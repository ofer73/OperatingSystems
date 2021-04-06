
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
    80000068:	1fc78793          	addi	a5,a5,508 # 80006260 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dbe78793          	addi	a5,a5,-578 # 80000e6c <main>
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
    80000122:	604080e7          	jalr	1540(ra) # 80002722 <either_copyin>
    80000126:	01550c63          	beq	a0,s5,8000013e <consolewrite+0x4a>
      break;
    uartputc(c);
    8000012a:	fbf44503          	lbu	a0,-65(s0)
    8000012e:	00000097          	auipc	ra,0x0
    80000132:	77a080e7          	jalr	1914(ra) # 800008a8 <uartputc>
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
    80000172:	8aaa                	mv	s5,a0
    80000174:	8a2e                	mv	s4,a1
    80000176:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000178:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000017c:	00011517          	auipc	a0,0x11
    80000180:	00450513          	addi	a0,a0,4 # 80011180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a3e080e7          	jalr	-1474(ra) # 80000bc2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00011497          	auipc	s1,0x11
    80000190:	ff448493          	addi	s1,s1,-12 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000194:	00011917          	auipc	s2,0x11
    80000198:	08490913          	addi	s2,s2,132 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    8000019c:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000019e:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001a0:	4ca9                	li	s9,10
  while(n > 0){
    800001a2:	07305863          	blez	s3,80000212 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001a6:	0984a783          	lw	a5,152(s1)
    800001aa:	09c4a703          	lw	a4,156(s1)
    800001ae:	02f71463          	bne	a4,a5,800001d6 <consoleread+0x80>
      if(myproc()->killed){
    800001b2:	00001097          	auipc	ra,0x1
    800001b6:	7cc080e7          	jalr	1996(ra) # 8000197e <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	13e080e7          	jalr	318(ra) # 80002300 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef700e3          	beq	a4,a5,800001b2 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001d6:	0017871b          	addiw	a4,a5,1
    800001da:	08e4ac23          	sw	a4,152(s1)
    800001de:	07f7f713          	andi	a4,a5,127
    800001e2:	9726                	add	a4,a4,s1
    800001e4:	01874703          	lbu	a4,24(a4)
    800001e8:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001ec:	077d0563          	beq	s10,s7,80000256 <consoleread+0x100>
    cbuf = c;
    800001f0:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001f4:	4685                	li	a3,1
    800001f6:	f9f40613          	addi	a2,s0,-97
    800001fa:	85d2                	mv	a1,s4
    800001fc:	8556                	mv	a0,s5
    800001fe:	00002097          	auipc	ra,0x2
    80000202:	4ce080e7          	jalr	1230(ra) # 800026cc <either_copyout>
    80000206:	01850663          	beq	a0,s8,80000212 <consoleread+0xbc>
    dst++;
    8000020a:	0a05                	addi	s4,s4,1
    --n;
    8000020c:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000020e:	f99d1ae3          	bne	s10,s9,800001a2 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000212:	00011517          	auipc	a0,0x11
    80000216:	f6e50513          	addi	a0,a0,-146 # 80011180 <cons>
    8000021a:	00001097          	auipc	ra,0x1
    8000021e:	a5c080e7          	jalr	-1444(ra) # 80000c76 <release>

  return target - n;
    80000222:	413b053b          	subw	a0,s6,s3
    80000226:	a811                	j	8000023a <consoleread+0xe4>
        release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	f5850513          	addi	a0,a0,-168 # 80011180 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a46080e7          	jalr	-1466(ra) # 80000c76 <release>
        return -1;
    80000238:	557d                	li	a0,-1
}
    8000023a:	70a6                	ld	ra,104(sp)
    8000023c:	7406                	ld	s0,96(sp)
    8000023e:	64e6                	ld	s1,88(sp)
    80000240:	6946                	ld	s2,80(sp)
    80000242:	69a6                	ld	s3,72(sp)
    80000244:	6a06                	ld	s4,64(sp)
    80000246:	7ae2                	ld	s5,56(sp)
    80000248:	7b42                	ld	s6,48(sp)
    8000024a:	7ba2                	ld	s7,40(sp)
    8000024c:	7c02                	ld	s8,32(sp)
    8000024e:	6ce2                	ld	s9,24(sp)
    80000250:	6d42                	ld	s10,16(sp)
    80000252:	6165                	addi	sp,sp,112
    80000254:	8082                	ret
      if(n < target){
    80000256:	0009871b          	sext.w	a4,s3
    8000025a:	fb677ce3          	bgeu	a4,s6,80000212 <consoleread+0xbc>
        cons.r--;
    8000025e:	00011717          	auipc	a4,0x11
    80000262:	faf72d23          	sw	a5,-70(a4) # 80011218 <cons+0x98>
    80000266:	b775                	j	80000212 <consoleread+0xbc>

0000000080000268 <consputc>:
{
    80000268:	1141                	addi	sp,sp,-16
    8000026a:	e406                	sd	ra,8(sp)
    8000026c:	e022                	sd	s0,0(sp)
    8000026e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000270:	10000793          	li	a5,256
    80000274:	00f50a63          	beq	a0,a5,80000288 <consputc+0x20>
    uartputc_sync(c);
    80000278:	00000097          	auipc	ra,0x0
    8000027c:	55e080e7          	jalr	1374(ra) # 800007d6 <uartputc_sync>
}
    80000280:	60a2                	ld	ra,8(sp)
    80000282:	6402                	ld	s0,0(sp)
    80000284:	0141                	addi	sp,sp,16
    80000286:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000288:	4521                	li	a0,8
    8000028a:	00000097          	auipc	ra,0x0
    8000028e:	54c080e7          	jalr	1356(ra) # 800007d6 <uartputc_sync>
    80000292:	02000513          	li	a0,32
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	540080e7          	jalr	1344(ra) # 800007d6 <uartputc_sync>
    8000029e:	4521                	li	a0,8
    800002a0:	00000097          	auipc	ra,0x0
    800002a4:	536080e7          	jalr	1334(ra) # 800007d6 <uartputc_sync>
    800002a8:	bfe1                	j	80000280 <consputc+0x18>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	e04a                	sd	s2,0(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	00011517          	auipc	a0,0x11
    800002bc:	ec850513          	addi	a0,a0,-312 # 80011180 <cons>
    800002c0:	00001097          	auipc	ra,0x1
    800002c4:	902080e7          	jalr	-1790(ra) # 80000bc2 <acquire>

  switch(c){
    800002c8:	47d5                	li	a5,21
    800002ca:	0af48663          	beq	s1,a5,80000376 <consoleintr+0xcc>
    800002ce:	0297ca63          	blt	a5,s1,80000302 <consoleintr+0x58>
    800002d2:	47a1                	li	a5,8
    800002d4:	0ef48763          	beq	s1,a5,800003c2 <consoleintr+0x118>
    800002d8:	47c1                	li	a5,16
    800002da:	10f49a63          	bne	s1,a5,800003ee <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002de:	00002097          	auipc	ra,0x2
    800002e2:	49a080e7          	jalr	1178(ra) # 80002778 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002e6:	00011517          	auipc	a0,0x11
    800002ea:	e9a50513          	addi	a0,a0,-358 # 80011180 <cons>
    800002ee:	00001097          	auipc	ra,0x1
    800002f2:	988080e7          	jalr	-1656(ra) # 80000c76 <release>
}
    800002f6:	60e2                	ld	ra,24(sp)
    800002f8:	6442                	ld	s0,16(sp)
    800002fa:	64a2                	ld	s1,8(sp)
    800002fc:	6902                	ld	s2,0(sp)
    800002fe:	6105                	addi	sp,sp,32
    80000300:	8082                	ret
  switch(c){
    80000302:	07f00793          	li	a5,127
    80000306:	0af48e63          	beq	s1,a5,800003c2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000030a:	00011717          	auipc	a4,0x11
    8000030e:	e7670713          	addi	a4,a4,-394 # 80011180 <cons>
    80000312:	0a072783          	lw	a5,160(a4)
    80000316:	09872703          	lw	a4,152(a4)
    8000031a:	9f99                	subw	a5,a5,a4
    8000031c:	07f00713          	li	a4,127
    80000320:	fcf763e3          	bltu	a4,a5,800002e6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000324:	47b5                	li	a5,13
    80000326:	0cf48763          	beq	s1,a5,800003f4 <consoleintr+0x14a>
      consputc(c);
    8000032a:	8526                	mv	a0,s1
    8000032c:	00000097          	auipc	ra,0x0
    80000330:	f3c080e7          	jalr	-196(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000334:	00011797          	auipc	a5,0x11
    80000338:	e4c78793          	addi	a5,a5,-436 # 80011180 <cons>
    8000033c:	0a07a703          	lw	a4,160(a5)
    80000340:	0017069b          	addiw	a3,a4,1
    80000344:	0006861b          	sext.w	a2,a3
    80000348:	0ad7a023          	sw	a3,160(a5)
    8000034c:	07f77713          	andi	a4,a4,127
    80000350:	97ba                	add	a5,a5,a4
    80000352:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000356:	47a9                	li	a5,10
    80000358:	0cf48563          	beq	s1,a5,80000422 <consoleintr+0x178>
    8000035c:	4791                	li	a5,4
    8000035e:	0cf48263          	beq	s1,a5,80000422 <consoleintr+0x178>
    80000362:	00011797          	auipc	a5,0x11
    80000366:	eb67a783          	lw	a5,-330(a5) # 80011218 <cons+0x98>
    8000036a:	0807879b          	addiw	a5,a5,128
    8000036e:	f6f61ce3          	bne	a2,a5,800002e6 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000372:	863e                	mv	a2,a5
    80000374:	a07d                	j	80000422 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000376:	00011717          	auipc	a4,0x11
    8000037a:	e0a70713          	addi	a4,a4,-502 # 80011180 <cons>
    8000037e:	0a072783          	lw	a5,160(a4)
    80000382:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000386:	00011497          	auipc	s1,0x11
    8000038a:	dfa48493          	addi	s1,s1,-518 # 80011180 <cons>
    while(cons.e != cons.w &&
    8000038e:	4929                	li	s2,10
    80000390:	f4f70be3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	37fd                	addiw	a5,a5,-1
    80000396:	07f7f713          	andi	a4,a5,127
    8000039a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000039c:	01874703          	lbu	a4,24(a4)
    800003a0:	f52703e3          	beq	a4,s2,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003a4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a8:	10000513          	li	a0,256
    800003ac:	00000097          	auipc	ra,0x0
    800003b0:	ebc080e7          	jalr	-324(ra) # 80000268 <consputc>
    while(cons.e != cons.w &&
    800003b4:	0a04a783          	lw	a5,160(s1)
    800003b8:	09c4a703          	lw	a4,156(s1)
    800003bc:	fcf71ce3          	bne	a4,a5,80000394 <consoleintr+0xea>
    800003c0:	b71d                	j	800002e6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003c2:	00011717          	auipc	a4,0x11
    800003c6:	dbe70713          	addi	a4,a4,-578 # 80011180 <cons>
    800003ca:	0a072783          	lw	a5,160(a4)
    800003ce:	09c72703          	lw	a4,156(a4)
    800003d2:	f0f70ae3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003d6:	37fd                	addiw	a5,a5,-1
    800003d8:	00011717          	auipc	a4,0x11
    800003dc:	e4f72423          	sw	a5,-440(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003e0:	10000513          	li	a0,256
    800003e4:	00000097          	auipc	ra,0x0
    800003e8:	e84080e7          	jalr	-380(ra) # 80000268 <consputc>
    800003ec:	bded                	j	800002e6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003ee:	ee048ce3          	beqz	s1,800002e6 <consoleintr+0x3c>
    800003f2:	bf21                	j	8000030a <consoleintr+0x60>
      consputc(c);
    800003f4:	4529                	li	a0,10
    800003f6:	00000097          	auipc	ra,0x0
    800003fa:	e72080e7          	jalr	-398(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003fe:	00011797          	auipc	a5,0x11
    80000402:	d8278793          	addi	a5,a5,-638 # 80011180 <cons>
    80000406:	0a07a703          	lw	a4,160(a5)
    8000040a:	0017069b          	addiw	a3,a4,1
    8000040e:	0006861b          	sext.w	a2,a3
    80000412:	0ad7a023          	sw	a3,160(a5)
    80000416:	07f77713          	andi	a4,a4,127
    8000041a:	97ba                	add	a5,a5,a4
    8000041c:	4729                	li	a4,10
    8000041e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000422:	00011797          	auipc	a5,0x11
    80000426:	dec7ad23          	sw	a2,-518(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    8000042a:	00011517          	auipc	a0,0x11
    8000042e:	dee50513          	addi	a0,a0,-530 # 80011218 <cons+0x98>
    80000432:	00002097          	auipc	ra,0x2
    80000436:	05a080e7          	jalr	90(ra) # 8000248c <wakeup>
    8000043a:	b575                	j	800002e6 <consoleintr+0x3c>

000000008000043c <consoleinit>:

void
consoleinit(void)
{
    8000043c:	1141                	addi	sp,sp,-16
    8000043e:	e406                	sd	ra,8(sp)
    80000440:	e022                	sd	s0,0(sp)
    80000442:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000444:	00008597          	auipc	a1,0x8
    80000448:	bcc58593          	addi	a1,a1,-1076 # 80008010 <etext+0x10>
    8000044c:	00011517          	auipc	a0,0x11
    80000450:	d3450513          	addi	a0,a0,-716 # 80011180 <cons>
    80000454:	00000097          	auipc	ra,0x0
    80000458:	6de080e7          	jalr	1758(ra) # 80000b32 <initlock>

  uartinit();
    8000045c:	00000097          	auipc	ra,0x0
    80000460:	32a080e7          	jalr	810(ra) # 80000786 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000464:	00022797          	auipc	a5,0x22
    80000468:	8b478793          	addi	a5,a5,-1868 # 80021d18 <devsw>
    8000046c:	00000717          	auipc	a4,0x0
    80000470:	cea70713          	addi	a4,a4,-790 # 80000156 <consoleread>
    80000474:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000476:	00000717          	auipc	a4,0x0
    8000047a:	c7e70713          	addi	a4,a4,-898 # 800000f4 <consolewrite>
    8000047e:	ef98                	sd	a4,24(a5)
}
    80000480:	60a2                	ld	ra,8(sp)
    80000482:	6402                	ld	s0,0(sp)
    80000484:	0141                	addi	sp,sp,16
    80000486:	8082                	ret

0000000080000488 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000488:	7179                	addi	sp,sp,-48
    8000048a:	f406                	sd	ra,40(sp)
    8000048c:	f022                	sd	s0,32(sp)
    8000048e:	ec26                	sd	s1,24(sp)
    80000490:	e84a                	sd	s2,16(sp)
    80000492:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80000494:	c219                	beqz	a2,8000049a <printint+0x12>
    80000496:	08054663          	bltz	a0,80000522 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    8000049a:	2501                	sext.w	a0,a0
    8000049c:	4881                	li	a7,0
    8000049e:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004a2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004a4:	2581                	sext.w	a1,a1
    800004a6:	00008617          	auipc	a2,0x8
    800004aa:	b9a60613          	addi	a2,a2,-1126 # 80008040 <digits>
    800004ae:	883a                	mv	a6,a4
    800004b0:	2705                	addiw	a4,a4,1
    800004b2:	02b577bb          	remuw	a5,a0,a1
    800004b6:	1782                	slli	a5,a5,0x20
    800004b8:	9381                	srli	a5,a5,0x20
    800004ba:	97b2                	add	a5,a5,a2
    800004bc:	0007c783          	lbu	a5,0(a5)
    800004c0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004c4:	0005079b          	sext.w	a5,a0
    800004c8:	02b5553b          	divuw	a0,a0,a1
    800004cc:	0685                	addi	a3,a3,1
    800004ce:	feb7f0e3          	bgeu	a5,a1,800004ae <printint+0x26>

  if(sign)
    800004d2:	00088b63          	beqz	a7,800004e8 <printint+0x60>
    buf[i++] = '-';
    800004d6:	fe040793          	addi	a5,s0,-32
    800004da:	973e                	add	a4,a4,a5
    800004dc:	02d00793          	li	a5,45
    800004e0:	fef70823          	sb	a5,-16(a4)
    800004e4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004e8:	02e05763          	blez	a4,80000516 <printint+0x8e>
    800004ec:	fd040793          	addi	a5,s0,-48
    800004f0:	00e784b3          	add	s1,a5,a4
    800004f4:	fff78913          	addi	s2,a5,-1
    800004f8:	993a                	add	s2,s2,a4
    800004fa:	377d                	addiw	a4,a4,-1
    800004fc:	1702                	slli	a4,a4,0x20
    800004fe:	9301                	srli	a4,a4,0x20
    80000500:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000504:	fff4c503          	lbu	a0,-1(s1)
    80000508:	00000097          	auipc	ra,0x0
    8000050c:	d60080e7          	jalr	-672(ra) # 80000268 <consputc>
  while(--i >= 0)
    80000510:	14fd                	addi	s1,s1,-1
    80000512:	ff2499e3          	bne	s1,s2,80000504 <printint+0x7c>
}
    80000516:	70a2                	ld	ra,40(sp)
    80000518:	7402                	ld	s0,32(sp)
    8000051a:	64e2                	ld	s1,24(sp)
    8000051c:	6942                	ld	s2,16(sp)
    8000051e:	6145                	addi	sp,sp,48
    80000520:	8082                	ret
    x = -xx;
    80000522:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000526:	4885                	li	a7,1
    x = -xx;
    80000528:	bf9d                	j	8000049e <printint+0x16>

000000008000052a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000052a:	1101                	addi	sp,sp,-32
    8000052c:	ec06                	sd	ra,24(sp)
    8000052e:	e822                	sd	s0,16(sp)
    80000530:	e426                	sd	s1,8(sp)
    80000532:	1000                	addi	s0,sp,32
    80000534:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000536:	00011797          	auipc	a5,0x11
    8000053a:	d007a523          	sw	zero,-758(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    8000053e:	00008517          	auipc	a0,0x8
    80000542:	ada50513          	addi	a0,a0,-1318 # 80008018 <etext+0x18>
    80000546:	00000097          	auipc	ra,0x0
    8000054a:	02e080e7          	jalr	46(ra) # 80000574 <printf>
  printf(s);
    8000054e:	8526                	mv	a0,s1
    80000550:	00000097          	auipc	ra,0x0
    80000554:	024080e7          	jalr	36(ra) # 80000574 <printf>
  printf("\n");
    80000558:	00008517          	auipc	a0,0x8
    8000055c:	b7050513          	addi	a0,a0,-1168 # 800080c8 <digits+0x88>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	014080e7          	jalr	20(ra) # 80000574 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000568:	4785                	li	a5,1
    8000056a:	00009717          	auipc	a4,0x9
    8000056e:	a8f72b23          	sw	a5,-1386(a4) # 80009000 <panicked>
  for(;;)
    80000572:	a001                	j	80000572 <panic+0x48>

0000000080000574 <printf>:
{
    80000574:	7131                	addi	sp,sp,-192
    80000576:	fc86                	sd	ra,120(sp)
    80000578:	f8a2                	sd	s0,112(sp)
    8000057a:	f4a6                	sd	s1,104(sp)
    8000057c:	f0ca                	sd	s2,96(sp)
    8000057e:	ecce                	sd	s3,88(sp)
    80000580:	e8d2                	sd	s4,80(sp)
    80000582:	e4d6                	sd	s5,72(sp)
    80000584:	e0da                	sd	s6,64(sp)
    80000586:	fc5e                	sd	s7,56(sp)
    80000588:	f862                	sd	s8,48(sp)
    8000058a:	f466                	sd	s9,40(sp)
    8000058c:	f06a                	sd	s10,32(sp)
    8000058e:	ec6e                	sd	s11,24(sp)
    80000590:	0100                	addi	s0,sp,128
    80000592:	8a2a                	mv	s4,a0
    80000594:	e40c                	sd	a1,8(s0)
    80000596:	e810                	sd	a2,16(s0)
    80000598:	ec14                	sd	a3,24(s0)
    8000059a:	f018                	sd	a4,32(s0)
    8000059c:	f41c                	sd	a5,40(s0)
    8000059e:	03043823          	sd	a6,48(s0)
    800005a2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005a6:	00011d97          	auipc	s11,0x11
    800005aa:	c9adad83          	lw	s11,-870(s11) # 80011240 <pr+0x18>
  if(locking)
    800005ae:	020d9b63          	bnez	s11,800005e4 <printf+0x70>
  if (fmt == 0)
    800005b2:	040a0263          	beqz	s4,800005f6 <printf+0x82>
  va_start(ap, fmt);
    800005b6:	00840793          	addi	a5,s0,8
    800005ba:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005be:	000a4503          	lbu	a0,0(s4)
    800005c2:	14050f63          	beqz	a0,80000720 <printf+0x1ac>
    800005c6:	4981                	li	s3,0
    if(c != '%'){
    800005c8:	02500a93          	li	s5,37
    switch(c){
    800005cc:	07000b93          	li	s7,112
  consputc('x');
    800005d0:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005d2:	00008b17          	auipc	s6,0x8
    800005d6:	a6eb0b13          	addi	s6,s6,-1426 # 80008040 <digits>
    switch(c){
    800005da:	07300c93          	li	s9,115
    800005de:	06400c13          	li	s8,100
    800005e2:	a82d                	j	8000061c <printf+0xa8>
    acquire(&pr.lock);
    800005e4:	00011517          	auipc	a0,0x11
    800005e8:	c4450513          	addi	a0,a0,-956 # 80011228 <pr>
    800005ec:	00000097          	auipc	ra,0x0
    800005f0:	5d6080e7          	jalr	1494(ra) # 80000bc2 <acquire>
    800005f4:	bf7d                	j	800005b2 <printf+0x3e>
    panic("null fmt");
    800005f6:	00008517          	auipc	a0,0x8
    800005fa:	a3250513          	addi	a0,a0,-1486 # 80008028 <etext+0x28>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	f2c080e7          	jalr	-212(ra) # 8000052a <panic>
      consputc(c);
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	c62080e7          	jalr	-926(ra) # 80000268 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000060e:	2985                	addiw	s3,s3,1
    80000610:	013a07b3          	add	a5,s4,s3
    80000614:	0007c503          	lbu	a0,0(a5)
    80000618:	10050463          	beqz	a0,80000720 <printf+0x1ac>
    if(c != '%'){
    8000061c:	ff5515e3          	bne	a0,s5,80000606 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c783          	lbu	a5,0(a5)
    8000062a:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000062e:	cbed                	beqz	a5,80000720 <printf+0x1ac>
    switch(c){
    80000630:	05778a63          	beq	a5,s7,80000684 <printf+0x110>
    80000634:	02fbf663          	bgeu	s7,a5,80000660 <printf+0xec>
    80000638:	09978863          	beq	a5,s9,800006c8 <printf+0x154>
    8000063c:	07800713          	li	a4,120
    80000640:	0ce79563          	bne	a5,a4,8000070a <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	85ea                	mv	a1,s10
    80000654:	4388                	lw	a0,0(a5)
    80000656:	00000097          	auipc	ra,0x0
    8000065a:	e32080e7          	jalr	-462(ra) # 80000488 <printint>
      break;
    8000065e:	bf45                	j	8000060e <printf+0x9a>
    switch(c){
    80000660:	09578f63          	beq	a5,s5,800006fe <printf+0x18a>
    80000664:	0b879363          	bne	a5,s8,8000070a <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000668:	f8843783          	ld	a5,-120(s0)
    8000066c:	00878713          	addi	a4,a5,8
    80000670:	f8e43423          	sd	a4,-120(s0)
    80000674:	4605                	li	a2,1
    80000676:	45a9                	li	a1,10
    80000678:	4388                	lw	a0,0(a5)
    8000067a:	00000097          	auipc	ra,0x0
    8000067e:	e0e080e7          	jalr	-498(ra) # 80000488 <printint>
      break;
    80000682:	b771                	j	8000060e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000684:	f8843783          	ld	a5,-120(s0)
    80000688:	00878713          	addi	a4,a5,8
    8000068c:	f8e43423          	sd	a4,-120(s0)
    80000690:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80000694:	03000513          	li	a0,48
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	bd0080e7          	jalr	-1072(ra) # 80000268 <consputc>
  consputc('x');
    800006a0:	07800513          	li	a0,120
    800006a4:	00000097          	auipc	ra,0x0
    800006a8:	bc4080e7          	jalr	-1084(ra) # 80000268 <consputc>
    800006ac:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ae:	03c95793          	srli	a5,s2,0x3c
    800006b2:	97da                	add	a5,a5,s6
    800006b4:	0007c503          	lbu	a0,0(a5)
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bb0080e7          	jalr	-1104(ra) # 80000268 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006c0:	0912                	slli	s2,s2,0x4
    800006c2:	34fd                	addiw	s1,s1,-1
    800006c4:	f4ed                	bnez	s1,800006ae <printf+0x13a>
    800006c6:	b7a1                	j	8000060e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006c8:	f8843783          	ld	a5,-120(s0)
    800006cc:	00878713          	addi	a4,a5,8
    800006d0:	f8e43423          	sd	a4,-120(s0)
    800006d4:	6384                	ld	s1,0(a5)
    800006d6:	cc89                	beqz	s1,800006f0 <printf+0x17c>
      for(; *s; s++)
    800006d8:	0004c503          	lbu	a0,0(s1)
    800006dc:	d90d                	beqz	a0,8000060e <printf+0x9a>
        consputc(*s);
    800006de:	00000097          	auipc	ra,0x0
    800006e2:	b8a080e7          	jalr	-1142(ra) # 80000268 <consputc>
      for(; *s; s++)
    800006e6:	0485                	addi	s1,s1,1
    800006e8:	0004c503          	lbu	a0,0(s1)
    800006ec:	f96d                	bnez	a0,800006de <printf+0x16a>
    800006ee:	b705                	j	8000060e <printf+0x9a>
        s = "(null)";
    800006f0:	00008497          	auipc	s1,0x8
    800006f4:	93048493          	addi	s1,s1,-1744 # 80008020 <etext+0x20>
      for(; *s; s++)
    800006f8:	02800513          	li	a0,40
    800006fc:	b7cd                	j	800006de <printf+0x16a>
      consputc('%');
    800006fe:	8556                	mv	a0,s5
    80000700:	00000097          	auipc	ra,0x0
    80000704:	b68080e7          	jalr	-1176(ra) # 80000268 <consputc>
      break;
    80000708:	b719                	j	8000060e <printf+0x9a>
      consputc('%');
    8000070a:	8556                	mv	a0,s5
    8000070c:	00000097          	auipc	ra,0x0
    80000710:	b5c080e7          	jalr	-1188(ra) # 80000268 <consputc>
      consputc(c);
    80000714:	8526                	mv	a0,s1
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b52080e7          	jalr	-1198(ra) # 80000268 <consputc>
      break;
    8000071e:	bdc5                	j	8000060e <printf+0x9a>
  if(locking)
    80000720:	020d9163          	bnez	s11,80000742 <printf+0x1ce>
}
    80000724:	70e6                	ld	ra,120(sp)
    80000726:	7446                	ld	s0,112(sp)
    80000728:	74a6                	ld	s1,104(sp)
    8000072a:	7906                	ld	s2,96(sp)
    8000072c:	69e6                	ld	s3,88(sp)
    8000072e:	6a46                	ld	s4,80(sp)
    80000730:	6aa6                	ld	s5,72(sp)
    80000732:	6b06                	ld	s6,64(sp)
    80000734:	7be2                	ld	s7,56(sp)
    80000736:	7c42                	ld	s8,48(sp)
    80000738:	7ca2                	ld	s9,40(sp)
    8000073a:	7d02                	ld	s10,32(sp)
    8000073c:	6de2                	ld	s11,24(sp)
    8000073e:	6129                	addi	sp,sp,192
    80000740:	8082                	ret
    release(&pr.lock);
    80000742:	00011517          	auipc	a0,0x11
    80000746:	ae650513          	addi	a0,a0,-1306 # 80011228 <pr>
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	52c080e7          	jalr	1324(ra) # 80000c76 <release>
}
    80000752:	bfc9                	j	80000724 <printf+0x1b0>

0000000080000754 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000754:	1101                	addi	sp,sp,-32
    80000756:	ec06                	sd	ra,24(sp)
    80000758:	e822                	sd	s0,16(sp)
    8000075a:	e426                	sd	s1,8(sp)
    8000075c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000075e:	00011497          	auipc	s1,0x11
    80000762:	aca48493          	addi	s1,s1,-1334 # 80011228 <pr>
    80000766:	00008597          	auipc	a1,0x8
    8000076a:	8d258593          	addi	a1,a1,-1838 # 80008038 <etext+0x38>
    8000076e:	8526                	mv	a0,s1
    80000770:	00000097          	auipc	ra,0x0
    80000774:	3c2080e7          	jalr	962(ra) # 80000b32 <initlock>
  pr.locking = 1;
    80000778:	4785                	li	a5,1
    8000077a:	cc9c                	sw	a5,24(s1)
}
    8000077c:	60e2                	ld	ra,24(sp)
    8000077e:	6442                	ld	s0,16(sp)
    80000780:	64a2                	ld	s1,8(sp)
    80000782:	6105                	addi	sp,sp,32
    80000784:	8082                	ret

0000000080000786 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000786:	1141                	addi	sp,sp,-16
    80000788:	e406                	sd	ra,8(sp)
    8000078a:	e022                	sd	s0,0(sp)
    8000078c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000078e:	100007b7          	lui	a5,0x10000
    80000792:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000796:	f8000713          	li	a4,-128
    8000079a:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000079e:	470d                	li	a4,3
    800007a0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007a4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007a8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ac:	469d                	li	a3,7
    800007ae:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007b2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007b6:	00008597          	auipc	a1,0x8
    800007ba:	8a258593          	addi	a1,a1,-1886 # 80008058 <digits+0x18>
    800007be:	00011517          	auipc	a0,0x11
    800007c2:	a8a50513          	addi	a0,a0,-1398 # 80011248 <uart_tx_lock>
    800007c6:	00000097          	auipc	ra,0x0
    800007ca:	36c080e7          	jalr	876(ra) # 80000b32 <initlock>
}
    800007ce:	60a2                	ld	ra,8(sp)
    800007d0:	6402                	ld	s0,0(sp)
    800007d2:	0141                	addi	sp,sp,16
    800007d4:	8082                	ret

00000000800007d6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007d6:	1101                	addi	sp,sp,-32
    800007d8:	ec06                	sd	ra,24(sp)
    800007da:	e822                	sd	s0,16(sp)
    800007dc:	e426                	sd	s1,8(sp)
    800007de:	1000                	addi	s0,sp,32
    800007e0:	84aa                	mv	s1,a0
  push_off();
    800007e2:	00000097          	auipc	ra,0x0
    800007e6:	394080e7          	jalr	916(ra) # 80000b76 <push_off>

  if(panicked){
    800007ea:	00009797          	auipc	a5,0x9
    800007ee:	8167a783          	lw	a5,-2026(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007f2:	10000737          	lui	a4,0x10000
  if(panicked){
    800007f6:	c391                	beqz	a5,800007fa <uartputc_sync+0x24>
    for(;;)
    800007f8:	a001                	j	800007f8 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007fa:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800007fe:	0207f793          	andi	a5,a5,32
    80000802:	dfe5                	beqz	a5,800007fa <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000804:	0ff4f513          	andi	a0,s1,255
    80000808:	100007b7          	lui	a5,0x10000
    8000080c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000810:	00000097          	auipc	ra,0x0
    80000814:	406080e7          	jalr	1030(ra) # 80000c16 <pop_off>
}
    80000818:	60e2                	ld	ra,24(sp)
    8000081a:	6442                	ld	s0,16(sp)
    8000081c:	64a2                	ld	s1,8(sp)
    8000081e:	6105                	addi	sp,sp,32
    80000820:	8082                	ret

0000000080000822 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000822:	00008797          	auipc	a5,0x8
    80000826:	7e67b783          	ld	a5,2022(a5) # 80009008 <uart_tx_r>
    8000082a:	00008717          	auipc	a4,0x8
    8000082e:	7e673703          	ld	a4,2022(a4) # 80009010 <uart_tx_w>
    80000832:	06f70a63          	beq	a4,a5,800008a6 <uartstart+0x84>
{
    80000836:	7139                	addi	sp,sp,-64
    80000838:	fc06                	sd	ra,56(sp)
    8000083a:	f822                	sd	s0,48(sp)
    8000083c:	f426                	sd	s1,40(sp)
    8000083e:	f04a                	sd	s2,32(sp)
    80000840:	ec4e                	sd	s3,24(sp)
    80000842:	e852                	sd	s4,16(sp)
    80000844:	e456                	sd	s5,8(sp)
    80000846:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000848:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000084c:	00011a17          	auipc	s4,0x11
    80000850:	9fca0a13          	addi	s4,s4,-1540 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000854:	00008497          	auipc	s1,0x8
    80000858:	7b448493          	addi	s1,s1,1972 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000085c:	00008997          	auipc	s3,0x8
    80000860:	7b498993          	addi	s3,s3,1972 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000864:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000868:	02077713          	andi	a4,a4,32
    8000086c:	c705                	beqz	a4,80000894 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000086e:	01f7f713          	andi	a4,a5,31
    80000872:	9752                	add	a4,a4,s4
    80000874:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000878:	0785                	addi	a5,a5,1
    8000087a:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000087c:	8526                	mv	a0,s1
    8000087e:	00002097          	auipc	ra,0x2
    80000882:	c0e080e7          	jalr	-1010(ra) # 8000248c <wakeup>
    
    WriteReg(THR, c);
    80000886:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000088a:	609c                	ld	a5,0(s1)
    8000088c:	0009b703          	ld	a4,0(s3)
    80000890:	fcf71ae3          	bne	a4,a5,80000864 <uartstart+0x42>
  }
}
    80000894:	70e2                	ld	ra,56(sp)
    80000896:	7442                	ld	s0,48(sp)
    80000898:	74a2                	ld	s1,40(sp)
    8000089a:	7902                	ld	s2,32(sp)
    8000089c:	69e2                	ld	s3,24(sp)
    8000089e:	6a42                	ld	s4,16(sp)
    800008a0:	6aa2                	ld	s5,8(sp)
    800008a2:	6121                	addi	sp,sp,64
    800008a4:	8082                	ret
    800008a6:	8082                	ret

00000000800008a8 <uartputc>:
{
    800008a8:	7179                	addi	sp,sp,-48
    800008aa:	f406                	sd	ra,40(sp)
    800008ac:	f022                	sd	s0,32(sp)
    800008ae:	ec26                	sd	s1,24(sp)
    800008b0:	e84a                	sd	s2,16(sp)
    800008b2:	e44e                	sd	s3,8(sp)
    800008b4:	e052                	sd	s4,0(sp)
    800008b6:	1800                	addi	s0,sp,48
    800008b8:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ba:	00011517          	auipc	a0,0x11
    800008be:	98e50513          	addi	a0,a0,-1650 # 80011248 <uart_tx_lock>
    800008c2:	00000097          	auipc	ra,0x0
    800008c6:	300080e7          	jalr	768(ra) # 80000bc2 <acquire>
  if(panicked){
    800008ca:	00008797          	auipc	a5,0x8
    800008ce:	7367a783          	lw	a5,1846(a5) # 80009000 <panicked>
    800008d2:	c391                	beqz	a5,800008d6 <uartputc+0x2e>
    for(;;)
    800008d4:	a001                	j	800008d4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008d6:	00008717          	auipc	a4,0x8
    800008da:	73a73703          	ld	a4,1850(a4) # 80009010 <uart_tx_w>
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	72a7b783          	ld	a5,1834(a5) # 80009008 <uart_tx_r>
    800008e6:	02078793          	addi	a5,a5,32
    800008ea:	02e79b63          	bne	a5,a4,80000920 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008ee:	00011997          	auipc	s3,0x11
    800008f2:	95a98993          	addi	s3,s3,-1702 # 80011248 <uart_tx_lock>
    800008f6:	00008497          	auipc	s1,0x8
    800008fa:	71248493          	addi	s1,s1,1810 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fe:	00008917          	auipc	s2,0x8
    80000902:	71290913          	addi	s2,s2,1810 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000906:	85ce                	mv	a1,s3
    80000908:	8526                	mv	a0,s1
    8000090a:	00002097          	auipc	ra,0x2
    8000090e:	9f6080e7          	jalr	-1546(ra) # 80002300 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000912:	00093703          	ld	a4,0(s2)
    80000916:	609c                	ld	a5,0(s1)
    80000918:	02078793          	addi	a5,a5,32
    8000091c:	fee785e3          	beq	a5,a4,80000906 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000920:	00011497          	auipc	s1,0x11
    80000924:	92848493          	addi	s1,s1,-1752 # 80011248 <uart_tx_lock>
    80000928:	01f77793          	andi	a5,a4,31
    8000092c:	97a6                	add	a5,a5,s1
    8000092e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000932:	0705                	addi	a4,a4,1
    80000934:	00008797          	auipc	a5,0x8
    80000938:	6ce7be23          	sd	a4,1756(a5) # 80009010 <uart_tx_w>
      uartstart();
    8000093c:	00000097          	auipc	ra,0x0
    80000940:	ee6080e7          	jalr	-282(ra) # 80000822 <uartstart>
      release(&uart_tx_lock);
    80000944:	8526                	mv	a0,s1
    80000946:	00000097          	auipc	ra,0x0
    8000094a:	330080e7          	jalr	816(ra) # 80000c76 <release>
}
    8000094e:	70a2                	ld	ra,40(sp)
    80000950:	7402                	ld	s0,32(sp)
    80000952:	64e2                	ld	s1,24(sp)
    80000954:	6942                	ld	s2,16(sp)
    80000956:	69a2                	ld	s3,8(sp)
    80000958:	6a02                	ld	s4,0(sp)
    8000095a:	6145                	addi	sp,sp,48
    8000095c:	8082                	ret

000000008000095e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000095e:	1141                	addi	sp,sp,-16
    80000960:	e422                	sd	s0,8(sp)
    80000962:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000964:	100007b7          	lui	a5,0x10000
    80000968:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000096c:	8b85                	andi	a5,a5,1
    8000096e:	cb91                	beqz	a5,80000982 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000970:	100007b7          	lui	a5,0x10000
    80000974:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000978:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000097c:	6422                	ld	s0,8(sp)
    8000097e:	0141                	addi	sp,sp,16
    80000980:	8082                	ret
    return -1;
    80000982:	557d                	li	a0,-1
    80000984:	bfe5                	j	8000097c <uartgetc+0x1e>

0000000080000986 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000986:	1101                	addi	sp,sp,-32
    80000988:	ec06                	sd	ra,24(sp)
    8000098a:	e822                	sd	s0,16(sp)
    8000098c:	e426                	sd	s1,8(sp)
    8000098e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000990:	54fd                	li	s1,-1
    80000992:	a029                	j	8000099c <uartintr+0x16>
      break;
    consoleintr(c);
    80000994:	00000097          	auipc	ra,0x0
    80000998:	916080e7          	jalr	-1770(ra) # 800002aa <consoleintr>
    int c = uartgetc();
    8000099c:	00000097          	auipc	ra,0x0
    800009a0:	fc2080e7          	jalr	-62(ra) # 8000095e <uartgetc>
    if(c == -1)
    800009a4:	fe9518e3          	bne	a0,s1,80000994 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009a8:	00011497          	auipc	s1,0x11
    800009ac:	8a048493          	addi	s1,s1,-1888 # 80011248 <uart_tx_lock>
    800009b0:	8526                	mv	a0,s1
    800009b2:	00000097          	auipc	ra,0x0
    800009b6:	210080e7          	jalr	528(ra) # 80000bc2 <acquire>
  uartstart();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	e68080e7          	jalr	-408(ra) # 80000822 <uartstart>
  release(&uart_tx_lock);
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	2b2080e7          	jalr	690(ra) # 80000c76 <release>
}
    800009cc:	60e2                	ld	ra,24(sp)
    800009ce:	6442                	ld	s0,16(sp)
    800009d0:	64a2                	ld	s1,8(sp)
    800009d2:	6105                	addi	sp,sp,32
    800009d4:	8082                	ret

00000000800009d6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009d6:	1101                	addi	sp,sp,-32
    800009d8:	ec06                	sd	ra,24(sp)
    800009da:	e822                	sd	s0,16(sp)
    800009dc:	e426                	sd	s1,8(sp)
    800009de:	e04a                	sd	s2,0(sp)
    800009e0:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009e2:	03451793          	slli	a5,a0,0x34
    800009e6:	ebb9                	bnez	a5,80000a3c <kfree+0x66>
    800009e8:	84aa                	mv	s1,a0
    800009ea:	00025797          	auipc	a5,0x25
    800009ee:	61678793          	addi	a5,a5,1558 # 80026000 <end>
    800009f2:	04f56563          	bltu	a0,a5,80000a3c <kfree+0x66>
    800009f6:	47c5                	li	a5,17
    800009f8:	07ee                	slli	a5,a5,0x1b
    800009fa:	04f57163          	bgeu	a0,a5,80000a3c <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009fe:	6605                	lui	a2,0x1
    80000a00:	4585                	li	a1,1
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	2bc080e7          	jalr	700(ra) # 80000cbe <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a0a:	00011917          	auipc	s2,0x11
    80000a0e:	87690913          	addi	s2,s2,-1930 # 80011280 <kmem>
    80000a12:	854a                	mv	a0,s2
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	1ae080e7          	jalr	430(ra) # 80000bc2 <acquire>
  r->next = kmem.freelist;
    80000a1c:	01893783          	ld	a5,24(s2)
    80000a20:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a22:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	24e080e7          	jalr	590(ra) # 80000c76 <release>
}
    80000a30:	60e2                	ld	ra,24(sp)
    80000a32:	6442                	ld	s0,16(sp)
    80000a34:	64a2                	ld	s1,8(sp)
    80000a36:	6902                	ld	s2,0(sp)
    80000a38:	6105                	addi	sp,sp,32
    80000a3a:	8082                	ret
    panic("kfree");
    80000a3c:	00007517          	auipc	a0,0x7
    80000a40:	62450513          	addi	a0,a0,1572 # 80008060 <digits+0x20>
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	ae6080e7          	jalr	-1306(ra) # 8000052a <panic>

0000000080000a4c <freerange>:
{
    80000a4c:	7179                	addi	sp,sp,-48
    80000a4e:	f406                	sd	ra,40(sp)
    80000a50:	f022                	sd	s0,32(sp)
    80000a52:	ec26                	sd	s1,24(sp)
    80000a54:	e84a                	sd	s2,16(sp)
    80000a56:	e44e                	sd	s3,8(sp)
    80000a58:	e052                	sd	s4,0(sp)
    80000a5a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a5c:	6785                	lui	a5,0x1
    80000a5e:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a62:	94aa                	add	s1,s1,a0
    80000a64:	757d                	lui	a0,0xfffff
    80000a66:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a68:	94be                	add	s1,s1,a5
    80000a6a:	0095ee63          	bltu	a1,s1,80000a86 <freerange+0x3a>
    80000a6e:	892e                	mv	s2,a1
    kfree(p);
    80000a70:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a72:	6985                	lui	s3,0x1
    kfree(p);
    80000a74:	01448533          	add	a0,s1,s4
    80000a78:	00000097          	auipc	ra,0x0
    80000a7c:	f5e080e7          	jalr	-162(ra) # 800009d6 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe9979e3          	bgeu	s2,s1,80000a74 <freerange+0x28>
}
    80000a86:	70a2                	ld	ra,40(sp)
    80000a88:	7402                	ld	s0,32(sp)
    80000a8a:	64e2                	ld	s1,24(sp)
    80000a8c:	6942                	ld	s2,16(sp)
    80000a8e:	69a2                	ld	s3,8(sp)
    80000a90:	6a02                	ld	s4,0(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00007597          	auipc	a1,0x7
    80000aa2:	5ca58593          	addi	a1,a1,1482 # 80008068 <digits+0x28>
    80000aa6:	00010517          	auipc	a0,0x10
    80000aaa:	7da50513          	addi	a0,a0,2010 # 80011280 <kmem>
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	084080e7          	jalr	132(ra) # 80000b32 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ab6:	45c5                	li	a1,17
    80000ab8:	05ee                	slli	a1,a1,0x1b
    80000aba:	00025517          	auipc	a0,0x25
    80000abe:	54650513          	addi	a0,a0,1350 # 80026000 <end>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	f8a080e7          	jalr	-118(ra) # 80000a4c <freerange>
}
    80000aca:	60a2                	ld	ra,8(sp)
    80000acc:	6402                	ld	s0,0(sp)
    80000ace:	0141                	addi	sp,sp,16
    80000ad0:	8082                	ret

0000000080000ad2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ad2:	1101                	addi	sp,sp,-32
    80000ad4:	ec06                	sd	ra,24(sp)
    80000ad6:	e822                	sd	s0,16(sp)
    80000ad8:	e426                	sd	s1,8(sp)
    80000ada:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000adc:	00010497          	auipc	s1,0x10
    80000ae0:	7a448493          	addi	s1,s1,1956 # 80011280 <kmem>
    80000ae4:	8526                	mv	a0,s1
    80000ae6:	00000097          	auipc	ra,0x0
    80000aea:	0dc080e7          	jalr	220(ra) # 80000bc2 <acquire>
  r = kmem.freelist;
    80000aee:	6c84                	ld	s1,24(s1)
  if(r)
    80000af0:	c885                	beqz	s1,80000b20 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af2:	609c                	ld	a5,0(s1)
    80000af4:	00010517          	auipc	a0,0x10
    80000af8:	78c50513          	addi	a0,a0,1932 # 80011280 <kmem>
    80000afc:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	178080e7          	jalr	376(ra) # 80000c76 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b06:	6605                	lui	a2,0x1
    80000b08:	4595                	li	a1,5
    80000b0a:	8526                	mv	a0,s1
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	1b2080e7          	jalr	434(ra) # 80000cbe <memset>
  return (void*)r;
}
    80000b14:	8526                	mv	a0,s1
    80000b16:	60e2                	ld	ra,24(sp)
    80000b18:	6442                	ld	s0,16(sp)
    80000b1a:	64a2                	ld	s1,8(sp)
    80000b1c:	6105                	addi	sp,sp,32
    80000b1e:	8082                	ret
  release(&kmem.lock);
    80000b20:	00010517          	auipc	a0,0x10
    80000b24:	76050513          	addi	a0,a0,1888 # 80011280 <kmem>
    80000b28:	00000097          	auipc	ra,0x0
    80000b2c:	14e080e7          	jalr	334(ra) # 80000c76 <release>
  if(r)
    80000b30:	b7d5                	j	80000b14 <kalloc+0x42>

0000000080000b32 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b32:	1141                	addi	sp,sp,-16
    80000b34:	e422                	sd	s0,8(sp)
    80000b36:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b38:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b3a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b3e:	00053823          	sd	zero,16(a0)
}
    80000b42:	6422                	ld	s0,8(sp)
    80000b44:	0141                	addi	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b48:	411c                	lw	a5,0(a0)
    80000b4a:	e399                	bnez	a5,80000b50 <holding+0x8>
    80000b4c:	4501                	li	a0,0
  return r;
}
    80000b4e:	8082                	ret
{
    80000b50:	1101                	addi	sp,sp,-32
    80000b52:	ec06                	sd	ra,24(sp)
    80000b54:	e822                	sd	s0,16(sp)
    80000b56:	e426                	sd	s1,8(sp)
    80000b58:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b5a:	6904                	ld	s1,16(a0)
    80000b5c:	00001097          	auipc	ra,0x1
    80000b60:	e06080e7          	jalr	-506(ra) # 80001962 <mycpu>
    80000b64:	40a48533          	sub	a0,s1,a0
    80000b68:	00153513          	seqz	a0,a0
}
    80000b6c:	60e2                	ld	ra,24(sp)
    80000b6e:	6442                	ld	s0,16(sp)
    80000b70:	64a2                	ld	s1,8(sp)
    80000b72:	6105                	addi	sp,sp,32
    80000b74:	8082                	ret

0000000080000b76 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b76:	1101                	addi	sp,sp,-32
    80000b78:	ec06                	sd	ra,24(sp)
    80000b7a:	e822                	sd	s0,16(sp)
    80000b7c:	e426                	sd	s1,8(sp)
    80000b7e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b80:	100024f3          	csrr	s1,sstatus
    80000b84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b88:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b8a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b8e:	00001097          	auipc	ra,0x1
    80000b92:	dd4080e7          	jalr	-556(ra) # 80001962 <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	dc8080e7          	jalr	-568(ra) # 80001962 <mycpu>
    80000ba2:	5d3c                	lw	a5,120(a0)
    80000ba4:	2785                	addiw	a5,a5,1
    80000ba6:	dd3c                	sw	a5,120(a0)
}
    80000ba8:	60e2                	ld	ra,24(sp)
    80000baa:	6442                	ld	s0,16(sp)
    80000bac:	64a2                	ld	s1,8(sp)
    80000bae:	6105                	addi	sp,sp,32
    80000bb0:	8082                	ret
    mycpu()->intena = old;
    80000bb2:	00001097          	auipc	ra,0x1
    80000bb6:	db0080e7          	jalr	-592(ra) # 80001962 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bba:	8085                	srli	s1,s1,0x1
    80000bbc:	8885                	andi	s1,s1,1
    80000bbe:	dd64                	sw	s1,124(a0)
    80000bc0:	bfe9                	j	80000b9a <push_off+0x24>

0000000080000bc2 <acquire>:
{
    80000bc2:	1101                	addi	sp,sp,-32
    80000bc4:	ec06                	sd	ra,24(sp)
    80000bc6:	e822                	sd	s0,16(sp)
    80000bc8:	e426                	sd	s1,8(sp)
    80000bca:	1000                	addi	s0,sp,32
    80000bcc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bce:	00000097          	auipc	ra,0x0
    80000bd2:	fa8080e7          	jalr	-88(ra) # 80000b76 <push_off>
  if(holding(lk))
    80000bd6:	8526                	mv	a0,s1
    80000bd8:	00000097          	auipc	ra,0x0
    80000bdc:	f70080e7          	jalr	-144(ra) # 80000b48 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be0:	4705                	li	a4,1
  if(holding(lk))
    80000be2:	e115                	bnez	a0,80000c06 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	87ba                	mv	a5,a4
    80000be6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bea:	2781                	sext.w	a5,a5
    80000bec:	ffe5                	bnez	a5,80000be4 <acquire+0x22>
  __sync_synchronize();
    80000bee:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bf2:	00001097          	auipc	ra,0x1
    80000bf6:	d70080e7          	jalr	-656(ra) # 80001962 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00007517          	auipc	a0,0x7
    80000c0a:	46a50513          	addi	a0,a0,1130 # 80008070 <digits+0x30>
    80000c0e:	00000097          	auipc	ra,0x0
    80000c12:	91c080e7          	jalr	-1764(ra) # 8000052a <panic>

0000000080000c16 <pop_off>:

void
pop_off(void)
{
    80000c16:	1141                	addi	sp,sp,-16
    80000c18:	e406                	sd	ra,8(sp)
    80000c1a:	e022                	sd	s0,0(sp)
    80000c1c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1e:	00001097          	auipc	ra,0x1
    80000c22:	d44080e7          	jalr	-700(ra) # 80001962 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c26:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c2a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c2c:	e78d                	bnez	a5,80000c56 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c2e:	5d3c                	lw	a5,120(a0)
    80000c30:	02f05b63          	blez	a5,80000c66 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c34:	37fd                	addiw	a5,a5,-1
    80000c36:	0007871b          	sext.w	a4,a5
    80000c3a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c3c:	eb09                	bnez	a4,80000c4e <pop_off+0x38>
    80000c3e:	5d7c                	lw	a5,124(a0)
    80000c40:	c799                	beqz	a5,80000c4e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c42:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c46:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c4a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c4e:	60a2                	ld	ra,8(sp)
    80000c50:	6402                	ld	s0,0(sp)
    80000c52:	0141                	addi	sp,sp,16
    80000c54:	8082                	ret
    panic("pop_off - interruptible");
    80000c56:	00007517          	auipc	a0,0x7
    80000c5a:	42250513          	addi	a0,a0,1058 # 80008078 <digits+0x38>
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	8cc080e7          	jalr	-1844(ra) # 8000052a <panic>
    panic("pop_off");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	42a50513          	addi	a0,a0,1066 # 80008090 <digits+0x50>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8bc080e7          	jalr	-1860(ra) # 8000052a <panic>

0000000080000c76 <release>:
{
    80000c76:	1101                	addi	sp,sp,-32
    80000c78:	ec06                	sd	ra,24(sp)
    80000c7a:	e822                	sd	s0,16(sp)
    80000c7c:	e426                	sd	s1,8(sp)
    80000c7e:	1000                	addi	s0,sp,32
    80000c80:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	ec6080e7          	jalr	-314(ra) # 80000b48 <holding>
    80000c8a:	c115                	beqz	a0,80000cae <release+0x38>
  lk->cpu = 0;
    80000c8c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c90:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c94:	0f50000f          	fence	iorw,ow
    80000c98:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c9c:	00000097          	auipc	ra,0x0
    80000ca0:	f7a080e7          	jalr	-134(ra) # 80000c16 <pop_off>
}
    80000ca4:	60e2                	ld	ra,24(sp)
    80000ca6:	6442                	ld	s0,16(sp)
    80000ca8:	64a2                	ld	s1,8(sp)
    80000caa:	6105                	addi	sp,sp,32
    80000cac:	8082                	ret
    panic("release");
    80000cae:	00007517          	auipc	a0,0x7
    80000cb2:	3ea50513          	addi	a0,a0,1002 # 80008098 <digits+0x58>
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	874080e7          	jalr	-1932(ra) # 8000052a <panic>

0000000080000cbe <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cbe:	1141                	addi	sp,sp,-16
    80000cc0:	e422                	sd	s0,8(sp)
    80000cc2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cc4:	ca19                	beqz	a2,80000cda <memset+0x1c>
    80000cc6:	87aa                	mv	a5,a0
    80000cc8:	1602                	slli	a2,a2,0x20
    80000cca:	9201                	srli	a2,a2,0x20
    80000ccc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cd0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cd4:	0785                	addi	a5,a5,1
    80000cd6:	fee79de3          	bne	a5,a4,80000cd0 <memset+0x12>
  }
  return dst;
}
    80000cda:	6422                	ld	s0,8(sp)
    80000cdc:	0141                	addi	sp,sp,16
    80000cde:	8082                	ret

0000000080000ce0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ce0:	1141                	addi	sp,sp,-16
    80000ce2:	e422                	sd	s0,8(sp)
    80000ce4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ce6:	ca05                	beqz	a2,80000d16 <memcmp+0x36>
    80000ce8:	fff6069b          	addiw	a3,a2,-1
    80000cec:	1682                	slli	a3,a3,0x20
    80000cee:	9281                	srli	a3,a3,0x20
    80000cf0:	0685                	addi	a3,a3,1
    80000cf2:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cf4:	00054783          	lbu	a5,0(a0)
    80000cf8:	0005c703          	lbu	a4,0(a1)
    80000cfc:	00e79863          	bne	a5,a4,80000d0c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d00:	0505                	addi	a0,a0,1
    80000d02:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d04:	fed518e3          	bne	a0,a3,80000cf4 <memcmp+0x14>
  }

  return 0;
    80000d08:	4501                	li	a0,0
    80000d0a:	a019                	j	80000d10 <memcmp+0x30>
      return *s1 - *s2;
    80000d0c:	40e7853b          	subw	a0,a5,a4
}
    80000d10:	6422                	ld	s0,8(sp)
    80000d12:	0141                	addi	sp,sp,16
    80000d14:	8082                	ret
  return 0;
    80000d16:	4501                	li	a0,0
    80000d18:	bfe5                	j	80000d10 <memcmp+0x30>

0000000080000d1a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d1a:	1141                	addi	sp,sp,-16
    80000d1c:	e422                	sd	s0,8(sp)
    80000d1e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d20:	02a5e563          	bltu	a1,a0,80000d4a <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d24:	fff6069b          	addiw	a3,a2,-1
    80000d28:	ce11                	beqz	a2,80000d44 <memmove+0x2a>
    80000d2a:	1682                	slli	a3,a3,0x20
    80000d2c:	9281                	srli	a3,a3,0x20
    80000d2e:	0685                	addi	a3,a3,1
    80000d30:	96ae                	add	a3,a3,a1
    80000d32:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d34:	0585                	addi	a1,a1,1
    80000d36:	0785                	addi	a5,a5,1
    80000d38:	fff5c703          	lbu	a4,-1(a1)
    80000d3c:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d40:	fed59ae3          	bne	a1,a3,80000d34 <memmove+0x1a>

  return dst;
}
    80000d44:	6422                	ld	s0,8(sp)
    80000d46:	0141                	addi	sp,sp,16
    80000d48:	8082                	ret
  if(s < d && s + n > d){
    80000d4a:	02061713          	slli	a4,a2,0x20
    80000d4e:	9301                	srli	a4,a4,0x20
    80000d50:	00e587b3          	add	a5,a1,a4
    80000d54:	fcf578e3          	bgeu	a0,a5,80000d24 <memmove+0xa>
    d += n;
    80000d58:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d5a:	fff6069b          	addiw	a3,a2,-1
    80000d5e:	d27d                	beqz	a2,80000d44 <memmove+0x2a>
    80000d60:	02069613          	slli	a2,a3,0x20
    80000d64:	9201                	srli	a2,a2,0x20
    80000d66:	fff64613          	not	a2,a2
    80000d6a:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d6c:	17fd                	addi	a5,a5,-1
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	0007c683          	lbu	a3,0(a5)
    80000d74:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d78:	fef61ae3          	bne	a2,a5,80000d6c <memmove+0x52>
    80000d7c:	b7e1                	j	80000d44 <memmove+0x2a>

0000000080000d7e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d7e:	1141                	addi	sp,sp,-16
    80000d80:	e406                	sd	ra,8(sp)
    80000d82:	e022                	sd	s0,0(sp)
    80000d84:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	f94080e7          	jalr	-108(ra) # 80000d1a <memmove>
}
    80000d8e:	60a2                	ld	ra,8(sp)
    80000d90:	6402                	ld	s0,0(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret

0000000080000d96 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e422                	sd	s0,8(sp)
    80000d9a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9c:	ce11                	beqz	a2,80000db8 <strncmp+0x22>
    80000d9e:	00054783          	lbu	a5,0(a0)
    80000da2:	cf89                	beqz	a5,80000dbc <strncmp+0x26>
    80000da4:	0005c703          	lbu	a4,0(a1)
    80000da8:	00f71a63          	bne	a4,a5,80000dbc <strncmp+0x26>
    n--, p++, q++;
    80000dac:	367d                	addiw	a2,a2,-1
    80000dae:	0505                	addi	a0,a0,1
    80000db0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db2:	f675                	bnez	a2,80000d9e <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db4:	4501                	li	a0,0
    80000db6:	a809                	j	80000dc8 <strncmp+0x32>
    80000db8:	4501                	li	a0,0
    80000dba:	a039                	j	80000dc8 <strncmp+0x32>
  if(n == 0)
    80000dbc:	ca09                	beqz	a2,80000dce <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dbe:	00054503          	lbu	a0,0(a0)
    80000dc2:	0005c783          	lbu	a5,0(a1)
    80000dc6:	9d1d                	subw	a0,a0,a5
}
    80000dc8:	6422                	ld	s0,8(sp)
    80000dca:	0141                	addi	sp,sp,16
    80000dcc:	8082                	ret
    return 0;
    80000dce:	4501                	li	a0,0
    80000dd0:	bfe5                	j	80000dc8 <strncmp+0x32>

0000000080000dd2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd2:	1141                	addi	sp,sp,-16
    80000dd4:	e422                	sd	s0,8(sp)
    80000dd6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd8:	872a                	mv	a4,a0
    80000dda:	8832                	mv	a6,a2
    80000ddc:	367d                	addiw	a2,a2,-1
    80000dde:	01005963          	blez	a6,80000df0 <strncpy+0x1e>
    80000de2:	0705                	addi	a4,a4,1
    80000de4:	0005c783          	lbu	a5,0(a1)
    80000de8:	fef70fa3          	sb	a5,-1(a4)
    80000dec:	0585                	addi	a1,a1,1
    80000dee:	f7f5                	bnez	a5,80000dda <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df0:	86ba                	mv	a3,a4
    80000df2:	00c05c63          	blez	a2,80000e0a <strncpy+0x38>
    *s++ = 0;
    80000df6:	0685                	addi	a3,a3,1
    80000df8:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000dfc:	fff6c793          	not	a5,a3
    80000e00:	9fb9                	addw	a5,a5,a4
    80000e02:	010787bb          	addw	a5,a5,a6
    80000e06:	fef048e3          	bgtz	a5,80000df6 <strncpy+0x24>
  return os;
}
    80000e0a:	6422                	ld	s0,8(sp)
    80000e0c:	0141                	addi	sp,sp,16
    80000e0e:	8082                	ret

0000000080000e10 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e10:	1141                	addi	sp,sp,-16
    80000e12:	e422                	sd	s0,8(sp)
    80000e14:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e16:	02c05363          	blez	a2,80000e3c <safestrcpy+0x2c>
    80000e1a:	fff6069b          	addiw	a3,a2,-1
    80000e1e:	1682                	slli	a3,a3,0x20
    80000e20:	9281                	srli	a3,a3,0x20
    80000e22:	96ae                	add	a3,a3,a1
    80000e24:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e26:	00d58963          	beq	a1,a3,80000e38 <safestrcpy+0x28>
    80000e2a:	0585                	addi	a1,a1,1
    80000e2c:	0785                	addi	a5,a5,1
    80000e2e:	fff5c703          	lbu	a4,-1(a1)
    80000e32:	fee78fa3          	sb	a4,-1(a5)
    80000e36:	fb65                	bnez	a4,80000e26 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e38:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e3c:	6422                	ld	s0,8(sp)
    80000e3e:	0141                	addi	sp,sp,16
    80000e40:	8082                	ret

0000000080000e42 <strlen>:

int
strlen(const char *s)
{
    80000e42:	1141                	addi	sp,sp,-16
    80000e44:	e422                	sd	s0,8(sp)
    80000e46:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e48:	00054783          	lbu	a5,0(a0)
    80000e4c:	cf91                	beqz	a5,80000e68 <strlen+0x26>
    80000e4e:	0505                	addi	a0,a0,1
    80000e50:	87aa                	mv	a5,a0
    80000e52:	4685                	li	a3,1
    80000e54:	9e89                	subw	a3,a3,a0
    80000e56:	00f6853b          	addw	a0,a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	fb7d                	bnez	a4,80000e56 <strlen+0x14>
    ;
  return n;
}
    80000e62:	6422                	ld	s0,8(sp)
    80000e64:	0141                	addi	sp,sp,16
    80000e66:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e68:	4501                	li	a0,0
    80000e6a:	bfe5                	j	80000e62 <strlen+0x20>

0000000080000e6c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e6c:	1141                	addi	sp,sp,-16
    80000e6e:	e406                	sd	ra,8(sp)
    80000e70:	e022                	sd	s0,0(sp)
    80000e72:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e74:	00001097          	auipc	ra,0x1
    80000e78:	ade080e7          	jalr	-1314(ra) # 80001952 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e7c:	00008717          	auipc	a4,0x8
    80000e80:	19c70713          	addi	a4,a4,412 # 80009018 <started>
  if(cpuid() == 0){
    80000e84:	c139                	beqz	a0,80000eca <main+0x5e>
    while(started == 0)
    80000e86:	431c                	lw	a5,0(a4)
    80000e88:	2781                	sext.w	a5,a5
    80000e8a:	dff5                	beqz	a5,80000e86 <main+0x1a>
      ;
    __sync_synchronize();
    80000e8c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e90:	00001097          	auipc	ra,0x1
    80000e94:	ac2080e7          	jalr	-1342(ra) # 80001952 <cpuid>
    80000e98:	85aa                	mv	a1,a0
    80000e9a:	00007517          	auipc	a0,0x7
    80000e9e:	21e50513          	addi	a0,a0,542 # 800080b8 <digits+0x78>
    80000ea2:	fffff097          	auipc	ra,0xfffff
    80000ea6:	6d2080e7          	jalr	1746(ra) # 80000574 <printf>
    kvminithart();    // turn on paging
    80000eaa:	00000097          	auipc	ra,0x0
    80000eae:	0d8080e7          	jalr	216(ra) # 80000f82 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb2:	00002097          	auipc	ra,0x2
    80000eb6:	cc2080e7          	jalr	-830(ra) # 80002b74 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00005097          	auipc	ra,0x5
    80000ebe:	3e6080e7          	jalr	998(ra) # 800062a0 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	2e0080e7          	jalr	736(ra) # 800021a2 <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00007517          	auipc	a0,0x7
    80000ede:	1ee50513          	addi	a0,a0,494 # 800080c8 <digits+0x88>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00007517          	auipc	a0,0x7
    80000eee:	1b650513          	addi	a0,a0,438 # 800080a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00007517          	auipc	a0,0x7
    80000efe:	1ce50513          	addi	a0,a0,462 # 800080c8 <digits+0x88>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    kinit();         // physical page allocator
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	b8c080e7          	jalr	-1140(ra) # 80000a96 <kinit>
    kvminit();       // create kernel page table
    80000f12:	00000097          	auipc	ra,0x0
    80000f16:	310080e7          	jalr	784(ra) # 80001222 <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	068080e7          	jalr	104(ra) # 80000f82 <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	980080e7          	jalr	-1664(ra) # 800018a2 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	c22080e7          	jalr	-990(ra) # 80002b4c <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	c42080e7          	jalr	-958(ra) # 80002b74 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00005097          	auipc	ra,0x5
    80000f3e:	350080e7          	jalr	848(ra) # 8000628a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00005097          	auipc	ra,0x5
    80000f46:	35e080e7          	jalr	862(ra) # 800062a0 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	526080e7          	jalr	1318(ra) # 80003470 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	bb8080e7          	jalr	-1096(ra) # 80003b0a <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	b66080e7          	jalr	-1178(ra) # 80004ac0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	460080e7          	jalr	1120(ra) # 800063c2 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	d58080e7          	jalr	-680(ra) # 80001cc2 <userinit>
    __sync_synchronize();
    80000f72:	0ff0000f          	fence
    started = 1;
    80000f76:	4785                	li	a5,1
    80000f78:	00008717          	auipc	a4,0x8
    80000f7c:	0af72023          	sw	a5,160(a4) # 80009018 <started>
    80000f80:	b789                	j	80000ec2 <main+0x56>

0000000080000f82 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f82:	1141                	addi	sp,sp,-16
    80000f84:	e422                	sd	s0,8(sp)
    80000f86:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f88:	00008797          	auipc	a5,0x8
    80000f8c:	0987b783          	ld	a5,152(a5) # 80009020 <kernel_pagetable>
    80000f90:	83b1                	srli	a5,a5,0xc
    80000f92:	577d                	li	a4,-1
    80000f94:	177e                	slli	a4,a4,0x3f
    80000f96:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f98:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f9c:	12000073          	sfence.vma
  sfence_vma();
}
    80000fa0:	6422                	ld	s0,8(sp)
    80000fa2:	0141                	addi	sp,sp,16
    80000fa4:	8082                	ret

0000000080000fa6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fa6:	7139                	addi	sp,sp,-64
    80000fa8:	fc06                	sd	ra,56(sp)
    80000faa:	f822                	sd	s0,48(sp)
    80000fac:	f426                	sd	s1,40(sp)
    80000fae:	f04a                	sd	s2,32(sp)
    80000fb0:	ec4e                	sd	s3,24(sp)
    80000fb2:	e852                	sd	s4,16(sp)
    80000fb4:	e456                	sd	s5,8(sp)
    80000fb6:	e05a                	sd	s6,0(sp)
    80000fb8:	0080                	addi	s0,sp,64
    80000fba:	84aa                	mv	s1,a0
    80000fbc:	89ae                	mv	s3,a1
    80000fbe:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fc0:	57fd                	li	a5,-1
    80000fc2:	83e9                	srli	a5,a5,0x1a
    80000fc4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fc6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fc8:	04b7f263          	bgeu	a5,a1,8000100c <walk+0x66>
    panic("walk");
    80000fcc:	00007517          	auipc	a0,0x7
    80000fd0:	10450513          	addi	a0,a0,260 # 800080d0 <digits+0x90>
    80000fd4:	fffff097          	auipc	ra,0xfffff
    80000fd8:	556080e7          	jalr	1366(ra) # 8000052a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fdc:	060a8663          	beqz	s5,80001048 <walk+0xa2>
    80000fe0:	00000097          	auipc	ra,0x0
    80000fe4:	af2080e7          	jalr	-1294(ra) # 80000ad2 <kalloc>
    80000fe8:	84aa                	mv	s1,a0
    80000fea:	c529                	beqz	a0,80001034 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000fec:	6605                	lui	a2,0x1
    80000fee:	4581                	li	a1,0
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	cce080e7          	jalr	-818(ra) # 80000cbe <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000ff8:	00c4d793          	srli	a5,s1,0xc
    80000ffc:	07aa                	slli	a5,a5,0xa
    80000ffe:	0017e793          	ori	a5,a5,1
    80001002:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001006:	3a5d                	addiw	s4,s4,-9
    80001008:	036a0063          	beq	s4,s6,80001028 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000100c:	0149d933          	srl	s2,s3,s4
    80001010:	1ff97913          	andi	s2,s2,511
    80001014:	090e                	slli	s2,s2,0x3
    80001016:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001018:	00093483          	ld	s1,0(s2)
    8000101c:	0014f793          	andi	a5,s1,1
    80001020:	dfd5                	beqz	a5,80000fdc <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001022:	80a9                	srli	s1,s1,0xa
    80001024:	04b2                	slli	s1,s1,0xc
    80001026:	b7c5                	j	80001006 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001028:	00c9d513          	srli	a0,s3,0xc
    8000102c:	1ff57513          	andi	a0,a0,511
    80001030:	050e                	slli	a0,a0,0x3
    80001032:	9526                	add	a0,a0,s1
}
    80001034:	70e2                	ld	ra,56(sp)
    80001036:	7442                	ld	s0,48(sp)
    80001038:	74a2                	ld	s1,40(sp)
    8000103a:	7902                	ld	s2,32(sp)
    8000103c:	69e2                	ld	s3,24(sp)
    8000103e:	6a42                	ld	s4,16(sp)
    80001040:	6aa2                	ld	s5,8(sp)
    80001042:	6b02                	ld	s6,0(sp)
    80001044:	6121                	addi	sp,sp,64
    80001046:	8082                	ret
        return 0;
    80001048:	4501                	li	a0,0
    8000104a:	b7ed                	j	80001034 <walk+0x8e>

000000008000104c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000104c:	57fd                	li	a5,-1
    8000104e:	83e9                	srli	a5,a5,0x1a
    80001050:	00b7f463          	bgeu	a5,a1,80001058 <walkaddr+0xc>
    return 0;
    80001054:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001056:	8082                	ret
{
    80001058:	1141                	addi	sp,sp,-16
    8000105a:	e406                	sd	ra,8(sp)
    8000105c:	e022                	sd	s0,0(sp)
    8000105e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001060:	4601                	li	a2,0
    80001062:	00000097          	auipc	ra,0x0
    80001066:	f44080e7          	jalr	-188(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000106a:	c105                	beqz	a0,8000108a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000106c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000106e:	0117f693          	andi	a3,a5,17
    80001072:	4745                	li	a4,17
    return 0;
    80001074:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001076:	00e68663          	beq	a3,a4,80001082 <walkaddr+0x36>
}
    8000107a:	60a2                	ld	ra,8(sp)
    8000107c:	6402                	ld	s0,0(sp)
    8000107e:	0141                	addi	sp,sp,16
    80001080:	8082                	ret
  pa = PTE2PA(*pte);
    80001082:	00a7d513          	srli	a0,a5,0xa
    80001086:	0532                	slli	a0,a0,0xc
  return pa;
    80001088:	bfcd                	j	8000107a <walkaddr+0x2e>
    return 0;
    8000108a:	4501                	li	a0,0
    8000108c:	b7fd                	j	8000107a <walkaddr+0x2e>

000000008000108e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000108e:	715d                	addi	sp,sp,-80
    80001090:	e486                	sd	ra,72(sp)
    80001092:	e0a2                	sd	s0,64(sp)
    80001094:	fc26                	sd	s1,56(sp)
    80001096:	f84a                	sd	s2,48(sp)
    80001098:	f44e                	sd	s3,40(sp)
    8000109a:	f052                	sd	s4,32(sp)
    8000109c:	ec56                	sd	s5,24(sp)
    8000109e:	e85a                	sd	s6,16(sp)
    800010a0:	e45e                	sd	s7,8(sp)
    800010a2:	0880                	addi	s0,sp,80
    800010a4:	8aaa                	mv	s5,a0
    800010a6:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010a8:	777d                	lui	a4,0xfffff
    800010aa:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ae:	167d                	addi	a2,a2,-1
    800010b0:	00b609b3          	add	s3,a2,a1
    800010b4:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010b8:	893e                	mv	s2,a5
    800010ba:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010be:	6b85                	lui	s7,0x1
    800010c0:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c4:	4605                	li	a2,1
    800010c6:	85ca                	mv	a1,s2
    800010c8:	8556                	mv	a0,s5
    800010ca:	00000097          	auipc	ra,0x0
    800010ce:	edc080e7          	jalr	-292(ra) # 80000fa6 <walk>
    800010d2:	c51d                	beqz	a0,80001100 <mappages+0x72>
    if(*pte & PTE_V)
    800010d4:	611c                	ld	a5,0(a0)
    800010d6:	8b85                	andi	a5,a5,1
    800010d8:	ef81                	bnez	a5,800010f0 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010da:	80b1                	srli	s1,s1,0xc
    800010dc:	04aa                	slli	s1,s1,0xa
    800010de:	0164e4b3          	or	s1,s1,s6
    800010e2:	0014e493          	ori	s1,s1,1
    800010e6:	e104                	sd	s1,0(a0)
    if(a == last)
    800010e8:	03390863          	beq	s2,s3,80001118 <mappages+0x8a>
    a += PGSIZE;
    800010ec:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010ee:	bfc9                	j	800010c0 <mappages+0x32>
      panic("remap");
    800010f0:	00007517          	auipc	a0,0x7
    800010f4:	fe850513          	addi	a0,a0,-24 # 800080d8 <digits+0x98>
    800010f8:	fffff097          	auipc	ra,0xfffff
    800010fc:	432080e7          	jalr	1074(ra) # 8000052a <panic>
      return -1;
    80001100:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001102:	60a6                	ld	ra,72(sp)
    80001104:	6406                	ld	s0,64(sp)
    80001106:	74e2                	ld	s1,56(sp)
    80001108:	7942                	ld	s2,48(sp)
    8000110a:	79a2                	ld	s3,40(sp)
    8000110c:	7a02                	ld	s4,32(sp)
    8000110e:	6ae2                	ld	s5,24(sp)
    80001110:	6b42                	ld	s6,16(sp)
    80001112:	6ba2                	ld	s7,8(sp)
    80001114:	6161                	addi	sp,sp,80
    80001116:	8082                	ret
  return 0;
    80001118:	4501                	li	a0,0
    8000111a:	b7e5                	j	80001102 <mappages+0x74>

000000008000111c <kvmmap>:
{
    8000111c:	1141                	addi	sp,sp,-16
    8000111e:	e406                	sd	ra,8(sp)
    80001120:	e022                	sd	s0,0(sp)
    80001122:	0800                	addi	s0,sp,16
    80001124:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001126:	86b2                	mv	a3,a2
    80001128:	863e                	mv	a2,a5
    8000112a:	00000097          	auipc	ra,0x0
    8000112e:	f64080e7          	jalr	-156(ra) # 8000108e <mappages>
    80001132:	e509                	bnez	a0,8000113c <kvmmap+0x20>
}
    80001134:	60a2                	ld	ra,8(sp)
    80001136:	6402                	ld	s0,0(sp)
    80001138:	0141                	addi	sp,sp,16
    8000113a:	8082                	ret
    panic("kvmmap");
    8000113c:	00007517          	auipc	a0,0x7
    80001140:	fa450513          	addi	a0,a0,-92 # 800080e0 <digits+0xa0>
    80001144:	fffff097          	auipc	ra,0xfffff
    80001148:	3e6080e7          	jalr	998(ra) # 8000052a <panic>

000000008000114c <kvmmake>:
{
    8000114c:	1101                	addi	sp,sp,-32
    8000114e:	ec06                	sd	ra,24(sp)
    80001150:	e822                	sd	s0,16(sp)
    80001152:	e426                	sd	s1,8(sp)
    80001154:	e04a                	sd	s2,0(sp)
    80001156:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001158:	00000097          	auipc	ra,0x0
    8000115c:	97a080e7          	jalr	-1670(ra) # 80000ad2 <kalloc>
    80001160:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001162:	6605                	lui	a2,0x1
    80001164:	4581                	li	a1,0
    80001166:	00000097          	auipc	ra,0x0
    8000116a:	b58080e7          	jalr	-1192(ra) # 80000cbe <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000116e:	4719                	li	a4,6
    80001170:	6685                	lui	a3,0x1
    80001172:	10000637          	lui	a2,0x10000
    80001176:	100005b7          	lui	a1,0x10000
    8000117a:	8526                	mv	a0,s1
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	fa0080e7          	jalr	-96(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001184:	4719                	li	a4,6
    80001186:	6685                	lui	a3,0x1
    80001188:	10001637          	lui	a2,0x10001
    8000118c:	100015b7          	lui	a1,0x10001
    80001190:	8526                	mv	a0,s1
    80001192:	00000097          	auipc	ra,0x0
    80001196:	f8a080e7          	jalr	-118(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000119a:	4719                	li	a4,6
    8000119c:	004006b7          	lui	a3,0x400
    800011a0:	0c000637          	lui	a2,0xc000
    800011a4:	0c0005b7          	lui	a1,0xc000
    800011a8:	8526                	mv	a0,s1
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f72080e7          	jalr	-142(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011b2:	00007917          	auipc	s2,0x7
    800011b6:	e4e90913          	addi	s2,s2,-434 # 80008000 <etext>
    800011ba:	4729                	li	a4,10
    800011bc:	80007697          	auipc	a3,0x80007
    800011c0:	e4468693          	addi	a3,a3,-444 # 8000 <_entry-0x7fff8000>
    800011c4:	4605                	li	a2,1
    800011c6:	067e                	slli	a2,a2,0x1f
    800011c8:	85b2                	mv	a1,a2
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f50080e7          	jalr	-176(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011d4:	4719                	li	a4,6
    800011d6:	46c5                	li	a3,17
    800011d8:	06ee                	slli	a3,a3,0x1b
    800011da:	412686b3          	sub	a3,a3,s2
    800011de:	864a                	mv	a2,s2
    800011e0:	85ca                	mv	a1,s2
    800011e2:	8526                	mv	a0,s1
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	f38080e7          	jalr	-200(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011ec:	4729                	li	a4,10
    800011ee:	6685                	lui	a3,0x1
    800011f0:	00006617          	auipc	a2,0x6
    800011f4:	e1060613          	addi	a2,a2,-496 # 80007000 <_trampoline>
    800011f8:	040005b7          	lui	a1,0x4000
    800011fc:	15fd                	addi	a1,a1,-1
    800011fe:	05b2                	slli	a1,a1,0xc
    80001200:	8526                	mv	a0,s1
    80001202:	00000097          	auipc	ra,0x0
    80001206:	f1a080e7          	jalr	-230(ra) # 8000111c <kvmmap>
  proc_mapstacks(kpgtbl);
    8000120a:	8526                	mv	a0,s1
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	600080e7          	jalr	1536(ra) # 8000180c <proc_mapstacks>
}
    80001214:	8526                	mv	a0,s1
    80001216:	60e2                	ld	ra,24(sp)
    80001218:	6442                	ld	s0,16(sp)
    8000121a:	64a2                	ld	s1,8(sp)
    8000121c:	6902                	ld	s2,0(sp)
    8000121e:	6105                	addi	sp,sp,32
    80001220:	8082                	ret

0000000080001222 <kvminit>:
{
    80001222:	1141                	addi	sp,sp,-16
    80001224:	e406                	sd	ra,8(sp)
    80001226:	e022                	sd	s0,0(sp)
    80001228:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000122a:	00000097          	auipc	ra,0x0
    8000122e:	f22080e7          	jalr	-222(ra) # 8000114c <kvmmake>
    80001232:	00008797          	auipc	a5,0x8
    80001236:	dea7b723          	sd	a0,-530(a5) # 80009020 <kernel_pagetable>
}
    8000123a:	60a2                	ld	ra,8(sp)
    8000123c:	6402                	ld	s0,0(sp)
    8000123e:	0141                	addi	sp,sp,16
    80001240:	8082                	ret

0000000080001242 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001242:	715d                	addi	sp,sp,-80
    80001244:	e486                	sd	ra,72(sp)
    80001246:	e0a2                	sd	s0,64(sp)
    80001248:	fc26                	sd	s1,56(sp)
    8000124a:	f84a                	sd	s2,48(sp)
    8000124c:	f44e                	sd	s3,40(sp)
    8000124e:	f052                	sd	s4,32(sp)
    80001250:	ec56                	sd	s5,24(sp)
    80001252:	e85a                	sd	s6,16(sp)
    80001254:	e45e                	sd	s7,8(sp)
    80001256:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001258:	03459793          	slli	a5,a1,0x34
    8000125c:	e795                	bnez	a5,80001288 <uvmunmap+0x46>
    8000125e:	8a2a                	mv	s4,a0
    80001260:	892e                	mv	s2,a1
    80001262:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001264:	0632                	slli	a2,a2,0xc
    80001266:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000126a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000126c:	6b05                	lui	s6,0x1
    8000126e:	0735e263          	bltu	a1,s3,800012d2 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001272:	60a6                	ld	ra,72(sp)
    80001274:	6406                	ld	s0,64(sp)
    80001276:	74e2                	ld	s1,56(sp)
    80001278:	7942                	ld	s2,48(sp)
    8000127a:	79a2                	ld	s3,40(sp)
    8000127c:	7a02                	ld	s4,32(sp)
    8000127e:	6ae2                	ld	s5,24(sp)
    80001280:	6b42                	ld	s6,16(sp)
    80001282:	6ba2                	ld	s7,8(sp)
    80001284:	6161                	addi	sp,sp,80
    80001286:	8082                	ret
    panic("uvmunmap: not aligned");
    80001288:	00007517          	auipc	a0,0x7
    8000128c:	e6050513          	addi	a0,a0,-416 # 800080e8 <digits+0xa8>
    80001290:	fffff097          	auipc	ra,0xfffff
    80001294:	29a080e7          	jalr	666(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    80001298:	00007517          	auipc	a0,0x7
    8000129c:	e6850513          	addi	a0,a0,-408 # 80008100 <digits+0xc0>
    800012a0:	fffff097          	auipc	ra,0xfffff
    800012a4:	28a080e7          	jalr	650(ra) # 8000052a <panic>
      panic("uvmunmap: not mapped");
    800012a8:	00007517          	auipc	a0,0x7
    800012ac:	e6850513          	addi	a0,a0,-408 # 80008110 <digits+0xd0>
    800012b0:	fffff097          	auipc	ra,0xfffff
    800012b4:	27a080e7          	jalr	634(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    800012b8:	00007517          	auipc	a0,0x7
    800012bc:	e7050513          	addi	a0,a0,-400 # 80008128 <digits+0xe8>
    800012c0:	fffff097          	auipc	ra,0xfffff
    800012c4:	26a080e7          	jalr	618(ra) # 8000052a <panic>
    *pte = 0;
    800012c8:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012cc:	995a                	add	s2,s2,s6
    800012ce:	fb3972e3          	bgeu	s2,s3,80001272 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012d2:	4601                	li	a2,0
    800012d4:	85ca                	mv	a1,s2
    800012d6:	8552                	mv	a0,s4
    800012d8:	00000097          	auipc	ra,0x0
    800012dc:	cce080e7          	jalr	-818(ra) # 80000fa6 <walk>
    800012e0:	84aa                	mv	s1,a0
    800012e2:	d95d                	beqz	a0,80001298 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012e4:	6108                	ld	a0,0(a0)
    800012e6:	00157793          	andi	a5,a0,1
    800012ea:	dfdd                	beqz	a5,800012a8 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800012ec:	3ff57793          	andi	a5,a0,1023
    800012f0:	fd7784e3          	beq	a5,s7,800012b8 <uvmunmap+0x76>
    if(do_free){
    800012f4:	fc0a8ae3          	beqz	s5,800012c8 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800012f8:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012fa:	0532                	slli	a0,a0,0xc
    800012fc:	fffff097          	auipc	ra,0xfffff
    80001300:	6da080e7          	jalr	1754(ra) # 800009d6 <kfree>
    80001304:	b7d1                	j	800012c8 <uvmunmap+0x86>

0000000080001306 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001306:	1101                	addi	sp,sp,-32
    80001308:	ec06                	sd	ra,24(sp)
    8000130a:	e822                	sd	s0,16(sp)
    8000130c:	e426                	sd	s1,8(sp)
    8000130e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001310:	fffff097          	auipc	ra,0xfffff
    80001314:	7c2080e7          	jalr	1986(ra) # 80000ad2 <kalloc>
    80001318:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000131a:	c519                	beqz	a0,80001328 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000131c:	6605                	lui	a2,0x1
    8000131e:	4581                	li	a1,0
    80001320:	00000097          	auipc	ra,0x0
    80001324:	99e080e7          	jalr	-1634(ra) # 80000cbe <memset>
  return pagetable;
}
    80001328:	8526                	mv	a0,s1
    8000132a:	60e2                	ld	ra,24(sp)
    8000132c:	6442                	ld	s0,16(sp)
    8000132e:	64a2                	ld	s1,8(sp)
    80001330:	6105                	addi	sp,sp,32
    80001332:	8082                	ret

0000000080001334 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001334:	7179                	addi	sp,sp,-48
    80001336:	f406                	sd	ra,40(sp)
    80001338:	f022                	sd	s0,32(sp)
    8000133a:	ec26                	sd	s1,24(sp)
    8000133c:	e84a                	sd	s2,16(sp)
    8000133e:	e44e                	sd	s3,8(sp)
    80001340:	e052                	sd	s4,0(sp)
    80001342:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001344:	6785                	lui	a5,0x1
    80001346:	04f67863          	bgeu	a2,a5,80001396 <uvminit+0x62>
    8000134a:	8a2a                	mv	s4,a0
    8000134c:	89ae                	mv	s3,a1
    8000134e:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001350:	fffff097          	auipc	ra,0xfffff
    80001354:	782080e7          	jalr	1922(ra) # 80000ad2 <kalloc>
    80001358:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000135a:	6605                	lui	a2,0x1
    8000135c:	4581                	li	a1,0
    8000135e:	00000097          	auipc	ra,0x0
    80001362:	960080e7          	jalr	-1696(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001366:	4779                	li	a4,30
    80001368:	86ca                	mv	a3,s2
    8000136a:	6605                	lui	a2,0x1
    8000136c:	4581                	li	a1,0
    8000136e:	8552                	mv	a0,s4
    80001370:	00000097          	auipc	ra,0x0
    80001374:	d1e080e7          	jalr	-738(ra) # 8000108e <mappages>
  memmove(mem, src, sz);
    80001378:	8626                	mv	a2,s1
    8000137a:	85ce                	mv	a1,s3
    8000137c:	854a                	mv	a0,s2
    8000137e:	00000097          	auipc	ra,0x0
    80001382:	99c080e7          	jalr	-1636(ra) # 80000d1a <memmove>
}
    80001386:	70a2                	ld	ra,40(sp)
    80001388:	7402                	ld	s0,32(sp)
    8000138a:	64e2                	ld	s1,24(sp)
    8000138c:	6942                	ld	s2,16(sp)
    8000138e:	69a2                	ld	s3,8(sp)
    80001390:	6a02                	ld	s4,0(sp)
    80001392:	6145                	addi	sp,sp,48
    80001394:	8082                	ret
    panic("inituvm: more than a page");
    80001396:	00007517          	auipc	a0,0x7
    8000139a:	daa50513          	addi	a0,a0,-598 # 80008140 <digits+0x100>
    8000139e:	fffff097          	auipc	ra,0xfffff
    800013a2:	18c080e7          	jalr	396(ra) # 8000052a <panic>

00000000800013a6 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013a6:	1101                	addi	sp,sp,-32
    800013a8:	ec06                	sd	ra,24(sp)
    800013aa:	e822                	sd	s0,16(sp)
    800013ac:	e426                	sd	s1,8(sp)
    800013ae:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013b0:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013b2:	00b67d63          	bgeu	a2,a1,800013cc <uvmdealloc+0x26>
    800013b6:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013b8:	6785                	lui	a5,0x1
    800013ba:	17fd                	addi	a5,a5,-1
    800013bc:	00f60733          	add	a4,a2,a5
    800013c0:	767d                	lui	a2,0xfffff
    800013c2:	8f71                	and	a4,a4,a2
    800013c4:	97ae                	add	a5,a5,a1
    800013c6:	8ff1                	and	a5,a5,a2
    800013c8:	00f76863          	bltu	a4,a5,800013d8 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013cc:	8526                	mv	a0,s1
    800013ce:	60e2                	ld	ra,24(sp)
    800013d0:	6442                	ld	s0,16(sp)
    800013d2:	64a2                	ld	s1,8(sp)
    800013d4:	6105                	addi	sp,sp,32
    800013d6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013d8:	8f99                	sub	a5,a5,a4
    800013da:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013dc:	4685                	li	a3,1
    800013de:	0007861b          	sext.w	a2,a5
    800013e2:	85ba                	mv	a1,a4
    800013e4:	00000097          	auipc	ra,0x0
    800013e8:	e5e080e7          	jalr	-418(ra) # 80001242 <uvmunmap>
    800013ec:	b7c5                	j	800013cc <uvmdealloc+0x26>

00000000800013ee <uvmalloc>:
  if(newsz < oldsz)
    800013ee:	0ab66163          	bltu	a2,a1,80001490 <uvmalloc+0xa2>
{
    800013f2:	7139                	addi	sp,sp,-64
    800013f4:	fc06                	sd	ra,56(sp)
    800013f6:	f822                	sd	s0,48(sp)
    800013f8:	f426                	sd	s1,40(sp)
    800013fa:	f04a                	sd	s2,32(sp)
    800013fc:	ec4e                	sd	s3,24(sp)
    800013fe:	e852                	sd	s4,16(sp)
    80001400:	e456                	sd	s5,8(sp)
    80001402:	0080                	addi	s0,sp,64
    80001404:	8aaa                	mv	s5,a0
    80001406:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001408:	6985                	lui	s3,0x1
    8000140a:	19fd                	addi	s3,s3,-1
    8000140c:	95ce                	add	a1,a1,s3
    8000140e:	79fd                	lui	s3,0xfffff
    80001410:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001414:	08c9f063          	bgeu	s3,a2,80001494 <uvmalloc+0xa6>
    80001418:	894e                	mv	s2,s3
    mem = kalloc();
    8000141a:	fffff097          	auipc	ra,0xfffff
    8000141e:	6b8080e7          	jalr	1720(ra) # 80000ad2 <kalloc>
    80001422:	84aa                	mv	s1,a0
    if(mem == 0){
    80001424:	c51d                	beqz	a0,80001452 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001426:	6605                	lui	a2,0x1
    80001428:	4581                	li	a1,0
    8000142a:	00000097          	auipc	ra,0x0
    8000142e:	894080e7          	jalr	-1900(ra) # 80000cbe <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001432:	4779                	li	a4,30
    80001434:	86a6                	mv	a3,s1
    80001436:	6605                	lui	a2,0x1
    80001438:	85ca                	mv	a1,s2
    8000143a:	8556                	mv	a0,s5
    8000143c:	00000097          	auipc	ra,0x0
    80001440:	c52080e7          	jalr	-942(ra) # 8000108e <mappages>
    80001444:	e905                	bnez	a0,80001474 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001446:	6785                	lui	a5,0x1
    80001448:	993e                	add	s2,s2,a5
    8000144a:	fd4968e3          	bltu	s2,s4,8000141a <uvmalloc+0x2c>
  return newsz;
    8000144e:	8552                	mv	a0,s4
    80001450:	a809                	j	80001462 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001452:	864e                	mv	a2,s3
    80001454:	85ca                	mv	a1,s2
    80001456:	8556                	mv	a0,s5
    80001458:	00000097          	auipc	ra,0x0
    8000145c:	f4e080e7          	jalr	-178(ra) # 800013a6 <uvmdealloc>
      return 0;
    80001460:	4501                	li	a0,0
}
    80001462:	70e2                	ld	ra,56(sp)
    80001464:	7442                	ld	s0,48(sp)
    80001466:	74a2                	ld	s1,40(sp)
    80001468:	7902                	ld	s2,32(sp)
    8000146a:	69e2                	ld	s3,24(sp)
    8000146c:	6a42                	ld	s4,16(sp)
    8000146e:	6aa2                	ld	s5,8(sp)
    80001470:	6121                	addi	sp,sp,64
    80001472:	8082                	ret
      kfree(mem);
    80001474:	8526                	mv	a0,s1
    80001476:	fffff097          	auipc	ra,0xfffff
    8000147a:	560080e7          	jalr	1376(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000147e:	864e                	mv	a2,s3
    80001480:	85ca                	mv	a1,s2
    80001482:	8556                	mv	a0,s5
    80001484:	00000097          	auipc	ra,0x0
    80001488:	f22080e7          	jalr	-222(ra) # 800013a6 <uvmdealloc>
      return 0;
    8000148c:	4501                	li	a0,0
    8000148e:	bfd1                	j	80001462 <uvmalloc+0x74>
    return oldsz;
    80001490:	852e                	mv	a0,a1
}
    80001492:	8082                	ret
  return newsz;
    80001494:	8532                	mv	a0,a2
    80001496:	b7f1                	j	80001462 <uvmalloc+0x74>

0000000080001498 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001498:	7179                	addi	sp,sp,-48
    8000149a:	f406                	sd	ra,40(sp)
    8000149c:	f022                	sd	s0,32(sp)
    8000149e:	ec26                	sd	s1,24(sp)
    800014a0:	e84a                	sd	s2,16(sp)
    800014a2:	e44e                	sd	s3,8(sp)
    800014a4:	e052                	sd	s4,0(sp)
    800014a6:	1800                	addi	s0,sp,48
    800014a8:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014aa:	84aa                	mv	s1,a0
    800014ac:	6905                	lui	s2,0x1
    800014ae:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014b0:	4985                	li	s3,1
    800014b2:	a821                	j	800014ca <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014b4:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014b6:	0532                	slli	a0,a0,0xc
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	fe0080e7          	jalr	-32(ra) # 80001498 <freewalk>
      pagetable[i] = 0;
    800014c0:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014c4:	04a1                	addi	s1,s1,8
    800014c6:	03248163          	beq	s1,s2,800014e8 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014ca:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014cc:	00f57793          	andi	a5,a0,15
    800014d0:	ff3782e3          	beq	a5,s3,800014b4 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014d4:	8905                	andi	a0,a0,1
    800014d6:	d57d                	beqz	a0,800014c4 <freewalk+0x2c>
      panic("freewalk: leaf");
    800014d8:	00007517          	auipc	a0,0x7
    800014dc:	c8850513          	addi	a0,a0,-888 # 80008160 <digits+0x120>
    800014e0:	fffff097          	auipc	ra,0xfffff
    800014e4:	04a080e7          	jalr	74(ra) # 8000052a <panic>
    }
  }
  kfree((void*)pagetable);
    800014e8:	8552                	mv	a0,s4
    800014ea:	fffff097          	auipc	ra,0xfffff
    800014ee:	4ec080e7          	jalr	1260(ra) # 800009d6 <kfree>
}
    800014f2:	70a2                	ld	ra,40(sp)
    800014f4:	7402                	ld	s0,32(sp)
    800014f6:	64e2                	ld	s1,24(sp)
    800014f8:	6942                	ld	s2,16(sp)
    800014fa:	69a2                	ld	s3,8(sp)
    800014fc:	6a02                	ld	s4,0(sp)
    800014fe:	6145                	addi	sp,sp,48
    80001500:	8082                	ret

0000000080001502 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001502:	1101                	addi	sp,sp,-32
    80001504:	ec06                	sd	ra,24(sp)
    80001506:	e822                	sd	s0,16(sp)
    80001508:	e426                	sd	s1,8(sp)
    8000150a:	1000                	addi	s0,sp,32
    8000150c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000150e:	e999                	bnez	a1,80001524 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001510:	8526                	mv	a0,s1
    80001512:	00000097          	auipc	ra,0x0
    80001516:	f86080e7          	jalr	-122(ra) # 80001498 <freewalk>
}
    8000151a:	60e2                	ld	ra,24(sp)
    8000151c:	6442                	ld	s0,16(sp)
    8000151e:	64a2                	ld	s1,8(sp)
    80001520:	6105                	addi	sp,sp,32
    80001522:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001524:	6605                	lui	a2,0x1
    80001526:	167d                	addi	a2,a2,-1
    80001528:	962e                	add	a2,a2,a1
    8000152a:	4685                	li	a3,1
    8000152c:	8231                	srli	a2,a2,0xc
    8000152e:	4581                	li	a1,0
    80001530:	00000097          	auipc	ra,0x0
    80001534:	d12080e7          	jalr	-750(ra) # 80001242 <uvmunmap>
    80001538:	bfe1                	j	80001510 <uvmfree+0xe>

000000008000153a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000153a:	c679                	beqz	a2,80001608 <uvmcopy+0xce>
{
    8000153c:	715d                	addi	sp,sp,-80
    8000153e:	e486                	sd	ra,72(sp)
    80001540:	e0a2                	sd	s0,64(sp)
    80001542:	fc26                	sd	s1,56(sp)
    80001544:	f84a                	sd	s2,48(sp)
    80001546:	f44e                	sd	s3,40(sp)
    80001548:	f052                	sd	s4,32(sp)
    8000154a:	ec56                	sd	s5,24(sp)
    8000154c:	e85a                	sd	s6,16(sp)
    8000154e:	e45e                	sd	s7,8(sp)
    80001550:	0880                	addi	s0,sp,80
    80001552:	8b2a                	mv	s6,a0
    80001554:	8aae                	mv	s5,a1
    80001556:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001558:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000155a:	4601                	li	a2,0
    8000155c:	85ce                	mv	a1,s3
    8000155e:	855a                	mv	a0,s6
    80001560:	00000097          	auipc	ra,0x0
    80001564:	a46080e7          	jalr	-1466(ra) # 80000fa6 <walk>
    80001568:	c531                	beqz	a0,800015b4 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000156a:	6118                	ld	a4,0(a0)
    8000156c:	00177793          	andi	a5,a4,1
    80001570:	cbb1                	beqz	a5,800015c4 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001572:	00a75593          	srli	a1,a4,0xa
    80001576:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000157a:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000157e:	fffff097          	auipc	ra,0xfffff
    80001582:	554080e7          	jalr	1364(ra) # 80000ad2 <kalloc>
    80001586:	892a                	mv	s2,a0
    80001588:	c939                	beqz	a0,800015de <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000158a:	6605                	lui	a2,0x1
    8000158c:	85de                	mv	a1,s7
    8000158e:	fffff097          	auipc	ra,0xfffff
    80001592:	78c080e7          	jalr	1932(ra) # 80000d1a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001596:	8726                	mv	a4,s1
    80001598:	86ca                	mv	a3,s2
    8000159a:	6605                	lui	a2,0x1
    8000159c:	85ce                	mv	a1,s3
    8000159e:	8556                	mv	a0,s5
    800015a0:	00000097          	auipc	ra,0x0
    800015a4:	aee080e7          	jalr	-1298(ra) # 8000108e <mappages>
    800015a8:	e515                	bnez	a0,800015d4 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015aa:	6785                	lui	a5,0x1
    800015ac:	99be                	add	s3,s3,a5
    800015ae:	fb49e6e3          	bltu	s3,s4,8000155a <uvmcopy+0x20>
    800015b2:	a081                	j	800015f2 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015b4:	00007517          	auipc	a0,0x7
    800015b8:	bbc50513          	addi	a0,a0,-1092 # 80008170 <digits+0x130>
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	f6e080e7          	jalr	-146(ra) # 8000052a <panic>
      panic("uvmcopy: page not present");
    800015c4:	00007517          	auipc	a0,0x7
    800015c8:	bcc50513          	addi	a0,a0,-1076 # 80008190 <digits+0x150>
    800015cc:	fffff097          	auipc	ra,0xfffff
    800015d0:	f5e080e7          	jalr	-162(ra) # 8000052a <panic>
      kfree(mem);
    800015d4:	854a                	mv	a0,s2
    800015d6:	fffff097          	auipc	ra,0xfffff
    800015da:	400080e7          	jalr	1024(ra) # 800009d6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015de:	4685                	li	a3,1
    800015e0:	00c9d613          	srli	a2,s3,0xc
    800015e4:	4581                	li	a1,0
    800015e6:	8556                	mv	a0,s5
    800015e8:	00000097          	auipc	ra,0x0
    800015ec:	c5a080e7          	jalr	-934(ra) # 80001242 <uvmunmap>
  return -1;
    800015f0:	557d                	li	a0,-1
}
    800015f2:	60a6                	ld	ra,72(sp)
    800015f4:	6406                	ld	s0,64(sp)
    800015f6:	74e2                	ld	s1,56(sp)
    800015f8:	7942                	ld	s2,48(sp)
    800015fa:	79a2                	ld	s3,40(sp)
    800015fc:	7a02                	ld	s4,32(sp)
    800015fe:	6ae2                	ld	s5,24(sp)
    80001600:	6b42                	ld	s6,16(sp)
    80001602:	6ba2                	ld	s7,8(sp)
    80001604:	6161                	addi	sp,sp,80
    80001606:	8082                	ret
  return 0;
    80001608:	4501                	li	a0,0
}
    8000160a:	8082                	ret

000000008000160c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000160c:	1141                	addi	sp,sp,-16
    8000160e:	e406                	sd	ra,8(sp)
    80001610:	e022                	sd	s0,0(sp)
    80001612:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001614:	4601                	li	a2,0
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	990080e7          	jalr	-1648(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000161e:	c901                	beqz	a0,8000162e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001620:	611c                	ld	a5,0(a0)
    80001622:	9bbd                	andi	a5,a5,-17
    80001624:	e11c                	sd	a5,0(a0)
}
    80001626:	60a2                	ld	ra,8(sp)
    80001628:	6402                	ld	s0,0(sp)
    8000162a:	0141                	addi	sp,sp,16
    8000162c:	8082                	ret
    panic("uvmclear");
    8000162e:	00007517          	auipc	a0,0x7
    80001632:	b8250513          	addi	a0,a0,-1150 # 800081b0 <digits+0x170>
    80001636:	fffff097          	auipc	ra,0xfffff
    8000163a:	ef4080e7          	jalr	-268(ra) # 8000052a <panic>

000000008000163e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000163e:	c6bd                	beqz	a3,800016ac <copyout+0x6e>
{
    80001640:	715d                	addi	sp,sp,-80
    80001642:	e486                	sd	ra,72(sp)
    80001644:	e0a2                	sd	s0,64(sp)
    80001646:	fc26                	sd	s1,56(sp)
    80001648:	f84a                	sd	s2,48(sp)
    8000164a:	f44e                	sd	s3,40(sp)
    8000164c:	f052                	sd	s4,32(sp)
    8000164e:	ec56                	sd	s5,24(sp)
    80001650:	e85a                	sd	s6,16(sp)
    80001652:	e45e                	sd	s7,8(sp)
    80001654:	e062                	sd	s8,0(sp)
    80001656:	0880                	addi	s0,sp,80
    80001658:	8b2a                	mv	s6,a0
    8000165a:	8c2e                	mv	s8,a1
    8000165c:	8a32                	mv	s4,a2
    8000165e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001660:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001662:	6a85                	lui	s5,0x1
    80001664:	a015                	j	80001688 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001666:	9562                	add	a0,a0,s8
    80001668:	0004861b          	sext.w	a2,s1
    8000166c:	85d2                	mv	a1,s4
    8000166e:	41250533          	sub	a0,a0,s2
    80001672:	fffff097          	auipc	ra,0xfffff
    80001676:	6a8080e7          	jalr	1704(ra) # 80000d1a <memmove>

    len -= n;
    8000167a:	409989b3          	sub	s3,s3,s1
    src += n;
    8000167e:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001680:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001684:	02098263          	beqz	s3,800016a8 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001688:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000168c:	85ca                	mv	a1,s2
    8000168e:	855a                	mv	a0,s6
    80001690:	00000097          	auipc	ra,0x0
    80001694:	9bc080e7          	jalr	-1604(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001698:	cd01                	beqz	a0,800016b0 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000169a:	418904b3          	sub	s1,s2,s8
    8000169e:	94d6                	add	s1,s1,s5
    if(n > len)
    800016a0:	fc99f3e3          	bgeu	s3,s1,80001666 <copyout+0x28>
    800016a4:	84ce                	mv	s1,s3
    800016a6:	b7c1                	j	80001666 <copyout+0x28>
  }
  return 0;
    800016a8:	4501                	li	a0,0
    800016aa:	a021                	j	800016b2 <copyout+0x74>
    800016ac:	4501                	li	a0,0
}
    800016ae:	8082                	ret
      return -1;
    800016b0:	557d                	li	a0,-1
}
    800016b2:	60a6                	ld	ra,72(sp)
    800016b4:	6406                	ld	s0,64(sp)
    800016b6:	74e2                	ld	s1,56(sp)
    800016b8:	7942                	ld	s2,48(sp)
    800016ba:	79a2                	ld	s3,40(sp)
    800016bc:	7a02                	ld	s4,32(sp)
    800016be:	6ae2                	ld	s5,24(sp)
    800016c0:	6b42                	ld	s6,16(sp)
    800016c2:	6ba2                	ld	s7,8(sp)
    800016c4:	6c02                	ld	s8,0(sp)
    800016c6:	6161                	addi	sp,sp,80
    800016c8:	8082                	ret

00000000800016ca <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016ca:	caa5                	beqz	a3,8000173a <copyin+0x70>
{
    800016cc:	715d                	addi	sp,sp,-80
    800016ce:	e486                	sd	ra,72(sp)
    800016d0:	e0a2                	sd	s0,64(sp)
    800016d2:	fc26                	sd	s1,56(sp)
    800016d4:	f84a                	sd	s2,48(sp)
    800016d6:	f44e                	sd	s3,40(sp)
    800016d8:	f052                	sd	s4,32(sp)
    800016da:	ec56                	sd	s5,24(sp)
    800016dc:	e85a                	sd	s6,16(sp)
    800016de:	e45e                	sd	s7,8(sp)
    800016e0:	e062                	sd	s8,0(sp)
    800016e2:	0880                	addi	s0,sp,80
    800016e4:	8b2a                	mv	s6,a0
    800016e6:	8a2e                	mv	s4,a1
    800016e8:	8c32                	mv	s8,a2
    800016ea:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800016ec:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016ee:	6a85                	lui	s5,0x1
    800016f0:	a01d                	j	80001716 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016f2:	018505b3          	add	a1,a0,s8
    800016f6:	0004861b          	sext.w	a2,s1
    800016fa:	412585b3          	sub	a1,a1,s2
    800016fe:	8552                	mv	a0,s4
    80001700:	fffff097          	auipc	ra,0xfffff
    80001704:	61a080e7          	jalr	1562(ra) # 80000d1a <memmove>

    len -= n;
    80001708:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000170c:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000170e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001712:	02098263          	beqz	s3,80001736 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001716:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000171a:	85ca                	mv	a1,s2
    8000171c:	855a                	mv	a0,s6
    8000171e:	00000097          	auipc	ra,0x0
    80001722:	92e080e7          	jalr	-1746(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001726:	cd01                	beqz	a0,8000173e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001728:	418904b3          	sub	s1,s2,s8
    8000172c:	94d6                	add	s1,s1,s5
    if(n > len)
    8000172e:	fc99f2e3          	bgeu	s3,s1,800016f2 <copyin+0x28>
    80001732:	84ce                	mv	s1,s3
    80001734:	bf7d                	j	800016f2 <copyin+0x28>
  }
  return 0;
    80001736:	4501                	li	a0,0
    80001738:	a021                	j	80001740 <copyin+0x76>
    8000173a:	4501                	li	a0,0
}
    8000173c:	8082                	ret
      return -1;
    8000173e:	557d                	li	a0,-1
}
    80001740:	60a6                	ld	ra,72(sp)
    80001742:	6406                	ld	s0,64(sp)
    80001744:	74e2                	ld	s1,56(sp)
    80001746:	7942                	ld	s2,48(sp)
    80001748:	79a2                	ld	s3,40(sp)
    8000174a:	7a02                	ld	s4,32(sp)
    8000174c:	6ae2                	ld	s5,24(sp)
    8000174e:	6b42                	ld	s6,16(sp)
    80001750:	6ba2                	ld	s7,8(sp)
    80001752:	6c02                	ld	s8,0(sp)
    80001754:	6161                	addi	sp,sp,80
    80001756:	8082                	ret

0000000080001758 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001758:	c6c5                	beqz	a3,80001800 <copyinstr+0xa8>
{
    8000175a:	715d                	addi	sp,sp,-80
    8000175c:	e486                	sd	ra,72(sp)
    8000175e:	e0a2                	sd	s0,64(sp)
    80001760:	fc26                	sd	s1,56(sp)
    80001762:	f84a                	sd	s2,48(sp)
    80001764:	f44e                	sd	s3,40(sp)
    80001766:	f052                	sd	s4,32(sp)
    80001768:	ec56                	sd	s5,24(sp)
    8000176a:	e85a                	sd	s6,16(sp)
    8000176c:	e45e                	sd	s7,8(sp)
    8000176e:	0880                	addi	s0,sp,80
    80001770:	8a2a                	mv	s4,a0
    80001772:	8b2e                	mv	s6,a1
    80001774:	8bb2                	mv	s7,a2
    80001776:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001778:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000177a:	6985                	lui	s3,0x1
    8000177c:	a035                	j	800017a8 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000177e:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001782:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001784:	0017b793          	seqz	a5,a5
    80001788:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000178c:	60a6                	ld	ra,72(sp)
    8000178e:	6406                	ld	s0,64(sp)
    80001790:	74e2                	ld	s1,56(sp)
    80001792:	7942                	ld	s2,48(sp)
    80001794:	79a2                	ld	s3,40(sp)
    80001796:	7a02                	ld	s4,32(sp)
    80001798:	6ae2                	ld	s5,24(sp)
    8000179a:	6b42                	ld	s6,16(sp)
    8000179c:	6ba2                	ld	s7,8(sp)
    8000179e:	6161                	addi	sp,sp,80
    800017a0:	8082                	ret
    srcva = va0 + PGSIZE;
    800017a2:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017a6:	c8a9                	beqz	s1,800017f8 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017a8:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017ac:	85ca                	mv	a1,s2
    800017ae:	8552                	mv	a0,s4
    800017b0:	00000097          	auipc	ra,0x0
    800017b4:	89c080e7          	jalr	-1892(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    800017b8:	c131                	beqz	a0,800017fc <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017ba:	41790833          	sub	a6,s2,s7
    800017be:	984e                	add	a6,a6,s3
    if(n > max)
    800017c0:	0104f363          	bgeu	s1,a6,800017c6 <copyinstr+0x6e>
    800017c4:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017c6:	955e                	add	a0,a0,s7
    800017c8:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017cc:	fc080be3          	beqz	a6,800017a2 <copyinstr+0x4a>
    800017d0:	985a                	add	a6,a6,s6
    800017d2:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017d4:	41650633          	sub	a2,a0,s6
    800017d8:	14fd                	addi	s1,s1,-1
    800017da:	9b26                	add	s6,s6,s1
    800017dc:	00f60733          	add	a4,a2,a5
    800017e0:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    800017e4:	df49                	beqz	a4,8000177e <copyinstr+0x26>
        *dst = *p;
    800017e6:	00e78023          	sb	a4,0(a5)
      --max;
    800017ea:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800017ee:	0785                	addi	a5,a5,1
    while(n > 0){
    800017f0:	ff0796e3          	bne	a5,a6,800017dc <copyinstr+0x84>
      dst++;
    800017f4:	8b42                	mv	s6,a6
    800017f6:	b775                	j	800017a2 <copyinstr+0x4a>
    800017f8:	4781                	li	a5,0
    800017fa:	b769                	j	80001784 <copyinstr+0x2c>
      return -1;
    800017fc:	557d                	li	a0,-1
    800017fe:	b779                	j	8000178c <copyinstr+0x34>
  int got_null = 0;
    80001800:	4781                	li	a5,0
  if(got_null){
    80001802:	0017b793          	seqz	a5,a5
    80001806:	40f00533          	neg	a0,a5
}
    8000180a:	8082                	ret

000000008000180c <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    8000180c:	7139                	addi	sp,sp,-64
    8000180e:	fc06                	sd	ra,56(sp)
    80001810:	f822                	sd	s0,48(sp)
    80001812:	f426                	sd	s1,40(sp)
    80001814:	f04a                	sd	s2,32(sp)
    80001816:	ec4e                	sd	s3,24(sp)
    80001818:	e852                	sd	s4,16(sp)
    8000181a:	e456                	sd	s5,8(sp)
    8000181c:	e05a                	sd	s6,0(sp)
    8000181e:	0080                	addi	s0,sp,64
    80001820:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001822:	00010497          	auipc	s1,0x10
    80001826:	eae48493          	addi	s1,s1,-338 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000182a:	8b26                	mv	s6,s1
    8000182c:	00006a97          	auipc	s5,0x6
    80001830:	7d4a8a93          	addi	s5,s5,2004 # 80008000 <etext>
    80001834:	04000937          	lui	s2,0x4000
    80001838:	197d                	addi	s2,s2,-1
    8000183a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183c:	00016a17          	auipc	s4,0x16
    80001840:	294a0a13          	addi	s4,s4,660 # 80017ad0 <tickslock>
    char *pa = kalloc();
    80001844:	fffff097          	auipc	ra,0xfffff
    80001848:	28e080e7          	jalr	654(ra) # 80000ad2 <kalloc>
    8000184c:	862a                	mv	a2,a0
    if(pa == 0)
    8000184e:	c131                	beqz	a0,80001892 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001850:	416485b3          	sub	a1,s1,s6
    80001854:	8591                	srai	a1,a1,0x4
    80001856:	000ab783          	ld	a5,0(s5)
    8000185a:	02f585b3          	mul	a1,a1,a5
    8000185e:	2585                	addiw	a1,a1,1
    80001860:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001864:	4719                	li	a4,6
    80001866:	6685                	lui	a3,0x1
    80001868:	40b905b3          	sub	a1,s2,a1
    8000186c:	854e                	mv	a0,s3
    8000186e:	00000097          	auipc	ra,0x0
    80001872:	8ae080e7          	jalr	-1874(ra) # 8000111c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001876:	19048493          	addi	s1,s1,400
    8000187a:	fd4495e3          	bne	s1,s4,80001844 <proc_mapstacks+0x38>
  }
}
    8000187e:	70e2                	ld	ra,56(sp)
    80001880:	7442                	ld	s0,48(sp)
    80001882:	74a2                	ld	s1,40(sp)
    80001884:	7902                	ld	s2,32(sp)
    80001886:	69e2                	ld	s3,24(sp)
    80001888:	6a42                	ld	s4,16(sp)
    8000188a:	6aa2                	ld	s5,8(sp)
    8000188c:	6b02                	ld	s6,0(sp)
    8000188e:	6121                	addi	sp,sp,64
    80001890:	8082                	ret
      panic("kalloc");
    80001892:	00007517          	auipc	a0,0x7
    80001896:	92e50513          	addi	a0,a0,-1746 # 800081c0 <digits+0x180>
    8000189a:	fffff097          	auipc	ra,0xfffff
    8000189e:	c90080e7          	jalr	-880(ra) # 8000052a <panic>

00000000800018a2 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018a2:	7139                	addi	sp,sp,-64
    800018a4:	fc06                	sd	ra,56(sp)
    800018a6:	f822                	sd	s0,48(sp)
    800018a8:	f426                	sd	s1,40(sp)
    800018aa:	f04a                	sd	s2,32(sp)
    800018ac:	ec4e                	sd	s3,24(sp)
    800018ae:	e852                	sd	s4,16(sp)
    800018b0:	e456                	sd	s5,8(sp)
    800018b2:	e05a                	sd	s6,0(sp)
    800018b4:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018b6:	00007597          	auipc	a1,0x7
    800018ba:	91258593          	addi	a1,a1,-1774 # 800081c8 <digits+0x188>
    800018be:	00010517          	auipc	a0,0x10
    800018c2:	9e250513          	addi	a0,a0,-1566 # 800112a0 <pid_lock>
    800018c6:	fffff097          	auipc	ra,0xfffff
    800018ca:	26c080e7          	jalr	620(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018ce:	00007597          	auipc	a1,0x7
    800018d2:	90258593          	addi	a1,a1,-1790 # 800081d0 <digits+0x190>
    800018d6:	00010517          	auipc	a0,0x10
    800018da:	9e250513          	addi	a0,a0,-1566 # 800112b8 <wait_lock>
    800018de:	fffff097          	auipc	ra,0xfffff
    800018e2:	254080e7          	jalr	596(ra) # 80000b32 <initlock>

  for(p = proc; p < &proc[NPROC]; p++) {
    800018e6:	00010497          	auipc	s1,0x10
    800018ea:	dea48493          	addi	s1,s1,-534 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    800018ee:	00007b17          	auipc	s6,0x7
    800018f2:	8f2b0b13          	addi	s6,s6,-1806 # 800081e0 <digits+0x1a0>
      p->kstack = KSTACK((int) (p - proc));
    800018f6:	8aa6                	mv	s5,s1
    800018f8:	00006a17          	auipc	s4,0x6
    800018fc:	708a0a13          	addi	s4,s4,1800 # 80008000 <etext>
    80001900:	04000937          	lui	s2,0x4000
    80001904:	197d                	addi	s2,s2,-1
    80001906:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001908:	00016997          	auipc	s3,0x16
    8000190c:	1c898993          	addi	s3,s3,456 # 80017ad0 <tickslock>
      initlock(&p->lock, "proc");
    80001910:	85da                	mv	a1,s6
    80001912:	8526                	mv	a0,s1
    80001914:	fffff097          	auipc	ra,0xfffff
    80001918:	21e080e7          	jalr	542(ra) # 80000b32 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    8000191c:	415487b3          	sub	a5,s1,s5
    80001920:	8791                	srai	a5,a5,0x4
    80001922:	000a3703          	ld	a4,0(s4)
    80001926:	02e787b3          	mul	a5,a5,a4
    8000192a:	2785                	addiw	a5,a5,1
    8000192c:	00d7979b          	slliw	a5,a5,0xd
    80001930:	40f907b3          	sub	a5,s2,a5
    80001934:	f4bc                	sd	a5,104(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001936:	19048493          	addi	s1,s1,400
    8000193a:	fd349be3          	bne	s1,s3,80001910 <procinit+0x6e>
  }
}
    8000193e:	70e2                	ld	ra,56(sp)
    80001940:	7442                	ld	s0,48(sp)
    80001942:	74a2                	ld	s1,40(sp)
    80001944:	7902                	ld	s2,32(sp)
    80001946:	69e2                	ld	s3,24(sp)
    80001948:	6a42                	ld	s4,16(sp)
    8000194a:	6aa2                	ld	s5,8(sp)
    8000194c:	6b02                	ld	s6,0(sp)
    8000194e:	6121                	addi	sp,sp,64
    80001950:	8082                	ret

0000000080001952 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001952:	1141                	addi	sp,sp,-16
    80001954:	e422                	sd	s0,8(sp)
    80001956:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001958:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000195a:	2501                	sext.w	a0,a0
    8000195c:	6422                	ld	s0,8(sp)
    8000195e:	0141                	addi	sp,sp,16
    80001960:	8082                	ret

0000000080001962 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001962:	1141                	addi	sp,sp,-16
    80001964:	e422                	sd	s0,8(sp)
    80001966:	0800                	addi	s0,sp,16
    80001968:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000196a:	2781                	sext.w	a5,a5
    8000196c:	079e                	slli	a5,a5,0x7
  return c;
}
    8000196e:	00010517          	auipc	a0,0x10
    80001972:	96250513          	addi	a0,a0,-1694 # 800112d0 <cpus>
    80001976:	953e                	add	a0,a0,a5
    80001978:	6422                	ld	s0,8(sp)
    8000197a:	0141                	addi	sp,sp,16
    8000197c:	8082                	ret

000000008000197e <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    8000197e:	1101                	addi	sp,sp,-32
    80001980:	ec06                	sd	ra,24(sp)
    80001982:	e822                	sd	s0,16(sp)
    80001984:	e426                	sd	s1,8(sp)
    80001986:	1000                	addi	s0,sp,32
  push_off();
    80001988:	fffff097          	auipc	ra,0xfffff
    8000198c:	1ee080e7          	jalr	494(ra) # 80000b76 <push_off>
    80001990:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001992:	2781                	sext.w	a5,a5
    80001994:	079e                	slli	a5,a5,0x7
    80001996:	00010717          	auipc	a4,0x10
    8000199a:	90a70713          	addi	a4,a4,-1782 # 800112a0 <pid_lock>
    8000199e:	97ba                	add	a5,a5,a4
    800019a0:	7b84                	ld	s1,48(a5)
  pop_off();
    800019a2:	fffff097          	auipc	ra,0xfffff
    800019a6:	274080e7          	jalr	628(ra) # 80000c16 <pop_off>
  return p;
}
    800019aa:	8526                	mv	a0,s1
    800019ac:	60e2                	ld	ra,24(sp)
    800019ae:	6442                	ld	s0,16(sp)
    800019b0:	64a2                	ld	s1,8(sp)
    800019b2:	6105                	addi	sp,sp,32
    800019b4:	8082                	ret

00000000800019b6 <SRT_compare>:
  printf("\t\t p1->runnable_since - p2->runnable_since %d\n",p1->runnable_since - p2->runnable_since);
  return p1->runnable_since - p2->runnable_since;
}

int
SRT_compare(struct proc *p1,struct proc *p2){
    800019b6:	1101                	addi	sp,sp,-32
    800019b8:	ec06                	sd	ra,24(sp)
    800019ba:	e822                	sd	s0,16(sp)
    800019bc:	e426                	sd	s1,8(sp)
    800019be:	e04a                	sd	s2,0(sp)
    800019c0:	1000                	addi	s0,sp,32
    800019c2:	892a                	mv	s2,a0
    800019c4:	84ae                	mv	s1,a1
  int mypid=myproc()->pid;
    800019c6:	00000097          	auipc	ra,0x0
    800019ca:	fb8080e7          	jalr	-72(ra) # 8000197e <myproc>
  printf("procces %d inside SRT comprator p2->brst=%d\n",mypid, p2->average_bursttime);
    800019ce:	44f0                	lw	a2,76(s1)
    800019d0:	590c                	lw	a1,48(a0)
    800019d2:	00007517          	auipc	a0,0x7
    800019d6:	81650513          	addi	a0,a0,-2026 # 800081e8 <digits+0x1a8>
    800019da:	fffff097          	auipc	ra,0xfffff
    800019de:	b9a080e7          	jalr	-1126(ra) # 80000574 <printf>
  // printf("\t\t p1->brst=%d \n",p1->average_bursttime);
  // printf("\t\t p1->brst - p2->v %d\n",p1->average_bursttime - p2->average_bursttime);
  return p1->average_bursttime - p2->average_bursttime;
    800019e2:	04c92503          	lw	a0,76(s2) # 400004c <_entry-0x7bffffb4>
    800019e6:	44fc                	lw	a5,76(s1)
}
    800019e8:	9d1d                	subw	a0,a0,a5
    800019ea:	60e2                	ld	ra,24(sp)
    800019ec:	6442                	ld	s0,16(sp)
    800019ee:	64a2                	ld	s1,8(sp)
    800019f0:	6902                	ld	s2,0(sp)
    800019f2:	6105                	addi	sp,sp,32
    800019f4:	8082                	ret

00000000800019f6 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019f6:	1141                	addi	sp,sp,-16
    800019f8:	e406                	sd	ra,8(sp)
    800019fa:	e022                	sd	s0,0(sp)
    800019fc:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019fe:	00000097          	auipc	ra,0x0
    80001a02:	f80080e7          	jalr	-128(ra) # 8000197e <myproc>
    80001a06:	fffff097          	auipc	ra,0xfffff
    80001a0a:	270080e7          	jalr	624(ra) # 80000c76 <release>

  if (first) {
    80001a0e:	00007797          	auipc	a5,0x7
    80001a12:	0f27a783          	lw	a5,242(a5) # 80008b00 <first.1>
    80001a16:	eb89                	bnez	a5,80001a28 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a18:	00001097          	auipc	ra,0x1
    80001a1c:	174080e7          	jalr	372(ra) # 80002b8c <usertrapret>
}
    80001a20:	60a2                	ld	ra,8(sp)
    80001a22:	6402                	ld	s0,0(sp)
    80001a24:	0141                	addi	sp,sp,16
    80001a26:	8082                	ret
    first = 0;
    80001a28:	00007797          	auipc	a5,0x7
    80001a2c:	0c07ac23          	sw	zero,216(a5) # 80008b00 <first.1>
    fsinit(ROOTDEV);
    80001a30:	4505                	li	a0,1
    80001a32:	00002097          	auipc	ra,0x2
    80001a36:	058080e7          	jalr	88(ra) # 80003a8a <fsinit>
    80001a3a:	bff9                	j	80001a18 <forkret+0x22>

0000000080001a3c <allocpid>:
allocpid() {
    80001a3c:	1101                	addi	sp,sp,-32
    80001a3e:	ec06                	sd	ra,24(sp)
    80001a40:	e822                	sd	s0,16(sp)
    80001a42:	e426                	sd	s1,8(sp)
    80001a44:	e04a                	sd	s2,0(sp)
    80001a46:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a48:	00010917          	auipc	s2,0x10
    80001a4c:	85890913          	addi	s2,s2,-1960 # 800112a0 <pid_lock>
    80001a50:	854a                	mv	a0,s2
    80001a52:	fffff097          	auipc	ra,0xfffff
    80001a56:	170080e7          	jalr	368(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001a5a:	00007797          	auipc	a5,0x7
    80001a5e:	0ae78793          	addi	a5,a5,174 # 80008b08 <nextpid>
    80001a62:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a64:	0014871b          	addiw	a4,s1,1
    80001a68:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a6a:	854a                	mv	a0,s2
    80001a6c:	fffff097          	auipc	ra,0xfffff
    80001a70:	20a080e7          	jalr	522(ra) # 80000c76 <release>
}
    80001a74:	8526                	mv	a0,s1
    80001a76:	60e2                	ld	ra,24(sp)
    80001a78:	6442                	ld	s0,16(sp)
    80001a7a:	64a2                	ld	s1,8(sp)
    80001a7c:	6902                	ld	s2,0(sp)
    80001a7e:	6105                	addi	sp,sp,32
    80001a80:	8082                	ret

0000000080001a82 <proc_pagetable>:
{
    80001a82:	1101                	addi	sp,sp,-32
    80001a84:	ec06                	sd	ra,24(sp)
    80001a86:	e822                	sd	s0,16(sp)
    80001a88:	e426                	sd	s1,8(sp)
    80001a8a:	e04a                	sd	s2,0(sp)
    80001a8c:	1000                	addi	s0,sp,32
    80001a8e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a90:	00000097          	auipc	ra,0x0
    80001a94:	876080e7          	jalr	-1930(ra) # 80001306 <uvmcreate>
    80001a98:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a9a:	c121                	beqz	a0,80001ada <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a9c:	4729                	li	a4,10
    80001a9e:	00005697          	auipc	a3,0x5
    80001aa2:	56268693          	addi	a3,a3,1378 # 80007000 <_trampoline>
    80001aa6:	6605                	lui	a2,0x1
    80001aa8:	040005b7          	lui	a1,0x4000
    80001aac:	15fd                	addi	a1,a1,-1
    80001aae:	05b2                	slli	a1,a1,0xc
    80001ab0:	fffff097          	auipc	ra,0xfffff
    80001ab4:	5de080e7          	jalr	1502(ra) # 8000108e <mappages>
    80001ab8:	02054863          	bltz	a0,80001ae8 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001abc:	4719                	li	a4,6
    80001abe:	08093683          	ld	a3,128(s2)
    80001ac2:	6605                	lui	a2,0x1
    80001ac4:	020005b7          	lui	a1,0x2000
    80001ac8:	15fd                	addi	a1,a1,-1
    80001aca:	05b6                	slli	a1,a1,0xd
    80001acc:	8526                	mv	a0,s1
    80001ace:	fffff097          	auipc	ra,0xfffff
    80001ad2:	5c0080e7          	jalr	1472(ra) # 8000108e <mappages>
    80001ad6:	02054163          	bltz	a0,80001af8 <proc_pagetable+0x76>
}
    80001ada:	8526                	mv	a0,s1
    80001adc:	60e2                	ld	ra,24(sp)
    80001ade:	6442                	ld	s0,16(sp)
    80001ae0:	64a2                	ld	s1,8(sp)
    80001ae2:	6902                	ld	s2,0(sp)
    80001ae4:	6105                	addi	sp,sp,32
    80001ae6:	8082                	ret
    uvmfree(pagetable, 0);
    80001ae8:	4581                	li	a1,0
    80001aea:	8526                	mv	a0,s1
    80001aec:	00000097          	auipc	ra,0x0
    80001af0:	a16080e7          	jalr	-1514(ra) # 80001502 <uvmfree>
    return 0;
    80001af4:	4481                	li	s1,0
    80001af6:	b7d5                	j	80001ada <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001af8:	4681                	li	a3,0
    80001afa:	4605                	li	a2,1
    80001afc:	040005b7          	lui	a1,0x4000
    80001b00:	15fd                	addi	a1,a1,-1
    80001b02:	05b2                	slli	a1,a1,0xc
    80001b04:	8526                	mv	a0,s1
    80001b06:	fffff097          	auipc	ra,0xfffff
    80001b0a:	73c080e7          	jalr	1852(ra) # 80001242 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b0e:	4581                	li	a1,0
    80001b10:	8526                	mv	a0,s1
    80001b12:	00000097          	auipc	ra,0x0
    80001b16:	9f0080e7          	jalr	-1552(ra) # 80001502 <uvmfree>
    return 0;
    80001b1a:	4481                	li	s1,0
    80001b1c:	bf7d                	j	80001ada <proc_pagetable+0x58>

0000000080001b1e <proc_freepagetable>:
{
    80001b1e:	1101                	addi	sp,sp,-32
    80001b20:	ec06                	sd	ra,24(sp)
    80001b22:	e822                	sd	s0,16(sp)
    80001b24:	e426                	sd	s1,8(sp)
    80001b26:	e04a                	sd	s2,0(sp)
    80001b28:	1000                	addi	s0,sp,32
    80001b2a:	84aa                	mv	s1,a0
    80001b2c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b2e:	4681                	li	a3,0
    80001b30:	4605                	li	a2,1
    80001b32:	040005b7          	lui	a1,0x4000
    80001b36:	15fd                	addi	a1,a1,-1
    80001b38:	05b2                	slli	a1,a1,0xc
    80001b3a:	fffff097          	auipc	ra,0xfffff
    80001b3e:	708080e7          	jalr	1800(ra) # 80001242 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b42:	4681                	li	a3,0
    80001b44:	4605                	li	a2,1
    80001b46:	020005b7          	lui	a1,0x2000
    80001b4a:	15fd                	addi	a1,a1,-1
    80001b4c:	05b6                	slli	a1,a1,0xd
    80001b4e:	8526                	mv	a0,s1
    80001b50:	fffff097          	auipc	ra,0xfffff
    80001b54:	6f2080e7          	jalr	1778(ra) # 80001242 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b58:	85ca                	mv	a1,s2
    80001b5a:	8526                	mv	a0,s1
    80001b5c:	00000097          	auipc	ra,0x0
    80001b60:	9a6080e7          	jalr	-1626(ra) # 80001502 <uvmfree>
}
    80001b64:	60e2                	ld	ra,24(sp)
    80001b66:	6442                	ld	s0,16(sp)
    80001b68:	64a2                	ld	s1,8(sp)
    80001b6a:	6902                	ld	s2,0(sp)
    80001b6c:	6105                	addi	sp,sp,32
    80001b6e:	8082                	ret

0000000080001b70 <freeproc>:
{
    80001b70:	1101                	addi	sp,sp,-32
    80001b72:	ec06                	sd	ra,24(sp)
    80001b74:	e822                	sd	s0,16(sp)
    80001b76:	e426                	sd	s1,8(sp)
    80001b78:	1000                	addi	s0,sp,32
    80001b7a:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b7c:	6148                	ld	a0,128(a0)
    80001b7e:	c509                	beqz	a0,80001b88 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b80:	fffff097          	auipc	ra,0xfffff
    80001b84:	e56080e7          	jalr	-426(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001b88:	0804b023          	sd	zero,128(s1)
  if(p->pagetable)
    80001b8c:	7ca8                	ld	a0,120(s1)
    80001b8e:	c511                	beqz	a0,80001b9a <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b90:	78ac                	ld	a1,112(s1)
    80001b92:	00000097          	auipc	ra,0x0
    80001b96:	f8c080e7          	jalr	-116(ra) # 80001b1e <proc_freepagetable>
  p->pagetable = 0;
    80001b9a:	0604bc23          	sd	zero,120(s1)
  p->sz = 0;
    80001b9e:	0604b823          	sd	zero,112(s1)
  p->pid = 0;
    80001ba2:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001ba6:	0604b023          	sd	zero,96(s1)
  p->name[0] = 0;
    80001baa:	18048023          	sb	zero,384(s1)
  p->chan = 0;
    80001bae:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bb2:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bb6:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bba:	0004ac23          	sw	zero,24(s1)
}
    80001bbe:	60e2                	ld	ra,24(sp)
    80001bc0:	6442                	ld	s0,16(sp)
    80001bc2:	64a2                	ld	s1,8(sp)
    80001bc4:	6105                	addi	sp,sp,32
    80001bc6:	8082                	ret

0000000080001bc8 <allocproc>:
{
    80001bc8:	1101                	addi	sp,sp,-32
    80001bca:	ec06                	sd	ra,24(sp)
    80001bcc:	e822                	sd	s0,16(sp)
    80001bce:	e426                	sd	s1,8(sp)
    80001bd0:	e04a                	sd	s2,0(sp)
    80001bd2:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bd4:	00010497          	auipc	s1,0x10
    80001bd8:	afc48493          	addi	s1,s1,-1284 # 800116d0 <proc>
    80001bdc:	00016917          	auipc	s2,0x16
    80001be0:	ef490913          	addi	s2,s2,-268 # 80017ad0 <tickslock>
    acquire(&p->lock);
    80001be4:	8526                	mv	a0,s1
    80001be6:	fffff097          	auipc	ra,0xfffff
    80001bea:	fdc080e7          	jalr	-36(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    80001bee:	4c9c                	lw	a5,24(s1)
    80001bf0:	cf81                	beqz	a5,80001c08 <allocproc+0x40>
      release(&p->lock);
    80001bf2:	8526                	mv	a0,s1
    80001bf4:	fffff097          	auipc	ra,0xfffff
    80001bf8:	082080e7          	jalr	130(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bfc:	19048493          	addi	s1,s1,400
    80001c00:	ff2492e3          	bne	s1,s2,80001be4 <allocproc+0x1c>
  return 0;
    80001c04:	4481                	li	s1,0
    80001c06:	a8bd                	j	80001c84 <allocproc+0xbc>
  p->pid = allocpid();
    80001c08:	00000097          	auipc	ra,0x0
    80001c0c:	e34080e7          	jalr	-460(ra) # 80001a3c <allocpid>
    80001c10:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c12:	4785                	li	a5,1
    80001c14:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	ebc080e7          	jalr	-324(ra) # 80000ad2 <kalloc>
    80001c1e:	892a                	mv	s2,a0
    80001c20:	e0c8                	sd	a0,128(s1)
    80001c22:	c925                	beqz	a0,80001c92 <allocproc+0xca>
  p->pagetable = proc_pagetable(p);
    80001c24:	8526                	mv	a0,s1
    80001c26:	00000097          	auipc	ra,0x0
    80001c2a:	e5c080e7          	jalr	-420(ra) # 80001a82 <proc_pagetable>
    80001c2e:	892a                	mv	s2,a0
    80001c30:	fca8                	sd	a0,120(s1)
  if(p->pagetable == 0){
    80001c32:	cd25                	beqz	a0,80001caa <allocproc+0xe2>
  memset(&p->context, 0, sizeof(p->context));
    80001c34:	07000613          	li	a2,112
    80001c38:	4581                	li	a1,0
    80001c3a:	08848513          	addi	a0,s1,136
    80001c3e:	fffff097          	auipc	ra,0xfffff
    80001c42:	080080e7          	jalr	128(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80001c46:	00000797          	auipc	a5,0x0
    80001c4a:	db078793          	addi	a5,a5,-592 # 800019f6 <forkret>
    80001c4e:	e4dc                	sd	a5,136(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c50:	74bc                	ld	a5,104(s1)
    80001c52:	6705                	lui	a4,0x1
    80001c54:	97ba                	add	a5,a5,a4
    80001c56:	e8dc                	sd	a5,144(s1)
  p->ctime = ticks;
    80001c58:	00007797          	auipc	a5,0x7
    80001c5c:	3d87a783          	lw	a5,984(a5) # 80009030 <ticks>
    80001c60:	dc9c                	sw	a5,56(s1)
  p->ttime = -1;
    80001c62:	57fd                	li	a5,-1
    80001c64:	dcdc                	sw	a5,60(s1)
  p->stime = 0;
    80001c66:	0404a023          	sw	zero,64(s1)
  p->retime = 0;
    80001c6a:	0404a223          	sw	zero,68(s1)
  p->rutime = 0;
    80001c6e:	0404a423          	sw	zero,72(s1)
  p->average_bursttime = QUANTUM * 100;
    80001c72:	1f400793          	li	a5,500
    80001c76:	c4fc                	sw	a5,76(s1)
  p->current_runtime = 0;
    80001c78:	0404aa23          	sw	zero,84(s1)
  p->decay_factor = 5;
    80001c7c:	4795                	li	a5,5
    80001c7e:	c8bc                	sw	a5,80(s1)
  p->runnable_since = 0;
    80001c80:	0404ac23          	sw	zero,88(s1)
}
    80001c84:	8526                	mv	a0,s1
    80001c86:	60e2                	ld	ra,24(sp)
    80001c88:	6442                	ld	s0,16(sp)
    80001c8a:	64a2                	ld	s1,8(sp)
    80001c8c:	6902                	ld	s2,0(sp)
    80001c8e:	6105                	addi	sp,sp,32
    80001c90:	8082                	ret
    freeproc(p);
    80001c92:	8526                	mv	a0,s1
    80001c94:	00000097          	auipc	ra,0x0
    80001c98:	edc080e7          	jalr	-292(ra) # 80001b70 <freeproc>
    release(&p->lock);
    80001c9c:	8526                	mv	a0,s1
    80001c9e:	fffff097          	auipc	ra,0xfffff
    80001ca2:	fd8080e7          	jalr	-40(ra) # 80000c76 <release>
    return 0;
    80001ca6:	84ca                	mv	s1,s2
    80001ca8:	bff1                	j	80001c84 <allocproc+0xbc>
    freeproc(p);
    80001caa:	8526                	mv	a0,s1
    80001cac:	00000097          	auipc	ra,0x0
    80001cb0:	ec4080e7          	jalr	-316(ra) # 80001b70 <freeproc>
    release(&p->lock);
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	fffff097          	auipc	ra,0xfffff
    80001cba:	fc0080e7          	jalr	-64(ra) # 80000c76 <release>
    return 0;
    80001cbe:	84ca                	mv	s1,s2
    80001cc0:	b7d1                	j	80001c84 <allocproc+0xbc>

0000000080001cc2 <userinit>:
{
    80001cc2:	1101                	addi	sp,sp,-32
    80001cc4:	ec06                	sd	ra,24(sp)
    80001cc6:	e822                	sd	s0,16(sp)
    80001cc8:	e426                	sd	s1,8(sp)
    80001cca:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ccc:	00000097          	auipc	ra,0x0
    80001cd0:	efc080e7          	jalr	-260(ra) # 80001bc8 <allocproc>
    80001cd4:	84aa                	mv	s1,a0
  initproc = p;
    80001cd6:	00007797          	auipc	a5,0x7
    80001cda:	34a7b923          	sd	a0,850(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cde:	03400613          	li	a2,52
    80001ce2:	00007597          	auipc	a1,0x7
    80001ce6:	e2e58593          	addi	a1,a1,-466 # 80008b10 <initcode>
    80001cea:	7d28                	ld	a0,120(a0)
    80001cec:	fffff097          	auipc	ra,0xfffff
    80001cf0:	648080e7          	jalr	1608(ra) # 80001334 <uvminit>
  p->sz = PGSIZE;
    80001cf4:	6785                	lui	a5,0x1
    80001cf6:	f8bc                	sd	a5,112(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cf8:	60d8                	ld	a4,128(s1)
    80001cfa:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cfe:	60d8                	ld	a4,128(s1)
    80001d00:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d02:	4641                	li	a2,16
    80001d04:	00006597          	auipc	a1,0x6
    80001d08:	51458593          	addi	a1,a1,1300 # 80008218 <digits+0x1d8>
    80001d0c:	18048513          	addi	a0,s1,384
    80001d10:	fffff097          	auipc	ra,0xfffff
    80001d14:	100080e7          	jalr	256(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80001d18:	00006517          	auipc	a0,0x6
    80001d1c:	51050513          	addi	a0,a0,1296 # 80008228 <digits+0x1e8>
    80001d20:	00002097          	auipc	ra,0x2
    80001d24:	798080e7          	jalr	1944(ra) # 800044b8 <namei>
    80001d28:	16a4bc23          	sd	a0,376(s1)
  p->state = RUNNABLE;
    80001d2c:	478d                	li	a5,3
    80001d2e:	cc9c                	sw	a5,24(s1)
  p->runnable_since = ticks;
    80001d30:	00007797          	auipc	a5,0x7
    80001d34:	3007a783          	lw	a5,768(a5) # 80009030 <ticks>
    80001d38:	ccbc                	sw	a5,88(s1)
  release(&p->lock);
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	f3a080e7          	jalr	-198(ra) # 80000c76 <release>
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
    80001d60:	c22080e7          	jalr	-990(ra) # 8000197e <myproc>
    80001d64:	892a                	mv	s2,a0
  sz = p->sz;
    80001d66:	792c                	ld	a1,112(a0)
    80001d68:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d6c:	00904f63          	bgtz	s1,80001d8a <growproc+0x3c>
  } else if(n < 0){
    80001d70:	0204cc63          	bltz	s1,80001da8 <growproc+0x5a>
  p->sz = sz;
    80001d74:	1602                	slli	a2,a2,0x20
    80001d76:	9201                	srli	a2,a2,0x20
    80001d78:	06c93823          	sd	a2,112(s2)
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
    80001d94:	7d28                	ld	a0,120(a0)
    80001d96:	fffff097          	auipc	ra,0xfffff
    80001d9a:	658080e7          	jalr	1624(ra) # 800013ee <uvmalloc>
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
    80001db2:	7d28                	ld	a0,120(a0)
    80001db4:	fffff097          	auipc	ra,0xfffff
    80001db8:	5f2080e7          	jalr	1522(ra) # 800013a6 <uvmdealloc>
    80001dbc:	0005061b          	sext.w	a2,a0
    80001dc0:	bf55                	j	80001d74 <growproc+0x26>

0000000080001dc2 <perfi>:
perfi(struct proc *proc, struct perf *perf){
    80001dc2:	1141                	addi	sp,sp,-16
    80001dc4:	e422                	sd	s0,8(sp)
    80001dc6:	0800                	addi	s0,sp,16
  perf->ctime = proc->ctime;
    80001dc8:	5d1c                	lw	a5,56(a0)
    80001dca:	c19c                	sw	a5,0(a1)
  perf->ttime = proc->ttime;
    80001dcc:	5d5c                	lw	a5,60(a0)
    80001dce:	c1dc                	sw	a5,4(a1)
  perf->stime = proc->stime;
    80001dd0:	413c                	lw	a5,64(a0)
    80001dd2:	c59c                	sw	a5,8(a1)
  perf->retime = proc->retime;
    80001dd4:	417c                	lw	a5,68(a0)
    80001dd6:	c5dc                	sw	a5,12(a1)
  perf->rutime = proc->rutime;
    80001dd8:	453c                	lw	a5,72(a0)
    80001dda:	c99c                	sw	a5,16(a1)
  perf->bursttime = proc->average_bursttime;
    80001ddc:	457c                	lw	a5,76(a0)
    80001dde:	c9dc                	sw	a5,20(a1)
}
    80001de0:	6422                	ld	s0,8(sp)
    80001de2:	0141                	addi	sp,sp,16
    80001de4:	8082                	ret

0000000080001de6 <fork>:
{
    80001de6:	7139                	addi	sp,sp,-64
    80001de8:	fc06                	sd	ra,56(sp)
    80001dea:	f822                	sd	s0,48(sp)
    80001dec:	f426                	sd	s1,40(sp)
    80001dee:	f04a                	sd	s2,32(sp)
    80001df0:	ec4e                	sd	s3,24(sp)
    80001df2:	e852                	sd	s4,16(sp)
    80001df4:	e456                	sd	s5,8(sp)
    80001df6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001df8:	00000097          	auipc	ra,0x0
    80001dfc:	b86080e7          	jalr	-1146(ra) # 8000197e <myproc>
    80001e00:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e02:	00000097          	auipc	ra,0x0
    80001e06:	dc6080e7          	jalr	-570(ra) # 80001bc8 <allocproc>
    80001e0a:	12050a63          	beqz	a0,80001f3e <fork+0x158>
    80001e0e:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e10:	070ab603          	ld	a2,112(s5)
    80001e14:	7d2c                	ld	a1,120(a0)
    80001e16:	078ab503          	ld	a0,120(s5)
    80001e1a:	fffff097          	auipc	ra,0xfffff
    80001e1e:	720080e7          	jalr	1824(ra) # 8000153a <uvmcopy>
    80001e22:	04054863          	bltz	a0,80001e72 <fork+0x8c>
  np->sz = p->sz;
    80001e26:	070ab783          	ld	a5,112(s5)
    80001e2a:	06f9b823          	sd	a5,112(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e2e:	080ab683          	ld	a3,128(s5)
    80001e32:	87b6                	mv	a5,a3
    80001e34:	0809b703          	ld	a4,128(s3)
    80001e38:	12068693          	addi	a3,a3,288
    80001e3c:	0007b803          	ld	a6,0(a5)
    80001e40:	6788                	ld	a0,8(a5)
    80001e42:	6b8c                	ld	a1,16(a5)
    80001e44:	6f90                	ld	a2,24(a5)
    80001e46:	01073023          	sd	a6,0(a4)
    80001e4a:	e708                	sd	a0,8(a4)
    80001e4c:	eb0c                	sd	a1,16(a4)
    80001e4e:	ef10                	sd	a2,24(a4)
    80001e50:	02078793          	addi	a5,a5,32
    80001e54:	02070713          	addi	a4,a4,32
    80001e58:	fed792e3          	bne	a5,a3,80001e3c <fork+0x56>
  np->trapframe->a0 = 0;
    80001e5c:	0809b783          	ld	a5,128(s3)
    80001e60:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e64:	0f8a8493          	addi	s1,s5,248
    80001e68:	0f898913          	addi	s2,s3,248
    80001e6c:	178a8a13          	addi	s4,s5,376
    80001e70:	a00d                	j	80001e92 <fork+0xac>
    freeproc(np);
    80001e72:	854e                	mv	a0,s3
    80001e74:	00000097          	auipc	ra,0x0
    80001e78:	cfc080e7          	jalr	-772(ra) # 80001b70 <freeproc>
    release(&np->lock);
    80001e7c:	854e                	mv	a0,s3
    80001e7e:	fffff097          	auipc	ra,0xfffff
    80001e82:	df8080e7          	jalr	-520(ra) # 80000c76 <release>
    return -1;
    80001e86:	597d                	li	s2,-1
    80001e88:	a04d                	j	80001f2a <fork+0x144>
  for(i = 0; i < NOFILE; i++)
    80001e8a:	04a1                	addi	s1,s1,8
    80001e8c:	0921                	addi	s2,s2,8
    80001e8e:	01448b63          	beq	s1,s4,80001ea4 <fork+0xbe>
    if(p->ofile[i])
    80001e92:	6088                	ld	a0,0(s1)
    80001e94:	d97d                	beqz	a0,80001e8a <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e96:	00003097          	auipc	ra,0x3
    80001e9a:	cbc080e7          	jalr	-836(ra) # 80004b52 <filedup>
    80001e9e:	00a93023          	sd	a0,0(s2)
    80001ea2:	b7e5                	j	80001e8a <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001ea4:	178ab503          	ld	a0,376(s5)
    80001ea8:	00002097          	auipc	ra,0x2
    80001eac:	e1c080e7          	jalr	-484(ra) # 80003cc4 <idup>
    80001eb0:	16a9bc23          	sd	a0,376(s3)
  np->tracemask = p->tracemask;
    80001eb4:	034aa783          	lw	a5,52(s5)
    80001eb8:	02f9aa23          	sw	a5,52(s3)
  np->decay_factor = p->decay_factor;
    80001ebc:	050aa783          	lw	a5,80(s5)
    80001ec0:	04f9a823          	sw	a5,80(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ec4:	4641                	li	a2,16
    80001ec6:	180a8593          	addi	a1,s5,384
    80001eca:	18098513          	addi	a0,s3,384
    80001ece:	fffff097          	auipc	ra,0xfffff
    80001ed2:	f42080e7          	jalr	-190(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80001ed6:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001eda:	854e                	mv	a0,s3
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	d9a080e7          	jalr	-614(ra) # 80000c76 <release>
  acquire(&wait_lock);
    80001ee4:	0000f497          	auipc	s1,0xf
    80001ee8:	3d448493          	addi	s1,s1,980 # 800112b8 <wait_lock>
    80001eec:	8526                	mv	a0,s1
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	cd4080e7          	jalr	-812(ra) # 80000bc2 <acquire>
  np->parent = p;
    80001ef6:	0759b023          	sd	s5,96(s3)
  release(&wait_lock);
    80001efa:	8526                	mv	a0,s1
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	d7a080e7          	jalr	-646(ra) # 80000c76 <release>
  acquire(&np->lock);
    80001f04:	854e                	mv	a0,s3
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	cbc080e7          	jalr	-836(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80001f0e:	478d                	li	a5,3
    80001f10:	00f9ac23          	sw	a5,24(s3)
  np->runnable_since = ticks;
    80001f14:	00007797          	auipc	a5,0x7
    80001f18:	11c7a783          	lw	a5,284(a5) # 80009030 <ticks>
    80001f1c:	04f9ac23          	sw	a5,88(s3)
  release(&np->lock);
    80001f20:	854e                	mv	a0,s3
    80001f22:	fffff097          	auipc	ra,0xfffff
    80001f26:	d54080e7          	jalr	-684(ra) # 80000c76 <release>
}
    80001f2a:	854a                	mv	a0,s2
    80001f2c:	70e2                	ld	ra,56(sp)
    80001f2e:	7442                	ld	s0,48(sp)
    80001f30:	74a2                	ld	s1,40(sp)
    80001f32:	7902                	ld	s2,32(sp)
    80001f34:	69e2                	ld	s3,24(sp)
    80001f36:	6a42                	ld	s4,16(sp)
    80001f38:	6aa2                	ld	s5,8(sp)
    80001f3a:	6121                	addi	sp,sp,64
    80001f3c:	8082                	ret
    return -1;
    80001f3e:	597d                	li	s2,-1
    80001f40:	b7ed                	j	80001f2a <fork+0x144>

0000000080001f42 <FCFS_compare>:
FCFS_compare(struct proc *p1,struct proc *p2){
    80001f42:	1101                	addi	sp,sp,-32
    80001f44:	ec06                	sd	ra,24(sp)
    80001f46:	e822                	sd	s0,16(sp)
    80001f48:	e426                	sd	s1,8(sp)
    80001f4a:	e04a                	sd	s2,0(sp)
    80001f4c:	1000                	addi	s0,sp,32
    80001f4e:	892a                	mv	s2,a0
    80001f50:	84ae                	mv	s1,a1
  printf("inside FCFS comprator p2->runsince=%d\n",p2->runnable_since);
    80001f52:	4dac                	lw	a1,88(a1)
    80001f54:	00006517          	auipc	a0,0x6
    80001f58:	2dc50513          	addi	a0,a0,732 # 80008230 <digits+0x1f0>
    80001f5c:	ffffe097          	auipc	ra,0xffffe
    80001f60:	618080e7          	jalr	1560(ra) # 80000574 <printf>
  printf("\t\t p1->runsince=%d \n",p1->runnable_since);
    80001f64:	05892583          	lw	a1,88(s2)
    80001f68:	00006517          	auipc	a0,0x6
    80001f6c:	2f050513          	addi	a0,a0,752 # 80008258 <digits+0x218>
    80001f70:	ffffe097          	auipc	ra,0xffffe
    80001f74:	604080e7          	jalr	1540(ra) # 80000574 <printf>
  printf("\t\t p1->runnable_since - p2->runnable_since %d\n",p1->runnable_since - p2->runnable_since);
    80001f78:	05892583          	lw	a1,88(s2)
    80001f7c:	4cbc                	lw	a5,88(s1)
    80001f7e:	9d9d                	subw	a1,a1,a5
    80001f80:	00006517          	auipc	a0,0x6
    80001f84:	2f050513          	addi	a0,a0,752 # 80008270 <digits+0x230>
    80001f88:	ffffe097          	auipc	ra,0xffffe
    80001f8c:	5ec080e7          	jalr	1516(ra) # 80000574 <printf>
  return p1->runnable_since - p2->runnable_since;
    80001f90:	05892503          	lw	a0,88(s2)
    80001f94:	4cbc                	lw	a5,88(s1)
}
    80001f96:	9d1d                	subw	a0,a0,a5
    80001f98:	60e2                	ld	ra,24(sp)
    80001f9a:	6442                	ld	s0,16(sp)
    80001f9c:	64a2                	ld	s1,8(sp)
    80001f9e:	6902                	ld	s2,0(sp)
    80001fa0:	6105                	addi	sp,sp,32
    80001fa2:	8082                	ret

0000000080001fa4 <SFSD_compare>:
SFSD_compare(struct proc *p1,struct proc *p2){
    80001fa4:	1141                	addi	sp,sp,-16
    80001fa6:	e422                	sd	s0,8(sp)
    80001fa8:	0800                	addi	s0,sp,16
  int p1_priority=(p1->rutime*p1->decay_factor)/(p1->rutime+p1->stime);
    80001faa:	453c                	lw	a5,72(a0)
  int p2_priority=(p2->rutime*p2->decay_factor)/(p2->rutime+p2->stime);
    80001fac:	45b4                	lw	a3,72(a1)
  int p1_priority=(p1->rutime*p1->decay_factor)/(p1->rutime+p1->stime);
    80001fae:	4938                	lw	a4,80(a0)
    80001fb0:	02f7073b          	mulw	a4,a4,a5
    80001fb4:	4128                	lw	a0,64(a0)
    80001fb6:	9d3d                	addw	a0,a0,a5
    80001fb8:	02a7453b          	divw	a0,a4,a0
  int p2_priority=(p2->rutime*p2->decay_factor)/(p2->rutime+p2->stime);
    80001fbc:	49bc                	lw	a5,80(a1)
    80001fbe:	02d787bb          	mulw	a5,a5,a3
    80001fc2:	41b8                	lw	a4,64(a1)
    80001fc4:	9f35                	addw	a4,a4,a3
    80001fc6:	02e7c7bb          	divw	a5,a5,a4
}
    80001fca:	9d1d                	subw	a0,a0,a5
    80001fcc:	6422                	ld	s0,8(sp)
    80001fce:	0141                	addi	sp,sp,16
    80001fd0:	8082                	ret

0000000080001fd2 <default_policy>:
default_policy(){
    80001fd2:	7139                	addi	sp,sp,-64
    80001fd4:	fc06                	sd	ra,56(sp)
    80001fd6:	f822                	sd	s0,48(sp)
    80001fd8:	f426                	sd	s1,40(sp)
    80001fda:	f04a                	sd	s2,32(sp)
    80001fdc:	ec4e                	sd	s3,24(sp)
    80001fde:	e852                	sd	s4,16(sp)
    80001fe0:	e456                	sd	s5,8(sp)
    80001fe2:	e05a                	sd	s6,0(sp)
    80001fe4:	0080                	addi	s0,sp,64
    80001fe6:	8792                	mv	a5,tp
  int id = r_tp();
    80001fe8:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fea:	00779a93          	slli	s5,a5,0x7
    80001fee:	0000f717          	auipc	a4,0xf
    80001ff2:	2b270713          	addi	a4,a4,690 # 800112a0 <pid_lock>
    80001ff6:	9756                	add	a4,a4,s5
    80001ff8:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ffc:	0000f717          	auipc	a4,0xf
    80002000:	2dc70713          	addi	a4,a4,732 # 800112d8 <cpus+0x8>
    80002004:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80002006:	498d                	li	s3,3
        p->state = RUNNING;
    80002008:	4b11                	li	s6,4
        c->proc = p;
    8000200a:	079e                	slli	a5,a5,0x7
    8000200c:	0000fa17          	auipc	s4,0xf
    80002010:	294a0a13          	addi	s4,s4,660 # 800112a0 <pid_lock>
    80002014:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002016:	00016917          	auipc	s2,0x16
    8000201a:	aba90913          	addi	s2,s2,-1350 # 80017ad0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000201e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002022:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002026:	10079073          	csrw	sstatus,a5
    8000202a:	0000f497          	auipc	s1,0xf
    8000202e:	6a648493          	addi	s1,s1,1702 # 800116d0 <proc>
    80002032:	a811                	j	80002046 <default_policy+0x74>
      release(&p->lock);
    80002034:	8526                	mv	a0,s1
    80002036:	fffff097          	auipc	ra,0xfffff
    8000203a:	c40080e7          	jalr	-960(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000203e:	19048493          	addi	s1,s1,400
    80002042:	fd248ee3          	beq	s1,s2,8000201e <default_policy+0x4c>
      acquire(&p->lock);
    80002046:	8526                	mv	a0,s1
    80002048:	fffff097          	auipc	ra,0xfffff
    8000204c:	b7a080e7          	jalr	-1158(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE) {
    80002050:	4c9c                	lw	a5,24(s1)
    80002052:	ff3791e3          	bne	a5,s3,80002034 <default_policy+0x62>
        p->state = RUNNING;
    80002056:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    8000205a:	029a3823          	sd	s1,48(s4)
        p->current_runtime = 0;
    8000205e:	0404aa23          	sw	zero,84(s1)
        swtch(&c->context, &p->context);
    80002062:	08848593          	addi	a1,s1,136
    80002066:	8556                	mv	a0,s5
    80002068:	00001097          	auipc	ra,0x1
    8000206c:	a7a080e7          	jalr	-1414(ra) # 80002ae2 <swtch>
        c->proc = 0;
    80002070:	020a3823          	sd	zero,48(s4)
    80002074:	b7c1                	j	80002034 <default_policy+0x62>

0000000080002076 <comperative_policy>:
comperative_policy(int (*compare)(struct proc *p1, struct proc *p2)){
    80002076:	7159                	addi	sp,sp,-112
    80002078:	f486                	sd	ra,104(sp)
    8000207a:	f0a2                	sd	s0,96(sp)
    8000207c:	eca6                	sd	s1,88(sp)
    8000207e:	e8ca                	sd	s2,80(sp)
    80002080:	e4ce                	sd	s3,72(sp)
    80002082:	e0d2                	sd	s4,64(sp)
    80002084:	fc56                	sd	s5,56(sp)
    80002086:	f85a                	sd	s6,48(sp)
    80002088:	f45e                	sd	s7,40(sp)
    8000208a:	f062                	sd	s8,32(sp)
    8000208c:	ec66                	sd	s9,24(sp)
    8000208e:	e86a                	sd	s10,16(sp)
    80002090:	e46e                	sd	s11,8(sp)
    80002092:	1880                	addi	s0,sp,112
    80002094:	8baa                	mv	s7,a0
  asm volatile("mv %0, tp" : "=r" (x) );
    80002096:	8492                	mv	s1,tp
  int id = r_tp();
    80002098:	2481                	sext.w	s1,s1
  c->proc = 0;
    8000209a:	00749d13          	slli	s10,s1,0x7
    8000209e:	0000f797          	auipc	a5,0xf
    800020a2:	20278793          	addi	a5,a5,514 # 800112a0 <pid_lock>
    800020a6:	97ea                	add	a5,a5,s10
    800020a8:	0207b823          	sd	zero,48(a5)
  int mypid=myproc()->pid;//TODO delete
    800020ac:	00000097          	auipc	ra,0x0
    800020b0:	8d2080e7          	jalr	-1838(ra) # 8000197e <myproc>
    800020b4:	03052a83          	lw	s5,48(a0)
      swtch(&c->context, &next_p->context);
    800020b8:	0000f797          	auipc	a5,0xf
    800020bc:	22078793          	addi	a5,a5,544 # 800112d8 <cpus+0x8>
    800020c0:	9d3e                	add	s10,s10,a5
  struct proc *next_p = 0;
    800020c2:	4901                	li	s2,0
      if(p->state == RUNNABLE) {
    800020c4:	498d                	li	s3,3
        printf("process %d calling compare func next_p=%d\n",mypid, next_p);
    800020c6:	00006b17          	auipc	s6,0x6
    800020ca:	1dab0b13          	addi	s6,s6,474 # 800082a0 <digits+0x260>
            printf("process %d after compare call\n",mypid);
    800020ce:	00006c17          	auipc	s8,0x6
    800020d2:	202c0c13          	addi	s8,s8,514 # 800082d0 <digits+0x290>
    for(p = proc; p < &proc[NPROC]; p++) {
    800020d6:	00016a17          	auipc	s4,0x16
    800020da:	9faa0a13          	addi	s4,s4,-1542 # 80017ad0 <tickslock>
      c->proc = next_p;
    800020de:	049e                	slli	s1,s1,0x7
    800020e0:	0000fc97          	auipc	s9,0xf
    800020e4:	1c0c8c93          	addi	s9,s9,448 # 800112a0 <pid_lock>
    800020e8:	9ca6                	add	s9,s9,s1
      next_p->runnable_since=ticks+1;
    800020ea:	00007d97          	auipc	s11,0x7
    800020ee:	f46d8d93          	addi	s11,s11,-186 # 80009030 <ticks>
    800020f2:	a869                	j	8000218c <comperative_policy+0x116>
        printf("process %d calling compare func next_p=%d\n",mypid, next_p);
    800020f4:	864a                	mv	a2,s2
    800020f6:	85d6                	mv	a1,s5
    800020f8:	855a                	mv	a0,s6
    800020fa:	ffffe097          	auipc	ra,0xffffe
    800020fe:	47a080e7          	jalr	1146(ra) # 80000574 <printf>
        if(next_p == 0 || compare(next_p, p) > 0){
    80002102:	02090263          	beqz	s2,80002126 <comperative_policy+0xb0>
    80002106:	85a6                	mv	a1,s1
    80002108:	854a                	mv	a0,s2
    8000210a:	9b82                	jalr	s7
    8000210c:	02a05a63          	blez	a0,80002140 <comperative_policy+0xca>
            printf("process %d after compare call\n",mypid);
    80002110:	85d6                	mv	a1,s5
    80002112:	8562                	mv	a0,s8
    80002114:	ffffe097          	auipc	ra,0xffffe
    80002118:	460080e7          	jalr	1120(ra) # 80000574 <printf>
            release(&next_p->lock);
    8000211c:	854a                	mv	a0,s2
    8000211e:	fffff097          	auipc	ra,0xfffff
    80002122:	b58080e7          	jalr	-1192(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002126:	8926                	mv	s2,s1
    80002128:	19048493          	addi	s1,s1,400
    8000212c:	03448263          	beq	s1,s4,80002150 <comperative_policy+0xda>
      acquire(&p->lock);
    80002130:	8526                	mv	a0,s1
    80002132:	fffff097          	auipc	ra,0xfffff
    80002136:	a90080e7          	jalr	-1392(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE) {
    8000213a:	4c9c                	lw	a5,24(s1)
    8000213c:	fb378ce3          	beq	a5,s3,800020f4 <comperative_policy+0x7e>
      if(p != next_p){
    80002140:	fe9904e3          	beq	s2,s1,80002128 <comperative_policy+0xb2>
        release(&p->lock);
    80002144:	8526                	mv	a0,s1
    80002146:	fffff097          	auipc	ra,0xfffff
    8000214a:	b30080e7          	jalr	-1232(ra) # 80000c76 <release>
    8000214e:	bfe9                	j	80002128 <comperative_policy+0xb2>
    if(next_p->state == RUNNABLE){
    80002150:	01892783          	lw	a5,24(s2)
    80002154:	03379763          	bne	a5,s3,80002182 <comperative_policy+0x10c>
      next_p->state = RUNNING;
    80002158:	4791                	li	a5,4
    8000215a:	00f92c23          	sw	a5,24(s2)
      c->proc = next_p;
    8000215e:	032cb823          	sd	s2,48(s9)
      next_p->current_runtime = 0;
    80002162:	04092a23          	sw	zero,84(s2)
      swtch(&c->context, &next_p->context);
    80002166:	08890593          	addi	a1,s2,136
    8000216a:	856a                	mv	a0,s10
    8000216c:	00001097          	auipc	ra,0x1
    80002170:	976080e7          	jalr	-1674(ra) # 80002ae2 <swtch>
      c->proc=0;
    80002174:	020cb823          	sd	zero,48(s9)
      next_p->runnable_since=ticks+1;
    80002178:	000da783          	lw	a5,0(s11)
    8000217c:	2785                	addiw	a5,a5,1
    8000217e:	04f92c23          	sw	a5,88(s2)
    release(&next_p->lock);
    80002182:	854a                	mv	a0,s2
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	af2080e7          	jalr	-1294(ra) # 80000c76 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000218c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002190:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002194:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002198:	0000f497          	auipc	s1,0xf
    8000219c:	53848493          	addi	s1,s1,1336 # 800116d0 <proc>
    800021a0:	bf41                	j	80002130 <comperative_policy+0xba>

00000000800021a2 <scheduler>:
{
    800021a2:	1141                	addi	sp,sp,-16
    800021a4:	e406                	sd	ra,8(sp)
    800021a6:	e022                	sd	s0,0(sp)
    800021a8:	0800                	addi	s0,sp,16
    printf("SRT schedueling policy active\n");
    800021aa:	00006517          	auipc	a0,0x6
    800021ae:	14650513          	addi	a0,a0,326 # 800082f0 <digits+0x2b0>
    800021b2:	ffffe097          	auipc	ra,0xffffe
    800021b6:	3c2080e7          	jalr	962(ra) # 80000574 <printf>
    comperative_policy(&SRT_compare);
    800021ba:	fffff517          	auipc	a0,0xfffff
    800021be:	7fc50513          	addi	a0,a0,2044 # 800019b6 <SRT_compare>
    800021c2:	00000097          	auipc	ra,0x0
    800021c6:	eb4080e7          	jalr	-332(ra) # 80002076 <comperative_policy>

00000000800021ca <sched>:
{
    800021ca:	7179                	addi	sp,sp,-48
    800021cc:	f406                	sd	ra,40(sp)
    800021ce:	f022                	sd	s0,32(sp)
    800021d0:	ec26                	sd	s1,24(sp)
    800021d2:	e84a                	sd	s2,16(sp)
    800021d4:	e44e                	sd	s3,8(sp)
    800021d6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800021d8:	fffff097          	auipc	ra,0xfffff
    800021dc:	7a6080e7          	jalr	1958(ra) # 8000197e <myproc>
    800021e0:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800021e2:	fffff097          	auipc	ra,0xfffff
    800021e6:	966080e7          	jalr	-1690(ra) # 80000b48 <holding>
    800021ea:	c941                	beqz	a0,8000227a <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021ec:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800021ee:	2781                	sext.w	a5,a5
    800021f0:	079e                	slli	a5,a5,0x7
    800021f2:	0000f717          	auipc	a4,0xf
    800021f6:	0ae70713          	addi	a4,a4,174 # 800112a0 <pid_lock>
    800021fa:	97ba                	add	a5,a5,a4
    800021fc:	0a87a703          	lw	a4,168(a5)
    80002200:	4785                	li	a5,1
    80002202:	08f71463          	bne	a4,a5,8000228a <sched+0xc0>
  if(p->state == RUNNING)
    80002206:	4c98                	lw	a4,24(s1)
    80002208:	4791                	li	a5,4
    8000220a:	08f70863          	beq	a4,a5,8000229a <sched+0xd0>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000220e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002212:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002214:	ebd9                	bnez	a5,800022aa <sched+0xe0>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002216:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002218:	0000f917          	auipc	s2,0xf
    8000221c:	08890913          	addi	s2,s2,136 # 800112a0 <pid_lock>
    80002220:	2781                	sext.w	a5,a5
    80002222:	079e                	slli	a5,a5,0x7
    80002224:	97ca                	add	a5,a5,s2
    80002226:	0ac7a983          	lw	s3,172(a5)
  p->average_bursttime =  ALPHA * p->current_runtime + ((100-ALPHA) * p->average_bursttime) / 100;
    8000222a:	48f8                	lw	a4,84(s1)
    8000222c:	03200793          	li	a5,50
    80002230:	02e787bb          	mulw	a5,a5,a4
    80002234:	44f4                	lw	a3,76(s1)
    80002236:	01f6d71b          	srliw	a4,a3,0x1f
    8000223a:	9f35                	addw	a4,a4,a3
    8000223c:	4017571b          	sraiw	a4,a4,0x1
    80002240:	9fb9                	addw	a5,a5,a4
    80002242:	c4fc                	sw	a5,76(s1)
    80002244:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002246:	2781                	sext.w	a5,a5
    80002248:	079e                	slli	a5,a5,0x7
    8000224a:	0000f597          	auipc	a1,0xf
    8000224e:	08e58593          	addi	a1,a1,142 # 800112d8 <cpus+0x8>
    80002252:	95be                	add	a1,a1,a5
    80002254:	08848513          	addi	a0,s1,136
    80002258:	00001097          	auipc	ra,0x1
    8000225c:	88a080e7          	jalr	-1910(ra) # 80002ae2 <swtch>
    80002260:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002262:	2781                	sext.w	a5,a5
    80002264:	079e                	slli	a5,a5,0x7
    80002266:	97ca                	add	a5,a5,s2
    80002268:	0b37a623          	sw	s3,172(a5)
}
    8000226c:	70a2                	ld	ra,40(sp)
    8000226e:	7402                	ld	s0,32(sp)
    80002270:	64e2                	ld	s1,24(sp)
    80002272:	6942                	ld	s2,16(sp)
    80002274:	69a2                	ld	s3,8(sp)
    80002276:	6145                	addi	sp,sp,48
    80002278:	8082                	ret
    panic("sched p->lock");
    8000227a:	00006517          	auipc	a0,0x6
    8000227e:	09650513          	addi	a0,a0,150 # 80008310 <digits+0x2d0>
    80002282:	ffffe097          	auipc	ra,0xffffe
    80002286:	2a8080e7          	jalr	680(ra) # 8000052a <panic>
    panic("sched locks");
    8000228a:	00006517          	auipc	a0,0x6
    8000228e:	09650513          	addi	a0,a0,150 # 80008320 <digits+0x2e0>
    80002292:	ffffe097          	auipc	ra,0xffffe
    80002296:	298080e7          	jalr	664(ra) # 8000052a <panic>
    panic("sched running");
    8000229a:	00006517          	auipc	a0,0x6
    8000229e:	09650513          	addi	a0,a0,150 # 80008330 <digits+0x2f0>
    800022a2:	ffffe097          	auipc	ra,0xffffe
    800022a6:	288080e7          	jalr	648(ra) # 8000052a <panic>
    panic("sched interruptible");
    800022aa:	00006517          	auipc	a0,0x6
    800022ae:	09650513          	addi	a0,a0,150 # 80008340 <digits+0x300>
    800022b2:	ffffe097          	auipc	ra,0xffffe
    800022b6:	278080e7          	jalr	632(ra) # 8000052a <panic>

00000000800022ba <yield>:
{
    800022ba:	1101                	addi	sp,sp,-32
    800022bc:	ec06                	sd	ra,24(sp)
    800022be:	e822                	sd	s0,16(sp)
    800022c0:	e426                	sd	s1,8(sp)
    800022c2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800022c4:	fffff097          	auipc	ra,0xfffff
    800022c8:	6ba080e7          	jalr	1722(ra) # 8000197e <myproc>
    800022cc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022ce:	fffff097          	auipc	ra,0xfffff
    800022d2:	8f4080e7          	jalr	-1804(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    800022d6:	478d                	li	a5,3
    800022d8:	cc9c                	sw	a5,24(s1)
  p->runnable_since=ticks;
    800022da:	00007797          	auipc	a5,0x7
    800022de:	d567a783          	lw	a5,-682(a5) # 80009030 <ticks>
    800022e2:	ccbc                	sw	a5,88(s1)
  sched();
    800022e4:	00000097          	auipc	ra,0x0
    800022e8:	ee6080e7          	jalr	-282(ra) # 800021ca <sched>
  release(&p->lock);
    800022ec:	8526                	mv	a0,s1
    800022ee:	fffff097          	auipc	ra,0xfffff
    800022f2:	988080e7          	jalr	-1656(ra) # 80000c76 <release>
}
    800022f6:	60e2                	ld	ra,24(sp)
    800022f8:	6442                	ld	s0,16(sp)
    800022fa:	64a2                	ld	s1,8(sp)
    800022fc:	6105                	addi	sp,sp,32
    800022fe:	8082                	ret

0000000080002300 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002300:	7179                	addi	sp,sp,-48
    80002302:	f406                	sd	ra,40(sp)
    80002304:	f022                	sd	s0,32(sp)
    80002306:	ec26                	sd	s1,24(sp)
    80002308:	e84a                	sd	s2,16(sp)
    8000230a:	e44e                	sd	s3,8(sp)
    8000230c:	1800                	addi	s0,sp,48
    8000230e:	89aa                	mv	s3,a0
    80002310:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	66c080e7          	jalr	1644(ra) # 8000197e <myproc>
    8000231a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000231c:	fffff097          	auipc	ra,0xfffff
    80002320:	8a6080e7          	jalr	-1882(ra) # 80000bc2 <acquire>
  release(lk);
    80002324:	854a                	mv	a0,s2
    80002326:	fffff097          	auipc	ra,0xfffff
    8000232a:	950080e7          	jalr	-1712(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    8000232e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002332:	4789                	li	a5,2
    80002334:	cc9c                	sw	a5,24(s1)

  sched();
    80002336:	00000097          	auipc	ra,0x0
    8000233a:	e94080e7          	jalr	-364(ra) # 800021ca <sched>

  // Tidy up.
  p->chan = 0;
    8000233e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002342:	8526                	mv	a0,s1
    80002344:	fffff097          	auipc	ra,0xfffff
    80002348:	932080e7          	jalr	-1742(ra) # 80000c76 <release>
  acquire(lk);
    8000234c:	854a                	mv	a0,s2
    8000234e:	fffff097          	auipc	ra,0xfffff
    80002352:	874080e7          	jalr	-1932(ra) # 80000bc2 <acquire>
}
    80002356:	70a2                	ld	ra,40(sp)
    80002358:	7402                	ld	s0,32(sp)
    8000235a:	64e2                	ld	s1,24(sp)
    8000235c:	6942                	ld	s2,16(sp)
    8000235e:	69a2                	ld	s3,8(sp)
    80002360:	6145                	addi	sp,sp,48
    80002362:	8082                	ret

0000000080002364 <wait>:
{
    80002364:	715d                	addi	sp,sp,-80
    80002366:	e486                	sd	ra,72(sp)
    80002368:	e0a2                	sd	s0,64(sp)
    8000236a:	fc26                	sd	s1,56(sp)
    8000236c:	f84a                	sd	s2,48(sp)
    8000236e:	f44e                	sd	s3,40(sp)
    80002370:	f052                	sd	s4,32(sp)
    80002372:	ec56                	sd	s5,24(sp)
    80002374:	e85a                	sd	s6,16(sp)
    80002376:	e45e                	sd	s7,8(sp)
    80002378:	e062                	sd	s8,0(sp)
    8000237a:	0880                	addi	s0,sp,80
    8000237c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000237e:	fffff097          	auipc	ra,0xfffff
    80002382:	600080e7          	jalr	1536(ra) # 8000197e <myproc>
    80002386:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002388:	0000f517          	auipc	a0,0xf
    8000238c:	f3050513          	addi	a0,a0,-208 # 800112b8 <wait_lock>
    80002390:	fffff097          	auipc	ra,0xfffff
    80002394:	832080e7          	jalr	-1998(ra) # 80000bc2 <acquire>
    havekids = 0;
    80002398:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000239a:	4a15                	li	s4,5
        havekids = 1;
    8000239c:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000239e:	00015997          	auipc	s3,0x15
    800023a2:	73298993          	addi	s3,s3,1842 # 80017ad0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023a6:	0000fc17          	auipc	s8,0xf
    800023aa:	f12c0c13          	addi	s8,s8,-238 # 800112b8 <wait_lock>
    havekids = 0;
    800023ae:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800023b0:	0000f497          	auipc	s1,0xf
    800023b4:	32048493          	addi	s1,s1,800 # 800116d0 <proc>
    800023b8:	a0bd                	j	80002426 <wait+0xc2>
          pid = np->pid;
    800023ba:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800023be:	000b0e63          	beqz	s6,800023da <wait+0x76>
    800023c2:	4691                	li	a3,4
    800023c4:	02c48613          	addi	a2,s1,44
    800023c8:	85da                	mv	a1,s6
    800023ca:	07893503          	ld	a0,120(s2)
    800023ce:	fffff097          	auipc	ra,0xfffff
    800023d2:	270080e7          	jalr	624(ra) # 8000163e <copyout>
    800023d6:	02054563          	bltz	a0,80002400 <wait+0x9c>
          freeproc(np);
    800023da:	8526                	mv	a0,s1
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	794080e7          	jalr	1940(ra) # 80001b70 <freeproc>
          release(&np->lock);
    800023e4:	8526                	mv	a0,s1
    800023e6:	fffff097          	auipc	ra,0xfffff
    800023ea:	890080e7          	jalr	-1904(ra) # 80000c76 <release>
          release(&wait_lock);
    800023ee:	0000f517          	auipc	a0,0xf
    800023f2:	eca50513          	addi	a0,a0,-310 # 800112b8 <wait_lock>
    800023f6:	fffff097          	auipc	ra,0xfffff
    800023fa:	880080e7          	jalr	-1920(ra) # 80000c76 <release>
          return pid;
    800023fe:	a09d                	j	80002464 <wait+0x100>
            release(&np->lock);
    80002400:	8526                	mv	a0,s1
    80002402:	fffff097          	auipc	ra,0xfffff
    80002406:	874080e7          	jalr	-1932(ra) # 80000c76 <release>
            release(&wait_lock);
    8000240a:	0000f517          	auipc	a0,0xf
    8000240e:	eae50513          	addi	a0,a0,-338 # 800112b8 <wait_lock>
    80002412:	fffff097          	auipc	ra,0xfffff
    80002416:	864080e7          	jalr	-1948(ra) # 80000c76 <release>
            return -1;
    8000241a:	59fd                	li	s3,-1
    8000241c:	a0a1                	j	80002464 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    8000241e:	19048493          	addi	s1,s1,400
    80002422:	03348463          	beq	s1,s3,8000244a <wait+0xe6>
      if(np->parent == p){
    80002426:	70bc                	ld	a5,96(s1)
    80002428:	ff279be3          	bne	a5,s2,8000241e <wait+0xba>
        acquire(&np->lock);
    8000242c:	8526                	mv	a0,s1
    8000242e:	ffffe097          	auipc	ra,0xffffe
    80002432:	794080e7          	jalr	1940(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    80002436:	4c9c                	lw	a5,24(s1)
    80002438:	f94781e3          	beq	a5,s4,800023ba <wait+0x56>
        release(&np->lock);
    8000243c:	8526                	mv	a0,s1
    8000243e:	fffff097          	auipc	ra,0xfffff
    80002442:	838080e7          	jalr	-1992(ra) # 80000c76 <release>
        havekids = 1;
    80002446:	8756                	mv	a4,s5
    80002448:	bfd9                	j	8000241e <wait+0xba>
    if(!havekids || p->killed){
    8000244a:	c701                	beqz	a4,80002452 <wait+0xee>
    8000244c:	02892783          	lw	a5,40(s2)
    80002450:	c79d                	beqz	a5,8000247e <wait+0x11a>
      release(&wait_lock);
    80002452:	0000f517          	auipc	a0,0xf
    80002456:	e6650513          	addi	a0,a0,-410 # 800112b8 <wait_lock>
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	81c080e7          	jalr	-2020(ra) # 80000c76 <release>
      return -1;
    80002462:	59fd                	li	s3,-1
}
    80002464:	854e                	mv	a0,s3
    80002466:	60a6                	ld	ra,72(sp)
    80002468:	6406                	ld	s0,64(sp)
    8000246a:	74e2                	ld	s1,56(sp)
    8000246c:	7942                	ld	s2,48(sp)
    8000246e:	79a2                	ld	s3,40(sp)
    80002470:	7a02                	ld	s4,32(sp)
    80002472:	6ae2                	ld	s5,24(sp)
    80002474:	6b42                	ld	s6,16(sp)
    80002476:	6ba2                	ld	s7,8(sp)
    80002478:	6c02                	ld	s8,0(sp)
    8000247a:	6161                	addi	sp,sp,80
    8000247c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000247e:	85e2                	mv	a1,s8
    80002480:	854a                	mv	a0,s2
    80002482:	00000097          	auipc	ra,0x0
    80002486:	e7e080e7          	jalr	-386(ra) # 80002300 <sleep>
    havekids = 0;
    8000248a:	b715                	j	800023ae <wait+0x4a>

000000008000248c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000248c:	7139                	addi	sp,sp,-64
    8000248e:	fc06                	sd	ra,56(sp)
    80002490:	f822                	sd	s0,48(sp)
    80002492:	f426                	sd	s1,40(sp)
    80002494:	f04a                	sd	s2,32(sp)
    80002496:	ec4e                	sd	s3,24(sp)
    80002498:	e852                	sd	s4,16(sp)
    8000249a:	e456                	sd	s5,8(sp)
    8000249c:	e05a                	sd	s6,0(sp)
    8000249e:	0080                	addi	s0,sp,64
    800024a0:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800024a2:	0000f497          	auipc	s1,0xf
    800024a6:	22e48493          	addi	s1,s1,558 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800024aa:	4989                	li	s3,2
        p->state = RUNNABLE;
    800024ac:	4b0d                	li	s6,3
        p->runnable_since = ticks;
    800024ae:	00007a97          	auipc	s5,0x7
    800024b2:	b82a8a93          	addi	s5,s5,-1150 # 80009030 <ticks>
  for(p = proc; p < &proc[NPROC]; p++) {
    800024b6:	00015917          	auipc	s2,0x15
    800024ba:	61a90913          	addi	s2,s2,1562 # 80017ad0 <tickslock>
    800024be:	a811                	j	800024d2 <wakeup+0x46>
      }
      release(&p->lock);
    800024c0:	8526                	mv	a0,s1
    800024c2:	ffffe097          	auipc	ra,0xffffe
    800024c6:	7b4080e7          	jalr	1972(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800024ca:	19048493          	addi	s1,s1,400
    800024ce:	03248963          	beq	s1,s2,80002500 <wakeup+0x74>
    if(p != myproc()){
    800024d2:	fffff097          	auipc	ra,0xfffff
    800024d6:	4ac080e7          	jalr	1196(ra) # 8000197e <myproc>
    800024da:	fea488e3          	beq	s1,a0,800024ca <wakeup+0x3e>
      acquire(&p->lock);
    800024de:	8526                	mv	a0,s1
    800024e0:	ffffe097          	auipc	ra,0xffffe
    800024e4:	6e2080e7          	jalr	1762(ra) # 80000bc2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800024e8:	4c9c                	lw	a5,24(s1)
    800024ea:	fd379be3          	bne	a5,s3,800024c0 <wakeup+0x34>
    800024ee:	709c                	ld	a5,32(s1)
    800024f0:	fd4798e3          	bne	a5,s4,800024c0 <wakeup+0x34>
        p->state = RUNNABLE;
    800024f4:	0164ac23          	sw	s6,24(s1)
        p->runnable_since = ticks;
    800024f8:	000aa783          	lw	a5,0(s5)
    800024fc:	ccbc                	sw	a5,88(s1)
    800024fe:	b7c9                	j	800024c0 <wakeup+0x34>
    }
  }
}
    80002500:	70e2                	ld	ra,56(sp)
    80002502:	7442                	ld	s0,48(sp)
    80002504:	74a2                	ld	s1,40(sp)
    80002506:	7902                	ld	s2,32(sp)
    80002508:	69e2                	ld	s3,24(sp)
    8000250a:	6a42                	ld	s4,16(sp)
    8000250c:	6aa2                	ld	s5,8(sp)
    8000250e:	6b02                	ld	s6,0(sp)
    80002510:	6121                	addi	sp,sp,64
    80002512:	8082                	ret

0000000080002514 <reparent>:
{
    80002514:	7179                	addi	sp,sp,-48
    80002516:	f406                	sd	ra,40(sp)
    80002518:	f022                	sd	s0,32(sp)
    8000251a:	ec26                	sd	s1,24(sp)
    8000251c:	e84a                	sd	s2,16(sp)
    8000251e:	e44e                	sd	s3,8(sp)
    80002520:	e052                	sd	s4,0(sp)
    80002522:	1800                	addi	s0,sp,48
    80002524:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002526:	0000f497          	auipc	s1,0xf
    8000252a:	1aa48493          	addi	s1,s1,426 # 800116d0 <proc>
      pp->parent = initproc;
    8000252e:	00007a17          	auipc	s4,0x7
    80002532:	afaa0a13          	addi	s4,s4,-1286 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002536:	00015997          	auipc	s3,0x15
    8000253a:	59a98993          	addi	s3,s3,1434 # 80017ad0 <tickslock>
    8000253e:	a029                	j	80002548 <reparent+0x34>
    80002540:	19048493          	addi	s1,s1,400
    80002544:	01348d63          	beq	s1,s3,8000255e <reparent+0x4a>
    if(pp->parent == p){
    80002548:	70bc                	ld	a5,96(s1)
    8000254a:	ff279be3          	bne	a5,s2,80002540 <reparent+0x2c>
      pp->parent = initproc;
    8000254e:	000a3503          	ld	a0,0(s4)
    80002552:	f0a8                	sd	a0,96(s1)
      wakeup(initproc);
    80002554:	00000097          	auipc	ra,0x0
    80002558:	f38080e7          	jalr	-200(ra) # 8000248c <wakeup>
    8000255c:	b7d5                	j	80002540 <reparent+0x2c>
}
    8000255e:	70a2                	ld	ra,40(sp)
    80002560:	7402                	ld	s0,32(sp)
    80002562:	64e2                	ld	s1,24(sp)
    80002564:	6942                	ld	s2,16(sp)
    80002566:	69a2                	ld	s3,8(sp)
    80002568:	6a02                	ld	s4,0(sp)
    8000256a:	6145                	addi	sp,sp,48
    8000256c:	8082                	ret

000000008000256e <exit>:
{
    8000256e:	7179                	addi	sp,sp,-48
    80002570:	f406                	sd	ra,40(sp)
    80002572:	f022                	sd	s0,32(sp)
    80002574:	ec26                	sd	s1,24(sp)
    80002576:	e84a                	sd	s2,16(sp)
    80002578:	e44e                	sd	s3,8(sp)
    8000257a:	e052                	sd	s4,0(sp)
    8000257c:	1800                	addi	s0,sp,48
    8000257e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002580:	fffff097          	auipc	ra,0xfffff
    80002584:	3fe080e7          	jalr	1022(ra) # 8000197e <myproc>
    80002588:	89aa                	mv	s3,a0
  if(p == initproc)
    8000258a:	00007797          	auipc	a5,0x7
    8000258e:	a9e7b783          	ld	a5,-1378(a5) # 80009028 <initproc>
    80002592:	0f850493          	addi	s1,a0,248
    80002596:	17850913          	addi	s2,a0,376
    8000259a:	02a79363          	bne	a5,a0,800025c0 <exit+0x52>
    panic("init exiting");
    8000259e:	00006517          	auipc	a0,0x6
    800025a2:	dba50513          	addi	a0,a0,-582 # 80008358 <digits+0x318>
    800025a6:	ffffe097          	auipc	ra,0xffffe
    800025aa:	f84080e7          	jalr	-124(ra) # 8000052a <panic>
      fileclose(f);
    800025ae:	00002097          	auipc	ra,0x2
    800025b2:	5f6080e7          	jalr	1526(ra) # 80004ba4 <fileclose>
      p->ofile[fd] = 0;
    800025b6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800025ba:	04a1                	addi	s1,s1,8
    800025bc:	01248563          	beq	s1,s2,800025c6 <exit+0x58>
    if(p->ofile[fd]){
    800025c0:	6088                	ld	a0,0(s1)
    800025c2:	f575                	bnez	a0,800025ae <exit+0x40>
    800025c4:	bfdd                	j	800025ba <exit+0x4c>
  begin_op();
    800025c6:	00002097          	auipc	ra,0x2
    800025ca:	112080e7          	jalr	274(ra) # 800046d8 <begin_op>
  iput(p->cwd);
    800025ce:	1789b503          	ld	a0,376(s3)
    800025d2:	00002097          	auipc	ra,0x2
    800025d6:	8ea080e7          	jalr	-1814(ra) # 80003ebc <iput>
  end_op();
    800025da:	00002097          	auipc	ra,0x2
    800025de:	17e080e7          	jalr	382(ra) # 80004758 <end_op>
  p->cwd = 0;
    800025e2:	1609bc23          	sd	zero,376(s3)
  acquire(&wait_lock);
    800025e6:	0000f497          	auipc	s1,0xf
    800025ea:	cd248493          	addi	s1,s1,-814 # 800112b8 <wait_lock>
    800025ee:	8526                	mv	a0,s1
    800025f0:	ffffe097          	auipc	ra,0xffffe
    800025f4:	5d2080e7          	jalr	1490(ra) # 80000bc2 <acquire>
  reparent(p);
    800025f8:	854e                	mv	a0,s3
    800025fa:	00000097          	auipc	ra,0x0
    800025fe:	f1a080e7          	jalr	-230(ra) # 80002514 <reparent>
  wakeup(p->parent);
    80002602:	0609b503          	ld	a0,96(s3)
    80002606:	00000097          	auipc	ra,0x0
    8000260a:	e86080e7          	jalr	-378(ra) # 8000248c <wakeup>
  acquire(&p->lock);
    8000260e:	854e                	mv	a0,s3
    80002610:	ffffe097          	auipc	ra,0xffffe
    80002614:	5b2080e7          	jalr	1458(ra) # 80000bc2 <acquire>
  p->xstate = status;
    80002618:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000261c:	4795                	li	a5,5
    8000261e:	00f9ac23          	sw	a5,24(s3)
  p->ttime = ticks; //update termination time
    80002622:	00007797          	auipc	a5,0x7
    80002626:	a0e7a783          	lw	a5,-1522(a5) # 80009030 <ticks>
    8000262a:	02f9ae23          	sw	a5,60(s3)
  release(&wait_lock);
    8000262e:	8526                	mv	a0,s1
    80002630:	ffffe097          	auipc	ra,0xffffe
    80002634:	646080e7          	jalr	1606(ra) # 80000c76 <release>
  sched();
    80002638:	00000097          	auipc	ra,0x0
    8000263c:	b92080e7          	jalr	-1134(ra) # 800021ca <sched>
  panic("zombie exit");
    80002640:	00006517          	auipc	a0,0x6
    80002644:	d2850513          	addi	a0,a0,-728 # 80008368 <digits+0x328>
    80002648:	ffffe097          	auipc	ra,0xffffe
    8000264c:	ee2080e7          	jalr	-286(ra) # 8000052a <panic>

0000000080002650 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002650:	7179                	addi	sp,sp,-48
    80002652:	f406                	sd	ra,40(sp)
    80002654:	f022                	sd	s0,32(sp)
    80002656:	ec26                	sd	s1,24(sp)
    80002658:	e84a                	sd	s2,16(sp)
    8000265a:	e44e                	sd	s3,8(sp)
    8000265c:	1800                	addi	s0,sp,48
    8000265e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002660:	0000f497          	auipc	s1,0xf
    80002664:	07048493          	addi	s1,s1,112 # 800116d0 <proc>
    80002668:	00015997          	auipc	s3,0x15
    8000266c:	46898993          	addi	s3,s3,1128 # 80017ad0 <tickslock>
    acquire(&p->lock);
    80002670:	8526                	mv	a0,s1
    80002672:	ffffe097          	auipc	ra,0xffffe
    80002676:	550080e7          	jalr	1360(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    8000267a:	589c                	lw	a5,48(s1)
    8000267c:	01278d63          	beq	a5,s2,80002696 <kill+0x46>
        p->runnable_since=ticks;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002680:	8526                	mv	a0,s1
    80002682:	ffffe097          	auipc	ra,0xffffe
    80002686:	5f4080e7          	jalr	1524(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000268a:	19048493          	addi	s1,s1,400
    8000268e:	ff3491e3          	bne	s1,s3,80002670 <kill+0x20>
  }
  return -1;
    80002692:	557d                	li	a0,-1
    80002694:	a829                	j	800026ae <kill+0x5e>
      p->killed = 1;
    80002696:	4785                	li	a5,1
    80002698:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000269a:	4c98                	lw	a4,24(s1)
    8000269c:	4789                	li	a5,2
    8000269e:	00f70f63          	beq	a4,a5,800026bc <kill+0x6c>
      release(&p->lock);
    800026a2:	8526                	mv	a0,s1
    800026a4:	ffffe097          	auipc	ra,0xffffe
    800026a8:	5d2080e7          	jalr	1490(ra) # 80000c76 <release>
      return 0;
    800026ac:	4501                	li	a0,0
}
    800026ae:	70a2                	ld	ra,40(sp)
    800026b0:	7402                	ld	s0,32(sp)
    800026b2:	64e2                	ld	s1,24(sp)
    800026b4:	6942                	ld	s2,16(sp)
    800026b6:	69a2                	ld	s3,8(sp)
    800026b8:	6145                	addi	sp,sp,48
    800026ba:	8082                	ret
        p->state = RUNNABLE;
    800026bc:	478d                	li	a5,3
    800026be:	cc9c                	sw	a5,24(s1)
        p->runnable_since=ticks;
    800026c0:	00007797          	auipc	a5,0x7
    800026c4:	9707a783          	lw	a5,-1680(a5) # 80009030 <ticks>
    800026c8:	ccbc                	sw	a5,88(s1)
    800026ca:	bfe1                	j	800026a2 <kill+0x52>

00000000800026cc <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800026cc:	7179                	addi	sp,sp,-48
    800026ce:	f406                	sd	ra,40(sp)
    800026d0:	f022                	sd	s0,32(sp)
    800026d2:	ec26                	sd	s1,24(sp)
    800026d4:	e84a                	sd	s2,16(sp)
    800026d6:	e44e                	sd	s3,8(sp)
    800026d8:	e052                	sd	s4,0(sp)
    800026da:	1800                	addi	s0,sp,48
    800026dc:	84aa                	mv	s1,a0
    800026de:	892e                	mv	s2,a1
    800026e0:	89b2                	mv	s3,a2
    800026e2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026e4:	fffff097          	auipc	ra,0xfffff
    800026e8:	29a080e7          	jalr	666(ra) # 8000197e <myproc>
  if(user_dst){
    800026ec:	c08d                	beqz	s1,8000270e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800026ee:	86d2                	mv	a3,s4
    800026f0:	864e                	mv	a2,s3
    800026f2:	85ca                	mv	a1,s2
    800026f4:	7d28                	ld	a0,120(a0)
    800026f6:	fffff097          	auipc	ra,0xfffff
    800026fa:	f48080e7          	jalr	-184(ra) # 8000163e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800026fe:	70a2                	ld	ra,40(sp)
    80002700:	7402                	ld	s0,32(sp)
    80002702:	64e2                	ld	s1,24(sp)
    80002704:	6942                	ld	s2,16(sp)
    80002706:	69a2                	ld	s3,8(sp)
    80002708:	6a02                	ld	s4,0(sp)
    8000270a:	6145                	addi	sp,sp,48
    8000270c:	8082                	ret
    memmove((char *)dst, src, len);
    8000270e:	000a061b          	sext.w	a2,s4
    80002712:	85ce                	mv	a1,s3
    80002714:	854a                	mv	a0,s2
    80002716:	ffffe097          	auipc	ra,0xffffe
    8000271a:	604080e7          	jalr	1540(ra) # 80000d1a <memmove>
    return 0;
    8000271e:	8526                	mv	a0,s1
    80002720:	bff9                	j	800026fe <either_copyout+0x32>

0000000080002722 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002722:	7179                	addi	sp,sp,-48
    80002724:	f406                	sd	ra,40(sp)
    80002726:	f022                	sd	s0,32(sp)
    80002728:	ec26                	sd	s1,24(sp)
    8000272a:	e84a                	sd	s2,16(sp)
    8000272c:	e44e                	sd	s3,8(sp)
    8000272e:	e052                	sd	s4,0(sp)
    80002730:	1800                	addi	s0,sp,48
    80002732:	892a                	mv	s2,a0
    80002734:	84ae                	mv	s1,a1
    80002736:	89b2                	mv	s3,a2
    80002738:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000273a:	fffff097          	auipc	ra,0xfffff
    8000273e:	244080e7          	jalr	580(ra) # 8000197e <myproc>
  if(user_src){
    80002742:	c08d                	beqz	s1,80002764 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002744:	86d2                	mv	a3,s4
    80002746:	864e                	mv	a2,s3
    80002748:	85ca                	mv	a1,s2
    8000274a:	7d28                	ld	a0,120(a0)
    8000274c:	fffff097          	auipc	ra,0xfffff
    80002750:	f7e080e7          	jalr	-130(ra) # 800016ca <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002754:	70a2                	ld	ra,40(sp)
    80002756:	7402                	ld	s0,32(sp)
    80002758:	64e2                	ld	s1,24(sp)
    8000275a:	6942                	ld	s2,16(sp)
    8000275c:	69a2                	ld	s3,8(sp)
    8000275e:	6a02                	ld	s4,0(sp)
    80002760:	6145                	addi	sp,sp,48
    80002762:	8082                	ret
    memmove(dst, (char*)src, len);
    80002764:	000a061b          	sext.w	a2,s4
    80002768:	85ce                	mv	a1,s3
    8000276a:	854a                	mv	a0,s2
    8000276c:	ffffe097          	auipc	ra,0xffffe
    80002770:	5ae080e7          	jalr	1454(ra) # 80000d1a <memmove>
    return 0;
    80002774:	8526                	mv	a0,s1
    80002776:	bff9                	j	80002754 <either_copyin+0x32>

0000000080002778 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002778:	715d                	addi	sp,sp,-80
    8000277a:	e486                	sd	ra,72(sp)
    8000277c:	e0a2                	sd	s0,64(sp)
    8000277e:	fc26                	sd	s1,56(sp)
    80002780:	f84a                	sd	s2,48(sp)
    80002782:	f44e                	sd	s3,40(sp)
    80002784:	f052                	sd	s4,32(sp)
    80002786:	ec56                	sd	s5,24(sp)
    80002788:	e85a                	sd	s6,16(sp)
    8000278a:	e45e                	sd	s7,8(sp)
    8000278c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000278e:	00006517          	auipc	a0,0x6
    80002792:	93a50513          	addi	a0,a0,-1734 # 800080c8 <digits+0x88>
    80002796:	ffffe097          	auipc	ra,0xffffe
    8000279a:	dde080e7          	jalr	-546(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000279e:	0000f497          	auipc	s1,0xf
    800027a2:	0b248493          	addi	s1,s1,178 # 80011850 <proc+0x180>
    800027a6:	00015917          	auipc	s2,0x15
    800027aa:	4aa90913          	addi	s2,s2,1194 # 80017c50 <bcache+0x168>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027ae:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800027b0:	00006997          	auipc	s3,0x6
    800027b4:	bc898993          	addi	s3,s3,-1080 # 80008378 <digits+0x338>
    printf("%d %s %s", p->pid, state, p->name);
    800027b8:	00006a97          	auipc	s5,0x6
    800027bc:	bc8a8a93          	addi	s5,s5,-1080 # 80008380 <digits+0x340>
    printf("\n");
    800027c0:	00006a17          	auipc	s4,0x6
    800027c4:	908a0a13          	addi	s4,s4,-1784 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027c8:	00006b97          	auipc	s7,0x6
    800027cc:	bf0b8b93          	addi	s7,s7,-1040 # 800083b8 <states.0>
    800027d0:	a00d                	j	800027f2 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800027d2:	eb06a583          	lw	a1,-336(a3)
    800027d6:	8556                	mv	a0,s5
    800027d8:	ffffe097          	auipc	ra,0xffffe
    800027dc:	d9c080e7          	jalr	-612(ra) # 80000574 <printf>
    printf("\n");
    800027e0:	8552                	mv	a0,s4
    800027e2:	ffffe097          	auipc	ra,0xffffe
    800027e6:	d92080e7          	jalr	-622(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027ea:	19048493          	addi	s1,s1,400
    800027ee:	03248263          	beq	s1,s2,80002812 <procdump+0x9a>
    if(p->state == UNUSED)
    800027f2:	86a6                	mv	a3,s1
    800027f4:	e984a783          	lw	a5,-360(s1)
    800027f8:	dbed                	beqz	a5,800027ea <procdump+0x72>
      state = "???";
    800027fa:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027fc:	fcfb6be3          	bltu	s6,a5,800027d2 <procdump+0x5a>
    80002800:	02079713          	slli	a4,a5,0x20
    80002804:	01d75793          	srli	a5,a4,0x1d
    80002808:	97de                	add	a5,a5,s7
    8000280a:	6390                	ld	a2,0(a5)
    8000280c:	f279                	bnez	a2,800027d2 <procdump+0x5a>
      state = "???";
    8000280e:	864e                	mv	a2,s3
    80002810:	b7c9                	j	800027d2 <procdump+0x5a>
  }
}
    80002812:	60a6                	ld	ra,72(sp)
    80002814:	6406                	ld	s0,64(sp)
    80002816:	74e2                	ld	s1,56(sp)
    80002818:	7942                	ld	s2,48(sp)
    8000281a:	79a2                	ld	s3,40(sp)
    8000281c:	7a02                	ld	s4,32(sp)
    8000281e:	6ae2                	ld	s5,24(sp)
    80002820:	6b42                	ld	s6,16(sp)
    80002822:	6ba2                	ld	s7,8(sp)
    80002824:	6161                	addi	sp,sp,80
    80002826:	8082                	ret

0000000080002828 <trace>:

// Changes the Trace bit mask for proccess with input pid
// Trace mask determines which system calls will be traced
int
trace(int mask, int pid){
    80002828:	7179                	addi	sp,sp,-48
    8000282a:	f406                	sd	ra,40(sp)
    8000282c:	f022                	sd	s0,32(sp)
    8000282e:	ec26                	sd	s1,24(sp)
    80002830:	e84a                	sd	s2,16(sp)
    80002832:	e44e                	sd	s3,8(sp)
    80002834:	e052                	sd	s4,0(sp)
    80002836:	1800                	addi	s0,sp,48
    80002838:	8a2a                	mv	s4,a0
    8000283a:	892e                	mv	s2,a1
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000283c:	0000f497          	auipc	s1,0xf
    80002840:	e9448493          	addi	s1,s1,-364 # 800116d0 <proc>
    80002844:	00015997          	auipc	s3,0x15
    80002848:	28c98993          	addi	s3,s3,652 # 80017ad0 <tickslock>
    acquire(&p->lock);
    8000284c:	8526                	mv	a0,s1
    8000284e:	ffffe097          	auipc	ra,0xffffe
    80002852:	374080e7          	jalr	884(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    80002856:	589c                	lw	a5,48(s1)
    80002858:	01278d63          	beq	a5,s2,80002872 <trace+0x4a>
      p->tracemask = mask;
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000285c:	8526                	mv	a0,s1
    8000285e:	ffffe097          	auipc	ra,0xffffe
    80002862:	418080e7          	jalr	1048(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002866:	19048493          	addi	s1,s1,400
    8000286a:	ff3491e3          	bne	s1,s3,8000284c <trace+0x24>
  }
  return -1;
    8000286e:	557d                	li	a0,-1
    80002870:	a809                	j	80002882 <trace+0x5a>
      p->tracemask = mask;
    80002872:	0344aa23          	sw	s4,52(s1)
      release(&p->lock);
    80002876:	8526                	mv	a0,s1
    80002878:	ffffe097          	auipc	ra,0xffffe
    8000287c:	3fe080e7          	jalr	1022(ra) # 80000c76 <release>
      return 0;
    80002880:	4501                	li	a0,0
}
    80002882:	70a2                	ld	ra,40(sp)
    80002884:	7402                	ld	s0,32(sp)
    80002886:	64e2                	ld	s1,24(sp)
    80002888:	6942                	ld	s2,16(sp)
    8000288a:	69a2                	ld	s3,8(sp)
    8000288c:	6a02                	ld	s4,0(sp)
    8000288e:	6145                	addi	sp,sp,48
    80002890:	8082                	ret

0000000080002892 <wait_stat>:

int
wait_stat(uint64 stat_addr, uint64 perf_addr){// ass1 
    80002892:	7119                	addi	sp,sp,-128
    80002894:	fc86                	sd	ra,120(sp)
    80002896:	f8a2                	sd	s0,112(sp)
    80002898:	f4a6                	sd	s1,104(sp)
    8000289a:	f0ca                	sd	s2,96(sp)
    8000289c:	ecce                	sd	s3,88(sp)
    8000289e:	e8d2                	sd	s4,80(sp)
    800028a0:	e4d6                	sd	s5,72(sp)
    800028a2:	e0da                	sd	s6,64(sp)
    800028a4:	fc5e                	sd	s7,56(sp)
    800028a6:	f862                	sd	s8,48(sp)
    800028a8:	f466                	sd	s9,40(sp)
    800028aa:	0100                	addi	s0,sp,128
    800028ac:	8b2a                	mv	s6,a0
    800028ae:	8bae                	mv	s7,a1
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800028b0:	fffff097          	auipc	ra,0xfffff
    800028b4:	0ce080e7          	jalr	206(ra) # 8000197e <myproc>
    800028b8:	892a                	mv	s2,a0
  struct perf child_perf;
  acquire(&wait_lock);
    800028ba:	0000f517          	auipc	a0,0xf
    800028be:	9fe50513          	addi	a0,a0,-1538 # 800112b8 <wait_lock>
    800028c2:	ffffe097          	auipc	ra,0xffffe
    800028c6:	300080e7          	jalr	768(ra) # 80000bc2 <acquire>
  
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    800028ca:	4c01                	li	s8,0
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){ 
    800028cc:	4a15                	li	s4,5
        havekids = 1;
    800028ce:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800028d0:	00015997          	auipc	s3,0x15
    800028d4:	20098993          	addi	s3,s3,512 # 80017ad0 <tickslock>
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800028d8:	0000fc97          	auipc	s9,0xf
    800028dc:	9e0c8c93          	addi	s9,s9,-1568 # 800112b8 <wait_lock>
    havekids = 0;
    800028e0:	8762                	mv	a4,s8
    for(np = proc; np < &proc[NPROC]; np++){
    800028e2:	0000f497          	auipc	s1,0xf
    800028e6:	dee48493          	addi	s1,s1,-530 # 800116d0 <proc>
    800028ea:	a861                	j	80002982 <wait_stat+0xf0>
          pid = np->pid;
    800028ec:	0304a983          	lw	s3,48(s1)
          perfi(np, &child_perf);
    800028f0:	f8840593          	addi	a1,s0,-120
    800028f4:	8526                	mv	a0,s1
    800028f6:	fffff097          	auipc	ra,0xfffff
    800028fa:	4cc080e7          	jalr	1228(ra) # 80001dc2 <perfi>
          if(stat_addr != 0 && perf_addr != 0 && 
    800028fe:	000b0463          	beqz	s6,80002906 <wait_stat+0x74>
    80002902:	020b9563          	bnez	s7,8000292c <wait_stat+0x9a>
          freeproc(np);
    80002906:	8526                	mv	a0,s1
    80002908:	fffff097          	auipc	ra,0xfffff
    8000290c:	268080e7          	jalr	616(ra) # 80001b70 <freeproc>
          release(&np->lock);
    80002910:	8526                	mv	a0,s1
    80002912:	ffffe097          	auipc	ra,0xffffe
    80002916:	364080e7          	jalr	868(ra) # 80000c76 <release>
          release(&wait_lock);
    8000291a:	0000f517          	auipc	a0,0xf
    8000291e:	99e50513          	addi	a0,a0,-1634 # 800112b8 <wait_lock>
    80002922:	ffffe097          	auipc	ra,0xffffe
    80002926:	354080e7          	jalr	852(ra) # 80000c76 <release>
          return pid;
    8000292a:	a859                	j	800029c0 <wait_stat+0x12e>
            ((copyout(p->pagetable, stat_addr, (char *)&np->xstate,sizeof(np->xstate)) < 0) ||
    8000292c:	4691                	li	a3,4
    8000292e:	02c48613          	addi	a2,s1,44
    80002932:	85da                	mv	a1,s6
    80002934:	07893503          	ld	a0,120(s2)
    80002938:	fffff097          	auipc	ra,0xfffff
    8000293c:	d06080e7          	jalr	-762(ra) # 8000163e <copyout>
          if(stat_addr != 0 && perf_addr != 0 && 
    80002940:	00054e63          	bltz	a0,8000295c <wait_stat+0xca>
            (copyout(p->pagetable, perf_addr, (char *)&child_perf, sizeof(child_perf)) < 0))){
    80002944:	46e1                	li	a3,24
    80002946:	f8840613          	addi	a2,s0,-120
    8000294a:	85de                	mv	a1,s7
    8000294c:	07893503          	ld	a0,120(s2)
    80002950:	fffff097          	auipc	ra,0xfffff
    80002954:	cee080e7          	jalr	-786(ra) # 8000163e <copyout>
            ((copyout(p->pagetable, stat_addr, (char *)&np->xstate,sizeof(np->xstate)) < 0) ||
    80002958:	fa0557e3          	bgez	a0,80002906 <wait_stat+0x74>
            release(&np->lock);
    8000295c:	8526                	mv	a0,s1
    8000295e:	ffffe097          	auipc	ra,0xffffe
    80002962:	318080e7          	jalr	792(ra) # 80000c76 <release>
            release(&wait_lock);
    80002966:	0000f517          	auipc	a0,0xf
    8000296a:	95250513          	addi	a0,a0,-1710 # 800112b8 <wait_lock>
    8000296e:	ffffe097          	auipc	ra,0xffffe
    80002972:	308080e7          	jalr	776(ra) # 80000c76 <release>
            return -1;
    80002976:	59fd                	li	s3,-1
    80002978:	a0a1                	j	800029c0 <wait_stat+0x12e>
    for(np = proc; np < &proc[NPROC]; np++){
    8000297a:	19048493          	addi	s1,s1,400
    8000297e:	03348463          	beq	s1,s3,800029a6 <wait_stat+0x114>
      if(np->parent == p){
    80002982:	70bc                	ld	a5,96(s1)
    80002984:	ff279be3          	bne	a5,s2,8000297a <wait_stat+0xe8>
        acquire(&np->lock);
    80002988:	8526                	mv	a0,s1
    8000298a:	ffffe097          	auipc	ra,0xffffe
    8000298e:	238080e7          	jalr	568(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){ 
    80002992:	4c9c                	lw	a5,24(s1)
    80002994:	f5478ce3          	beq	a5,s4,800028ec <wait_stat+0x5a>
        release(&np->lock);
    80002998:	8526                	mv	a0,s1
    8000299a:	ffffe097          	auipc	ra,0xffffe
    8000299e:	2dc080e7          	jalr	732(ra) # 80000c76 <release>
        havekids = 1;
    800029a2:	8756                	mv	a4,s5
    800029a4:	bfd9                	j	8000297a <wait_stat+0xe8>
    if(!havekids || p->killed){
    800029a6:	c701                	beqz	a4,800029ae <wait_stat+0x11c>
    800029a8:	02892783          	lw	a5,40(s2)
    800029ac:	cb85                	beqz	a5,800029dc <wait_stat+0x14a>
      release(&wait_lock);
    800029ae:	0000f517          	auipc	a0,0xf
    800029b2:	90a50513          	addi	a0,a0,-1782 # 800112b8 <wait_lock>
    800029b6:	ffffe097          	auipc	ra,0xffffe
    800029ba:	2c0080e7          	jalr	704(ra) # 80000c76 <release>
      return -1;
    800029be:	59fd                	li	s3,-1
  }

}
    800029c0:	854e                	mv	a0,s3
    800029c2:	70e6                	ld	ra,120(sp)
    800029c4:	7446                	ld	s0,112(sp)
    800029c6:	74a6                	ld	s1,104(sp)
    800029c8:	7906                	ld	s2,96(sp)
    800029ca:	69e6                	ld	s3,88(sp)
    800029cc:	6a46                	ld	s4,80(sp)
    800029ce:	6aa6                	ld	s5,72(sp)
    800029d0:	6b06                	ld	s6,64(sp)
    800029d2:	7be2                	ld	s7,56(sp)
    800029d4:	7c42                	ld	s8,48(sp)
    800029d6:	7ca2                	ld	s9,40(sp)
    800029d8:	6109                	addi	sp,sp,128
    800029da:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800029dc:	85e6                	mv	a1,s9
    800029de:	854a                	mv	a0,s2
    800029e0:	00000097          	auipc	ra,0x0
    800029e4:	920080e7          	jalr	-1760(ra) # 80002300 <sleep>
    havekids = 0;
    800029e8:	bde5                	j	800028e0 <wait_stat+0x4e>

00000000800029ea <update_times>:

void
update_times(){
    800029ea:	7139                	addi	sp,sp,-64
    800029ec:	fc06                	sd	ra,56(sp)
    800029ee:	f822                	sd	s0,48(sp)
    800029f0:	f426                	sd	s1,40(sp)
    800029f2:	f04a                	sd	s2,32(sp)
    800029f4:	ec4e                	sd	s3,24(sp)
    800029f6:	e852                	sd	s4,16(sp)
    800029f8:	e456                	sd	s5,8(sp)
    800029fa:	0080                	addi	s0,sp,64
    struct proc *np;

    for(np = proc; np < &proc[NPROC]; np++){
    800029fc:	0000f497          	auipc	s1,0xf
    80002a00:	cd448493          	addi	s1,s1,-812 # 800116d0 <proc>
      acquire(&np->lock);
      switch (np->state)
    80002a04:	4a8d                	li	s5,3
    80002a06:	4a11                	li	s4,4
    80002a08:	4989                	li	s3,2
    for(np = proc; np < &proc[NPROC]; np++){
    80002a0a:	00015917          	auipc	s2,0x15
    80002a0e:	0c690913          	addi	s2,s2,198 # 80017ad0 <tickslock>
    80002a12:	a829                	j	80002a2c <update_times+0x42>
      {
      case SLEEPING:
        np->stime++;
        break;
      case RUNNABLE:
        np->retime++;
    80002a14:	40fc                	lw	a5,68(s1)
    80002a16:	2785                	addiw	a5,a5,1
    80002a18:	c0fc                	sw	a5,68(s1)
        np->rutime++;
        break;
      default:
        break;
      }
    release(&np->lock);
    80002a1a:	8526                	mv	a0,s1
    80002a1c:	ffffe097          	auipc	ra,0xffffe
    80002a20:	25a080e7          	jalr	602(ra) # 80000c76 <release>
    for(np = proc; np < &proc[NPROC]; np++){
    80002a24:	19048493          	addi	s1,s1,400
    80002a28:	03248963          	beq	s1,s2,80002a5a <update_times+0x70>
      acquire(&np->lock);
    80002a2c:	8526                	mv	a0,s1
    80002a2e:	ffffe097          	auipc	ra,0xffffe
    80002a32:	194080e7          	jalr	404(ra) # 80000bc2 <acquire>
      switch (np->state)
    80002a36:	4c9c                	lw	a5,24(s1)
    80002a38:	fd578ee3          	beq	a5,s5,80002a14 <update_times+0x2a>
    80002a3c:	01478863          	beq	a5,s4,80002a4c <update_times+0x62>
    80002a40:	fd379de3          	bne	a5,s3,80002a1a <update_times+0x30>
        np->stime++;
    80002a44:	40bc                	lw	a5,64(s1)
    80002a46:	2785                	addiw	a5,a5,1
    80002a48:	c0bc                	sw	a5,64(s1)
        break;
    80002a4a:	bfc1                	j	80002a1a <update_times+0x30>
        np->current_runtime++;
    80002a4c:	48fc                	lw	a5,84(s1)
    80002a4e:	2785                	addiw	a5,a5,1
    80002a50:	c8fc                	sw	a5,84(s1)
        np->rutime++;
    80002a52:	44bc                	lw	a5,72(s1)
    80002a54:	2785                	addiw	a5,a5,1
    80002a56:	c4bc                	sw	a5,72(s1)
        break;
    80002a58:	b7c9                	j	80002a1a <update_times+0x30>
    } 
}
    80002a5a:	70e2                	ld	ra,56(sp)
    80002a5c:	7442                	ld	s0,48(sp)
    80002a5e:	74a2                	ld	s1,40(sp)
    80002a60:	7902                	ld	s2,32(sp)
    80002a62:	69e2                	ld	s3,24(sp)
    80002a64:	6a42                	ld	s4,16(sp)
    80002a66:	6aa2                	ld	s5,8(sp)
    80002a68:	6121                	addi	sp,sp,64
    80002a6a:	8082                	ret

0000000080002a6c <set_priority>:

int
set_priority(int priority){
    80002a6c:	7139                	addi	sp,sp,-64
    80002a6e:	fc06                	sd	ra,56(sp)
    80002a70:	f822                	sd	s0,48(sp)
    80002a72:	f426                	sd	s1,40(sp)
    80002a74:	f04a                	sd	s2,32(sp)
    80002a76:	0080                	addi	s0,sp,64
    80002a78:	84aa                	mv	s1,a0
  struct proc *p = myproc();   
    80002a7a:	fffff097          	auipc	ra,0xfffff
    80002a7e:	f04080e7          	jalr	-252(ra) # 8000197e <myproc>
  int priority_to_decay[5] = {1,3,5,7,25};
    80002a82:	4785                	li	a5,1
    80002a84:	fcf42423          	sw	a5,-56(s0)
    80002a88:	478d                	li	a5,3
    80002a8a:	fcf42623          	sw	a5,-52(s0)
    80002a8e:	4795                	li	a5,5
    80002a90:	fcf42823          	sw	a5,-48(s0)
    80002a94:	479d                	li	a5,7
    80002a96:	fcf42a23          	sw	a5,-44(s0)
    80002a9a:	47e5                	li	a5,25
    80002a9c:	fcf42c23          	sw	a5,-40(s0)

  if(priority < 1 || priority > 5)
    80002aa0:	fff4871b          	addiw	a4,s1,-1
    80002aa4:	4791                	li	a5,4
    80002aa6:	02e7ec63          	bltu	a5,a4,80002ade <set_priority+0x72>
    80002aaa:	892a                	mv	s2,a0
    return -1;

  acquire(&p->lock);
    80002aac:	ffffe097          	auipc	ra,0xffffe
    80002ab0:	116080e7          	jalr	278(ra) # 80000bc2 <acquire>
  p->decay_factor=priority_to_decay[priority-1];
    80002ab4:	34fd                	addiw	s1,s1,-1
    80002ab6:	048a                	slli	s1,s1,0x2
    80002ab8:	fe040793          	addi	a5,s0,-32
    80002abc:	94be                	add	s1,s1,a5
    80002abe:	fe84a783          	lw	a5,-24(s1)
    80002ac2:	04f92823          	sw	a5,80(s2)
  release(&p->lock); 
    80002ac6:	854a                	mv	a0,s2
    80002ac8:	ffffe097          	auipc	ra,0xffffe
    80002acc:	1ae080e7          	jalr	430(ra) # 80000c76 <release>

  return 0;
    80002ad0:	4501                	li	a0,0
}
    80002ad2:	70e2                	ld	ra,56(sp)
    80002ad4:	7442                	ld	s0,48(sp)
    80002ad6:	74a2                	ld	s1,40(sp)
    80002ad8:	7902                	ld	s2,32(sp)
    80002ada:	6121                	addi	sp,sp,64
    80002adc:	8082                	ret
    return -1;
    80002ade:	557d                	li	a0,-1
    80002ae0:	bfcd                	j	80002ad2 <set_priority+0x66>

0000000080002ae2 <swtch>:
    80002ae2:	00153023          	sd	ra,0(a0)
    80002ae6:	00253423          	sd	sp,8(a0)
    80002aea:	e900                	sd	s0,16(a0)
    80002aec:	ed04                	sd	s1,24(a0)
    80002aee:	03253023          	sd	s2,32(a0)
    80002af2:	03353423          	sd	s3,40(a0)
    80002af6:	03453823          	sd	s4,48(a0)
    80002afa:	03553c23          	sd	s5,56(a0)
    80002afe:	05653023          	sd	s6,64(a0)
    80002b02:	05753423          	sd	s7,72(a0)
    80002b06:	05853823          	sd	s8,80(a0)
    80002b0a:	05953c23          	sd	s9,88(a0)
    80002b0e:	07a53023          	sd	s10,96(a0)
    80002b12:	07b53423          	sd	s11,104(a0)
    80002b16:	0005b083          	ld	ra,0(a1)
    80002b1a:	0085b103          	ld	sp,8(a1)
    80002b1e:	6980                	ld	s0,16(a1)
    80002b20:	6d84                	ld	s1,24(a1)
    80002b22:	0205b903          	ld	s2,32(a1)
    80002b26:	0285b983          	ld	s3,40(a1)
    80002b2a:	0305ba03          	ld	s4,48(a1)
    80002b2e:	0385ba83          	ld	s5,56(a1)
    80002b32:	0405bb03          	ld	s6,64(a1)
    80002b36:	0485bb83          	ld	s7,72(a1)
    80002b3a:	0505bc03          	ld	s8,80(a1)
    80002b3e:	0585bc83          	ld	s9,88(a1)
    80002b42:	0605bd03          	ld	s10,96(a1)
    80002b46:	0685bd83          	ld	s11,104(a1)
    80002b4a:	8082                	ret

0000000080002b4c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002b4c:	1141                	addi	sp,sp,-16
    80002b4e:	e406                	sd	ra,8(sp)
    80002b50:	e022                	sd	s0,0(sp)
    80002b52:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002b54:	00006597          	auipc	a1,0x6
    80002b58:	89458593          	addi	a1,a1,-1900 # 800083e8 <states.0+0x30>
    80002b5c:	00015517          	auipc	a0,0x15
    80002b60:	f7450513          	addi	a0,a0,-140 # 80017ad0 <tickslock>
    80002b64:	ffffe097          	auipc	ra,0xffffe
    80002b68:	fce080e7          	jalr	-50(ra) # 80000b32 <initlock>
}
    80002b6c:	60a2                	ld	ra,8(sp)
    80002b6e:	6402                	ld	s0,0(sp)
    80002b70:	0141                	addi	sp,sp,16
    80002b72:	8082                	ret

0000000080002b74 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002b74:	1141                	addi	sp,sp,-16
    80002b76:	e422                	sd	s0,8(sp)
    80002b78:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b7a:	00003797          	auipc	a5,0x3
    80002b7e:	65678793          	addi	a5,a5,1622 # 800061d0 <kernelvec>
    80002b82:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002b86:	6422                	ld	s0,8(sp)
    80002b88:	0141                	addi	sp,sp,16
    80002b8a:	8082                	ret

0000000080002b8c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002b8c:	1141                	addi	sp,sp,-16
    80002b8e:	e406                	sd	ra,8(sp)
    80002b90:	e022                	sd	s0,0(sp)
    80002b92:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b94:	fffff097          	auipc	ra,0xfffff
    80002b98:	dea080e7          	jalr	-534(ra) # 8000197e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002ba0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ba2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002ba6:	00004617          	auipc	a2,0x4
    80002baa:	45a60613          	addi	a2,a2,1114 # 80007000 <_trampoline>
    80002bae:	00004697          	auipc	a3,0x4
    80002bb2:	45268693          	addi	a3,a3,1106 # 80007000 <_trampoline>
    80002bb6:	8e91                	sub	a3,a3,a2
    80002bb8:	040007b7          	lui	a5,0x4000
    80002bbc:	17fd                	addi	a5,a5,-1
    80002bbe:	07b2                	slli	a5,a5,0xc
    80002bc0:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bc2:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002bc6:	6158                	ld	a4,128(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002bc8:	180026f3          	csrr	a3,satp
    80002bcc:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002bce:	6158                	ld	a4,128(a0)
    80002bd0:	7534                	ld	a3,104(a0)
    80002bd2:	6585                	lui	a1,0x1
    80002bd4:	96ae                	add	a3,a3,a1
    80002bd6:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002bd8:	6158                	ld	a4,128(a0)
    80002bda:	00000697          	auipc	a3,0x0
    80002bde:	14668693          	addi	a3,a3,326 # 80002d20 <usertrap>
    80002be2:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002be4:	6158                	ld	a4,128(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002be6:	8692                	mv	a3,tp
    80002be8:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bea:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002bee:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002bf2:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bf6:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002bfa:	6158                	ld	a4,128(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bfc:	6f18                	ld	a4,24(a4)
    80002bfe:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002c02:	7d2c                	ld	a1,120(a0)
    80002c04:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002c06:	00004717          	auipc	a4,0x4
    80002c0a:	48a70713          	addi	a4,a4,1162 # 80007090 <userret>
    80002c0e:	8f11                	sub	a4,a4,a2
    80002c10:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002c12:	577d                	li	a4,-1
    80002c14:	177e                	slli	a4,a4,0x3f
    80002c16:	8dd9                	or	a1,a1,a4
    80002c18:	02000537          	lui	a0,0x2000
    80002c1c:	157d                	addi	a0,a0,-1
    80002c1e:	0536                	slli	a0,a0,0xd
    80002c20:	9782                	jalr	a5
}
    80002c22:	60a2                	ld	ra,8(sp)
    80002c24:	6402                	ld	s0,0(sp)
    80002c26:	0141                	addi	sp,sp,16
    80002c28:	8082                	ret

0000000080002c2a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002c2a:	1101                	addi	sp,sp,-32
    80002c2c:	ec06                	sd	ra,24(sp)
    80002c2e:	e822                	sd	s0,16(sp)
    80002c30:	e426                	sd	s1,8(sp)
    80002c32:	e04a                	sd	s2,0(sp)
    80002c34:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002c36:	00015917          	auipc	s2,0x15
    80002c3a:	e9a90913          	addi	s2,s2,-358 # 80017ad0 <tickslock>
    80002c3e:	854a                	mv	a0,s2
    80002c40:	ffffe097          	auipc	ra,0xffffe
    80002c44:	f82080e7          	jalr	-126(ra) # 80000bc2 <acquire>
  ticks++;
    80002c48:	00006497          	auipc	s1,0x6
    80002c4c:	3e848493          	addi	s1,s1,1000 # 80009030 <ticks>
    80002c50:	409c                	lw	a5,0(s1)
    80002c52:	2785                	addiw	a5,a5,1
    80002c54:	c09c                	sw	a5,0(s1)
  update_times();
    80002c56:	00000097          	auipc	ra,0x0
    80002c5a:	d94080e7          	jalr	-620(ra) # 800029ea <update_times>
  wakeup(&ticks);
    80002c5e:	8526                	mv	a0,s1
    80002c60:	00000097          	auipc	ra,0x0
    80002c64:	82c080e7          	jalr	-2004(ra) # 8000248c <wakeup>
  release(&tickslock);
    80002c68:	854a                	mv	a0,s2
    80002c6a:	ffffe097          	auipc	ra,0xffffe
    80002c6e:	00c080e7          	jalr	12(ra) # 80000c76 <release>
}
    80002c72:	60e2                	ld	ra,24(sp)
    80002c74:	6442                	ld	s0,16(sp)
    80002c76:	64a2                	ld	s1,8(sp)
    80002c78:	6902                	ld	s2,0(sp)
    80002c7a:	6105                	addi	sp,sp,32
    80002c7c:	8082                	ret

0000000080002c7e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002c7e:	1101                	addi	sp,sp,-32
    80002c80:	ec06                	sd	ra,24(sp)
    80002c82:	e822                	sd	s0,16(sp)
    80002c84:	e426                	sd	s1,8(sp)
    80002c86:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c88:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002c8c:	00074d63          	bltz	a4,80002ca6 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002c90:	57fd                	li	a5,-1
    80002c92:	17fe                	slli	a5,a5,0x3f
    80002c94:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002c96:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002c98:	06f70363          	beq	a4,a5,80002cfe <devintr+0x80>
  }
}
    80002c9c:	60e2                	ld	ra,24(sp)
    80002c9e:	6442                	ld	s0,16(sp)
    80002ca0:	64a2                	ld	s1,8(sp)
    80002ca2:	6105                	addi	sp,sp,32
    80002ca4:	8082                	ret
     (scause & 0xff) == 9){
    80002ca6:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002caa:	46a5                	li	a3,9
    80002cac:	fed792e3          	bne	a5,a3,80002c90 <devintr+0x12>
    int irq = plic_claim();
    80002cb0:	00003097          	auipc	ra,0x3
    80002cb4:	628080e7          	jalr	1576(ra) # 800062d8 <plic_claim>
    80002cb8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002cba:	47a9                	li	a5,10
    80002cbc:	02f50763          	beq	a0,a5,80002cea <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002cc0:	4785                	li	a5,1
    80002cc2:	02f50963          	beq	a0,a5,80002cf4 <devintr+0x76>
    return 1;
    80002cc6:	4505                	li	a0,1
    } else if(irq){
    80002cc8:	d8f1                	beqz	s1,80002c9c <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002cca:	85a6                	mv	a1,s1
    80002ccc:	00005517          	auipc	a0,0x5
    80002cd0:	72450513          	addi	a0,a0,1828 # 800083f0 <states.0+0x38>
    80002cd4:	ffffe097          	auipc	ra,0xffffe
    80002cd8:	8a0080e7          	jalr	-1888(ra) # 80000574 <printf>
      plic_complete(irq);
    80002cdc:	8526                	mv	a0,s1
    80002cde:	00003097          	auipc	ra,0x3
    80002ce2:	61e080e7          	jalr	1566(ra) # 800062fc <plic_complete>
    return 1;
    80002ce6:	4505                	li	a0,1
    80002ce8:	bf55                	j	80002c9c <devintr+0x1e>
      uartintr();
    80002cea:	ffffe097          	auipc	ra,0xffffe
    80002cee:	c9c080e7          	jalr	-868(ra) # 80000986 <uartintr>
    80002cf2:	b7ed                	j	80002cdc <devintr+0x5e>
      virtio_disk_intr();
    80002cf4:	00004097          	auipc	ra,0x4
    80002cf8:	a9a080e7          	jalr	-1382(ra) # 8000678e <virtio_disk_intr>
    80002cfc:	b7c5                	j	80002cdc <devintr+0x5e>
    if(cpuid() == 0){
    80002cfe:	fffff097          	auipc	ra,0xfffff
    80002d02:	c54080e7          	jalr	-940(ra) # 80001952 <cpuid>
    80002d06:	c901                	beqz	a0,80002d16 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002d08:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002d0c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002d0e:	14479073          	csrw	sip,a5
    return 2;
    80002d12:	4509                	li	a0,2
    80002d14:	b761                	j	80002c9c <devintr+0x1e>
      clockintr();
    80002d16:	00000097          	auipc	ra,0x0
    80002d1a:	f14080e7          	jalr	-236(ra) # 80002c2a <clockintr>
    80002d1e:	b7ed                	j	80002d08 <devintr+0x8a>

0000000080002d20 <usertrap>:
{
    80002d20:	1101                	addi	sp,sp,-32
    80002d22:	ec06                	sd	ra,24(sp)
    80002d24:	e822                	sd	s0,16(sp)
    80002d26:	e426                	sd	s1,8(sp)
    80002d28:	e04a                	sd	s2,0(sp)
    80002d2a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d2c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002d30:	1007f793          	andi	a5,a5,256
    80002d34:	e3ad                	bnez	a5,80002d96 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d36:	00003797          	auipc	a5,0x3
    80002d3a:	49a78793          	addi	a5,a5,1178 # 800061d0 <kernelvec>
    80002d3e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002d42:	fffff097          	auipc	ra,0xfffff
    80002d46:	c3c080e7          	jalr	-964(ra) # 8000197e <myproc>
    80002d4a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002d4c:	615c                	ld	a5,128(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d4e:	14102773          	csrr	a4,sepc
    80002d52:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d54:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002d58:	47a1                	li	a5,8
    80002d5a:	04f71c63          	bne	a4,a5,80002db2 <usertrap+0x92>
    if(p->killed)
    80002d5e:	551c                	lw	a5,40(a0)
    80002d60:	e3b9                	bnez	a5,80002da6 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002d62:	60d8                	ld	a4,128(s1)
    80002d64:	6f1c                	ld	a5,24(a4)
    80002d66:	0791                	addi	a5,a5,4
    80002d68:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d6a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d6e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d72:	10079073          	csrw	sstatus,a5
    syscall();
    80002d76:	00000097          	auipc	ra,0x0
    80002d7a:	380080e7          	jalr	896(ra) # 800030f6 <syscall>
  if(p->killed)
    80002d7e:	549c                	lw	a5,40(s1)
    80002d80:	e3dd                	bnez	a5,80002e26 <usertrap+0x106>
  usertrapret();
    80002d82:	00000097          	auipc	ra,0x0
    80002d86:	e0a080e7          	jalr	-502(ra) # 80002b8c <usertrapret>
}
    80002d8a:	60e2                	ld	ra,24(sp)
    80002d8c:	6442                	ld	s0,16(sp)
    80002d8e:	64a2                	ld	s1,8(sp)
    80002d90:	6902                	ld	s2,0(sp)
    80002d92:	6105                	addi	sp,sp,32
    80002d94:	8082                	ret
    panic("usertrap: not from user mode");
    80002d96:	00005517          	auipc	a0,0x5
    80002d9a:	67a50513          	addi	a0,a0,1658 # 80008410 <states.0+0x58>
    80002d9e:	ffffd097          	auipc	ra,0xffffd
    80002da2:	78c080e7          	jalr	1932(ra) # 8000052a <panic>
      exit(-1);
    80002da6:	557d                	li	a0,-1
    80002da8:	fffff097          	auipc	ra,0xfffff
    80002dac:	7c6080e7          	jalr	1990(ra) # 8000256e <exit>
    80002db0:	bf4d                	j	80002d62 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002db2:	00000097          	auipc	ra,0x0
    80002db6:	ecc080e7          	jalr	-308(ra) # 80002c7e <devintr>
    80002dba:	892a                	mv	s2,a0
    80002dbc:	c501                	beqz	a0,80002dc4 <usertrap+0xa4>
  if(p->killed)
    80002dbe:	549c                	lw	a5,40(s1)
    80002dc0:	c3a1                	beqz	a5,80002e00 <usertrap+0xe0>
    80002dc2:	a815                	j	80002df6 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002dc4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002dc8:	5890                	lw	a2,48(s1)
    80002dca:	00005517          	auipc	a0,0x5
    80002dce:	66650513          	addi	a0,a0,1638 # 80008430 <states.0+0x78>
    80002dd2:	ffffd097          	auipc	ra,0xffffd
    80002dd6:	7a2080e7          	jalr	1954(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dda:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002dde:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002de2:	00005517          	auipc	a0,0x5
    80002de6:	67e50513          	addi	a0,a0,1662 # 80008460 <states.0+0xa8>
    80002dea:	ffffd097          	auipc	ra,0xffffd
    80002dee:	78a080e7          	jalr	1930(ra) # 80000574 <printf>
    p->killed = 1;
    80002df2:	4785                	li	a5,1
    80002df4:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002df6:	557d                	li	a0,-1
    80002df8:	fffff097          	auipc	ra,0xfffff
    80002dfc:	776080e7          	jalr	1910(ra) # 8000256e <exit>
  if(which_dev == 2 && p->current_runtime >= QUANTUM && is_preemptive==1)
    80002e00:	4789                	li	a5,2
    80002e02:	f8f910e3          	bne	s2,a5,80002d82 <usertrap+0x62>
    80002e06:	48f8                	lw	a4,84(s1)
    80002e08:	4791                	li	a5,4
    80002e0a:	f6e7dce3          	bge	a5,a4,80002d82 <usertrap+0x62>
    80002e0e:	00006717          	auipc	a4,0x6
    80002e12:	cf672703          	lw	a4,-778(a4) # 80008b04 <is_preemptive>
    80002e16:	4785                	li	a5,1
    80002e18:	f6f715e3          	bne	a4,a5,80002d82 <usertrap+0x62>
    yield();
    80002e1c:	fffff097          	auipc	ra,0xfffff
    80002e20:	49e080e7          	jalr	1182(ra) # 800022ba <yield>
    80002e24:	bfb9                	j	80002d82 <usertrap+0x62>
  int which_dev = 0;
    80002e26:	4901                	li	s2,0
    80002e28:	b7f9                	j	80002df6 <usertrap+0xd6>

0000000080002e2a <kerneltrap>:
{
    80002e2a:	7179                	addi	sp,sp,-48
    80002e2c:	f406                	sd	ra,40(sp)
    80002e2e:	f022                	sd	s0,32(sp)
    80002e30:	ec26                	sd	s1,24(sp)
    80002e32:	e84a                	sd	s2,16(sp)
    80002e34:	e44e                	sd	s3,8(sp)
    80002e36:	e052                	sd	s4,0(sp)
    80002e38:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e3a:	141029f3          	csrr	s3,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e3e:	10002973          	csrr	s2,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e42:	14202a73          	csrr	s4,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002e46:	10097793          	andi	a5,s2,256
    80002e4a:	cf95                	beqz	a5,80002e86 <kerneltrap+0x5c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e4c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002e50:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002e52:	e3b1                	bnez	a5,80002e96 <kerneltrap+0x6c>
  if((which_dev = devintr()) == 0){
    80002e54:	00000097          	auipc	ra,0x0
    80002e58:	e2a080e7          	jalr	-470(ra) # 80002c7e <devintr>
    80002e5c:	84aa                	mv	s1,a0
    80002e5e:	c521                	beqz	a0,80002ea6 <kerneltrap+0x7c>
  struct proc *p = myproc();
    80002e60:	fffff097          	auipc	ra,0xfffff
    80002e64:	b1e080e7          	jalr	-1250(ra) # 8000197e <myproc>
  if(which_dev == 2 && p != 0 && p->state == RUNNING && p->current_runtime >= QUANTUM && is_preemptive==1)
    80002e68:	4789                	li	a5,2
    80002e6a:	06f48b63          	beq	s1,a5,80002ee0 <kerneltrap+0xb6>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e6e:	14199073          	csrw	sepc,s3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e72:	10091073          	csrw	sstatus,s2
}
    80002e76:	70a2                	ld	ra,40(sp)
    80002e78:	7402                	ld	s0,32(sp)
    80002e7a:	64e2                	ld	s1,24(sp)
    80002e7c:	6942                	ld	s2,16(sp)
    80002e7e:	69a2                	ld	s3,8(sp)
    80002e80:	6a02                	ld	s4,0(sp)
    80002e82:	6145                	addi	sp,sp,48
    80002e84:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002e86:	00005517          	auipc	a0,0x5
    80002e8a:	5fa50513          	addi	a0,a0,1530 # 80008480 <states.0+0xc8>
    80002e8e:	ffffd097          	auipc	ra,0xffffd
    80002e92:	69c080e7          	jalr	1692(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80002e96:	00005517          	auipc	a0,0x5
    80002e9a:	61250513          	addi	a0,a0,1554 # 800084a8 <states.0+0xf0>
    80002e9e:	ffffd097          	auipc	ra,0xffffd
    80002ea2:	68c080e7          	jalr	1676(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80002ea6:	85d2                	mv	a1,s4
    80002ea8:	00005517          	auipc	a0,0x5
    80002eac:	62050513          	addi	a0,a0,1568 # 800084c8 <states.0+0x110>
    80002eb0:	ffffd097          	auipc	ra,0xffffd
    80002eb4:	6c4080e7          	jalr	1732(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002eb8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ebc:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ec0:	00005517          	auipc	a0,0x5
    80002ec4:	61850513          	addi	a0,a0,1560 # 800084d8 <states.0+0x120>
    80002ec8:	ffffd097          	auipc	ra,0xffffd
    80002ecc:	6ac080e7          	jalr	1708(ra) # 80000574 <printf>
    panic("kerneltrap");
    80002ed0:	00005517          	auipc	a0,0x5
    80002ed4:	62050513          	addi	a0,a0,1568 # 800084f0 <states.0+0x138>
    80002ed8:	ffffd097          	auipc	ra,0xffffd
    80002edc:	652080e7          	jalr	1618(ra) # 8000052a <panic>
  if(which_dev == 2 && p != 0 && p->state == RUNNING && p->current_runtime >= QUANTUM && is_preemptive==1)
    80002ee0:	d559                	beqz	a0,80002e6e <kerneltrap+0x44>
    80002ee2:	4d18                	lw	a4,24(a0)
    80002ee4:	4791                	li	a5,4
    80002ee6:	f8f714e3          	bne	a4,a5,80002e6e <kerneltrap+0x44>
    80002eea:	4978                	lw	a4,84(a0)
    80002eec:	f8e7d1e3          	bge	a5,a4,80002e6e <kerneltrap+0x44>
    80002ef0:	00006717          	auipc	a4,0x6
    80002ef4:	c1472703          	lw	a4,-1004(a4) # 80008b04 <is_preemptive>
    80002ef8:	4785                	li	a5,1
    80002efa:	f6f71ae3          	bne	a4,a5,80002e6e <kerneltrap+0x44>
    yield();
    80002efe:	fffff097          	auipc	ra,0xfffff
    80002f02:	3bc080e7          	jalr	956(ra) # 800022ba <yield>
    80002f06:	b7a5                	j	80002e6e <kerneltrap+0x44>

0000000080002f08 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002f08:	1101                	addi	sp,sp,-32
    80002f0a:	ec06                	sd	ra,24(sp)
    80002f0c:	e822                	sd	s0,16(sp)
    80002f0e:	e426                	sd	s1,8(sp)
    80002f10:	1000                	addi	s0,sp,32
    80002f12:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002f14:	fffff097          	auipc	ra,0xfffff
    80002f18:	a6a080e7          	jalr	-1430(ra) # 8000197e <myproc>
  switch (n) {
    80002f1c:	4795                	li	a5,5
    80002f1e:	0497e163          	bltu	a5,s1,80002f60 <argraw+0x58>
    80002f22:	048a                	slli	s1,s1,0x2
    80002f24:	00005717          	auipc	a4,0x5
    80002f28:	72470713          	addi	a4,a4,1828 # 80008648 <states.0+0x290>
    80002f2c:	94ba                	add	s1,s1,a4
    80002f2e:	409c                	lw	a5,0(s1)
    80002f30:	97ba                	add	a5,a5,a4
    80002f32:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002f34:	615c                	ld	a5,128(a0)
    80002f36:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002f38:	60e2                	ld	ra,24(sp)
    80002f3a:	6442                	ld	s0,16(sp)
    80002f3c:	64a2                	ld	s1,8(sp)
    80002f3e:	6105                	addi	sp,sp,32
    80002f40:	8082                	ret
    return p->trapframe->a1;
    80002f42:	615c                	ld	a5,128(a0)
    80002f44:	7fa8                	ld	a0,120(a5)
    80002f46:	bfcd                	j	80002f38 <argraw+0x30>
    return p->trapframe->a2;
    80002f48:	615c                	ld	a5,128(a0)
    80002f4a:	63c8                	ld	a0,128(a5)
    80002f4c:	b7f5                	j	80002f38 <argraw+0x30>
    return p->trapframe->a3;
    80002f4e:	615c                	ld	a5,128(a0)
    80002f50:	67c8                	ld	a0,136(a5)
    80002f52:	b7dd                	j	80002f38 <argraw+0x30>
    return p->trapframe->a4;
    80002f54:	615c                	ld	a5,128(a0)
    80002f56:	6bc8                	ld	a0,144(a5)
    80002f58:	b7c5                	j	80002f38 <argraw+0x30>
    return p->trapframe->a5;
    80002f5a:	615c                	ld	a5,128(a0)
    80002f5c:	6fc8                	ld	a0,152(a5)
    80002f5e:	bfe9                	j	80002f38 <argraw+0x30>
  panic("argraw");
    80002f60:	00005517          	auipc	a0,0x5
    80002f64:	5a050513          	addi	a0,a0,1440 # 80008500 <states.0+0x148>
    80002f68:	ffffd097          	auipc	ra,0xffffd
    80002f6c:	5c2080e7          	jalr	1474(ra) # 8000052a <panic>

0000000080002f70 <fetchaddr>:
{
    80002f70:	1101                	addi	sp,sp,-32
    80002f72:	ec06                	sd	ra,24(sp)
    80002f74:	e822                	sd	s0,16(sp)
    80002f76:	e426                	sd	s1,8(sp)
    80002f78:	e04a                	sd	s2,0(sp)
    80002f7a:	1000                	addi	s0,sp,32
    80002f7c:	84aa                	mv	s1,a0
    80002f7e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002f80:	fffff097          	auipc	ra,0xfffff
    80002f84:	9fe080e7          	jalr	-1538(ra) # 8000197e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002f88:	793c                	ld	a5,112(a0)
    80002f8a:	02f4f863          	bgeu	s1,a5,80002fba <fetchaddr+0x4a>
    80002f8e:	00848713          	addi	a4,s1,8
    80002f92:	02e7e663          	bltu	a5,a4,80002fbe <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002f96:	46a1                	li	a3,8
    80002f98:	8626                	mv	a2,s1
    80002f9a:	85ca                	mv	a1,s2
    80002f9c:	7d28                	ld	a0,120(a0)
    80002f9e:	ffffe097          	auipc	ra,0xffffe
    80002fa2:	72c080e7          	jalr	1836(ra) # 800016ca <copyin>
    80002fa6:	00a03533          	snez	a0,a0
    80002faa:	40a00533          	neg	a0,a0
}
    80002fae:	60e2                	ld	ra,24(sp)
    80002fb0:	6442                	ld	s0,16(sp)
    80002fb2:	64a2                	ld	s1,8(sp)
    80002fb4:	6902                	ld	s2,0(sp)
    80002fb6:	6105                	addi	sp,sp,32
    80002fb8:	8082                	ret
    return -1;
    80002fba:	557d                	li	a0,-1
    80002fbc:	bfcd                	j	80002fae <fetchaddr+0x3e>
    80002fbe:	557d                	li	a0,-1
    80002fc0:	b7fd                	j	80002fae <fetchaddr+0x3e>

0000000080002fc2 <fetchstr>:
{
    80002fc2:	7179                	addi	sp,sp,-48
    80002fc4:	f406                	sd	ra,40(sp)
    80002fc6:	f022                	sd	s0,32(sp)
    80002fc8:	ec26                	sd	s1,24(sp)
    80002fca:	e84a                	sd	s2,16(sp)
    80002fcc:	e44e                	sd	s3,8(sp)
    80002fce:	1800                	addi	s0,sp,48
    80002fd0:	892a                	mv	s2,a0
    80002fd2:	84ae                	mv	s1,a1
    80002fd4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002fd6:	fffff097          	auipc	ra,0xfffff
    80002fda:	9a8080e7          	jalr	-1624(ra) # 8000197e <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002fde:	86ce                	mv	a3,s3
    80002fe0:	864a                	mv	a2,s2
    80002fe2:	85a6                	mv	a1,s1
    80002fe4:	7d28                	ld	a0,120(a0)
    80002fe6:	ffffe097          	auipc	ra,0xffffe
    80002fea:	772080e7          	jalr	1906(ra) # 80001758 <copyinstr>
  if(err < 0)
    80002fee:	00054763          	bltz	a0,80002ffc <fetchstr+0x3a>
  return strlen(buf);
    80002ff2:	8526                	mv	a0,s1
    80002ff4:	ffffe097          	auipc	ra,0xffffe
    80002ff8:	e4e080e7          	jalr	-434(ra) # 80000e42 <strlen>
}
    80002ffc:	70a2                	ld	ra,40(sp)
    80002ffe:	7402                	ld	s0,32(sp)
    80003000:	64e2                	ld	s1,24(sp)
    80003002:	6942                	ld	s2,16(sp)
    80003004:	69a2                	ld	s3,8(sp)
    80003006:	6145                	addi	sp,sp,48
    80003008:	8082                	ret

000000008000300a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    8000300a:	1101                	addi	sp,sp,-32
    8000300c:	ec06                	sd	ra,24(sp)
    8000300e:	e822                	sd	s0,16(sp)
    80003010:	e426                	sd	s1,8(sp)
    80003012:	1000                	addi	s0,sp,32
    80003014:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003016:	00000097          	auipc	ra,0x0
    8000301a:	ef2080e7          	jalr	-270(ra) # 80002f08 <argraw>
    8000301e:	c088                	sw	a0,0(s1)
  return 0;
}
    80003020:	4501                	li	a0,0
    80003022:	60e2                	ld	ra,24(sp)
    80003024:	6442                	ld	s0,16(sp)
    80003026:	64a2                	ld	s1,8(sp)
    80003028:	6105                	addi	sp,sp,32
    8000302a:	8082                	ret

000000008000302c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    8000302c:	1101                	addi	sp,sp,-32
    8000302e:	ec06                	sd	ra,24(sp)
    80003030:	e822                	sd	s0,16(sp)
    80003032:	e426                	sd	s1,8(sp)
    80003034:	1000                	addi	s0,sp,32
    80003036:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003038:	00000097          	auipc	ra,0x0
    8000303c:	ed0080e7          	jalr	-304(ra) # 80002f08 <argraw>
    80003040:	e088                	sd	a0,0(s1)
  return 0;
}
    80003042:	4501                	li	a0,0
    80003044:	60e2                	ld	ra,24(sp)
    80003046:	6442                	ld	s0,16(sp)
    80003048:	64a2                	ld	s1,8(sp)
    8000304a:	6105                	addi	sp,sp,32
    8000304c:	8082                	ret

000000008000304e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000304e:	1101                	addi	sp,sp,-32
    80003050:	ec06                	sd	ra,24(sp)
    80003052:	e822                	sd	s0,16(sp)
    80003054:	e426                	sd	s1,8(sp)
    80003056:	e04a                	sd	s2,0(sp)
    80003058:	1000                	addi	s0,sp,32
    8000305a:	84ae                	mv	s1,a1
    8000305c:	8932                	mv	s2,a2
  *ip = argraw(n);
    8000305e:	00000097          	auipc	ra,0x0
    80003062:	eaa080e7          	jalr	-342(ra) # 80002f08 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003066:	864a                	mv	a2,s2
    80003068:	85a6                	mv	a1,s1
    8000306a:	00000097          	auipc	ra,0x0
    8000306e:	f58080e7          	jalr	-168(ra) # 80002fc2 <fetchstr>
}
    80003072:	60e2                	ld	ra,24(sp)
    80003074:	6442                	ld	s0,16(sp)
    80003076:	64a2                	ld	s1,8(sp)
    80003078:	6902                	ld	s2,0(sp)
    8000307a:	6105                	addi	sp,sp,32
    8000307c:	8082                	ret

000000008000307e <printtrace>:
[SYS_set_priority] "set_priority",
};


int 
printtrace(int syscallnum,int pid, uint64 ret, int arg){
    8000307e:	1141                	addi	sp,sp,-16
    80003080:	e406                	sd	ra,8(sp)
    80003082:	e022                	sd	s0,0(sp)
    80003084:	0800                	addi	s0,sp,16
  if(syscallnum == SYS_fork){
    80003086:	4785                	li	a5,1
    80003088:	02f50d63          	beq	a0,a5,800030c2 <printtrace+0x44>
    printf("%d: syscall fork NULL -> %d\n",pid,ret);
  }
  else if(syscallnum == SYS_kill || syscallnum == SYS_sbrk){  
    8000308c:	4799                	li	a5,6
    8000308e:	00f50563          	beq	a0,a5,80003098 <printtrace+0x1a>
    80003092:	47b1                	li	a5,12
    80003094:	04f51063          	bne	a0,a5,800030d4 <printtrace+0x56>
    printf("%d: syscall %s %d -> %d\n",pid,syscallnames[syscallnum], arg, ret);
    80003098:	050e                	slli	a0,a0,0x3
    8000309a:	00005797          	auipc	a5,0x5
    8000309e:	5c678793          	addi	a5,a5,1478 # 80008660 <syscallnames>
    800030a2:	953e                	add	a0,a0,a5
    800030a4:	8732                	mv	a4,a2
    800030a6:	6110                	ld	a2,0(a0)
    800030a8:	00005517          	auipc	a0,0x5
    800030ac:	48050513          	addi	a0,a0,1152 # 80008528 <states.0+0x170>
    800030b0:	ffffd097          	auipc	ra,0xffffd
    800030b4:	4c4080e7          	jalr	1220(ra) # 80000574 <printf>
  }
  else{
    printf("%d: syscall %s -> %d\n",pid,syscallnames[syscallnum],ret);
  }
  return 0;   
}
    800030b8:	4501                	li	a0,0
    800030ba:	60a2                	ld	ra,8(sp)
    800030bc:	6402                	ld	s0,0(sp)
    800030be:	0141                	addi	sp,sp,16
    800030c0:	8082                	ret
    printf("%d: syscall fork NULL -> %d\n",pid,ret);
    800030c2:	00005517          	auipc	a0,0x5
    800030c6:	44650513          	addi	a0,a0,1094 # 80008508 <states.0+0x150>
    800030ca:	ffffd097          	auipc	ra,0xffffd
    800030ce:	4aa080e7          	jalr	1194(ra) # 80000574 <printf>
    800030d2:	b7dd                	j	800030b8 <printtrace+0x3a>
    printf("%d: syscall %s -> %d\n",pid,syscallnames[syscallnum],ret);
    800030d4:	050e                	slli	a0,a0,0x3
    800030d6:	00005797          	auipc	a5,0x5
    800030da:	58a78793          	addi	a5,a5,1418 # 80008660 <syscallnames>
    800030de:	953e                	add	a0,a0,a5
    800030e0:	86b2                	mv	a3,a2
    800030e2:	6110                	ld	a2,0(a0)
    800030e4:	00005517          	auipc	a0,0x5
    800030e8:	46450513          	addi	a0,a0,1124 # 80008548 <states.0+0x190>
    800030ec:	ffffd097          	auipc	ra,0xffffd
    800030f0:	488080e7          	jalr	1160(ra) # 80000574 <printf>
    800030f4:	b7d1                	j	800030b8 <printtrace+0x3a>

00000000800030f6 <syscall>:


void
syscall(void)
{
    800030f6:	715d                	addi	sp,sp,-80
    800030f8:	e486                	sd	ra,72(sp)
    800030fa:	e0a2                	sd	s0,64(sp)
    800030fc:	fc26                	sd	s1,56(sp)
    800030fe:	f84a                	sd	s2,48(sp)
    80003100:	f44e                	sd	s3,40(sp)
    80003102:	f052                	sd	s4,32(sp)
    80003104:	ec56                	sd	s5,24(sp)
    80003106:	0880                	addi	s0,sp,80
  int num;
  struct proc *p = myproc();
    80003108:	fffff097          	auipc	ra,0xfffff
    8000310c:	876080e7          	jalr	-1930(ra) # 8000197e <myproc>
    80003110:	84aa                	mv	s1,a0
  int tracemask = p->tracemask;

  num = p->trapframe->a7;
    80003112:	615c                	ld	a5,128(a0)
    80003114:	77dc                	ld	a5,168(a5)
    80003116:	0007891b          	sext.w	s2,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000311a:	37fd                	addiw	a5,a5,-1
    8000311c:	475d                	li	a4,23
    8000311e:	04f76c63          	bltu	a4,a5,80003176 <syscall+0x80>
    80003122:	00391713          	slli	a4,s2,0x3
    80003126:	00005797          	auipc	a5,0x5
    8000312a:	53a78793          	addi	a5,a5,1338 # 80008660 <syscallnames>
    8000312e:	97ba                	add	a5,a5,a4
    80003130:	0c87ba03          	ld	s4,200(a5)
    80003134:	040a0163          	beqz	s4,80003176 <syscall+0x80>
  int tracemask = p->tracemask;
    80003138:	03452983          	lw	s3,52(a0)
    int arg;
    argint(0, &arg);
    8000313c:	fbc40593          	addi	a1,s0,-68
    80003140:	4501                	li	a0,0
    80003142:	00000097          	auipc	ra,0x0
    80003146:	ec8080e7          	jalr	-312(ra) # 8000300a <argint>

    p->trapframe->a0 = syscalls[num]();
    8000314a:	0804ba83          	ld	s5,128(s1)
    8000314e:	9a02                	jalr	s4
    80003150:	06aab823          	sd	a0,112(s5)

    if(tracemask & (1<<num)){
    80003154:	4129d9bb          	sraw	s3,s3,s2
    80003158:	0019f993          	andi	s3,s3,1
    8000315c:	02098c63          	beqz	s3,80003194 <syscall+0x9e>
      printtrace(num,p->pid,p->trapframe->a0,arg);
    80003160:	60dc                	ld	a5,128(s1)
    80003162:	fbc42683          	lw	a3,-68(s0)
    80003166:	7bb0                	ld	a2,112(a5)
    80003168:	588c                	lw	a1,48(s1)
    8000316a:	854a                	mv	a0,s2
    8000316c:	00000097          	auipc	ra,0x0
    80003170:	f12080e7          	jalr	-238(ra) # 8000307e <printtrace>
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003174:	a005                	j	80003194 <syscall+0x9e>
    }
    
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003176:	86ca                	mv	a3,s2
    80003178:	18048613          	addi	a2,s1,384
    8000317c:	588c                	lw	a1,48(s1)
    8000317e:	00005517          	auipc	a0,0x5
    80003182:	3e250513          	addi	a0,a0,994 # 80008560 <states.0+0x1a8>
    80003186:	ffffd097          	auipc	ra,0xffffd
    8000318a:	3ee080e7          	jalr	1006(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000318e:	60dc                	ld	a5,128(s1)
    80003190:	577d                	li	a4,-1
    80003192:	fbb8                	sd	a4,112(a5)
  }
}
    80003194:	60a6                	ld	ra,72(sp)
    80003196:	6406                	ld	s0,64(sp)
    80003198:	74e2                	ld	s1,56(sp)
    8000319a:	7942                	ld	s2,48(sp)
    8000319c:	79a2                	ld	s3,40(sp)
    8000319e:	7a02                	ld	s4,32(sp)
    800031a0:	6ae2                	ld	s5,24(sp)
    800031a2:	6161                	addi	sp,sp,80
    800031a4:	8082                	ret

00000000800031a6 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800031a6:	1101                	addi	sp,sp,-32
    800031a8:	ec06                	sd	ra,24(sp)
    800031aa:	e822                	sd	s0,16(sp)
    800031ac:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800031ae:	fec40593          	addi	a1,s0,-20
    800031b2:	4501                	li	a0,0
    800031b4:	00000097          	auipc	ra,0x0
    800031b8:	e56080e7          	jalr	-426(ra) # 8000300a <argint>
    return -1;
    800031bc:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800031be:	00054963          	bltz	a0,800031d0 <sys_exit+0x2a>
  exit(n);
    800031c2:	fec42503          	lw	a0,-20(s0)
    800031c6:	fffff097          	auipc	ra,0xfffff
    800031ca:	3a8080e7          	jalr	936(ra) # 8000256e <exit>
  return 0;  // not reached
    800031ce:	4781                	li	a5,0
}
    800031d0:	853e                	mv	a0,a5
    800031d2:	60e2                	ld	ra,24(sp)
    800031d4:	6442                	ld	s0,16(sp)
    800031d6:	6105                	addi	sp,sp,32
    800031d8:	8082                	ret

00000000800031da <sys_getpid>:

uint64
sys_getpid(void)
{
    800031da:	1141                	addi	sp,sp,-16
    800031dc:	e406                	sd	ra,8(sp)
    800031de:	e022                	sd	s0,0(sp)
    800031e0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800031e2:	ffffe097          	auipc	ra,0xffffe
    800031e6:	79c080e7          	jalr	1948(ra) # 8000197e <myproc>
}
    800031ea:	5908                	lw	a0,48(a0)
    800031ec:	60a2                	ld	ra,8(sp)
    800031ee:	6402                	ld	s0,0(sp)
    800031f0:	0141                	addi	sp,sp,16
    800031f2:	8082                	ret

00000000800031f4 <sys_fork>:

uint64
sys_fork(void)
{
    800031f4:	1141                	addi	sp,sp,-16
    800031f6:	e406                	sd	ra,8(sp)
    800031f8:	e022                	sd	s0,0(sp)
    800031fa:	0800                	addi	s0,sp,16
  return fork();
    800031fc:	fffff097          	auipc	ra,0xfffff
    80003200:	bea080e7          	jalr	-1046(ra) # 80001de6 <fork>
}
    80003204:	60a2                	ld	ra,8(sp)
    80003206:	6402                	ld	s0,0(sp)
    80003208:	0141                	addi	sp,sp,16
    8000320a:	8082                	ret

000000008000320c <sys_wait>:

uint64
sys_wait(void)
{
    8000320c:	1101                	addi	sp,sp,-32
    8000320e:	ec06                	sd	ra,24(sp)
    80003210:	e822                	sd	s0,16(sp)
    80003212:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003214:	fe840593          	addi	a1,s0,-24
    80003218:	4501                	li	a0,0
    8000321a:	00000097          	auipc	ra,0x0
    8000321e:	e12080e7          	jalr	-494(ra) # 8000302c <argaddr>
    80003222:	87aa                	mv	a5,a0
    return -1;
    80003224:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003226:	0007c863          	bltz	a5,80003236 <sys_wait+0x2a>
  return wait(p);
    8000322a:	fe843503          	ld	a0,-24(s0)
    8000322e:	fffff097          	auipc	ra,0xfffff
    80003232:	136080e7          	jalr	310(ra) # 80002364 <wait>
}
    80003236:	60e2                	ld	ra,24(sp)
    80003238:	6442                	ld	s0,16(sp)
    8000323a:	6105                	addi	sp,sp,32
    8000323c:	8082                	ret

000000008000323e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000323e:	7179                	addi	sp,sp,-48
    80003240:	f406                	sd	ra,40(sp)
    80003242:	f022                	sd	s0,32(sp)
    80003244:	ec26                	sd	s1,24(sp)
    80003246:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003248:	fdc40593          	addi	a1,s0,-36
    8000324c:	4501                	li	a0,0
    8000324e:	00000097          	auipc	ra,0x0
    80003252:	dbc080e7          	jalr	-580(ra) # 8000300a <argint>
    return -1;
    80003256:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003258:	00054f63          	bltz	a0,80003276 <sys_sbrk+0x38>
  addr = myproc()->sz;
    8000325c:	ffffe097          	auipc	ra,0xffffe
    80003260:	722080e7          	jalr	1826(ra) # 8000197e <myproc>
    80003264:	5924                	lw	s1,112(a0)
  if(growproc(n) < 0)
    80003266:	fdc42503          	lw	a0,-36(s0)
    8000326a:	fffff097          	auipc	ra,0xfffff
    8000326e:	ae4080e7          	jalr	-1308(ra) # 80001d4e <growproc>
    80003272:	00054863          	bltz	a0,80003282 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003276:	8526                	mv	a0,s1
    80003278:	70a2                	ld	ra,40(sp)
    8000327a:	7402                	ld	s0,32(sp)
    8000327c:	64e2                	ld	s1,24(sp)
    8000327e:	6145                	addi	sp,sp,48
    80003280:	8082                	ret
    return -1;
    80003282:	54fd                	li	s1,-1
    80003284:	bfcd                	j	80003276 <sys_sbrk+0x38>

0000000080003286 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003286:	7139                	addi	sp,sp,-64
    80003288:	fc06                	sd	ra,56(sp)
    8000328a:	f822                	sd	s0,48(sp)
    8000328c:	f426                	sd	s1,40(sp)
    8000328e:	f04a                	sd	s2,32(sp)
    80003290:	ec4e                	sd	s3,24(sp)
    80003292:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003294:	fcc40593          	addi	a1,s0,-52
    80003298:	4501                	li	a0,0
    8000329a:	00000097          	auipc	ra,0x0
    8000329e:	d70080e7          	jalr	-656(ra) # 8000300a <argint>
    return -1;
    800032a2:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800032a4:	06054563          	bltz	a0,8000330e <sys_sleep+0x88>
  acquire(&tickslock);
    800032a8:	00015517          	auipc	a0,0x15
    800032ac:	82850513          	addi	a0,a0,-2008 # 80017ad0 <tickslock>
    800032b0:	ffffe097          	auipc	ra,0xffffe
    800032b4:	912080e7          	jalr	-1774(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    800032b8:	00006917          	auipc	s2,0x6
    800032bc:	d7892903          	lw	s2,-648(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    800032c0:	fcc42783          	lw	a5,-52(s0)
    800032c4:	cf85                	beqz	a5,800032fc <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800032c6:	00015997          	auipc	s3,0x15
    800032ca:	80a98993          	addi	s3,s3,-2038 # 80017ad0 <tickslock>
    800032ce:	00006497          	auipc	s1,0x6
    800032d2:	d6248493          	addi	s1,s1,-670 # 80009030 <ticks>
    if(myproc()->killed){
    800032d6:	ffffe097          	auipc	ra,0xffffe
    800032da:	6a8080e7          	jalr	1704(ra) # 8000197e <myproc>
    800032de:	551c                	lw	a5,40(a0)
    800032e0:	ef9d                	bnez	a5,8000331e <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    800032e2:	85ce                	mv	a1,s3
    800032e4:	8526                	mv	a0,s1
    800032e6:	fffff097          	auipc	ra,0xfffff
    800032ea:	01a080e7          	jalr	26(ra) # 80002300 <sleep>
  while(ticks - ticks0 < n){
    800032ee:	409c                	lw	a5,0(s1)
    800032f0:	412787bb          	subw	a5,a5,s2
    800032f4:	fcc42703          	lw	a4,-52(s0)
    800032f8:	fce7efe3          	bltu	a5,a4,800032d6 <sys_sleep+0x50>
  }
  release(&tickslock);
    800032fc:	00014517          	auipc	a0,0x14
    80003300:	7d450513          	addi	a0,a0,2004 # 80017ad0 <tickslock>
    80003304:	ffffe097          	auipc	ra,0xffffe
    80003308:	972080e7          	jalr	-1678(ra) # 80000c76 <release>
  return 0;
    8000330c:	4781                	li	a5,0
}
    8000330e:	853e                	mv	a0,a5
    80003310:	70e2                	ld	ra,56(sp)
    80003312:	7442                	ld	s0,48(sp)
    80003314:	74a2                	ld	s1,40(sp)
    80003316:	7902                	ld	s2,32(sp)
    80003318:	69e2                	ld	s3,24(sp)
    8000331a:	6121                	addi	sp,sp,64
    8000331c:	8082                	ret
      release(&tickslock);
    8000331e:	00014517          	auipc	a0,0x14
    80003322:	7b250513          	addi	a0,a0,1970 # 80017ad0 <tickslock>
    80003326:	ffffe097          	auipc	ra,0xffffe
    8000332a:	950080e7          	jalr	-1712(ra) # 80000c76 <release>
      return -1;
    8000332e:	57fd                	li	a5,-1
    80003330:	bff9                	j	8000330e <sys_sleep+0x88>

0000000080003332 <sys_kill>:

uint64
sys_kill(void)
{
    80003332:	1101                	addi	sp,sp,-32
    80003334:	ec06                	sd	ra,24(sp)
    80003336:	e822                	sd	s0,16(sp)
    80003338:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000333a:	fec40593          	addi	a1,s0,-20
    8000333e:	4501                	li	a0,0
    80003340:	00000097          	auipc	ra,0x0
    80003344:	cca080e7          	jalr	-822(ra) # 8000300a <argint>
    80003348:	87aa                	mv	a5,a0
    return -1;
    8000334a:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000334c:	0007c863          	bltz	a5,8000335c <sys_kill+0x2a>
  return kill(pid);
    80003350:	fec42503          	lw	a0,-20(s0)
    80003354:	fffff097          	auipc	ra,0xfffff
    80003358:	2fc080e7          	jalr	764(ra) # 80002650 <kill>
}
    8000335c:	60e2                	ld	ra,24(sp)
    8000335e:	6442                	ld	s0,16(sp)
    80003360:	6105                	addi	sp,sp,32
    80003362:	8082                	ret

0000000080003364 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003364:	1101                	addi	sp,sp,-32
    80003366:	ec06                	sd	ra,24(sp)
    80003368:	e822                	sd	s0,16(sp)
    8000336a:	e426                	sd	s1,8(sp)
    8000336c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000336e:	00014517          	auipc	a0,0x14
    80003372:	76250513          	addi	a0,a0,1890 # 80017ad0 <tickslock>
    80003376:	ffffe097          	auipc	ra,0xffffe
    8000337a:	84c080e7          	jalr	-1972(ra) # 80000bc2 <acquire>
  xticks = ticks;
    8000337e:	00006497          	auipc	s1,0x6
    80003382:	cb24a483          	lw	s1,-846(s1) # 80009030 <ticks>
  release(&tickslock);
    80003386:	00014517          	auipc	a0,0x14
    8000338a:	74a50513          	addi	a0,a0,1866 # 80017ad0 <tickslock>
    8000338e:	ffffe097          	auipc	ra,0xffffe
    80003392:	8e8080e7          	jalr	-1816(ra) # 80000c76 <release>
  return xticks;
}
    80003396:	02049513          	slli	a0,s1,0x20
    8000339a:	9101                	srli	a0,a0,0x20
    8000339c:	60e2                	ld	ra,24(sp)
    8000339e:	6442                	ld	s0,16(sp)
    800033a0:	64a2                	ld	s1,8(sp)
    800033a2:	6105                	addi	sp,sp,32
    800033a4:	8082                	ret

00000000800033a6 <sys_trace>:

uint64
sys_trace(void)
{
    800033a6:	1101                	addi	sp,sp,-32
    800033a8:	ec06                	sd	ra,24(sp)
    800033aa:	e822                	sd	s0,16(sp)
    800033ac:	1000                	addi	s0,sp,32
  int mask, pid;

  if(argint(0, &mask) < 0)
    800033ae:	fec40593          	addi	a1,s0,-20
    800033b2:	4501                	li	a0,0
    800033b4:	00000097          	auipc	ra,0x0
    800033b8:	c56080e7          	jalr	-938(ra) # 8000300a <argint>
    return -1;
    800033bc:	57fd                	li	a5,-1
  if(argint(0, &mask) < 0)
    800033be:	02054563          	bltz	a0,800033e8 <sys_trace+0x42>
  if(argint(1, &pid) < 0)
    800033c2:	fe840593          	addi	a1,s0,-24
    800033c6:	4505                	li	a0,1
    800033c8:	00000097          	auipc	ra,0x0
    800033cc:	c42080e7          	jalr	-958(ra) # 8000300a <argint>
    return -1;
    800033d0:	57fd                	li	a5,-1
  if(argint(1, &pid) < 0)
    800033d2:	00054b63          	bltz	a0,800033e8 <sys_trace+0x42>
  return trace(mask, pid);
    800033d6:	fe842583          	lw	a1,-24(s0)
    800033da:	fec42503          	lw	a0,-20(s0)
    800033de:	fffff097          	auipc	ra,0xfffff
    800033e2:	44a080e7          	jalr	1098(ra) # 80002828 <trace>
    800033e6:	87aa                	mv	a5,a0
}
    800033e8:	853e                	mv	a0,a5
    800033ea:	60e2                	ld	ra,24(sp)
    800033ec:	6442                	ld	s0,16(sp)
    800033ee:	6105                	addi	sp,sp,32
    800033f0:	8082                	ret

00000000800033f2 <sys_wait_stat>:


uint64
sys_wait_stat(void){
    800033f2:	1101                	addi	sp,sp,-32
    800033f4:	ec06                	sd	ra,24(sp)
    800033f6:	e822                	sd	s0,16(sp)
    800033f8:	1000                	addi	s0,sp,32
  uint64 stat;
  uint64 perf;
  if(argaddr(0, &stat) < 0)
    800033fa:	fe840593          	addi	a1,s0,-24
    800033fe:	4501                	li	a0,0
    80003400:	00000097          	auipc	ra,0x0
    80003404:	c2c080e7          	jalr	-980(ra) # 8000302c <argaddr>
    return -1;
    80003408:	57fd                	li	a5,-1
  if(argaddr(0, &stat) < 0)
    8000340a:	02054563          	bltz	a0,80003434 <sys_wait_stat+0x42>
  if(argaddr(1, &perf) < 0)
    8000340e:	fe040593          	addi	a1,s0,-32
    80003412:	4505                	li	a0,1
    80003414:	00000097          	auipc	ra,0x0
    80003418:	c18080e7          	jalr	-1000(ra) # 8000302c <argaddr>
    return -1;
    8000341c:	57fd                	li	a5,-1
  if(argaddr(1, &perf) < 0)
    8000341e:	00054b63          	bltz	a0,80003434 <sys_wait_stat+0x42>
  return wait_stat(stat, perf);
    80003422:	fe043583          	ld	a1,-32(s0)
    80003426:	fe843503          	ld	a0,-24(s0)
    8000342a:	fffff097          	auipc	ra,0xfffff
    8000342e:	468080e7          	jalr	1128(ra) # 80002892 <wait_stat>
    80003432:	87aa                	mv	a5,a0
}
    80003434:	853e                	mv	a0,a5
    80003436:	60e2                	ld	ra,24(sp)
    80003438:	6442                	ld	s0,16(sp)
    8000343a:	6105                	addi	sp,sp,32
    8000343c:	8082                	ret

000000008000343e <sys_set_priority>:

uint64
sys_set_priority(void){
    8000343e:	1101                	addi	sp,sp,-32
    80003440:	ec06                	sd	ra,24(sp)
    80003442:	e822                	sd	s0,16(sp)
    80003444:	1000                	addi	s0,sp,32
  int priotity;
 if(argint(0,&priotity) < 0)
    80003446:	fec40593          	addi	a1,s0,-20
    8000344a:	4501                	li	a0,0
    8000344c:	00000097          	auipc	ra,0x0
    80003450:	bbe080e7          	jalr	-1090(ra) # 8000300a <argint>
    80003454:	87aa                	mv	a5,a0
    return -1;
    80003456:	557d                	li	a0,-1
 if(argint(0,&priotity) < 0)
    80003458:	0007c863          	bltz	a5,80003468 <sys_set_priority+0x2a>
  return set_priority(priotity);
    8000345c:	fec42503          	lw	a0,-20(s0)
    80003460:	fffff097          	auipc	ra,0xfffff
    80003464:	60c080e7          	jalr	1548(ra) # 80002a6c <set_priority>
}
    80003468:	60e2                	ld	ra,24(sp)
    8000346a:	6442                	ld	s0,16(sp)
    8000346c:	6105                	addi	sp,sp,32
    8000346e:	8082                	ret

0000000080003470 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003470:	7179                	addi	sp,sp,-48
    80003472:	f406                	sd	ra,40(sp)
    80003474:	f022                	sd	s0,32(sp)
    80003476:	ec26                	sd	s1,24(sp)
    80003478:	e84a                	sd	s2,16(sp)
    8000347a:	e44e                	sd	s3,8(sp)
    8000347c:	e052                	sd	s4,0(sp)
    8000347e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003480:	00005597          	auipc	a1,0x5
    80003484:	37058593          	addi	a1,a1,880 # 800087f0 <syscalls+0xc8>
    80003488:	00014517          	auipc	a0,0x14
    8000348c:	66050513          	addi	a0,a0,1632 # 80017ae8 <bcache>
    80003490:	ffffd097          	auipc	ra,0xffffd
    80003494:	6a2080e7          	jalr	1698(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003498:	0001c797          	auipc	a5,0x1c
    8000349c:	65078793          	addi	a5,a5,1616 # 8001fae8 <bcache+0x8000>
    800034a0:	0001d717          	auipc	a4,0x1d
    800034a4:	8b070713          	addi	a4,a4,-1872 # 8001fd50 <bcache+0x8268>
    800034a8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800034ac:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034b0:	00014497          	auipc	s1,0x14
    800034b4:	65048493          	addi	s1,s1,1616 # 80017b00 <bcache+0x18>
    b->next = bcache.head.next;
    800034b8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800034ba:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800034bc:	00005a17          	auipc	s4,0x5
    800034c0:	33ca0a13          	addi	s4,s4,828 # 800087f8 <syscalls+0xd0>
    b->next = bcache.head.next;
    800034c4:	2b893783          	ld	a5,696(s2)
    800034c8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800034ca:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800034ce:	85d2                	mv	a1,s4
    800034d0:	01048513          	addi	a0,s1,16
    800034d4:	00001097          	auipc	ra,0x1
    800034d8:	4c2080e7          	jalr	1218(ra) # 80004996 <initsleeplock>
    bcache.head.next->prev = b;
    800034dc:	2b893783          	ld	a5,696(s2)
    800034e0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800034e2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034e6:	45848493          	addi	s1,s1,1112
    800034ea:	fd349de3          	bne	s1,s3,800034c4 <binit+0x54>
  }
}
    800034ee:	70a2                	ld	ra,40(sp)
    800034f0:	7402                	ld	s0,32(sp)
    800034f2:	64e2                	ld	s1,24(sp)
    800034f4:	6942                	ld	s2,16(sp)
    800034f6:	69a2                	ld	s3,8(sp)
    800034f8:	6a02                	ld	s4,0(sp)
    800034fa:	6145                	addi	sp,sp,48
    800034fc:	8082                	ret

00000000800034fe <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800034fe:	7179                	addi	sp,sp,-48
    80003500:	f406                	sd	ra,40(sp)
    80003502:	f022                	sd	s0,32(sp)
    80003504:	ec26                	sd	s1,24(sp)
    80003506:	e84a                	sd	s2,16(sp)
    80003508:	e44e                	sd	s3,8(sp)
    8000350a:	1800                	addi	s0,sp,48
    8000350c:	892a                	mv	s2,a0
    8000350e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003510:	00014517          	auipc	a0,0x14
    80003514:	5d850513          	addi	a0,a0,1496 # 80017ae8 <bcache>
    80003518:	ffffd097          	auipc	ra,0xffffd
    8000351c:	6aa080e7          	jalr	1706(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003520:	0001d497          	auipc	s1,0x1d
    80003524:	8804b483          	ld	s1,-1920(s1) # 8001fda0 <bcache+0x82b8>
    80003528:	0001d797          	auipc	a5,0x1d
    8000352c:	82878793          	addi	a5,a5,-2008 # 8001fd50 <bcache+0x8268>
    80003530:	02f48f63          	beq	s1,a5,8000356e <bread+0x70>
    80003534:	873e                	mv	a4,a5
    80003536:	a021                	j	8000353e <bread+0x40>
    80003538:	68a4                	ld	s1,80(s1)
    8000353a:	02e48a63          	beq	s1,a4,8000356e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000353e:	449c                	lw	a5,8(s1)
    80003540:	ff279ce3          	bne	a5,s2,80003538 <bread+0x3a>
    80003544:	44dc                	lw	a5,12(s1)
    80003546:	ff3799e3          	bne	a5,s3,80003538 <bread+0x3a>
      b->refcnt++;
    8000354a:	40bc                	lw	a5,64(s1)
    8000354c:	2785                	addiw	a5,a5,1
    8000354e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003550:	00014517          	auipc	a0,0x14
    80003554:	59850513          	addi	a0,a0,1432 # 80017ae8 <bcache>
    80003558:	ffffd097          	auipc	ra,0xffffd
    8000355c:	71e080e7          	jalr	1822(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003560:	01048513          	addi	a0,s1,16
    80003564:	00001097          	auipc	ra,0x1
    80003568:	46c080e7          	jalr	1132(ra) # 800049d0 <acquiresleep>
      return b;
    8000356c:	a8b9                	j	800035ca <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000356e:	0001d497          	auipc	s1,0x1d
    80003572:	82a4b483          	ld	s1,-2006(s1) # 8001fd98 <bcache+0x82b0>
    80003576:	0001c797          	auipc	a5,0x1c
    8000357a:	7da78793          	addi	a5,a5,2010 # 8001fd50 <bcache+0x8268>
    8000357e:	00f48863          	beq	s1,a5,8000358e <bread+0x90>
    80003582:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003584:	40bc                	lw	a5,64(s1)
    80003586:	cf81                	beqz	a5,8000359e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003588:	64a4                	ld	s1,72(s1)
    8000358a:	fee49de3          	bne	s1,a4,80003584 <bread+0x86>
  panic("bget: no buffers");
    8000358e:	00005517          	auipc	a0,0x5
    80003592:	27250513          	addi	a0,a0,626 # 80008800 <syscalls+0xd8>
    80003596:	ffffd097          	auipc	ra,0xffffd
    8000359a:	f94080e7          	jalr	-108(ra) # 8000052a <panic>
      b->dev = dev;
    8000359e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800035a2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800035a6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800035aa:	4785                	li	a5,1
    800035ac:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035ae:	00014517          	auipc	a0,0x14
    800035b2:	53a50513          	addi	a0,a0,1338 # 80017ae8 <bcache>
    800035b6:	ffffd097          	auipc	ra,0xffffd
    800035ba:	6c0080e7          	jalr	1728(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    800035be:	01048513          	addi	a0,s1,16
    800035c2:	00001097          	auipc	ra,0x1
    800035c6:	40e080e7          	jalr	1038(ra) # 800049d0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800035ca:	409c                	lw	a5,0(s1)
    800035cc:	cb89                	beqz	a5,800035de <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800035ce:	8526                	mv	a0,s1
    800035d0:	70a2                	ld	ra,40(sp)
    800035d2:	7402                	ld	s0,32(sp)
    800035d4:	64e2                	ld	s1,24(sp)
    800035d6:	6942                	ld	s2,16(sp)
    800035d8:	69a2                	ld	s3,8(sp)
    800035da:	6145                	addi	sp,sp,48
    800035dc:	8082                	ret
    virtio_disk_rw(b, 0);
    800035de:	4581                	li	a1,0
    800035e0:	8526                	mv	a0,s1
    800035e2:	00003097          	auipc	ra,0x3
    800035e6:	f24080e7          	jalr	-220(ra) # 80006506 <virtio_disk_rw>
    b->valid = 1;
    800035ea:	4785                	li	a5,1
    800035ec:	c09c                	sw	a5,0(s1)
  return b;
    800035ee:	b7c5                	j	800035ce <bread+0xd0>

00000000800035f0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800035f0:	1101                	addi	sp,sp,-32
    800035f2:	ec06                	sd	ra,24(sp)
    800035f4:	e822                	sd	s0,16(sp)
    800035f6:	e426                	sd	s1,8(sp)
    800035f8:	1000                	addi	s0,sp,32
    800035fa:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035fc:	0541                	addi	a0,a0,16
    800035fe:	00001097          	auipc	ra,0x1
    80003602:	46c080e7          	jalr	1132(ra) # 80004a6a <holdingsleep>
    80003606:	cd01                	beqz	a0,8000361e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003608:	4585                	li	a1,1
    8000360a:	8526                	mv	a0,s1
    8000360c:	00003097          	auipc	ra,0x3
    80003610:	efa080e7          	jalr	-262(ra) # 80006506 <virtio_disk_rw>
}
    80003614:	60e2                	ld	ra,24(sp)
    80003616:	6442                	ld	s0,16(sp)
    80003618:	64a2                	ld	s1,8(sp)
    8000361a:	6105                	addi	sp,sp,32
    8000361c:	8082                	ret
    panic("bwrite");
    8000361e:	00005517          	auipc	a0,0x5
    80003622:	1fa50513          	addi	a0,a0,506 # 80008818 <syscalls+0xf0>
    80003626:	ffffd097          	auipc	ra,0xffffd
    8000362a:	f04080e7          	jalr	-252(ra) # 8000052a <panic>

000000008000362e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000362e:	1101                	addi	sp,sp,-32
    80003630:	ec06                	sd	ra,24(sp)
    80003632:	e822                	sd	s0,16(sp)
    80003634:	e426                	sd	s1,8(sp)
    80003636:	e04a                	sd	s2,0(sp)
    80003638:	1000                	addi	s0,sp,32
    8000363a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000363c:	01050913          	addi	s2,a0,16
    80003640:	854a                	mv	a0,s2
    80003642:	00001097          	auipc	ra,0x1
    80003646:	428080e7          	jalr	1064(ra) # 80004a6a <holdingsleep>
    8000364a:	c92d                	beqz	a0,800036bc <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000364c:	854a                	mv	a0,s2
    8000364e:	00001097          	auipc	ra,0x1
    80003652:	3d8080e7          	jalr	984(ra) # 80004a26 <releasesleep>

  acquire(&bcache.lock);
    80003656:	00014517          	auipc	a0,0x14
    8000365a:	49250513          	addi	a0,a0,1170 # 80017ae8 <bcache>
    8000365e:	ffffd097          	auipc	ra,0xffffd
    80003662:	564080e7          	jalr	1380(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003666:	40bc                	lw	a5,64(s1)
    80003668:	37fd                	addiw	a5,a5,-1
    8000366a:	0007871b          	sext.w	a4,a5
    8000366e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003670:	eb05                	bnez	a4,800036a0 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003672:	68bc                	ld	a5,80(s1)
    80003674:	64b8                	ld	a4,72(s1)
    80003676:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003678:	64bc                	ld	a5,72(s1)
    8000367a:	68b8                	ld	a4,80(s1)
    8000367c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000367e:	0001c797          	auipc	a5,0x1c
    80003682:	46a78793          	addi	a5,a5,1130 # 8001fae8 <bcache+0x8000>
    80003686:	2b87b703          	ld	a4,696(a5)
    8000368a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000368c:	0001c717          	auipc	a4,0x1c
    80003690:	6c470713          	addi	a4,a4,1732 # 8001fd50 <bcache+0x8268>
    80003694:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003696:	2b87b703          	ld	a4,696(a5)
    8000369a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000369c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800036a0:	00014517          	auipc	a0,0x14
    800036a4:	44850513          	addi	a0,a0,1096 # 80017ae8 <bcache>
    800036a8:	ffffd097          	auipc	ra,0xffffd
    800036ac:	5ce080e7          	jalr	1486(ra) # 80000c76 <release>
}
    800036b0:	60e2                	ld	ra,24(sp)
    800036b2:	6442                	ld	s0,16(sp)
    800036b4:	64a2                	ld	s1,8(sp)
    800036b6:	6902                	ld	s2,0(sp)
    800036b8:	6105                	addi	sp,sp,32
    800036ba:	8082                	ret
    panic("brelse");
    800036bc:	00005517          	auipc	a0,0x5
    800036c0:	16450513          	addi	a0,a0,356 # 80008820 <syscalls+0xf8>
    800036c4:	ffffd097          	auipc	ra,0xffffd
    800036c8:	e66080e7          	jalr	-410(ra) # 8000052a <panic>

00000000800036cc <bpin>:

void
bpin(struct buf *b) {
    800036cc:	1101                	addi	sp,sp,-32
    800036ce:	ec06                	sd	ra,24(sp)
    800036d0:	e822                	sd	s0,16(sp)
    800036d2:	e426                	sd	s1,8(sp)
    800036d4:	1000                	addi	s0,sp,32
    800036d6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036d8:	00014517          	auipc	a0,0x14
    800036dc:	41050513          	addi	a0,a0,1040 # 80017ae8 <bcache>
    800036e0:	ffffd097          	auipc	ra,0xffffd
    800036e4:	4e2080e7          	jalr	1250(ra) # 80000bc2 <acquire>
  b->refcnt++;
    800036e8:	40bc                	lw	a5,64(s1)
    800036ea:	2785                	addiw	a5,a5,1
    800036ec:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036ee:	00014517          	auipc	a0,0x14
    800036f2:	3fa50513          	addi	a0,a0,1018 # 80017ae8 <bcache>
    800036f6:	ffffd097          	auipc	ra,0xffffd
    800036fa:	580080e7          	jalr	1408(ra) # 80000c76 <release>
}
    800036fe:	60e2                	ld	ra,24(sp)
    80003700:	6442                	ld	s0,16(sp)
    80003702:	64a2                	ld	s1,8(sp)
    80003704:	6105                	addi	sp,sp,32
    80003706:	8082                	ret

0000000080003708 <bunpin>:

void
bunpin(struct buf *b) {
    80003708:	1101                	addi	sp,sp,-32
    8000370a:	ec06                	sd	ra,24(sp)
    8000370c:	e822                	sd	s0,16(sp)
    8000370e:	e426                	sd	s1,8(sp)
    80003710:	1000                	addi	s0,sp,32
    80003712:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003714:	00014517          	auipc	a0,0x14
    80003718:	3d450513          	addi	a0,a0,980 # 80017ae8 <bcache>
    8000371c:	ffffd097          	auipc	ra,0xffffd
    80003720:	4a6080e7          	jalr	1190(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003724:	40bc                	lw	a5,64(s1)
    80003726:	37fd                	addiw	a5,a5,-1
    80003728:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000372a:	00014517          	auipc	a0,0x14
    8000372e:	3be50513          	addi	a0,a0,958 # 80017ae8 <bcache>
    80003732:	ffffd097          	auipc	ra,0xffffd
    80003736:	544080e7          	jalr	1348(ra) # 80000c76 <release>
}
    8000373a:	60e2                	ld	ra,24(sp)
    8000373c:	6442                	ld	s0,16(sp)
    8000373e:	64a2                	ld	s1,8(sp)
    80003740:	6105                	addi	sp,sp,32
    80003742:	8082                	ret

0000000080003744 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003744:	1101                	addi	sp,sp,-32
    80003746:	ec06                	sd	ra,24(sp)
    80003748:	e822                	sd	s0,16(sp)
    8000374a:	e426                	sd	s1,8(sp)
    8000374c:	e04a                	sd	s2,0(sp)
    8000374e:	1000                	addi	s0,sp,32
    80003750:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003752:	00d5d59b          	srliw	a1,a1,0xd
    80003756:	0001d797          	auipc	a5,0x1d
    8000375a:	a6e7a783          	lw	a5,-1426(a5) # 800201c4 <sb+0x1c>
    8000375e:	9dbd                	addw	a1,a1,a5
    80003760:	00000097          	auipc	ra,0x0
    80003764:	d9e080e7          	jalr	-610(ra) # 800034fe <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003768:	0074f713          	andi	a4,s1,7
    8000376c:	4785                	li	a5,1
    8000376e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003772:	14ce                	slli	s1,s1,0x33
    80003774:	90d9                	srli	s1,s1,0x36
    80003776:	00950733          	add	a4,a0,s1
    8000377a:	05874703          	lbu	a4,88(a4)
    8000377e:	00e7f6b3          	and	a3,a5,a4
    80003782:	c69d                	beqz	a3,800037b0 <bfree+0x6c>
    80003784:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003786:	94aa                	add	s1,s1,a0
    80003788:	fff7c793          	not	a5,a5
    8000378c:	8ff9                	and	a5,a5,a4
    8000378e:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003792:	00001097          	auipc	ra,0x1
    80003796:	11e080e7          	jalr	286(ra) # 800048b0 <log_write>
  brelse(bp);
    8000379a:	854a                	mv	a0,s2
    8000379c:	00000097          	auipc	ra,0x0
    800037a0:	e92080e7          	jalr	-366(ra) # 8000362e <brelse>
}
    800037a4:	60e2                	ld	ra,24(sp)
    800037a6:	6442                	ld	s0,16(sp)
    800037a8:	64a2                	ld	s1,8(sp)
    800037aa:	6902                	ld	s2,0(sp)
    800037ac:	6105                	addi	sp,sp,32
    800037ae:	8082                	ret
    panic("freeing free block");
    800037b0:	00005517          	auipc	a0,0x5
    800037b4:	07850513          	addi	a0,a0,120 # 80008828 <syscalls+0x100>
    800037b8:	ffffd097          	auipc	ra,0xffffd
    800037bc:	d72080e7          	jalr	-654(ra) # 8000052a <panic>

00000000800037c0 <balloc>:
{
    800037c0:	711d                	addi	sp,sp,-96
    800037c2:	ec86                	sd	ra,88(sp)
    800037c4:	e8a2                	sd	s0,80(sp)
    800037c6:	e4a6                	sd	s1,72(sp)
    800037c8:	e0ca                	sd	s2,64(sp)
    800037ca:	fc4e                	sd	s3,56(sp)
    800037cc:	f852                	sd	s4,48(sp)
    800037ce:	f456                	sd	s5,40(sp)
    800037d0:	f05a                	sd	s6,32(sp)
    800037d2:	ec5e                	sd	s7,24(sp)
    800037d4:	e862                	sd	s8,16(sp)
    800037d6:	e466                	sd	s9,8(sp)
    800037d8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800037da:	0001d797          	auipc	a5,0x1d
    800037de:	9d27a783          	lw	a5,-1582(a5) # 800201ac <sb+0x4>
    800037e2:	cbd1                	beqz	a5,80003876 <balloc+0xb6>
    800037e4:	8baa                	mv	s7,a0
    800037e6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800037e8:	0001db17          	auipc	s6,0x1d
    800037ec:	9c0b0b13          	addi	s6,s6,-1600 # 800201a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037f0:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800037f2:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037f4:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800037f6:	6c89                	lui	s9,0x2
    800037f8:	a831                	j	80003814 <balloc+0x54>
    brelse(bp);
    800037fa:	854a                	mv	a0,s2
    800037fc:	00000097          	auipc	ra,0x0
    80003800:	e32080e7          	jalr	-462(ra) # 8000362e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003804:	015c87bb          	addw	a5,s9,s5
    80003808:	00078a9b          	sext.w	s5,a5
    8000380c:	004b2703          	lw	a4,4(s6)
    80003810:	06eaf363          	bgeu	s5,a4,80003876 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003814:	41fad79b          	sraiw	a5,s5,0x1f
    80003818:	0137d79b          	srliw	a5,a5,0x13
    8000381c:	015787bb          	addw	a5,a5,s5
    80003820:	40d7d79b          	sraiw	a5,a5,0xd
    80003824:	01cb2583          	lw	a1,28(s6)
    80003828:	9dbd                	addw	a1,a1,a5
    8000382a:	855e                	mv	a0,s7
    8000382c:	00000097          	auipc	ra,0x0
    80003830:	cd2080e7          	jalr	-814(ra) # 800034fe <bread>
    80003834:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003836:	004b2503          	lw	a0,4(s6)
    8000383a:	000a849b          	sext.w	s1,s5
    8000383e:	8662                	mv	a2,s8
    80003840:	faa4fde3          	bgeu	s1,a0,800037fa <balloc+0x3a>
      m = 1 << (bi % 8);
    80003844:	41f6579b          	sraiw	a5,a2,0x1f
    80003848:	01d7d69b          	srliw	a3,a5,0x1d
    8000384c:	00c6873b          	addw	a4,a3,a2
    80003850:	00777793          	andi	a5,a4,7
    80003854:	9f95                	subw	a5,a5,a3
    80003856:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000385a:	4037571b          	sraiw	a4,a4,0x3
    8000385e:	00e906b3          	add	a3,s2,a4
    80003862:	0586c683          	lbu	a3,88(a3)
    80003866:	00d7f5b3          	and	a1,a5,a3
    8000386a:	cd91                	beqz	a1,80003886 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000386c:	2605                	addiw	a2,a2,1
    8000386e:	2485                	addiw	s1,s1,1
    80003870:	fd4618e3          	bne	a2,s4,80003840 <balloc+0x80>
    80003874:	b759                	j	800037fa <balloc+0x3a>
  panic("balloc: out of blocks");
    80003876:	00005517          	auipc	a0,0x5
    8000387a:	fca50513          	addi	a0,a0,-54 # 80008840 <syscalls+0x118>
    8000387e:	ffffd097          	auipc	ra,0xffffd
    80003882:	cac080e7          	jalr	-852(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003886:	974a                	add	a4,a4,s2
    80003888:	8fd5                	or	a5,a5,a3
    8000388a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000388e:	854a                	mv	a0,s2
    80003890:	00001097          	auipc	ra,0x1
    80003894:	020080e7          	jalr	32(ra) # 800048b0 <log_write>
        brelse(bp);
    80003898:	854a                	mv	a0,s2
    8000389a:	00000097          	auipc	ra,0x0
    8000389e:	d94080e7          	jalr	-620(ra) # 8000362e <brelse>
  bp = bread(dev, bno);
    800038a2:	85a6                	mv	a1,s1
    800038a4:	855e                	mv	a0,s7
    800038a6:	00000097          	auipc	ra,0x0
    800038aa:	c58080e7          	jalr	-936(ra) # 800034fe <bread>
    800038ae:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800038b0:	40000613          	li	a2,1024
    800038b4:	4581                	li	a1,0
    800038b6:	05850513          	addi	a0,a0,88
    800038ba:	ffffd097          	auipc	ra,0xffffd
    800038be:	404080e7          	jalr	1028(ra) # 80000cbe <memset>
  log_write(bp);
    800038c2:	854a                	mv	a0,s2
    800038c4:	00001097          	auipc	ra,0x1
    800038c8:	fec080e7          	jalr	-20(ra) # 800048b0 <log_write>
  brelse(bp);
    800038cc:	854a                	mv	a0,s2
    800038ce:	00000097          	auipc	ra,0x0
    800038d2:	d60080e7          	jalr	-672(ra) # 8000362e <brelse>
}
    800038d6:	8526                	mv	a0,s1
    800038d8:	60e6                	ld	ra,88(sp)
    800038da:	6446                	ld	s0,80(sp)
    800038dc:	64a6                	ld	s1,72(sp)
    800038de:	6906                	ld	s2,64(sp)
    800038e0:	79e2                	ld	s3,56(sp)
    800038e2:	7a42                	ld	s4,48(sp)
    800038e4:	7aa2                	ld	s5,40(sp)
    800038e6:	7b02                	ld	s6,32(sp)
    800038e8:	6be2                	ld	s7,24(sp)
    800038ea:	6c42                	ld	s8,16(sp)
    800038ec:	6ca2                	ld	s9,8(sp)
    800038ee:	6125                	addi	sp,sp,96
    800038f0:	8082                	ret

00000000800038f2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800038f2:	7179                	addi	sp,sp,-48
    800038f4:	f406                	sd	ra,40(sp)
    800038f6:	f022                	sd	s0,32(sp)
    800038f8:	ec26                	sd	s1,24(sp)
    800038fa:	e84a                	sd	s2,16(sp)
    800038fc:	e44e                	sd	s3,8(sp)
    800038fe:	e052                	sd	s4,0(sp)
    80003900:	1800                	addi	s0,sp,48
    80003902:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003904:	47ad                	li	a5,11
    80003906:	04b7fe63          	bgeu	a5,a1,80003962 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000390a:	ff45849b          	addiw	s1,a1,-12
    8000390e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003912:	0ff00793          	li	a5,255
    80003916:	0ae7e463          	bltu	a5,a4,800039be <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000391a:	08052583          	lw	a1,128(a0)
    8000391e:	c5b5                	beqz	a1,8000398a <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003920:	00092503          	lw	a0,0(s2)
    80003924:	00000097          	auipc	ra,0x0
    80003928:	bda080e7          	jalr	-1062(ra) # 800034fe <bread>
    8000392c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000392e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003932:	02049713          	slli	a4,s1,0x20
    80003936:	01e75593          	srli	a1,a4,0x1e
    8000393a:	00b784b3          	add	s1,a5,a1
    8000393e:	0004a983          	lw	s3,0(s1)
    80003942:	04098e63          	beqz	s3,8000399e <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003946:	8552                	mv	a0,s4
    80003948:	00000097          	auipc	ra,0x0
    8000394c:	ce6080e7          	jalr	-794(ra) # 8000362e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003950:	854e                	mv	a0,s3
    80003952:	70a2                	ld	ra,40(sp)
    80003954:	7402                	ld	s0,32(sp)
    80003956:	64e2                	ld	s1,24(sp)
    80003958:	6942                	ld	s2,16(sp)
    8000395a:	69a2                	ld	s3,8(sp)
    8000395c:	6a02                	ld	s4,0(sp)
    8000395e:	6145                	addi	sp,sp,48
    80003960:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003962:	02059793          	slli	a5,a1,0x20
    80003966:	01e7d593          	srli	a1,a5,0x1e
    8000396a:	00b504b3          	add	s1,a0,a1
    8000396e:	0504a983          	lw	s3,80(s1)
    80003972:	fc099fe3          	bnez	s3,80003950 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003976:	4108                	lw	a0,0(a0)
    80003978:	00000097          	auipc	ra,0x0
    8000397c:	e48080e7          	jalr	-440(ra) # 800037c0 <balloc>
    80003980:	0005099b          	sext.w	s3,a0
    80003984:	0534a823          	sw	s3,80(s1)
    80003988:	b7e1                	j	80003950 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000398a:	4108                	lw	a0,0(a0)
    8000398c:	00000097          	auipc	ra,0x0
    80003990:	e34080e7          	jalr	-460(ra) # 800037c0 <balloc>
    80003994:	0005059b          	sext.w	a1,a0
    80003998:	08b92023          	sw	a1,128(s2)
    8000399c:	b751                	j	80003920 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000399e:	00092503          	lw	a0,0(s2)
    800039a2:	00000097          	auipc	ra,0x0
    800039a6:	e1e080e7          	jalr	-482(ra) # 800037c0 <balloc>
    800039aa:	0005099b          	sext.w	s3,a0
    800039ae:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800039b2:	8552                	mv	a0,s4
    800039b4:	00001097          	auipc	ra,0x1
    800039b8:	efc080e7          	jalr	-260(ra) # 800048b0 <log_write>
    800039bc:	b769                	j	80003946 <bmap+0x54>
  panic("bmap: out of range");
    800039be:	00005517          	auipc	a0,0x5
    800039c2:	e9a50513          	addi	a0,a0,-358 # 80008858 <syscalls+0x130>
    800039c6:	ffffd097          	auipc	ra,0xffffd
    800039ca:	b64080e7          	jalr	-1180(ra) # 8000052a <panic>

00000000800039ce <iget>:
{
    800039ce:	7179                	addi	sp,sp,-48
    800039d0:	f406                	sd	ra,40(sp)
    800039d2:	f022                	sd	s0,32(sp)
    800039d4:	ec26                	sd	s1,24(sp)
    800039d6:	e84a                	sd	s2,16(sp)
    800039d8:	e44e                	sd	s3,8(sp)
    800039da:	e052                	sd	s4,0(sp)
    800039dc:	1800                	addi	s0,sp,48
    800039de:	89aa                	mv	s3,a0
    800039e0:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800039e2:	0001c517          	auipc	a0,0x1c
    800039e6:	7e650513          	addi	a0,a0,2022 # 800201c8 <itable>
    800039ea:	ffffd097          	auipc	ra,0xffffd
    800039ee:	1d8080e7          	jalr	472(ra) # 80000bc2 <acquire>
  empty = 0;
    800039f2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039f4:	0001c497          	auipc	s1,0x1c
    800039f8:	7ec48493          	addi	s1,s1,2028 # 800201e0 <itable+0x18>
    800039fc:	0001e697          	auipc	a3,0x1e
    80003a00:	27468693          	addi	a3,a3,628 # 80021c70 <log>
    80003a04:	a039                	j	80003a12 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a06:	02090b63          	beqz	s2,80003a3c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a0a:	08848493          	addi	s1,s1,136
    80003a0e:	02d48a63          	beq	s1,a3,80003a42 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003a12:	449c                	lw	a5,8(s1)
    80003a14:	fef059e3          	blez	a5,80003a06 <iget+0x38>
    80003a18:	4098                	lw	a4,0(s1)
    80003a1a:	ff3716e3          	bne	a4,s3,80003a06 <iget+0x38>
    80003a1e:	40d8                	lw	a4,4(s1)
    80003a20:	ff4713e3          	bne	a4,s4,80003a06 <iget+0x38>
      ip->ref++;
    80003a24:	2785                	addiw	a5,a5,1
    80003a26:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003a28:	0001c517          	auipc	a0,0x1c
    80003a2c:	7a050513          	addi	a0,a0,1952 # 800201c8 <itable>
    80003a30:	ffffd097          	auipc	ra,0xffffd
    80003a34:	246080e7          	jalr	582(ra) # 80000c76 <release>
      return ip;
    80003a38:	8926                	mv	s2,s1
    80003a3a:	a03d                	j	80003a68 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a3c:	f7f9                	bnez	a5,80003a0a <iget+0x3c>
    80003a3e:	8926                	mv	s2,s1
    80003a40:	b7e9                	j	80003a0a <iget+0x3c>
  if(empty == 0)
    80003a42:	02090c63          	beqz	s2,80003a7a <iget+0xac>
  ip->dev = dev;
    80003a46:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003a4a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003a4e:	4785                	li	a5,1
    80003a50:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003a54:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003a58:	0001c517          	auipc	a0,0x1c
    80003a5c:	77050513          	addi	a0,a0,1904 # 800201c8 <itable>
    80003a60:	ffffd097          	auipc	ra,0xffffd
    80003a64:	216080e7          	jalr	534(ra) # 80000c76 <release>
}
    80003a68:	854a                	mv	a0,s2
    80003a6a:	70a2                	ld	ra,40(sp)
    80003a6c:	7402                	ld	s0,32(sp)
    80003a6e:	64e2                	ld	s1,24(sp)
    80003a70:	6942                	ld	s2,16(sp)
    80003a72:	69a2                	ld	s3,8(sp)
    80003a74:	6a02                	ld	s4,0(sp)
    80003a76:	6145                	addi	sp,sp,48
    80003a78:	8082                	ret
    panic("iget: no inodes");
    80003a7a:	00005517          	auipc	a0,0x5
    80003a7e:	df650513          	addi	a0,a0,-522 # 80008870 <syscalls+0x148>
    80003a82:	ffffd097          	auipc	ra,0xffffd
    80003a86:	aa8080e7          	jalr	-1368(ra) # 8000052a <panic>

0000000080003a8a <fsinit>:
fsinit(int dev) {
    80003a8a:	7179                	addi	sp,sp,-48
    80003a8c:	f406                	sd	ra,40(sp)
    80003a8e:	f022                	sd	s0,32(sp)
    80003a90:	ec26                	sd	s1,24(sp)
    80003a92:	e84a                	sd	s2,16(sp)
    80003a94:	e44e                	sd	s3,8(sp)
    80003a96:	1800                	addi	s0,sp,48
    80003a98:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a9a:	4585                	li	a1,1
    80003a9c:	00000097          	auipc	ra,0x0
    80003aa0:	a62080e7          	jalr	-1438(ra) # 800034fe <bread>
    80003aa4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003aa6:	0001c997          	auipc	s3,0x1c
    80003aaa:	70298993          	addi	s3,s3,1794 # 800201a8 <sb>
    80003aae:	02000613          	li	a2,32
    80003ab2:	05850593          	addi	a1,a0,88
    80003ab6:	854e                	mv	a0,s3
    80003ab8:	ffffd097          	auipc	ra,0xffffd
    80003abc:	262080e7          	jalr	610(ra) # 80000d1a <memmove>
  brelse(bp);
    80003ac0:	8526                	mv	a0,s1
    80003ac2:	00000097          	auipc	ra,0x0
    80003ac6:	b6c080e7          	jalr	-1172(ra) # 8000362e <brelse>
  if(sb.magic != FSMAGIC)
    80003aca:	0009a703          	lw	a4,0(s3)
    80003ace:	102037b7          	lui	a5,0x10203
    80003ad2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003ad6:	02f71263          	bne	a4,a5,80003afa <fsinit+0x70>
  initlog(dev, &sb);
    80003ada:	0001c597          	auipc	a1,0x1c
    80003ade:	6ce58593          	addi	a1,a1,1742 # 800201a8 <sb>
    80003ae2:	854a                	mv	a0,s2
    80003ae4:	00001097          	auipc	ra,0x1
    80003ae8:	b4e080e7          	jalr	-1202(ra) # 80004632 <initlog>
}
    80003aec:	70a2                	ld	ra,40(sp)
    80003aee:	7402                	ld	s0,32(sp)
    80003af0:	64e2                	ld	s1,24(sp)
    80003af2:	6942                	ld	s2,16(sp)
    80003af4:	69a2                	ld	s3,8(sp)
    80003af6:	6145                	addi	sp,sp,48
    80003af8:	8082                	ret
    panic("invalid file system");
    80003afa:	00005517          	auipc	a0,0x5
    80003afe:	d8650513          	addi	a0,a0,-634 # 80008880 <syscalls+0x158>
    80003b02:	ffffd097          	auipc	ra,0xffffd
    80003b06:	a28080e7          	jalr	-1496(ra) # 8000052a <panic>

0000000080003b0a <iinit>:
{
    80003b0a:	7179                	addi	sp,sp,-48
    80003b0c:	f406                	sd	ra,40(sp)
    80003b0e:	f022                	sd	s0,32(sp)
    80003b10:	ec26                	sd	s1,24(sp)
    80003b12:	e84a                	sd	s2,16(sp)
    80003b14:	e44e                	sd	s3,8(sp)
    80003b16:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003b18:	00005597          	auipc	a1,0x5
    80003b1c:	d8058593          	addi	a1,a1,-640 # 80008898 <syscalls+0x170>
    80003b20:	0001c517          	auipc	a0,0x1c
    80003b24:	6a850513          	addi	a0,a0,1704 # 800201c8 <itable>
    80003b28:	ffffd097          	auipc	ra,0xffffd
    80003b2c:	00a080e7          	jalr	10(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003b30:	0001c497          	auipc	s1,0x1c
    80003b34:	6c048493          	addi	s1,s1,1728 # 800201f0 <itable+0x28>
    80003b38:	0001e997          	auipc	s3,0x1e
    80003b3c:	14898993          	addi	s3,s3,328 # 80021c80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003b40:	00005917          	auipc	s2,0x5
    80003b44:	d6090913          	addi	s2,s2,-672 # 800088a0 <syscalls+0x178>
    80003b48:	85ca                	mv	a1,s2
    80003b4a:	8526                	mv	a0,s1
    80003b4c:	00001097          	auipc	ra,0x1
    80003b50:	e4a080e7          	jalr	-438(ra) # 80004996 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003b54:	08848493          	addi	s1,s1,136
    80003b58:	ff3498e3          	bne	s1,s3,80003b48 <iinit+0x3e>
}
    80003b5c:	70a2                	ld	ra,40(sp)
    80003b5e:	7402                	ld	s0,32(sp)
    80003b60:	64e2                	ld	s1,24(sp)
    80003b62:	6942                	ld	s2,16(sp)
    80003b64:	69a2                	ld	s3,8(sp)
    80003b66:	6145                	addi	sp,sp,48
    80003b68:	8082                	ret

0000000080003b6a <ialloc>:
{
    80003b6a:	715d                	addi	sp,sp,-80
    80003b6c:	e486                	sd	ra,72(sp)
    80003b6e:	e0a2                	sd	s0,64(sp)
    80003b70:	fc26                	sd	s1,56(sp)
    80003b72:	f84a                	sd	s2,48(sp)
    80003b74:	f44e                	sd	s3,40(sp)
    80003b76:	f052                	sd	s4,32(sp)
    80003b78:	ec56                	sd	s5,24(sp)
    80003b7a:	e85a                	sd	s6,16(sp)
    80003b7c:	e45e                	sd	s7,8(sp)
    80003b7e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b80:	0001c717          	auipc	a4,0x1c
    80003b84:	63472703          	lw	a4,1588(a4) # 800201b4 <sb+0xc>
    80003b88:	4785                	li	a5,1
    80003b8a:	04e7fa63          	bgeu	a5,a4,80003bde <ialloc+0x74>
    80003b8e:	8aaa                	mv	s5,a0
    80003b90:	8bae                	mv	s7,a1
    80003b92:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003b94:	0001ca17          	auipc	s4,0x1c
    80003b98:	614a0a13          	addi	s4,s4,1556 # 800201a8 <sb>
    80003b9c:	00048b1b          	sext.w	s6,s1
    80003ba0:	0044d793          	srli	a5,s1,0x4
    80003ba4:	018a2583          	lw	a1,24(s4)
    80003ba8:	9dbd                	addw	a1,a1,a5
    80003baa:	8556                	mv	a0,s5
    80003bac:	00000097          	auipc	ra,0x0
    80003bb0:	952080e7          	jalr	-1710(ra) # 800034fe <bread>
    80003bb4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003bb6:	05850993          	addi	s3,a0,88
    80003bba:	00f4f793          	andi	a5,s1,15
    80003bbe:	079a                	slli	a5,a5,0x6
    80003bc0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003bc2:	00099783          	lh	a5,0(s3)
    80003bc6:	c785                	beqz	a5,80003bee <ialloc+0x84>
    brelse(bp);
    80003bc8:	00000097          	auipc	ra,0x0
    80003bcc:	a66080e7          	jalr	-1434(ra) # 8000362e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003bd0:	0485                	addi	s1,s1,1
    80003bd2:	00ca2703          	lw	a4,12(s4)
    80003bd6:	0004879b          	sext.w	a5,s1
    80003bda:	fce7e1e3          	bltu	a5,a4,80003b9c <ialloc+0x32>
  panic("ialloc: no inodes");
    80003bde:	00005517          	auipc	a0,0x5
    80003be2:	cca50513          	addi	a0,a0,-822 # 800088a8 <syscalls+0x180>
    80003be6:	ffffd097          	auipc	ra,0xffffd
    80003bea:	944080e7          	jalr	-1724(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003bee:	04000613          	li	a2,64
    80003bf2:	4581                	li	a1,0
    80003bf4:	854e                	mv	a0,s3
    80003bf6:	ffffd097          	auipc	ra,0xffffd
    80003bfa:	0c8080e7          	jalr	200(ra) # 80000cbe <memset>
      dip->type = type;
    80003bfe:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003c02:	854a                	mv	a0,s2
    80003c04:	00001097          	auipc	ra,0x1
    80003c08:	cac080e7          	jalr	-852(ra) # 800048b0 <log_write>
      brelse(bp);
    80003c0c:	854a                	mv	a0,s2
    80003c0e:	00000097          	auipc	ra,0x0
    80003c12:	a20080e7          	jalr	-1504(ra) # 8000362e <brelse>
      return iget(dev, inum);
    80003c16:	85da                	mv	a1,s6
    80003c18:	8556                	mv	a0,s5
    80003c1a:	00000097          	auipc	ra,0x0
    80003c1e:	db4080e7          	jalr	-588(ra) # 800039ce <iget>
}
    80003c22:	60a6                	ld	ra,72(sp)
    80003c24:	6406                	ld	s0,64(sp)
    80003c26:	74e2                	ld	s1,56(sp)
    80003c28:	7942                	ld	s2,48(sp)
    80003c2a:	79a2                	ld	s3,40(sp)
    80003c2c:	7a02                	ld	s4,32(sp)
    80003c2e:	6ae2                	ld	s5,24(sp)
    80003c30:	6b42                	ld	s6,16(sp)
    80003c32:	6ba2                	ld	s7,8(sp)
    80003c34:	6161                	addi	sp,sp,80
    80003c36:	8082                	ret

0000000080003c38 <iupdate>:
{
    80003c38:	1101                	addi	sp,sp,-32
    80003c3a:	ec06                	sd	ra,24(sp)
    80003c3c:	e822                	sd	s0,16(sp)
    80003c3e:	e426                	sd	s1,8(sp)
    80003c40:	e04a                	sd	s2,0(sp)
    80003c42:	1000                	addi	s0,sp,32
    80003c44:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c46:	415c                	lw	a5,4(a0)
    80003c48:	0047d79b          	srliw	a5,a5,0x4
    80003c4c:	0001c597          	auipc	a1,0x1c
    80003c50:	5745a583          	lw	a1,1396(a1) # 800201c0 <sb+0x18>
    80003c54:	9dbd                	addw	a1,a1,a5
    80003c56:	4108                	lw	a0,0(a0)
    80003c58:	00000097          	auipc	ra,0x0
    80003c5c:	8a6080e7          	jalr	-1882(ra) # 800034fe <bread>
    80003c60:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c62:	05850793          	addi	a5,a0,88
    80003c66:	40c8                	lw	a0,4(s1)
    80003c68:	893d                	andi	a0,a0,15
    80003c6a:	051a                	slli	a0,a0,0x6
    80003c6c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003c6e:	04449703          	lh	a4,68(s1)
    80003c72:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003c76:	04649703          	lh	a4,70(s1)
    80003c7a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003c7e:	04849703          	lh	a4,72(s1)
    80003c82:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003c86:	04a49703          	lh	a4,74(s1)
    80003c8a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003c8e:	44f8                	lw	a4,76(s1)
    80003c90:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c92:	03400613          	li	a2,52
    80003c96:	05048593          	addi	a1,s1,80
    80003c9a:	0531                	addi	a0,a0,12
    80003c9c:	ffffd097          	auipc	ra,0xffffd
    80003ca0:	07e080e7          	jalr	126(ra) # 80000d1a <memmove>
  log_write(bp);
    80003ca4:	854a                	mv	a0,s2
    80003ca6:	00001097          	auipc	ra,0x1
    80003caa:	c0a080e7          	jalr	-1014(ra) # 800048b0 <log_write>
  brelse(bp);
    80003cae:	854a                	mv	a0,s2
    80003cb0:	00000097          	auipc	ra,0x0
    80003cb4:	97e080e7          	jalr	-1666(ra) # 8000362e <brelse>
}
    80003cb8:	60e2                	ld	ra,24(sp)
    80003cba:	6442                	ld	s0,16(sp)
    80003cbc:	64a2                	ld	s1,8(sp)
    80003cbe:	6902                	ld	s2,0(sp)
    80003cc0:	6105                	addi	sp,sp,32
    80003cc2:	8082                	ret

0000000080003cc4 <idup>:
{
    80003cc4:	1101                	addi	sp,sp,-32
    80003cc6:	ec06                	sd	ra,24(sp)
    80003cc8:	e822                	sd	s0,16(sp)
    80003cca:	e426                	sd	s1,8(sp)
    80003ccc:	1000                	addi	s0,sp,32
    80003cce:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003cd0:	0001c517          	auipc	a0,0x1c
    80003cd4:	4f850513          	addi	a0,a0,1272 # 800201c8 <itable>
    80003cd8:	ffffd097          	auipc	ra,0xffffd
    80003cdc:	eea080e7          	jalr	-278(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003ce0:	449c                	lw	a5,8(s1)
    80003ce2:	2785                	addiw	a5,a5,1
    80003ce4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ce6:	0001c517          	auipc	a0,0x1c
    80003cea:	4e250513          	addi	a0,a0,1250 # 800201c8 <itable>
    80003cee:	ffffd097          	auipc	ra,0xffffd
    80003cf2:	f88080e7          	jalr	-120(ra) # 80000c76 <release>
}
    80003cf6:	8526                	mv	a0,s1
    80003cf8:	60e2                	ld	ra,24(sp)
    80003cfa:	6442                	ld	s0,16(sp)
    80003cfc:	64a2                	ld	s1,8(sp)
    80003cfe:	6105                	addi	sp,sp,32
    80003d00:	8082                	ret

0000000080003d02 <ilock>:
{
    80003d02:	1101                	addi	sp,sp,-32
    80003d04:	ec06                	sd	ra,24(sp)
    80003d06:	e822                	sd	s0,16(sp)
    80003d08:	e426                	sd	s1,8(sp)
    80003d0a:	e04a                	sd	s2,0(sp)
    80003d0c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003d0e:	c115                	beqz	a0,80003d32 <ilock+0x30>
    80003d10:	84aa                	mv	s1,a0
    80003d12:	451c                	lw	a5,8(a0)
    80003d14:	00f05f63          	blez	a5,80003d32 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003d18:	0541                	addi	a0,a0,16
    80003d1a:	00001097          	auipc	ra,0x1
    80003d1e:	cb6080e7          	jalr	-842(ra) # 800049d0 <acquiresleep>
  if(ip->valid == 0){
    80003d22:	40bc                	lw	a5,64(s1)
    80003d24:	cf99                	beqz	a5,80003d42 <ilock+0x40>
}
    80003d26:	60e2                	ld	ra,24(sp)
    80003d28:	6442                	ld	s0,16(sp)
    80003d2a:	64a2                	ld	s1,8(sp)
    80003d2c:	6902                	ld	s2,0(sp)
    80003d2e:	6105                	addi	sp,sp,32
    80003d30:	8082                	ret
    panic("ilock");
    80003d32:	00005517          	auipc	a0,0x5
    80003d36:	b8e50513          	addi	a0,a0,-1138 # 800088c0 <syscalls+0x198>
    80003d3a:	ffffc097          	auipc	ra,0xffffc
    80003d3e:	7f0080e7          	jalr	2032(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d42:	40dc                	lw	a5,4(s1)
    80003d44:	0047d79b          	srliw	a5,a5,0x4
    80003d48:	0001c597          	auipc	a1,0x1c
    80003d4c:	4785a583          	lw	a1,1144(a1) # 800201c0 <sb+0x18>
    80003d50:	9dbd                	addw	a1,a1,a5
    80003d52:	4088                	lw	a0,0(s1)
    80003d54:	fffff097          	auipc	ra,0xfffff
    80003d58:	7aa080e7          	jalr	1962(ra) # 800034fe <bread>
    80003d5c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d5e:	05850593          	addi	a1,a0,88
    80003d62:	40dc                	lw	a5,4(s1)
    80003d64:	8bbd                	andi	a5,a5,15
    80003d66:	079a                	slli	a5,a5,0x6
    80003d68:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003d6a:	00059783          	lh	a5,0(a1)
    80003d6e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003d72:	00259783          	lh	a5,2(a1)
    80003d76:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003d7a:	00459783          	lh	a5,4(a1)
    80003d7e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d82:	00659783          	lh	a5,6(a1)
    80003d86:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d8a:	459c                	lw	a5,8(a1)
    80003d8c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d8e:	03400613          	li	a2,52
    80003d92:	05b1                	addi	a1,a1,12
    80003d94:	05048513          	addi	a0,s1,80
    80003d98:	ffffd097          	auipc	ra,0xffffd
    80003d9c:	f82080e7          	jalr	-126(ra) # 80000d1a <memmove>
    brelse(bp);
    80003da0:	854a                	mv	a0,s2
    80003da2:	00000097          	auipc	ra,0x0
    80003da6:	88c080e7          	jalr	-1908(ra) # 8000362e <brelse>
    ip->valid = 1;
    80003daa:	4785                	li	a5,1
    80003dac:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003dae:	04449783          	lh	a5,68(s1)
    80003db2:	fbb5                	bnez	a5,80003d26 <ilock+0x24>
      panic("ilock: no type");
    80003db4:	00005517          	auipc	a0,0x5
    80003db8:	b1450513          	addi	a0,a0,-1260 # 800088c8 <syscalls+0x1a0>
    80003dbc:	ffffc097          	auipc	ra,0xffffc
    80003dc0:	76e080e7          	jalr	1902(ra) # 8000052a <panic>

0000000080003dc4 <iunlock>:
{
    80003dc4:	1101                	addi	sp,sp,-32
    80003dc6:	ec06                	sd	ra,24(sp)
    80003dc8:	e822                	sd	s0,16(sp)
    80003dca:	e426                	sd	s1,8(sp)
    80003dcc:	e04a                	sd	s2,0(sp)
    80003dce:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003dd0:	c905                	beqz	a0,80003e00 <iunlock+0x3c>
    80003dd2:	84aa                	mv	s1,a0
    80003dd4:	01050913          	addi	s2,a0,16
    80003dd8:	854a                	mv	a0,s2
    80003dda:	00001097          	auipc	ra,0x1
    80003dde:	c90080e7          	jalr	-880(ra) # 80004a6a <holdingsleep>
    80003de2:	cd19                	beqz	a0,80003e00 <iunlock+0x3c>
    80003de4:	449c                	lw	a5,8(s1)
    80003de6:	00f05d63          	blez	a5,80003e00 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003dea:	854a                	mv	a0,s2
    80003dec:	00001097          	auipc	ra,0x1
    80003df0:	c3a080e7          	jalr	-966(ra) # 80004a26 <releasesleep>
}
    80003df4:	60e2                	ld	ra,24(sp)
    80003df6:	6442                	ld	s0,16(sp)
    80003df8:	64a2                	ld	s1,8(sp)
    80003dfa:	6902                	ld	s2,0(sp)
    80003dfc:	6105                	addi	sp,sp,32
    80003dfe:	8082                	ret
    panic("iunlock");
    80003e00:	00005517          	auipc	a0,0x5
    80003e04:	ad850513          	addi	a0,a0,-1320 # 800088d8 <syscalls+0x1b0>
    80003e08:	ffffc097          	auipc	ra,0xffffc
    80003e0c:	722080e7          	jalr	1826(ra) # 8000052a <panic>

0000000080003e10 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003e10:	7179                	addi	sp,sp,-48
    80003e12:	f406                	sd	ra,40(sp)
    80003e14:	f022                	sd	s0,32(sp)
    80003e16:	ec26                	sd	s1,24(sp)
    80003e18:	e84a                	sd	s2,16(sp)
    80003e1a:	e44e                	sd	s3,8(sp)
    80003e1c:	e052                	sd	s4,0(sp)
    80003e1e:	1800                	addi	s0,sp,48
    80003e20:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003e22:	05050493          	addi	s1,a0,80
    80003e26:	08050913          	addi	s2,a0,128
    80003e2a:	a021                	j	80003e32 <itrunc+0x22>
    80003e2c:	0491                	addi	s1,s1,4
    80003e2e:	01248d63          	beq	s1,s2,80003e48 <itrunc+0x38>
    if(ip->addrs[i]){
    80003e32:	408c                	lw	a1,0(s1)
    80003e34:	dde5                	beqz	a1,80003e2c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003e36:	0009a503          	lw	a0,0(s3)
    80003e3a:	00000097          	auipc	ra,0x0
    80003e3e:	90a080e7          	jalr	-1782(ra) # 80003744 <bfree>
      ip->addrs[i] = 0;
    80003e42:	0004a023          	sw	zero,0(s1)
    80003e46:	b7dd                	j	80003e2c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003e48:	0809a583          	lw	a1,128(s3)
    80003e4c:	e185                	bnez	a1,80003e6c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003e4e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003e52:	854e                	mv	a0,s3
    80003e54:	00000097          	auipc	ra,0x0
    80003e58:	de4080e7          	jalr	-540(ra) # 80003c38 <iupdate>
}
    80003e5c:	70a2                	ld	ra,40(sp)
    80003e5e:	7402                	ld	s0,32(sp)
    80003e60:	64e2                	ld	s1,24(sp)
    80003e62:	6942                	ld	s2,16(sp)
    80003e64:	69a2                	ld	s3,8(sp)
    80003e66:	6a02                	ld	s4,0(sp)
    80003e68:	6145                	addi	sp,sp,48
    80003e6a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003e6c:	0009a503          	lw	a0,0(s3)
    80003e70:	fffff097          	auipc	ra,0xfffff
    80003e74:	68e080e7          	jalr	1678(ra) # 800034fe <bread>
    80003e78:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003e7a:	05850493          	addi	s1,a0,88
    80003e7e:	45850913          	addi	s2,a0,1112
    80003e82:	a021                	j	80003e8a <itrunc+0x7a>
    80003e84:	0491                	addi	s1,s1,4
    80003e86:	01248b63          	beq	s1,s2,80003e9c <itrunc+0x8c>
      if(a[j])
    80003e8a:	408c                	lw	a1,0(s1)
    80003e8c:	dde5                	beqz	a1,80003e84 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003e8e:	0009a503          	lw	a0,0(s3)
    80003e92:	00000097          	auipc	ra,0x0
    80003e96:	8b2080e7          	jalr	-1870(ra) # 80003744 <bfree>
    80003e9a:	b7ed                	j	80003e84 <itrunc+0x74>
    brelse(bp);
    80003e9c:	8552                	mv	a0,s4
    80003e9e:	fffff097          	auipc	ra,0xfffff
    80003ea2:	790080e7          	jalr	1936(ra) # 8000362e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ea6:	0809a583          	lw	a1,128(s3)
    80003eaa:	0009a503          	lw	a0,0(s3)
    80003eae:	00000097          	auipc	ra,0x0
    80003eb2:	896080e7          	jalr	-1898(ra) # 80003744 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003eb6:	0809a023          	sw	zero,128(s3)
    80003eba:	bf51                	j	80003e4e <itrunc+0x3e>

0000000080003ebc <iput>:
{
    80003ebc:	1101                	addi	sp,sp,-32
    80003ebe:	ec06                	sd	ra,24(sp)
    80003ec0:	e822                	sd	s0,16(sp)
    80003ec2:	e426                	sd	s1,8(sp)
    80003ec4:	e04a                	sd	s2,0(sp)
    80003ec6:	1000                	addi	s0,sp,32
    80003ec8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003eca:	0001c517          	auipc	a0,0x1c
    80003ece:	2fe50513          	addi	a0,a0,766 # 800201c8 <itable>
    80003ed2:	ffffd097          	auipc	ra,0xffffd
    80003ed6:	cf0080e7          	jalr	-784(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003eda:	4498                	lw	a4,8(s1)
    80003edc:	4785                	li	a5,1
    80003ede:	02f70363          	beq	a4,a5,80003f04 <iput+0x48>
  ip->ref--;
    80003ee2:	449c                	lw	a5,8(s1)
    80003ee4:	37fd                	addiw	a5,a5,-1
    80003ee6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ee8:	0001c517          	auipc	a0,0x1c
    80003eec:	2e050513          	addi	a0,a0,736 # 800201c8 <itable>
    80003ef0:	ffffd097          	auipc	ra,0xffffd
    80003ef4:	d86080e7          	jalr	-634(ra) # 80000c76 <release>
}
    80003ef8:	60e2                	ld	ra,24(sp)
    80003efa:	6442                	ld	s0,16(sp)
    80003efc:	64a2                	ld	s1,8(sp)
    80003efe:	6902                	ld	s2,0(sp)
    80003f00:	6105                	addi	sp,sp,32
    80003f02:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f04:	40bc                	lw	a5,64(s1)
    80003f06:	dff1                	beqz	a5,80003ee2 <iput+0x26>
    80003f08:	04a49783          	lh	a5,74(s1)
    80003f0c:	fbf9                	bnez	a5,80003ee2 <iput+0x26>
    acquiresleep(&ip->lock);
    80003f0e:	01048913          	addi	s2,s1,16
    80003f12:	854a                	mv	a0,s2
    80003f14:	00001097          	auipc	ra,0x1
    80003f18:	abc080e7          	jalr	-1348(ra) # 800049d0 <acquiresleep>
    release(&itable.lock);
    80003f1c:	0001c517          	auipc	a0,0x1c
    80003f20:	2ac50513          	addi	a0,a0,684 # 800201c8 <itable>
    80003f24:	ffffd097          	auipc	ra,0xffffd
    80003f28:	d52080e7          	jalr	-686(ra) # 80000c76 <release>
    itrunc(ip);
    80003f2c:	8526                	mv	a0,s1
    80003f2e:	00000097          	auipc	ra,0x0
    80003f32:	ee2080e7          	jalr	-286(ra) # 80003e10 <itrunc>
    ip->type = 0;
    80003f36:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003f3a:	8526                	mv	a0,s1
    80003f3c:	00000097          	auipc	ra,0x0
    80003f40:	cfc080e7          	jalr	-772(ra) # 80003c38 <iupdate>
    ip->valid = 0;
    80003f44:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003f48:	854a                	mv	a0,s2
    80003f4a:	00001097          	auipc	ra,0x1
    80003f4e:	adc080e7          	jalr	-1316(ra) # 80004a26 <releasesleep>
    acquire(&itable.lock);
    80003f52:	0001c517          	auipc	a0,0x1c
    80003f56:	27650513          	addi	a0,a0,630 # 800201c8 <itable>
    80003f5a:	ffffd097          	auipc	ra,0xffffd
    80003f5e:	c68080e7          	jalr	-920(ra) # 80000bc2 <acquire>
    80003f62:	b741                	j	80003ee2 <iput+0x26>

0000000080003f64 <iunlockput>:
{
    80003f64:	1101                	addi	sp,sp,-32
    80003f66:	ec06                	sd	ra,24(sp)
    80003f68:	e822                	sd	s0,16(sp)
    80003f6a:	e426                	sd	s1,8(sp)
    80003f6c:	1000                	addi	s0,sp,32
    80003f6e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003f70:	00000097          	auipc	ra,0x0
    80003f74:	e54080e7          	jalr	-428(ra) # 80003dc4 <iunlock>
  iput(ip);
    80003f78:	8526                	mv	a0,s1
    80003f7a:	00000097          	auipc	ra,0x0
    80003f7e:	f42080e7          	jalr	-190(ra) # 80003ebc <iput>
}
    80003f82:	60e2                	ld	ra,24(sp)
    80003f84:	6442                	ld	s0,16(sp)
    80003f86:	64a2                	ld	s1,8(sp)
    80003f88:	6105                	addi	sp,sp,32
    80003f8a:	8082                	ret

0000000080003f8c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f8c:	1141                	addi	sp,sp,-16
    80003f8e:	e422                	sd	s0,8(sp)
    80003f90:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f92:	411c                	lw	a5,0(a0)
    80003f94:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f96:	415c                	lw	a5,4(a0)
    80003f98:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f9a:	04451783          	lh	a5,68(a0)
    80003f9e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003fa2:	04a51783          	lh	a5,74(a0)
    80003fa6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003faa:	04c56783          	lwu	a5,76(a0)
    80003fae:	e99c                	sd	a5,16(a1)
}
    80003fb0:	6422                	ld	s0,8(sp)
    80003fb2:	0141                	addi	sp,sp,16
    80003fb4:	8082                	ret

0000000080003fb6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fb6:	457c                	lw	a5,76(a0)
    80003fb8:	0ed7e963          	bltu	a5,a3,800040aa <readi+0xf4>
{
    80003fbc:	7159                	addi	sp,sp,-112
    80003fbe:	f486                	sd	ra,104(sp)
    80003fc0:	f0a2                	sd	s0,96(sp)
    80003fc2:	eca6                	sd	s1,88(sp)
    80003fc4:	e8ca                	sd	s2,80(sp)
    80003fc6:	e4ce                	sd	s3,72(sp)
    80003fc8:	e0d2                	sd	s4,64(sp)
    80003fca:	fc56                	sd	s5,56(sp)
    80003fcc:	f85a                	sd	s6,48(sp)
    80003fce:	f45e                	sd	s7,40(sp)
    80003fd0:	f062                	sd	s8,32(sp)
    80003fd2:	ec66                	sd	s9,24(sp)
    80003fd4:	e86a                	sd	s10,16(sp)
    80003fd6:	e46e                	sd	s11,8(sp)
    80003fd8:	1880                	addi	s0,sp,112
    80003fda:	8baa                	mv	s7,a0
    80003fdc:	8c2e                	mv	s8,a1
    80003fde:	8ab2                	mv	s5,a2
    80003fe0:	84b6                	mv	s1,a3
    80003fe2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003fe4:	9f35                	addw	a4,a4,a3
    return 0;
    80003fe6:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003fe8:	0ad76063          	bltu	a4,a3,80004088 <readi+0xd2>
  if(off + n > ip->size)
    80003fec:	00e7f463          	bgeu	a5,a4,80003ff4 <readi+0x3e>
    n = ip->size - off;
    80003ff0:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ff4:	0a0b0963          	beqz	s6,800040a6 <readi+0xf0>
    80003ff8:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ffa:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ffe:	5cfd                	li	s9,-1
    80004000:	a82d                	j	8000403a <readi+0x84>
    80004002:	020a1d93          	slli	s11,s4,0x20
    80004006:	020ddd93          	srli	s11,s11,0x20
    8000400a:	05890793          	addi	a5,s2,88
    8000400e:	86ee                	mv	a3,s11
    80004010:	963e                	add	a2,a2,a5
    80004012:	85d6                	mv	a1,s5
    80004014:	8562                	mv	a0,s8
    80004016:	ffffe097          	auipc	ra,0xffffe
    8000401a:	6b6080e7          	jalr	1718(ra) # 800026cc <either_copyout>
    8000401e:	05950d63          	beq	a0,s9,80004078 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004022:	854a                	mv	a0,s2
    80004024:	fffff097          	auipc	ra,0xfffff
    80004028:	60a080e7          	jalr	1546(ra) # 8000362e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000402c:	013a09bb          	addw	s3,s4,s3
    80004030:	009a04bb          	addw	s1,s4,s1
    80004034:	9aee                	add	s5,s5,s11
    80004036:	0569f763          	bgeu	s3,s6,80004084 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000403a:	000ba903          	lw	s2,0(s7)
    8000403e:	00a4d59b          	srliw	a1,s1,0xa
    80004042:	855e                	mv	a0,s7
    80004044:	00000097          	auipc	ra,0x0
    80004048:	8ae080e7          	jalr	-1874(ra) # 800038f2 <bmap>
    8000404c:	0005059b          	sext.w	a1,a0
    80004050:	854a                	mv	a0,s2
    80004052:	fffff097          	auipc	ra,0xfffff
    80004056:	4ac080e7          	jalr	1196(ra) # 800034fe <bread>
    8000405a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000405c:	3ff4f613          	andi	a2,s1,1023
    80004060:	40cd07bb          	subw	a5,s10,a2
    80004064:	413b073b          	subw	a4,s6,s3
    80004068:	8a3e                	mv	s4,a5
    8000406a:	2781                	sext.w	a5,a5
    8000406c:	0007069b          	sext.w	a3,a4
    80004070:	f8f6f9e3          	bgeu	a3,a5,80004002 <readi+0x4c>
    80004074:	8a3a                	mv	s4,a4
    80004076:	b771                	j	80004002 <readi+0x4c>
      brelse(bp);
    80004078:	854a                	mv	a0,s2
    8000407a:	fffff097          	auipc	ra,0xfffff
    8000407e:	5b4080e7          	jalr	1460(ra) # 8000362e <brelse>
      tot = -1;
    80004082:	59fd                	li	s3,-1
  }
  return tot;
    80004084:	0009851b          	sext.w	a0,s3
}
    80004088:	70a6                	ld	ra,104(sp)
    8000408a:	7406                	ld	s0,96(sp)
    8000408c:	64e6                	ld	s1,88(sp)
    8000408e:	6946                	ld	s2,80(sp)
    80004090:	69a6                	ld	s3,72(sp)
    80004092:	6a06                	ld	s4,64(sp)
    80004094:	7ae2                	ld	s5,56(sp)
    80004096:	7b42                	ld	s6,48(sp)
    80004098:	7ba2                	ld	s7,40(sp)
    8000409a:	7c02                	ld	s8,32(sp)
    8000409c:	6ce2                	ld	s9,24(sp)
    8000409e:	6d42                	ld	s10,16(sp)
    800040a0:	6da2                	ld	s11,8(sp)
    800040a2:	6165                	addi	sp,sp,112
    800040a4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040a6:	89da                	mv	s3,s6
    800040a8:	bff1                	j	80004084 <readi+0xce>
    return 0;
    800040aa:	4501                	li	a0,0
}
    800040ac:	8082                	ret

00000000800040ae <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800040ae:	457c                	lw	a5,76(a0)
    800040b0:	10d7e863          	bltu	a5,a3,800041c0 <writei+0x112>
{
    800040b4:	7159                	addi	sp,sp,-112
    800040b6:	f486                	sd	ra,104(sp)
    800040b8:	f0a2                	sd	s0,96(sp)
    800040ba:	eca6                	sd	s1,88(sp)
    800040bc:	e8ca                	sd	s2,80(sp)
    800040be:	e4ce                	sd	s3,72(sp)
    800040c0:	e0d2                	sd	s4,64(sp)
    800040c2:	fc56                	sd	s5,56(sp)
    800040c4:	f85a                	sd	s6,48(sp)
    800040c6:	f45e                	sd	s7,40(sp)
    800040c8:	f062                	sd	s8,32(sp)
    800040ca:	ec66                	sd	s9,24(sp)
    800040cc:	e86a                	sd	s10,16(sp)
    800040ce:	e46e                	sd	s11,8(sp)
    800040d0:	1880                	addi	s0,sp,112
    800040d2:	8b2a                	mv	s6,a0
    800040d4:	8c2e                	mv	s8,a1
    800040d6:	8ab2                	mv	s5,a2
    800040d8:	8936                	mv	s2,a3
    800040da:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    800040dc:	00e687bb          	addw	a5,a3,a4
    800040e0:	0ed7e263          	bltu	a5,a3,800041c4 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800040e4:	00043737          	lui	a4,0x43
    800040e8:	0ef76063          	bltu	a4,a5,800041c8 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040ec:	0c0b8863          	beqz	s7,800041bc <writei+0x10e>
    800040f0:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800040f2:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800040f6:	5cfd                	li	s9,-1
    800040f8:	a091                	j	8000413c <writei+0x8e>
    800040fa:	02099d93          	slli	s11,s3,0x20
    800040fe:	020ddd93          	srli	s11,s11,0x20
    80004102:	05848793          	addi	a5,s1,88
    80004106:	86ee                	mv	a3,s11
    80004108:	8656                	mv	a2,s5
    8000410a:	85e2                	mv	a1,s8
    8000410c:	953e                	add	a0,a0,a5
    8000410e:	ffffe097          	auipc	ra,0xffffe
    80004112:	614080e7          	jalr	1556(ra) # 80002722 <either_copyin>
    80004116:	07950263          	beq	a0,s9,8000417a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000411a:	8526                	mv	a0,s1
    8000411c:	00000097          	auipc	ra,0x0
    80004120:	794080e7          	jalr	1940(ra) # 800048b0 <log_write>
    brelse(bp);
    80004124:	8526                	mv	a0,s1
    80004126:	fffff097          	auipc	ra,0xfffff
    8000412a:	508080e7          	jalr	1288(ra) # 8000362e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000412e:	01498a3b          	addw	s4,s3,s4
    80004132:	0129893b          	addw	s2,s3,s2
    80004136:	9aee                	add	s5,s5,s11
    80004138:	057a7663          	bgeu	s4,s7,80004184 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000413c:	000b2483          	lw	s1,0(s6)
    80004140:	00a9559b          	srliw	a1,s2,0xa
    80004144:	855a                	mv	a0,s6
    80004146:	fffff097          	auipc	ra,0xfffff
    8000414a:	7ac080e7          	jalr	1964(ra) # 800038f2 <bmap>
    8000414e:	0005059b          	sext.w	a1,a0
    80004152:	8526                	mv	a0,s1
    80004154:	fffff097          	auipc	ra,0xfffff
    80004158:	3aa080e7          	jalr	938(ra) # 800034fe <bread>
    8000415c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000415e:	3ff97513          	andi	a0,s2,1023
    80004162:	40ad07bb          	subw	a5,s10,a0
    80004166:	414b873b          	subw	a4,s7,s4
    8000416a:	89be                	mv	s3,a5
    8000416c:	2781                	sext.w	a5,a5
    8000416e:	0007069b          	sext.w	a3,a4
    80004172:	f8f6f4e3          	bgeu	a3,a5,800040fa <writei+0x4c>
    80004176:	89ba                	mv	s3,a4
    80004178:	b749                	j	800040fa <writei+0x4c>
      brelse(bp);
    8000417a:	8526                	mv	a0,s1
    8000417c:	fffff097          	auipc	ra,0xfffff
    80004180:	4b2080e7          	jalr	1202(ra) # 8000362e <brelse>
  }

  if(off > ip->size)
    80004184:	04cb2783          	lw	a5,76(s6)
    80004188:	0127f463          	bgeu	a5,s2,80004190 <writei+0xe2>
    ip->size = off;
    8000418c:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004190:	855a                	mv	a0,s6
    80004192:	00000097          	auipc	ra,0x0
    80004196:	aa6080e7          	jalr	-1370(ra) # 80003c38 <iupdate>

  return tot;
    8000419a:	000a051b          	sext.w	a0,s4
}
    8000419e:	70a6                	ld	ra,104(sp)
    800041a0:	7406                	ld	s0,96(sp)
    800041a2:	64e6                	ld	s1,88(sp)
    800041a4:	6946                	ld	s2,80(sp)
    800041a6:	69a6                	ld	s3,72(sp)
    800041a8:	6a06                	ld	s4,64(sp)
    800041aa:	7ae2                	ld	s5,56(sp)
    800041ac:	7b42                	ld	s6,48(sp)
    800041ae:	7ba2                	ld	s7,40(sp)
    800041b0:	7c02                	ld	s8,32(sp)
    800041b2:	6ce2                	ld	s9,24(sp)
    800041b4:	6d42                	ld	s10,16(sp)
    800041b6:	6da2                	ld	s11,8(sp)
    800041b8:	6165                	addi	sp,sp,112
    800041ba:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041bc:	8a5e                	mv	s4,s7
    800041be:	bfc9                	j	80004190 <writei+0xe2>
    return -1;
    800041c0:	557d                	li	a0,-1
}
    800041c2:	8082                	ret
    return -1;
    800041c4:	557d                	li	a0,-1
    800041c6:	bfe1                	j	8000419e <writei+0xf0>
    return -1;
    800041c8:	557d                	li	a0,-1
    800041ca:	bfd1                	j	8000419e <writei+0xf0>

00000000800041cc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800041cc:	1141                	addi	sp,sp,-16
    800041ce:	e406                	sd	ra,8(sp)
    800041d0:	e022                	sd	s0,0(sp)
    800041d2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800041d4:	4639                	li	a2,14
    800041d6:	ffffd097          	auipc	ra,0xffffd
    800041da:	bc0080e7          	jalr	-1088(ra) # 80000d96 <strncmp>
}
    800041de:	60a2                	ld	ra,8(sp)
    800041e0:	6402                	ld	s0,0(sp)
    800041e2:	0141                	addi	sp,sp,16
    800041e4:	8082                	ret

00000000800041e6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800041e6:	7139                	addi	sp,sp,-64
    800041e8:	fc06                	sd	ra,56(sp)
    800041ea:	f822                	sd	s0,48(sp)
    800041ec:	f426                	sd	s1,40(sp)
    800041ee:	f04a                	sd	s2,32(sp)
    800041f0:	ec4e                	sd	s3,24(sp)
    800041f2:	e852                	sd	s4,16(sp)
    800041f4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800041f6:	04451703          	lh	a4,68(a0)
    800041fa:	4785                	li	a5,1
    800041fc:	00f71a63          	bne	a4,a5,80004210 <dirlookup+0x2a>
    80004200:	892a                	mv	s2,a0
    80004202:	89ae                	mv	s3,a1
    80004204:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004206:	457c                	lw	a5,76(a0)
    80004208:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000420a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000420c:	e79d                	bnez	a5,8000423a <dirlookup+0x54>
    8000420e:	a8a5                	j	80004286 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004210:	00004517          	auipc	a0,0x4
    80004214:	6d050513          	addi	a0,a0,1744 # 800088e0 <syscalls+0x1b8>
    80004218:	ffffc097          	auipc	ra,0xffffc
    8000421c:	312080e7          	jalr	786(ra) # 8000052a <panic>
      panic("dirlookup read");
    80004220:	00004517          	auipc	a0,0x4
    80004224:	6d850513          	addi	a0,a0,1752 # 800088f8 <syscalls+0x1d0>
    80004228:	ffffc097          	auipc	ra,0xffffc
    8000422c:	302080e7          	jalr	770(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004230:	24c1                	addiw	s1,s1,16
    80004232:	04c92783          	lw	a5,76(s2)
    80004236:	04f4f763          	bgeu	s1,a5,80004284 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000423a:	4741                	li	a4,16
    8000423c:	86a6                	mv	a3,s1
    8000423e:	fc040613          	addi	a2,s0,-64
    80004242:	4581                	li	a1,0
    80004244:	854a                	mv	a0,s2
    80004246:	00000097          	auipc	ra,0x0
    8000424a:	d70080e7          	jalr	-656(ra) # 80003fb6 <readi>
    8000424e:	47c1                	li	a5,16
    80004250:	fcf518e3          	bne	a0,a5,80004220 <dirlookup+0x3a>
    if(de.inum == 0)
    80004254:	fc045783          	lhu	a5,-64(s0)
    80004258:	dfe1                	beqz	a5,80004230 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000425a:	fc240593          	addi	a1,s0,-62
    8000425e:	854e                	mv	a0,s3
    80004260:	00000097          	auipc	ra,0x0
    80004264:	f6c080e7          	jalr	-148(ra) # 800041cc <namecmp>
    80004268:	f561                	bnez	a0,80004230 <dirlookup+0x4a>
      if(poff)
    8000426a:	000a0463          	beqz	s4,80004272 <dirlookup+0x8c>
        *poff = off;
    8000426e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004272:	fc045583          	lhu	a1,-64(s0)
    80004276:	00092503          	lw	a0,0(s2)
    8000427a:	fffff097          	auipc	ra,0xfffff
    8000427e:	754080e7          	jalr	1876(ra) # 800039ce <iget>
    80004282:	a011                	j	80004286 <dirlookup+0xa0>
  return 0;
    80004284:	4501                	li	a0,0
}
    80004286:	70e2                	ld	ra,56(sp)
    80004288:	7442                	ld	s0,48(sp)
    8000428a:	74a2                	ld	s1,40(sp)
    8000428c:	7902                	ld	s2,32(sp)
    8000428e:	69e2                	ld	s3,24(sp)
    80004290:	6a42                	ld	s4,16(sp)
    80004292:	6121                	addi	sp,sp,64
    80004294:	8082                	ret

0000000080004296 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004296:	711d                	addi	sp,sp,-96
    80004298:	ec86                	sd	ra,88(sp)
    8000429a:	e8a2                	sd	s0,80(sp)
    8000429c:	e4a6                	sd	s1,72(sp)
    8000429e:	e0ca                	sd	s2,64(sp)
    800042a0:	fc4e                	sd	s3,56(sp)
    800042a2:	f852                	sd	s4,48(sp)
    800042a4:	f456                	sd	s5,40(sp)
    800042a6:	f05a                	sd	s6,32(sp)
    800042a8:	ec5e                	sd	s7,24(sp)
    800042aa:	e862                	sd	s8,16(sp)
    800042ac:	e466                	sd	s9,8(sp)
    800042ae:	1080                	addi	s0,sp,96
    800042b0:	84aa                	mv	s1,a0
    800042b2:	8aae                	mv	s5,a1
    800042b4:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800042b6:	00054703          	lbu	a4,0(a0)
    800042ba:	02f00793          	li	a5,47
    800042be:	02f70363          	beq	a4,a5,800042e4 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800042c2:	ffffd097          	auipc	ra,0xffffd
    800042c6:	6bc080e7          	jalr	1724(ra) # 8000197e <myproc>
    800042ca:	17853503          	ld	a0,376(a0)
    800042ce:	00000097          	auipc	ra,0x0
    800042d2:	9f6080e7          	jalr	-1546(ra) # 80003cc4 <idup>
    800042d6:	89aa                	mv	s3,a0
  while(*path == '/')
    800042d8:	02f00913          	li	s2,47
  len = path - s;
    800042dc:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800042de:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800042e0:	4b85                	li	s7,1
    800042e2:	a865                	j	8000439a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800042e4:	4585                	li	a1,1
    800042e6:	4505                	li	a0,1
    800042e8:	fffff097          	auipc	ra,0xfffff
    800042ec:	6e6080e7          	jalr	1766(ra) # 800039ce <iget>
    800042f0:	89aa                	mv	s3,a0
    800042f2:	b7dd                	j	800042d8 <namex+0x42>
      iunlockput(ip);
    800042f4:	854e                	mv	a0,s3
    800042f6:	00000097          	auipc	ra,0x0
    800042fa:	c6e080e7          	jalr	-914(ra) # 80003f64 <iunlockput>
      return 0;
    800042fe:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004300:	854e                	mv	a0,s3
    80004302:	60e6                	ld	ra,88(sp)
    80004304:	6446                	ld	s0,80(sp)
    80004306:	64a6                	ld	s1,72(sp)
    80004308:	6906                	ld	s2,64(sp)
    8000430a:	79e2                	ld	s3,56(sp)
    8000430c:	7a42                	ld	s4,48(sp)
    8000430e:	7aa2                	ld	s5,40(sp)
    80004310:	7b02                	ld	s6,32(sp)
    80004312:	6be2                	ld	s7,24(sp)
    80004314:	6c42                	ld	s8,16(sp)
    80004316:	6ca2                	ld	s9,8(sp)
    80004318:	6125                	addi	sp,sp,96
    8000431a:	8082                	ret
      iunlock(ip);
    8000431c:	854e                	mv	a0,s3
    8000431e:	00000097          	auipc	ra,0x0
    80004322:	aa6080e7          	jalr	-1370(ra) # 80003dc4 <iunlock>
      return ip;
    80004326:	bfe9                	j	80004300 <namex+0x6a>
      iunlockput(ip);
    80004328:	854e                	mv	a0,s3
    8000432a:	00000097          	auipc	ra,0x0
    8000432e:	c3a080e7          	jalr	-966(ra) # 80003f64 <iunlockput>
      return 0;
    80004332:	89e6                	mv	s3,s9
    80004334:	b7f1                	j	80004300 <namex+0x6a>
  len = path - s;
    80004336:	40b48633          	sub	a2,s1,a1
    8000433a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000433e:	099c5463          	bge	s8,s9,800043c6 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004342:	4639                	li	a2,14
    80004344:	8552                	mv	a0,s4
    80004346:	ffffd097          	auipc	ra,0xffffd
    8000434a:	9d4080e7          	jalr	-1580(ra) # 80000d1a <memmove>
  while(*path == '/')
    8000434e:	0004c783          	lbu	a5,0(s1)
    80004352:	01279763          	bne	a5,s2,80004360 <namex+0xca>
    path++;
    80004356:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004358:	0004c783          	lbu	a5,0(s1)
    8000435c:	ff278de3          	beq	a5,s2,80004356 <namex+0xc0>
    ilock(ip);
    80004360:	854e                	mv	a0,s3
    80004362:	00000097          	auipc	ra,0x0
    80004366:	9a0080e7          	jalr	-1632(ra) # 80003d02 <ilock>
    if(ip->type != T_DIR){
    8000436a:	04499783          	lh	a5,68(s3)
    8000436e:	f97793e3          	bne	a5,s7,800042f4 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004372:	000a8563          	beqz	s5,8000437c <namex+0xe6>
    80004376:	0004c783          	lbu	a5,0(s1)
    8000437a:	d3cd                	beqz	a5,8000431c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000437c:	865a                	mv	a2,s6
    8000437e:	85d2                	mv	a1,s4
    80004380:	854e                	mv	a0,s3
    80004382:	00000097          	auipc	ra,0x0
    80004386:	e64080e7          	jalr	-412(ra) # 800041e6 <dirlookup>
    8000438a:	8caa                	mv	s9,a0
    8000438c:	dd51                	beqz	a0,80004328 <namex+0x92>
    iunlockput(ip);
    8000438e:	854e                	mv	a0,s3
    80004390:	00000097          	auipc	ra,0x0
    80004394:	bd4080e7          	jalr	-1068(ra) # 80003f64 <iunlockput>
    ip = next;
    80004398:	89e6                	mv	s3,s9
  while(*path == '/')
    8000439a:	0004c783          	lbu	a5,0(s1)
    8000439e:	05279763          	bne	a5,s2,800043ec <namex+0x156>
    path++;
    800043a2:	0485                	addi	s1,s1,1
  while(*path == '/')
    800043a4:	0004c783          	lbu	a5,0(s1)
    800043a8:	ff278de3          	beq	a5,s2,800043a2 <namex+0x10c>
  if(*path == 0)
    800043ac:	c79d                	beqz	a5,800043da <namex+0x144>
    path++;
    800043ae:	85a6                	mv	a1,s1
  len = path - s;
    800043b0:	8cda                	mv	s9,s6
    800043b2:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800043b4:	01278963          	beq	a5,s2,800043c6 <namex+0x130>
    800043b8:	dfbd                	beqz	a5,80004336 <namex+0xa0>
    path++;
    800043ba:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800043bc:	0004c783          	lbu	a5,0(s1)
    800043c0:	ff279ce3          	bne	a5,s2,800043b8 <namex+0x122>
    800043c4:	bf8d                	j	80004336 <namex+0xa0>
    memmove(name, s, len);
    800043c6:	2601                	sext.w	a2,a2
    800043c8:	8552                	mv	a0,s4
    800043ca:	ffffd097          	auipc	ra,0xffffd
    800043ce:	950080e7          	jalr	-1712(ra) # 80000d1a <memmove>
    name[len] = 0;
    800043d2:	9cd2                	add	s9,s9,s4
    800043d4:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800043d8:	bf9d                	j	8000434e <namex+0xb8>
  if(nameiparent){
    800043da:	f20a83e3          	beqz	s5,80004300 <namex+0x6a>
    iput(ip);
    800043de:	854e                	mv	a0,s3
    800043e0:	00000097          	auipc	ra,0x0
    800043e4:	adc080e7          	jalr	-1316(ra) # 80003ebc <iput>
    return 0;
    800043e8:	4981                	li	s3,0
    800043ea:	bf19                	j	80004300 <namex+0x6a>
  if(*path == 0)
    800043ec:	d7fd                	beqz	a5,800043da <namex+0x144>
  while(*path != '/' && *path != 0)
    800043ee:	0004c783          	lbu	a5,0(s1)
    800043f2:	85a6                	mv	a1,s1
    800043f4:	b7d1                	j	800043b8 <namex+0x122>

00000000800043f6 <dirlink>:
{
    800043f6:	7139                	addi	sp,sp,-64
    800043f8:	fc06                	sd	ra,56(sp)
    800043fa:	f822                	sd	s0,48(sp)
    800043fc:	f426                	sd	s1,40(sp)
    800043fe:	f04a                	sd	s2,32(sp)
    80004400:	ec4e                	sd	s3,24(sp)
    80004402:	e852                	sd	s4,16(sp)
    80004404:	0080                	addi	s0,sp,64
    80004406:	892a                	mv	s2,a0
    80004408:	8a2e                	mv	s4,a1
    8000440a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000440c:	4601                	li	a2,0
    8000440e:	00000097          	auipc	ra,0x0
    80004412:	dd8080e7          	jalr	-552(ra) # 800041e6 <dirlookup>
    80004416:	e93d                	bnez	a0,8000448c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004418:	04c92483          	lw	s1,76(s2)
    8000441c:	c49d                	beqz	s1,8000444a <dirlink+0x54>
    8000441e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004420:	4741                	li	a4,16
    80004422:	86a6                	mv	a3,s1
    80004424:	fc040613          	addi	a2,s0,-64
    80004428:	4581                	li	a1,0
    8000442a:	854a                	mv	a0,s2
    8000442c:	00000097          	auipc	ra,0x0
    80004430:	b8a080e7          	jalr	-1142(ra) # 80003fb6 <readi>
    80004434:	47c1                	li	a5,16
    80004436:	06f51163          	bne	a0,a5,80004498 <dirlink+0xa2>
    if(de.inum == 0)
    8000443a:	fc045783          	lhu	a5,-64(s0)
    8000443e:	c791                	beqz	a5,8000444a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004440:	24c1                	addiw	s1,s1,16
    80004442:	04c92783          	lw	a5,76(s2)
    80004446:	fcf4ede3          	bltu	s1,a5,80004420 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000444a:	4639                	li	a2,14
    8000444c:	85d2                	mv	a1,s4
    8000444e:	fc240513          	addi	a0,s0,-62
    80004452:	ffffd097          	auipc	ra,0xffffd
    80004456:	980080e7          	jalr	-1664(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    8000445a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000445e:	4741                	li	a4,16
    80004460:	86a6                	mv	a3,s1
    80004462:	fc040613          	addi	a2,s0,-64
    80004466:	4581                	li	a1,0
    80004468:	854a                	mv	a0,s2
    8000446a:	00000097          	auipc	ra,0x0
    8000446e:	c44080e7          	jalr	-956(ra) # 800040ae <writei>
    80004472:	872a                	mv	a4,a0
    80004474:	47c1                	li	a5,16
  return 0;
    80004476:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004478:	02f71863          	bne	a4,a5,800044a8 <dirlink+0xb2>
}
    8000447c:	70e2                	ld	ra,56(sp)
    8000447e:	7442                	ld	s0,48(sp)
    80004480:	74a2                	ld	s1,40(sp)
    80004482:	7902                	ld	s2,32(sp)
    80004484:	69e2                	ld	s3,24(sp)
    80004486:	6a42                	ld	s4,16(sp)
    80004488:	6121                	addi	sp,sp,64
    8000448a:	8082                	ret
    iput(ip);
    8000448c:	00000097          	auipc	ra,0x0
    80004490:	a30080e7          	jalr	-1488(ra) # 80003ebc <iput>
    return -1;
    80004494:	557d                	li	a0,-1
    80004496:	b7dd                	j	8000447c <dirlink+0x86>
      panic("dirlink read");
    80004498:	00004517          	auipc	a0,0x4
    8000449c:	47050513          	addi	a0,a0,1136 # 80008908 <syscalls+0x1e0>
    800044a0:	ffffc097          	auipc	ra,0xffffc
    800044a4:	08a080e7          	jalr	138(ra) # 8000052a <panic>
    panic("dirlink");
    800044a8:	00004517          	auipc	a0,0x4
    800044ac:	56850513          	addi	a0,a0,1384 # 80008a10 <syscalls+0x2e8>
    800044b0:	ffffc097          	auipc	ra,0xffffc
    800044b4:	07a080e7          	jalr	122(ra) # 8000052a <panic>

00000000800044b8 <namei>:

struct inode*
namei(char *path)
{
    800044b8:	1101                	addi	sp,sp,-32
    800044ba:	ec06                	sd	ra,24(sp)
    800044bc:	e822                	sd	s0,16(sp)
    800044be:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800044c0:	fe040613          	addi	a2,s0,-32
    800044c4:	4581                	li	a1,0
    800044c6:	00000097          	auipc	ra,0x0
    800044ca:	dd0080e7          	jalr	-560(ra) # 80004296 <namex>
}
    800044ce:	60e2                	ld	ra,24(sp)
    800044d0:	6442                	ld	s0,16(sp)
    800044d2:	6105                	addi	sp,sp,32
    800044d4:	8082                	ret

00000000800044d6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800044d6:	1141                	addi	sp,sp,-16
    800044d8:	e406                	sd	ra,8(sp)
    800044da:	e022                	sd	s0,0(sp)
    800044dc:	0800                	addi	s0,sp,16
    800044de:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800044e0:	4585                	li	a1,1
    800044e2:	00000097          	auipc	ra,0x0
    800044e6:	db4080e7          	jalr	-588(ra) # 80004296 <namex>
}
    800044ea:	60a2                	ld	ra,8(sp)
    800044ec:	6402                	ld	s0,0(sp)
    800044ee:	0141                	addi	sp,sp,16
    800044f0:	8082                	ret

00000000800044f2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800044f2:	1101                	addi	sp,sp,-32
    800044f4:	ec06                	sd	ra,24(sp)
    800044f6:	e822                	sd	s0,16(sp)
    800044f8:	e426                	sd	s1,8(sp)
    800044fa:	e04a                	sd	s2,0(sp)
    800044fc:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800044fe:	0001d917          	auipc	s2,0x1d
    80004502:	77290913          	addi	s2,s2,1906 # 80021c70 <log>
    80004506:	01892583          	lw	a1,24(s2)
    8000450a:	02892503          	lw	a0,40(s2)
    8000450e:	fffff097          	auipc	ra,0xfffff
    80004512:	ff0080e7          	jalr	-16(ra) # 800034fe <bread>
    80004516:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004518:	02c92683          	lw	a3,44(s2)
    8000451c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000451e:	02d05863          	blez	a3,8000454e <write_head+0x5c>
    80004522:	0001d797          	auipc	a5,0x1d
    80004526:	77e78793          	addi	a5,a5,1918 # 80021ca0 <log+0x30>
    8000452a:	05c50713          	addi	a4,a0,92
    8000452e:	36fd                	addiw	a3,a3,-1
    80004530:	02069613          	slli	a2,a3,0x20
    80004534:	01e65693          	srli	a3,a2,0x1e
    80004538:	0001d617          	auipc	a2,0x1d
    8000453c:	76c60613          	addi	a2,a2,1900 # 80021ca4 <log+0x34>
    80004540:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004542:	4390                	lw	a2,0(a5)
    80004544:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004546:	0791                	addi	a5,a5,4
    80004548:	0711                	addi	a4,a4,4
    8000454a:	fed79ce3          	bne	a5,a3,80004542 <write_head+0x50>
  }
  bwrite(buf);
    8000454e:	8526                	mv	a0,s1
    80004550:	fffff097          	auipc	ra,0xfffff
    80004554:	0a0080e7          	jalr	160(ra) # 800035f0 <bwrite>
  brelse(buf);
    80004558:	8526                	mv	a0,s1
    8000455a:	fffff097          	auipc	ra,0xfffff
    8000455e:	0d4080e7          	jalr	212(ra) # 8000362e <brelse>
}
    80004562:	60e2                	ld	ra,24(sp)
    80004564:	6442                	ld	s0,16(sp)
    80004566:	64a2                	ld	s1,8(sp)
    80004568:	6902                	ld	s2,0(sp)
    8000456a:	6105                	addi	sp,sp,32
    8000456c:	8082                	ret

000000008000456e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000456e:	0001d797          	auipc	a5,0x1d
    80004572:	72e7a783          	lw	a5,1838(a5) # 80021c9c <log+0x2c>
    80004576:	0af05d63          	blez	a5,80004630 <install_trans+0xc2>
{
    8000457a:	7139                	addi	sp,sp,-64
    8000457c:	fc06                	sd	ra,56(sp)
    8000457e:	f822                	sd	s0,48(sp)
    80004580:	f426                	sd	s1,40(sp)
    80004582:	f04a                	sd	s2,32(sp)
    80004584:	ec4e                	sd	s3,24(sp)
    80004586:	e852                	sd	s4,16(sp)
    80004588:	e456                	sd	s5,8(sp)
    8000458a:	e05a                	sd	s6,0(sp)
    8000458c:	0080                	addi	s0,sp,64
    8000458e:	8b2a                	mv	s6,a0
    80004590:	0001da97          	auipc	s5,0x1d
    80004594:	710a8a93          	addi	s5,s5,1808 # 80021ca0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004598:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000459a:	0001d997          	auipc	s3,0x1d
    8000459e:	6d698993          	addi	s3,s3,1750 # 80021c70 <log>
    800045a2:	a00d                	j	800045c4 <install_trans+0x56>
    brelse(lbuf);
    800045a4:	854a                	mv	a0,s2
    800045a6:	fffff097          	auipc	ra,0xfffff
    800045aa:	088080e7          	jalr	136(ra) # 8000362e <brelse>
    brelse(dbuf);
    800045ae:	8526                	mv	a0,s1
    800045b0:	fffff097          	auipc	ra,0xfffff
    800045b4:	07e080e7          	jalr	126(ra) # 8000362e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045b8:	2a05                	addiw	s4,s4,1
    800045ba:	0a91                	addi	s5,s5,4
    800045bc:	02c9a783          	lw	a5,44(s3)
    800045c0:	04fa5e63          	bge	s4,a5,8000461c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800045c4:	0189a583          	lw	a1,24(s3)
    800045c8:	014585bb          	addw	a1,a1,s4
    800045cc:	2585                	addiw	a1,a1,1
    800045ce:	0289a503          	lw	a0,40(s3)
    800045d2:	fffff097          	auipc	ra,0xfffff
    800045d6:	f2c080e7          	jalr	-212(ra) # 800034fe <bread>
    800045da:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800045dc:	000aa583          	lw	a1,0(s5)
    800045e0:	0289a503          	lw	a0,40(s3)
    800045e4:	fffff097          	auipc	ra,0xfffff
    800045e8:	f1a080e7          	jalr	-230(ra) # 800034fe <bread>
    800045ec:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800045ee:	40000613          	li	a2,1024
    800045f2:	05890593          	addi	a1,s2,88
    800045f6:	05850513          	addi	a0,a0,88
    800045fa:	ffffc097          	auipc	ra,0xffffc
    800045fe:	720080e7          	jalr	1824(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004602:	8526                	mv	a0,s1
    80004604:	fffff097          	auipc	ra,0xfffff
    80004608:	fec080e7          	jalr	-20(ra) # 800035f0 <bwrite>
    if(recovering == 0)
    8000460c:	f80b1ce3          	bnez	s6,800045a4 <install_trans+0x36>
      bunpin(dbuf);
    80004610:	8526                	mv	a0,s1
    80004612:	fffff097          	auipc	ra,0xfffff
    80004616:	0f6080e7          	jalr	246(ra) # 80003708 <bunpin>
    8000461a:	b769                	j	800045a4 <install_trans+0x36>
}
    8000461c:	70e2                	ld	ra,56(sp)
    8000461e:	7442                	ld	s0,48(sp)
    80004620:	74a2                	ld	s1,40(sp)
    80004622:	7902                	ld	s2,32(sp)
    80004624:	69e2                	ld	s3,24(sp)
    80004626:	6a42                	ld	s4,16(sp)
    80004628:	6aa2                	ld	s5,8(sp)
    8000462a:	6b02                	ld	s6,0(sp)
    8000462c:	6121                	addi	sp,sp,64
    8000462e:	8082                	ret
    80004630:	8082                	ret

0000000080004632 <initlog>:
{
    80004632:	7179                	addi	sp,sp,-48
    80004634:	f406                	sd	ra,40(sp)
    80004636:	f022                	sd	s0,32(sp)
    80004638:	ec26                	sd	s1,24(sp)
    8000463a:	e84a                	sd	s2,16(sp)
    8000463c:	e44e                	sd	s3,8(sp)
    8000463e:	1800                	addi	s0,sp,48
    80004640:	892a                	mv	s2,a0
    80004642:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004644:	0001d497          	auipc	s1,0x1d
    80004648:	62c48493          	addi	s1,s1,1580 # 80021c70 <log>
    8000464c:	00004597          	auipc	a1,0x4
    80004650:	2cc58593          	addi	a1,a1,716 # 80008918 <syscalls+0x1f0>
    80004654:	8526                	mv	a0,s1
    80004656:	ffffc097          	auipc	ra,0xffffc
    8000465a:	4dc080e7          	jalr	1244(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    8000465e:	0149a583          	lw	a1,20(s3)
    80004662:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004664:	0109a783          	lw	a5,16(s3)
    80004668:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000466a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000466e:	854a                	mv	a0,s2
    80004670:	fffff097          	auipc	ra,0xfffff
    80004674:	e8e080e7          	jalr	-370(ra) # 800034fe <bread>
  log.lh.n = lh->n;
    80004678:	4d34                	lw	a3,88(a0)
    8000467a:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000467c:	02d05663          	blez	a3,800046a8 <initlog+0x76>
    80004680:	05c50793          	addi	a5,a0,92
    80004684:	0001d717          	auipc	a4,0x1d
    80004688:	61c70713          	addi	a4,a4,1564 # 80021ca0 <log+0x30>
    8000468c:	36fd                	addiw	a3,a3,-1
    8000468e:	02069613          	slli	a2,a3,0x20
    80004692:	01e65693          	srli	a3,a2,0x1e
    80004696:	06050613          	addi	a2,a0,96
    8000469a:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000469c:	4390                	lw	a2,0(a5)
    8000469e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800046a0:	0791                	addi	a5,a5,4
    800046a2:	0711                	addi	a4,a4,4
    800046a4:	fed79ce3          	bne	a5,a3,8000469c <initlog+0x6a>
  brelse(buf);
    800046a8:	fffff097          	auipc	ra,0xfffff
    800046ac:	f86080e7          	jalr	-122(ra) # 8000362e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800046b0:	4505                	li	a0,1
    800046b2:	00000097          	auipc	ra,0x0
    800046b6:	ebc080e7          	jalr	-324(ra) # 8000456e <install_trans>
  log.lh.n = 0;
    800046ba:	0001d797          	auipc	a5,0x1d
    800046be:	5e07a123          	sw	zero,1506(a5) # 80021c9c <log+0x2c>
  write_head(); // clear the log
    800046c2:	00000097          	auipc	ra,0x0
    800046c6:	e30080e7          	jalr	-464(ra) # 800044f2 <write_head>
}
    800046ca:	70a2                	ld	ra,40(sp)
    800046cc:	7402                	ld	s0,32(sp)
    800046ce:	64e2                	ld	s1,24(sp)
    800046d0:	6942                	ld	s2,16(sp)
    800046d2:	69a2                	ld	s3,8(sp)
    800046d4:	6145                	addi	sp,sp,48
    800046d6:	8082                	ret

00000000800046d8 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800046d8:	1101                	addi	sp,sp,-32
    800046da:	ec06                	sd	ra,24(sp)
    800046dc:	e822                	sd	s0,16(sp)
    800046de:	e426                	sd	s1,8(sp)
    800046e0:	e04a                	sd	s2,0(sp)
    800046e2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800046e4:	0001d517          	auipc	a0,0x1d
    800046e8:	58c50513          	addi	a0,a0,1420 # 80021c70 <log>
    800046ec:	ffffc097          	auipc	ra,0xffffc
    800046f0:	4d6080e7          	jalr	1238(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    800046f4:	0001d497          	auipc	s1,0x1d
    800046f8:	57c48493          	addi	s1,s1,1404 # 80021c70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046fc:	4979                	li	s2,30
    800046fe:	a039                	j	8000470c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004700:	85a6                	mv	a1,s1
    80004702:	8526                	mv	a0,s1
    80004704:	ffffe097          	auipc	ra,0xffffe
    80004708:	bfc080e7          	jalr	-1028(ra) # 80002300 <sleep>
    if(log.committing){
    8000470c:	50dc                	lw	a5,36(s1)
    8000470e:	fbed                	bnez	a5,80004700 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004710:	509c                	lw	a5,32(s1)
    80004712:	0017871b          	addiw	a4,a5,1
    80004716:	0007069b          	sext.w	a3,a4
    8000471a:	0027179b          	slliw	a5,a4,0x2
    8000471e:	9fb9                	addw	a5,a5,a4
    80004720:	0017979b          	slliw	a5,a5,0x1
    80004724:	54d8                	lw	a4,44(s1)
    80004726:	9fb9                	addw	a5,a5,a4
    80004728:	00f95963          	bge	s2,a5,8000473a <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000472c:	85a6                	mv	a1,s1
    8000472e:	8526                	mv	a0,s1
    80004730:	ffffe097          	auipc	ra,0xffffe
    80004734:	bd0080e7          	jalr	-1072(ra) # 80002300 <sleep>
    80004738:	bfd1                	j	8000470c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000473a:	0001d517          	auipc	a0,0x1d
    8000473e:	53650513          	addi	a0,a0,1334 # 80021c70 <log>
    80004742:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004744:	ffffc097          	auipc	ra,0xffffc
    80004748:	532080e7          	jalr	1330(ra) # 80000c76 <release>
      break;
    }
  }
}
    8000474c:	60e2                	ld	ra,24(sp)
    8000474e:	6442                	ld	s0,16(sp)
    80004750:	64a2                	ld	s1,8(sp)
    80004752:	6902                	ld	s2,0(sp)
    80004754:	6105                	addi	sp,sp,32
    80004756:	8082                	ret

0000000080004758 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004758:	7139                	addi	sp,sp,-64
    8000475a:	fc06                	sd	ra,56(sp)
    8000475c:	f822                	sd	s0,48(sp)
    8000475e:	f426                	sd	s1,40(sp)
    80004760:	f04a                	sd	s2,32(sp)
    80004762:	ec4e                	sd	s3,24(sp)
    80004764:	e852                	sd	s4,16(sp)
    80004766:	e456                	sd	s5,8(sp)
    80004768:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000476a:	0001d497          	auipc	s1,0x1d
    8000476e:	50648493          	addi	s1,s1,1286 # 80021c70 <log>
    80004772:	8526                	mv	a0,s1
    80004774:	ffffc097          	auipc	ra,0xffffc
    80004778:	44e080e7          	jalr	1102(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    8000477c:	509c                	lw	a5,32(s1)
    8000477e:	37fd                	addiw	a5,a5,-1
    80004780:	0007891b          	sext.w	s2,a5
    80004784:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004786:	50dc                	lw	a5,36(s1)
    80004788:	e7b9                	bnez	a5,800047d6 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000478a:	04091e63          	bnez	s2,800047e6 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000478e:	0001d497          	auipc	s1,0x1d
    80004792:	4e248493          	addi	s1,s1,1250 # 80021c70 <log>
    80004796:	4785                	li	a5,1
    80004798:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000479a:	8526                	mv	a0,s1
    8000479c:	ffffc097          	auipc	ra,0xffffc
    800047a0:	4da080e7          	jalr	1242(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800047a4:	54dc                	lw	a5,44(s1)
    800047a6:	06f04763          	bgtz	a5,80004814 <end_op+0xbc>
    acquire(&log.lock);
    800047aa:	0001d497          	auipc	s1,0x1d
    800047ae:	4c648493          	addi	s1,s1,1222 # 80021c70 <log>
    800047b2:	8526                	mv	a0,s1
    800047b4:	ffffc097          	auipc	ra,0xffffc
    800047b8:	40e080e7          	jalr	1038(ra) # 80000bc2 <acquire>
    log.committing = 0;
    800047bc:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800047c0:	8526                	mv	a0,s1
    800047c2:	ffffe097          	auipc	ra,0xffffe
    800047c6:	cca080e7          	jalr	-822(ra) # 8000248c <wakeup>
    release(&log.lock);
    800047ca:	8526                	mv	a0,s1
    800047cc:	ffffc097          	auipc	ra,0xffffc
    800047d0:	4aa080e7          	jalr	1194(ra) # 80000c76 <release>
}
    800047d4:	a03d                	j	80004802 <end_op+0xaa>
    panic("log.committing");
    800047d6:	00004517          	auipc	a0,0x4
    800047da:	14a50513          	addi	a0,a0,330 # 80008920 <syscalls+0x1f8>
    800047de:	ffffc097          	auipc	ra,0xffffc
    800047e2:	d4c080e7          	jalr	-692(ra) # 8000052a <panic>
    wakeup(&log);
    800047e6:	0001d497          	auipc	s1,0x1d
    800047ea:	48a48493          	addi	s1,s1,1162 # 80021c70 <log>
    800047ee:	8526                	mv	a0,s1
    800047f0:	ffffe097          	auipc	ra,0xffffe
    800047f4:	c9c080e7          	jalr	-868(ra) # 8000248c <wakeup>
  release(&log.lock);
    800047f8:	8526                	mv	a0,s1
    800047fa:	ffffc097          	auipc	ra,0xffffc
    800047fe:	47c080e7          	jalr	1148(ra) # 80000c76 <release>
}
    80004802:	70e2                	ld	ra,56(sp)
    80004804:	7442                	ld	s0,48(sp)
    80004806:	74a2                	ld	s1,40(sp)
    80004808:	7902                	ld	s2,32(sp)
    8000480a:	69e2                	ld	s3,24(sp)
    8000480c:	6a42                	ld	s4,16(sp)
    8000480e:	6aa2                	ld	s5,8(sp)
    80004810:	6121                	addi	sp,sp,64
    80004812:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004814:	0001da97          	auipc	s5,0x1d
    80004818:	48ca8a93          	addi	s5,s5,1164 # 80021ca0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000481c:	0001da17          	auipc	s4,0x1d
    80004820:	454a0a13          	addi	s4,s4,1108 # 80021c70 <log>
    80004824:	018a2583          	lw	a1,24(s4)
    80004828:	012585bb          	addw	a1,a1,s2
    8000482c:	2585                	addiw	a1,a1,1
    8000482e:	028a2503          	lw	a0,40(s4)
    80004832:	fffff097          	auipc	ra,0xfffff
    80004836:	ccc080e7          	jalr	-820(ra) # 800034fe <bread>
    8000483a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000483c:	000aa583          	lw	a1,0(s5)
    80004840:	028a2503          	lw	a0,40(s4)
    80004844:	fffff097          	auipc	ra,0xfffff
    80004848:	cba080e7          	jalr	-838(ra) # 800034fe <bread>
    8000484c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000484e:	40000613          	li	a2,1024
    80004852:	05850593          	addi	a1,a0,88
    80004856:	05848513          	addi	a0,s1,88
    8000485a:	ffffc097          	auipc	ra,0xffffc
    8000485e:	4c0080e7          	jalr	1216(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004862:	8526                	mv	a0,s1
    80004864:	fffff097          	auipc	ra,0xfffff
    80004868:	d8c080e7          	jalr	-628(ra) # 800035f0 <bwrite>
    brelse(from);
    8000486c:	854e                	mv	a0,s3
    8000486e:	fffff097          	auipc	ra,0xfffff
    80004872:	dc0080e7          	jalr	-576(ra) # 8000362e <brelse>
    brelse(to);
    80004876:	8526                	mv	a0,s1
    80004878:	fffff097          	auipc	ra,0xfffff
    8000487c:	db6080e7          	jalr	-586(ra) # 8000362e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004880:	2905                	addiw	s2,s2,1
    80004882:	0a91                	addi	s5,s5,4
    80004884:	02ca2783          	lw	a5,44(s4)
    80004888:	f8f94ee3          	blt	s2,a5,80004824 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000488c:	00000097          	auipc	ra,0x0
    80004890:	c66080e7          	jalr	-922(ra) # 800044f2 <write_head>
    install_trans(0); // Now install writes to home locations
    80004894:	4501                	li	a0,0
    80004896:	00000097          	auipc	ra,0x0
    8000489a:	cd8080e7          	jalr	-808(ra) # 8000456e <install_trans>
    log.lh.n = 0;
    8000489e:	0001d797          	auipc	a5,0x1d
    800048a2:	3e07af23          	sw	zero,1022(a5) # 80021c9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800048a6:	00000097          	auipc	ra,0x0
    800048aa:	c4c080e7          	jalr	-948(ra) # 800044f2 <write_head>
    800048ae:	bdf5                	j	800047aa <end_op+0x52>

00000000800048b0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800048b0:	1101                	addi	sp,sp,-32
    800048b2:	ec06                	sd	ra,24(sp)
    800048b4:	e822                	sd	s0,16(sp)
    800048b6:	e426                	sd	s1,8(sp)
    800048b8:	e04a                	sd	s2,0(sp)
    800048ba:	1000                	addi	s0,sp,32
    800048bc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800048be:	0001d917          	auipc	s2,0x1d
    800048c2:	3b290913          	addi	s2,s2,946 # 80021c70 <log>
    800048c6:	854a                	mv	a0,s2
    800048c8:	ffffc097          	auipc	ra,0xffffc
    800048cc:	2fa080e7          	jalr	762(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800048d0:	02c92603          	lw	a2,44(s2)
    800048d4:	47f5                	li	a5,29
    800048d6:	06c7c563          	blt	a5,a2,80004940 <log_write+0x90>
    800048da:	0001d797          	auipc	a5,0x1d
    800048de:	3b27a783          	lw	a5,946(a5) # 80021c8c <log+0x1c>
    800048e2:	37fd                	addiw	a5,a5,-1
    800048e4:	04f65e63          	bge	a2,a5,80004940 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800048e8:	0001d797          	auipc	a5,0x1d
    800048ec:	3a87a783          	lw	a5,936(a5) # 80021c90 <log+0x20>
    800048f0:	06f05063          	blez	a5,80004950 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800048f4:	4781                	li	a5,0
    800048f6:	06c05563          	blez	a2,80004960 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800048fa:	44cc                	lw	a1,12(s1)
    800048fc:	0001d717          	auipc	a4,0x1d
    80004900:	3a470713          	addi	a4,a4,932 # 80021ca0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004904:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004906:	4314                	lw	a3,0(a4)
    80004908:	04b68c63          	beq	a3,a1,80004960 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000490c:	2785                	addiw	a5,a5,1
    8000490e:	0711                	addi	a4,a4,4
    80004910:	fef61be3          	bne	a2,a5,80004906 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004914:	0621                	addi	a2,a2,8
    80004916:	060a                	slli	a2,a2,0x2
    80004918:	0001d797          	auipc	a5,0x1d
    8000491c:	35878793          	addi	a5,a5,856 # 80021c70 <log>
    80004920:	963e                	add	a2,a2,a5
    80004922:	44dc                	lw	a5,12(s1)
    80004924:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004926:	8526                	mv	a0,s1
    80004928:	fffff097          	auipc	ra,0xfffff
    8000492c:	da4080e7          	jalr	-604(ra) # 800036cc <bpin>
    log.lh.n++;
    80004930:	0001d717          	auipc	a4,0x1d
    80004934:	34070713          	addi	a4,a4,832 # 80021c70 <log>
    80004938:	575c                	lw	a5,44(a4)
    8000493a:	2785                	addiw	a5,a5,1
    8000493c:	d75c                	sw	a5,44(a4)
    8000493e:	a835                	j	8000497a <log_write+0xca>
    panic("too big a transaction");
    80004940:	00004517          	auipc	a0,0x4
    80004944:	ff050513          	addi	a0,a0,-16 # 80008930 <syscalls+0x208>
    80004948:	ffffc097          	auipc	ra,0xffffc
    8000494c:	be2080e7          	jalr	-1054(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004950:	00004517          	auipc	a0,0x4
    80004954:	ff850513          	addi	a0,a0,-8 # 80008948 <syscalls+0x220>
    80004958:	ffffc097          	auipc	ra,0xffffc
    8000495c:	bd2080e7          	jalr	-1070(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004960:	00878713          	addi	a4,a5,8
    80004964:	00271693          	slli	a3,a4,0x2
    80004968:	0001d717          	auipc	a4,0x1d
    8000496c:	30870713          	addi	a4,a4,776 # 80021c70 <log>
    80004970:	9736                	add	a4,a4,a3
    80004972:	44d4                	lw	a3,12(s1)
    80004974:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004976:	faf608e3          	beq	a2,a5,80004926 <log_write+0x76>
  }
  release(&log.lock);
    8000497a:	0001d517          	auipc	a0,0x1d
    8000497e:	2f650513          	addi	a0,a0,758 # 80021c70 <log>
    80004982:	ffffc097          	auipc	ra,0xffffc
    80004986:	2f4080e7          	jalr	756(ra) # 80000c76 <release>
}
    8000498a:	60e2                	ld	ra,24(sp)
    8000498c:	6442                	ld	s0,16(sp)
    8000498e:	64a2                	ld	s1,8(sp)
    80004990:	6902                	ld	s2,0(sp)
    80004992:	6105                	addi	sp,sp,32
    80004994:	8082                	ret

0000000080004996 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004996:	1101                	addi	sp,sp,-32
    80004998:	ec06                	sd	ra,24(sp)
    8000499a:	e822                	sd	s0,16(sp)
    8000499c:	e426                	sd	s1,8(sp)
    8000499e:	e04a                	sd	s2,0(sp)
    800049a0:	1000                	addi	s0,sp,32
    800049a2:	84aa                	mv	s1,a0
    800049a4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800049a6:	00004597          	auipc	a1,0x4
    800049aa:	fc258593          	addi	a1,a1,-62 # 80008968 <syscalls+0x240>
    800049ae:	0521                	addi	a0,a0,8
    800049b0:	ffffc097          	auipc	ra,0xffffc
    800049b4:	182080e7          	jalr	386(ra) # 80000b32 <initlock>
  lk->name = name;
    800049b8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800049bc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049c0:	0204a423          	sw	zero,40(s1)
}
    800049c4:	60e2                	ld	ra,24(sp)
    800049c6:	6442                	ld	s0,16(sp)
    800049c8:	64a2                	ld	s1,8(sp)
    800049ca:	6902                	ld	s2,0(sp)
    800049cc:	6105                	addi	sp,sp,32
    800049ce:	8082                	ret

00000000800049d0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800049d0:	1101                	addi	sp,sp,-32
    800049d2:	ec06                	sd	ra,24(sp)
    800049d4:	e822                	sd	s0,16(sp)
    800049d6:	e426                	sd	s1,8(sp)
    800049d8:	e04a                	sd	s2,0(sp)
    800049da:	1000                	addi	s0,sp,32
    800049dc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049de:	00850913          	addi	s2,a0,8
    800049e2:	854a                	mv	a0,s2
    800049e4:	ffffc097          	auipc	ra,0xffffc
    800049e8:	1de080e7          	jalr	478(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    800049ec:	409c                	lw	a5,0(s1)
    800049ee:	cb89                	beqz	a5,80004a00 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800049f0:	85ca                	mv	a1,s2
    800049f2:	8526                	mv	a0,s1
    800049f4:	ffffe097          	auipc	ra,0xffffe
    800049f8:	90c080e7          	jalr	-1780(ra) # 80002300 <sleep>
  while (lk->locked) {
    800049fc:	409c                	lw	a5,0(s1)
    800049fe:	fbed                	bnez	a5,800049f0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004a00:	4785                	li	a5,1
    80004a02:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004a04:	ffffd097          	auipc	ra,0xffffd
    80004a08:	f7a080e7          	jalr	-134(ra) # 8000197e <myproc>
    80004a0c:	591c                	lw	a5,48(a0)
    80004a0e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004a10:	854a                	mv	a0,s2
    80004a12:	ffffc097          	auipc	ra,0xffffc
    80004a16:	264080e7          	jalr	612(ra) # 80000c76 <release>
}
    80004a1a:	60e2                	ld	ra,24(sp)
    80004a1c:	6442                	ld	s0,16(sp)
    80004a1e:	64a2                	ld	s1,8(sp)
    80004a20:	6902                	ld	s2,0(sp)
    80004a22:	6105                	addi	sp,sp,32
    80004a24:	8082                	ret

0000000080004a26 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004a26:	1101                	addi	sp,sp,-32
    80004a28:	ec06                	sd	ra,24(sp)
    80004a2a:	e822                	sd	s0,16(sp)
    80004a2c:	e426                	sd	s1,8(sp)
    80004a2e:	e04a                	sd	s2,0(sp)
    80004a30:	1000                	addi	s0,sp,32
    80004a32:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a34:	00850913          	addi	s2,a0,8
    80004a38:	854a                	mv	a0,s2
    80004a3a:	ffffc097          	auipc	ra,0xffffc
    80004a3e:	188080e7          	jalr	392(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80004a42:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a46:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004a4a:	8526                	mv	a0,s1
    80004a4c:	ffffe097          	auipc	ra,0xffffe
    80004a50:	a40080e7          	jalr	-1472(ra) # 8000248c <wakeup>
  release(&lk->lk);
    80004a54:	854a                	mv	a0,s2
    80004a56:	ffffc097          	auipc	ra,0xffffc
    80004a5a:	220080e7          	jalr	544(ra) # 80000c76 <release>
}
    80004a5e:	60e2                	ld	ra,24(sp)
    80004a60:	6442                	ld	s0,16(sp)
    80004a62:	64a2                	ld	s1,8(sp)
    80004a64:	6902                	ld	s2,0(sp)
    80004a66:	6105                	addi	sp,sp,32
    80004a68:	8082                	ret

0000000080004a6a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a6a:	7179                	addi	sp,sp,-48
    80004a6c:	f406                	sd	ra,40(sp)
    80004a6e:	f022                	sd	s0,32(sp)
    80004a70:	ec26                	sd	s1,24(sp)
    80004a72:	e84a                	sd	s2,16(sp)
    80004a74:	e44e                	sd	s3,8(sp)
    80004a76:	1800                	addi	s0,sp,48
    80004a78:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a7a:	00850913          	addi	s2,a0,8
    80004a7e:	854a                	mv	a0,s2
    80004a80:	ffffc097          	auipc	ra,0xffffc
    80004a84:	142080e7          	jalr	322(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a88:	409c                	lw	a5,0(s1)
    80004a8a:	ef99                	bnez	a5,80004aa8 <holdingsleep+0x3e>
    80004a8c:	4481                	li	s1,0
  release(&lk->lk);
    80004a8e:	854a                	mv	a0,s2
    80004a90:	ffffc097          	auipc	ra,0xffffc
    80004a94:	1e6080e7          	jalr	486(ra) # 80000c76 <release>
  return r;
}
    80004a98:	8526                	mv	a0,s1
    80004a9a:	70a2                	ld	ra,40(sp)
    80004a9c:	7402                	ld	s0,32(sp)
    80004a9e:	64e2                	ld	s1,24(sp)
    80004aa0:	6942                	ld	s2,16(sp)
    80004aa2:	69a2                	ld	s3,8(sp)
    80004aa4:	6145                	addi	sp,sp,48
    80004aa6:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004aa8:	0284a983          	lw	s3,40(s1)
    80004aac:	ffffd097          	auipc	ra,0xffffd
    80004ab0:	ed2080e7          	jalr	-302(ra) # 8000197e <myproc>
    80004ab4:	5904                	lw	s1,48(a0)
    80004ab6:	413484b3          	sub	s1,s1,s3
    80004aba:	0014b493          	seqz	s1,s1
    80004abe:	bfc1                	j	80004a8e <holdingsleep+0x24>

0000000080004ac0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004ac0:	1141                	addi	sp,sp,-16
    80004ac2:	e406                	sd	ra,8(sp)
    80004ac4:	e022                	sd	s0,0(sp)
    80004ac6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004ac8:	00004597          	auipc	a1,0x4
    80004acc:	eb058593          	addi	a1,a1,-336 # 80008978 <syscalls+0x250>
    80004ad0:	0001d517          	auipc	a0,0x1d
    80004ad4:	2e850513          	addi	a0,a0,744 # 80021db8 <ftable>
    80004ad8:	ffffc097          	auipc	ra,0xffffc
    80004adc:	05a080e7          	jalr	90(ra) # 80000b32 <initlock>
}
    80004ae0:	60a2                	ld	ra,8(sp)
    80004ae2:	6402                	ld	s0,0(sp)
    80004ae4:	0141                	addi	sp,sp,16
    80004ae6:	8082                	ret

0000000080004ae8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004ae8:	1101                	addi	sp,sp,-32
    80004aea:	ec06                	sd	ra,24(sp)
    80004aec:	e822                	sd	s0,16(sp)
    80004aee:	e426                	sd	s1,8(sp)
    80004af0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004af2:	0001d517          	auipc	a0,0x1d
    80004af6:	2c650513          	addi	a0,a0,710 # 80021db8 <ftable>
    80004afa:	ffffc097          	auipc	ra,0xffffc
    80004afe:	0c8080e7          	jalr	200(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b02:	0001d497          	auipc	s1,0x1d
    80004b06:	2ce48493          	addi	s1,s1,718 # 80021dd0 <ftable+0x18>
    80004b0a:	0001e717          	auipc	a4,0x1e
    80004b0e:	26670713          	addi	a4,a4,614 # 80022d70 <ftable+0xfb8>
    if(f->ref == 0){
    80004b12:	40dc                	lw	a5,4(s1)
    80004b14:	cf99                	beqz	a5,80004b32 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b16:	02848493          	addi	s1,s1,40
    80004b1a:	fee49ce3          	bne	s1,a4,80004b12 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004b1e:	0001d517          	auipc	a0,0x1d
    80004b22:	29a50513          	addi	a0,a0,666 # 80021db8 <ftable>
    80004b26:	ffffc097          	auipc	ra,0xffffc
    80004b2a:	150080e7          	jalr	336(ra) # 80000c76 <release>
  return 0;
    80004b2e:	4481                	li	s1,0
    80004b30:	a819                	j	80004b46 <filealloc+0x5e>
      f->ref = 1;
    80004b32:	4785                	li	a5,1
    80004b34:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004b36:	0001d517          	auipc	a0,0x1d
    80004b3a:	28250513          	addi	a0,a0,642 # 80021db8 <ftable>
    80004b3e:	ffffc097          	auipc	ra,0xffffc
    80004b42:	138080e7          	jalr	312(ra) # 80000c76 <release>
}
    80004b46:	8526                	mv	a0,s1
    80004b48:	60e2                	ld	ra,24(sp)
    80004b4a:	6442                	ld	s0,16(sp)
    80004b4c:	64a2                	ld	s1,8(sp)
    80004b4e:	6105                	addi	sp,sp,32
    80004b50:	8082                	ret

0000000080004b52 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b52:	1101                	addi	sp,sp,-32
    80004b54:	ec06                	sd	ra,24(sp)
    80004b56:	e822                	sd	s0,16(sp)
    80004b58:	e426                	sd	s1,8(sp)
    80004b5a:	1000                	addi	s0,sp,32
    80004b5c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b5e:	0001d517          	auipc	a0,0x1d
    80004b62:	25a50513          	addi	a0,a0,602 # 80021db8 <ftable>
    80004b66:	ffffc097          	auipc	ra,0xffffc
    80004b6a:	05c080e7          	jalr	92(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004b6e:	40dc                	lw	a5,4(s1)
    80004b70:	02f05263          	blez	a5,80004b94 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b74:	2785                	addiw	a5,a5,1
    80004b76:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b78:	0001d517          	auipc	a0,0x1d
    80004b7c:	24050513          	addi	a0,a0,576 # 80021db8 <ftable>
    80004b80:	ffffc097          	auipc	ra,0xffffc
    80004b84:	0f6080e7          	jalr	246(ra) # 80000c76 <release>
  return f;
}
    80004b88:	8526                	mv	a0,s1
    80004b8a:	60e2                	ld	ra,24(sp)
    80004b8c:	6442                	ld	s0,16(sp)
    80004b8e:	64a2                	ld	s1,8(sp)
    80004b90:	6105                	addi	sp,sp,32
    80004b92:	8082                	ret
    panic("filedup");
    80004b94:	00004517          	auipc	a0,0x4
    80004b98:	dec50513          	addi	a0,a0,-532 # 80008980 <syscalls+0x258>
    80004b9c:	ffffc097          	auipc	ra,0xffffc
    80004ba0:	98e080e7          	jalr	-1650(ra) # 8000052a <panic>

0000000080004ba4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004ba4:	7139                	addi	sp,sp,-64
    80004ba6:	fc06                	sd	ra,56(sp)
    80004ba8:	f822                	sd	s0,48(sp)
    80004baa:	f426                	sd	s1,40(sp)
    80004bac:	f04a                	sd	s2,32(sp)
    80004bae:	ec4e                	sd	s3,24(sp)
    80004bb0:	e852                	sd	s4,16(sp)
    80004bb2:	e456                	sd	s5,8(sp)
    80004bb4:	0080                	addi	s0,sp,64
    80004bb6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004bb8:	0001d517          	auipc	a0,0x1d
    80004bbc:	20050513          	addi	a0,a0,512 # 80021db8 <ftable>
    80004bc0:	ffffc097          	auipc	ra,0xffffc
    80004bc4:	002080e7          	jalr	2(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004bc8:	40dc                	lw	a5,4(s1)
    80004bca:	06f05163          	blez	a5,80004c2c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004bce:	37fd                	addiw	a5,a5,-1
    80004bd0:	0007871b          	sext.w	a4,a5
    80004bd4:	c0dc                	sw	a5,4(s1)
    80004bd6:	06e04363          	bgtz	a4,80004c3c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004bda:	0004a903          	lw	s2,0(s1)
    80004bde:	0094ca83          	lbu	s5,9(s1)
    80004be2:	0104ba03          	ld	s4,16(s1)
    80004be6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004bea:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004bee:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004bf2:	0001d517          	auipc	a0,0x1d
    80004bf6:	1c650513          	addi	a0,a0,454 # 80021db8 <ftable>
    80004bfa:	ffffc097          	auipc	ra,0xffffc
    80004bfe:	07c080e7          	jalr	124(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    80004c02:	4785                	li	a5,1
    80004c04:	04f90d63          	beq	s2,a5,80004c5e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004c08:	3979                	addiw	s2,s2,-2
    80004c0a:	4785                	li	a5,1
    80004c0c:	0527e063          	bltu	a5,s2,80004c4c <fileclose+0xa8>
    begin_op();
    80004c10:	00000097          	auipc	ra,0x0
    80004c14:	ac8080e7          	jalr	-1336(ra) # 800046d8 <begin_op>
    iput(ff.ip);
    80004c18:	854e                	mv	a0,s3
    80004c1a:	fffff097          	auipc	ra,0xfffff
    80004c1e:	2a2080e7          	jalr	674(ra) # 80003ebc <iput>
    end_op();
    80004c22:	00000097          	auipc	ra,0x0
    80004c26:	b36080e7          	jalr	-1226(ra) # 80004758 <end_op>
    80004c2a:	a00d                	j	80004c4c <fileclose+0xa8>
    panic("fileclose");
    80004c2c:	00004517          	auipc	a0,0x4
    80004c30:	d5c50513          	addi	a0,a0,-676 # 80008988 <syscalls+0x260>
    80004c34:	ffffc097          	auipc	ra,0xffffc
    80004c38:	8f6080e7          	jalr	-1802(ra) # 8000052a <panic>
    release(&ftable.lock);
    80004c3c:	0001d517          	auipc	a0,0x1d
    80004c40:	17c50513          	addi	a0,a0,380 # 80021db8 <ftable>
    80004c44:	ffffc097          	auipc	ra,0xffffc
    80004c48:	032080e7          	jalr	50(ra) # 80000c76 <release>
  }
}
    80004c4c:	70e2                	ld	ra,56(sp)
    80004c4e:	7442                	ld	s0,48(sp)
    80004c50:	74a2                	ld	s1,40(sp)
    80004c52:	7902                	ld	s2,32(sp)
    80004c54:	69e2                	ld	s3,24(sp)
    80004c56:	6a42                	ld	s4,16(sp)
    80004c58:	6aa2                	ld	s5,8(sp)
    80004c5a:	6121                	addi	sp,sp,64
    80004c5c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c5e:	85d6                	mv	a1,s5
    80004c60:	8552                	mv	a0,s4
    80004c62:	00000097          	auipc	ra,0x0
    80004c66:	34c080e7          	jalr	844(ra) # 80004fae <pipeclose>
    80004c6a:	b7cd                	j	80004c4c <fileclose+0xa8>

0000000080004c6c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c6c:	715d                	addi	sp,sp,-80
    80004c6e:	e486                	sd	ra,72(sp)
    80004c70:	e0a2                	sd	s0,64(sp)
    80004c72:	fc26                	sd	s1,56(sp)
    80004c74:	f84a                	sd	s2,48(sp)
    80004c76:	f44e                	sd	s3,40(sp)
    80004c78:	0880                	addi	s0,sp,80
    80004c7a:	84aa                	mv	s1,a0
    80004c7c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c7e:	ffffd097          	auipc	ra,0xffffd
    80004c82:	d00080e7          	jalr	-768(ra) # 8000197e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c86:	409c                	lw	a5,0(s1)
    80004c88:	37f9                	addiw	a5,a5,-2
    80004c8a:	4705                	li	a4,1
    80004c8c:	04f76763          	bltu	a4,a5,80004cda <filestat+0x6e>
    80004c90:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c92:	6c88                	ld	a0,24(s1)
    80004c94:	fffff097          	auipc	ra,0xfffff
    80004c98:	06e080e7          	jalr	110(ra) # 80003d02 <ilock>
    stati(f->ip, &st);
    80004c9c:	fb840593          	addi	a1,s0,-72
    80004ca0:	6c88                	ld	a0,24(s1)
    80004ca2:	fffff097          	auipc	ra,0xfffff
    80004ca6:	2ea080e7          	jalr	746(ra) # 80003f8c <stati>
    iunlock(f->ip);
    80004caa:	6c88                	ld	a0,24(s1)
    80004cac:	fffff097          	auipc	ra,0xfffff
    80004cb0:	118080e7          	jalr	280(ra) # 80003dc4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004cb4:	46e1                	li	a3,24
    80004cb6:	fb840613          	addi	a2,s0,-72
    80004cba:	85ce                	mv	a1,s3
    80004cbc:	07893503          	ld	a0,120(s2)
    80004cc0:	ffffd097          	auipc	ra,0xffffd
    80004cc4:	97e080e7          	jalr	-1666(ra) # 8000163e <copyout>
    80004cc8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004ccc:	60a6                	ld	ra,72(sp)
    80004cce:	6406                	ld	s0,64(sp)
    80004cd0:	74e2                	ld	s1,56(sp)
    80004cd2:	7942                	ld	s2,48(sp)
    80004cd4:	79a2                	ld	s3,40(sp)
    80004cd6:	6161                	addi	sp,sp,80
    80004cd8:	8082                	ret
  return -1;
    80004cda:	557d                	li	a0,-1
    80004cdc:	bfc5                	j	80004ccc <filestat+0x60>

0000000080004cde <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004cde:	7179                	addi	sp,sp,-48
    80004ce0:	f406                	sd	ra,40(sp)
    80004ce2:	f022                	sd	s0,32(sp)
    80004ce4:	ec26                	sd	s1,24(sp)
    80004ce6:	e84a                	sd	s2,16(sp)
    80004ce8:	e44e                	sd	s3,8(sp)
    80004cea:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004cec:	00854783          	lbu	a5,8(a0)
    80004cf0:	c3d5                	beqz	a5,80004d94 <fileread+0xb6>
    80004cf2:	84aa                	mv	s1,a0
    80004cf4:	89ae                	mv	s3,a1
    80004cf6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cf8:	411c                	lw	a5,0(a0)
    80004cfa:	4705                	li	a4,1
    80004cfc:	04e78963          	beq	a5,a4,80004d4e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d00:	470d                	li	a4,3
    80004d02:	04e78d63          	beq	a5,a4,80004d5c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d06:	4709                	li	a4,2
    80004d08:	06e79e63          	bne	a5,a4,80004d84 <fileread+0xa6>
    ilock(f->ip);
    80004d0c:	6d08                	ld	a0,24(a0)
    80004d0e:	fffff097          	auipc	ra,0xfffff
    80004d12:	ff4080e7          	jalr	-12(ra) # 80003d02 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004d16:	874a                	mv	a4,s2
    80004d18:	5094                	lw	a3,32(s1)
    80004d1a:	864e                	mv	a2,s3
    80004d1c:	4585                	li	a1,1
    80004d1e:	6c88                	ld	a0,24(s1)
    80004d20:	fffff097          	auipc	ra,0xfffff
    80004d24:	296080e7          	jalr	662(ra) # 80003fb6 <readi>
    80004d28:	892a                	mv	s2,a0
    80004d2a:	00a05563          	blez	a0,80004d34 <fileread+0x56>
      f->off += r;
    80004d2e:	509c                	lw	a5,32(s1)
    80004d30:	9fa9                	addw	a5,a5,a0
    80004d32:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004d34:	6c88                	ld	a0,24(s1)
    80004d36:	fffff097          	auipc	ra,0xfffff
    80004d3a:	08e080e7          	jalr	142(ra) # 80003dc4 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004d3e:	854a                	mv	a0,s2
    80004d40:	70a2                	ld	ra,40(sp)
    80004d42:	7402                	ld	s0,32(sp)
    80004d44:	64e2                	ld	s1,24(sp)
    80004d46:	6942                	ld	s2,16(sp)
    80004d48:	69a2                	ld	s3,8(sp)
    80004d4a:	6145                	addi	sp,sp,48
    80004d4c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d4e:	6908                	ld	a0,16(a0)
    80004d50:	00000097          	auipc	ra,0x0
    80004d54:	3c0080e7          	jalr	960(ra) # 80005110 <piperead>
    80004d58:	892a                	mv	s2,a0
    80004d5a:	b7d5                	j	80004d3e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d5c:	02451783          	lh	a5,36(a0)
    80004d60:	03079693          	slli	a3,a5,0x30
    80004d64:	92c1                	srli	a3,a3,0x30
    80004d66:	4725                	li	a4,9
    80004d68:	02d76863          	bltu	a4,a3,80004d98 <fileread+0xba>
    80004d6c:	0792                	slli	a5,a5,0x4
    80004d6e:	0001d717          	auipc	a4,0x1d
    80004d72:	faa70713          	addi	a4,a4,-86 # 80021d18 <devsw>
    80004d76:	97ba                	add	a5,a5,a4
    80004d78:	639c                	ld	a5,0(a5)
    80004d7a:	c38d                	beqz	a5,80004d9c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004d7c:	4505                	li	a0,1
    80004d7e:	9782                	jalr	a5
    80004d80:	892a                	mv	s2,a0
    80004d82:	bf75                	j	80004d3e <fileread+0x60>
    panic("fileread");
    80004d84:	00004517          	auipc	a0,0x4
    80004d88:	c1450513          	addi	a0,a0,-1004 # 80008998 <syscalls+0x270>
    80004d8c:	ffffb097          	auipc	ra,0xffffb
    80004d90:	79e080e7          	jalr	1950(ra) # 8000052a <panic>
    return -1;
    80004d94:	597d                	li	s2,-1
    80004d96:	b765                	j	80004d3e <fileread+0x60>
      return -1;
    80004d98:	597d                	li	s2,-1
    80004d9a:	b755                	j	80004d3e <fileread+0x60>
    80004d9c:	597d                	li	s2,-1
    80004d9e:	b745                	j	80004d3e <fileread+0x60>

0000000080004da0 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004da0:	715d                	addi	sp,sp,-80
    80004da2:	e486                	sd	ra,72(sp)
    80004da4:	e0a2                	sd	s0,64(sp)
    80004da6:	fc26                	sd	s1,56(sp)
    80004da8:	f84a                	sd	s2,48(sp)
    80004daa:	f44e                	sd	s3,40(sp)
    80004dac:	f052                	sd	s4,32(sp)
    80004dae:	ec56                	sd	s5,24(sp)
    80004db0:	e85a                	sd	s6,16(sp)
    80004db2:	e45e                	sd	s7,8(sp)
    80004db4:	e062                	sd	s8,0(sp)
    80004db6:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004db8:	00954783          	lbu	a5,9(a0)
    80004dbc:	10078663          	beqz	a5,80004ec8 <filewrite+0x128>
    80004dc0:	892a                	mv	s2,a0
    80004dc2:	8aae                	mv	s5,a1
    80004dc4:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004dc6:	411c                	lw	a5,0(a0)
    80004dc8:	4705                	li	a4,1
    80004dca:	02e78263          	beq	a5,a4,80004dee <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004dce:	470d                	li	a4,3
    80004dd0:	02e78663          	beq	a5,a4,80004dfc <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004dd4:	4709                	li	a4,2
    80004dd6:	0ee79163          	bne	a5,a4,80004eb8 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004dda:	0ac05d63          	blez	a2,80004e94 <filewrite+0xf4>
    int i = 0;
    80004dde:	4981                	li	s3,0
    80004de0:	6b05                	lui	s6,0x1
    80004de2:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004de6:	6b85                	lui	s7,0x1
    80004de8:	c00b8b9b          	addiw	s7,s7,-1024
    80004dec:	a861                	j	80004e84 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004dee:	6908                	ld	a0,16(a0)
    80004df0:	00000097          	auipc	ra,0x0
    80004df4:	22e080e7          	jalr	558(ra) # 8000501e <pipewrite>
    80004df8:	8a2a                	mv	s4,a0
    80004dfa:	a045                	j	80004e9a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004dfc:	02451783          	lh	a5,36(a0)
    80004e00:	03079693          	slli	a3,a5,0x30
    80004e04:	92c1                	srli	a3,a3,0x30
    80004e06:	4725                	li	a4,9
    80004e08:	0cd76263          	bltu	a4,a3,80004ecc <filewrite+0x12c>
    80004e0c:	0792                	slli	a5,a5,0x4
    80004e0e:	0001d717          	auipc	a4,0x1d
    80004e12:	f0a70713          	addi	a4,a4,-246 # 80021d18 <devsw>
    80004e16:	97ba                	add	a5,a5,a4
    80004e18:	679c                	ld	a5,8(a5)
    80004e1a:	cbdd                	beqz	a5,80004ed0 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004e1c:	4505                	li	a0,1
    80004e1e:	9782                	jalr	a5
    80004e20:	8a2a                	mv	s4,a0
    80004e22:	a8a5                	j	80004e9a <filewrite+0xfa>
    80004e24:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004e28:	00000097          	auipc	ra,0x0
    80004e2c:	8b0080e7          	jalr	-1872(ra) # 800046d8 <begin_op>
      ilock(f->ip);
    80004e30:	01893503          	ld	a0,24(s2)
    80004e34:	fffff097          	auipc	ra,0xfffff
    80004e38:	ece080e7          	jalr	-306(ra) # 80003d02 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004e3c:	8762                	mv	a4,s8
    80004e3e:	02092683          	lw	a3,32(s2)
    80004e42:	01598633          	add	a2,s3,s5
    80004e46:	4585                	li	a1,1
    80004e48:	01893503          	ld	a0,24(s2)
    80004e4c:	fffff097          	auipc	ra,0xfffff
    80004e50:	262080e7          	jalr	610(ra) # 800040ae <writei>
    80004e54:	84aa                	mv	s1,a0
    80004e56:	00a05763          	blez	a0,80004e64 <filewrite+0xc4>
        f->off += r;
    80004e5a:	02092783          	lw	a5,32(s2)
    80004e5e:	9fa9                	addw	a5,a5,a0
    80004e60:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e64:	01893503          	ld	a0,24(s2)
    80004e68:	fffff097          	auipc	ra,0xfffff
    80004e6c:	f5c080e7          	jalr	-164(ra) # 80003dc4 <iunlock>
      end_op();
    80004e70:	00000097          	auipc	ra,0x0
    80004e74:	8e8080e7          	jalr	-1816(ra) # 80004758 <end_op>

      if(r != n1){
    80004e78:	009c1f63          	bne	s8,s1,80004e96 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004e7c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e80:	0149db63          	bge	s3,s4,80004e96 <filewrite+0xf6>
      int n1 = n - i;
    80004e84:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004e88:	84be                	mv	s1,a5
    80004e8a:	2781                	sext.w	a5,a5
    80004e8c:	f8fb5ce3          	bge	s6,a5,80004e24 <filewrite+0x84>
    80004e90:	84de                	mv	s1,s7
    80004e92:	bf49                	j	80004e24 <filewrite+0x84>
    int i = 0;
    80004e94:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e96:	013a1f63          	bne	s4,s3,80004eb4 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e9a:	8552                	mv	a0,s4
    80004e9c:	60a6                	ld	ra,72(sp)
    80004e9e:	6406                	ld	s0,64(sp)
    80004ea0:	74e2                	ld	s1,56(sp)
    80004ea2:	7942                	ld	s2,48(sp)
    80004ea4:	79a2                	ld	s3,40(sp)
    80004ea6:	7a02                	ld	s4,32(sp)
    80004ea8:	6ae2                	ld	s5,24(sp)
    80004eaa:	6b42                	ld	s6,16(sp)
    80004eac:	6ba2                	ld	s7,8(sp)
    80004eae:	6c02                	ld	s8,0(sp)
    80004eb0:	6161                	addi	sp,sp,80
    80004eb2:	8082                	ret
    ret = (i == n ? n : -1);
    80004eb4:	5a7d                	li	s4,-1
    80004eb6:	b7d5                	j	80004e9a <filewrite+0xfa>
    panic("filewrite");
    80004eb8:	00004517          	auipc	a0,0x4
    80004ebc:	af050513          	addi	a0,a0,-1296 # 800089a8 <syscalls+0x280>
    80004ec0:	ffffb097          	auipc	ra,0xffffb
    80004ec4:	66a080e7          	jalr	1642(ra) # 8000052a <panic>
    return -1;
    80004ec8:	5a7d                	li	s4,-1
    80004eca:	bfc1                	j	80004e9a <filewrite+0xfa>
      return -1;
    80004ecc:	5a7d                	li	s4,-1
    80004ece:	b7f1                	j	80004e9a <filewrite+0xfa>
    80004ed0:	5a7d                	li	s4,-1
    80004ed2:	b7e1                	j	80004e9a <filewrite+0xfa>

0000000080004ed4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ed4:	7179                	addi	sp,sp,-48
    80004ed6:	f406                	sd	ra,40(sp)
    80004ed8:	f022                	sd	s0,32(sp)
    80004eda:	ec26                	sd	s1,24(sp)
    80004edc:	e84a                	sd	s2,16(sp)
    80004ede:	e44e                	sd	s3,8(sp)
    80004ee0:	e052                	sd	s4,0(sp)
    80004ee2:	1800                	addi	s0,sp,48
    80004ee4:	84aa                	mv	s1,a0
    80004ee6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ee8:	0005b023          	sd	zero,0(a1)
    80004eec:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ef0:	00000097          	auipc	ra,0x0
    80004ef4:	bf8080e7          	jalr	-1032(ra) # 80004ae8 <filealloc>
    80004ef8:	e088                	sd	a0,0(s1)
    80004efa:	c551                	beqz	a0,80004f86 <pipealloc+0xb2>
    80004efc:	00000097          	auipc	ra,0x0
    80004f00:	bec080e7          	jalr	-1044(ra) # 80004ae8 <filealloc>
    80004f04:	00aa3023          	sd	a0,0(s4)
    80004f08:	c92d                	beqz	a0,80004f7a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004f0a:	ffffc097          	auipc	ra,0xffffc
    80004f0e:	bc8080e7          	jalr	-1080(ra) # 80000ad2 <kalloc>
    80004f12:	892a                	mv	s2,a0
    80004f14:	c125                	beqz	a0,80004f74 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004f16:	4985                	li	s3,1
    80004f18:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004f1c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004f20:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004f24:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004f28:	00003597          	auipc	a1,0x3
    80004f2c:	67058593          	addi	a1,a1,1648 # 80008598 <states.0+0x1e0>
    80004f30:	ffffc097          	auipc	ra,0xffffc
    80004f34:	c02080e7          	jalr	-1022(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80004f38:	609c                	ld	a5,0(s1)
    80004f3a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004f3e:	609c                	ld	a5,0(s1)
    80004f40:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f44:	609c                	ld	a5,0(s1)
    80004f46:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004f4a:	609c                	ld	a5,0(s1)
    80004f4c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f50:	000a3783          	ld	a5,0(s4)
    80004f54:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f58:	000a3783          	ld	a5,0(s4)
    80004f5c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f60:	000a3783          	ld	a5,0(s4)
    80004f64:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f68:	000a3783          	ld	a5,0(s4)
    80004f6c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f70:	4501                	li	a0,0
    80004f72:	a025                	j	80004f9a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f74:	6088                	ld	a0,0(s1)
    80004f76:	e501                	bnez	a0,80004f7e <pipealloc+0xaa>
    80004f78:	a039                	j	80004f86 <pipealloc+0xb2>
    80004f7a:	6088                	ld	a0,0(s1)
    80004f7c:	c51d                	beqz	a0,80004faa <pipealloc+0xd6>
    fileclose(*f0);
    80004f7e:	00000097          	auipc	ra,0x0
    80004f82:	c26080e7          	jalr	-986(ra) # 80004ba4 <fileclose>
  if(*f1)
    80004f86:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004f8a:	557d                	li	a0,-1
  if(*f1)
    80004f8c:	c799                	beqz	a5,80004f9a <pipealloc+0xc6>
    fileclose(*f1);
    80004f8e:	853e                	mv	a0,a5
    80004f90:	00000097          	auipc	ra,0x0
    80004f94:	c14080e7          	jalr	-1004(ra) # 80004ba4 <fileclose>
  return -1;
    80004f98:	557d                	li	a0,-1
}
    80004f9a:	70a2                	ld	ra,40(sp)
    80004f9c:	7402                	ld	s0,32(sp)
    80004f9e:	64e2                	ld	s1,24(sp)
    80004fa0:	6942                	ld	s2,16(sp)
    80004fa2:	69a2                	ld	s3,8(sp)
    80004fa4:	6a02                	ld	s4,0(sp)
    80004fa6:	6145                	addi	sp,sp,48
    80004fa8:	8082                	ret
  return -1;
    80004faa:	557d                	li	a0,-1
    80004fac:	b7fd                	j	80004f9a <pipealloc+0xc6>

0000000080004fae <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004fae:	1101                	addi	sp,sp,-32
    80004fb0:	ec06                	sd	ra,24(sp)
    80004fb2:	e822                	sd	s0,16(sp)
    80004fb4:	e426                	sd	s1,8(sp)
    80004fb6:	e04a                	sd	s2,0(sp)
    80004fb8:	1000                	addi	s0,sp,32
    80004fba:	84aa                	mv	s1,a0
    80004fbc:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004fbe:	ffffc097          	auipc	ra,0xffffc
    80004fc2:	c04080e7          	jalr	-1020(ra) # 80000bc2 <acquire>
  if(writable){
    80004fc6:	02090d63          	beqz	s2,80005000 <pipeclose+0x52>
    pi->writeopen = 0;
    80004fca:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004fce:	21848513          	addi	a0,s1,536
    80004fd2:	ffffd097          	auipc	ra,0xffffd
    80004fd6:	4ba080e7          	jalr	1210(ra) # 8000248c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004fda:	2204b783          	ld	a5,544(s1)
    80004fde:	eb95                	bnez	a5,80005012 <pipeclose+0x64>
    release(&pi->lock);
    80004fe0:	8526                	mv	a0,s1
    80004fe2:	ffffc097          	auipc	ra,0xffffc
    80004fe6:	c94080e7          	jalr	-876(ra) # 80000c76 <release>
    kfree((char*)pi);
    80004fea:	8526                	mv	a0,s1
    80004fec:	ffffc097          	auipc	ra,0xffffc
    80004ff0:	9ea080e7          	jalr	-1558(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    80004ff4:	60e2                	ld	ra,24(sp)
    80004ff6:	6442                	ld	s0,16(sp)
    80004ff8:	64a2                	ld	s1,8(sp)
    80004ffa:	6902                	ld	s2,0(sp)
    80004ffc:	6105                	addi	sp,sp,32
    80004ffe:	8082                	ret
    pi->readopen = 0;
    80005000:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005004:	21c48513          	addi	a0,s1,540
    80005008:	ffffd097          	auipc	ra,0xffffd
    8000500c:	484080e7          	jalr	1156(ra) # 8000248c <wakeup>
    80005010:	b7e9                	j	80004fda <pipeclose+0x2c>
    release(&pi->lock);
    80005012:	8526                	mv	a0,s1
    80005014:	ffffc097          	auipc	ra,0xffffc
    80005018:	c62080e7          	jalr	-926(ra) # 80000c76 <release>
}
    8000501c:	bfe1                	j	80004ff4 <pipeclose+0x46>

000000008000501e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000501e:	711d                	addi	sp,sp,-96
    80005020:	ec86                	sd	ra,88(sp)
    80005022:	e8a2                	sd	s0,80(sp)
    80005024:	e4a6                	sd	s1,72(sp)
    80005026:	e0ca                	sd	s2,64(sp)
    80005028:	fc4e                	sd	s3,56(sp)
    8000502a:	f852                	sd	s4,48(sp)
    8000502c:	f456                	sd	s5,40(sp)
    8000502e:	f05a                	sd	s6,32(sp)
    80005030:	ec5e                	sd	s7,24(sp)
    80005032:	e862                	sd	s8,16(sp)
    80005034:	1080                	addi	s0,sp,96
    80005036:	84aa                	mv	s1,a0
    80005038:	8aae                	mv	s5,a1
    8000503a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000503c:	ffffd097          	auipc	ra,0xffffd
    80005040:	942080e7          	jalr	-1726(ra) # 8000197e <myproc>
    80005044:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005046:	8526                	mv	a0,s1
    80005048:	ffffc097          	auipc	ra,0xffffc
    8000504c:	b7a080e7          	jalr	-1158(ra) # 80000bc2 <acquire>
  while(i < n){
    80005050:	0b405363          	blez	s4,800050f6 <pipewrite+0xd8>
  int i = 0;
    80005054:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005056:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005058:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000505c:	21c48b93          	addi	s7,s1,540
    80005060:	a089                	j	800050a2 <pipewrite+0x84>
      release(&pi->lock);
    80005062:	8526                	mv	a0,s1
    80005064:	ffffc097          	auipc	ra,0xffffc
    80005068:	c12080e7          	jalr	-1006(ra) # 80000c76 <release>
      return -1;
    8000506c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000506e:	854a                	mv	a0,s2
    80005070:	60e6                	ld	ra,88(sp)
    80005072:	6446                	ld	s0,80(sp)
    80005074:	64a6                	ld	s1,72(sp)
    80005076:	6906                	ld	s2,64(sp)
    80005078:	79e2                	ld	s3,56(sp)
    8000507a:	7a42                	ld	s4,48(sp)
    8000507c:	7aa2                	ld	s5,40(sp)
    8000507e:	7b02                	ld	s6,32(sp)
    80005080:	6be2                	ld	s7,24(sp)
    80005082:	6c42                	ld	s8,16(sp)
    80005084:	6125                	addi	sp,sp,96
    80005086:	8082                	ret
      wakeup(&pi->nread);
    80005088:	8562                	mv	a0,s8
    8000508a:	ffffd097          	auipc	ra,0xffffd
    8000508e:	402080e7          	jalr	1026(ra) # 8000248c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005092:	85a6                	mv	a1,s1
    80005094:	855e                	mv	a0,s7
    80005096:	ffffd097          	auipc	ra,0xffffd
    8000509a:	26a080e7          	jalr	618(ra) # 80002300 <sleep>
  while(i < n){
    8000509e:	05495d63          	bge	s2,s4,800050f8 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    800050a2:	2204a783          	lw	a5,544(s1)
    800050a6:	dfd5                	beqz	a5,80005062 <pipewrite+0x44>
    800050a8:	0289a783          	lw	a5,40(s3)
    800050ac:	fbdd                	bnez	a5,80005062 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800050ae:	2184a783          	lw	a5,536(s1)
    800050b2:	21c4a703          	lw	a4,540(s1)
    800050b6:	2007879b          	addiw	a5,a5,512
    800050ba:	fcf707e3          	beq	a4,a5,80005088 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050be:	4685                	li	a3,1
    800050c0:	01590633          	add	a2,s2,s5
    800050c4:	faf40593          	addi	a1,s0,-81
    800050c8:	0789b503          	ld	a0,120(s3)
    800050cc:	ffffc097          	auipc	ra,0xffffc
    800050d0:	5fe080e7          	jalr	1534(ra) # 800016ca <copyin>
    800050d4:	03650263          	beq	a0,s6,800050f8 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800050d8:	21c4a783          	lw	a5,540(s1)
    800050dc:	0017871b          	addiw	a4,a5,1
    800050e0:	20e4ae23          	sw	a4,540(s1)
    800050e4:	1ff7f793          	andi	a5,a5,511
    800050e8:	97a6                	add	a5,a5,s1
    800050ea:	faf44703          	lbu	a4,-81(s0)
    800050ee:	00e78c23          	sb	a4,24(a5)
      i++;
    800050f2:	2905                	addiw	s2,s2,1
    800050f4:	b76d                	j	8000509e <pipewrite+0x80>
  int i = 0;
    800050f6:	4901                	li	s2,0
  wakeup(&pi->nread);
    800050f8:	21848513          	addi	a0,s1,536
    800050fc:	ffffd097          	auipc	ra,0xffffd
    80005100:	390080e7          	jalr	912(ra) # 8000248c <wakeup>
  release(&pi->lock);
    80005104:	8526                	mv	a0,s1
    80005106:	ffffc097          	auipc	ra,0xffffc
    8000510a:	b70080e7          	jalr	-1168(ra) # 80000c76 <release>
  return i;
    8000510e:	b785                	j	8000506e <pipewrite+0x50>

0000000080005110 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005110:	715d                	addi	sp,sp,-80
    80005112:	e486                	sd	ra,72(sp)
    80005114:	e0a2                	sd	s0,64(sp)
    80005116:	fc26                	sd	s1,56(sp)
    80005118:	f84a                	sd	s2,48(sp)
    8000511a:	f44e                	sd	s3,40(sp)
    8000511c:	f052                	sd	s4,32(sp)
    8000511e:	ec56                	sd	s5,24(sp)
    80005120:	e85a                	sd	s6,16(sp)
    80005122:	0880                	addi	s0,sp,80
    80005124:	84aa                	mv	s1,a0
    80005126:	892e                	mv	s2,a1
    80005128:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000512a:	ffffd097          	auipc	ra,0xffffd
    8000512e:	854080e7          	jalr	-1964(ra) # 8000197e <myproc>
    80005132:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005134:	8526                	mv	a0,s1
    80005136:	ffffc097          	auipc	ra,0xffffc
    8000513a:	a8c080e7          	jalr	-1396(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000513e:	2184a703          	lw	a4,536(s1)
    80005142:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005146:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000514a:	02f71463          	bne	a4,a5,80005172 <piperead+0x62>
    8000514e:	2244a783          	lw	a5,548(s1)
    80005152:	c385                	beqz	a5,80005172 <piperead+0x62>
    if(pr->killed){
    80005154:	028a2783          	lw	a5,40(s4)
    80005158:	ebc1                	bnez	a5,800051e8 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000515a:	85a6                	mv	a1,s1
    8000515c:	854e                	mv	a0,s3
    8000515e:	ffffd097          	auipc	ra,0xffffd
    80005162:	1a2080e7          	jalr	418(ra) # 80002300 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005166:	2184a703          	lw	a4,536(s1)
    8000516a:	21c4a783          	lw	a5,540(s1)
    8000516e:	fef700e3          	beq	a4,a5,8000514e <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005172:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005174:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005176:	05505363          	blez	s5,800051bc <piperead+0xac>
    if(pi->nread == pi->nwrite)
    8000517a:	2184a783          	lw	a5,536(s1)
    8000517e:	21c4a703          	lw	a4,540(s1)
    80005182:	02f70d63          	beq	a4,a5,800051bc <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005186:	0017871b          	addiw	a4,a5,1
    8000518a:	20e4ac23          	sw	a4,536(s1)
    8000518e:	1ff7f793          	andi	a5,a5,511
    80005192:	97a6                	add	a5,a5,s1
    80005194:	0187c783          	lbu	a5,24(a5)
    80005198:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000519c:	4685                	li	a3,1
    8000519e:	fbf40613          	addi	a2,s0,-65
    800051a2:	85ca                	mv	a1,s2
    800051a4:	078a3503          	ld	a0,120(s4)
    800051a8:	ffffc097          	auipc	ra,0xffffc
    800051ac:	496080e7          	jalr	1174(ra) # 8000163e <copyout>
    800051b0:	01650663          	beq	a0,s6,800051bc <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051b4:	2985                	addiw	s3,s3,1
    800051b6:	0905                	addi	s2,s2,1
    800051b8:	fd3a91e3          	bne	s5,s3,8000517a <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800051bc:	21c48513          	addi	a0,s1,540
    800051c0:	ffffd097          	auipc	ra,0xffffd
    800051c4:	2cc080e7          	jalr	716(ra) # 8000248c <wakeup>
  release(&pi->lock);
    800051c8:	8526                	mv	a0,s1
    800051ca:	ffffc097          	auipc	ra,0xffffc
    800051ce:	aac080e7          	jalr	-1364(ra) # 80000c76 <release>
  return i;
}
    800051d2:	854e                	mv	a0,s3
    800051d4:	60a6                	ld	ra,72(sp)
    800051d6:	6406                	ld	s0,64(sp)
    800051d8:	74e2                	ld	s1,56(sp)
    800051da:	7942                	ld	s2,48(sp)
    800051dc:	79a2                	ld	s3,40(sp)
    800051de:	7a02                	ld	s4,32(sp)
    800051e0:	6ae2                	ld	s5,24(sp)
    800051e2:	6b42                	ld	s6,16(sp)
    800051e4:	6161                	addi	sp,sp,80
    800051e6:	8082                	ret
      release(&pi->lock);
    800051e8:	8526                	mv	a0,s1
    800051ea:	ffffc097          	auipc	ra,0xffffc
    800051ee:	a8c080e7          	jalr	-1396(ra) # 80000c76 <release>
      return -1;
    800051f2:	59fd                	li	s3,-1
    800051f4:	bff9                	j	800051d2 <piperead+0xc2>

00000000800051f6 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    800051f6:	de010113          	addi	sp,sp,-544
    800051fa:	20113c23          	sd	ra,536(sp)
    800051fe:	20813823          	sd	s0,528(sp)
    80005202:	20913423          	sd	s1,520(sp)
    80005206:	21213023          	sd	s2,512(sp)
    8000520a:	ffce                	sd	s3,504(sp)
    8000520c:	fbd2                	sd	s4,496(sp)
    8000520e:	f7d6                	sd	s5,488(sp)
    80005210:	f3da                	sd	s6,480(sp)
    80005212:	efde                	sd	s7,472(sp)
    80005214:	ebe2                	sd	s8,464(sp)
    80005216:	e7e6                	sd	s9,456(sp)
    80005218:	e3ea                	sd	s10,448(sp)
    8000521a:	ff6e                	sd	s11,440(sp)
    8000521c:	1400                	addi	s0,sp,544
    8000521e:	892a                	mv	s2,a0
    80005220:	dea43423          	sd	a0,-536(s0)
    80005224:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005228:	ffffc097          	auipc	ra,0xffffc
    8000522c:	756080e7          	jalr	1878(ra) # 8000197e <myproc>
    80005230:	84aa                	mv	s1,a0

  begin_op();
    80005232:	fffff097          	auipc	ra,0xfffff
    80005236:	4a6080e7          	jalr	1190(ra) # 800046d8 <begin_op>

  if((ip = namei(path)) == 0){
    8000523a:	854a                	mv	a0,s2
    8000523c:	fffff097          	auipc	ra,0xfffff
    80005240:	27c080e7          	jalr	636(ra) # 800044b8 <namei>
    80005244:	c93d                	beqz	a0,800052ba <exec+0xc4>
    80005246:	8aaa                	mv	s5,a0
    end_op();
    /////////////////////////////we changed the return value in this case from -1
    return -2;
  }
  ilock(ip);
    80005248:	fffff097          	auipc	ra,0xfffff
    8000524c:	aba080e7          	jalr	-1350(ra) # 80003d02 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005250:	04000713          	li	a4,64
    80005254:	4681                	li	a3,0
    80005256:	e4840613          	addi	a2,s0,-440
    8000525a:	4581                	li	a1,0
    8000525c:	8556                	mv	a0,s5
    8000525e:	fffff097          	auipc	ra,0xfffff
    80005262:	d58080e7          	jalr	-680(ra) # 80003fb6 <readi>
    80005266:	04000793          	li	a5,64
    8000526a:	00f51a63          	bne	a0,a5,8000527e <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    8000526e:	e4842703          	lw	a4,-440(s0)
    80005272:	464c47b7          	lui	a5,0x464c4
    80005276:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000527a:	04f70663          	beq	a4,a5,800052c6 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000527e:	8556                	mv	a0,s5
    80005280:	fffff097          	auipc	ra,0xfffff
    80005284:	ce4080e7          	jalr	-796(ra) # 80003f64 <iunlockput>
    end_op();
    80005288:	fffff097          	auipc	ra,0xfffff
    8000528c:	4d0080e7          	jalr	1232(ra) # 80004758 <end_op>
  }
  return -1;
    80005290:	557d                	li	a0,-1
}
    80005292:	21813083          	ld	ra,536(sp)
    80005296:	21013403          	ld	s0,528(sp)
    8000529a:	20813483          	ld	s1,520(sp)
    8000529e:	20013903          	ld	s2,512(sp)
    800052a2:	79fe                	ld	s3,504(sp)
    800052a4:	7a5e                	ld	s4,496(sp)
    800052a6:	7abe                	ld	s5,488(sp)
    800052a8:	7b1e                	ld	s6,480(sp)
    800052aa:	6bfe                	ld	s7,472(sp)
    800052ac:	6c5e                	ld	s8,464(sp)
    800052ae:	6cbe                	ld	s9,456(sp)
    800052b0:	6d1e                	ld	s10,448(sp)
    800052b2:	7dfa                	ld	s11,440(sp)
    800052b4:	22010113          	addi	sp,sp,544
    800052b8:	8082                	ret
    end_op();
    800052ba:	fffff097          	auipc	ra,0xfffff
    800052be:	49e080e7          	jalr	1182(ra) # 80004758 <end_op>
    return -2;
    800052c2:	5579                	li	a0,-2
    800052c4:	b7f9                	j	80005292 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800052c6:	8526                	mv	a0,s1
    800052c8:	ffffc097          	auipc	ra,0xffffc
    800052cc:	7ba080e7          	jalr	1978(ra) # 80001a82 <proc_pagetable>
    800052d0:	8b2a                	mv	s6,a0
    800052d2:	d555                	beqz	a0,8000527e <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052d4:	e6842783          	lw	a5,-408(s0)
    800052d8:	e8045703          	lhu	a4,-384(s0)
    800052dc:	c735                	beqz	a4,80005348 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800052de:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052e0:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800052e4:	6a05                	lui	s4,0x1
    800052e6:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800052ea:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    800052ee:	6d85                	lui	s11,0x1
    800052f0:	7d7d                	lui	s10,0xfffff
    800052f2:	ac1d                	j	80005528 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800052f4:	00003517          	auipc	a0,0x3
    800052f8:	6c450513          	addi	a0,a0,1732 # 800089b8 <syscalls+0x290>
    800052fc:	ffffb097          	auipc	ra,0xffffb
    80005300:	22e080e7          	jalr	558(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005304:	874a                	mv	a4,s2
    80005306:	009c86bb          	addw	a3,s9,s1
    8000530a:	4581                	li	a1,0
    8000530c:	8556                	mv	a0,s5
    8000530e:	fffff097          	auipc	ra,0xfffff
    80005312:	ca8080e7          	jalr	-856(ra) # 80003fb6 <readi>
    80005316:	2501                	sext.w	a0,a0
    80005318:	1aa91863          	bne	s2,a0,800054c8 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    8000531c:	009d84bb          	addw	s1,s11,s1
    80005320:	013d09bb          	addw	s3,s10,s3
    80005324:	1f74f263          	bgeu	s1,s7,80005508 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80005328:	02049593          	slli	a1,s1,0x20
    8000532c:	9181                	srli	a1,a1,0x20
    8000532e:	95e2                	add	a1,a1,s8
    80005330:	855a                	mv	a0,s6
    80005332:	ffffc097          	auipc	ra,0xffffc
    80005336:	d1a080e7          	jalr	-742(ra) # 8000104c <walkaddr>
    8000533a:	862a                	mv	a2,a0
    if(pa == 0)
    8000533c:	dd45                	beqz	a0,800052f4 <exec+0xfe>
      n = PGSIZE;
    8000533e:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005340:	fd49f2e3          	bgeu	s3,s4,80005304 <exec+0x10e>
      n = sz - i;
    80005344:	894e                	mv	s2,s3
    80005346:	bf7d                	j	80005304 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005348:	4481                	li	s1,0
  iunlockput(ip);
    8000534a:	8556                	mv	a0,s5
    8000534c:	fffff097          	auipc	ra,0xfffff
    80005350:	c18080e7          	jalr	-1000(ra) # 80003f64 <iunlockput>
  end_op();
    80005354:	fffff097          	auipc	ra,0xfffff
    80005358:	404080e7          	jalr	1028(ra) # 80004758 <end_op>
  p = myproc();
    8000535c:	ffffc097          	auipc	ra,0xffffc
    80005360:	622080e7          	jalr	1570(ra) # 8000197e <myproc>
    80005364:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005366:	07053d03          	ld	s10,112(a0)
  sz = PGROUNDUP(sz);
    8000536a:	6785                	lui	a5,0x1
    8000536c:	17fd                	addi	a5,a5,-1
    8000536e:	94be                	add	s1,s1,a5
    80005370:	77fd                	lui	a5,0xfffff
    80005372:	8fe5                	and	a5,a5,s1
    80005374:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005378:	6609                	lui	a2,0x2
    8000537a:	963e                	add	a2,a2,a5
    8000537c:	85be                	mv	a1,a5
    8000537e:	855a                	mv	a0,s6
    80005380:	ffffc097          	auipc	ra,0xffffc
    80005384:	06e080e7          	jalr	110(ra) # 800013ee <uvmalloc>
    80005388:	8c2a                	mv	s8,a0
  ip = 0;
    8000538a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000538c:	12050e63          	beqz	a0,800054c8 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005390:	75f9                	lui	a1,0xffffe
    80005392:	95aa                	add	a1,a1,a0
    80005394:	855a                	mv	a0,s6
    80005396:	ffffc097          	auipc	ra,0xffffc
    8000539a:	276080e7          	jalr	630(ra) # 8000160c <uvmclear>
  stackbase = sp - PGSIZE;
    8000539e:	7afd                	lui	s5,0xfffff
    800053a0:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800053a2:	df043783          	ld	a5,-528(s0)
    800053a6:	6388                	ld	a0,0(a5)
    800053a8:	c925                	beqz	a0,80005418 <exec+0x222>
    800053aa:	e8840993          	addi	s3,s0,-376
    800053ae:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    800053b2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800053b4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800053b6:	ffffc097          	auipc	ra,0xffffc
    800053ba:	a8c080e7          	jalr	-1396(ra) # 80000e42 <strlen>
    800053be:	0015079b          	addiw	a5,a0,1
    800053c2:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800053c6:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800053ca:	13596363          	bltu	s2,s5,800054f0 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800053ce:	df043d83          	ld	s11,-528(s0)
    800053d2:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800053d6:	8552                	mv	a0,s4
    800053d8:	ffffc097          	auipc	ra,0xffffc
    800053dc:	a6a080e7          	jalr	-1430(ra) # 80000e42 <strlen>
    800053e0:	0015069b          	addiw	a3,a0,1
    800053e4:	8652                	mv	a2,s4
    800053e6:	85ca                	mv	a1,s2
    800053e8:	855a                	mv	a0,s6
    800053ea:	ffffc097          	auipc	ra,0xffffc
    800053ee:	254080e7          	jalr	596(ra) # 8000163e <copyout>
    800053f2:	10054363          	bltz	a0,800054f8 <exec+0x302>
    ustack[argc] = sp;
    800053f6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800053fa:	0485                	addi	s1,s1,1
    800053fc:	008d8793          	addi	a5,s11,8
    80005400:	def43823          	sd	a5,-528(s0)
    80005404:	008db503          	ld	a0,8(s11)
    80005408:	c911                	beqz	a0,8000541c <exec+0x226>
    if(argc >= MAXARG)
    8000540a:	09a1                	addi	s3,s3,8
    8000540c:	fb3c95e3          	bne	s9,s3,800053b6 <exec+0x1c0>
  sz = sz1;
    80005410:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005414:	4a81                	li	s5,0
    80005416:	a84d                	j	800054c8 <exec+0x2d2>
  sp = sz;
    80005418:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000541a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000541c:	00349793          	slli	a5,s1,0x3
    80005420:	f9040713          	addi	a4,s0,-112
    80005424:	97ba                	add	a5,a5,a4
    80005426:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    8000542a:	00148693          	addi	a3,s1,1
    8000542e:	068e                	slli	a3,a3,0x3
    80005430:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005434:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005438:	01597663          	bgeu	s2,s5,80005444 <exec+0x24e>
  sz = sz1;
    8000543c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005440:	4a81                	li	s5,0
    80005442:	a059                	j	800054c8 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005444:	e8840613          	addi	a2,s0,-376
    80005448:	85ca                	mv	a1,s2
    8000544a:	855a                	mv	a0,s6
    8000544c:	ffffc097          	auipc	ra,0xffffc
    80005450:	1f2080e7          	jalr	498(ra) # 8000163e <copyout>
    80005454:	0a054663          	bltz	a0,80005500 <exec+0x30a>
  p->trapframe->a1 = sp;
    80005458:	080bb783          	ld	a5,128(s7) # 1080 <_entry-0x7fffef80>
    8000545c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005460:	de843783          	ld	a5,-536(s0)
    80005464:	0007c703          	lbu	a4,0(a5)
    80005468:	cf11                	beqz	a4,80005484 <exec+0x28e>
    8000546a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000546c:	02f00693          	li	a3,47
    80005470:	a039                	j	8000547e <exec+0x288>
      last = s+1;
    80005472:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005476:	0785                	addi	a5,a5,1
    80005478:	fff7c703          	lbu	a4,-1(a5)
    8000547c:	c701                	beqz	a4,80005484 <exec+0x28e>
    if(*s == '/')
    8000547e:	fed71ce3          	bne	a4,a3,80005476 <exec+0x280>
    80005482:	bfc5                	j	80005472 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80005484:	4641                	li	a2,16
    80005486:	de843583          	ld	a1,-536(s0)
    8000548a:	180b8513          	addi	a0,s7,384
    8000548e:	ffffc097          	auipc	ra,0xffffc
    80005492:	982080e7          	jalr	-1662(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005496:	078bb503          	ld	a0,120(s7)
  p->pagetable = pagetable;
    8000549a:	076bbc23          	sd	s6,120(s7)
  p->sz = sz;
    8000549e:	078bb823          	sd	s8,112(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800054a2:	080bb783          	ld	a5,128(s7)
    800054a6:	e6043703          	ld	a4,-416(s0)
    800054aa:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800054ac:	080bb783          	ld	a5,128(s7)
    800054b0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800054b4:	85ea                	mv	a1,s10
    800054b6:	ffffc097          	auipc	ra,0xffffc
    800054ba:	668080e7          	jalr	1640(ra) # 80001b1e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800054be:	0004851b          	sext.w	a0,s1
    800054c2:	bbc1                	j	80005292 <exec+0x9c>
    800054c4:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    800054c8:	df843583          	ld	a1,-520(s0)
    800054cc:	855a                	mv	a0,s6
    800054ce:	ffffc097          	auipc	ra,0xffffc
    800054d2:	650080e7          	jalr	1616(ra) # 80001b1e <proc_freepagetable>
  if(ip){
    800054d6:	da0a94e3          	bnez	s5,8000527e <exec+0x88>
  return -1;
    800054da:	557d                	li	a0,-1
    800054dc:	bb5d                	j	80005292 <exec+0x9c>
    800054de:	de943c23          	sd	s1,-520(s0)
    800054e2:	b7dd                	j	800054c8 <exec+0x2d2>
    800054e4:	de943c23          	sd	s1,-520(s0)
    800054e8:	b7c5                	j	800054c8 <exec+0x2d2>
    800054ea:	de943c23          	sd	s1,-520(s0)
    800054ee:	bfe9                	j	800054c8 <exec+0x2d2>
  sz = sz1;
    800054f0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800054f4:	4a81                	li	s5,0
    800054f6:	bfc9                	j	800054c8 <exec+0x2d2>
  sz = sz1;
    800054f8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800054fc:	4a81                	li	s5,0
    800054fe:	b7e9                	j	800054c8 <exec+0x2d2>
  sz = sz1;
    80005500:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005504:	4a81                	li	s5,0
    80005506:	b7c9                	j	800054c8 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005508:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000550c:	e0843783          	ld	a5,-504(s0)
    80005510:	0017869b          	addiw	a3,a5,1
    80005514:	e0d43423          	sd	a3,-504(s0)
    80005518:	e0043783          	ld	a5,-512(s0)
    8000551c:	0387879b          	addiw	a5,a5,56
    80005520:	e8045703          	lhu	a4,-384(s0)
    80005524:	e2e6d3e3          	bge	a3,a4,8000534a <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005528:	2781                	sext.w	a5,a5
    8000552a:	e0f43023          	sd	a5,-512(s0)
    8000552e:	03800713          	li	a4,56
    80005532:	86be                	mv	a3,a5
    80005534:	e1040613          	addi	a2,s0,-496
    80005538:	4581                	li	a1,0
    8000553a:	8556                	mv	a0,s5
    8000553c:	fffff097          	auipc	ra,0xfffff
    80005540:	a7a080e7          	jalr	-1414(ra) # 80003fb6 <readi>
    80005544:	03800793          	li	a5,56
    80005548:	f6f51ee3          	bne	a0,a5,800054c4 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    8000554c:	e1042783          	lw	a5,-496(s0)
    80005550:	4705                	li	a4,1
    80005552:	fae79de3          	bne	a5,a4,8000550c <exec+0x316>
    if(ph.memsz < ph.filesz)
    80005556:	e3843603          	ld	a2,-456(s0)
    8000555a:	e3043783          	ld	a5,-464(s0)
    8000555e:	f8f660e3          	bltu	a2,a5,800054de <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005562:	e2043783          	ld	a5,-480(s0)
    80005566:	963e                	add	a2,a2,a5
    80005568:	f6f66ee3          	bltu	a2,a5,800054e4 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000556c:	85a6                	mv	a1,s1
    8000556e:	855a                	mv	a0,s6
    80005570:	ffffc097          	auipc	ra,0xffffc
    80005574:	e7e080e7          	jalr	-386(ra) # 800013ee <uvmalloc>
    80005578:	dea43c23          	sd	a0,-520(s0)
    8000557c:	d53d                	beqz	a0,800054ea <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    8000557e:	e2043c03          	ld	s8,-480(s0)
    80005582:	de043783          	ld	a5,-544(s0)
    80005586:	00fc77b3          	and	a5,s8,a5
    8000558a:	ff9d                	bnez	a5,800054c8 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000558c:	e1842c83          	lw	s9,-488(s0)
    80005590:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005594:	f60b8ae3          	beqz	s7,80005508 <exec+0x312>
    80005598:	89de                	mv	s3,s7
    8000559a:	4481                	li	s1,0
    8000559c:	b371                	j	80005328 <exec+0x132>

000000008000559e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000559e:	7179                	addi	sp,sp,-48
    800055a0:	f406                	sd	ra,40(sp)
    800055a2:	f022                	sd	s0,32(sp)
    800055a4:	ec26                	sd	s1,24(sp)
    800055a6:	e84a                	sd	s2,16(sp)
    800055a8:	1800                	addi	s0,sp,48
    800055aa:	892e                	mv	s2,a1
    800055ac:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800055ae:	fdc40593          	addi	a1,s0,-36
    800055b2:	ffffe097          	auipc	ra,0xffffe
    800055b6:	a58080e7          	jalr	-1448(ra) # 8000300a <argint>
    800055ba:	04054063          	bltz	a0,800055fa <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800055be:	fdc42703          	lw	a4,-36(s0)
    800055c2:	47bd                	li	a5,15
    800055c4:	02e7ed63          	bltu	a5,a4,800055fe <argfd+0x60>
    800055c8:	ffffc097          	auipc	ra,0xffffc
    800055cc:	3b6080e7          	jalr	950(ra) # 8000197e <myproc>
    800055d0:	fdc42703          	lw	a4,-36(s0)
    800055d4:	01e70793          	addi	a5,a4,30
    800055d8:	078e                	slli	a5,a5,0x3
    800055da:	953e                	add	a0,a0,a5
    800055dc:	651c                	ld	a5,8(a0)
    800055de:	c395                	beqz	a5,80005602 <argfd+0x64>
    return -1;
  if(pfd)
    800055e0:	00090463          	beqz	s2,800055e8 <argfd+0x4a>
    *pfd = fd;
    800055e4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800055e8:	4501                	li	a0,0
  if(pf)
    800055ea:	c091                	beqz	s1,800055ee <argfd+0x50>
    *pf = f;
    800055ec:	e09c                	sd	a5,0(s1)
}
    800055ee:	70a2                	ld	ra,40(sp)
    800055f0:	7402                	ld	s0,32(sp)
    800055f2:	64e2                	ld	s1,24(sp)
    800055f4:	6942                	ld	s2,16(sp)
    800055f6:	6145                	addi	sp,sp,48
    800055f8:	8082                	ret
    return -1;
    800055fa:	557d                	li	a0,-1
    800055fc:	bfcd                	j	800055ee <argfd+0x50>
    return -1;
    800055fe:	557d                	li	a0,-1
    80005600:	b7fd                	j	800055ee <argfd+0x50>
    80005602:	557d                	li	a0,-1
    80005604:	b7ed                	j	800055ee <argfd+0x50>

0000000080005606 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005606:	1101                	addi	sp,sp,-32
    80005608:	ec06                	sd	ra,24(sp)
    8000560a:	e822                	sd	s0,16(sp)
    8000560c:	e426                	sd	s1,8(sp)
    8000560e:	1000                	addi	s0,sp,32
    80005610:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005612:	ffffc097          	auipc	ra,0xffffc
    80005616:	36c080e7          	jalr	876(ra) # 8000197e <myproc>
    8000561a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000561c:	0f850793          	addi	a5,a0,248
    80005620:	4501                	li	a0,0
    80005622:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005624:	6398                	ld	a4,0(a5)
    80005626:	cb19                	beqz	a4,8000563c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005628:	2505                	addiw	a0,a0,1
    8000562a:	07a1                	addi	a5,a5,8
    8000562c:	fed51ce3          	bne	a0,a3,80005624 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005630:	557d                	li	a0,-1
}
    80005632:	60e2                	ld	ra,24(sp)
    80005634:	6442                	ld	s0,16(sp)
    80005636:	64a2                	ld	s1,8(sp)
    80005638:	6105                	addi	sp,sp,32
    8000563a:	8082                	ret
      p->ofile[fd] = f;
    8000563c:	01e50793          	addi	a5,a0,30
    80005640:	078e                	slli	a5,a5,0x3
    80005642:	963e                	add	a2,a2,a5
    80005644:	e604                	sd	s1,8(a2)
      return fd;
    80005646:	b7f5                	j	80005632 <fdalloc+0x2c>

0000000080005648 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005648:	715d                	addi	sp,sp,-80
    8000564a:	e486                	sd	ra,72(sp)
    8000564c:	e0a2                	sd	s0,64(sp)
    8000564e:	fc26                	sd	s1,56(sp)
    80005650:	f84a                	sd	s2,48(sp)
    80005652:	f44e                	sd	s3,40(sp)
    80005654:	f052                	sd	s4,32(sp)
    80005656:	ec56                	sd	s5,24(sp)
    80005658:	0880                	addi	s0,sp,80
    8000565a:	89ae                	mv	s3,a1
    8000565c:	8ab2                	mv	s5,a2
    8000565e:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005660:	fb040593          	addi	a1,s0,-80
    80005664:	fffff097          	auipc	ra,0xfffff
    80005668:	e72080e7          	jalr	-398(ra) # 800044d6 <nameiparent>
    8000566c:	892a                	mv	s2,a0
    8000566e:	12050e63          	beqz	a0,800057aa <create+0x162>
    return 0;

  ilock(dp);
    80005672:	ffffe097          	auipc	ra,0xffffe
    80005676:	690080e7          	jalr	1680(ra) # 80003d02 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000567a:	4601                	li	a2,0
    8000567c:	fb040593          	addi	a1,s0,-80
    80005680:	854a                	mv	a0,s2
    80005682:	fffff097          	auipc	ra,0xfffff
    80005686:	b64080e7          	jalr	-1180(ra) # 800041e6 <dirlookup>
    8000568a:	84aa                	mv	s1,a0
    8000568c:	c921                	beqz	a0,800056dc <create+0x94>
    iunlockput(dp);
    8000568e:	854a                	mv	a0,s2
    80005690:	fffff097          	auipc	ra,0xfffff
    80005694:	8d4080e7          	jalr	-1836(ra) # 80003f64 <iunlockput>
    ilock(ip);
    80005698:	8526                	mv	a0,s1
    8000569a:	ffffe097          	auipc	ra,0xffffe
    8000569e:	668080e7          	jalr	1640(ra) # 80003d02 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800056a2:	2981                	sext.w	s3,s3
    800056a4:	4789                	li	a5,2
    800056a6:	02f99463          	bne	s3,a5,800056ce <create+0x86>
    800056aa:	0444d783          	lhu	a5,68(s1)
    800056ae:	37f9                	addiw	a5,a5,-2
    800056b0:	17c2                	slli	a5,a5,0x30
    800056b2:	93c1                	srli	a5,a5,0x30
    800056b4:	4705                	li	a4,1
    800056b6:	00f76c63          	bltu	a4,a5,800056ce <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800056ba:	8526                	mv	a0,s1
    800056bc:	60a6                	ld	ra,72(sp)
    800056be:	6406                	ld	s0,64(sp)
    800056c0:	74e2                	ld	s1,56(sp)
    800056c2:	7942                	ld	s2,48(sp)
    800056c4:	79a2                	ld	s3,40(sp)
    800056c6:	7a02                	ld	s4,32(sp)
    800056c8:	6ae2                	ld	s5,24(sp)
    800056ca:	6161                	addi	sp,sp,80
    800056cc:	8082                	ret
    iunlockput(ip);
    800056ce:	8526                	mv	a0,s1
    800056d0:	fffff097          	auipc	ra,0xfffff
    800056d4:	894080e7          	jalr	-1900(ra) # 80003f64 <iunlockput>
    return 0;
    800056d8:	4481                	li	s1,0
    800056da:	b7c5                	j	800056ba <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800056dc:	85ce                	mv	a1,s3
    800056de:	00092503          	lw	a0,0(s2)
    800056e2:	ffffe097          	auipc	ra,0xffffe
    800056e6:	488080e7          	jalr	1160(ra) # 80003b6a <ialloc>
    800056ea:	84aa                	mv	s1,a0
    800056ec:	c521                	beqz	a0,80005734 <create+0xec>
  ilock(ip);
    800056ee:	ffffe097          	auipc	ra,0xffffe
    800056f2:	614080e7          	jalr	1556(ra) # 80003d02 <ilock>
  ip->major = major;
    800056f6:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800056fa:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800056fe:	4a05                	li	s4,1
    80005700:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005704:	8526                	mv	a0,s1
    80005706:	ffffe097          	auipc	ra,0xffffe
    8000570a:	532080e7          	jalr	1330(ra) # 80003c38 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000570e:	2981                	sext.w	s3,s3
    80005710:	03498a63          	beq	s3,s4,80005744 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005714:	40d0                	lw	a2,4(s1)
    80005716:	fb040593          	addi	a1,s0,-80
    8000571a:	854a                	mv	a0,s2
    8000571c:	fffff097          	auipc	ra,0xfffff
    80005720:	cda080e7          	jalr	-806(ra) # 800043f6 <dirlink>
    80005724:	06054b63          	bltz	a0,8000579a <create+0x152>
  iunlockput(dp);
    80005728:	854a                	mv	a0,s2
    8000572a:	fffff097          	auipc	ra,0xfffff
    8000572e:	83a080e7          	jalr	-1990(ra) # 80003f64 <iunlockput>
  return ip;
    80005732:	b761                	j	800056ba <create+0x72>
    panic("create: ialloc");
    80005734:	00003517          	auipc	a0,0x3
    80005738:	2a450513          	addi	a0,a0,676 # 800089d8 <syscalls+0x2b0>
    8000573c:	ffffb097          	auipc	ra,0xffffb
    80005740:	dee080e7          	jalr	-530(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    80005744:	04a95783          	lhu	a5,74(s2)
    80005748:	2785                	addiw	a5,a5,1
    8000574a:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000574e:	854a                	mv	a0,s2
    80005750:	ffffe097          	auipc	ra,0xffffe
    80005754:	4e8080e7          	jalr	1256(ra) # 80003c38 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005758:	40d0                	lw	a2,4(s1)
    8000575a:	00003597          	auipc	a1,0x3
    8000575e:	28e58593          	addi	a1,a1,654 # 800089e8 <syscalls+0x2c0>
    80005762:	8526                	mv	a0,s1
    80005764:	fffff097          	auipc	ra,0xfffff
    80005768:	c92080e7          	jalr	-878(ra) # 800043f6 <dirlink>
    8000576c:	00054f63          	bltz	a0,8000578a <create+0x142>
    80005770:	00492603          	lw	a2,4(s2)
    80005774:	00003597          	auipc	a1,0x3
    80005778:	27c58593          	addi	a1,a1,636 # 800089f0 <syscalls+0x2c8>
    8000577c:	8526                	mv	a0,s1
    8000577e:	fffff097          	auipc	ra,0xfffff
    80005782:	c78080e7          	jalr	-904(ra) # 800043f6 <dirlink>
    80005786:	f80557e3          	bgez	a0,80005714 <create+0xcc>
      panic("create dots");
    8000578a:	00003517          	auipc	a0,0x3
    8000578e:	26e50513          	addi	a0,a0,622 # 800089f8 <syscalls+0x2d0>
    80005792:	ffffb097          	auipc	ra,0xffffb
    80005796:	d98080e7          	jalr	-616(ra) # 8000052a <panic>
    panic("create: dirlink");
    8000579a:	00003517          	auipc	a0,0x3
    8000579e:	26e50513          	addi	a0,a0,622 # 80008a08 <syscalls+0x2e0>
    800057a2:	ffffb097          	auipc	ra,0xffffb
    800057a6:	d88080e7          	jalr	-632(ra) # 8000052a <panic>
    return 0;
    800057aa:	84aa                	mv	s1,a0
    800057ac:	b739                	j	800056ba <create+0x72>

00000000800057ae <sys_dup>:
{
    800057ae:	7179                	addi	sp,sp,-48
    800057b0:	f406                	sd	ra,40(sp)
    800057b2:	f022                	sd	s0,32(sp)
    800057b4:	ec26                	sd	s1,24(sp)
    800057b6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800057b8:	fd840613          	addi	a2,s0,-40
    800057bc:	4581                	li	a1,0
    800057be:	4501                	li	a0,0
    800057c0:	00000097          	auipc	ra,0x0
    800057c4:	dde080e7          	jalr	-546(ra) # 8000559e <argfd>
    return -1;
    800057c8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800057ca:	02054363          	bltz	a0,800057f0 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800057ce:	fd843503          	ld	a0,-40(s0)
    800057d2:	00000097          	auipc	ra,0x0
    800057d6:	e34080e7          	jalr	-460(ra) # 80005606 <fdalloc>
    800057da:	84aa                	mv	s1,a0
    return -1;
    800057dc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800057de:	00054963          	bltz	a0,800057f0 <sys_dup+0x42>
  filedup(f);
    800057e2:	fd843503          	ld	a0,-40(s0)
    800057e6:	fffff097          	auipc	ra,0xfffff
    800057ea:	36c080e7          	jalr	876(ra) # 80004b52 <filedup>
  return fd;
    800057ee:	87a6                	mv	a5,s1
}
    800057f0:	853e                	mv	a0,a5
    800057f2:	70a2                	ld	ra,40(sp)
    800057f4:	7402                	ld	s0,32(sp)
    800057f6:	64e2                	ld	s1,24(sp)
    800057f8:	6145                	addi	sp,sp,48
    800057fa:	8082                	ret

00000000800057fc <sys_read>:
{
    800057fc:	7179                	addi	sp,sp,-48
    800057fe:	f406                	sd	ra,40(sp)
    80005800:	f022                	sd	s0,32(sp)
    80005802:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005804:	fe840613          	addi	a2,s0,-24
    80005808:	4581                	li	a1,0
    8000580a:	4501                	li	a0,0
    8000580c:	00000097          	auipc	ra,0x0
    80005810:	d92080e7          	jalr	-622(ra) # 8000559e <argfd>
    return -1;
    80005814:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005816:	04054163          	bltz	a0,80005858 <sys_read+0x5c>
    8000581a:	fe440593          	addi	a1,s0,-28
    8000581e:	4509                	li	a0,2
    80005820:	ffffd097          	auipc	ra,0xffffd
    80005824:	7ea080e7          	jalr	2026(ra) # 8000300a <argint>
    return -1;
    80005828:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000582a:	02054763          	bltz	a0,80005858 <sys_read+0x5c>
    8000582e:	fd840593          	addi	a1,s0,-40
    80005832:	4505                	li	a0,1
    80005834:	ffffd097          	auipc	ra,0xffffd
    80005838:	7f8080e7          	jalr	2040(ra) # 8000302c <argaddr>
    return -1;
    8000583c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000583e:	00054d63          	bltz	a0,80005858 <sys_read+0x5c>
  return fileread(f, p, n);
    80005842:	fe442603          	lw	a2,-28(s0)
    80005846:	fd843583          	ld	a1,-40(s0)
    8000584a:	fe843503          	ld	a0,-24(s0)
    8000584e:	fffff097          	auipc	ra,0xfffff
    80005852:	490080e7          	jalr	1168(ra) # 80004cde <fileread>
    80005856:	87aa                	mv	a5,a0
}
    80005858:	853e                	mv	a0,a5
    8000585a:	70a2                	ld	ra,40(sp)
    8000585c:	7402                	ld	s0,32(sp)
    8000585e:	6145                	addi	sp,sp,48
    80005860:	8082                	ret

0000000080005862 <sys_write>:
{
    80005862:	7179                	addi	sp,sp,-48
    80005864:	f406                	sd	ra,40(sp)
    80005866:	f022                	sd	s0,32(sp)
    80005868:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000586a:	fe840613          	addi	a2,s0,-24
    8000586e:	4581                	li	a1,0
    80005870:	4501                	li	a0,0
    80005872:	00000097          	auipc	ra,0x0
    80005876:	d2c080e7          	jalr	-724(ra) # 8000559e <argfd>
    return -1;
    8000587a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000587c:	04054163          	bltz	a0,800058be <sys_write+0x5c>
    80005880:	fe440593          	addi	a1,s0,-28
    80005884:	4509                	li	a0,2
    80005886:	ffffd097          	auipc	ra,0xffffd
    8000588a:	784080e7          	jalr	1924(ra) # 8000300a <argint>
    return -1;
    8000588e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005890:	02054763          	bltz	a0,800058be <sys_write+0x5c>
    80005894:	fd840593          	addi	a1,s0,-40
    80005898:	4505                	li	a0,1
    8000589a:	ffffd097          	auipc	ra,0xffffd
    8000589e:	792080e7          	jalr	1938(ra) # 8000302c <argaddr>
    return -1;
    800058a2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058a4:	00054d63          	bltz	a0,800058be <sys_write+0x5c>
  return filewrite(f, p, n);
    800058a8:	fe442603          	lw	a2,-28(s0)
    800058ac:	fd843583          	ld	a1,-40(s0)
    800058b0:	fe843503          	ld	a0,-24(s0)
    800058b4:	fffff097          	auipc	ra,0xfffff
    800058b8:	4ec080e7          	jalr	1260(ra) # 80004da0 <filewrite>
    800058bc:	87aa                	mv	a5,a0
}
    800058be:	853e                	mv	a0,a5
    800058c0:	70a2                	ld	ra,40(sp)
    800058c2:	7402                	ld	s0,32(sp)
    800058c4:	6145                	addi	sp,sp,48
    800058c6:	8082                	ret

00000000800058c8 <sys_close>:
{
    800058c8:	1101                	addi	sp,sp,-32
    800058ca:	ec06                	sd	ra,24(sp)
    800058cc:	e822                	sd	s0,16(sp)
    800058ce:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800058d0:	fe040613          	addi	a2,s0,-32
    800058d4:	fec40593          	addi	a1,s0,-20
    800058d8:	4501                	li	a0,0
    800058da:	00000097          	auipc	ra,0x0
    800058de:	cc4080e7          	jalr	-828(ra) # 8000559e <argfd>
    return -1;
    800058e2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800058e4:	02054463          	bltz	a0,8000590c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800058e8:	ffffc097          	auipc	ra,0xffffc
    800058ec:	096080e7          	jalr	150(ra) # 8000197e <myproc>
    800058f0:	fec42783          	lw	a5,-20(s0)
    800058f4:	07f9                	addi	a5,a5,30
    800058f6:	078e                	slli	a5,a5,0x3
    800058f8:	97aa                	add	a5,a5,a0
    800058fa:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800058fe:	fe043503          	ld	a0,-32(s0)
    80005902:	fffff097          	auipc	ra,0xfffff
    80005906:	2a2080e7          	jalr	674(ra) # 80004ba4 <fileclose>
  return 0;
    8000590a:	4781                	li	a5,0
}
    8000590c:	853e                	mv	a0,a5
    8000590e:	60e2                	ld	ra,24(sp)
    80005910:	6442                	ld	s0,16(sp)
    80005912:	6105                	addi	sp,sp,32
    80005914:	8082                	ret

0000000080005916 <sys_fstat>:
{
    80005916:	1101                	addi	sp,sp,-32
    80005918:	ec06                	sd	ra,24(sp)
    8000591a:	e822                	sd	s0,16(sp)
    8000591c:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000591e:	fe840613          	addi	a2,s0,-24
    80005922:	4581                	li	a1,0
    80005924:	4501                	li	a0,0
    80005926:	00000097          	auipc	ra,0x0
    8000592a:	c78080e7          	jalr	-904(ra) # 8000559e <argfd>
    return -1;
    8000592e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005930:	02054563          	bltz	a0,8000595a <sys_fstat+0x44>
    80005934:	fe040593          	addi	a1,s0,-32
    80005938:	4505                	li	a0,1
    8000593a:	ffffd097          	auipc	ra,0xffffd
    8000593e:	6f2080e7          	jalr	1778(ra) # 8000302c <argaddr>
    return -1;
    80005942:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005944:	00054b63          	bltz	a0,8000595a <sys_fstat+0x44>
  return filestat(f, st);
    80005948:	fe043583          	ld	a1,-32(s0)
    8000594c:	fe843503          	ld	a0,-24(s0)
    80005950:	fffff097          	auipc	ra,0xfffff
    80005954:	31c080e7          	jalr	796(ra) # 80004c6c <filestat>
    80005958:	87aa                	mv	a5,a0
}
    8000595a:	853e                	mv	a0,a5
    8000595c:	60e2                	ld	ra,24(sp)
    8000595e:	6442                	ld	s0,16(sp)
    80005960:	6105                	addi	sp,sp,32
    80005962:	8082                	ret

0000000080005964 <sys_link>:
{
    80005964:	7169                	addi	sp,sp,-304
    80005966:	f606                	sd	ra,296(sp)
    80005968:	f222                	sd	s0,288(sp)
    8000596a:	ee26                	sd	s1,280(sp)
    8000596c:	ea4a                	sd	s2,272(sp)
    8000596e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005970:	08000613          	li	a2,128
    80005974:	ed040593          	addi	a1,s0,-304
    80005978:	4501                	li	a0,0
    8000597a:	ffffd097          	auipc	ra,0xffffd
    8000597e:	6d4080e7          	jalr	1748(ra) # 8000304e <argstr>
    return -1;
    80005982:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005984:	10054e63          	bltz	a0,80005aa0 <sys_link+0x13c>
    80005988:	08000613          	li	a2,128
    8000598c:	f5040593          	addi	a1,s0,-176
    80005990:	4505                	li	a0,1
    80005992:	ffffd097          	auipc	ra,0xffffd
    80005996:	6bc080e7          	jalr	1724(ra) # 8000304e <argstr>
    return -1;
    8000599a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000599c:	10054263          	bltz	a0,80005aa0 <sys_link+0x13c>
  begin_op();
    800059a0:	fffff097          	auipc	ra,0xfffff
    800059a4:	d38080e7          	jalr	-712(ra) # 800046d8 <begin_op>
  if((ip = namei(old)) == 0){
    800059a8:	ed040513          	addi	a0,s0,-304
    800059ac:	fffff097          	auipc	ra,0xfffff
    800059b0:	b0c080e7          	jalr	-1268(ra) # 800044b8 <namei>
    800059b4:	84aa                	mv	s1,a0
    800059b6:	c551                	beqz	a0,80005a42 <sys_link+0xde>
  ilock(ip);
    800059b8:	ffffe097          	auipc	ra,0xffffe
    800059bc:	34a080e7          	jalr	842(ra) # 80003d02 <ilock>
  if(ip->type == T_DIR){
    800059c0:	04449703          	lh	a4,68(s1)
    800059c4:	4785                	li	a5,1
    800059c6:	08f70463          	beq	a4,a5,80005a4e <sys_link+0xea>
  ip->nlink++;
    800059ca:	04a4d783          	lhu	a5,74(s1)
    800059ce:	2785                	addiw	a5,a5,1
    800059d0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059d4:	8526                	mv	a0,s1
    800059d6:	ffffe097          	auipc	ra,0xffffe
    800059da:	262080e7          	jalr	610(ra) # 80003c38 <iupdate>
  iunlock(ip);
    800059de:	8526                	mv	a0,s1
    800059e0:	ffffe097          	auipc	ra,0xffffe
    800059e4:	3e4080e7          	jalr	996(ra) # 80003dc4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800059e8:	fd040593          	addi	a1,s0,-48
    800059ec:	f5040513          	addi	a0,s0,-176
    800059f0:	fffff097          	auipc	ra,0xfffff
    800059f4:	ae6080e7          	jalr	-1306(ra) # 800044d6 <nameiparent>
    800059f8:	892a                	mv	s2,a0
    800059fa:	c935                	beqz	a0,80005a6e <sys_link+0x10a>
  ilock(dp);
    800059fc:	ffffe097          	auipc	ra,0xffffe
    80005a00:	306080e7          	jalr	774(ra) # 80003d02 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005a04:	00092703          	lw	a4,0(s2)
    80005a08:	409c                	lw	a5,0(s1)
    80005a0a:	04f71d63          	bne	a4,a5,80005a64 <sys_link+0x100>
    80005a0e:	40d0                	lw	a2,4(s1)
    80005a10:	fd040593          	addi	a1,s0,-48
    80005a14:	854a                	mv	a0,s2
    80005a16:	fffff097          	auipc	ra,0xfffff
    80005a1a:	9e0080e7          	jalr	-1568(ra) # 800043f6 <dirlink>
    80005a1e:	04054363          	bltz	a0,80005a64 <sys_link+0x100>
  iunlockput(dp);
    80005a22:	854a                	mv	a0,s2
    80005a24:	ffffe097          	auipc	ra,0xffffe
    80005a28:	540080e7          	jalr	1344(ra) # 80003f64 <iunlockput>
  iput(ip);
    80005a2c:	8526                	mv	a0,s1
    80005a2e:	ffffe097          	auipc	ra,0xffffe
    80005a32:	48e080e7          	jalr	1166(ra) # 80003ebc <iput>
  end_op();
    80005a36:	fffff097          	auipc	ra,0xfffff
    80005a3a:	d22080e7          	jalr	-734(ra) # 80004758 <end_op>
  return 0;
    80005a3e:	4781                	li	a5,0
    80005a40:	a085                	j	80005aa0 <sys_link+0x13c>
    end_op();
    80005a42:	fffff097          	auipc	ra,0xfffff
    80005a46:	d16080e7          	jalr	-746(ra) # 80004758 <end_op>
    return -1;
    80005a4a:	57fd                	li	a5,-1
    80005a4c:	a891                	j	80005aa0 <sys_link+0x13c>
    iunlockput(ip);
    80005a4e:	8526                	mv	a0,s1
    80005a50:	ffffe097          	auipc	ra,0xffffe
    80005a54:	514080e7          	jalr	1300(ra) # 80003f64 <iunlockput>
    end_op();
    80005a58:	fffff097          	auipc	ra,0xfffff
    80005a5c:	d00080e7          	jalr	-768(ra) # 80004758 <end_op>
    return -1;
    80005a60:	57fd                	li	a5,-1
    80005a62:	a83d                	j	80005aa0 <sys_link+0x13c>
    iunlockput(dp);
    80005a64:	854a                	mv	a0,s2
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	4fe080e7          	jalr	1278(ra) # 80003f64 <iunlockput>
  ilock(ip);
    80005a6e:	8526                	mv	a0,s1
    80005a70:	ffffe097          	auipc	ra,0xffffe
    80005a74:	292080e7          	jalr	658(ra) # 80003d02 <ilock>
  ip->nlink--;
    80005a78:	04a4d783          	lhu	a5,74(s1)
    80005a7c:	37fd                	addiw	a5,a5,-1
    80005a7e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a82:	8526                	mv	a0,s1
    80005a84:	ffffe097          	auipc	ra,0xffffe
    80005a88:	1b4080e7          	jalr	436(ra) # 80003c38 <iupdate>
  iunlockput(ip);
    80005a8c:	8526                	mv	a0,s1
    80005a8e:	ffffe097          	auipc	ra,0xffffe
    80005a92:	4d6080e7          	jalr	1238(ra) # 80003f64 <iunlockput>
  end_op();
    80005a96:	fffff097          	auipc	ra,0xfffff
    80005a9a:	cc2080e7          	jalr	-830(ra) # 80004758 <end_op>
  return -1;
    80005a9e:	57fd                	li	a5,-1
}
    80005aa0:	853e                	mv	a0,a5
    80005aa2:	70b2                	ld	ra,296(sp)
    80005aa4:	7412                	ld	s0,288(sp)
    80005aa6:	64f2                	ld	s1,280(sp)
    80005aa8:	6952                	ld	s2,272(sp)
    80005aaa:	6155                	addi	sp,sp,304
    80005aac:	8082                	ret

0000000080005aae <sys_unlink>:
{
    80005aae:	7151                	addi	sp,sp,-240
    80005ab0:	f586                	sd	ra,232(sp)
    80005ab2:	f1a2                	sd	s0,224(sp)
    80005ab4:	eda6                	sd	s1,216(sp)
    80005ab6:	e9ca                	sd	s2,208(sp)
    80005ab8:	e5ce                	sd	s3,200(sp)
    80005aba:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005abc:	08000613          	li	a2,128
    80005ac0:	f3040593          	addi	a1,s0,-208
    80005ac4:	4501                	li	a0,0
    80005ac6:	ffffd097          	auipc	ra,0xffffd
    80005aca:	588080e7          	jalr	1416(ra) # 8000304e <argstr>
    80005ace:	18054163          	bltz	a0,80005c50 <sys_unlink+0x1a2>
  begin_op();
    80005ad2:	fffff097          	auipc	ra,0xfffff
    80005ad6:	c06080e7          	jalr	-1018(ra) # 800046d8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005ada:	fb040593          	addi	a1,s0,-80
    80005ade:	f3040513          	addi	a0,s0,-208
    80005ae2:	fffff097          	auipc	ra,0xfffff
    80005ae6:	9f4080e7          	jalr	-1548(ra) # 800044d6 <nameiparent>
    80005aea:	84aa                	mv	s1,a0
    80005aec:	c979                	beqz	a0,80005bc2 <sys_unlink+0x114>
  ilock(dp);
    80005aee:	ffffe097          	auipc	ra,0xffffe
    80005af2:	214080e7          	jalr	532(ra) # 80003d02 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005af6:	00003597          	auipc	a1,0x3
    80005afa:	ef258593          	addi	a1,a1,-270 # 800089e8 <syscalls+0x2c0>
    80005afe:	fb040513          	addi	a0,s0,-80
    80005b02:	ffffe097          	auipc	ra,0xffffe
    80005b06:	6ca080e7          	jalr	1738(ra) # 800041cc <namecmp>
    80005b0a:	14050a63          	beqz	a0,80005c5e <sys_unlink+0x1b0>
    80005b0e:	00003597          	auipc	a1,0x3
    80005b12:	ee258593          	addi	a1,a1,-286 # 800089f0 <syscalls+0x2c8>
    80005b16:	fb040513          	addi	a0,s0,-80
    80005b1a:	ffffe097          	auipc	ra,0xffffe
    80005b1e:	6b2080e7          	jalr	1714(ra) # 800041cc <namecmp>
    80005b22:	12050e63          	beqz	a0,80005c5e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005b26:	f2c40613          	addi	a2,s0,-212
    80005b2a:	fb040593          	addi	a1,s0,-80
    80005b2e:	8526                	mv	a0,s1
    80005b30:	ffffe097          	auipc	ra,0xffffe
    80005b34:	6b6080e7          	jalr	1718(ra) # 800041e6 <dirlookup>
    80005b38:	892a                	mv	s2,a0
    80005b3a:	12050263          	beqz	a0,80005c5e <sys_unlink+0x1b0>
  ilock(ip);
    80005b3e:	ffffe097          	auipc	ra,0xffffe
    80005b42:	1c4080e7          	jalr	452(ra) # 80003d02 <ilock>
  if(ip->nlink < 1)
    80005b46:	04a91783          	lh	a5,74(s2)
    80005b4a:	08f05263          	blez	a5,80005bce <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005b4e:	04491703          	lh	a4,68(s2)
    80005b52:	4785                	li	a5,1
    80005b54:	08f70563          	beq	a4,a5,80005bde <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005b58:	4641                	li	a2,16
    80005b5a:	4581                	li	a1,0
    80005b5c:	fc040513          	addi	a0,s0,-64
    80005b60:	ffffb097          	auipc	ra,0xffffb
    80005b64:	15e080e7          	jalr	350(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b68:	4741                	li	a4,16
    80005b6a:	f2c42683          	lw	a3,-212(s0)
    80005b6e:	fc040613          	addi	a2,s0,-64
    80005b72:	4581                	li	a1,0
    80005b74:	8526                	mv	a0,s1
    80005b76:	ffffe097          	auipc	ra,0xffffe
    80005b7a:	538080e7          	jalr	1336(ra) # 800040ae <writei>
    80005b7e:	47c1                	li	a5,16
    80005b80:	0af51563          	bne	a0,a5,80005c2a <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005b84:	04491703          	lh	a4,68(s2)
    80005b88:	4785                	li	a5,1
    80005b8a:	0af70863          	beq	a4,a5,80005c3a <sys_unlink+0x18c>
  iunlockput(dp);
    80005b8e:	8526                	mv	a0,s1
    80005b90:	ffffe097          	auipc	ra,0xffffe
    80005b94:	3d4080e7          	jalr	980(ra) # 80003f64 <iunlockput>
  ip->nlink--;
    80005b98:	04a95783          	lhu	a5,74(s2)
    80005b9c:	37fd                	addiw	a5,a5,-1
    80005b9e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005ba2:	854a                	mv	a0,s2
    80005ba4:	ffffe097          	auipc	ra,0xffffe
    80005ba8:	094080e7          	jalr	148(ra) # 80003c38 <iupdate>
  iunlockput(ip);
    80005bac:	854a                	mv	a0,s2
    80005bae:	ffffe097          	auipc	ra,0xffffe
    80005bb2:	3b6080e7          	jalr	950(ra) # 80003f64 <iunlockput>
  end_op();
    80005bb6:	fffff097          	auipc	ra,0xfffff
    80005bba:	ba2080e7          	jalr	-1118(ra) # 80004758 <end_op>
  return 0;
    80005bbe:	4501                	li	a0,0
    80005bc0:	a84d                	j	80005c72 <sys_unlink+0x1c4>
    end_op();
    80005bc2:	fffff097          	auipc	ra,0xfffff
    80005bc6:	b96080e7          	jalr	-1130(ra) # 80004758 <end_op>
    return -1;
    80005bca:	557d                	li	a0,-1
    80005bcc:	a05d                	j	80005c72 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005bce:	00003517          	auipc	a0,0x3
    80005bd2:	e4a50513          	addi	a0,a0,-438 # 80008a18 <syscalls+0x2f0>
    80005bd6:	ffffb097          	auipc	ra,0xffffb
    80005bda:	954080e7          	jalr	-1708(ra) # 8000052a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bde:	04c92703          	lw	a4,76(s2)
    80005be2:	02000793          	li	a5,32
    80005be6:	f6e7f9e3          	bgeu	a5,a4,80005b58 <sys_unlink+0xaa>
    80005bea:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005bee:	4741                	li	a4,16
    80005bf0:	86ce                	mv	a3,s3
    80005bf2:	f1840613          	addi	a2,s0,-232
    80005bf6:	4581                	li	a1,0
    80005bf8:	854a                	mv	a0,s2
    80005bfa:	ffffe097          	auipc	ra,0xffffe
    80005bfe:	3bc080e7          	jalr	956(ra) # 80003fb6 <readi>
    80005c02:	47c1                	li	a5,16
    80005c04:	00f51b63          	bne	a0,a5,80005c1a <sys_unlink+0x16c>
    if(de.inum != 0)
    80005c08:	f1845783          	lhu	a5,-232(s0)
    80005c0c:	e7a1                	bnez	a5,80005c54 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c0e:	29c1                	addiw	s3,s3,16
    80005c10:	04c92783          	lw	a5,76(s2)
    80005c14:	fcf9ede3          	bltu	s3,a5,80005bee <sys_unlink+0x140>
    80005c18:	b781                	j	80005b58 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005c1a:	00003517          	auipc	a0,0x3
    80005c1e:	e1650513          	addi	a0,a0,-490 # 80008a30 <syscalls+0x308>
    80005c22:	ffffb097          	auipc	ra,0xffffb
    80005c26:	908080e7          	jalr	-1784(ra) # 8000052a <panic>
    panic("unlink: writei");
    80005c2a:	00003517          	auipc	a0,0x3
    80005c2e:	e1e50513          	addi	a0,a0,-482 # 80008a48 <syscalls+0x320>
    80005c32:	ffffb097          	auipc	ra,0xffffb
    80005c36:	8f8080e7          	jalr	-1800(ra) # 8000052a <panic>
    dp->nlink--;
    80005c3a:	04a4d783          	lhu	a5,74(s1)
    80005c3e:	37fd                	addiw	a5,a5,-1
    80005c40:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c44:	8526                	mv	a0,s1
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	ff2080e7          	jalr	-14(ra) # 80003c38 <iupdate>
    80005c4e:	b781                	j	80005b8e <sys_unlink+0xe0>
    return -1;
    80005c50:	557d                	li	a0,-1
    80005c52:	a005                	j	80005c72 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005c54:	854a                	mv	a0,s2
    80005c56:	ffffe097          	auipc	ra,0xffffe
    80005c5a:	30e080e7          	jalr	782(ra) # 80003f64 <iunlockput>
  iunlockput(dp);
    80005c5e:	8526                	mv	a0,s1
    80005c60:	ffffe097          	auipc	ra,0xffffe
    80005c64:	304080e7          	jalr	772(ra) # 80003f64 <iunlockput>
  end_op();
    80005c68:	fffff097          	auipc	ra,0xfffff
    80005c6c:	af0080e7          	jalr	-1296(ra) # 80004758 <end_op>
  return -1;
    80005c70:	557d                	li	a0,-1
}
    80005c72:	70ae                	ld	ra,232(sp)
    80005c74:	740e                	ld	s0,224(sp)
    80005c76:	64ee                	ld	s1,216(sp)
    80005c78:	694e                	ld	s2,208(sp)
    80005c7a:	69ae                	ld	s3,200(sp)
    80005c7c:	616d                	addi	sp,sp,240
    80005c7e:	8082                	ret

0000000080005c80 <sys_open>:

uint64
sys_open(void)
{
    80005c80:	7131                	addi	sp,sp,-192
    80005c82:	fd06                	sd	ra,184(sp)
    80005c84:	f922                	sd	s0,176(sp)
    80005c86:	f526                	sd	s1,168(sp)
    80005c88:	f14a                	sd	s2,160(sp)
    80005c8a:	ed4e                	sd	s3,152(sp)
    80005c8c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005c8e:	08000613          	li	a2,128
    80005c92:	f5040593          	addi	a1,s0,-176
    80005c96:	4501                	li	a0,0
    80005c98:	ffffd097          	auipc	ra,0xffffd
    80005c9c:	3b6080e7          	jalr	950(ra) # 8000304e <argstr>
    return -1;
    80005ca0:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005ca2:	0c054163          	bltz	a0,80005d64 <sys_open+0xe4>
    80005ca6:	f4c40593          	addi	a1,s0,-180
    80005caa:	4505                	li	a0,1
    80005cac:	ffffd097          	auipc	ra,0xffffd
    80005cb0:	35e080e7          	jalr	862(ra) # 8000300a <argint>
    80005cb4:	0a054863          	bltz	a0,80005d64 <sys_open+0xe4>

  begin_op();
    80005cb8:	fffff097          	auipc	ra,0xfffff
    80005cbc:	a20080e7          	jalr	-1504(ra) # 800046d8 <begin_op>

  if(omode & O_CREATE){
    80005cc0:	f4c42783          	lw	a5,-180(s0)
    80005cc4:	2007f793          	andi	a5,a5,512
    80005cc8:	cbdd                	beqz	a5,80005d7e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005cca:	4681                	li	a3,0
    80005ccc:	4601                	li	a2,0
    80005cce:	4589                	li	a1,2
    80005cd0:	f5040513          	addi	a0,s0,-176
    80005cd4:	00000097          	auipc	ra,0x0
    80005cd8:	974080e7          	jalr	-1676(ra) # 80005648 <create>
    80005cdc:	892a                	mv	s2,a0
    if(ip == 0){
    80005cde:	c959                	beqz	a0,80005d74 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005ce0:	04491703          	lh	a4,68(s2)
    80005ce4:	478d                	li	a5,3
    80005ce6:	00f71763          	bne	a4,a5,80005cf4 <sys_open+0x74>
    80005cea:	04695703          	lhu	a4,70(s2)
    80005cee:	47a5                	li	a5,9
    80005cf0:	0ce7ec63          	bltu	a5,a4,80005dc8 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005cf4:	fffff097          	auipc	ra,0xfffff
    80005cf8:	df4080e7          	jalr	-524(ra) # 80004ae8 <filealloc>
    80005cfc:	89aa                	mv	s3,a0
    80005cfe:	10050263          	beqz	a0,80005e02 <sys_open+0x182>
    80005d02:	00000097          	auipc	ra,0x0
    80005d06:	904080e7          	jalr	-1788(ra) # 80005606 <fdalloc>
    80005d0a:	84aa                	mv	s1,a0
    80005d0c:	0e054663          	bltz	a0,80005df8 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005d10:	04491703          	lh	a4,68(s2)
    80005d14:	478d                	li	a5,3
    80005d16:	0cf70463          	beq	a4,a5,80005dde <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005d1a:	4789                	li	a5,2
    80005d1c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005d20:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005d24:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005d28:	f4c42783          	lw	a5,-180(s0)
    80005d2c:	0017c713          	xori	a4,a5,1
    80005d30:	8b05                	andi	a4,a4,1
    80005d32:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005d36:	0037f713          	andi	a4,a5,3
    80005d3a:	00e03733          	snez	a4,a4
    80005d3e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005d42:	4007f793          	andi	a5,a5,1024
    80005d46:	c791                	beqz	a5,80005d52 <sys_open+0xd2>
    80005d48:	04491703          	lh	a4,68(s2)
    80005d4c:	4789                	li	a5,2
    80005d4e:	08f70f63          	beq	a4,a5,80005dec <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005d52:	854a                	mv	a0,s2
    80005d54:	ffffe097          	auipc	ra,0xffffe
    80005d58:	070080e7          	jalr	112(ra) # 80003dc4 <iunlock>
  end_op();
    80005d5c:	fffff097          	auipc	ra,0xfffff
    80005d60:	9fc080e7          	jalr	-1540(ra) # 80004758 <end_op>

  return fd;
}
    80005d64:	8526                	mv	a0,s1
    80005d66:	70ea                	ld	ra,184(sp)
    80005d68:	744a                	ld	s0,176(sp)
    80005d6a:	74aa                	ld	s1,168(sp)
    80005d6c:	790a                	ld	s2,160(sp)
    80005d6e:	69ea                	ld	s3,152(sp)
    80005d70:	6129                	addi	sp,sp,192
    80005d72:	8082                	ret
      end_op();
    80005d74:	fffff097          	auipc	ra,0xfffff
    80005d78:	9e4080e7          	jalr	-1564(ra) # 80004758 <end_op>
      return -1;
    80005d7c:	b7e5                	j	80005d64 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005d7e:	f5040513          	addi	a0,s0,-176
    80005d82:	ffffe097          	auipc	ra,0xffffe
    80005d86:	736080e7          	jalr	1846(ra) # 800044b8 <namei>
    80005d8a:	892a                	mv	s2,a0
    80005d8c:	c905                	beqz	a0,80005dbc <sys_open+0x13c>
    ilock(ip);
    80005d8e:	ffffe097          	auipc	ra,0xffffe
    80005d92:	f74080e7          	jalr	-140(ra) # 80003d02 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005d96:	04491703          	lh	a4,68(s2)
    80005d9a:	4785                	li	a5,1
    80005d9c:	f4f712e3          	bne	a4,a5,80005ce0 <sys_open+0x60>
    80005da0:	f4c42783          	lw	a5,-180(s0)
    80005da4:	dba1                	beqz	a5,80005cf4 <sys_open+0x74>
      iunlockput(ip);
    80005da6:	854a                	mv	a0,s2
    80005da8:	ffffe097          	auipc	ra,0xffffe
    80005dac:	1bc080e7          	jalr	444(ra) # 80003f64 <iunlockput>
      end_op();
    80005db0:	fffff097          	auipc	ra,0xfffff
    80005db4:	9a8080e7          	jalr	-1624(ra) # 80004758 <end_op>
      return -1;
    80005db8:	54fd                	li	s1,-1
    80005dba:	b76d                	j	80005d64 <sys_open+0xe4>
      end_op();
    80005dbc:	fffff097          	auipc	ra,0xfffff
    80005dc0:	99c080e7          	jalr	-1636(ra) # 80004758 <end_op>
      return -1;
    80005dc4:	54fd                	li	s1,-1
    80005dc6:	bf79                	j	80005d64 <sys_open+0xe4>
    iunlockput(ip);
    80005dc8:	854a                	mv	a0,s2
    80005dca:	ffffe097          	auipc	ra,0xffffe
    80005dce:	19a080e7          	jalr	410(ra) # 80003f64 <iunlockput>
    end_op();
    80005dd2:	fffff097          	auipc	ra,0xfffff
    80005dd6:	986080e7          	jalr	-1658(ra) # 80004758 <end_op>
    return -1;
    80005dda:	54fd                	li	s1,-1
    80005ddc:	b761                	j	80005d64 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005dde:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005de2:	04691783          	lh	a5,70(s2)
    80005de6:	02f99223          	sh	a5,36(s3)
    80005dea:	bf2d                	j	80005d24 <sys_open+0xa4>
    itrunc(ip);
    80005dec:	854a                	mv	a0,s2
    80005dee:	ffffe097          	auipc	ra,0xffffe
    80005df2:	022080e7          	jalr	34(ra) # 80003e10 <itrunc>
    80005df6:	bfb1                	j	80005d52 <sys_open+0xd2>
      fileclose(f);
    80005df8:	854e                	mv	a0,s3
    80005dfa:	fffff097          	auipc	ra,0xfffff
    80005dfe:	daa080e7          	jalr	-598(ra) # 80004ba4 <fileclose>
    iunlockput(ip);
    80005e02:	854a                	mv	a0,s2
    80005e04:	ffffe097          	auipc	ra,0xffffe
    80005e08:	160080e7          	jalr	352(ra) # 80003f64 <iunlockput>
    end_op();
    80005e0c:	fffff097          	auipc	ra,0xfffff
    80005e10:	94c080e7          	jalr	-1716(ra) # 80004758 <end_op>
    return -1;
    80005e14:	54fd                	li	s1,-1
    80005e16:	b7b9                	j	80005d64 <sys_open+0xe4>

0000000080005e18 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005e18:	7175                	addi	sp,sp,-144
    80005e1a:	e506                	sd	ra,136(sp)
    80005e1c:	e122                	sd	s0,128(sp)
    80005e1e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005e20:	fffff097          	auipc	ra,0xfffff
    80005e24:	8b8080e7          	jalr	-1864(ra) # 800046d8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005e28:	08000613          	li	a2,128
    80005e2c:	f7040593          	addi	a1,s0,-144
    80005e30:	4501                	li	a0,0
    80005e32:	ffffd097          	auipc	ra,0xffffd
    80005e36:	21c080e7          	jalr	540(ra) # 8000304e <argstr>
    80005e3a:	02054963          	bltz	a0,80005e6c <sys_mkdir+0x54>
    80005e3e:	4681                	li	a3,0
    80005e40:	4601                	li	a2,0
    80005e42:	4585                	li	a1,1
    80005e44:	f7040513          	addi	a0,s0,-144
    80005e48:	00000097          	auipc	ra,0x0
    80005e4c:	800080e7          	jalr	-2048(ra) # 80005648 <create>
    80005e50:	cd11                	beqz	a0,80005e6c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e52:	ffffe097          	auipc	ra,0xffffe
    80005e56:	112080e7          	jalr	274(ra) # 80003f64 <iunlockput>
  end_op();
    80005e5a:	fffff097          	auipc	ra,0xfffff
    80005e5e:	8fe080e7          	jalr	-1794(ra) # 80004758 <end_op>
  return 0;
    80005e62:	4501                	li	a0,0
}
    80005e64:	60aa                	ld	ra,136(sp)
    80005e66:	640a                	ld	s0,128(sp)
    80005e68:	6149                	addi	sp,sp,144
    80005e6a:	8082                	ret
    end_op();
    80005e6c:	fffff097          	auipc	ra,0xfffff
    80005e70:	8ec080e7          	jalr	-1812(ra) # 80004758 <end_op>
    return -1;
    80005e74:	557d                	li	a0,-1
    80005e76:	b7fd                	j	80005e64 <sys_mkdir+0x4c>

0000000080005e78 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005e78:	7135                	addi	sp,sp,-160
    80005e7a:	ed06                	sd	ra,152(sp)
    80005e7c:	e922                	sd	s0,144(sp)
    80005e7e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005e80:	fffff097          	auipc	ra,0xfffff
    80005e84:	858080e7          	jalr	-1960(ra) # 800046d8 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e88:	08000613          	li	a2,128
    80005e8c:	f7040593          	addi	a1,s0,-144
    80005e90:	4501                	li	a0,0
    80005e92:	ffffd097          	auipc	ra,0xffffd
    80005e96:	1bc080e7          	jalr	444(ra) # 8000304e <argstr>
    80005e9a:	04054a63          	bltz	a0,80005eee <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005e9e:	f6c40593          	addi	a1,s0,-148
    80005ea2:	4505                	li	a0,1
    80005ea4:	ffffd097          	auipc	ra,0xffffd
    80005ea8:	166080e7          	jalr	358(ra) # 8000300a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005eac:	04054163          	bltz	a0,80005eee <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005eb0:	f6840593          	addi	a1,s0,-152
    80005eb4:	4509                	li	a0,2
    80005eb6:	ffffd097          	auipc	ra,0xffffd
    80005eba:	154080e7          	jalr	340(ra) # 8000300a <argint>
     argint(1, &major) < 0 ||
    80005ebe:	02054863          	bltz	a0,80005eee <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ec2:	f6841683          	lh	a3,-152(s0)
    80005ec6:	f6c41603          	lh	a2,-148(s0)
    80005eca:	458d                	li	a1,3
    80005ecc:	f7040513          	addi	a0,s0,-144
    80005ed0:	fffff097          	auipc	ra,0xfffff
    80005ed4:	778080e7          	jalr	1912(ra) # 80005648 <create>
     argint(2, &minor) < 0 ||
    80005ed8:	c919                	beqz	a0,80005eee <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005eda:	ffffe097          	auipc	ra,0xffffe
    80005ede:	08a080e7          	jalr	138(ra) # 80003f64 <iunlockput>
  end_op();
    80005ee2:	fffff097          	auipc	ra,0xfffff
    80005ee6:	876080e7          	jalr	-1930(ra) # 80004758 <end_op>
  return 0;
    80005eea:	4501                	li	a0,0
    80005eec:	a031                	j	80005ef8 <sys_mknod+0x80>
    end_op();
    80005eee:	fffff097          	auipc	ra,0xfffff
    80005ef2:	86a080e7          	jalr	-1942(ra) # 80004758 <end_op>
    return -1;
    80005ef6:	557d                	li	a0,-1
}
    80005ef8:	60ea                	ld	ra,152(sp)
    80005efa:	644a                	ld	s0,144(sp)
    80005efc:	610d                	addi	sp,sp,160
    80005efe:	8082                	ret

0000000080005f00 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005f00:	7135                	addi	sp,sp,-160
    80005f02:	ed06                	sd	ra,152(sp)
    80005f04:	e922                	sd	s0,144(sp)
    80005f06:	e526                	sd	s1,136(sp)
    80005f08:	e14a                	sd	s2,128(sp)
    80005f0a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005f0c:	ffffc097          	auipc	ra,0xffffc
    80005f10:	a72080e7          	jalr	-1422(ra) # 8000197e <myproc>
    80005f14:	892a                	mv	s2,a0
  
  begin_op();
    80005f16:	ffffe097          	auipc	ra,0xffffe
    80005f1a:	7c2080e7          	jalr	1986(ra) # 800046d8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005f1e:	08000613          	li	a2,128
    80005f22:	f6040593          	addi	a1,s0,-160
    80005f26:	4501                	li	a0,0
    80005f28:	ffffd097          	auipc	ra,0xffffd
    80005f2c:	126080e7          	jalr	294(ra) # 8000304e <argstr>
    80005f30:	04054b63          	bltz	a0,80005f86 <sys_chdir+0x86>
    80005f34:	f6040513          	addi	a0,s0,-160
    80005f38:	ffffe097          	auipc	ra,0xffffe
    80005f3c:	580080e7          	jalr	1408(ra) # 800044b8 <namei>
    80005f40:	84aa                	mv	s1,a0
    80005f42:	c131                	beqz	a0,80005f86 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005f44:	ffffe097          	auipc	ra,0xffffe
    80005f48:	dbe080e7          	jalr	-578(ra) # 80003d02 <ilock>
  if(ip->type != T_DIR){
    80005f4c:	04449703          	lh	a4,68(s1)
    80005f50:	4785                	li	a5,1
    80005f52:	04f71063          	bne	a4,a5,80005f92 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005f56:	8526                	mv	a0,s1
    80005f58:	ffffe097          	auipc	ra,0xffffe
    80005f5c:	e6c080e7          	jalr	-404(ra) # 80003dc4 <iunlock>
  iput(p->cwd);
    80005f60:	17893503          	ld	a0,376(s2)
    80005f64:	ffffe097          	auipc	ra,0xffffe
    80005f68:	f58080e7          	jalr	-168(ra) # 80003ebc <iput>
  end_op();
    80005f6c:	ffffe097          	auipc	ra,0xffffe
    80005f70:	7ec080e7          	jalr	2028(ra) # 80004758 <end_op>
  p->cwd = ip;
    80005f74:	16993c23          	sd	s1,376(s2)
  return 0;
    80005f78:	4501                	li	a0,0
}
    80005f7a:	60ea                	ld	ra,152(sp)
    80005f7c:	644a                	ld	s0,144(sp)
    80005f7e:	64aa                	ld	s1,136(sp)
    80005f80:	690a                	ld	s2,128(sp)
    80005f82:	610d                	addi	sp,sp,160
    80005f84:	8082                	ret
    end_op();
    80005f86:	ffffe097          	auipc	ra,0xffffe
    80005f8a:	7d2080e7          	jalr	2002(ra) # 80004758 <end_op>
    return -1;
    80005f8e:	557d                	li	a0,-1
    80005f90:	b7ed                	j	80005f7a <sys_chdir+0x7a>
    iunlockput(ip);
    80005f92:	8526                	mv	a0,s1
    80005f94:	ffffe097          	auipc	ra,0xffffe
    80005f98:	fd0080e7          	jalr	-48(ra) # 80003f64 <iunlockput>
    end_op();
    80005f9c:	ffffe097          	auipc	ra,0xffffe
    80005fa0:	7bc080e7          	jalr	1980(ra) # 80004758 <end_op>
    return -1;
    80005fa4:	557d                	li	a0,-1
    80005fa6:	bfd1                	j	80005f7a <sys_chdir+0x7a>

0000000080005fa8 <sys_exec>:

uint64
sys_exec(void)
{
    80005fa8:	7145                	addi	sp,sp,-464
    80005faa:	e786                	sd	ra,456(sp)
    80005fac:	e3a2                	sd	s0,448(sp)
    80005fae:	ff26                	sd	s1,440(sp)
    80005fb0:	fb4a                	sd	s2,432(sp)
    80005fb2:	f74e                	sd	s3,424(sp)
    80005fb4:	f352                	sd	s4,416(sp)
    80005fb6:	ef56                	sd	s5,408(sp)
    80005fb8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005fba:	08000613          	li	a2,128
    80005fbe:	f4040593          	addi	a1,s0,-192
    80005fc2:	4501                	li	a0,0
    80005fc4:	ffffd097          	auipc	ra,0xffffd
    80005fc8:	08a080e7          	jalr	138(ra) # 8000304e <argstr>
    return -1;
    80005fcc:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005fce:	0c054a63          	bltz	a0,800060a2 <sys_exec+0xfa>
    80005fd2:	e3840593          	addi	a1,s0,-456
    80005fd6:	4505                	li	a0,1
    80005fd8:	ffffd097          	auipc	ra,0xffffd
    80005fdc:	054080e7          	jalr	84(ra) # 8000302c <argaddr>
    80005fe0:	0c054163          	bltz	a0,800060a2 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005fe4:	10000613          	li	a2,256
    80005fe8:	4581                	li	a1,0
    80005fea:	e4040513          	addi	a0,s0,-448
    80005fee:	ffffb097          	auipc	ra,0xffffb
    80005ff2:	cd0080e7          	jalr	-816(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ff6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005ffa:	89a6                	mv	s3,s1
    80005ffc:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ffe:	02000a13          	li	s4,32
    80006002:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006006:	00391793          	slli	a5,s2,0x3
    8000600a:	e3040593          	addi	a1,s0,-464
    8000600e:	e3843503          	ld	a0,-456(s0)
    80006012:	953e                	add	a0,a0,a5
    80006014:	ffffd097          	auipc	ra,0xffffd
    80006018:	f5c080e7          	jalr	-164(ra) # 80002f70 <fetchaddr>
    8000601c:	02054a63          	bltz	a0,80006050 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006020:	e3043783          	ld	a5,-464(s0)
    80006024:	c3b9                	beqz	a5,8000606a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006026:	ffffb097          	auipc	ra,0xffffb
    8000602a:	aac080e7          	jalr	-1364(ra) # 80000ad2 <kalloc>
    8000602e:	85aa                	mv	a1,a0
    80006030:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006034:	cd11                	beqz	a0,80006050 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006036:	6605                	lui	a2,0x1
    80006038:	e3043503          	ld	a0,-464(s0)
    8000603c:	ffffd097          	auipc	ra,0xffffd
    80006040:	f86080e7          	jalr	-122(ra) # 80002fc2 <fetchstr>
    80006044:	00054663          	bltz	a0,80006050 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006048:	0905                	addi	s2,s2,1
    8000604a:	09a1                	addi	s3,s3,8
    8000604c:	fb491be3          	bne	s2,s4,80006002 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006050:	10048913          	addi	s2,s1,256
    80006054:	6088                	ld	a0,0(s1)
    80006056:	c529                	beqz	a0,800060a0 <sys_exec+0xf8>
    kfree(argv[i]);
    80006058:	ffffb097          	auipc	ra,0xffffb
    8000605c:	97e080e7          	jalr	-1666(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006060:	04a1                	addi	s1,s1,8
    80006062:	ff2499e3          	bne	s1,s2,80006054 <sys_exec+0xac>
  return -1;
    80006066:	597d                	li	s2,-1
    80006068:	a82d                	j	800060a2 <sys_exec+0xfa>
      argv[i] = 0;
    8000606a:	0a8e                	slli	s5,s5,0x3
    8000606c:	fc040793          	addi	a5,s0,-64
    80006070:	9abe                	add	s5,s5,a5
    80006072:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd8e80>
  int ret = exec(path, argv);
    80006076:	e4040593          	addi	a1,s0,-448
    8000607a:	f4040513          	addi	a0,s0,-192
    8000607e:	fffff097          	auipc	ra,0xfffff
    80006082:	178080e7          	jalr	376(ra) # 800051f6 <exec>
    80006086:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006088:	10048993          	addi	s3,s1,256
    8000608c:	6088                	ld	a0,0(s1)
    8000608e:	c911                	beqz	a0,800060a2 <sys_exec+0xfa>
    kfree(argv[i]);
    80006090:	ffffb097          	auipc	ra,0xffffb
    80006094:	946080e7          	jalr	-1722(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006098:	04a1                	addi	s1,s1,8
    8000609a:	ff3499e3          	bne	s1,s3,8000608c <sys_exec+0xe4>
    8000609e:	a011                	j	800060a2 <sys_exec+0xfa>
  return -1;
    800060a0:	597d                	li	s2,-1
}
    800060a2:	854a                	mv	a0,s2
    800060a4:	60be                	ld	ra,456(sp)
    800060a6:	641e                	ld	s0,448(sp)
    800060a8:	74fa                	ld	s1,440(sp)
    800060aa:	795a                	ld	s2,432(sp)
    800060ac:	79ba                	ld	s3,424(sp)
    800060ae:	7a1a                	ld	s4,416(sp)
    800060b0:	6afa                	ld	s5,408(sp)
    800060b2:	6179                	addi	sp,sp,464
    800060b4:	8082                	ret

00000000800060b6 <sys_pipe>:

uint64
sys_pipe(void)
{
    800060b6:	7139                	addi	sp,sp,-64
    800060b8:	fc06                	sd	ra,56(sp)
    800060ba:	f822                	sd	s0,48(sp)
    800060bc:	f426                	sd	s1,40(sp)
    800060be:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800060c0:	ffffc097          	auipc	ra,0xffffc
    800060c4:	8be080e7          	jalr	-1858(ra) # 8000197e <myproc>
    800060c8:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800060ca:	fd840593          	addi	a1,s0,-40
    800060ce:	4501                	li	a0,0
    800060d0:	ffffd097          	auipc	ra,0xffffd
    800060d4:	f5c080e7          	jalr	-164(ra) # 8000302c <argaddr>
    return -1;
    800060d8:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800060da:	0e054063          	bltz	a0,800061ba <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800060de:	fc840593          	addi	a1,s0,-56
    800060e2:	fd040513          	addi	a0,s0,-48
    800060e6:	fffff097          	auipc	ra,0xfffff
    800060ea:	dee080e7          	jalr	-530(ra) # 80004ed4 <pipealloc>
    return -1;
    800060ee:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800060f0:	0c054563          	bltz	a0,800061ba <sys_pipe+0x104>
  fd0 = -1;
    800060f4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800060f8:	fd043503          	ld	a0,-48(s0)
    800060fc:	fffff097          	auipc	ra,0xfffff
    80006100:	50a080e7          	jalr	1290(ra) # 80005606 <fdalloc>
    80006104:	fca42223          	sw	a0,-60(s0)
    80006108:	08054c63          	bltz	a0,800061a0 <sys_pipe+0xea>
    8000610c:	fc843503          	ld	a0,-56(s0)
    80006110:	fffff097          	auipc	ra,0xfffff
    80006114:	4f6080e7          	jalr	1270(ra) # 80005606 <fdalloc>
    80006118:	fca42023          	sw	a0,-64(s0)
    8000611c:	06054863          	bltz	a0,8000618c <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006120:	4691                	li	a3,4
    80006122:	fc440613          	addi	a2,s0,-60
    80006126:	fd843583          	ld	a1,-40(s0)
    8000612a:	7ca8                	ld	a0,120(s1)
    8000612c:	ffffb097          	auipc	ra,0xffffb
    80006130:	512080e7          	jalr	1298(ra) # 8000163e <copyout>
    80006134:	02054063          	bltz	a0,80006154 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006138:	4691                	li	a3,4
    8000613a:	fc040613          	addi	a2,s0,-64
    8000613e:	fd843583          	ld	a1,-40(s0)
    80006142:	0591                	addi	a1,a1,4
    80006144:	7ca8                	ld	a0,120(s1)
    80006146:	ffffb097          	auipc	ra,0xffffb
    8000614a:	4f8080e7          	jalr	1272(ra) # 8000163e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000614e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006150:	06055563          	bgez	a0,800061ba <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006154:	fc442783          	lw	a5,-60(s0)
    80006158:	07f9                	addi	a5,a5,30
    8000615a:	078e                	slli	a5,a5,0x3
    8000615c:	97a6                	add	a5,a5,s1
    8000615e:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006162:	fc042503          	lw	a0,-64(s0)
    80006166:	0579                	addi	a0,a0,30
    80006168:	050e                	slli	a0,a0,0x3
    8000616a:	9526                	add	a0,a0,s1
    8000616c:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80006170:	fd043503          	ld	a0,-48(s0)
    80006174:	fffff097          	auipc	ra,0xfffff
    80006178:	a30080e7          	jalr	-1488(ra) # 80004ba4 <fileclose>
    fileclose(wf);
    8000617c:	fc843503          	ld	a0,-56(s0)
    80006180:	fffff097          	auipc	ra,0xfffff
    80006184:	a24080e7          	jalr	-1500(ra) # 80004ba4 <fileclose>
    return -1;
    80006188:	57fd                	li	a5,-1
    8000618a:	a805                	j	800061ba <sys_pipe+0x104>
    if(fd0 >= 0)
    8000618c:	fc442783          	lw	a5,-60(s0)
    80006190:	0007c863          	bltz	a5,800061a0 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006194:	01e78513          	addi	a0,a5,30
    80006198:	050e                	slli	a0,a0,0x3
    8000619a:	9526                	add	a0,a0,s1
    8000619c:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    800061a0:	fd043503          	ld	a0,-48(s0)
    800061a4:	fffff097          	auipc	ra,0xfffff
    800061a8:	a00080e7          	jalr	-1536(ra) # 80004ba4 <fileclose>
    fileclose(wf);
    800061ac:	fc843503          	ld	a0,-56(s0)
    800061b0:	fffff097          	auipc	ra,0xfffff
    800061b4:	9f4080e7          	jalr	-1548(ra) # 80004ba4 <fileclose>
    return -1;
    800061b8:	57fd                	li	a5,-1
}
    800061ba:	853e                	mv	a0,a5
    800061bc:	70e2                	ld	ra,56(sp)
    800061be:	7442                	ld	s0,48(sp)
    800061c0:	74a2                	ld	s1,40(sp)
    800061c2:	6121                	addi	sp,sp,64
    800061c4:	8082                	ret
	...

00000000800061d0 <kernelvec>:
    800061d0:	7111                	addi	sp,sp,-256
    800061d2:	e006                	sd	ra,0(sp)
    800061d4:	e40a                	sd	sp,8(sp)
    800061d6:	e80e                	sd	gp,16(sp)
    800061d8:	ec12                	sd	tp,24(sp)
    800061da:	f016                	sd	t0,32(sp)
    800061dc:	f41a                	sd	t1,40(sp)
    800061de:	f81e                	sd	t2,48(sp)
    800061e0:	fc22                	sd	s0,56(sp)
    800061e2:	e0a6                	sd	s1,64(sp)
    800061e4:	e4aa                	sd	a0,72(sp)
    800061e6:	e8ae                	sd	a1,80(sp)
    800061e8:	ecb2                	sd	a2,88(sp)
    800061ea:	f0b6                	sd	a3,96(sp)
    800061ec:	f4ba                	sd	a4,104(sp)
    800061ee:	f8be                	sd	a5,112(sp)
    800061f0:	fcc2                	sd	a6,120(sp)
    800061f2:	e146                	sd	a7,128(sp)
    800061f4:	e54a                	sd	s2,136(sp)
    800061f6:	e94e                	sd	s3,144(sp)
    800061f8:	ed52                	sd	s4,152(sp)
    800061fa:	f156                	sd	s5,160(sp)
    800061fc:	f55a                	sd	s6,168(sp)
    800061fe:	f95e                	sd	s7,176(sp)
    80006200:	fd62                	sd	s8,184(sp)
    80006202:	e1e6                	sd	s9,192(sp)
    80006204:	e5ea                	sd	s10,200(sp)
    80006206:	e9ee                	sd	s11,208(sp)
    80006208:	edf2                	sd	t3,216(sp)
    8000620a:	f1f6                	sd	t4,224(sp)
    8000620c:	f5fa                	sd	t5,232(sp)
    8000620e:	f9fe                	sd	t6,240(sp)
    80006210:	c1bfc0ef          	jal	ra,80002e2a <kerneltrap>
    80006214:	6082                	ld	ra,0(sp)
    80006216:	6122                	ld	sp,8(sp)
    80006218:	61c2                	ld	gp,16(sp)
    8000621a:	7282                	ld	t0,32(sp)
    8000621c:	7322                	ld	t1,40(sp)
    8000621e:	73c2                	ld	t2,48(sp)
    80006220:	7462                	ld	s0,56(sp)
    80006222:	6486                	ld	s1,64(sp)
    80006224:	6526                	ld	a0,72(sp)
    80006226:	65c6                	ld	a1,80(sp)
    80006228:	6666                	ld	a2,88(sp)
    8000622a:	7686                	ld	a3,96(sp)
    8000622c:	7726                	ld	a4,104(sp)
    8000622e:	77c6                	ld	a5,112(sp)
    80006230:	7866                	ld	a6,120(sp)
    80006232:	688a                	ld	a7,128(sp)
    80006234:	692a                	ld	s2,136(sp)
    80006236:	69ca                	ld	s3,144(sp)
    80006238:	6a6a                	ld	s4,152(sp)
    8000623a:	7a8a                	ld	s5,160(sp)
    8000623c:	7b2a                	ld	s6,168(sp)
    8000623e:	7bca                	ld	s7,176(sp)
    80006240:	7c6a                	ld	s8,184(sp)
    80006242:	6c8e                	ld	s9,192(sp)
    80006244:	6d2e                	ld	s10,200(sp)
    80006246:	6dce                	ld	s11,208(sp)
    80006248:	6e6e                	ld	t3,216(sp)
    8000624a:	7e8e                	ld	t4,224(sp)
    8000624c:	7f2e                	ld	t5,232(sp)
    8000624e:	7fce                	ld	t6,240(sp)
    80006250:	6111                	addi	sp,sp,256
    80006252:	10200073          	sret
    80006256:	00000013          	nop
    8000625a:	00000013          	nop
    8000625e:	0001                	nop

0000000080006260 <timervec>:
    80006260:	34051573          	csrrw	a0,mscratch,a0
    80006264:	e10c                	sd	a1,0(a0)
    80006266:	e510                	sd	a2,8(a0)
    80006268:	e914                	sd	a3,16(a0)
    8000626a:	6d0c                	ld	a1,24(a0)
    8000626c:	7110                	ld	a2,32(a0)
    8000626e:	6194                	ld	a3,0(a1)
    80006270:	96b2                	add	a3,a3,a2
    80006272:	e194                	sd	a3,0(a1)
    80006274:	4589                	li	a1,2
    80006276:	14459073          	csrw	sip,a1
    8000627a:	6914                	ld	a3,16(a0)
    8000627c:	6510                	ld	a2,8(a0)
    8000627e:	610c                	ld	a1,0(a0)
    80006280:	34051573          	csrrw	a0,mscratch,a0
    80006284:	30200073          	mret
	...

000000008000628a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000628a:	1141                	addi	sp,sp,-16
    8000628c:	e422                	sd	s0,8(sp)
    8000628e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006290:	0c0007b7          	lui	a5,0xc000
    80006294:	4705                	li	a4,1
    80006296:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006298:	c3d8                	sw	a4,4(a5)
}
    8000629a:	6422                	ld	s0,8(sp)
    8000629c:	0141                	addi	sp,sp,16
    8000629e:	8082                	ret

00000000800062a0 <plicinithart>:

void
plicinithart(void)
{
    800062a0:	1141                	addi	sp,sp,-16
    800062a2:	e406                	sd	ra,8(sp)
    800062a4:	e022                	sd	s0,0(sp)
    800062a6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062a8:	ffffb097          	auipc	ra,0xffffb
    800062ac:	6aa080e7          	jalr	1706(ra) # 80001952 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800062b0:	0085171b          	slliw	a4,a0,0x8
    800062b4:	0c0027b7          	lui	a5,0xc002
    800062b8:	97ba                	add	a5,a5,a4
    800062ba:	40200713          	li	a4,1026
    800062be:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800062c2:	00d5151b          	slliw	a0,a0,0xd
    800062c6:	0c2017b7          	lui	a5,0xc201
    800062ca:	953e                	add	a0,a0,a5
    800062cc:	00052023          	sw	zero,0(a0)
}
    800062d0:	60a2                	ld	ra,8(sp)
    800062d2:	6402                	ld	s0,0(sp)
    800062d4:	0141                	addi	sp,sp,16
    800062d6:	8082                	ret

00000000800062d8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800062d8:	1141                	addi	sp,sp,-16
    800062da:	e406                	sd	ra,8(sp)
    800062dc:	e022                	sd	s0,0(sp)
    800062de:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062e0:	ffffb097          	auipc	ra,0xffffb
    800062e4:	672080e7          	jalr	1650(ra) # 80001952 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800062e8:	00d5179b          	slliw	a5,a0,0xd
    800062ec:	0c201537          	lui	a0,0xc201
    800062f0:	953e                	add	a0,a0,a5
  return irq;
}
    800062f2:	4148                	lw	a0,4(a0)
    800062f4:	60a2                	ld	ra,8(sp)
    800062f6:	6402                	ld	s0,0(sp)
    800062f8:	0141                	addi	sp,sp,16
    800062fa:	8082                	ret

00000000800062fc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800062fc:	1101                	addi	sp,sp,-32
    800062fe:	ec06                	sd	ra,24(sp)
    80006300:	e822                	sd	s0,16(sp)
    80006302:	e426                	sd	s1,8(sp)
    80006304:	1000                	addi	s0,sp,32
    80006306:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006308:	ffffb097          	auipc	ra,0xffffb
    8000630c:	64a080e7          	jalr	1610(ra) # 80001952 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006310:	00d5151b          	slliw	a0,a0,0xd
    80006314:	0c2017b7          	lui	a5,0xc201
    80006318:	97aa                	add	a5,a5,a0
    8000631a:	c3c4                	sw	s1,4(a5)
}
    8000631c:	60e2                	ld	ra,24(sp)
    8000631e:	6442                	ld	s0,16(sp)
    80006320:	64a2                	ld	s1,8(sp)
    80006322:	6105                	addi	sp,sp,32
    80006324:	8082                	ret

0000000080006326 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006326:	1141                	addi	sp,sp,-16
    80006328:	e406                	sd	ra,8(sp)
    8000632a:	e022                	sd	s0,0(sp)
    8000632c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000632e:	479d                	li	a5,7
    80006330:	06a7c963          	blt	a5,a0,800063a2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006334:	0001d797          	auipc	a5,0x1d
    80006338:	ccc78793          	addi	a5,a5,-820 # 80023000 <disk>
    8000633c:	00a78733          	add	a4,a5,a0
    80006340:	6789                	lui	a5,0x2
    80006342:	97ba                	add	a5,a5,a4
    80006344:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006348:	e7ad                	bnez	a5,800063b2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000634a:	00451793          	slli	a5,a0,0x4
    8000634e:	0001f717          	auipc	a4,0x1f
    80006352:	cb270713          	addi	a4,a4,-846 # 80025000 <disk+0x2000>
    80006356:	6314                	ld	a3,0(a4)
    80006358:	96be                	add	a3,a3,a5
    8000635a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000635e:	6314                	ld	a3,0(a4)
    80006360:	96be                	add	a3,a3,a5
    80006362:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006366:	6314                	ld	a3,0(a4)
    80006368:	96be                	add	a3,a3,a5
    8000636a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000636e:	6318                	ld	a4,0(a4)
    80006370:	97ba                	add	a5,a5,a4
    80006372:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006376:	0001d797          	auipc	a5,0x1d
    8000637a:	c8a78793          	addi	a5,a5,-886 # 80023000 <disk>
    8000637e:	97aa                	add	a5,a5,a0
    80006380:	6509                	lui	a0,0x2
    80006382:	953e                	add	a0,a0,a5
    80006384:	4785                	li	a5,1
    80006386:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000638a:	0001f517          	auipc	a0,0x1f
    8000638e:	c8e50513          	addi	a0,a0,-882 # 80025018 <disk+0x2018>
    80006392:	ffffc097          	auipc	ra,0xffffc
    80006396:	0fa080e7          	jalr	250(ra) # 8000248c <wakeup>
}
    8000639a:	60a2                	ld	ra,8(sp)
    8000639c:	6402                	ld	s0,0(sp)
    8000639e:	0141                	addi	sp,sp,16
    800063a0:	8082                	ret
    panic("free_desc 1");
    800063a2:	00002517          	auipc	a0,0x2
    800063a6:	6b650513          	addi	a0,a0,1718 # 80008a58 <syscalls+0x330>
    800063aa:	ffffa097          	auipc	ra,0xffffa
    800063ae:	180080e7          	jalr	384(ra) # 8000052a <panic>
    panic("free_desc 2");
    800063b2:	00002517          	auipc	a0,0x2
    800063b6:	6b650513          	addi	a0,a0,1718 # 80008a68 <syscalls+0x340>
    800063ba:	ffffa097          	auipc	ra,0xffffa
    800063be:	170080e7          	jalr	368(ra) # 8000052a <panic>

00000000800063c2 <virtio_disk_init>:
{
    800063c2:	1101                	addi	sp,sp,-32
    800063c4:	ec06                	sd	ra,24(sp)
    800063c6:	e822                	sd	s0,16(sp)
    800063c8:	e426                	sd	s1,8(sp)
    800063ca:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800063cc:	00002597          	auipc	a1,0x2
    800063d0:	6ac58593          	addi	a1,a1,1708 # 80008a78 <syscalls+0x350>
    800063d4:	0001f517          	auipc	a0,0x1f
    800063d8:	d5450513          	addi	a0,a0,-684 # 80025128 <disk+0x2128>
    800063dc:	ffffa097          	auipc	ra,0xffffa
    800063e0:	756080e7          	jalr	1878(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063e4:	100017b7          	lui	a5,0x10001
    800063e8:	4398                	lw	a4,0(a5)
    800063ea:	2701                	sext.w	a4,a4
    800063ec:	747277b7          	lui	a5,0x74727
    800063f0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800063f4:	0ef71163          	bne	a4,a5,800064d6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800063f8:	100017b7          	lui	a5,0x10001
    800063fc:	43dc                	lw	a5,4(a5)
    800063fe:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006400:	4705                	li	a4,1
    80006402:	0ce79a63          	bne	a5,a4,800064d6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006406:	100017b7          	lui	a5,0x10001
    8000640a:	479c                	lw	a5,8(a5)
    8000640c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000640e:	4709                	li	a4,2
    80006410:	0ce79363          	bne	a5,a4,800064d6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006414:	100017b7          	lui	a5,0x10001
    80006418:	47d8                	lw	a4,12(a5)
    8000641a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000641c:	554d47b7          	lui	a5,0x554d4
    80006420:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006424:	0af71963          	bne	a4,a5,800064d6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006428:	100017b7          	lui	a5,0x10001
    8000642c:	4705                	li	a4,1
    8000642e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006430:	470d                	li	a4,3
    80006432:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006434:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006436:	c7ffe737          	lui	a4,0xc7ffe
    8000643a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    8000643e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006440:	2701                	sext.w	a4,a4
    80006442:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006444:	472d                	li	a4,11
    80006446:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006448:	473d                	li	a4,15
    8000644a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000644c:	6705                	lui	a4,0x1
    8000644e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006450:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006454:	5bdc                	lw	a5,52(a5)
    80006456:	2781                	sext.w	a5,a5
  if(max == 0)
    80006458:	c7d9                	beqz	a5,800064e6 <virtio_disk_init+0x124>
  if(max < NUM)
    8000645a:	471d                	li	a4,7
    8000645c:	08f77d63          	bgeu	a4,a5,800064f6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006460:	100014b7          	lui	s1,0x10001
    80006464:	47a1                	li	a5,8
    80006466:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006468:	6609                	lui	a2,0x2
    8000646a:	4581                	li	a1,0
    8000646c:	0001d517          	auipc	a0,0x1d
    80006470:	b9450513          	addi	a0,a0,-1132 # 80023000 <disk>
    80006474:	ffffb097          	auipc	ra,0xffffb
    80006478:	84a080e7          	jalr	-1974(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000647c:	0001d717          	auipc	a4,0x1d
    80006480:	b8470713          	addi	a4,a4,-1148 # 80023000 <disk>
    80006484:	00c75793          	srli	a5,a4,0xc
    80006488:	2781                	sext.w	a5,a5
    8000648a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000648c:	0001f797          	auipc	a5,0x1f
    80006490:	b7478793          	addi	a5,a5,-1164 # 80025000 <disk+0x2000>
    80006494:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006496:	0001d717          	auipc	a4,0x1d
    8000649a:	bea70713          	addi	a4,a4,-1046 # 80023080 <disk+0x80>
    8000649e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    800064a0:	0001e717          	auipc	a4,0x1e
    800064a4:	b6070713          	addi	a4,a4,-1184 # 80024000 <disk+0x1000>
    800064a8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800064aa:	4705                	li	a4,1
    800064ac:	00e78c23          	sb	a4,24(a5)
    800064b0:	00e78ca3          	sb	a4,25(a5)
    800064b4:	00e78d23          	sb	a4,26(a5)
    800064b8:	00e78da3          	sb	a4,27(a5)
    800064bc:	00e78e23          	sb	a4,28(a5)
    800064c0:	00e78ea3          	sb	a4,29(a5)
    800064c4:	00e78f23          	sb	a4,30(a5)
    800064c8:	00e78fa3          	sb	a4,31(a5)
}
    800064cc:	60e2                	ld	ra,24(sp)
    800064ce:	6442                	ld	s0,16(sp)
    800064d0:	64a2                	ld	s1,8(sp)
    800064d2:	6105                	addi	sp,sp,32
    800064d4:	8082                	ret
    panic("could not find virtio disk");
    800064d6:	00002517          	auipc	a0,0x2
    800064da:	5b250513          	addi	a0,a0,1458 # 80008a88 <syscalls+0x360>
    800064de:	ffffa097          	auipc	ra,0xffffa
    800064e2:	04c080e7          	jalr	76(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    800064e6:	00002517          	auipc	a0,0x2
    800064ea:	5c250513          	addi	a0,a0,1474 # 80008aa8 <syscalls+0x380>
    800064ee:	ffffa097          	auipc	ra,0xffffa
    800064f2:	03c080e7          	jalr	60(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    800064f6:	00002517          	auipc	a0,0x2
    800064fa:	5d250513          	addi	a0,a0,1490 # 80008ac8 <syscalls+0x3a0>
    800064fe:	ffffa097          	auipc	ra,0xffffa
    80006502:	02c080e7          	jalr	44(ra) # 8000052a <panic>

0000000080006506 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006506:	7119                	addi	sp,sp,-128
    80006508:	fc86                	sd	ra,120(sp)
    8000650a:	f8a2                	sd	s0,112(sp)
    8000650c:	f4a6                	sd	s1,104(sp)
    8000650e:	f0ca                	sd	s2,96(sp)
    80006510:	ecce                	sd	s3,88(sp)
    80006512:	e8d2                	sd	s4,80(sp)
    80006514:	e4d6                	sd	s5,72(sp)
    80006516:	e0da                	sd	s6,64(sp)
    80006518:	fc5e                	sd	s7,56(sp)
    8000651a:	f862                	sd	s8,48(sp)
    8000651c:	f466                	sd	s9,40(sp)
    8000651e:	f06a                	sd	s10,32(sp)
    80006520:	ec6e                	sd	s11,24(sp)
    80006522:	0100                	addi	s0,sp,128
    80006524:	8aaa                	mv	s5,a0
    80006526:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006528:	00c52c83          	lw	s9,12(a0)
    8000652c:	001c9c9b          	slliw	s9,s9,0x1
    80006530:	1c82                	slli	s9,s9,0x20
    80006532:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006536:	0001f517          	auipc	a0,0x1f
    8000653a:	bf250513          	addi	a0,a0,-1038 # 80025128 <disk+0x2128>
    8000653e:	ffffa097          	auipc	ra,0xffffa
    80006542:	684080e7          	jalr	1668(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006546:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006548:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000654a:	0001dc17          	auipc	s8,0x1d
    8000654e:	ab6c0c13          	addi	s8,s8,-1354 # 80023000 <disk>
    80006552:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006554:	4b0d                	li	s6,3
    80006556:	a0ad                	j	800065c0 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006558:	00fc0733          	add	a4,s8,a5
    8000655c:	975e                	add	a4,a4,s7
    8000655e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006562:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006564:	0207c563          	bltz	a5,8000658e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006568:	2905                	addiw	s2,s2,1
    8000656a:	0611                	addi	a2,a2,4
    8000656c:	19690d63          	beq	s2,s6,80006706 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006570:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006572:	0001f717          	auipc	a4,0x1f
    80006576:	aa670713          	addi	a4,a4,-1370 # 80025018 <disk+0x2018>
    8000657a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000657c:	00074683          	lbu	a3,0(a4)
    80006580:	fee1                	bnez	a3,80006558 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006582:	2785                	addiw	a5,a5,1
    80006584:	0705                	addi	a4,a4,1
    80006586:	fe979be3          	bne	a5,s1,8000657c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000658a:	57fd                	li	a5,-1
    8000658c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000658e:	01205d63          	blez	s2,800065a8 <virtio_disk_rw+0xa2>
    80006592:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006594:	000a2503          	lw	a0,0(s4)
    80006598:	00000097          	auipc	ra,0x0
    8000659c:	d8e080e7          	jalr	-626(ra) # 80006326 <free_desc>
      for(int j = 0; j < i; j++)
    800065a0:	2d85                	addiw	s11,s11,1
    800065a2:	0a11                	addi	s4,s4,4
    800065a4:	ffb918e3          	bne	s2,s11,80006594 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065a8:	0001f597          	auipc	a1,0x1f
    800065ac:	b8058593          	addi	a1,a1,-1152 # 80025128 <disk+0x2128>
    800065b0:	0001f517          	auipc	a0,0x1f
    800065b4:	a6850513          	addi	a0,a0,-1432 # 80025018 <disk+0x2018>
    800065b8:	ffffc097          	auipc	ra,0xffffc
    800065bc:	d48080e7          	jalr	-696(ra) # 80002300 <sleep>
  for(int i = 0; i < 3; i++){
    800065c0:	f8040a13          	addi	s4,s0,-128
{
    800065c4:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800065c6:	894e                	mv	s2,s3
    800065c8:	b765                	j	80006570 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800065ca:	0001f697          	auipc	a3,0x1f
    800065ce:	a366b683          	ld	a3,-1482(a3) # 80025000 <disk+0x2000>
    800065d2:	96ba                	add	a3,a3,a4
    800065d4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800065d8:	0001d817          	auipc	a6,0x1d
    800065dc:	a2880813          	addi	a6,a6,-1496 # 80023000 <disk>
    800065e0:	0001f697          	auipc	a3,0x1f
    800065e4:	a2068693          	addi	a3,a3,-1504 # 80025000 <disk+0x2000>
    800065e8:	6290                	ld	a2,0(a3)
    800065ea:	963a                	add	a2,a2,a4
    800065ec:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800065f0:	0015e593          	ori	a1,a1,1
    800065f4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800065f8:	f8842603          	lw	a2,-120(s0)
    800065fc:	628c                	ld	a1,0(a3)
    800065fe:	972e                	add	a4,a4,a1
    80006600:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006604:	20050593          	addi	a1,a0,512
    80006608:	0592                	slli	a1,a1,0x4
    8000660a:	95c2                	add	a1,a1,a6
    8000660c:	577d                	li	a4,-1
    8000660e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006612:	00461713          	slli	a4,a2,0x4
    80006616:	6290                	ld	a2,0(a3)
    80006618:	963a                	add	a2,a2,a4
    8000661a:	03078793          	addi	a5,a5,48
    8000661e:	97c2                	add	a5,a5,a6
    80006620:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006622:	629c                	ld	a5,0(a3)
    80006624:	97ba                	add	a5,a5,a4
    80006626:	4605                	li	a2,1
    80006628:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000662a:	629c                	ld	a5,0(a3)
    8000662c:	97ba                	add	a5,a5,a4
    8000662e:	4809                	li	a6,2
    80006630:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006634:	629c                	ld	a5,0(a3)
    80006636:	973e                	add	a4,a4,a5
    80006638:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000663c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006640:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006644:	6698                	ld	a4,8(a3)
    80006646:	00275783          	lhu	a5,2(a4)
    8000664a:	8b9d                	andi	a5,a5,7
    8000664c:	0786                	slli	a5,a5,0x1
    8000664e:	97ba                	add	a5,a5,a4
    80006650:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006654:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006658:	6698                	ld	a4,8(a3)
    8000665a:	00275783          	lhu	a5,2(a4)
    8000665e:	2785                	addiw	a5,a5,1
    80006660:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006664:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006668:	100017b7          	lui	a5,0x10001
    8000666c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006670:	004aa783          	lw	a5,4(s5)
    80006674:	02c79163          	bne	a5,a2,80006696 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006678:	0001f917          	auipc	s2,0x1f
    8000667c:	ab090913          	addi	s2,s2,-1360 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80006680:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006682:	85ca                	mv	a1,s2
    80006684:	8556                	mv	a0,s5
    80006686:	ffffc097          	auipc	ra,0xffffc
    8000668a:	c7a080e7          	jalr	-902(ra) # 80002300 <sleep>
  while(b->disk == 1) {
    8000668e:	004aa783          	lw	a5,4(s5)
    80006692:	fe9788e3          	beq	a5,s1,80006682 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006696:	f8042903          	lw	s2,-128(s0)
    8000669a:	20090793          	addi	a5,s2,512
    8000669e:	00479713          	slli	a4,a5,0x4
    800066a2:	0001d797          	auipc	a5,0x1d
    800066a6:	95e78793          	addi	a5,a5,-1698 # 80023000 <disk>
    800066aa:	97ba                	add	a5,a5,a4
    800066ac:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800066b0:	0001f997          	auipc	s3,0x1f
    800066b4:	95098993          	addi	s3,s3,-1712 # 80025000 <disk+0x2000>
    800066b8:	00491713          	slli	a4,s2,0x4
    800066bc:	0009b783          	ld	a5,0(s3)
    800066c0:	97ba                	add	a5,a5,a4
    800066c2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800066c6:	854a                	mv	a0,s2
    800066c8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800066cc:	00000097          	auipc	ra,0x0
    800066d0:	c5a080e7          	jalr	-934(ra) # 80006326 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800066d4:	8885                	andi	s1,s1,1
    800066d6:	f0ed                	bnez	s1,800066b8 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800066d8:	0001f517          	auipc	a0,0x1f
    800066dc:	a5050513          	addi	a0,a0,-1456 # 80025128 <disk+0x2128>
    800066e0:	ffffa097          	auipc	ra,0xffffa
    800066e4:	596080e7          	jalr	1430(ra) # 80000c76 <release>
}
    800066e8:	70e6                	ld	ra,120(sp)
    800066ea:	7446                	ld	s0,112(sp)
    800066ec:	74a6                	ld	s1,104(sp)
    800066ee:	7906                	ld	s2,96(sp)
    800066f0:	69e6                	ld	s3,88(sp)
    800066f2:	6a46                	ld	s4,80(sp)
    800066f4:	6aa6                	ld	s5,72(sp)
    800066f6:	6b06                	ld	s6,64(sp)
    800066f8:	7be2                	ld	s7,56(sp)
    800066fa:	7c42                	ld	s8,48(sp)
    800066fc:	7ca2                	ld	s9,40(sp)
    800066fe:	7d02                	ld	s10,32(sp)
    80006700:	6de2                	ld	s11,24(sp)
    80006702:	6109                	addi	sp,sp,128
    80006704:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006706:	f8042503          	lw	a0,-128(s0)
    8000670a:	20050793          	addi	a5,a0,512
    8000670e:	0792                	slli	a5,a5,0x4
  if(write)
    80006710:	0001d817          	auipc	a6,0x1d
    80006714:	8f080813          	addi	a6,a6,-1808 # 80023000 <disk>
    80006718:	00f80733          	add	a4,a6,a5
    8000671c:	01a036b3          	snez	a3,s10
    80006720:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006724:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006728:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000672c:	7679                	lui	a2,0xffffe
    8000672e:	963e                	add	a2,a2,a5
    80006730:	0001f697          	auipc	a3,0x1f
    80006734:	8d068693          	addi	a3,a3,-1840 # 80025000 <disk+0x2000>
    80006738:	6298                	ld	a4,0(a3)
    8000673a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000673c:	0a878593          	addi	a1,a5,168
    80006740:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006742:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006744:	6298                	ld	a4,0(a3)
    80006746:	9732                	add	a4,a4,a2
    80006748:	45c1                	li	a1,16
    8000674a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000674c:	6298                	ld	a4,0(a3)
    8000674e:	9732                	add	a4,a4,a2
    80006750:	4585                	li	a1,1
    80006752:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006756:	f8442703          	lw	a4,-124(s0)
    8000675a:	628c                	ld	a1,0(a3)
    8000675c:	962e                	add	a2,a2,a1
    8000675e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006762:	0712                	slli	a4,a4,0x4
    80006764:	6290                	ld	a2,0(a3)
    80006766:	963a                	add	a2,a2,a4
    80006768:	058a8593          	addi	a1,s5,88
    8000676c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000676e:	6294                	ld	a3,0(a3)
    80006770:	96ba                	add	a3,a3,a4
    80006772:	40000613          	li	a2,1024
    80006776:	c690                	sw	a2,8(a3)
  if(write)
    80006778:	e40d19e3          	bnez	s10,800065ca <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000677c:	0001f697          	auipc	a3,0x1f
    80006780:	8846b683          	ld	a3,-1916(a3) # 80025000 <disk+0x2000>
    80006784:	96ba                	add	a3,a3,a4
    80006786:	4609                	li	a2,2
    80006788:	00c69623          	sh	a2,12(a3)
    8000678c:	b5b1                	j	800065d8 <virtio_disk_rw+0xd2>

000000008000678e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000678e:	1101                	addi	sp,sp,-32
    80006790:	ec06                	sd	ra,24(sp)
    80006792:	e822                	sd	s0,16(sp)
    80006794:	e426                	sd	s1,8(sp)
    80006796:	e04a                	sd	s2,0(sp)
    80006798:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000679a:	0001f517          	auipc	a0,0x1f
    8000679e:	98e50513          	addi	a0,a0,-1650 # 80025128 <disk+0x2128>
    800067a2:	ffffa097          	auipc	ra,0xffffa
    800067a6:	420080e7          	jalr	1056(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800067aa:	10001737          	lui	a4,0x10001
    800067ae:	533c                	lw	a5,96(a4)
    800067b0:	8b8d                	andi	a5,a5,3
    800067b2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800067b4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800067b8:	0001f797          	auipc	a5,0x1f
    800067bc:	84878793          	addi	a5,a5,-1976 # 80025000 <disk+0x2000>
    800067c0:	6b94                	ld	a3,16(a5)
    800067c2:	0207d703          	lhu	a4,32(a5)
    800067c6:	0026d783          	lhu	a5,2(a3)
    800067ca:	06f70163          	beq	a4,a5,8000682c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800067ce:	0001d917          	auipc	s2,0x1d
    800067d2:	83290913          	addi	s2,s2,-1998 # 80023000 <disk>
    800067d6:	0001f497          	auipc	s1,0x1f
    800067da:	82a48493          	addi	s1,s1,-2006 # 80025000 <disk+0x2000>
    __sync_synchronize();
    800067de:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800067e2:	6898                	ld	a4,16(s1)
    800067e4:	0204d783          	lhu	a5,32(s1)
    800067e8:	8b9d                	andi	a5,a5,7
    800067ea:	078e                	slli	a5,a5,0x3
    800067ec:	97ba                	add	a5,a5,a4
    800067ee:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800067f0:	20078713          	addi	a4,a5,512
    800067f4:	0712                	slli	a4,a4,0x4
    800067f6:	974a                	add	a4,a4,s2
    800067f8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800067fc:	e731                	bnez	a4,80006848 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800067fe:	20078793          	addi	a5,a5,512
    80006802:	0792                	slli	a5,a5,0x4
    80006804:	97ca                	add	a5,a5,s2
    80006806:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006808:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000680c:	ffffc097          	auipc	ra,0xffffc
    80006810:	c80080e7          	jalr	-896(ra) # 8000248c <wakeup>

    disk.used_idx += 1;
    80006814:	0204d783          	lhu	a5,32(s1)
    80006818:	2785                	addiw	a5,a5,1
    8000681a:	17c2                	slli	a5,a5,0x30
    8000681c:	93c1                	srli	a5,a5,0x30
    8000681e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006822:	6898                	ld	a4,16(s1)
    80006824:	00275703          	lhu	a4,2(a4)
    80006828:	faf71be3          	bne	a4,a5,800067de <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000682c:	0001f517          	auipc	a0,0x1f
    80006830:	8fc50513          	addi	a0,a0,-1796 # 80025128 <disk+0x2128>
    80006834:	ffffa097          	auipc	ra,0xffffa
    80006838:	442080e7          	jalr	1090(ra) # 80000c76 <release>
}
    8000683c:	60e2                	ld	ra,24(sp)
    8000683e:	6442                	ld	s0,16(sp)
    80006840:	64a2                	ld	s1,8(sp)
    80006842:	6902                	ld	s2,0(sp)
    80006844:	6105                	addi	sp,sp,32
    80006846:	8082                	ret
      panic("virtio_disk_intr status");
    80006848:	00002517          	auipc	a0,0x2
    8000684c:	2a050513          	addi	a0,a0,672 # 80008ae8 <syscalls+0x3c0>
    80006850:	ffffa097          	auipc	ra,0xffffa
    80006854:	cda080e7          	jalr	-806(ra) # 8000052a <panic>
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
