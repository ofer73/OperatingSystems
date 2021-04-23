
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
    80000068:	fdc78793          	addi	a5,a5,-36 # 80006040 <timervec>
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
    80000122:	484080e7          	jalr	1156(ra) # 800025a2 <either_copyin>
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
    800001c8:	f4e080e7          	jalr	-178(ra) # 80002112 <sleep>
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
    80000204:	34c080e7          	jalr	844(ra) # 8000254c <either_copyout>
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
    800002e6:	316080e7          	jalr	790(ra) # 800025f8 <procdump>
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
    8000043a:	e6a080e7          	jalr	-406(ra) # 800022a0 <wakeup>
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
    80000560:	e1450513          	addi	a0,a0,-492 # 80008370 <states.0+0x80>
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
    80000886:	a1e080e7          	jalr	-1506(ra) # 800022a0 <wakeup>
    
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
    80000912:	804080e7          	jalr	-2044(ra) # 80002112 <sleep>
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
{
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
    printf("pid=%d tried to lock when already holding\n",lk->cpu->proc->pid);
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
    80000ed0:	9c0080e7          	jalr	-1600(ra) # 8000288c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ed4:	00005097          	auipc	ra,0x5
    80000ed8:	1ac080e7          	jalr	428(ra) # 80006080 <plicinithart>
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
    80000ef8:	47c50513          	addi	a0,a0,1148 # 80008370 <states.0+0x80>
    80000efc:	fffff097          	auipc	ra,0xfffff
    80000f00:	67c080e7          	jalr	1660(ra) # 80000578 <printf>
    printf("xv6 kernel is booting\n");
    80000f04:	00007517          	auipc	a0,0x7
    80000f08:	1cc50513          	addi	a0,a0,460 # 800080d0 <digits+0x90>
    80000f0c:	fffff097          	auipc	ra,0xfffff
    80000f10:	66c080e7          	jalr	1644(ra) # 80000578 <printf>
    printf("\n");
    80000f14:	00007517          	auipc	a0,0x7
    80000f18:	45c50513          	addi	a0,a0,1116 # 80008370 <states.0+0x80>
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
    80000f48:	920080e7          	jalr	-1760(ra) # 80002864 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f4c:	00002097          	auipc	ra,0x2
    80000f50:	940080e7          	jalr	-1728(ra) # 8000288c <trapinithart>
    plicinit();      // set up interrupt controller
    80000f54:	00005097          	auipc	ra,0x5
    80000f58:	116080e7          	jalr	278(ra) # 8000606a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f5c:	00005097          	auipc	ra,0x5
    80000f60:	124080e7          	jalr	292(ra) # 80006080 <plicinithart>
    binit();         // buffer cache
    80000f64:	00002097          	auipc	ra,0x2
    80000f68:	2da080e7          	jalr	730(ra) # 8000323e <binit>
    iinit();         // inode cache
    80000f6c:	00003097          	auipc	ra,0x3
    80000f70:	96c080e7          	jalr	-1684(ra) # 800038d8 <iinit>
    fileinit();      // file table
    80000f74:	00004097          	auipc	ra,0x4
    80000f78:	91a080e7          	jalr	-1766(ra) # 8000488e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f7c:	00005097          	auipc	ra,0x5
    80000f80:	226080e7          	jalr	550(ra) # 800061a2 <virtio_disk_init>
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
    800019ec:	f187a783          	lw	a5,-232(a5) # 80008900 <first.1>
    800019f0:	eb89                	bnez	a5,80001a02 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019f2:	00001097          	auipc	ra,0x1
    800019f6:	ece080e7          	jalr	-306(ra) # 800028c0 <usertrapret>
}
    800019fa:	60a2                	ld	ra,8(sp)
    800019fc:	6402                	ld	s0,0(sp)
    800019fe:	0141                	addi	sp,sp,16
    80001a00:	8082                	ret
    first = 0;
    80001a02:	00007797          	auipc	a5,0x7
    80001a06:	ee07af23          	sw	zero,-258(a5) # 80008900 <first.1>
    fsinit(ROOTDEV);
    80001a0a:	4505                	li	a0,1
    80001a0c:	00002097          	auipc	ra,0x2
    80001a10:	e4c080e7          	jalr	-436(ra) # 80003858 <fsinit>
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
    80001a38:	ed078793          	addi	a5,a5,-304 # 80008904 <nextpid>
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
    80001cf0:	c2458593          	addi	a1,a1,-988 # 80008910 <initcode>
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
    80001d2e:	55c080e7          	jalr	1372(ra) # 80004286 <namei>
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
    80001e76:	aae080e7          	jalr	-1362(ra) # 80004920 <filedup>
    80001e7a:	00a9b023          	sd	a0,0(s3)
    80001e7e:	b7e5                	j	80001e66 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e80:	15093503          	ld	a0,336(s2)
    80001e84:	00002097          	auipc	ra,0x2
    80001e88:	c0e080e7          	jalr	-1010(ra) # 80003a92 <idup>
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
    80001f32:	711d                	addi	sp,sp,-96
    80001f34:	ec86                	sd	ra,88(sp)
    80001f36:	e8a2                	sd	s0,80(sp)
    80001f38:	e4a6                	sd	s1,72(sp)
    80001f3a:	e0ca                	sd	s2,64(sp)
    80001f3c:	fc4e                	sd	s3,56(sp)
    80001f3e:	f852                	sd	s4,48(sp)
    80001f40:	f456                	sd	s5,40(sp)
    80001f42:	f05a                	sd	s6,32(sp)
    80001f44:	ec5e                	sd	s7,24(sp)
    80001f46:	e862                	sd	s8,16(sp)
    80001f48:	e466                	sd	s9,8(sp)
    80001f4a:	1080                	addi	s0,sp,96
    80001f4c:	8792                	mv	a5,tp
  int id = r_tp();
    80001f4e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f50:	00779c93          	slli	s9,a5,0x7
    80001f54:	0000f717          	auipc	a4,0xf
    80001f58:	34c70713          	addi	a4,a4,844 # 800112a0 <pid_lock>
    80001f5c:	9766                	add	a4,a4,s9
    80001f5e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f62:	0000f717          	auipc	a4,0xf
    80001f66:	37670713          	addi	a4,a4,886 # 800112d8 <cpus+0x8>
    80001f6a:	9cba                	add	s9,s9,a4
      if(p->state == RUNNABLE) {
    80001f6c:	4a0d                	li	s4,3
        if(p->frozen==1){
    80001f6e:	4b05                	li	s6,1
        c->proc = p;
    80001f70:	079e                	slli	a5,a5,0x7
    80001f72:	0000fa97          	auipc	s5,0xf
    80001f76:	32ea8a93          	addi	s5,s5,814 # 800112a0 <pid_lock>
    80001f7a:	9abe                	add	s5,s5,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f7c:	0001d997          	auipc	s3,0x1d
    80001f80:	75498993          	addi	s3,s3,1876 # 8001f6d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f88:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f8c:	10079073          	csrw	sstatus,a5
    80001f90:	0000f497          	auipc	s1,0xf
    80001f94:	74048493          	addi	s1,s1,1856 # 800116d0 <proc>
        p->state = RUNNING;
    80001f98:	4c11                	li	s8,4
            if(p->pending_signals & (1<<SIGCONT)){
    80001f9a:	00080bb7          	lui	s7,0x80
    80001f9e:	a82d                	j	80001fd8 <scheduler+0xa6>
              p->frozen = 0;
    80001fa0:	3604ac23          	sw	zero,888(s1)
              p->pending_signals ^= (1<<SIGCONT);  // discard pending cont signal after handle
    80001fa4:	0177c7b3          	xor	a5,a5,s7
    80001fa8:	16f4a423          	sw	a5,360(s1)
        p->state = RUNNING;
    80001fac:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001fb0:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &p->context);
    80001fb4:	06090593          	addi	a1,s2,96
    80001fb8:	8566                	mv	a0,s9
    80001fba:	00001097          	auipc	ra,0x1
    80001fbe:	840080e7          	jalr	-1984(ra) # 800027fa <swtch>
        c->proc = 0;
    80001fc2:	020ab823          	sd	zero,48(s5)
      release(&p->lock);
    80001fc6:	8526                	mv	a0,s1
    80001fc8:	fffff097          	auipc	ra,0xfffff
    80001fcc:	cc8080e7          	jalr	-824(ra) # 80000c90 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fd0:	38048493          	addi	s1,s1,896
    80001fd4:	fb3488e3          	beq	s1,s3,80001f84 <scheduler+0x52>
      acquire(&p->lock);
    80001fd8:	8926                	mv	s2,s1
    80001fda:	8526                	mv	a0,s1
    80001fdc:	fffff097          	auipc	ra,0xfffff
    80001fe0:	bea080e7          	jalr	-1046(ra) # 80000bc6 <acquire>
      if(p->state == RUNNABLE) {
    80001fe4:	4c9c                	lw	a5,24(s1)
    80001fe6:	ff4790e3          	bne	a5,s4,80001fc6 <scheduler+0x94>
        if(p->frozen==1){
    80001fea:	3784a783          	lw	a5,888(s1)
    80001fee:	fb679fe3          	bne	a5,s6,80001fac <scheduler+0x7a>
            if(p->pending_signals & (1<<SIGCONT)){
    80001ff2:	1684a783          	lw	a5,360(s1)
    80001ff6:	0177f733          	and	a4,a5,s7
    80001ffa:	2701                	sext.w	a4,a4
    80001ffc:	f355                	bnez	a4,80001fa0 <scheduler+0x6e>
    80001ffe:	bfc9                	j	80001fd0 <scheduler+0x9e>

0000000080002000 <sched>:
{
    80002000:	7179                	addi	sp,sp,-48
    80002002:	f406                	sd	ra,40(sp)
    80002004:	f022                	sd	s0,32(sp)
    80002006:	ec26                	sd	s1,24(sp)
    80002008:	e84a                	sd	s2,16(sp)
    8000200a:	e44e                	sd	s3,8(sp)
    8000200c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000200e:	00000097          	auipc	ra,0x0
    80002012:	98a080e7          	jalr	-1654(ra) # 80001998 <myproc>
    80002016:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002018:	fffff097          	auipc	ra,0xfffff
    8000201c:	b34080e7          	jalr	-1228(ra) # 80000b4c <holding>
    80002020:	c93d                	beqz	a0,80002096 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002022:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002024:	2781                	sext.w	a5,a5
    80002026:	079e                	slli	a5,a5,0x7
    80002028:	0000f717          	auipc	a4,0xf
    8000202c:	27870713          	addi	a4,a4,632 # 800112a0 <pid_lock>
    80002030:	97ba                	add	a5,a5,a4
    80002032:	0a87a703          	lw	a4,168(a5)
    80002036:	4785                	li	a5,1
    80002038:	06f71763          	bne	a4,a5,800020a6 <sched+0xa6>
  if(p->state == RUNNING)
    8000203c:	4c98                	lw	a4,24(s1)
    8000203e:	4791                	li	a5,4
    80002040:	06f70b63          	beq	a4,a5,800020b6 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002044:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002048:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000204a:	efb5                	bnez	a5,800020c6 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000204c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000204e:	0000f917          	auipc	s2,0xf
    80002052:	25290913          	addi	s2,s2,594 # 800112a0 <pid_lock>
    80002056:	2781                	sext.w	a5,a5
    80002058:	079e                	slli	a5,a5,0x7
    8000205a:	97ca                	add	a5,a5,s2
    8000205c:	0ac7a983          	lw	s3,172(a5)
    80002060:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002062:	2781                	sext.w	a5,a5
    80002064:	079e                	slli	a5,a5,0x7
    80002066:	0000f597          	auipc	a1,0xf
    8000206a:	27258593          	addi	a1,a1,626 # 800112d8 <cpus+0x8>
    8000206e:	95be                	add	a1,a1,a5
    80002070:	06048513          	addi	a0,s1,96
    80002074:	00000097          	auipc	ra,0x0
    80002078:	786080e7          	jalr	1926(ra) # 800027fa <swtch>
    8000207c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000207e:	2781                	sext.w	a5,a5
    80002080:	079e                	slli	a5,a5,0x7
    80002082:	97ca                	add	a5,a5,s2
    80002084:	0b37a623          	sw	s3,172(a5)
}
    80002088:	70a2                	ld	ra,40(sp)
    8000208a:	7402                	ld	s0,32(sp)
    8000208c:	64e2                	ld	s1,24(sp)
    8000208e:	6942                	ld	s2,16(sp)
    80002090:	69a2                	ld	s3,8(sp)
    80002092:	6145                	addi	sp,sp,48
    80002094:	8082                	ret
    panic("sched p->lock");
    80002096:	00006517          	auipc	a0,0x6
    8000209a:	19a50513          	addi	a0,a0,410 # 80008230 <digits+0x1f0>
    8000209e:	ffffe097          	auipc	ra,0xffffe
    800020a2:	490080e7          	jalr	1168(ra) # 8000052e <panic>
    panic("sched locks");
    800020a6:	00006517          	auipc	a0,0x6
    800020aa:	19a50513          	addi	a0,a0,410 # 80008240 <digits+0x200>
    800020ae:	ffffe097          	auipc	ra,0xffffe
    800020b2:	480080e7          	jalr	1152(ra) # 8000052e <panic>
    panic("sched running");
    800020b6:	00006517          	auipc	a0,0x6
    800020ba:	19a50513          	addi	a0,a0,410 # 80008250 <digits+0x210>
    800020be:	ffffe097          	auipc	ra,0xffffe
    800020c2:	470080e7          	jalr	1136(ra) # 8000052e <panic>
    panic("sched interruptible");
    800020c6:	00006517          	auipc	a0,0x6
    800020ca:	19a50513          	addi	a0,a0,410 # 80008260 <digits+0x220>
    800020ce:	ffffe097          	auipc	ra,0xffffe
    800020d2:	460080e7          	jalr	1120(ra) # 8000052e <panic>

00000000800020d6 <yield>:
{
    800020d6:	1101                	addi	sp,sp,-32
    800020d8:	ec06                	sd	ra,24(sp)
    800020da:	e822                	sd	s0,16(sp)
    800020dc:	e426                	sd	s1,8(sp)
    800020de:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020e0:	00000097          	auipc	ra,0x0
    800020e4:	8b8080e7          	jalr	-1864(ra) # 80001998 <myproc>
    800020e8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020ea:	fffff097          	auipc	ra,0xfffff
    800020ee:	adc080e7          	jalr	-1316(ra) # 80000bc6 <acquire>
  p->state = RUNNABLE;
    800020f2:	478d                	li	a5,3
    800020f4:	cc9c                	sw	a5,24(s1)
  sched();
    800020f6:	00000097          	auipc	ra,0x0
    800020fa:	f0a080e7          	jalr	-246(ra) # 80002000 <sched>
  release(&p->lock);
    800020fe:	8526                	mv	a0,s1
    80002100:	fffff097          	auipc	ra,0xfffff
    80002104:	b90080e7          	jalr	-1136(ra) # 80000c90 <release>
}
    80002108:	60e2                	ld	ra,24(sp)
    8000210a:	6442                	ld	s0,16(sp)
    8000210c:	64a2                	ld	s1,8(sp)
    8000210e:	6105                	addi	sp,sp,32
    80002110:	8082                	ret

0000000080002112 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002112:	7179                	addi	sp,sp,-48
    80002114:	f406                	sd	ra,40(sp)
    80002116:	f022                	sd	s0,32(sp)
    80002118:	ec26                	sd	s1,24(sp)
    8000211a:	e84a                	sd	s2,16(sp)
    8000211c:	e44e                	sd	s3,8(sp)
    8000211e:	1800                	addi	s0,sp,48
    80002120:	89aa                	mv	s3,a0
    80002122:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002124:	00000097          	auipc	ra,0x0
    80002128:	874080e7          	jalr	-1932(ra) # 80001998 <myproc>
    8000212c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000212e:	fffff097          	auipc	ra,0xfffff
    80002132:	a98080e7          	jalr	-1384(ra) # 80000bc6 <acquire>
  release(lk);
    80002136:	854a                	mv	a0,s2
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	b58080e7          	jalr	-1192(ra) # 80000c90 <release>

  // Go to sleep.
  p->chan = chan;
    80002140:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002144:	4789                	li	a5,2
    80002146:	cc9c                	sw	a5,24(s1)

  sched();
    80002148:	00000097          	auipc	ra,0x0
    8000214c:	eb8080e7          	jalr	-328(ra) # 80002000 <sched>

  // Tidy up.
  p->chan = 0;
    80002150:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002154:	8526                	mv	a0,s1
    80002156:	fffff097          	auipc	ra,0xfffff
    8000215a:	b3a080e7          	jalr	-1222(ra) # 80000c90 <release>
  acquire(lk);
    8000215e:	854a                	mv	a0,s2
    80002160:	fffff097          	auipc	ra,0xfffff
    80002164:	a66080e7          	jalr	-1434(ra) # 80000bc6 <acquire>
}
    80002168:	70a2                	ld	ra,40(sp)
    8000216a:	7402                	ld	s0,32(sp)
    8000216c:	64e2                	ld	s1,24(sp)
    8000216e:	6942                	ld	s2,16(sp)
    80002170:	69a2                	ld	s3,8(sp)
    80002172:	6145                	addi	sp,sp,48
    80002174:	8082                	ret

0000000080002176 <wait>:
{
    80002176:	715d                	addi	sp,sp,-80
    80002178:	e486                	sd	ra,72(sp)
    8000217a:	e0a2                	sd	s0,64(sp)
    8000217c:	fc26                	sd	s1,56(sp)
    8000217e:	f84a                	sd	s2,48(sp)
    80002180:	f44e                	sd	s3,40(sp)
    80002182:	f052                	sd	s4,32(sp)
    80002184:	ec56                	sd	s5,24(sp)
    80002186:	e85a                	sd	s6,16(sp)
    80002188:	e45e                	sd	s7,8(sp)
    8000218a:	e062                	sd	s8,0(sp)
    8000218c:	0880                	addi	s0,sp,80
    8000218e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002190:	00000097          	auipc	ra,0x0
    80002194:	808080e7          	jalr	-2040(ra) # 80001998 <myproc>
    80002198:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000219a:	0000f517          	auipc	a0,0xf
    8000219e:	11e50513          	addi	a0,a0,286 # 800112b8 <wait_lock>
    800021a2:	fffff097          	auipc	ra,0xfffff
    800021a6:	a24080e7          	jalr	-1500(ra) # 80000bc6 <acquire>
    havekids = 0;
    800021aa:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800021ac:	4a95                	li	s5,5
        havekids = 1;
    800021ae:	4a05                	li	s4,1
    for(np = proc; np < &proc[NPROC]; np++){
    800021b0:	0001d997          	auipc	s3,0x1d
    800021b4:	52098993          	addi	s3,s3,1312 # 8001f6d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021b8:	0000fc17          	auipc	s8,0xf
    800021bc:	100c0c13          	addi	s8,s8,256 # 800112b8 <wait_lock>
    havekids = 0;
    800021c0:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800021c2:	0000f497          	auipc	s1,0xf
    800021c6:	50e48493          	addi	s1,s1,1294 # 800116d0 <proc>
    800021ca:	a0bd                	j	80002238 <wait+0xc2>
          pid = np->pid;
    800021cc:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800021d0:	000b0e63          	beqz	s6,800021ec <wait+0x76>
    800021d4:	4691                	li	a3,4
    800021d6:	02c48613          	addi	a2,s1,44
    800021da:	85da                	mv	a1,s6
    800021dc:	05093503          	ld	a0,80(s2)
    800021e0:	fffff097          	auipc	ra,0xfffff
    800021e4:	478080e7          	jalr	1144(ra) # 80001658 <copyout>
    800021e8:	02054563          	bltz	a0,80002212 <wait+0x9c>
          freeproc(np);
    800021ec:	8526                	mv	a0,s1
    800021ee:	00000097          	auipc	ra,0x0
    800021f2:	95c080e7          	jalr	-1700(ra) # 80001b4a <freeproc>
          release(&np->lock);
    800021f6:	8526                	mv	a0,s1
    800021f8:	fffff097          	auipc	ra,0xfffff
    800021fc:	a98080e7          	jalr	-1384(ra) # 80000c90 <release>
          release(&wait_lock);
    80002200:	0000f517          	auipc	a0,0xf
    80002204:	0b850513          	addi	a0,a0,184 # 800112b8 <wait_lock>
    80002208:	fffff097          	auipc	ra,0xfffff
    8000220c:	a88080e7          	jalr	-1400(ra) # 80000c90 <release>
          return pid;
    80002210:	a0a5                	j	80002278 <wait+0x102>
            release(&np->lock);
    80002212:	8526                	mv	a0,s1
    80002214:	fffff097          	auipc	ra,0xfffff
    80002218:	a7c080e7          	jalr	-1412(ra) # 80000c90 <release>
            release(&wait_lock);
    8000221c:	0000f517          	auipc	a0,0xf
    80002220:	09c50513          	addi	a0,a0,156 # 800112b8 <wait_lock>
    80002224:	fffff097          	auipc	ra,0xfffff
    80002228:	a6c080e7          	jalr	-1428(ra) # 80000c90 <release>
            return -1;
    8000222c:	59fd                	li	s3,-1
    8000222e:	a0a9                	j	80002278 <wait+0x102>
    for(np = proc; np < &proc[NPROC]; np++){
    80002230:	38048493          	addi	s1,s1,896
    80002234:	03348463          	beq	s1,s3,8000225c <wait+0xe6>
      if(np->parent == p){
    80002238:	7c9c                	ld	a5,56(s1)
    8000223a:	ff279be3          	bne	a5,s2,80002230 <wait+0xba>
        acquire(&np->lock);
    8000223e:	8526                	mv	a0,s1
    80002240:	fffff097          	auipc	ra,0xfffff
    80002244:	986080e7          	jalr	-1658(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    80002248:	4c9c                	lw	a5,24(s1)
    8000224a:	f95781e3          	beq	a5,s5,800021cc <wait+0x56>
        release(&np->lock);
    8000224e:	8526                	mv	a0,s1
    80002250:	fffff097          	auipc	ra,0xfffff
    80002254:	a40080e7          	jalr	-1472(ra) # 80000c90 <release>
        havekids = 1;
    80002258:	8752                	mv	a4,s4
    8000225a:	bfd9                	j	80002230 <wait+0xba>
    if(!havekids || p->killed==1){
    8000225c:	c709                	beqz	a4,80002266 <wait+0xf0>
    8000225e:	02892783          	lw	a5,40(s2)
    80002262:	03479863          	bne	a5,s4,80002292 <wait+0x11c>
      release(&wait_lock);
    80002266:	0000f517          	auipc	a0,0xf
    8000226a:	05250513          	addi	a0,a0,82 # 800112b8 <wait_lock>
    8000226e:	fffff097          	auipc	ra,0xfffff
    80002272:	a22080e7          	jalr	-1502(ra) # 80000c90 <release>
      return -1;
    80002276:	59fd                	li	s3,-1
}
    80002278:	854e                	mv	a0,s3
    8000227a:	60a6                	ld	ra,72(sp)
    8000227c:	6406                	ld	s0,64(sp)
    8000227e:	74e2                	ld	s1,56(sp)
    80002280:	7942                	ld	s2,48(sp)
    80002282:	79a2                	ld	s3,40(sp)
    80002284:	7a02                	ld	s4,32(sp)
    80002286:	6ae2                	ld	s5,24(sp)
    80002288:	6b42                	ld	s6,16(sp)
    8000228a:	6ba2                	ld	s7,8(sp)
    8000228c:	6c02                	ld	s8,0(sp)
    8000228e:	6161                	addi	sp,sp,80
    80002290:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002292:	85e2                	mv	a1,s8
    80002294:	854a                	mv	a0,s2
    80002296:	00000097          	auipc	ra,0x0
    8000229a:	e7c080e7          	jalr	-388(ra) # 80002112 <sleep>
    havekids = 0;
    8000229e:	b70d                	j	800021c0 <wait+0x4a>

00000000800022a0 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800022a0:	7139                	addi	sp,sp,-64
    800022a2:	fc06                	sd	ra,56(sp)
    800022a4:	f822                	sd	s0,48(sp)
    800022a6:	f426                	sd	s1,40(sp)
    800022a8:	f04a                	sd	s2,32(sp)
    800022aa:	ec4e                	sd	s3,24(sp)
    800022ac:	e852                	sd	s4,16(sp)
    800022ae:	e456                	sd	s5,8(sp)
    800022b0:	0080                	addi	s0,sp,64
    800022b2:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800022b4:	0000f497          	auipc	s1,0xf
    800022b8:	41c48493          	addi	s1,s1,1052 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800022bc:	4989                	li	s3,2
        p->state = RUNNABLE;
    800022be:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800022c0:	0001d917          	auipc	s2,0x1d
    800022c4:	41090913          	addi	s2,s2,1040 # 8001f6d0 <tickslock>
    800022c8:	a811                	j	800022dc <wakeup+0x3c>
      }
      release(&p->lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	9c4080e7          	jalr	-1596(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800022d4:	38048493          	addi	s1,s1,896
    800022d8:	03248663          	beq	s1,s2,80002304 <wakeup+0x64>
    if(p != myproc()){
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	6bc080e7          	jalr	1724(ra) # 80001998 <myproc>
    800022e4:	fea488e3          	beq	s1,a0,800022d4 <wakeup+0x34>
      acquire(&p->lock);
    800022e8:	8526                	mv	a0,s1
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	8dc080e7          	jalr	-1828(ra) # 80000bc6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800022f2:	4c9c                	lw	a5,24(s1)
    800022f4:	fd379be3          	bne	a5,s3,800022ca <wakeup+0x2a>
    800022f8:	709c                	ld	a5,32(s1)
    800022fa:	fd4798e3          	bne	a5,s4,800022ca <wakeup+0x2a>
        p->state = RUNNABLE;
    800022fe:	0154ac23          	sw	s5,24(s1)
    80002302:	b7e1                	j	800022ca <wakeup+0x2a>
    }
  }
}
    80002304:	70e2                	ld	ra,56(sp)
    80002306:	7442                	ld	s0,48(sp)
    80002308:	74a2                	ld	s1,40(sp)
    8000230a:	7902                	ld	s2,32(sp)
    8000230c:	69e2                	ld	s3,24(sp)
    8000230e:	6a42                	ld	s4,16(sp)
    80002310:	6aa2                	ld	s5,8(sp)
    80002312:	6121                	addi	sp,sp,64
    80002314:	8082                	ret

0000000080002316 <reparent>:
{
    80002316:	7179                	addi	sp,sp,-48
    80002318:	f406                	sd	ra,40(sp)
    8000231a:	f022                	sd	s0,32(sp)
    8000231c:	ec26                	sd	s1,24(sp)
    8000231e:	e84a                	sd	s2,16(sp)
    80002320:	e44e                	sd	s3,8(sp)
    80002322:	e052                	sd	s4,0(sp)
    80002324:	1800                	addi	s0,sp,48
    80002326:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002328:	0000f497          	auipc	s1,0xf
    8000232c:	3a848493          	addi	s1,s1,936 # 800116d0 <proc>
      pp->parent = initproc;
    80002330:	00007a17          	auipc	s4,0x7
    80002334:	cf8a0a13          	addi	s4,s4,-776 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002338:	0001d997          	auipc	s3,0x1d
    8000233c:	39898993          	addi	s3,s3,920 # 8001f6d0 <tickslock>
    80002340:	a029                	j	8000234a <reparent+0x34>
    80002342:	38048493          	addi	s1,s1,896
    80002346:	01348d63          	beq	s1,s3,80002360 <reparent+0x4a>
    if(pp->parent == p){
    8000234a:	7c9c                	ld	a5,56(s1)
    8000234c:	ff279be3          	bne	a5,s2,80002342 <reparent+0x2c>
      pp->parent = initproc;
    80002350:	000a3503          	ld	a0,0(s4)
    80002354:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002356:	00000097          	auipc	ra,0x0
    8000235a:	f4a080e7          	jalr	-182(ra) # 800022a0 <wakeup>
    8000235e:	b7d5                	j	80002342 <reparent+0x2c>
}
    80002360:	70a2                	ld	ra,40(sp)
    80002362:	7402                	ld	s0,32(sp)
    80002364:	64e2                	ld	s1,24(sp)
    80002366:	6942                	ld	s2,16(sp)
    80002368:	69a2                	ld	s3,8(sp)
    8000236a:	6a02                	ld	s4,0(sp)
    8000236c:	6145                	addi	sp,sp,48
    8000236e:	8082                	ret

0000000080002370 <exit>:
{
    80002370:	7179                	addi	sp,sp,-48
    80002372:	f406                	sd	ra,40(sp)
    80002374:	f022                	sd	s0,32(sp)
    80002376:	ec26                	sd	s1,24(sp)
    80002378:	e84a                	sd	s2,16(sp)
    8000237a:	e44e                	sd	s3,8(sp)
    8000237c:	e052                	sd	s4,0(sp)
    8000237e:	1800                	addi	s0,sp,48
    80002380:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	616080e7          	jalr	1558(ra) # 80001998 <myproc>
    8000238a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000238c:	00007797          	auipc	a5,0x7
    80002390:	c9c7b783          	ld	a5,-868(a5) # 80009028 <initproc>
    80002394:	0d050493          	addi	s1,a0,208
    80002398:	15050913          	addi	s2,a0,336
    8000239c:	02a79363          	bne	a5,a0,800023c2 <exit+0x52>
    panic("init exiting");
    800023a0:	00006517          	auipc	a0,0x6
    800023a4:	ed850513          	addi	a0,a0,-296 # 80008278 <digits+0x238>
    800023a8:	ffffe097          	auipc	ra,0xffffe
    800023ac:	186080e7          	jalr	390(ra) # 8000052e <panic>
      fileclose(f);
    800023b0:	00002097          	auipc	ra,0x2
    800023b4:	5c2080e7          	jalr	1474(ra) # 80004972 <fileclose>
      p->ofile[fd] = 0;
    800023b8:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800023bc:	04a1                	addi	s1,s1,8
    800023be:	01248563          	beq	s1,s2,800023c8 <exit+0x58>
    if(p->ofile[fd]){
    800023c2:	6088                	ld	a0,0(s1)
    800023c4:	f575                	bnez	a0,800023b0 <exit+0x40>
    800023c6:	bfdd                	j	800023bc <exit+0x4c>
  begin_op();
    800023c8:	00002097          	auipc	ra,0x2
    800023cc:	0de080e7          	jalr	222(ra) # 800044a6 <begin_op>
  iput(p->cwd);
    800023d0:	1509b503          	ld	a0,336(s3)
    800023d4:	00002097          	auipc	ra,0x2
    800023d8:	8b6080e7          	jalr	-1866(ra) # 80003c8a <iput>
  end_op();
    800023dc:	00002097          	auipc	ra,0x2
    800023e0:	14a080e7          	jalr	330(ra) # 80004526 <end_op>
  p->cwd = 0;
    800023e4:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800023e8:	0000f497          	auipc	s1,0xf
    800023ec:	ed048493          	addi	s1,s1,-304 # 800112b8 <wait_lock>
    800023f0:	8526                	mv	a0,s1
    800023f2:	ffffe097          	auipc	ra,0xffffe
    800023f6:	7d4080e7          	jalr	2004(ra) # 80000bc6 <acquire>
  reparent(p);
    800023fa:	854e                	mv	a0,s3
    800023fc:	00000097          	auipc	ra,0x0
    80002400:	f1a080e7          	jalr	-230(ra) # 80002316 <reparent>
  wakeup(p->parent);
    80002404:	0389b503          	ld	a0,56(s3)
    80002408:	00000097          	auipc	ra,0x0
    8000240c:	e98080e7          	jalr	-360(ra) # 800022a0 <wakeup>
  acquire(&p->lock);
    80002410:	854e                	mv	a0,s3
    80002412:	ffffe097          	auipc	ra,0xffffe
    80002416:	7b4080e7          	jalr	1972(ra) # 80000bc6 <acquire>
  p->xstate = status;
    8000241a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000241e:	4795                	li	a5,5
    80002420:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002424:	8526                	mv	a0,s1
    80002426:	fffff097          	auipc	ra,0xfffff
    8000242a:	86a080e7          	jalr	-1942(ra) # 80000c90 <release>
  sched();
    8000242e:	00000097          	auipc	ra,0x0
    80002432:	bd2080e7          	jalr	-1070(ra) # 80002000 <sched>
  panic("zombie exit");
    80002436:	00006517          	auipc	a0,0x6
    8000243a:	e5250513          	addi	a0,a0,-430 # 80008288 <digits+0x248>
    8000243e:	ffffe097          	auipc	ra,0xffffe
    80002442:	0f0080e7          	jalr	240(ra) # 8000052e <panic>

0000000080002446 <kill>:


// new kill sending signal to process pid - task 2.2.1
int
kill(int pid, int signum)
{
    80002446:	7179                	addi	sp,sp,-48
    80002448:	f406                	sd	ra,40(sp)
    8000244a:	f022                	sd	s0,32(sp)
    8000244c:	ec26                	sd	s1,24(sp)
    8000244e:	e84a                	sd	s2,16(sp)
    80002450:	e44e                	sd	s3,8(sp)
    80002452:	e052                	sd	s4,0(sp)
    80002454:	1800                	addi	s0,sp,48
    80002456:	892a                	mv	s2,a0
    80002458:	8a2e                	mv	s4,a1
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000245a:	0000f497          	auipc	s1,0xf
    8000245e:	27648493          	addi	s1,s1,630 # 800116d0 <proc>
    80002462:	0001d997          	auipc	s3,0x1d
    80002466:	26e98993          	addi	s3,s3,622 # 8001f6d0 <tickslock>
    acquire(&p->lock);
    8000246a:	8526                	mv	a0,s1
    8000246c:	ffffe097          	auipc	ra,0xffffe
    80002470:	75a080e7          	jalr	1882(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    80002474:	589c                	lw	a5,48(s1)
    80002476:	01278d63          	beq	a5,s2,80002490 <kill+0x4a>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000247a:	8526                	mv	a0,s1
    8000247c:	fffff097          	auipc	ra,0xfffff
    80002480:	814080e7          	jalr	-2028(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002484:	38048493          	addi	s1,s1,896
    80002488:	ff3491e3          	bne	s1,s3,8000246a <kill+0x24>
  }
  return -1;
    8000248c:	557d                	li	a0,-1
    8000248e:	a815                	j	800024c2 <kill+0x7c>
      if(p->signal_handlers[signum].sa_handler!=(void*)SIG_IGN){
    80002490:	017a0793          	addi	a5,s4,23
    80002494:	0792                	slli	a5,a5,0x4
    80002496:	97a6                	add	a5,a5,s1
    80002498:	6398                	ld	a4,0(a5)
    8000249a:	4785                	li	a5,1
    8000249c:	00f70963          	beq	a4,a5,800024ae <kill+0x68>
        p->pending_signals|= (1<<signum);
    800024a0:	0147973b          	sllw	a4,a5,s4
    800024a4:	1684a783          	lw	a5,360(s1)
    800024a8:	8fd9                	or	a5,a5,a4
    800024aa:	16f4a423          	sw	a5,360(s1)
      if(p->state == SLEEPING && signum == SIGKILL){
    800024ae:	4c98                	lw	a4,24(s1)
    800024b0:	4789                	li	a5,2
    800024b2:	02f70063          	beq	a4,a5,800024d2 <kill+0x8c>
      release(&p->lock);
    800024b6:	8526                	mv	a0,s1
    800024b8:	ffffe097          	auipc	ra,0xffffe
    800024bc:	7d8080e7          	jalr	2008(ra) # 80000c90 <release>
      return 0;
    800024c0:	4501                	li	a0,0
}
    800024c2:	70a2                	ld	ra,40(sp)
    800024c4:	7402                	ld	s0,32(sp)
    800024c6:	64e2                	ld	s1,24(sp)
    800024c8:	6942                	ld	s2,16(sp)
    800024ca:	69a2                	ld	s3,8(sp)
    800024cc:	6a02                	ld	s4,0(sp)
    800024ce:	6145                	addi	sp,sp,48
    800024d0:	8082                	ret
      if(p->state == SLEEPING && signum == SIGKILL){
    800024d2:	47a5                	li	a5,9
    800024d4:	fefa11e3          	bne	s4,a5,800024b6 <kill+0x70>
        p->state = RUNNABLE;
    800024d8:	478d                	li	a5,3
    800024da:	cc9c                	sw	a5,24(s1)
    800024dc:	bfe9                	j	800024b6 <kill+0x70>

00000000800024de <sig_stop>:
//   return -1;
// }

int
sig_stop(int pid)
{
    800024de:	7179                	addi	sp,sp,-48
    800024e0:	f406                	sd	ra,40(sp)
    800024e2:	f022                	sd	s0,32(sp)
    800024e4:	ec26                	sd	s1,24(sp)
    800024e6:	e84a                	sd	s2,16(sp)
    800024e8:	e44e                	sd	s3,8(sp)
    800024ea:	1800                	addi	s0,sp,48
    800024ec:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800024ee:	0000f497          	auipc	s1,0xf
    800024f2:	1e248493          	addi	s1,s1,482 # 800116d0 <proc>
    800024f6:	0001d997          	auipc	s3,0x1d
    800024fa:	1da98993          	addi	s3,s3,474 # 8001f6d0 <tickslock>
    acquire(&p->lock);
    800024fe:	8526                	mv	a0,s1
    80002500:	ffffe097          	auipc	ra,0xffffe
    80002504:	6c6080e7          	jalr	1734(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    80002508:	589c                	lw	a5,48(s1)
    8000250a:	01278d63          	beq	a5,s2,80002524 <sig_stop+0x46>
      p->pending_signals|=(1<<SIGSTOP);

      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000250e:	8526                	mv	a0,s1
    80002510:	ffffe097          	auipc	ra,0xffffe
    80002514:	780080e7          	jalr	1920(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002518:	38048493          	addi	s1,s1,896
    8000251c:	ff3491e3          	bne	s1,s3,800024fe <sig_stop+0x20>
  }
  return -1;
    80002520:	557d                	li	a0,-1
    80002522:	a831                	j	8000253e <sig_stop+0x60>
      p->pending_signals|=(1<<SIGSTOP);
    80002524:	1684a783          	lw	a5,360(s1)
    80002528:	00020737          	lui	a4,0x20
    8000252c:	8fd9                	or	a5,a5,a4
    8000252e:	16f4a423          	sw	a5,360(s1)
      release(&p->lock);
    80002532:	8526                	mv	a0,s1
    80002534:	ffffe097          	auipc	ra,0xffffe
    80002538:	75c080e7          	jalr	1884(ra) # 80000c90 <release>
      return 0;
    8000253c:	4501                	li	a0,0
}
    8000253e:	70a2                	ld	ra,40(sp)
    80002540:	7402                	ld	s0,32(sp)
    80002542:	64e2                	ld	s1,24(sp)
    80002544:	6942                	ld	s2,16(sp)
    80002546:	69a2                	ld	s3,8(sp)
    80002548:	6145                	addi	sp,sp,48
    8000254a:	8082                	ret

000000008000254c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000254c:	7179                	addi	sp,sp,-48
    8000254e:	f406                	sd	ra,40(sp)
    80002550:	f022                	sd	s0,32(sp)
    80002552:	ec26                	sd	s1,24(sp)
    80002554:	e84a                	sd	s2,16(sp)
    80002556:	e44e                	sd	s3,8(sp)
    80002558:	e052                	sd	s4,0(sp)
    8000255a:	1800                	addi	s0,sp,48
    8000255c:	84aa                	mv	s1,a0
    8000255e:	892e                	mv	s2,a1
    80002560:	89b2                	mv	s3,a2
    80002562:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002564:	fffff097          	auipc	ra,0xfffff
    80002568:	434080e7          	jalr	1076(ra) # 80001998 <myproc>
  if(user_dst){
    8000256c:	c08d                	beqz	s1,8000258e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000256e:	86d2                	mv	a3,s4
    80002570:	864e                	mv	a2,s3
    80002572:	85ca                	mv	a1,s2
    80002574:	6928                	ld	a0,80(a0)
    80002576:	fffff097          	auipc	ra,0xfffff
    8000257a:	0e2080e7          	jalr	226(ra) # 80001658 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000257e:	70a2                	ld	ra,40(sp)
    80002580:	7402                	ld	s0,32(sp)
    80002582:	64e2                	ld	s1,24(sp)
    80002584:	6942                	ld	s2,16(sp)
    80002586:	69a2                	ld	s3,8(sp)
    80002588:	6a02                	ld	s4,0(sp)
    8000258a:	6145                	addi	sp,sp,48
    8000258c:	8082                	ret
    memmove((char *)dst, src, len);
    8000258e:	000a061b          	sext.w	a2,s4
    80002592:	85ce                	mv	a1,s3
    80002594:	854a                	mv	a0,s2
    80002596:	ffffe097          	auipc	ra,0xffffe
    8000259a:	79e080e7          	jalr	1950(ra) # 80000d34 <memmove>
    return 0;
    8000259e:	8526                	mv	a0,s1
    800025a0:	bff9                	j	8000257e <either_copyout+0x32>

00000000800025a2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025a2:	7179                	addi	sp,sp,-48
    800025a4:	f406                	sd	ra,40(sp)
    800025a6:	f022                	sd	s0,32(sp)
    800025a8:	ec26                	sd	s1,24(sp)
    800025aa:	e84a                	sd	s2,16(sp)
    800025ac:	e44e                	sd	s3,8(sp)
    800025ae:	e052                	sd	s4,0(sp)
    800025b0:	1800                	addi	s0,sp,48
    800025b2:	892a                	mv	s2,a0
    800025b4:	84ae                	mv	s1,a1
    800025b6:	89b2                	mv	s3,a2
    800025b8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025ba:	fffff097          	auipc	ra,0xfffff
    800025be:	3de080e7          	jalr	990(ra) # 80001998 <myproc>
  if(user_src){
    800025c2:	c08d                	beqz	s1,800025e4 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800025c4:	86d2                	mv	a3,s4
    800025c6:	864e                	mv	a2,s3
    800025c8:	85ca                	mv	a1,s2
    800025ca:	6928                	ld	a0,80(a0)
    800025cc:	fffff097          	auipc	ra,0xfffff
    800025d0:	118080e7          	jalr	280(ra) # 800016e4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025d4:	70a2                	ld	ra,40(sp)
    800025d6:	7402                	ld	s0,32(sp)
    800025d8:	64e2                	ld	s1,24(sp)
    800025da:	6942                	ld	s2,16(sp)
    800025dc:	69a2                	ld	s3,8(sp)
    800025de:	6a02                	ld	s4,0(sp)
    800025e0:	6145                	addi	sp,sp,48
    800025e2:	8082                	ret
    memmove(dst, (char*)src, len);
    800025e4:	000a061b          	sext.w	a2,s4
    800025e8:	85ce                	mv	a1,s3
    800025ea:	854a                	mv	a0,s2
    800025ec:	ffffe097          	auipc	ra,0xffffe
    800025f0:	748080e7          	jalr	1864(ra) # 80000d34 <memmove>
    return 0;
    800025f4:	8526                	mv	a0,s1
    800025f6:	bff9                	j	800025d4 <either_copyin+0x32>

00000000800025f8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025f8:	715d                	addi	sp,sp,-80
    800025fa:	e486                	sd	ra,72(sp)
    800025fc:	e0a2                	sd	s0,64(sp)
    800025fe:	fc26                	sd	s1,56(sp)
    80002600:	f84a                	sd	s2,48(sp)
    80002602:	f44e                	sd	s3,40(sp)
    80002604:	f052                	sd	s4,32(sp)
    80002606:	ec56                	sd	s5,24(sp)
    80002608:	e85a                	sd	s6,16(sp)
    8000260a:	e45e                	sd	s7,8(sp)
    8000260c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000260e:	00006517          	auipc	a0,0x6
    80002612:	d6250513          	addi	a0,a0,-670 # 80008370 <states.0+0x80>
    80002616:	ffffe097          	auipc	ra,0xffffe
    8000261a:	f62080e7          	jalr	-158(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000261e:	0000f497          	auipc	s1,0xf
    80002622:	20a48493          	addi	s1,s1,522 # 80011828 <proc+0x158>
    80002626:	0001d917          	auipc	s2,0x1d
    8000262a:	20290913          	addi	s2,s2,514 # 8001f828 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000262e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002630:	00006997          	auipc	s3,0x6
    80002634:	c6898993          	addi	s3,s3,-920 # 80008298 <digits+0x258>
    printf("%d %s %s", p->pid, state, p->name);
    80002638:	00006a97          	auipc	s5,0x6
    8000263c:	c68a8a93          	addi	s5,s5,-920 # 800082a0 <digits+0x260>
    printf("\n");
    80002640:	00006a17          	auipc	s4,0x6
    80002644:	d30a0a13          	addi	s4,s4,-720 # 80008370 <states.0+0x80>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002648:	00006b97          	auipc	s7,0x6
    8000264c:	ca8b8b93          	addi	s7,s7,-856 # 800082f0 <states.0>
    80002650:	a00d                	j	80002672 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002652:	ed86a583          	lw	a1,-296(a3)
    80002656:	8556                	mv	a0,s5
    80002658:	ffffe097          	auipc	ra,0xffffe
    8000265c:	f20080e7          	jalr	-224(ra) # 80000578 <printf>
    printf("\n");
    80002660:	8552                	mv	a0,s4
    80002662:	ffffe097          	auipc	ra,0xffffe
    80002666:	f16080e7          	jalr	-234(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000266a:	38048493          	addi	s1,s1,896
    8000266e:	03248263          	beq	s1,s2,80002692 <procdump+0x9a>
    if(p->state == UNUSED)
    80002672:	86a6                	mv	a3,s1
    80002674:	ec04a783          	lw	a5,-320(s1)
    80002678:	dbed                	beqz	a5,8000266a <procdump+0x72>
      state = "???";
    8000267a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000267c:	fcfb6be3          	bltu	s6,a5,80002652 <procdump+0x5a>
    80002680:	02079713          	slli	a4,a5,0x20
    80002684:	01d75793          	srli	a5,a4,0x1d
    80002688:	97de                	add	a5,a5,s7
    8000268a:	6390                	ld	a2,0(a5)
    8000268c:	f279                	bnez	a2,80002652 <procdump+0x5a>
      state = "???";
    8000268e:	864e                	mv	a2,s3
    80002690:	b7c9                	j	80002652 <procdump+0x5a>
  }
}
    80002692:	60a6                	ld	ra,72(sp)
    80002694:	6406                	ld	s0,64(sp)
    80002696:	74e2                	ld	s1,56(sp)
    80002698:	7942                	ld	s2,48(sp)
    8000269a:	79a2                	ld	s3,40(sp)
    8000269c:	7a02                	ld	s4,32(sp)
    8000269e:	6ae2                	ld	s5,24(sp)
    800026a0:	6b42                	ld	s6,16(sp)
    800026a2:	6ba2                	ld	s7,8(sp)
    800026a4:	6161                	addi	sp,sp,80
    800026a6:	8082                	ret

00000000800026a8 <is_valid_sigmask>:

int 
is_valid_sigmask(int sigmask){
    800026a8:	1141                	addi	sp,sp,-16
    800026aa:	e422                	sd	s0,8(sp)
    800026ac:	0800                	addi	s0,sp,16
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    800026ae:	000207b7          	lui	a5,0x20
    800026b2:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    800026b6:	8d7d                	and	a0,a0,a5
    return 0;
  return 1;
}
    800026b8:	00153513          	seqz	a0,a0
    800026bc:	6422                	ld	s0,8(sp)
    800026be:	0141                	addi	sp,sp,16
    800026c0:	8082                	ret

00000000800026c2 <sigprocmask>:

uint
sigprocmask(uint new_procmask){
    800026c2:	7179                	addi	sp,sp,-48
    800026c4:	f406                	sd	ra,40(sp)
    800026c6:	f022                	sd	s0,32(sp)
    800026c8:	ec26                	sd	s1,24(sp)
    800026ca:	e84a                	sd	s2,16(sp)
    800026cc:	e44e                	sd	s3,8(sp)
    800026ce:	1800                	addi	s0,sp,48
    800026d0:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800026d2:	fffff097          	auipc	ra,0xfffff
    800026d6:	2c6080e7          	jalr	710(ra) # 80001998 <myproc>
  if(is_valid_sigmask(new_procmask) == 0)
    800026da:	000207b7          	lui	a5,0x20
    800026de:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    800026e2:	00f977b3          	and	a5,s2,a5
    return -1;
    800026e6:	59fd                	li	s3,-1
  if(is_valid_sigmask(new_procmask) == 0)
    800026e8:	ef99                	bnez	a5,80002706 <sigprocmask+0x44>
    800026ea:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	4da080e7          	jalr	1242(ra) # 80000bc6 <acquire>
  int old_procmask = p->signal_mask;
    800026f4:	16c4a983          	lw	s3,364(s1)
  p->signal_mask = new_procmask;
    800026f8:	1724a623          	sw	s2,364(s1)
  release(&p->lock);
    800026fc:	8526                	mv	a0,s1
    800026fe:	ffffe097          	auipc	ra,0xffffe
    80002702:	592080e7          	jalr	1426(ra) # 80000c90 <release>
  
  return old_procmask;
}
    80002706:	854e                	mv	a0,s3
    80002708:	70a2                	ld	ra,40(sp)
    8000270a:	7402                	ld	s0,32(sp)
    8000270c:	64e2                	ld	s1,24(sp)
    8000270e:	6942                	ld	s2,16(sp)
    80002710:	69a2                	ld	s3,8(sp)
    80002712:	6145                	addi	sp,sp,48
    80002714:	8082                	ret

0000000080002716 <sigaction>:
 
int 
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP)
    80002716:	0005079b          	sext.w	a5,a0
    8000271a:	477d                	li	a4,31
    8000271c:	08f76663          	bltu	a4,a5,800027a8 <sigaction+0x92>
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
    80002720:	7179                	addi	sp,sp,-48
    80002722:	f406                	sd	ra,40(sp)
    80002724:	f022                	sd	s0,32(sp)
    80002726:	ec26                	sd	s1,24(sp)
    80002728:	e84a                	sd	s2,16(sp)
    8000272a:	e44e                	sd	s3,8(sp)
    8000272c:	e052                	sd	s4,0(sp)
    8000272e:	1800                	addi	s0,sp,48
    80002730:	84aa                	mv	s1,a0
    80002732:	892e                	mv	s2,a1
    80002734:	8a32                	mv	s4,a2
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP)
    80002736:	37dd                	addiw	a5,a5,-9
    80002738:	9bdd                	andi	a5,a5,-9
    8000273a:	2781                	sext.w	a5,a5
    8000273c:	cba5                	beqz	a5,800027ac <sigaction+0x96>
    return -1;
  if(act == 0||is_valid_sigmask(act->sigmask) == 0)
    8000273e:	c9ad                	beqz	a1,800027b0 <sigaction+0x9a>
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002740:	4598                	lw	a4,8(a1)
  if(act == 0||is_valid_sigmask(act->sigmask) == 0)
    80002742:	000207b7          	lui	a5,0x20
    80002746:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    8000274a:	8ff9                	and	a5,a5,a4
    8000274c:	e7a5                	bnez	a5,800027b4 <sigaction+0x9e>
    return -1;
  struct proc *p = myproc();
    8000274e:	fffff097          	auipc	ra,0xfffff
    80002752:	24a080e7          	jalr	586(ra) # 80001998 <myproc>
    80002756:	89aa                	mv	s3,a0
  acquire(&p->lock);
    80002758:	ffffe097          	auipc	ra,0xffffe
    8000275c:	46e080e7          	jalr	1134(ra) # 80000bc6 <acquire>
  if(oldact!=0){
    80002760:	000a0d63          	beqz	s4,8000277a <sigaction+0x64>
    oldact->sa_handler = p->signal_handlers[signum].sa_handler;
    80002764:	00449793          	slli	a5,s1,0x4
    80002768:	97ce                	add	a5,a5,s3
    8000276a:	1707b703          	ld	a4,368(a5)
    8000276e:	00ea3023          	sd	a4,0(s4)
    oldact->sigmask = p->signal_handlers[signum].sigmask;
    80002772:	1787a783          	lw	a5,376(a5)
    80002776:	00fa2423          	sw	a5,8(s4)
  }
  p->signal_handlers[signum] = *act;
    8000277a:	04dd                	addi	s1,s1,23
    8000277c:	0492                	slli	s1,s1,0x4
    8000277e:	94ce                	add	s1,s1,s3
    80002780:	00093783          	ld	a5,0(s2)
    80002784:	e09c                	sd	a5,0(s1)
    80002786:	00893783          	ld	a5,8(s2)
    8000278a:	e49c                	sd	a5,8(s1)
  release(&p->lock);
    8000278c:	854e                	mv	a0,s3
    8000278e:	ffffe097          	auipc	ra,0xffffe
    80002792:	502080e7          	jalr	1282(ra) # 80000c90 <release>
  
  return 0;
    80002796:	4501                	li	a0,0
}
    80002798:	70a2                	ld	ra,40(sp)
    8000279a:	7402                	ld	s0,32(sp)
    8000279c:	64e2                	ld	s1,24(sp)
    8000279e:	6942                	ld	s2,16(sp)
    800027a0:	69a2                	ld	s3,8(sp)
    800027a2:	6a02                	ld	s4,0(sp)
    800027a4:	6145                	addi	sp,sp,48
    800027a6:	8082                	ret
    return -1;
    800027a8:	557d                	li	a0,-1
}
    800027aa:	8082                	ret
    return -1;
    800027ac:	557d                	li	a0,-1
    800027ae:	b7ed                	j	80002798 <sigaction+0x82>
    return -1;
    800027b0:	557d                	li	a0,-1
    800027b2:	b7dd                	j	80002798 <sigaction+0x82>
    800027b4:	557d                	li	a0,-1
    800027b6:	b7cd                	j	80002798 <sigaction+0x82>

00000000800027b8 <sigret>:

void 
sigret(void){
    800027b8:	1141                	addi	sp,sp,-16
    800027ba:	e406                	sd	ra,8(sp)
    800027bc:	e022                	sd	s0,0(sp)
    800027be:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800027c0:	fffff097          	auipc	ra,0xfffff
    800027c4:	1d8080e7          	jalr	472(ra) # 80001998 <myproc>
  if(p!=0&&p->user_trapframe_backup){
    800027c8:	cd09                	beqz	a0,800027e2 <sigret+0x2a>
    800027ca:	37053783          	ld	a5,880(a0)
    800027ce:	cb91                	beqz	a5,800027e2 <sigret+0x2a>
      memmove(p->trapframe, &(p->user_trapframe_backup),sizeof(struct trapframe));  
    800027d0:	12000613          	li	a2,288
    800027d4:	37050593          	addi	a1,a0,880
    800027d8:	6d28                	ld	a0,88(a0)
    800027da:	ffffe097          	auipc	ra,0xffffe
    800027de:	55a080e7          	jalr	1370(ra) # 80000d34 <memmove>
  }
  printf("we shell never be here\n");
    800027e2:	00006517          	auipc	a0,0x6
    800027e6:	ace50513          	addi	a0,a0,-1330 # 800082b0 <digits+0x270>
    800027ea:	ffffe097          	auipc	ra,0xffffe
    800027ee:	d8e080e7          	jalr	-626(ra) # 80000578 <printf>
}
    800027f2:	60a2                	ld	ra,8(sp)
    800027f4:	6402                	ld	s0,0(sp)
    800027f6:	0141                	addi	sp,sp,16
    800027f8:	8082                	ret

00000000800027fa <swtch>:
    800027fa:	00153023          	sd	ra,0(a0)
    800027fe:	00253423          	sd	sp,8(a0)
    80002802:	e900                	sd	s0,16(a0)
    80002804:	ed04                	sd	s1,24(a0)
    80002806:	03253023          	sd	s2,32(a0)
    8000280a:	03353423          	sd	s3,40(a0)
    8000280e:	03453823          	sd	s4,48(a0)
    80002812:	03553c23          	sd	s5,56(a0)
    80002816:	05653023          	sd	s6,64(a0)
    8000281a:	05753423          	sd	s7,72(a0)
    8000281e:	05853823          	sd	s8,80(a0)
    80002822:	05953c23          	sd	s9,88(a0)
    80002826:	07a53023          	sd	s10,96(a0)
    8000282a:	07b53423          	sd	s11,104(a0)
    8000282e:	0005b083          	ld	ra,0(a1)
    80002832:	0085b103          	ld	sp,8(a1)
    80002836:	6980                	ld	s0,16(a1)
    80002838:	6d84                	ld	s1,24(a1)
    8000283a:	0205b903          	ld	s2,32(a1)
    8000283e:	0285b983          	ld	s3,40(a1)
    80002842:	0305ba03          	ld	s4,48(a1)
    80002846:	0385ba83          	ld	s5,56(a1)
    8000284a:	0405bb03          	ld	s6,64(a1)
    8000284e:	0485bb83          	ld	s7,72(a1)
    80002852:	0505bc03          	ld	s8,80(a1)
    80002856:	0585bc83          	ld	s9,88(a1)
    8000285a:	0605bd03          	ld	s10,96(a1)
    8000285e:	0685bd83          	ld	s11,104(a1)
    80002862:	8082                	ret

0000000080002864 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002864:	1141                	addi	sp,sp,-16
    80002866:	e406                	sd	ra,8(sp)
    80002868:	e022                	sd	s0,0(sp)
    8000286a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000286c:	00006597          	auipc	a1,0x6
    80002870:	ab458593          	addi	a1,a1,-1356 # 80008320 <states.0+0x30>
    80002874:	0001d517          	auipc	a0,0x1d
    80002878:	e5c50513          	addi	a0,a0,-420 # 8001f6d0 <tickslock>
    8000287c:	ffffe097          	auipc	ra,0xffffe
    80002880:	2ba080e7          	jalr	698(ra) # 80000b36 <initlock>
}
    80002884:	60a2                	ld	ra,8(sp)
    80002886:	6402                	ld	s0,0(sp)
    80002888:	0141                	addi	sp,sp,16
    8000288a:	8082                	ret

000000008000288c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000288c:	1141                	addi	sp,sp,-16
    8000288e:	e422                	sd	s0,8(sp)
    80002890:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002892:	00003797          	auipc	a5,0x3
    80002896:	71e78793          	addi	a5,a5,1822 # 80005fb0 <kernelvec>
    8000289a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000289e:	6422                	ld	s0,8(sp)
    800028a0:	0141                	addi	sp,sp,16
    800028a2:	8082                	ret

00000000800028a4 <backup_trapframe>:
//     p->handlingSignal=1;
//     return;                                                 
// }

void
backup_trapframe(struct trapframe *trap_frame_backup, struct trapframe *user_trap_frame){
    800028a4:	1141                	addi	sp,sp,-16
    800028a6:	e406                	sd	ra,8(sp)
    800028a8:	e022                	sd	s0,0(sp)
    800028aa:	0800                	addi	s0,sp,16
  memmove(trap_frame_backup, user_trap_frame, sizeof(struct trapframe));
    800028ac:	12000613          	li	a2,288
    800028b0:	ffffe097          	auipc	ra,0xffffe
    800028b4:	484080e7          	jalr	1156(ra) # 80000d34 <memmove>
}
    800028b8:	60a2                	ld	ra,8(sp)
    800028ba:	6402                	ld	s0,0(sp)
    800028bc:	0141                	addi	sp,sp,16
    800028be:	8082                	ret

00000000800028c0 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800028c0:	1141                	addi	sp,sp,-16
    800028c2:	e406                	sd	ra,8(sp)
    800028c4:	e022                	sd	s0,0(sp)
    800028c6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028c8:	fffff097          	auipc	ra,0xfffff
    800028cc:	0d0080e7          	jalr	208(ra) # 80001998 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028d0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028d4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028d6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800028da:	00004617          	auipc	a2,0x4
    800028de:	72660613          	addi	a2,a2,1830 # 80007000 <_trampoline>
    800028e2:	00004697          	auipc	a3,0x4
    800028e6:	71e68693          	addi	a3,a3,1822 # 80007000 <_trampoline>
    800028ea:	8e91                	sub	a3,a3,a2
    800028ec:	040007b7          	lui	a5,0x4000
    800028f0:	17fd                	addi	a5,a5,-1
    800028f2:	07b2                	slli	a5,a5,0xc
    800028f4:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028f6:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800028fa:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800028fc:	180026f3          	csrr	a3,satp
    80002900:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002902:	6d38                	ld	a4,88(a0)
    80002904:	6134                	ld	a3,64(a0)
    80002906:	6585                	lui	a1,0x1
    80002908:	96ae                	add	a3,a3,a1
    8000290a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000290c:	6d38                	ld	a4,88(a0)
    8000290e:	00000697          	auipc	a3,0x0
    80002912:	2a868693          	addi	a3,a3,680 # 80002bb6 <usertrap>
    80002916:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002918:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000291a:	8692                	mv	a3,tp
    8000291c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000291e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002922:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002926:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000292a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000292e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002930:	6f18                	ld	a4,24(a4)
    80002932:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002936:	692c                	ld	a1,80(a0)
    80002938:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000293a:	00004717          	auipc	a4,0x4
    8000293e:	75670713          	addi	a4,a4,1878 # 80007090 <userret>
    80002942:	8f11                	sub	a4,a4,a2
    80002944:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002946:	577d                	li	a4,-1
    80002948:	177e                	slli	a4,a4,0x3f
    8000294a:	8dd9                	or	a1,a1,a4
    8000294c:	02000537          	lui	a0,0x2000
    80002950:	157d                	addi	a0,a0,-1
    80002952:	0536                	slli	a0,a0,0xd
    80002954:	9782                	jalr	a5
}
    80002956:	60a2                	ld	ra,8(sp)
    80002958:	6402                	ld	s0,0(sp)
    8000295a:	0141                	addi	sp,sp,16
    8000295c:	8082                	ret

000000008000295e <handle_user_signal>:
handle_user_signal(struct proc* p,int signum){
    8000295e:	1141                	addi	sp,sp,-16
    80002960:	e406                	sd	ra,8(sp)
    80002962:	e022                	sd	s0,0(sp)
    80002964:	0800                	addi	s0,sp,16
  usertrapret();
    80002966:	00000097          	auipc	ra,0x0
    8000296a:	f5a080e7          	jalr	-166(ra) # 800028c0 <usertrapret>
}
    8000296e:	60a2                	ld	ra,8(sp)
    80002970:	6402                	ld	s0,0(sp)
    80002972:	0141                	addi	sp,sp,16
    80002974:	8082                	ret

0000000080002976 <check_pending_signals>:
check_pending_signals(struct proc* p){
    80002976:	7159                	addi	sp,sp,-112
    80002978:	f486                	sd	ra,104(sp)
    8000297a:	f0a2                	sd	s0,96(sp)
    8000297c:	eca6                	sd	s1,88(sp)
    8000297e:	e8ca                	sd	s2,80(sp)
    80002980:	e4ce                	sd	s3,72(sp)
    80002982:	e0d2                	sd	s4,64(sp)
    80002984:	fc56                	sd	s5,56(sp)
    80002986:	f85a                	sd	s6,48(sp)
    80002988:	f45e                	sd	s7,40(sp)
    8000298a:	f062                	sd	s8,32(sp)
    8000298c:	ec66                	sd	s9,24(sp)
    8000298e:	e86a                	sd	s10,16(sp)
    80002990:	e46e                	sd	s11,8(sp)
    80002992:	1880                	addi	s0,sp,112
    80002994:	892a                	mv	s2,a0
  for(int sig_num=0;sig_num<32;sig_num++){
    80002996:	17050a13          	addi	s4,a0,368 # 2000170 <_entry-0x7dfffe90>
    8000299a:	4481                	li	s1,0
    printf("are we locking? %d pid=%d i=%d\n",holding(&p->lock),p->pid,sig_num);
    8000299c:	00006b97          	auipc	s7,0x6
    800029a0:	98cb8b93          	addi	s7,s7,-1652 # 80008328 <states.0+0x38>
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    800029a4:	4b05                	li	s6,1
      else if(act.sa_handler != (void*)SIG_IGN){ 
    800029a6:	4c05                	li	s8,1
        switch (sig_num)
    800029a8:	4d45                	li	s10,17
              printf("trying to lock before handle stop pid=%d\n",p->pid);//TODO delete
    800029aa:	00006d97          	auipc	s11,0x6
    800029ae:	99ed8d93          	addi	s11,s11,-1634 # 80008348 <states.0+0x58>
        switch (sig_num)
    800029b2:	4ccd                	li	s9,19
    800029b4:	a059                	j	80002a3a <check_pending_signals+0xc4>
    800029b6:	05a48363          	beq	s1,s10,800029fc <check_pending_signals+0x86>
    800029ba:	0f948063          	beq	s1,s9,80002a9a <check_pending_signals+0x124>
              printf("trying to lock at handle kill\n");//TODO delete
    800029be:	00006517          	auipc	a0,0x6
    800029c2:	9d250513          	addi	a0,a0,-1582 # 80008390 <states.0+0xa0>
    800029c6:	ffffe097          	auipc	ra,0xffffe
    800029ca:	bb2080e7          	jalr	-1102(ra) # 80000578 <printf>
              acquire(&p->lock);
    800029ce:	854a                	mv	a0,s2
    800029d0:	ffffe097          	auipc	ra,0xffffe
    800029d4:	1f6080e7          	jalr	502(ra) # 80000bc6 <acquire>
              p->killed = 1;
    800029d8:	03892423          	sw	s8,40(s2)
              release(&p->lock);
    800029dc:	854a                	mv	a0,s2
    800029de:	ffffe097          	auipc	ra,0xffffe
    800029e2:	2b2080e7          	jalr	690(ra) # 80000c90 <release>
              printf("pid = %d handeled kill signal",p->pid);//TODO delete
    800029e6:	03092583          	lw	a1,48(s2)
    800029ea:	00006517          	auipc	a0,0x6
    800029ee:	9c650513          	addi	a0,a0,-1594 # 800083b0 <states.0+0xc0>
    800029f2:	ffffe097          	auipc	ra,0xffffe
    800029f6:	b86080e7          	jalr	-1146(ra) # 80000578 <printf>
    800029fa:	a025                	j	80002a22 <check_pending_signals+0xac>
              printf("trying to lock before handle stop pid=%d\n",p->pid);//TODO delete
    800029fc:	03092583          	lw	a1,48(s2)
    80002a00:	856e                	mv	a0,s11
    80002a02:	ffffe097          	auipc	ra,0xffffe
    80002a06:	b76080e7          	jalr	-1162(ra) # 80000578 <printf>
              acquire(&p->lock);
    80002a0a:	854a                	mv	a0,s2
    80002a0c:	ffffe097          	auipc	ra,0xffffe
    80002a10:	1ba080e7          	jalr	442(ra) # 80000bc6 <acquire>
              p->frozen = 1;
    80002a14:	37892c23          	sw	s8,888(s2)
              release(&p->lock);
    80002a18:	854a                	mv	a0,s2
    80002a1a:	ffffe097          	auipc	ra,0xffffe
    80002a1e:	276080e7          	jalr	630(ra) # 80000c90 <release>
      p->pending_signals^=1<<sig_num;
    80002a22:	16892783          	lw	a5,360(s2)
    80002a26:	0137c9b3          	xor	s3,a5,s3
    80002a2a:	17392423          	sw	s3,360(s2)
  for(int sig_num=0;sig_num<32;sig_num++){
    80002a2e:	2485                	addiw	s1,s1,1
    80002a30:	0a41                	addi	s4,s4,16
    80002a32:	02000793          	li	a5,32
    80002a36:	06f48d63          	beq	s1,a5,80002ab0 <check_pending_signals+0x13a>
    printf("are we locking? %d pid=%d i=%d\n",holding(&p->lock),p->pid,sig_num);
    80002a3a:	854a                	mv	a0,s2
    80002a3c:	ffffe097          	auipc	ra,0xffffe
    80002a40:	110080e7          	jalr	272(ra) # 80000b4c <holding>
    80002a44:	85aa                	mv	a1,a0
    80002a46:	86a6                	mv	a3,s1
    80002a48:	03092603          	lw	a2,48(s2)
    80002a4c:	855e                	mv	a0,s7
    80002a4e:	ffffe097          	auipc	ra,0xffffe
    80002a52:	b2a080e7          	jalr	-1238(ra) # 80000578 <printf>
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    80002a56:	009b19bb          	sllw	s3,s6,s1
    80002a5a:	16892783          	lw	a5,360(s2)
    80002a5e:	0137f7b3          	and	a5,a5,s3
    80002a62:	2781                	sext.w	a5,a5
    80002a64:	d7e9                	beqz	a5,80002a2e <check_pending_signals+0xb8>
    80002a66:	16c92a83          	lw	s5,364(s2)
    80002a6a:	013af7b3          	and	a5,s5,s3
    80002a6e:	2781                	sext.w	a5,a5
    80002a70:	ffdd                	bnez	a5,80002a2e <check_pending_signals+0xb8>
      struct sigaction act = p->signal_handlers[sig_num];
    80002a72:	000a3783          	ld	a5,0(s4)
      if(act.sa_handler == (void*)SIG_DFL){
    80002a76:	d3a1                	beqz	a5,800029b6 <check_pending_signals+0x40>
      else if(act.sa_handler != (void*)SIG_IGN){ 
    80002a78:	fb8785e3          	beq	a5,s8,80002a22 <check_pending_signals+0xac>
        backup_trapframe(p->user_trapframe_backup, p->trapframe);
    80002a7c:	05893583          	ld	a1,88(s2)
    80002a80:	37093503          	ld	a0,880(s2)
    80002a84:	00000097          	auipc	ra,0x0
    80002a88:	e20080e7          	jalr	-480(ra) # 800028a4 <backup_trapframe>
  usertrapret();
    80002a8c:	00000097          	auipc	ra,0x0
    80002a90:	e34080e7          	jalr	-460(ra) # 800028c0 <usertrapret>
        p->signal_mask = original_mask;
    80002a94:	17592623          	sw	s5,364(s2)
    80002a98:	b769                	j	80002a22 <check_pending_signals+0xac>
            printf("handle sigcont pid=%d\n",p->pid); 
    80002a9a:	03092583          	lw	a1,48(s2)
    80002a9e:	00006517          	auipc	a0,0x6
    80002aa2:	8da50513          	addi	a0,a0,-1830 # 80008378 <states.0+0x88>
    80002aa6:	ffffe097          	auipc	ra,0xffffe
    80002aaa:	ad2080e7          	jalr	-1326(ra) # 80000578 <printf>
            break;
    80002aae:	bf95                	j	80002a22 <check_pending_signals+0xac>
}
    80002ab0:	70a6                	ld	ra,104(sp)
    80002ab2:	7406                	ld	s0,96(sp)
    80002ab4:	64e6                	ld	s1,88(sp)
    80002ab6:	6946                	ld	s2,80(sp)
    80002ab8:	69a6                	ld	s3,72(sp)
    80002aba:	6a06                	ld	s4,64(sp)
    80002abc:	7ae2                	ld	s5,56(sp)
    80002abe:	7b42                	ld	s6,48(sp)
    80002ac0:	7ba2                	ld	s7,40(sp)
    80002ac2:	7c02                	ld	s8,32(sp)
    80002ac4:	6ce2                	ld	s9,24(sp)
    80002ac6:	6d42                	ld	s10,16(sp)
    80002ac8:	6da2                	ld	s11,8(sp)
    80002aca:	6165                	addi	sp,sp,112
    80002acc:	8082                	ret

0000000080002ace <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002ace:	1101                	addi	sp,sp,-32
    80002ad0:	ec06                	sd	ra,24(sp)
    80002ad2:	e822                	sd	s0,16(sp)
    80002ad4:	e426                	sd	s1,8(sp)
    80002ad6:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002ad8:	0001d497          	auipc	s1,0x1d
    80002adc:	bf848493          	addi	s1,s1,-1032 # 8001f6d0 <tickslock>
    80002ae0:	8526                	mv	a0,s1
    80002ae2:	ffffe097          	auipc	ra,0xffffe
    80002ae6:	0e4080e7          	jalr	228(ra) # 80000bc6 <acquire>
  ticks++;
    80002aea:	00006517          	auipc	a0,0x6
    80002aee:	54650513          	addi	a0,a0,1350 # 80009030 <ticks>
    80002af2:	411c                	lw	a5,0(a0)
    80002af4:	2785                	addiw	a5,a5,1
    80002af6:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002af8:	fffff097          	auipc	ra,0xfffff
    80002afc:	7a8080e7          	jalr	1960(ra) # 800022a0 <wakeup>
  release(&tickslock);
    80002b00:	8526                	mv	a0,s1
    80002b02:	ffffe097          	auipc	ra,0xffffe
    80002b06:	18e080e7          	jalr	398(ra) # 80000c90 <release>
}
    80002b0a:	60e2                	ld	ra,24(sp)
    80002b0c:	6442                	ld	s0,16(sp)
    80002b0e:	64a2                	ld	s1,8(sp)
    80002b10:	6105                	addi	sp,sp,32
    80002b12:	8082                	ret

0000000080002b14 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002b14:	1101                	addi	sp,sp,-32
    80002b16:	ec06                	sd	ra,24(sp)
    80002b18:	e822                	sd	s0,16(sp)
    80002b1a:	e426                	sd	s1,8(sp)
    80002b1c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b1e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002b22:	00074d63          	bltz	a4,80002b3c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002b26:	57fd                	li	a5,-1
    80002b28:	17fe                	slli	a5,a5,0x3f
    80002b2a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002b2c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002b2e:	06f70363          	beq	a4,a5,80002b94 <devintr+0x80>
  }
}
    80002b32:	60e2                	ld	ra,24(sp)
    80002b34:	6442                	ld	s0,16(sp)
    80002b36:	64a2                	ld	s1,8(sp)
    80002b38:	6105                	addi	sp,sp,32
    80002b3a:	8082                	ret
     (scause & 0xff) == 9){
    80002b3c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002b40:	46a5                	li	a3,9
    80002b42:	fed792e3          	bne	a5,a3,80002b26 <devintr+0x12>
    int irq = plic_claim();
    80002b46:	00003097          	auipc	ra,0x3
    80002b4a:	572080e7          	jalr	1394(ra) # 800060b8 <plic_claim>
    80002b4e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002b50:	47a9                	li	a5,10
    80002b52:	02f50763          	beq	a0,a5,80002b80 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002b56:	4785                	li	a5,1
    80002b58:	02f50963          	beq	a0,a5,80002b8a <devintr+0x76>
    return 1;
    80002b5c:	4505                	li	a0,1
    } else if(irq){
    80002b5e:	d8f1                	beqz	s1,80002b32 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b60:	85a6                	mv	a1,s1
    80002b62:	00006517          	auipc	a0,0x6
    80002b66:	86e50513          	addi	a0,a0,-1938 # 800083d0 <states.0+0xe0>
    80002b6a:	ffffe097          	auipc	ra,0xffffe
    80002b6e:	a0e080e7          	jalr	-1522(ra) # 80000578 <printf>
      plic_complete(irq);
    80002b72:	8526                	mv	a0,s1
    80002b74:	00003097          	auipc	ra,0x3
    80002b78:	568080e7          	jalr	1384(ra) # 800060dc <plic_complete>
    return 1;
    80002b7c:	4505                	li	a0,1
    80002b7e:	bf55                	j	80002b32 <devintr+0x1e>
      uartintr();
    80002b80:	ffffe097          	auipc	ra,0xffffe
    80002b84:	e0a080e7          	jalr	-502(ra) # 8000098a <uartintr>
    80002b88:	b7ed                	j	80002b72 <devintr+0x5e>
      virtio_disk_intr();
    80002b8a:	00004097          	auipc	ra,0x4
    80002b8e:	9e4080e7          	jalr	-1564(ra) # 8000656e <virtio_disk_intr>
    80002b92:	b7c5                	j	80002b72 <devintr+0x5e>
    if(cpuid() == 0){
    80002b94:	fffff097          	auipc	ra,0xfffff
    80002b98:	dd8080e7          	jalr	-552(ra) # 8000196c <cpuid>
    80002b9c:	c901                	beqz	a0,80002bac <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b9e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002ba2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ba4:	14479073          	csrw	sip,a5
    return 2;
    80002ba8:	4509                	li	a0,2
    80002baa:	b761                	j	80002b32 <devintr+0x1e>
      clockintr();
    80002bac:	00000097          	auipc	ra,0x0
    80002bb0:	f22080e7          	jalr	-222(ra) # 80002ace <clockintr>
    80002bb4:	b7ed                	j	80002b9e <devintr+0x8a>

0000000080002bb6 <usertrap>:
{
    80002bb6:	1101                	addi	sp,sp,-32
    80002bb8:	ec06                	sd	ra,24(sp)
    80002bba:	e822                	sd	s0,16(sp)
    80002bbc:	e426                	sd	s1,8(sp)
    80002bbe:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bc0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002bc4:	1007f793          	andi	a5,a5,256
    80002bc8:	ebad                	bnez	a5,80002c3a <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bca:	00003797          	auipc	a5,0x3
    80002bce:	3e678793          	addi	a5,a5,998 # 80005fb0 <kernelvec>
    80002bd2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002bd6:	fffff097          	auipc	ra,0xfffff
    80002bda:	dc2080e7          	jalr	-574(ra) # 80001998 <myproc>
    80002bde:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002be0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002be2:	14102773          	csrr	a4,sepc
    80002be6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002be8:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002bec:	47a1                	li	a5,8
    80002bee:	06f71463          	bne	a4,a5,80002c56 <usertrap+0xa0>
    if(p->killed==1)
    80002bf2:	5518                	lw	a4,40(a0)
    80002bf4:	4785                	li	a5,1
    80002bf6:	04f70a63          	beq	a4,a5,80002c4a <usertrap+0x94>
    p->trapframe->epc += 4;
    80002bfa:	6cb8                	ld	a4,88(s1)
    80002bfc:	6f1c                	ld	a5,24(a4)
    80002bfe:	0791                	addi	a5,a5,4
    80002c00:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c02:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c06:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c0a:	10079073          	csrw	sstatus,a5
    syscall();
    80002c0e:	00000097          	auipc	ra,0x0
    80002c12:	2e4080e7          	jalr	740(ra) # 80002ef2 <syscall>
  check_pending_signals(p);
    80002c16:	8526                	mv	a0,s1
    80002c18:	00000097          	auipc	ra,0x0
    80002c1c:	d5e080e7          	jalr	-674(ra) # 80002976 <check_pending_signals>
  if(p->killed==1)
    80002c20:	5498                	lw	a4,40(s1)
    80002c22:	4785                	li	a5,1
    80002c24:	08f70063          	beq	a4,a5,80002ca4 <usertrap+0xee>
  usertrapret();
    80002c28:	00000097          	auipc	ra,0x0
    80002c2c:	c98080e7          	jalr	-872(ra) # 800028c0 <usertrapret>
}
    80002c30:	60e2                	ld	ra,24(sp)
    80002c32:	6442                	ld	s0,16(sp)
    80002c34:	64a2                	ld	s1,8(sp)
    80002c36:	6105                	addi	sp,sp,32
    80002c38:	8082                	ret
    panic("usertrap: not from user mode");
    80002c3a:	00005517          	auipc	a0,0x5
    80002c3e:	7b650513          	addi	a0,a0,1974 # 800083f0 <states.0+0x100>
    80002c42:	ffffe097          	auipc	ra,0xffffe
    80002c46:	8ec080e7          	jalr	-1812(ra) # 8000052e <panic>
      exit(-1);
    80002c4a:	557d                	li	a0,-1
    80002c4c:	fffff097          	auipc	ra,0xfffff
    80002c50:	724080e7          	jalr	1828(ra) # 80002370 <exit>
    80002c54:	b75d                	j	80002bfa <usertrap+0x44>
  else if((which_dev = devintr()) != 0){
    80002c56:	00000097          	auipc	ra,0x0
    80002c5a:	ebe080e7          	jalr	-322(ra) # 80002b14 <devintr>
    80002c5e:	c909                	beqz	a0,80002c70 <usertrap+0xba>
  if(which_dev == 2)
    80002c60:	4789                	li	a5,2
    80002c62:	faf51ae3          	bne	a0,a5,80002c16 <usertrap+0x60>
    yield();
    80002c66:	fffff097          	auipc	ra,0xfffff
    80002c6a:	470080e7          	jalr	1136(ra) # 800020d6 <yield>
    80002c6e:	b765                	j	80002c16 <usertrap+0x60>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c70:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c74:	5890                	lw	a2,48(s1)
    80002c76:	00005517          	auipc	a0,0x5
    80002c7a:	79a50513          	addi	a0,a0,1946 # 80008410 <states.0+0x120>
    80002c7e:	ffffe097          	auipc	ra,0xffffe
    80002c82:	8fa080e7          	jalr	-1798(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c86:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c8a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c8e:	00005517          	auipc	a0,0x5
    80002c92:	7b250513          	addi	a0,a0,1970 # 80008440 <states.0+0x150>
    80002c96:	ffffe097          	auipc	ra,0xffffe
    80002c9a:	8e2080e7          	jalr	-1822(ra) # 80000578 <printf>
    p->killed = 1;
    80002c9e:	4785                	li	a5,1
    80002ca0:	d49c                	sw	a5,40(s1)
  if(which_dev == 2)
    80002ca2:	bf95                	j	80002c16 <usertrap+0x60>
    exit(-1);
    80002ca4:	557d                	li	a0,-1
    80002ca6:	fffff097          	auipc	ra,0xfffff
    80002caa:	6ca080e7          	jalr	1738(ra) # 80002370 <exit>
    80002cae:	bfad                	j	80002c28 <usertrap+0x72>

0000000080002cb0 <kerneltrap>:
{
    80002cb0:	7179                	addi	sp,sp,-48
    80002cb2:	f406                	sd	ra,40(sp)
    80002cb4:	f022                	sd	s0,32(sp)
    80002cb6:	ec26                	sd	s1,24(sp)
    80002cb8:	e84a                	sd	s2,16(sp)
    80002cba:	e44e                	sd	s3,8(sp)
    80002cbc:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cbe:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cc2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cc6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002cca:	1004f793          	andi	a5,s1,256
    80002cce:	cb85                	beqz	a5,80002cfe <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cd0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002cd4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002cd6:	ef85                	bnez	a5,80002d0e <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002cd8:	00000097          	auipc	ra,0x0
    80002cdc:	e3c080e7          	jalr	-452(ra) # 80002b14 <devintr>
    80002ce0:	cd1d                	beqz	a0,80002d1e <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ce2:	4789                	li	a5,2
    80002ce4:	06f50a63          	beq	a0,a5,80002d58 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ce8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cec:	10049073          	csrw	sstatus,s1
}
    80002cf0:	70a2                	ld	ra,40(sp)
    80002cf2:	7402                	ld	s0,32(sp)
    80002cf4:	64e2                	ld	s1,24(sp)
    80002cf6:	6942                	ld	s2,16(sp)
    80002cf8:	69a2                	ld	s3,8(sp)
    80002cfa:	6145                	addi	sp,sp,48
    80002cfc:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002cfe:	00005517          	auipc	a0,0x5
    80002d02:	76250513          	addi	a0,a0,1890 # 80008460 <states.0+0x170>
    80002d06:	ffffe097          	auipc	ra,0xffffe
    80002d0a:	828080e7          	jalr	-2008(ra) # 8000052e <panic>
    panic("kerneltrap: interrupts enabled");
    80002d0e:	00005517          	auipc	a0,0x5
    80002d12:	77a50513          	addi	a0,a0,1914 # 80008488 <states.0+0x198>
    80002d16:	ffffe097          	auipc	ra,0xffffe
    80002d1a:	818080e7          	jalr	-2024(ra) # 8000052e <panic>
    printf("scause %p\n", scause);
    80002d1e:	85ce                	mv	a1,s3
    80002d20:	00005517          	auipc	a0,0x5
    80002d24:	78850513          	addi	a0,a0,1928 # 800084a8 <states.0+0x1b8>
    80002d28:	ffffe097          	auipc	ra,0xffffe
    80002d2c:	850080e7          	jalr	-1968(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d30:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d34:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d38:	00005517          	auipc	a0,0x5
    80002d3c:	78050513          	addi	a0,a0,1920 # 800084b8 <states.0+0x1c8>
    80002d40:	ffffe097          	auipc	ra,0xffffe
    80002d44:	838080e7          	jalr	-1992(ra) # 80000578 <printf>
    panic("kerneltrap");
    80002d48:	00005517          	auipc	a0,0x5
    80002d4c:	78850513          	addi	a0,a0,1928 # 800084d0 <states.0+0x1e0>
    80002d50:	ffffd097          	auipc	ra,0xffffd
    80002d54:	7de080e7          	jalr	2014(ra) # 8000052e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d58:	fffff097          	auipc	ra,0xfffff
    80002d5c:	c40080e7          	jalr	-960(ra) # 80001998 <myproc>
    80002d60:	d541                	beqz	a0,80002ce8 <kerneltrap+0x38>
    80002d62:	fffff097          	auipc	ra,0xfffff
    80002d66:	c36080e7          	jalr	-970(ra) # 80001998 <myproc>
    80002d6a:	4d18                	lw	a4,24(a0)
    80002d6c:	4791                	li	a5,4
    80002d6e:	f6f71de3          	bne	a4,a5,80002ce8 <kerneltrap+0x38>
    yield();
    80002d72:	fffff097          	auipc	ra,0xfffff
    80002d76:	364080e7          	jalr	868(ra) # 800020d6 <yield>
    80002d7a:	b7bd                	j	80002ce8 <kerneltrap+0x38>

0000000080002d7c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d7c:	1101                	addi	sp,sp,-32
    80002d7e:	ec06                	sd	ra,24(sp)
    80002d80:	e822                	sd	s0,16(sp)
    80002d82:	e426                	sd	s1,8(sp)
    80002d84:	1000                	addi	s0,sp,32
    80002d86:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d88:	fffff097          	auipc	ra,0xfffff
    80002d8c:	c10080e7          	jalr	-1008(ra) # 80001998 <myproc>
  switch (n) {
    80002d90:	4795                	li	a5,5
    80002d92:	0497e163          	bltu	a5,s1,80002dd4 <argraw+0x58>
    80002d96:	048a                	slli	s1,s1,0x2
    80002d98:	00005717          	auipc	a4,0x5
    80002d9c:	77070713          	addi	a4,a4,1904 # 80008508 <states.0+0x218>
    80002da0:	94ba                	add	s1,s1,a4
    80002da2:	409c                	lw	a5,0(s1)
    80002da4:	97ba                	add	a5,a5,a4
    80002da6:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002da8:	6d3c                	ld	a5,88(a0)
    80002daa:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002dac:	60e2                	ld	ra,24(sp)
    80002dae:	6442                	ld	s0,16(sp)
    80002db0:	64a2                	ld	s1,8(sp)
    80002db2:	6105                	addi	sp,sp,32
    80002db4:	8082                	ret
    return p->trapframe->a1;
    80002db6:	6d3c                	ld	a5,88(a0)
    80002db8:	7fa8                	ld	a0,120(a5)
    80002dba:	bfcd                	j	80002dac <argraw+0x30>
    return p->trapframe->a2;
    80002dbc:	6d3c                	ld	a5,88(a0)
    80002dbe:	63c8                	ld	a0,128(a5)
    80002dc0:	b7f5                	j	80002dac <argraw+0x30>
    return p->trapframe->a3;
    80002dc2:	6d3c                	ld	a5,88(a0)
    80002dc4:	67c8                	ld	a0,136(a5)
    80002dc6:	b7dd                	j	80002dac <argraw+0x30>
    return p->trapframe->a4;
    80002dc8:	6d3c                	ld	a5,88(a0)
    80002dca:	6bc8                	ld	a0,144(a5)
    80002dcc:	b7c5                	j	80002dac <argraw+0x30>
    return p->trapframe->a5;
    80002dce:	6d3c                	ld	a5,88(a0)
    80002dd0:	6fc8                	ld	a0,152(a5)
    80002dd2:	bfe9                	j	80002dac <argraw+0x30>
  panic("argraw");
    80002dd4:	00005517          	auipc	a0,0x5
    80002dd8:	70c50513          	addi	a0,a0,1804 # 800084e0 <states.0+0x1f0>
    80002ddc:	ffffd097          	auipc	ra,0xffffd
    80002de0:	752080e7          	jalr	1874(ra) # 8000052e <panic>

0000000080002de4 <fetchaddr>:
{
    80002de4:	1101                	addi	sp,sp,-32
    80002de6:	ec06                	sd	ra,24(sp)
    80002de8:	e822                	sd	s0,16(sp)
    80002dea:	e426                	sd	s1,8(sp)
    80002dec:	e04a                	sd	s2,0(sp)
    80002dee:	1000                	addi	s0,sp,32
    80002df0:	84aa                	mv	s1,a0
    80002df2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002df4:	fffff097          	auipc	ra,0xfffff
    80002df8:	ba4080e7          	jalr	-1116(ra) # 80001998 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002dfc:	653c                	ld	a5,72(a0)
    80002dfe:	02f4f863          	bgeu	s1,a5,80002e2e <fetchaddr+0x4a>
    80002e02:	00848713          	addi	a4,s1,8
    80002e06:	02e7e663          	bltu	a5,a4,80002e32 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e0a:	46a1                	li	a3,8
    80002e0c:	8626                	mv	a2,s1
    80002e0e:	85ca                	mv	a1,s2
    80002e10:	6928                	ld	a0,80(a0)
    80002e12:	fffff097          	auipc	ra,0xfffff
    80002e16:	8d2080e7          	jalr	-1838(ra) # 800016e4 <copyin>
    80002e1a:	00a03533          	snez	a0,a0
    80002e1e:	40a00533          	neg	a0,a0
}
    80002e22:	60e2                	ld	ra,24(sp)
    80002e24:	6442                	ld	s0,16(sp)
    80002e26:	64a2                	ld	s1,8(sp)
    80002e28:	6902                	ld	s2,0(sp)
    80002e2a:	6105                	addi	sp,sp,32
    80002e2c:	8082                	ret
    return -1;
    80002e2e:	557d                	li	a0,-1
    80002e30:	bfcd                	j	80002e22 <fetchaddr+0x3e>
    80002e32:	557d                	li	a0,-1
    80002e34:	b7fd                	j	80002e22 <fetchaddr+0x3e>

0000000080002e36 <fetchstr>:
{
    80002e36:	7179                	addi	sp,sp,-48
    80002e38:	f406                	sd	ra,40(sp)
    80002e3a:	f022                	sd	s0,32(sp)
    80002e3c:	ec26                	sd	s1,24(sp)
    80002e3e:	e84a                	sd	s2,16(sp)
    80002e40:	e44e                	sd	s3,8(sp)
    80002e42:	1800                	addi	s0,sp,48
    80002e44:	892a                	mv	s2,a0
    80002e46:	84ae                	mv	s1,a1
    80002e48:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e4a:	fffff097          	auipc	ra,0xfffff
    80002e4e:	b4e080e7          	jalr	-1202(ra) # 80001998 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002e52:	86ce                	mv	a3,s3
    80002e54:	864a                	mv	a2,s2
    80002e56:	85a6                	mv	a1,s1
    80002e58:	6928                	ld	a0,80(a0)
    80002e5a:	fffff097          	auipc	ra,0xfffff
    80002e5e:	918080e7          	jalr	-1768(ra) # 80001772 <copyinstr>
  if(err < 0)
    80002e62:	00054763          	bltz	a0,80002e70 <fetchstr+0x3a>
  return strlen(buf);
    80002e66:	8526                	mv	a0,s1
    80002e68:	ffffe097          	auipc	ra,0xffffe
    80002e6c:	ff4080e7          	jalr	-12(ra) # 80000e5c <strlen>
}
    80002e70:	70a2                	ld	ra,40(sp)
    80002e72:	7402                	ld	s0,32(sp)
    80002e74:	64e2                	ld	s1,24(sp)
    80002e76:	6942                	ld	s2,16(sp)
    80002e78:	69a2                	ld	s3,8(sp)
    80002e7a:	6145                	addi	sp,sp,48
    80002e7c:	8082                	ret

0000000080002e7e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002e7e:	1101                	addi	sp,sp,-32
    80002e80:	ec06                	sd	ra,24(sp)
    80002e82:	e822                	sd	s0,16(sp)
    80002e84:	e426                	sd	s1,8(sp)
    80002e86:	1000                	addi	s0,sp,32
    80002e88:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e8a:	00000097          	auipc	ra,0x0
    80002e8e:	ef2080e7          	jalr	-270(ra) # 80002d7c <argraw>
    80002e92:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e94:	4501                	li	a0,0
    80002e96:	60e2                	ld	ra,24(sp)
    80002e98:	6442                	ld	s0,16(sp)
    80002e9a:	64a2                	ld	s1,8(sp)
    80002e9c:	6105                	addi	sp,sp,32
    80002e9e:	8082                	ret

0000000080002ea0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002ea0:	1101                	addi	sp,sp,-32
    80002ea2:	ec06                	sd	ra,24(sp)
    80002ea4:	e822                	sd	s0,16(sp)
    80002ea6:	e426                	sd	s1,8(sp)
    80002ea8:	1000                	addi	s0,sp,32
    80002eaa:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002eac:	00000097          	auipc	ra,0x0
    80002eb0:	ed0080e7          	jalr	-304(ra) # 80002d7c <argraw>
    80002eb4:	e088                	sd	a0,0(s1)
  return 0;
}
    80002eb6:	4501                	li	a0,0
    80002eb8:	60e2                	ld	ra,24(sp)
    80002eba:	6442                	ld	s0,16(sp)
    80002ebc:	64a2                	ld	s1,8(sp)
    80002ebe:	6105                	addi	sp,sp,32
    80002ec0:	8082                	ret

0000000080002ec2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ec2:	1101                	addi	sp,sp,-32
    80002ec4:	ec06                	sd	ra,24(sp)
    80002ec6:	e822                	sd	s0,16(sp)
    80002ec8:	e426                	sd	s1,8(sp)
    80002eca:	e04a                	sd	s2,0(sp)
    80002ecc:	1000                	addi	s0,sp,32
    80002ece:	84ae                	mv	s1,a1
    80002ed0:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002ed2:	00000097          	auipc	ra,0x0
    80002ed6:	eaa080e7          	jalr	-342(ra) # 80002d7c <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002eda:	864a                	mv	a2,s2
    80002edc:	85a6                	mv	a1,s1
    80002ede:	00000097          	auipc	ra,0x0
    80002ee2:	f58080e7          	jalr	-168(ra) # 80002e36 <fetchstr>
}
    80002ee6:	60e2                	ld	ra,24(sp)
    80002ee8:	6442                	ld	s0,16(sp)
    80002eea:	64a2                	ld	s1,8(sp)
    80002eec:	6902                	ld	s2,0(sp)
    80002eee:	6105                	addi	sp,sp,32
    80002ef0:	8082                	ret

0000000080002ef2 <syscall>:
[SYS_sigret] sys_sigret,
};

void
syscall(void)
{
    80002ef2:	1101                	addi	sp,sp,-32
    80002ef4:	ec06                	sd	ra,24(sp)
    80002ef6:	e822                	sd	s0,16(sp)
    80002ef8:	e426                	sd	s1,8(sp)
    80002efa:	e04a                	sd	s2,0(sp)
    80002efc:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002efe:	fffff097          	auipc	ra,0xfffff
    80002f02:	a9a080e7          	jalr	-1382(ra) # 80001998 <myproc>
    80002f06:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002f08:	05853903          	ld	s2,88(a0)
    80002f0c:	0a893783          	ld	a5,168(s2)
    80002f10:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f14:	37fd                	addiw	a5,a5,-1
    80002f16:	475d                	li	a4,23
    80002f18:	00f76f63          	bltu	a4,a5,80002f36 <syscall+0x44>
    80002f1c:	00369713          	slli	a4,a3,0x3
    80002f20:	00005797          	auipc	a5,0x5
    80002f24:	60078793          	addi	a5,a5,1536 # 80008520 <syscalls>
    80002f28:	97ba                	add	a5,a5,a4
    80002f2a:	639c                	ld	a5,0(a5)
    80002f2c:	c789                	beqz	a5,80002f36 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002f2e:	9782                	jalr	a5
    80002f30:	06a93823          	sd	a0,112(s2)
    80002f34:	a839                	j	80002f52 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f36:	15848613          	addi	a2,s1,344
    80002f3a:	588c                	lw	a1,48(s1)
    80002f3c:	00005517          	auipc	a0,0x5
    80002f40:	5ac50513          	addi	a0,a0,1452 # 800084e8 <states.0+0x1f8>
    80002f44:	ffffd097          	auipc	ra,0xffffd
    80002f48:	634080e7          	jalr	1588(ra) # 80000578 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f4c:	6cbc                	ld	a5,88(s1)
    80002f4e:	577d                	li	a4,-1
    80002f50:	fbb8                	sd	a4,112(a5)
  }
}
    80002f52:	60e2                	ld	ra,24(sp)
    80002f54:	6442                	ld	s0,16(sp)
    80002f56:	64a2                	ld	s1,8(sp)
    80002f58:	6902                	ld	s2,0(sp)
    80002f5a:	6105                	addi	sp,sp,32
    80002f5c:	8082                	ret

0000000080002f5e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f5e:	1101                	addi	sp,sp,-32
    80002f60:	ec06                	sd	ra,24(sp)
    80002f62:	e822                	sd	s0,16(sp)
    80002f64:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002f66:	fec40593          	addi	a1,s0,-20
    80002f6a:	4501                	li	a0,0
    80002f6c:	00000097          	auipc	ra,0x0
    80002f70:	f12080e7          	jalr	-238(ra) # 80002e7e <argint>
    return -1;
    80002f74:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f76:	00054963          	bltz	a0,80002f88 <sys_exit+0x2a>
  exit(n);
    80002f7a:	fec42503          	lw	a0,-20(s0)
    80002f7e:	fffff097          	auipc	ra,0xfffff
    80002f82:	3f2080e7          	jalr	1010(ra) # 80002370 <exit>
  return 0;  // not reached
    80002f86:	4781                	li	a5,0
}
    80002f88:	853e                	mv	a0,a5
    80002f8a:	60e2                	ld	ra,24(sp)
    80002f8c:	6442                	ld	s0,16(sp)
    80002f8e:	6105                	addi	sp,sp,32
    80002f90:	8082                	ret

0000000080002f92 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f92:	1141                	addi	sp,sp,-16
    80002f94:	e406                	sd	ra,8(sp)
    80002f96:	e022                	sd	s0,0(sp)
    80002f98:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f9a:	fffff097          	auipc	ra,0xfffff
    80002f9e:	9fe080e7          	jalr	-1538(ra) # 80001998 <myproc>
}
    80002fa2:	5908                	lw	a0,48(a0)
    80002fa4:	60a2                	ld	ra,8(sp)
    80002fa6:	6402                	ld	s0,0(sp)
    80002fa8:	0141                	addi	sp,sp,16
    80002faa:	8082                	ret

0000000080002fac <sys_fork>:

uint64
sys_fork(void)
{
    80002fac:	1141                	addi	sp,sp,-16
    80002fae:	e406                	sd	ra,8(sp)
    80002fb0:	e022                	sd	s0,0(sp)
    80002fb2:	0800                	addi	s0,sp,16
  return fork();
    80002fb4:	fffff097          	auipc	ra,0xfffff
    80002fb8:	e0e080e7          	jalr	-498(ra) # 80001dc2 <fork>
}
    80002fbc:	60a2                	ld	ra,8(sp)
    80002fbe:	6402                	ld	s0,0(sp)
    80002fc0:	0141                	addi	sp,sp,16
    80002fc2:	8082                	ret

0000000080002fc4 <sys_wait>:

uint64
sys_wait(void)
{
    80002fc4:	1101                	addi	sp,sp,-32
    80002fc6:	ec06                	sd	ra,24(sp)
    80002fc8:	e822                	sd	s0,16(sp)
    80002fca:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002fcc:	fe840593          	addi	a1,s0,-24
    80002fd0:	4501                	li	a0,0
    80002fd2:	00000097          	auipc	ra,0x0
    80002fd6:	ece080e7          	jalr	-306(ra) # 80002ea0 <argaddr>
    80002fda:	87aa                	mv	a5,a0
    return -1;
    80002fdc:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002fde:	0007c863          	bltz	a5,80002fee <sys_wait+0x2a>
  return wait(p);
    80002fe2:	fe843503          	ld	a0,-24(s0)
    80002fe6:	fffff097          	auipc	ra,0xfffff
    80002fea:	190080e7          	jalr	400(ra) # 80002176 <wait>
}
    80002fee:	60e2                	ld	ra,24(sp)
    80002ff0:	6442                	ld	s0,16(sp)
    80002ff2:	6105                	addi	sp,sp,32
    80002ff4:	8082                	ret

0000000080002ff6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ff6:	7179                	addi	sp,sp,-48
    80002ff8:	f406                	sd	ra,40(sp)
    80002ffa:	f022                	sd	s0,32(sp)
    80002ffc:	ec26                	sd	s1,24(sp)
    80002ffe:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003000:	fdc40593          	addi	a1,s0,-36
    80003004:	4501                	li	a0,0
    80003006:	00000097          	auipc	ra,0x0
    8000300a:	e78080e7          	jalr	-392(ra) # 80002e7e <argint>
    return -1;
    8000300e:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003010:	00054f63          	bltz	a0,8000302e <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003014:	fffff097          	auipc	ra,0xfffff
    80003018:	984080e7          	jalr	-1660(ra) # 80001998 <myproc>
    8000301c:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    8000301e:	fdc42503          	lw	a0,-36(s0)
    80003022:	fffff097          	auipc	ra,0xfffff
    80003026:	d2c080e7          	jalr	-724(ra) # 80001d4e <growproc>
    8000302a:	00054863          	bltz	a0,8000303a <sys_sbrk+0x44>
    return -1;
  return addr;
}
    8000302e:	8526                	mv	a0,s1
    80003030:	70a2                	ld	ra,40(sp)
    80003032:	7402                	ld	s0,32(sp)
    80003034:	64e2                	ld	s1,24(sp)
    80003036:	6145                	addi	sp,sp,48
    80003038:	8082                	ret
    return -1;
    8000303a:	54fd                	li	s1,-1
    8000303c:	bfcd                	j	8000302e <sys_sbrk+0x38>

000000008000303e <sys_sleep>:

uint64
sys_sleep(void)
{
    8000303e:	7139                	addi	sp,sp,-64
    80003040:	fc06                	sd	ra,56(sp)
    80003042:	f822                	sd	s0,48(sp)
    80003044:	f426                	sd	s1,40(sp)
    80003046:	f04a                	sd	s2,32(sp)
    80003048:	ec4e                	sd	s3,24(sp)
    8000304a:	e852                	sd	s4,16(sp)
    8000304c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    8000304e:	fcc40593          	addi	a1,s0,-52
    80003052:	4501                	li	a0,0
    80003054:	00000097          	auipc	ra,0x0
    80003058:	e2a080e7          	jalr	-470(ra) # 80002e7e <argint>
    return -1;
    8000305c:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000305e:	06054763          	bltz	a0,800030cc <sys_sleep+0x8e>
  acquire(&tickslock);
    80003062:	0001c517          	auipc	a0,0x1c
    80003066:	66e50513          	addi	a0,a0,1646 # 8001f6d0 <tickslock>
    8000306a:	ffffe097          	auipc	ra,0xffffe
    8000306e:	b5c080e7          	jalr	-1188(ra) # 80000bc6 <acquire>
  ticks0 = ticks;
    80003072:	00006997          	auipc	s3,0x6
    80003076:	fbe9a983          	lw	s3,-66(s3) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    8000307a:	fcc42783          	lw	a5,-52(s0)
    8000307e:	cf95                	beqz	a5,800030ba <sys_sleep+0x7c>
    if(myproc()->killed==1){
    80003080:	4905                	li	s2,1
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003082:	0001ca17          	auipc	s4,0x1c
    80003086:	64ea0a13          	addi	s4,s4,1614 # 8001f6d0 <tickslock>
    8000308a:	00006497          	auipc	s1,0x6
    8000308e:	fa648493          	addi	s1,s1,-90 # 80009030 <ticks>
    if(myproc()->killed==1){
    80003092:	fffff097          	auipc	ra,0xfffff
    80003096:	906080e7          	jalr	-1786(ra) # 80001998 <myproc>
    8000309a:	551c                	lw	a5,40(a0)
    8000309c:	05278163          	beq	a5,s2,800030de <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    800030a0:	85d2                	mv	a1,s4
    800030a2:	8526                	mv	a0,s1
    800030a4:	fffff097          	auipc	ra,0xfffff
    800030a8:	06e080e7          	jalr	110(ra) # 80002112 <sleep>
  while(ticks - ticks0 < n){
    800030ac:	409c                	lw	a5,0(s1)
    800030ae:	413787bb          	subw	a5,a5,s3
    800030b2:	fcc42703          	lw	a4,-52(s0)
    800030b6:	fce7eee3          	bltu	a5,a4,80003092 <sys_sleep+0x54>
  }
  release(&tickslock);
    800030ba:	0001c517          	auipc	a0,0x1c
    800030be:	61650513          	addi	a0,a0,1558 # 8001f6d0 <tickslock>
    800030c2:	ffffe097          	auipc	ra,0xffffe
    800030c6:	bce080e7          	jalr	-1074(ra) # 80000c90 <release>
  return 0;
    800030ca:	4781                	li	a5,0
}
    800030cc:	853e                	mv	a0,a5
    800030ce:	70e2                	ld	ra,56(sp)
    800030d0:	7442                	ld	s0,48(sp)
    800030d2:	74a2                	ld	s1,40(sp)
    800030d4:	7902                	ld	s2,32(sp)
    800030d6:	69e2                	ld	s3,24(sp)
    800030d8:	6a42                	ld	s4,16(sp)
    800030da:	6121                	addi	sp,sp,64
    800030dc:	8082                	ret
      release(&tickslock);
    800030de:	0001c517          	auipc	a0,0x1c
    800030e2:	5f250513          	addi	a0,a0,1522 # 8001f6d0 <tickslock>
    800030e6:	ffffe097          	auipc	ra,0xffffe
    800030ea:	baa080e7          	jalr	-1110(ra) # 80000c90 <release>
      return -1;
    800030ee:	57fd                	li	a5,-1
    800030f0:	bff1                	j	800030cc <sys_sleep+0x8e>

00000000800030f2 <sys_kill>:

uint64
sys_kill(void)
{
    800030f2:	1101                	addi	sp,sp,-32
    800030f4:	ec06                	sd	ra,24(sp)
    800030f6:	e822                	sd	s0,16(sp)
    800030f8:	1000                	addi	s0,sp,32
  int pid;
  int signum;

  if(argint(0, &pid) < 0)
    800030fa:	fec40593          	addi	a1,s0,-20
    800030fe:	4501                	li	a0,0
    80003100:	00000097          	auipc	ra,0x0
    80003104:	d7e080e7          	jalr	-642(ra) # 80002e7e <argint>
    80003108:	87aa                	mv	a5,a0
    return -1;
    8000310a:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000310c:	0207c963          	bltz	a5,8000313e <sys_kill+0x4c>
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003110:	fe840593          	addi	a1,s0,-24
    80003114:	4505                	li	a0,1
    80003116:	00000097          	auipc	ra,0x0
    8000311a:	d68080e7          	jalr	-664(ra) # 80002e7e <argint>
    8000311e:	02054463          	bltz	a0,80003146 <sys_kill+0x54>
    80003122:	fe842583          	lw	a1,-24(s0)
    80003126:	0005871b          	sext.w	a4,a1
    8000312a:	47fd                	li	a5,31
    return -1;
    8000312c:	557d                	li	a0,-1
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    8000312e:	00e7e863          	bltu	a5,a4,8000313e <sys_kill+0x4c>
  return kill(pid, signum);
    80003132:	fec42503          	lw	a0,-20(s0)
    80003136:	fffff097          	auipc	ra,0xfffff
    8000313a:	310080e7          	jalr	784(ra) # 80002446 <kill>
}
    8000313e:	60e2                	ld	ra,24(sp)
    80003140:	6442                	ld	s0,16(sp)
    80003142:	6105                	addi	sp,sp,32
    80003144:	8082                	ret
    return -1;
    80003146:	557d                	li	a0,-1
    80003148:	bfdd                	j	8000313e <sys_kill+0x4c>

000000008000314a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000314a:	1101                	addi	sp,sp,-32
    8000314c:	ec06                	sd	ra,24(sp)
    8000314e:	e822                	sd	s0,16(sp)
    80003150:	e426                	sd	s1,8(sp)
    80003152:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003154:	0001c517          	auipc	a0,0x1c
    80003158:	57c50513          	addi	a0,a0,1404 # 8001f6d0 <tickslock>
    8000315c:	ffffe097          	auipc	ra,0xffffe
    80003160:	a6a080e7          	jalr	-1430(ra) # 80000bc6 <acquire>
  xticks = ticks;
    80003164:	00006497          	auipc	s1,0x6
    80003168:	ecc4a483          	lw	s1,-308(s1) # 80009030 <ticks>
  release(&tickslock);
    8000316c:	0001c517          	auipc	a0,0x1c
    80003170:	56450513          	addi	a0,a0,1380 # 8001f6d0 <tickslock>
    80003174:	ffffe097          	auipc	ra,0xffffe
    80003178:	b1c080e7          	jalr	-1252(ra) # 80000c90 <release>
  return xticks;
}
    8000317c:	02049513          	slli	a0,s1,0x20
    80003180:	9101                	srli	a0,a0,0x20
    80003182:	60e2                	ld	ra,24(sp)
    80003184:	6442                	ld	s0,16(sp)
    80003186:	64a2                	ld	s1,8(sp)
    80003188:	6105                	addi	sp,sp,32
    8000318a:	8082                	ret

000000008000318c <sys_sigprocmask>:

uint64
sys_sigprocmask(void)
{
    8000318c:	1101                	addi	sp,sp,-32
    8000318e:	ec06                	sd	ra,24(sp)
    80003190:	e822                	sd	s0,16(sp)
    80003192:	1000                	addi	s0,sp,32
  uint sigmask;

  if(argint(0, &sigmask) < 0)
    80003194:	fec40593          	addi	a1,s0,-20
    80003198:	4501                	li	a0,0
    8000319a:	00000097          	auipc	ra,0x0
    8000319e:	ce4080e7          	jalr	-796(ra) # 80002e7e <argint>
    800031a2:	87aa                	mv	a5,a0
    return -1;
    800031a4:	557d                	li	a0,-1
  if(argint(0, &sigmask) < 0)
    800031a6:	0007ca63          	bltz	a5,800031ba <sys_sigprocmask+0x2e>
  return sigprocmask(sigmask);
    800031aa:	fec42503          	lw	a0,-20(s0)
    800031ae:	fffff097          	auipc	ra,0xfffff
    800031b2:	514080e7          	jalr	1300(ra) # 800026c2 <sigprocmask>
    800031b6:	1502                	slli	a0,a0,0x20
    800031b8:	9101                	srli	a0,a0,0x20
}
    800031ba:	60e2                	ld	ra,24(sp)
    800031bc:	6442                	ld	s0,16(sp)
    800031be:	6105                	addi	sp,sp,32
    800031c0:	8082                	ret

00000000800031c2 <sys_sigaction>:

uint64
sys_sigaction(void)
{
    800031c2:	7179                	addi	sp,sp,-48
    800031c4:	f406                	sd	ra,40(sp)
    800031c6:	f022                	sd	s0,32(sp)
    800031c8:	1800                	addi	s0,sp,48
  int signum;
  uint64 newact;
  uint64 oldact;
  
  if(argint(0, &signum) < 0)
    800031ca:	fec40593          	addi	a1,s0,-20
    800031ce:	4501                	li	a0,0
    800031d0:	00000097          	auipc	ra,0x0
    800031d4:	cae080e7          	jalr	-850(ra) # 80002e7e <argint>
    return -1;
    800031d8:	57fd                	li	a5,-1
  if(argint(0, &signum) < 0)
    800031da:	04054163          	bltz	a0,8000321c <sys_sigaction+0x5a>
  if(argaddr(1, &newact) < 0)
    800031de:	fe040593          	addi	a1,s0,-32
    800031e2:	4505                	li	a0,1
    800031e4:	00000097          	auipc	ra,0x0
    800031e8:	cbc080e7          	jalr	-836(ra) # 80002ea0 <argaddr>
    return -1;
    800031ec:	57fd                	li	a5,-1
  if(argaddr(1, &newact) < 0)
    800031ee:	02054763          	bltz	a0,8000321c <sys_sigaction+0x5a>
  if(argaddr(1, &oldact) < 0)
    800031f2:	fd840593          	addi	a1,s0,-40
    800031f6:	4505                	li	a0,1
    800031f8:	00000097          	auipc	ra,0x0
    800031fc:	ca8080e7          	jalr	-856(ra) # 80002ea0 <argaddr>
    return -1;
    80003200:	57fd                	li	a5,-1
  if(argaddr(1, &oldact) < 0)
    80003202:	00054d63          	bltz	a0,8000321c <sys_sigaction+0x5a>

  return sigaction(signum,newact,oldact);
    80003206:	fd843603          	ld	a2,-40(s0)
    8000320a:	fe043583          	ld	a1,-32(s0)
    8000320e:	fec42503          	lw	a0,-20(s0)
    80003212:	fffff097          	auipc	ra,0xfffff
    80003216:	504080e7          	jalr	1284(ra) # 80002716 <sigaction>
    8000321a:	87aa                	mv	a5,a0
  
}
    8000321c:	853e                	mv	a0,a5
    8000321e:	70a2                	ld	ra,40(sp)
    80003220:	7402                	ld	s0,32(sp)
    80003222:	6145                	addi	sp,sp,48
    80003224:	8082                	ret

0000000080003226 <sys_sigret>:
uint64
sys_sigret(void)
{
    80003226:	1141                	addi	sp,sp,-16
    80003228:	e406                	sd	ra,8(sp)
    8000322a:	e022                	sd	s0,0(sp)
    8000322c:	0800                	addi	s0,sp,16
  sigret();
    8000322e:	fffff097          	auipc	ra,0xfffff
    80003232:	58a080e7          	jalr	1418(ra) # 800027b8 <sigret>
}
    80003236:	60a2                	ld	ra,8(sp)
    80003238:	6402                	ld	s0,0(sp)
    8000323a:	0141                	addi	sp,sp,16
    8000323c:	8082                	ret

000000008000323e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000323e:	7179                	addi	sp,sp,-48
    80003240:	f406                	sd	ra,40(sp)
    80003242:	f022                	sd	s0,32(sp)
    80003244:	ec26                	sd	s1,24(sp)
    80003246:	e84a                	sd	s2,16(sp)
    80003248:	e44e                	sd	s3,8(sp)
    8000324a:	e052                	sd	s4,0(sp)
    8000324c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000324e:	00005597          	auipc	a1,0x5
    80003252:	39a58593          	addi	a1,a1,922 # 800085e8 <syscalls+0xc8>
    80003256:	0001c517          	auipc	a0,0x1c
    8000325a:	49250513          	addi	a0,a0,1170 # 8001f6e8 <bcache>
    8000325e:	ffffe097          	auipc	ra,0xffffe
    80003262:	8d8080e7          	jalr	-1832(ra) # 80000b36 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003266:	00024797          	auipc	a5,0x24
    8000326a:	48278793          	addi	a5,a5,1154 # 800276e8 <bcache+0x8000>
    8000326e:	00024717          	auipc	a4,0x24
    80003272:	6e270713          	addi	a4,a4,1762 # 80027950 <bcache+0x8268>
    80003276:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000327a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000327e:	0001c497          	auipc	s1,0x1c
    80003282:	48248493          	addi	s1,s1,1154 # 8001f700 <bcache+0x18>
    b->next = bcache.head.next;
    80003286:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003288:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000328a:	00005a17          	auipc	s4,0x5
    8000328e:	366a0a13          	addi	s4,s4,870 # 800085f0 <syscalls+0xd0>
    b->next = bcache.head.next;
    80003292:	2b893783          	ld	a5,696(s2)
    80003296:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003298:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000329c:	85d2                	mv	a1,s4
    8000329e:	01048513          	addi	a0,s1,16
    800032a2:	00001097          	auipc	ra,0x1
    800032a6:	4c2080e7          	jalr	1218(ra) # 80004764 <initsleeplock>
    bcache.head.next->prev = b;
    800032aa:	2b893783          	ld	a5,696(s2)
    800032ae:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800032b0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800032b4:	45848493          	addi	s1,s1,1112
    800032b8:	fd349de3          	bne	s1,s3,80003292 <binit+0x54>
  }
}
    800032bc:	70a2                	ld	ra,40(sp)
    800032be:	7402                	ld	s0,32(sp)
    800032c0:	64e2                	ld	s1,24(sp)
    800032c2:	6942                	ld	s2,16(sp)
    800032c4:	69a2                	ld	s3,8(sp)
    800032c6:	6a02                	ld	s4,0(sp)
    800032c8:	6145                	addi	sp,sp,48
    800032ca:	8082                	ret

00000000800032cc <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800032cc:	7179                	addi	sp,sp,-48
    800032ce:	f406                	sd	ra,40(sp)
    800032d0:	f022                	sd	s0,32(sp)
    800032d2:	ec26                	sd	s1,24(sp)
    800032d4:	e84a                	sd	s2,16(sp)
    800032d6:	e44e                	sd	s3,8(sp)
    800032d8:	1800                	addi	s0,sp,48
    800032da:	892a                	mv	s2,a0
    800032dc:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800032de:	0001c517          	auipc	a0,0x1c
    800032e2:	40a50513          	addi	a0,a0,1034 # 8001f6e8 <bcache>
    800032e6:	ffffe097          	auipc	ra,0xffffe
    800032ea:	8e0080e7          	jalr	-1824(ra) # 80000bc6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800032ee:	00024497          	auipc	s1,0x24
    800032f2:	6b24b483          	ld	s1,1714(s1) # 800279a0 <bcache+0x82b8>
    800032f6:	00024797          	auipc	a5,0x24
    800032fa:	65a78793          	addi	a5,a5,1626 # 80027950 <bcache+0x8268>
    800032fe:	02f48f63          	beq	s1,a5,8000333c <bread+0x70>
    80003302:	873e                	mv	a4,a5
    80003304:	a021                	j	8000330c <bread+0x40>
    80003306:	68a4                	ld	s1,80(s1)
    80003308:	02e48a63          	beq	s1,a4,8000333c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000330c:	449c                	lw	a5,8(s1)
    8000330e:	ff279ce3          	bne	a5,s2,80003306 <bread+0x3a>
    80003312:	44dc                	lw	a5,12(s1)
    80003314:	ff3799e3          	bne	a5,s3,80003306 <bread+0x3a>
      b->refcnt++;
    80003318:	40bc                	lw	a5,64(s1)
    8000331a:	2785                	addiw	a5,a5,1
    8000331c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000331e:	0001c517          	auipc	a0,0x1c
    80003322:	3ca50513          	addi	a0,a0,970 # 8001f6e8 <bcache>
    80003326:	ffffe097          	auipc	ra,0xffffe
    8000332a:	96a080e7          	jalr	-1686(ra) # 80000c90 <release>
      acquiresleep(&b->lock);
    8000332e:	01048513          	addi	a0,s1,16
    80003332:	00001097          	auipc	ra,0x1
    80003336:	46c080e7          	jalr	1132(ra) # 8000479e <acquiresleep>
      return b;
    8000333a:	a8b9                	j	80003398 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000333c:	00024497          	auipc	s1,0x24
    80003340:	65c4b483          	ld	s1,1628(s1) # 80027998 <bcache+0x82b0>
    80003344:	00024797          	auipc	a5,0x24
    80003348:	60c78793          	addi	a5,a5,1548 # 80027950 <bcache+0x8268>
    8000334c:	00f48863          	beq	s1,a5,8000335c <bread+0x90>
    80003350:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003352:	40bc                	lw	a5,64(s1)
    80003354:	cf81                	beqz	a5,8000336c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003356:	64a4                	ld	s1,72(s1)
    80003358:	fee49de3          	bne	s1,a4,80003352 <bread+0x86>
  panic("bget: no buffers");
    8000335c:	00005517          	auipc	a0,0x5
    80003360:	29c50513          	addi	a0,a0,668 # 800085f8 <syscalls+0xd8>
    80003364:	ffffd097          	auipc	ra,0xffffd
    80003368:	1ca080e7          	jalr	458(ra) # 8000052e <panic>
      b->dev = dev;
    8000336c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003370:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003374:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003378:	4785                	li	a5,1
    8000337a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000337c:	0001c517          	auipc	a0,0x1c
    80003380:	36c50513          	addi	a0,a0,876 # 8001f6e8 <bcache>
    80003384:	ffffe097          	auipc	ra,0xffffe
    80003388:	90c080e7          	jalr	-1780(ra) # 80000c90 <release>
      acquiresleep(&b->lock);
    8000338c:	01048513          	addi	a0,s1,16
    80003390:	00001097          	auipc	ra,0x1
    80003394:	40e080e7          	jalr	1038(ra) # 8000479e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003398:	409c                	lw	a5,0(s1)
    8000339a:	cb89                	beqz	a5,800033ac <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000339c:	8526                	mv	a0,s1
    8000339e:	70a2                	ld	ra,40(sp)
    800033a0:	7402                	ld	s0,32(sp)
    800033a2:	64e2                	ld	s1,24(sp)
    800033a4:	6942                	ld	s2,16(sp)
    800033a6:	69a2                	ld	s3,8(sp)
    800033a8:	6145                	addi	sp,sp,48
    800033aa:	8082                	ret
    virtio_disk_rw(b, 0);
    800033ac:	4581                	li	a1,0
    800033ae:	8526                	mv	a0,s1
    800033b0:	00003097          	auipc	ra,0x3
    800033b4:	f36080e7          	jalr	-202(ra) # 800062e6 <virtio_disk_rw>
    b->valid = 1;
    800033b8:	4785                	li	a5,1
    800033ba:	c09c                	sw	a5,0(s1)
  return b;
    800033bc:	b7c5                	j	8000339c <bread+0xd0>

00000000800033be <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800033be:	1101                	addi	sp,sp,-32
    800033c0:	ec06                	sd	ra,24(sp)
    800033c2:	e822                	sd	s0,16(sp)
    800033c4:	e426                	sd	s1,8(sp)
    800033c6:	1000                	addi	s0,sp,32
    800033c8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033ca:	0541                	addi	a0,a0,16
    800033cc:	00001097          	auipc	ra,0x1
    800033d0:	46c080e7          	jalr	1132(ra) # 80004838 <holdingsleep>
    800033d4:	cd01                	beqz	a0,800033ec <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800033d6:	4585                	li	a1,1
    800033d8:	8526                	mv	a0,s1
    800033da:	00003097          	auipc	ra,0x3
    800033de:	f0c080e7          	jalr	-244(ra) # 800062e6 <virtio_disk_rw>
}
    800033e2:	60e2                	ld	ra,24(sp)
    800033e4:	6442                	ld	s0,16(sp)
    800033e6:	64a2                	ld	s1,8(sp)
    800033e8:	6105                	addi	sp,sp,32
    800033ea:	8082                	ret
    panic("bwrite");
    800033ec:	00005517          	auipc	a0,0x5
    800033f0:	22450513          	addi	a0,a0,548 # 80008610 <syscalls+0xf0>
    800033f4:	ffffd097          	auipc	ra,0xffffd
    800033f8:	13a080e7          	jalr	314(ra) # 8000052e <panic>

00000000800033fc <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800033fc:	1101                	addi	sp,sp,-32
    800033fe:	ec06                	sd	ra,24(sp)
    80003400:	e822                	sd	s0,16(sp)
    80003402:	e426                	sd	s1,8(sp)
    80003404:	e04a                	sd	s2,0(sp)
    80003406:	1000                	addi	s0,sp,32
    80003408:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000340a:	01050913          	addi	s2,a0,16
    8000340e:	854a                	mv	a0,s2
    80003410:	00001097          	auipc	ra,0x1
    80003414:	428080e7          	jalr	1064(ra) # 80004838 <holdingsleep>
    80003418:	c92d                	beqz	a0,8000348a <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000341a:	854a                	mv	a0,s2
    8000341c:	00001097          	auipc	ra,0x1
    80003420:	3d8080e7          	jalr	984(ra) # 800047f4 <releasesleep>

  acquire(&bcache.lock);
    80003424:	0001c517          	auipc	a0,0x1c
    80003428:	2c450513          	addi	a0,a0,708 # 8001f6e8 <bcache>
    8000342c:	ffffd097          	auipc	ra,0xffffd
    80003430:	79a080e7          	jalr	1946(ra) # 80000bc6 <acquire>
  b->refcnt--;
    80003434:	40bc                	lw	a5,64(s1)
    80003436:	37fd                	addiw	a5,a5,-1
    80003438:	0007871b          	sext.w	a4,a5
    8000343c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000343e:	eb05                	bnez	a4,8000346e <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003440:	68bc                	ld	a5,80(s1)
    80003442:	64b8                	ld	a4,72(s1)
    80003444:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003446:	64bc                	ld	a5,72(s1)
    80003448:	68b8                	ld	a4,80(s1)
    8000344a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000344c:	00024797          	auipc	a5,0x24
    80003450:	29c78793          	addi	a5,a5,668 # 800276e8 <bcache+0x8000>
    80003454:	2b87b703          	ld	a4,696(a5)
    80003458:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000345a:	00024717          	auipc	a4,0x24
    8000345e:	4f670713          	addi	a4,a4,1270 # 80027950 <bcache+0x8268>
    80003462:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003464:	2b87b703          	ld	a4,696(a5)
    80003468:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000346a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000346e:	0001c517          	auipc	a0,0x1c
    80003472:	27a50513          	addi	a0,a0,634 # 8001f6e8 <bcache>
    80003476:	ffffe097          	auipc	ra,0xffffe
    8000347a:	81a080e7          	jalr	-2022(ra) # 80000c90 <release>
}
    8000347e:	60e2                	ld	ra,24(sp)
    80003480:	6442                	ld	s0,16(sp)
    80003482:	64a2                	ld	s1,8(sp)
    80003484:	6902                	ld	s2,0(sp)
    80003486:	6105                	addi	sp,sp,32
    80003488:	8082                	ret
    panic("brelse");
    8000348a:	00005517          	auipc	a0,0x5
    8000348e:	18e50513          	addi	a0,a0,398 # 80008618 <syscalls+0xf8>
    80003492:	ffffd097          	auipc	ra,0xffffd
    80003496:	09c080e7          	jalr	156(ra) # 8000052e <panic>

000000008000349a <bpin>:

void
bpin(struct buf *b) {
    8000349a:	1101                	addi	sp,sp,-32
    8000349c:	ec06                	sd	ra,24(sp)
    8000349e:	e822                	sd	s0,16(sp)
    800034a0:	e426                	sd	s1,8(sp)
    800034a2:	1000                	addi	s0,sp,32
    800034a4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034a6:	0001c517          	auipc	a0,0x1c
    800034aa:	24250513          	addi	a0,a0,578 # 8001f6e8 <bcache>
    800034ae:	ffffd097          	auipc	ra,0xffffd
    800034b2:	718080e7          	jalr	1816(ra) # 80000bc6 <acquire>
  b->refcnt++;
    800034b6:	40bc                	lw	a5,64(s1)
    800034b8:	2785                	addiw	a5,a5,1
    800034ba:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034bc:	0001c517          	auipc	a0,0x1c
    800034c0:	22c50513          	addi	a0,a0,556 # 8001f6e8 <bcache>
    800034c4:	ffffd097          	auipc	ra,0xffffd
    800034c8:	7cc080e7          	jalr	1996(ra) # 80000c90 <release>
}
    800034cc:	60e2                	ld	ra,24(sp)
    800034ce:	6442                	ld	s0,16(sp)
    800034d0:	64a2                	ld	s1,8(sp)
    800034d2:	6105                	addi	sp,sp,32
    800034d4:	8082                	ret

00000000800034d6 <bunpin>:

void
bunpin(struct buf *b) {
    800034d6:	1101                	addi	sp,sp,-32
    800034d8:	ec06                	sd	ra,24(sp)
    800034da:	e822                	sd	s0,16(sp)
    800034dc:	e426                	sd	s1,8(sp)
    800034de:	1000                	addi	s0,sp,32
    800034e0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034e2:	0001c517          	auipc	a0,0x1c
    800034e6:	20650513          	addi	a0,a0,518 # 8001f6e8 <bcache>
    800034ea:	ffffd097          	auipc	ra,0xffffd
    800034ee:	6dc080e7          	jalr	1756(ra) # 80000bc6 <acquire>
  b->refcnt--;
    800034f2:	40bc                	lw	a5,64(s1)
    800034f4:	37fd                	addiw	a5,a5,-1
    800034f6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034f8:	0001c517          	auipc	a0,0x1c
    800034fc:	1f050513          	addi	a0,a0,496 # 8001f6e8 <bcache>
    80003500:	ffffd097          	auipc	ra,0xffffd
    80003504:	790080e7          	jalr	1936(ra) # 80000c90 <release>
}
    80003508:	60e2                	ld	ra,24(sp)
    8000350a:	6442                	ld	s0,16(sp)
    8000350c:	64a2                	ld	s1,8(sp)
    8000350e:	6105                	addi	sp,sp,32
    80003510:	8082                	ret

0000000080003512 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003512:	1101                	addi	sp,sp,-32
    80003514:	ec06                	sd	ra,24(sp)
    80003516:	e822                	sd	s0,16(sp)
    80003518:	e426                	sd	s1,8(sp)
    8000351a:	e04a                	sd	s2,0(sp)
    8000351c:	1000                	addi	s0,sp,32
    8000351e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003520:	00d5d59b          	srliw	a1,a1,0xd
    80003524:	00025797          	auipc	a5,0x25
    80003528:	8a07a783          	lw	a5,-1888(a5) # 80027dc4 <sb+0x1c>
    8000352c:	9dbd                	addw	a1,a1,a5
    8000352e:	00000097          	auipc	ra,0x0
    80003532:	d9e080e7          	jalr	-610(ra) # 800032cc <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003536:	0074f713          	andi	a4,s1,7
    8000353a:	4785                	li	a5,1
    8000353c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003540:	14ce                	slli	s1,s1,0x33
    80003542:	90d9                	srli	s1,s1,0x36
    80003544:	00950733          	add	a4,a0,s1
    80003548:	05874703          	lbu	a4,88(a4)
    8000354c:	00e7f6b3          	and	a3,a5,a4
    80003550:	c69d                	beqz	a3,8000357e <bfree+0x6c>
    80003552:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003554:	94aa                	add	s1,s1,a0
    80003556:	fff7c793          	not	a5,a5
    8000355a:	8ff9                	and	a5,a5,a4
    8000355c:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003560:	00001097          	auipc	ra,0x1
    80003564:	11e080e7          	jalr	286(ra) # 8000467e <log_write>
  brelse(bp);
    80003568:	854a                	mv	a0,s2
    8000356a:	00000097          	auipc	ra,0x0
    8000356e:	e92080e7          	jalr	-366(ra) # 800033fc <brelse>
}
    80003572:	60e2                	ld	ra,24(sp)
    80003574:	6442                	ld	s0,16(sp)
    80003576:	64a2                	ld	s1,8(sp)
    80003578:	6902                	ld	s2,0(sp)
    8000357a:	6105                	addi	sp,sp,32
    8000357c:	8082                	ret
    panic("freeing free block");
    8000357e:	00005517          	auipc	a0,0x5
    80003582:	0a250513          	addi	a0,a0,162 # 80008620 <syscalls+0x100>
    80003586:	ffffd097          	auipc	ra,0xffffd
    8000358a:	fa8080e7          	jalr	-88(ra) # 8000052e <panic>

000000008000358e <balloc>:
{
    8000358e:	711d                	addi	sp,sp,-96
    80003590:	ec86                	sd	ra,88(sp)
    80003592:	e8a2                	sd	s0,80(sp)
    80003594:	e4a6                	sd	s1,72(sp)
    80003596:	e0ca                	sd	s2,64(sp)
    80003598:	fc4e                	sd	s3,56(sp)
    8000359a:	f852                	sd	s4,48(sp)
    8000359c:	f456                	sd	s5,40(sp)
    8000359e:	f05a                	sd	s6,32(sp)
    800035a0:	ec5e                	sd	s7,24(sp)
    800035a2:	e862                	sd	s8,16(sp)
    800035a4:	e466                	sd	s9,8(sp)
    800035a6:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800035a8:	00025797          	auipc	a5,0x25
    800035ac:	8047a783          	lw	a5,-2044(a5) # 80027dac <sb+0x4>
    800035b0:	cbd1                	beqz	a5,80003644 <balloc+0xb6>
    800035b2:	8baa                	mv	s7,a0
    800035b4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800035b6:	00024b17          	auipc	s6,0x24
    800035ba:	7f2b0b13          	addi	s6,s6,2034 # 80027da8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035be:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800035c0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035c2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800035c4:	6c89                	lui	s9,0x2
    800035c6:	a831                	j	800035e2 <balloc+0x54>
    brelse(bp);
    800035c8:	854a                	mv	a0,s2
    800035ca:	00000097          	auipc	ra,0x0
    800035ce:	e32080e7          	jalr	-462(ra) # 800033fc <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800035d2:	015c87bb          	addw	a5,s9,s5
    800035d6:	00078a9b          	sext.w	s5,a5
    800035da:	004b2703          	lw	a4,4(s6)
    800035de:	06eaf363          	bgeu	s5,a4,80003644 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800035e2:	41fad79b          	sraiw	a5,s5,0x1f
    800035e6:	0137d79b          	srliw	a5,a5,0x13
    800035ea:	015787bb          	addw	a5,a5,s5
    800035ee:	40d7d79b          	sraiw	a5,a5,0xd
    800035f2:	01cb2583          	lw	a1,28(s6)
    800035f6:	9dbd                	addw	a1,a1,a5
    800035f8:	855e                	mv	a0,s7
    800035fa:	00000097          	auipc	ra,0x0
    800035fe:	cd2080e7          	jalr	-814(ra) # 800032cc <bread>
    80003602:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003604:	004b2503          	lw	a0,4(s6)
    80003608:	000a849b          	sext.w	s1,s5
    8000360c:	8662                	mv	a2,s8
    8000360e:	faa4fde3          	bgeu	s1,a0,800035c8 <balloc+0x3a>
      m = 1 << (bi % 8);
    80003612:	41f6579b          	sraiw	a5,a2,0x1f
    80003616:	01d7d69b          	srliw	a3,a5,0x1d
    8000361a:	00c6873b          	addw	a4,a3,a2
    8000361e:	00777793          	andi	a5,a4,7
    80003622:	9f95                	subw	a5,a5,a3
    80003624:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003628:	4037571b          	sraiw	a4,a4,0x3
    8000362c:	00e906b3          	add	a3,s2,a4
    80003630:	0586c683          	lbu	a3,88(a3)
    80003634:	00d7f5b3          	and	a1,a5,a3
    80003638:	cd91                	beqz	a1,80003654 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000363a:	2605                	addiw	a2,a2,1
    8000363c:	2485                	addiw	s1,s1,1
    8000363e:	fd4618e3          	bne	a2,s4,8000360e <balloc+0x80>
    80003642:	b759                	j	800035c8 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003644:	00005517          	auipc	a0,0x5
    80003648:	ff450513          	addi	a0,a0,-12 # 80008638 <syscalls+0x118>
    8000364c:	ffffd097          	auipc	ra,0xffffd
    80003650:	ee2080e7          	jalr	-286(ra) # 8000052e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003654:	974a                	add	a4,a4,s2
    80003656:	8fd5                	or	a5,a5,a3
    80003658:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000365c:	854a                	mv	a0,s2
    8000365e:	00001097          	auipc	ra,0x1
    80003662:	020080e7          	jalr	32(ra) # 8000467e <log_write>
        brelse(bp);
    80003666:	854a                	mv	a0,s2
    80003668:	00000097          	auipc	ra,0x0
    8000366c:	d94080e7          	jalr	-620(ra) # 800033fc <brelse>
  bp = bread(dev, bno);
    80003670:	85a6                	mv	a1,s1
    80003672:	855e                	mv	a0,s7
    80003674:	00000097          	auipc	ra,0x0
    80003678:	c58080e7          	jalr	-936(ra) # 800032cc <bread>
    8000367c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000367e:	40000613          	li	a2,1024
    80003682:	4581                	li	a1,0
    80003684:	05850513          	addi	a0,a0,88
    80003688:	ffffd097          	auipc	ra,0xffffd
    8000368c:	650080e7          	jalr	1616(ra) # 80000cd8 <memset>
  log_write(bp);
    80003690:	854a                	mv	a0,s2
    80003692:	00001097          	auipc	ra,0x1
    80003696:	fec080e7          	jalr	-20(ra) # 8000467e <log_write>
  brelse(bp);
    8000369a:	854a                	mv	a0,s2
    8000369c:	00000097          	auipc	ra,0x0
    800036a0:	d60080e7          	jalr	-672(ra) # 800033fc <brelse>
}
    800036a4:	8526                	mv	a0,s1
    800036a6:	60e6                	ld	ra,88(sp)
    800036a8:	6446                	ld	s0,80(sp)
    800036aa:	64a6                	ld	s1,72(sp)
    800036ac:	6906                	ld	s2,64(sp)
    800036ae:	79e2                	ld	s3,56(sp)
    800036b0:	7a42                	ld	s4,48(sp)
    800036b2:	7aa2                	ld	s5,40(sp)
    800036b4:	7b02                	ld	s6,32(sp)
    800036b6:	6be2                	ld	s7,24(sp)
    800036b8:	6c42                	ld	s8,16(sp)
    800036ba:	6ca2                	ld	s9,8(sp)
    800036bc:	6125                	addi	sp,sp,96
    800036be:	8082                	ret

00000000800036c0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800036c0:	7179                	addi	sp,sp,-48
    800036c2:	f406                	sd	ra,40(sp)
    800036c4:	f022                	sd	s0,32(sp)
    800036c6:	ec26                	sd	s1,24(sp)
    800036c8:	e84a                	sd	s2,16(sp)
    800036ca:	e44e                	sd	s3,8(sp)
    800036cc:	e052                	sd	s4,0(sp)
    800036ce:	1800                	addi	s0,sp,48
    800036d0:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800036d2:	47ad                	li	a5,11
    800036d4:	04b7fe63          	bgeu	a5,a1,80003730 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800036d8:	ff45849b          	addiw	s1,a1,-12
    800036dc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800036e0:	0ff00793          	li	a5,255
    800036e4:	0ae7e463          	bltu	a5,a4,8000378c <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800036e8:	08052583          	lw	a1,128(a0)
    800036ec:	c5b5                	beqz	a1,80003758 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800036ee:	00092503          	lw	a0,0(s2)
    800036f2:	00000097          	auipc	ra,0x0
    800036f6:	bda080e7          	jalr	-1062(ra) # 800032cc <bread>
    800036fa:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800036fc:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003700:	02049713          	slli	a4,s1,0x20
    80003704:	01e75593          	srli	a1,a4,0x1e
    80003708:	00b784b3          	add	s1,a5,a1
    8000370c:	0004a983          	lw	s3,0(s1)
    80003710:	04098e63          	beqz	s3,8000376c <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003714:	8552                	mv	a0,s4
    80003716:	00000097          	auipc	ra,0x0
    8000371a:	ce6080e7          	jalr	-794(ra) # 800033fc <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000371e:	854e                	mv	a0,s3
    80003720:	70a2                	ld	ra,40(sp)
    80003722:	7402                	ld	s0,32(sp)
    80003724:	64e2                	ld	s1,24(sp)
    80003726:	6942                	ld	s2,16(sp)
    80003728:	69a2                	ld	s3,8(sp)
    8000372a:	6a02                	ld	s4,0(sp)
    8000372c:	6145                	addi	sp,sp,48
    8000372e:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003730:	02059793          	slli	a5,a1,0x20
    80003734:	01e7d593          	srli	a1,a5,0x1e
    80003738:	00b504b3          	add	s1,a0,a1
    8000373c:	0504a983          	lw	s3,80(s1)
    80003740:	fc099fe3          	bnez	s3,8000371e <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003744:	4108                	lw	a0,0(a0)
    80003746:	00000097          	auipc	ra,0x0
    8000374a:	e48080e7          	jalr	-440(ra) # 8000358e <balloc>
    8000374e:	0005099b          	sext.w	s3,a0
    80003752:	0534a823          	sw	s3,80(s1)
    80003756:	b7e1                	j	8000371e <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003758:	4108                	lw	a0,0(a0)
    8000375a:	00000097          	auipc	ra,0x0
    8000375e:	e34080e7          	jalr	-460(ra) # 8000358e <balloc>
    80003762:	0005059b          	sext.w	a1,a0
    80003766:	08b92023          	sw	a1,128(s2)
    8000376a:	b751                	j	800036ee <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000376c:	00092503          	lw	a0,0(s2)
    80003770:	00000097          	auipc	ra,0x0
    80003774:	e1e080e7          	jalr	-482(ra) # 8000358e <balloc>
    80003778:	0005099b          	sext.w	s3,a0
    8000377c:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003780:	8552                	mv	a0,s4
    80003782:	00001097          	auipc	ra,0x1
    80003786:	efc080e7          	jalr	-260(ra) # 8000467e <log_write>
    8000378a:	b769                	j	80003714 <bmap+0x54>
  panic("bmap: out of range");
    8000378c:	00005517          	auipc	a0,0x5
    80003790:	ec450513          	addi	a0,a0,-316 # 80008650 <syscalls+0x130>
    80003794:	ffffd097          	auipc	ra,0xffffd
    80003798:	d9a080e7          	jalr	-614(ra) # 8000052e <panic>

000000008000379c <iget>:
{
    8000379c:	7179                	addi	sp,sp,-48
    8000379e:	f406                	sd	ra,40(sp)
    800037a0:	f022                	sd	s0,32(sp)
    800037a2:	ec26                	sd	s1,24(sp)
    800037a4:	e84a                	sd	s2,16(sp)
    800037a6:	e44e                	sd	s3,8(sp)
    800037a8:	e052                	sd	s4,0(sp)
    800037aa:	1800                	addi	s0,sp,48
    800037ac:	89aa                	mv	s3,a0
    800037ae:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800037b0:	00024517          	auipc	a0,0x24
    800037b4:	61850513          	addi	a0,a0,1560 # 80027dc8 <itable>
    800037b8:	ffffd097          	auipc	ra,0xffffd
    800037bc:	40e080e7          	jalr	1038(ra) # 80000bc6 <acquire>
  empty = 0;
    800037c0:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037c2:	00024497          	auipc	s1,0x24
    800037c6:	61e48493          	addi	s1,s1,1566 # 80027de0 <itable+0x18>
    800037ca:	00026697          	auipc	a3,0x26
    800037ce:	0a668693          	addi	a3,a3,166 # 80029870 <log>
    800037d2:	a039                	j	800037e0 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037d4:	02090b63          	beqz	s2,8000380a <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037d8:	08848493          	addi	s1,s1,136
    800037dc:	02d48a63          	beq	s1,a3,80003810 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800037e0:	449c                	lw	a5,8(s1)
    800037e2:	fef059e3          	blez	a5,800037d4 <iget+0x38>
    800037e6:	4098                	lw	a4,0(s1)
    800037e8:	ff3716e3          	bne	a4,s3,800037d4 <iget+0x38>
    800037ec:	40d8                	lw	a4,4(s1)
    800037ee:	ff4713e3          	bne	a4,s4,800037d4 <iget+0x38>
      ip->ref++;
    800037f2:	2785                	addiw	a5,a5,1
    800037f4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800037f6:	00024517          	auipc	a0,0x24
    800037fa:	5d250513          	addi	a0,a0,1490 # 80027dc8 <itable>
    800037fe:	ffffd097          	auipc	ra,0xffffd
    80003802:	492080e7          	jalr	1170(ra) # 80000c90 <release>
      return ip;
    80003806:	8926                	mv	s2,s1
    80003808:	a03d                	j	80003836 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000380a:	f7f9                	bnez	a5,800037d8 <iget+0x3c>
    8000380c:	8926                	mv	s2,s1
    8000380e:	b7e9                	j	800037d8 <iget+0x3c>
  if(empty == 0)
    80003810:	02090c63          	beqz	s2,80003848 <iget+0xac>
  ip->dev = dev;
    80003814:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003818:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000381c:	4785                	li	a5,1
    8000381e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003822:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003826:	00024517          	auipc	a0,0x24
    8000382a:	5a250513          	addi	a0,a0,1442 # 80027dc8 <itable>
    8000382e:	ffffd097          	auipc	ra,0xffffd
    80003832:	462080e7          	jalr	1122(ra) # 80000c90 <release>
}
    80003836:	854a                	mv	a0,s2
    80003838:	70a2                	ld	ra,40(sp)
    8000383a:	7402                	ld	s0,32(sp)
    8000383c:	64e2                	ld	s1,24(sp)
    8000383e:	6942                	ld	s2,16(sp)
    80003840:	69a2                	ld	s3,8(sp)
    80003842:	6a02                	ld	s4,0(sp)
    80003844:	6145                	addi	sp,sp,48
    80003846:	8082                	ret
    panic("iget: no inodes");
    80003848:	00005517          	auipc	a0,0x5
    8000384c:	e2050513          	addi	a0,a0,-480 # 80008668 <syscalls+0x148>
    80003850:	ffffd097          	auipc	ra,0xffffd
    80003854:	cde080e7          	jalr	-802(ra) # 8000052e <panic>

0000000080003858 <fsinit>:
fsinit(int dev) {
    80003858:	7179                	addi	sp,sp,-48
    8000385a:	f406                	sd	ra,40(sp)
    8000385c:	f022                	sd	s0,32(sp)
    8000385e:	ec26                	sd	s1,24(sp)
    80003860:	e84a                	sd	s2,16(sp)
    80003862:	e44e                	sd	s3,8(sp)
    80003864:	1800                	addi	s0,sp,48
    80003866:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003868:	4585                	li	a1,1
    8000386a:	00000097          	auipc	ra,0x0
    8000386e:	a62080e7          	jalr	-1438(ra) # 800032cc <bread>
    80003872:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003874:	00024997          	auipc	s3,0x24
    80003878:	53498993          	addi	s3,s3,1332 # 80027da8 <sb>
    8000387c:	02000613          	li	a2,32
    80003880:	05850593          	addi	a1,a0,88
    80003884:	854e                	mv	a0,s3
    80003886:	ffffd097          	auipc	ra,0xffffd
    8000388a:	4ae080e7          	jalr	1198(ra) # 80000d34 <memmove>
  brelse(bp);
    8000388e:	8526                	mv	a0,s1
    80003890:	00000097          	auipc	ra,0x0
    80003894:	b6c080e7          	jalr	-1172(ra) # 800033fc <brelse>
  if(sb.magic != FSMAGIC)
    80003898:	0009a703          	lw	a4,0(s3)
    8000389c:	102037b7          	lui	a5,0x10203
    800038a0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800038a4:	02f71263          	bne	a4,a5,800038c8 <fsinit+0x70>
  initlog(dev, &sb);
    800038a8:	00024597          	auipc	a1,0x24
    800038ac:	50058593          	addi	a1,a1,1280 # 80027da8 <sb>
    800038b0:	854a                	mv	a0,s2
    800038b2:	00001097          	auipc	ra,0x1
    800038b6:	b4e080e7          	jalr	-1202(ra) # 80004400 <initlog>
}
    800038ba:	70a2                	ld	ra,40(sp)
    800038bc:	7402                	ld	s0,32(sp)
    800038be:	64e2                	ld	s1,24(sp)
    800038c0:	6942                	ld	s2,16(sp)
    800038c2:	69a2                	ld	s3,8(sp)
    800038c4:	6145                	addi	sp,sp,48
    800038c6:	8082                	ret
    panic("invalid file system");
    800038c8:	00005517          	auipc	a0,0x5
    800038cc:	db050513          	addi	a0,a0,-592 # 80008678 <syscalls+0x158>
    800038d0:	ffffd097          	auipc	ra,0xffffd
    800038d4:	c5e080e7          	jalr	-930(ra) # 8000052e <panic>

00000000800038d8 <iinit>:
{
    800038d8:	7179                	addi	sp,sp,-48
    800038da:	f406                	sd	ra,40(sp)
    800038dc:	f022                	sd	s0,32(sp)
    800038de:	ec26                	sd	s1,24(sp)
    800038e0:	e84a                	sd	s2,16(sp)
    800038e2:	e44e                	sd	s3,8(sp)
    800038e4:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800038e6:	00005597          	auipc	a1,0x5
    800038ea:	daa58593          	addi	a1,a1,-598 # 80008690 <syscalls+0x170>
    800038ee:	00024517          	auipc	a0,0x24
    800038f2:	4da50513          	addi	a0,a0,1242 # 80027dc8 <itable>
    800038f6:	ffffd097          	auipc	ra,0xffffd
    800038fa:	240080e7          	jalr	576(ra) # 80000b36 <initlock>
  for(i = 0; i < NINODE; i++) {
    800038fe:	00024497          	auipc	s1,0x24
    80003902:	4f248493          	addi	s1,s1,1266 # 80027df0 <itable+0x28>
    80003906:	00026997          	auipc	s3,0x26
    8000390a:	f7a98993          	addi	s3,s3,-134 # 80029880 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000390e:	00005917          	auipc	s2,0x5
    80003912:	d8a90913          	addi	s2,s2,-630 # 80008698 <syscalls+0x178>
    80003916:	85ca                	mv	a1,s2
    80003918:	8526                	mv	a0,s1
    8000391a:	00001097          	auipc	ra,0x1
    8000391e:	e4a080e7          	jalr	-438(ra) # 80004764 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003922:	08848493          	addi	s1,s1,136
    80003926:	ff3498e3          	bne	s1,s3,80003916 <iinit+0x3e>
}
    8000392a:	70a2                	ld	ra,40(sp)
    8000392c:	7402                	ld	s0,32(sp)
    8000392e:	64e2                	ld	s1,24(sp)
    80003930:	6942                	ld	s2,16(sp)
    80003932:	69a2                	ld	s3,8(sp)
    80003934:	6145                	addi	sp,sp,48
    80003936:	8082                	ret

0000000080003938 <ialloc>:
{
    80003938:	715d                	addi	sp,sp,-80
    8000393a:	e486                	sd	ra,72(sp)
    8000393c:	e0a2                	sd	s0,64(sp)
    8000393e:	fc26                	sd	s1,56(sp)
    80003940:	f84a                	sd	s2,48(sp)
    80003942:	f44e                	sd	s3,40(sp)
    80003944:	f052                	sd	s4,32(sp)
    80003946:	ec56                	sd	s5,24(sp)
    80003948:	e85a                	sd	s6,16(sp)
    8000394a:	e45e                	sd	s7,8(sp)
    8000394c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000394e:	00024717          	auipc	a4,0x24
    80003952:	46672703          	lw	a4,1126(a4) # 80027db4 <sb+0xc>
    80003956:	4785                	li	a5,1
    80003958:	04e7fa63          	bgeu	a5,a4,800039ac <ialloc+0x74>
    8000395c:	8aaa                	mv	s5,a0
    8000395e:	8bae                	mv	s7,a1
    80003960:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003962:	00024a17          	auipc	s4,0x24
    80003966:	446a0a13          	addi	s4,s4,1094 # 80027da8 <sb>
    8000396a:	00048b1b          	sext.w	s6,s1
    8000396e:	0044d793          	srli	a5,s1,0x4
    80003972:	018a2583          	lw	a1,24(s4)
    80003976:	9dbd                	addw	a1,a1,a5
    80003978:	8556                	mv	a0,s5
    8000397a:	00000097          	auipc	ra,0x0
    8000397e:	952080e7          	jalr	-1710(ra) # 800032cc <bread>
    80003982:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003984:	05850993          	addi	s3,a0,88
    80003988:	00f4f793          	andi	a5,s1,15
    8000398c:	079a                	slli	a5,a5,0x6
    8000398e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003990:	00099783          	lh	a5,0(s3)
    80003994:	c785                	beqz	a5,800039bc <ialloc+0x84>
    brelse(bp);
    80003996:	00000097          	auipc	ra,0x0
    8000399a:	a66080e7          	jalr	-1434(ra) # 800033fc <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000399e:	0485                	addi	s1,s1,1
    800039a0:	00ca2703          	lw	a4,12(s4)
    800039a4:	0004879b          	sext.w	a5,s1
    800039a8:	fce7e1e3          	bltu	a5,a4,8000396a <ialloc+0x32>
  panic("ialloc: no inodes");
    800039ac:	00005517          	auipc	a0,0x5
    800039b0:	cf450513          	addi	a0,a0,-780 # 800086a0 <syscalls+0x180>
    800039b4:	ffffd097          	auipc	ra,0xffffd
    800039b8:	b7a080e7          	jalr	-1158(ra) # 8000052e <panic>
      memset(dip, 0, sizeof(*dip));
    800039bc:	04000613          	li	a2,64
    800039c0:	4581                	li	a1,0
    800039c2:	854e                	mv	a0,s3
    800039c4:	ffffd097          	auipc	ra,0xffffd
    800039c8:	314080e7          	jalr	788(ra) # 80000cd8 <memset>
      dip->type = type;
    800039cc:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800039d0:	854a                	mv	a0,s2
    800039d2:	00001097          	auipc	ra,0x1
    800039d6:	cac080e7          	jalr	-852(ra) # 8000467e <log_write>
      brelse(bp);
    800039da:	854a                	mv	a0,s2
    800039dc:	00000097          	auipc	ra,0x0
    800039e0:	a20080e7          	jalr	-1504(ra) # 800033fc <brelse>
      return iget(dev, inum);
    800039e4:	85da                	mv	a1,s6
    800039e6:	8556                	mv	a0,s5
    800039e8:	00000097          	auipc	ra,0x0
    800039ec:	db4080e7          	jalr	-588(ra) # 8000379c <iget>
}
    800039f0:	60a6                	ld	ra,72(sp)
    800039f2:	6406                	ld	s0,64(sp)
    800039f4:	74e2                	ld	s1,56(sp)
    800039f6:	7942                	ld	s2,48(sp)
    800039f8:	79a2                	ld	s3,40(sp)
    800039fa:	7a02                	ld	s4,32(sp)
    800039fc:	6ae2                	ld	s5,24(sp)
    800039fe:	6b42                	ld	s6,16(sp)
    80003a00:	6ba2                	ld	s7,8(sp)
    80003a02:	6161                	addi	sp,sp,80
    80003a04:	8082                	ret

0000000080003a06 <iupdate>:
{
    80003a06:	1101                	addi	sp,sp,-32
    80003a08:	ec06                	sd	ra,24(sp)
    80003a0a:	e822                	sd	s0,16(sp)
    80003a0c:	e426                	sd	s1,8(sp)
    80003a0e:	e04a                	sd	s2,0(sp)
    80003a10:	1000                	addi	s0,sp,32
    80003a12:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a14:	415c                	lw	a5,4(a0)
    80003a16:	0047d79b          	srliw	a5,a5,0x4
    80003a1a:	00024597          	auipc	a1,0x24
    80003a1e:	3a65a583          	lw	a1,934(a1) # 80027dc0 <sb+0x18>
    80003a22:	9dbd                	addw	a1,a1,a5
    80003a24:	4108                	lw	a0,0(a0)
    80003a26:	00000097          	auipc	ra,0x0
    80003a2a:	8a6080e7          	jalr	-1882(ra) # 800032cc <bread>
    80003a2e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a30:	05850793          	addi	a5,a0,88
    80003a34:	40c8                	lw	a0,4(s1)
    80003a36:	893d                	andi	a0,a0,15
    80003a38:	051a                	slli	a0,a0,0x6
    80003a3a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003a3c:	04449703          	lh	a4,68(s1)
    80003a40:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003a44:	04649703          	lh	a4,70(s1)
    80003a48:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003a4c:	04849703          	lh	a4,72(s1)
    80003a50:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003a54:	04a49703          	lh	a4,74(s1)
    80003a58:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003a5c:	44f8                	lw	a4,76(s1)
    80003a5e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003a60:	03400613          	li	a2,52
    80003a64:	05048593          	addi	a1,s1,80
    80003a68:	0531                	addi	a0,a0,12
    80003a6a:	ffffd097          	auipc	ra,0xffffd
    80003a6e:	2ca080e7          	jalr	714(ra) # 80000d34 <memmove>
  log_write(bp);
    80003a72:	854a                	mv	a0,s2
    80003a74:	00001097          	auipc	ra,0x1
    80003a78:	c0a080e7          	jalr	-1014(ra) # 8000467e <log_write>
  brelse(bp);
    80003a7c:	854a                	mv	a0,s2
    80003a7e:	00000097          	auipc	ra,0x0
    80003a82:	97e080e7          	jalr	-1666(ra) # 800033fc <brelse>
}
    80003a86:	60e2                	ld	ra,24(sp)
    80003a88:	6442                	ld	s0,16(sp)
    80003a8a:	64a2                	ld	s1,8(sp)
    80003a8c:	6902                	ld	s2,0(sp)
    80003a8e:	6105                	addi	sp,sp,32
    80003a90:	8082                	ret

0000000080003a92 <idup>:
{
    80003a92:	1101                	addi	sp,sp,-32
    80003a94:	ec06                	sd	ra,24(sp)
    80003a96:	e822                	sd	s0,16(sp)
    80003a98:	e426                	sd	s1,8(sp)
    80003a9a:	1000                	addi	s0,sp,32
    80003a9c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a9e:	00024517          	auipc	a0,0x24
    80003aa2:	32a50513          	addi	a0,a0,810 # 80027dc8 <itable>
    80003aa6:	ffffd097          	auipc	ra,0xffffd
    80003aaa:	120080e7          	jalr	288(ra) # 80000bc6 <acquire>
  ip->ref++;
    80003aae:	449c                	lw	a5,8(s1)
    80003ab0:	2785                	addiw	a5,a5,1
    80003ab2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ab4:	00024517          	auipc	a0,0x24
    80003ab8:	31450513          	addi	a0,a0,788 # 80027dc8 <itable>
    80003abc:	ffffd097          	auipc	ra,0xffffd
    80003ac0:	1d4080e7          	jalr	468(ra) # 80000c90 <release>
}
    80003ac4:	8526                	mv	a0,s1
    80003ac6:	60e2                	ld	ra,24(sp)
    80003ac8:	6442                	ld	s0,16(sp)
    80003aca:	64a2                	ld	s1,8(sp)
    80003acc:	6105                	addi	sp,sp,32
    80003ace:	8082                	ret

0000000080003ad0 <ilock>:
{
    80003ad0:	1101                	addi	sp,sp,-32
    80003ad2:	ec06                	sd	ra,24(sp)
    80003ad4:	e822                	sd	s0,16(sp)
    80003ad6:	e426                	sd	s1,8(sp)
    80003ad8:	e04a                	sd	s2,0(sp)
    80003ada:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003adc:	c115                	beqz	a0,80003b00 <ilock+0x30>
    80003ade:	84aa                	mv	s1,a0
    80003ae0:	451c                	lw	a5,8(a0)
    80003ae2:	00f05f63          	blez	a5,80003b00 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003ae6:	0541                	addi	a0,a0,16
    80003ae8:	00001097          	auipc	ra,0x1
    80003aec:	cb6080e7          	jalr	-842(ra) # 8000479e <acquiresleep>
  if(ip->valid == 0){
    80003af0:	40bc                	lw	a5,64(s1)
    80003af2:	cf99                	beqz	a5,80003b10 <ilock+0x40>
}
    80003af4:	60e2                	ld	ra,24(sp)
    80003af6:	6442                	ld	s0,16(sp)
    80003af8:	64a2                	ld	s1,8(sp)
    80003afa:	6902                	ld	s2,0(sp)
    80003afc:	6105                	addi	sp,sp,32
    80003afe:	8082                	ret
    panic("ilock");
    80003b00:	00005517          	auipc	a0,0x5
    80003b04:	bb850513          	addi	a0,a0,-1096 # 800086b8 <syscalls+0x198>
    80003b08:	ffffd097          	auipc	ra,0xffffd
    80003b0c:	a26080e7          	jalr	-1498(ra) # 8000052e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b10:	40dc                	lw	a5,4(s1)
    80003b12:	0047d79b          	srliw	a5,a5,0x4
    80003b16:	00024597          	auipc	a1,0x24
    80003b1a:	2aa5a583          	lw	a1,682(a1) # 80027dc0 <sb+0x18>
    80003b1e:	9dbd                	addw	a1,a1,a5
    80003b20:	4088                	lw	a0,0(s1)
    80003b22:	fffff097          	auipc	ra,0xfffff
    80003b26:	7aa080e7          	jalr	1962(ra) # 800032cc <bread>
    80003b2a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b2c:	05850593          	addi	a1,a0,88
    80003b30:	40dc                	lw	a5,4(s1)
    80003b32:	8bbd                	andi	a5,a5,15
    80003b34:	079a                	slli	a5,a5,0x6
    80003b36:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003b38:	00059783          	lh	a5,0(a1)
    80003b3c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003b40:	00259783          	lh	a5,2(a1)
    80003b44:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003b48:	00459783          	lh	a5,4(a1)
    80003b4c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003b50:	00659783          	lh	a5,6(a1)
    80003b54:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003b58:	459c                	lw	a5,8(a1)
    80003b5a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003b5c:	03400613          	li	a2,52
    80003b60:	05b1                	addi	a1,a1,12
    80003b62:	05048513          	addi	a0,s1,80
    80003b66:	ffffd097          	auipc	ra,0xffffd
    80003b6a:	1ce080e7          	jalr	462(ra) # 80000d34 <memmove>
    brelse(bp);
    80003b6e:	854a                	mv	a0,s2
    80003b70:	00000097          	auipc	ra,0x0
    80003b74:	88c080e7          	jalr	-1908(ra) # 800033fc <brelse>
    ip->valid = 1;
    80003b78:	4785                	li	a5,1
    80003b7a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003b7c:	04449783          	lh	a5,68(s1)
    80003b80:	fbb5                	bnez	a5,80003af4 <ilock+0x24>
      panic("ilock: no type");
    80003b82:	00005517          	auipc	a0,0x5
    80003b86:	b3e50513          	addi	a0,a0,-1218 # 800086c0 <syscalls+0x1a0>
    80003b8a:	ffffd097          	auipc	ra,0xffffd
    80003b8e:	9a4080e7          	jalr	-1628(ra) # 8000052e <panic>

0000000080003b92 <iunlock>:
{
    80003b92:	1101                	addi	sp,sp,-32
    80003b94:	ec06                	sd	ra,24(sp)
    80003b96:	e822                	sd	s0,16(sp)
    80003b98:	e426                	sd	s1,8(sp)
    80003b9a:	e04a                	sd	s2,0(sp)
    80003b9c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003b9e:	c905                	beqz	a0,80003bce <iunlock+0x3c>
    80003ba0:	84aa                	mv	s1,a0
    80003ba2:	01050913          	addi	s2,a0,16
    80003ba6:	854a                	mv	a0,s2
    80003ba8:	00001097          	auipc	ra,0x1
    80003bac:	c90080e7          	jalr	-880(ra) # 80004838 <holdingsleep>
    80003bb0:	cd19                	beqz	a0,80003bce <iunlock+0x3c>
    80003bb2:	449c                	lw	a5,8(s1)
    80003bb4:	00f05d63          	blez	a5,80003bce <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003bb8:	854a                	mv	a0,s2
    80003bba:	00001097          	auipc	ra,0x1
    80003bbe:	c3a080e7          	jalr	-966(ra) # 800047f4 <releasesleep>
}
    80003bc2:	60e2                	ld	ra,24(sp)
    80003bc4:	6442                	ld	s0,16(sp)
    80003bc6:	64a2                	ld	s1,8(sp)
    80003bc8:	6902                	ld	s2,0(sp)
    80003bca:	6105                	addi	sp,sp,32
    80003bcc:	8082                	ret
    panic("iunlock");
    80003bce:	00005517          	auipc	a0,0x5
    80003bd2:	b0250513          	addi	a0,a0,-1278 # 800086d0 <syscalls+0x1b0>
    80003bd6:	ffffd097          	auipc	ra,0xffffd
    80003bda:	958080e7          	jalr	-1704(ra) # 8000052e <panic>

0000000080003bde <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003bde:	7179                	addi	sp,sp,-48
    80003be0:	f406                	sd	ra,40(sp)
    80003be2:	f022                	sd	s0,32(sp)
    80003be4:	ec26                	sd	s1,24(sp)
    80003be6:	e84a                	sd	s2,16(sp)
    80003be8:	e44e                	sd	s3,8(sp)
    80003bea:	e052                	sd	s4,0(sp)
    80003bec:	1800                	addi	s0,sp,48
    80003bee:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003bf0:	05050493          	addi	s1,a0,80
    80003bf4:	08050913          	addi	s2,a0,128
    80003bf8:	a021                	j	80003c00 <itrunc+0x22>
    80003bfa:	0491                	addi	s1,s1,4
    80003bfc:	01248d63          	beq	s1,s2,80003c16 <itrunc+0x38>
    if(ip->addrs[i]){
    80003c00:	408c                	lw	a1,0(s1)
    80003c02:	dde5                	beqz	a1,80003bfa <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003c04:	0009a503          	lw	a0,0(s3)
    80003c08:	00000097          	auipc	ra,0x0
    80003c0c:	90a080e7          	jalr	-1782(ra) # 80003512 <bfree>
      ip->addrs[i] = 0;
    80003c10:	0004a023          	sw	zero,0(s1)
    80003c14:	b7dd                	j	80003bfa <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003c16:	0809a583          	lw	a1,128(s3)
    80003c1a:	e185                	bnez	a1,80003c3a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c1c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003c20:	854e                	mv	a0,s3
    80003c22:	00000097          	auipc	ra,0x0
    80003c26:	de4080e7          	jalr	-540(ra) # 80003a06 <iupdate>
}
    80003c2a:	70a2                	ld	ra,40(sp)
    80003c2c:	7402                	ld	s0,32(sp)
    80003c2e:	64e2                	ld	s1,24(sp)
    80003c30:	6942                	ld	s2,16(sp)
    80003c32:	69a2                	ld	s3,8(sp)
    80003c34:	6a02                	ld	s4,0(sp)
    80003c36:	6145                	addi	sp,sp,48
    80003c38:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c3a:	0009a503          	lw	a0,0(s3)
    80003c3e:	fffff097          	auipc	ra,0xfffff
    80003c42:	68e080e7          	jalr	1678(ra) # 800032cc <bread>
    80003c46:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003c48:	05850493          	addi	s1,a0,88
    80003c4c:	45850913          	addi	s2,a0,1112
    80003c50:	a021                	j	80003c58 <itrunc+0x7a>
    80003c52:	0491                	addi	s1,s1,4
    80003c54:	01248b63          	beq	s1,s2,80003c6a <itrunc+0x8c>
      if(a[j])
    80003c58:	408c                	lw	a1,0(s1)
    80003c5a:	dde5                	beqz	a1,80003c52 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003c5c:	0009a503          	lw	a0,0(s3)
    80003c60:	00000097          	auipc	ra,0x0
    80003c64:	8b2080e7          	jalr	-1870(ra) # 80003512 <bfree>
    80003c68:	b7ed                	j	80003c52 <itrunc+0x74>
    brelse(bp);
    80003c6a:	8552                	mv	a0,s4
    80003c6c:	fffff097          	auipc	ra,0xfffff
    80003c70:	790080e7          	jalr	1936(ra) # 800033fc <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003c74:	0809a583          	lw	a1,128(s3)
    80003c78:	0009a503          	lw	a0,0(s3)
    80003c7c:	00000097          	auipc	ra,0x0
    80003c80:	896080e7          	jalr	-1898(ra) # 80003512 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003c84:	0809a023          	sw	zero,128(s3)
    80003c88:	bf51                	j	80003c1c <itrunc+0x3e>

0000000080003c8a <iput>:
{
    80003c8a:	1101                	addi	sp,sp,-32
    80003c8c:	ec06                	sd	ra,24(sp)
    80003c8e:	e822                	sd	s0,16(sp)
    80003c90:	e426                	sd	s1,8(sp)
    80003c92:	e04a                	sd	s2,0(sp)
    80003c94:	1000                	addi	s0,sp,32
    80003c96:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c98:	00024517          	auipc	a0,0x24
    80003c9c:	13050513          	addi	a0,a0,304 # 80027dc8 <itable>
    80003ca0:	ffffd097          	auipc	ra,0xffffd
    80003ca4:	f26080e7          	jalr	-218(ra) # 80000bc6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ca8:	4498                	lw	a4,8(s1)
    80003caa:	4785                	li	a5,1
    80003cac:	02f70363          	beq	a4,a5,80003cd2 <iput+0x48>
  ip->ref--;
    80003cb0:	449c                	lw	a5,8(s1)
    80003cb2:	37fd                	addiw	a5,a5,-1
    80003cb4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003cb6:	00024517          	auipc	a0,0x24
    80003cba:	11250513          	addi	a0,a0,274 # 80027dc8 <itable>
    80003cbe:	ffffd097          	auipc	ra,0xffffd
    80003cc2:	fd2080e7          	jalr	-46(ra) # 80000c90 <release>
}
    80003cc6:	60e2                	ld	ra,24(sp)
    80003cc8:	6442                	ld	s0,16(sp)
    80003cca:	64a2                	ld	s1,8(sp)
    80003ccc:	6902                	ld	s2,0(sp)
    80003cce:	6105                	addi	sp,sp,32
    80003cd0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003cd2:	40bc                	lw	a5,64(s1)
    80003cd4:	dff1                	beqz	a5,80003cb0 <iput+0x26>
    80003cd6:	04a49783          	lh	a5,74(s1)
    80003cda:	fbf9                	bnez	a5,80003cb0 <iput+0x26>
    acquiresleep(&ip->lock);
    80003cdc:	01048913          	addi	s2,s1,16
    80003ce0:	854a                	mv	a0,s2
    80003ce2:	00001097          	auipc	ra,0x1
    80003ce6:	abc080e7          	jalr	-1348(ra) # 8000479e <acquiresleep>
    release(&itable.lock);
    80003cea:	00024517          	auipc	a0,0x24
    80003cee:	0de50513          	addi	a0,a0,222 # 80027dc8 <itable>
    80003cf2:	ffffd097          	auipc	ra,0xffffd
    80003cf6:	f9e080e7          	jalr	-98(ra) # 80000c90 <release>
    itrunc(ip);
    80003cfa:	8526                	mv	a0,s1
    80003cfc:	00000097          	auipc	ra,0x0
    80003d00:	ee2080e7          	jalr	-286(ra) # 80003bde <itrunc>
    ip->type = 0;
    80003d04:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003d08:	8526                	mv	a0,s1
    80003d0a:	00000097          	auipc	ra,0x0
    80003d0e:	cfc080e7          	jalr	-772(ra) # 80003a06 <iupdate>
    ip->valid = 0;
    80003d12:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003d16:	854a                	mv	a0,s2
    80003d18:	00001097          	auipc	ra,0x1
    80003d1c:	adc080e7          	jalr	-1316(ra) # 800047f4 <releasesleep>
    acquire(&itable.lock);
    80003d20:	00024517          	auipc	a0,0x24
    80003d24:	0a850513          	addi	a0,a0,168 # 80027dc8 <itable>
    80003d28:	ffffd097          	auipc	ra,0xffffd
    80003d2c:	e9e080e7          	jalr	-354(ra) # 80000bc6 <acquire>
    80003d30:	b741                	j	80003cb0 <iput+0x26>

0000000080003d32 <iunlockput>:
{
    80003d32:	1101                	addi	sp,sp,-32
    80003d34:	ec06                	sd	ra,24(sp)
    80003d36:	e822                	sd	s0,16(sp)
    80003d38:	e426                	sd	s1,8(sp)
    80003d3a:	1000                	addi	s0,sp,32
    80003d3c:	84aa                	mv	s1,a0
  iunlock(ip);
    80003d3e:	00000097          	auipc	ra,0x0
    80003d42:	e54080e7          	jalr	-428(ra) # 80003b92 <iunlock>
  iput(ip);
    80003d46:	8526                	mv	a0,s1
    80003d48:	00000097          	auipc	ra,0x0
    80003d4c:	f42080e7          	jalr	-190(ra) # 80003c8a <iput>
}
    80003d50:	60e2                	ld	ra,24(sp)
    80003d52:	6442                	ld	s0,16(sp)
    80003d54:	64a2                	ld	s1,8(sp)
    80003d56:	6105                	addi	sp,sp,32
    80003d58:	8082                	ret

0000000080003d5a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003d5a:	1141                	addi	sp,sp,-16
    80003d5c:	e422                	sd	s0,8(sp)
    80003d5e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d60:	411c                	lw	a5,0(a0)
    80003d62:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d64:	415c                	lw	a5,4(a0)
    80003d66:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d68:	04451783          	lh	a5,68(a0)
    80003d6c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d70:	04a51783          	lh	a5,74(a0)
    80003d74:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d78:	04c56783          	lwu	a5,76(a0)
    80003d7c:	e99c                	sd	a5,16(a1)
}
    80003d7e:	6422                	ld	s0,8(sp)
    80003d80:	0141                	addi	sp,sp,16
    80003d82:	8082                	ret

0000000080003d84 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d84:	457c                	lw	a5,76(a0)
    80003d86:	0ed7e963          	bltu	a5,a3,80003e78 <readi+0xf4>
{
    80003d8a:	7159                	addi	sp,sp,-112
    80003d8c:	f486                	sd	ra,104(sp)
    80003d8e:	f0a2                	sd	s0,96(sp)
    80003d90:	eca6                	sd	s1,88(sp)
    80003d92:	e8ca                	sd	s2,80(sp)
    80003d94:	e4ce                	sd	s3,72(sp)
    80003d96:	e0d2                	sd	s4,64(sp)
    80003d98:	fc56                	sd	s5,56(sp)
    80003d9a:	f85a                	sd	s6,48(sp)
    80003d9c:	f45e                	sd	s7,40(sp)
    80003d9e:	f062                	sd	s8,32(sp)
    80003da0:	ec66                	sd	s9,24(sp)
    80003da2:	e86a                	sd	s10,16(sp)
    80003da4:	e46e                	sd	s11,8(sp)
    80003da6:	1880                	addi	s0,sp,112
    80003da8:	8baa                	mv	s7,a0
    80003daa:	8c2e                	mv	s8,a1
    80003dac:	8ab2                	mv	s5,a2
    80003dae:	84b6                	mv	s1,a3
    80003db0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003db2:	9f35                	addw	a4,a4,a3
    return 0;
    80003db4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003db6:	0ad76063          	bltu	a4,a3,80003e56 <readi+0xd2>
  if(off + n > ip->size)
    80003dba:	00e7f463          	bgeu	a5,a4,80003dc2 <readi+0x3e>
    n = ip->size - off;
    80003dbe:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dc2:	0a0b0963          	beqz	s6,80003e74 <readi+0xf0>
    80003dc6:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dc8:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003dcc:	5cfd                	li	s9,-1
    80003dce:	a82d                	j	80003e08 <readi+0x84>
    80003dd0:	020a1d93          	slli	s11,s4,0x20
    80003dd4:	020ddd93          	srli	s11,s11,0x20
    80003dd8:	05890793          	addi	a5,s2,88
    80003ddc:	86ee                	mv	a3,s11
    80003dde:	963e                	add	a2,a2,a5
    80003de0:	85d6                	mv	a1,s5
    80003de2:	8562                	mv	a0,s8
    80003de4:	ffffe097          	auipc	ra,0xffffe
    80003de8:	768080e7          	jalr	1896(ra) # 8000254c <either_copyout>
    80003dec:	05950d63          	beq	a0,s9,80003e46 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003df0:	854a                	mv	a0,s2
    80003df2:	fffff097          	auipc	ra,0xfffff
    80003df6:	60a080e7          	jalr	1546(ra) # 800033fc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dfa:	013a09bb          	addw	s3,s4,s3
    80003dfe:	009a04bb          	addw	s1,s4,s1
    80003e02:	9aee                	add	s5,s5,s11
    80003e04:	0569f763          	bgeu	s3,s6,80003e52 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003e08:	000ba903          	lw	s2,0(s7)
    80003e0c:	00a4d59b          	srliw	a1,s1,0xa
    80003e10:	855e                	mv	a0,s7
    80003e12:	00000097          	auipc	ra,0x0
    80003e16:	8ae080e7          	jalr	-1874(ra) # 800036c0 <bmap>
    80003e1a:	0005059b          	sext.w	a1,a0
    80003e1e:	854a                	mv	a0,s2
    80003e20:	fffff097          	auipc	ra,0xfffff
    80003e24:	4ac080e7          	jalr	1196(ra) # 800032cc <bread>
    80003e28:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e2a:	3ff4f613          	andi	a2,s1,1023
    80003e2e:	40cd07bb          	subw	a5,s10,a2
    80003e32:	413b073b          	subw	a4,s6,s3
    80003e36:	8a3e                	mv	s4,a5
    80003e38:	2781                	sext.w	a5,a5
    80003e3a:	0007069b          	sext.w	a3,a4
    80003e3e:	f8f6f9e3          	bgeu	a3,a5,80003dd0 <readi+0x4c>
    80003e42:	8a3a                	mv	s4,a4
    80003e44:	b771                	j	80003dd0 <readi+0x4c>
      brelse(bp);
    80003e46:	854a                	mv	a0,s2
    80003e48:	fffff097          	auipc	ra,0xfffff
    80003e4c:	5b4080e7          	jalr	1460(ra) # 800033fc <brelse>
      tot = -1;
    80003e50:	59fd                	li	s3,-1
  }
  return tot;
    80003e52:	0009851b          	sext.w	a0,s3
}
    80003e56:	70a6                	ld	ra,104(sp)
    80003e58:	7406                	ld	s0,96(sp)
    80003e5a:	64e6                	ld	s1,88(sp)
    80003e5c:	6946                	ld	s2,80(sp)
    80003e5e:	69a6                	ld	s3,72(sp)
    80003e60:	6a06                	ld	s4,64(sp)
    80003e62:	7ae2                	ld	s5,56(sp)
    80003e64:	7b42                	ld	s6,48(sp)
    80003e66:	7ba2                	ld	s7,40(sp)
    80003e68:	7c02                	ld	s8,32(sp)
    80003e6a:	6ce2                	ld	s9,24(sp)
    80003e6c:	6d42                	ld	s10,16(sp)
    80003e6e:	6da2                	ld	s11,8(sp)
    80003e70:	6165                	addi	sp,sp,112
    80003e72:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e74:	89da                	mv	s3,s6
    80003e76:	bff1                	j	80003e52 <readi+0xce>
    return 0;
    80003e78:	4501                	li	a0,0
}
    80003e7a:	8082                	ret

0000000080003e7c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e7c:	457c                	lw	a5,76(a0)
    80003e7e:	10d7e863          	bltu	a5,a3,80003f8e <writei+0x112>
{
    80003e82:	7159                	addi	sp,sp,-112
    80003e84:	f486                	sd	ra,104(sp)
    80003e86:	f0a2                	sd	s0,96(sp)
    80003e88:	eca6                	sd	s1,88(sp)
    80003e8a:	e8ca                	sd	s2,80(sp)
    80003e8c:	e4ce                	sd	s3,72(sp)
    80003e8e:	e0d2                	sd	s4,64(sp)
    80003e90:	fc56                	sd	s5,56(sp)
    80003e92:	f85a                	sd	s6,48(sp)
    80003e94:	f45e                	sd	s7,40(sp)
    80003e96:	f062                	sd	s8,32(sp)
    80003e98:	ec66                	sd	s9,24(sp)
    80003e9a:	e86a                	sd	s10,16(sp)
    80003e9c:	e46e                	sd	s11,8(sp)
    80003e9e:	1880                	addi	s0,sp,112
    80003ea0:	8b2a                	mv	s6,a0
    80003ea2:	8c2e                	mv	s8,a1
    80003ea4:	8ab2                	mv	s5,a2
    80003ea6:	8936                	mv	s2,a3
    80003ea8:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003eaa:	00e687bb          	addw	a5,a3,a4
    80003eae:	0ed7e263          	bltu	a5,a3,80003f92 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003eb2:	00043737          	lui	a4,0x43
    80003eb6:	0ef76063          	bltu	a4,a5,80003f96 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003eba:	0c0b8863          	beqz	s7,80003f8a <writei+0x10e>
    80003ebe:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ec0:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ec4:	5cfd                	li	s9,-1
    80003ec6:	a091                	j	80003f0a <writei+0x8e>
    80003ec8:	02099d93          	slli	s11,s3,0x20
    80003ecc:	020ddd93          	srli	s11,s11,0x20
    80003ed0:	05848793          	addi	a5,s1,88
    80003ed4:	86ee                	mv	a3,s11
    80003ed6:	8656                	mv	a2,s5
    80003ed8:	85e2                	mv	a1,s8
    80003eda:	953e                	add	a0,a0,a5
    80003edc:	ffffe097          	auipc	ra,0xffffe
    80003ee0:	6c6080e7          	jalr	1734(ra) # 800025a2 <either_copyin>
    80003ee4:	07950263          	beq	a0,s9,80003f48 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ee8:	8526                	mv	a0,s1
    80003eea:	00000097          	auipc	ra,0x0
    80003eee:	794080e7          	jalr	1940(ra) # 8000467e <log_write>
    brelse(bp);
    80003ef2:	8526                	mv	a0,s1
    80003ef4:	fffff097          	auipc	ra,0xfffff
    80003ef8:	508080e7          	jalr	1288(ra) # 800033fc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003efc:	01498a3b          	addw	s4,s3,s4
    80003f00:	0129893b          	addw	s2,s3,s2
    80003f04:	9aee                	add	s5,s5,s11
    80003f06:	057a7663          	bgeu	s4,s7,80003f52 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003f0a:	000b2483          	lw	s1,0(s6)
    80003f0e:	00a9559b          	srliw	a1,s2,0xa
    80003f12:	855a                	mv	a0,s6
    80003f14:	fffff097          	auipc	ra,0xfffff
    80003f18:	7ac080e7          	jalr	1964(ra) # 800036c0 <bmap>
    80003f1c:	0005059b          	sext.w	a1,a0
    80003f20:	8526                	mv	a0,s1
    80003f22:	fffff097          	auipc	ra,0xfffff
    80003f26:	3aa080e7          	jalr	938(ra) # 800032cc <bread>
    80003f2a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f2c:	3ff97513          	andi	a0,s2,1023
    80003f30:	40ad07bb          	subw	a5,s10,a0
    80003f34:	414b873b          	subw	a4,s7,s4
    80003f38:	89be                	mv	s3,a5
    80003f3a:	2781                	sext.w	a5,a5
    80003f3c:	0007069b          	sext.w	a3,a4
    80003f40:	f8f6f4e3          	bgeu	a3,a5,80003ec8 <writei+0x4c>
    80003f44:	89ba                	mv	s3,a4
    80003f46:	b749                	j	80003ec8 <writei+0x4c>
      brelse(bp);
    80003f48:	8526                	mv	a0,s1
    80003f4a:	fffff097          	auipc	ra,0xfffff
    80003f4e:	4b2080e7          	jalr	1202(ra) # 800033fc <brelse>
  }

  if(off > ip->size)
    80003f52:	04cb2783          	lw	a5,76(s6)
    80003f56:	0127f463          	bgeu	a5,s2,80003f5e <writei+0xe2>
    ip->size = off;
    80003f5a:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003f5e:	855a                	mv	a0,s6
    80003f60:	00000097          	auipc	ra,0x0
    80003f64:	aa6080e7          	jalr	-1370(ra) # 80003a06 <iupdate>

  return tot;
    80003f68:	000a051b          	sext.w	a0,s4
}
    80003f6c:	70a6                	ld	ra,104(sp)
    80003f6e:	7406                	ld	s0,96(sp)
    80003f70:	64e6                	ld	s1,88(sp)
    80003f72:	6946                	ld	s2,80(sp)
    80003f74:	69a6                	ld	s3,72(sp)
    80003f76:	6a06                	ld	s4,64(sp)
    80003f78:	7ae2                	ld	s5,56(sp)
    80003f7a:	7b42                	ld	s6,48(sp)
    80003f7c:	7ba2                	ld	s7,40(sp)
    80003f7e:	7c02                	ld	s8,32(sp)
    80003f80:	6ce2                	ld	s9,24(sp)
    80003f82:	6d42                	ld	s10,16(sp)
    80003f84:	6da2                	ld	s11,8(sp)
    80003f86:	6165                	addi	sp,sp,112
    80003f88:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f8a:	8a5e                	mv	s4,s7
    80003f8c:	bfc9                	j	80003f5e <writei+0xe2>
    return -1;
    80003f8e:	557d                	li	a0,-1
}
    80003f90:	8082                	ret
    return -1;
    80003f92:	557d                	li	a0,-1
    80003f94:	bfe1                	j	80003f6c <writei+0xf0>
    return -1;
    80003f96:	557d                	li	a0,-1
    80003f98:	bfd1                	j	80003f6c <writei+0xf0>

0000000080003f9a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003f9a:	1141                	addi	sp,sp,-16
    80003f9c:	e406                	sd	ra,8(sp)
    80003f9e:	e022                	sd	s0,0(sp)
    80003fa0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003fa2:	4639                	li	a2,14
    80003fa4:	ffffd097          	auipc	ra,0xffffd
    80003fa8:	e0c080e7          	jalr	-500(ra) # 80000db0 <strncmp>
}
    80003fac:	60a2                	ld	ra,8(sp)
    80003fae:	6402                	ld	s0,0(sp)
    80003fb0:	0141                	addi	sp,sp,16
    80003fb2:	8082                	ret

0000000080003fb4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003fb4:	7139                	addi	sp,sp,-64
    80003fb6:	fc06                	sd	ra,56(sp)
    80003fb8:	f822                	sd	s0,48(sp)
    80003fba:	f426                	sd	s1,40(sp)
    80003fbc:	f04a                	sd	s2,32(sp)
    80003fbe:	ec4e                	sd	s3,24(sp)
    80003fc0:	e852                	sd	s4,16(sp)
    80003fc2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003fc4:	04451703          	lh	a4,68(a0)
    80003fc8:	4785                	li	a5,1
    80003fca:	00f71a63          	bne	a4,a5,80003fde <dirlookup+0x2a>
    80003fce:	892a                	mv	s2,a0
    80003fd0:	89ae                	mv	s3,a1
    80003fd2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fd4:	457c                	lw	a5,76(a0)
    80003fd6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003fd8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fda:	e79d                	bnez	a5,80004008 <dirlookup+0x54>
    80003fdc:	a8a5                	j	80004054 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003fde:	00004517          	auipc	a0,0x4
    80003fe2:	6fa50513          	addi	a0,a0,1786 # 800086d8 <syscalls+0x1b8>
    80003fe6:	ffffc097          	auipc	ra,0xffffc
    80003fea:	548080e7          	jalr	1352(ra) # 8000052e <panic>
      panic("dirlookup read");
    80003fee:	00004517          	auipc	a0,0x4
    80003ff2:	70250513          	addi	a0,a0,1794 # 800086f0 <syscalls+0x1d0>
    80003ff6:	ffffc097          	auipc	ra,0xffffc
    80003ffa:	538080e7          	jalr	1336(ra) # 8000052e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ffe:	24c1                	addiw	s1,s1,16
    80004000:	04c92783          	lw	a5,76(s2)
    80004004:	04f4f763          	bgeu	s1,a5,80004052 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004008:	4741                	li	a4,16
    8000400a:	86a6                	mv	a3,s1
    8000400c:	fc040613          	addi	a2,s0,-64
    80004010:	4581                	li	a1,0
    80004012:	854a                	mv	a0,s2
    80004014:	00000097          	auipc	ra,0x0
    80004018:	d70080e7          	jalr	-656(ra) # 80003d84 <readi>
    8000401c:	47c1                	li	a5,16
    8000401e:	fcf518e3          	bne	a0,a5,80003fee <dirlookup+0x3a>
    if(de.inum == 0)
    80004022:	fc045783          	lhu	a5,-64(s0)
    80004026:	dfe1                	beqz	a5,80003ffe <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004028:	fc240593          	addi	a1,s0,-62
    8000402c:	854e                	mv	a0,s3
    8000402e:	00000097          	auipc	ra,0x0
    80004032:	f6c080e7          	jalr	-148(ra) # 80003f9a <namecmp>
    80004036:	f561                	bnez	a0,80003ffe <dirlookup+0x4a>
      if(poff)
    80004038:	000a0463          	beqz	s4,80004040 <dirlookup+0x8c>
        *poff = off;
    8000403c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004040:	fc045583          	lhu	a1,-64(s0)
    80004044:	00092503          	lw	a0,0(s2)
    80004048:	fffff097          	auipc	ra,0xfffff
    8000404c:	754080e7          	jalr	1876(ra) # 8000379c <iget>
    80004050:	a011                	j	80004054 <dirlookup+0xa0>
  return 0;
    80004052:	4501                	li	a0,0
}
    80004054:	70e2                	ld	ra,56(sp)
    80004056:	7442                	ld	s0,48(sp)
    80004058:	74a2                	ld	s1,40(sp)
    8000405a:	7902                	ld	s2,32(sp)
    8000405c:	69e2                	ld	s3,24(sp)
    8000405e:	6a42                	ld	s4,16(sp)
    80004060:	6121                	addi	sp,sp,64
    80004062:	8082                	ret

0000000080004064 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004064:	711d                	addi	sp,sp,-96
    80004066:	ec86                	sd	ra,88(sp)
    80004068:	e8a2                	sd	s0,80(sp)
    8000406a:	e4a6                	sd	s1,72(sp)
    8000406c:	e0ca                	sd	s2,64(sp)
    8000406e:	fc4e                	sd	s3,56(sp)
    80004070:	f852                	sd	s4,48(sp)
    80004072:	f456                	sd	s5,40(sp)
    80004074:	f05a                	sd	s6,32(sp)
    80004076:	ec5e                	sd	s7,24(sp)
    80004078:	e862                	sd	s8,16(sp)
    8000407a:	e466                	sd	s9,8(sp)
    8000407c:	1080                	addi	s0,sp,96
    8000407e:	84aa                	mv	s1,a0
    80004080:	8aae                	mv	s5,a1
    80004082:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004084:	00054703          	lbu	a4,0(a0)
    80004088:	02f00793          	li	a5,47
    8000408c:	02f70363          	beq	a4,a5,800040b2 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004090:	ffffe097          	auipc	ra,0xffffe
    80004094:	908080e7          	jalr	-1784(ra) # 80001998 <myproc>
    80004098:	15053503          	ld	a0,336(a0)
    8000409c:	00000097          	auipc	ra,0x0
    800040a0:	9f6080e7          	jalr	-1546(ra) # 80003a92 <idup>
    800040a4:	89aa                	mv	s3,a0
  while(*path == '/')
    800040a6:	02f00913          	li	s2,47
  len = path - s;
    800040aa:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800040ac:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800040ae:	4b85                	li	s7,1
    800040b0:	a865                	j	80004168 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800040b2:	4585                	li	a1,1
    800040b4:	4505                	li	a0,1
    800040b6:	fffff097          	auipc	ra,0xfffff
    800040ba:	6e6080e7          	jalr	1766(ra) # 8000379c <iget>
    800040be:	89aa                	mv	s3,a0
    800040c0:	b7dd                	j	800040a6 <namex+0x42>
      iunlockput(ip);
    800040c2:	854e                	mv	a0,s3
    800040c4:	00000097          	auipc	ra,0x0
    800040c8:	c6e080e7          	jalr	-914(ra) # 80003d32 <iunlockput>
      return 0;
    800040cc:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800040ce:	854e                	mv	a0,s3
    800040d0:	60e6                	ld	ra,88(sp)
    800040d2:	6446                	ld	s0,80(sp)
    800040d4:	64a6                	ld	s1,72(sp)
    800040d6:	6906                	ld	s2,64(sp)
    800040d8:	79e2                	ld	s3,56(sp)
    800040da:	7a42                	ld	s4,48(sp)
    800040dc:	7aa2                	ld	s5,40(sp)
    800040de:	7b02                	ld	s6,32(sp)
    800040e0:	6be2                	ld	s7,24(sp)
    800040e2:	6c42                	ld	s8,16(sp)
    800040e4:	6ca2                	ld	s9,8(sp)
    800040e6:	6125                	addi	sp,sp,96
    800040e8:	8082                	ret
      iunlock(ip);
    800040ea:	854e                	mv	a0,s3
    800040ec:	00000097          	auipc	ra,0x0
    800040f0:	aa6080e7          	jalr	-1370(ra) # 80003b92 <iunlock>
      return ip;
    800040f4:	bfe9                	j	800040ce <namex+0x6a>
      iunlockput(ip);
    800040f6:	854e                	mv	a0,s3
    800040f8:	00000097          	auipc	ra,0x0
    800040fc:	c3a080e7          	jalr	-966(ra) # 80003d32 <iunlockput>
      return 0;
    80004100:	89e6                	mv	s3,s9
    80004102:	b7f1                	j	800040ce <namex+0x6a>
  len = path - s;
    80004104:	40b48633          	sub	a2,s1,a1
    80004108:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000410c:	099c5463          	bge	s8,s9,80004194 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004110:	4639                	li	a2,14
    80004112:	8552                	mv	a0,s4
    80004114:	ffffd097          	auipc	ra,0xffffd
    80004118:	c20080e7          	jalr	-992(ra) # 80000d34 <memmove>
  while(*path == '/')
    8000411c:	0004c783          	lbu	a5,0(s1)
    80004120:	01279763          	bne	a5,s2,8000412e <namex+0xca>
    path++;
    80004124:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004126:	0004c783          	lbu	a5,0(s1)
    8000412a:	ff278de3          	beq	a5,s2,80004124 <namex+0xc0>
    ilock(ip);
    8000412e:	854e                	mv	a0,s3
    80004130:	00000097          	auipc	ra,0x0
    80004134:	9a0080e7          	jalr	-1632(ra) # 80003ad0 <ilock>
    if(ip->type != T_DIR){
    80004138:	04499783          	lh	a5,68(s3)
    8000413c:	f97793e3          	bne	a5,s7,800040c2 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004140:	000a8563          	beqz	s5,8000414a <namex+0xe6>
    80004144:	0004c783          	lbu	a5,0(s1)
    80004148:	d3cd                	beqz	a5,800040ea <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000414a:	865a                	mv	a2,s6
    8000414c:	85d2                	mv	a1,s4
    8000414e:	854e                	mv	a0,s3
    80004150:	00000097          	auipc	ra,0x0
    80004154:	e64080e7          	jalr	-412(ra) # 80003fb4 <dirlookup>
    80004158:	8caa                	mv	s9,a0
    8000415a:	dd51                	beqz	a0,800040f6 <namex+0x92>
    iunlockput(ip);
    8000415c:	854e                	mv	a0,s3
    8000415e:	00000097          	auipc	ra,0x0
    80004162:	bd4080e7          	jalr	-1068(ra) # 80003d32 <iunlockput>
    ip = next;
    80004166:	89e6                	mv	s3,s9
  while(*path == '/')
    80004168:	0004c783          	lbu	a5,0(s1)
    8000416c:	05279763          	bne	a5,s2,800041ba <namex+0x156>
    path++;
    80004170:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004172:	0004c783          	lbu	a5,0(s1)
    80004176:	ff278de3          	beq	a5,s2,80004170 <namex+0x10c>
  if(*path == 0)
    8000417a:	c79d                	beqz	a5,800041a8 <namex+0x144>
    path++;
    8000417c:	85a6                	mv	a1,s1
  len = path - s;
    8000417e:	8cda                	mv	s9,s6
    80004180:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004182:	01278963          	beq	a5,s2,80004194 <namex+0x130>
    80004186:	dfbd                	beqz	a5,80004104 <namex+0xa0>
    path++;
    80004188:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000418a:	0004c783          	lbu	a5,0(s1)
    8000418e:	ff279ce3          	bne	a5,s2,80004186 <namex+0x122>
    80004192:	bf8d                	j	80004104 <namex+0xa0>
    memmove(name, s, len);
    80004194:	2601                	sext.w	a2,a2
    80004196:	8552                	mv	a0,s4
    80004198:	ffffd097          	auipc	ra,0xffffd
    8000419c:	b9c080e7          	jalr	-1124(ra) # 80000d34 <memmove>
    name[len] = 0;
    800041a0:	9cd2                	add	s9,s9,s4
    800041a2:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800041a6:	bf9d                	j	8000411c <namex+0xb8>
  if(nameiparent){
    800041a8:	f20a83e3          	beqz	s5,800040ce <namex+0x6a>
    iput(ip);
    800041ac:	854e                	mv	a0,s3
    800041ae:	00000097          	auipc	ra,0x0
    800041b2:	adc080e7          	jalr	-1316(ra) # 80003c8a <iput>
    return 0;
    800041b6:	4981                	li	s3,0
    800041b8:	bf19                	j	800040ce <namex+0x6a>
  if(*path == 0)
    800041ba:	d7fd                	beqz	a5,800041a8 <namex+0x144>
  while(*path != '/' && *path != 0)
    800041bc:	0004c783          	lbu	a5,0(s1)
    800041c0:	85a6                	mv	a1,s1
    800041c2:	b7d1                	j	80004186 <namex+0x122>

00000000800041c4 <dirlink>:
{
    800041c4:	7139                	addi	sp,sp,-64
    800041c6:	fc06                	sd	ra,56(sp)
    800041c8:	f822                	sd	s0,48(sp)
    800041ca:	f426                	sd	s1,40(sp)
    800041cc:	f04a                	sd	s2,32(sp)
    800041ce:	ec4e                	sd	s3,24(sp)
    800041d0:	e852                	sd	s4,16(sp)
    800041d2:	0080                	addi	s0,sp,64
    800041d4:	892a                	mv	s2,a0
    800041d6:	8a2e                	mv	s4,a1
    800041d8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800041da:	4601                	li	a2,0
    800041dc:	00000097          	auipc	ra,0x0
    800041e0:	dd8080e7          	jalr	-552(ra) # 80003fb4 <dirlookup>
    800041e4:	e93d                	bnez	a0,8000425a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041e6:	04c92483          	lw	s1,76(s2)
    800041ea:	c49d                	beqz	s1,80004218 <dirlink+0x54>
    800041ec:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041ee:	4741                	li	a4,16
    800041f0:	86a6                	mv	a3,s1
    800041f2:	fc040613          	addi	a2,s0,-64
    800041f6:	4581                	li	a1,0
    800041f8:	854a                	mv	a0,s2
    800041fa:	00000097          	auipc	ra,0x0
    800041fe:	b8a080e7          	jalr	-1142(ra) # 80003d84 <readi>
    80004202:	47c1                	li	a5,16
    80004204:	06f51163          	bne	a0,a5,80004266 <dirlink+0xa2>
    if(de.inum == 0)
    80004208:	fc045783          	lhu	a5,-64(s0)
    8000420c:	c791                	beqz	a5,80004218 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000420e:	24c1                	addiw	s1,s1,16
    80004210:	04c92783          	lw	a5,76(s2)
    80004214:	fcf4ede3          	bltu	s1,a5,800041ee <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004218:	4639                	li	a2,14
    8000421a:	85d2                	mv	a1,s4
    8000421c:	fc240513          	addi	a0,s0,-62
    80004220:	ffffd097          	auipc	ra,0xffffd
    80004224:	bcc080e7          	jalr	-1076(ra) # 80000dec <strncpy>
  de.inum = inum;
    80004228:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000422c:	4741                	li	a4,16
    8000422e:	86a6                	mv	a3,s1
    80004230:	fc040613          	addi	a2,s0,-64
    80004234:	4581                	li	a1,0
    80004236:	854a                	mv	a0,s2
    80004238:	00000097          	auipc	ra,0x0
    8000423c:	c44080e7          	jalr	-956(ra) # 80003e7c <writei>
    80004240:	872a                	mv	a4,a0
    80004242:	47c1                	li	a5,16
  return 0;
    80004244:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004246:	02f71863          	bne	a4,a5,80004276 <dirlink+0xb2>
}
    8000424a:	70e2                	ld	ra,56(sp)
    8000424c:	7442                	ld	s0,48(sp)
    8000424e:	74a2                	ld	s1,40(sp)
    80004250:	7902                	ld	s2,32(sp)
    80004252:	69e2                	ld	s3,24(sp)
    80004254:	6a42                	ld	s4,16(sp)
    80004256:	6121                	addi	sp,sp,64
    80004258:	8082                	ret
    iput(ip);
    8000425a:	00000097          	auipc	ra,0x0
    8000425e:	a30080e7          	jalr	-1488(ra) # 80003c8a <iput>
    return -1;
    80004262:	557d                	li	a0,-1
    80004264:	b7dd                	j	8000424a <dirlink+0x86>
      panic("dirlink read");
    80004266:	00004517          	auipc	a0,0x4
    8000426a:	49a50513          	addi	a0,a0,1178 # 80008700 <syscalls+0x1e0>
    8000426e:	ffffc097          	auipc	ra,0xffffc
    80004272:	2c0080e7          	jalr	704(ra) # 8000052e <panic>
    panic("dirlink");
    80004276:	00004517          	auipc	a0,0x4
    8000427a:	59a50513          	addi	a0,a0,1434 # 80008810 <syscalls+0x2f0>
    8000427e:	ffffc097          	auipc	ra,0xffffc
    80004282:	2b0080e7          	jalr	688(ra) # 8000052e <panic>

0000000080004286 <namei>:

struct inode*
namei(char *path)
{
    80004286:	1101                	addi	sp,sp,-32
    80004288:	ec06                	sd	ra,24(sp)
    8000428a:	e822                	sd	s0,16(sp)
    8000428c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000428e:	fe040613          	addi	a2,s0,-32
    80004292:	4581                	li	a1,0
    80004294:	00000097          	auipc	ra,0x0
    80004298:	dd0080e7          	jalr	-560(ra) # 80004064 <namex>
}
    8000429c:	60e2                	ld	ra,24(sp)
    8000429e:	6442                	ld	s0,16(sp)
    800042a0:	6105                	addi	sp,sp,32
    800042a2:	8082                	ret

00000000800042a4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800042a4:	1141                	addi	sp,sp,-16
    800042a6:	e406                	sd	ra,8(sp)
    800042a8:	e022                	sd	s0,0(sp)
    800042aa:	0800                	addi	s0,sp,16
    800042ac:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800042ae:	4585                	li	a1,1
    800042b0:	00000097          	auipc	ra,0x0
    800042b4:	db4080e7          	jalr	-588(ra) # 80004064 <namex>
}
    800042b8:	60a2                	ld	ra,8(sp)
    800042ba:	6402                	ld	s0,0(sp)
    800042bc:	0141                	addi	sp,sp,16
    800042be:	8082                	ret

00000000800042c0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800042c0:	1101                	addi	sp,sp,-32
    800042c2:	ec06                	sd	ra,24(sp)
    800042c4:	e822                	sd	s0,16(sp)
    800042c6:	e426                	sd	s1,8(sp)
    800042c8:	e04a                	sd	s2,0(sp)
    800042ca:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800042cc:	00025917          	auipc	s2,0x25
    800042d0:	5a490913          	addi	s2,s2,1444 # 80029870 <log>
    800042d4:	01892583          	lw	a1,24(s2)
    800042d8:	02892503          	lw	a0,40(s2)
    800042dc:	fffff097          	auipc	ra,0xfffff
    800042e0:	ff0080e7          	jalr	-16(ra) # 800032cc <bread>
    800042e4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800042e6:	02c92683          	lw	a3,44(s2)
    800042ea:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800042ec:	02d05863          	blez	a3,8000431c <write_head+0x5c>
    800042f0:	00025797          	auipc	a5,0x25
    800042f4:	5b078793          	addi	a5,a5,1456 # 800298a0 <log+0x30>
    800042f8:	05c50713          	addi	a4,a0,92
    800042fc:	36fd                	addiw	a3,a3,-1
    800042fe:	02069613          	slli	a2,a3,0x20
    80004302:	01e65693          	srli	a3,a2,0x1e
    80004306:	00025617          	auipc	a2,0x25
    8000430a:	59e60613          	addi	a2,a2,1438 # 800298a4 <log+0x34>
    8000430e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004310:	4390                	lw	a2,0(a5)
    80004312:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004314:	0791                	addi	a5,a5,4
    80004316:	0711                	addi	a4,a4,4
    80004318:	fed79ce3          	bne	a5,a3,80004310 <write_head+0x50>
  }
  bwrite(buf);
    8000431c:	8526                	mv	a0,s1
    8000431e:	fffff097          	auipc	ra,0xfffff
    80004322:	0a0080e7          	jalr	160(ra) # 800033be <bwrite>
  brelse(buf);
    80004326:	8526                	mv	a0,s1
    80004328:	fffff097          	auipc	ra,0xfffff
    8000432c:	0d4080e7          	jalr	212(ra) # 800033fc <brelse>
}
    80004330:	60e2                	ld	ra,24(sp)
    80004332:	6442                	ld	s0,16(sp)
    80004334:	64a2                	ld	s1,8(sp)
    80004336:	6902                	ld	s2,0(sp)
    80004338:	6105                	addi	sp,sp,32
    8000433a:	8082                	ret

000000008000433c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000433c:	00025797          	auipc	a5,0x25
    80004340:	5607a783          	lw	a5,1376(a5) # 8002989c <log+0x2c>
    80004344:	0af05d63          	blez	a5,800043fe <install_trans+0xc2>
{
    80004348:	7139                	addi	sp,sp,-64
    8000434a:	fc06                	sd	ra,56(sp)
    8000434c:	f822                	sd	s0,48(sp)
    8000434e:	f426                	sd	s1,40(sp)
    80004350:	f04a                	sd	s2,32(sp)
    80004352:	ec4e                	sd	s3,24(sp)
    80004354:	e852                	sd	s4,16(sp)
    80004356:	e456                	sd	s5,8(sp)
    80004358:	e05a                	sd	s6,0(sp)
    8000435a:	0080                	addi	s0,sp,64
    8000435c:	8b2a                	mv	s6,a0
    8000435e:	00025a97          	auipc	s5,0x25
    80004362:	542a8a93          	addi	s5,s5,1346 # 800298a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004366:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004368:	00025997          	auipc	s3,0x25
    8000436c:	50898993          	addi	s3,s3,1288 # 80029870 <log>
    80004370:	a00d                	j	80004392 <install_trans+0x56>
    brelse(lbuf);
    80004372:	854a                	mv	a0,s2
    80004374:	fffff097          	auipc	ra,0xfffff
    80004378:	088080e7          	jalr	136(ra) # 800033fc <brelse>
    brelse(dbuf);
    8000437c:	8526                	mv	a0,s1
    8000437e:	fffff097          	auipc	ra,0xfffff
    80004382:	07e080e7          	jalr	126(ra) # 800033fc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004386:	2a05                	addiw	s4,s4,1
    80004388:	0a91                	addi	s5,s5,4
    8000438a:	02c9a783          	lw	a5,44(s3)
    8000438e:	04fa5e63          	bge	s4,a5,800043ea <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004392:	0189a583          	lw	a1,24(s3)
    80004396:	014585bb          	addw	a1,a1,s4
    8000439a:	2585                	addiw	a1,a1,1
    8000439c:	0289a503          	lw	a0,40(s3)
    800043a0:	fffff097          	auipc	ra,0xfffff
    800043a4:	f2c080e7          	jalr	-212(ra) # 800032cc <bread>
    800043a8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800043aa:	000aa583          	lw	a1,0(s5)
    800043ae:	0289a503          	lw	a0,40(s3)
    800043b2:	fffff097          	auipc	ra,0xfffff
    800043b6:	f1a080e7          	jalr	-230(ra) # 800032cc <bread>
    800043ba:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800043bc:	40000613          	li	a2,1024
    800043c0:	05890593          	addi	a1,s2,88
    800043c4:	05850513          	addi	a0,a0,88
    800043c8:	ffffd097          	auipc	ra,0xffffd
    800043cc:	96c080e7          	jalr	-1684(ra) # 80000d34 <memmove>
    bwrite(dbuf);  // write dst to disk
    800043d0:	8526                	mv	a0,s1
    800043d2:	fffff097          	auipc	ra,0xfffff
    800043d6:	fec080e7          	jalr	-20(ra) # 800033be <bwrite>
    if(recovering == 0)
    800043da:	f80b1ce3          	bnez	s6,80004372 <install_trans+0x36>
      bunpin(dbuf);
    800043de:	8526                	mv	a0,s1
    800043e0:	fffff097          	auipc	ra,0xfffff
    800043e4:	0f6080e7          	jalr	246(ra) # 800034d6 <bunpin>
    800043e8:	b769                	j	80004372 <install_trans+0x36>
}
    800043ea:	70e2                	ld	ra,56(sp)
    800043ec:	7442                	ld	s0,48(sp)
    800043ee:	74a2                	ld	s1,40(sp)
    800043f0:	7902                	ld	s2,32(sp)
    800043f2:	69e2                	ld	s3,24(sp)
    800043f4:	6a42                	ld	s4,16(sp)
    800043f6:	6aa2                	ld	s5,8(sp)
    800043f8:	6b02                	ld	s6,0(sp)
    800043fa:	6121                	addi	sp,sp,64
    800043fc:	8082                	ret
    800043fe:	8082                	ret

0000000080004400 <initlog>:
{
    80004400:	7179                	addi	sp,sp,-48
    80004402:	f406                	sd	ra,40(sp)
    80004404:	f022                	sd	s0,32(sp)
    80004406:	ec26                	sd	s1,24(sp)
    80004408:	e84a                	sd	s2,16(sp)
    8000440a:	e44e                	sd	s3,8(sp)
    8000440c:	1800                	addi	s0,sp,48
    8000440e:	892a                	mv	s2,a0
    80004410:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004412:	00025497          	auipc	s1,0x25
    80004416:	45e48493          	addi	s1,s1,1118 # 80029870 <log>
    8000441a:	00004597          	auipc	a1,0x4
    8000441e:	2f658593          	addi	a1,a1,758 # 80008710 <syscalls+0x1f0>
    80004422:	8526                	mv	a0,s1
    80004424:	ffffc097          	auipc	ra,0xffffc
    80004428:	712080e7          	jalr	1810(ra) # 80000b36 <initlock>
  log.start = sb->logstart;
    8000442c:	0149a583          	lw	a1,20(s3)
    80004430:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004432:	0109a783          	lw	a5,16(s3)
    80004436:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004438:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000443c:	854a                	mv	a0,s2
    8000443e:	fffff097          	auipc	ra,0xfffff
    80004442:	e8e080e7          	jalr	-370(ra) # 800032cc <bread>
  log.lh.n = lh->n;
    80004446:	4d34                	lw	a3,88(a0)
    80004448:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000444a:	02d05663          	blez	a3,80004476 <initlog+0x76>
    8000444e:	05c50793          	addi	a5,a0,92
    80004452:	00025717          	auipc	a4,0x25
    80004456:	44e70713          	addi	a4,a4,1102 # 800298a0 <log+0x30>
    8000445a:	36fd                	addiw	a3,a3,-1
    8000445c:	02069613          	slli	a2,a3,0x20
    80004460:	01e65693          	srli	a3,a2,0x1e
    80004464:	06050613          	addi	a2,a0,96
    80004468:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000446a:	4390                	lw	a2,0(a5)
    8000446c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000446e:	0791                	addi	a5,a5,4
    80004470:	0711                	addi	a4,a4,4
    80004472:	fed79ce3          	bne	a5,a3,8000446a <initlog+0x6a>
  brelse(buf);
    80004476:	fffff097          	auipc	ra,0xfffff
    8000447a:	f86080e7          	jalr	-122(ra) # 800033fc <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000447e:	4505                	li	a0,1
    80004480:	00000097          	auipc	ra,0x0
    80004484:	ebc080e7          	jalr	-324(ra) # 8000433c <install_trans>
  log.lh.n = 0;
    80004488:	00025797          	auipc	a5,0x25
    8000448c:	4007aa23          	sw	zero,1044(a5) # 8002989c <log+0x2c>
  write_head(); // clear the log
    80004490:	00000097          	auipc	ra,0x0
    80004494:	e30080e7          	jalr	-464(ra) # 800042c0 <write_head>
}
    80004498:	70a2                	ld	ra,40(sp)
    8000449a:	7402                	ld	s0,32(sp)
    8000449c:	64e2                	ld	s1,24(sp)
    8000449e:	6942                	ld	s2,16(sp)
    800044a0:	69a2                	ld	s3,8(sp)
    800044a2:	6145                	addi	sp,sp,48
    800044a4:	8082                	ret

00000000800044a6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800044a6:	1101                	addi	sp,sp,-32
    800044a8:	ec06                	sd	ra,24(sp)
    800044aa:	e822                	sd	s0,16(sp)
    800044ac:	e426                	sd	s1,8(sp)
    800044ae:	e04a                	sd	s2,0(sp)
    800044b0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800044b2:	00025517          	auipc	a0,0x25
    800044b6:	3be50513          	addi	a0,a0,958 # 80029870 <log>
    800044ba:	ffffc097          	auipc	ra,0xffffc
    800044be:	70c080e7          	jalr	1804(ra) # 80000bc6 <acquire>
  while(1){
    if(log.committing){
    800044c2:	00025497          	auipc	s1,0x25
    800044c6:	3ae48493          	addi	s1,s1,942 # 80029870 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044ca:	4979                	li	s2,30
    800044cc:	a039                	j	800044da <begin_op+0x34>
      sleep(&log, &log.lock);
    800044ce:	85a6                	mv	a1,s1
    800044d0:	8526                	mv	a0,s1
    800044d2:	ffffe097          	auipc	ra,0xffffe
    800044d6:	c40080e7          	jalr	-960(ra) # 80002112 <sleep>
    if(log.committing){
    800044da:	50dc                	lw	a5,36(s1)
    800044dc:	fbed                	bnez	a5,800044ce <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044de:	509c                	lw	a5,32(s1)
    800044e0:	0017871b          	addiw	a4,a5,1
    800044e4:	0007069b          	sext.w	a3,a4
    800044e8:	0027179b          	slliw	a5,a4,0x2
    800044ec:	9fb9                	addw	a5,a5,a4
    800044ee:	0017979b          	slliw	a5,a5,0x1
    800044f2:	54d8                	lw	a4,44(s1)
    800044f4:	9fb9                	addw	a5,a5,a4
    800044f6:	00f95963          	bge	s2,a5,80004508 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800044fa:	85a6                	mv	a1,s1
    800044fc:	8526                	mv	a0,s1
    800044fe:	ffffe097          	auipc	ra,0xffffe
    80004502:	c14080e7          	jalr	-1004(ra) # 80002112 <sleep>
    80004506:	bfd1                	j	800044da <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004508:	00025517          	auipc	a0,0x25
    8000450c:	36850513          	addi	a0,a0,872 # 80029870 <log>
    80004510:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004512:	ffffc097          	auipc	ra,0xffffc
    80004516:	77e080e7          	jalr	1918(ra) # 80000c90 <release>
      break;
    }
  }
}
    8000451a:	60e2                	ld	ra,24(sp)
    8000451c:	6442                	ld	s0,16(sp)
    8000451e:	64a2                	ld	s1,8(sp)
    80004520:	6902                	ld	s2,0(sp)
    80004522:	6105                	addi	sp,sp,32
    80004524:	8082                	ret

0000000080004526 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004526:	7139                	addi	sp,sp,-64
    80004528:	fc06                	sd	ra,56(sp)
    8000452a:	f822                	sd	s0,48(sp)
    8000452c:	f426                	sd	s1,40(sp)
    8000452e:	f04a                	sd	s2,32(sp)
    80004530:	ec4e                	sd	s3,24(sp)
    80004532:	e852                	sd	s4,16(sp)
    80004534:	e456                	sd	s5,8(sp)
    80004536:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004538:	00025497          	auipc	s1,0x25
    8000453c:	33848493          	addi	s1,s1,824 # 80029870 <log>
    80004540:	8526                	mv	a0,s1
    80004542:	ffffc097          	auipc	ra,0xffffc
    80004546:	684080e7          	jalr	1668(ra) # 80000bc6 <acquire>
  log.outstanding -= 1;
    8000454a:	509c                	lw	a5,32(s1)
    8000454c:	37fd                	addiw	a5,a5,-1
    8000454e:	0007891b          	sext.w	s2,a5
    80004552:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004554:	50dc                	lw	a5,36(s1)
    80004556:	e7b9                	bnez	a5,800045a4 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004558:	04091e63          	bnez	s2,800045b4 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000455c:	00025497          	auipc	s1,0x25
    80004560:	31448493          	addi	s1,s1,788 # 80029870 <log>
    80004564:	4785                	li	a5,1
    80004566:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004568:	8526                	mv	a0,s1
    8000456a:	ffffc097          	auipc	ra,0xffffc
    8000456e:	726080e7          	jalr	1830(ra) # 80000c90 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004572:	54dc                	lw	a5,44(s1)
    80004574:	06f04763          	bgtz	a5,800045e2 <end_op+0xbc>
    acquire(&log.lock);
    80004578:	00025497          	auipc	s1,0x25
    8000457c:	2f848493          	addi	s1,s1,760 # 80029870 <log>
    80004580:	8526                	mv	a0,s1
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	644080e7          	jalr	1604(ra) # 80000bc6 <acquire>
    log.committing = 0;
    8000458a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000458e:	8526                	mv	a0,s1
    80004590:	ffffe097          	auipc	ra,0xffffe
    80004594:	d10080e7          	jalr	-752(ra) # 800022a0 <wakeup>
    release(&log.lock);
    80004598:	8526                	mv	a0,s1
    8000459a:	ffffc097          	auipc	ra,0xffffc
    8000459e:	6f6080e7          	jalr	1782(ra) # 80000c90 <release>
}
    800045a2:	a03d                	j	800045d0 <end_op+0xaa>
    panic("log.committing");
    800045a4:	00004517          	auipc	a0,0x4
    800045a8:	17450513          	addi	a0,a0,372 # 80008718 <syscalls+0x1f8>
    800045ac:	ffffc097          	auipc	ra,0xffffc
    800045b0:	f82080e7          	jalr	-126(ra) # 8000052e <panic>
    wakeup(&log);
    800045b4:	00025497          	auipc	s1,0x25
    800045b8:	2bc48493          	addi	s1,s1,700 # 80029870 <log>
    800045bc:	8526                	mv	a0,s1
    800045be:	ffffe097          	auipc	ra,0xffffe
    800045c2:	ce2080e7          	jalr	-798(ra) # 800022a0 <wakeup>
  release(&log.lock);
    800045c6:	8526                	mv	a0,s1
    800045c8:	ffffc097          	auipc	ra,0xffffc
    800045cc:	6c8080e7          	jalr	1736(ra) # 80000c90 <release>
}
    800045d0:	70e2                	ld	ra,56(sp)
    800045d2:	7442                	ld	s0,48(sp)
    800045d4:	74a2                	ld	s1,40(sp)
    800045d6:	7902                	ld	s2,32(sp)
    800045d8:	69e2                	ld	s3,24(sp)
    800045da:	6a42                	ld	s4,16(sp)
    800045dc:	6aa2                	ld	s5,8(sp)
    800045de:	6121                	addi	sp,sp,64
    800045e0:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800045e2:	00025a97          	auipc	s5,0x25
    800045e6:	2bea8a93          	addi	s5,s5,702 # 800298a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800045ea:	00025a17          	auipc	s4,0x25
    800045ee:	286a0a13          	addi	s4,s4,646 # 80029870 <log>
    800045f2:	018a2583          	lw	a1,24(s4)
    800045f6:	012585bb          	addw	a1,a1,s2
    800045fa:	2585                	addiw	a1,a1,1
    800045fc:	028a2503          	lw	a0,40(s4)
    80004600:	fffff097          	auipc	ra,0xfffff
    80004604:	ccc080e7          	jalr	-820(ra) # 800032cc <bread>
    80004608:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000460a:	000aa583          	lw	a1,0(s5)
    8000460e:	028a2503          	lw	a0,40(s4)
    80004612:	fffff097          	auipc	ra,0xfffff
    80004616:	cba080e7          	jalr	-838(ra) # 800032cc <bread>
    8000461a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000461c:	40000613          	li	a2,1024
    80004620:	05850593          	addi	a1,a0,88
    80004624:	05848513          	addi	a0,s1,88
    80004628:	ffffc097          	auipc	ra,0xffffc
    8000462c:	70c080e7          	jalr	1804(ra) # 80000d34 <memmove>
    bwrite(to);  // write the log
    80004630:	8526                	mv	a0,s1
    80004632:	fffff097          	auipc	ra,0xfffff
    80004636:	d8c080e7          	jalr	-628(ra) # 800033be <bwrite>
    brelse(from);
    8000463a:	854e                	mv	a0,s3
    8000463c:	fffff097          	auipc	ra,0xfffff
    80004640:	dc0080e7          	jalr	-576(ra) # 800033fc <brelse>
    brelse(to);
    80004644:	8526                	mv	a0,s1
    80004646:	fffff097          	auipc	ra,0xfffff
    8000464a:	db6080e7          	jalr	-586(ra) # 800033fc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000464e:	2905                	addiw	s2,s2,1
    80004650:	0a91                	addi	s5,s5,4
    80004652:	02ca2783          	lw	a5,44(s4)
    80004656:	f8f94ee3          	blt	s2,a5,800045f2 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000465a:	00000097          	auipc	ra,0x0
    8000465e:	c66080e7          	jalr	-922(ra) # 800042c0 <write_head>
    install_trans(0); // Now install writes to home locations
    80004662:	4501                	li	a0,0
    80004664:	00000097          	auipc	ra,0x0
    80004668:	cd8080e7          	jalr	-808(ra) # 8000433c <install_trans>
    log.lh.n = 0;
    8000466c:	00025797          	auipc	a5,0x25
    80004670:	2207a823          	sw	zero,560(a5) # 8002989c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004674:	00000097          	auipc	ra,0x0
    80004678:	c4c080e7          	jalr	-948(ra) # 800042c0 <write_head>
    8000467c:	bdf5                	j	80004578 <end_op+0x52>

000000008000467e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000467e:	1101                	addi	sp,sp,-32
    80004680:	ec06                	sd	ra,24(sp)
    80004682:	e822                	sd	s0,16(sp)
    80004684:	e426                	sd	s1,8(sp)
    80004686:	e04a                	sd	s2,0(sp)
    80004688:	1000                	addi	s0,sp,32
    8000468a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000468c:	00025917          	auipc	s2,0x25
    80004690:	1e490913          	addi	s2,s2,484 # 80029870 <log>
    80004694:	854a                	mv	a0,s2
    80004696:	ffffc097          	auipc	ra,0xffffc
    8000469a:	530080e7          	jalr	1328(ra) # 80000bc6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000469e:	02c92603          	lw	a2,44(s2)
    800046a2:	47f5                	li	a5,29
    800046a4:	06c7c563          	blt	a5,a2,8000470e <log_write+0x90>
    800046a8:	00025797          	auipc	a5,0x25
    800046ac:	1e47a783          	lw	a5,484(a5) # 8002988c <log+0x1c>
    800046b0:	37fd                	addiw	a5,a5,-1
    800046b2:	04f65e63          	bge	a2,a5,8000470e <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800046b6:	00025797          	auipc	a5,0x25
    800046ba:	1da7a783          	lw	a5,474(a5) # 80029890 <log+0x20>
    800046be:	06f05063          	blez	a5,8000471e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800046c2:	4781                	li	a5,0
    800046c4:	06c05563          	blez	a2,8000472e <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800046c8:	44cc                	lw	a1,12(s1)
    800046ca:	00025717          	auipc	a4,0x25
    800046ce:	1d670713          	addi	a4,a4,470 # 800298a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800046d2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800046d4:	4314                	lw	a3,0(a4)
    800046d6:	04b68c63          	beq	a3,a1,8000472e <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800046da:	2785                	addiw	a5,a5,1
    800046dc:	0711                	addi	a4,a4,4
    800046de:	fef61be3          	bne	a2,a5,800046d4 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800046e2:	0621                	addi	a2,a2,8
    800046e4:	060a                	slli	a2,a2,0x2
    800046e6:	00025797          	auipc	a5,0x25
    800046ea:	18a78793          	addi	a5,a5,394 # 80029870 <log>
    800046ee:	963e                	add	a2,a2,a5
    800046f0:	44dc                	lw	a5,12(s1)
    800046f2:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800046f4:	8526                	mv	a0,s1
    800046f6:	fffff097          	auipc	ra,0xfffff
    800046fa:	da4080e7          	jalr	-604(ra) # 8000349a <bpin>
    log.lh.n++;
    800046fe:	00025717          	auipc	a4,0x25
    80004702:	17270713          	addi	a4,a4,370 # 80029870 <log>
    80004706:	575c                	lw	a5,44(a4)
    80004708:	2785                	addiw	a5,a5,1
    8000470a:	d75c                	sw	a5,44(a4)
    8000470c:	a835                	j	80004748 <log_write+0xca>
    panic("too big a transaction");
    8000470e:	00004517          	auipc	a0,0x4
    80004712:	01a50513          	addi	a0,a0,26 # 80008728 <syscalls+0x208>
    80004716:	ffffc097          	auipc	ra,0xffffc
    8000471a:	e18080e7          	jalr	-488(ra) # 8000052e <panic>
    panic("log_write outside of trans");
    8000471e:	00004517          	auipc	a0,0x4
    80004722:	02250513          	addi	a0,a0,34 # 80008740 <syscalls+0x220>
    80004726:	ffffc097          	auipc	ra,0xffffc
    8000472a:	e08080e7          	jalr	-504(ra) # 8000052e <panic>
  log.lh.block[i] = b->blockno;
    8000472e:	00878713          	addi	a4,a5,8
    80004732:	00271693          	slli	a3,a4,0x2
    80004736:	00025717          	auipc	a4,0x25
    8000473a:	13a70713          	addi	a4,a4,314 # 80029870 <log>
    8000473e:	9736                	add	a4,a4,a3
    80004740:	44d4                	lw	a3,12(s1)
    80004742:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004744:	faf608e3          	beq	a2,a5,800046f4 <log_write+0x76>
  }
  release(&log.lock);
    80004748:	00025517          	auipc	a0,0x25
    8000474c:	12850513          	addi	a0,a0,296 # 80029870 <log>
    80004750:	ffffc097          	auipc	ra,0xffffc
    80004754:	540080e7          	jalr	1344(ra) # 80000c90 <release>
}
    80004758:	60e2                	ld	ra,24(sp)
    8000475a:	6442                	ld	s0,16(sp)
    8000475c:	64a2                	ld	s1,8(sp)
    8000475e:	6902                	ld	s2,0(sp)
    80004760:	6105                	addi	sp,sp,32
    80004762:	8082                	ret

0000000080004764 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004764:	1101                	addi	sp,sp,-32
    80004766:	ec06                	sd	ra,24(sp)
    80004768:	e822                	sd	s0,16(sp)
    8000476a:	e426                	sd	s1,8(sp)
    8000476c:	e04a                	sd	s2,0(sp)
    8000476e:	1000                	addi	s0,sp,32
    80004770:	84aa                	mv	s1,a0
    80004772:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004774:	00004597          	auipc	a1,0x4
    80004778:	fec58593          	addi	a1,a1,-20 # 80008760 <syscalls+0x240>
    8000477c:	0521                	addi	a0,a0,8
    8000477e:	ffffc097          	auipc	ra,0xffffc
    80004782:	3b8080e7          	jalr	952(ra) # 80000b36 <initlock>
  lk->name = name;
    80004786:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000478a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000478e:	0204a423          	sw	zero,40(s1)
}
    80004792:	60e2                	ld	ra,24(sp)
    80004794:	6442                	ld	s0,16(sp)
    80004796:	64a2                	ld	s1,8(sp)
    80004798:	6902                	ld	s2,0(sp)
    8000479a:	6105                	addi	sp,sp,32
    8000479c:	8082                	ret

000000008000479e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000479e:	1101                	addi	sp,sp,-32
    800047a0:	ec06                	sd	ra,24(sp)
    800047a2:	e822                	sd	s0,16(sp)
    800047a4:	e426                	sd	s1,8(sp)
    800047a6:	e04a                	sd	s2,0(sp)
    800047a8:	1000                	addi	s0,sp,32
    800047aa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047ac:	00850913          	addi	s2,a0,8
    800047b0:	854a                	mv	a0,s2
    800047b2:	ffffc097          	auipc	ra,0xffffc
    800047b6:	414080e7          	jalr	1044(ra) # 80000bc6 <acquire>
  while (lk->locked) {
    800047ba:	409c                	lw	a5,0(s1)
    800047bc:	cb89                	beqz	a5,800047ce <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800047be:	85ca                	mv	a1,s2
    800047c0:	8526                	mv	a0,s1
    800047c2:	ffffe097          	auipc	ra,0xffffe
    800047c6:	950080e7          	jalr	-1712(ra) # 80002112 <sleep>
  while (lk->locked) {
    800047ca:	409c                	lw	a5,0(s1)
    800047cc:	fbed                	bnez	a5,800047be <acquiresleep+0x20>
  }
  lk->locked = 1;
    800047ce:	4785                	li	a5,1
    800047d0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800047d2:	ffffd097          	auipc	ra,0xffffd
    800047d6:	1c6080e7          	jalr	454(ra) # 80001998 <myproc>
    800047da:	591c                	lw	a5,48(a0)
    800047dc:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800047de:	854a                	mv	a0,s2
    800047e0:	ffffc097          	auipc	ra,0xffffc
    800047e4:	4b0080e7          	jalr	1200(ra) # 80000c90 <release>
}
    800047e8:	60e2                	ld	ra,24(sp)
    800047ea:	6442                	ld	s0,16(sp)
    800047ec:	64a2                	ld	s1,8(sp)
    800047ee:	6902                	ld	s2,0(sp)
    800047f0:	6105                	addi	sp,sp,32
    800047f2:	8082                	ret

00000000800047f4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800047f4:	1101                	addi	sp,sp,-32
    800047f6:	ec06                	sd	ra,24(sp)
    800047f8:	e822                	sd	s0,16(sp)
    800047fa:	e426                	sd	s1,8(sp)
    800047fc:	e04a                	sd	s2,0(sp)
    800047fe:	1000                	addi	s0,sp,32
    80004800:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004802:	00850913          	addi	s2,a0,8
    80004806:	854a                	mv	a0,s2
    80004808:	ffffc097          	auipc	ra,0xffffc
    8000480c:	3be080e7          	jalr	958(ra) # 80000bc6 <acquire>
  lk->locked = 0;
    80004810:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004814:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004818:	8526                	mv	a0,s1
    8000481a:	ffffe097          	auipc	ra,0xffffe
    8000481e:	a86080e7          	jalr	-1402(ra) # 800022a0 <wakeup>
  release(&lk->lk);
    80004822:	854a                	mv	a0,s2
    80004824:	ffffc097          	auipc	ra,0xffffc
    80004828:	46c080e7          	jalr	1132(ra) # 80000c90 <release>
}
    8000482c:	60e2                	ld	ra,24(sp)
    8000482e:	6442                	ld	s0,16(sp)
    80004830:	64a2                	ld	s1,8(sp)
    80004832:	6902                	ld	s2,0(sp)
    80004834:	6105                	addi	sp,sp,32
    80004836:	8082                	ret

0000000080004838 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004838:	7179                	addi	sp,sp,-48
    8000483a:	f406                	sd	ra,40(sp)
    8000483c:	f022                	sd	s0,32(sp)
    8000483e:	ec26                	sd	s1,24(sp)
    80004840:	e84a                	sd	s2,16(sp)
    80004842:	e44e                	sd	s3,8(sp)
    80004844:	1800                	addi	s0,sp,48
    80004846:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004848:	00850913          	addi	s2,a0,8
    8000484c:	854a                	mv	a0,s2
    8000484e:	ffffc097          	auipc	ra,0xffffc
    80004852:	378080e7          	jalr	888(ra) # 80000bc6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004856:	409c                	lw	a5,0(s1)
    80004858:	ef99                	bnez	a5,80004876 <holdingsleep+0x3e>
    8000485a:	4481                	li	s1,0
  release(&lk->lk);
    8000485c:	854a                	mv	a0,s2
    8000485e:	ffffc097          	auipc	ra,0xffffc
    80004862:	432080e7          	jalr	1074(ra) # 80000c90 <release>
  return r;
}
    80004866:	8526                	mv	a0,s1
    80004868:	70a2                	ld	ra,40(sp)
    8000486a:	7402                	ld	s0,32(sp)
    8000486c:	64e2                	ld	s1,24(sp)
    8000486e:	6942                	ld	s2,16(sp)
    80004870:	69a2                	ld	s3,8(sp)
    80004872:	6145                	addi	sp,sp,48
    80004874:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004876:	0284a983          	lw	s3,40(s1)
    8000487a:	ffffd097          	auipc	ra,0xffffd
    8000487e:	11e080e7          	jalr	286(ra) # 80001998 <myproc>
    80004882:	5904                	lw	s1,48(a0)
    80004884:	413484b3          	sub	s1,s1,s3
    80004888:	0014b493          	seqz	s1,s1
    8000488c:	bfc1                	j	8000485c <holdingsleep+0x24>

000000008000488e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000488e:	1141                	addi	sp,sp,-16
    80004890:	e406                	sd	ra,8(sp)
    80004892:	e022                	sd	s0,0(sp)
    80004894:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004896:	00004597          	auipc	a1,0x4
    8000489a:	eda58593          	addi	a1,a1,-294 # 80008770 <syscalls+0x250>
    8000489e:	00025517          	auipc	a0,0x25
    800048a2:	11a50513          	addi	a0,a0,282 # 800299b8 <ftable>
    800048a6:	ffffc097          	auipc	ra,0xffffc
    800048aa:	290080e7          	jalr	656(ra) # 80000b36 <initlock>
}
    800048ae:	60a2                	ld	ra,8(sp)
    800048b0:	6402                	ld	s0,0(sp)
    800048b2:	0141                	addi	sp,sp,16
    800048b4:	8082                	ret

00000000800048b6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800048b6:	1101                	addi	sp,sp,-32
    800048b8:	ec06                	sd	ra,24(sp)
    800048ba:	e822                	sd	s0,16(sp)
    800048bc:	e426                	sd	s1,8(sp)
    800048be:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800048c0:	00025517          	auipc	a0,0x25
    800048c4:	0f850513          	addi	a0,a0,248 # 800299b8 <ftable>
    800048c8:	ffffc097          	auipc	ra,0xffffc
    800048cc:	2fe080e7          	jalr	766(ra) # 80000bc6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048d0:	00025497          	auipc	s1,0x25
    800048d4:	10048493          	addi	s1,s1,256 # 800299d0 <ftable+0x18>
    800048d8:	00026717          	auipc	a4,0x26
    800048dc:	09870713          	addi	a4,a4,152 # 8002a970 <ftable+0xfb8>
    if(f->ref == 0){
    800048e0:	40dc                	lw	a5,4(s1)
    800048e2:	cf99                	beqz	a5,80004900 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048e4:	02848493          	addi	s1,s1,40
    800048e8:	fee49ce3          	bne	s1,a4,800048e0 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800048ec:	00025517          	auipc	a0,0x25
    800048f0:	0cc50513          	addi	a0,a0,204 # 800299b8 <ftable>
    800048f4:	ffffc097          	auipc	ra,0xffffc
    800048f8:	39c080e7          	jalr	924(ra) # 80000c90 <release>
  return 0;
    800048fc:	4481                	li	s1,0
    800048fe:	a819                	j	80004914 <filealloc+0x5e>
      f->ref = 1;
    80004900:	4785                	li	a5,1
    80004902:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004904:	00025517          	auipc	a0,0x25
    80004908:	0b450513          	addi	a0,a0,180 # 800299b8 <ftable>
    8000490c:	ffffc097          	auipc	ra,0xffffc
    80004910:	384080e7          	jalr	900(ra) # 80000c90 <release>
}
    80004914:	8526                	mv	a0,s1
    80004916:	60e2                	ld	ra,24(sp)
    80004918:	6442                	ld	s0,16(sp)
    8000491a:	64a2                	ld	s1,8(sp)
    8000491c:	6105                	addi	sp,sp,32
    8000491e:	8082                	ret

0000000080004920 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004920:	1101                	addi	sp,sp,-32
    80004922:	ec06                	sd	ra,24(sp)
    80004924:	e822                	sd	s0,16(sp)
    80004926:	e426                	sd	s1,8(sp)
    80004928:	1000                	addi	s0,sp,32
    8000492a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000492c:	00025517          	auipc	a0,0x25
    80004930:	08c50513          	addi	a0,a0,140 # 800299b8 <ftable>
    80004934:	ffffc097          	auipc	ra,0xffffc
    80004938:	292080e7          	jalr	658(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    8000493c:	40dc                	lw	a5,4(s1)
    8000493e:	02f05263          	blez	a5,80004962 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004942:	2785                	addiw	a5,a5,1
    80004944:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004946:	00025517          	auipc	a0,0x25
    8000494a:	07250513          	addi	a0,a0,114 # 800299b8 <ftable>
    8000494e:	ffffc097          	auipc	ra,0xffffc
    80004952:	342080e7          	jalr	834(ra) # 80000c90 <release>
  return f;
}
    80004956:	8526                	mv	a0,s1
    80004958:	60e2                	ld	ra,24(sp)
    8000495a:	6442                	ld	s0,16(sp)
    8000495c:	64a2                	ld	s1,8(sp)
    8000495e:	6105                	addi	sp,sp,32
    80004960:	8082                	ret
    panic("filedup");
    80004962:	00004517          	auipc	a0,0x4
    80004966:	e1650513          	addi	a0,a0,-490 # 80008778 <syscalls+0x258>
    8000496a:	ffffc097          	auipc	ra,0xffffc
    8000496e:	bc4080e7          	jalr	-1084(ra) # 8000052e <panic>

0000000080004972 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004972:	7139                	addi	sp,sp,-64
    80004974:	fc06                	sd	ra,56(sp)
    80004976:	f822                	sd	s0,48(sp)
    80004978:	f426                	sd	s1,40(sp)
    8000497a:	f04a                	sd	s2,32(sp)
    8000497c:	ec4e                	sd	s3,24(sp)
    8000497e:	e852                	sd	s4,16(sp)
    80004980:	e456                	sd	s5,8(sp)
    80004982:	0080                	addi	s0,sp,64
    80004984:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004986:	00025517          	auipc	a0,0x25
    8000498a:	03250513          	addi	a0,a0,50 # 800299b8 <ftable>
    8000498e:	ffffc097          	auipc	ra,0xffffc
    80004992:	238080e7          	jalr	568(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    80004996:	40dc                	lw	a5,4(s1)
    80004998:	06f05163          	blez	a5,800049fa <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000499c:	37fd                	addiw	a5,a5,-1
    8000499e:	0007871b          	sext.w	a4,a5
    800049a2:	c0dc                	sw	a5,4(s1)
    800049a4:	06e04363          	bgtz	a4,80004a0a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800049a8:	0004a903          	lw	s2,0(s1)
    800049ac:	0094ca83          	lbu	s5,9(s1)
    800049b0:	0104ba03          	ld	s4,16(s1)
    800049b4:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800049b8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800049bc:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800049c0:	00025517          	auipc	a0,0x25
    800049c4:	ff850513          	addi	a0,a0,-8 # 800299b8 <ftable>
    800049c8:	ffffc097          	auipc	ra,0xffffc
    800049cc:	2c8080e7          	jalr	712(ra) # 80000c90 <release>

  if(ff.type == FD_PIPE){
    800049d0:	4785                	li	a5,1
    800049d2:	04f90d63          	beq	s2,a5,80004a2c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800049d6:	3979                	addiw	s2,s2,-2
    800049d8:	4785                	li	a5,1
    800049da:	0527e063          	bltu	a5,s2,80004a1a <fileclose+0xa8>
    begin_op();
    800049de:	00000097          	auipc	ra,0x0
    800049e2:	ac8080e7          	jalr	-1336(ra) # 800044a6 <begin_op>
    iput(ff.ip);
    800049e6:	854e                	mv	a0,s3
    800049e8:	fffff097          	auipc	ra,0xfffff
    800049ec:	2a2080e7          	jalr	674(ra) # 80003c8a <iput>
    end_op();
    800049f0:	00000097          	auipc	ra,0x0
    800049f4:	b36080e7          	jalr	-1226(ra) # 80004526 <end_op>
    800049f8:	a00d                	j	80004a1a <fileclose+0xa8>
    panic("fileclose");
    800049fa:	00004517          	auipc	a0,0x4
    800049fe:	d8650513          	addi	a0,a0,-634 # 80008780 <syscalls+0x260>
    80004a02:	ffffc097          	auipc	ra,0xffffc
    80004a06:	b2c080e7          	jalr	-1236(ra) # 8000052e <panic>
    release(&ftable.lock);
    80004a0a:	00025517          	auipc	a0,0x25
    80004a0e:	fae50513          	addi	a0,a0,-82 # 800299b8 <ftable>
    80004a12:	ffffc097          	auipc	ra,0xffffc
    80004a16:	27e080e7          	jalr	638(ra) # 80000c90 <release>
  }
}
    80004a1a:	70e2                	ld	ra,56(sp)
    80004a1c:	7442                	ld	s0,48(sp)
    80004a1e:	74a2                	ld	s1,40(sp)
    80004a20:	7902                	ld	s2,32(sp)
    80004a22:	69e2                	ld	s3,24(sp)
    80004a24:	6a42                	ld	s4,16(sp)
    80004a26:	6aa2                	ld	s5,8(sp)
    80004a28:	6121                	addi	sp,sp,64
    80004a2a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a2c:	85d6                	mv	a1,s5
    80004a2e:	8552                	mv	a0,s4
    80004a30:	00000097          	auipc	ra,0x0
    80004a34:	34c080e7          	jalr	844(ra) # 80004d7c <pipeclose>
    80004a38:	b7cd                	j	80004a1a <fileclose+0xa8>

0000000080004a3a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a3a:	715d                	addi	sp,sp,-80
    80004a3c:	e486                	sd	ra,72(sp)
    80004a3e:	e0a2                	sd	s0,64(sp)
    80004a40:	fc26                	sd	s1,56(sp)
    80004a42:	f84a                	sd	s2,48(sp)
    80004a44:	f44e                	sd	s3,40(sp)
    80004a46:	0880                	addi	s0,sp,80
    80004a48:	84aa                	mv	s1,a0
    80004a4a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a4c:	ffffd097          	auipc	ra,0xffffd
    80004a50:	f4c080e7          	jalr	-180(ra) # 80001998 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a54:	409c                	lw	a5,0(s1)
    80004a56:	37f9                	addiw	a5,a5,-2
    80004a58:	4705                	li	a4,1
    80004a5a:	04f76763          	bltu	a4,a5,80004aa8 <filestat+0x6e>
    80004a5e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004a60:	6c88                	ld	a0,24(s1)
    80004a62:	fffff097          	auipc	ra,0xfffff
    80004a66:	06e080e7          	jalr	110(ra) # 80003ad0 <ilock>
    stati(f->ip, &st);
    80004a6a:	fb840593          	addi	a1,s0,-72
    80004a6e:	6c88                	ld	a0,24(s1)
    80004a70:	fffff097          	auipc	ra,0xfffff
    80004a74:	2ea080e7          	jalr	746(ra) # 80003d5a <stati>
    iunlock(f->ip);
    80004a78:	6c88                	ld	a0,24(s1)
    80004a7a:	fffff097          	auipc	ra,0xfffff
    80004a7e:	118080e7          	jalr	280(ra) # 80003b92 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a82:	46e1                	li	a3,24
    80004a84:	fb840613          	addi	a2,s0,-72
    80004a88:	85ce                	mv	a1,s3
    80004a8a:	05093503          	ld	a0,80(s2)
    80004a8e:	ffffd097          	auipc	ra,0xffffd
    80004a92:	bca080e7          	jalr	-1078(ra) # 80001658 <copyout>
    80004a96:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004a9a:	60a6                	ld	ra,72(sp)
    80004a9c:	6406                	ld	s0,64(sp)
    80004a9e:	74e2                	ld	s1,56(sp)
    80004aa0:	7942                	ld	s2,48(sp)
    80004aa2:	79a2                	ld	s3,40(sp)
    80004aa4:	6161                	addi	sp,sp,80
    80004aa6:	8082                	ret
  return -1;
    80004aa8:	557d                	li	a0,-1
    80004aaa:	bfc5                	j	80004a9a <filestat+0x60>

0000000080004aac <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004aac:	7179                	addi	sp,sp,-48
    80004aae:	f406                	sd	ra,40(sp)
    80004ab0:	f022                	sd	s0,32(sp)
    80004ab2:	ec26                	sd	s1,24(sp)
    80004ab4:	e84a                	sd	s2,16(sp)
    80004ab6:	e44e                	sd	s3,8(sp)
    80004ab8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004aba:	00854783          	lbu	a5,8(a0)
    80004abe:	c3d5                	beqz	a5,80004b62 <fileread+0xb6>
    80004ac0:	84aa                	mv	s1,a0
    80004ac2:	89ae                	mv	s3,a1
    80004ac4:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ac6:	411c                	lw	a5,0(a0)
    80004ac8:	4705                	li	a4,1
    80004aca:	04e78963          	beq	a5,a4,80004b1c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ace:	470d                	li	a4,3
    80004ad0:	04e78d63          	beq	a5,a4,80004b2a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ad4:	4709                	li	a4,2
    80004ad6:	06e79e63          	bne	a5,a4,80004b52 <fileread+0xa6>
    ilock(f->ip);
    80004ada:	6d08                	ld	a0,24(a0)
    80004adc:	fffff097          	auipc	ra,0xfffff
    80004ae0:	ff4080e7          	jalr	-12(ra) # 80003ad0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004ae4:	874a                	mv	a4,s2
    80004ae6:	5094                	lw	a3,32(s1)
    80004ae8:	864e                	mv	a2,s3
    80004aea:	4585                	li	a1,1
    80004aec:	6c88                	ld	a0,24(s1)
    80004aee:	fffff097          	auipc	ra,0xfffff
    80004af2:	296080e7          	jalr	662(ra) # 80003d84 <readi>
    80004af6:	892a                	mv	s2,a0
    80004af8:	00a05563          	blez	a0,80004b02 <fileread+0x56>
      f->off += r;
    80004afc:	509c                	lw	a5,32(s1)
    80004afe:	9fa9                	addw	a5,a5,a0
    80004b00:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b02:	6c88                	ld	a0,24(s1)
    80004b04:	fffff097          	auipc	ra,0xfffff
    80004b08:	08e080e7          	jalr	142(ra) # 80003b92 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004b0c:	854a                	mv	a0,s2
    80004b0e:	70a2                	ld	ra,40(sp)
    80004b10:	7402                	ld	s0,32(sp)
    80004b12:	64e2                	ld	s1,24(sp)
    80004b14:	6942                	ld	s2,16(sp)
    80004b16:	69a2                	ld	s3,8(sp)
    80004b18:	6145                	addi	sp,sp,48
    80004b1a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b1c:	6908                	ld	a0,16(a0)
    80004b1e:	00000097          	auipc	ra,0x0
    80004b22:	3c8080e7          	jalr	968(ra) # 80004ee6 <piperead>
    80004b26:	892a                	mv	s2,a0
    80004b28:	b7d5                	j	80004b0c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b2a:	02451783          	lh	a5,36(a0)
    80004b2e:	03079693          	slli	a3,a5,0x30
    80004b32:	92c1                	srli	a3,a3,0x30
    80004b34:	4725                	li	a4,9
    80004b36:	02d76863          	bltu	a4,a3,80004b66 <fileread+0xba>
    80004b3a:	0792                	slli	a5,a5,0x4
    80004b3c:	00025717          	auipc	a4,0x25
    80004b40:	ddc70713          	addi	a4,a4,-548 # 80029918 <devsw>
    80004b44:	97ba                	add	a5,a5,a4
    80004b46:	639c                	ld	a5,0(a5)
    80004b48:	c38d                	beqz	a5,80004b6a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004b4a:	4505                	li	a0,1
    80004b4c:	9782                	jalr	a5
    80004b4e:	892a                	mv	s2,a0
    80004b50:	bf75                	j	80004b0c <fileread+0x60>
    panic("fileread");
    80004b52:	00004517          	auipc	a0,0x4
    80004b56:	c3e50513          	addi	a0,a0,-962 # 80008790 <syscalls+0x270>
    80004b5a:	ffffc097          	auipc	ra,0xffffc
    80004b5e:	9d4080e7          	jalr	-1580(ra) # 8000052e <panic>
    return -1;
    80004b62:	597d                	li	s2,-1
    80004b64:	b765                	j	80004b0c <fileread+0x60>
      return -1;
    80004b66:	597d                	li	s2,-1
    80004b68:	b755                	j	80004b0c <fileread+0x60>
    80004b6a:	597d                	li	s2,-1
    80004b6c:	b745                	j	80004b0c <fileread+0x60>

0000000080004b6e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004b6e:	715d                	addi	sp,sp,-80
    80004b70:	e486                	sd	ra,72(sp)
    80004b72:	e0a2                	sd	s0,64(sp)
    80004b74:	fc26                	sd	s1,56(sp)
    80004b76:	f84a                	sd	s2,48(sp)
    80004b78:	f44e                	sd	s3,40(sp)
    80004b7a:	f052                	sd	s4,32(sp)
    80004b7c:	ec56                	sd	s5,24(sp)
    80004b7e:	e85a                	sd	s6,16(sp)
    80004b80:	e45e                	sd	s7,8(sp)
    80004b82:	e062                	sd	s8,0(sp)
    80004b84:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004b86:	00954783          	lbu	a5,9(a0)
    80004b8a:	10078663          	beqz	a5,80004c96 <filewrite+0x128>
    80004b8e:	892a                	mv	s2,a0
    80004b90:	8aae                	mv	s5,a1
    80004b92:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b94:	411c                	lw	a5,0(a0)
    80004b96:	4705                	li	a4,1
    80004b98:	02e78263          	beq	a5,a4,80004bbc <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b9c:	470d                	li	a4,3
    80004b9e:	02e78663          	beq	a5,a4,80004bca <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ba2:	4709                	li	a4,2
    80004ba4:	0ee79163          	bne	a5,a4,80004c86 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004ba8:	0ac05d63          	blez	a2,80004c62 <filewrite+0xf4>
    int i = 0;
    80004bac:	4981                	li	s3,0
    80004bae:	6b05                	lui	s6,0x1
    80004bb0:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004bb4:	6b85                	lui	s7,0x1
    80004bb6:	c00b8b9b          	addiw	s7,s7,-1024
    80004bba:	a861                	j	80004c52 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004bbc:	6908                	ld	a0,16(a0)
    80004bbe:	00000097          	auipc	ra,0x0
    80004bc2:	22e080e7          	jalr	558(ra) # 80004dec <pipewrite>
    80004bc6:	8a2a                	mv	s4,a0
    80004bc8:	a045                	j	80004c68 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004bca:	02451783          	lh	a5,36(a0)
    80004bce:	03079693          	slli	a3,a5,0x30
    80004bd2:	92c1                	srli	a3,a3,0x30
    80004bd4:	4725                	li	a4,9
    80004bd6:	0cd76263          	bltu	a4,a3,80004c9a <filewrite+0x12c>
    80004bda:	0792                	slli	a5,a5,0x4
    80004bdc:	00025717          	auipc	a4,0x25
    80004be0:	d3c70713          	addi	a4,a4,-708 # 80029918 <devsw>
    80004be4:	97ba                	add	a5,a5,a4
    80004be6:	679c                	ld	a5,8(a5)
    80004be8:	cbdd                	beqz	a5,80004c9e <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004bea:	4505                	li	a0,1
    80004bec:	9782                	jalr	a5
    80004bee:	8a2a                	mv	s4,a0
    80004bf0:	a8a5                	j	80004c68 <filewrite+0xfa>
    80004bf2:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004bf6:	00000097          	auipc	ra,0x0
    80004bfa:	8b0080e7          	jalr	-1872(ra) # 800044a6 <begin_op>
      ilock(f->ip);
    80004bfe:	01893503          	ld	a0,24(s2)
    80004c02:	fffff097          	auipc	ra,0xfffff
    80004c06:	ece080e7          	jalr	-306(ra) # 80003ad0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c0a:	8762                	mv	a4,s8
    80004c0c:	02092683          	lw	a3,32(s2)
    80004c10:	01598633          	add	a2,s3,s5
    80004c14:	4585                	li	a1,1
    80004c16:	01893503          	ld	a0,24(s2)
    80004c1a:	fffff097          	auipc	ra,0xfffff
    80004c1e:	262080e7          	jalr	610(ra) # 80003e7c <writei>
    80004c22:	84aa                	mv	s1,a0
    80004c24:	00a05763          	blez	a0,80004c32 <filewrite+0xc4>
        f->off += r;
    80004c28:	02092783          	lw	a5,32(s2)
    80004c2c:	9fa9                	addw	a5,a5,a0
    80004c2e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c32:	01893503          	ld	a0,24(s2)
    80004c36:	fffff097          	auipc	ra,0xfffff
    80004c3a:	f5c080e7          	jalr	-164(ra) # 80003b92 <iunlock>
      end_op();
    80004c3e:	00000097          	auipc	ra,0x0
    80004c42:	8e8080e7          	jalr	-1816(ra) # 80004526 <end_op>

      if(r != n1){
    80004c46:	009c1f63          	bne	s8,s1,80004c64 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004c4a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004c4e:	0149db63          	bge	s3,s4,80004c64 <filewrite+0xf6>
      int n1 = n - i;
    80004c52:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004c56:	84be                	mv	s1,a5
    80004c58:	2781                	sext.w	a5,a5
    80004c5a:	f8fb5ce3          	bge	s6,a5,80004bf2 <filewrite+0x84>
    80004c5e:	84de                	mv	s1,s7
    80004c60:	bf49                	j	80004bf2 <filewrite+0x84>
    int i = 0;
    80004c62:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004c64:	013a1f63          	bne	s4,s3,80004c82 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c68:	8552                	mv	a0,s4
    80004c6a:	60a6                	ld	ra,72(sp)
    80004c6c:	6406                	ld	s0,64(sp)
    80004c6e:	74e2                	ld	s1,56(sp)
    80004c70:	7942                	ld	s2,48(sp)
    80004c72:	79a2                	ld	s3,40(sp)
    80004c74:	7a02                	ld	s4,32(sp)
    80004c76:	6ae2                	ld	s5,24(sp)
    80004c78:	6b42                	ld	s6,16(sp)
    80004c7a:	6ba2                	ld	s7,8(sp)
    80004c7c:	6c02                	ld	s8,0(sp)
    80004c7e:	6161                	addi	sp,sp,80
    80004c80:	8082                	ret
    ret = (i == n ? n : -1);
    80004c82:	5a7d                	li	s4,-1
    80004c84:	b7d5                	j	80004c68 <filewrite+0xfa>
    panic("filewrite");
    80004c86:	00004517          	auipc	a0,0x4
    80004c8a:	b1a50513          	addi	a0,a0,-1254 # 800087a0 <syscalls+0x280>
    80004c8e:	ffffc097          	auipc	ra,0xffffc
    80004c92:	8a0080e7          	jalr	-1888(ra) # 8000052e <panic>
    return -1;
    80004c96:	5a7d                	li	s4,-1
    80004c98:	bfc1                	j	80004c68 <filewrite+0xfa>
      return -1;
    80004c9a:	5a7d                	li	s4,-1
    80004c9c:	b7f1                	j	80004c68 <filewrite+0xfa>
    80004c9e:	5a7d                	li	s4,-1
    80004ca0:	b7e1                	j	80004c68 <filewrite+0xfa>

0000000080004ca2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ca2:	7179                	addi	sp,sp,-48
    80004ca4:	f406                	sd	ra,40(sp)
    80004ca6:	f022                	sd	s0,32(sp)
    80004ca8:	ec26                	sd	s1,24(sp)
    80004caa:	e84a                	sd	s2,16(sp)
    80004cac:	e44e                	sd	s3,8(sp)
    80004cae:	e052                	sd	s4,0(sp)
    80004cb0:	1800                	addi	s0,sp,48
    80004cb2:	84aa                	mv	s1,a0
    80004cb4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004cb6:	0005b023          	sd	zero,0(a1)
    80004cba:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004cbe:	00000097          	auipc	ra,0x0
    80004cc2:	bf8080e7          	jalr	-1032(ra) # 800048b6 <filealloc>
    80004cc6:	e088                	sd	a0,0(s1)
    80004cc8:	c551                	beqz	a0,80004d54 <pipealloc+0xb2>
    80004cca:	00000097          	auipc	ra,0x0
    80004cce:	bec080e7          	jalr	-1044(ra) # 800048b6 <filealloc>
    80004cd2:	00aa3023          	sd	a0,0(s4)
    80004cd6:	c92d                	beqz	a0,80004d48 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004cd8:	ffffc097          	auipc	ra,0xffffc
    80004cdc:	dfe080e7          	jalr	-514(ra) # 80000ad6 <kalloc>
    80004ce0:	892a                	mv	s2,a0
    80004ce2:	c125                	beqz	a0,80004d42 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004ce4:	4985                	li	s3,1
    80004ce6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004cea:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004cee:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004cf2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004cf6:	00004597          	auipc	a1,0x4
    80004cfa:	aba58593          	addi	a1,a1,-1350 # 800087b0 <syscalls+0x290>
    80004cfe:	ffffc097          	auipc	ra,0xffffc
    80004d02:	e38080e7          	jalr	-456(ra) # 80000b36 <initlock>
  (*f0)->type = FD_PIPE;
    80004d06:	609c                	ld	a5,0(s1)
    80004d08:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d0c:	609c                	ld	a5,0(s1)
    80004d0e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d12:	609c                	ld	a5,0(s1)
    80004d14:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d18:	609c                	ld	a5,0(s1)
    80004d1a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d1e:	000a3783          	ld	a5,0(s4)
    80004d22:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d26:	000a3783          	ld	a5,0(s4)
    80004d2a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d2e:	000a3783          	ld	a5,0(s4)
    80004d32:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d36:	000a3783          	ld	a5,0(s4)
    80004d3a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d3e:	4501                	li	a0,0
    80004d40:	a025                	j	80004d68 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d42:	6088                	ld	a0,0(s1)
    80004d44:	e501                	bnez	a0,80004d4c <pipealloc+0xaa>
    80004d46:	a039                	j	80004d54 <pipealloc+0xb2>
    80004d48:	6088                	ld	a0,0(s1)
    80004d4a:	c51d                	beqz	a0,80004d78 <pipealloc+0xd6>
    fileclose(*f0);
    80004d4c:	00000097          	auipc	ra,0x0
    80004d50:	c26080e7          	jalr	-986(ra) # 80004972 <fileclose>
  if(*f1)
    80004d54:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004d58:	557d                	li	a0,-1
  if(*f1)
    80004d5a:	c799                	beqz	a5,80004d68 <pipealloc+0xc6>
    fileclose(*f1);
    80004d5c:	853e                	mv	a0,a5
    80004d5e:	00000097          	auipc	ra,0x0
    80004d62:	c14080e7          	jalr	-1004(ra) # 80004972 <fileclose>
  return -1;
    80004d66:	557d                	li	a0,-1
}
    80004d68:	70a2                	ld	ra,40(sp)
    80004d6a:	7402                	ld	s0,32(sp)
    80004d6c:	64e2                	ld	s1,24(sp)
    80004d6e:	6942                	ld	s2,16(sp)
    80004d70:	69a2                	ld	s3,8(sp)
    80004d72:	6a02                	ld	s4,0(sp)
    80004d74:	6145                	addi	sp,sp,48
    80004d76:	8082                	ret
  return -1;
    80004d78:	557d                	li	a0,-1
    80004d7a:	b7fd                	j	80004d68 <pipealloc+0xc6>

0000000080004d7c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004d7c:	1101                	addi	sp,sp,-32
    80004d7e:	ec06                	sd	ra,24(sp)
    80004d80:	e822                	sd	s0,16(sp)
    80004d82:	e426                	sd	s1,8(sp)
    80004d84:	e04a                	sd	s2,0(sp)
    80004d86:	1000                	addi	s0,sp,32
    80004d88:	84aa                	mv	s1,a0
    80004d8a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004d8c:	ffffc097          	auipc	ra,0xffffc
    80004d90:	e3a080e7          	jalr	-454(ra) # 80000bc6 <acquire>
  if(writable){
    80004d94:	02090d63          	beqz	s2,80004dce <pipeclose+0x52>
    pi->writeopen = 0;
    80004d98:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004d9c:	21848513          	addi	a0,s1,536
    80004da0:	ffffd097          	auipc	ra,0xffffd
    80004da4:	500080e7          	jalr	1280(ra) # 800022a0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004da8:	2204b783          	ld	a5,544(s1)
    80004dac:	eb95                	bnez	a5,80004de0 <pipeclose+0x64>
    release(&pi->lock);
    80004dae:	8526                	mv	a0,s1
    80004db0:	ffffc097          	auipc	ra,0xffffc
    80004db4:	ee0080e7          	jalr	-288(ra) # 80000c90 <release>
    kfree((char*)pi);
    80004db8:	8526                	mv	a0,s1
    80004dba:	ffffc097          	auipc	ra,0xffffc
    80004dbe:	c20080e7          	jalr	-992(ra) # 800009da <kfree>
  } else
    release(&pi->lock);
}
    80004dc2:	60e2                	ld	ra,24(sp)
    80004dc4:	6442                	ld	s0,16(sp)
    80004dc6:	64a2                	ld	s1,8(sp)
    80004dc8:	6902                	ld	s2,0(sp)
    80004dca:	6105                	addi	sp,sp,32
    80004dcc:	8082                	ret
    pi->readopen = 0;
    80004dce:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004dd2:	21c48513          	addi	a0,s1,540
    80004dd6:	ffffd097          	auipc	ra,0xffffd
    80004dda:	4ca080e7          	jalr	1226(ra) # 800022a0 <wakeup>
    80004dde:	b7e9                	j	80004da8 <pipeclose+0x2c>
    release(&pi->lock);
    80004de0:	8526                	mv	a0,s1
    80004de2:	ffffc097          	auipc	ra,0xffffc
    80004de6:	eae080e7          	jalr	-338(ra) # 80000c90 <release>
}
    80004dea:	bfe1                	j	80004dc2 <pipeclose+0x46>

0000000080004dec <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004dec:	7159                	addi	sp,sp,-112
    80004dee:	f486                	sd	ra,104(sp)
    80004df0:	f0a2                	sd	s0,96(sp)
    80004df2:	eca6                	sd	s1,88(sp)
    80004df4:	e8ca                	sd	s2,80(sp)
    80004df6:	e4ce                	sd	s3,72(sp)
    80004df8:	e0d2                	sd	s4,64(sp)
    80004dfa:	fc56                	sd	s5,56(sp)
    80004dfc:	f85a                	sd	s6,48(sp)
    80004dfe:	f45e                	sd	s7,40(sp)
    80004e00:	f062                	sd	s8,32(sp)
    80004e02:	ec66                	sd	s9,24(sp)
    80004e04:	1880                	addi	s0,sp,112
    80004e06:	84aa                	mv	s1,a0
    80004e08:	8b2e                	mv	s6,a1
    80004e0a:	8ab2                	mv	s5,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e0c:	ffffd097          	auipc	ra,0xffffd
    80004e10:	b8c080e7          	jalr	-1140(ra) # 80001998 <myproc>
    80004e14:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004e16:	8526                	mv	a0,s1
    80004e18:	ffffc097          	auipc	ra,0xffffc
    80004e1c:	dae080e7          	jalr	-594(ra) # 80000bc6 <acquire>
  while(i < n){
    80004e20:	0b505663          	blez	s5,80004ecc <pipewrite+0xe0>
  int i = 0;
    80004e24:	4901                	li	s2,0
    if(pi->readopen == 0 || pr->killed==1){
    80004e26:	4a05                	li	s4,1
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e28:	5bfd                	li	s7,-1
      wakeup(&pi->nread);
    80004e2a:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004e2e:	21c48c13          	addi	s8,s1,540
    80004e32:	a091                	j	80004e76 <pipewrite+0x8a>
      release(&pi->lock);
    80004e34:	8526                	mv	a0,s1
    80004e36:	ffffc097          	auipc	ra,0xffffc
    80004e3a:	e5a080e7          	jalr	-422(ra) # 80000c90 <release>
      return -1;
    80004e3e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004e40:	854a                	mv	a0,s2
    80004e42:	70a6                	ld	ra,104(sp)
    80004e44:	7406                	ld	s0,96(sp)
    80004e46:	64e6                	ld	s1,88(sp)
    80004e48:	6946                	ld	s2,80(sp)
    80004e4a:	69a6                	ld	s3,72(sp)
    80004e4c:	6a06                	ld	s4,64(sp)
    80004e4e:	7ae2                	ld	s5,56(sp)
    80004e50:	7b42                	ld	s6,48(sp)
    80004e52:	7ba2                	ld	s7,40(sp)
    80004e54:	7c02                	ld	s8,32(sp)
    80004e56:	6ce2                	ld	s9,24(sp)
    80004e58:	6165                	addi	sp,sp,112
    80004e5a:	8082                	ret
      wakeup(&pi->nread);
    80004e5c:	8566                	mv	a0,s9
    80004e5e:	ffffd097          	auipc	ra,0xffffd
    80004e62:	442080e7          	jalr	1090(ra) # 800022a0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e66:	85a6                	mv	a1,s1
    80004e68:	8562                	mv	a0,s8
    80004e6a:	ffffd097          	auipc	ra,0xffffd
    80004e6e:	2a8080e7          	jalr	680(ra) # 80002112 <sleep>
  while(i < n){
    80004e72:	05595e63          	bge	s2,s5,80004ece <pipewrite+0xe2>
    if(pi->readopen == 0 || pr->killed==1){
    80004e76:	2204a783          	lw	a5,544(s1)
    80004e7a:	dfcd                	beqz	a5,80004e34 <pipewrite+0x48>
    80004e7c:	0289a783          	lw	a5,40(s3)
    80004e80:	fb478ae3          	beq	a5,s4,80004e34 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004e84:	2184a783          	lw	a5,536(s1)
    80004e88:	21c4a703          	lw	a4,540(s1)
    80004e8c:	2007879b          	addiw	a5,a5,512
    80004e90:	fcf706e3          	beq	a4,a5,80004e5c <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e94:	86d2                	mv	a3,s4
    80004e96:	01690633          	add	a2,s2,s6
    80004e9a:	f9f40593          	addi	a1,s0,-97
    80004e9e:	0509b503          	ld	a0,80(s3)
    80004ea2:	ffffd097          	auipc	ra,0xffffd
    80004ea6:	842080e7          	jalr	-1982(ra) # 800016e4 <copyin>
    80004eaa:	03750263          	beq	a0,s7,80004ece <pipewrite+0xe2>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004eae:	21c4a783          	lw	a5,540(s1)
    80004eb2:	0017871b          	addiw	a4,a5,1
    80004eb6:	20e4ae23          	sw	a4,540(s1)
    80004eba:	1ff7f793          	andi	a5,a5,511
    80004ebe:	97a6                	add	a5,a5,s1
    80004ec0:	f9f44703          	lbu	a4,-97(s0)
    80004ec4:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ec8:	2905                	addiw	s2,s2,1
    80004eca:	b765                	j	80004e72 <pipewrite+0x86>
  int i = 0;
    80004ecc:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004ece:	21848513          	addi	a0,s1,536
    80004ed2:	ffffd097          	auipc	ra,0xffffd
    80004ed6:	3ce080e7          	jalr	974(ra) # 800022a0 <wakeup>
  release(&pi->lock);
    80004eda:	8526                	mv	a0,s1
    80004edc:	ffffc097          	auipc	ra,0xffffc
    80004ee0:	db4080e7          	jalr	-588(ra) # 80000c90 <release>
  return i;
    80004ee4:	bfb1                	j	80004e40 <pipewrite+0x54>

0000000080004ee6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ee6:	715d                	addi	sp,sp,-80
    80004ee8:	e486                	sd	ra,72(sp)
    80004eea:	e0a2                	sd	s0,64(sp)
    80004eec:	fc26                	sd	s1,56(sp)
    80004eee:	f84a                	sd	s2,48(sp)
    80004ef0:	f44e                	sd	s3,40(sp)
    80004ef2:	f052                	sd	s4,32(sp)
    80004ef4:	ec56                	sd	s5,24(sp)
    80004ef6:	e85a                	sd	s6,16(sp)
    80004ef8:	0880                	addi	s0,sp,80
    80004efa:	84aa                	mv	s1,a0
    80004efc:	892e                	mv	s2,a1
    80004efe:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f00:	ffffd097          	auipc	ra,0xffffd
    80004f04:	a98080e7          	jalr	-1384(ra) # 80001998 <myproc>
    80004f08:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f0a:	8526                	mv	a0,s1
    80004f0c:	ffffc097          	auipc	ra,0xffffc
    80004f10:	cba080e7          	jalr	-838(ra) # 80000bc6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f14:	2184a703          	lw	a4,536(s1)
    80004f18:	21c4a783          	lw	a5,540(s1)
    if(pr->killed==1){
    80004f1c:	4985                	li	s3,1
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f1e:	21848b13          	addi	s6,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f22:	02f71563          	bne	a4,a5,80004f4c <piperead+0x66>
    80004f26:	2244a783          	lw	a5,548(s1)
    80004f2a:	c38d                	beqz	a5,80004f4c <piperead+0x66>
    if(pr->killed==1){
    80004f2c:	028a2783          	lw	a5,40(s4)
    80004f30:	09378963          	beq	a5,s3,80004fc2 <piperead+0xdc>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f34:	85a6                	mv	a1,s1
    80004f36:	855a                	mv	a0,s6
    80004f38:	ffffd097          	auipc	ra,0xffffd
    80004f3c:	1da080e7          	jalr	474(ra) # 80002112 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f40:	2184a703          	lw	a4,536(s1)
    80004f44:	21c4a783          	lw	a5,540(s1)
    80004f48:	fcf70fe3          	beq	a4,a5,80004f26 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f4c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f4e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f50:	05505363          	blez	s5,80004f96 <piperead+0xb0>
    if(pi->nread == pi->nwrite)
    80004f54:	2184a783          	lw	a5,536(s1)
    80004f58:	21c4a703          	lw	a4,540(s1)
    80004f5c:	02f70d63          	beq	a4,a5,80004f96 <piperead+0xb0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004f60:	0017871b          	addiw	a4,a5,1
    80004f64:	20e4ac23          	sw	a4,536(s1)
    80004f68:	1ff7f793          	andi	a5,a5,511
    80004f6c:	97a6                	add	a5,a5,s1
    80004f6e:	0187c783          	lbu	a5,24(a5)
    80004f72:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f76:	4685                	li	a3,1
    80004f78:	fbf40613          	addi	a2,s0,-65
    80004f7c:	85ca                	mv	a1,s2
    80004f7e:	050a3503          	ld	a0,80(s4)
    80004f82:	ffffc097          	auipc	ra,0xffffc
    80004f86:	6d6080e7          	jalr	1750(ra) # 80001658 <copyout>
    80004f8a:	01650663          	beq	a0,s6,80004f96 <piperead+0xb0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f8e:	2985                	addiw	s3,s3,1
    80004f90:	0905                	addi	s2,s2,1
    80004f92:	fd3a91e3          	bne	s5,s3,80004f54 <piperead+0x6e>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004f96:	21c48513          	addi	a0,s1,540
    80004f9a:	ffffd097          	auipc	ra,0xffffd
    80004f9e:	306080e7          	jalr	774(ra) # 800022a0 <wakeup>
  release(&pi->lock);
    80004fa2:	8526                	mv	a0,s1
    80004fa4:	ffffc097          	auipc	ra,0xffffc
    80004fa8:	cec080e7          	jalr	-788(ra) # 80000c90 <release>
  return i;
}
    80004fac:	854e                	mv	a0,s3
    80004fae:	60a6                	ld	ra,72(sp)
    80004fb0:	6406                	ld	s0,64(sp)
    80004fb2:	74e2                	ld	s1,56(sp)
    80004fb4:	7942                	ld	s2,48(sp)
    80004fb6:	79a2                	ld	s3,40(sp)
    80004fb8:	7a02                	ld	s4,32(sp)
    80004fba:	6ae2                	ld	s5,24(sp)
    80004fbc:	6b42                	ld	s6,16(sp)
    80004fbe:	6161                	addi	sp,sp,80
    80004fc0:	8082                	ret
      release(&pi->lock);
    80004fc2:	8526                	mv	a0,s1
    80004fc4:	ffffc097          	auipc	ra,0xffffc
    80004fc8:	ccc080e7          	jalr	-820(ra) # 80000c90 <release>
      return -1;
    80004fcc:	59fd                	li	s3,-1
    80004fce:	bff9                	j	80004fac <piperead+0xc6>

0000000080004fd0 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004fd0:	de010113          	addi	sp,sp,-544
    80004fd4:	20113c23          	sd	ra,536(sp)
    80004fd8:	20813823          	sd	s0,528(sp)
    80004fdc:	20913423          	sd	s1,520(sp)
    80004fe0:	21213023          	sd	s2,512(sp)
    80004fe4:	ffce                	sd	s3,504(sp)
    80004fe6:	fbd2                	sd	s4,496(sp)
    80004fe8:	f7d6                	sd	s5,488(sp)
    80004fea:	f3da                	sd	s6,480(sp)
    80004fec:	efde                	sd	s7,472(sp)
    80004fee:	ebe2                	sd	s8,464(sp)
    80004ff0:	e7e6                	sd	s9,456(sp)
    80004ff2:	e3ea                	sd	s10,448(sp)
    80004ff4:	ff6e                	sd	s11,440(sp)
    80004ff6:	1400                	addi	s0,sp,544
    80004ff8:	892a                	mv	s2,a0
    80004ffa:	dea43423          	sd	a0,-536(s0)
    80004ffe:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005002:	ffffd097          	auipc	ra,0xffffd
    80005006:	996080e7          	jalr	-1642(ra) # 80001998 <myproc>
    8000500a:	84aa                	mv	s1,a0

  begin_op();
    8000500c:	fffff097          	auipc	ra,0xfffff
    80005010:	49a080e7          	jalr	1178(ra) # 800044a6 <begin_op>

  if((ip = namei(path)) == 0){
    80005014:	854a                	mv	a0,s2
    80005016:	fffff097          	auipc	ra,0xfffff
    8000501a:	270080e7          	jalr	624(ra) # 80004286 <namei>
    8000501e:	c93d                	beqz	a0,80005094 <exec+0xc4>
    80005020:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005022:	fffff097          	auipc	ra,0xfffff
    80005026:	aae080e7          	jalr	-1362(ra) # 80003ad0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000502a:	04000713          	li	a4,64
    8000502e:	4681                	li	a3,0
    80005030:	e4840613          	addi	a2,s0,-440
    80005034:	4581                	li	a1,0
    80005036:	8556                	mv	a0,s5
    80005038:	fffff097          	auipc	ra,0xfffff
    8000503c:	d4c080e7          	jalr	-692(ra) # 80003d84 <readi>
    80005040:	04000793          	li	a5,64
    80005044:	00f51a63          	bne	a0,a5,80005058 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005048:	e4842703          	lw	a4,-440(s0)
    8000504c:	464c47b7          	lui	a5,0x464c4
    80005050:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005054:	04f70663          	beq	a4,a5,800050a0 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005058:	8556                	mv	a0,s5
    8000505a:	fffff097          	auipc	ra,0xfffff
    8000505e:	cd8080e7          	jalr	-808(ra) # 80003d32 <iunlockput>
    end_op();
    80005062:	fffff097          	auipc	ra,0xfffff
    80005066:	4c4080e7          	jalr	1220(ra) # 80004526 <end_op>
  }
  return -1;
    8000506a:	557d                	li	a0,-1
}
    8000506c:	21813083          	ld	ra,536(sp)
    80005070:	21013403          	ld	s0,528(sp)
    80005074:	20813483          	ld	s1,520(sp)
    80005078:	20013903          	ld	s2,512(sp)
    8000507c:	79fe                	ld	s3,504(sp)
    8000507e:	7a5e                	ld	s4,496(sp)
    80005080:	7abe                	ld	s5,488(sp)
    80005082:	7b1e                	ld	s6,480(sp)
    80005084:	6bfe                	ld	s7,472(sp)
    80005086:	6c5e                	ld	s8,464(sp)
    80005088:	6cbe                	ld	s9,456(sp)
    8000508a:	6d1e                	ld	s10,448(sp)
    8000508c:	7dfa                	ld	s11,440(sp)
    8000508e:	22010113          	addi	sp,sp,544
    80005092:	8082                	ret
    end_op();
    80005094:	fffff097          	auipc	ra,0xfffff
    80005098:	492080e7          	jalr	1170(ra) # 80004526 <end_op>
    return -1;
    8000509c:	557d                	li	a0,-1
    8000509e:	b7f9                	j	8000506c <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800050a0:	8526                	mv	a0,s1
    800050a2:	ffffd097          	auipc	ra,0xffffd
    800050a6:	9ba080e7          	jalr	-1606(ra) # 80001a5c <proc_pagetable>
    800050aa:	8b2a                	mv	s6,a0
    800050ac:	d555                	beqz	a0,80005058 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050ae:	e6842783          	lw	a5,-408(s0)
    800050b2:	e8045703          	lhu	a4,-384(s0)
    800050b6:	c735                	beqz	a4,80005122 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800050b8:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050ba:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800050be:	6a05                	lui	s4,0x1
    800050c0:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800050c4:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    800050c8:	6d85                	lui	s11,0x1
    800050ca:	7d7d                	lui	s10,0xfffff
    800050cc:	ac3d                	j	8000530a <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800050ce:	00003517          	auipc	a0,0x3
    800050d2:	6ea50513          	addi	a0,a0,1770 # 800087b8 <syscalls+0x298>
    800050d6:	ffffb097          	auipc	ra,0xffffb
    800050da:	458080e7          	jalr	1112(ra) # 8000052e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800050de:	874a                	mv	a4,s2
    800050e0:	009c86bb          	addw	a3,s9,s1
    800050e4:	4581                	li	a1,0
    800050e6:	8556                	mv	a0,s5
    800050e8:	fffff097          	auipc	ra,0xfffff
    800050ec:	c9c080e7          	jalr	-868(ra) # 80003d84 <readi>
    800050f0:	2501                	sext.w	a0,a0
    800050f2:	1aa91c63          	bne	s2,a0,800052aa <exec+0x2da>
  for(i = 0; i < sz; i += PGSIZE){
    800050f6:	009d84bb          	addw	s1,s11,s1
    800050fa:	013d09bb          	addw	s3,s10,s3
    800050fe:	1f74f663          	bgeu	s1,s7,800052ea <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80005102:	02049593          	slli	a1,s1,0x20
    80005106:	9181                	srli	a1,a1,0x20
    80005108:	95e2                	add	a1,a1,s8
    8000510a:	855a                	mv	a0,s6
    8000510c:	ffffc097          	auipc	ra,0xffffc
    80005110:	f5a080e7          	jalr	-166(ra) # 80001066 <walkaddr>
    80005114:	862a                	mv	a2,a0
    if(pa == 0)
    80005116:	dd45                	beqz	a0,800050ce <exec+0xfe>
      n = PGSIZE;
    80005118:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000511a:	fd49f2e3          	bgeu	s3,s4,800050de <exec+0x10e>
      n = sz - i;
    8000511e:	894e                	mv	s2,s3
    80005120:	bf7d                	j	800050de <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005122:	4481                	li	s1,0
  iunlockput(ip);
    80005124:	8556                	mv	a0,s5
    80005126:	fffff097          	auipc	ra,0xfffff
    8000512a:	c0c080e7          	jalr	-1012(ra) # 80003d32 <iunlockput>
  end_op();
    8000512e:	fffff097          	auipc	ra,0xfffff
    80005132:	3f8080e7          	jalr	1016(ra) # 80004526 <end_op>
  p = myproc();
    80005136:	ffffd097          	auipc	ra,0xffffd
    8000513a:	862080e7          	jalr	-1950(ra) # 80001998 <myproc>
    8000513e:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005140:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005144:	6785                	lui	a5,0x1
    80005146:	17fd                	addi	a5,a5,-1
    80005148:	94be                	add	s1,s1,a5
    8000514a:	77fd                	lui	a5,0xfffff
    8000514c:	8fe5                	and	a5,a5,s1
    8000514e:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005152:	6609                	lui	a2,0x2
    80005154:	963e                	add	a2,a2,a5
    80005156:	85be                	mv	a1,a5
    80005158:	855a                	mv	a0,s6
    8000515a:	ffffc097          	auipc	ra,0xffffc
    8000515e:	2ae080e7          	jalr	686(ra) # 80001408 <uvmalloc>
    80005162:	8c2a                	mv	s8,a0
  ip = 0;
    80005164:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005166:	14050263          	beqz	a0,800052aa <exec+0x2da>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000516a:	75f9                	lui	a1,0xffffe
    8000516c:	95aa                	add	a1,a1,a0
    8000516e:	855a                	mv	a0,s6
    80005170:	ffffc097          	auipc	ra,0xffffc
    80005174:	4b6080e7          	jalr	1206(ra) # 80001626 <uvmclear>
  stackbase = sp - PGSIZE;
    80005178:	7afd                	lui	s5,0xfffff
    8000517a:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000517c:	df043783          	ld	a5,-528(s0)
    80005180:	6388                	ld	a0,0(a5)
    80005182:	c925                	beqz	a0,800051f2 <exec+0x222>
    80005184:	e8840993          	addi	s3,s0,-376
    80005188:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    8000518c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000518e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005190:	ffffc097          	auipc	ra,0xffffc
    80005194:	ccc080e7          	jalr	-820(ra) # 80000e5c <strlen>
    80005198:	0015079b          	addiw	a5,a0,1
    8000519c:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800051a0:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800051a4:	13596763          	bltu	s2,s5,800052d2 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800051a8:	df043d83          	ld	s11,-528(s0)
    800051ac:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800051b0:	8552                	mv	a0,s4
    800051b2:	ffffc097          	auipc	ra,0xffffc
    800051b6:	caa080e7          	jalr	-854(ra) # 80000e5c <strlen>
    800051ba:	0015069b          	addiw	a3,a0,1
    800051be:	8652                	mv	a2,s4
    800051c0:	85ca                	mv	a1,s2
    800051c2:	855a                	mv	a0,s6
    800051c4:	ffffc097          	auipc	ra,0xffffc
    800051c8:	494080e7          	jalr	1172(ra) # 80001658 <copyout>
    800051cc:	10054763          	bltz	a0,800052da <exec+0x30a>
    ustack[argc] = sp;
    800051d0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800051d4:	0485                	addi	s1,s1,1
    800051d6:	008d8793          	addi	a5,s11,8
    800051da:	def43823          	sd	a5,-528(s0)
    800051de:	008db503          	ld	a0,8(s11)
    800051e2:	c911                	beqz	a0,800051f6 <exec+0x226>
    if(argc >= MAXARG)
    800051e4:	09a1                	addi	s3,s3,8
    800051e6:	fb3c95e3          	bne	s9,s3,80005190 <exec+0x1c0>
  sz = sz1;
    800051ea:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051ee:	4a81                	li	s5,0
    800051f0:	a86d                	j	800052aa <exec+0x2da>
  sp = sz;
    800051f2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800051f4:	4481                	li	s1,0
  ustack[argc] = 0;
    800051f6:	00349793          	slli	a5,s1,0x3
    800051fa:	f9040713          	addi	a4,s0,-112
    800051fe:	97ba                	add	a5,a5,a4
    80005200:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd0ef8>
  sp -= (argc+1) * sizeof(uint64);
    80005204:	00148693          	addi	a3,s1,1
    80005208:	068e                	slli	a3,a3,0x3
    8000520a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000520e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005212:	01597663          	bgeu	s2,s5,8000521e <exec+0x24e>
  sz = sz1;
    80005216:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000521a:	4a81                	li	s5,0
    8000521c:	a079                	j	800052aa <exec+0x2da>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000521e:	e8840613          	addi	a2,s0,-376
    80005222:	85ca                	mv	a1,s2
    80005224:	855a                	mv	a0,s6
    80005226:	ffffc097          	auipc	ra,0xffffc
    8000522a:	432080e7          	jalr	1074(ra) # 80001658 <copyout>
    8000522e:	0a054a63          	bltz	a0,800052e2 <exec+0x312>
  p->trapframe->a1 = sp;
    80005232:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80005236:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000523a:	de843783          	ld	a5,-536(s0)
    8000523e:	0007c703          	lbu	a4,0(a5)
    80005242:	cf11                	beqz	a4,8000525e <exec+0x28e>
    80005244:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005246:	02f00693          	li	a3,47
    8000524a:	a039                	j	80005258 <exec+0x288>
      last = s+1;
    8000524c:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005250:	0785                	addi	a5,a5,1
    80005252:	fff7c703          	lbu	a4,-1(a5)
    80005256:	c701                	beqz	a4,8000525e <exec+0x28e>
    if(*s == '/')
    80005258:	fed71ce3          	bne	a4,a3,80005250 <exec+0x280>
    8000525c:	bfc5                	j	8000524c <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000525e:	4641                	li	a2,16
    80005260:	de843583          	ld	a1,-536(s0)
    80005264:	158b8513          	addi	a0,s7,344
    80005268:	ffffc097          	auipc	ra,0xffffc
    8000526c:	bc2080e7          	jalr	-1086(ra) # 80000e2a <safestrcpy>
    80005270:	02000793          	li	a5,32
  for(int i=0; i<32; i++){
    80005274:	37fd                	addiw	a5,a5,-1
    80005276:	fffd                	bnez	a5,80005274 <exec+0x2a4>
  oldpagetable = p->pagetable;
    80005278:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    8000527c:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005280:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005284:	058bb783          	ld	a5,88(s7)
    80005288:	e6043703          	ld	a4,-416(s0)
    8000528c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000528e:	058bb783          	ld	a5,88(s7)
    80005292:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005296:	85ea                	mv	a1,s10
    80005298:	ffffd097          	auipc	ra,0xffffd
    8000529c:	860080e7          	jalr	-1952(ra) # 80001af8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800052a0:	0004851b          	sext.w	a0,s1
    800052a4:	b3e1                	j	8000506c <exec+0x9c>
    800052a6:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    800052aa:	df843583          	ld	a1,-520(s0)
    800052ae:	855a                	mv	a0,s6
    800052b0:	ffffd097          	auipc	ra,0xffffd
    800052b4:	848080e7          	jalr	-1976(ra) # 80001af8 <proc_freepagetable>
  if(ip){
    800052b8:	da0a90e3          	bnez	s5,80005058 <exec+0x88>
  return -1;
    800052bc:	557d                	li	a0,-1
    800052be:	b37d                	j	8000506c <exec+0x9c>
    800052c0:	de943c23          	sd	s1,-520(s0)
    800052c4:	b7dd                	j	800052aa <exec+0x2da>
    800052c6:	de943c23          	sd	s1,-520(s0)
    800052ca:	b7c5                	j	800052aa <exec+0x2da>
    800052cc:	de943c23          	sd	s1,-520(s0)
    800052d0:	bfe9                	j	800052aa <exec+0x2da>
  sz = sz1;
    800052d2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052d6:	4a81                	li	s5,0
    800052d8:	bfc9                	j	800052aa <exec+0x2da>
  sz = sz1;
    800052da:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052de:	4a81                	li	s5,0
    800052e0:	b7e9                	j	800052aa <exec+0x2da>
  sz = sz1;
    800052e2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052e6:	4a81                	li	s5,0
    800052e8:	b7c9                	j	800052aa <exec+0x2da>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800052ea:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052ee:	e0843783          	ld	a5,-504(s0)
    800052f2:	0017869b          	addiw	a3,a5,1
    800052f6:	e0d43423          	sd	a3,-504(s0)
    800052fa:	e0043783          	ld	a5,-512(s0)
    800052fe:	0387879b          	addiw	a5,a5,56
    80005302:	e8045703          	lhu	a4,-384(s0)
    80005306:	e0e6dfe3          	bge	a3,a4,80005124 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000530a:	2781                	sext.w	a5,a5
    8000530c:	e0f43023          	sd	a5,-512(s0)
    80005310:	03800713          	li	a4,56
    80005314:	86be                	mv	a3,a5
    80005316:	e1040613          	addi	a2,s0,-496
    8000531a:	4581                	li	a1,0
    8000531c:	8556                	mv	a0,s5
    8000531e:	fffff097          	auipc	ra,0xfffff
    80005322:	a66080e7          	jalr	-1434(ra) # 80003d84 <readi>
    80005326:	03800793          	li	a5,56
    8000532a:	f6f51ee3          	bne	a0,a5,800052a6 <exec+0x2d6>
    if(ph.type != ELF_PROG_LOAD)
    8000532e:	e1042783          	lw	a5,-496(s0)
    80005332:	4705                	li	a4,1
    80005334:	fae79de3          	bne	a5,a4,800052ee <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80005338:	e3843603          	ld	a2,-456(s0)
    8000533c:	e3043783          	ld	a5,-464(s0)
    80005340:	f8f660e3          	bltu	a2,a5,800052c0 <exec+0x2f0>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005344:	e2043783          	ld	a5,-480(s0)
    80005348:	963e                	add	a2,a2,a5
    8000534a:	f6f66ee3          	bltu	a2,a5,800052c6 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000534e:	85a6                	mv	a1,s1
    80005350:	855a                	mv	a0,s6
    80005352:	ffffc097          	auipc	ra,0xffffc
    80005356:	0b6080e7          	jalr	182(ra) # 80001408 <uvmalloc>
    8000535a:	dea43c23          	sd	a0,-520(s0)
    8000535e:	d53d                	beqz	a0,800052cc <exec+0x2fc>
    if(ph.vaddr % PGSIZE != 0)
    80005360:	e2043c03          	ld	s8,-480(s0)
    80005364:	de043783          	ld	a5,-544(s0)
    80005368:	00fc77b3          	and	a5,s8,a5
    8000536c:	ff9d                	bnez	a5,800052aa <exec+0x2da>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000536e:	e1842c83          	lw	s9,-488(s0)
    80005372:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005376:	f60b8ae3          	beqz	s7,800052ea <exec+0x31a>
    8000537a:	89de                	mv	s3,s7
    8000537c:	4481                	li	s1,0
    8000537e:	b351                	j	80005102 <exec+0x132>

0000000080005380 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005380:	7179                	addi	sp,sp,-48
    80005382:	f406                	sd	ra,40(sp)
    80005384:	f022                	sd	s0,32(sp)
    80005386:	ec26                	sd	s1,24(sp)
    80005388:	e84a                	sd	s2,16(sp)
    8000538a:	1800                	addi	s0,sp,48
    8000538c:	892e                	mv	s2,a1
    8000538e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005390:	fdc40593          	addi	a1,s0,-36
    80005394:	ffffe097          	auipc	ra,0xffffe
    80005398:	aea080e7          	jalr	-1302(ra) # 80002e7e <argint>
    8000539c:	04054063          	bltz	a0,800053dc <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800053a0:	fdc42703          	lw	a4,-36(s0)
    800053a4:	47bd                	li	a5,15
    800053a6:	02e7ed63          	bltu	a5,a4,800053e0 <argfd+0x60>
    800053aa:	ffffc097          	auipc	ra,0xffffc
    800053ae:	5ee080e7          	jalr	1518(ra) # 80001998 <myproc>
    800053b2:	fdc42703          	lw	a4,-36(s0)
    800053b6:	01a70793          	addi	a5,a4,26
    800053ba:	078e                	slli	a5,a5,0x3
    800053bc:	953e                	add	a0,a0,a5
    800053be:	611c                	ld	a5,0(a0)
    800053c0:	c395                	beqz	a5,800053e4 <argfd+0x64>
    return -1;
  if(pfd)
    800053c2:	00090463          	beqz	s2,800053ca <argfd+0x4a>
    *pfd = fd;
    800053c6:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800053ca:	4501                	li	a0,0
  if(pf)
    800053cc:	c091                	beqz	s1,800053d0 <argfd+0x50>
    *pf = f;
    800053ce:	e09c                	sd	a5,0(s1)
}
    800053d0:	70a2                	ld	ra,40(sp)
    800053d2:	7402                	ld	s0,32(sp)
    800053d4:	64e2                	ld	s1,24(sp)
    800053d6:	6942                	ld	s2,16(sp)
    800053d8:	6145                	addi	sp,sp,48
    800053da:	8082                	ret
    return -1;
    800053dc:	557d                	li	a0,-1
    800053de:	bfcd                	j	800053d0 <argfd+0x50>
    return -1;
    800053e0:	557d                	li	a0,-1
    800053e2:	b7fd                	j	800053d0 <argfd+0x50>
    800053e4:	557d                	li	a0,-1
    800053e6:	b7ed                	j	800053d0 <argfd+0x50>

00000000800053e8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800053e8:	1101                	addi	sp,sp,-32
    800053ea:	ec06                	sd	ra,24(sp)
    800053ec:	e822                	sd	s0,16(sp)
    800053ee:	e426                	sd	s1,8(sp)
    800053f0:	1000                	addi	s0,sp,32
    800053f2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800053f4:	ffffc097          	auipc	ra,0xffffc
    800053f8:	5a4080e7          	jalr	1444(ra) # 80001998 <myproc>
    800053fc:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800053fe:	0d050793          	addi	a5,a0,208
    80005402:	4501                	li	a0,0
    80005404:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005406:	6398                	ld	a4,0(a5)
    80005408:	cb19                	beqz	a4,8000541e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000540a:	2505                	addiw	a0,a0,1
    8000540c:	07a1                	addi	a5,a5,8
    8000540e:	fed51ce3          	bne	a0,a3,80005406 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005412:	557d                	li	a0,-1
}
    80005414:	60e2                	ld	ra,24(sp)
    80005416:	6442                	ld	s0,16(sp)
    80005418:	64a2                	ld	s1,8(sp)
    8000541a:	6105                	addi	sp,sp,32
    8000541c:	8082                	ret
      p->ofile[fd] = f;
    8000541e:	01a50793          	addi	a5,a0,26
    80005422:	078e                	slli	a5,a5,0x3
    80005424:	963e                	add	a2,a2,a5
    80005426:	e204                	sd	s1,0(a2)
      return fd;
    80005428:	b7f5                	j	80005414 <fdalloc+0x2c>

000000008000542a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000542a:	715d                	addi	sp,sp,-80
    8000542c:	e486                	sd	ra,72(sp)
    8000542e:	e0a2                	sd	s0,64(sp)
    80005430:	fc26                	sd	s1,56(sp)
    80005432:	f84a                	sd	s2,48(sp)
    80005434:	f44e                	sd	s3,40(sp)
    80005436:	f052                	sd	s4,32(sp)
    80005438:	ec56                	sd	s5,24(sp)
    8000543a:	0880                	addi	s0,sp,80
    8000543c:	89ae                	mv	s3,a1
    8000543e:	8ab2                	mv	s5,a2
    80005440:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005442:	fb040593          	addi	a1,s0,-80
    80005446:	fffff097          	auipc	ra,0xfffff
    8000544a:	e5e080e7          	jalr	-418(ra) # 800042a4 <nameiparent>
    8000544e:	892a                	mv	s2,a0
    80005450:	12050e63          	beqz	a0,8000558c <create+0x162>
    return 0;

  ilock(dp);
    80005454:	ffffe097          	auipc	ra,0xffffe
    80005458:	67c080e7          	jalr	1660(ra) # 80003ad0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000545c:	4601                	li	a2,0
    8000545e:	fb040593          	addi	a1,s0,-80
    80005462:	854a                	mv	a0,s2
    80005464:	fffff097          	auipc	ra,0xfffff
    80005468:	b50080e7          	jalr	-1200(ra) # 80003fb4 <dirlookup>
    8000546c:	84aa                	mv	s1,a0
    8000546e:	c921                	beqz	a0,800054be <create+0x94>
    iunlockput(dp);
    80005470:	854a                	mv	a0,s2
    80005472:	fffff097          	auipc	ra,0xfffff
    80005476:	8c0080e7          	jalr	-1856(ra) # 80003d32 <iunlockput>
    ilock(ip);
    8000547a:	8526                	mv	a0,s1
    8000547c:	ffffe097          	auipc	ra,0xffffe
    80005480:	654080e7          	jalr	1620(ra) # 80003ad0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005484:	2981                	sext.w	s3,s3
    80005486:	4789                	li	a5,2
    80005488:	02f99463          	bne	s3,a5,800054b0 <create+0x86>
    8000548c:	0444d783          	lhu	a5,68(s1)
    80005490:	37f9                	addiw	a5,a5,-2
    80005492:	17c2                	slli	a5,a5,0x30
    80005494:	93c1                	srli	a5,a5,0x30
    80005496:	4705                	li	a4,1
    80005498:	00f76c63          	bltu	a4,a5,800054b0 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000549c:	8526                	mv	a0,s1
    8000549e:	60a6                	ld	ra,72(sp)
    800054a0:	6406                	ld	s0,64(sp)
    800054a2:	74e2                	ld	s1,56(sp)
    800054a4:	7942                	ld	s2,48(sp)
    800054a6:	79a2                	ld	s3,40(sp)
    800054a8:	7a02                	ld	s4,32(sp)
    800054aa:	6ae2                	ld	s5,24(sp)
    800054ac:	6161                	addi	sp,sp,80
    800054ae:	8082                	ret
    iunlockput(ip);
    800054b0:	8526                	mv	a0,s1
    800054b2:	fffff097          	auipc	ra,0xfffff
    800054b6:	880080e7          	jalr	-1920(ra) # 80003d32 <iunlockput>
    return 0;
    800054ba:	4481                	li	s1,0
    800054bc:	b7c5                	j	8000549c <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800054be:	85ce                	mv	a1,s3
    800054c0:	00092503          	lw	a0,0(s2)
    800054c4:	ffffe097          	auipc	ra,0xffffe
    800054c8:	474080e7          	jalr	1140(ra) # 80003938 <ialloc>
    800054cc:	84aa                	mv	s1,a0
    800054ce:	c521                	beqz	a0,80005516 <create+0xec>
  ilock(ip);
    800054d0:	ffffe097          	auipc	ra,0xffffe
    800054d4:	600080e7          	jalr	1536(ra) # 80003ad0 <ilock>
  ip->major = major;
    800054d8:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800054dc:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800054e0:	4a05                	li	s4,1
    800054e2:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800054e6:	8526                	mv	a0,s1
    800054e8:	ffffe097          	auipc	ra,0xffffe
    800054ec:	51e080e7          	jalr	1310(ra) # 80003a06 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800054f0:	2981                	sext.w	s3,s3
    800054f2:	03498a63          	beq	s3,s4,80005526 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800054f6:	40d0                	lw	a2,4(s1)
    800054f8:	fb040593          	addi	a1,s0,-80
    800054fc:	854a                	mv	a0,s2
    800054fe:	fffff097          	auipc	ra,0xfffff
    80005502:	cc6080e7          	jalr	-826(ra) # 800041c4 <dirlink>
    80005506:	06054b63          	bltz	a0,8000557c <create+0x152>
  iunlockput(dp);
    8000550a:	854a                	mv	a0,s2
    8000550c:	fffff097          	auipc	ra,0xfffff
    80005510:	826080e7          	jalr	-2010(ra) # 80003d32 <iunlockput>
  return ip;
    80005514:	b761                	j	8000549c <create+0x72>
    panic("create: ialloc");
    80005516:	00003517          	auipc	a0,0x3
    8000551a:	2c250513          	addi	a0,a0,706 # 800087d8 <syscalls+0x2b8>
    8000551e:	ffffb097          	auipc	ra,0xffffb
    80005522:	010080e7          	jalr	16(ra) # 8000052e <panic>
    dp->nlink++;  // for ".."
    80005526:	04a95783          	lhu	a5,74(s2)
    8000552a:	2785                	addiw	a5,a5,1
    8000552c:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005530:	854a                	mv	a0,s2
    80005532:	ffffe097          	auipc	ra,0xffffe
    80005536:	4d4080e7          	jalr	1236(ra) # 80003a06 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000553a:	40d0                	lw	a2,4(s1)
    8000553c:	00003597          	auipc	a1,0x3
    80005540:	2ac58593          	addi	a1,a1,684 # 800087e8 <syscalls+0x2c8>
    80005544:	8526                	mv	a0,s1
    80005546:	fffff097          	auipc	ra,0xfffff
    8000554a:	c7e080e7          	jalr	-898(ra) # 800041c4 <dirlink>
    8000554e:	00054f63          	bltz	a0,8000556c <create+0x142>
    80005552:	00492603          	lw	a2,4(s2)
    80005556:	00003597          	auipc	a1,0x3
    8000555a:	29a58593          	addi	a1,a1,666 # 800087f0 <syscalls+0x2d0>
    8000555e:	8526                	mv	a0,s1
    80005560:	fffff097          	auipc	ra,0xfffff
    80005564:	c64080e7          	jalr	-924(ra) # 800041c4 <dirlink>
    80005568:	f80557e3          	bgez	a0,800054f6 <create+0xcc>
      panic("create dots");
    8000556c:	00003517          	auipc	a0,0x3
    80005570:	28c50513          	addi	a0,a0,652 # 800087f8 <syscalls+0x2d8>
    80005574:	ffffb097          	auipc	ra,0xffffb
    80005578:	fba080e7          	jalr	-70(ra) # 8000052e <panic>
    panic("create: dirlink");
    8000557c:	00003517          	auipc	a0,0x3
    80005580:	28c50513          	addi	a0,a0,652 # 80008808 <syscalls+0x2e8>
    80005584:	ffffb097          	auipc	ra,0xffffb
    80005588:	faa080e7          	jalr	-86(ra) # 8000052e <panic>
    return 0;
    8000558c:	84aa                	mv	s1,a0
    8000558e:	b739                	j	8000549c <create+0x72>

0000000080005590 <sys_dup>:
{
    80005590:	7179                	addi	sp,sp,-48
    80005592:	f406                	sd	ra,40(sp)
    80005594:	f022                	sd	s0,32(sp)
    80005596:	ec26                	sd	s1,24(sp)
    80005598:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000559a:	fd840613          	addi	a2,s0,-40
    8000559e:	4581                	li	a1,0
    800055a0:	4501                	li	a0,0
    800055a2:	00000097          	auipc	ra,0x0
    800055a6:	dde080e7          	jalr	-546(ra) # 80005380 <argfd>
    return -1;
    800055aa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800055ac:	02054363          	bltz	a0,800055d2 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800055b0:	fd843503          	ld	a0,-40(s0)
    800055b4:	00000097          	auipc	ra,0x0
    800055b8:	e34080e7          	jalr	-460(ra) # 800053e8 <fdalloc>
    800055bc:	84aa                	mv	s1,a0
    return -1;
    800055be:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800055c0:	00054963          	bltz	a0,800055d2 <sys_dup+0x42>
  filedup(f);
    800055c4:	fd843503          	ld	a0,-40(s0)
    800055c8:	fffff097          	auipc	ra,0xfffff
    800055cc:	358080e7          	jalr	856(ra) # 80004920 <filedup>
  return fd;
    800055d0:	87a6                	mv	a5,s1
}
    800055d2:	853e                	mv	a0,a5
    800055d4:	70a2                	ld	ra,40(sp)
    800055d6:	7402                	ld	s0,32(sp)
    800055d8:	64e2                	ld	s1,24(sp)
    800055da:	6145                	addi	sp,sp,48
    800055dc:	8082                	ret

00000000800055de <sys_read>:
{
    800055de:	7179                	addi	sp,sp,-48
    800055e0:	f406                	sd	ra,40(sp)
    800055e2:	f022                	sd	s0,32(sp)
    800055e4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055e6:	fe840613          	addi	a2,s0,-24
    800055ea:	4581                	li	a1,0
    800055ec:	4501                	li	a0,0
    800055ee:	00000097          	auipc	ra,0x0
    800055f2:	d92080e7          	jalr	-622(ra) # 80005380 <argfd>
    return -1;
    800055f6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055f8:	04054163          	bltz	a0,8000563a <sys_read+0x5c>
    800055fc:	fe440593          	addi	a1,s0,-28
    80005600:	4509                	li	a0,2
    80005602:	ffffe097          	auipc	ra,0xffffe
    80005606:	87c080e7          	jalr	-1924(ra) # 80002e7e <argint>
    return -1;
    8000560a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000560c:	02054763          	bltz	a0,8000563a <sys_read+0x5c>
    80005610:	fd840593          	addi	a1,s0,-40
    80005614:	4505                	li	a0,1
    80005616:	ffffe097          	auipc	ra,0xffffe
    8000561a:	88a080e7          	jalr	-1910(ra) # 80002ea0 <argaddr>
    return -1;
    8000561e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005620:	00054d63          	bltz	a0,8000563a <sys_read+0x5c>
  return fileread(f, p, n);
    80005624:	fe442603          	lw	a2,-28(s0)
    80005628:	fd843583          	ld	a1,-40(s0)
    8000562c:	fe843503          	ld	a0,-24(s0)
    80005630:	fffff097          	auipc	ra,0xfffff
    80005634:	47c080e7          	jalr	1148(ra) # 80004aac <fileread>
    80005638:	87aa                	mv	a5,a0
}
    8000563a:	853e                	mv	a0,a5
    8000563c:	70a2                	ld	ra,40(sp)
    8000563e:	7402                	ld	s0,32(sp)
    80005640:	6145                	addi	sp,sp,48
    80005642:	8082                	ret

0000000080005644 <sys_write>:
{
    80005644:	7179                	addi	sp,sp,-48
    80005646:	f406                	sd	ra,40(sp)
    80005648:	f022                	sd	s0,32(sp)
    8000564a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000564c:	fe840613          	addi	a2,s0,-24
    80005650:	4581                	li	a1,0
    80005652:	4501                	li	a0,0
    80005654:	00000097          	auipc	ra,0x0
    80005658:	d2c080e7          	jalr	-724(ra) # 80005380 <argfd>
    return -1;
    8000565c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000565e:	04054163          	bltz	a0,800056a0 <sys_write+0x5c>
    80005662:	fe440593          	addi	a1,s0,-28
    80005666:	4509                	li	a0,2
    80005668:	ffffe097          	auipc	ra,0xffffe
    8000566c:	816080e7          	jalr	-2026(ra) # 80002e7e <argint>
    return -1;
    80005670:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005672:	02054763          	bltz	a0,800056a0 <sys_write+0x5c>
    80005676:	fd840593          	addi	a1,s0,-40
    8000567a:	4505                	li	a0,1
    8000567c:	ffffe097          	auipc	ra,0xffffe
    80005680:	824080e7          	jalr	-2012(ra) # 80002ea0 <argaddr>
    return -1;
    80005684:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005686:	00054d63          	bltz	a0,800056a0 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000568a:	fe442603          	lw	a2,-28(s0)
    8000568e:	fd843583          	ld	a1,-40(s0)
    80005692:	fe843503          	ld	a0,-24(s0)
    80005696:	fffff097          	auipc	ra,0xfffff
    8000569a:	4d8080e7          	jalr	1240(ra) # 80004b6e <filewrite>
    8000569e:	87aa                	mv	a5,a0
}
    800056a0:	853e                	mv	a0,a5
    800056a2:	70a2                	ld	ra,40(sp)
    800056a4:	7402                	ld	s0,32(sp)
    800056a6:	6145                	addi	sp,sp,48
    800056a8:	8082                	ret

00000000800056aa <sys_close>:
{
    800056aa:	1101                	addi	sp,sp,-32
    800056ac:	ec06                	sd	ra,24(sp)
    800056ae:	e822                	sd	s0,16(sp)
    800056b0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800056b2:	fe040613          	addi	a2,s0,-32
    800056b6:	fec40593          	addi	a1,s0,-20
    800056ba:	4501                	li	a0,0
    800056bc:	00000097          	auipc	ra,0x0
    800056c0:	cc4080e7          	jalr	-828(ra) # 80005380 <argfd>
    return -1;
    800056c4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800056c6:	02054463          	bltz	a0,800056ee <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800056ca:	ffffc097          	auipc	ra,0xffffc
    800056ce:	2ce080e7          	jalr	718(ra) # 80001998 <myproc>
    800056d2:	fec42783          	lw	a5,-20(s0)
    800056d6:	07e9                	addi	a5,a5,26
    800056d8:	078e                	slli	a5,a5,0x3
    800056da:	97aa                	add	a5,a5,a0
    800056dc:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800056e0:	fe043503          	ld	a0,-32(s0)
    800056e4:	fffff097          	auipc	ra,0xfffff
    800056e8:	28e080e7          	jalr	654(ra) # 80004972 <fileclose>
  return 0;
    800056ec:	4781                	li	a5,0
}
    800056ee:	853e                	mv	a0,a5
    800056f0:	60e2                	ld	ra,24(sp)
    800056f2:	6442                	ld	s0,16(sp)
    800056f4:	6105                	addi	sp,sp,32
    800056f6:	8082                	ret

00000000800056f8 <sys_fstat>:
{
    800056f8:	1101                	addi	sp,sp,-32
    800056fa:	ec06                	sd	ra,24(sp)
    800056fc:	e822                	sd	s0,16(sp)
    800056fe:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005700:	fe840613          	addi	a2,s0,-24
    80005704:	4581                	li	a1,0
    80005706:	4501                	li	a0,0
    80005708:	00000097          	auipc	ra,0x0
    8000570c:	c78080e7          	jalr	-904(ra) # 80005380 <argfd>
    return -1;
    80005710:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005712:	02054563          	bltz	a0,8000573c <sys_fstat+0x44>
    80005716:	fe040593          	addi	a1,s0,-32
    8000571a:	4505                	li	a0,1
    8000571c:	ffffd097          	auipc	ra,0xffffd
    80005720:	784080e7          	jalr	1924(ra) # 80002ea0 <argaddr>
    return -1;
    80005724:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005726:	00054b63          	bltz	a0,8000573c <sys_fstat+0x44>
  return filestat(f, st);
    8000572a:	fe043583          	ld	a1,-32(s0)
    8000572e:	fe843503          	ld	a0,-24(s0)
    80005732:	fffff097          	auipc	ra,0xfffff
    80005736:	308080e7          	jalr	776(ra) # 80004a3a <filestat>
    8000573a:	87aa                	mv	a5,a0
}
    8000573c:	853e                	mv	a0,a5
    8000573e:	60e2                	ld	ra,24(sp)
    80005740:	6442                	ld	s0,16(sp)
    80005742:	6105                	addi	sp,sp,32
    80005744:	8082                	ret

0000000080005746 <sys_link>:
{
    80005746:	7169                	addi	sp,sp,-304
    80005748:	f606                	sd	ra,296(sp)
    8000574a:	f222                	sd	s0,288(sp)
    8000574c:	ee26                	sd	s1,280(sp)
    8000574e:	ea4a                	sd	s2,272(sp)
    80005750:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005752:	08000613          	li	a2,128
    80005756:	ed040593          	addi	a1,s0,-304
    8000575a:	4501                	li	a0,0
    8000575c:	ffffd097          	auipc	ra,0xffffd
    80005760:	766080e7          	jalr	1894(ra) # 80002ec2 <argstr>
    return -1;
    80005764:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005766:	10054e63          	bltz	a0,80005882 <sys_link+0x13c>
    8000576a:	08000613          	li	a2,128
    8000576e:	f5040593          	addi	a1,s0,-176
    80005772:	4505                	li	a0,1
    80005774:	ffffd097          	auipc	ra,0xffffd
    80005778:	74e080e7          	jalr	1870(ra) # 80002ec2 <argstr>
    return -1;
    8000577c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000577e:	10054263          	bltz	a0,80005882 <sys_link+0x13c>
  begin_op();
    80005782:	fffff097          	auipc	ra,0xfffff
    80005786:	d24080e7          	jalr	-732(ra) # 800044a6 <begin_op>
  if((ip = namei(old)) == 0){
    8000578a:	ed040513          	addi	a0,s0,-304
    8000578e:	fffff097          	auipc	ra,0xfffff
    80005792:	af8080e7          	jalr	-1288(ra) # 80004286 <namei>
    80005796:	84aa                	mv	s1,a0
    80005798:	c551                	beqz	a0,80005824 <sys_link+0xde>
  ilock(ip);
    8000579a:	ffffe097          	auipc	ra,0xffffe
    8000579e:	336080e7          	jalr	822(ra) # 80003ad0 <ilock>
  if(ip->type == T_DIR){
    800057a2:	04449703          	lh	a4,68(s1)
    800057a6:	4785                	li	a5,1
    800057a8:	08f70463          	beq	a4,a5,80005830 <sys_link+0xea>
  ip->nlink++;
    800057ac:	04a4d783          	lhu	a5,74(s1)
    800057b0:	2785                	addiw	a5,a5,1
    800057b2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057b6:	8526                	mv	a0,s1
    800057b8:	ffffe097          	auipc	ra,0xffffe
    800057bc:	24e080e7          	jalr	590(ra) # 80003a06 <iupdate>
  iunlock(ip);
    800057c0:	8526                	mv	a0,s1
    800057c2:	ffffe097          	auipc	ra,0xffffe
    800057c6:	3d0080e7          	jalr	976(ra) # 80003b92 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800057ca:	fd040593          	addi	a1,s0,-48
    800057ce:	f5040513          	addi	a0,s0,-176
    800057d2:	fffff097          	auipc	ra,0xfffff
    800057d6:	ad2080e7          	jalr	-1326(ra) # 800042a4 <nameiparent>
    800057da:	892a                	mv	s2,a0
    800057dc:	c935                	beqz	a0,80005850 <sys_link+0x10a>
  ilock(dp);
    800057de:	ffffe097          	auipc	ra,0xffffe
    800057e2:	2f2080e7          	jalr	754(ra) # 80003ad0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800057e6:	00092703          	lw	a4,0(s2)
    800057ea:	409c                	lw	a5,0(s1)
    800057ec:	04f71d63          	bne	a4,a5,80005846 <sys_link+0x100>
    800057f0:	40d0                	lw	a2,4(s1)
    800057f2:	fd040593          	addi	a1,s0,-48
    800057f6:	854a                	mv	a0,s2
    800057f8:	fffff097          	auipc	ra,0xfffff
    800057fc:	9cc080e7          	jalr	-1588(ra) # 800041c4 <dirlink>
    80005800:	04054363          	bltz	a0,80005846 <sys_link+0x100>
  iunlockput(dp);
    80005804:	854a                	mv	a0,s2
    80005806:	ffffe097          	auipc	ra,0xffffe
    8000580a:	52c080e7          	jalr	1324(ra) # 80003d32 <iunlockput>
  iput(ip);
    8000580e:	8526                	mv	a0,s1
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	47a080e7          	jalr	1146(ra) # 80003c8a <iput>
  end_op();
    80005818:	fffff097          	auipc	ra,0xfffff
    8000581c:	d0e080e7          	jalr	-754(ra) # 80004526 <end_op>
  return 0;
    80005820:	4781                	li	a5,0
    80005822:	a085                	j	80005882 <sys_link+0x13c>
    end_op();
    80005824:	fffff097          	auipc	ra,0xfffff
    80005828:	d02080e7          	jalr	-766(ra) # 80004526 <end_op>
    return -1;
    8000582c:	57fd                	li	a5,-1
    8000582e:	a891                	j	80005882 <sys_link+0x13c>
    iunlockput(ip);
    80005830:	8526                	mv	a0,s1
    80005832:	ffffe097          	auipc	ra,0xffffe
    80005836:	500080e7          	jalr	1280(ra) # 80003d32 <iunlockput>
    end_op();
    8000583a:	fffff097          	auipc	ra,0xfffff
    8000583e:	cec080e7          	jalr	-788(ra) # 80004526 <end_op>
    return -1;
    80005842:	57fd                	li	a5,-1
    80005844:	a83d                	j	80005882 <sys_link+0x13c>
    iunlockput(dp);
    80005846:	854a                	mv	a0,s2
    80005848:	ffffe097          	auipc	ra,0xffffe
    8000584c:	4ea080e7          	jalr	1258(ra) # 80003d32 <iunlockput>
  ilock(ip);
    80005850:	8526                	mv	a0,s1
    80005852:	ffffe097          	auipc	ra,0xffffe
    80005856:	27e080e7          	jalr	638(ra) # 80003ad0 <ilock>
  ip->nlink--;
    8000585a:	04a4d783          	lhu	a5,74(s1)
    8000585e:	37fd                	addiw	a5,a5,-1
    80005860:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005864:	8526                	mv	a0,s1
    80005866:	ffffe097          	auipc	ra,0xffffe
    8000586a:	1a0080e7          	jalr	416(ra) # 80003a06 <iupdate>
  iunlockput(ip);
    8000586e:	8526                	mv	a0,s1
    80005870:	ffffe097          	auipc	ra,0xffffe
    80005874:	4c2080e7          	jalr	1218(ra) # 80003d32 <iunlockput>
  end_op();
    80005878:	fffff097          	auipc	ra,0xfffff
    8000587c:	cae080e7          	jalr	-850(ra) # 80004526 <end_op>
  return -1;
    80005880:	57fd                	li	a5,-1
}
    80005882:	853e                	mv	a0,a5
    80005884:	70b2                	ld	ra,296(sp)
    80005886:	7412                	ld	s0,288(sp)
    80005888:	64f2                	ld	s1,280(sp)
    8000588a:	6952                	ld	s2,272(sp)
    8000588c:	6155                	addi	sp,sp,304
    8000588e:	8082                	ret

0000000080005890 <sys_unlink>:
{
    80005890:	7151                	addi	sp,sp,-240
    80005892:	f586                	sd	ra,232(sp)
    80005894:	f1a2                	sd	s0,224(sp)
    80005896:	eda6                	sd	s1,216(sp)
    80005898:	e9ca                	sd	s2,208(sp)
    8000589a:	e5ce                	sd	s3,200(sp)
    8000589c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000589e:	08000613          	li	a2,128
    800058a2:	f3040593          	addi	a1,s0,-208
    800058a6:	4501                	li	a0,0
    800058a8:	ffffd097          	auipc	ra,0xffffd
    800058ac:	61a080e7          	jalr	1562(ra) # 80002ec2 <argstr>
    800058b0:	18054163          	bltz	a0,80005a32 <sys_unlink+0x1a2>
  begin_op();
    800058b4:	fffff097          	auipc	ra,0xfffff
    800058b8:	bf2080e7          	jalr	-1038(ra) # 800044a6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800058bc:	fb040593          	addi	a1,s0,-80
    800058c0:	f3040513          	addi	a0,s0,-208
    800058c4:	fffff097          	auipc	ra,0xfffff
    800058c8:	9e0080e7          	jalr	-1568(ra) # 800042a4 <nameiparent>
    800058cc:	84aa                	mv	s1,a0
    800058ce:	c979                	beqz	a0,800059a4 <sys_unlink+0x114>
  ilock(dp);
    800058d0:	ffffe097          	auipc	ra,0xffffe
    800058d4:	200080e7          	jalr	512(ra) # 80003ad0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800058d8:	00003597          	auipc	a1,0x3
    800058dc:	f1058593          	addi	a1,a1,-240 # 800087e8 <syscalls+0x2c8>
    800058e0:	fb040513          	addi	a0,s0,-80
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	6b6080e7          	jalr	1718(ra) # 80003f9a <namecmp>
    800058ec:	14050a63          	beqz	a0,80005a40 <sys_unlink+0x1b0>
    800058f0:	00003597          	auipc	a1,0x3
    800058f4:	f0058593          	addi	a1,a1,-256 # 800087f0 <syscalls+0x2d0>
    800058f8:	fb040513          	addi	a0,s0,-80
    800058fc:	ffffe097          	auipc	ra,0xffffe
    80005900:	69e080e7          	jalr	1694(ra) # 80003f9a <namecmp>
    80005904:	12050e63          	beqz	a0,80005a40 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005908:	f2c40613          	addi	a2,s0,-212
    8000590c:	fb040593          	addi	a1,s0,-80
    80005910:	8526                	mv	a0,s1
    80005912:	ffffe097          	auipc	ra,0xffffe
    80005916:	6a2080e7          	jalr	1698(ra) # 80003fb4 <dirlookup>
    8000591a:	892a                	mv	s2,a0
    8000591c:	12050263          	beqz	a0,80005a40 <sys_unlink+0x1b0>
  ilock(ip);
    80005920:	ffffe097          	auipc	ra,0xffffe
    80005924:	1b0080e7          	jalr	432(ra) # 80003ad0 <ilock>
  if(ip->nlink < 1)
    80005928:	04a91783          	lh	a5,74(s2)
    8000592c:	08f05263          	blez	a5,800059b0 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005930:	04491703          	lh	a4,68(s2)
    80005934:	4785                	li	a5,1
    80005936:	08f70563          	beq	a4,a5,800059c0 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000593a:	4641                	li	a2,16
    8000593c:	4581                	li	a1,0
    8000593e:	fc040513          	addi	a0,s0,-64
    80005942:	ffffb097          	auipc	ra,0xffffb
    80005946:	396080e7          	jalr	918(ra) # 80000cd8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000594a:	4741                	li	a4,16
    8000594c:	f2c42683          	lw	a3,-212(s0)
    80005950:	fc040613          	addi	a2,s0,-64
    80005954:	4581                	li	a1,0
    80005956:	8526                	mv	a0,s1
    80005958:	ffffe097          	auipc	ra,0xffffe
    8000595c:	524080e7          	jalr	1316(ra) # 80003e7c <writei>
    80005960:	47c1                	li	a5,16
    80005962:	0af51563          	bne	a0,a5,80005a0c <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005966:	04491703          	lh	a4,68(s2)
    8000596a:	4785                	li	a5,1
    8000596c:	0af70863          	beq	a4,a5,80005a1c <sys_unlink+0x18c>
  iunlockput(dp);
    80005970:	8526                	mv	a0,s1
    80005972:	ffffe097          	auipc	ra,0xffffe
    80005976:	3c0080e7          	jalr	960(ra) # 80003d32 <iunlockput>
  ip->nlink--;
    8000597a:	04a95783          	lhu	a5,74(s2)
    8000597e:	37fd                	addiw	a5,a5,-1
    80005980:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005984:	854a                	mv	a0,s2
    80005986:	ffffe097          	auipc	ra,0xffffe
    8000598a:	080080e7          	jalr	128(ra) # 80003a06 <iupdate>
  iunlockput(ip);
    8000598e:	854a                	mv	a0,s2
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	3a2080e7          	jalr	930(ra) # 80003d32 <iunlockput>
  end_op();
    80005998:	fffff097          	auipc	ra,0xfffff
    8000599c:	b8e080e7          	jalr	-1138(ra) # 80004526 <end_op>
  return 0;
    800059a0:	4501                	li	a0,0
    800059a2:	a84d                	j	80005a54 <sys_unlink+0x1c4>
    end_op();
    800059a4:	fffff097          	auipc	ra,0xfffff
    800059a8:	b82080e7          	jalr	-1150(ra) # 80004526 <end_op>
    return -1;
    800059ac:	557d                	li	a0,-1
    800059ae:	a05d                	j	80005a54 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800059b0:	00003517          	auipc	a0,0x3
    800059b4:	e6850513          	addi	a0,a0,-408 # 80008818 <syscalls+0x2f8>
    800059b8:	ffffb097          	auipc	ra,0xffffb
    800059bc:	b76080e7          	jalr	-1162(ra) # 8000052e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059c0:	04c92703          	lw	a4,76(s2)
    800059c4:	02000793          	li	a5,32
    800059c8:	f6e7f9e3          	bgeu	a5,a4,8000593a <sys_unlink+0xaa>
    800059cc:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059d0:	4741                	li	a4,16
    800059d2:	86ce                	mv	a3,s3
    800059d4:	f1840613          	addi	a2,s0,-232
    800059d8:	4581                	li	a1,0
    800059da:	854a                	mv	a0,s2
    800059dc:	ffffe097          	auipc	ra,0xffffe
    800059e0:	3a8080e7          	jalr	936(ra) # 80003d84 <readi>
    800059e4:	47c1                	li	a5,16
    800059e6:	00f51b63          	bne	a0,a5,800059fc <sys_unlink+0x16c>
    if(de.inum != 0)
    800059ea:	f1845783          	lhu	a5,-232(s0)
    800059ee:	e7a1                	bnez	a5,80005a36 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059f0:	29c1                	addiw	s3,s3,16
    800059f2:	04c92783          	lw	a5,76(s2)
    800059f6:	fcf9ede3          	bltu	s3,a5,800059d0 <sys_unlink+0x140>
    800059fa:	b781                	j	8000593a <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800059fc:	00003517          	auipc	a0,0x3
    80005a00:	e3450513          	addi	a0,a0,-460 # 80008830 <syscalls+0x310>
    80005a04:	ffffb097          	auipc	ra,0xffffb
    80005a08:	b2a080e7          	jalr	-1238(ra) # 8000052e <panic>
    panic("unlink: writei");
    80005a0c:	00003517          	auipc	a0,0x3
    80005a10:	e3c50513          	addi	a0,a0,-452 # 80008848 <syscalls+0x328>
    80005a14:	ffffb097          	auipc	ra,0xffffb
    80005a18:	b1a080e7          	jalr	-1254(ra) # 8000052e <panic>
    dp->nlink--;
    80005a1c:	04a4d783          	lhu	a5,74(s1)
    80005a20:	37fd                	addiw	a5,a5,-1
    80005a22:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a26:	8526                	mv	a0,s1
    80005a28:	ffffe097          	auipc	ra,0xffffe
    80005a2c:	fde080e7          	jalr	-34(ra) # 80003a06 <iupdate>
    80005a30:	b781                	j	80005970 <sys_unlink+0xe0>
    return -1;
    80005a32:	557d                	li	a0,-1
    80005a34:	a005                	j	80005a54 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005a36:	854a                	mv	a0,s2
    80005a38:	ffffe097          	auipc	ra,0xffffe
    80005a3c:	2fa080e7          	jalr	762(ra) # 80003d32 <iunlockput>
  iunlockput(dp);
    80005a40:	8526                	mv	a0,s1
    80005a42:	ffffe097          	auipc	ra,0xffffe
    80005a46:	2f0080e7          	jalr	752(ra) # 80003d32 <iunlockput>
  end_op();
    80005a4a:	fffff097          	auipc	ra,0xfffff
    80005a4e:	adc080e7          	jalr	-1316(ra) # 80004526 <end_op>
  return -1;
    80005a52:	557d                	li	a0,-1
}
    80005a54:	70ae                	ld	ra,232(sp)
    80005a56:	740e                	ld	s0,224(sp)
    80005a58:	64ee                	ld	s1,216(sp)
    80005a5a:	694e                	ld	s2,208(sp)
    80005a5c:	69ae                	ld	s3,200(sp)
    80005a5e:	616d                	addi	sp,sp,240
    80005a60:	8082                	ret

0000000080005a62 <sys_open>:

uint64
sys_open(void)
{
    80005a62:	7131                	addi	sp,sp,-192
    80005a64:	fd06                	sd	ra,184(sp)
    80005a66:	f922                	sd	s0,176(sp)
    80005a68:	f526                	sd	s1,168(sp)
    80005a6a:	f14a                	sd	s2,160(sp)
    80005a6c:	ed4e                	sd	s3,152(sp)
    80005a6e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a70:	08000613          	li	a2,128
    80005a74:	f5040593          	addi	a1,s0,-176
    80005a78:	4501                	li	a0,0
    80005a7a:	ffffd097          	auipc	ra,0xffffd
    80005a7e:	448080e7          	jalr	1096(ra) # 80002ec2 <argstr>
    return -1;
    80005a82:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a84:	0c054163          	bltz	a0,80005b46 <sys_open+0xe4>
    80005a88:	f4c40593          	addi	a1,s0,-180
    80005a8c:	4505                	li	a0,1
    80005a8e:	ffffd097          	auipc	ra,0xffffd
    80005a92:	3f0080e7          	jalr	1008(ra) # 80002e7e <argint>
    80005a96:	0a054863          	bltz	a0,80005b46 <sys_open+0xe4>

  begin_op();
    80005a9a:	fffff097          	auipc	ra,0xfffff
    80005a9e:	a0c080e7          	jalr	-1524(ra) # 800044a6 <begin_op>

  if(omode & O_CREATE){
    80005aa2:	f4c42783          	lw	a5,-180(s0)
    80005aa6:	2007f793          	andi	a5,a5,512
    80005aaa:	cbdd                	beqz	a5,80005b60 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005aac:	4681                	li	a3,0
    80005aae:	4601                	li	a2,0
    80005ab0:	4589                	li	a1,2
    80005ab2:	f5040513          	addi	a0,s0,-176
    80005ab6:	00000097          	auipc	ra,0x0
    80005aba:	974080e7          	jalr	-1676(ra) # 8000542a <create>
    80005abe:	892a                	mv	s2,a0
    if(ip == 0){
    80005ac0:	c959                	beqz	a0,80005b56 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005ac2:	04491703          	lh	a4,68(s2)
    80005ac6:	478d                	li	a5,3
    80005ac8:	00f71763          	bne	a4,a5,80005ad6 <sys_open+0x74>
    80005acc:	04695703          	lhu	a4,70(s2)
    80005ad0:	47a5                	li	a5,9
    80005ad2:	0ce7ec63          	bltu	a5,a4,80005baa <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ad6:	fffff097          	auipc	ra,0xfffff
    80005ada:	de0080e7          	jalr	-544(ra) # 800048b6 <filealloc>
    80005ade:	89aa                	mv	s3,a0
    80005ae0:	10050263          	beqz	a0,80005be4 <sys_open+0x182>
    80005ae4:	00000097          	auipc	ra,0x0
    80005ae8:	904080e7          	jalr	-1788(ra) # 800053e8 <fdalloc>
    80005aec:	84aa                	mv	s1,a0
    80005aee:	0e054663          	bltz	a0,80005bda <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005af2:	04491703          	lh	a4,68(s2)
    80005af6:	478d                	li	a5,3
    80005af8:	0cf70463          	beq	a4,a5,80005bc0 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005afc:	4789                	li	a5,2
    80005afe:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005b02:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005b06:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005b0a:	f4c42783          	lw	a5,-180(s0)
    80005b0e:	0017c713          	xori	a4,a5,1
    80005b12:	8b05                	andi	a4,a4,1
    80005b14:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b18:	0037f713          	andi	a4,a5,3
    80005b1c:	00e03733          	snez	a4,a4
    80005b20:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005b24:	4007f793          	andi	a5,a5,1024
    80005b28:	c791                	beqz	a5,80005b34 <sys_open+0xd2>
    80005b2a:	04491703          	lh	a4,68(s2)
    80005b2e:	4789                	li	a5,2
    80005b30:	08f70f63          	beq	a4,a5,80005bce <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005b34:	854a                	mv	a0,s2
    80005b36:	ffffe097          	auipc	ra,0xffffe
    80005b3a:	05c080e7          	jalr	92(ra) # 80003b92 <iunlock>
  end_op();
    80005b3e:	fffff097          	auipc	ra,0xfffff
    80005b42:	9e8080e7          	jalr	-1560(ra) # 80004526 <end_op>

  return fd;
}
    80005b46:	8526                	mv	a0,s1
    80005b48:	70ea                	ld	ra,184(sp)
    80005b4a:	744a                	ld	s0,176(sp)
    80005b4c:	74aa                	ld	s1,168(sp)
    80005b4e:	790a                	ld	s2,160(sp)
    80005b50:	69ea                	ld	s3,152(sp)
    80005b52:	6129                	addi	sp,sp,192
    80005b54:	8082                	ret
      end_op();
    80005b56:	fffff097          	auipc	ra,0xfffff
    80005b5a:	9d0080e7          	jalr	-1584(ra) # 80004526 <end_op>
      return -1;
    80005b5e:	b7e5                	j	80005b46 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005b60:	f5040513          	addi	a0,s0,-176
    80005b64:	ffffe097          	auipc	ra,0xffffe
    80005b68:	722080e7          	jalr	1826(ra) # 80004286 <namei>
    80005b6c:	892a                	mv	s2,a0
    80005b6e:	c905                	beqz	a0,80005b9e <sys_open+0x13c>
    ilock(ip);
    80005b70:	ffffe097          	auipc	ra,0xffffe
    80005b74:	f60080e7          	jalr	-160(ra) # 80003ad0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b78:	04491703          	lh	a4,68(s2)
    80005b7c:	4785                	li	a5,1
    80005b7e:	f4f712e3          	bne	a4,a5,80005ac2 <sys_open+0x60>
    80005b82:	f4c42783          	lw	a5,-180(s0)
    80005b86:	dba1                	beqz	a5,80005ad6 <sys_open+0x74>
      iunlockput(ip);
    80005b88:	854a                	mv	a0,s2
    80005b8a:	ffffe097          	auipc	ra,0xffffe
    80005b8e:	1a8080e7          	jalr	424(ra) # 80003d32 <iunlockput>
      end_op();
    80005b92:	fffff097          	auipc	ra,0xfffff
    80005b96:	994080e7          	jalr	-1644(ra) # 80004526 <end_op>
      return -1;
    80005b9a:	54fd                	li	s1,-1
    80005b9c:	b76d                	j	80005b46 <sys_open+0xe4>
      end_op();
    80005b9e:	fffff097          	auipc	ra,0xfffff
    80005ba2:	988080e7          	jalr	-1656(ra) # 80004526 <end_op>
      return -1;
    80005ba6:	54fd                	li	s1,-1
    80005ba8:	bf79                	j	80005b46 <sys_open+0xe4>
    iunlockput(ip);
    80005baa:	854a                	mv	a0,s2
    80005bac:	ffffe097          	auipc	ra,0xffffe
    80005bb0:	186080e7          	jalr	390(ra) # 80003d32 <iunlockput>
    end_op();
    80005bb4:	fffff097          	auipc	ra,0xfffff
    80005bb8:	972080e7          	jalr	-1678(ra) # 80004526 <end_op>
    return -1;
    80005bbc:	54fd                	li	s1,-1
    80005bbe:	b761                	j	80005b46 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005bc0:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005bc4:	04691783          	lh	a5,70(s2)
    80005bc8:	02f99223          	sh	a5,36(s3)
    80005bcc:	bf2d                	j	80005b06 <sys_open+0xa4>
    itrunc(ip);
    80005bce:	854a                	mv	a0,s2
    80005bd0:	ffffe097          	auipc	ra,0xffffe
    80005bd4:	00e080e7          	jalr	14(ra) # 80003bde <itrunc>
    80005bd8:	bfb1                	j	80005b34 <sys_open+0xd2>
      fileclose(f);
    80005bda:	854e                	mv	a0,s3
    80005bdc:	fffff097          	auipc	ra,0xfffff
    80005be0:	d96080e7          	jalr	-618(ra) # 80004972 <fileclose>
    iunlockput(ip);
    80005be4:	854a                	mv	a0,s2
    80005be6:	ffffe097          	auipc	ra,0xffffe
    80005bea:	14c080e7          	jalr	332(ra) # 80003d32 <iunlockput>
    end_op();
    80005bee:	fffff097          	auipc	ra,0xfffff
    80005bf2:	938080e7          	jalr	-1736(ra) # 80004526 <end_op>
    return -1;
    80005bf6:	54fd                	li	s1,-1
    80005bf8:	b7b9                	j	80005b46 <sys_open+0xe4>

0000000080005bfa <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005bfa:	7175                	addi	sp,sp,-144
    80005bfc:	e506                	sd	ra,136(sp)
    80005bfe:	e122                	sd	s0,128(sp)
    80005c00:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005c02:	fffff097          	auipc	ra,0xfffff
    80005c06:	8a4080e7          	jalr	-1884(ra) # 800044a6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005c0a:	08000613          	li	a2,128
    80005c0e:	f7040593          	addi	a1,s0,-144
    80005c12:	4501                	li	a0,0
    80005c14:	ffffd097          	auipc	ra,0xffffd
    80005c18:	2ae080e7          	jalr	686(ra) # 80002ec2 <argstr>
    80005c1c:	02054963          	bltz	a0,80005c4e <sys_mkdir+0x54>
    80005c20:	4681                	li	a3,0
    80005c22:	4601                	li	a2,0
    80005c24:	4585                	li	a1,1
    80005c26:	f7040513          	addi	a0,s0,-144
    80005c2a:	00000097          	auipc	ra,0x0
    80005c2e:	800080e7          	jalr	-2048(ra) # 8000542a <create>
    80005c32:	cd11                	beqz	a0,80005c4e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c34:	ffffe097          	auipc	ra,0xffffe
    80005c38:	0fe080e7          	jalr	254(ra) # 80003d32 <iunlockput>
  end_op();
    80005c3c:	fffff097          	auipc	ra,0xfffff
    80005c40:	8ea080e7          	jalr	-1814(ra) # 80004526 <end_op>
  return 0;
    80005c44:	4501                	li	a0,0
}
    80005c46:	60aa                	ld	ra,136(sp)
    80005c48:	640a                	ld	s0,128(sp)
    80005c4a:	6149                	addi	sp,sp,144
    80005c4c:	8082                	ret
    end_op();
    80005c4e:	fffff097          	auipc	ra,0xfffff
    80005c52:	8d8080e7          	jalr	-1832(ra) # 80004526 <end_op>
    return -1;
    80005c56:	557d                	li	a0,-1
    80005c58:	b7fd                	j	80005c46 <sys_mkdir+0x4c>

0000000080005c5a <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c5a:	7135                	addi	sp,sp,-160
    80005c5c:	ed06                	sd	ra,152(sp)
    80005c5e:	e922                	sd	s0,144(sp)
    80005c60:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c62:	fffff097          	auipc	ra,0xfffff
    80005c66:	844080e7          	jalr	-1980(ra) # 800044a6 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c6a:	08000613          	li	a2,128
    80005c6e:	f7040593          	addi	a1,s0,-144
    80005c72:	4501                	li	a0,0
    80005c74:	ffffd097          	auipc	ra,0xffffd
    80005c78:	24e080e7          	jalr	590(ra) # 80002ec2 <argstr>
    80005c7c:	04054a63          	bltz	a0,80005cd0 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005c80:	f6c40593          	addi	a1,s0,-148
    80005c84:	4505                	li	a0,1
    80005c86:	ffffd097          	auipc	ra,0xffffd
    80005c8a:	1f8080e7          	jalr	504(ra) # 80002e7e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c8e:	04054163          	bltz	a0,80005cd0 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005c92:	f6840593          	addi	a1,s0,-152
    80005c96:	4509                	li	a0,2
    80005c98:	ffffd097          	auipc	ra,0xffffd
    80005c9c:	1e6080e7          	jalr	486(ra) # 80002e7e <argint>
     argint(1, &major) < 0 ||
    80005ca0:	02054863          	bltz	a0,80005cd0 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ca4:	f6841683          	lh	a3,-152(s0)
    80005ca8:	f6c41603          	lh	a2,-148(s0)
    80005cac:	458d                	li	a1,3
    80005cae:	f7040513          	addi	a0,s0,-144
    80005cb2:	fffff097          	auipc	ra,0xfffff
    80005cb6:	778080e7          	jalr	1912(ra) # 8000542a <create>
     argint(2, &minor) < 0 ||
    80005cba:	c919                	beqz	a0,80005cd0 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005cbc:	ffffe097          	auipc	ra,0xffffe
    80005cc0:	076080e7          	jalr	118(ra) # 80003d32 <iunlockput>
  end_op();
    80005cc4:	fffff097          	auipc	ra,0xfffff
    80005cc8:	862080e7          	jalr	-1950(ra) # 80004526 <end_op>
  return 0;
    80005ccc:	4501                	li	a0,0
    80005cce:	a031                	j	80005cda <sys_mknod+0x80>
    end_op();
    80005cd0:	fffff097          	auipc	ra,0xfffff
    80005cd4:	856080e7          	jalr	-1962(ra) # 80004526 <end_op>
    return -1;
    80005cd8:	557d                	li	a0,-1
}
    80005cda:	60ea                	ld	ra,152(sp)
    80005cdc:	644a                	ld	s0,144(sp)
    80005cde:	610d                	addi	sp,sp,160
    80005ce0:	8082                	ret

0000000080005ce2 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005ce2:	7135                	addi	sp,sp,-160
    80005ce4:	ed06                	sd	ra,152(sp)
    80005ce6:	e922                	sd	s0,144(sp)
    80005ce8:	e526                	sd	s1,136(sp)
    80005cea:	e14a                	sd	s2,128(sp)
    80005cec:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005cee:	ffffc097          	auipc	ra,0xffffc
    80005cf2:	caa080e7          	jalr	-854(ra) # 80001998 <myproc>
    80005cf6:	892a                	mv	s2,a0
  
  begin_op();
    80005cf8:	ffffe097          	auipc	ra,0xffffe
    80005cfc:	7ae080e7          	jalr	1966(ra) # 800044a6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005d00:	08000613          	li	a2,128
    80005d04:	f6040593          	addi	a1,s0,-160
    80005d08:	4501                	li	a0,0
    80005d0a:	ffffd097          	auipc	ra,0xffffd
    80005d0e:	1b8080e7          	jalr	440(ra) # 80002ec2 <argstr>
    80005d12:	04054b63          	bltz	a0,80005d68 <sys_chdir+0x86>
    80005d16:	f6040513          	addi	a0,s0,-160
    80005d1a:	ffffe097          	auipc	ra,0xffffe
    80005d1e:	56c080e7          	jalr	1388(ra) # 80004286 <namei>
    80005d22:	84aa                	mv	s1,a0
    80005d24:	c131                	beqz	a0,80005d68 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005d26:	ffffe097          	auipc	ra,0xffffe
    80005d2a:	daa080e7          	jalr	-598(ra) # 80003ad0 <ilock>
  if(ip->type != T_DIR){
    80005d2e:	04449703          	lh	a4,68(s1)
    80005d32:	4785                	li	a5,1
    80005d34:	04f71063          	bne	a4,a5,80005d74 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d38:	8526                	mv	a0,s1
    80005d3a:	ffffe097          	auipc	ra,0xffffe
    80005d3e:	e58080e7          	jalr	-424(ra) # 80003b92 <iunlock>
  iput(p->cwd);
    80005d42:	15093503          	ld	a0,336(s2)
    80005d46:	ffffe097          	auipc	ra,0xffffe
    80005d4a:	f44080e7          	jalr	-188(ra) # 80003c8a <iput>
  end_op();
    80005d4e:	ffffe097          	auipc	ra,0xffffe
    80005d52:	7d8080e7          	jalr	2008(ra) # 80004526 <end_op>
  p->cwd = ip;
    80005d56:	14993823          	sd	s1,336(s2)
  return 0;
    80005d5a:	4501                	li	a0,0
}
    80005d5c:	60ea                	ld	ra,152(sp)
    80005d5e:	644a                	ld	s0,144(sp)
    80005d60:	64aa                	ld	s1,136(sp)
    80005d62:	690a                	ld	s2,128(sp)
    80005d64:	610d                	addi	sp,sp,160
    80005d66:	8082                	ret
    end_op();
    80005d68:	ffffe097          	auipc	ra,0xffffe
    80005d6c:	7be080e7          	jalr	1982(ra) # 80004526 <end_op>
    return -1;
    80005d70:	557d                	li	a0,-1
    80005d72:	b7ed                	j	80005d5c <sys_chdir+0x7a>
    iunlockput(ip);
    80005d74:	8526                	mv	a0,s1
    80005d76:	ffffe097          	auipc	ra,0xffffe
    80005d7a:	fbc080e7          	jalr	-68(ra) # 80003d32 <iunlockput>
    end_op();
    80005d7e:	ffffe097          	auipc	ra,0xffffe
    80005d82:	7a8080e7          	jalr	1960(ra) # 80004526 <end_op>
    return -1;
    80005d86:	557d                	li	a0,-1
    80005d88:	bfd1                	j	80005d5c <sys_chdir+0x7a>

0000000080005d8a <sys_exec>:

uint64
sys_exec(void)
{
    80005d8a:	7145                	addi	sp,sp,-464
    80005d8c:	e786                	sd	ra,456(sp)
    80005d8e:	e3a2                	sd	s0,448(sp)
    80005d90:	ff26                	sd	s1,440(sp)
    80005d92:	fb4a                	sd	s2,432(sp)
    80005d94:	f74e                	sd	s3,424(sp)
    80005d96:	f352                	sd	s4,416(sp)
    80005d98:	ef56                	sd	s5,408(sp)
    80005d9a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d9c:	08000613          	li	a2,128
    80005da0:	f4040593          	addi	a1,s0,-192
    80005da4:	4501                	li	a0,0
    80005da6:	ffffd097          	auipc	ra,0xffffd
    80005daa:	11c080e7          	jalr	284(ra) # 80002ec2 <argstr>
    return -1;
    80005dae:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005db0:	0c054a63          	bltz	a0,80005e84 <sys_exec+0xfa>
    80005db4:	e3840593          	addi	a1,s0,-456
    80005db8:	4505                	li	a0,1
    80005dba:	ffffd097          	auipc	ra,0xffffd
    80005dbe:	0e6080e7          	jalr	230(ra) # 80002ea0 <argaddr>
    80005dc2:	0c054163          	bltz	a0,80005e84 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005dc6:	10000613          	li	a2,256
    80005dca:	4581                	li	a1,0
    80005dcc:	e4040513          	addi	a0,s0,-448
    80005dd0:	ffffb097          	auipc	ra,0xffffb
    80005dd4:	f08080e7          	jalr	-248(ra) # 80000cd8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005dd8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005ddc:	89a6                	mv	s3,s1
    80005dde:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005de0:	02000a13          	li	s4,32
    80005de4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005de8:	00391793          	slli	a5,s2,0x3
    80005dec:	e3040593          	addi	a1,s0,-464
    80005df0:	e3843503          	ld	a0,-456(s0)
    80005df4:	953e                	add	a0,a0,a5
    80005df6:	ffffd097          	auipc	ra,0xffffd
    80005dfa:	fee080e7          	jalr	-18(ra) # 80002de4 <fetchaddr>
    80005dfe:	02054a63          	bltz	a0,80005e32 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005e02:	e3043783          	ld	a5,-464(s0)
    80005e06:	c3b9                	beqz	a5,80005e4c <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e08:	ffffb097          	auipc	ra,0xffffb
    80005e0c:	cce080e7          	jalr	-818(ra) # 80000ad6 <kalloc>
    80005e10:	85aa                	mv	a1,a0
    80005e12:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e16:	cd11                	beqz	a0,80005e32 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005e18:	6605                	lui	a2,0x1
    80005e1a:	e3043503          	ld	a0,-464(s0)
    80005e1e:	ffffd097          	auipc	ra,0xffffd
    80005e22:	018080e7          	jalr	24(ra) # 80002e36 <fetchstr>
    80005e26:	00054663          	bltz	a0,80005e32 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005e2a:	0905                	addi	s2,s2,1
    80005e2c:	09a1                	addi	s3,s3,8
    80005e2e:	fb491be3          	bne	s2,s4,80005de4 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e32:	10048913          	addi	s2,s1,256
    80005e36:	6088                	ld	a0,0(s1)
    80005e38:	c529                	beqz	a0,80005e82 <sys_exec+0xf8>
    kfree(argv[i]);
    80005e3a:	ffffb097          	auipc	ra,0xffffb
    80005e3e:	ba0080e7          	jalr	-1120(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e42:	04a1                	addi	s1,s1,8
    80005e44:	ff2499e3          	bne	s1,s2,80005e36 <sys_exec+0xac>
  return -1;
    80005e48:	597d                	li	s2,-1
    80005e4a:	a82d                	j	80005e84 <sys_exec+0xfa>
      argv[i] = 0;
    80005e4c:	0a8e                	slli	s5,s5,0x3
    80005e4e:	fc040793          	addi	a5,s0,-64
    80005e52:	9abe                	add	s5,s5,a5
    80005e54:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd0e80>
  int ret = exec(path, argv);
    80005e58:	e4040593          	addi	a1,s0,-448
    80005e5c:	f4040513          	addi	a0,s0,-192
    80005e60:	fffff097          	auipc	ra,0xfffff
    80005e64:	170080e7          	jalr	368(ra) # 80004fd0 <exec>
    80005e68:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e6a:	10048993          	addi	s3,s1,256
    80005e6e:	6088                	ld	a0,0(s1)
    80005e70:	c911                	beqz	a0,80005e84 <sys_exec+0xfa>
    kfree(argv[i]);
    80005e72:	ffffb097          	auipc	ra,0xffffb
    80005e76:	b68080e7          	jalr	-1176(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e7a:	04a1                	addi	s1,s1,8
    80005e7c:	ff3499e3          	bne	s1,s3,80005e6e <sys_exec+0xe4>
    80005e80:	a011                	j	80005e84 <sys_exec+0xfa>
  return -1;
    80005e82:	597d                	li	s2,-1
}
    80005e84:	854a                	mv	a0,s2
    80005e86:	60be                	ld	ra,456(sp)
    80005e88:	641e                	ld	s0,448(sp)
    80005e8a:	74fa                	ld	s1,440(sp)
    80005e8c:	795a                	ld	s2,432(sp)
    80005e8e:	79ba                	ld	s3,424(sp)
    80005e90:	7a1a                	ld	s4,416(sp)
    80005e92:	6afa                	ld	s5,408(sp)
    80005e94:	6179                	addi	sp,sp,464
    80005e96:	8082                	ret

0000000080005e98 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e98:	7139                	addi	sp,sp,-64
    80005e9a:	fc06                	sd	ra,56(sp)
    80005e9c:	f822                	sd	s0,48(sp)
    80005e9e:	f426                	sd	s1,40(sp)
    80005ea0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ea2:	ffffc097          	auipc	ra,0xffffc
    80005ea6:	af6080e7          	jalr	-1290(ra) # 80001998 <myproc>
    80005eaa:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005eac:	fd840593          	addi	a1,s0,-40
    80005eb0:	4501                	li	a0,0
    80005eb2:	ffffd097          	auipc	ra,0xffffd
    80005eb6:	fee080e7          	jalr	-18(ra) # 80002ea0 <argaddr>
    return -1;
    80005eba:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005ebc:	0e054063          	bltz	a0,80005f9c <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005ec0:	fc840593          	addi	a1,s0,-56
    80005ec4:	fd040513          	addi	a0,s0,-48
    80005ec8:	fffff097          	auipc	ra,0xfffff
    80005ecc:	dda080e7          	jalr	-550(ra) # 80004ca2 <pipealloc>
    return -1;
    80005ed0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ed2:	0c054563          	bltz	a0,80005f9c <sys_pipe+0x104>
  fd0 = -1;
    80005ed6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005eda:	fd043503          	ld	a0,-48(s0)
    80005ede:	fffff097          	auipc	ra,0xfffff
    80005ee2:	50a080e7          	jalr	1290(ra) # 800053e8 <fdalloc>
    80005ee6:	fca42223          	sw	a0,-60(s0)
    80005eea:	08054c63          	bltz	a0,80005f82 <sys_pipe+0xea>
    80005eee:	fc843503          	ld	a0,-56(s0)
    80005ef2:	fffff097          	auipc	ra,0xfffff
    80005ef6:	4f6080e7          	jalr	1270(ra) # 800053e8 <fdalloc>
    80005efa:	fca42023          	sw	a0,-64(s0)
    80005efe:	06054863          	bltz	a0,80005f6e <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f02:	4691                	li	a3,4
    80005f04:	fc440613          	addi	a2,s0,-60
    80005f08:	fd843583          	ld	a1,-40(s0)
    80005f0c:	68a8                	ld	a0,80(s1)
    80005f0e:	ffffb097          	auipc	ra,0xffffb
    80005f12:	74a080e7          	jalr	1866(ra) # 80001658 <copyout>
    80005f16:	02054063          	bltz	a0,80005f36 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f1a:	4691                	li	a3,4
    80005f1c:	fc040613          	addi	a2,s0,-64
    80005f20:	fd843583          	ld	a1,-40(s0)
    80005f24:	0591                	addi	a1,a1,4
    80005f26:	68a8                	ld	a0,80(s1)
    80005f28:	ffffb097          	auipc	ra,0xffffb
    80005f2c:	730080e7          	jalr	1840(ra) # 80001658 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f30:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f32:	06055563          	bgez	a0,80005f9c <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005f36:	fc442783          	lw	a5,-60(s0)
    80005f3a:	07e9                	addi	a5,a5,26
    80005f3c:	078e                	slli	a5,a5,0x3
    80005f3e:	97a6                	add	a5,a5,s1
    80005f40:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f44:	fc042503          	lw	a0,-64(s0)
    80005f48:	0569                	addi	a0,a0,26
    80005f4a:	050e                	slli	a0,a0,0x3
    80005f4c:	9526                	add	a0,a0,s1
    80005f4e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005f52:	fd043503          	ld	a0,-48(s0)
    80005f56:	fffff097          	auipc	ra,0xfffff
    80005f5a:	a1c080e7          	jalr	-1508(ra) # 80004972 <fileclose>
    fileclose(wf);
    80005f5e:	fc843503          	ld	a0,-56(s0)
    80005f62:	fffff097          	auipc	ra,0xfffff
    80005f66:	a10080e7          	jalr	-1520(ra) # 80004972 <fileclose>
    return -1;
    80005f6a:	57fd                	li	a5,-1
    80005f6c:	a805                	j	80005f9c <sys_pipe+0x104>
    if(fd0 >= 0)
    80005f6e:	fc442783          	lw	a5,-60(s0)
    80005f72:	0007c863          	bltz	a5,80005f82 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005f76:	01a78513          	addi	a0,a5,26
    80005f7a:	050e                	slli	a0,a0,0x3
    80005f7c:	9526                	add	a0,a0,s1
    80005f7e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005f82:	fd043503          	ld	a0,-48(s0)
    80005f86:	fffff097          	auipc	ra,0xfffff
    80005f8a:	9ec080e7          	jalr	-1556(ra) # 80004972 <fileclose>
    fileclose(wf);
    80005f8e:	fc843503          	ld	a0,-56(s0)
    80005f92:	fffff097          	auipc	ra,0xfffff
    80005f96:	9e0080e7          	jalr	-1568(ra) # 80004972 <fileclose>
    return -1;
    80005f9a:	57fd                	li	a5,-1
}
    80005f9c:	853e                	mv	a0,a5
    80005f9e:	70e2                	ld	ra,56(sp)
    80005fa0:	7442                	ld	s0,48(sp)
    80005fa2:	74a2                	ld	s1,40(sp)
    80005fa4:	6121                	addi	sp,sp,64
    80005fa6:	8082                	ret
	...

0000000080005fb0 <kernelvec>:
    80005fb0:	7111                	addi	sp,sp,-256
    80005fb2:	e006                	sd	ra,0(sp)
    80005fb4:	e40a                	sd	sp,8(sp)
    80005fb6:	e80e                	sd	gp,16(sp)
    80005fb8:	ec12                	sd	tp,24(sp)
    80005fba:	f016                	sd	t0,32(sp)
    80005fbc:	f41a                	sd	t1,40(sp)
    80005fbe:	f81e                	sd	t2,48(sp)
    80005fc0:	fc22                	sd	s0,56(sp)
    80005fc2:	e0a6                	sd	s1,64(sp)
    80005fc4:	e4aa                	sd	a0,72(sp)
    80005fc6:	e8ae                	sd	a1,80(sp)
    80005fc8:	ecb2                	sd	a2,88(sp)
    80005fca:	f0b6                	sd	a3,96(sp)
    80005fcc:	f4ba                	sd	a4,104(sp)
    80005fce:	f8be                	sd	a5,112(sp)
    80005fd0:	fcc2                	sd	a6,120(sp)
    80005fd2:	e146                	sd	a7,128(sp)
    80005fd4:	e54a                	sd	s2,136(sp)
    80005fd6:	e94e                	sd	s3,144(sp)
    80005fd8:	ed52                	sd	s4,152(sp)
    80005fda:	f156                	sd	s5,160(sp)
    80005fdc:	f55a                	sd	s6,168(sp)
    80005fde:	f95e                	sd	s7,176(sp)
    80005fe0:	fd62                	sd	s8,184(sp)
    80005fe2:	e1e6                	sd	s9,192(sp)
    80005fe4:	e5ea                	sd	s10,200(sp)
    80005fe6:	e9ee                	sd	s11,208(sp)
    80005fe8:	edf2                	sd	t3,216(sp)
    80005fea:	f1f6                	sd	t4,224(sp)
    80005fec:	f5fa                	sd	t5,232(sp)
    80005fee:	f9fe                	sd	t6,240(sp)
    80005ff0:	cc1fc0ef          	jal	ra,80002cb0 <kerneltrap>
    80005ff4:	6082                	ld	ra,0(sp)
    80005ff6:	6122                	ld	sp,8(sp)
    80005ff8:	61c2                	ld	gp,16(sp)
    80005ffa:	7282                	ld	t0,32(sp)
    80005ffc:	7322                	ld	t1,40(sp)
    80005ffe:	73c2                	ld	t2,48(sp)
    80006000:	7462                	ld	s0,56(sp)
    80006002:	6486                	ld	s1,64(sp)
    80006004:	6526                	ld	a0,72(sp)
    80006006:	65c6                	ld	a1,80(sp)
    80006008:	6666                	ld	a2,88(sp)
    8000600a:	7686                	ld	a3,96(sp)
    8000600c:	7726                	ld	a4,104(sp)
    8000600e:	77c6                	ld	a5,112(sp)
    80006010:	7866                	ld	a6,120(sp)
    80006012:	688a                	ld	a7,128(sp)
    80006014:	692a                	ld	s2,136(sp)
    80006016:	69ca                	ld	s3,144(sp)
    80006018:	6a6a                	ld	s4,152(sp)
    8000601a:	7a8a                	ld	s5,160(sp)
    8000601c:	7b2a                	ld	s6,168(sp)
    8000601e:	7bca                	ld	s7,176(sp)
    80006020:	7c6a                	ld	s8,184(sp)
    80006022:	6c8e                	ld	s9,192(sp)
    80006024:	6d2e                	ld	s10,200(sp)
    80006026:	6dce                	ld	s11,208(sp)
    80006028:	6e6e                	ld	t3,216(sp)
    8000602a:	7e8e                	ld	t4,224(sp)
    8000602c:	7f2e                	ld	t5,232(sp)
    8000602e:	7fce                	ld	t6,240(sp)
    80006030:	6111                	addi	sp,sp,256
    80006032:	10200073          	sret
    80006036:	00000013          	nop
    8000603a:	00000013          	nop
    8000603e:	0001                	nop

0000000080006040 <timervec>:
    80006040:	34051573          	csrrw	a0,mscratch,a0
    80006044:	e10c                	sd	a1,0(a0)
    80006046:	e510                	sd	a2,8(a0)
    80006048:	e914                	sd	a3,16(a0)
    8000604a:	6d0c                	ld	a1,24(a0)
    8000604c:	7110                	ld	a2,32(a0)
    8000604e:	6194                	ld	a3,0(a1)
    80006050:	96b2                	add	a3,a3,a2
    80006052:	e194                	sd	a3,0(a1)
    80006054:	4589                	li	a1,2
    80006056:	14459073          	csrw	sip,a1
    8000605a:	6914                	ld	a3,16(a0)
    8000605c:	6510                	ld	a2,8(a0)
    8000605e:	610c                	ld	a1,0(a0)
    80006060:	34051573          	csrrw	a0,mscratch,a0
    80006064:	30200073          	mret
	...

000000008000606a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000606a:	1141                	addi	sp,sp,-16
    8000606c:	e422                	sd	s0,8(sp)
    8000606e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006070:	0c0007b7          	lui	a5,0xc000
    80006074:	4705                	li	a4,1
    80006076:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006078:	c3d8                	sw	a4,4(a5)
}
    8000607a:	6422                	ld	s0,8(sp)
    8000607c:	0141                	addi	sp,sp,16
    8000607e:	8082                	ret

0000000080006080 <plicinithart>:

void
plicinithart(void)
{
    80006080:	1141                	addi	sp,sp,-16
    80006082:	e406                	sd	ra,8(sp)
    80006084:	e022                	sd	s0,0(sp)
    80006086:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006088:	ffffc097          	auipc	ra,0xffffc
    8000608c:	8e4080e7          	jalr	-1820(ra) # 8000196c <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006090:	0085171b          	slliw	a4,a0,0x8
    80006094:	0c0027b7          	lui	a5,0xc002
    80006098:	97ba                	add	a5,a5,a4
    8000609a:	40200713          	li	a4,1026
    8000609e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800060a2:	00d5151b          	slliw	a0,a0,0xd
    800060a6:	0c2017b7          	lui	a5,0xc201
    800060aa:	953e                	add	a0,a0,a5
    800060ac:	00052023          	sw	zero,0(a0)
}
    800060b0:	60a2                	ld	ra,8(sp)
    800060b2:	6402                	ld	s0,0(sp)
    800060b4:	0141                	addi	sp,sp,16
    800060b6:	8082                	ret

00000000800060b8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800060b8:	1141                	addi	sp,sp,-16
    800060ba:	e406                	sd	ra,8(sp)
    800060bc:	e022                	sd	s0,0(sp)
    800060be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060c0:	ffffc097          	auipc	ra,0xffffc
    800060c4:	8ac080e7          	jalr	-1876(ra) # 8000196c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800060c8:	00d5179b          	slliw	a5,a0,0xd
    800060cc:	0c201537          	lui	a0,0xc201
    800060d0:	953e                	add	a0,a0,a5
  return irq;
}
    800060d2:	4148                	lw	a0,4(a0)
    800060d4:	60a2                	ld	ra,8(sp)
    800060d6:	6402                	ld	s0,0(sp)
    800060d8:	0141                	addi	sp,sp,16
    800060da:	8082                	ret

00000000800060dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800060dc:	1101                	addi	sp,sp,-32
    800060de:	ec06                	sd	ra,24(sp)
    800060e0:	e822                	sd	s0,16(sp)
    800060e2:	e426                	sd	s1,8(sp)
    800060e4:	1000                	addi	s0,sp,32
    800060e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800060e8:	ffffc097          	auipc	ra,0xffffc
    800060ec:	884080e7          	jalr	-1916(ra) # 8000196c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800060f0:	00d5151b          	slliw	a0,a0,0xd
    800060f4:	0c2017b7          	lui	a5,0xc201
    800060f8:	97aa                	add	a5,a5,a0
    800060fa:	c3c4                	sw	s1,4(a5)
}
    800060fc:	60e2                	ld	ra,24(sp)
    800060fe:	6442                	ld	s0,16(sp)
    80006100:	64a2                	ld	s1,8(sp)
    80006102:	6105                	addi	sp,sp,32
    80006104:	8082                	ret

0000000080006106 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006106:	1141                	addi	sp,sp,-16
    80006108:	e406                	sd	ra,8(sp)
    8000610a:	e022                	sd	s0,0(sp)
    8000610c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000610e:	479d                	li	a5,7
    80006110:	06a7c963          	blt	a5,a0,80006182 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006114:	00025797          	auipc	a5,0x25
    80006118:	eec78793          	addi	a5,a5,-276 # 8002b000 <disk>
    8000611c:	00a78733          	add	a4,a5,a0
    80006120:	6789                	lui	a5,0x2
    80006122:	97ba                	add	a5,a5,a4
    80006124:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006128:	e7ad                	bnez	a5,80006192 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000612a:	00451793          	slli	a5,a0,0x4
    8000612e:	00027717          	auipc	a4,0x27
    80006132:	ed270713          	addi	a4,a4,-302 # 8002d000 <disk+0x2000>
    80006136:	6314                	ld	a3,0(a4)
    80006138:	96be                	add	a3,a3,a5
    8000613a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000613e:	6314                	ld	a3,0(a4)
    80006140:	96be                	add	a3,a3,a5
    80006142:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006146:	6314                	ld	a3,0(a4)
    80006148:	96be                	add	a3,a3,a5
    8000614a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000614e:	6318                	ld	a4,0(a4)
    80006150:	97ba                	add	a5,a5,a4
    80006152:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006156:	00025797          	auipc	a5,0x25
    8000615a:	eaa78793          	addi	a5,a5,-342 # 8002b000 <disk>
    8000615e:	97aa                	add	a5,a5,a0
    80006160:	6509                	lui	a0,0x2
    80006162:	953e                	add	a0,a0,a5
    80006164:	4785                	li	a5,1
    80006166:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000616a:	00027517          	auipc	a0,0x27
    8000616e:	eae50513          	addi	a0,a0,-338 # 8002d018 <disk+0x2018>
    80006172:	ffffc097          	auipc	ra,0xffffc
    80006176:	12e080e7          	jalr	302(ra) # 800022a0 <wakeup>
}
    8000617a:	60a2                	ld	ra,8(sp)
    8000617c:	6402                	ld	s0,0(sp)
    8000617e:	0141                	addi	sp,sp,16
    80006180:	8082                	ret
    panic("free_desc 1");
    80006182:	00002517          	auipc	a0,0x2
    80006186:	6d650513          	addi	a0,a0,1750 # 80008858 <syscalls+0x338>
    8000618a:	ffffa097          	auipc	ra,0xffffa
    8000618e:	3a4080e7          	jalr	932(ra) # 8000052e <panic>
    panic("free_desc 2");
    80006192:	00002517          	auipc	a0,0x2
    80006196:	6d650513          	addi	a0,a0,1750 # 80008868 <syscalls+0x348>
    8000619a:	ffffa097          	auipc	ra,0xffffa
    8000619e:	394080e7          	jalr	916(ra) # 8000052e <panic>

00000000800061a2 <virtio_disk_init>:
{
    800061a2:	1101                	addi	sp,sp,-32
    800061a4:	ec06                	sd	ra,24(sp)
    800061a6:	e822                	sd	s0,16(sp)
    800061a8:	e426                	sd	s1,8(sp)
    800061aa:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800061ac:	00002597          	auipc	a1,0x2
    800061b0:	6cc58593          	addi	a1,a1,1740 # 80008878 <syscalls+0x358>
    800061b4:	00027517          	auipc	a0,0x27
    800061b8:	f7450513          	addi	a0,a0,-140 # 8002d128 <disk+0x2128>
    800061bc:	ffffb097          	auipc	ra,0xffffb
    800061c0:	97a080e7          	jalr	-1670(ra) # 80000b36 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061c4:	100017b7          	lui	a5,0x10001
    800061c8:	4398                	lw	a4,0(a5)
    800061ca:	2701                	sext.w	a4,a4
    800061cc:	747277b7          	lui	a5,0x74727
    800061d0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800061d4:	0ef71163          	bne	a4,a5,800062b6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800061d8:	100017b7          	lui	a5,0x10001
    800061dc:	43dc                	lw	a5,4(a5)
    800061de:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061e0:	4705                	li	a4,1
    800061e2:	0ce79a63          	bne	a5,a4,800062b6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061e6:	100017b7          	lui	a5,0x10001
    800061ea:	479c                	lw	a5,8(a5)
    800061ec:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800061ee:	4709                	li	a4,2
    800061f0:	0ce79363          	bne	a5,a4,800062b6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800061f4:	100017b7          	lui	a5,0x10001
    800061f8:	47d8                	lw	a4,12(a5)
    800061fa:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061fc:	554d47b7          	lui	a5,0x554d4
    80006200:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006204:	0af71963          	bne	a4,a5,800062b6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006208:	100017b7          	lui	a5,0x10001
    8000620c:	4705                	li	a4,1
    8000620e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006210:	470d                	li	a4,3
    80006212:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006214:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006216:	c7ffe737          	lui	a4,0xc7ffe
    8000621a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd075f>
    8000621e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006220:	2701                	sext.w	a4,a4
    80006222:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006224:	472d                	li	a4,11
    80006226:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006228:	473d                	li	a4,15
    8000622a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000622c:	6705                	lui	a4,0x1
    8000622e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006230:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006234:	5bdc                	lw	a5,52(a5)
    80006236:	2781                	sext.w	a5,a5
  if(max == 0)
    80006238:	c7d9                	beqz	a5,800062c6 <virtio_disk_init+0x124>
  if(max < NUM)
    8000623a:	471d                	li	a4,7
    8000623c:	08f77d63          	bgeu	a4,a5,800062d6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006240:	100014b7          	lui	s1,0x10001
    80006244:	47a1                	li	a5,8
    80006246:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006248:	6609                	lui	a2,0x2
    8000624a:	4581                	li	a1,0
    8000624c:	00025517          	auipc	a0,0x25
    80006250:	db450513          	addi	a0,a0,-588 # 8002b000 <disk>
    80006254:	ffffb097          	auipc	ra,0xffffb
    80006258:	a84080e7          	jalr	-1404(ra) # 80000cd8 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000625c:	00025717          	auipc	a4,0x25
    80006260:	da470713          	addi	a4,a4,-604 # 8002b000 <disk>
    80006264:	00c75793          	srli	a5,a4,0xc
    80006268:	2781                	sext.w	a5,a5
    8000626a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000626c:	00027797          	auipc	a5,0x27
    80006270:	d9478793          	addi	a5,a5,-620 # 8002d000 <disk+0x2000>
    80006274:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006276:	00025717          	auipc	a4,0x25
    8000627a:	e0a70713          	addi	a4,a4,-502 # 8002b080 <disk+0x80>
    8000627e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006280:	00026717          	auipc	a4,0x26
    80006284:	d8070713          	addi	a4,a4,-640 # 8002c000 <disk+0x1000>
    80006288:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000628a:	4705                	li	a4,1
    8000628c:	00e78c23          	sb	a4,24(a5)
    80006290:	00e78ca3          	sb	a4,25(a5)
    80006294:	00e78d23          	sb	a4,26(a5)
    80006298:	00e78da3          	sb	a4,27(a5)
    8000629c:	00e78e23          	sb	a4,28(a5)
    800062a0:	00e78ea3          	sb	a4,29(a5)
    800062a4:	00e78f23          	sb	a4,30(a5)
    800062a8:	00e78fa3          	sb	a4,31(a5)
}
    800062ac:	60e2                	ld	ra,24(sp)
    800062ae:	6442                	ld	s0,16(sp)
    800062b0:	64a2                	ld	s1,8(sp)
    800062b2:	6105                	addi	sp,sp,32
    800062b4:	8082                	ret
    panic("could not find virtio disk");
    800062b6:	00002517          	auipc	a0,0x2
    800062ba:	5d250513          	addi	a0,a0,1490 # 80008888 <syscalls+0x368>
    800062be:	ffffa097          	auipc	ra,0xffffa
    800062c2:	270080e7          	jalr	624(ra) # 8000052e <panic>
    panic("virtio disk has no queue 0");
    800062c6:	00002517          	auipc	a0,0x2
    800062ca:	5e250513          	addi	a0,a0,1506 # 800088a8 <syscalls+0x388>
    800062ce:	ffffa097          	auipc	ra,0xffffa
    800062d2:	260080e7          	jalr	608(ra) # 8000052e <panic>
    panic("virtio disk max queue too short");
    800062d6:	00002517          	auipc	a0,0x2
    800062da:	5f250513          	addi	a0,a0,1522 # 800088c8 <syscalls+0x3a8>
    800062de:	ffffa097          	auipc	ra,0xffffa
    800062e2:	250080e7          	jalr	592(ra) # 8000052e <panic>

00000000800062e6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800062e6:	7119                	addi	sp,sp,-128
    800062e8:	fc86                	sd	ra,120(sp)
    800062ea:	f8a2                	sd	s0,112(sp)
    800062ec:	f4a6                	sd	s1,104(sp)
    800062ee:	f0ca                	sd	s2,96(sp)
    800062f0:	ecce                	sd	s3,88(sp)
    800062f2:	e8d2                	sd	s4,80(sp)
    800062f4:	e4d6                	sd	s5,72(sp)
    800062f6:	e0da                	sd	s6,64(sp)
    800062f8:	fc5e                	sd	s7,56(sp)
    800062fa:	f862                	sd	s8,48(sp)
    800062fc:	f466                	sd	s9,40(sp)
    800062fe:	f06a                	sd	s10,32(sp)
    80006300:	ec6e                	sd	s11,24(sp)
    80006302:	0100                	addi	s0,sp,128
    80006304:	8aaa                	mv	s5,a0
    80006306:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006308:	00c52c83          	lw	s9,12(a0)
    8000630c:	001c9c9b          	slliw	s9,s9,0x1
    80006310:	1c82                	slli	s9,s9,0x20
    80006312:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006316:	00027517          	auipc	a0,0x27
    8000631a:	e1250513          	addi	a0,a0,-494 # 8002d128 <disk+0x2128>
    8000631e:	ffffb097          	auipc	ra,0xffffb
    80006322:	8a8080e7          	jalr	-1880(ra) # 80000bc6 <acquire>
  for(int i = 0; i < 3; i++){
    80006326:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006328:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000632a:	00025c17          	auipc	s8,0x25
    8000632e:	cd6c0c13          	addi	s8,s8,-810 # 8002b000 <disk>
    80006332:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006334:	4b0d                	li	s6,3
    80006336:	a0ad                	j	800063a0 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006338:	00fc0733          	add	a4,s8,a5
    8000633c:	975e                	add	a4,a4,s7
    8000633e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006342:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006344:	0207c563          	bltz	a5,8000636e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006348:	2905                	addiw	s2,s2,1
    8000634a:	0611                	addi	a2,a2,4
    8000634c:	19690d63          	beq	s2,s6,800064e6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006350:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006352:	00027717          	auipc	a4,0x27
    80006356:	cc670713          	addi	a4,a4,-826 # 8002d018 <disk+0x2018>
    8000635a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000635c:	00074683          	lbu	a3,0(a4)
    80006360:	fee1                	bnez	a3,80006338 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006362:	2785                	addiw	a5,a5,1
    80006364:	0705                	addi	a4,a4,1
    80006366:	fe979be3          	bne	a5,s1,8000635c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000636a:	57fd                	li	a5,-1
    8000636c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000636e:	01205d63          	blez	s2,80006388 <virtio_disk_rw+0xa2>
    80006372:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006374:	000a2503          	lw	a0,0(s4)
    80006378:	00000097          	auipc	ra,0x0
    8000637c:	d8e080e7          	jalr	-626(ra) # 80006106 <free_desc>
      for(int j = 0; j < i; j++)
    80006380:	2d85                	addiw	s11,s11,1
    80006382:	0a11                	addi	s4,s4,4
    80006384:	ffb918e3          	bne	s2,s11,80006374 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006388:	00027597          	auipc	a1,0x27
    8000638c:	da058593          	addi	a1,a1,-608 # 8002d128 <disk+0x2128>
    80006390:	00027517          	auipc	a0,0x27
    80006394:	c8850513          	addi	a0,a0,-888 # 8002d018 <disk+0x2018>
    80006398:	ffffc097          	auipc	ra,0xffffc
    8000639c:	d7a080e7          	jalr	-646(ra) # 80002112 <sleep>
  for(int i = 0; i < 3; i++){
    800063a0:	f8040a13          	addi	s4,s0,-128
{
    800063a4:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800063a6:	894e                	mv	s2,s3
    800063a8:	b765                	j	80006350 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800063aa:	00027697          	auipc	a3,0x27
    800063ae:	c566b683          	ld	a3,-938(a3) # 8002d000 <disk+0x2000>
    800063b2:	96ba                	add	a3,a3,a4
    800063b4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800063b8:	00025817          	auipc	a6,0x25
    800063bc:	c4880813          	addi	a6,a6,-952 # 8002b000 <disk>
    800063c0:	00027697          	auipc	a3,0x27
    800063c4:	c4068693          	addi	a3,a3,-960 # 8002d000 <disk+0x2000>
    800063c8:	6290                	ld	a2,0(a3)
    800063ca:	963a                	add	a2,a2,a4
    800063cc:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800063d0:	0015e593          	ori	a1,a1,1
    800063d4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800063d8:	f8842603          	lw	a2,-120(s0)
    800063dc:	628c                	ld	a1,0(a3)
    800063de:	972e                	add	a4,a4,a1
    800063e0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800063e4:	20050593          	addi	a1,a0,512
    800063e8:	0592                	slli	a1,a1,0x4
    800063ea:	95c2                	add	a1,a1,a6
    800063ec:	577d                	li	a4,-1
    800063ee:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800063f2:	00461713          	slli	a4,a2,0x4
    800063f6:	6290                	ld	a2,0(a3)
    800063f8:	963a                	add	a2,a2,a4
    800063fa:	03078793          	addi	a5,a5,48
    800063fe:	97c2                	add	a5,a5,a6
    80006400:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006402:	629c                	ld	a5,0(a3)
    80006404:	97ba                	add	a5,a5,a4
    80006406:	4605                	li	a2,1
    80006408:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000640a:	629c                	ld	a5,0(a3)
    8000640c:	97ba                	add	a5,a5,a4
    8000640e:	4809                	li	a6,2
    80006410:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006414:	629c                	ld	a5,0(a3)
    80006416:	973e                	add	a4,a4,a5
    80006418:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000641c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006420:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006424:	6698                	ld	a4,8(a3)
    80006426:	00275783          	lhu	a5,2(a4)
    8000642a:	8b9d                	andi	a5,a5,7
    8000642c:	0786                	slli	a5,a5,0x1
    8000642e:	97ba                	add	a5,a5,a4
    80006430:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006434:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006438:	6698                	ld	a4,8(a3)
    8000643a:	00275783          	lhu	a5,2(a4)
    8000643e:	2785                	addiw	a5,a5,1
    80006440:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006444:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006448:	100017b7          	lui	a5,0x10001
    8000644c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006450:	004aa783          	lw	a5,4(s5)
    80006454:	02c79163          	bne	a5,a2,80006476 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006458:	00027917          	auipc	s2,0x27
    8000645c:	cd090913          	addi	s2,s2,-816 # 8002d128 <disk+0x2128>
  while(b->disk == 1) {
    80006460:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006462:	85ca                	mv	a1,s2
    80006464:	8556                	mv	a0,s5
    80006466:	ffffc097          	auipc	ra,0xffffc
    8000646a:	cac080e7          	jalr	-852(ra) # 80002112 <sleep>
  while(b->disk == 1) {
    8000646e:	004aa783          	lw	a5,4(s5)
    80006472:	fe9788e3          	beq	a5,s1,80006462 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006476:	f8042903          	lw	s2,-128(s0)
    8000647a:	20090793          	addi	a5,s2,512
    8000647e:	00479713          	slli	a4,a5,0x4
    80006482:	00025797          	auipc	a5,0x25
    80006486:	b7e78793          	addi	a5,a5,-1154 # 8002b000 <disk>
    8000648a:	97ba                	add	a5,a5,a4
    8000648c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006490:	00027997          	auipc	s3,0x27
    80006494:	b7098993          	addi	s3,s3,-1168 # 8002d000 <disk+0x2000>
    80006498:	00491713          	slli	a4,s2,0x4
    8000649c:	0009b783          	ld	a5,0(s3)
    800064a0:	97ba                	add	a5,a5,a4
    800064a2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800064a6:	854a                	mv	a0,s2
    800064a8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800064ac:	00000097          	auipc	ra,0x0
    800064b0:	c5a080e7          	jalr	-934(ra) # 80006106 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800064b4:	8885                	andi	s1,s1,1
    800064b6:	f0ed                	bnez	s1,80006498 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800064b8:	00027517          	auipc	a0,0x27
    800064bc:	c7050513          	addi	a0,a0,-912 # 8002d128 <disk+0x2128>
    800064c0:	ffffa097          	auipc	ra,0xffffa
    800064c4:	7d0080e7          	jalr	2000(ra) # 80000c90 <release>
}
    800064c8:	70e6                	ld	ra,120(sp)
    800064ca:	7446                	ld	s0,112(sp)
    800064cc:	74a6                	ld	s1,104(sp)
    800064ce:	7906                	ld	s2,96(sp)
    800064d0:	69e6                	ld	s3,88(sp)
    800064d2:	6a46                	ld	s4,80(sp)
    800064d4:	6aa6                	ld	s5,72(sp)
    800064d6:	6b06                	ld	s6,64(sp)
    800064d8:	7be2                	ld	s7,56(sp)
    800064da:	7c42                	ld	s8,48(sp)
    800064dc:	7ca2                	ld	s9,40(sp)
    800064de:	7d02                	ld	s10,32(sp)
    800064e0:	6de2                	ld	s11,24(sp)
    800064e2:	6109                	addi	sp,sp,128
    800064e4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800064e6:	f8042503          	lw	a0,-128(s0)
    800064ea:	20050793          	addi	a5,a0,512
    800064ee:	0792                	slli	a5,a5,0x4
  if(write)
    800064f0:	00025817          	auipc	a6,0x25
    800064f4:	b1080813          	addi	a6,a6,-1264 # 8002b000 <disk>
    800064f8:	00f80733          	add	a4,a6,a5
    800064fc:	01a036b3          	snez	a3,s10
    80006500:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006504:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006508:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000650c:	7679                	lui	a2,0xffffe
    8000650e:	963e                	add	a2,a2,a5
    80006510:	00027697          	auipc	a3,0x27
    80006514:	af068693          	addi	a3,a3,-1296 # 8002d000 <disk+0x2000>
    80006518:	6298                	ld	a4,0(a3)
    8000651a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000651c:	0a878593          	addi	a1,a5,168
    80006520:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006522:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006524:	6298                	ld	a4,0(a3)
    80006526:	9732                	add	a4,a4,a2
    80006528:	45c1                	li	a1,16
    8000652a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000652c:	6298                	ld	a4,0(a3)
    8000652e:	9732                	add	a4,a4,a2
    80006530:	4585                	li	a1,1
    80006532:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006536:	f8442703          	lw	a4,-124(s0)
    8000653a:	628c                	ld	a1,0(a3)
    8000653c:	962e                	add	a2,a2,a1
    8000653e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd000e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006542:	0712                	slli	a4,a4,0x4
    80006544:	6290                	ld	a2,0(a3)
    80006546:	963a                	add	a2,a2,a4
    80006548:	058a8593          	addi	a1,s5,88
    8000654c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000654e:	6294                	ld	a3,0(a3)
    80006550:	96ba                	add	a3,a3,a4
    80006552:	40000613          	li	a2,1024
    80006556:	c690                	sw	a2,8(a3)
  if(write)
    80006558:	e40d19e3          	bnez	s10,800063aa <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000655c:	00027697          	auipc	a3,0x27
    80006560:	aa46b683          	ld	a3,-1372(a3) # 8002d000 <disk+0x2000>
    80006564:	96ba                	add	a3,a3,a4
    80006566:	4609                	li	a2,2
    80006568:	00c69623          	sh	a2,12(a3)
    8000656c:	b5b1                	j	800063b8 <virtio_disk_rw+0xd2>

000000008000656e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000656e:	1101                	addi	sp,sp,-32
    80006570:	ec06                	sd	ra,24(sp)
    80006572:	e822                	sd	s0,16(sp)
    80006574:	e426                	sd	s1,8(sp)
    80006576:	e04a                	sd	s2,0(sp)
    80006578:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000657a:	00027517          	auipc	a0,0x27
    8000657e:	bae50513          	addi	a0,a0,-1106 # 8002d128 <disk+0x2128>
    80006582:	ffffa097          	auipc	ra,0xffffa
    80006586:	644080e7          	jalr	1604(ra) # 80000bc6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000658a:	10001737          	lui	a4,0x10001
    8000658e:	533c                	lw	a5,96(a4)
    80006590:	8b8d                	andi	a5,a5,3
    80006592:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006594:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006598:	00027797          	auipc	a5,0x27
    8000659c:	a6878793          	addi	a5,a5,-1432 # 8002d000 <disk+0x2000>
    800065a0:	6b94                	ld	a3,16(a5)
    800065a2:	0207d703          	lhu	a4,32(a5)
    800065a6:	0026d783          	lhu	a5,2(a3)
    800065aa:	06f70163          	beq	a4,a5,8000660c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800065ae:	00025917          	auipc	s2,0x25
    800065b2:	a5290913          	addi	s2,s2,-1454 # 8002b000 <disk>
    800065b6:	00027497          	auipc	s1,0x27
    800065ba:	a4a48493          	addi	s1,s1,-1462 # 8002d000 <disk+0x2000>
    __sync_synchronize();
    800065be:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800065c2:	6898                	ld	a4,16(s1)
    800065c4:	0204d783          	lhu	a5,32(s1)
    800065c8:	8b9d                	andi	a5,a5,7
    800065ca:	078e                	slli	a5,a5,0x3
    800065cc:	97ba                	add	a5,a5,a4
    800065ce:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800065d0:	20078713          	addi	a4,a5,512
    800065d4:	0712                	slli	a4,a4,0x4
    800065d6:	974a                	add	a4,a4,s2
    800065d8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800065dc:	e731                	bnez	a4,80006628 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800065de:	20078793          	addi	a5,a5,512
    800065e2:	0792                	slli	a5,a5,0x4
    800065e4:	97ca                	add	a5,a5,s2
    800065e6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800065e8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800065ec:	ffffc097          	auipc	ra,0xffffc
    800065f0:	cb4080e7          	jalr	-844(ra) # 800022a0 <wakeup>

    disk.used_idx += 1;
    800065f4:	0204d783          	lhu	a5,32(s1)
    800065f8:	2785                	addiw	a5,a5,1
    800065fa:	17c2                	slli	a5,a5,0x30
    800065fc:	93c1                	srli	a5,a5,0x30
    800065fe:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006602:	6898                	ld	a4,16(s1)
    80006604:	00275703          	lhu	a4,2(a4)
    80006608:	faf71be3          	bne	a4,a5,800065be <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000660c:	00027517          	auipc	a0,0x27
    80006610:	b1c50513          	addi	a0,a0,-1252 # 8002d128 <disk+0x2128>
    80006614:	ffffa097          	auipc	ra,0xffffa
    80006618:	67c080e7          	jalr	1660(ra) # 80000c90 <release>
}
    8000661c:	60e2                	ld	ra,24(sp)
    8000661e:	6442                	ld	s0,16(sp)
    80006620:	64a2                	ld	s1,8(sp)
    80006622:	6902                	ld	s2,0(sp)
    80006624:	6105                	addi	sp,sp,32
    80006626:	8082                	ret
      panic("virtio_disk_intr status");
    80006628:	00002517          	auipc	a0,0x2
    8000662c:	2c050513          	addi	a0,a0,704 # 800088e8 <syscalls+0x3c8>
    80006630:	ffffa097          	auipc	ra,0xffffa
    80006634:	efe080e7          	jalr	-258(ra) # 8000052e <panic>
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
