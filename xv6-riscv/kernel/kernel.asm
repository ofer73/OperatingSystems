
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
    80000068:	19c78793          	addi	a5,a5,412 # 80006200 <timervec>
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
    80000122:	5ac080e7          	jalr	1452(ra) # 800026ca <either_copyin>
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
    800001c6:	0e6080e7          	jalr	230(ra) # 800022a8 <sleep>
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
    80000202:	476080e7          	jalr	1142(ra) # 80002674 <either_copyout>
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
    800002e2:	442080e7          	jalr	1090(ra) # 80002720 <procdump>
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
    80000436:	002080e7          	jalr	2(ra) # 80002434 <wakeup>
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
    80000882:	bb6080e7          	jalr	-1098(ra) # 80002434 <wakeup>
    
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
    8000090e:	99e080e7          	jalr	-1634(ra) # 800022a8 <sleep>
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
    80000eb6:	c6a080e7          	jalr	-918(ra) # 80002b1c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00005097          	auipc	ra,0x5
    80000ebe:	386080e7          	jalr	902(ra) # 80006240 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	13a080e7          	jalr	314(ra) # 80001ffc <scheduler>
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
    80000f2e:	bca080e7          	jalr	-1078(ra) # 80002af4 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	bea080e7          	jalr	-1046(ra) # 80002b1c <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00005097          	auipc	ra,0x5
    80000f3e:	2f0080e7          	jalr	752(ra) # 8000622a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00005097          	auipc	ra,0x5
    80000f46:	2fe080e7          	jalr	766(ra) # 80006240 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	4ce080e7          	jalr	1230(ra) # 80003418 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	b60080e7          	jalr	-1184(ra) # 80003ab2 <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	b0e080e7          	jalr	-1266(ra) # 80004a68 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	400080e7          	jalr	1024(ra) # 80006362 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	d1c080e7          	jalr	-740(ra) # 80001c86 <userinit>
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

00000000800019b6 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019b6:	1141                	addi	sp,sp,-16
    800019b8:	e406                	sd	ra,8(sp)
    800019ba:	e022                	sd	s0,0(sp)
    800019bc:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019be:	00000097          	auipc	ra,0x0
    800019c2:	fc0080e7          	jalr	-64(ra) # 8000197e <myproc>
    800019c6:	fffff097          	auipc	ra,0xfffff
    800019ca:	2b0080e7          	jalr	688(ra) # 80000c76 <release>

  if (first) {
    800019ce:	00007797          	auipc	a5,0x7
    800019d2:	0527a783          	lw	a5,82(a5) # 80008a20 <first.1>
    800019d6:	eb89                	bnez	a5,800019e8 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019d8:	00001097          	auipc	ra,0x1
    800019dc:	15c080e7          	jalr	348(ra) # 80002b34 <usertrapret>
}
    800019e0:	60a2                	ld	ra,8(sp)
    800019e2:	6402                	ld	s0,0(sp)
    800019e4:	0141                	addi	sp,sp,16
    800019e6:	8082                	ret
    first = 0;
    800019e8:	00007797          	auipc	a5,0x7
    800019ec:	0207ac23          	sw	zero,56(a5) # 80008a20 <first.1>
    fsinit(ROOTDEV);
    800019f0:	4505                	li	a0,1
    800019f2:	00002097          	auipc	ra,0x2
    800019f6:	040080e7          	jalr	64(ra) # 80003a32 <fsinit>
    800019fa:	bff9                	j	800019d8 <forkret+0x22>

00000000800019fc <allocpid>:
allocpid() {
    800019fc:	1101                	addi	sp,sp,-32
    800019fe:	ec06                	sd	ra,24(sp)
    80001a00:	e822                	sd	s0,16(sp)
    80001a02:	e426                	sd	s1,8(sp)
    80001a04:	e04a                	sd	s2,0(sp)
    80001a06:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a08:	00010917          	auipc	s2,0x10
    80001a0c:	89890913          	addi	s2,s2,-1896 # 800112a0 <pid_lock>
    80001a10:	854a                	mv	a0,s2
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	1b0080e7          	jalr	432(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001a1a:	00007797          	auipc	a5,0x7
    80001a1e:	00e78793          	addi	a5,a5,14 # 80008a28 <nextpid>
    80001a22:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a24:	0014871b          	addiw	a4,s1,1
    80001a28:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a2a:	854a                	mv	a0,s2
    80001a2c:	fffff097          	auipc	ra,0xfffff
    80001a30:	24a080e7          	jalr	586(ra) # 80000c76 <release>
}
    80001a34:	8526                	mv	a0,s1
    80001a36:	60e2                	ld	ra,24(sp)
    80001a38:	6442                	ld	s0,16(sp)
    80001a3a:	64a2                	ld	s1,8(sp)
    80001a3c:	6902                	ld	s2,0(sp)
    80001a3e:	6105                	addi	sp,sp,32
    80001a40:	8082                	ret

0000000080001a42 <proc_pagetable>:
{
    80001a42:	1101                	addi	sp,sp,-32
    80001a44:	ec06                	sd	ra,24(sp)
    80001a46:	e822                	sd	s0,16(sp)
    80001a48:	e426                	sd	s1,8(sp)
    80001a4a:	e04a                	sd	s2,0(sp)
    80001a4c:	1000                	addi	s0,sp,32
    80001a4e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a50:	00000097          	auipc	ra,0x0
    80001a54:	8b6080e7          	jalr	-1866(ra) # 80001306 <uvmcreate>
    80001a58:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a5a:	c121                	beqz	a0,80001a9a <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a5c:	4729                	li	a4,10
    80001a5e:	00005697          	auipc	a3,0x5
    80001a62:	5a268693          	addi	a3,a3,1442 # 80007000 <_trampoline>
    80001a66:	6605                	lui	a2,0x1
    80001a68:	040005b7          	lui	a1,0x4000
    80001a6c:	15fd                	addi	a1,a1,-1
    80001a6e:	05b2                	slli	a1,a1,0xc
    80001a70:	fffff097          	auipc	ra,0xfffff
    80001a74:	61e080e7          	jalr	1566(ra) # 8000108e <mappages>
    80001a78:	02054863          	bltz	a0,80001aa8 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a7c:	4719                	li	a4,6
    80001a7e:	08093683          	ld	a3,128(s2)
    80001a82:	6605                	lui	a2,0x1
    80001a84:	020005b7          	lui	a1,0x2000
    80001a88:	15fd                	addi	a1,a1,-1
    80001a8a:	05b6                	slli	a1,a1,0xd
    80001a8c:	8526                	mv	a0,s1
    80001a8e:	fffff097          	auipc	ra,0xfffff
    80001a92:	600080e7          	jalr	1536(ra) # 8000108e <mappages>
    80001a96:	02054163          	bltz	a0,80001ab8 <proc_pagetable+0x76>
}
    80001a9a:	8526                	mv	a0,s1
    80001a9c:	60e2                	ld	ra,24(sp)
    80001a9e:	6442                	ld	s0,16(sp)
    80001aa0:	64a2                	ld	s1,8(sp)
    80001aa2:	6902                	ld	s2,0(sp)
    80001aa4:	6105                	addi	sp,sp,32
    80001aa6:	8082                	ret
    uvmfree(pagetable, 0);
    80001aa8:	4581                	li	a1,0
    80001aaa:	8526                	mv	a0,s1
    80001aac:	00000097          	auipc	ra,0x0
    80001ab0:	a56080e7          	jalr	-1450(ra) # 80001502 <uvmfree>
    return 0;
    80001ab4:	4481                	li	s1,0
    80001ab6:	b7d5                	j	80001a9a <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ab8:	4681                	li	a3,0
    80001aba:	4605                	li	a2,1
    80001abc:	040005b7          	lui	a1,0x4000
    80001ac0:	15fd                	addi	a1,a1,-1
    80001ac2:	05b2                	slli	a1,a1,0xc
    80001ac4:	8526                	mv	a0,s1
    80001ac6:	fffff097          	auipc	ra,0xfffff
    80001aca:	77c080e7          	jalr	1916(ra) # 80001242 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ace:	4581                	li	a1,0
    80001ad0:	8526                	mv	a0,s1
    80001ad2:	00000097          	auipc	ra,0x0
    80001ad6:	a30080e7          	jalr	-1488(ra) # 80001502 <uvmfree>
    return 0;
    80001ada:	4481                	li	s1,0
    80001adc:	bf7d                	j	80001a9a <proc_pagetable+0x58>

0000000080001ade <proc_freepagetable>:
{
    80001ade:	1101                	addi	sp,sp,-32
    80001ae0:	ec06                	sd	ra,24(sp)
    80001ae2:	e822                	sd	s0,16(sp)
    80001ae4:	e426                	sd	s1,8(sp)
    80001ae6:	e04a                	sd	s2,0(sp)
    80001ae8:	1000                	addi	s0,sp,32
    80001aea:	84aa                	mv	s1,a0
    80001aec:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aee:	4681                	li	a3,0
    80001af0:	4605                	li	a2,1
    80001af2:	040005b7          	lui	a1,0x4000
    80001af6:	15fd                	addi	a1,a1,-1
    80001af8:	05b2                	slli	a1,a1,0xc
    80001afa:	fffff097          	auipc	ra,0xfffff
    80001afe:	748080e7          	jalr	1864(ra) # 80001242 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b02:	4681                	li	a3,0
    80001b04:	4605                	li	a2,1
    80001b06:	020005b7          	lui	a1,0x2000
    80001b0a:	15fd                	addi	a1,a1,-1
    80001b0c:	05b6                	slli	a1,a1,0xd
    80001b0e:	8526                	mv	a0,s1
    80001b10:	fffff097          	auipc	ra,0xfffff
    80001b14:	732080e7          	jalr	1842(ra) # 80001242 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b18:	85ca                	mv	a1,s2
    80001b1a:	8526                	mv	a0,s1
    80001b1c:	00000097          	auipc	ra,0x0
    80001b20:	9e6080e7          	jalr	-1562(ra) # 80001502 <uvmfree>
}
    80001b24:	60e2                	ld	ra,24(sp)
    80001b26:	6442                	ld	s0,16(sp)
    80001b28:	64a2                	ld	s1,8(sp)
    80001b2a:	6902                	ld	s2,0(sp)
    80001b2c:	6105                	addi	sp,sp,32
    80001b2e:	8082                	ret

0000000080001b30 <freeproc>:
{
    80001b30:	1101                	addi	sp,sp,-32
    80001b32:	ec06                	sd	ra,24(sp)
    80001b34:	e822                	sd	s0,16(sp)
    80001b36:	e426                	sd	s1,8(sp)
    80001b38:	1000                	addi	s0,sp,32
    80001b3a:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b3c:	6148                	ld	a0,128(a0)
    80001b3e:	c509                	beqz	a0,80001b48 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b40:	fffff097          	auipc	ra,0xfffff
    80001b44:	e96080e7          	jalr	-362(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001b48:	0804b023          	sd	zero,128(s1)
  if(p->pagetable)
    80001b4c:	7ca8                	ld	a0,120(s1)
    80001b4e:	c511                	beqz	a0,80001b5a <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b50:	78ac                	ld	a1,112(s1)
    80001b52:	00000097          	auipc	ra,0x0
    80001b56:	f8c080e7          	jalr	-116(ra) # 80001ade <proc_freepagetable>
  p->pagetable = 0;
    80001b5a:	0604bc23          	sd	zero,120(s1)
  p->sz = 0;
    80001b5e:	0604b823          	sd	zero,112(s1)
  p->pid = 0;
    80001b62:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b66:	0604b023          	sd	zero,96(s1)
  p->name[0] = 0;
    80001b6a:	18048023          	sb	zero,384(s1)
  p->chan = 0;
    80001b6e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b72:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b76:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b7a:	0004ac23          	sw	zero,24(s1)
}
    80001b7e:	60e2                	ld	ra,24(sp)
    80001b80:	6442                	ld	s0,16(sp)
    80001b82:	64a2                	ld	s1,8(sp)
    80001b84:	6105                	addi	sp,sp,32
    80001b86:	8082                	ret

0000000080001b88 <allocproc>:
{
    80001b88:	1101                	addi	sp,sp,-32
    80001b8a:	ec06                	sd	ra,24(sp)
    80001b8c:	e822                	sd	s0,16(sp)
    80001b8e:	e426                	sd	s1,8(sp)
    80001b90:	e04a                	sd	s2,0(sp)
    80001b92:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b94:	00010497          	auipc	s1,0x10
    80001b98:	b3c48493          	addi	s1,s1,-1220 # 800116d0 <proc>
    80001b9c:	00016917          	auipc	s2,0x16
    80001ba0:	f3490913          	addi	s2,s2,-204 # 80017ad0 <tickslock>
    acquire(&p->lock);
    80001ba4:	8526                	mv	a0,s1
    80001ba6:	fffff097          	auipc	ra,0xfffff
    80001baa:	01c080e7          	jalr	28(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    80001bae:	4c9c                	lw	a5,24(s1)
    80001bb0:	cf81                	beqz	a5,80001bc8 <allocproc+0x40>
      release(&p->lock);
    80001bb2:	8526                	mv	a0,s1
    80001bb4:	fffff097          	auipc	ra,0xfffff
    80001bb8:	0c2080e7          	jalr	194(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bbc:	19048493          	addi	s1,s1,400
    80001bc0:	ff2492e3          	bne	s1,s2,80001ba4 <allocproc+0x1c>
  return 0;
    80001bc4:	4481                	li	s1,0
    80001bc6:	a049                	j	80001c48 <allocproc+0xc0>
  p->pid = allocpid();
    80001bc8:	00000097          	auipc	ra,0x0
    80001bcc:	e34080e7          	jalr	-460(ra) # 800019fc <allocpid>
    80001bd0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bd2:	4785                	li	a5,1
    80001bd4:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001bd6:	fffff097          	auipc	ra,0xfffff
    80001bda:	efc080e7          	jalr	-260(ra) # 80000ad2 <kalloc>
    80001bde:	892a                	mv	s2,a0
    80001be0:	e0c8                	sd	a0,128(s1)
    80001be2:	c935                	beqz	a0,80001c56 <allocproc+0xce>
  p->pagetable = proc_pagetable(p);
    80001be4:	8526                	mv	a0,s1
    80001be6:	00000097          	auipc	ra,0x0
    80001bea:	e5c080e7          	jalr	-420(ra) # 80001a42 <proc_pagetable>
    80001bee:	892a                	mv	s2,a0
    80001bf0:	fca8                	sd	a0,120(s1)
  if(p->pagetable == 0){
    80001bf2:	cd35                	beqz	a0,80001c6e <allocproc+0xe6>
  memset(&p->context, 0, sizeof(p->context));
    80001bf4:	07000613          	li	a2,112
    80001bf8:	4581                	li	a1,0
    80001bfa:	08848513          	addi	a0,s1,136
    80001bfe:	fffff097          	auipc	ra,0xfffff
    80001c02:	0c0080e7          	jalr	192(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80001c06:	00000797          	auipc	a5,0x0
    80001c0a:	db078793          	addi	a5,a5,-592 # 800019b6 <forkret>
    80001c0e:	e4dc                	sd	a5,136(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c10:	74bc                	ld	a5,104(s1)
    80001c12:	6705                	lui	a4,0x1
    80001c14:	97ba                	add	a5,a5,a4
    80001c16:	e8dc                	sd	a5,144(s1)
  p->ctime = ticks;
    80001c18:	00007797          	auipc	a5,0x7
    80001c1c:	4187a783          	lw	a5,1048(a5) # 80009030 <ticks>
    80001c20:	dc9c                	sw	a5,56(s1)
  p->ttime = -1;
    80001c22:	57fd                	li	a5,-1
    80001c24:	dcdc                	sw	a5,60(s1)
  p->stime = 0;
    80001c26:	0404a023          	sw	zero,64(s1)
  p->retime = 0;
    80001c2a:	0404a223          	sw	zero,68(s1)
  p->rutime = 0;
    80001c2e:	0404a423          	sw	zero,72(s1)
  p->average_bursttime = QUANTUM * 100;
    80001c32:	1f400793          	li	a5,500
    80001c36:	c4fc                	sw	a5,76(s1)
  p->current_runtime = 0;
    80001c38:	0404aa23          	sw	zero,84(s1)
  p->decay_factor = 5;
    80001c3c:	4795                	li	a5,5
    80001c3e:	c8bc                	sw	a5,80(s1)
  p->runnable_since = 0;
    80001c40:	0404ac23          	sw	zero,88(s1)
  p->chosen = 0;
    80001c44:	0404ae23          	sw	zero,92(s1)
}
    80001c48:	8526                	mv	a0,s1
    80001c4a:	60e2                	ld	ra,24(sp)
    80001c4c:	6442                	ld	s0,16(sp)
    80001c4e:	64a2                	ld	s1,8(sp)
    80001c50:	6902                	ld	s2,0(sp)
    80001c52:	6105                	addi	sp,sp,32
    80001c54:	8082                	ret
    freeproc(p);
    80001c56:	8526                	mv	a0,s1
    80001c58:	00000097          	auipc	ra,0x0
    80001c5c:	ed8080e7          	jalr	-296(ra) # 80001b30 <freeproc>
    release(&p->lock);
    80001c60:	8526                	mv	a0,s1
    80001c62:	fffff097          	auipc	ra,0xfffff
    80001c66:	014080e7          	jalr	20(ra) # 80000c76 <release>
    return 0;
    80001c6a:	84ca                	mv	s1,s2
    80001c6c:	bff1                	j	80001c48 <allocproc+0xc0>
    freeproc(p);
    80001c6e:	8526                	mv	a0,s1
    80001c70:	00000097          	auipc	ra,0x0
    80001c74:	ec0080e7          	jalr	-320(ra) # 80001b30 <freeproc>
    release(&p->lock);
    80001c78:	8526                	mv	a0,s1
    80001c7a:	fffff097          	auipc	ra,0xfffff
    80001c7e:	ffc080e7          	jalr	-4(ra) # 80000c76 <release>
    return 0;
    80001c82:	84ca                	mv	s1,s2
    80001c84:	b7d1                	j	80001c48 <allocproc+0xc0>

0000000080001c86 <userinit>:
{
    80001c86:	1101                	addi	sp,sp,-32
    80001c88:	ec06                	sd	ra,24(sp)
    80001c8a:	e822                	sd	s0,16(sp)
    80001c8c:	e426                	sd	s1,8(sp)
    80001c8e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c90:	00000097          	auipc	ra,0x0
    80001c94:	ef8080e7          	jalr	-264(ra) # 80001b88 <allocproc>
    80001c98:	84aa                	mv	s1,a0
  initproc = p;
    80001c9a:	00007797          	auipc	a5,0x7
    80001c9e:	38a7b723          	sd	a0,910(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001ca2:	03400613          	li	a2,52
    80001ca6:	00007597          	auipc	a1,0x7
    80001caa:	d8a58593          	addi	a1,a1,-630 # 80008a30 <initcode>
    80001cae:	7d28                	ld	a0,120(a0)
    80001cb0:	fffff097          	auipc	ra,0xfffff
    80001cb4:	684080e7          	jalr	1668(ra) # 80001334 <uvminit>
  p->sz = PGSIZE;
    80001cb8:	6785                	lui	a5,0x1
    80001cba:	f8bc                	sd	a5,112(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cbc:	60d8                	ld	a4,128(s1)
    80001cbe:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cc2:	60d8                	ld	a4,128(s1)
    80001cc4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cc6:	4641                	li	a2,16
    80001cc8:	00006597          	auipc	a1,0x6
    80001ccc:	52058593          	addi	a1,a1,1312 # 800081e8 <digits+0x1a8>
    80001cd0:	18048513          	addi	a0,s1,384
    80001cd4:	fffff097          	auipc	ra,0xfffff
    80001cd8:	13c080e7          	jalr	316(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80001cdc:	00006517          	auipc	a0,0x6
    80001ce0:	51c50513          	addi	a0,a0,1308 # 800081f8 <digits+0x1b8>
    80001ce4:	00002097          	auipc	ra,0x2
    80001ce8:	77c080e7          	jalr	1916(ra) # 80004460 <namei>
    80001cec:	16a4bc23          	sd	a0,376(s1)
  p->state = RUNNABLE;
    80001cf0:	478d                	li	a5,3
    80001cf2:	cc9c                	sw	a5,24(s1)
  p->runnable_since = ticks;
    80001cf4:	00007797          	auipc	a5,0x7
    80001cf8:	33c7a783          	lw	a5,828(a5) # 80009030 <ticks>
    80001cfc:	ccbc                	sw	a5,88(s1)
  release(&p->lock);
    80001cfe:	8526                	mv	a0,s1
    80001d00:	fffff097          	auipc	ra,0xfffff
    80001d04:	f76080e7          	jalr	-138(ra) # 80000c76 <release>
}
    80001d08:	60e2                	ld	ra,24(sp)
    80001d0a:	6442                	ld	s0,16(sp)
    80001d0c:	64a2                	ld	s1,8(sp)
    80001d0e:	6105                	addi	sp,sp,32
    80001d10:	8082                	ret

0000000080001d12 <growproc>:
{
    80001d12:	1101                	addi	sp,sp,-32
    80001d14:	ec06                	sd	ra,24(sp)
    80001d16:	e822                	sd	s0,16(sp)
    80001d18:	e426                	sd	s1,8(sp)
    80001d1a:	e04a                	sd	s2,0(sp)
    80001d1c:	1000                	addi	s0,sp,32
    80001d1e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d20:	00000097          	auipc	ra,0x0
    80001d24:	c5e080e7          	jalr	-930(ra) # 8000197e <myproc>
    80001d28:	892a                	mv	s2,a0
  sz = p->sz;
    80001d2a:	792c                	ld	a1,112(a0)
    80001d2c:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d30:	00904f63          	bgtz	s1,80001d4e <growproc+0x3c>
  } else if(n < 0){
    80001d34:	0204cc63          	bltz	s1,80001d6c <growproc+0x5a>
  p->sz = sz;
    80001d38:	1602                	slli	a2,a2,0x20
    80001d3a:	9201                	srli	a2,a2,0x20
    80001d3c:	06c93823          	sd	a2,112(s2)
  return 0;
    80001d40:	4501                	li	a0,0
}
    80001d42:	60e2                	ld	ra,24(sp)
    80001d44:	6442                	ld	s0,16(sp)
    80001d46:	64a2                	ld	s1,8(sp)
    80001d48:	6902                	ld	s2,0(sp)
    80001d4a:	6105                	addi	sp,sp,32
    80001d4c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d4e:	9e25                	addw	a2,a2,s1
    80001d50:	1602                	slli	a2,a2,0x20
    80001d52:	9201                	srli	a2,a2,0x20
    80001d54:	1582                	slli	a1,a1,0x20
    80001d56:	9181                	srli	a1,a1,0x20
    80001d58:	7d28                	ld	a0,120(a0)
    80001d5a:	fffff097          	auipc	ra,0xfffff
    80001d5e:	694080e7          	jalr	1684(ra) # 800013ee <uvmalloc>
    80001d62:	0005061b          	sext.w	a2,a0
    80001d66:	fa69                	bnez	a2,80001d38 <growproc+0x26>
      return -1;
    80001d68:	557d                	li	a0,-1
    80001d6a:	bfe1                	j	80001d42 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d6c:	9e25                	addw	a2,a2,s1
    80001d6e:	1602                	slli	a2,a2,0x20
    80001d70:	9201                	srli	a2,a2,0x20
    80001d72:	1582                	slli	a1,a1,0x20
    80001d74:	9181                	srli	a1,a1,0x20
    80001d76:	7d28                	ld	a0,120(a0)
    80001d78:	fffff097          	auipc	ra,0xfffff
    80001d7c:	62e080e7          	jalr	1582(ra) # 800013a6 <uvmdealloc>
    80001d80:	0005061b          	sext.w	a2,a0
    80001d84:	bf55                	j	80001d38 <growproc+0x26>

0000000080001d86 <perfi>:
perfi(struct proc *proc, struct perf *perf){
    80001d86:	1141                	addi	sp,sp,-16
    80001d88:	e422                	sd	s0,8(sp)
    80001d8a:	0800                	addi	s0,sp,16
  perf->ctime = proc->ctime;
    80001d8c:	5d1c                	lw	a5,56(a0)
    80001d8e:	c19c                	sw	a5,0(a1)
  perf->ttime = proc->ttime;
    80001d90:	5d5c                	lw	a5,60(a0)
    80001d92:	c1dc                	sw	a5,4(a1)
  perf->stime = proc->stime;
    80001d94:	413c                	lw	a5,64(a0)
    80001d96:	c59c                	sw	a5,8(a1)
  perf->retime = proc->retime;
    80001d98:	417c                	lw	a5,68(a0)
    80001d9a:	c5dc                	sw	a5,12(a1)
  perf->rutime = proc->rutime;
    80001d9c:	453c                	lw	a5,72(a0)
    80001d9e:	c99c                	sw	a5,16(a1)
  perf->average_bursttime = proc->average_bursttime;
    80001da0:	457c                	lw	a5,76(a0)
    80001da2:	c9dc                	sw	a5,20(a1)
}
    80001da4:	6422                	ld	s0,8(sp)
    80001da6:	0141                	addi	sp,sp,16
    80001da8:	8082                	ret

0000000080001daa <fork>:
{
    80001daa:	7139                	addi	sp,sp,-64
    80001dac:	fc06                	sd	ra,56(sp)
    80001dae:	f822                	sd	s0,48(sp)
    80001db0:	f426                	sd	s1,40(sp)
    80001db2:	f04a                	sd	s2,32(sp)
    80001db4:	ec4e                	sd	s3,24(sp)
    80001db6:	e852                	sd	s4,16(sp)
    80001db8:	e456                	sd	s5,8(sp)
    80001dba:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dbc:	00000097          	auipc	ra,0x0
    80001dc0:	bc2080e7          	jalr	-1086(ra) # 8000197e <myproc>
    80001dc4:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001dc6:	00000097          	auipc	ra,0x0
    80001dca:	dc2080e7          	jalr	-574(ra) # 80001b88 <allocproc>
    80001dce:	12050a63          	beqz	a0,80001f02 <fork+0x158>
    80001dd2:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dd4:	070ab603          	ld	a2,112(s5)
    80001dd8:	7d2c                	ld	a1,120(a0)
    80001dda:	078ab503          	ld	a0,120(s5)
    80001dde:	fffff097          	auipc	ra,0xfffff
    80001de2:	75c080e7          	jalr	1884(ra) # 8000153a <uvmcopy>
    80001de6:	04054863          	bltz	a0,80001e36 <fork+0x8c>
  np->sz = p->sz;
    80001dea:	070ab783          	ld	a5,112(s5)
    80001dee:	06f9b823          	sd	a5,112(s3)
  *(np->trapframe) = *(p->trapframe);
    80001df2:	080ab683          	ld	a3,128(s5)
    80001df6:	87b6                	mv	a5,a3
    80001df8:	0809b703          	ld	a4,128(s3)
    80001dfc:	12068693          	addi	a3,a3,288
    80001e00:	0007b803          	ld	a6,0(a5)
    80001e04:	6788                	ld	a0,8(a5)
    80001e06:	6b8c                	ld	a1,16(a5)
    80001e08:	6f90                	ld	a2,24(a5)
    80001e0a:	01073023          	sd	a6,0(a4)
    80001e0e:	e708                	sd	a0,8(a4)
    80001e10:	eb0c                	sd	a1,16(a4)
    80001e12:	ef10                	sd	a2,24(a4)
    80001e14:	02078793          	addi	a5,a5,32
    80001e18:	02070713          	addi	a4,a4,32
    80001e1c:	fed792e3          	bne	a5,a3,80001e00 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e20:	0809b783          	ld	a5,128(s3)
    80001e24:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e28:	0f8a8493          	addi	s1,s5,248
    80001e2c:	0f898913          	addi	s2,s3,248
    80001e30:	178a8a13          	addi	s4,s5,376
    80001e34:	a00d                	j	80001e56 <fork+0xac>
    freeproc(np);
    80001e36:	854e                	mv	a0,s3
    80001e38:	00000097          	auipc	ra,0x0
    80001e3c:	cf8080e7          	jalr	-776(ra) # 80001b30 <freeproc>
    release(&np->lock);
    80001e40:	854e                	mv	a0,s3
    80001e42:	fffff097          	auipc	ra,0xfffff
    80001e46:	e34080e7          	jalr	-460(ra) # 80000c76 <release>
    return -1;
    80001e4a:	597d                	li	s2,-1
    80001e4c:	a04d                	j	80001eee <fork+0x144>
  for(i = 0; i < NOFILE; i++)
    80001e4e:	04a1                	addi	s1,s1,8
    80001e50:	0921                	addi	s2,s2,8
    80001e52:	01448b63          	beq	s1,s4,80001e68 <fork+0xbe>
    if(p->ofile[i])
    80001e56:	6088                	ld	a0,0(s1)
    80001e58:	d97d                	beqz	a0,80001e4e <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e5a:	00003097          	auipc	ra,0x3
    80001e5e:	ca0080e7          	jalr	-864(ra) # 80004afa <filedup>
    80001e62:	00a93023          	sd	a0,0(s2)
    80001e66:	b7e5                	j	80001e4e <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e68:	178ab503          	ld	a0,376(s5)
    80001e6c:	00002097          	auipc	ra,0x2
    80001e70:	e00080e7          	jalr	-512(ra) # 80003c6c <idup>
    80001e74:	16a9bc23          	sd	a0,376(s3)
  np->tracemask = p->tracemask;
    80001e78:	034aa783          	lw	a5,52(s5)
    80001e7c:	02f9aa23          	sw	a5,52(s3)
  np->decay_factor = p->decay_factor;
    80001e80:	050aa783          	lw	a5,80(s5)
    80001e84:	04f9a823          	sw	a5,80(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e88:	4641                	li	a2,16
    80001e8a:	180a8593          	addi	a1,s5,384
    80001e8e:	18098513          	addi	a0,s3,384
    80001e92:	fffff097          	auipc	ra,0xfffff
    80001e96:	f7e080e7          	jalr	-130(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80001e9a:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001e9e:	854e                	mv	a0,s3
    80001ea0:	fffff097          	auipc	ra,0xfffff
    80001ea4:	dd6080e7          	jalr	-554(ra) # 80000c76 <release>
  acquire(&wait_lock);
    80001ea8:	0000f497          	auipc	s1,0xf
    80001eac:	41048493          	addi	s1,s1,1040 # 800112b8 <wait_lock>
    80001eb0:	8526                	mv	a0,s1
    80001eb2:	fffff097          	auipc	ra,0xfffff
    80001eb6:	d10080e7          	jalr	-752(ra) # 80000bc2 <acquire>
  np->parent = p;
    80001eba:	0759b023          	sd	s5,96(s3)
  release(&wait_lock);
    80001ebe:	8526                	mv	a0,s1
    80001ec0:	fffff097          	auipc	ra,0xfffff
    80001ec4:	db6080e7          	jalr	-586(ra) # 80000c76 <release>
  acquire(&np->lock);
    80001ec8:	854e                	mv	a0,s3
    80001eca:	fffff097          	auipc	ra,0xfffff
    80001ece:	cf8080e7          	jalr	-776(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80001ed2:	478d                	li	a5,3
    80001ed4:	00f9ac23          	sw	a5,24(s3)
  np->runnable_since = ticks;
    80001ed8:	00007797          	auipc	a5,0x7
    80001edc:	1587a783          	lw	a5,344(a5) # 80009030 <ticks>
    80001ee0:	04f9ac23          	sw	a5,88(s3)
  release(&np->lock);
    80001ee4:	854e                	mv	a0,s3
    80001ee6:	fffff097          	auipc	ra,0xfffff
    80001eea:	d90080e7          	jalr	-624(ra) # 80000c76 <release>
}
    80001eee:	854a                	mv	a0,s2
    80001ef0:	70e2                	ld	ra,56(sp)
    80001ef2:	7442                	ld	s0,48(sp)
    80001ef4:	74a2                	ld	s1,40(sp)
    80001ef6:	7902                	ld	s2,32(sp)
    80001ef8:	69e2                	ld	s3,24(sp)
    80001efa:	6a42                	ld	s4,16(sp)
    80001efc:	6aa2                	ld	s5,8(sp)
    80001efe:	6121                	addi	sp,sp,64
    80001f00:	8082                	ret
    return -1;
    80001f02:	597d                	li	s2,-1
    80001f04:	b7ed                	j	80001eee <fork+0x144>

0000000080001f06 <FCFS_compare>:
FCFS_compare(struct proc *p1,struct proc *p2){
    80001f06:	1141                	addi	sp,sp,-16
    80001f08:	e422                	sd	s0,8(sp)
    80001f0a:	0800                	addi	s0,sp,16
  return p1->runnable_since - p2->runnable_since;
    80001f0c:	4d28                	lw	a0,88(a0)
    80001f0e:	4dbc                	lw	a5,88(a1)
}
    80001f10:	9d1d                	subw	a0,a0,a5
    80001f12:	6422                	ld	s0,8(sp)
    80001f14:	0141                	addi	sp,sp,16
    80001f16:	8082                	ret

0000000080001f18 <SRT_compare>:
SRT_compare(struct proc *p1,struct proc *p2){
    80001f18:	1141                	addi	sp,sp,-16
    80001f1a:	e422                	sd	s0,8(sp)
    80001f1c:	0800                	addi	s0,sp,16
  return p1->average_bursttime - p2->average_bursttime;
    80001f1e:	4568                	lw	a0,76(a0)
    80001f20:	45fc                	lw	a5,76(a1)
}
    80001f22:	9d1d                	subw	a0,a0,a5
    80001f24:	6422                	ld	s0,8(sp)
    80001f26:	0141                	addi	sp,sp,16
    80001f28:	8082                	ret

0000000080001f2a <CFSD_compare>:
CFSD_compare(struct proc *p1,struct proc *p2){
    80001f2a:	1141                	addi	sp,sp,-16
    80001f2c:	e422                	sd	s0,8(sp)
    80001f2e:	0800                	addi	s0,sp,16
  int p1_priority=(p1->rutime*p1->decay_factor)/(p1->rutime+p1->stime);
    80001f30:	453c                	lw	a5,72(a0)
  int p2_priority=(p2->rutime*p2->decay_factor)/(p2->rutime+p2->stime);
    80001f32:	45b4                	lw	a3,72(a1)
  int p1_priority=(p1->rutime*p1->decay_factor)/(p1->rutime+p1->stime);
    80001f34:	4938                	lw	a4,80(a0)
    80001f36:	02f7073b          	mulw	a4,a4,a5
    80001f3a:	4128                	lw	a0,64(a0)
    80001f3c:	9d3d                	addw	a0,a0,a5
    80001f3e:	02a7453b          	divw	a0,a4,a0
  int p2_priority=(p2->rutime*p2->decay_factor)/(p2->rutime+p2->stime);
    80001f42:	49bc                	lw	a5,80(a1)
    80001f44:	02d787bb          	mulw	a5,a5,a3
    80001f48:	41b8                	lw	a4,64(a1)
    80001f4a:	9f35                	addw	a4,a4,a3
    80001f4c:	02e7c7bb          	divw	a5,a5,a4
}
    80001f50:	9d1d                	subw	a0,a0,a5
    80001f52:	6422                	ld	s0,8(sp)
    80001f54:	0141                	addi	sp,sp,16
    80001f56:	8082                	ret

0000000080001f58 <default_policy>:
default_policy(){
    80001f58:	7139                	addi	sp,sp,-64
    80001f5a:	fc06                	sd	ra,56(sp)
    80001f5c:	f822                	sd	s0,48(sp)
    80001f5e:	f426                	sd	s1,40(sp)
    80001f60:	f04a                	sd	s2,32(sp)
    80001f62:	ec4e                	sd	s3,24(sp)
    80001f64:	e852                	sd	s4,16(sp)
    80001f66:	e456                	sd	s5,8(sp)
    80001f68:	e05a                	sd	s6,0(sp)
    80001f6a:	0080                	addi	s0,sp,64
    80001f6c:	8792                	mv	a5,tp
  int id = r_tp();
    80001f6e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f70:	00779a93          	slli	s5,a5,0x7
    80001f74:	0000f717          	auipc	a4,0xf
    80001f78:	32c70713          	addi	a4,a4,812 # 800112a0 <pid_lock>
    80001f7c:	9756                	add	a4,a4,s5
    80001f7e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f82:	0000f717          	auipc	a4,0xf
    80001f86:	35670713          	addi	a4,a4,854 # 800112d8 <cpus+0x8>
    80001f8a:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f8c:	498d                	li	s3,3
        p->state = RUNNING;
    80001f8e:	4b11                	li	s6,4
        c->proc = p;
    80001f90:	079e                	slli	a5,a5,0x7
    80001f92:	0000fa17          	auipc	s4,0xf
    80001f96:	30ea0a13          	addi	s4,s4,782 # 800112a0 <pid_lock>
    80001f9a:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f9c:	00016917          	auipc	s2,0x16
    80001fa0:	b3490913          	addi	s2,s2,-1228 # 80017ad0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fa4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fa8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fac:	10079073          	csrw	sstatus,a5
    80001fb0:	0000f497          	auipc	s1,0xf
    80001fb4:	72048493          	addi	s1,s1,1824 # 800116d0 <proc>
    80001fb8:	a811                	j	80001fcc <default_policy+0x74>
      release(&p->lock);
    80001fba:	8526                	mv	a0,s1
    80001fbc:	fffff097          	auipc	ra,0xfffff
    80001fc0:	cba080e7          	jalr	-838(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fc4:	19048493          	addi	s1,s1,400
    80001fc8:	fd248ee3          	beq	s1,s2,80001fa4 <default_policy+0x4c>
      acquire(&p->lock);
    80001fcc:	8526                	mv	a0,s1
    80001fce:	fffff097          	auipc	ra,0xfffff
    80001fd2:	bf4080e7          	jalr	-1036(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE) {
    80001fd6:	4c9c                	lw	a5,24(s1)
    80001fd8:	ff3791e3          	bne	a5,s3,80001fba <default_policy+0x62>
        p->state = RUNNING;
    80001fdc:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fe0:	029a3823          	sd	s1,48(s4)
        p->current_runtime = 0;
    80001fe4:	0404aa23          	sw	zero,84(s1)
        swtch(&c->context, &p->context);
    80001fe8:	08848593          	addi	a1,s1,136
    80001fec:	8556                	mv	a0,s5
    80001fee:	00001097          	auipc	ra,0x1
    80001ff2:	a9c080e7          	jalr	-1380(ra) # 80002a8a <swtch>
        c->proc = 0;
    80001ff6:	020a3823          	sd	zero,48(s4)
    80001ffa:	b7c1                	j	80001fba <default_policy+0x62>

0000000080001ffc <scheduler>:
{
    80001ffc:	1141                	addi	sp,sp,-16
    80001ffe:	e406                	sd	ra,8(sp)
    80002000:	e022                	sd	s0,0(sp)
    80002002:	0800                	addi	s0,sp,16
    printf("default schedueling policy active\n");
    80002004:	00006517          	auipc	a0,0x6
    80002008:	1fc50513          	addi	a0,a0,508 # 80008200 <digits+0x1c0>
    8000200c:	ffffe097          	auipc	ra,0xffffe
    80002010:	568080e7          	jalr	1384(ra) # 80000574 <printf>
    default_policy();
    80002014:	00000097          	auipc	ra,0x0
    80002018:	f44080e7          	jalr	-188(ra) # 80001f58 <default_policy>

000000008000201c <comperative_policy>:
comperative_policy(int (*compare)(struct proc *p1, struct proc *p2)){
    8000201c:	7119                	addi	sp,sp,-128
    8000201e:	fc86                	sd	ra,120(sp)
    80002020:	f8a2                	sd	s0,112(sp)
    80002022:	f4a6                	sd	s1,104(sp)
    80002024:	f0ca                	sd	s2,96(sp)
    80002026:	ecce                	sd	s3,88(sp)
    80002028:	e8d2                	sd	s4,80(sp)
    8000202a:	e4d6                	sd	s5,72(sp)
    8000202c:	e0da                	sd	s6,64(sp)
    8000202e:	fc5e                	sd	s7,56(sp)
    80002030:	f862                	sd	s8,48(sp)
    80002032:	f466                	sd	s9,40(sp)
    80002034:	f06a                	sd	s10,32(sp)
    80002036:	ec6e                	sd	s11,24(sp)
    80002038:	0100                	addi	s0,sp,128
    8000203a:	8caa                	mv	s9,a0
  asm volatile("mv %0, tp" : "=r" (x) );
    8000203c:	8792                	mv	a5,tp
  int id = r_tp();
    8000203e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002040:	00779693          	slli	a3,a5,0x7
    80002044:	0000f717          	auipc	a4,0xf
    80002048:	25c70713          	addi	a4,a4,604 # 800112a0 <pid_lock>
    8000204c:	9736                	add	a4,a4,a3
    8000204e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &next_p->context);
    80002052:	0000f717          	auipc	a4,0xf
    80002056:	28670713          	addi	a4,a4,646 # 800112d8 <cpus+0x8>
    8000205a:	9736                	add	a4,a4,a3
    8000205c:	f8e43423          	sd	a4,-120(s0)
    next_p = 0;
    80002060:	4d01                	li	s10,0
      if(p->state == RUNNABLE && p->chosen == 0) {
    80002062:	4a8d                	li	s5,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80002064:	00016b17          	auipc	s6,0x16
    80002068:	a6cb0b13          	addi	s6,s6,-1428 # 80017ad0 <tickslock>
        c->proc = next_p;
    8000206c:	0000fd97          	auipc	s11,0xf
    80002070:	234d8d93          	addi	s11,s11,564 # 800112a0 <pid_lock>
    80002074:	9db6                	add	s11,s11,a3
    80002076:	a0e9                	j	80002140 <comperative_policy+0x124>
            acquire(&next_p->lock);
    80002078:	855e                	mv	a0,s7
    8000207a:	fffff097          	auipc	ra,0xfffff
    8000207e:	b48080e7          	jalr	-1208(ra) # 80000bc2 <acquire>
            next_p->chosen = 0;
    80002082:	040bae23          	sw	zero,92(s7) # fffffffffffff05c <end+0xffffffff7ffd905c>
            release(&next_p->lock);
    80002086:	855e                	mv	a0,s7
    80002088:	fffff097          	auipc	ra,0xfffff
    8000208c:	bee080e7          	jalr	-1042(ra) # 80000c76 <release>
    80002090:	a0a9                	j	800020da <comperative_policy+0xbe>
      release(&p->lock);
    80002092:	854e                	mv	a0,s3
    80002094:	fffff097          	auipc	ra,0xfffff
    80002098:	be2080e7          	jalr	-1054(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000209c:	0b6a7463          	bgeu	s4,s6,80002144 <comperative_policy+0x128>
    800020a0:	19090913          	addi	s2,s2,400
    800020a4:	19048493          	addi	s1,s1,400
    800020a8:	89ca                	mv	s3,s2
      acquire(&p->lock);
    800020aa:	854a                	mv	a0,s2
    800020ac:	fffff097          	auipc	ra,0xfffff
    800020b0:	b16080e7          	jalr	-1258(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE && p->chosen == 0) {
    800020b4:	8a26                	mv	s4,s1
    800020b6:	e884a783          	lw	a5,-376(s1)
    800020ba:	fd579ce3          	bne	a5,s5,80002092 <comperative_policy+0x76>
    800020be:	ecc4a783          	lw	a5,-308(s1)
    800020c2:	fbe1                	bnez	a5,80002092 <comperative_policy+0x76>
        if(next_p == 0 || compare(next_p, p) > 0){  
    800020c4:	000b8b63          	beqz	s7,800020da <comperative_policy+0xbe>
    800020c8:	85ca                	mv	a1,s2
    800020ca:	855e                	mv	a0,s7
    800020cc:	9c82                	jalr	s9
    800020ce:	00a05963          	blez	a0,800020e0 <comperative_policy+0xc4>
          if( next_p!=0 && next_p->chosen==1){
    800020d2:	05cba783          	lw	a5,92(s7)
    800020d6:	fb8781e3          	beq	a5,s8,80002078 <comperative_policy+0x5c>
          p->chosen=1;
    800020da:	ed8a2623          	sw	s8,-308(s4)
    800020de:	8bce                	mv	s7,s3
      release(&p->lock);
    800020e0:	854e                	mv	a0,s3
    800020e2:	fffff097          	auipc	ra,0xfffff
    800020e6:	b94080e7          	jalr	-1132(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800020ea:	fb6a6be3          	bltu	s4,s6,800020a0 <comperative_policy+0x84>
      acquire(&next_p->lock);
    800020ee:	84de                	mv	s1,s7
    800020f0:	855e                	mv	a0,s7
    800020f2:	fffff097          	auipc	ra,0xfffff
    800020f6:	ad0080e7          	jalr	-1328(ra) # 80000bc2 <acquire>
      if(next_p->state==RUNNABLE){
    800020fa:	018ba783          	lw	a5,24(s7)
    800020fe:	03579a63          	bne	a5,s5,80002132 <comperative_policy+0x116>
        next_p->state = RUNNING;
    80002102:	4791                	li	a5,4
    80002104:	00fbac23          	sw	a5,24(s7)
        c->proc = next_p;
    80002108:	037db823          	sd	s7,48(s11)
        next_p->current_runtime = 0;
    8000210c:	040baa23          	sw	zero,84(s7)
        swtch(&c->context, &next_p->context);
    80002110:	088b8593          	addi	a1,s7,136
    80002114:	f8843503          	ld	a0,-120(s0)
    80002118:	00001097          	auipc	ra,0x1
    8000211c:	972080e7          	jalr	-1678(ra) # 80002a8a <swtch>
        c->proc=0;
    80002120:	020db823          	sd	zero,48(s11)
        next_p->runnable_since=ticks+1;
    80002124:	00007797          	auipc	a5,0x7
    80002128:	f0c7a783          	lw	a5,-244(a5) # 80009030 <ticks>
    8000212c:	2785                	addiw	a5,a5,1
    8000212e:	04fbac23          	sw	a5,88(s7)
      next_p->chosen = 0;
    80002132:	040bae23          	sw	zero,92(s7)
      release(&next_p->lock);
    80002136:	8526                	mv	a0,s1
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	b3e080e7          	jalr	-1218(ra) # 80000c76 <release>
          p->chosen=1;
    80002140:	4c05                	li	s8,1
    80002142:	a019                	j	80002148 <comperative_policy+0x12c>
    if(next_p!=0 ){
    80002144:	fa0b95e3          	bnez	s7,800020ee <comperative_policy+0xd2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002148:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000214c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002150:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002154:	0000f917          	auipc	s2,0xf
    80002158:	57c90913          	addi	s2,s2,1404 # 800116d0 <proc>
    8000215c:	0000f497          	auipc	s1,0xf
    80002160:	70448493          	addi	s1,s1,1796 # 80011860 <proc+0x190>
    next_p = 0;
    80002164:	8bea                	mv	s7,s10
    80002166:	b789                	j	800020a8 <comperative_policy+0x8c>

0000000080002168 <sched>:
{
    80002168:	7179                	addi	sp,sp,-48
    8000216a:	f406                	sd	ra,40(sp)
    8000216c:	f022                	sd	s0,32(sp)
    8000216e:	ec26                	sd	s1,24(sp)
    80002170:	e84a                	sd	s2,16(sp)
    80002172:	e44e                	sd	s3,8(sp)
    80002174:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002176:	00000097          	auipc	ra,0x0
    8000217a:	808080e7          	jalr	-2040(ra) # 8000197e <myproc>
    8000217e:	84aa                	mv	s1,a0
  int temp =  ALPHA * (ticks - p->runnable_since) + ((100-ALPHA) * p->average_bursttime) / 100;
    80002180:	4d38                	lw	a4,88(a0)
    80002182:	00007797          	auipc	a5,0x7
    80002186:	eae7a783          	lw	a5,-338(a5) # 80009030 <ticks>
    8000218a:	9f99                	subw	a5,a5,a4
    8000218c:	03200713          	li	a4,50
    80002190:	02e787bb          	mulw	a5,a5,a4
    80002194:	4574                	lw	a3,76(a0)
    80002196:	01f6d71b          	srliw	a4,a3,0x1f
    8000219a:	9f35                	addw	a4,a4,a3
    8000219c:	4017571b          	sraiw	a4,a4,0x1
    800021a0:	9fb9                	addw	a5,a5,a4
  p->average_bursttime=temp;
    800021a2:	c57c                	sw	a5,76(a0)
  if(!holding(&p->lock))
    800021a4:	fffff097          	auipc	ra,0xfffff
    800021a8:	9a4080e7          	jalr	-1628(ra) # 80000b48 <holding>
    800021ac:	c93d                	beqz	a0,80002222 <sched+0xba>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021ae:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800021b0:	2781                	sext.w	a5,a5
    800021b2:	079e                	slli	a5,a5,0x7
    800021b4:	0000f717          	auipc	a4,0xf
    800021b8:	0ec70713          	addi	a4,a4,236 # 800112a0 <pid_lock>
    800021bc:	97ba                	add	a5,a5,a4
    800021be:	0a87a703          	lw	a4,168(a5)
    800021c2:	4785                	li	a5,1
    800021c4:	06f71763          	bne	a4,a5,80002232 <sched+0xca>
  if(p->state == RUNNING)
    800021c8:	4c98                	lw	a4,24(s1)
    800021ca:	4791                	li	a5,4
    800021cc:	06f70b63          	beq	a4,a5,80002242 <sched+0xda>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021d0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800021d4:	8b89                	andi	a5,a5,2
  if(intr_get())
    800021d6:	efb5                	bnez	a5,80002252 <sched+0xea>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021d8:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800021da:	0000f917          	auipc	s2,0xf
    800021de:	0c690913          	addi	s2,s2,198 # 800112a0 <pid_lock>
    800021e2:	2781                	sext.w	a5,a5
    800021e4:	079e                	slli	a5,a5,0x7
    800021e6:	97ca                	add	a5,a5,s2
    800021e8:	0ac7a983          	lw	s3,172(a5)
    800021ec:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800021ee:	2781                	sext.w	a5,a5
    800021f0:	079e                	slli	a5,a5,0x7
    800021f2:	0000f597          	auipc	a1,0xf
    800021f6:	0e658593          	addi	a1,a1,230 # 800112d8 <cpus+0x8>
    800021fa:	95be                	add	a1,a1,a5
    800021fc:	08848513          	addi	a0,s1,136
    80002200:	00001097          	auipc	ra,0x1
    80002204:	88a080e7          	jalr	-1910(ra) # 80002a8a <swtch>
    80002208:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000220a:	2781                	sext.w	a5,a5
    8000220c:	079e                	slli	a5,a5,0x7
    8000220e:	97ca                	add	a5,a5,s2
    80002210:	0b37a623          	sw	s3,172(a5)
}
    80002214:	70a2                	ld	ra,40(sp)
    80002216:	7402                	ld	s0,32(sp)
    80002218:	64e2                	ld	s1,24(sp)
    8000221a:	6942                	ld	s2,16(sp)
    8000221c:	69a2                	ld	s3,8(sp)
    8000221e:	6145                	addi	sp,sp,48
    80002220:	8082                	ret
    panic("sched p->lock");
    80002222:	00006517          	auipc	a0,0x6
    80002226:	00650513          	addi	a0,a0,6 # 80008228 <digits+0x1e8>
    8000222a:	ffffe097          	auipc	ra,0xffffe
    8000222e:	300080e7          	jalr	768(ra) # 8000052a <panic>
    panic("sched locks");
    80002232:	00006517          	auipc	a0,0x6
    80002236:	00650513          	addi	a0,a0,6 # 80008238 <digits+0x1f8>
    8000223a:	ffffe097          	auipc	ra,0xffffe
    8000223e:	2f0080e7          	jalr	752(ra) # 8000052a <panic>
    panic("sched running");
    80002242:	00006517          	auipc	a0,0x6
    80002246:	00650513          	addi	a0,a0,6 # 80008248 <digits+0x208>
    8000224a:	ffffe097          	auipc	ra,0xffffe
    8000224e:	2e0080e7          	jalr	736(ra) # 8000052a <panic>
    panic("sched interruptible");
    80002252:	00006517          	auipc	a0,0x6
    80002256:	00650513          	addi	a0,a0,6 # 80008258 <digits+0x218>
    8000225a:	ffffe097          	auipc	ra,0xffffe
    8000225e:	2d0080e7          	jalr	720(ra) # 8000052a <panic>

0000000080002262 <yield>:
{
    80002262:	1101                	addi	sp,sp,-32
    80002264:	ec06                	sd	ra,24(sp)
    80002266:	e822                	sd	s0,16(sp)
    80002268:	e426                	sd	s1,8(sp)
    8000226a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000226c:	fffff097          	auipc	ra,0xfffff
    80002270:	712080e7          	jalr	1810(ra) # 8000197e <myproc>
    80002274:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	94c080e7          	jalr	-1716(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    8000227e:	478d                	li	a5,3
    80002280:	cc9c                	sw	a5,24(s1)
  p->runnable_since=ticks;
    80002282:	00007797          	auipc	a5,0x7
    80002286:	dae7a783          	lw	a5,-594(a5) # 80009030 <ticks>
    8000228a:	ccbc                	sw	a5,88(s1)
  sched();
    8000228c:	00000097          	auipc	ra,0x0
    80002290:	edc080e7          	jalr	-292(ra) # 80002168 <sched>
  release(&p->lock);
    80002294:	8526                	mv	a0,s1
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	9e0080e7          	jalr	-1568(ra) # 80000c76 <release>
}
    8000229e:	60e2                	ld	ra,24(sp)
    800022a0:	6442                	ld	s0,16(sp)
    800022a2:	64a2                	ld	s1,8(sp)
    800022a4:	6105                	addi	sp,sp,32
    800022a6:	8082                	ret

00000000800022a8 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800022a8:	7179                	addi	sp,sp,-48
    800022aa:	f406                	sd	ra,40(sp)
    800022ac:	f022                	sd	s0,32(sp)
    800022ae:	ec26                	sd	s1,24(sp)
    800022b0:	e84a                	sd	s2,16(sp)
    800022b2:	e44e                	sd	s3,8(sp)
    800022b4:	1800                	addi	s0,sp,48
    800022b6:	89aa                	mv	s3,a0
    800022b8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800022ba:	fffff097          	auipc	ra,0xfffff
    800022be:	6c4080e7          	jalr	1732(ra) # 8000197e <myproc>
    800022c2:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800022c4:	fffff097          	auipc	ra,0xfffff
    800022c8:	8fe080e7          	jalr	-1794(ra) # 80000bc2 <acquire>
  release(lk);
    800022cc:	854a                	mv	a0,s2
    800022ce:	fffff097          	auipc	ra,0xfffff
    800022d2:	9a8080e7          	jalr	-1624(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    800022d6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800022da:	4789                	li	a5,2
    800022dc:	cc9c                	sw	a5,24(s1)

  sched();
    800022de:	00000097          	auipc	ra,0x0
    800022e2:	e8a080e7          	jalr	-374(ra) # 80002168 <sched>

  // Tidy up.
  p->chan = 0;
    800022e6:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800022ea:	8526                	mv	a0,s1
    800022ec:	fffff097          	auipc	ra,0xfffff
    800022f0:	98a080e7          	jalr	-1654(ra) # 80000c76 <release>
  acquire(lk);
    800022f4:	854a                	mv	a0,s2
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	8cc080e7          	jalr	-1844(ra) # 80000bc2 <acquire>
}
    800022fe:	70a2                	ld	ra,40(sp)
    80002300:	7402                	ld	s0,32(sp)
    80002302:	64e2                	ld	s1,24(sp)
    80002304:	6942                	ld	s2,16(sp)
    80002306:	69a2                	ld	s3,8(sp)
    80002308:	6145                	addi	sp,sp,48
    8000230a:	8082                	ret

000000008000230c <wait>:
{
    8000230c:	715d                	addi	sp,sp,-80
    8000230e:	e486                	sd	ra,72(sp)
    80002310:	e0a2                	sd	s0,64(sp)
    80002312:	fc26                	sd	s1,56(sp)
    80002314:	f84a                	sd	s2,48(sp)
    80002316:	f44e                	sd	s3,40(sp)
    80002318:	f052                	sd	s4,32(sp)
    8000231a:	ec56                	sd	s5,24(sp)
    8000231c:	e85a                	sd	s6,16(sp)
    8000231e:	e45e                	sd	s7,8(sp)
    80002320:	e062                	sd	s8,0(sp)
    80002322:	0880                	addi	s0,sp,80
    80002324:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002326:	fffff097          	auipc	ra,0xfffff
    8000232a:	658080e7          	jalr	1624(ra) # 8000197e <myproc>
    8000232e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002330:	0000f517          	auipc	a0,0xf
    80002334:	f8850513          	addi	a0,a0,-120 # 800112b8 <wait_lock>
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	88a080e7          	jalr	-1910(ra) # 80000bc2 <acquire>
    havekids = 0;
    80002340:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002342:	4a15                	li	s4,5
        havekids = 1;
    80002344:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002346:	00015997          	auipc	s3,0x15
    8000234a:	78a98993          	addi	s3,s3,1930 # 80017ad0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000234e:	0000fc17          	auipc	s8,0xf
    80002352:	f6ac0c13          	addi	s8,s8,-150 # 800112b8 <wait_lock>
    havekids = 0;
    80002356:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002358:	0000f497          	auipc	s1,0xf
    8000235c:	37848493          	addi	s1,s1,888 # 800116d0 <proc>
    80002360:	a0bd                	j	800023ce <wait+0xc2>
          pid = np->pid;
    80002362:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002366:	000b0e63          	beqz	s6,80002382 <wait+0x76>
    8000236a:	4691                	li	a3,4
    8000236c:	02c48613          	addi	a2,s1,44
    80002370:	85da                	mv	a1,s6
    80002372:	07893503          	ld	a0,120(s2)
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	2c8080e7          	jalr	712(ra) # 8000163e <copyout>
    8000237e:	02054563          	bltz	a0,800023a8 <wait+0x9c>
          freeproc(np);
    80002382:	8526                	mv	a0,s1
    80002384:	fffff097          	auipc	ra,0xfffff
    80002388:	7ac080e7          	jalr	1964(ra) # 80001b30 <freeproc>
          release(&np->lock);
    8000238c:	8526                	mv	a0,s1
    8000238e:	fffff097          	auipc	ra,0xfffff
    80002392:	8e8080e7          	jalr	-1816(ra) # 80000c76 <release>
          release(&wait_lock);
    80002396:	0000f517          	auipc	a0,0xf
    8000239a:	f2250513          	addi	a0,a0,-222 # 800112b8 <wait_lock>
    8000239e:	fffff097          	auipc	ra,0xfffff
    800023a2:	8d8080e7          	jalr	-1832(ra) # 80000c76 <release>
          return pid;
    800023a6:	a09d                	j	8000240c <wait+0x100>
            release(&np->lock);
    800023a8:	8526                	mv	a0,s1
    800023aa:	fffff097          	auipc	ra,0xfffff
    800023ae:	8cc080e7          	jalr	-1844(ra) # 80000c76 <release>
            release(&wait_lock);
    800023b2:	0000f517          	auipc	a0,0xf
    800023b6:	f0650513          	addi	a0,a0,-250 # 800112b8 <wait_lock>
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	8bc080e7          	jalr	-1860(ra) # 80000c76 <release>
            return -1;
    800023c2:	59fd                	li	s3,-1
    800023c4:	a0a1                	j	8000240c <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800023c6:	19048493          	addi	s1,s1,400
    800023ca:	03348463          	beq	s1,s3,800023f2 <wait+0xe6>
      if(np->parent == p){
    800023ce:	70bc                	ld	a5,96(s1)
    800023d0:	ff279be3          	bne	a5,s2,800023c6 <wait+0xba>
        acquire(&np->lock);
    800023d4:	8526                	mv	a0,s1
    800023d6:	ffffe097          	auipc	ra,0xffffe
    800023da:	7ec080e7          	jalr	2028(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    800023de:	4c9c                	lw	a5,24(s1)
    800023e0:	f94781e3          	beq	a5,s4,80002362 <wait+0x56>
        release(&np->lock);
    800023e4:	8526                	mv	a0,s1
    800023e6:	fffff097          	auipc	ra,0xfffff
    800023ea:	890080e7          	jalr	-1904(ra) # 80000c76 <release>
        havekids = 1;
    800023ee:	8756                	mv	a4,s5
    800023f0:	bfd9                	j	800023c6 <wait+0xba>
    if(!havekids || p->killed){
    800023f2:	c701                	beqz	a4,800023fa <wait+0xee>
    800023f4:	02892783          	lw	a5,40(s2)
    800023f8:	c79d                	beqz	a5,80002426 <wait+0x11a>
      release(&wait_lock);
    800023fa:	0000f517          	auipc	a0,0xf
    800023fe:	ebe50513          	addi	a0,a0,-322 # 800112b8 <wait_lock>
    80002402:	fffff097          	auipc	ra,0xfffff
    80002406:	874080e7          	jalr	-1932(ra) # 80000c76 <release>
      return -1;
    8000240a:	59fd                	li	s3,-1
}
    8000240c:	854e                	mv	a0,s3
    8000240e:	60a6                	ld	ra,72(sp)
    80002410:	6406                	ld	s0,64(sp)
    80002412:	74e2                	ld	s1,56(sp)
    80002414:	7942                	ld	s2,48(sp)
    80002416:	79a2                	ld	s3,40(sp)
    80002418:	7a02                	ld	s4,32(sp)
    8000241a:	6ae2                	ld	s5,24(sp)
    8000241c:	6b42                	ld	s6,16(sp)
    8000241e:	6ba2                	ld	s7,8(sp)
    80002420:	6c02                	ld	s8,0(sp)
    80002422:	6161                	addi	sp,sp,80
    80002424:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002426:	85e2                	mv	a1,s8
    80002428:	854a                	mv	a0,s2
    8000242a:	00000097          	auipc	ra,0x0
    8000242e:	e7e080e7          	jalr	-386(ra) # 800022a8 <sleep>
    havekids = 0;
    80002432:	b715                	j	80002356 <wait+0x4a>

0000000080002434 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002434:	7139                	addi	sp,sp,-64
    80002436:	fc06                	sd	ra,56(sp)
    80002438:	f822                	sd	s0,48(sp)
    8000243a:	f426                	sd	s1,40(sp)
    8000243c:	f04a                	sd	s2,32(sp)
    8000243e:	ec4e                	sd	s3,24(sp)
    80002440:	e852                	sd	s4,16(sp)
    80002442:	e456                	sd	s5,8(sp)
    80002444:	e05a                	sd	s6,0(sp)
    80002446:	0080                	addi	s0,sp,64
    80002448:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000244a:	0000f497          	auipc	s1,0xf
    8000244e:	28648493          	addi	s1,s1,646 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002452:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002454:	4b0d                	li	s6,3
        p->runnable_since = ticks;
    80002456:	00007a97          	auipc	s5,0x7
    8000245a:	bdaa8a93          	addi	s5,s5,-1062 # 80009030 <ticks>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000245e:	00015917          	auipc	s2,0x15
    80002462:	67290913          	addi	s2,s2,1650 # 80017ad0 <tickslock>
    80002466:	a811                	j	8000247a <wakeup+0x46>
      }
      release(&p->lock);
    80002468:	8526                	mv	a0,s1
    8000246a:	fffff097          	auipc	ra,0xfffff
    8000246e:	80c080e7          	jalr	-2036(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002472:	19048493          	addi	s1,s1,400
    80002476:	03248963          	beq	s1,s2,800024a8 <wakeup+0x74>
    if(p != myproc()){
    8000247a:	fffff097          	auipc	ra,0xfffff
    8000247e:	504080e7          	jalr	1284(ra) # 8000197e <myproc>
    80002482:	fea488e3          	beq	s1,a0,80002472 <wakeup+0x3e>
      acquire(&p->lock);
    80002486:	8526                	mv	a0,s1
    80002488:	ffffe097          	auipc	ra,0xffffe
    8000248c:	73a080e7          	jalr	1850(ra) # 80000bc2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002490:	4c9c                	lw	a5,24(s1)
    80002492:	fd379be3          	bne	a5,s3,80002468 <wakeup+0x34>
    80002496:	709c                	ld	a5,32(s1)
    80002498:	fd4798e3          	bne	a5,s4,80002468 <wakeup+0x34>
        p->state = RUNNABLE;
    8000249c:	0164ac23          	sw	s6,24(s1)
        p->runnable_since = ticks;
    800024a0:	000aa783          	lw	a5,0(s5)
    800024a4:	ccbc                	sw	a5,88(s1)
    800024a6:	b7c9                	j	80002468 <wakeup+0x34>
    }
  }
}
    800024a8:	70e2                	ld	ra,56(sp)
    800024aa:	7442                	ld	s0,48(sp)
    800024ac:	74a2                	ld	s1,40(sp)
    800024ae:	7902                	ld	s2,32(sp)
    800024b0:	69e2                	ld	s3,24(sp)
    800024b2:	6a42                	ld	s4,16(sp)
    800024b4:	6aa2                	ld	s5,8(sp)
    800024b6:	6b02                	ld	s6,0(sp)
    800024b8:	6121                	addi	sp,sp,64
    800024ba:	8082                	ret

00000000800024bc <reparent>:
{
    800024bc:	7179                	addi	sp,sp,-48
    800024be:	f406                	sd	ra,40(sp)
    800024c0:	f022                	sd	s0,32(sp)
    800024c2:	ec26                	sd	s1,24(sp)
    800024c4:	e84a                	sd	s2,16(sp)
    800024c6:	e44e                	sd	s3,8(sp)
    800024c8:	e052                	sd	s4,0(sp)
    800024ca:	1800                	addi	s0,sp,48
    800024cc:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024ce:	0000f497          	auipc	s1,0xf
    800024d2:	20248493          	addi	s1,s1,514 # 800116d0 <proc>
      pp->parent = initproc;
    800024d6:	00007a17          	auipc	s4,0x7
    800024da:	b52a0a13          	addi	s4,s4,-1198 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024de:	00015997          	auipc	s3,0x15
    800024e2:	5f298993          	addi	s3,s3,1522 # 80017ad0 <tickslock>
    800024e6:	a029                	j	800024f0 <reparent+0x34>
    800024e8:	19048493          	addi	s1,s1,400
    800024ec:	01348d63          	beq	s1,s3,80002506 <reparent+0x4a>
    if(pp->parent == p){
    800024f0:	70bc                	ld	a5,96(s1)
    800024f2:	ff279be3          	bne	a5,s2,800024e8 <reparent+0x2c>
      pp->parent = initproc;
    800024f6:	000a3503          	ld	a0,0(s4)
    800024fa:	f0a8                	sd	a0,96(s1)
      wakeup(initproc);
    800024fc:	00000097          	auipc	ra,0x0
    80002500:	f38080e7          	jalr	-200(ra) # 80002434 <wakeup>
    80002504:	b7d5                	j	800024e8 <reparent+0x2c>
}
    80002506:	70a2                	ld	ra,40(sp)
    80002508:	7402                	ld	s0,32(sp)
    8000250a:	64e2                	ld	s1,24(sp)
    8000250c:	6942                	ld	s2,16(sp)
    8000250e:	69a2                	ld	s3,8(sp)
    80002510:	6a02                	ld	s4,0(sp)
    80002512:	6145                	addi	sp,sp,48
    80002514:	8082                	ret

0000000080002516 <exit>:
{
    80002516:	7179                	addi	sp,sp,-48
    80002518:	f406                	sd	ra,40(sp)
    8000251a:	f022                	sd	s0,32(sp)
    8000251c:	ec26                	sd	s1,24(sp)
    8000251e:	e84a                	sd	s2,16(sp)
    80002520:	e44e                	sd	s3,8(sp)
    80002522:	e052                	sd	s4,0(sp)
    80002524:	1800                	addi	s0,sp,48
    80002526:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002528:	fffff097          	auipc	ra,0xfffff
    8000252c:	456080e7          	jalr	1110(ra) # 8000197e <myproc>
    80002530:	89aa                	mv	s3,a0
  if(p == initproc)
    80002532:	00007797          	auipc	a5,0x7
    80002536:	af67b783          	ld	a5,-1290(a5) # 80009028 <initproc>
    8000253a:	0f850493          	addi	s1,a0,248
    8000253e:	17850913          	addi	s2,a0,376
    80002542:	02a79363          	bne	a5,a0,80002568 <exit+0x52>
    panic("init exiting");
    80002546:	00006517          	auipc	a0,0x6
    8000254a:	d2a50513          	addi	a0,a0,-726 # 80008270 <digits+0x230>
    8000254e:	ffffe097          	auipc	ra,0xffffe
    80002552:	fdc080e7          	jalr	-36(ra) # 8000052a <panic>
      fileclose(f);
    80002556:	00002097          	auipc	ra,0x2
    8000255a:	5f6080e7          	jalr	1526(ra) # 80004b4c <fileclose>
      p->ofile[fd] = 0;
    8000255e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002562:	04a1                	addi	s1,s1,8
    80002564:	01248563          	beq	s1,s2,8000256e <exit+0x58>
    if(p->ofile[fd]){
    80002568:	6088                	ld	a0,0(s1)
    8000256a:	f575                	bnez	a0,80002556 <exit+0x40>
    8000256c:	bfdd                	j	80002562 <exit+0x4c>
  begin_op();
    8000256e:	00002097          	auipc	ra,0x2
    80002572:	112080e7          	jalr	274(ra) # 80004680 <begin_op>
  iput(p->cwd);
    80002576:	1789b503          	ld	a0,376(s3)
    8000257a:	00002097          	auipc	ra,0x2
    8000257e:	8ea080e7          	jalr	-1814(ra) # 80003e64 <iput>
  end_op();
    80002582:	00002097          	auipc	ra,0x2
    80002586:	17e080e7          	jalr	382(ra) # 80004700 <end_op>
  p->cwd = 0;
    8000258a:	1609bc23          	sd	zero,376(s3)
  acquire(&wait_lock);
    8000258e:	0000f497          	auipc	s1,0xf
    80002592:	d2a48493          	addi	s1,s1,-726 # 800112b8 <wait_lock>
    80002596:	8526                	mv	a0,s1
    80002598:	ffffe097          	auipc	ra,0xffffe
    8000259c:	62a080e7          	jalr	1578(ra) # 80000bc2 <acquire>
  reparent(p);
    800025a0:	854e                	mv	a0,s3
    800025a2:	00000097          	auipc	ra,0x0
    800025a6:	f1a080e7          	jalr	-230(ra) # 800024bc <reparent>
  wakeup(p->parent);
    800025aa:	0609b503          	ld	a0,96(s3)
    800025ae:	00000097          	auipc	ra,0x0
    800025b2:	e86080e7          	jalr	-378(ra) # 80002434 <wakeup>
  acquire(&p->lock);
    800025b6:	854e                	mv	a0,s3
    800025b8:	ffffe097          	auipc	ra,0xffffe
    800025bc:	60a080e7          	jalr	1546(ra) # 80000bc2 <acquire>
  p->xstate = status;
    800025c0:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800025c4:	4795                	li	a5,5
    800025c6:	00f9ac23          	sw	a5,24(s3)
  p->ttime = ticks; //update termination time
    800025ca:	00007797          	auipc	a5,0x7
    800025ce:	a667a783          	lw	a5,-1434(a5) # 80009030 <ticks>
    800025d2:	02f9ae23          	sw	a5,60(s3)
  release(&wait_lock);
    800025d6:	8526                	mv	a0,s1
    800025d8:	ffffe097          	auipc	ra,0xffffe
    800025dc:	69e080e7          	jalr	1694(ra) # 80000c76 <release>
  sched();
    800025e0:	00000097          	auipc	ra,0x0
    800025e4:	b88080e7          	jalr	-1144(ra) # 80002168 <sched>
  panic("zombie exit");
    800025e8:	00006517          	auipc	a0,0x6
    800025ec:	c9850513          	addi	a0,a0,-872 # 80008280 <digits+0x240>
    800025f0:	ffffe097          	auipc	ra,0xffffe
    800025f4:	f3a080e7          	jalr	-198(ra) # 8000052a <panic>

00000000800025f8 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800025f8:	7179                	addi	sp,sp,-48
    800025fa:	f406                	sd	ra,40(sp)
    800025fc:	f022                	sd	s0,32(sp)
    800025fe:	ec26                	sd	s1,24(sp)
    80002600:	e84a                	sd	s2,16(sp)
    80002602:	e44e                	sd	s3,8(sp)
    80002604:	1800                	addi	s0,sp,48
    80002606:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002608:	0000f497          	auipc	s1,0xf
    8000260c:	0c848493          	addi	s1,s1,200 # 800116d0 <proc>
    80002610:	00015997          	auipc	s3,0x15
    80002614:	4c098993          	addi	s3,s3,1216 # 80017ad0 <tickslock>
    acquire(&p->lock);
    80002618:	8526                	mv	a0,s1
    8000261a:	ffffe097          	auipc	ra,0xffffe
    8000261e:	5a8080e7          	jalr	1448(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    80002622:	589c                	lw	a5,48(s1)
    80002624:	01278d63          	beq	a5,s2,8000263e <kill+0x46>
        p->runnable_since=ticks;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002628:	8526                	mv	a0,s1
    8000262a:	ffffe097          	auipc	ra,0xffffe
    8000262e:	64c080e7          	jalr	1612(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002632:	19048493          	addi	s1,s1,400
    80002636:	ff3491e3          	bne	s1,s3,80002618 <kill+0x20>
  }
  return -1;
    8000263a:	557d                	li	a0,-1
    8000263c:	a829                	j	80002656 <kill+0x5e>
      p->killed = 1;
    8000263e:	4785                	li	a5,1
    80002640:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002642:	4c98                	lw	a4,24(s1)
    80002644:	4789                	li	a5,2
    80002646:	00f70f63          	beq	a4,a5,80002664 <kill+0x6c>
      release(&p->lock);
    8000264a:	8526                	mv	a0,s1
    8000264c:	ffffe097          	auipc	ra,0xffffe
    80002650:	62a080e7          	jalr	1578(ra) # 80000c76 <release>
      return 0;
    80002654:	4501                	li	a0,0
}
    80002656:	70a2                	ld	ra,40(sp)
    80002658:	7402                	ld	s0,32(sp)
    8000265a:	64e2                	ld	s1,24(sp)
    8000265c:	6942                	ld	s2,16(sp)
    8000265e:	69a2                	ld	s3,8(sp)
    80002660:	6145                	addi	sp,sp,48
    80002662:	8082                	ret
        p->state = RUNNABLE;
    80002664:	478d                	li	a5,3
    80002666:	cc9c                	sw	a5,24(s1)
        p->runnable_since=ticks;
    80002668:	00007797          	auipc	a5,0x7
    8000266c:	9c87a783          	lw	a5,-1592(a5) # 80009030 <ticks>
    80002670:	ccbc                	sw	a5,88(s1)
    80002672:	bfe1                	j	8000264a <kill+0x52>

0000000080002674 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002674:	7179                	addi	sp,sp,-48
    80002676:	f406                	sd	ra,40(sp)
    80002678:	f022                	sd	s0,32(sp)
    8000267a:	ec26                	sd	s1,24(sp)
    8000267c:	e84a                	sd	s2,16(sp)
    8000267e:	e44e                	sd	s3,8(sp)
    80002680:	e052                	sd	s4,0(sp)
    80002682:	1800                	addi	s0,sp,48
    80002684:	84aa                	mv	s1,a0
    80002686:	892e                	mv	s2,a1
    80002688:	89b2                	mv	s3,a2
    8000268a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000268c:	fffff097          	auipc	ra,0xfffff
    80002690:	2f2080e7          	jalr	754(ra) # 8000197e <myproc>
  if(user_dst){
    80002694:	c08d                	beqz	s1,800026b6 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002696:	86d2                	mv	a3,s4
    80002698:	864e                	mv	a2,s3
    8000269a:	85ca                	mv	a1,s2
    8000269c:	7d28                	ld	a0,120(a0)
    8000269e:	fffff097          	auipc	ra,0xfffff
    800026a2:	fa0080e7          	jalr	-96(ra) # 8000163e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800026a6:	70a2                	ld	ra,40(sp)
    800026a8:	7402                	ld	s0,32(sp)
    800026aa:	64e2                	ld	s1,24(sp)
    800026ac:	6942                	ld	s2,16(sp)
    800026ae:	69a2                	ld	s3,8(sp)
    800026b0:	6a02                	ld	s4,0(sp)
    800026b2:	6145                	addi	sp,sp,48
    800026b4:	8082                	ret
    memmove((char *)dst, src, len);
    800026b6:	000a061b          	sext.w	a2,s4
    800026ba:	85ce                	mv	a1,s3
    800026bc:	854a                	mv	a0,s2
    800026be:	ffffe097          	auipc	ra,0xffffe
    800026c2:	65c080e7          	jalr	1628(ra) # 80000d1a <memmove>
    return 0;
    800026c6:	8526                	mv	a0,s1
    800026c8:	bff9                	j	800026a6 <either_copyout+0x32>

00000000800026ca <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026ca:	7179                	addi	sp,sp,-48
    800026cc:	f406                	sd	ra,40(sp)
    800026ce:	f022                	sd	s0,32(sp)
    800026d0:	ec26                	sd	s1,24(sp)
    800026d2:	e84a                	sd	s2,16(sp)
    800026d4:	e44e                	sd	s3,8(sp)
    800026d6:	e052                	sd	s4,0(sp)
    800026d8:	1800                	addi	s0,sp,48
    800026da:	892a                	mv	s2,a0
    800026dc:	84ae                	mv	s1,a1
    800026de:	89b2                	mv	s3,a2
    800026e0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026e2:	fffff097          	auipc	ra,0xfffff
    800026e6:	29c080e7          	jalr	668(ra) # 8000197e <myproc>
  if(user_src){
    800026ea:	c08d                	beqz	s1,8000270c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800026ec:	86d2                	mv	a3,s4
    800026ee:	864e                	mv	a2,s3
    800026f0:	85ca                	mv	a1,s2
    800026f2:	7d28                	ld	a0,120(a0)
    800026f4:	fffff097          	auipc	ra,0xfffff
    800026f8:	fd6080e7          	jalr	-42(ra) # 800016ca <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800026fc:	70a2                	ld	ra,40(sp)
    800026fe:	7402                	ld	s0,32(sp)
    80002700:	64e2                	ld	s1,24(sp)
    80002702:	6942                	ld	s2,16(sp)
    80002704:	69a2                	ld	s3,8(sp)
    80002706:	6a02                	ld	s4,0(sp)
    80002708:	6145                	addi	sp,sp,48
    8000270a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000270c:	000a061b          	sext.w	a2,s4
    80002710:	85ce                	mv	a1,s3
    80002712:	854a                	mv	a0,s2
    80002714:	ffffe097          	auipc	ra,0xffffe
    80002718:	606080e7          	jalr	1542(ra) # 80000d1a <memmove>
    return 0;
    8000271c:	8526                	mv	a0,s1
    8000271e:	bff9                	j	800026fc <either_copyin+0x32>

0000000080002720 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002720:	715d                	addi	sp,sp,-80
    80002722:	e486                	sd	ra,72(sp)
    80002724:	e0a2                	sd	s0,64(sp)
    80002726:	fc26                	sd	s1,56(sp)
    80002728:	f84a                	sd	s2,48(sp)
    8000272a:	f44e                	sd	s3,40(sp)
    8000272c:	f052                	sd	s4,32(sp)
    8000272e:	ec56                	sd	s5,24(sp)
    80002730:	e85a                	sd	s6,16(sp)
    80002732:	e45e                	sd	s7,8(sp)
    80002734:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002736:	00006517          	auipc	a0,0x6
    8000273a:	99250513          	addi	a0,a0,-1646 # 800080c8 <digits+0x88>
    8000273e:	ffffe097          	auipc	ra,0xffffe
    80002742:	e36080e7          	jalr	-458(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002746:	0000f497          	auipc	s1,0xf
    8000274a:	10a48493          	addi	s1,s1,266 # 80011850 <proc+0x180>
    8000274e:	00015917          	auipc	s2,0x15
    80002752:	50290913          	addi	s2,s2,1282 # 80017c50 <bcache+0x168>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002756:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002758:	00006997          	auipc	s3,0x6
    8000275c:	b3898993          	addi	s3,s3,-1224 # 80008290 <digits+0x250>
    printf("%d %s %s", p->pid, state, p->name);
    80002760:	00006a97          	auipc	s5,0x6
    80002764:	b38a8a93          	addi	s5,s5,-1224 # 80008298 <digits+0x258>
    printf("\n");
    80002768:	00006a17          	auipc	s4,0x6
    8000276c:	960a0a13          	addi	s4,s4,-1696 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002770:	00006b97          	auipc	s7,0x6
    80002774:	b60b8b93          	addi	s7,s7,-1184 # 800082d0 <states.0>
    80002778:	a00d                	j	8000279a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000277a:	eb06a583          	lw	a1,-336(a3)
    8000277e:	8556                	mv	a0,s5
    80002780:	ffffe097          	auipc	ra,0xffffe
    80002784:	df4080e7          	jalr	-524(ra) # 80000574 <printf>
    printf("\n");
    80002788:	8552                	mv	a0,s4
    8000278a:	ffffe097          	auipc	ra,0xffffe
    8000278e:	dea080e7          	jalr	-534(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002792:	19048493          	addi	s1,s1,400
    80002796:	03248263          	beq	s1,s2,800027ba <procdump+0x9a>
    if(p->state == UNUSED)
    8000279a:	86a6                	mv	a3,s1
    8000279c:	e984a783          	lw	a5,-360(s1)
    800027a0:	dbed                	beqz	a5,80002792 <procdump+0x72>
      state = "???";
    800027a2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027a4:	fcfb6be3          	bltu	s6,a5,8000277a <procdump+0x5a>
    800027a8:	02079713          	slli	a4,a5,0x20
    800027ac:	01d75793          	srli	a5,a4,0x1d
    800027b0:	97de                	add	a5,a5,s7
    800027b2:	6390                	ld	a2,0(a5)
    800027b4:	f279                	bnez	a2,8000277a <procdump+0x5a>
      state = "???";
    800027b6:	864e                	mv	a2,s3
    800027b8:	b7c9                	j	8000277a <procdump+0x5a>
  }
}
    800027ba:	60a6                	ld	ra,72(sp)
    800027bc:	6406                	ld	s0,64(sp)
    800027be:	74e2                	ld	s1,56(sp)
    800027c0:	7942                	ld	s2,48(sp)
    800027c2:	79a2                	ld	s3,40(sp)
    800027c4:	7a02                	ld	s4,32(sp)
    800027c6:	6ae2                	ld	s5,24(sp)
    800027c8:	6b42                	ld	s6,16(sp)
    800027ca:	6ba2                	ld	s7,8(sp)
    800027cc:	6161                	addi	sp,sp,80
    800027ce:	8082                	ret

00000000800027d0 <trace>:

// Changes the Trace bit mask for proccess with input pid
// Trace mask determines which system calls will be traced
int
trace(int mask, int pid){
    800027d0:	7179                	addi	sp,sp,-48
    800027d2:	f406                	sd	ra,40(sp)
    800027d4:	f022                	sd	s0,32(sp)
    800027d6:	ec26                	sd	s1,24(sp)
    800027d8:	e84a                	sd	s2,16(sp)
    800027da:	e44e                	sd	s3,8(sp)
    800027dc:	e052                	sd	s4,0(sp)
    800027de:	1800                	addi	s0,sp,48
    800027e0:	8a2a                	mv	s4,a0
    800027e2:	892e                	mv	s2,a1
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800027e4:	0000f497          	auipc	s1,0xf
    800027e8:	eec48493          	addi	s1,s1,-276 # 800116d0 <proc>
    800027ec:	00015997          	auipc	s3,0x15
    800027f0:	2e498993          	addi	s3,s3,740 # 80017ad0 <tickslock>
    acquire(&p->lock);
    800027f4:	8526                	mv	a0,s1
    800027f6:	ffffe097          	auipc	ra,0xffffe
    800027fa:	3cc080e7          	jalr	972(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    800027fe:	589c                	lw	a5,48(s1)
    80002800:	01278d63          	beq	a5,s2,8000281a <trace+0x4a>
      p->tracemask = mask;
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002804:	8526                	mv	a0,s1
    80002806:	ffffe097          	auipc	ra,0xffffe
    8000280a:	470080e7          	jalr	1136(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000280e:	19048493          	addi	s1,s1,400
    80002812:	ff3491e3          	bne	s1,s3,800027f4 <trace+0x24>
  }
  return -1;
    80002816:	557d                	li	a0,-1
    80002818:	a809                	j	8000282a <trace+0x5a>
      p->tracemask = mask;
    8000281a:	0344aa23          	sw	s4,52(s1)
      release(&p->lock);
    8000281e:	8526                	mv	a0,s1
    80002820:	ffffe097          	auipc	ra,0xffffe
    80002824:	456080e7          	jalr	1110(ra) # 80000c76 <release>
      return 0;
    80002828:	4501                	li	a0,0
}
    8000282a:	70a2                	ld	ra,40(sp)
    8000282c:	7402                	ld	s0,32(sp)
    8000282e:	64e2                	ld	s1,24(sp)
    80002830:	6942                	ld	s2,16(sp)
    80002832:	69a2                	ld	s3,8(sp)
    80002834:	6a02                	ld	s4,0(sp)
    80002836:	6145                	addi	sp,sp,48
    80002838:	8082                	ret

000000008000283a <wait_stat>:

int
wait_stat(uint64 stat_addr, uint64 perf_addr){// ass1 
    8000283a:	7119                	addi	sp,sp,-128
    8000283c:	fc86                	sd	ra,120(sp)
    8000283e:	f8a2                	sd	s0,112(sp)
    80002840:	f4a6                	sd	s1,104(sp)
    80002842:	f0ca                	sd	s2,96(sp)
    80002844:	ecce                	sd	s3,88(sp)
    80002846:	e8d2                	sd	s4,80(sp)
    80002848:	e4d6                	sd	s5,72(sp)
    8000284a:	e0da                	sd	s6,64(sp)
    8000284c:	fc5e                	sd	s7,56(sp)
    8000284e:	f862                	sd	s8,48(sp)
    80002850:	f466                	sd	s9,40(sp)
    80002852:	0100                	addi	s0,sp,128
    80002854:	8b2a                	mv	s6,a0
    80002856:	8bae                	mv	s7,a1
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    80002858:	fffff097          	auipc	ra,0xfffff
    8000285c:	126080e7          	jalr	294(ra) # 8000197e <myproc>
    80002860:	892a                	mv	s2,a0
  struct perf child_perf;
  acquire(&wait_lock);
    80002862:	0000f517          	auipc	a0,0xf
    80002866:	a5650513          	addi	a0,a0,-1450 # 800112b8 <wait_lock>
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	358080e7          	jalr	856(ra) # 80000bc2 <acquire>
  
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    80002872:	4c01                	li	s8,0
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){ 
    80002874:	4a15                	li	s4,5
        havekids = 1;
    80002876:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002878:	00015997          	auipc	s3,0x15
    8000287c:	25898993          	addi	s3,s3,600 # 80017ad0 <tickslock>
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002880:	0000fc97          	auipc	s9,0xf
    80002884:	a38c8c93          	addi	s9,s9,-1480 # 800112b8 <wait_lock>
    havekids = 0;
    80002888:	8762                	mv	a4,s8
    for(np = proc; np < &proc[NPROC]; np++){
    8000288a:	0000f497          	auipc	s1,0xf
    8000288e:	e4648493          	addi	s1,s1,-442 # 800116d0 <proc>
    80002892:	a861                	j	8000292a <wait_stat+0xf0>
          pid = np->pid;
    80002894:	0304a983          	lw	s3,48(s1)
          perfi(np, &child_perf);
    80002898:	f8840593          	addi	a1,s0,-120
    8000289c:	8526                	mv	a0,s1
    8000289e:	fffff097          	auipc	ra,0xfffff
    800028a2:	4e8080e7          	jalr	1256(ra) # 80001d86 <perfi>
          if(stat_addr != 0 && perf_addr != 0 && 
    800028a6:	000b0463          	beqz	s6,800028ae <wait_stat+0x74>
    800028aa:	020b9563          	bnez	s7,800028d4 <wait_stat+0x9a>
          freeproc(np);
    800028ae:	8526                	mv	a0,s1
    800028b0:	fffff097          	auipc	ra,0xfffff
    800028b4:	280080e7          	jalr	640(ra) # 80001b30 <freeproc>
          release(&np->lock);
    800028b8:	8526                	mv	a0,s1
    800028ba:	ffffe097          	auipc	ra,0xffffe
    800028be:	3bc080e7          	jalr	956(ra) # 80000c76 <release>
          release(&wait_lock);
    800028c2:	0000f517          	auipc	a0,0xf
    800028c6:	9f650513          	addi	a0,a0,-1546 # 800112b8 <wait_lock>
    800028ca:	ffffe097          	auipc	ra,0xffffe
    800028ce:	3ac080e7          	jalr	940(ra) # 80000c76 <release>
          return pid;
    800028d2:	a859                	j	80002968 <wait_stat+0x12e>
            ((copyout(p->pagetable, stat_addr, (char *)&np->xstate,sizeof(np->xstate)) < 0) ||
    800028d4:	4691                	li	a3,4
    800028d6:	02c48613          	addi	a2,s1,44
    800028da:	85da                	mv	a1,s6
    800028dc:	07893503          	ld	a0,120(s2)
    800028e0:	fffff097          	auipc	ra,0xfffff
    800028e4:	d5e080e7          	jalr	-674(ra) # 8000163e <copyout>
          if(stat_addr != 0 && perf_addr != 0 && 
    800028e8:	00054e63          	bltz	a0,80002904 <wait_stat+0xca>
            (copyout(p->pagetable, perf_addr, (char *)&child_perf, sizeof(child_perf)) < 0))){
    800028ec:	46e1                	li	a3,24
    800028ee:	f8840613          	addi	a2,s0,-120
    800028f2:	85de                	mv	a1,s7
    800028f4:	07893503          	ld	a0,120(s2)
    800028f8:	fffff097          	auipc	ra,0xfffff
    800028fc:	d46080e7          	jalr	-698(ra) # 8000163e <copyout>
            ((copyout(p->pagetable, stat_addr, (char *)&np->xstate,sizeof(np->xstate)) < 0) ||
    80002900:	fa0557e3          	bgez	a0,800028ae <wait_stat+0x74>
            release(&np->lock);
    80002904:	8526                	mv	a0,s1
    80002906:	ffffe097          	auipc	ra,0xffffe
    8000290a:	370080e7          	jalr	880(ra) # 80000c76 <release>
            release(&wait_lock);
    8000290e:	0000f517          	auipc	a0,0xf
    80002912:	9aa50513          	addi	a0,a0,-1622 # 800112b8 <wait_lock>
    80002916:	ffffe097          	auipc	ra,0xffffe
    8000291a:	360080e7          	jalr	864(ra) # 80000c76 <release>
            return -1;
    8000291e:	59fd                	li	s3,-1
    80002920:	a0a1                	j	80002968 <wait_stat+0x12e>
    for(np = proc; np < &proc[NPROC]; np++){
    80002922:	19048493          	addi	s1,s1,400
    80002926:	03348463          	beq	s1,s3,8000294e <wait_stat+0x114>
      if(np->parent == p){
    8000292a:	70bc                	ld	a5,96(s1)
    8000292c:	ff279be3          	bne	a5,s2,80002922 <wait_stat+0xe8>
        acquire(&np->lock);
    80002930:	8526                	mv	a0,s1
    80002932:	ffffe097          	auipc	ra,0xffffe
    80002936:	290080e7          	jalr	656(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){ 
    8000293a:	4c9c                	lw	a5,24(s1)
    8000293c:	f5478ce3          	beq	a5,s4,80002894 <wait_stat+0x5a>
        release(&np->lock);
    80002940:	8526                	mv	a0,s1
    80002942:	ffffe097          	auipc	ra,0xffffe
    80002946:	334080e7          	jalr	820(ra) # 80000c76 <release>
        havekids = 1;
    8000294a:	8756                	mv	a4,s5
    8000294c:	bfd9                	j	80002922 <wait_stat+0xe8>
    if(!havekids || p->killed){
    8000294e:	c701                	beqz	a4,80002956 <wait_stat+0x11c>
    80002950:	02892783          	lw	a5,40(s2)
    80002954:	cb85                	beqz	a5,80002984 <wait_stat+0x14a>
      release(&wait_lock);
    80002956:	0000f517          	auipc	a0,0xf
    8000295a:	96250513          	addi	a0,a0,-1694 # 800112b8 <wait_lock>
    8000295e:	ffffe097          	auipc	ra,0xffffe
    80002962:	318080e7          	jalr	792(ra) # 80000c76 <release>
      return -1;
    80002966:	59fd                	li	s3,-1
  }

}
    80002968:	854e                	mv	a0,s3
    8000296a:	70e6                	ld	ra,120(sp)
    8000296c:	7446                	ld	s0,112(sp)
    8000296e:	74a6                	ld	s1,104(sp)
    80002970:	7906                	ld	s2,96(sp)
    80002972:	69e6                	ld	s3,88(sp)
    80002974:	6a46                	ld	s4,80(sp)
    80002976:	6aa6                	ld	s5,72(sp)
    80002978:	6b06                	ld	s6,64(sp)
    8000297a:	7be2                	ld	s7,56(sp)
    8000297c:	7c42                	ld	s8,48(sp)
    8000297e:	7ca2                	ld	s9,40(sp)
    80002980:	6109                	addi	sp,sp,128
    80002982:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002984:	85e6                	mv	a1,s9
    80002986:	854a                	mv	a0,s2
    80002988:	00000097          	auipc	ra,0x0
    8000298c:	920080e7          	jalr	-1760(ra) # 800022a8 <sleep>
    havekids = 0;
    80002990:	bde5                	j	80002888 <wait_stat+0x4e>

0000000080002992 <update_times>:

void
update_times(){
    80002992:	7139                	addi	sp,sp,-64
    80002994:	fc06                	sd	ra,56(sp)
    80002996:	f822                	sd	s0,48(sp)
    80002998:	f426                	sd	s1,40(sp)
    8000299a:	f04a                	sd	s2,32(sp)
    8000299c:	ec4e                	sd	s3,24(sp)
    8000299e:	e852                	sd	s4,16(sp)
    800029a0:	e456                	sd	s5,8(sp)
    800029a2:	0080                	addi	s0,sp,64
    struct proc *np;

    for(np = proc; np < &proc[NPROC]; np++){
    800029a4:	0000f497          	auipc	s1,0xf
    800029a8:	d2c48493          	addi	s1,s1,-724 # 800116d0 <proc>
      acquire(&np->lock);
      switch (np->state)
    800029ac:	4a8d                	li	s5,3
    800029ae:	4a11                	li	s4,4
    800029b0:	4989                	li	s3,2
    for(np = proc; np < &proc[NPROC]; np++){
    800029b2:	00015917          	auipc	s2,0x15
    800029b6:	11e90913          	addi	s2,s2,286 # 80017ad0 <tickslock>
    800029ba:	a829                	j	800029d4 <update_times+0x42>
      {
      case SLEEPING:
        np->stime++;
        break;
      case RUNNABLE:
        np->retime++;
    800029bc:	40fc                	lw	a5,68(s1)
    800029be:	2785                	addiw	a5,a5,1
    800029c0:	c0fc                	sw	a5,68(s1)
        np->rutime++;
        break;
      default:
        break;
      }
    release(&np->lock);
    800029c2:	8526                	mv	a0,s1
    800029c4:	ffffe097          	auipc	ra,0xffffe
    800029c8:	2b2080e7          	jalr	690(ra) # 80000c76 <release>
    for(np = proc; np < &proc[NPROC]; np++){
    800029cc:	19048493          	addi	s1,s1,400
    800029d0:	03248963          	beq	s1,s2,80002a02 <update_times+0x70>
      acquire(&np->lock);
    800029d4:	8526                	mv	a0,s1
    800029d6:	ffffe097          	auipc	ra,0xffffe
    800029da:	1ec080e7          	jalr	492(ra) # 80000bc2 <acquire>
      switch (np->state)
    800029de:	4c9c                	lw	a5,24(s1)
    800029e0:	fd578ee3          	beq	a5,s5,800029bc <update_times+0x2a>
    800029e4:	01478863          	beq	a5,s4,800029f4 <update_times+0x62>
    800029e8:	fd379de3          	bne	a5,s3,800029c2 <update_times+0x30>
        np->stime++;
    800029ec:	40bc                	lw	a5,64(s1)
    800029ee:	2785                	addiw	a5,a5,1
    800029f0:	c0bc                	sw	a5,64(s1)
        break;
    800029f2:	bfc1                	j	800029c2 <update_times+0x30>
        np->current_runtime++;
    800029f4:	48fc                	lw	a5,84(s1)
    800029f6:	2785                	addiw	a5,a5,1
    800029f8:	c8fc                	sw	a5,84(s1)
        np->rutime++;
    800029fa:	44bc                	lw	a5,72(s1)
    800029fc:	2785                	addiw	a5,a5,1
    800029fe:	c4bc                	sw	a5,72(s1)
        break;
    80002a00:	b7c9                	j	800029c2 <update_times+0x30>
    } 
}
    80002a02:	70e2                	ld	ra,56(sp)
    80002a04:	7442                	ld	s0,48(sp)
    80002a06:	74a2                	ld	s1,40(sp)
    80002a08:	7902                	ld	s2,32(sp)
    80002a0a:	69e2                	ld	s3,24(sp)
    80002a0c:	6a42                	ld	s4,16(sp)
    80002a0e:	6aa2                	ld	s5,8(sp)
    80002a10:	6121                	addi	sp,sp,64
    80002a12:	8082                	ret

0000000080002a14 <set_priority>:

int
set_priority(int priority){
    80002a14:	7139                	addi	sp,sp,-64
    80002a16:	fc06                	sd	ra,56(sp)
    80002a18:	f822                	sd	s0,48(sp)
    80002a1a:	f426                	sd	s1,40(sp)
    80002a1c:	f04a                	sd	s2,32(sp)
    80002a1e:	0080                	addi	s0,sp,64
    80002a20:	84aa                	mv	s1,a0
  struct proc *p = myproc();   
    80002a22:	fffff097          	auipc	ra,0xfffff
    80002a26:	f5c080e7          	jalr	-164(ra) # 8000197e <myproc>
  int priority_to_decay[5] = {1,3,5,7,25};
    80002a2a:	4785                	li	a5,1
    80002a2c:	fcf42423          	sw	a5,-56(s0)
    80002a30:	478d                	li	a5,3
    80002a32:	fcf42623          	sw	a5,-52(s0)
    80002a36:	4795                	li	a5,5
    80002a38:	fcf42823          	sw	a5,-48(s0)
    80002a3c:	479d                	li	a5,7
    80002a3e:	fcf42a23          	sw	a5,-44(s0)
    80002a42:	47e5                	li	a5,25
    80002a44:	fcf42c23          	sw	a5,-40(s0)

  if(priority < 1 || priority > 5)
    80002a48:	fff4871b          	addiw	a4,s1,-1
    80002a4c:	4791                	li	a5,4
    80002a4e:	02e7ec63          	bltu	a5,a4,80002a86 <set_priority+0x72>
    80002a52:	892a                	mv	s2,a0
    return -1;

  acquire(&p->lock);
    80002a54:	ffffe097          	auipc	ra,0xffffe
    80002a58:	16e080e7          	jalr	366(ra) # 80000bc2 <acquire>
  p->decay_factor=priority_to_decay[priority-1];
    80002a5c:	34fd                	addiw	s1,s1,-1
    80002a5e:	048a                	slli	s1,s1,0x2
    80002a60:	fe040793          	addi	a5,s0,-32
    80002a64:	94be                	add	s1,s1,a5
    80002a66:	fe84a783          	lw	a5,-24(s1)
    80002a6a:	04f92823          	sw	a5,80(s2)
  release(&p->lock); 
    80002a6e:	854a                	mv	a0,s2
    80002a70:	ffffe097          	auipc	ra,0xffffe
    80002a74:	206080e7          	jalr	518(ra) # 80000c76 <release>

  return 0;
    80002a78:	4501                	li	a0,0
}
    80002a7a:	70e2                	ld	ra,56(sp)
    80002a7c:	7442                	ld	s0,48(sp)
    80002a7e:	74a2                	ld	s1,40(sp)
    80002a80:	7902                	ld	s2,32(sp)
    80002a82:	6121                	addi	sp,sp,64
    80002a84:	8082                	ret
    return -1;
    80002a86:	557d                	li	a0,-1
    80002a88:	bfcd                	j	80002a7a <set_priority+0x66>

0000000080002a8a <swtch>:
    80002a8a:	00153023          	sd	ra,0(a0)
    80002a8e:	00253423          	sd	sp,8(a0)
    80002a92:	e900                	sd	s0,16(a0)
    80002a94:	ed04                	sd	s1,24(a0)
    80002a96:	03253023          	sd	s2,32(a0)
    80002a9a:	03353423          	sd	s3,40(a0)
    80002a9e:	03453823          	sd	s4,48(a0)
    80002aa2:	03553c23          	sd	s5,56(a0)
    80002aa6:	05653023          	sd	s6,64(a0)
    80002aaa:	05753423          	sd	s7,72(a0)
    80002aae:	05853823          	sd	s8,80(a0)
    80002ab2:	05953c23          	sd	s9,88(a0)
    80002ab6:	07a53023          	sd	s10,96(a0)
    80002aba:	07b53423          	sd	s11,104(a0)
    80002abe:	0005b083          	ld	ra,0(a1)
    80002ac2:	0085b103          	ld	sp,8(a1)
    80002ac6:	6980                	ld	s0,16(a1)
    80002ac8:	6d84                	ld	s1,24(a1)
    80002aca:	0205b903          	ld	s2,32(a1)
    80002ace:	0285b983          	ld	s3,40(a1)
    80002ad2:	0305ba03          	ld	s4,48(a1)
    80002ad6:	0385ba83          	ld	s5,56(a1)
    80002ada:	0405bb03          	ld	s6,64(a1)
    80002ade:	0485bb83          	ld	s7,72(a1)
    80002ae2:	0505bc03          	ld	s8,80(a1)
    80002ae6:	0585bc83          	ld	s9,88(a1)
    80002aea:	0605bd03          	ld	s10,96(a1)
    80002aee:	0685bd83          	ld	s11,104(a1)
    80002af2:	8082                	ret

0000000080002af4 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002af4:	1141                	addi	sp,sp,-16
    80002af6:	e406                	sd	ra,8(sp)
    80002af8:	e022                	sd	s0,0(sp)
    80002afa:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002afc:	00006597          	auipc	a1,0x6
    80002b00:	80458593          	addi	a1,a1,-2044 # 80008300 <states.0+0x30>
    80002b04:	00015517          	auipc	a0,0x15
    80002b08:	fcc50513          	addi	a0,a0,-52 # 80017ad0 <tickslock>
    80002b0c:	ffffe097          	auipc	ra,0xffffe
    80002b10:	026080e7          	jalr	38(ra) # 80000b32 <initlock>
}
    80002b14:	60a2                	ld	ra,8(sp)
    80002b16:	6402                	ld	s0,0(sp)
    80002b18:	0141                	addi	sp,sp,16
    80002b1a:	8082                	ret

0000000080002b1c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002b1c:	1141                	addi	sp,sp,-16
    80002b1e:	e422                	sd	s0,8(sp)
    80002b20:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b22:	00003797          	auipc	a5,0x3
    80002b26:	64e78793          	addi	a5,a5,1614 # 80006170 <kernelvec>
    80002b2a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002b2e:	6422                	ld	s0,8(sp)
    80002b30:	0141                	addi	sp,sp,16
    80002b32:	8082                	ret

0000000080002b34 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002b34:	1141                	addi	sp,sp,-16
    80002b36:	e406                	sd	ra,8(sp)
    80002b38:	e022                	sd	s0,0(sp)
    80002b3a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b3c:	fffff097          	auipc	ra,0xfffff
    80002b40:	e42080e7          	jalr	-446(ra) # 8000197e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b44:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b48:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b4a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002b4e:	00004617          	auipc	a2,0x4
    80002b52:	4b260613          	addi	a2,a2,1202 # 80007000 <_trampoline>
    80002b56:	00004697          	auipc	a3,0x4
    80002b5a:	4aa68693          	addi	a3,a3,1194 # 80007000 <_trampoline>
    80002b5e:	8e91                	sub	a3,a3,a2
    80002b60:	040007b7          	lui	a5,0x4000
    80002b64:	17fd                	addi	a5,a5,-1
    80002b66:	07b2                	slli	a5,a5,0xc
    80002b68:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b6a:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b6e:	6158                	ld	a4,128(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b70:	180026f3          	csrr	a3,satp
    80002b74:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b76:	6158                	ld	a4,128(a0)
    80002b78:	7534                	ld	a3,104(a0)
    80002b7a:	6585                	lui	a1,0x1
    80002b7c:	96ae                	add	a3,a3,a1
    80002b7e:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b80:	6158                	ld	a4,128(a0)
    80002b82:	00000697          	auipc	a3,0x0
    80002b86:	14668693          	addi	a3,a3,326 # 80002cc8 <usertrap>
    80002b8a:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b8c:	6158                	ld	a4,128(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b8e:	8692                	mv	a3,tp
    80002b90:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b92:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b96:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b9a:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b9e:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002ba2:	6158                	ld	a4,128(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ba4:	6f18                	ld	a4,24(a4)
    80002ba6:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002baa:	7d2c                	ld	a1,120(a0)
    80002bac:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002bae:	00004717          	auipc	a4,0x4
    80002bb2:	4e270713          	addi	a4,a4,1250 # 80007090 <userret>
    80002bb6:	8f11                	sub	a4,a4,a2
    80002bb8:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002bba:	577d                	li	a4,-1
    80002bbc:	177e                	slli	a4,a4,0x3f
    80002bbe:	8dd9                	or	a1,a1,a4
    80002bc0:	02000537          	lui	a0,0x2000
    80002bc4:	157d                	addi	a0,a0,-1
    80002bc6:	0536                	slli	a0,a0,0xd
    80002bc8:	9782                	jalr	a5
}
    80002bca:	60a2                	ld	ra,8(sp)
    80002bcc:	6402                	ld	s0,0(sp)
    80002bce:	0141                	addi	sp,sp,16
    80002bd0:	8082                	ret

0000000080002bd2 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002bd2:	1101                	addi	sp,sp,-32
    80002bd4:	ec06                	sd	ra,24(sp)
    80002bd6:	e822                	sd	s0,16(sp)
    80002bd8:	e426                	sd	s1,8(sp)
    80002bda:	e04a                	sd	s2,0(sp)
    80002bdc:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002bde:	00015917          	auipc	s2,0x15
    80002be2:	ef290913          	addi	s2,s2,-270 # 80017ad0 <tickslock>
    80002be6:	854a                	mv	a0,s2
    80002be8:	ffffe097          	auipc	ra,0xffffe
    80002bec:	fda080e7          	jalr	-38(ra) # 80000bc2 <acquire>
  ticks++;
    80002bf0:	00006497          	auipc	s1,0x6
    80002bf4:	44048493          	addi	s1,s1,1088 # 80009030 <ticks>
    80002bf8:	409c                	lw	a5,0(s1)
    80002bfa:	2785                	addiw	a5,a5,1
    80002bfc:	c09c                	sw	a5,0(s1)
  update_times();
    80002bfe:	00000097          	auipc	ra,0x0
    80002c02:	d94080e7          	jalr	-620(ra) # 80002992 <update_times>
  wakeup(&ticks);
    80002c06:	8526                	mv	a0,s1
    80002c08:	00000097          	auipc	ra,0x0
    80002c0c:	82c080e7          	jalr	-2004(ra) # 80002434 <wakeup>
  release(&tickslock);
    80002c10:	854a                	mv	a0,s2
    80002c12:	ffffe097          	auipc	ra,0xffffe
    80002c16:	064080e7          	jalr	100(ra) # 80000c76 <release>
}
    80002c1a:	60e2                	ld	ra,24(sp)
    80002c1c:	6442                	ld	s0,16(sp)
    80002c1e:	64a2                	ld	s1,8(sp)
    80002c20:	6902                	ld	s2,0(sp)
    80002c22:	6105                	addi	sp,sp,32
    80002c24:	8082                	ret

0000000080002c26 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002c26:	1101                	addi	sp,sp,-32
    80002c28:	ec06                	sd	ra,24(sp)
    80002c2a:	e822                	sd	s0,16(sp)
    80002c2c:	e426                	sd	s1,8(sp)
    80002c2e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c30:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002c34:	00074d63          	bltz	a4,80002c4e <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002c38:	57fd                	li	a5,-1
    80002c3a:	17fe                	slli	a5,a5,0x3f
    80002c3c:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002c3e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002c40:	06f70363          	beq	a4,a5,80002ca6 <devintr+0x80>
  }
}
    80002c44:	60e2                	ld	ra,24(sp)
    80002c46:	6442                	ld	s0,16(sp)
    80002c48:	64a2                	ld	s1,8(sp)
    80002c4a:	6105                	addi	sp,sp,32
    80002c4c:	8082                	ret
     (scause & 0xff) == 9){
    80002c4e:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002c52:	46a5                	li	a3,9
    80002c54:	fed792e3          	bne	a5,a3,80002c38 <devintr+0x12>
    int irq = plic_claim();
    80002c58:	00003097          	auipc	ra,0x3
    80002c5c:	620080e7          	jalr	1568(ra) # 80006278 <plic_claim>
    80002c60:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002c62:	47a9                	li	a5,10
    80002c64:	02f50763          	beq	a0,a5,80002c92 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002c68:	4785                	li	a5,1
    80002c6a:	02f50963          	beq	a0,a5,80002c9c <devintr+0x76>
    return 1;
    80002c6e:	4505                	li	a0,1
    } else if(irq){
    80002c70:	d8f1                	beqz	s1,80002c44 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c72:	85a6                	mv	a1,s1
    80002c74:	00005517          	auipc	a0,0x5
    80002c78:	69450513          	addi	a0,a0,1684 # 80008308 <states.0+0x38>
    80002c7c:	ffffe097          	auipc	ra,0xffffe
    80002c80:	8f8080e7          	jalr	-1800(ra) # 80000574 <printf>
      plic_complete(irq);
    80002c84:	8526                	mv	a0,s1
    80002c86:	00003097          	auipc	ra,0x3
    80002c8a:	616080e7          	jalr	1558(ra) # 8000629c <plic_complete>
    return 1;
    80002c8e:	4505                	li	a0,1
    80002c90:	bf55                	j	80002c44 <devintr+0x1e>
      uartintr();
    80002c92:	ffffe097          	auipc	ra,0xffffe
    80002c96:	cf4080e7          	jalr	-780(ra) # 80000986 <uartintr>
    80002c9a:	b7ed                	j	80002c84 <devintr+0x5e>
      virtio_disk_intr();
    80002c9c:	00004097          	auipc	ra,0x4
    80002ca0:	a92080e7          	jalr	-1390(ra) # 8000672e <virtio_disk_intr>
    80002ca4:	b7c5                	j	80002c84 <devintr+0x5e>
    if(cpuid() == 0){
    80002ca6:	fffff097          	auipc	ra,0xfffff
    80002caa:	cac080e7          	jalr	-852(ra) # 80001952 <cpuid>
    80002cae:	c901                	beqz	a0,80002cbe <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002cb0:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002cb4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002cb6:	14479073          	csrw	sip,a5
    return 2;
    80002cba:	4509                	li	a0,2
    80002cbc:	b761                	j	80002c44 <devintr+0x1e>
      clockintr();
    80002cbe:	00000097          	auipc	ra,0x0
    80002cc2:	f14080e7          	jalr	-236(ra) # 80002bd2 <clockintr>
    80002cc6:	b7ed                	j	80002cb0 <devintr+0x8a>

0000000080002cc8 <usertrap>:
{
    80002cc8:	1101                	addi	sp,sp,-32
    80002cca:	ec06                	sd	ra,24(sp)
    80002ccc:	e822                	sd	s0,16(sp)
    80002cce:	e426                	sd	s1,8(sp)
    80002cd0:	e04a                	sd	s2,0(sp)
    80002cd2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cd4:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002cd8:	1007f793          	andi	a5,a5,256
    80002cdc:	e3ad                	bnez	a5,80002d3e <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cde:	00003797          	auipc	a5,0x3
    80002ce2:	49278793          	addi	a5,a5,1170 # 80006170 <kernelvec>
    80002ce6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002cea:	fffff097          	auipc	ra,0xfffff
    80002cee:	c94080e7          	jalr	-876(ra) # 8000197e <myproc>
    80002cf2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002cf4:	615c                	ld	a5,128(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cf6:	14102773          	csrr	a4,sepc
    80002cfa:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cfc:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002d00:	47a1                	li	a5,8
    80002d02:	04f71c63          	bne	a4,a5,80002d5a <usertrap+0x92>
    if(p->killed)
    80002d06:	551c                	lw	a5,40(a0)
    80002d08:	e3b9                	bnez	a5,80002d4e <usertrap+0x86>
    p->trapframe->epc += 4;
    80002d0a:	60d8                	ld	a4,128(s1)
    80002d0c:	6f1c                	ld	a5,24(a4)
    80002d0e:	0791                	addi	a5,a5,4
    80002d10:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d12:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d16:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d1a:	10079073          	csrw	sstatus,a5
    syscall();
    80002d1e:	00000097          	auipc	ra,0x0
    80002d22:	380080e7          	jalr	896(ra) # 8000309e <syscall>
  if(p->killed)
    80002d26:	549c                	lw	a5,40(s1)
    80002d28:	e3dd                	bnez	a5,80002dce <usertrap+0x106>
  usertrapret();
    80002d2a:	00000097          	auipc	ra,0x0
    80002d2e:	e0a080e7          	jalr	-502(ra) # 80002b34 <usertrapret>
}
    80002d32:	60e2                	ld	ra,24(sp)
    80002d34:	6442                	ld	s0,16(sp)
    80002d36:	64a2                	ld	s1,8(sp)
    80002d38:	6902                	ld	s2,0(sp)
    80002d3a:	6105                	addi	sp,sp,32
    80002d3c:	8082                	ret
    panic("usertrap: not from user mode");
    80002d3e:	00005517          	auipc	a0,0x5
    80002d42:	5ea50513          	addi	a0,a0,1514 # 80008328 <states.0+0x58>
    80002d46:	ffffd097          	auipc	ra,0xffffd
    80002d4a:	7e4080e7          	jalr	2020(ra) # 8000052a <panic>
      exit(-1);
    80002d4e:	557d                	li	a0,-1
    80002d50:	fffff097          	auipc	ra,0xfffff
    80002d54:	7c6080e7          	jalr	1990(ra) # 80002516 <exit>
    80002d58:	bf4d                	j	80002d0a <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002d5a:	00000097          	auipc	ra,0x0
    80002d5e:	ecc080e7          	jalr	-308(ra) # 80002c26 <devintr>
    80002d62:	892a                	mv	s2,a0
    80002d64:	c501                	beqz	a0,80002d6c <usertrap+0xa4>
  if(p->killed)
    80002d66:	549c                	lw	a5,40(s1)
    80002d68:	c3a1                	beqz	a5,80002da8 <usertrap+0xe0>
    80002d6a:	a815                	j	80002d9e <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d6c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d70:	5890                	lw	a2,48(s1)
    80002d72:	00005517          	auipc	a0,0x5
    80002d76:	5d650513          	addi	a0,a0,1494 # 80008348 <states.0+0x78>
    80002d7a:	ffffd097          	auipc	ra,0xffffd
    80002d7e:	7fa080e7          	jalr	2042(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d82:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d86:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d8a:	00005517          	auipc	a0,0x5
    80002d8e:	5ee50513          	addi	a0,a0,1518 # 80008378 <states.0+0xa8>
    80002d92:	ffffd097          	auipc	ra,0xffffd
    80002d96:	7e2080e7          	jalr	2018(ra) # 80000574 <printf>
    p->killed = 1;
    80002d9a:	4785                	li	a5,1
    80002d9c:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002d9e:	557d                	li	a0,-1
    80002da0:	fffff097          	auipc	ra,0xfffff
    80002da4:	776080e7          	jalr	1910(ra) # 80002516 <exit>
  if(which_dev == 2 && p->current_runtime >= QUANTUM && is_preemptive==1)
    80002da8:	4789                	li	a5,2
    80002daa:	f8f910e3          	bne	s2,a5,80002d2a <usertrap+0x62>
    80002dae:	48f8                	lw	a4,84(s1)
    80002db0:	4791                	li	a5,4
    80002db2:	f6e7dce3          	bge	a5,a4,80002d2a <usertrap+0x62>
    80002db6:	00006717          	auipc	a4,0x6
    80002dba:	c6e72703          	lw	a4,-914(a4) # 80008a24 <is_preemptive>
    80002dbe:	4785                	li	a5,1
    80002dc0:	f6f715e3          	bne	a4,a5,80002d2a <usertrap+0x62>
    yield();
    80002dc4:	fffff097          	auipc	ra,0xfffff
    80002dc8:	49e080e7          	jalr	1182(ra) # 80002262 <yield>
    80002dcc:	bfb9                	j	80002d2a <usertrap+0x62>
  int which_dev = 0;
    80002dce:	4901                	li	s2,0
    80002dd0:	b7f9                	j	80002d9e <usertrap+0xd6>

0000000080002dd2 <kerneltrap>:
{
    80002dd2:	7179                	addi	sp,sp,-48
    80002dd4:	f406                	sd	ra,40(sp)
    80002dd6:	f022                	sd	s0,32(sp)
    80002dd8:	ec26                	sd	s1,24(sp)
    80002dda:	e84a                	sd	s2,16(sp)
    80002ddc:	e44e                	sd	s3,8(sp)
    80002dde:	e052                	sd	s4,0(sp)
    80002de0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002de2:	141029f3          	csrr	s3,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002de6:	10002973          	csrr	s2,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002dea:	14202a73          	csrr	s4,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002dee:	10097793          	andi	a5,s2,256
    80002df2:	cf95                	beqz	a5,80002e2e <kerneltrap+0x5c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002df4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002df8:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002dfa:	e3b1                	bnez	a5,80002e3e <kerneltrap+0x6c>
  if((which_dev = devintr()) == 0){
    80002dfc:	00000097          	auipc	ra,0x0
    80002e00:	e2a080e7          	jalr	-470(ra) # 80002c26 <devintr>
    80002e04:	84aa                	mv	s1,a0
    80002e06:	c521                	beqz	a0,80002e4e <kerneltrap+0x7c>
  struct proc *p = myproc();
    80002e08:	fffff097          	auipc	ra,0xfffff
    80002e0c:	b76080e7          	jalr	-1162(ra) # 8000197e <myproc>
  if(which_dev == 2 && p != 0 && p->state == RUNNING && p->current_runtime >= QUANTUM && is_preemptive==1)
    80002e10:	4789                	li	a5,2
    80002e12:	06f48b63          	beq	s1,a5,80002e88 <kerneltrap+0xb6>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e16:	14199073          	csrw	sepc,s3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e1a:	10091073          	csrw	sstatus,s2
}
    80002e1e:	70a2                	ld	ra,40(sp)
    80002e20:	7402                	ld	s0,32(sp)
    80002e22:	64e2                	ld	s1,24(sp)
    80002e24:	6942                	ld	s2,16(sp)
    80002e26:	69a2                	ld	s3,8(sp)
    80002e28:	6a02                	ld	s4,0(sp)
    80002e2a:	6145                	addi	sp,sp,48
    80002e2c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002e2e:	00005517          	auipc	a0,0x5
    80002e32:	56a50513          	addi	a0,a0,1386 # 80008398 <states.0+0xc8>
    80002e36:	ffffd097          	auipc	ra,0xffffd
    80002e3a:	6f4080e7          	jalr	1780(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80002e3e:	00005517          	auipc	a0,0x5
    80002e42:	58250513          	addi	a0,a0,1410 # 800083c0 <states.0+0xf0>
    80002e46:	ffffd097          	auipc	ra,0xffffd
    80002e4a:	6e4080e7          	jalr	1764(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80002e4e:	85d2                	mv	a1,s4
    80002e50:	00005517          	auipc	a0,0x5
    80002e54:	59050513          	addi	a0,a0,1424 # 800083e0 <states.0+0x110>
    80002e58:	ffffd097          	auipc	ra,0xffffd
    80002e5c:	71c080e7          	jalr	1820(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e60:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e64:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e68:	00005517          	auipc	a0,0x5
    80002e6c:	58850513          	addi	a0,a0,1416 # 800083f0 <states.0+0x120>
    80002e70:	ffffd097          	auipc	ra,0xffffd
    80002e74:	704080e7          	jalr	1796(ra) # 80000574 <printf>
    panic("kerneltrap");
    80002e78:	00005517          	auipc	a0,0x5
    80002e7c:	59050513          	addi	a0,a0,1424 # 80008408 <states.0+0x138>
    80002e80:	ffffd097          	auipc	ra,0xffffd
    80002e84:	6aa080e7          	jalr	1706(ra) # 8000052a <panic>
  if(which_dev == 2 && p != 0 && p->state == RUNNING && p->current_runtime >= QUANTUM && is_preemptive==1)
    80002e88:	d559                	beqz	a0,80002e16 <kerneltrap+0x44>
    80002e8a:	4d18                	lw	a4,24(a0)
    80002e8c:	4791                	li	a5,4
    80002e8e:	f8f714e3          	bne	a4,a5,80002e16 <kerneltrap+0x44>
    80002e92:	4978                	lw	a4,84(a0)
    80002e94:	f8e7d1e3          	bge	a5,a4,80002e16 <kerneltrap+0x44>
    80002e98:	00006717          	auipc	a4,0x6
    80002e9c:	b8c72703          	lw	a4,-1140(a4) # 80008a24 <is_preemptive>
    80002ea0:	4785                	li	a5,1
    80002ea2:	f6f71ae3          	bne	a4,a5,80002e16 <kerneltrap+0x44>
    yield();
    80002ea6:	fffff097          	auipc	ra,0xfffff
    80002eaa:	3bc080e7          	jalr	956(ra) # 80002262 <yield>
    80002eae:	b7a5                	j	80002e16 <kerneltrap+0x44>

0000000080002eb0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002eb0:	1101                	addi	sp,sp,-32
    80002eb2:	ec06                	sd	ra,24(sp)
    80002eb4:	e822                	sd	s0,16(sp)
    80002eb6:	e426                	sd	s1,8(sp)
    80002eb8:	1000                	addi	s0,sp,32
    80002eba:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ebc:	fffff097          	auipc	ra,0xfffff
    80002ec0:	ac2080e7          	jalr	-1342(ra) # 8000197e <myproc>
  switch (n) {
    80002ec4:	4795                	li	a5,5
    80002ec6:	0497e163          	bltu	a5,s1,80002f08 <argraw+0x58>
    80002eca:	048a                	slli	s1,s1,0x2
    80002ecc:	00005717          	auipc	a4,0x5
    80002ed0:	69470713          	addi	a4,a4,1684 # 80008560 <states.0+0x290>
    80002ed4:	94ba                	add	s1,s1,a4
    80002ed6:	409c                	lw	a5,0(s1)
    80002ed8:	97ba                	add	a5,a5,a4
    80002eda:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002edc:	615c                	ld	a5,128(a0)
    80002ede:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002ee0:	60e2                	ld	ra,24(sp)
    80002ee2:	6442                	ld	s0,16(sp)
    80002ee4:	64a2                	ld	s1,8(sp)
    80002ee6:	6105                	addi	sp,sp,32
    80002ee8:	8082                	ret
    return p->trapframe->a1;
    80002eea:	615c                	ld	a5,128(a0)
    80002eec:	7fa8                	ld	a0,120(a5)
    80002eee:	bfcd                	j	80002ee0 <argraw+0x30>
    return p->trapframe->a2;
    80002ef0:	615c                	ld	a5,128(a0)
    80002ef2:	63c8                	ld	a0,128(a5)
    80002ef4:	b7f5                	j	80002ee0 <argraw+0x30>
    return p->trapframe->a3;
    80002ef6:	615c                	ld	a5,128(a0)
    80002ef8:	67c8                	ld	a0,136(a5)
    80002efa:	b7dd                	j	80002ee0 <argraw+0x30>
    return p->trapframe->a4;
    80002efc:	615c                	ld	a5,128(a0)
    80002efe:	6bc8                	ld	a0,144(a5)
    80002f00:	b7c5                	j	80002ee0 <argraw+0x30>
    return p->trapframe->a5;
    80002f02:	615c                	ld	a5,128(a0)
    80002f04:	6fc8                	ld	a0,152(a5)
    80002f06:	bfe9                	j	80002ee0 <argraw+0x30>
  panic("argraw");
    80002f08:	00005517          	auipc	a0,0x5
    80002f0c:	51050513          	addi	a0,a0,1296 # 80008418 <states.0+0x148>
    80002f10:	ffffd097          	auipc	ra,0xffffd
    80002f14:	61a080e7          	jalr	1562(ra) # 8000052a <panic>

0000000080002f18 <fetchaddr>:
{
    80002f18:	1101                	addi	sp,sp,-32
    80002f1a:	ec06                	sd	ra,24(sp)
    80002f1c:	e822                	sd	s0,16(sp)
    80002f1e:	e426                	sd	s1,8(sp)
    80002f20:	e04a                	sd	s2,0(sp)
    80002f22:	1000                	addi	s0,sp,32
    80002f24:	84aa                	mv	s1,a0
    80002f26:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002f28:	fffff097          	auipc	ra,0xfffff
    80002f2c:	a56080e7          	jalr	-1450(ra) # 8000197e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002f30:	793c                	ld	a5,112(a0)
    80002f32:	02f4f863          	bgeu	s1,a5,80002f62 <fetchaddr+0x4a>
    80002f36:	00848713          	addi	a4,s1,8
    80002f3a:	02e7e663          	bltu	a5,a4,80002f66 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002f3e:	46a1                	li	a3,8
    80002f40:	8626                	mv	a2,s1
    80002f42:	85ca                	mv	a1,s2
    80002f44:	7d28                	ld	a0,120(a0)
    80002f46:	ffffe097          	auipc	ra,0xffffe
    80002f4a:	784080e7          	jalr	1924(ra) # 800016ca <copyin>
    80002f4e:	00a03533          	snez	a0,a0
    80002f52:	40a00533          	neg	a0,a0
}
    80002f56:	60e2                	ld	ra,24(sp)
    80002f58:	6442                	ld	s0,16(sp)
    80002f5a:	64a2                	ld	s1,8(sp)
    80002f5c:	6902                	ld	s2,0(sp)
    80002f5e:	6105                	addi	sp,sp,32
    80002f60:	8082                	ret
    return -1;
    80002f62:	557d                	li	a0,-1
    80002f64:	bfcd                	j	80002f56 <fetchaddr+0x3e>
    80002f66:	557d                	li	a0,-1
    80002f68:	b7fd                	j	80002f56 <fetchaddr+0x3e>

0000000080002f6a <fetchstr>:
{
    80002f6a:	7179                	addi	sp,sp,-48
    80002f6c:	f406                	sd	ra,40(sp)
    80002f6e:	f022                	sd	s0,32(sp)
    80002f70:	ec26                	sd	s1,24(sp)
    80002f72:	e84a                	sd	s2,16(sp)
    80002f74:	e44e                	sd	s3,8(sp)
    80002f76:	1800                	addi	s0,sp,48
    80002f78:	892a                	mv	s2,a0
    80002f7a:	84ae                	mv	s1,a1
    80002f7c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002f7e:	fffff097          	auipc	ra,0xfffff
    80002f82:	a00080e7          	jalr	-1536(ra) # 8000197e <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002f86:	86ce                	mv	a3,s3
    80002f88:	864a                	mv	a2,s2
    80002f8a:	85a6                	mv	a1,s1
    80002f8c:	7d28                	ld	a0,120(a0)
    80002f8e:	ffffe097          	auipc	ra,0xffffe
    80002f92:	7ca080e7          	jalr	1994(ra) # 80001758 <copyinstr>
  if(err < 0)
    80002f96:	00054763          	bltz	a0,80002fa4 <fetchstr+0x3a>
  return strlen(buf);
    80002f9a:	8526                	mv	a0,s1
    80002f9c:	ffffe097          	auipc	ra,0xffffe
    80002fa0:	ea6080e7          	jalr	-346(ra) # 80000e42 <strlen>
}
    80002fa4:	70a2                	ld	ra,40(sp)
    80002fa6:	7402                	ld	s0,32(sp)
    80002fa8:	64e2                	ld	s1,24(sp)
    80002faa:	6942                	ld	s2,16(sp)
    80002fac:	69a2                	ld	s3,8(sp)
    80002fae:	6145                	addi	sp,sp,48
    80002fb0:	8082                	ret

0000000080002fb2 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002fb2:	1101                	addi	sp,sp,-32
    80002fb4:	ec06                	sd	ra,24(sp)
    80002fb6:	e822                	sd	s0,16(sp)
    80002fb8:	e426                	sd	s1,8(sp)
    80002fba:	1000                	addi	s0,sp,32
    80002fbc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002fbe:	00000097          	auipc	ra,0x0
    80002fc2:	ef2080e7          	jalr	-270(ra) # 80002eb0 <argraw>
    80002fc6:	c088                	sw	a0,0(s1)
  return 0;
}
    80002fc8:	4501                	li	a0,0
    80002fca:	60e2                	ld	ra,24(sp)
    80002fcc:	6442                	ld	s0,16(sp)
    80002fce:	64a2                	ld	s1,8(sp)
    80002fd0:	6105                	addi	sp,sp,32
    80002fd2:	8082                	ret

0000000080002fd4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002fd4:	1101                	addi	sp,sp,-32
    80002fd6:	ec06                	sd	ra,24(sp)
    80002fd8:	e822                	sd	s0,16(sp)
    80002fda:	e426                	sd	s1,8(sp)
    80002fdc:	1000                	addi	s0,sp,32
    80002fde:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002fe0:	00000097          	auipc	ra,0x0
    80002fe4:	ed0080e7          	jalr	-304(ra) # 80002eb0 <argraw>
    80002fe8:	e088                	sd	a0,0(s1)
  return 0;
}
    80002fea:	4501                	li	a0,0
    80002fec:	60e2                	ld	ra,24(sp)
    80002fee:	6442                	ld	s0,16(sp)
    80002ff0:	64a2                	ld	s1,8(sp)
    80002ff2:	6105                	addi	sp,sp,32
    80002ff4:	8082                	ret

0000000080002ff6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ff6:	1101                	addi	sp,sp,-32
    80002ff8:	ec06                	sd	ra,24(sp)
    80002ffa:	e822                	sd	s0,16(sp)
    80002ffc:	e426                	sd	s1,8(sp)
    80002ffe:	e04a                	sd	s2,0(sp)
    80003000:	1000                	addi	s0,sp,32
    80003002:	84ae                	mv	s1,a1
    80003004:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003006:	00000097          	auipc	ra,0x0
    8000300a:	eaa080e7          	jalr	-342(ra) # 80002eb0 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    8000300e:	864a                	mv	a2,s2
    80003010:	85a6                	mv	a1,s1
    80003012:	00000097          	auipc	ra,0x0
    80003016:	f58080e7          	jalr	-168(ra) # 80002f6a <fetchstr>
}
    8000301a:	60e2                	ld	ra,24(sp)
    8000301c:	6442                	ld	s0,16(sp)
    8000301e:	64a2                	ld	s1,8(sp)
    80003020:	6902                	ld	s2,0(sp)
    80003022:	6105                	addi	sp,sp,32
    80003024:	8082                	ret

0000000080003026 <printtrace>:
[SYS_set_priority] "set_priority",
};


int 
printtrace(int syscallnum,int pid, uint64 ret, int arg){
    80003026:	1141                	addi	sp,sp,-16
    80003028:	e406                	sd	ra,8(sp)
    8000302a:	e022                	sd	s0,0(sp)
    8000302c:	0800                	addi	s0,sp,16
  if(syscallnum == SYS_fork){
    8000302e:	4785                	li	a5,1
    80003030:	02f50d63          	beq	a0,a5,8000306a <printtrace+0x44>
    printf("%d: syscall fork NULL -> %d\n",pid,ret);
  }
  else if(syscallnum == SYS_kill || syscallnum == SYS_sbrk){  
    80003034:	4799                	li	a5,6
    80003036:	00f50563          	beq	a0,a5,80003040 <printtrace+0x1a>
    8000303a:	47b1                	li	a5,12
    8000303c:	04f51063          	bne	a0,a5,8000307c <printtrace+0x56>
    printf("%d: syscall %s %d -> %d\n",pid,syscallnames[syscallnum], arg, ret);
    80003040:	050e                	slli	a0,a0,0x3
    80003042:	00005797          	auipc	a5,0x5
    80003046:	53678793          	addi	a5,a5,1334 # 80008578 <syscallnames>
    8000304a:	953e                	add	a0,a0,a5
    8000304c:	8732                	mv	a4,a2
    8000304e:	6110                	ld	a2,0(a0)
    80003050:	00005517          	auipc	a0,0x5
    80003054:	3f050513          	addi	a0,a0,1008 # 80008440 <states.0+0x170>
    80003058:	ffffd097          	auipc	ra,0xffffd
    8000305c:	51c080e7          	jalr	1308(ra) # 80000574 <printf>
  }
  else{
    printf("%d: syscall %s -> %d\n",pid,syscallnames[syscallnum],ret);
  }
  return 0;   
}
    80003060:	4501                	li	a0,0
    80003062:	60a2                	ld	ra,8(sp)
    80003064:	6402                	ld	s0,0(sp)
    80003066:	0141                	addi	sp,sp,16
    80003068:	8082                	ret
    printf("%d: syscall fork NULL -> %d\n",pid,ret);
    8000306a:	00005517          	auipc	a0,0x5
    8000306e:	3b650513          	addi	a0,a0,950 # 80008420 <states.0+0x150>
    80003072:	ffffd097          	auipc	ra,0xffffd
    80003076:	502080e7          	jalr	1282(ra) # 80000574 <printf>
    8000307a:	b7dd                	j	80003060 <printtrace+0x3a>
    printf("%d: syscall %s -> %d\n",pid,syscallnames[syscallnum],ret);
    8000307c:	050e                	slli	a0,a0,0x3
    8000307e:	00005797          	auipc	a5,0x5
    80003082:	4fa78793          	addi	a5,a5,1274 # 80008578 <syscallnames>
    80003086:	953e                	add	a0,a0,a5
    80003088:	86b2                	mv	a3,a2
    8000308a:	6110                	ld	a2,0(a0)
    8000308c:	00005517          	auipc	a0,0x5
    80003090:	3d450513          	addi	a0,a0,980 # 80008460 <states.0+0x190>
    80003094:	ffffd097          	auipc	ra,0xffffd
    80003098:	4e0080e7          	jalr	1248(ra) # 80000574 <printf>
    8000309c:	b7d1                	j	80003060 <printtrace+0x3a>

000000008000309e <syscall>:


void
syscall(void)
{
    8000309e:	715d                	addi	sp,sp,-80
    800030a0:	e486                	sd	ra,72(sp)
    800030a2:	e0a2                	sd	s0,64(sp)
    800030a4:	fc26                	sd	s1,56(sp)
    800030a6:	f84a                	sd	s2,48(sp)
    800030a8:	f44e                	sd	s3,40(sp)
    800030aa:	f052                	sd	s4,32(sp)
    800030ac:	ec56                	sd	s5,24(sp)
    800030ae:	0880                	addi	s0,sp,80
  int num;
  struct proc *p = myproc();
    800030b0:	fffff097          	auipc	ra,0xfffff
    800030b4:	8ce080e7          	jalr	-1842(ra) # 8000197e <myproc>
    800030b8:	84aa                	mv	s1,a0
  int tracemask = p->tracemask;

  num = p->trapframe->a7;
    800030ba:	615c                	ld	a5,128(a0)
    800030bc:	77dc                	ld	a5,168(a5)
    800030be:	0007891b          	sext.w	s2,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800030c2:	37fd                	addiw	a5,a5,-1
    800030c4:	475d                	li	a4,23
    800030c6:	04f76c63          	bltu	a4,a5,8000311e <syscall+0x80>
    800030ca:	00391713          	slli	a4,s2,0x3
    800030ce:	00005797          	auipc	a5,0x5
    800030d2:	4aa78793          	addi	a5,a5,1194 # 80008578 <syscallnames>
    800030d6:	97ba                	add	a5,a5,a4
    800030d8:	0c87ba03          	ld	s4,200(a5)
    800030dc:	040a0163          	beqz	s4,8000311e <syscall+0x80>
  int tracemask = p->tracemask;
    800030e0:	03452983          	lw	s3,52(a0)
    int arg;
    argint(0, &arg);
    800030e4:	fbc40593          	addi	a1,s0,-68
    800030e8:	4501                	li	a0,0
    800030ea:	00000097          	auipc	ra,0x0
    800030ee:	ec8080e7          	jalr	-312(ra) # 80002fb2 <argint>

    p->trapframe->a0 = syscalls[num]();
    800030f2:	0804ba83          	ld	s5,128(s1)
    800030f6:	9a02                	jalr	s4
    800030f8:	06aab823          	sd	a0,112(s5)

    if(tracemask & (1<<num)){
    800030fc:	4129d9bb          	sraw	s3,s3,s2
    80003100:	0019f993          	andi	s3,s3,1
    80003104:	02098c63          	beqz	s3,8000313c <syscall+0x9e>
      printtrace(num,p->pid,p->trapframe->a0,arg);
    80003108:	60dc                	ld	a5,128(s1)
    8000310a:	fbc42683          	lw	a3,-68(s0)
    8000310e:	7bb0                	ld	a2,112(a5)
    80003110:	588c                	lw	a1,48(s1)
    80003112:	854a                	mv	a0,s2
    80003114:	00000097          	auipc	ra,0x0
    80003118:	f12080e7          	jalr	-238(ra) # 80003026 <printtrace>
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000311c:	a005                	j	8000313c <syscall+0x9e>
    }
    
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000311e:	86ca                	mv	a3,s2
    80003120:	18048613          	addi	a2,s1,384
    80003124:	588c                	lw	a1,48(s1)
    80003126:	00005517          	auipc	a0,0x5
    8000312a:	35250513          	addi	a0,a0,850 # 80008478 <states.0+0x1a8>
    8000312e:	ffffd097          	auipc	ra,0xffffd
    80003132:	446080e7          	jalr	1094(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003136:	60dc                	ld	a5,128(s1)
    80003138:	577d                	li	a4,-1
    8000313a:	fbb8                	sd	a4,112(a5)
  }
}
    8000313c:	60a6                	ld	ra,72(sp)
    8000313e:	6406                	ld	s0,64(sp)
    80003140:	74e2                	ld	s1,56(sp)
    80003142:	7942                	ld	s2,48(sp)
    80003144:	79a2                	ld	s3,40(sp)
    80003146:	7a02                	ld	s4,32(sp)
    80003148:	6ae2                	ld	s5,24(sp)
    8000314a:	6161                	addi	sp,sp,80
    8000314c:	8082                	ret

000000008000314e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000314e:	1101                	addi	sp,sp,-32
    80003150:	ec06                	sd	ra,24(sp)
    80003152:	e822                	sd	s0,16(sp)
    80003154:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003156:	fec40593          	addi	a1,s0,-20
    8000315a:	4501                	li	a0,0
    8000315c:	00000097          	auipc	ra,0x0
    80003160:	e56080e7          	jalr	-426(ra) # 80002fb2 <argint>
    return -1;
    80003164:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003166:	00054963          	bltz	a0,80003178 <sys_exit+0x2a>
  exit(n);
    8000316a:	fec42503          	lw	a0,-20(s0)
    8000316e:	fffff097          	auipc	ra,0xfffff
    80003172:	3a8080e7          	jalr	936(ra) # 80002516 <exit>
  return 0;  // not reached
    80003176:	4781                	li	a5,0
}
    80003178:	853e                	mv	a0,a5
    8000317a:	60e2                	ld	ra,24(sp)
    8000317c:	6442                	ld	s0,16(sp)
    8000317e:	6105                	addi	sp,sp,32
    80003180:	8082                	ret

0000000080003182 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003182:	1141                	addi	sp,sp,-16
    80003184:	e406                	sd	ra,8(sp)
    80003186:	e022                	sd	s0,0(sp)
    80003188:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000318a:	ffffe097          	auipc	ra,0xffffe
    8000318e:	7f4080e7          	jalr	2036(ra) # 8000197e <myproc>
}
    80003192:	5908                	lw	a0,48(a0)
    80003194:	60a2                	ld	ra,8(sp)
    80003196:	6402                	ld	s0,0(sp)
    80003198:	0141                	addi	sp,sp,16
    8000319a:	8082                	ret

000000008000319c <sys_fork>:

uint64
sys_fork(void)
{
    8000319c:	1141                	addi	sp,sp,-16
    8000319e:	e406                	sd	ra,8(sp)
    800031a0:	e022                	sd	s0,0(sp)
    800031a2:	0800                	addi	s0,sp,16
  return fork();
    800031a4:	fffff097          	auipc	ra,0xfffff
    800031a8:	c06080e7          	jalr	-1018(ra) # 80001daa <fork>
}
    800031ac:	60a2                	ld	ra,8(sp)
    800031ae:	6402                	ld	s0,0(sp)
    800031b0:	0141                	addi	sp,sp,16
    800031b2:	8082                	ret

00000000800031b4 <sys_wait>:

uint64
sys_wait(void)
{
    800031b4:	1101                	addi	sp,sp,-32
    800031b6:	ec06                	sd	ra,24(sp)
    800031b8:	e822                	sd	s0,16(sp)
    800031ba:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    800031bc:	fe840593          	addi	a1,s0,-24
    800031c0:	4501                	li	a0,0
    800031c2:	00000097          	auipc	ra,0x0
    800031c6:	e12080e7          	jalr	-494(ra) # 80002fd4 <argaddr>
    800031ca:	87aa                	mv	a5,a0
    return -1;
    800031cc:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800031ce:	0007c863          	bltz	a5,800031de <sys_wait+0x2a>
  return wait(p);
    800031d2:	fe843503          	ld	a0,-24(s0)
    800031d6:	fffff097          	auipc	ra,0xfffff
    800031da:	136080e7          	jalr	310(ra) # 8000230c <wait>
}
    800031de:	60e2                	ld	ra,24(sp)
    800031e0:	6442                	ld	s0,16(sp)
    800031e2:	6105                	addi	sp,sp,32
    800031e4:	8082                	ret

00000000800031e6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800031e6:	7179                	addi	sp,sp,-48
    800031e8:	f406                	sd	ra,40(sp)
    800031ea:	f022                	sd	s0,32(sp)
    800031ec:	ec26                	sd	s1,24(sp)
    800031ee:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800031f0:	fdc40593          	addi	a1,s0,-36
    800031f4:	4501                	li	a0,0
    800031f6:	00000097          	auipc	ra,0x0
    800031fa:	dbc080e7          	jalr	-580(ra) # 80002fb2 <argint>
    return -1;
    800031fe:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003200:	00054f63          	bltz	a0,8000321e <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003204:	ffffe097          	auipc	ra,0xffffe
    80003208:	77a080e7          	jalr	1914(ra) # 8000197e <myproc>
    8000320c:	5924                	lw	s1,112(a0)
  if(growproc(n) < 0)
    8000320e:	fdc42503          	lw	a0,-36(s0)
    80003212:	fffff097          	auipc	ra,0xfffff
    80003216:	b00080e7          	jalr	-1280(ra) # 80001d12 <growproc>
    8000321a:	00054863          	bltz	a0,8000322a <sys_sbrk+0x44>
    return -1;
  return addr;
}
    8000321e:	8526                	mv	a0,s1
    80003220:	70a2                	ld	ra,40(sp)
    80003222:	7402                	ld	s0,32(sp)
    80003224:	64e2                	ld	s1,24(sp)
    80003226:	6145                	addi	sp,sp,48
    80003228:	8082                	ret
    return -1;
    8000322a:	54fd                	li	s1,-1
    8000322c:	bfcd                	j	8000321e <sys_sbrk+0x38>

000000008000322e <sys_sleep>:

uint64
sys_sleep(void)
{
    8000322e:	7139                	addi	sp,sp,-64
    80003230:	fc06                	sd	ra,56(sp)
    80003232:	f822                	sd	s0,48(sp)
    80003234:	f426                	sd	s1,40(sp)
    80003236:	f04a                	sd	s2,32(sp)
    80003238:	ec4e                	sd	s3,24(sp)
    8000323a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    8000323c:	fcc40593          	addi	a1,s0,-52
    80003240:	4501                	li	a0,0
    80003242:	00000097          	auipc	ra,0x0
    80003246:	d70080e7          	jalr	-656(ra) # 80002fb2 <argint>
    return -1;
    8000324a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000324c:	06054563          	bltz	a0,800032b6 <sys_sleep+0x88>
  acquire(&tickslock);
    80003250:	00015517          	auipc	a0,0x15
    80003254:	88050513          	addi	a0,a0,-1920 # 80017ad0 <tickslock>
    80003258:	ffffe097          	auipc	ra,0xffffe
    8000325c:	96a080e7          	jalr	-1686(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    80003260:	00006917          	auipc	s2,0x6
    80003264:	dd092903          	lw	s2,-560(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80003268:	fcc42783          	lw	a5,-52(s0)
    8000326c:	cf85                	beqz	a5,800032a4 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000326e:	00015997          	auipc	s3,0x15
    80003272:	86298993          	addi	s3,s3,-1950 # 80017ad0 <tickslock>
    80003276:	00006497          	auipc	s1,0x6
    8000327a:	dba48493          	addi	s1,s1,-582 # 80009030 <ticks>
    if(myproc()->killed){
    8000327e:	ffffe097          	auipc	ra,0xffffe
    80003282:	700080e7          	jalr	1792(ra) # 8000197e <myproc>
    80003286:	551c                	lw	a5,40(a0)
    80003288:	ef9d                	bnez	a5,800032c6 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000328a:	85ce                	mv	a1,s3
    8000328c:	8526                	mv	a0,s1
    8000328e:	fffff097          	auipc	ra,0xfffff
    80003292:	01a080e7          	jalr	26(ra) # 800022a8 <sleep>
  while(ticks - ticks0 < n){
    80003296:	409c                	lw	a5,0(s1)
    80003298:	412787bb          	subw	a5,a5,s2
    8000329c:	fcc42703          	lw	a4,-52(s0)
    800032a0:	fce7efe3          	bltu	a5,a4,8000327e <sys_sleep+0x50>
  }
  release(&tickslock);
    800032a4:	00015517          	auipc	a0,0x15
    800032a8:	82c50513          	addi	a0,a0,-2004 # 80017ad0 <tickslock>
    800032ac:	ffffe097          	auipc	ra,0xffffe
    800032b0:	9ca080e7          	jalr	-1590(ra) # 80000c76 <release>
  return 0;
    800032b4:	4781                	li	a5,0
}
    800032b6:	853e                	mv	a0,a5
    800032b8:	70e2                	ld	ra,56(sp)
    800032ba:	7442                	ld	s0,48(sp)
    800032bc:	74a2                	ld	s1,40(sp)
    800032be:	7902                	ld	s2,32(sp)
    800032c0:	69e2                	ld	s3,24(sp)
    800032c2:	6121                	addi	sp,sp,64
    800032c4:	8082                	ret
      release(&tickslock);
    800032c6:	00015517          	auipc	a0,0x15
    800032ca:	80a50513          	addi	a0,a0,-2038 # 80017ad0 <tickslock>
    800032ce:	ffffe097          	auipc	ra,0xffffe
    800032d2:	9a8080e7          	jalr	-1624(ra) # 80000c76 <release>
      return -1;
    800032d6:	57fd                	li	a5,-1
    800032d8:	bff9                	j	800032b6 <sys_sleep+0x88>

00000000800032da <sys_kill>:

uint64
sys_kill(void)
{
    800032da:	1101                	addi	sp,sp,-32
    800032dc:	ec06                	sd	ra,24(sp)
    800032de:	e822                	sd	s0,16(sp)
    800032e0:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800032e2:	fec40593          	addi	a1,s0,-20
    800032e6:	4501                	li	a0,0
    800032e8:	00000097          	auipc	ra,0x0
    800032ec:	cca080e7          	jalr	-822(ra) # 80002fb2 <argint>
    800032f0:	87aa                	mv	a5,a0
    return -1;
    800032f2:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800032f4:	0007c863          	bltz	a5,80003304 <sys_kill+0x2a>
  return kill(pid);
    800032f8:	fec42503          	lw	a0,-20(s0)
    800032fc:	fffff097          	auipc	ra,0xfffff
    80003300:	2fc080e7          	jalr	764(ra) # 800025f8 <kill>
}
    80003304:	60e2                	ld	ra,24(sp)
    80003306:	6442                	ld	s0,16(sp)
    80003308:	6105                	addi	sp,sp,32
    8000330a:	8082                	ret

000000008000330c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000330c:	1101                	addi	sp,sp,-32
    8000330e:	ec06                	sd	ra,24(sp)
    80003310:	e822                	sd	s0,16(sp)
    80003312:	e426                	sd	s1,8(sp)
    80003314:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003316:	00014517          	auipc	a0,0x14
    8000331a:	7ba50513          	addi	a0,a0,1978 # 80017ad0 <tickslock>
    8000331e:	ffffe097          	auipc	ra,0xffffe
    80003322:	8a4080e7          	jalr	-1884(ra) # 80000bc2 <acquire>
  xticks = ticks;
    80003326:	00006497          	auipc	s1,0x6
    8000332a:	d0a4a483          	lw	s1,-758(s1) # 80009030 <ticks>
  release(&tickslock);
    8000332e:	00014517          	auipc	a0,0x14
    80003332:	7a250513          	addi	a0,a0,1954 # 80017ad0 <tickslock>
    80003336:	ffffe097          	auipc	ra,0xffffe
    8000333a:	940080e7          	jalr	-1728(ra) # 80000c76 <release>
  return xticks;
}
    8000333e:	02049513          	slli	a0,s1,0x20
    80003342:	9101                	srli	a0,a0,0x20
    80003344:	60e2                	ld	ra,24(sp)
    80003346:	6442                	ld	s0,16(sp)
    80003348:	64a2                	ld	s1,8(sp)
    8000334a:	6105                	addi	sp,sp,32
    8000334c:	8082                	ret

000000008000334e <sys_trace>:

uint64
sys_trace(void)
{
    8000334e:	1101                	addi	sp,sp,-32
    80003350:	ec06                	sd	ra,24(sp)
    80003352:	e822                	sd	s0,16(sp)
    80003354:	1000                	addi	s0,sp,32
  int mask, pid;

  if(argint(0, &mask) < 0)
    80003356:	fec40593          	addi	a1,s0,-20
    8000335a:	4501                	li	a0,0
    8000335c:	00000097          	auipc	ra,0x0
    80003360:	c56080e7          	jalr	-938(ra) # 80002fb2 <argint>
    return -1;
    80003364:	57fd                	li	a5,-1
  if(argint(0, &mask) < 0)
    80003366:	02054563          	bltz	a0,80003390 <sys_trace+0x42>
  if(argint(1, &pid) < 0)
    8000336a:	fe840593          	addi	a1,s0,-24
    8000336e:	4505                	li	a0,1
    80003370:	00000097          	auipc	ra,0x0
    80003374:	c42080e7          	jalr	-958(ra) # 80002fb2 <argint>
    return -1;
    80003378:	57fd                	li	a5,-1
  if(argint(1, &pid) < 0)
    8000337a:	00054b63          	bltz	a0,80003390 <sys_trace+0x42>
  return trace(mask, pid);
    8000337e:	fe842583          	lw	a1,-24(s0)
    80003382:	fec42503          	lw	a0,-20(s0)
    80003386:	fffff097          	auipc	ra,0xfffff
    8000338a:	44a080e7          	jalr	1098(ra) # 800027d0 <trace>
    8000338e:	87aa                	mv	a5,a0
}
    80003390:	853e                	mv	a0,a5
    80003392:	60e2                	ld	ra,24(sp)
    80003394:	6442                	ld	s0,16(sp)
    80003396:	6105                	addi	sp,sp,32
    80003398:	8082                	ret

000000008000339a <sys_wait_stat>:


uint64
sys_wait_stat(void){
    8000339a:	1101                	addi	sp,sp,-32
    8000339c:	ec06                	sd	ra,24(sp)
    8000339e:	e822                	sd	s0,16(sp)
    800033a0:	1000                	addi	s0,sp,32
  uint64 stat;
  uint64 perf;
  if(argaddr(0, &stat) < 0)
    800033a2:	fe840593          	addi	a1,s0,-24
    800033a6:	4501                	li	a0,0
    800033a8:	00000097          	auipc	ra,0x0
    800033ac:	c2c080e7          	jalr	-980(ra) # 80002fd4 <argaddr>
    return -1;
    800033b0:	57fd                	li	a5,-1
  if(argaddr(0, &stat) < 0)
    800033b2:	02054563          	bltz	a0,800033dc <sys_wait_stat+0x42>
  if(argaddr(1, &perf) < 0)
    800033b6:	fe040593          	addi	a1,s0,-32
    800033ba:	4505                	li	a0,1
    800033bc:	00000097          	auipc	ra,0x0
    800033c0:	c18080e7          	jalr	-1000(ra) # 80002fd4 <argaddr>
    return -1;
    800033c4:	57fd                	li	a5,-1
  if(argaddr(1, &perf) < 0)
    800033c6:	00054b63          	bltz	a0,800033dc <sys_wait_stat+0x42>
  return wait_stat(stat, perf);
    800033ca:	fe043583          	ld	a1,-32(s0)
    800033ce:	fe843503          	ld	a0,-24(s0)
    800033d2:	fffff097          	auipc	ra,0xfffff
    800033d6:	468080e7          	jalr	1128(ra) # 8000283a <wait_stat>
    800033da:	87aa                	mv	a5,a0
}
    800033dc:	853e                	mv	a0,a5
    800033de:	60e2                	ld	ra,24(sp)
    800033e0:	6442                	ld	s0,16(sp)
    800033e2:	6105                	addi	sp,sp,32
    800033e4:	8082                	ret

00000000800033e6 <sys_set_priority>:

uint64
sys_set_priority(void){
    800033e6:	1101                	addi	sp,sp,-32
    800033e8:	ec06                	sd	ra,24(sp)
    800033ea:	e822                	sd	s0,16(sp)
    800033ec:	1000                	addi	s0,sp,32
  int priotity;
 if(argint(0,&priotity) < 0)
    800033ee:	fec40593          	addi	a1,s0,-20
    800033f2:	4501                	li	a0,0
    800033f4:	00000097          	auipc	ra,0x0
    800033f8:	bbe080e7          	jalr	-1090(ra) # 80002fb2 <argint>
    800033fc:	87aa                	mv	a5,a0
    return -1;
    800033fe:	557d                	li	a0,-1
 if(argint(0,&priotity) < 0)
    80003400:	0007c863          	bltz	a5,80003410 <sys_set_priority+0x2a>
  return set_priority(priotity);
    80003404:	fec42503          	lw	a0,-20(s0)
    80003408:	fffff097          	auipc	ra,0xfffff
    8000340c:	60c080e7          	jalr	1548(ra) # 80002a14 <set_priority>
}
    80003410:	60e2                	ld	ra,24(sp)
    80003412:	6442                	ld	s0,16(sp)
    80003414:	6105                	addi	sp,sp,32
    80003416:	8082                	ret

0000000080003418 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003418:	7179                	addi	sp,sp,-48
    8000341a:	f406                	sd	ra,40(sp)
    8000341c:	f022                	sd	s0,32(sp)
    8000341e:	ec26                	sd	s1,24(sp)
    80003420:	e84a                	sd	s2,16(sp)
    80003422:	e44e                	sd	s3,8(sp)
    80003424:	e052                	sd	s4,0(sp)
    80003426:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003428:	00005597          	auipc	a1,0x5
    8000342c:	2e058593          	addi	a1,a1,736 # 80008708 <syscalls+0xc8>
    80003430:	00014517          	auipc	a0,0x14
    80003434:	6b850513          	addi	a0,a0,1720 # 80017ae8 <bcache>
    80003438:	ffffd097          	auipc	ra,0xffffd
    8000343c:	6fa080e7          	jalr	1786(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003440:	0001c797          	auipc	a5,0x1c
    80003444:	6a878793          	addi	a5,a5,1704 # 8001fae8 <bcache+0x8000>
    80003448:	0001d717          	auipc	a4,0x1d
    8000344c:	90870713          	addi	a4,a4,-1784 # 8001fd50 <bcache+0x8268>
    80003450:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003454:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003458:	00014497          	auipc	s1,0x14
    8000345c:	6a848493          	addi	s1,s1,1704 # 80017b00 <bcache+0x18>
    b->next = bcache.head.next;
    80003460:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003462:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003464:	00005a17          	auipc	s4,0x5
    80003468:	2aca0a13          	addi	s4,s4,684 # 80008710 <syscalls+0xd0>
    b->next = bcache.head.next;
    8000346c:	2b893783          	ld	a5,696(s2)
    80003470:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003472:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003476:	85d2                	mv	a1,s4
    80003478:	01048513          	addi	a0,s1,16
    8000347c:	00001097          	auipc	ra,0x1
    80003480:	4c2080e7          	jalr	1218(ra) # 8000493e <initsleeplock>
    bcache.head.next->prev = b;
    80003484:	2b893783          	ld	a5,696(s2)
    80003488:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000348a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000348e:	45848493          	addi	s1,s1,1112
    80003492:	fd349de3          	bne	s1,s3,8000346c <binit+0x54>
  }
}
    80003496:	70a2                	ld	ra,40(sp)
    80003498:	7402                	ld	s0,32(sp)
    8000349a:	64e2                	ld	s1,24(sp)
    8000349c:	6942                	ld	s2,16(sp)
    8000349e:	69a2                	ld	s3,8(sp)
    800034a0:	6a02                	ld	s4,0(sp)
    800034a2:	6145                	addi	sp,sp,48
    800034a4:	8082                	ret

00000000800034a6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800034a6:	7179                	addi	sp,sp,-48
    800034a8:	f406                	sd	ra,40(sp)
    800034aa:	f022                	sd	s0,32(sp)
    800034ac:	ec26                	sd	s1,24(sp)
    800034ae:	e84a                	sd	s2,16(sp)
    800034b0:	e44e                	sd	s3,8(sp)
    800034b2:	1800                	addi	s0,sp,48
    800034b4:	892a                	mv	s2,a0
    800034b6:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800034b8:	00014517          	auipc	a0,0x14
    800034bc:	63050513          	addi	a0,a0,1584 # 80017ae8 <bcache>
    800034c0:	ffffd097          	auipc	ra,0xffffd
    800034c4:	702080e7          	jalr	1794(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800034c8:	0001d497          	auipc	s1,0x1d
    800034cc:	8d84b483          	ld	s1,-1832(s1) # 8001fda0 <bcache+0x82b8>
    800034d0:	0001d797          	auipc	a5,0x1d
    800034d4:	88078793          	addi	a5,a5,-1920 # 8001fd50 <bcache+0x8268>
    800034d8:	02f48f63          	beq	s1,a5,80003516 <bread+0x70>
    800034dc:	873e                	mv	a4,a5
    800034de:	a021                	j	800034e6 <bread+0x40>
    800034e0:	68a4                	ld	s1,80(s1)
    800034e2:	02e48a63          	beq	s1,a4,80003516 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800034e6:	449c                	lw	a5,8(s1)
    800034e8:	ff279ce3          	bne	a5,s2,800034e0 <bread+0x3a>
    800034ec:	44dc                	lw	a5,12(s1)
    800034ee:	ff3799e3          	bne	a5,s3,800034e0 <bread+0x3a>
      b->refcnt++;
    800034f2:	40bc                	lw	a5,64(s1)
    800034f4:	2785                	addiw	a5,a5,1
    800034f6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034f8:	00014517          	auipc	a0,0x14
    800034fc:	5f050513          	addi	a0,a0,1520 # 80017ae8 <bcache>
    80003500:	ffffd097          	auipc	ra,0xffffd
    80003504:	776080e7          	jalr	1910(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003508:	01048513          	addi	a0,s1,16
    8000350c:	00001097          	auipc	ra,0x1
    80003510:	46c080e7          	jalr	1132(ra) # 80004978 <acquiresleep>
      return b;
    80003514:	a8b9                	j	80003572 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003516:	0001d497          	auipc	s1,0x1d
    8000351a:	8824b483          	ld	s1,-1918(s1) # 8001fd98 <bcache+0x82b0>
    8000351e:	0001d797          	auipc	a5,0x1d
    80003522:	83278793          	addi	a5,a5,-1998 # 8001fd50 <bcache+0x8268>
    80003526:	00f48863          	beq	s1,a5,80003536 <bread+0x90>
    8000352a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000352c:	40bc                	lw	a5,64(s1)
    8000352e:	cf81                	beqz	a5,80003546 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003530:	64a4                	ld	s1,72(s1)
    80003532:	fee49de3          	bne	s1,a4,8000352c <bread+0x86>
  panic("bget: no buffers");
    80003536:	00005517          	auipc	a0,0x5
    8000353a:	1e250513          	addi	a0,a0,482 # 80008718 <syscalls+0xd8>
    8000353e:	ffffd097          	auipc	ra,0xffffd
    80003542:	fec080e7          	jalr	-20(ra) # 8000052a <panic>
      b->dev = dev;
    80003546:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000354a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000354e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003552:	4785                	li	a5,1
    80003554:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003556:	00014517          	auipc	a0,0x14
    8000355a:	59250513          	addi	a0,a0,1426 # 80017ae8 <bcache>
    8000355e:	ffffd097          	auipc	ra,0xffffd
    80003562:	718080e7          	jalr	1816(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003566:	01048513          	addi	a0,s1,16
    8000356a:	00001097          	auipc	ra,0x1
    8000356e:	40e080e7          	jalr	1038(ra) # 80004978 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003572:	409c                	lw	a5,0(s1)
    80003574:	cb89                	beqz	a5,80003586 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003576:	8526                	mv	a0,s1
    80003578:	70a2                	ld	ra,40(sp)
    8000357a:	7402                	ld	s0,32(sp)
    8000357c:	64e2                	ld	s1,24(sp)
    8000357e:	6942                	ld	s2,16(sp)
    80003580:	69a2                	ld	s3,8(sp)
    80003582:	6145                	addi	sp,sp,48
    80003584:	8082                	ret
    virtio_disk_rw(b, 0);
    80003586:	4581                	li	a1,0
    80003588:	8526                	mv	a0,s1
    8000358a:	00003097          	auipc	ra,0x3
    8000358e:	f1c080e7          	jalr	-228(ra) # 800064a6 <virtio_disk_rw>
    b->valid = 1;
    80003592:	4785                	li	a5,1
    80003594:	c09c                	sw	a5,0(s1)
  return b;
    80003596:	b7c5                	j	80003576 <bread+0xd0>

0000000080003598 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003598:	1101                	addi	sp,sp,-32
    8000359a:	ec06                	sd	ra,24(sp)
    8000359c:	e822                	sd	s0,16(sp)
    8000359e:	e426                	sd	s1,8(sp)
    800035a0:	1000                	addi	s0,sp,32
    800035a2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035a4:	0541                	addi	a0,a0,16
    800035a6:	00001097          	auipc	ra,0x1
    800035aa:	46c080e7          	jalr	1132(ra) # 80004a12 <holdingsleep>
    800035ae:	cd01                	beqz	a0,800035c6 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800035b0:	4585                	li	a1,1
    800035b2:	8526                	mv	a0,s1
    800035b4:	00003097          	auipc	ra,0x3
    800035b8:	ef2080e7          	jalr	-270(ra) # 800064a6 <virtio_disk_rw>
}
    800035bc:	60e2                	ld	ra,24(sp)
    800035be:	6442                	ld	s0,16(sp)
    800035c0:	64a2                	ld	s1,8(sp)
    800035c2:	6105                	addi	sp,sp,32
    800035c4:	8082                	ret
    panic("bwrite");
    800035c6:	00005517          	auipc	a0,0x5
    800035ca:	16a50513          	addi	a0,a0,362 # 80008730 <syscalls+0xf0>
    800035ce:	ffffd097          	auipc	ra,0xffffd
    800035d2:	f5c080e7          	jalr	-164(ra) # 8000052a <panic>

00000000800035d6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800035d6:	1101                	addi	sp,sp,-32
    800035d8:	ec06                	sd	ra,24(sp)
    800035da:	e822                	sd	s0,16(sp)
    800035dc:	e426                	sd	s1,8(sp)
    800035de:	e04a                	sd	s2,0(sp)
    800035e0:	1000                	addi	s0,sp,32
    800035e2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035e4:	01050913          	addi	s2,a0,16
    800035e8:	854a                	mv	a0,s2
    800035ea:	00001097          	auipc	ra,0x1
    800035ee:	428080e7          	jalr	1064(ra) # 80004a12 <holdingsleep>
    800035f2:	c92d                	beqz	a0,80003664 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800035f4:	854a                	mv	a0,s2
    800035f6:	00001097          	auipc	ra,0x1
    800035fa:	3d8080e7          	jalr	984(ra) # 800049ce <releasesleep>

  acquire(&bcache.lock);
    800035fe:	00014517          	auipc	a0,0x14
    80003602:	4ea50513          	addi	a0,a0,1258 # 80017ae8 <bcache>
    80003606:	ffffd097          	auipc	ra,0xffffd
    8000360a:	5bc080e7          	jalr	1468(ra) # 80000bc2 <acquire>
  b->refcnt--;
    8000360e:	40bc                	lw	a5,64(s1)
    80003610:	37fd                	addiw	a5,a5,-1
    80003612:	0007871b          	sext.w	a4,a5
    80003616:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003618:	eb05                	bnez	a4,80003648 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000361a:	68bc                	ld	a5,80(s1)
    8000361c:	64b8                	ld	a4,72(s1)
    8000361e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003620:	64bc                	ld	a5,72(s1)
    80003622:	68b8                	ld	a4,80(s1)
    80003624:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003626:	0001c797          	auipc	a5,0x1c
    8000362a:	4c278793          	addi	a5,a5,1218 # 8001fae8 <bcache+0x8000>
    8000362e:	2b87b703          	ld	a4,696(a5)
    80003632:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003634:	0001c717          	auipc	a4,0x1c
    80003638:	71c70713          	addi	a4,a4,1820 # 8001fd50 <bcache+0x8268>
    8000363c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000363e:	2b87b703          	ld	a4,696(a5)
    80003642:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003644:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003648:	00014517          	auipc	a0,0x14
    8000364c:	4a050513          	addi	a0,a0,1184 # 80017ae8 <bcache>
    80003650:	ffffd097          	auipc	ra,0xffffd
    80003654:	626080e7          	jalr	1574(ra) # 80000c76 <release>
}
    80003658:	60e2                	ld	ra,24(sp)
    8000365a:	6442                	ld	s0,16(sp)
    8000365c:	64a2                	ld	s1,8(sp)
    8000365e:	6902                	ld	s2,0(sp)
    80003660:	6105                	addi	sp,sp,32
    80003662:	8082                	ret
    panic("brelse");
    80003664:	00005517          	auipc	a0,0x5
    80003668:	0d450513          	addi	a0,a0,212 # 80008738 <syscalls+0xf8>
    8000366c:	ffffd097          	auipc	ra,0xffffd
    80003670:	ebe080e7          	jalr	-322(ra) # 8000052a <panic>

0000000080003674 <bpin>:

void
bpin(struct buf *b) {
    80003674:	1101                	addi	sp,sp,-32
    80003676:	ec06                	sd	ra,24(sp)
    80003678:	e822                	sd	s0,16(sp)
    8000367a:	e426                	sd	s1,8(sp)
    8000367c:	1000                	addi	s0,sp,32
    8000367e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003680:	00014517          	auipc	a0,0x14
    80003684:	46850513          	addi	a0,a0,1128 # 80017ae8 <bcache>
    80003688:	ffffd097          	auipc	ra,0xffffd
    8000368c:	53a080e7          	jalr	1338(ra) # 80000bc2 <acquire>
  b->refcnt++;
    80003690:	40bc                	lw	a5,64(s1)
    80003692:	2785                	addiw	a5,a5,1
    80003694:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003696:	00014517          	auipc	a0,0x14
    8000369a:	45250513          	addi	a0,a0,1106 # 80017ae8 <bcache>
    8000369e:	ffffd097          	auipc	ra,0xffffd
    800036a2:	5d8080e7          	jalr	1496(ra) # 80000c76 <release>
}
    800036a6:	60e2                	ld	ra,24(sp)
    800036a8:	6442                	ld	s0,16(sp)
    800036aa:	64a2                	ld	s1,8(sp)
    800036ac:	6105                	addi	sp,sp,32
    800036ae:	8082                	ret

00000000800036b0 <bunpin>:

void
bunpin(struct buf *b) {
    800036b0:	1101                	addi	sp,sp,-32
    800036b2:	ec06                	sd	ra,24(sp)
    800036b4:	e822                	sd	s0,16(sp)
    800036b6:	e426                	sd	s1,8(sp)
    800036b8:	1000                	addi	s0,sp,32
    800036ba:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036bc:	00014517          	auipc	a0,0x14
    800036c0:	42c50513          	addi	a0,a0,1068 # 80017ae8 <bcache>
    800036c4:	ffffd097          	auipc	ra,0xffffd
    800036c8:	4fe080e7          	jalr	1278(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800036cc:	40bc                	lw	a5,64(s1)
    800036ce:	37fd                	addiw	a5,a5,-1
    800036d0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036d2:	00014517          	auipc	a0,0x14
    800036d6:	41650513          	addi	a0,a0,1046 # 80017ae8 <bcache>
    800036da:	ffffd097          	auipc	ra,0xffffd
    800036de:	59c080e7          	jalr	1436(ra) # 80000c76 <release>
}
    800036e2:	60e2                	ld	ra,24(sp)
    800036e4:	6442                	ld	s0,16(sp)
    800036e6:	64a2                	ld	s1,8(sp)
    800036e8:	6105                	addi	sp,sp,32
    800036ea:	8082                	ret

00000000800036ec <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800036ec:	1101                	addi	sp,sp,-32
    800036ee:	ec06                	sd	ra,24(sp)
    800036f0:	e822                	sd	s0,16(sp)
    800036f2:	e426                	sd	s1,8(sp)
    800036f4:	e04a                	sd	s2,0(sp)
    800036f6:	1000                	addi	s0,sp,32
    800036f8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800036fa:	00d5d59b          	srliw	a1,a1,0xd
    800036fe:	0001d797          	auipc	a5,0x1d
    80003702:	ac67a783          	lw	a5,-1338(a5) # 800201c4 <sb+0x1c>
    80003706:	9dbd                	addw	a1,a1,a5
    80003708:	00000097          	auipc	ra,0x0
    8000370c:	d9e080e7          	jalr	-610(ra) # 800034a6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003710:	0074f713          	andi	a4,s1,7
    80003714:	4785                	li	a5,1
    80003716:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000371a:	14ce                	slli	s1,s1,0x33
    8000371c:	90d9                	srli	s1,s1,0x36
    8000371e:	00950733          	add	a4,a0,s1
    80003722:	05874703          	lbu	a4,88(a4)
    80003726:	00e7f6b3          	and	a3,a5,a4
    8000372a:	c69d                	beqz	a3,80003758 <bfree+0x6c>
    8000372c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000372e:	94aa                	add	s1,s1,a0
    80003730:	fff7c793          	not	a5,a5
    80003734:	8ff9                	and	a5,a5,a4
    80003736:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000373a:	00001097          	auipc	ra,0x1
    8000373e:	11e080e7          	jalr	286(ra) # 80004858 <log_write>
  brelse(bp);
    80003742:	854a                	mv	a0,s2
    80003744:	00000097          	auipc	ra,0x0
    80003748:	e92080e7          	jalr	-366(ra) # 800035d6 <brelse>
}
    8000374c:	60e2                	ld	ra,24(sp)
    8000374e:	6442                	ld	s0,16(sp)
    80003750:	64a2                	ld	s1,8(sp)
    80003752:	6902                	ld	s2,0(sp)
    80003754:	6105                	addi	sp,sp,32
    80003756:	8082                	ret
    panic("freeing free block");
    80003758:	00005517          	auipc	a0,0x5
    8000375c:	fe850513          	addi	a0,a0,-24 # 80008740 <syscalls+0x100>
    80003760:	ffffd097          	auipc	ra,0xffffd
    80003764:	dca080e7          	jalr	-566(ra) # 8000052a <panic>

0000000080003768 <balloc>:
{
    80003768:	711d                	addi	sp,sp,-96
    8000376a:	ec86                	sd	ra,88(sp)
    8000376c:	e8a2                	sd	s0,80(sp)
    8000376e:	e4a6                	sd	s1,72(sp)
    80003770:	e0ca                	sd	s2,64(sp)
    80003772:	fc4e                	sd	s3,56(sp)
    80003774:	f852                	sd	s4,48(sp)
    80003776:	f456                	sd	s5,40(sp)
    80003778:	f05a                	sd	s6,32(sp)
    8000377a:	ec5e                	sd	s7,24(sp)
    8000377c:	e862                	sd	s8,16(sp)
    8000377e:	e466                	sd	s9,8(sp)
    80003780:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003782:	0001d797          	auipc	a5,0x1d
    80003786:	a2a7a783          	lw	a5,-1494(a5) # 800201ac <sb+0x4>
    8000378a:	cbd1                	beqz	a5,8000381e <balloc+0xb6>
    8000378c:	8baa                	mv	s7,a0
    8000378e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003790:	0001db17          	auipc	s6,0x1d
    80003794:	a18b0b13          	addi	s6,s6,-1512 # 800201a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003798:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000379a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000379c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000379e:	6c89                	lui	s9,0x2
    800037a0:	a831                	j	800037bc <balloc+0x54>
    brelse(bp);
    800037a2:	854a                	mv	a0,s2
    800037a4:	00000097          	auipc	ra,0x0
    800037a8:	e32080e7          	jalr	-462(ra) # 800035d6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800037ac:	015c87bb          	addw	a5,s9,s5
    800037b0:	00078a9b          	sext.w	s5,a5
    800037b4:	004b2703          	lw	a4,4(s6)
    800037b8:	06eaf363          	bgeu	s5,a4,8000381e <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800037bc:	41fad79b          	sraiw	a5,s5,0x1f
    800037c0:	0137d79b          	srliw	a5,a5,0x13
    800037c4:	015787bb          	addw	a5,a5,s5
    800037c8:	40d7d79b          	sraiw	a5,a5,0xd
    800037cc:	01cb2583          	lw	a1,28(s6)
    800037d0:	9dbd                	addw	a1,a1,a5
    800037d2:	855e                	mv	a0,s7
    800037d4:	00000097          	auipc	ra,0x0
    800037d8:	cd2080e7          	jalr	-814(ra) # 800034a6 <bread>
    800037dc:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037de:	004b2503          	lw	a0,4(s6)
    800037e2:	000a849b          	sext.w	s1,s5
    800037e6:	8662                	mv	a2,s8
    800037e8:	faa4fde3          	bgeu	s1,a0,800037a2 <balloc+0x3a>
      m = 1 << (bi % 8);
    800037ec:	41f6579b          	sraiw	a5,a2,0x1f
    800037f0:	01d7d69b          	srliw	a3,a5,0x1d
    800037f4:	00c6873b          	addw	a4,a3,a2
    800037f8:	00777793          	andi	a5,a4,7
    800037fc:	9f95                	subw	a5,a5,a3
    800037fe:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003802:	4037571b          	sraiw	a4,a4,0x3
    80003806:	00e906b3          	add	a3,s2,a4
    8000380a:	0586c683          	lbu	a3,88(a3)
    8000380e:	00d7f5b3          	and	a1,a5,a3
    80003812:	cd91                	beqz	a1,8000382e <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003814:	2605                	addiw	a2,a2,1
    80003816:	2485                	addiw	s1,s1,1
    80003818:	fd4618e3          	bne	a2,s4,800037e8 <balloc+0x80>
    8000381c:	b759                	j	800037a2 <balloc+0x3a>
  panic("balloc: out of blocks");
    8000381e:	00005517          	auipc	a0,0x5
    80003822:	f3a50513          	addi	a0,a0,-198 # 80008758 <syscalls+0x118>
    80003826:	ffffd097          	auipc	ra,0xffffd
    8000382a:	d04080e7          	jalr	-764(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000382e:	974a                	add	a4,a4,s2
    80003830:	8fd5                	or	a5,a5,a3
    80003832:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003836:	854a                	mv	a0,s2
    80003838:	00001097          	auipc	ra,0x1
    8000383c:	020080e7          	jalr	32(ra) # 80004858 <log_write>
        brelse(bp);
    80003840:	854a                	mv	a0,s2
    80003842:	00000097          	auipc	ra,0x0
    80003846:	d94080e7          	jalr	-620(ra) # 800035d6 <brelse>
  bp = bread(dev, bno);
    8000384a:	85a6                	mv	a1,s1
    8000384c:	855e                	mv	a0,s7
    8000384e:	00000097          	auipc	ra,0x0
    80003852:	c58080e7          	jalr	-936(ra) # 800034a6 <bread>
    80003856:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003858:	40000613          	li	a2,1024
    8000385c:	4581                	li	a1,0
    8000385e:	05850513          	addi	a0,a0,88
    80003862:	ffffd097          	auipc	ra,0xffffd
    80003866:	45c080e7          	jalr	1116(ra) # 80000cbe <memset>
  log_write(bp);
    8000386a:	854a                	mv	a0,s2
    8000386c:	00001097          	auipc	ra,0x1
    80003870:	fec080e7          	jalr	-20(ra) # 80004858 <log_write>
  brelse(bp);
    80003874:	854a                	mv	a0,s2
    80003876:	00000097          	auipc	ra,0x0
    8000387a:	d60080e7          	jalr	-672(ra) # 800035d6 <brelse>
}
    8000387e:	8526                	mv	a0,s1
    80003880:	60e6                	ld	ra,88(sp)
    80003882:	6446                	ld	s0,80(sp)
    80003884:	64a6                	ld	s1,72(sp)
    80003886:	6906                	ld	s2,64(sp)
    80003888:	79e2                	ld	s3,56(sp)
    8000388a:	7a42                	ld	s4,48(sp)
    8000388c:	7aa2                	ld	s5,40(sp)
    8000388e:	7b02                	ld	s6,32(sp)
    80003890:	6be2                	ld	s7,24(sp)
    80003892:	6c42                	ld	s8,16(sp)
    80003894:	6ca2                	ld	s9,8(sp)
    80003896:	6125                	addi	sp,sp,96
    80003898:	8082                	ret

000000008000389a <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000389a:	7179                	addi	sp,sp,-48
    8000389c:	f406                	sd	ra,40(sp)
    8000389e:	f022                	sd	s0,32(sp)
    800038a0:	ec26                	sd	s1,24(sp)
    800038a2:	e84a                	sd	s2,16(sp)
    800038a4:	e44e                	sd	s3,8(sp)
    800038a6:	e052                	sd	s4,0(sp)
    800038a8:	1800                	addi	s0,sp,48
    800038aa:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800038ac:	47ad                	li	a5,11
    800038ae:	04b7fe63          	bgeu	a5,a1,8000390a <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800038b2:	ff45849b          	addiw	s1,a1,-12
    800038b6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800038ba:	0ff00793          	li	a5,255
    800038be:	0ae7e463          	bltu	a5,a4,80003966 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800038c2:	08052583          	lw	a1,128(a0)
    800038c6:	c5b5                	beqz	a1,80003932 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800038c8:	00092503          	lw	a0,0(s2)
    800038cc:	00000097          	auipc	ra,0x0
    800038d0:	bda080e7          	jalr	-1062(ra) # 800034a6 <bread>
    800038d4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800038d6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800038da:	02049713          	slli	a4,s1,0x20
    800038de:	01e75593          	srli	a1,a4,0x1e
    800038e2:	00b784b3          	add	s1,a5,a1
    800038e6:	0004a983          	lw	s3,0(s1)
    800038ea:	04098e63          	beqz	s3,80003946 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800038ee:	8552                	mv	a0,s4
    800038f0:	00000097          	auipc	ra,0x0
    800038f4:	ce6080e7          	jalr	-794(ra) # 800035d6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800038f8:	854e                	mv	a0,s3
    800038fa:	70a2                	ld	ra,40(sp)
    800038fc:	7402                	ld	s0,32(sp)
    800038fe:	64e2                	ld	s1,24(sp)
    80003900:	6942                	ld	s2,16(sp)
    80003902:	69a2                	ld	s3,8(sp)
    80003904:	6a02                	ld	s4,0(sp)
    80003906:	6145                	addi	sp,sp,48
    80003908:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000390a:	02059793          	slli	a5,a1,0x20
    8000390e:	01e7d593          	srli	a1,a5,0x1e
    80003912:	00b504b3          	add	s1,a0,a1
    80003916:	0504a983          	lw	s3,80(s1)
    8000391a:	fc099fe3          	bnez	s3,800038f8 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000391e:	4108                	lw	a0,0(a0)
    80003920:	00000097          	auipc	ra,0x0
    80003924:	e48080e7          	jalr	-440(ra) # 80003768 <balloc>
    80003928:	0005099b          	sext.w	s3,a0
    8000392c:	0534a823          	sw	s3,80(s1)
    80003930:	b7e1                	j	800038f8 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003932:	4108                	lw	a0,0(a0)
    80003934:	00000097          	auipc	ra,0x0
    80003938:	e34080e7          	jalr	-460(ra) # 80003768 <balloc>
    8000393c:	0005059b          	sext.w	a1,a0
    80003940:	08b92023          	sw	a1,128(s2)
    80003944:	b751                	j	800038c8 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003946:	00092503          	lw	a0,0(s2)
    8000394a:	00000097          	auipc	ra,0x0
    8000394e:	e1e080e7          	jalr	-482(ra) # 80003768 <balloc>
    80003952:	0005099b          	sext.w	s3,a0
    80003956:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000395a:	8552                	mv	a0,s4
    8000395c:	00001097          	auipc	ra,0x1
    80003960:	efc080e7          	jalr	-260(ra) # 80004858 <log_write>
    80003964:	b769                	j	800038ee <bmap+0x54>
  panic("bmap: out of range");
    80003966:	00005517          	auipc	a0,0x5
    8000396a:	e0a50513          	addi	a0,a0,-502 # 80008770 <syscalls+0x130>
    8000396e:	ffffd097          	auipc	ra,0xffffd
    80003972:	bbc080e7          	jalr	-1092(ra) # 8000052a <panic>

0000000080003976 <iget>:
{
    80003976:	7179                	addi	sp,sp,-48
    80003978:	f406                	sd	ra,40(sp)
    8000397a:	f022                	sd	s0,32(sp)
    8000397c:	ec26                	sd	s1,24(sp)
    8000397e:	e84a                	sd	s2,16(sp)
    80003980:	e44e                	sd	s3,8(sp)
    80003982:	e052                	sd	s4,0(sp)
    80003984:	1800                	addi	s0,sp,48
    80003986:	89aa                	mv	s3,a0
    80003988:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000398a:	0001d517          	auipc	a0,0x1d
    8000398e:	83e50513          	addi	a0,a0,-1986 # 800201c8 <itable>
    80003992:	ffffd097          	auipc	ra,0xffffd
    80003996:	230080e7          	jalr	560(ra) # 80000bc2 <acquire>
  empty = 0;
    8000399a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000399c:	0001d497          	auipc	s1,0x1d
    800039a0:	84448493          	addi	s1,s1,-1980 # 800201e0 <itable+0x18>
    800039a4:	0001e697          	auipc	a3,0x1e
    800039a8:	2cc68693          	addi	a3,a3,716 # 80021c70 <log>
    800039ac:	a039                	j	800039ba <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039ae:	02090b63          	beqz	s2,800039e4 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039b2:	08848493          	addi	s1,s1,136
    800039b6:	02d48a63          	beq	s1,a3,800039ea <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800039ba:	449c                	lw	a5,8(s1)
    800039bc:	fef059e3          	blez	a5,800039ae <iget+0x38>
    800039c0:	4098                	lw	a4,0(s1)
    800039c2:	ff3716e3          	bne	a4,s3,800039ae <iget+0x38>
    800039c6:	40d8                	lw	a4,4(s1)
    800039c8:	ff4713e3          	bne	a4,s4,800039ae <iget+0x38>
      ip->ref++;
    800039cc:	2785                	addiw	a5,a5,1
    800039ce:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800039d0:	0001c517          	auipc	a0,0x1c
    800039d4:	7f850513          	addi	a0,a0,2040 # 800201c8 <itable>
    800039d8:	ffffd097          	auipc	ra,0xffffd
    800039dc:	29e080e7          	jalr	670(ra) # 80000c76 <release>
      return ip;
    800039e0:	8926                	mv	s2,s1
    800039e2:	a03d                	j	80003a10 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039e4:	f7f9                	bnez	a5,800039b2 <iget+0x3c>
    800039e6:	8926                	mv	s2,s1
    800039e8:	b7e9                	j	800039b2 <iget+0x3c>
  if(empty == 0)
    800039ea:	02090c63          	beqz	s2,80003a22 <iget+0xac>
  ip->dev = dev;
    800039ee:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800039f2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800039f6:	4785                	li	a5,1
    800039f8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800039fc:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003a00:	0001c517          	auipc	a0,0x1c
    80003a04:	7c850513          	addi	a0,a0,1992 # 800201c8 <itable>
    80003a08:	ffffd097          	auipc	ra,0xffffd
    80003a0c:	26e080e7          	jalr	622(ra) # 80000c76 <release>
}
    80003a10:	854a                	mv	a0,s2
    80003a12:	70a2                	ld	ra,40(sp)
    80003a14:	7402                	ld	s0,32(sp)
    80003a16:	64e2                	ld	s1,24(sp)
    80003a18:	6942                	ld	s2,16(sp)
    80003a1a:	69a2                	ld	s3,8(sp)
    80003a1c:	6a02                	ld	s4,0(sp)
    80003a1e:	6145                	addi	sp,sp,48
    80003a20:	8082                	ret
    panic("iget: no inodes");
    80003a22:	00005517          	auipc	a0,0x5
    80003a26:	d6650513          	addi	a0,a0,-666 # 80008788 <syscalls+0x148>
    80003a2a:	ffffd097          	auipc	ra,0xffffd
    80003a2e:	b00080e7          	jalr	-1280(ra) # 8000052a <panic>

0000000080003a32 <fsinit>:
fsinit(int dev) {
    80003a32:	7179                	addi	sp,sp,-48
    80003a34:	f406                	sd	ra,40(sp)
    80003a36:	f022                	sd	s0,32(sp)
    80003a38:	ec26                	sd	s1,24(sp)
    80003a3a:	e84a                	sd	s2,16(sp)
    80003a3c:	e44e                	sd	s3,8(sp)
    80003a3e:	1800                	addi	s0,sp,48
    80003a40:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a42:	4585                	li	a1,1
    80003a44:	00000097          	auipc	ra,0x0
    80003a48:	a62080e7          	jalr	-1438(ra) # 800034a6 <bread>
    80003a4c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a4e:	0001c997          	auipc	s3,0x1c
    80003a52:	75a98993          	addi	s3,s3,1882 # 800201a8 <sb>
    80003a56:	02000613          	li	a2,32
    80003a5a:	05850593          	addi	a1,a0,88
    80003a5e:	854e                	mv	a0,s3
    80003a60:	ffffd097          	auipc	ra,0xffffd
    80003a64:	2ba080e7          	jalr	698(ra) # 80000d1a <memmove>
  brelse(bp);
    80003a68:	8526                	mv	a0,s1
    80003a6a:	00000097          	auipc	ra,0x0
    80003a6e:	b6c080e7          	jalr	-1172(ra) # 800035d6 <brelse>
  if(sb.magic != FSMAGIC)
    80003a72:	0009a703          	lw	a4,0(s3)
    80003a76:	102037b7          	lui	a5,0x10203
    80003a7a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a7e:	02f71263          	bne	a4,a5,80003aa2 <fsinit+0x70>
  initlog(dev, &sb);
    80003a82:	0001c597          	auipc	a1,0x1c
    80003a86:	72658593          	addi	a1,a1,1830 # 800201a8 <sb>
    80003a8a:	854a                	mv	a0,s2
    80003a8c:	00001097          	auipc	ra,0x1
    80003a90:	b4e080e7          	jalr	-1202(ra) # 800045da <initlog>
}
    80003a94:	70a2                	ld	ra,40(sp)
    80003a96:	7402                	ld	s0,32(sp)
    80003a98:	64e2                	ld	s1,24(sp)
    80003a9a:	6942                	ld	s2,16(sp)
    80003a9c:	69a2                	ld	s3,8(sp)
    80003a9e:	6145                	addi	sp,sp,48
    80003aa0:	8082                	ret
    panic("invalid file system");
    80003aa2:	00005517          	auipc	a0,0x5
    80003aa6:	cf650513          	addi	a0,a0,-778 # 80008798 <syscalls+0x158>
    80003aaa:	ffffd097          	auipc	ra,0xffffd
    80003aae:	a80080e7          	jalr	-1408(ra) # 8000052a <panic>

0000000080003ab2 <iinit>:
{
    80003ab2:	7179                	addi	sp,sp,-48
    80003ab4:	f406                	sd	ra,40(sp)
    80003ab6:	f022                	sd	s0,32(sp)
    80003ab8:	ec26                	sd	s1,24(sp)
    80003aba:	e84a                	sd	s2,16(sp)
    80003abc:	e44e                	sd	s3,8(sp)
    80003abe:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003ac0:	00005597          	auipc	a1,0x5
    80003ac4:	cf058593          	addi	a1,a1,-784 # 800087b0 <syscalls+0x170>
    80003ac8:	0001c517          	auipc	a0,0x1c
    80003acc:	70050513          	addi	a0,a0,1792 # 800201c8 <itable>
    80003ad0:	ffffd097          	auipc	ra,0xffffd
    80003ad4:	062080e7          	jalr	98(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003ad8:	0001c497          	auipc	s1,0x1c
    80003adc:	71848493          	addi	s1,s1,1816 # 800201f0 <itable+0x28>
    80003ae0:	0001e997          	auipc	s3,0x1e
    80003ae4:	1a098993          	addi	s3,s3,416 # 80021c80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003ae8:	00005917          	auipc	s2,0x5
    80003aec:	cd090913          	addi	s2,s2,-816 # 800087b8 <syscalls+0x178>
    80003af0:	85ca                	mv	a1,s2
    80003af2:	8526                	mv	a0,s1
    80003af4:	00001097          	auipc	ra,0x1
    80003af8:	e4a080e7          	jalr	-438(ra) # 8000493e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003afc:	08848493          	addi	s1,s1,136
    80003b00:	ff3498e3          	bne	s1,s3,80003af0 <iinit+0x3e>
}
    80003b04:	70a2                	ld	ra,40(sp)
    80003b06:	7402                	ld	s0,32(sp)
    80003b08:	64e2                	ld	s1,24(sp)
    80003b0a:	6942                	ld	s2,16(sp)
    80003b0c:	69a2                	ld	s3,8(sp)
    80003b0e:	6145                	addi	sp,sp,48
    80003b10:	8082                	ret

0000000080003b12 <ialloc>:
{
    80003b12:	715d                	addi	sp,sp,-80
    80003b14:	e486                	sd	ra,72(sp)
    80003b16:	e0a2                	sd	s0,64(sp)
    80003b18:	fc26                	sd	s1,56(sp)
    80003b1a:	f84a                	sd	s2,48(sp)
    80003b1c:	f44e                	sd	s3,40(sp)
    80003b1e:	f052                	sd	s4,32(sp)
    80003b20:	ec56                	sd	s5,24(sp)
    80003b22:	e85a                	sd	s6,16(sp)
    80003b24:	e45e                	sd	s7,8(sp)
    80003b26:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b28:	0001c717          	auipc	a4,0x1c
    80003b2c:	68c72703          	lw	a4,1676(a4) # 800201b4 <sb+0xc>
    80003b30:	4785                	li	a5,1
    80003b32:	04e7fa63          	bgeu	a5,a4,80003b86 <ialloc+0x74>
    80003b36:	8aaa                	mv	s5,a0
    80003b38:	8bae                	mv	s7,a1
    80003b3a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003b3c:	0001ca17          	auipc	s4,0x1c
    80003b40:	66ca0a13          	addi	s4,s4,1644 # 800201a8 <sb>
    80003b44:	00048b1b          	sext.w	s6,s1
    80003b48:	0044d793          	srli	a5,s1,0x4
    80003b4c:	018a2583          	lw	a1,24(s4)
    80003b50:	9dbd                	addw	a1,a1,a5
    80003b52:	8556                	mv	a0,s5
    80003b54:	00000097          	auipc	ra,0x0
    80003b58:	952080e7          	jalr	-1710(ra) # 800034a6 <bread>
    80003b5c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b5e:	05850993          	addi	s3,a0,88
    80003b62:	00f4f793          	andi	a5,s1,15
    80003b66:	079a                	slli	a5,a5,0x6
    80003b68:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b6a:	00099783          	lh	a5,0(s3)
    80003b6e:	c785                	beqz	a5,80003b96 <ialloc+0x84>
    brelse(bp);
    80003b70:	00000097          	auipc	ra,0x0
    80003b74:	a66080e7          	jalr	-1434(ra) # 800035d6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b78:	0485                	addi	s1,s1,1
    80003b7a:	00ca2703          	lw	a4,12(s4)
    80003b7e:	0004879b          	sext.w	a5,s1
    80003b82:	fce7e1e3          	bltu	a5,a4,80003b44 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003b86:	00005517          	auipc	a0,0x5
    80003b8a:	c3a50513          	addi	a0,a0,-966 # 800087c0 <syscalls+0x180>
    80003b8e:	ffffd097          	auipc	ra,0xffffd
    80003b92:	99c080e7          	jalr	-1636(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003b96:	04000613          	li	a2,64
    80003b9a:	4581                	li	a1,0
    80003b9c:	854e                	mv	a0,s3
    80003b9e:	ffffd097          	auipc	ra,0xffffd
    80003ba2:	120080e7          	jalr	288(ra) # 80000cbe <memset>
      dip->type = type;
    80003ba6:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003baa:	854a                	mv	a0,s2
    80003bac:	00001097          	auipc	ra,0x1
    80003bb0:	cac080e7          	jalr	-852(ra) # 80004858 <log_write>
      brelse(bp);
    80003bb4:	854a                	mv	a0,s2
    80003bb6:	00000097          	auipc	ra,0x0
    80003bba:	a20080e7          	jalr	-1504(ra) # 800035d6 <brelse>
      return iget(dev, inum);
    80003bbe:	85da                	mv	a1,s6
    80003bc0:	8556                	mv	a0,s5
    80003bc2:	00000097          	auipc	ra,0x0
    80003bc6:	db4080e7          	jalr	-588(ra) # 80003976 <iget>
}
    80003bca:	60a6                	ld	ra,72(sp)
    80003bcc:	6406                	ld	s0,64(sp)
    80003bce:	74e2                	ld	s1,56(sp)
    80003bd0:	7942                	ld	s2,48(sp)
    80003bd2:	79a2                	ld	s3,40(sp)
    80003bd4:	7a02                	ld	s4,32(sp)
    80003bd6:	6ae2                	ld	s5,24(sp)
    80003bd8:	6b42                	ld	s6,16(sp)
    80003bda:	6ba2                	ld	s7,8(sp)
    80003bdc:	6161                	addi	sp,sp,80
    80003bde:	8082                	ret

0000000080003be0 <iupdate>:
{
    80003be0:	1101                	addi	sp,sp,-32
    80003be2:	ec06                	sd	ra,24(sp)
    80003be4:	e822                	sd	s0,16(sp)
    80003be6:	e426                	sd	s1,8(sp)
    80003be8:	e04a                	sd	s2,0(sp)
    80003bea:	1000                	addi	s0,sp,32
    80003bec:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bee:	415c                	lw	a5,4(a0)
    80003bf0:	0047d79b          	srliw	a5,a5,0x4
    80003bf4:	0001c597          	auipc	a1,0x1c
    80003bf8:	5cc5a583          	lw	a1,1484(a1) # 800201c0 <sb+0x18>
    80003bfc:	9dbd                	addw	a1,a1,a5
    80003bfe:	4108                	lw	a0,0(a0)
    80003c00:	00000097          	auipc	ra,0x0
    80003c04:	8a6080e7          	jalr	-1882(ra) # 800034a6 <bread>
    80003c08:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c0a:	05850793          	addi	a5,a0,88
    80003c0e:	40c8                	lw	a0,4(s1)
    80003c10:	893d                	andi	a0,a0,15
    80003c12:	051a                	slli	a0,a0,0x6
    80003c14:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003c16:	04449703          	lh	a4,68(s1)
    80003c1a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003c1e:	04649703          	lh	a4,70(s1)
    80003c22:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003c26:	04849703          	lh	a4,72(s1)
    80003c2a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003c2e:	04a49703          	lh	a4,74(s1)
    80003c32:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003c36:	44f8                	lw	a4,76(s1)
    80003c38:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c3a:	03400613          	li	a2,52
    80003c3e:	05048593          	addi	a1,s1,80
    80003c42:	0531                	addi	a0,a0,12
    80003c44:	ffffd097          	auipc	ra,0xffffd
    80003c48:	0d6080e7          	jalr	214(ra) # 80000d1a <memmove>
  log_write(bp);
    80003c4c:	854a                	mv	a0,s2
    80003c4e:	00001097          	auipc	ra,0x1
    80003c52:	c0a080e7          	jalr	-1014(ra) # 80004858 <log_write>
  brelse(bp);
    80003c56:	854a                	mv	a0,s2
    80003c58:	00000097          	auipc	ra,0x0
    80003c5c:	97e080e7          	jalr	-1666(ra) # 800035d6 <brelse>
}
    80003c60:	60e2                	ld	ra,24(sp)
    80003c62:	6442                	ld	s0,16(sp)
    80003c64:	64a2                	ld	s1,8(sp)
    80003c66:	6902                	ld	s2,0(sp)
    80003c68:	6105                	addi	sp,sp,32
    80003c6a:	8082                	ret

0000000080003c6c <idup>:
{
    80003c6c:	1101                	addi	sp,sp,-32
    80003c6e:	ec06                	sd	ra,24(sp)
    80003c70:	e822                	sd	s0,16(sp)
    80003c72:	e426                	sd	s1,8(sp)
    80003c74:	1000                	addi	s0,sp,32
    80003c76:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c78:	0001c517          	auipc	a0,0x1c
    80003c7c:	55050513          	addi	a0,a0,1360 # 800201c8 <itable>
    80003c80:	ffffd097          	auipc	ra,0xffffd
    80003c84:	f42080e7          	jalr	-190(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003c88:	449c                	lw	a5,8(s1)
    80003c8a:	2785                	addiw	a5,a5,1
    80003c8c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c8e:	0001c517          	auipc	a0,0x1c
    80003c92:	53a50513          	addi	a0,a0,1338 # 800201c8 <itable>
    80003c96:	ffffd097          	auipc	ra,0xffffd
    80003c9a:	fe0080e7          	jalr	-32(ra) # 80000c76 <release>
}
    80003c9e:	8526                	mv	a0,s1
    80003ca0:	60e2                	ld	ra,24(sp)
    80003ca2:	6442                	ld	s0,16(sp)
    80003ca4:	64a2                	ld	s1,8(sp)
    80003ca6:	6105                	addi	sp,sp,32
    80003ca8:	8082                	ret

0000000080003caa <ilock>:
{
    80003caa:	1101                	addi	sp,sp,-32
    80003cac:	ec06                	sd	ra,24(sp)
    80003cae:	e822                	sd	s0,16(sp)
    80003cb0:	e426                	sd	s1,8(sp)
    80003cb2:	e04a                	sd	s2,0(sp)
    80003cb4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003cb6:	c115                	beqz	a0,80003cda <ilock+0x30>
    80003cb8:	84aa                	mv	s1,a0
    80003cba:	451c                	lw	a5,8(a0)
    80003cbc:	00f05f63          	blez	a5,80003cda <ilock+0x30>
  acquiresleep(&ip->lock);
    80003cc0:	0541                	addi	a0,a0,16
    80003cc2:	00001097          	auipc	ra,0x1
    80003cc6:	cb6080e7          	jalr	-842(ra) # 80004978 <acquiresleep>
  if(ip->valid == 0){
    80003cca:	40bc                	lw	a5,64(s1)
    80003ccc:	cf99                	beqz	a5,80003cea <ilock+0x40>
}
    80003cce:	60e2                	ld	ra,24(sp)
    80003cd0:	6442                	ld	s0,16(sp)
    80003cd2:	64a2                	ld	s1,8(sp)
    80003cd4:	6902                	ld	s2,0(sp)
    80003cd6:	6105                	addi	sp,sp,32
    80003cd8:	8082                	ret
    panic("ilock");
    80003cda:	00005517          	auipc	a0,0x5
    80003cde:	afe50513          	addi	a0,a0,-1282 # 800087d8 <syscalls+0x198>
    80003ce2:	ffffd097          	auipc	ra,0xffffd
    80003ce6:	848080e7          	jalr	-1976(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cea:	40dc                	lw	a5,4(s1)
    80003cec:	0047d79b          	srliw	a5,a5,0x4
    80003cf0:	0001c597          	auipc	a1,0x1c
    80003cf4:	4d05a583          	lw	a1,1232(a1) # 800201c0 <sb+0x18>
    80003cf8:	9dbd                	addw	a1,a1,a5
    80003cfa:	4088                	lw	a0,0(s1)
    80003cfc:	fffff097          	auipc	ra,0xfffff
    80003d00:	7aa080e7          	jalr	1962(ra) # 800034a6 <bread>
    80003d04:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d06:	05850593          	addi	a1,a0,88
    80003d0a:	40dc                	lw	a5,4(s1)
    80003d0c:	8bbd                	andi	a5,a5,15
    80003d0e:	079a                	slli	a5,a5,0x6
    80003d10:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003d12:	00059783          	lh	a5,0(a1)
    80003d16:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003d1a:	00259783          	lh	a5,2(a1)
    80003d1e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003d22:	00459783          	lh	a5,4(a1)
    80003d26:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d2a:	00659783          	lh	a5,6(a1)
    80003d2e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d32:	459c                	lw	a5,8(a1)
    80003d34:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d36:	03400613          	li	a2,52
    80003d3a:	05b1                	addi	a1,a1,12
    80003d3c:	05048513          	addi	a0,s1,80
    80003d40:	ffffd097          	auipc	ra,0xffffd
    80003d44:	fda080e7          	jalr	-38(ra) # 80000d1a <memmove>
    brelse(bp);
    80003d48:	854a                	mv	a0,s2
    80003d4a:	00000097          	auipc	ra,0x0
    80003d4e:	88c080e7          	jalr	-1908(ra) # 800035d6 <brelse>
    ip->valid = 1;
    80003d52:	4785                	li	a5,1
    80003d54:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d56:	04449783          	lh	a5,68(s1)
    80003d5a:	fbb5                	bnez	a5,80003cce <ilock+0x24>
      panic("ilock: no type");
    80003d5c:	00005517          	auipc	a0,0x5
    80003d60:	a8450513          	addi	a0,a0,-1404 # 800087e0 <syscalls+0x1a0>
    80003d64:	ffffc097          	auipc	ra,0xffffc
    80003d68:	7c6080e7          	jalr	1990(ra) # 8000052a <panic>

0000000080003d6c <iunlock>:
{
    80003d6c:	1101                	addi	sp,sp,-32
    80003d6e:	ec06                	sd	ra,24(sp)
    80003d70:	e822                	sd	s0,16(sp)
    80003d72:	e426                	sd	s1,8(sp)
    80003d74:	e04a                	sd	s2,0(sp)
    80003d76:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d78:	c905                	beqz	a0,80003da8 <iunlock+0x3c>
    80003d7a:	84aa                	mv	s1,a0
    80003d7c:	01050913          	addi	s2,a0,16
    80003d80:	854a                	mv	a0,s2
    80003d82:	00001097          	auipc	ra,0x1
    80003d86:	c90080e7          	jalr	-880(ra) # 80004a12 <holdingsleep>
    80003d8a:	cd19                	beqz	a0,80003da8 <iunlock+0x3c>
    80003d8c:	449c                	lw	a5,8(s1)
    80003d8e:	00f05d63          	blez	a5,80003da8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d92:	854a                	mv	a0,s2
    80003d94:	00001097          	auipc	ra,0x1
    80003d98:	c3a080e7          	jalr	-966(ra) # 800049ce <releasesleep>
}
    80003d9c:	60e2                	ld	ra,24(sp)
    80003d9e:	6442                	ld	s0,16(sp)
    80003da0:	64a2                	ld	s1,8(sp)
    80003da2:	6902                	ld	s2,0(sp)
    80003da4:	6105                	addi	sp,sp,32
    80003da6:	8082                	ret
    panic("iunlock");
    80003da8:	00005517          	auipc	a0,0x5
    80003dac:	a4850513          	addi	a0,a0,-1464 # 800087f0 <syscalls+0x1b0>
    80003db0:	ffffc097          	auipc	ra,0xffffc
    80003db4:	77a080e7          	jalr	1914(ra) # 8000052a <panic>

0000000080003db8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003db8:	7179                	addi	sp,sp,-48
    80003dba:	f406                	sd	ra,40(sp)
    80003dbc:	f022                	sd	s0,32(sp)
    80003dbe:	ec26                	sd	s1,24(sp)
    80003dc0:	e84a                	sd	s2,16(sp)
    80003dc2:	e44e                	sd	s3,8(sp)
    80003dc4:	e052                	sd	s4,0(sp)
    80003dc6:	1800                	addi	s0,sp,48
    80003dc8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003dca:	05050493          	addi	s1,a0,80
    80003dce:	08050913          	addi	s2,a0,128
    80003dd2:	a021                	j	80003dda <itrunc+0x22>
    80003dd4:	0491                	addi	s1,s1,4
    80003dd6:	01248d63          	beq	s1,s2,80003df0 <itrunc+0x38>
    if(ip->addrs[i]){
    80003dda:	408c                	lw	a1,0(s1)
    80003ddc:	dde5                	beqz	a1,80003dd4 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003dde:	0009a503          	lw	a0,0(s3)
    80003de2:	00000097          	auipc	ra,0x0
    80003de6:	90a080e7          	jalr	-1782(ra) # 800036ec <bfree>
      ip->addrs[i] = 0;
    80003dea:	0004a023          	sw	zero,0(s1)
    80003dee:	b7dd                	j	80003dd4 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003df0:	0809a583          	lw	a1,128(s3)
    80003df4:	e185                	bnez	a1,80003e14 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003df6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003dfa:	854e                	mv	a0,s3
    80003dfc:	00000097          	auipc	ra,0x0
    80003e00:	de4080e7          	jalr	-540(ra) # 80003be0 <iupdate>
}
    80003e04:	70a2                	ld	ra,40(sp)
    80003e06:	7402                	ld	s0,32(sp)
    80003e08:	64e2                	ld	s1,24(sp)
    80003e0a:	6942                	ld	s2,16(sp)
    80003e0c:	69a2                	ld	s3,8(sp)
    80003e0e:	6a02                	ld	s4,0(sp)
    80003e10:	6145                	addi	sp,sp,48
    80003e12:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003e14:	0009a503          	lw	a0,0(s3)
    80003e18:	fffff097          	auipc	ra,0xfffff
    80003e1c:	68e080e7          	jalr	1678(ra) # 800034a6 <bread>
    80003e20:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003e22:	05850493          	addi	s1,a0,88
    80003e26:	45850913          	addi	s2,a0,1112
    80003e2a:	a021                	j	80003e32 <itrunc+0x7a>
    80003e2c:	0491                	addi	s1,s1,4
    80003e2e:	01248b63          	beq	s1,s2,80003e44 <itrunc+0x8c>
      if(a[j])
    80003e32:	408c                	lw	a1,0(s1)
    80003e34:	dde5                	beqz	a1,80003e2c <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003e36:	0009a503          	lw	a0,0(s3)
    80003e3a:	00000097          	auipc	ra,0x0
    80003e3e:	8b2080e7          	jalr	-1870(ra) # 800036ec <bfree>
    80003e42:	b7ed                	j	80003e2c <itrunc+0x74>
    brelse(bp);
    80003e44:	8552                	mv	a0,s4
    80003e46:	fffff097          	auipc	ra,0xfffff
    80003e4a:	790080e7          	jalr	1936(ra) # 800035d6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e4e:	0809a583          	lw	a1,128(s3)
    80003e52:	0009a503          	lw	a0,0(s3)
    80003e56:	00000097          	auipc	ra,0x0
    80003e5a:	896080e7          	jalr	-1898(ra) # 800036ec <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e5e:	0809a023          	sw	zero,128(s3)
    80003e62:	bf51                	j	80003df6 <itrunc+0x3e>

0000000080003e64 <iput>:
{
    80003e64:	1101                	addi	sp,sp,-32
    80003e66:	ec06                	sd	ra,24(sp)
    80003e68:	e822                	sd	s0,16(sp)
    80003e6a:	e426                	sd	s1,8(sp)
    80003e6c:	e04a                	sd	s2,0(sp)
    80003e6e:	1000                	addi	s0,sp,32
    80003e70:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e72:	0001c517          	auipc	a0,0x1c
    80003e76:	35650513          	addi	a0,a0,854 # 800201c8 <itable>
    80003e7a:	ffffd097          	auipc	ra,0xffffd
    80003e7e:	d48080e7          	jalr	-696(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e82:	4498                	lw	a4,8(s1)
    80003e84:	4785                	li	a5,1
    80003e86:	02f70363          	beq	a4,a5,80003eac <iput+0x48>
  ip->ref--;
    80003e8a:	449c                	lw	a5,8(s1)
    80003e8c:	37fd                	addiw	a5,a5,-1
    80003e8e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e90:	0001c517          	auipc	a0,0x1c
    80003e94:	33850513          	addi	a0,a0,824 # 800201c8 <itable>
    80003e98:	ffffd097          	auipc	ra,0xffffd
    80003e9c:	dde080e7          	jalr	-546(ra) # 80000c76 <release>
}
    80003ea0:	60e2                	ld	ra,24(sp)
    80003ea2:	6442                	ld	s0,16(sp)
    80003ea4:	64a2                	ld	s1,8(sp)
    80003ea6:	6902                	ld	s2,0(sp)
    80003ea8:	6105                	addi	sp,sp,32
    80003eaa:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003eac:	40bc                	lw	a5,64(s1)
    80003eae:	dff1                	beqz	a5,80003e8a <iput+0x26>
    80003eb0:	04a49783          	lh	a5,74(s1)
    80003eb4:	fbf9                	bnez	a5,80003e8a <iput+0x26>
    acquiresleep(&ip->lock);
    80003eb6:	01048913          	addi	s2,s1,16
    80003eba:	854a                	mv	a0,s2
    80003ebc:	00001097          	auipc	ra,0x1
    80003ec0:	abc080e7          	jalr	-1348(ra) # 80004978 <acquiresleep>
    release(&itable.lock);
    80003ec4:	0001c517          	auipc	a0,0x1c
    80003ec8:	30450513          	addi	a0,a0,772 # 800201c8 <itable>
    80003ecc:	ffffd097          	auipc	ra,0xffffd
    80003ed0:	daa080e7          	jalr	-598(ra) # 80000c76 <release>
    itrunc(ip);
    80003ed4:	8526                	mv	a0,s1
    80003ed6:	00000097          	auipc	ra,0x0
    80003eda:	ee2080e7          	jalr	-286(ra) # 80003db8 <itrunc>
    ip->type = 0;
    80003ede:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003ee2:	8526                	mv	a0,s1
    80003ee4:	00000097          	auipc	ra,0x0
    80003ee8:	cfc080e7          	jalr	-772(ra) # 80003be0 <iupdate>
    ip->valid = 0;
    80003eec:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003ef0:	854a                	mv	a0,s2
    80003ef2:	00001097          	auipc	ra,0x1
    80003ef6:	adc080e7          	jalr	-1316(ra) # 800049ce <releasesleep>
    acquire(&itable.lock);
    80003efa:	0001c517          	auipc	a0,0x1c
    80003efe:	2ce50513          	addi	a0,a0,718 # 800201c8 <itable>
    80003f02:	ffffd097          	auipc	ra,0xffffd
    80003f06:	cc0080e7          	jalr	-832(ra) # 80000bc2 <acquire>
    80003f0a:	b741                	j	80003e8a <iput+0x26>

0000000080003f0c <iunlockput>:
{
    80003f0c:	1101                	addi	sp,sp,-32
    80003f0e:	ec06                	sd	ra,24(sp)
    80003f10:	e822                	sd	s0,16(sp)
    80003f12:	e426                	sd	s1,8(sp)
    80003f14:	1000                	addi	s0,sp,32
    80003f16:	84aa                	mv	s1,a0
  iunlock(ip);
    80003f18:	00000097          	auipc	ra,0x0
    80003f1c:	e54080e7          	jalr	-428(ra) # 80003d6c <iunlock>
  iput(ip);
    80003f20:	8526                	mv	a0,s1
    80003f22:	00000097          	auipc	ra,0x0
    80003f26:	f42080e7          	jalr	-190(ra) # 80003e64 <iput>
}
    80003f2a:	60e2                	ld	ra,24(sp)
    80003f2c:	6442                	ld	s0,16(sp)
    80003f2e:	64a2                	ld	s1,8(sp)
    80003f30:	6105                	addi	sp,sp,32
    80003f32:	8082                	ret

0000000080003f34 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f34:	1141                	addi	sp,sp,-16
    80003f36:	e422                	sd	s0,8(sp)
    80003f38:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f3a:	411c                	lw	a5,0(a0)
    80003f3c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f3e:	415c                	lw	a5,4(a0)
    80003f40:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f42:	04451783          	lh	a5,68(a0)
    80003f46:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f4a:	04a51783          	lh	a5,74(a0)
    80003f4e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f52:	04c56783          	lwu	a5,76(a0)
    80003f56:	e99c                	sd	a5,16(a1)
}
    80003f58:	6422                	ld	s0,8(sp)
    80003f5a:	0141                	addi	sp,sp,16
    80003f5c:	8082                	ret

0000000080003f5e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f5e:	457c                	lw	a5,76(a0)
    80003f60:	0ed7e963          	bltu	a5,a3,80004052 <readi+0xf4>
{
    80003f64:	7159                	addi	sp,sp,-112
    80003f66:	f486                	sd	ra,104(sp)
    80003f68:	f0a2                	sd	s0,96(sp)
    80003f6a:	eca6                	sd	s1,88(sp)
    80003f6c:	e8ca                	sd	s2,80(sp)
    80003f6e:	e4ce                	sd	s3,72(sp)
    80003f70:	e0d2                	sd	s4,64(sp)
    80003f72:	fc56                	sd	s5,56(sp)
    80003f74:	f85a                	sd	s6,48(sp)
    80003f76:	f45e                	sd	s7,40(sp)
    80003f78:	f062                	sd	s8,32(sp)
    80003f7a:	ec66                	sd	s9,24(sp)
    80003f7c:	e86a                	sd	s10,16(sp)
    80003f7e:	e46e                	sd	s11,8(sp)
    80003f80:	1880                	addi	s0,sp,112
    80003f82:	8baa                	mv	s7,a0
    80003f84:	8c2e                	mv	s8,a1
    80003f86:	8ab2                	mv	s5,a2
    80003f88:	84b6                	mv	s1,a3
    80003f8a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f8c:	9f35                	addw	a4,a4,a3
    return 0;
    80003f8e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f90:	0ad76063          	bltu	a4,a3,80004030 <readi+0xd2>
  if(off + n > ip->size)
    80003f94:	00e7f463          	bgeu	a5,a4,80003f9c <readi+0x3e>
    n = ip->size - off;
    80003f98:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f9c:	0a0b0963          	beqz	s6,8000404e <readi+0xf0>
    80003fa0:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fa2:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003fa6:	5cfd                	li	s9,-1
    80003fa8:	a82d                	j	80003fe2 <readi+0x84>
    80003faa:	020a1d93          	slli	s11,s4,0x20
    80003fae:	020ddd93          	srli	s11,s11,0x20
    80003fb2:	05890793          	addi	a5,s2,88
    80003fb6:	86ee                	mv	a3,s11
    80003fb8:	963e                	add	a2,a2,a5
    80003fba:	85d6                	mv	a1,s5
    80003fbc:	8562                	mv	a0,s8
    80003fbe:	ffffe097          	auipc	ra,0xffffe
    80003fc2:	6b6080e7          	jalr	1718(ra) # 80002674 <either_copyout>
    80003fc6:	05950d63          	beq	a0,s9,80004020 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003fca:	854a                	mv	a0,s2
    80003fcc:	fffff097          	auipc	ra,0xfffff
    80003fd0:	60a080e7          	jalr	1546(ra) # 800035d6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fd4:	013a09bb          	addw	s3,s4,s3
    80003fd8:	009a04bb          	addw	s1,s4,s1
    80003fdc:	9aee                	add	s5,s5,s11
    80003fde:	0569f763          	bgeu	s3,s6,8000402c <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003fe2:	000ba903          	lw	s2,0(s7)
    80003fe6:	00a4d59b          	srliw	a1,s1,0xa
    80003fea:	855e                	mv	a0,s7
    80003fec:	00000097          	auipc	ra,0x0
    80003ff0:	8ae080e7          	jalr	-1874(ra) # 8000389a <bmap>
    80003ff4:	0005059b          	sext.w	a1,a0
    80003ff8:	854a                	mv	a0,s2
    80003ffa:	fffff097          	auipc	ra,0xfffff
    80003ffe:	4ac080e7          	jalr	1196(ra) # 800034a6 <bread>
    80004002:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004004:	3ff4f613          	andi	a2,s1,1023
    80004008:	40cd07bb          	subw	a5,s10,a2
    8000400c:	413b073b          	subw	a4,s6,s3
    80004010:	8a3e                	mv	s4,a5
    80004012:	2781                	sext.w	a5,a5
    80004014:	0007069b          	sext.w	a3,a4
    80004018:	f8f6f9e3          	bgeu	a3,a5,80003faa <readi+0x4c>
    8000401c:	8a3a                	mv	s4,a4
    8000401e:	b771                	j	80003faa <readi+0x4c>
      brelse(bp);
    80004020:	854a                	mv	a0,s2
    80004022:	fffff097          	auipc	ra,0xfffff
    80004026:	5b4080e7          	jalr	1460(ra) # 800035d6 <brelse>
      tot = -1;
    8000402a:	59fd                	li	s3,-1
  }
  return tot;
    8000402c:	0009851b          	sext.w	a0,s3
}
    80004030:	70a6                	ld	ra,104(sp)
    80004032:	7406                	ld	s0,96(sp)
    80004034:	64e6                	ld	s1,88(sp)
    80004036:	6946                	ld	s2,80(sp)
    80004038:	69a6                	ld	s3,72(sp)
    8000403a:	6a06                	ld	s4,64(sp)
    8000403c:	7ae2                	ld	s5,56(sp)
    8000403e:	7b42                	ld	s6,48(sp)
    80004040:	7ba2                	ld	s7,40(sp)
    80004042:	7c02                	ld	s8,32(sp)
    80004044:	6ce2                	ld	s9,24(sp)
    80004046:	6d42                	ld	s10,16(sp)
    80004048:	6da2                	ld	s11,8(sp)
    8000404a:	6165                	addi	sp,sp,112
    8000404c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000404e:	89da                	mv	s3,s6
    80004050:	bff1                	j	8000402c <readi+0xce>
    return 0;
    80004052:	4501                	li	a0,0
}
    80004054:	8082                	ret

0000000080004056 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004056:	457c                	lw	a5,76(a0)
    80004058:	10d7e863          	bltu	a5,a3,80004168 <writei+0x112>
{
    8000405c:	7159                	addi	sp,sp,-112
    8000405e:	f486                	sd	ra,104(sp)
    80004060:	f0a2                	sd	s0,96(sp)
    80004062:	eca6                	sd	s1,88(sp)
    80004064:	e8ca                	sd	s2,80(sp)
    80004066:	e4ce                	sd	s3,72(sp)
    80004068:	e0d2                	sd	s4,64(sp)
    8000406a:	fc56                	sd	s5,56(sp)
    8000406c:	f85a                	sd	s6,48(sp)
    8000406e:	f45e                	sd	s7,40(sp)
    80004070:	f062                	sd	s8,32(sp)
    80004072:	ec66                	sd	s9,24(sp)
    80004074:	e86a                	sd	s10,16(sp)
    80004076:	e46e                	sd	s11,8(sp)
    80004078:	1880                	addi	s0,sp,112
    8000407a:	8b2a                	mv	s6,a0
    8000407c:	8c2e                	mv	s8,a1
    8000407e:	8ab2                	mv	s5,a2
    80004080:	8936                	mv	s2,a3
    80004082:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004084:	00e687bb          	addw	a5,a3,a4
    80004088:	0ed7e263          	bltu	a5,a3,8000416c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000408c:	00043737          	lui	a4,0x43
    80004090:	0ef76063          	bltu	a4,a5,80004170 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004094:	0c0b8863          	beqz	s7,80004164 <writei+0x10e>
    80004098:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000409a:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000409e:	5cfd                	li	s9,-1
    800040a0:	a091                	j	800040e4 <writei+0x8e>
    800040a2:	02099d93          	slli	s11,s3,0x20
    800040a6:	020ddd93          	srli	s11,s11,0x20
    800040aa:	05848793          	addi	a5,s1,88
    800040ae:	86ee                	mv	a3,s11
    800040b0:	8656                	mv	a2,s5
    800040b2:	85e2                	mv	a1,s8
    800040b4:	953e                	add	a0,a0,a5
    800040b6:	ffffe097          	auipc	ra,0xffffe
    800040ba:	614080e7          	jalr	1556(ra) # 800026ca <either_copyin>
    800040be:	07950263          	beq	a0,s9,80004122 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800040c2:	8526                	mv	a0,s1
    800040c4:	00000097          	auipc	ra,0x0
    800040c8:	794080e7          	jalr	1940(ra) # 80004858 <log_write>
    brelse(bp);
    800040cc:	8526                	mv	a0,s1
    800040ce:	fffff097          	auipc	ra,0xfffff
    800040d2:	508080e7          	jalr	1288(ra) # 800035d6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040d6:	01498a3b          	addw	s4,s3,s4
    800040da:	0129893b          	addw	s2,s3,s2
    800040de:	9aee                	add	s5,s5,s11
    800040e0:	057a7663          	bgeu	s4,s7,8000412c <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800040e4:	000b2483          	lw	s1,0(s6)
    800040e8:	00a9559b          	srliw	a1,s2,0xa
    800040ec:	855a                	mv	a0,s6
    800040ee:	fffff097          	auipc	ra,0xfffff
    800040f2:	7ac080e7          	jalr	1964(ra) # 8000389a <bmap>
    800040f6:	0005059b          	sext.w	a1,a0
    800040fa:	8526                	mv	a0,s1
    800040fc:	fffff097          	auipc	ra,0xfffff
    80004100:	3aa080e7          	jalr	938(ra) # 800034a6 <bread>
    80004104:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004106:	3ff97513          	andi	a0,s2,1023
    8000410a:	40ad07bb          	subw	a5,s10,a0
    8000410e:	414b873b          	subw	a4,s7,s4
    80004112:	89be                	mv	s3,a5
    80004114:	2781                	sext.w	a5,a5
    80004116:	0007069b          	sext.w	a3,a4
    8000411a:	f8f6f4e3          	bgeu	a3,a5,800040a2 <writei+0x4c>
    8000411e:	89ba                	mv	s3,a4
    80004120:	b749                	j	800040a2 <writei+0x4c>
      brelse(bp);
    80004122:	8526                	mv	a0,s1
    80004124:	fffff097          	auipc	ra,0xfffff
    80004128:	4b2080e7          	jalr	1202(ra) # 800035d6 <brelse>
  }

  if(off > ip->size)
    8000412c:	04cb2783          	lw	a5,76(s6)
    80004130:	0127f463          	bgeu	a5,s2,80004138 <writei+0xe2>
    ip->size = off;
    80004134:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004138:	855a                	mv	a0,s6
    8000413a:	00000097          	auipc	ra,0x0
    8000413e:	aa6080e7          	jalr	-1370(ra) # 80003be0 <iupdate>

  return tot;
    80004142:	000a051b          	sext.w	a0,s4
}
    80004146:	70a6                	ld	ra,104(sp)
    80004148:	7406                	ld	s0,96(sp)
    8000414a:	64e6                	ld	s1,88(sp)
    8000414c:	6946                	ld	s2,80(sp)
    8000414e:	69a6                	ld	s3,72(sp)
    80004150:	6a06                	ld	s4,64(sp)
    80004152:	7ae2                	ld	s5,56(sp)
    80004154:	7b42                	ld	s6,48(sp)
    80004156:	7ba2                	ld	s7,40(sp)
    80004158:	7c02                	ld	s8,32(sp)
    8000415a:	6ce2                	ld	s9,24(sp)
    8000415c:	6d42                	ld	s10,16(sp)
    8000415e:	6da2                	ld	s11,8(sp)
    80004160:	6165                	addi	sp,sp,112
    80004162:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004164:	8a5e                	mv	s4,s7
    80004166:	bfc9                	j	80004138 <writei+0xe2>
    return -1;
    80004168:	557d                	li	a0,-1
}
    8000416a:	8082                	ret
    return -1;
    8000416c:	557d                	li	a0,-1
    8000416e:	bfe1                	j	80004146 <writei+0xf0>
    return -1;
    80004170:	557d                	li	a0,-1
    80004172:	bfd1                	j	80004146 <writei+0xf0>

0000000080004174 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004174:	1141                	addi	sp,sp,-16
    80004176:	e406                	sd	ra,8(sp)
    80004178:	e022                	sd	s0,0(sp)
    8000417a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000417c:	4639                	li	a2,14
    8000417e:	ffffd097          	auipc	ra,0xffffd
    80004182:	c18080e7          	jalr	-1000(ra) # 80000d96 <strncmp>
}
    80004186:	60a2                	ld	ra,8(sp)
    80004188:	6402                	ld	s0,0(sp)
    8000418a:	0141                	addi	sp,sp,16
    8000418c:	8082                	ret

000000008000418e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000418e:	7139                	addi	sp,sp,-64
    80004190:	fc06                	sd	ra,56(sp)
    80004192:	f822                	sd	s0,48(sp)
    80004194:	f426                	sd	s1,40(sp)
    80004196:	f04a                	sd	s2,32(sp)
    80004198:	ec4e                	sd	s3,24(sp)
    8000419a:	e852                	sd	s4,16(sp)
    8000419c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000419e:	04451703          	lh	a4,68(a0)
    800041a2:	4785                	li	a5,1
    800041a4:	00f71a63          	bne	a4,a5,800041b8 <dirlookup+0x2a>
    800041a8:	892a                	mv	s2,a0
    800041aa:	89ae                	mv	s3,a1
    800041ac:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800041ae:	457c                	lw	a5,76(a0)
    800041b0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800041b2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041b4:	e79d                	bnez	a5,800041e2 <dirlookup+0x54>
    800041b6:	a8a5                	j	8000422e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800041b8:	00004517          	auipc	a0,0x4
    800041bc:	64050513          	addi	a0,a0,1600 # 800087f8 <syscalls+0x1b8>
    800041c0:	ffffc097          	auipc	ra,0xffffc
    800041c4:	36a080e7          	jalr	874(ra) # 8000052a <panic>
      panic("dirlookup read");
    800041c8:	00004517          	auipc	a0,0x4
    800041cc:	64850513          	addi	a0,a0,1608 # 80008810 <syscalls+0x1d0>
    800041d0:	ffffc097          	auipc	ra,0xffffc
    800041d4:	35a080e7          	jalr	858(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041d8:	24c1                	addiw	s1,s1,16
    800041da:	04c92783          	lw	a5,76(s2)
    800041de:	04f4f763          	bgeu	s1,a5,8000422c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041e2:	4741                	li	a4,16
    800041e4:	86a6                	mv	a3,s1
    800041e6:	fc040613          	addi	a2,s0,-64
    800041ea:	4581                	li	a1,0
    800041ec:	854a                	mv	a0,s2
    800041ee:	00000097          	auipc	ra,0x0
    800041f2:	d70080e7          	jalr	-656(ra) # 80003f5e <readi>
    800041f6:	47c1                	li	a5,16
    800041f8:	fcf518e3          	bne	a0,a5,800041c8 <dirlookup+0x3a>
    if(de.inum == 0)
    800041fc:	fc045783          	lhu	a5,-64(s0)
    80004200:	dfe1                	beqz	a5,800041d8 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004202:	fc240593          	addi	a1,s0,-62
    80004206:	854e                	mv	a0,s3
    80004208:	00000097          	auipc	ra,0x0
    8000420c:	f6c080e7          	jalr	-148(ra) # 80004174 <namecmp>
    80004210:	f561                	bnez	a0,800041d8 <dirlookup+0x4a>
      if(poff)
    80004212:	000a0463          	beqz	s4,8000421a <dirlookup+0x8c>
        *poff = off;
    80004216:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000421a:	fc045583          	lhu	a1,-64(s0)
    8000421e:	00092503          	lw	a0,0(s2)
    80004222:	fffff097          	auipc	ra,0xfffff
    80004226:	754080e7          	jalr	1876(ra) # 80003976 <iget>
    8000422a:	a011                	j	8000422e <dirlookup+0xa0>
  return 0;
    8000422c:	4501                	li	a0,0
}
    8000422e:	70e2                	ld	ra,56(sp)
    80004230:	7442                	ld	s0,48(sp)
    80004232:	74a2                	ld	s1,40(sp)
    80004234:	7902                	ld	s2,32(sp)
    80004236:	69e2                	ld	s3,24(sp)
    80004238:	6a42                	ld	s4,16(sp)
    8000423a:	6121                	addi	sp,sp,64
    8000423c:	8082                	ret

000000008000423e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000423e:	711d                	addi	sp,sp,-96
    80004240:	ec86                	sd	ra,88(sp)
    80004242:	e8a2                	sd	s0,80(sp)
    80004244:	e4a6                	sd	s1,72(sp)
    80004246:	e0ca                	sd	s2,64(sp)
    80004248:	fc4e                	sd	s3,56(sp)
    8000424a:	f852                	sd	s4,48(sp)
    8000424c:	f456                	sd	s5,40(sp)
    8000424e:	f05a                	sd	s6,32(sp)
    80004250:	ec5e                	sd	s7,24(sp)
    80004252:	e862                	sd	s8,16(sp)
    80004254:	e466                	sd	s9,8(sp)
    80004256:	1080                	addi	s0,sp,96
    80004258:	84aa                	mv	s1,a0
    8000425a:	8aae                	mv	s5,a1
    8000425c:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000425e:	00054703          	lbu	a4,0(a0)
    80004262:	02f00793          	li	a5,47
    80004266:	02f70363          	beq	a4,a5,8000428c <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000426a:	ffffd097          	auipc	ra,0xffffd
    8000426e:	714080e7          	jalr	1812(ra) # 8000197e <myproc>
    80004272:	17853503          	ld	a0,376(a0)
    80004276:	00000097          	auipc	ra,0x0
    8000427a:	9f6080e7          	jalr	-1546(ra) # 80003c6c <idup>
    8000427e:	89aa                	mv	s3,a0
  while(*path == '/')
    80004280:	02f00913          	li	s2,47
  len = path - s;
    80004284:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004286:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004288:	4b85                	li	s7,1
    8000428a:	a865                	j	80004342 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000428c:	4585                	li	a1,1
    8000428e:	4505                	li	a0,1
    80004290:	fffff097          	auipc	ra,0xfffff
    80004294:	6e6080e7          	jalr	1766(ra) # 80003976 <iget>
    80004298:	89aa                	mv	s3,a0
    8000429a:	b7dd                	j	80004280 <namex+0x42>
      iunlockput(ip);
    8000429c:	854e                	mv	a0,s3
    8000429e:	00000097          	auipc	ra,0x0
    800042a2:	c6e080e7          	jalr	-914(ra) # 80003f0c <iunlockput>
      return 0;
    800042a6:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800042a8:	854e                	mv	a0,s3
    800042aa:	60e6                	ld	ra,88(sp)
    800042ac:	6446                	ld	s0,80(sp)
    800042ae:	64a6                	ld	s1,72(sp)
    800042b0:	6906                	ld	s2,64(sp)
    800042b2:	79e2                	ld	s3,56(sp)
    800042b4:	7a42                	ld	s4,48(sp)
    800042b6:	7aa2                	ld	s5,40(sp)
    800042b8:	7b02                	ld	s6,32(sp)
    800042ba:	6be2                	ld	s7,24(sp)
    800042bc:	6c42                	ld	s8,16(sp)
    800042be:	6ca2                	ld	s9,8(sp)
    800042c0:	6125                	addi	sp,sp,96
    800042c2:	8082                	ret
      iunlock(ip);
    800042c4:	854e                	mv	a0,s3
    800042c6:	00000097          	auipc	ra,0x0
    800042ca:	aa6080e7          	jalr	-1370(ra) # 80003d6c <iunlock>
      return ip;
    800042ce:	bfe9                	j	800042a8 <namex+0x6a>
      iunlockput(ip);
    800042d0:	854e                	mv	a0,s3
    800042d2:	00000097          	auipc	ra,0x0
    800042d6:	c3a080e7          	jalr	-966(ra) # 80003f0c <iunlockput>
      return 0;
    800042da:	89e6                	mv	s3,s9
    800042dc:	b7f1                	j	800042a8 <namex+0x6a>
  len = path - s;
    800042de:	40b48633          	sub	a2,s1,a1
    800042e2:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800042e6:	099c5463          	bge	s8,s9,8000436e <namex+0x130>
    memmove(name, s, DIRSIZ);
    800042ea:	4639                	li	a2,14
    800042ec:	8552                	mv	a0,s4
    800042ee:	ffffd097          	auipc	ra,0xffffd
    800042f2:	a2c080e7          	jalr	-1492(ra) # 80000d1a <memmove>
  while(*path == '/')
    800042f6:	0004c783          	lbu	a5,0(s1)
    800042fa:	01279763          	bne	a5,s2,80004308 <namex+0xca>
    path++;
    800042fe:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004300:	0004c783          	lbu	a5,0(s1)
    80004304:	ff278de3          	beq	a5,s2,800042fe <namex+0xc0>
    ilock(ip);
    80004308:	854e                	mv	a0,s3
    8000430a:	00000097          	auipc	ra,0x0
    8000430e:	9a0080e7          	jalr	-1632(ra) # 80003caa <ilock>
    if(ip->type != T_DIR){
    80004312:	04499783          	lh	a5,68(s3)
    80004316:	f97793e3          	bne	a5,s7,8000429c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000431a:	000a8563          	beqz	s5,80004324 <namex+0xe6>
    8000431e:	0004c783          	lbu	a5,0(s1)
    80004322:	d3cd                	beqz	a5,800042c4 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004324:	865a                	mv	a2,s6
    80004326:	85d2                	mv	a1,s4
    80004328:	854e                	mv	a0,s3
    8000432a:	00000097          	auipc	ra,0x0
    8000432e:	e64080e7          	jalr	-412(ra) # 8000418e <dirlookup>
    80004332:	8caa                	mv	s9,a0
    80004334:	dd51                	beqz	a0,800042d0 <namex+0x92>
    iunlockput(ip);
    80004336:	854e                	mv	a0,s3
    80004338:	00000097          	auipc	ra,0x0
    8000433c:	bd4080e7          	jalr	-1068(ra) # 80003f0c <iunlockput>
    ip = next;
    80004340:	89e6                	mv	s3,s9
  while(*path == '/')
    80004342:	0004c783          	lbu	a5,0(s1)
    80004346:	05279763          	bne	a5,s2,80004394 <namex+0x156>
    path++;
    8000434a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000434c:	0004c783          	lbu	a5,0(s1)
    80004350:	ff278de3          	beq	a5,s2,8000434a <namex+0x10c>
  if(*path == 0)
    80004354:	c79d                	beqz	a5,80004382 <namex+0x144>
    path++;
    80004356:	85a6                	mv	a1,s1
  len = path - s;
    80004358:	8cda                	mv	s9,s6
    8000435a:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    8000435c:	01278963          	beq	a5,s2,8000436e <namex+0x130>
    80004360:	dfbd                	beqz	a5,800042de <namex+0xa0>
    path++;
    80004362:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004364:	0004c783          	lbu	a5,0(s1)
    80004368:	ff279ce3          	bne	a5,s2,80004360 <namex+0x122>
    8000436c:	bf8d                	j	800042de <namex+0xa0>
    memmove(name, s, len);
    8000436e:	2601                	sext.w	a2,a2
    80004370:	8552                	mv	a0,s4
    80004372:	ffffd097          	auipc	ra,0xffffd
    80004376:	9a8080e7          	jalr	-1624(ra) # 80000d1a <memmove>
    name[len] = 0;
    8000437a:	9cd2                	add	s9,s9,s4
    8000437c:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004380:	bf9d                	j	800042f6 <namex+0xb8>
  if(nameiparent){
    80004382:	f20a83e3          	beqz	s5,800042a8 <namex+0x6a>
    iput(ip);
    80004386:	854e                	mv	a0,s3
    80004388:	00000097          	auipc	ra,0x0
    8000438c:	adc080e7          	jalr	-1316(ra) # 80003e64 <iput>
    return 0;
    80004390:	4981                	li	s3,0
    80004392:	bf19                	j	800042a8 <namex+0x6a>
  if(*path == 0)
    80004394:	d7fd                	beqz	a5,80004382 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004396:	0004c783          	lbu	a5,0(s1)
    8000439a:	85a6                	mv	a1,s1
    8000439c:	b7d1                	j	80004360 <namex+0x122>

000000008000439e <dirlink>:
{
    8000439e:	7139                	addi	sp,sp,-64
    800043a0:	fc06                	sd	ra,56(sp)
    800043a2:	f822                	sd	s0,48(sp)
    800043a4:	f426                	sd	s1,40(sp)
    800043a6:	f04a                	sd	s2,32(sp)
    800043a8:	ec4e                	sd	s3,24(sp)
    800043aa:	e852                	sd	s4,16(sp)
    800043ac:	0080                	addi	s0,sp,64
    800043ae:	892a                	mv	s2,a0
    800043b0:	8a2e                	mv	s4,a1
    800043b2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800043b4:	4601                	li	a2,0
    800043b6:	00000097          	auipc	ra,0x0
    800043ba:	dd8080e7          	jalr	-552(ra) # 8000418e <dirlookup>
    800043be:	e93d                	bnez	a0,80004434 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043c0:	04c92483          	lw	s1,76(s2)
    800043c4:	c49d                	beqz	s1,800043f2 <dirlink+0x54>
    800043c6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043c8:	4741                	li	a4,16
    800043ca:	86a6                	mv	a3,s1
    800043cc:	fc040613          	addi	a2,s0,-64
    800043d0:	4581                	li	a1,0
    800043d2:	854a                	mv	a0,s2
    800043d4:	00000097          	auipc	ra,0x0
    800043d8:	b8a080e7          	jalr	-1142(ra) # 80003f5e <readi>
    800043dc:	47c1                	li	a5,16
    800043de:	06f51163          	bne	a0,a5,80004440 <dirlink+0xa2>
    if(de.inum == 0)
    800043e2:	fc045783          	lhu	a5,-64(s0)
    800043e6:	c791                	beqz	a5,800043f2 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043e8:	24c1                	addiw	s1,s1,16
    800043ea:	04c92783          	lw	a5,76(s2)
    800043ee:	fcf4ede3          	bltu	s1,a5,800043c8 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800043f2:	4639                	li	a2,14
    800043f4:	85d2                	mv	a1,s4
    800043f6:	fc240513          	addi	a0,s0,-62
    800043fa:	ffffd097          	auipc	ra,0xffffd
    800043fe:	9d8080e7          	jalr	-1576(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    80004402:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004406:	4741                	li	a4,16
    80004408:	86a6                	mv	a3,s1
    8000440a:	fc040613          	addi	a2,s0,-64
    8000440e:	4581                	li	a1,0
    80004410:	854a                	mv	a0,s2
    80004412:	00000097          	auipc	ra,0x0
    80004416:	c44080e7          	jalr	-956(ra) # 80004056 <writei>
    8000441a:	872a                	mv	a4,a0
    8000441c:	47c1                	li	a5,16
  return 0;
    8000441e:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004420:	02f71863          	bne	a4,a5,80004450 <dirlink+0xb2>
}
    80004424:	70e2                	ld	ra,56(sp)
    80004426:	7442                	ld	s0,48(sp)
    80004428:	74a2                	ld	s1,40(sp)
    8000442a:	7902                	ld	s2,32(sp)
    8000442c:	69e2                	ld	s3,24(sp)
    8000442e:	6a42                	ld	s4,16(sp)
    80004430:	6121                	addi	sp,sp,64
    80004432:	8082                	ret
    iput(ip);
    80004434:	00000097          	auipc	ra,0x0
    80004438:	a30080e7          	jalr	-1488(ra) # 80003e64 <iput>
    return -1;
    8000443c:	557d                	li	a0,-1
    8000443e:	b7dd                	j	80004424 <dirlink+0x86>
      panic("dirlink read");
    80004440:	00004517          	auipc	a0,0x4
    80004444:	3e050513          	addi	a0,a0,992 # 80008820 <syscalls+0x1e0>
    80004448:	ffffc097          	auipc	ra,0xffffc
    8000444c:	0e2080e7          	jalr	226(ra) # 8000052a <panic>
    panic("dirlink");
    80004450:	00004517          	auipc	a0,0x4
    80004454:	4d850513          	addi	a0,a0,1240 # 80008928 <syscalls+0x2e8>
    80004458:	ffffc097          	auipc	ra,0xffffc
    8000445c:	0d2080e7          	jalr	210(ra) # 8000052a <panic>

0000000080004460 <namei>:

struct inode*
namei(char *path)
{
    80004460:	1101                	addi	sp,sp,-32
    80004462:	ec06                	sd	ra,24(sp)
    80004464:	e822                	sd	s0,16(sp)
    80004466:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004468:	fe040613          	addi	a2,s0,-32
    8000446c:	4581                	li	a1,0
    8000446e:	00000097          	auipc	ra,0x0
    80004472:	dd0080e7          	jalr	-560(ra) # 8000423e <namex>
}
    80004476:	60e2                	ld	ra,24(sp)
    80004478:	6442                	ld	s0,16(sp)
    8000447a:	6105                	addi	sp,sp,32
    8000447c:	8082                	ret

000000008000447e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000447e:	1141                	addi	sp,sp,-16
    80004480:	e406                	sd	ra,8(sp)
    80004482:	e022                	sd	s0,0(sp)
    80004484:	0800                	addi	s0,sp,16
    80004486:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004488:	4585                	li	a1,1
    8000448a:	00000097          	auipc	ra,0x0
    8000448e:	db4080e7          	jalr	-588(ra) # 8000423e <namex>
}
    80004492:	60a2                	ld	ra,8(sp)
    80004494:	6402                	ld	s0,0(sp)
    80004496:	0141                	addi	sp,sp,16
    80004498:	8082                	ret

000000008000449a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000449a:	1101                	addi	sp,sp,-32
    8000449c:	ec06                	sd	ra,24(sp)
    8000449e:	e822                	sd	s0,16(sp)
    800044a0:	e426                	sd	s1,8(sp)
    800044a2:	e04a                	sd	s2,0(sp)
    800044a4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800044a6:	0001d917          	auipc	s2,0x1d
    800044aa:	7ca90913          	addi	s2,s2,1994 # 80021c70 <log>
    800044ae:	01892583          	lw	a1,24(s2)
    800044b2:	02892503          	lw	a0,40(s2)
    800044b6:	fffff097          	auipc	ra,0xfffff
    800044ba:	ff0080e7          	jalr	-16(ra) # 800034a6 <bread>
    800044be:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800044c0:	02c92683          	lw	a3,44(s2)
    800044c4:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800044c6:	02d05863          	blez	a3,800044f6 <write_head+0x5c>
    800044ca:	0001d797          	auipc	a5,0x1d
    800044ce:	7d678793          	addi	a5,a5,2006 # 80021ca0 <log+0x30>
    800044d2:	05c50713          	addi	a4,a0,92
    800044d6:	36fd                	addiw	a3,a3,-1
    800044d8:	02069613          	slli	a2,a3,0x20
    800044dc:	01e65693          	srli	a3,a2,0x1e
    800044e0:	0001d617          	auipc	a2,0x1d
    800044e4:	7c460613          	addi	a2,a2,1988 # 80021ca4 <log+0x34>
    800044e8:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800044ea:	4390                	lw	a2,0(a5)
    800044ec:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800044ee:	0791                	addi	a5,a5,4
    800044f0:	0711                	addi	a4,a4,4
    800044f2:	fed79ce3          	bne	a5,a3,800044ea <write_head+0x50>
  }
  bwrite(buf);
    800044f6:	8526                	mv	a0,s1
    800044f8:	fffff097          	auipc	ra,0xfffff
    800044fc:	0a0080e7          	jalr	160(ra) # 80003598 <bwrite>
  brelse(buf);
    80004500:	8526                	mv	a0,s1
    80004502:	fffff097          	auipc	ra,0xfffff
    80004506:	0d4080e7          	jalr	212(ra) # 800035d6 <brelse>
}
    8000450a:	60e2                	ld	ra,24(sp)
    8000450c:	6442                	ld	s0,16(sp)
    8000450e:	64a2                	ld	s1,8(sp)
    80004510:	6902                	ld	s2,0(sp)
    80004512:	6105                	addi	sp,sp,32
    80004514:	8082                	ret

0000000080004516 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004516:	0001d797          	auipc	a5,0x1d
    8000451a:	7867a783          	lw	a5,1926(a5) # 80021c9c <log+0x2c>
    8000451e:	0af05d63          	blez	a5,800045d8 <install_trans+0xc2>
{
    80004522:	7139                	addi	sp,sp,-64
    80004524:	fc06                	sd	ra,56(sp)
    80004526:	f822                	sd	s0,48(sp)
    80004528:	f426                	sd	s1,40(sp)
    8000452a:	f04a                	sd	s2,32(sp)
    8000452c:	ec4e                	sd	s3,24(sp)
    8000452e:	e852                	sd	s4,16(sp)
    80004530:	e456                	sd	s5,8(sp)
    80004532:	e05a                	sd	s6,0(sp)
    80004534:	0080                	addi	s0,sp,64
    80004536:	8b2a                	mv	s6,a0
    80004538:	0001da97          	auipc	s5,0x1d
    8000453c:	768a8a93          	addi	s5,s5,1896 # 80021ca0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004540:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004542:	0001d997          	auipc	s3,0x1d
    80004546:	72e98993          	addi	s3,s3,1838 # 80021c70 <log>
    8000454a:	a00d                	j	8000456c <install_trans+0x56>
    brelse(lbuf);
    8000454c:	854a                	mv	a0,s2
    8000454e:	fffff097          	auipc	ra,0xfffff
    80004552:	088080e7          	jalr	136(ra) # 800035d6 <brelse>
    brelse(dbuf);
    80004556:	8526                	mv	a0,s1
    80004558:	fffff097          	auipc	ra,0xfffff
    8000455c:	07e080e7          	jalr	126(ra) # 800035d6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004560:	2a05                	addiw	s4,s4,1
    80004562:	0a91                	addi	s5,s5,4
    80004564:	02c9a783          	lw	a5,44(s3)
    80004568:	04fa5e63          	bge	s4,a5,800045c4 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000456c:	0189a583          	lw	a1,24(s3)
    80004570:	014585bb          	addw	a1,a1,s4
    80004574:	2585                	addiw	a1,a1,1
    80004576:	0289a503          	lw	a0,40(s3)
    8000457a:	fffff097          	auipc	ra,0xfffff
    8000457e:	f2c080e7          	jalr	-212(ra) # 800034a6 <bread>
    80004582:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004584:	000aa583          	lw	a1,0(s5)
    80004588:	0289a503          	lw	a0,40(s3)
    8000458c:	fffff097          	auipc	ra,0xfffff
    80004590:	f1a080e7          	jalr	-230(ra) # 800034a6 <bread>
    80004594:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004596:	40000613          	li	a2,1024
    8000459a:	05890593          	addi	a1,s2,88
    8000459e:	05850513          	addi	a0,a0,88
    800045a2:	ffffc097          	auipc	ra,0xffffc
    800045a6:	778080e7          	jalr	1912(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    800045aa:	8526                	mv	a0,s1
    800045ac:	fffff097          	auipc	ra,0xfffff
    800045b0:	fec080e7          	jalr	-20(ra) # 80003598 <bwrite>
    if(recovering == 0)
    800045b4:	f80b1ce3          	bnez	s6,8000454c <install_trans+0x36>
      bunpin(dbuf);
    800045b8:	8526                	mv	a0,s1
    800045ba:	fffff097          	auipc	ra,0xfffff
    800045be:	0f6080e7          	jalr	246(ra) # 800036b0 <bunpin>
    800045c2:	b769                	j	8000454c <install_trans+0x36>
}
    800045c4:	70e2                	ld	ra,56(sp)
    800045c6:	7442                	ld	s0,48(sp)
    800045c8:	74a2                	ld	s1,40(sp)
    800045ca:	7902                	ld	s2,32(sp)
    800045cc:	69e2                	ld	s3,24(sp)
    800045ce:	6a42                	ld	s4,16(sp)
    800045d0:	6aa2                	ld	s5,8(sp)
    800045d2:	6b02                	ld	s6,0(sp)
    800045d4:	6121                	addi	sp,sp,64
    800045d6:	8082                	ret
    800045d8:	8082                	ret

00000000800045da <initlog>:
{
    800045da:	7179                	addi	sp,sp,-48
    800045dc:	f406                	sd	ra,40(sp)
    800045de:	f022                	sd	s0,32(sp)
    800045e0:	ec26                	sd	s1,24(sp)
    800045e2:	e84a                	sd	s2,16(sp)
    800045e4:	e44e                	sd	s3,8(sp)
    800045e6:	1800                	addi	s0,sp,48
    800045e8:	892a                	mv	s2,a0
    800045ea:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800045ec:	0001d497          	auipc	s1,0x1d
    800045f0:	68448493          	addi	s1,s1,1668 # 80021c70 <log>
    800045f4:	00004597          	auipc	a1,0x4
    800045f8:	23c58593          	addi	a1,a1,572 # 80008830 <syscalls+0x1f0>
    800045fc:	8526                	mv	a0,s1
    800045fe:	ffffc097          	auipc	ra,0xffffc
    80004602:	534080e7          	jalr	1332(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004606:	0149a583          	lw	a1,20(s3)
    8000460a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000460c:	0109a783          	lw	a5,16(s3)
    80004610:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004612:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004616:	854a                	mv	a0,s2
    80004618:	fffff097          	auipc	ra,0xfffff
    8000461c:	e8e080e7          	jalr	-370(ra) # 800034a6 <bread>
  log.lh.n = lh->n;
    80004620:	4d34                	lw	a3,88(a0)
    80004622:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004624:	02d05663          	blez	a3,80004650 <initlog+0x76>
    80004628:	05c50793          	addi	a5,a0,92
    8000462c:	0001d717          	auipc	a4,0x1d
    80004630:	67470713          	addi	a4,a4,1652 # 80021ca0 <log+0x30>
    80004634:	36fd                	addiw	a3,a3,-1
    80004636:	02069613          	slli	a2,a3,0x20
    8000463a:	01e65693          	srli	a3,a2,0x1e
    8000463e:	06050613          	addi	a2,a0,96
    80004642:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004644:	4390                	lw	a2,0(a5)
    80004646:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004648:	0791                	addi	a5,a5,4
    8000464a:	0711                	addi	a4,a4,4
    8000464c:	fed79ce3          	bne	a5,a3,80004644 <initlog+0x6a>
  brelse(buf);
    80004650:	fffff097          	auipc	ra,0xfffff
    80004654:	f86080e7          	jalr	-122(ra) # 800035d6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004658:	4505                	li	a0,1
    8000465a:	00000097          	auipc	ra,0x0
    8000465e:	ebc080e7          	jalr	-324(ra) # 80004516 <install_trans>
  log.lh.n = 0;
    80004662:	0001d797          	auipc	a5,0x1d
    80004666:	6207ad23          	sw	zero,1594(a5) # 80021c9c <log+0x2c>
  write_head(); // clear the log
    8000466a:	00000097          	auipc	ra,0x0
    8000466e:	e30080e7          	jalr	-464(ra) # 8000449a <write_head>
}
    80004672:	70a2                	ld	ra,40(sp)
    80004674:	7402                	ld	s0,32(sp)
    80004676:	64e2                	ld	s1,24(sp)
    80004678:	6942                	ld	s2,16(sp)
    8000467a:	69a2                	ld	s3,8(sp)
    8000467c:	6145                	addi	sp,sp,48
    8000467e:	8082                	ret

0000000080004680 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004680:	1101                	addi	sp,sp,-32
    80004682:	ec06                	sd	ra,24(sp)
    80004684:	e822                	sd	s0,16(sp)
    80004686:	e426                	sd	s1,8(sp)
    80004688:	e04a                	sd	s2,0(sp)
    8000468a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000468c:	0001d517          	auipc	a0,0x1d
    80004690:	5e450513          	addi	a0,a0,1508 # 80021c70 <log>
    80004694:	ffffc097          	auipc	ra,0xffffc
    80004698:	52e080e7          	jalr	1326(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    8000469c:	0001d497          	auipc	s1,0x1d
    800046a0:	5d448493          	addi	s1,s1,1492 # 80021c70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046a4:	4979                	li	s2,30
    800046a6:	a039                	j	800046b4 <begin_op+0x34>
      sleep(&log, &log.lock);
    800046a8:	85a6                	mv	a1,s1
    800046aa:	8526                	mv	a0,s1
    800046ac:	ffffe097          	auipc	ra,0xffffe
    800046b0:	bfc080e7          	jalr	-1028(ra) # 800022a8 <sleep>
    if(log.committing){
    800046b4:	50dc                	lw	a5,36(s1)
    800046b6:	fbed                	bnez	a5,800046a8 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046b8:	509c                	lw	a5,32(s1)
    800046ba:	0017871b          	addiw	a4,a5,1
    800046be:	0007069b          	sext.w	a3,a4
    800046c2:	0027179b          	slliw	a5,a4,0x2
    800046c6:	9fb9                	addw	a5,a5,a4
    800046c8:	0017979b          	slliw	a5,a5,0x1
    800046cc:	54d8                	lw	a4,44(s1)
    800046ce:	9fb9                	addw	a5,a5,a4
    800046d0:	00f95963          	bge	s2,a5,800046e2 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800046d4:	85a6                	mv	a1,s1
    800046d6:	8526                	mv	a0,s1
    800046d8:	ffffe097          	auipc	ra,0xffffe
    800046dc:	bd0080e7          	jalr	-1072(ra) # 800022a8 <sleep>
    800046e0:	bfd1                	j	800046b4 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800046e2:	0001d517          	auipc	a0,0x1d
    800046e6:	58e50513          	addi	a0,a0,1422 # 80021c70 <log>
    800046ea:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800046ec:	ffffc097          	auipc	ra,0xffffc
    800046f0:	58a080e7          	jalr	1418(ra) # 80000c76 <release>
      break;
    }
  }
}
    800046f4:	60e2                	ld	ra,24(sp)
    800046f6:	6442                	ld	s0,16(sp)
    800046f8:	64a2                	ld	s1,8(sp)
    800046fa:	6902                	ld	s2,0(sp)
    800046fc:	6105                	addi	sp,sp,32
    800046fe:	8082                	ret

0000000080004700 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004700:	7139                	addi	sp,sp,-64
    80004702:	fc06                	sd	ra,56(sp)
    80004704:	f822                	sd	s0,48(sp)
    80004706:	f426                	sd	s1,40(sp)
    80004708:	f04a                	sd	s2,32(sp)
    8000470a:	ec4e                	sd	s3,24(sp)
    8000470c:	e852                	sd	s4,16(sp)
    8000470e:	e456                	sd	s5,8(sp)
    80004710:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004712:	0001d497          	auipc	s1,0x1d
    80004716:	55e48493          	addi	s1,s1,1374 # 80021c70 <log>
    8000471a:	8526                	mv	a0,s1
    8000471c:	ffffc097          	auipc	ra,0xffffc
    80004720:	4a6080e7          	jalr	1190(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004724:	509c                	lw	a5,32(s1)
    80004726:	37fd                	addiw	a5,a5,-1
    80004728:	0007891b          	sext.w	s2,a5
    8000472c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000472e:	50dc                	lw	a5,36(s1)
    80004730:	e7b9                	bnez	a5,8000477e <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004732:	04091e63          	bnez	s2,8000478e <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004736:	0001d497          	auipc	s1,0x1d
    8000473a:	53a48493          	addi	s1,s1,1338 # 80021c70 <log>
    8000473e:	4785                	li	a5,1
    80004740:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004742:	8526                	mv	a0,s1
    80004744:	ffffc097          	auipc	ra,0xffffc
    80004748:	532080e7          	jalr	1330(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000474c:	54dc                	lw	a5,44(s1)
    8000474e:	06f04763          	bgtz	a5,800047bc <end_op+0xbc>
    acquire(&log.lock);
    80004752:	0001d497          	auipc	s1,0x1d
    80004756:	51e48493          	addi	s1,s1,1310 # 80021c70 <log>
    8000475a:	8526                	mv	a0,s1
    8000475c:	ffffc097          	auipc	ra,0xffffc
    80004760:	466080e7          	jalr	1126(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004764:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004768:	8526                	mv	a0,s1
    8000476a:	ffffe097          	auipc	ra,0xffffe
    8000476e:	cca080e7          	jalr	-822(ra) # 80002434 <wakeup>
    release(&log.lock);
    80004772:	8526                	mv	a0,s1
    80004774:	ffffc097          	auipc	ra,0xffffc
    80004778:	502080e7          	jalr	1282(ra) # 80000c76 <release>
}
    8000477c:	a03d                	j	800047aa <end_op+0xaa>
    panic("log.committing");
    8000477e:	00004517          	auipc	a0,0x4
    80004782:	0ba50513          	addi	a0,a0,186 # 80008838 <syscalls+0x1f8>
    80004786:	ffffc097          	auipc	ra,0xffffc
    8000478a:	da4080e7          	jalr	-604(ra) # 8000052a <panic>
    wakeup(&log);
    8000478e:	0001d497          	auipc	s1,0x1d
    80004792:	4e248493          	addi	s1,s1,1250 # 80021c70 <log>
    80004796:	8526                	mv	a0,s1
    80004798:	ffffe097          	auipc	ra,0xffffe
    8000479c:	c9c080e7          	jalr	-868(ra) # 80002434 <wakeup>
  release(&log.lock);
    800047a0:	8526                	mv	a0,s1
    800047a2:	ffffc097          	auipc	ra,0xffffc
    800047a6:	4d4080e7          	jalr	1236(ra) # 80000c76 <release>
}
    800047aa:	70e2                	ld	ra,56(sp)
    800047ac:	7442                	ld	s0,48(sp)
    800047ae:	74a2                	ld	s1,40(sp)
    800047b0:	7902                	ld	s2,32(sp)
    800047b2:	69e2                	ld	s3,24(sp)
    800047b4:	6a42                	ld	s4,16(sp)
    800047b6:	6aa2                	ld	s5,8(sp)
    800047b8:	6121                	addi	sp,sp,64
    800047ba:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800047bc:	0001da97          	auipc	s5,0x1d
    800047c0:	4e4a8a93          	addi	s5,s5,1252 # 80021ca0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800047c4:	0001da17          	auipc	s4,0x1d
    800047c8:	4aca0a13          	addi	s4,s4,1196 # 80021c70 <log>
    800047cc:	018a2583          	lw	a1,24(s4)
    800047d0:	012585bb          	addw	a1,a1,s2
    800047d4:	2585                	addiw	a1,a1,1
    800047d6:	028a2503          	lw	a0,40(s4)
    800047da:	fffff097          	auipc	ra,0xfffff
    800047de:	ccc080e7          	jalr	-820(ra) # 800034a6 <bread>
    800047e2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800047e4:	000aa583          	lw	a1,0(s5)
    800047e8:	028a2503          	lw	a0,40(s4)
    800047ec:	fffff097          	auipc	ra,0xfffff
    800047f0:	cba080e7          	jalr	-838(ra) # 800034a6 <bread>
    800047f4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800047f6:	40000613          	li	a2,1024
    800047fa:	05850593          	addi	a1,a0,88
    800047fe:	05848513          	addi	a0,s1,88
    80004802:	ffffc097          	auipc	ra,0xffffc
    80004806:	518080e7          	jalr	1304(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    8000480a:	8526                	mv	a0,s1
    8000480c:	fffff097          	auipc	ra,0xfffff
    80004810:	d8c080e7          	jalr	-628(ra) # 80003598 <bwrite>
    brelse(from);
    80004814:	854e                	mv	a0,s3
    80004816:	fffff097          	auipc	ra,0xfffff
    8000481a:	dc0080e7          	jalr	-576(ra) # 800035d6 <brelse>
    brelse(to);
    8000481e:	8526                	mv	a0,s1
    80004820:	fffff097          	auipc	ra,0xfffff
    80004824:	db6080e7          	jalr	-586(ra) # 800035d6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004828:	2905                	addiw	s2,s2,1
    8000482a:	0a91                	addi	s5,s5,4
    8000482c:	02ca2783          	lw	a5,44(s4)
    80004830:	f8f94ee3          	blt	s2,a5,800047cc <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004834:	00000097          	auipc	ra,0x0
    80004838:	c66080e7          	jalr	-922(ra) # 8000449a <write_head>
    install_trans(0); // Now install writes to home locations
    8000483c:	4501                	li	a0,0
    8000483e:	00000097          	auipc	ra,0x0
    80004842:	cd8080e7          	jalr	-808(ra) # 80004516 <install_trans>
    log.lh.n = 0;
    80004846:	0001d797          	auipc	a5,0x1d
    8000484a:	4407ab23          	sw	zero,1110(a5) # 80021c9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000484e:	00000097          	auipc	ra,0x0
    80004852:	c4c080e7          	jalr	-948(ra) # 8000449a <write_head>
    80004856:	bdf5                	j	80004752 <end_op+0x52>

0000000080004858 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004858:	1101                	addi	sp,sp,-32
    8000485a:	ec06                	sd	ra,24(sp)
    8000485c:	e822                	sd	s0,16(sp)
    8000485e:	e426                	sd	s1,8(sp)
    80004860:	e04a                	sd	s2,0(sp)
    80004862:	1000                	addi	s0,sp,32
    80004864:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004866:	0001d917          	auipc	s2,0x1d
    8000486a:	40a90913          	addi	s2,s2,1034 # 80021c70 <log>
    8000486e:	854a                	mv	a0,s2
    80004870:	ffffc097          	auipc	ra,0xffffc
    80004874:	352080e7          	jalr	850(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004878:	02c92603          	lw	a2,44(s2)
    8000487c:	47f5                	li	a5,29
    8000487e:	06c7c563          	blt	a5,a2,800048e8 <log_write+0x90>
    80004882:	0001d797          	auipc	a5,0x1d
    80004886:	40a7a783          	lw	a5,1034(a5) # 80021c8c <log+0x1c>
    8000488a:	37fd                	addiw	a5,a5,-1
    8000488c:	04f65e63          	bge	a2,a5,800048e8 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004890:	0001d797          	auipc	a5,0x1d
    80004894:	4007a783          	lw	a5,1024(a5) # 80021c90 <log+0x20>
    80004898:	06f05063          	blez	a5,800048f8 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000489c:	4781                	li	a5,0
    8000489e:	06c05563          	blez	a2,80004908 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800048a2:	44cc                	lw	a1,12(s1)
    800048a4:	0001d717          	auipc	a4,0x1d
    800048a8:	3fc70713          	addi	a4,a4,1020 # 80021ca0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800048ac:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800048ae:	4314                	lw	a3,0(a4)
    800048b0:	04b68c63          	beq	a3,a1,80004908 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800048b4:	2785                	addiw	a5,a5,1
    800048b6:	0711                	addi	a4,a4,4
    800048b8:	fef61be3          	bne	a2,a5,800048ae <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800048bc:	0621                	addi	a2,a2,8
    800048be:	060a                	slli	a2,a2,0x2
    800048c0:	0001d797          	auipc	a5,0x1d
    800048c4:	3b078793          	addi	a5,a5,944 # 80021c70 <log>
    800048c8:	963e                	add	a2,a2,a5
    800048ca:	44dc                	lw	a5,12(s1)
    800048cc:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800048ce:	8526                	mv	a0,s1
    800048d0:	fffff097          	auipc	ra,0xfffff
    800048d4:	da4080e7          	jalr	-604(ra) # 80003674 <bpin>
    log.lh.n++;
    800048d8:	0001d717          	auipc	a4,0x1d
    800048dc:	39870713          	addi	a4,a4,920 # 80021c70 <log>
    800048e0:	575c                	lw	a5,44(a4)
    800048e2:	2785                	addiw	a5,a5,1
    800048e4:	d75c                	sw	a5,44(a4)
    800048e6:	a835                	j	80004922 <log_write+0xca>
    panic("too big a transaction");
    800048e8:	00004517          	auipc	a0,0x4
    800048ec:	f6050513          	addi	a0,a0,-160 # 80008848 <syscalls+0x208>
    800048f0:	ffffc097          	auipc	ra,0xffffc
    800048f4:	c3a080e7          	jalr	-966(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    800048f8:	00004517          	auipc	a0,0x4
    800048fc:	f6850513          	addi	a0,a0,-152 # 80008860 <syscalls+0x220>
    80004900:	ffffc097          	auipc	ra,0xffffc
    80004904:	c2a080e7          	jalr	-982(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004908:	00878713          	addi	a4,a5,8
    8000490c:	00271693          	slli	a3,a4,0x2
    80004910:	0001d717          	auipc	a4,0x1d
    80004914:	36070713          	addi	a4,a4,864 # 80021c70 <log>
    80004918:	9736                	add	a4,a4,a3
    8000491a:	44d4                	lw	a3,12(s1)
    8000491c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000491e:	faf608e3          	beq	a2,a5,800048ce <log_write+0x76>
  }
  release(&log.lock);
    80004922:	0001d517          	auipc	a0,0x1d
    80004926:	34e50513          	addi	a0,a0,846 # 80021c70 <log>
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	34c080e7          	jalr	844(ra) # 80000c76 <release>
}
    80004932:	60e2                	ld	ra,24(sp)
    80004934:	6442                	ld	s0,16(sp)
    80004936:	64a2                	ld	s1,8(sp)
    80004938:	6902                	ld	s2,0(sp)
    8000493a:	6105                	addi	sp,sp,32
    8000493c:	8082                	ret

000000008000493e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000493e:	1101                	addi	sp,sp,-32
    80004940:	ec06                	sd	ra,24(sp)
    80004942:	e822                	sd	s0,16(sp)
    80004944:	e426                	sd	s1,8(sp)
    80004946:	e04a                	sd	s2,0(sp)
    80004948:	1000                	addi	s0,sp,32
    8000494a:	84aa                	mv	s1,a0
    8000494c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000494e:	00004597          	auipc	a1,0x4
    80004952:	f3258593          	addi	a1,a1,-206 # 80008880 <syscalls+0x240>
    80004956:	0521                	addi	a0,a0,8
    80004958:	ffffc097          	auipc	ra,0xffffc
    8000495c:	1da080e7          	jalr	474(ra) # 80000b32 <initlock>
  lk->name = name;
    80004960:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004964:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004968:	0204a423          	sw	zero,40(s1)
}
    8000496c:	60e2                	ld	ra,24(sp)
    8000496e:	6442                	ld	s0,16(sp)
    80004970:	64a2                	ld	s1,8(sp)
    80004972:	6902                	ld	s2,0(sp)
    80004974:	6105                	addi	sp,sp,32
    80004976:	8082                	ret

0000000080004978 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004978:	1101                	addi	sp,sp,-32
    8000497a:	ec06                	sd	ra,24(sp)
    8000497c:	e822                	sd	s0,16(sp)
    8000497e:	e426                	sd	s1,8(sp)
    80004980:	e04a                	sd	s2,0(sp)
    80004982:	1000                	addi	s0,sp,32
    80004984:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004986:	00850913          	addi	s2,a0,8
    8000498a:	854a                	mv	a0,s2
    8000498c:	ffffc097          	auipc	ra,0xffffc
    80004990:	236080e7          	jalr	566(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    80004994:	409c                	lw	a5,0(s1)
    80004996:	cb89                	beqz	a5,800049a8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004998:	85ca                	mv	a1,s2
    8000499a:	8526                	mv	a0,s1
    8000499c:	ffffe097          	auipc	ra,0xffffe
    800049a0:	90c080e7          	jalr	-1780(ra) # 800022a8 <sleep>
  while (lk->locked) {
    800049a4:	409c                	lw	a5,0(s1)
    800049a6:	fbed                	bnez	a5,80004998 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800049a8:	4785                	li	a5,1
    800049aa:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800049ac:	ffffd097          	auipc	ra,0xffffd
    800049b0:	fd2080e7          	jalr	-46(ra) # 8000197e <myproc>
    800049b4:	591c                	lw	a5,48(a0)
    800049b6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800049b8:	854a                	mv	a0,s2
    800049ba:	ffffc097          	auipc	ra,0xffffc
    800049be:	2bc080e7          	jalr	700(ra) # 80000c76 <release>
}
    800049c2:	60e2                	ld	ra,24(sp)
    800049c4:	6442                	ld	s0,16(sp)
    800049c6:	64a2                	ld	s1,8(sp)
    800049c8:	6902                	ld	s2,0(sp)
    800049ca:	6105                	addi	sp,sp,32
    800049cc:	8082                	ret

00000000800049ce <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800049ce:	1101                	addi	sp,sp,-32
    800049d0:	ec06                	sd	ra,24(sp)
    800049d2:	e822                	sd	s0,16(sp)
    800049d4:	e426                	sd	s1,8(sp)
    800049d6:	e04a                	sd	s2,0(sp)
    800049d8:	1000                	addi	s0,sp,32
    800049da:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049dc:	00850913          	addi	s2,a0,8
    800049e0:	854a                	mv	a0,s2
    800049e2:	ffffc097          	auipc	ra,0xffffc
    800049e6:	1e0080e7          	jalr	480(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    800049ea:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049ee:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800049f2:	8526                	mv	a0,s1
    800049f4:	ffffe097          	auipc	ra,0xffffe
    800049f8:	a40080e7          	jalr	-1472(ra) # 80002434 <wakeup>
  release(&lk->lk);
    800049fc:	854a                	mv	a0,s2
    800049fe:	ffffc097          	auipc	ra,0xffffc
    80004a02:	278080e7          	jalr	632(ra) # 80000c76 <release>
}
    80004a06:	60e2                	ld	ra,24(sp)
    80004a08:	6442                	ld	s0,16(sp)
    80004a0a:	64a2                	ld	s1,8(sp)
    80004a0c:	6902                	ld	s2,0(sp)
    80004a0e:	6105                	addi	sp,sp,32
    80004a10:	8082                	ret

0000000080004a12 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a12:	7179                	addi	sp,sp,-48
    80004a14:	f406                	sd	ra,40(sp)
    80004a16:	f022                	sd	s0,32(sp)
    80004a18:	ec26                	sd	s1,24(sp)
    80004a1a:	e84a                	sd	s2,16(sp)
    80004a1c:	e44e                	sd	s3,8(sp)
    80004a1e:	1800                	addi	s0,sp,48
    80004a20:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a22:	00850913          	addi	s2,a0,8
    80004a26:	854a                	mv	a0,s2
    80004a28:	ffffc097          	auipc	ra,0xffffc
    80004a2c:	19a080e7          	jalr	410(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a30:	409c                	lw	a5,0(s1)
    80004a32:	ef99                	bnez	a5,80004a50 <holdingsleep+0x3e>
    80004a34:	4481                	li	s1,0
  release(&lk->lk);
    80004a36:	854a                	mv	a0,s2
    80004a38:	ffffc097          	auipc	ra,0xffffc
    80004a3c:	23e080e7          	jalr	574(ra) # 80000c76 <release>
  return r;
}
    80004a40:	8526                	mv	a0,s1
    80004a42:	70a2                	ld	ra,40(sp)
    80004a44:	7402                	ld	s0,32(sp)
    80004a46:	64e2                	ld	s1,24(sp)
    80004a48:	6942                	ld	s2,16(sp)
    80004a4a:	69a2                	ld	s3,8(sp)
    80004a4c:	6145                	addi	sp,sp,48
    80004a4e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a50:	0284a983          	lw	s3,40(s1)
    80004a54:	ffffd097          	auipc	ra,0xffffd
    80004a58:	f2a080e7          	jalr	-214(ra) # 8000197e <myproc>
    80004a5c:	5904                	lw	s1,48(a0)
    80004a5e:	413484b3          	sub	s1,s1,s3
    80004a62:	0014b493          	seqz	s1,s1
    80004a66:	bfc1                	j	80004a36 <holdingsleep+0x24>

0000000080004a68 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a68:	1141                	addi	sp,sp,-16
    80004a6a:	e406                	sd	ra,8(sp)
    80004a6c:	e022                	sd	s0,0(sp)
    80004a6e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a70:	00004597          	auipc	a1,0x4
    80004a74:	e2058593          	addi	a1,a1,-480 # 80008890 <syscalls+0x250>
    80004a78:	0001d517          	auipc	a0,0x1d
    80004a7c:	34050513          	addi	a0,a0,832 # 80021db8 <ftable>
    80004a80:	ffffc097          	auipc	ra,0xffffc
    80004a84:	0b2080e7          	jalr	178(ra) # 80000b32 <initlock>
}
    80004a88:	60a2                	ld	ra,8(sp)
    80004a8a:	6402                	ld	s0,0(sp)
    80004a8c:	0141                	addi	sp,sp,16
    80004a8e:	8082                	ret

0000000080004a90 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a90:	1101                	addi	sp,sp,-32
    80004a92:	ec06                	sd	ra,24(sp)
    80004a94:	e822                	sd	s0,16(sp)
    80004a96:	e426                	sd	s1,8(sp)
    80004a98:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a9a:	0001d517          	auipc	a0,0x1d
    80004a9e:	31e50513          	addi	a0,a0,798 # 80021db8 <ftable>
    80004aa2:	ffffc097          	auipc	ra,0xffffc
    80004aa6:	120080e7          	jalr	288(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004aaa:	0001d497          	auipc	s1,0x1d
    80004aae:	32648493          	addi	s1,s1,806 # 80021dd0 <ftable+0x18>
    80004ab2:	0001e717          	auipc	a4,0x1e
    80004ab6:	2be70713          	addi	a4,a4,702 # 80022d70 <ftable+0xfb8>
    if(f->ref == 0){
    80004aba:	40dc                	lw	a5,4(s1)
    80004abc:	cf99                	beqz	a5,80004ada <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004abe:	02848493          	addi	s1,s1,40
    80004ac2:	fee49ce3          	bne	s1,a4,80004aba <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004ac6:	0001d517          	auipc	a0,0x1d
    80004aca:	2f250513          	addi	a0,a0,754 # 80021db8 <ftable>
    80004ace:	ffffc097          	auipc	ra,0xffffc
    80004ad2:	1a8080e7          	jalr	424(ra) # 80000c76 <release>
  return 0;
    80004ad6:	4481                	li	s1,0
    80004ad8:	a819                	j	80004aee <filealloc+0x5e>
      f->ref = 1;
    80004ada:	4785                	li	a5,1
    80004adc:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004ade:	0001d517          	auipc	a0,0x1d
    80004ae2:	2da50513          	addi	a0,a0,730 # 80021db8 <ftable>
    80004ae6:	ffffc097          	auipc	ra,0xffffc
    80004aea:	190080e7          	jalr	400(ra) # 80000c76 <release>
}
    80004aee:	8526                	mv	a0,s1
    80004af0:	60e2                	ld	ra,24(sp)
    80004af2:	6442                	ld	s0,16(sp)
    80004af4:	64a2                	ld	s1,8(sp)
    80004af6:	6105                	addi	sp,sp,32
    80004af8:	8082                	ret

0000000080004afa <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004afa:	1101                	addi	sp,sp,-32
    80004afc:	ec06                	sd	ra,24(sp)
    80004afe:	e822                	sd	s0,16(sp)
    80004b00:	e426                	sd	s1,8(sp)
    80004b02:	1000                	addi	s0,sp,32
    80004b04:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b06:	0001d517          	auipc	a0,0x1d
    80004b0a:	2b250513          	addi	a0,a0,690 # 80021db8 <ftable>
    80004b0e:	ffffc097          	auipc	ra,0xffffc
    80004b12:	0b4080e7          	jalr	180(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004b16:	40dc                	lw	a5,4(s1)
    80004b18:	02f05263          	blez	a5,80004b3c <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b1c:	2785                	addiw	a5,a5,1
    80004b1e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b20:	0001d517          	auipc	a0,0x1d
    80004b24:	29850513          	addi	a0,a0,664 # 80021db8 <ftable>
    80004b28:	ffffc097          	auipc	ra,0xffffc
    80004b2c:	14e080e7          	jalr	334(ra) # 80000c76 <release>
  return f;
}
    80004b30:	8526                	mv	a0,s1
    80004b32:	60e2                	ld	ra,24(sp)
    80004b34:	6442                	ld	s0,16(sp)
    80004b36:	64a2                	ld	s1,8(sp)
    80004b38:	6105                	addi	sp,sp,32
    80004b3a:	8082                	ret
    panic("filedup");
    80004b3c:	00004517          	auipc	a0,0x4
    80004b40:	d5c50513          	addi	a0,a0,-676 # 80008898 <syscalls+0x258>
    80004b44:	ffffc097          	auipc	ra,0xffffc
    80004b48:	9e6080e7          	jalr	-1562(ra) # 8000052a <panic>

0000000080004b4c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004b4c:	7139                	addi	sp,sp,-64
    80004b4e:	fc06                	sd	ra,56(sp)
    80004b50:	f822                	sd	s0,48(sp)
    80004b52:	f426                	sd	s1,40(sp)
    80004b54:	f04a                	sd	s2,32(sp)
    80004b56:	ec4e                	sd	s3,24(sp)
    80004b58:	e852                	sd	s4,16(sp)
    80004b5a:	e456                	sd	s5,8(sp)
    80004b5c:	0080                	addi	s0,sp,64
    80004b5e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004b60:	0001d517          	auipc	a0,0x1d
    80004b64:	25850513          	addi	a0,a0,600 # 80021db8 <ftable>
    80004b68:	ffffc097          	auipc	ra,0xffffc
    80004b6c:	05a080e7          	jalr	90(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004b70:	40dc                	lw	a5,4(s1)
    80004b72:	06f05163          	blez	a5,80004bd4 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004b76:	37fd                	addiw	a5,a5,-1
    80004b78:	0007871b          	sext.w	a4,a5
    80004b7c:	c0dc                	sw	a5,4(s1)
    80004b7e:	06e04363          	bgtz	a4,80004be4 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b82:	0004a903          	lw	s2,0(s1)
    80004b86:	0094ca83          	lbu	s5,9(s1)
    80004b8a:	0104ba03          	ld	s4,16(s1)
    80004b8e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004b92:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b96:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b9a:	0001d517          	auipc	a0,0x1d
    80004b9e:	21e50513          	addi	a0,a0,542 # 80021db8 <ftable>
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	0d4080e7          	jalr	212(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    80004baa:	4785                	li	a5,1
    80004bac:	04f90d63          	beq	s2,a5,80004c06 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004bb0:	3979                	addiw	s2,s2,-2
    80004bb2:	4785                	li	a5,1
    80004bb4:	0527e063          	bltu	a5,s2,80004bf4 <fileclose+0xa8>
    begin_op();
    80004bb8:	00000097          	auipc	ra,0x0
    80004bbc:	ac8080e7          	jalr	-1336(ra) # 80004680 <begin_op>
    iput(ff.ip);
    80004bc0:	854e                	mv	a0,s3
    80004bc2:	fffff097          	auipc	ra,0xfffff
    80004bc6:	2a2080e7          	jalr	674(ra) # 80003e64 <iput>
    end_op();
    80004bca:	00000097          	auipc	ra,0x0
    80004bce:	b36080e7          	jalr	-1226(ra) # 80004700 <end_op>
    80004bd2:	a00d                	j	80004bf4 <fileclose+0xa8>
    panic("fileclose");
    80004bd4:	00004517          	auipc	a0,0x4
    80004bd8:	ccc50513          	addi	a0,a0,-820 # 800088a0 <syscalls+0x260>
    80004bdc:	ffffc097          	auipc	ra,0xffffc
    80004be0:	94e080e7          	jalr	-1714(ra) # 8000052a <panic>
    release(&ftable.lock);
    80004be4:	0001d517          	auipc	a0,0x1d
    80004be8:	1d450513          	addi	a0,a0,468 # 80021db8 <ftable>
    80004bec:	ffffc097          	auipc	ra,0xffffc
    80004bf0:	08a080e7          	jalr	138(ra) # 80000c76 <release>
  }
}
    80004bf4:	70e2                	ld	ra,56(sp)
    80004bf6:	7442                	ld	s0,48(sp)
    80004bf8:	74a2                	ld	s1,40(sp)
    80004bfa:	7902                	ld	s2,32(sp)
    80004bfc:	69e2                	ld	s3,24(sp)
    80004bfe:	6a42                	ld	s4,16(sp)
    80004c00:	6aa2                	ld	s5,8(sp)
    80004c02:	6121                	addi	sp,sp,64
    80004c04:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c06:	85d6                	mv	a1,s5
    80004c08:	8552                	mv	a0,s4
    80004c0a:	00000097          	auipc	ra,0x0
    80004c0e:	34c080e7          	jalr	844(ra) # 80004f56 <pipeclose>
    80004c12:	b7cd                	j	80004bf4 <fileclose+0xa8>

0000000080004c14 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c14:	715d                	addi	sp,sp,-80
    80004c16:	e486                	sd	ra,72(sp)
    80004c18:	e0a2                	sd	s0,64(sp)
    80004c1a:	fc26                	sd	s1,56(sp)
    80004c1c:	f84a                	sd	s2,48(sp)
    80004c1e:	f44e                	sd	s3,40(sp)
    80004c20:	0880                	addi	s0,sp,80
    80004c22:	84aa                	mv	s1,a0
    80004c24:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c26:	ffffd097          	auipc	ra,0xffffd
    80004c2a:	d58080e7          	jalr	-680(ra) # 8000197e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c2e:	409c                	lw	a5,0(s1)
    80004c30:	37f9                	addiw	a5,a5,-2
    80004c32:	4705                	li	a4,1
    80004c34:	04f76763          	bltu	a4,a5,80004c82 <filestat+0x6e>
    80004c38:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c3a:	6c88                	ld	a0,24(s1)
    80004c3c:	fffff097          	auipc	ra,0xfffff
    80004c40:	06e080e7          	jalr	110(ra) # 80003caa <ilock>
    stati(f->ip, &st);
    80004c44:	fb840593          	addi	a1,s0,-72
    80004c48:	6c88                	ld	a0,24(s1)
    80004c4a:	fffff097          	auipc	ra,0xfffff
    80004c4e:	2ea080e7          	jalr	746(ra) # 80003f34 <stati>
    iunlock(f->ip);
    80004c52:	6c88                	ld	a0,24(s1)
    80004c54:	fffff097          	auipc	ra,0xfffff
    80004c58:	118080e7          	jalr	280(ra) # 80003d6c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004c5c:	46e1                	li	a3,24
    80004c5e:	fb840613          	addi	a2,s0,-72
    80004c62:	85ce                	mv	a1,s3
    80004c64:	07893503          	ld	a0,120(s2)
    80004c68:	ffffd097          	auipc	ra,0xffffd
    80004c6c:	9d6080e7          	jalr	-1578(ra) # 8000163e <copyout>
    80004c70:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004c74:	60a6                	ld	ra,72(sp)
    80004c76:	6406                	ld	s0,64(sp)
    80004c78:	74e2                	ld	s1,56(sp)
    80004c7a:	7942                	ld	s2,48(sp)
    80004c7c:	79a2                	ld	s3,40(sp)
    80004c7e:	6161                	addi	sp,sp,80
    80004c80:	8082                	ret
  return -1;
    80004c82:	557d                	li	a0,-1
    80004c84:	bfc5                	j	80004c74 <filestat+0x60>

0000000080004c86 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c86:	7179                	addi	sp,sp,-48
    80004c88:	f406                	sd	ra,40(sp)
    80004c8a:	f022                	sd	s0,32(sp)
    80004c8c:	ec26                	sd	s1,24(sp)
    80004c8e:	e84a                	sd	s2,16(sp)
    80004c90:	e44e                	sd	s3,8(sp)
    80004c92:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c94:	00854783          	lbu	a5,8(a0)
    80004c98:	c3d5                	beqz	a5,80004d3c <fileread+0xb6>
    80004c9a:	84aa                	mv	s1,a0
    80004c9c:	89ae                	mv	s3,a1
    80004c9e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ca0:	411c                	lw	a5,0(a0)
    80004ca2:	4705                	li	a4,1
    80004ca4:	04e78963          	beq	a5,a4,80004cf6 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ca8:	470d                	li	a4,3
    80004caa:	04e78d63          	beq	a5,a4,80004d04 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cae:	4709                	li	a4,2
    80004cb0:	06e79e63          	bne	a5,a4,80004d2c <fileread+0xa6>
    ilock(f->ip);
    80004cb4:	6d08                	ld	a0,24(a0)
    80004cb6:	fffff097          	auipc	ra,0xfffff
    80004cba:	ff4080e7          	jalr	-12(ra) # 80003caa <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004cbe:	874a                	mv	a4,s2
    80004cc0:	5094                	lw	a3,32(s1)
    80004cc2:	864e                	mv	a2,s3
    80004cc4:	4585                	li	a1,1
    80004cc6:	6c88                	ld	a0,24(s1)
    80004cc8:	fffff097          	auipc	ra,0xfffff
    80004ccc:	296080e7          	jalr	662(ra) # 80003f5e <readi>
    80004cd0:	892a                	mv	s2,a0
    80004cd2:	00a05563          	blez	a0,80004cdc <fileread+0x56>
      f->off += r;
    80004cd6:	509c                	lw	a5,32(s1)
    80004cd8:	9fa9                	addw	a5,a5,a0
    80004cda:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004cdc:	6c88                	ld	a0,24(s1)
    80004cde:	fffff097          	auipc	ra,0xfffff
    80004ce2:	08e080e7          	jalr	142(ra) # 80003d6c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004ce6:	854a                	mv	a0,s2
    80004ce8:	70a2                	ld	ra,40(sp)
    80004cea:	7402                	ld	s0,32(sp)
    80004cec:	64e2                	ld	s1,24(sp)
    80004cee:	6942                	ld	s2,16(sp)
    80004cf0:	69a2                	ld	s3,8(sp)
    80004cf2:	6145                	addi	sp,sp,48
    80004cf4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004cf6:	6908                	ld	a0,16(a0)
    80004cf8:	00000097          	auipc	ra,0x0
    80004cfc:	3c0080e7          	jalr	960(ra) # 800050b8 <piperead>
    80004d00:	892a                	mv	s2,a0
    80004d02:	b7d5                	j	80004ce6 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d04:	02451783          	lh	a5,36(a0)
    80004d08:	03079693          	slli	a3,a5,0x30
    80004d0c:	92c1                	srli	a3,a3,0x30
    80004d0e:	4725                	li	a4,9
    80004d10:	02d76863          	bltu	a4,a3,80004d40 <fileread+0xba>
    80004d14:	0792                	slli	a5,a5,0x4
    80004d16:	0001d717          	auipc	a4,0x1d
    80004d1a:	00270713          	addi	a4,a4,2 # 80021d18 <devsw>
    80004d1e:	97ba                	add	a5,a5,a4
    80004d20:	639c                	ld	a5,0(a5)
    80004d22:	c38d                	beqz	a5,80004d44 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004d24:	4505                	li	a0,1
    80004d26:	9782                	jalr	a5
    80004d28:	892a                	mv	s2,a0
    80004d2a:	bf75                	j	80004ce6 <fileread+0x60>
    panic("fileread");
    80004d2c:	00004517          	auipc	a0,0x4
    80004d30:	b8450513          	addi	a0,a0,-1148 # 800088b0 <syscalls+0x270>
    80004d34:	ffffb097          	auipc	ra,0xffffb
    80004d38:	7f6080e7          	jalr	2038(ra) # 8000052a <panic>
    return -1;
    80004d3c:	597d                	li	s2,-1
    80004d3e:	b765                	j	80004ce6 <fileread+0x60>
      return -1;
    80004d40:	597d                	li	s2,-1
    80004d42:	b755                	j	80004ce6 <fileread+0x60>
    80004d44:	597d                	li	s2,-1
    80004d46:	b745                	j	80004ce6 <fileread+0x60>

0000000080004d48 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004d48:	715d                	addi	sp,sp,-80
    80004d4a:	e486                	sd	ra,72(sp)
    80004d4c:	e0a2                	sd	s0,64(sp)
    80004d4e:	fc26                	sd	s1,56(sp)
    80004d50:	f84a                	sd	s2,48(sp)
    80004d52:	f44e                	sd	s3,40(sp)
    80004d54:	f052                	sd	s4,32(sp)
    80004d56:	ec56                	sd	s5,24(sp)
    80004d58:	e85a                	sd	s6,16(sp)
    80004d5a:	e45e                	sd	s7,8(sp)
    80004d5c:	e062                	sd	s8,0(sp)
    80004d5e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004d60:	00954783          	lbu	a5,9(a0)
    80004d64:	10078663          	beqz	a5,80004e70 <filewrite+0x128>
    80004d68:	892a                	mv	s2,a0
    80004d6a:	8aae                	mv	s5,a1
    80004d6c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d6e:	411c                	lw	a5,0(a0)
    80004d70:	4705                	li	a4,1
    80004d72:	02e78263          	beq	a5,a4,80004d96 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d76:	470d                	li	a4,3
    80004d78:	02e78663          	beq	a5,a4,80004da4 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d7c:	4709                	li	a4,2
    80004d7e:	0ee79163          	bne	a5,a4,80004e60 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d82:	0ac05d63          	blez	a2,80004e3c <filewrite+0xf4>
    int i = 0;
    80004d86:	4981                	li	s3,0
    80004d88:	6b05                	lui	s6,0x1
    80004d8a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004d8e:	6b85                	lui	s7,0x1
    80004d90:	c00b8b9b          	addiw	s7,s7,-1024
    80004d94:	a861                	j	80004e2c <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004d96:	6908                	ld	a0,16(a0)
    80004d98:	00000097          	auipc	ra,0x0
    80004d9c:	22e080e7          	jalr	558(ra) # 80004fc6 <pipewrite>
    80004da0:	8a2a                	mv	s4,a0
    80004da2:	a045                	j	80004e42 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004da4:	02451783          	lh	a5,36(a0)
    80004da8:	03079693          	slli	a3,a5,0x30
    80004dac:	92c1                	srli	a3,a3,0x30
    80004dae:	4725                	li	a4,9
    80004db0:	0cd76263          	bltu	a4,a3,80004e74 <filewrite+0x12c>
    80004db4:	0792                	slli	a5,a5,0x4
    80004db6:	0001d717          	auipc	a4,0x1d
    80004dba:	f6270713          	addi	a4,a4,-158 # 80021d18 <devsw>
    80004dbe:	97ba                	add	a5,a5,a4
    80004dc0:	679c                	ld	a5,8(a5)
    80004dc2:	cbdd                	beqz	a5,80004e78 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004dc4:	4505                	li	a0,1
    80004dc6:	9782                	jalr	a5
    80004dc8:	8a2a                	mv	s4,a0
    80004dca:	a8a5                	j	80004e42 <filewrite+0xfa>
    80004dcc:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004dd0:	00000097          	auipc	ra,0x0
    80004dd4:	8b0080e7          	jalr	-1872(ra) # 80004680 <begin_op>
      ilock(f->ip);
    80004dd8:	01893503          	ld	a0,24(s2)
    80004ddc:	fffff097          	auipc	ra,0xfffff
    80004de0:	ece080e7          	jalr	-306(ra) # 80003caa <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004de4:	8762                	mv	a4,s8
    80004de6:	02092683          	lw	a3,32(s2)
    80004dea:	01598633          	add	a2,s3,s5
    80004dee:	4585                	li	a1,1
    80004df0:	01893503          	ld	a0,24(s2)
    80004df4:	fffff097          	auipc	ra,0xfffff
    80004df8:	262080e7          	jalr	610(ra) # 80004056 <writei>
    80004dfc:	84aa                	mv	s1,a0
    80004dfe:	00a05763          	blez	a0,80004e0c <filewrite+0xc4>
        f->off += r;
    80004e02:	02092783          	lw	a5,32(s2)
    80004e06:	9fa9                	addw	a5,a5,a0
    80004e08:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e0c:	01893503          	ld	a0,24(s2)
    80004e10:	fffff097          	auipc	ra,0xfffff
    80004e14:	f5c080e7          	jalr	-164(ra) # 80003d6c <iunlock>
      end_op();
    80004e18:	00000097          	auipc	ra,0x0
    80004e1c:	8e8080e7          	jalr	-1816(ra) # 80004700 <end_op>

      if(r != n1){
    80004e20:	009c1f63          	bne	s8,s1,80004e3e <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004e24:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e28:	0149db63          	bge	s3,s4,80004e3e <filewrite+0xf6>
      int n1 = n - i;
    80004e2c:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004e30:	84be                	mv	s1,a5
    80004e32:	2781                	sext.w	a5,a5
    80004e34:	f8fb5ce3          	bge	s6,a5,80004dcc <filewrite+0x84>
    80004e38:	84de                	mv	s1,s7
    80004e3a:	bf49                	j	80004dcc <filewrite+0x84>
    int i = 0;
    80004e3c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e3e:	013a1f63          	bne	s4,s3,80004e5c <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e42:	8552                	mv	a0,s4
    80004e44:	60a6                	ld	ra,72(sp)
    80004e46:	6406                	ld	s0,64(sp)
    80004e48:	74e2                	ld	s1,56(sp)
    80004e4a:	7942                	ld	s2,48(sp)
    80004e4c:	79a2                	ld	s3,40(sp)
    80004e4e:	7a02                	ld	s4,32(sp)
    80004e50:	6ae2                	ld	s5,24(sp)
    80004e52:	6b42                	ld	s6,16(sp)
    80004e54:	6ba2                	ld	s7,8(sp)
    80004e56:	6c02                	ld	s8,0(sp)
    80004e58:	6161                	addi	sp,sp,80
    80004e5a:	8082                	ret
    ret = (i == n ? n : -1);
    80004e5c:	5a7d                	li	s4,-1
    80004e5e:	b7d5                	j	80004e42 <filewrite+0xfa>
    panic("filewrite");
    80004e60:	00004517          	auipc	a0,0x4
    80004e64:	a6050513          	addi	a0,a0,-1440 # 800088c0 <syscalls+0x280>
    80004e68:	ffffb097          	auipc	ra,0xffffb
    80004e6c:	6c2080e7          	jalr	1730(ra) # 8000052a <panic>
    return -1;
    80004e70:	5a7d                	li	s4,-1
    80004e72:	bfc1                	j	80004e42 <filewrite+0xfa>
      return -1;
    80004e74:	5a7d                	li	s4,-1
    80004e76:	b7f1                	j	80004e42 <filewrite+0xfa>
    80004e78:	5a7d                	li	s4,-1
    80004e7a:	b7e1                	j	80004e42 <filewrite+0xfa>

0000000080004e7c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004e7c:	7179                	addi	sp,sp,-48
    80004e7e:	f406                	sd	ra,40(sp)
    80004e80:	f022                	sd	s0,32(sp)
    80004e82:	ec26                	sd	s1,24(sp)
    80004e84:	e84a                	sd	s2,16(sp)
    80004e86:	e44e                	sd	s3,8(sp)
    80004e88:	e052                	sd	s4,0(sp)
    80004e8a:	1800                	addi	s0,sp,48
    80004e8c:	84aa                	mv	s1,a0
    80004e8e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e90:	0005b023          	sd	zero,0(a1)
    80004e94:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e98:	00000097          	auipc	ra,0x0
    80004e9c:	bf8080e7          	jalr	-1032(ra) # 80004a90 <filealloc>
    80004ea0:	e088                	sd	a0,0(s1)
    80004ea2:	c551                	beqz	a0,80004f2e <pipealloc+0xb2>
    80004ea4:	00000097          	auipc	ra,0x0
    80004ea8:	bec080e7          	jalr	-1044(ra) # 80004a90 <filealloc>
    80004eac:	00aa3023          	sd	a0,0(s4)
    80004eb0:	c92d                	beqz	a0,80004f22 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004eb2:	ffffc097          	auipc	ra,0xffffc
    80004eb6:	c20080e7          	jalr	-992(ra) # 80000ad2 <kalloc>
    80004eba:	892a                	mv	s2,a0
    80004ebc:	c125                	beqz	a0,80004f1c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004ebe:	4985                	li	s3,1
    80004ec0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004ec4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ec8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ecc:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ed0:	00003597          	auipc	a1,0x3
    80004ed4:	5e058593          	addi	a1,a1,1504 # 800084b0 <states.0+0x1e0>
    80004ed8:	ffffc097          	auipc	ra,0xffffc
    80004edc:	c5a080e7          	jalr	-934(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80004ee0:	609c                	ld	a5,0(s1)
    80004ee2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ee6:	609c                	ld	a5,0(s1)
    80004ee8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004eec:	609c                	ld	a5,0(s1)
    80004eee:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ef2:	609c                	ld	a5,0(s1)
    80004ef4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ef8:	000a3783          	ld	a5,0(s4)
    80004efc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f00:	000a3783          	ld	a5,0(s4)
    80004f04:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f08:	000a3783          	ld	a5,0(s4)
    80004f0c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f10:	000a3783          	ld	a5,0(s4)
    80004f14:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f18:	4501                	li	a0,0
    80004f1a:	a025                	j	80004f42 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f1c:	6088                	ld	a0,0(s1)
    80004f1e:	e501                	bnez	a0,80004f26 <pipealloc+0xaa>
    80004f20:	a039                	j	80004f2e <pipealloc+0xb2>
    80004f22:	6088                	ld	a0,0(s1)
    80004f24:	c51d                	beqz	a0,80004f52 <pipealloc+0xd6>
    fileclose(*f0);
    80004f26:	00000097          	auipc	ra,0x0
    80004f2a:	c26080e7          	jalr	-986(ra) # 80004b4c <fileclose>
  if(*f1)
    80004f2e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004f32:	557d                	li	a0,-1
  if(*f1)
    80004f34:	c799                	beqz	a5,80004f42 <pipealloc+0xc6>
    fileclose(*f1);
    80004f36:	853e                	mv	a0,a5
    80004f38:	00000097          	auipc	ra,0x0
    80004f3c:	c14080e7          	jalr	-1004(ra) # 80004b4c <fileclose>
  return -1;
    80004f40:	557d                	li	a0,-1
}
    80004f42:	70a2                	ld	ra,40(sp)
    80004f44:	7402                	ld	s0,32(sp)
    80004f46:	64e2                	ld	s1,24(sp)
    80004f48:	6942                	ld	s2,16(sp)
    80004f4a:	69a2                	ld	s3,8(sp)
    80004f4c:	6a02                	ld	s4,0(sp)
    80004f4e:	6145                	addi	sp,sp,48
    80004f50:	8082                	ret
  return -1;
    80004f52:	557d                	li	a0,-1
    80004f54:	b7fd                	j	80004f42 <pipealloc+0xc6>

0000000080004f56 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004f56:	1101                	addi	sp,sp,-32
    80004f58:	ec06                	sd	ra,24(sp)
    80004f5a:	e822                	sd	s0,16(sp)
    80004f5c:	e426                	sd	s1,8(sp)
    80004f5e:	e04a                	sd	s2,0(sp)
    80004f60:	1000                	addi	s0,sp,32
    80004f62:	84aa                	mv	s1,a0
    80004f64:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f66:	ffffc097          	auipc	ra,0xffffc
    80004f6a:	c5c080e7          	jalr	-932(ra) # 80000bc2 <acquire>
  if(writable){
    80004f6e:	02090d63          	beqz	s2,80004fa8 <pipeclose+0x52>
    pi->writeopen = 0;
    80004f72:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004f76:	21848513          	addi	a0,s1,536
    80004f7a:	ffffd097          	auipc	ra,0xffffd
    80004f7e:	4ba080e7          	jalr	1210(ra) # 80002434 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f82:	2204b783          	ld	a5,544(s1)
    80004f86:	eb95                	bnez	a5,80004fba <pipeclose+0x64>
    release(&pi->lock);
    80004f88:	8526                	mv	a0,s1
    80004f8a:	ffffc097          	auipc	ra,0xffffc
    80004f8e:	cec080e7          	jalr	-788(ra) # 80000c76 <release>
    kfree((char*)pi);
    80004f92:	8526                	mv	a0,s1
    80004f94:	ffffc097          	auipc	ra,0xffffc
    80004f98:	a42080e7          	jalr	-1470(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    80004f9c:	60e2                	ld	ra,24(sp)
    80004f9e:	6442                	ld	s0,16(sp)
    80004fa0:	64a2                	ld	s1,8(sp)
    80004fa2:	6902                	ld	s2,0(sp)
    80004fa4:	6105                	addi	sp,sp,32
    80004fa6:	8082                	ret
    pi->readopen = 0;
    80004fa8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004fac:	21c48513          	addi	a0,s1,540
    80004fb0:	ffffd097          	auipc	ra,0xffffd
    80004fb4:	484080e7          	jalr	1156(ra) # 80002434 <wakeup>
    80004fb8:	b7e9                	j	80004f82 <pipeclose+0x2c>
    release(&pi->lock);
    80004fba:	8526                	mv	a0,s1
    80004fbc:	ffffc097          	auipc	ra,0xffffc
    80004fc0:	cba080e7          	jalr	-838(ra) # 80000c76 <release>
}
    80004fc4:	bfe1                	j	80004f9c <pipeclose+0x46>

0000000080004fc6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004fc6:	711d                	addi	sp,sp,-96
    80004fc8:	ec86                	sd	ra,88(sp)
    80004fca:	e8a2                	sd	s0,80(sp)
    80004fcc:	e4a6                	sd	s1,72(sp)
    80004fce:	e0ca                	sd	s2,64(sp)
    80004fd0:	fc4e                	sd	s3,56(sp)
    80004fd2:	f852                	sd	s4,48(sp)
    80004fd4:	f456                	sd	s5,40(sp)
    80004fd6:	f05a                	sd	s6,32(sp)
    80004fd8:	ec5e                	sd	s7,24(sp)
    80004fda:	e862                	sd	s8,16(sp)
    80004fdc:	1080                	addi	s0,sp,96
    80004fde:	84aa                	mv	s1,a0
    80004fe0:	8aae                	mv	s5,a1
    80004fe2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004fe4:	ffffd097          	auipc	ra,0xffffd
    80004fe8:	99a080e7          	jalr	-1638(ra) # 8000197e <myproc>
    80004fec:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004fee:	8526                	mv	a0,s1
    80004ff0:	ffffc097          	auipc	ra,0xffffc
    80004ff4:	bd2080e7          	jalr	-1070(ra) # 80000bc2 <acquire>
  while(i < n){
    80004ff8:	0b405363          	blez	s4,8000509e <pipewrite+0xd8>
  int i = 0;
    80004ffc:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ffe:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005000:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005004:	21c48b93          	addi	s7,s1,540
    80005008:	a089                	j	8000504a <pipewrite+0x84>
      release(&pi->lock);
    8000500a:	8526                	mv	a0,s1
    8000500c:	ffffc097          	auipc	ra,0xffffc
    80005010:	c6a080e7          	jalr	-918(ra) # 80000c76 <release>
      return -1;
    80005014:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005016:	854a                	mv	a0,s2
    80005018:	60e6                	ld	ra,88(sp)
    8000501a:	6446                	ld	s0,80(sp)
    8000501c:	64a6                	ld	s1,72(sp)
    8000501e:	6906                	ld	s2,64(sp)
    80005020:	79e2                	ld	s3,56(sp)
    80005022:	7a42                	ld	s4,48(sp)
    80005024:	7aa2                	ld	s5,40(sp)
    80005026:	7b02                	ld	s6,32(sp)
    80005028:	6be2                	ld	s7,24(sp)
    8000502a:	6c42                	ld	s8,16(sp)
    8000502c:	6125                	addi	sp,sp,96
    8000502e:	8082                	ret
      wakeup(&pi->nread);
    80005030:	8562                	mv	a0,s8
    80005032:	ffffd097          	auipc	ra,0xffffd
    80005036:	402080e7          	jalr	1026(ra) # 80002434 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000503a:	85a6                	mv	a1,s1
    8000503c:	855e                	mv	a0,s7
    8000503e:	ffffd097          	auipc	ra,0xffffd
    80005042:	26a080e7          	jalr	618(ra) # 800022a8 <sleep>
  while(i < n){
    80005046:	05495d63          	bge	s2,s4,800050a0 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    8000504a:	2204a783          	lw	a5,544(s1)
    8000504e:	dfd5                	beqz	a5,8000500a <pipewrite+0x44>
    80005050:	0289a783          	lw	a5,40(s3)
    80005054:	fbdd                	bnez	a5,8000500a <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005056:	2184a783          	lw	a5,536(s1)
    8000505a:	21c4a703          	lw	a4,540(s1)
    8000505e:	2007879b          	addiw	a5,a5,512
    80005062:	fcf707e3          	beq	a4,a5,80005030 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005066:	4685                	li	a3,1
    80005068:	01590633          	add	a2,s2,s5
    8000506c:	faf40593          	addi	a1,s0,-81
    80005070:	0789b503          	ld	a0,120(s3)
    80005074:	ffffc097          	auipc	ra,0xffffc
    80005078:	656080e7          	jalr	1622(ra) # 800016ca <copyin>
    8000507c:	03650263          	beq	a0,s6,800050a0 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005080:	21c4a783          	lw	a5,540(s1)
    80005084:	0017871b          	addiw	a4,a5,1
    80005088:	20e4ae23          	sw	a4,540(s1)
    8000508c:	1ff7f793          	andi	a5,a5,511
    80005090:	97a6                	add	a5,a5,s1
    80005092:	faf44703          	lbu	a4,-81(s0)
    80005096:	00e78c23          	sb	a4,24(a5)
      i++;
    8000509a:	2905                	addiw	s2,s2,1
    8000509c:	b76d                	j	80005046 <pipewrite+0x80>
  int i = 0;
    8000509e:	4901                	li	s2,0
  wakeup(&pi->nread);
    800050a0:	21848513          	addi	a0,s1,536
    800050a4:	ffffd097          	auipc	ra,0xffffd
    800050a8:	390080e7          	jalr	912(ra) # 80002434 <wakeup>
  release(&pi->lock);
    800050ac:	8526                	mv	a0,s1
    800050ae:	ffffc097          	auipc	ra,0xffffc
    800050b2:	bc8080e7          	jalr	-1080(ra) # 80000c76 <release>
  return i;
    800050b6:	b785                	j	80005016 <pipewrite+0x50>

00000000800050b8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800050b8:	715d                	addi	sp,sp,-80
    800050ba:	e486                	sd	ra,72(sp)
    800050bc:	e0a2                	sd	s0,64(sp)
    800050be:	fc26                	sd	s1,56(sp)
    800050c0:	f84a                	sd	s2,48(sp)
    800050c2:	f44e                	sd	s3,40(sp)
    800050c4:	f052                	sd	s4,32(sp)
    800050c6:	ec56                	sd	s5,24(sp)
    800050c8:	e85a                	sd	s6,16(sp)
    800050ca:	0880                	addi	s0,sp,80
    800050cc:	84aa                	mv	s1,a0
    800050ce:	892e                	mv	s2,a1
    800050d0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800050d2:	ffffd097          	auipc	ra,0xffffd
    800050d6:	8ac080e7          	jalr	-1876(ra) # 8000197e <myproc>
    800050da:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800050dc:	8526                	mv	a0,s1
    800050de:	ffffc097          	auipc	ra,0xffffc
    800050e2:	ae4080e7          	jalr	-1308(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050e6:	2184a703          	lw	a4,536(s1)
    800050ea:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050ee:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050f2:	02f71463          	bne	a4,a5,8000511a <piperead+0x62>
    800050f6:	2244a783          	lw	a5,548(s1)
    800050fa:	c385                	beqz	a5,8000511a <piperead+0x62>
    if(pr->killed){
    800050fc:	028a2783          	lw	a5,40(s4)
    80005100:	ebc1                	bnez	a5,80005190 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005102:	85a6                	mv	a1,s1
    80005104:	854e                	mv	a0,s3
    80005106:	ffffd097          	auipc	ra,0xffffd
    8000510a:	1a2080e7          	jalr	418(ra) # 800022a8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000510e:	2184a703          	lw	a4,536(s1)
    80005112:	21c4a783          	lw	a5,540(s1)
    80005116:	fef700e3          	beq	a4,a5,800050f6 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000511a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000511c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000511e:	05505363          	blez	s5,80005164 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80005122:	2184a783          	lw	a5,536(s1)
    80005126:	21c4a703          	lw	a4,540(s1)
    8000512a:	02f70d63          	beq	a4,a5,80005164 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000512e:	0017871b          	addiw	a4,a5,1
    80005132:	20e4ac23          	sw	a4,536(s1)
    80005136:	1ff7f793          	andi	a5,a5,511
    8000513a:	97a6                	add	a5,a5,s1
    8000513c:	0187c783          	lbu	a5,24(a5)
    80005140:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005144:	4685                	li	a3,1
    80005146:	fbf40613          	addi	a2,s0,-65
    8000514a:	85ca                	mv	a1,s2
    8000514c:	078a3503          	ld	a0,120(s4)
    80005150:	ffffc097          	auipc	ra,0xffffc
    80005154:	4ee080e7          	jalr	1262(ra) # 8000163e <copyout>
    80005158:	01650663          	beq	a0,s6,80005164 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000515c:	2985                	addiw	s3,s3,1
    8000515e:	0905                	addi	s2,s2,1
    80005160:	fd3a91e3          	bne	s5,s3,80005122 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005164:	21c48513          	addi	a0,s1,540
    80005168:	ffffd097          	auipc	ra,0xffffd
    8000516c:	2cc080e7          	jalr	716(ra) # 80002434 <wakeup>
  release(&pi->lock);
    80005170:	8526                	mv	a0,s1
    80005172:	ffffc097          	auipc	ra,0xffffc
    80005176:	b04080e7          	jalr	-1276(ra) # 80000c76 <release>
  return i;
}
    8000517a:	854e                	mv	a0,s3
    8000517c:	60a6                	ld	ra,72(sp)
    8000517e:	6406                	ld	s0,64(sp)
    80005180:	74e2                	ld	s1,56(sp)
    80005182:	7942                	ld	s2,48(sp)
    80005184:	79a2                	ld	s3,40(sp)
    80005186:	7a02                	ld	s4,32(sp)
    80005188:	6ae2                	ld	s5,24(sp)
    8000518a:	6b42                	ld	s6,16(sp)
    8000518c:	6161                	addi	sp,sp,80
    8000518e:	8082                	ret
      release(&pi->lock);
    80005190:	8526                	mv	a0,s1
    80005192:	ffffc097          	auipc	ra,0xffffc
    80005196:	ae4080e7          	jalr	-1308(ra) # 80000c76 <release>
      return -1;
    8000519a:	59fd                	li	s3,-1
    8000519c:	bff9                	j	8000517a <piperead+0xc2>

000000008000519e <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    8000519e:	de010113          	addi	sp,sp,-544
    800051a2:	20113c23          	sd	ra,536(sp)
    800051a6:	20813823          	sd	s0,528(sp)
    800051aa:	20913423          	sd	s1,520(sp)
    800051ae:	21213023          	sd	s2,512(sp)
    800051b2:	ffce                	sd	s3,504(sp)
    800051b4:	fbd2                	sd	s4,496(sp)
    800051b6:	f7d6                	sd	s5,488(sp)
    800051b8:	f3da                	sd	s6,480(sp)
    800051ba:	efde                	sd	s7,472(sp)
    800051bc:	ebe2                	sd	s8,464(sp)
    800051be:	e7e6                	sd	s9,456(sp)
    800051c0:	e3ea                	sd	s10,448(sp)
    800051c2:	ff6e                	sd	s11,440(sp)
    800051c4:	1400                	addi	s0,sp,544
    800051c6:	892a                	mv	s2,a0
    800051c8:	dea43423          	sd	a0,-536(s0)
    800051cc:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800051d0:	ffffc097          	auipc	ra,0xffffc
    800051d4:	7ae080e7          	jalr	1966(ra) # 8000197e <myproc>
    800051d8:	84aa                	mv	s1,a0

  begin_op();
    800051da:	fffff097          	auipc	ra,0xfffff
    800051de:	4a6080e7          	jalr	1190(ra) # 80004680 <begin_op>

  if((ip = namei(path)) == 0){
    800051e2:	854a                	mv	a0,s2
    800051e4:	fffff097          	auipc	ra,0xfffff
    800051e8:	27c080e7          	jalr	636(ra) # 80004460 <namei>
    800051ec:	c93d                	beqz	a0,80005262 <exec+0xc4>
    800051ee:	8aaa                	mv	s5,a0
    end_op();
    /////////////////////////////we changed the return value in this case from -1
    return -2;
  }
  ilock(ip);
    800051f0:	fffff097          	auipc	ra,0xfffff
    800051f4:	aba080e7          	jalr	-1350(ra) # 80003caa <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800051f8:	04000713          	li	a4,64
    800051fc:	4681                	li	a3,0
    800051fe:	e4840613          	addi	a2,s0,-440
    80005202:	4581                	li	a1,0
    80005204:	8556                	mv	a0,s5
    80005206:	fffff097          	auipc	ra,0xfffff
    8000520a:	d58080e7          	jalr	-680(ra) # 80003f5e <readi>
    8000520e:	04000793          	li	a5,64
    80005212:	00f51a63          	bne	a0,a5,80005226 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005216:	e4842703          	lw	a4,-440(s0)
    8000521a:	464c47b7          	lui	a5,0x464c4
    8000521e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005222:	04f70663          	beq	a4,a5,8000526e <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005226:	8556                	mv	a0,s5
    80005228:	fffff097          	auipc	ra,0xfffff
    8000522c:	ce4080e7          	jalr	-796(ra) # 80003f0c <iunlockput>
    end_op();
    80005230:	fffff097          	auipc	ra,0xfffff
    80005234:	4d0080e7          	jalr	1232(ra) # 80004700 <end_op>
  }
  return -1;
    80005238:	557d                	li	a0,-1
}
    8000523a:	21813083          	ld	ra,536(sp)
    8000523e:	21013403          	ld	s0,528(sp)
    80005242:	20813483          	ld	s1,520(sp)
    80005246:	20013903          	ld	s2,512(sp)
    8000524a:	79fe                	ld	s3,504(sp)
    8000524c:	7a5e                	ld	s4,496(sp)
    8000524e:	7abe                	ld	s5,488(sp)
    80005250:	7b1e                	ld	s6,480(sp)
    80005252:	6bfe                	ld	s7,472(sp)
    80005254:	6c5e                	ld	s8,464(sp)
    80005256:	6cbe                	ld	s9,456(sp)
    80005258:	6d1e                	ld	s10,448(sp)
    8000525a:	7dfa                	ld	s11,440(sp)
    8000525c:	22010113          	addi	sp,sp,544
    80005260:	8082                	ret
    end_op();
    80005262:	fffff097          	auipc	ra,0xfffff
    80005266:	49e080e7          	jalr	1182(ra) # 80004700 <end_op>
    return -2;
    8000526a:	5579                	li	a0,-2
    8000526c:	b7f9                	j	8000523a <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000526e:	8526                	mv	a0,s1
    80005270:	ffffc097          	auipc	ra,0xffffc
    80005274:	7d2080e7          	jalr	2002(ra) # 80001a42 <proc_pagetable>
    80005278:	8b2a                	mv	s6,a0
    8000527a:	d555                	beqz	a0,80005226 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000527c:	e6842783          	lw	a5,-408(s0)
    80005280:	e8045703          	lhu	a4,-384(s0)
    80005284:	c735                	beqz	a4,800052f0 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005286:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005288:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000528c:	6a05                	lui	s4,0x1
    8000528e:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005292:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005296:	6d85                	lui	s11,0x1
    80005298:	7d7d                	lui	s10,0xfffff
    8000529a:	ac1d                	j	800054d0 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000529c:	00003517          	auipc	a0,0x3
    800052a0:	63450513          	addi	a0,a0,1588 # 800088d0 <syscalls+0x290>
    800052a4:	ffffb097          	auipc	ra,0xffffb
    800052a8:	286080e7          	jalr	646(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800052ac:	874a                	mv	a4,s2
    800052ae:	009c86bb          	addw	a3,s9,s1
    800052b2:	4581                	li	a1,0
    800052b4:	8556                	mv	a0,s5
    800052b6:	fffff097          	auipc	ra,0xfffff
    800052ba:	ca8080e7          	jalr	-856(ra) # 80003f5e <readi>
    800052be:	2501                	sext.w	a0,a0
    800052c0:	1aa91863          	bne	s2,a0,80005470 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    800052c4:	009d84bb          	addw	s1,s11,s1
    800052c8:	013d09bb          	addw	s3,s10,s3
    800052cc:	1f74f263          	bgeu	s1,s7,800054b0 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    800052d0:	02049593          	slli	a1,s1,0x20
    800052d4:	9181                	srli	a1,a1,0x20
    800052d6:	95e2                	add	a1,a1,s8
    800052d8:	855a                	mv	a0,s6
    800052da:	ffffc097          	auipc	ra,0xffffc
    800052de:	d72080e7          	jalr	-654(ra) # 8000104c <walkaddr>
    800052e2:	862a                	mv	a2,a0
    if(pa == 0)
    800052e4:	dd45                	beqz	a0,8000529c <exec+0xfe>
      n = PGSIZE;
    800052e6:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800052e8:	fd49f2e3          	bgeu	s3,s4,800052ac <exec+0x10e>
      n = sz - i;
    800052ec:	894e                	mv	s2,s3
    800052ee:	bf7d                	j	800052ac <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800052f0:	4481                	li	s1,0
  iunlockput(ip);
    800052f2:	8556                	mv	a0,s5
    800052f4:	fffff097          	auipc	ra,0xfffff
    800052f8:	c18080e7          	jalr	-1000(ra) # 80003f0c <iunlockput>
  end_op();
    800052fc:	fffff097          	auipc	ra,0xfffff
    80005300:	404080e7          	jalr	1028(ra) # 80004700 <end_op>
  p = myproc();
    80005304:	ffffc097          	auipc	ra,0xffffc
    80005308:	67a080e7          	jalr	1658(ra) # 8000197e <myproc>
    8000530c:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000530e:	07053d03          	ld	s10,112(a0)
  sz = PGROUNDUP(sz);
    80005312:	6785                	lui	a5,0x1
    80005314:	17fd                	addi	a5,a5,-1
    80005316:	94be                	add	s1,s1,a5
    80005318:	77fd                	lui	a5,0xfffff
    8000531a:	8fe5                	and	a5,a5,s1
    8000531c:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005320:	6609                	lui	a2,0x2
    80005322:	963e                	add	a2,a2,a5
    80005324:	85be                	mv	a1,a5
    80005326:	855a                	mv	a0,s6
    80005328:	ffffc097          	auipc	ra,0xffffc
    8000532c:	0c6080e7          	jalr	198(ra) # 800013ee <uvmalloc>
    80005330:	8c2a                	mv	s8,a0
  ip = 0;
    80005332:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005334:	12050e63          	beqz	a0,80005470 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005338:	75f9                	lui	a1,0xffffe
    8000533a:	95aa                	add	a1,a1,a0
    8000533c:	855a                	mv	a0,s6
    8000533e:	ffffc097          	auipc	ra,0xffffc
    80005342:	2ce080e7          	jalr	718(ra) # 8000160c <uvmclear>
  stackbase = sp - PGSIZE;
    80005346:	7afd                	lui	s5,0xfffff
    80005348:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000534a:	df043783          	ld	a5,-528(s0)
    8000534e:	6388                	ld	a0,0(a5)
    80005350:	c925                	beqz	a0,800053c0 <exec+0x222>
    80005352:	e8840993          	addi	s3,s0,-376
    80005356:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    8000535a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000535c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000535e:	ffffc097          	auipc	ra,0xffffc
    80005362:	ae4080e7          	jalr	-1308(ra) # 80000e42 <strlen>
    80005366:	0015079b          	addiw	a5,a0,1
    8000536a:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000536e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005372:	13596363          	bltu	s2,s5,80005498 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005376:	df043d83          	ld	s11,-528(s0)
    8000537a:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000537e:	8552                	mv	a0,s4
    80005380:	ffffc097          	auipc	ra,0xffffc
    80005384:	ac2080e7          	jalr	-1342(ra) # 80000e42 <strlen>
    80005388:	0015069b          	addiw	a3,a0,1
    8000538c:	8652                	mv	a2,s4
    8000538e:	85ca                	mv	a1,s2
    80005390:	855a                	mv	a0,s6
    80005392:	ffffc097          	auipc	ra,0xffffc
    80005396:	2ac080e7          	jalr	684(ra) # 8000163e <copyout>
    8000539a:	10054363          	bltz	a0,800054a0 <exec+0x302>
    ustack[argc] = sp;
    8000539e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800053a2:	0485                	addi	s1,s1,1
    800053a4:	008d8793          	addi	a5,s11,8
    800053a8:	def43823          	sd	a5,-528(s0)
    800053ac:	008db503          	ld	a0,8(s11)
    800053b0:	c911                	beqz	a0,800053c4 <exec+0x226>
    if(argc >= MAXARG)
    800053b2:	09a1                	addi	s3,s3,8
    800053b4:	fb3c95e3          	bne	s9,s3,8000535e <exec+0x1c0>
  sz = sz1;
    800053b8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053bc:	4a81                	li	s5,0
    800053be:	a84d                	j	80005470 <exec+0x2d2>
  sp = sz;
    800053c0:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800053c2:	4481                	li	s1,0
  ustack[argc] = 0;
    800053c4:	00349793          	slli	a5,s1,0x3
    800053c8:	f9040713          	addi	a4,s0,-112
    800053cc:	97ba                	add	a5,a5,a4
    800053ce:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    800053d2:	00148693          	addi	a3,s1,1
    800053d6:	068e                	slli	a3,a3,0x3
    800053d8:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800053dc:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800053e0:	01597663          	bgeu	s2,s5,800053ec <exec+0x24e>
  sz = sz1;
    800053e4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053e8:	4a81                	li	s5,0
    800053ea:	a059                	j	80005470 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800053ec:	e8840613          	addi	a2,s0,-376
    800053f0:	85ca                	mv	a1,s2
    800053f2:	855a                	mv	a0,s6
    800053f4:	ffffc097          	auipc	ra,0xffffc
    800053f8:	24a080e7          	jalr	586(ra) # 8000163e <copyout>
    800053fc:	0a054663          	bltz	a0,800054a8 <exec+0x30a>
  p->trapframe->a1 = sp;
    80005400:	080bb783          	ld	a5,128(s7) # 1080 <_entry-0x7fffef80>
    80005404:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005408:	de843783          	ld	a5,-536(s0)
    8000540c:	0007c703          	lbu	a4,0(a5)
    80005410:	cf11                	beqz	a4,8000542c <exec+0x28e>
    80005412:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005414:	02f00693          	li	a3,47
    80005418:	a039                	j	80005426 <exec+0x288>
      last = s+1;
    8000541a:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000541e:	0785                	addi	a5,a5,1
    80005420:	fff7c703          	lbu	a4,-1(a5)
    80005424:	c701                	beqz	a4,8000542c <exec+0x28e>
    if(*s == '/')
    80005426:	fed71ce3          	bne	a4,a3,8000541e <exec+0x280>
    8000542a:	bfc5                	j	8000541a <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000542c:	4641                	li	a2,16
    8000542e:	de843583          	ld	a1,-536(s0)
    80005432:	180b8513          	addi	a0,s7,384
    80005436:	ffffc097          	auipc	ra,0xffffc
    8000543a:	9da080e7          	jalr	-1574(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    8000543e:	078bb503          	ld	a0,120(s7)
  p->pagetable = pagetable;
    80005442:	076bbc23          	sd	s6,120(s7)
  p->sz = sz;
    80005446:	078bb823          	sd	s8,112(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000544a:	080bb783          	ld	a5,128(s7)
    8000544e:	e6043703          	ld	a4,-416(s0)
    80005452:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005454:	080bb783          	ld	a5,128(s7)
    80005458:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000545c:	85ea                	mv	a1,s10
    8000545e:	ffffc097          	auipc	ra,0xffffc
    80005462:	680080e7          	jalr	1664(ra) # 80001ade <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005466:	0004851b          	sext.w	a0,s1
    8000546a:	bbc1                	j	8000523a <exec+0x9c>
    8000546c:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005470:	df843583          	ld	a1,-520(s0)
    80005474:	855a                	mv	a0,s6
    80005476:	ffffc097          	auipc	ra,0xffffc
    8000547a:	668080e7          	jalr	1640(ra) # 80001ade <proc_freepagetable>
  if(ip){
    8000547e:	da0a94e3          	bnez	s5,80005226 <exec+0x88>
  return -1;
    80005482:	557d                	li	a0,-1
    80005484:	bb5d                	j	8000523a <exec+0x9c>
    80005486:	de943c23          	sd	s1,-520(s0)
    8000548a:	b7dd                	j	80005470 <exec+0x2d2>
    8000548c:	de943c23          	sd	s1,-520(s0)
    80005490:	b7c5                	j	80005470 <exec+0x2d2>
    80005492:	de943c23          	sd	s1,-520(s0)
    80005496:	bfe9                	j	80005470 <exec+0x2d2>
  sz = sz1;
    80005498:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000549c:	4a81                	li	s5,0
    8000549e:	bfc9                	j	80005470 <exec+0x2d2>
  sz = sz1;
    800054a0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800054a4:	4a81                	li	s5,0
    800054a6:	b7e9                	j	80005470 <exec+0x2d2>
  sz = sz1;
    800054a8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800054ac:	4a81                	li	s5,0
    800054ae:	b7c9                	j	80005470 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800054b0:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800054b4:	e0843783          	ld	a5,-504(s0)
    800054b8:	0017869b          	addiw	a3,a5,1
    800054bc:	e0d43423          	sd	a3,-504(s0)
    800054c0:	e0043783          	ld	a5,-512(s0)
    800054c4:	0387879b          	addiw	a5,a5,56
    800054c8:	e8045703          	lhu	a4,-384(s0)
    800054cc:	e2e6d3e3          	bge	a3,a4,800052f2 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800054d0:	2781                	sext.w	a5,a5
    800054d2:	e0f43023          	sd	a5,-512(s0)
    800054d6:	03800713          	li	a4,56
    800054da:	86be                	mv	a3,a5
    800054dc:	e1040613          	addi	a2,s0,-496
    800054e0:	4581                	li	a1,0
    800054e2:	8556                	mv	a0,s5
    800054e4:	fffff097          	auipc	ra,0xfffff
    800054e8:	a7a080e7          	jalr	-1414(ra) # 80003f5e <readi>
    800054ec:	03800793          	li	a5,56
    800054f0:	f6f51ee3          	bne	a0,a5,8000546c <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    800054f4:	e1042783          	lw	a5,-496(s0)
    800054f8:	4705                	li	a4,1
    800054fa:	fae79de3          	bne	a5,a4,800054b4 <exec+0x316>
    if(ph.memsz < ph.filesz)
    800054fe:	e3843603          	ld	a2,-456(s0)
    80005502:	e3043783          	ld	a5,-464(s0)
    80005506:	f8f660e3          	bltu	a2,a5,80005486 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000550a:	e2043783          	ld	a5,-480(s0)
    8000550e:	963e                	add	a2,a2,a5
    80005510:	f6f66ee3          	bltu	a2,a5,8000548c <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005514:	85a6                	mv	a1,s1
    80005516:	855a                	mv	a0,s6
    80005518:	ffffc097          	auipc	ra,0xffffc
    8000551c:	ed6080e7          	jalr	-298(ra) # 800013ee <uvmalloc>
    80005520:	dea43c23          	sd	a0,-520(s0)
    80005524:	d53d                	beqz	a0,80005492 <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    80005526:	e2043c03          	ld	s8,-480(s0)
    8000552a:	de043783          	ld	a5,-544(s0)
    8000552e:	00fc77b3          	and	a5,s8,a5
    80005532:	ff9d                	bnez	a5,80005470 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005534:	e1842c83          	lw	s9,-488(s0)
    80005538:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000553c:	f60b8ae3          	beqz	s7,800054b0 <exec+0x312>
    80005540:	89de                	mv	s3,s7
    80005542:	4481                	li	s1,0
    80005544:	b371                	j	800052d0 <exec+0x132>

0000000080005546 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005546:	7179                	addi	sp,sp,-48
    80005548:	f406                	sd	ra,40(sp)
    8000554a:	f022                	sd	s0,32(sp)
    8000554c:	ec26                	sd	s1,24(sp)
    8000554e:	e84a                	sd	s2,16(sp)
    80005550:	1800                	addi	s0,sp,48
    80005552:	892e                	mv	s2,a1
    80005554:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005556:	fdc40593          	addi	a1,s0,-36
    8000555a:	ffffe097          	auipc	ra,0xffffe
    8000555e:	a58080e7          	jalr	-1448(ra) # 80002fb2 <argint>
    80005562:	04054063          	bltz	a0,800055a2 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005566:	fdc42703          	lw	a4,-36(s0)
    8000556a:	47bd                	li	a5,15
    8000556c:	02e7ed63          	bltu	a5,a4,800055a6 <argfd+0x60>
    80005570:	ffffc097          	auipc	ra,0xffffc
    80005574:	40e080e7          	jalr	1038(ra) # 8000197e <myproc>
    80005578:	fdc42703          	lw	a4,-36(s0)
    8000557c:	01e70793          	addi	a5,a4,30
    80005580:	078e                	slli	a5,a5,0x3
    80005582:	953e                	add	a0,a0,a5
    80005584:	651c                	ld	a5,8(a0)
    80005586:	c395                	beqz	a5,800055aa <argfd+0x64>
    return -1;
  if(pfd)
    80005588:	00090463          	beqz	s2,80005590 <argfd+0x4a>
    *pfd = fd;
    8000558c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005590:	4501                	li	a0,0
  if(pf)
    80005592:	c091                	beqz	s1,80005596 <argfd+0x50>
    *pf = f;
    80005594:	e09c                	sd	a5,0(s1)
}
    80005596:	70a2                	ld	ra,40(sp)
    80005598:	7402                	ld	s0,32(sp)
    8000559a:	64e2                	ld	s1,24(sp)
    8000559c:	6942                	ld	s2,16(sp)
    8000559e:	6145                	addi	sp,sp,48
    800055a0:	8082                	ret
    return -1;
    800055a2:	557d                	li	a0,-1
    800055a4:	bfcd                	j	80005596 <argfd+0x50>
    return -1;
    800055a6:	557d                	li	a0,-1
    800055a8:	b7fd                	j	80005596 <argfd+0x50>
    800055aa:	557d                	li	a0,-1
    800055ac:	b7ed                	j	80005596 <argfd+0x50>

00000000800055ae <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800055ae:	1101                	addi	sp,sp,-32
    800055b0:	ec06                	sd	ra,24(sp)
    800055b2:	e822                	sd	s0,16(sp)
    800055b4:	e426                	sd	s1,8(sp)
    800055b6:	1000                	addi	s0,sp,32
    800055b8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800055ba:	ffffc097          	auipc	ra,0xffffc
    800055be:	3c4080e7          	jalr	964(ra) # 8000197e <myproc>
    800055c2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800055c4:	0f850793          	addi	a5,a0,248
    800055c8:	4501                	li	a0,0
    800055ca:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800055cc:	6398                	ld	a4,0(a5)
    800055ce:	cb19                	beqz	a4,800055e4 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800055d0:	2505                	addiw	a0,a0,1
    800055d2:	07a1                	addi	a5,a5,8
    800055d4:	fed51ce3          	bne	a0,a3,800055cc <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800055d8:	557d                	li	a0,-1
}
    800055da:	60e2                	ld	ra,24(sp)
    800055dc:	6442                	ld	s0,16(sp)
    800055de:	64a2                	ld	s1,8(sp)
    800055e0:	6105                	addi	sp,sp,32
    800055e2:	8082                	ret
      p->ofile[fd] = f;
    800055e4:	01e50793          	addi	a5,a0,30
    800055e8:	078e                	slli	a5,a5,0x3
    800055ea:	963e                	add	a2,a2,a5
    800055ec:	e604                	sd	s1,8(a2)
      return fd;
    800055ee:	b7f5                	j	800055da <fdalloc+0x2c>

00000000800055f0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800055f0:	715d                	addi	sp,sp,-80
    800055f2:	e486                	sd	ra,72(sp)
    800055f4:	e0a2                	sd	s0,64(sp)
    800055f6:	fc26                	sd	s1,56(sp)
    800055f8:	f84a                	sd	s2,48(sp)
    800055fa:	f44e                	sd	s3,40(sp)
    800055fc:	f052                	sd	s4,32(sp)
    800055fe:	ec56                	sd	s5,24(sp)
    80005600:	0880                	addi	s0,sp,80
    80005602:	89ae                	mv	s3,a1
    80005604:	8ab2                	mv	s5,a2
    80005606:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005608:	fb040593          	addi	a1,s0,-80
    8000560c:	fffff097          	auipc	ra,0xfffff
    80005610:	e72080e7          	jalr	-398(ra) # 8000447e <nameiparent>
    80005614:	892a                	mv	s2,a0
    80005616:	12050e63          	beqz	a0,80005752 <create+0x162>
    return 0;

  ilock(dp);
    8000561a:	ffffe097          	auipc	ra,0xffffe
    8000561e:	690080e7          	jalr	1680(ra) # 80003caa <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005622:	4601                	li	a2,0
    80005624:	fb040593          	addi	a1,s0,-80
    80005628:	854a                	mv	a0,s2
    8000562a:	fffff097          	auipc	ra,0xfffff
    8000562e:	b64080e7          	jalr	-1180(ra) # 8000418e <dirlookup>
    80005632:	84aa                	mv	s1,a0
    80005634:	c921                	beqz	a0,80005684 <create+0x94>
    iunlockput(dp);
    80005636:	854a                	mv	a0,s2
    80005638:	fffff097          	auipc	ra,0xfffff
    8000563c:	8d4080e7          	jalr	-1836(ra) # 80003f0c <iunlockput>
    ilock(ip);
    80005640:	8526                	mv	a0,s1
    80005642:	ffffe097          	auipc	ra,0xffffe
    80005646:	668080e7          	jalr	1640(ra) # 80003caa <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000564a:	2981                	sext.w	s3,s3
    8000564c:	4789                	li	a5,2
    8000564e:	02f99463          	bne	s3,a5,80005676 <create+0x86>
    80005652:	0444d783          	lhu	a5,68(s1)
    80005656:	37f9                	addiw	a5,a5,-2
    80005658:	17c2                	slli	a5,a5,0x30
    8000565a:	93c1                	srli	a5,a5,0x30
    8000565c:	4705                	li	a4,1
    8000565e:	00f76c63          	bltu	a4,a5,80005676 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005662:	8526                	mv	a0,s1
    80005664:	60a6                	ld	ra,72(sp)
    80005666:	6406                	ld	s0,64(sp)
    80005668:	74e2                	ld	s1,56(sp)
    8000566a:	7942                	ld	s2,48(sp)
    8000566c:	79a2                	ld	s3,40(sp)
    8000566e:	7a02                	ld	s4,32(sp)
    80005670:	6ae2                	ld	s5,24(sp)
    80005672:	6161                	addi	sp,sp,80
    80005674:	8082                	ret
    iunlockput(ip);
    80005676:	8526                	mv	a0,s1
    80005678:	fffff097          	auipc	ra,0xfffff
    8000567c:	894080e7          	jalr	-1900(ra) # 80003f0c <iunlockput>
    return 0;
    80005680:	4481                	li	s1,0
    80005682:	b7c5                	j	80005662 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005684:	85ce                	mv	a1,s3
    80005686:	00092503          	lw	a0,0(s2)
    8000568a:	ffffe097          	auipc	ra,0xffffe
    8000568e:	488080e7          	jalr	1160(ra) # 80003b12 <ialloc>
    80005692:	84aa                	mv	s1,a0
    80005694:	c521                	beqz	a0,800056dc <create+0xec>
  ilock(ip);
    80005696:	ffffe097          	auipc	ra,0xffffe
    8000569a:	614080e7          	jalr	1556(ra) # 80003caa <ilock>
  ip->major = major;
    8000569e:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800056a2:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800056a6:	4a05                	li	s4,1
    800056a8:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800056ac:	8526                	mv	a0,s1
    800056ae:	ffffe097          	auipc	ra,0xffffe
    800056b2:	532080e7          	jalr	1330(ra) # 80003be0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800056b6:	2981                	sext.w	s3,s3
    800056b8:	03498a63          	beq	s3,s4,800056ec <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800056bc:	40d0                	lw	a2,4(s1)
    800056be:	fb040593          	addi	a1,s0,-80
    800056c2:	854a                	mv	a0,s2
    800056c4:	fffff097          	auipc	ra,0xfffff
    800056c8:	cda080e7          	jalr	-806(ra) # 8000439e <dirlink>
    800056cc:	06054b63          	bltz	a0,80005742 <create+0x152>
  iunlockput(dp);
    800056d0:	854a                	mv	a0,s2
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	83a080e7          	jalr	-1990(ra) # 80003f0c <iunlockput>
  return ip;
    800056da:	b761                	j	80005662 <create+0x72>
    panic("create: ialloc");
    800056dc:	00003517          	auipc	a0,0x3
    800056e0:	21450513          	addi	a0,a0,532 # 800088f0 <syscalls+0x2b0>
    800056e4:	ffffb097          	auipc	ra,0xffffb
    800056e8:	e46080e7          	jalr	-442(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    800056ec:	04a95783          	lhu	a5,74(s2)
    800056f0:	2785                	addiw	a5,a5,1
    800056f2:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800056f6:	854a                	mv	a0,s2
    800056f8:	ffffe097          	auipc	ra,0xffffe
    800056fc:	4e8080e7          	jalr	1256(ra) # 80003be0 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005700:	40d0                	lw	a2,4(s1)
    80005702:	00003597          	auipc	a1,0x3
    80005706:	1fe58593          	addi	a1,a1,510 # 80008900 <syscalls+0x2c0>
    8000570a:	8526                	mv	a0,s1
    8000570c:	fffff097          	auipc	ra,0xfffff
    80005710:	c92080e7          	jalr	-878(ra) # 8000439e <dirlink>
    80005714:	00054f63          	bltz	a0,80005732 <create+0x142>
    80005718:	00492603          	lw	a2,4(s2)
    8000571c:	00003597          	auipc	a1,0x3
    80005720:	1ec58593          	addi	a1,a1,492 # 80008908 <syscalls+0x2c8>
    80005724:	8526                	mv	a0,s1
    80005726:	fffff097          	auipc	ra,0xfffff
    8000572a:	c78080e7          	jalr	-904(ra) # 8000439e <dirlink>
    8000572e:	f80557e3          	bgez	a0,800056bc <create+0xcc>
      panic("create dots");
    80005732:	00003517          	auipc	a0,0x3
    80005736:	1de50513          	addi	a0,a0,478 # 80008910 <syscalls+0x2d0>
    8000573a:	ffffb097          	auipc	ra,0xffffb
    8000573e:	df0080e7          	jalr	-528(ra) # 8000052a <panic>
    panic("create: dirlink");
    80005742:	00003517          	auipc	a0,0x3
    80005746:	1de50513          	addi	a0,a0,478 # 80008920 <syscalls+0x2e0>
    8000574a:	ffffb097          	auipc	ra,0xffffb
    8000574e:	de0080e7          	jalr	-544(ra) # 8000052a <panic>
    return 0;
    80005752:	84aa                	mv	s1,a0
    80005754:	b739                	j	80005662 <create+0x72>

0000000080005756 <sys_dup>:
{
    80005756:	7179                	addi	sp,sp,-48
    80005758:	f406                	sd	ra,40(sp)
    8000575a:	f022                	sd	s0,32(sp)
    8000575c:	ec26                	sd	s1,24(sp)
    8000575e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005760:	fd840613          	addi	a2,s0,-40
    80005764:	4581                	li	a1,0
    80005766:	4501                	li	a0,0
    80005768:	00000097          	auipc	ra,0x0
    8000576c:	dde080e7          	jalr	-546(ra) # 80005546 <argfd>
    return -1;
    80005770:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005772:	02054363          	bltz	a0,80005798 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005776:	fd843503          	ld	a0,-40(s0)
    8000577a:	00000097          	auipc	ra,0x0
    8000577e:	e34080e7          	jalr	-460(ra) # 800055ae <fdalloc>
    80005782:	84aa                	mv	s1,a0
    return -1;
    80005784:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005786:	00054963          	bltz	a0,80005798 <sys_dup+0x42>
  filedup(f);
    8000578a:	fd843503          	ld	a0,-40(s0)
    8000578e:	fffff097          	auipc	ra,0xfffff
    80005792:	36c080e7          	jalr	876(ra) # 80004afa <filedup>
  return fd;
    80005796:	87a6                	mv	a5,s1
}
    80005798:	853e                	mv	a0,a5
    8000579a:	70a2                	ld	ra,40(sp)
    8000579c:	7402                	ld	s0,32(sp)
    8000579e:	64e2                	ld	s1,24(sp)
    800057a0:	6145                	addi	sp,sp,48
    800057a2:	8082                	ret

00000000800057a4 <sys_read>:
{
    800057a4:	7179                	addi	sp,sp,-48
    800057a6:	f406                	sd	ra,40(sp)
    800057a8:	f022                	sd	s0,32(sp)
    800057aa:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057ac:	fe840613          	addi	a2,s0,-24
    800057b0:	4581                	li	a1,0
    800057b2:	4501                	li	a0,0
    800057b4:	00000097          	auipc	ra,0x0
    800057b8:	d92080e7          	jalr	-622(ra) # 80005546 <argfd>
    return -1;
    800057bc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057be:	04054163          	bltz	a0,80005800 <sys_read+0x5c>
    800057c2:	fe440593          	addi	a1,s0,-28
    800057c6:	4509                	li	a0,2
    800057c8:	ffffd097          	auipc	ra,0xffffd
    800057cc:	7ea080e7          	jalr	2026(ra) # 80002fb2 <argint>
    return -1;
    800057d0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057d2:	02054763          	bltz	a0,80005800 <sys_read+0x5c>
    800057d6:	fd840593          	addi	a1,s0,-40
    800057da:	4505                	li	a0,1
    800057dc:	ffffd097          	auipc	ra,0xffffd
    800057e0:	7f8080e7          	jalr	2040(ra) # 80002fd4 <argaddr>
    return -1;
    800057e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057e6:	00054d63          	bltz	a0,80005800 <sys_read+0x5c>
  return fileread(f, p, n);
    800057ea:	fe442603          	lw	a2,-28(s0)
    800057ee:	fd843583          	ld	a1,-40(s0)
    800057f2:	fe843503          	ld	a0,-24(s0)
    800057f6:	fffff097          	auipc	ra,0xfffff
    800057fa:	490080e7          	jalr	1168(ra) # 80004c86 <fileread>
    800057fe:	87aa                	mv	a5,a0
}
    80005800:	853e                	mv	a0,a5
    80005802:	70a2                	ld	ra,40(sp)
    80005804:	7402                	ld	s0,32(sp)
    80005806:	6145                	addi	sp,sp,48
    80005808:	8082                	ret

000000008000580a <sys_write>:
{
    8000580a:	7179                	addi	sp,sp,-48
    8000580c:	f406                	sd	ra,40(sp)
    8000580e:	f022                	sd	s0,32(sp)
    80005810:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005812:	fe840613          	addi	a2,s0,-24
    80005816:	4581                	li	a1,0
    80005818:	4501                	li	a0,0
    8000581a:	00000097          	auipc	ra,0x0
    8000581e:	d2c080e7          	jalr	-724(ra) # 80005546 <argfd>
    return -1;
    80005822:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005824:	04054163          	bltz	a0,80005866 <sys_write+0x5c>
    80005828:	fe440593          	addi	a1,s0,-28
    8000582c:	4509                	li	a0,2
    8000582e:	ffffd097          	auipc	ra,0xffffd
    80005832:	784080e7          	jalr	1924(ra) # 80002fb2 <argint>
    return -1;
    80005836:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005838:	02054763          	bltz	a0,80005866 <sys_write+0x5c>
    8000583c:	fd840593          	addi	a1,s0,-40
    80005840:	4505                	li	a0,1
    80005842:	ffffd097          	auipc	ra,0xffffd
    80005846:	792080e7          	jalr	1938(ra) # 80002fd4 <argaddr>
    return -1;
    8000584a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000584c:	00054d63          	bltz	a0,80005866 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005850:	fe442603          	lw	a2,-28(s0)
    80005854:	fd843583          	ld	a1,-40(s0)
    80005858:	fe843503          	ld	a0,-24(s0)
    8000585c:	fffff097          	auipc	ra,0xfffff
    80005860:	4ec080e7          	jalr	1260(ra) # 80004d48 <filewrite>
    80005864:	87aa                	mv	a5,a0
}
    80005866:	853e                	mv	a0,a5
    80005868:	70a2                	ld	ra,40(sp)
    8000586a:	7402                	ld	s0,32(sp)
    8000586c:	6145                	addi	sp,sp,48
    8000586e:	8082                	ret

0000000080005870 <sys_close>:
{
    80005870:	1101                	addi	sp,sp,-32
    80005872:	ec06                	sd	ra,24(sp)
    80005874:	e822                	sd	s0,16(sp)
    80005876:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005878:	fe040613          	addi	a2,s0,-32
    8000587c:	fec40593          	addi	a1,s0,-20
    80005880:	4501                	li	a0,0
    80005882:	00000097          	auipc	ra,0x0
    80005886:	cc4080e7          	jalr	-828(ra) # 80005546 <argfd>
    return -1;
    8000588a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000588c:	02054463          	bltz	a0,800058b4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005890:	ffffc097          	auipc	ra,0xffffc
    80005894:	0ee080e7          	jalr	238(ra) # 8000197e <myproc>
    80005898:	fec42783          	lw	a5,-20(s0)
    8000589c:	07f9                	addi	a5,a5,30
    8000589e:	078e                	slli	a5,a5,0x3
    800058a0:	97aa                	add	a5,a5,a0
    800058a2:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800058a6:	fe043503          	ld	a0,-32(s0)
    800058aa:	fffff097          	auipc	ra,0xfffff
    800058ae:	2a2080e7          	jalr	674(ra) # 80004b4c <fileclose>
  return 0;
    800058b2:	4781                	li	a5,0
}
    800058b4:	853e                	mv	a0,a5
    800058b6:	60e2                	ld	ra,24(sp)
    800058b8:	6442                	ld	s0,16(sp)
    800058ba:	6105                	addi	sp,sp,32
    800058bc:	8082                	ret

00000000800058be <sys_fstat>:
{
    800058be:	1101                	addi	sp,sp,-32
    800058c0:	ec06                	sd	ra,24(sp)
    800058c2:	e822                	sd	s0,16(sp)
    800058c4:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800058c6:	fe840613          	addi	a2,s0,-24
    800058ca:	4581                	li	a1,0
    800058cc:	4501                	li	a0,0
    800058ce:	00000097          	auipc	ra,0x0
    800058d2:	c78080e7          	jalr	-904(ra) # 80005546 <argfd>
    return -1;
    800058d6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800058d8:	02054563          	bltz	a0,80005902 <sys_fstat+0x44>
    800058dc:	fe040593          	addi	a1,s0,-32
    800058e0:	4505                	li	a0,1
    800058e2:	ffffd097          	auipc	ra,0xffffd
    800058e6:	6f2080e7          	jalr	1778(ra) # 80002fd4 <argaddr>
    return -1;
    800058ea:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800058ec:	00054b63          	bltz	a0,80005902 <sys_fstat+0x44>
  return filestat(f, st);
    800058f0:	fe043583          	ld	a1,-32(s0)
    800058f4:	fe843503          	ld	a0,-24(s0)
    800058f8:	fffff097          	auipc	ra,0xfffff
    800058fc:	31c080e7          	jalr	796(ra) # 80004c14 <filestat>
    80005900:	87aa                	mv	a5,a0
}
    80005902:	853e                	mv	a0,a5
    80005904:	60e2                	ld	ra,24(sp)
    80005906:	6442                	ld	s0,16(sp)
    80005908:	6105                	addi	sp,sp,32
    8000590a:	8082                	ret

000000008000590c <sys_link>:
{
    8000590c:	7169                	addi	sp,sp,-304
    8000590e:	f606                	sd	ra,296(sp)
    80005910:	f222                	sd	s0,288(sp)
    80005912:	ee26                	sd	s1,280(sp)
    80005914:	ea4a                	sd	s2,272(sp)
    80005916:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005918:	08000613          	li	a2,128
    8000591c:	ed040593          	addi	a1,s0,-304
    80005920:	4501                	li	a0,0
    80005922:	ffffd097          	auipc	ra,0xffffd
    80005926:	6d4080e7          	jalr	1748(ra) # 80002ff6 <argstr>
    return -1;
    8000592a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000592c:	10054e63          	bltz	a0,80005a48 <sys_link+0x13c>
    80005930:	08000613          	li	a2,128
    80005934:	f5040593          	addi	a1,s0,-176
    80005938:	4505                	li	a0,1
    8000593a:	ffffd097          	auipc	ra,0xffffd
    8000593e:	6bc080e7          	jalr	1724(ra) # 80002ff6 <argstr>
    return -1;
    80005942:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005944:	10054263          	bltz	a0,80005a48 <sys_link+0x13c>
  begin_op();
    80005948:	fffff097          	auipc	ra,0xfffff
    8000594c:	d38080e7          	jalr	-712(ra) # 80004680 <begin_op>
  if((ip = namei(old)) == 0){
    80005950:	ed040513          	addi	a0,s0,-304
    80005954:	fffff097          	auipc	ra,0xfffff
    80005958:	b0c080e7          	jalr	-1268(ra) # 80004460 <namei>
    8000595c:	84aa                	mv	s1,a0
    8000595e:	c551                	beqz	a0,800059ea <sys_link+0xde>
  ilock(ip);
    80005960:	ffffe097          	auipc	ra,0xffffe
    80005964:	34a080e7          	jalr	842(ra) # 80003caa <ilock>
  if(ip->type == T_DIR){
    80005968:	04449703          	lh	a4,68(s1)
    8000596c:	4785                	li	a5,1
    8000596e:	08f70463          	beq	a4,a5,800059f6 <sys_link+0xea>
  ip->nlink++;
    80005972:	04a4d783          	lhu	a5,74(s1)
    80005976:	2785                	addiw	a5,a5,1
    80005978:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000597c:	8526                	mv	a0,s1
    8000597e:	ffffe097          	auipc	ra,0xffffe
    80005982:	262080e7          	jalr	610(ra) # 80003be0 <iupdate>
  iunlock(ip);
    80005986:	8526                	mv	a0,s1
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	3e4080e7          	jalr	996(ra) # 80003d6c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005990:	fd040593          	addi	a1,s0,-48
    80005994:	f5040513          	addi	a0,s0,-176
    80005998:	fffff097          	auipc	ra,0xfffff
    8000599c:	ae6080e7          	jalr	-1306(ra) # 8000447e <nameiparent>
    800059a0:	892a                	mv	s2,a0
    800059a2:	c935                	beqz	a0,80005a16 <sys_link+0x10a>
  ilock(dp);
    800059a4:	ffffe097          	auipc	ra,0xffffe
    800059a8:	306080e7          	jalr	774(ra) # 80003caa <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800059ac:	00092703          	lw	a4,0(s2)
    800059b0:	409c                	lw	a5,0(s1)
    800059b2:	04f71d63          	bne	a4,a5,80005a0c <sys_link+0x100>
    800059b6:	40d0                	lw	a2,4(s1)
    800059b8:	fd040593          	addi	a1,s0,-48
    800059bc:	854a                	mv	a0,s2
    800059be:	fffff097          	auipc	ra,0xfffff
    800059c2:	9e0080e7          	jalr	-1568(ra) # 8000439e <dirlink>
    800059c6:	04054363          	bltz	a0,80005a0c <sys_link+0x100>
  iunlockput(dp);
    800059ca:	854a                	mv	a0,s2
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	540080e7          	jalr	1344(ra) # 80003f0c <iunlockput>
  iput(ip);
    800059d4:	8526                	mv	a0,s1
    800059d6:	ffffe097          	auipc	ra,0xffffe
    800059da:	48e080e7          	jalr	1166(ra) # 80003e64 <iput>
  end_op();
    800059de:	fffff097          	auipc	ra,0xfffff
    800059e2:	d22080e7          	jalr	-734(ra) # 80004700 <end_op>
  return 0;
    800059e6:	4781                	li	a5,0
    800059e8:	a085                	j	80005a48 <sys_link+0x13c>
    end_op();
    800059ea:	fffff097          	auipc	ra,0xfffff
    800059ee:	d16080e7          	jalr	-746(ra) # 80004700 <end_op>
    return -1;
    800059f2:	57fd                	li	a5,-1
    800059f4:	a891                	j	80005a48 <sys_link+0x13c>
    iunlockput(ip);
    800059f6:	8526                	mv	a0,s1
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	514080e7          	jalr	1300(ra) # 80003f0c <iunlockput>
    end_op();
    80005a00:	fffff097          	auipc	ra,0xfffff
    80005a04:	d00080e7          	jalr	-768(ra) # 80004700 <end_op>
    return -1;
    80005a08:	57fd                	li	a5,-1
    80005a0a:	a83d                	j	80005a48 <sys_link+0x13c>
    iunlockput(dp);
    80005a0c:	854a                	mv	a0,s2
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	4fe080e7          	jalr	1278(ra) # 80003f0c <iunlockput>
  ilock(ip);
    80005a16:	8526                	mv	a0,s1
    80005a18:	ffffe097          	auipc	ra,0xffffe
    80005a1c:	292080e7          	jalr	658(ra) # 80003caa <ilock>
  ip->nlink--;
    80005a20:	04a4d783          	lhu	a5,74(s1)
    80005a24:	37fd                	addiw	a5,a5,-1
    80005a26:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a2a:	8526                	mv	a0,s1
    80005a2c:	ffffe097          	auipc	ra,0xffffe
    80005a30:	1b4080e7          	jalr	436(ra) # 80003be0 <iupdate>
  iunlockput(ip);
    80005a34:	8526                	mv	a0,s1
    80005a36:	ffffe097          	auipc	ra,0xffffe
    80005a3a:	4d6080e7          	jalr	1238(ra) # 80003f0c <iunlockput>
  end_op();
    80005a3e:	fffff097          	auipc	ra,0xfffff
    80005a42:	cc2080e7          	jalr	-830(ra) # 80004700 <end_op>
  return -1;
    80005a46:	57fd                	li	a5,-1
}
    80005a48:	853e                	mv	a0,a5
    80005a4a:	70b2                	ld	ra,296(sp)
    80005a4c:	7412                	ld	s0,288(sp)
    80005a4e:	64f2                	ld	s1,280(sp)
    80005a50:	6952                	ld	s2,272(sp)
    80005a52:	6155                	addi	sp,sp,304
    80005a54:	8082                	ret

0000000080005a56 <sys_unlink>:
{
    80005a56:	7151                	addi	sp,sp,-240
    80005a58:	f586                	sd	ra,232(sp)
    80005a5a:	f1a2                	sd	s0,224(sp)
    80005a5c:	eda6                	sd	s1,216(sp)
    80005a5e:	e9ca                	sd	s2,208(sp)
    80005a60:	e5ce                	sd	s3,200(sp)
    80005a62:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a64:	08000613          	li	a2,128
    80005a68:	f3040593          	addi	a1,s0,-208
    80005a6c:	4501                	li	a0,0
    80005a6e:	ffffd097          	auipc	ra,0xffffd
    80005a72:	588080e7          	jalr	1416(ra) # 80002ff6 <argstr>
    80005a76:	18054163          	bltz	a0,80005bf8 <sys_unlink+0x1a2>
  begin_op();
    80005a7a:	fffff097          	auipc	ra,0xfffff
    80005a7e:	c06080e7          	jalr	-1018(ra) # 80004680 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a82:	fb040593          	addi	a1,s0,-80
    80005a86:	f3040513          	addi	a0,s0,-208
    80005a8a:	fffff097          	auipc	ra,0xfffff
    80005a8e:	9f4080e7          	jalr	-1548(ra) # 8000447e <nameiparent>
    80005a92:	84aa                	mv	s1,a0
    80005a94:	c979                	beqz	a0,80005b6a <sys_unlink+0x114>
  ilock(dp);
    80005a96:	ffffe097          	auipc	ra,0xffffe
    80005a9a:	214080e7          	jalr	532(ra) # 80003caa <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a9e:	00003597          	auipc	a1,0x3
    80005aa2:	e6258593          	addi	a1,a1,-414 # 80008900 <syscalls+0x2c0>
    80005aa6:	fb040513          	addi	a0,s0,-80
    80005aaa:	ffffe097          	auipc	ra,0xffffe
    80005aae:	6ca080e7          	jalr	1738(ra) # 80004174 <namecmp>
    80005ab2:	14050a63          	beqz	a0,80005c06 <sys_unlink+0x1b0>
    80005ab6:	00003597          	auipc	a1,0x3
    80005aba:	e5258593          	addi	a1,a1,-430 # 80008908 <syscalls+0x2c8>
    80005abe:	fb040513          	addi	a0,s0,-80
    80005ac2:	ffffe097          	auipc	ra,0xffffe
    80005ac6:	6b2080e7          	jalr	1714(ra) # 80004174 <namecmp>
    80005aca:	12050e63          	beqz	a0,80005c06 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005ace:	f2c40613          	addi	a2,s0,-212
    80005ad2:	fb040593          	addi	a1,s0,-80
    80005ad6:	8526                	mv	a0,s1
    80005ad8:	ffffe097          	auipc	ra,0xffffe
    80005adc:	6b6080e7          	jalr	1718(ra) # 8000418e <dirlookup>
    80005ae0:	892a                	mv	s2,a0
    80005ae2:	12050263          	beqz	a0,80005c06 <sys_unlink+0x1b0>
  ilock(ip);
    80005ae6:	ffffe097          	auipc	ra,0xffffe
    80005aea:	1c4080e7          	jalr	452(ra) # 80003caa <ilock>
  if(ip->nlink < 1)
    80005aee:	04a91783          	lh	a5,74(s2)
    80005af2:	08f05263          	blez	a5,80005b76 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005af6:	04491703          	lh	a4,68(s2)
    80005afa:	4785                	li	a5,1
    80005afc:	08f70563          	beq	a4,a5,80005b86 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005b00:	4641                	li	a2,16
    80005b02:	4581                	li	a1,0
    80005b04:	fc040513          	addi	a0,s0,-64
    80005b08:	ffffb097          	auipc	ra,0xffffb
    80005b0c:	1b6080e7          	jalr	438(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b10:	4741                	li	a4,16
    80005b12:	f2c42683          	lw	a3,-212(s0)
    80005b16:	fc040613          	addi	a2,s0,-64
    80005b1a:	4581                	li	a1,0
    80005b1c:	8526                	mv	a0,s1
    80005b1e:	ffffe097          	auipc	ra,0xffffe
    80005b22:	538080e7          	jalr	1336(ra) # 80004056 <writei>
    80005b26:	47c1                	li	a5,16
    80005b28:	0af51563          	bne	a0,a5,80005bd2 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005b2c:	04491703          	lh	a4,68(s2)
    80005b30:	4785                	li	a5,1
    80005b32:	0af70863          	beq	a4,a5,80005be2 <sys_unlink+0x18c>
  iunlockput(dp);
    80005b36:	8526                	mv	a0,s1
    80005b38:	ffffe097          	auipc	ra,0xffffe
    80005b3c:	3d4080e7          	jalr	980(ra) # 80003f0c <iunlockput>
  ip->nlink--;
    80005b40:	04a95783          	lhu	a5,74(s2)
    80005b44:	37fd                	addiw	a5,a5,-1
    80005b46:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005b4a:	854a                	mv	a0,s2
    80005b4c:	ffffe097          	auipc	ra,0xffffe
    80005b50:	094080e7          	jalr	148(ra) # 80003be0 <iupdate>
  iunlockput(ip);
    80005b54:	854a                	mv	a0,s2
    80005b56:	ffffe097          	auipc	ra,0xffffe
    80005b5a:	3b6080e7          	jalr	950(ra) # 80003f0c <iunlockput>
  end_op();
    80005b5e:	fffff097          	auipc	ra,0xfffff
    80005b62:	ba2080e7          	jalr	-1118(ra) # 80004700 <end_op>
  return 0;
    80005b66:	4501                	li	a0,0
    80005b68:	a84d                	j	80005c1a <sys_unlink+0x1c4>
    end_op();
    80005b6a:	fffff097          	auipc	ra,0xfffff
    80005b6e:	b96080e7          	jalr	-1130(ra) # 80004700 <end_op>
    return -1;
    80005b72:	557d                	li	a0,-1
    80005b74:	a05d                	j	80005c1a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005b76:	00003517          	auipc	a0,0x3
    80005b7a:	dba50513          	addi	a0,a0,-582 # 80008930 <syscalls+0x2f0>
    80005b7e:	ffffb097          	auipc	ra,0xffffb
    80005b82:	9ac080e7          	jalr	-1620(ra) # 8000052a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b86:	04c92703          	lw	a4,76(s2)
    80005b8a:	02000793          	li	a5,32
    80005b8e:	f6e7f9e3          	bgeu	a5,a4,80005b00 <sys_unlink+0xaa>
    80005b92:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b96:	4741                	li	a4,16
    80005b98:	86ce                	mv	a3,s3
    80005b9a:	f1840613          	addi	a2,s0,-232
    80005b9e:	4581                	li	a1,0
    80005ba0:	854a                	mv	a0,s2
    80005ba2:	ffffe097          	auipc	ra,0xffffe
    80005ba6:	3bc080e7          	jalr	956(ra) # 80003f5e <readi>
    80005baa:	47c1                	li	a5,16
    80005bac:	00f51b63          	bne	a0,a5,80005bc2 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005bb0:	f1845783          	lhu	a5,-232(s0)
    80005bb4:	e7a1                	bnez	a5,80005bfc <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bb6:	29c1                	addiw	s3,s3,16
    80005bb8:	04c92783          	lw	a5,76(s2)
    80005bbc:	fcf9ede3          	bltu	s3,a5,80005b96 <sys_unlink+0x140>
    80005bc0:	b781                	j	80005b00 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005bc2:	00003517          	auipc	a0,0x3
    80005bc6:	d8650513          	addi	a0,a0,-634 # 80008948 <syscalls+0x308>
    80005bca:	ffffb097          	auipc	ra,0xffffb
    80005bce:	960080e7          	jalr	-1696(ra) # 8000052a <panic>
    panic("unlink: writei");
    80005bd2:	00003517          	auipc	a0,0x3
    80005bd6:	d8e50513          	addi	a0,a0,-626 # 80008960 <syscalls+0x320>
    80005bda:	ffffb097          	auipc	ra,0xffffb
    80005bde:	950080e7          	jalr	-1712(ra) # 8000052a <panic>
    dp->nlink--;
    80005be2:	04a4d783          	lhu	a5,74(s1)
    80005be6:	37fd                	addiw	a5,a5,-1
    80005be8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005bec:	8526                	mv	a0,s1
    80005bee:	ffffe097          	auipc	ra,0xffffe
    80005bf2:	ff2080e7          	jalr	-14(ra) # 80003be0 <iupdate>
    80005bf6:	b781                	j	80005b36 <sys_unlink+0xe0>
    return -1;
    80005bf8:	557d                	li	a0,-1
    80005bfa:	a005                	j	80005c1a <sys_unlink+0x1c4>
    iunlockput(ip);
    80005bfc:	854a                	mv	a0,s2
    80005bfe:	ffffe097          	auipc	ra,0xffffe
    80005c02:	30e080e7          	jalr	782(ra) # 80003f0c <iunlockput>
  iunlockput(dp);
    80005c06:	8526                	mv	a0,s1
    80005c08:	ffffe097          	auipc	ra,0xffffe
    80005c0c:	304080e7          	jalr	772(ra) # 80003f0c <iunlockput>
  end_op();
    80005c10:	fffff097          	auipc	ra,0xfffff
    80005c14:	af0080e7          	jalr	-1296(ra) # 80004700 <end_op>
  return -1;
    80005c18:	557d                	li	a0,-1
}
    80005c1a:	70ae                	ld	ra,232(sp)
    80005c1c:	740e                	ld	s0,224(sp)
    80005c1e:	64ee                	ld	s1,216(sp)
    80005c20:	694e                	ld	s2,208(sp)
    80005c22:	69ae                	ld	s3,200(sp)
    80005c24:	616d                	addi	sp,sp,240
    80005c26:	8082                	ret

0000000080005c28 <sys_open>:

uint64
sys_open(void)
{
    80005c28:	7131                	addi	sp,sp,-192
    80005c2a:	fd06                	sd	ra,184(sp)
    80005c2c:	f922                	sd	s0,176(sp)
    80005c2e:	f526                	sd	s1,168(sp)
    80005c30:	f14a                	sd	s2,160(sp)
    80005c32:	ed4e                	sd	s3,152(sp)
    80005c34:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005c36:	08000613          	li	a2,128
    80005c3a:	f5040593          	addi	a1,s0,-176
    80005c3e:	4501                	li	a0,0
    80005c40:	ffffd097          	auipc	ra,0xffffd
    80005c44:	3b6080e7          	jalr	950(ra) # 80002ff6 <argstr>
    return -1;
    80005c48:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005c4a:	0c054163          	bltz	a0,80005d0c <sys_open+0xe4>
    80005c4e:	f4c40593          	addi	a1,s0,-180
    80005c52:	4505                	li	a0,1
    80005c54:	ffffd097          	auipc	ra,0xffffd
    80005c58:	35e080e7          	jalr	862(ra) # 80002fb2 <argint>
    80005c5c:	0a054863          	bltz	a0,80005d0c <sys_open+0xe4>

  begin_op();
    80005c60:	fffff097          	auipc	ra,0xfffff
    80005c64:	a20080e7          	jalr	-1504(ra) # 80004680 <begin_op>

  if(omode & O_CREATE){
    80005c68:	f4c42783          	lw	a5,-180(s0)
    80005c6c:	2007f793          	andi	a5,a5,512
    80005c70:	cbdd                	beqz	a5,80005d26 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005c72:	4681                	li	a3,0
    80005c74:	4601                	li	a2,0
    80005c76:	4589                	li	a1,2
    80005c78:	f5040513          	addi	a0,s0,-176
    80005c7c:	00000097          	auipc	ra,0x0
    80005c80:	974080e7          	jalr	-1676(ra) # 800055f0 <create>
    80005c84:	892a                	mv	s2,a0
    if(ip == 0){
    80005c86:	c959                	beqz	a0,80005d1c <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c88:	04491703          	lh	a4,68(s2)
    80005c8c:	478d                	li	a5,3
    80005c8e:	00f71763          	bne	a4,a5,80005c9c <sys_open+0x74>
    80005c92:	04695703          	lhu	a4,70(s2)
    80005c96:	47a5                	li	a5,9
    80005c98:	0ce7ec63          	bltu	a5,a4,80005d70 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	df4080e7          	jalr	-524(ra) # 80004a90 <filealloc>
    80005ca4:	89aa                	mv	s3,a0
    80005ca6:	10050263          	beqz	a0,80005daa <sys_open+0x182>
    80005caa:	00000097          	auipc	ra,0x0
    80005cae:	904080e7          	jalr	-1788(ra) # 800055ae <fdalloc>
    80005cb2:	84aa                	mv	s1,a0
    80005cb4:	0e054663          	bltz	a0,80005da0 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005cb8:	04491703          	lh	a4,68(s2)
    80005cbc:	478d                	li	a5,3
    80005cbe:	0cf70463          	beq	a4,a5,80005d86 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005cc2:	4789                	li	a5,2
    80005cc4:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005cc8:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005ccc:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005cd0:	f4c42783          	lw	a5,-180(s0)
    80005cd4:	0017c713          	xori	a4,a5,1
    80005cd8:	8b05                	andi	a4,a4,1
    80005cda:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005cde:	0037f713          	andi	a4,a5,3
    80005ce2:	00e03733          	snez	a4,a4
    80005ce6:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005cea:	4007f793          	andi	a5,a5,1024
    80005cee:	c791                	beqz	a5,80005cfa <sys_open+0xd2>
    80005cf0:	04491703          	lh	a4,68(s2)
    80005cf4:	4789                	li	a5,2
    80005cf6:	08f70f63          	beq	a4,a5,80005d94 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005cfa:	854a                	mv	a0,s2
    80005cfc:	ffffe097          	auipc	ra,0xffffe
    80005d00:	070080e7          	jalr	112(ra) # 80003d6c <iunlock>
  end_op();
    80005d04:	fffff097          	auipc	ra,0xfffff
    80005d08:	9fc080e7          	jalr	-1540(ra) # 80004700 <end_op>

  return fd;
}
    80005d0c:	8526                	mv	a0,s1
    80005d0e:	70ea                	ld	ra,184(sp)
    80005d10:	744a                	ld	s0,176(sp)
    80005d12:	74aa                	ld	s1,168(sp)
    80005d14:	790a                	ld	s2,160(sp)
    80005d16:	69ea                	ld	s3,152(sp)
    80005d18:	6129                	addi	sp,sp,192
    80005d1a:	8082                	ret
      end_op();
    80005d1c:	fffff097          	auipc	ra,0xfffff
    80005d20:	9e4080e7          	jalr	-1564(ra) # 80004700 <end_op>
      return -1;
    80005d24:	b7e5                	j	80005d0c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005d26:	f5040513          	addi	a0,s0,-176
    80005d2a:	ffffe097          	auipc	ra,0xffffe
    80005d2e:	736080e7          	jalr	1846(ra) # 80004460 <namei>
    80005d32:	892a                	mv	s2,a0
    80005d34:	c905                	beqz	a0,80005d64 <sys_open+0x13c>
    ilock(ip);
    80005d36:	ffffe097          	auipc	ra,0xffffe
    80005d3a:	f74080e7          	jalr	-140(ra) # 80003caa <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005d3e:	04491703          	lh	a4,68(s2)
    80005d42:	4785                	li	a5,1
    80005d44:	f4f712e3          	bne	a4,a5,80005c88 <sys_open+0x60>
    80005d48:	f4c42783          	lw	a5,-180(s0)
    80005d4c:	dba1                	beqz	a5,80005c9c <sys_open+0x74>
      iunlockput(ip);
    80005d4e:	854a                	mv	a0,s2
    80005d50:	ffffe097          	auipc	ra,0xffffe
    80005d54:	1bc080e7          	jalr	444(ra) # 80003f0c <iunlockput>
      end_op();
    80005d58:	fffff097          	auipc	ra,0xfffff
    80005d5c:	9a8080e7          	jalr	-1624(ra) # 80004700 <end_op>
      return -1;
    80005d60:	54fd                	li	s1,-1
    80005d62:	b76d                	j	80005d0c <sys_open+0xe4>
      end_op();
    80005d64:	fffff097          	auipc	ra,0xfffff
    80005d68:	99c080e7          	jalr	-1636(ra) # 80004700 <end_op>
      return -1;
    80005d6c:	54fd                	li	s1,-1
    80005d6e:	bf79                	j	80005d0c <sys_open+0xe4>
    iunlockput(ip);
    80005d70:	854a                	mv	a0,s2
    80005d72:	ffffe097          	auipc	ra,0xffffe
    80005d76:	19a080e7          	jalr	410(ra) # 80003f0c <iunlockput>
    end_op();
    80005d7a:	fffff097          	auipc	ra,0xfffff
    80005d7e:	986080e7          	jalr	-1658(ra) # 80004700 <end_op>
    return -1;
    80005d82:	54fd                	li	s1,-1
    80005d84:	b761                	j	80005d0c <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005d86:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d8a:	04691783          	lh	a5,70(s2)
    80005d8e:	02f99223          	sh	a5,36(s3)
    80005d92:	bf2d                	j	80005ccc <sys_open+0xa4>
    itrunc(ip);
    80005d94:	854a                	mv	a0,s2
    80005d96:	ffffe097          	auipc	ra,0xffffe
    80005d9a:	022080e7          	jalr	34(ra) # 80003db8 <itrunc>
    80005d9e:	bfb1                	j	80005cfa <sys_open+0xd2>
      fileclose(f);
    80005da0:	854e                	mv	a0,s3
    80005da2:	fffff097          	auipc	ra,0xfffff
    80005da6:	daa080e7          	jalr	-598(ra) # 80004b4c <fileclose>
    iunlockput(ip);
    80005daa:	854a                	mv	a0,s2
    80005dac:	ffffe097          	auipc	ra,0xffffe
    80005db0:	160080e7          	jalr	352(ra) # 80003f0c <iunlockput>
    end_op();
    80005db4:	fffff097          	auipc	ra,0xfffff
    80005db8:	94c080e7          	jalr	-1716(ra) # 80004700 <end_op>
    return -1;
    80005dbc:	54fd                	li	s1,-1
    80005dbe:	b7b9                	j	80005d0c <sys_open+0xe4>

0000000080005dc0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005dc0:	7175                	addi	sp,sp,-144
    80005dc2:	e506                	sd	ra,136(sp)
    80005dc4:	e122                	sd	s0,128(sp)
    80005dc6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005dc8:	fffff097          	auipc	ra,0xfffff
    80005dcc:	8b8080e7          	jalr	-1864(ra) # 80004680 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005dd0:	08000613          	li	a2,128
    80005dd4:	f7040593          	addi	a1,s0,-144
    80005dd8:	4501                	li	a0,0
    80005dda:	ffffd097          	auipc	ra,0xffffd
    80005dde:	21c080e7          	jalr	540(ra) # 80002ff6 <argstr>
    80005de2:	02054963          	bltz	a0,80005e14 <sys_mkdir+0x54>
    80005de6:	4681                	li	a3,0
    80005de8:	4601                	li	a2,0
    80005dea:	4585                	li	a1,1
    80005dec:	f7040513          	addi	a0,s0,-144
    80005df0:	00000097          	auipc	ra,0x0
    80005df4:	800080e7          	jalr	-2048(ra) # 800055f0 <create>
    80005df8:	cd11                	beqz	a0,80005e14 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005dfa:	ffffe097          	auipc	ra,0xffffe
    80005dfe:	112080e7          	jalr	274(ra) # 80003f0c <iunlockput>
  end_op();
    80005e02:	fffff097          	auipc	ra,0xfffff
    80005e06:	8fe080e7          	jalr	-1794(ra) # 80004700 <end_op>
  return 0;
    80005e0a:	4501                	li	a0,0
}
    80005e0c:	60aa                	ld	ra,136(sp)
    80005e0e:	640a                	ld	s0,128(sp)
    80005e10:	6149                	addi	sp,sp,144
    80005e12:	8082                	ret
    end_op();
    80005e14:	fffff097          	auipc	ra,0xfffff
    80005e18:	8ec080e7          	jalr	-1812(ra) # 80004700 <end_op>
    return -1;
    80005e1c:	557d                	li	a0,-1
    80005e1e:	b7fd                	j	80005e0c <sys_mkdir+0x4c>

0000000080005e20 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005e20:	7135                	addi	sp,sp,-160
    80005e22:	ed06                	sd	ra,152(sp)
    80005e24:	e922                	sd	s0,144(sp)
    80005e26:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005e28:	fffff097          	auipc	ra,0xfffff
    80005e2c:	858080e7          	jalr	-1960(ra) # 80004680 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e30:	08000613          	li	a2,128
    80005e34:	f7040593          	addi	a1,s0,-144
    80005e38:	4501                	li	a0,0
    80005e3a:	ffffd097          	auipc	ra,0xffffd
    80005e3e:	1bc080e7          	jalr	444(ra) # 80002ff6 <argstr>
    80005e42:	04054a63          	bltz	a0,80005e96 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005e46:	f6c40593          	addi	a1,s0,-148
    80005e4a:	4505                	li	a0,1
    80005e4c:	ffffd097          	auipc	ra,0xffffd
    80005e50:	166080e7          	jalr	358(ra) # 80002fb2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e54:	04054163          	bltz	a0,80005e96 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005e58:	f6840593          	addi	a1,s0,-152
    80005e5c:	4509                	li	a0,2
    80005e5e:	ffffd097          	auipc	ra,0xffffd
    80005e62:	154080e7          	jalr	340(ra) # 80002fb2 <argint>
     argint(1, &major) < 0 ||
    80005e66:	02054863          	bltz	a0,80005e96 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005e6a:	f6841683          	lh	a3,-152(s0)
    80005e6e:	f6c41603          	lh	a2,-148(s0)
    80005e72:	458d                	li	a1,3
    80005e74:	f7040513          	addi	a0,s0,-144
    80005e78:	fffff097          	auipc	ra,0xfffff
    80005e7c:	778080e7          	jalr	1912(ra) # 800055f0 <create>
     argint(2, &minor) < 0 ||
    80005e80:	c919                	beqz	a0,80005e96 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e82:	ffffe097          	auipc	ra,0xffffe
    80005e86:	08a080e7          	jalr	138(ra) # 80003f0c <iunlockput>
  end_op();
    80005e8a:	fffff097          	auipc	ra,0xfffff
    80005e8e:	876080e7          	jalr	-1930(ra) # 80004700 <end_op>
  return 0;
    80005e92:	4501                	li	a0,0
    80005e94:	a031                	j	80005ea0 <sys_mknod+0x80>
    end_op();
    80005e96:	fffff097          	auipc	ra,0xfffff
    80005e9a:	86a080e7          	jalr	-1942(ra) # 80004700 <end_op>
    return -1;
    80005e9e:	557d                	li	a0,-1
}
    80005ea0:	60ea                	ld	ra,152(sp)
    80005ea2:	644a                	ld	s0,144(sp)
    80005ea4:	610d                	addi	sp,sp,160
    80005ea6:	8082                	ret

0000000080005ea8 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005ea8:	7135                	addi	sp,sp,-160
    80005eaa:	ed06                	sd	ra,152(sp)
    80005eac:	e922                	sd	s0,144(sp)
    80005eae:	e526                	sd	s1,136(sp)
    80005eb0:	e14a                	sd	s2,128(sp)
    80005eb2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005eb4:	ffffc097          	auipc	ra,0xffffc
    80005eb8:	aca080e7          	jalr	-1334(ra) # 8000197e <myproc>
    80005ebc:	892a                	mv	s2,a0
  
  begin_op();
    80005ebe:	ffffe097          	auipc	ra,0xffffe
    80005ec2:	7c2080e7          	jalr	1986(ra) # 80004680 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005ec6:	08000613          	li	a2,128
    80005eca:	f6040593          	addi	a1,s0,-160
    80005ece:	4501                	li	a0,0
    80005ed0:	ffffd097          	auipc	ra,0xffffd
    80005ed4:	126080e7          	jalr	294(ra) # 80002ff6 <argstr>
    80005ed8:	04054b63          	bltz	a0,80005f2e <sys_chdir+0x86>
    80005edc:	f6040513          	addi	a0,s0,-160
    80005ee0:	ffffe097          	auipc	ra,0xffffe
    80005ee4:	580080e7          	jalr	1408(ra) # 80004460 <namei>
    80005ee8:	84aa                	mv	s1,a0
    80005eea:	c131                	beqz	a0,80005f2e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005eec:	ffffe097          	auipc	ra,0xffffe
    80005ef0:	dbe080e7          	jalr	-578(ra) # 80003caa <ilock>
  if(ip->type != T_DIR){
    80005ef4:	04449703          	lh	a4,68(s1)
    80005ef8:	4785                	li	a5,1
    80005efa:	04f71063          	bne	a4,a5,80005f3a <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005efe:	8526                	mv	a0,s1
    80005f00:	ffffe097          	auipc	ra,0xffffe
    80005f04:	e6c080e7          	jalr	-404(ra) # 80003d6c <iunlock>
  iput(p->cwd);
    80005f08:	17893503          	ld	a0,376(s2)
    80005f0c:	ffffe097          	auipc	ra,0xffffe
    80005f10:	f58080e7          	jalr	-168(ra) # 80003e64 <iput>
  end_op();
    80005f14:	ffffe097          	auipc	ra,0xffffe
    80005f18:	7ec080e7          	jalr	2028(ra) # 80004700 <end_op>
  p->cwd = ip;
    80005f1c:	16993c23          	sd	s1,376(s2)
  return 0;
    80005f20:	4501                	li	a0,0
}
    80005f22:	60ea                	ld	ra,152(sp)
    80005f24:	644a                	ld	s0,144(sp)
    80005f26:	64aa                	ld	s1,136(sp)
    80005f28:	690a                	ld	s2,128(sp)
    80005f2a:	610d                	addi	sp,sp,160
    80005f2c:	8082                	ret
    end_op();
    80005f2e:	ffffe097          	auipc	ra,0xffffe
    80005f32:	7d2080e7          	jalr	2002(ra) # 80004700 <end_op>
    return -1;
    80005f36:	557d                	li	a0,-1
    80005f38:	b7ed                	j	80005f22 <sys_chdir+0x7a>
    iunlockput(ip);
    80005f3a:	8526                	mv	a0,s1
    80005f3c:	ffffe097          	auipc	ra,0xffffe
    80005f40:	fd0080e7          	jalr	-48(ra) # 80003f0c <iunlockput>
    end_op();
    80005f44:	ffffe097          	auipc	ra,0xffffe
    80005f48:	7bc080e7          	jalr	1980(ra) # 80004700 <end_op>
    return -1;
    80005f4c:	557d                	li	a0,-1
    80005f4e:	bfd1                	j	80005f22 <sys_chdir+0x7a>

0000000080005f50 <sys_exec>:

uint64
sys_exec(void)
{
    80005f50:	7145                	addi	sp,sp,-464
    80005f52:	e786                	sd	ra,456(sp)
    80005f54:	e3a2                	sd	s0,448(sp)
    80005f56:	ff26                	sd	s1,440(sp)
    80005f58:	fb4a                	sd	s2,432(sp)
    80005f5a:	f74e                	sd	s3,424(sp)
    80005f5c:	f352                	sd	s4,416(sp)
    80005f5e:	ef56                	sd	s5,408(sp)
    80005f60:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005f62:	08000613          	li	a2,128
    80005f66:	f4040593          	addi	a1,s0,-192
    80005f6a:	4501                	li	a0,0
    80005f6c:	ffffd097          	auipc	ra,0xffffd
    80005f70:	08a080e7          	jalr	138(ra) # 80002ff6 <argstr>
    return -1;
    80005f74:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005f76:	0c054a63          	bltz	a0,8000604a <sys_exec+0xfa>
    80005f7a:	e3840593          	addi	a1,s0,-456
    80005f7e:	4505                	li	a0,1
    80005f80:	ffffd097          	auipc	ra,0xffffd
    80005f84:	054080e7          	jalr	84(ra) # 80002fd4 <argaddr>
    80005f88:	0c054163          	bltz	a0,8000604a <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005f8c:	10000613          	li	a2,256
    80005f90:	4581                	li	a1,0
    80005f92:	e4040513          	addi	a0,s0,-448
    80005f96:	ffffb097          	auipc	ra,0xffffb
    80005f9a:	d28080e7          	jalr	-728(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f9e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005fa2:	89a6                	mv	s3,s1
    80005fa4:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005fa6:	02000a13          	li	s4,32
    80005faa:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005fae:	00391793          	slli	a5,s2,0x3
    80005fb2:	e3040593          	addi	a1,s0,-464
    80005fb6:	e3843503          	ld	a0,-456(s0)
    80005fba:	953e                	add	a0,a0,a5
    80005fbc:	ffffd097          	auipc	ra,0xffffd
    80005fc0:	f5c080e7          	jalr	-164(ra) # 80002f18 <fetchaddr>
    80005fc4:	02054a63          	bltz	a0,80005ff8 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005fc8:	e3043783          	ld	a5,-464(s0)
    80005fcc:	c3b9                	beqz	a5,80006012 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005fce:	ffffb097          	auipc	ra,0xffffb
    80005fd2:	b04080e7          	jalr	-1276(ra) # 80000ad2 <kalloc>
    80005fd6:	85aa                	mv	a1,a0
    80005fd8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005fdc:	cd11                	beqz	a0,80005ff8 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005fde:	6605                	lui	a2,0x1
    80005fe0:	e3043503          	ld	a0,-464(s0)
    80005fe4:	ffffd097          	auipc	ra,0xffffd
    80005fe8:	f86080e7          	jalr	-122(ra) # 80002f6a <fetchstr>
    80005fec:	00054663          	bltz	a0,80005ff8 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005ff0:	0905                	addi	s2,s2,1
    80005ff2:	09a1                	addi	s3,s3,8
    80005ff4:	fb491be3          	bne	s2,s4,80005faa <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ff8:	10048913          	addi	s2,s1,256
    80005ffc:	6088                	ld	a0,0(s1)
    80005ffe:	c529                	beqz	a0,80006048 <sys_exec+0xf8>
    kfree(argv[i]);
    80006000:	ffffb097          	auipc	ra,0xffffb
    80006004:	9d6080e7          	jalr	-1578(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006008:	04a1                	addi	s1,s1,8
    8000600a:	ff2499e3          	bne	s1,s2,80005ffc <sys_exec+0xac>
  return -1;
    8000600e:	597d                	li	s2,-1
    80006010:	a82d                	j	8000604a <sys_exec+0xfa>
      argv[i] = 0;
    80006012:	0a8e                	slli	s5,s5,0x3
    80006014:	fc040793          	addi	a5,s0,-64
    80006018:	9abe                	add	s5,s5,a5
    8000601a:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd8e80>
  int ret = exec(path, argv);
    8000601e:	e4040593          	addi	a1,s0,-448
    80006022:	f4040513          	addi	a0,s0,-192
    80006026:	fffff097          	auipc	ra,0xfffff
    8000602a:	178080e7          	jalr	376(ra) # 8000519e <exec>
    8000602e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006030:	10048993          	addi	s3,s1,256
    80006034:	6088                	ld	a0,0(s1)
    80006036:	c911                	beqz	a0,8000604a <sys_exec+0xfa>
    kfree(argv[i]);
    80006038:	ffffb097          	auipc	ra,0xffffb
    8000603c:	99e080e7          	jalr	-1634(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006040:	04a1                	addi	s1,s1,8
    80006042:	ff3499e3          	bne	s1,s3,80006034 <sys_exec+0xe4>
    80006046:	a011                	j	8000604a <sys_exec+0xfa>
  return -1;
    80006048:	597d                	li	s2,-1
}
    8000604a:	854a                	mv	a0,s2
    8000604c:	60be                	ld	ra,456(sp)
    8000604e:	641e                	ld	s0,448(sp)
    80006050:	74fa                	ld	s1,440(sp)
    80006052:	795a                	ld	s2,432(sp)
    80006054:	79ba                	ld	s3,424(sp)
    80006056:	7a1a                	ld	s4,416(sp)
    80006058:	6afa                	ld	s5,408(sp)
    8000605a:	6179                	addi	sp,sp,464
    8000605c:	8082                	ret

000000008000605e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000605e:	7139                	addi	sp,sp,-64
    80006060:	fc06                	sd	ra,56(sp)
    80006062:	f822                	sd	s0,48(sp)
    80006064:	f426                	sd	s1,40(sp)
    80006066:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006068:	ffffc097          	auipc	ra,0xffffc
    8000606c:	916080e7          	jalr	-1770(ra) # 8000197e <myproc>
    80006070:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006072:	fd840593          	addi	a1,s0,-40
    80006076:	4501                	li	a0,0
    80006078:	ffffd097          	auipc	ra,0xffffd
    8000607c:	f5c080e7          	jalr	-164(ra) # 80002fd4 <argaddr>
    return -1;
    80006080:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006082:	0e054063          	bltz	a0,80006162 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006086:	fc840593          	addi	a1,s0,-56
    8000608a:	fd040513          	addi	a0,s0,-48
    8000608e:	fffff097          	auipc	ra,0xfffff
    80006092:	dee080e7          	jalr	-530(ra) # 80004e7c <pipealloc>
    return -1;
    80006096:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006098:	0c054563          	bltz	a0,80006162 <sys_pipe+0x104>
  fd0 = -1;
    8000609c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800060a0:	fd043503          	ld	a0,-48(s0)
    800060a4:	fffff097          	auipc	ra,0xfffff
    800060a8:	50a080e7          	jalr	1290(ra) # 800055ae <fdalloc>
    800060ac:	fca42223          	sw	a0,-60(s0)
    800060b0:	08054c63          	bltz	a0,80006148 <sys_pipe+0xea>
    800060b4:	fc843503          	ld	a0,-56(s0)
    800060b8:	fffff097          	auipc	ra,0xfffff
    800060bc:	4f6080e7          	jalr	1270(ra) # 800055ae <fdalloc>
    800060c0:	fca42023          	sw	a0,-64(s0)
    800060c4:	06054863          	bltz	a0,80006134 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060c8:	4691                	li	a3,4
    800060ca:	fc440613          	addi	a2,s0,-60
    800060ce:	fd843583          	ld	a1,-40(s0)
    800060d2:	7ca8                	ld	a0,120(s1)
    800060d4:	ffffb097          	auipc	ra,0xffffb
    800060d8:	56a080e7          	jalr	1386(ra) # 8000163e <copyout>
    800060dc:	02054063          	bltz	a0,800060fc <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800060e0:	4691                	li	a3,4
    800060e2:	fc040613          	addi	a2,s0,-64
    800060e6:	fd843583          	ld	a1,-40(s0)
    800060ea:	0591                	addi	a1,a1,4
    800060ec:	7ca8                	ld	a0,120(s1)
    800060ee:	ffffb097          	auipc	ra,0xffffb
    800060f2:	550080e7          	jalr	1360(ra) # 8000163e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800060f6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060f8:	06055563          	bgez	a0,80006162 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    800060fc:	fc442783          	lw	a5,-60(s0)
    80006100:	07f9                	addi	a5,a5,30
    80006102:	078e                	slli	a5,a5,0x3
    80006104:	97a6                	add	a5,a5,s1
    80006106:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    8000610a:	fc042503          	lw	a0,-64(s0)
    8000610e:	0579                	addi	a0,a0,30
    80006110:	050e                	slli	a0,a0,0x3
    80006112:	9526                	add	a0,a0,s1
    80006114:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80006118:	fd043503          	ld	a0,-48(s0)
    8000611c:	fffff097          	auipc	ra,0xfffff
    80006120:	a30080e7          	jalr	-1488(ra) # 80004b4c <fileclose>
    fileclose(wf);
    80006124:	fc843503          	ld	a0,-56(s0)
    80006128:	fffff097          	auipc	ra,0xfffff
    8000612c:	a24080e7          	jalr	-1500(ra) # 80004b4c <fileclose>
    return -1;
    80006130:	57fd                	li	a5,-1
    80006132:	a805                	j	80006162 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006134:	fc442783          	lw	a5,-60(s0)
    80006138:	0007c863          	bltz	a5,80006148 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    8000613c:	01e78513          	addi	a0,a5,30
    80006140:	050e                	slli	a0,a0,0x3
    80006142:	9526                	add	a0,a0,s1
    80006144:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80006148:	fd043503          	ld	a0,-48(s0)
    8000614c:	fffff097          	auipc	ra,0xfffff
    80006150:	a00080e7          	jalr	-1536(ra) # 80004b4c <fileclose>
    fileclose(wf);
    80006154:	fc843503          	ld	a0,-56(s0)
    80006158:	fffff097          	auipc	ra,0xfffff
    8000615c:	9f4080e7          	jalr	-1548(ra) # 80004b4c <fileclose>
    return -1;
    80006160:	57fd                	li	a5,-1
}
    80006162:	853e                	mv	a0,a5
    80006164:	70e2                	ld	ra,56(sp)
    80006166:	7442                	ld	s0,48(sp)
    80006168:	74a2                	ld	s1,40(sp)
    8000616a:	6121                	addi	sp,sp,64
    8000616c:	8082                	ret
	...

0000000080006170 <kernelvec>:
    80006170:	7111                	addi	sp,sp,-256
    80006172:	e006                	sd	ra,0(sp)
    80006174:	e40a                	sd	sp,8(sp)
    80006176:	e80e                	sd	gp,16(sp)
    80006178:	ec12                	sd	tp,24(sp)
    8000617a:	f016                	sd	t0,32(sp)
    8000617c:	f41a                	sd	t1,40(sp)
    8000617e:	f81e                	sd	t2,48(sp)
    80006180:	fc22                	sd	s0,56(sp)
    80006182:	e0a6                	sd	s1,64(sp)
    80006184:	e4aa                	sd	a0,72(sp)
    80006186:	e8ae                	sd	a1,80(sp)
    80006188:	ecb2                	sd	a2,88(sp)
    8000618a:	f0b6                	sd	a3,96(sp)
    8000618c:	f4ba                	sd	a4,104(sp)
    8000618e:	f8be                	sd	a5,112(sp)
    80006190:	fcc2                	sd	a6,120(sp)
    80006192:	e146                	sd	a7,128(sp)
    80006194:	e54a                	sd	s2,136(sp)
    80006196:	e94e                	sd	s3,144(sp)
    80006198:	ed52                	sd	s4,152(sp)
    8000619a:	f156                	sd	s5,160(sp)
    8000619c:	f55a                	sd	s6,168(sp)
    8000619e:	f95e                	sd	s7,176(sp)
    800061a0:	fd62                	sd	s8,184(sp)
    800061a2:	e1e6                	sd	s9,192(sp)
    800061a4:	e5ea                	sd	s10,200(sp)
    800061a6:	e9ee                	sd	s11,208(sp)
    800061a8:	edf2                	sd	t3,216(sp)
    800061aa:	f1f6                	sd	t4,224(sp)
    800061ac:	f5fa                	sd	t5,232(sp)
    800061ae:	f9fe                	sd	t6,240(sp)
    800061b0:	c23fc0ef          	jal	ra,80002dd2 <kerneltrap>
    800061b4:	6082                	ld	ra,0(sp)
    800061b6:	6122                	ld	sp,8(sp)
    800061b8:	61c2                	ld	gp,16(sp)
    800061ba:	7282                	ld	t0,32(sp)
    800061bc:	7322                	ld	t1,40(sp)
    800061be:	73c2                	ld	t2,48(sp)
    800061c0:	7462                	ld	s0,56(sp)
    800061c2:	6486                	ld	s1,64(sp)
    800061c4:	6526                	ld	a0,72(sp)
    800061c6:	65c6                	ld	a1,80(sp)
    800061c8:	6666                	ld	a2,88(sp)
    800061ca:	7686                	ld	a3,96(sp)
    800061cc:	7726                	ld	a4,104(sp)
    800061ce:	77c6                	ld	a5,112(sp)
    800061d0:	7866                	ld	a6,120(sp)
    800061d2:	688a                	ld	a7,128(sp)
    800061d4:	692a                	ld	s2,136(sp)
    800061d6:	69ca                	ld	s3,144(sp)
    800061d8:	6a6a                	ld	s4,152(sp)
    800061da:	7a8a                	ld	s5,160(sp)
    800061dc:	7b2a                	ld	s6,168(sp)
    800061de:	7bca                	ld	s7,176(sp)
    800061e0:	7c6a                	ld	s8,184(sp)
    800061e2:	6c8e                	ld	s9,192(sp)
    800061e4:	6d2e                	ld	s10,200(sp)
    800061e6:	6dce                	ld	s11,208(sp)
    800061e8:	6e6e                	ld	t3,216(sp)
    800061ea:	7e8e                	ld	t4,224(sp)
    800061ec:	7f2e                	ld	t5,232(sp)
    800061ee:	7fce                	ld	t6,240(sp)
    800061f0:	6111                	addi	sp,sp,256
    800061f2:	10200073          	sret
    800061f6:	00000013          	nop
    800061fa:	00000013          	nop
    800061fe:	0001                	nop

0000000080006200 <timervec>:
    80006200:	34051573          	csrrw	a0,mscratch,a0
    80006204:	e10c                	sd	a1,0(a0)
    80006206:	e510                	sd	a2,8(a0)
    80006208:	e914                	sd	a3,16(a0)
    8000620a:	6d0c                	ld	a1,24(a0)
    8000620c:	7110                	ld	a2,32(a0)
    8000620e:	6194                	ld	a3,0(a1)
    80006210:	96b2                	add	a3,a3,a2
    80006212:	e194                	sd	a3,0(a1)
    80006214:	4589                	li	a1,2
    80006216:	14459073          	csrw	sip,a1
    8000621a:	6914                	ld	a3,16(a0)
    8000621c:	6510                	ld	a2,8(a0)
    8000621e:	610c                	ld	a1,0(a0)
    80006220:	34051573          	csrrw	a0,mscratch,a0
    80006224:	30200073          	mret
	...

000000008000622a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000622a:	1141                	addi	sp,sp,-16
    8000622c:	e422                	sd	s0,8(sp)
    8000622e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006230:	0c0007b7          	lui	a5,0xc000
    80006234:	4705                	li	a4,1
    80006236:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006238:	c3d8                	sw	a4,4(a5)
}
    8000623a:	6422                	ld	s0,8(sp)
    8000623c:	0141                	addi	sp,sp,16
    8000623e:	8082                	ret

0000000080006240 <plicinithart>:

void
plicinithart(void)
{
    80006240:	1141                	addi	sp,sp,-16
    80006242:	e406                	sd	ra,8(sp)
    80006244:	e022                	sd	s0,0(sp)
    80006246:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006248:	ffffb097          	auipc	ra,0xffffb
    8000624c:	70a080e7          	jalr	1802(ra) # 80001952 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006250:	0085171b          	slliw	a4,a0,0x8
    80006254:	0c0027b7          	lui	a5,0xc002
    80006258:	97ba                	add	a5,a5,a4
    8000625a:	40200713          	li	a4,1026
    8000625e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006262:	00d5151b          	slliw	a0,a0,0xd
    80006266:	0c2017b7          	lui	a5,0xc201
    8000626a:	953e                	add	a0,a0,a5
    8000626c:	00052023          	sw	zero,0(a0)
}
    80006270:	60a2                	ld	ra,8(sp)
    80006272:	6402                	ld	s0,0(sp)
    80006274:	0141                	addi	sp,sp,16
    80006276:	8082                	ret

0000000080006278 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006278:	1141                	addi	sp,sp,-16
    8000627a:	e406                	sd	ra,8(sp)
    8000627c:	e022                	sd	s0,0(sp)
    8000627e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006280:	ffffb097          	auipc	ra,0xffffb
    80006284:	6d2080e7          	jalr	1746(ra) # 80001952 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006288:	00d5179b          	slliw	a5,a0,0xd
    8000628c:	0c201537          	lui	a0,0xc201
    80006290:	953e                	add	a0,a0,a5
  return irq;
}
    80006292:	4148                	lw	a0,4(a0)
    80006294:	60a2                	ld	ra,8(sp)
    80006296:	6402                	ld	s0,0(sp)
    80006298:	0141                	addi	sp,sp,16
    8000629a:	8082                	ret

000000008000629c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000629c:	1101                	addi	sp,sp,-32
    8000629e:	ec06                	sd	ra,24(sp)
    800062a0:	e822                	sd	s0,16(sp)
    800062a2:	e426                	sd	s1,8(sp)
    800062a4:	1000                	addi	s0,sp,32
    800062a6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800062a8:	ffffb097          	auipc	ra,0xffffb
    800062ac:	6aa080e7          	jalr	1706(ra) # 80001952 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800062b0:	00d5151b          	slliw	a0,a0,0xd
    800062b4:	0c2017b7          	lui	a5,0xc201
    800062b8:	97aa                	add	a5,a5,a0
    800062ba:	c3c4                	sw	s1,4(a5)
}
    800062bc:	60e2                	ld	ra,24(sp)
    800062be:	6442                	ld	s0,16(sp)
    800062c0:	64a2                	ld	s1,8(sp)
    800062c2:	6105                	addi	sp,sp,32
    800062c4:	8082                	ret

00000000800062c6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800062c6:	1141                	addi	sp,sp,-16
    800062c8:	e406                	sd	ra,8(sp)
    800062ca:	e022                	sd	s0,0(sp)
    800062cc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800062ce:	479d                	li	a5,7
    800062d0:	06a7c963          	blt	a5,a0,80006342 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800062d4:	0001d797          	auipc	a5,0x1d
    800062d8:	d2c78793          	addi	a5,a5,-724 # 80023000 <disk>
    800062dc:	00a78733          	add	a4,a5,a0
    800062e0:	6789                	lui	a5,0x2
    800062e2:	97ba                	add	a5,a5,a4
    800062e4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800062e8:	e7ad                	bnez	a5,80006352 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800062ea:	00451793          	slli	a5,a0,0x4
    800062ee:	0001f717          	auipc	a4,0x1f
    800062f2:	d1270713          	addi	a4,a4,-750 # 80025000 <disk+0x2000>
    800062f6:	6314                	ld	a3,0(a4)
    800062f8:	96be                	add	a3,a3,a5
    800062fa:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800062fe:	6314                	ld	a3,0(a4)
    80006300:	96be                	add	a3,a3,a5
    80006302:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006306:	6314                	ld	a3,0(a4)
    80006308:	96be                	add	a3,a3,a5
    8000630a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000630e:	6318                	ld	a4,0(a4)
    80006310:	97ba                	add	a5,a5,a4
    80006312:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006316:	0001d797          	auipc	a5,0x1d
    8000631a:	cea78793          	addi	a5,a5,-790 # 80023000 <disk>
    8000631e:	97aa                	add	a5,a5,a0
    80006320:	6509                	lui	a0,0x2
    80006322:	953e                	add	a0,a0,a5
    80006324:	4785                	li	a5,1
    80006326:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000632a:	0001f517          	auipc	a0,0x1f
    8000632e:	cee50513          	addi	a0,a0,-786 # 80025018 <disk+0x2018>
    80006332:	ffffc097          	auipc	ra,0xffffc
    80006336:	102080e7          	jalr	258(ra) # 80002434 <wakeup>
}
    8000633a:	60a2                	ld	ra,8(sp)
    8000633c:	6402                	ld	s0,0(sp)
    8000633e:	0141                	addi	sp,sp,16
    80006340:	8082                	ret
    panic("free_desc 1");
    80006342:	00002517          	auipc	a0,0x2
    80006346:	62e50513          	addi	a0,a0,1582 # 80008970 <syscalls+0x330>
    8000634a:	ffffa097          	auipc	ra,0xffffa
    8000634e:	1e0080e7          	jalr	480(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006352:	00002517          	auipc	a0,0x2
    80006356:	62e50513          	addi	a0,a0,1582 # 80008980 <syscalls+0x340>
    8000635a:	ffffa097          	auipc	ra,0xffffa
    8000635e:	1d0080e7          	jalr	464(ra) # 8000052a <panic>

0000000080006362 <virtio_disk_init>:
{
    80006362:	1101                	addi	sp,sp,-32
    80006364:	ec06                	sd	ra,24(sp)
    80006366:	e822                	sd	s0,16(sp)
    80006368:	e426                	sd	s1,8(sp)
    8000636a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000636c:	00002597          	auipc	a1,0x2
    80006370:	62458593          	addi	a1,a1,1572 # 80008990 <syscalls+0x350>
    80006374:	0001f517          	auipc	a0,0x1f
    80006378:	db450513          	addi	a0,a0,-588 # 80025128 <disk+0x2128>
    8000637c:	ffffa097          	auipc	ra,0xffffa
    80006380:	7b6080e7          	jalr	1974(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006384:	100017b7          	lui	a5,0x10001
    80006388:	4398                	lw	a4,0(a5)
    8000638a:	2701                	sext.w	a4,a4
    8000638c:	747277b7          	lui	a5,0x74727
    80006390:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006394:	0ef71163          	bne	a4,a5,80006476 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006398:	100017b7          	lui	a5,0x10001
    8000639c:	43dc                	lw	a5,4(a5)
    8000639e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063a0:	4705                	li	a4,1
    800063a2:	0ce79a63          	bne	a5,a4,80006476 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063a6:	100017b7          	lui	a5,0x10001
    800063aa:	479c                	lw	a5,8(a5)
    800063ac:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800063ae:	4709                	li	a4,2
    800063b0:	0ce79363          	bne	a5,a4,80006476 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800063b4:	100017b7          	lui	a5,0x10001
    800063b8:	47d8                	lw	a4,12(a5)
    800063ba:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063bc:	554d47b7          	lui	a5,0x554d4
    800063c0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800063c4:	0af71963          	bne	a4,a5,80006476 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063c8:	100017b7          	lui	a5,0x10001
    800063cc:	4705                	li	a4,1
    800063ce:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063d0:	470d                	li	a4,3
    800063d2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800063d4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800063d6:	c7ffe737          	lui	a4,0xc7ffe
    800063da:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    800063de:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800063e0:	2701                	sext.w	a4,a4
    800063e2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063e4:	472d                	li	a4,11
    800063e6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063e8:	473d                	li	a4,15
    800063ea:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800063ec:	6705                	lui	a4,0x1
    800063ee:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800063f0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800063f4:	5bdc                	lw	a5,52(a5)
    800063f6:	2781                	sext.w	a5,a5
  if(max == 0)
    800063f8:	c7d9                	beqz	a5,80006486 <virtio_disk_init+0x124>
  if(max < NUM)
    800063fa:	471d                	li	a4,7
    800063fc:	08f77d63          	bgeu	a4,a5,80006496 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006400:	100014b7          	lui	s1,0x10001
    80006404:	47a1                	li	a5,8
    80006406:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006408:	6609                	lui	a2,0x2
    8000640a:	4581                	li	a1,0
    8000640c:	0001d517          	auipc	a0,0x1d
    80006410:	bf450513          	addi	a0,a0,-1036 # 80023000 <disk>
    80006414:	ffffb097          	auipc	ra,0xffffb
    80006418:	8aa080e7          	jalr	-1878(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000641c:	0001d717          	auipc	a4,0x1d
    80006420:	be470713          	addi	a4,a4,-1052 # 80023000 <disk>
    80006424:	00c75793          	srli	a5,a4,0xc
    80006428:	2781                	sext.w	a5,a5
    8000642a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000642c:	0001f797          	auipc	a5,0x1f
    80006430:	bd478793          	addi	a5,a5,-1068 # 80025000 <disk+0x2000>
    80006434:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006436:	0001d717          	auipc	a4,0x1d
    8000643a:	c4a70713          	addi	a4,a4,-950 # 80023080 <disk+0x80>
    8000643e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006440:	0001e717          	auipc	a4,0x1e
    80006444:	bc070713          	addi	a4,a4,-1088 # 80024000 <disk+0x1000>
    80006448:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000644a:	4705                	li	a4,1
    8000644c:	00e78c23          	sb	a4,24(a5)
    80006450:	00e78ca3          	sb	a4,25(a5)
    80006454:	00e78d23          	sb	a4,26(a5)
    80006458:	00e78da3          	sb	a4,27(a5)
    8000645c:	00e78e23          	sb	a4,28(a5)
    80006460:	00e78ea3          	sb	a4,29(a5)
    80006464:	00e78f23          	sb	a4,30(a5)
    80006468:	00e78fa3          	sb	a4,31(a5)
}
    8000646c:	60e2                	ld	ra,24(sp)
    8000646e:	6442                	ld	s0,16(sp)
    80006470:	64a2                	ld	s1,8(sp)
    80006472:	6105                	addi	sp,sp,32
    80006474:	8082                	ret
    panic("could not find virtio disk");
    80006476:	00002517          	auipc	a0,0x2
    8000647a:	52a50513          	addi	a0,a0,1322 # 800089a0 <syscalls+0x360>
    8000647e:	ffffa097          	auipc	ra,0xffffa
    80006482:	0ac080e7          	jalr	172(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006486:	00002517          	auipc	a0,0x2
    8000648a:	53a50513          	addi	a0,a0,1338 # 800089c0 <syscalls+0x380>
    8000648e:	ffffa097          	auipc	ra,0xffffa
    80006492:	09c080e7          	jalr	156(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006496:	00002517          	auipc	a0,0x2
    8000649a:	54a50513          	addi	a0,a0,1354 # 800089e0 <syscalls+0x3a0>
    8000649e:	ffffa097          	auipc	ra,0xffffa
    800064a2:	08c080e7          	jalr	140(ra) # 8000052a <panic>

00000000800064a6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800064a6:	7119                	addi	sp,sp,-128
    800064a8:	fc86                	sd	ra,120(sp)
    800064aa:	f8a2                	sd	s0,112(sp)
    800064ac:	f4a6                	sd	s1,104(sp)
    800064ae:	f0ca                	sd	s2,96(sp)
    800064b0:	ecce                	sd	s3,88(sp)
    800064b2:	e8d2                	sd	s4,80(sp)
    800064b4:	e4d6                	sd	s5,72(sp)
    800064b6:	e0da                	sd	s6,64(sp)
    800064b8:	fc5e                	sd	s7,56(sp)
    800064ba:	f862                	sd	s8,48(sp)
    800064bc:	f466                	sd	s9,40(sp)
    800064be:	f06a                	sd	s10,32(sp)
    800064c0:	ec6e                	sd	s11,24(sp)
    800064c2:	0100                	addi	s0,sp,128
    800064c4:	8aaa                	mv	s5,a0
    800064c6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800064c8:	00c52c83          	lw	s9,12(a0)
    800064cc:	001c9c9b          	slliw	s9,s9,0x1
    800064d0:	1c82                	slli	s9,s9,0x20
    800064d2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800064d6:	0001f517          	auipc	a0,0x1f
    800064da:	c5250513          	addi	a0,a0,-942 # 80025128 <disk+0x2128>
    800064de:	ffffa097          	auipc	ra,0xffffa
    800064e2:	6e4080e7          	jalr	1764(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    800064e6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800064e8:	44a1                	li	s1,8
      disk.free[i] = 0;
    800064ea:	0001dc17          	auipc	s8,0x1d
    800064ee:	b16c0c13          	addi	s8,s8,-1258 # 80023000 <disk>
    800064f2:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    800064f4:	4b0d                	li	s6,3
    800064f6:	a0ad                	j	80006560 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    800064f8:	00fc0733          	add	a4,s8,a5
    800064fc:	975e                	add	a4,a4,s7
    800064fe:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006502:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006504:	0207c563          	bltz	a5,8000652e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006508:	2905                	addiw	s2,s2,1
    8000650a:	0611                	addi	a2,a2,4
    8000650c:	19690d63          	beq	s2,s6,800066a6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006510:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006512:	0001f717          	auipc	a4,0x1f
    80006516:	b0670713          	addi	a4,a4,-1274 # 80025018 <disk+0x2018>
    8000651a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000651c:	00074683          	lbu	a3,0(a4)
    80006520:	fee1                	bnez	a3,800064f8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006522:	2785                	addiw	a5,a5,1
    80006524:	0705                	addi	a4,a4,1
    80006526:	fe979be3          	bne	a5,s1,8000651c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000652a:	57fd                	li	a5,-1
    8000652c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000652e:	01205d63          	blez	s2,80006548 <virtio_disk_rw+0xa2>
    80006532:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006534:	000a2503          	lw	a0,0(s4)
    80006538:	00000097          	auipc	ra,0x0
    8000653c:	d8e080e7          	jalr	-626(ra) # 800062c6 <free_desc>
      for(int j = 0; j < i; j++)
    80006540:	2d85                	addiw	s11,s11,1
    80006542:	0a11                	addi	s4,s4,4
    80006544:	ffb918e3          	bne	s2,s11,80006534 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006548:	0001f597          	auipc	a1,0x1f
    8000654c:	be058593          	addi	a1,a1,-1056 # 80025128 <disk+0x2128>
    80006550:	0001f517          	auipc	a0,0x1f
    80006554:	ac850513          	addi	a0,a0,-1336 # 80025018 <disk+0x2018>
    80006558:	ffffc097          	auipc	ra,0xffffc
    8000655c:	d50080e7          	jalr	-688(ra) # 800022a8 <sleep>
  for(int i = 0; i < 3; i++){
    80006560:	f8040a13          	addi	s4,s0,-128
{
    80006564:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006566:	894e                	mv	s2,s3
    80006568:	b765                	j	80006510 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000656a:	0001f697          	auipc	a3,0x1f
    8000656e:	a966b683          	ld	a3,-1386(a3) # 80025000 <disk+0x2000>
    80006572:	96ba                	add	a3,a3,a4
    80006574:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006578:	0001d817          	auipc	a6,0x1d
    8000657c:	a8880813          	addi	a6,a6,-1400 # 80023000 <disk>
    80006580:	0001f697          	auipc	a3,0x1f
    80006584:	a8068693          	addi	a3,a3,-1408 # 80025000 <disk+0x2000>
    80006588:	6290                	ld	a2,0(a3)
    8000658a:	963a                	add	a2,a2,a4
    8000658c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006590:	0015e593          	ori	a1,a1,1
    80006594:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006598:	f8842603          	lw	a2,-120(s0)
    8000659c:	628c                	ld	a1,0(a3)
    8000659e:	972e                	add	a4,a4,a1
    800065a0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800065a4:	20050593          	addi	a1,a0,512
    800065a8:	0592                	slli	a1,a1,0x4
    800065aa:	95c2                	add	a1,a1,a6
    800065ac:	577d                	li	a4,-1
    800065ae:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800065b2:	00461713          	slli	a4,a2,0x4
    800065b6:	6290                	ld	a2,0(a3)
    800065b8:	963a                	add	a2,a2,a4
    800065ba:	03078793          	addi	a5,a5,48
    800065be:	97c2                	add	a5,a5,a6
    800065c0:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800065c2:	629c                	ld	a5,0(a3)
    800065c4:	97ba                	add	a5,a5,a4
    800065c6:	4605                	li	a2,1
    800065c8:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800065ca:	629c                	ld	a5,0(a3)
    800065cc:	97ba                	add	a5,a5,a4
    800065ce:	4809                	li	a6,2
    800065d0:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800065d4:	629c                	ld	a5,0(a3)
    800065d6:	973e                	add	a4,a4,a5
    800065d8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800065dc:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800065e0:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800065e4:	6698                	ld	a4,8(a3)
    800065e6:	00275783          	lhu	a5,2(a4)
    800065ea:	8b9d                	andi	a5,a5,7
    800065ec:	0786                	slli	a5,a5,0x1
    800065ee:	97ba                	add	a5,a5,a4
    800065f0:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    800065f4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800065f8:	6698                	ld	a4,8(a3)
    800065fa:	00275783          	lhu	a5,2(a4)
    800065fe:	2785                	addiw	a5,a5,1
    80006600:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006604:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006608:	100017b7          	lui	a5,0x10001
    8000660c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006610:	004aa783          	lw	a5,4(s5)
    80006614:	02c79163          	bne	a5,a2,80006636 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006618:	0001f917          	auipc	s2,0x1f
    8000661c:	b1090913          	addi	s2,s2,-1264 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80006620:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006622:	85ca                	mv	a1,s2
    80006624:	8556                	mv	a0,s5
    80006626:	ffffc097          	auipc	ra,0xffffc
    8000662a:	c82080e7          	jalr	-894(ra) # 800022a8 <sleep>
  while(b->disk == 1) {
    8000662e:	004aa783          	lw	a5,4(s5)
    80006632:	fe9788e3          	beq	a5,s1,80006622 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006636:	f8042903          	lw	s2,-128(s0)
    8000663a:	20090793          	addi	a5,s2,512
    8000663e:	00479713          	slli	a4,a5,0x4
    80006642:	0001d797          	auipc	a5,0x1d
    80006646:	9be78793          	addi	a5,a5,-1602 # 80023000 <disk>
    8000664a:	97ba                	add	a5,a5,a4
    8000664c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006650:	0001f997          	auipc	s3,0x1f
    80006654:	9b098993          	addi	s3,s3,-1616 # 80025000 <disk+0x2000>
    80006658:	00491713          	slli	a4,s2,0x4
    8000665c:	0009b783          	ld	a5,0(s3)
    80006660:	97ba                	add	a5,a5,a4
    80006662:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006666:	854a                	mv	a0,s2
    80006668:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000666c:	00000097          	auipc	ra,0x0
    80006670:	c5a080e7          	jalr	-934(ra) # 800062c6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006674:	8885                	andi	s1,s1,1
    80006676:	f0ed                	bnez	s1,80006658 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006678:	0001f517          	auipc	a0,0x1f
    8000667c:	ab050513          	addi	a0,a0,-1360 # 80025128 <disk+0x2128>
    80006680:	ffffa097          	auipc	ra,0xffffa
    80006684:	5f6080e7          	jalr	1526(ra) # 80000c76 <release>
}
    80006688:	70e6                	ld	ra,120(sp)
    8000668a:	7446                	ld	s0,112(sp)
    8000668c:	74a6                	ld	s1,104(sp)
    8000668e:	7906                	ld	s2,96(sp)
    80006690:	69e6                	ld	s3,88(sp)
    80006692:	6a46                	ld	s4,80(sp)
    80006694:	6aa6                	ld	s5,72(sp)
    80006696:	6b06                	ld	s6,64(sp)
    80006698:	7be2                	ld	s7,56(sp)
    8000669a:	7c42                	ld	s8,48(sp)
    8000669c:	7ca2                	ld	s9,40(sp)
    8000669e:	7d02                	ld	s10,32(sp)
    800066a0:	6de2                	ld	s11,24(sp)
    800066a2:	6109                	addi	sp,sp,128
    800066a4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800066a6:	f8042503          	lw	a0,-128(s0)
    800066aa:	20050793          	addi	a5,a0,512
    800066ae:	0792                	slli	a5,a5,0x4
  if(write)
    800066b0:	0001d817          	auipc	a6,0x1d
    800066b4:	95080813          	addi	a6,a6,-1712 # 80023000 <disk>
    800066b8:	00f80733          	add	a4,a6,a5
    800066bc:	01a036b3          	snez	a3,s10
    800066c0:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800066c4:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800066c8:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800066cc:	7679                	lui	a2,0xffffe
    800066ce:	963e                	add	a2,a2,a5
    800066d0:	0001f697          	auipc	a3,0x1f
    800066d4:	93068693          	addi	a3,a3,-1744 # 80025000 <disk+0x2000>
    800066d8:	6298                	ld	a4,0(a3)
    800066da:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800066dc:	0a878593          	addi	a1,a5,168
    800066e0:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    800066e2:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800066e4:	6298                	ld	a4,0(a3)
    800066e6:	9732                	add	a4,a4,a2
    800066e8:	45c1                	li	a1,16
    800066ea:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800066ec:	6298                	ld	a4,0(a3)
    800066ee:	9732                	add	a4,a4,a2
    800066f0:	4585                	li	a1,1
    800066f2:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800066f6:	f8442703          	lw	a4,-124(s0)
    800066fa:	628c                	ld	a1,0(a3)
    800066fc:	962e                	add	a2,a2,a1
    800066fe:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006702:	0712                	slli	a4,a4,0x4
    80006704:	6290                	ld	a2,0(a3)
    80006706:	963a                	add	a2,a2,a4
    80006708:	058a8593          	addi	a1,s5,88
    8000670c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000670e:	6294                	ld	a3,0(a3)
    80006710:	96ba                	add	a3,a3,a4
    80006712:	40000613          	li	a2,1024
    80006716:	c690                	sw	a2,8(a3)
  if(write)
    80006718:	e40d19e3          	bnez	s10,8000656a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000671c:	0001f697          	auipc	a3,0x1f
    80006720:	8e46b683          	ld	a3,-1820(a3) # 80025000 <disk+0x2000>
    80006724:	96ba                	add	a3,a3,a4
    80006726:	4609                	li	a2,2
    80006728:	00c69623          	sh	a2,12(a3)
    8000672c:	b5b1                	j	80006578 <virtio_disk_rw+0xd2>

000000008000672e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000672e:	1101                	addi	sp,sp,-32
    80006730:	ec06                	sd	ra,24(sp)
    80006732:	e822                	sd	s0,16(sp)
    80006734:	e426                	sd	s1,8(sp)
    80006736:	e04a                	sd	s2,0(sp)
    80006738:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000673a:	0001f517          	auipc	a0,0x1f
    8000673e:	9ee50513          	addi	a0,a0,-1554 # 80025128 <disk+0x2128>
    80006742:	ffffa097          	auipc	ra,0xffffa
    80006746:	480080e7          	jalr	1152(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000674a:	10001737          	lui	a4,0x10001
    8000674e:	533c                	lw	a5,96(a4)
    80006750:	8b8d                	andi	a5,a5,3
    80006752:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006754:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006758:	0001f797          	auipc	a5,0x1f
    8000675c:	8a878793          	addi	a5,a5,-1880 # 80025000 <disk+0x2000>
    80006760:	6b94                	ld	a3,16(a5)
    80006762:	0207d703          	lhu	a4,32(a5)
    80006766:	0026d783          	lhu	a5,2(a3)
    8000676a:	06f70163          	beq	a4,a5,800067cc <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000676e:	0001d917          	auipc	s2,0x1d
    80006772:	89290913          	addi	s2,s2,-1902 # 80023000 <disk>
    80006776:	0001f497          	auipc	s1,0x1f
    8000677a:	88a48493          	addi	s1,s1,-1910 # 80025000 <disk+0x2000>
    __sync_synchronize();
    8000677e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006782:	6898                	ld	a4,16(s1)
    80006784:	0204d783          	lhu	a5,32(s1)
    80006788:	8b9d                	andi	a5,a5,7
    8000678a:	078e                	slli	a5,a5,0x3
    8000678c:	97ba                	add	a5,a5,a4
    8000678e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006790:	20078713          	addi	a4,a5,512
    80006794:	0712                	slli	a4,a4,0x4
    80006796:	974a                	add	a4,a4,s2
    80006798:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000679c:	e731                	bnez	a4,800067e8 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000679e:	20078793          	addi	a5,a5,512
    800067a2:	0792                	slli	a5,a5,0x4
    800067a4:	97ca                	add	a5,a5,s2
    800067a6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800067a8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800067ac:	ffffc097          	auipc	ra,0xffffc
    800067b0:	c88080e7          	jalr	-888(ra) # 80002434 <wakeup>

    disk.used_idx += 1;
    800067b4:	0204d783          	lhu	a5,32(s1)
    800067b8:	2785                	addiw	a5,a5,1
    800067ba:	17c2                	slli	a5,a5,0x30
    800067bc:	93c1                	srli	a5,a5,0x30
    800067be:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800067c2:	6898                	ld	a4,16(s1)
    800067c4:	00275703          	lhu	a4,2(a4)
    800067c8:	faf71be3          	bne	a4,a5,8000677e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800067cc:	0001f517          	auipc	a0,0x1f
    800067d0:	95c50513          	addi	a0,a0,-1700 # 80025128 <disk+0x2128>
    800067d4:	ffffa097          	auipc	ra,0xffffa
    800067d8:	4a2080e7          	jalr	1186(ra) # 80000c76 <release>
}
    800067dc:	60e2                	ld	ra,24(sp)
    800067de:	6442                	ld	s0,16(sp)
    800067e0:	64a2                	ld	s1,8(sp)
    800067e2:	6902                	ld	s2,0(sp)
    800067e4:	6105                	addi	sp,sp,32
    800067e6:	8082                	ret
      panic("virtio_disk_intr status");
    800067e8:	00002517          	auipc	a0,0x2
    800067ec:	21850513          	addi	a0,a0,536 # 80008a00 <syscalls+0x3c0>
    800067f0:	ffffa097          	auipc	ra,0xffffa
    800067f4:	d3a080e7          	jalr	-710(ra) # 8000052a <panic>
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
