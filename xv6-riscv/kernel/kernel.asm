
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
    80000122:	3e2080e7          	jalr	994(ra) # 80002500 <either_copyin>
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
    800001b6:	7e4080e7          	jalr	2020(ra) # 80001996 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	f38080e7          	jalr	-200(ra) # 800020fa <sleep>
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
    80000202:	2ac080e7          	jalr	684(ra) # 800024aa <either_copyout>
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
    800002e2:	278080e7          	jalr	632(ra) # 80002556 <procdump>
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
    80000436:	e54080e7          	jalr	-428(ra) # 80002286 <wakeup>
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
    80000464:	00021797          	auipc	a5,0x21
    80000468:	6cc78793          	addi	a5,a5,1740 # 80021b30 <devsw>
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
    80000882:	a08080e7          	jalr	-1528(ra) # 80002286 <wakeup>
    
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
    8000090a:	00001097          	auipc	ra,0x1
    8000090e:	7f0080e7          	jalr	2032(ra) # 800020fa <sleep>
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
    80000b60:	e1e080e7          	jalr	-482(ra) # 8000197a <mycpu>
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
    80000b92:	dec080e7          	jalr	-532(ra) # 8000197a <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	de0080e7          	jalr	-544(ra) # 8000197a <mycpu>
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
    80000bb6:	dc8080e7          	jalr	-568(ra) # 8000197a <mycpu>
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
    80000bf6:	d88080e7          	jalr	-632(ra) # 8000197a <mycpu>
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
    80000c22:	d5c080e7          	jalr	-676(ra) # 8000197a <mycpu>
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
    80000e78:	af6080e7          	jalr	-1290(ra) # 8000196a <cpuid>
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
    80000e94:	ada080e7          	jalr	-1318(ra) # 8000196a <cpuid>
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
    80000eb6:	ac4080e7          	jalr	-1340(ra) # 80002976 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00005097          	auipc	ra,0x5
    80000ebe:	1c6080e7          	jalr	454(ra) # 80006080 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	03a080e7          	jalr	58(ra) # 80001efc <scheduler>
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
    80000f2e:	a24080e7          	jalr	-1500(ra) # 8000294e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	a44080e7          	jalr	-1468(ra) # 80002976 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00005097          	auipc	ra,0x5
    80000f3e:	130080e7          	jalr	304(ra) # 8000606a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00005097          	auipc	ra,0x5
    80000f46:	13e080e7          	jalr	318(ra) # 80006080 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	30c080e7          	jalr	780(ra) # 80003256 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	99e080e7          	jalr	-1634(ra) # 800038f0 <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	94c080e7          	jalr	-1716(ra) # 800048a6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	240080e7          	jalr	576(ra) # 800061a2 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	d28080e7          	jalr	-728(ra) # 80001c92 <userinit>
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
    80001826:	ec648493          	addi	s1,s1,-314 # 800116e8 <proc>
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
    80001840:	0aca0a13          	addi	s4,s4,172 # 800178e8 <tickslock>
    char *pa = kalloc();
    80001844:	fffff097          	auipc	ra,0xfffff
    80001848:	28e080e7          	jalr	654(ra) # 80000ad2 <kalloc>
    8000184c:	862a                	mv	a2,a0
    if(pa == 0)
    8000184e:	c131                	beqz	a0,80001892 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001850:	416485b3          	sub	a1,s1,s6
    80001854:	858d                	srai	a1,a1,0x3
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
    80001876:	18848493          	addi	s1,s1,392
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
  initlock(&runtime_lock,"runtime_lock");//ass3 task3
    800018e6:	00007597          	auipc	a1,0x7
    800018ea:	8fa58593          	addi	a1,a1,-1798 # 800081e0 <digits+0x1a0>
    800018ee:	00010517          	auipc	a0,0x10
    800018f2:	9e250513          	addi	a0,a0,-1566 # 800112d0 <runtime_lock>
    800018f6:	fffff097          	auipc	ra,0xfffff
    800018fa:	23c080e7          	jalr	572(ra) # 80000b32 <initlock>

  for(p = proc; p < &proc[NPROC]; p++) {
    800018fe:	00010497          	auipc	s1,0x10
    80001902:	dea48493          	addi	s1,s1,-534 # 800116e8 <proc>
      initlock(&p->lock, "proc");
    80001906:	00007b17          	auipc	s6,0x7
    8000190a:	8eab0b13          	addi	s6,s6,-1814 # 800081f0 <digits+0x1b0>
      p->kstack = KSTACK((int) (p - proc));
    8000190e:	8aa6                	mv	s5,s1
    80001910:	00006a17          	auipc	s4,0x6
    80001914:	6f0a0a13          	addi	s4,s4,1776 # 80008000 <etext>
    80001918:	04000937          	lui	s2,0x4000
    8000191c:	197d                	addi	s2,s2,-1
    8000191e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001920:	00016997          	auipc	s3,0x16
    80001924:	fc898993          	addi	s3,s3,-56 # 800178e8 <tickslock>
      initlock(&p->lock, "proc");
    80001928:	85da                	mv	a1,s6
    8000192a:	8526                	mv	a0,s1
    8000192c:	fffff097          	auipc	ra,0xfffff
    80001930:	206080e7          	jalr	518(ra) # 80000b32 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001934:	415487b3          	sub	a5,s1,s5
    80001938:	878d                	srai	a5,a5,0x3
    8000193a:	000a3703          	ld	a4,0(s4)
    8000193e:	02e787b3          	mul	a5,a5,a4
    80001942:	2785                	addiw	a5,a5,1
    80001944:	00d7979b          	slliw	a5,a5,0xd
    80001948:	40f907b3          	sub	a5,s2,a5
    8000194c:	f0bc                	sd	a5,96(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000194e:	18848493          	addi	s1,s1,392
    80001952:	fd349be3          	bne	s1,s3,80001928 <procinit+0x86>
  }
}
    80001956:	70e2                	ld	ra,56(sp)
    80001958:	7442                	ld	s0,48(sp)
    8000195a:	74a2                	ld	s1,40(sp)
    8000195c:	7902                	ld	s2,32(sp)
    8000195e:	69e2                	ld	s3,24(sp)
    80001960:	6a42                	ld	s4,16(sp)
    80001962:	6aa2                	ld	s5,8(sp)
    80001964:	6b02                	ld	s6,0(sp)
    80001966:	6121                	addi	sp,sp,64
    80001968:	8082                	ret

000000008000196a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000196a:	1141                	addi	sp,sp,-16
    8000196c:	e422                	sd	s0,8(sp)
    8000196e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001970:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001972:	2501                	sext.w	a0,a0
    80001974:	6422                	ld	s0,8(sp)
    80001976:	0141                	addi	sp,sp,16
    80001978:	8082                	ret

000000008000197a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    8000197a:	1141                	addi	sp,sp,-16
    8000197c:	e422                	sd	s0,8(sp)
    8000197e:	0800                	addi	s0,sp,16
    80001980:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001982:	2781                	sext.w	a5,a5
    80001984:	079e                	slli	a5,a5,0x7
  return c;
}
    80001986:	00010517          	auipc	a0,0x10
    8000198a:	96250513          	addi	a0,a0,-1694 # 800112e8 <cpus>
    8000198e:	953e                	add	a0,a0,a5
    80001990:	6422                	ld	s0,8(sp)
    80001992:	0141                	addi	sp,sp,16
    80001994:	8082                	ret

0000000080001996 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001996:	1101                	addi	sp,sp,-32
    80001998:	ec06                	sd	ra,24(sp)
    8000199a:	e822                	sd	s0,16(sp)
    8000199c:	e426                	sd	s1,8(sp)
    8000199e:	1000                	addi	s0,sp,32
  push_off();
    800019a0:	fffff097          	auipc	ra,0xfffff
    800019a4:	1d6080e7          	jalr	470(ra) # 80000b76 <push_off>
    800019a8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019aa:	2781                	sext.w	a5,a5
    800019ac:	079e                	slli	a5,a5,0x7
    800019ae:	00010717          	auipc	a4,0x10
    800019b2:	8f270713          	addi	a4,a4,-1806 # 800112a0 <pid_lock>
    800019b6:	97ba                	add	a5,a5,a4
    800019b8:	67a4                	ld	s1,72(a5)
  pop_off();
    800019ba:	fffff097          	auipc	ra,0xfffff
    800019be:	25c080e7          	jalr	604(ra) # 80000c16 <pop_off>
  return p;
}
    800019c2:	8526                	mv	a0,s1
    800019c4:	60e2                	ld	ra,24(sp)
    800019c6:	6442                	ld	s0,16(sp)
    800019c8:	64a2                	ld	s1,8(sp)
    800019ca:	6105                	addi	sp,sp,32
    800019cc:	8082                	ret

00000000800019ce <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019ce:	1141                	addi	sp,sp,-16
    800019d0:	e406                	sd	ra,8(sp)
    800019d2:	e022                	sd	s0,0(sp)
    800019d4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019d6:	00000097          	auipc	ra,0x0
    800019da:	fc0080e7          	jalr	-64(ra) # 80001996 <myproc>
    800019de:	fffff097          	auipc	ra,0xfffff
    800019e2:	298080e7          	jalr	664(ra) # 80000c76 <release>

  if (first) {
    800019e6:	00007797          	auipc	a5,0x7
    800019ea:	01a7a783          	lw	a5,26(a5) # 80008a00 <first.1>
    800019ee:	eb89                	bnez	a5,80001a00 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019f0:	00001097          	auipc	ra,0x1
    800019f4:	f9e080e7          	jalr	-98(ra) # 8000298e <usertrapret>
}
    800019f8:	60a2                	ld	ra,8(sp)
    800019fa:	6402                	ld	s0,0(sp)
    800019fc:	0141                	addi	sp,sp,16
    800019fe:	8082                	ret
    first = 0;
    80001a00:	00007797          	auipc	a5,0x7
    80001a04:	0007a023          	sw	zero,0(a5) # 80008a00 <first.1>
    fsinit(ROOTDEV);
    80001a08:	4505                	li	a0,1
    80001a0a:	00002097          	auipc	ra,0x2
    80001a0e:	e66080e7          	jalr	-410(ra) # 80003870 <fsinit>
    80001a12:	bff9                	j	800019f0 <forkret+0x22>

0000000080001a14 <allocpid>:
allocpid() {
    80001a14:	1101                	addi	sp,sp,-32
    80001a16:	ec06                	sd	ra,24(sp)
    80001a18:	e822                	sd	s0,16(sp)
    80001a1a:	e426                	sd	s1,8(sp)
    80001a1c:	e04a                	sd	s2,0(sp)
    80001a1e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a20:	00010917          	auipc	s2,0x10
    80001a24:	88090913          	addi	s2,s2,-1920 # 800112a0 <pid_lock>
    80001a28:	854a                	mv	a0,s2
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	198080e7          	jalr	408(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001a32:	00007797          	auipc	a5,0x7
    80001a36:	fd278793          	addi	a5,a5,-46 # 80008a04 <nextpid>
    80001a3a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a3c:	0014871b          	addiw	a4,s1,1
    80001a40:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a42:	854a                	mv	a0,s2
    80001a44:	fffff097          	auipc	ra,0xfffff
    80001a48:	232080e7          	jalr	562(ra) # 80000c76 <release>
}
    80001a4c:	8526                	mv	a0,s1
    80001a4e:	60e2                	ld	ra,24(sp)
    80001a50:	6442                	ld	s0,16(sp)
    80001a52:	64a2                	ld	s1,8(sp)
    80001a54:	6902                	ld	s2,0(sp)
    80001a56:	6105                	addi	sp,sp,32
    80001a58:	8082                	ret

0000000080001a5a <proc_pagetable>:
{
    80001a5a:	1101                	addi	sp,sp,-32
    80001a5c:	ec06                	sd	ra,24(sp)
    80001a5e:	e822                	sd	s0,16(sp)
    80001a60:	e426                	sd	s1,8(sp)
    80001a62:	e04a                	sd	s2,0(sp)
    80001a64:	1000                	addi	s0,sp,32
    80001a66:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a68:	00000097          	auipc	ra,0x0
    80001a6c:	89e080e7          	jalr	-1890(ra) # 80001306 <uvmcreate>
    80001a70:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a72:	c121                	beqz	a0,80001ab2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a74:	4729                	li	a4,10
    80001a76:	00005697          	auipc	a3,0x5
    80001a7a:	58a68693          	addi	a3,a3,1418 # 80007000 <_trampoline>
    80001a7e:	6605                	lui	a2,0x1
    80001a80:	040005b7          	lui	a1,0x4000
    80001a84:	15fd                	addi	a1,a1,-1
    80001a86:	05b2                	slli	a1,a1,0xc
    80001a88:	fffff097          	auipc	ra,0xfffff
    80001a8c:	606080e7          	jalr	1542(ra) # 8000108e <mappages>
    80001a90:	02054863          	bltz	a0,80001ac0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a94:	4719                	li	a4,6
    80001a96:	07893683          	ld	a3,120(s2)
    80001a9a:	6605                	lui	a2,0x1
    80001a9c:	020005b7          	lui	a1,0x2000
    80001aa0:	15fd                	addi	a1,a1,-1
    80001aa2:	05b6                	slli	a1,a1,0xd
    80001aa4:	8526                	mv	a0,s1
    80001aa6:	fffff097          	auipc	ra,0xfffff
    80001aaa:	5e8080e7          	jalr	1512(ra) # 8000108e <mappages>
    80001aae:	02054163          	bltz	a0,80001ad0 <proc_pagetable+0x76>
}
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	60e2                	ld	ra,24(sp)
    80001ab6:	6442                	ld	s0,16(sp)
    80001ab8:	64a2                	ld	s1,8(sp)
    80001aba:	6902                	ld	s2,0(sp)
    80001abc:	6105                	addi	sp,sp,32
    80001abe:	8082                	ret
    uvmfree(pagetable, 0);
    80001ac0:	4581                	li	a1,0
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	00000097          	auipc	ra,0x0
    80001ac8:	a3e080e7          	jalr	-1474(ra) # 80001502 <uvmfree>
    return 0;
    80001acc:	4481                	li	s1,0
    80001ace:	b7d5                	j	80001ab2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ad0:	4681                	li	a3,0
    80001ad2:	4605                	li	a2,1
    80001ad4:	040005b7          	lui	a1,0x4000
    80001ad8:	15fd                	addi	a1,a1,-1
    80001ada:	05b2                	slli	a1,a1,0xc
    80001adc:	8526                	mv	a0,s1
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	764080e7          	jalr	1892(ra) # 80001242 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ae6:	4581                	li	a1,0
    80001ae8:	8526                	mv	a0,s1
    80001aea:	00000097          	auipc	ra,0x0
    80001aee:	a18080e7          	jalr	-1512(ra) # 80001502 <uvmfree>
    return 0;
    80001af2:	4481                	li	s1,0
    80001af4:	bf7d                	j	80001ab2 <proc_pagetable+0x58>

0000000080001af6 <proc_freepagetable>:
{
    80001af6:	1101                	addi	sp,sp,-32
    80001af8:	ec06                	sd	ra,24(sp)
    80001afa:	e822                	sd	s0,16(sp)
    80001afc:	e426                	sd	s1,8(sp)
    80001afe:	e04a                	sd	s2,0(sp)
    80001b00:	1000                	addi	s0,sp,32
    80001b02:	84aa                	mv	s1,a0
    80001b04:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b06:	4681                	li	a3,0
    80001b08:	4605                	li	a2,1
    80001b0a:	040005b7          	lui	a1,0x4000
    80001b0e:	15fd                	addi	a1,a1,-1
    80001b10:	05b2                	slli	a1,a1,0xc
    80001b12:	fffff097          	auipc	ra,0xfffff
    80001b16:	730080e7          	jalr	1840(ra) # 80001242 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b1a:	4681                	li	a3,0
    80001b1c:	4605                	li	a2,1
    80001b1e:	020005b7          	lui	a1,0x2000
    80001b22:	15fd                	addi	a1,a1,-1
    80001b24:	05b6                	slli	a1,a1,0xd
    80001b26:	8526                	mv	a0,s1
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	71a080e7          	jalr	1818(ra) # 80001242 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b30:	85ca                	mv	a1,s2
    80001b32:	8526                	mv	a0,s1
    80001b34:	00000097          	auipc	ra,0x0
    80001b38:	9ce080e7          	jalr	-1586(ra) # 80001502 <uvmfree>
}
    80001b3c:	60e2                	ld	ra,24(sp)
    80001b3e:	6442                	ld	s0,16(sp)
    80001b40:	64a2                	ld	s1,8(sp)
    80001b42:	6902                	ld	s2,0(sp)
    80001b44:	6105                	addi	sp,sp,32
    80001b46:	8082                	ret

0000000080001b48 <freeproc>:
{
    80001b48:	1101                	addi	sp,sp,-32
    80001b4a:	ec06                	sd	ra,24(sp)
    80001b4c:	e822                	sd	s0,16(sp)
    80001b4e:	e426                	sd	s1,8(sp)
    80001b50:	1000                	addi	s0,sp,32
    80001b52:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b54:	7d28                	ld	a0,120(a0)
    80001b56:	c509                	beqz	a0,80001b60 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	e7e080e7          	jalr	-386(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001b60:	0604bc23          	sd	zero,120(s1)
  if(p->pagetable)
    80001b64:	78a8                	ld	a0,112(s1)
    80001b66:	c511                	beqz	a0,80001b72 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b68:	74ac                	ld	a1,104(s1)
    80001b6a:	00000097          	auipc	ra,0x0
    80001b6e:	f8c080e7          	jalr	-116(ra) # 80001af6 <proc_freepagetable>
  p->pagetable = 0;
    80001b72:	0604b823          	sd	zero,112(s1)
  p->sz = 0;
    80001b76:	0604b423          	sd	zero,104(s1)
  p->pid = 0;
    80001b7a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b7e:	0404bc23          	sd	zero,88(s1)
  p->name[0] = 0;
    80001b82:	16048c23          	sb	zero,376(s1)
  p->chan = 0;
    80001b86:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b8a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b8e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b92:	0004ac23          	sw	zero,24(s1)
}
    80001b96:	60e2                	ld	ra,24(sp)
    80001b98:	6442                	ld	s0,16(sp)
    80001b9a:	64a2                	ld	s1,8(sp)
    80001b9c:	6105                	addi	sp,sp,32
    80001b9e:	8082                	ret

0000000080001ba0 <allocproc>:
{
    80001ba0:	1101                	addi	sp,sp,-32
    80001ba2:	ec06                	sd	ra,24(sp)
    80001ba4:	e822                	sd	s0,16(sp)
    80001ba6:	e426                	sd	s1,8(sp)
    80001ba8:	e04a                	sd	s2,0(sp)
    80001baa:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bac:	00010497          	auipc	s1,0x10
    80001bb0:	b3c48493          	addi	s1,s1,-1220 # 800116e8 <proc>
    80001bb4:	00016917          	auipc	s2,0x16
    80001bb8:	d3490913          	addi	s2,s2,-716 # 800178e8 <tickslock>
    acquire(&p->lock);
    80001bbc:	8526                	mv	a0,s1
    80001bbe:	fffff097          	auipc	ra,0xfffff
    80001bc2:	004080e7          	jalr	4(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    80001bc6:	4c9c                	lw	a5,24(s1)
    80001bc8:	cf81                	beqz	a5,80001be0 <allocproc+0x40>
      release(&p->lock);
    80001bca:	8526                	mv	a0,s1
    80001bcc:	fffff097          	auipc	ra,0xfffff
    80001bd0:	0aa080e7          	jalr	170(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bd4:	18848493          	addi	s1,s1,392
    80001bd8:	ff2492e3          	bne	s1,s2,80001bbc <allocproc+0x1c>
  return 0;
    80001bdc:	4481                	li	s1,0
    80001bde:	a89d                	j	80001c54 <allocproc+0xb4>
  p->pid = allocpid();
    80001be0:	00000097          	auipc	ra,0x0
    80001be4:	e34080e7          	jalr	-460(ra) # 80001a14 <allocpid>
    80001be8:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bea:	4785                	li	a5,1
    80001bec:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001bee:	fffff097          	auipc	ra,0xfffff
    80001bf2:	ee4080e7          	jalr	-284(ra) # 80000ad2 <kalloc>
    80001bf6:	892a                	mv	s2,a0
    80001bf8:	fca8                	sd	a0,120(s1)
    80001bfa:	c525                	beqz	a0,80001c62 <allocproc+0xc2>
  p->pagetable = proc_pagetable(p);
    80001bfc:	8526                	mv	a0,s1
    80001bfe:	00000097          	auipc	ra,0x0
    80001c02:	e5c080e7          	jalr	-420(ra) # 80001a5a <proc_pagetable>
    80001c06:	892a                	mv	s2,a0
    80001c08:	f8a8                	sd	a0,112(s1)
  if(p->pagetable == 0){
    80001c0a:	c925                	beqz	a0,80001c7a <allocproc+0xda>
  memset(&p->context, 0, sizeof(p->context));
    80001c0c:	07000613          	li	a2,112
    80001c10:	4581                	li	a1,0
    80001c12:	08048513          	addi	a0,s1,128
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	0a8080e7          	jalr	168(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80001c1e:	00000797          	auipc	a5,0x0
    80001c22:	db078793          	addi	a5,a5,-592 # 800019ce <forkret>
    80001c26:	e0dc                	sd	a5,128(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c28:	70bc                	ld	a5,96(s1)
    80001c2a:	6705                	lui	a4,0x1
    80001c2c:	97ba                	add	a5,a5,a4
    80001c2e:	e4dc                	sd	a5,136(s1)
  p->ctime = ticks;
    80001c30:	00007797          	auipc	a5,0x7
    80001c34:	4087a783          	lw	a5,1032(a5) # 80009038 <ticks>
    80001c38:	dc9c                	sw	a5,56(s1)
  p->ttime = -1;
    80001c3a:	57fd                	li	a5,-1
    80001c3c:	dcdc                	sw	a5,60(s1)
  p->stime = 0;
    80001c3e:	0404a023          	sw	zero,64(s1)
  p->retime = 0;
    80001c42:	0404a223          	sw	zero,68(s1)
  p->rutime = 0;
    80001c46:	0404a423          	sw	zero,72(s1)
  p->average_bursttime = QUANTUM * 100;
    80001c4a:	1f400793          	li	a5,500
    80001c4e:	c4fc                	sw	a5,76(s1)
  p->decay_factor = 5;
    80001c50:	4795                	li	a5,5
    80001c52:	c8bc                	sw	a5,80(s1)
}
    80001c54:	8526                	mv	a0,s1
    80001c56:	60e2                	ld	ra,24(sp)
    80001c58:	6442                	ld	s0,16(sp)
    80001c5a:	64a2                	ld	s1,8(sp)
    80001c5c:	6902                	ld	s2,0(sp)
    80001c5e:	6105                	addi	sp,sp,32
    80001c60:	8082                	ret
    freeproc(p);
    80001c62:	8526                	mv	a0,s1
    80001c64:	00000097          	auipc	ra,0x0
    80001c68:	ee4080e7          	jalr	-284(ra) # 80001b48 <freeproc>
    release(&p->lock);
    80001c6c:	8526                	mv	a0,s1
    80001c6e:	fffff097          	auipc	ra,0xfffff
    80001c72:	008080e7          	jalr	8(ra) # 80000c76 <release>
    return 0;
    80001c76:	84ca                	mv	s1,s2
    80001c78:	bff1                	j	80001c54 <allocproc+0xb4>
    freeproc(p);
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	00000097          	auipc	ra,0x0
    80001c80:	ecc080e7          	jalr	-308(ra) # 80001b48 <freeproc>
    release(&p->lock);
    80001c84:	8526                	mv	a0,s1
    80001c86:	fffff097          	auipc	ra,0xfffff
    80001c8a:	ff0080e7          	jalr	-16(ra) # 80000c76 <release>
    return 0;
    80001c8e:	84ca                	mv	s1,s2
    80001c90:	b7d1                	j	80001c54 <allocproc+0xb4>

0000000080001c92 <userinit>:
{
    80001c92:	1101                	addi	sp,sp,-32
    80001c94:	ec06                	sd	ra,24(sp)
    80001c96:	e822                	sd	s0,16(sp)
    80001c98:	e426                	sd	s1,8(sp)
    80001c9a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c9c:	00000097          	auipc	ra,0x0
    80001ca0:	f04080e7          	jalr	-252(ra) # 80001ba0 <allocproc>
    80001ca4:	84aa                	mv	s1,a0
  initproc = p;
    80001ca6:	00007797          	auipc	a5,0x7
    80001caa:	38a7b523          	sd	a0,906(a5) # 80009030 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cae:	03400613          	li	a2,52
    80001cb2:	00007597          	auipc	a1,0x7
    80001cb6:	d5e58593          	addi	a1,a1,-674 # 80008a10 <initcode>
    80001cba:	7928                	ld	a0,112(a0)
    80001cbc:	fffff097          	auipc	ra,0xfffff
    80001cc0:	678080e7          	jalr	1656(ra) # 80001334 <uvminit>
  p->sz = PGSIZE;
    80001cc4:	6785                	lui	a5,0x1
    80001cc6:	f4bc                	sd	a5,104(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cc8:	7cb8                	ld	a4,120(s1)
    80001cca:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cce:	7cb8                	ld	a4,120(s1)
    80001cd0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cd2:	4641                	li	a2,16
    80001cd4:	00006597          	auipc	a1,0x6
    80001cd8:	52458593          	addi	a1,a1,1316 # 800081f8 <digits+0x1b8>
    80001cdc:	17848513          	addi	a0,s1,376
    80001ce0:	fffff097          	auipc	ra,0xfffff
    80001ce4:	130080e7          	jalr	304(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80001ce8:	00006517          	auipc	a0,0x6
    80001cec:	52050513          	addi	a0,a0,1312 # 80008208 <digits+0x1c8>
    80001cf0:	00002097          	auipc	ra,0x2
    80001cf4:	5ae080e7          	jalr	1454(ra) # 8000429e <namei>
    80001cf8:	16a4b823          	sd	a0,368(s1)
  p->state = RUNNABLE;
    80001cfc:	478d                	li	a5,3
    80001cfe:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d00:	8526                	mv	a0,s1
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	f74080e7          	jalr	-140(ra) # 80000c76 <release>
}
    80001d0a:	60e2                	ld	ra,24(sp)
    80001d0c:	6442                	ld	s0,16(sp)
    80001d0e:	64a2                	ld	s1,8(sp)
    80001d10:	6105                	addi	sp,sp,32
    80001d12:	8082                	ret

0000000080001d14 <growproc>:
{
    80001d14:	1101                	addi	sp,sp,-32
    80001d16:	ec06                	sd	ra,24(sp)
    80001d18:	e822                	sd	s0,16(sp)
    80001d1a:	e426                	sd	s1,8(sp)
    80001d1c:	e04a                	sd	s2,0(sp)
    80001d1e:	1000                	addi	s0,sp,32
    80001d20:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d22:	00000097          	auipc	ra,0x0
    80001d26:	c74080e7          	jalr	-908(ra) # 80001996 <myproc>
    80001d2a:	892a                	mv	s2,a0
  sz = p->sz;
    80001d2c:	752c                	ld	a1,104(a0)
    80001d2e:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d32:	00904f63          	bgtz	s1,80001d50 <growproc+0x3c>
  } else if(n < 0){
    80001d36:	0204cc63          	bltz	s1,80001d6e <growproc+0x5a>
  p->sz = sz;
    80001d3a:	1602                	slli	a2,a2,0x20
    80001d3c:	9201                	srli	a2,a2,0x20
    80001d3e:	06c93423          	sd	a2,104(s2)
  return 0;
    80001d42:	4501                	li	a0,0
}
    80001d44:	60e2                	ld	ra,24(sp)
    80001d46:	6442                	ld	s0,16(sp)
    80001d48:	64a2                	ld	s1,8(sp)
    80001d4a:	6902                	ld	s2,0(sp)
    80001d4c:	6105                	addi	sp,sp,32
    80001d4e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d50:	9e25                	addw	a2,a2,s1
    80001d52:	1602                	slli	a2,a2,0x20
    80001d54:	9201                	srli	a2,a2,0x20
    80001d56:	1582                	slli	a1,a1,0x20
    80001d58:	9181                	srli	a1,a1,0x20
    80001d5a:	7928                	ld	a0,112(a0)
    80001d5c:	fffff097          	auipc	ra,0xfffff
    80001d60:	692080e7          	jalr	1682(ra) # 800013ee <uvmalloc>
    80001d64:	0005061b          	sext.w	a2,a0
    80001d68:	fa69                	bnez	a2,80001d3a <growproc+0x26>
      return -1;
    80001d6a:	557d                	li	a0,-1
    80001d6c:	bfe1                	j	80001d44 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d6e:	9e25                	addw	a2,a2,s1
    80001d70:	1602                	slli	a2,a2,0x20
    80001d72:	9201                	srli	a2,a2,0x20
    80001d74:	1582                	slli	a1,a1,0x20
    80001d76:	9181                	srli	a1,a1,0x20
    80001d78:	7928                	ld	a0,112(a0)
    80001d7a:	fffff097          	auipc	ra,0xfffff
    80001d7e:	62c080e7          	jalr	1580(ra) # 800013a6 <uvmdealloc>
    80001d82:	0005061b          	sext.w	a2,a0
    80001d86:	bf55                	j	80001d3a <growproc+0x26>

0000000080001d88 <perfi>:
perfi(struct proc *proc, struct perf *perf){
    80001d88:	1141                	addi	sp,sp,-16
    80001d8a:	e422                	sd	s0,8(sp)
    80001d8c:	0800                	addi	s0,sp,16
  perf->ctime = proc->ctime;
    80001d8e:	5d1c                	lw	a5,56(a0)
    80001d90:	c19c                	sw	a5,0(a1)
  perf->ttime = proc->ttime;
    80001d92:	5d5c                	lw	a5,60(a0)
    80001d94:	c1dc                	sw	a5,4(a1)
  perf->stime = proc->stime;
    80001d96:	413c                	lw	a5,64(a0)
    80001d98:	c59c                	sw	a5,8(a1)
  perf->retime = proc->retime;
    80001d9a:	417c                	lw	a5,68(a0)
    80001d9c:	c5dc                	sw	a5,12(a1)
  perf->rutime = proc->rutime;
    80001d9e:	453c                	lw	a5,72(a0)
    80001da0:	c99c                	sw	a5,16(a1)
  perf->bursttime = proc->average_bursttime;
    80001da2:	457c                	lw	a5,76(a0)
    80001da4:	c9dc                	sw	a5,20(a1)
}
    80001da6:	6422                	ld	s0,8(sp)
    80001da8:	0141                	addi	sp,sp,16
    80001daa:	8082                	ret

0000000080001dac <fork>:
{
    80001dac:	7139                	addi	sp,sp,-64
    80001dae:	fc06                	sd	ra,56(sp)
    80001db0:	f822                	sd	s0,48(sp)
    80001db2:	f426                	sd	s1,40(sp)
    80001db4:	f04a                	sd	s2,32(sp)
    80001db6:	ec4e                	sd	s3,24(sp)
    80001db8:	e852                	sd	s4,16(sp)
    80001dba:	e456                	sd	s5,8(sp)
    80001dbc:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dbe:	00000097          	auipc	ra,0x0
    80001dc2:	bd8080e7          	jalr	-1064(ra) # 80001996 <myproc>
    80001dc6:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001dc8:	00000097          	auipc	ra,0x0
    80001dcc:	dd8080e7          	jalr	-552(ra) # 80001ba0 <allocproc>
    80001dd0:	12050463          	beqz	a0,80001ef8 <fork+0x14c>
    80001dd4:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dd6:	068ab603          	ld	a2,104(s5)
    80001dda:	792c                	ld	a1,112(a0)
    80001ddc:	070ab503          	ld	a0,112(s5)
    80001de0:	fffff097          	auipc	ra,0xfffff
    80001de4:	75a080e7          	jalr	1882(ra) # 8000153a <uvmcopy>
    80001de8:	04054863          	bltz	a0,80001e38 <fork+0x8c>
  np->sz = p->sz;
    80001dec:	068ab783          	ld	a5,104(s5)
    80001df0:	06f9b423          	sd	a5,104(s3)
  *(np->trapframe) = *(p->trapframe);
    80001df4:	078ab683          	ld	a3,120(s5)
    80001df8:	87b6                	mv	a5,a3
    80001dfa:	0789b703          	ld	a4,120(s3)
    80001dfe:	12068693          	addi	a3,a3,288
    80001e02:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e06:	6788                	ld	a0,8(a5)
    80001e08:	6b8c                	ld	a1,16(a5)
    80001e0a:	6f90                	ld	a2,24(a5)
    80001e0c:	01073023          	sd	a6,0(a4)
    80001e10:	e708                	sd	a0,8(a4)
    80001e12:	eb0c                	sd	a1,16(a4)
    80001e14:	ef10                	sd	a2,24(a4)
    80001e16:	02078793          	addi	a5,a5,32
    80001e1a:	02070713          	addi	a4,a4,32
    80001e1e:	fed792e3          	bne	a5,a3,80001e02 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e22:	0789b783          	ld	a5,120(s3)
    80001e26:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e2a:	0f0a8493          	addi	s1,s5,240
    80001e2e:	0f098913          	addi	s2,s3,240
    80001e32:	170a8a13          	addi	s4,s5,368
    80001e36:	a00d                	j	80001e58 <fork+0xac>
    freeproc(np);
    80001e38:	854e                	mv	a0,s3
    80001e3a:	00000097          	auipc	ra,0x0
    80001e3e:	d0e080e7          	jalr	-754(ra) # 80001b48 <freeproc>
    release(&np->lock);
    80001e42:	854e                	mv	a0,s3
    80001e44:	fffff097          	auipc	ra,0xfffff
    80001e48:	e32080e7          	jalr	-462(ra) # 80000c76 <release>
    return -1;
    80001e4c:	597d                	li	s2,-1
    80001e4e:	a859                	j	80001ee4 <fork+0x138>
  for(i = 0; i < NOFILE; i++)
    80001e50:	04a1                	addi	s1,s1,8
    80001e52:	0921                	addi	s2,s2,8
    80001e54:	01448b63          	beq	s1,s4,80001e6a <fork+0xbe>
    if(p->ofile[i])
    80001e58:	6088                	ld	a0,0(s1)
    80001e5a:	d97d                	beqz	a0,80001e50 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e5c:	00003097          	auipc	ra,0x3
    80001e60:	adc080e7          	jalr	-1316(ra) # 80004938 <filedup>
    80001e64:	00a93023          	sd	a0,0(s2)
    80001e68:	b7e5                	j	80001e50 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e6a:	170ab503          	ld	a0,368(s5)
    80001e6e:	00002097          	auipc	ra,0x2
    80001e72:	c3c080e7          	jalr	-964(ra) # 80003aaa <idup>
    80001e76:	16a9b823          	sd	a0,368(s3)
  np->tracemask = p->tracemask;
    80001e7a:	034aa783          	lw	a5,52(s5)
    80001e7e:	02f9aa23          	sw	a5,52(s3)
  np->decay_factor = p->decay_factor;
    80001e82:	050aa783          	lw	a5,80(s5)
    80001e86:	04f9a823          	sw	a5,80(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e8a:	4641                	li	a2,16
    80001e8c:	178a8593          	addi	a1,s5,376
    80001e90:	17898513          	addi	a0,s3,376
    80001e94:	fffff097          	auipc	ra,0xfffff
    80001e98:	f7c080e7          	jalr	-132(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80001e9c:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001ea0:	854e                	mv	a0,s3
    80001ea2:	fffff097          	auipc	ra,0xfffff
    80001ea6:	dd4080e7          	jalr	-556(ra) # 80000c76 <release>
  acquire(&wait_lock);
    80001eaa:	0000f497          	auipc	s1,0xf
    80001eae:	40e48493          	addi	s1,s1,1038 # 800112b8 <wait_lock>
    80001eb2:	8526                	mv	a0,s1
    80001eb4:	fffff097          	auipc	ra,0xfffff
    80001eb8:	d0e080e7          	jalr	-754(ra) # 80000bc2 <acquire>
  np->parent = p;
    80001ebc:	0559bc23          	sd	s5,88(s3)
  release(&wait_lock);
    80001ec0:	8526                	mv	a0,s1
    80001ec2:	fffff097          	auipc	ra,0xfffff
    80001ec6:	db4080e7          	jalr	-588(ra) # 80000c76 <release>
  acquire(&np->lock);
    80001eca:	854e                	mv	a0,s3
    80001ecc:	fffff097          	auipc	ra,0xfffff
    80001ed0:	cf6080e7          	jalr	-778(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80001ed4:	478d                	li	a5,3
    80001ed6:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001eda:	854e                	mv	a0,s3
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	d9a080e7          	jalr	-614(ra) # 80000c76 <release>
}
    80001ee4:	854a                	mv	a0,s2
    80001ee6:	70e2                	ld	ra,56(sp)
    80001ee8:	7442                	ld	s0,48(sp)
    80001eea:	74a2                	ld	s1,40(sp)
    80001eec:	7902                	ld	s2,32(sp)
    80001eee:	69e2                	ld	s3,24(sp)
    80001ef0:	6a42                	ld	s4,16(sp)
    80001ef2:	6aa2                	ld	s5,8(sp)
    80001ef4:	6121                	addi	sp,sp,64
    80001ef6:	8082                	ret
    return -1;
    80001ef8:	597d                	li	s2,-1
    80001efa:	b7ed                	j	80001ee4 <fork+0x138>

0000000080001efc <scheduler>:
{
    80001efc:	715d                	addi	sp,sp,-80
    80001efe:	e486                	sd	ra,72(sp)
    80001f00:	e0a2                	sd	s0,64(sp)
    80001f02:	fc26                	sd	s1,56(sp)
    80001f04:	f84a                	sd	s2,48(sp)
    80001f06:	f44e                	sd	s3,40(sp)
    80001f08:	f052                	sd	s4,32(sp)
    80001f0a:	ec56                	sd	s5,24(sp)
    80001f0c:	e85a                	sd	s6,16(sp)
    80001f0e:	e45e                	sd	s7,8(sp)
    80001f10:	e062                	sd	s8,0(sp)
    80001f12:	0880                	addi	s0,sp,80
    80001f14:	8792                	mv	a5,tp
  int id = r_tp();
    80001f16:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f18:	00779b93          	slli	s7,a5,0x7
    80001f1c:	0000f717          	auipc	a4,0xf
    80001f20:	38470713          	addi	a4,a4,900 # 800112a0 <pid_lock>
    80001f24:	975e                	add	a4,a4,s7
    80001f26:	04073423          	sd	zero,72(a4)
        swtch(&c->context, &p->context);
    80001f2a:	0000f717          	auipc	a4,0xf
    80001f2e:	3c670713          	addi	a4,a4,966 # 800112f0 <cpus+0x8>
    80001f32:	9bba                	add	s7,s7,a4
        c->proc = p;
    80001f34:	079e                	slli	a5,a5,0x7
    80001f36:	0000fa17          	auipc	s4,0xf
    80001f3a:	36aa0a13          	addi	s4,s4,874 # 800112a0 <pid_lock>
    80001f3e:	9a3e                	add	s4,s4,a5
        acquire(&runtime_lock);
    80001f40:	0000fa97          	auipc	s5,0xf
    80001f44:	390a8a93          	addi	s5,s5,912 # 800112d0 <runtime_lock>
        current_runtime = 0;
    80001f48:	00007c17          	auipc	s8,0x7
    80001f4c:	0e0c0c13          	addi	s8,s8,224 # 80009028 <current_runtime>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f50:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f54:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f58:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f5c:	0000f497          	auipc	s1,0xf
    80001f60:	78c48493          	addi	s1,s1,1932 # 800116e8 <proc>
      if(p->state == RUNNABLE) {
    80001f64:	498d                	li	s3,3
        p->state = RUNNING;
    80001f66:	4b11                	li	s6,4
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f68:	00016917          	auipc	s2,0x16
    80001f6c:	98090913          	addi	s2,s2,-1664 # 800178e8 <tickslock>
    80001f70:	a811                	j	80001f84 <scheduler+0x88>
      release(&p->lock);
    80001f72:	8526                	mv	a0,s1
    80001f74:	fffff097          	auipc	ra,0xfffff
    80001f78:	d02080e7          	jalr	-766(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f7c:	18848493          	addi	s1,s1,392
    80001f80:	fd2488e3          	beq	s1,s2,80001f50 <scheduler+0x54>
      acquire(&p->lock);
    80001f84:	8526                	mv	a0,s1
    80001f86:	fffff097          	auipc	ra,0xfffff
    80001f8a:	c3c080e7          	jalr	-964(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE) {
    80001f8e:	4c9c                	lw	a5,24(s1)
    80001f90:	ff3791e3          	bne	a5,s3,80001f72 <scheduler+0x76>
        p->state = RUNNING;
    80001f94:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f98:	049a3423          	sd	s1,72(s4)
        acquire(&runtime_lock);
    80001f9c:	8556                	mv	a0,s5
    80001f9e:	fffff097          	auipc	ra,0xfffff
    80001fa2:	c24080e7          	jalr	-988(ra) # 80000bc2 <acquire>
        current_runtime = 0;
    80001fa6:	000c2023          	sw	zero,0(s8)
        release(&runtime_lock);
    80001faa:	8556                	mv	a0,s5
    80001fac:	fffff097          	auipc	ra,0xfffff
    80001fb0:	cca080e7          	jalr	-822(ra) # 80000c76 <release>
        swtch(&c->context, &p->context);
    80001fb4:	08048593          	addi	a1,s1,128
    80001fb8:	855e                	mv	a0,s7
    80001fba:	00001097          	auipc	ra,0x1
    80001fbe:	92a080e7          	jalr	-1750(ra) # 800028e4 <swtch>
        c->proc = 0;
    80001fc2:	040a3423          	sd	zero,72(s4)
    80001fc6:	b775                	j	80001f72 <scheduler+0x76>

0000000080001fc8 <sched>:
{
    80001fc8:	7179                	addi	sp,sp,-48
    80001fca:	f406                	sd	ra,40(sp)
    80001fcc:	f022                	sd	s0,32(sp)
    80001fce:	ec26                	sd	s1,24(sp)
    80001fd0:	e84a                	sd	s2,16(sp)
    80001fd2:	e44e                	sd	s3,8(sp)
    80001fd4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fd6:	00000097          	auipc	ra,0x0
    80001fda:	9c0080e7          	jalr	-1600(ra) # 80001996 <myproc>
    80001fde:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fe0:	fffff097          	auipc	ra,0xfffff
    80001fe4:	b68080e7          	jalr	-1176(ra) # 80000b48 <holding>
    80001fe8:	c959                	beqz	a0,8000207e <sched+0xb6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fea:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fec:	2781                	sext.w	a5,a5
    80001fee:	079e                	slli	a5,a5,0x7
    80001ff0:	0000f717          	auipc	a4,0xf
    80001ff4:	2b070713          	addi	a4,a4,688 # 800112a0 <pid_lock>
    80001ff8:	97ba                	add	a5,a5,a4
    80001ffa:	0c07a703          	lw	a4,192(a5)
    80001ffe:	4785                	li	a5,1
    80002000:	08f71763          	bne	a4,a5,8000208e <sched+0xc6>
  if(p->state == RUNNING)
    80002004:	4c98                	lw	a4,24(s1)
    80002006:	4791                	li	a5,4
    80002008:	08f70b63          	beq	a4,a5,8000209e <sched+0xd6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000200c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002010:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002012:	efd1                	bnez	a5,800020ae <sched+0xe6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002014:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002016:	0000f917          	auipc	s2,0xf
    8000201a:	28a90913          	addi	s2,s2,650 # 800112a0 <pid_lock>
    8000201e:	2781                	sext.w	a5,a5
    80002020:	079e                	slli	a5,a5,0x7
    80002022:	97ca                	add	a5,a5,s2
    80002024:	0c47a983          	lw	s3,196(a5)
  p->average_bursttime =  ALPHA * current_runtime + ((100-ALPHA) * p->average_bursttime) / 100;
    80002028:	03200793          	li	a5,50
    8000202c:	00007717          	auipc	a4,0x7
    80002030:	ffc72703          	lw	a4,-4(a4) # 80009028 <current_runtime>
    80002034:	02e787bb          	mulw	a5,a5,a4
    80002038:	44f4                	lw	a3,76(s1)
    8000203a:	01f6d71b          	srliw	a4,a3,0x1f
    8000203e:	9f35                	addw	a4,a4,a3
    80002040:	4017571b          	sraiw	a4,a4,0x1
    80002044:	9fb9                	addw	a5,a5,a4
    80002046:	c4fc                	sw	a5,76(s1)
    80002048:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000204a:	2781                	sext.w	a5,a5
    8000204c:	079e                	slli	a5,a5,0x7
    8000204e:	0000f597          	auipc	a1,0xf
    80002052:	2a258593          	addi	a1,a1,674 # 800112f0 <cpus+0x8>
    80002056:	95be                	add	a1,a1,a5
    80002058:	08048513          	addi	a0,s1,128
    8000205c:	00001097          	auipc	ra,0x1
    80002060:	888080e7          	jalr	-1912(ra) # 800028e4 <swtch>
    80002064:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002066:	2781                	sext.w	a5,a5
    80002068:	079e                	slli	a5,a5,0x7
    8000206a:	97ca                	add	a5,a5,s2
    8000206c:	0d37a223          	sw	s3,196(a5)
}
    80002070:	70a2                	ld	ra,40(sp)
    80002072:	7402                	ld	s0,32(sp)
    80002074:	64e2                	ld	s1,24(sp)
    80002076:	6942                	ld	s2,16(sp)
    80002078:	69a2                	ld	s3,8(sp)
    8000207a:	6145                	addi	sp,sp,48
    8000207c:	8082                	ret
    panic("sched p->lock");
    8000207e:	00006517          	auipc	a0,0x6
    80002082:	19250513          	addi	a0,a0,402 # 80008210 <digits+0x1d0>
    80002086:	ffffe097          	auipc	ra,0xffffe
    8000208a:	4a4080e7          	jalr	1188(ra) # 8000052a <panic>
    panic("sched locks");
    8000208e:	00006517          	auipc	a0,0x6
    80002092:	19250513          	addi	a0,a0,402 # 80008220 <digits+0x1e0>
    80002096:	ffffe097          	auipc	ra,0xffffe
    8000209a:	494080e7          	jalr	1172(ra) # 8000052a <panic>
    panic("sched running");
    8000209e:	00006517          	auipc	a0,0x6
    800020a2:	19250513          	addi	a0,a0,402 # 80008230 <digits+0x1f0>
    800020a6:	ffffe097          	auipc	ra,0xffffe
    800020aa:	484080e7          	jalr	1156(ra) # 8000052a <panic>
    panic("sched interruptible");
    800020ae:	00006517          	auipc	a0,0x6
    800020b2:	19250513          	addi	a0,a0,402 # 80008240 <digits+0x200>
    800020b6:	ffffe097          	auipc	ra,0xffffe
    800020ba:	474080e7          	jalr	1140(ra) # 8000052a <panic>

00000000800020be <yield>:
{
    800020be:	1101                	addi	sp,sp,-32
    800020c0:	ec06                	sd	ra,24(sp)
    800020c2:	e822                	sd	s0,16(sp)
    800020c4:	e426                	sd	s1,8(sp)
    800020c6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020c8:	00000097          	auipc	ra,0x0
    800020cc:	8ce080e7          	jalr	-1842(ra) # 80001996 <myproc>
    800020d0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020d2:	fffff097          	auipc	ra,0xfffff
    800020d6:	af0080e7          	jalr	-1296(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    800020da:	478d                	li	a5,3
    800020dc:	cc9c                	sw	a5,24(s1)
  sched();
    800020de:	00000097          	auipc	ra,0x0
    800020e2:	eea080e7          	jalr	-278(ra) # 80001fc8 <sched>
  release(&p->lock);
    800020e6:	8526                	mv	a0,s1
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	b8e080e7          	jalr	-1138(ra) # 80000c76 <release>
}
    800020f0:	60e2                	ld	ra,24(sp)
    800020f2:	6442                	ld	s0,16(sp)
    800020f4:	64a2                	ld	s1,8(sp)
    800020f6:	6105                	addi	sp,sp,32
    800020f8:	8082                	ret

00000000800020fa <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020fa:	7179                	addi	sp,sp,-48
    800020fc:	f406                	sd	ra,40(sp)
    800020fe:	f022                	sd	s0,32(sp)
    80002100:	ec26                	sd	s1,24(sp)
    80002102:	e84a                	sd	s2,16(sp)
    80002104:	e44e                	sd	s3,8(sp)
    80002106:	1800                	addi	s0,sp,48
    80002108:	89aa                	mv	s3,a0
    8000210a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000210c:	00000097          	auipc	ra,0x0
    80002110:	88a080e7          	jalr	-1910(ra) # 80001996 <myproc>
    80002114:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	aac080e7          	jalr	-1364(ra) # 80000bc2 <acquire>
  release(lk);
    8000211e:	854a                	mv	a0,s2
    80002120:	fffff097          	auipc	ra,0xfffff
    80002124:	b56080e7          	jalr	-1194(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    80002128:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000212c:	4789                	li	a5,2
    8000212e:	cc9c                	sw	a5,24(s1)

  sched();
    80002130:	00000097          	auipc	ra,0x0
    80002134:	e98080e7          	jalr	-360(ra) # 80001fc8 <sched>

  // Tidy up.
  p->chan = 0;
    80002138:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000213c:	8526                	mv	a0,s1
    8000213e:	fffff097          	auipc	ra,0xfffff
    80002142:	b38080e7          	jalr	-1224(ra) # 80000c76 <release>
  acquire(lk);
    80002146:	854a                	mv	a0,s2
    80002148:	fffff097          	auipc	ra,0xfffff
    8000214c:	a7a080e7          	jalr	-1414(ra) # 80000bc2 <acquire>
}
    80002150:	70a2                	ld	ra,40(sp)
    80002152:	7402                	ld	s0,32(sp)
    80002154:	64e2                	ld	s1,24(sp)
    80002156:	6942                	ld	s2,16(sp)
    80002158:	69a2                	ld	s3,8(sp)
    8000215a:	6145                	addi	sp,sp,48
    8000215c:	8082                	ret

000000008000215e <wait>:
{
    8000215e:	715d                	addi	sp,sp,-80
    80002160:	e486                	sd	ra,72(sp)
    80002162:	e0a2                	sd	s0,64(sp)
    80002164:	fc26                	sd	s1,56(sp)
    80002166:	f84a                	sd	s2,48(sp)
    80002168:	f44e                	sd	s3,40(sp)
    8000216a:	f052                	sd	s4,32(sp)
    8000216c:	ec56                	sd	s5,24(sp)
    8000216e:	e85a                	sd	s6,16(sp)
    80002170:	e45e                	sd	s7,8(sp)
    80002172:	e062                	sd	s8,0(sp)
    80002174:	0880                	addi	s0,sp,80
    80002176:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002178:	00000097          	auipc	ra,0x0
    8000217c:	81e080e7          	jalr	-2018(ra) # 80001996 <myproc>
    80002180:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002182:	0000f517          	auipc	a0,0xf
    80002186:	13650513          	addi	a0,a0,310 # 800112b8 <wait_lock>
    8000218a:	fffff097          	auipc	ra,0xfffff
    8000218e:	a38080e7          	jalr	-1480(ra) # 80000bc2 <acquire>
    havekids = 0;
    80002192:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002194:	4a15                	li	s4,5
        havekids = 1;
    80002196:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002198:	00015997          	auipc	s3,0x15
    8000219c:	75098993          	addi	s3,s3,1872 # 800178e8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021a0:	0000fc17          	auipc	s8,0xf
    800021a4:	118c0c13          	addi	s8,s8,280 # 800112b8 <wait_lock>
    havekids = 0;
    800021a8:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800021aa:	0000f497          	auipc	s1,0xf
    800021ae:	53e48493          	addi	s1,s1,1342 # 800116e8 <proc>
    800021b2:	a0bd                	j	80002220 <wait+0xc2>
          pid = np->pid;
    800021b4:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800021b8:	000b0e63          	beqz	s6,800021d4 <wait+0x76>
    800021bc:	4691                	li	a3,4
    800021be:	02c48613          	addi	a2,s1,44
    800021c2:	85da                	mv	a1,s6
    800021c4:	07093503          	ld	a0,112(s2)
    800021c8:	fffff097          	auipc	ra,0xfffff
    800021cc:	476080e7          	jalr	1142(ra) # 8000163e <copyout>
    800021d0:	02054563          	bltz	a0,800021fa <wait+0x9c>
          freeproc(np);
    800021d4:	8526                	mv	a0,s1
    800021d6:	00000097          	auipc	ra,0x0
    800021da:	972080e7          	jalr	-1678(ra) # 80001b48 <freeproc>
          release(&np->lock);
    800021de:	8526                	mv	a0,s1
    800021e0:	fffff097          	auipc	ra,0xfffff
    800021e4:	a96080e7          	jalr	-1386(ra) # 80000c76 <release>
          release(&wait_lock);
    800021e8:	0000f517          	auipc	a0,0xf
    800021ec:	0d050513          	addi	a0,a0,208 # 800112b8 <wait_lock>
    800021f0:	fffff097          	auipc	ra,0xfffff
    800021f4:	a86080e7          	jalr	-1402(ra) # 80000c76 <release>
          return pid;
    800021f8:	a09d                	j	8000225e <wait+0x100>
            release(&np->lock);
    800021fa:	8526                	mv	a0,s1
    800021fc:	fffff097          	auipc	ra,0xfffff
    80002200:	a7a080e7          	jalr	-1414(ra) # 80000c76 <release>
            release(&wait_lock);
    80002204:	0000f517          	auipc	a0,0xf
    80002208:	0b450513          	addi	a0,a0,180 # 800112b8 <wait_lock>
    8000220c:	fffff097          	auipc	ra,0xfffff
    80002210:	a6a080e7          	jalr	-1430(ra) # 80000c76 <release>
            return -1;
    80002214:	59fd                	li	s3,-1
    80002216:	a0a1                	j	8000225e <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002218:	18848493          	addi	s1,s1,392
    8000221c:	03348463          	beq	s1,s3,80002244 <wait+0xe6>
      if(np->parent == p){
    80002220:	6cbc                	ld	a5,88(s1)
    80002222:	ff279be3          	bne	a5,s2,80002218 <wait+0xba>
        acquire(&np->lock);
    80002226:	8526                	mv	a0,s1
    80002228:	fffff097          	auipc	ra,0xfffff
    8000222c:	99a080e7          	jalr	-1638(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    80002230:	4c9c                	lw	a5,24(s1)
    80002232:	f94781e3          	beq	a5,s4,800021b4 <wait+0x56>
        release(&np->lock);
    80002236:	8526                	mv	a0,s1
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	a3e080e7          	jalr	-1474(ra) # 80000c76 <release>
        havekids = 1;
    80002240:	8756                	mv	a4,s5
    80002242:	bfd9                	j	80002218 <wait+0xba>
    if(!havekids || p->killed){
    80002244:	c701                	beqz	a4,8000224c <wait+0xee>
    80002246:	02892783          	lw	a5,40(s2)
    8000224a:	c79d                	beqz	a5,80002278 <wait+0x11a>
      release(&wait_lock);
    8000224c:	0000f517          	auipc	a0,0xf
    80002250:	06c50513          	addi	a0,a0,108 # 800112b8 <wait_lock>
    80002254:	fffff097          	auipc	ra,0xfffff
    80002258:	a22080e7          	jalr	-1502(ra) # 80000c76 <release>
      return -1;
    8000225c:	59fd                	li	s3,-1
}
    8000225e:	854e                	mv	a0,s3
    80002260:	60a6                	ld	ra,72(sp)
    80002262:	6406                	ld	s0,64(sp)
    80002264:	74e2                	ld	s1,56(sp)
    80002266:	7942                	ld	s2,48(sp)
    80002268:	79a2                	ld	s3,40(sp)
    8000226a:	7a02                	ld	s4,32(sp)
    8000226c:	6ae2                	ld	s5,24(sp)
    8000226e:	6b42                	ld	s6,16(sp)
    80002270:	6ba2                	ld	s7,8(sp)
    80002272:	6c02                	ld	s8,0(sp)
    80002274:	6161                	addi	sp,sp,80
    80002276:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002278:	85e2                	mv	a1,s8
    8000227a:	854a                	mv	a0,s2
    8000227c:	00000097          	auipc	ra,0x0
    80002280:	e7e080e7          	jalr	-386(ra) # 800020fa <sleep>
    havekids = 0;
    80002284:	b715                	j	800021a8 <wait+0x4a>

0000000080002286 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002286:	7139                	addi	sp,sp,-64
    80002288:	fc06                	sd	ra,56(sp)
    8000228a:	f822                	sd	s0,48(sp)
    8000228c:	f426                	sd	s1,40(sp)
    8000228e:	f04a                	sd	s2,32(sp)
    80002290:	ec4e                	sd	s3,24(sp)
    80002292:	e852                	sd	s4,16(sp)
    80002294:	e456                	sd	s5,8(sp)
    80002296:	0080                	addi	s0,sp,64
    80002298:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000229a:	0000f497          	auipc	s1,0xf
    8000229e:	44e48493          	addi	s1,s1,1102 # 800116e8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800022a2:	4989                	li	s3,2
        p->state = RUNNABLE;
    800022a4:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800022a6:	00015917          	auipc	s2,0x15
    800022aa:	64290913          	addi	s2,s2,1602 # 800178e8 <tickslock>
    800022ae:	a811                	j	800022c2 <wakeup+0x3c>
      }
      release(&p->lock);
    800022b0:	8526                	mv	a0,s1
    800022b2:	fffff097          	auipc	ra,0xfffff
    800022b6:	9c4080e7          	jalr	-1596(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800022ba:	18848493          	addi	s1,s1,392
    800022be:	03248663          	beq	s1,s2,800022ea <wakeup+0x64>
    if(p != myproc()){
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	6d4080e7          	jalr	1748(ra) # 80001996 <myproc>
    800022ca:	fea488e3          	beq	s1,a0,800022ba <wakeup+0x34>
      acquire(&p->lock);
    800022ce:	8526                	mv	a0,s1
    800022d0:	fffff097          	auipc	ra,0xfffff
    800022d4:	8f2080e7          	jalr	-1806(ra) # 80000bc2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800022d8:	4c9c                	lw	a5,24(s1)
    800022da:	fd379be3          	bne	a5,s3,800022b0 <wakeup+0x2a>
    800022de:	709c                	ld	a5,32(s1)
    800022e0:	fd4798e3          	bne	a5,s4,800022b0 <wakeup+0x2a>
        p->state = RUNNABLE;
    800022e4:	0154ac23          	sw	s5,24(s1)
    800022e8:	b7e1                	j	800022b0 <wakeup+0x2a>
    }
  }
}
    800022ea:	70e2                	ld	ra,56(sp)
    800022ec:	7442                	ld	s0,48(sp)
    800022ee:	74a2                	ld	s1,40(sp)
    800022f0:	7902                	ld	s2,32(sp)
    800022f2:	69e2                	ld	s3,24(sp)
    800022f4:	6a42                	ld	s4,16(sp)
    800022f6:	6aa2                	ld	s5,8(sp)
    800022f8:	6121                	addi	sp,sp,64
    800022fa:	8082                	ret

00000000800022fc <reparent>:
{
    800022fc:	7179                	addi	sp,sp,-48
    800022fe:	f406                	sd	ra,40(sp)
    80002300:	f022                	sd	s0,32(sp)
    80002302:	ec26                	sd	s1,24(sp)
    80002304:	e84a                	sd	s2,16(sp)
    80002306:	e44e                	sd	s3,8(sp)
    80002308:	e052                	sd	s4,0(sp)
    8000230a:	1800                	addi	s0,sp,48
    8000230c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000230e:	0000f497          	auipc	s1,0xf
    80002312:	3da48493          	addi	s1,s1,986 # 800116e8 <proc>
      pp->parent = initproc;
    80002316:	00007a17          	auipc	s4,0x7
    8000231a:	d1aa0a13          	addi	s4,s4,-742 # 80009030 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000231e:	00015997          	auipc	s3,0x15
    80002322:	5ca98993          	addi	s3,s3,1482 # 800178e8 <tickslock>
    80002326:	a029                	j	80002330 <reparent+0x34>
    80002328:	18848493          	addi	s1,s1,392
    8000232c:	01348d63          	beq	s1,s3,80002346 <reparent+0x4a>
    if(pp->parent == p){
    80002330:	6cbc                	ld	a5,88(s1)
    80002332:	ff279be3          	bne	a5,s2,80002328 <reparent+0x2c>
      pp->parent = initproc;
    80002336:	000a3503          	ld	a0,0(s4)
    8000233a:	eca8                	sd	a0,88(s1)
      wakeup(initproc);
    8000233c:	00000097          	auipc	ra,0x0
    80002340:	f4a080e7          	jalr	-182(ra) # 80002286 <wakeup>
    80002344:	b7d5                	j	80002328 <reparent+0x2c>
}
    80002346:	70a2                	ld	ra,40(sp)
    80002348:	7402                	ld	s0,32(sp)
    8000234a:	64e2                	ld	s1,24(sp)
    8000234c:	6942                	ld	s2,16(sp)
    8000234e:	69a2                	ld	s3,8(sp)
    80002350:	6a02                	ld	s4,0(sp)
    80002352:	6145                	addi	sp,sp,48
    80002354:	8082                	ret

0000000080002356 <exit>:
{
    80002356:	7179                	addi	sp,sp,-48
    80002358:	f406                	sd	ra,40(sp)
    8000235a:	f022                	sd	s0,32(sp)
    8000235c:	ec26                	sd	s1,24(sp)
    8000235e:	e84a                	sd	s2,16(sp)
    80002360:	e44e                	sd	s3,8(sp)
    80002362:	e052                	sd	s4,0(sp)
    80002364:	1800                	addi	s0,sp,48
    80002366:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	62e080e7          	jalr	1582(ra) # 80001996 <myproc>
    80002370:	89aa                	mv	s3,a0
  if(p == initproc)
    80002372:	00007797          	auipc	a5,0x7
    80002376:	cbe7b783          	ld	a5,-834(a5) # 80009030 <initproc>
    8000237a:	0f050493          	addi	s1,a0,240
    8000237e:	17050913          	addi	s2,a0,368
    80002382:	02a79363          	bne	a5,a0,800023a8 <exit+0x52>
    panic("init exiting");
    80002386:	00006517          	auipc	a0,0x6
    8000238a:	ed250513          	addi	a0,a0,-302 # 80008258 <digits+0x218>
    8000238e:	ffffe097          	auipc	ra,0xffffe
    80002392:	19c080e7          	jalr	412(ra) # 8000052a <panic>
      fileclose(f);
    80002396:	00002097          	auipc	ra,0x2
    8000239a:	5f4080e7          	jalr	1524(ra) # 8000498a <fileclose>
      p->ofile[fd] = 0;
    8000239e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800023a2:	04a1                	addi	s1,s1,8
    800023a4:	01248563          	beq	s1,s2,800023ae <exit+0x58>
    if(p->ofile[fd]){
    800023a8:	6088                	ld	a0,0(s1)
    800023aa:	f575                	bnez	a0,80002396 <exit+0x40>
    800023ac:	bfdd                	j	800023a2 <exit+0x4c>
  begin_op();
    800023ae:	00002097          	auipc	ra,0x2
    800023b2:	110080e7          	jalr	272(ra) # 800044be <begin_op>
  iput(p->cwd);
    800023b6:	1709b503          	ld	a0,368(s3)
    800023ba:	00002097          	auipc	ra,0x2
    800023be:	8e8080e7          	jalr	-1816(ra) # 80003ca2 <iput>
  end_op();
    800023c2:	00002097          	auipc	ra,0x2
    800023c6:	17c080e7          	jalr	380(ra) # 8000453e <end_op>
  p->cwd = 0;
    800023ca:	1609b823          	sd	zero,368(s3)
  acquire(&wait_lock);
    800023ce:	0000f497          	auipc	s1,0xf
    800023d2:	eea48493          	addi	s1,s1,-278 # 800112b8 <wait_lock>
    800023d6:	8526                	mv	a0,s1
    800023d8:	ffffe097          	auipc	ra,0xffffe
    800023dc:	7ea080e7          	jalr	2026(ra) # 80000bc2 <acquire>
  reparent(p);
    800023e0:	854e                	mv	a0,s3
    800023e2:	00000097          	auipc	ra,0x0
    800023e6:	f1a080e7          	jalr	-230(ra) # 800022fc <reparent>
  wakeup(p->parent);
    800023ea:	0589b503          	ld	a0,88(s3)
    800023ee:	00000097          	auipc	ra,0x0
    800023f2:	e98080e7          	jalr	-360(ra) # 80002286 <wakeup>
  acquire(&p->lock);
    800023f6:	854e                	mv	a0,s3
    800023f8:	ffffe097          	auipc	ra,0xffffe
    800023fc:	7ca080e7          	jalr	1994(ra) # 80000bc2 <acquire>
  p->xstate = status;
    80002400:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002404:	4795                	li	a5,5
    80002406:	00f9ac23          	sw	a5,24(s3)
  p->ttime = ticks; //update termination time
    8000240a:	00007797          	auipc	a5,0x7
    8000240e:	c2e7a783          	lw	a5,-978(a5) # 80009038 <ticks>
    80002412:	02f9ae23          	sw	a5,60(s3)
  release(&wait_lock);
    80002416:	8526                	mv	a0,s1
    80002418:	fffff097          	auipc	ra,0xfffff
    8000241c:	85e080e7          	jalr	-1954(ra) # 80000c76 <release>
  sched();
    80002420:	00000097          	auipc	ra,0x0
    80002424:	ba8080e7          	jalr	-1112(ra) # 80001fc8 <sched>
  panic("zombie exit");
    80002428:	00006517          	auipc	a0,0x6
    8000242c:	e4050513          	addi	a0,a0,-448 # 80008268 <digits+0x228>
    80002430:	ffffe097          	auipc	ra,0xffffe
    80002434:	0fa080e7          	jalr	250(ra) # 8000052a <panic>

0000000080002438 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002438:	7179                	addi	sp,sp,-48
    8000243a:	f406                	sd	ra,40(sp)
    8000243c:	f022                	sd	s0,32(sp)
    8000243e:	ec26                	sd	s1,24(sp)
    80002440:	e84a                	sd	s2,16(sp)
    80002442:	e44e                	sd	s3,8(sp)
    80002444:	1800                	addi	s0,sp,48
    80002446:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002448:	0000f497          	auipc	s1,0xf
    8000244c:	2a048493          	addi	s1,s1,672 # 800116e8 <proc>
    80002450:	00015997          	auipc	s3,0x15
    80002454:	49898993          	addi	s3,s3,1176 # 800178e8 <tickslock>
    acquire(&p->lock);
    80002458:	8526                	mv	a0,s1
    8000245a:	ffffe097          	auipc	ra,0xffffe
    8000245e:	768080e7          	jalr	1896(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    80002462:	589c                	lw	a5,48(s1)
    80002464:	01278d63          	beq	a5,s2,8000247e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002468:	8526                	mv	a0,s1
    8000246a:	fffff097          	auipc	ra,0xfffff
    8000246e:	80c080e7          	jalr	-2036(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002472:	18848493          	addi	s1,s1,392
    80002476:	ff3491e3          	bne	s1,s3,80002458 <kill+0x20>
  }
  return -1;
    8000247a:	557d                	li	a0,-1
    8000247c:	a829                	j	80002496 <kill+0x5e>
      p->killed = 1;
    8000247e:	4785                	li	a5,1
    80002480:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002482:	4c98                	lw	a4,24(s1)
    80002484:	4789                	li	a5,2
    80002486:	00f70f63          	beq	a4,a5,800024a4 <kill+0x6c>
      release(&p->lock);
    8000248a:	8526                	mv	a0,s1
    8000248c:	ffffe097          	auipc	ra,0xffffe
    80002490:	7ea080e7          	jalr	2026(ra) # 80000c76 <release>
      return 0;
    80002494:	4501                	li	a0,0
}
    80002496:	70a2                	ld	ra,40(sp)
    80002498:	7402                	ld	s0,32(sp)
    8000249a:	64e2                	ld	s1,24(sp)
    8000249c:	6942                	ld	s2,16(sp)
    8000249e:	69a2                	ld	s3,8(sp)
    800024a0:	6145                	addi	sp,sp,48
    800024a2:	8082                	ret
        p->state = RUNNABLE;
    800024a4:	478d                	li	a5,3
    800024a6:	cc9c                	sw	a5,24(s1)
    800024a8:	b7cd                	j	8000248a <kill+0x52>

00000000800024aa <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024aa:	7179                	addi	sp,sp,-48
    800024ac:	f406                	sd	ra,40(sp)
    800024ae:	f022                	sd	s0,32(sp)
    800024b0:	ec26                	sd	s1,24(sp)
    800024b2:	e84a                	sd	s2,16(sp)
    800024b4:	e44e                	sd	s3,8(sp)
    800024b6:	e052                	sd	s4,0(sp)
    800024b8:	1800                	addi	s0,sp,48
    800024ba:	84aa                	mv	s1,a0
    800024bc:	892e                	mv	s2,a1
    800024be:	89b2                	mv	s3,a2
    800024c0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024c2:	fffff097          	auipc	ra,0xfffff
    800024c6:	4d4080e7          	jalr	1236(ra) # 80001996 <myproc>
  if(user_dst){
    800024ca:	c08d                	beqz	s1,800024ec <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024cc:	86d2                	mv	a3,s4
    800024ce:	864e                	mv	a2,s3
    800024d0:	85ca                	mv	a1,s2
    800024d2:	7928                	ld	a0,112(a0)
    800024d4:	fffff097          	auipc	ra,0xfffff
    800024d8:	16a080e7          	jalr	362(ra) # 8000163e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024dc:	70a2                	ld	ra,40(sp)
    800024de:	7402                	ld	s0,32(sp)
    800024e0:	64e2                	ld	s1,24(sp)
    800024e2:	6942                	ld	s2,16(sp)
    800024e4:	69a2                	ld	s3,8(sp)
    800024e6:	6a02                	ld	s4,0(sp)
    800024e8:	6145                	addi	sp,sp,48
    800024ea:	8082                	ret
    memmove((char *)dst, src, len);
    800024ec:	000a061b          	sext.w	a2,s4
    800024f0:	85ce                	mv	a1,s3
    800024f2:	854a                	mv	a0,s2
    800024f4:	fffff097          	auipc	ra,0xfffff
    800024f8:	826080e7          	jalr	-2010(ra) # 80000d1a <memmove>
    return 0;
    800024fc:	8526                	mv	a0,s1
    800024fe:	bff9                	j	800024dc <either_copyout+0x32>

0000000080002500 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002500:	7179                	addi	sp,sp,-48
    80002502:	f406                	sd	ra,40(sp)
    80002504:	f022                	sd	s0,32(sp)
    80002506:	ec26                	sd	s1,24(sp)
    80002508:	e84a                	sd	s2,16(sp)
    8000250a:	e44e                	sd	s3,8(sp)
    8000250c:	e052                	sd	s4,0(sp)
    8000250e:	1800                	addi	s0,sp,48
    80002510:	892a                	mv	s2,a0
    80002512:	84ae                	mv	s1,a1
    80002514:	89b2                	mv	s3,a2
    80002516:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002518:	fffff097          	auipc	ra,0xfffff
    8000251c:	47e080e7          	jalr	1150(ra) # 80001996 <myproc>
  if(user_src){
    80002520:	c08d                	beqz	s1,80002542 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002522:	86d2                	mv	a3,s4
    80002524:	864e                	mv	a2,s3
    80002526:	85ca                	mv	a1,s2
    80002528:	7928                	ld	a0,112(a0)
    8000252a:	fffff097          	auipc	ra,0xfffff
    8000252e:	1a0080e7          	jalr	416(ra) # 800016ca <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002532:	70a2                	ld	ra,40(sp)
    80002534:	7402                	ld	s0,32(sp)
    80002536:	64e2                	ld	s1,24(sp)
    80002538:	6942                	ld	s2,16(sp)
    8000253a:	69a2                	ld	s3,8(sp)
    8000253c:	6a02                	ld	s4,0(sp)
    8000253e:	6145                	addi	sp,sp,48
    80002540:	8082                	ret
    memmove(dst, (char*)src, len);
    80002542:	000a061b          	sext.w	a2,s4
    80002546:	85ce                	mv	a1,s3
    80002548:	854a                	mv	a0,s2
    8000254a:	ffffe097          	auipc	ra,0xffffe
    8000254e:	7d0080e7          	jalr	2000(ra) # 80000d1a <memmove>
    return 0;
    80002552:	8526                	mv	a0,s1
    80002554:	bff9                	j	80002532 <either_copyin+0x32>

0000000080002556 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002556:	715d                	addi	sp,sp,-80
    80002558:	e486                	sd	ra,72(sp)
    8000255a:	e0a2                	sd	s0,64(sp)
    8000255c:	fc26                	sd	s1,56(sp)
    8000255e:	f84a                	sd	s2,48(sp)
    80002560:	f44e                	sd	s3,40(sp)
    80002562:	f052                	sd	s4,32(sp)
    80002564:	ec56                	sd	s5,24(sp)
    80002566:	e85a                	sd	s6,16(sp)
    80002568:	e45e                	sd	s7,8(sp)
    8000256a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000256c:	00006517          	auipc	a0,0x6
    80002570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80002574:	ffffe097          	auipc	ra,0xffffe
    80002578:	000080e7          	jalr	ra # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000257c:	0000f497          	auipc	s1,0xf
    80002580:	2e448493          	addi	s1,s1,740 # 80011860 <proc+0x178>
    80002584:	00015917          	auipc	s2,0x15
    80002588:	4dc90913          	addi	s2,s2,1244 # 80017a60 <bcache+0x160>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000258c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000258e:	00006997          	auipc	s3,0x6
    80002592:	cea98993          	addi	s3,s3,-790 # 80008278 <digits+0x238>
    printf("%d %s %s", p->pid, state, p->name);
    80002596:	00006a97          	auipc	s5,0x6
    8000259a:	ceaa8a93          	addi	s5,s5,-790 # 80008280 <digits+0x240>
    printf("\n");
    8000259e:	00006a17          	auipc	s4,0x6
    800025a2:	b2aa0a13          	addi	s4,s4,-1238 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a6:	00006b97          	auipc	s7,0x6
    800025aa:	d12b8b93          	addi	s7,s7,-750 # 800082b8 <states.0>
    800025ae:	a00d                	j	800025d0 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025b0:	eb86a583          	lw	a1,-328(a3)
    800025b4:	8556                	mv	a0,s5
    800025b6:	ffffe097          	auipc	ra,0xffffe
    800025ba:	fbe080e7          	jalr	-66(ra) # 80000574 <printf>
    printf("\n");
    800025be:	8552                	mv	a0,s4
    800025c0:	ffffe097          	auipc	ra,0xffffe
    800025c4:	fb4080e7          	jalr	-76(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025c8:	18848493          	addi	s1,s1,392
    800025cc:	03248263          	beq	s1,s2,800025f0 <procdump+0x9a>
    if(p->state == UNUSED)
    800025d0:	86a6                	mv	a3,s1
    800025d2:	ea04a783          	lw	a5,-352(s1)
    800025d6:	dbed                	beqz	a5,800025c8 <procdump+0x72>
      state = "???";
    800025d8:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025da:	fcfb6be3          	bltu	s6,a5,800025b0 <procdump+0x5a>
    800025de:	02079713          	slli	a4,a5,0x20
    800025e2:	01d75793          	srli	a5,a4,0x1d
    800025e6:	97de                	add	a5,a5,s7
    800025e8:	6390                	ld	a2,0(a5)
    800025ea:	f279                	bnez	a2,800025b0 <procdump+0x5a>
      state = "???";
    800025ec:	864e                	mv	a2,s3
    800025ee:	b7c9                	j	800025b0 <procdump+0x5a>
  }
}
    800025f0:	60a6                	ld	ra,72(sp)
    800025f2:	6406                	ld	s0,64(sp)
    800025f4:	74e2                	ld	s1,56(sp)
    800025f6:	7942                	ld	s2,48(sp)
    800025f8:	79a2                	ld	s3,40(sp)
    800025fa:	7a02                	ld	s4,32(sp)
    800025fc:	6ae2                	ld	s5,24(sp)
    800025fe:	6b42                	ld	s6,16(sp)
    80002600:	6ba2                	ld	s7,8(sp)
    80002602:	6161                	addi	sp,sp,80
    80002604:	8082                	ret

0000000080002606 <trace>:

// Changes the Trace bit mask for proccess with input pid
// Trace mask determines which system calls will be traced
int
trace(int mask, int pid){
    80002606:	7179                	addi	sp,sp,-48
    80002608:	f406                	sd	ra,40(sp)
    8000260a:	f022                	sd	s0,32(sp)
    8000260c:	ec26                	sd	s1,24(sp)
    8000260e:	e84a                	sd	s2,16(sp)
    80002610:	e44e                	sd	s3,8(sp)
    80002612:	e052                	sd	s4,0(sp)
    80002614:	1800                	addi	s0,sp,48
    80002616:	8a2a                	mv	s4,a0
    80002618:	892e                	mv	s2,a1
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000261a:	0000f497          	auipc	s1,0xf
    8000261e:	0ce48493          	addi	s1,s1,206 # 800116e8 <proc>
    80002622:	00015997          	auipc	s3,0x15
    80002626:	2c698993          	addi	s3,s3,710 # 800178e8 <tickslock>
    acquire(&p->lock);
    8000262a:	8526                	mv	a0,s1
    8000262c:	ffffe097          	auipc	ra,0xffffe
    80002630:	596080e7          	jalr	1430(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    80002634:	589c                	lw	a5,48(s1)
    80002636:	01278d63          	beq	a5,s2,80002650 <trace+0x4a>
      p->tracemask = mask;
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000263a:	8526                	mv	a0,s1
    8000263c:	ffffe097          	auipc	ra,0xffffe
    80002640:	63a080e7          	jalr	1594(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002644:	18848493          	addi	s1,s1,392
    80002648:	ff3491e3          	bne	s1,s3,8000262a <trace+0x24>
  }
  return -1;
    8000264c:	557d                	li	a0,-1
    8000264e:	a809                	j	80002660 <trace+0x5a>
      p->tracemask = mask;
    80002650:	0344aa23          	sw	s4,52(s1)
      release(&p->lock);
    80002654:	8526                	mv	a0,s1
    80002656:	ffffe097          	auipc	ra,0xffffe
    8000265a:	620080e7          	jalr	1568(ra) # 80000c76 <release>
      return 0;
    8000265e:	4501                	li	a0,0
}
    80002660:	70a2                	ld	ra,40(sp)
    80002662:	7402                	ld	s0,32(sp)
    80002664:	64e2                	ld	s1,24(sp)
    80002666:	6942                	ld	s2,16(sp)
    80002668:	69a2                	ld	s3,8(sp)
    8000266a:	6a02                	ld	s4,0(sp)
    8000266c:	6145                	addi	sp,sp,48
    8000266e:	8082                	ret

0000000080002670 <wait_stat>:

int
wait_stat(uint64 stat_addr, uint64 perf_addr){// ass1 
    80002670:	7119                	addi	sp,sp,-128
    80002672:	fc86                	sd	ra,120(sp)
    80002674:	f8a2                	sd	s0,112(sp)
    80002676:	f4a6                	sd	s1,104(sp)
    80002678:	f0ca                	sd	s2,96(sp)
    8000267a:	ecce                	sd	s3,88(sp)
    8000267c:	e8d2                	sd	s4,80(sp)
    8000267e:	e4d6                	sd	s5,72(sp)
    80002680:	e0da                	sd	s6,64(sp)
    80002682:	fc5e                	sd	s7,56(sp)
    80002684:	f862                	sd	s8,48(sp)
    80002686:	f466                	sd	s9,40(sp)
    80002688:	0100                	addi	s0,sp,128
    8000268a:	8b2a                	mv	s6,a0
    8000268c:	8bae                	mv	s7,a1
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    8000268e:	fffff097          	auipc	ra,0xfffff
    80002692:	308080e7          	jalr	776(ra) # 80001996 <myproc>
    80002696:	892a                	mv	s2,a0
  struct perf child_perf;
  acquire(&wait_lock);
    80002698:	0000f517          	auipc	a0,0xf
    8000269c:	c2050513          	addi	a0,a0,-992 # 800112b8 <wait_lock>
    800026a0:	ffffe097          	auipc	ra,0xffffe
    800026a4:	522080e7          	jalr	1314(ra) # 80000bc2 <acquire>
  
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    800026a8:	4c01                	li	s8,0
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){ 
    800026aa:	4a15                	li	s4,5
        havekids = 1;
    800026ac:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800026ae:	00015997          	auipc	s3,0x15
    800026b2:	23a98993          	addi	s3,s3,570 # 800178e8 <tickslock>
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800026b6:	0000fc97          	auipc	s9,0xf
    800026ba:	c02c8c93          	addi	s9,s9,-1022 # 800112b8 <wait_lock>
    havekids = 0;
    800026be:	8762                	mv	a4,s8
    for(np = proc; np < &proc[NPROC]; np++){
    800026c0:	0000f497          	auipc	s1,0xf
    800026c4:	02848493          	addi	s1,s1,40 # 800116e8 <proc>
    800026c8:	a861                	j	80002760 <wait_stat+0xf0>
          pid = np->pid;
    800026ca:	0304a983          	lw	s3,48(s1)
          perfi(np, &child_perf);
    800026ce:	f8840593          	addi	a1,s0,-120
    800026d2:	8526                	mv	a0,s1
    800026d4:	fffff097          	auipc	ra,0xfffff
    800026d8:	6b4080e7          	jalr	1716(ra) # 80001d88 <perfi>
          if(stat_addr != 0 && perf_addr != 0 && 
    800026dc:	000b0463          	beqz	s6,800026e4 <wait_stat+0x74>
    800026e0:	020b9563          	bnez	s7,8000270a <wait_stat+0x9a>
          freeproc(np);
    800026e4:	8526                	mv	a0,s1
    800026e6:	fffff097          	auipc	ra,0xfffff
    800026ea:	462080e7          	jalr	1122(ra) # 80001b48 <freeproc>
          release(&np->lock);
    800026ee:	8526                	mv	a0,s1
    800026f0:	ffffe097          	auipc	ra,0xffffe
    800026f4:	586080e7          	jalr	1414(ra) # 80000c76 <release>
          release(&wait_lock);
    800026f8:	0000f517          	auipc	a0,0xf
    800026fc:	bc050513          	addi	a0,a0,-1088 # 800112b8 <wait_lock>
    80002700:	ffffe097          	auipc	ra,0xffffe
    80002704:	576080e7          	jalr	1398(ra) # 80000c76 <release>
          return pid;
    80002708:	a859                	j	8000279e <wait_stat+0x12e>
            ((copyout(p->pagetable, stat_addr, (char *)&np->xstate,sizeof(np->xstate)) < 0) ||
    8000270a:	4691                	li	a3,4
    8000270c:	02c48613          	addi	a2,s1,44
    80002710:	85da                	mv	a1,s6
    80002712:	07093503          	ld	a0,112(s2)
    80002716:	fffff097          	auipc	ra,0xfffff
    8000271a:	f28080e7          	jalr	-216(ra) # 8000163e <copyout>
          if(stat_addr != 0 && perf_addr != 0 && 
    8000271e:	00054e63          	bltz	a0,8000273a <wait_stat+0xca>
            (copyout(p->pagetable, perf_addr, (char *)&child_perf, sizeof(child_perf)) < 0))){
    80002722:	46e1                	li	a3,24
    80002724:	f8840613          	addi	a2,s0,-120
    80002728:	85de                	mv	a1,s7
    8000272a:	07093503          	ld	a0,112(s2)
    8000272e:	fffff097          	auipc	ra,0xfffff
    80002732:	f10080e7          	jalr	-240(ra) # 8000163e <copyout>
            ((copyout(p->pagetable, stat_addr, (char *)&np->xstate,sizeof(np->xstate)) < 0) ||
    80002736:	fa0557e3          	bgez	a0,800026e4 <wait_stat+0x74>
            release(&np->lock);
    8000273a:	8526                	mv	a0,s1
    8000273c:	ffffe097          	auipc	ra,0xffffe
    80002740:	53a080e7          	jalr	1338(ra) # 80000c76 <release>
            release(&wait_lock);
    80002744:	0000f517          	auipc	a0,0xf
    80002748:	b7450513          	addi	a0,a0,-1164 # 800112b8 <wait_lock>
    8000274c:	ffffe097          	auipc	ra,0xffffe
    80002750:	52a080e7          	jalr	1322(ra) # 80000c76 <release>
            return -1;
    80002754:	59fd                	li	s3,-1
    80002756:	a0a1                	j	8000279e <wait_stat+0x12e>
    for(np = proc; np < &proc[NPROC]; np++){
    80002758:	18848493          	addi	s1,s1,392
    8000275c:	03348463          	beq	s1,s3,80002784 <wait_stat+0x114>
      if(np->parent == p){
    80002760:	6cbc                	ld	a5,88(s1)
    80002762:	ff279be3          	bne	a5,s2,80002758 <wait_stat+0xe8>
        acquire(&np->lock);
    80002766:	8526                	mv	a0,s1
    80002768:	ffffe097          	auipc	ra,0xffffe
    8000276c:	45a080e7          	jalr	1114(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){ 
    80002770:	4c9c                	lw	a5,24(s1)
    80002772:	f5478ce3          	beq	a5,s4,800026ca <wait_stat+0x5a>
        release(&np->lock);
    80002776:	8526                	mv	a0,s1
    80002778:	ffffe097          	auipc	ra,0xffffe
    8000277c:	4fe080e7          	jalr	1278(ra) # 80000c76 <release>
        havekids = 1;
    80002780:	8756                	mv	a4,s5
    80002782:	bfd9                	j	80002758 <wait_stat+0xe8>
    if(!havekids || p->killed){
    80002784:	c701                	beqz	a4,8000278c <wait_stat+0x11c>
    80002786:	02892783          	lw	a5,40(s2)
    8000278a:	cb85                	beqz	a5,800027ba <wait_stat+0x14a>
      release(&wait_lock);
    8000278c:	0000f517          	auipc	a0,0xf
    80002790:	b2c50513          	addi	a0,a0,-1236 # 800112b8 <wait_lock>
    80002794:	ffffe097          	auipc	ra,0xffffe
    80002798:	4e2080e7          	jalr	1250(ra) # 80000c76 <release>
      return -1;
    8000279c:	59fd                	li	s3,-1
  }

}
    8000279e:	854e                	mv	a0,s3
    800027a0:	70e6                	ld	ra,120(sp)
    800027a2:	7446                	ld	s0,112(sp)
    800027a4:	74a6                	ld	s1,104(sp)
    800027a6:	7906                	ld	s2,96(sp)
    800027a8:	69e6                	ld	s3,88(sp)
    800027aa:	6a46                	ld	s4,80(sp)
    800027ac:	6aa6                	ld	s5,72(sp)
    800027ae:	6b06                	ld	s6,64(sp)
    800027b0:	7be2                	ld	s7,56(sp)
    800027b2:	7c42                	ld	s8,48(sp)
    800027b4:	7ca2                	ld	s9,40(sp)
    800027b6:	6109                	addi	sp,sp,128
    800027b8:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800027ba:	85e6                	mv	a1,s9
    800027bc:	854a                	mv	a0,s2
    800027be:	00000097          	auipc	ra,0x0
    800027c2:	93c080e7          	jalr	-1732(ra) # 800020fa <sleep>
    havekids = 0;
    800027c6:	bde5                	j	800026be <wait_stat+0x4e>

00000000800027c8 <update_times>:

void
update_times(){
    800027c8:	7139                	addi	sp,sp,-64
    800027ca:	fc06                	sd	ra,56(sp)
    800027cc:	f822                	sd	s0,48(sp)
    800027ce:	f426                	sd	s1,40(sp)
    800027d0:	f04a                	sd	s2,32(sp)
    800027d2:	ec4e                	sd	s3,24(sp)
    800027d4:	e852                	sd	s4,16(sp)
    800027d6:	e456                	sd	s5,8(sp)
    800027d8:	0080                	addi	s0,sp,64
    struct proc *np;
    acquire(&runtime_lock);
    800027da:	0000f497          	auipc	s1,0xf
    800027de:	af648493          	addi	s1,s1,-1290 # 800112d0 <runtime_lock>
    800027e2:	8526                	mv	a0,s1
    800027e4:	ffffe097          	auipc	ra,0xffffe
    800027e8:	3de080e7          	jalr	990(ra) # 80000bc2 <acquire>
    current_runtime++;
    800027ec:	00007717          	auipc	a4,0x7
    800027f0:	83c70713          	addi	a4,a4,-1988 # 80009028 <current_runtime>
    800027f4:	431c                	lw	a5,0(a4)
    800027f6:	2785                	addiw	a5,a5,1
    800027f8:	c31c                	sw	a5,0(a4)
    release(&runtime_lock);
    800027fa:	8526                	mv	a0,s1
    800027fc:	ffffe097          	auipc	ra,0xffffe
    80002800:	47a080e7          	jalr	1146(ra) # 80000c76 <release>

    for(np = proc; np < &proc[NPROC]; np++){
    80002804:	0000f497          	auipc	s1,0xf
    80002808:	ee448493          	addi	s1,s1,-284 # 800116e8 <proc>
      acquire(&np->lock);
      switch (np->state)
    8000280c:	4a8d                	li	s5,3
    8000280e:	4a11                	li	s4,4
    80002810:	4989                	li	s3,2
    for(np = proc; np < &proc[NPROC]; np++){
    80002812:	00015917          	auipc	s2,0x15
    80002816:	0d690913          	addi	s2,s2,214 # 800178e8 <tickslock>
    8000281a:	a829                	j	80002834 <update_times+0x6c>
      {
      case SLEEPING:
        np->stime++;
        break;
      case RUNNABLE:
        np->retime++;
    8000281c:	40fc                	lw	a5,68(s1)
    8000281e:	2785                	addiw	a5,a5,1
    80002820:	c0fc                	sw	a5,68(s1)
        np->rutime++;
        break;
      default:
        break;
      }
    release(&np->lock);
    80002822:	8526                	mv	a0,s1
    80002824:	ffffe097          	auipc	ra,0xffffe
    80002828:	452080e7          	jalr	1106(ra) # 80000c76 <release>
    for(np = proc; np < &proc[NPROC]; np++){
    8000282c:	18848493          	addi	s1,s1,392
    80002830:	03248663          	beq	s1,s2,8000285c <update_times+0x94>
      acquire(&np->lock);
    80002834:	8526                	mv	a0,s1
    80002836:	ffffe097          	auipc	ra,0xffffe
    8000283a:	38c080e7          	jalr	908(ra) # 80000bc2 <acquire>
      switch (np->state)
    8000283e:	4c9c                	lw	a5,24(s1)
    80002840:	fd578ee3          	beq	a5,s5,8000281c <update_times+0x54>
    80002844:	01478863          	beq	a5,s4,80002854 <update_times+0x8c>
    80002848:	fd379de3          	bne	a5,s3,80002822 <update_times+0x5a>
        np->stime++;
    8000284c:	40bc                	lw	a5,64(s1)
    8000284e:	2785                	addiw	a5,a5,1
    80002850:	c0bc                	sw	a5,64(s1)
        break;
    80002852:	bfc1                	j	80002822 <update_times+0x5a>
        np->rutime++;
    80002854:	44bc                	lw	a5,72(s1)
    80002856:	2785                	addiw	a5,a5,1
    80002858:	c4bc                	sw	a5,72(s1)
        break;
    8000285a:	b7e1                	j	80002822 <update_times+0x5a>
    //TODO (ofer) update burst time 
    } 
}
    8000285c:	70e2                	ld	ra,56(sp)
    8000285e:	7442                	ld	s0,48(sp)
    80002860:	74a2                	ld	s1,40(sp)
    80002862:	7902                	ld	s2,32(sp)
    80002864:	69e2                	ld	s3,24(sp)
    80002866:	6a42                	ld	s4,16(sp)
    80002868:	6aa2                	ld	s5,8(sp)
    8000286a:	6121                	addi	sp,sp,64
    8000286c:	8082                	ret

000000008000286e <set_priority>:

int
set_priority(int priority){
    8000286e:	7139                	addi	sp,sp,-64
    80002870:	fc06                	sd	ra,56(sp)
    80002872:	f822                	sd	s0,48(sp)
    80002874:	f426                	sd	s1,40(sp)
    80002876:	f04a                	sd	s2,32(sp)
    80002878:	0080                	addi	s0,sp,64
    8000287a:	84aa                	mv	s1,a0
  struct proc *p = myproc();   
    8000287c:	fffff097          	auipc	ra,0xfffff
    80002880:	11a080e7          	jalr	282(ra) # 80001996 <myproc>
  int priority_to_decay[5] = {1,3,5,7,25};
    80002884:	4785                	li	a5,1
    80002886:	fcf42423          	sw	a5,-56(s0)
    8000288a:	478d                	li	a5,3
    8000288c:	fcf42623          	sw	a5,-52(s0)
    80002890:	4795                	li	a5,5
    80002892:	fcf42823          	sw	a5,-48(s0)
    80002896:	479d                	li	a5,7
    80002898:	fcf42a23          	sw	a5,-44(s0)
    8000289c:	47e5                	li	a5,25
    8000289e:	fcf42c23          	sw	a5,-40(s0)

  if(priority < 1 || priority > 5)
    800028a2:	fff4871b          	addiw	a4,s1,-1
    800028a6:	4791                	li	a5,4
    800028a8:	02e7ec63          	bltu	a5,a4,800028e0 <set_priority+0x72>
    800028ac:	892a                	mv	s2,a0
    return -1;

  acquire(&p->lock);
    800028ae:	ffffe097          	auipc	ra,0xffffe
    800028b2:	314080e7          	jalr	788(ra) # 80000bc2 <acquire>
  p->decay_factor=priority_to_decay[priority-1];
    800028b6:	34fd                	addiw	s1,s1,-1
    800028b8:	048a                	slli	s1,s1,0x2
    800028ba:	fe040793          	addi	a5,s0,-32
    800028be:	94be                	add	s1,s1,a5
    800028c0:	fe84a783          	lw	a5,-24(s1)
    800028c4:	04f92823          	sw	a5,80(s2)
  release(&p->lock); 
    800028c8:	854a                	mv	a0,s2
    800028ca:	ffffe097          	auipc	ra,0xffffe
    800028ce:	3ac080e7          	jalr	940(ra) # 80000c76 <release>

  return 0;
    800028d2:	4501                	li	a0,0
}
    800028d4:	70e2                	ld	ra,56(sp)
    800028d6:	7442                	ld	s0,48(sp)
    800028d8:	74a2                	ld	s1,40(sp)
    800028da:	7902                	ld	s2,32(sp)
    800028dc:	6121                	addi	sp,sp,64
    800028de:	8082                	ret
    return -1;
    800028e0:	557d                	li	a0,-1
    800028e2:	bfcd                	j	800028d4 <set_priority+0x66>

00000000800028e4 <swtch>:
    800028e4:	00153023          	sd	ra,0(a0)
    800028e8:	00253423          	sd	sp,8(a0)
    800028ec:	e900                	sd	s0,16(a0)
    800028ee:	ed04                	sd	s1,24(a0)
    800028f0:	03253023          	sd	s2,32(a0)
    800028f4:	03353423          	sd	s3,40(a0)
    800028f8:	03453823          	sd	s4,48(a0)
    800028fc:	03553c23          	sd	s5,56(a0)
    80002900:	05653023          	sd	s6,64(a0)
    80002904:	05753423          	sd	s7,72(a0)
    80002908:	05853823          	sd	s8,80(a0)
    8000290c:	05953c23          	sd	s9,88(a0)
    80002910:	07a53023          	sd	s10,96(a0)
    80002914:	07b53423          	sd	s11,104(a0)
    80002918:	0005b083          	ld	ra,0(a1)
    8000291c:	0085b103          	ld	sp,8(a1)
    80002920:	6980                	ld	s0,16(a1)
    80002922:	6d84                	ld	s1,24(a1)
    80002924:	0205b903          	ld	s2,32(a1)
    80002928:	0285b983          	ld	s3,40(a1)
    8000292c:	0305ba03          	ld	s4,48(a1)
    80002930:	0385ba83          	ld	s5,56(a1)
    80002934:	0405bb03          	ld	s6,64(a1)
    80002938:	0485bb83          	ld	s7,72(a1)
    8000293c:	0505bc03          	ld	s8,80(a1)
    80002940:	0585bc83          	ld	s9,88(a1)
    80002944:	0605bd03          	ld	s10,96(a1)
    80002948:	0685bd83          	ld	s11,104(a1)
    8000294c:	8082                	ret

000000008000294e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000294e:	1141                	addi	sp,sp,-16
    80002950:	e406                	sd	ra,8(sp)
    80002952:	e022                	sd	s0,0(sp)
    80002954:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002956:	00006597          	auipc	a1,0x6
    8000295a:	99258593          	addi	a1,a1,-1646 # 800082e8 <states.0+0x30>
    8000295e:	00015517          	auipc	a0,0x15
    80002962:	f8a50513          	addi	a0,a0,-118 # 800178e8 <tickslock>
    80002966:	ffffe097          	auipc	ra,0xffffe
    8000296a:	1cc080e7          	jalr	460(ra) # 80000b32 <initlock>
}
    8000296e:	60a2                	ld	ra,8(sp)
    80002970:	6402                	ld	s0,0(sp)
    80002972:	0141                	addi	sp,sp,16
    80002974:	8082                	ret

0000000080002976 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002976:	1141                	addi	sp,sp,-16
    80002978:	e422                	sd	s0,8(sp)
    8000297a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000297c:	00003797          	auipc	a5,0x3
    80002980:	63478793          	addi	a5,a5,1588 # 80005fb0 <kernelvec>
    80002984:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002988:	6422                	ld	s0,8(sp)
    8000298a:	0141                	addi	sp,sp,16
    8000298c:	8082                	ret

000000008000298e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000298e:	1141                	addi	sp,sp,-16
    80002990:	e406                	sd	ra,8(sp)
    80002992:	e022                	sd	s0,0(sp)
    80002994:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002996:	fffff097          	auipc	ra,0xfffff
    8000299a:	000080e7          	jalr	ra # 80001996 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000299e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029a2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029a4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800029a8:	00004617          	auipc	a2,0x4
    800029ac:	65860613          	addi	a2,a2,1624 # 80007000 <_trampoline>
    800029b0:	00004697          	auipc	a3,0x4
    800029b4:	65068693          	addi	a3,a3,1616 # 80007000 <_trampoline>
    800029b8:	8e91                	sub	a3,a3,a2
    800029ba:	040007b7          	lui	a5,0x4000
    800029be:	17fd                	addi	a5,a5,-1
    800029c0:	07b2                	slli	a5,a5,0xc
    800029c2:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029c4:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029c8:	7d38                	ld	a4,120(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029ca:	180026f3          	csrr	a3,satp
    800029ce:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029d0:	7d38                	ld	a4,120(a0)
    800029d2:	7134                	ld	a3,96(a0)
    800029d4:	6585                	lui	a1,0x1
    800029d6:	96ae                	add	a3,a3,a1
    800029d8:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029da:	7d38                	ld	a4,120(a0)
    800029dc:	00000697          	auipc	a3,0x0
    800029e0:	14668693          	addi	a3,a3,326 # 80002b22 <usertrap>
    800029e4:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800029e6:	7d38                	ld	a4,120(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029e8:	8692                	mv	a3,tp
    800029ea:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029ec:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029f0:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029f4:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029f8:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800029fc:	7d38                	ld	a4,120(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029fe:	6f18                	ld	a4,24(a4)
    80002a00:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a04:	792c                	ld	a1,112(a0)
    80002a06:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002a08:	00004717          	auipc	a4,0x4
    80002a0c:	68870713          	addi	a4,a4,1672 # 80007090 <userret>
    80002a10:	8f11                	sub	a4,a4,a2
    80002a12:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002a14:	577d                	li	a4,-1
    80002a16:	177e                	slli	a4,a4,0x3f
    80002a18:	8dd9                	or	a1,a1,a4
    80002a1a:	02000537          	lui	a0,0x2000
    80002a1e:	157d                	addi	a0,a0,-1
    80002a20:	0536                	slli	a0,a0,0xd
    80002a22:	9782                	jalr	a5
}
    80002a24:	60a2                	ld	ra,8(sp)
    80002a26:	6402                	ld	s0,0(sp)
    80002a28:	0141                	addi	sp,sp,16
    80002a2a:	8082                	ret

0000000080002a2c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a2c:	1101                	addi	sp,sp,-32
    80002a2e:	ec06                	sd	ra,24(sp)
    80002a30:	e822                	sd	s0,16(sp)
    80002a32:	e426                	sd	s1,8(sp)
    80002a34:	e04a                	sd	s2,0(sp)
    80002a36:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a38:	00015917          	auipc	s2,0x15
    80002a3c:	eb090913          	addi	s2,s2,-336 # 800178e8 <tickslock>
    80002a40:	854a                	mv	a0,s2
    80002a42:	ffffe097          	auipc	ra,0xffffe
    80002a46:	180080e7          	jalr	384(ra) # 80000bc2 <acquire>
  ticks++;
    80002a4a:	00006497          	auipc	s1,0x6
    80002a4e:	5ee48493          	addi	s1,s1,1518 # 80009038 <ticks>
    80002a52:	409c                	lw	a5,0(s1)
    80002a54:	2785                	addiw	a5,a5,1
    80002a56:	c09c                	sw	a5,0(s1)
  update_times();
    80002a58:	00000097          	auipc	ra,0x0
    80002a5c:	d70080e7          	jalr	-656(ra) # 800027c8 <update_times>
  wakeup(&ticks);
    80002a60:	8526                	mv	a0,s1
    80002a62:	00000097          	auipc	ra,0x0
    80002a66:	824080e7          	jalr	-2012(ra) # 80002286 <wakeup>
  release(&tickslock);
    80002a6a:	854a                	mv	a0,s2
    80002a6c:	ffffe097          	auipc	ra,0xffffe
    80002a70:	20a080e7          	jalr	522(ra) # 80000c76 <release>
}
    80002a74:	60e2                	ld	ra,24(sp)
    80002a76:	6442                	ld	s0,16(sp)
    80002a78:	64a2                	ld	s1,8(sp)
    80002a7a:	6902                	ld	s2,0(sp)
    80002a7c:	6105                	addi	sp,sp,32
    80002a7e:	8082                	ret

0000000080002a80 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a80:	1101                	addi	sp,sp,-32
    80002a82:	ec06                	sd	ra,24(sp)
    80002a84:	e822                	sd	s0,16(sp)
    80002a86:	e426                	sd	s1,8(sp)
    80002a88:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a8a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002a8e:	00074d63          	bltz	a4,80002aa8 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002a92:	57fd                	li	a5,-1
    80002a94:	17fe                	slli	a5,a5,0x3f
    80002a96:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002a98:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a9a:	06f70363          	beq	a4,a5,80002b00 <devintr+0x80>
  }
}
    80002a9e:	60e2                	ld	ra,24(sp)
    80002aa0:	6442                	ld	s0,16(sp)
    80002aa2:	64a2                	ld	s1,8(sp)
    80002aa4:	6105                	addi	sp,sp,32
    80002aa6:	8082                	ret
     (scause & 0xff) == 9){
    80002aa8:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002aac:	46a5                	li	a3,9
    80002aae:	fed792e3          	bne	a5,a3,80002a92 <devintr+0x12>
    int irq = plic_claim();
    80002ab2:	00003097          	auipc	ra,0x3
    80002ab6:	606080e7          	jalr	1542(ra) # 800060b8 <plic_claim>
    80002aba:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002abc:	47a9                	li	a5,10
    80002abe:	02f50763          	beq	a0,a5,80002aec <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002ac2:	4785                	li	a5,1
    80002ac4:	02f50963          	beq	a0,a5,80002af6 <devintr+0x76>
    return 1;
    80002ac8:	4505                	li	a0,1
    } else if(irq){
    80002aca:	d8f1                	beqz	s1,80002a9e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002acc:	85a6                	mv	a1,s1
    80002ace:	00006517          	auipc	a0,0x6
    80002ad2:	82250513          	addi	a0,a0,-2014 # 800082f0 <states.0+0x38>
    80002ad6:	ffffe097          	auipc	ra,0xffffe
    80002ada:	a9e080e7          	jalr	-1378(ra) # 80000574 <printf>
      plic_complete(irq);
    80002ade:	8526                	mv	a0,s1
    80002ae0:	00003097          	auipc	ra,0x3
    80002ae4:	5fc080e7          	jalr	1532(ra) # 800060dc <plic_complete>
    return 1;
    80002ae8:	4505                	li	a0,1
    80002aea:	bf55                	j	80002a9e <devintr+0x1e>
      uartintr();
    80002aec:	ffffe097          	auipc	ra,0xffffe
    80002af0:	e9a080e7          	jalr	-358(ra) # 80000986 <uartintr>
    80002af4:	b7ed                	j	80002ade <devintr+0x5e>
      virtio_disk_intr();
    80002af6:	00004097          	auipc	ra,0x4
    80002afa:	a78080e7          	jalr	-1416(ra) # 8000656e <virtio_disk_intr>
    80002afe:	b7c5                	j	80002ade <devintr+0x5e>
    if(cpuid() == 0){
    80002b00:	fffff097          	auipc	ra,0xfffff
    80002b04:	e6a080e7          	jalr	-406(ra) # 8000196a <cpuid>
    80002b08:	c901                	beqz	a0,80002b18 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b0a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b0e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b10:	14479073          	csrw	sip,a5
    return 2;
    80002b14:	4509                	li	a0,2
    80002b16:	b761                	j	80002a9e <devintr+0x1e>
      clockintr();
    80002b18:	00000097          	auipc	ra,0x0
    80002b1c:	f14080e7          	jalr	-236(ra) # 80002a2c <clockintr>
    80002b20:	b7ed                	j	80002b0a <devintr+0x8a>

0000000080002b22 <usertrap>:
{
    80002b22:	1101                	addi	sp,sp,-32
    80002b24:	ec06                	sd	ra,24(sp)
    80002b26:	e822                	sd	s0,16(sp)
    80002b28:	e426                	sd	s1,8(sp)
    80002b2a:	e04a                	sd	s2,0(sp)
    80002b2c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b2e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b32:	1007f793          	andi	a5,a5,256
    80002b36:	e3ad                	bnez	a5,80002b98 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b38:	00003797          	auipc	a5,0x3
    80002b3c:	47878793          	addi	a5,a5,1144 # 80005fb0 <kernelvec>
    80002b40:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b44:	fffff097          	auipc	ra,0xfffff
    80002b48:	e52080e7          	jalr	-430(ra) # 80001996 <myproc>
    80002b4c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b4e:	7d3c                	ld	a5,120(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b50:	14102773          	csrr	a4,sepc
    80002b54:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b56:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b5a:	47a1                	li	a5,8
    80002b5c:	04f71c63          	bne	a4,a5,80002bb4 <usertrap+0x92>
    if(p->killed)
    80002b60:	551c                	lw	a5,40(a0)
    80002b62:	e3b9                	bnez	a5,80002ba8 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002b64:	7cb8                	ld	a4,120(s1)
    80002b66:	6f1c                	ld	a5,24(a4)
    80002b68:	0791                	addi	a5,a5,4
    80002b6a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b6c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b70:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b74:	10079073          	csrw	sstatus,a5
    syscall();
    80002b78:	00000097          	auipc	ra,0x0
    80002b7c:	364080e7          	jalr	868(ra) # 80002edc <syscall>
  if(p->killed)
    80002b80:	549c                	lw	a5,40(s1)
    80002b82:	ebc1                	bnez	a5,80002c12 <usertrap+0xf0>
  usertrapret();
    80002b84:	00000097          	auipc	ra,0x0
    80002b88:	e0a080e7          	jalr	-502(ra) # 8000298e <usertrapret>
}
    80002b8c:	60e2                	ld	ra,24(sp)
    80002b8e:	6442                	ld	s0,16(sp)
    80002b90:	64a2                	ld	s1,8(sp)
    80002b92:	6902                	ld	s2,0(sp)
    80002b94:	6105                	addi	sp,sp,32
    80002b96:	8082                	ret
    panic("usertrap: not from user mode");
    80002b98:	00005517          	auipc	a0,0x5
    80002b9c:	77850513          	addi	a0,a0,1912 # 80008310 <states.0+0x58>
    80002ba0:	ffffe097          	auipc	ra,0xffffe
    80002ba4:	98a080e7          	jalr	-1654(ra) # 8000052a <panic>
      exit(-1);
    80002ba8:	557d                	li	a0,-1
    80002baa:	fffff097          	auipc	ra,0xfffff
    80002bae:	7ac080e7          	jalr	1964(ra) # 80002356 <exit>
    80002bb2:	bf4d                	j	80002b64 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002bb4:	00000097          	auipc	ra,0x0
    80002bb8:	ecc080e7          	jalr	-308(ra) # 80002a80 <devintr>
    80002bbc:	892a                	mv	s2,a0
    80002bbe:	c501                	beqz	a0,80002bc6 <usertrap+0xa4>
  if(p->killed)
    80002bc0:	549c                	lw	a5,40(s1)
    80002bc2:	c3a1                	beqz	a5,80002c02 <usertrap+0xe0>
    80002bc4:	a815                	j	80002bf8 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bc6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002bca:	5890                	lw	a2,48(s1)
    80002bcc:	00005517          	auipc	a0,0x5
    80002bd0:	76450513          	addi	a0,a0,1892 # 80008330 <states.0+0x78>
    80002bd4:	ffffe097          	auipc	ra,0xffffe
    80002bd8:	9a0080e7          	jalr	-1632(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bdc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002be0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002be4:	00005517          	auipc	a0,0x5
    80002be8:	77c50513          	addi	a0,a0,1916 # 80008360 <states.0+0xa8>
    80002bec:	ffffe097          	auipc	ra,0xffffe
    80002bf0:	988080e7          	jalr	-1656(ra) # 80000574 <printf>
    p->killed = 1;
    80002bf4:	4785                	li	a5,1
    80002bf6:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002bf8:	557d                	li	a0,-1
    80002bfa:	fffff097          	auipc	ra,0xfffff
    80002bfe:	75c080e7          	jalr	1884(ra) # 80002356 <exit>
  if(which_dev == 2)
    80002c02:	4789                	li	a5,2
    80002c04:	f8f910e3          	bne	s2,a5,80002b84 <usertrap+0x62>
    yield();
    80002c08:	fffff097          	auipc	ra,0xfffff
    80002c0c:	4b6080e7          	jalr	1206(ra) # 800020be <yield>
    80002c10:	bf95                	j	80002b84 <usertrap+0x62>
  int which_dev = 0;
    80002c12:	4901                	li	s2,0
    80002c14:	b7d5                	j	80002bf8 <usertrap+0xd6>

0000000080002c16 <kerneltrap>:
{
    80002c16:	7179                	addi	sp,sp,-48
    80002c18:	f406                	sd	ra,40(sp)
    80002c1a:	f022                	sd	s0,32(sp)
    80002c1c:	ec26                	sd	s1,24(sp)
    80002c1e:	e84a                	sd	s2,16(sp)
    80002c20:	e44e                	sd	s3,8(sp)
    80002c22:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c24:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c28:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c2c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c30:	1004f793          	andi	a5,s1,256
    80002c34:	cb85                	beqz	a5,80002c64 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c3a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c3c:	ef85                	bnez	a5,80002c74 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c3e:	00000097          	auipc	ra,0x0
    80002c42:	e42080e7          	jalr	-446(ra) # 80002a80 <devintr>
    80002c46:	cd1d                	beqz	a0,80002c84 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING && current_runtime >= QUANTUM)
    80002c48:	4789                	li	a5,2
    80002c4a:	06f50a63          	beq	a0,a5,80002cbe <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c4e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c52:	10049073          	csrw	sstatus,s1
}
    80002c56:	70a2                	ld	ra,40(sp)
    80002c58:	7402                	ld	s0,32(sp)
    80002c5a:	64e2                	ld	s1,24(sp)
    80002c5c:	6942                	ld	s2,16(sp)
    80002c5e:	69a2                	ld	s3,8(sp)
    80002c60:	6145                	addi	sp,sp,48
    80002c62:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c64:	00005517          	auipc	a0,0x5
    80002c68:	71c50513          	addi	a0,a0,1820 # 80008380 <states.0+0xc8>
    80002c6c:	ffffe097          	auipc	ra,0xffffe
    80002c70:	8be080e7          	jalr	-1858(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80002c74:	00005517          	auipc	a0,0x5
    80002c78:	73450513          	addi	a0,a0,1844 # 800083a8 <states.0+0xf0>
    80002c7c:	ffffe097          	auipc	ra,0xffffe
    80002c80:	8ae080e7          	jalr	-1874(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80002c84:	85ce                	mv	a1,s3
    80002c86:	00005517          	auipc	a0,0x5
    80002c8a:	74250513          	addi	a0,a0,1858 # 800083c8 <states.0+0x110>
    80002c8e:	ffffe097          	auipc	ra,0xffffe
    80002c92:	8e6080e7          	jalr	-1818(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c96:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c9a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c9e:	00005517          	auipc	a0,0x5
    80002ca2:	73a50513          	addi	a0,a0,1850 # 800083d8 <states.0+0x120>
    80002ca6:	ffffe097          	auipc	ra,0xffffe
    80002caa:	8ce080e7          	jalr	-1842(ra) # 80000574 <printf>
    panic("kerneltrap");
    80002cae:	00005517          	auipc	a0,0x5
    80002cb2:	74250513          	addi	a0,a0,1858 # 800083f0 <states.0+0x138>
    80002cb6:	ffffe097          	auipc	ra,0xffffe
    80002cba:	874080e7          	jalr	-1932(ra) # 8000052a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING && current_runtime >= QUANTUM)
    80002cbe:	fffff097          	auipc	ra,0xfffff
    80002cc2:	cd8080e7          	jalr	-808(ra) # 80001996 <myproc>
    80002cc6:	d541                	beqz	a0,80002c4e <kerneltrap+0x38>
    80002cc8:	fffff097          	auipc	ra,0xfffff
    80002ccc:	cce080e7          	jalr	-818(ra) # 80001996 <myproc>
    80002cd0:	4d18                	lw	a4,24(a0)
    80002cd2:	4791                	li	a5,4
    80002cd4:	f6f71de3          	bne	a4,a5,80002c4e <kerneltrap+0x38>
    80002cd8:	00006717          	auipc	a4,0x6
    80002cdc:	35072703          	lw	a4,848(a4) # 80009028 <current_runtime>
    80002ce0:	f6e7d7e3          	bge	a5,a4,80002c4e <kerneltrap+0x38>
    yield();
    80002ce4:	fffff097          	auipc	ra,0xfffff
    80002ce8:	3da080e7          	jalr	986(ra) # 800020be <yield>
    80002cec:	b78d                	j	80002c4e <kerneltrap+0x38>

0000000080002cee <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cee:	1101                	addi	sp,sp,-32
    80002cf0:	ec06                	sd	ra,24(sp)
    80002cf2:	e822                	sd	s0,16(sp)
    80002cf4:	e426                	sd	s1,8(sp)
    80002cf6:	1000                	addi	s0,sp,32
    80002cf8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002cfa:	fffff097          	auipc	ra,0xfffff
    80002cfe:	c9c080e7          	jalr	-868(ra) # 80001996 <myproc>
  switch (n) {
    80002d02:	4795                	li	a5,5
    80002d04:	0497e163          	bltu	a5,s1,80002d46 <argraw+0x58>
    80002d08:	048a                	slli	s1,s1,0x2
    80002d0a:	00006717          	auipc	a4,0x6
    80002d0e:	83e70713          	addi	a4,a4,-1986 # 80008548 <states.0+0x290>
    80002d12:	94ba                	add	s1,s1,a4
    80002d14:	409c                	lw	a5,0(s1)
    80002d16:	97ba                	add	a5,a5,a4
    80002d18:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d1a:	7d3c                	ld	a5,120(a0)
    80002d1c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d1e:	60e2                	ld	ra,24(sp)
    80002d20:	6442                	ld	s0,16(sp)
    80002d22:	64a2                	ld	s1,8(sp)
    80002d24:	6105                	addi	sp,sp,32
    80002d26:	8082                	ret
    return p->trapframe->a1;
    80002d28:	7d3c                	ld	a5,120(a0)
    80002d2a:	7fa8                	ld	a0,120(a5)
    80002d2c:	bfcd                	j	80002d1e <argraw+0x30>
    return p->trapframe->a2;
    80002d2e:	7d3c                	ld	a5,120(a0)
    80002d30:	63c8                	ld	a0,128(a5)
    80002d32:	b7f5                	j	80002d1e <argraw+0x30>
    return p->trapframe->a3;
    80002d34:	7d3c                	ld	a5,120(a0)
    80002d36:	67c8                	ld	a0,136(a5)
    80002d38:	b7dd                	j	80002d1e <argraw+0x30>
    return p->trapframe->a4;
    80002d3a:	7d3c                	ld	a5,120(a0)
    80002d3c:	6bc8                	ld	a0,144(a5)
    80002d3e:	b7c5                	j	80002d1e <argraw+0x30>
    return p->trapframe->a5;
    80002d40:	7d3c                	ld	a5,120(a0)
    80002d42:	6fc8                	ld	a0,152(a5)
    80002d44:	bfe9                	j	80002d1e <argraw+0x30>
  panic("argraw");
    80002d46:	00005517          	auipc	a0,0x5
    80002d4a:	6ba50513          	addi	a0,a0,1722 # 80008400 <states.0+0x148>
    80002d4e:	ffffd097          	auipc	ra,0xffffd
    80002d52:	7dc080e7          	jalr	2012(ra) # 8000052a <panic>

0000000080002d56 <fetchaddr>:
{
    80002d56:	1101                	addi	sp,sp,-32
    80002d58:	ec06                	sd	ra,24(sp)
    80002d5a:	e822                	sd	s0,16(sp)
    80002d5c:	e426                	sd	s1,8(sp)
    80002d5e:	e04a                	sd	s2,0(sp)
    80002d60:	1000                	addi	s0,sp,32
    80002d62:	84aa                	mv	s1,a0
    80002d64:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d66:	fffff097          	auipc	ra,0xfffff
    80002d6a:	c30080e7          	jalr	-976(ra) # 80001996 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002d6e:	753c                	ld	a5,104(a0)
    80002d70:	02f4f863          	bgeu	s1,a5,80002da0 <fetchaddr+0x4a>
    80002d74:	00848713          	addi	a4,s1,8
    80002d78:	02e7e663          	bltu	a5,a4,80002da4 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d7c:	46a1                	li	a3,8
    80002d7e:	8626                	mv	a2,s1
    80002d80:	85ca                	mv	a1,s2
    80002d82:	7928                	ld	a0,112(a0)
    80002d84:	fffff097          	auipc	ra,0xfffff
    80002d88:	946080e7          	jalr	-1722(ra) # 800016ca <copyin>
    80002d8c:	00a03533          	snez	a0,a0
    80002d90:	40a00533          	neg	a0,a0
}
    80002d94:	60e2                	ld	ra,24(sp)
    80002d96:	6442                	ld	s0,16(sp)
    80002d98:	64a2                	ld	s1,8(sp)
    80002d9a:	6902                	ld	s2,0(sp)
    80002d9c:	6105                	addi	sp,sp,32
    80002d9e:	8082                	ret
    return -1;
    80002da0:	557d                	li	a0,-1
    80002da2:	bfcd                	j	80002d94 <fetchaddr+0x3e>
    80002da4:	557d                	li	a0,-1
    80002da6:	b7fd                	j	80002d94 <fetchaddr+0x3e>

0000000080002da8 <fetchstr>:
{
    80002da8:	7179                	addi	sp,sp,-48
    80002daa:	f406                	sd	ra,40(sp)
    80002dac:	f022                	sd	s0,32(sp)
    80002dae:	ec26                	sd	s1,24(sp)
    80002db0:	e84a                	sd	s2,16(sp)
    80002db2:	e44e                	sd	s3,8(sp)
    80002db4:	1800                	addi	s0,sp,48
    80002db6:	892a                	mv	s2,a0
    80002db8:	84ae                	mv	s1,a1
    80002dba:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002dbc:	fffff097          	auipc	ra,0xfffff
    80002dc0:	bda080e7          	jalr	-1062(ra) # 80001996 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002dc4:	86ce                	mv	a3,s3
    80002dc6:	864a                	mv	a2,s2
    80002dc8:	85a6                	mv	a1,s1
    80002dca:	7928                	ld	a0,112(a0)
    80002dcc:	fffff097          	auipc	ra,0xfffff
    80002dd0:	98c080e7          	jalr	-1652(ra) # 80001758 <copyinstr>
  if(err < 0)
    80002dd4:	00054763          	bltz	a0,80002de2 <fetchstr+0x3a>
  return strlen(buf);
    80002dd8:	8526                	mv	a0,s1
    80002dda:	ffffe097          	auipc	ra,0xffffe
    80002dde:	068080e7          	jalr	104(ra) # 80000e42 <strlen>
}
    80002de2:	70a2                	ld	ra,40(sp)
    80002de4:	7402                	ld	s0,32(sp)
    80002de6:	64e2                	ld	s1,24(sp)
    80002de8:	6942                	ld	s2,16(sp)
    80002dea:	69a2                	ld	s3,8(sp)
    80002dec:	6145                	addi	sp,sp,48
    80002dee:	8082                	ret

0000000080002df0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002df0:	1101                	addi	sp,sp,-32
    80002df2:	ec06                	sd	ra,24(sp)
    80002df4:	e822                	sd	s0,16(sp)
    80002df6:	e426                	sd	s1,8(sp)
    80002df8:	1000                	addi	s0,sp,32
    80002dfa:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dfc:	00000097          	auipc	ra,0x0
    80002e00:	ef2080e7          	jalr	-270(ra) # 80002cee <argraw>
    80002e04:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e06:	4501                	li	a0,0
    80002e08:	60e2                	ld	ra,24(sp)
    80002e0a:	6442                	ld	s0,16(sp)
    80002e0c:	64a2                	ld	s1,8(sp)
    80002e0e:	6105                	addi	sp,sp,32
    80002e10:	8082                	ret

0000000080002e12 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002e12:	1101                	addi	sp,sp,-32
    80002e14:	ec06                	sd	ra,24(sp)
    80002e16:	e822                	sd	s0,16(sp)
    80002e18:	e426                	sd	s1,8(sp)
    80002e1a:	1000                	addi	s0,sp,32
    80002e1c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e1e:	00000097          	auipc	ra,0x0
    80002e22:	ed0080e7          	jalr	-304(ra) # 80002cee <argraw>
    80002e26:	e088                	sd	a0,0(s1)
  return 0;
}
    80002e28:	4501                	li	a0,0
    80002e2a:	60e2                	ld	ra,24(sp)
    80002e2c:	6442                	ld	s0,16(sp)
    80002e2e:	64a2                	ld	s1,8(sp)
    80002e30:	6105                	addi	sp,sp,32
    80002e32:	8082                	ret

0000000080002e34 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e34:	1101                	addi	sp,sp,-32
    80002e36:	ec06                	sd	ra,24(sp)
    80002e38:	e822                	sd	s0,16(sp)
    80002e3a:	e426                	sd	s1,8(sp)
    80002e3c:	e04a                	sd	s2,0(sp)
    80002e3e:	1000                	addi	s0,sp,32
    80002e40:	84ae                	mv	s1,a1
    80002e42:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002e44:	00000097          	auipc	ra,0x0
    80002e48:	eaa080e7          	jalr	-342(ra) # 80002cee <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002e4c:	864a                	mv	a2,s2
    80002e4e:	85a6                	mv	a1,s1
    80002e50:	00000097          	auipc	ra,0x0
    80002e54:	f58080e7          	jalr	-168(ra) # 80002da8 <fetchstr>
}
    80002e58:	60e2                	ld	ra,24(sp)
    80002e5a:	6442                	ld	s0,16(sp)
    80002e5c:	64a2                	ld	s1,8(sp)
    80002e5e:	6902                	ld	s2,0(sp)
    80002e60:	6105                	addi	sp,sp,32
    80002e62:	8082                	ret

0000000080002e64 <printtrace>:
[SYS_set_priority] "set_priority",
};


int 
printtrace(int syscallnum,int pid, uint64 ret, int arg){
    80002e64:	1141                	addi	sp,sp,-16
    80002e66:	e406                	sd	ra,8(sp)
    80002e68:	e022                	sd	s0,0(sp)
    80002e6a:	0800                	addi	s0,sp,16
  if(syscallnum == SYS_fork){
    80002e6c:	4785                	li	a5,1
    80002e6e:	02f50d63          	beq	a0,a5,80002ea8 <printtrace+0x44>
    printf("%d: syscall fork NULL -> %d\n",pid,ret);
  }
  else if(syscallnum == SYS_kill || syscallnum == SYS_sbrk){  
    80002e72:	4799                	li	a5,6
    80002e74:	00f50563          	beq	a0,a5,80002e7e <printtrace+0x1a>
    80002e78:	47b1                	li	a5,12
    80002e7a:	04f51063          	bne	a0,a5,80002eba <printtrace+0x56>
    printf("%d: syscall %s %d -> %d\n",pid,syscallnames[syscallnum], arg, ret);
    80002e7e:	050e                	slli	a0,a0,0x3
    80002e80:	00005797          	auipc	a5,0x5
    80002e84:	6e078793          	addi	a5,a5,1760 # 80008560 <syscallnames>
    80002e88:	953e                	add	a0,a0,a5
    80002e8a:	8732                	mv	a4,a2
    80002e8c:	6110                	ld	a2,0(a0)
    80002e8e:	00005517          	auipc	a0,0x5
    80002e92:	59a50513          	addi	a0,a0,1434 # 80008428 <states.0+0x170>
    80002e96:	ffffd097          	auipc	ra,0xffffd
    80002e9a:	6de080e7          	jalr	1758(ra) # 80000574 <printf>
  }
  else{
    printf("%d: syscall %s -> %d\n",pid,syscallnames[syscallnum],ret);
  }
  return 0;   
}
    80002e9e:	4501                	li	a0,0
    80002ea0:	60a2                	ld	ra,8(sp)
    80002ea2:	6402                	ld	s0,0(sp)
    80002ea4:	0141                	addi	sp,sp,16
    80002ea6:	8082                	ret
    printf("%d: syscall fork NULL -> %d\n",pid,ret);
    80002ea8:	00005517          	auipc	a0,0x5
    80002eac:	56050513          	addi	a0,a0,1376 # 80008408 <states.0+0x150>
    80002eb0:	ffffd097          	auipc	ra,0xffffd
    80002eb4:	6c4080e7          	jalr	1732(ra) # 80000574 <printf>
    80002eb8:	b7dd                	j	80002e9e <printtrace+0x3a>
    printf("%d: syscall %s -> %d\n",pid,syscallnames[syscallnum],ret);
    80002eba:	050e                	slli	a0,a0,0x3
    80002ebc:	00005797          	auipc	a5,0x5
    80002ec0:	6a478793          	addi	a5,a5,1700 # 80008560 <syscallnames>
    80002ec4:	953e                	add	a0,a0,a5
    80002ec6:	86b2                	mv	a3,a2
    80002ec8:	6110                	ld	a2,0(a0)
    80002eca:	00005517          	auipc	a0,0x5
    80002ece:	57e50513          	addi	a0,a0,1406 # 80008448 <states.0+0x190>
    80002ed2:	ffffd097          	auipc	ra,0xffffd
    80002ed6:	6a2080e7          	jalr	1698(ra) # 80000574 <printf>
    80002eda:	b7d1                	j	80002e9e <printtrace+0x3a>

0000000080002edc <syscall>:


void
syscall(void)
{
    80002edc:	715d                	addi	sp,sp,-80
    80002ede:	e486                	sd	ra,72(sp)
    80002ee0:	e0a2                	sd	s0,64(sp)
    80002ee2:	fc26                	sd	s1,56(sp)
    80002ee4:	f84a                	sd	s2,48(sp)
    80002ee6:	f44e                	sd	s3,40(sp)
    80002ee8:	f052                	sd	s4,32(sp)
    80002eea:	ec56                	sd	s5,24(sp)
    80002eec:	0880                	addi	s0,sp,80
  int num;
  struct proc *p = myproc();
    80002eee:	fffff097          	auipc	ra,0xfffff
    80002ef2:	aa8080e7          	jalr	-1368(ra) # 80001996 <myproc>
    80002ef6:	84aa                	mv	s1,a0
  int tracemask = p->tracemask;

  num = p->trapframe->a7;
    80002ef8:	7d3c                	ld	a5,120(a0)
    80002efa:	77dc                	ld	a5,168(a5)
    80002efc:	0007891b          	sext.w	s2,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f00:	37fd                	addiw	a5,a5,-1
    80002f02:	475d                	li	a4,23
    80002f04:	04f76c63          	bltu	a4,a5,80002f5c <syscall+0x80>
    80002f08:	00391713          	slli	a4,s2,0x3
    80002f0c:	00005797          	auipc	a5,0x5
    80002f10:	65478793          	addi	a5,a5,1620 # 80008560 <syscallnames>
    80002f14:	97ba                	add	a5,a5,a4
    80002f16:	0c87ba03          	ld	s4,200(a5)
    80002f1a:	040a0163          	beqz	s4,80002f5c <syscall+0x80>
  int tracemask = p->tracemask;
    80002f1e:	03452983          	lw	s3,52(a0)
    int arg;
    argint(0, &arg);
    80002f22:	fbc40593          	addi	a1,s0,-68
    80002f26:	4501                	li	a0,0
    80002f28:	00000097          	auipc	ra,0x0
    80002f2c:	ec8080e7          	jalr	-312(ra) # 80002df0 <argint>

    p->trapframe->a0 = syscalls[num]();
    80002f30:	0784ba83          	ld	s5,120(s1)
    80002f34:	9a02                	jalr	s4
    80002f36:	06aab823          	sd	a0,112(s5)

    if(tracemask & (1<<num)){
    80002f3a:	4129d9bb          	sraw	s3,s3,s2
    80002f3e:	0019f993          	andi	s3,s3,1
    80002f42:	02098c63          	beqz	s3,80002f7a <syscall+0x9e>
      printtrace(num,p->pid,p->trapframe->a0,arg);
    80002f46:	7cbc                	ld	a5,120(s1)
    80002f48:	fbc42683          	lw	a3,-68(s0)
    80002f4c:	7bb0                	ld	a2,112(a5)
    80002f4e:	588c                	lw	a1,48(s1)
    80002f50:	854a                	mv	a0,s2
    80002f52:	00000097          	auipc	ra,0x0
    80002f56:	f12080e7          	jalr	-238(ra) # 80002e64 <printtrace>
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f5a:	a005                	j	80002f7a <syscall+0x9e>
    }
    
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f5c:	86ca                	mv	a3,s2
    80002f5e:	17848613          	addi	a2,s1,376
    80002f62:	588c                	lw	a1,48(s1)
    80002f64:	00005517          	auipc	a0,0x5
    80002f68:	4fc50513          	addi	a0,a0,1276 # 80008460 <states.0+0x1a8>
    80002f6c:	ffffd097          	auipc	ra,0xffffd
    80002f70:	608080e7          	jalr	1544(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f74:	7cbc                	ld	a5,120(s1)
    80002f76:	577d                	li	a4,-1
    80002f78:	fbb8                	sd	a4,112(a5)
  }
}
    80002f7a:	60a6                	ld	ra,72(sp)
    80002f7c:	6406                	ld	s0,64(sp)
    80002f7e:	74e2                	ld	s1,56(sp)
    80002f80:	7942                	ld	s2,48(sp)
    80002f82:	79a2                	ld	s3,40(sp)
    80002f84:	7a02                	ld	s4,32(sp)
    80002f86:	6ae2                	ld	s5,24(sp)
    80002f88:	6161                	addi	sp,sp,80
    80002f8a:	8082                	ret

0000000080002f8c <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f8c:	1101                	addi	sp,sp,-32
    80002f8e:	ec06                	sd	ra,24(sp)
    80002f90:	e822                	sd	s0,16(sp)
    80002f92:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002f94:	fec40593          	addi	a1,s0,-20
    80002f98:	4501                	li	a0,0
    80002f9a:	00000097          	auipc	ra,0x0
    80002f9e:	e56080e7          	jalr	-426(ra) # 80002df0 <argint>
    return -1;
    80002fa2:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002fa4:	00054963          	bltz	a0,80002fb6 <sys_exit+0x2a>
  exit(n);
    80002fa8:	fec42503          	lw	a0,-20(s0)
    80002fac:	fffff097          	auipc	ra,0xfffff
    80002fb0:	3aa080e7          	jalr	938(ra) # 80002356 <exit>
  return 0;  // not reached
    80002fb4:	4781                	li	a5,0
}
    80002fb6:	853e                	mv	a0,a5
    80002fb8:	60e2                	ld	ra,24(sp)
    80002fba:	6442                	ld	s0,16(sp)
    80002fbc:	6105                	addi	sp,sp,32
    80002fbe:	8082                	ret

0000000080002fc0 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002fc0:	1141                	addi	sp,sp,-16
    80002fc2:	e406                	sd	ra,8(sp)
    80002fc4:	e022                	sd	s0,0(sp)
    80002fc6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002fc8:	fffff097          	auipc	ra,0xfffff
    80002fcc:	9ce080e7          	jalr	-1586(ra) # 80001996 <myproc>
}
    80002fd0:	5908                	lw	a0,48(a0)
    80002fd2:	60a2                	ld	ra,8(sp)
    80002fd4:	6402                	ld	s0,0(sp)
    80002fd6:	0141                	addi	sp,sp,16
    80002fd8:	8082                	ret

0000000080002fda <sys_fork>:

uint64
sys_fork(void)
{
    80002fda:	1141                	addi	sp,sp,-16
    80002fdc:	e406                	sd	ra,8(sp)
    80002fde:	e022                	sd	s0,0(sp)
    80002fe0:	0800                	addi	s0,sp,16
  return fork();
    80002fe2:	fffff097          	auipc	ra,0xfffff
    80002fe6:	dca080e7          	jalr	-566(ra) # 80001dac <fork>
}
    80002fea:	60a2                	ld	ra,8(sp)
    80002fec:	6402                	ld	s0,0(sp)
    80002fee:	0141                	addi	sp,sp,16
    80002ff0:	8082                	ret

0000000080002ff2 <sys_wait>:

uint64
sys_wait(void)
{
    80002ff2:	1101                	addi	sp,sp,-32
    80002ff4:	ec06                	sd	ra,24(sp)
    80002ff6:	e822                	sd	s0,16(sp)
    80002ff8:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002ffa:	fe840593          	addi	a1,s0,-24
    80002ffe:	4501                	li	a0,0
    80003000:	00000097          	auipc	ra,0x0
    80003004:	e12080e7          	jalr	-494(ra) # 80002e12 <argaddr>
    80003008:	87aa                	mv	a5,a0
    return -1;
    8000300a:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    8000300c:	0007c863          	bltz	a5,8000301c <sys_wait+0x2a>
  return wait(p);
    80003010:	fe843503          	ld	a0,-24(s0)
    80003014:	fffff097          	auipc	ra,0xfffff
    80003018:	14a080e7          	jalr	330(ra) # 8000215e <wait>
}
    8000301c:	60e2                	ld	ra,24(sp)
    8000301e:	6442                	ld	s0,16(sp)
    80003020:	6105                	addi	sp,sp,32
    80003022:	8082                	ret

0000000080003024 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003024:	7179                	addi	sp,sp,-48
    80003026:	f406                	sd	ra,40(sp)
    80003028:	f022                	sd	s0,32(sp)
    8000302a:	ec26                	sd	s1,24(sp)
    8000302c:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000302e:	fdc40593          	addi	a1,s0,-36
    80003032:	4501                	li	a0,0
    80003034:	00000097          	auipc	ra,0x0
    80003038:	dbc080e7          	jalr	-580(ra) # 80002df0 <argint>
    return -1;
    8000303c:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    8000303e:	00054f63          	bltz	a0,8000305c <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003042:	fffff097          	auipc	ra,0xfffff
    80003046:	954080e7          	jalr	-1708(ra) # 80001996 <myproc>
    8000304a:	5524                	lw	s1,104(a0)
  if(growproc(n) < 0)
    8000304c:	fdc42503          	lw	a0,-36(s0)
    80003050:	fffff097          	auipc	ra,0xfffff
    80003054:	cc4080e7          	jalr	-828(ra) # 80001d14 <growproc>
    80003058:	00054863          	bltz	a0,80003068 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    8000305c:	8526                	mv	a0,s1
    8000305e:	70a2                	ld	ra,40(sp)
    80003060:	7402                	ld	s0,32(sp)
    80003062:	64e2                	ld	s1,24(sp)
    80003064:	6145                	addi	sp,sp,48
    80003066:	8082                	ret
    return -1;
    80003068:	54fd                	li	s1,-1
    8000306a:	bfcd                	j	8000305c <sys_sbrk+0x38>

000000008000306c <sys_sleep>:

uint64
sys_sleep(void)
{
    8000306c:	7139                	addi	sp,sp,-64
    8000306e:	fc06                	sd	ra,56(sp)
    80003070:	f822                	sd	s0,48(sp)
    80003072:	f426                	sd	s1,40(sp)
    80003074:	f04a                	sd	s2,32(sp)
    80003076:	ec4e                	sd	s3,24(sp)
    80003078:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    8000307a:	fcc40593          	addi	a1,s0,-52
    8000307e:	4501                	li	a0,0
    80003080:	00000097          	auipc	ra,0x0
    80003084:	d70080e7          	jalr	-656(ra) # 80002df0 <argint>
    return -1;
    80003088:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000308a:	06054563          	bltz	a0,800030f4 <sys_sleep+0x88>
  acquire(&tickslock);
    8000308e:	00015517          	auipc	a0,0x15
    80003092:	85a50513          	addi	a0,a0,-1958 # 800178e8 <tickslock>
    80003096:	ffffe097          	auipc	ra,0xffffe
    8000309a:	b2c080e7          	jalr	-1236(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    8000309e:	00006917          	auipc	s2,0x6
    800030a2:	f9a92903          	lw	s2,-102(s2) # 80009038 <ticks>
  while(ticks - ticks0 < n){
    800030a6:	fcc42783          	lw	a5,-52(s0)
    800030aa:	cf85                	beqz	a5,800030e2 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800030ac:	00015997          	auipc	s3,0x15
    800030b0:	83c98993          	addi	s3,s3,-1988 # 800178e8 <tickslock>
    800030b4:	00006497          	auipc	s1,0x6
    800030b8:	f8448493          	addi	s1,s1,-124 # 80009038 <ticks>
    if(myproc()->killed){
    800030bc:	fffff097          	auipc	ra,0xfffff
    800030c0:	8da080e7          	jalr	-1830(ra) # 80001996 <myproc>
    800030c4:	551c                	lw	a5,40(a0)
    800030c6:	ef9d                	bnez	a5,80003104 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    800030c8:	85ce                	mv	a1,s3
    800030ca:	8526                	mv	a0,s1
    800030cc:	fffff097          	auipc	ra,0xfffff
    800030d0:	02e080e7          	jalr	46(ra) # 800020fa <sleep>
  while(ticks - ticks0 < n){
    800030d4:	409c                	lw	a5,0(s1)
    800030d6:	412787bb          	subw	a5,a5,s2
    800030da:	fcc42703          	lw	a4,-52(s0)
    800030de:	fce7efe3          	bltu	a5,a4,800030bc <sys_sleep+0x50>
  }
  release(&tickslock);
    800030e2:	00015517          	auipc	a0,0x15
    800030e6:	80650513          	addi	a0,a0,-2042 # 800178e8 <tickslock>
    800030ea:	ffffe097          	auipc	ra,0xffffe
    800030ee:	b8c080e7          	jalr	-1140(ra) # 80000c76 <release>
  return 0;
    800030f2:	4781                	li	a5,0
}
    800030f4:	853e                	mv	a0,a5
    800030f6:	70e2                	ld	ra,56(sp)
    800030f8:	7442                	ld	s0,48(sp)
    800030fa:	74a2                	ld	s1,40(sp)
    800030fc:	7902                	ld	s2,32(sp)
    800030fe:	69e2                	ld	s3,24(sp)
    80003100:	6121                	addi	sp,sp,64
    80003102:	8082                	ret
      release(&tickslock);
    80003104:	00014517          	auipc	a0,0x14
    80003108:	7e450513          	addi	a0,a0,2020 # 800178e8 <tickslock>
    8000310c:	ffffe097          	auipc	ra,0xffffe
    80003110:	b6a080e7          	jalr	-1174(ra) # 80000c76 <release>
      return -1;
    80003114:	57fd                	li	a5,-1
    80003116:	bff9                	j	800030f4 <sys_sleep+0x88>

0000000080003118 <sys_kill>:

uint64
sys_kill(void)
{
    80003118:	1101                	addi	sp,sp,-32
    8000311a:	ec06                	sd	ra,24(sp)
    8000311c:	e822                	sd	s0,16(sp)
    8000311e:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003120:	fec40593          	addi	a1,s0,-20
    80003124:	4501                	li	a0,0
    80003126:	00000097          	auipc	ra,0x0
    8000312a:	cca080e7          	jalr	-822(ra) # 80002df0 <argint>
    8000312e:	87aa                	mv	a5,a0
    return -1;
    80003130:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003132:	0007c863          	bltz	a5,80003142 <sys_kill+0x2a>
  return kill(pid);
    80003136:	fec42503          	lw	a0,-20(s0)
    8000313a:	fffff097          	auipc	ra,0xfffff
    8000313e:	2fe080e7          	jalr	766(ra) # 80002438 <kill>
}
    80003142:	60e2                	ld	ra,24(sp)
    80003144:	6442                	ld	s0,16(sp)
    80003146:	6105                	addi	sp,sp,32
    80003148:	8082                	ret

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
    80003154:	00014517          	auipc	a0,0x14
    80003158:	79450513          	addi	a0,a0,1940 # 800178e8 <tickslock>
    8000315c:	ffffe097          	auipc	ra,0xffffe
    80003160:	a66080e7          	jalr	-1434(ra) # 80000bc2 <acquire>
  xticks = ticks;
    80003164:	00006497          	auipc	s1,0x6
    80003168:	ed44a483          	lw	s1,-300(s1) # 80009038 <ticks>
  release(&tickslock);
    8000316c:	00014517          	auipc	a0,0x14
    80003170:	77c50513          	addi	a0,a0,1916 # 800178e8 <tickslock>
    80003174:	ffffe097          	auipc	ra,0xffffe
    80003178:	b02080e7          	jalr	-1278(ra) # 80000c76 <release>
  return xticks;
}
    8000317c:	02049513          	slli	a0,s1,0x20
    80003180:	9101                	srli	a0,a0,0x20
    80003182:	60e2                	ld	ra,24(sp)
    80003184:	6442                	ld	s0,16(sp)
    80003186:	64a2                	ld	s1,8(sp)
    80003188:	6105                	addi	sp,sp,32
    8000318a:	8082                	ret

000000008000318c <sys_trace>:

uint64
sys_trace(void)
{
    8000318c:	1101                	addi	sp,sp,-32
    8000318e:	ec06                	sd	ra,24(sp)
    80003190:	e822                	sd	s0,16(sp)
    80003192:	1000                	addi	s0,sp,32
  int mask, pid;

  if(argint(0, &mask) < 0)
    80003194:	fec40593          	addi	a1,s0,-20
    80003198:	4501                	li	a0,0
    8000319a:	00000097          	auipc	ra,0x0
    8000319e:	c56080e7          	jalr	-938(ra) # 80002df0 <argint>
    return -1;
    800031a2:	57fd                	li	a5,-1
  if(argint(0, &mask) < 0)
    800031a4:	02054563          	bltz	a0,800031ce <sys_trace+0x42>
  if(argint(1, &pid) < 0)
    800031a8:	fe840593          	addi	a1,s0,-24
    800031ac:	4505                	li	a0,1
    800031ae:	00000097          	auipc	ra,0x0
    800031b2:	c42080e7          	jalr	-958(ra) # 80002df0 <argint>
    return -1;
    800031b6:	57fd                	li	a5,-1
  if(argint(1, &pid) < 0)
    800031b8:	00054b63          	bltz	a0,800031ce <sys_trace+0x42>
  return trace(mask, pid);
    800031bc:	fe842583          	lw	a1,-24(s0)
    800031c0:	fec42503          	lw	a0,-20(s0)
    800031c4:	fffff097          	auipc	ra,0xfffff
    800031c8:	442080e7          	jalr	1090(ra) # 80002606 <trace>
    800031cc:	87aa                	mv	a5,a0
}
    800031ce:	853e                	mv	a0,a5
    800031d0:	60e2                	ld	ra,24(sp)
    800031d2:	6442                	ld	s0,16(sp)
    800031d4:	6105                	addi	sp,sp,32
    800031d6:	8082                	ret

00000000800031d8 <sys_wait_stat>:


uint64
sys_wait_stat(void){
    800031d8:	1101                	addi	sp,sp,-32
    800031da:	ec06                	sd	ra,24(sp)
    800031dc:	e822                	sd	s0,16(sp)
    800031de:	1000                	addi	s0,sp,32
  uint64 stat;
  uint64 perf;
  if(argaddr(0, &stat) < 0)
    800031e0:	fe840593          	addi	a1,s0,-24
    800031e4:	4501                	li	a0,0
    800031e6:	00000097          	auipc	ra,0x0
    800031ea:	c2c080e7          	jalr	-980(ra) # 80002e12 <argaddr>
    return -1;
    800031ee:	57fd                	li	a5,-1
  if(argaddr(0, &stat) < 0)
    800031f0:	02054563          	bltz	a0,8000321a <sys_wait_stat+0x42>
  if(argaddr(1, &perf) < 0)
    800031f4:	fe040593          	addi	a1,s0,-32
    800031f8:	4505                	li	a0,1
    800031fa:	00000097          	auipc	ra,0x0
    800031fe:	c18080e7          	jalr	-1000(ra) # 80002e12 <argaddr>
    return -1;
    80003202:	57fd                	li	a5,-1
  if(argaddr(1, &perf) < 0)
    80003204:	00054b63          	bltz	a0,8000321a <sys_wait_stat+0x42>
  return wait_stat(stat, perf);
    80003208:	fe043583          	ld	a1,-32(s0)
    8000320c:	fe843503          	ld	a0,-24(s0)
    80003210:	fffff097          	auipc	ra,0xfffff
    80003214:	460080e7          	jalr	1120(ra) # 80002670 <wait_stat>
    80003218:	87aa                	mv	a5,a0
}
    8000321a:	853e                	mv	a0,a5
    8000321c:	60e2                	ld	ra,24(sp)
    8000321e:	6442                	ld	s0,16(sp)
    80003220:	6105                	addi	sp,sp,32
    80003222:	8082                	ret

0000000080003224 <sys_set_priority>:

uint64
sys_set_priority(void){
    80003224:	1101                	addi	sp,sp,-32
    80003226:	ec06                	sd	ra,24(sp)
    80003228:	e822                	sd	s0,16(sp)
    8000322a:	1000                	addi	s0,sp,32
  int priotity;
 if(argint(0,&priotity) < 0)
    8000322c:	fec40593          	addi	a1,s0,-20
    80003230:	4501                	li	a0,0
    80003232:	00000097          	auipc	ra,0x0
    80003236:	bbe080e7          	jalr	-1090(ra) # 80002df0 <argint>
    8000323a:	87aa                	mv	a5,a0
    return -1;
    8000323c:	557d                	li	a0,-1
 if(argint(0,&priotity) < 0)
    8000323e:	0007c863          	bltz	a5,8000324e <sys_set_priority+0x2a>
  return set_priority(priotity);
    80003242:	fec42503          	lw	a0,-20(s0)
    80003246:	fffff097          	auipc	ra,0xfffff
    8000324a:	628080e7          	jalr	1576(ra) # 8000286e <set_priority>
}
    8000324e:	60e2                	ld	ra,24(sp)
    80003250:	6442                	ld	s0,16(sp)
    80003252:	6105                	addi	sp,sp,32
    80003254:	8082                	ret

0000000080003256 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003256:	7179                	addi	sp,sp,-48
    80003258:	f406                	sd	ra,40(sp)
    8000325a:	f022                	sd	s0,32(sp)
    8000325c:	ec26                	sd	s1,24(sp)
    8000325e:	e84a                	sd	s2,16(sp)
    80003260:	e44e                	sd	s3,8(sp)
    80003262:	e052                	sd	s4,0(sp)
    80003264:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003266:	00005597          	auipc	a1,0x5
    8000326a:	48a58593          	addi	a1,a1,1162 # 800086f0 <syscalls+0xc8>
    8000326e:	00014517          	auipc	a0,0x14
    80003272:	69250513          	addi	a0,a0,1682 # 80017900 <bcache>
    80003276:	ffffe097          	auipc	ra,0xffffe
    8000327a:	8bc080e7          	jalr	-1860(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000327e:	0001c797          	auipc	a5,0x1c
    80003282:	68278793          	addi	a5,a5,1666 # 8001f900 <bcache+0x8000>
    80003286:	0001d717          	auipc	a4,0x1d
    8000328a:	8e270713          	addi	a4,a4,-1822 # 8001fb68 <bcache+0x8268>
    8000328e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003292:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003296:	00014497          	auipc	s1,0x14
    8000329a:	68248493          	addi	s1,s1,1666 # 80017918 <bcache+0x18>
    b->next = bcache.head.next;
    8000329e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800032a0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800032a2:	00005a17          	auipc	s4,0x5
    800032a6:	456a0a13          	addi	s4,s4,1110 # 800086f8 <syscalls+0xd0>
    b->next = bcache.head.next;
    800032aa:	2b893783          	ld	a5,696(s2)
    800032ae:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800032b0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800032b4:	85d2                	mv	a1,s4
    800032b6:	01048513          	addi	a0,s1,16
    800032ba:	00001097          	auipc	ra,0x1
    800032be:	4c2080e7          	jalr	1218(ra) # 8000477c <initsleeplock>
    bcache.head.next->prev = b;
    800032c2:	2b893783          	ld	a5,696(s2)
    800032c6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800032c8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800032cc:	45848493          	addi	s1,s1,1112
    800032d0:	fd349de3          	bne	s1,s3,800032aa <binit+0x54>
  }
}
    800032d4:	70a2                	ld	ra,40(sp)
    800032d6:	7402                	ld	s0,32(sp)
    800032d8:	64e2                	ld	s1,24(sp)
    800032da:	6942                	ld	s2,16(sp)
    800032dc:	69a2                	ld	s3,8(sp)
    800032de:	6a02                	ld	s4,0(sp)
    800032e0:	6145                	addi	sp,sp,48
    800032e2:	8082                	ret

00000000800032e4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800032e4:	7179                	addi	sp,sp,-48
    800032e6:	f406                	sd	ra,40(sp)
    800032e8:	f022                	sd	s0,32(sp)
    800032ea:	ec26                	sd	s1,24(sp)
    800032ec:	e84a                	sd	s2,16(sp)
    800032ee:	e44e                	sd	s3,8(sp)
    800032f0:	1800                	addi	s0,sp,48
    800032f2:	892a                	mv	s2,a0
    800032f4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800032f6:	00014517          	auipc	a0,0x14
    800032fa:	60a50513          	addi	a0,a0,1546 # 80017900 <bcache>
    800032fe:	ffffe097          	auipc	ra,0xffffe
    80003302:	8c4080e7          	jalr	-1852(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003306:	0001d497          	auipc	s1,0x1d
    8000330a:	8b24b483          	ld	s1,-1870(s1) # 8001fbb8 <bcache+0x82b8>
    8000330e:	0001d797          	auipc	a5,0x1d
    80003312:	85a78793          	addi	a5,a5,-1958 # 8001fb68 <bcache+0x8268>
    80003316:	02f48f63          	beq	s1,a5,80003354 <bread+0x70>
    8000331a:	873e                	mv	a4,a5
    8000331c:	a021                	j	80003324 <bread+0x40>
    8000331e:	68a4                	ld	s1,80(s1)
    80003320:	02e48a63          	beq	s1,a4,80003354 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003324:	449c                	lw	a5,8(s1)
    80003326:	ff279ce3          	bne	a5,s2,8000331e <bread+0x3a>
    8000332a:	44dc                	lw	a5,12(s1)
    8000332c:	ff3799e3          	bne	a5,s3,8000331e <bread+0x3a>
      b->refcnt++;
    80003330:	40bc                	lw	a5,64(s1)
    80003332:	2785                	addiw	a5,a5,1
    80003334:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003336:	00014517          	auipc	a0,0x14
    8000333a:	5ca50513          	addi	a0,a0,1482 # 80017900 <bcache>
    8000333e:	ffffe097          	auipc	ra,0xffffe
    80003342:	938080e7          	jalr	-1736(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003346:	01048513          	addi	a0,s1,16
    8000334a:	00001097          	auipc	ra,0x1
    8000334e:	46c080e7          	jalr	1132(ra) # 800047b6 <acquiresleep>
      return b;
    80003352:	a8b9                	j	800033b0 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003354:	0001d497          	auipc	s1,0x1d
    80003358:	85c4b483          	ld	s1,-1956(s1) # 8001fbb0 <bcache+0x82b0>
    8000335c:	0001d797          	auipc	a5,0x1d
    80003360:	80c78793          	addi	a5,a5,-2036 # 8001fb68 <bcache+0x8268>
    80003364:	00f48863          	beq	s1,a5,80003374 <bread+0x90>
    80003368:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000336a:	40bc                	lw	a5,64(s1)
    8000336c:	cf81                	beqz	a5,80003384 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000336e:	64a4                	ld	s1,72(s1)
    80003370:	fee49de3          	bne	s1,a4,8000336a <bread+0x86>
  panic("bget: no buffers");
    80003374:	00005517          	auipc	a0,0x5
    80003378:	38c50513          	addi	a0,a0,908 # 80008700 <syscalls+0xd8>
    8000337c:	ffffd097          	auipc	ra,0xffffd
    80003380:	1ae080e7          	jalr	430(ra) # 8000052a <panic>
      b->dev = dev;
    80003384:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003388:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000338c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003390:	4785                	li	a5,1
    80003392:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003394:	00014517          	auipc	a0,0x14
    80003398:	56c50513          	addi	a0,a0,1388 # 80017900 <bcache>
    8000339c:	ffffe097          	auipc	ra,0xffffe
    800033a0:	8da080e7          	jalr	-1830(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    800033a4:	01048513          	addi	a0,s1,16
    800033a8:	00001097          	auipc	ra,0x1
    800033ac:	40e080e7          	jalr	1038(ra) # 800047b6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800033b0:	409c                	lw	a5,0(s1)
    800033b2:	cb89                	beqz	a5,800033c4 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800033b4:	8526                	mv	a0,s1
    800033b6:	70a2                	ld	ra,40(sp)
    800033b8:	7402                	ld	s0,32(sp)
    800033ba:	64e2                	ld	s1,24(sp)
    800033bc:	6942                	ld	s2,16(sp)
    800033be:	69a2                	ld	s3,8(sp)
    800033c0:	6145                	addi	sp,sp,48
    800033c2:	8082                	ret
    virtio_disk_rw(b, 0);
    800033c4:	4581                	li	a1,0
    800033c6:	8526                	mv	a0,s1
    800033c8:	00003097          	auipc	ra,0x3
    800033cc:	f1e080e7          	jalr	-226(ra) # 800062e6 <virtio_disk_rw>
    b->valid = 1;
    800033d0:	4785                	li	a5,1
    800033d2:	c09c                	sw	a5,0(s1)
  return b;
    800033d4:	b7c5                	j	800033b4 <bread+0xd0>

00000000800033d6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800033d6:	1101                	addi	sp,sp,-32
    800033d8:	ec06                	sd	ra,24(sp)
    800033da:	e822                	sd	s0,16(sp)
    800033dc:	e426                	sd	s1,8(sp)
    800033de:	1000                	addi	s0,sp,32
    800033e0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033e2:	0541                	addi	a0,a0,16
    800033e4:	00001097          	auipc	ra,0x1
    800033e8:	46c080e7          	jalr	1132(ra) # 80004850 <holdingsleep>
    800033ec:	cd01                	beqz	a0,80003404 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800033ee:	4585                	li	a1,1
    800033f0:	8526                	mv	a0,s1
    800033f2:	00003097          	auipc	ra,0x3
    800033f6:	ef4080e7          	jalr	-268(ra) # 800062e6 <virtio_disk_rw>
}
    800033fa:	60e2                	ld	ra,24(sp)
    800033fc:	6442                	ld	s0,16(sp)
    800033fe:	64a2                	ld	s1,8(sp)
    80003400:	6105                	addi	sp,sp,32
    80003402:	8082                	ret
    panic("bwrite");
    80003404:	00005517          	auipc	a0,0x5
    80003408:	31450513          	addi	a0,a0,788 # 80008718 <syscalls+0xf0>
    8000340c:	ffffd097          	auipc	ra,0xffffd
    80003410:	11e080e7          	jalr	286(ra) # 8000052a <panic>

0000000080003414 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003414:	1101                	addi	sp,sp,-32
    80003416:	ec06                	sd	ra,24(sp)
    80003418:	e822                	sd	s0,16(sp)
    8000341a:	e426                	sd	s1,8(sp)
    8000341c:	e04a                	sd	s2,0(sp)
    8000341e:	1000                	addi	s0,sp,32
    80003420:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003422:	01050913          	addi	s2,a0,16
    80003426:	854a                	mv	a0,s2
    80003428:	00001097          	auipc	ra,0x1
    8000342c:	428080e7          	jalr	1064(ra) # 80004850 <holdingsleep>
    80003430:	c92d                	beqz	a0,800034a2 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003432:	854a                	mv	a0,s2
    80003434:	00001097          	auipc	ra,0x1
    80003438:	3d8080e7          	jalr	984(ra) # 8000480c <releasesleep>

  acquire(&bcache.lock);
    8000343c:	00014517          	auipc	a0,0x14
    80003440:	4c450513          	addi	a0,a0,1220 # 80017900 <bcache>
    80003444:	ffffd097          	auipc	ra,0xffffd
    80003448:	77e080e7          	jalr	1918(ra) # 80000bc2 <acquire>
  b->refcnt--;
    8000344c:	40bc                	lw	a5,64(s1)
    8000344e:	37fd                	addiw	a5,a5,-1
    80003450:	0007871b          	sext.w	a4,a5
    80003454:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003456:	eb05                	bnez	a4,80003486 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003458:	68bc                	ld	a5,80(s1)
    8000345a:	64b8                	ld	a4,72(s1)
    8000345c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000345e:	64bc                	ld	a5,72(s1)
    80003460:	68b8                	ld	a4,80(s1)
    80003462:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003464:	0001c797          	auipc	a5,0x1c
    80003468:	49c78793          	addi	a5,a5,1180 # 8001f900 <bcache+0x8000>
    8000346c:	2b87b703          	ld	a4,696(a5)
    80003470:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003472:	0001c717          	auipc	a4,0x1c
    80003476:	6f670713          	addi	a4,a4,1782 # 8001fb68 <bcache+0x8268>
    8000347a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000347c:	2b87b703          	ld	a4,696(a5)
    80003480:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003482:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003486:	00014517          	auipc	a0,0x14
    8000348a:	47a50513          	addi	a0,a0,1146 # 80017900 <bcache>
    8000348e:	ffffd097          	auipc	ra,0xffffd
    80003492:	7e8080e7          	jalr	2024(ra) # 80000c76 <release>
}
    80003496:	60e2                	ld	ra,24(sp)
    80003498:	6442                	ld	s0,16(sp)
    8000349a:	64a2                	ld	s1,8(sp)
    8000349c:	6902                	ld	s2,0(sp)
    8000349e:	6105                	addi	sp,sp,32
    800034a0:	8082                	ret
    panic("brelse");
    800034a2:	00005517          	auipc	a0,0x5
    800034a6:	27e50513          	addi	a0,a0,638 # 80008720 <syscalls+0xf8>
    800034aa:	ffffd097          	auipc	ra,0xffffd
    800034ae:	080080e7          	jalr	128(ra) # 8000052a <panic>

00000000800034b2 <bpin>:

void
bpin(struct buf *b) {
    800034b2:	1101                	addi	sp,sp,-32
    800034b4:	ec06                	sd	ra,24(sp)
    800034b6:	e822                	sd	s0,16(sp)
    800034b8:	e426                	sd	s1,8(sp)
    800034ba:	1000                	addi	s0,sp,32
    800034bc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034be:	00014517          	auipc	a0,0x14
    800034c2:	44250513          	addi	a0,a0,1090 # 80017900 <bcache>
    800034c6:	ffffd097          	auipc	ra,0xffffd
    800034ca:	6fc080e7          	jalr	1788(ra) # 80000bc2 <acquire>
  b->refcnt++;
    800034ce:	40bc                	lw	a5,64(s1)
    800034d0:	2785                	addiw	a5,a5,1
    800034d2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034d4:	00014517          	auipc	a0,0x14
    800034d8:	42c50513          	addi	a0,a0,1068 # 80017900 <bcache>
    800034dc:	ffffd097          	auipc	ra,0xffffd
    800034e0:	79a080e7          	jalr	1946(ra) # 80000c76 <release>
}
    800034e4:	60e2                	ld	ra,24(sp)
    800034e6:	6442                	ld	s0,16(sp)
    800034e8:	64a2                	ld	s1,8(sp)
    800034ea:	6105                	addi	sp,sp,32
    800034ec:	8082                	ret

00000000800034ee <bunpin>:

void
bunpin(struct buf *b) {
    800034ee:	1101                	addi	sp,sp,-32
    800034f0:	ec06                	sd	ra,24(sp)
    800034f2:	e822                	sd	s0,16(sp)
    800034f4:	e426                	sd	s1,8(sp)
    800034f6:	1000                	addi	s0,sp,32
    800034f8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034fa:	00014517          	auipc	a0,0x14
    800034fe:	40650513          	addi	a0,a0,1030 # 80017900 <bcache>
    80003502:	ffffd097          	auipc	ra,0xffffd
    80003506:	6c0080e7          	jalr	1728(ra) # 80000bc2 <acquire>
  b->refcnt--;
    8000350a:	40bc                	lw	a5,64(s1)
    8000350c:	37fd                	addiw	a5,a5,-1
    8000350e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003510:	00014517          	auipc	a0,0x14
    80003514:	3f050513          	addi	a0,a0,1008 # 80017900 <bcache>
    80003518:	ffffd097          	auipc	ra,0xffffd
    8000351c:	75e080e7          	jalr	1886(ra) # 80000c76 <release>
}
    80003520:	60e2                	ld	ra,24(sp)
    80003522:	6442                	ld	s0,16(sp)
    80003524:	64a2                	ld	s1,8(sp)
    80003526:	6105                	addi	sp,sp,32
    80003528:	8082                	ret

000000008000352a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000352a:	1101                	addi	sp,sp,-32
    8000352c:	ec06                	sd	ra,24(sp)
    8000352e:	e822                	sd	s0,16(sp)
    80003530:	e426                	sd	s1,8(sp)
    80003532:	e04a                	sd	s2,0(sp)
    80003534:	1000                	addi	s0,sp,32
    80003536:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003538:	00d5d59b          	srliw	a1,a1,0xd
    8000353c:	0001d797          	auipc	a5,0x1d
    80003540:	aa07a783          	lw	a5,-1376(a5) # 8001ffdc <sb+0x1c>
    80003544:	9dbd                	addw	a1,a1,a5
    80003546:	00000097          	auipc	ra,0x0
    8000354a:	d9e080e7          	jalr	-610(ra) # 800032e4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000354e:	0074f713          	andi	a4,s1,7
    80003552:	4785                	li	a5,1
    80003554:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003558:	14ce                	slli	s1,s1,0x33
    8000355a:	90d9                	srli	s1,s1,0x36
    8000355c:	00950733          	add	a4,a0,s1
    80003560:	05874703          	lbu	a4,88(a4)
    80003564:	00e7f6b3          	and	a3,a5,a4
    80003568:	c69d                	beqz	a3,80003596 <bfree+0x6c>
    8000356a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000356c:	94aa                	add	s1,s1,a0
    8000356e:	fff7c793          	not	a5,a5
    80003572:	8ff9                	and	a5,a5,a4
    80003574:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003578:	00001097          	auipc	ra,0x1
    8000357c:	11e080e7          	jalr	286(ra) # 80004696 <log_write>
  brelse(bp);
    80003580:	854a                	mv	a0,s2
    80003582:	00000097          	auipc	ra,0x0
    80003586:	e92080e7          	jalr	-366(ra) # 80003414 <brelse>
}
    8000358a:	60e2                	ld	ra,24(sp)
    8000358c:	6442                	ld	s0,16(sp)
    8000358e:	64a2                	ld	s1,8(sp)
    80003590:	6902                	ld	s2,0(sp)
    80003592:	6105                	addi	sp,sp,32
    80003594:	8082                	ret
    panic("freeing free block");
    80003596:	00005517          	auipc	a0,0x5
    8000359a:	19250513          	addi	a0,a0,402 # 80008728 <syscalls+0x100>
    8000359e:	ffffd097          	auipc	ra,0xffffd
    800035a2:	f8c080e7          	jalr	-116(ra) # 8000052a <panic>

00000000800035a6 <balloc>:
{
    800035a6:	711d                	addi	sp,sp,-96
    800035a8:	ec86                	sd	ra,88(sp)
    800035aa:	e8a2                	sd	s0,80(sp)
    800035ac:	e4a6                	sd	s1,72(sp)
    800035ae:	e0ca                	sd	s2,64(sp)
    800035b0:	fc4e                	sd	s3,56(sp)
    800035b2:	f852                	sd	s4,48(sp)
    800035b4:	f456                	sd	s5,40(sp)
    800035b6:	f05a                	sd	s6,32(sp)
    800035b8:	ec5e                	sd	s7,24(sp)
    800035ba:	e862                	sd	s8,16(sp)
    800035bc:	e466                	sd	s9,8(sp)
    800035be:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800035c0:	0001d797          	auipc	a5,0x1d
    800035c4:	a047a783          	lw	a5,-1532(a5) # 8001ffc4 <sb+0x4>
    800035c8:	cbd1                	beqz	a5,8000365c <balloc+0xb6>
    800035ca:	8baa                	mv	s7,a0
    800035cc:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800035ce:	0001db17          	auipc	s6,0x1d
    800035d2:	9f2b0b13          	addi	s6,s6,-1550 # 8001ffc0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035d6:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800035d8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035da:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800035dc:	6c89                	lui	s9,0x2
    800035de:	a831                	j	800035fa <balloc+0x54>
    brelse(bp);
    800035e0:	854a                	mv	a0,s2
    800035e2:	00000097          	auipc	ra,0x0
    800035e6:	e32080e7          	jalr	-462(ra) # 80003414 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800035ea:	015c87bb          	addw	a5,s9,s5
    800035ee:	00078a9b          	sext.w	s5,a5
    800035f2:	004b2703          	lw	a4,4(s6)
    800035f6:	06eaf363          	bgeu	s5,a4,8000365c <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800035fa:	41fad79b          	sraiw	a5,s5,0x1f
    800035fe:	0137d79b          	srliw	a5,a5,0x13
    80003602:	015787bb          	addw	a5,a5,s5
    80003606:	40d7d79b          	sraiw	a5,a5,0xd
    8000360a:	01cb2583          	lw	a1,28(s6)
    8000360e:	9dbd                	addw	a1,a1,a5
    80003610:	855e                	mv	a0,s7
    80003612:	00000097          	auipc	ra,0x0
    80003616:	cd2080e7          	jalr	-814(ra) # 800032e4 <bread>
    8000361a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000361c:	004b2503          	lw	a0,4(s6)
    80003620:	000a849b          	sext.w	s1,s5
    80003624:	8662                	mv	a2,s8
    80003626:	faa4fde3          	bgeu	s1,a0,800035e0 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000362a:	41f6579b          	sraiw	a5,a2,0x1f
    8000362e:	01d7d69b          	srliw	a3,a5,0x1d
    80003632:	00c6873b          	addw	a4,a3,a2
    80003636:	00777793          	andi	a5,a4,7
    8000363a:	9f95                	subw	a5,a5,a3
    8000363c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003640:	4037571b          	sraiw	a4,a4,0x3
    80003644:	00e906b3          	add	a3,s2,a4
    80003648:	0586c683          	lbu	a3,88(a3)
    8000364c:	00d7f5b3          	and	a1,a5,a3
    80003650:	cd91                	beqz	a1,8000366c <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003652:	2605                	addiw	a2,a2,1
    80003654:	2485                	addiw	s1,s1,1
    80003656:	fd4618e3          	bne	a2,s4,80003626 <balloc+0x80>
    8000365a:	b759                	j	800035e0 <balloc+0x3a>
  panic("balloc: out of blocks");
    8000365c:	00005517          	auipc	a0,0x5
    80003660:	0e450513          	addi	a0,a0,228 # 80008740 <syscalls+0x118>
    80003664:	ffffd097          	auipc	ra,0xffffd
    80003668:	ec6080e7          	jalr	-314(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000366c:	974a                	add	a4,a4,s2
    8000366e:	8fd5                	or	a5,a5,a3
    80003670:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003674:	854a                	mv	a0,s2
    80003676:	00001097          	auipc	ra,0x1
    8000367a:	020080e7          	jalr	32(ra) # 80004696 <log_write>
        brelse(bp);
    8000367e:	854a                	mv	a0,s2
    80003680:	00000097          	auipc	ra,0x0
    80003684:	d94080e7          	jalr	-620(ra) # 80003414 <brelse>
  bp = bread(dev, bno);
    80003688:	85a6                	mv	a1,s1
    8000368a:	855e                	mv	a0,s7
    8000368c:	00000097          	auipc	ra,0x0
    80003690:	c58080e7          	jalr	-936(ra) # 800032e4 <bread>
    80003694:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003696:	40000613          	li	a2,1024
    8000369a:	4581                	li	a1,0
    8000369c:	05850513          	addi	a0,a0,88
    800036a0:	ffffd097          	auipc	ra,0xffffd
    800036a4:	61e080e7          	jalr	1566(ra) # 80000cbe <memset>
  log_write(bp);
    800036a8:	854a                	mv	a0,s2
    800036aa:	00001097          	auipc	ra,0x1
    800036ae:	fec080e7          	jalr	-20(ra) # 80004696 <log_write>
  brelse(bp);
    800036b2:	854a                	mv	a0,s2
    800036b4:	00000097          	auipc	ra,0x0
    800036b8:	d60080e7          	jalr	-672(ra) # 80003414 <brelse>
}
    800036bc:	8526                	mv	a0,s1
    800036be:	60e6                	ld	ra,88(sp)
    800036c0:	6446                	ld	s0,80(sp)
    800036c2:	64a6                	ld	s1,72(sp)
    800036c4:	6906                	ld	s2,64(sp)
    800036c6:	79e2                	ld	s3,56(sp)
    800036c8:	7a42                	ld	s4,48(sp)
    800036ca:	7aa2                	ld	s5,40(sp)
    800036cc:	7b02                	ld	s6,32(sp)
    800036ce:	6be2                	ld	s7,24(sp)
    800036d0:	6c42                	ld	s8,16(sp)
    800036d2:	6ca2                	ld	s9,8(sp)
    800036d4:	6125                	addi	sp,sp,96
    800036d6:	8082                	ret

00000000800036d8 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800036d8:	7179                	addi	sp,sp,-48
    800036da:	f406                	sd	ra,40(sp)
    800036dc:	f022                	sd	s0,32(sp)
    800036de:	ec26                	sd	s1,24(sp)
    800036e0:	e84a                	sd	s2,16(sp)
    800036e2:	e44e                	sd	s3,8(sp)
    800036e4:	e052                	sd	s4,0(sp)
    800036e6:	1800                	addi	s0,sp,48
    800036e8:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800036ea:	47ad                	li	a5,11
    800036ec:	04b7fe63          	bgeu	a5,a1,80003748 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800036f0:	ff45849b          	addiw	s1,a1,-12
    800036f4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800036f8:	0ff00793          	li	a5,255
    800036fc:	0ae7e463          	bltu	a5,a4,800037a4 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003700:	08052583          	lw	a1,128(a0)
    80003704:	c5b5                	beqz	a1,80003770 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003706:	00092503          	lw	a0,0(s2)
    8000370a:	00000097          	auipc	ra,0x0
    8000370e:	bda080e7          	jalr	-1062(ra) # 800032e4 <bread>
    80003712:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003714:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003718:	02049713          	slli	a4,s1,0x20
    8000371c:	01e75593          	srli	a1,a4,0x1e
    80003720:	00b784b3          	add	s1,a5,a1
    80003724:	0004a983          	lw	s3,0(s1)
    80003728:	04098e63          	beqz	s3,80003784 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000372c:	8552                	mv	a0,s4
    8000372e:	00000097          	auipc	ra,0x0
    80003732:	ce6080e7          	jalr	-794(ra) # 80003414 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003736:	854e                	mv	a0,s3
    80003738:	70a2                	ld	ra,40(sp)
    8000373a:	7402                	ld	s0,32(sp)
    8000373c:	64e2                	ld	s1,24(sp)
    8000373e:	6942                	ld	s2,16(sp)
    80003740:	69a2                	ld	s3,8(sp)
    80003742:	6a02                	ld	s4,0(sp)
    80003744:	6145                	addi	sp,sp,48
    80003746:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003748:	02059793          	slli	a5,a1,0x20
    8000374c:	01e7d593          	srli	a1,a5,0x1e
    80003750:	00b504b3          	add	s1,a0,a1
    80003754:	0504a983          	lw	s3,80(s1)
    80003758:	fc099fe3          	bnez	s3,80003736 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000375c:	4108                	lw	a0,0(a0)
    8000375e:	00000097          	auipc	ra,0x0
    80003762:	e48080e7          	jalr	-440(ra) # 800035a6 <balloc>
    80003766:	0005099b          	sext.w	s3,a0
    8000376a:	0534a823          	sw	s3,80(s1)
    8000376e:	b7e1                	j	80003736 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003770:	4108                	lw	a0,0(a0)
    80003772:	00000097          	auipc	ra,0x0
    80003776:	e34080e7          	jalr	-460(ra) # 800035a6 <balloc>
    8000377a:	0005059b          	sext.w	a1,a0
    8000377e:	08b92023          	sw	a1,128(s2)
    80003782:	b751                	j	80003706 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003784:	00092503          	lw	a0,0(s2)
    80003788:	00000097          	auipc	ra,0x0
    8000378c:	e1e080e7          	jalr	-482(ra) # 800035a6 <balloc>
    80003790:	0005099b          	sext.w	s3,a0
    80003794:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003798:	8552                	mv	a0,s4
    8000379a:	00001097          	auipc	ra,0x1
    8000379e:	efc080e7          	jalr	-260(ra) # 80004696 <log_write>
    800037a2:	b769                	j	8000372c <bmap+0x54>
  panic("bmap: out of range");
    800037a4:	00005517          	auipc	a0,0x5
    800037a8:	fb450513          	addi	a0,a0,-76 # 80008758 <syscalls+0x130>
    800037ac:	ffffd097          	auipc	ra,0xffffd
    800037b0:	d7e080e7          	jalr	-642(ra) # 8000052a <panic>

00000000800037b4 <iget>:
{
    800037b4:	7179                	addi	sp,sp,-48
    800037b6:	f406                	sd	ra,40(sp)
    800037b8:	f022                	sd	s0,32(sp)
    800037ba:	ec26                	sd	s1,24(sp)
    800037bc:	e84a                	sd	s2,16(sp)
    800037be:	e44e                	sd	s3,8(sp)
    800037c0:	e052                	sd	s4,0(sp)
    800037c2:	1800                	addi	s0,sp,48
    800037c4:	89aa                	mv	s3,a0
    800037c6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800037c8:	0001d517          	auipc	a0,0x1d
    800037cc:	81850513          	addi	a0,a0,-2024 # 8001ffe0 <itable>
    800037d0:	ffffd097          	auipc	ra,0xffffd
    800037d4:	3f2080e7          	jalr	1010(ra) # 80000bc2 <acquire>
  empty = 0;
    800037d8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037da:	0001d497          	auipc	s1,0x1d
    800037de:	81e48493          	addi	s1,s1,-2018 # 8001fff8 <itable+0x18>
    800037e2:	0001e697          	auipc	a3,0x1e
    800037e6:	2a668693          	addi	a3,a3,678 # 80021a88 <log>
    800037ea:	a039                	j	800037f8 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037ec:	02090b63          	beqz	s2,80003822 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037f0:	08848493          	addi	s1,s1,136
    800037f4:	02d48a63          	beq	s1,a3,80003828 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800037f8:	449c                	lw	a5,8(s1)
    800037fa:	fef059e3          	blez	a5,800037ec <iget+0x38>
    800037fe:	4098                	lw	a4,0(s1)
    80003800:	ff3716e3          	bne	a4,s3,800037ec <iget+0x38>
    80003804:	40d8                	lw	a4,4(s1)
    80003806:	ff4713e3          	bne	a4,s4,800037ec <iget+0x38>
      ip->ref++;
    8000380a:	2785                	addiw	a5,a5,1
    8000380c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000380e:	0001c517          	auipc	a0,0x1c
    80003812:	7d250513          	addi	a0,a0,2002 # 8001ffe0 <itable>
    80003816:	ffffd097          	auipc	ra,0xffffd
    8000381a:	460080e7          	jalr	1120(ra) # 80000c76 <release>
      return ip;
    8000381e:	8926                	mv	s2,s1
    80003820:	a03d                	j	8000384e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003822:	f7f9                	bnez	a5,800037f0 <iget+0x3c>
    80003824:	8926                	mv	s2,s1
    80003826:	b7e9                	j	800037f0 <iget+0x3c>
  if(empty == 0)
    80003828:	02090c63          	beqz	s2,80003860 <iget+0xac>
  ip->dev = dev;
    8000382c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003830:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003834:	4785                	li	a5,1
    80003836:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000383a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000383e:	0001c517          	auipc	a0,0x1c
    80003842:	7a250513          	addi	a0,a0,1954 # 8001ffe0 <itable>
    80003846:	ffffd097          	auipc	ra,0xffffd
    8000384a:	430080e7          	jalr	1072(ra) # 80000c76 <release>
}
    8000384e:	854a                	mv	a0,s2
    80003850:	70a2                	ld	ra,40(sp)
    80003852:	7402                	ld	s0,32(sp)
    80003854:	64e2                	ld	s1,24(sp)
    80003856:	6942                	ld	s2,16(sp)
    80003858:	69a2                	ld	s3,8(sp)
    8000385a:	6a02                	ld	s4,0(sp)
    8000385c:	6145                	addi	sp,sp,48
    8000385e:	8082                	ret
    panic("iget: no inodes");
    80003860:	00005517          	auipc	a0,0x5
    80003864:	f1050513          	addi	a0,a0,-240 # 80008770 <syscalls+0x148>
    80003868:	ffffd097          	auipc	ra,0xffffd
    8000386c:	cc2080e7          	jalr	-830(ra) # 8000052a <panic>

0000000080003870 <fsinit>:
fsinit(int dev) {
    80003870:	7179                	addi	sp,sp,-48
    80003872:	f406                	sd	ra,40(sp)
    80003874:	f022                	sd	s0,32(sp)
    80003876:	ec26                	sd	s1,24(sp)
    80003878:	e84a                	sd	s2,16(sp)
    8000387a:	e44e                	sd	s3,8(sp)
    8000387c:	1800                	addi	s0,sp,48
    8000387e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003880:	4585                	li	a1,1
    80003882:	00000097          	auipc	ra,0x0
    80003886:	a62080e7          	jalr	-1438(ra) # 800032e4 <bread>
    8000388a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000388c:	0001c997          	auipc	s3,0x1c
    80003890:	73498993          	addi	s3,s3,1844 # 8001ffc0 <sb>
    80003894:	02000613          	li	a2,32
    80003898:	05850593          	addi	a1,a0,88
    8000389c:	854e                	mv	a0,s3
    8000389e:	ffffd097          	auipc	ra,0xffffd
    800038a2:	47c080e7          	jalr	1148(ra) # 80000d1a <memmove>
  brelse(bp);
    800038a6:	8526                	mv	a0,s1
    800038a8:	00000097          	auipc	ra,0x0
    800038ac:	b6c080e7          	jalr	-1172(ra) # 80003414 <brelse>
  if(sb.magic != FSMAGIC)
    800038b0:	0009a703          	lw	a4,0(s3)
    800038b4:	102037b7          	lui	a5,0x10203
    800038b8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800038bc:	02f71263          	bne	a4,a5,800038e0 <fsinit+0x70>
  initlog(dev, &sb);
    800038c0:	0001c597          	auipc	a1,0x1c
    800038c4:	70058593          	addi	a1,a1,1792 # 8001ffc0 <sb>
    800038c8:	854a                	mv	a0,s2
    800038ca:	00001097          	auipc	ra,0x1
    800038ce:	b4e080e7          	jalr	-1202(ra) # 80004418 <initlog>
}
    800038d2:	70a2                	ld	ra,40(sp)
    800038d4:	7402                	ld	s0,32(sp)
    800038d6:	64e2                	ld	s1,24(sp)
    800038d8:	6942                	ld	s2,16(sp)
    800038da:	69a2                	ld	s3,8(sp)
    800038dc:	6145                	addi	sp,sp,48
    800038de:	8082                	ret
    panic("invalid file system");
    800038e0:	00005517          	auipc	a0,0x5
    800038e4:	ea050513          	addi	a0,a0,-352 # 80008780 <syscalls+0x158>
    800038e8:	ffffd097          	auipc	ra,0xffffd
    800038ec:	c42080e7          	jalr	-958(ra) # 8000052a <panic>

00000000800038f0 <iinit>:
{
    800038f0:	7179                	addi	sp,sp,-48
    800038f2:	f406                	sd	ra,40(sp)
    800038f4:	f022                	sd	s0,32(sp)
    800038f6:	ec26                	sd	s1,24(sp)
    800038f8:	e84a                	sd	s2,16(sp)
    800038fa:	e44e                	sd	s3,8(sp)
    800038fc:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800038fe:	00005597          	auipc	a1,0x5
    80003902:	e9a58593          	addi	a1,a1,-358 # 80008798 <syscalls+0x170>
    80003906:	0001c517          	auipc	a0,0x1c
    8000390a:	6da50513          	addi	a0,a0,1754 # 8001ffe0 <itable>
    8000390e:	ffffd097          	auipc	ra,0xffffd
    80003912:	224080e7          	jalr	548(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003916:	0001c497          	auipc	s1,0x1c
    8000391a:	6f248493          	addi	s1,s1,1778 # 80020008 <itable+0x28>
    8000391e:	0001e997          	auipc	s3,0x1e
    80003922:	17a98993          	addi	s3,s3,378 # 80021a98 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003926:	00005917          	auipc	s2,0x5
    8000392a:	e7a90913          	addi	s2,s2,-390 # 800087a0 <syscalls+0x178>
    8000392e:	85ca                	mv	a1,s2
    80003930:	8526                	mv	a0,s1
    80003932:	00001097          	auipc	ra,0x1
    80003936:	e4a080e7          	jalr	-438(ra) # 8000477c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000393a:	08848493          	addi	s1,s1,136
    8000393e:	ff3498e3          	bne	s1,s3,8000392e <iinit+0x3e>
}
    80003942:	70a2                	ld	ra,40(sp)
    80003944:	7402                	ld	s0,32(sp)
    80003946:	64e2                	ld	s1,24(sp)
    80003948:	6942                	ld	s2,16(sp)
    8000394a:	69a2                	ld	s3,8(sp)
    8000394c:	6145                	addi	sp,sp,48
    8000394e:	8082                	ret

0000000080003950 <ialloc>:
{
    80003950:	715d                	addi	sp,sp,-80
    80003952:	e486                	sd	ra,72(sp)
    80003954:	e0a2                	sd	s0,64(sp)
    80003956:	fc26                	sd	s1,56(sp)
    80003958:	f84a                	sd	s2,48(sp)
    8000395a:	f44e                	sd	s3,40(sp)
    8000395c:	f052                	sd	s4,32(sp)
    8000395e:	ec56                	sd	s5,24(sp)
    80003960:	e85a                	sd	s6,16(sp)
    80003962:	e45e                	sd	s7,8(sp)
    80003964:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003966:	0001c717          	auipc	a4,0x1c
    8000396a:	66672703          	lw	a4,1638(a4) # 8001ffcc <sb+0xc>
    8000396e:	4785                	li	a5,1
    80003970:	04e7fa63          	bgeu	a5,a4,800039c4 <ialloc+0x74>
    80003974:	8aaa                	mv	s5,a0
    80003976:	8bae                	mv	s7,a1
    80003978:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000397a:	0001ca17          	auipc	s4,0x1c
    8000397e:	646a0a13          	addi	s4,s4,1606 # 8001ffc0 <sb>
    80003982:	00048b1b          	sext.w	s6,s1
    80003986:	0044d793          	srli	a5,s1,0x4
    8000398a:	018a2583          	lw	a1,24(s4)
    8000398e:	9dbd                	addw	a1,a1,a5
    80003990:	8556                	mv	a0,s5
    80003992:	00000097          	auipc	ra,0x0
    80003996:	952080e7          	jalr	-1710(ra) # 800032e4 <bread>
    8000399a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000399c:	05850993          	addi	s3,a0,88
    800039a0:	00f4f793          	andi	a5,s1,15
    800039a4:	079a                	slli	a5,a5,0x6
    800039a6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800039a8:	00099783          	lh	a5,0(s3)
    800039ac:	c785                	beqz	a5,800039d4 <ialloc+0x84>
    brelse(bp);
    800039ae:	00000097          	auipc	ra,0x0
    800039b2:	a66080e7          	jalr	-1434(ra) # 80003414 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800039b6:	0485                	addi	s1,s1,1
    800039b8:	00ca2703          	lw	a4,12(s4)
    800039bc:	0004879b          	sext.w	a5,s1
    800039c0:	fce7e1e3          	bltu	a5,a4,80003982 <ialloc+0x32>
  panic("ialloc: no inodes");
    800039c4:	00005517          	auipc	a0,0x5
    800039c8:	de450513          	addi	a0,a0,-540 # 800087a8 <syscalls+0x180>
    800039cc:	ffffd097          	auipc	ra,0xffffd
    800039d0:	b5e080e7          	jalr	-1186(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    800039d4:	04000613          	li	a2,64
    800039d8:	4581                	li	a1,0
    800039da:	854e                	mv	a0,s3
    800039dc:	ffffd097          	auipc	ra,0xffffd
    800039e0:	2e2080e7          	jalr	738(ra) # 80000cbe <memset>
      dip->type = type;
    800039e4:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800039e8:	854a                	mv	a0,s2
    800039ea:	00001097          	auipc	ra,0x1
    800039ee:	cac080e7          	jalr	-852(ra) # 80004696 <log_write>
      brelse(bp);
    800039f2:	854a                	mv	a0,s2
    800039f4:	00000097          	auipc	ra,0x0
    800039f8:	a20080e7          	jalr	-1504(ra) # 80003414 <brelse>
      return iget(dev, inum);
    800039fc:	85da                	mv	a1,s6
    800039fe:	8556                	mv	a0,s5
    80003a00:	00000097          	auipc	ra,0x0
    80003a04:	db4080e7          	jalr	-588(ra) # 800037b4 <iget>
}
    80003a08:	60a6                	ld	ra,72(sp)
    80003a0a:	6406                	ld	s0,64(sp)
    80003a0c:	74e2                	ld	s1,56(sp)
    80003a0e:	7942                	ld	s2,48(sp)
    80003a10:	79a2                	ld	s3,40(sp)
    80003a12:	7a02                	ld	s4,32(sp)
    80003a14:	6ae2                	ld	s5,24(sp)
    80003a16:	6b42                	ld	s6,16(sp)
    80003a18:	6ba2                	ld	s7,8(sp)
    80003a1a:	6161                	addi	sp,sp,80
    80003a1c:	8082                	ret

0000000080003a1e <iupdate>:
{
    80003a1e:	1101                	addi	sp,sp,-32
    80003a20:	ec06                	sd	ra,24(sp)
    80003a22:	e822                	sd	s0,16(sp)
    80003a24:	e426                	sd	s1,8(sp)
    80003a26:	e04a                	sd	s2,0(sp)
    80003a28:	1000                	addi	s0,sp,32
    80003a2a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a2c:	415c                	lw	a5,4(a0)
    80003a2e:	0047d79b          	srliw	a5,a5,0x4
    80003a32:	0001c597          	auipc	a1,0x1c
    80003a36:	5a65a583          	lw	a1,1446(a1) # 8001ffd8 <sb+0x18>
    80003a3a:	9dbd                	addw	a1,a1,a5
    80003a3c:	4108                	lw	a0,0(a0)
    80003a3e:	00000097          	auipc	ra,0x0
    80003a42:	8a6080e7          	jalr	-1882(ra) # 800032e4 <bread>
    80003a46:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a48:	05850793          	addi	a5,a0,88
    80003a4c:	40c8                	lw	a0,4(s1)
    80003a4e:	893d                	andi	a0,a0,15
    80003a50:	051a                	slli	a0,a0,0x6
    80003a52:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003a54:	04449703          	lh	a4,68(s1)
    80003a58:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003a5c:	04649703          	lh	a4,70(s1)
    80003a60:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003a64:	04849703          	lh	a4,72(s1)
    80003a68:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003a6c:	04a49703          	lh	a4,74(s1)
    80003a70:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003a74:	44f8                	lw	a4,76(s1)
    80003a76:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003a78:	03400613          	li	a2,52
    80003a7c:	05048593          	addi	a1,s1,80
    80003a80:	0531                	addi	a0,a0,12
    80003a82:	ffffd097          	auipc	ra,0xffffd
    80003a86:	298080e7          	jalr	664(ra) # 80000d1a <memmove>
  log_write(bp);
    80003a8a:	854a                	mv	a0,s2
    80003a8c:	00001097          	auipc	ra,0x1
    80003a90:	c0a080e7          	jalr	-1014(ra) # 80004696 <log_write>
  brelse(bp);
    80003a94:	854a                	mv	a0,s2
    80003a96:	00000097          	auipc	ra,0x0
    80003a9a:	97e080e7          	jalr	-1666(ra) # 80003414 <brelse>
}
    80003a9e:	60e2                	ld	ra,24(sp)
    80003aa0:	6442                	ld	s0,16(sp)
    80003aa2:	64a2                	ld	s1,8(sp)
    80003aa4:	6902                	ld	s2,0(sp)
    80003aa6:	6105                	addi	sp,sp,32
    80003aa8:	8082                	ret

0000000080003aaa <idup>:
{
    80003aaa:	1101                	addi	sp,sp,-32
    80003aac:	ec06                	sd	ra,24(sp)
    80003aae:	e822                	sd	s0,16(sp)
    80003ab0:	e426                	sd	s1,8(sp)
    80003ab2:	1000                	addi	s0,sp,32
    80003ab4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ab6:	0001c517          	auipc	a0,0x1c
    80003aba:	52a50513          	addi	a0,a0,1322 # 8001ffe0 <itable>
    80003abe:	ffffd097          	auipc	ra,0xffffd
    80003ac2:	104080e7          	jalr	260(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003ac6:	449c                	lw	a5,8(s1)
    80003ac8:	2785                	addiw	a5,a5,1
    80003aca:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003acc:	0001c517          	auipc	a0,0x1c
    80003ad0:	51450513          	addi	a0,a0,1300 # 8001ffe0 <itable>
    80003ad4:	ffffd097          	auipc	ra,0xffffd
    80003ad8:	1a2080e7          	jalr	418(ra) # 80000c76 <release>
}
    80003adc:	8526                	mv	a0,s1
    80003ade:	60e2                	ld	ra,24(sp)
    80003ae0:	6442                	ld	s0,16(sp)
    80003ae2:	64a2                	ld	s1,8(sp)
    80003ae4:	6105                	addi	sp,sp,32
    80003ae6:	8082                	ret

0000000080003ae8 <ilock>:
{
    80003ae8:	1101                	addi	sp,sp,-32
    80003aea:	ec06                	sd	ra,24(sp)
    80003aec:	e822                	sd	s0,16(sp)
    80003aee:	e426                	sd	s1,8(sp)
    80003af0:	e04a                	sd	s2,0(sp)
    80003af2:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003af4:	c115                	beqz	a0,80003b18 <ilock+0x30>
    80003af6:	84aa                	mv	s1,a0
    80003af8:	451c                	lw	a5,8(a0)
    80003afa:	00f05f63          	blez	a5,80003b18 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003afe:	0541                	addi	a0,a0,16
    80003b00:	00001097          	auipc	ra,0x1
    80003b04:	cb6080e7          	jalr	-842(ra) # 800047b6 <acquiresleep>
  if(ip->valid == 0){
    80003b08:	40bc                	lw	a5,64(s1)
    80003b0a:	cf99                	beqz	a5,80003b28 <ilock+0x40>
}
    80003b0c:	60e2                	ld	ra,24(sp)
    80003b0e:	6442                	ld	s0,16(sp)
    80003b10:	64a2                	ld	s1,8(sp)
    80003b12:	6902                	ld	s2,0(sp)
    80003b14:	6105                	addi	sp,sp,32
    80003b16:	8082                	ret
    panic("ilock");
    80003b18:	00005517          	auipc	a0,0x5
    80003b1c:	ca850513          	addi	a0,a0,-856 # 800087c0 <syscalls+0x198>
    80003b20:	ffffd097          	auipc	ra,0xffffd
    80003b24:	a0a080e7          	jalr	-1526(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b28:	40dc                	lw	a5,4(s1)
    80003b2a:	0047d79b          	srliw	a5,a5,0x4
    80003b2e:	0001c597          	auipc	a1,0x1c
    80003b32:	4aa5a583          	lw	a1,1194(a1) # 8001ffd8 <sb+0x18>
    80003b36:	9dbd                	addw	a1,a1,a5
    80003b38:	4088                	lw	a0,0(s1)
    80003b3a:	fffff097          	auipc	ra,0xfffff
    80003b3e:	7aa080e7          	jalr	1962(ra) # 800032e4 <bread>
    80003b42:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b44:	05850593          	addi	a1,a0,88
    80003b48:	40dc                	lw	a5,4(s1)
    80003b4a:	8bbd                	andi	a5,a5,15
    80003b4c:	079a                	slli	a5,a5,0x6
    80003b4e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003b50:	00059783          	lh	a5,0(a1)
    80003b54:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003b58:	00259783          	lh	a5,2(a1)
    80003b5c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003b60:	00459783          	lh	a5,4(a1)
    80003b64:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003b68:	00659783          	lh	a5,6(a1)
    80003b6c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003b70:	459c                	lw	a5,8(a1)
    80003b72:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003b74:	03400613          	li	a2,52
    80003b78:	05b1                	addi	a1,a1,12
    80003b7a:	05048513          	addi	a0,s1,80
    80003b7e:	ffffd097          	auipc	ra,0xffffd
    80003b82:	19c080e7          	jalr	412(ra) # 80000d1a <memmove>
    brelse(bp);
    80003b86:	854a                	mv	a0,s2
    80003b88:	00000097          	auipc	ra,0x0
    80003b8c:	88c080e7          	jalr	-1908(ra) # 80003414 <brelse>
    ip->valid = 1;
    80003b90:	4785                	li	a5,1
    80003b92:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003b94:	04449783          	lh	a5,68(s1)
    80003b98:	fbb5                	bnez	a5,80003b0c <ilock+0x24>
      panic("ilock: no type");
    80003b9a:	00005517          	auipc	a0,0x5
    80003b9e:	c2e50513          	addi	a0,a0,-978 # 800087c8 <syscalls+0x1a0>
    80003ba2:	ffffd097          	auipc	ra,0xffffd
    80003ba6:	988080e7          	jalr	-1656(ra) # 8000052a <panic>

0000000080003baa <iunlock>:
{
    80003baa:	1101                	addi	sp,sp,-32
    80003bac:	ec06                	sd	ra,24(sp)
    80003bae:	e822                	sd	s0,16(sp)
    80003bb0:	e426                	sd	s1,8(sp)
    80003bb2:	e04a                	sd	s2,0(sp)
    80003bb4:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003bb6:	c905                	beqz	a0,80003be6 <iunlock+0x3c>
    80003bb8:	84aa                	mv	s1,a0
    80003bba:	01050913          	addi	s2,a0,16
    80003bbe:	854a                	mv	a0,s2
    80003bc0:	00001097          	auipc	ra,0x1
    80003bc4:	c90080e7          	jalr	-880(ra) # 80004850 <holdingsleep>
    80003bc8:	cd19                	beqz	a0,80003be6 <iunlock+0x3c>
    80003bca:	449c                	lw	a5,8(s1)
    80003bcc:	00f05d63          	blez	a5,80003be6 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003bd0:	854a                	mv	a0,s2
    80003bd2:	00001097          	auipc	ra,0x1
    80003bd6:	c3a080e7          	jalr	-966(ra) # 8000480c <releasesleep>
}
    80003bda:	60e2                	ld	ra,24(sp)
    80003bdc:	6442                	ld	s0,16(sp)
    80003bde:	64a2                	ld	s1,8(sp)
    80003be0:	6902                	ld	s2,0(sp)
    80003be2:	6105                	addi	sp,sp,32
    80003be4:	8082                	ret
    panic("iunlock");
    80003be6:	00005517          	auipc	a0,0x5
    80003bea:	bf250513          	addi	a0,a0,-1038 # 800087d8 <syscalls+0x1b0>
    80003bee:	ffffd097          	auipc	ra,0xffffd
    80003bf2:	93c080e7          	jalr	-1732(ra) # 8000052a <panic>

0000000080003bf6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003bf6:	7179                	addi	sp,sp,-48
    80003bf8:	f406                	sd	ra,40(sp)
    80003bfa:	f022                	sd	s0,32(sp)
    80003bfc:	ec26                	sd	s1,24(sp)
    80003bfe:	e84a                	sd	s2,16(sp)
    80003c00:	e44e                	sd	s3,8(sp)
    80003c02:	e052                	sd	s4,0(sp)
    80003c04:	1800                	addi	s0,sp,48
    80003c06:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003c08:	05050493          	addi	s1,a0,80
    80003c0c:	08050913          	addi	s2,a0,128
    80003c10:	a021                	j	80003c18 <itrunc+0x22>
    80003c12:	0491                	addi	s1,s1,4
    80003c14:	01248d63          	beq	s1,s2,80003c2e <itrunc+0x38>
    if(ip->addrs[i]){
    80003c18:	408c                	lw	a1,0(s1)
    80003c1a:	dde5                	beqz	a1,80003c12 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003c1c:	0009a503          	lw	a0,0(s3)
    80003c20:	00000097          	auipc	ra,0x0
    80003c24:	90a080e7          	jalr	-1782(ra) # 8000352a <bfree>
      ip->addrs[i] = 0;
    80003c28:	0004a023          	sw	zero,0(s1)
    80003c2c:	b7dd                	j	80003c12 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003c2e:	0809a583          	lw	a1,128(s3)
    80003c32:	e185                	bnez	a1,80003c52 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c34:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003c38:	854e                	mv	a0,s3
    80003c3a:	00000097          	auipc	ra,0x0
    80003c3e:	de4080e7          	jalr	-540(ra) # 80003a1e <iupdate>
}
    80003c42:	70a2                	ld	ra,40(sp)
    80003c44:	7402                	ld	s0,32(sp)
    80003c46:	64e2                	ld	s1,24(sp)
    80003c48:	6942                	ld	s2,16(sp)
    80003c4a:	69a2                	ld	s3,8(sp)
    80003c4c:	6a02                	ld	s4,0(sp)
    80003c4e:	6145                	addi	sp,sp,48
    80003c50:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c52:	0009a503          	lw	a0,0(s3)
    80003c56:	fffff097          	auipc	ra,0xfffff
    80003c5a:	68e080e7          	jalr	1678(ra) # 800032e4 <bread>
    80003c5e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003c60:	05850493          	addi	s1,a0,88
    80003c64:	45850913          	addi	s2,a0,1112
    80003c68:	a021                	j	80003c70 <itrunc+0x7a>
    80003c6a:	0491                	addi	s1,s1,4
    80003c6c:	01248b63          	beq	s1,s2,80003c82 <itrunc+0x8c>
      if(a[j])
    80003c70:	408c                	lw	a1,0(s1)
    80003c72:	dde5                	beqz	a1,80003c6a <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003c74:	0009a503          	lw	a0,0(s3)
    80003c78:	00000097          	auipc	ra,0x0
    80003c7c:	8b2080e7          	jalr	-1870(ra) # 8000352a <bfree>
    80003c80:	b7ed                	j	80003c6a <itrunc+0x74>
    brelse(bp);
    80003c82:	8552                	mv	a0,s4
    80003c84:	fffff097          	auipc	ra,0xfffff
    80003c88:	790080e7          	jalr	1936(ra) # 80003414 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003c8c:	0809a583          	lw	a1,128(s3)
    80003c90:	0009a503          	lw	a0,0(s3)
    80003c94:	00000097          	auipc	ra,0x0
    80003c98:	896080e7          	jalr	-1898(ra) # 8000352a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003c9c:	0809a023          	sw	zero,128(s3)
    80003ca0:	bf51                	j	80003c34 <itrunc+0x3e>

0000000080003ca2 <iput>:
{
    80003ca2:	1101                	addi	sp,sp,-32
    80003ca4:	ec06                	sd	ra,24(sp)
    80003ca6:	e822                	sd	s0,16(sp)
    80003ca8:	e426                	sd	s1,8(sp)
    80003caa:	e04a                	sd	s2,0(sp)
    80003cac:	1000                	addi	s0,sp,32
    80003cae:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003cb0:	0001c517          	auipc	a0,0x1c
    80003cb4:	33050513          	addi	a0,a0,816 # 8001ffe0 <itable>
    80003cb8:	ffffd097          	auipc	ra,0xffffd
    80003cbc:	f0a080e7          	jalr	-246(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003cc0:	4498                	lw	a4,8(s1)
    80003cc2:	4785                	li	a5,1
    80003cc4:	02f70363          	beq	a4,a5,80003cea <iput+0x48>
  ip->ref--;
    80003cc8:	449c                	lw	a5,8(s1)
    80003cca:	37fd                	addiw	a5,a5,-1
    80003ccc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003cce:	0001c517          	auipc	a0,0x1c
    80003cd2:	31250513          	addi	a0,a0,786 # 8001ffe0 <itable>
    80003cd6:	ffffd097          	auipc	ra,0xffffd
    80003cda:	fa0080e7          	jalr	-96(ra) # 80000c76 <release>
}
    80003cde:	60e2                	ld	ra,24(sp)
    80003ce0:	6442                	ld	s0,16(sp)
    80003ce2:	64a2                	ld	s1,8(sp)
    80003ce4:	6902                	ld	s2,0(sp)
    80003ce6:	6105                	addi	sp,sp,32
    80003ce8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003cea:	40bc                	lw	a5,64(s1)
    80003cec:	dff1                	beqz	a5,80003cc8 <iput+0x26>
    80003cee:	04a49783          	lh	a5,74(s1)
    80003cf2:	fbf9                	bnez	a5,80003cc8 <iput+0x26>
    acquiresleep(&ip->lock);
    80003cf4:	01048913          	addi	s2,s1,16
    80003cf8:	854a                	mv	a0,s2
    80003cfa:	00001097          	auipc	ra,0x1
    80003cfe:	abc080e7          	jalr	-1348(ra) # 800047b6 <acquiresleep>
    release(&itable.lock);
    80003d02:	0001c517          	auipc	a0,0x1c
    80003d06:	2de50513          	addi	a0,a0,734 # 8001ffe0 <itable>
    80003d0a:	ffffd097          	auipc	ra,0xffffd
    80003d0e:	f6c080e7          	jalr	-148(ra) # 80000c76 <release>
    itrunc(ip);
    80003d12:	8526                	mv	a0,s1
    80003d14:	00000097          	auipc	ra,0x0
    80003d18:	ee2080e7          	jalr	-286(ra) # 80003bf6 <itrunc>
    ip->type = 0;
    80003d1c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003d20:	8526                	mv	a0,s1
    80003d22:	00000097          	auipc	ra,0x0
    80003d26:	cfc080e7          	jalr	-772(ra) # 80003a1e <iupdate>
    ip->valid = 0;
    80003d2a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003d2e:	854a                	mv	a0,s2
    80003d30:	00001097          	auipc	ra,0x1
    80003d34:	adc080e7          	jalr	-1316(ra) # 8000480c <releasesleep>
    acquire(&itable.lock);
    80003d38:	0001c517          	auipc	a0,0x1c
    80003d3c:	2a850513          	addi	a0,a0,680 # 8001ffe0 <itable>
    80003d40:	ffffd097          	auipc	ra,0xffffd
    80003d44:	e82080e7          	jalr	-382(ra) # 80000bc2 <acquire>
    80003d48:	b741                	j	80003cc8 <iput+0x26>

0000000080003d4a <iunlockput>:
{
    80003d4a:	1101                	addi	sp,sp,-32
    80003d4c:	ec06                	sd	ra,24(sp)
    80003d4e:	e822                	sd	s0,16(sp)
    80003d50:	e426                	sd	s1,8(sp)
    80003d52:	1000                	addi	s0,sp,32
    80003d54:	84aa                	mv	s1,a0
  iunlock(ip);
    80003d56:	00000097          	auipc	ra,0x0
    80003d5a:	e54080e7          	jalr	-428(ra) # 80003baa <iunlock>
  iput(ip);
    80003d5e:	8526                	mv	a0,s1
    80003d60:	00000097          	auipc	ra,0x0
    80003d64:	f42080e7          	jalr	-190(ra) # 80003ca2 <iput>
}
    80003d68:	60e2                	ld	ra,24(sp)
    80003d6a:	6442                	ld	s0,16(sp)
    80003d6c:	64a2                	ld	s1,8(sp)
    80003d6e:	6105                	addi	sp,sp,32
    80003d70:	8082                	ret

0000000080003d72 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003d72:	1141                	addi	sp,sp,-16
    80003d74:	e422                	sd	s0,8(sp)
    80003d76:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d78:	411c                	lw	a5,0(a0)
    80003d7a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d7c:	415c                	lw	a5,4(a0)
    80003d7e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d80:	04451783          	lh	a5,68(a0)
    80003d84:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d88:	04a51783          	lh	a5,74(a0)
    80003d8c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d90:	04c56783          	lwu	a5,76(a0)
    80003d94:	e99c                	sd	a5,16(a1)
}
    80003d96:	6422                	ld	s0,8(sp)
    80003d98:	0141                	addi	sp,sp,16
    80003d9a:	8082                	ret

0000000080003d9c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d9c:	457c                	lw	a5,76(a0)
    80003d9e:	0ed7e963          	bltu	a5,a3,80003e90 <readi+0xf4>
{
    80003da2:	7159                	addi	sp,sp,-112
    80003da4:	f486                	sd	ra,104(sp)
    80003da6:	f0a2                	sd	s0,96(sp)
    80003da8:	eca6                	sd	s1,88(sp)
    80003daa:	e8ca                	sd	s2,80(sp)
    80003dac:	e4ce                	sd	s3,72(sp)
    80003dae:	e0d2                	sd	s4,64(sp)
    80003db0:	fc56                	sd	s5,56(sp)
    80003db2:	f85a                	sd	s6,48(sp)
    80003db4:	f45e                	sd	s7,40(sp)
    80003db6:	f062                	sd	s8,32(sp)
    80003db8:	ec66                	sd	s9,24(sp)
    80003dba:	e86a                	sd	s10,16(sp)
    80003dbc:	e46e                	sd	s11,8(sp)
    80003dbe:	1880                	addi	s0,sp,112
    80003dc0:	8baa                	mv	s7,a0
    80003dc2:	8c2e                	mv	s8,a1
    80003dc4:	8ab2                	mv	s5,a2
    80003dc6:	84b6                	mv	s1,a3
    80003dc8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003dca:	9f35                	addw	a4,a4,a3
    return 0;
    80003dcc:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003dce:	0ad76063          	bltu	a4,a3,80003e6e <readi+0xd2>
  if(off + n > ip->size)
    80003dd2:	00e7f463          	bgeu	a5,a4,80003dda <readi+0x3e>
    n = ip->size - off;
    80003dd6:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dda:	0a0b0963          	beqz	s6,80003e8c <readi+0xf0>
    80003dde:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003de0:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003de4:	5cfd                	li	s9,-1
    80003de6:	a82d                	j	80003e20 <readi+0x84>
    80003de8:	020a1d93          	slli	s11,s4,0x20
    80003dec:	020ddd93          	srli	s11,s11,0x20
    80003df0:	05890793          	addi	a5,s2,88
    80003df4:	86ee                	mv	a3,s11
    80003df6:	963e                	add	a2,a2,a5
    80003df8:	85d6                	mv	a1,s5
    80003dfa:	8562                	mv	a0,s8
    80003dfc:	ffffe097          	auipc	ra,0xffffe
    80003e00:	6ae080e7          	jalr	1710(ra) # 800024aa <either_copyout>
    80003e04:	05950d63          	beq	a0,s9,80003e5e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e08:	854a                	mv	a0,s2
    80003e0a:	fffff097          	auipc	ra,0xfffff
    80003e0e:	60a080e7          	jalr	1546(ra) # 80003414 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e12:	013a09bb          	addw	s3,s4,s3
    80003e16:	009a04bb          	addw	s1,s4,s1
    80003e1a:	9aee                	add	s5,s5,s11
    80003e1c:	0569f763          	bgeu	s3,s6,80003e6a <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003e20:	000ba903          	lw	s2,0(s7)
    80003e24:	00a4d59b          	srliw	a1,s1,0xa
    80003e28:	855e                	mv	a0,s7
    80003e2a:	00000097          	auipc	ra,0x0
    80003e2e:	8ae080e7          	jalr	-1874(ra) # 800036d8 <bmap>
    80003e32:	0005059b          	sext.w	a1,a0
    80003e36:	854a                	mv	a0,s2
    80003e38:	fffff097          	auipc	ra,0xfffff
    80003e3c:	4ac080e7          	jalr	1196(ra) # 800032e4 <bread>
    80003e40:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e42:	3ff4f613          	andi	a2,s1,1023
    80003e46:	40cd07bb          	subw	a5,s10,a2
    80003e4a:	413b073b          	subw	a4,s6,s3
    80003e4e:	8a3e                	mv	s4,a5
    80003e50:	2781                	sext.w	a5,a5
    80003e52:	0007069b          	sext.w	a3,a4
    80003e56:	f8f6f9e3          	bgeu	a3,a5,80003de8 <readi+0x4c>
    80003e5a:	8a3a                	mv	s4,a4
    80003e5c:	b771                	j	80003de8 <readi+0x4c>
      brelse(bp);
    80003e5e:	854a                	mv	a0,s2
    80003e60:	fffff097          	auipc	ra,0xfffff
    80003e64:	5b4080e7          	jalr	1460(ra) # 80003414 <brelse>
      tot = -1;
    80003e68:	59fd                	li	s3,-1
  }
  return tot;
    80003e6a:	0009851b          	sext.w	a0,s3
}
    80003e6e:	70a6                	ld	ra,104(sp)
    80003e70:	7406                	ld	s0,96(sp)
    80003e72:	64e6                	ld	s1,88(sp)
    80003e74:	6946                	ld	s2,80(sp)
    80003e76:	69a6                	ld	s3,72(sp)
    80003e78:	6a06                	ld	s4,64(sp)
    80003e7a:	7ae2                	ld	s5,56(sp)
    80003e7c:	7b42                	ld	s6,48(sp)
    80003e7e:	7ba2                	ld	s7,40(sp)
    80003e80:	7c02                	ld	s8,32(sp)
    80003e82:	6ce2                	ld	s9,24(sp)
    80003e84:	6d42                	ld	s10,16(sp)
    80003e86:	6da2                	ld	s11,8(sp)
    80003e88:	6165                	addi	sp,sp,112
    80003e8a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e8c:	89da                	mv	s3,s6
    80003e8e:	bff1                	j	80003e6a <readi+0xce>
    return 0;
    80003e90:	4501                	li	a0,0
}
    80003e92:	8082                	ret

0000000080003e94 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e94:	457c                	lw	a5,76(a0)
    80003e96:	10d7e863          	bltu	a5,a3,80003fa6 <writei+0x112>
{
    80003e9a:	7159                	addi	sp,sp,-112
    80003e9c:	f486                	sd	ra,104(sp)
    80003e9e:	f0a2                	sd	s0,96(sp)
    80003ea0:	eca6                	sd	s1,88(sp)
    80003ea2:	e8ca                	sd	s2,80(sp)
    80003ea4:	e4ce                	sd	s3,72(sp)
    80003ea6:	e0d2                	sd	s4,64(sp)
    80003ea8:	fc56                	sd	s5,56(sp)
    80003eaa:	f85a                	sd	s6,48(sp)
    80003eac:	f45e                	sd	s7,40(sp)
    80003eae:	f062                	sd	s8,32(sp)
    80003eb0:	ec66                	sd	s9,24(sp)
    80003eb2:	e86a                	sd	s10,16(sp)
    80003eb4:	e46e                	sd	s11,8(sp)
    80003eb6:	1880                	addi	s0,sp,112
    80003eb8:	8b2a                	mv	s6,a0
    80003eba:	8c2e                	mv	s8,a1
    80003ebc:	8ab2                	mv	s5,a2
    80003ebe:	8936                	mv	s2,a3
    80003ec0:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003ec2:	00e687bb          	addw	a5,a3,a4
    80003ec6:	0ed7e263          	bltu	a5,a3,80003faa <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003eca:	00043737          	lui	a4,0x43
    80003ece:	0ef76063          	bltu	a4,a5,80003fae <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ed2:	0c0b8863          	beqz	s7,80003fa2 <writei+0x10e>
    80003ed6:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ed8:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003edc:	5cfd                	li	s9,-1
    80003ede:	a091                	j	80003f22 <writei+0x8e>
    80003ee0:	02099d93          	slli	s11,s3,0x20
    80003ee4:	020ddd93          	srli	s11,s11,0x20
    80003ee8:	05848793          	addi	a5,s1,88
    80003eec:	86ee                	mv	a3,s11
    80003eee:	8656                	mv	a2,s5
    80003ef0:	85e2                	mv	a1,s8
    80003ef2:	953e                	add	a0,a0,a5
    80003ef4:	ffffe097          	auipc	ra,0xffffe
    80003ef8:	60c080e7          	jalr	1548(ra) # 80002500 <either_copyin>
    80003efc:	07950263          	beq	a0,s9,80003f60 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003f00:	8526                	mv	a0,s1
    80003f02:	00000097          	auipc	ra,0x0
    80003f06:	794080e7          	jalr	1940(ra) # 80004696 <log_write>
    brelse(bp);
    80003f0a:	8526                	mv	a0,s1
    80003f0c:	fffff097          	auipc	ra,0xfffff
    80003f10:	508080e7          	jalr	1288(ra) # 80003414 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f14:	01498a3b          	addw	s4,s3,s4
    80003f18:	0129893b          	addw	s2,s3,s2
    80003f1c:	9aee                	add	s5,s5,s11
    80003f1e:	057a7663          	bgeu	s4,s7,80003f6a <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003f22:	000b2483          	lw	s1,0(s6)
    80003f26:	00a9559b          	srliw	a1,s2,0xa
    80003f2a:	855a                	mv	a0,s6
    80003f2c:	fffff097          	auipc	ra,0xfffff
    80003f30:	7ac080e7          	jalr	1964(ra) # 800036d8 <bmap>
    80003f34:	0005059b          	sext.w	a1,a0
    80003f38:	8526                	mv	a0,s1
    80003f3a:	fffff097          	auipc	ra,0xfffff
    80003f3e:	3aa080e7          	jalr	938(ra) # 800032e4 <bread>
    80003f42:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f44:	3ff97513          	andi	a0,s2,1023
    80003f48:	40ad07bb          	subw	a5,s10,a0
    80003f4c:	414b873b          	subw	a4,s7,s4
    80003f50:	89be                	mv	s3,a5
    80003f52:	2781                	sext.w	a5,a5
    80003f54:	0007069b          	sext.w	a3,a4
    80003f58:	f8f6f4e3          	bgeu	a3,a5,80003ee0 <writei+0x4c>
    80003f5c:	89ba                	mv	s3,a4
    80003f5e:	b749                	j	80003ee0 <writei+0x4c>
      brelse(bp);
    80003f60:	8526                	mv	a0,s1
    80003f62:	fffff097          	auipc	ra,0xfffff
    80003f66:	4b2080e7          	jalr	1202(ra) # 80003414 <brelse>
  }

  if(off > ip->size)
    80003f6a:	04cb2783          	lw	a5,76(s6)
    80003f6e:	0127f463          	bgeu	a5,s2,80003f76 <writei+0xe2>
    ip->size = off;
    80003f72:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003f76:	855a                	mv	a0,s6
    80003f78:	00000097          	auipc	ra,0x0
    80003f7c:	aa6080e7          	jalr	-1370(ra) # 80003a1e <iupdate>

  return tot;
    80003f80:	000a051b          	sext.w	a0,s4
}
    80003f84:	70a6                	ld	ra,104(sp)
    80003f86:	7406                	ld	s0,96(sp)
    80003f88:	64e6                	ld	s1,88(sp)
    80003f8a:	6946                	ld	s2,80(sp)
    80003f8c:	69a6                	ld	s3,72(sp)
    80003f8e:	6a06                	ld	s4,64(sp)
    80003f90:	7ae2                	ld	s5,56(sp)
    80003f92:	7b42                	ld	s6,48(sp)
    80003f94:	7ba2                	ld	s7,40(sp)
    80003f96:	7c02                	ld	s8,32(sp)
    80003f98:	6ce2                	ld	s9,24(sp)
    80003f9a:	6d42                	ld	s10,16(sp)
    80003f9c:	6da2                	ld	s11,8(sp)
    80003f9e:	6165                	addi	sp,sp,112
    80003fa0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fa2:	8a5e                	mv	s4,s7
    80003fa4:	bfc9                	j	80003f76 <writei+0xe2>
    return -1;
    80003fa6:	557d                	li	a0,-1
}
    80003fa8:	8082                	ret
    return -1;
    80003faa:	557d                	li	a0,-1
    80003fac:	bfe1                	j	80003f84 <writei+0xf0>
    return -1;
    80003fae:	557d                	li	a0,-1
    80003fb0:	bfd1                	j	80003f84 <writei+0xf0>

0000000080003fb2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003fb2:	1141                	addi	sp,sp,-16
    80003fb4:	e406                	sd	ra,8(sp)
    80003fb6:	e022                	sd	s0,0(sp)
    80003fb8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003fba:	4639                	li	a2,14
    80003fbc:	ffffd097          	auipc	ra,0xffffd
    80003fc0:	dda080e7          	jalr	-550(ra) # 80000d96 <strncmp>
}
    80003fc4:	60a2                	ld	ra,8(sp)
    80003fc6:	6402                	ld	s0,0(sp)
    80003fc8:	0141                	addi	sp,sp,16
    80003fca:	8082                	ret

0000000080003fcc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003fcc:	7139                	addi	sp,sp,-64
    80003fce:	fc06                	sd	ra,56(sp)
    80003fd0:	f822                	sd	s0,48(sp)
    80003fd2:	f426                	sd	s1,40(sp)
    80003fd4:	f04a                	sd	s2,32(sp)
    80003fd6:	ec4e                	sd	s3,24(sp)
    80003fd8:	e852                	sd	s4,16(sp)
    80003fda:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003fdc:	04451703          	lh	a4,68(a0)
    80003fe0:	4785                	li	a5,1
    80003fe2:	00f71a63          	bne	a4,a5,80003ff6 <dirlookup+0x2a>
    80003fe6:	892a                	mv	s2,a0
    80003fe8:	89ae                	mv	s3,a1
    80003fea:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fec:	457c                	lw	a5,76(a0)
    80003fee:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ff0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ff2:	e79d                	bnez	a5,80004020 <dirlookup+0x54>
    80003ff4:	a8a5                	j	8000406c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ff6:	00004517          	auipc	a0,0x4
    80003ffa:	7ea50513          	addi	a0,a0,2026 # 800087e0 <syscalls+0x1b8>
    80003ffe:	ffffc097          	auipc	ra,0xffffc
    80004002:	52c080e7          	jalr	1324(ra) # 8000052a <panic>
      panic("dirlookup read");
    80004006:	00004517          	auipc	a0,0x4
    8000400a:	7f250513          	addi	a0,a0,2034 # 800087f8 <syscalls+0x1d0>
    8000400e:	ffffc097          	auipc	ra,0xffffc
    80004012:	51c080e7          	jalr	1308(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004016:	24c1                	addiw	s1,s1,16
    80004018:	04c92783          	lw	a5,76(s2)
    8000401c:	04f4f763          	bgeu	s1,a5,8000406a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004020:	4741                	li	a4,16
    80004022:	86a6                	mv	a3,s1
    80004024:	fc040613          	addi	a2,s0,-64
    80004028:	4581                	li	a1,0
    8000402a:	854a                	mv	a0,s2
    8000402c:	00000097          	auipc	ra,0x0
    80004030:	d70080e7          	jalr	-656(ra) # 80003d9c <readi>
    80004034:	47c1                	li	a5,16
    80004036:	fcf518e3          	bne	a0,a5,80004006 <dirlookup+0x3a>
    if(de.inum == 0)
    8000403a:	fc045783          	lhu	a5,-64(s0)
    8000403e:	dfe1                	beqz	a5,80004016 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004040:	fc240593          	addi	a1,s0,-62
    80004044:	854e                	mv	a0,s3
    80004046:	00000097          	auipc	ra,0x0
    8000404a:	f6c080e7          	jalr	-148(ra) # 80003fb2 <namecmp>
    8000404e:	f561                	bnez	a0,80004016 <dirlookup+0x4a>
      if(poff)
    80004050:	000a0463          	beqz	s4,80004058 <dirlookup+0x8c>
        *poff = off;
    80004054:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004058:	fc045583          	lhu	a1,-64(s0)
    8000405c:	00092503          	lw	a0,0(s2)
    80004060:	fffff097          	auipc	ra,0xfffff
    80004064:	754080e7          	jalr	1876(ra) # 800037b4 <iget>
    80004068:	a011                	j	8000406c <dirlookup+0xa0>
  return 0;
    8000406a:	4501                	li	a0,0
}
    8000406c:	70e2                	ld	ra,56(sp)
    8000406e:	7442                	ld	s0,48(sp)
    80004070:	74a2                	ld	s1,40(sp)
    80004072:	7902                	ld	s2,32(sp)
    80004074:	69e2                	ld	s3,24(sp)
    80004076:	6a42                	ld	s4,16(sp)
    80004078:	6121                	addi	sp,sp,64
    8000407a:	8082                	ret

000000008000407c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000407c:	711d                	addi	sp,sp,-96
    8000407e:	ec86                	sd	ra,88(sp)
    80004080:	e8a2                	sd	s0,80(sp)
    80004082:	e4a6                	sd	s1,72(sp)
    80004084:	e0ca                	sd	s2,64(sp)
    80004086:	fc4e                	sd	s3,56(sp)
    80004088:	f852                	sd	s4,48(sp)
    8000408a:	f456                	sd	s5,40(sp)
    8000408c:	f05a                	sd	s6,32(sp)
    8000408e:	ec5e                	sd	s7,24(sp)
    80004090:	e862                	sd	s8,16(sp)
    80004092:	e466                	sd	s9,8(sp)
    80004094:	1080                	addi	s0,sp,96
    80004096:	84aa                	mv	s1,a0
    80004098:	8aae                	mv	s5,a1
    8000409a:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000409c:	00054703          	lbu	a4,0(a0)
    800040a0:	02f00793          	li	a5,47
    800040a4:	02f70363          	beq	a4,a5,800040ca <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800040a8:	ffffe097          	auipc	ra,0xffffe
    800040ac:	8ee080e7          	jalr	-1810(ra) # 80001996 <myproc>
    800040b0:	17053503          	ld	a0,368(a0)
    800040b4:	00000097          	auipc	ra,0x0
    800040b8:	9f6080e7          	jalr	-1546(ra) # 80003aaa <idup>
    800040bc:	89aa                	mv	s3,a0
  while(*path == '/')
    800040be:	02f00913          	li	s2,47
  len = path - s;
    800040c2:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800040c4:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800040c6:	4b85                	li	s7,1
    800040c8:	a865                	j	80004180 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800040ca:	4585                	li	a1,1
    800040cc:	4505                	li	a0,1
    800040ce:	fffff097          	auipc	ra,0xfffff
    800040d2:	6e6080e7          	jalr	1766(ra) # 800037b4 <iget>
    800040d6:	89aa                	mv	s3,a0
    800040d8:	b7dd                	j	800040be <namex+0x42>
      iunlockput(ip);
    800040da:	854e                	mv	a0,s3
    800040dc:	00000097          	auipc	ra,0x0
    800040e0:	c6e080e7          	jalr	-914(ra) # 80003d4a <iunlockput>
      return 0;
    800040e4:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800040e6:	854e                	mv	a0,s3
    800040e8:	60e6                	ld	ra,88(sp)
    800040ea:	6446                	ld	s0,80(sp)
    800040ec:	64a6                	ld	s1,72(sp)
    800040ee:	6906                	ld	s2,64(sp)
    800040f0:	79e2                	ld	s3,56(sp)
    800040f2:	7a42                	ld	s4,48(sp)
    800040f4:	7aa2                	ld	s5,40(sp)
    800040f6:	7b02                	ld	s6,32(sp)
    800040f8:	6be2                	ld	s7,24(sp)
    800040fa:	6c42                	ld	s8,16(sp)
    800040fc:	6ca2                	ld	s9,8(sp)
    800040fe:	6125                	addi	sp,sp,96
    80004100:	8082                	ret
      iunlock(ip);
    80004102:	854e                	mv	a0,s3
    80004104:	00000097          	auipc	ra,0x0
    80004108:	aa6080e7          	jalr	-1370(ra) # 80003baa <iunlock>
      return ip;
    8000410c:	bfe9                	j	800040e6 <namex+0x6a>
      iunlockput(ip);
    8000410e:	854e                	mv	a0,s3
    80004110:	00000097          	auipc	ra,0x0
    80004114:	c3a080e7          	jalr	-966(ra) # 80003d4a <iunlockput>
      return 0;
    80004118:	89e6                	mv	s3,s9
    8000411a:	b7f1                	j	800040e6 <namex+0x6a>
  len = path - s;
    8000411c:	40b48633          	sub	a2,s1,a1
    80004120:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004124:	099c5463          	bge	s8,s9,800041ac <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004128:	4639                	li	a2,14
    8000412a:	8552                	mv	a0,s4
    8000412c:	ffffd097          	auipc	ra,0xffffd
    80004130:	bee080e7          	jalr	-1042(ra) # 80000d1a <memmove>
  while(*path == '/')
    80004134:	0004c783          	lbu	a5,0(s1)
    80004138:	01279763          	bne	a5,s2,80004146 <namex+0xca>
    path++;
    8000413c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000413e:	0004c783          	lbu	a5,0(s1)
    80004142:	ff278de3          	beq	a5,s2,8000413c <namex+0xc0>
    ilock(ip);
    80004146:	854e                	mv	a0,s3
    80004148:	00000097          	auipc	ra,0x0
    8000414c:	9a0080e7          	jalr	-1632(ra) # 80003ae8 <ilock>
    if(ip->type != T_DIR){
    80004150:	04499783          	lh	a5,68(s3)
    80004154:	f97793e3          	bne	a5,s7,800040da <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004158:	000a8563          	beqz	s5,80004162 <namex+0xe6>
    8000415c:	0004c783          	lbu	a5,0(s1)
    80004160:	d3cd                	beqz	a5,80004102 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004162:	865a                	mv	a2,s6
    80004164:	85d2                	mv	a1,s4
    80004166:	854e                	mv	a0,s3
    80004168:	00000097          	auipc	ra,0x0
    8000416c:	e64080e7          	jalr	-412(ra) # 80003fcc <dirlookup>
    80004170:	8caa                	mv	s9,a0
    80004172:	dd51                	beqz	a0,8000410e <namex+0x92>
    iunlockput(ip);
    80004174:	854e                	mv	a0,s3
    80004176:	00000097          	auipc	ra,0x0
    8000417a:	bd4080e7          	jalr	-1068(ra) # 80003d4a <iunlockput>
    ip = next;
    8000417e:	89e6                	mv	s3,s9
  while(*path == '/')
    80004180:	0004c783          	lbu	a5,0(s1)
    80004184:	05279763          	bne	a5,s2,800041d2 <namex+0x156>
    path++;
    80004188:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000418a:	0004c783          	lbu	a5,0(s1)
    8000418e:	ff278de3          	beq	a5,s2,80004188 <namex+0x10c>
  if(*path == 0)
    80004192:	c79d                	beqz	a5,800041c0 <namex+0x144>
    path++;
    80004194:	85a6                	mv	a1,s1
  len = path - s;
    80004196:	8cda                	mv	s9,s6
    80004198:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    8000419a:	01278963          	beq	a5,s2,800041ac <namex+0x130>
    8000419e:	dfbd                	beqz	a5,8000411c <namex+0xa0>
    path++;
    800041a0:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800041a2:	0004c783          	lbu	a5,0(s1)
    800041a6:	ff279ce3          	bne	a5,s2,8000419e <namex+0x122>
    800041aa:	bf8d                	j	8000411c <namex+0xa0>
    memmove(name, s, len);
    800041ac:	2601                	sext.w	a2,a2
    800041ae:	8552                	mv	a0,s4
    800041b0:	ffffd097          	auipc	ra,0xffffd
    800041b4:	b6a080e7          	jalr	-1174(ra) # 80000d1a <memmove>
    name[len] = 0;
    800041b8:	9cd2                	add	s9,s9,s4
    800041ba:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800041be:	bf9d                	j	80004134 <namex+0xb8>
  if(nameiparent){
    800041c0:	f20a83e3          	beqz	s5,800040e6 <namex+0x6a>
    iput(ip);
    800041c4:	854e                	mv	a0,s3
    800041c6:	00000097          	auipc	ra,0x0
    800041ca:	adc080e7          	jalr	-1316(ra) # 80003ca2 <iput>
    return 0;
    800041ce:	4981                	li	s3,0
    800041d0:	bf19                	j	800040e6 <namex+0x6a>
  if(*path == 0)
    800041d2:	d7fd                	beqz	a5,800041c0 <namex+0x144>
  while(*path != '/' && *path != 0)
    800041d4:	0004c783          	lbu	a5,0(s1)
    800041d8:	85a6                	mv	a1,s1
    800041da:	b7d1                	j	8000419e <namex+0x122>

00000000800041dc <dirlink>:
{
    800041dc:	7139                	addi	sp,sp,-64
    800041de:	fc06                	sd	ra,56(sp)
    800041e0:	f822                	sd	s0,48(sp)
    800041e2:	f426                	sd	s1,40(sp)
    800041e4:	f04a                	sd	s2,32(sp)
    800041e6:	ec4e                	sd	s3,24(sp)
    800041e8:	e852                	sd	s4,16(sp)
    800041ea:	0080                	addi	s0,sp,64
    800041ec:	892a                	mv	s2,a0
    800041ee:	8a2e                	mv	s4,a1
    800041f0:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800041f2:	4601                	li	a2,0
    800041f4:	00000097          	auipc	ra,0x0
    800041f8:	dd8080e7          	jalr	-552(ra) # 80003fcc <dirlookup>
    800041fc:	e93d                	bnez	a0,80004272 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041fe:	04c92483          	lw	s1,76(s2)
    80004202:	c49d                	beqz	s1,80004230 <dirlink+0x54>
    80004204:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004206:	4741                	li	a4,16
    80004208:	86a6                	mv	a3,s1
    8000420a:	fc040613          	addi	a2,s0,-64
    8000420e:	4581                	li	a1,0
    80004210:	854a                	mv	a0,s2
    80004212:	00000097          	auipc	ra,0x0
    80004216:	b8a080e7          	jalr	-1142(ra) # 80003d9c <readi>
    8000421a:	47c1                	li	a5,16
    8000421c:	06f51163          	bne	a0,a5,8000427e <dirlink+0xa2>
    if(de.inum == 0)
    80004220:	fc045783          	lhu	a5,-64(s0)
    80004224:	c791                	beqz	a5,80004230 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004226:	24c1                	addiw	s1,s1,16
    80004228:	04c92783          	lw	a5,76(s2)
    8000422c:	fcf4ede3          	bltu	s1,a5,80004206 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004230:	4639                	li	a2,14
    80004232:	85d2                	mv	a1,s4
    80004234:	fc240513          	addi	a0,s0,-62
    80004238:	ffffd097          	auipc	ra,0xffffd
    8000423c:	b9a080e7          	jalr	-1126(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    80004240:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004244:	4741                	li	a4,16
    80004246:	86a6                	mv	a3,s1
    80004248:	fc040613          	addi	a2,s0,-64
    8000424c:	4581                	li	a1,0
    8000424e:	854a                	mv	a0,s2
    80004250:	00000097          	auipc	ra,0x0
    80004254:	c44080e7          	jalr	-956(ra) # 80003e94 <writei>
    80004258:	872a                	mv	a4,a0
    8000425a:	47c1                	li	a5,16
  return 0;
    8000425c:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000425e:	02f71863          	bne	a4,a5,8000428e <dirlink+0xb2>
}
    80004262:	70e2                	ld	ra,56(sp)
    80004264:	7442                	ld	s0,48(sp)
    80004266:	74a2                	ld	s1,40(sp)
    80004268:	7902                	ld	s2,32(sp)
    8000426a:	69e2                	ld	s3,24(sp)
    8000426c:	6a42                	ld	s4,16(sp)
    8000426e:	6121                	addi	sp,sp,64
    80004270:	8082                	ret
    iput(ip);
    80004272:	00000097          	auipc	ra,0x0
    80004276:	a30080e7          	jalr	-1488(ra) # 80003ca2 <iput>
    return -1;
    8000427a:	557d                	li	a0,-1
    8000427c:	b7dd                	j	80004262 <dirlink+0x86>
      panic("dirlink read");
    8000427e:	00004517          	auipc	a0,0x4
    80004282:	58a50513          	addi	a0,a0,1418 # 80008808 <syscalls+0x1e0>
    80004286:	ffffc097          	auipc	ra,0xffffc
    8000428a:	2a4080e7          	jalr	676(ra) # 8000052a <panic>
    panic("dirlink");
    8000428e:	00004517          	auipc	a0,0x4
    80004292:	68250513          	addi	a0,a0,1666 # 80008910 <syscalls+0x2e8>
    80004296:	ffffc097          	auipc	ra,0xffffc
    8000429a:	294080e7          	jalr	660(ra) # 8000052a <panic>

000000008000429e <namei>:

struct inode*
namei(char *path)
{
    8000429e:	1101                	addi	sp,sp,-32
    800042a0:	ec06                	sd	ra,24(sp)
    800042a2:	e822                	sd	s0,16(sp)
    800042a4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800042a6:	fe040613          	addi	a2,s0,-32
    800042aa:	4581                	li	a1,0
    800042ac:	00000097          	auipc	ra,0x0
    800042b0:	dd0080e7          	jalr	-560(ra) # 8000407c <namex>
}
    800042b4:	60e2                	ld	ra,24(sp)
    800042b6:	6442                	ld	s0,16(sp)
    800042b8:	6105                	addi	sp,sp,32
    800042ba:	8082                	ret

00000000800042bc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800042bc:	1141                	addi	sp,sp,-16
    800042be:	e406                	sd	ra,8(sp)
    800042c0:	e022                	sd	s0,0(sp)
    800042c2:	0800                	addi	s0,sp,16
    800042c4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800042c6:	4585                	li	a1,1
    800042c8:	00000097          	auipc	ra,0x0
    800042cc:	db4080e7          	jalr	-588(ra) # 8000407c <namex>
}
    800042d0:	60a2                	ld	ra,8(sp)
    800042d2:	6402                	ld	s0,0(sp)
    800042d4:	0141                	addi	sp,sp,16
    800042d6:	8082                	ret

00000000800042d8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800042d8:	1101                	addi	sp,sp,-32
    800042da:	ec06                	sd	ra,24(sp)
    800042dc:	e822                	sd	s0,16(sp)
    800042de:	e426                	sd	s1,8(sp)
    800042e0:	e04a                	sd	s2,0(sp)
    800042e2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800042e4:	0001d917          	auipc	s2,0x1d
    800042e8:	7a490913          	addi	s2,s2,1956 # 80021a88 <log>
    800042ec:	01892583          	lw	a1,24(s2)
    800042f0:	02892503          	lw	a0,40(s2)
    800042f4:	fffff097          	auipc	ra,0xfffff
    800042f8:	ff0080e7          	jalr	-16(ra) # 800032e4 <bread>
    800042fc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800042fe:	02c92683          	lw	a3,44(s2)
    80004302:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004304:	02d05863          	blez	a3,80004334 <write_head+0x5c>
    80004308:	0001d797          	auipc	a5,0x1d
    8000430c:	7b078793          	addi	a5,a5,1968 # 80021ab8 <log+0x30>
    80004310:	05c50713          	addi	a4,a0,92
    80004314:	36fd                	addiw	a3,a3,-1
    80004316:	02069613          	slli	a2,a3,0x20
    8000431a:	01e65693          	srli	a3,a2,0x1e
    8000431e:	0001d617          	auipc	a2,0x1d
    80004322:	79e60613          	addi	a2,a2,1950 # 80021abc <log+0x34>
    80004326:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004328:	4390                	lw	a2,0(a5)
    8000432a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000432c:	0791                	addi	a5,a5,4
    8000432e:	0711                	addi	a4,a4,4
    80004330:	fed79ce3          	bne	a5,a3,80004328 <write_head+0x50>
  }
  bwrite(buf);
    80004334:	8526                	mv	a0,s1
    80004336:	fffff097          	auipc	ra,0xfffff
    8000433a:	0a0080e7          	jalr	160(ra) # 800033d6 <bwrite>
  brelse(buf);
    8000433e:	8526                	mv	a0,s1
    80004340:	fffff097          	auipc	ra,0xfffff
    80004344:	0d4080e7          	jalr	212(ra) # 80003414 <brelse>
}
    80004348:	60e2                	ld	ra,24(sp)
    8000434a:	6442                	ld	s0,16(sp)
    8000434c:	64a2                	ld	s1,8(sp)
    8000434e:	6902                	ld	s2,0(sp)
    80004350:	6105                	addi	sp,sp,32
    80004352:	8082                	ret

0000000080004354 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004354:	0001d797          	auipc	a5,0x1d
    80004358:	7607a783          	lw	a5,1888(a5) # 80021ab4 <log+0x2c>
    8000435c:	0af05d63          	blez	a5,80004416 <install_trans+0xc2>
{
    80004360:	7139                	addi	sp,sp,-64
    80004362:	fc06                	sd	ra,56(sp)
    80004364:	f822                	sd	s0,48(sp)
    80004366:	f426                	sd	s1,40(sp)
    80004368:	f04a                	sd	s2,32(sp)
    8000436a:	ec4e                	sd	s3,24(sp)
    8000436c:	e852                	sd	s4,16(sp)
    8000436e:	e456                	sd	s5,8(sp)
    80004370:	e05a                	sd	s6,0(sp)
    80004372:	0080                	addi	s0,sp,64
    80004374:	8b2a                	mv	s6,a0
    80004376:	0001da97          	auipc	s5,0x1d
    8000437a:	742a8a93          	addi	s5,s5,1858 # 80021ab8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000437e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004380:	0001d997          	auipc	s3,0x1d
    80004384:	70898993          	addi	s3,s3,1800 # 80021a88 <log>
    80004388:	a00d                	j	800043aa <install_trans+0x56>
    brelse(lbuf);
    8000438a:	854a                	mv	a0,s2
    8000438c:	fffff097          	auipc	ra,0xfffff
    80004390:	088080e7          	jalr	136(ra) # 80003414 <brelse>
    brelse(dbuf);
    80004394:	8526                	mv	a0,s1
    80004396:	fffff097          	auipc	ra,0xfffff
    8000439a:	07e080e7          	jalr	126(ra) # 80003414 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000439e:	2a05                	addiw	s4,s4,1
    800043a0:	0a91                	addi	s5,s5,4
    800043a2:	02c9a783          	lw	a5,44(s3)
    800043a6:	04fa5e63          	bge	s4,a5,80004402 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800043aa:	0189a583          	lw	a1,24(s3)
    800043ae:	014585bb          	addw	a1,a1,s4
    800043b2:	2585                	addiw	a1,a1,1
    800043b4:	0289a503          	lw	a0,40(s3)
    800043b8:	fffff097          	auipc	ra,0xfffff
    800043bc:	f2c080e7          	jalr	-212(ra) # 800032e4 <bread>
    800043c0:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800043c2:	000aa583          	lw	a1,0(s5)
    800043c6:	0289a503          	lw	a0,40(s3)
    800043ca:	fffff097          	auipc	ra,0xfffff
    800043ce:	f1a080e7          	jalr	-230(ra) # 800032e4 <bread>
    800043d2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800043d4:	40000613          	li	a2,1024
    800043d8:	05890593          	addi	a1,s2,88
    800043dc:	05850513          	addi	a0,a0,88
    800043e0:	ffffd097          	auipc	ra,0xffffd
    800043e4:	93a080e7          	jalr	-1734(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    800043e8:	8526                	mv	a0,s1
    800043ea:	fffff097          	auipc	ra,0xfffff
    800043ee:	fec080e7          	jalr	-20(ra) # 800033d6 <bwrite>
    if(recovering == 0)
    800043f2:	f80b1ce3          	bnez	s6,8000438a <install_trans+0x36>
      bunpin(dbuf);
    800043f6:	8526                	mv	a0,s1
    800043f8:	fffff097          	auipc	ra,0xfffff
    800043fc:	0f6080e7          	jalr	246(ra) # 800034ee <bunpin>
    80004400:	b769                	j	8000438a <install_trans+0x36>
}
    80004402:	70e2                	ld	ra,56(sp)
    80004404:	7442                	ld	s0,48(sp)
    80004406:	74a2                	ld	s1,40(sp)
    80004408:	7902                	ld	s2,32(sp)
    8000440a:	69e2                	ld	s3,24(sp)
    8000440c:	6a42                	ld	s4,16(sp)
    8000440e:	6aa2                	ld	s5,8(sp)
    80004410:	6b02                	ld	s6,0(sp)
    80004412:	6121                	addi	sp,sp,64
    80004414:	8082                	ret
    80004416:	8082                	ret

0000000080004418 <initlog>:
{
    80004418:	7179                	addi	sp,sp,-48
    8000441a:	f406                	sd	ra,40(sp)
    8000441c:	f022                	sd	s0,32(sp)
    8000441e:	ec26                	sd	s1,24(sp)
    80004420:	e84a                	sd	s2,16(sp)
    80004422:	e44e                	sd	s3,8(sp)
    80004424:	1800                	addi	s0,sp,48
    80004426:	892a                	mv	s2,a0
    80004428:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000442a:	0001d497          	auipc	s1,0x1d
    8000442e:	65e48493          	addi	s1,s1,1630 # 80021a88 <log>
    80004432:	00004597          	auipc	a1,0x4
    80004436:	3e658593          	addi	a1,a1,998 # 80008818 <syscalls+0x1f0>
    8000443a:	8526                	mv	a0,s1
    8000443c:	ffffc097          	auipc	ra,0xffffc
    80004440:	6f6080e7          	jalr	1782(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004444:	0149a583          	lw	a1,20(s3)
    80004448:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000444a:	0109a783          	lw	a5,16(s3)
    8000444e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004450:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004454:	854a                	mv	a0,s2
    80004456:	fffff097          	auipc	ra,0xfffff
    8000445a:	e8e080e7          	jalr	-370(ra) # 800032e4 <bread>
  log.lh.n = lh->n;
    8000445e:	4d34                	lw	a3,88(a0)
    80004460:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004462:	02d05663          	blez	a3,8000448e <initlog+0x76>
    80004466:	05c50793          	addi	a5,a0,92
    8000446a:	0001d717          	auipc	a4,0x1d
    8000446e:	64e70713          	addi	a4,a4,1614 # 80021ab8 <log+0x30>
    80004472:	36fd                	addiw	a3,a3,-1
    80004474:	02069613          	slli	a2,a3,0x20
    80004478:	01e65693          	srli	a3,a2,0x1e
    8000447c:	06050613          	addi	a2,a0,96
    80004480:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004482:	4390                	lw	a2,0(a5)
    80004484:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004486:	0791                	addi	a5,a5,4
    80004488:	0711                	addi	a4,a4,4
    8000448a:	fed79ce3          	bne	a5,a3,80004482 <initlog+0x6a>
  brelse(buf);
    8000448e:	fffff097          	auipc	ra,0xfffff
    80004492:	f86080e7          	jalr	-122(ra) # 80003414 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004496:	4505                	li	a0,1
    80004498:	00000097          	auipc	ra,0x0
    8000449c:	ebc080e7          	jalr	-324(ra) # 80004354 <install_trans>
  log.lh.n = 0;
    800044a0:	0001d797          	auipc	a5,0x1d
    800044a4:	6007aa23          	sw	zero,1556(a5) # 80021ab4 <log+0x2c>
  write_head(); // clear the log
    800044a8:	00000097          	auipc	ra,0x0
    800044ac:	e30080e7          	jalr	-464(ra) # 800042d8 <write_head>
}
    800044b0:	70a2                	ld	ra,40(sp)
    800044b2:	7402                	ld	s0,32(sp)
    800044b4:	64e2                	ld	s1,24(sp)
    800044b6:	6942                	ld	s2,16(sp)
    800044b8:	69a2                	ld	s3,8(sp)
    800044ba:	6145                	addi	sp,sp,48
    800044bc:	8082                	ret

00000000800044be <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800044be:	1101                	addi	sp,sp,-32
    800044c0:	ec06                	sd	ra,24(sp)
    800044c2:	e822                	sd	s0,16(sp)
    800044c4:	e426                	sd	s1,8(sp)
    800044c6:	e04a                	sd	s2,0(sp)
    800044c8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800044ca:	0001d517          	auipc	a0,0x1d
    800044ce:	5be50513          	addi	a0,a0,1470 # 80021a88 <log>
    800044d2:	ffffc097          	auipc	ra,0xffffc
    800044d6:	6f0080e7          	jalr	1776(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    800044da:	0001d497          	auipc	s1,0x1d
    800044de:	5ae48493          	addi	s1,s1,1454 # 80021a88 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044e2:	4979                	li	s2,30
    800044e4:	a039                	j	800044f2 <begin_op+0x34>
      sleep(&log, &log.lock);
    800044e6:	85a6                	mv	a1,s1
    800044e8:	8526                	mv	a0,s1
    800044ea:	ffffe097          	auipc	ra,0xffffe
    800044ee:	c10080e7          	jalr	-1008(ra) # 800020fa <sleep>
    if(log.committing){
    800044f2:	50dc                	lw	a5,36(s1)
    800044f4:	fbed                	bnez	a5,800044e6 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044f6:	509c                	lw	a5,32(s1)
    800044f8:	0017871b          	addiw	a4,a5,1
    800044fc:	0007069b          	sext.w	a3,a4
    80004500:	0027179b          	slliw	a5,a4,0x2
    80004504:	9fb9                	addw	a5,a5,a4
    80004506:	0017979b          	slliw	a5,a5,0x1
    8000450a:	54d8                	lw	a4,44(s1)
    8000450c:	9fb9                	addw	a5,a5,a4
    8000450e:	00f95963          	bge	s2,a5,80004520 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004512:	85a6                	mv	a1,s1
    80004514:	8526                	mv	a0,s1
    80004516:	ffffe097          	auipc	ra,0xffffe
    8000451a:	be4080e7          	jalr	-1052(ra) # 800020fa <sleep>
    8000451e:	bfd1                	j	800044f2 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004520:	0001d517          	auipc	a0,0x1d
    80004524:	56850513          	addi	a0,a0,1384 # 80021a88 <log>
    80004528:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000452a:	ffffc097          	auipc	ra,0xffffc
    8000452e:	74c080e7          	jalr	1868(ra) # 80000c76 <release>
      break;
    }
  }
}
    80004532:	60e2                	ld	ra,24(sp)
    80004534:	6442                	ld	s0,16(sp)
    80004536:	64a2                	ld	s1,8(sp)
    80004538:	6902                	ld	s2,0(sp)
    8000453a:	6105                	addi	sp,sp,32
    8000453c:	8082                	ret

000000008000453e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000453e:	7139                	addi	sp,sp,-64
    80004540:	fc06                	sd	ra,56(sp)
    80004542:	f822                	sd	s0,48(sp)
    80004544:	f426                	sd	s1,40(sp)
    80004546:	f04a                	sd	s2,32(sp)
    80004548:	ec4e                	sd	s3,24(sp)
    8000454a:	e852                	sd	s4,16(sp)
    8000454c:	e456                	sd	s5,8(sp)
    8000454e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004550:	0001d497          	auipc	s1,0x1d
    80004554:	53848493          	addi	s1,s1,1336 # 80021a88 <log>
    80004558:	8526                	mv	a0,s1
    8000455a:	ffffc097          	auipc	ra,0xffffc
    8000455e:	668080e7          	jalr	1640(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004562:	509c                	lw	a5,32(s1)
    80004564:	37fd                	addiw	a5,a5,-1
    80004566:	0007891b          	sext.w	s2,a5
    8000456a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000456c:	50dc                	lw	a5,36(s1)
    8000456e:	e7b9                	bnez	a5,800045bc <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004570:	04091e63          	bnez	s2,800045cc <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004574:	0001d497          	auipc	s1,0x1d
    80004578:	51448493          	addi	s1,s1,1300 # 80021a88 <log>
    8000457c:	4785                	li	a5,1
    8000457e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004580:	8526                	mv	a0,s1
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	6f4080e7          	jalr	1780(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000458a:	54dc                	lw	a5,44(s1)
    8000458c:	06f04763          	bgtz	a5,800045fa <end_op+0xbc>
    acquire(&log.lock);
    80004590:	0001d497          	auipc	s1,0x1d
    80004594:	4f848493          	addi	s1,s1,1272 # 80021a88 <log>
    80004598:	8526                	mv	a0,s1
    8000459a:	ffffc097          	auipc	ra,0xffffc
    8000459e:	628080e7          	jalr	1576(ra) # 80000bc2 <acquire>
    log.committing = 0;
    800045a2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800045a6:	8526                	mv	a0,s1
    800045a8:	ffffe097          	auipc	ra,0xffffe
    800045ac:	cde080e7          	jalr	-802(ra) # 80002286 <wakeup>
    release(&log.lock);
    800045b0:	8526                	mv	a0,s1
    800045b2:	ffffc097          	auipc	ra,0xffffc
    800045b6:	6c4080e7          	jalr	1732(ra) # 80000c76 <release>
}
    800045ba:	a03d                	j	800045e8 <end_op+0xaa>
    panic("log.committing");
    800045bc:	00004517          	auipc	a0,0x4
    800045c0:	26450513          	addi	a0,a0,612 # 80008820 <syscalls+0x1f8>
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	f66080e7          	jalr	-154(ra) # 8000052a <panic>
    wakeup(&log);
    800045cc:	0001d497          	auipc	s1,0x1d
    800045d0:	4bc48493          	addi	s1,s1,1212 # 80021a88 <log>
    800045d4:	8526                	mv	a0,s1
    800045d6:	ffffe097          	auipc	ra,0xffffe
    800045da:	cb0080e7          	jalr	-848(ra) # 80002286 <wakeup>
  release(&log.lock);
    800045de:	8526                	mv	a0,s1
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	696080e7          	jalr	1686(ra) # 80000c76 <release>
}
    800045e8:	70e2                	ld	ra,56(sp)
    800045ea:	7442                	ld	s0,48(sp)
    800045ec:	74a2                	ld	s1,40(sp)
    800045ee:	7902                	ld	s2,32(sp)
    800045f0:	69e2                	ld	s3,24(sp)
    800045f2:	6a42                	ld	s4,16(sp)
    800045f4:	6aa2                	ld	s5,8(sp)
    800045f6:	6121                	addi	sp,sp,64
    800045f8:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800045fa:	0001da97          	auipc	s5,0x1d
    800045fe:	4bea8a93          	addi	s5,s5,1214 # 80021ab8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004602:	0001da17          	auipc	s4,0x1d
    80004606:	486a0a13          	addi	s4,s4,1158 # 80021a88 <log>
    8000460a:	018a2583          	lw	a1,24(s4)
    8000460e:	012585bb          	addw	a1,a1,s2
    80004612:	2585                	addiw	a1,a1,1
    80004614:	028a2503          	lw	a0,40(s4)
    80004618:	fffff097          	auipc	ra,0xfffff
    8000461c:	ccc080e7          	jalr	-820(ra) # 800032e4 <bread>
    80004620:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004622:	000aa583          	lw	a1,0(s5)
    80004626:	028a2503          	lw	a0,40(s4)
    8000462a:	fffff097          	auipc	ra,0xfffff
    8000462e:	cba080e7          	jalr	-838(ra) # 800032e4 <bread>
    80004632:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004634:	40000613          	li	a2,1024
    80004638:	05850593          	addi	a1,a0,88
    8000463c:	05848513          	addi	a0,s1,88
    80004640:	ffffc097          	auipc	ra,0xffffc
    80004644:	6da080e7          	jalr	1754(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004648:	8526                	mv	a0,s1
    8000464a:	fffff097          	auipc	ra,0xfffff
    8000464e:	d8c080e7          	jalr	-628(ra) # 800033d6 <bwrite>
    brelse(from);
    80004652:	854e                	mv	a0,s3
    80004654:	fffff097          	auipc	ra,0xfffff
    80004658:	dc0080e7          	jalr	-576(ra) # 80003414 <brelse>
    brelse(to);
    8000465c:	8526                	mv	a0,s1
    8000465e:	fffff097          	auipc	ra,0xfffff
    80004662:	db6080e7          	jalr	-586(ra) # 80003414 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004666:	2905                	addiw	s2,s2,1
    80004668:	0a91                	addi	s5,s5,4
    8000466a:	02ca2783          	lw	a5,44(s4)
    8000466e:	f8f94ee3          	blt	s2,a5,8000460a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004672:	00000097          	auipc	ra,0x0
    80004676:	c66080e7          	jalr	-922(ra) # 800042d8 <write_head>
    install_trans(0); // Now install writes to home locations
    8000467a:	4501                	li	a0,0
    8000467c:	00000097          	auipc	ra,0x0
    80004680:	cd8080e7          	jalr	-808(ra) # 80004354 <install_trans>
    log.lh.n = 0;
    80004684:	0001d797          	auipc	a5,0x1d
    80004688:	4207a823          	sw	zero,1072(a5) # 80021ab4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000468c:	00000097          	auipc	ra,0x0
    80004690:	c4c080e7          	jalr	-948(ra) # 800042d8 <write_head>
    80004694:	bdf5                	j	80004590 <end_op+0x52>

0000000080004696 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004696:	1101                	addi	sp,sp,-32
    80004698:	ec06                	sd	ra,24(sp)
    8000469a:	e822                	sd	s0,16(sp)
    8000469c:	e426                	sd	s1,8(sp)
    8000469e:	e04a                	sd	s2,0(sp)
    800046a0:	1000                	addi	s0,sp,32
    800046a2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800046a4:	0001d917          	auipc	s2,0x1d
    800046a8:	3e490913          	addi	s2,s2,996 # 80021a88 <log>
    800046ac:	854a                	mv	a0,s2
    800046ae:	ffffc097          	auipc	ra,0xffffc
    800046b2:	514080e7          	jalr	1300(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800046b6:	02c92603          	lw	a2,44(s2)
    800046ba:	47f5                	li	a5,29
    800046bc:	06c7c563          	blt	a5,a2,80004726 <log_write+0x90>
    800046c0:	0001d797          	auipc	a5,0x1d
    800046c4:	3e47a783          	lw	a5,996(a5) # 80021aa4 <log+0x1c>
    800046c8:	37fd                	addiw	a5,a5,-1
    800046ca:	04f65e63          	bge	a2,a5,80004726 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800046ce:	0001d797          	auipc	a5,0x1d
    800046d2:	3da7a783          	lw	a5,986(a5) # 80021aa8 <log+0x20>
    800046d6:	06f05063          	blez	a5,80004736 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800046da:	4781                	li	a5,0
    800046dc:	06c05563          	blez	a2,80004746 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800046e0:	44cc                	lw	a1,12(s1)
    800046e2:	0001d717          	auipc	a4,0x1d
    800046e6:	3d670713          	addi	a4,a4,982 # 80021ab8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800046ea:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800046ec:	4314                	lw	a3,0(a4)
    800046ee:	04b68c63          	beq	a3,a1,80004746 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800046f2:	2785                	addiw	a5,a5,1
    800046f4:	0711                	addi	a4,a4,4
    800046f6:	fef61be3          	bne	a2,a5,800046ec <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800046fa:	0621                	addi	a2,a2,8
    800046fc:	060a                	slli	a2,a2,0x2
    800046fe:	0001d797          	auipc	a5,0x1d
    80004702:	38a78793          	addi	a5,a5,906 # 80021a88 <log>
    80004706:	963e                	add	a2,a2,a5
    80004708:	44dc                	lw	a5,12(s1)
    8000470a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000470c:	8526                	mv	a0,s1
    8000470e:	fffff097          	auipc	ra,0xfffff
    80004712:	da4080e7          	jalr	-604(ra) # 800034b2 <bpin>
    log.lh.n++;
    80004716:	0001d717          	auipc	a4,0x1d
    8000471a:	37270713          	addi	a4,a4,882 # 80021a88 <log>
    8000471e:	575c                	lw	a5,44(a4)
    80004720:	2785                	addiw	a5,a5,1
    80004722:	d75c                	sw	a5,44(a4)
    80004724:	a835                	j	80004760 <log_write+0xca>
    panic("too big a transaction");
    80004726:	00004517          	auipc	a0,0x4
    8000472a:	10a50513          	addi	a0,a0,266 # 80008830 <syscalls+0x208>
    8000472e:	ffffc097          	auipc	ra,0xffffc
    80004732:	dfc080e7          	jalr	-516(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004736:	00004517          	auipc	a0,0x4
    8000473a:	11250513          	addi	a0,a0,274 # 80008848 <syscalls+0x220>
    8000473e:	ffffc097          	auipc	ra,0xffffc
    80004742:	dec080e7          	jalr	-532(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004746:	00878713          	addi	a4,a5,8
    8000474a:	00271693          	slli	a3,a4,0x2
    8000474e:	0001d717          	auipc	a4,0x1d
    80004752:	33a70713          	addi	a4,a4,826 # 80021a88 <log>
    80004756:	9736                	add	a4,a4,a3
    80004758:	44d4                	lw	a3,12(s1)
    8000475a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000475c:	faf608e3          	beq	a2,a5,8000470c <log_write+0x76>
  }
  release(&log.lock);
    80004760:	0001d517          	auipc	a0,0x1d
    80004764:	32850513          	addi	a0,a0,808 # 80021a88 <log>
    80004768:	ffffc097          	auipc	ra,0xffffc
    8000476c:	50e080e7          	jalr	1294(ra) # 80000c76 <release>
}
    80004770:	60e2                	ld	ra,24(sp)
    80004772:	6442                	ld	s0,16(sp)
    80004774:	64a2                	ld	s1,8(sp)
    80004776:	6902                	ld	s2,0(sp)
    80004778:	6105                	addi	sp,sp,32
    8000477a:	8082                	ret

000000008000477c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000477c:	1101                	addi	sp,sp,-32
    8000477e:	ec06                	sd	ra,24(sp)
    80004780:	e822                	sd	s0,16(sp)
    80004782:	e426                	sd	s1,8(sp)
    80004784:	e04a                	sd	s2,0(sp)
    80004786:	1000                	addi	s0,sp,32
    80004788:	84aa                	mv	s1,a0
    8000478a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000478c:	00004597          	auipc	a1,0x4
    80004790:	0dc58593          	addi	a1,a1,220 # 80008868 <syscalls+0x240>
    80004794:	0521                	addi	a0,a0,8
    80004796:	ffffc097          	auipc	ra,0xffffc
    8000479a:	39c080e7          	jalr	924(ra) # 80000b32 <initlock>
  lk->name = name;
    8000479e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800047a2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047a6:	0204a423          	sw	zero,40(s1)
}
    800047aa:	60e2                	ld	ra,24(sp)
    800047ac:	6442                	ld	s0,16(sp)
    800047ae:	64a2                	ld	s1,8(sp)
    800047b0:	6902                	ld	s2,0(sp)
    800047b2:	6105                	addi	sp,sp,32
    800047b4:	8082                	ret

00000000800047b6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800047b6:	1101                	addi	sp,sp,-32
    800047b8:	ec06                	sd	ra,24(sp)
    800047ba:	e822                	sd	s0,16(sp)
    800047bc:	e426                	sd	s1,8(sp)
    800047be:	e04a                	sd	s2,0(sp)
    800047c0:	1000                	addi	s0,sp,32
    800047c2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047c4:	00850913          	addi	s2,a0,8
    800047c8:	854a                	mv	a0,s2
    800047ca:	ffffc097          	auipc	ra,0xffffc
    800047ce:	3f8080e7          	jalr	1016(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    800047d2:	409c                	lw	a5,0(s1)
    800047d4:	cb89                	beqz	a5,800047e6 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800047d6:	85ca                	mv	a1,s2
    800047d8:	8526                	mv	a0,s1
    800047da:	ffffe097          	auipc	ra,0xffffe
    800047de:	920080e7          	jalr	-1760(ra) # 800020fa <sleep>
  while (lk->locked) {
    800047e2:	409c                	lw	a5,0(s1)
    800047e4:	fbed                	bnez	a5,800047d6 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800047e6:	4785                	li	a5,1
    800047e8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800047ea:	ffffd097          	auipc	ra,0xffffd
    800047ee:	1ac080e7          	jalr	428(ra) # 80001996 <myproc>
    800047f2:	591c                	lw	a5,48(a0)
    800047f4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800047f6:	854a                	mv	a0,s2
    800047f8:	ffffc097          	auipc	ra,0xffffc
    800047fc:	47e080e7          	jalr	1150(ra) # 80000c76 <release>
}
    80004800:	60e2                	ld	ra,24(sp)
    80004802:	6442                	ld	s0,16(sp)
    80004804:	64a2                	ld	s1,8(sp)
    80004806:	6902                	ld	s2,0(sp)
    80004808:	6105                	addi	sp,sp,32
    8000480a:	8082                	ret

000000008000480c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000480c:	1101                	addi	sp,sp,-32
    8000480e:	ec06                	sd	ra,24(sp)
    80004810:	e822                	sd	s0,16(sp)
    80004812:	e426                	sd	s1,8(sp)
    80004814:	e04a                	sd	s2,0(sp)
    80004816:	1000                	addi	s0,sp,32
    80004818:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000481a:	00850913          	addi	s2,a0,8
    8000481e:	854a                	mv	a0,s2
    80004820:	ffffc097          	auipc	ra,0xffffc
    80004824:	3a2080e7          	jalr	930(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80004828:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000482c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004830:	8526                	mv	a0,s1
    80004832:	ffffe097          	auipc	ra,0xffffe
    80004836:	a54080e7          	jalr	-1452(ra) # 80002286 <wakeup>
  release(&lk->lk);
    8000483a:	854a                	mv	a0,s2
    8000483c:	ffffc097          	auipc	ra,0xffffc
    80004840:	43a080e7          	jalr	1082(ra) # 80000c76 <release>
}
    80004844:	60e2                	ld	ra,24(sp)
    80004846:	6442                	ld	s0,16(sp)
    80004848:	64a2                	ld	s1,8(sp)
    8000484a:	6902                	ld	s2,0(sp)
    8000484c:	6105                	addi	sp,sp,32
    8000484e:	8082                	ret

0000000080004850 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004850:	7179                	addi	sp,sp,-48
    80004852:	f406                	sd	ra,40(sp)
    80004854:	f022                	sd	s0,32(sp)
    80004856:	ec26                	sd	s1,24(sp)
    80004858:	e84a                	sd	s2,16(sp)
    8000485a:	e44e                	sd	s3,8(sp)
    8000485c:	1800                	addi	s0,sp,48
    8000485e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004860:	00850913          	addi	s2,a0,8
    80004864:	854a                	mv	a0,s2
    80004866:	ffffc097          	auipc	ra,0xffffc
    8000486a:	35c080e7          	jalr	860(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000486e:	409c                	lw	a5,0(s1)
    80004870:	ef99                	bnez	a5,8000488e <holdingsleep+0x3e>
    80004872:	4481                	li	s1,0
  release(&lk->lk);
    80004874:	854a                	mv	a0,s2
    80004876:	ffffc097          	auipc	ra,0xffffc
    8000487a:	400080e7          	jalr	1024(ra) # 80000c76 <release>
  return r;
}
    8000487e:	8526                	mv	a0,s1
    80004880:	70a2                	ld	ra,40(sp)
    80004882:	7402                	ld	s0,32(sp)
    80004884:	64e2                	ld	s1,24(sp)
    80004886:	6942                	ld	s2,16(sp)
    80004888:	69a2                	ld	s3,8(sp)
    8000488a:	6145                	addi	sp,sp,48
    8000488c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000488e:	0284a983          	lw	s3,40(s1)
    80004892:	ffffd097          	auipc	ra,0xffffd
    80004896:	104080e7          	jalr	260(ra) # 80001996 <myproc>
    8000489a:	5904                	lw	s1,48(a0)
    8000489c:	413484b3          	sub	s1,s1,s3
    800048a0:	0014b493          	seqz	s1,s1
    800048a4:	bfc1                	j	80004874 <holdingsleep+0x24>

00000000800048a6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800048a6:	1141                	addi	sp,sp,-16
    800048a8:	e406                	sd	ra,8(sp)
    800048aa:	e022                	sd	s0,0(sp)
    800048ac:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800048ae:	00004597          	auipc	a1,0x4
    800048b2:	fca58593          	addi	a1,a1,-54 # 80008878 <syscalls+0x250>
    800048b6:	0001d517          	auipc	a0,0x1d
    800048ba:	31a50513          	addi	a0,a0,794 # 80021bd0 <ftable>
    800048be:	ffffc097          	auipc	ra,0xffffc
    800048c2:	274080e7          	jalr	628(ra) # 80000b32 <initlock>
}
    800048c6:	60a2                	ld	ra,8(sp)
    800048c8:	6402                	ld	s0,0(sp)
    800048ca:	0141                	addi	sp,sp,16
    800048cc:	8082                	ret

00000000800048ce <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800048ce:	1101                	addi	sp,sp,-32
    800048d0:	ec06                	sd	ra,24(sp)
    800048d2:	e822                	sd	s0,16(sp)
    800048d4:	e426                	sd	s1,8(sp)
    800048d6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800048d8:	0001d517          	auipc	a0,0x1d
    800048dc:	2f850513          	addi	a0,a0,760 # 80021bd0 <ftable>
    800048e0:	ffffc097          	auipc	ra,0xffffc
    800048e4:	2e2080e7          	jalr	738(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048e8:	0001d497          	auipc	s1,0x1d
    800048ec:	30048493          	addi	s1,s1,768 # 80021be8 <ftable+0x18>
    800048f0:	0001e717          	auipc	a4,0x1e
    800048f4:	29870713          	addi	a4,a4,664 # 80022b88 <ftable+0xfb8>
    if(f->ref == 0){
    800048f8:	40dc                	lw	a5,4(s1)
    800048fa:	cf99                	beqz	a5,80004918 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048fc:	02848493          	addi	s1,s1,40
    80004900:	fee49ce3          	bne	s1,a4,800048f8 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004904:	0001d517          	auipc	a0,0x1d
    80004908:	2cc50513          	addi	a0,a0,716 # 80021bd0 <ftable>
    8000490c:	ffffc097          	auipc	ra,0xffffc
    80004910:	36a080e7          	jalr	874(ra) # 80000c76 <release>
  return 0;
    80004914:	4481                	li	s1,0
    80004916:	a819                	j	8000492c <filealloc+0x5e>
      f->ref = 1;
    80004918:	4785                	li	a5,1
    8000491a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000491c:	0001d517          	auipc	a0,0x1d
    80004920:	2b450513          	addi	a0,a0,692 # 80021bd0 <ftable>
    80004924:	ffffc097          	auipc	ra,0xffffc
    80004928:	352080e7          	jalr	850(ra) # 80000c76 <release>
}
    8000492c:	8526                	mv	a0,s1
    8000492e:	60e2                	ld	ra,24(sp)
    80004930:	6442                	ld	s0,16(sp)
    80004932:	64a2                	ld	s1,8(sp)
    80004934:	6105                	addi	sp,sp,32
    80004936:	8082                	ret

0000000080004938 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004938:	1101                	addi	sp,sp,-32
    8000493a:	ec06                	sd	ra,24(sp)
    8000493c:	e822                	sd	s0,16(sp)
    8000493e:	e426                	sd	s1,8(sp)
    80004940:	1000                	addi	s0,sp,32
    80004942:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004944:	0001d517          	auipc	a0,0x1d
    80004948:	28c50513          	addi	a0,a0,652 # 80021bd0 <ftable>
    8000494c:	ffffc097          	auipc	ra,0xffffc
    80004950:	276080e7          	jalr	630(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004954:	40dc                	lw	a5,4(s1)
    80004956:	02f05263          	blez	a5,8000497a <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000495a:	2785                	addiw	a5,a5,1
    8000495c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000495e:	0001d517          	auipc	a0,0x1d
    80004962:	27250513          	addi	a0,a0,626 # 80021bd0 <ftable>
    80004966:	ffffc097          	auipc	ra,0xffffc
    8000496a:	310080e7          	jalr	784(ra) # 80000c76 <release>
  return f;
}
    8000496e:	8526                	mv	a0,s1
    80004970:	60e2                	ld	ra,24(sp)
    80004972:	6442                	ld	s0,16(sp)
    80004974:	64a2                	ld	s1,8(sp)
    80004976:	6105                	addi	sp,sp,32
    80004978:	8082                	ret
    panic("filedup");
    8000497a:	00004517          	auipc	a0,0x4
    8000497e:	f0650513          	addi	a0,a0,-250 # 80008880 <syscalls+0x258>
    80004982:	ffffc097          	auipc	ra,0xffffc
    80004986:	ba8080e7          	jalr	-1112(ra) # 8000052a <panic>

000000008000498a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000498a:	7139                	addi	sp,sp,-64
    8000498c:	fc06                	sd	ra,56(sp)
    8000498e:	f822                	sd	s0,48(sp)
    80004990:	f426                	sd	s1,40(sp)
    80004992:	f04a                	sd	s2,32(sp)
    80004994:	ec4e                	sd	s3,24(sp)
    80004996:	e852                	sd	s4,16(sp)
    80004998:	e456                	sd	s5,8(sp)
    8000499a:	0080                	addi	s0,sp,64
    8000499c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000499e:	0001d517          	auipc	a0,0x1d
    800049a2:	23250513          	addi	a0,a0,562 # 80021bd0 <ftable>
    800049a6:	ffffc097          	auipc	ra,0xffffc
    800049aa:	21c080e7          	jalr	540(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    800049ae:	40dc                	lw	a5,4(s1)
    800049b0:	06f05163          	blez	a5,80004a12 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800049b4:	37fd                	addiw	a5,a5,-1
    800049b6:	0007871b          	sext.w	a4,a5
    800049ba:	c0dc                	sw	a5,4(s1)
    800049bc:	06e04363          	bgtz	a4,80004a22 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800049c0:	0004a903          	lw	s2,0(s1)
    800049c4:	0094ca83          	lbu	s5,9(s1)
    800049c8:	0104ba03          	ld	s4,16(s1)
    800049cc:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800049d0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800049d4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800049d8:	0001d517          	auipc	a0,0x1d
    800049dc:	1f850513          	addi	a0,a0,504 # 80021bd0 <ftable>
    800049e0:	ffffc097          	auipc	ra,0xffffc
    800049e4:	296080e7          	jalr	662(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    800049e8:	4785                	li	a5,1
    800049ea:	04f90d63          	beq	s2,a5,80004a44 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800049ee:	3979                	addiw	s2,s2,-2
    800049f0:	4785                	li	a5,1
    800049f2:	0527e063          	bltu	a5,s2,80004a32 <fileclose+0xa8>
    begin_op();
    800049f6:	00000097          	auipc	ra,0x0
    800049fa:	ac8080e7          	jalr	-1336(ra) # 800044be <begin_op>
    iput(ff.ip);
    800049fe:	854e                	mv	a0,s3
    80004a00:	fffff097          	auipc	ra,0xfffff
    80004a04:	2a2080e7          	jalr	674(ra) # 80003ca2 <iput>
    end_op();
    80004a08:	00000097          	auipc	ra,0x0
    80004a0c:	b36080e7          	jalr	-1226(ra) # 8000453e <end_op>
    80004a10:	a00d                	j	80004a32 <fileclose+0xa8>
    panic("fileclose");
    80004a12:	00004517          	auipc	a0,0x4
    80004a16:	e7650513          	addi	a0,a0,-394 # 80008888 <syscalls+0x260>
    80004a1a:	ffffc097          	auipc	ra,0xffffc
    80004a1e:	b10080e7          	jalr	-1264(ra) # 8000052a <panic>
    release(&ftable.lock);
    80004a22:	0001d517          	auipc	a0,0x1d
    80004a26:	1ae50513          	addi	a0,a0,430 # 80021bd0 <ftable>
    80004a2a:	ffffc097          	auipc	ra,0xffffc
    80004a2e:	24c080e7          	jalr	588(ra) # 80000c76 <release>
  }
}
    80004a32:	70e2                	ld	ra,56(sp)
    80004a34:	7442                	ld	s0,48(sp)
    80004a36:	74a2                	ld	s1,40(sp)
    80004a38:	7902                	ld	s2,32(sp)
    80004a3a:	69e2                	ld	s3,24(sp)
    80004a3c:	6a42                	ld	s4,16(sp)
    80004a3e:	6aa2                	ld	s5,8(sp)
    80004a40:	6121                	addi	sp,sp,64
    80004a42:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a44:	85d6                	mv	a1,s5
    80004a46:	8552                	mv	a0,s4
    80004a48:	00000097          	auipc	ra,0x0
    80004a4c:	34c080e7          	jalr	844(ra) # 80004d94 <pipeclose>
    80004a50:	b7cd                	j	80004a32 <fileclose+0xa8>

0000000080004a52 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a52:	715d                	addi	sp,sp,-80
    80004a54:	e486                	sd	ra,72(sp)
    80004a56:	e0a2                	sd	s0,64(sp)
    80004a58:	fc26                	sd	s1,56(sp)
    80004a5a:	f84a                	sd	s2,48(sp)
    80004a5c:	f44e                	sd	s3,40(sp)
    80004a5e:	0880                	addi	s0,sp,80
    80004a60:	84aa                	mv	s1,a0
    80004a62:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a64:	ffffd097          	auipc	ra,0xffffd
    80004a68:	f32080e7          	jalr	-206(ra) # 80001996 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a6c:	409c                	lw	a5,0(s1)
    80004a6e:	37f9                	addiw	a5,a5,-2
    80004a70:	4705                	li	a4,1
    80004a72:	04f76763          	bltu	a4,a5,80004ac0 <filestat+0x6e>
    80004a76:	892a                	mv	s2,a0
    ilock(f->ip);
    80004a78:	6c88                	ld	a0,24(s1)
    80004a7a:	fffff097          	auipc	ra,0xfffff
    80004a7e:	06e080e7          	jalr	110(ra) # 80003ae8 <ilock>
    stati(f->ip, &st);
    80004a82:	fb840593          	addi	a1,s0,-72
    80004a86:	6c88                	ld	a0,24(s1)
    80004a88:	fffff097          	auipc	ra,0xfffff
    80004a8c:	2ea080e7          	jalr	746(ra) # 80003d72 <stati>
    iunlock(f->ip);
    80004a90:	6c88                	ld	a0,24(s1)
    80004a92:	fffff097          	auipc	ra,0xfffff
    80004a96:	118080e7          	jalr	280(ra) # 80003baa <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a9a:	46e1                	li	a3,24
    80004a9c:	fb840613          	addi	a2,s0,-72
    80004aa0:	85ce                	mv	a1,s3
    80004aa2:	07093503          	ld	a0,112(s2)
    80004aa6:	ffffd097          	auipc	ra,0xffffd
    80004aaa:	b98080e7          	jalr	-1128(ra) # 8000163e <copyout>
    80004aae:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004ab2:	60a6                	ld	ra,72(sp)
    80004ab4:	6406                	ld	s0,64(sp)
    80004ab6:	74e2                	ld	s1,56(sp)
    80004ab8:	7942                	ld	s2,48(sp)
    80004aba:	79a2                	ld	s3,40(sp)
    80004abc:	6161                	addi	sp,sp,80
    80004abe:	8082                	ret
  return -1;
    80004ac0:	557d                	li	a0,-1
    80004ac2:	bfc5                	j	80004ab2 <filestat+0x60>

0000000080004ac4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004ac4:	7179                	addi	sp,sp,-48
    80004ac6:	f406                	sd	ra,40(sp)
    80004ac8:	f022                	sd	s0,32(sp)
    80004aca:	ec26                	sd	s1,24(sp)
    80004acc:	e84a                	sd	s2,16(sp)
    80004ace:	e44e                	sd	s3,8(sp)
    80004ad0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004ad2:	00854783          	lbu	a5,8(a0)
    80004ad6:	c3d5                	beqz	a5,80004b7a <fileread+0xb6>
    80004ad8:	84aa                	mv	s1,a0
    80004ada:	89ae                	mv	s3,a1
    80004adc:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ade:	411c                	lw	a5,0(a0)
    80004ae0:	4705                	li	a4,1
    80004ae2:	04e78963          	beq	a5,a4,80004b34 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ae6:	470d                	li	a4,3
    80004ae8:	04e78d63          	beq	a5,a4,80004b42 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004aec:	4709                	li	a4,2
    80004aee:	06e79e63          	bne	a5,a4,80004b6a <fileread+0xa6>
    ilock(f->ip);
    80004af2:	6d08                	ld	a0,24(a0)
    80004af4:	fffff097          	auipc	ra,0xfffff
    80004af8:	ff4080e7          	jalr	-12(ra) # 80003ae8 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004afc:	874a                	mv	a4,s2
    80004afe:	5094                	lw	a3,32(s1)
    80004b00:	864e                	mv	a2,s3
    80004b02:	4585                	li	a1,1
    80004b04:	6c88                	ld	a0,24(s1)
    80004b06:	fffff097          	auipc	ra,0xfffff
    80004b0a:	296080e7          	jalr	662(ra) # 80003d9c <readi>
    80004b0e:	892a                	mv	s2,a0
    80004b10:	00a05563          	blez	a0,80004b1a <fileread+0x56>
      f->off += r;
    80004b14:	509c                	lw	a5,32(s1)
    80004b16:	9fa9                	addw	a5,a5,a0
    80004b18:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b1a:	6c88                	ld	a0,24(s1)
    80004b1c:	fffff097          	auipc	ra,0xfffff
    80004b20:	08e080e7          	jalr	142(ra) # 80003baa <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004b24:	854a                	mv	a0,s2
    80004b26:	70a2                	ld	ra,40(sp)
    80004b28:	7402                	ld	s0,32(sp)
    80004b2a:	64e2                	ld	s1,24(sp)
    80004b2c:	6942                	ld	s2,16(sp)
    80004b2e:	69a2                	ld	s3,8(sp)
    80004b30:	6145                	addi	sp,sp,48
    80004b32:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b34:	6908                	ld	a0,16(a0)
    80004b36:	00000097          	auipc	ra,0x0
    80004b3a:	3c0080e7          	jalr	960(ra) # 80004ef6 <piperead>
    80004b3e:	892a                	mv	s2,a0
    80004b40:	b7d5                	j	80004b24 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b42:	02451783          	lh	a5,36(a0)
    80004b46:	03079693          	slli	a3,a5,0x30
    80004b4a:	92c1                	srli	a3,a3,0x30
    80004b4c:	4725                	li	a4,9
    80004b4e:	02d76863          	bltu	a4,a3,80004b7e <fileread+0xba>
    80004b52:	0792                	slli	a5,a5,0x4
    80004b54:	0001d717          	auipc	a4,0x1d
    80004b58:	fdc70713          	addi	a4,a4,-36 # 80021b30 <devsw>
    80004b5c:	97ba                	add	a5,a5,a4
    80004b5e:	639c                	ld	a5,0(a5)
    80004b60:	c38d                	beqz	a5,80004b82 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004b62:	4505                	li	a0,1
    80004b64:	9782                	jalr	a5
    80004b66:	892a                	mv	s2,a0
    80004b68:	bf75                	j	80004b24 <fileread+0x60>
    panic("fileread");
    80004b6a:	00004517          	auipc	a0,0x4
    80004b6e:	d2e50513          	addi	a0,a0,-722 # 80008898 <syscalls+0x270>
    80004b72:	ffffc097          	auipc	ra,0xffffc
    80004b76:	9b8080e7          	jalr	-1608(ra) # 8000052a <panic>
    return -1;
    80004b7a:	597d                	li	s2,-1
    80004b7c:	b765                	j	80004b24 <fileread+0x60>
      return -1;
    80004b7e:	597d                	li	s2,-1
    80004b80:	b755                	j	80004b24 <fileread+0x60>
    80004b82:	597d                	li	s2,-1
    80004b84:	b745                	j	80004b24 <fileread+0x60>

0000000080004b86 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004b86:	715d                	addi	sp,sp,-80
    80004b88:	e486                	sd	ra,72(sp)
    80004b8a:	e0a2                	sd	s0,64(sp)
    80004b8c:	fc26                	sd	s1,56(sp)
    80004b8e:	f84a                	sd	s2,48(sp)
    80004b90:	f44e                	sd	s3,40(sp)
    80004b92:	f052                	sd	s4,32(sp)
    80004b94:	ec56                	sd	s5,24(sp)
    80004b96:	e85a                	sd	s6,16(sp)
    80004b98:	e45e                	sd	s7,8(sp)
    80004b9a:	e062                	sd	s8,0(sp)
    80004b9c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004b9e:	00954783          	lbu	a5,9(a0)
    80004ba2:	10078663          	beqz	a5,80004cae <filewrite+0x128>
    80004ba6:	892a                	mv	s2,a0
    80004ba8:	8aae                	mv	s5,a1
    80004baa:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bac:	411c                	lw	a5,0(a0)
    80004bae:	4705                	li	a4,1
    80004bb0:	02e78263          	beq	a5,a4,80004bd4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bb4:	470d                	li	a4,3
    80004bb6:	02e78663          	beq	a5,a4,80004be2 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004bba:	4709                	li	a4,2
    80004bbc:	0ee79163          	bne	a5,a4,80004c9e <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004bc0:	0ac05d63          	blez	a2,80004c7a <filewrite+0xf4>
    int i = 0;
    80004bc4:	4981                	li	s3,0
    80004bc6:	6b05                	lui	s6,0x1
    80004bc8:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004bcc:	6b85                	lui	s7,0x1
    80004bce:	c00b8b9b          	addiw	s7,s7,-1024
    80004bd2:	a861                	j	80004c6a <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004bd4:	6908                	ld	a0,16(a0)
    80004bd6:	00000097          	auipc	ra,0x0
    80004bda:	22e080e7          	jalr	558(ra) # 80004e04 <pipewrite>
    80004bde:	8a2a                	mv	s4,a0
    80004be0:	a045                	j	80004c80 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004be2:	02451783          	lh	a5,36(a0)
    80004be6:	03079693          	slli	a3,a5,0x30
    80004bea:	92c1                	srli	a3,a3,0x30
    80004bec:	4725                	li	a4,9
    80004bee:	0cd76263          	bltu	a4,a3,80004cb2 <filewrite+0x12c>
    80004bf2:	0792                	slli	a5,a5,0x4
    80004bf4:	0001d717          	auipc	a4,0x1d
    80004bf8:	f3c70713          	addi	a4,a4,-196 # 80021b30 <devsw>
    80004bfc:	97ba                	add	a5,a5,a4
    80004bfe:	679c                	ld	a5,8(a5)
    80004c00:	cbdd                	beqz	a5,80004cb6 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004c02:	4505                	li	a0,1
    80004c04:	9782                	jalr	a5
    80004c06:	8a2a                	mv	s4,a0
    80004c08:	a8a5                	j	80004c80 <filewrite+0xfa>
    80004c0a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004c0e:	00000097          	auipc	ra,0x0
    80004c12:	8b0080e7          	jalr	-1872(ra) # 800044be <begin_op>
      ilock(f->ip);
    80004c16:	01893503          	ld	a0,24(s2)
    80004c1a:	fffff097          	auipc	ra,0xfffff
    80004c1e:	ece080e7          	jalr	-306(ra) # 80003ae8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c22:	8762                	mv	a4,s8
    80004c24:	02092683          	lw	a3,32(s2)
    80004c28:	01598633          	add	a2,s3,s5
    80004c2c:	4585                	li	a1,1
    80004c2e:	01893503          	ld	a0,24(s2)
    80004c32:	fffff097          	auipc	ra,0xfffff
    80004c36:	262080e7          	jalr	610(ra) # 80003e94 <writei>
    80004c3a:	84aa                	mv	s1,a0
    80004c3c:	00a05763          	blez	a0,80004c4a <filewrite+0xc4>
        f->off += r;
    80004c40:	02092783          	lw	a5,32(s2)
    80004c44:	9fa9                	addw	a5,a5,a0
    80004c46:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c4a:	01893503          	ld	a0,24(s2)
    80004c4e:	fffff097          	auipc	ra,0xfffff
    80004c52:	f5c080e7          	jalr	-164(ra) # 80003baa <iunlock>
      end_op();
    80004c56:	00000097          	auipc	ra,0x0
    80004c5a:	8e8080e7          	jalr	-1816(ra) # 8000453e <end_op>

      if(r != n1){
    80004c5e:	009c1f63          	bne	s8,s1,80004c7c <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004c62:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004c66:	0149db63          	bge	s3,s4,80004c7c <filewrite+0xf6>
      int n1 = n - i;
    80004c6a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004c6e:	84be                	mv	s1,a5
    80004c70:	2781                	sext.w	a5,a5
    80004c72:	f8fb5ce3          	bge	s6,a5,80004c0a <filewrite+0x84>
    80004c76:	84de                	mv	s1,s7
    80004c78:	bf49                	j	80004c0a <filewrite+0x84>
    int i = 0;
    80004c7a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004c7c:	013a1f63          	bne	s4,s3,80004c9a <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c80:	8552                	mv	a0,s4
    80004c82:	60a6                	ld	ra,72(sp)
    80004c84:	6406                	ld	s0,64(sp)
    80004c86:	74e2                	ld	s1,56(sp)
    80004c88:	7942                	ld	s2,48(sp)
    80004c8a:	79a2                	ld	s3,40(sp)
    80004c8c:	7a02                	ld	s4,32(sp)
    80004c8e:	6ae2                	ld	s5,24(sp)
    80004c90:	6b42                	ld	s6,16(sp)
    80004c92:	6ba2                	ld	s7,8(sp)
    80004c94:	6c02                	ld	s8,0(sp)
    80004c96:	6161                	addi	sp,sp,80
    80004c98:	8082                	ret
    ret = (i == n ? n : -1);
    80004c9a:	5a7d                	li	s4,-1
    80004c9c:	b7d5                	j	80004c80 <filewrite+0xfa>
    panic("filewrite");
    80004c9e:	00004517          	auipc	a0,0x4
    80004ca2:	c0a50513          	addi	a0,a0,-1014 # 800088a8 <syscalls+0x280>
    80004ca6:	ffffc097          	auipc	ra,0xffffc
    80004caa:	884080e7          	jalr	-1916(ra) # 8000052a <panic>
    return -1;
    80004cae:	5a7d                	li	s4,-1
    80004cb0:	bfc1                	j	80004c80 <filewrite+0xfa>
      return -1;
    80004cb2:	5a7d                	li	s4,-1
    80004cb4:	b7f1                	j	80004c80 <filewrite+0xfa>
    80004cb6:	5a7d                	li	s4,-1
    80004cb8:	b7e1                	j	80004c80 <filewrite+0xfa>

0000000080004cba <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004cba:	7179                	addi	sp,sp,-48
    80004cbc:	f406                	sd	ra,40(sp)
    80004cbe:	f022                	sd	s0,32(sp)
    80004cc0:	ec26                	sd	s1,24(sp)
    80004cc2:	e84a                	sd	s2,16(sp)
    80004cc4:	e44e                	sd	s3,8(sp)
    80004cc6:	e052                	sd	s4,0(sp)
    80004cc8:	1800                	addi	s0,sp,48
    80004cca:	84aa                	mv	s1,a0
    80004ccc:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004cce:	0005b023          	sd	zero,0(a1)
    80004cd2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004cd6:	00000097          	auipc	ra,0x0
    80004cda:	bf8080e7          	jalr	-1032(ra) # 800048ce <filealloc>
    80004cde:	e088                	sd	a0,0(s1)
    80004ce0:	c551                	beqz	a0,80004d6c <pipealloc+0xb2>
    80004ce2:	00000097          	auipc	ra,0x0
    80004ce6:	bec080e7          	jalr	-1044(ra) # 800048ce <filealloc>
    80004cea:	00aa3023          	sd	a0,0(s4)
    80004cee:	c92d                	beqz	a0,80004d60 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004cf0:	ffffc097          	auipc	ra,0xffffc
    80004cf4:	de2080e7          	jalr	-542(ra) # 80000ad2 <kalloc>
    80004cf8:	892a                	mv	s2,a0
    80004cfa:	c125                	beqz	a0,80004d5a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004cfc:	4985                	li	s3,1
    80004cfe:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004d02:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004d06:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004d0a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004d0e:	00003597          	auipc	a1,0x3
    80004d12:	78a58593          	addi	a1,a1,1930 # 80008498 <states.0+0x1e0>
    80004d16:	ffffc097          	auipc	ra,0xffffc
    80004d1a:	e1c080e7          	jalr	-484(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80004d1e:	609c                	ld	a5,0(s1)
    80004d20:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d24:	609c                	ld	a5,0(s1)
    80004d26:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d2a:	609c                	ld	a5,0(s1)
    80004d2c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d30:	609c                	ld	a5,0(s1)
    80004d32:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d36:	000a3783          	ld	a5,0(s4)
    80004d3a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d3e:	000a3783          	ld	a5,0(s4)
    80004d42:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d46:	000a3783          	ld	a5,0(s4)
    80004d4a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d4e:	000a3783          	ld	a5,0(s4)
    80004d52:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d56:	4501                	li	a0,0
    80004d58:	a025                	j	80004d80 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d5a:	6088                	ld	a0,0(s1)
    80004d5c:	e501                	bnez	a0,80004d64 <pipealloc+0xaa>
    80004d5e:	a039                	j	80004d6c <pipealloc+0xb2>
    80004d60:	6088                	ld	a0,0(s1)
    80004d62:	c51d                	beqz	a0,80004d90 <pipealloc+0xd6>
    fileclose(*f0);
    80004d64:	00000097          	auipc	ra,0x0
    80004d68:	c26080e7          	jalr	-986(ra) # 8000498a <fileclose>
  if(*f1)
    80004d6c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004d70:	557d                	li	a0,-1
  if(*f1)
    80004d72:	c799                	beqz	a5,80004d80 <pipealloc+0xc6>
    fileclose(*f1);
    80004d74:	853e                	mv	a0,a5
    80004d76:	00000097          	auipc	ra,0x0
    80004d7a:	c14080e7          	jalr	-1004(ra) # 8000498a <fileclose>
  return -1;
    80004d7e:	557d                	li	a0,-1
}
    80004d80:	70a2                	ld	ra,40(sp)
    80004d82:	7402                	ld	s0,32(sp)
    80004d84:	64e2                	ld	s1,24(sp)
    80004d86:	6942                	ld	s2,16(sp)
    80004d88:	69a2                	ld	s3,8(sp)
    80004d8a:	6a02                	ld	s4,0(sp)
    80004d8c:	6145                	addi	sp,sp,48
    80004d8e:	8082                	ret
  return -1;
    80004d90:	557d                	li	a0,-1
    80004d92:	b7fd                	j	80004d80 <pipealloc+0xc6>

0000000080004d94 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004d94:	1101                	addi	sp,sp,-32
    80004d96:	ec06                	sd	ra,24(sp)
    80004d98:	e822                	sd	s0,16(sp)
    80004d9a:	e426                	sd	s1,8(sp)
    80004d9c:	e04a                	sd	s2,0(sp)
    80004d9e:	1000                	addi	s0,sp,32
    80004da0:	84aa                	mv	s1,a0
    80004da2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004da4:	ffffc097          	auipc	ra,0xffffc
    80004da8:	e1e080e7          	jalr	-482(ra) # 80000bc2 <acquire>
  if(writable){
    80004dac:	02090d63          	beqz	s2,80004de6 <pipeclose+0x52>
    pi->writeopen = 0;
    80004db0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004db4:	21848513          	addi	a0,s1,536
    80004db8:	ffffd097          	auipc	ra,0xffffd
    80004dbc:	4ce080e7          	jalr	1230(ra) # 80002286 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004dc0:	2204b783          	ld	a5,544(s1)
    80004dc4:	eb95                	bnez	a5,80004df8 <pipeclose+0x64>
    release(&pi->lock);
    80004dc6:	8526                	mv	a0,s1
    80004dc8:	ffffc097          	auipc	ra,0xffffc
    80004dcc:	eae080e7          	jalr	-338(ra) # 80000c76 <release>
    kfree((char*)pi);
    80004dd0:	8526                	mv	a0,s1
    80004dd2:	ffffc097          	auipc	ra,0xffffc
    80004dd6:	c04080e7          	jalr	-1020(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    80004dda:	60e2                	ld	ra,24(sp)
    80004ddc:	6442                	ld	s0,16(sp)
    80004dde:	64a2                	ld	s1,8(sp)
    80004de0:	6902                	ld	s2,0(sp)
    80004de2:	6105                	addi	sp,sp,32
    80004de4:	8082                	ret
    pi->readopen = 0;
    80004de6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004dea:	21c48513          	addi	a0,s1,540
    80004dee:	ffffd097          	auipc	ra,0xffffd
    80004df2:	498080e7          	jalr	1176(ra) # 80002286 <wakeup>
    80004df6:	b7e9                	j	80004dc0 <pipeclose+0x2c>
    release(&pi->lock);
    80004df8:	8526                	mv	a0,s1
    80004dfa:	ffffc097          	auipc	ra,0xffffc
    80004dfe:	e7c080e7          	jalr	-388(ra) # 80000c76 <release>
}
    80004e02:	bfe1                	j	80004dda <pipeclose+0x46>

0000000080004e04 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e04:	711d                	addi	sp,sp,-96
    80004e06:	ec86                	sd	ra,88(sp)
    80004e08:	e8a2                	sd	s0,80(sp)
    80004e0a:	e4a6                	sd	s1,72(sp)
    80004e0c:	e0ca                	sd	s2,64(sp)
    80004e0e:	fc4e                	sd	s3,56(sp)
    80004e10:	f852                	sd	s4,48(sp)
    80004e12:	f456                	sd	s5,40(sp)
    80004e14:	f05a                	sd	s6,32(sp)
    80004e16:	ec5e                	sd	s7,24(sp)
    80004e18:	e862                	sd	s8,16(sp)
    80004e1a:	1080                	addi	s0,sp,96
    80004e1c:	84aa                	mv	s1,a0
    80004e1e:	8aae                	mv	s5,a1
    80004e20:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e22:	ffffd097          	auipc	ra,0xffffd
    80004e26:	b74080e7          	jalr	-1164(ra) # 80001996 <myproc>
    80004e2a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004e2c:	8526                	mv	a0,s1
    80004e2e:	ffffc097          	auipc	ra,0xffffc
    80004e32:	d94080e7          	jalr	-620(ra) # 80000bc2 <acquire>
  while(i < n){
    80004e36:	0b405363          	blez	s4,80004edc <pipewrite+0xd8>
  int i = 0;
    80004e3a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e3c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004e3e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004e42:	21c48b93          	addi	s7,s1,540
    80004e46:	a089                	j	80004e88 <pipewrite+0x84>
      release(&pi->lock);
    80004e48:	8526                	mv	a0,s1
    80004e4a:	ffffc097          	auipc	ra,0xffffc
    80004e4e:	e2c080e7          	jalr	-468(ra) # 80000c76 <release>
      return -1;
    80004e52:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004e54:	854a                	mv	a0,s2
    80004e56:	60e6                	ld	ra,88(sp)
    80004e58:	6446                	ld	s0,80(sp)
    80004e5a:	64a6                	ld	s1,72(sp)
    80004e5c:	6906                	ld	s2,64(sp)
    80004e5e:	79e2                	ld	s3,56(sp)
    80004e60:	7a42                	ld	s4,48(sp)
    80004e62:	7aa2                	ld	s5,40(sp)
    80004e64:	7b02                	ld	s6,32(sp)
    80004e66:	6be2                	ld	s7,24(sp)
    80004e68:	6c42                	ld	s8,16(sp)
    80004e6a:	6125                	addi	sp,sp,96
    80004e6c:	8082                	ret
      wakeup(&pi->nread);
    80004e6e:	8562                	mv	a0,s8
    80004e70:	ffffd097          	auipc	ra,0xffffd
    80004e74:	416080e7          	jalr	1046(ra) # 80002286 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e78:	85a6                	mv	a1,s1
    80004e7a:	855e                	mv	a0,s7
    80004e7c:	ffffd097          	auipc	ra,0xffffd
    80004e80:	27e080e7          	jalr	638(ra) # 800020fa <sleep>
  while(i < n){
    80004e84:	05495d63          	bge	s2,s4,80004ede <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004e88:	2204a783          	lw	a5,544(s1)
    80004e8c:	dfd5                	beqz	a5,80004e48 <pipewrite+0x44>
    80004e8e:	0289a783          	lw	a5,40(s3)
    80004e92:	fbdd                	bnez	a5,80004e48 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004e94:	2184a783          	lw	a5,536(s1)
    80004e98:	21c4a703          	lw	a4,540(s1)
    80004e9c:	2007879b          	addiw	a5,a5,512
    80004ea0:	fcf707e3          	beq	a4,a5,80004e6e <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ea4:	4685                	li	a3,1
    80004ea6:	01590633          	add	a2,s2,s5
    80004eaa:	faf40593          	addi	a1,s0,-81
    80004eae:	0709b503          	ld	a0,112(s3)
    80004eb2:	ffffd097          	auipc	ra,0xffffd
    80004eb6:	818080e7          	jalr	-2024(ra) # 800016ca <copyin>
    80004eba:	03650263          	beq	a0,s6,80004ede <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ebe:	21c4a783          	lw	a5,540(s1)
    80004ec2:	0017871b          	addiw	a4,a5,1
    80004ec6:	20e4ae23          	sw	a4,540(s1)
    80004eca:	1ff7f793          	andi	a5,a5,511
    80004ece:	97a6                	add	a5,a5,s1
    80004ed0:	faf44703          	lbu	a4,-81(s0)
    80004ed4:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ed8:	2905                	addiw	s2,s2,1
    80004eda:	b76d                	j	80004e84 <pipewrite+0x80>
  int i = 0;
    80004edc:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004ede:	21848513          	addi	a0,s1,536
    80004ee2:	ffffd097          	auipc	ra,0xffffd
    80004ee6:	3a4080e7          	jalr	932(ra) # 80002286 <wakeup>
  release(&pi->lock);
    80004eea:	8526                	mv	a0,s1
    80004eec:	ffffc097          	auipc	ra,0xffffc
    80004ef0:	d8a080e7          	jalr	-630(ra) # 80000c76 <release>
  return i;
    80004ef4:	b785                	j	80004e54 <pipewrite+0x50>

0000000080004ef6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ef6:	715d                	addi	sp,sp,-80
    80004ef8:	e486                	sd	ra,72(sp)
    80004efa:	e0a2                	sd	s0,64(sp)
    80004efc:	fc26                	sd	s1,56(sp)
    80004efe:	f84a                	sd	s2,48(sp)
    80004f00:	f44e                	sd	s3,40(sp)
    80004f02:	f052                	sd	s4,32(sp)
    80004f04:	ec56                	sd	s5,24(sp)
    80004f06:	e85a                	sd	s6,16(sp)
    80004f08:	0880                	addi	s0,sp,80
    80004f0a:	84aa                	mv	s1,a0
    80004f0c:	892e                	mv	s2,a1
    80004f0e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f10:	ffffd097          	auipc	ra,0xffffd
    80004f14:	a86080e7          	jalr	-1402(ra) # 80001996 <myproc>
    80004f18:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f1a:	8526                	mv	a0,s1
    80004f1c:	ffffc097          	auipc	ra,0xffffc
    80004f20:	ca6080e7          	jalr	-858(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f24:	2184a703          	lw	a4,536(s1)
    80004f28:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f2c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f30:	02f71463          	bne	a4,a5,80004f58 <piperead+0x62>
    80004f34:	2244a783          	lw	a5,548(s1)
    80004f38:	c385                	beqz	a5,80004f58 <piperead+0x62>
    if(pr->killed){
    80004f3a:	028a2783          	lw	a5,40(s4)
    80004f3e:	ebc1                	bnez	a5,80004fce <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f40:	85a6                	mv	a1,s1
    80004f42:	854e                	mv	a0,s3
    80004f44:	ffffd097          	auipc	ra,0xffffd
    80004f48:	1b6080e7          	jalr	438(ra) # 800020fa <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f4c:	2184a703          	lw	a4,536(s1)
    80004f50:	21c4a783          	lw	a5,540(s1)
    80004f54:	fef700e3          	beq	a4,a5,80004f34 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f58:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f5a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f5c:	05505363          	blez	s5,80004fa2 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004f60:	2184a783          	lw	a5,536(s1)
    80004f64:	21c4a703          	lw	a4,540(s1)
    80004f68:	02f70d63          	beq	a4,a5,80004fa2 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004f6c:	0017871b          	addiw	a4,a5,1
    80004f70:	20e4ac23          	sw	a4,536(s1)
    80004f74:	1ff7f793          	andi	a5,a5,511
    80004f78:	97a6                	add	a5,a5,s1
    80004f7a:	0187c783          	lbu	a5,24(a5)
    80004f7e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f82:	4685                	li	a3,1
    80004f84:	fbf40613          	addi	a2,s0,-65
    80004f88:	85ca                	mv	a1,s2
    80004f8a:	070a3503          	ld	a0,112(s4)
    80004f8e:	ffffc097          	auipc	ra,0xffffc
    80004f92:	6b0080e7          	jalr	1712(ra) # 8000163e <copyout>
    80004f96:	01650663          	beq	a0,s6,80004fa2 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f9a:	2985                	addiw	s3,s3,1
    80004f9c:	0905                	addi	s2,s2,1
    80004f9e:	fd3a91e3          	bne	s5,s3,80004f60 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004fa2:	21c48513          	addi	a0,s1,540
    80004fa6:	ffffd097          	auipc	ra,0xffffd
    80004faa:	2e0080e7          	jalr	736(ra) # 80002286 <wakeup>
  release(&pi->lock);
    80004fae:	8526                	mv	a0,s1
    80004fb0:	ffffc097          	auipc	ra,0xffffc
    80004fb4:	cc6080e7          	jalr	-826(ra) # 80000c76 <release>
  return i;
}
    80004fb8:	854e                	mv	a0,s3
    80004fba:	60a6                	ld	ra,72(sp)
    80004fbc:	6406                	ld	s0,64(sp)
    80004fbe:	74e2                	ld	s1,56(sp)
    80004fc0:	7942                	ld	s2,48(sp)
    80004fc2:	79a2                	ld	s3,40(sp)
    80004fc4:	7a02                	ld	s4,32(sp)
    80004fc6:	6ae2                	ld	s5,24(sp)
    80004fc8:	6b42                	ld	s6,16(sp)
    80004fca:	6161                	addi	sp,sp,80
    80004fcc:	8082                	ret
      release(&pi->lock);
    80004fce:	8526                	mv	a0,s1
    80004fd0:	ffffc097          	auipc	ra,0xffffc
    80004fd4:	ca6080e7          	jalr	-858(ra) # 80000c76 <release>
      return -1;
    80004fd8:	59fd                	li	s3,-1
    80004fda:	bff9                	j	80004fb8 <piperead+0xc2>

0000000080004fdc <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004fdc:	de010113          	addi	sp,sp,-544
    80004fe0:	20113c23          	sd	ra,536(sp)
    80004fe4:	20813823          	sd	s0,528(sp)
    80004fe8:	20913423          	sd	s1,520(sp)
    80004fec:	21213023          	sd	s2,512(sp)
    80004ff0:	ffce                	sd	s3,504(sp)
    80004ff2:	fbd2                	sd	s4,496(sp)
    80004ff4:	f7d6                	sd	s5,488(sp)
    80004ff6:	f3da                	sd	s6,480(sp)
    80004ff8:	efde                	sd	s7,472(sp)
    80004ffa:	ebe2                	sd	s8,464(sp)
    80004ffc:	e7e6                	sd	s9,456(sp)
    80004ffe:	e3ea                	sd	s10,448(sp)
    80005000:	ff6e                	sd	s11,440(sp)
    80005002:	1400                	addi	s0,sp,544
    80005004:	892a                	mv	s2,a0
    80005006:	dea43423          	sd	a0,-536(s0)
    8000500a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000500e:	ffffd097          	auipc	ra,0xffffd
    80005012:	988080e7          	jalr	-1656(ra) # 80001996 <myproc>
    80005016:	84aa                	mv	s1,a0

  begin_op();
    80005018:	fffff097          	auipc	ra,0xfffff
    8000501c:	4a6080e7          	jalr	1190(ra) # 800044be <begin_op>

  if((ip = namei(path)) == 0){
    80005020:	854a                	mv	a0,s2
    80005022:	fffff097          	auipc	ra,0xfffff
    80005026:	27c080e7          	jalr	636(ra) # 8000429e <namei>
    8000502a:	c93d                	beqz	a0,800050a0 <exec+0xc4>
    8000502c:	8aaa                	mv	s5,a0
    end_op();
    /////////////////////////////we changed the return value in this case from -1
    return -2;
  }
  ilock(ip);
    8000502e:	fffff097          	auipc	ra,0xfffff
    80005032:	aba080e7          	jalr	-1350(ra) # 80003ae8 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005036:	04000713          	li	a4,64
    8000503a:	4681                	li	a3,0
    8000503c:	e4840613          	addi	a2,s0,-440
    80005040:	4581                	li	a1,0
    80005042:	8556                	mv	a0,s5
    80005044:	fffff097          	auipc	ra,0xfffff
    80005048:	d58080e7          	jalr	-680(ra) # 80003d9c <readi>
    8000504c:	04000793          	li	a5,64
    80005050:	00f51a63          	bne	a0,a5,80005064 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005054:	e4842703          	lw	a4,-440(s0)
    80005058:	464c47b7          	lui	a5,0x464c4
    8000505c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005060:	04f70663          	beq	a4,a5,800050ac <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005064:	8556                	mv	a0,s5
    80005066:	fffff097          	auipc	ra,0xfffff
    8000506a:	ce4080e7          	jalr	-796(ra) # 80003d4a <iunlockput>
    end_op();
    8000506e:	fffff097          	auipc	ra,0xfffff
    80005072:	4d0080e7          	jalr	1232(ra) # 8000453e <end_op>
  }
  return -1;
    80005076:	557d                	li	a0,-1
}
    80005078:	21813083          	ld	ra,536(sp)
    8000507c:	21013403          	ld	s0,528(sp)
    80005080:	20813483          	ld	s1,520(sp)
    80005084:	20013903          	ld	s2,512(sp)
    80005088:	79fe                	ld	s3,504(sp)
    8000508a:	7a5e                	ld	s4,496(sp)
    8000508c:	7abe                	ld	s5,488(sp)
    8000508e:	7b1e                	ld	s6,480(sp)
    80005090:	6bfe                	ld	s7,472(sp)
    80005092:	6c5e                	ld	s8,464(sp)
    80005094:	6cbe                	ld	s9,456(sp)
    80005096:	6d1e                	ld	s10,448(sp)
    80005098:	7dfa                	ld	s11,440(sp)
    8000509a:	22010113          	addi	sp,sp,544
    8000509e:	8082                	ret
    end_op();
    800050a0:	fffff097          	auipc	ra,0xfffff
    800050a4:	49e080e7          	jalr	1182(ra) # 8000453e <end_op>
    return -2;
    800050a8:	5579                	li	a0,-2
    800050aa:	b7f9                	j	80005078 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800050ac:	8526                	mv	a0,s1
    800050ae:	ffffd097          	auipc	ra,0xffffd
    800050b2:	9ac080e7          	jalr	-1620(ra) # 80001a5a <proc_pagetable>
    800050b6:	8b2a                	mv	s6,a0
    800050b8:	d555                	beqz	a0,80005064 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050ba:	e6842783          	lw	a5,-408(s0)
    800050be:	e8045703          	lhu	a4,-384(s0)
    800050c2:	c735                	beqz	a4,8000512e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800050c4:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050c6:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800050ca:	6a05                	lui	s4,0x1
    800050cc:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800050d0:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    800050d4:	6d85                	lui	s11,0x1
    800050d6:	7d7d                	lui	s10,0xfffff
    800050d8:	ac1d                	j	8000530e <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800050da:	00003517          	auipc	a0,0x3
    800050de:	7de50513          	addi	a0,a0,2014 # 800088b8 <syscalls+0x290>
    800050e2:	ffffb097          	auipc	ra,0xffffb
    800050e6:	448080e7          	jalr	1096(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800050ea:	874a                	mv	a4,s2
    800050ec:	009c86bb          	addw	a3,s9,s1
    800050f0:	4581                	li	a1,0
    800050f2:	8556                	mv	a0,s5
    800050f4:	fffff097          	auipc	ra,0xfffff
    800050f8:	ca8080e7          	jalr	-856(ra) # 80003d9c <readi>
    800050fc:	2501                	sext.w	a0,a0
    800050fe:	1aa91863          	bne	s2,a0,800052ae <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80005102:	009d84bb          	addw	s1,s11,s1
    80005106:	013d09bb          	addw	s3,s10,s3
    8000510a:	1f74f263          	bgeu	s1,s7,800052ee <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    8000510e:	02049593          	slli	a1,s1,0x20
    80005112:	9181                	srli	a1,a1,0x20
    80005114:	95e2                	add	a1,a1,s8
    80005116:	855a                	mv	a0,s6
    80005118:	ffffc097          	auipc	ra,0xffffc
    8000511c:	f34080e7          	jalr	-204(ra) # 8000104c <walkaddr>
    80005120:	862a                	mv	a2,a0
    if(pa == 0)
    80005122:	dd45                	beqz	a0,800050da <exec+0xfe>
      n = PGSIZE;
    80005124:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005126:	fd49f2e3          	bgeu	s3,s4,800050ea <exec+0x10e>
      n = sz - i;
    8000512a:	894e                	mv	s2,s3
    8000512c:	bf7d                	j	800050ea <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000512e:	4481                	li	s1,0
  iunlockput(ip);
    80005130:	8556                	mv	a0,s5
    80005132:	fffff097          	auipc	ra,0xfffff
    80005136:	c18080e7          	jalr	-1000(ra) # 80003d4a <iunlockput>
  end_op();
    8000513a:	fffff097          	auipc	ra,0xfffff
    8000513e:	404080e7          	jalr	1028(ra) # 8000453e <end_op>
  p = myproc();
    80005142:	ffffd097          	auipc	ra,0xffffd
    80005146:	854080e7          	jalr	-1964(ra) # 80001996 <myproc>
    8000514a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000514c:	06853d03          	ld	s10,104(a0)
  sz = PGROUNDUP(sz);
    80005150:	6785                	lui	a5,0x1
    80005152:	17fd                	addi	a5,a5,-1
    80005154:	94be                	add	s1,s1,a5
    80005156:	77fd                	lui	a5,0xfffff
    80005158:	8fe5                	and	a5,a5,s1
    8000515a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000515e:	6609                	lui	a2,0x2
    80005160:	963e                	add	a2,a2,a5
    80005162:	85be                	mv	a1,a5
    80005164:	855a                	mv	a0,s6
    80005166:	ffffc097          	auipc	ra,0xffffc
    8000516a:	288080e7          	jalr	648(ra) # 800013ee <uvmalloc>
    8000516e:	8c2a                	mv	s8,a0
  ip = 0;
    80005170:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005172:	12050e63          	beqz	a0,800052ae <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005176:	75f9                	lui	a1,0xffffe
    80005178:	95aa                	add	a1,a1,a0
    8000517a:	855a                	mv	a0,s6
    8000517c:	ffffc097          	auipc	ra,0xffffc
    80005180:	490080e7          	jalr	1168(ra) # 8000160c <uvmclear>
  stackbase = sp - PGSIZE;
    80005184:	7afd                	lui	s5,0xfffff
    80005186:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005188:	df043783          	ld	a5,-528(s0)
    8000518c:	6388                	ld	a0,0(a5)
    8000518e:	c925                	beqz	a0,800051fe <exec+0x222>
    80005190:	e8840993          	addi	s3,s0,-376
    80005194:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005198:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000519a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000519c:	ffffc097          	auipc	ra,0xffffc
    800051a0:	ca6080e7          	jalr	-858(ra) # 80000e42 <strlen>
    800051a4:	0015079b          	addiw	a5,a0,1
    800051a8:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800051ac:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800051b0:	13596363          	bltu	s2,s5,800052d6 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800051b4:	df043d83          	ld	s11,-528(s0)
    800051b8:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800051bc:	8552                	mv	a0,s4
    800051be:	ffffc097          	auipc	ra,0xffffc
    800051c2:	c84080e7          	jalr	-892(ra) # 80000e42 <strlen>
    800051c6:	0015069b          	addiw	a3,a0,1
    800051ca:	8652                	mv	a2,s4
    800051cc:	85ca                	mv	a1,s2
    800051ce:	855a                	mv	a0,s6
    800051d0:	ffffc097          	auipc	ra,0xffffc
    800051d4:	46e080e7          	jalr	1134(ra) # 8000163e <copyout>
    800051d8:	10054363          	bltz	a0,800052de <exec+0x302>
    ustack[argc] = sp;
    800051dc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800051e0:	0485                	addi	s1,s1,1
    800051e2:	008d8793          	addi	a5,s11,8
    800051e6:	def43823          	sd	a5,-528(s0)
    800051ea:	008db503          	ld	a0,8(s11)
    800051ee:	c911                	beqz	a0,80005202 <exec+0x226>
    if(argc >= MAXARG)
    800051f0:	09a1                	addi	s3,s3,8
    800051f2:	fb3c95e3          	bne	s9,s3,8000519c <exec+0x1c0>
  sz = sz1;
    800051f6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051fa:	4a81                	li	s5,0
    800051fc:	a84d                	j	800052ae <exec+0x2d2>
  sp = sz;
    800051fe:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005200:	4481                	li	s1,0
  ustack[argc] = 0;
    80005202:	00349793          	slli	a5,s1,0x3
    80005206:	f9040713          	addi	a4,s0,-112
    8000520a:	97ba                	add	a5,a5,a4
    8000520c:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    80005210:	00148693          	addi	a3,s1,1
    80005214:	068e                	slli	a3,a3,0x3
    80005216:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000521a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000521e:	01597663          	bgeu	s2,s5,8000522a <exec+0x24e>
  sz = sz1;
    80005222:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005226:	4a81                	li	s5,0
    80005228:	a059                	j	800052ae <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000522a:	e8840613          	addi	a2,s0,-376
    8000522e:	85ca                	mv	a1,s2
    80005230:	855a                	mv	a0,s6
    80005232:	ffffc097          	auipc	ra,0xffffc
    80005236:	40c080e7          	jalr	1036(ra) # 8000163e <copyout>
    8000523a:	0a054663          	bltz	a0,800052e6 <exec+0x30a>
  p->trapframe->a1 = sp;
    8000523e:	078bb783          	ld	a5,120(s7) # 1078 <_entry-0x7fffef88>
    80005242:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005246:	de843783          	ld	a5,-536(s0)
    8000524a:	0007c703          	lbu	a4,0(a5)
    8000524e:	cf11                	beqz	a4,8000526a <exec+0x28e>
    80005250:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005252:	02f00693          	li	a3,47
    80005256:	a039                	j	80005264 <exec+0x288>
      last = s+1;
    80005258:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000525c:	0785                	addi	a5,a5,1
    8000525e:	fff7c703          	lbu	a4,-1(a5)
    80005262:	c701                	beqz	a4,8000526a <exec+0x28e>
    if(*s == '/')
    80005264:	fed71ce3          	bne	a4,a3,8000525c <exec+0x280>
    80005268:	bfc5                	j	80005258 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000526a:	4641                	li	a2,16
    8000526c:	de843583          	ld	a1,-536(s0)
    80005270:	178b8513          	addi	a0,s7,376
    80005274:	ffffc097          	auipc	ra,0xffffc
    80005278:	b9c080e7          	jalr	-1124(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    8000527c:	070bb503          	ld	a0,112(s7)
  p->pagetable = pagetable;
    80005280:	076bb823          	sd	s6,112(s7)
  p->sz = sz;
    80005284:	078bb423          	sd	s8,104(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005288:	078bb783          	ld	a5,120(s7)
    8000528c:	e6043703          	ld	a4,-416(s0)
    80005290:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005292:	078bb783          	ld	a5,120(s7)
    80005296:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000529a:	85ea                	mv	a1,s10
    8000529c:	ffffd097          	auipc	ra,0xffffd
    800052a0:	85a080e7          	jalr	-1958(ra) # 80001af6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800052a4:	0004851b          	sext.w	a0,s1
    800052a8:	bbc1                	j	80005078 <exec+0x9c>
    800052aa:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    800052ae:	df843583          	ld	a1,-520(s0)
    800052b2:	855a                	mv	a0,s6
    800052b4:	ffffd097          	auipc	ra,0xffffd
    800052b8:	842080e7          	jalr	-1982(ra) # 80001af6 <proc_freepagetable>
  if(ip){
    800052bc:	da0a94e3          	bnez	s5,80005064 <exec+0x88>
  return -1;
    800052c0:	557d                	li	a0,-1
    800052c2:	bb5d                	j	80005078 <exec+0x9c>
    800052c4:	de943c23          	sd	s1,-520(s0)
    800052c8:	b7dd                	j	800052ae <exec+0x2d2>
    800052ca:	de943c23          	sd	s1,-520(s0)
    800052ce:	b7c5                	j	800052ae <exec+0x2d2>
    800052d0:	de943c23          	sd	s1,-520(s0)
    800052d4:	bfe9                	j	800052ae <exec+0x2d2>
  sz = sz1;
    800052d6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052da:	4a81                	li	s5,0
    800052dc:	bfc9                	j	800052ae <exec+0x2d2>
  sz = sz1;
    800052de:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052e2:	4a81                	li	s5,0
    800052e4:	b7e9                	j	800052ae <exec+0x2d2>
  sz = sz1;
    800052e6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052ea:	4a81                	li	s5,0
    800052ec:	b7c9                	j	800052ae <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800052ee:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052f2:	e0843783          	ld	a5,-504(s0)
    800052f6:	0017869b          	addiw	a3,a5,1
    800052fa:	e0d43423          	sd	a3,-504(s0)
    800052fe:	e0043783          	ld	a5,-512(s0)
    80005302:	0387879b          	addiw	a5,a5,56
    80005306:	e8045703          	lhu	a4,-384(s0)
    8000530a:	e2e6d3e3          	bge	a3,a4,80005130 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000530e:	2781                	sext.w	a5,a5
    80005310:	e0f43023          	sd	a5,-512(s0)
    80005314:	03800713          	li	a4,56
    80005318:	86be                	mv	a3,a5
    8000531a:	e1040613          	addi	a2,s0,-496
    8000531e:	4581                	li	a1,0
    80005320:	8556                	mv	a0,s5
    80005322:	fffff097          	auipc	ra,0xfffff
    80005326:	a7a080e7          	jalr	-1414(ra) # 80003d9c <readi>
    8000532a:	03800793          	li	a5,56
    8000532e:	f6f51ee3          	bne	a0,a5,800052aa <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80005332:	e1042783          	lw	a5,-496(s0)
    80005336:	4705                	li	a4,1
    80005338:	fae79de3          	bne	a5,a4,800052f2 <exec+0x316>
    if(ph.memsz < ph.filesz)
    8000533c:	e3843603          	ld	a2,-456(s0)
    80005340:	e3043783          	ld	a5,-464(s0)
    80005344:	f8f660e3          	bltu	a2,a5,800052c4 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005348:	e2043783          	ld	a5,-480(s0)
    8000534c:	963e                	add	a2,a2,a5
    8000534e:	f6f66ee3          	bltu	a2,a5,800052ca <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005352:	85a6                	mv	a1,s1
    80005354:	855a                	mv	a0,s6
    80005356:	ffffc097          	auipc	ra,0xffffc
    8000535a:	098080e7          	jalr	152(ra) # 800013ee <uvmalloc>
    8000535e:	dea43c23          	sd	a0,-520(s0)
    80005362:	d53d                	beqz	a0,800052d0 <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    80005364:	e2043c03          	ld	s8,-480(s0)
    80005368:	de043783          	ld	a5,-544(s0)
    8000536c:	00fc77b3          	and	a5,s8,a5
    80005370:	ff9d                	bnez	a5,800052ae <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005372:	e1842c83          	lw	s9,-488(s0)
    80005376:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000537a:	f60b8ae3          	beqz	s7,800052ee <exec+0x312>
    8000537e:	89de                	mv	s3,s7
    80005380:	4481                	li	s1,0
    80005382:	b371                	j	8000510e <exec+0x132>

0000000080005384 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005384:	7179                	addi	sp,sp,-48
    80005386:	f406                	sd	ra,40(sp)
    80005388:	f022                	sd	s0,32(sp)
    8000538a:	ec26                	sd	s1,24(sp)
    8000538c:	e84a                	sd	s2,16(sp)
    8000538e:	1800                	addi	s0,sp,48
    80005390:	892e                	mv	s2,a1
    80005392:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005394:	fdc40593          	addi	a1,s0,-36
    80005398:	ffffe097          	auipc	ra,0xffffe
    8000539c:	a58080e7          	jalr	-1448(ra) # 80002df0 <argint>
    800053a0:	04054063          	bltz	a0,800053e0 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800053a4:	fdc42703          	lw	a4,-36(s0)
    800053a8:	47bd                	li	a5,15
    800053aa:	02e7ed63          	bltu	a5,a4,800053e4 <argfd+0x60>
    800053ae:	ffffc097          	auipc	ra,0xffffc
    800053b2:	5e8080e7          	jalr	1512(ra) # 80001996 <myproc>
    800053b6:	fdc42703          	lw	a4,-36(s0)
    800053ba:	01e70793          	addi	a5,a4,30
    800053be:	078e                	slli	a5,a5,0x3
    800053c0:	953e                	add	a0,a0,a5
    800053c2:	611c                	ld	a5,0(a0)
    800053c4:	c395                	beqz	a5,800053e8 <argfd+0x64>
    return -1;
  if(pfd)
    800053c6:	00090463          	beqz	s2,800053ce <argfd+0x4a>
    *pfd = fd;
    800053ca:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800053ce:	4501                	li	a0,0
  if(pf)
    800053d0:	c091                	beqz	s1,800053d4 <argfd+0x50>
    *pf = f;
    800053d2:	e09c                	sd	a5,0(s1)
}
    800053d4:	70a2                	ld	ra,40(sp)
    800053d6:	7402                	ld	s0,32(sp)
    800053d8:	64e2                	ld	s1,24(sp)
    800053da:	6942                	ld	s2,16(sp)
    800053dc:	6145                	addi	sp,sp,48
    800053de:	8082                	ret
    return -1;
    800053e0:	557d                	li	a0,-1
    800053e2:	bfcd                	j	800053d4 <argfd+0x50>
    return -1;
    800053e4:	557d                	li	a0,-1
    800053e6:	b7fd                	j	800053d4 <argfd+0x50>
    800053e8:	557d                	li	a0,-1
    800053ea:	b7ed                	j	800053d4 <argfd+0x50>

00000000800053ec <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800053ec:	1101                	addi	sp,sp,-32
    800053ee:	ec06                	sd	ra,24(sp)
    800053f0:	e822                	sd	s0,16(sp)
    800053f2:	e426                	sd	s1,8(sp)
    800053f4:	1000                	addi	s0,sp,32
    800053f6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800053f8:	ffffc097          	auipc	ra,0xffffc
    800053fc:	59e080e7          	jalr	1438(ra) # 80001996 <myproc>
    80005400:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005402:	0f050793          	addi	a5,a0,240
    80005406:	4501                	li	a0,0
    80005408:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000540a:	6398                	ld	a4,0(a5)
    8000540c:	cb19                	beqz	a4,80005422 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000540e:	2505                	addiw	a0,a0,1
    80005410:	07a1                	addi	a5,a5,8
    80005412:	fed51ce3          	bne	a0,a3,8000540a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005416:	557d                	li	a0,-1
}
    80005418:	60e2                	ld	ra,24(sp)
    8000541a:	6442                	ld	s0,16(sp)
    8000541c:	64a2                	ld	s1,8(sp)
    8000541e:	6105                	addi	sp,sp,32
    80005420:	8082                	ret
      p->ofile[fd] = f;
    80005422:	01e50793          	addi	a5,a0,30
    80005426:	078e                	slli	a5,a5,0x3
    80005428:	963e                	add	a2,a2,a5
    8000542a:	e204                	sd	s1,0(a2)
      return fd;
    8000542c:	b7f5                	j	80005418 <fdalloc+0x2c>

000000008000542e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000542e:	715d                	addi	sp,sp,-80
    80005430:	e486                	sd	ra,72(sp)
    80005432:	e0a2                	sd	s0,64(sp)
    80005434:	fc26                	sd	s1,56(sp)
    80005436:	f84a                	sd	s2,48(sp)
    80005438:	f44e                	sd	s3,40(sp)
    8000543a:	f052                	sd	s4,32(sp)
    8000543c:	ec56                	sd	s5,24(sp)
    8000543e:	0880                	addi	s0,sp,80
    80005440:	89ae                	mv	s3,a1
    80005442:	8ab2                	mv	s5,a2
    80005444:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005446:	fb040593          	addi	a1,s0,-80
    8000544a:	fffff097          	auipc	ra,0xfffff
    8000544e:	e72080e7          	jalr	-398(ra) # 800042bc <nameiparent>
    80005452:	892a                	mv	s2,a0
    80005454:	12050e63          	beqz	a0,80005590 <create+0x162>
    return 0;

  ilock(dp);
    80005458:	ffffe097          	auipc	ra,0xffffe
    8000545c:	690080e7          	jalr	1680(ra) # 80003ae8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005460:	4601                	li	a2,0
    80005462:	fb040593          	addi	a1,s0,-80
    80005466:	854a                	mv	a0,s2
    80005468:	fffff097          	auipc	ra,0xfffff
    8000546c:	b64080e7          	jalr	-1180(ra) # 80003fcc <dirlookup>
    80005470:	84aa                	mv	s1,a0
    80005472:	c921                	beqz	a0,800054c2 <create+0x94>
    iunlockput(dp);
    80005474:	854a                	mv	a0,s2
    80005476:	fffff097          	auipc	ra,0xfffff
    8000547a:	8d4080e7          	jalr	-1836(ra) # 80003d4a <iunlockput>
    ilock(ip);
    8000547e:	8526                	mv	a0,s1
    80005480:	ffffe097          	auipc	ra,0xffffe
    80005484:	668080e7          	jalr	1640(ra) # 80003ae8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005488:	2981                	sext.w	s3,s3
    8000548a:	4789                	li	a5,2
    8000548c:	02f99463          	bne	s3,a5,800054b4 <create+0x86>
    80005490:	0444d783          	lhu	a5,68(s1)
    80005494:	37f9                	addiw	a5,a5,-2
    80005496:	17c2                	slli	a5,a5,0x30
    80005498:	93c1                	srli	a5,a5,0x30
    8000549a:	4705                	li	a4,1
    8000549c:	00f76c63          	bltu	a4,a5,800054b4 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800054a0:	8526                	mv	a0,s1
    800054a2:	60a6                	ld	ra,72(sp)
    800054a4:	6406                	ld	s0,64(sp)
    800054a6:	74e2                	ld	s1,56(sp)
    800054a8:	7942                	ld	s2,48(sp)
    800054aa:	79a2                	ld	s3,40(sp)
    800054ac:	7a02                	ld	s4,32(sp)
    800054ae:	6ae2                	ld	s5,24(sp)
    800054b0:	6161                	addi	sp,sp,80
    800054b2:	8082                	ret
    iunlockput(ip);
    800054b4:	8526                	mv	a0,s1
    800054b6:	fffff097          	auipc	ra,0xfffff
    800054ba:	894080e7          	jalr	-1900(ra) # 80003d4a <iunlockput>
    return 0;
    800054be:	4481                	li	s1,0
    800054c0:	b7c5                	j	800054a0 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800054c2:	85ce                	mv	a1,s3
    800054c4:	00092503          	lw	a0,0(s2)
    800054c8:	ffffe097          	auipc	ra,0xffffe
    800054cc:	488080e7          	jalr	1160(ra) # 80003950 <ialloc>
    800054d0:	84aa                	mv	s1,a0
    800054d2:	c521                	beqz	a0,8000551a <create+0xec>
  ilock(ip);
    800054d4:	ffffe097          	auipc	ra,0xffffe
    800054d8:	614080e7          	jalr	1556(ra) # 80003ae8 <ilock>
  ip->major = major;
    800054dc:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800054e0:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800054e4:	4a05                	li	s4,1
    800054e6:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800054ea:	8526                	mv	a0,s1
    800054ec:	ffffe097          	auipc	ra,0xffffe
    800054f0:	532080e7          	jalr	1330(ra) # 80003a1e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800054f4:	2981                	sext.w	s3,s3
    800054f6:	03498a63          	beq	s3,s4,8000552a <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800054fa:	40d0                	lw	a2,4(s1)
    800054fc:	fb040593          	addi	a1,s0,-80
    80005500:	854a                	mv	a0,s2
    80005502:	fffff097          	auipc	ra,0xfffff
    80005506:	cda080e7          	jalr	-806(ra) # 800041dc <dirlink>
    8000550a:	06054b63          	bltz	a0,80005580 <create+0x152>
  iunlockput(dp);
    8000550e:	854a                	mv	a0,s2
    80005510:	fffff097          	auipc	ra,0xfffff
    80005514:	83a080e7          	jalr	-1990(ra) # 80003d4a <iunlockput>
  return ip;
    80005518:	b761                	j	800054a0 <create+0x72>
    panic("create: ialloc");
    8000551a:	00003517          	auipc	a0,0x3
    8000551e:	3be50513          	addi	a0,a0,958 # 800088d8 <syscalls+0x2b0>
    80005522:	ffffb097          	auipc	ra,0xffffb
    80005526:	008080e7          	jalr	8(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    8000552a:	04a95783          	lhu	a5,74(s2)
    8000552e:	2785                	addiw	a5,a5,1
    80005530:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005534:	854a                	mv	a0,s2
    80005536:	ffffe097          	auipc	ra,0xffffe
    8000553a:	4e8080e7          	jalr	1256(ra) # 80003a1e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000553e:	40d0                	lw	a2,4(s1)
    80005540:	00003597          	auipc	a1,0x3
    80005544:	3a858593          	addi	a1,a1,936 # 800088e8 <syscalls+0x2c0>
    80005548:	8526                	mv	a0,s1
    8000554a:	fffff097          	auipc	ra,0xfffff
    8000554e:	c92080e7          	jalr	-878(ra) # 800041dc <dirlink>
    80005552:	00054f63          	bltz	a0,80005570 <create+0x142>
    80005556:	00492603          	lw	a2,4(s2)
    8000555a:	00003597          	auipc	a1,0x3
    8000555e:	39658593          	addi	a1,a1,918 # 800088f0 <syscalls+0x2c8>
    80005562:	8526                	mv	a0,s1
    80005564:	fffff097          	auipc	ra,0xfffff
    80005568:	c78080e7          	jalr	-904(ra) # 800041dc <dirlink>
    8000556c:	f80557e3          	bgez	a0,800054fa <create+0xcc>
      panic("create dots");
    80005570:	00003517          	auipc	a0,0x3
    80005574:	38850513          	addi	a0,a0,904 # 800088f8 <syscalls+0x2d0>
    80005578:	ffffb097          	auipc	ra,0xffffb
    8000557c:	fb2080e7          	jalr	-78(ra) # 8000052a <panic>
    panic("create: dirlink");
    80005580:	00003517          	auipc	a0,0x3
    80005584:	38850513          	addi	a0,a0,904 # 80008908 <syscalls+0x2e0>
    80005588:	ffffb097          	auipc	ra,0xffffb
    8000558c:	fa2080e7          	jalr	-94(ra) # 8000052a <panic>
    return 0;
    80005590:	84aa                	mv	s1,a0
    80005592:	b739                	j	800054a0 <create+0x72>

0000000080005594 <sys_dup>:
{
    80005594:	7179                	addi	sp,sp,-48
    80005596:	f406                	sd	ra,40(sp)
    80005598:	f022                	sd	s0,32(sp)
    8000559a:	ec26                	sd	s1,24(sp)
    8000559c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000559e:	fd840613          	addi	a2,s0,-40
    800055a2:	4581                	li	a1,0
    800055a4:	4501                	li	a0,0
    800055a6:	00000097          	auipc	ra,0x0
    800055aa:	dde080e7          	jalr	-546(ra) # 80005384 <argfd>
    return -1;
    800055ae:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800055b0:	02054363          	bltz	a0,800055d6 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800055b4:	fd843503          	ld	a0,-40(s0)
    800055b8:	00000097          	auipc	ra,0x0
    800055bc:	e34080e7          	jalr	-460(ra) # 800053ec <fdalloc>
    800055c0:	84aa                	mv	s1,a0
    return -1;
    800055c2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800055c4:	00054963          	bltz	a0,800055d6 <sys_dup+0x42>
  filedup(f);
    800055c8:	fd843503          	ld	a0,-40(s0)
    800055cc:	fffff097          	auipc	ra,0xfffff
    800055d0:	36c080e7          	jalr	876(ra) # 80004938 <filedup>
  return fd;
    800055d4:	87a6                	mv	a5,s1
}
    800055d6:	853e                	mv	a0,a5
    800055d8:	70a2                	ld	ra,40(sp)
    800055da:	7402                	ld	s0,32(sp)
    800055dc:	64e2                	ld	s1,24(sp)
    800055de:	6145                	addi	sp,sp,48
    800055e0:	8082                	ret

00000000800055e2 <sys_read>:
{
    800055e2:	7179                	addi	sp,sp,-48
    800055e4:	f406                	sd	ra,40(sp)
    800055e6:	f022                	sd	s0,32(sp)
    800055e8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055ea:	fe840613          	addi	a2,s0,-24
    800055ee:	4581                	li	a1,0
    800055f0:	4501                	li	a0,0
    800055f2:	00000097          	auipc	ra,0x0
    800055f6:	d92080e7          	jalr	-622(ra) # 80005384 <argfd>
    return -1;
    800055fa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055fc:	04054163          	bltz	a0,8000563e <sys_read+0x5c>
    80005600:	fe440593          	addi	a1,s0,-28
    80005604:	4509                	li	a0,2
    80005606:	ffffd097          	auipc	ra,0xffffd
    8000560a:	7ea080e7          	jalr	2026(ra) # 80002df0 <argint>
    return -1;
    8000560e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005610:	02054763          	bltz	a0,8000563e <sys_read+0x5c>
    80005614:	fd840593          	addi	a1,s0,-40
    80005618:	4505                	li	a0,1
    8000561a:	ffffd097          	auipc	ra,0xffffd
    8000561e:	7f8080e7          	jalr	2040(ra) # 80002e12 <argaddr>
    return -1;
    80005622:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005624:	00054d63          	bltz	a0,8000563e <sys_read+0x5c>
  return fileread(f, p, n);
    80005628:	fe442603          	lw	a2,-28(s0)
    8000562c:	fd843583          	ld	a1,-40(s0)
    80005630:	fe843503          	ld	a0,-24(s0)
    80005634:	fffff097          	auipc	ra,0xfffff
    80005638:	490080e7          	jalr	1168(ra) # 80004ac4 <fileread>
    8000563c:	87aa                	mv	a5,a0
}
    8000563e:	853e                	mv	a0,a5
    80005640:	70a2                	ld	ra,40(sp)
    80005642:	7402                	ld	s0,32(sp)
    80005644:	6145                	addi	sp,sp,48
    80005646:	8082                	ret

0000000080005648 <sys_write>:
{
    80005648:	7179                	addi	sp,sp,-48
    8000564a:	f406                	sd	ra,40(sp)
    8000564c:	f022                	sd	s0,32(sp)
    8000564e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005650:	fe840613          	addi	a2,s0,-24
    80005654:	4581                	li	a1,0
    80005656:	4501                	li	a0,0
    80005658:	00000097          	auipc	ra,0x0
    8000565c:	d2c080e7          	jalr	-724(ra) # 80005384 <argfd>
    return -1;
    80005660:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005662:	04054163          	bltz	a0,800056a4 <sys_write+0x5c>
    80005666:	fe440593          	addi	a1,s0,-28
    8000566a:	4509                	li	a0,2
    8000566c:	ffffd097          	auipc	ra,0xffffd
    80005670:	784080e7          	jalr	1924(ra) # 80002df0 <argint>
    return -1;
    80005674:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005676:	02054763          	bltz	a0,800056a4 <sys_write+0x5c>
    8000567a:	fd840593          	addi	a1,s0,-40
    8000567e:	4505                	li	a0,1
    80005680:	ffffd097          	auipc	ra,0xffffd
    80005684:	792080e7          	jalr	1938(ra) # 80002e12 <argaddr>
    return -1;
    80005688:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000568a:	00054d63          	bltz	a0,800056a4 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000568e:	fe442603          	lw	a2,-28(s0)
    80005692:	fd843583          	ld	a1,-40(s0)
    80005696:	fe843503          	ld	a0,-24(s0)
    8000569a:	fffff097          	auipc	ra,0xfffff
    8000569e:	4ec080e7          	jalr	1260(ra) # 80004b86 <filewrite>
    800056a2:	87aa                	mv	a5,a0
}
    800056a4:	853e                	mv	a0,a5
    800056a6:	70a2                	ld	ra,40(sp)
    800056a8:	7402                	ld	s0,32(sp)
    800056aa:	6145                	addi	sp,sp,48
    800056ac:	8082                	ret

00000000800056ae <sys_close>:
{
    800056ae:	1101                	addi	sp,sp,-32
    800056b0:	ec06                	sd	ra,24(sp)
    800056b2:	e822                	sd	s0,16(sp)
    800056b4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800056b6:	fe040613          	addi	a2,s0,-32
    800056ba:	fec40593          	addi	a1,s0,-20
    800056be:	4501                	li	a0,0
    800056c0:	00000097          	auipc	ra,0x0
    800056c4:	cc4080e7          	jalr	-828(ra) # 80005384 <argfd>
    return -1;
    800056c8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800056ca:	02054463          	bltz	a0,800056f2 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800056ce:	ffffc097          	auipc	ra,0xffffc
    800056d2:	2c8080e7          	jalr	712(ra) # 80001996 <myproc>
    800056d6:	fec42783          	lw	a5,-20(s0)
    800056da:	07f9                	addi	a5,a5,30
    800056dc:	078e                	slli	a5,a5,0x3
    800056de:	97aa                	add	a5,a5,a0
    800056e0:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800056e4:	fe043503          	ld	a0,-32(s0)
    800056e8:	fffff097          	auipc	ra,0xfffff
    800056ec:	2a2080e7          	jalr	674(ra) # 8000498a <fileclose>
  return 0;
    800056f0:	4781                	li	a5,0
}
    800056f2:	853e                	mv	a0,a5
    800056f4:	60e2                	ld	ra,24(sp)
    800056f6:	6442                	ld	s0,16(sp)
    800056f8:	6105                	addi	sp,sp,32
    800056fa:	8082                	ret

00000000800056fc <sys_fstat>:
{
    800056fc:	1101                	addi	sp,sp,-32
    800056fe:	ec06                	sd	ra,24(sp)
    80005700:	e822                	sd	s0,16(sp)
    80005702:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005704:	fe840613          	addi	a2,s0,-24
    80005708:	4581                	li	a1,0
    8000570a:	4501                	li	a0,0
    8000570c:	00000097          	auipc	ra,0x0
    80005710:	c78080e7          	jalr	-904(ra) # 80005384 <argfd>
    return -1;
    80005714:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005716:	02054563          	bltz	a0,80005740 <sys_fstat+0x44>
    8000571a:	fe040593          	addi	a1,s0,-32
    8000571e:	4505                	li	a0,1
    80005720:	ffffd097          	auipc	ra,0xffffd
    80005724:	6f2080e7          	jalr	1778(ra) # 80002e12 <argaddr>
    return -1;
    80005728:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000572a:	00054b63          	bltz	a0,80005740 <sys_fstat+0x44>
  return filestat(f, st);
    8000572e:	fe043583          	ld	a1,-32(s0)
    80005732:	fe843503          	ld	a0,-24(s0)
    80005736:	fffff097          	auipc	ra,0xfffff
    8000573a:	31c080e7          	jalr	796(ra) # 80004a52 <filestat>
    8000573e:	87aa                	mv	a5,a0
}
    80005740:	853e                	mv	a0,a5
    80005742:	60e2                	ld	ra,24(sp)
    80005744:	6442                	ld	s0,16(sp)
    80005746:	6105                	addi	sp,sp,32
    80005748:	8082                	ret

000000008000574a <sys_link>:
{
    8000574a:	7169                	addi	sp,sp,-304
    8000574c:	f606                	sd	ra,296(sp)
    8000574e:	f222                	sd	s0,288(sp)
    80005750:	ee26                	sd	s1,280(sp)
    80005752:	ea4a                	sd	s2,272(sp)
    80005754:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005756:	08000613          	li	a2,128
    8000575a:	ed040593          	addi	a1,s0,-304
    8000575e:	4501                	li	a0,0
    80005760:	ffffd097          	auipc	ra,0xffffd
    80005764:	6d4080e7          	jalr	1748(ra) # 80002e34 <argstr>
    return -1;
    80005768:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000576a:	10054e63          	bltz	a0,80005886 <sys_link+0x13c>
    8000576e:	08000613          	li	a2,128
    80005772:	f5040593          	addi	a1,s0,-176
    80005776:	4505                	li	a0,1
    80005778:	ffffd097          	auipc	ra,0xffffd
    8000577c:	6bc080e7          	jalr	1724(ra) # 80002e34 <argstr>
    return -1;
    80005780:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005782:	10054263          	bltz	a0,80005886 <sys_link+0x13c>
  begin_op();
    80005786:	fffff097          	auipc	ra,0xfffff
    8000578a:	d38080e7          	jalr	-712(ra) # 800044be <begin_op>
  if((ip = namei(old)) == 0){
    8000578e:	ed040513          	addi	a0,s0,-304
    80005792:	fffff097          	auipc	ra,0xfffff
    80005796:	b0c080e7          	jalr	-1268(ra) # 8000429e <namei>
    8000579a:	84aa                	mv	s1,a0
    8000579c:	c551                	beqz	a0,80005828 <sys_link+0xde>
  ilock(ip);
    8000579e:	ffffe097          	auipc	ra,0xffffe
    800057a2:	34a080e7          	jalr	842(ra) # 80003ae8 <ilock>
  if(ip->type == T_DIR){
    800057a6:	04449703          	lh	a4,68(s1)
    800057aa:	4785                	li	a5,1
    800057ac:	08f70463          	beq	a4,a5,80005834 <sys_link+0xea>
  ip->nlink++;
    800057b0:	04a4d783          	lhu	a5,74(s1)
    800057b4:	2785                	addiw	a5,a5,1
    800057b6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057ba:	8526                	mv	a0,s1
    800057bc:	ffffe097          	auipc	ra,0xffffe
    800057c0:	262080e7          	jalr	610(ra) # 80003a1e <iupdate>
  iunlock(ip);
    800057c4:	8526                	mv	a0,s1
    800057c6:	ffffe097          	auipc	ra,0xffffe
    800057ca:	3e4080e7          	jalr	996(ra) # 80003baa <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800057ce:	fd040593          	addi	a1,s0,-48
    800057d2:	f5040513          	addi	a0,s0,-176
    800057d6:	fffff097          	auipc	ra,0xfffff
    800057da:	ae6080e7          	jalr	-1306(ra) # 800042bc <nameiparent>
    800057de:	892a                	mv	s2,a0
    800057e0:	c935                	beqz	a0,80005854 <sys_link+0x10a>
  ilock(dp);
    800057e2:	ffffe097          	auipc	ra,0xffffe
    800057e6:	306080e7          	jalr	774(ra) # 80003ae8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800057ea:	00092703          	lw	a4,0(s2)
    800057ee:	409c                	lw	a5,0(s1)
    800057f0:	04f71d63          	bne	a4,a5,8000584a <sys_link+0x100>
    800057f4:	40d0                	lw	a2,4(s1)
    800057f6:	fd040593          	addi	a1,s0,-48
    800057fa:	854a                	mv	a0,s2
    800057fc:	fffff097          	auipc	ra,0xfffff
    80005800:	9e0080e7          	jalr	-1568(ra) # 800041dc <dirlink>
    80005804:	04054363          	bltz	a0,8000584a <sys_link+0x100>
  iunlockput(dp);
    80005808:	854a                	mv	a0,s2
    8000580a:	ffffe097          	auipc	ra,0xffffe
    8000580e:	540080e7          	jalr	1344(ra) # 80003d4a <iunlockput>
  iput(ip);
    80005812:	8526                	mv	a0,s1
    80005814:	ffffe097          	auipc	ra,0xffffe
    80005818:	48e080e7          	jalr	1166(ra) # 80003ca2 <iput>
  end_op();
    8000581c:	fffff097          	auipc	ra,0xfffff
    80005820:	d22080e7          	jalr	-734(ra) # 8000453e <end_op>
  return 0;
    80005824:	4781                	li	a5,0
    80005826:	a085                	j	80005886 <sys_link+0x13c>
    end_op();
    80005828:	fffff097          	auipc	ra,0xfffff
    8000582c:	d16080e7          	jalr	-746(ra) # 8000453e <end_op>
    return -1;
    80005830:	57fd                	li	a5,-1
    80005832:	a891                	j	80005886 <sys_link+0x13c>
    iunlockput(ip);
    80005834:	8526                	mv	a0,s1
    80005836:	ffffe097          	auipc	ra,0xffffe
    8000583a:	514080e7          	jalr	1300(ra) # 80003d4a <iunlockput>
    end_op();
    8000583e:	fffff097          	auipc	ra,0xfffff
    80005842:	d00080e7          	jalr	-768(ra) # 8000453e <end_op>
    return -1;
    80005846:	57fd                	li	a5,-1
    80005848:	a83d                	j	80005886 <sys_link+0x13c>
    iunlockput(dp);
    8000584a:	854a                	mv	a0,s2
    8000584c:	ffffe097          	auipc	ra,0xffffe
    80005850:	4fe080e7          	jalr	1278(ra) # 80003d4a <iunlockput>
  ilock(ip);
    80005854:	8526                	mv	a0,s1
    80005856:	ffffe097          	auipc	ra,0xffffe
    8000585a:	292080e7          	jalr	658(ra) # 80003ae8 <ilock>
  ip->nlink--;
    8000585e:	04a4d783          	lhu	a5,74(s1)
    80005862:	37fd                	addiw	a5,a5,-1
    80005864:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005868:	8526                	mv	a0,s1
    8000586a:	ffffe097          	auipc	ra,0xffffe
    8000586e:	1b4080e7          	jalr	436(ra) # 80003a1e <iupdate>
  iunlockput(ip);
    80005872:	8526                	mv	a0,s1
    80005874:	ffffe097          	auipc	ra,0xffffe
    80005878:	4d6080e7          	jalr	1238(ra) # 80003d4a <iunlockput>
  end_op();
    8000587c:	fffff097          	auipc	ra,0xfffff
    80005880:	cc2080e7          	jalr	-830(ra) # 8000453e <end_op>
  return -1;
    80005884:	57fd                	li	a5,-1
}
    80005886:	853e                	mv	a0,a5
    80005888:	70b2                	ld	ra,296(sp)
    8000588a:	7412                	ld	s0,288(sp)
    8000588c:	64f2                	ld	s1,280(sp)
    8000588e:	6952                	ld	s2,272(sp)
    80005890:	6155                	addi	sp,sp,304
    80005892:	8082                	ret

0000000080005894 <sys_unlink>:
{
    80005894:	7151                	addi	sp,sp,-240
    80005896:	f586                	sd	ra,232(sp)
    80005898:	f1a2                	sd	s0,224(sp)
    8000589a:	eda6                	sd	s1,216(sp)
    8000589c:	e9ca                	sd	s2,208(sp)
    8000589e:	e5ce                	sd	s3,200(sp)
    800058a0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800058a2:	08000613          	li	a2,128
    800058a6:	f3040593          	addi	a1,s0,-208
    800058aa:	4501                	li	a0,0
    800058ac:	ffffd097          	auipc	ra,0xffffd
    800058b0:	588080e7          	jalr	1416(ra) # 80002e34 <argstr>
    800058b4:	18054163          	bltz	a0,80005a36 <sys_unlink+0x1a2>
  begin_op();
    800058b8:	fffff097          	auipc	ra,0xfffff
    800058bc:	c06080e7          	jalr	-1018(ra) # 800044be <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800058c0:	fb040593          	addi	a1,s0,-80
    800058c4:	f3040513          	addi	a0,s0,-208
    800058c8:	fffff097          	auipc	ra,0xfffff
    800058cc:	9f4080e7          	jalr	-1548(ra) # 800042bc <nameiparent>
    800058d0:	84aa                	mv	s1,a0
    800058d2:	c979                	beqz	a0,800059a8 <sys_unlink+0x114>
  ilock(dp);
    800058d4:	ffffe097          	auipc	ra,0xffffe
    800058d8:	214080e7          	jalr	532(ra) # 80003ae8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800058dc:	00003597          	auipc	a1,0x3
    800058e0:	00c58593          	addi	a1,a1,12 # 800088e8 <syscalls+0x2c0>
    800058e4:	fb040513          	addi	a0,s0,-80
    800058e8:	ffffe097          	auipc	ra,0xffffe
    800058ec:	6ca080e7          	jalr	1738(ra) # 80003fb2 <namecmp>
    800058f0:	14050a63          	beqz	a0,80005a44 <sys_unlink+0x1b0>
    800058f4:	00003597          	auipc	a1,0x3
    800058f8:	ffc58593          	addi	a1,a1,-4 # 800088f0 <syscalls+0x2c8>
    800058fc:	fb040513          	addi	a0,s0,-80
    80005900:	ffffe097          	auipc	ra,0xffffe
    80005904:	6b2080e7          	jalr	1714(ra) # 80003fb2 <namecmp>
    80005908:	12050e63          	beqz	a0,80005a44 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000590c:	f2c40613          	addi	a2,s0,-212
    80005910:	fb040593          	addi	a1,s0,-80
    80005914:	8526                	mv	a0,s1
    80005916:	ffffe097          	auipc	ra,0xffffe
    8000591a:	6b6080e7          	jalr	1718(ra) # 80003fcc <dirlookup>
    8000591e:	892a                	mv	s2,a0
    80005920:	12050263          	beqz	a0,80005a44 <sys_unlink+0x1b0>
  ilock(ip);
    80005924:	ffffe097          	auipc	ra,0xffffe
    80005928:	1c4080e7          	jalr	452(ra) # 80003ae8 <ilock>
  if(ip->nlink < 1)
    8000592c:	04a91783          	lh	a5,74(s2)
    80005930:	08f05263          	blez	a5,800059b4 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005934:	04491703          	lh	a4,68(s2)
    80005938:	4785                	li	a5,1
    8000593a:	08f70563          	beq	a4,a5,800059c4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000593e:	4641                	li	a2,16
    80005940:	4581                	li	a1,0
    80005942:	fc040513          	addi	a0,s0,-64
    80005946:	ffffb097          	auipc	ra,0xffffb
    8000594a:	378080e7          	jalr	888(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000594e:	4741                	li	a4,16
    80005950:	f2c42683          	lw	a3,-212(s0)
    80005954:	fc040613          	addi	a2,s0,-64
    80005958:	4581                	li	a1,0
    8000595a:	8526                	mv	a0,s1
    8000595c:	ffffe097          	auipc	ra,0xffffe
    80005960:	538080e7          	jalr	1336(ra) # 80003e94 <writei>
    80005964:	47c1                	li	a5,16
    80005966:	0af51563          	bne	a0,a5,80005a10 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000596a:	04491703          	lh	a4,68(s2)
    8000596e:	4785                	li	a5,1
    80005970:	0af70863          	beq	a4,a5,80005a20 <sys_unlink+0x18c>
  iunlockput(dp);
    80005974:	8526                	mv	a0,s1
    80005976:	ffffe097          	auipc	ra,0xffffe
    8000597a:	3d4080e7          	jalr	980(ra) # 80003d4a <iunlockput>
  ip->nlink--;
    8000597e:	04a95783          	lhu	a5,74(s2)
    80005982:	37fd                	addiw	a5,a5,-1
    80005984:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005988:	854a                	mv	a0,s2
    8000598a:	ffffe097          	auipc	ra,0xffffe
    8000598e:	094080e7          	jalr	148(ra) # 80003a1e <iupdate>
  iunlockput(ip);
    80005992:	854a                	mv	a0,s2
    80005994:	ffffe097          	auipc	ra,0xffffe
    80005998:	3b6080e7          	jalr	950(ra) # 80003d4a <iunlockput>
  end_op();
    8000599c:	fffff097          	auipc	ra,0xfffff
    800059a0:	ba2080e7          	jalr	-1118(ra) # 8000453e <end_op>
  return 0;
    800059a4:	4501                	li	a0,0
    800059a6:	a84d                	j	80005a58 <sys_unlink+0x1c4>
    end_op();
    800059a8:	fffff097          	auipc	ra,0xfffff
    800059ac:	b96080e7          	jalr	-1130(ra) # 8000453e <end_op>
    return -1;
    800059b0:	557d                	li	a0,-1
    800059b2:	a05d                	j	80005a58 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800059b4:	00003517          	auipc	a0,0x3
    800059b8:	f6450513          	addi	a0,a0,-156 # 80008918 <syscalls+0x2f0>
    800059bc:	ffffb097          	auipc	ra,0xffffb
    800059c0:	b6e080e7          	jalr	-1170(ra) # 8000052a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059c4:	04c92703          	lw	a4,76(s2)
    800059c8:	02000793          	li	a5,32
    800059cc:	f6e7f9e3          	bgeu	a5,a4,8000593e <sys_unlink+0xaa>
    800059d0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059d4:	4741                	li	a4,16
    800059d6:	86ce                	mv	a3,s3
    800059d8:	f1840613          	addi	a2,s0,-232
    800059dc:	4581                	li	a1,0
    800059de:	854a                	mv	a0,s2
    800059e0:	ffffe097          	auipc	ra,0xffffe
    800059e4:	3bc080e7          	jalr	956(ra) # 80003d9c <readi>
    800059e8:	47c1                	li	a5,16
    800059ea:	00f51b63          	bne	a0,a5,80005a00 <sys_unlink+0x16c>
    if(de.inum != 0)
    800059ee:	f1845783          	lhu	a5,-232(s0)
    800059f2:	e7a1                	bnez	a5,80005a3a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059f4:	29c1                	addiw	s3,s3,16
    800059f6:	04c92783          	lw	a5,76(s2)
    800059fa:	fcf9ede3          	bltu	s3,a5,800059d4 <sys_unlink+0x140>
    800059fe:	b781                	j	8000593e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005a00:	00003517          	auipc	a0,0x3
    80005a04:	f3050513          	addi	a0,a0,-208 # 80008930 <syscalls+0x308>
    80005a08:	ffffb097          	auipc	ra,0xffffb
    80005a0c:	b22080e7          	jalr	-1246(ra) # 8000052a <panic>
    panic("unlink: writei");
    80005a10:	00003517          	auipc	a0,0x3
    80005a14:	f3850513          	addi	a0,a0,-200 # 80008948 <syscalls+0x320>
    80005a18:	ffffb097          	auipc	ra,0xffffb
    80005a1c:	b12080e7          	jalr	-1262(ra) # 8000052a <panic>
    dp->nlink--;
    80005a20:	04a4d783          	lhu	a5,74(s1)
    80005a24:	37fd                	addiw	a5,a5,-1
    80005a26:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a2a:	8526                	mv	a0,s1
    80005a2c:	ffffe097          	auipc	ra,0xffffe
    80005a30:	ff2080e7          	jalr	-14(ra) # 80003a1e <iupdate>
    80005a34:	b781                	j	80005974 <sys_unlink+0xe0>
    return -1;
    80005a36:	557d                	li	a0,-1
    80005a38:	a005                	j	80005a58 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005a3a:	854a                	mv	a0,s2
    80005a3c:	ffffe097          	auipc	ra,0xffffe
    80005a40:	30e080e7          	jalr	782(ra) # 80003d4a <iunlockput>
  iunlockput(dp);
    80005a44:	8526                	mv	a0,s1
    80005a46:	ffffe097          	auipc	ra,0xffffe
    80005a4a:	304080e7          	jalr	772(ra) # 80003d4a <iunlockput>
  end_op();
    80005a4e:	fffff097          	auipc	ra,0xfffff
    80005a52:	af0080e7          	jalr	-1296(ra) # 8000453e <end_op>
  return -1;
    80005a56:	557d                	li	a0,-1
}
    80005a58:	70ae                	ld	ra,232(sp)
    80005a5a:	740e                	ld	s0,224(sp)
    80005a5c:	64ee                	ld	s1,216(sp)
    80005a5e:	694e                	ld	s2,208(sp)
    80005a60:	69ae                	ld	s3,200(sp)
    80005a62:	616d                	addi	sp,sp,240
    80005a64:	8082                	ret

0000000080005a66 <sys_open>:

uint64
sys_open(void)
{
    80005a66:	7131                	addi	sp,sp,-192
    80005a68:	fd06                	sd	ra,184(sp)
    80005a6a:	f922                	sd	s0,176(sp)
    80005a6c:	f526                	sd	s1,168(sp)
    80005a6e:	f14a                	sd	s2,160(sp)
    80005a70:	ed4e                	sd	s3,152(sp)
    80005a72:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a74:	08000613          	li	a2,128
    80005a78:	f5040593          	addi	a1,s0,-176
    80005a7c:	4501                	li	a0,0
    80005a7e:	ffffd097          	auipc	ra,0xffffd
    80005a82:	3b6080e7          	jalr	950(ra) # 80002e34 <argstr>
    return -1;
    80005a86:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a88:	0c054163          	bltz	a0,80005b4a <sys_open+0xe4>
    80005a8c:	f4c40593          	addi	a1,s0,-180
    80005a90:	4505                	li	a0,1
    80005a92:	ffffd097          	auipc	ra,0xffffd
    80005a96:	35e080e7          	jalr	862(ra) # 80002df0 <argint>
    80005a9a:	0a054863          	bltz	a0,80005b4a <sys_open+0xe4>

  begin_op();
    80005a9e:	fffff097          	auipc	ra,0xfffff
    80005aa2:	a20080e7          	jalr	-1504(ra) # 800044be <begin_op>

  if(omode & O_CREATE){
    80005aa6:	f4c42783          	lw	a5,-180(s0)
    80005aaa:	2007f793          	andi	a5,a5,512
    80005aae:	cbdd                	beqz	a5,80005b64 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005ab0:	4681                	li	a3,0
    80005ab2:	4601                	li	a2,0
    80005ab4:	4589                	li	a1,2
    80005ab6:	f5040513          	addi	a0,s0,-176
    80005aba:	00000097          	auipc	ra,0x0
    80005abe:	974080e7          	jalr	-1676(ra) # 8000542e <create>
    80005ac2:	892a                	mv	s2,a0
    if(ip == 0){
    80005ac4:	c959                	beqz	a0,80005b5a <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005ac6:	04491703          	lh	a4,68(s2)
    80005aca:	478d                	li	a5,3
    80005acc:	00f71763          	bne	a4,a5,80005ada <sys_open+0x74>
    80005ad0:	04695703          	lhu	a4,70(s2)
    80005ad4:	47a5                	li	a5,9
    80005ad6:	0ce7ec63          	bltu	a5,a4,80005bae <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ada:	fffff097          	auipc	ra,0xfffff
    80005ade:	df4080e7          	jalr	-524(ra) # 800048ce <filealloc>
    80005ae2:	89aa                	mv	s3,a0
    80005ae4:	10050263          	beqz	a0,80005be8 <sys_open+0x182>
    80005ae8:	00000097          	auipc	ra,0x0
    80005aec:	904080e7          	jalr	-1788(ra) # 800053ec <fdalloc>
    80005af0:	84aa                	mv	s1,a0
    80005af2:	0e054663          	bltz	a0,80005bde <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005af6:	04491703          	lh	a4,68(s2)
    80005afa:	478d                	li	a5,3
    80005afc:	0cf70463          	beq	a4,a5,80005bc4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005b00:	4789                	li	a5,2
    80005b02:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005b06:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005b0a:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005b0e:	f4c42783          	lw	a5,-180(s0)
    80005b12:	0017c713          	xori	a4,a5,1
    80005b16:	8b05                	andi	a4,a4,1
    80005b18:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b1c:	0037f713          	andi	a4,a5,3
    80005b20:	00e03733          	snez	a4,a4
    80005b24:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005b28:	4007f793          	andi	a5,a5,1024
    80005b2c:	c791                	beqz	a5,80005b38 <sys_open+0xd2>
    80005b2e:	04491703          	lh	a4,68(s2)
    80005b32:	4789                	li	a5,2
    80005b34:	08f70f63          	beq	a4,a5,80005bd2 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005b38:	854a                	mv	a0,s2
    80005b3a:	ffffe097          	auipc	ra,0xffffe
    80005b3e:	070080e7          	jalr	112(ra) # 80003baa <iunlock>
  end_op();
    80005b42:	fffff097          	auipc	ra,0xfffff
    80005b46:	9fc080e7          	jalr	-1540(ra) # 8000453e <end_op>

  return fd;
}
    80005b4a:	8526                	mv	a0,s1
    80005b4c:	70ea                	ld	ra,184(sp)
    80005b4e:	744a                	ld	s0,176(sp)
    80005b50:	74aa                	ld	s1,168(sp)
    80005b52:	790a                	ld	s2,160(sp)
    80005b54:	69ea                	ld	s3,152(sp)
    80005b56:	6129                	addi	sp,sp,192
    80005b58:	8082                	ret
      end_op();
    80005b5a:	fffff097          	auipc	ra,0xfffff
    80005b5e:	9e4080e7          	jalr	-1564(ra) # 8000453e <end_op>
      return -1;
    80005b62:	b7e5                	j	80005b4a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005b64:	f5040513          	addi	a0,s0,-176
    80005b68:	ffffe097          	auipc	ra,0xffffe
    80005b6c:	736080e7          	jalr	1846(ra) # 8000429e <namei>
    80005b70:	892a                	mv	s2,a0
    80005b72:	c905                	beqz	a0,80005ba2 <sys_open+0x13c>
    ilock(ip);
    80005b74:	ffffe097          	auipc	ra,0xffffe
    80005b78:	f74080e7          	jalr	-140(ra) # 80003ae8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b7c:	04491703          	lh	a4,68(s2)
    80005b80:	4785                	li	a5,1
    80005b82:	f4f712e3          	bne	a4,a5,80005ac6 <sys_open+0x60>
    80005b86:	f4c42783          	lw	a5,-180(s0)
    80005b8a:	dba1                	beqz	a5,80005ada <sys_open+0x74>
      iunlockput(ip);
    80005b8c:	854a                	mv	a0,s2
    80005b8e:	ffffe097          	auipc	ra,0xffffe
    80005b92:	1bc080e7          	jalr	444(ra) # 80003d4a <iunlockput>
      end_op();
    80005b96:	fffff097          	auipc	ra,0xfffff
    80005b9a:	9a8080e7          	jalr	-1624(ra) # 8000453e <end_op>
      return -1;
    80005b9e:	54fd                	li	s1,-1
    80005ba0:	b76d                	j	80005b4a <sys_open+0xe4>
      end_op();
    80005ba2:	fffff097          	auipc	ra,0xfffff
    80005ba6:	99c080e7          	jalr	-1636(ra) # 8000453e <end_op>
      return -1;
    80005baa:	54fd                	li	s1,-1
    80005bac:	bf79                	j	80005b4a <sys_open+0xe4>
    iunlockput(ip);
    80005bae:	854a                	mv	a0,s2
    80005bb0:	ffffe097          	auipc	ra,0xffffe
    80005bb4:	19a080e7          	jalr	410(ra) # 80003d4a <iunlockput>
    end_op();
    80005bb8:	fffff097          	auipc	ra,0xfffff
    80005bbc:	986080e7          	jalr	-1658(ra) # 8000453e <end_op>
    return -1;
    80005bc0:	54fd                	li	s1,-1
    80005bc2:	b761                	j	80005b4a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005bc4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005bc8:	04691783          	lh	a5,70(s2)
    80005bcc:	02f99223          	sh	a5,36(s3)
    80005bd0:	bf2d                	j	80005b0a <sys_open+0xa4>
    itrunc(ip);
    80005bd2:	854a                	mv	a0,s2
    80005bd4:	ffffe097          	auipc	ra,0xffffe
    80005bd8:	022080e7          	jalr	34(ra) # 80003bf6 <itrunc>
    80005bdc:	bfb1                	j	80005b38 <sys_open+0xd2>
      fileclose(f);
    80005bde:	854e                	mv	a0,s3
    80005be0:	fffff097          	auipc	ra,0xfffff
    80005be4:	daa080e7          	jalr	-598(ra) # 8000498a <fileclose>
    iunlockput(ip);
    80005be8:	854a                	mv	a0,s2
    80005bea:	ffffe097          	auipc	ra,0xffffe
    80005bee:	160080e7          	jalr	352(ra) # 80003d4a <iunlockput>
    end_op();
    80005bf2:	fffff097          	auipc	ra,0xfffff
    80005bf6:	94c080e7          	jalr	-1716(ra) # 8000453e <end_op>
    return -1;
    80005bfa:	54fd                	li	s1,-1
    80005bfc:	b7b9                	j	80005b4a <sys_open+0xe4>

0000000080005bfe <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005bfe:	7175                	addi	sp,sp,-144
    80005c00:	e506                	sd	ra,136(sp)
    80005c02:	e122                	sd	s0,128(sp)
    80005c04:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005c06:	fffff097          	auipc	ra,0xfffff
    80005c0a:	8b8080e7          	jalr	-1864(ra) # 800044be <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005c0e:	08000613          	li	a2,128
    80005c12:	f7040593          	addi	a1,s0,-144
    80005c16:	4501                	li	a0,0
    80005c18:	ffffd097          	auipc	ra,0xffffd
    80005c1c:	21c080e7          	jalr	540(ra) # 80002e34 <argstr>
    80005c20:	02054963          	bltz	a0,80005c52 <sys_mkdir+0x54>
    80005c24:	4681                	li	a3,0
    80005c26:	4601                	li	a2,0
    80005c28:	4585                	li	a1,1
    80005c2a:	f7040513          	addi	a0,s0,-144
    80005c2e:	00000097          	auipc	ra,0x0
    80005c32:	800080e7          	jalr	-2048(ra) # 8000542e <create>
    80005c36:	cd11                	beqz	a0,80005c52 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c38:	ffffe097          	auipc	ra,0xffffe
    80005c3c:	112080e7          	jalr	274(ra) # 80003d4a <iunlockput>
  end_op();
    80005c40:	fffff097          	auipc	ra,0xfffff
    80005c44:	8fe080e7          	jalr	-1794(ra) # 8000453e <end_op>
  return 0;
    80005c48:	4501                	li	a0,0
}
    80005c4a:	60aa                	ld	ra,136(sp)
    80005c4c:	640a                	ld	s0,128(sp)
    80005c4e:	6149                	addi	sp,sp,144
    80005c50:	8082                	ret
    end_op();
    80005c52:	fffff097          	auipc	ra,0xfffff
    80005c56:	8ec080e7          	jalr	-1812(ra) # 8000453e <end_op>
    return -1;
    80005c5a:	557d                	li	a0,-1
    80005c5c:	b7fd                	j	80005c4a <sys_mkdir+0x4c>

0000000080005c5e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c5e:	7135                	addi	sp,sp,-160
    80005c60:	ed06                	sd	ra,152(sp)
    80005c62:	e922                	sd	s0,144(sp)
    80005c64:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c66:	fffff097          	auipc	ra,0xfffff
    80005c6a:	858080e7          	jalr	-1960(ra) # 800044be <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c6e:	08000613          	li	a2,128
    80005c72:	f7040593          	addi	a1,s0,-144
    80005c76:	4501                	li	a0,0
    80005c78:	ffffd097          	auipc	ra,0xffffd
    80005c7c:	1bc080e7          	jalr	444(ra) # 80002e34 <argstr>
    80005c80:	04054a63          	bltz	a0,80005cd4 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005c84:	f6c40593          	addi	a1,s0,-148
    80005c88:	4505                	li	a0,1
    80005c8a:	ffffd097          	auipc	ra,0xffffd
    80005c8e:	166080e7          	jalr	358(ra) # 80002df0 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c92:	04054163          	bltz	a0,80005cd4 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005c96:	f6840593          	addi	a1,s0,-152
    80005c9a:	4509                	li	a0,2
    80005c9c:	ffffd097          	auipc	ra,0xffffd
    80005ca0:	154080e7          	jalr	340(ra) # 80002df0 <argint>
     argint(1, &major) < 0 ||
    80005ca4:	02054863          	bltz	a0,80005cd4 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ca8:	f6841683          	lh	a3,-152(s0)
    80005cac:	f6c41603          	lh	a2,-148(s0)
    80005cb0:	458d                	li	a1,3
    80005cb2:	f7040513          	addi	a0,s0,-144
    80005cb6:	fffff097          	auipc	ra,0xfffff
    80005cba:	778080e7          	jalr	1912(ra) # 8000542e <create>
     argint(2, &minor) < 0 ||
    80005cbe:	c919                	beqz	a0,80005cd4 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005cc0:	ffffe097          	auipc	ra,0xffffe
    80005cc4:	08a080e7          	jalr	138(ra) # 80003d4a <iunlockput>
  end_op();
    80005cc8:	fffff097          	auipc	ra,0xfffff
    80005ccc:	876080e7          	jalr	-1930(ra) # 8000453e <end_op>
  return 0;
    80005cd0:	4501                	li	a0,0
    80005cd2:	a031                	j	80005cde <sys_mknod+0x80>
    end_op();
    80005cd4:	fffff097          	auipc	ra,0xfffff
    80005cd8:	86a080e7          	jalr	-1942(ra) # 8000453e <end_op>
    return -1;
    80005cdc:	557d                	li	a0,-1
}
    80005cde:	60ea                	ld	ra,152(sp)
    80005ce0:	644a                	ld	s0,144(sp)
    80005ce2:	610d                	addi	sp,sp,160
    80005ce4:	8082                	ret

0000000080005ce6 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005ce6:	7135                	addi	sp,sp,-160
    80005ce8:	ed06                	sd	ra,152(sp)
    80005cea:	e922                	sd	s0,144(sp)
    80005cec:	e526                	sd	s1,136(sp)
    80005cee:	e14a                	sd	s2,128(sp)
    80005cf0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005cf2:	ffffc097          	auipc	ra,0xffffc
    80005cf6:	ca4080e7          	jalr	-860(ra) # 80001996 <myproc>
    80005cfa:	892a                	mv	s2,a0
  
  begin_op();
    80005cfc:	ffffe097          	auipc	ra,0xffffe
    80005d00:	7c2080e7          	jalr	1986(ra) # 800044be <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005d04:	08000613          	li	a2,128
    80005d08:	f6040593          	addi	a1,s0,-160
    80005d0c:	4501                	li	a0,0
    80005d0e:	ffffd097          	auipc	ra,0xffffd
    80005d12:	126080e7          	jalr	294(ra) # 80002e34 <argstr>
    80005d16:	04054b63          	bltz	a0,80005d6c <sys_chdir+0x86>
    80005d1a:	f6040513          	addi	a0,s0,-160
    80005d1e:	ffffe097          	auipc	ra,0xffffe
    80005d22:	580080e7          	jalr	1408(ra) # 8000429e <namei>
    80005d26:	84aa                	mv	s1,a0
    80005d28:	c131                	beqz	a0,80005d6c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005d2a:	ffffe097          	auipc	ra,0xffffe
    80005d2e:	dbe080e7          	jalr	-578(ra) # 80003ae8 <ilock>
  if(ip->type != T_DIR){
    80005d32:	04449703          	lh	a4,68(s1)
    80005d36:	4785                	li	a5,1
    80005d38:	04f71063          	bne	a4,a5,80005d78 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d3c:	8526                	mv	a0,s1
    80005d3e:	ffffe097          	auipc	ra,0xffffe
    80005d42:	e6c080e7          	jalr	-404(ra) # 80003baa <iunlock>
  iput(p->cwd);
    80005d46:	17093503          	ld	a0,368(s2)
    80005d4a:	ffffe097          	auipc	ra,0xffffe
    80005d4e:	f58080e7          	jalr	-168(ra) # 80003ca2 <iput>
  end_op();
    80005d52:	ffffe097          	auipc	ra,0xffffe
    80005d56:	7ec080e7          	jalr	2028(ra) # 8000453e <end_op>
  p->cwd = ip;
    80005d5a:	16993823          	sd	s1,368(s2)
  return 0;
    80005d5e:	4501                	li	a0,0
}
    80005d60:	60ea                	ld	ra,152(sp)
    80005d62:	644a                	ld	s0,144(sp)
    80005d64:	64aa                	ld	s1,136(sp)
    80005d66:	690a                	ld	s2,128(sp)
    80005d68:	610d                	addi	sp,sp,160
    80005d6a:	8082                	ret
    end_op();
    80005d6c:	ffffe097          	auipc	ra,0xffffe
    80005d70:	7d2080e7          	jalr	2002(ra) # 8000453e <end_op>
    return -1;
    80005d74:	557d                	li	a0,-1
    80005d76:	b7ed                	j	80005d60 <sys_chdir+0x7a>
    iunlockput(ip);
    80005d78:	8526                	mv	a0,s1
    80005d7a:	ffffe097          	auipc	ra,0xffffe
    80005d7e:	fd0080e7          	jalr	-48(ra) # 80003d4a <iunlockput>
    end_op();
    80005d82:	ffffe097          	auipc	ra,0xffffe
    80005d86:	7bc080e7          	jalr	1980(ra) # 8000453e <end_op>
    return -1;
    80005d8a:	557d                	li	a0,-1
    80005d8c:	bfd1                	j	80005d60 <sys_chdir+0x7a>

0000000080005d8e <sys_exec>:

uint64
sys_exec(void)
{
    80005d8e:	7145                	addi	sp,sp,-464
    80005d90:	e786                	sd	ra,456(sp)
    80005d92:	e3a2                	sd	s0,448(sp)
    80005d94:	ff26                	sd	s1,440(sp)
    80005d96:	fb4a                	sd	s2,432(sp)
    80005d98:	f74e                	sd	s3,424(sp)
    80005d9a:	f352                	sd	s4,416(sp)
    80005d9c:	ef56                	sd	s5,408(sp)
    80005d9e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005da0:	08000613          	li	a2,128
    80005da4:	f4040593          	addi	a1,s0,-192
    80005da8:	4501                	li	a0,0
    80005daa:	ffffd097          	auipc	ra,0xffffd
    80005dae:	08a080e7          	jalr	138(ra) # 80002e34 <argstr>
    return -1;
    80005db2:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005db4:	0c054a63          	bltz	a0,80005e88 <sys_exec+0xfa>
    80005db8:	e3840593          	addi	a1,s0,-456
    80005dbc:	4505                	li	a0,1
    80005dbe:	ffffd097          	auipc	ra,0xffffd
    80005dc2:	054080e7          	jalr	84(ra) # 80002e12 <argaddr>
    80005dc6:	0c054163          	bltz	a0,80005e88 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005dca:	10000613          	li	a2,256
    80005dce:	4581                	li	a1,0
    80005dd0:	e4040513          	addi	a0,s0,-448
    80005dd4:	ffffb097          	auipc	ra,0xffffb
    80005dd8:	eea080e7          	jalr	-278(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ddc:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005de0:	89a6                	mv	s3,s1
    80005de2:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005de4:	02000a13          	li	s4,32
    80005de8:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005dec:	00391793          	slli	a5,s2,0x3
    80005df0:	e3040593          	addi	a1,s0,-464
    80005df4:	e3843503          	ld	a0,-456(s0)
    80005df8:	953e                	add	a0,a0,a5
    80005dfa:	ffffd097          	auipc	ra,0xffffd
    80005dfe:	f5c080e7          	jalr	-164(ra) # 80002d56 <fetchaddr>
    80005e02:	02054a63          	bltz	a0,80005e36 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005e06:	e3043783          	ld	a5,-464(s0)
    80005e0a:	c3b9                	beqz	a5,80005e50 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e0c:	ffffb097          	auipc	ra,0xffffb
    80005e10:	cc6080e7          	jalr	-826(ra) # 80000ad2 <kalloc>
    80005e14:	85aa                	mv	a1,a0
    80005e16:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e1a:	cd11                	beqz	a0,80005e36 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005e1c:	6605                	lui	a2,0x1
    80005e1e:	e3043503          	ld	a0,-464(s0)
    80005e22:	ffffd097          	auipc	ra,0xffffd
    80005e26:	f86080e7          	jalr	-122(ra) # 80002da8 <fetchstr>
    80005e2a:	00054663          	bltz	a0,80005e36 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005e2e:	0905                	addi	s2,s2,1
    80005e30:	09a1                	addi	s3,s3,8
    80005e32:	fb491be3          	bne	s2,s4,80005de8 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e36:	10048913          	addi	s2,s1,256
    80005e3a:	6088                	ld	a0,0(s1)
    80005e3c:	c529                	beqz	a0,80005e86 <sys_exec+0xf8>
    kfree(argv[i]);
    80005e3e:	ffffb097          	auipc	ra,0xffffb
    80005e42:	b98080e7          	jalr	-1128(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e46:	04a1                	addi	s1,s1,8
    80005e48:	ff2499e3          	bne	s1,s2,80005e3a <sys_exec+0xac>
  return -1;
    80005e4c:	597d                	li	s2,-1
    80005e4e:	a82d                	j	80005e88 <sys_exec+0xfa>
      argv[i] = 0;
    80005e50:	0a8e                	slli	s5,s5,0x3
    80005e52:	fc040793          	addi	a5,s0,-64
    80005e56:	9abe                	add	s5,s5,a5
    80005e58:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd8e80>
  int ret = exec(path, argv);
    80005e5c:	e4040593          	addi	a1,s0,-448
    80005e60:	f4040513          	addi	a0,s0,-192
    80005e64:	fffff097          	auipc	ra,0xfffff
    80005e68:	178080e7          	jalr	376(ra) # 80004fdc <exec>
    80005e6c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e6e:	10048993          	addi	s3,s1,256
    80005e72:	6088                	ld	a0,0(s1)
    80005e74:	c911                	beqz	a0,80005e88 <sys_exec+0xfa>
    kfree(argv[i]);
    80005e76:	ffffb097          	auipc	ra,0xffffb
    80005e7a:	b60080e7          	jalr	-1184(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e7e:	04a1                	addi	s1,s1,8
    80005e80:	ff3499e3          	bne	s1,s3,80005e72 <sys_exec+0xe4>
    80005e84:	a011                	j	80005e88 <sys_exec+0xfa>
  return -1;
    80005e86:	597d                	li	s2,-1
}
    80005e88:	854a                	mv	a0,s2
    80005e8a:	60be                	ld	ra,456(sp)
    80005e8c:	641e                	ld	s0,448(sp)
    80005e8e:	74fa                	ld	s1,440(sp)
    80005e90:	795a                	ld	s2,432(sp)
    80005e92:	79ba                	ld	s3,424(sp)
    80005e94:	7a1a                	ld	s4,416(sp)
    80005e96:	6afa                	ld	s5,408(sp)
    80005e98:	6179                	addi	sp,sp,464
    80005e9a:	8082                	ret

0000000080005e9c <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e9c:	7139                	addi	sp,sp,-64
    80005e9e:	fc06                	sd	ra,56(sp)
    80005ea0:	f822                	sd	s0,48(sp)
    80005ea2:	f426                	sd	s1,40(sp)
    80005ea4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ea6:	ffffc097          	auipc	ra,0xffffc
    80005eaa:	af0080e7          	jalr	-1296(ra) # 80001996 <myproc>
    80005eae:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005eb0:	fd840593          	addi	a1,s0,-40
    80005eb4:	4501                	li	a0,0
    80005eb6:	ffffd097          	auipc	ra,0xffffd
    80005eba:	f5c080e7          	jalr	-164(ra) # 80002e12 <argaddr>
    return -1;
    80005ebe:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005ec0:	0e054063          	bltz	a0,80005fa0 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005ec4:	fc840593          	addi	a1,s0,-56
    80005ec8:	fd040513          	addi	a0,s0,-48
    80005ecc:	fffff097          	auipc	ra,0xfffff
    80005ed0:	dee080e7          	jalr	-530(ra) # 80004cba <pipealloc>
    return -1;
    80005ed4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ed6:	0c054563          	bltz	a0,80005fa0 <sys_pipe+0x104>
  fd0 = -1;
    80005eda:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005ede:	fd043503          	ld	a0,-48(s0)
    80005ee2:	fffff097          	auipc	ra,0xfffff
    80005ee6:	50a080e7          	jalr	1290(ra) # 800053ec <fdalloc>
    80005eea:	fca42223          	sw	a0,-60(s0)
    80005eee:	08054c63          	bltz	a0,80005f86 <sys_pipe+0xea>
    80005ef2:	fc843503          	ld	a0,-56(s0)
    80005ef6:	fffff097          	auipc	ra,0xfffff
    80005efa:	4f6080e7          	jalr	1270(ra) # 800053ec <fdalloc>
    80005efe:	fca42023          	sw	a0,-64(s0)
    80005f02:	06054863          	bltz	a0,80005f72 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f06:	4691                	li	a3,4
    80005f08:	fc440613          	addi	a2,s0,-60
    80005f0c:	fd843583          	ld	a1,-40(s0)
    80005f10:	78a8                	ld	a0,112(s1)
    80005f12:	ffffb097          	auipc	ra,0xffffb
    80005f16:	72c080e7          	jalr	1836(ra) # 8000163e <copyout>
    80005f1a:	02054063          	bltz	a0,80005f3a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f1e:	4691                	li	a3,4
    80005f20:	fc040613          	addi	a2,s0,-64
    80005f24:	fd843583          	ld	a1,-40(s0)
    80005f28:	0591                	addi	a1,a1,4
    80005f2a:	78a8                	ld	a0,112(s1)
    80005f2c:	ffffb097          	auipc	ra,0xffffb
    80005f30:	712080e7          	jalr	1810(ra) # 8000163e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f34:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f36:	06055563          	bgez	a0,80005fa0 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005f3a:	fc442783          	lw	a5,-60(s0)
    80005f3e:	07f9                	addi	a5,a5,30
    80005f40:	078e                	slli	a5,a5,0x3
    80005f42:	97a6                	add	a5,a5,s1
    80005f44:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f48:	fc042503          	lw	a0,-64(s0)
    80005f4c:	0579                	addi	a0,a0,30
    80005f4e:	050e                	slli	a0,a0,0x3
    80005f50:	9526                	add	a0,a0,s1
    80005f52:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005f56:	fd043503          	ld	a0,-48(s0)
    80005f5a:	fffff097          	auipc	ra,0xfffff
    80005f5e:	a30080e7          	jalr	-1488(ra) # 8000498a <fileclose>
    fileclose(wf);
    80005f62:	fc843503          	ld	a0,-56(s0)
    80005f66:	fffff097          	auipc	ra,0xfffff
    80005f6a:	a24080e7          	jalr	-1500(ra) # 8000498a <fileclose>
    return -1;
    80005f6e:	57fd                	li	a5,-1
    80005f70:	a805                	j	80005fa0 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005f72:	fc442783          	lw	a5,-60(s0)
    80005f76:	0007c863          	bltz	a5,80005f86 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005f7a:	01e78513          	addi	a0,a5,30
    80005f7e:	050e                	slli	a0,a0,0x3
    80005f80:	9526                	add	a0,a0,s1
    80005f82:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005f86:	fd043503          	ld	a0,-48(s0)
    80005f8a:	fffff097          	auipc	ra,0xfffff
    80005f8e:	a00080e7          	jalr	-1536(ra) # 8000498a <fileclose>
    fileclose(wf);
    80005f92:	fc843503          	ld	a0,-56(s0)
    80005f96:	fffff097          	auipc	ra,0xfffff
    80005f9a:	9f4080e7          	jalr	-1548(ra) # 8000498a <fileclose>
    return -1;
    80005f9e:	57fd                	li	a5,-1
}
    80005fa0:	853e                	mv	a0,a5
    80005fa2:	70e2                	ld	ra,56(sp)
    80005fa4:	7442                	ld	s0,48(sp)
    80005fa6:	74a2                	ld	s1,40(sp)
    80005fa8:	6121                	addi	sp,sp,64
    80005faa:	8082                	ret
    80005fac:	0000                	unimp
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
    80005ff0:	c27fc0ef          	jal	ra,80002c16 <kerneltrap>
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
    8000608c:	8e2080e7          	jalr	-1822(ra) # 8000196a <cpuid>
  
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
    800060c4:	8aa080e7          	jalr	-1878(ra) # 8000196a <cpuid>
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
    800060ec:	882080e7          	jalr	-1918(ra) # 8000196a <cpuid>
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
    80006114:	0001d797          	auipc	a5,0x1d
    80006118:	eec78793          	addi	a5,a5,-276 # 80023000 <disk>
    8000611c:	00a78733          	add	a4,a5,a0
    80006120:	6789                	lui	a5,0x2
    80006122:	97ba                	add	a5,a5,a4
    80006124:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006128:	e7ad                	bnez	a5,80006192 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000612a:	00451793          	slli	a5,a0,0x4
    8000612e:	0001f717          	auipc	a4,0x1f
    80006132:	ed270713          	addi	a4,a4,-302 # 80025000 <disk+0x2000>
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
    80006156:	0001d797          	auipc	a5,0x1d
    8000615a:	eaa78793          	addi	a5,a5,-342 # 80023000 <disk>
    8000615e:	97aa                	add	a5,a5,a0
    80006160:	6509                	lui	a0,0x2
    80006162:	953e                	add	a0,a0,a5
    80006164:	4785                	li	a5,1
    80006166:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000616a:	0001f517          	auipc	a0,0x1f
    8000616e:	eae50513          	addi	a0,a0,-338 # 80025018 <disk+0x2018>
    80006172:	ffffc097          	auipc	ra,0xffffc
    80006176:	114080e7          	jalr	276(ra) # 80002286 <wakeup>
}
    8000617a:	60a2                	ld	ra,8(sp)
    8000617c:	6402                	ld	s0,0(sp)
    8000617e:	0141                	addi	sp,sp,16
    80006180:	8082                	ret
    panic("free_desc 1");
    80006182:	00002517          	auipc	a0,0x2
    80006186:	7d650513          	addi	a0,a0,2006 # 80008958 <syscalls+0x330>
    8000618a:	ffffa097          	auipc	ra,0xffffa
    8000618e:	3a0080e7          	jalr	928(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006192:	00002517          	auipc	a0,0x2
    80006196:	7d650513          	addi	a0,a0,2006 # 80008968 <syscalls+0x340>
    8000619a:	ffffa097          	auipc	ra,0xffffa
    8000619e:	390080e7          	jalr	912(ra) # 8000052a <panic>

00000000800061a2 <virtio_disk_init>:
{
    800061a2:	1101                	addi	sp,sp,-32
    800061a4:	ec06                	sd	ra,24(sp)
    800061a6:	e822                	sd	s0,16(sp)
    800061a8:	e426                	sd	s1,8(sp)
    800061aa:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800061ac:	00002597          	auipc	a1,0x2
    800061b0:	7cc58593          	addi	a1,a1,1996 # 80008978 <syscalls+0x350>
    800061b4:	0001f517          	auipc	a0,0x1f
    800061b8:	f7450513          	addi	a0,a0,-140 # 80025128 <disk+0x2128>
    800061bc:	ffffb097          	auipc	ra,0xffffb
    800061c0:	976080e7          	jalr	-1674(ra) # 80000b32 <initlock>
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
    8000621a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
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
    8000624c:	0001d517          	auipc	a0,0x1d
    80006250:	db450513          	addi	a0,a0,-588 # 80023000 <disk>
    80006254:	ffffb097          	auipc	ra,0xffffb
    80006258:	a6a080e7          	jalr	-1430(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000625c:	0001d717          	auipc	a4,0x1d
    80006260:	da470713          	addi	a4,a4,-604 # 80023000 <disk>
    80006264:	00c75793          	srli	a5,a4,0xc
    80006268:	2781                	sext.w	a5,a5
    8000626a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000626c:	0001f797          	auipc	a5,0x1f
    80006270:	d9478793          	addi	a5,a5,-620 # 80025000 <disk+0x2000>
    80006274:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006276:	0001d717          	auipc	a4,0x1d
    8000627a:	e0a70713          	addi	a4,a4,-502 # 80023080 <disk+0x80>
    8000627e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006280:	0001e717          	auipc	a4,0x1e
    80006284:	d8070713          	addi	a4,a4,-640 # 80024000 <disk+0x1000>
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
    800062ba:	6d250513          	addi	a0,a0,1746 # 80008988 <syscalls+0x360>
    800062be:	ffffa097          	auipc	ra,0xffffa
    800062c2:	26c080e7          	jalr	620(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    800062c6:	00002517          	auipc	a0,0x2
    800062ca:	6e250513          	addi	a0,a0,1762 # 800089a8 <syscalls+0x380>
    800062ce:	ffffa097          	auipc	ra,0xffffa
    800062d2:	25c080e7          	jalr	604(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    800062d6:	00002517          	auipc	a0,0x2
    800062da:	6f250513          	addi	a0,a0,1778 # 800089c8 <syscalls+0x3a0>
    800062de:	ffffa097          	auipc	ra,0xffffa
    800062e2:	24c080e7          	jalr	588(ra) # 8000052a <panic>

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
    80006316:	0001f517          	auipc	a0,0x1f
    8000631a:	e1250513          	addi	a0,a0,-494 # 80025128 <disk+0x2128>
    8000631e:	ffffb097          	auipc	ra,0xffffb
    80006322:	8a4080e7          	jalr	-1884(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006326:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006328:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000632a:	0001dc17          	auipc	s8,0x1d
    8000632e:	cd6c0c13          	addi	s8,s8,-810 # 80023000 <disk>
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
    80006352:	0001f717          	auipc	a4,0x1f
    80006356:	cc670713          	addi	a4,a4,-826 # 80025018 <disk+0x2018>
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
    80006388:	0001f597          	auipc	a1,0x1f
    8000638c:	da058593          	addi	a1,a1,-608 # 80025128 <disk+0x2128>
    80006390:	0001f517          	auipc	a0,0x1f
    80006394:	c8850513          	addi	a0,a0,-888 # 80025018 <disk+0x2018>
    80006398:	ffffc097          	auipc	ra,0xffffc
    8000639c:	d62080e7          	jalr	-670(ra) # 800020fa <sleep>
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
    800063aa:	0001f697          	auipc	a3,0x1f
    800063ae:	c566b683          	ld	a3,-938(a3) # 80025000 <disk+0x2000>
    800063b2:	96ba                	add	a3,a3,a4
    800063b4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800063b8:	0001d817          	auipc	a6,0x1d
    800063bc:	c4880813          	addi	a6,a6,-952 # 80023000 <disk>
    800063c0:	0001f697          	auipc	a3,0x1f
    800063c4:	c4068693          	addi	a3,a3,-960 # 80025000 <disk+0x2000>
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
    80006458:	0001f917          	auipc	s2,0x1f
    8000645c:	cd090913          	addi	s2,s2,-816 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80006460:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006462:	85ca                	mv	a1,s2
    80006464:	8556                	mv	a0,s5
    80006466:	ffffc097          	auipc	ra,0xffffc
    8000646a:	c94080e7          	jalr	-876(ra) # 800020fa <sleep>
  while(b->disk == 1) {
    8000646e:	004aa783          	lw	a5,4(s5)
    80006472:	fe9788e3          	beq	a5,s1,80006462 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006476:	f8042903          	lw	s2,-128(s0)
    8000647a:	20090793          	addi	a5,s2,512
    8000647e:	00479713          	slli	a4,a5,0x4
    80006482:	0001d797          	auipc	a5,0x1d
    80006486:	b7e78793          	addi	a5,a5,-1154 # 80023000 <disk>
    8000648a:	97ba                	add	a5,a5,a4
    8000648c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006490:	0001f997          	auipc	s3,0x1f
    80006494:	b7098993          	addi	s3,s3,-1168 # 80025000 <disk+0x2000>
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
    800064b8:	0001f517          	auipc	a0,0x1f
    800064bc:	c7050513          	addi	a0,a0,-912 # 80025128 <disk+0x2128>
    800064c0:	ffffa097          	auipc	ra,0xffffa
    800064c4:	7b6080e7          	jalr	1974(ra) # 80000c76 <release>
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
    800064f0:	0001d817          	auipc	a6,0x1d
    800064f4:	b1080813          	addi	a6,a6,-1264 # 80023000 <disk>
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
    80006510:	0001f697          	auipc	a3,0x1f
    80006514:	af068693          	addi	a3,a3,-1296 # 80025000 <disk+0x2000>
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
    8000653e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
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
    8000655c:	0001f697          	auipc	a3,0x1f
    80006560:	aa46b683          	ld	a3,-1372(a3) # 80025000 <disk+0x2000>
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
    8000657a:	0001f517          	auipc	a0,0x1f
    8000657e:	bae50513          	addi	a0,a0,-1106 # 80025128 <disk+0x2128>
    80006582:	ffffa097          	auipc	ra,0xffffa
    80006586:	640080e7          	jalr	1600(ra) # 80000bc2 <acquire>
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
    80006598:	0001f797          	auipc	a5,0x1f
    8000659c:	a6878793          	addi	a5,a5,-1432 # 80025000 <disk+0x2000>
    800065a0:	6b94                	ld	a3,16(a5)
    800065a2:	0207d703          	lhu	a4,32(a5)
    800065a6:	0026d783          	lhu	a5,2(a3)
    800065aa:	06f70163          	beq	a4,a5,8000660c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800065ae:	0001d917          	auipc	s2,0x1d
    800065b2:	a5290913          	addi	s2,s2,-1454 # 80023000 <disk>
    800065b6:	0001f497          	auipc	s1,0x1f
    800065ba:	a4a48493          	addi	s1,s1,-1462 # 80025000 <disk+0x2000>
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
    800065f0:	c9a080e7          	jalr	-870(ra) # 80002286 <wakeup>

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
    8000660c:	0001f517          	auipc	a0,0x1f
    80006610:	b1c50513          	addi	a0,a0,-1252 # 80025128 <disk+0x2128>
    80006614:	ffffa097          	auipc	ra,0xffffa
    80006618:	662080e7          	jalr	1634(ra) # 80000c76 <release>
}
    8000661c:	60e2                	ld	ra,24(sp)
    8000661e:	6442                	ld	s0,16(sp)
    80006620:	64a2                	ld	s1,8(sp)
    80006622:	6902                	ld	s2,0(sp)
    80006624:	6105                	addi	sp,sp,32
    80006626:	8082                	ret
      panic("virtio_disk_intr status");
    80006628:	00002517          	auipc	a0,0x2
    8000662c:	3c050513          	addi	a0,a0,960 # 800089e8 <syscalls+0x3c0>
    80006630:	ffffa097          	auipc	ra,0xffffa
    80006634:	efa080e7          	jalr	-262(ra) # 8000052a <panic>
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
