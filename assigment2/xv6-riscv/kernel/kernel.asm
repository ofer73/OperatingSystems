
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
    80000068:	10c78793          	addi	a5,a5,268 # 80006170 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd27ff>
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
    80000122:	43c080e7          	jalr	1084(ra) # 8000255a <either_copyin>
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
    800001c8:	f06080e7          	jalr	-250(ra) # 800020ca <sleep>
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
    80000204:	304080e7          	jalr	772(ra) # 80002504 <either_copyout>
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
    800002e6:	2ce080e7          	jalr	718(ra) # 800025b0 <procdump>
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
    8000043a:	e22080e7          	jalr	-478(ra) # 80002258 <wakeup>
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
    80000468:	00027797          	auipc	a5,0x27
    8000046c:	6b078793          	addi	a5,a5,1712 # 80027b18 <devsw>
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
    80000886:	9d6080e7          	jalr	-1578(ra) # 80002258 <wakeup>
    
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
    80000912:	7bc080e7          	jalr	1980(ra) # 800020ca <sleep>
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
    800009ee:	0002b797          	auipc	a5,0x2b
    800009f2:	61278793          	addi	a5,a5,1554 # 8002c000 <end>
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
    80000abe:	0002b517          	auipc	a0,0x2b
    80000ac2:	54250513          	addi	a0,a0,1346 # 8002c000 <end>
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
    80000ed0:	a3a080e7          	jalr	-1478(ra) # 80002906 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ed4:	00005097          	auipc	ra,0x5
    80000ed8:	2dc080e7          	jalr	732(ra) # 800061b0 <plicinithart>
  }

  scheduler();        
    80000edc:	00001097          	auipc	ra,0x1
    80000ee0:	03c080e7          	jalr	60(ra) # 80001f18 <scheduler>
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
    80000f48:	99a080e7          	jalr	-1638(ra) # 800028de <trapinit>
    trapinithart();  // install kernel trap vector
    80000f4c:	00002097          	auipc	ra,0x2
    80000f50:	9ba080e7          	jalr	-1606(ra) # 80002906 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f54:	00005097          	auipc	ra,0x5
    80000f58:	246080e7          	jalr	582(ra) # 8000619a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f5c:	00005097          	auipc	ra,0x5
    80000f60:	254080e7          	jalr	596(ra) # 800061b0 <plicinithart>
    binit();         // buffer cache
    80000f64:	00002097          	auipc	ra,0x2
    80000f68:	3e6080e7          	jalr	998(ra) # 8000334a <binit>
    iinit();         // inode cache
    80000f6c:	00003097          	auipc	ra,0x3
    80000f70:	a78080e7          	jalr	-1416(ra) # 800039e4 <iinit>
    fileinit();      // file table
    80000f74:	00004097          	auipc	ra,0x4
    80000f78:	a26080e7          	jalr	-1498(ra) # 8000499a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f7c:	00005097          	auipc	ra,0x5
    80000f80:	356080e7          	jalr	854(ra) # 800062d2 <virtio_disk_init>
    userinit();      // first user process
    80000f84:	00001097          	auipc	ra,0x1
    80000f88:	d20080e7          	jalr	-736(ra) # 80001ca4 <userinit>
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
    800017fa:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd3000>
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
    80001856:	0001ca17          	auipc	s4,0x1c
    8000185a:	07aa0a13          	addi	s4,s4,122 # 8001d8d0 <tickslock>
    char *pa = kalloc();
    8000185e:	fffff097          	auipc	ra,0xfffff
    80001862:	278080e7          	jalr	632(ra) # 80000ad6 <kalloc>
    80001866:	862a                	mv	a2,a0
    if(pa == 0)
    80001868:	c131                	beqz	a0,800018ac <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000186a:	416485b3          	sub	a1,s1,s6
    8000186e:	858d                	srai	a1,a1,0x3
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
    80001890:	30848493          	addi	s1,s1,776
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
    80001922:	0001c997          	auipc	s3,0x1c
    80001926:	fae98993          	addi	s3,s3,-82 # 8001d8d0 <tickslock>
      initlock(&p->lock, "proc");
    8000192a:	85da                	mv	a1,s6
    8000192c:	8526                	mv	a0,s1
    8000192e:	fffff097          	auipc	ra,0xfffff
    80001932:	208080e7          	jalr	520(ra) # 80000b36 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001936:	415487b3          	sub	a5,s1,s5
    8000193a:	878d                	srai	a5,a5,0x3
    8000193c:	000a3703          	ld	a4,0(s4)
    80001940:	02e787b3          	mul	a5,a5,a4
    80001944:	2785                	addiw	a5,a5,1
    80001946:	00d7979b          	slliw	a5,a5,0xd
    8000194a:	40f907b3          	sub	a5,s2,a5
    8000194e:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001950:	30848493          	addi	s1,s1,776
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
    800019ec:	ee87a783          	lw	a5,-280(a5) # 800088d0 <first.1>
    800019f0:	eb89                	bnez	a5,80001a02 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019f2:	00001097          	auipc	ra,0x1
    800019f6:	148080e7          	jalr	328(ra) # 80002b3a <usertrapret>
}
    800019fa:	60a2                	ld	ra,8(sp)
    800019fc:	6402                	ld	s0,0(sp)
    800019fe:	0141                	addi	sp,sp,16
    80001a00:	8082                	ret
    first = 0;
    80001a02:	00007797          	auipc	a5,0x7
    80001a06:	ec07a723          	sw	zero,-306(a5) # 800088d0 <first.1>
    fsinit(ROOTDEV);
    80001a0a:	4505                	li	a0,1
    80001a0c:	00002097          	auipc	ra,0x2
    80001a10:	f58080e7          	jalr	-168(ra) # 80003964 <fsinit>
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
    80001a38:	ea078793          	addi	a5,a5,-352 # 800088d4 <nextpid>
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
  p->user_trapframe_backup = 0;
    80001b66:	2e04bc23          	sd	zero,760(s1)
  if(p->pagetable)
    80001b6a:	68a8                	ld	a0,80(s1)
    80001b6c:	c511                	beqz	a0,80001b78 <freeproc+0x2e>
    proc_freepagetable(p->pagetable, p->sz);
    80001b6e:	64ac                	ld	a1,72(s1)
    80001b70:	00000097          	auipc	ra,0x0
    80001b74:	f88080e7          	jalr	-120(ra) # 80001af8 <proc_freepagetable>
  p->pagetable = 0;
    80001b78:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b7c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b80:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b84:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b88:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b8c:	0204b023          	sd	zero,32(s1)
  p->xstate = 0;
    80001b90:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b94:	0004ac23          	sw	zero,24(s1)
}
    80001b98:	60e2                	ld	ra,24(sp)
    80001b9a:	6442                	ld	s0,16(sp)
    80001b9c:	64a2                	ld	s1,8(sp)
    80001b9e:	6105                	addi	sp,sp,32
    80001ba0:	8082                	ret

0000000080001ba2 <allocproc>:
{
    80001ba2:	7179                	addi	sp,sp,-48
    80001ba4:	f406                	sd	ra,40(sp)
    80001ba6:	f022                	sd	s0,32(sp)
    80001ba8:	ec26                	sd	s1,24(sp)
    80001baa:	e84a                	sd	s2,16(sp)
    80001bac:	e44e                	sd	s3,8(sp)
    80001bae:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bb0:	00010497          	auipc	s1,0x10
    80001bb4:	b2048493          	addi	s1,s1,-1248 # 800116d0 <proc>
    80001bb8:	0001c997          	auipc	s3,0x1c
    80001bbc:	d1898993          	addi	s3,s3,-744 # 8001d8d0 <tickslock>
    acquire(&p->lock);
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	fffff097          	auipc	ra,0xfffff
    80001bc6:	004080e7          	jalr	4(ra) # 80000bc6 <acquire>
    if(p->state == UNUSED) {
    80001bca:	4c9c                	lw	a5,24(s1)
    80001bcc:	cf81                	beqz	a5,80001be4 <allocproc+0x42>
      release(&p->lock);
    80001bce:	8526                	mv	a0,s1
    80001bd0:	fffff097          	auipc	ra,0xfffff
    80001bd4:	0c0080e7          	jalr	192(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bd8:	30848493          	addi	s1,s1,776
    80001bdc:	ff3492e3          	bne	s1,s3,80001bc0 <allocproc+0x1e>
  return 0;
    80001be0:	4481                	li	s1,0
    80001be2:	a049                	j	80001c64 <allocproc+0xc2>
  p->pid = allocpid();
    80001be4:	00000097          	auipc	ra,0x0
    80001be8:	e32080e7          	jalr	-462(ra) # 80001a16 <allocpid>
    80001bec:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bee:	4785                	li	a5,1
    80001bf0:	cc9c                	sw	a5,24(s1)
  for(int i=0;i<32;i++){
    80001bf2:	17848713          	addi	a4,s1,376
    80001bf6:	27848793          	addi	a5,s1,632
    80001bfa:	2f848693          	addi	a3,s1,760
    p->signal_handlers[i] = SIG_DFL;
    80001bfe:	00073023          	sd	zero,0(a4)
    p->handlers_sigmasks[i] = 0;
    80001c02:	0007a023          	sw	zero,0(a5)
  for(int i=0;i<32;i++){
    80001c06:	0721                	addi	a4,a4,8
    80001c08:	0791                	addi	a5,a5,4
    80001c0a:	fed79ae3          	bne	a5,a3,80001bfe <allocproc+0x5c>
  p->signal_mask= 0;
    80001c0e:	1604a623          	sw	zero,364(s1)
  p->pending_signals = 0;
    80001c12:	1604a423          	sw	zero,360(s1)
  p->frozen=0;
    80001c16:	3004a023          	sw	zero,768(s1)
  p->signal_mask_backup = 0;
    80001c1a:	1604a823          	sw	zero,368(s1)
  p->handling_user_sig_flag = 0;
    80001c1e:	3004a223          	sw	zero,772(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	eb4080e7          	jalr	-332(ra) # 80000ad6 <kalloc>
    80001c2a:	892a                	mv	s2,a0
    80001c2c:	eca8                	sd	a0,88(s1)
    80001c2e:	c139                	beqz	a0,80001c74 <allocproc+0xd2>
  p->pagetable = proc_pagetable(p);
    80001c30:	8526                	mv	a0,s1
    80001c32:	00000097          	auipc	ra,0x0
    80001c36:	e2a080e7          	jalr	-470(ra) # 80001a5c <proc_pagetable>
    80001c3a:	892a                	mv	s2,a0
    80001c3c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c3e:	c539                	beqz	a0,80001c8c <allocproc+0xea>
  memset(&p->context, 0, sizeof(p->context));
    80001c40:	07000613          	li	a2,112
    80001c44:	4581                	li	a1,0
    80001c46:	06048513          	addi	a0,s1,96
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	08e080e7          	jalr	142(ra) # 80000cd8 <memset>
  p->context.ra = (uint64)forkret;
    80001c52:	00000797          	auipc	a5,0x0
    80001c56:	d7e78793          	addi	a5,a5,-642 # 800019d0 <forkret>
    80001c5a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c5c:	60bc                	ld	a5,64(s1)
    80001c5e:	6705                	lui	a4,0x1
    80001c60:	97ba                	add	a5,a5,a4
    80001c62:	f4bc                	sd	a5,104(s1)
}
    80001c64:	8526                	mv	a0,s1
    80001c66:	70a2                	ld	ra,40(sp)
    80001c68:	7402                	ld	s0,32(sp)
    80001c6a:	64e2                	ld	s1,24(sp)
    80001c6c:	6942                	ld	s2,16(sp)
    80001c6e:	69a2                	ld	s3,8(sp)
    80001c70:	6145                	addi	sp,sp,48
    80001c72:	8082                	ret
    freeproc(p);
    80001c74:	8526                	mv	a0,s1
    80001c76:	00000097          	auipc	ra,0x0
    80001c7a:	ed4080e7          	jalr	-300(ra) # 80001b4a <freeproc>
    release(&p->lock);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	010080e7          	jalr	16(ra) # 80000c90 <release>
    return 0;
    80001c88:	84ca                	mv	s1,s2
    80001c8a:	bfe9                	j	80001c64 <allocproc+0xc2>
    freeproc(p);
    80001c8c:	8526                	mv	a0,s1
    80001c8e:	00000097          	auipc	ra,0x0
    80001c92:	ebc080e7          	jalr	-324(ra) # 80001b4a <freeproc>
    release(&p->lock);
    80001c96:	8526                	mv	a0,s1
    80001c98:	fffff097          	auipc	ra,0xfffff
    80001c9c:	ff8080e7          	jalr	-8(ra) # 80000c90 <release>
    return 0;
    80001ca0:	84ca                	mv	s1,s2
    80001ca2:	b7c9                	j	80001c64 <allocproc+0xc2>

0000000080001ca4 <userinit>:
{
    80001ca4:	1101                	addi	sp,sp,-32
    80001ca6:	ec06                	sd	ra,24(sp)
    80001ca8:	e822                	sd	s0,16(sp)
    80001caa:	e426                	sd	s1,8(sp)
    80001cac:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cae:	00000097          	auipc	ra,0x0
    80001cb2:	ef4080e7          	jalr	-268(ra) # 80001ba2 <allocproc>
    80001cb6:	84aa                	mv	s1,a0
  initproc = p;
    80001cb8:	00007797          	auipc	a5,0x7
    80001cbc:	36a7b823          	sd	a0,880(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cc0:	03400613          	li	a2,52
    80001cc4:	00007597          	auipc	a1,0x7
    80001cc8:	c1c58593          	addi	a1,a1,-996 # 800088e0 <initcode>
    80001ccc:	6928                	ld	a0,80(a0)
    80001cce:	fffff097          	auipc	ra,0xfffff
    80001cd2:	680080e7          	jalr	1664(ra) # 8000134e <uvminit>
  p->sz = PGSIZE;
    80001cd6:	6785                	lui	a5,0x1
    80001cd8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cda:	6cb8                	ld	a4,88(s1)
    80001cdc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001ce0:	6cb8                	ld	a4,88(s1)
    80001ce2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ce4:	4641                	li	a2,16
    80001ce6:	00006597          	auipc	a1,0x6
    80001cea:	53258593          	addi	a1,a1,1330 # 80008218 <digits+0x1d8>
    80001cee:	15848513          	addi	a0,s1,344
    80001cf2:	fffff097          	auipc	ra,0xfffff
    80001cf6:	138080e7          	jalr	312(ra) # 80000e2a <safestrcpy>
  p->cwd = namei("/");
    80001cfa:	00006517          	auipc	a0,0x6
    80001cfe:	52e50513          	addi	a0,a0,1326 # 80008228 <digits+0x1e8>
    80001d02:	00002097          	auipc	ra,0x2
    80001d06:	690080e7          	jalr	1680(ra) # 80004392 <namei>
    80001d0a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d0e:	478d                	li	a5,3
    80001d10:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d12:	8526                	mv	a0,s1
    80001d14:	fffff097          	auipc	ra,0xfffff
    80001d18:	f7c080e7          	jalr	-132(ra) # 80000c90 <release>
}
    80001d1c:	60e2                	ld	ra,24(sp)
    80001d1e:	6442                	ld	s0,16(sp)
    80001d20:	64a2                	ld	s1,8(sp)
    80001d22:	6105                	addi	sp,sp,32
    80001d24:	8082                	ret

0000000080001d26 <growproc>:
{
    80001d26:	1101                	addi	sp,sp,-32
    80001d28:	ec06                	sd	ra,24(sp)
    80001d2a:	e822                	sd	s0,16(sp)
    80001d2c:	e426                	sd	s1,8(sp)
    80001d2e:	e04a                	sd	s2,0(sp)
    80001d30:	1000                	addi	s0,sp,32
    80001d32:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d34:	00000097          	auipc	ra,0x0
    80001d38:	c64080e7          	jalr	-924(ra) # 80001998 <myproc>
    80001d3c:	892a                	mv	s2,a0
  sz = p->sz;
    80001d3e:	652c                	ld	a1,72(a0)
    80001d40:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d44:	00904f63          	bgtz	s1,80001d62 <growproc+0x3c>
  } else if(n < 0){
    80001d48:	0204cc63          	bltz	s1,80001d80 <growproc+0x5a>
  p->sz = sz;
    80001d4c:	1602                	slli	a2,a2,0x20
    80001d4e:	9201                	srli	a2,a2,0x20
    80001d50:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d54:	4501                	li	a0,0
}
    80001d56:	60e2                	ld	ra,24(sp)
    80001d58:	6442                	ld	s0,16(sp)
    80001d5a:	64a2                	ld	s1,8(sp)
    80001d5c:	6902                	ld	s2,0(sp)
    80001d5e:	6105                	addi	sp,sp,32
    80001d60:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d62:	9e25                	addw	a2,a2,s1
    80001d64:	1602                	slli	a2,a2,0x20
    80001d66:	9201                	srli	a2,a2,0x20
    80001d68:	1582                	slli	a1,a1,0x20
    80001d6a:	9181                	srli	a1,a1,0x20
    80001d6c:	6928                	ld	a0,80(a0)
    80001d6e:	fffff097          	auipc	ra,0xfffff
    80001d72:	69a080e7          	jalr	1690(ra) # 80001408 <uvmalloc>
    80001d76:	0005061b          	sext.w	a2,a0
    80001d7a:	fa69                	bnez	a2,80001d4c <growproc+0x26>
      return -1;
    80001d7c:	557d                	li	a0,-1
    80001d7e:	bfe1                	j	80001d56 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d80:	9e25                	addw	a2,a2,s1
    80001d82:	1602                	slli	a2,a2,0x20
    80001d84:	9201                	srli	a2,a2,0x20
    80001d86:	1582                	slli	a1,a1,0x20
    80001d88:	9181                	srli	a1,a1,0x20
    80001d8a:	6928                	ld	a0,80(a0)
    80001d8c:	fffff097          	auipc	ra,0xfffff
    80001d90:	634080e7          	jalr	1588(ra) # 800013c0 <uvmdealloc>
    80001d94:	0005061b          	sext.w	a2,a0
    80001d98:	bf55                	j	80001d4c <growproc+0x26>

0000000080001d9a <fork>:
{
    80001d9a:	7139                	addi	sp,sp,-64
    80001d9c:	fc06                	sd	ra,56(sp)
    80001d9e:	f822                	sd	s0,48(sp)
    80001da0:	f426                	sd	s1,40(sp)
    80001da2:	f04a                	sd	s2,32(sp)
    80001da4:	ec4e                	sd	s3,24(sp)
    80001da6:	e852                	sd	s4,16(sp)
    80001da8:	e456                	sd	s5,8(sp)
    80001daa:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dac:	00000097          	auipc	ra,0x0
    80001db0:	bec080e7          	jalr	-1044(ra) # 80001998 <myproc>
    80001db4:	89aa                	mv	s3,a0
  if((np = allocproc()) == 0){
    80001db6:	00000097          	auipc	ra,0x0
    80001dba:	dec080e7          	jalr	-532(ra) # 80001ba2 <allocproc>
    80001dbe:	14050b63          	beqz	a0,80001f14 <fork+0x17a>
    80001dc2:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dc4:	0489b603          	ld	a2,72(s3)
    80001dc8:	692c                	ld	a1,80(a0)
    80001dca:	0509b503          	ld	a0,80(s3)
    80001dce:	fffff097          	auipc	ra,0xfffff
    80001dd2:	786080e7          	jalr	1926(ra) # 80001554 <uvmcopy>
    80001dd6:	04054863          	bltz	a0,80001e26 <fork+0x8c>
  np->sz = p->sz;
    80001dda:	0489b783          	ld	a5,72(s3)
    80001dde:	04f93423          	sd	a5,72(s2)
  *(np->trapframe) = *(p->trapframe);
    80001de2:	0589b683          	ld	a3,88(s3)
    80001de6:	87b6                	mv	a5,a3
    80001de8:	05893703          	ld	a4,88(s2)
    80001dec:	12068693          	addi	a3,a3,288
    80001df0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001df4:	6788                	ld	a0,8(a5)
    80001df6:	6b8c                	ld	a1,16(a5)
    80001df8:	6f90                	ld	a2,24(a5)
    80001dfa:	01073023          	sd	a6,0(a4)
    80001dfe:	e708                	sd	a0,8(a4)
    80001e00:	eb0c                	sd	a1,16(a4)
    80001e02:	ef10                	sd	a2,24(a4)
    80001e04:	02078793          	addi	a5,a5,32
    80001e08:	02070713          	addi	a4,a4,32
    80001e0c:	fed792e3          	bne	a5,a3,80001df0 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e10:	05893783          	ld	a5,88(s2)
    80001e14:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e18:	0d098493          	addi	s1,s3,208
    80001e1c:	0d090a13          	addi	s4,s2,208
    80001e20:	15098a93          	addi	s5,s3,336
    80001e24:	a00d                	j	80001e46 <fork+0xac>
    freeproc(np);
    80001e26:	854a                	mv	a0,s2
    80001e28:	00000097          	auipc	ra,0x0
    80001e2c:	d22080e7          	jalr	-734(ra) # 80001b4a <freeproc>
    release(&np->lock);
    80001e30:	854a                	mv	a0,s2
    80001e32:	fffff097          	auipc	ra,0xfffff
    80001e36:	e5e080e7          	jalr	-418(ra) # 80000c90 <release>
    return -1;
    80001e3a:	54fd                	li	s1,-1
    80001e3c:	a0d1                	j	80001f00 <fork+0x166>
  for(i = 0; i < NOFILE; i++)
    80001e3e:	04a1                	addi	s1,s1,8
    80001e40:	0a21                	addi	s4,s4,8
    80001e42:	01548b63          	beq	s1,s5,80001e58 <fork+0xbe>
    if(p->ofile[i])
    80001e46:	6088                	ld	a0,0(s1)
    80001e48:	d97d                	beqz	a0,80001e3e <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e4a:	00003097          	auipc	ra,0x3
    80001e4e:	be2080e7          	jalr	-1054(ra) # 80004a2c <filedup>
    80001e52:	00aa3023          	sd	a0,0(s4)
    80001e56:	b7e5                	j	80001e3e <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e58:	1509b503          	ld	a0,336(s3)
    80001e5c:	00002097          	auipc	ra,0x2
    80001e60:	d42080e7          	jalr	-702(ra) # 80003b9e <idup>
    80001e64:	14a93823          	sd	a0,336(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e68:	4641                	li	a2,16
    80001e6a:	15898593          	addi	a1,s3,344
    80001e6e:	15890513          	addi	a0,s2,344
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	fb8080e7          	jalr	-72(ra) # 80000e2a <safestrcpy>
  pid = np->pid;
    80001e7a:	03092483          	lw	s1,48(s2)
  release(&np->lock);
    80001e7e:	854a                	mv	a0,s2
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	e10080e7          	jalr	-496(ra) # 80000c90 <release>
  acquire(&wait_lock);
    80001e88:	0000f517          	auipc	a0,0xf
    80001e8c:	43050513          	addi	a0,a0,1072 # 800112b8 <wait_lock>
    80001e90:	fffff097          	auipc	ra,0xfffff
    80001e94:	d36080e7          	jalr	-714(ra) # 80000bc6 <acquire>
  np->parent = p;
    80001e98:	03393c23          	sd	s3,56(s2)
  np->signal_mask = p->signal_mask;
    80001e9c:	16c9a783          	lw	a5,364(s3)
    80001ea0:	16f92623          	sw	a5,364(s2)
  for(int i=0;i<32;i++){
    80001ea4:	17898693          	addi	a3,s3,376
    80001ea8:	17890713          	addi	a4,s2,376
  np->signal_mask = p->signal_mask;
    80001eac:	27800793          	li	a5,632
  for(int i=0;i<32;i++){
    80001eb0:	2f800513          	li	a0,760
    np->signal_handlers[i] = p->signal_handlers[i];
    80001eb4:	6290                	ld	a2,0(a3)
    80001eb6:	e310                	sd	a2,0(a4)
    np->handlers_sigmasks[i] = p->handlers_sigmasks[i];
    80001eb8:	00f98633          	add	a2,s3,a5
    80001ebc:	420c                	lw	a1,0(a2)
    80001ebe:	00f90633          	add	a2,s2,a5
    80001ec2:	c20c                	sw	a1,0(a2)
  for(int i=0;i<32;i++){
    80001ec4:	06a1                	addi	a3,a3,8
    80001ec6:	0721                	addi	a4,a4,8
    80001ec8:	0791                	addi	a5,a5,4
    80001eca:	fea795e3          	bne	a5,a0,80001eb4 <fork+0x11a>
  np-> pending_signals=0;
    80001ece:	16092423          	sw	zero,360(s2)
  np->frozen=0;
    80001ed2:	30092023          	sw	zero,768(s2)
  release(&wait_lock);
    80001ed6:	0000f517          	auipc	a0,0xf
    80001eda:	3e250513          	addi	a0,a0,994 # 800112b8 <wait_lock>
    80001ede:	fffff097          	auipc	ra,0xfffff
    80001ee2:	db2080e7          	jalr	-590(ra) # 80000c90 <release>
  acquire(&np->lock);
    80001ee6:	854a                	mv	a0,s2
    80001ee8:	fffff097          	auipc	ra,0xfffff
    80001eec:	cde080e7          	jalr	-802(ra) # 80000bc6 <acquire>
  np->state = RUNNABLE;
    80001ef0:	478d                	li	a5,3
    80001ef2:	00f92c23          	sw	a5,24(s2)
  release(&np->lock);
    80001ef6:	854a                	mv	a0,s2
    80001ef8:	fffff097          	auipc	ra,0xfffff
    80001efc:	d98080e7          	jalr	-616(ra) # 80000c90 <release>
}
    80001f00:	8526                	mv	a0,s1
    80001f02:	70e2                	ld	ra,56(sp)
    80001f04:	7442                	ld	s0,48(sp)
    80001f06:	74a2                	ld	s1,40(sp)
    80001f08:	7902                	ld	s2,32(sp)
    80001f0a:	69e2                	ld	s3,24(sp)
    80001f0c:	6a42                	ld	s4,16(sp)
    80001f0e:	6aa2                	ld	s5,8(sp)
    80001f10:	6121                	addi	sp,sp,64
    80001f12:	8082                	ret
    return -1;
    80001f14:	54fd                	li	s1,-1
    80001f16:	b7ed                	j	80001f00 <fork+0x166>

0000000080001f18 <scheduler>:
{
    80001f18:	7139                	addi	sp,sp,-64
    80001f1a:	fc06                	sd	ra,56(sp)
    80001f1c:	f822                	sd	s0,48(sp)
    80001f1e:	f426                	sd	s1,40(sp)
    80001f20:	f04a                	sd	s2,32(sp)
    80001f22:	ec4e                	sd	s3,24(sp)
    80001f24:	e852                	sd	s4,16(sp)
    80001f26:	e456                	sd	s5,8(sp)
    80001f28:	e05a                	sd	s6,0(sp)
    80001f2a:	0080                	addi	s0,sp,64
    80001f2c:	8792                	mv	a5,tp
  int id = r_tp();
    80001f2e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f30:	00779a93          	slli	s5,a5,0x7
    80001f34:	0000f717          	auipc	a4,0xf
    80001f38:	36c70713          	addi	a4,a4,876 # 800112a0 <pid_lock>
    80001f3c:	9756                	add	a4,a4,s5
    80001f3e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f42:	0000f717          	auipc	a4,0xf
    80001f46:	39670713          	addi	a4,a4,918 # 800112d8 <cpus+0x8>
    80001f4a:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f4c:	498d                	li	s3,3
        p->state = RUNNING;
    80001f4e:	4b11                	li	s6,4
        c->proc = p;
    80001f50:	079e                	slli	a5,a5,0x7
    80001f52:	0000fa17          	auipc	s4,0xf
    80001f56:	34ea0a13          	addi	s4,s4,846 # 800112a0 <pid_lock>
    80001f5a:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f5c:	0001c917          	auipc	s2,0x1c
    80001f60:	97490913          	addi	s2,s2,-1676 # 8001d8d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f64:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f68:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f6c:	10079073          	csrw	sstatus,a5
    80001f70:	0000f497          	auipc	s1,0xf
    80001f74:	76048493          	addi	s1,s1,1888 # 800116d0 <proc>
    80001f78:	a811                	j	80001f8c <scheduler+0x74>
      release(&p->lock);
    80001f7a:	8526                	mv	a0,s1
    80001f7c:	fffff097          	auipc	ra,0xfffff
    80001f80:	d14080e7          	jalr	-748(ra) # 80000c90 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f84:	30848493          	addi	s1,s1,776
    80001f88:	fd248ee3          	beq	s1,s2,80001f64 <scheduler+0x4c>
      acquire(&p->lock);
    80001f8c:	8526                	mv	a0,s1
    80001f8e:	fffff097          	auipc	ra,0xfffff
    80001f92:	c38080e7          	jalr	-968(ra) # 80000bc6 <acquire>
      if(p->state == RUNNABLE) {
    80001f96:	4c9c                	lw	a5,24(s1)
    80001f98:	ff3791e3          	bne	a5,s3,80001f7a <scheduler+0x62>
        p->state = RUNNING;
    80001f9c:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fa0:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fa4:	06048593          	addi	a1,s1,96
    80001fa8:	8556                	mv	a0,s5
    80001faa:	00001097          	auipc	ra,0x1
    80001fae:	8ca080e7          	jalr	-1846(ra) # 80002874 <swtch>
        c->proc = 0;
    80001fb2:	020a3823          	sd	zero,48(s4)
    80001fb6:	b7d1                	j	80001f7a <scheduler+0x62>

0000000080001fb8 <sched>:
{
    80001fb8:	7179                	addi	sp,sp,-48
    80001fba:	f406                	sd	ra,40(sp)
    80001fbc:	f022                	sd	s0,32(sp)
    80001fbe:	ec26                	sd	s1,24(sp)
    80001fc0:	e84a                	sd	s2,16(sp)
    80001fc2:	e44e                	sd	s3,8(sp)
    80001fc4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fc6:	00000097          	auipc	ra,0x0
    80001fca:	9d2080e7          	jalr	-1582(ra) # 80001998 <myproc>
    80001fce:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fd0:	fffff097          	auipc	ra,0xfffff
    80001fd4:	b7c080e7          	jalr	-1156(ra) # 80000b4c <holding>
    80001fd8:	c93d                	beqz	a0,8000204e <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fda:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fdc:	2781                	sext.w	a5,a5
    80001fde:	079e                	slli	a5,a5,0x7
    80001fe0:	0000f717          	auipc	a4,0xf
    80001fe4:	2c070713          	addi	a4,a4,704 # 800112a0 <pid_lock>
    80001fe8:	97ba                	add	a5,a5,a4
    80001fea:	0a87a703          	lw	a4,168(a5)
    80001fee:	4785                	li	a5,1
    80001ff0:	06f71763          	bne	a4,a5,8000205e <sched+0xa6>
  if(p->state == RUNNING)
    80001ff4:	4c98                	lw	a4,24(s1)
    80001ff6:	4791                	li	a5,4
    80001ff8:	06f70b63          	beq	a4,a5,8000206e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ffc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002000:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002002:	efb5                	bnez	a5,8000207e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002004:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002006:	0000f917          	auipc	s2,0xf
    8000200a:	29a90913          	addi	s2,s2,666 # 800112a0 <pid_lock>
    8000200e:	2781                	sext.w	a5,a5
    80002010:	079e                	slli	a5,a5,0x7
    80002012:	97ca                	add	a5,a5,s2
    80002014:	0ac7a983          	lw	s3,172(a5)
    80002018:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000201a:	2781                	sext.w	a5,a5
    8000201c:	079e                	slli	a5,a5,0x7
    8000201e:	0000f597          	auipc	a1,0xf
    80002022:	2ba58593          	addi	a1,a1,698 # 800112d8 <cpus+0x8>
    80002026:	95be                	add	a1,a1,a5
    80002028:	06048513          	addi	a0,s1,96
    8000202c:	00001097          	auipc	ra,0x1
    80002030:	848080e7          	jalr	-1976(ra) # 80002874 <swtch>
    80002034:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002036:	2781                	sext.w	a5,a5
    80002038:	079e                	slli	a5,a5,0x7
    8000203a:	97ca                	add	a5,a5,s2
    8000203c:	0b37a623          	sw	s3,172(a5)
}
    80002040:	70a2                	ld	ra,40(sp)
    80002042:	7402                	ld	s0,32(sp)
    80002044:	64e2                	ld	s1,24(sp)
    80002046:	6942                	ld	s2,16(sp)
    80002048:	69a2                	ld	s3,8(sp)
    8000204a:	6145                	addi	sp,sp,48
    8000204c:	8082                	ret
    panic("sched p->lock");
    8000204e:	00006517          	auipc	a0,0x6
    80002052:	1e250513          	addi	a0,a0,482 # 80008230 <digits+0x1f0>
    80002056:	ffffe097          	auipc	ra,0xffffe
    8000205a:	4d8080e7          	jalr	1240(ra) # 8000052e <panic>
    panic("sched locks");
    8000205e:	00006517          	auipc	a0,0x6
    80002062:	1e250513          	addi	a0,a0,482 # 80008240 <digits+0x200>
    80002066:	ffffe097          	auipc	ra,0xffffe
    8000206a:	4c8080e7          	jalr	1224(ra) # 8000052e <panic>
    panic("sched running");
    8000206e:	00006517          	auipc	a0,0x6
    80002072:	1e250513          	addi	a0,a0,482 # 80008250 <digits+0x210>
    80002076:	ffffe097          	auipc	ra,0xffffe
    8000207a:	4b8080e7          	jalr	1208(ra) # 8000052e <panic>
    panic("sched interruptible");
    8000207e:	00006517          	auipc	a0,0x6
    80002082:	1e250513          	addi	a0,a0,482 # 80008260 <digits+0x220>
    80002086:	ffffe097          	auipc	ra,0xffffe
    8000208a:	4a8080e7          	jalr	1192(ra) # 8000052e <panic>

000000008000208e <yield>:
{
    8000208e:	1101                	addi	sp,sp,-32
    80002090:	ec06                	sd	ra,24(sp)
    80002092:	e822                	sd	s0,16(sp)
    80002094:	e426                	sd	s1,8(sp)
    80002096:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002098:	00000097          	auipc	ra,0x0
    8000209c:	900080e7          	jalr	-1792(ra) # 80001998 <myproc>
    800020a0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020a2:	fffff097          	auipc	ra,0xfffff
    800020a6:	b24080e7          	jalr	-1244(ra) # 80000bc6 <acquire>
  p->state = RUNNABLE;
    800020aa:	478d                	li	a5,3
    800020ac:	cc9c                	sw	a5,24(s1)
  sched();
    800020ae:	00000097          	auipc	ra,0x0
    800020b2:	f0a080e7          	jalr	-246(ra) # 80001fb8 <sched>
  release(&p->lock);
    800020b6:	8526                	mv	a0,s1
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	bd8080e7          	jalr	-1064(ra) # 80000c90 <release>
}
    800020c0:	60e2                	ld	ra,24(sp)
    800020c2:	6442                	ld	s0,16(sp)
    800020c4:	64a2                	ld	s1,8(sp)
    800020c6:	6105                	addi	sp,sp,32
    800020c8:	8082                	ret

00000000800020ca <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020ca:	7179                	addi	sp,sp,-48
    800020cc:	f406                	sd	ra,40(sp)
    800020ce:	f022                	sd	s0,32(sp)
    800020d0:	ec26                	sd	s1,24(sp)
    800020d2:	e84a                	sd	s2,16(sp)
    800020d4:	e44e                	sd	s3,8(sp)
    800020d6:	1800                	addi	s0,sp,48
    800020d8:	89aa                	mv	s3,a0
    800020da:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020dc:	00000097          	auipc	ra,0x0
    800020e0:	8bc080e7          	jalr	-1860(ra) # 80001998 <myproc>
    800020e4:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020e6:	fffff097          	auipc	ra,0xfffff
    800020ea:	ae0080e7          	jalr	-1312(ra) # 80000bc6 <acquire>
  release(lk);
    800020ee:	854a                	mv	a0,s2
    800020f0:	fffff097          	auipc	ra,0xfffff
    800020f4:	ba0080e7          	jalr	-1120(ra) # 80000c90 <release>

  // Go to sleep.
  p->chan = chan;
    800020f8:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020fc:	4789                	li	a5,2
    800020fe:	cc9c                	sw	a5,24(s1)

  sched();
    80002100:	00000097          	auipc	ra,0x0
    80002104:	eb8080e7          	jalr	-328(ra) # 80001fb8 <sched>

  // Tidy up.
  p->chan = 0;
    80002108:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000210c:	8526                	mv	a0,s1
    8000210e:	fffff097          	auipc	ra,0xfffff
    80002112:	b82080e7          	jalr	-1150(ra) # 80000c90 <release>
  acquire(lk);
    80002116:	854a                	mv	a0,s2
    80002118:	fffff097          	auipc	ra,0xfffff
    8000211c:	aae080e7          	jalr	-1362(ra) # 80000bc6 <acquire>
}
    80002120:	70a2                	ld	ra,40(sp)
    80002122:	7402                	ld	s0,32(sp)
    80002124:	64e2                	ld	s1,24(sp)
    80002126:	6942                	ld	s2,16(sp)
    80002128:	69a2                	ld	s3,8(sp)
    8000212a:	6145                	addi	sp,sp,48
    8000212c:	8082                	ret

000000008000212e <wait>:
{
    8000212e:	715d                	addi	sp,sp,-80
    80002130:	e486                	sd	ra,72(sp)
    80002132:	e0a2                	sd	s0,64(sp)
    80002134:	fc26                	sd	s1,56(sp)
    80002136:	f84a                	sd	s2,48(sp)
    80002138:	f44e                	sd	s3,40(sp)
    8000213a:	f052                	sd	s4,32(sp)
    8000213c:	ec56                	sd	s5,24(sp)
    8000213e:	e85a                	sd	s6,16(sp)
    80002140:	e45e                	sd	s7,8(sp)
    80002142:	e062                	sd	s8,0(sp)
    80002144:	0880                	addi	s0,sp,80
    80002146:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002148:	00000097          	auipc	ra,0x0
    8000214c:	850080e7          	jalr	-1968(ra) # 80001998 <myproc>
    80002150:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002152:	0000f517          	auipc	a0,0xf
    80002156:	16650513          	addi	a0,a0,358 # 800112b8 <wait_lock>
    8000215a:	fffff097          	auipc	ra,0xfffff
    8000215e:	a6c080e7          	jalr	-1428(ra) # 80000bc6 <acquire>
    havekids = 0;
    80002162:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002164:	4a95                	li	s5,5
        havekids = 1;
    80002166:	4a05                	li	s4,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002168:	0001b997          	auipc	s3,0x1b
    8000216c:	76898993          	addi	s3,s3,1896 # 8001d8d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002170:	0000fc17          	auipc	s8,0xf
    80002174:	148c0c13          	addi	s8,s8,328 # 800112b8 <wait_lock>
    havekids = 0;
    80002178:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000217a:	0000f497          	auipc	s1,0xf
    8000217e:	55648493          	addi	s1,s1,1366 # 800116d0 <proc>
    80002182:	a0bd                	j	800021f0 <wait+0xc2>
          pid = np->pid;
    80002184:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002188:	000b0e63          	beqz	s6,800021a4 <wait+0x76>
    8000218c:	4691                	li	a3,4
    8000218e:	02c48613          	addi	a2,s1,44
    80002192:	85da                	mv	a1,s6
    80002194:	05093503          	ld	a0,80(s2)
    80002198:	fffff097          	auipc	ra,0xfffff
    8000219c:	4c0080e7          	jalr	1216(ra) # 80001658 <copyout>
    800021a0:	02054563          	bltz	a0,800021ca <wait+0x9c>
          freeproc(np);
    800021a4:	8526                	mv	a0,s1
    800021a6:	00000097          	auipc	ra,0x0
    800021aa:	9a4080e7          	jalr	-1628(ra) # 80001b4a <freeproc>
          release(&np->lock);
    800021ae:	8526                	mv	a0,s1
    800021b0:	fffff097          	auipc	ra,0xfffff
    800021b4:	ae0080e7          	jalr	-1312(ra) # 80000c90 <release>
          release(&wait_lock);
    800021b8:	0000f517          	auipc	a0,0xf
    800021bc:	10050513          	addi	a0,a0,256 # 800112b8 <wait_lock>
    800021c0:	fffff097          	auipc	ra,0xfffff
    800021c4:	ad0080e7          	jalr	-1328(ra) # 80000c90 <release>
          return pid;
    800021c8:	a0a5                	j	80002230 <wait+0x102>
            release(&np->lock);
    800021ca:	8526                	mv	a0,s1
    800021cc:	fffff097          	auipc	ra,0xfffff
    800021d0:	ac4080e7          	jalr	-1340(ra) # 80000c90 <release>
            release(&wait_lock);
    800021d4:	0000f517          	auipc	a0,0xf
    800021d8:	0e450513          	addi	a0,a0,228 # 800112b8 <wait_lock>
    800021dc:	fffff097          	auipc	ra,0xfffff
    800021e0:	ab4080e7          	jalr	-1356(ra) # 80000c90 <release>
            return -1;
    800021e4:	59fd                	li	s3,-1
    800021e6:	a0a9                	j	80002230 <wait+0x102>
    for(np = proc; np < &proc[NPROC]; np++){
    800021e8:	30848493          	addi	s1,s1,776
    800021ec:	03348463          	beq	s1,s3,80002214 <wait+0xe6>
      if(np->parent == p){
    800021f0:	7c9c                	ld	a5,56(s1)
    800021f2:	ff279be3          	bne	a5,s2,800021e8 <wait+0xba>
        acquire(&np->lock);
    800021f6:	8526                	mv	a0,s1
    800021f8:	fffff097          	auipc	ra,0xfffff
    800021fc:	9ce080e7          	jalr	-1586(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    80002200:	4c9c                	lw	a5,24(s1)
    80002202:	f95781e3          	beq	a5,s5,80002184 <wait+0x56>
        release(&np->lock);
    80002206:	8526                	mv	a0,s1
    80002208:	fffff097          	auipc	ra,0xfffff
    8000220c:	a88080e7          	jalr	-1400(ra) # 80000c90 <release>
        havekids = 1;
    80002210:	8752                	mv	a4,s4
    80002212:	bfd9                	j	800021e8 <wait+0xba>
    if(!havekids || p->killed==1){
    80002214:	c709                	beqz	a4,8000221e <wait+0xf0>
    80002216:	02892783          	lw	a5,40(s2)
    8000221a:	03479863          	bne	a5,s4,8000224a <wait+0x11c>
      release(&wait_lock);
    8000221e:	0000f517          	auipc	a0,0xf
    80002222:	09a50513          	addi	a0,a0,154 # 800112b8 <wait_lock>
    80002226:	fffff097          	auipc	ra,0xfffff
    8000222a:	a6a080e7          	jalr	-1430(ra) # 80000c90 <release>
      return -1;
    8000222e:	59fd                	li	s3,-1
}
    80002230:	854e                	mv	a0,s3
    80002232:	60a6                	ld	ra,72(sp)
    80002234:	6406                	ld	s0,64(sp)
    80002236:	74e2                	ld	s1,56(sp)
    80002238:	7942                	ld	s2,48(sp)
    8000223a:	79a2                	ld	s3,40(sp)
    8000223c:	7a02                	ld	s4,32(sp)
    8000223e:	6ae2                	ld	s5,24(sp)
    80002240:	6b42                	ld	s6,16(sp)
    80002242:	6ba2                	ld	s7,8(sp)
    80002244:	6c02                	ld	s8,0(sp)
    80002246:	6161                	addi	sp,sp,80
    80002248:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000224a:	85e2                	mv	a1,s8
    8000224c:	854a                	mv	a0,s2
    8000224e:	00000097          	auipc	ra,0x0
    80002252:	e7c080e7          	jalr	-388(ra) # 800020ca <sleep>
    havekids = 0;
    80002256:	b70d                	j	80002178 <wait+0x4a>

0000000080002258 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002258:	7139                	addi	sp,sp,-64
    8000225a:	fc06                	sd	ra,56(sp)
    8000225c:	f822                	sd	s0,48(sp)
    8000225e:	f426                	sd	s1,40(sp)
    80002260:	f04a                	sd	s2,32(sp)
    80002262:	ec4e                	sd	s3,24(sp)
    80002264:	e852                	sd	s4,16(sp)
    80002266:	e456                	sd	s5,8(sp)
    80002268:	0080                	addi	s0,sp,64
    8000226a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000226c:	0000f497          	auipc	s1,0xf
    80002270:	46448493          	addi	s1,s1,1124 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002274:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002276:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002278:	0001b917          	auipc	s2,0x1b
    8000227c:	65890913          	addi	s2,s2,1624 # 8001d8d0 <tickslock>
    80002280:	a811                	j	80002294 <wakeup+0x3c>
      }
      release(&p->lock);
    80002282:	8526                	mv	a0,s1
    80002284:	fffff097          	auipc	ra,0xfffff
    80002288:	a0c080e7          	jalr	-1524(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000228c:	30848493          	addi	s1,s1,776
    80002290:	03248663          	beq	s1,s2,800022bc <wakeup+0x64>
    if(p != myproc()){
    80002294:	fffff097          	auipc	ra,0xfffff
    80002298:	704080e7          	jalr	1796(ra) # 80001998 <myproc>
    8000229c:	fea488e3          	beq	s1,a0,8000228c <wakeup+0x34>
      acquire(&p->lock);
    800022a0:	8526                	mv	a0,s1
    800022a2:	fffff097          	auipc	ra,0xfffff
    800022a6:	924080e7          	jalr	-1756(ra) # 80000bc6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800022aa:	4c9c                	lw	a5,24(s1)
    800022ac:	fd379be3          	bne	a5,s3,80002282 <wakeup+0x2a>
    800022b0:	709c                	ld	a5,32(s1)
    800022b2:	fd4798e3          	bne	a5,s4,80002282 <wakeup+0x2a>
        p->state = RUNNABLE;
    800022b6:	0154ac23          	sw	s5,24(s1)
    800022ba:	b7e1                	j	80002282 <wakeup+0x2a>
    }
  }
}
    800022bc:	70e2                	ld	ra,56(sp)
    800022be:	7442                	ld	s0,48(sp)
    800022c0:	74a2                	ld	s1,40(sp)
    800022c2:	7902                	ld	s2,32(sp)
    800022c4:	69e2                	ld	s3,24(sp)
    800022c6:	6a42                	ld	s4,16(sp)
    800022c8:	6aa2                	ld	s5,8(sp)
    800022ca:	6121                	addi	sp,sp,64
    800022cc:	8082                	ret

00000000800022ce <reparent>:
{
    800022ce:	7179                	addi	sp,sp,-48
    800022d0:	f406                	sd	ra,40(sp)
    800022d2:	f022                	sd	s0,32(sp)
    800022d4:	ec26                	sd	s1,24(sp)
    800022d6:	e84a                	sd	s2,16(sp)
    800022d8:	e44e                	sd	s3,8(sp)
    800022da:	e052                	sd	s4,0(sp)
    800022dc:	1800                	addi	s0,sp,48
    800022de:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022e0:	0000f497          	auipc	s1,0xf
    800022e4:	3f048493          	addi	s1,s1,1008 # 800116d0 <proc>
      pp->parent = initproc;
    800022e8:	00007a17          	auipc	s4,0x7
    800022ec:	d40a0a13          	addi	s4,s4,-704 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022f0:	0001b997          	auipc	s3,0x1b
    800022f4:	5e098993          	addi	s3,s3,1504 # 8001d8d0 <tickslock>
    800022f8:	a029                	j	80002302 <reparent+0x34>
    800022fa:	30848493          	addi	s1,s1,776
    800022fe:	01348d63          	beq	s1,s3,80002318 <reparent+0x4a>
    if(pp->parent == p){
    80002302:	7c9c                	ld	a5,56(s1)
    80002304:	ff279be3          	bne	a5,s2,800022fa <reparent+0x2c>
      pp->parent = initproc;
    80002308:	000a3503          	ld	a0,0(s4)
    8000230c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000230e:	00000097          	auipc	ra,0x0
    80002312:	f4a080e7          	jalr	-182(ra) # 80002258 <wakeup>
    80002316:	b7d5                	j	800022fa <reparent+0x2c>
}
    80002318:	70a2                	ld	ra,40(sp)
    8000231a:	7402                	ld	s0,32(sp)
    8000231c:	64e2                	ld	s1,24(sp)
    8000231e:	6942                	ld	s2,16(sp)
    80002320:	69a2                	ld	s3,8(sp)
    80002322:	6a02                	ld	s4,0(sp)
    80002324:	6145                	addi	sp,sp,48
    80002326:	8082                	ret

0000000080002328 <exit>:
{
    80002328:	7179                	addi	sp,sp,-48
    8000232a:	f406                	sd	ra,40(sp)
    8000232c:	f022                	sd	s0,32(sp)
    8000232e:	ec26                	sd	s1,24(sp)
    80002330:	e84a                	sd	s2,16(sp)
    80002332:	e44e                	sd	s3,8(sp)
    80002334:	e052                	sd	s4,0(sp)
    80002336:	1800                	addi	s0,sp,48
    80002338:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	65e080e7          	jalr	1630(ra) # 80001998 <myproc>
    80002342:	89aa                	mv	s3,a0
  if(p == initproc)
    80002344:	00007797          	auipc	a5,0x7
    80002348:	ce47b783          	ld	a5,-796(a5) # 80009028 <initproc>
    8000234c:	0d050493          	addi	s1,a0,208
    80002350:	15050913          	addi	s2,a0,336
    80002354:	02a79363          	bne	a5,a0,8000237a <exit+0x52>
    panic("init exiting");
    80002358:	00006517          	auipc	a0,0x6
    8000235c:	f2050513          	addi	a0,a0,-224 # 80008278 <digits+0x238>
    80002360:	ffffe097          	auipc	ra,0xffffe
    80002364:	1ce080e7          	jalr	462(ra) # 8000052e <panic>
      fileclose(f);
    80002368:	00002097          	auipc	ra,0x2
    8000236c:	716080e7          	jalr	1814(ra) # 80004a7e <fileclose>
      p->ofile[fd] = 0;
    80002370:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002374:	04a1                	addi	s1,s1,8
    80002376:	01248563          	beq	s1,s2,80002380 <exit+0x58>
    if(p->ofile[fd]){
    8000237a:	6088                	ld	a0,0(s1)
    8000237c:	f575                	bnez	a0,80002368 <exit+0x40>
    8000237e:	bfdd                	j	80002374 <exit+0x4c>
  begin_op();
    80002380:	00002097          	auipc	ra,0x2
    80002384:	232080e7          	jalr	562(ra) # 800045b2 <begin_op>
  iput(p->cwd);
    80002388:	1509b503          	ld	a0,336(s3)
    8000238c:	00002097          	auipc	ra,0x2
    80002390:	a0a080e7          	jalr	-1526(ra) # 80003d96 <iput>
  end_op();
    80002394:	00002097          	auipc	ra,0x2
    80002398:	29e080e7          	jalr	670(ra) # 80004632 <end_op>
  p->cwd = 0;
    8000239c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800023a0:	0000f497          	auipc	s1,0xf
    800023a4:	f1848493          	addi	s1,s1,-232 # 800112b8 <wait_lock>
    800023a8:	8526                	mv	a0,s1
    800023aa:	fffff097          	auipc	ra,0xfffff
    800023ae:	81c080e7          	jalr	-2020(ra) # 80000bc6 <acquire>
  reparent(p);
    800023b2:	854e                	mv	a0,s3
    800023b4:	00000097          	auipc	ra,0x0
    800023b8:	f1a080e7          	jalr	-230(ra) # 800022ce <reparent>
  wakeup(p->parent);
    800023bc:	0389b503          	ld	a0,56(s3)
    800023c0:	00000097          	auipc	ra,0x0
    800023c4:	e98080e7          	jalr	-360(ra) # 80002258 <wakeup>
  acquire(&p->lock);
    800023c8:	854e                	mv	a0,s3
    800023ca:	ffffe097          	auipc	ra,0xffffe
    800023ce:	7fc080e7          	jalr	2044(ra) # 80000bc6 <acquire>
  p->xstate = status;
    800023d2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800023d6:	4795                	li	a5,5
    800023d8:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800023dc:	8526                	mv	a0,s1
    800023de:	fffff097          	auipc	ra,0xfffff
    800023e2:	8b2080e7          	jalr	-1870(ra) # 80000c90 <release>
  sched();
    800023e6:	00000097          	auipc	ra,0x0
    800023ea:	bd2080e7          	jalr	-1070(ra) # 80001fb8 <sched>
  panic("zombie exit");
    800023ee:	00006517          	auipc	a0,0x6
    800023f2:	e9a50513          	addi	a0,a0,-358 # 80008288 <digits+0x248>
    800023f6:	ffffe097          	auipc	ra,0xffffe
    800023fa:	138080e7          	jalr	312(ra) # 8000052e <panic>

00000000800023fe <kill>:


// new kill sending signal to process pid - task 2.2.1
int
kill(int pid, int signum)
{
    800023fe:	7179                	addi	sp,sp,-48
    80002400:	f406                	sd	ra,40(sp)
    80002402:	f022                	sd	s0,32(sp)
    80002404:	ec26                	sd	s1,24(sp)
    80002406:	e84a                	sd	s2,16(sp)
    80002408:	e44e                	sd	s3,8(sp)
    8000240a:	e052                	sd	s4,0(sp)
    8000240c:	1800                	addi	s0,sp,48
    8000240e:	892a                	mv	s2,a0
    80002410:	8a2e                	mv	s4,a1
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002412:	0000f497          	auipc	s1,0xf
    80002416:	2be48493          	addi	s1,s1,702 # 800116d0 <proc>
    8000241a:	0001b997          	auipc	s3,0x1b
    8000241e:	4b698993          	addi	s3,s3,1206 # 8001d8d0 <tickslock>
    // printf("proc %d try to acquire proc %d\n",myproc()->pid,pid);//TODO delete
    acquire(&p->lock);
    80002422:	8526                	mv	a0,s1
    80002424:	ffffe097          	auipc	ra,0xffffe
    80002428:	7a2080e7          	jalr	1954(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    8000242c:	589c                	lw	a5,48(s1)
    8000242e:	01278d63          	beq	a5,s2,80002448 <kill+0x4a>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002432:	8526                	mv	a0,s1
    80002434:	fffff097          	auipc	ra,0xfffff
    80002438:	85c080e7          	jalr	-1956(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000243c:	30848493          	addi	s1,s1,776
    80002440:	ff3491e3          	bne	s1,s3,80002422 <kill+0x24>
  }
  return -1;
    80002444:	557d                	li	a0,-1
    80002446:	a815                	j	8000247a <kill+0x7c>
      if(p->signal_handlers[signum]!=(void*)SIG_IGN){
    80002448:	02ea0793          	addi	a5,s4,46
    8000244c:	078e                	slli	a5,a5,0x3
    8000244e:	97a6                	add	a5,a5,s1
    80002450:	6798                	ld	a4,8(a5)
    80002452:	4785                	li	a5,1
    80002454:	00f70963          	beq	a4,a5,80002466 <kill+0x68>
        p->pending_signals|= (1<<signum);
    80002458:	0147973b          	sllw	a4,a5,s4
    8000245c:	1684a783          	lw	a5,360(s1)
    80002460:	8fd9                	or	a5,a5,a4
    80002462:	16f4a423          	sw	a5,360(s1)
      if(p->state == SLEEPING && signum == SIGKILL){
    80002466:	4c98                	lw	a4,24(s1)
    80002468:	4789                	li	a5,2
    8000246a:	02f70063          	beq	a4,a5,8000248a <kill+0x8c>
      release(&p->lock);
    8000246e:	8526                	mv	a0,s1
    80002470:	fffff097          	auipc	ra,0xfffff
    80002474:	820080e7          	jalr	-2016(ra) # 80000c90 <release>
      return 0;
    80002478:	4501                	li	a0,0
}
    8000247a:	70a2                	ld	ra,40(sp)
    8000247c:	7402                	ld	s0,32(sp)
    8000247e:	64e2                	ld	s1,24(sp)
    80002480:	6942                	ld	s2,16(sp)
    80002482:	69a2                	ld	s3,8(sp)
    80002484:	6a02                	ld	s4,0(sp)
    80002486:	6145                	addi	sp,sp,48
    80002488:	8082                	ret
      if(p->state == SLEEPING && signum == SIGKILL){
    8000248a:	47a5                	li	a5,9
    8000248c:	fefa11e3          	bne	s4,a5,8000246e <kill+0x70>
        p->state = RUNNABLE;
    80002490:	478d                	li	a5,3
    80002492:	cc9c                	sw	a5,24(s1)
    80002494:	bfe9                	j	8000246e <kill+0x70>

0000000080002496 <sig_stop>:
//   return -1;
// }

int
sig_stop(int pid)//TODO delete if not used
{
    80002496:	7179                	addi	sp,sp,-48
    80002498:	f406                	sd	ra,40(sp)
    8000249a:	f022                	sd	s0,32(sp)
    8000249c:	ec26                	sd	s1,24(sp)
    8000249e:	e84a                	sd	s2,16(sp)
    800024a0:	e44e                	sd	s3,8(sp)
    800024a2:	1800                	addi	s0,sp,48
    800024a4:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800024a6:	0000f497          	auipc	s1,0xf
    800024aa:	22a48493          	addi	s1,s1,554 # 800116d0 <proc>
    800024ae:	0001b997          	auipc	s3,0x1b
    800024b2:	42298993          	addi	s3,s3,1058 # 8001d8d0 <tickslock>
    acquire(&p->lock);
    800024b6:	8526                	mv	a0,s1
    800024b8:	ffffe097          	auipc	ra,0xffffe
    800024bc:	70e080e7          	jalr	1806(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    800024c0:	589c                	lw	a5,48(s1)
    800024c2:	01278d63          	beq	a5,s2,800024dc <sig_stop+0x46>
      p->pending_signals|=(1<<SIGSTOP);

      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024c6:	8526                	mv	a0,s1
    800024c8:	ffffe097          	auipc	ra,0xffffe
    800024cc:	7c8080e7          	jalr	1992(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800024d0:	30848493          	addi	s1,s1,776
    800024d4:	ff3491e3          	bne	s1,s3,800024b6 <sig_stop+0x20>
  }
  return -1;
    800024d8:	557d                	li	a0,-1
    800024da:	a831                	j	800024f6 <sig_stop+0x60>
      p->pending_signals|=(1<<SIGSTOP);
    800024dc:	1684a783          	lw	a5,360(s1)
    800024e0:	00020737          	lui	a4,0x20
    800024e4:	8fd9                	or	a5,a5,a4
    800024e6:	16f4a423          	sw	a5,360(s1)
      release(&p->lock);
    800024ea:	8526                	mv	a0,s1
    800024ec:	ffffe097          	auipc	ra,0xffffe
    800024f0:	7a4080e7          	jalr	1956(ra) # 80000c90 <release>
      return 0;
    800024f4:	4501                	li	a0,0
}
    800024f6:	70a2                	ld	ra,40(sp)
    800024f8:	7402                	ld	s0,32(sp)
    800024fa:	64e2                	ld	s1,24(sp)
    800024fc:	6942                	ld	s2,16(sp)
    800024fe:	69a2                	ld	s3,8(sp)
    80002500:	6145                	addi	sp,sp,48
    80002502:	8082                	ret

0000000080002504 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002504:	7179                	addi	sp,sp,-48
    80002506:	f406                	sd	ra,40(sp)
    80002508:	f022                	sd	s0,32(sp)
    8000250a:	ec26                	sd	s1,24(sp)
    8000250c:	e84a                	sd	s2,16(sp)
    8000250e:	e44e                	sd	s3,8(sp)
    80002510:	e052                	sd	s4,0(sp)
    80002512:	1800                	addi	s0,sp,48
    80002514:	84aa                	mv	s1,a0
    80002516:	892e                	mv	s2,a1
    80002518:	89b2                	mv	s3,a2
    8000251a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	47c080e7          	jalr	1148(ra) # 80001998 <myproc>
  if(user_dst){
    80002524:	c08d                	beqz	s1,80002546 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002526:	86d2                	mv	a3,s4
    80002528:	864e                	mv	a2,s3
    8000252a:	85ca                	mv	a1,s2
    8000252c:	6928                	ld	a0,80(a0)
    8000252e:	fffff097          	auipc	ra,0xfffff
    80002532:	12a080e7          	jalr	298(ra) # 80001658 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002536:	70a2                	ld	ra,40(sp)
    80002538:	7402                	ld	s0,32(sp)
    8000253a:	64e2                	ld	s1,24(sp)
    8000253c:	6942                	ld	s2,16(sp)
    8000253e:	69a2                	ld	s3,8(sp)
    80002540:	6a02                	ld	s4,0(sp)
    80002542:	6145                	addi	sp,sp,48
    80002544:	8082                	ret
    memmove((char *)dst, src, len);
    80002546:	000a061b          	sext.w	a2,s4
    8000254a:	85ce                	mv	a1,s3
    8000254c:	854a                	mv	a0,s2
    8000254e:	ffffe097          	auipc	ra,0xffffe
    80002552:	7e6080e7          	jalr	2022(ra) # 80000d34 <memmove>
    return 0;
    80002556:	8526                	mv	a0,s1
    80002558:	bff9                	j	80002536 <either_copyout+0x32>

000000008000255a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000255a:	7179                	addi	sp,sp,-48
    8000255c:	f406                	sd	ra,40(sp)
    8000255e:	f022                	sd	s0,32(sp)
    80002560:	ec26                	sd	s1,24(sp)
    80002562:	e84a                	sd	s2,16(sp)
    80002564:	e44e                	sd	s3,8(sp)
    80002566:	e052                	sd	s4,0(sp)
    80002568:	1800                	addi	s0,sp,48
    8000256a:	892a                	mv	s2,a0
    8000256c:	84ae                	mv	s1,a1
    8000256e:	89b2                	mv	s3,a2
    80002570:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002572:	fffff097          	auipc	ra,0xfffff
    80002576:	426080e7          	jalr	1062(ra) # 80001998 <myproc>
  if(user_src){
    8000257a:	c08d                	beqz	s1,8000259c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000257c:	86d2                	mv	a3,s4
    8000257e:	864e                	mv	a2,s3
    80002580:	85ca                	mv	a1,s2
    80002582:	6928                	ld	a0,80(a0)
    80002584:	fffff097          	auipc	ra,0xfffff
    80002588:	160080e7          	jalr	352(ra) # 800016e4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000258c:	70a2                	ld	ra,40(sp)
    8000258e:	7402                	ld	s0,32(sp)
    80002590:	64e2                	ld	s1,24(sp)
    80002592:	6942                	ld	s2,16(sp)
    80002594:	69a2                	ld	s3,8(sp)
    80002596:	6a02                	ld	s4,0(sp)
    80002598:	6145                	addi	sp,sp,48
    8000259a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000259c:	000a061b          	sext.w	a2,s4
    800025a0:	85ce                	mv	a1,s3
    800025a2:	854a                	mv	a0,s2
    800025a4:	ffffe097          	auipc	ra,0xffffe
    800025a8:	790080e7          	jalr	1936(ra) # 80000d34 <memmove>
    return 0;
    800025ac:	8526                	mv	a0,s1
    800025ae:	bff9                	j	8000258c <either_copyin+0x32>

00000000800025b0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025b0:	715d                	addi	sp,sp,-80
    800025b2:	e486                	sd	ra,72(sp)
    800025b4:	e0a2                	sd	s0,64(sp)
    800025b6:	fc26                	sd	s1,56(sp)
    800025b8:	f84a                	sd	s2,48(sp)
    800025ba:	f44e                	sd	s3,40(sp)
    800025bc:	f052                	sd	s4,32(sp)
    800025be:	ec56                	sd	s5,24(sp)
    800025c0:	e85a                	sd	s6,16(sp)
    800025c2:	e45e                	sd	s7,8(sp)
    800025c4:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025c6:	00006517          	auipc	a0,0x6
    800025ca:	b3250513          	addi	a0,a0,-1230 # 800080f8 <digits+0xb8>
    800025ce:	ffffe097          	auipc	ra,0xffffe
    800025d2:	faa080e7          	jalr	-86(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025d6:	0000f497          	auipc	s1,0xf
    800025da:	25248493          	addi	s1,s1,594 # 80011828 <proc+0x158>
    800025de:	0001b917          	auipc	s2,0x1b
    800025e2:	44a90913          	addi	s2,s2,1098 # 8001da28 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025e6:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025e8:	00006997          	auipc	s3,0x6
    800025ec:	cb098993          	addi	s3,s3,-848 # 80008298 <digits+0x258>
    printf("%d %s %s", p->pid, state, p->name);
    800025f0:	00006a97          	auipc	s5,0x6
    800025f4:	cb0a8a93          	addi	s5,s5,-848 # 800082a0 <digits+0x260>
    printf("\n");
    800025f8:	00006a17          	auipc	s4,0x6
    800025fc:	b00a0a13          	addi	s4,s4,-1280 # 800080f8 <digits+0xb8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002600:	00006b97          	auipc	s7,0x6
    80002604:	d00b8b93          	addi	s7,s7,-768 # 80008300 <states.0>
    80002608:	a00d                	j	8000262a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000260a:	ed86a583          	lw	a1,-296(a3)
    8000260e:	8556                	mv	a0,s5
    80002610:	ffffe097          	auipc	ra,0xffffe
    80002614:	f68080e7          	jalr	-152(ra) # 80000578 <printf>
    printf("\n");
    80002618:	8552                	mv	a0,s4
    8000261a:	ffffe097          	auipc	ra,0xffffe
    8000261e:	f5e080e7          	jalr	-162(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002622:	30848493          	addi	s1,s1,776
    80002626:	03248263          	beq	s1,s2,8000264a <procdump+0x9a>
    if(p->state == UNUSED)
    8000262a:	86a6                	mv	a3,s1
    8000262c:	ec04a783          	lw	a5,-320(s1)
    80002630:	dbed                	beqz	a5,80002622 <procdump+0x72>
      state = "???";
    80002632:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002634:	fcfb6be3          	bltu	s6,a5,8000260a <procdump+0x5a>
    80002638:	02079713          	slli	a4,a5,0x20
    8000263c:	01d75793          	srli	a5,a4,0x1d
    80002640:	97de                	add	a5,a5,s7
    80002642:	6390                	ld	a2,0(a5)
    80002644:	f279                	bnez	a2,8000260a <procdump+0x5a>
      state = "???";
    80002646:	864e                	mv	a2,s3
    80002648:	b7c9                	j	8000260a <procdump+0x5a>
  }
}
    8000264a:	60a6                	ld	ra,72(sp)
    8000264c:	6406                	ld	s0,64(sp)
    8000264e:	74e2                	ld	s1,56(sp)
    80002650:	7942                	ld	s2,48(sp)
    80002652:	79a2                	ld	s3,40(sp)
    80002654:	7a02                	ld	s4,32(sp)
    80002656:	6ae2                	ld	s5,24(sp)
    80002658:	6b42                	ld	s6,16(sp)
    8000265a:	6ba2                	ld	s7,8(sp)
    8000265c:	6161                	addi	sp,sp,80
    8000265e:	8082                	ret

0000000080002660 <is_valid_sigmask>:

int 
is_valid_sigmask(int sigmask){
    80002660:	1141                	addi	sp,sp,-16
    80002662:	e422                	sd	s0,8(sp)
    80002664:	0800                	addi	s0,sp,16
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002666:	000207b7          	lui	a5,0x20
    8000266a:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    8000266e:	8d7d                	and	a0,a0,a5
    return 0;
  return 1;
}
    80002670:	00153513          	seqz	a0,a0
    80002674:	6422                	ld	s0,8(sp)
    80002676:	0141                	addi	sp,sp,16
    80002678:	8082                	ret

000000008000267a <sigprocmask>:

uint
sigprocmask(uint new_procmask){
    8000267a:	7179                	addi	sp,sp,-48
    8000267c:	f406                	sd	ra,40(sp)
    8000267e:	f022                	sd	s0,32(sp)
    80002680:	ec26                	sd	s1,24(sp)
    80002682:	e84a                	sd	s2,16(sp)
    80002684:	e44e                	sd	s3,8(sp)
    80002686:	1800                	addi	s0,sp,48
    80002688:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000268a:	fffff097          	auipc	ra,0xfffff
    8000268e:	30e080e7          	jalr	782(ra) # 80001998 <myproc>
  if(is_valid_sigmask(new_procmask) == 0)
    80002692:	000207b7          	lui	a5,0x20
    80002696:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    8000269a:	00f977b3          	and	a5,s2,a5
    return -1;
    8000269e:	59fd                	li	s3,-1
  if(is_valid_sigmask(new_procmask) == 0)
    800026a0:	ef99                	bnez	a5,800026be <sigprocmask+0x44>
    800026a2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800026a4:	ffffe097          	auipc	ra,0xffffe
    800026a8:	522080e7          	jalr	1314(ra) # 80000bc6 <acquire>
  int old_procmask = p->signal_mask;
    800026ac:	16c4a983          	lw	s3,364(s1)
  p->signal_mask = new_procmask;
    800026b0:	1724a623          	sw	s2,364(s1)
  release(&p->lock);
    800026b4:	8526                	mv	a0,s1
    800026b6:	ffffe097          	auipc	ra,0xffffe
    800026ba:	5da080e7          	jalr	1498(ra) # 80000c90 <release>
  
  return old_procmask;
}
    800026be:	854e                	mv	a0,s3
    800026c0:	70a2                	ld	ra,40(sp)
    800026c2:	7402                	ld	s0,32(sp)
    800026c4:	64e2                	ld	s1,24(sp)
    800026c6:	6942                	ld	s2,16(sp)
    800026c8:	69a2                	ld	s3,8(sp)
    800026ca:	6145                	addi	sp,sp,48
    800026cc:	8082                	ret

00000000800026ce <sigaction>:

 
int 
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    800026ce:	0005079b          	sext.w	a5,a0
    800026d2:	477d                	li	a4,31
    800026d4:	0ef76e63          	bltu	a4,a5,800027d0 <sigaction+0x102>
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
    800026d8:	7139                	addi	sp,sp,-64
    800026da:	fc06                	sd	ra,56(sp)
    800026dc:	f822                	sd	s0,48(sp)
    800026de:	f426                	sd	s1,40(sp)
    800026e0:	f04a                	sd	s2,32(sp)
    800026e2:	ec4e                	sd	s3,24(sp)
    800026e4:	e852                	sd	s4,16(sp)
    800026e6:	0080                	addi	s0,sp,64
    800026e8:	892a                	mv	s2,a0
    800026ea:	89ae                	mv	s3,a1
    800026ec:	8a32                	mv	s4,a2
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    800026ee:	37dd                	addiw	a5,a5,-9
    800026f0:	9bdd                	andi	a5,a5,-9
    800026f2:	2781                	sext.w	a5,a5
    800026f4:	c3e5                	beqz	a5,800027d4 <sigaction+0x106>
    800026f6:	c1ed                	beqz	a1,800027d8 <sigaction+0x10a>
    return -1;
  struct proc *p = myproc();
    800026f8:	fffff097          	auipc	ra,0xfffff
    800026fc:	2a0080e7          	jalr	672(ra) # 80001998 <myproc>
    80002700:	84aa                	mv	s1,a0
  uint new_mask;
  copyin(p->pagetable, (char *)&new_mask, (uint64)&act->sigmask, sizeof(act->sigmask));
    80002702:	4691                	li	a3,4
    80002704:	00898613          	addi	a2,s3,8
    80002708:	fcc40593          	addi	a1,s0,-52
    8000270c:	6928                	ld	a0,80(a0)
    8000270e:	fffff097          	auipc	ra,0xfffff
    80002712:	fd6080e7          	jalr	-42(ra) # 800016e4 <copyin>
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002716:	fcc42703          	lw	a4,-52(s0)
  if(is_valid_sigmask(new_mask) == 0)
    8000271a:	000207b7          	lui	a5,0x20
    8000271e:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002722:	8ff9                	and	a5,a5,a4
    80002724:	efc5                	bnez	a5,800027dc <sigaction+0x10e>
    return -1;
  acquire(&p->lock);
    80002726:	8526                	mv	a0,s1
    80002728:	ffffe097          	auipc	ra,0xffffe
    8000272c:	49e080e7          	jalr	1182(ra) # 80000bc6 <acquire>
  if(oldact!=0){
    80002730:	020a0963          	beqz	s4,80002762 <sigaction+0x94>
    copyout(p->pagetable, (uint64)&oldact->sa_handler, (char *)&p->signal_handlers[signum], sizeof(void*));
    80002734:	02f90613          	addi	a2,s2,47
    80002738:	060e                	slli	a2,a2,0x3
    8000273a:	46a1                	li	a3,8
    8000273c:	9626                	add	a2,a2,s1
    8000273e:	85d2                	mv	a1,s4
    80002740:	68a8                	ld	a0,80(s1)
    80002742:	fffff097          	auipc	ra,0xfffff
    80002746:	f16080e7          	jalr	-234(ra) # 80001658 <copyout>
    copyout(p->pagetable, (uint64)&oldact->sigmask, (char *)&p->handlers_sigmasks[signum], sizeof(uint));
    8000274a:	09e90613          	addi	a2,s2,158
    8000274e:	060a                	slli	a2,a2,0x2
    80002750:	4691                	li	a3,4
    80002752:	9626                	add	a2,a2,s1
    80002754:	008a0593          	addi	a1,s4,8
    80002758:	68a8                	ld	a0,80(s1)
    8000275a:	fffff097          	auipc	ra,0xfffff
    8000275e:	efe080e7          	jalr	-258(ra) # 80001658 <copyout>
  }
  copyin(p->pagetable, (char *)&p->signal_handlers[signum], (uint64)&act->sa_handler, sizeof(act->sa_handler));
    80002762:	02f90593          	addi	a1,s2,47
    80002766:	058e                	slli	a1,a1,0x3
    80002768:	46a1                	li	a3,8
    8000276a:	864e                	mv	a2,s3
    8000276c:	95a6                	add	a1,a1,s1
    8000276e:	68a8                	ld	a0,80(s1)
    80002770:	fffff097          	auipc	ra,0xfffff
    80002774:	f74080e7          	jalr	-140(ra) # 800016e4 <copyin>
  p->handlers_sigmasks[signum]=new_mask;
    80002778:	00291993          	slli	s3,s2,0x2
    8000277c:	99a6                	add	s3,s3,s1
    8000277e:	fcc42783          	lw	a5,-52(s0)
    80002782:	26f9ac23          	sw	a5,632(s3)
  release(&p->lock);
    80002786:	8526                	mv	a0,s1
    80002788:	ffffe097          	auipc	ra,0xffffe
    8000278c:	508080e7          	jalr	1288(ra) # 80000c90 <release>

  printf("handler address %p = \n",p->signal_handlers[signum]);
    80002790:	02e90913          	addi	s2,s2,46
    80002794:	090e                	slli	s2,s2,0x3
    80002796:	94ca                	add	s1,s1,s2
    80002798:	648c                	ld	a1,8(s1)
    8000279a:	00006517          	auipc	a0,0x6
    8000279e:	b1650513          	addi	a0,a0,-1258 # 800082b0 <digits+0x270>
    800027a2:	ffffe097          	auipc	ra,0xffffe
    800027a6:	dd6080e7          	jalr	-554(ra) # 80000578 <printf>
  printf("h_mask %d  \n",p->handlers_sigmasks[signum]);
    800027aa:	2789a583          	lw	a1,632(s3)
    800027ae:	00006517          	auipc	a0,0x6
    800027b2:	b1a50513          	addi	a0,a0,-1254 # 800082c8 <digits+0x288>
    800027b6:	ffffe097          	auipc	ra,0xffffe
    800027ba:	dc2080e7          	jalr	-574(ra) # 80000578 <printf>

  return 0;
    800027be:	4501                	li	a0,0
}
    800027c0:	70e2                	ld	ra,56(sp)
    800027c2:	7442                	ld	s0,48(sp)
    800027c4:	74a2                	ld	s1,40(sp)
    800027c6:	7902                	ld	s2,32(sp)
    800027c8:	69e2                	ld	s3,24(sp)
    800027ca:	6a42                	ld	s4,16(sp)
    800027cc:	6121                	addi	sp,sp,64
    800027ce:	8082                	ret
    return -1;
    800027d0:	557d                	li	a0,-1
}
    800027d2:	8082                	ret
    return -1;
    800027d4:	557d                	li	a0,-1
    800027d6:	b7ed                	j	800027c0 <sigaction+0xf2>
    800027d8:	557d                	li	a0,-1
    800027da:	b7dd                	j	800027c0 <sigaction+0xf2>
    return -1;
    800027dc:	557d                	li	a0,-1
    800027de:	b7cd                	j	800027c0 <sigaction+0xf2>

00000000800027e0 <sigret>:

void 
sigret(void){
    800027e0:	1101                	addi	sp,sp,-32
    800027e2:	ec06                	sd	ra,24(sp)
    800027e4:	e822                	sd	s0,16(sp)
    800027e6:	e426                	sd	s1,8(sp)
    800027e8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800027ea:	fffff097          	auipc	ra,0xfffff
    800027ee:	1ae080e7          	jalr	430(ra) # 80001998 <myproc>
    800027f2:	84aa                	mv	s1,a0
  copyin(p->pagetable, (char *)p->trapframe, (uint64)p->user_trapframe_backup, sizeof(struct trapframe));
    800027f4:	12000693          	li	a3,288
    800027f8:	2f853603          	ld	a2,760(a0)
    800027fc:	6d2c                	ld	a1,88(a0)
    800027fe:	6928                	ld	a0,80(a0)
    80002800:	fffff097          	auipc	ra,0xfffff
    80002804:	ee4080e7          	jalr	-284(ra) # 800016e4 <copyin>
 
  // restore user stack pointer
  p->trapframe->sp += sizeof(struct trapframe);
    80002808:	6cb8                	ld	a4,88(s1)
    8000280a:	7b1c                	ld	a5,48(a4)
    8000280c:	12078793          	addi	a5,a5,288
    80002810:	fb1c                	sd	a5,48(a4)

  p->signal_mask = p->signal_mask_backup;
    80002812:	1704a783          	lw	a5,368(s1)
    80002816:	16f4a623          	sw	a5,364(s1)
  
  // allow user signal handler since we finished handling the current

  p->handling_user_sig_flag = 0;
    8000281a:	3004a223          	sw	zero,772(s1)

}
    8000281e:	60e2                	ld	ra,24(sp)
    80002820:	6442                	ld	s0,16(sp)
    80002822:	64a2                	ld	s1,8(sp)
    80002824:	6105                	addi	sp,sp,32
    80002826:	8082                	ret

0000000080002828 <turn_on_bit>:

void
turn_on_bit(struct proc* p, int signum){
    80002828:	1141                	addi	sp,sp,-16
    8000282a:	e422                	sd	s0,8(sp)
    8000282c:	0800                	addi	s0,sp,16
  if(!p->pending_signals & (1 << signum))
    8000282e:	16852703          	lw	a4,360(a0)
    80002832:	00173793          	seqz	a5,a4
    80002836:	40b7d7bb          	sraw	a5,a5,a1
    8000283a:	8b85                	andi	a5,a5,1
    8000283c:	c799                	beqz	a5,8000284a <turn_on_bit+0x22>
    p->pending_signals ^= (1 << signum);  
    8000283e:	4785                	li	a5,1
    80002840:	00b795bb          	sllw	a1,a5,a1
    80002844:	8f2d                	xor	a4,a4,a1
    80002846:	16e52423          	sw	a4,360(a0)
}
    8000284a:	6422                	ld	s0,8(sp)
    8000284c:	0141                	addi	sp,sp,16
    8000284e:	8082                	ret

0000000080002850 <turn_off_bit>:

void
turn_off_bit(struct proc* p, int signum){
    80002850:	1141                	addi	sp,sp,-16
    80002852:	e422                	sd	s0,8(sp)
    80002854:	0800                	addi	s0,sp,16
  if(p->pending_signals & (1 << signum))
    80002856:	16852703          	lw	a4,360(a0)
    8000285a:	4785                	li	a5,1
    8000285c:	00b795bb          	sllw	a1,a5,a1
    80002860:	00b777b3          	and	a5,a4,a1
    80002864:	2781                	sext.w	a5,a5
    80002866:	c781                	beqz	a5,8000286e <turn_off_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    80002868:	8db9                	xor	a1,a1,a4
    8000286a:	16b52423          	sw	a1,360(a0)
}
    8000286e:	6422                	ld	s0,8(sp)
    80002870:	0141                	addi	sp,sp,16
    80002872:	8082                	ret

0000000080002874 <swtch>:
    80002874:	00153023          	sd	ra,0(a0)
    80002878:	00253423          	sd	sp,8(a0)
    8000287c:	e900                	sd	s0,16(a0)
    8000287e:	ed04                	sd	s1,24(a0)
    80002880:	03253023          	sd	s2,32(a0)
    80002884:	03353423          	sd	s3,40(a0)
    80002888:	03453823          	sd	s4,48(a0)
    8000288c:	03553c23          	sd	s5,56(a0)
    80002890:	05653023          	sd	s6,64(a0)
    80002894:	05753423          	sd	s7,72(a0)
    80002898:	05853823          	sd	s8,80(a0)
    8000289c:	05953c23          	sd	s9,88(a0)
    800028a0:	07a53023          	sd	s10,96(a0)
    800028a4:	07b53423          	sd	s11,104(a0)
    800028a8:	0005b083          	ld	ra,0(a1)
    800028ac:	0085b103          	ld	sp,8(a1)
    800028b0:	6980                	ld	s0,16(a1)
    800028b2:	6d84                	ld	s1,24(a1)
    800028b4:	0205b903          	ld	s2,32(a1)
    800028b8:	0285b983          	ld	s3,40(a1)
    800028bc:	0305ba03          	ld	s4,48(a1)
    800028c0:	0385ba83          	ld	s5,56(a1)
    800028c4:	0405bb03          	ld	s6,64(a1)
    800028c8:	0485bb83          	ld	s7,72(a1)
    800028cc:	0505bc03          	ld	s8,80(a1)
    800028d0:	0585bc83          	ld	s9,88(a1)
    800028d4:	0605bd03          	ld	s10,96(a1)
    800028d8:	0685bd83          	ld	s11,104(a1)
    800028dc:	8082                	ret

00000000800028de <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028de:	1141                	addi	sp,sp,-16
    800028e0:	e406                	sd	ra,8(sp)
    800028e2:	e022                	sd	s0,0(sp)
    800028e4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028e6:	00006597          	auipc	a1,0x6
    800028ea:	a4a58593          	addi	a1,a1,-1462 # 80008330 <states.0+0x30>
    800028ee:	0001b517          	auipc	a0,0x1b
    800028f2:	fe250513          	addi	a0,a0,-30 # 8001d8d0 <tickslock>
    800028f6:	ffffe097          	auipc	ra,0xffffe
    800028fa:	240080e7          	jalr	576(ra) # 80000b36 <initlock>
}
    800028fe:	60a2                	ld	ra,8(sp)
    80002900:	6402                	ld	s0,0(sp)
    80002902:	0141                	addi	sp,sp,16
    80002904:	8082                	ret

0000000080002906 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002906:	1141                	addi	sp,sp,-16
    80002908:	e422                	sd	s0,8(sp)
    8000290a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000290c:	00003797          	auipc	a5,0x3
    80002910:	7d478793          	addi	a5,a5,2004 # 800060e0 <kernelvec>
    80002914:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002918:	6422                	ld	s0,8(sp)
    8000291a:	0141                	addi	sp,sp,16
    8000291c:	8082                	ret

000000008000291e <handle_stop>:


  usertrapret();
}
void
handle_stop(struct proc* p){
    8000291e:	1101                	addi	sp,sp,-32
    80002920:	ec06                	sd	ra,24(sp)
    80002922:	e822                	sd	s0,16(sp)
    80002924:	e426                	sd	s1,8(sp)
    80002926:	e04a                	sd	s2,0(sp)
    80002928:	1000                	addi	s0,sp,32
    8000292a:	84aa                	mv	s1,a0
  p->frozen=1;
    8000292c:	4785                	li	a5,1
    8000292e:	30f52023          	sw	a5,768(a0)
  while ((p->pending_signals&1<<SIGCONT)==0)
    80002932:	16852783          	lw	a5,360(a0)
    80002936:	00080737          	lui	a4,0x80
    8000293a:	8ff9                	and	a5,a5,a4
    8000293c:	ef89                	bnez	a5,80002956 <handle_stop+0x38>
    8000293e:	00080937          	lui	s2,0x80
  {
    // printf("in handle stop, yielding pid=%d \n",p->pid);//TODO delete
    yield();
    80002942:	fffff097          	auipc	ra,0xfffff
    80002946:	74c080e7          	jalr	1868(ra) # 8000208e <yield>
  while ((p->pending_signals&1<<SIGCONT)==0)
    8000294a:	1684a783          	lw	a5,360(s1)
    8000294e:	0127f7b3          	and	a5,a5,s2
    80002952:	2781                	sext.w	a5,a5
    80002954:	d7fd                	beqz	a5,80002942 <handle_stop+0x24>
  }  
  p->frozen=0;
    80002956:	3004a023          	sw	zero,768(s1)
}
    8000295a:	60e2                	ld	ra,24(sp)
    8000295c:	6442                	ld	s0,16(sp)
    8000295e:	64a2                	ld	s1,8(sp)
    80002960:	6902                	ld	s2,0(sp)
    80002962:	6105                	addi	sp,sp,32
    80002964:	8082                	ret

0000000080002966 <handle_user_signal>:
      turn_off_bit(p, sig_num);            
    }
  }
}
void 
handle_user_signal(struct proc* p, int signum){
    80002966:	1101                	addi	sp,sp,-32
    80002968:	ec06                	sd	ra,24(sp)
    8000296a:	e822                	sd	s0,16(sp)
    8000296c:	e426                	sd	s1,8(sp)
    8000296e:	e04a                	sd	s2,0(sp)
    80002970:	1000                	addi	s0,sp,32
    80002972:	84aa                	mv	s1,a0
    80002974:	892e                	mv	s2,a1
 
  p->handling_user_sig_flag = 1;
    80002976:	4785                	li	a5,1
    80002978:	30f52223          	sw	a5,772(a0)

  //backup mask, and change the process mask to handler mask 
  p->signal_mask_backup = p->signal_mask;
    8000297c:	16c52783          	lw	a5,364(a0)
    80002980:	16f52823          	sw	a5,368(a0)
  p->signal_mask= p->handlers_sigmasks[signum];
    80002984:	09c58793          	addi	a5,a1,156
    80002988:	078a                	slli	a5,a5,0x2
    8000298a:	97aa                	add	a5,a5,a0
    8000298c:	479c                	lw	a5,8(a5)
    8000298e:	16f52623          	sw	a5,364(a0)
  
  //copy current trapframe into the user stack for later use
  p->trapframe->sp -= sizeof(struct trapframe);
    80002992:	6d38                	ld	a4,88(a0)
    80002994:	7b1c                	ld	a5,48(a4)
    80002996:	ee078793          	addi	a5,a5,-288
    8000299a:	fb1c                	sd	a5,48(a4)
  p->user_trapframe_backup = (struct trapframe* )(p->trapframe->sp);
    8000299c:	6d2c                	ld	a1,88(a0)
    8000299e:	799c                	ld	a5,48(a1)
    800029a0:	2ef53c23          	sd	a5,760(a0)
  copyout(p->pagetable, (uint64)p->trapframe, (char *)p->trapframe, sizeof(struct trapframe));
    800029a4:	12000693          	li	a3,288
    800029a8:	862e                	mv	a2,a1
    800029aa:	6928                	ld	a0,80(a0)
    800029ac:	fffff097          	auipc	ra,0xfffff
    800029b0:	cac080e7          	jalr	-852(ra) # 80001658 <copyout>

  // inject the call to sigret to user stack
  uint64 size = (uint64)&end_sigret - (uint64)&call_sigret;
    800029b4:	00004697          	auipc	a3,0x4
    800029b8:	dbc68693          	addi	a3,a3,-580 # 80006770 <end_sigret>
    800029bc:	00004617          	auipc	a2,0x4
    800029c0:	dac60613          	addi	a2,a2,-596 # 80006768 <call_sigret>
  p->trapframe->sp -= size;
    800029c4:	6cb8                	ld	a4,88(s1)
    800029c6:	40d605b3          	sub	a1,a2,a3
    800029ca:	7b1c                	ld	a5,48(a4)
    800029cc:	97ae                	add	a5,a5,a1
    800029ce:	fb1c                	sd	a5,48(a4)
  copyout(p->pagetable, (uint64)p->trapframe->sp, (char *)&call_sigret, size);
    800029d0:	6cbc                	ld	a5,88(s1)
    800029d2:	8e91                	sub	a3,a3,a2
    800029d4:	7b8c                	ld	a1,48(a5)
    800029d6:	68a8                	ld	a0,80(s1)
    800029d8:	fffff097          	auipc	ra,0xfffff
    800029dc:	c80080e7          	jalr	-896(ra) # 80001658 <copyout>
 
  // arg0 = signum
  p->trapframe->a0 = signum;
    800029e0:	6cbc                	ld	a5,88(s1)
    800029e2:	0727b823          	sd	s2,112(a5)
  
  // user return address from the user handler will be th .asm code on the user stack
  p->trapframe->ra = p->trapframe->sp;
    800029e6:	6cbc                	ld	a5,88(s1)
    800029e8:	7b98                	ld	a4,48(a5)
    800029ea:	f798                	sd	a4,40(a5)
    
  // Change user program counter to point at the signal handler
  p->trapframe->epc = (uint64)p->signal_handlers[signum];
    800029ec:	6cb8                	ld	a4,88(s1)
    800029ee:	02e90793          	addi	a5,s2,46 # 8002e <_entry-0x7ff7ffd2>
    800029f2:	078e                	slli	a5,a5,0x3
    800029f4:	97a6                	add	a5,a5,s1
    800029f6:	679c                	ld	a5,8(a5)
    800029f8:	ef1c                	sd	a5,24(a4)
  
  //turn off pending signal
  turn_off_bit(p, signum);
    800029fa:	85ca                	mv	a1,s2
    800029fc:	8526                	mv	a0,s1
    800029fe:	00000097          	auipc	ra,0x0
    80002a02:	e52080e7          	jalr	-430(ra) # 80002850 <turn_off_bit>
}
    80002a06:	60e2                	ld	ra,24(sp)
    80002a08:	6442                	ld	s0,16(sp)
    80002a0a:	64a2                	ld	s1,8(sp)
    80002a0c:	6902                	ld	s2,0(sp)
    80002a0e:	6105                	addi	sp,sp,32
    80002a10:	8082                	ret

0000000080002a12 <check_pending_signals>:
check_pending_signals(struct proc* p){
    80002a12:	7159                	addi	sp,sp,-112
    80002a14:	f486                	sd	ra,104(sp)
    80002a16:	f0a2                	sd	s0,96(sp)
    80002a18:	eca6                	sd	s1,88(sp)
    80002a1a:	e8ca                	sd	s2,80(sp)
    80002a1c:	e4ce                	sd	s3,72(sp)
    80002a1e:	e0d2                	sd	s4,64(sp)
    80002a20:	fc56                	sd	s5,56(sp)
    80002a22:	f85a                	sd	s6,48(sp)
    80002a24:	f45e                	sd	s7,40(sp)
    80002a26:	f062                	sd	s8,32(sp)
    80002a28:	ec66                	sd	s9,24(sp)
    80002a2a:	e86a                	sd	s10,16(sp)
    80002a2c:	e46e                	sd	s11,8(sp)
    80002a2e:	1880                	addi	s0,sp,112
    80002a30:	89aa                	mv	s3,a0
  for(int sig_num=0;sig_num<32;sig_num++){
    80002a32:	17850913          	addi	s2,a0,376
    80002a36:	4481                	li	s1,0
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    80002a38:	4a05                	li	s4,1
      printf("at pending pid=%d signum=%d\n",p->pid,sig_num);
    80002a3a:	00006b17          	auipc	s6,0x6
    80002a3e:	8feb0b13          	addi	s6,s6,-1794 # 80008338 <states.0+0x38>
      else if(act.sa_handler==(void*)SIGKILL){
    80002a42:	4ba5                	li	s7,9
      }else if(act.sa_handler==(void*)SIGSTOP){
    80002a44:	4cc5                	li	s9,17
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    80002a46:	4c05                	li	s8,1
        printf("didnt ignore sig_num=%d\n",sig_num);
    80002a48:	00006d97          	auipc	s11,0x6
    80002a4c:	910d8d93          	addi	s11,s11,-1776 # 80008358 <states.0+0x58>
        switch (sig_num)
    80002a50:	4d4d                	li	s10,19
  for(int sig_num=0;sig_num<32;sig_num++){
    80002a52:	02000a93          	li	s5,32
    80002a56:	a8a9                	j	80002ab0 <check_pending_signals+0x9e>
        printf("didnt ignore sig_num=%d\n",sig_num);
    80002a58:	85a6                	mv	a1,s1
    80002a5a:	856e                	mv	a0,s11
    80002a5c:	ffffe097          	auipc	ra,0xffffe
    80002a60:	b1c080e7          	jalr	-1252(ra) # 80000578 <printf>
        switch (sig_num)
    80002a64:	03948163          	beq	s1,s9,80002a86 <check_pending_signals+0x74>
    80002a68:	03a48563          	beq	s1,s10,80002a92 <check_pending_signals+0x80>
              acquire(&p->lock);
    80002a6c:	854e                	mv	a0,s3
    80002a6e:	ffffe097          	auipc	ra,0xffffe
    80002a72:	158080e7          	jalr	344(ra) # 80000bc6 <acquire>
              p->killed = 1;
    80002a76:	0389a423          	sw	s8,40(s3)
              release(&p->lock);
    80002a7a:	854e                	mv	a0,s3
    80002a7c:	ffffe097          	auipc	ra,0xffffe
    80002a80:	214080e7          	jalr	532(ra) # 80000c90 <release>
    80002a84:	a821                	j	80002a9c <check_pending_signals+0x8a>
              handle_stop(p);
    80002a86:	854e                	mv	a0,s3
    80002a88:	00000097          	auipc	ra,0x0
    80002a8c:	e96080e7          	jalr	-362(ra) # 8000291e <handle_stop>
            break;
    80002a90:	a031                	j	80002a9c <check_pending_signals+0x8a>
            p->frozen = 0;
    80002a92:	3009a023          	sw	zero,768(s3)
            break;
    80002a96:	a019                	j	80002a9c <check_pending_signals+0x8a>
        p->killed=1;
    80002a98:	0389a423          	sw	s8,40(s3)
      turn_off_bit(p, sig_num);            
    80002a9c:	85a6                	mv	a1,s1
    80002a9e:	854e                	mv	a0,s3
    80002aa0:	00000097          	auipc	ra,0x0
    80002aa4:	db0080e7          	jalr	-592(ra) # 80002850 <turn_off_bit>
  for(int sig_num=0;sig_num<32;sig_num++){
    80002aa8:	2485                	addiw	s1,s1,1
    80002aaa:	0921                	addi	s2,s2,8
    80002aac:	07548263          	beq	s1,s5,80002b10 <check_pending_signals+0xfe>
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    80002ab0:	009a173b          	sllw	a4,s4,s1
    80002ab4:	1689a783          	lw	a5,360(s3)
    80002ab8:	8ff9                	and	a5,a5,a4
    80002aba:	2781                	sext.w	a5,a5
    80002abc:	d7f5                	beqz	a5,80002aa8 <check_pending_signals+0x96>
    80002abe:	16c9a783          	lw	a5,364(s3)
    80002ac2:	8ff9                	and	a5,a5,a4
    80002ac4:	2781                	sext.w	a5,a5
    80002ac6:	f3ed                	bnez	a5,80002aa8 <check_pending_signals+0x96>
      printf("at pending pid=%d signum=%d\n",p->pid,sig_num);
    80002ac8:	8626                	mv	a2,s1
    80002aca:	0309a583          	lw	a1,48(s3)
    80002ace:	855a                	mv	a0,s6
    80002ad0:	ffffe097          	auipc	ra,0xffffe
    80002ad4:	aa8080e7          	jalr	-1368(ra) # 80000578 <printf>
      act.sa_handler = p->signal_handlers[sig_num];
    80002ad8:	00093783          	ld	a5,0(s2)
      if(act.sa_handler == (void*)SIG_DFL){
    80002adc:	dfb5                	beqz	a5,80002a58 <check_pending_signals+0x46>
      else if(act.sa_handler==(void*)SIGKILL){
    80002ade:	fb778de3          	beq	a5,s7,80002a98 <check_pending_signals+0x86>
      }else if(act.sa_handler==(void*)SIGSTOP){
    80002ae2:	05978663          	beq	a5,s9,80002b2e <check_pending_signals+0x11c>
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    80002ae6:	fb878be3          	beq	a5,s8,80002a9c <check_pending_signals+0x8a>
    80002aea:	3049a783          	lw	a5,772(s3)
    80002aee:	f7dd                	bnez	a5,80002a9c <check_pending_signals+0x8a>
        printf("at user signal handler pid=%d\n",p->pid);
    80002af0:	0309a583          	lw	a1,48(s3)
    80002af4:	00006517          	auipc	a0,0x6
    80002af8:	88450513          	addi	a0,a0,-1916 # 80008378 <states.0+0x78>
    80002afc:	ffffe097          	auipc	ra,0xffffe
    80002b00:	a7c080e7          	jalr	-1412(ra) # 80000578 <printf>
        handle_user_signal(p, sig_num);
    80002b04:	85a6                	mv	a1,s1
    80002b06:	854e                	mv	a0,s3
    80002b08:	00000097          	auipc	ra,0x0
    80002b0c:	e5e080e7          	jalr	-418(ra) # 80002966 <handle_user_signal>
}
    80002b10:	70a6                	ld	ra,104(sp)
    80002b12:	7406                	ld	s0,96(sp)
    80002b14:	64e6                	ld	s1,88(sp)
    80002b16:	6946                	ld	s2,80(sp)
    80002b18:	69a6                	ld	s3,72(sp)
    80002b1a:	6a06                	ld	s4,64(sp)
    80002b1c:	7ae2                	ld	s5,56(sp)
    80002b1e:	7b42                	ld	s6,48(sp)
    80002b20:	7ba2                	ld	s7,40(sp)
    80002b22:	7c02                	ld	s8,32(sp)
    80002b24:	6ce2                	ld	s9,24(sp)
    80002b26:	6d42                	ld	s10,16(sp)
    80002b28:	6da2                	ld	s11,8(sp)
    80002b2a:	6165                	addi	sp,sp,112
    80002b2c:	8082                	ret
        handle_stop(p);
    80002b2e:	854e                	mv	a0,s3
    80002b30:	00000097          	auipc	ra,0x0
    80002b34:	dee080e7          	jalr	-530(ra) # 8000291e <handle_stop>
    80002b38:	b795                	j	80002a9c <check_pending_signals+0x8a>

0000000080002b3a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002b3a:	1141                	addi	sp,sp,-16
    80002b3c:	e406                	sd	ra,8(sp)
    80002b3e:	e022                	sd	s0,0(sp)
    80002b40:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b42:	fffff097          	auipc	ra,0xfffff
    80002b46:	e56080e7          	jalr	-426(ra) # 80001998 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b4a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b4e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b50:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002b54:	00004617          	auipc	a2,0x4
    80002b58:	4ac60613          	addi	a2,a2,1196 # 80007000 <_trampoline>
    80002b5c:	00004697          	auipc	a3,0x4
    80002b60:	4a468693          	addi	a3,a3,1188 # 80007000 <_trampoline>
    80002b64:	8e91                	sub	a3,a3,a2
    80002b66:	040007b7          	lui	a5,0x4000
    80002b6a:	17fd                	addi	a5,a5,-1
    80002b6c:	07b2                	slli	a5,a5,0xc
    80002b6e:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b70:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b74:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b76:	180026f3          	csrr	a3,satp
    80002b7a:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b7c:	6d38                	ld	a4,88(a0)
    80002b7e:	6134                	ld	a3,64(a0)
    80002b80:	6585                	lui	a1,0x1
    80002b82:	96ae                	add	a3,a3,a1
    80002b84:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b86:	6d38                	ld	a4,88(a0)
    80002b88:	00000697          	auipc	a3,0x0
    80002b8c:	13868693          	addi	a3,a3,312 # 80002cc0 <usertrap>
    80002b90:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b92:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b94:	8692                	mv	a3,tp
    80002b96:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b98:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b9c:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002ba0:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ba4:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002ba8:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002baa:	6f18                	ld	a4,24(a4)
    80002bac:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002bb0:	692c                	ld	a1,80(a0)
    80002bb2:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002bb4:	00004717          	auipc	a4,0x4
    80002bb8:	4dc70713          	addi	a4,a4,1244 # 80007090 <userret>
    80002bbc:	8f11                	sub	a4,a4,a2
    80002bbe:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002bc0:	577d                	li	a4,-1
    80002bc2:	177e                	slli	a4,a4,0x3f
    80002bc4:	8dd9                	or	a1,a1,a4
    80002bc6:	02000537          	lui	a0,0x2000
    80002bca:	157d                	addi	a0,a0,-1
    80002bcc:	0536                	slli	a0,a0,0xd
    80002bce:	9782                	jalr	a5
}
    80002bd0:	60a2                	ld	ra,8(sp)
    80002bd2:	6402                	ld	s0,0(sp)
    80002bd4:	0141                	addi	sp,sp,16
    80002bd6:	8082                	ret

0000000080002bd8 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002bd8:	1101                	addi	sp,sp,-32
    80002bda:	ec06                	sd	ra,24(sp)
    80002bdc:	e822                	sd	s0,16(sp)
    80002bde:	e426                	sd	s1,8(sp)
    80002be0:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002be2:	0001b497          	auipc	s1,0x1b
    80002be6:	cee48493          	addi	s1,s1,-786 # 8001d8d0 <tickslock>
    80002bea:	8526                	mv	a0,s1
    80002bec:	ffffe097          	auipc	ra,0xffffe
    80002bf0:	fda080e7          	jalr	-38(ra) # 80000bc6 <acquire>
  ticks++;
    80002bf4:	00006517          	auipc	a0,0x6
    80002bf8:	43c50513          	addi	a0,a0,1084 # 80009030 <ticks>
    80002bfc:	411c                	lw	a5,0(a0)
    80002bfe:	2785                	addiw	a5,a5,1
    80002c00:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002c02:	fffff097          	auipc	ra,0xfffff
    80002c06:	656080e7          	jalr	1622(ra) # 80002258 <wakeup>
  release(&tickslock);
    80002c0a:	8526                	mv	a0,s1
    80002c0c:	ffffe097          	auipc	ra,0xffffe
    80002c10:	084080e7          	jalr	132(ra) # 80000c90 <release>
}
    80002c14:	60e2                	ld	ra,24(sp)
    80002c16:	6442                	ld	s0,16(sp)
    80002c18:	64a2                	ld	s1,8(sp)
    80002c1a:	6105                	addi	sp,sp,32
    80002c1c:	8082                	ret

0000000080002c1e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002c1e:	1101                	addi	sp,sp,-32
    80002c20:	ec06                	sd	ra,24(sp)
    80002c22:	e822                	sd	s0,16(sp)
    80002c24:	e426                	sd	s1,8(sp)
    80002c26:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c28:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002c2c:	00074d63          	bltz	a4,80002c46 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002c30:	57fd                	li	a5,-1
    80002c32:	17fe                	slli	a5,a5,0x3f
    80002c34:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002c36:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002c38:	06f70363          	beq	a4,a5,80002c9e <devintr+0x80>
  }
}
    80002c3c:	60e2                	ld	ra,24(sp)
    80002c3e:	6442                	ld	s0,16(sp)
    80002c40:	64a2                	ld	s1,8(sp)
    80002c42:	6105                	addi	sp,sp,32
    80002c44:	8082                	ret
     (scause & 0xff) == 9){
    80002c46:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002c4a:	46a5                	li	a3,9
    80002c4c:	fed792e3          	bne	a5,a3,80002c30 <devintr+0x12>
    int irq = plic_claim();
    80002c50:	00003097          	auipc	ra,0x3
    80002c54:	598080e7          	jalr	1432(ra) # 800061e8 <plic_claim>
    80002c58:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002c5a:	47a9                	li	a5,10
    80002c5c:	02f50763          	beq	a0,a5,80002c8a <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002c60:	4785                	li	a5,1
    80002c62:	02f50963          	beq	a0,a5,80002c94 <devintr+0x76>
    return 1;
    80002c66:	4505                	li	a0,1
    } else if(irq){
    80002c68:	d8f1                	beqz	s1,80002c3c <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c6a:	85a6                	mv	a1,s1
    80002c6c:	00005517          	auipc	a0,0x5
    80002c70:	72c50513          	addi	a0,a0,1836 # 80008398 <states.0+0x98>
    80002c74:	ffffe097          	auipc	ra,0xffffe
    80002c78:	904080e7          	jalr	-1788(ra) # 80000578 <printf>
      plic_complete(irq);
    80002c7c:	8526                	mv	a0,s1
    80002c7e:	00003097          	auipc	ra,0x3
    80002c82:	58e080e7          	jalr	1422(ra) # 8000620c <plic_complete>
    return 1;
    80002c86:	4505                	li	a0,1
    80002c88:	bf55                	j	80002c3c <devintr+0x1e>
      uartintr();
    80002c8a:	ffffe097          	auipc	ra,0xffffe
    80002c8e:	d00080e7          	jalr	-768(ra) # 8000098a <uartintr>
    80002c92:	b7ed                	j	80002c7c <devintr+0x5e>
      virtio_disk_intr();
    80002c94:	00004097          	auipc	ra,0x4
    80002c98:	a0a080e7          	jalr	-1526(ra) # 8000669e <virtio_disk_intr>
    80002c9c:	b7c5                	j	80002c7c <devintr+0x5e>
    if(cpuid() == 0){
    80002c9e:	fffff097          	auipc	ra,0xfffff
    80002ca2:	cce080e7          	jalr	-818(ra) # 8000196c <cpuid>
    80002ca6:	c901                	beqz	a0,80002cb6 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002ca8:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002cac:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002cae:	14479073          	csrw	sip,a5
    return 2;
    80002cb2:	4509                	li	a0,2
    80002cb4:	b761                	j	80002c3c <devintr+0x1e>
      clockintr();
    80002cb6:	00000097          	auipc	ra,0x0
    80002cba:	f22080e7          	jalr	-222(ra) # 80002bd8 <clockintr>
    80002cbe:	b7ed                	j	80002ca8 <devintr+0x8a>

0000000080002cc0 <usertrap>:
{
    80002cc0:	1101                	addi	sp,sp,-32
    80002cc2:	ec06                	sd	ra,24(sp)
    80002cc4:	e822                	sd	s0,16(sp)
    80002cc6:	e426                	sd	s1,8(sp)
    80002cc8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cca:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002cce:	1007f793          	andi	a5,a5,256
    80002cd2:	ebad                	bnez	a5,80002d44 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cd4:	00003797          	auipc	a5,0x3
    80002cd8:	40c78793          	addi	a5,a5,1036 # 800060e0 <kernelvec>
    80002cdc:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ce0:	fffff097          	auipc	ra,0xfffff
    80002ce4:	cb8080e7          	jalr	-840(ra) # 80001998 <myproc>
    80002ce8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002cea:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cec:	14102773          	csrr	a4,sepc
    80002cf0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cf2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002cf6:	47a1                	li	a5,8
    80002cf8:	06f71463          	bne	a4,a5,80002d60 <usertrap+0xa0>
    if(p->killed==1)
    80002cfc:	5518                	lw	a4,40(a0)
    80002cfe:	4785                	li	a5,1
    80002d00:	04f70a63          	beq	a4,a5,80002d54 <usertrap+0x94>
    p->trapframe->epc += 4;
    80002d04:	6cb8                	ld	a4,88(s1)
    80002d06:	6f1c                	ld	a5,24(a4)
    80002d08:	0791                	addi	a5,a5,4
    80002d0a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d0c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d10:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d14:	10079073          	csrw	sstatus,a5
    syscall();
    80002d18:	00000097          	auipc	ra,0x0
    80002d1c:	2e4080e7          	jalr	740(ra) # 80002ffc <syscall>
  check_pending_signals(p);
    80002d20:	8526                	mv	a0,s1
    80002d22:	00000097          	auipc	ra,0x0
    80002d26:	cf0080e7          	jalr	-784(ra) # 80002a12 <check_pending_signals>
  if(p->killed==1)
    80002d2a:	5498                	lw	a4,40(s1)
    80002d2c:	4785                	li	a5,1
    80002d2e:	08f70063          	beq	a4,a5,80002dae <usertrap+0xee>
  usertrapret();
    80002d32:	00000097          	auipc	ra,0x0
    80002d36:	e08080e7          	jalr	-504(ra) # 80002b3a <usertrapret>
}
    80002d3a:	60e2                	ld	ra,24(sp)
    80002d3c:	6442                	ld	s0,16(sp)
    80002d3e:	64a2                	ld	s1,8(sp)
    80002d40:	6105                	addi	sp,sp,32
    80002d42:	8082                	ret
    panic("usertrap: not from user mode");
    80002d44:	00005517          	auipc	a0,0x5
    80002d48:	67450513          	addi	a0,a0,1652 # 800083b8 <states.0+0xb8>
    80002d4c:	ffffd097          	auipc	ra,0xffffd
    80002d50:	7e2080e7          	jalr	2018(ra) # 8000052e <panic>
      exit(-1);
    80002d54:	557d                	li	a0,-1
    80002d56:	fffff097          	auipc	ra,0xfffff
    80002d5a:	5d2080e7          	jalr	1490(ra) # 80002328 <exit>
    80002d5e:	b75d                	j	80002d04 <usertrap+0x44>
  else if((which_dev = devintr()) != 0){
    80002d60:	00000097          	auipc	ra,0x0
    80002d64:	ebe080e7          	jalr	-322(ra) # 80002c1e <devintr>
    80002d68:	c909                	beqz	a0,80002d7a <usertrap+0xba>
  if(which_dev == 2)
    80002d6a:	4789                	li	a5,2
    80002d6c:	faf51ae3          	bne	a0,a5,80002d20 <usertrap+0x60>
    yield();
    80002d70:	fffff097          	auipc	ra,0xfffff
    80002d74:	31e080e7          	jalr	798(ra) # 8000208e <yield>
    80002d78:	b765                	j	80002d20 <usertrap+0x60>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d7a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d7e:	5890                	lw	a2,48(s1)
    80002d80:	00005517          	auipc	a0,0x5
    80002d84:	65850513          	addi	a0,a0,1624 # 800083d8 <states.0+0xd8>
    80002d88:	ffffd097          	auipc	ra,0xffffd
    80002d8c:	7f0080e7          	jalr	2032(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d90:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d94:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d98:	00005517          	auipc	a0,0x5
    80002d9c:	67050513          	addi	a0,a0,1648 # 80008408 <states.0+0x108>
    80002da0:	ffffd097          	auipc	ra,0xffffd
    80002da4:	7d8080e7          	jalr	2008(ra) # 80000578 <printf>
    p->killed = 1;
    80002da8:	4785                	li	a5,1
    80002daa:	d49c                	sw	a5,40(s1)
  if(which_dev == 2)
    80002dac:	bf95                	j	80002d20 <usertrap+0x60>
    exit(-1);
    80002dae:	557d                	li	a0,-1
    80002db0:	fffff097          	auipc	ra,0xfffff
    80002db4:	578080e7          	jalr	1400(ra) # 80002328 <exit>
    80002db8:	bfad                	j	80002d32 <usertrap+0x72>

0000000080002dba <kerneltrap>:
{
    80002dba:	7179                	addi	sp,sp,-48
    80002dbc:	f406                	sd	ra,40(sp)
    80002dbe:	f022                	sd	s0,32(sp)
    80002dc0:	ec26                	sd	s1,24(sp)
    80002dc2:	e84a                	sd	s2,16(sp)
    80002dc4:	e44e                	sd	s3,8(sp)
    80002dc6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dc8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dcc:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002dd0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002dd4:	1004f793          	andi	a5,s1,256
    80002dd8:	cb85                	beqz	a5,80002e08 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dda:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002dde:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002de0:	ef85                	bnez	a5,80002e18 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002de2:	00000097          	auipc	ra,0x0
    80002de6:	e3c080e7          	jalr	-452(ra) # 80002c1e <devintr>
    80002dea:	cd1d                	beqz	a0,80002e28 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002dec:	4789                	li	a5,2
    80002dee:	06f50a63          	beq	a0,a5,80002e62 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002df2:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002df6:	10049073          	csrw	sstatus,s1
}
    80002dfa:	70a2                	ld	ra,40(sp)
    80002dfc:	7402                	ld	s0,32(sp)
    80002dfe:	64e2                	ld	s1,24(sp)
    80002e00:	6942                	ld	s2,16(sp)
    80002e02:	69a2                	ld	s3,8(sp)
    80002e04:	6145                	addi	sp,sp,48
    80002e06:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002e08:	00005517          	auipc	a0,0x5
    80002e0c:	62050513          	addi	a0,a0,1568 # 80008428 <states.0+0x128>
    80002e10:	ffffd097          	auipc	ra,0xffffd
    80002e14:	71e080e7          	jalr	1822(ra) # 8000052e <panic>
    panic("kerneltrap: interrupts enabled");
    80002e18:	00005517          	auipc	a0,0x5
    80002e1c:	63850513          	addi	a0,a0,1592 # 80008450 <states.0+0x150>
    80002e20:	ffffd097          	auipc	ra,0xffffd
    80002e24:	70e080e7          	jalr	1806(ra) # 8000052e <panic>
    printf("scause %p\n", scause);
    80002e28:	85ce                	mv	a1,s3
    80002e2a:	00005517          	auipc	a0,0x5
    80002e2e:	64650513          	addi	a0,a0,1606 # 80008470 <states.0+0x170>
    80002e32:	ffffd097          	auipc	ra,0xffffd
    80002e36:	746080e7          	jalr	1862(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e3a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e3e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e42:	00005517          	auipc	a0,0x5
    80002e46:	63e50513          	addi	a0,a0,1598 # 80008480 <states.0+0x180>
    80002e4a:	ffffd097          	auipc	ra,0xffffd
    80002e4e:	72e080e7          	jalr	1838(ra) # 80000578 <printf>
    panic("kerneltrap");
    80002e52:	00005517          	auipc	a0,0x5
    80002e56:	64650513          	addi	a0,a0,1606 # 80008498 <states.0+0x198>
    80002e5a:	ffffd097          	auipc	ra,0xffffd
    80002e5e:	6d4080e7          	jalr	1748(ra) # 8000052e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e62:	fffff097          	auipc	ra,0xfffff
    80002e66:	b36080e7          	jalr	-1226(ra) # 80001998 <myproc>
    80002e6a:	d541                	beqz	a0,80002df2 <kerneltrap+0x38>
    80002e6c:	fffff097          	auipc	ra,0xfffff
    80002e70:	b2c080e7          	jalr	-1236(ra) # 80001998 <myproc>
    80002e74:	4d18                	lw	a4,24(a0)
    80002e76:	4791                	li	a5,4
    80002e78:	f6f71de3          	bne	a4,a5,80002df2 <kerneltrap+0x38>
    yield();
    80002e7c:	fffff097          	auipc	ra,0xfffff
    80002e80:	212080e7          	jalr	530(ra) # 8000208e <yield>
    80002e84:	b7bd                	j	80002df2 <kerneltrap+0x38>

0000000080002e86 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e86:	1101                	addi	sp,sp,-32
    80002e88:	ec06                	sd	ra,24(sp)
    80002e8a:	e822                	sd	s0,16(sp)
    80002e8c:	e426                	sd	s1,8(sp)
    80002e8e:	1000                	addi	s0,sp,32
    80002e90:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002e92:	fffff097          	auipc	ra,0xfffff
    80002e96:	b06080e7          	jalr	-1274(ra) # 80001998 <myproc>
  switch (n) {
    80002e9a:	4795                	li	a5,5
    80002e9c:	0497e163          	bltu	a5,s1,80002ede <argraw+0x58>
    80002ea0:	048a                	slli	s1,s1,0x2
    80002ea2:	00005717          	auipc	a4,0x5
    80002ea6:	62e70713          	addi	a4,a4,1582 # 800084d0 <states.0+0x1d0>
    80002eaa:	94ba                	add	s1,s1,a4
    80002eac:	409c                	lw	a5,0(s1)
    80002eae:	97ba                	add	a5,a5,a4
    80002eb0:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002eb2:	6d3c                	ld	a5,88(a0)
    80002eb4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002eb6:	60e2                	ld	ra,24(sp)
    80002eb8:	6442                	ld	s0,16(sp)
    80002eba:	64a2                	ld	s1,8(sp)
    80002ebc:	6105                	addi	sp,sp,32
    80002ebe:	8082                	ret
    return p->trapframe->a1;
    80002ec0:	6d3c                	ld	a5,88(a0)
    80002ec2:	7fa8                	ld	a0,120(a5)
    80002ec4:	bfcd                	j	80002eb6 <argraw+0x30>
    return p->trapframe->a2;
    80002ec6:	6d3c                	ld	a5,88(a0)
    80002ec8:	63c8                	ld	a0,128(a5)
    80002eca:	b7f5                	j	80002eb6 <argraw+0x30>
    return p->trapframe->a3;
    80002ecc:	6d3c                	ld	a5,88(a0)
    80002ece:	67c8                	ld	a0,136(a5)
    80002ed0:	b7dd                	j	80002eb6 <argraw+0x30>
    return p->trapframe->a4;
    80002ed2:	6d3c                	ld	a5,88(a0)
    80002ed4:	6bc8                	ld	a0,144(a5)
    80002ed6:	b7c5                	j	80002eb6 <argraw+0x30>
    return p->trapframe->a5;
    80002ed8:	6d3c                	ld	a5,88(a0)
    80002eda:	6fc8                	ld	a0,152(a5)
    80002edc:	bfe9                	j	80002eb6 <argraw+0x30>
  panic("argraw");
    80002ede:	00005517          	auipc	a0,0x5
    80002ee2:	5ca50513          	addi	a0,a0,1482 # 800084a8 <states.0+0x1a8>
    80002ee6:	ffffd097          	auipc	ra,0xffffd
    80002eea:	648080e7          	jalr	1608(ra) # 8000052e <panic>

0000000080002eee <fetchaddr>:
{
    80002eee:	1101                	addi	sp,sp,-32
    80002ef0:	ec06                	sd	ra,24(sp)
    80002ef2:	e822                	sd	s0,16(sp)
    80002ef4:	e426                	sd	s1,8(sp)
    80002ef6:	e04a                	sd	s2,0(sp)
    80002ef8:	1000                	addi	s0,sp,32
    80002efa:	84aa                	mv	s1,a0
    80002efc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002efe:	fffff097          	auipc	ra,0xfffff
    80002f02:	a9a080e7          	jalr	-1382(ra) # 80001998 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002f06:	653c                	ld	a5,72(a0)
    80002f08:	02f4f863          	bgeu	s1,a5,80002f38 <fetchaddr+0x4a>
    80002f0c:	00848713          	addi	a4,s1,8
    80002f10:	02e7e663          	bltu	a5,a4,80002f3c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002f14:	46a1                	li	a3,8
    80002f16:	8626                	mv	a2,s1
    80002f18:	85ca                	mv	a1,s2
    80002f1a:	6928                	ld	a0,80(a0)
    80002f1c:	ffffe097          	auipc	ra,0xffffe
    80002f20:	7c8080e7          	jalr	1992(ra) # 800016e4 <copyin>
    80002f24:	00a03533          	snez	a0,a0
    80002f28:	40a00533          	neg	a0,a0
}
    80002f2c:	60e2                	ld	ra,24(sp)
    80002f2e:	6442                	ld	s0,16(sp)
    80002f30:	64a2                	ld	s1,8(sp)
    80002f32:	6902                	ld	s2,0(sp)
    80002f34:	6105                	addi	sp,sp,32
    80002f36:	8082                	ret
    return -1;
    80002f38:	557d                	li	a0,-1
    80002f3a:	bfcd                	j	80002f2c <fetchaddr+0x3e>
    80002f3c:	557d                	li	a0,-1
    80002f3e:	b7fd                	j	80002f2c <fetchaddr+0x3e>

0000000080002f40 <fetchstr>:
{
    80002f40:	7179                	addi	sp,sp,-48
    80002f42:	f406                	sd	ra,40(sp)
    80002f44:	f022                	sd	s0,32(sp)
    80002f46:	ec26                	sd	s1,24(sp)
    80002f48:	e84a                	sd	s2,16(sp)
    80002f4a:	e44e                	sd	s3,8(sp)
    80002f4c:	1800                	addi	s0,sp,48
    80002f4e:	892a                	mv	s2,a0
    80002f50:	84ae                	mv	s1,a1
    80002f52:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002f54:	fffff097          	auipc	ra,0xfffff
    80002f58:	a44080e7          	jalr	-1468(ra) # 80001998 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002f5c:	86ce                	mv	a3,s3
    80002f5e:	864a                	mv	a2,s2
    80002f60:	85a6                	mv	a1,s1
    80002f62:	6928                	ld	a0,80(a0)
    80002f64:	fffff097          	auipc	ra,0xfffff
    80002f68:	80e080e7          	jalr	-2034(ra) # 80001772 <copyinstr>
  if(err < 0)
    80002f6c:	00054763          	bltz	a0,80002f7a <fetchstr+0x3a>
  return strlen(buf);
    80002f70:	8526                	mv	a0,s1
    80002f72:	ffffe097          	auipc	ra,0xffffe
    80002f76:	eea080e7          	jalr	-278(ra) # 80000e5c <strlen>
}
    80002f7a:	70a2                	ld	ra,40(sp)
    80002f7c:	7402                	ld	s0,32(sp)
    80002f7e:	64e2                	ld	s1,24(sp)
    80002f80:	6942                	ld	s2,16(sp)
    80002f82:	69a2                	ld	s3,8(sp)
    80002f84:	6145                	addi	sp,sp,48
    80002f86:	8082                	ret

0000000080002f88 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002f88:	1101                	addi	sp,sp,-32
    80002f8a:	ec06                	sd	ra,24(sp)
    80002f8c:	e822                	sd	s0,16(sp)
    80002f8e:	e426                	sd	s1,8(sp)
    80002f90:	1000                	addi	s0,sp,32
    80002f92:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f94:	00000097          	auipc	ra,0x0
    80002f98:	ef2080e7          	jalr	-270(ra) # 80002e86 <argraw>
    80002f9c:	c088                	sw	a0,0(s1)
  return 0;
}
    80002f9e:	4501                	li	a0,0
    80002fa0:	60e2                	ld	ra,24(sp)
    80002fa2:	6442                	ld	s0,16(sp)
    80002fa4:	64a2                	ld	s1,8(sp)
    80002fa6:	6105                	addi	sp,sp,32
    80002fa8:	8082                	ret

0000000080002faa <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002faa:	1101                	addi	sp,sp,-32
    80002fac:	ec06                	sd	ra,24(sp)
    80002fae:	e822                	sd	s0,16(sp)
    80002fb0:	e426                	sd	s1,8(sp)
    80002fb2:	1000                	addi	s0,sp,32
    80002fb4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002fb6:	00000097          	auipc	ra,0x0
    80002fba:	ed0080e7          	jalr	-304(ra) # 80002e86 <argraw>
    80002fbe:	e088                	sd	a0,0(s1)
  return 0;
}
    80002fc0:	4501                	li	a0,0
    80002fc2:	60e2                	ld	ra,24(sp)
    80002fc4:	6442                	ld	s0,16(sp)
    80002fc6:	64a2                	ld	s1,8(sp)
    80002fc8:	6105                	addi	sp,sp,32
    80002fca:	8082                	ret

0000000080002fcc <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002fcc:	1101                	addi	sp,sp,-32
    80002fce:	ec06                	sd	ra,24(sp)
    80002fd0:	e822                	sd	s0,16(sp)
    80002fd2:	e426                	sd	s1,8(sp)
    80002fd4:	e04a                	sd	s2,0(sp)
    80002fd6:	1000                	addi	s0,sp,32
    80002fd8:	84ae                	mv	s1,a1
    80002fda:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002fdc:	00000097          	auipc	ra,0x0
    80002fe0:	eaa080e7          	jalr	-342(ra) # 80002e86 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002fe4:	864a                	mv	a2,s2
    80002fe6:	85a6                	mv	a1,s1
    80002fe8:	00000097          	auipc	ra,0x0
    80002fec:	f58080e7          	jalr	-168(ra) # 80002f40 <fetchstr>
}
    80002ff0:	60e2                	ld	ra,24(sp)
    80002ff2:	6442                	ld	s0,16(sp)
    80002ff4:	64a2                	ld	s1,8(sp)
    80002ff6:	6902                	ld	s2,0(sp)
    80002ff8:	6105                	addi	sp,sp,32
    80002ffa:	8082                	ret

0000000080002ffc <syscall>:
[SYS_sigret] sys_sigret,
};

void
syscall(void)
{
    80002ffc:	1101                	addi	sp,sp,-32
    80002ffe:	ec06                	sd	ra,24(sp)
    80003000:	e822                	sd	s0,16(sp)
    80003002:	e426                	sd	s1,8(sp)
    80003004:	e04a                	sd	s2,0(sp)
    80003006:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003008:	fffff097          	auipc	ra,0xfffff
    8000300c:	990080e7          	jalr	-1648(ra) # 80001998 <myproc>
    80003010:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003012:	05853903          	ld	s2,88(a0)
    80003016:	0a893783          	ld	a5,168(s2)
    8000301a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000301e:	37fd                	addiw	a5,a5,-1
    80003020:	475d                	li	a4,23
    80003022:	00f76f63          	bltu	a4,a5,80003040 <syscall+0x44>
    80003026:	00369713          	slli	a4,a3,0x3
    8000302a:	00005797          	auipc	a5,0x5
    8000302e:	4be78793          	addi	a5,a5,1214 # 800084e8 <syscalls>
    80003032:	97ba                	add	a5,a5,a4
    80003034:	639c                	ld	a5,0(a5)
    80003036:	c789                	beqz	a5,80003040 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80003038:	9782                	jalr	a5
    8000303a:	06a93823          	sd	a0,112(s2)
    8000303e:	a839                	j	8000305c <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003040:	15848613          	addi	a2,s1,344
    80003044:	588c                	lw	a1,48(s1)
    80003046:	00005517          	auipc	a0,0x5
    8000304a:	46a50513          	addi	a0,a0,1130 # 800084b0 <states.0+0x1b0>
    8000304e:	ffffd097          	auipc	ra,0xffffd
    80003052:	52a080e7          	jalr	1322(ra) # 80000578 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003056:	6cbc                	ld	a5,88(s1)
    80003058:	577d                	li	a4,-1
    8000305a:	fbb8                	sd	a4,112(a5)
  }
}
    8000305c:	60e2                	ld	ra,24(sp)
    8000305e:	6442                	ld	s0,16(sp)
    80003060:	64a2                	ld	s1,8(sp)
    80003062:	6902                	ld	s2,0(sp)
    80003064:	6105                	addi	sp,sp,32
    80003066:	8082                	ret

0000000080003068 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003068:	1101                	addi	sp,sp,-32
    8000306a:	ec06                	sd	ra,24(sp)
    8000306c:	e822                	sd	s0,16(sp)
    8000306e:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003070:	fec40593          	addi	a1,s0,-20
    80003074:	4501                	li	a0,0
    80003076:	00000097          	auipc	ra,0x0
    8000307a:	f12080e7          	jalr	-238(ra) # 80002f88 <argint>
    return -1;
    8000307e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003080:	00054963          	bltz	a0,80003092 <sys_exit+0x2a>
  exit(n);
    80003084:	fec42503          	lw	a0,-20(s0)
    80003088:	fffff097          	auipc	ra,0xfffff
    8000308c:	2a0080e7          	jalr	672(ra) # 80002328 <exit>
  return 0;  // not reached
    80003090:	4781                	li	a5,0
}
    80003092:	853e                	mv	a0,a5
    80003094:	60e2                	ld	ra,24(sp)
    80003096:	6442                	ld	s0,16(sp)
    80003098:	6105                	addi	sp,sp,32
    8000309a:	8082                	ret

000000008000309c <sys_getpid>:

uint64
sys_getpid(void)
{
    8000309c:	1141                	addi	sp,sp,-16
    8000309e:	e406                	sd	ra,8(sp)
    800030a0:	e022                	sd	s0,0(sp)
    800030a2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800030a4:	fffff097          	auipc	ra,0xfffff
    800030a8:	8f4080e7          	jalr	-1804(ra) # 80001998 <myproc>
}
    800030ac:	5908                	lw	a0,48(a0)
    800030ae:	60a2                	ld	ra,8(sp)
    800030b0:	6402                	ld	s0,0(sp)
    800030b2:	0141                	addi	sp,sp,16
    800030b4:	8082                	ret

00000000800030b6 <sys_fork>:

uint64
sys_fork(void)
{
    800030b6:	1141                	addi	sp,sp,-16
    800030b8:	e406                	sd	ra,8(sp)
    800030ba:	e022                	sd	s0,0(sp)
    800030bc:	0800                	addi	s0,sp,16
  return fork();
    800030be:	fffff097          	auipc	ra,0xfffff
    800030c2:	cdc080e7          	jalr	-804(ra) # 80001d9a <fork>
}
    800030c6:	60a2                	ld	ra,8(sp)
    800030c8:	6402                	ld	s0,0(sp)
    800030ca:	0141                	addi	sp,sp,16
    800030cc:	8082                	ret

00000000800030ce <sys_wait>:

uint64
sys_wait(void)
{
    800030ce:	1101                	addi	sp,sp,-32
    800030d0:	ec06                	sd	ra,24(sp)
    800030d2:	e822                	sd	s0,16(sp)
    800030d4:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    800030d6:	fe840593          	addi	a1,s0,-24
    800030da:	4501                	li	a0,0
    800030dc:	00000097          	auipc	ra,0x0
    800030e0:	ece080e7          	jalr	-306(ra) # 80002faa <argaddr>
    800030e4:	87aa                	mv	a5,a0
    return -1;
    800030e6:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800030e8:	0007c863          	bltz	a5,800030f8 <sys_wait+0x2a>
  return wait(p);
    800030ec:	fe843503          	ld	a0,-24(s0)
    800030f0:	fffff097          	auipc	ra,0xfffff
    800030f4:	03e080e7          	jalr	62(ra) # 8000212e <wait>
}
    800030f8:	60e2                	ld	ra,24(sp)
    800030fa:	6442                	ld	s0,16(sp)
    800030fc:	6105                	addi	sp,sp,32
    800030fe:	8082                	ret

0000000080003100 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003100:	7179                	addi	sp,sp,-48
    80003102:	f406                	sd	ra,40(sp)
    80003104:	f022                	sd	s0,32(sp)
    80003106:	ec26                	sd	s1,24(sp)
    80003108:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000310a:	fdc40593          	addi	a1,s0,-36
    8000310e:	4501                	li	a0,0
    80003110:	00000097          	auipc	ra,0x0
    80003114:	e78080e7          	jalr	-392(ra) # 80002f88 <argint>
    return -1;
    80003118:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    8000311a:	00054f63          	bltz	a0,80003138 <sys_sbrk+0x38>
  addr = myproc()->sz;
    8000311e:	fffff097          	auipc	ra,0xfffff
    80003122:	87a080e7          	jalr	-1926(ra) # 80001998 <myproc>
    80003126:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80003128:	fdc42503          	lw	a0,-36(s0)
    8000312c:	fffff097          	auipc	ra,0xfffff
    80003130:	bfa080e7          	jalr	-1030(ra) # 80001d26 <growproc>
    80003134:	00054863          	bltz	a0,80003144 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003138:	8526                	mv	a0,s1
    8000313a:	70a2                	ld	ra,40(sp)
    8000313c:	7402                	ld	s0,32(sp)
    8000313e:	64e2                	ld	s1,24(sp)
    80003140:	6145                	addi	sp,sp,48
    80003142:	8082                	ret
    return -1;
    80003144:	54fd                	li	s1,-1
    80003146:	bfcd                	j	80003138 <sys_sbrk+0x38>

0000000080003148 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003148:	7139                	addi	sp,sp,-64
    8000314a:	fc06                	sd	ra,56(sp)
    8000314c:	f822                	sd	s0,48(sp)
    8000314e:	f426                	sd	s1,40(sp)
    80003150:	f04a                	sd	s2,32(sp)
    80003152:	ec4e                	sd	s3,24(sp)
    80003154:	e852                	sd	s4,16(sp)
    80003156:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003158:	fcc40593          	addi	a1,s0,-52
    8000315c:	4501                	li	a0,0
    8000315e:	00000097          	auipc	ra,0x0
    80003162:	e2a080e7          	jalr	-470(ra) # 80002f88 <argint>
    return -1;
    80003166:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003168:	06054763          	bltz	a0,800031d6 <sys_sleep+0x8e>
  acquire(&tickslock);
    8000316c:	0001a517          	auipc	a0,0x1a
    80003170:	76450513          	addi	a0,a0,1892 # 8001d8d0 <tickslock>
    80003174:	ffffe097          	auipc	ra,0xffffe
    80003178:	a52080e7          	jalr	-1454(ra) # 80000bc6 <acquire>
  ticks0 = ticks;
    8000317c:	00006997          	auipc	s3,0x6
    80003180:	eb49a983          	lw	s3,-332(s3) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80003184:	fcc42783          	lw	a5,-52(s0)
    80003188:	cf95                	beqz	a5,800031c4 <sys_sleep+0x7c>
    if(myproc()->killed==1){
    8000318a:	4905                	li	s2,1
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000318c:	0001aa17          	auipc	s4,0x1a
    80003190:	744a0a13          	addi	s4,s4,1860 # 8001d8d0 <tickslock>
    80003194:	00006497          	auipc	s1,0x6
    80003198:	e9c48493          	addi	s1,s1,-356 # 80009030 <ticks>
    if(myproc()->killed==1){
    8000319c:	ffffe097          	auipc	ra,0xffffe
    800031a0:	7fc080e7          	jalr	2044(ra) # 80001998 <myproc>
    800031a4:	551c                	lw	a5,40(a0)
    800031a6:	05278163          	beq	a5,s2,800031e8 <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    800031aa:	85d2                	mv	a1,s4
    800031ac:	8526                	mv	a0,s1
    800031ae:	fffff097          	auipc	ra,0xfffff
    800031b2:	f1c080e7          	jalr	-228(ra) # 800020ca <sleep>
  while(ticks - ticks0 < n){
    800031b6:	409c                	lw	a5,0(s1)
    800031b8:	413787bb          	subw	a5,a5,s3
    800031bc:	fcc42703          	lw	a4,-52(s0)
    800031c0:	fce7eee3          	bltu	a5,a4,8000319c <sys_sleep+0x54>
  }
  release(&tickslock);
    800031c4:	0001a517          	auipc	a0,0x1a
    800031c8:	70c50513          	addi	a0,a0,1804 # 8001d8d0 <tickslock>
    800031cc:	ffffe097          	auipc	ra,0xffffe
    800031d0:	ac4080e7          	jalr	-1340(ra) # 80000c90 <release>
  return 0;
    800031d4:	4781                	li	a5,0
}
    800031d6:	853e                	mv	a0,a5
    800031d8:	70e2                	ld	ra,56(sp)
    800031da:	7442                	ld	s0,48(sp)
    800031dc:	74a2                	ld	s1,40(sp)
    800031de:	7902                	ld	s2,32(sp)
    800031e0:	69e2                	ld	s3,24(sp)
    800031e2:	6a42                	ld	s4,16(sp)
    800031e4:	6121                	addi	sp,sp,64
    800031e6:	8082                	ret
      release(&tickslock);
    800031e8:	0001a517          	auipc	a0,0x1a
    800031ec:	6e850513          	addi	a0,a0,1768 # 8001d8d0 <tickslock>
    800031f0:	ffffe097          	auipc	ra,0xffffe
    800031f4:	aa0080e7          	jalr	-1376(ra) # 80000c90 <release>
      return -1;
    800031f8:	57fd                	li	a5,-1
    800031fa:	bff1                	j	800031d6 <sys_sleep+0x8e>

00000000800031fc <sys_kill>:

uint64
sys_kill(void)
{
    800031fc:	1101                	addi	sp,sp,-32
    800031fe:	ec06                	sd	ra,24(sp)
    80003200:	e822                	sd	s0,16(sp)
    80003202:	1000                	addi	s0,sp,32
  int pid;
  int signum;

  if(argint(0, &pid) < 0)
    80003204:	fec40593          	addi	a1,s0,-20
    80003208:	4501                	li	a0,0
    8000320a:	00000097          	auipc	ra,0x0
    8000320e:	d7e080e7          	jalr	-642(ra) # 80002f88 <argint>
    80003212:	87aa                	mv	a5,a0
    return -1;
    80003214:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003216:	0207c963          	bltz	a5,80003248 <sys_kill+0x4c>
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    8000321a:	fe840593          	addi	a1,s0,-24
    8000321e:	4505                	li	a0,1
    80003220:	00000097          	auipc	ra,0x0
    80003224:	d68080e7          	jalr	-664(ra) # 80002f88 <argint>
    80003228:	02054463          	bltz	a0,80003250 <sys_kill+0x54>
    8000322c:	fe842583          	lw	a1,-24(s0)
    80003230:	0005871b          	sext.w	a4,a1
    80003234:	47fd                	li	a5,31
    return -1;
    80003236:	557d                	li	a0,-1
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003238:	00e7e863          	bltu	a5,a4,80003248 <sys_kill+0x4c>
  return kill(pid, signum);
    8000323c:	fec42503          	lw	a0,-20(s0)
    80003240:	fffff097          	auipc	ra,0xfffff
    80003244:	1be080e7          	jalr	446(ra) # 800023fe <kill>
}
    80003248:	60e2                	ld	ra,24(sp)
    8000324a:	6442                	ld	s0,16(sp)
    8000324c:	6105                	addi	sp,sp,32
    8000324e:	8082                	ret
    return -1;
    80003250:	557d                	li	a0,-1
    80003252:	bfdd                	j	80003248 <sys_kill+0x4c>

0000000080003254 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003254:	1101                	addi	sp,sp,-32
    80003256:	ec06                	sd	ra,24(sp)
    80003258:	e822                	sd	s0,16(sp)
    8000325a:	e426                	sd	s1,8(sp)
    8000325c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000325e:	0001a517          	auipc	a0,0x1a
    80003262:	67250513          	addi	a0,a0,1650 # 8001d8d0 <tickslock>
    80003266:	ffffe097          	auipc	ra,0xffffe
    8000326a:	960080e7          	jalr	-1696(ra) # 80000bc6 <acquire>
  xticks = ticks;
    8000326e:	00006497          	auipc	s1,0x6
    80003272:	dc24a483          	lw	s1,-574(s1) # 80009030 <ticks>
  release(&tickslock);
    80003276:	0001a517          	auipc	a0,0x1a
    8000327a:	65a50513          	addi	a0,a0,1626 # 8001d8d0 <tickslock>
    8000327e:	ffffe097          	auipc	ra,0xffffe
    80003282:	a12080e7          	jalr	-1518(ra) # 80000c90 <release>
  return xticks;
}
    80003286:	02049513          	slli	a0,s1,0x20
    8000328a:	9101                	srli	a0,a0,0x20
    8000328c:	60e2                	ld	ra,24(sp)
    8000328e:	6442                	ld	s0,16(sp)
    80003290:	64a2                	ld	s1,8(sp)
    80003292:	6105                	addi	sp,sp,32
    80003294:	8082                	ret

0000000080003296 <sys_sigprocmask>:

uint64
sys_sigprocmask(void)
{
    80003296:	1101                	addi	sp,sp,-32
    80003298:	ec06                	sd	ra,24(sp)
    8000329a:	e822                	sd	s0,16(sp)
    8000329c:	1000                	addi	s0,sp,32
  int sigmask;

  if(argint(0, &sigmask) < 0)
    8000329e:	fec40593          	addi	a1,s0,-20
    800032a2:	4501                	li	a0,0
    800032a4:	00000097          	auipc	ra,0x0
    800032a8:	ce4080e7          	jalr	-796(ra) # 80002f88 <argint>
    800032ac:	87aa                	mv	a5,a0
    return -1;
    800032ae:	557d                	li	a0,-1
  if(argint(0, &sigmask) < 0)
    800032b0:	0007ca63          	bltz	a5,800032c4 <sys_sigprocmask+0x2e>
  return sigprocmask((uint)sigmask);
    800032b4:	fec42503          	lw	a0,-20(s0)
    800032b8:	fffff097          	auipc	ra,0xfffff
    800032bc:	3c2080e7          	jalr	962(ra) # 8000267a <sigprocmask>
    800032c0:	1502                	slli	a0,a0,0x20
    800032c2:	9101                	srli	a0,a0,0x20
}
    800032c4:	60e2                	ld	ra,24(sp)
    800032c6:	6442                	ld	s0,16(sp)
    800032c8:	6105                	addi	sp,sp,32
    800032ca:	8082                	ret

00000000800032cc <sys_sigaction>:

uint64
sys_sigaction(void)
{
    800032cc:	7179                	addi	sp,sp,-48
    800032ce:	f406                	sd	ra,40(sp)
    800032d0:	f022                	sd	s0,32(sp)
    800032d2:	1800                	addi	s0,sp,48
  int signum;
  uint64 newact;
  uint64 oldact;
  
  if(argint(0, &signum) < 0)
    800032d4:	fec40593          	addi	a1,s0,-20
    800032d8:	4501                	li	a0,0
    800032da:	00000097          	auipc	ra,0x0
    800032de:	cae080e7          	jalr	-850(ra) # 80002f88 <argint>
    return -1;
    800032e2:	57fd                	li	a5,-1
  if(argint(0, &signum) < 0)
    800032e4:	04054163          	bltz	a0,80003326 <sys_sigaction+0x5a>
  if(argaddr(1, &newact) < 0)
    800032e8:	fe040593          	addi	a1,s0,-32
    800032ec:	4505                	li	a0,1
    800032ee:	00000097          	auipc	ra,0x0
    800032f2:	cbc080e7          	jalr	-836(ra) # 80002faa <argaddr>
    return -1;
    800032f6:	57fd                	li	a5,-1
  if(argaddr(1, &newact) < 0)
    800032f8:	02054763          	bltz	a0,80003326 <sys_sigaction+0x5a>
  if(argaddr(1, &oldact) < 0)
    800032fc:	fd840593          	addi	a1,s0,-40
    80003300:	4505                	li	a0,1
    80003302:	00000097          	auipc	ra,0x0
    80003306:	ca8080e7          	jalr	-856(ra) # 80002faa <argaddr>
    return -1;
    8000330a:	57fd                	li	a5,-1
  if(argaddr(1, &oldact) < 0)
    8000330c:	00054d63          	bltz	a0,80003326 <sys_sigaction+0x5a>

  return sigaction(signum,newact,oldact);
    80003310:	fd843603          	ld	a2,-40(s0)
    80003314:	fe043583          	ld	a1,-32(s0)
    80003318:	fec42503          	lw	a0,-20(s0)
    8000331c:	fffff097          	auipc	ra,0xfffff
    80003320:	3b2080e7          	jalr	946(ra) # 800026ce <sigaction>
    80003324:	87aa                	mv	a5,a0
  
}
    80003326:	853e                	mv	a0,a5
    80003328:	70a2                	ld	ra,40(sp)
    8000332a:	7402                	ld	s0,32(sp)
    8000332c:	6145                	addi	sp,sp,48
    8000332e:	8082                	ret

0000000080003330 <sys_sigret>:
uint64
sys_sigret(void)
{
    80003330:	1141                	addi	sp,sp,-16
    80003332:	e406                	sd	ra,8(sp)
    80003334:	e022                	sd	s0,0(sp)
    80003336:	0800                	addi	s0,sp,16
  sigret();
    80003338:	fffff097          	auipc	ra,0xfffff
    8000333c:	4a8080e7          	jalr	1192(ra) # 800027e0 <sigret>
  return 0;
}
    80003340:	4501                	li	a0,0
    80003342:	60a2                	ld	ra,8(sp)
    80003344:	6402                	ld	s0,0(sp)
    80003346:	0141                	addi	sp,sp,16
    80003348:	8082                	ret

000000008000334a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000334a:	7179                	addi	sp,sp,-48
    8000334c:	f406                	sd	ra,40(sp)
    8000334e:	f022                	sd	s0,32(sp)
    80003350:	ec26                	sd	s1,24(sp)
    80003352:	e84a                	sd	s2,16(sp)
    80003354:	e44e                	sd	s3,8(sp)
    80003356:	e052                	sd	s4,0(sp)
    80003358:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000335a:	00005597          	auipc	a1,0x5
    8000335e:	25658593          	addi	a1,a1,598 # 800085b0 <syscalls+0xc8>
    80003362:	0001a517          	auipc	a0,0x1a
    80003366:	58650513          	addi	a0,a0,1414 # 8001d8e8 <bcache>
    8000336a:	ffffd097          	auipc	ra,0xffffd
    8000336e:	7cc080e7          	jalr	1996(ra) # 80000b36 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003372:	00022797          	auipc	a5,0x22
    80003376:	57678793          	addi	a5,a5,1398 # 800258e8 <bcache+0x8000>
    8000337a:	00022717          	auipc	a4,0x22
    8000337e:	7d670713          	addi	a4,a4,2006 # 80025b50 <bcache+0x8268>
    80003382:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003386:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000338a:	0001a497          	auipc	s1,0x1a
    8000338e:	57648493          	addi	s1,s1,1398 # 8001d900 <bcache+0x18>
    b->next = bcache.head.next;
    80003392:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003394:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003396:	00005a17          	auipc	s4,0x5
    8000339a:	222a0a13          	addi	s4,s4,546 # 800085b8 <syscalls+0xd0>
    b->next = bcache.head.next;
    8000339e:	2b893783          	ld	a5,696(s2)
    800033a2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800033a4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800033a8:	85d2                	mv	a1,s4
    800033aa:	01048513          	addi	a0,s1,16
    800033ae:	00001097          	auipc	ra,0x1
    800033b2:	4c2080e7          	jalr	1218(ra) # 80004870 <initsleeplock>
    bcache.head.next->prev = b;
    800033b6:	2b893783          	ld	a5,696(s2)
    800033ba:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800033bc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033c0:	45848493          	addi	s1,s1,1112
    800033c4:	fd349de3          	bne	s1,s3,8000339e <binit+0x54>
  }
}
    800033c8:	70a2                	ld	ra,40(sp)
    800033ca:	7402                	ld	s0,32(sp)
    800033cc:	64e2                	ld	s1,24(sp)
    800033ce:	6942                	ld	s2,16(sp)
    800033d0:	69a2                	ld	s3,8(sp)
    800033d2:	6a02                	ld	s4,0(sp)
    800033d4:	6145                	addi	sp,sp,48
    800033d6:	8082                	ret

00000000800033d8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800033d8:	7179                	addi	sp,sp,-48
    800033da:	f406                	sd	ra,40(sp)
    800033dc:	f022                	sd	s0,32(sp)
    800033de:	ec26                	sd	s1,24(sp)
    800033e0:	e84a                	sd	s2,16(sp)
    800033e2:	e44e                	sd	s3,8(sp)
    800033e4:	1800                	addi	s0,sp,48
    800033e6:	892a                	mv	s2,a0
    800033e8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800033ea:	0001a517          	auipc	a0,0x1a
    800033ee:	4fe50513          	addi	a0,a0,1278 # 8001d8e8 <bcache>
    800033f2:	ffffd097          	auipc	ra,0xffffd
    800033f6:	7d4080e7          	jalr	2004(ra) # 80000bc6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800033fa:	00022497          	auipc	s1,0x22
    800033fe:	7a64b483          	ld	s1,1958(s1) # 80025ba0 <bcache+0x82b8>
    80003402:	00022797          	auipc	a5,0x22
    80003406:	74e78793          	addi	a5,a5,1870 # 80025b50 <bcache+0x8268>
    8000340a:	02f48f63          	beq	s1,a5,80003448 <bread+0x70>
    8000340e:	873e                	mv	a4,a5
    80003410:	a021                	j	80003418 <bread+0x40>
    80003412:	68a4                	ld	s1,80(s1)
    80003414:	02e48a63          	beq	s1,a4,80003448 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003418:	449c                	lw	a5,8(s1)
    8000341a:	ff279ce3          	bne	a5,s2,80003412 <bread+0x3a>
    8000341e:	44dc                	lw	a5,12(s1)
    80003420:	ff3799e3          	bne	a5,s3,80003412 <bread+0x3a>
      b->refcnt++;
    80003424:	40bc                	lw	a5,64(s1)
    80003426:	2785                	addiw	a5,a5,1
    80003428:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000342a:	0001a517          	auipc	a0,0x1a
    8000342e:	4be50513          	addi	a0,a0,1214 # 8001d8e8 <bcache>
    80003432:	ffffe097          	auipc	ra,0xffffe
    80003436:	85e080e7          	jalr	-1954(ra) # 80000c90 <release>
      acquiresleep(&b->lock);
    8000343a:	01048513          	addi	a0,s1,16
    8000343e:	00001097          	auipc	ra,0x1
    80003442:	46c080e7          	jalr	1132(ra) # 800048aa <acquiresleep>
      return b;
    80003446:	a8b9                	j	800034a4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003448:	00022497          	auipc	s1,0x22
    8000344c:	7504b483          	ld	s1,1872(s1) # 80025b98 <bcache+0x82b0>
    80003450:	00022797          	auipc	a5,0x22
    80003454:	70078793          	addi	a5,a5,1792 # 80025b50 <bcache+0x8268>
    80003458:	00f48863          	beq	s1,a5,80003468 <bread+0x90>
    8000345c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000345e:	40bc                	lw	a5,64(s1)
    80003460:	cf81                	beqz	a5,80003478 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003462:	64a4                	ld	s1,72(s1)
    80003464:	fee49de3          	bne	s1,a4,8000345e <bread+0x86>
  panic("bget: no buffers");
    80003468:	00005517          	auipc	a0,0x5
    8000346c:	15850513          	addi	a0,a0,344 # 800085c0 <syscalls+0xd8>
    80003470:	ffffd097          	auipc	ra,0xffffd
    80003474:	0be080e7          	jalr	190(ra) # 8000052e <panic>
      b->dev = dev;
    80003478:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000347c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003480:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003484:	4785                	li	a5,1
    80003486:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003488:	0001a517          	auipc	a0,0x1a
    8000348c:	46050513          	addi	a0,a0,1120 # 8001d8e8 <bcache>
    80003490:	ffffe097          	auipc	ra,0xffffe
    80003494:	800080e7          	jalr	-2048(ra) # 80000c90 <release>
      acquiresleep(&b->lock);
    80003498:	01048513          	addi	a0,s1,16
    8000349c:	00001097          	auipc	ra,0x1
    800034a0:	40e080e7          	jalr	1038(ra) # 800048aa <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800034a4:	409c                	lw	a5,0(s1)
    800034a6:	cb89                	beqz	a5,800034b8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800034a8:	8526                	mv	a0,s1
    800034aa:	70a2                	ld	ra,40(sp)
    800034ac:	7402                	ld	s0,32(sp)
    800034ae:	64e2                	ld	s1,24(sp)
    800034b0:	6942                	ld	s2,16(sp)
    800034b2:	69a2                	ld	s3,8(sp)
    800034b4:	6145                	addi	sp,sp,48
    800034b6:	8082                	ret
    virtio_disk_rw(b, 0);
    800034b8:	4581                	li	a1,0
    800034ba:	8526                	mv	a0,s1
    800034bc:	00003097          	auipc	ra,0x3
    800034c0:	f5a080e7          	jalr	-166(ra) # 80006416 <virtio_disk_rw>
    b->valid = 1;
    800034c4:	4785                	li	a5,1
    800034c6:	c09c                	sw	a5,0(s1)
  return b;
    800034c8:	b7c5                	j	800034a8 <bread+0xd0>

00000000800034ca <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800034ca:	1101                	addi	sp,sp,-32
    800034cc:	ec06                	sd	ra,24(sp)
    800034ce:	e822                	sd	s0,16(sp)
    800034d0:	e426                	sd	s1,8(sp)
    800034d2:	1000                	addi	s0,sp,32
    800034d4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034d6:	0541                	addi	a0,a0,16
    800034d8:	00001097          	auipc	ra,0x1
    800034dc:	46c080e7          	jalr	1132(ra) # 80004944 <holdingsleep>
    800034e0:	cd01                	beqz	a0,800034f8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800034e2:	4585                	li	a1,1
    800034e4:	8526                	mv	a0,s1
    800034e6:	00003097          	auipc	ra,0x3
    800034ea:	f30080e7          	jalr	-208(ra) # 80006416 <virtio_disk_rw>
}
    800034ee:	60e2                	ld	ra,24(sp)
    800034f0:	6442                	ld	s0,16(sp)
    800034f2:	64a2                	ld	s1,8(sp)
    800034f4:	6105                	addi	sp,sp,32
    800034f6:	8082                	ret
    panic("bwrite");
    800034f8:	00005517          	auipc	a0,0x5
    800034fc:	0e050513          	addi	a0,a0,224 # 800085d8 <syscalls+0xf0>
    80003500:	ffffd097          	auipc	ra,0xffffd
    80003504:	02e080e7          	jalr	46(ra) # 8000052e <panic>

0000000080003508 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003508:	1101                	addi	sp,sp,-32
    8000350a:	ec06                	sd	ra,24(sp)
    8000350c:	e822                	sd	s0,16(sp)
    8000350e:	e426                	sd	s1,8(sp)
    80003510:	e04a                	sd	s2,0(sp)
    80003512:	1000                	addi	s0,sp,32
    80003514:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003516:	01050913          	addi	s2,a0,16
    8000351a:	854a                	mv	a0,s2
    8000351c:	00001097          	auipc	ra,0x1
    80003520:	428080e7          	jalr	1064(ra) # 80004944 <holdingsleep>
    80003524:	c92d                	beqz	a0,80003596 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003526:	854a                	mv	a0,s2
    80003528:	00001097          	auipc	ra,0x1
    8000352c:	3d8080e7          	jalr	984(ra) # 80004900 <releasesleep>

  acquire(&bcache.lock);
    80003530:	0001a517          	auipc	a0,0x1a
    80003534:	3b850513          	addi	a0,a0,952 # 8001d8e8 <bcache>
    80003538:	ffffd097          	auipc	ra,0xffffd
    8000353c:	68e080e7          	jalr	1678(ra) # 80000bc6 <acquire>
  b->refcnt--;
    80003540:	40bc                	lw	a5,64(s1)
    80003542:	37fd                	addiw	a5,a5,-1
    80003544:	0007871b          	sext.w	a4,a5
    80003548:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000354a:	eb05                	bnez	a4,8000357a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000354c:	68bc                	ld	a5,80(s1)
    8000354e:	64b8                	ld	a4,72(s1)
    80003550:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003552:	64bc                	ld	a5,72(s1)
    80003554:	68b8                	ld	a4,80(s1)
    80003556:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003558:	00022797          	auipc	a5,0x22
    8000355c:	39078793          	addi	a5,a5,912 # 800258e8 <bcache+0x8000>
    80003560:	2b87b703          	ld	a4,696(a5)
    80003564:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003566:	00022717          	auipc	a4,0x22
    8000356a:	5ea70713          	addi	a4,a4,1514 # 80025b50 <bcache+0x8268>
    8000356e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003570:	2b87b703          	ld	a4,696(a5)
    80003574:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003576:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000357a:	0001a517          	auipc	a0,0x1a
    8000357e:	36e50513          	addi	a0,a0,878 # 8001d8e8 <bcache>
    80003582:	ffffd097          	auipc	ra,0xffffd
    80003586:	70e080e7          	jalr	1806(ra) # 80000c90 <release>
}
    8000358a:	60e2                	ld	ra,24(sp)
    8000358c:	6442                	ld	s0,16(sp)
    8000358e:	64a2                	ld	s1,8(sp)
    80003590:	6902                	ld	s2,0(sp)
    80003592:	6105                	addi	sp,sp,32
    80003594:	8082                	ret
    panic("brelse");
    80003596:	00005517          	auipc	a0,0x5
    8000359a:	04a50513          	addi	a0,a0,74 # 800085e0 <syscalls+0xf8>
    8000359e:	ffffd097          	auipc	ra,0xffffd
    800035a2:	f90080e7          	jalr	-112(ra) # 8000052e <panic>

00000000800035a6 <bpin>:

void
bpin(struct buf *b) {
    800035a6:	1101                	addi	sp,sp,-32
    800035a8:	ec06                	sd	ra,24(sp)
    800035aa:	e822                	sd	s0,16(sp)
    800035ac:	e426                	sd	s1,8(sp)
    800035ae:	1000                	addi	s0,sp,32
    800035b0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035b2:	0001a517          	auipc	a0,0x1a
    800035b6:	33650513          	addi	a0,a0,822 # 8001d8e8 <bcache>
    800035ba:	ffffd097          	auipc	ra,0xffffd
    800035be:	60c080e7          	jalr	1548(ra) # 80000bc6 <acquire>
  b->refcnt++;
    800035c2:	40bc                	lw	a5,64(s1)
    800035c4:	2785                	addiw	a5,a5,1
    800035c6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035c8:	0001a517          	auipc	a0,0x1a
    800035cc:	32050513          	addi	a0,a0,800 # 8001d8e8 <bcache>
    800035d0:	ffffd097          	auipc	ra,0xffffd
    800035d4:	6c0080e7          	jalr	1728(ra) # 80000c90 <release>
}
    800035d8:	60e2                	ld	ra,24(sp)
    800035da:	6442                	ld	s0,16(sp)
    800035dc:	64a2                	ld	s1,8(sp)
    800035de:	6105                	addi	sp,sp,32
    800035e0:	8082                	ret

00000000800035e2 <bunpin>:

void
bunpin(struct buf *b) {
    800035e2:	1101                	addi	sp,sp,-32
    800035e4:	ec06                	sd	ra,24(sp)
    800035e6:	e822                	sd	s0,16(sp)
    800035e8:	e426                	sd	s1,8(sp)
    800035ea:	1000                	addi	s0,sp,32
    800035ec:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035ee:	0001a517          	auipc	a0,0x1a
    800035f2:	2fa50513          	addi	a0,a0,762 # 8001d8e8 <bcache>
    800035f6:	ffffd097          	auipc	ra,0xffffd
    800035fa:	5d0080e7          	jalr	1488(ra) # 80000bc6 <acquire>
  b->refcnt--;
    800035fe:	40bc                	lw	a5,64(s1)
    80003600:	37fd                	addiw	a5,a5,-1
    80003602:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003604:	0001a517          	auipc	a0,0x1a
    80003608:	2e450513          	addi	a0,a0,740 # 8001d8e8 <bcache>
    8000360c:	ffffd097          	auipc	ra,0xffffd
    80003610:	684080e7          	jalr	1668(ra) # 80000c90 <release>
}
    80003614:	60e2                	ld	ra,24(sp)
    80003616:	6442                	ld	s0,16(sp)
    80003618:	64a2                	ld	s1,8(sp)
    8000361a:	6105                	addi	sp,sp,32
    8000361c:	8082                	ret

000000008000361e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000361e:	1101                	addi	sp,sp,-32
    80003620:	ec06                	sd	ra,24(sp)
    80003622:	e822                	sd	s0,16(sp)
    80003624:	e426                	sd	s1,8(sp)
    80003626:	e04a                	sd	s2,0(sp)
    80003628:	1000                	addi	s0,sp,32
    8000362a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000362c:	00d5d59b          	srliw	a1,a1,0xd
    80003630:	00023797          	auipc	a5,0x23
    80003634:	9947a783          	lw	a5,-1644(a5) # 80025fc4 <sb+0x1c>
    80003638:	9dbd                	addw	a1,a1,a5
    8000363a:	00000097          	auipc	ra,0x0
    8000363e:	d9e080e7          	jalr	-610(ra) # 800033d8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003642:	0074f713          	andi	a4,s1,7
    80003646:	4785                	li	a5,1
    80003648:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000364c:	14ce                	slli	s1,s1,0x33
    8000364e:	90d9                	srli	s1,s1,0x36
    80003650:	00950733          	add	a4,a0,s1
    80003654:	05874703          	lbu	a4,88(a4)
    80003658:	00e7f6b3          	and	a3,a5,a4
    8000365c:	c69d                	beqz	a3,8000368a <bfree+0x6c>
    8000365e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003660:	94aa                	add	s1,s1,a0
    80003662:	fff7c793          	not	a5,a5
    80003666:	8ff9                	and	a5,a5,a4
    80003668:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000366c:	00001097          	auipc	ra,0x1
    80003670:	11e080e7          	jalr	286(ra) # 8000478a <log_write>
  brelse(bp);
    80003674:	854a                	mv	a0,s2
    80003676:	00000097          	auipc	ra,0x0
    8000367a:	e92080e7          	jalr	-366(ra) # 80003508 <brelse>
}
    8000367e:	60e2                	ld	ra,24(sp)
    80003680:	6442                	ld	s0,16(sp)
    80003682:	64a2                	ld	s1,8(sp)
    80003684:	6902                	ld	s2,0(sp)
    80003686:	6105                	addi	sp,sp,32
    80003688:	8082                	ret
    panic("freeing free block");
    8000368a:	00005517          	auipc	a0,0x5
    8000368e:	f5e50513          	addi	a0,a0,-162 # 800085e8 <syscalls+0x100>
    80003692:	ffffd097          	auipc	ra,0xffffd
    80003696:	e9c080e7          	jalr	-356(ra) # 8000052e <panic>

000000008000369a <balloc>:
{
    8000369a:	711d                	addi	sp,sp,-96
    8000369c:	ec86                	sd	ra,88(sp)
    8000369e:	e8a2                	sd	s0,80(sp)
    800036a0:	e4a6                	sd	s1,72(sp)
    800036a2:	e0ca                	sd	s2,64(sp)
    800036a4:	fc4e                	sd	s3,56(sp)
    800036a6:	f852                	sd	s4,48(sp)
    800036a8:	f456                	sd	s5,40(sp)
    800036aa:	f05a                	sd	s6,32(sp)
    800036ac:	ec5e                	sd	s7,24(sp)
    800036ae:	e862                	sd	s8,16(sp)
    800036b0:	e466                	sd	s9,8(sp)
    800036b2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800036b4:	00023797          	auipc	a5,0x23
    800036b8:	8f87a783          	lw	a5,-1800(a5) # 80025fac <sb+0x4>
    800036bc:	cbd1                	beqz	a5,80003750 <balloc+0xb6>
    800036be:	8baa                	mv	s7,a0
    800036c0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800036c2:	00023b17          	auipc	s6,0x23
    800036c6:	8e6b0b13          	addi	s6,s6,-1818 # 80025fa8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036ca:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800036cc:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036ce:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800036d0:	6c89                	lui	s9,0x2
    800036d2:	a831                	j	800036ee <balloc+0x54>
    brelse(bp);
    800036d4:	854a                	mv	a0,s2
    800036d6:	00000097          	auipc	ra,0x0
    800036da:	e32080e7          	jalr	-462(ra) # 80003508 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800036de:	015c87bb          	addw	a5,s9,s5
    800036e2:	00078a9b          	sext.w	s5,a5
    800036e6:	004b2703          	lw	a4,4(s6)
    800036ea:	06eaf363          	bgeu	s5,a4,80003750 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800036ee:	41fad79b          	sraiw	a5,s5,0x1f
    800036f2:	0137d79b          	srliw	a5,a5,0x13
    800036f6:	015787bb          	addw	a5,a5,s5
    800036fa:	40d7d79b          	sraiw	a5,a5,0xd
    800036fe:	01cb2583          	lw	a1,28(s6)
    80003702:	9dbd                	addw	a1,a1,a5
    80003704:	855e                	mv	a0,s7
    80003706:	00000097          	auipc	ra,0x0
    8000370a:	cd2080e7          	jalr	-814(ra) # 800033d8 <bread>
    8000370e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003710:	004b2503          	lw	a0,4(s6)
    80003714:	000a849b          	sext.w	s1,s5
    80003718:	8662                	mv	a2,s8
    8000371a:	faa4fde3          	bgeu	s1,a0,800036d4 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000371e:	41f6579b          	sraiw	a5,a2,0x1f
    80003722:	01d7d69b          	srliw	a3,a5,0x1d
    80003726:	00c6873b          	addw	a4,a3,a2
    8000372a:	00777793          	andi	a5,a4,7
    8000372e:	9f95                	subw	a5,a5,a3
    80003730:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003734:	4037571b          	sraiw	a4,a4,0x3
    80003738:	00e906b3          	add	a3,s2,a4
    8000373c:	0586c683          	lbu	a3,88(a3)
    80003740:	00d7f5b3          	and	a1,a5,a3
    80003744:	cd91                	beqz	a1,80003760 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003746:	2605                	addiw	a2,a2,1
    80003748:	2485                	addiw	s1,s1,1
    8000374a:	fd4618e3          	bne	a2,s4,8000371a <balloc+0x80>
    8000374e:	b759                	j	800036d4 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003750:	00005517          	auipc	a0,0x5
    80003754:	eb050513          	addi	a0,a0,-336 # 80008600 <syscalls+0x118>
    80003758:	ffffd097          	auipc	ra,0xffffd
    8000375c:	dd6080e7          	jalr	-554(ra) # 8000052e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003760:	974a                	add	a4,a4,s2
    80003762:	8fd5                	or	a5,a5,a3
    80003764:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003768:	854a                	mv	a0,s2
    8000376a:	00001097          	auipc	ra,0x1
    8000376e:	020080e7          	jalr	32(ra) # 8000478a <log_write>
        brelse(bp);
    80003772:	854a                	mv	a0,s2
    80003774:	00000097          	auipc	ra,0x0
    80003778:	d94080e7          	jalr	-620(ra) # 80003508 <brelse>
  bp = bread(dev, bno);
    8000377c:	85a6                	mv	a1,s1
    8000377e:	855e                	mv	a0,s7
    80003780:	00000097          	auipc	ra,0x0
    80003784:	c58080e7          	jalr	-936(ra) # 800033d8 <bread>
    80003788:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000378a:	40000613          	li	a2,1024
    8000378e:	4581                	li	a1,0
    80003790:	05850513          	addi	a0,a0,88
    80003794:	ffffd097          	auipc	ra,0xffffd
    80003798:	544080e7          	jalr	1348(ra) # 80000cd8 <memset>
  log_write(bp);
    8000379c:	854a                	mv	a0,s2
    8000379e:	00001097          	auipc	ra,0x1
    800037a2:	fec080e7          	jalr	-20(ra) # 8000478a <log_write>
  brelse(bp);
    800037a6:	854a                	mv	a0,s2
    800037a8:	00000097          	auipc	ra,0x0
    800037ac:	d60080e7          	jalr	-672(ra) # 80003508 <brelse>
}
    800037b0:	8526                	mv	a0,s1
    800037b2:	60e6                	ld	ra,88(sp)
    800037b4:	6446                	ld	s0,80(sp)
    800037b6:	64a6                	ld	s1,72(sp)
    800037b8:	6906                	ld	s2,64(sp)
    800037ba:	79e2                	ld	s3,56(sp)
    800037bc:	7a42                	ld	s4,48(sp)
    800037be:	7aa2                	ld	s5,40(sp)
    800037c0:	7b02                	ld	s6,32(sp)
    800037c2:	6be2                	ld	s7,24(sp)
    800037c4:	6c42                	ld	s8,16(sp)
    800037c6:	6ca2                	ld	s9,8(sp)
    800037c8:	6125                	addi	sp,sp,96
    800037ca:	8082                	ret

00000000800037cc <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800037cc:	7179                	addi	sp,sp,-48
    800037ce:	f406                	sd	ra,40(sp)
    800037d0:	f022                	sd	s0,32(sp)
    800037d2:	ec26                	sd	s1,24(sp)
    800037d4:	e84a                	sd	s2,16(sp)
    800037d6:	e44e                	sd	s3,8(sp)
    800037d8:	e052                	sd	s4,0(sp)
    800037da:	1800                	addi	s0,sp,48
    800037dc:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800037de:	47ad                	li	a5,11
    800037e0:	04b7fe63          	bgeu	a5,a1,8000383c <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800037e4:	ff45849b          	addiw	s1,a1,-12
    800037e8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800037ec:	0ff00793          	li	a5,255
    800037f0:	0ae7e463          	bltu	a5,a4,80003898 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800037f4:	08052583          	lw	a1,128(a0)
    800037f8:	c5b5                	beqz	a1,80003864 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800037fa:	00092503          	lw	a0,0(s2)
    800037fe:	00000097          	auipc	ra,0x0
    80003802:	bda080e7          	jalr	-1062(ra) # 800033d8 <bread>
    80003806:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003808:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000380c:	02049713          	slli	a4,s1,0x20
    80003810:	01e75593          	srli	a1,a4,0x1e
    80003814:	00b784b3          	add	s1,a5,a1
    80003818:	0004a983          	lw	s3,0(s1)
    8000381c:	04098e63          	beqz	s3,80003878 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003820:	8552                	mv	a0,s4
    80003822:	00000097          	auipc	ra,0x0
    80003826:	ce6080e7          	jalr	-794(ra) # 80003508 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000382a:	854e                	mv	a0,s3
    8000382c:	70a2                	ld	ra,40(sp)
    8000382e:	7402                	ld	s0,32(sp)
    80003830:	64e2                	ld	s1,24(sp)
    80003832:	6942                	ld	s2,16(sp)
    80003834:	69a2                	ld	s3,8(sp)
    80003836:	6a02                	ld	s4,0(sp)
    80003838:	6145                	addi	sp,sp,48
    8000383a:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000383c:	02059793          	slli	a5,a1,0x20
    80003840:	01e7d593          	srli	a1,a5,0x1e
    80003844:	00b504b3          	add	s1,a0,a1
    80003848:	0504a983          	lw	s3,80(s1)
    8000384c:	fc099fe3          	bnez	s3,8000382a <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003850:	4108                	lw	a0,0(a0)
    80003852:	00000097          	auipc	ra,0x0
    80003856:	e48080e7          	jalr	-440(ra) # 8000369a <balloc>
    8000385a:	0005099b          	sext.w	s3,a0
    8000385e:	0534a823          	sw	s3,80(s1)
    80003862:	b7e1                	j	8000382a <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003864:	4108                	lw	a0,0(a0)
    80003866:	00000097          	auipc	ra,0x0
    8000386a:	e34080e7          	jalr	-460(ra) # 8000369a <balloc>
    8000386e:	0005059b          	sext.w	a1,a0
    80003872:	08b92023          	sw	a1,128(s2)
    80003876:	b751                	j	800037fa <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003878:	00092503          	lw	a0,0(s2)
    8000387c:	00000097          	auipc	ra,0x0
    80003880:	e1e080e7          	jalr	-482(ra) # 8000369a <balloc>
    80003884:	0005099b          	sext.w	s3,a0
    80003888:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000388c:	8552                	mv	a0,s4
    8000388e:	00001097          	auipc	ra,0x1
    80003892:	efc080e7          	jalr	-260(ra) # 8000478a <log_write>
    80003896:	b769                	j	80003820 <bmap+0x54>
  panic("bmap: out of range");
    80003898:	00005517          	auipc	a0,0x5
    8000389c:	d8050513          	addi	a0,a0,-640 # 80008618 <syscalls+0x130>
    800038a0:	ffffd097          	auipc	ra,0xffffd
    800038a4:	c8e080e7          	jalr	-882(ra) # 8000052e <panic>

00000000800038a8 <iget>:
{
    800038a8:	7179                	addi	sp,sp,-48
    800038aa:	f406                	sd	ra,40(sp)
    800038ac:	f022                	sd	s0,32(sp)
    800038ae:	ec26                	sd	s1,24(sp)
    800038b0:	e84a                	sd	s2,16(sp)
    800038b2:	e44e                	sd	s3,8(sp)
    800038b4:	e052                	sd	s4,0(sp)
    800038b6:	1800                	addi	s0,sp,48
    800038b8:	89aa                	mv	s3,a0
    800038ba:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800038bc:	00022517          	auipc	a0,0x22
    800038c0:	70c50513          	addi	a0,a0,1804 # 80025fc8 <itable>
    800038c4:	ffffd097          	auipc	ra,0xffffd
    800038c8:	302080e7          	jalr	770(ra) # 80000bc6 <acquire>
  empty = 0;
    800038cc:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038ce:	00022497          	auipc	s1,0x22
    800038d2:	71248493          	addi	s1,s1,1810 # 80025fe0 <itable+0x18>
    800038d6:	00024697          	auipc	a3,0x24
    800038da:	19a68693          	addi	a3,a3,410 # 80027a70 <log>
    800038de:	a039                	j	800038ec <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038e0:	02090b63          	beqz	s2,80003916 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038e4:	08848493          	addi	s1,s1,136
    800038e8:	02d48a63          	beq	s1,a3,8000391c <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800038ec:	449c                	lw	a5,8(s1)
    800038ee:	fef059e3          	blez	a5,800038e0 <iget+0x38>
    800038f2:	4098                	lw	a4,0(s1)
    800038f4:	ff3716e3          	bne	a4,s3,800038e0 <iget+0x38>
    800038f8:	40d8                	lw	a4,4(s1)
    800038fa:	ff4713e3          	bne	a4,s4,800038e0 <iget+0x38>
      ip->ref++;
    800038fe:	2785                	addiw	a5,a5,1
    80003900:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003902:	00022517          	auipc	a0,0x22
    80003906:	6c650513          	addi	a0,a0,1734 # 80025fc8 <itable>
    8000390a:	ffffd097          	auipc	ra,0xffffd
    8000390e:	386080e7          	jalr	902(ra) # 80000c90 <release>
      return ip;
    80003912:	8926                	mv	s2,s1
    80003914:	a03d                	j	80003942 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003916:	f7f9                	bnez	a5,800038e4 <iget+0x3c>
    80003918:	8926                	mv	s2,s1
    8000391a:	b7e9                	j	800038e4 <iget+0x3c>
  if(empty == 0)
    8000391c:	02090c63          	beqz	s2,80003954 <iget+0xac>
  ip->dev = dev;
    80003920:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003924:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003928:	4785                	li	a5,1
    8000392a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000392e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003932:	00022517          	auipc	a0,0x22
    80003936:	69650513          	addi	a0,a0,1686 # 80025fc8 <itable>
    8000393a:	ffffd097          	auipc	ra,0xffffd
    8000393e:	356080e7          	jalr	854(ra) # 80000c90 <release>
}
    80003942:	854a                	mv	a0,s2
    80003944:	70a2                	ld	ra,40(sp)
    80003946:	7402                	ld	s0,32(sp)
    80003948:	64e2                	ld	s1,24(sp)
    8000394a:	6942                	ld	s2,16(sp)
    8000394c:	69a2                	ld	s3,8(sp)
    8000394e:	6a02                	ld	s4,0(sp)
    80003950:	6145                	addi	sp,sp,48
    80003952:	8082                	ret
    panic("iget: no inodes");
    80003954:	00005517          	auipc	a0,0x5
    80003958:	cdc50513          	addi	a0,a0,-804 # 80008630 <syscalls+0x148>
    8000395c:	ffffd097          	auipc	ra,0xffffd
    80003960:	bd2080e7          	jalr	-1070(ra) # 8000052e <panic>

0000000080003964 <fsinit>:
fsinit(int dev) {
    80003964:	7179                	addi	sp,sp,-48
    80003966:	f406                	sd	ra,40(sp)
    80003968:	f022                	sd	s0,32(sp)
    8000396a:	ec26                	sd	s1,24(sp)
    8000396c:	e84a                	sd	s2,16(sp)
    8000396e:	e44e                	sd	s3,8(sp)
    80003970:	1800                	addi	s0,sp,48
    80003972:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003974:	4585                	li	a1,1
    80003976:	00000097          	auipc	ra,0x0
    8000397a:	a62080e7          	jalr	-1438(ra) # 800033d8 <bread>
    8000397e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003980:	00022997          	auipc	s3,0x22
    80003984:	62898993          	addi	s3,s3,1576 # 80025fa8 <sb>
    80003988:	02000613          	li	a2,32
    8000398c:	05850593          	addi	a1,a0,88
    80003990:	854e                	mv	a0,s3
    80003992:	ffffd097          	auipc	ra,0xffffd
    80003996:	3a2080e7          	jalr	930(ra) # 80000d34 <memmove>
  brelse(bp);
    8000399a:	8526                	mv	a0,s1
    8000399c:	00000097          	auipc	ra,0x0
    800039a0:	b6c080e7          	jalr	-1172(ra) # 80003508 <brelse>
  if(sb.magic != FSMAGIC)
    800039a4:	0009a703          	lw	a4,0(s3)
    800039a8:	102037b7          	lui	a5,0x10203
    800039ac:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800039b0:	02f71263          	bne	a4,a5,800039d4 <fsinit+0x70>
  initlog(dev, &sb);
    800039b4:	00022597          	auipc	a1,0x22
    800039b8:	5f458593          	addi	a1,a1,1524 # 80025fa8 <sb>
    800039bc:	854a                	mv	a0,s2
    800039be:	00001097          	auipc	ra,0x1
    800039c2:	b4e080e7          	jalr	-1202(ra) # 8000450c <initlog>
}
    800039c6:	70a2                	ld	ra,40(sp)
    800039c8:	7402                	ld	s0,32(sp)
    800039ca:	64e2                	ld	s1,24(sp)
    800039cc:	6942                	ld	s2,16(sp)
    800039ce:	69a2                	ld	s3,8(sp)
    800039d0:	6145                	addi	sp,sp,48
    800039d2:	8082                	ret
    panic("invalid file system");
    800039d4:	00005517          	auipc	a0,0x5
    800039d8:	c6c50513          	addi	a0,a0,-916 # 80008640 <syscalls+0x158>
    800039dc:	ffffd097          	auipc	ra,0xffffd
    800039e0:	b52080e7          	jalr	-1198(ra) # 8000052e <panic>

00000000800039e4 <iinit>:
{
    800039e4:	7179                	addi	sp,sp,-48
    800039e6:	f406                	sd	ra,40(sp)
    800039e8:	f022                	sd	s0,32(sp)
    800039ea:	ec26                	sd	s1,24(sp)
    800039ec:	e84a                	sd	s2,16(sp)
    800039ee:	e44e                	sd	s3,8(sp)
    800039f0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800039f2:	00005597          	auipc	a1,0x5
    800039f6:	c6658593          	addi	a1,a1,-922 # 80008658 <syscalls+0x170>
    800039fa:	00022517          	auipc	a0,0x22
    800039fe:	5ce50513          	addi	a0,a0,1486 # 80025fc8 <itable>
    80003a02:	ffffd097          	auipc	ra,0xffffd
    80003a06:	134080e7          	jalr	308(ra) # 80000b36 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a0a:	00022497          	auipc	s1,0x22
    80003a0e:	5e648493          	addi	s1,s1,1510 # 80025ff0 <itable+0x28>
    80003a12:	00024997          	auipc	s3,0x24
    80003a16:	06e98993          	addi	s3,s3,110 # 80027a80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a1a:	00005917          	auipc	s2,0x5
    80003a1e:	c4690913          	addi	s2,s2,-954 # 80008660 <syscalls+0x178>
    80003a22:	85ca                	mv	a1,s2
    80003a24:	8526                	mv	a0,s1
    80003a26:	00001097          	auipc	ra,0x1
    80003a2a:	e4a080e7          	jalr	-438(ra) # 80004870 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a2e:	08848493          	addi	s1,s1,136
    80003a32:	ff3498e3          	bne	s1,s3,80003a22 <iinit+0x3e>
}
    80003a36:	70a2                	ld	ra,40(sp)
    80003a38:	7402                	ld	s0,32(sp)
    80003a3a:	64e2                	ld	s1,24(sp)
    80003a3c:	6942                	ld	s2,16(sp)
    80003a3e:	69a2                	ld	s3,8(sp)
    80003a40:	6145                	addi	sp,sp,48
    80003a42:	8082                	ret

0000000080003a44 <ialloc>:
{
    80003a44:	715d                	addi	sp,sp,-80
    80003a46:	e486                	sd	ra,72(sp)
    80003a48:	e0a2                	sd	s0,64(sp)
    80003a4a:	fc26                	sd	s1,56(sp)
    80003a4c:	f84a                	sd	s2,48(sp)
    80003a4e:	f44e                	sd	s3,40(sp)
    80003a50:	f052                	sd	s4,32(sp)
    80003a52:	ec56                	sd	s5,24(sp)
    80003a54:	e85a                	sd	s6,16(sp)
    80003a56:	e45e                	sd	s7,8(sp)
    80003a58:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a5a:	00022717          	auipc	a4,0x22
    80003a5e:	55a72703          	lw	a4,1370(a4) # 80025fb4 <sb+0xc>
    80003a62:	4785                	li	a5,1
    80003a64:	04e7fa63          	bgeu	a5,a4,80003ab8 <ialloc+0x74>
    80003a68:	8aaa                	mv	s5,a0
    80003a6a:	8bae                	mv	s7,a1
    80003a6c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a6e:	00022a17          	auipc	s4,0x22
    80003a72:	53aa0a13          	addi	s4,s4,1338 # 80025fa8 <sb>
    80003a76:	00048b1b          	sext.w	s6,s1
    80003a7a:	0044d793          	srli	a5,s1,0x4
    80003a7e:	018a2583          	lw	a1,24(s4)
    80003a82:	9dbd                	addw	a1,a1,a5
    80003a84:	8556                	mv	a0,s5
    80003a86:	00000097          	auipc	ra,0x0
    80003a8a:	952080e7          	jalr	-1710(ra) # 800033d8 <bread>
    80003a8e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a90:	05850993          	addi	s3,a0,88
    80003a94:	00f4f793          	andi	a5,s1,15
    80003a98:	079a                	slli	a5,a5,0x6
    80003a9a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a9c:	00099783          	lh	a5,0(s3)
    80003aa0:	c785                	beqz	a5,80003ac8 <ialloc+0x84>
    brelse(bp);
    80003aa2:	00000097          	auipc	ra,0x0
    80003aa6:	a66080e7          	jalr	-1434(ra) # 80003508 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003aaa:	0485                	addi	s1,s1,1
    80003aac:	00ca2703          	lw	a4,12(s4)
    80003ab0:	0004879b          	sext.w	a5,s1
    80003ab4:	fce7e1e3          	bltu	a5,a4,80003a76 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003ab8:	00005517          	auipc	a0,0x5
    80003abc:	bb050513          	addi	a0,a0,-1104 # 80008668 <syscalls+0x180>
    80003ac0:	ffffd097          	auipc	ra,0xffffd
    80003ac4:	a6e080e7          	jalr	-1426(ra) # 8000052e <panic>
      memset(dip, 0, sizeof(*dip));
    80003ac8:	04000613          	li	a2,64
    80003acc:	4581                	li	a1,0
    80003ace:	854e                	mv	a0,s3
    80003ad0:	ffffd097          	auipc	ra,0xffffd
    80003ad4:	208080e7          	jalr	520(ra) # 80000cd8 <memset>
      dip->type = type;
    80003ad8:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003adc:	854a                	mv	a0,s2
    80003ade:	00001097          	auipc	ra,0x1
    80003ae2:	cac080e7          	jalr	-852(ra) # 8000478a <log_write>
      brelse(bp);
    80003ae6:	854a                	mv	a0,s2
    80003ae8:	00000097          	auipc	ra,0x0
    80003aec:	a20080e7          	jalr	-1504(ra) # 80003508 <brelse>
      return iget(dev, inum);
    80003af0:	85da                	mv	a1,s6
    80003af2:	8556                	mv	a0,s5
    80003af4:	00000097          	auipc	ra,0x0
    80003af8:	db4080e7          	jalr	-588(ra) # 800038a8 <iget>
}
    80003afc:	60a6                	ld	ra,72(sp)
    80003afe:	6406                	ld	s0,64(sp)
    80003b00:	74e2                	ld	s1,56(sp)
    80003b02:	7942                	ld	s2,48(sp)
    80003b04:	79a2                	ld	s3,40(sp)
    80003b06:	7a02                	ld	s4,32(sp)
    80003b08:	6ae2                	ld	s5,24(sp)
    80003b0a:	6b42                	ld	s6,16(sp)
    80003b0c:	6ba2                	ld	s7,8(sp)
    80003b0e:	6161                	addi	sp,sp,80
    80003b10:	8082                	ret

0000000080003b12 <iupdate>:
{
    80003b12:	1101                	addi	sp,sp,-32
    80003b14:	ec06                	sd	ra,24(sp)
    80003b16:	e822                	sd	s0,16(sp)
    80003b18:	e426                	sd	s1,8(sp)
    80003b1a:	e04a                	sd	s2,0(sp)
    80003b1c:	1000                	addi	s0,sp,32
    80003b1e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b20:	415c                	lw	a5,4(a0)
    80003b22:	0047d79b          	srliw	a5,a5,0x4
    80003b26:	00022597          	auipc	a1,0x22
    80003b2a:	49a5a583          	lw	a1,1178(a1) # 80025fc0 <sb+0x18>
    80003b2e:	9dbd                	addw	a1,a1,a5
    80003b30:	4108                	lw	a0,0(a0)
    80003b32:	00000097          	auipc	ra,0x0
    80003b36:	8a6080e7          	jalr	-1882(ra) # 800033d8 <bread>
    80003b3a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b3c:	05850793          	addi	a5,a0,88
    80003b40:	40c8                	lw	a0,4(s1)
    80003b42:	893d                	andi	a0,a0,15
    80003b44:	051a                	slli	a0,a0,0x6
    80003b46:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003b48:	04449703          	lh	a4,68(s1)
    80003b4c:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003b50:	04649703          	lh	a4,70(s1)
    80003b54:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003b58:	04849703          	lh	a4,72(s1)
    80003b5c:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003b60:	04a49703          	lh	a4,74(s1)
    80003b64:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003b68:	44f8                	lw	a4,76(s1)
    80003b6a:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003b6c:	03400613          	li	a2,52
    80003b70:	05048593          	addi	a1,s1,80
    80003b74:	0531                	addi	a0,a0,12
    80003b76:	ffffd097          	auipc	ra,0xffffd
    80003b7a:	1be080e7          	jalr	446(ra) # 80000d34 <memmove>
  log_write(bp);
    80003b7e:	854a                	mv	a0,s2
    80003b80:	00001097          	auipc	ra,0x1
    80003b84:	c0a080e7          	jalr	-1014(ra) # 8000478a <log_write>
  brelse(bp);
    80003b88:	854a                	mv	a0,s2
    80003b8a:	00000097          	auipc	ra,0x0
    80003b8e:	97e080e7          	jalr	-1666(ra) # 80003508 <brelse>
}
    80003b92:	60e2                	ld	ra,24(sp)
    80003b94:	6442                	ld	s0,16(sp)
    80003b96:	64a2                	ld	s1,8(sp)
    80003b98:	6902                	ld	s2,0(sp)
    80003b9a:	6105                	addi	sp,sp,32
    80003b9c:	8082                	ret

0000000080003b9e <idup>:
{
    80003b9e:	1101                	addi	sp,sp,-32
    80003ba0:	ec06                	sd	ra,24(sp)
    80003ba2:	e822                	sd	s0,16(sp)
    80003ba4:	e426                	sd	s1,8(sp)
    80003ba6:	1000                	addi	s0,sp,32
    80003ba8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003baa:	00022517          	auipc	a0,0x22
    80003bae:	41e50513          	addi	a0,a0,1054 # 80025fc8 <itable>
    80003bb2:	ffffd097          	auipc	ra,0xffffd
    80003bb6:	014080e7          	jalr	20(ra) # 80000bc6 <acquire>
  ip->ref++;
    80003bba:	449c                	lw	a5,8(s1)
    80003bbc:	2785                	addiw	a5,a5,1
    80003bbe:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bc0:	00022517          	auipc	a0,0x22
    80003bc4:	40850513          	addi	a0,a0,1032 # 80025fc8 <itable>
    80003bc8:	ffffd097          	auipc	ra,0xffffd
    80003bcc:	0c8080e7          	jalr	200(ra) # 80000c90 <release>
}
    80003bd0:	8526                	mv	a0,s1
    80003bd2:	60e2                	ld	ra,24(sp)
    80003bd4:	6442                	ld	s0,16(sp)
    80003bd6:	64a2                	ld	s1,8(sp)
    80003bd8:	6105                	addi	sp,sp,32
    80003bda:	8082                	ret

0000000080003bdc <ilock>:
{
    80003bdc:	1101                	addi	sp,sp,-32
    80003bde:	ec06                	sd	ra,24(sp)
    80003be0:	e822                	sd	s0,16(sp)
    80003be2:	e426                	sd	s1,8(sp)
    80003be4:	e04a                	sd	s2,0(sp)
    80003be6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003be8:	c115                	beqz	a0,80003c0c <ilock+0x30>
    80003bea:	84aa                	mv	s1,a0
    80003bec:	451c                	lw	a5,8(a0)
    80003bee:	00f05f63          	blez	a5,80003c0c <ilock+0x30>
  acquiresleep(&ip->lock);
    80003bf2:	0541                	addi	a0,a0,16
    80003bf4:	00001097          	auipc	ra,0x1
    80003bf8:	cb6080e7          	jalr	-842(ra) # 800048aa <acquiresleep>
  if(ip->valid == 0){
    80003bfc:	40bc                	lw	a5,64(s1)
    80003bfe:	cf99                	beqz	a5,80003c1c <ilock+0x40>
}
    80003c00:	60e2                	ld	ra,24(sp)
    80003c02:	6442                	ld	s0,16(sp)
    80003c04:	64a2                	ld	s1,8(sp)
    80003c06:	6902                	ld	s2,0(sp)
    80003c08:	6105                	addi	sp,sp,32
    80003c0a:	8082                	ret
    panic("ilock");
    80003c0c:	00005517          	auipc	a0,0x5
    80003c10:	a7450513          	addi	a0,a0,-1420 # 80008680 <syscalls+0x198>
    80003c14:	ffffd097          	auipc	ra,0xffffd
    80003c18:	91a080e7          	jalr	-1766(ra) # 8000052e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c1c:	40dc                	lw	a5,4(s1)
    80003c1e:	0047d79b          	srliw	a5,a5,0x4
    80003c22:	00022597          	auipc	a1,0x22
    80003c26:	39e5a583          	lw	a1,926(a1) # 80025fc0 <sb+0x18>
    80003c2a:	9dbd                	addw	a1,a1,a5
    80003c2c:	4088                	lw	a0,0(s1)
    80003c2e:	fffff097          	auipc	ra,0xfffff
    80003c32:	7aa080e7          	jalr	1962(ra) # 800033d8 <bread>
    80003c36:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c38:	05850593          	addi	a1,a0,88
    80003c3c:	40dc                	lw	a5,4(s1)
    80003c3e:	8bbd                	andi	a5,a5,15
    80003c40:	079a                	slli	a5,a5,0x6
    80003c42:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c44:	00059783          	lh	a5,0(a1)
    80003c48:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c4c:	00259783          	lh	a5,2(a1)
    80003c50:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c54:	00459783          	lh	a5,4(a1)
    80003c58:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c5c:	00659783          	lh	a5,6(a1)
    80003c60:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c64:	459c                	lw	a5,8(a1)
    80003c66:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c68:	03400613          	li	a2,52
    80003c6c:	05b1                	addi	a1,a1,12
    80003c6e:	05048513          	addi	a0,s1,80
    80003c72:	ffffd097          	auipc	ra,0xffffd
    80003c76:	0c2080e7          	jalr	194(ra) # 80000d34 <memmove>
    brelse(bp);
    80003c7a:	854a                	mv	a0,s2
    80003c7c:	00000097          	auipc	ra,0x0
    80003c80:	88c080e7          	jalr	-1908(ra) # 80003508 <brelse>
    ip->valid = 1;
    80003c84:	4785                	li	a5,1
    80003c86:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c88:	04449783          	lh	a5,68(s1)
    80003c8c:	fbb5                	bnez	a5,80003c00 <ilock+0x24>
      panic("ilock: no type");
    80003c8e:	00005517          	auipc	a0,0x5
    80003c92:	9fa50513          	addi	a0,a0,-1542 # 80008688 <syscalls+0x1a0>
    80003c96:	ffffd097          	auipc	ra,0xffffd
    80003c9a:	898080e7          	jalr	-1896(ra) # 8000052e <panic>

0000000080003c9e <iunlock>:
{
    80003c9e:	1101                	addi	sp,sp,-32
    80003ca0:	ec06                	sd	ra,24(sp)
    80003ca2:	e822                	sd	s0,16(sp)
    80003ca4:	e426                	sd	s1,8(sp)
    80003ca6:	e04a                	sd	s2,0(sp)
    80003ca8:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003caa:	c905                	beqz	a0,80003cda <iunlock+0x3c>
    80003cac:	84aa                	mv	s1,a0
    80003cae:	01050913          	addi	s2,a0,16
    80003cb2:	854a                	mv	a0,s2
    80003cb4:	00001097          	auipc	ra,0x1
    80003cb8:	c90080e7          	jalr	-880(ra) # 80004944 <holdingsleep>
    80003cbc:	cd19                	beqz	a0,80003cda <iunlock+0x3c>
    80003cbe:	449c                	lw	a5,8(s1)
    80003cc0:	00f05d63          	blez	a5,80003cda <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003cc4:	854a                	mv	a0,s2
    80003cc6:	00001097          	auipc	ra,0x1
    80003cca:	c3a080e7          	jalr	-966(ra) # 80004900 <releasesleep>
}
    80003cce:	60e2                	ld	ra,24(sp)
    80003cd0:	6442                	ld	s0,16(sp)
    80003cd2:	64a2                	ld	s1,8(sp)
    80003cd4:	6902                	ld	s2,0(sp)
    80003cd6:	6105                	addi	sp,sp,32
    80003cd8:	8082                	ret
    panic("iunlock");
    80003cda:	00005517          	auipc	a0,0x5
    80003cde:	9be50513          	addi	a0,a0,-1602 # 80008698 <syscalls+0x1b0>
    80003ce2:	ffffd097          	auipc	ra,0xffffd
    80003ce6:	84c080e7          	jalr	-1972(ra) # 8000052e <panic>

0000000080003cea <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003cea:	7179                	addi	sp,sp,-48
    80003cec:	f406                	sd	ra,40(sp)
    80003cee:	f022                	sd	s0,32(sp)
    80003cf0:	ec26                	sd	s1,24(sp)
    80003cf2:	e84a                	sd	s2,16(sp)
    80003cf4:	e44e                	sd	s3,8(sp)
    80003cf6:	e052                	sd	s4,0(sp)
    80003cf8:	1800                	addi	s0,sp,48
    80003cfa:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003cfc:	05050493          	addi	s1,a0,80
    80003d00:	08050913          	addi	s2,a0,128
    80003d04:	a021                	j	80003d0c <itrunc+0x22>
    80003d06:	0491                	addi	s1,s1,4
    80003d08:	01248d63          	beq	s1,s2,80003d22 <itrunc+0x38>
    if(ip->addrs[i]){
    80003d0c:	408c                	lw	a1,0(s1)
    80003d0e:	dde5                	beqz	a1,80003d06 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003d10:	0009a503          	lw	a0,0(s3)
    80003d14:	00000097          	auipc	ra,0x0
    80003d18:	90a080e7          	jalr	-1782(ra) # 8000361e <bfree>
      ip->addrs[i] = 0;
    80003d1c:	0004a023          	sw	zero,0(s1)
    80003d20:	b7dd                	j	80003d06 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d22:	0809a583          	lw	a1,128(s3)
    80003d26:	e185                	bnez	a1,80003d46 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d28:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d2c:	854e                	mv	a0,s3
    80003d2e:	00000097          	auipc	ra,0x0
    80003d32:	de4080e7          	jalr	-540(ra) # 80003b12 <iupdate>
}
    80003d36:	70a2                	ld	ra,40(sp)
    80003d38:	7402                	ld	s0,32(sp)
    80003d3a:	64e2                	ld	s1,24(sp)
    80003d3c:	6942                	ld	s2,16(sp)
    80003d3e:	69a2                	ld	s3,8(sp)
    80003d40:	6a02                	ld	s4,0(sp)
    80003d42:	6145                	addi	sp,sp,48
    80003d44:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d46:	0009a503          	lw	a0,0(s3)
    80003d4a:	fffff097          	auipc	ra,0xfffff
    80003d4e:	68e080e7          	jalr	1678(ra) # 800033d8 <bread>
    80003d52:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d54:	05850493          	addi	s1,a0,88
    80003d58:	45850913          	addi	s2,a0,1112
    80003d5c:	a021                	j	80003d64 <itrunc+0x7a>
    80003d5e:	0491                	addi	s1,s1,4
    80003d60:	01248b63          	beq	s1,s2,80003d76 <itrunc+0x8c>
      if(a[j])
    80003d64:	408c                	lw	a1,0(s1)
    80003d66:	dde5                	beqz	a1,80003d5e <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003d68:	0009a503          	lw	a0,0(s3)
    80003d6c:	00000097          	auipc	ra,0x0
    80003d70:	8b2080e7          	jalr	-1870(ra) # 8000361e <bfree>
    80003d74:	b7ed                	j	80003d5e <itrunc+0x74>
    brelse(bp);
    80003d76:	8552                	mv	a0,s4
    80003d78:	fffff097          	auipc	ra,0xfffff
    80003d7c:	790080e7          	jalr	1936(ra) # 80003508 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d80:	0809a583          	lw	a1,128(s3)
    80003d84:	0009a503          	lw	a0,0(s3)
    80003d88:	00000097          	auipc	ra,0x0
    80003d8c:	896080e7          	jalr	-1898(ra) # 8000361e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d90:	0809a023          	sw	zero,128(s3)
    80003d94:	bf51                	j	80003d28 <itrunc+0x3e>

0000000080003d96 <iput>:
{
    80003d96:	1101                	addi	sp,sp,-32
    80003d98:	ec06                	sd	ra,24(sp)
    80003d9a:	e822                	sd	s0,16(sp)
    80003d9c:	e426                	sd	s1,8(sp)
    80003d9e:	e04a                	sd	s2,0(sp)
    80003da0:	1000                	addi	s0,sp,32
    80003da2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003da4:	00022517          	auipc	a0,0x22
    80003da8:	22450513          	addi	a0,a0,548 # 80025fc8 <itable>
    80003dac:	ffffd097          	auipc	ra,0xffffd
    80003db0:	e1a080e7          	jalr	-486(ra) # 80000bc6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003db4:	4498                	lw	a4,8(s1)
    80003db6:	4785                	li	a5,1
    80003db8:	02f70363          	beq	a4,a5,80003dde <iput+0x48>
  ip->ref--;
    80003dbc:	449c                	lw	a5,8(s1)
    80003dbe:	37fd                	addiw	a5,a5,-1
    80003dc0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003dc2:	00022517          	auipc	a0,0x22
    80003dc6:	20650513          	addi	a0,a0,518 # 80025fc8 <itable>
    80003dca:	ffffd097          	auipc	ra,0xffffd
    80003dce:	ec6080e7          	jalr	-314(ra) # 80000c90 <release>
}
    80003dd2:	60e2                	ld	ra,24(sp)
    80003dd4:	6442                	ld	s0,16(sp)
    80003dd6:	64a2                	ld	s1,8(sp)
    80003dd8:	6902                	ld	s2,0(sp)
    80003dda:	6105                	addi	sp,sp,32
    80003ddc:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003dde:	40bc                	lw	a5,64(s1)
    80003de0:	dff1                	beqz	a5,80003dbc <iput+0x26>
    80003de2:	04a49783          	lh	a5,74(s1)
    80003de6:	fbf9                	bnez	a5,80003dbc <iput+0x26>
    acquiresleep(&ip->lock);
    80003de8:	01048913          	addi	s2,s1,16
    80003dec:	854a                	mv	a0,s2
    80003dee:	00001097          	auipc	ra,0x1
    80003df2:	abc080e7          	jalr	-1348(ra) # 800048aa <acquiresleep>
    release(&itable.lock);
    80003df6:	00022517          	auipc	a0,0x22
    80003dfa:	1d250513          	addi	a0,a0,466 # 80025fc8 <itable>
    80003dfe:	ffffd097          	auipc	ra,0xffffd
    80003e02:	e92080e7          	jalr	-366(ra) # 80000c90 <release>
    itrunc(ip);
    80003e06:	8526                	mv	a0,s1
    80003e08:	00000097          	auipc	ra,0x0
    80003e0c:	ee2080e7          	jalr	-286(ra) # 80003cea <itrunc>
    ip->type = 0;
    80003e10:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e14:	8526                	mv	a0,s1
    80003e16:	00000097          	auipc	ra,0x0
    80003e1a:	cfc080e7          	jalr	-772(ra) # 80003b12 <iupdate>
    ip->valid = 0;
    80003e1e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e22:	854a                	mv	a0,s2
    80003e24:	00001097          	auipc	ra,0x1
    80003e28:	adc080e7          	jalr	-1316(ra) # 80004900 <releasesleep>
    acquire(&itable.lock);
    80003e2c:	00022517          	auipc	a0,0x22
    80003e30:	19c50513          	addi	a0,a0,412 # 80025fc8 <itable>
    80003e34:	ffffd097          	auipc	ra,0xffffd
    80003e38:	d92080e7          	jalr	-622(ra) # 80000bc6 <acquire>
    80003e3c:	b741                	j	80003dbc <iput+0x26>

0000000080003e3e <iunlockput>:
{
    80003e3e:	1101                	addi	sp,sp,-32
    80003e40:	ec06                	sd	ra,24(sp)
    80003e42:	e822                	sd	s0,16(sp)
    80003e44:	e426                	sd	s1,8(sp)
    80003e46:	1000                	addi	s0,sp,32
    80003e48:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e4a:	00000097          	auipc	ra,0x0
    80003e4e:	e54080e7          	jalr	-428(ra) # 80003c9e <iunlock>
  iput(ip);
    80003e52:	8526                	mv	a0,s1
    80003e54:	00000097          	auipc	ra,0x0
    80003e58:	f42080e7          	jalr	-190(ra) # 80003d96 <iput>
}
    80003e5c:	60e2                	ld	ra,24(sp)
    80003e5e:	6442                	ld	s0,16(sp)
    80003e60:	64a2                	ld	s1,8(sp)
    80003e62:	6105                	addi	sp,sp,32
    80003e64:	8082                	ret

0000000080003e66 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e66:	1141                	addi	sp,sp,-16
    80003e68:	e422                	sd	s0,8(sp)
    80003e6a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003e6c:	411c                	lw	a5,0(a0)
    80003e6e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003e70:	415c                	lw	a5,4(a0)
    80003e72:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e74:	04451783          	lh	a5,68(a0)
    80003e78:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e7c:	04a51783          	lh	a5,74(a0)
    80003e80:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e84:	04c56783          	lwu	a5,76(a0)
    80003e88:	e99c                	sd	a5,16(a1)
}
    80003e8a:	6422                	ld	s0,8(sp)
    80003e8c:	0141                	addi	sp,sp,16
    80003e8e:	8082                	ret

0000000080003e90 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e90:	457c                	lw	a5,76(a0)
    80003e92:	0ed7e963          	bltu	a5,a3,80003f84 <readi+0xf4>
{
    80003e96:	7159                	addi	sp,sp,-112
    80003e98:	f486                	sd	ra,104(sp)
    80003e9a:	f0a2                	sd	s0,96(sp)
    80003e9c:	eca6                	sd	s1,88(sp)
    80003e9e:	e8ca                	sd	s2,80(sp)
    80003ea0:	e4ce                	sd	s3,72(sp)
    80003ea2:	e0d2                	sd	s4,64(sp)
    80003ea4:	fc56                	sd	s5,56(sp)
    80003ea6:	f85a                	sd	s6,48(sp)
    80003ea8:	f45e                	sd	s7,40(sp)
    80003eaa:	f062                	sd	s8,32(sp)
    80003eac:	ec66                	sd	s9,24(sp)
    80003eae:	e86a                	sd	s10,16(sp)
    80003eb0:	e46e                	sd	s11,8(sp)
    80003eb2:	1880                	addi	s0,sp,112
    80003eb4:	8baa                	mv	s7,a0
    80003eb6:	8c2e                	mv	s8,a1
    80003eb8:	8ab2                	mv	s5,a2
    80003eba:	84b6                	mv	s1,a3
    80003ebc:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ebe:	9f35                	addw	a4,a4,a3
    return 0;
    80003ec0:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ec2:	0ad76063          	bltu	a4,a3,80003f62 <readi+0xd2>
  if(off + n > ip->size)
    80003ec6:	00e7f463          	bgeu	a5,a4,80003ece <readi+0x3e>
    n = ip->size - off;
    80003eca:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ece:	0a0b0963          	beqz	s6,80003f80 <readi+0xf0>
    80003ed2:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ed4:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ed8:	5cfd                	li	s9,-1
    80003eda:	a82d                	j	80003f14 <readi+0x84>
    80003edc:	020a1d93          	slli	s11,s4,0x20
    80003ee0:	020ddd93          	srli	s11,s11,0x20
    80003ee4:	05890793          	addi	a5,s2,88
    80003ee8:	86ee                	mv	a3,s11
    80003eea:	963e                	add	a2,a2,a5
    80003eec:	85d6                	mv	a1,s5
    80003eee:	8562                	mv	a0,s8
    80003ef0:	ffffe097          	auipc	ra,0xffffe
    80003ef4:	614080e7          	jalr	1556(ra) # 80002504 <either_copyout>
    80003ef8:	05950d63          	beq	a0,s9,80003f52 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003efc:	854a                	mv	a0,s2
    80003efe:	fffff097          	auipc	ra,0xfffff
    80003f02:	60a080e7          	jalr	1546(ra) # 80003508 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f06:	013a09bb          	addw	s3,s4,s3
    80003f0a:	009a04bb          	addw	s1,s4,s1
    80003f0e:	9aee                	add	s5,s5,s11
    80003f10:	0569f763          	bgeu	s3,s6,80003f5e <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003f14:	000ba903          	lw	s2,0(s7)
    80003f18:	00a4d59b          	srliw	a1,s1,0xa
    80003f1c:	855e                	mv	a0,s7
    80003f1e:	00000097          	auipc	ra,0x0
    80003f22:	8ae080e7          	jalr	-1874(ra) # 800037cc <bmap>
    80003f26:	0005059b          	sext.w	a1,a0
    80003f2a:	854a                	mv	a0,s2
    80003f2c:	fffff097          	auipc	ra,0xfffff
    80003f30:	4ac080e7          	jalr	1196(ra) # 800033d8 <bread>
    80003f34:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f36:	3ff4f613          	andi	a2,s1,1023
    80003f3a:	40cd07bb          	subw	a5,s10,a2
    80003f3e:	413b073b          	subw	a4,s6,s3
    80003f42:	8a3e                	mv	s4,a5
    80003f44:	2781                	sext.w	a5,a5
    80003f46:	0007069b          	sext.w	a3,a4
    80003f4a:	f8f6f9e3          	bgeu	a3,a5,80003edc <readi+0x4c>
    80003f4e:	8a3a                	mv	s4,a4
    80003f50:	b771                	j	80003edc <readi+0x4c>
      brelse(bp);
    80003f52:	854a                	mv	a0,s2
    80003f54:	fffff097          	auipc	ra,0xfffff
    80003f58:	5b4080e7          	jalr	1460(ra) # 80003508 <brelse>
      tot = -1;
    80003f5c:	59fd                	li	s3,-1
  }
  return tot;
    80003f5e:	0009851b          	sext.w	a0,s3
}
    80003f62:	70a6                	ld	ra,104(sp)
    80003f64:	7406                	ld	s0,96(sp)
    80003f66:	64e6                	ld	s1,88(sp)
    80003f68:	6946                	ld	s2,80(sp)
    80003f6a:	69a6                	ld	s3,72(sp)
    80003f6c:	6a06                	ld	s4,64(sp)
    80003f6e:	7ae2                	ld	s5,56(sp)
    80003f70:	7b42                	ld	s6,48(sp)
    80003f72:	7ba2                	ld	s7,40(sp)
    80003f74:	7c02                	ld	s8,32(sp)
    80003f76:	6ce2                	ld	s9,24(sp)
    80003f78:	6d42                	ld	s10,16(sp)
    80003f7a:	6da2                	ld	s11,8(sp)
    80003f7c:	6165                	addi	sp,sp,112
    80003f7e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f80:	89da                	mv	s3,s6
    80003f82:	bff1                	j	80003f5e <readi+0xce>
    return 0;
    80003f84:	4501                	li	a0,0
}
    80003f86:	8082                	ret

0000000080003f88 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f88:	457c                	lw	a5,76(a0)
    80003f8a:	10d7e863          	bltu	a5,a3,8000409a <writei+0x112>
{
    80003f8e:	7159                	addi	sp,sp,-112
    80003f90:	f486                	sd	ra,104(sp)
    80003f92:	f0a2                	sd	s0,96(sp)
    80003f94:	eca6                	sd	s1,88(sp)
    80003f96:	e8ca                	sd	s2,80(sp)
    80003f98:	e4ce                	sd	s3,72(sp)
    80003f9a:	e0d2                	sd	s4,64(sp)
    80003f9c:	fc56                	sd	s5,56(sp)
    80003f9e:	f85a                	sd	s6,48(sp)
    80003fa0:	f45e                	sd	s7,40(sp)
    80003fa2:	f062                	sd	s8,32(sp)
    80003fa4:	ec66                	sd	s9,24(sp)
    80003fa6:	e86a                	sd	s10,16(sp)
    80003fa8:	e46e                	sd	s11,8(sp)
    80003faa:	1880                	addi	s0,sp,112
    80003fac:	8b2a                	mv	s6,a0
    80003fae:	8c2e                	mv	s8,a1
    80003fb0:	8ab2                	mv	s5,a2
    80003fb2:	8936                	mv	s2,a3
    80003fb4:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003fb6:	00e687bb          	addw	a5,a3,a4
    80003fba:	0ed7e263          	bltu	a5,a3,8000409e <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003fbe:	00043737          	lui	a4,0x43
    80003fc2:	0ef76063          	bltu	a4,a5,800040a2 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fc6:	0c0b8863          	beqz	s7,80004096 <writei+0x10e>
    80003fca:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fcc:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003fd0:	5cfd                	li	s9,-1
    80003fd2:	a091                	j	80004016 <writei+0x8e>
    80003fd4:	02099d93          	slli	s11,s3,0x20
    80003fd8:	020ddd93          	srli	s11,s11,0x20
    80003fdc:	05848793          	addi	a5,s1,88
    80003fe0:	86ee                	mv	a3,s11
    80003fe2:	8656                	mv	a2,s5
    80003fe4:	85e2                	mv	a1,s8
    80003fe6:	953e                	add	a0,a0,a5
    80003fe8:	ffffe097          	auipc	ra,0xffffe
    80003fec:	572080e7          	jalr	1394(ra) # 8000255a <either_copyin>
    80003ff0:	07950263          	beq	a0,s9,80004054 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ff4:	8526                	mv	a0,s1
    80003ff6:	00000097          	auipc	ra,0x0
    80003ffa:	794080e7          	jalr	1940(ra) # 8000478a <log_write>
    brelse(bp);
    80003ffe:	8526                	mv	a0,s1
    80004000:	fffff097          	auipc	ra,0xfffff
    80004004:	508080e7          	jalr	1288(ra) # 80003508 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004008:	01498a3b          	addw	s4,s3,s4
    8000400c:	0129893b          	addw	s2,s3,s2
    80004010:	9aee                	add	s5,s5,s11
    80004012:	057a7663          	bgeu	s4,s7,8000405e <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004016:	000b2483          	lw	s1,0(s6)
    8000401a:	00a9559b          	srliw	a1,s2,0xa
    8000401e:	855a                	mv	a0,s6
    80004020:	fffff097          	auipc	ra,0xfffff
    80004024:	7ac080e7          	jalr	1964(ra) # 800037cc <bmap>
    80004028:	0005059b          	sext.w	a1,a0
    8000402c:	8526                	mv	a0,s1
    8000402e:	fffff097          	auipc	ra,0xfffff
    80004032:	3aa080e7          	jalr	938(ra) # 800033d8 <bread>
    80004036:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004038:	3ff97513          	andi	a0,s2,1023
    8000403c:	40ad07bb          	subw	a5,s10,a0
    80004040:	414b873b          	subw	a4,s7,s4
    80004044:	89be                	mv	s3,a5
    80004046:	2781                	sext.w	a5,a5
    80004048:	0007069b          	sext.w	a3,a4
    8000404c:	f8f6f4e3          	bgeu	a3,a5,80003fd4 <writei+0x4c>
    80004050:	89ba                	mv	s3,a4
    80004052:	b749                	j	80003fd4 <writei+0x4c>
      brelse(bp);
    80004054:	8526                	mv	a0,s1
    80004056:	fffff097          	auipc	ra,0xfffff
    8000405a:	4b2080e7          	jalr	1202(ra) # 80003508 <brelse>
  }

  if(off > ip->size)
    8000405e:	04cb2783          	lw	a5,76(s6)
    80004062:	0127f463          	bgeu	a5,s2,8000406a <writei+0xe2>
    ip->size = off;
    80004066:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000406a:	855a                	mv	a0,s6
    8000406c:	00000097          	auipc	ra,0x0
    80004070:	aa6080e7          	jalr	-1370(ra) # 80003b12 <iupdate>

  return tot;
    80004074:	000a051b          	sext.w	a0,s4
}
    80004078:	70a6                	ld	ra,104(sp)
    8000407a:	7406                	ld	s0,96(sp)
    8000407c:	64e6                	ld	s1,88(sp)
    8000407e:	6946                	ld	s2,80(sp)
    80004080:	69a6                	ld	s3,72(sp)
    80004082:	6a06                	ld	s4,64(sp)
    80004084:	7ae2                	ld	s5,56(sp)
    80004086:	7b42                	ld	s6,48(sp)
    80004088:	7ba2                	ld	s7,40(sp)
    8000408a:	7c02                	ld	s8,32(sp)
    8000408c:	6ce2                	ld	s9,24(sp)
    8000408e:	6d42                	ld	s10,16(sp)
    80004090:	6da2                	ld	s11,8(sp)
    80004092:	6165                	addi	sp,sp,112
    80004094:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004096:	8a5e                	mv	s4,s7
    80004098:	bfc9                	j	8000406a <writei+0xe2>
    return -1;
    8000409a:	557d                	li	a0,-1
}
    8000409c:	8082                	ret
    return -1;
    8000409e:	557d                	li	a0,-1
    800040a0:	bfe1                	j	80004078 <writei+0xf0>
    return -1;
    800040a2:	557d                	li	a0,-1
    800040a4:	bfd1                	j	80004078 <writei+0xf0>

00000000800040a6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800040a6:	1141                	addi	sp,sp,-16
    800040a8:	e406                	sd	ra,8(sp)
    800040aa:	e022                	sd	s0,0(sp)
    800040ac:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800040ae:	4639                	li	a2,14
    800040b0:	ffffd097          	auipc	ra,0xffffd
    800040b4:	d00080e7          	jalr	-768(ra) # 80000db0 <strncmp>
}
    800040b8:	60a2                	ld	ra,8(sp)
    800040ba:	6402                	ld	s0,0(sp)
    800040bc:	0141                	addi	sp,sp,16
    800040be:	8082                	ret

00000000800040c0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800040c0:	7139                	addi	sp,sp,-64
    800040c2:	fc06                	sd	ra,56(sp)
    800040c4:	f822                	sd	s0,48(sp)
    800040c6:	f426                	sd	s1,40(sp)
    800040c8:	f04a                	sd	s2,32(sp)
    800040ca:	ec4e                	sd	s3,24(sp)
    800040cc:	e852                	sd	s4,16(sp)
    800040ce:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800040d0:	04451703          	lh	a4,68(a0)
    800040d4:	4785                	li	a5,1
    800040d6:	00f71a63          	bne	a4,a5,800040ea <dirlookup+0x2a>
    800040da:	892a                	mv	s2,a0
    800040dc:	89ae                	mv	s3,a1
    800040de:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800040e0:	457c                	lw	a5,76(a0)
    800040e2:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800040e4:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040e6:	e79d                	bnez	a5,80004114 <dirlookup+0x54>
    800040e8:	a8a5                	j	80004160 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800040ea:	00004517          	auipc	a0,0x4
    800040ee:	5b650513          	addi	a0,a0,1462 # 800086a0 <syscalls+0x1b8>
    800040f2:	ffffc097          	auipc	ra,0xffffc
    800040f6:	43c080e7          	jalr	1084(ra) # 8000052e <panic>
      panic("dirlookup read");
    800040fa:	00004517          	auipc	a0,0x4
    800040fe:	5be50513          	addi	a0,a0,1470 # 800086b8 <syscalls+0x1d0>
    80004102:	ffffc097          	auipc	ra,0xffffc
    80004106:	42c080e7          	jalr	1068(ra) # 8000052e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000410a:	24c1                	addiw	s1,s1,16
    8000410c:	04c92783          	lw	a5,76(s2)
    80004110:	04f4f763          	bgeu	s1,a5,8000415e <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004114:	4741                	li	a4,16
    80004116:	86a6                	mv	a3,s1
    80004118:	fc040613          	addi	a2,s0,-64
    8000411c:	4581                	li	a1,0
    8000411e:	854a                	mv	a0,s2
    80004120:	00000097          	auipc	ra,0x0
    80004124:	d70080e7          	jalr	-656(ra) # 80003e90 <readi>
    80004128:	47c1                	li	a5,16
    8000412a:	fcf518e3          	bne	a0,a5,800040fa <dirlookup+0x3a>
    if(de.inum == 0)
    8000412e:	fc045783          	lhu	a5,-64(s0)
    80004132:	dfe1                	beqz	a5,8000410a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004134:	fc240593          	addi	a1,s0,-62
    80004138:	854e                	mv	a0,s3
    8000413a:	00000097          	auipc	ra,0x0
    8000413e:	f6c080e7          	jalr	-148(ra) # 800040a6 <namecmp>
    80004142:	f561                	bnez	a0,8000410a <dirlookup+0x4a>
      if(poff)
    80004144:	000a0463          	beqz	s4,8000414c <dirlookup+0x8c>
        *poff = off;
    80004148:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000414c:	fc045583          	lhu	a1,-64(s0)
    80004150:	00092503          	lw	a0,0(s2)
    80004154:	fffff097          	auipc	ra,0xfffff
    80004158:	754080e7          	jalr	1876(ra) # 800038a8 <iget>
    8000415c:	a011                	j	80004160 <dirlookup+0xa0>
  return 0;
    8000415e:	4501                	li	a0,0
}
    80004160:	70e2                	ld	ra,56(sp)
    80004162:	7442                	ld	s0,48(sp)
    80004164:	74a2                	ld	s1,40(sp)
    80004166:	7902                	ld	s2,32(sp)
    80004168:	69e2                	ld	s3,24(sp)
    8000416a:	6a42                	ld	s4,16(sp)
    8000416c:	6121                	addi	sp,sp,64
    8000416e:	8082                	ret

0000000080004170 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004170:	711d                	addi	sp,sp,-96
    80004172:	ec86                	sd	ra,88(sp)
    80004174:	e8a2                	sd	s0,80(sp)
    80004176:	e4a6                	sd	s1,72(sp)
    80004178:	e0ca                	sd	s2,64(sp)
    8000417a:	fc4e                	sd	s3,56(sp)
    8000417c:	f852                	sd	s4,48(sp)
    8000417e:	f456                	sd	s5,40(sp)
    80004180:	f05a                	sd	s6,32(sp)
    80004182:	ec5e                	sd	s7,24(sp)
    80004184:	e862                	sd	s8,16(sp)
    80004186:	e466                	sd	s9,8(sp)
    80004188:	1080                	addi	s0,sp,96
    8000418a:	84aa                	mv	s1,a0
    8000418c:	8aae                	mv	s5,a1
    8000418e:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004190:	00054703          	lbu	a4,0(a0)
    80004194:	02f00793          	li	a5,47
    80004198:	02f70363          	beq	a4,a5,800041be <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000419c:	ffffd097          	auipc	ra,0xffffd
    800041a0:	7fc080e7          	jalr	2044(ra) # 80001998 <myproc>
    800041a4:	15053503          	ld	a0,336(a0)
    800041a8:	00000097          	auipc	ra,0x0
    800041ac:	9f6080e7          	jalr	-1546(ra) # 80003b9e <idup>
    800041b0:	89aa                	mv	s3,a0
  while(*path == '/')
    800041b2:	02f00913          	li	s2,47
  len = path - s;
    800041b6:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800041b8:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800041ba:	4b85                	li	s7,1
    800041bc:	a865                	j	80004274 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800041be:	4585                	li	a1,1
    800041c0:	4505                	li	a0,1
    800041c2:	fffff097          	auipc	ra,0xfffff
    800041c6:	6e6080e7          	jalr	1766(ra) # 800038a8 <iget>
    800041ca:	89aa                	mv	s3,a0
    800041cc:	b7dd                	j	800041b2 <namex+0x42>
      iunlockput(ip);
    800041ce:	854e                	mv	a0,s3
    800041d0:	00000097          	auipc	ra,0x0
    800041d4:	c6e080e7          	jalr	-914(ra) # 80003e3e <iunlockput>
      return 0;
    800041d8:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800041da:	854e                	mv	a0,s3
    800041dc:	60e6                	ld	ra,88(sp)
    800041de:	6446                	ld	s0,80(sp)
    800041e0:	64a6                	ld	s1,72(sp)
    800041e2:	6906                	ld	s2,64(sp)
    800041e4:	79e2                	ld	s3,56(sp)
    800041e6:	7a42                	ld	s4,48(sp)
    800041e8:	7aa2                	ld	s5,40(sp)
    800041ea:	7b02                	ld	s6,32(sp)
    800041ec:	6be2                	ld	s7,24(sp)
    800041ee:	6c42                	ld	s8,16(sp)
    800041f0:	6ca2                	ld	s9,8(sp)
    800041f2:	6125                	addi	sp,sp,96
    800041f4:	8082                	ret
      iunlock(ip);
    800041f6:	854e                	mv	a0,s3
    800041f8:	00000097          	auipc	ra,0x0
    800041fc:	aa6080e7          	jalr	-1370(ra) # 80003c9e <iunlock>
      return ip;
    80004200:	bfe9                	j	800041da <namex+0x6a>
      iunlockput(ip);
    80004202:	854e                	mv	a0,s3
    80004204:	00000097          	auipc	ra,0x0
    80004208:	c3a080e7          	jalr	-966(ra) # 80003e3e <iunlockput>
      return 0;
    8000420c:	89e6                	mv	s3,s9
    8000420e:	b7f1                	j	800041da <namex+0x6a>
  len = path - s;
    80004210:	40b48633          	sub	a2,s1,a1
    80004214:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004218:	099c5463          	bge	s8,s9,800042a0 <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000421c:	4639                	li	a2,14
    8000421e:	8552                	mv	a0,s4
    80004220:	ffffd097          	auipc	ra,0xffffd
    80004224:	b14080e7          	jalr	-1260(ra) # 80000d34 <memmove>
  while(*path == '/')
    80004228:	0004c783          	lbu	a5,0(s1)
    8000422c:	01279763          	bne	a5,s2,8000423a <namex+0xca>
    path++;
    80004230:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004232:	0004c783          	lbu	a5,0(s1)
    80004236:	ff278de3          	beq	a5,s2,80004230 <namex+0xc0>
    ilock(ip);
    8000423a:	854e                	mv	a0,s3
    8000423c:	00000097          	auipc	ra,0x0
    80004240:	9a0080e7          	jalr	-1632(ra) # 80003bdc <ilock>
    if(ip->type != T_DIR){
    80004244:	04499783          	lh	a5,68(s3)
    80004248:	f97793e3          	bne	a5,s7,800041ce <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000424c:	000a8563          	beqz	s5,80004256 <namex+0xe6>
    80004250:	0004c783          	lbu	a5,0(s1)
    80004254:	d3cd                	beqz	a5,800041f6 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004256:	865a                	mv	a2,s6
    80004258:	85d2                	mv	a1,s4
    8000425a:	854e                	mv	a0,s3
    8000425c:	00000097          	auipc	ra,0x0
    80004260:	e64080e7          	jalr	-412(ra) # 800040c0 <dirlookup>
    80004264:	8caa                	mv	s9,a0
    80004266:	dd51                	beqz	a0,80004202 <namex+0x92>
    iunlockput(ip);
    80004268:	854e                	mv	a0,s3
    8000426a:	00000097          	auipc	ra,0x0
    8000426e:	bd4080e7          	jalr	-1068(ra) # 80003e3e <iunlockput>
    ip = next;
    80004272:	89e6                	mv	s3,s9
  while(*path == '/')
    80004274:	0004c783          	lbu	a5,0(s1)
    80004278:	05279763          	bne	a5,s2,800042c6 <namex+0x156>
    path++;
    8000427c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000427e:	0004c783          	lbu	a5,0(s1)
    80004282:	ff278de3          	beq	a5,s2,8000427c <namex+0x10c>
  if(*path == 0)
    80004286:	c79d                	beqz	a5,800042b4 <namex+0x144>
    path++;
    80004288:	85a6                	mv	a1,s1
  len = path - s;
    8000428a:	8cda                	mv	s9,s6
    8000428c:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    8000428e:	01278963          	beq	a5,s2,800042a0 <namex+0x130>
    80004292:	dfbd                	beqz	a5,80004210 <namex+0xa0>
    path++;
    80004294:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004296:	0004c783          	lbu	a5,0(s1)
    8000429a:	ff279ce3          	bne	a5,s2,80004292 <namex+0x122>
    8000429e:	bf8d                	j	80004210 <namex+0xa0>
    memmove(name, s, len);
    800042a0:	2601                	sext.w	a2,a2
    800042a2:	8552                	mv	a0,s4
    800042a4:	ffffd097          	auipc	ra,0xffffd
    800042a8:	a90080e7          	jalr	-1392(ra) # 80000d34 <memmove>
    name[len] = 0;
    800042ac:	9cd2                	add	s9,s9,s4
    800042ae:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800042b2:	bf9d                	j	80004228 <namex+0xb8>
  if(nameiparent){
    800042b4:	f20a83e3          	beqz	s5,800041da <namex+0x6a>
    iput(ip);
    800042b8:	854e                	mv	a0,s3
    800042ba:	00000097          	auipc	ra,0x0
    800042be:	adc080e7          	jalr	-1316(ra) # 80003d96 <iput>
    return 0;
    800042c2:	4981                	li	s3,0
    800042c4:	bf19                	j	800041da <namex+0x6a>
  if(*path == 0)
    800042c6:	d7fd                	beqz	a5,800042b4 <namex+0x144>
  while(*path != '/' && *path != 0)
    800042c8:	0004c783          	lbu	a5,0(s1)
    800042cc:	85a6                	mv	a1,s1
    800042ce:	b7d1                	j	80004292 <namex+0x122>

00000000800042d0 <dirlink>:
{
    800042d0:	7139                	addi	sp,sp,-64
    800042d2:	fc06                	sd	ra,56(sp)
    800042d4:	f822                	sd	s0,48(sp)
    800042d6:	f426                	sd	s1,40(sp)
    800042d8:	f04a                	sd	s2,32(sp)
    800042da:	ec4e                	sd	s3,24(sp)
    800042dc:	e852                	sd	s4,16(sp)
    800042de:	0080                	addi	s0,sp,64
    800042e0:	892a                	mv	s2,a0
    800042e2:	8a2e                	mv	s4,a1
    800042e4:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800042e6:	4601                	li	a2,0
    800042e8:	00000097          	auipc	ra,0x0
    800042ec:	dd8080e7          	jalr	-552(ra) # 800040c0 <dirlookup>
    800042f0:	e93d                	bnez	a0,80004366 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042f2:	04c92483          	lw	s1,76(s2)
    800042f6:	c49d                	beqz	s1,80004324 <dirlink+0x54>
    800042f8:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042fa:	4741                	li	a4,16
    800042fc:	86a6                	mv	a3,s1
    800042fe:	fc040613          	addi	a2,s0,-64
    80004302:	4581                	li	a1,0
    80004304:	854a                	mv	a0,s2
    80004306:	00000097          	auipc	ra,0x0
    8000430a:	b8a080e7          	jalr	-1142(ra) # 80003e90 <readi>
    8000430e:	47c1                	li	a5,16
    80004310:	06f51163          	bne	a0,a5,80004372 <dirlink+0xa2>
    if(de.inum == 0)
    80004314:	fc045783          	lhu	a5,-64(s0)
    80004318:	c791                	beqz	a5,80004324 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000431a:	24c1                	addiw	s1,s1,16
    8000431c:	04c92783          	lw	a5,76(s2)
    80004320:	fcf4ede3          	bltu	s1,a5,800042fa <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004324:	4639                	li	a2,14
    80004326:	85d2                	mv	a1,s4
    80004328:	fc240513          	addi	a0,s0,-62
    8000432c:	ffffd097          	auipc	ra,0xffffd
    80004330:	ac0080e7          	jalr	-1344(ra) # 80000dec <strncpy>
  de.inum = inum;
    80004334:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004338:	4741                	li	a4,16
    8000433a:	86a6                	mv	a3,s1
    8000433c:	fc040613          	addi	a2,s0,-64
    80004340:	4581                	li	a1,0
    80004342:	854a                	mv	a0,s2
    80004344:	00000097          	auipc	ra,0x0
    80004348:	c44080e7          	jalr	-956(ra) # 80003f88 <writei>
    8000434c:	872a                	mv	a4,a0
    8000434e:	47c1                	li	a5,16
  return 0;
    80004350:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004352:	02f71863          	bne	a4,a5,80004382 <dirlink+0xb2>
}
    80004356:	70e2                	ld	ra,56(sp)
    80004358:	7442                	ld	s0,48(sp)
    8000435a:	74a2                	ld	s1,40(sp)
    8000435c:	7902                	ld	s2,32(sp)
    8000435e:	69e2                	ld	s3,24(sp)
    80004360:	6a42                	ld	s4,16(sp)
    80004362:	6121                	addi	sp,sp,64
    80004364:	8082                	ret
    iput(ip);
    80004366:	00000097          	auipc	ra,0x0
    8000436a:	a30080e7          	jalr	-1488(ra) # 80003d96 <iput>
    return -1;
    8000436e:	557d                	li	a0,-1
    80004370:	b7dd                	j	80004356 <dirlink+0x86>
      panic("dirlink read");
    80004372:	00004517          	auipc	a0,0x4
    80004376:	35650513          	addi	a0,a0,854 # 800086c8 <syscalls+0x1e0>
    8000437a:	ffffc097          	auipc	ra,0xffffc
    8000437e:	1b4080e7          	jalr	436(ra) # 8000052e <panic>
    panic("dirlink");
    80004382:	00004517          	auipc	a0,0x4
    80004386:	45650513          	addi	a0,a0,1110 # 800087d8 <syscalls+0x2f0>
    8000438a:	ffffc097          	auipc	ra,0xffffc
    8000438e:	1a4080e7          	jalr	420(ra) # 8000052e <panic>

0000000080004392 <namei>:

struct inode*
namei(char *path)
{
    80004392:	1101                	addi	sp,sp,-32
    80004394:	ec06                	sd	ra,24(sp)
    80004396:	e822                	sd	s0,16(sp)
    80004398:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000439a:	fe040613          	addi	a2,s0,-32
    8000439e:	4581                	li	a1,0
    800043a0:	00000097          	auipc	ra,0x0
    800043a4:	dd0080e7          	jalr	-560(ra) # 80004170 <namex>
}
    800043a8:	60e2                	ld	ra,24(sp)
    800043aa:	6442                	ld	s0,16(sp)
    800043ac:	6105                	addi	sp,sp,32
    800043ae:	8082                	ret

00000000800043b0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800043b0:	1141                	addi	sp,sp,-16
    800043b2:	e406                	sd	ra,8(sp)
    800043b4:	e022                	sd	s0,0(sp)
    800043b6:	0800                	addi	s0,sp,16
    800043b8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800043ba:	4585                	li	a1,1
    800043bc:	00000097          	auipc	ra,0x0
    800043c0:	db4080e7          	jalr	-588(ra) # 80004170 <namex>
}
    800043c4:	60a2                	ld	ra,8(sp)
    800043c6:	6402                	ld	s0,0(sp)
    800043c8:	0141                	addi	sp,sp,16
    800043ca:	8082                	ret

00000000800043cc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800043cc:	1101                	addi	sp,sp,-32
    800043ce:	ec06                	sd	ra,24(sp)
    800043d0:	e822                	sd	s0,16(sp)
    800043d2:	e426                	sd	s1,8(sp)
    800043d4:	e04a                	sd	s2,0(sp)
    800043d6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800043d8:	00023917          	auipc	s2,0x23
    800043dc:	69890913          	addi	s2,s2,1688 # 80027a70 <log>
    800043e0:	01892583          	lw	a1,24(s2)
    800043e4:	02892503          	lw	a0,40(s2)
    800043e8:	fffff097          	auipc	ra,0xfffff
    800043ec:	ff0080e7          	jalr	-16(ra) # 800033d8 <bread>
    800043f0:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800043f2:	02c92683          	lw	a3,44(s2)
    800043f6:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800043f8:	02d05863          	blez	a3,80004428 <write_head+0x5c>
    800043fc:	00023797          	auipc	a5,0x23
    80004400:	6a478793          	addi	a5,a5,1700 # 80027aa0 <log+0x30>
    80004404:	05c50713          	addi	a4,a0,92
    80004408:	36fd                	addiw	a3,a3,-1
    8000440a:	02069613          	slli	a2,a3,0x20
    8000440e:	01e65693          	srli	a3,a2,0x1e
    80004412:	00023617          	auipc	a2,0x23
    80004416:	69260613          	addi	a2,a2,1682 # 80027aa4 <log+0x34>
    8000441a:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000441c:	4390                	lw	a2,0(a5)
    8000441e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004420:	0791                	addi	a5,a5,4
    80004422:	0711                	addi	a4,a4,4
    80004424:	fed79ce3          	bne	a5,a3,8000441c <write_head+0x50>
  }
  bwrite(buf);
    80004428:	8526                	mv	a0,s1
    8000442a:	fffff097          	auipc	ra,0xfffff
    8000442e:	0a0080e7          	jalr	160(ra) # 800034ca <bwrite>
  brelse(buf);
    80004432:	8526                	mv	a0,s1
    80004434:	fffff097          	auipc	ra,0xfffff
    80004438:	0d4080e7          	jalr	212(ra) # 80003508 <brelse>
}
    8000443c:	60e2                	ld	ra,24(sp)
    8000443e:	6442                	ld	s0,16(sp)
    80004440:	64a2                	ld	s1,8(sp)
    80004442:	6902                	ld	s2,0(sp)
    80004444:	6105                	addi	sp,sp,32
    80004446:	8082                	ret

0000000080004448 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004448:	00023797          	auipc	a5,0x23
    8000444c:	6547a783          	lw	a5,1620(a5) # 80027a9c <log+0x2c>
    80004450:	0af05d63          	blez	a5,8000450a <install_trans+0xc2>
{
    80004454:	7139                	addi	sp,sp,-64
    80004456:	fc06                	sd	ra,56(sp)
    80004458:	f822                	sd	s0,48(sp)
    8000445a:	f426                	sd	s1,40(sp)
    8000445c:	f04a                	sd	s2,32(sp)
    8000445e:	ec4e                	sd	s3,24(sp)
    80004460:	e852                	sd	s4,16(sp)
    80004462:	e456                	sd	s5,8(sp)
    80004464:	e05a                	sd	s6,0(sp)
    80004466:	0080                	addi	s0,sp,64
    80004468:	8b2a                	mv	s6,a0
    8000446a:	00023a97          	auipc	s5,0x23
    8000446e:	636a8a93          	addi	s5,s5,1590 # 80027aa0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004472:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004474:	00023997          	auipc	s3,0x23
    80004478:	5fc98993          	addi	s3,s3,1532 # 80027a70 <log>
    8000447c:	a00d                	j	8000449e <install_trans+0x56>
    brelse(lbuf);
    8000447e:	854a                	mv	a0,s2
    80004480:	fffff097          	auipc	ra,0xfffff
    80004484:	088080e7          	jalr	136(ra) # 80003508 <brelse>
    brelse(dbuf);
    80004488:	8526                	mv	a0,s1
    8000448a:	fffff097          	auipc	ra,0xfffff
    8000448e:	07e080e7          	jalr	126(ra) # 80003508 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004492:	2a05                	addiw	s4,s4,1
    80004494:	0a91                	addi	s5,s5,4
    80004496:	02c9a783          	lw	a5,44(s3)
    8000449a:	04fa5e63          	bge	s4,a5,800044f6 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000449e:	0189a583          	lw	a1,24(s3)
    800044a2:	014585bb          	addw	a1,a1,s4
    800044a6:	2585                	addiw	a1,a1,1
    800044a8:	0289a503          	lw	a0,40(s3)
    800044ac:	fffff097          	auipc	ra,0xfffff
    800044b0:	f2c080e7          	jalr	-212(ra) # 800033d8 <bread>
    800044b4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800044b6:	000aa583          	lw	a1,0(s5)
    800044ba:	0289a503          	lw	a0,40(s3)
    800044be:	fffff097          	auipc	ra,0xfffff
    800044c2:	f1a080e7          	jalr	-230(ra) # 800033d8 <bread>
    800044c6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800044c8:	40000613          	li	a2,1024
    800044cc:	05890593          	addi	a1,s2,88
    800044d0:	05850513          	addi	a0,a0,88
    800044d4:	ffffd097          	auipc	ra,0xffffd
    800044d8:	860080e7          	jalr	-1952(ra) # 80000d34 <memmove>
    bwrite(dbuf);  // write dst to disk
    800044dc:	8526                	mv	a0,s1
    800044de:	fffff097          	auipc	ra,0xfffff
    800044e2:	fec080e7          	jalr	-20(ra) # 800034ca <bwrite>
    if(recovering == 0)
    800044e6:	f80b1ce3          	bnez	s6,8000447e <install_trans+0x36>
      bunpin(dbuf);
    800044ea:	8526                	mv	a0,s1
    800044ec:	fffff097          	auipc	ra,0xfffff
    800044f0:	0f6080e7          	jalr	246(ra) # 800035e2 <bunpin>
    800044f4:	b769                	j	8000447e <install_trans+0x36>
}
    800044f6:	70e2                	ld	ra,56(sp)
    800044f8:	7442                	ld	s0,48(sp)
    800044fa:	74a2                	ld	s1,40(sp)
    800044fc:	7902                	ld	s2,32(sp)
    800044fe:	69e2                	ld	s3,24(sp)
    80004500:	6a42                	ld	s4,16(sp)
    80004502:	6aa2                	ld	s5,8(sp)
    80004504:	6b02                	ld	s6,0(sp)
    80004506:	6121                	addi	sp,sp,64
    80004508:	8082                	ret
    8000450a:	8082                	ret

000000008000450c <initlog>:
{
    8000450c:	7179                	addi	sp,sp,-48
    8000450e:	f406                	sd	ra,40(sp)
    80004510:	f022                	sd	s0,32(sp)
    80004512:	ec26                	sd	s1,24(sp)
    80004514:	e84a                	sd	s2,16(sp)
    80004516:	e44e                	sd	s3,8(sp)
    80004518:	1800                	addi	s0,sp,48
    8000451a:	892a                	mv	s2,a0
    8000451c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000451e:	00023497          	auipc	s1,0x23
    80004522:	55248493          	addi	s1,s1,1362 # 80027a70 <log>
    80004526:	00004597          	auipc	a1,0x4
    8000452a:	1b258593          	addi	a1,a1,434 # 800086d8 <syscalls+0x1f0>
    8000452e:	8526                	mv	a0,s1
    80004530:	ffffc097          	auipc	ra,0xffffc
    80004534:	606080e7          	jalr	1542(ra) # 80000b36 <initlock>
  log.start = sb->logstart;
    80004538:	0149a583          	lw	a1,20(s3)
    8000453c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000453e:	0109a783          	lw	a5,16(s3)
    80004542:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004544:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004548:	854a                	mv	a0,s2
    8000454a:	fffff097          	auipc	ra,0xfffff
    8000454e:	e8e080e7          	jalr	-370(ra) # 800033d8 <bread>
  log.lh.n = lh->n;
    80004552:	4d34                	lw	a3,88(a0)
    80004554:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004556:	02d05663          	blez	a3,80004582 <initlog+0x76>
    8000455a:	05c50793          	addi	a5,a0,92
    8000455e:	00023717          	auipc	a4,0x23
    80004562:	54270713          	addi	a4,a4,1346 # 80027aa0 <log+0x30>
    80004566:	36fd                	addiw	a3,a3,-1
    80004568:	02069613          	slli	a2,a3,0x20
    8000456c:	01e65693          	srli	a3,a2,0x1e
    80004570:	06050613          	addi	a2,a0,96
    80004574:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004576:	4390                	lw	a2,0(a5)
    80004578:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000457a:	0791                	addi	a5,a5,4
    8000457c:	0711                	addi	a4,a4,4
    8000457e:	fed79ce3          	bne	a5,a3,80004576 <initlog+0x6a>
  brelse(buf);
    80004582:	fffff097          	auipc	ra,0xfffff
    80004586:	f86080e7          	jalr	-122(ra) # 80003508 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000458a:	4505                	li	a0,1
    8000458c:	00000097          	auipc	ra,0x0
    80004590:	ebc080e7          	jalr	-324(ra) # 80004448 <install_trans>
  log.lh.n = 0;
    80004594:	00023797          	auipc	a5,0x23
    80004598:	5007a423          	sw	zero,1288(a5) # 80027a9c <log+0x2c>
  write_head(); // clear the log
    8000459c:	00000097          	auipc	ra,0x0
    800045a0:	e30080e7          	jalr	-464(ra) # 800043cc <write_head>
}
    800045a4:	70a2                	ld	ra,40(sp)
    800045a6:	7402                	ld	s0,32(sp)
    800045a8:	64e2                	ld	s1,24(sp)
    800045aa:	6942                	ld	s2,16(sp)
    800045ac:	69a2                	ld	s3,8(sp)
    800045ae:	6145                	addi	sp,sp,48
    800045b0:	8082                	ret

00000000800045b2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800045b2:	1101                	addi	sp,sp,-32
    800045b4:	ec06                	sd	ra,24(sp)
    800045b6:	e822                	sd	s0,16(sp)
    800045b8:	e426                	sd	s1,8(sp)
    800045ba:	e04a                	sd	s2,0(sp)
    800045bc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800045be:	00023517          	auipc	a0,0x23
    800045c2:	4b250513          	addi	a0,a0,1202 # 80027a70 <log>
    800045c6:	ffffc097          	auipc	ra,0xffffc
    800045ca:	600080e7          	jalr	1536(ra) # 80000bc6 <acquire>
  while(1){
    if(log.committing){
    800045ce:	00023497          	auipc	s1,0x23
    800045d2:	4a248493          	addi	s1,s1,1186 # 80027a70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045d6:	4979                	li	s2,30
    800045d8:	a039                	j	800045e6 <begin_op+0x34>
      sleep(&log, &log.lock);
    800045da:	85a6                	mv	a1,s1
    800045dc:	8526                	mv	a0,s1
    800045de:	ffffe097          	auipc	ra,0xffffe
    800045e2:	aec080e7          	jalr	-1300(ra) # 800020ca <sleep>
    if(log.committing){
    800045e6:	50dc                	lw	a5,36(s1)
    800045e8:	fbed                	bnez	a5,800045da <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045ea:	509c                	lw	a5,32(s1)
    800045ec:	0017871b          	addiw	a4,a5,1
    800045f0:	0007069b          	sext.w	a3,a4
    800045f4:	0027179b          	slliw	a5,a4,0x2
    800045f8:	9fb9                	addw	a5,a5,a4
    800045fa:	0017979b          	slliw	a5,a5,0x1
    800045fe:	54d8                	lw	a4,44(s1)
    80004600:	9fb9                	addw	a5,a5,a4
    80004602:	00f95963          	bge	s2,a5,80004614 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004606:	85a6                	mv	a1,s1
    80004608:	8526                	mv	a0,s1
    8000460a:	ffffe097          	auipc	ra,0xffffe
    8000460e:	ac0080e7          	jalr	-1344(ra) # 800020ca <sleep>
    80004612:	bfd1                	j	800045e6 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004614:	00023517          	auipc	a0,0x23
    80004618:	45c50513          	addi	a0,a0,1116 # 80027a70 <log>
    8000461c:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000461e:	ffffc097          	auipc	ra,0xffffc
    80004622:	672080e7          	jalr	1650(ra) # 80000c90 <release>
      break;
    }
  }
}
    80004626:	60e2                	ld	ra,24(sp)
    80004628:	6442                	ld	s0,16(sp)
    8000462a:	64a2                	ld	s1,8(sp)
    8000462c:	6902                	ld	s2,0(sp)
    8000462e:	6105                	addi	sp,sp,32
    80004630:	8082                	ret

0000000080004632 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004632:	7139                	addi	sp,sp,-64
    80004634:	fc06                	sd	ra,56(sp)
    80004636:	f822                	sd	s0,48(sp)
    80004638:	f426                	sd	s1,40(sp)
    8000463a:	f04a                	sd	s2,32(sp)
    8000463c:	ec4e                	sd	s3,24(sp)
    8000463e:	e852                	sd	s4,16(sp)
    80004640:	e456                	sd	s5,8(sp)
    80004642:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004644:	00023497          	auipc	s1,0x23
    80004648:	42c48493          	addi	s1,s1,1068 # 80027a70 <log>
    8000464c:	8526                	mv	a0,s1
    8000464e:	ffffc097          	auipc	ra,0xffffc
    80004652:	578080e7          	jalr	1400(ra) # 80000bc6 <acquire>
  log.outstanding -= 1;
    80004656:	509c                	lw	a5,32(s1)
    80004658:	37fd                	addiw	a5,a5,-1
    8000465a:	0007891b          	sext.w	s2,a5
    8000465e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004660:	50dc                	lw	a5,36(s1)
    80004662:	e7b9                	bnez	a5,800046b0 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004664:	04091e63          	bnez	s2,800046c0 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004668:	00023497          	auipc	s1,0x23
    8000466c:	40848493          	addi	s1,s1,1032 # 80027a70 <log>
    80004670:	4785                	li	a5,1
    80004672:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004674:	8526                	mv	a0,s1
    80004676:	ffffc097          	auipc	ra,0xffffc
    8000467a:	61a080e7          	jalr	1562(ra) # 80000c90 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000467e:	54dc                	lw	a5,44(s1)
    80004680:	06f04763          	bgtz	a5,800046ee <end_op+0xbc>
    acquire(&log.lock);
    80004684:	00023497          	auipc	s1,0x23
    80004688:	3ec48493          	addi	s1,s1,1004 # 80027a70 <log>
    8000468c:	8526                	mv	a0,s1
    8000468e:	ffffc097          	auipc	ra,0xffffc
    80004692:	538080e7          	jalr	1336(ra) # 80000bc6 <acquire>
    log.committing = 0;
    80004696:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000469a:	8526                	mv	a0,s1
    8000469c:	ffffe097          	auipc	ra,0xffffe
    800046a0:	bbc080e7          	jalr	-1092(ra) # 80002258 <wakeup>
    release(&log.lock);
    800046a4:	8526                	mv	a0,s1
    800046a6:	ffffc097          	auipc	ra,0xffffc
    800046aa:	5ea080e7          	jalr	1514(ra) # 80000c90 <release>
}
    800046ae:	a03d                	j	800046dc <end_op+0xaa>
    panic("log.committing");
    800046b0:	00004517          	auipc	a0,0x4
    800046b4:	03050513          	addi	a0,a0,48 # 800086e0 <syscalls+0x1f8>
    800046b8:	ffffc097          	auipc	ra,0xffffc
    800046bc:	e76080e7          	jalr	-394(ra) # 8000052e <panic>
    wakeup(&log);
    800046c0:	00023497          	auipc	s1,0x23
    800046c4:	3b048493          	addi	s1,s1,944 # 80027a70 <log>
    800046c8:	8526                	mv	a0,s1
    800046ca:	ffffe097          	auipc	ra,0xffffe
    800046ce:	b8e080e7          	jalr	-1138(ra) # 80002258 <wakeup>
  release(&log.lock);
    800046d2:	8526                	mv	a0,s1
    800046d4:	ffffc097          	auipc	ra,0xffffc
    800046d8:	5bc080e7          	jalr	1468(ra) # 80000c90 <release>
}
    800046dc:	70e2                	ld	ra,56(sp)
    800046de:	7442                	ld	s0,48(sp)
    800046e0:	74a2                	ld	s1,40(sp)
    800046e2:	7902                	ld	s2,32(sp)
    800046e4:	69e2                	ld	s3,24(sp)
    800046e6:	6a42                	ld	s4,16(sp)
    800046e8:	6aa2                	ld	s5,8(sp)
    800046ea:	6121                	addi	sp,sp,64
    800046ec:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800046ee:	00023a97          	auipc	s5,0x23
    800046f2:	3b2a8a93          	addi	s5,s5,946 # 80027aa0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800046f6:	00023a17          	auipc	s4,0x23
    800046fa:	37aa0a13          	addi	s4,s4,890 # 80027a70 <log>
    800046fe:	018a2583          	lw	a1,24(s4)
    80004702:	012585bb          	addw	a1,a1,s2
    80004706:	2585                	addiw	a1,a1,1
    80004708:	028a2503          	lw	a0,40(s4)
    8000470c:	fffff097          	auipc	ra,0xfffff
    80004710:	ccc080e7          	jalr	-820(ra) # 800033d8 <bread>
    80004714:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004716:	000aa583          	lw	a1,0(s5)
    8000471a:	028a2503          	lw	a0,40(s4)
    8000471e:	fffff097          	auipc	ra,0xfffff
    80004722:	cba080e7          	jalr	-838(ra) # 800033d8 <bread>
    80004726:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004728:	40000613          	li	a2,1024
    8000472c:	05850593          	addi	a1,a0,88
    80004730:	05848513          	addi	a0,s1,88
    80004734:	ffffc097          	auipc	ra,0xffffc
    80004738:	600080e7          	jalr	1536(ra) # 80000d34 <memmove>
    bwrite(to);  // write the log
    8000473c:	8526                	mv	a0,s1
    8000473e:	fffff097          	auipc	ra,0xfffff
    80004742:	d8c080e7          	jalr	-628(ra) # 800034ca <bwrite>
    brelse(from);
    80004746:	854e                	mv	a0,s3
    80004748:	fffff097          	auipc	ra,0xfffff
    8000474c:	dc0080e7          	jalr	-576(ra) # 80003508 <brelse>
    brelse(to);
    80004750:	8526                	mv	a0,s1
    80004752:	fffff097          	auipc	ra,0xfffff
    80004756:	db6080e7          	jalr	-586(ra) # 80003508 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000475a:	2905                	addiw	s2,s2,1
    8000475c:	0a91                	addi	s5,s5,4
    8000475e:	02ca2783          	lw	a5,44(s4)
    80004762:	f8f94ee3          	blt	s2,a5,800046fe <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004766:	00000097          	auipc	ra,0x0
    8000476a:	c66080e7          	jalr	-922(ra) # 800043cc <write_head>
    install_trans(0); // Now install writes to home locations
    8000476e:	4501                	li	a0,0
    80004770:	00000097          	auipc	ra,0x0
    80004774:	cd8080e7          	jalr	-808(ra) # 80004448 <install_trans>
    log.lh.n = 0;
    80004778:	00023797          	auipc	a5,0x23
    8000477c:	3207a223          	sw	zero,804(a5) # 80027a9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004780:	00000097          	auipc	ra,0x0
    80004784:	c4c080e7          	jalr	-948(ra) # 800043cc <write_head>
    80004788:	bdf5                	j	80004684 <end_op+0x52>

000000008000478a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000478a:	1101                	addi	sp,sp,-32
    8000478c:	ec06                	sd	ra,24(sp)
    8000478e:	e822                	sd	s0,16(sp)
    80004790:	e426                	sd	s1,8(sp)
    80004792:	e04a                	sd	s2,0(sp)
    80004794:	1000                	addi	s0,sp,32
    80004796:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004798:	00023917          	auipc	s2,0x23
    8000479c:	2d890913          	addi	s2,s2,728 # 80027a70 <log>
    800047a0:	854a                	mv	a0,s2
    800047a2:	ffffc097          	auipc	ra,0xffffc
    800047a6:	424080e7          	jalr	1060(ra) # 80000bc6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800047aa:	02c92603          	lw	a2,44(s2)
    800047ae:	47f5                	li	a5,29
    800047b0:	06c7c563          	blt	a5,a2,8000481a <log_write+0x90>
    800047b4:	00023797          	auipc	a5,0x23
    800047b8:	2d87a783          	lw	a5,728(a5) # 80027a8c <log+0x1c>
    800047bc:	37fd                	addiw	a5,a5,-1
    800047be:	04f65e63          	bge	a2,a5,8000481a <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800047c2:	00023797          	auipc	a5,0x23
    800047c6:	2ce7a783          	lw	a5,718(a5) # 80027a90 <log+0x20>
    800047ca:	06f05063          	blez	a5,8000482a <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800047ce:	4781                	li	a5,0
    800047d0:	06c05563          	blez	a2,8000483a <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800047d4:	44cc                	lw	a1,12(s1)
    800047d6:	00023717          	auipc	a4,0x23
    800047da:	2ca70713          	addi	a4,a4,714 # 80027aa0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800047de:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800047e0:	4314                	lw	a3,0(a4)
    800047e2:	04b68c63          	beq	a3,a1,8000483a <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800047e6:	2785                	addiw	a5,a5,1
    800047e8:	0711                	addi	a4,a4,4
    800047ea:	fef61be3          	bne	a2,a5,800047e0 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800047ee:	0621                	addi	a2,a2,8
    800047f0:	060a                	slli	a2,a2,0x2
    800047f2:	00023797          	auipc	a5,0x23
    800047f6:	27e78793          	addi	a5,a5,638 # 80027a70 <log>
    800047fa:	963e                	add	a2,a2,a5
    800047fc:	44dc                	lw	a5,12(s1)
    800047fe:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004800:	8526                	mv	a0,s1
    80004802:	fffff097          	auipc	ra,0xfffff
    80004806:	da4080e7          	jalr	-604(ra) # 800035a6 <bpin>
    log.lh.n++;
    8000480a:	00023717          	auipc	a4,0x23
    8000480e:	26670713          	addi	a4,a4,614 # 80027a70 <log>
    80004812:	575c                	lw	a5,44(a4)
    80004814:	2785                	addiw	a5,a5,1
    80004816:	d75c                	sw	a5,44(a4)
    80004818:	a835                	j	80004854 <log_write+0xca>
    panic("too big a transaction");
    8000481a:	00004517          	auipc	a0,0x4
    8000481e:	ed650513          	addi	a0,a0,-298 # 800086f0 <syscalls+0x208>
    80004822:	ffffc097          	auipc	ra,0xffffc
    80004826:	d0c080e7          	jalr	-756(ra) # 8000052e <panic>
    panic("log_write outside of trans");
    8000482a:	00004517          	auipc	a0,0x4
    8000482e:	ede50513          	addi	a0,a0,-290 # 80008708 <syscalls+0x220>
    80004832:	ffffc097          	auipc	ra,0xffffc
    80004836:	cfc080e7          	jalr	-772(ra) # 8000052e <panic>
  log.lh.block[i] = b->blockno;
    8000483a:	00878713          	addi	a4,a5,8
    8000483e:	00271693          	slli	a3,a4,0x2
    80004842:	00023717          	auipc	a4,0x23
    80004846:	22e70713          	addi	a4,a4,558 # 80027a70 <log>
    8000484a:	9736                	add	a4,a4,a3
    8000484c:	44d4                	lw	a3,12(s1)
    8000484e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004850:	faf608e3          	beq	a2,a5,80004800 <log_write+0x76>
  }
  release(&log.lock);
    80004854:	00023517          	auipc	a0,0x23
    80004858:	21c50513          	addi	a0,a0,540 # 80027a70 <log>
    8000485c:	ffffc097          	auipc	ra,0xffffc
    80004860:	434080e7          	jalr	1076(ra) # 80000c90 <release>
}
    80004864:	60e2                	ld	ra,24(sp)
    80004866:	6442                	ld	s0,16(sp)
    80004868:	64a2                	ld	s1,8(sp)
    8000486a:	6902                	ld	s2,0(sp)
    8000486c:	6105                	addi	sp,sp,32
    8000486e:	8082                	ret

0000000080004870 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004870:	1101                	addi	sp,sp,-32
    80004872:	ec06                	sd	ra,24(sp)
    80004874:	e822                	sd	s0,16(sp)
    80004876:	e426                	sd	s1,8(sp)
    80004878:	e04a                	sd	s2,0(sp)
    8000487a:	1000                	addi	s0,sp,32
    8000487c:	84aa                	mv	s1,a0
    8000487e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004880:	00004597          	auipc	a1,0x4
    80004884:	ea858593          	addi	a1,a1,-344 # 80008728 <syscalls+0x240>
    80004888:	0521                	addi	a0,a0,8
    8000488a:	ffffc097          	auipc	ra,0xffffc
    8000488e:	2ac080e7          	jalr	684(ra) # 80000b36 <initlock>
  lk->name = name;
    80004892:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004896:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000489a:	0204a423          	sw	zero,40(s1)
}
    8000489e:	60e2                	ld	ra,24(sp)
    800048a0:	6442                	ld	s0,16(sp)
    800048a2:	64a2                	ld	s1,8(sp)
    800048a4:	6902                	ld	s2,0(sp)
    800048a6:	6105                	addi	sp,sp,32
    800048a8:	8082                	ret

00000000800048aa <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800048aa:	1101                	addi	sp,sp,-32
    800048ac:	ec06                	sd	ra,24(sp)
    800048ae:	e822                	sd	s0,16(sp)
    800048b0:	e426                	sd	s1,8(sp)
    800048b2:	e04a                	sd	s2,0(sp)
    800048b4:	1000                	addi	s0,sp,32
    800048b6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048b8:	00850913          	addi	s2,a0,8
    800048bc:	854a                	mv	a0,s2
    800048be:	ffffc097          	auipc	ra,0xffffc
    800048c2:	308080e7          	jalr	776(ra) # 80000bc6 <acquire>
  while (lk->locked) {
    800048c6:	409c                	lw	a5,0(s1)
    800048c8:	cb89                	beqz	a5,800048da <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800048ca:	85ca                	mv	a1,s2
    800048cc:	8526                	mv	a0,s1
    800048ce:	ffffd097          	auipc	ra,0xffffd
    800048d2:	7fc080e7          	jalr	2044(ra) # 800020ca <sleep>
  while (lk->locked) {
    800048d6:	409c                	lw	a5,0(s1)
    800048d8:	fbed                	bnez	a5,800048ca <acquiresleep+0x20>
  }
  lk->locked = 1;
    800048da:	4785                	li	a5,1
    800048dc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800048de:	ffffd097          	auipc	ra,0xffffd
    800048e2:	0ba080e7          	jalr	186(ra) # 80001998 <myproc>
    800048e6:	591c                	lw	a5,48(a0)
    800048e8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800048ea:	854a                	mv	a0,s2
    800048ec:	ffffc097          	auipc	ra,0xffffc
    800048f0:	3a4080e7          	jalr	932(ra) # 80000c90 <release>
}
    800048f4:	60e2                	ld	ra,24(sp)
    800048f6:	6442                	ld	s0,16(sp)
    800048f8:	64a2                	ld	s1,8(sp)
    800048fa:	6902                	ld	s2,0(sp)
    800048fc:	6105                	addi	sp,sp,32
    800048fe:	8082                	ret

0000000080004900 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004900:	1101                	addi	sp,sp,-32
    80004902:	ec06                	sd	ra,24(sp)
    80004904:	e822                	sd	s0,16(sp)
    80004906:	e426                	sd	s1,8(sp)
    80004908:	e04a                	sd	s2,0(sp)
    8000490a:	1000                	addi	s0,sp,32
    8000490c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000490e:	00850913          	addi	s2,a0,8
    80004912:	854a                	mv	a0,s2
    80004914:	ffffc097          	auipc	ra,0xffffc
    80004918:	2b2080e7          	jalr	690(ra) # 80000bc6 <acquire>
  lk->locked = 0;
    8000491c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004920:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004924:	8526                	mv	a0,s1
    80004926:	ffffe097          	auipc	ra,0xffffe
    8000492a:	932080e7          	jalr	-1742(ra) # 80002258 <wakeup>
  release(&lk->lk);
    8000492e:	854a                	mv	a0,s2
    80004930:	ffffc097          	auipc	ra,0xffffc
    80004934:	360080e7          	jalr	864(ra) # 80000c90 <release>
}
    80004938:	60e2                	ld	ra,24(sp)
    8000493a:	6442                	ld	s0,16(sp)
    8000493c:	64a2                	ld	s1,8(sp)
    8000493e:	6902                	ld	s2,0(sp)
    80004940:	6105                	addi	sp,sp,32
    80004942:	8082                	ret

0000000080004944 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004944:	7179                	addi	sp,sp,-48
    80004946:	f406                	sd	ra,40(sp)
    80004948:	f022                	sd	s0,32(sp)
    8000494a:	ec26                	sd	s1,24(sp)
    8000494c:	e84a                	sd	s2,16(sp)
    8000494e:	e44e                	sd	s3,8(sp)
    80004950:	1800                	addi	s0,sp,48
    80004952:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004954:	00850913          	addi	s2,a0,8
    80004958:	854a                	mv	a0,s2
    8000495a:	ffffc097          	auipc	ra,0xffffc
    8000495e:	26c080e7          	jalr	620(ra) # 80000bc6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004962:	409c                	lw	a5,0(s1)
    80004964:	ef99                	bnez	a5,80004982 <holdingsleep+0x3e>
    80004966:	4481                	li	s1,0
  release(&lk->lk);
    80004968:	854a                	mv	a0,s2
    8000496a:	ffffc097          	auipc	ra,0xffffc
    8000496e:	326080e7          	jalr	806(ra) # 80000c90 <release>
  return r;
}
    80004972:	8526                	mv	a0,s1
    80004974:	70a2                	ld	ra,40(sp)
    80004976:	7402                	ld	s0,32(sp)
    80004978:	64e2                	ld	s1,24(sp)
    8000497a:	6942                	ld	s2,16(sp)
    8000497c:	69a2                	ld	s3,8(sp)
    8000497e:	6145                	addi	sp,sp,48
    80004980:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004982:	0284a983          	lw	s3,40(s1)
    80004986:	ffffd097          	auipc	ra,0xffffd
    8000498a:	012080e7          	jalr	18(ra) # 80001998 <myproc>
    8000498e:	5904                	lw	s1,48(a0)
    80004990:	413484b3          	sub	s1,s1,s3
    80004994:	0014b493          	seqz	s1,s1
    80004998:	bfc1                	j	80004968 <holdingsleep+0x24>

000000008000499a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000499a:	1141                	addi	sp,sp,-16
    8000499c:	e406                	sd	ra,8(sp)
    8000499e:	e022                	sd	s0,0(sp)
    800049a0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800049a2:	00004597          	auipc	a1,0x4
    800049a6:	d9658593          	addi	a1,a1,-618 # 80008738 <syscalls+0x250>
    800049aa:	00023517          	auipc	a0,0x23
    800049ae:	20e50513          	addi	a0,a0,526 # 80027bb8 <ftable>
    800049b2:	ffffc097          	auipc	ra,0xffffc
    800049b6:	184080e7          	jalr	388(ra) # 80000b36 <initlock>
}
    800049ba:	60a2                	ld	ra,8(sp)
    800049bc:	6402                	ld	s0,0(sp)
    800049be:	0141                	addi	sp,sp,16
    800049c0:	8082                	ret

00000000800049c2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800049c2:	1101                	addi	sp,sp,-32
    800049c4:	ec06                	sd	ra,24(sp)
    800049c6:	e822                	sd	s0,16(sp)
    800049c8:	e426                	sd	s1,8(sp)
    800049ca:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800049cc:	00023517          	auipc	a0,0x23
    800049d0:	1ec50513          	addi	a0,a0,492 # 80027bb8 <ftable>
    800049d4:	ffffc097          	auipc	ra,0xffffc
    800049d8:	1f2080e7          	jalr	498(ra) # 80000bc6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049dc:	00023497          	auipc	s1,0x23
    800049e0:	1f448493          	addi	s1,s1,500 # 80027bd0 <ftable+0x18>
    800049e4:	00024717          	auipc	a4,0x24
    800049e8:	18c70713          	addi	a4,a4,396 # 80028b70 <ftable+0xfb8>
    if(f->ref == 0){
    800049ec:	40dc                	lw	a5,4(s1)
    800049ee:	cf99                	beqz	a5,80004a0c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049f0:	02848493          	addi	s1,s1,40
    800049f4:	fee49ce3          	bne	s1,a4,800049ec <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800049f8:	00023517          	auipc	a0,0x23
    800049fc:	1c050513          	addi	a0,a0,448 # 80027bb8 <ftable>
    80004a00:	ffffc097          	auipc	ra,0xffffc
    80004a04:	290080e7          	jalr	656(ra) # 80000c90 <release>
  return 0;
    80004a08:	4481                	li	s1,0
    80004a0a:	a819                	j	80004a20 <filealloc+0x5e>
      f->ref = 1;
    80004a0c:	4785                	li	a5,1
    80004a0e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a10:	00023517          	auipc	a0,0x23
    80004a14:	1a850513          	addi	a0,a0,424 # 80027bb8 <ftable>
    80004a18:	ffffc097          	auipc	ra,0xffffc
    80004a1c:	278080e7          	jalr	632(ra) # 80000c90 <release>
}
    80004a20:	8526                	mv	a0,s1
    80004a22:	60e2                	ld	ra,24(sp)
    80004a24:	6442                	ld	s0,16(sp)
    80004a26:	64a2                	ld	s1,8(sp)
    80004a28:	6105                	addi	sp,sp,32
    80004a2a:	8082                	ret

0000000080004a2c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a2c:	1101                	addi	sp,sp,-32
    80004a2e:	ec06                	sd	ra,24(sp)
    80004a30:	e822                	sd	s0,16(sp)
    80004a32:	e426                	sd	s1,8(sp)
    80004a34:	1000                	addi	s0,sp,32
    80004a36:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a38:	00023517          	auipc	a0,0x23
    80004a3c:	18050513          	addi	a0,a0,384 # 80027bb8 <ftable>
    80004a40:	ffffc097          	auipc	ra,0xffffc
    80004a44:	186080e7          	jalr	390(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    80004a48:	40dc                	lw	a5,4(s1)
    80004a4a:	02f05263          	blez	a5,80004a6e <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004a4e:	2785                	addiw	a5,a5,1
    80004a50:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a52:	00023517          	auipc	a0,0x23
    80004a56:	16650513          	addi	a0,a0,358 # 80027bb8 <ftable>
    80004a5a:	ffffc097          	auipc	ra,0xffffc
    80004a5e:	236080e7          	jalr	566(ra) # 80000c90 <release>
  return f;
}
    80004a62:	8526                	mv	a0,s1
    80004a64:	60e2                	ld	ra,24(sp)
    80004a66:	6442                	ld	s0,16(sp)
    80004a68:	64a2                	ld	s1,8(sp)
    80004a6a:	6105                	addi	sp,sp,32
    80004a6c:	8082                	ret
    panic("filedup");
    80004a6e:	00004517          	auipc	a0,0x4
    80004a72:	cd250513          	addi	a0,a0,-814 # 80008740 <syscalls+0x258>
    80004a76:	ffffc097          	auipc	ra,0xffffc
    80004a7a:	ab8080e7          	jalr	-1352(ra) # 8000052e <panic>

0000000080004a7e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a7e:	7139                	addi	sp,sp,-64
    80004a80:	fc06                	sd	ra,56(sp)
    80004a82:	f822                	sd	s0,48(sp)
    80004a84:	f426                	sd	s1,40(sp)
    80004a86:	f04a                	sd	s2,32(sp)
    80004a88:	ec4e                	sd	s3,24(sp)
    80004a8a:	e852                	sd	s4,16(sp)
    80004a8c:	e456                	sd	s5,8(sp)
    80004a8e:	0080                	addi	s0,sp,64
    80004a90:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a92:	00023517          	auipc	a0,0x23
    80004a96:	12650513          	addi	a0,a0,294 # 80027bb8 <ftable>
    80004a9a:	ffffc097          	auipc	ra,0xffffc
    80004a9e:	12c080e7          	jalr	300(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    80004aa2:	40dc                	lw	a5,4(s1)
    80004aa4:	06f05163          	blez	a5,80004b06 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004aa8:	37fd                	addiw	a5,a5,-1
    80004aaa:	0007871b          	sext.w	a4,a5
    80004aae:	c0dc                	sw	a5,4(s1)
    80004ab0:	06e04363          	bgtz	a4,80004b16 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004ab4:	0004a903          	lw	s2,0(s1)
    80004ab8:	0094ca83          	lbu	s5,9(s1)
    80004abc:	0104ba03          	ld	s4,16(s1)
    80004ac0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004ac4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004ac8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004acc:	00023517          	auipc	a0,0x23
    80004ad0:	0ec50513          	addi	a0,a0,236 # 80027bb8 <ftable>
    80004ad4:	ffffc097          	auipc	ra,0xffffc
    80004ad8:	1bc080e7          	jalr	444(ra) # 80000c90 <release>

  if(ff.type == FD_PIPE){
    80004adc:	4785                	li	a5,1
    80004ade:	04f90d63          	beq	s2,a5,80004b38 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004ae2:	3979                	addiw	s2,s2,-2
    80004ae4:	4785                	li	a5,1
    80004ae6:	0527e063          	bltu	a5,s2,80004b26 <fileclose+0xa8>
    begin_op();
    80004aea:	00000097          	auipc	ra,0x0
    80004aee:	ac8080e7          	jalr	-1336(ra) # 800045b2 <begin_op>
    iput(ff.ip);
    80004af2:	854e                	mv	a0,s3
    80004af4:	fffff097          	auipc	ra,0xfffff
    80004af8:	2a2080e7          	jalr	674(ra) # 80003d96 <iput>
    end_op();
    80004afc:	00000097          	auipc	ra,0x0
    80004b00:	b36080e7          	jalr	-1226(ra) # 80004632 <end_op>
    80004b04:	a00d                	j	80004b26 <fileclose+0xa8>
    panic("fileclose");
    80004b06:	00004517          	auipc	a0,0x4
    80004b0a:	c4250513          	addi	a0,a0,-958 # 80008748 <syscalls+0x260>
    80004b0e:	ffffc097          	auipc	ra,0xffffc
    80004b12:	a20080e7          	jalr	-1504(ra) # 8000052e <panic>
    release(&ftable.lock);
    80004b16:	00023517          	auipc	a0,0x23
    80004b1a:	0a250513          	addi	a0,a0,162 # 80027bb8 <ftable>
    80004b1e:	ffffc097          	auipc	ra,0xffffc
    80004b22:	172080e7          	jalr	370(ra) # 80000c90 <release>
  }
}
    80004b26:	70e2                	ld	ra,56(sp)
    80004b28:	7442                	ld	s0,48(sp)
    80004b2a:	74a2                	ld	s1,40(sp)
    80004b2c:	7902                	ld	s2,32(sp)
    80004b2e:	69e2                	ld	s3,24(sp)
    80004b30:	6a42                	ld	s4,16(sp)
    80004b32:	6aa2                	ld	s5,8(sp)
    80004b34:	6121                	addi	sp,sp,64
    80004b36:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b38:	85d6                	mv	a1,s5
    80004b3a:	8552                	mv	a0,s4
    80004b3c:	00000097          	auipc	ra,0x0
    80004b40:	34c080e7          	jalr	844(ra) # 80004e88 <pipeclose>
    80004b44:	b7cd                	j	80004b26 <fileclose+0xa8>

0000000080004b46 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b46:	715d                	addi	sp,sp,-80
    80004b48:	e486                	sd	ra,72(sp)
    80004b4a:	e0a2                	sd	s0,64(sp)
    80004b4c:	fc26                	sd	s1,56(sp)
    80004b4e:	f84a                	sd	s2,48(sp)
    80004b50:	f44e                	sd	s3,40(sp)
    80004b52:	0880                	addi	s0,sp,80
    80004b54:	84aa                	mv	s1,a0
    80004b56:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004b58:	ffffd097          	auipc	ra,0xffffd
    80004b5c:	e40080e7          	jalr	-448(ra) # 80001998 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b60:	409c                	lw	a5,0(s1)
    80004b62:	37f9                	addiw	a5,a5,-2
    80004b64:	4705                	li	a4,1
    80004b66:	04f76763          	bltu	a4,a5,80004bb4 <filestat+0x6e>
    80004b6a:	892a                	mv	s2,a0
    ilock(f->ip);
    80004b6c:	6c88                	ld	a0,24(s1)
    80004b6e:	fffff097          	auipc	ra,0xfffff
    80004b72:	06e080e7          	jalr	110(ra) # 80003bdc <ilock>
    stati(f->ip, &st);
    80004b76:	fb840593          	addi	a1,s0,-72
    80004b7a:	6c88                	ld	a0,24(s1)
    80004b7c:	fffff097          	auipc	ra,0xfffff
    80004b80:	2ea080e7          	jalr	746(ra) # 80003e66 <stati>
    iunlock(f->ip);
    80004b84:	6c88                	ld	a0,24(s1)
    80004b86:	fffff097          	auipc	ra,0xfffff
    80004b8a:	118080e7          	jalr	280(ra) # 80003c9e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b8e:	46e1                	li	a3,24
    80004b90:	fb840613          	addi	a2,s0,-72
    80004b94:	85ce                	mv	a1,s3
    80004b96:	05093503          	ld	a0,80(s2)
    80004b9a:	ffffd097          	auipc	ra,0xffffd
    80004b9e:	abe080e7          	jalr	-1346(ra) # 80001658 <copyout>
    80004ba2:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004ba6:	60a6                	ld	ra,72(sp)
    80004ba8:	6406                	ld	s0,64(sp)
    80004baa:	74e2                	ld	s1,56(sp)
    80004bac:	7942                	ld	s2,48(sp)
    80004bae:	79a2                	ld	s3,40(sp)
    80004bb0:	6161                	addi	sp,sp,80
    80004bb2:	8082                	ret
  return -1;
    80004bb4:	557d                	li	a0,-1
    80004bb6:	bfc5                	j	80004ba6 <filestat+0x60>

0000000080004bb8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004bb8:	7179                	addi	sp,sp,-48
    80004bba:	f406                	sd	ra,40(sp)
    80004bbc:	f022                	sd	s0,32(sp)
    80004bbe:	ec26                	sd	s1,24(sp)
    80004bc0:	e84a                	sd	s2,16(sp)
    80004bc2:	e44e                	sd	s3,8(sp)
    80004bc4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004bc6:	00854783          	lbu	a5,8(a0)
    80004bca:	c3d5                	beqz	a5,80004c6e <fileread+0xb6>
    80004bcc:	84aa                	mv	s1,a0
    80004bce:	89ae                	mv	s3,a1
    80004bd0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bd2:	411c                	lw	a5,0(a0)
    80004bd4:	4705                	li	a4,1
    80004bd6:	04e78963          	beq	a5,a4,80004c28 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bda:	470d                	li	a4,3
    80004bdc:	04e78d63          	beq	a5,a4,80004c36 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004be0:	4709                	li	a4,2
    80004be2:	06e79e63          	bne	a5,a4,80004c5e <fileread+0xa6>
    ilock(f->ip);
    80004be6:	6d08                	ld	a0,24(a0)
    80004be8:	fffff097          	auipc	ra,0xfffff
    80004bec:	ff4080e7          	jalr	-12(ra) # 80003bdc <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004bf0:	874a                	mv	a4,s2
    80004bf2:	5094                	lw	a3,32(s1)
    80004bf4:	864e                	mv	a2,s3
    80004bf6:	4585                	li	a1,1
    80004bf8:	6c88                	ld	a0,24(s1)
    80004bfa:	fffff097          	auipc	ra,0xfffff
    80004bfe:	296080e7          	jalr	662(ra) # 80003e90 <readi>
    80004c02:	892a                	mv	s2,a0
    80004c04:	00a05563          	blez	a0,80004c0e <fileread+0x56>
      f->off += r;
    80004c08:	509c                	lw	a5,32(s1)
    80004c0a:	9fa9                	addw	a5,a5,a0
    80004c0c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c0e:	6c88                	ld	a0,24(s1)
    80004c10:	fffff097          	auipc	ra,0xfffff
    80004c14:	08e080e7          	jalr	142(ra) # 80003c9e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004c18:	854a                	mv	a0,s2
    80004c1a:	70a2                	ld	ra,40(sp)
    80004c1c:	7402                	ld	s0,32(sp)
    80004c1e:	64e2                	ld	s1,24(sp)
    80004c20:	6942                	ld	s2,16(sp)
    80004c22:	69a2                	ld	s3,8(sp)
    80004c24:	6145                	addi	sp,sp,48
    80004c26:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c28:	6908                	ld	a0,16(a0)
    80004c2a:	00000097          	auipc	ra,0x0
    80004c2e:	3c8080e7          	jalr	968(ra) # 80004ff2 <piperead>
    80004c32:	892a                	mv	s2,a0
    80004c34:	b7d5                	j	80004c18 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c36:	02451783          	lh	a5,36(a0)
    80004c3a:	03079693          	slli	a3,a5,0x30
    80004c3e:	92c1                	srli	a3,a3,0x30
    80004c40:	4725                	li	a4,9
    80004c42:	02d76863          	bltu	a4,a3,80004c72 <fileread+0xba>
    80004c46:	0792                	slli	a5,a5,0x4
    80004c48:	00023717          	auipc	a4,0x23
    80004c4c:	ed070713          	addi	a4,a4,-304 # 80027b18 <devsw>
    80004c50:	97ba                	add	a5,a5,a4
    80004c52:	639c                	ld	a5,0(a5)
    80004c54:	c38d                	beqz	a5,80004c76 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004c56:	4505                	li	a0,1
    80004c58:	9782                	jalr	a5
    80004c5a:	892a                	mv	s2,a0
    80004c5c:	bf75                	j	80004c18 <fileread+0x60>
    panic("fileread");
    80004c5e:	00004517          	auipc	a0,0x4
    80004c62:	afa50513          	addi	a0,a0,-1286 # 80008758 <syscalls+0x270>
    80004c66:	ffffc097          	auipc	ra,0xffffc
    80004c6a:	8c8080e7          	jalr	-1848(ra) # 8000052e <panic>
    return -1;
    80004c6e:	597d                	li	s2,-1
    80004c70:	b765                	j	80004c18 <fileread+0x60>
      return -1;
    80004c72:	597d                	li	s2,-1
    80004c74:	b755                	j	80004c18 <fileread+0x60>
    80004c76:	597d                	li	s2,-1
    80004c78:	b745                	j	80004c18 <fileread+0x60>

0000000080004c7a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004c7a:	715d                	addi	sp,sp,-80
    80004c7c:	e486                	sd	ra,72(sp)
    80004c7e:	e0a2                	sd	s0,64(sp)
    80004c80:	fc26                	sd	s1,56(sp)
    80004c82:	f84a                	sd	s2,48(sp)
    80004c84:	f44e                	sd	s3,40(sp)
    80004c86:	f052                	sd	s4,32(sp)
    80004c88:	ec56                	sd	s5,24(sp)
    80004c8a:	e85a                	sd	s6,16(sp)
    80004c8c:	e45e                	sd	s7,8(sp)
    80004c8e:	e062                	sd	s8,0(sp)
    80004c90:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004c92:	00954783          	lbu	a5,9(a0)
    80004c96:	10078663          	beqz	a5,80004da2 <filewrite+0x128>
    80004c9a:	892a                	mv	s2,a0
    80004c9c:	8aae                	mv	s5,a1
    80004c9e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ca0:	411c                	lw	a5,0(a0)
    80004ca2:	4705                	li	a4,1
    80004ca4:	02e78263          	beq	a5,a4,80004cc8 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ca8:	470d                	li	a4,3
    80004caa:	02e78663          	beq	a5,a4,80004cd6 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cae:	4709                	li	a4,2
    80004cb0:	0ee79163          	bne	a5,a4,80004d92 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004cb4:	0ac05d63          	blez	a2,80004d6e <filewrite+0xf4>
    int i = 0;
    80004cb8:	4981                	li	s3,0
    80004cba:	6b05                	lui	s6,0x1
    80004cbc:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004cc0:	6b85                	lui	s7,0x1
    80004cc2:	c00b8b9b          	addiw	s7,s7,-1024
    80004cc6:	a861                	j	80004d5e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004cc8:	6908                	ld	a0,16(a0)
    80004cca:	00000097          	auipc	ra,0x0
    80004cce:	22e080e7          	jalr	558(ra) # 80004ef8 <pipewrite>
    80004cd2:	8a2a                	mv	s4,a0
    80004cd4:	a045                	j	80004d74 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004cd6:	02451783          	lh	a5,36(a0)
    80004cda:	03079693          	slli	a3,a5,0x30
    80004cde:	92c1                	srli	a3,a3,0x30
    80004ce0:	4725                	li	a4,9
    80004ce2:	0cd76263          	bltu	a4,a3,80004da6 <filewrite+0x12c>
    80004ce6:	0792                	slli	a5,a5,0x4
    80004ce8:	00023717          	auipc	a4,0x23
    80004cec:	e3070713          	addi	a4,a4,-464 # 80027b18 <devsw>
    80004cf0:	97ba                	add	a5,a5,a4
    80004cf2:	679c                	ld	a5,8(a5)
    80004cf4:	cbdd                	beqz	a5,80004daa <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004cf6:	4505                	li	a0,1
    80004cf8:	9782                	jalr	a5
    80004cfa:	8a2a                	mv	s4,a0
    80004cfc:	a8a5                	j	80004d74 <filewrite+0xfa>
    80004cfe:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004d02:	00000097          	auipc	ra,0x0
    80004d06:	8b0080e7          	jalr	-1872(ra) # 800045b2 <begin_op>
      ilock(f->ip);
    80004d0a:	01893503          	ld	a0,24(s2)
    80004d0e:	fffff097          	auipc	ra,0xfffff
    80004d12:	ece080e7          	jalr	-306(ra) # 80003bdc <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d16:	8762                	mv	a4,s8
    80004d18:	02092683          	lw	a3,32(s2)
    80004d1c:	01598633          	add	a2,s3,s5
    80004d20:	4585                	li	a1,1
    80004d22:	01893503          	ld	a0,24(s2)
    80004d26:	fffff097          	auipc	ra,0xfffff
    80004d2a:	262080e7          	jalr	610(ra) # 80003f88 <writei>
    80004d2e:	84aa                	mv	s1,a0
    80004d30:	00a05763          	blez	a0,80004d3e <filewrite+0xc4>
        f->off += r;
    80004d34:	02092783          	lw	a5,32(s2)
    80004d38:	9fa9                	addw	a5,a5,a0
    80004d3a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d3e:	01893503          	ld	a0,24(s2)
    80004d42:	fffff097          	auipc	ra,0xfffff
    80004d46:	f5c080e7          	jalr	-164(ra) # 80003c9e <iunlock>
      end_op();
    80004d4a:	00000097          	auipc	ra,0x0
    80004d4e:	8e8080e7          	jalr	-1816(ra) # 80004632 <end_op>

      if(r != n1){
    80004d52:	009c1f63          	bne	s8,s1,80004d70 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004d56:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004d5a:	0149db63          	bge	s3,s4,80004d70 <filewrite+0xf6>
      int n1 = n - i;
    80004d5e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004d62:	84be                	mv	s1,a5
    80004d64:	2781                	sext.w	a5,a5
    80004d66:	f8fb5ce3          	bge	s6,a5,80004cfe <filewrite+0x84>
    80004d6a:	84de                	mv	s1,s7
    80004d6c:	bf49                	j	80004cfe <filewrite+0x84>
    int i = 0;
    80004d6e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004d70:	013a1f63          	bne	s4,s3,80004d8e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d74:	8552                	mv	a0,s4
    80004d76:	60a6                	ld	ra,72(sp)
    80004d78:	6406                	ld	s0,64(sp)
    80004d7a:	74e2                	ld	s1,56(sp)
    80004d7c:	7942                	ld	s2,48(sp)
    80004d7e:	79a2                	ld	s3,40(sp)
    80004d80:	7a02                	ld	s4,32(sp)
    80004d82:	6ae2                	ld	s5,24(sp)
    80004d84:	6b42                	ld	s6,16(sp)
    80004d86:	6ba2                	ld	s7,8(sp)
    80004d88:	6c02                	ld	s8,0(sp)
    80004d8a:	6161                	addi	sp,sp,80
    80004d8c:	8082                	ret
    ret = (i == n ? n : -1);
    80004d8e:	5a7d                	li	s4,-1
    80004d90:	b7d5                	j	80004d74 <filewrite+0xfa>
    panic("filewrite");
    80004d92:	00004517          	auipc	a0,0x4
    80004d96:	9d650513          	addi	a0,a0,-1578 # 80008768 <syscalls+0x280>
    80004d9a:	ffffb097          	auipc	ra,0xffffb
    80004d9e:	794080e7          	jalr	1940(ra) # 8000052e <panic>
    return -1;
    80004da2:	5a7d                	li	s4,-1
    80004da4:	bfc1                	j	80004d74 <filewrite+0xfa>
      return -1;
    80004da6:	5a7d                	li	s4,-1
    80004da8:	b7f1                	j	80004d74 <filewrite+0xfa>
    80004daa:	5a7d                	li	s4,-1
    80004dac:	b7e1                	j	80004d74 <filewrite+0xfa>

0000000080004dae <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004dae:	7179                	addi	sp,sp,-48
    80004db0:	f406                	sd	ra,40(sp)
    80004db2:	f022                	sd	s0,32(sp)
    80004db4:	ec26                	sd	s1,24(sp)
    80004db6:	e84a                	sd	s2,16(sp)
    80004db8:	e44e                	sd	s3,8(sp)
    80004dba:	e052                	sd	s4,0(sp)
    80004dbc:	1800                	addi	s0,sp,48
    80004dbe:	84aa                	mv	s1,a0
    80004dc0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004dc2:	0005b023          	sd	zero,0(a1)
    80004dc6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004dca:	00000097          	auipc	ra,0x0
    80004dce:	bf8080e7          	jalr	-1032(ra) # 800049c2 <filealloc>
    80004dd2:	e088                	sd	a0,0(s1)
    80004dd4:	c551                	beqz	a0,80004e60 <pipealloc+0xb2>
    80004dd6:	00000097          	auipc	ra,0x0
    80004dda:	bec080e7          	jalr	-1044(ra) # 800049c2 <filealloc>
    80004dde:	00aa3023          	sd	a0,0(s4)
    80004de2:	c92d                	beqz	a0,80004e54 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004de4:	ffffc097          	auipc	ra,0xffffc
    80004de8:	cf2080e7          	jalr	-782(ra) # 80000ad6 <kalloc>
    80004dec:	892a                	mv	s2,a0
    80004dee:	c125                	beqz	a0,80004e4e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004df0:	4985                	li	s3,1
    80004df2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004df6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004dfa:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004dfe:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004e02:	00004597          	auipc	a1,0x4
    80004e06:	97658593          	addi	a1,a1,-1674 # 80008778 <syscalls+0x290>
    80004e0a:	ffffc097          	auipc	ra,0xffffc
    80004e0e:	d2c080e7          	jalr	-724(ra) # 80000b36 <initlock>
  (*f0)->type = FD_PIPE;
    80004e12:	609c                	ld	a5,0(s1)
    80004e14:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004e18:	609c                	ld	a5,0(s1)
    80004e1a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e1e:	609c                	ld	a5,0(s1)
    80004e20:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e24:	609c                	ld	a5,0(s1)
    80004e26:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004e2a:	000a3783          	ld	a5,0(s4)
    80004e2e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004e32:	000a3783          	ld	a5,0(s4)
    80004e36:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e3a:	000a3783          	ld	a5,0(s4)
    80004e3e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004e42:	000a3783          	ld	a5,0(s4)
    80004e46:	0127b823          	sd	s2,16(a5)
  return 0;
    80004e4a:	4501                	li	a0,0
    80004e4c:	a025                	j	80004e74 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e4e:	6088                	ld	a0,0(s1)
    80004e50:	e501                	bnez	a0,80004e58 <pipealloc+0xaa>
    80004e52:	a039                	j	80004e60 <pipealloc+0xb2>
    80004e54:	6088                	ld	a0,0(s1)
    80004e56:	c51d                	beqz	a0,80004e84 <pipealloc+0xd6>
    fileclose(*f0);
    80004e58:	00000097          	auipc	ra,0x0
    80004e5c:	c26080e7          	jalr	-986(ra) # 80004a7e <fileclose>
  if(*f1)
    80004e60:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004e64:	557d                	li	a0,-1
  if(*f1)
    80004e66:	c799                	beqz	a5,80004e74 <pipealloc+0xc6>
    fileclose(*f1);
    80004e68:	853e                	mv	a0,a5
    80004e6a:	00000097          	auipc	ra,0x0
    80004e6e:	c14080e7          	jalr	-1004(ra) # 80004a7e <fileclose>
  return -1;
    80004e72:	557d                	li	a0,-1
}
    80004e74:	70a2                	ld	ra,40(sp)
    80004e76:	7402                	ld	s0,32(sp)
    80004e78:	64e2                	ld	s1,24(sp)
    80004e7a:	6942                	ld	s2,16(sp)
    80004e7c:	69a2                	ld	s3,8(sp)
    80004e7e:	6a02                	ld	s4,0(sp)
    80004e80:	6145                	addi	sp,sp,48
    80004e82:	8082                	ret
  return -1;
    80004e84:	557d                	li	a0,-1
    80004e86:	b7fd                	j	80004e74 <pipealloc+0xc6>

0000000080004e88 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004e88:	1101                	addi	sp,sp,-32
    80004e8a:	ec06                	sd	ra,24(sp)
    80004e8c:	e822                	sd	s0,16(sp)
    80004e8e:	e426                	sd	s1,8(sp)
    80004e90:	e04a                	sd	s2,0(sp)
    80004e92:	1000                	addi	s0,sp,32
    80004e94:	84aa                	mv	s1,a0
    80004e96:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e98:	ffffc097          	auipc	ra,0xffffc
    80004e9c:	d2e080e7          	jalr	-722(ra) # 80000bc6 <acquire>
  if(writable){
    80004ea0:	02090d63          	beqz	s2,80004eda <pipeclose+0x52>
    pi->writeopen = 0;
    80004ea4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004ea8:	21848513          	addi	a0,s1,536
    80004eac:	ffffd097          	auipc	ra,0xffffd
    80004eb0:	3ac080e7          	jalr	940(ra) # 80002258 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004eb4:	2204b783          	ld	a5,544(s1)
    80004eb8:	eb95                	bnez	a5,80004eec <pipeclose+0x64>
    release(&pi->lock);
    80004eba:	8526                	mv	a0,s1
    80004ebc:	ffffc097          	auipc	ra,0xffffc
    80004ec0:	dd4080e7          	jalr	-556(ra) # 80000c90 <release>
    kfree((char*)pi);
    80004ec4:	8526                	mv	a0,s1
    80004ec6:	ffffc097          	auipc	ra,0xffffc
    80004eca:	b14080e7          	jalr	-1260(ra) # 800009da <kfree>
  } else
    release(&pi->lock);
}
    80004ece:	60e2                	ld	ra,24(sp)
    80004ed0:	6442                	ld	s0,16(sp)
    80004ed2:	64a2                	ld	s1,8(sp)
    80004ed4:	6902                	ld	s2,0(sp)
    80004ed6:	6105                	addi	sp,sp,32
    80004ed8:	8082                	ret
    pi->readopen = 0;
    80004eda:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ede:	21c48513          	addi	a0,s1,540
    80004ee2:	ffffd097          	auipc	ra,0xffffd
    80004ee6:	376080e7          	jalr	886(ra) # 80002258 <wakeup>
    80004eea:	b7e9                	j	80004eb4 <pipeclose+0x2c>
    release(&pi->lock);
    80004eec:	8526                	mv	a0,s1
    80004eee:	ffffc097          	auipc	ra,0xffffc
    80004ef2:	da2080e7          	jalr	-606(ra) # 80000c90 <release>
}
    80004ef6:	bfe1                	j	80004ece <pipeclose+0x46>

0000000080004ef8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ef8:	7159                	addi	sp,sp,-112
    80004efa:	f486                	sd	ra,104(sp)
    80004efc:	f0a2                	sd	s0,96(sp)
    80004efe:	eca6                	sd	s1,88(sp)
    80004f00:	e8ca                	sd	s2,80(sp)
    80004f02:	e4ce                	sd	s3,72(sp)
    80004f04:	e0d2                	sd	s4,64(sp)
    80004f06:	fc56                	sd	s5,56(sp)
    80004f08:	f85a                	sd	s6,48(sp)
    80004f0a:	f45e                	sd	s7,40(sp)
    80004f0c:	f062                	sd	s8,32(sp)
    80004f0e:	ec66                	sd	s9,24(sp)
    80004f10:	1880                	addi	s0,sp,112
    80004f12:	84aa                	mv	s1,a0
    80004f14:	8b2e                	mv	s6,a1
    80004f16:	8ab2                	mv	s5,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f18:	ffffd097          	auipc	ra,0xffffd
    80004f1c:	a80080e7          	jalr	-1408(ra) # 80001998 <myproc>
    80004f20:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f22:	8526                	mv	a0,s1
    80004f24:	ffffc097          	auipc	ra,0xffffc
    80004f28:	ca2080e7          	jalr	-862(ra) # 80000bc6 <acquire>
  while(i < n){
    80004f2c:	0b505663          	blez	s5,80004fd8 <pipewrite+0xe0>
  int i = 0;
    80004f30:	4901                	li	s2,0
    if(pi->readopen == 0 || pr->killed==1){
    80004f32:	4a05                	li	s4,1
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f34:	5bfd                	li	s7,-1
      wakeup(&pi->nread);
    80004f36:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004f3a:	21c48c13          	addi	s8,s1,540
    80004f3e:	a091                	j	80004f82 <pipewrite+0x8a>
      release(&pi->lock);
    80004f40:	8526                	mv	a0,s1
    80004f42:	ffffc097          	auipc	ra,0xffffc
    80004f46:	d4e080e7          	jalr	-690(ra) # 80000c90 <release>
      return -1;
    80004f4a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004f4c:	854a                	mv	a0,s2
    80004f4e:	70a6                	ld	ra,104(sp)
    80004f50:	7406                	ld	s0,96(sp)
    80004f52:	64e6                	ld	s1,88(sp)
    80004f54:	6946                	ld	s2,80(sp)
    80004f56:	69a6                	ld	s3,72(sp)
    80004f58:	6a06                	ld	s4,64(sp)
    80004f5a:	7ae2                	ld	s5,56(sp)
    80004f5c:	7b42                	ld	s6,48(sp)
    80004f5e:	7ba2                	ld	s7,40(sp)
    80004f60:	7c02                	ld	s8,32(sp)
    80004f62:	6ce2                	ld	s9,24(sp)
    80004f64:	6165                	addi	sp,sp,112
    80004f66:	8082                	ret
      wakeup(&pi->nread);
    80004f68:	8566                	mv	a0,s9
    80004f6a:	ffffd097          	auipc	ra,0xffffd
    80004f6e:	2ee080e7          	jalr	750(ra) # 80002258 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004f72:	85a6                	mv	a1,s1
    80004f74:	8562                	mv	a0,s8
    80004f76:	ffffd097          	auipc	ra,0xffffd
    80004f7a:	154080e7          	jalr	340(ra) # 800020ca <sleep>
  while(i < n){
    80004f7e:	05595e63          	bge	s2,s5,80004fda <pipewrite+0xe2>
    if(pi->readopen == 0 || pr->killed==1){
    80004f82:	2204a783          	lw	a5,544(s1)
    80004f86:	dfcd                	beqz	a5,80004f40 <pipewrite+0x48>
    80004f88:	0289a783          	lw	a5,40(s3)
    80004f8c:	fb478ae3          	beq	a5,s4,80004f40 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004f90:	2184a783          	lw	a5,536(s1)
    80004f94:	21c4a703          	lw	a4,540(s1)
    80004f98:	2007879b          	addiw	a5,a5,512
    80004f9c:	fcf706e3          	beq	a4,a5,80004f68 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fa0:	86d2                	mv	a3,s4
    80004fa2:	01690633          	add	a2,s2,s6
    80004fa6:	f9f40593          	addi	a1,s0,-97
    80004faa:	0509b503          	ld	a0,80(s3)
    80004fae:	ffffc097          	auipc	ra,0xffffc
    80004fb2:	736080e7          	jalr	1846(ra) # 800016e4 <copyin>
    80004fb6:	03750263          	beq	a0,s7,80004fda <pipewrite+0xe2>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004fba:	21c4a783          	lw	a5,540(s1)
    80004fbe:	0017871b          	addiw	a4,a5,1
    80004fc2:	20e4ae23          	sw	a4,540(s1)
    80004fc6:	1ff7f793          	andi	a5,a5,511
    80004fca:	97a6                	add	a5,a5,s1
    80004fcc:	f9f44703          	lbu	a4,-97(s0)
    80004fd0:	00e78c23          	sb	a4,24(a5)
      i++;
    80004fd4:	2905                	addiw	s2,s2,1
    80004fd6:	b765                	j	80004f7e <pipewrite+0x86>
  int i = 0;
    80004fd8:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004fda:	21848513          	addi	a0,s1,536
    80004fde:	ffffd097          	auipc	ra,0xffffd
    80004fe2:	27a080e7          	jalr	634(ra) # 80002258 <wakeup>
  release(&pi->lock);
    80004fe6:	8526                	mv	a0,s1
    80004fe8:	ffffc097          	auipc	ra,0xffffc
    80004fec:	ca8080e7          	jalr	-856(ra) # 80000c90 <release>
  return i;
    80004ff0:	bfb1                	j	80004f4c <pipewrite+0x54>

0000000080004ff2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ff2:	715d                	addi	sp,sp,-80
    80004ff4:	e486                	sd	ra,72(sp)
    80004ff6:	e0a2                	sd	s0,64(sp)
    80004ff8:	fc26                	sd	s1,56(sp)
    80004ffa:	f84a                	sd	s2,48(sp)
    80004ffc:	f44e                	sd	s3,40(sp)
    80004ffe:	f052                	sd	s4,32(sp)
    80005000:	ec56                	sd	s5,24(sp)
    80005002:	e85a                	sd	s6,16(sp)
    80005004:	0880                	addi	s0,sp,80
    80005006:	84aa                	mv	s1,a0
    80005008:	892e                	mv	s2,a1
    8000500a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000500c:	ffffd097          	auipc	ra,0xffffd
    80005010:	98c080e7          	jalr	-1652(ra) # 80001998 <myproc>
    80005014:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005016:	8526                	mv	a0,s1
    80005018:	ffffc097          	auipc	ra,0xffffc
    8000501c:	bae080e7          	jalr	-1106(ra) # 80000bc6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005020:	2184a703          	lw	a4,536(s1)
    80005024:	21c4a783          	lw	a5,540(s1)
    if(pr->killed==1){
    80005028:	4985                	li	s3,1
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000502a:	21848b13          	addi	s6,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000502e:	02f71563          	bne	a4,a5,80005058 <piperead+0x66>
    80005032:	2244a783          	lw	a5,548(s1)
    80005036:	c38d                	beqz	a5,80005058 <piperead+0x66>
    if(pr->killed==1){
    80005038:	028a2783          	lw	a5,40(s4)
    8000503c:	09378963          	beq	a5,s3,800050ce <piperead+0xdc>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005040:	85a6                	mv	a1,s1
    80005042:	855a                	mv	a0,s6
    80005044:	ffffd097          	auipc	ra,0xffffd
    80005048:	086080e7          	jalr	134(ra) # 800020ca <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000504c:	2184a703          	lw	a4,536(s1)
    80005050:	21c4a783          	lw	a5,540(s1)
    80005054:	fcf70fe3          	beq	a4,a5,80005032 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005058:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000505a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000505c:	05505363          	blez	s5,800050a2 <piperead+0xb0>
    if(pi->nread == pi->nwrite)
    80005060:	2184a783          	lw	a5,536(s1)
    80005064:	21c4a703          	lw	a4,540(s1)
    80005068:	02f70d63          	beq	a4,a5,800050a2 <piperead+0xb0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000506c:	0017871b          	addiw	a4,a5,1
    80005070:	20e4ac23          	sw	a4,536(s1)
    80005074:	1ff7f793          	andi	a5,a5,511
    80005078:	97a6                	add	a5,a5,s1
    8000507a:	0187c783          	lbu	a5,24(a5)
    8000507e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005082:	4685                	li	a3,1
    80005084:	fbf40613          	addi	a2,s0,-65
    80005088:	85ca                	mv	a1,s2
    8000508a:	050a3503          	ld	a0,80(s4)
    8000508e:	ffffc097          	auipc	ra,0xffffc
    80005092:	5ca080e7          	jalr	1482(ra) # 80001658 <copyout>
    80005096:	01650663          	beq	a0,s6,800050a2 <piperead+0xb0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000509a:	2985                	addiw	s3,s3,1
    8000509c:	0905                	addi	s2,s2,1
    8000509e:	fd3a91e3          	bne	s5,s3,80005060 <piperead+0x6e>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800050a2:	21c48513          	addi	a0,s1,540
    800050a6:	ffffd097          	auipc	ra,0xffffd
    800050aa:	1b2080e7          	jalr	434(ra) # 80002258 <wakeup>
  release(&pi->lock);
    800050ae:	8526                	mv	a0,s1
    800050b0:	ffffc097          	auipc	ra,0xffffc
    800050b4:	be0080e7          	jalr	-1056(ra) # 80000c90 <release>
  return i;
}
    800050b8:	854e                	mv	a0,s3
    800050ba:	60a6                	ld	ra,72(sp)
    800050bc:	6406                	ld	s0,64(sp)
    800050be:	74e2                	ld	s1,56(sp)
    800050c0:	7942                	ld	s2,48(sp)
    800050c2:	79a2                	ld	s3,40(sp)
    800050c4:	7a02                	ld	s4,32(sp)
    800050c6:	6ae2                	ld	s5,24(sp)
    800050c8:	6b42                	ld	s6,16(sp)
    800050ca:	6161                	addi	sp,sp,80
    800050cc:	8082                	ret
      release(&pi->lock);
    800050ce:	8526                	mv	a0,s1
    800050d0:	ffffc097          	auipc	ra,0xffffc
    800050d4:	bc0080e7          	jalr	-1088(ra) # 80000c90 <release>
      return -1;
    800050d8:	59fd                	li	s3,-1
    800050da:	bff9                	j	800050b8 <piperead+0xc6>

00000000800050dc <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    800050dc:	de010113          	addi	sp,sp,-544
    800050e0:	20113c23          	sd	ra,536(sp)
    800050e4:	20813823          	sd	s0,528(sp)
    800050e8:	20913423          	sd	s1,520(sp)
    800050ec:	21213023          	sd	s2,512(sp)
    800050f0:	ffce                	sd	s3,504(sp)
    800050f2:	fbd2                	sd	s4,496(sp)
    800050f4:	f7d6                	sd	s5,488(sp)
    800050f6:	f3da                	sd	s6,480(sp)
    800050f8:	efde                	sd	s7,472(sp)
    800050fa:	ebe2                	sd	s8,464(sp)
    800050fc:	e7e6                	sd	s9,456(sp)
    800050fe:	e3ea                	sd	s10,448(sp)
    80005100:	ff6e                	sd	s11,440(sp)
    80005102:	1400                	addi	s0,sp,544
    80005104:	892a                	mv	s2,a0
    80005106:	dea43423          	sd	a0,-536(s0)
    8000510a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000510e:	ffffd097          	auipc	ra,0xffffd
    80005112:	88a080e7          	jalr	-1910(ra) # 80001998 <myproc>
    80005116:	84aa                	mv	s1,a0

  begin_op();
    80005118:	fffff097          	auipc	ra,0xfffff
    8000511c:	49a080e7          	jalr	1178(ra) # 800045b2 <begin_op>

  if((ip = namei(path)) == 0){
    80005120:	854a                	mv	a0,s2
    80005122:	fffff097          	auipc	ra,0xfffff
    80005126:	270080e7          	jalr	624(ra) # 80004392 <namei>
    8000512a:	c93d                	beqz	a0,800051a0 <exec+0xc4>
    8000512c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000512e:	fffff097          	auipc	ra,0xfffff
    80005132:	aae080e7          	jalr	-1362(ra) # 80003bdc <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005136:	04000713          	li	a4,64
    8000513a:	4681                	li	a3,0
    8000513c:	e4840613          	addi	a2,s0,-440
    80005140:	4581                	li	a1,0
    80005142:	8556                	mv	a0,s5
    80005144:	fffff097          	auipc	ra,0xfffff
    80005148:	d4c080e7          	jalr	-692(ra) # 80003e90 <readi>
    8000514c:	04000793          	li	a5,64
    80005150:	00f51a63          	bne	a0,a5,80005164 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005154:	e4842703          	lw	a4,-440(s0)
    80005158:	464c47b7          	lui	a5,0x464c4
    8000515c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005160:	04f70663          	beq	a4,a5,800051ac <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005164:	8556                	mv	a0,s5
    80005166:	fffff097          	auipc	ra,0xfffff
    8000516a:	cd8080e7          	jalr	-808(ra) # 80003e3e <iunlockput>
    end_op();
    8000516e:	fffff097          	auipc	ra,0xfffff
    80005172:	4c4080e7          	jalr	1220(ra) # 80004632 <end_op>
  }
  return -1;
    80005176:	557d                	li	a0,-1
}
    80005178:	21813083          	ld	ra,536(sp)
    8000517c:	21013403          	ld	s0,528(sp)
    80005180:	20813483          	ld	s1,520(sp)
    80005184:	20013903          	ld	s2,512(sp)
    80005188:	79fe                	ld	s3,504(sp)
    8000518a:	7a5e                	ld	s4,496(sp)
    8000518c:	7abe                	ld	s5,488(sp)
    8000518e:	7b1e                	ld	s6,480(sp)
    80005190:	6bfe                	ld	s7,472(sp)
    80005192:	6c5e                	ld	s8,464(sp)
    80005194:	6cbe                	ld	s9,456(sp)
    80005196:	6d1e                	ld	s10,448(sp)
    80005198:	7dfa                	ld	s11,440(sp)
    8000519a:	22010113          	addi	sp,sp,544
    8000519e:	8082                	ret
    end_op();
    800051a0:	fffff097          	auipc	ra,0xfffff
    800051a4:	492080e7          	jalr	1170(ra) # 80004632 <end_op>
    return -1;
    800051a8:	557d                	li	a0,-1
    800051aa:	b7f9                	j	80005178 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800051ac:	8526                	mv	a0,s1
    800051ae:	ffffd097          	auipc	ra,0xffffd
    800051b2:	8ae080e7          	jalr	-1874(ra) # 80001a5c <proc_pagetable>
    800051b6:	8b2a                	mv	s6,a0
    800051b8:	d555                	beqz	a0,80005164 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051ba:	e6842783          	lw	a5,-408(s0)
    800051be:	e8045703          	lhu	a4,-384(s0)
    800051c2:	c735                	beqz	a4,8000522e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800051c4:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051c6:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800051ca:	6a05                	lui	s4,0x1
    800051cc:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800051d0:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    800051d4:	6d85                	lui	s11,0x1
    800051d6:	7d7d                	lui	s10,0xfffff
    800051d8:	acb1                	j	80005434 <exec+0x358>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800051da:	00003517          	auipc	a0,0x3
    800051de:	5a650513          	addi	a0,a0,1446 # 80008780 <syscalls+0x298>
    800051e2:	ffffb097          	auipc	ra,0xffffb
    800051e6:	34c080e7          	jalr	844(ra) # 8000052e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800051ea:	874a                	mv	a4,s2
    800051ec:	009c86bb          	addw	a3,s9,s1
    800051f0:	4581                	li	a1,0
    800051f2:	8556                	mv	a0,s5
    800051f4:	fffff097          	auipc	ra,0xfffff
    800051f8:	c9c080e7          	jalr	-868(ra) # 80003e90 <readi>
    800051fc:	2501                	sext.w	a0,a0
    800051fe:	1ca91b63          	bne	s2,a0,800053d4 <exec+0x2f8>
  for(i = 0; i < sz; i += PGSIZE){
    80005202:	009d84bb          	addw	s1,s11,s1
    80005206:	013d09bb          	addw	s3,s10,s3
    8000520a:	2174f563          	bgeu	s1,s7,80005414 <exec+0x338>
    pa = walkaddr(pagetable, va + i);
    8000520e:	02049593          	slli	a1,s1,0x20
    80005212:	9181                	srli	a1,a1,0x20
    80005214:	95e2                	add	a1,a1,s8
    80005216:	855a                	mv	a0,s6
    80005218:	ffffc097          	auipc	ra,0xffffc
    8000521c:	e4e080e7          	jalr	-434(ra) # 80001066 <walkaddr>
    80005220:	862a                	mv	a2,a0
    if(pa == 0)
    80005222:	dd45                	beqz	a0,800051da <exec+0xfe>
      n = PGSIZE;
    80005224:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005226:	fd49f2e3          	bgeu	s3,s4,800051ea <exec+0x10e>
      n = sz - i;
    8000522a:	894e                	mv	s2,s3
    8000522c:	bf7d                	j	800051ea <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000522e:	4481                	li	s1,0
  iunlockput(ip);
    80005230:	8556                	mv	a0,s5
    80005232:	fffff097          	auipc	ra,0xfffff
    80005236:	c0c080e7          	jalr	-1012(ra) # 80003e3e <iunlockput>
  end_op();
    8000523a:	fffff097          	auipc	ra,0xfffff
    8000523e:	3f8080e7          	jalr	1016(ra) # 80004632 <end_op>
  p = myproc();
    80005242:	ffffc097          	auipc	ra,0xffffc
    80005246:	756080e7          	jalr	1878(ra) # 80001998 <myproc>
    8000524a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000524c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005250:	6785                	lui	a5,0x1
    80005252:	17fd                	addi	a5,a5,-1
    80005254:	94be                	add	s1,s1,a5
    80005256:	77fd                	lui	a5,0xfffff
    80005258:	8fe5                	and	a5,a5,s1
    8000525a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000525e:	6609                	lui	a2,0x2
    80005260:	963e                	add	a2,a2,a5
    80005262:	85be                	mv	a1,a5
    80005264:	855a                	mv	a0,s6
    80005266:	ffffc097          	auipc	ra,0xffffc
    8000526a:	1a2080e7          	jalr	418(ra) # 80001408 <uvmalloc>
    8000526e:	8c2a                	mv	s8,a0
  ip = 0;
    80005270:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005272:	16050163          	beqz	a0,800053d4 <exec+0x2f8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005276:	75f9                	lui	a1,0xffffe
    80005278:	95aa                	add	a1,a1,a0
    8000527a:	855a                	mv	a0,s6
    8000527c:	ffffc097          	auipc	ra,0xffffc
    80005280:	3aa080e7          	jalr	938(ra) # 80001626 <uvmclear>
  stackbase = sp - PGSIZE;
    80005284:	7afd                	lui	s5,0xfffff
    80005286:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005288:	df043783          	ld	a5,-528(s0)
    8000528c:	6388                	ld	a0,0(a5)
    8000528e:	c925                	beqz	a0,800052fe <exec+0x222>
    80005290:	e8840993          	addi	s3,s0,-376
    80005294:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005298:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000529a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000529c:	ffffc097          	auipc	ra,0xffffc
    800052a0:	bc0080e7          	jalr	-1088(ra) # 80000e5c <strlen>
    800052a4:	0015079b          	addiw	a5,a0,1
    800052a8:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800052ac:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800052b0:	15596663          	bltu	s2,s5,800053fc <exec+0x320>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800052b4:	df043d83          	ld	s11,-528(s0)
    800052b8:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800052bc:	8552                	mv	a0,s4
    800052be:	ffffc097          	auipc	ra,0xffffc
    800052c2:	b9e080e7          	jalr	-1122(ra) # 80000e5c <strlen>
    800052c6:	0015069b          	addiw	a3,a0,1
    800052ca:	8652                	mv	a2,s4
    800052cc:	85ca                	mv	a1,s2
    800052ce:	855a                	mv	a0,s6
    800052d0:	ffffc097          	auipc	ra,0xffffc
    800052d4:	388080e7          	jalr	904(ra) # 80001658 <copyout>
    800052d8:	12054663          	bltz	a0,80005404 <exec+0x328>
    ustack[argc] = sp;
    800052dc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800052e0:	0485                	addi	s1,s1,1
    800052e2:	008d8793          	addi	a5,s11,8
    800052e6:	def43823          	sd	a5,-528(s0)
    800052ea:	008db503          	ld	a0,8(s11)
    800052ee:	c911                	beqz	a0,80005302 <exec+0x226>
    if(argc >= MAXARG)
    800052f0:	09a1                	addi	s3,s3,8
    800052f2:	fb9995e3          	bne	s3,s9,8000529c <exec+0x1c0>
  sz = sz1;
    800052f6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052fa:	4a81                	li	s5,0
    800052fc:	a8e1                	j	800053d4 <exec+0x2f8>
  sp = sz;
    800052fe:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005300:	4481                	li	s1,0
  ustack[argc] = 0;
    80005302:	00349793          	slli	a5,s1,0x3
    80005306:	f9040713          	addi	a4,s0,-112
    8000530a:	97ba                	add	a5,a5,a4
    8000530c:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd2ef8>
  sp -= (argc+1) * sizeof(uint64);
    80005310:	00148693          	addi	a3,s1,1
    80005314:	068e                	slli	a3,a3,0x3
    80005316:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000531a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000531e:	01597663          	bgeu	s2,s5,8000532a <exec+0x24e>
  sz = sz1;
    80005322:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005326:	4a81                	li	s5,0
    80005328:	a075                	j	800053d4 <exec+0x2f8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000532a:	e8840613          	addi	a2,s0,-376
    8000532e:	85ca                	mv	a1,s2
    80005330:	855a                	mv	a0,s6
    80005332:	ffffc097          	auipc	ra,0xffffc
    80005336:	326080e7          	jalr	806(ra) # 80001658 <copyout>
    8000533a:	0c054963          	bltz	a0,8000540c <exec+0x330>
  p->trapframe->a1 = sp;
    8000533e:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80005342:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005346:	de843783          	ld	a5,-536(s0)
    8000534a:	0007c703          	lbu	a4,0(a5)
    8000534e:	cf11                	beqz	a4,8000536a <exec+0x28e>
    80005350:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005352:	02f00693          	li	a3,47
    80005356:	a039                	j	80005364 <exec+0x288>
      last = s+1;
    80005358:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000535c:	0785                	addi	a5,a5,1
    8000535e:	fff7c703          	lbu	a4,-1(a5)
    80005362:	c701                	beqz	a4,8000536a <exec+0x28e>
    if(*s == '/')
    80005364:	fed71ce3          	bne	a4,a3,8000535c <exec+0x280>
    80005368:	bfc5                	j	80005358 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000536a:	4641                	li	a2,16
    8000536c:	de843583          	ld	a1,-536(s0)
    80005370:	158b8513          	addi	a0,s7,344
    80005374:	ffffc097          	auipc	ra,0xffffc
    80005378:	ab6080e7          	jalr	-1354(ra) # 80000e2a <safestrcpy>
  for(int i=0; i<32; i++){
    8000537c:	178b8793          	addi	a5,s7,376
    80005380:	278b8713          	addi	a4,s7,632
    80005384:	85ba                	mv	a1,a4
    if(!((p->signal_handlers[i]) == (void*)SIG_IGN)){
    80005386:	4605                	li	a2,1
    80005388:	a809                	j	8000539a <exec+0x2be>
        p->signal_handlers[i]=SIG_DFL;
    8000538a:	0007b023          	sd	zero,0(a5)
        p->handlers_sigmasks[i]=0;   
    8000538e:	00072023          	sw	zero,0(a4)
  for(int i=0; i<32; i++){
    80005392:	07a1                	addi	a5,a5,8
    80005394:	0711                	addi	a4,a4,4
    80005396:	00b78663          	beq	a5,a1,800053a2 <exec+0x2c6>
    if(!((p->signal_handlers[i]) == (void*)SIG_IGN)){
    8000539a:	6394                	ld	a3,0(a5)
    8000539c:	fec697e3          	bne	a3,a2,8000538a <exec+0x2ae>
    800053a0:	bfcd                	j	80005392 <exec+0x2b6>
  oldpagetable = p->pagetable;
    800053a2:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800053a6:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800053aa:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800053ae:	058bb783          	ld	a5,88(s7)
    800053b2:	e6043703          	ld	a4,-416(s0)
    800053b6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800053b8:	058bb783          	ld	a5,88(s7)
    800053bc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800053c0:	85ea                	mv	a1,s10
    800053c2:	ffffc097          	auipc	ra,0xffffc
    800053c6:	736080e7          	jalr	1846(ra) # 80001af8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800053ca:	0004851b          	sext.w	a0,s1
    800053ce:	b36d                	j	80005178 <exec+0x9c>
    800053d0:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    800053d4:	df843583          	ld	a1,-520(s0)
    800053d8:	855a                	mv	a0,s6
    800053da:	ffffc097          	auipc	ra,0xffffc
    800053de:	71e080e7          	jalr	1822(ra) # 80001af8 <proc_freepagetable>
  if(ip){
    800053e2:	d80a91e3          	bnez	s5,80005164 <exec+0x88>
  return -1;
    800053e6:	557d                	li	a0,-1
    800053e8:	bb41                	j	80005178 <exec+0x9c>
    800053ea:	de943c23          	sd	s1,-520(s0)
    800053ee:	b7dd                	j	800053d4 <exec+0x2f8>
    800053f0:	de943c23          	sd	s1,-520(s0)
    800053f4:	b7c5                	j	800053d4 <exec+0x2f8>
    800053f6:	de943c23          	sd	s1,-520(s0)
    800053fa:	bfe9                	j	800053d4 <exec+0x2f8>
  sz = sz1;
    800053fc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005400:	4a81                	li	s5,0
    80005402:	bfc9                	j	800053d4 <exec+0x2f8>
  sz = sz1;
    80005404:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005408:	4a81                	li	s5,0
    8000540a:	b7e9                	j	800053d4 <exec+0x2f8>
  sz = sz1;
    8000540c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005410:	4a81                	li	s5,0
    80005412:	b7c9                	j	800053d4 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005414:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005418:	e0843783          	ld	a5,-504(s0)
    8000541c:	0017869b          	addiw	a3,a5,1
    80005420:	e0d43423          	sd	a3,-504(s0)
    80005424:	e0043783          	ld	a5,-512(s0)
    80005428:	0387879b          	addiw	a5,a5,56
    8000542c:	e8045703          	lhu	a4,-384(s0)
    80005430:	e0e6d0e3          	bge	a3,a4,80005230 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005434:	2781                	sext.w	a5,a5
    80005436:	e0f43023          	sd	a5,-512(s0)
    8000543a:	03800713          	li	a4,56
    8000543e:	86be                	mv	a3,a5
    80005440:	e1040613          	addi	a2,s0,-496
    80005444:	4581                	li	a1,0
    80005446:	8556                	mv	a0,s5
    80005448:	fffff097          	auipc	ra,0xfffff
    8000544c:	a48080e7          	jalr	-1464(ra) # 80003e90 <readi>
    80005450:	03800793          	li	a5,56
    80005454:	f6f51ee3          	bne	a0,a5,800053d0 <exec+0x2f4>
    if(ph.type != ELF_PROG_LOAD)
    80005458:	e1042783          	lw	a5,-496(s0)
    8000545c:	4705                	li	a4,1
    8000545e:	fae79de3          	bne	a5,a4,80005418 <exec+0x33c>
    if(ph.memsz < ph.filesz)
    80005462:	e3843603          	ld	a2,-456(s0)
    80005466:	e3043783          	ld	a5,-464(s0)
    8000546a:	f8f660e3          	bltu	a2,a5,800053ea <exec+0x30e>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000546e:	e2043783          	ld	a5,-480(s0)
    80005472:	963e                	add	a2,a2,a5
    80005474:	f6f66ee3          	bltu	a2,a5,800053f0 <exec+0x314>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005478:	85a6                	mv	a1,s1
    8000547a:	855a                	mv	a0,s6
    8000547c:	ffffc097          	auipc	ra,0xffffc
    80005480:	f8c080e7          	jalr	-116(ra) # 80001408 <uvmalloc>
    80005484:	dea43c23          	sd	a0,-520(s0)
    80005488:	d53d                	beqz	a0,800053f6 <exec+0x31a>
    if(ph.vaddr % PGSIZE != 0)
    8000548a:	e2043c03          	ld	s8,-480(s0)
    8000548e:	de043783          	ld	a5,-544(s0)
    80005492:	00fc77b3          	and	a5,s8,a5
    80005496:	ff9d                	bnez	a5,800053d4 <exec+0x2f8>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005498:	e1842c83          	lw	s9,-488(s0)
    8000549c:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800054a0:	f60b8ae3          	beqz	s7,80005414 <exec+0x338>
    800054a4:	89de                	mv	s3,s7
    800054a6:	4481                	li	s1,0
    800054a8:	b39d                	j	8000520e <exec+0x132>

00000000800054aa <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800054aa:	7179                	addi	sp,sp,-48
    800054ac:	f406                	sd	ra,40(sp)
    800054ae:	f022                	sd	s0,32(sp)
    800054b0:	ec26                	sd	s1,24(sp)
    800054b2:	e84a                	sd	s2,16(sp)
    800054b4:	1800                	addi	s0,sp,48
    800054b6:	892e                	mv	s2,a1
    800054b8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800054ba:	fdc40593          	addi	a1,s0,-36
    800054be:	ffffe097          	auipc	ra,0xffffe
    800054c2:	aca080e7          	jalr	-1334(ra) # 80002f88 <argint>
    800054c6:	04054063          	bltz	a0,80005506 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800054ca:	fdc42703          	lw	a4,-36(s0)
    800054ce:	47bd                	li	a5,15
    800054d0:	02e7ed63          	bltu	a5,a4,8000550a <argfd+0x60>
    800054d4:	ffffc097          	auipc	ra,0xffffc
    800054d8:	4c4080e7          	jalr	1220(ra) # 80001998 <myproc>
    800054dc:	fdc42703          	lw	a4,-36(s0)
    800054e0:	01a70793          	addi	a5,a4,26
    800054e4:	078e                	slli	a5,a5,0x3
    800054e6:	953e                	add	a0,a0,a5
    800054e8:	611c                	ld	a5,0(a0)
    800054ea:	c395                	beqz	a5,8000550e <argfd+0x64>
    return -1;
  if(pfd)
    800054ec:	00090463          	beqz	s2,800054f4 <argfd+0x4a>
    *pfd = fd;
    800054f0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800054f4:	4501                	li	a0,0
  if(pf)
    800054f6:	c091                	beqz	s1,800054fa <argfd+0x50>
    *pf = f;
    800054f8:	e09c                	sd	a5,0(s1)
}
    800054fa:	70a2                	ld	ra,40(sp)
    800054fc:	7402                	ld	s0,32(sp)
    800054fe:	64e2                	ld	s1,24(sp)
    80005500:	6942                	ld	s2,16(sp)
    80005502:	6145                	addi	sp,sp,48
    80005504:	8082                	ret
    return -1;
    80005506:	557d                	li	a0,-1
    80005508:	bfcd                	j	800054fa <argfd+0x50>
    return -1;
    8000550a:	557d                	li	a0,-1
    8000550c:	b7fd                	j	800054fa <argfd+0x50>
    8000550e:	557d                	li	a0,-1
    80005510:	b7ed                	j	800054fa <argfd+0x50>

0000000080005512 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005512:	1101                	addi	sp,sp,-32
    80005514:	ec06                	sd	ra,24(sp)
    80005516:	e822                	sd	s0,16(sp)
    80005518:	e426                	sd	s1,8(sp)
    8000551a:	1000                	addi	s0,sp,32
    8000551c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000551e:	ffffc097          	auipc	ra,0xffffc
    80005522:	47a080e7          	jalr	1146(ra) # 80001998 <myproc>
    80005526:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005528:	0d050793          	addi	a5,a0,208
    8000552c:	4501                	li	a0,0
    8000552e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005530:	6398                	ld	a4,0(a5)
    80005532:	cb19                	beqz	a4,80005548 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005534:	2505                	addiw	a0,a0,1
    80005536:	07a1                	addi	a5,a5,8
    80005538:	fed51ce3          	bne	a0,a3,80005530 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000553c:	557d                	li	a0,-1
}
    8000553e:	60e2                	ld	ra,24(sp)
    80005540:	6442                	ld	s0,16(sp)
    80005542:	64a2                	ld	s1,8(sp)
    80005544:	6105                	addi	sp,sp,32
    80005546:	8082                	ret
      p->ofile[fd] = f;
    80005548:	01a50793          	addi	a5,a0,26
    8000554c:	078e                	slli	a5,a5,0x3
    8000554e:	963e                	add	a2,a2,a5
    80005550:	e204                	sd	s1,0(a2)
      return fd;
    80005552:	b7f5                	j	8000553e <fdalloc+0x2c>

0000000080005554 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005554:	715d                	addi	sp,sp,-80
    80005556:	e486                	sd	ra,72(sp)
    80005558:	e0a2                	sd	s0,64(sp)
    8000555a:	fc26                	sd	s1,56(sp)
    8000555c:	f84a                	sd	s2,48(sp)
    8000555e:	f44e                	sd	s3,40(sp)
    80005560:	f052                	sd	s4,32(sp)
    80005562:	ec56                	sd	s5,24(sp)
    80005564:	0880                	addi	s0,sp,80
    80005566:	89ae                	mv	s3,a1
    80005568:	8ab2                	mv	s5,a2
    8000556a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000556c:	fb040593          	addi	a1,s0,-80
    80005570:	fffff097          	auipc	ra,0xfffff
    80005574:	e40080e7          	jalr	-448(ra) # 800043b0 <nameiparent>
    80005578:	892a                	mv	s2,a0
    8000557a:	12050e63          	beqz	a0,800056b6 <create+0x162>
    return 0;

  ilock(dp);
    8000557e:	ffffe097          	auipc	ra,0xffffe
    80005582:	65e080e7          	jalr	1630(ra) # 80003bdc <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005586:	4601                	li	a2,0
    80005588:	fb040593          	addi	a1,s0,-80
    8000558c:	854a                	mv	a0,s2
    8000558e:	fffff097          	auipc	ra,0xfffff
    80005592:	b32080e7          	jalr	-1230(ra) # 800040c0 <dirlookup>
    80005596:	84aa                	mv	s1,a0
    80005598:	c921                	beqz	a0,800055e8 <create+0x94>
    iunlockput(dp);
    8000559a:	854a                	mv	a0,s2
    8000559c:	fffff097          	auipc	ra,0xfffff
    800055a0:	8a2080e7          	jalr	-1886(ra) # 80003e3e <iunlockput>
    ilock(ip);
    800055a4:	8526                	mv	a0,s1
    800055a6:	ffffe097          	auipc	ra,0xffffe
    800055aa:	636080e7          	jalr	1590(ra) # 80003bdc <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800055ae:	2981                	sext.w	s3,s3
    800055b0:	4789                	li	a5,2
    800055b2:	02f99463          	bne	s3,a5,800055da <create+0x86>
    800055b6:	0444d783          	lhu	a5,68(s1)
    800055ba:	37f9                	addiw	a5,a5,-2
    800055bc:	17c2                	slli	a5,a5,0x30
    800055be:	93c1                	srli	a5,a5,0x30
    800055c0:	4705                	li	a4,1
    800055c2:	00f76c63          	bltu	a4,a5,800055da <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800055c6:	8526                	mv	a0,s1
    800055c8:	60a6                	ld	ra,72(sp)
    800055ca:	6406                	ld	s0,64(sp)
    800055cc:	74e2                	ld	s1,56(sp)
    800055ce:	7942                	ld	s2,48(sp)
    800055d0:	79a2                	ld	s3,40(sp)
    800055d2:	7a02                	ld	s4,32(sp)
    800055d4:	6ae2                	ld	s5,24(sp)
    800055d6:	6161                	addi	sp,sp,80
    800055d8:	8082                	ret
    iunlockput(ip);
    800055da:	8526                	mv	a0,s1
    800055dc:	fffff097          	auipc	ra,0xfffff
    800055e0:	862080e7          	jalr	-1950(ra) # 80003e3e <iunlockput>
    return 0;
    800055e4:	4481                	li	s1,0
    800055e6:	b7c5                	j	800055c6 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800055e8:	85ce                	mv	a1,s3
    800055ea:	00092503          	lw	a0,0(s2)
    800055ee:	ffffe097          	auipc	ra,0xffffe
    800055f2:	456080e7          	jalr	1110(ra) # 80003a44 <ialloc>
    800055f6:	84aa                	mv	s1,a0
    800055f8:	c521                	beqz	a0,80005640 <create+0xec>
  ilock(ip);
    800055fa:	ffffe097          	auipc	ra,0xffffe
    800055fe:	5e2080e7          	jalr	1506(ra) # 80003bdc <ilock>
  ip->major = major;
    80005602:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005606:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000560a:	4a05                	li	s4,1
    8000560c:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005610:	8526                	mv	a0,s1
    80005612:	ffffe097          	auipc	ra,0xffffe
    80005616:	500080e7          	jalr	1280(ra) # 80003b12 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000561a:	2981                	sext.w	s3,s3
    8000561c:	03498a63          	beq	s3,s4,80005650 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005620:	40d0                	lw	a2,4(s1)
    80005622:	fb040593          	addi	a1,s0,-80
    80005626:	854a                	mv	a0,s2
    80005628:	fffff097          	auipc	ra,0xfffff
    8000562c:	ca8080e7          	jalr	-856(ra) # 800042d0 <dirlink>
    80005630:	06054b63          	bltz	a0,800056a6 <create+0x152>
  iunlockput(dp);
    80005634:	854a                	mv	a0,s2
    80005636:	fffff097          	auipc	ra,0xfffff
    8000563a:	808080e7          	jalr	-2040(ra) # 80003e3e <iunlockput>
  return ip;
    8000563e:	b761                	j	800055c6 <create+0x72>
    panic("create: ialloc");
    80005640:	00003517          	auipc	a0,0x3
    80005644:	16050513          	addi	a0,a0,352 # 800087a0 <syscalls+0x2b8>
    80005648:	ffffb097          	auipc	ra,0xffffb
    8000564c:	ee6080e7          	jalr	-282(ra) # 8000052e <panic>
    dp->nlink++;  // for ".."
    80005650:	04a95783          	lhu	a5,74(s2)
    80005654:	2785                	addiw	a5,a5,1
    80005656:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000565a:	854a                	mv	a0,s2
    8000565c:	ffffe097          	auipc	ra,0xffffe
    80005660:	4b6080e7          	jalr	1206(ra) # 80003b12 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005664:	40d0                	lw	a2,4(s1)
    80005666:	00003597          	auipc	a1,0x3
    8000566a:	14a58593          	addi	a1,a1,330 # 800087b0 <syscalls+0x2c8>
    8000566e:	8526                	mv	a0,s1
    80005670:	fffff097          	auipc	ra,0xfffff
    80005674:	c60080e7          	jalr	-928(ra) # 800042d0 <dirlink>
    80005678:	00054f63          	bltz	a0,80005696 <create+0x142>
    8000567c:	00492603          	lw	a2,4(s2)
    80005680:	00003597          	auipc	a1,0x3
    80005684:	13858593          	addi	a1,a1,312 # 800087b8 <syscalls+0x2d0>
    80005688:	8526                	mv	a0,s1
    8000568a:	fffff097          	auipc	ra,0xfffff
    8000568e:	c46080e7          	jalr	-954(ra) # 800042d0 <dirlink>
    80005692:	f80557e3          	bgez	a0,80005620 <create+0xcc>
      panic("create dots");
    80005696:	00003517          	auipc	a0,0x3
    8000569a:	12a50513          	addi	a0,a0,298 # 800087c0 <syscalls+0x2d8>
    8000569e:	ffffb097          	auipc	ra,0xffffb
    800056a2:	e90080e7          	jalr	-368(ra) # 8000052e <panic>
    panic("create: dirlink");
    800056a6:	00003517          	auipc	a0,0x3
    800056aa:	12a50513          	addi	a0,a0,298 # 800087d0 <syscalls+0x2e8>
    800056ae:	ffffb097          	auipc	ra,0xffffb
    800056b2:	e80080e7          	jalr	-384(ra) # 8000052e <panic>
    return 0;
    800056b6:	84aa                	mv	s1,a0
    800056b8:	b739                	j	800055c6 <create+0x72>

00000000800056ba <sys_dup>:
{
    800056ba:	7179                	addi	sp,sp,-48
    800056bc:	f406                	sd	ra,40(sp)
    800056be:	f022                	sd	s0,32(sp)
    800056c0:	ec26                	sd	s1,24(sp)
    800056c2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800056c4:	fd840613          	addi	a2,s0,-40
    800056c8:	4581                	li	a1,0
    800056ca:	4501                	li	a0,0
    800056cc:	00000097          	auipc	ra,0x0
    800056d0:	dde080e7          	jalr	-546(ra) # 800054aa <argfd>
    return -1;
    800056d4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800056d6:	02054363          	bltz	a0,800056fc <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800056da:	fd843503          	ld	a0,-40(s0)
    800056de:	00000097          	auipc	ra,0x0
    800056e2:	e34080e7          	jalr	-460(ra) # 80005512 <fdalloc>
    800056e6:	84aa                	mv	s1,a0
    return -1;
    800056e8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800056ea:	00054963          	bltz	a0,800056fc <sys_dup+0x42>
  filedup(f);
    800056ee:	fd843503          	ld	a0,-40(s0)
    800056f2:	fffff097          	auipc	ra,0xfffff
    800056f6:	33a080e7          	jalr	826(ra) # 80004a2c <filedup>
  return fd;
    800056fa:	87a6                	mv	a5,s1
}
    800056fc:	853e                	mv	a0,a5
    800056fe:	70a2                	ld	ra,40(sp)
    80005700:	7402                	ld	s0,32(sp)
    80005702:	64e2                	ld	s1,24(sp)
    80005704:	6145                	addi	sp,sp,48
    80005706:	8082                	ret

0000000080005708 <sys_read>:
{
    80005708:	7179                	addi	sp,sp,-48
    8000570a:	f406                	sd	ra,40(sp)
    8000570c:	f022                	sd	s0,32(sp)
    8000570e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005710:	fe840613          	addi	a2,s0,-24
    80005714:	4581                	li	a1,0
    80005716:	4501                	li	a0,0
    80005718:	00000097          	auipc	ra,0x0
    8000571c:	d92080e7          	jalr	-622(ra) # 800054aa <argfd>
    return -1;
    80005720:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005722:	04054163          	bltz	a0,80005764 <sys_read+0x5c>
    80005726:	fe440593          	addi	a1,s0,-28
    8000572a:	4509                	li	a0,2
    8000572c:	ffffe097          	auipc	ra,0xffffe
    80005730:	85c080e7          	jalr	-1956(ra) # 80002f88 <argint>
    return -1;
    80005734:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005736:	02054763          	bltz	a0,80005764 <sys_read+0x5c>
    8000573a:	fd840593          	addi	a1,s0,-40
    8000573e:	4505                	li	a0,1
    80005740:	ffffe097          	auipc	ra,0xffffe
    80005744:	86a080e7          	jalr	-1942(ra) # 80002faa <argaddr>
    return -1;
    80005748:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000574a:	00054d63          	bltz	a0,80005764 <sys_read+0x5c>
  return fileread(f, p, n);
    8000574e:	fe442603          	lw	a2,-28(s0)
    80005752:	fd843583          	ld	a1,-40(s0)
    80005756:	fe843503          	ld	a0,-24(s0)
    8000575a:	fffff097          	auipc	ra,0xfffff
    8000575e:	45e080e7          	jalr	1118(ra) # 80004bb8 <fileread>
    80005762:	87aa                	mv	a5,a0
}
    80005764:	853e                	mv	a0,a5
    80005766:	70a2                	ld	ra,40(sp)
    80005768:	7402                	ld	s0,32(sp)
    8000576a:	6145                	addi	sp,sp,48
    8000576c:	8082                	ret

000000008000576e <sys_write>:
{
    8000576e:	7179                	addi	sp,sp,-48
    80005770:	f406                	sd	ra,40(sp)
    80005772:	f022                	sd	s0,32(sp)
    80005774:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005776:	fe840613          	addi	a2,s0,-24
    8000577a:	4581                	li	a1,0
    8000577c:	4501                	li	a0,0
    8000577e:	00000097          	auipc	ra,0x0
    80005782:	d2c080e7          	jalr	-724(ra) # 800054aa <argfd>
    return -1;
    80005786:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005788:	04054163          	bltz	a0,800057ca <sys_write+0x5c>
    8000578c:	fe440593          	addi	a1,s0,-28
    80005790:	4509                	li	a0,2
    80005792:	ffffd097          	auipc	ra,0xffffd
    80005796:	7f6080e7          	jalr	2038(ra) # 80002f88 <argint>
    return -1;
    8000579a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000579c:	02054763          	bltz	a0,800057ca <sys_write+0x5c>
    800057a0:	fd840593          	addi	a1,s0,-40
    800057a4:	4505                	li	a0,1
    800057a6:	ffffe097          	auipc	ra,0xffffe
    800057aa:	804080e7          	jalr	-2044(ra) # 80002faa <argaddr>
    return -1;
    800057ae:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057b0:	00054d63          	bltz	a0,800057ca <sys_write+0x5c>
  return filewrite(f, p, n);
    800057b4:	fe442603          	lw	a2,-28(s0)
    800057b8:	fd843583          	ld	a1,-40(s0)
    800057bc:	fe843503          	ld	a0,-24(s0)
    800057c0:	fffff097          	auipc	ra,0xfffff
    800057c4:	4ba080e7          	jalr	1210(ra) # 80004c7a <filewrite>
    800057c8:	87aa                	mv	a5,a0
}
    800057ca:	853e                	mv	a0,a5
    800057cc:	70a2                	ld	ra,40(sp)
    800057ce:	7402                	ld	s0,32(sp)
    800057d0:	6145                	addi	sp,sp,48
    800057d2:	8082                	ret

00000000800057d4 <sys_close>:
{
    800057d4:	1101                	addi	sp,sp,-32
    800057d6:	ec06                	sd	ra,24(sp)
    800057d8:	e822                	sd	s0,16(sp)
    800057da:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800057dc:	fe040613          	addi	a2,s0,-32
    800057e0:	fec40593          	addi	a1,s0,-20
    800057e4:	4501                	li	a0,0
    800057e6:	00000097          	auipc	ra,0x0
    800057ea:	cc4080e7          	jalr	-828(ra) # 800054aa <argfd>
    return -1;
    800057ee:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800057f0:	02054463          	bltz	a0,80005818 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800057f4:	ffffc097          	auipc	ra,0xffffc
    800057f8:	1a4080e7          	jalr	420(ra) # 80001998 <myproc>
    800057fc:	fec42783          	lw	a5,-20(s0)
    80005800:	07e9                	addi	a5,a5,26
    80005802:	078e                	slli	a5,a5,0x3
    80005804:	97aa                	add	a5,a5,a0
    80005806:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000580a:	fe043503          	ld	a0,-32(s0)
    8000580e:	fffff097          	auipc	ra,0xfffff
    80005812:	270080e7          	jalr	624(ra) # 80004a7e <fileclose>
  return 0;
    80005816:	4781                	li	a5,0
}
    80005818:	853e                	mv	a0,a5
    8000581a:	60e2                	ld	ra,24(sp)
    8000581c:	6442                	ld	s0,16(sp)
    8000581e:	6105                	addi	sp,sp,32
    80005820:	8082                	ret

0000000080005822 <sys_fstat>:
{
    80005822:	1101                	addi	sp,sp,-32
    80005824:	ec06                	sd	ra,24(sp)
    80005826:	e822                	sd	s0,16(sp)
    80005828:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000582a:	fe840613          	addi	a2,s0,-24
    8000582e:	4581                	li	a1,0
    80005830:	4501                	li	a0,0
    80005832:	00000097          	auipc	ra,0x0
    80005836:	c78080e7          	jalr	-904(ra) # 800054aa <argfd>
    return -1;
    8000583a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000583c:	02054563          	bltz	a0,80005866 <sys_fstat+0x44>
    80005840:	fe040593          	addi	a1,s0,-32
    80005844:	4505                	li	a0,1
    80005846:	ffffd097          	auipc	ra,0xffffd
    8000584a:	764080e7          	jalr	1892(ra) # 80002faa <argaddr>
    return -1;
    8000584e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005850:	00054b63          	bltz	a0,80005866 <sys_fstat+0x44>
  return filestat(f, st);
    80005854:	fe043583          	ld	a1,-32(s0)
    80005858:	fe843503          	ld	a0,-24(s0)
    8000585c:	fffff097          	auipc	ra,0xfffff
    80005860:	2ea080e7          	jalr	746(ra) # 80004b46 <filestat>
    80005864:	87aa                	mv	a5,a0
}
    80005866:	853e                	mv	a0,a5
    80005868:	60e2                	ld	ra,24(sp)
    8000586a:	6442                	ld	s0,16(sp)
    8000586c:	6105                	addi	sp,sp,32
    8000586e:	8082                	ret

0000000080005870 <sys_link>:
{
    80005870:	7169                	addi	sp,sp,-304
    80005872:	f606                	sd	ra,296(sp)
    80005874:	f222                	sd	s0,288(sp)
    80005876:	ee26                	sd	s1,280(sp)
    80005878:	ea4a                	sd	s2,272(sp)
    8000587a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000587c:	08000613          	li	a2,128
    80005880:	ed040593          	addi	a1,s0,-304
    80005884:	4501                	li	a0,0
    80005886:	ffffd097          	auipc	ra,0xffffd
    8000588a:	746080e7          	jalr	1862(ra) # 80002fcc <argstr>
    return -1;
    8000588e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005890:	10054e63          	bltz	a0,800059ac <sys_link+0x13c>
    80005894:	08000613          	li	a2,128
    80005898:	f5040593          	addi	a1,s0,-176
    8000589c:	4505                	li	a0,1
    8000589e:	ffffd097          	auipc	ra,0xffffd
    800058a2:	72e080e7          	jalr	1838(ra) # 80002fcc <argstr>
    return -1;
    800058a6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058a8:	10054263          	bltz	a0,800059ac <sys_link+0x13c>
  begin_op();
    800058ac:	fffff097          	auipc	ra,0xfffff
    800058b0:	d06080e7          	jalr	-762(ra) # 800045b2 <begin_op>
  if((ip = namei(old)) == 0){
    800058b4:	ed040513          	addi	a0,s0,-304
    800058b8:	fffff097          	auipc	ra,0xfffff
    800058bc:	ada080e7          	jalr	-1318(ra) # 80004392 <namei>
    800058c0:	84aa                	mv	s1,a0
    800058c2:	c551                	beqz	a0,8000594e <sys_link+0xde>
  ilock(ip);
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	318080e7          	jalr	792(ra) # 80003bdc <ilock>
  if(ip->type == T_DIR){
    800058cc:	04449703          	lh	a4,68(s1)
    800058d0:	4785                	li	a5,1
    800058d2:	08f70463          	beq	a4,a5,8000595a <sys_link+0xea>
  ip->nlink++;
    800058d6:	04a4d783          	lhu	a5,74(s1)
    800058da:	2785                	addiw	a5,a5,1
    800058dc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058e0:	8526                	mv	a0,s1
    800058e2:	ffffe097          	auipc	ra,0xffffe
    800058e6:	230080e7          	jalr	560(ra) # 80003b12 <iupdate>
  iunlock(ip);
    800058ea:	8526                	mv	a0,s1
    800058ec:	ffffe097          	auipc	ra,0xffffe
    800058f0:	3b2080e7          	jalr	946(ra) # 80003c9e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800058f4:	fd040593          	addi	a1,s0,-48
    800058f8:	f5040513          	addi	a0,s0,-176
    800058fc:	fffff097          	auipc	ra,0xfffff
    80005900:	ab4080e7          	jalr	-1356(ra) # 800043b0 <nameiparent>
    80005904:	892a                	mv	s2,a0
    80005906:	c935                	beqz	a0,8000597a <sys_link+0x10a>
  ilock(dp);
    80005908:	ffffe097          	auipc	ra,0xffffe
    8000590c:	2d4080e7          	jalr	724(ra) # 80003bdc <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005910:	00092703          	lw	a4,0(s2)
    80005914:	409c                	lw	a5,0(s1)
    80005916:	04f71d63          	bne	a4,a5,80005970 <sys_link+0x100>
    8000591a:	40d0                	lw	a2,4(s1)
    8000591c:	fd040593          	addi	a1,s0,-48
    80005920:	854a                	mv	a0,s2
    80005922:	fffff097          	auipc	ra,0xfffff
    80005926:	9ae080e7          	jalr	-1618(ra) # 800042d0 <dirlink>
    8000592a:	04054363          	bltz	a0,80005970 <sys_link+0x100>
  iunlockput(dp);
    8000592e:	854a                	mv	a0,s2
    80005930:	ffffe097          	auipc	ra,0xffffe
    80005934:	50e080e7          	jalr	1294(ra) # 80003e3e <iunlockput>
  iput(ip);
    80005938:	8526                	mv	a0,s1
    8000593a:	ffffe097          	auipc	ra,0xffffe
    8000593e:	45c080e7          	jalr	1116(ra) # 80003d96 <iput>
  end_op();
    80005942:	fffff097          	auipc	ra,0xfffff
    80005946:	cf0080e7          	jalr	-784(ra) # 80004632 <end_op>
  return 0;
    8000594a:	4781                	li	a5,0
    8000594c:	a085                	j	800059ac <sys_link+0x13c>
    end_op();
    8000594e:	fffff097          	auipc	ra,0xfffff
    80005952:	ce4080e7          	jalr	-796(ra) # 80004632 <end_op>
    return -1;
    80005956:	57fd                	li	a5,-1
    80005958:	a891                	j	800059ac <sys_link+0x13c>
    iunlockput(ip);
    8000595a:	8526                	mv	a0,s1
    8000595c:	ffffe097          	auipc	ra,0xffffe
    80005960:	4e2080e7          	jalr	1250(ra) # 80003e3e <iunlockput>
    end_op();
    80005964:	fffff097          	auipc	ra,0xfffff
    80005968:	cce080e7          	jalr	-818(ra) # 80004632 <end_op>
    return -1;
    8000596c:	57fd                	li	a5,-1
    8000596e:	a83d                	j	800059ac <sys_link+0x13c>
    iunlockput(dp);
    80005970:	854a                	mv	a0,s2
    80005972:	ffffe097          	auipc	ra,0xffffe
    80005976:	4cc080e7          	jalr	1228(ra) # 80003e3e <iunlockput>
  ilock(ip);
    8000597a:	8526                	mv	a0,s1
    8000597c:	ffffe097          	auipc	ra,0xffffe
    80005980:	260080e7          	jalr	608(ra) # 80003bdc <ilock>
  ip->nlink--;
    80005984:	04a4d783          	lhu	a5,74(s1)
    80005988:	37fd                	addiw	a5,a5,-1
    8000598a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000598e:	8526                	mv	a0,s1
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	182080e7          	jalr	386(ra) # 80003b12 <iupdate>
  iunlockput(ip);
    80005998:	8526                	mv	a0,s1
    8000599a:	ffffe097          	auipc	ra,0xffffe
    8000599e:	4a4080e7          	jalr	1188(ra) # 80003e3e <iunlockput>
  end_op();
    800059a2:	fffff097          	auipc	ra,0xfffff
    800059a6:	c90080e7          	jalr	-880(ra) # 80004632 <end_op>
  return -1;
    800059aa:	57fd                	li	a5,-1
}
    800059ac:	853e                	mv	a0,a5
    800059ae:	70b2                	ld	ra,296(sp)
    800059b0:	7412                	ld	s0,288(sp)
    800059b2:	64f2                	ld	s1,280(sp)
    800059b4:	6952                	ld	s2,272(sp)
    800059b6:	6155                	addi	sp,sp,304
    800059b8:	8082                	ret

00000000800059ba <sys_unlink>:
{
    800059ba:	7151                	addi	sp,sp,-240
    800059bc:	f586                	sd	ra,232(sp)
    800059be:	f1a2                	sd	s0,224(sp)
    800059c0:	eda6                	sd	s1,216(sp)
    800059c2:	e9ca                	sd	s2,208(sp)
    800059c4:	e5ce                	sd	s3,200(sp)
    800059c6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800059c8:	08000613          	li	a2,128
    800059cc:	f3040593          	addi	a1,s0,-208
    800059d0:	4501                	li	a0,0
    800059d2:	ffffd097          	auipc	ra,0xffffd
    800059d6:	5fa080e7          	jalr	1530(ra) # 80002fcc <argstr>
    800059da:	18054163          	bltz	a0,80005b5c <sys_unlink+0x1a2>
  begin_op();
    800059de:	fffff097          	auipc	ra,0xfffff
    800059e2:	bd4080e7          	jalr	-1068(ra) # 800045b2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800059e6:	fb040593          	addi	a1,s0,-80
    800059ea:	f3040513          	addi	a0,s0,-208
    800059ee:	fffff097          	auipc	ra,0xfffff
    800059f2:	9c2080e7          	jalr	-1598(ra) # 800043b0 <nameiparent>
    800059f6:	84aa                	mv	s1,a0
    800059f8:	c979                	beqz	a0,80005ace <sys_unlink+0x114>
  ilock(dp);
    800059fa:	ffffe097          	auipc	ra,0xffffe
    800059fe:	1e2080e7          	jalr	482(ra) # 80003bdc <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a02:	00003597          	auipc	a1,0x3
    80005a06:	dae58593          	addi	a1,a1,-594 # 800087b0 <syscalls+0x2c8>
    80005a0a:	fb040513          	addi	a0,s0,-80
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	698080e7          	jalr	1688(ra) # 800040a6 <namecmp>
    80005a16:	14050a63          	beqz	a0,80005b6a <sys_unlink+0x1b0>
    80005a1a:	00003597          	auipc	a1,0x3
    80005a1e:	d9e58593          	addi	a1,a1,-610 # 800087b8 <syscalls+0x2d0>
    80005a22:	fb040513          	addi	a0,s0,-80
    80005a26:	ffffe097          	auipc	ra,0xffffe
    80005a2a:	680080e7          	jalr	1664(ra) # 800040a6 <namecmp>
    80005a2e:	12050e63          	beqz	a0,80005b6a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a32:	f2c40613          	addi	a2,s0,-212
    80005a36:	fb040593          	addi	a1,s0,-80
    80005a3a:	8526                	mv	a0,s1
    80005a3c:	ffffe097          	auipc	ra,0xffffe
    80005a40:	684080e7          	jalr	1668(ra) # 800040c0 <dirlookup>
    80005a44:	892a                	mv	s2,a0
    80005a46:	12050263          	beqz	a0,80005b6a <sys_unlink+0x1b0>
  ilock(ip);
    80005a4a:	ffffe097          	auipc	ra,0xffffe
    80005a4e:	192080e7          	jalr	402(ra) # 80003bdc <ilock>
  if(ip->nlink < 1)
    80005a52:	04a91783          	lh	a5,74(s2)
    80005a56:	08f05263          	blez	a5,80005ada <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a5a:	04491703          	lh	a4,68(s2)
    80005a5e:	4785                	li	a5,1
    80005a60:	08f70563          	beq	a4,a5,80005aea <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005a64:	4641                	li	a2,16
    80005a66:	4581                	li	a1,0
    80005a68:	fc040513          	addi	a0,s0,-64
    80005a6c:	ffffb097          	auipc	ra,0xffffb
    80005a70:	26c080e7          	jalr	620(ra) # 80000cd8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a74:	4741                	li	a4,16
    80005a76:	f2c42683          	lw	a3,-212(s0)
    80005a7a:	fc040613          	addi	a2,s0,-64
    80005a7e:	4581                	li	a1,0
    80005a80:	8526                	mv	a0,s1
    80005a82:	ffffe097          	auipc	ra,0xffffe
    80005a86:	506080e7          	jalr	1286(ra) # 80003f88 <writei>
    80005a8a:	47c1                	li	a5,16
    80005a8c:	0af51563          	bne	a0,a5,80005b36 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005a90:	04491703          	lh	a4,68(s2)
    80005a94:	4785                	li	a5,1
    80005a96:	0af70863          	beq	a4,a5,80005b46 <sys_unlink+0x18c>
  iunlockput(dp);
    80005a9a:	8526                	mv	a0,s1
    80005a9c:	ffffe097          	auipc	ra,0xffffe
    80005aa0:	3a2080e7          	jalr	930(ra) # 80003e3e <iunlockput>
  ip->nlink--;
    80005aa4:	04a95783          	lhu	a5,74(s2)
    80005aa8:	37fd                	addiw	a5,a5,-1
    80005aaa:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005aae:	854a                	mv	a0,s2
    80005ab0:	ffffe097          	auipc	ra,0xffffe
    80005ab4:	062080e7          	jalr	98(ra) # 80003b12 <iupdate>
  iunlockput(ip);
    80005ab8:	854a                	mv	a0,s2
    80005aba:	ffffe097          	auipc	ra,0xffffe
    80005abe:	384080e7          	jalr	900(ra) # 80003e3e <iunlockput>
  end_op();
    80005ac2:	fffff097          	auipc	ra,0xfffff
    80005ac6:	b70080e7          	jalr	-1168(ra) # 80004632 <end_op>
  return 0;
    80005aca:	4501                	li	a0,0
    80005acc:	a84d                	j	80005b7e <sys_unlink+0x1c4>
    end_op();
    80005ace:	fffff097          	auipc	ra,0xfffff
    80005ad2:	b64080e7          	jalr	-1180(ra) # 80004632 <end_op>
    return -1;
    80005ad6:	557d                	li	a0,-1
    80005ad8:	a05d                	j	80005b7e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005ada:	00003517          	auipc	a0,0x3
    80005ade:	d0650513          	addi	a0,a0,-762 # 800087e0 <syscalls+0x2f8>
    80005ae2:	ffffb097          	auipc	ra,0xffffb
    80005ae6:	a4c080e7          	jalr	-1460(ra) # 8000052e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005aea:	04c92703          	lw	a4,76(s2)
    80005aee:	02000793          	li	a5,32
    80005af2:	f6e7f9e3          	bgeu	a5,a4,80005a64 <sys_unlink+0xaa>
    80005af6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005afa:	4741                	li	a4,16
    80005afc:	86ce                	mv	a3,s3
    80005afe:	f1840613          	addi	a2,s0,-232
    80005b02:	4581                	li	a1,0
    80005b04:	854a                	mv	a0,s2
    80005b06:	ffffe097          	auipc	ra,0xffffe
    80005b0a:	38a080e7          	jalr	906(ra) # 80003e90 <readi>
    80005b0e:	47c1                	li	a5,16
    80005b10:	00f51b63          	bne	a0,a5,80005b26 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005b14:	f1845783          	lhu	a5,-232(s0)
    80005b18:	e7a1                	bnez	a5,80005b60 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b1a:	29c1                	addiw	s3,s3,16
    80005b1c:	04c92783          	lw	a5,76(s2)
    80005b20:	fcf9ede3          	bltu	s3,a5,80005afa <sys_unlink+0x140>
    80005b24:	b781                	j	80005a64 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b26:	00003517          	auipc	a0,0x3
    80005b2a:	cd250513          	addi	a0,a0,-814 # 800087f8 <syscalls+0x310>
    80005b2e:	ffffb097          	auipc	ra,0xffffb
    80005b32:	a00080e7          	jalr	-1536(ra) # 8000052e <panic>
    panic("unlink: writei");
    80005b36:	00003517          	auipc	a0,0x3
    80005b3a:	cda50513          	addi	a0,a0,-806 # 80008810 <syscalls+0x328>
    80005b3e:	ffffb097          	auipc	ra,0xffffb
    80005b42:	9f0080e7          	jalr	-1552(ra) # 8000052e <panic>
    dp->nlink--;
    80005b46:	04a4d783          	lhu	a5,74(s1)
    80005b4a:	37fd                	addiw	a5,a5,-1
    80005b4c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b50:	8526                	mv	a0,s1
    80005b52:	ffffe097          	auipc	ra,0xffffe
    80005b56:	fc0080e7          	jalr	-64(ra) # 80003b12 <iupdate>
    80005b5a:	b781                	j	80005a9a <sys_unlink+0xe0>
    return -1;
    80005b5c:	557d                	li	a0,-1
    80005b5e:	a005                	j	80005b7e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005b60:	854a                	mv	a0,s2
    80005b62:	ffffe097          	auipc	ra,0xffffe
    80005b66:	2dc080e7          	jalr	732(ra) # 80003e3e <iunlockput>
  iunlockput(dp);
    80005b6a:	8526                	mv	a0,s1
    80005b6c:	ffffe097          	auipc	ra,0xffffe
    80005b70:	2d2080e7          	jalr	722(ra) # 80003e3e <iunlockput>
  end_op();
    80005b74:	fffff097          	auipc	ra,0xfffff
    80005b78:	abe080e7          	jalr	-1346(ra) # 80004632 <end_op>
  return -1;
    80005b7c:	557d                	li	a0,-1
}
    80005b7e:	70ae                	ld	ra,232(sp)
    80005b80:	740e                	ld	s0,224(sp)
    80005b82:	64ee                	ld	s1,216(sp)
    80005b84:	694e                	ld	s2,208(sp)
    80005b86:	69ae                	ld	s3,200(sp)
    80005b88:	616d                	addi	sp,sp,240
    80005b8a:	8082                	ret

0000000080005b8c <sys_open>:

uint64
sys_open(void)
{
    80005b8c:	7131                	addi	sp,sp,-192
    80005b8e:	fd06                	sd	ra,184(sp)
    80005b90:	f922                	sd	s0,176(sp)
    80005b92:	f526                	sd	s1,168(sp)
    80005b94:	f14a                	sd	s2,160(sp)
    80005b96:	ed4e                	sd	s3,152(sp)
    80005b98:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005b9a:	08000613          	li	a2,128
    80005b9e:	f5040593          	addi	a1,s0,-176
    80005ba2:	4501                	li	a0,0
    80005ba4:	ffffd097          	auipc	ra,0xffffd
    80005ba8:	428080e7          	jalr	1064(ra) # 80002fcc <argstr>
    return -1;
    80005bac:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005bae:	0c054163          	bltz	a0,80005c70 <sys_open+0xe4>
    80005bb2:	f4c40593          	addi	a1,s0,-180
    80005bb6:	4505                	li	a0,1
    80005bb8:	ffffd097          	auipc	ra,0xffffd
    80005bbc:	3d0080e7          	jalr	976(ra) # 80002f88 <argint>
    80005bc0:	0a054863          	bltz	a0,80005c70 <sys_open+0xe4>

  begin_op();
    80005bc4:	fffff097          	auipc	ra,0xfffff
    80005bc8:	9ee080e7          	jalr	-1554(ra) # 800045b2 <begin_op>

  if(omode & O_CREATE){
    80005bcc:	f4c42783          	lw	a5,-180(s0)
    80005bd0:	2007f793          	andi	a5,a5,512
    80005bd4:	cbdd                	beqz	a5,80005c8a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005bd6:	4681                	li	a3,0
    80005bd8:	4601                	li	a2,0
    80005bda:	4589                	li	a1,2
    80005bdc:	f5040513          	addi	a0,s0,-176
    80005be0:	00000097          	auipc	ra,0x0
    80005be4:	974080e7          	jalr	-1676(ra) # 80005554 <create>
    80005be8:	892a                	mv	s2,a0
    if(ip == 0){
    80005bea:	c959                	beqz	a0,80005c80 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005bec:	04491703          	lh	a4,68(s2)
    80005bf0:	478d                	li	a5,3
    80005bf2:	00f71763          	bne	a4,a5,80005c00 <sys_open+0x74>
    80005bf6:	04695703          	lhu	a4,70(s2)
    80005bfa:	47a5                	li	a5,9
    80005bfc:	0ce7ec63          	bltu	a5,a4,80005cd4 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c00:	fffff097          	auipc	ra,0xfffff
    80005c04:	dc2080e7          	jalr	-574(ra) # 800049c2 <filealloc>
    80005c08:	89aa                	mv	s3,a0
    80005c0a:	10050263          	beqz	a0,80005d0e <sys_open+0x182>
    80005c0e:	00000097          	auipc	ra,0x0
    80005c12:	904080e7          	jalr	-1788(ra) # 80005512 <fdalloc>
    80005c16:	84aa                	mv	s1,a0
    80005c18:	0e054663          	bltz	a0,80005d04 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c1c:	04491703          	lh	a4,68(s2)
    80005c20:	478d                	li	a5,3
    80005c22:	0cf70463          	beq	a4,a5,80005cea <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c26:	4789                	li	a5,2
    80005c28:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c2c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c30:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c34:	f4c42783          	lw	a5,-180(s0)
    80005c38:	0017c713          	xori	a4,a5,1
    80005c3c:	8b05                	andi	a4,a4,1
    80005c3e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c42:	0037f713          	andi	a4,a5,3
    80005c46:	00e03733          	snez	a4,a4
    80005c4a:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c4e:	4007f793          	andi	a5,a5,1024
    80005c52:	c791                	beqz	a5,80005c5e <sys_open+0xd2>
    80005c54:	04491703          	lh	a4,68(s2)
    80005c58:	4789                	li	a5,2
    80005c5a:	08f70f63          	beq	a4,a5,80005cf8 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c5e:	854a                	mv	a0,s2
    80005c60:	ffffe097          	auipc	ra,0xffffe
    80005c64:	03e080e7          	jalr	62(ra) # 80003c9e <iunlock>
  end_op();
    80005c68:	fffff097          	auipc	ra,0xfffff
    80005c6c:	9ca080e7          	jalr	-1590(ra) # 80004632 <end_op>

  return fd;
}
    80005c70:	8526                	mv	a0,s1
    80005c72:	70ea                	ld	ra,184(sp)
    80005c74:	744a                	ld	s0,176(sp)
    80005c76:	74aa                	ld	s1,168(sp)
    80005c78:	790a                	ld	s2,160(sp)
    80005c7a:	69ea                	ld	s3,152(sp)
    80005c7c:	6129                	addi	sp,sp,192
    80005c7e:	8082                	ret
      end_op();
    80005c80:	fffff097          	auipc	ra,0xfffff
    80005c84:	9b2080e7          	jalr	-1614(ra) # 80004632 <end_op>
      return -1;
    80005c88:	b7e5                	j	80005c70 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005c8a:	f5040513          	addi	a0,s0,-176
    80005c8e:	ffffe097          	auipc	ra,0xffffe
    80005c92:	704080e7          	jalr	1796(ra) # 80004392 <namei>
    80005c96:	892a                	mv	s2,a0
    80005c98:	c905                	beqz	a0,80005cc8 <sys_open+0x13c>
    ilock(ip);
    80005c9a:	ffffe097          	auipc	ra,0xffffe
    80005c9e:	f42080e7          	jalr	-190(ra) # 80003bdc <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005ca2:	04491703          	lh	a4,68(s2)
    80005ca6:	4785                	li	a5,1
    80005ca8:	f4f712e3          	bne	a4,a5,80005bec <sys_open+0x60>
    80005cac:	f4c42783          	lw	a5,-180(s0)
    80005cb0:	dba1                	beqz	a5,80005c00 <sys_open+0x74>
      iunlockput(ip);
    80005cb2:	854a                	mv	a0,s2
    80005cb4:	ffffe097          	auipc	ra,0xffffe
    80005cb8:	18a080e7          	jalr	394(ra) # 80003e3e <iunlockput>
      end_op();
    80005cbc:	fffff097          	auipc	ra,0xfffff
    80005cc0:	976080e7          	jalr	-1674(ra) # 80004632 <end_op>
      return -1;
    80005cc4:	54fd                	li	s1,-1
    80005cc6:	b76d                	j	80005c70 <sys_open+0xe4>
      end_op();
    80005cc8:	fffff097          	auipc	ra,0xfffff
    80005ccc:	96a080e7          	jalr	-1686(ra) # 80004632 <end_op>
      return -1;
    80005cd0:	54fd                	li	s1,-1
    80005cd2:	bf79                	j	80005c70 <sys_open+0xe4>
    iunlockput(ip);
    80005cd4:	854a                	mv	a0,s2
    80005cd6:	ffffe097          	auipc	ra,0xffffe
    80005cda:	168080e7          	jalr	360(ra) # 80003e3e <iunlockput>
    end_op();
    80005cde:	fffff097          	auipc	ra,0xfffff
    80005ce2:	954080e7          	jalr	-1708(ra) # 80004632 <end_op>
    return -1;
    80005ce6:	54fd                	li	s1,-1
    80005ce8:	b761                	j	80005c70 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005cea:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005cee:	04691783          	lh	a5,70(s2)
    80005cf2:	02f99223          	sh	a5,36(s3)
    80005cf6:	bf2d                	j	80005c30 <sys_open+0xa4>
    itrunc(ip);
    80005cf8:	854a                	mv	a0,s2
    80005cfa:	ffffe097          	auipc	ra,0xffffe
    80005cfe:	ff0080e7          	jalr	-16(ra) # 80003cea <itrunc>
    80005d02:	bfb1                	j	80005c5e <sys_open+0xd2>
      fileclose(f);
    80005d04:	854e                	mv	a0,s3
    80005d06:	fffff097          	auipc	ra,0xfffff
    80005d0a:	d78080e7          	jalr	-648(ra) # 80004a7e <fileclose>
    iunlockput(ip);
    80005d0e:	854a                	mv	a0,s2
    80005d10:	ffffe097          	auipc	ra,0xffffe
    80005d14:	12e080e7          	jalr	302(ra) # 80003e3e <iunlockput>
    end_op();
    80005d18:	fffff097          	auipc	ra,0xfffff
    80005d1c:	91a080e7          	jalr	-1766(ra) # 80004632 <end_op>
    return -1;
    80005d20:	54fd                	li	s1,-1
    80005d22:	b7b9                	j	80005c70 <sys_open+0xe4>

0000000080005d24 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d24:	7175                	addi	sp,sp,-144
    80005d26:	e506                	sd	ra,136(sp)
    80005d28:	e122                	sd	s0,128(sp)
    80005d2a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d2c:	fffff097          	auipc	ra,0xfffff
    80005d30:	886080e7          	jalr	-1914(ra) # 800045b2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d34:	08000613          	li	a2,128
    80005d38:	f7040593          	addi	a1,s0,-144
    80005d3c:	4501                	li	a0,0
    80005d3e:	ffffd097          	auipc	ra,0xffffd
    80005d42:	28e080e7          	jalr	654(ra) # 80002fcc <argstr>
    80005d46:	02054963          	bltz	a0,80005d78 <sys_mkdir+0x54>
    80005d4a:	4681                	li	a3,0
    80005d4c:	4601                	li	a2,0
    80005d4e:	4585                	li	a1,1
    80005d50:	f7040513          	addi	a0,s0,-144
    80005d54:	00000097          	auipc	ra,0x0
    80005d58:	800080e7          	jalr	-2048(ra) # 80005554 <create>
    80005d5c:	cd11                	beqz	a0,80005d78 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d5e:	ffffe097          	auipc	ra,0xffffe
    80005d62:	0e0080e7          	jalr	224(ra) # 80003e3e <iunlockput>
  end_op();
    80005d66:	fffff097          	auipc	ra,0xfffff
    80005d6a:	8cc080e7          	jalr	-1844(ra) # 80004632 <end_op>
  return 0;
    80005d6e:	4501                	li	a0,0
}
    80005d70:	60aa                	ld	ra,136(sp)
    80005d72:	640a                	ld	s0,128(sp)
    80005d74:	6149                	addi	sp,sp,144
    80005d76:	8082                	ret
    end_op();
    80005d78:	fffff097          	auipc	ra,0xfffff
    80005d7c:	8ba080e7          	jalr	-1862(ra) # 80004632 <end_op>
    return -1;
    80005d80:	557d                	li	a0,-1
    80005d82:	b7fd                	j	80005d70 <sys_mkdir+0x4c>

0000000080005d84 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d84:	7135                	addi	sp,sp,-160
    80005d86:	ed06                	sd	ra,152(sp)
    80005d88:	e922                	sd	s0,144(sp)
    80005d8a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d8c:	fffff097          	auipc	ra,0xfffff
    80005d90:	826080e7          	jalr	-2010(ra) # 800045b2 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d94:	08000613          	li	a2,128
    80005d98:	f7040593          	addi	a1,s0,-144
    80005d9c:	4501                	li	a0,0
    80005d9e:	ffffd097          	auipc	ra,0xffffd
    80005da2:	22e080e7          	jalr	558(ra) # 80002fcc <argstr>
    80005da6:	04054a63          	bltz	a0,80005dfa <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005daa:	f6c40593          	addi	a1,s0,-148
    80005dae:	4505                	li	a0,1
    80005db0:	ffffd097          	auipc	ra,0xffffd
    80005db4:	1d8080e7          	jalr	472(ra) # 80002f88 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005db8:	04054163          	bltz	a0,80005dfa <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005dbc:	f6840593          	addi	a1,s0,-152
    80005dc0:	4509                	li	a0,2
    80005dc2:	ffffd097          	auipc	ra,0xffffd
    80005dc6:	1c6080e7          	jalr	454(ra) # 80002f88 <argint>
     argint(1, &major) < 0 ||
    80005dca:	02054863          	bltz	a0,80005dfa <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005dce:	f6841683          	lh	a3,-152(s0)
    80005dd2:	f6c41603          	lh	a2,-148(s0)
    80005dd6:	458d                	li	a1,3
    80005dd8:	f7040513          	addi	a0,s0,-144
    80005ddc:	fffff097          	auipc	ra,0xfffff
    80005de0:	778080e7          	jalr	1912(ra) # 80005554 <create>
     argint(2, &minor) < 0 ||
    80005de4:	c919                	beqz	a0,80005dfa <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005de6:	ffffe097          	auipc	ra,0xffffe
    80005dea:	058080e7          	jalr	88(ra) # 80003e3e <iunlockput>
  end_op();
    80005dee:	fffff097          	auipc	ra,0xfffff
    80005df2:	844080e7          	jalr	-1980(ra) # 80004632 <end_op>
  return 0;
    80005df6:	4501                	li	a0,0
    80005df8:	a031                	j	80005e04 <sys_mknod+0x80>
    end_op();
    80005dfa:	fffff097          	auipc	ra,0xfffff
    80005dfe:	838080e7          	jalr	-1992(ra) # 80004632 <end_op>
    return -1;
    80005e02:	557d                	li	a0,-1
}
    80005e04:	60ea                	ld	ra,152(sp)
    80005e06:	644a                	ld	s0,144(sp)
    80005e08:	610d                	addi	sp,sp,160
    80005e0a:	8082                	ret

0000000080005e0c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e0c:	7135                	addi	sp,sp,-160
    80005e0e:	ed06                	sd	ra,152(sp)
    80005e10:	e922                	sd	s0,144(sp)
    80005e12:	e526                	sd	s1,136(sp)
    80005e14:	e14a                	sd	s2,128(sp)
    80005e16:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e18:	ffffc097          	auipc	ra,0xffffc
    80005e1c:	b80080e7          	jalr	-1152(ra) # 80001998 <myproc>
    80005e20:	892a                	mv	s2,a0
  
  begin_op();
    80005e22:	ffffe097          	auipc	ra,0xffffe
    80005e26:	790080e7          	jalr	1936(ra) # 800045b2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e2a:	08000613          	li	a2,128
    80005e2e:	f6040593          	addi	a1,s0,-160
    80005e32:	4501                	li	a0,0
    80005e34:	ffffd097          	auipc	ra,0xffffd
    80005e38:	198080e7          	jalr	408(ra) # 80002fcc <argstr>
    80005e3c:	04054b63          	bltz	a0,80005e92 <sys_chdir+0x86>
    80005e40:	f6040513          	addi	a0,s0,-160
    80005e44:	ffffe097          	auipc	ra,0xffffe
    80005e48:	54e080e7          	jalr	1358(ra) # 80004392 <namei>
    80005e4c:	84aa                	mv	s1,a0
    80005e4e:	c131                	beqz	a0,80005e92 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e50:	ffffe097          	auipc	ra,0xffffe
    80005e54:	d8c080e7          	jalr	-628(ra) # 80003bdc <ilock>
  if(ip->type != T_DIR){
    80005e58:	04449703          	lh	a4,68(s1)
    80005e5c:	4785                	li	a5,1
    80005e5e:	04f71063          	bne	a4,a5,80005e9e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005e62:	8526                	mv	a0,s1
    80005e64:	ffffe097          	auipc	ra,0xffffe
    80005e68:	e3a080e7          	jalr	-454(ra) # 80003c9e <iunlock>
  iput(p->cwd);
    80005e6c:	15093503          	ld	a0,336(s2)
    80005e70:	ffffe097          	auipc	ra,0xffffe
    80005e74:	f26080e7          	jalr	-218(ra) # 80003d96 <iput>
  end_op();
    80005e78:	ffffe097          	auipc	ra,0xffffe
    80005e7c:	7ba080e7          	jalr	1978(ra) # 80004632 <end_op>
  p->cwd = ip;
    80005e80:	14993823          	sd	s1,336(s2)
  return 0;
    80005e84:	4501                	li	a0,0
}
    80005e86:	60ea                	ld	ra,152(sp)
    80005e88:	644a                	ld	s0,144(sp)
    80005e8a:	64aa                	ld	s1,136(sp)
    80005e8c:	690a                	ld	s2,128(sp)
    80005e8e:	610d                	addi	sp,sp,160
    80005e90:	8082                	ret
    end_op();
    80005e92:	ffffe097          	auipc	ra,0xffffe
    80005e96:	7a0080e7          	jalr	1952(ra) # 80004632 <end_op>
    return -1;
    80005e9a:	557d                	li	a0,-1
    80005e9c:	b7ed                	j	80005e86 <sys_chdir+0x7a>
    iunlockput(ip);
    80005e9e:	8526                	mv	a0,s1
    80005ea0:	ffffe097          	auipc	ra,0xffffe
    80005ea4:	f9e080e7          	jalr	-98(ra) # 80003e3e <iunlockput>
    end_op();
    80005ea8:	ffffe097          	auipc	ra,0xffffe
    80005eac:	78a080e7          	jalr	1930(ra) # 80004632 <end_op>
    return -1;
    80005eb0:	557d                	li	a0,-1
    80005eb2:	bfd1                	j	80005e86 <sys_chdir+0x7a>

0000000080005eb4 <sys_exec>:

uint64
sys_exec(void)
{
    80005eb4:	7145                	addi	sp,sp,-464
    80005eb6:	e786                	sd	ra,456(sp)
    80005eb8:	e3a2                	sd	s0,448(sp)
    80005eba:	ff26                	sd	s1,440(sp)
    80005ebc:	fb4a                	sd	s2,432(sp)
    80005ebe:	f74e                	sd	s3,424(sp)
    80005ec0:	f352                	sd	s4,416(sp)
    80005ec2:	ef56                	sd	s5,408(sp)
    80005ec4:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005ec6:	08000613          	li	a2,128
    80005eca:	f4040593          	addi	a1,s0,-192
    80005ece:	4501                	li	a0,0
    80005ed0:	ffffd097          	auipc	ra,0xffffd
    80005ed4:	0fc080e7          	jalr	252(ra) # 80002fcc <argstr>
    return -1;
    80005ed8:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005eda:	0c054a63          	bltz	a0,80005fae <sys_exec+0xfa>
    80005ede:	e3840593          	addi	a1,s0,-456
    80005ee2:	4505                	li	a0,1
    80005ee4:	ffffd097          	auipc	ra,0xffffd
    80005ee8:	0c6080e7          	jalr	198(ra) # 80002faa <argaddr>
    80005eec:	0c054163          	bltz	a0,80005fae <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005ef0:	10000613          	li	a2,256
    80005ef4:	4581                	li	a1,0
    80005ef6:	e4040513          	addi	a0,s0,-448
    80005efa:	ffffb097          	auipc	ra,0xffffb
    80005efe:	dde080e7          	jalr	-546(ra) # 80000cd8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f02:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005f06:	89a6                	mv	s3,s1
    80005f08:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005f0a:	02000a13          	li	s4,32
    80005f0e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f12:	00391793          	slli	a5,s2,0x3
    80005f16:	e3040593          	addi	a1,s0,-464
    80005f1a:	e3843503          	ld	a0,-456(s0)
    80005f1e:	953e                	add	a0,a0,a5
    80005f20:	ffffd097          	auipc	ra,0xffffd
    80005f24:	fce080e7          	jalr	-50(ra) # 80002eee <fetchaddr>
    80005f28:	02054a63          	bltz	a0,80005f5c <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005f2c:	e3043783          	ld	a5,-464(s0)
    80005f30:	c3b9                	beqz	a5,80005f76 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f32:	ffffb097          	auipc	ra,0xffffb
    80005f36:	ba4080e7          	jalr	-1116(ra) # 80000ad6 <kalloc>
    80005f3a:	85aa                	mv	a1,a0
    80005f3c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f40:	cd11                	beqz	a0,80005f5c <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f42:	6605                	lui	a2,0x1
    80005f44:	e3043503          	ld	a0,-464(s0)
    80005f48:	ffffd097          	auipc	ra,0xffffd
    80005f4c:	ff8080e7          	jalr	-8(ra) # 80002f40 <fetchstr>
    80005f50:	00054663          	bltz	a0,80005f5c <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005f54:	0905                	addi	s2,s2,1
    80005f56:	09a1                	addi	s3,s3,8
    80005f58:	fb491be3          	bne	s2,s4,80005f0e <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f5c:	10048913          	addi	s2,s1,256
    80005f60:	6088                	ld	a0,0(s1)
    80005f62:	c529                	beqz	a0,80005fac <sys_exec+0xf8>
    kfree(argv[i]);
    80005f64:	ffffb097          	auipc	ra,0xffffb
    80005f68:	a76080e7          	jalr	-1418(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f6c:	04a1                	addi	s1,s1,8
    80005f6e:	ff2499e3          	bne	s1,s2,80005f60 <sys_exec+0xac>
  return -1;
    80005f72:	597d                	li	s2,-1
    80005f74:	a82d                	j	80005fae <sys_exec+0xfa>
      argv[i] = 0;
    80005f76:	0a8e                	slli	s5,s5,0x3
    80005f78:	fc040793          	addi	a5,s0,-64
    80005f7c:	9abe                	add	s5,s5,a5
    80005f7e:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd2e80>
  int ret = exec(path, argv);
    80005f82:	e4040593          	addi	a1,s0,-448
    80005f86:	f4040513          	addi	a0,s0,-192
    80005f8a:	fffff097          	auipc	ra,0xfffff
    80005f8e:	152080e7          	jalr	338(ra) # 800050dc <exec>
    80005f92:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f94:	10048993          	addi	s3,s1,256
    80005f98:	6088                	ld	a0,0(s1)
    80005f9a:	c911                	beqz	a0,80005fae <sys_exec+0xfa>
    kfree(argv[i]);
    80005f9c:	ffffb097          	auipc	ra,0xffffb
    80005fa0:	a3e080e7          	jalr	-1474(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fa4:	04a1                	addi	s1,s1,8
    80005fa6:	ff3499e3          	bne	s1,s3,80005f98 <sys_exec+0xe4>
    80005faa:	a011                	j	80005fae <sys_exec+0xfa>
  return -1;
    80005fac:	597d                	li	s2,-1
}
    80005fae:	854a                	mv	a0,s2
    80005fb0:	60be                	ld	ra,456(sp)
    80005fb2:	641e                	ld	s0,448(sp)
    80005fb4:	74fa                	ld	s1,440(sp)
    80005fb6:	795a                	ld	s2,432(sp)
    80005fb8:	79ba                	ld	s3,424(sp)
    80005fba:	7a1a                	ld	s4,416(sp)
    80005fbc:	6afa                	ld	s5,408(sp)
    80005fbe:	6179                	addi	sp,sp,464
    80005fc0:	8082                	ret

0000000080005fc2 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005fc2:	7139                	addi	sp,sp,-64
    80005fc4:	fc06                	sd	ra,56(sp)
    80005fc6:	f822                	sd	s0,48(sp)
    80005fc8:	f426                	sd	s1,40(sp)
    80005fca:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005fcc:	ffffc097          	auipc	ra,0xffffc
    80005fd0:	9cc080e7          	jalr	-1588(ra) # 80001998 <myproc>
    80005fd4:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005fd6:	fd840593          	addi	a1,s0,-40
    80005fda:	4501                	li	a0,0
    80005fdc:	ffffd097          	auipc	ra,0xffffd
    80005fe0:	fce080e7          	jalr	-50(ra) # 80002faa <argaddr>
    return -1;
    80005fe4:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005fe6:	0e054063          	bltz	a0,800060c6 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005fea:	fc840593          	addi	a1,s0,-56
    80005fee:	fd040513          	addi	a0,s0,-48
    80005ff2:	fffff097          	auipc	ra,0xfffff
    80005ff6:	dbc080e7          	jalr	-580(ra) # 80004dae <pipealloc>
    return -1;
    80005ffa:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ffc:	0c054563          	bltz	a0,800060c6 <sys_pipe+0x104>
  fd0 = -1;
    80006000:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006004:	fd043503          	ld	a0,-48(s0)
    80006008:	fffff097          	auipc	ra,0xfffff
    8000600c:	50a080e7          	jalr	1290(ra) # 80005512 <fdalloc>
    80006010:	fca42223          	sw	a0,-60(s0)
    80006014:	08054c63          	bltz	a0,800060ac <sys_pipe+0xea>
    80006018:	fc843503          	ld	a0,-56(s0)
    8000601c:	fffff097          	auipc	ra,0xfffff
    80006020:	4f6080e7          	jalr	1270(ra) # 80005512 <fdalloc>
    80006024:	fca42023          	sw	a0,-64(s0)
    80006028:	06054863          	bltz	a0,80006098 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000602c:	4691                	li	a3,4
    8000602e:	fc440613          	addi	a2,s0,-60
    80006032:	fd843583          	ld	a1,-40(s0)
    80006036:	68a8                	ld	a0,80(s1)
    80006038:	ffffb097          	auipc	ra,0xffffb
    8000603c:	620080e7          	jalr	1568(ra) # 80001658 <copyout>
    80006040:	02054063          	bltz	a0,80006060 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006044:	4691                	li	a3,4
    80006046:	fc040613          	addi	a2,s0,-64
    8000604a:	fd843583          	ld	a1,-40(s0)
    8000604e:	0591                	addi	a1,a1,4
    80006050:	68a8                	ld	a0,80(s1)
    80006052:	ffffb097          	auipc	ra,0xffffb
    80006056:	606080e7          	jalr	1542(ra) # 80001658 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000605a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000605c:	06055563          	bgez	a0,800060c6 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006060:	fc442783          	lw	a5,-60(s0)
    80006064:	07e9                	addi	a5,a5,26
    80006066:	078e                	slli	a5,a5,0x3
    80006068:	97a6                	add	a5,a5,s1
    8000606a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000606e:	fc042503          	lw	a0,-64(s0)
    80006072:	0569                	addi	a0,a0,26
    80006074:	050e                	slli	a0,a0,0x3
    80006076:	9526                	add	a0,a0,s1
    80006078:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    8000607c:	fd043503          	ld	a0,-48(s0)
    80006080:	fffff097          	auipc	ra,0xfffff
    80006084:	9fe080e7          	jalr	-1538(ra) # 80004a7e <fileclose>
    fileclose(wf);
    80006088:	fc843503          	ld	a0,-56(s0)
    8000608c:	fffff097          	auipc	ra,0xfffff
    80006090:	9f2080e7          	jalr	-1550(ra) # 80004a7e <fileclose>
    return -1;
    80006094:	57fd                	li	a5,-1
    80006096:	a805                	j	800060c6 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006098:	fc442783          	lw	a5,-60(s0)
    8000609c:	0007c863          	bltz	a5,800060ac <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    800060a0:	01a78513          	addi	a0,a5,26
    800060a4:	050e                	slli	a0,a0,0x3
    800060a6:	9526                	add	a0,a0,s1
    800060a8:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    800060ac:	fd043503          	ld	a0,-48(s0)
    800060b0:	fffff097          	auipc	ra,0xfffff
    800060b4:	9ce080e7          	jalr	-1586(ra) # 80004a7e <fileclose>
    fileclose(wf);
    800060b8:	fc843503          	ld	a0,-56(s0)
    800060bc:	fffff097          	auipc	ra,0xfffff
    800060c0:	9c2080e7          	jalr	-1598(ra) # 80004a7e <fileclose>
    return -1;
    800060c4:	57fd                	li	a5,-1
}
    800060c6:	853e                	mv	a0,a5
    800060c8:	70e2                	ld	ra,56(sp)
    800060ca:	7442                	ld	s0,48(sp)
    800060cc:	74a2                	ld	s1,40(sp)
    800060ce:	6121                	addi	sp,sp,64
    800060d0:	8082                	ret
	...

00000000800060e0 <kernelvec>:
    800060e0:	7111                	addi	sp,sp,-256
    800060e2:	e006                	sd	ra,0(sp)
    800060e4:	e40a                	sd	sp,8(sp)
    800060e6:	e80e                	sd	gp,16(sp)
    800060e8:	ec12                	sd	tp,24(sp)
    800060ea:	f016                	sd	t0,32(sp)
    800060ec:	f41a                	sd	t1,40(sp)
    800060ee:	f81e                	sd	t2,48(sp)
    800060f0:	fc22                	sd	s0,56(sp)
    800060f2:	e0a6                	sd	s1,64(sp)
    800060f4:	e4aa                	sd	a0,72(sp)
    800060f6:	e8ae                	sd	a1,80(sp)
    800060f8:	ecb2                	sd	a2,88(sp)
    800060fa:	f0b6                	sd	a3,96(sp)
    800060fc:	f4ba                	sd	a4,104(sp)
    800060fe:	f8be                	sd	a5,112(sp)
    80006100:	fcc2                	sd	a6,120(sp)
    80006102:	e146                	sd	a7,128(sp)
    80006104:	e54a                	sd	s2,136(sp)
    80006106:	e94e                	sd	s3,144(sp)
    80006108:	ed52                	sd	s4,152(sp)
    8000610a:	f156                	sd	s5,160(sp)
    8000610c:	f55a                	sd	s6,168(sp)
    8000610e:	f95e                	sd	s7,176(sp)
    80006110:	fd62                	sd	s8,184(sp)
    80006112:	e1e6                	sd	s9,192(sp)
    80006114:	e5ea                	sd	s10,200(sp)
    80006116:	e9ee                	sd	s11,208(sp)
    80006118:	edf2                	sd	t3,216(sp)
    8000611a:	f1f6                	sd	t4,224(sp)
    8000611c:	f5fa                	sd	t5,232(sp)
    8000611e:	f9fe                	sd	t6,240(sp)
    80006120:	c9bfc0ef          	jal	ra,80002dba <kerneltrap>
    80006124:	6082                	ld	ra,0(sp)
    80006126:	6122                	ld	sp,8(sp)
    80006128:	61c2                	ld	gp,16(sp)
    8000612a:	7282                	ld	t0,32(sp)
    8000612c:	7322                	ld	t1,40(sp)
    8000612e:	73c2                	ld	t2,48(sp)
    80006130:	7462                	ld	s0,56(sp)
    80006132:	6486                	ld	s1,64(sp)
    80006134:	6526                	ld	a0,72(sp)
    80006136:	65c6                	ld	a1,80(sp)
    80006138:	6666                	ld	a2,88(sp)
    8000613a:	7686                	ld	a3,96(sp)
    8000613c:	7726                	ld	a4,104(sp)
    8000613e:	77c6                	ld	a5,112(sp)
    80006140:	7866                	ld	a6,120(sp)
    80006142:	688a                	ld	a7,128(sp)
    80006144:	692a                	ld	s2,136(sp)
    80006146:	69ca                	ld	s3,144(sp)
    80006148:	6a6a                	ld	s4,152(sp)
    8000614a:	7a8a                	ld	s5,160(sp)
    8000614c:	7b2a                	ld	s6,168(sp)
    8000614e:	7bca                	ld	s7,176(sp)
    80006150:	7c6a                	ld	s8,184(sp)
    80006152:	6c8e                	ld	s9,192(sp)
    80006154:	6d2e                	ld	s10,200(sp)
    80006156:	6dce                	ld	s11,208(sp)
    80006158:	6e6e                	ld	t3,216(sp)
    8000615a:	7e8e                	ld	t4,224(sp)
    8000615c:	7f2e                	ld	t5,232(sp)
    8000615e:	7fce                	ld	t6,240(sp)
    80006160:	6111                	addi	sp,sp,256
    80006162:	10200073          	sret
    80006166:	00000013          	nop
    8000616a:	00000013          	nop
    8000616e:	0001                	nop

0000000080006170 <timervec>:
    80006170:	34051573          	csrrw	a0,mscratch,a0
    80006174:	e10c                	sd	a1,0(a0)
    80006176:	e510                	sd	a2,8(a0)
    80006178:	e914                	sd	a3,16(a0)
    8000617a:	6d0c                	ld	a1,24(a0)
    8000617c:	7110                	ld	a2,32(a0)
    8000617e:	6194                	ld	a3,0(a1)
    80006180:	96b2                	add	a3,a3,a2
    80006182:	e194                	sd	a3,0(a1)
    80006184:	4589                	li	a1,2
    80006186:	14459073          	csrw	sip,a1
    8000618a:	6914                	ld	a3,16(a0)
    8000618c:	6510                	ld	a2,8(a0)
    8000618e:	610c                	ld	a1,0(a0)
    80006190:	34051573          	csrrw	a0,mscratch,a0
    80006194:	30200073          	mret
	...

000000008000619a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000619a:	1141                	addi	sp,sp,-16
    8000619c:	e422                	sd	s0,8(sp)
    8000619e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800061a0:	0c0007b7          	lui	a5,0xc000
    800061a4:	4705                	li	a4,1
    800061a6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800061a8:	c3d8                	sw	a4,4(a5)
}
    800061aa:	6422                	ld	s0,8(sp)
    800061ac:	0141                	addi	sp,sp,16
    800061ae:	8082                	ret

00000000800061b0 <plicinithart>:

void
plicinithart(void)
{
    800061b0:	1141                	addi	sp,sp,-16
    800061b2:	e406                	sd	ra,8(sp)
    800061b4:	e022                	sd	s0,0(sp)
    800061b6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061b8:	ffffb097          	auipc	ra,0xffffb
    800061bc:	7b4080e7          	jalr	1972(ra) # 8000196c <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800061c0:	0085171b          	slliw	a4,a0,0x8
    800061c4:	0c0027b7          	lui	a5,0xc002
    800061c8:	97ba                	add	a5,a5,a4
    800061ca:	40200713          	li	a4,1026
    800061ce:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800061d2:	00d5151b          	slliw	a0,a0,0xd
    800061d6:	0c2017b7          	lui	a5,0xc201
    800061da:	953e                	add	a0,a0,a5
    800061dc:	00052023          	sw	zero,0(a0)
}
    800061e0:	60a2                	ld	ra,8(sp)
    800061e2:	6402                	ld	s0,0(sp)
    800061e4:	0141                	addi	sp,sp,16
    800061e6:	8082                	ret

00000000800061e8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800061e8:	1141                	addi	sp,sp,-16
    800061ea:	e406                	sd	ra,8(sp)
    800061ec:	e022                	sd	s0,0(sp)
    800061ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061f0:	ffffb097          	auipc	ra,0xffffb
    800061f4:	77c080e7          	jalr	1916(ra) # 8000196c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800061f8:	00d5179b          	slliw	a5,a0,0xd
    800061fc:	0c201537          	lui	a0,0xc201
    80006200:	953e                	add	a0,a0,a5
  return irq;
}
    80006202:	4148                	lw	a0,4(a0)
    80006204:	60a2                	ld	ra,8(sp)
    80006206:	6402                	ld	s0,0(sp)
    80006208:	0141                	addi	sp,sp,16
    8000620a:	8082                	ret

000000008000620c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000620c:	1101                	addi	sp,sp,-32
    8000620e:	ec06                	sd	ra,24(sp)
    80006210:	e822                	sd	s0,16(sp)
    80006212:	e426                	sd	s1,8(sp)
    80006214:	1000                	addi	s0,sp,32
    80006216:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006218:	ffffb097          	auipc	ra,0xffffb
    8000621c:	754080e7          	jalr	1876(ra) # 8000196c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006220:	00d5151b          	slliw	a0,a0,0xd
    80006224:	0c2017b7          	lui	a5,0xc201
    80006228:	97aa                	add	a5,a5,a0
    8000622a:	c3c4                	sw	s1,4(a5)
}
    8000622c:	60e2                	ld	ra,24(sp)
    8000622e:	6442                	ld	s0,16(sp)
    80006230:	64a2                	ld	s1,8(sp)
    80006232:	6105                	addi	sp,sp,32
    80006234:	8082                	ret

0000000080006236 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006236:	1141                	addi	sp,sp,-16
    80006238:	e406                	sd	ra,8(sp)
    8000623a:	e022                	sd	s0,0(sp)
    8000623c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000623e:	479d                	li	a5,7
    80006240:	06a7c963          	blt	a5,a0,800062b2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006244:	00023797          	auipc	a5,0x23
    80006248:	dbc78793          	addi	a5,a5,-580 # 80029000 <disk>
    8000624c:	00a78733          	add	a4,a5,a0
    80006250:	6789                	lui	a5,0x2
    80006252:	97ba                	add	a5,a5,a4
    80006254:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006258:	e7ad                	bnez	a5,800062c2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000625a:	00451793          	slli	a5,a0,0x4
    8000625e:	00025717          	auipc	a4,0x25
    80006262:	da270713          	addi	a4,a4,-606 # 8002b000 <disk+0x2000>
    80006266:	6314                	ld	a3,0(a4)
    80006268:	96be                	add	a3,a3,a5
    8000626a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000626e:	6314                	ld	a3,0(a4)
    80006270:	96be                	add	a3,a3,a5
    80006272:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006276:	6314                	ld	a3,0(a4)
    80006278:	96be                	add	a3,a3,a5
    8000627a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000627e:	6318                	ld	a4,0(a4)
    80006280:	97ba                	add	a5,a5,a4
    80006282:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006286:	00023797          	auipc	a5,0x23
    8000628a:	d7a78793          	addi	a5,a5,-646 # 80029000 <disk>
    8000628e:	97aa                	add	a5,a5,a0
    80006290:	6509                	lui	a0,0x2
    80006292:	953e                	add	a0,a0,a5
    80006294:	4785                	li	a5,1
    80006296:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000629a:	00025517          	auipc	a0,0x25
    8000629e:	d7e50513          	addi	a0,a0,-642 # 8002b018 <disk+0x2018>
    800062a2:	ffffc097          	auipc	ra,0xffffc
    800062a6:	fb6080e7          	jalr	-74(ra) # 80002258 <wakeup>
}
    800062aa:	60a2                	ld	ra,8(sp)
    800062ac:	6402                	ld	s0,0(sp)
    800062ae:	0141                	addi	sp,sp,16
    800062b0:	8082                	ret
    panic("free_desc 1");
    800062b2:	00002517          	auipc	a0,0x2
    800062b6:	56e50513          	addi	a0,a0,1390 # 80008820 <syscalls+0x338>
    800062ba:	ffffa097          	auipc	ra,0xffffa
    800062be:	274080e7          	jalr	628(ra) # 8000052e <panic>
    panic("free_desc 2");
    800062c2:	00002517          	auipc	a0,0x2
    800062c6:	56e50513          	addi	a0,a0,1390 # 80008830 <syscalls+0x348>
    800062ca:	ffffa097          	auipc	ra,0xffffa
    800062ce:	264080e7          	jalr	612(ra) # 8000052e <panic>

00000000800062d2 <virtio_disk_init>:
{
    800062d2:	1101                	addi	sp,sp,-32
    800062d4:	ec06                	sd	ra,24(sp)
    800062d6:	e822                	sd	s0,16(sp)
    800062d8:	e426                	sd	s1,8(sp)
    800062da:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800062dc:	00002597          	auipc	a1,0x2
    800062e0:	56458593          	addi	a1,a1,1380 # 80008840 <syscalls+0x358>
    800062e4:	00025517          	auipc	a0,0x25
    800062e8:	e4450513          	addi	a0,a0,-444 # 8002b128 <disk+0x2128>
    800062ec:	ffffb097          	auipc	ra,0xffffb
    800062f0:	84a080e7          	jalr	-1974(ra) # 80000b36 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062f4:	100017b7          	lui	a5,0x10001
    800062f8:	4398                	lw	a4,0(a5)
    800062fa:	2701                	sext.w	a4,a4
    800062fc:	747277b7          	lui	a5,0x74727
    80006300:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006304:	0ef71163          	bne	a4,a5,800063e6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006308:	100017b7          	lui	a5,0x10001
    8000630c:	43dc                	lw	a5,4(a5)
    8000630e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006310:	4705                	li	a4,1
    80006312:	0ce79a63          	bne	a5,a4,800063e6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006316:	100017b7          	lui	a5,0x10001
    8000631a:	479c                	lw	a5,8(a5)
    8000631c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000631e:	4709                	li	a4,2
    80006320:	0ce79363          	bne	a5,a4,800063e6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006324:	100017b7          	lui	a5,0x10001
    80006328:	47d8                	lw	a4,12(a5)
    8000632a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000632c:	554d47b7          	lui	a5,0x554d4
    80006330:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006334:	0af71963          	bne	a4,a5,800063e6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006338:	100017b7          	lui	a5,0x10001
    8000633c:	4705                	li	a4,1
    8000633e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006340:	470d                	li	a4,3
    80006342:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006344:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006346:	c7ffe737          	lui	a4,0xc7ffe
    8000634a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd275f>
    8000634e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006350:	2701                	sext.w	a4,a4
    80006352:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006354:	472d                	li	a4,11
    80006356:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006358:	473d                	li	a4,15
    8000635a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000635c:	6705                	lui	a4,0x1
    8000635e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006360:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006364:	5bdc                	lw	a5,52(a5)
    80006366:	2781                	sext.w	a5,a5
  if(max == 0)
    80006368:	c7d9                	beqz	a5,800063f6 <virtio_disk_init+0x124>
  if(max < NUM)
    8000636a:	471d                	li	a4,7
    8000636c:	08f77d63          	bgeu	a4,a5,80006406 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006370:	100014b7          	lui	s1,0x10001
    80006374:	47a1                	li	a5,8
    80006376:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006378:	6609                	lui	a2,0x2
    8000637a:	4581                	li	a1,0
    8000637c:	00023517          	auipc	a0,0x23
    80006380:	c8450513          	addi	a0,a0,-892 # 80029000 <disk>
    80006384:	ffffb097          	auipc	ra,0xffffb
    80006388:	954080e7          	jalr	-1708(ra) # 80000cd8 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000638c:	00023717          	auipc	a4,0x23
    80006390:	c7470713          	addi	a4,a4,-908 # 80029000 <disk>
    80006394:	00c75793          	srli	a5,a4,0xc
    80006398:	2781                	sext.w	a5,a5
    8000639a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000639c:	00025797          	auipc	a5,0x25
    800063a0:	c6478793          	addi	a5,a5,-924 # 8002b000 <disk+0x2000>
    800063a4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800063a6:	00023717          	auipc	a4,0x23
    800063aa:	cda70713          	addi	a4,a4,-806 # 80029080 <disk+0x80>
    800063ae:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    800063b0:	00024717          	auipc	a4,0x24
    800063b4:	c5070713          	addi	a4,a4,-944 # 8002a000 <disk+0x1000>
    800063b8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800063ba:	4705                	li	a4,1
    800063bc:	00e78c23          	sb	a4,24(a5)
    800063c0:	00e78ca3          	sb	a4,25(a5)
    800063c4:	00e78d23          	sb	a4,26(a5)
    800063c8:	00e78da3          	sb	a4,27(a5)
    800063cc:	00e78e23          	sb	a4,28(a5)
    800063d0:	00e78ea3          	sb	a4,29(a5)
    800063d4:	00e78f23          	sb	a4,30(a5)
    800063d8:	00e78fa3          	sb	a4,31(a5)
}
    800063dc:	60e2                	ld	ra,24(sp)
    800063de:	6442                	ld	s0,16(sp)
    800063e0:	64a2                	ld	s1,8(sp)
    800063e2:	6105                	addi	sp,sp,32
    800063e4:	8082                	ret
    panic("could not find virtio disk");
    800063e6:	00002517          	auipc	a0,0x2
    800063ea:	46a50513          	addi	a0,a0,1130 # 80008850 <syscalls+0x368>
    800063ee:	ffffa097          	auipc	ra,0xffffa
    800063f2:	140080e7          	jalr	320(ra) # 8000052e <panic>
    panic("virtio disk has no queue 0");
    800063f6:	00002517          	auipc	a0,0x2
    800063fa:	47a50513          	addi	a0,a0,1146 # 80008870 <syscalls+0x388>
    800063fe:	ffffa097          	auipc	ra,0xffffa
    80006402:	130080e7          	jalr	304(ra) # 8000052e <panic>
    panic("virtio disk max queue too short");
    80006406:	00002517          	auipc	a0,0x2
    8000640a:	48a50513          	addi	a0,a0,1162 # 80008890 <syscalls+0x3a8>
    8000640e:	ffffa097          	auipc	ra,0xffffa
    80006412:	120080e7          	jalr	288(ra) # 8000052e <panic>

0000000080006416 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006416:	7119                	addi	sp,sp,-128
    80006418:	fc86                	sd	ra,120(sp)
    8000641a:	f8a2                	sd	s0,112(sp)
    8000641c:	f4a6                	sd	s1,104(sp)
    8000641e:	f0ca                	sd	s2,96(sp)
    80006420:	ecce                	sd	s3,88(sp)
    80006422:	e8d2                	sd	s4,80(sp)
    80006424:	e4d6                	sd	s5,72(sp)
    80006426:	e0da                	sd	s6,64(sp)
    80006428:	fc5e                	sd	s7,56(sp)
    8000642a:	f862                	sd	s8,48(sp)
    8000642c:	f466                	sd	s9,40(sp)
    8000642e:	f06a                	sd	s10,32(sp)
    80006430:	ec6e                	sd	s11,24(sp)
    80006432:	0100                	addi	s0,sp,128
    80006434:	8aaa                	mv	s5,a0
    80006436:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006438:	00c52c83          	lw	s9,12(a0)
    8000643c:	001c9c9b          	slliw	s9,s9,0x1
    80006440:	1c82                	slli	s9,s9,0x20
    80006442:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006446:	00025517          	auipc	a0,0x25
    8000644a:	ce250513          	addi	a0,a0,-798 # 8002b128 <disk+0x2128>
    8000644e:	ffffa097          	auipc	ra,0xffffa
    80006452:	778080e7          	jalr	1912(ra) # 80000bc6 <acquire>
  for(int i = 0; i < 3; i++){
    80006456:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006458:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000645a:	00023c17          	auipc	s8,0x23
    8000645e:	ba6c0c13          	addi	s8,s8,-1114 # 80029000 <disk>
    80006462:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006464:	4b0d                	li	s6,3
    80006466:	a0ad                	j	800064d0 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006468:	00fc0733          	add	a4,s8,a5
    8000646c:	975e                	add	a4,a4,s7
    8000646e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006472:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006474:	0207c563          	bltz	a5,8000649e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006478:	2905                	addiw	s2,s2,1
    8000647a:	0611                	addi	a2,a2,4
    8000647c:	19690d63          	beq	s2,s6,80006616 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006480:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006482:	00025717          	auipc	a4,0x25
    80006486:	b9670713          	addi	a4,a4,-1130 # 8002b018 <disk+0x2018>
    8000648a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000648c:	00074683          	lbu	a3,0(a4)
    80006490:	fee1                	bnez	a3,80006468 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006492:	2785                	addiw	a5,a5,1
    80006494:	0705                	addi	a4,a4,1
    80006496:	fe979be3          	bne	a5,s1,8000648c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000649a:	57fd                	li	a5,-1
    8000649c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000649e:	01205d63          	blez	s2,800064b8 <virtio_disk_rw+0xa2>
    800064a2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800064a4:	000a2503          	lw	a0,0(s4)
    800064a8:	00000097          	auipc	ra,0x0
    800064ac:	d8e080e7          	jalr	-626(ra) # 80006236 <free_desc>
      for(int j = 0; j < i; j++)
    800064b0:	2d85                	addiw	s11,s11,1
    800064b2:	0a11                	addi	s4,s4,4
    800064b4:	ffb918e3          	bne	s2,s11,800064a4 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064b8:	00025597          	auipc	a1,0x25
    800064bc:	c7058593          	addi	a1,a1,-912 # 8002b128 <disk+0x2128>
    800064c0:	00025517          	auipc	a0,0x25
    800064c4:	b5850513          	addi	a0,a0,-1192 # 8002b018 <disk+0x2018>
    800064c8:	ffffc097          	auipc	ra,0xffffc
    800064cc:	c02080e7          	jalr	-1022(ra) # 800020ca <sleep>
  for(int i = 0; i < 3; i++){
    800064d0:	f8040a13          	addi	s4,s0,-128
{
    800064d4:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800064d6:	894e                	mv	s2,s3
    800064d8:	b765                	j	80006480 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800064da:	00025697          	auipc	a3,0x25
    800064de:	b266b683          	ld	a3,-1242(a3) # 8002b000 <disk+0x2000>
    800064e2:	96ba                	add	a3,a3,a4
    800064e4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800064e8:	00023817          	auipc	a6,0x23
    800064ec:	b1880813          	addi	a6,a6,-1256 # 80029000 <disk>
    800064f0:	00025697          	auipc	a3,0x25
    800064f4:	b1068693          	addi	a3,a3,-1264 # 8002b000 <disk+0x2000>
    800064f8:	6290                	ld	a2,0(a3)
    800064fa:	963a                	add	a2,a2,a4
    800064fc:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006500:	0015e593          	ori	a1,a1,1
    80006504:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006508:	f8842603          	lw	a2,-120(s0)
    8000650c:	628c                	ld	a1,0(a3)
    8000650e:	972e                	add	a4,a4,a1
    80006510:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006514:	20050593          	addi	a1,a0,512
    80006518:	0592                	slli	a1,a1,0x4
    8000651a:	95c2                	add	a1,a1,a6
    8000651c:	577d                	li	a4,-1
    8000651e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006522:	00461713          	slli	a4,a2,0x4
    80006526:	6290                	ld	a2,0(a3)
    80006528:	963a                	add	a2,a2,a4
    8000652a:	03078793          	addi	a5,a5,48
    8000652e:	97c2                	add	a5,a5,a6
    80006530:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006532:	629c                	ld	a5,0(a3)
    80006534:	97ba                	add	a5,a5,a4
    80006536:	4605                	li	a2,1
    80006538:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000653a:	629c                	ld	a5,0(a3)
    8000653c:	97ba                	add	a5,a5,a4
    8000653e:	4809                	li	a6,2
    80006540:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006544:	629c                	ld	a5,0(a3)
    80006546:	973e                	add	a4,a4,a5
    80006548:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000654c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006550:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006554:	6698                	ld	a4,8(a3)
    80006556:	00275783          	lhu	a5,2(a4)
    8000655a:	8b9d                	andi	a5,a5,7
    8000655c:	0786                	slli	a5,a5,0x1
    8000655e:	97ba                	add	a5,a5,a4
    80006560:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006564:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006568:	6698                	ld	a4,8(a3)
    8000656a:	00275783          	lhu	a5,2(a4)
    8000656e:	2785                	addiw	a5,a5,1
    80006570:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006574:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006578:	100017b7          	lui	a5,0x10001
    8000657c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006580:	004aa783          	lw	a5,4(s5)
    80006584:	02c79163          	bne	a5,a2,800065a6 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006588:	00025917          	auipc	s2,0x25
    8000658c:	ba090913          	addi	s2,s2,-1120 # 8002b128 <disk+0x2128>
  while(b->disk == 1) {
    80006590:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006592:	85ca                	mv	a1,s2
    80006594:	8556                	mv	a0,s5
    80006596:	ffffc097          	auipc	ra,0xffffc
    8000659a:	b34080e7          	jalr	-1228(ra) # 800020ca <sleep>
  while(b->disk == 1) {
    8000659e:	004aa783          	lw	a5,4(s5)
    800065a2:	fe9788e3          	beq	a5,s1,80006592 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800065a6:	f8042903          	lw	s2,-128(s0)
    800065aa:	20090793          	addi	a5,s2,512
    800065ae:	00479713          	slli	a4,a5,0x4
    800065b2:	00023797          	auipc	a5,0x23
    800065b6:	a4e78793          	addi	a5,a5,-1458 # 80029000 <disk>
    800065ba:	97ba                	add	a5,a5,a4
    800065bc:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800065c0:	00025997          	auipc	s3,0x25
    800065c4:	a4098993          	addi	s3,s3,-1472 # 8002b000 <disk+0x2000>
    800065c8:	00491713          	slli	a4,s2,0x4
    800065cc:	0009b783          	ld	a5,0(s3)
    800065d0:	97ba                	add	a5,a5,a4
    800065d2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800065d6:	854a                	mv	a0,s2
    800065d8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800065dc:	00000097          	auipc	ra,0x0
    800065e0:	c5a080e7          	jalr	-934(ra) # 80006236 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800065e4:	8885                	andi	s1,s1,1
    800065e6:	f0ed                	bnez	s1,800065c8 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800065e8:	00025517          	auipc	a0,0x25
    800065ec:	b4050513          	addi	a0,a0,-1216 # 8002b128 <disk+0x2128>
    800065f0:	ffffa097          	auipc	ra,0xffffa
    800065f4:	6a0080e7          	jalr	1696(ra) # 80000c90 <release>
}
    800065f8:	70e6                	ld	ra,120(sp)
    800065fa:	7446                	ld	s0,112(sp)
    800065fc:	74a6                	ld	s1,104(sp)
    800065fe:	7906                	ld	s2,96(sp)
    80006600:	69e6                	ld	s3,88(sp)
    80006602:	6a46                	ld	s4,80(sp)
    80006604:	6aa6                	ld	s5,72(sp)
    80006606:	6b06                	ld	s6,64(sp)
    80006608:	7be2                	ld	s7,56(sp)
    8000660a:	7c42                	ld	s8,48(sp)
    8000660c:	7ca2                	ld	s9,40(sp)
    8000660e:	7d02                	ld	s10,32(sp)
    80006610:	6de2                	ld	s11,24(sp)
    80006612:	6109                	addi	sp,sp,128
    80006614:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006616:	f8042503          	lw	a0,-128(s0)
    8000661a:	20050793          	addi	a5,a0,512
    8000661e:	0792                	slli	a5,a5,0x4
  if(write)
    80006620:	00023817          	auipc	a6,0x23
    80006624:	9e080813          	addi	a6,a6,-1568 # 80029000 <disk>
    80006628:	00f80733          	add	a4,a6,a5
    8000662c:	01a036b3          	snez	a3,s10
    80006630:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006634:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006638:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000663c:	7679                	lui	a2,0xffffe
    8000663e:	963e                	add	a2,a2,a5
    80006640:	00025697          	auipc	a3,0x25
    80006644:	9c068693          	addi	a3,a3,-1600 # 8002b000 <disk+0x2000>
    80006648:	6298                	ld	a4,0(a3)
    8000664a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000664c:	0a878593          	addi	a1,a5,168
    80006650:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006652:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006654:	6298                	ld	a4,0(a3)
    80006656:	9732                	add	a4,a4,a2
    80006658:	45c1                	li	a1,16
    8000665a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000665c:	6298                	ld	a4,0(a3)
    8000665e:	9732                	add	a4,a4,a2
    80006660:	4585                	li	a1,1
    80006662:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006666:	f8442703          	lw	a4,-124(s0)
    8000666a:	628c                	ld	a1,0(a3)
    8000666c:	962e                	add	a2,a2,a1
    8000666e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd200e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006672:	0712                	slli	a4,a4,0x4
    80006674:	6290                	ld	a2,0(a3)
    80006676:	963a                	add	a2,a2,a4
    80006678:	058a8593          	addi	a1,s5,88
    8000667c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000667e:	6294                	ld	a3,0(a3)
    80006680:	96ba                	add	a3,a3,a4
    80006682:	40000613          	li	a2,1024
    80006686:	c690                	sw	a2,8(a3)
  if(write)
    80006688:	e40d19e3          	bnez	s10,800064da <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000668c:	00025697          	auipc	a3,0x25
    80006690:	9746b683          	ld	a3,-1676(a3) # 8002b000 <disk+0x2000>
    80006694:	96ba                	add	a3,a3,a4
    80006696:	4609                	li	a2,2
    80006698:	00c69623          	sh	a2,12(a3)
    8000669c:	b5b1                	j	800064e8 <virtio_disk_rw+0xd2>

000000008000669e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000669e:	1101                	addi	sp,sp,-32
    800066a0:	ec06                	sd	ra,24(sp)
    800066a2:	e822                	sd	s0,16(sp)
    800066a4:	e426                	sd	s1,8(sp)
    800066a6:	e04a                	sd	s2,0(sp)
    800066a8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800066aa:	00025517          	auipc	a0,0x25
    800066ae:	a7e50513          	addi	a0,a0,-1410 # 8002b128 <disk+0x2128>
    800066b2:	ffffa097          	auipc	ra,0xffffa
    800066b6:	514080e7          	jalr	1300(ra) # 80000bc6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800066ba:	10001737          	lui	a4,0x10001
    800066be:	533c                	lw	a5,96(a4)
    800066c0:	8b8d                	andi	a5,a5,3
    800066c2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800066c4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800066c8:	00025797          	auipc	a5,0x25
    800066cc:	93878793          	addi	a5,a5,-1736 # 8002b000 <disk+0x2000>
    800066d0:	6b94                	ld	a3,16(a5)
    800066d2:	0207d703          	lhu	a4,32(a5)
    800066d6:	0026d783          	lhu	a5,2(a3)
    800066da:	06f70163          	beq	a4,a5,8000673c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800066de:	00023917          	auipc	s2,0x23
    800066e2:	92290913          	addi	s2,s2,-1758 # 80029000 <disk>
    800066e6:	00025497          	auipc	s1,0x25
    800066ea:	91a48493          	addi	s1,s1,-1766 # 8002b000 <disk+0x2000>
    __sync_synchronize();
    800066ee:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800066f2:	6898                	ld	a4,16(s1)
    800066f4:	0204d783          	lhu	a5,32(s1)
    800066f8:	8b9d                	andi	a5,a5,7
    800066fa:	078e                	slli	a5,a5,0x3
    800066fc:	97ba                	add	a5,a5,a4
    800066fe:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006700:	20078713          	addi	a4,a5,512
    80006704:	0712                	slli	a4,a4,0x4
    80006706:	974a                	add	a4,a4,s2
    80006708:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000670c:	e731                	bnez	a4,80006758 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000670e:	20078793          	addi	a5,a5,512
    80006712:	0792                	slli	a5,a5,0x4
    80006714:	97ca                	add	a5,a5,s2
    80006716:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006718:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000671c:	ffffc097          	auipc	ra,0xffffc
    80006720:	b3c080e7          	jalr	-1220(ra) # 80002258 <wakeup>

    disk.used_idx += 1;
    80006724:	0204d783          	lhu	a5,32(s1)
    80006728:	2785                	addiw	a5,a5,1
    8000672a:	17c2                	slli	a5,a5,0x30
    8000672c:	93c1                	srli	a5,a5,0x30
    8000672e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006732:	6898                	ld	a4,16(s1)
    80006734:	00275703          	lhu	a4,2(a4)
    80006738:	faf71be3          	bne	a4,a5,800066ee <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000673c:	00025517          	auipc	a0,0x25
    80006740:	9ec50513          	addi	a0,a0,-1556 # 8002b128 <disk+0x2128>
    80006744:	ffffa097          	auipc	ra,0xffffa
    80006748:	54c080e7          	jalr	1356(ra) # 80000c90 <release>
}
    8000674c:	60e2                	ld	ra,24(sp)
    8000674e:	6442                	ld	s0,16(sp)
    80006750:	64a2                	ld	s1,8(sp)
    80006752:	6902                	ld	s2,0(sp)
    80006754:	6105                	addi	sp,sp,32
    80006756:	8082                	ret
      panic("virtio_disk_intr status");
    80006758:	00002517          	auipc	a0,0x2
    8000675c:	15850513          	addi	a0,a0,344 # 800088b0 <syscalls+0x3c8>
    80006760:	ffffa097          	auipc	ra,0xffffa
    80006764:	dce080e7          	jalr	-562(ra) # 8000052e <panic>

0000000080006768 <call_sigret>:
    80006768:	48e1                	li	a7,24
    8000676a:	00000073          	ecall
    8000676e:	8082                	ret

0000000080006770 <end_sigret>:
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
