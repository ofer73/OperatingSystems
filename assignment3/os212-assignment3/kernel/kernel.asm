
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	18010113          	addi	sp,sp,384 # 8000b180 <stack0>
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
    80000052:	0000b717          	auipc	a4,0xb
    80000056:	fee70713          	addi	a4,a4,-18 # 8000b040 <timer_scratch>
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
    80000068:	c8c78793          	addi	a5,a5,-884 # 80006cf0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffce7ff>
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
    80000122:	71c080e7          	jalr	1820(ra) # 8000283a <either_copyin>
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
    8000017c:	00013517          	auipc	a0,0x13
    80000180:	00450513          	addi	a0,a0,4 # 80013180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a3e080e7          	jalr	-1474(ra) # 80000bc2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00013497          	auipc	s1,0x13
    80000190:	ff448493          	addi	s1,s1,-12 # 80013180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000194:	00013917          	auipc	s2,0x13
    80000198:	08490913          	addi	s2,s2,132 # 80013218 <cons+0x98>
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
    800001b2:	00002097          	auipc	ra,0x2
    800001b6:	ce2080e7          	jalr	-798(ra) # 80001e94 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	274080e7          	jalr	628(ra) # 80002436 <sleep>
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
    80000202:	5e6080e7          	jalr	1510(ra) # 800027e4 <either_copyout>
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
    80000212:	00013517          	auipc	a0,0x13
    80000216:	f6e50513          	addi	a0,a0,-146 # 80013180 <cons>
    8000021a:	00001097          	auipc	ra,0x1
    8000021e:	a5c080e7          	jalr	-1444(ra) # 80000c76 <release>

  return target - n;
    80000222:	413b053b          	subw	a0,s6,s3
    80000226:	a811                	j	8000023a <consoleread+0xe4>
        release(&cons.lock);
    80000228:	00013517          	auipc	a0,0x13
    8000022c:	f5850513          	addi	a0,a0,-168 # 80013180 <cons>
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
    8000025e:	00013717          	auipc	a4,0x13
    80000262:	faf72d23          	sw	a5,-70(a4) # 80013218 <cons+0x98>
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
    800002b8:	00013517          	auipc	a0,0x13
    800002bc:	ec850513          	addi	a0,a0,-312 # 80013180 <cons>
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
    800002e2:	5b2080e7          	jalr	1458(ra) # 80002890 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002e6:	00013517          	auipc	a0,0x13
    800002ea:	e9a50513          	addi	a0,a0,-358 # 80013180 <cons>
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
    8000030a:	00013717          	auipc	a4,0x13
    8000030e:	e7670713          	addi	a4,a4,-394 # 80013180 <cons>
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
    80000334:	00013797          	auipc	a5,0x13
    80000338:	e4c78793          	addi	a5,a5,-436 # 80013180 <cons>
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
    80000362:	00013797          	auipc	a5,0x13
    80000366:	eb67a783          	lw	a5,-330(a5) # 80013218 <cons+0x98>
    8000036a:	0807879b          	addiw	a5,a5,128
    8000036e:	f6f61ce3          	bne	a2,a5,800002e6 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000372:	863e                	mv	a2,a5
    80000374:	a07d                	j	80000422 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000376:	00013717          	auipc	a4,0x13
    8000037a:	e0a70713          	addi	a4,a4,-502 # 80013180 <cons>
    8000037e:	0a072783          	lw	a5,160(a4)
    80000382:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000386:	00013497          	auipc	s1,0x13
    8000038a:	dfa48493          	addi	s1,s1,-518 # 80013180 <cons>
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
    800003c2:	00013717          	auipc	a4,0x13
    800003c6:	dbe70713          	addi	a4,a4,-578 # 80013180 <cons>
    800003ca:	0a072783          	lw	a5,160(a4)
    800003ce:	09c72703          	lw	a4,156(a4)
    800003d2:	f0f70ae3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003d6:	37fd                	addiw	a5,a5,-1
    800003d8:	00013717          	auipc	a4,0x13
    800003dc:	e4f72423          	sw	a5,-440(a4) # 80013220 <cons+0xa0>
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
    800003fe:	00013797          	auipc	a5,0x13
    80000402:	d8278793          	addi	a5,a5,-638 # 80013180 <cons>
    80000406:	0a07a703          	lw	a4,160(a5)
    8000040a:	0017069b          	addiw	a3,a4,1
    8000040e:	0006861b          	sext.w	a2,a3
    80000412:	0ad7a023          	sw	a3,160(a5)
    80000416:	07f77713          	andi	a4,a4,127
    8000041a:	97ba                	add	a5,a5,a4
    8000041c:	4729                	li	a4,10
    8000041e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000422:	00013797          	auipc	a5,0x13
    80000426:	dec7ad23          	sw	a2,-518(a5) # 8001321c <cons+0x9c>
        wakeup(&cons.r);
    8000042a:	00013517          	auipc	a0,0x13
    8000042e:	dee50513          	addi	a0,a0,-530 # 80013218 <cons+0x98>
    80000432:	00002097          	auipc	ra,0x2
    80000436:	190080e7          	jalr	400(ra) # 800025c2 <wakeup>
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
    80000444:	00009597          	auipc	a1,0x9
    80000448:	bcc58593          	addi	a1,a1,-1076 # 80009010 <etext+0x10>
    8000044c:	00013517          	auipc	a0,0x13
    80000450:	d3450513          	addi	a0,a0,-716 # 80013180 <cons>
    80000454:	00000097          	auipc	ra,0x0
    80000458:	6de080e7          	jalr	1758(ra) # 80000b32 <initlock>

  uartinit();
    8000045c:	00000097          	auipc	ra,0x0
    80000460:	32a080e7          	jalr	810(ra) # 80000786 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000464:	0002b797          	auipc	a5,0x2b
    80000468:	6b478793          	addi	a5,a5,1716 # 8002bb18 <devsw>
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
    800004a6:	00009617          	auipc	a2,0x9
    800004aa:	b9a60613          	addi	a2,a2,-1126 # 80009040 <digits>
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
    80000536:	00013797          	auipc	a5,0x13
    8000053a:	d007a523          	sw	zero,-758(a5) # 80013240 <pr+0x18>
  printf("panic: ");
    8000053e:	00009517          	auipc	a0,0x9
    80000542:	ada50513          	addi	a0,a0,-1318 # 80009018 <etext+0x18>
    80000546:	00000097          	auipc	ra,0x0
    8000054a:	02e080e7          	jalr	46(ra) # 80000574 <printf>
  printf(s);
    8000054e:	8526                	mv	a0,s1
    80000550:	00000097          	auipc	ra,0x0
    80000554:	024080e7          	jalr	36(ra) # 80000574 <printf>
  printf("\n");
    80000558:	00009517          	auipc	a0,0x9
    8000055c:	3a850513          	addi	a0,a0,936 # 80009900 <digits+0x8c0>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	014080e7          	jalr	20(ra) # 80000574 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000568:	4785                	li	a5,1
    8000056a:	0000b717          	auipc	a4,0xb
    8000056e:	a8f72b23          	sw	a5,-1386(a4) # 8000b000 <panicked>
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
    800005a6:	00013d97          	auipc	s11,0x13
    800005aa:	c9adad83          	lw	s11,-870(s11) # 80013240 <pr+0x18>
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
    800005d2:	00009b17          	auipc	s6,0x9
    800005d6:	a6eb0b13          	addi	s6,s6,-1426 # 80009040 <digits>
    switch(c){
    800005da:	07300c93          	li	s9,115
    800005de:	06400c13          	li	s8,100
    800005e2:	a82d                	j	8000061c <printf+0xa8>
    acquire(&pr.lock);
    800005e4:	00013517          	auipc	a0,0x13
    800005e8:	c4450513          	addi	a0,a0,-956 # 80013228 <pr>
    800005ec:	00000097          	auipc	ra,0x0
    800005f0:	5d6080e7          	jalr	1494(ra) # 80000bc2 <acquire>
    800005f4:	bf7d                	j	800005b2 <printf+0x3e>
    panic("null fmt");
    800005f6:	00009517          	auipc	a0,0x9
    800005fa:	a3250513          	addi	a0,a0,-1486 # 80009028 <etext+0x28>
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
    800006f0:	00009497          	auipc	s1,0x9
    800006f4:	93048493          	addi	s1,s1,-1744 # 80009020 <etext+0x20>
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
    80000742:	00013517          	auipc	a0,0x13
    80000746:	ae650513          	addi	a0,a0,-1306 # 80013228 <pr>
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
    8000075e:	00013497          	auipc	s1,0x13
    80000762:	aca48493          	addi	s1,s1,-1334 # 80013228 <pr>
    80000766:	00009597          	auipc	a1,0x9
    8000076a:	8d258593          	addi	a1,a1,-1838 # 80009038 <etext+0x38>
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
    800007b6:	00009597          	auipc	a1,0x9
    800007ba:	8a258593          	addi	a1,a1,-1886 # 80009058 <digits+0x18>
    800007be:	00013517          	auipc	a0,0x13
    800007c2:	a8a50513          	addi	a0,a0,-1398 # 80013248 <uart_tx_lock>
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
    800007ea:	0000b797          	auipc	a5,0xb
    800007ee:	8167a783          	lw	a5,-2026(a5) # 8000b000 <panicked>
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
    80000822:	0000a797          	auipc	a5,0xa
    80000826:	7e67b783          	ld	a5,2022(a5) # 8000b008 <uart_tx_r>
    8000082a:	0000a717          	auipc	a4,0xa
    8000082e:	7e673703          	ld	a4,2022(a4) # 8000b010 <uart_tx_w>
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
    8000084c:	00013a17          	auipc	s4,0x13
    80000850:	9fca0a13          	addi	s4,s4,-1540 # 80013248 <uart_tx_lock>
    uart_tx_r += 1;
    80000854:	0000a497          	auipc	s1,0xa
    80000858:	7b448493          	addi	s1,s1,1972 # 8000b008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000085c:	0000a997          	auipc	s3,0xa
    80000860:	7b498993          	addi	s3,s3,1972 # 8000b010 <uart_tx_w>
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
    80000882:	d44080e7          	jalr	-700(ra) # 800025c2 <wakeup>
    
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
    800008ba:	00013517          	auipc	a0,0x13
    800008be:	98e50513          	addi	a0,a0,-1650 # 80013248 <uart_tx_lock>
    800008c2:	00000097          	auipc	ra,0x0
    800008c6:	300080e7          	jalr	768(ra) # 80000bc2 <acquire>
  if(panicked){
    800008ca:	0000a797          	auipc	a5,0xa
    800008ce:	7367a783          	lw	a5,1846(a5) # 8000b000 <panicked>
    800008d2:	c391                	beqz	a5,800008d6 <uartputc+0x2e>
    for(;;)
    800008d4:	a001                	j	800008d4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008d6:	0000a717          	auipc	a4,0xa
    800008da:	73a73703          	ld	a4,1850(a4) # 8000b010 <uart_tx_w>
    800008de:	0000a797          	auipc	a5,0xa
    800008e2:	72a7b783          	ld	a5,1834(a5) # 8000b008 <uart_tx_r>
    800008e6:	02078793          	addi	a5,a5,32
    800008ea:	02e79b63          	bne	a5,a4,80000920 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008ee:	00013997          	auipc	s3,0x13
    800008f2:	95a98993          	addi	s3,s3,-1702 # 80013248 <uart_tx_lock>
    800008f6:	0000a497          	auipc	s1,0xa
    800008fa:	71248493          	addi	s1,s1,1810 # 8000b008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fe:	0000a917          	auipc	s2,0xa
    80000902:	71290913          	addi	s2,s2,1810 # 8000b010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000906:	85ce                	mv	a1,s3
    80000908:	8526                	mv	a0,s1
    8000090a:	00002097          	auipc	ra,0x2
    8000090e:	b2c080e7          	jalr	-1236(ra) # 80002436 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000912:	00093703          	ld	a4,0(s2)
    80000916:	609c                	ld	a5,0(s1)
    80000918:	02078793          	addi	a5,a5,32
    8000091c:	fee785e3          	beq	a5,a4,80000906 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000920:	00013497          	auipc	s1,0x13
    80000924:	92848493          	addi	s1,s1,-1752 # 80013248 <uart_tx_lock>
    80000928:	01f77793          	andi	a5,a4,31
    8000092c:	97a6                	add	a5,a5,s1
    8000092e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000932:	0705                	addi	a4,a4,1
    80000934:	0000a797          	auipc	a5,0xa
    80000938:	6ce7be23          	sd	a4,1756(a5) # 8000b010 <uart_tx_w>
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
    800009a8:	00013497          	auipc	s1,0x13
    800009ac:	8a048493          	addi	s1,s1,-1888 # 80013248 <uart_tx_lock>
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
    800009ea:	0002f797          	auipc	a5,0x2f
    800009ee:	61678793          	addi	a5,a5,1558 # 80030000 <end>
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
    80000a0a:	00013917          	auipc	s2,0x13
    80000a0e:	87690913          	addi	s2,s2,-1930 # 80013280 <kmem>
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
    80000a3c:	00008517          	auipc	a0,0x8
    80000a40:	62450513          	addi	a0,a0,1572 # 80009060 <digits+0x20>
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
    80000a9e:	00008597          	auipc	a1,0x8
    80000aa2:	5ca58593          	addi	a1,a1,1482 # 80009068 <digits+0x28>
    80000aa6:	00012517          	auipc	a0,0x12
    80000aaa:	7da50513          	addi	a0,a0,2010 # 80013280 <kmem>
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	084080e7          	jalr	132(ra) # 80000b32 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ab6:	45c5                	li	a1,17
    80000ab8:	05ee                	slli	a1,a1,0x1b
    80000aba:	0002f517          	auipc	a0,0x2f
    80000abe:	54650513          	addi	a0,a0,1350 # 80030000 <end>
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
    80000adc:	00012497          	auipc	s1,0x12
    80000ae0:	7a448493          	addi	s1,s1,1956 # 80013280 <kmem>
    80000ae4:	8526                	mv	a0,s1
    80000ae6:	00000097          	auipc	ra,0x0
    80000aea:	0dc080e7          	jalr	220(ra) # 80000bc2 <acquire>
  r = kmem.freelist;
    80000aee:	6c84                	ld	s1,24(s1)
  if(r)
    80000af0:	c885                	beqz	s1,80000b20 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af2:	609c                	ld	a5,0(s1)
    80000af4:	00012517          	auipc	a0,0x12
    80000af8:	78c50513          	addi	a0,a0,1932 # 80013280 <kmem>
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
    80000b20:	00012517          	auipc	a0,0x12
    80000b24:	76050513          	addi	a0,a0,1888 # 80013280 <kmem>
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
    80000b60:	31c080e7          	jalr	796(ra) # 80001e78 <mycpu>
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
    80000b92:	2ea080e7          	jalr	746(ra) # 80001e78 <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	2de080e7          	jalr	734(ra) # 80001e78 <mycpu>
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
    80000bb6:	2c6080e7          	jalr	710(ra) # 80001e78 <mycpu>
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
    80000bf6:	286080e7          	jalr	646(ra) # 80001e78 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00008517          	auipc	a0,0x8
    80000c0a:	46a50513          	addi	a0,a0,1130 # 80009070 <digits+0x30>
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
    80000c22:	25a080e7          	jalr	602(ra) # 80001e78 <mycpu>
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
    80000c56:	00008517          	auipc	a0,0x8
    80000c5a:	42250513          	addi	a0,a0,1058 # 80009078 <digits+0x38>
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	8cc080e7          	jalr	-1844(ra) # 8000052a <panic>
    panic("pop_off");
    80000c66:	00008517          	auipc	a0,0x8
    80000c6a:	42a50513          	addi	a0,a0,1066 # 80009090 <digits+0x50>
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
    80000cae:	00008517          	auipc	a0,0x8
    80000cb2:	3ea50513          	addi	a0,a0,1002 # 80009098 <digits+0x58>
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
    80000e78:	ff4080e7          	jalr	-12(ra) # 80001e68 <cpuid>
    __sync_synchronize();


    started = 1;
  } else {
    while(started == 0)
    80000e7c:	0000a717          	auipc	a4,0xa
    80000e80:	19c70713          	addi	a4,a4,412 # 8000b018 <started>
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
    80000e94:	fd8080e7          	jalr	-40(ra) # 80001e68 <cpuid>
    80000e98:	85aa                	mv	a1,a0
    80000e9a:	00008517          	auipc	a0,0x8
    80000e9e:	21e50513          	addi	a0,a0,542 # 800090b8 <digits+0x78>
    80000ea2:	fffff097          	auipc	ra,0xfffff
    80000ea6:	6d2080e7          	jalr	1746(ra) # 80000574 <printf>
    kvminithart();    // turn on paging
    80000eaa:	00000097          	auipc	ra,0x0
    80000eae:	0d8080e7          	jalr	216(ra) # 80000f82 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb2:	00002097          	auipc	ra,0x2
    80000eb6:	25c080e7          	jalr	604(ra) # 8000310e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00006097          	auipc	ra,0x6
    80000ebe:	e76080e7          	jalr	-394(ra) # 80006d30 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	3c2080e7          	jalr	962(ra) # 80002284 <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00009517          	auipc	a0,0x9
    80000ede:	a2650513          	addi	a0,a0,-1498 # 80009900 <digits+0x8c0>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00008517          	auipc	a0,0x8
    80000eee:	1b650513          	addi	a0,a0,438 # 800090a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00009517          	auipc	a0,0x9
    80000efe:	a0650513          	addi	a0,a0,-1530 # 80009900 <digits+0x8c0>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    kinit();         // physical page allocator
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	b8c080e7          	jalr	-1140(ra) # 80000a96 <kinit>
    kvminit();       // create kernel page table
    80000f12:	00000097          	auipc	ra,0x0
    80000f16:	326080e7          	jalr	806(ra) # 80001238 <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	068080e7          	jalr	104(ra) # 80000f82 <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	e96080e7          	jalr	-362(ra) # 80001db8 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	1bc080e7          	jalr	444(ra) # 800030e6 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	1dc080e7          	jalr	476(ra) # 8000310e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00006097          	auipc	ra,0x6
    80000f3e:	de0080e7          	jalr	-544(ra) # 80006d1a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00006097          	auipc	ra,0x6
    80000f46:	dee080e7          	jalr	-530(ra) # 80006d30 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00003097          	auipc	ra,0x3
    80000f4e:	a18080e7          	jalr	-1512(ra) # 80003962 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	0aa080e7          	jalr	170(ra) # 80003ffc <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	37a080e7          	jalr	890(ra) # 800052d4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00006097          	auipc	ra,0x6
    80000f66:	ef0080e7          	jalr	-272(ra) # 80006e52 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	212080e7          	jalr	530(ra) # 8000217c <userinit>
    __sync_synchronize();
    80000f72:	0ff0000f          	fence
    started = 1;
    80000f76:	4785                	li	a5,1
    80000f78:	0000a717          	auipc	a4,0xa
    80000f7c:	0af72023          	sw	a5,160(a4) # 8000b018 <started>
    80000f80:	b789                	j	80000ec2 <main+0x56>

0000000080000f82 <kvminithart>:
}

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void kvminithart()
{
    80000f82:	1141                	addi	sp,sp,-16
    80000f84:	e422                	sd	s0,8(sp)
    80000f86:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f88:	0000a797          	auipc	a5,0xa
    80000f8c:	0987b783          	ld	a5,152(a5) # 8000b020 <kernel_pagetable>
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
  if (va >= MAXVA)
    80000fc0:	57fd                	li	a5,-1
    80000fc2:	83e9                	srli	a5,a5,0x1a
    80000fc4:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--)
    80000fc6:	4b31                	li	s6,12
  if (va >= MAXVA)
    80000fc8:	04b7f263          	bgeu	a5,a1,8000100c <walk+0x66>
    panic("walk");
    80000fcc:	00008517          	auipc	a0,0x8
    80000fd0:	10450513          	addi	a0,a0,260 # 800090d0 <digits+0x90>
    80000fd4:	fffff097          	auipc	ra,0xfffff
    80000fd8:	556080e7          	jalr	1366(ra) # 8000052a <panic>
    {
      pagetable = (pagetable_t)PTE2PA(*pte);
    }
    else
    {
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
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
  for (int level = 2; level > 0; level--)
    80001006:	3a5d                	addiw	s4,s4,-9
    80001008:	036a0063          	beq	s4,s6,80001028 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000100c:	0149d933          	srl	s2,s3,s4
    80001010:	1ff97913          	andi	s2,s2,511
    80001014:	090e                	slli	s2,s2,0x3
    80001016:	9926                	add	s2,s2,s1
    if (*pte & PTE_V)
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
  // check if we have space in phsical addres or in case the

  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    8000104c:	57fd                	li	a5,-1
    8000104e:	83e9                	srli	a5,a5,0x1a
    80001050:	00b7f463          	bgeu	a5,a1,80001058 <walkaddr+0xc>
    return 0;
    80001054:	4501                	li	a0,0
      panic("walkaddr: fack pte is not valid ");
    *pte ^= PTE_V;  // page table entry now invalid
    *pte |= PTE_PG; // paged out to secondary storage
  }
  return pa;
}
    80001056:	8082                	ret
{
    80001058:	1101                	addi	sp,sp,-32
    8000105a:	ec06                	sd	ra,24(sp)
    8000105c:	e822                	sd	s0,16(sp)
    8000105e:	e426                	sd	s1,8(sp)
    80001060:	1000                	addi	s0,sp,32
    80001062:	84b2                	mv	s1,a2
  pte = walk(pagetable, va, 0);
    80001064:	4601                	li	a2,0
    80001066:	00000097          	auipc	ra,0x0
    8000106a:	f40080e7          	jalr	-192(ra) # 80000fa6 <walk>
    8000106e:	872a                	mv	a4,a0
  if (pte == 0)
    80001070:	c905                	beqz	a0,800010a0 <walkaddr+0x54>
  if ((*pte & PTE_V) == 0)
    80001072:	6114                	ld	a3,0(a0)
  if ((*pte & PTE_U) == 0)
    80001074:	0116f613          	andi	a2,a3,17
    80001078:	47c5                	li	a5,17
    return 0;
    8000107a:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    8000107c:	00f60763          	beq	a2,a5,8000108a <walkaddr+0x3e>
}
    80001080:	60e2                	ld	ra,24(sp)
    80001082:	6442                	ld	s0,16(sp)
    80001084:	64a2                	ld	s1,8(sp)
    80001086:	6105                	addi	sp,sp,32
    80001088:	8082                	ret
  pa = PTE2PA(*pte);
    8000108a:	00a6d793          	srli	a5,a3,0xa
    8000108e:	00c79513          	slli	a0,a5,0xc
  if (to_page_out)
    80001092:	d4fd                	beqz	s1,80001080 <walkaddr+0x34>
    *pte ^= PTE_V;  // page table entry now invalid
    80001094:	0016c693          	xori	a3,a3,1
    *pte |= PTE_PG; // paged out to secondary storage
    80001098:	2006e693          	ori	a3,a3,512
    8000109c:	e314                	sd	a3,0(a4)
    8000109e:	b7cd                	j	80001080 <walkaddr+0x34>
    return 0;
    800010a0:	4501                	li	a0,0
    800010a2:	bff9                	j	80001080 <walkaddr+0x34>

00000000800010a4 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a4:	715d                	addi	sp,sp,-80
    800010a6:	e486                	sd	ra,72(sp)
    800010a8:	e0a2                	sd	s0,64(sp)
    800010aa:	fc26                	sd	s1,56(sp)
    800010ac:	f84a                	sd	s2,48(sp)
    800010ae:	f44e                	sd	s3,40(sp)
    800010b0:	f052                	sd	s4,32(sp)
    800010b2:	ec56                	sd	s5,24(sp)
    800010b4:	e85a                	sd	s6,16(sp)
    800010b6:	e45e                	sd	s7,8(sp)
    800010b8:	0880                	addi	s0,sp,80
    800010ba:	8aaa                	mv	s5,a0
    800010bc:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010be:	777d                	lui	a4,0xfffff
    800010c0:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c4:	167d                	addi	a2,a2,-1
    800010c6:	00b609b3          	add	s3,a2,a1
    800010ca:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010ce:	893e                	mv	s2,a5
    800010d0:	40f68a33          	sub	s4,a3,a5
    if (*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    800010d4:	6b85                	lui	s7,0x1
    800010d6:	012a04b3          	add	s1,s4,s2
    if ((pte = walk(pagetable, a, 1)) == 0)
    800010da:	4605                	li	a2,1
    800010dc:	85ca                	mv	a1,s2
    800010de:	8556                	mv	a0,s5
    800010e0:	00000097          	auipc	ra,0x0
    800010e4:	ec6080e7          	jalr	-314(ra) # 80000fa6 <walk>
    800010e8:	c51d                	beqz	a0,80001116 <mappages+0x72>
    if (*pte & PTE_V)
    800010ea:	611c                	ld	a5,0(a0)
    800010ec:	8b85                	andi	a5,a5,1
    800010ee:	ef81                	bnez	a5,80001106 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010f0:	80b1                	srli	s1,s1,0xc
    800010f2:	04aa                	slli	s1,s1,0xa
    800010f4:	0164e4b3          	or	s1,s1,s6
    800010f8:	0014e493          	ori	s1,s1,1
    800010fc:	e104                	sd	s1,0(a0)
    if (a == last)
    800010fe:	03390863          	beq	s2,s3,8000112e <mappages+0x8a>
    a += PGSIZE;
    80001102:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001104:	bfc9                	j	800010d6 <mappages+0x32>
      panic("remap");
    80001106:	00008517          	auipc	a0,0x8
    8000110a:	fd250513          	addi	a0,a0,-46 # 800090d8 <digits+0x98>
    8000110e:	fffff097          	auipc	ra,0xfffff
    80001112:	41c080e7          	jalr	1052(ra) # 8000052a <panic>
      return -1;
    80001116:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001118:	60a6                	ld	ra,72(sp)
    8000111a:	6406                	ld	s0,64(sp)
    8000111c:	74e2                	ld	s1,56(sp)
    8000111e:	7942                	ld	s2,48(sp)
    80001120:	79a2                	ld	s3,40(sp)
    80001122:	7a02                	ld	s4,32(sp)
    80001124:	6ae2                	ld	s5,24(sp)
    80001126:	6b42                	ld	s6,16(sp)
    80001128:	6ba2                	ld	s7,8(sp)
    8000112a:	6161                	addi	sp,sp,80
    8000112c:	8082                	ret
  return 0;
    8000112e:	4501                	li	a0,0
    80001130:	b7e5                	j	80001118 <mappages+0x74>

0000000080001132 <kvmmap>:
{
    80001132:	1141                	addi	sp,sp,-16
    80001134:	e406                	sd	ra,8(sp)
    80001136:	e022                	sd	s0,0(sp)
    80001138:	0800                	addi	s0,sp,16
    8000113a:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000113c:	86b2                	mv	a3,a2
    8000113e:	863e                	mv	a2,a5
    80001140:	00000097          	auipc	ra,0x0
    80001144:	f64080e7          	jalr	-156(ra) # 800010a4 <mappages>
    80001148:	e509                	bnez	a0,80001152 <kvmmap+0x20>
}
    8000114a:	60a2                	ld	ra,8(sp)
    8000114c:	6402                	ld	s0,0(sp)
    8000114e:	0141                	addi	sp,sp,16
    80001150:	8082                	ret
    panic("kvmmap");
    80001152:	00008517          	auipc	a0,0x8
    80001156:	f8e50513          	addi	a0,a0,-114 # 800090e0 <digits+0xa0>
    8000115a:	fffff097          	auipc	ra,0xfffff
    8000115e:	3d0080e7          	jalr	976(ra) # 8000052a <panic>

0000000080001162 <kvmmake>:
{
    80001162:	1101                	addi	sp,sp,-32
    80001164:	ec06                	sd	ra,24(sp)
    80001166:	e822                	sd	s0,16(sp)
    80001168:	e426                	sd	s1,8(sp)
    8000116a:	e04a                	sd	s2,0(sp)
    8000116c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    8000116e:	00000097          	auipc	ra,0x0
    80001172:	964080e7          	jalr	-1692(ra) # 80000ad2 <kalloc>
    80001176:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001178:	6605                	lui	a2,0x1
    8000117a:	4581                	li	a1,0
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	b42080e7          	jalr	-1214(ra) # 80000cbe <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001184:	4719                	li	a4,6
    80001186:	6685                	lui	a3,0x1
    80001188:	10000637          	lui	a2,0x10000
    8000118c:	100005b7          	lui	a1,0x10000
    80001190:	8526                	mv	a0,s1
    80001192:	00000097          	auipc	ra,0x0
    80001196:	fa0080e7          	jalr	-96(ra) # 80001132 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000119a:	4719                	li	a4,6
    8000119c:	6685                	lui	a3,0x1
    8000119e:	10001637          	lui	a2,0x10001
    800011a2:	100015b7          	lui	a1,0x10001
    800011a6:	8526                	mv	a0,s1
    800011a8:	00000097          	auipc	ra,0x0
    800011ac:	f8a080e7          	jalr	-118(ra) # 80001132 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b0:	4719                	li	a4,6
    800011b2:	004006b7          	lui	a3,0x400
    800011b6:	0c000637          	lui	a2,0xc000
    800011ba:	0c0005b7          	lui	a1,0xc000
    800011be:	8526                	mv	a0,s1
    800011c0:	00000097          	auipc	ra,0x0
    800011c4:	f72080e7          	jalr	-142(ra) # 80001132 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    800011c8:	00008917          	auipc	s2,0x8
    800011cc:	e3890913          	addi	s2,s2,-456 # 80009000 <etext>
    800011d0:	4729                	li	a4,10
    800011d2:	80008697          	auipc	a3,0x80008
    800011d6:	e2e68693          	addi	a3,a3,-466 # 9000 <_entry-0x7fff7000>
    800011da:	4605                	li	a2,1
    800011dc:	067e                	slli	a2,a2,0x1f
    800011de:	85b2                	mv	a1,a2
    800011e0:	8526                	mv	a0,s1
    800011e2:	00000097          	auipc	ra,0x0
    800011e6:	f50080e7          	jalr	-176(ra) # 80001132 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext, PTE_R | PTE_W);
    800011ea:	4719                	li	a4,6
    800011ec:	46c5                	li	a3,17
    800011ee:	06ee                	slli	a3,a3,0x1b
    800011f0:	412686b3          	sub	a3,a3,s2
    800011f4:	864a                	mv	a2,s2
    800011f6:	85ca                	mv	a1,s2
    800011f8:	8526                	mv	a0,s1
    800011fa:	00000097          	auipc	ra,0x0
    800011fe:	f38080e7          	jalr	-200(ra) # 80001132 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001202:	4729                	li	a4,10
    80001204:	6685                	lui	a3,0x1
    80001206:	00007617          	auipc	a2,0x7
    8000120a:	dfa60613          	addi	a2,a2,-518 # 80008000 <_trampoline>
    8000120e:	040005b7          	lui	a1,0x4000
    80001212:	15fd                	addi	a1,a1,-1
    80001214:	05b2                	slli	a1,a1,0xc
    80001216:	8526                	mv	a0,s1
    80001218:	00000097          	auipc	ra,0x0
    8000121c:	f1a080e7          	jalr	-230(ra) # 80001132 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001220:	8526                	mv	a0,s1
    80001222:	00001097          	auipc	ra,0x1
    80001226:	b00080e7          	jalr	-1280(ra) # 80001d22 <proc_mapstacks>
}
    8000122a:	8526                	mv	a0,s1
    8000122c:	60e2                	ld	ra,24(sp)
    8000122e:	6442                	ld	s0,16(sp)
    80001230:	64a2                	ld	s1,8(sp)
    80001232:	6902                	ld	s2,0(sp)
    80001234:	6105                	addi	sp,sp,32
    80001236:	8082                	ret

0000000080001238 <kvminit>:
{
    80001238:	1141                	addi	sp,sp,-16
    8000123a:	e406                	sd	ra,8(sp)
    8000123c:	e022                	sd	s0,0(sp)
    8000123e:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001240:	00000097          	auipc	ra,0x0
    80001244:	f22080e7          	jalr	-222(ra) # 80001162 <kvmmake>
    80001248:	0000a797          	auipc	a5,0xa
    8000124c:	dca7bc23          	sd	a0,-552(a5) # 8000b020 <kernel_pagetable>
}
    80001250:	60a2                	ld	ra,8(sp)
    80001252:	6402                	ld	s0,0(sp)
    80001254:	0141                	addi	sp,sp,16
    80001256:	8082                	ret

0000000080001258 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001258:	1101                	addi	sp,sp,-32
    8000125a:	ec06                	sd	ra,24(sp)
    8000125c:	e822                	sd	s0,16(sp)
    8000125e:	e426                	sd	s1,8(sp)
    80001260:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80001262:	00000097          	auipc	ra,0x0
    80001266:	870080e7          	jalr	-1936(ra) # 80000ad2 <kalloc>
    8000126a:	84aa                	mv	s1,a0
  if (pagetable == 0)
    8000126c:	c519                	beqz	a0,8000127a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000126e:	6605                	lui	a2,0x1
    80001270:	4581                	li	a1,0
    80001272:	00000097          	auipc	ra,0x0
    80001276:	a4c080e7          	jalr	-1460(ra) # 80000cbe <memset>
  return pagetable;
}
    8000127a:	8526                	mv	a0,s1
    8000127c:	60e2                	ld	ra,24(sp)
    8000127e:	6442                	ld	s0,16(sp)
    80001280:	64a2                	ld	s1,8(sp)
    80001282:	6105                	addi	sp,sp,32
    80001284:	8082                	ret

0000000080001286 <uvminit>:

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001286:	7179                	addi	sp,sp,-48
    80001288:	f406                	sd	ra,40(sp)
    8000128a:	f022                	sd	s0,32(sp)
    8000128c:	ec26                	sd	s1,24(sp)
    8000128e:	e84a                	sd	s2,16(sp)
    80001290:	e44e                	sd	s3,8(sp)
    80001292:	e052                	sd	s4,0(sp)
    80001294:	1800                	addi	s0,sp,48
  char *mem;

  if (sz >= PGSIZE)
    80001296:	6785                	lui	a5,0x1
    80001298:	04f67863          	bgeu	a2,a5,800012e8 <uvminit+0x62>
    8000129c:	8a2a                	mv	s4,a0
    8000129e:	89ae                	mv	s3,a1
    800012a0:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800012a2:	00000097          	auipc	ra,0x0
    800012a6:	830080e7          	jalr	-2000(ra) # 80000ad2 <kalloc>
    800012aa:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012ac:	6605                	lui	a2,0x1
    800012ae:	4581                	li	a1,0
    800012b0:	00000097          	auipc	ra,0x0
    800012b4:	a0e080e7          	jalr	-1522(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W | PTE_R | PTE_X | PTE_U);
    800012b8:	4779                	li	a4,30
    800012ba:	86ca                	mv	a3,s2
    800012bc:	6605                	lui	a2,0x1
    800012be:	4581                	li	a1,0
    800012c0:	8552                	mv	a0,s4
    800012c2:	00000097          	auipc	ra,0x0
    800012c6:	de2080e7          	jalr	-542(ra) # 800010a4 <mappages>
  memmove(mem, src, sz);
    800012ca:	8626                	mv	a2,s1
    800012cc:	85ce                	mv	a1,s3
    800012ce:	854a                	mv	a0,s2
    800012d0:	00000097          	auipc	ra,0x0
    800012d4:	a4a080e7          	jalr	-1462(ra) # 80000d1a <memmove>
}
    800012d8:	70a2                	ld	ra,40(sp)
    800012da:	7402                	ld	s0,32(sp)
    800012dc:	64e2                	ld	s1,24(sp)
    800012de:	6942                	ld	s2,16(sp)
    800012e0:	69a2                	ld	s3,8(sp)
    800012e2:	6a02                	ld	s4,0(sp)
    800012e4:	6145                	addi	sp,sp,48
    800012e6:	8082                	ret
    panic("inituvm: more than a page");
    800012e8:	00008517          	auipc	a0,0x8
    800012ec:	e0050513          	addi	a0,a0,-512 # 800090e8 <digits+0xa8>
    800012f0:	fffff097          	auipc	ra,0xfffff
    800012f4:	23a080e7          	jalr	570(ra) # 8000052a <panic>

00000000800012f8 <freewalk>:
}

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void freewalk(pagetable_t pagetable)
{
    800012f8:	7179                	addi	sp,sp,-48
    800012fa:	f406                	sd	ra,40(sp)
    800012fc:	f022                	sd	s0,32(sp)
    800012fe:	ec26                	sd	s1,24(sp)
    80001300:	e84a                	sd	s2,16(sp)
    80001302:	e44e                	sd	s3,8(sp)
    80001304:	e052                	sd	s4,0(sp)
    80001306:	1800                	addi	s0,sp,48
    80001308:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++)
    8000130a:	84aa                	mv	s1,a0
    8000130c:	6905                	lui	s2,0x1
    8000130e:	992a                	add	s2,s2,a0
  {
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80001310:	4985                	li	s3,1
    80001312:	a821                	j	8000132a <freewalk+0x32>
    {
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001314:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001316:	0532                	slli	a0,a0,0xc
    80001318:	00000097          	auipc	ra,0x0
    8000131c:	fe0080e7          	jalr	-32(ra) # 800012f8 <freewalk>
      pagetable[i] = 0;
    80001320:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++)
    80001324:	04a1                	addi	s1,s1,8
    80001326:	03248163          	beq	s1,s2,80001348 <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000132a:	6088                	ld	a0,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    8000132c:	00f57793          	andi	a5,a0,15
    80001330:	ff3782e3          	beq	a5,s3,80001314 <freewalk+0x1c>
    }
    else if (pte & PTE_V)
    80001334:	8905                	andi	a0,a0,1
    80001336:	d57d                	beqz	a0,80001324 <freewalk+0x2c>
    {
      panic("freewalk: leaf");
    80001338:	00008517          	auipc	a0,0x8
    8000133c:	dd050513          	addi	a0,a0,-560 # 80009108 <digits+0xc8>
    80001340:	fffff097          	auipc	ra,0xfffff
    80001344:	1ea080e7          	jalr	490(ra) # 8000052a <panic>
    }
  }
  kfree((void *)pagetable);
    80001348:	8552                	mv	a0,s4
    8000134a:	fffff097          	auipc	ra,0xfffff
    8000134e:	68c080e7          	jalr	1676(ra) # 800009d6 <kfree>
}
    80001352:	70a2                	ld	ra,40(sp)
    80001354:	7402                	ld	s0,32(sp)
    80001356:	64e2                	ld	s1,24(sp)
    80001358:	6942                	ld	s2,16(sp)
    8000135a:	69a2                	ld	s3,8(sp)
    8000135c:	6a02                	ld	s4,0(sp)
    8000135e:	6145                	addi	sp,sp,48
    80001360:	8082                	ret

0000000080001362 <uvmclear>:
}

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void uvmclear(pagetable_t pagetable, uint64 va)
{
    80001362:	1101                	addi	sp,sp,-32
    80001364:	ec06                	sd	ra,24(sp)
    80001366:	e822                	sd	s0,16(sp)
    80001368:	e426                	sd	s1,8(sp)
    8000136a:	e04a                	sd	s2,0(sp)
    8000136c:	1000                	addi	s0,sp,32
    8000136e:	84aa                	mv	s1,a0
    80001370:	892e                	mv	s2,a1
  printf("uvmclear...\n"); // TODO delete
    80001372:	00008517          	auipc	a0,0x8
    80001376:	da650513          	addi	a0,a0,-602 # 80009118 <digits+0xd8>
    8000137a:	fffff097          	auipc	ra,0xfffff
    8000137e:	1fa080e7          	jalr	506(ra) # 80000574 <printf>

  pte_t *pte;

  pte = walk(pagetable, va, 0);
    80001382:	4601                	li	a2,0
    80001384:	85ca                	mv	a1,s2
    80001386:	8526                	mv	a0,s1
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	c1e080e7          	jalr	-994(ra) # 80000fa6 <walk>
  if (pte == 0)
    80001390:	c911                	beqz	a0,800013a4 <uvmclear+0x42>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001392:	611c                	ld	a5,0(a0)
    80001394:	9bbd                	andi	a5,a5,-17
    80001396:	e11c                	sd	a5,0(a0)
}
    80001398:	60e2                	ld	ra,24(sp)
    8000139a:	6442                	ld	s0,16(sp)
    8000139c:	64a2                	ld	s1,8(sp)
    8000139e:	6902                	ld	s2,0(sp)
    800013a0:	6105                	addi	sp,sp,32
    800013a2:	8082                	ret
    panic("uvmclear");
    800013a4:	00008517          	auipc	a0,0x8
    800013a8:	d8450513          	addi	a0,a0,-636 # 80009128 <digits+0xe8>
    800013ac:	fffff097          	auipc	ra,0xfffff
    800013b0:	17e080e7          	jalr	382(ra) # 8000052a <panic>

00000000800013b4 <copyout>:

// Copy from kernel to user.
// Copy len bytes from src to virtual address dstva in a given page table.
// Return 0 on success, -1 on error.
int copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
    800013b4:	711d                	addi	sp,sp,-96
    800013b6:	ec86                	sd	ra,88(sp)
    800013b8:	e8a2                	sd	s0,80(sp)
    800013ba:	e4a6                	sd	s1,72(sp)
    800013bc:	e0ca                	sd	s2,64(sp)
    800013be:	fc4e                	sd	s3,56(sp)
    800013c0:	f852                	sd	s4,48(sp)
    800013c2:	f456                	sd	s5,40(sp)
    800013c4:	f05a                	sd	s6,32(sp)
    800013c6:	ec5e                	sd	s7,24(sp)
    800013c8:	e862                	sd	s8,16(sp)
    800013ca:	e466                	sd	s9,8(sp)
    800013cc:	1080                	addi	s0,sp,96
    800013ce:	8baa                	mv	s7,a0
    800013d0:	8a2e                	mv	s4,a1
    800013d2:	8ab2                	mv	s5,a2
    800013d4:	89b6                	mv	s3,a3
  printf("copyout... va = %p, pid = %d\n",dstva, myproc()->pid);
    800013d6:	00001097          	auipc	ra,0x1
    800013da:	abe080e7          	jalr	-1346(ra) # 80001e94 <myproc>
    800013de:	5910                	lw	a2,48(a0)
    800013e0:	85d2                	mv	a1,s4
    800013e2:	00008517          	auipc	a0,0x8
    800013e6:	d5650513          	addi	a0,a0,-682 # 80009138 <digits+0xf8>
    800013ea:	fffff097          	auipc	ra,0xfffff
    800013ee:	18a080e7          	jalr	394(ra) # 80000574 <printf>
  uint64 n, va0, pa0;

  while (len > 0)
    800013f2:	06098363          	beqz	s3,80001458 <copyout+0xa4>
  {
    va0 = PGROUNDDOWN(dstva);
    800013f6:	7cfd                	lui	s9,0xfffff
    printf("va0 = %p\n",va0);
    800013f8:	00008c17          	auipc	s8,0x8
    800013fc:	d60c0c13          	addi	s8,s8,-672 # 80009158 <digits+0x118>
    pa0 = walkaddr(pagetable, va0, 0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001400:	6b05                	lui	s6,0x1
    80001402:	a015                	j	80001426 <copyout+0x72>
    if (n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001404:	9552                	add	a0,a0,s4
    80001406:	0004861b          	sext.w	a2,s1
    8000140a:	85d6                	mv	a1,s5
    8000140c:	41250533          	sub	a0,a0,s2
    80001410:	00000097          	auipc	ra,0x0
    80001414:	90a080e7          	jalr	-1782(ra) # 80000d1a <memmove>

    len -= n;
    80001418:	409989b3          	sub	s3,s3,s1
    src += n;
    8000141c:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    8000141e:	01690a33          	add	s4,s2,s6
  while (len > 0)
    80001422:	02098963          	beqz	s3,80001454 <copyout+0xa0>
    va0 = PGROUNDDOWN(dstva);
    80001426:	019a7933          	and	s2,s4,s9
    printf("va0 = %p\n",va0);
    8000142a:	85ca                	mv	a1,s2
    8000142c:	8562                	mv	a0,s8
    8000142e:	fffff097          	auipc	ra,0xfffff
    80001432:	146080e7          	jalr	326(ra) # 80000574 <printf>
    pa0 = walkaddr(pagetable, va0, 0);
    80001436:	4601                	li	a2,0
    80001438:	85ca                	mv	a1,s2
    8000143a:	855e                	mv	a0,s7
    8000143c:	00000097          	auipc	ra,0x0
    80001440:	c10080e7          	jalr	-1008(ra) # 8000104c <walkaddr>
    if (pa0 == 0)
    80001444:	cd01                	beqz	a0,8000145c <copyout+0xa8>
    n = PGSIZE - (dstva - va0);
    80001446:	414904b3          	sub	s1,s2,s4
    8000144a:	94da                	add	s1,s1,s6
    if (n > len)
    8000144c:	fa99fce3          	bgeu	s3,s1,80001404 <copyout+0x50>
    80001450:	84ce                	mv	s1,s3
    80001452:	bf4d                	j	80001404 <copyout+0x50>
  }
  return 0;
    80001454:	4501                	li	a0,0
    80001456:	a021                	j	8000145e <copyout+0xaa>
    80001458:	4501                	li	a0,0
    8000145a:	a011                	j	8000145e <copyout+0xaa>
      return -1;
    8000145c:	557d                	li	a0,-1
}
    8000145e:	60e6                	ld	ra,88(sp)
    80001460:	6446                	ld	s0,80(sp)
    80001462:	64a6                	ld	s1,72(sp)
    80001464:	6906                	ld	s2,64(sp)
    80001466:	79e2                	ld	s3,56(sp)
    80001468:	7a42                	ld	s4,48(sp)
    8000146a:	7aa2                	ld	s5,40(sp)
    8000146c:	7b02                	ld	s6,32(sp)
    8000146e:	6be2                	ld	s7,24(sp)
    80001470:	6c42                	ld	s8,16(sp)
    80001472:	6ca2                	ld	s9,8(sp)
    80001474:	6125                	addi	sp,sp,96
    80001476:	8082                	ret

0000000080001478 <copyin>:
// Return 0 on success, -1 on error.
int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while (len > 0)
    80001478:	caad                	beqz	a3,800014ea <copyin+0x72>
{
    8000147a:	715d                	addi	sp,sp,-80
    8000147c:	e486                	sd	ra,72(sp)
    8000147e:	e0a2                	sd	s0,64(sp)
    80001480:	fc26                	sd	s1,56(sp)
    80001482:	f84a                	sd	s2,48(sp)
    80001484:	f44e                	sd	s3,40(sp)
    80001486:	f052                	sd	s4,32(sp)
    80001488:	ec56                	sd	s5,24(sp)
    8000148a:	e85a                	sd	s6,16(sp)
    8000148c:	e45e                	sd	s7,8(sp)
    8000148e:	e062                	sd	s8,0(sp)
    80001490:	0880                	addi	s0,sp,80
    80001492:	8b2a                	mv	s6,a0
    80001494:	8a2e                	mv	s4,a1
    80001496:	8c32                	mv	s8,a2
    80001498:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(srcva);
    8000149a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0, 0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000149c:	6a85                	lui	s5,0x1
    8000149e:	a01d                	j	800014c4 <copyin+0x4c>
    if (n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800014a0:	018505b3          	add	a1,a0,s8
    800014a4:	0004861b          	sext.w	a2,s1
    800014a8:	412585b3          	sub	a1,a1,s2
    800014ac:	8552                	mv	a0,s4
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	86c080e7          	jalr	-1940(ra) # 80000d1a <memmove>

    len -= n;
    800014b6:	409989b3          	sub	s3,s3,s1
    dst += n;
    800014ba:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800014bc:	01590c33          	add	s8,s2,s5
  while (len > 0)
    800014c0:	02098363          	beqz	s3,800014e6 <copyin+0x6e>
    va0 = PGROUNDDOWN(srcva);
    800014c4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0, 0);
    800014c8:	4601                	li	a2,0
    800014ca:	85ca                	mv	a1,s2
    800014cc:	855a                	mv	a0,s6
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	b7e080e7          	jalr	-1154(ra) # 8000104c <walkaddr>
    if (pa0 == 0)
    800014d6:	cd01                	beqz	a0,800014ee <copyin+0x76>
    n = PGSIZE - (srcva - va0);
    800014d8:	418904b3          	sub	s1,s2,s8
    800014dc:	94d6                	add	s1,s1,s5
    if (n > len)
    800014de:	fc99f1e3          	bgeu	s3,s1,800014a0 <copyin+0x28>
    800014e2:	84ce                	mv	s1,s3
    800014e4:	bf75                	j	800014a0 <copyin+0x28>
  }
  return 0;
    800014e6:	4501                	li	a0,0
    800014e8:	a021                	j	800014f0 <copyin+0x78>
    800014ea:	4501                	li	a0,0
}
    800014ec:	8082                	ret
      return -1;
    800014ee:	557d                	li	a0,-1
}
    800014f0:	60a6                	ld	ra,72(sp)
    800014f2:	6406                	ld	s0,64(sp)
    800014f4:	74e2                	ld	s1,56(sp)
    800014f6:	7942                	ld	s2,48(sp)
    800014f8:	79a2                	ld	s3,40(sp)
    800014fa:	7a02                	ld	s4,32(sp)
    800014fc:	6ae2                	ld	s5,24(sp)
    800014fe:	6b42                	ld	s6,16(sp)
    80001500:	6ba2                	ld	s7,8(sp)
    80001502:	6c02                	ld	s8,0(sp)
    80001504:	6161                	addi	sp,sp,80
    80001506:	8082                	ret

0000000080001508 <copyinstr>:
int copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0)
    80001508:	c6cd                	beqz	a3,800015b2 <copyinstr+0xaa>
{
    8000150a:	715d                	addi	sp,sp,-80
    8000150c:	e486                	sd	ra,72(sp)
    8000150e:	e0a2                	sd	s0,64(sp)
    80001510:	fc26                	sd	s1,56(sp)
    80001512:	f84a                	sd	s2,48(sp)
    80001514:	f44e                	sd	s3,40(sp)
    80001516:	f052                	sd	s4,32(sp)
    80001518:	ec56                	sd	s5,24(sp)
    8000151a:	e85a                	sd	s6,16(sp)
    8000151c:	e45e                	sd	s7,8(sp)
    8000151e:	0880                	addi	s0,sp,80
    80001520:	8a2a                	mv	s4,a0
    80001522:	8b2e                	mv	s6,a1
    80001524:	8bb2                	mv	s7,a2
    80001526:	84b6                	mv	s1,a3
  {
    va0 = PGROUNDDOWN(srcva);
    80001528:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0, 0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000152a:	6985                	lui	s3,0x1
    8000152c:	a035                	j	80001558 <copyinstr+0x50>
    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0)
    {
      if (*p == '\0')
      {
        *dst = '\0';
    8000152e:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001532:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null)
    80001534:	0017b793          	seqz	a5,a5
    80001538:	40f00533          	neg	a0,a5
  }
  else
  {
    return -1;
  }
} 
    8000153c:	60a6                	ld	ra,72(sp)
    8000153e:	6406                	ld	s0,64(sp)
    80001540:	74e2                	ld	s1,56(sp)
    80001542:	7942                	ld	s2,48(sp)
    80001544:	79a2                	ld	s3,40(sp)
    80001546:	7a02                	ld	s4,32(sp)
    80001548:	6ae2                	ld	s5,24(sp)
    8000154a:	6b42                	ld	s6,16(sp)
    8000154c:	6ba2                	ld	s7,8(sp)
    8000154e:	6161                	addi	sp,sp,80
    80001550:	8082                	ret
    srcva = va0 + PGSIZE;
    80001552:	01390bb3          	add	s7,s2,s3
  while (got_null == 0 && max > 0)
    80001556:	c8b1                	beqz	s1,800015aa <copyinstr+0xa2>
    va0 = PGROUNDDOWN(srcva);
    80001558:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0, 0);
    8000155c:	4601                	li	a2,0
    8000155e:	85ca                	mv	a1,s2
    80001560:	8552                	mv	a0,s4
    80001562:	00000097          	auipc	ra,0x0
    80001566:	aea080e7          	jalr	-1302(ra) # 8000104c <walkaddr>
    if (pa0 == 0)
    8000156a:	c131                	beqz	a0,800015ae <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    8000156c:	41790833          	sub	a6,s2,s7
    80001570:	984e                	add	a6,a6,s3
    if (n > max)
    80001572:	0104f363          	bgeu	s1,a6,80001578 <copyinstr+0x70>
    80001576:	8826                	mv	a6,s1
    char *p = (char *)(pa0 + (srcva - va0));
    80001578:	955e                	add	a0,a0,s7
    8000157a:	41250533          	sub	a0,a0,s2
    while (n > 0)
    8000157e:	fc080ae3          	beqz	a6,80001552 <copyinstr+0x4a>
    80001582:	985a                	add	a6,a6,s6
    80001584:	87da                	mv	a5,s6
      if (*p == '\0')
    80001586:	41650633          	sub	a2,a0,s6
    8000158a:	14fd                	addi	s1,s1,-1
    8000158c:	9b26                	add	s6,s6,s1
    8000158e:	00f60733          	add	a4,a2,a5
    80001592:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffcf000>
    80001596:	df41                	beqz	a4,8000152e <copyinstr+0x26>
        *dst = *p;
    80001598:	00e78023          	sb	a4,0(a5)
      --max;
    8000159c:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800015a0:	0785                	addi	a5,a5,1
    while (n > 0)
    800015a2:	ff0796e3          	bne	a5,a6,8000158e <copyinstr+0x86>
      dst++;
    800015a6:	8b42                	mv	s6,a6
    800015a8:	b76d                	j	80001552 <copyinstr+0x4a>
    800015aa:	4781                	li	a5,0
    800015ac:	b761                	j	80001534 <copyinstr+0x2c>
      return -1;
    800015ae:	557d                	li	a0,-1
    800015b0:	b771                	j	8000153c <copyinstr+0x34>
  int got_null = 0;
    800015b2:	4781                	li	a5,0
  if (got_null)
    800015b4:	0017b793          	seqz	a5,a5
    800015b8:	40f00533          	neg	a0,a5
} 
    800015bc:	8082                	ret

00000000800015be <insert_page_to_swap_file>:
// Update data structure
int insert_page_to_swap_file(uint64 a)
{
    800015be:	1101                	addi	sp,sp,-32
    800015c0:	ec06                	sd	ra,24(sp)
    800015c2:	e822                	sd	s0,16(sp)
    800015c4:	e426                	sd	s1,8(sp)
    800015c6:	e04a                	sd	s2,0(sp)
    800015c8:	1000                	addi	s0,sp,32
    800015ca:	892a                	mv	s2,a0
  printf("insert_page_to_swap_file... va = %p , pid = %d\n",a,myproc()->pid);
    800015cc:	00001097          	auipc	ra,0x1
    800015d0:	8c8080e7          	jalr	-1848(ra) # 80001e94 <myproc>
    800015d4:	5910                	lw	a2,48(a0)
    800015d6:	85ca                	mv	a1,s2
    800015d8:	00008517          	auipc	a0,0x8
    800015dc:	b9050513          	addi	a0,a0,-1136 # 80009168 <digits+0x128>
    800015e0:	fffff097          	auipc	ra,0xfffff
    800015e4:	f94080e7          	jalr	-108(ra) # 80000574 <printf>
  struct proc *p = myproc();
    800015e8:	00001097          	auipc	ra,0x1
    800015ec:	8ac080e7          	jalr	-1876(ra) # 80001e94 <myproc>
    800015f0:	84aa                	mv	s1,a0
  int free_index = get_next_free_space(p->pages_swap_info.free_spaces);
    800015f2:	17855503          	lhu	a0,376(a0)
    800015f6:	00001097          	auipc	ra,0x1
    800015fa:	34a080e7          	jalr	842(ra) # 80002940 <get_next_free_space>
  if (free_index < 0 || free_index >= MAX_PSYC_PAGES)
    800015fe:	0005071b          	sext.w	a4,a0
    80001602:	47bd                	li	a5,15
    80001604:	02e7ea63          	bltu	a5,a4,80001638 <insert_page_to_swap_file+0x7a>
    panic("insert_swap: no free index in swap arr");
  p->pages_swap_info.pages[free_index].va = a;                // Set va of page
    80001608:	01750793          	addi	a5,a0,23
    8000160c:	0792                	slli	a5,a5,0x4
    8000160e:	97a6                	add	a5,a5,s1
    80001610:	0127b823          	sd	s2,16(a5)

  if (p->pages_swap_info.free_spaces & (1 << free_index))
    80001614:	1784d783          	lhu	a5,376(s1)
    80001618:	40a7d73b          	sraw	a4,a5,a0
    8000161c:	8b05                	andi	a4,a4,1
    8000161e:	e70d                	bnez	a4,80001648 <insert_page_to_swap_file+0x8a>
    panic("insert_swap: tried to set free space flag when it is already set");
  p->pages_swap_info.free_spaces |= (1 << free_index); // Mark space as occupied
    80001620:	4705                	li	a4,1
    80001622:	00a7173b          	sllw	a4,a4,a0
    80001626:	8fd9                	or	a5,a5,a4
    80001628:	16f49c23          	sh	a5,376(s1)

  return free_index;
}
    8000162c:	60e2                	ld	ra,24(sp)
    8000162e:	6442                	ld	s0,16(sp)
    80001630:	64a2                	ld	s1,8(sp)
    80001632:	6902                	ld	s2,0(sp)
    80001634:	6105                	addi	sp,sp,32
    80001636:	8082                	ret
    panic("insert_swap: no free index in swap arr");
    80001638:	00008517          	auipc	a0,0x8
    8000163c:	b6050513          	addi	a0,a0,-1184 # 80009198 <digits+0x158>
    80001640:	fffff097          	auipc	ra,0xfffff
    80001644:	eea080e7          	jalr	-278(ra) # 8000052a <panic>
    panic("insert_swap: tried to set free space flag when it is already set");
    80001648:	00008517          	auipc	a0,0x8
    8000164c:	b7850513          	addi	a0,a0,-1160 # 800091c0 <digits+0x180>
    80001650:	fffff097          	auipc	ra,0xfffff
    80001654:	eda080e7          	jalr	-294(ra) # 8000052a <panic>

0000000080001658 <insert_page_to_physical_memory>:
// Update data structure
int insert_page_to_physical_memory(uint64 a)
{
    80001658:	7179                	addi	sp,sp,-48
    8000165a:	f406                	sd	ra,40(sp)
    8000165c:	f022                	sd	s0,32(sp)
    8000165e:	ec26                	sd	s1,24(sp)
    80001660:	e84a                	sd	s2,16(sp)
    80001662:	e44e                	sd	s3,8(sp)
    80001664:	1800                	addi	s0,sp,48
    80001666:	89aa                	mv	s3,a0
  printf("insert_page_to_physical_memory... va=%p, pid = %d\n",a,myproc()->pid);
    80001668:	00001097          	auipc	ra,0x1
    8000166c:	82c080e7          	jalr	-2004(ra) # 80001e94 <myproc>
    80001670:	5910                	lw	a2,48(a0)
    80001672:	85ce                	mv	a1,s3
    80001674:	00008517          	auipc	a0,0x8
    80001678:	b9450513          	addi	a0,a0,-1132 # 80009208 <digits+0x1c8>
    8000167c:	fffff097          	auipc	ra,0xfffff
    80001680:	ef8080e7          	jalr	-264(ra) # 80000574 <printf>
  struct proc *p = myproc();
    80001684:	00001097          	auipc	ra,0x1
    80001688:	810080e7          	jalr	-2032(ra) # 80001e94 <myproc>
    8000168c:	892a                	mv	s2,a0
  int free_index = get_next_free_space(p->pages_physc_info.free_spaces);
    8000168e:	28055503          	lhu	a0,640(a0)
    80001692:	00001097          	auipc	ra,0x1
    80001696:	2ae080e7          	jalr	686(ra) # 80002940 <get_next_free_space>
  if (free_index < 0 || free_index >= MAX_PSYC_PAGES)
    8000169a:	0005071b          	sext.w	a4,a0
    8000169e:	47bd                	li	a5,15
    800016a0:	04e7ea63          	bltu	a5,a4,800016f4 <insert_page_to_physical_memory+0x9c>
    800016a4:	84aa                	mv	s1,a0
    panic("insert_phys: no free index in physc arr");
  p->pages_physc_info.pages[free_index].va = a;                // Set va of page
    800016a6:	00451793          	slli	a5,a0,0x4
    800016aa:	97ca                	add	a5,a5,s2
    800016ac:	2937b423          	sd	s3,648(a5)
  p->pages_physc_info.pages[free_index].time_inserted = ticks; //  Update insertion time
    800016b0:	0000a717          	auipc	a4,0xa
    800016b4:	98072703          	lw	a4,-1664(a4) # 8000b030 <ticks>
    800016b8:	28e7aa23          	sw	a4,660(a5)
  reset_aging_counter(&p->pages_physc_info.pages[free_index]);
    800016bc:	0512                	slli	a0,a0,0x4
    800016be:	28850513          	addi	a0,a0,648
    800016c2:	954a                	add	a0,a0,s2
    800016c4:	00002097          	auipc	ra,0x2
    800016c8:	8f6080e7          	jalr	-1802(ra) # 80002fba <reset_aging_counter>
  if (p->pages_physc_info.free_spaces & (1 << free_index))
    800016cc:	28095783          	lhu	a5,640(s2) # 1280 <_entry-0x7fffed80>
    800016d0:	4097d73b          	sraw	a4,a5,s1
    800016d4:	8b05                	andi	a4,a4,1
    800016d6:	e71d                	bnez	a4,80001704 <insert_page_to_physical_memory+0xac>
    panic("insert_phys: tried to set free space flag when it is already set");
  p->pages_physc_info.free_spaces |= (1 << free_index); // Mark space as occupied
    800016d8:	4705                	li	a4,1
    800016da:	0097173b          	sllw	a4,a4,s1
    800016de:	8fd9                	or	a5,a5,a4
    800016e0:	28f91023          	sh	a5,640(s2)

  return free_index;
}
    800016e4:	8526                	mv	a0,s1
    800016e6:	70a2                	ld	ra,40(sp)
    800016e8:	7402                	ld	s0,32(sp)
    800016ea:	64e2                	ld	s1,24(sp)
    800016ec:	6942                	ld	s2,16(sp)
    800016ee:	69a2                	ld	s3,8(sp)
    800016f0:	6145                	addi	sp,sp,48
    800016f2:	8082                	ret
    panic("insert_phys: no free index in physc arr");
    800016f4:	00008517          	auipc	a0,0x8
    800016f8:	b4c50513          	addi	a0,a0,-1204 # 80009240 <digits+0x200>
    800016fc:	fffff097          	auipc	ra,0xfffff
    80001700:	e2e080e7          	jalr	-466(ra) # 8000052a <panic>
    panic("insert_phys: tried to set free space flag when it is already set");
    80001704:	00008517          	auipc	a0,0x8
    80001708:	b6450513          	addi	a0,a0,-1180 # 80009268 <digits+0x228>
    8000170c:	fffff097          	auipc	ra,0xfffff
    80001710:	e1e080e7          	jalr	-482(ra) # 8000052a <panic>

0000000080001714 <remove_page_from_physical_memory>:

// Update data structure
int remove_page_from_physical_memory(uint64 a)
{
    80001714:	1101                	addi	sp,sp,-32
    80001716:	ec06                	sd	ra,24(sp)
    80001718:	e822                	sd	s0,16(sp)
    8000171a:	e426                	sd	s1,8(sp)
    8000171c:	e04a                	sd	s2,0(sp)
    8000171e:	1000                	addi	s0,sp,32
    80001720:	892a                	mv	s2,a0
  printf("remove_page_from_physical_memory va = %p pid=%d...\n",a,myproc()->pid);
    80001722:	00000097          	auipc	ra,0x0
    80001726:	772080e7          	jalr	1906(ra) # 80001e94 <myproc>
    8000172a:	5910                	lw	a2,48(a0)
    8000172c:	85ca                	mv	a1,s2
    8000172e:	00008517          	auipc	a0,0x8
    80001732:	b8250513          	addi	a0,a0,-1150 # 800092b0 <digits+0x270>
    80001736:	fffff097          	auipc	ra,0xfffff
    8000173a:	e3e080e7          	jalr	-450(ra) # 80000574 <printf>
  struct proc *p = myproc();
    8000173e:	00000097          	auipc	ra,0x0
    80001742:	756080e7          	jalr	1878(ra) # 80001e94 <myproc>
    80001746:	84aa                	mv	s1,a0
  int index = get_index_in_page_info_array(a, p->pages_physc_info.pages);
    80001748:	28850593          	addi	a1,a0,648
    8000174c:	854a                	mv	a0,s2
    8000174e:	00001097          	auipc	ra,0x1
    80001752:	21e080e7          	jalr	542(ra) # 8000296c <get_index_in_page_info_array>
  if (index < 0 || index >= MAX_PSYC_PAGES)
    80001756:	0005071b          	sext.w	a4,a0
    8000175a:	47bd                	li	a5,15
    8000175c:	02e7ec63          	bltu	a5,a4,80001794 <remove_page_from_physical_memory+0x80>
    return -1; // page is not in phisical mem
  // panic("remove_page_from_physical_memory: not found page to free ");
  if (!(p->pages_physc_info.free_spaces & (1 << index)))
    80001760:	2804d783          	lhu	a5,640(s1)
    80001764:	40a7d73b          	sraw	a4,a5,a0
    80001768:	8b05                	andi	a4,a4,1
    8000176a:	cf09                	beqz	a4,80001784 <remove_page_from_physical_memory+0x70>
    panic("remove_page_from_physical_memory: free space flag should be set but is unset");
  p->pages_physc_info.free_spaces ^= (1 << index);
    8000176c:	4705                	li	a4,1
    8000176e:	00a7173b          	sllw	a4,a4,a0
    80001772:	8fb9                	xor	a5,a5,a4
    80001774:	28f49023          	sh	a5,640(s1)

  return index;
}
    80001778:	60e2                	ld	ra,24(sp)
    8000177a:	6442                	ld	s0,16(sp)
    8000177c:	64a2                	ld	s1,8(sp)
    8000177e:	6902                	ld	s2,0(sp)
    80001780:	6105                	addi	sp,sp,32
    80001782:	8082                	ret
    panic("remove_page_from_physical_memory: free space flag should be set but is unset");
    80001784:	00008517          	auipc	a0,0x8
    80001788:	b6450513          	addi	a0,a0,-1180 # 800092e8 <digits+0x2a8>
    8000178c:	fffff097          	auipc	ra,0xfffff
    80001790:	d9e080e7          	jalr	-610(ra) # 8000052a <panic>
    return -1; // page is not in phisical mem
    80001794:	557d                	li	a0,-1
    80001796:	b7cd                	j	80001778 <remove_page_from_physical_memory+0x64>

0000000080001798 <remove_page_from_swap_file>:

// Update data structure
int remove_page_from_swap_file(uint64 a)
{
    80001798:	1101                	addi	sp,sp,-32
    8000179a:	ec06                	sd	ra,24(sp)
    8000179c:	e822                	sd	s0,16(sp)
    8000179e:	e426                	sd	s1,8(sp)
    800017a0:	e04a                	sd	s2,0(sp)
    800017a2:	1000                	addi	s0,sp,32
    800017a4:	892a                	mv	s2,a0
  printf("remove_page_from_swap_file, va =%p pid = %d ...\n",a,myproc()->pid);
    800017a6:	00000097          	auipc	ra,0x0
    800017aa:	6ee080e7          	jalr	1774(ra) # 80001e94 <myproc>
    800017ae:	5910                	lw	a2,48(a0)
    800017b0:	85ca                	mv	a1,s2
    800017b2:	00008517          	auipc	a0,0x8
    800017b6:	b8650513          	addi	a0,a0,-1146 # 80009338 <digits+0x2f8>
    800017ba:	fffff097          	auipc	ra,0xfffff
    800017be:	dba080e7          	jalr	-582(ra) # 80000574 <printf>
  struct proc *p = myproc();
    800017c2:	00000097          	auipc	ra,0x0
    800017c6:	6d2080e7          	jalr	1746(ra) # 80001e94 <myproc>
    800017ca:	84aa                	mv	s1,a0
  int index = get_index_in_page_info_array(a, p->pages_swap_info.pages);
    800017cc:	18050593          	addi	a1,a0,384
    800017d0:	854a                	mv	a0,s2
    800017d2:	00001097          	auipc	ra,0x1
    800017d6:	19a080e7          	jalr	410(ra) # 8000296c <get_index_in_page_info_array>
  if (index < 0 || index >= MAX_PSYC_PAGES)
    800017da:	0005071b          	sext.w	a4,a0
    800017de:	47bd                	li	a5,15
    800017e0:	02e7ec63          	bltu	a5,a4,80001818 <remove_page_from_swap_file+0x80>
    return -1; // page is not in phisical mem
  // panic("remove_page_from_physical_memory: not found page to free ");
  if (!(p->pages_swap_info.free_spaces & (1 << index)))
    800017e4:	1784d783          	lhu	a5,376(s1)
    800017e8:	40a7d73b          	sraw	a4,a5,a0
    800017ec:	8b05                	andi	a4,a4,1
    800017ee:	cf09                	beqz	a4,80001808 <remove_page_from_swap_file+0x70>
    panic("remove_page_from_swap_file: free space flag should be set but is unset");
  p->pages_swap_info.free_spaces ^= (1 << index);
    800017f0:	4705                	li	a4,1
    800017f2:	00a7173b          	sllw	a4,a4,a0
    800017f6:	8fb9                	xor	a5,a5,a4
    800017f8:	16f49c23          	sh	a5,376(s1)

  return index;
    800017fc:	60e2                	ld	ra,24(sp)
    800017fe:	6442                	ld	s0,16(sp)
    80001800:	64a2                	ld	s1,8(sp)
    80001802:	6902                	ld	s2,0(sp)
    80001804:	6105                	addi	sp,sp,32
    80001806:	8082                	ret
    panic("remove_page_from_swap_file: free space flag should be set but is unset");
    80001808:	00008517          	auipc	a0,0x8
    8000180c:	b6850513          	addi	a0,a0,-1176 # 80009370 <digits+0x330>
    80001810:	fffff097          	auipc	ra,0xfffff
    80001814:	d1a080e7          	jalr	-742(ra) # 8000052a <panic>
    return -1; // page is not in phisical mem
    80001818:	557d                	li	a0,-1
    8000181a:	b7cd                	j	800017fc <remove_page_from_swap_file+0x64>

000000008000181c <uvmunmap>:
{
    8000181c:	711d                	addi	sp,sp,-96
    8000181e:	ec86                	sd	ra,88(sp)
    80001820:	e8a2                	sd	s0,80(sp)
    80001822:	e4a6                	sd	s1,72(sp)
    80001824:	e0ca                	sd	s2,64(sp)
    80001826:	fc4e                	sd	s3,56(sp)
    80001828:	f852                	sd	s4,48(sp)
    8000182a:	f456                	sd	s5,40(sp)
    8000182c:	f05a                	sd	s6,32(sp)
    8000182e:	ec5e                	sd	s7,24(sp)
    80001830:	e862                	sd	s8,16(sp)
    80001832:	e466                	sd	s9,8(sp)
    80001834:	1080                	addi	s0,sp,96
    80001836:	8aaa                	mv	s5,a0
    80001838:	892e                	mv	s2,a1
    8000183a:	8a32                	mv	s4,a2
    8000183c:	8c36                	mv	s8,a3
  printf("uvmunmap... va = %d dofree = %d\n", va,do_free); // TODO delete
    8000183e:	8636                	mv	a2,a3
    80001840:	00008517          	auipc	a0,0x8
    80001844:	b7850513          	addi	a0,a0,-1160 # 800093b8 <digits+0x378>
    80001848:	fffff097          	auipc	ra,0xfffff
    8000184c:	d2c080e7          	jalr	-724(ra) # 80000574 <printf>
  struct proc *p = myproc();
    80001850:	00000097          	auipc	ra,0x0
    80001854:	644080e7          	jalr	1604(ra) # 80001e94 <myproc>
  if ((va % PGSIZE) != 0)
    80001858:	03491793          	slli	a5,s2,0x34
    8000185c:	eb91                	bnez	a5,80001870 <uvmunmap+0x54>
    8000185e:	89aa                	mv	s3,a0
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80001860:	0a32                	slli	s4,s4,0xc
    80001862:	9a4a                	add	s4,s4,s2
    80001864:	13497163          	bgeu	s2,s4,80001986 <uvmunmap+0x16a>
    if (PTE_FLAGS(*pte) == PTE_V)
    80001868:	4c85                	li	s9,1
      if (myproc()->pid > 2)
    8000186a:	4b89                	li	s7,2
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    8000186c:	6b05                	lui	s6,0x1
    8000186e:	a0a1                	j	800018b6 <uvmunmap+0x9a>
    panic("uvmunmap: not aligned");
    80001870:	00008517          	auipc	a0,0x8
    80001874:	b7050513          	addi	a0,a0,-1168 # 800093e0 <digits+0x3a0>
    80001878:	fffff097          	auipc	ra,0xfffff
    8000187c:	cb2080e7          	jalr	-846(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    80001880:	00008517          	auipc	a0,0x8
    80001884:	b7850513          	addi	a0,a0,-1160 # 800093f8 <digits+0x3b8>
    80001888:	fffff097          	auipc	ra,0xfffff
    8000188c:	ca2080e7          	jalr	-862(ra) # 8000052a <panic>
        panic("uvmunmap: not mapped");
    80001890:	00008517          	auipc	a0,0x8
    80001894:	b7850513          	addi	a0,a0,-1160 # 80009408 <digits+0x3c8>
    80001898:	fffff097          	auipc	ra,0xfffff
    8000189c:	c92080e7          	jalr	-878(ra) # 8000052a <panic>
    if (PTE_FLAGS(*pte) == PTE_V)
    800018a0:	3ff7f713          	andi	a4,a5,1023
    800018a4:	05970a63          	beq	a4,s9,800018f8 <uvmunmap+0xdc>
    if (do_free)
    800018a8:	060c1063          	bnez	s8,80001908 <uvmunmap+0xec>
    *pte = 0;
    800018ac:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    800018b0:	995a                	add	s2,s2,s6
    800018b2:	0d497a63          	bgeu	s2,s4,80001986 <uvmunmap+0x16a>
    if ((pte = walk(pagetable, a, 0)) == 0)
    800018b6:	4601                	li	a2,0
    800018b8:	85ca                	mv	a1,s2
    800018ba:	8556                	mv	a0,s5
    800018bc:	fffff097          	auipc	ra,0xfffff
    800018c0:	6ea080e7          	jalr	1770(ra) # 80000fa6 <walk>
    800018c4:	84aa                	mv	s1,a0
    800018c6:	dd4d                	beqz	a0,80001880 <uvmunmap+0x64>
    if ((*pte & PTE_V) == 0){
    800018c8:	611c                	ld	a5,0(a0)
    800018ca:	0017f713          	andi	a4,a5,1
    800018ce:	fb69                	bnez	a4,800018a0 <uvmunmap+0x84>
      if((*pte & PTE_PG) && p->pid>2){  // page is swapped out
    800018d0:	2007f793          	andi	a5,a5,512
    800018d4:	dfd5                	beqz	a5,80001890 <uvmunmap+0x74>
    800018d6:	0309a783          	lw	a5,48(s3) # 1030 <_entry-0x7fffefd0>
    800018da:	fafbdbe3          	bge	s7,a5,80001890 <uvmunmap+0x74>
        remove_page_from_swap_file(a);
    800018de:	854a                	mv	a0,s2
    800018e0:	00000097          	auipc	ra,0x0
    800018e4:	eb8080e7          	jalr	-328(ra) # 80001798 <remove_page_from_swap_file>
        *pte = 0;
    800018e8:	0004b023          	sd	zero,0(s1)
        p->total_pages_num--;
    800018ec:	1749a783          	lw	a5,372(s3)
    800018f0:	37fd                	addiw	a5,a5,-1
    800018f2:	16f9aa23          	sw	a5,372(s3)
        continue;
    800018f6:	bf6d                	j	800018b0 <uvmunmap+0x94>
      panic("uvmunmap: not a leaf");
    800018f8:	00008517          	auipc	a0,0x8
    800018fc:	b2850513          	addi	a0,a0,-1240 # 80009420 <digits+0x3e0>
    80001900:	fffff097          	auipc	ra,0xfffff
    80001904:	c2a080e7          	jalr	-982(ra) # 8000052a <panic>
      uint64 pa = PTE2PA(*pte);
    80001908:	00a7d513          	srli	a0,a5,0xa
      kfree((void *)pa);
    8000190c:	0532                	slli	a0,a0,0xc
    8000190e:	fffff097          	auipc	ra,0xfffff
    80001912:	0c8080e7          	jalr	200(ra) # 800009d6 <kfree>
      if (myproc()->pid > 2)
    80001916:	00000097          	auipc	ra,0x0
    8000191a:	57e080e7          	jalr	1406(ra) # 80001e94 <myproc>
    8000191e:	591c                	lw	a5,48(a0)
    80001920:	f8fbd6e3          	bge	s7,a5,800018ac <uvmunmap+0x90>
        if (remove_page_from_physical_memory(a) >= 0)
    80001924:	854a                	mv	a0,s2
    80001926:	00000097          	auipc	ra,0x0
    8000192a:	dee080e7          	jalr	-530(ra) # 80001714 <remove_page_from_physical_memory>
    8000192e:	02054563          	bltz	a0,80001958 <uvmunmap+0x13c>
          myproc()->physical_pages_num--;
    80001932:	00000097          	auipc	ra,0x0
    80001936:	562080e7          	jalr	1378(ra) # 80001e94 <myproc>
    8000193a:	17052783          	lw	a5,368(a0)
    8000193e:	37fd                	addiw	a5,a5,-1
    80001940:	16f52823          	sw	a5,368(a0)
          myproc()->total_pages_num--;
    80001944:	00000097          	auipc	ra,0x0
    80001948:	550080e7          	jalr	1360(ra) # 80001e94 <myproc>
    8000194c:	17452783          	lw	a5,372(a0)
    80001950:	37fd                	addiw	a5,a5,-1
    80001952:	16f52a23          	sw	a5,372(a0)
    80001956:	bf99                	j	800018ac <uvmunmap+0x90>
          printf("not found va = %p,pid=%d\n", a,p->pid);
    80001958:	0309a603          	lw	a2,48(s3)
    8000195c:	85ca                	mv	a1,s2
    8000195e:	00008517          	auipc	a0,0x8
    80001962:	ada50513          	addi	a0,a0,-1318 # 80009438 <digits+0x3f8>
    80001966:	fffff097          	auipc	ra,0xfffff
    8000196a:	c0e080e7          	jalr	-1010(ra) # 80000574 <printf>
          print_pages_from_info_arrs();
    8000196e:	00001097          	auipc	ra,0x1
    80001972:	658080e7          	jalr	1624(ra) # 80002fc6 <print_pages_from_info_arrs>
          panic("uvmunmap: page not found in physical mem or swapfile");
    80001976:	00008517          	auipc	a0,0x8
    8000197a:	ae250513          	addi	a0,a0,-1310 # 80009458 <digits+0x418>
    8000197e:	fffff097          	auipc	ra,0xfffff
    80001982:	bac080e7          	jalr	-1108(ra) # 8000052a <panic>
}
    80001986:	60e6                	ld	ra,88(sp)
    80001988:	6446                	ld	s0,80(sp)
    8000198a:	64a6                	ld	s1,72(sp)
    8000198c:	6906                	ld	s2,64(sp)
    8000198e:	79e2                	ld	s3,56(sp)
    80001990:	7a42                	ld	s4,48(sp)
    80001992:	7aa2                	ld	s5,40(sp)
    80001994:	7b02                	ld	s6,32(sp)
    80001996:	6be2                	ld	s7,24(sp)
    80001998:	6c42                	ld	s8,16(sp)
    8000199a:	6ca2                	ld	s9,8(sp)
    8000199c:	6125                	addi	sp,sp,96
    8000199e:	8082                	ret

00000000800019a0 <uvmdealloc>:
{
    800019a0:	7179                	addi	sp,sp,-48
    800019a2:	f406                	sd	ra,40(sp)
    800019a4:	f022                	sd	s0,32(sp)
    800019a6:	ec26                	sd	s1,24(sp)
    800019a8:	e84a                	sd	s2,16(sp)
    800019aa:	e44e                	sd	s3,8(sp)
    800019ac:	1800                	addi	s0,sp,48
    800019ae:	89aa                	mv	s3,a0
    800019b0:	84ae                	mv	s1,a1
    800019b2:	8932                	mv	s2,a2
  printf("uvmdealloc...\n"); // TODO delete
    800019b4:	00008517          	auipc	a0,0x8
    800019b8:	adc50513          	addi	a0,a0,-1316 # 80009490 <digits+0x450>
    800019bc:	fffff097          	auipc	ra,0xfffff
    800019c0:	bb8080e7          	jalr	-1096(ra) # 80000574 <printf>
  if (newsz >= oldsz)
    800019c4:	02997f63          	bgeu	s2,s1,80001a02 <uvmdealloc+0x62>
  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    800019c8:	6785                	lui	a5,0x1
    800019ca:	17fd                	addi	a5,a5,-1
    800019cc:	00f905b3          	add	a1,s2,a5
    800019d0:	767d                	lui	a2,0xfffff
    800019d2:	8df1                	and	a1,a1,a2
    800019d4:	94be                	add	s1,s1,a5
    800019d6:	8cf1                	and	s1,s1,a2
    800019d8:	0095ea63          	bltu	a1,s1,800019ec <uvmdealloc+0x4c>
}
    800019dc:	854a                	mv	a0,s2
    800019de:	70a2                	ld	ra,40(sp)
    800019e0:	7402                	ld	s0,32(sp)
    800019e2:	64e2                	ld	s1,24(sp)
    800019e4:	6942                	ld	s2,16(sp)
    800019e6:	69a2                	ld	s3,8(sp)
    800019e8:	6145                	addi	sp,sp,48
    800019ea:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800019ec:	8c8d                	sub	s1,s1,a1
    800019ee:	80b1                	srli	s1,s1,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800019f0:	4685                	li	a3,1
    800019f2:	0004861b          	sext.w	a2,s1
    800019f6:	854e                	mv	a0,s3
    800019f8:	00000097          	auipc	ra,0x0
    800019fc:	e24080e7          	jalr	-476(ra) # 8000181c <uvmunmap>
    80001a00:	bff1                	j	800019dc <uvmdealloc+0x3c>
    return oldsz;
    80001a02:	8926                	mv	s2,s1
    80001a04:	bfe1                	j	800019dc <uvmdealloc+0x3c>

0000000080001a06 <uvmalloc>:
{
    80001a06:	7159                	addi	sp,sp,-112
    80001a08:	f486                	sd	ra,104(sp)
    80001a0a:	f0a2                	sd	s0,96(sp)
    80001a0c:	eca6                	sd	s1,88(sp)
    80001a0e:	e8ca                	sd	s2,80(sp)
    80001a10:	e4ce                	sd	s3,72(sp)
    80001a12:	e0d2                	sd	s4,64(sp)
    80001a14:	fc56                	sd	s5,56(sp)
    80001a16:	f85a                	sd	s6,48(sp)
    80001a18:	f45e                	sd	s7,40(sp)
    80001a1a:	f062                	sd	s8,32(sp)
    80001a1c:	ec66                	sd	s9,24(sp)
    80001a1e:	e86a                	sd	s10,16(sp)
    80001a20:	e46e                	sd	s11,8(sp)
    80001a22:	1880                	addi	s0,sp,112
    80001a24:	8caa                	mv	s9,a0
    80001a26:	84ae                	mv	s1,a1
    80001a28:	8c32                	mv	s8,a2
  printf("uvmalloc...oldsize = %d newsize = %d\n", oldsz, newsz);
    80001a2a:	00008517          	auipc	a0,0x8
    80001a2e:	a7650513          	addi	a0,a0,-1418 # 800094a0 <digits+0x460>
    80001a32:	fffff097          	auipc	ra,0xfffff
    80001a36:	b42080e7          	jalr	-1214(ra) # 80000574 <printf>
  struct proc *p = myproc();
    80001a3a:	00000097          	auipc	ra,0x0
    80001a3e:	45a080e7          	jalr	1114(ra) # 80001e94 <myproc>
  if (newsz < oldsz)
    80001a42:	149c6863          	bltu	s8,s1,80001b92 <uvmalloc+0x18c>
    80001a46:	892a                	mv	s2,a0
  oldsz = PGROUNDUP(oldsz);
    80001a48:	6d05                	lui	s10,0x1
    80001a4a:	1d7d                	addi	s10,s10,-1
    80001a4c:	94ea                	add	s1,s1,s10
    80001a4e:	7d7d                	lui	s10,0xfffff
    80001a50:	01a4fd33          	and	s10,s1,s10
  for (a = oldsz; a < newsz; a += PGSIZE)
    80001a54:	158d7f63          	bgeu	s10,s8,80001bb2 <uvmalloc+0x1ac>
    80001a58:	8b6a                	mv	s6,s10
    if (p->pid > 2)
    80001a5a:	4b89                	li	s7,2
      if (p->total_pages_num >= MAX_TOTAL_PAGES)
    80001a5c:	4dfd                	li	s11,31
      while (p->physical_pages_num >= MAX_PSYC_PAGES)
    80001a5e:	49bd                	li	s3,15
        printf("inside while loop for page out in uvmalloc");
    80001a60:	00008a17          	auipc	s4,0x8
    80001a64:	a88a0a13          	addi	s4,s4,-1400 # 800094e8 <digits+0x4a8>
        printf("about to call page_out from uvmalloc with rva = %p, index in arry = %d\n", rva, i);
    80001a68:	00008a97          	auipc	s5,0x8
    80001a6c:	b00a8a93          	addi	s5,s5,-1280 # 80009568 <digits+0x528>
    80001a70:	a88d                	j	80001ae2 <uvmalloc+0xdc>
        panic("uvmalloc: proc out of space!");
    80001a72:	00008517          	auipc	a0,0x8
    80001a76:	a5650513          	addi	a0,a0,-1450 # 800094c8 <digits+0x488>
    80001a7a:	fffff097          	auipc	ra,0xfffff
    80001a7e:	ab0080e7          	jalr	-1360(ra) # 8000052a <panic>
          printf("panic recieved for pid=%d\n",p->pid);
    80001a82:	03092583          	lw	a1,48(s2)
    80001a86:	00008517          	auipc	a0,0x8
    80001a8a:	a9250513          	addi	a0,a0,-1390 # 80009518 <digits+0x4d8>
    80001a8e:	fffff097          	auipc	ra,0xfffff
    80001a92:	ae6080e7          	jalr	-1306(ra) # 80000574 <printf>
          panic("uvmalloc: did not find the page to swap out!");
    80001a96:	00008517          	auipc	a0,0x8
    80001a9a:	aa250513          	addi	a0,a0,-1374 # 80009538 <digits+0x4f8>
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	a8c080e7          	jalr	-1396(ra) # 8000052a <panic>
    mem = kalloc();
    80001aa6:	fffff097          	auipc	ra,0xfffff
    80001aaa:	02c080e7          	jalr	44(ra) # 80000ad2 <kalloc>
    80001aae:	84aa                	mv	s1,a0
    if (mem == 0)
    80001ab0:	c941                	beqz	a0,80001b40 <uvmalloc+0x13a>
    memset(mem, 0, PGSIZE);
    80001ab2:	6605                	lui	a2,0x1
    80001ab4:	4581                	li	a1,0
    80001ab6:	fffff097          	auipc	ra,0xfffff
    80001aba:	208080e7          	jalr	520(ra) # 80000cbe <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W | PTE_X | PTE_R | PTE_U) != 0)
    80001abe:	4779                	li	a4,30
    80001ac0:	86a6                	mv	a3,s1
    80001ac2:	6605                	lui	a2,0x1
    80001ac4:	85da                	mv	a1,s6
    80001ac6:	8566                	mv	a0,s9
    80001ac8:	fffff097          	auipc	ra,0xfffff
    80001acc:	5dc080e7          	jalr	1500(ra) # 800010a4 <mappages>
    80001ad0:	e149                	bnez	a0,80001b52 <uvmalloc+0x14c>
    if (p->pid > 2)
    80001ad2:	03092783          	lw	a5,48(s2)
    80001ad6:	08fbcc63          	blt	s7,a5,80001b6e <uvmalloc+0x168>
  for (a = oldsz; a < newsz; a += PGSIZE)
    80001ada:	6785                	lui	a5,0x1
    80001adc:	9b3e                	add	s6,s6,a5
    80001ade:	0b8b7863          	bgeu	s6,s8,80001b8e <uvmalloc+0x188>
    if (p->pid > 2)
    80001ae2:	03092783          	lw	a5,48(s2)
    80001ae6:	fcfbd0e3          	bge	s7,a5,80001aa6 <uvmalloc+0xa0>
      if (p->total_pages_num >= MAX_TOTAL_PAGES)
    80001aea:	17492783          	lw	a5,372(s2)
    80001aee:	f8fdc2e3          	blt	s11,a5,80001a72 <uvmalloc+0x6c>
      while (p->physical_pages_num >= MAX_PSYC_PAGES)
    80001af2:	17092783          	lw	a5,368(s2)
    80001af6:	faf9d8e3          	bge	s3,a5,80001aa6 <uvmalloc+0xa0>
        printf("inside while loop for page out in uvmalloc");
    80001afa:	8552                	mv	a0,s4
    80001afc:	fffff097          	auipc	ra,0xfffff
    80001b00:	a78080e7          	jalr	-1416(ra) # 80000574 <printf>
        int i = get_next_page_to_swap_out();
    80001b04:	00001097          	auipc	ra,0x1
    80001b08:	412080e7          	jalr	1042(ra) # 80002f16 <get_next_page_to_swap_out>
    80001b0c:	862a                	mv	a2,a0
        if (i < 0 || i >= MAX_PSYC_PAGES){
    80001b0e:	0005079b          	sext.w	a5,a0
    80001b12:	f6f9e8e3          	bltu	s3,a5,80001a82 <uvmalloc+0x7c>
        uint64 rva = p->pages_physc_info.pages[i].va;
    80001b16:	02850793          	addi	a5,a0,40
    80001b1a:	0792                	slli	a5,a5,0x4
    80001b1c:	97ca                	add	a5,a5,s2
    80001b1e:	6784                	ld	s1,8(a5)
        printf("about to call page_out from uvmalloc with rva = %p, index in arry = %d\n", rva, i);
    80001b20:	85a6                	mv	a1,s1
    80001b22:	8556                	mv	a0,s5
    80001b24:	fffff097          	auipc	ra,0xfffff
    80001b28:	a50080e7          	jalr	-1456(ra) # 80000574 <printf>
        page_out(rva);
    80001b2c:	8526                	mv	a0,s1
    80001b2e:	00001097          	auipc	ra,0x1
    80001b32:	e8e080e7          	jalr	-370(ra) # 800029bc <page_out>
      while (p->physical_pages_num >= MAX_PSYC_PAGES)
    80001b36:	17092783          	lw	a5,368(s2)
    80001b3a:	fcf9c0e3          	blt	s3,a5,80001afa <uvmalloc+0xf4>
    80001b3e:	b7a5                	j	80001aa6 <uvmalloc+0xa0>
      uvmdealloc(pagetable, a, oldsz);
    80001b40:	866a                	mv	a2,s10
    80001b42:	85da                	mv	a1,s6
    80001b44:	8566                	mv	a0,s9
    80001b46:	00000097          	auipc	ra,0x0
    80001b4a:	e5a080e7          	jalr	-422(ra) # 800019a0 <uvmdealloc>
      return 0;
    80001b4e:	4501                	li	a0,0
    80001b50:	a091                	j	80001b94 <uvmalloc+0x18e>
      kfree(mem);
    80001b52:	8526                	mv	a0,s1
    80001b54:	fffff097          	auipc	ra,0xfffff
    80001b58:	e82080e7          	jalr	-382(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001b5c:	866a                	mv	a2,s10
    80001b5e:	85da                	mv	a1,s6
    80001b60:	8566                	mv	a0,s9
    80001b62:	00000097          	auipc	ra,0x0
    80001b66:	e3e080e7          	jalr	-450(ra) # 800019a0 <uvmdealloc>
      return 0;
    80001b6a:	4501                	li	a0,0
    80001b6c:	a025                	j	80001b94 <uvmalloc+0x18e>
      insert_page_to_physical_memory(a);
    80001b6e:	855a                	mv	a0,s6
    80001b70:	00000097          	auipc	ra,0x0
    80001b74:	ae8080e7          	jalr	-1304(ra) # 80001658 <insert_page_to_physical_memory>
      p->total_pages_num++;
    80001b78:	17492783          	lw	a5,372(s2)
    80001b7c:	2785                	addiw	a5,a5,1
    80001b7e:	16f92a23          	sw	a5,372(s2)
      p->physical_pages_num++;
    80001b82:	17092783          	lw	a5,368(s2)
    80001b86:	2785                	addiw	a5,a5,1
    80001b88:	16f92823          	sw	a5,368(s2)
    80001b8c:	b7b9                	j	80001ada <uvmalloc+0xd4>
  return newsz;
    80001b8e:	8562                	mv	a0,s8
    80001b90:	a011                	j	80001b94 <uvmalloc+0x18e>
    return oldsz;
    80001b92:	8526                	mv	a0,s1
}
    80001b94:	70a6                	ld	ra,104(sp)
    80001b96:	7406                	ld	s0,96(sp)
    80001b98:	64e6                	ld	s1,88(sp)
    80001b9a:	6946                	ld	s2,80(sp)
    80001b9c:	69a6                	ld	s3,72(sp)
    80001b9e:	6a06                	ld	s4,64(sp)
    80001ba0:	7ae2                	ld	s5,56(sp)
    80001ba2:	7b42                	ld	s6,48(sp)
    80001ba4:	7ba2                	ld	s7,40(sp)
    80001ba6:	7c02                	ld	s8,32(sp)
    80001ba8:	6ce2                	ld	s9,24(sp)
    80001baa:	6d42                	ld	s10,16(sp)
    80001bac:	6da2                	ld	s11,8(sp)
    80001bae:	6165                	addi	sp,sp,112
    80001bb0:	8082                	ret
  return newsz;
    80001bb2:	8562                	mv	a0,s8
    80001bb4:	b7c5                	j	80001b94 <uvmalloc+0x18e>

0000000080001bb6 <uvmfree>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
    80001bc2:	892a                	mv	s2,a0
    80001bc4:	84ae                	mv	s1,a1
  printf("uvmfree...pid = %d\n",myproc()->pid); // TODO delete
    80001bc6:	00000097          	auipc	ra,0x0
    80001bca:	2ce080e7          	jalr	718(ra) # 80001e94 <myproc>
    80001bce:	590c                	lw	a1,48(a0)
    80001bd0:	00008517          	auipc	a0,0x8
    80001bd4:	9e050513          	addi	a0,a0,-1568 # 800095b0 <digits+0x570>
    80001bd8:	fffff097          	auipc	ra,0xfffff
    80001bdc:	99c080e7          	jalr	-1636(ra) # 80000574 <printf>
  if (sz > 0)
    80001be0:	ec81                	bnez	s1,80001bf8 <uvmfree+0x42>
  freewalk(pagetable);
    80001be2:	854a                	mv	a0,s2
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	714080e7          	jalr	1812(ra) # 800012f8 <freewalk>
}
    80001bec:	60e2                	ld	ra,24(sp)
    80001bee:	6442                	ld	s0,16(sp)
    80001bf0:	64a2                	ld	s1,8(sp)
    80001bf2:	6902                	ld	s2,0(sp)
    80001bf4:	6105                	addi	sp,sp,32
    80001bf6:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001bf8:	6605                	lui	a2,0x1
    80001bfa:	167d                	addi	a2,a2,-1
    80001bfc:	9626                	add	a2,a2,s1
    80001bfe:	4685                	li	a3,1
    80001c00:	8231                	srli	a2,a2,0xc
    80001c02:	4581                	li	a1,0
    80001c04:	854a                	mv	a0,s2
    80001c06:	00000097          	auipc	ra,0x0
    80001c0a:	c16080e7          	jalr	-1002(ra) # 8000181c <uvmunmap>
    80001c0e:	bfd1                	j	80001be2 <uvmfree+0x2c>

0000000080001c10 <uvmcopy>:
{
    80001c10:	715d                	addi	sp,sp,-80
    80001c12:	e486                	sd	ra,72(sp)
    80001c14:	e0a2                	sd	s0,64(sp)
    80001c16:	fc26                	sd	s1,56(sp)
    80001c18:	f84a                	sd	s2,48(sp)
    80001c1a:	f44e                	sd	s3,40(sp)
    80001c1c:	f052                	sd	s4,32(sp)
    80001c1e:	ec56                	sd	s5,24(sp)
    80001c20:	e85a                	sd	s6,16(sp)
    80001c22:	e45e                	sd	s7,8(sp)
    80001c24:	0880                	addi	s0,sp,80
    80001c26:	8b2a                	mv	s6,a0
    80001c28:	8aae                	mv	s5,a1
    80001c2a:	8a32                	mv	s4,a2
  printf("uvmcopy...,pid = %d\n",myproc()->pid);
    80001c2c:	00000097          	auipc	ra,0x0
    80001c30:	268080e7          	jalr	616(ra) # 80001e94 <myproc>
    80001c34:	590c                	lw	a1,48(a0)
    80001c36:	00008517          	auipc	a0,0x8
    80001c3a:	99250513          	addi	a0,a0,-1646 # 800095c8 <digits+0x588>
    80001c3e:	fffff097          	auipc	ra,0xfffff
    80001c42:	936080e7          	jalr	-1738(ra) # 80000574 <printf>
  for (i = 0; i < sz; i += PGSIZE)
    80001c46:	0a0a0a63          	beqz	s4,80001cfa <uvmcopy+0xea>
    80001c4a:	4981                	li	s3,0
    if ((pte = walk(old, i, 0)) == 0)
    80001c4c:	4601                	li	a2,0
    80001c4e:	85ce                	mv	a1,s3
    80001c50:	855a                	mv	a0,s6
    80001c52:	fffff097          	auipc	ra,0xfffff
    80001c56:	354080e7          	jalr	852(ra) # 80000fa6 <walk>
    80001c5a:	c531                	beqz	a0,80001ca6 <uvmcopy+0x96>
    if ((*pte & PTE_V) == 0)
    80001c5c:	6118                	ld	a4,0(a0)
    80001c5e:	00177793          	andi	a5,a4,1
    80001c62:	cbb1                	beqz	a5,80001cb6 <uvmcopy+0xa6>
    pa = PTE2PA(*pte);
    80001c64:	00a75593          	srli	a1,a4,0xa
    80001c68:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001c6c:	3ff77493          	andi	s1,a4,1023
    if ((mem = kalloc()) == 0)
    80001c70:	fffff097          	auipc	ra,0xfffff
    80001c74:	e62080e7          	jalr	-414(ra) # 80000ad2 <kalloc>
    80001c78:	892a                	mv	s2,a0
    80001c7a:	c939                	beqz	a0,80001cd0 <uvmcopy+0xc0>
    memmove(mem, (char *)pa, PGSIZE);
    80001c7c:	6605                	lui	a2,0x1
    80001c7e:	85de                	mv	a1,s7
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	09a080e7          	jalr	154(ra) # 80000d1a <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    80001c88:	8726                	mv	a4,s1
    80001c8a:	86ca                	mv	a3,s2
    80001c8c:	6605                	lui	a2,0x1
    80001c8e:	85ce                	mv	a1,s3
    80001c90:	8556                	mv	a0,s5
    80001c92:	fffff097          	auipc	ra,0xfffff
    80001c96:	412080e7          	jalr	1042(ra) # 800010a4 <mappages>
    80001c9a:	e515                	bnez	a0,80001cc6 <uvmcopy+0xb6>
  for (i = 0; i < sz; i += PGSIZE)
    80001c9c:	6785                	lui	a5,0x1
    80001c9e:	99be                	add	s3,s3,a5
    80001ca0:	fb49e6e3          	bltu	s3,s4,80001c4c <uvmcopy+0x3c>
    80001ca4:	a081                	j	80001ce4 <uvmcopy+0xd4>
      panic("uvmcopy: pte should exist");
    80001ca6:	00008517          	auipc	a0,0x8
    80001caa:	93a50513          	addi	a0,a0,-1734 # 800095e0 <digits+0x5a0>
    80001cae:	fffff097          	auipc	ra,0xfffff
    80001cb2:	87c080e7          	jalr	-1924(ra) # 8000052a <panic>
      panic("uvmcopy: page not present");
    80001cb6:	00008517          	auipc	a0,0x8
    80001cba:	94a50513          	addi	a0,a0,-1718 # 80009600 <digits+0x5c0>
    80001cbe:	fffff097          	auipc	ra,0xfffff
    80001cc2:	86c080e7          	jalr	-1940(ra) # 8000052a <panic>
      kfree(mem);
    80001cc6:	854a                	mv	a0,s2
    80001cc8:	fffff097          	auipc	ra,0xfffff
    80001ccc:	d0e080e7          	jalr	-754(ra) # 800009d6 <kfree>
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001cd0:	4685                	li	a3,1
    80001cd2:	00c9d613          	srli	a2,s3,0xc
    80001cd6:	4581                	li	a1,0
    80001cd8:	8556                	mv	a0,s5
    80001cda:	00000097          	auipc	ra,0x0
    80001cde:	b42080e7          	jalr	-1214(ra) # 8000181c <uvmunmap>
  return -1;
    80001ce2:	557d                	li	a0,-1
}
    80001ce4:	60a6                	ld	ra,72(sp)
    80001ce6:	6406                	ld	s0,64(sp)
    80001ce8:	74e2                	ld	s1,56(sp)
    80001cea:	7942                	ld	s2,48(sp)
    80001cec:	79a2                	ld	s3,40(sp)
    80001cee:	7a02                	ld	s4,32(sp)
    80001cf0:	6ae2                	ld	s5,24(sp)
    80001cf2:	6b42                	ld	s6,16(sp)
    80001cf4:	6ba2                	ld	s7,8(sp)
    80001cf6:	6161                	addi	sp,sp,80
    80001cf8:	8082                	ret
  return 0;
    80001cfa:	4501                	li	a0,0
    80001cfc:	b7e5                	j	80001ce4 <uvmcopy+0xd4>

0000000080001cfe <SCFIFO_compare>:
  return res;
}

int SCFIFO_compare(struct page_info *pg1, struct page_info *pg2)
{
  if (!pg1 || !pg2)
    80001cfe:	c511                	beqz	a0,80001d0a <SCFIFO_compare+0xc>
    80001d00:	c589                	beqz	a1,80001d0a <SCFIFO_compare+0xc>
    panic("SCFIFO_compare : null input");

  return pg1->time_inserted - pg2->time_inserted;
    80001d02:	4548                	lw	a0,12(a0)
    80001d04:	45dc                	lw	a5,12(a1)
}
    80001d06:	9d1d                	subw	a0,a0,a5
    80001d08:	8082                	ret
{
    80001d0a:	1141                	addi	sp,sp,-16
    80001d0c:	e406                	sd	ra,8(sp)
    80001d0e:	e022                	sd	s0,0(sp)
    80001d10:	0800                	addi	s0,sp,16
    panic("SCFIFO_compare : null input");
    80001d12:	00008517          	auipc	a0,0x8
    80001d16:	90e50513          	addi	a0,a0,-1778 # 80009620 <digits+0x5e0>
    80001d1a:	fffff097          	auipc	ra,0xfffff
    80001d1e:	810080e7          	jalr	-2032(ra) # 8000052a <panic>

0000000080001d22 <proc_mapstacks>:
{
    80001d22:	7139                	addi	sp,sp,-64
    80001d24:	fc06                	sd	ra,56(sp)
    80001d26:	f822                	sd	s0,48(sp)
    80001d28:	f426                	sd	s1,40(sp)
    80001d2a:	f04a                	sd	s2,32(sp)
    80001d2c:	ec4e                	sd	s3,24(sp)
    80001d2e:	e852                	sd	s4,16(sp)
    80001d30:	e456                	sd	s5,8(sp)
    80001d32:	e05a                	sd	s6,0(sp)
    80001d34:	0080                	addi	s0,sp,64
    80001d36:	89aa                	mv	s3,a0
  for (p = proc; p < &proc[NPROC]; p++)
    80001d38:	00012497          	auipc	s1,0x12
    80001d3c:	99848493          	addi	s1,s1,-1640 # 800136d0 <proc>
    uint64 va = KSTACK((int)(p - proc));
    80001d40:	8b26                	mv	s6,s1
    80001d42:	00007a97          	auipc	s5,0x7
    80001d46:	2bea8a93          	addi	s5,s5,702 # 80009000 <etext>
    80001d4a:	04000937          	lui	s2,0x4000
    80001d4e:	197d                	addi	s2,s2,-1
    80001d50:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001d52:	00020a17          	auipc	s4,0x20
    80001d56:	b7ea0a13          	addi	s4,s4,-1154 # 800218d0 <tickslock>
    char *pa = kalloc();
    80001d5a:	fffff097          	auipc	ra,0xfffff
    80001d5e:	d78080e7          	jalr	-648(ra) # 80000ad2 <kalloc>
    80001d62:	862a                	mv	a2,a0
    if (pa == 0)
    80001d64:	c131                	beqz	a0,80001da8 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001d66:	416485b3          	sub	a1,s1,s6
    80001d6a:	858d                	srai	a1,a1,0x3
    80001d6c:	000ab783          	ld	a5,0(s5)
    80001d70:	02f585b3          	mul	a1,a1,a5
    80001d74:	2585                	addiw	a1,a1,1
    80001d76:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001d7a:	4719                	li	a4,6
    80001d7c:	6685                	lui	a3,0x1
    80001d7e:	40b905b3          	sub	a1,s2,a1
    80001d82:	854e                	mv	a0,s3
    80001d84:	fffff097          	auipc	ra,0xfffff
    80001d88:	3ae080e7          	jalr	942(ra) # 80001132 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001d8c:	38848493          	addi	s1,s1,904
    80001d90:	fd4495e3          	bne	s1,s4,80001d5a <proc_mapstacks+0x38>
}
    80001d94:	70e2                	ld	ra,56(sp)
    80001d96:	7442                	ld	s0,48(sp)
    80001d98:	74a2                	ld	s1,40(sp)
    80001d9a:	7902                	ld	s2,32(sp)
    80001d9c:	69e2                	ld	s3,24(sp)
    80001d9e:	6a42                	ld	s4,16(sp)
    80001da0:	6aa2                	ld	s5,8(sp)
    80001da2:	6b02                	ld	s6,0(sp)
    80001da4:	6121                	addi	sp,sp,64
    80001da6:	8082                	ret
      panic("kalloc");
    80001da8:	00008517          	auipc	a0,0x8
    80001dac:	89850513          	addi	a0,a0,-1896 # 80009640 <digits+0x600>
    80001db0:	ffffe097          	auipc	ra,0xffffe
    80001db4:	77a080e7          	jalr	1914(ra) # 8000052a <panic>

0000000080001db8 <procinit>:
{
    80001db8:	7139                	addi	sp,sp,-64
    80001dba:	fc06                	sd	ra,56(sp)
    80001dbc:	f822                	sd	s0,48(sp)
    80001dbe:	f426                	sd	s1,40(sp)
    80001dc0:	f04a                	sd	s2,32(sp)
    80001dc2:	ec4e                	sd	s3,24(sp)
    80001dc4:	e852                	sd	s4,16(sp)
    80001dc6:	e456                	sd	s5,8(sp)
    80001dc8:	e05a                	sd	s6,0(sp)
    80001dca:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    80001dcc:	00008597          	auipc	a1,0x8
    80001dd0:	87c58593          	addi	a1,a1,-1924 # 80009648 <digits+0x608>
    80001dd4:	00011517          	auipc	a0,0x11
    80001dd8:	4cc50513          	addi	a0,a0,1228 # 800132a0 <pid_lock>
    80001ddc:	fffff097          	auipc	ra,0xfffff
    80001de0:	d56080e7          	jalr	-682(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001de4:	00008597          	auipc	a1,0x8
    80001de8:	86c58593          	addi	a1,a1,-1940 # 80009650 <digits+0x610>
    80001dec:	00011517          	auipc	a0,0x11
    80001df0:	4cc50513          	addi	a0,a0,1228 # 800132b8 <wait_lock>
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	d3e080e7          	jalr	-706(ra) # 80000b32 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001dfc:	00012497          	auipc	s1,0x12
    80001e00:	8d448493          	addi	s1,s1,-1836 # 800136d0 <proc>
    initlock(&p->lock, "proc");
    80001e04:	00008b17          	auipc	s6,0x8
    80001e08:	85cb0b13          	addi	s6,s6,-1956 # 80009660 <digits+0x620>
    p->kstack = KSTACK((int)(p - proc));
    80001e0c:	8aa6                	mv	s5,s1
    80001e0e:	00007a17          	auipc	s4,0x7
    80001e12:	1f2a0a13          	addi	s4,s4,498 # 80009000 <etext>
    80001e16:	04000937          	lui	s2,0x4000
    80001e1a:	197d                	addi	s2,s2,-1
    80001e1c:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001e1e:	00020997          	auipc	s3,0x20
    80001e22:	ab298993          	addi	s3,s3,-1358 # 800218d0 <tickslock>
    initlock(&p->lock, "proc");
    80001e26:	85da                	mv	a1,s6
    80001e28:	8526                	mv	a0,s1
    80001e2a:	fffff097          	auipc	ra,0xfffff
    80001e2e:	d08080e7          	jalr	-760(ra) # 80000b32 <initlock>
    p->kstack = KSTACK((int)(p - proc));
    80001e32:	415487b3          	sub	a5,s1,s5
    80001e36:	878d                	srai	a5,a5,0x3
    80001e38:	000a3703          	ld	a4,0(s4)
    80001e3c:	02e787b3          	mul	a5,a5,a4
    80001e40:	2785                	addiw	a5,a5,1
    80001e42:	00d7979b          	slliw	a5,a5,0xd
    80001e46:	40f907b3          	sub	a5,s2,a5
    80001e4a:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001e4c:	38848493          	addi	s1,s1,904
    80001e50:	fd349be3          	bne	s1,s3,80001e26 <procinit+0x6e>
}
    80001e54:	70e2                	ld	ra,56(sp)
    80001e56:	7442                	ld	s0,48(sp)
    80001e58:	74a2                	ld	s1,40(sp)
    80001e5a:	7902                	ld	s2,32(sp)
    80001e5c:	69e2                	ld	s3,24(sp)
    80001e5e:	6a42                	ld	s4,16(sp)
    80001e60:	6aa2                	ld	s5,8(sp)
    80001e62:	6b02                	ld	s6,0(sp)
    80001e64:	6121                	addi	sp,sp,64
    80001e66:	8082                	ret

0000000080001e68 <cpuid>:
{
    80001e68:	1141                	addi	sp,sp,-16
    80001e6a:	e422                	sd	s0,8(sp)
    80001e6c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e6e:	8512                	mv	a0,tp
}
    80001e70:	2501                	sext.w	a0,a0
    80001e72:	6422                	ld	s0,8(sp)
    80001e74:	0141                	addi	sp,sp,16
    80001e76:	8082                	ret

0000000080001e78 <mycpu>:
{
    80001e78:	1141                	addi	sp,sp,-16
    80001e7a:	e422                	sd	s0,8(sp)
    80001e7c:	0800                	addi	s0,sp,16
    80001e7e:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001e80:	2781                	sext.w	a5,a5
    80001e82:	079e                	slli	a5,a5,0x7
}
    80001e84:	00011517          	auipc	a0,0x11
    80001e88:	44c50513          	addi	a0,a0,1100 # 800132d0 <cpus>
    80001e8c:	953e                	add	a0,a0,a5
    80001e8e:	6422                	ld	s0,8(sp)
    80001e90:	0141                	addi	sp,sp,16
    80001e92:	8082                	ret

0000000080001e94 <myproc>:
{
    80001e94:	1101                	addi	sp,sp,-32
    80001e96:	ec06                	sd	ra,24(sp)
    80001e98:	e822                	sd	s0,16(sp)
    80001e9a:	e426                	sd	s1,8(sp)
    80001e9c:	1000                	addi	s0,sp,32
  push_off();
    80001e9e:	fffff097          	auipc	ra,0xfffff
    80001ea2:	cd8080e7          	jalr	-808(ra) # 80000b76 <push_off>
    80001ea6:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001ea8:	2781                	sext.w	a5,a5
    80001eaa:	079e                	slli	a5,a5,0x7
    80001eac:	00011717          	auipc	a4,0x11
    80001eb0:	3f470713          	addi	a4,a4,1012 # 800132a0 <pid_lock>
    80001eb4:	97ba                	add	a5,a5,a4
    80001eb6:	7b84                	ld	s1,48(a5)
  pop_off();
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	d5e080e7          	jalr	-674(ra) # 80000c16 <pop_off>
}
    80001ec0:	8526                	mv	a0,s1
    80001ec2:	60e2                	ld	ra,24(sp)
    80001ec4:	6442                	ld	s0,16(sp)
    80001ec6:	64a2                	ld	s1,8(sp)
    80001ec8:	6105                	addi	sp,sp,32
    80001eca:	8082                	ret

0000000080001ecc <forkret>:
{
    80001ecc:	1141                	addi	sp,sp,-16
    80001ece:	e406                	sd	ra,8(sp)
    80001ed0:	e022                	sd	s0,0(sp)
    80001ed2:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001ed4:	00000097          	auipc	ra,0x0
    80001ed8:	fc0080e7          	jalr	-64(ra) # 80001e94 <myproc>
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	d9a080e7          	jalr	-614(ra) # 80000c76 <release>
  if (first)
    80001ee4:	00008797          	auipc	a5,0x8
    80001ee8:	16c7a783          	lw	a5,364(a5) # 8000a050 <first.1>
    80001eec:	eb89                	bnez	a5,80001efe <forkret+0x32>
  usertrapret();
    80001eee:	00001097          	auipc	ra,0x1
    80001ef2:	238080e7          	jalr	568(ra) # 80003126 <usertrapret>
}
    80001ef6:	60a2                	ld	ra,8(sp)
    80001ef8:	6402                	ld	s0,0(sp)
    80001efa:	0141                	addi	sp,sp,16
    80001efc:	8082                	ret
    first = 0;
    80001efe:	00008797          	auipc	a5,0x8
    80001f02:	1407a923          	sw	zero,338(a5) # 8000a050 <first.1>
    fsinit(ROOTDEV);
    80001f06:	4505                	li	a0,1
    80001f08:	00002097          	auipc	ra,0x2
    80001f0c:	074080e7          	jalr	116(ra) # 80003f7c <fsinit>
    80001f10:	bff9                	j	80001eee <forkret+0x22>

0000000080001f12 <allocpid>:
{
    80001f12:	1101                	addi	sp,sp,-32
    80001f14:	ec06                	sd	ra,24(sp)
    80001f16:	e822                	sd	s0,16(sp)
    80001f18:	e426                	sd	s1,8(sp)
    80001f1a:	e04a                	sd	s2,0(sp)
    80001f1c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001f1e:	00011917          	auipc	s2,0x11
    80001f22:	38290913          	addi	s2,s2,898 # 800132a0 <pid_lock>
    80001f26:	854a                	mv	a0,s2
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	c9a080e7          	jalr	-870(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001f30:	00008797          	auipc	a5,0x8
    80001f34:	12478793          	addi	a5,a5,292 # 8000a054 <nextpid>
    80001f38:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001f3a:	0014871b          	addiw	a4,s1,1
    80001f3e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001f40:	854a                	mv	a0,s2
    80001f42:	fffff097          	auipc	ra,0xfffff
    80001f46:	d34080e7          	jalr	-716(ra) # 80000c76 <release>
}
    80001f4a:	8526                	mv	a0,s1
    80001f4c:	60e2                	ld	ra,24(sp)
    80001f4e:	6442                	ld	s0,16(sp)
    80001f50:	64a2                	ld	s1,8(sp)
    80001f52:	6902                	ld	s2,0(sp)
    80001f54:	6105                	addi	sp,sp,32
    80001f56:	8082                	ret

0000000080001f58 <proc_pagetable>:
{
    80001f58:	1101                	addi	sp,sp,-32
    80001f5a:	ec06                	sd	ra,24(sp)
    80001f5c:	e822                	sd	s0,16(sp)
    80001f5e:	e426                	sd	s1,8(sp)
    80001f60:	e04a                	sd	s2,0(sp)
    80001f62:	1000                	addi	s0,sp,32
    80001f64:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	2f2080e7          	jalr	754(ra) # 80001258 <uvmcreate>
    80001f6e:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001f70:	c121                	beqz	a0,80001fb0 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001f72:	4729                	li	a4,10
    80001f74:	00006697          	auipc	a3,0x6
    80001f78:	08c68693          	addi	a3,a3,140 # 80008000 <_trampoline>
    80001f7c:	6605                	lui	a2,0x1
    80001f7e:	040005b7          	lui	a1,0x4000
    80001f82:	15fd                	addi	a1,a1,-1
    80001f84:	05b2                	slli	a1,a1,0xc
    80001f86:	fffff097          	auipc	ra,0xfffff
    80001f8a:	11e080e7          	jalr	286(ra) # 800010a4 <mappages>
    80001f8e:	02054863          	bltz	a0,80001fbe <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001f92:	4719                	li	a4,6
    80001f94:	05893683          	ld	a3,88(s2)
    80001f98:	6605                	lui	a2,0x1
    80001f9a:	020005b7          	lui	a1,0x2000
    80001f9e:	15fd                	addi	a1,a1,-1
    80001fa0:	05b6                	slli	a1,a1,0xd
    80001fa2:	8526                	mv	a0,s1
    80001fa4:	fffff097          	auipc	ra,0xfffff
    80001fa8:	100080e7          	jalr	256(ra) # 800010a4 <mappages>
    80001fac:	02054163          	bltz	a0,80001fce <proc_pagetable+0x76>
}
    80001fb0:	8526                	mv	a0,s1
    80001fb2:	60e2                	ld	ra,24(sp)
    80001fb4:	6442                	ld	s0,16(sp)
    80001fb6:	64a2                	ld	s1,8(sp)
    80001fb8:	6902                	ld	s2,0(sp)
    80001fba:	6105                	addi	sp,sp,32
    80001fbc:	8082                	ret
    uvmfree(pagetable, 0);
    80001fbe:	4581                	li	a1,0
    80001fc0:	8526                	mv	a0,s1
    80001fc2:	00000097          	auipc	ra,0x0
    80001fc6:	bf4080e7          	jalr	-1036(ra) # 80001bb6 <uvmfree>
    return 0;
    80001fca:	4481                	li	s1,0
    80001fcc:	b7d5                	j	80001fb0 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001fce:	4681                	li	a3,0
    80001fd0:	4605                	li	a2,1
    80001fd2:	040005b7          	lui	a1,0x4000
    80001fd6:	15fd                	addi	a1,a1,-1
    80001fd8:	05b2                	slli	a1,a1,0xc
    80001fda:	8526                	mv	a0,s1
    80001fdc:	00000097          	auipc	ra,0x0
    80001fe0:	840080e7          	jalr	-1984(ra) # 8000181c <uvmunmap>
    uvmfree(pagetable, 0);
    80001fe4:	4581                	li	a1,0
    80001fe6:	8526                	mv	a0,s1
    80001fe8:	00000097          	auipc	ra,0x0
    80001fec:	bce080e7          	jalr	-1074(ra) # 80001bb6 <uvmfree>
    return 0;
    80001ff0:	4481                	li	s1,0
    80001ff2:	bf7d                	j	80001fb0 <proc_pagetable+0x58>

0000000080001ff4 <proc_freepagetable>:
{
    80001ff4:	1101                	addi	sp,sp,-32
    80001ff6:	ec06                	sd	ra,24(sp)
    80001ff8:	e822                	sd	s0,16(sp)
    80001ffa:	e426                	sd	s1,8(sp)
    80001ffc:	e04a                	sd	s2,0(sp)
    80001ffe:	1000                	addi	s0,sp,32
    80002000:	84aa                	mv	s1,a0
    80002002:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80002004:	4681                	li	a3,0
    80002006:	4605                	li	a2,1
    80002008:	040005b7          	lui	a1,0x4000
    8000200c:	15fd                	addi	a1,a1,-1
    8000200e:	05b2                	slli	a1,a1,0xc
    80002010:	00000097          	auipc	ra,0x0
    80002014:	80c080e7          	jalr	-2036(ra) # 8000181c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80002018:	4681                	li	a3,0
    8000201a:	4605                	li	a2,1
    8000201c:	020005b7          	lui	a1,0x2000
    80002020:	15fd                	addi	a1,a1,-1
    80002022:	05b6                	slli	a1,a1,0xd
    80002024:	8526                	mv	a0,s1
    80002026:	fffff097          	auipc	ra,0xfffff
    8000202a:	7f6080e7          	jalr	2038(ra) # 8000181c <uvmunmap>
  uvmfree(pagetable, sz);
    8000202e:	85ca                	mv	a1,s2
    80002030:	8526                	mv	a0,s1
    80002032:	00000097          	auipc	ra,0x0
    80002036:	b84080e7          	jalr	-1148(ra) # 80001bb6 <uvmfree>
}
    8000203a:	60e2                	ld	ra,24(sp)
    8000203c:	6442                	ld	s0,16(sp)
    8000203e:	64a2                	ld	s1,8(sp)
    80002040:	6902                	ld	s2,0(sp)
    80002042:	6105                	addi	sp,sp,32
    80002044:	8082                	ret

0000000080002046 <freeproc>:
{
    80002046:	1101                	addi	sp,sp,-32
    80002048:	ec06                	sd	ra,24(sp)
    8000204a:	e822                	sd	s0,16(sp)
    8000204c:	e426                	sd	s1,8(sp)
    8000204e:	1000                	addi	s0,sp,32
    80002050:	84aa                	mv	s1,a0
  if (p->trapframe)
    80002052:	6d28                	ld	a0,88(a0)
    80002054:	c509                	beqz	a0,8000205e <freeproc+0x18>
    kfree((void *)p->trapframe);
    80002056:	fffff097          	auipc	ra,0xfffff
    8000205a:	980080e7          	jalr	-1664(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    8000205e:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80002062:	68a8                	ld	a0,80(s1)
    80002064:	c511                	beqz	a0,80002070 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80002066:	64ac                	ld	a1,72(s1)
    80002068:	00000097          	auipc	ra,0x0
    8000206c:	f8c080e7          	jalr	-116(ra) # 80001ff4 <proc_freepagetable>
  p->pagetable = 0;
    80002070:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80002074:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80002078:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    8000207c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80002080:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80002084:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80002088:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    8000208c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80002090:	0004ac23          	sw	zero,24(s1)
}
    80002094:	60e2                	ld	ra,24(sp)
    80002096:	6442                	ld	s0,16(sp)
    80002098:	64a2                	ld	s1,8(sp)
    8000209a:	6105                	addi	sp,sp,32
    8000209c:	8082                	ret

000000008000209e <allocproc>:
{
    8000209e:	1101                	addi	sp,sp,-32
    800020a0:	ec06                	sd	ra,24(sp)
    800020a2:	e822                	sd	s0,16(sp)
    800020a4:	e426                	sd	s1,8(sp)
    800020a6:	e04a                	sd	s2,0(sp)
    800020a8:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    800020aa:	00011497          	auipc	s1,0x11
    800020ae:	62648493          	addi	s1,s1,1574 # 800136d0 <proc>
    800020b2:	00020917          	auipc	s2,0x20
    800020b6:	81e90913          	addi	s2,s2,-2018 # 800218d0 <tickslock>
    acquire(&p->lock);
    800020ba:	8526                	mv	a0,s1
    800020bc:	fffff097          	auipc	ra,0xfffff
    800020c0:	b06080e7          	jalr	-1274(ra) # 80000bc2 <acquire>
    if (p->state == UNUSED)
    800020c4:	4c9c                	lw	a5,24(s1)
    800020c6:	cf81                	beqz	a5,800020de <allocproc+0x40>
      release(&p->lock);
    800020c8:	8526                	mv	a0,s1
    800020ca:	fffff097          	auipc	ra,0xfffff
    800020ce:	bac080e7          	jalr	-1108(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800020d2:	38848493          	addi	s1,s1,904
    800020d6:	ff2492e3          	bne	s1,s2,800020ba <allocproc+0x1c>
  return 0;
    800020da:	4481                	li	s1,0
    800020dc:	a08d                	j	8000213e <allocproc+0xa0>
  p->pid = allocpid();
    800020de:	00000097          	auipc	ra,0x0
    800020e2:	e34080e7          	jalr	-460(ra) # 80001f12 <allocpid>
    800020e6:	d888                	sw	a0,48(s1)
  p->state = USED;
    800020e8:	4785                	li	a5,1
    800020ea:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    800020ec:	fffff097          	auipc	ra,0xfffff
    800020f0:	9e6080e7          	jalr	-1562(ra) # 80000ad2 <kalloc>
    800020f4:	892a                	mv	s2,a0
    800020f6:	eca8                	sd	a0,88(s1)
    800020f8:	c931                	beqz	a0,8000214c <allocproc+0xae>
  p->pagetable = proc_pagetable(p);
    800020fa:	8526                	mv	a0,s1
    800020fc:	00000097          	auipc	ra,0x0
    80002100:	e5c080e7          	jalr	-420(ra) # 80001f58 <proc_pagetable>
    80002104:	892a                	mv	s2,a0
    80002106:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80002108:	cd31                	beqz	a0,80002164 <allocproc+0xc6>
  memset(&p->context, 0, sizeof(p->context));
    8000210a:	07000613          	li	a2,112
    8000210e:	4581                	li	a1,0
    80002110:	06048513          	addi	a0,s1,96
    80002114:	fffff097          	auipc	ra,0xfffff
    80002118:	baa080e7          	jalr	-1110(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    8000211c:	00000797          	auipc	a5,0x0
    80002120:	db078793          	addi	a5,a5,-592 # 80001ecc <forkret>
    80002124:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002126:	60bc                	ld	a5,64(s1)
    80002128:	6705                	lui	a4,0x1
    8000212a:	97ba                	add	a5,a5,a4
    8000212c:	f4bc                	sd	a5,104(s1)
  p->physical_pages_num = 0;
    8000212e:	1604a823          	sw	zero,368(s1)
  p->total_pages_num = 0;
    80002132:	1604aa23          	sw	zero,372(s1)
  p->pages_physc_info.free_spaces = 0;
    80002136:	28049023          	sh	zero,640(s1)
  p->pages_swap_info.free_spaces = 0;
    8000213a:	16049c23          	sh	zero,376(s1)
}
    8000213e:	8526                	mv	a0,s1
    80002140:	60e2                	ld	ra,24(sp)
    80002142:	6442                	ld	s0,16(sp)
    80002144:	64a2                	ld	s1,8(sp)
    80002146:	6902                	ld	s2,0(sp)
    80002148:	6105                	addi	sp,sp,32
    8000214a:	8082                	ret
    freeproc(p);
    8000214c:	8526                	mv	a0,s1
    8000214e:	00000097          	auipc	ra,0x0
    80002152:	ef8080e7          	jalr	-264(ra) # 80002046 <freeproc>
    release(&p->lock);
    80002156:	8526                	mv	a0,s1
    80002158:	fffff097          	auipc	ra,0xfffff
    8000215c:	b1e080e7          	jalr	-1250(ra) # 80000c76 <release>
    return 0;
    80002160:	84ca                	mv	s1,s2
    80002162:	bff1                	j	8000213e <allocproc+0xa0>
    freeproc(p);
    80002164:	8526                	mv	a0,s1
    80002166:	00000097          	auipc	ra,0x0
    8000216a:	ee0080e7          	jalr	-288(ra) # 80002046 <freeproc>
    release(&p->lock);
    8000216e:	8526                	mv	a0,s1
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	b06080e7          	jalr	-1274(ra) # 80000c76 <release>
    return 0;
    80002178:	84ca                	mv	s1,s2
    8000217a:	b7d1                	j	8000213e <allocproc+0xa0>

000000008000217c <userinit>:
{
    8000217c:	1101                	addi	sp,sp,-32
    8000217e:	ec06                	sd	ra,24(sp)
    80002180:	e822                	sd	s0,16(sp)
    80002182:	e426                	sd	s1,8(sp)
    80002184:	1000                	addi	s0,sp,32
  p = allocproc();
    80002186:	00000097          	auipc	ra,0x0
    8000218a:	f18080e7          	jalr	-232(ra) # 8000209e <allocproc>
    8000218e:	84aa                	mv	s1,a0
  initproc = p;
    80002190:	00009797          	auipc	a5,0x9
    80002194:	e8a7bc23          	sd	a0,-360(a5) # 8000b028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80002198:	03400613          	li	a2,52
    8000219c:	00008597          	auipc	a1,0x8
    800021a0:	ec458593          	addi	a1,a1,-316 # 8000a060 <initcode>
    800021a4:	6928                	ld	a0,80(a0)
    800021a6:	fffff097          	auipc	ra,0xfffff
    800021aa:	0e0080e7          	jalr	224(ra) # 80001286 <uvminit>
  p->sz = PGSIZE;
    800021ae:	6785                	lui	a5,0x1
    800021b0:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    800021b2:	6cb8                	ld	a4,88(s1)
    800021b4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    800021b8:	6cb8                	ld	a4,88(s1)
    800021ba:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800021bc:	4641                	li	a2,16
    800021be:	00007597          	auipc	a1,0x7
    800021c2:	4aa58593          	addi	a1,a1,1194 # 80009668 <digits+0x628>
    800021c6:	15848513          	addi	a0,s1,344
    800021ca:	fffff097          	auipc	ra,0xfffff
    800021ce:	c46080e7          	jalr	-954(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    800021d2:	00007517          	auipc	a0,0x7
    800021d6:	4a650513          	addi	a0,a0,1190 # 80009678 <digits+0x638>
    800021da:	00002097          	auipc	ra,0x2
    800021de:	7d0080e7          	jalr	2000(ra) # 800049aa <namei>
    800021e2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800021e6:	478d                	li	a5,3
    800021e8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800021ea:	8526                	mv	a0,s1
    800021ec:	fffff097          	auipc	ra,0xfffff
    800021f0:	a8a080e7          	jalr	-1398(ra) # 80000c76 <release>
}
    800021f4:	60e2                	ld	ra,24(sp)
    800021f6:	6442                	ld	s0,16(sp)
    800021f8:	64a2                	ld	s1,8(sp)
    800021fa:	6105                	addi	sp,sp,32
    800021fc:	8082                	ret

00000000800021fe <growproc>:
{
    800021fe:	1101                	addi	sp,sp,-32
    80002200:	ec06                	sd	ra,24(sp)
    80002202:	e822                	sd	s0,16(sp)
    80002204:	e426                	sd	s1,8(sp)
    80002206:	e04a                	sd	s2,0(sp)
    80002208:	1000                	addi	s0,sp,32
    8000220a:	84aa                	mv	s1,a0
  printf("growproc... n= %d\n",n);
    8000220c:	85aa                	mv	a1,a0
    8000220e:	00007517          	auipc	a0,0x7
    80002212:	47250513          	addi	a0,a0,1138 # 80009680 <digits+0x640>
    80002216:	ffffe097          	auipc	ra,0xffffe
    8000221a:	35e080e7          	jalr	862(ra) # 80000574 <printf>
  struct proc *p = myproc();
    8000221e:	00000097          	auipc	ra,0x0
    80002222:	c76080e7          	jalr	-906(ra) # 80001e94 <myproc>
    80002226:	892a                	mv	s2,a0
  sz = p->sz;
    80002228:	652c                	ld	a1,72(a0)
    8000222a:	0005861b          	sext.w	a2,a1
  if (n > 0)
    8000222e:	00904f63          	bgtz	s1,8000224c <growproc+0x4e>
  else if (n < 0)
    80002232:	0204cc63          	bltz	s1,8000226a <growproc+0x6c>
  p->sz = sz;
    80002236:	1602                	slli	a2,a2,0x20
    80002238:	9201                	srli	a2,a2,0x20
    8000223a:	04c93423          	sd	a2,72(s2)
  return 0;
    8000223e:	4501                	li	a0,0
}
    80002240:	60e2                	ld	ra,24(sp)
    80002242:	6442                	ld	s0,16(sp)
    80002244:	64a2                	ld	s1,8(sp)
    80002246:	6902                	ld	s2,0(sp)
    80002248:	6105                	addi	sp,sp,32
    8000224a:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0)
    8000224c:	9e25                	addw	a2,a2,s1
    8000224e:	1602                	slli	a2,a2,0x20
    80002250:	9201                	srli	a2,a2,0x20
    80002252:	1582                	slli	a1,a1,0x20
    80002254:	9181                	srli	a1,a1,0x20
    80002256:	6928                	ld	a0,80(a0)
    80002258:	fffff097          	auipc	ra,0xfffff
    8000225c:	7ae080e7          	jalr	1966(ra) # 80001a06 <uvmalloc>
    80002260:	0005061b          	sext.w	a2,a0
    80002264:	fa69                	bnez	a2,80002236 <growproc+0x38>
      return -1;
    80002266:	557d                	li	a0,-1
    80002268:	bfe1                	j	80002240 <growproc+0x42>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000226a:	9e25                	addw	a2,a2,s1
    8000226c:	1602                	slli	a2,a2,0x20
    8000226e:	9201                	srli	a2,a2,0x20
    80002270:	1582                	slli	a1,a1,0x20
    80002272:	9181                	srli	a1,a1,0x20
    80002274:	6928                	ld	a0,80(a0)
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	72a080e7          	jalr	1834(ra) # 800019a0 <uvmdealloc>
    8000227e:	0005061b          	sext.w	a2,a0
    80002282:	bf55                	j	80002236 <growproc+0x38>

0000000080002284 <scheduler>:
{
    80002284:	7139                	addi	sp,sp,-64
    80002286:	fc06                	sd	ra,56(sp)
    80002288:	f822                	sd	s0,48(sp)
    8000228a:	f426                	sd	s1,40(sp)
    8000228c:	f04a                	sd	s2,32(sp)
    8000228e:	ec4e                	sd	s3,24(sp)
    80002290:	e852                	sd	s4,16(sp)
    80002292:	e456                	sd	s5,8(sp)
    80002294:	e05a                	sd	s6,0(sp)
    80002296:	0080                	addi	s0,sp,64
    80002298:	8792                	mv	a5,tp
  int id = r_tp();
    8000229a:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000229c:	00779a93          	slli	s5,a5,0x7
    800022a0:	00011717          	auipc	a4,0x11
    800022a4:	00070713          	mv	a4,a4
    800022a8:	9756                	add	a4,a4,s5
    800022aa:	02073823          	sd	zero,48(a4) # 800132d0 <cpus>
        swtch(&c->context, &p->context);
    800022ae:	00011717          	auipc	a4,0x11
    800022b2:	02a70713          	addi	a4,a4,42 # 800132d8 <cpus+0x8>
    800022b6:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    800022b8:	498d                	li	s3,3
        p->state = RUNNING;
    800022ba:	4b11                	li	s6,4
        c->proc = p;
    800022bc:	079e                	slli	a5,a5,0x7
    800022be:	00011a17          	auipc	s4,0x11
    800022c2:	fe2a0a13          	addi	s4,s4,-30 # 800132a0 <pid_lock>
    800022c6:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    800022c8:	0001f917          	auipc	s2,0x1f
    800022cc:	60890913          	addi	s2,s2,1544 # 800218d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022d0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800022d4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022d8:	10079073          	csrw	sstatus,a5
    800022dc:	00011497          	auipc	s1,0x11
    800022e0:	3f448493          	addi	s1,s1,1012 # 800136d0 <proc>
    800022e4:	a811                	j	800022f8 <scheduler+0x74>
      release(&p->lock);
    800022e6:	8526                	mv	a0,s1
    800022e8:	fffff097          	auipc	ra,0xfffff
    800022ec:	98e080e7          	jalr	-1650(ra) # 80000c76 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800022f0:	38848493          	addi	s1,s1,904
    800022f4:	fd248ee3          	beq	s1,s2,800022d0 <scheduler+0x4c>
      acquire(&p->lock);
    800022f8:	8526                	mv	a0,s1
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	8c8080e7          	jalr	-1848(ra) # 80000bc2 <acquire>
      if (p->state == RUNNABLE)
    80002302:	4c9c                	lw	a5,24(s1)
    80002304:	ff3791e3          	bne	a5,s3,800022e6 <scheduler+0x62>
        p->state = RUNNING;
    80002308:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    8000230c:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002310:	06048593          	addi	a1,s1,96
    80002314:	8556                	mv	a0,s5
    80002316:	00001097          	auipc	ra,0x1
    8000231a:	d66080e7          	jalr	-666(ra) # 8000307c <swtch>
        c->proc = 0;
    8000231e:	020a3823          	sd	zero,48(s4)
    80002322:	b7d1                	j	800022e6 <scheduler+0x62>

0000000080002324 <sched>:
{
    80002324:	7179                	addi	sp,sp,-48
    80002326:	f406                	sd	ra,40(sp)
    80002328:	f022                	sd	s0,32(sp)
    8000232a:	ec26                	sd	s1,24(sp)
    8000232c:	e84a                	sd	s2,16(sp)
    8000232e:	e44e                	sd	s3,8(sp)
    80002330:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002332:	00000097          	auipc	ra,0x0
    80002336:	b62080e7          	jalr	-1182(ra) # 80001e94 <myproc>
    8000233a:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000233c:	fffff097          	auipc	ra,0xfffff
    80002340:	80c080e7          	jalr	-2036(ra) # 80000b48 <holding>
    80002344:	c93d                	beqz	a0,800023ba <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002346:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002348:	2781                	sext.w	a5,a5
    8000234a:	079e                	slli	a5,a5,0x7
    8000234c:	00011717          	auipc	a4,0x11
    80002350:	f5470713          	addi	a4,a4,-172 # 800132a0 <pid_lock>
    80002354:	97ba                	add	a5,a5,a4
    80002356:	0a87a703          	lw	a4,168(a5) # 10a8 <_entry-0x7fffef58>
    8000235a:	4785                	li	a5,1
    8000235c:	06f71763          	bne	a4,a5,800023ca <sched+0xa6>
  if (p->state == RUNNING)
    80002360:	4c98                	lw	a4,24(s1)
    80002362:	4791                	li	a5,4
    80002364:	06f70b63          	beq	a4,a5,800023da <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002368:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000236c:	8b89                	andi	a5,a5,2
  if (intr_get())
    8000236e:	efb5                	bnez	a5,800023ea <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002370:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002372:	00011917          	auipc	s2,0x11
    80002376:	f2e90913          	addi	s2,s2,-210 # 800132a0 <pid_lock>
    8000237a:	2781                	sext.w	a5,a5
    8000237c:	079e                	slli	a5,a5,0x7
    8000237e:	97ca                	add	a5,a5,s2
    80002380:	0ac7a983          	lw	s3,172(a5)
    80002384:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002386:	2781                	sext.w	a5,a5
    80002388:	079e                	slli	a5,a5,0x7
    8000238a:	00011597          	auipc	a1,0x11
    8000238e:	f4e58593          	addi	a1,a1,-178 # 800132d8 <cpus+0x8>
    80002392:	95be                	add	a1,a1,a5
    80002394:	06048513          	addi	a0,s1,96
    80002398:	00001097          	auipc	ra,0x1
    8000239c:	ce4080e7          	jalr	-796(ra) # 8000307c <swtch>
    800023a0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800023a2:	2781                	sext.w	a5,a5
    800023a4:	079e                	slli	a5,a5,0x7
    800023a6:	97ca                	add	a5,a5,s2
    800023a8:	0b37a623          	sw	s3,172(a5)
}
    800023ac:	70a2                	ld	ra,40(sp)
    800023ae:	7402                	ld	s0,32(sp)
    800023b0:	64e2                	ld	s1,24(sp)
    800023b2:	6942                	ld	s2,16(sp)
    800023b4:	69a2                	ld	s3,8(sp)
    800023b6:	6145                	addi	sp,sp,48
    800023b8:	8082                	ret
    panic("sched p->lock");
    800023ba:	00007517          	auipc	a0,0x7
    800023be:	2de50513          	addi	a0,a0,734 # 80009698 <digits+0x658>
    800023c2:	ffffe097          	auipc	ra,0xffffe
    800023c6:	168080e7          	jalr	360(ra) # 8000052a <panic>
    panic("sched locks");
    800023ca:	00007517          	auipc	a0,0x7
    800023ce:	2de50513          	addi	a0,a0,734 # 800096a8 <digits+0x668>
    800023d2:	ffffe097          	auipc	ra,0xffffe
    800023d6:	158080e7          	jalr	344(ra) # 8000052a <panic>
    panic("sched running");
    800023da:	00007517          	auipc	a0,0x7
    800023de:	2de50513          	addi	a0,a0,734 # 800096b8 <digits+0x678>
    800023e2:	ffffe097          	auipc	ra,0xffffe
    800023e6:	148080e7          	jalr	328(ra) # 8000052a <panic>
    panic("sched interruptible");
    800023ea:	00007517          	auipc	a0,0x7
    800023ee:	2de50513          	addi	a0,a0,734 # 800096c8 <digits+0x688>
    800023f2:	ffffe097          	auipc	ra,0xffffe
    800023f6:	138080e7          	jalr	312(ra) # 8000052a <panic>

00000000800023fa <yield>:
{
    800023fa:	1101                	addi	sp,sp,-32
    800023fc:	ec06                	sd	ra,24(sp)
    800023fe:	e822                	sd	s0,16(sp)
    80002400:	e426                	sd	s1,8(sp)
    80002402:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002404:	00000097          	auipc	ra,0x0
    80002408:	a90080e7          	jalr	-1392(ra) # 80001e94 <myproc>
    8000240c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000240e:	ffffe097          	auipc	ra,0xffffe
    80002412:	7b4080e7          	jalr	1972(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    80002416:	478d                	li	a5,3
    80002418:	cc9c                	sw	a5,24(s1)
  sched();
    8000241a:	00000097          	auipc	ra,0x0
    8000241e:	f0a080e7          	jalr	-246(ra) # 80002324 <sched>
  release(&p->lock);
    80002422:	8526                	mv	a0,s1
    80002424:	fffff097          	auipc	ra,0xfffff
    80002428:	852080e7          	jalr	-1966(ra) # 80000c76 <release>
}
    8000242c:	60e2                	ld	ra,24(sp)
    8000242e:	6442                	ld	s0,16(sp)
    80002430:	64a2                	ld	s1,8(sp)
    80002432:	6105                	addi	sp,sp,32
    80002434:	8082                	ret

0000000080002436 <sleep>:
{
    80002436:	7179                	addi	sp,sp,-48
    80002438:	f406                	sd	ra,40(sp)
    8000243a:	f022                	sd	s0,32(sp)
    8000243c:	ec26                	sd	s1,24(sp)
    8000243e:	e84a                	sd	s2,16(sp)
    80002440:	e44e                	sd	s3,8(sp)
    80002442:	1800                	addi	s0,sp,48
    80002444:	89aa                	mv	s3,a0
    80002446:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002448:	00000097          	auipc	ra,0x0
    8000244c:	a4c080e7          	jalr	-1460(ra) # 80001e94 <myproc>
    80002450:	84aa                	mv	s1,a0
  acquire(&p->lock); //DOC: sleeplock1
    80002452:	ffffe097          	auipc	ra,0xffffe
    80002456:	770080e7          	jalr	1904(ra) # 80000bc2 <acquire>
  release(lk);
    8000245a:	854a                	mv	a0,s2
    8000245c:	fffff097          	auipc	ra,0xfffff
    80002460:	81a080e7          	jalr	-2022(ra) # 80000c76 <release>
  p->chan = chan;
    80002464:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002468:	4789                	li	a5,2
    8000246a:	cc9c                	sw	a5,24(s1)
  sched();
    8000246c:	00000097          	auipc	ra,0x0
    80002470:	eb8080e7          	jalr	-328(ra) # 80002324 <sched>
  p->chan = 0;
    80002474:	0204b023          	sd	zero,32(s1)
  release(&p->lock);
    80002478:	8526                	mv	a0,s1
    8000247a:	ffffe097          	auipc	ra,0xffffe
    8000247e:	7fc080e7          	jalr	2044(ra) # 80000c76 <release>
  acquire(lk);
    80002482:	854a                	mv	a0,s2
    80002484:	ffffe097          	auipc	ra,0xffffe
    80002488:	73e080e7          	jalr	1854(ra) # 80000bc2 <acquire>
}
    8000248c:	70a2                	ld	ra,40(sp)
    8000248e:	7402                	ld	s0,32(sp)
    80002490:	64e2                	ld	s1,24(sp)
    80002492:	6942                	ld	s2,16(sp)
    80002494:	69a2                	ld	s3,8(sp)
    80002496:	6145                	addi	sp,sp,48
    80002498:	8082                	ret

000000008000249a <wait>:
{
    8000249a:	715d                	addi	sp,sp,-80
    8000249c:	e486                	sd	ra,72(sp)
    8000249e:	e0a2                	sd	s0,64(sp)
    800024a0:	fc26                	sd	s1,56(sp)
    800024a2:	f84a                	sd	s2,48(sp)
    800024a4:	f44e                	sd	s3,40(sp)
    800024a6:	f052                	sd	s4,32(sp)
    800024a8:	ec56                	sd	s5,24(sp)
    800024aa:	e85a                	sd	s6,16(sp)
    800024ac:	e45e                	sd	s7,8(sp)
    800024ae:	e062                	sd	s8,0(sp)
    800024b0:	0880                	addi	s0,sp,80
    800024b2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800024b4:	00000097          	auipc	ra,0x0
    800024b8:	9e0080e7          	jalr	-1568(ra) # 80001e94 <myproc>
    800024bc:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024be:	00011517          	auipc	a0,0x11
    800024c2:	dfa50513          	addi	a0,a0,-518 # 800132b8 <wait_lock>
    800024c6:	ffffe097          	auipc	ra,0xffffe
    800024ca:	6fc080e7          	jalr	1788(ra) # 80000bc2 <acquire>
    havekids = 0;
    800024ce:	4b81                	li	s7,0
        if (np->state == ZOMBIE)
    800024d0:	4a15                	li	s4,5
        havekids = 1;
    800024d2:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800024d4:	0001f997          	auipc	s3,0x1f
    800024d8:	3fc98993          	addi	s3,s3,1020 # 800218d0 <tickslock>
    sleep(p, &wait_lock); //DOC: wait-sleep
    800024dc:	00011c17          	auipc	s8,0x11
    800024e0:	ddcc0c13          	addi	s8,s8,-548 # 800132b8 <wait_lock>
    havekids = 0;
    800024e4:	875e                	mv	a4,s7
    for (np = proc; np < &proc[NPROC]; np++)
    800024e6:	00011497          	auipc	s1,0x11
    800024ea:	1ea48493          	addi	s1,s1,490 # 800136d0 <proc>
    800024ee:	a0bd                	j	8000255c <wait+0xc2>
          pid = np->pid;
    800024f0:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800024f4:	000b0e63          	beqz	s6,80002510 <wait+0x76>
    800024f8:	4691                	li	a3,4
    800024fa:	02c48613          	addi	a2,s1,44
    800024fe:	85da                	mv	a1,s6
    80002500:	05093503          	ld	a0,80(s2)
    80002504:	fffff097          	auipc	ra,0xfffff
    80002508:	eb0080e7          	jalr	-336(ra) # 800013b4 <copyout>
    8000250c:	02054563          	bltz	a0,80002536 <wait+0x9c>
          freeproc(np);
    80002510:	8526                	mv	a0,s1
    80002512:	00000097          	auipc	ra,0x0
    80002516:	b34080e7          	jalr	-1228(ra) # 80002046 <freeproc>
          release(&np->lock);
    8000251a:	8526                	mv	a0,s1
    8000251c:	ffffe097          	auipc	ra,0xffffe
    80002520:	75a080e7          	jalr	1882(ra) # 80000c76 <release>
          release(&wait_lock);
    80002524:	00011517          	auipc	a0,0x11
    80002528:	d9450513          	addi	a0,a0,-620 # 800132b8 <wait_lock>
    8000252c:	ffffe097          	auipc	ra,0xffffe
    80002530:	74a080e7          	jalr	1866(ra) # 80000c76 <release>
          return pid;
    80002534:	a09d                	j	8000259a <wait+0x100>
            release(&np->lock);
    80002536:	8526                	mv	a0,s1
    80002538:	ffffe097          	auipc	ra,0xffffe
    8000253c:	73e080e7          	jalr	1854(ra) # 80000c76 <release>
            release(&wait_lock);
    80002540:	00011517          	auipc	a0,0x11
    80002544:	d7850513          	addi	a0,a0,-648 # 800132b8 <wait_lock>
    80002548:	ffffe097          	auipc	ra,0xffffe
    8000254c:	72e080e7          	jalr	1838(ra) # 80000c76 <release>
            return -1;
    80002550:	59fd                	li	s3,-1
    80002552:	a0a1                	j	8000259a <wait+0x100>
    for (np = proc; np < &proc[NPROC]; np++)
    80002554:	38848493          	addi	s1,s1,904
    80002558:	03348463          	beq	s1,s3,80002580 <wait+0xe6>
      if (np->parent == p)
    8000255c:	7c9c                	ld	a5,56(s1)
    8000255e:	ff279be3          	bne	a5,s2,80002554 <wait+0xba>
        acquire(&np->lock);
    80002562:	8526                	mv	a0,s1
    80002564:	ffffe097          	auipc	ra,0xffffe
    80002568:	65e080e7          	jalr	1630(ra) # 80000bc2 <acquire>
        if (np->state == ZOMBIE)
    8000256c:	4c9c                	lw	a5,24(s1)
    8000256e:	f94781e3          	beq	a5,s4,800024f0 <wait+0x56>
        release(&np->lock);
    80002572:	8526                	mv	a0,s1
    80002574:	ffffe097          	auipc	ra,0xffffe
    80002578:	702080e7          	jalr	1794(ra) # 80000c76 <release>
        havekids = 1;
    8000257c:	8756                	mv	a4,s5
    8000257e:	bfd9                	j	80002554 <wait+0xba>
    if (!havekids || p->killed)
    80002580:	c701                	beqz	a4,80002588 <wait+0xee>
    80002582:	02892783          	lw	a5,40(s2)
    80002586:	c79d                	beqz	a5,800025b4 <wait+0x11a>
      release(&wait_lock);
    80002588:	00011517          	auipc	a0,0x11
    8000258c:	d3050513          	addi	a0,a0,-720 # 800132b8 <wait_lock>
    80002590:	ffffe097          	auipc	ra,0xffffe
    80002594:	6e6080e7          	jalr	1766(ra) # 80000c76 <release>
      return -1;
    80002598:	59fd                	li	s3,-1
}
    8000259a:	854e                	mv	a0,s3
    8000259c:	60a6                	ld	ra,72(sp)
    8000259e:	6406                	ld	s0,64(sp)
    800025a0:	74e2                	ld	s1,56(sp)
    800025a2:	7942                	ld	s2,48(sp)
    800025a4:	79a2                	ld	s3,40(sp)
    800025a6:	7a02                	ld	s4,32(sp)
    800025a8:	6ae2                	ld	s5,24(sp)
    800025aa:	6b42                	ld	s6,16(sp)
    800025ac:	6ba2                	ld	s7,8(sp)
    800025ae:	6c02                	ld	s8,0(sp)
    800025b0:	6161                	addi	sp,sp,80
    800025b2:	8082                	ret
    sleep(p, &wait_lock); //DOC: wait-sleep
    800025b4:	85e2                	mv	a1,s8
    800025b6:	854a                	mv	a0,s2
    800025b8:	00000097          	auipc	ra,0x0
    800025bc:	e7e080e7          	jalr	-386(ra) # 80002436 <sleep>
    havekids = 0;
    800025c0:	b715                	j	800024e4 <wait+0x4a>

00000000800025c2 <wakeup>:
{
    800025c2:	7139                	addi	sp,sp,-64
    800025c4:	fc06                	sd	ra,56(sp)
    800025c6:	f822                	sd	s0,48(sp)
    800025c8:	f426                	sd	s1,40(sp)
    800025ca:	f04a                	sd	s2,32(sp)
    800025cc:	ec4e                	sd	s3,24(sp)
    800025ce:	e852                	sd	s4,16(sp)
    800025d0:	e456                	sd	s5,8(sp)
    800025d2:	0080                	addi	s0,sp,64
    800025d4:	8a2a                	mv	s4,a0
  for (p = proc; p < &proc[NPROC]; p++)
    800025d6:	00011497          	auipc	s1,0x11
    800025da:	0fa48493          	addi	s1,s1,250 # 800136d0 <proc>
      if (p->state == SLEEPING && p->chan == chan)
    800025de:	4989                	li	s3,2
        p->state = RUNNABLE;
    800025e0:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800025e2:	0001f917          	auipc	s2,0x1f
    800025e6:	2ee90913          	addi	s2,s2,750 # 800218d0 <tickslock>
    800025ea:	a811                	j	800025fe <wakeup+0x3c>
      release(&p->lock);
    800025ec:	8526                	mv	a0,s1
    800025ee:	ffffe097          	auipc	ra,0xffffe
    800025f2:	688080e7          	jalr	1672(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800025f6:	38848493          	addi	s1,s1,904
    800025fa:	03248663          	beq	s1,s2,80002626 <wakeup+0x64>
    if (p != myproc())
    800025fe:	00000097          	auipc	ra,0x0
    80002602:	896080e7          	jalr	-1898(ra) # 80001e94 <myproc>
    80002606:	fea488e3          	beq	s1,a0,800025f6 <wakeup+0x34>
      acquire(&p->lock);
    8000260a:	8526                	mv	a0,s1
    8000260c:	ffffe097          	auipc	ra,0xffffe
    80002610:	5b6080e7          	jalr	1462(ra) # 80000bc2 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002614:	4c9c                	lw	a5,24(s1)
    80002616:	fd379be3          	bne	a5,s3,800025ec <wakeup+0x2a>
    8000261a:	709c                	ld	a5,32(s1)
    8000261c:	fd4798e3          	bne	a5,s4,800025ec <wakeup+0x2a>
        p->state = RUNNABLE;
    80002620:	0154ac23          	sw	s5,24(s1)
    80002624:	b7e1                	j	800025ec <wakeup+0x2a>
}
    80002626:	70e2                	ld	ra,56(sp)
    80002628:	7442                	ld	s0,48(sp)
    8000262a:	74a2                	ld	s1,40(sp)
    8000262c:	7902                	ld	s2,32(sp)
    8000262e:	69e2                	ld	s3,24(sp)
    80002630:	6a42                	ld	s4,16(sp)
    80002632:	6aa2                	ld	s5,8(sp)
    80002634:	6121                	addi	sp,sp,64
    80002636:	8082                	ret

0000000080002638 <reparent>:
{
    80002638:	7179                	addi	sp,sp,-48
    8000263a:	f406                	sd	ra,40(sp)
    8000263c:	f022                	sd	s0,32(sp)
    8000263e:	ec26                	sd	s1,24(sp)
    80002640:	e84a                	sd	s2,16(sp)
    80002642:	e44e                	sd	s3,8(sp)
    80002644:	e052                	sd	s4,0(sp)
    80002646:	1800                	addi	s0,sp,48
    80002648:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000264a:	00011497          	auipc	s1,0x11
    8000264e:	08648493          	addi	s1,s1,134 # 800136d0 <proc>
      pp->parent = initproc;
    80002652:	00009a17          	auipc	s4,0x9
    80002656:	9d6a0a13          	addi	s4,s4,-1578 # 8000b028 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000265a:	0001f997          	auipc	s3,0x1f
    8000265e:	27698993          	addi	s3,s3,630 # 800218d0 <tickslock>
    80002662:	a029                	j	8000266c <reparent+0x34>
    80002664:	38848493          	addi	s1,s1,904
    80002668:	01348d63          	beq	s1,s3,80002682 <reparent+0x4a>
    if (pp->parent == p)
    8000266c:	7c9c                	ld	a5,56(s1)
    8000266e:	ff279be3          	bne	a5,s2,80002664 <reparent+0x2c>
      pp->parent = initproc;
    80002672:	000a3503          	ld	a0,0(s4)
    80002676:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002678:	00000097          	auipc	ra,0x0
    8000267c:	f4a080e7          	jalr	-182(ra) # 800025c2 <wakeup>
    80002680:	b7d5                	j	80002664 <reparent+0x2c>
}
    80002682:	70a2                	ld	ra,40(sp)
    80002684:	7402                	ld	s0,32(sp)
    80002686:	64e2                	ld	s1,24(sp)
    80002688:	6942                	ld	s2,16(sp)
    8000268a:	69a2                	ld	s3,8(sp)
    8000268c:	6a02                	ld	s4,0(sp)
    8000268e:	6145                	addi	sp,sp,48
    80002690:	8082                	ret

0000000080002692 <exit>:
{
    80002692:	7179                	addi	sp,sp,-48
    80002694:	f406                	sd	ra,40(sp)
    80002696:	f022                	sd	s0,32(sp)
    80002698:	ec26                	sd	s1,24(sp)
    8000269a:	e84a                	sd	s2,16(sp)
    8000269c:	e44e                	sd	s3,8(sp)
    8000269e:	e052                	sd	s4,0(sp)
    800026a0:	1800                	addi	s0,sp,48
    800026a2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800026a4:	fffff097          	auipc	ra,0xfffff
    800026a8:	7f0080e7          	jalr	2032(ra) # 80001e94 <myproc>
    800026ac:	89aa                	mv	s3,a0
  if (p == initproc)
    800026ae:	00009797          	auipc	a5,0x9
    800026b2:	97a7b783          	ld	a5,-1670(a5) # 8000b028 <initproc>
    800026b6:	0d050493          	addi	s1,a0,208
    800026ba:	15050913          	addi	s2,a0,336
    800026be:	02a79363          	bne	a5,a0,800026e4 <exit+0x52>
    panic("init exiting");
    800026c2:	00007517          	auipc	a0,0x7
    800026c6:	01e50513          	addi	a0,a0,30 # 800096e0 <digits+0x6a0>
    800026ca:	ffffe097          	auipc	ra,0xffffe
    800026ce:	e60080e7          	jalr	-416(ra) # 8000052a <panic>
      fileclose(f);
    800026d2:	00003097          	auipc	ra,0x3
    800026d6:	ce6080e7          	jalr	-794(ra) # 800053b8 <fileclose>
      p->ofile[fd] = 0;
    800026da:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800026de:	04a1                	addi	s1,s1,8
    800026e0:	01248563          	beq	s1,s2,800026ea <exit+0x58>
    if (p->ofile[fd])
    800026e4:	6088                	ld	a0,0(s1)
    800026e6:	f575                	bnez	a0,800026d2 <exit+0x40>
    800026e8:	bfdd                	j	800026de <exit+0x4c>
  removeSwapFile(p);  // Remove swap file of p
    800026ea:	854e                	mv	a0,s3
    800026ec:	00002097          	auipc	ra,0x2
    800026f0:	36a080e7          	jalr	874(ra) # 80004a56 <removeSwapFile>
  begin_op();
    800026f4:	00002097          	auipc	ra,0x2
    800026f8:	7f8080e7          	jalr	2040(ra) # 80004eec <begin_op>
  iput(p->cwd);
    800026fc:	1509b503          	ld	a0,336(s3)
    80002700:	00002097          	auipc	ra,0x2
    80002704:	cae080e7          	jalr	-850(ra) # 800043ae <iput>
  end_op();
    80002708:	00003097          	auipc	ra,0x3
    8000270c:	864080e7          	jalr	-1948(ra) # 80004f6c <end_op>
  p->cwd = 0;
    80002710:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002714:	00011497          	auipc	s1,0x11
    80002718:	ba448493          	addi	s1,s1,-1116 # 800132b8 <wait_lock>
    8000271c:	8526                	mv	a0,s1
    8000271e:	ffffe097          	auipc	ra,0xffffe
    80002722:	4a4080e7          	jalr	1188(ra) # 80000bc2 <acquire>
  reparent(p);
    80002726:	854e                	mv	a0,s3
    80002728:	00000097          	auipc	ra,0x0
    8000272c:	f10080e7          	jalr	-240(ra) # 80002638 <reparent>
  wakeup(p->parent);
    80002730:	0389b503          	ld	a0,56(s3)
    80002734:	00000097          	auipc	ra,0x0
    80002738:	e8e080e7          	jalr	-370(ra) # 800025c2 <wakeup>
  acquire(&p->lock);
    8000273c:	854e                	mv	a0,s3
    8000273e:	ffffe097          	auipc	ra,0xffffe
    80002742:	484080e7          	jalr	1156(ra) # 80000bc2 <acquire>
  p->xstate = status;
    80002746:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000274a:	4795                	li	a5,5
    8000274c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002750:	8526                	mv	a0,s1
    80002752:	ffffe097          	auipc	ra,0xffffe
    80002756:	524080e7          	jalr	1316(ra) # 80000c76 <release>
  sched();
    8000275a:	00000097          	auipc	ra,0x0
    8000275e:	bca080e7          	jalr	-1078(ra) # 80002324 <sched>
  panic("zombie exit");
    80002762:	00007517          	auipc	a0,0x7
    80002766:	f8e50513          	addi	a0,a0,-114 # 800096f0 <digits+0x6b0>
    8000276a:	ffffe097          	auipc	ra,0xffffe
    8000276e:	dc0080e7          	jalr	-576(ra) # 8000052a <panic>

0000000080002772 <kill>:
{
    80002772:	7179                	addi	sp,sp,-48
    80002774:	f406                	sd	ra,40(sp)
    80002776:	f022                	sd	s0,32(sp)
    80002778:	ec26                	sd	s1,24(sp)
    8000277a:	e84a                	sd	s2,16(sp)
    8000277c:	e44e                	sd	s3,8(sp)
    8000277e:	1800                	addi	s0,sp,48
    80002780:	892a                	mv	s2,a0
  for (p = proc; p < &proc[NPROC]; p++)
    80002782:	00011497          	auipc	s1,0x11
    80002786:	f4e48493          	addi	s1,s1,-178 # 800136d0 <proc>
    8000278a:	0001f997          	auipc	s3,0x1f
    8000278e:	14698993          	addi	s3,s3,326 # 800218d0 <tickslock>
    acquire(&p->lock);
    80002792:	8526                	mv	a0,s1
    80002794:	ffffe097          	auipc	ra,0xffffe
    80002798:	42e080e7          	jalr	1070(ra) # 80000bc2 <acquire>
    if (p->pid == pid)
    8000279c:	589c                	lw	a5,48(s1)
    8000279e:	01278d63          	beq	a5,s2,800027b8 <kill+0x46>
    release(&p->lock);
    800027a2:	8526                	mv	a0,s1
    800027a4:	ffffe097          	auipc	ra,0xffffe
    800027a8:	4d2080e7          	jalr	1234(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800027ac:	38848493          	addi	s1,s1,904
    800027b0:	ff3491e3          	bne	s1,s3,80002792 <kill+0x20>
  return -1;
    800027b4:	557d                	li	a0,-1
    800027b6:	a829                	j	800027d0 <kill+0x5e>
      p->killed = 1;
    800027b8:	4785                	li	a5,1
    800027ba:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800027bc:	4c98                	lw	a4,24(s1)
    800027be:	4789                	li	a5,2
    800027c0:	00f70f63          	beq	a4,a5,800027de <kill+0x6c>
      release(&p->lock);
    800027c4:	8526                	mv	a0,s1
    800027c6:	ffffe097          	auipc	ra,0xffffe
    800027ca:	4b0080e7          	jalr	1200(ra) # 80000c76 <release>
      return 0;
    800027ce:	4501                	li	a0,0
}
    800027d0:	70a2                	ld	ra,40(sp)
    800027d2:	7402                	ld	s0,32(sp)
    800027d4:	64e2                	ld	s1,24(sp)
    800027d6:	6942                	ld	s2,16(sp)
    800027d8:	69a2                	ld	s3,8(sp)
    800027da:	6145                	addi	sp,sp,48
    800027dc:	8082                	ret
        p->state = RUNNABLE;
    800027de:	478d                	li	a5,3
    800027e0:	cc9c                	sw	a5,24(s1)
    800027e2:	b7cd                	j	800027c4 <kill+0x52>

00000000800027e4 <either_copyout>:
{
    800027e4:	7179                	addi	sp,sp,-48
    800027e6:	f406                	sd	ra,40(sp)
    800027e8:	f022                	sd	s0,32(sp)
    800027ea:	ec26                	sd	s1,24(sp)
    800027ec:	e84a                	sd	s2,16(sp)
    800027ee:	e44e                	sd	s3,8(sp)
    800027f0:	e052                	sd	s4,0(sp)
    800027f2:	1800                	addi	s0,sp,48
    800027f4:	84aa                	mv	s1,a0
    800027f6:	892e                	mv	s2,a1
    800027f8:	89b2                	mv	s3,a2
    800027fa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027fc:	fffff097          	auipc	ra,0xfffff
    80002800:	698080e7          	jalr	1688(ra) # 80001e94 <myproc>
  if (user_dst)
    80002804:	c08d                	beqz	s1,80002826 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002806:	86d2                	mv	a3,s4
    80002808:	864e                	mv	a2,s3
    8000280a:	85ca                	mv	a1,s2
    8000280c:	6928                	ld	a0,80(a0)
    8000280e:	fffff097          	auipc	ra,0xfffff
    80002812:	ba6080e7          	jalr	-1114(ra) # 800013b4 <copyout>
}
    80002816:	70a2                	ld	ra,40(sp)
    80002818:	7402                	ld	s0,32(sp)
    8000281a:	64e2                	ld	s1,24(sp)
    8000281c:	6942                	ld	s2,16(sp)
    8000281e:	69a2                	ld	s3,8(sp)
    80002820:	6a02                	ld	s4,0(sp)
    80002822:	6145                	addi	sp,sp,48
    80002824:	8082                	ret
    memmove((char *)dst, src, len);
    80002826:	000a061b          	sext.w	a2,s4
    8000282a:	85ce                	mv	a1,s3
    8000282c:	854a                	mv	a0,s2
    8000282e:	ffffe097          	auipc	ra,0xffffe
    80002832:	4ec080e7          	jalr	1260(ra) # 80000d1a <memmove>
    return 0;
    80002836:	8526                	mv	a0,s1
    80002838:	bff9                	j	80002816 <either_copyout+0x32>

000000008000283a <either_copyin>:
{
    8000283a:	7179                	addi	sp,sp,-48
    8000283c:	f406                	sd	ra,40(sp)
    8000283e:	f022                	sd	s0,32(sp)
    80002840:	ec26                	sd	s1,24(sp)
    80002842:	e84a                	sd	s2,16(sp)
    80002844:	e44e                	sd	s3,8(sp)
    80002846:	e052                	sd	s4,0(sp)
    80002848:	1800                	addi	s0,sp,48
    8000284a:	892a                	mv	s2,a0
    8000284c:	84ae                	mv	s1,a1
    8000284e:	89b2                	mv	s3,a2
    80002850:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002852:	fffff097          	auipc	ra,0xfffff
    80002856:	642080e7          	jalr	1602(ra) # 80001e94 <myproc>
  if (user_src)
    8000285a:	c08d                	beqz	s1,8000287c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000285c:	86d2                	mv	a3,s4
    8000285e:	864e                	mv	a2,s3
    80002860:	85ca                	mv	a1,s2
    80002862:	6928                	ld	a0,80(a0)
    80002864:	fffff097          	auipc	ra,0xfffff
    80002868:	c14080e7          	jalr	-1004(ra) # 80001478 <copyin>
}
    8000286c:	70a2                	ld	ra,40(sp)
    8000286e:	7402                	ld	s0,32(sp)
    80002870:	64e2                	ld	s1,24(sp)
    80002872:	6942                	ld	s2,16(sp)
    80002874:	69a2                	ld	s3,8(sp)
    80002876:	6a02                	ld	s4,0(sp)
    80002878:	6145                	addi	sp,sp,48
    8000287a:	8082                	ret
    memmove(dst, (char *)src, len);
    8000287c:	000a061b          	sext.w	a2,s4
    80002880:	85ce                	mv	a1,s3
    80002882:	854a                	mv	a0,s2
    80002884:	ffffe097          	auipc	ra,0xffffe
    80002888:	496080e7          	jalr	1174(ra) # 80000d1a <memmove>
    return 0;
    8000288c:	8526                	mv	a0,s1
    8000288e:	bff9                	j	8000286c <either_copyin+0x32>

0000000080002890 <procdump>:
{
    80002890:	715d                	addi	sp,sp,-80
    80002892:	e486                	sd	ra,72(sp)
    80002894:	e0a2                	sd	s0,64(sp)
    80002896:	fc26                	sd	s1,56(sp)
    80002898:	f84a                	sd	s2,48(sp)
    8000289a:	f44e                	sd	s3,40(sp)
    8000289c:	f052                	sd	s4,32(sp)
    8000289e:	ec56                	sd	s5,24(sp)
    800028a0:	e85a                	sd	s6,16(sp)
    800028a2:	e45e                	sd	s7,8(sp)
    800028a4:	0880                	addi	s0,sp,80
  printf("\n");
    800028a6:	00007517          	auipc	a0,0x7
    800028aa:	05a50513          	addi	a0,a0,90 # 80009900 <digits+0x8c0>
    800028ae:	ffffe097          	auipc	ra,0xffffe
    800028b2:	cc6080e7          	jalr	-826(ra) # 80000574 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800028b6:	00011497          	auipc	s1,0x11
    800028ba:	f7248493          	addi	s1,s1,-142 # 80013828 <proc+0x158>
    800028be:	0001f917          	auipc	s2,0x1f
    800028c2:	16a90913          	addi	s2,s2,362 # 80021a28 <bcache+0x140>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028c6:	4b15                	li	s6,5
      state = "???";
    800028c8:	00007997          	auipc	s3,0x7
    800028cc:	e3898993          	addi	s3,s3,-456 # 80009700 <digits+0x6c0>
    printf("%d %s %s", p->pid, state, p->name);
    800028d0:	00007a97          	auipc	s5,0x7
    800028d4:	e38a8a93          	addi	s5,s5,-456 # 80009708 <digits+0x6c8>
    printf("\n");
    800028d8:	00007a17          	auipc	s4,0x7
    800028dc:	028a0a13          	addi	s4,s4,40 # 80009900 <digits+0x8c0>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028e0:	00007b97          	auipc	s7,0x7
    800028e4:	070b8b93          	addi	s7,s7,112 # 80009950 <states.0>
    800028e8:	a00d                	j	8000290a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800028ea:	ed86a583          	lw	a1,-296(a3)
    800028ee:	8556                	mv	a0,s5
    800028f0:	ffffe097          	auipc	ra,0xffffe
    800028f4:	c84080e7          	jalr	-892(ra) # 80000574 <printf>
    printf("\n");
    800028f8:	8552                	mv	a0,s4
    800028fa:	ffffe097          	auipc	ra,0xffffe
    800028fe:	c7a080e7          	jalr	-902(ra) # 80000574 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002902:	38848493          	addi	s1,s1,904
    80002906:	03248263          	beq	s1,s2,8000292a <procdump+0x9a>
    if (p->state == UNUSED)
    8000290a:	86a6                	mv	a3,s1
    8000290c:	ec04a783          	lw	a5,-320(s1)
    80002910:	dbed                	beqz	a5,80002902 <procdump+0x72>
      state = "???";
    80002912:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002914:	fcfb6be3          	bltu	s6,a5,800028ea <procdump+0x5a>
    80002918:	02079713          	slli	a4,a5,0x20
    8000291c:	01d75793          	srli	a5,a4,0x1d
    80002920:	97de                	add	a5,a5,s7
    80002922:	6390                	ld	a2,0(a5)
    80002924:	f279                	bnez	a2,800028ea <procdump+0x5a>
      state = "???";
    80002926:	864e                	mv	a2,s3
    80002928:	b7c9                	j	800028ea <procdump+0x5a>
}
    8000292a:	60a6                	ld	ra,72(sp)
    8000292c:	6406                	ld	s0,64(sp)
    8000292e:	74e2                	ld	s1,56(sp)
    80002930:	7942                	ld	s2,48(sp)
    80002932:	79a2                	ld	s3,40(sp)
    80002934:	7a02                	ld	s4,32(sp)
    80002936:	6ae2                	ld	s5,24(sp)
    80002938:	6b42                	ld	s6,16(sp)
    8000293a:	6ba2                	ld	s7,8(sp)
    8000293c:	6161                	addi	sp,sp,80
    8000293e:	8082                	ret

0000000080002940 <get_next_free_space>:
{
    80002940:	1141                	addi	sp,sp,-16
    80002942:	e422                	sd	s0,8(sp)
    80002944:	0800                	addi	s0,sp,16
    if (!(free_spaces & (1 << i)))
    80002946:	0005071b          	sext.w	a4,a0
    8000294a:	8905                	andi	a0,a0,1
    8000294c:	cd11                	beqz	a0,80002968 <get_next_free_space+0x28>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000294e:	4505                	li	a0,1
    80002950:	46c1                	li	a3,16
    if (!(free_spaces & (1 << i)))
    80002952:	40a757bb          	sraw	a5,a4,a0
    80002956:	8b85                	andi	a5,a5,1
    80002958:	c789                	beqz	a5,80002962 <get_next_free_space+0x22>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000295a:	2505                	addiw	a0,a0,1
    8000295c:	fed51be3          	bne	a0,a3,80002952 <get_next_free_space+0x12>
  return -1;
    80002960:	557d                	li	a0,-1
}
    80002962:	6422                	ld	s0,8(sp)
    80002964:	0141                	addi	sp,sp,16
    80002966:	8082                	ret
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002968:	4501                	li	a0,0
    8000296a:	bfe5                	j	80002962 <get_next_free_space+0x22>

000000008000296c <get_index_in_page_info_array>:
{
    8000296c:	1101                	addi	sp,sp,-32
    8000296e:	ec06                	sd	ra,24(sp)
    80002970:	e822                	sd	s0,16(sp)
    80002972:	e426                	sd	s1,8(sp)
    80002974:	1000                	addi	s0,sp,32
  uint64 rva = PGROUNDDOWN(va);
    80002976:	77fd                	lui	a5,0xfffff
    80002978:	8d7d                	and	a0,a0,a5
  for (int i = 0; i < MAX_PSYC_PAGES;i++)
    8000297a:	4481                	li	s1,0
    8000297c:	4741                	li	a4,16
    if (po->va == rva)
    8000297e:	619c                	ld	a5,0(a1)
    80002980:	02a78563          	beq	a5,a0,800029aa <get_index_in_page_info_array+0x3e>
  for (int i = 0; i < MAX_PSYC_PAGES;i++)
    80002984:	2485                	addiw	s1,s1,1
    80002986:	05c1                	addi	a1,a1,16
    80002988:	fee49be3          	bne	s1,a4,8000297e <get_index_in_page_info_array+0x12>
  printf("get_index_in_page_info_array  :(  not-found\n");
    8000298c:	00007517          	auipc	a0,0x7
    80002990:	dbc50513          	addi	a0,a0,-580 # 80009748 <digits+0x708>
    80002994:	ffffe097          	auipc	ra,0xffffe
    80002998:	be0080e7          	jalr	-1056(ra) # 80000574 <printf>
  return -1; // if not found return null
    8000299c:	54fd                	li	s1,-1
}
    8000299e:	8526                	mv	a0,s1
    800029a0:	60e2                	ld	ra,24(sp)
    800029a2:	6442                	ld	s0,16(sp)
    800029a4:	64a2                	ld	s1,8(sp)
    800029a6:	6105                	addi	sp,sp,32
    800029a8:	8082                	ret
      printf("get_index_in_page_info_array  :)  found\n");
    800029aa:	00007517          	auipc	a0,0x7
    800029ae:	d6e50513          	addi	a0,a0,-658 # 80009718 <digits+0x6d8>
    800029b2:	ffffe097          	auipc	ra,0xffffe
    800029b6:	bc2080e7          	jalr	-1086(ra) # 80000574 <printf>
      return i;
    800029ba:	b7d5                	j	8000299e <get_index_in_page_info_array+0x32>

00000000800029bc <page_out>:
{
    800029bc:	7179                	addi	sp,sp,-48
    800029be:	f406                	sd	ra,40(sp)
    800029c0:	f022                	sd	s0,32(sp)
    800029c2:	ec26                	sd	s1,24(sp)
    800029c4:	e84a                	sd	s2,16(sp)
    800029c6:	e44e                	sd	s3,8(sp)
    800029c8:	1800                	addi	s0,sp,48
    800029ca:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029cc:	fffff097          	auipc	ra,0xfffff
    800029d0:	4c8080e7          	jalr	1224(ra) # 80001e94 <myproc>
    800029d4:	892a                	mv	s2,a0
  uint64 rva = PGROUNDDOWN(va);
    800029d6:	757d                	lui	a0,0xfffff
    800029d8:	8ce9                	and	s1,s1,a0
  uint64 pa = walkaddr(p->pagetable, rva, 1); // return with pte valid = 0
    800029da:	4605                	li	a2,1
    800029dc:	85a6                	mv	a1,s1
    800029de:	05093503          	ld	a0,80(s2)
    800029e2:	ffffe097          	auipc	ra,0xffffe
    800029e6:	66a080e7          	jalr	1642(ra) # 8000104c <walkaddr>
    800029ea:	89aa                	mv	s3,a0
  int page_index = insert_page_to_swap_file(rva);
    800029ec:	8526                	mv	a0,s1
    800029ee:	fffff097          	auipc	ra,0xfffff
    800029f2:	bd0080e7          	jalr	-1072(ra) # 800015be <insert_page_to_swap_file>
  if (page_index < 0 || page_index >= MAX_PSYC_PAGES)
    800029f6:	0005079b          	sext.w	a5,a0
    800029fa:	473d                	li	a4,15
    800029fc:	04f76363          	bltu	a4,a5,80002a42 <page_out+0x86>
    80002a00:	00c5161b          	slliw	a2,a0,0xc
  writeToSwapFile(p, (char *)pa, start_offset, PGSIZE); // Write page to swap file
    80002a04:	6685                	lui	a3,0x1
    80002a06:	2601                	sext.w	a2,a2
    80002a08:	85ce                	mv	a1,s3
    80002a0a:	854a                	mv	a0,s2
    80002a0c:	00002097          	auipc	ra,0x2
    80002a10:	2b2080e7          	jalr	690(ra) # 80004cbe <writeToSwapFile>
  remove_page_from_physical_memory(rva);
    80002a14:	8526                	mv	a0,s1
    80002a16:	fffff097          	auipc	ra,0xfffff
    80002a1a:	cfe080e7          	jalr	-770(ra) # 80001714 <remove_page_from_physical_memory>
  p->physical_pages_num--;
    80002a1e:	17092783          	lw	a5,368(s2)
    80002a22:	37fd                	addiw	a5,a5,-1
    80002a24:	16f92823          	sw	a5,368(s2)
  kfree((void *)pa);
    80002a28:	854e                	mv	a0,s3
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	fac080e7          	jalr	-84(ra) # 800009d6 <kfree>
}
    80002a32:	854e                	mv	a0,s3
    80002a34:	70a2                	ld	ra,40(sp)
    80002a36:	7402                	ld	s0,32(sp)
    80002a38:	64e2                	ld	s1,24(sp)
    80002a3a:	6942                	ld	s2,16(sp)
    80002a3c:	69a2                	ld	s3,8(sp)
    80002a3e:	6145                	addi	sp,sp,48
    80002a40:	8082                	ret
    panic("fadge no free index in page_out");
    80002a42:	00007517          	auipc	a0,0x7
    80002a46:	d3650513          	addi	a0,a0,-714 # 80009778 <digits+0x738>
    80002a4a:	ffffe097          	auipc	ra,0xffffe
    80002a4e:	ae0080e7          	jalr	-1312(ra) # 8000052a <panic>

0000000080002a52 <page_in>:
{
    80002a52:	7179                	addi	sp,sp,-48
    80002a54:	f406                	sd	ra,40(sp)
    80002a56:	f022                	sd	s0,32(sp)
    80002a58:	ec26                	sd	s1,24(sp)
    80002a5a:	e84a                	sd	s2,16(sp)
    80002a5c:	e44e                	sd	s3,8(sp)
    80002a5e:	e052                	sd	s4,0(sp)
    80002a60:	1800                	addi	s0,sp,48
    80002a62:	84aa                	mv	s1,a0
    80002a64:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80002a66:	fffff097          	auipc	ra,0xfffff
    80002a6a:	42e080e7          	jalr	1070(ra) # 80001e94 <myproc>
    80002a6e:	892a                	mv	s2,a0
  uint64 rva = PGROUNDDOWN(va);
    80002a70:	757d                	lui	a0,0xfffff
    80002a72:	8ce9                	and	s1,s1,a0
  int swap_old_index = remove_page_from_swap_file(rva);
    80002a74:	8526                	mv	a0,s1
    80002a76:	fffff097          	auipc	ra,0xfffff
    80002a7a:	d22080e7          	jalr	-734(ra) # 80001798 <remove_page_from_swap_file>
  if(swap_old_index <0)
    80002a7e:	06054963          	bltz	a0,80002af0 <page_in+0x9e>
    80002a82:	8a2a                	mv	s4,a0
  int physc_new_index = insert_page_to_physical_memory(rva);
    80002a84:	8526                	mv	a0,s1
    80002a86:	fffff097          	auipc	ra,0xfffff
    80002a8a:	bd2080e7          	jalr	-1070(ra) # 80001658 <insert_page_to_physical_memory>
  p->physical_pages_num++;
    80002a8e:	17092783          	lw	a5,368(s2)
    80002a92:	2785                	addiw	a5,a5,1
    80002a94:	16f92823          	sw	a5,368(s2)
  void *pa = kalloc();
    80002a98:	ffffe097          	auipc	ra,0xffffe
    80002a9c:	03a080e7          	jalr	58(ra) # 80000ad2 <kalloc>
    80002aa0:	84aa                	mv	s1,a0
  if (!pa)
    80002aa2:	cd39                	beqz	a0,80002b00 <page_in+0xae>
  memset(pa, 0, PGSIZE);
    80002aa4:	6605                	lui	a2,0x1
    80002aa6:	4581                	li	a1,0
    80002aa8:	ffffe097          	auipc	ra,0xffffe
    80002aac:	216080e7          	jalr	534(ra) # 80000cbe <memset>
  readFromSwapFile(p, pa, start_offset, PGSIZE);
    80002ab0:	6685                	lui	a3,0x1
    80002ab2:	00ca161b          	slliw	a2,s4,0xc
    80002ab6:	85a6                	mv	a1,s1
    80002ab8:	854a                	mv	a0,s2
    80002aba:	00002097          	auipc	ra,0x2
    80002abe:	228080e7          	jalr	552(ra) # 80004ce2 <readFromSwapFile>
  if (!(*pte & PTE_PG) || *pte & PTE_V)
    80002ac2:	0009b783          	ld	a5,0(s3)
    80002ac6:	2017f793          	andi	a5,a5,513
    80002aca:	20000713          	li	a4,512
    80002ace:	04e79163          	bne	a5,a4,80002b10 <page_in+0xbe>
  *pte = PA2PTE(pa) ^ PTE_V ^ PTE_PG;
    80002ad2:	80b1                	srli	s1,s1,0xc
    80002ad4:	04aa                	slli	s1,s1,0xa
    80002ad6:	2014c493          	xori	s1,s1,513
    80002ada:	0099b023          	sd	s1,0(s3)
}
    80002ade:	854e                	mv	a0,s3
    80002ae0:	70a2                	ld	ra,40(sp)
    80002ae2:	7402                	ld	s0,32(sp)
    80002ae4:	64e2                	ld	s1,24(sp)
    80002ae6:	6942                	ld	s2,16(sp)
    80002ae8:	69a2                	ld	s3,8(sp)
    80002aea:	6a02                	ld	s4,0(sp)
    80002aec:	6145                	addi	sp,sp,48
    80002aee:	8082                	ret
    panic("page_in: index in swap file not found");
    80002af0:	00007517          	auipc	a0,0x7
    80002af4:	ca850513          	addi	a0,a0,-856 # 80009798 <digits+0x758>
    80002af8:	ffffe097          	auipc	ra,0xffffe
    80002afc:	a32080e7          	jalr	-1486(ra) # 8000052a <panic>
    panic("page in: fack kalloc failed in page_in");
    80002b00:	00007517          	auipc	a0,0x7
    80002b04:	cc050513          	addi	a0,a0,-832 # 800097c0 <digits+0x780>
    80002b08:	ffffe097          	auipc	ra,0xffffe
    80002b0c:	a22080e7          	jalr	-1502(ra) # 8000052a <panic>
    panic("page in: page out flag was off or valid flag was on");
    80002b10:	00007517          	auipc	a0,0x7
    80002b14:	cd850513          	addi	a0,a0,-808 # 800097e8 <digits+0x7a8>
    80002b18:	ffffe097          	auipc	ra,0xffffe
    80002b1c:	a12080e7          	jalr	-1518(ra) # 8000052a <panic>

0000000080002b20 <copyFilesInfo>:
{
    80002b20:	7139                	addi	sp,sp,-64
    80002b22:	fc06                	sd	ra,56(sp)
    80002b24:	f822                	sd	s0,48(sp)
    80002b26:	f426                	sd	s1,40(sp)
    80002b28:	f04a                	sd	s2,32(sp)
    80002b2a:	ec4e                	sd	s3,24(sp)
    80002b2c:	e852                	sd	s4,16(sp)
    80002b2e:	e456                	sd	s5,8(sp)
    80002b30:	e05a                	sd	s6,0(sp)
    80002b32:	0080                	addi	s0,sp,64
    80002b34:	89aa                	mv	s3,a0
    80002b36:	84ae                	mv	s1,a1
  if (!(temp_page = kalloc()))
    80002b38:	ffffe097          	auipc	ra,0xffffe
    80002b3c:	f9a080e7          	jalr	-102(ra) # 80000ad2 <kalloc>
    80002b40:	8b2a                	mv	s6,a0
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002b42:	4901                	li	s2,0
    80002b44:	4a41                	li	s4,16
  if (!(temp_page = kalloc()))
    80002b46:	e505                	bnez	a0,80002b6e <copyFilesInfo+0x4e>
    panic("copyFilesInfo: kalloc failed");
    80002b48:	00007517          	auipc	a0,0x7
    80002b4c:	cd850513          	addi	a0,a0,-808 # 80009820 <digits+0x7e0>
    80002b50:	ffffe097          	auipc	ra,0xffffe
    80002b54:	9da080e7          	jalr	-1574(ra) # 8000052a <panic>
        panic("copyFilesInfo: failed read");
    80002b58:	00007517          	auipc	a0,0x7
    80002b5c:	ce850513          	addi	a0,a0,-792 # 80009840 <digits+0x800>
    80002b60:	ffffe097          	auipc	ra,0xffffe
    80002b64:	9ca080e7          	jalr	-1590(ra) # 8000052a <panic>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002b68:	2905                	addiw	s2,s2,1
    80002b6a:	05490663          	beq	s2,s4,80002bb6 <copyFilesInfo+0x96>
    if (p->pages_swap_info.free_spaces & (1 << i))
    80002b6e:	1789d783          	lhu	a5,376(s3)
    80002b72:	4127d7bb          	sraw	a5,a5,s2
    80002b76:	8b85                	andi	a5,a5,1
    80002b78:	dbe5                	beqz	a5,80002b68 <copyFilesInfo+0x48>
      int res = readFromSwapFile(p, (char *)temp_page, i * PGSIZE, PGSIZE);
    80002b7a:	00c91a9b          	slliw	s5,s2,0xc
    80002b7e:	6685                	lui	a3,0x1
    80002b80:	8656                	mv	a2,s5
    80002b82:	85da                	mv	a1,s6
    80002b84:	854e                	mv	a0,s3
    80002b86:	00002097          	auipc	ra,0x2
    80002b8a:	15c080e7          	jalr	348(ra) # 80004ce2 <readFromSwapFile>
      if (res < 0)
    80002b8e:	fc0545e3          	bltz	a0,80002b58 <copyFilesInfo+0x38>
      res = writeToSwapFile(np, temp_page, i * PGSIZE, PGSIZE);
    80002b92:	6685                	lui	a3,0x1
    80002b94:	8656                	mv	a2,s5
    80002b96:	85da                	mv	a1,s6
    80002b98:	8526                	mv	a0,s1
    80002b9a:	00002097          	auipc	ra,0x2
    80002b9e:	124080e7          	jalr	292(ra) # 80004cbe <writeToSwapFile>
      if (res < 0)
    80002ba2:	fc0553e3          	bgez	a0,80002b68 <copyFilesInfo+0x48>
        panic("copyFilesInfo: faild write ");
    80002ba6:	00007517          	auipc	a0,0x7
    80002baa:	cba50513          	addi	a0,a0,-838 # 80009860 <digits+0x820>
    80002bae:	ffffe097          	auipc	ra,0xffffe
    80002bb2:	97c080e7          	jalr	-1668(ra) # 8000052a <panic>
  kfree(temp_page);
    80002bb6:	855a                	mv	a0,s6
    80002bb8:	ffffe097          	auipc	ra,0xffffe
    80002bbc:	e1e080e7          	jalr	-482(ra) # 800009d6 <kfree>
  np->pages_swap_info.free_spaces = p->pages_swap_info.free_spaces;
    80002bc0:	1789d783          	lhu	a5,376(s3)
    80002bc4:	16f49c23          	sh	a5,376(s1)
  np->pages_physc_info.free_spaces = p->pages_physc_info.free_spaces;
    80002bc8:	2809d783          	lhu	a5,640(s3)
    80002bcc:	28f49023          	sh	a5,640(s1)
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002bd0:	18098793          	addi	a5,s3,384
    80002bd4:	18048593          	addi	a1,s1,384
    80002bd8:	28098993          	addi	s3,s3,640
    np->pages_swap_info.pages[i] = p->pages_swap_info.pages[i];
    80002bdc:	6398                	ld	a4,0(a5)
    80002bde:	e198                	sd	a4,0(a1)
    80002be0:	6798                	ld	a4,8(a5)
    80002be2:	e598                	sd	a4,8(a1)
    np->pages_physc_info.pages[i] = p->pages_physc_info.pages[i];
    80002be4:	1087b703          	ld	a4,264(a5) # fffffffffffff108 <end+0xffffffff7ffcf108>
    80002be8:	10e5b423          	sd	a4,264(a1)
    80002bec:	1107b703          	ld	a4,272(a5)
    80002bf0:	10e5b823          	sd	a4,272(a1)
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002bf4:	07c1                	addi	a5,a5,16
    80002bf6:	05c1                	addi	a1,a1,16
    80002bf8:	ff3792e3          	bne	a5,s3,80002bdc <copyFilesInfo+0xbc>
}
    80002bfc:	70e2                	ld	ra,56(sp)
    80002bfe:	7442                	ld	s0,48(sp)
    80002c00:	74a2                	ld	s1,40(sp)
    80002c02:	7902                	ld	s2,32(sp)
    80002c04:	69e2                	ld	s3,24(sp)
    80002c06:	6a42                	ld	s4,16(sp)
    80002c08:	6aa2                	ld	s5,8(sp)
    80002c0a:	6b02                	ld	s6,0(sp)
    80002c0c:	6121                	addi	sp,sp,64
    80002c0e:	8082                	ret

0000000080002c10 <fork>:
{
    80002c10:	7139                	addi	sp,sp,-64
    80002c12:	fc06                	sd	ra,56(sp)
    80002c14:	f822                	sd	s0,48(sp)
    80002c16:	f426                	sd	s1,40(sp)
    80002c18:	f04a                	sd	s2,32(sp)
    80002c1a:	ec4e                	sd	s3,24(sp)
    80002c1c:	e852                	sd	s4,16(sp)
    80002c1e:	e456                	sd	s5,8(sp)
    80002c20:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002c22:	fffff097          	auipc	ra,0xfffff
    80002c26:	272080e7          	jalr	626(ra) # 80001e94 <myproc>
    80002c2a:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80002c2c:	fffff097          	auipc	ra,0xfffff
    80002c30:	472080e7          	jalr	1138(ra) # 8000209e <allocproc>
    80002c34:	14050563          	beqz	a0,80002d7e <fork+0x16e>
    80002c38:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002c3a:	048ab603          	ld	a2,72(s5)
    80002c3e:	692c                	ld	a1,80(a0)
    80002c40:	050ab503          	ld	a0,80(s5)
    80002c44:	fffff097          	auipc	ra,0xfffff
    80002c48:	fcc080e7          	jalr	-52(ra) # 80001c10 <uvmcopy>
    80002c4c:	04054863          	bltz	a0,80002c9c <fork+0x8c>
  np->sz = p->sz;
    80002c50:	048ab783          	ld	a5,72(s5)
    80002c54:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80002c58:	058ab683          	ld	a3,88(s5)
    80002c5c:	87b6                	mv	a5,a3
    80002c5e:	0589b703          	ld	a4,88(s3)
    80002c62:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    80002c66:	0007b803          	ld	a6,0(a5)
    80002c6a:	6788                	ld	a0,8(a5)
    80002c6c:	6b8c                	ld	a1,16(a5)
    80002c6e:	6f90                	ld	a2,24(a5)
    80002c70:	01073023          	sd	a6,0(a4)
    80002c74:	e708                	sd	a0,8(a4)
    80002c76:	eb0c                	sd	a1,16(a4)
    80002c78:	ef10                	sd	a2,24(a4)
    80002c7a:	02078793          	addi	a5,a5,32
    80002c7e:	02070713          	addi	a4,a4,32
    80002c82:	fed792e3          	bne	a5,a3,80002c66 <fork+0x56>
  np->trapframe->a0 = 0;
    80002c86:	0589b783          	ld	a5,88(s3)
    80002c8a:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80002c8e:	0d0a8493          	addi	s1,s5,208
    80002c92:	0d098913          	addi	s2,s3,208
    80002c96:	150a8a13          	addi	s4,s5,336
    80002c9a:	a00d                	j	80002cbc <fork+0xac>
    freeproc(np);
    80002c9c:	854e                	mv	a0,s3
    80002c9e:	fffff097          	auipc	ra,0xfffff
    80002ca2:	3a8080e7          	jalr	936(ra) # 80002046 <freeproc>
    release(&np->lock);
    80002ca6:	854e                	mv	a0,s3
    80002ca8:	ffffe097          	auipc	ra,0xffffe
    80002cac:	fce080e7          	jalr	-50(ra) # 80000c76 <release>
    return -1;
    80002cb0:	597d                	li	s2,-1
    80002cb2:	a06d                	j	80002d5c <fork+0x14c>
  for (i = 0; i < NOFILE; i++)
    80002cb4:	04a1                	addi	s1,s1,8
    80002cb6:	0921                	addi	s2,s2,8
    80002cb8:	01448b63          	beq	s1,s4,80002cce <fork+0xbe>
    if (p->ofile[i])
    80002cbc:	6088                	ld	a0,0(s1)
    80002cbe:	d97d                	beqz	a0,80002cb4 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80002cc0:	00002097          	auipc	ra,0x2
    80002cc4:	6a6080e7          	jalr	1702(ra) # 80005366 <filedup>
    80002cc8:	00a93023          	sd	a0,0(s2)
    80002ccc:	b7e5                	j	80002cb4 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80002cce:	150ab503          	ld	a0,336(s5)
    80002cd2:	00001097          	auipc	ra,0x1
    80002cd6:	4e4080e7          	jalr	1252(ra) # 800041b6 <idup>
    80002cda:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002cde:	4641                	li	a2,16
    80002ce0:	158a8593          	addi	a1,s5,344
    80002ce4:	15898513          	addi	a0,s3,344
    80002ce8:	ffffe097          	auipc	ra,0xffffe
    80002cec:	128080e7          	jalr	296(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80002cf0:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002cf4:	854e                	mv	a0,s3
    80002cf6:	ffffe097          	auipc	ra,0xffffe
    80002cfa:	f80080e7          	jalr	-128(ra) # 80000c76 <release>
  createSwapFile(np);
    80002cfe:	854e                	mv	a0,s3
    80002d00:	00002097          	auipc	ra,0x2
    80002d04:	f0e080e7          	jalr	-242(ra) # 80004c0e <createSwapFile>
  if(p->pid >2 )
    80002d08:	030aa703          	lw	a4,48(s5)
    80002d0c:	4789                	li	a5,2
    80002d0e:	06e7c163          	blt	a5,a4,80002d70 <fork+0x160>
  np->physical_pages_num = p->physical_pages_num;
    80002d12:	170aa783          	lw	a5,368(s5)
    80002d16:	16f9a823          	sw	a5,368(s3)
  np->total_pages_num = p->total_pages_num;
    80002d1a:	174aa783          	lw	a5,372(s5)
    80002d1e:	16f9aa23          	sw	a5,372(s3)
  acquire(&wait_lock);
    80002d22:	00010497          	auipc	s1,0x10
    80002d26:	59648493          	addi	s1,s1,1430 # 800132b8 <wait_lock>
    80002d2a:	8526                	mv	a0,s1
    80002d2c:	ffffe097          	auipc	ra,0xffffe
    80002d30:	e96080e7          	jalr	-362(ra) # 80000bc2 <acquire>
  np->parent = p;
    80002d34:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002d38:	8526                	mv	a0,s1
    80002d3a:	ffffe097          	auipc	ra,0xffffe
    80002d3e:	f3c080e7          	jalr	-196(ra) # 80000c76 <release>
  acquire(&np->lock);
    80002d42:	854e                	mv	a0,s3
    80002d44:	ffffe097          	auipc	ra,0xffffe
    80002d48:	e7e080e7          	jalr	-386(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80002d4c:	478d                	li	a5,3
    80002d4e:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002d52:	854e                	mv	a0,s3
    80002d54:	ffffe097          	auipc	ra,0xffffe
    80002d58:	f22080e7          	jalr	-222(ra) # 80000c76 <release>
}
    80002d5c:	854a                	mv	a0,s2
    80002d5e:	70e2                	ld	ra,56(sp)
    80002d60:	7442                	ld	s0,48(sp)
    80002d62:	74a2                	ld	s1,40(sp)
    80002d64:	7902                	ld	s2,32(sp)
    80002d66:	69e2                	ld	s3,24(sp)
    80002d68:	6a42                	ld	s4,16(sp)
    80002d6a:	6aa2                	ld	s5,8(sp)
    80002d6c:	6121                	addi	sp,sp,64
    80002d6e:	8082                	ret
    copyFilesInfo(p, np);
    80002d70:	85ce                	mv	a1,s3
    80002d72:	8556                	mv	a0,s5
    80002d74:	00000097          	auipc	ra,0x0
    80002d78:	dac080e7          	jalr	-596(ra) # 80002b20 <copyFilesInfo>
    80002d7c:	bf59                	j	80002d12 <fork+0x102>
    return -1;
    80002d7e:	597d                	li	s2,-1
    80002d80:	bff1                	j	80002d5c <fork+0x14c>

0000000080002d82 <NFUA_compare>:
  if (!pg1 || !pg2)
    80002d82:	c511                	beqz	a0,80002d8e <NFUA_compare+0xc>
    80002d84:	c589                	beqz	a1,80002d8e <NFUA_compare+0xc>
  return pg1->aging_counter - pg2->aging_counter;
    80002d86:	4508                	lw	a0,8(a0)
    80002d88:	459c                	lw	a5,8(a1)
}
    80002d8a:	9d1d                	subw	a0,a0,a5
    80002d8c:	8082                	ret
{
    80002d8e:	1141                	addi	sp,sp,-16
    80002d90:	e406                	sd	ra,8(sp)
    80002d92:	e022                	sd	s0,0(sp)
    80002d94:	0800                	addi	s0,sp,16
    panic("NFUA_compare : null input");
    80002d96:	00007517          	auipc	a0,0x7
    80002d9a:	aea50513          	addi	a0,a0,-1302 # 80009880 <digits+0x840>
    80002d9e:	ffffd097          	auipc	ra,0xffffd
    80002da2:	78c080e7          	jalr	1932(ra) # 8000052a <panic>

0000000080002da6 <countOnes>:

int countOnes(uint n)
{
    80002da6:	1141                	addi	sp,sp,-16
    80002da8:	e422                	sd	s0,8(sp)
    80002daa:	0800                	addi	s0,sp,16
  int count = 0;
  while (n)
    80002dac:	cd01                	beqz	a0,80002dc4 <countOnes+0x1e>
    80002dae:	87aa                	mv	a5,a0
  int count = 0;
    80002db0:	4501                	li	a0,0
  {
    count += n & 1;
    80002db2:	0017f713          	andi	a4,a5,1
    80002db6:	9d39                	addw	a0,a0,a4
    n >>= 1;
    80002db8:	0017d79b          	srliw	a5,a5,0x1
  while (n)
    80002dbc:	fbfd                	bnez	a5,80002db2 <countOnes+0xc>
  }
  return count;
}
    80002dbe:	6422                	ld	s0,8(sp)
    80002dc0:	0141                	addi	sp,sp,16
    80002dc2:	8082                	ret
  int count = 0;
    80002dc4:	4501                	li	a0,0
    80002dc6:	bfe5                	j	80002dbe <countOnes+0x18>

0000000080002dc8 <LAPA_compare>:
{
    80002dc8:	7179                	addi	sp,sp,-48
    80002dca:	f406                	sd	ra,40(sp)
    80002dcc:	f022                	sd	s0,32(sp)
    80002dce:	ec26                	sd	s1,24(sp)
    80002dd0:	e84a                	sd	s2,16(sp)
    80002dd2:	e44e                	sd	s3,8(sp)
    80002dd4:	1800                	addi	s0,sp,48
  if (!pg1 || !pg2)
    80002dd6:	cd05                	beqz	a0,80002e0e <LAPA_compare+0x46>
    80002dd8:	892e                	mv	s2,a1
    80002dda:	c995                	beqz	a1,80002e0e <LAPA_compare+0x46>
  int res = countOnes(pg1->aging_counter) - countOnes(pg2->aging_counter);
    80002ddc:	00852983          	lw	s3,8(a0)
    80002de0:	854e                	mv	a0,s3
    80002de2:	00000097          	auipc	ra,0x0
    80002de6:	fc4080e7          	jalr	-60(ra) # 80002da6 <countOnes>
    80002dea:	84aa                	mv	s1,a0
    80002dec:	00892903          	lw	s2,8(s2)
    80002df0:	854a                	mv	a0,s2
    80002df2:	00000097          	auipc	ra,0x0
    80002df6:	fb4080e7          	jalr	-76(ra) # 80002da6 <countOnes>
    80002dfa:	40a4853b          	subw	a0,s1,a0
  if (res == 0)
    80002dfe:	c105                	beqz	a0,80002e1e <LAPA_compare+0x56>
}
    80002e00:	70a2                	ld	ra,40(sp)
    80002e02:	7402                	ld	s0,32(sp)
    80002e04:	64e2                	ld	s1,24(sp)
    80002e06:	6942                	ld	s2,16(sp)
    80002e08:	69a2                	ld	s3,8(sp)
    80002e0a:	6145                	addi	sp,sp,48
    80002e0c:	8082                	ret
    panic("LAPA_compare : null input");
    80002e0e:	00007517          	auipc	a0,0x7
    80002e12:	a9250513          	addi	a0,a0,-1390 # 800098a0 <digits+0x860>
    80002e16:	ffffd097          	auipc	ra,0xffffd
    80002e1a:	714080e7          	jalr	1812(ra) # 8000052a <panic>
    return pg1->aging_counter - pg2->aging_counter;
    80002e1e:	4129853b          	subw	a0,s3,s2
    80002e22:	bff9                	j	80002e00 <LAPA_compare+0x38>

0000000080002e24 <compare_all_pages>:

// Return the index of the page to swap out acording to paging policy
int compare_all_pages(int (*compare)(struct page_info *pg1, struct page_info *pg2))
{
    80002e24:	711d                	addi	sp,sp,-96
    80002e26:	ec86                	sd	ra,88(sp)
    80002e28:	e8a2                	sd	s0,80(sp)
    80002e2a:	e4a6                	sd	s1,72(sp)
    80002e2c:	e0ca                	sd	s2,64(sp)
    80002e2e:	fc4e                	sd	s3,56(sp)
    80002e30:	f852                	sd	s4,48(sp)
    80002e32:	f456                	sd	s5,40(sp)
    80002e34:	f05a                	sd	s6,32(sp)
    80002e36:	ec5e                	sd	s7,24(sp)
    80002e38:	e862                	sd	s8,16(sp)
    80002e3a:	e466                	sd	s9,8(sp)
    80002e3c:	1080                	addi	s0,sp,96
    80002e3e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002e40:	fffff097          	auipc	ra,0xfffff
    80002e44:	054080e7          	jalr	84(ra) # 80001e94 <myproc>
    80002e48:	89aa                	mv	s3,a0
  
  struct page_info *pg_to_swap = 0;
  int min_index = -1;
  for (int i=0;i<MAX_PSYC_PAGES;i++)
    80002e4a:	28850913          	addi	s2,a0,648
    80002e4e:	4481                	li	s1,0
  int min_index = -1;
    80002e50:	5bfd                	li	s7,-1
  struct page_info *pg_to_swap = 0;
    80002e52:	4a01                	li	s4,0
  {
    struct page_info *pg = &p->pages_physc_info.pages[i];
    if ((p->pages_physc_info.free_spaces & (1 << i)) && (!pg_to_swap || compare(pg, pg_to_swap) < 0))
    {
      printf("%d\n",i);
    80002e54:	00006c17          	auipc	s8,0x6
    80002e58:	76cc0c13          	addi	s8,s8,1900 # 800095c0 <digits+0x580>
  for (int i=0;i<MAX_PSYC_PAGES;i++)
    80002e5c:	4ac1                	li	s5,16
    80002e5e:	a829                	j	80002e78 <compare_all_pages+0x54>
      printf("%d\n",i);
    80002e60:	85a6                	mv	a1,s1
    80002e62:	8562                	mv	a0,s8
    80002e64:	ffffd097          	auipc	ra,0xffffd
    80002e68:	710080e7          	jalr	1808(ra) # 80000574 <printf>
    80002e6c:	8ba6                	mv	s7,s1
      // in case pg_to_swap have not yet been initialize or the current pg is less needable acording to policy
      pg_to_swap = pg;
    80002e6e:	8a66                	mv	s4,s9
  for (int i=0;i<MAX_PSYC_PAGES;i++)
    80002e70:	2485                	addiw	s1,s1,1
    80002e72:	0941                	addi	s2,s2,16
    80002e74:	03548163          	beq	s1,s5,80002e96 <compare_all_pages+0x72>
    if ((p->pages_physc_info.free_spaces & (1 << i)) && (!pg_to_swap || compare(pg, pg_to_swap) < 0))
    80002e78:	2809d783          	lhu	a5,640(s3)
    80002e7c:	4097d7bb          	sraw	a5,a5,s1
    80002e80:	8b85                	andi	a5,a5,1
    80002e82:	d7fd                	beqz	a5,80002e70 <compare_all_pages+0x4c>
    struct page_info *pg = &p->pages_physc_info.pages[i];
    80002e84:	8cca                	mv	s9,s2
    if ((p->pages_physc_info.free_spaces & (1 << i)) && (!pg_to_swap || compare(pg, pg_to_swap) < 0))
    80002e86:	fc0a0de3          	beqz	s4,80002e60 <compare_all_pages+0x3c>
    80002e8a:	85d2                	mv	a1,s4
    80002e8c:	854a                	mv	a0,s2
    80002e8e:	9b02                	jalr	s6
    80002e90:	fe0550e3          	bgez	a0,80002e70 <compare_all_pages+0x4c>
    80002e94:	b7f1                	j	80002e60 <compare_all_pages+0x3c>
      min_index = i;
    }
  }
  printf("min index chosen in comapre all is : %d\n",min_index);
    80002e96:	85de                	mv	a1,s7
    80002e98:	00007517          	auipc	a0,0x7
    80002e9c:	a2850513          	addi	a0,a0,-1496 # 800098c0 <digits+0x880>
    80002ea0:	ffffd097          	auipc	ra,0xffffd
    80002ea4:	6d4080e7          	jalr	1748(ra) # 80000574 <printf>
  return min_index;
}
    80002ea8:	855e                	mv	a0,s7
    80002eaa:	60e6                	ld	ra,88(sp)
    80002eac:	6446                	ld	s0,80(sp)
    80002eae:	64a6                	ld	s1,72(sp)
    80002eb0:	6906                	ld	s2,64(sp)
    80002eb2:	79e2                	ld	s3,56(sp)
    80002eb4:	7a42                	ld	s4,48(sp)
    80002eb6:	7aa2                	ld	s5,40(sp)
    80002eb8:	7b02                	ld	s6,32(sp)
    80002eba:	6be2                	ld	s7,24(sp)
    80002ebc:	6c42                	ld	s8,16(sp)
    80002ebe:	6ca2                	ld	s9,8(sp)
    80002ec0:	6125                	addi	sp,sp,96
    80002ec2:	8082                	ret

0000000080002ec4 <update_pages_info>:

void update_pages_info()
{
    80002ec4:	1141                	addi	sp,sp,-16
    80002ec6:	e422                	sd	s0,8(sp)
    80002ec8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();

  for (pg = p->pages_physc_info.pages; pg <= &p->pages_physc_info.pages[MAX_PSYC_PAGES]; pg++)
    update_NFUA_LAPA_counter(pg);
#endif
}
    80002eca:	6422                	ld	s0,8(sp)
    80002ecc:	0141                	addi	sp,sp,16
    80002ece:	8082                	ret

0000000080002ed0 <is_accessed>:
{
  pg->aging_counter = (pg->aging_counter >> 1) | (is_accessed(pg, 1) << 31);
}

int is_accessed(struct page_info *pg, int to_reset)
{
    80002ed0:	1101                	addi	sp,sp,-32
    80002ed2:	ec06                	sd	ra,24(sp)
    80002ed4:	e822                	sd	s0,16(sp)
    80002ed6:	e426                	sd	s1,8(sp)
    80002ed8:	e04a                	sd	s2,0(sp)
    80002eda:	1000                	addi	s0,sp,32
    80002edc:	84aa                	mv	s1,a0
    80002ede:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ee0:	fffff097          	auipc	ra,0xfffff
    80002ee4:	fb4080e7          	jalr	-76(ra) # 80001e94 <myproc>
  pte_t *pte = walk(p->pagetable, pg->va, 0);
    80002ee8:	4601                	li	a2,0
    80002eea:	608c                	ld	a1,0(s1)
    80002eec:	6928                	ld	a0,80(a0)
    80002eee:	ffffe097          	auipc	ra,0xffffe
    80002ef2:	0b8080e7          	jalr	184(ra) # 80000fa6 <walk>
    80002ef6:	87aa                	mv	a5,a0
  int accessed = (*pte & PTE_A);
    80002ef8:	6118                	ld	a4,0(a0)
    80002efa:	04077513          	andi	a0,a4,64
  if (accessed && to_reset)
    80002efe:	c511                	beqz	a0,80002f0a <is_accessed+0x3a>
    80002f00:	00090563          	beqz	s2,80002f0a <is_accessed+0x3a>
    *pte ^= PTE_A; // reset accessed flag
    80002f04:	04074713          	xori	a4,a4,64
    80002f08:	e398                	sd	a4,0(a5)

  return accessed;
}
    80002f0a:	60e2                	ld	ra,24(sp)
    80002f0c:	6442                	ld	s0,16(sp)
    80002f0e:	64a2                	ld	s1,8(sp)
    80002f10:	6902                	ld	s2,0(sp)
    80002f12:	6105                	addi	sp,sp,32
    80002f14:	8082                	ret

0000000080002f16 <get_next_page_to_swap_out>:
{
    80002f16:	7179                	addi	sp,sp,-48
    80002f18:	f406                	sd	ra,40(sp)
    80002f1a:	f022                	sd	s0,32(sp)
    80002f1c:	ec26                	sd	s1,24(sp)
    80002f1e:	e84a                	sd	s2,16(sp)
    80002f20:	e44e                	sd	s3,8(sp)
    80002f22:	e052                	sd	s4,0(sp)
    80002f24:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002f26:	fffff097          	auipc	ra,0xfffff
    80002f2a:	f6e080e7          	jalr	-146(ra) # 80001e94 <myproc>
    80002f2e:	892a                	mv	s2,a0
    selected_pg_index = compare_all_pages(SCFIFO_compare);
    80002f30:	fffff997          	auipc	s3,0xfffff
    80002f34:	dce98993          	addi	s3,s3,-562 # 80001cfe <SCFIFO_compare>
        p->pages_physc_info.pages[selected_pg_index].time_inserted = ticks;
    80002f38:	00008a17          	auipc	s4,0x8
    80002f3c:	0f8a0a13          	addi	s4,s4,248 # 8000b030 <ticks>
    selected_pg_index = compare_all_pages(SCFIFO_compare);
    80002f40:	854e                	mv	a0,s3
    80002f42:	00000097          	auipc	ra,0x0
    80002f46:	ee2080e7          	jalr	-286(ra) # 80002e24 <compare_all_pages>
    80002f4a:	84aa                	mv	s1,a0
    if (selected_pg_index >= 0)
    80002f4c:	fe054ae3          	bltz	a0,80002f40 <get_next_page_to_swap_out+0x2a>
      int accessed = is_accessed(&p->pages_physc_info.pages[selected_pg_index], 1);
    80002f50:	0512                	slli	a0,a0,0x4
    80002f52:	28850513          	addi	a0,a0,648
    80002f56:	4585                	li	a1,1
    80002f58:	954a                	add	a0,a0,s2
    80002f5a:	00000097          	auipc	ra,0x0
    80002f5e:	f76080e7          	jalr	-138(ra) # 80002ed0 <is_accessed>
      if (accessed)
    80002f62:	c909                	beqz	a0,80002f74 <get_next_page_to_swap_out+0x5e>
        p->pages_physc_info.pages[selected_pg_index].time_inserted = ticks;
    80002f64:	02848493          	addi	s1,s1,40
    80002f68:	0492                	slli	s1,s1,0x4
    80002f6a:	94ca                	add	s1,s1,s2
    80002f6c:	000a2783          	lw	a5,0(s4)
    80002f70:	c8dc                	sw	a5,20(s1)
  while (selected_pg_index < 0)
    80002f72:	b7f9                	j	80002f40 <get_next_page_to_swap_out+0x2a>
}
    80002f74:	8526                	mv	a0,s1
    80002f76:	70a2                	ld	ra,40(sp)
    80002f78:	7402                	ld	s0,32(sp)
    80002f7a:	64e2                	ld	s1,24(sp)
    80002f7c:	6942                	ld	s2,16(sp)
    80002f7e:	69a2                	ld	s3,8(sp)
    80002f80:	6a02                	ld	s4,0(sp)
    80002f82:	6145                	addi	sp,sp,48
    80002f84:	8082                	ret

0000000080002f86 <update_NFUA_LAPA_counter>:
{
    80002f86:	1101                	addi	sp,sp,-32
    80002f88:	ec06                	sd	ra,24(sp)
    80002f8a:	e822                	sd	s0,16(sp)
    80002f8c:	e426                	sd	s1,8(sp)
    80002f8e:	e04a                	sd	s2,0(sp)
    80002f90:	1000                	addi	s0,sp,32
    80002f92:	84aa                	mv	s1,a0
  pg->aging_counter = (pg->aging_counter >> 1) | (is_accessed(pg, 1) << 31);
    80002f94:	451c                	lw	a5,8(a0)
    80002f96:	0017d91b          	srliw	s2,a5,0x1
    80002f9a:	4585                	li	a1,1
    80002f9c:	00000097          	auipc	ra,0x0
    80002fa0:	f34080e7          	jalr	-204(ra) # 80002ed0 <is_accessed>
    80002fa4:	01f5179b          	slliw	a5,a0,0x1f
    80002fa8:	0127e7b3          	or	a5,a5,s2
    80002fac:	c49c                	sw	a5,8(s1)
}
    80002fae:	60e2                	ld	ra,24(sp)
    80002fb0:	6442                	ld	s0,16(sp)
    80002fb2:	64a2                	ld	s1,8(sp)
    80002fb4:	6902                	ld	s2,0(sp)
    80002fb6:	6105                	addi	sp,sp,32
    80002fb8:	8082                	ret

0000000080002fba <reset_aging_counter>:
void reset_aging_counter(struct page_info *pg)
{
    80002fba:	1141                	addi	sp,sp,-16
    80002fbc:	e422                	sd	s0,8(sp)
    80002fbe:	0800                	addi	s0,sp,16
  #ifdef NFUA
    pg->aging_counter = 0;
  #elif LAPA
    pg->aging_counter = ~0;
  #endif
}
    80002fc0:	6422                	ld	s0,8(sp)
    80002fc2:	0141                	addi	sp,sp,16
    80002fc4:	8082                	ret

0000000080002fc6 <print_pages_from_info_arrs>:

void print_pages_from_info_arrs(){
    80002fc6:	7139                	addi	sp,sp,-64
    80002fc8:	fc06                	sd	ra,56(sp)
    80002fca:	f822                	sd	s0,48(sp)
    80002fcc:	f426                	sd	s1,40(sp)
    80002fce:	f04a                	sd	s2,32(sp)
    80002fd0:	ec4e                	sd	s3,24(sp)
    80002fd2:	e852                	sd	s4,16(sp)
    80002fd4:	e456                	sd	s5,8(sp)
    80002fd6:	e05a                	sd	s6,0(sp)
    80002fd8:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002fda:	fffff097          	auipc	ra,0xfffff
    80002fde:	eba080e7          	jalr	-326(ra) # 80001e94 <myproc>
    80002fe2:	89aa                	mv	s3,a0
  printf("\n physic pages :\n");
    80002fe4:	00007517          	auipc	a0,0x7
    80002fe8:	90c50513          	addi	a0,a0,-1780 # 800098f0 <digits+0x8b0>
    80002fec:	ffffd097          	auipc	ra,0xffffd
    80002ff0:	588080e7          	jalr	1416(ra) # 80000574 <printf>

  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002ff4:	28898913          	addi	s2,s3,648
    80002ff8:	4481                	li	s1,0
    printf("(%p , %d)\n ", p->pages_physc_info.pages[i].va, p->pages_physc_info.free_spaces & (1 << i));
    80002ffa:	4b05                	li	s6,1
    80002ffc:	00007a97          	auipc	s5,0x7
    80003000:	90ca8a93          	addi	s5,s5,-1780 # 80009908 <digits+0x8c8>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80003004:	4a41                	li	s4,16
    printf("(%p , %d)\n ", p->pages_physc_info.pages[i].va, p->pages_physc_info.free_spaces & (1 << i));
    80003006:	009b17bb          	sllw	a5,s6,s1
    8000300a:	2809d603          	lhu	a2,640(s3)
    8000300e:	8e7d                	and	a2,a2,a5
    80003010:	00093583          	ld	a1,0(s2)
    80003014:	8556                	mv	a0,s5
    80003016:	ffffd097          	auipc	ra,0xffffd
    8000301a:	55e080e7          	jalr	1374(ra) # 80000574 <printf>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000301e:	2485                	addiw	s1,s1,1
    80003020:	0941                	addi	s2,s2,16
    80003022:	ff4492e3          	bne	s1,s4,80003006 <print_pages_from_info_arrs+0x40>
  

  printf("\n swap file:\n");
    80003026:	00007517          	auipc	a0,0x7
    8000302a:	8f250513          	addi	a0,a0,-1806 # 80009918 <digits+0x8d8>
    8000302e:	ffffd097          	auipc	ra,0xffffd
    80003032:	546080e7          	jalr	1350(ra) # 80000574 <printf>
  for(int i=0;i<MAX_PSYC_PAGES;i++)
    80003036:	18098913          	addi	s2,s3,384
    8000303a:	4481                	li	s1,0
    printf("(%p , %d)\n ",p->pages_swap_info.pages[i].va,p->pages_swap_info.free_spaces&(1<<i));
    8000303c:	4b05                	li	s6,1
    8000303e:	00007a97          	auipc	s5,0x7
    80003042:	8caa8a93          	addi	s5,s5,-1846 # 80009908 <digits+0x8c8>
  for(int i=0;i<MAX_PSYC_PAGES;i++)
    80003046:	4a41                	li	s4,16
    printf("(%p , %d)\n ",p->pages_swap_info.pages[i].va,p->pages_swap_info.free_spaces&(1<<i));
    80003048:	009b17bb          	sllw	a5,s6,s1
    8000304c:	1789d603          	lhu	a2,376(s3)
    80003050:	8e7d                	and	a2,a2,a5
    80003052:	00093583          	ld	a1,0(s2)
    80003056:	8556                	mv	a0,s5
    80003058:	ffffd097          	auipc	ra,0xffffd
    8000305c:	51c080e7          	jalr	1308(ra) # 80000574 <printf>
  for(int i=0;i<MAX_PSYC_PAGES;i++)
    80003060:	2485                	addiw	s1,s1,1
    80003062:	0941                	addi	s2,s2,16
    80003064:	ff4492e3          	bne	s1,s4,80003048 <print_pages_from_info_arrs+0x82>
    80003068:	70e2                	ld	ra,56(sp)
    8000306a:	7442                	ld	s0,48(sp)
    8000306c:	74a2                	ld	s1,40(sp)
    8000306e:	7902                	ld	s2,32(sp)
    80003070:	69e2                	ld	s3,24(sp)
    80003072:	6a42                	ld	s4,16(sp)
    80003074:	6aa2                	ld	s5,8(sp)
    80003076:	6b02                	ld	s6,0(sp)
    80003078:	6121                	addi	sp,sp,64
    8000307a:	8082                	ret

000000008000307c <swtch>:
    8000307c:	00153023          	sd	ra,0(a0)
    80003080:	00253423          	sd	sp,8(a0)
    80003084:	e900                	sd	s0,16(a0)
    80003086:	ed04                	sd	s1,24(a0)
    80003088:	03253023          	sd	s2,32(a0)
    8000308c:	03353423          	sd	s3,40(a0)
    80003090:	03453823          	sd	s4,48(a0)
    80003094:	03553c23          	sd	s5,56(a0)
    80003098:	05653023          	sd	s6,64(a0)
    8000309c:	05753423          	sd	s7,72(a0)
    800030a0:	05853823          	sd	s8,80(a0)
    800030a4:	05953c23          	sd	s9,88(a0)
    800030a8:	07a53023          	sd	s10,96(a0)
    800030ac:	07b53423          	sd	s11,104(a0)
    800030b0:	0005b083          	ld	ra,0(a1)
    800030b4:	0085b103          	ld	sp,8(a1)
    800030b8:	6980                	ld	s0,16(a1)
    800030ba:	6d84                	ld	s1,24(a1)
    800030bc:	0205b903          	ld	s2,32(a1)
    800030c0:	0285b983          	ld	s3,40(a1)
    800030c4:	0305ba03          	ld	s4,48(a1)
    800030c8:	0385ba83          	ld	s5,56(a1)
    800030cc:	0405bb03          	ld	s6,64(a1)
    800030d0:	0485bb83          	ld	s7,72(a1)
    800030d4:	0505bc03          	ld	s8,80(a1)
    800030d8:	0585bc83          	ld	s9,88(a1)
    800030dc:	0605bd03          	ld	s10,96(a1)
    800030e0:	0685bd83          	ld	s11,104(a1)
    800030e4:	8082                	ret

00000000800030e6 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    800030e6:	1141                	addi	sp,sp,-16
    800030e8:	e406                	sd	ra,8(sp)
    800030ea:	e022                	sd	s0,0(sp)
    800030ec:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800030ee:	00007597          	auipc	a1,0x7
    800030f2:	89258593          	addi	a1,a1,-1902 # 80009980 <states.0+0x30>
    800030f6:	0001e517          	auipc	a0,0x1e
    800030fa:	7da50513          	addi	a0,a0,2010 # 800218d0 <tickslock>
    800030fe:	ffffe097          	auipc	ra,0xffffe
    80003102:	a34080e7          	jalr	-1484(ra) # 80000b32 <initlock>
}
    80003106:	60a2                	ld	ra,8(sp)
    80003108:	6402                	ld	s0,0(sp)
    8000310a:	0141                	addi	sp,sp,16
    8000310c:	8082                	ret

000000008000310e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    8000310e:	1141                	addi	sp,sp,-16
    80003110:	e422                	sd	s0,8(sp)
    80003112:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003114:	00004797          	auipc	a5,0x4
    80003118:	b4c78793          	addi	a5,a5,-1204 # 80006c60 <kernelvec>
    8000311c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80003120:	6422                	ld	s0,8(sp)
    80003122:	0141                	addi	sp,sp,16
    80003124:	8082                	ret

0000000080003126 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80003126:	1141                	addi	sp,sp,-16
    80003128:	e406                	sd	ra,8(sp)
    8000312a:	e022                	sd	s0,0(sp)
    8000312c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000312e:	fffff097          	auipc	ra,0xfffff
    80003132:	d66080e7          	jalr	-666(ra) # 80001e94 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003136:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000313a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000313c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80003140:	00005617          	auipc	a2,0x5
    80003144:	ec060613          	addi	a2,a2,-320 # 80008000 <_trampoline>
    80003148:	00005697          	auipc	a3,0x5
    8000314c:	eb868693          	addi	a3,a3,-328 # 80008000 <_trampoline>
    80003150:	8e91                	sub	a3,a3,a2
    80003152:	040007b7          	lui	a5,0x4000
    80003156:	17fd                	addi	a5,a5,-1
    80003158:	07b2                	slli	a5,a5,0xc
    8000315a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000315c:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80003160:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80003162:	180026f3          	csrr	a3,satp
    80003166:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80003168:	6d38                	ld	a4,88(a0)
    8000316a:	6134                	ld	a3,64(a0)
    8000316c:	6585                	lui	a1,0x1
    8000316e:	96ae                	add	a3,a3,a1
    80003170:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80003172:	6d38                	ld	a4,88(a0)
    80003174:	00000697          	auipc	a3,0x0
    80003178:	13868693          	addi	a3,a3,312 # 800032ac <usertrap>
    8000317c:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    8000317e:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80003180:	8692                	mv	a3,tp
    80003182:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003184:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80003188:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000318c:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003190:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80003194:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003196:	6f18                	ld	a4,24(a4)
    80003198:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000319c:	692c                	ld	a1,80(a0)
    8000319e:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800031a0:	00005717          	auipc	a4,0x5
    800031a4:	ef070713          	addi	a4,a4,-272 # 80008090 <userret>
    800031a8:	8f11                	sub	a4,a4,a2
    800031aa:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))fn)(TRAPFRAME, satp);
    800031ac:	577d                	li	a4,-1
    800031ae:	177e                	slli	a4,a4,0x3f
    800031b0:	8dd9                	or	a1,a1,a4
    800031b2:	02000537          	lui	a0,0x2000
    800031b6:	157d                	addi	a0,a0,-1
    800031b8:	0536                	slli	a0,a0,0xd
    800031ba:	9782                	jalr	a5
}
    800031bc:	60a2                	ld	ra,8(sp)
    800031be:	6402                	ld	s0,0(sp)
    800031c0:	0141                	addi	sp,sp,16
    800031c2:	8082                	ret

00000000800031c4 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    800031c4:	1101                	addi	sp,sp,-32
    800031c6:	ec06                	sd	ra,24(sp)
    800031c8:	e822                	sd	s0,16(sp)
    800031ca:	e426                	sd	s1,8(sp)
    800031cc:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800031ce:	0001e497          	auipc	s1,0x1e
    800031d2:	70248493          	addi	s1,s1,1794 # 800218d0 <tickslock>
    800031d6:	8526                	mv	a0,s1
    800031d8:	ffffe097          	auipc	ra,0xffffe
    800031dc:	9ea080e7          	jalr	-1558(ra) # 80000bc2 <acquire>
  ticks++;
    800031e0:	00008517          	auipc	a0,0x8
    800031e4:	e5050513          	addi	a0,a0,-432 # 8000b030 <ticks>
    800031e8:	411c                	lw	a5,0(a0)
    800031ea:	2785                	addiw	a5,a5,1
    800031ec:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800031ee:	fffff097          	auipc	ra,0xfffff
    800031f2:	3d4080e7          	jalr	980(ra) # 800025c2 <wakeup>
  release(&tickslock);
    800031f6:	8526                	mv	a0,s1
    800031f8:	ffffe097          	auipc	ra,0xffffe
    800031fc:	a7e080e7          	jalr	-1410(ra) # 80000c76 <release>
}
    80003200:	60e2                	ld	ra,24(sp)
    80003202:	6442                	ld	s0,16(sp)
    80003204:	64a2                	ld	s1,8(sp)
    80003206:	6105                	addi	sp,sp,32
    80003208:	8082                	ret

000000008000320a <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    8000320a:	1101                	addi	sp,sp,-32
    8000320c:	ec06                	sd	ra,24(sp)
    8000320e:	e822                	sd	s0,16(sp)
    80003210:	e426                	sd	s1,8(sp)
    80003212:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003214:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80003218:	00074d63          	bltz	a4,80003232 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    8000321c:	57fd                	li	a5,-1
    8000321e:	17fe                	slli	a5,a5,0x3f
    80003220:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80003222:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80003224:	06f70363          	beq	a4,a5,8000328a <devintr+0x80>
  }
}
    80003228:	60e2                	ld	ra,24(sp)
    8000322a:	6442                	ld	s0,16(sp)
    8000322c:	64a2                	ld	s1,8(sp)
    8000322e:	6105                	addi	sp,sp,32
    80003230:	8082                	ret
      (scause & 0xff) == 9)
    80003232:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    80003236:	46a5                	li	a3,9
    80003238:	fed792e3          	bne	a5,a3,8000321c <devintr+0x12>
    int irq = plic_claim();
    8000323c:	00004097          	auipc	ra,0x4
    80003240:	b2c080e7          	jalr	-1236(ra) # 80006d68 <plic_claim>
    80003244:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80003246:	47a9                	li	a5,10
    80003248:	02f50763          	beq	a0,a5,80003276 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    8000324c:	4785                	li	a5,1
    8000324e:	02f50963          	beq	a0,a5,80003280 <devintr+0x76>
    return 1;
    80003252:	4505                	li	a0,1
    else if (irq)
    80003254:	d8f1                	beqz	s1,80003228 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80003256:	85a6                	mv	a1,s1
    80003258:	00006517          	auipc	a0,0x6
    8000325c:	73050513          	addi	a0,a0,1840 # 80009988 <states.0+0x38>
    80003260:	ffffd097          	auipc	ra,0xffffd
    80003264:	314080e7          	jalr	788(ra) # 80000574 <printf>
      plic_complete(irq);
    80003268:	8526                	mv	a0,s1
    8000326a:	00004097          	auipc	ra,0x4
    8000326e:	b22080e7          	jalr	-1246(ra) # 80006d8c <plic_complete>
    return 1;
    80003272:	4505                	li	a0,1
    80003274:	bf55                	j	80003228 <devintr+0x1e>
      uartintr();
    80003276:	ffffd097          	auipc	ra,0xffffd
    8000327a:	710080e7          	jalr	1808(ra) # 80000986 <uartintr>
    8000327e:	b7ed                	j	80003268 <devintr+0x5e>
      virtio_disk_intr();
    80003280:	00004097          	auipc	ra,0x4
    80003284:	f9e080e7          	jalr	-98(ra) # 8000721e <virtio_disk_intr>
    80003288:	b7c5                	j	80003268 <devintr+0x5e>
    if (cpuid() == 0)
    8000328a:	fffff097          	auipc	ra,0xfffff
    8000328e:	bde080e7          	jalr	-1058(ra) # 80001e68 <cpuid>
    80003292:	c901                	beqz	a0,800032a2 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80003294:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80003298:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000329a:	14479073          	csrw	sip,a5
    return 2;
    8000329e:	4509                	li	a0,2
    800032a0:	b761                	j	80003228 <devintr+0x1e>
      clockintr();
    800032a2:	00000097          	auipc	ra,0x0
    800032a6:	f22080e7          	jalr	-222(ra) # 800031c4 <clockintr>
    800032aa:	b7ed                	j	80003294 <devintr+0x8a>

00000000800032ac <usertrap>:
{
    800032ac:	7179                	addi	sp,sp,-48
    800032ae:	f406                	sd	ra,40(sp)
    800032b0:	f022                	sd	s0,32(sp)
    800032b2:	ec26                	sd	s1,24(sp)
    800032b4:	e84a                	sd	s2,16(sp)
    800032b6:	e44e                	sd	s3,8(sp)
    800032b8:	e052                	sd	s4,0(sp)
    800032ba:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800032bc:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800032c0:	1007f793          	andi	a5,a5,256
    800032c4:	e7a1                	bnez	a5,8000330c <usertrap+0x60>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800032c6:	00004797          	auipc	a5,0x4
    800032ca:	99a78793          	addi	a5,a5,-1638 # 80006c60 <kernelvec>
    800032ce:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800032d2:	fffff097          	auipc	ra,0xfffff
    800032d6:	bc2080e7          	jalr	-1086(ra) # 80001e94 <myproc>
    800032da:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800032dc:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800032de:	14102773          	csrr	a4,sepc
    800032e2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800032e4:	142027f3          	csrr	a5,scause
  if (trap_cause == 8)
    800032e8:	4721                	li	a4,8
    800032ea:	02e78963          	beq	a5,a4,8000331c <usertrap+0x70>
  else if (trap_cause == 13 || trap_cause == 15)
    800032ee:	9bf5                	andi	a5,a5,-3
    800032f0:	4735                	li	a4,13
    800032f2:	06e78a63          	beq	a5,a4,80003366 <usertrap+0xba>
  else if ((which_dev = devintr()) != 0)
    800032f6:	00000097          	auipc	ra,0x0
    800032fa:	f14080e7          	jalr	-236(ra) # 8000320a <devintr>
    800032fe:	892a                	mv	s2,a0
    80003300:	16050263          	beqz	a0,80003464 <usertrap+0x1b8>
  if (p->killed)
    80003304:	549c                	lw	a5,40(s1)
    80003306:	18078f63          	beqz	a5,800034a4 <usertrap+0x1f8>
    8000330a:	aa41                	j	8000349a <usertrap+0x1ee>
    panic("usertrap: not from user mode");
    8000330c:	00006517          	auipc	a0,0x6
    80003310:	69c50513          	addi	a0,a0,1692 # 800099a8 <states.0+0x58>
    80003314:	ffffd097          	auipc	ra,0xffffd
    80003318:	216080e7          	jalr	534(ra) # 8000052a <panic>
    if (p->killed)
    8000331c:	551c                	lw	a5,40(a0)
    8000331e:	ef95                	bnez	a5,8000335a <usertrap+0xae>
    p->trapframe->epc += 4;
    80003320:	6cb8                	ld	a4,88(s1)
    80003322:	6f1c                	ld	a5,24(a4)
    80003324:	0791                	addi	a5,a5,4
    80003326:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003328:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000332c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003330:	10079073          	csrw	sstatus,a5
    syscall();
    80003334:	00000097          	auipc	ra,0x0
    80003338:	3c2080e7          	jalr	962(ra) # 800036f6 <syscall>
  if (p->killed)
    8000333c:	549c                	lw	a5,40(s1)
    8000333e:	14079d63          	bnez	a5,80003498 <usertrap+0x1ec>
  usertrapret();
    80003342:	00000097          	auipc	ra,0x0
    80003346:	de4080e7          	jalr	-540(ra) # 80003126 <usertrapret>
}
    8000334a:	70a2                	ld	ra,40(sp)
    8000334c:	7402                	ld	s0,32(sp)
    8000334e:	64e2                	ld	s1,24(sp)
    80003350:	6942                	ld	s2,16(sp)
    80003352:	69a2                	ld	s3,8(sp)
    80003354:	6a02                	ld	s4,0(sp)
    80003356:	6145                	addi	sp,sp,48
    80003358:	8082                	ret
      exit(-1);
    8000335a:	557d                	li	a0,-1
    8000335c:	fffff097          	auipc	ra,0xfffff
    80003360:	336080e7          	jalr	822(ra) # 80002692 <exit>
    80003364:	bf75                	j	80003320 <usertrap+0x74>
    struct proc *p = myproc();
    80003366:	fffff097          	auipc	ra,0xfffff
    8000336a:	b2e080e7          	jalr	-1234(ra) # 80001e94 <myproc>
    8000336e:	892a                	mv	s2,a0
    printf("inside page fault usertrap\n"); //TODO delete
    80003370:	00006517          	auipc	a0,0x6
    80003374:	65850513          	addi	a0,a0,1624 # 800099c8 <states.0+0x78>
    80003378:	ffffd097          	auipc	ra,0xffffd
    8000337c:	1fc080e7          	jalr	508(ra) # 80000574 <printf>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003380:	14302a73          	csrr	s4,stval
    uint64 fault_rva = PGROUNDDOWN(fault_va);
    80003384:	77fd                	lui	a5,0xfffff
    80003386:	00fa7a33          	and	s4,s4,a5
    pte_t *pte = walk(p->pagetable, fault_rva, 0);
    8000338a:	4601                	li	a2,0
    8000338c:	85d2                	mv	a1,s4
    8000338e:	05093503          	ld	a0,80(s2)
    80003392:	ffffe097          	auipc	ra,0xffffe
    80003396:	c14080e7          	jalr	-1004(ra) # 80000fa6 <walk>
    8000339a:	89aa                	mv	s3,a0
    if (!pte || p->pid <= 2)
    8000339c:	c51d                	beqz	a0,800033ca <usertrap+0x11e>
    8000339e:	03092703          	lw	a4,48(s2)
    800033a2:	4789                	li	a5,2
    800033a4:	02e7d363          	bge	a5,a4,800033ca <usertrap+0x11e>
    if (*pte & PTE_PG && !(*pte & PTE_V))
    800033a8:	611c                	ld	a5,0(a0)
    800033aa:	2017f693          	andi	a3,a5,513
    800033ae:	20000713          	li	a4,512
    800033b2:	02e68e63          	beq	a3,a4,800033ee <usertrap+0x142>
    else if (*pte & PTE_V)
    800033b6:	8b85                	andi	a5,a5,1
    800033b8:	d3d1                	beqz	a5,8000333c <usertrap+0x90>
      panic("usertrap: PTE_V should not be valid during page_fault"); //TODO: check if needed/true
    800033ba:	00006517          	auipc	a0,0x6
    800033be:	6d650513          	addi	a0,a0,1750 # 80009a90 <states.0+0x140>
    800033c2:	ffffd097          	auipc	ra,0xffffd
    800033c6:	168080e7          	jalr	360(ra) # 8000052a <panic>
      printf("seg fault with pid=%d", p->pid);
    800033ca:	03092583          	lw	a1,48(s2)
    800033ce:	00006517          	auipc	a0,0x6
    800033d2:	61a50513          	addi	a0,a0,1562 # 800099e8 <states.0+0x98>
    800033d6:	ffffd097          	auipc	ra,0xffffd
    800033da:	19e080e7          	jalr	414(ra) # 80000574 <printf>
      panic("usertrap: segmentation fault oh nooooo"); // TODO check if need to kill just the current procces
    800033de:	00006517          	auipc	a0,0x6
    800033e2:	62250513          	addi	a0,a0,1570 # 80009a00 <states.0+0xb0>
    800033e6:	ffffd097          	auipc	ra,0xffffd
    800033ea:	144080e7          	jalr	324(ra) # 8000052a <panic>
      if (p->physical_pages_num >= MAX_PSYC_PAGES)
    800033ee:	17092703          	lw	a4,368(s2)
    800033f2:	47bd                	li	a5,15
    800033f4:	04e7d063          	bge	a5,a4,80003434 <usertrap+0x188>
        int page_to_swap_out_index = get_next_page_to_swap_out();
    800033f8:	00000097          	auipc	ra,0x0
    800033fc:	b1e080e7          	jalr	-1250(ra) # 80002f16 <get_next_page_to_swap_out>
        if(page_to_swap_out_index <0 || page_to_swap_out_index > MAX_PSYC_PAGES)
    80003400:	0005071b          	sext.w	a4,a0
    80003404:	47c1                	li	a5,16
    80003406:	04e7e763          	bltu	a5,a4,80003454 <usertrap+0x1a8>
        uint64 va = p->pages_physc_info.pages[page_to_swap_out_index].va;
    8000340a:	02850513          	addi	a0,a0,40
    8000340e:	0512                	slli	a0,a0,0x4
    80003410:	992a                	add	s2,s2,a0
    80003412:	00893903          	ld	s2,8(s2)
        uint64 pa = page_out(va);
    80003416:	854a                	mv	a0,s2
    80003418:	fffff097          	auipc	ra,0xfffff
    8000341c:	5a4080e7          	jalr	1444(ra) # 800029bc <page_out>
    80003420:	862a                	mv	a2,a0
        printf("paged out page with va = %p pa = %p\n", va, pa); //TODO delete
    80003422:	85ca                	mv	a1,s2
    80003424:	00006517          	auipc	a0,0x6
    80003428:	62c50513          	addi	a0,a0,1580 # 80009a50 <states.0+0x100>
    8000342c:	ffffd097          	auipc	ra,0xffffd
    80003430:	148080e7          	jalr	328(ra) # 80000574 <printf>
        pte_t *pte_new = page_in(fault_rva, pte);
    80003434:	85ce                	mv	a1,s3
    80003436:	8552                	mv	a0,s4
    80003438:	fffff097          	auipc	ra,0xfffff
    8000343c:	61a080e7          	jalr	1562(ra) # 80002a52 <page_in>
    80003440:	85aa                	mv	a1,a0
        printf("usertrap: pte_new = %p", pte_new); // TODO delete
    80003442:	00006517          	auipc	a0,0x6
    80003446:	63650513          	addi	a0,a0,1590 # 80009a78 <states.0+0x128>
    8000344a:	ffffd097          	auipc	ra,0xffffd
    8000344e:	12a080e7          	jalr	298(ra) # 80000574 <printf>
    80003452:	b5ed                	j	8000333c <usertrap+0x90>
          panic("usertrap: did not find page to swap out");
    80003454:	00006517          	auipc	a0,0x6
    80003458:	5d450513          	addi	a0,a0,1492 # 80009a28 <states.0+0xd8>
    8000345c:	ffffd097          	auipc	ra,0xffffd
    80003460:	0ce080e7          	jalr	206(ra) # 8000052a <panic>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003464:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003468:	5890                	lw	a2,48(s1)
    8000346a:	00006517          	auipc	a0,0x6
    8000346e:	65e50513          	addi	a0,a0,1630 # 80009ac8 <states.0+0x178>
    80003472:	ffffd097          	auipc	ra,0xffffd
    80003476:	102080e7          	jalr	258(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000347a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000347e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003482:	00006517          	auipc	a0,0x6
    80003486:	67650513          	addi	a0,a0,1654 # 80009af8 <states.0+0x1a8>
    8000348a:	ffffd097          	auipc	ra,0xffffd
    8000348e:	0ea080e7          	jalr	234(ra) # 80000574 <printf>
    p->killed = 1;
    80003492:	4785                	li	a5,1
    80003494:	d49c                	sw	a5,40(s1)
  if (p->killed)
    80003496:	a011                	j	8000349a <usertrap+0x1ee>
    80003498:	4901                	li	s2,0
    exit(-1);
    8000349a:	557d                	li	a0,-1
    8000349c:	fffff097          	auipc	ra,0xfffff
    800034a0:	1f6080e7          	jalr	502(ra) # 80002692 <exit>
  if (which_dev == 2)
    800034a4:	4789                	li	a5,2
    800034a6:	e8f91ee3          	bne	s2,a5,80003342 <usertrap+0x96>
    yield();
    800034aa:	fffff097          	auipc	ra,0xfffff
    800034ae:	f50080e7          	jalr	-176(ra) # 800023fa <yield>
    800034b2:	bd41                	j	80003342 <usertrap+0x96>

00000000800034b4 <kerneltrap>:
{
    800034b4:	7179                	addi	sp,sp,-48
    800034b6:	f406                	sd	ra,40(sp)
    800034b8:	f022                	sd	s0,32(sp)
    800034ba:	ec26                	sd	s1,24(sp)
    800034bc:	e84a                	sd	s2,16(sp)
    800034be:	e44e                	sd	s3,8(sp)
    800034c0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800034c2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800034c6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800034ca:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    800034ce:	1004f793          	andi	a5,s1,256
    800034d2:	cb85                	beqz	a5,80003502 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800034d4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800034d8:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800034da:	ef85                	bnez	a5,80003512 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    800034dc:	00000097          	auipc	ra,0x0
    800034e0:	d2e080e7          	jalr	-722(ra) # 8000320a <devintr>
    800034e4:	cd1d                	beqz	a0,80003522 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800034e6:	4789                	li	a5,2
    800034e8:	06f50a63          	beq	a0,a5,8000355c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800034ec:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800034f0:	10049073          	csrw	sstatus,s1
}
    800034f4:	70a2                	ld	ra,40(sp)
    800034f6:	7402                	ld	s0,32(sp)
    800034f8:	64e2                	ld	s1,24(sp)
    800034fa:	6942                	ld	s2,16(sp)
    800034fc:	69a2                	ld	s3,8(sp)
    800034fe:	6145                	addi	sp,sp,48
    80003500:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003502:	00006517          	auipc	a0,0x6
    80003506:	61650513          	addi	a0,a0,1558 # 80009b18 <states.0+0x1c8>
    8000350a:	ffffd097          	auipc	ra,0xffffd
    8000350e:	020080e7          	jalr	32(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80003512:	00006517          	auipc	a0,0x6
    80003516:	62e50513          	addi	a0,a0,1582 # 80009b40 <states.0+0x1f0>
    8000351a:	ffffd097          	auipc	ra,0xffffd
    8000351e:	010080e7          	jalr	16(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80003522:	85ce                	mv	a1,s3
    80003524:	00006517          	auipc	a0,0x6
    80003528:	63c50513          	addi	a0,a0,1596 # 80009b60 <states.0+0x210>
    8000352c:	ffffd097          	auipc	ra,0xffffd
    80003530:	048080e7          	jalr	72(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003534:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003538:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000353c:	00006517          	auipc	a0,0x6
    80003540:	63450513          	addi	a0,a0,1588 # 80009b70 <states.0+0x220>
    80003544:	ffffd097          	auipc	ra,0xffffd
    80003548:	030080e7          	jalr	48(ra) # 80000574 <printf>
    panic("kerneltrap");
    8000354c:	00006517          	auipc	a0,0x6
    80003550:	63c50513          	addi	a0,a0,1596 # 80009b88 <states.0+0x238>
    80003554:	ffffd097          	auipc	ra,0xffffd
    80003558:	fd6080e7          	jalr	-42(ra) # 8000052a <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000355c:	fffff097          	auipc	ra,0xfffff
    80003560:	938080e7          	jalr	-1736(ra) # 80001e94 <myproc>
    80003564:	d541                	beqz	a0,800034ec <kerneltrap+0x38>
    80003566:	fffff097          	auipc	ra,0xfffff
    8000356a:	92e080e7          	jalr	-1746(ra) # 80001e94 <myproc>
    8000356e:	4d18                	lw	a4,24(a0)
    80003570:	4791                	li	a5,4
    80003572:	f6f71de3          	bne	a4,a5,800034ec <kerneltrap+0x38>
    yield();
    80003576:	fffff097          	auipc	ra,0xfffff
    8000357a:	e84080e7          	jalr	-380(ra) # 800023fa <yield>
    8000357e:	b7bd                	j	800034ec <kerneltrap+0x38>

0000000080003580 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003580:	1101                	addi	sp,sp,-32
    80003582:	ec06                	sd	ra,24(sp)
    80003584:	e822                	sd	s0,16(sp)
    80003586:	e426                	sd	s1,8(sp)
    80003588:	1000                	addi	s0,sp,32
    8000358a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000358c:	fffff097          	auipc	ra,0xfffff
    80003590:	908080e7          	jalr	-1784(ra) # 80001e94 <myproc>
  switch (n) {
    80003594:	4795                	li	a5,5
    80003596:	0497e163          	bltu	a5,s1,800035d8 <argraw+0x58>
    8000359a:	048a                	slli	s1,s1,0x2
    8000359c:	00006717          	auipc	a4,0x6
    800035a0:	62470713          	addi	a4,a4,1572 # 80009bc0 <states.0+0x270>
    800035a4:	94ba                	add	s1,s1,a4
    800035a6:	409c                	lw	a5,0(s1)
    800035a8:	97ba                	add	a5,a5,a4
    800035aa:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800035ac:	6d3c                	ld	a5,88(a0)
    800035ae:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800035b0:	60e2                	ld	ra,24(sp)
    800035b2:	6442                	ld	s0,16(sp)
    800035b4:	64a2                	ld	s1,8(sp)
    800035b6:	6105                	addi	sp,sp,32
    800035b8:	8082                	ret
    return p->trapframe->a1;
    800035ba:	6d3c                	ld	a5,88(a0)
    800035bc:	7fa8                	ld	a0,120(a5)
    800035be:	bfcd                	j	800035b0 <argraw+0x30>
    return p->trapframe->a2;
    800035c0:	6d3c                	ld	a5,88(a0)
    800035c2:	63c8                	ld	a0,128(a5)
    800035c4:	b7f5                	j	800035b0 <argraw+0x30>
    return p->trapframe->a3;
    800035c6:	6d3c                	ld	a5,88(a0)
    800035c8:	67c8                	ld	a0,136(a5)
    800035ca:	b7dd                	j	800035b0 <argraw+0x30>
    return p->trapframe->a4;
    800035cc:	6d3c                	ld	a5,88(a0)
    800035ce:	6bc8                	ld	a0,144(a5)
    800035d0:	b7c5                	j	800035b0 <argraw+0x30>
    return p->trapframe->a5;
    800035d2:	6d3c                	ld	a5,88(a0)
    800035d4:	6fc8                	ld	a0,152(a5)
    800035d6:	bfe9                	j	800035b0 <argraw+0x30>
  panic("argraw");
    800035d8:	00006517          	auipc	a0,0x6
    800035dc:	5c050513          	addi	a0,a0,1472 # 80009b98 <states.0+0x248>
    800035e0:	ffffd097          	auipc	ra,0xffffd
    800035e4:	f4a080e7          	jalr	-182(ra) # 8000052a <panic>

00000000800035e8 <fetchaddr>:
{
    800035e8:	1101                	addi	sp,sp,-32
    800035ea:	ec06                	sd	ra,24(sp)
    800035ec:	e822                	sd	s0,16(sp)
    800035ee:	e426                	sd	s1,8(sp)
    800035f0:	e04a                	sd	s2,0(sp)
    800035f2:	1000                	addi	s0,sp,32
    800035f4:	84aa                	mv	s1,a0
    800035f6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800035f8:	fffff097          	auipc	ra,0xfffff
    800035fc:	89c080e7          	jalr	-1892(ra) # 80001e94 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003600:	653c                	ld	a5,72(a0)
    80003602:	02f4f863          	bgeu	s1,a5,80003632 <fetchaddr+0x4a>
    80003606:	00848713          	addi	a4,s1,8
    8000360a:	02e7e663          	bltu	a5,a4,80003636 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000360e:	46a1                	li	a3,8
    80003610:	8626                	mv	a2,s1
    80003612:	85ca                	mv	a1,s2
    80003614:	6928                	ld	a0,80(a0)
    80003616:	ffffe097          	auipc	ra,0xffffe
    8000361a:	e62080e7          	jalr	-414(ra) # 80001478 <copyin>
    8000361e:	00a03533          	snez	a0,a0
    80003622:	40a00533          	neg	a0,a0
}
    80003626:	60e2                	ld	ra,24(sp)
    80003628:	6442                	ld	s0,16(sp)
    8000362a:	64a2                	ld	s1,8(sp)
    8000362c:	6902                	ld	s2,0(sp)
    8000362e:	6105                	addi	sp,sp,32
    80003630:	8082                	ret
    return -1;
    80003632:	557d                	li	a0,-1
    80003634:	bfcd                	j	80003626 <fetchaddr+0x3e>
    80003636:	557d                	li	a0,-1
    80003638:	b7fd                	j	80003626 <fetchaddr+0x3e>

000000008000363a <fetchstr>:
{
    8000363a:	7179                	addi	sp,sp,-48
    8000363c:	f406                	sd	ra,40(sp)
    8000363e:	f022                	sd	s0,32(sp)
    80003640:	ec26                	sd	s1,24(sp)
    80003642:	e84a                	sd	s2,16(sp)
    80003644:	e44e                	sd	s3,8(sp)
    80003646:	1800                	addi	s0,sp,48
    80003648:	892a                	mv	s2,a0
    8000364a:	84ae                	mv	s1,a1
    8000364c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000364e:	fffff097          	auipc	ra,0xfffff
    80003652:	846080e7          	jalr	-1978(ra) # 80001e94 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003656:	86ce                	mv	a3,s3
    80003658:	864a                	mv	a2,s2
    8000365a:	85a6                	mv	a1,s1
    8000365c:	6928                	ld	a0,80(a0)
    8000365e:	ffffe097          	auipc	ra,0xffffe
    80003662:	eaa080e7          	jalr	-342(ra) # 80001508 <copyinstr>
  if(err < 0)
    80003666:	00054763          	bltz	a0,80003674 <fetchstr+0x3a>
  return strlen(buf);
    8000366a:	8526                	mv	a0,s1
    8000366c:	ffffd097          	auipc	ra,0xffffd
    80003670:	7d6080e7          	jalr	2006(ra) # 80000e42 <strlen>
}
    80003674:	70a2                	ld	ra,40(sp)
    80003676:	7402                	ld	s0,32(sp)
    80003678:	64e2                	ld	s1,24(sp)
    8000367a:	6942                	ld	s2,16(sp)
    8000367c:	69a2                	ld	s3,8(sp)
    8000367e:	6145                	addi	sp,sp,48
    80003680:	8082                	ret

0000000080003682 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003682:	1101                	addi	sp,sp,-32
    80003684:	ec06                	sd	ra,24(sp)
    80003686:	e822                	sd	s0,16(sp)
    80003688:	e426                	sd	s1,8(sp)
    8000368a:	1000                	addi	s0,sp,32
    8000368c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000368e:	00000097          	auipc	ra,0x0
    80003692:	ef2080e7          	jalr	-270(ra) # 80003580 <argraw>
    80003696:	c088                	sw	a0,0(s1)
  return 0;
}
    80003698:	4501                	li	a0,0
    8000369a:	60e2                	ld	ra,24(sp)
    8000369c:	6442                	ld	s0,16(sp)
    8000369e:	64a2                	ld	s1,8(sp)
    800036a0:	6105                	addi	sp,sp,32
    800036a2:	8082                	ret

00000000800036a4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800036a4:	1101                	addi	sp,sp,-32
    800036a6:	ec06                	sd	ra,24(sp)
    800036a8:	e822                	sd	s0,16(sp)
    800036aa:	e426                	sd	s1,8(sp)
    800036ac:	1000                	addi	s0,sp,32
    800036ae:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800036b0:	00000097          	auipc	ra,0x0
    800036b4:	ed0080e7          	jalr	-304(ra) # 80003580 <argraw>
    800036b8:	e088                	sd	a0,0(s1)
  return 0;
}
    800036ba:	4501                	li	a0,0
    800036bc:	60e2                	ld	ra,24(sp)
    800036be:	6442                	ld	s0,16(sp)
    800036c0:	64a2                	ld	s1,8(sp)
    800036c2:	6105                	addi	sp,sp,32
    800036c4:	8082                	ret

00000000800036c6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800036c6:	1101                	addi	sp,sp,-32
    800036c8:	ec06                	sd	ra,24(sp)
    800036ca:	e822                	sd	s0,16(sp)
    800036cc:	e426                	sd	s1,8(sp)
    800036ce:	e04a                	sd	s2,0(sp)
    800036d0:	1000                	addi	s0,sp,32
    800036d2:	84ae                	mv	s1,a1
    800036d4:	8932                	mv	s2,a2
  *ip = argraw(n);
    800036d6:	00000097          	auipc	ra,0x0
    800036da:	eaa080e7          	jalr	-342(ra) # 80003580 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    800036de:	864a                	mv	a2,s2
    800036e0:	85a6                	mv	a1,s1
    800036e2:	00000097          	auipc	ra,0x0
    800036e6:	f58080e7          	jalr	-168(ra) # 8000363a <fetchstr>
}
    800036ea:	60e2                	ld	ra,24(sp)
    800036ec:	6442                	ld	s0,16(sp)
    800036ee:	64a2                	ld	s1,8(sp)
    800036f0:	6902                	ld	s2,0(sp)
    800036f2:	6105                	addi	sp,sp,32
    800036f4:	8082                	ret

00000000800036f6 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    800036f6:	1101                	addi	sp,sp,-32
    800036f8:	ec06                	sd	ra,24(sp)
    800036fa:	e822                	sd	s0,16(sp)
    800036fc:	e426                	sd	s1,8(sp)
    800036fe:	e04a                	sd	s2,0(sp)
    80003700:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003702:	ffffe097          	auipc	ra,0xffffe
    80003706:	792080e7          	jalr	1938(ra) # 80001e94 <myproc>
    8000370a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000370c:	05853903          	ld	s2,88(a0)
    80003710:	0a893783          	ld	a5,168(s2)
    80003714:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003718:	37fd                	addiw	a5,a5,-1
    8000371a:	4751                	li	a4,20
    8000371c:	00f76f63          	bltu	a4,a5,8000373a <syscall+0x44>
    80003720:	00369713          	slli	a4,a3,0x3
    80003724:	00006797          	auipc	a5,0x6
    80003728:	4b478793          	addi	a5,a5,1204 # 80009bd8 <syscalls>
    8000372c:	97ba                	add	a5,a5,a4
    8000372e:	639c                	ld	a5,0(a5)
    80003730:	c789                	beqz	a5,8000373a <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80003732:	9782                	jalr	a5
    80003734:	06a93823          	sd	a0,112(s2)
    80003738:	a839                	j	80003756 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000373a:	15848613          	addi	a2,s1,344
    8000373e:	588c                	lw	a1,48(s1)
    80003740:	00006517          	auipc	a0,0x6
    80003744:	46050513          	addi	a0,a0,1120 # 80009ba0 <states.0+0x250>
    80003748:	ffffd097          	auipc	ra,0xffffd
    8000374c:	e2c080e7          	jalr	-468(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003750:	6cbc                	ld	a5,88(s1)
    80003752:	577d                	li	a4,-1
    80003754:	fbb8                	sd	a4,112(a5)
  }
}
    80003756:	60e2                	ld	ra,24(sp)
    80003758:	6442                	ld	s0,16(sp)
    8000375a:	64a2                	ld	s1,8(sp)
    8000375c:	6902                	ld	s2,0(sp)
    8000375e:	6105                	addi	sp,sp,32
    80003760:	8082                	ret

0000000080003762 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003762:	1101                	addi	sp,sp,-32
    80003764:	ec06                	sd	ra,24(sp)
    80003766:	e822                	sd	s0,16(sp)
    80003768:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    8000376a:	fec40593          	addi	a1,s0,-20
    8000376e:	4501                	li	a0,0
    80003770:	00000097          	auipc	ra,0x0
    80003774:	f12080e7          	jalr	-238(ra) # 80003682 <argint>
    return -1;
    80003778:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000377a:	00054963          	bltz	a0,8000378c <sys_exit+0x2a>
  exit(n);
    8000377e:	fec42503          	lw	a0,-20(s0)
    80003782:	fffff097          	auipc	ra,0xfffff
    80003786:	f10080e7          	jalr	-240(ra) # 80002692 <exit>
  return 0;  // not reached
    8000378a:	4781                	li	a5,0
}
    8000378c:	853e                	mv	a0,a5
    8000378e:	60e2                	ld	ra,24(sp)
    80003790:	6442                	ld	s0,16(sp)
    80003792:	6105                	addi	sp,sp,32
    80003794:	8082                	ret

0000000080003796 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003796:	1141                	addi	sp,sp,-16
    80003798:	e406                	sd	ra,8(sp)
    8000379a:	e022                	sd	s0,0(sp)
    8000379c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000379e:	ffffe097          	auipc	ra,0xffffe
    800037a2:	6f6080e7          	jalr	1782(ra) # 80001e94 <myproc>
}
    800037a6:	5908                	lw	a0,48(a0)
    800037a8:	60a2                	ld	ra,8(sp)
    800037aa:	6402                	ld	s0,0(sp)
    800037ac:	0141                	addi	sp,sp,16
    800037ae:	8082                	ret

00000000800037b0 <sys_fork>:

uint64
sys_fork(void)
{
    800037b0:	1141                	addi	sp,sp,-16
    800037b2:	e406                	sd	ra,8(sp)
    800037b4:	e022                	sd	s0,0(sp)
    800037b6:	0800                	addi	s0,sp,16
  return fork();
    800037b8:	fffff097          	auipc	ra,0xfffff
    800037bc:	458080e7          	jalr	1112(ra) # 80002c10 <fork>
}
    800037c0:	60a2                	ld	ra,8(sp)
    800037c2:	6402                	ld	s0,0(sp)
    800037c4:	0141                	addi	sp,sp,16
    800037c6:	8082                	ret

00000000800037c8 <sys_wait>:

uint64
sys_wait(void)
{
    800037c8:	1101                	addi	sp,sp,-32
    800037ca:	ec06                	sd	ra,24(sp)
    800037cc:	e822                	sd	s0,16(sp)
    800037ce:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    800037d0:	fe840593          	addi	a1,s0,-24
    800037d4:	4501                	li	a0,0
    800037d6:	00000097          	auipc	ra,0x0
    800037da:	ece080e7          	jalr	-306(ra) # 800036a4 <argaddr>
    800037de:	87aa                	mv	a5,a0
    return -1;
    800037e0:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800037e2:	0007c863          	bltz	a5,800037f2 <sys_wait+0x2a>
  return wait(p);
    800037e6:	fe843503          	ld	a0,-24(s0)
    800037ea:	fffff097          	auipc	ra,0xfffff
    800037ee:	cb0080e7          	jalr	-848(ra) # 8000249a <wait>
}
    800037f2:	60e2                	ld	ra,24(sp)
    800037f4:	6442                	ld	s0,16(sp)
    800037f6:	6105                	addi	sp,sp,32
    800037f8:	8082                	ret

00000000800037fa <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800037fa:	7179                	addi	sp,sp,-48
    800037fc:	f406                	sd	ra,40(sp)
    800037fe:	f022                	sd	s0,32(sp)
    80003800:	ec26                	sd	s1,24(sp)
    80003802:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003804:	fdc40593          	addi	a1,s0,-36
    80003808:	4501                	li	a0,0
    8000380a:	00000097          	auipc	ra,0x0
    8000380e:	e78080e7          	jalr	-392(ra) # 80003682 <argint>
    return -1;
    80003812:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003814:	00054f63          	bltz	a0,80003832 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003818:	ffffe097          	auipc	ra,0xffffe
    8000381c:	67c080e7          	jalr	1660(ra) # 80001e94 <myproc>
    80003820:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80003822:	fdc42503          	lw	a0,-36(s0)
    80003826:	fffff097          	auipc	ra,0xfffff
    8000382a:	9d8080e7          	jalr	-1576(ra) # 800021fe <growproc>
    8000382e:	00054863          	bltz	a0,8000383e <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003832:	8526                	mv	a0,s1
    80003834:	70a2                	ld	ra,40(sp)
    80003836:	7402                	ld	s0,32(sp)
    80003838:	64e2                	ld	s1,24(sp)
    8000383a:	6145                	addi	sp,sp,48
    8000383c:	8082                	ret
    return -1;
    8000383e:	54fd                	li	s1,-1
    80003840:	bfcd                	j	80003832 <sys_sbrk+0x38>

0000000080003842 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003842:	7139                	addi	sp,sp,-64
    80003844:	fc06                	sd	ra,56(sp)
    80003846:	f822                	sd	s0,48(sp)
    80003848:	f426                	sd	s1,40(sp)
    8000384a:	f04a                	sd	s2,32(sp)
    8000384c:	ec4e                	sd	s3,24(sp)
    8000384e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003850:	fcc40593          	addi	a1,s0,-52
    80003854:	4501                	li	a0,0
    80003856:	00000097          	auipc	ra,0x0
    8000385a:	e2c080e7          	jalr	-468(ra) # 80003682 <argint>
    return -1;
    8000385e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003860:	06054563          	bltz	a0,800038ca <sys_sleep+0x88>
  acquire(&tickslock);
    80003864:	0001e517          	auipc	a0,0x1e
    80003868:	06c50513          	addi	a0,a0,108 # 800218d0 <tickslock>
    8000386c:	ffffd097          	auipc	ra,0xffffd
    80003870:	356080e7          	jalr	854(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    80003874:	00007917          	auipc	s2,0x7
    80003878:	7bc92903          	lw	s2,1980(s2) # 8000b030 <ticks>
  while(ticks - ticks0 < n){
    8000387c:	fcc42783          	lw	a5,-52(s0)
    80003880:	cf85                	beqz	a5,800038b8 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003882:	0001e997          	auipc	s3,0x1e
    80003886:	04e98993          	addi	s3,s3,78 # 800218d0 <tickslock>
    8000388a:	00007497          	auipc	s1,0x7
    8000388e:	7a648493          	addi	s1,s1,1958 # 8000b030 <ticks>
    if(myproc()->killed){
    80003892:	ffffe097          	auipc	ra,0xffffe
    80003896:	602080e7          	jalr	1538(ra) # 80001e94 <myproc>
    8000389a:	551c                	lw	a5,40(a0)
    8000389c:	ef9d                	bnez	a5,800038da <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000389e:	85ce                	mv	a1,s3
    800038a0:	8526                	mv	a0,s1
    800038a2:	fffff097          	auipc	ra,0xfffff
    800038a6:	b94080e7          	jalr	-1132(ra) # 80002436 <sleep>
  while(ticks - ticks0 < n){
    800038aa:	409c                	lw	a5,0(s1)
    800038ac:	412787bb          	subw	a5,a5,s2
    800038b0:	fcc42703          	lw	a4,-52(s0)
    800038b4:	fce7efe3          	bltu	a5,a4,80003892 <sys_sleep+0x50>
  }
  release(&tickslock);
    800038b8:	0001e517          	auipc	a0,0x1e
    800038bc:	01850513          	addi	a0,a0,24 # 800218d0 <tickslock>
    800038c0:	ffffd097          	auipc	ra,0xffffd
    800038c4:	3b6080e7          	jalr	950(ra) # 80000c76 <release>
  return 0;
    800038c8:	4781                	li	a5,0
}
    800038ca:	853e                	mv	a0,a5
    800038cc:	70e2                	ld	ra,56(sp)
    800038ce:	7442                	ld	s0,48(sp)
    800038d0:	74a2                	ld	s1,40(sp)
    800038d2:	7902                	ld	s2,32(sp)
    800038d4:	69e2                	ld	s3,24(sp)
    800038d6:	6121                	addi	sp,sp,64
    800038d8:	8082                	ret
      release(&tickslock);
    800038da:	0001e517          	auipc	a0,0x1e
    800038de:	ff650513          	addi	a0,a0,-10 # 800218d0 <tickslock>
    800038e2:	ffffd097          	auipc	ra,0xffffd
    800038e6:	394080e7          	jalr	916(ra) # 80000c76 <release>
      return -1;
    800038ea:	57fd                	li	a5,-1
    800038ec:	bff9                	j	800038ca <sys_sleep+0x88>

00000000800038ee <sys_kill>:

uint64
sys_kill(void)
{
    800038ee:	1101                	addi	sp,sp,-32
    800038f0:	ec06                	sd	ra,24(sp)
    800038f2:	e822                	sd	s0,16(sp)
    800038f4:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800038f6:	fec40593          	addi	a1,s0,-20
    800038fa:	4501                	li	a0,0
    800038fc:	00000097          	auipc	ra,0x0
    80003900:	d86080e7          	jalr	-634(ra) # 80003682 <argint>
    80003904:	87aa                	mv	a5,a0
    return -1;
    80003906:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003908:	0007c863          	bltz	a5,80003918 <sys_kill+0x2a>
  return kill(pid);
    8000390c:	fec42503          	lw	a0,-20(s0)
    80003910:	fffff097          	auipc	ra,0xfffff
    80003914:	e62080e7          	jalr	-414(ra) # 80002772 <kill>
}
    80003918:	60e2                	ld	ra,24(sp)
    8000391a:	6442                	ld	s0,16(sp)
    8000391c:	6105                	addi	sp,sp,32
    8000391e:	8082                	ret

0000000080003920 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003920:	1101                	addi	sp,sp,-32
    80003922:	ec06                	sd	ra,24(sp)
    80003924:	e822                	sd	s0,16(sp)
    80003926:	e426                	sd	s1,8(sp)
    80003928:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000392a:	0001e517          	auipc	a0,0x1e
    8000392e:	fa650513          	addi	a0,a0,-90 # 800218d0 <tickslock>
    80003932:	ffffd097          	auipc	ra,0xffffd
    80003936:	290080e7          	jalr	656(ra) # 80000bc2 <acquire>
  xticks = ticks;
    8000393a:	00007497          	auipc	s1,0x7
    8000393e:	6f64a483          	lw	s1,1782(s1) # 8000b030 <ticks>
  release(&tickslock);
    80003942:	0001e517          	auipc	a0,0x1e
    80003946:	f8e50513          	addi	a0,a0,-114 # 800218d0 <tickslock>
    8000394a:	ffffd097          	auipc	ra,0xffffd
    8000394e:	32c080e7          	jalr	812(ra) # 80000c76 <release>
  return xticks;
}
    80003952:	02049513          	slli	a0,s1,0x20
    80003956:	9101                	srli	a0,a0,0x20
    80003958:	60e2                	ld	ra,24(sp)
    8000395a:	6442                	ld	s0,16(sp)
    8000395c:	64a2                	ld	s1,8(sp)
    8000395e:	6105                	addi	sp,sp,32
    80003960:	8082                	ret

0000000080003962 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003962:	7179                	addi	sp,sp,-48
    80003964:	f406                	sd	ra,40(sp)
    80003966:	f022                	sd	s0,32(sp)
    80003968:	ec26                	sd	s1,24(sp)
    8000396a:	e84a                	sd	s2,16(sp)
    8000396c:	e44e                	sd	s3,8(sp)
    8000396e:	e052                	sd	s4,0(sp)
    80003970:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003972:	00006597          	auipc	a1,0x6
    80003976:	31658593          	addi	a1,a1,790 # 80009c88 <syscalls+0xb0>
    8000397a:	0001e517          	auipc	a0,0x1e
    8000397e:	f6e50513          	addi	a0,a0,-146 # 800218e8 <bcache>
    80003982:	ffffd097          	auipc	ra,0xffffd
    80003986:	1b0080e7          	jalr	432(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000398a:	00026797          	auipc	a5,0x26
    8000398e:	f5e78793          	addi	a5,a5,-162 # 800298e8 <bcache+0x8000>
    80003992:	00026717          	auipc	a4,0x26
    80003996:	1be70713          	addi	a4,a4,446 # 80029b50 <bcache+0x8268>
    8000399a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000399e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800039a2:	0001e497          	auipc	s1,0x1e
    800039a6:	f5e48493          	addi	s1,s1,-162 # 80021900 <bcache+0x18>
    b->next = bcache.head.next;
    800039aa:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800039ac:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800039ae:	00006a17          	auipc	s4,0x6
    800039b2:	2e2a0a13          	addi	s4,s4,738 # 80009c90 <syscalls+0xb8>
    b->next = bcache.head.next;
    800039b6:	2b893783          	ld	a5,696(s2)
    800039ba:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800039bc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800039c0:	85d2                	mv	a1,s4
    800039c2:	01048513          	addi	a0,s1,16
    800039c6:	00001097          	auipc	ra,0x1
    800039ca:	7e4080e7          	jalr	2020(ra) # 800051aa <initsleeplock>
    bcache.head.next->prev = b;
    800039ce:	2b893783          	ld	a5,696(s2)
    800039d2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800039d4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800039d8:	45848493          	addi	s1,s1,1112
    800039dc:	fd349de3          	bne	s1,s3,800039b6 <binit+0x54>
  }
}
    800039e0:	70a2                	ld	ra,40(sp)
    800039e2:	7402                	ld	s0,32(sp)
    800039e4:	64e2                	ld	s1,24(sp)
    800039e6:	6942                	ld	s2,16(sp)
    800039e8:	69a2                	ld	s3,8(sp)
    800039ea:	6a02                	ld	s4,0(sp)
    800039ec:	6145                	addi	sp,sp,48
    800039ee:	8082                	ret

00000000800039f0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800039f0:	7179                	addi	sp,sp,-48
    800039f2:	f406                	sd	ra,40(sp)
    800039f4:	f022                	sd	s0,32(sp)
    800039f6:	ec26                	sd	s1,24(sp)
    800039f8:	e84a                	sd	s2,16(sp)
    800039fa:	e44e                	sd	s3,8(sp)
    800039fc:	1800                	addi	s0,sp,48
    800039fe:	892a                	mv	s2,a0
    80003a00:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003a02:	0001e517          	auipc	a0,0x1e
    80003a06:	ee650513          	addi	a0,a0,-282 # 800218e8 <bcache>
    80003a0a:	ffffd097          	auipc	ra,0xffffd
    80003a0e:	1b8080e7          	jalr	440(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003a12:	00026497          	auipc	s1,0x26
    80003a16:	18e4b483          	ld	s1,398(s1) # 80029ba0 <bcache+0x82b8>
    80003a1a:	00026797          	auipc	a5,0x26
    80003a1e:	13678793          	addi	a5,a5,310 # 80029b50 <bcache+0x8268>
    80003a22:	02f48f63          	beq	s1,a5,80003a60 <bread+0x70>
    80003a26:	873e                	mv	a4,a5
    80003a28:	a021                	j	80003a30 <bread+0x40>
    80003a2a:	68a4                	ld	s1,80(s1)
    80003a2c:	02e48a63          	beq	s1,a4,80003a60 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003a30:	449c                	lw	a5,8(s1)
    80003a32:	ff279ce3          	bne	a5,s2,80003a2a <bread+0x3a>
    80003a36:	44dc                	lw	a5,12(s1)
    80003a38:	ff3799e3          	bne	a5,s3,80003a2a <bread+0x3a>
      b->refcnt++;
    80003a3c:	40bc                	lw	a5,64(s1)
    80003a3e:	2785                	addiw	a5,a5,1
    80003a40:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003a42:	0001e517          	auipc	a0,0x1e
    80003a46:	ea650513          	addi	a0,a0,-346 # 800218e8 <bcache>
    80003a4a:	ffffd097          	auipc	ra,0xffffd
    80003a4e:	22c080e7          	jalr	556(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003a52:	01048513          	addi	a0,s1,16
    80003a56:	00001097          	auipc	ra,0x1
    80003a5a:	78e080e7          	jalr	1934(ra) # 800051e4 <acquiresleep>
      return b;
    80003a5e:	a8b9                	j	80003abc <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003a60:	00026497          	auipc	s1,0x26
    80003a64:	1384b483          	ld	s1,312(s1) # 80029b98 <bcache+0x82b0>
    80003a68:	00026797          	auipc	a5,0x26
    80003a6c:	0e878793          	addi	a5,a5,232 # 80029b50 <bcache+0x8268>
    80003a70:	00f48863          	beq	s1,a5,80003a80 <bread+0x90>
    80003a74:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003a76:	40bc                	lw	a5,64(s1)
    80003a78:	cf81                	beqz	a5,80003a90 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003a7a:	64a4                	ld	s1,72(s1)
    80003a7c:	fee49de3          	bne	s1,a4,80003a76 <bread+0x86>
  panic("bget: no buffers");
    80003a80:	00006517          	auipc	a0,0x6
    80003a84:	21850513          	addi	a0,a0,536 # 80009c98 <syscalls+0xc0>
    80003a88:	ffffd097          	auipc	ra,0xffffd
    80003a8c:	aa2080e7          	jalr	-1374(ra) # 8000052a <panic>
      b->dev = dev;
    80003a90:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003a94:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003a98:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003a9c:	4785                	li	a5,1
    80003a9e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003aa0:	0001e517          	auipc	a0,0x1e
    80003aa4:	e4850513          	addi	a0,a0,-440 # 800218e8 <bcache>
    80003aa8:	ffffd097          	auipc	ra,0xffffd
    80003aac:	1ce080e7          	jalr	462(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003ab0:	01048513          	addi	a0,s1,16
    80003ab4:	00001097          	auipc	ra,0x1
    80003ab8:	730080e7          	jalr	1840(ra) # 800051e4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003abc:	409c                	lw	a5,0(s1)
    80003abe:	cb89                	beqz	a5,80003ad0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003ac0:	8526                	mv	a0,s1
    80003ac2:	70a2                	ld	ra,40(sp)
    80003ac4:	7402                	ld	s0,32(sp)
    80003ac6:	64e2                	ld	s1,24(sp)
    80003ac8:	6942                	ld	s2,16(sp)
    80003aca:	69a2                	ld	s3,8(sp)
    80003acc:	6145                	addi	sp,sp,48
    80003ace:	8082                	ret
    virtio_disk_rw(b, 0);
    80003ad0:	4581                	li	a1,0
    80003ad2:	8526                	mv	a0,s1
    80003ad4:	00003097          	auipc	ra,0x3
    80003ad8:	4c2080e7          	jalr	1218(ra) # 80006f96 <virtio_disk_rw>
    b->valid = 1;
    80003adc:	4785                	li	a5,1
    80003ade:	c09c                	sw	a5,0(s1)
  return b;
    80003ae0:	b7c5                	j	80003ac0 <bread+0xd0>

0000000080003ae2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003ae2:	1101                	addi	sp,sp,-32
    80003ae4:	ec06                	sd	ra,24(sp)
    80003ae6:	e822                	sd	s0,16(sp)
    80003ae8:	e426                	sd	s1,8(sp)
    80003aea:	1000                	addi	s0,sp,32
    80003aec:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003aee:	0541                	addi	a0,a0,16
    80003af0:	00001097          	auipc	ra,0x1
    80003af4:	78e080e7          	jalr	1934(ra) # 8000527e <holdingsleep>
    80003af8:	cd01                	beqz	a0,80003b10 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003afa:	4585                	li	a1,1
    80003afc:	8526                	mv	a0,s1
    80003afe:	00003097          	auipc	ra,0x3
    80003b02:	498080e7          	jalr	1176(ra) # 80006f96 <virtio_disk_rw>
}
    80003b06:	60e2                	ld	ra,24(sp)
    80003b08:	6442                	ld	s0,16(sp)
    80003b0a:	64a2                	ld	s1,8(sp)
    80003b0c:	6105                	addi	sp,sp,32
    80003b0e:	8082                	ret
    panic("bwrite");
    80003b10:	00006517          	auipc	a0,0x6
    80003b14:	1a050513          	addi	a0,a0,416 # 80009cb0 <syscalls+0xd8>
    80003b18:	ffffd097          	auipc	ra,0xffffd
    80003b1c:	a12080e7          	jalr	-1518(ra) # 8000052a <panic>

0000000080003b20 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003b20:	1101                	addi	sp,sp,-32
    80003b22:	ec06                	sd	ra,24(sp)
    80003b24:	e822                	sd	s0,16(sp)
    80003b26:	e426                	sd	s1,8(sp)
    80003b28:	e04a                	sd	s2,0(sp)
    80003b2a:	1000                	addi	s0,sp,32
    80003b2c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003b2e:	01050913          	addi	s2,a0,16
    80003b32:	854a                	mv	a0,s2
    80003b34:	00001097          	auipc	ra,0x1
    80003b38:	74a080e7          	jalr	1866(ra) # 8000527e <holdingsleep>
    80003b3c:	c92d                	beqz	a0,80003bae <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003b3e:	854a                	mv	a0,s2
    80003b40:	00001097          	auipc	ra,0x1
    80003b44:	6fa080e7          	jalr	1786(ra) # 8000523a <releasesleep>

  acquire(&bcache.lock);
    80003b48:	0001e517          	auipc	a0,0x1e
    80003b4c:	da050513          	addi	a0,a0,-608 # 800218e8 <bcache>
    80003b50:	ffffd097          	auipc	ra,0xffffd
    80003b54:	072080e7          	jalr	114(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003b58:	40bc                	lw	a5,64(s1)
    80003b5a:	37fd                	addiw	a5,a5,-1
    80003b5c:	0007871b          	sext.w	a4,a5
    80003b60:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003b62:	eb05                	bnez	a4,80003b92 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003b64:	68bc                	ld	a5,80(s1)
    80003b66:	64b8                	ld	a4,72(s1)
    80003b68:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003b6a:	64bc                	ld	a5,72(s1)
    80003b6c:	68b8                	ld	a4,80(s1)
    80003b6e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003b70:	00026797          	auipc	a5,0x26
    80003b74:	d7878793          	addi	a5,a5,-648 # 800298e8 <bcache+0x8000>
    80003b78:	2b87b703          	ld	a4,696(a5)
    80003b7c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003b7e:	00026717          	auipc	a4,0x26
    80003b82:	fd270713          	addi	a4,a4,-46 # 80029b50 <bcache+0x8268>
    80003b86:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003b88:	2b87b703          	ld	a4,696(a5)
    80003b8c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003b8e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003b92:	0001e517          	auipc	a0,0x1e
    80003b96:	d5650513          	addi	a0,a0,-682 # 800218e8 <bcache>
    80003b9a:	ffffd097          	auipc	ra,0xffffd
    80003b9e:	0dc080e7          	jalr	220(ra) # 80000c76 <release>
}
    80003ba2:	60e2                	ld	ra,24(sp)
    80003ba4:	6442                	ld	s0,16(sp)
    80003ba6:	64a2                	ld	s1,8(sp)
    80003ba8:	6902                	ld	s2,0(sp)
    80003baa:	6105                	addi	sp,sp,32
    80003bac:	8082                	ret
    panic("brelse");
    80003bae:	00006517          	auipc	a0,0x6
    80003bb2:	10a50513          	addi	a0,a0,266 # 80009cb8 <syscalls+0xe0>
    80003bb6:	ffffd097          	auipc	ra,0xffffd
    80003bba:	974080e7          	jalr	-1676(ra) # 8000052a <panic>

0000000080003bbe <bpin>:

void
bpin(struct buf *b) {
    80003bbe:	1101                	addi	sp,sp,-32
    80003bc0:	ec06                	sd	ra,24(sp)
    80003bc2:	e822                	sd	s0,16(sp)
    80003bc4:	e426                	sd	s1,8(sp)
    80003bc6:	1000                	addi	s0,sp,32
    80003bc8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003bca:	0001e517          	auipc	a0,0x1e
    80003bce:	d1e50513          	addi	a0,a0,-738 # 800218e8 <bcache>
    80003bd2:	ffffd097          	auipc	ra,0xffffd
    80003bd6:	ff0080e7          	jalr	-16(ra) # 80000bc2 <acquire>
  b->refcnt++;
    80003bda:	40bc                	lw	a5,64(s1)
    80003bdc:	2785                	addiw	a5,a5,1
    80003bde:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003be0:	0001e517          	auipc	a0,0x1e
    80003be4:	d0850513          	addi	a0,a0,-760 # 800218e8 <bcache>
    80003be8:	ffffd097          	auipc	ra,0xffffd
    80003bec:	08e080e7          	jalr	142(ra) # 80000c76 <release>
}
    80003bf0:	60e2                	ld	ra,24(sp)
    80003bf2:	6442                	ld	s0,16(sp)
    80003bf4:	64a2                	ld	s1,8(sp)
    80003bf6:	6105                	addi	sp,sp,32
    80003bf8:	8082                	ret

0000000080003bfa <bunpin>:

void
bunpin(struct buf *b) {
    80003bfa:	1101                	addi	sp,sp,-32
    80003bfc:	ec06                	sd	ra,24(sp)
    80003bfe:	e822                	sd	s0,16(sp)
    80003c00:	e426                	sd	s1,8(sp)
    80003c02:	1000                	addi	s0,sp,32
    80003c04:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003c06:	0001e517          	auipc	a0,0x1e
    80003c0a:	ce250513          	addi	a0,a0,-798 # 800218e8 <bcache>
    80003c0e:	ffffd097          	auipc	ra,0xffffd
    80003c12:	fb4080e7          	jalr	-76(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003c16:	40bc                	lw	a5,64(s1)
    80003c18:	37fd                	addiw	a5,a5,-1
    80003c1a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003c1c:	0001e517          	auipc	a0,0x1e
    80003c20:	ccc50513          	addi	a0,a0,-820 # 800218e8 <bcache>
    80003c24:	ffffd097          	auipc	ra,0xffffd
    80003c28:	052080e7          	jalr	82(ra) # 80000c76 <release>
}
    80003c2c:	60e2                	ld	ra,24(sp)
    80003c2e:	6442                	ld	s0,16(sp)
    80003c30:	64a2                	ld	s1,8(sp)
    80003c32:	6105                	addi	sp,sp,32
    80003c34:	8082                	ret

0000000080003c36 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003c36:	1101                	addi	sp,sp,-32
    80003c38:	ec06                	sd	ra,24(sp)
    80003c3a:	e822                	sd	s0,16(sp)
    80003c3c:	e426                	sd	s1,8(sp)
    80003c3e:	e04a                	sd	s2,0(sp)
    80003c40:	1000                	addi	s0,sp,32
    80003c42:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003c44:	00d5d59b          	srliw	a1,a1,0xd
    80003c48:	00026797          	auipc	a5,0x26
    80003c4c:	37c7a783          	lw	a5,892(a5) # 80029fc4 <sb+0x1c>
    80003c50:	9dbd                	addw	a1,a1,a5
    80003c52:	00000097          	auipc	ra,0x0
    80003c56:	d9e080e7          	jalr	-610(ra) # 800039f0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003c5a:	0074f713          	andi	a4,s1,7
    80003c5e:	4785                	li	a5,1
    80003c60:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003c64:	14ce                	slli	s1,s1,0x33
    80003c66:	90d9                	srli	s1,s1,0x36
    80003c68:	00950733          	add	a4,a0,s1
    80003c6c:	05874703          	lbu	a4,88(a4)
    80003c70:	00e7f6b3          	and	a3,a5,a4
    80003c74:	c69d                	beqz	a3,80003ca2 <bfree+0x6c>
    80003c76:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003c78:	94aa                	add	s1,s1,a0
    80003c7a:	fff7c793          	not	a5,a5
    80003c7e:	8ff9                	and	a5,a5,a4
    80003c80:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003c84:	00001097          	auipc	ra,0x1
    80003c88:	440080e7          	jalr	1088(ra) # 800050c4 <log_write>
  brelse(bp);
    80003c8c:	854a                	mv	a0,s2
    80003c8e:	00000097          	auipc	ra,0x0
    80003c92:	e92080e7          	jalr	-366(ra) # 80003b20 <brelse>
}
    80003c96:	60e2                	ld	ra,24(sp)
    80003c98:	6442                	ld	s0,16(sp)
    80003c9a:	64a2                	ld	s1,8(sp)
    80003c9c:	6902                	ld	s2,0(sp)
    80003c9e:	6105                	addi	sp,sp,32
    80003ca0:	8082                	ret
    panic("freeing free block");
    80003ca2:	00006517          	auipc	a0,0x6
    80003ca6:	01e50513          	addi	a0,a0,30 # 80009cc0 <syscalls+0xe8>
    80003caa:	ffffd097          	auipc	ra,0xffffd
    80003cae:	880080e7          	jalr	-1920(ra) # 8000052a <panic>

0000000080003cb2 <balloc>:
{
    80003cb2:	711d                	addi	sp,sp,-96
    80003cb4:	ec86                	sd	ra,88(sp)
    80003cb6:	e8a2                	sd	s0,80(sp)
    80003cb8:	e4a6                	sd	s1,72(sp)
    80003cba:	e0ca                	sd	s2,64(sp)
    80003cbc:	fc4e                	sd	s3,56(sp)
    80003cbe:	f852                	sd	s4,48(sp)
    80003cc0:	f456                	sd	s5,40(sp)
    80003cc2:	f05a                	sd	s6,32(sp)
    80003cc4:	ec5e                	sd	s7,24(sp)
    80003cc6:	e862                	sd	s8,16(sp)
    80003cc8:	e466                	sd	s9,8(sp)
    80003cca:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003ccc:	00026797          	auipc	a5,0x26
    80003cd0:	2e07a783          	lw	a5,736(a5) # 80029fac <sb+0x4>
    80003cd4:	cbd1                	beqz	a5,80003d68 <balloc+0xb6>
    80003cd6:	8baa                	mv	s7,a0
    80003cd8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003cda:	00026b17          	auipc	s6,0x26
    80003cde:	2ceb0b13          	addi	s6,s6,718 # 80029fa8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ce2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003ce4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ce6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003ce8:	6c89                	lui	s9,0x2
    80003cea:	a831                	j	80003d06 <balloc+0x54>
    brelse(bp);
    80003cec:	854a                	mv	a0,s2
    80003cee:	00000097          	auipc	ra,0x0
    80003cf2:	e32080e7          	jalr	-462(ra) # 80003b20 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003cf6:	015c87bb          	addw	a5,s9,s5
    80003cfa:	00078a9b          	sext.w	s5,a5
    80003cfe:	004b2703          	lw	a4,4(s6)
    80003d02:	06eaf363          	bgeu	s5,a4,80003d68 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003d06:	41fad79b          	sraiw	a5,s5,0x1f
    80003d0a:	0137d79b          	srliw	a5,a5,0x13
    80003d0e:	015787bb          	addw	a5,a5,s5
    80003d12:	40d7d79b          	sraiw	a5,a5,0xd
    80003d16:	01cb2583          	lw	a1,28(s6)
    80003d1a:	9dbd                	addw	a1,a1,a5
    80003d1c:	855e                	mv	a0,s7
    80003d1e:	00000097          	auipc	ra,0x0
    80003d22:	cd2080e7          	jalr	-814(ra) # 800039f0 <bread>
    80003d26:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003d28:	004b2503          	lw	a0,4(s6)
    80003d2c:	000a849b          	sext.w	s1,s5
    80003d30:	8662                	mv	a2,s8
    80003d32:	faa4fde3          	bgeu	s1,a0,80003cec <balloc+0x3a>
      m = 1 << (bi % 8);
    80003d36:	41f6579b          	sraiw	a5,a2,0x1f
    80003d3a:	01d7d69b          	srliw	a3,a5,0x1d
    80003d3e:	00c6873b          	addw	a4,a3,a2
    80003d42:	00777793          	andi	a5,a4,7
    80003d46:	9f95                	subw	a5,a5,a3
    80003d48:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003d4c:	4037571b          	sraiw	a4,a4,0x3
    80003d50:	00e906b3          	add	a3,s2,a4
    80003d54:	0586c683          	lbu	a3,88(a3)
    80003d58:	00d7f5b3          	and	a1,a5,a3
    80003d5c:	cd91                	beqz	a1,80003d78 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003d5e:	2605                	addiw	a2,a2,1
    80003d60:	2485                	addiw	s1,s1,1
    80003d62:	fd4618e3          	bne	a2,s4,80003d32 <balloc+0x80>
    80003d66:	b759                	j	80003cec <balloc+0x3a>
  panic("balloc: out of blocks");
    80003d68:	00006517          	auipc	a0,0x6
    80003d6c:	f7050513          	addi	a0,a0,-144 # 80009cd8 <syscalls+0x100>
    80003d70:	ffffc097          	auipc	ra,0xffffc
    80003d74:	7ba080e7          	jalr	1978(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003d78:	974a                	add	a4,a4,s2
    80003d7a:	8fd5                	or	a5,a5,a3
    80003d7c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003d80:	854a                	mv	a0,s2
    80003d82:	00001097          	auipc	ra,0x1
    80003d86:	342080e7          	jalr	834(ra) # 800050c4 <log_write>
        brelse(bp);
    80003d8a:	854a                	mv	a0,s2
    80003d8c:	00000097          	auipc	ra,0x0
    80003d90:	d94080e7          	jalr	-620(ra) # 80003b20 <brelse>
  bp = bread(dev, bno);
    80003d94:	85a6                	mv	a1,s1
    80003d96:	855e                	mv	a0,s7
    80003d98:	00000097          	auipc	ra,0x0
    80003d9c:	c58080e7          	jalr	-936(ra) # 800039f0 <bread>
    80003da0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003da2:	40000613          	li	a2,1024
    80003da6:	4581                	li	a1,0
    80003da8:	05850513          	addi	a0,a0,88
    80003dac:	ffffd097          	auipc	ra,0xffffd
    80003db0:	f12080e7          	jalr	-238(ra) # 80000cbe <memset>
  log_write(bp);
    80003db4:	854a                	mv	a0,s2
    80003db6:	00001097          	auipc	ra,0x1
    80003dba:	30e080e7          	jalr	782(ra) # 800050c4 <log_write>
  brelse(bp);
    80003dbe:	854a                	mv	a0,s2
    80003dc0:	00000097          	auipc	ra,0x0
    80003dc4:	d60080e7          	jalr	-672(ra) # 80003b20 <brelse>
}
    80003dc8:	8526                	mv	a0,s1
    80003dca:	60e6                	ld	ra,88(sp)
    80003dcc:	6446                	ld	s0,80(sp)
    80003dce:	64a6                	ld	s1,72(sp)
    80003dd0:	6906                	ld	s2,64(sp)
    80003dd2:	79e2                	ld	s3,56(sp)
    80003dd4:	7a42                	ld	s4,48(sp)
    80003dd6:	7aa2                	ld	s5,40(sp)
    80003dd8:	7b02                	ld	s6,32(sp)
    80003dda:	6be2                	ld	s7,24(sp)
    80003ddc:	6c42                	ld	s8,16(sp)
    80003dde:	6ca2                	ld	s9,8(sp)
    80003de0:	6125                	addi	sp,sp,96
    80003de2:	8082                	ret

0000000080003de4 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003de4:	7179                	addi	sp,sp,-48
    80003de6:	f406                	sd	ra,40(sp)
    80003de8:	f022                	sd	s0,32(sp)
    80003dea:	ec26                	sd	s1,24(sp)
    80003dec:	e84a                	sd	s2,16(sp)
    80003dee:	e44e                	sd	s3,8(sp)
    80003df0:	e052                	sd	s4,0(sp)
    80003df2:	1800                	addi	s0,sp,48
    80003df4:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003df6:	47ad                	li	a5,11
    80003df8:	04b7fe63          	bgeu	a5,a1,80003e54 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003dfc:	ff45849b          	addiw	s1,a1,-12
    80003e00:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003e04:	0ff00793          	li	a5,255
    80003e08:	0ae7e463          	bltu	a5,a4,80003eb0 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003e0c:	08052583          	lw	a1,128(a0)
    80003e10:	c5b5                	beqz	a1,80003e7c <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003e12:	00092503          	lw	a0,0(s2)
    80003e16:	00000097          	auipc	ra,0x0
    80003e1a:	bda080e7          	jalr	-1062(ra) # 800039f0 <bread>
    80003e1e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003e20:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003e24:	02049713          	slli	a4,s1,0x20
    80003e28:	01e75593          	srli	a1,a4,0x1e
    80003e2c:	00b784b3          	add	s1,a5,a1
    80003e30:	0004a983          	lw	s3,0(s1)
    80003e34:	04098e63          	beqz	s3,80003e90 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003e38:	8552                	mv	a0,s4
    80003e3a:	00000097          	auipc	ra,0x0
    80003e3e:	ce6080e7          	jalr	-794(ra) # 80003b20 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003e42:	854e                	mv	a0,s3
    80003e44:	70a2                	ld	ra,40(sp)
    80003e46:	7402                	ld	s0,32(sp)
    80003e48:	64e2                	ld	s1,24(sp)
    80003e4a:	6942                	ld	s2,16(sp)
    80003e4c:	69a2                	ld	s3,8(sp)
    80003e4e:	6a02                	ld	s4,0(sp)
    80003e50:	6145                	addi	sp,sp,48
    80003e52:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003e54:	02059793          	slli	a5,a1,0x20
    80003e58:	01e7d593          	srli	a1,a5,0x1e
    80003e5c:	00b504b3          	add	s1,a0,a1
    80003e60:	0504a983          	lw	s3,80(s1)
    80003e64:	fc099fe3          	bnez	s3,80003e42 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003e68:	4108                	lw	a0,0(a0)
    80003e6a:	00000097          	auipc	ra,0x0
    80003e6e:	e48080e7          	jalr	-440(ra) # 80003cb2 <balloc>
    80003e72:	0005099b          	sext.w	s3,a0
    80003e76:	0534a823          	sw	s3,80(s1)
    80003e7a:	b7e1                	j	80003e42 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003e7c:	4108                	lw	a0,0(a0)
    80003e7e:	00000097          	auipc	ra,0x0
    80003e82:	e34080e7          	jalr	-460(ra) # 80003cb2 <balloc>
    80003e86:	0005059b          	sext.w	a1,a0
    80003e8a:	08b92023          	sw	a1,128(s2)
    80003e8e:	b751                	j	80003e12 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003e90:	00092503          	lw	a0,0(s2)
    80003e94:	00000097          	auipc	ra,0x0
    80003e98:	e1e080e7          	jalr	-482(ra) # 80003cb2 <balloc>
    80003e9c:	0005099b          	sext.w	s3,a0
    80003ea0:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003ea4:	8552                	mv	a0,s4
    80003ea6:	00001097          	auipc	ra,0x1
    80003eaa:	21e080e7          	jalr	542(ra) # 800050c4 <log_write>
    80003eae:	b769                	j	80003e38 <bmap+0x54>
  panic("bmap: out of range");
    80003eb0:	00006517          	auipc	a0,0x6
    80003eb4:	e4050513          	addi	a0,a0,-448 # 80009cf0 <syscalls+0x118>
    80003eb8:	ffffc097          	auipc	ra,0xffffc
    80003ebc:	672080e7          	jalr	1650(ra) # 8000052a <panic>

0000000080003ec0 <iget>:
{
    80003ec0:	7179                	addi	sp,sp,-48
    80003ec2:	f406                	sd	ra,40(sp)
    80003ec4:	f022                	sd	s0,32(sp)
    80003ec6:	ec26                	sd	s1,24(sp)
    80003ec8:	e84a                	sd	s2,16(sp)
    80003eca:	e44e                	sd	s3,8(sp)
    80003ecc:	e052                	sd	s4,0(sp)
    80003ece:	1800                	addi	s0,sp,48
    80003ed0:	89aa                	mv	s3,a0
    80003ed2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003ed4:	00026517          	auipc	a0,0x26
    80003ed8:	0f450513          	addi	a0,a0,244 # 80029fc8 <itable>
    80003edc:	ffffd097          	auipc	ra,0xffffd
    80003ee0:	ce6080e7          	jalr	-794(ra) # 80000bc2 <acquire>
  empty = 0;
    80003ee4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ee6:	00026497          	auipc	s1,0x26
    80003eea:	0fa48493          	addi	s1,s1,250 # 80029fe0 <itable+0x18>
    80003eee:	00028697          	auipc	a3,0x28
    80003ef2:	b8268693          	addi	a3,a3,-1150 # 8002ba70 <log>
    80003ef6:	a039                	j	80003f04 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ef8:	02090b63          	beqz	s2,80003f2e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003efc:	08848493          	addi	s1,s1,136
    80003f00:	02d48a63          	beq	s1,a3,80003f34 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003f04:	449c                	lw	a5,8(s1)
    80003f06:	fef059e3          	blez	a5,80003ef8 <iget+0x38>
    80003f0a:	4098                	lw	a4,0(s1)
    80003f0c:	ff3716e3          	bne	a4,s3,80003ef8 <iget+0x38>
    80003f10:	40d8                	lw	a4,4(s1)
    80003f12:	ff4713e3          	bne	a4,s4,80003ef8 <iget+0x38>
      ip->ref++;
    80003f16:	2785                	addiw	a5,a5,1
    80003f18:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003f1a:	00026517          	auipc	a0,0x26
    80003f1e:	0ae50513          	addi	a0,a0,174 # 80029fc8 <itable>
    80003f22:	ffffd097          	auipc	ra,0xffffd
    80003f26:	d54080e7          	jalr	-684(ra) # 80000c76 <release>
      return ip;
    80003f2a:	8926                	mv	s2,s1
    80003f2c:	a03d                	j	80003f5a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003f2e:	f7f9                	bnez	a5,80003efc <iget+0x3c>
    80003f30:	8926                	mv	s2,s1
    80003f32:	b7e9                	j	80003efc <iget+0x3c>
  if(empty == 0)
    80003f34:	02090c63          	beqz	s2,80003f6c <iget+0xac>
  ip->dev = dev;
    80003f38:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003f3c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003f40:	4785                	li	a5,1
    80003f42:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003f46:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003f4a:	00026517          	auipc	a0,0x26
    80003f4e:	07e50513          	addi	a0,a0,126 # 80029fc8 <itable>
    80003f52:	ffffd097          	auipc	ra,0xffffd
    80003f56:	d24080e7          	jalr	-732(ra) # 80000c76 <release>
}
    80003f5a:	854a                	mv	a0,s2
    80003f5c:	70a2                	ld	ra,40(sp)
    80003f5e:	7402                	ld	s0,32(sp)
    80003f60:	64e2                	ld	s1,24(sp)
    80003f62:	6942                	ld	s2,16(sp)
    80003f64:	69a2                	ld	s3,8(sp)
    80003f66:	6a02                	ld	s4,0(sp)
    80003f68:	6145                	addi	sp,sp,48
    80003f6a:	8082                	ret
    panic("iget: no inodes");
    80003f6c:	00006517          	auipc	a0,0x6
    80003f70:	d9c50513          	addi	a0,a0,-612 # 80009d08 <syscalls+0x130>
    80003f74:	ffffc097          	auipc	ra,0xffffc
    80003f78:	5b6080e7          	jalr	1462(ra) # 8000052a <panic>

0000000080003f7c <fsinit>:
fsinit(int dev) {
    80003f7c:	7179                	addi	sp,sp,-48
    80003f7e:	f406                	sd	ra,40(sp)
    80003f80:	f022                	sd	s0,32(sp)
    80003f82:	ec26                	sd	s1,24(sp)
    80003f84:	e84a                	sd	s2,16(sp)
    80003f86:	e44e                	sd	s3,8(sp)
    80003f88:	1800                	addi	s0,sp,48
    80003f8a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003f8c:	4585                	li	a1,1
    80003f8e:	00000097          	auipc	ra,0x0
    80003f92:	a62080e7          	jalr	-1438(ra) # 800039f0 <bread>
    80003f96:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003f98:	00026997          	auipc	s3,0x26
    80003f9c:	01098993          	addi	s3,s3,16 # 80029fa8 <sb>
    80003fa0:	02000613          	li	a2,32
    80003fa4:	05850593          	addi	a1,a0,88
    80003fa8:	854e                	mv	a0,s3
    80003faa:	ffffd097          	auipc	ra,0xffffd
    80003fae:	d70080e7          	jalr	-656(ra) # 80000d1a <memmove>
  brelse(bp);
    80003fb2:	8526                	mv	a0,s1
    80003fb4:	00000097          	auipc	ra,0x0
    80003fb8:	b6c080e7          	jalr	-1172(ra) # 80003b20 <brelse>
  if(sb.magic != FSMAGIC)
    80003fbc:	0009a703          	lw	a4,0(s3)
    80003fc0:	102037b7          	lui	a5,0x10203
    80003fc4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003fc8:	02f71263          	bne	a4,a5,80003fec <fsinit+0x70>
  initlog(dev, &sb);
    80003fcc:	00026597          	auipc	a1,0x26
    80003fd0:	fdc58593          	addi	a1,a1,-36 # 80029fa8 <sb>
    80003fd4:	854a                	mv	a0,s2
    80003fd6:	00001097          	auipc	ra,0x1
    80003fda:	e70080e7          	jalr	-400(ra) # 80004e46 <initlog>
}
    80003fde:	70a2                	ld	ra,40(sp)
    80003fe0:	7402                	ld	s0,32(sp)
    80003fe2:	64e2                	ld	s1,24(sp)
    80003fe4:	6942                	ld	s2,16(sp)
    80003fe6:	69a2                	ld	s3,8(sp)
    80003fe8:	6145                	addi	sp,sp,48
    80003fea:	8082                	ret
    panic("invalid file system");
    80003fec:	00006517          	auipc	a0,0x6
    80003ff0:	d2c50513          	addi	a0,a0,-724 # 80009d18 <syscalls+0x140>
    80003ff4:	ffffc097          	auipc	ra,0xffffc
    80003ff8:	536080e7          	jalr	1334(ra) # 8000052a <panic>

0000000080003ffc <iinit>:
{
    80003ffc:	7179                	addi	sp,sp,-48
    80003ffe:	f406                	sd	ra,40(sp)
    80004000:	f022                	sd	s0,32(sp)
    80004002:	ec26                	sd	s1,24(sp)
    80004004:	e84a                	sd	s2,16(sp)
    80004006:	e44e                	sd	s3,8(sp)
    80004008:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000400a:	00006597          	auipc	a1,0x6
    8000400e:	d2658593          	addi	a1,a1,-730 # 80009d30 <syscalls+0x158>
    80004012:	00026517          	auipc	a0,0x26
    80004016:	fb650513          	addi	a0,a0,-74 # 80029fc8 <itable>
    8000401a:	ffffd097          	auipc	ra,0xffffd
    8000401e:	b18080e7          	jalr	-1256(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80004022:	00026497          	auipc	s1,0x26
    80004026:	fce48493          	addi	s1,s1,-50 # 80029ff0 <itable+0x28>
    8000402a:	00028997          	auipc	s3,0x28
    8000402e:	a5698993          	addi	s3,s3,-1450 # 8002ba80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004032:	00006917          	auipc	s2,0x6
    80004036:	d0690913          	addi	s2,s2,-762 # 80009d38 <syscalls+0x160>
    8000403a:	85ca                	mv	a1,s2
    8000403c:	8526                	mv	a0,s1
    8000403e:	00001097          	auipc	ra,0x1
    80004042:	16c080e7          	jalr	364(ra) # 800051aa <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004046:	08848493          	addi	s1,s1,136
    8000404a:	ff3498e3          	bne	s1,s3,8000403a <iinit+0x3e>
}
    8000404e:	70a2                	ld	ra,40(sp)
    80004050:	7402                	ld	s0,32(sp)
    80004052:	64e2                	ld	s1,24(sp)
    80004054:	6942                	ld	s2,16(sp)
    80004056:	69a2                	ld	s3,8(sp)
    80004058:	6145                	addi	sp,sp,48
    8000405a:	8082                	ret

000000008000405c <ialloc>:
{
    8000405c:	715d                	addi	sp,sp,-80
    8000405e:	e486                	sd	ra,72(sp)
    80004060:	e0a2                	sd	s0,64(sp)
    80004062:	fc26                	sd	s1,56(sp)
    80004064:	f84a                	sd	s2,48(sp)
    80004066:	f44e                	sd	s3,40(sp)
    80004068:	f052                	sd	s4,32(sp)
    8000406a:	ec56                	sd	s5,24(sp)
    8000406c:	e85a                	sd	s6,16(sp)
    8000406e:	e45e                	sd	s7,8(sp)
    80004070:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80004072:	00026717          	auipc	a4,0x26
    80004076:	f4272703          	lw	a4,-190(a4) # 80029fb4 <sb+0xc>
    8000407a:	4785                	li	a5,1
    8000407c:	04e7fa63          	bgeu	a5,a4,800040d0 <ialloc+0x74>
    80004080:	8aaa                	mv	s5,a0
    80004082:	8bae                	mv	s7,a1
    80004084:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80004086:	00026a17          	auipc	s4,0x26
    8000408a:	f22a0a13          	addi	s4,s4,-222 # 80029fa8 <sb>
    8000408e:	00048b1b          	sext.w	s6,s1
    80004092:	0044d793          	srli	a5,s1,0x4
    80004096:	018a2583          	lw	a1,24(s4)
    8000409a:	9dbd                	addw	a1,a1,a5
    8000409c:	8556                	mv	a0,s5
    8000409e:	00000097          	auipc	ra,0x0
    800040a2:	952080e7          	jalr	-1710(ra) # 800039f0 <bread>
    800040a6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800040a8:	05850993          	addi	s3,a0,88
    800040ac:	00f4f793          	andi	a5,s1,15
    800040b0:	079a                	slli	a5,a5,0x6
    800040b2:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800040b4:	00099783          	lh	a5,0(s3)
    800040b8:	c785                	beqz	a5,800040e0 <ialloc+0x84>
    brelse(bp);
    800040ba:	00000097          	auipc	ra,0x0
    800040be:	a66080e7          	jalr	-1434(ra) # 80003b20 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800040c2:	0485                	addi	s1,s1,1
    800040c4:	00ca2703          	lw	a4,12(s4)
    800040c8:	0004879b          	sext.w	a5,s1
    800040cc:	fce7e1e3          	bltu	a5,a4,8000408e <ialloc+0x32>
  panic("ialloc: no inodes");
    800040d0:	00006517          	auipc	a0,0x6
    800040d4:	c7050513          	addi	a0,a0,-912 # 80009d40 <syscalls+0x168>
    800040d8:	ffffc097          	auipc	ra,0xffffc
    800040dc:	452080e7          	jalr	1106(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    800040e0:	04000613          	li	a2,64
    800040e4:	4581                	li	a1,0
    800040e6:	854e                	mv	a0,s3
    800040e8:	ffffd097          	auipc	ra,0xffffd
    800040ec:	bd6080e7          	jalr	-1066(ra) # 80000cbe <memset>
      dip->type = type;
    800040f0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800040f4:	854a                	mv	a0,s2
    800040f6:	00001097          	auipc	ra,0x1
    800040fa:	fce080e7          	jalr	-50(ra) # 800050c4 <log_write>
      brelse(bp);
    800040fe:	854a                	mv	a0,s2
    80004100:	00000097          	auipc	ra,0x0
    80004104:	a20080e7          	jalr	-1504(ra) # 80003b20 <brelse>
      return iget(dev, inum);
    80004108:	85da                	mv	a1,s6
    8000410a:	8556                	mv	a0,s5
    8000410c:	00000097          	auipc	ra,0x0
    80004110:	db4080e7          	jalr	-588(ra) # 80003ec0 <iget>
}
    80004114:	60a6                	ld	ra,72(sp)
    80004116:	6406                	ld	s0,64(sp)
    80004118:	74e2                	ld	s1,56(sp)
    8000411a:	7942                	ld	s2,48(sp)
    8000411c:	79a2                	ld	s3,40(sp)
    8000411e:	7a02                	ld	s4,32(sp)
    80004120:	6ae2                	ld	s5,24(sp)
    80004122:	6b42                	ld	s6,16(sp)
    80004124:	6ba2                	ld	s7,8(sp)
    80004126:	6161                	addi	sp,sp,80
    80004128:	8082                	ret

000000008000412a <iupdate>:
{
    8000412a:	1101                	addi	sp,sp,-32
    8000412c:	ec06                	sd	ra,24(sp)
    8000412e:	e822                	sd	s0,16(sp)
    80004130:	e426                	sd	s1,8(sp)
    80004132:	e04a                	sd	s2,0(sp)
    80004134:	1000                	addi	s0,sp,32
    80004136:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004138:	415c                	lw	a5,4(a0)
    8000413a:	0047d79b          	srliw	a5,a5,0x4
    8000413e:	00026597          	auipc	a1,0x26
    80004142:	e825a583          	lw	a1,-382(a1) # 80029fc0 <sb+0x18>
    80004146:	9dbd                	addw	a1,a1,a5
    80004148:	4108                	lw	a0,0(a0)
    8000414a:	00000097          	auipc	ra,0x0
    8000414e:	8a6080e7          	jalr	-1882(ra) # 800039f0 <bread>
    80004152:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004154:	05850793          	addi	a5,a0,88
    80004158:	40c8                	lw	a0,4(s1)
    8000415a:	893d                	andi	a0,a0,15
    8000415c:	051a                	slli	a0,a0,0x6
    8000415e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80004160:	04449703          	lh	a4,68(s1)
    80004164:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80004168:	04649703          	lh	a4,70(s1)
    8000416c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80004170:	04849703          	lh	a4,72(s1)
    80004174:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80004178:	04a49703          	lh	a4,74(s1)
    8000417c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80004180:	44f8                	lw	a4,76(s1)
    80004182:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004184:	03400613          	li	a2,52
    80004188:	05048593          	addi	a1,s1,80
    8000418c:	0531                	addi	a0,a0,12
    8000418e:	ffffd097          	auipc	ra,0xffffd
    80004192:	b8c080e7          	jalr	-1140(ra) # 80000d1a <memmove>
  log_write(bp);
    80004196:	854a                	mv	a0,s2
    80004198:	00001097          	auipc	ra,0x1
    8000419c:	f2c080e7          	jalr	-212(ra) # 800050c4 <log_write>
  brelse(bp);
    800041a0:	854a                	mv	a0,s2
    800041a2:	00000097          	auipc	ra,0x0
    800041a6:	97e080e7          	jalr	-1666(ra) # 80003b20 <brelse>
}
    800041aa:	60e2                	ld	ra,24(sp)
    800041ac:	6442                	ld	s0,16(sp)
    800041ae:	64a2                	ld	s1,8(sp)
    800041b0:	6902                	ld	s2,0(sp)
    800041b2:	6105                	addi	sp,sp,32
    800041b4:	8082                	ret

00000000800041b6 <idup>:
{
    800041b6:	1101                	addi	sp,sp,-32
    800041b8:	ec06                	sd	ra,24(sp)
    800041ba:	e822                	sd	s0,16(sp)
    800041bc:	e426                	sd	s1,8(sp)
    800041be:	1000                	addi	s0,sp,32
    800041c0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800041c2:	00026517          	auipc	a0,0x26
    800041c6:	e0650513          	addi	a0,a0,-506 # 80029fc8 <itable>
    800041ca:	ffffd097          	auipc	ra,0xffffd
    800041ce:	9f8080e7          	jalr	-1544(ra) # 80000bc2 <acquire>
  ip->ref++;
    800041d2:	449c                	lw	a5,8(s1)
    800041d4:	2785                	addiw	a5,a5,1
    800041d6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800041d8:	00026517          	auipc	a0,0x26
    800041dc:	df050513          	addi	a0,a0,-528 # 80029fc8 <itable>
    800041e0:	ffffd097          	auipc	ra,0xffffd
    800041e4:	a96080e7          	jalr	-1386(ra) # 80000c76 <release>
}
    800041e8:	8526                	mv	a0,s1
    800041ea:	60e2                	ld	ra,24(sp)
    800041ec:	6442                	ld	s0,16(sp)
    800041ee:	64a2                	ld	s1,8(sp)
    800041f0:	6105                	addi	sp,sp,32
    800041f2:	8082                	ret

00000000800041f4 <ilock>:
{
    800041f4:	1101                	addi	sp,sp,-32
    800041f6:	ec06                	sd	ra,24(sp)
    800041f8:	e822                	sd	s0,16(sp)
    800041fa:	e426                	sd	s1,8(sp)
    800041fc:	e04a                	sd	s2,0(sp)
    800041fe:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004200:	c115                	beqz	a0,80004224 <ilock+0x30>
    80004202:	84aa                	mv	s1,a0
    80004204:	451c                	lw	a5,8(a0)
    80004206:	00f05f63          	blez	a5,80004224 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000420a:	0541                	addi	a0,a0,16
    8000420c:	00001097          	auipc	ra,0x1
    80004210:	fd8080e7          	jalr	-40(ra) # 800051e4 <acquiresleep>
  if(ip->valid == 0){
    80004214:	40bc                	lw	a5,64(s1)
    80004216:	cf99                	beqz	a5,80004234 <ilock+0x40>
}
    80004218:	60e2                	ld	ra,24(sp)
    8000421a:	6442                	ld	s0,16(sp)
    8000421c:	64a2                	ld	s1,8(sp)
    8000421e:	6902                	ld	s2,0(sp)
    80004220:	6105                	addi	sp,sp,32
    80004222:	8082                	ret
    panic("ilock");
    80004224:	00006517          	auipc	a0,0x6
    80004228:	b3450513          	addi	a0,a0,-1228 # 80009d58 <syscalls+0x180>
    8000422c:	ffffc097          	auipc	ra,0xffffc
    80004230:	2fe080e7          	jalr	766(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004234:	40dc                	lw	a5,4(s1)
    80004236:	0047d79b          	srliw	a5,a5,0x4
    8000423a:	00026597          	auipc	a1,0x26
    8000423e:	d865a583          	lw	a1,-634(a1) # 80029fc0 <sb+0x18>
    80004242:	9dbd                	addw	a1,a1,a5
    80004244:	4088                	lw	a0,0(s1)
    80004246:	fffff097          	auipc	ra,0xfffff
    8000424a:	7aa080e7          	jalr	1962(ra) # 800039f0 <bread>
    8000424e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004250:	05850593          	addi	a1,a0,88
    80004254:	40dc                	lw	a5,4(s1)
    80004256:	8bbd                	andi	a5,a5,15
    80004258:	079a                	slli	a5,a5,0x6
    8000425a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000425c:	00059783          	lh	a5,0(a1)
    80004260:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004264:	00259783          	lh	a5,2(a1)
    80004268:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000426c:	00459783          	lh	a5,4(a1)
    80004270:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004274:	00659783          	lh	a5,6(a1)
    80004278:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000427c:	459c                	lw	a5,8(a1)
    8000427e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004280:	03400613          	li	a2,52
    80004284:	05b1                	addi	a1,a1,12
    80004286:	05048513          	addi	a0,s1,80
    8000428a:	ffffd097          	auipc	ra,0xffffd
    8000428e:	a90080e7          	jalr	-1392(ra) # 80000d1a <memmove>
    brelse(bp);
    80004292:	854a                	mv	a0,s2
    80004294:	00000097          	auipc	ra,0x0
    80004298:	88c080e7          	jalr	-1908(ra) # 80003b20 <brelse>
    ip->valid = 1;
    8000429c:	4785                	li	a5,1
    8000429e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800042a0:	04449783          	lh	a5,68(s1)
    800042a4:	fbb5                	bnez	a5,80004218 <ilock+0x24>
      panic("ilock: no type");
    800042a6:	00006517          	auipc	a0,0x6
    800042aa:	aba50513          	addi	a0,a0,-1350 # 80009d60 <syscalls+0x188>
    800042ae:	ffffc097          	auipc	ra,0xffffc
    800042b2:	27c080e7          	jalr	636(ra) # 8000052a <panic>

00000000800042b6 <iunlock>:
{
    800042b6:	1101                	addi	sp,sp,-32
    800042b8:	ec06                	sd	ra,24(sp)
    800042ba:	e822                	sd	s0,16(sp)
    800042bc:	e426                	sd	s1,8(sp)
    800042be:	e04a                	sd	s2,0(sp)
    800042c0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800042c2:	c905                	beqz	a0,800042f2 <iunlock+0x3c>
    800042c4:	84aa                	mv	s1,a0
    800042c6:	01050913          	addi	s2,a0,16
    800042ca:	854a                	mv	a0,s2
    800042cc:	00001097          	auipc	ra,0x1
    800042d0:	fb2080e7          	jalr	-78(ra) # 8000527e <holdingsleep>
    800042d4:	cd19                	beqz	a0,800042f2 <iunlock+0x3c>
    800042d6:	449c                	lw	a5,8(s1)
    800042d8:	00f05d63          	blez	a5,800042f2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800042dc:	854a                	mv	a0,s2
    800042de:	00001097          	auipc	ra,0x1
    800042e2:	f5c080e7          	jalr	-164(ra) # 8000523a <releasesleep>
}
    800042e6:	60e2                	ld	ra,24(sp)
    800042e8:	6442                	ld	s0,16(sp)
    800042ea:	64a2                	ld	s1,8(sp)
    800042ec:	6902                	ld	s2,0(sp)
    800042ee:	6105                	addi	sp,sp,32
    800042f0:	8082                	ret
    panic("iunlock");
    800042f2:	00006517          	auipc	a0,0x6
    800042f6:	a7e50513          	addi	a0,a0,-1410 # 80009d70 <syscalls+0x198>
    800042fa:	ffffc097          	auipc	ra,0xffffc
    800042fe:	230080e7          	jalr	560(ra) # 8000052a <panic>

0000000080004302 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004302:	7179                	addi	sp,sp,-48
    80004304:	f406                	sd	ra,40(sp)
    80004306:	f022                	sd	s0,32(sp)
    80004308:	ec26                	sd	s1,24(sp)
    8000430a:	e84a                	sd	s2,16(sp)
    8000430c:	e44e                	sd	s3,8(sp)
    8000430e:	e052                	sd	s4,0(sp)
    80004310:	1800                	addi	s0,sp,48
    80004312:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004314:	05050493          	addi	s1,a0,80
    80004318:	08050913          	addi	s2,a0,128
    8000431c:	a021                	j	80004324 <itrunc+0x22>
    8000431e:	0491                	addi	s1,s1,4
    80004320:	01248d63          	beq	s1,s2,8000433a <itrunc+0x38>
    if(ip->addrs[i]){
    80004324:	408c                	lw	a1,0(s1)
    80004326:	dde5                	beqz	a1,8000431e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80004328:	0009a503          	lw	a0,0(s3)
    8000432c:	00000097          	auipc	ra,0x0
    80004330:	90a080e7          	jalr	-1782(ra) # 80003c36 <bfree>
      ip->addrs[i] = 0;
    80004334:	0004a023          	sw	zero,0(s1)
    80004338:	b7dd                	j	8000431e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000433a:	0809a583          	lw	a1,128(s3)
    8000433e:	e185                	bnez	a1,8000435e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004340:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004344:	854e                	mv	a0,s3
    80004346:	00000097          	auipc	ra,0x0
    8000434a:	de4080e7          	jalr	-540(ra) # 8000412a <iupdate>
}
    8000434e:	70a2                	ld	ra,40(sp)
    80004350:	7402                	ld	s0,32(sp)
    80004352:	64e2                	ld	s1,24(sp)
    80004354:	6942                	ld	s2,16(sp)
    80004356:	69a2                	ld	s3,8(sp)
    80004358:	6a02                	ld	s4,0(sp)
    8000435a:	6145                	addi	sp,sp,48
    8000435c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000435e:	0009a503          	lw	a0,0(s3)
    80004362:	fffff097          	auipc	ra,0xfffff
    80004366:	68e080e7          	jalr	1678(ra) # 800039f0 <bread>
    8000436a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000436c:	05850493          	addi	s1,a0,88
    80004370:	45850913          	addi	s2,a0,1112
    80004374:	a021                	j	8000437c <itrunc+0x7a>
    80004376:	0491                	addi	s1,s1,4
    80004378:	01248b63          	beq	s1,s2,8000438e <itrunc+0x8c>
      if(a[j])
    8000437c:	408c                	lw	a1,0(s1)
    8000437e:	dde5                	beqz	a1,80004376 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80004380:	0009a503          	lw	a0,0(s3)
    80004384:	00000097          	auipc	ra,0x0
    80004388:	8b2080e7          	jalr	-1870(ra) # 80003c36 <bfree>
    8000438c:	b7ed                	j	80004376 <itrunc+0x74>
    brelse(bp);
    8000438e:	8552                	mv	a0,s4
    80004390:	fffff097          	auipc	ra,0xfffff
    80004394:	790080e7          	jalr	1936(ra) # 80003b20 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004398:	0809a583          	lw	a1,128(s3)
    8000439c:	0009a503          	lw	a0,0(s3)
    800043a0:	00000097          	auipc	ra,0x0
    800043a4:	896080e7          	jalr	-1898(ra) # 80003c36 <bfree>
    ip->addrs[NDIRECT] = 0;
    800043a8:	0809a023          	sw	zero,128(s3)
    800043ac:	bf51                	j	80004340 <itrunc+0x3e>

00000000800043ae <iput>:
{
    800043ae:	1101                	addi	sp,sp,-32
    800043b0:	ec06                	sd	ra,24(sp)
    800043b2:	e822                	sd	s0,16(sp)
    800043b4:	e426                	sd	s1,8(sp)
    800043b6:	e04a                	sd	s2,0(sp)
    800043b8:	1000                	addi	s0,sp,32
    800043ba:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800043bc:	00026517          	auipc	a0,0x26
    800043c0:	c0c50513          	addi	a0,a0,-1012 # 80029fc8 <itable>
    800043c4:	ffffc097          	auipc	ra,0xffffc
    800043c8:	7fe080e7          	jalr	2046(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800043cc:	4498                	lw	a4,8(s1)
    800043ce:	4785                	li	a5,1
    800043d0:	02f70363          	beq	a4,a5,800043f6 <iput+0x48>
  ip->ref--;
    800043d4:	449c                	lw	a5,8(s1)
    800043d6:	37fd                	addiw	a5,a5,-1
    800043d8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800043da:	00026517          	auipc	a0,0x26
    800043de:	bee50513          	addi	a0,a0,-1042 # 80029fc8 <itable>
    800043e2:	ffffd097          	auipc	ra,0xffffd
    800043e6:	894080e7          	jalr	-1900(ra) # 80000c76 <release>
}
    800043ea:	60e2                	ld	ra,24(sp)
    800043ec:	6442                	ld	s0,16(sp)
    800043ee:	64a2                	ld	s1,8(sp)
    800043f0:	6902                	ld	s2,0(sp)
    800043f2:	6105                	addi	sp,sp,32
    800043f4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800043f6:	40bc                	lw	a5,64(s1)
    800043f8:	dff1                	beqz	a5,800043d4 <iput+0x26>
    800043fa:	04a49783          	lh	a5,74(s1)
    800043fe:	fbf9                	bnez	a5,800043d4 <iput+0x26>
    acquiresleep(&ip->lock);
    80004400:	01048913          	addi	s2,s1,16
    80004404:	854a                	mv	a0,s2
    80004406:	00001097          	auipc	ra,0x1
    8000440a:	dde080e7          	jalr	-546(ra) # 800051e4 <acquiresleep>
    release(&itable.lock);
    8000440e:	00026517          	auipc	a0,0x26
    80004412:	bba50513          	addi	a0,a0,-1094 # 80029fc8 <itable>
    80004416:	ffffd097          	auipc	ra,0xffffd
    8000441a:	860080e7          	jalr	-1952(ra) # 80000c76 <release>
    itrunc(ip);
    8000441e:	8526                	mv	a0,s1
    80004420:	00000097          	auipc	ra,0x0
    80004424:	ee2080e7          	jalr	-286(ra) # 80004302 <itrunc>
    ip->type = 0;
    80004428:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000442c:	8526                	mv	a0,s1
    8000442e:	00000097          	auipc	ra,0x0
    80004432:	cfc080e7          	jalr	-772(ra) # 8000412a <iupdate>
    ip->valid = 0;
    80004436:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000443a:	854a                	mv	a0,s2
    8000443c:	00001097          	auipc	ra,0x1
    80004440:	dfe080e7          	jalr	-514(ra) # 8000523a <releasesleep>
    acquire(&itable.lock);
    80004444:	00026517          	auipc	a0,0x26
    80004448:	b8450513          	addi	a0,a0,-1148 # 80029fc8 <itable>
    8000444c:	ffffc097          	auipc	ra,0xffffc
    80004450:	776080e7          	jalr	1910(ra) # 80000bc2 <acquire>
    80004454:	b741                	j	800043d4 <iput+0x26>

0000000080004456 <iunlockput>:
{
    80004456:	1101                	addi	sp,sp,-32
    80004458:	ec06                	sd	ra,24(sp)
    8000445a:	e822                	sd	s0,16(sp)
    8000445c:	e426                	sd	s1,8(sp)
    8000445e:	1000                	addi	s0,sp,32
    80004460:	84aa                	mv	s1,a0
  iunlock(ip);
    80004462:	00000097          	auipc	ra,0x0
    80004466:	e54080e7          	jalr	-428(ra) # 800042b6 <iunlock>
  iput(ip);
    8000446a:	8526                	mv	a0,s1
    8000446c:	00000097          	auipc	ra,0x0
    80004470:	f42080e7          	jalr	-190(ra) # 800043ae <iput>
}
    80004474:	60e2                	ld	ra,24(sp)
    80004476:	6442                	ld	s0,16(sp)
    80004478:	64a2                	ld	s1,8(sp)
    8000447a:	6105                	addi	sp,sp,32
    8000447c:	8082                	ret

000000008000447e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000447e:	1141                	addi	sp,sp,-16
    80004480:	e422                	sd	s0,8(sp)
    80004482:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004484:	411c                	lw	a5,0(a0)
    80004486:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004488:	415c                	lw	a5,4(a0)
    8000448a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000448c:	04451783          	lh	a5,68(a0)
    80004490:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004494:	04a51783          	lh	a5,74(a0)
    80004498:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000449c:	04c56783          	lwu	a5,76(a0)
    800044a0:	e99c                	sd	a5,16(a1)
}
    800044a2:	6422                	ld	s0,8(sp)
    800044a4:	0141                	addi	sp,sp,16
    800044a6:	8082                	ret

00000000800044a8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800044a8:	457c                	lw	a5,76(a0)
    800044aa:	0ed7e963          	bltu	a5,a3,8000459c <readi+0xf4>
{
    800044ae:	7159                	addi	sp,sp,-112
    800044b0:	f486                	sd	ra,104(sp)
    800044b2:	f0a2                	sd	s0,96(sp)
    800044b4:	eca6                	sd	s1,88(sp)
    800044b6:	e8ca                	sd	s2,80(sp)
    800044b8:	e4ce                	sd	s3,72(sp)
    800044ba:	e0d2                	sd	s4,64(sp)
    800044bc:	fc56                	sd	s5,56(sp)
    800044be:	f85a                	sd	s6,48(sp)
    800044c0:	f45e                	sd	s7,40(sp)
    800044c2:	f062                	sd	s8,32(sp)
    800044c4:	ec66                	sd	s9,24(sp)
    800044c6:	e86a                	sd	s10,16(sp)
    800044c8:	e46e                	sd	s11,8(sp)
    800044ca:	1880                	addi	s0,sp,112
    800044cc:	8baa                	mv	s7,a0
    800044ce:	8c2e                	mv	s8,a1
    800044d0:	8ab2                	mv	s5,a2
    800044d2:	84b6                	mv	s1,a3
    800044d4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800044d6:	9f35                	addw	a4,a4,a3
    return 0;
    800044d8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800044da:	0ad76063          	bltu	a4,a3,8000457a <readi+0xd2>
  if(off + n > ip->size)
    800044de:	00e7f463          	bgeu	a5,a4,800044e6 <readi+0x3e>
    n = ip->size - off;
    800044e2:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800044e6:	0a0b0963          	beqz	s6,80004598 <readi+0xf0>
    800044ea:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800044ec:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800044f0:	5cfd                	li	s9,-1
    800044f2:	a82d                	j	8000452c <readi+0x84>
    800044f4:	020a1d93          	slli	s11,s4,0x20
    800044f8:	020ddd93          	srli	s11,s11,0x20
    800044fc:	05890793          	addi	a5,s2,88
    80004500:	86ee                	mv	a3,s11
    80004502:	963e                	add	a2,a2,a5
    80004504:	85d6                	mv	a1,s5
    80004506:	8562                	mv	a0,s8
    80004508:	ffffe097          	auipc	ra,0xffffe
    8000450c:	2dc080e7          	jalr	732(ra) # 800027e4 <either_copyout>
    80004510:	05950d63          	beq	a0,s9,8000456a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004514:	854a                	mv	a0,s2
    80004516:	fffff097          	auipc	ra,0xfffff
    8000451a:	60a080e7          	jalr	1546(ra) # 80003b20 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000451e:	013a09bb          	addw	s3,s4,s3
    80004522:	009a04bb          	addw	s1,s4,s1
    80004526:	9aee                	add	s5,s5,s11
    80004528:	0569f763          	bgeu	s3,s6,80004576 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000452c:	000ba903          	lw	s2,0(s7)
    80004530:	00a4d59b          	srliw	a1,s1,0xa
    80004534:	855e                	mv	a0,s7
    80004536:	00000097          	auipc	ra,0x0
    8000453a:	8ae080e7          	jalr	-1874(ra) # 80003de4 <bmap>
    8000453e:	0005059b          	sext.w	a1,a0
    80004542:	854a                	mv	a0,s2
    80004544:	fffff097          	auipc	ra,0xfffff
    80004548:	4ac080e7          	jalr	1196(ra) # 800039f0 <bread>
    8000454c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000454e:	3ff4f613          	andi	a2,s1,1023
    80004552:	40cd07bb          	subw	a5,s10,a2
    80004556:	413b073b          	subw	a4,s6,s3
    8000455a:	8a3e                	mv	s4,a5
    8000455c:	2781                	sext.w	a5,a5
    8000455e:	0007069b          	sext.w	a3,a4
    80004562:	f8f6f9e3          	bgeu	a3,a5,800044f4 <readi+0x4c>
    80004566:	8a3a                	mv	s4,a4
    80004568:	b771                	j	800044f4 <readi+0x4c>
      brelse(bp);
    8000456a:	854a                	mv	a0,s2
    8000456c:	fffff097          	auipc	ra,0xfffff
    80004570:	5b4080e7          	jalr	1460(ra) # 80003b20 <brelse>
      tot = -1;
    80004574:	59fd                	li	s3,-1
  }
  return tot;
    80004576:	0009851b          	sext.w	a0,s3
}
    8000457a:	70a6                	ld	ra,104(sp)
    8000457c:	7406                	ld	s0,96(sp)
    8000457e:	64e6                	ld	s1,88(sp)
    80004580:	6946                	ld	s2,80(sp)
    80004582:	69a6                	ld	s3,72(sp)
    80004584:	6a06                	ld	s4,64(sp)
    80004586:	7ae2                	ld	s5,56(sp)
    80004588:	7b42                	ld	s6,48(sp)
    8000458a:	7ba2                	ld	s7,40(sp)
    8000458c:	7c02                	ld	s8,32(sp)
    8000458e:	6ce2                	ld	s9,24(sp)
    80004590:	6d42                	ld	s10,16(sp)
    80004592:	6da2                	ld	s11,8(sp)
    80004594:	6165                	addi	sp,sp,112
    80004596:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004598:	89da                	mv	s3,s6
    8000459a:	bff1                	j	80004576 <readi+0xce>
    return 0;
    8000459c:	4501                	li	a0,0
}
    8000459e:	8082                	ret

00000000800045a0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800045a0:	457c                	lw	a5,76(a0)
    800045a2:	10d7e863          	bltu	a5,a3,800046b2 <writei+0x112>
{
    800045a6:	7159                	addi	sp,sp,-112
    800045a8:	f486                	sd	ra,104(sp)
    800045aa:	f0a2                	sd	s0,96(sp)
    800045ac:	eca6                	sd	s1,88(sp)
    800045ae:	e8ca                	sd	s2,80(sp)
    800045b0:	e4ce                	sd	s3,72(sp)
    800045b2:	e0d2                	sd	s4,64(sp)
    800045b4:	fc56                	sd	s5,56(sp)
    800045b6:	f85a                	sd	s6,48(sp)
    800045b8:	f45e                	sd	s7,40(sp)
    800045ba:	f062                	sd	s8,32(sp)
    800045bc:	ec66                	sd	s9,24(sp)
    800045be:	e86a                	sd	s10,16(sp)
    800045c0:	e46e                	sd	s11,8(sp)
    800045c2:	1880                	addi	s0,sp,112
    800045c4:	8b2a                	mv	s6,a0
    800045c6:	8c2e                	mv	s8,a1
    800045c8:	8ab2                	mv	s5,a2
    800045ca:	8936                	mv	s2,a3
    800045cc:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    800045ce:	00e687bb          	addw	a5,a3,a4
    800045d2:	0ed7e263          	bltu	a5,a3,800046b6 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800045d6:	00043737          	lui	a4,0x43
    800045da:	0ef76063          	bltu	a4,a5,800046ba <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800045de:	0c0b8863          	beqz	s7,800046ae <writei+0x10e>
    800045e2:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800045e4:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800045e8:	5cfd                	li	s9,-1
    800045ea:	a091                	j	8000462e <writei+0x8e>
    800045ec:	02099d93          	slli	s11,s3,0x20
    800045f0:	020ddd93          	srli	s11,s11,0x20
    800045f4:	05848793          	addi	a5,s1,88
    800045f8:	86ee                	mv	a3,s11
    800045fa:	8656                	mv	a2,s5
    800045fc:	85e2                	mv	a1,s8
    800045fe:	953e                	add	a0,a0,a5
    80004600:	ffffe097          	auipc	ra,0xffffe
    80004604:	23a080e7          	jalr	570(ra) # 8000283a <either_copyin>
    80004608:	07950263          	beq	a0,s9,8000466c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000460c:	8526                	mv	a0,s1
    8000460e:	00001097          	auipc	ra,0x1
    80004612:	ab6080e7          	jalr	-1354(ra) # 800050c4 <log_write>
    brelse(bp);
    80004616:	8526                	mv	a0,s1
    80004618:	fffff097          	auipc	ra,0xfffff
    8000461c:	508080e7          	jalr	1288(ra) # 80003b20 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004620:	01498a3b          	addw	s4,s3,s4
    80004624:	0129893b          	addw	s2,s3,s2
    80004628:	9aee                	add	s5,s5,s11
    8000462a:	057a7663          	bgeu	s4,s7,80004676 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000462e:	000b2483          	lw	s1,0(s6)
    80004632:	00a9559b          	srliw	a1,s2,0xa
    80004636:	855a                	mv	a0,s6
    80004638:	fffff097          	auipc	ra,0xfffff
    8000463c:	7ac080e7          	jalr	1964(ra) # 80003de4 <bmap>
    80004640:	0005059b          	sext.w	a1,a0
    80004644:	8526                	mv	a0,s1
    80004646:	fffff097          	auipc	ra,0xfffff
    8000464a:	3aa080e7          	jalr	938(ra) # 800039f0 <bread>
    8000464e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004650:	3ff97513          	andi	a0,s2,1023
    80004654:	40ad07bb          	subw	a5,s10,a0
    80004658:	414b873b          	subw	a4,s7,s4
    8000465c:	89be                	mv	s3,a5
    8000465e:	2781                	sext.w	a5,a5
    80004660:	0007069b          	sext.w	a3,a4
    80004664:	f8f6f4e3          	bgeu	a3,a5,800045ec <writei+0x4c>
    80004668:	89ba                	mv	s3,a4
    8000466a:	b749                	j	800045ec <writei+0x4c>
      brelse(bp);
    8000466c:	8526                	mv	a0,s1
    8000466e:	fffff097          	auipc	ra,0xfffff
    80004672:	4b2080e7          	jalr	1202(ra) # 80003b20 <brelse>
  }

  if(off > ip->size)
    80004676:	04cb2783          	lw	a5,76(s6)
    8000467a:	0127f463          	bgeu	a5,s2,80004682 <writei+0xe2>
    ip->size = off;
    8000467e:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004682:	855a                	mv	a0,s6
    80004684:	00000097          	auipc	ra,0x0
    80004688:	aa6080e7          	jalr	-1370(ra) # 8000412a <iupdate>

  return tot;
    8000468c:	000a051b          	sext.w	a0,s4
}
    80004690:	70a6                	ld	ra,104(sp)
    80004692:	7406                	ld	s0,96(sp)
    80004694:	64e6                	ld	s1,88(sp)
    80004696:	6946                	ld	s2,80(sp)
    80004698:	69a6                	ld	s3,72(sp)
    8000469a:	6a06                	ld	s4,64(sp)
    8000469c:	7ae2                	ld	s5,56(sp)
    8000469e:	7b42                	ld	s6,48(sp)
    800046a0:	7ba2                	ld	s7,40(sp)
    800046a2:	7c02                	ld	s8,32(sp)
    800046a4:	6ce2                	ld	s9,24(sp)
    800046a6:	6d42                	ld	s10,16(sp)
    800046a8:	6da2                	ld	s11,8(sp)
    800046aa:	6165                	addi	sp,sp,112
    800046ac:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800046ae:	8a5e                	mv	s4,s7
    800046b0:	bfc9                	j	80004682 <writei+0xe2>
    return -1;
    800046b2:	557d                	li	a0,-1
}
    800046b4:	8082                	ret
    return -1;
    800046b6:	557d                	li	a0,-1
    800046b8:	bfe1                	j	80004690 <writei+0xf0>
    return -1;
    800046ba:	557d                	li	a0,-1
    800046bc:	bfd1                	j	80004690 <writei+0xf0>

00000000800046be <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800046be:	1141                	addi	sp,sp,-16
    800046c0:	e406                	sd	ra,8(sp)
    800046c2:	e022                	sd	s0,0(sp)
    800046c4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800046c6:	4639                	li	a2,14
    800046c8:	ffffc097          	auipc	ra,0xffffc
    800046cc:	6ce080e7          	jalr	1742(ra) # 80000d96 <strncmp>
}
    800046d0:	60a2                	ld	ra,8(sp)
    800046d2:	6402                	ld	s0,0(sp)
    800046d4:	0141                	addi	sp,sp,16
    800046d6:	8082                	ret

00000000800046d8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800046d8:	7139                	addi	sp,sp,-64
    800046da:	fc06                	sd	ra,56(sp)
    800046dc:	f822                	sd	s0,48(sp)
    800046de:	f426                	sd	s1,40(sp)
    800046e0:	f04a                	sd	s2,32(sp)
    800046e2:	ec4e                	sd	s3,24(sp)
    800046e4:	e852                	sd	s4,16(sp)
    800046e6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800046e8:	04451703          	lh	a4,68(a0)
    800046ec:	4785                	li	a5,1
    800046ee:	00f71a63          	bne	a4,a5,80004702 <dirlookup+0x2a>
    800046f2:	892a                	mv	s2,a0
    800046f4:	89ae                	mv	s3,a1
    800046f6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800046f8:	457c                	lw	a5,76(a0)
    800046fa:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800046fc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046fe:	e79d                	bnez	a5,8000472c <dirlookup+0x54>
    80004700:	a8a5                	j	80004778 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004702:	00005517          	auipc	a0,0x5
    80004706:	67650513          	addi	a0,a0,1654 # 80009d78 <syscalls+0x1a0>
    8000470a:	ffffc097          	auipc	ra,0xffffc
    8000470e:	e20080e7          	jalr	-480(ra) # 8000052a <panic>
      panic("dirlookup read");
    80004712:	00005517          	auipc	a0,0x5
    80004716:	67e50513          	addi	a0,a0,1662 # 80009d90 <syscalls+0x1b8>
    8000471a:	ffffc097          	auipc	ra,0xffffc
    8000471e:	e10080e7          	jalr	-496(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004722:	24c1                	addiw	s1,s1,16
    80004724:	04c92783          	lw	a5,76(s2)
    80004728:	04f4f763          	bgeu	s1,a5,80004776 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000472c:	4741                	li	a4,16
    8000472e:	86a6                	mv	a3,s1
    80004730:	fc040613          	addi	a2,s0,-64
    80004734:	4581                	li	a1,0
    80004736:	854a                	mv	a0,s2
    80004738:	00000097          	auipc	ra,0x0
    8000473c:	d70080e7          	jalr	-656(ra) # 800044a8 <readi>
    80004740:	47c1                	li	a5,16
    80004742:	fcf518e3          	bne	a0,a5,80004712 <dirlookup+0x3a>
    if(de.inum == 0)
    80004746:	fc045783          	lhu	a5,-64(s0)
    8000474a:	dfe1                	beqz	a5,80004722 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000474c:	fc240593          	addi	a1,s0,-62
    80004750:	854e                	mv	a0,s3
    80004752:	00000097          	auipc	ra,0x0
    80004756:	f6c080e7          	jalr	-148(ra) # 800046be <namecmp>
    8000475a:	f561                	bnez	a0,80004722 <dirlookup+0x4a>
      if(poff)
    8000475c:	000a0463          	beqz	s4,80004764 <dirlookup+0x8c>
        *poff = off;
    80004760:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004764:	fc045583          	lhu	a1,-64(s0)
    80004768:	00092503          	lw	a0,0(s2)
    8000476c:	fffff097          	auipc	ra,0xfffff
    80004770:	754080e7          	jalr	1876(ra) # 80003ec0 <iget>
    80004774:	a011                	j	80004778 <dirlookup+0xa0>
  return 0;
    80004776:	4501                	li	a0,0
}
    80004778:	70e2                	ld	ra,56(sp)
    8000477a:	7442                	ld	s0,48(sp)
    8000477c:	74a2                	ld	s1,40(sp)
    8000477e:	7902                	ld	s2,32(sp)
    80004780:	69e2                	ld	s3,24(sp)
    80004782:	6a42                	ld	s4,16(sp)
    80004784:	6121                	addi	sp,sp,64
    80004786:	8082                	ret

0000000080004788 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004788:	711d                	addi	sp,sp,-96
    8000478a:	ec86                	sd	ra,88(sp)
    8000478c:	e8a2                	sd	s0,80(sp)
    8000478e:	e4a6                	sd	s1,72(sp)
    80004790:	e0ca                	sd	s2,64(sp)
    80004792:	fc4e                	sd	s3,56(sp)
    80004794:	f852                	sd	s4,48(sp)
    80004796:	f456                	sd	s5,40(sp)
    80004798:	f05a                	sd	s6,32(sp)
    8000479a:	ec5e                	sd	s7,24(sp)
    8000479c:	e862                	sd	s8,16(sp)
    8000479e:	e466                	sd	s9,8(sp)
    800047a0:	1080                	addi	s0,sp,96
    800047a2:	84aa                	mv	s1,a0
    800047a4:	8aae                	mv	s5,a1
    800047a6:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800047a8:	00054703          	lbu	a4,0(a0)
    800047ac:	02f00793          	li	a5,47
    800047b0:	02f70363          	beq	a4,a5,800047d6 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800047b4:	ffffd097          	auipc	ra,0xffffd
    800047b8:	6e0080e7          	jalr	1760(ra) # 80001e94 <myproc>
    800047bc:	15053503          	ld	a0,336(a0)
    800047c0:	00000097          	auipc	ra,0x0
    800047c4:	9f6080e7          	jalr	-1546(ra) # 800041b6 <idup>
    800047c8:	89aa                	mv	s3,a0
  while(*path == '/')
    800047ca:	02f00913          	li	s2,47
  len = path - s;
    800047ce:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800047d0:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800047d2:	4b85                	li	s7,1
    800047d4:	a865                	j	8000488c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800047d6:	4585                	li	a1,1
    800047d8:	4505                	li	a0,1
    800047da:	fffff097          	auipc	ra,0xfffff
    800047de:	6e6080e7          	jalr	1766(ra) # 80003ec0 <iget>
    800047e2:	89aa                	mv	s3,a0
    800047e4:	b7dd                	j	800047ca <namex+0x42>
      iunlockput(ip);
    800047e6:	854e                	mv	a0,s3
    800047e8:	00000097          	auipc	ra,0x0
    800047ec:	c6e080e7          	jalr	-914(ra) # 80004456 <iunlockput>
      return 0;
    800047f0:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800047f2:	854e                	mv	a0,s3
    800047f4:	60e6                	ld	ra,88(sp)
    800047f6:	6446                	ld	s0,80(sp)
    800047f8:	64a6                	ld	s1,72(sp)
    800047fa:	6906                	ld	s2,64(sp)
    800047fc:	79e2                	ld	s3,56(sp)
    800047fe:	7a42                	ld	s4,48(sp)
    80004800:	7aa2                	ld	s5,40(sp)
    80004802:	7b02                	ld	s6,32(sp)
    80004804:	6be2                	ld	s7,24(sp)
    80004806:	6c42                	ld	s8,16(sp)
    80004808:	6ca2                	ld	s9,8(sp)
    8000480a:	6125                	addi	sp,sp,96
    8000480c:	8082                	ret
      iunlock(ip);
    8000480e:	854e                	mv	a0,s3
    80004810:	00000097          	auipc	ra,0x0
    80004814:	aa6080e7          	jalr	-1370(ra) # 800042b6 <iunlock>
      return ip;
    80004818:	bfe9                	j	800047f2 <namex+0x6a>
      iunlockput(ip);
    8000481a:	854e                	mv	a0,s3
    8000481c:	00000097          	auipc	ra,0x0
    80004820:	c3a080e7          	jalr	-966(ra) # 80004456 <iunlockput>
      return 0;
    80004824:	89e6                	mv	s3,s9
    80004826:	b7f1                	j	800047f2 <namex+0x6a>
  len = path - s;
    80004828:	40b48633          	sub	a2,s1,a1
    8000482c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004830:	099c5463          	bge	s8,s9,800048b8 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004834:	4639                	li	a2,14
    80004836:	8552                	mv	a0,s4
    80004838:	ffffc097          	auipc	ra,0xffffc
    8000483c:	4e2080e7          	jalr	1250(ra) # 80000d1a <memmove>
  while(*path == '/')
    80004840:	0004c783          	lbu	a5,0(s1)
    80004844:	01279763          	bne	a5,s2,80004852 <namex+0xca>
    path++;
    80004848:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000484a:	0004c783          	lbu	a5,0(s1)
    8000484e:	ff278de3          	beq	a5,s2,80004848 <namex+0xc0>
    ilock(ip);
    80004852:	854e                	mv	a0,s3
    80004854:	00000097          	auipc	ra,0x0
    80004858:	9a0080e7          	jalr	-1632(ra) # 800041f4 <ilock>
    if(ip->type != T_DIR){
    8000485c:	04499783          	lh	a5,68(s3)
    80004860:	f97793e3          	bne	a5,s7,800047e6 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004864:	000a8563          	beqz	s5,8000486e <namex+0xe6>
    80004868:	0004c783          	lbu	a5,0(s1)
    8000486c:	d3cd                	beqz	a5,8000480e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000486e:	865a                	mv	a2,s6
    80004870:	85d2                	mv	a1,s4
    80004872:	854e                	mv	a0,s3
    80004874:	00000097          	auipc	ra,0x0
    80004878:	e64080e7          	jalr	-412(ra) # 800046d8 <dirlookup>
    8000487c:	8caa                	mv	s9,a0
    8000487e:	dd51                	beqz	a0,8000481a <namex+0x92>
    iunlockput(ip);
    80004880:	854e                	mv	a0,s3
    80004882:	00000097          	auipc	ra,0x0
    80004886:	bd4080e7          	jalr	-1068(ra) # 80004456 <iunlockput>
    ip = next;
    8000488a:	89e6                	mv	s3,s9
  while(*path == '/')
    8000488c:	0004c783          	lbu	a5,0(s1)
    80004890:	05279763          	bne	a5,s2,800048de <namex+0x156>
    path++;
    80004894:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004896:	0004c783          	lbu	a5,0(s1)
    8000489a:	ff278de3          	beq	a5,s2,80004894 <namex+0x10c>
  if(*path == 0)
    8000489e:	c79d                	beqz	a5,800048cc <namex+0x144>
    path++;
    800048a0:	85a6                	mv	a1,s1
  len = path - s;
    800048a2:	8cda                	mv	s9,s6
    800048a4:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800048a6:	01278963          	beq	a5,s2,800048b8 <namex+0x130>
    800048aa:	dfbd                	beqz	a5,80004828 <namex+0xa0>
    path++;
    800048ac:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800048ae:	0004c783          	lbu	a5,0(s1)
    800048b2:	ff279ce3          	bne	a5,s2,800048aa <namex+0x122>
    800048b6:	bf8d                	j	80004828 <namex+0xa0>
    memmove(name, s, len);
    800048b8:	2601                	sext.w	a2,a2
    800048ba:	8552                	mv	a0,s4
    800048bc:	ffffc097          	auipc	ra,0xffffc
    800048c0:	45e080e7          	jalr	1118(ra) # 80000d1a <memmove>
    name[len] = 0;
    800048c4:	9cd2                	add	s9,s9,s4
    800048c6:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800048ca:	bf9d                	j	80004840 <namex+0xb8>
  if(nameiparent){
    800048cc:	f20a83e3          	beqz	s5,800047f2 <namex+0x6a>
    iput(ip);
    800048d0:	854e                	mv	a0,s3
    800048d2:	00000097          	auipc	ra,0x0
    800048d6:	adc080e7          	jalr	-1316(ra) # 800043ae <iput>
    return 0;
    800048da:	4981                	li	s3,0
    800048dc:	bf19                	j	800047f2 <namex+0x6a>
  if(*path == 0)
    800048de:	d7fd                	beqz	a5,800048cc <namex+0x144>
  while(*path != '/' && *path != 0)
    800048e0:	0004c783          	lbu	a5,0(s1)
    800048e4:	85a6                	mv	a1,s1
    800048e6:	b7d1                	j	800048aa <namex+0x122>

00000000800048e8 <dirlink>:
{
    800048e8:	7139                	addi	sp,sp,-64
    800048ea:	fc06                	sd	ra,56(sp)
    800048ec:	f822                	sd	s0,48(sp)
    800048ee:	f426                	sd	s1,40(sp)
    800048f0:	f04a                	sd	s2,32(sp)
    800048f2:	ec4e                	sd	s3,24(sp)
    800048f4:	e852                	sd	s4,16(sp)
    800048f6:	0080                	addi	s0,sp,64
    800048f8:	892a                	mv	s2,a0
    800048fa:	8a2e                	mv	s4,a1
    800048fc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800048fe:	4601                	li	a2,0
    80004900:	00000097          	auipc	ra,0x0
    80004904:	dd8080e7          	jalr	-552(ra) # 800046d8 <dirlookup>
    80004908:	e93d                	bnez	a0,8000497e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000490a:	04c92483          	lw	s1,76(s2)
    8000490e:	c49d                	beqz	s1,8000493c <dirlink+0x54>
    80004910:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004912:	4741                	li	a4,16
    80004914:	86a6                	mv	a3,s1
    80004916:	fc040613          	addi	a2,s0,-64
    8000491a:	4581                	li	a1,0
    8000491c:	854a                	mv	a0,s2
    8000491e:	00000097          	auipc	ra,0x0
    80004922:	b8a080e7          	jalr	-1142(ra) # 800044a8 <readi>
    80004926:	47c1                	li	a5,16
    80004928:	06f51163          	bne	a0,a5,8000498a <dirlink+0xa2>
    if(de.inum == 0)
    8000492c:	fc045783          	lhu	a5,-64(s0)
    80004930:	c791                	beqz	a5,8000493c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004932:	24c1                	addiw	s1,s1,16
    80004934:	04c92783          	lw	a5,76(s2)
    80004938:	fcf4ede3          	bltu	s1,a5,80004912 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000493c:	4639                	li	a2,14
    8000493e:	85d2                	mv	a1,s4
    80004940:	fc240513          	addi	a0,s0,-62
    80004944:	ffffc097          	auipc	ra,0xffffc
    80004948:	48e080e7          	jalr	1166(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    8000494c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004950:	4741                	li	a4,16
    80004952:	86a6                	mv	a3,s1
    80004954:	fc040613          	addi	a2,s0,-64
    80004958:	4581                	li	a1,0
    8000495a:	854a                	mv	a0,s2
    8000495c:	00000097          	auipc	ra,0x0
    80004960:	c44080e7          	jalr	-956(ra) # 800045a0 <writei>
    80004964:	872a                	mv	a4,a0
    80004966:	47c1                	li	a5,16
  return 0;
    80004968:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000496a:	02f71863          	bne	a4,a5,8000499a <dirlink+0xb2>
}
    8000496e:	70e2                	ld	ra,56(sp)
    80004970:	7442                	ld	s0,48(sp)
    80004972:	74a2                	ld	s1,40(sp)
    80004974:	7902                	ld	s2,32(sp)
    80004976:	69e2                	ld	s3,24(sp)
    80004978:	6a42                	ld	s4,16(sp)
    8000497a:	6121                	addi	sp,sp,64
    8000497c:	8082                	ret
    iput(ip);
    8000497e:	00000097          	auipc	ra,0x0
    80004982:	a30080e7          	jalr	-1488(ra) # 800043ae <iput>
    return -1;
    80004986:	557d                	li	a0,-1
    80004988:	b7dd                	j	8000496e <dirlink+0x86>
      panic("dirlink read");
    8000498a:	00005517          	auipc	a0,0x5
    8000498e:	41650513          	addi	a0,a0,1046 # 80009da0 <syscalls+0x1c8>
    80004992:	ffffc097          	auipc	ra,0xffffc
    80004996:	b98080e7          	jalr	-1128(ra) # 8000052a <panic>
    panic("dirlink");
    8000499a:	00005517          	auipc	a0,0x5
    8000499e:	60650513          	addi	a0,a0,1542 # 80009fa0 <syscalls+0x3c8>
    800049a2:	ffffc097          	auipc	ra,0xffffc
    800049a6:	b88080e7          	jalr	-1144(ra) # 8000052a <panic>

00000000800049aa <namei>:

struct inode*
namei(char *path)
{
    800049aa:	1101                	addi	sp,sp,-32
    800049ac:	ec06                	sd	ra,24(sp)
    800049ae:	e822                	sd	s0,16(sp)
    800049b0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800049b2:	fe040613          	addi	a2,s0,-32
    800049b6:	4581                	li	a1,0
    800049b8:	00000097          	auipc	ra,0x0
    800049bc:	dd0080e7          	jalr	-560(ra) # 80004788 <namex>
}
    800049c0:	60e2                	ld	ra,24(sp)
    800049c2:	6442                	ld	s0,16(sp)
    800049c4:	6105                	addi	sp,sp,32
    800049c6:	8082                	ret

00000000800049c8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800049c8:	1141                	addi	sp,sp,-16
    800049ca:	e406                	sd	ra,8(sp)
    800049cc:	e022                	sd	s0,0(sp)
    800049ce:	0800                	addi	s0,sp,16
    800049d0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800049d2:	4585                	li	a1,1
    800049d4:	00000097          	auipc	ra,0x0
    800049d8:	db4080e7          	jalr	-588(ra) # 80004788 <namex>
}
    800049dc:	60a2                	ld	ra,8(sp)
    800049de:	6402                	ld	s0,0(sp)
    800049e0:	0141                	addi	sp,sp,16
    800049e2:	8082                	ret

00000000800049e4 <itoa>:


#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
    800049e4:	1101                	addi	sp,sp,-32
    800049e6:	ec22                	sd	s0,24(sp)
    800049e8:	1000                	addi	s0,sp,32
    800049ea:	872a                	mv	a4,a0
    800049ec:	852e                	mv	a0,a1
    char const digit[] = "0123456789";
    800049ee:	00005797          	auipc	a5,0x5
    800049f2:	3c278793          	addi	a5,a5,962 # 80009db0 <syscalls+0x1d8>
    800049f6:	6394                	ld	a3,0(a5)
    800049f8:	fed43023          	sd	a3,-32(s0)
    800049fc:	0087d683          	lhu	a3,8(a5)
    80004a00:	fed41423          	sh	a3,-24(s0)
    80004a04:	00a7c783          	lbu	a5,10(a5)
    80004a08:	fef40523          	sb	a5,-22(s0)
    char* p = b;
    80004a0c:	87ae                	mv	a5,a1
    if(i<0){
    80004a0e:	02074b63          	bltz	a4,80004a44 <itoa+0x60>
        *p++ = '-';
        i *= -1;
    }
    int shifter = i;
    80004a12:	86ba                	mv	a3,a4
    do{ //Move to where representation ends
        ++p;
        shifter = shifter/10;
    80004a14:	4629                	li	a2,10
        ++p;
    80004a16:	0785                	addi	a5,a5,1
        shifter = shifter/10;
    80004a18:	02c6c6bb          	divw	a3,a3,a2
    }while(shifter);
    80004a1c:	feed                	bnez	a3,80004a16 <itoa+0x32>
    *p = '\0';
    80004a1e:	00078023          	sb	zero,0(a5)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
    80004a22:	4629                	li	a2,10
    80004a24:	17fd                	addi	a5,a5,-1
    80004a26:	02c766bb          	remw	a3,a4,a2
    80004a2a:	ff040593          	addi	a1,s0,-16
    80004a2e:	96ae                	add	a3,a3,a1
    80004a30:	ff06c683          	lbu	a3,-16(a3)
    80004a34:	00d78023          	sb	a3,0(a5)
        i = i/10;
    80004a38:	02c7473b          	divw	a4,a4,a2
    }while(i);
    80004a3c:	f765                	bnez	a4,80004a24 <itoa+0x40>
    return b;
}
    80004a3e:	6462                	ld	s0,24(sp)
    80004a40:	6105                	addi	sp,sp,32
    80004a42:	8082                	ret
        *p++ = '-';
    80004a44:	00158793          	addi	a5,a1,1
    80004a48:	02d00693          	li	a3,45
    80004a4c:	00d58023          	sb	a3,0(a1)
        i *= -1;
    80004a50:	40e0073b          	negw	a4,a4
    80004a54:	bf7d                	j	80004a12 <itoa+0x2e>

0000000080004a56 <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
    80004a56:	711d                	addi	sp,sp,-96
    80004a58:	ec86                	sd	ra,88(sp)
    80004a5a:	e8a2                	sd	s0,80(sp)
    80004a5c:	e4a6                	sd	s1,72(sp)
    80004a5e:	e0ca                	sd	s2,64(sp)
    80004a60:	1080                	addi	s0,sp,96
    80004a62:	84aa                	mv	s1,a0
    printf("in RemoveSwapFile\n"); //TODO: delete
    80004a64:	00005517          	auipc	a0,0x5
    80004a68:	35c50513          	addi	a0,a0,860 # 80009dc0 <syscalls+0x1e8>
    80004a6c:	ffffc097          	auipc	ra,0xffffc
    80004a70:	b08080e7          	jalr	-1272(ra) # 80000574 <printf>

  //path of proccess
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    80004a74:	4619                	li	a2,6
    80004a76:	00005597          	auipc	a1,0x5
    80004a7a:	36258593          	addi	a1,a1,866 # 80009dd8 <syscalls+0x200>
    80004a7e:	fd040513          	addi	a0,s0,-48
    80004a82:	ffffc097          	auipc	ra,0xffffc
    80004a86:	298080e7          	jalr	664(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    80004a8a:	fd640593          	addi	a1,s0,-42
    80004a8e:	5888                	lw	a0,48(s1)
    80004a90:	00000097          	auipc	ra,0x0
    80004a94:	f54080e7          	jalr	-172(ra) # 800049e4 <itoa>
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ];
  uint off;

  if(0 == p->swapFile)
    80004a98:	1684b503          	ld	a0,360(s1)
    80004a9c:	16050763          	beqz	a0,80004c0a <removeSwapFile+0x1b4>
  {
    return -1;
  }
  fileclose(p->swapFile);
    80004aa0:	00001097          	auipc	ra,0x1
    80004aa4:	918080e7          	jalr	-1768(ra) # 800053b8 <fileclose>

  begin_op();
    80004aa8:	00000097          	auipc	ra,0x0
    80004aac:	444080e7          	jalr	1092(ra) # 80004eec <begin_op>
  if((dp = nameiparent(path, name)) == 0)
    80004ab0:	fb040593          	addi	a1,s0,-80
    80004ab4:	fd040513          	addi	a0,s0,-48
    80004ab8:	00000097          	auipc	ra,0x0
    80004abc:	f10080e7          	jalr	-240(ra) # 800049c8 <nameiparent>
    80004ac0:	892a                	mv	s2,a0
    80004ac2:	cd69                	beqz	a0,80004b9c <removeSwapFile+0x146>
  {
    end_op();
    return -1;
  }

  ilock(dp);
    80004ac4:	fffff097          	auipc	ra,0xfffff
    80004ac8:	730080e7          	jalr	1840(ra) # 800041f4 <ilock>

    // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004acc:	00005597          	auipc	a1,0x5
    80004ad0:	31458593          	addi	a1,a1,788 # 80009de0 <syscalls+0x208>
    80004ad4:	fb040513          	addi	a0,s0,-80
    80004ad8:	00000097          	auipc	ra,0x0
    80004adc:	be6080e7          	jalr	-1050(ra) # 800046be <namecmp>
    80004ae0:	c57d                	beqz	a0,80004bce <removeSwapFile+0x178>
    80004ae2:	00005597          	auipc	a1,0x5
    80004ae6:	30658593          	addi	a1,a1,774 # 80009de8 <syscalls+0x210>
    80004aea:	fb040513          	addi	a0,s0,-80
    80004aee:	00000097          	auipc	ra,0x0
    80004af2:	bd0080e7          	jalr	-1072(ra) # 800046be <namecmp>
    80004af6:	cd61                	beqz	a0,80004bce <removeSwapFile+0x178>
     goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    80004af8:	fac40613          	addi	a2,s0,-84
    80004afc:	fb040593          	addi	a1,s0,-80
    80004b00:	854a                	mv	a0,s2
    80004b02:	00000097          	auipc	ra,0x0
    80004b06:	bd6080e7          	jalr	-1066(ra) # 800046d8 <dirlookup>
    80004b0a:	84aa                	mv	s1,a0
    80004b0c:	c169                	beqz	a0,80004bce <removeSwapFile+0x178>
    goto bad;
  ilock(ip);
    80004b0e:	fffff097          	auipc	ra,0xfffff
    80004b12:	6e6080e7          	jalr	1766(ra) # 800041f4 <ilock>

  if(ip->nlink < 1)
    80004b16:	04a49783          	lh	a5,74(s1)
    80004b1a:	08f05763          	blez	a5,80004ba8 <removeSwapFile+0x152>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004b1e:	04449703          	lh	a4,68(s1)
    80004b22:	4785                	li	a5,1
    80004b24:	08f70a63          	beq	a4,a5,80004bb8 <removeSwapFile+0x162>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    80004b28:	4641                	li	a2,16
    80004b2a:	4581                	li	a1,0
    80004b2c:	fc040513          	addi	a0,s0,-64
    80004b30:	ffffc097          	auipc	ra,0xffffc
    80004b34:	18e080e7          	jalr	398(ra) # 80000cbe <memset>
  if(writei(dp,0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004b38:	4741                	li	a4,16
    80004b3a:	fac42683          	lw	a3,-84(s0)
    80004b3e:	fc040613          	addi	a2,s0,-64
    80004b42:	4581                	li	a1,0
    80004b44:	854a                	mv	a0,s2
    80004b46:	00000097          	auipc	ra,0x0
    80004b4a:	a5a080e7          	jalr	-1446(ra) # 800045a0 <writei>
    80004b4e:	47c1                	li	a5,16
    80004b50:	08f51a63          	bne	a0,a5,80004be4 <removeSwapFile+0x18e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    80004b54:	04449703          	lh	a4,68(s1)
    80004b58:	4785                	li	a5,1
    80004b5a:	08f70d63          	beq	a4,a5,80004bf4 <removeSwapFile+0x19e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    80004b5e:	854a                	mv	a0,s2
    80004b60:	00000097          	auipc	ra,0x0
    80004b64:	8f6080e7          	jalr	-1802(ra) # 80004456 <iunlockput>

  ip->nlink--;
    80004b68:	04a4d783          	lhu	a5,74(s1)
    80004b6c:	37fd                	addiw	a5,a5,-1
    80004b6e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004b72:	8526                	mv	a0,s1
    80004b74:	fffff097          	auipc	ra,0xfffff
    80004b78:	5b6080e7          	jalr	1462(ra) # 8000412a <iupdate>
  iunlockput(ip);
    80004b7c:	8526                	mv	a0,s1
    80004b7e:	00000097          	auipc	ra,0x0
    80004b82:	8d8080e7          	jalr	-1832(ra) # 80004456 <iunlockput>

  end_op();
    80004b86:	00000097          	auipc	ra,0x0
    80004b8a:	3e6080e7          	jalr	998(ra) # 80004f6c <end_op>

  return 0;
    80004b8e:	4501                	li	a0,0
    iunlockput(dp);
    end_op();
    return -1;
    printf("end RemoveSwapFile\n"); //TODO: delete

}
    80004b90:	60e6                	ld	ra,88(sp)
    80004b92:	6446                	ld	s0,80(sp)
    80004b94:	64a6                	ld	s1,72(sp)
    80004b96:	6906                	ld	s2,64(sp)
    80004b98:	6125                	addi	sp,sp,96
    80004b9a:	8082                	ret
    end_op();
    80004b9c:	00000097          	auipc	ra,0x0
    80004ba0:	3d0080e7          	jalr	976(ra) # 80004f6c <end_op>
    return -1;
    80004ba4:	557d                	li	a0,-1
    80004ba6:	b7ed                	j	80004b90 <removeSwapFile+0x13a>
    panic("unlink: nlink < 1");
    80004ba8:	00005517          	auipc	a0,0x5
    80004bac:	24850513          	addi	a0,a0,584 # 80009df0 <syscalls+0x218>
    80004bb0:	ffffc097          	auipc	ra,0xffffc
    80004bb4:	97a080e7          	jalr	-1670(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004bb8:	8526                	mv	a0,s1
    80004bba:	00001097          	auipc	ra,0x1
    80004bbe:	7fa080e7          	jalr	2042(ra) # 800063b4 <isdirempty>
    80004bc2:	f13d                	bnez	a0,80004b28 <removeSwapFile+0xd2>
    iunlockput(ip);
    80004bc4:	8526                	mv	a0,s1
    80004bc6:	00000097          	auipc	ra,0x0
    80004bca:	890080e7          	jalr	-1904(ra) # 80004456 <iunlockput>
    iunlockput(dp);
    80004bce:	854a                	mv	a0,s2
    80004bd0:	00000097          	auipc	ra,0x0
    80004bd4:	886080e7          	jalr	-1914(ra) # 80004456 <iunlockput>
    end_op();
    80004bd8:	00000097          	auipc	ra,0x0
    80004bdc:	394080e7          	jalr	916(ra) # 80004f6c <end_op>
    return -1;
    80004be0:	557d                	li	a0,-1
    80004be2:	b77d                	j	80004b90 <removeSwapFile+0x13a>
    panic("unlink: writei");
    80004be4:	00005517          	auipc	a0,0x5
    80004be8:	22450513          	addi	a0,a0,548 # 80009e08 <syscalls+0x230>
    80004bec:	ffffc097          	auipc	ra,0xffffc
    80004bf0:	93e080e7          	jalr	-1730(ra) # 8000052a <panic>
    dp->nlink--;
    80004bf4:	04a95783          	lhu	a5,74(s2)
    80004bf8:	37fd                	addiw	a5,a5,-1
    80004bfa:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80004bfe:	854a                	mv	a0,s2
    80004c00:	fffff097          	auipc	ra,0xfffff
    80004c04:	52a080e7          	jalr	1322(ra) # 8000412a <iupdate>
    80004c08:	bf99                	j	80004b5e <removeSwapFile+0x108>
    return -1;
    80004c0a:	557d                	li	a0,-1
    80004c0c:	b751                	j	80004b90 <removeSwapFile+0x13a>

0000000080004c0e <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
    80004c0e:	7179                	addi	sp,sp,-48
    80004c10:	f406                	sd	ra,40(sp)
    80004c12:	f022                	sd	s0,32(sp)
    80004c14:	ec26                	sd	s1,24(sp)
    80004c16:	e84a                	sd	s2,16(sp)
    80004c18:	1800                	addi	s0,sp,48
    80004c1a:	84aa                	mv	s1,a0
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    80004c1c:	4619                	li	a2,6
    80004c1e:	00005597          	auipc	a1,0x5
    80004c22:	1ba58593          	addi	a1,a1,442 # 80009dd8 <syscalls+0x200>
    80004c26:	fd040513          	addi	a0,s0,-48
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	0f0080e7          	jalr	240(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    80004c32:	fd640593          	addi	a1,s0,-42
    80004c36:	5888                	lw	a0,48(s1)
    80004c38:	00000097          	auipc	ra,0x0
    80004c3c:	dac080e7          	jalr	-596(ra) # 800049e4 <itoa>

  begin_op();
    80004c40:	00000097          	auipc	ra,0x0
    80004c44:	2ac080e7          	jalr	684(ra) # 80004eec <begin_op>

  struct inode * in = create(path, T_FILE, 0, 0);
    80004c48:	4681                	li	a3,0
    80004c4a:	4601                	li	a2,0
    80004c4c:	4589                	li	a1,2
    80004c4e:	fd040513          	addi	a0,s0,-48
    80004c52:	00002097          	auipc	ra,0x2
    80004c56:	956080e7          	jalr	-1706(ra) # 800065a8 <create>
    80004c5a:	892a                	mv	s2,a0
  iunlock(in);
    80004c5c:	fffff097          	auipc	ra,0xfffff
    80004c60:	65a080e7          	jalr	1626(ra) # 800042b6 <iunlock>
  p->swapFile = filealloc();  if (p->swapFile == 0)
    80004c64:	00000097          	auipc	ra,0x0
    80004c68:	698080e7          	jalr	1688(ra) # 800052fc <filealloc>
    80004c6c:	16a4b423          	sd	a0,360(s1)
    80004c70:	cd1d                	beqz	a0,80004cae <createSwapFile+0xa0>
    panic("no slot for files on /store");

  p->swapFile->ip = in;
    80004c72:	01253c23          	sd	s2,24(a0)
  p->swapFile->type = FD_INODE;
    80004c76:	1684b703          	ld	a4,360(s1)
    80004c7a:	4789                	li	a5,2
    80004c7c:	c31c                	sw	a5,0(a4)
  p->swapFile->off = 0;
    80004c7e:	1684b703          	ld	a4,360(s1)
    80004c82:	02072023          	sw	zero,32(a4) # 43020 <_entry-0x7ffbcfe0>
  p->swapFile->readable = O_WRONLY;
    80004c86:	1684b703          	ld	a4,360(s1)
    80004c8a:	4685                	li	a3,1
    80004c8c:	00d70423          	sb	a3,8(a4)
  p->swapFile->writable = O_RDWR;
    80004c90:	1684b703          	ld	a4,360(s1)
    80004c94:	00f704a3          	sb	a5,9(a4)
    end_op();
    80004c98:	00000097          	auipc	ra,0x0
    80004c9c:	2d4080e7          	jalr	724(ra) # 80004f6c <end_op>

    return 0;
}
    80004ca0:	4501                	li	a0,0
    80004ca2:	70a2                	ld	ra,40(sp)
    80004ca4:	7402                	ld	s0,32(sp)
    80004ca6:	64e2                	ld	s1,24(sp)
    80004ca8:	6942                	ld	s2,16(sp)
    80004caa:	6145                	addi	sp,sp,48
    80004cac:	8082                	ret
    panic("no slot for files on /store");
    80004cae:	00005517          	auipc	a0,0x5
    80004cb2:	16a50513          	addi	a0,a0,362 # 80009e18 <syscalls+0x240>
    80004cb6:	ffffc097          	auipc	ra,0xffffc
    80004cba:	874080e7          	jalr	-1932(ra) # 8000052a <panic>

0000000080004cbe <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004cbe:	1141                	addi	sp,sp,-16
    80004cc0:	e406                	sd	ra,8(sp)
    80004cc2:	e022                	sd	s0,0(sp)
    80004cc4:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004cc6:	16853783          	ld	a5,360(a0)
    80004cca:	d390                	sw	a2,32(a5)
  return kfilewrite(p->swapFile, (uint64)buffer, size);
    80004ccc:	8636                	mv	a2,a3
    80004cce:	16853503          	ld	a0,360(a0)
    80004cd2:	00001097          	auipc	ra,0x1
    80004cd6:	ad8080e7          	jalr	-1320(ra) # 800057aa <kfilewrite>
}
    80004cda:	60a2                	ld	ra,8(sp)
    80004cdc:	6402                	ld	s0,0(sp)
    80004cde:	0141                	addi	sp,sp,16
    80004ce0:	8082                	ret

0000000080004ce2 <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004ce2:	1141                	addi	sp,sp,-16
    80004ce4:	e406                	sd	ra,8(sp)
    80004ce6:	e022                	sd	s0,0(sp)
    80004ce8:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004cea:	16853783          	ld	a5,360(a0)
    80004cee:	d390                	sw	a2,32(a5)
  return kfileread(p->swapFile, (uint64)buffer,  size);
    80004cf0:	8636                	mv	a2,a3
    80004cf2:	16853503          	ld	a0,360(a0)
    80004cf6:	00001097          	auipc	ra,0x1
    80004cfa:	9f2080e7          	jalr	-1550(ra) # 800056e8 <kfileread>
    80004cfe:	60a2                	ld	ra,8(sp)
    80004d00:	6402                	ld	s0,0(sp)
    80004d02:	0141                	addi	sp,sp,16
    80004d04:	8082                	ret

0000000080004d06 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004d06:	1101                	addi	sp,sp,-32
    80004d08:	ec06                	sd	ra,24(sp)
    80004d0a:	e822                	sd	s0,16(sp)
    80004d0c:	e426                	sd	s1,8(sp)
    80004d0e:	e04a                	sd	s2,0(sp)
    80004d10:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004d12:	00027917          	auipc	s2,0x27
    80004d16:	d5e90913          	addi	s2,s2,-674 # 8002ba70 <log>
    80004d1a:	01892583          	lw	a1,24(s2)
    80004d1e:	02892503          	lw	a0,40(s2)
    80004d22:	fffff097          	auipc	ra,0xfffff
    80004d26:	cce080e7          	jalr	-818(ra) # 800039f0 <bread>
    80004d2a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004d2c:	02c92683          	lw	a3,44(s2)
    80004d30:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004d32:	02d05863          	blez	a3,80004d62 <write_head+0x5c>
    80004d36:	00027797          	auipc	a5,0x27
    80004d3a:	d6a78793          	addi	a5,a5,-662 # 8002baa0 <log+0x30>
    80004d3e:	05c50713          	addi	a4,a0,92
    80004d42:	36fd                	addiw	a3,a3,-1
    80004d44:	02069613          	slli	a2,a3,0x20
    80004d48:	01e65693          	srli	a3,a2,0x1e
    80004d4c:	00027617          	auipc	a2,0x27
    80004d50:	d5860613          	addi	a2,a2,-680 # 8002baa4 <log+0x34>
    80004d54:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004d56:	4390                	lw	a2,0(a5)
    80004d58:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004d5a:	0791                	addi	a5,a5,4
    80004d5c:	0711                	addi	a4,a4,4
    80004d5e:	fed79ce3          	bne	a5,a3,80004d56 <write_head+0x50>
  }
  bwrite(buf);
    80004d62:	8526                	mv	a0,s1
    80004d64:	fffff097          	auipc	ra,0xfffff
    80004d68:	d7e080e7          	jalr	-642(ra) # 80003ae2 <bwrite>
  brelse(buf);
    80004d6c:	8526                	mv	a0,s1
    80004d6e:	fffff097          	auipc	ra,0xfffff
    80004d72:	db2080e7          	jalr	-590(ra) # 80003b20 <brelse>
}
    80004d76:	60e2                	ld	ra,24(sp)
    80004d78:	6442                	ld	s0,16(sp)
    80004d7a:	64a2                	ld	s1,8(sp)
    80004d7c:	6902                	ld	s2,0(sp)
    80004d7e:	6105                	addi	sp,sp,32
    80004d80:	8082                	ret

0000000080004d82 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004d82:	00027797          	auipc	a5,0x27
    80004d86:	d1a7a783          	lw	a5,-742(a5) # 8002ba9c <log+0x2c>
    80004d8a:	0af05d63          	blez	a5,80004e44 <install_trans+0xc2>
{
    80004d8e:	7139                	addi	sp,sp,-64
    80004d90:	fc06                	sd	ra,56(sp)
    80004d92:	f822                	sd	s0,48(sp)
    80004d94:	f426                	sd	s1,40(sp)
    80004d96:	f04a                	sd	s2,32(sp)
    80004d98:	ec4e                	sd	s3,24(sp)
    80004d9a:	e852                	sd	s4,16(sp)
    80004d9c:	e456                	sd	s5,8(sp)
    80004d9e:	e05a                	sd	s6,0(sp)
    80004da0:	0080                	addi	s0,sp,64
    80004da2:	8b2a                	mv	s6,a0
    80004da4:	00027a97          	auipc	s5,0x27
    80004da8:	cfca8a93          	addi	s5,s5,-772 # 8002baa0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004dac:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004dae:	00027997          	auipc	s3,0x27
    80004db2:	cc298993          	addi	s3,s3,-830 # 8002ba70 <log>
    80004db6:	a00d                	j	80004dd8 <install_trans+0x56>
    brelse(lbuf);
    80004db8:	854a                	mv	a0,s2
    80004dba:	fffff097          	auipc	ra,0xfffff
    80004dbe:	d66080e7          	jalr	-666(ra) # 80003b20 <brelse>
    brelse(dbuf);
    80004dc2:	8526                	mv	a0,s1
    80004dc4:	fffff097          	auipc	ra,0xfffff
    80004dc8:	d5c080e7          	jalr	-676(ra) # 80003b20 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004dcc:	2a05                	addiw	s4,s4,1
    80004dce:	0a91                	addi	s5,s5,4
    80004dd0:	02c9a783          	lw	a5,44(s3)
    80004dd4:	04fa5e63          	bge	s4,a5,80004e30 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004dd8:	0189a583          	lw	a1,24(s3)
    80004ddc:	014585bb          	addw	a1,a1,s4
    80004de0:	2585                	addiw	a1,a1,1
    80004de2:	0289a503          	lw	a0,40(s3)
    80004de6:	fffff097          	auipc	ra,0xfffff
    80004dea:	c0a080e7          	jalr	-1014(ra) # 800039f0 <bread>
    80004dee:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004df0:	000aa583          	lw	a1,0(s5)
    80004df4:	0289a503          	lw	a0,40(s3)
    80004df8:	fffff097          	auipc	ra,0xfffff
    80004dfc:	bf8080e7          	jalr	-1032(ra) # 800039f0 <bread>
    80004e00:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004e02:	40000613          	li	a2,1024
    80004e06:	05890593          	addi	a1,s2,88
    80004e0a:	05850513          	addi	a0,a0,88
    80004e0e:	ffffc097          	auipc	ra,0xffffc
    80004e12:	f0c080e7          	jalr	-244(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004e16:	8526                	mv	a0,s1
    80004e18:	fffff097          	auipc	ra,0xfffff
    80004e1c:	cca080e7          	jalr	-822(ra) # 80003ae2 <bwrite>
    if(recovering == 0)
    80004e20:	f80b1ce3          	bnez	s6,80004db8 <install_trans+0x36>
      bunpin(dbuf);
    80004e24:	8526                	mv	a0,s1
    80004e26:	fffff097          	auipc	ra,0xfffff
    80004e2a:	dd4080e7          	jalr	-556(ra) # 80003bfa <bunpin>
    80004e2e:	b769                	j	80004db8 <install_trans+0x36>
}
    80004e30:	70e2                	ld	ra,56(sp)
    80004e32:	7442                	ld	s0,48(sp)
    80004e34:	74a2                	ld	s1,40(sp)
    80004e36:	7902                	ld	s2,32(sp)
    80004e38:	69e2                	ld	s3,24(sp)
    80004e3a:	6a42                	ld	s4,16(sp)
    80004e3c:	6aa2                	ld	s5,8(sp)
    80004e3e:	6b02                	ld	s6,0(sp)
    80004e40:	6121                	addi	sp,sp,64
    80004e42:	8082                	ret
    80004e44:	8082                	ret

0000000080004e46 <initlog>:
{
    80004e46:	7179                	addi	sp,sp,-48
    80004e48:	f406                	sd	ra,40(sp)
    80004e4a:	f022                	sd	s0,32(sp)
    80004e4c:	ec26                	sd	s1,24(sp)
    80004e4e:	e84a                	sd	s2,16(sp)
    80004e50:	e44e                	sd	s3,8(sp)
    80004e52:	1800                	addi	s0,sp,48
    80004e54:	892a                	mv	s2,a0
    80004e56:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004e58:	00027497          	auipc	s1,0x27
    80004e5c:	c1848493          	addi	s1,s1,-1000 # 8002ba70 <log>
    80004e60:	00005597          	auipc	a1,0x5
    80004e64:	fd858593          	addi	a1,a1,-40 # 80009e38 <syscalls+0x260>
    80004e68:	8526                	mv	a0,s1
    80004e6a:	ffffc097          	auipc	ra,0xffffc
    80004e6e:	cc8080e7          	jalr	-824(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004e72:	0149a583          	lw	a1,20(s3)
    80004e76:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004e78:	0109a783          	lw	a5,16(s3)
    80004e7c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004e7e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004e82:	854a                	mv	a0,s2
    80004e84:	fffff097          	auipc	ra,0xfffff
    80004e88:	b6c080e7          	jalr	-1172(ra) # 800039f0 <bread>
  log.lh.n = lh->n;
    80004e8c:	4d34                	lw	a3,88(a0)
    80004e8e:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004e90:	02d05663          	blez	a3,80004ebc <initlog+0x76>
    80004e94:	05c50793          	addi	a5,a0,92
    80004e98:	00027717          	auipc	a4,0x27
    80004e9c:	c0870713          	addi	a4,a4,-1016 # 8002baa0 <log+0x30>
    80004ea0:	36fd                	addiw	a3,a3,-1
    80004ea2:	02069613          	slli	a2,a3,0x20
    80004ea6:	01e65693          	srli	a3,a2,0x1e
    80004eaa:	06050613          	addi	a2,a0,96
    80004eae:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004eb0:	4390                	lw	a2,0(a5)
    80004eb2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004eb4:	0791                	addi	a5,a5,4
    80004eb6:	0711                	addi	a4,a4,4
    80004eb8:	fed79ce3          	bne	a5,a3,80004eb0 <initlog+0x6a>
  brelse(buf);
    80004ebc:	fffff097          	auipc	ra,0xfffff
    80004ec0:	c64080e7          	jalr	-924(ra) # 80003b20 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004ec4:	4505                	li	a0,1
    80004ec6:	00000097          	auipc	ra,0x0
    80004eca:	ebc080e7          	jalr	-324(ra) # 80004d82 <install_trans>
  log.lh.n = 0;
    80004ece:	00027797          	auipc	a5,0x27
    80004ed2:	bc07a723          	sw	zero,-1074(a5) # 8002ba9c <log+0x2c>
  write_head(); // clear the log
    80004ed6:	00000097          	auipc	ra,0x0
    80004eda:	e30080e7          	jalr	-464(ra) # 80004d06 <write_head>
}
    80004ede:	70a2                	ld	ra,40(sp)
    80004ee0:	7402                	ld	s0,32(sp)
    80004ee2:	64e2                	ld	s1,24(sp)
    80004ee4:	6942                	ld	s2,16(sp)
    80004ee6:	69a2                	ld	s3,8(sp)
    80004ee8:	6145                	addi	sp,sp,48
    80004eea:	8082                	ret

0000000080004eec <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004eec:	1101                	addi	sp,sp,-32
    80004eee:	ec06                	sd	ra,24(sp)
    80004ef0:	e822                	sd	s0,16(sp)
    80004ef2:	e426                	sd	s1,8(sp)
    80004ef4:	e04a                	sd	s2,0(sp)
    80004ef6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004ef8:	00027517          	auipc	a0,0x27
    80004efc:	b7850513          	addi	a0,a0,-1160 # 8002ba70 <log>
    80004f00:	ffffc097          	auipc	ra,0xffffc
    80004f04:	cc2080e7          	jalr	-830(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    80004f08:	00027497          	auipc	s1,0x27
    80004f0c:	b6848493          	addi	s1,s1,-1176 # 8002ba70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004f10:	4979                	li	s2,30
    80004f12:	a039                	j	80004f20 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004f14:	85a6                	mv	a1,s1
    80004f16:	8526                	mv	a0,s1
    80004f18:	ffffd097          	auipc	ra,0xffffd
    80004f1c:	51e080e7          	jalr	1310(ra) # 80002436 <sleep>
    if(log.committing){
    80004f20:	50dc                	lw	a5,36(s1)
    80004f22:	fbed                	bnez	a5,80004f14 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004f24:	509c                	lw	a5,32(s1)
    80004f26:	0017871b          	addiw	a4,a5,1
    80004f2a:	0007069b          	sext.w	a3,a4
    80004f2e:	0027179b          	slliw	a5,a4,0x2
    80004f32:	9fb9                	addw	a5,a5,a4
    80004f34:	0017979b          	slliw	a5,a5,0x1
    80004f38:	54d8                	lw	a4,44(s1)
    80004f3a:	9fb9                	addw	a5,a5,a4
    80004f3c:	00f95963          	bge	s2,a5,80004f4e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004f40:	85a6                	mv	a1,s1
    80004f42:	8526                	mv	a0,s1
    80004f44:	ffffd097          	auipc	ra,0xffffd
    80004f48:	4f2080e7          	jalr	1266(ra) # 80002436 <sleep>
    80004f4c:	bfd1                	j	80004f20 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004f4e:	00027517          	auipc	a0,0x27
    80004f52:	b2250513          	addi	a0,a0,-1246 # 8002ba70 <log>
    80004f56:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004f58:	ffffc097          	auipc	ra,0xffffc
    80004f5c:	d1e080e7          	jalr	-738(ra) # 80000c76 <release>
      break;
    }
  }
}
    80004f60:	60e2                	ld	ra,24(sp)
    80004f62:	6442                	ld	s0,16(sp)
    80004f64:	64a2                	ld	s1,8(sp)
    80004f66:	6902                	ld	s2,0(sp)
    80004f68:	6105                	addi	sp,sp,32
    80004f6a:	8082                	ret

0000000080004f6c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004f6c:	7139                	addi	sp,sp,-64
    80004f6e:	fc06                	sd	ra,56(sp)
    80004f70:	f822                	sd	s0,48(sp)
    80004f72:	f426                	sd	s1,40(sp)
    80004f74:	f04a                	sd	s2,32(sp)
    80004f76:	ec4e                	sd	s3,24(sp)
    80004f78:	e852                	sd	s4,16(sp)
    80004f7a:	e456                	sd	s5,8(sp)
    80004f7c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004f7e:	00027497          	auipc	s1,0x27
    80004f82:	af248493          	addi	s1,s1,-1294 # 8002ba70 <log>
    80004f86:	8526                	mv	a0,s1
    80004f88:	ffffc097          	auipc	ra,0xffffc
    80004f8c:	c3a080e7          	jalr	-966(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004f90:	509c                	lw	a5,32(s1)
    80004f92:	37fd                	addiw	a5,a5,-1
    80004f94:	0007891b          	sext.w	s2,a5
    80004f98:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004f9a:	50dc                	lw	a5,36(s1)
    80004f9c:	e7b9                	bnez	a5,80004fea <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004f9e:	04091e63          	bnez	s2,80004ffa <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004fa2:	00027497          	auipc	s1,0x27
    80004fa6:	ace48493          	addi	s1,s1,-1330 # 8002ba70 <log>
    80004faa:	4785                	li	a5,1
    80004fac:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004fae:	8526                	mv	a0,s1
    80004fb0:	ffffc097          	auipc	ra,0xffffc
    80004fb4:	cc6080e7          	jalr	-826(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004fb8:	54dc                	lw	a5,44(s1)
    80004fba:	06f04763          	bgtz	a5,80005028 <end_op+0xbc>
    acquire(&log.lock);
    80004fbe:	00027497          	auipc	s1,0x27
    80004fc2:	ab248493          	addi	s1,s1,-1358 # 8002ba70 <log>
    80004fc6:	8526                	mv	a0,s1
    80004fc8:	ffffc097          	auipc	ra,0xffffc
    80004fcc:	bfa080e7          	jalr	-1030(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004fd0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004fd4:	8526                	mv	a0,s1
    80004fd6:	ffffd097          	auipc	ra,0xffffd
    80004fda:	5ec080e7          	jalr	1516(ra) # 800025c2 <wakeup>
    release(&log.lock);
    80004fde:	8526                	mv	a0,s1
    80004fe0:	ffffc097          	auipc	ra,0xffffc
    80004fe4:	c96080e7          	jalr	-874(ra) # 80000c76 <release>
}
    80004fe8:	a03d                	j	80005016 <end_op+0xaa>
    panic("log.committing");
    80004fea:	00005517          	auipc	a0,0x5
    80004fee:	e5650513          	addi	a0,a0,-426 # 80009e40 <syscalls+0x268>
    80004ff2:	ffffb097          	auipc	ra,0xffffb
    80004ff6:	538080e7          	jalr	1336(ra) # 8000052a <panic>
    wakeup(&log);
    80004ffa:	00027497          	auipc	s1,0x27
    80004ffe:	a7648493          	addi	s1,s1,-1418 # 8002ba70 <log>
    80005002:	8526                	mv	a0,s1
    80005004:	ffffd097          	auipc	ra,0xffffd
    80005008:	5be080e7          	jalr	1470(ra) # 800025c2 <wakeup>
  release(&log.lock);
    8000500c:	8526                	mv	a0,s1
    8000500e:	ffffc097          	auipc	ra,0xffffc
    80005012:	c68080e7          	jalr	-920(ra) # 80000c76 <release>
}
    80005016:	70e2                	ld	ra,56(sp)
    80005018:	7442                	ld	s0,48(sp)
    8000501a:	74a2                	ld	s1,40(sp)
    8000501c:	7902                	ld	s2,32(sp)
    8000501e:	69e2                	ld	s3,24(sp)
    80005020:	6a42                	ld	s4,16(sp)
    80005022:	6aa2                	ld	s5,8(sp)
    80005024:	6121                	addi	sp,sp,64
    80005026:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80005028:	00027a97          	auipc	s5,0x27
    8000502c:	a78a8a93          	addi	s5,s5,-1416 # 8002baa0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80005030:	00027a17          	auipc	s4,0x27
    80005034:	a40a0a13          	addi	s4,s4,-1472 # 8002ba70 <log>
    80005038:	018a2583          	lw	a1,24(s4)
    8000503c:	012585bb          	addw	a1,a1,s2
    80005040:	2585                	addiw	a1,a1,1
    80005042:	028a2503          	lw	a0,40(s4)
    80005046:	fffff097          	auipc	ra,0xfffff
    8000504a:	9aa080e7          	jalr	-1622(ra) # 800039f0 <bread>
    8000504e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80005050:	000aa583          	lw	a1,0(s5)
    80005054:	028a2503          	lw	a0,40(s4)
    80005058:	fffff097          	auipc	ra,0xfffff
    8000505c:	998080e7          	jalr	-1640(ra) # 800039f0 <bread>
    80005060:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80005062:	40000613          	li	a2,1024
    80005066:	05850593          	addi	a1,a0,88
    8000506a:	05848513          	addi	a0,s1,88
    8000506e:	ffffc097          	auipc	ra,0xffffc
    80005072:	cac080e7          	jalr	-852(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80005076:	8526                	mv	a0,s1
    80005078:	fffff097          	auipc	ra,0xfffff
    8000507c:	a6a080e7          	jalr	-1430(ra) # 80003ae2 <bwrite>
    brelse(from);
    80005080:	854e                	mv	a0,s3
    80005082:	fffff097          	auipc	ra,0xfffff
    80005086:	a9e080e7          	jalr	-1378(ra) # 80003b20 <brelse>
    brelse(to);
    8000508a:	8526                	mv	a0,s1
    8000508c:	fffff097          	auipc	ra,0xfffff
    80005090:	a94080e7          	jalr	-1388(ra) # 80003b20 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005094:	2905                	addiw	s2,s2,1
    80005096:	0a91                	addi	s5,s5,4
    80005098:	02ca2783          	lw	a5,44(s4)
    8000509c:	f8f94ee3          	blt	s2,a5,80005038 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800050a0:	00000097          	auipc	ra,0x0
    800050a4:	c66080e7          	jalr	-922(ra) # 80004d06 <write_head>
    install_trans(0); // Now install writes to home locations
    800050a8:	4501                	li	a0,0
    800050aa:	00000097          	auipc	ra,0x0
    800050ae:	cd8080e7          	jalr	-808(ra) # 80004d82 <install_trans>
    log.lh.n = 0;
    800050b2:	00027797          	auipc	a5,0x27
    800050b6:	9e07a523          	sw	zero,-1558(a5) # 8002ba9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800050ba:	00000097          	auipc	ra,0x0
    800050be:	c4c080e7          	jalr	-948(ra) # 80004d06 <write_head>
    800050c2:	bdf5                	j	80004fbe <end_op+0x52>

00000000800050c4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800050c4:	1101                	addi	sp,sp,-32
    800050c6:	ec06                	sd	ra,24(sp)
    800050c8:	e822                	sd	s0,16(sp)
    800050ca:	e426                	sd	s1,8(sp)
    800050cc:	e04a                	sd	s2,0(sp)
    800050ce:	1000                	addi	s0,sp,32
    800050d0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800050d2:	00027917          	auipc	s2,0x27
    800050d6:	99e90913          	addi	s2,s2,-1634 # 8002ba70 <log>
    800050da:	854a                	mv	a0,s2
    800050dc:	ffffc097          	auipc	ra,0xffffc
    800050e0:	ae6080e7          	jalr	-1306(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800050e4:	02c92603          	lw	a2,44(s2)
    800050e8:	47f5                	li	a5,29
    800050ea:	06c7c563          	blt	a5,a2,80005154 <log_write+0x90>
    800050ee:	00027797          	auipc	a5,0x27
    800050f2:	99e7a783          	lw	a5,-1634(a5) # 8002ba8c <log+0x1c>
    800050f6:	37fd                	addiw	a5,a5,-1
    800050f8:	04f65e63          	bge	a2,a5,80005154 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800050fc:	00027797          	auipc	a5,0x27
    80005100:	9947a783          	lw	a5,-1644(a5) # 8002ba90 <log+0x20>
    80005104:	06f05063          	blez	a5,80005164 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80005108:	4781                	li	a5,0
    8000510a:	06c05563          	blez	a2,80005174 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000510e:	44cc                	lw	a1,12(s1)
    80005110:	00027717          	auipc	a4,0x27
    80005114:	99070713          	addi	a4,a4,-1648 # 8002baa0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80005118:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000511a:	4314                	lw	a3,0(a4)
    8000511c:	04b68c63          	beq	a3,a1,80005174 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80005120:	2785                	addiw	a5,a5,1
    80005122:	0711                	addi	a4,a4,4
    80005124:	fef61be3          	bne	a2,a5,8000511a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80005128:	0621                	addi	a2,a2,8
    8000512a:	060a                	slli	a2,a2,0x2
    8000512c:	00027797          	auipc	a5,0x27
    80005130:	94478793          	addi	a5,a5,-1724 # 8002ba70 <log>
    80005134:	963e                	add	a2,a2,a5
    80005136:	44dc                	lw	a5,12(s1)
    80005138:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000513a:	8526                	mv	a0,s1
    8000513c:	fffff097          	auipc	ra,0xfffff
    80005140:	a82080e7          	jalr	-1406(ra) # 80003bbe <bpin>
    log.lh.n++;
    80005144:	00027717          	auipc	a4,0x27
    80005148:	92c70713          	addi	a4,a4,-1748 # 8002ba70 <log>
    8000514c:	575c                	lw	a5,44(a4)
    8000514e:	2785                	addiw	a5,a5,1
    80005150:	d75c                	sw	a5,44(a4)
    80005152:	a835                	j	8000518e <log_write+0xca>
    panic("too big a transaction");
    80005154:	00005517          	auipc	a0,0x5
    80005158:	cfc50513          	addi	a0,a0,-772 # 80009e50 <syscalls+0x278>
    8000515c:	ffffb097          	auipc	ra,0xffffb
    80005160:	3ce080e7          	jalr	974(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80005164:	00005517          	auipc	a0,0x5
    80005168:	d0450513          	addi	a0,a0,-764 # 80009e68 <syscalls+0x290>
    8000516c:	ffffb097          	auipc	ra,0xffffb
    80005170:	3be080e7          	jalr	958(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80005174:	00878713          	addi	a4,a5,8
    80005178:	00271693          	slli	a3,a4,0x2
    8000517c:	00027717          	auipc	a4,0x27
    80005180:	8f470713          	addi	a4,a4,-1804 # 8002ba70 <log>
    80005184:	9736                	add	a4,a4,a3
    80005186:	44d4                	lw	a3,12(s1)
    80005188:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000518a:	faf608e3          	beq	a2,a5,8000513a <log_write+0x76>
  }
  release(&log.lock);
    8000518e:	00027517          	auipc	a0,0x27
    80005192:	8e250513          	addi	a0,a0,-1822 # 8002ba70 <log>
    80005196:	ffffc097          	auipc	ra,0xffffc
    8000519a:	ae0080e7          	jalr	-1312(ra) # 80000c76 <release>
}
    8000519e:	60e2                	ld	ra,24(sp)
    800051a0:	6442                	ld	s0,16(sp)
    800051a2:	64a2                	ld	s1,8(sp)
    800051a4:	6902                	ld	s2,0(sp)
    800051a6:	6105                	addi	sp,sp,32
    800051a8:	8082                	ret

00000000800051aa <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800051aa:	1101                	addi	sp,sp,-32
    800051ac:	ec06                	sd	ra,24(sp)
    800051ae:	e822                	sd	s0,16(sp)
    800051b0:	e426                	sd	s1,8(sp)
    800051b2:	e04a                	sd	s2,0(sp)
    800051b4:	1000                	addi	s0,sp,32
    800051b6:	84aa                	mv	s1,a0
    800051b8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800051ba:	00005597          	auipc	a1,0x5
    800051be:	cce58593          	addi	a1,a1,-818 # 80009e88 <syscalls+0x2b0>
    800051c2:	0521                	addi	a0,a0,8
    800051c4:	ffffc097          	auipc	ra,0xffffc
    800051c8:	96e080e7          	jalr	-1682(ra) # 80000b32 <initlock>
  lk->name = name;
    800051cc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800051d0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800051d4:	0204a423          	sw	zero,40(s1)
}
    800051d8:	60e2                	ld	ra,24(sp)
    800051da:	6442                	ld	s0,16(sp)
    800051dc:	64a2                	ld	s1,8(sp)
    800051de:	6902                	ld	s2,0(sp)
    800051e0:	6105                	addi	sp,sp,32
    800051e2:	8082                	ret

00000000800051e4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800051e4:	1101                	addi	sp,sp,-32
    800051e6:	ec06                	sd	ra,24(sp)
    800051e8:	e822                	sd	s0,16(sp)
    800051ea:	e426                	sd	s1,8(sp)
    800051ec:	e04a                	sd	s2,0(sp)
    800051ee:	1000                	addi	s0,sp,32
    800051f0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800051f2:	00850913          	addi	s2,a0,8
    800051f6:	854a                	mv	a0,s2
    800051f8:	ffffc097          	auipc	ra,0xffffc
    800051fc:	9ca080e7          	jalr	-1590(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    80005200:	409c                	lw	a5,0(s1)
    80005202:	cb89                	beqz	a5,80005214 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80005204:	85ca                	mv	a1,s2
    80005206:	8526                	mv	a0,s1
    80005208:	ffffd097          	auipc	ra,0xffffd
    8000520c:	22e080e7          	jalr	558(ra) # 80002436 <sleep>
  while (lk->locked) {
    80005210:	409c                	lw	a5,0(s1)
    80005212:	fbed                	bnez	a5,80005204 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80005214:	4785                	li	a5,1
    80005216:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80005218:	ffffd097          	auipc	ra,0xffffd
    8000521c:	c7c080e7          	jalr	-900(ra) # 80001e94 <myproc>
    80005220:	591c                	lw	a5,48(a0)
    80005222:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005224:	854a                	mv	a0,s2
    80005226:	ffffc097          	auipc	ra,0xffffc
    8000522a:	a50080e7          	jalr	-1456(ra) # 80000c76 <release>
}
    8000522e:	60e2                	ld	ra,24(sp)
    80005230:	6442                	ld	s0,16(sp)
    80005232:	64a2                	ld	s1,8(sp)
    80005234:	6902                	ld	s2,0(sp)
    80005236:	6105                	addi	sp,sp,32
    80005238:	8082                	ret

000000008000523a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000523a:	1101                	addi	sp,sp,-32
    8000523c:	ec06                	sd	ra,24(sp)
    8000523e:	e822                	sd	s0,16(sp)
    80005240:	e426                	sd	s1,8(sp)
    80005242:	e04a                	sd	s2,0(sp)
    80005244:	1000                	addi	s0,sp,32
    80005246:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005248:	00850913          	addi	s2,a0,8
    8000524c:	854a                	mv	a0,s2
    8000524e:	ffffc097          	auipc	ra,0xffffc
    80005252:	974080e7          	jalr	-1676(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80005256:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000525a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000525e:	8526                	mv	a0,s1
    80005260:	ffffd097          	auipc	ra,0xffffd
    80005264:	362080e7          	jalr	866(ra) # 800025c2 <wakeup>
  release(&lk->lk);
    80005268:	854a                	mv	a0,s2
    8000526a:	ffffc097          	auipc	ra,0xffffc
    8000526e:	a0c080e7          	jalr	-1524(ra) # 80000c76 <release>
}
    80005272:	60e2                	ld	ra,24(sp)
    80005274:	6442                	ld	s0,16(sp)
    80005276:	64a2                	ld	s1,8(sp)
    80005278:	6902                	ld	s2,0(sp)
    8000527a:	6105                	addi	sp,sp,32
    8000527c:	8082                	ret

000000008000527e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000527e:	7179                	addi	sp,sp,-48
    80005280:	f406                	sd	ra,40(sp)
    80005282:	f022                	sd	s0,32(sp)
    80005284:	ec26                	sd	s1,24(sp)
    80005286:	e84a                	sd	s2,16(sp)
    80005288:	e44e                	sd	s3,8(sp)
    8000528a:	1800                	addi	s0,sp,48
    8000528c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000528e:	00850913          	addi	s2,a0,8
    80005292:	854a                	mv	a0,s2
    80005294:	ffffc097          	auipc	ra,0xffffc
    80005298:	92e080e7          	jalr	-1746(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000529c:	409c                	lw	a5,0(s1)
    8000529e:	ef99                	bnez	a5,800052bc <holdingsleep+0x3e>
    800052a0:	4481                	li	s1,0
  release(&lk->lk);
    800052a2:	854a                	mv	a0,s2
    800052a4:	ffffc097          	auipc	ra,0xffffc
    800052a8:	9d2080e7          	jalr	-1582(ra) # 80000c76 <release>
  return r;
}
    800052ac:	8526                	mv	a0,s1
    800052ae:	70a2                	ld	ra,40(sp)
    800052b0:	7402                	ld	s0,32(sp)
    800052b2:	64e2                	ld	s1,24(sp)
    800052b4:	6942                	ld	s2,16(sp)
    800052b6:	69a2                	ld	s3,8(sp)
    800052b8:	6145                	addi	sp,sp,48
    800052ba:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800052bc:	0284a983          	lw	s3,40(s1)
    800052c0:	ffffd097          	auipc	ra,0xffffd
    800052c4:	bd4080e7          	jalr	-1068(ra) # 80001e94 <myproc>
    800052c8:	5904                	lw	s1,48(a0)
    800052ca:	413484b3          	sub	s1,s1,s3
    800052ce:	0014b493          	seqz	s1,s1
    800052d2:	bfc1                	j	800052a2 <holdingsleep+0x24>

00000000800052d4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800052d4:	1141                	addi	sp,sp,-16
    800052d6:	e406                	sd	ra,8(sp)
    800052d8:	e022                	sd	s0,0(sp)
    800052da:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800052dc:	00005597          	auipc	a1,0x5
    800052e0:	bbc58593          	addi	a1,a1,-1092 # 80009e98 <syscalls+0x2c0>
    800052e4:	00027517          	auipc	a0,0x27
    800052e8:	8d450513          	addi	a0,a0,-1836 # 8002bbb8 <ftable>
    800052ec:	ffffc097          	auipc	ra,0xffffc
    800052f0:	846080e7          	jalr	-1978(ra) # 80000b32 <initlock>
}
    800052f4:	60a2                	ld	ra,8(sp)
    800052f6:	6402                	ld	s0,0(sp)
    800052f8:	0141                	addi	sp,sp,16
    800052fa:	8082                	ret

00000000800052fc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800052fc:	1101                	addi	sp,sp,-32
    800052fe:	ec06                	sd	ra,24(sp)
    80005300:	e822                	sd	s0,16(sp)
    80005302:	e426                	sd	s1,8(sp)
    80005304:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80005306:	00027517          	auipc	a0,0x27
    8000530a:	8b250513          	addi	a0,a0,-1870 # 8002bbb8 <ftable>
    8000530e:	ffffc097          	auipc	ra,0xffffc
    80005312:	8b4080e7          	jalr	-1868(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005316:	00027497          	auipc	s1,0x27
    8000531a:	8ba48493          	addi	s1,s1,-1862 # 8002bbd0 <ftable+0x18>
    8000531e:	00028717          	auipc	a4,0x28
    80005322:	85270713          	addi	a4,a4,-1966 # 8002cb70 <ftable+0xfb8>
    if(f->ref == 0){
    80005326:	40dc                	lw	a5,4(s1)
    80005328:	cf99                	beqz	a5,80005346 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000532a:	02848493          	addi	s1,s1,40
    8000532e:	fee49ce3          	bne	s1,a4,80005326 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005332:	00027517          	auipc	a0,0x27
    80005336:	88650513          	addi	a0,a0,-1914 # 8002bbb8 <ftable>
    8000533a:	ffffc097          	auipc	ra,0xffffc
    8000533e:	93c080e7          	jalr	-1732(ra) # 80000c76 <release>
  return 0;
    80005342:	4481                	li	s1,0
    80005344:	a819                	j	8000535a <filealloc+0x5e>
      f->ref = 1;
    80005346:	4785                	li	a5,1
    80005348:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000534a:	00027517          	auipc	a0,0x27
    8000534e:	86e50513          	addi	a0,a0,-1938 # 8002bbb8 <ftable>
    80005352:	ffffc097          	auipc	ra,0xffffc
    80005356:	924080e7          	jalr	-1756(ra) # 80000c76 <release>
}
    8000535a:	8526                	mv	a0,s1
    8000535c:	60e2                	ld	ra,24(sp)
    8000535e:	6442                	ld	s0,16(sp)
    80005360:	64a2                	ld	s1,8(sp)
    80005362:	6105                	addi	sp,sp,32
    80005364:	8082                	ret

0000000080005366 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005366:	1101                	addi	sp,sp,-32
    80005368:	ec06                	sd	ra,24(sp)
    8000536a:	e822                	sd	s0,16(sp)
    8000536c:	e426                	sd	s1,8(sp)
    8000536e:	1000                	addi	s0,sp,32
    80005370:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005372:	00027517          	auipc	a0,0x27
    80005376:	84650513          	addi	a0,a0,-1978 # 8002bbb8 <ftable>
    8000537a:	ffffc097          	auipc	ra,0xffffc
    8000537e:	848080e7          	jalr	-1976(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80005382:	40dc                	lw	a5,4(s1)
    80005384:	02f05263          	blez	a5,800053a8 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80005388:	2785                	addiw	a5,a5,1
    8000538a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000538c:	00027517          	auipc	a0,0x27
    80005390:	82c50513          	addi	a0,a0,-2004 # 8002bbb8 <ftable>
    80005394:	ffffc097          	auipc	ra,0xffffc
    80005398:	8e2080e7          	jalr	-1822(ra) # 80000c76 <release>
  return f;
}
    8000539c:	8526                	mv	a0,s1
    8000539e:	60e2                	ld	ra,24(sp)
    800053a0:	6442                	ld	s0,16(sp)
    800053a2:	64a2                	ld	s1,8(sp)
    800053a4:	6105                	addi	sp,sp,32
    800053a6:	8082                	ret
    panic("filedup");
    800053a8:	00005517          	auipc	a0,0x5
    800053ac:	af850513          	addi	a0,a0,-1288 # 80009ea0 <syscalls+0x2c8>
    800053b0:	ffffb097          	auipc	ra,0xffffb
    800053b4:	17a080e7          	jalr	378(ra) # 8000052a <panic>

00000000800053b8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800053b8:	7139                	addi	sp,sp,-64
    800053ba:	fc06                	sd	ra,56(sp)
    800053bc:	f822                	sd	s0,48(sp)
    800053be:	f426                	sd	s1,40(sp)
    800053c0:	f04a                	sd	s2,32(sp)
    800053c2:	ec4e                	sd	s3,24(sp)
    800053c4:	e852                	sd	s4,16(sp)
    800053c6:	e456                	sd	s5,8(sp)
    800053c8:	0080                	addi	s0,sp,64
    800053ca:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800053cc:	00026517          	auipc	a0,0x26
    800053d0:	7ec50513          	addi	a0,a0,2028 # 8002bbb8 <ftable>
    800053d4:	ffffb097          	auipc	ra,0xffffb
    800053d8:	7ee080e7          	jalr	2030(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    800053dc:	40dc                	lw	a5,4(s1)
    800053de:	06f05163          	blez	a5,80005440 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800053e2:	37fd                	addiw	a5,a5,-1
    800053e4:	0007871b          	sext.w	a4,a5
    800053e8:	c0dc                	sw	a5,4(s1)
    800053ea:	06e04363          	bgtz	a4,80005450 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800053ee:	0004a903          	lw	s2,0(s1)
    800053f2:	0094ca83          	lbu	s5,9(s1)
    800053f6:	0104ba03          	ld	s4,16(s1)
    800053fa:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800053fe:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005402:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005406:	00026517          	auipc	a0,0x26
    8000540a:	7b250513          	addi	a0,a0,1970 # 8002bbb8 <ftable>
    8000540e:	ffffc097          	auipc	ra,0xffffc
    80005412:	868080e7          	jalr	-1944(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    80005416:	4785                	li	a5,1
    80005418:	04f90d63          	beq	s2,a5,80005472 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000541c:	3979                	addiw	s2,s2,-2
    8000541e:	4785                	li	a5,1
    80005420:	0527e063          	bltu	a5,s2,80005460 <fileclose+0xa8>
    begin_op();
    80005424:	00000097          	auipc	ra,0x0
    80005428:	ac8080e7          	jalr	-1336(ra) # 80004eec <begin_op>
    iput(ff.ip);
    8000542c:	854e                	mv	a0,s3
    8000542e:	fffff097          	auipc	ra,0xfffff
    80005432:	f80080e7          	jalr	-128(ra) # 800043ae <iput>
    end_op();
    80005436:	00000097          	auipc	ra,0x0
    8000543a:	b36080e7          	jalr	-1226(ra) # 80004f6c <end_op>
    8000543e:	a00d                	j	80005460 <fileclose+0xa8>
    panic("fileclose");
    80005440:	00005517          	auipc	a0,0x5
    80005444:	a6850513          	addi	a0,a0,-1432 # 80009ea8 <syscalls+0x2d0>
    80005448:	ffffb097          	auipc	ra,0xffffb
    8000544c:	0e2080e7          	jalr	226(ra) # 8000052a <panic>
    release(&ftable.lock);
    80005450:	00026517          	auipc	a0,0x26
    80005454:	76850513          	addi	a0,a0,1896 # 8002bbb8 <ftable>
    80005458:	ffffc097          	auipc	ra,0xffffc
    8000545c:	81e080e7          	jalr	-2018(ra) # 80000c76 <release>
  }
}
    80005460:	70e2                	ld	ra,56(sp)
    80005462:	7442                	ld	s0,48(sp)
    80005464:	74a2                	ld	s1,40(sp)
    80005466:	7902                	ld	s2,32(sp)
    80005468:	69e2                	ld	s3,24(sp)
    8000546a:	6a42                	ld	s4,16(sp)
    8000546c:	6aa2                	ld	s5,8(sp)
    8000546e:	6121                	addi	sp,sp,64
    80005470:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005472:	85d6                	mv	a1,s5
    80005474:	8552                	mv	a0,s4
    80005476:	00000097          	auipc	ra,0x0
    8000547a:	542080e7          	jalr	1346(ra) # 800059b8 <pipeclose>
    8000547e:	b7cd                	j	80005460 <fileclose+0xa8>

0000000080005480 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005480:	715d                	addi	sp,sp,-80
    80005482:	e486                	sd	ra,72(sp)
    80005484:	e0a2                	sd	s0,64(sp)
    80005486:	fc26                	sd	s1,56(sp)
    80005488:	f84a                	sd	s2,48(sp)
    8000548a:	f44e                	sd	s3,40(sp)
    8000548c:	0880                	addi	s0,sp,80
    8000548e:	84aa                	mv	s1,a0
    80005490:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005492:	ffffd097          	auipc	ra,0xffffd
    80005496:	a02080e7          	jalr	-1534(ra) # 80001e94 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000549a:	409c                	lw	a5,0(s1)
    8000549c:	37f9                	addiw	a5,a5,-2
    8000549e:	4705                	li	a4,1
    800054a0:	04f76763          	bltu	a4,a5,800054ee <filestat+0x6e>
    800054a4:	892a                	mv	s2,a0
    ilock(f->ip);
    800054a6:	6c88                	ld	a0,24(s1)
    800054a8:	fffff097          	auipc	ra,0xfffff
    800054ac:	d4c080e7          	jalr	-692(ra) # 800041f4 <ilock>
    stati(f->ip, &st);
    800054b0:	fb840593          	addi	a1,s0,-72
    800054b4:	6c88                	ld	a0,24(s1)
    800054b6:	fffff097          	auipc	ra,0xfffff
    800054ba:	fc8080e7          	jalr	-56(ra) # 8000447e <stati>
    iunlock(f->ip);
    800054be:	6c88                	ld	a0,24(s1)
    800054c0:	fffff097          	auipc	ra,0xfffff
    800054c4:	df6080e7          	jalr	-522(ra) # 800042b6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800054c8:	46e1                	li	a3,24
    800054ca:	fb840613          	addi	a2,s0,-72
    800054ce:	85ce                	mv	a1,s3
    800054d0:	05093503          	ld	a0,80(s2)
    800054d4:	ffffc097          	auipc	ra,0xffffc
    800054d8:	ee0080e7          	jalr	-288(ra) # 800013b4 <copyout>
    800054dc:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800054e0:	60a6                	ld	ra,72(sp)
    800054e2:	6406                	ld	s0,64(sp)
    800054e4:	74e2                	ld	s1,56(sp)
    800054e6:	7942                	ld	s2,48(sp)
    800054e8:	79a2                	ld	s3,40(sp)
    800054ea:	6161                	addi	sp,sp,80
    800054ec:	8082                	ret
  return -1;
    800054ee:	557d                	li	a0,-1
    800054f0:	bfc5                	j	800054e0 <filestat+0x60>

00000000800054f2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800054f2:	7179                	addi	sp,sp,-48
    800054f4:	f406                	sd	ra,40(sp)
    800054f6:	f022                	sd	s0,32(sp)
    800054f8:	ec26                	sd	s1,24(sp)
    800054fa:	e84a                	sd	s2,16(sp)
    800054fc:	e44e                	sd	s3,8(sp)
    800054fe:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005500:	00854783          	lbu	a5,8(a0)
    80005504:	c3d5                	beqz	a5,800055a8 <fileread+0xb6>
    80005506:	84aa                	mv	s1,a0
    80005508:	89ae                	mv	s3,a1
    8000550a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000550c:	411c                	lw	a5,0(a0)
    8000550e:	4705                	li	a4,1
    80005510:	04e78963          	beq	a5,a4,80005562 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005514:	470d                	li	a4,3
    80005516:	04e78d63          	beq	a5,a4,80005570 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000551a:	4709                	li	a4,2
    8000551c:	06e79e63          	bne	a5,a4,80005598 <fileread+0xa6>
    ilock(f->ip);
    80005520:	6d08                	ld	a0,24(a0)
    80005522:	fffff097          	auipc	ra,0xfffff
    80005526:	cd2080e7          	jalr	-814(ra) # 800041f4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000552a:	874a                	mv	a4,s2
    8000552c:	5094                	lw	a3,32(s1)
    8000552e:	864e                	mv	a2,s3
    80005530:	4585                	li	a1,1
    80005532:	6c88                	ld	a0,24(s1)
    80005534:	fffff097          	auipc	ra,0xfffff
    80005538:	f74080e7          	jalr	-140(ra) # 800044a8 <readi>
    8000553c:	892a                	mv	s2,a0
    8000553e:	00a05563          	blez	a0,80005548 <fileread+0x56>
      f->off += r;
    80005542:	509c                	lw	a5,32(s1)
    80005544:	9fa9                	addw	a5,a5,a0
    80005546:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005548:	6c88                	ld	a0,24(s1)
    8000554a:	fffff097          	auipc	ra,0xfffff
    8000554e:	d6c080e7          	jalr	-660(ra) # 800042b6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005552:	854a                	mv	a0,s2
    80005554:	70a2                	ld	ra,40(sp)
    80005556:	7402                	ld	s0,32(sp)
    80005558:	64e2                	ld	s1,24(sp)
    8000555a:	6942                	ld	s2,16(sp)
    8000555c:	69a2                	ld	s3,8(sp)
    8000555e:	6145                	addi	sp,sp,48
    80005560:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005562:	6908                	ld	a0,16(a0)
    80005564:	00000097          	auipc	ra,0x0
    80005568:	5b6080e7          	jalr	1462(ra) # 80005b1a <piperead>
    8000556c:	892a                	mv	s2,a0
    8000556e:	b7d5                	j	80005552 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005570:	02451783          	lh	a5,36(a0)
    80005574:	03079693          	slli	a3,a5,0x30
    80005578:	92c1                	srli	a3,a3,0x30
    8000557a:	4725                	li	a4,9
    8000557c:	02d76863          	bltu	a4,a3,800055ac <fileread+0xba>
    80005580:	0792                	slli	a5,a5,0x4
    80005582:	00026717          	auipc	a4,0x26
    80005586:	59670713          	addi	a4,a4,1430 # 8002bb18 <devsw>
    8000558a:	97ba                	add	a5,a5,a4
    8000558c:	639c                	ld	a5,0(a5)
    8000558e:	c38d                	beqz	a5,800055b0 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005590:	4505                	li	a0,1
    80005592:	9782                	jalr	a5
    80005594:	892a                	mv	s2,a0
    80005596:	bf75                	j	80005552 <fileread+0x60>
    panic("fileread");
    80005598:	00005517          	auipc	a0,0x5
    8000559c:	92050513          	addi	a0,a0,-1760 # 80009eb8 <syscalls+0x2e0>
    800055a0:	ffffb097          	auipc	ra,0xffffb
    800055a4:	f8a080e7          	jalr	-118(ra) # 8000052a <panic>
    return -1;
    800055a8:	597d                	li	s2,-1
    800055aa:	b765                	j	80005552 <fileread+0x60>
      return -1;
    800055ac:	597d                	li	s2,-1
    800055ae:	b755                	j	80005552 <fileread+0x60>
    800055b0:	597d                	li	s2,-1
    800055b2:	b745                	j	80005552 <fileread+0x60>

00000000800055b4 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800055b4:	715d                	addi	sp,sp,-80
    800055b6:	e486                	sd	ra,72(sp)
    800055b8:	e0a2                	sd	s0,64(sp)
    800055ba:	fc26                	sd	s1,56(sp)
    800055bc:	f84a                	sd	s2,48(sp)
    800055be:	f44e                	sd	s3,40(sp)
    800055c0:	f052                	sd	s4,32(sp)
    800055c2:	ec56                	sd	s5,24(sp)
    800055c4:	e85a                	sd	s6,16(sp)
    800055c6:	e45e                	sd	s7,8(sp)
    800055c8:	e062                	sd	s8,0(sp)
    800055ca:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800055cc:	00954783          	lbu	a5,9(a0)
    800055d0:	10078663          	beqz	a5,800056dc <filewrite+0x128>
    800055d4:	892a                	mv	s2,a0
    800055d6:	8aae                	mv	s5,a1
    800055d8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800055da:	411c                	lw	a5,0(a0)
    800055dc:	4705                	li	a4,1
    800055de:	02e78263          	beq	a5,a4,80005602 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800055e2:	470d                	li	a4,3
    800055e4:	02e78663          	beq	a5,a4,80005610 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800055e8:	4709                	li	a4,2
    800055ea:	0ee79163          	bne	a5,a4,800056cc <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800055ee:	0ac05d63          	blez	a2,800056a8 <filewrite+0xf4>
    int i = 0;
    800055f2:	4981                	li	s3,0
    800055f4:	6b05                	lui	s6,0x1
    800055f6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800055fa:	6b85                	lui	s7,0x1
    800055fc:	c00b8b9b          	addiw	s7,s7,-1024
    80005600:	a861                	j	80005698 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005602:	6908                	ld	a0,16(a0)
    80005604:	00000097          	auipc	ra,0x0
    80005608:	424080e7          	jalr	1060(ra) # 80005a28 <pipewrite>
    8000560c:	8a2a                	mv	s4,a0
    8000560e:	a045                	j	800056ae <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005610:	02451783          	lh	a5,36(a0)
    80005614:	03079693          	slli	a3,a5,0x30
    80005618:	92c1                	srli	a3,a3,0x30
    8000561a:	4725                	li	a4,9
    8000561c:	0cd76263          	bltu	a4,a3,800056e0 <filewrite+0x12c>
    80005620:	0792                	slli	a5,a5,0x4
    80005622:	00026717          	auipc	a4,0x26
    80005626:	4f670713          	addi	a4,a4,1270 # 8002bb18 <devsw>
    8000562a:	97ba                	add	a5,a5,a4
    8000562c:	679c                	ld	a5,8(a5)
    8000562e:	cbdd                	beqz	a5,800056e4 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005630:	4505                	li	a0,1
    80005632:	9782                	jalr	a5
    80005634:	8a2a                	mv	s4,a0
    80005636:	a8a5                	j	800056ae <filewrite+0xfa>
    80005638:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000563c:	00000097          	auipc	ra,0x0
    80005640:	8b0080e7          	jalr	-1872(ra) # 80004eec <begin_op>
      ilock(f->ip);
    80005644:	01893503          	ld	a0,24(s2)
    80005648:	fffff097          	auipc	ra,0xfffff
    8000564c:	bac080e7          	jalr	-1108(ra) # 800041f4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005650:	8762                	mv	a4,s8
    80005652:	02092683          	lw	a3,32(s2)
    80005656:	01598633          	add	a2,s3,s5
    8000565a:	4585                	li	a1,1
    8000565c:	01893503          	ld	a0,24(s2)
    80005660:	fffff097          	auipc	ra,0xfffff
    80005664:	f40080e7          	jalr	-192(ra) # 800045a0 <writei>
    80005668:	84aa                	mv	s1,a0
    8000566a:	00a05763          	blez	a0,80005678 <filewrite+0xc4>
        f->off += r;
    8000566e:	02092783          	lw	a5,32(s2)
    80005672:	9fa9                	addw	a5,a5,a0
    80005674:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005678:	01893503          	ld	a0,24(s2)
    8000567c:	fffff097          	auipc	ra,0xfffff
    80005680:	c3a080e7          	jalr	-966(ra) # 800042b6 <iunlock>
      end_op();
    80005684:	00000097          	auipc	ra,0x0
    80005688:	8e8080e7          	jalr	-1816(ra) # 80004f6c <end_op>

      if(r != n1){
    8000568c:	009c1f63          	bne	s8,s1,800056aa <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005690:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005694:	0149db63          	bge	s3,s4,800056aa <filewrite+0xf6>
      int n1 = n - i;
    80005698:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000569c:	84be                	mv	s1,a5
    8000569e:	2781                	sext.w	a5,a5
    800056a0:	f8fb5ce3          	bge	s6,a5,80005638 <filewrite+0x84>
    800056a4:	84de                	mv	s1,s7
    800056a6:	bf49                	j	80005638 <filewrite+0x84>
    int i = 0;
    800056a8:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800056aa:	013a1f63          	bne	s4,s3,800056c8 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800056ae:	8552                	mv	a0,s4
    800056b0:	60a6                	ld	ra,72(sp)
    800056b2:	6406                	ld	s0,64(sp)
    800056b4:	74e2                	ld	s1,56(sp)
    800056b6:	7942                	ld	s2,48(sp)
    800056b8:	79a2                	ld	s3,40(sp)
    800056ba:	7a02                	ld	s4,32(sp)
    800056bc:	6ae2                	ld	s5,24(sp)
    800056be:	6b42                	ld	s6,16(sp)
    800056c0:	6ba2                	ld	s7,8(sp)
    800056c2:	6c02                	ld	s8,0(sp)
    800056c4:	6161                	addi	sp,sp,80
    800056c6:	8082                	ret
    ret = (i == n ? n : -1);
    800056c8:	5a7d                	li	s4,-1
    800056ca:	b7d5                	j	800056ae <filewrite+0xfa>
    panic("filewrite");
    800056cc:	00004517          	auipc	a0,0x4
    800056d0:	7fc50513          	addi	a0,a0,2044 # 80009ec8 <syscalls+0x2f0>
    800056d4:	ffffb097          	auipc	ra,0xffffb
    800056d8:	e56080e7          	jalr	-426(ra) # 8000052a <panic>
    return -1;
    800056dc:	5a7d                	li	s4,-1
    800056de:	bfc1                	j	800056ae <filewrite+0xfa>
      return -1;
    800056e0:	5a7d                	li	s4,-1
    800056e2:	b7f1                	j	800056ae <filewrite+0xfa>
    800056e4:	5a7d                	li	s4,-1
    800056e6:	b7e1                	j	800056ae <filewrite+0xfa>

00000000800056e8 <kfileread>:

// Read from file f.
// addr is a kernel virtual address.
int
kfileread(struct file *f, uint64 addr, int n)
{
    800056e8:	7179                	addi	sp,sp,-48
    800056ea:	f406                	sd	ra,40(sp)
    800056ec:	f022                	sd	s0,32(sp)
    800056ee:	ec26                	sd	s1,24(sp)
    800056f0:	e84a                	sd	s2,16(sp)
    800056f2:	e44e                	sd	s3,8(sp)
    800056f4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800056f6:	00854783          	lbu	a5,8(a0)
    800056fa:	c3d5                	beqz	a5,8000579e <kfileread+0xb6>
    800056fc:	84aa                	mv	s1,a0
    800056fe:	89ae                	mv	s3,a1
    80005700:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005702:	411c                	lw	a5,0(a0)
    80005704:	4705                	li	a4,1
    80005706:	04e78963          	beq	a5,a4,80005758 <kfileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000570a:	470d                	li	a4,3
    8000570c:	04e78d63          	beq	a5,a4,80005766 <kfileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005710:	4709                	li	a4,2
    80005712:	06e79e63          	bne	a5,a4,8000578e <kfileread+0xa6>
    ilock(f->ip);
    80005716:	6d08                	ld	a0,24(a0)
    80005718:	fffff097          	auipc	ra,0xfffff
    8000571c:	adc080e7          	jalr	-1316(ra) # 800041f4 <ilock>
    if((r = readi(f->ip, 0, addr, f->off, n)) > 0)
    80005720:	874a                	mv	a4,s2
    80005722:	5094                	lw	a3,32(s1)
    80005724:	864e                	mv	a2,s3
    80005726:	4581                	li	a1,0
    80005728:	6c88                	ld	a0,24(s1)
    8000572a:	fffff097          	auipc	ra,0xfffff
    8000572e:	d7e080e7          	jalr	-642(ra) # 800044a8 <readi>
    80005732:	892a                	mv	s2,a0
    80005734:	00a05563          	blez	a0,8000573e <kfileread+0x56>
      f->off += r;
    80005738:	509c                	lw	a5,32(s1)
    8000573a:	9fa9                	addw	a5,a5,a0
    8000573c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000573e:	6c88                	ld	a0,24(s1)
    80005740:	fffff097          	auipc	ra,0xfffff
    80005744:	b76080e7          	jalr	-1162(ra) # 800042b6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005748:	854a                	mv	a0,s2
    8000574a:	70a2                	ld	ra,40(sp)
    8000574c:	7402                	ld	s0,32(sp)
    8000574e:	64e2                	ld	s1,24(sp)
    80005750:	6942                	ld	s2,16(sp)
    80005752:	69a2                	ld	s3,8(sp)
    80005754:	6145                	addi	sp,sp,48
    80005756:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005758:	6908                	ld	a0,16(a0)
    8000575a:	00000097          	auipc	ra,0x0
    8000575e:	3c0080e7          	jalr	960(ra) # 80005b1a <piperead>
    80005762:	892a                	mv	s2,a0
    80005764:	b7d5                	j	80005748 <kfileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005766:	02451783          	lh	a5,36(a0)
    8000576a:	03079693          	slli	a3,a5,0x30
    8000576e:	92c1                	srli	a3,a3,0x30
    80005770:	4725                	li	a4,9
    80005772:	02d76863          	bltu	a4,a3,800057a2 <kfileread+0xba>
    80005776:	0792                	slli	a5,a5,0x4
    80005778:	00026717          	auipc	a4,0x26
    8000577c:	3a070713          	addi	a4,a4,928 # 8002bb18 <devsw>
    80005780:	97ba                	add	a5,a5,a4
    80005782:	639c                	ld	a5,0(a5)
    80005784:	c38d                	beqz	a5,800057a6 <kfileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005786:	4505                	li	a0,1
    80005788:	9782                	jalr	a5
    8000578a:	892a                	mv	s2,a0
    8000578c:	bf75                	j	80005748 <kfileread+0x60>
    panic("fileread");
    8000578e:	00004517          	auipc	a0,0x4
    80005792:	72a50513          	addi	a0,a0,1834 # 80009eb8 <syscalls+0x2e0>
    80005796:	ffffb097          	auipc	ra,0xffffb
    8000579a:	d94080e7          	jalr	-620(ra) # 8000052a <panic>
    return -1;
    8000579e:	597d                	li	s2,-1
    800057a0:	b765                	j	80005748 <kfileread+0x60>
      return -1;
    800057a2:	597d                	li	s2,-1
    800057a4:	b755                	j	80005748 <kfileread+0x60>
    800057a6:	597d                	li	s2,-1
    800057a8:	b745                	j	80005748 <kfileread+0x60>

00000000800057aa <kfilewrite>:

// Write to file f.
// addr is a kernel virtual address.
int
kfilewrite(struct file *f, uint64 addr, int n)
{
    800057aa:	715d                	addi	sp,sp,-80
    800057ac:	e486                	sd	ra,72(sp)
    800057ae:	e0a2                	sd	s0,64(sp)
    800057b0:	fc26                	sd	s1,56(sp)
    800057b2:	f84a                	sd	s2,48(sp)
    800057b4:	f44e                	sd	s3,40(sp)
    800057b6:	f052                	sd	s4,32(sp)
    800057b8:	ec56                	sd	s5,24(sp)
    800057ba:	e85a                	sd	s6,16(sp)
    800057bc:	e45e                	sd	s7,8(sp)
    800057be:	e062                	sd	s8,0(sp)
    800057c0:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800057c2:	00954783          	lbu	a5,9(a0)
    800057c6:	10078663          	beqz	a5,800058d2 <kfilewrite+0x128>
    800057ca:	892a                	mv	s2,a0
    800057cc:	8aae                	mv	s5,a1
    800057ce:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800057d0:	411c                	lw	a5,0(a0)
    800057d2:	4705                	li	a4,1
    800057d4:	02e78263          	beq	a5,a4,800057f8 <kfilewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800057d8:	470d                	li	a4,3
    800057da:	02e78663          	beq	a5,a4,80005806 <kfilewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800057de:	4709                	li	a4,2
    800057e0:	0ee79163          	bne	a5,a4,800058c2 <kfilewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800057e4:	0ac05d63          	blez	a2,8000589e <kfilewrite+0xf4>
    int i = 0;
    800057e8:	4981                	li	s3,0
    800057ea:	6b05                	lui	s6,0x1
    800057ec:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800057f0:	6b85                	lui	s7,0x1
    800057f2:	c00b8b9b          	addiw	s7,s7,-1024
    800057f6:	a861                	j	8000588e <kfilewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800057f8:	6908                	ld	a0,16(a0)
    800057fa:	00000097          	auipc	ra,0x0
    800057fe:	22e080e7          	jalr	558(ra) # 80005a28 <pipewrite>
    80005802:	8a2a                	mv	s4,a0
    80005804:	a045                	j	800058a4 <kfilewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005806:	02451783          	lh	a5,36(a0)
    8000580a:	03079693          	slli	a3,a5,0x30
    8000580e:	92c1                	srli	a3,a3,0x30
    80005810:	4725                	li	a4,9
    80005812:	0cd76263          	bltu	a4,a3,800058d6 <kfilewrite+0x12c>
    80005816:	0792                	slli	a5,a5,0x4
    80005818:	00026717          	auipc	a4,0x26
    8000581c:	30070713          	addi	a4,a4,768 # 8002bb18 <devsw>
    80005820:	97ba                	add	a5,a5,a4
    80005822:	679c                	ld	a5,8(a5)
    80005824:	cbdd                	beqz	a5,800058da <kfilewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005826:	4505                	li	a0,1
    80005828:	9782                	jalr	a5
    8000582a:	8a2a                	mv	s4,a0
    8000582c:	a8a5                	j	800058a4 <kfilewrite+0xfa>
    8000582e:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005832:	fffff097          	auipc	ra,0xfffff
    80005836:	6ba080e7          	jalr	1722(ra) # 80004eec <begin_op>
      ilock(f->ip);
    8000583a:	01893503          	ld	a0,24(s2)
    8000583e:	fffff097          	auipc	ra,0xfffff
    80005842:	9b6080e7          	jalr	-1610(ra) # 800041f4 <ilock>
      if ((r = writei(f->ip, 0, addr + i, f->off, n1)) > 0)
    80005846:	8762                	mv	a4,s8
    80005848:	02092683          	lw	a3,32(s2)
    8000584c:	01598633          	add	a2,s3,s5
    80005850:	4581                	li	a1,0
    80005852:	01893503          	ld	a0,24(s2)
    80005856:	fffff097          	auipc	ra,0xfffff
    8000585a:	d4a080e7          	jalr	-694(ra) # 800045a0 <writei>
    8000585e:	84aa                	mv	s1,a0
    80005860:	00a05763          	blez	a0,8000586e <kfilewrite+0xc4>
        f->off += r;
    80005864:	02092783          	lw	a5,32(s2)
    80005868:	9fa9                	addw	a5,a5,a0
    8000586a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000586e:	01893503          	ld	a0,24(s2)
    80005872:	fffff097          	auipc	ra,0xfffff
    80005876:	a44080e7          	jalr	-1468(ra) # 800042b6 <iunlock>
      end_op();
    8000587a:	fffff097          	auipc	ra,0xfffff
    8000587e:	6f2080e7          	jalr	1778(ra) # 80004f6c <end_op>

      if(r != n1){
    80005882:	009c1f63          	bne	s8,s1,800058a0 <kfilewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005886:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000588a:	0149db63          	bge	s3,s4,800058a0 <kfilewrite+0xf6>
      int n1 = n - i;
    8000588e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005892:	84be                	mv	s1,a5
    80005894:	2781                	sext.w	a5,a5
    80005896:	f8fb5ce3          	bge	s6,a5,8000582e <kfilewrite+0x84>
    8000589a:	84de                	mv	s1,s7
    8000589c:	bf49                	j	8000582e <kfilewrite+0x84>
    int i = 0;
    8000589e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800058a0:	013a1f63          	bne	s4,s3,800058be <kfilewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
    800058a4:	8552                	mv	a0,s4
    800058a6:	60a6                	ld	ra,72(sp)
    800058a8:	6406                	ld	s0,64(sp)
    800058aa:	74e2                	ld	s1,56(sp)
    800058ac:	7942                	ld	s2,48(sp)
    800058ae:	79a2                	ld	s3,40(sp)
    800058b0:	7a02                	ld	s4,32(sp)
    800058b2:	6ae2                	ld	s5,24(sp)
    800058b4:	6b42                	ld	s6,16(sp)
    800058b6:	6ba2                	ld	s7,8(sp)
    800058b8:	6c02                	ld	s8,0(sp)
    800058ba:	6161                	addi	sp,sp,80
    800058bc:	8082                	ret
    ret = (i == n ? n : -1);
    800058be:	5a7d                	li	s4,-1
    800058c0:	b7d5                	j	800058a4 <kfilewrite+0xfa>
    panic("filewrite");
    800058c2:	00004517          	auipc	a0,0x4
    800058c6:	60650513          	addi	a0,a0,1542 # 80009ec8 <syscalls+0x2f0>
    800058ca:	ffffb097          	auipc	ra,0xffffb
    800058ce:	c60080e7          	jalr	-928(ra) # 8000052a <panic>
    return -1;
    800058d2:	5a7d                	li	s4,-1
    800058d4:	bfc1                	j	800058a4 <kfilewrite+0xfa>
      return -1;
    800058d6:	5a7d                	li	s4,-1
    800058d8:	b7f1                	j	800058a4 <kfilewrite+0xfa>
    800058da:	5a7d                	li	s4,-1
    800058dc:	b7e1                	j	800058a4 <kfilewrite+0xfa>

00000000800058de <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800058de:	7179                	addi	sp,sp,-48
    800058e0:	f406                	sd	ra,40(sp)
    800058e2:	f022                	sd	s0,32(sp)
    800058e4:	ec26                	sd	s1,24(sp)
    800058e6:	e84a                	sd	s2,16(sp)
    800058e8:	e44e                	sd	s3,8(sp)
    800058ea:	e052                	sd	s4,0(sp)
    800058ec:	1800                	addi	s0,sp,48
    800058ee:	84aa                	mv	s1,a0
    800058f0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800058f2:	0005b023          	sd	zero,0(a1)
    800058f6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800058fa:	00000097          	auipc	ra,0x0
    800058fe:	a02080e7          	jalr	-1534(ra) # 800052fc <filealloc>
    80005902:	e088                	sd	a0,0(s1)
    80005904:	c551                	beqz	a0,80005990 <pipealloc+0xb2>
    80005906:	00000097          	auipc	ra,0x0
    8000590a:	9f6080e7          	jalr	-1546(ra) # 800052fc <filealloc>
    8000590e:	00aa3023          	sd	a0,0(s4)
    80005912:	c92d                	beqz	a0,80005984 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005914:	ffffb097          	auipc	ra,0xffffb
    80005918:	1be080e7          	jalr	446(ra) # 80000ad2 <kalloc>
    8000591c:	892a                	mv	s2,a0
    8000591e:	c125                	beqz	a0,8000597e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005920:	4985                	li	s3,1
    80005922:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005926:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000592a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000592e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005932:	00004597          	auipc	a1,0x4
    80005936:	5a658593          	addi	a1,a1,1446 # 80009ed8 <syscalls+0x300>
    8000593a:	ffffb097          	auipc	ra,0xffffb
    8000593e:	1f8080e7          	jalr	504(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80005942:	609c                	ld	a5,0(s1)
    80005944:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005948:	609c                	ld	a5,0(s1)
    8000594a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000594e:	609c                	ld	a5,0(s1)
    80005950:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005954:	609c                	ld	a5,0(s1)
    80005956:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000595a:	000a3783          	ld	a5,0(s4)
    8000595e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005962:	000a3783          	ld	a5,0(s4)
    80005966:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000596a:	000a3783          	ld	a5,0(s4)
    8000596e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005972:	000a3783          	ld	a5,0(s4)
    80005976:	0127b823          	sd	s2,16(a5)
  return 0;
    8000597a:	4501                	li	a0,0
    8000597c:	a025                	j	800059a4 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000597e:	6088                	ld	a0,0(s1)
    80005980:	e501                	bnez	a0,80005988 <pipealloc+0xaa>
    80005982:	a039                	j	80005990 <pipealloc+0xb2>
    80005984:	6088                	ld	a0,0(s1)
    80005986:	c51d                	beqz	a0,800059b4 <pipealloc+0xd6>
    fileclose(*f0);
    80005988:	00000097          	auipc	ra,0x0
    8000598c:	a30080e7          	jalr	-1488(ra) # 800053b8 <fileclose>
  if(*f1)
    80005990:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005994:	557d                	li	a0,-1
  if(*f1)
    80005996:	c799                	beqz	a5,800059a4 <pipealloc+0xc6>
    fileclose(*f1);
    80005998:	853e                	mv	a0,a5
    8000599a:	00000097          	auipc	ra,0x0
    8000599e:	a1e080e7          	jalr	-1506(ra) # 800053b8 <fileclose>
  return -1;
    800059a2:	557d                	li	a0,-1
}
    800059a4:	70a2                	ld	ra,40(sp)
    800059a6:	7402                	ld	s0,32(sp)
    800059a8:	64e2                	ld	s1,24(sp)
    800059aa:	6942                	ld	s2,16(sp)
    800059ac:	69a2                	ld	s3,8(sp)
    800059ae:	6a02                	ld	s4,0(sp)
    800059b0:	6145                	addi	sp,sp,48
    800059b2:	8082                	ret
  return -1;
    800059b4:	557d                	li	a0,-1
    800059b6:	b7fd                	j	800059a4 <pipealloc+0xc6>

00000000800059b8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800059b8:	1101                	addi	sp,sp,-32
    800059ba:	ec06                	sd	ra,24(sp)
    800059bc:	e822                	sd	s0,16(sp)
    800059be:	e426                	sd	s1,8(sp)
    800059c0:	e04a                	sd	s2,0(sp)
    800059c2:	1000                	addi	s0,sp,32
    800059c4:	84aa                	mv	s1,a0
    800059c6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800059c8:	ffffb097          	auipc	ra,0xffffb
    800059cc:	1fa080e7          	jalr	506(ra) # 80000bc2 <acquire>
  if(writable){
    800059d0:	02090d63          	beqz	s2,80005a0a <pipeclose+0x52>
    pi->writeopen = 0;
    800059d4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800059d8:	21848513          	addi	a0,s1,536
    800059dc:	ffffd097          	auipc	ra,0xffffd
    800059e0:	be6080e7          	jalr	-1050(ra) # 800025c2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800059e4:	2204b783          	ld	a5,544(s1)
    800059e8:	eb95                	bnez	a5,80005a1c <pipeclose+0x64>
    release(&pi->lock);
    800059ea:	8526                	mv	a0,s1
    800059ec:	ffffb097          	auipc	ra,0xffffb
    800059f0:	28a080e7          	jalr	650(ra) # 80000c76 <release>
    kfree((char*)pi);
    800059f4:	8526                	mv	a0,s1
    800059f6:	ffffb097          	auipc	ra,0xffffb
    800059fa:	fe0080e7          	jalr	-32(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    800059fe:	60e2                	ld	ra,24(sp)
    80005a00:	6442                	ld	s0,16(sp)
    80005a02:	64a2                	ld	s1,8(sp)
    80005a04:	6902                	ld	s2,0(sp)
    80005a06:	6105                	addi	sp,sp,32
    80005a08:	8082                	ret
    pi->readopen = 0;
    80005a0a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005a0e:	21c48513          	addi	a0,s1,540
    80005a12:	ffffd097          	auipc	ra,0xffffd
    80005a16:	bb0080e7          	jalr	-1104(ra) # 800025c2 <wakeup>
    80005a1a:	b7e9                	j	800059e4 <pipeclose+0x2c>
    release(&pi->lock);
    80005a1c:	8526                	mv	a0,s1
    80005a1e:	ffffb097          	auipc	ra,0xffffb
    80005a22:	258080e7          	jalr	600(ra) # 80000c76 <release>
}
    80005a26:	bfe1                	j	800059fe <pipeclose+0x46>

0000000080005a28 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005a28:	711d                	addi	sp,sp,-96
    80005a2a:	ec86                	sd	ra,88(sp)
    80005a2c:	e8a2                	sd	s0,80(sp)
    80005a2e:	e4a6                	sd	s1,72(sp)
    80005a30:	e0ca                	sd	s2,64(sp)
    80005a32:	fc4e                	sd	s3,56(sp)
    80005a34:	f852                	sd	s4,48(sp)
    80005a36:	f456                	sd	s5,40(sp)
    80005a38:	f05a                	sd	s6,32(sp)
    80005a3a:	ec5e                	sd	s7,24(sp)
    80005a3c:	e862                	sd	s8,16(sp)
    80005a3e:	1080                	addi	s0,sp,96
    80005a40:	84aa                	mv	s1,a0
    80005a42:	8aae                	mv	s5,a1
    80005a44:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005a46:	ffffc097          	auipc	ra,0xffffc
    80005a4a:	44e080e7          	jalr	1102(ra) # 80001e94 <myproc>
    80005a4e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005a50:	8526                	mv	a0,s1
    80005a52:	ffffb097          	auipc	ra,0xffffb
    80005a56:	170080e7          	jalr	368(ra) # 80000bc2 <acquire>
  while(i < n){
    80005a5a:	0b405363          	blez	s4,80005b00 <pipewrite+0xd8>
  int i = 0;
    80005a5e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005a60:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005a62:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005a66:	21c48b93          	addi	s7,s1,540
    80005a6a:	a089                	j	80005aac <pipewrite+0x84>
      release(&pi->lock);
    80005a6c:	8526                	mv	a0,s1
    80005a6e:	ffffb097          	auipc	ra,0xffffb
    80005a72:	208080e7          	jalr	520(ra) # 80000c76 <release>
      return -1;
    80005a76:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005a78:	854a                	mv	a0,s2
    80005a7a:	60e6                	ld	ra,88(sp)
    80005a7c:	6446                	ld	s0,80(sp)
    80005a7e:	64a6                	ld	s1,72(sp)
    80005a80:	6906                	ld	s2,64(sp)
    80005a82:	79e2                	ld	s3,56(sp)
    80005a84:	7a42                	ld	s4,48(sp)
    80005a86:	7aa2                	ld	s5,40(sp)
    80005a88:	7b02                	ld	s6,32(sp)
    80005a8a:	6be2                	ld	s7,24(sp)
    80005a8c:	6c42                	ld	s8,16(sp)
    80005a8e:	6125                	addi	sp,sp,96
    80005a90:	8082                	ret
      wakeup(&pi->nread);
    80005a92:	8562                	mv	a0,s8
    80005a94:	ffffd097          	auipc	ra,0xffffd
    80005a98:	b2e080e7          	jalr	-1234(ra) # 800025c2 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005a9c:	85a6                	mv	a1,s1
    80005a9e:	855e                	mv	a0,s7
    80005aa0:	ffffd097          	auipc	ra,0xffffd
    80005aa4:	996080e7          	jalr	-1642(ra) # 80002436 <sleep>
  while(i < n){
    80005aa8:	05495d63          	bge	s2,s4,80005b02 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80005aac:	2204a783          	lw	a5,544(s1)
    80005ab0:	dfd5                	beqz	a5,80005a6c <pipewrite+0x44>
    80005ab2:	0289a783          	lw	a5,40(s3)
    80005ab6:	fbdd                	bnez	a5,80005a6c <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005ab8:	2184a783          	lw	a5,536(s1)
    80005abc:	21c4a703          	lw	a4,540(s1)
    80005ac0:	2007879b          	addiw	a5,a5,512
    80005ac4:	fcf707e3          	beq	a4,a5,80005a92 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005ac8:	4685                	li	a3,1
    80005aca:	01590633          	add	a2,s2,s5
    80005ace:	faf40593          	addi	a1,s0,-81
    80005ad2:	0509b503          	ld	a0,80(s3)
    80005ad6:	ffffc097          	auipc	ra,0xffffc
    80005ada:	9a2080e7          	jalr	-1630(ra) # 80001478 <copyin>
    80005ade:	03650263          	beq	a0,s6,80005b02 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005ae2:	21c4a783          	lw	a5,540(s1)
    80005ae6:	0017871b          	addiw	a4,a5,1
    80005aea:	20e4ae23          	sw	a4,540(s1)
    80005aee:	1ff7f793          	andi	a5,a5,511
    80005af2:	97a6                	add	a5,a5,s1
    80005af4:	faf44703          	lbu	a4,-81(s0)
    80005af8:	00e78c23          	sb	a4,24(a5)
      i++;
    80005afc:	2905                	addiw	s2,s2,1
    80005afe:	b76d                	j	80005aa8 <pipewrite+0x80>
  int i = 0;
    80005b00:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005b02:	21848513          	addi	a0,s1,536
    80005b06:	ffffd097          	auipc	ra,0xffffd
    80005b0a:	abc080e7          	jalr	-1348(ra) # 800025c2 <wakeup>
  release(&pi->lock);
    80005b0e:	8526                	mv	a0,s1
    80005b10:	ffffb097          	auipc	ra,0xffffb
    80005b14:	166080e7          	jalr	358(ra) # 80000c76 <release>
  return i;
    80005b18:	b785                	j	80005a78 <pipewrite+0x50>

0000000080005b1a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005b1a:	715d                	addi	sp,sp,-80
    80005b1c:	e486                	sd	ra,72(sp)
    80005b1e:	e0a2                	sd	s0,64(sp)
    80005b20:	fc26                	sd	s1,56(sp)
    80005b22:	f84a                	sd	s2,48(sp)
    80005b24:	f44e                	sd	s3,40(sp)
    80005b26:	f052                	sd	s4,32(sp)
    80005b28:	ec56                	sd	s5,24(sp)
    80005b2a:	e85a                	sd	s6,16(sp)
    80005b2c:	0880                	addi	s0,sp,80
    80005b2e:	84aa                	mv	s1,a0
    80005b30:	892e                	mv	s2,a1
    80005b32:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005b34:	ffffc097          	auipc	ra,0xffffc
    80005b38:	360080e7          	jalr	864(ra) # 80001e94 <myproc>
    80005b3c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005b3e:	8526                	mv	a0,s1
    80005b40:	ffffb097          	auipc	ra,0xffffb
    80005b44:	082080e7          	jalr	130(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005b48:	2184a703          	lw	a4,536(s1)
    80005b4c:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005b50:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005b54:	02f71463          	bne	a4,a5,80005b7c <piperead+0x62>
    80005b58:	2244a783          	lw	a5,548(s1)
    80005b5c:	c385                	beqz	a5,80005b7c <piperead+0x62>
    if(pr->killed){
    80005b5e:	028a2783          	lw	a5,40(s4)
    80005b62:	ebc1                	bnez	a5,80005bf2 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005b64:	85a6                	mv	a1,s1
    80005b66:	854e                	mv	a0,s3
    80005b68:	ffffd097          	auipc	ra,0xffffd
    80005b6c:	8ce080e7          	jalr	-1842(ra) # 80002436 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005b70:	2184a703          	lw	a4,536(s1)
    80005b74:	21c4a783          	lw	a5,540(s1)
    80005b78:	fef700e3          	beq	a4,a5,80005b58 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005b7c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005b7e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005b80:	05505363          	blez	s5,80005bc6 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80005b84:	2184a783          	lw	a5,536(s1)
    80005b88:	21c4a703          	lw	a4,540(s1)
    80005b8c:	02f70d63          	beq	a4,a5,80005bc6 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005b90:	0017871b          	addiw	a4,a5,1
    80005b94:	20e4ac23          	sw	a4,536(s1)
    80005b98:	1ff7f793          	andi	a5,a5,511
    80005b9c:	97a6                	add	a5,a5,s1
    80005b9e:	0187c783          	lbu	a5,24(a5)
    80005ba2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005ba6:	4685                	li	a3,1
    80005ba8:	fbf40613          	addi	a2,s0,-65
    80005bac:	85ca                	mv	a1,s2
    80005bae:	050a3503          	ld	a0,80(s4)
    80005bb2:	ffffc097          	auipc	ra,0xffffc
    80005bb6:	802080e7          	jalr	-2046(ra) # 800013b4 <copyout>
    80005bba:	01650663          	beq	a0,s6,80005bc6 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005bbe:	2985                	addiw	s3,s3,1
    80005bc0:	0905                	addi	s2,s2,1
    80005bc2:	fd3a91e3          	bne	s5,s3,80005b84 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005bc6:	21c48513          	addi	a0,s1,540
    80005bca:	ffffd097          	auipc	ra,0xffffd
    80005bce:	9f8080e7          	jalr	-1544(ra) # 800025c2 <wakeup>
  release(&pi->lock);
    80005bd2:	8526                	mv	a0,s1
    80005bd4:	ffffb097          	auipc	ra,0xffffb
    80005bd8:	0a2080e7          	jalr	162(ra) # 80000c76 <release>
  return i;
}
    80005bdc:	854e                	mv	a0,s3
    80005bde:	60a6                	ld	ra,72(sp)
    80005be0:	6406                	ld	s0,64(sp)
    80005be2:	74e2                	ld	s1,56(sp)
    80005be4:	7942                	ld	s2,48(sp)
    80005be6:	79a2                	ld	s3,40(sp)
    80005be8:	7a02                	ld	s4,32(sp)
    80005bea:	6ae2                	ld	s5,24(sp)
    80005bec:	6b42                	ld	s6,16(sp)
    80005bee:	6161                	addi	sp,sp,80
    80005bf0:	8082                	ret
      release(&pi->lock);
    80005bf2:	8526                	mv	a0,s1
    80005bf4:	ffffb097          	auipc	ra,0xffffb
    80005bf8:	082080e7          	jalr	130(ra) # 80000c76 <release>
      return -1;
    80005bfc:	59fd                	li	s3,-1
    80005bfe:	bff9                	j	80005bdc <piperead+0xc2>

0000000080005c00 <exec>:
#include "elf.h"

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int exec(char *path, char **argv)
{
    80005c00:	de010113          	addi	sp,sp,-544
    80005c04:	20113c23          	sd	ra,536(sp)
    80005c08:	20813823          	sd	s0,528(sp)
    80005c0c:	20913423          	sd	s1,520(sp)
    80005c10:	21213023          	sd	s2,512(sp)
    80005c14:	ffce                	sd	s3,504(sp)
    80005c16:	fbd2                	sd	s4,496(sp)
    80005c18:	f7d6                	sd	s5,488(sp)
    80005c1a:	f3da                	sd	s6,480(sp)
    80005c1c:	efde                	sd	s7,472(sp)
    80005c1e:	ebe2                	sd	s8,464(sp)
    80005c20:	e7e6                	sd	s9,456(sp)
    80005c22:	e3ea                	sd	s10,448(sp)
    80005c24:	ff6e                	sd	s11,440(sp)
    80005c26:	1400                	addi	s0,sp,544
    80005c28:	892a                	mv	s2,a0
    80005c2a:	dea43423          	sd	a0,-536(s0)
    80005c2e:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005c32:	ffffc097          	auipc	ra,0xffffc
    80005c36:	262080e7          	jalr	610(ra) # 80001e94 <myproc>
    80005c3a:	84aa                	mv	s1,a0

  begin_op();
    80005c3c:	fffff097          	auipc	ra,0xfffff
    80005c40:	2b0080e7          	jalr	688(ra) # 80004eec <begin_op>

  if ((ip = namei(path)) == 0)
    80005c44:	854a                	mv	a0,s2
    80005c46:	fffff097          	auipc	ra,0xfffff
    80005c4a:	d64080e7          	jalr	-668(ra) # 800049aa <namei>
    80005c4e:	c93d                	beqz	a0,80005cc4 <exec+0xc4>
    80005c50:	8aaa                	mv	s5,a0
  {
    end_op();
    return -1;
  }
  ilock(ip);
    80005c52:	ffffe097          	auipc	ra,0xffffe
    80005c56:	5a2080e7          	jalr	1442(ra) # 800041f4 <ilock>

  // Check ELF header
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005c5a:	04000713          	li	a4,64
    80005c5e:	4681                	li	a3,0
    80005c60:	e4840613          	addi	a2,s0,-440
    80005c64:	4581                	li	a1,0
    80005c66:	8556                	mv	a0,s5
    80005c68:	fffff097          	auipc	ra,0xfffff
    80005c6c:	840080e7          	jalr	-1984(ra) # 800044a8 <readi>
    80005c70:	04000793          	li	a5,64
    80005c74:	00f51a63          	bne	a0,a5,80005c88 <exec+0x88>
    goto bad;
  if (elf.magic != ELF_MAGIC)
    80005c78:	e4842703          	lw	a4,-440(s0)
    80005c7c:	464c47b7          	lui	a5,0x464c4
    80005c80:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005c84:	04f70663          	beq	a4,a5,80005cd0 <exec+0xd0>
bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip)
  {
    iunlockput(ip);
    80005c88:	8556                	mv	a0,s5
    80005c8a:	ffffe097          	auipc	ra,0xffffe
    80005c8e:	7cc080e7          	jalr	1996(ra) # 80004456 <iunlockput>
    end_op();
    80005c92:	fffff097          	auipc	ra,0xfffff
    80005c96:	2da080e7          	jalr	730(ra) # 80004f6c <end_op>
  }
  return -1;
    80005c9a:	557d                	li	a0,-1
}
    80005c9c:	21813083          	ld	ra,536(sp)
    80005ca0:	21013403          	ld	s0,528(sp)
    80005ca4:	20813483          	ld	s1,520(sp)
    80005ca8:	20013903          	ld	s2,512(sp)
    80005cac:	79fe                	ld	s3,504(sp)
    80005cae:	7a5e                	ld	s4,496(sp)
    80005cb0:	7abe                	ld	s5,488(sp)
    80005cb2:	7b1e                	ld	s6,480(sp)
    80005cb4:	6bfe                	ld	s7,472(sp)
    80005cb6:	6c5e                	ld	s8,464(sp)
    80005cb8:	6cbe                	ld	s9,456(sp)
    80005cba:	6d1e                	ld	s10,448(sp)
    80005cbc:	7dfa                	ld	s11,440(sp)
    80005cbe:	22010113          	addi	sp,sp,544
    80005cc2:	8082                	ret
    end_op();
    80005cc4:	fffff097          	auipc	ra,0xfffff
    80005cc8:	2a8080e7          	jalr	680(ra) # 80004f6c <end_op>
    return -1;
    80005ccc:	557d                	li	a0,-1
    80005cce:	b7f9                	j	80005c9c <exec+0x9c>
  if ((pagetable = proc_pagetable(p)) == 0)
    80005cd0:	8526                	mv	a0,s1
    80005cd2:	ffffc097          	auipc	ra,0xffffc
    80005cd6:	286080e7          	jalr	646(ra) # 80001f58 <proc_pagetable>
    80005cda:	8b2a                	mv	s6,a0
    80005cdc:	d555                	beqz	a0,80005c88 <exec+0x88>
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005cde:	e6842783          	lw	a5,-408(s0)
    80005ce2:	e8045703          	lhu	a4,-384(s0)
    80005ce6:	c73d                	beqz	a4,80005d54 <exec+0x154>
  uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
    80005ce8:	4481                	li	s1,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005cea:	e0043423          	sd	zero,-504(s0)
    if (ph.vaddr % PGSIZE != 0)
    80005cee:	6a05                	lui	s4,0x1
    80005cf0:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005cf4:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if ((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for (i = 0; i < sz; i += PGSIZE)
    80005cf8:	6d85                	lui	s11,0x1
    80005cfa:	7d7d                	lui	s10,0xfffff
    80005cfc:	ac61                	j	80005f94 <exec+0x394>
  {
    pa = walkaddr(pagetable, va + i, 0);
    if (pa == 0)
      panic("loadseg: address should exist");
    80005cfe:	00004517          	auipc	a0,0x4
    80005d02:	1e250513          	addi	a0,a0,482 # 80009ee0 <syscalls+0x308>
    80005d06:	ffffb097          	auipc	ra,0xffffb
    80005d0a:	824080e7          	jalr	-2012(ra) # 8000052a <panic>
    if (sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80005d0e:	874a                	mv	a4,s2
    80005d10:	009c86bb          	addw	a3,s9,s1
    80005d14:	4581                	li	a1,0
    80005d16:	8556                	mv	a0,s5
    80005d18:	ffffe097          	auipc	ra,0xffffe
    80005d1c:	790080e7          	jalr	1936(ra) # 800044a8 <readi>
    80005d20:	2501                	sext.w	a0,a0
    80005d22:	20a91963          	bne	s2,a0,80005f34 <exec+0x334>
  for (i = 0; i < sz; i += PGSIZE)
    80005d26:	009d84bb          	addw	s1,s11,s1
    80005d2a:	013d09bb          	addw	s3,s10,s3
    80005d2e:	2574f363          	bgeu	s1,s7,80005f74 <exec+0x374>
    pa = walkaddr(pagetable, va + i, 0);
    80005d32:	02049593          	slli	a1,s1,0x20
    80005d36:	9181                	srli	a1,a1,0x20
    80005d38:	4601                	li	a2,0
    80005d3a:	95e2                	add	a1,a1,s8
    80005d3c:	855a                	mv	a0,s6
    80005d3e:	ffffb097          	auipc	ra,0xffffb
    80005d42:	30e080e7          	jalr	782(ra) # 8000104c <walkaddr>
    80005d46:	862a                	mv	a2,a0
    if (pa == 0)
    80005d48:	d95d                	beqz	a0,80005cfe <exec+0xfe>
      n = PGSIZE;
    80005d4a:	8952                	mv	s2,s4
    if (sz - i < PGSIZE)
    80005d4c:	fd49f1e3          	bgeu	s3,s4,80005d0e <exec+0x10e>
      n = sz - i;
    80005d50:	894e                	mv	s2,s3
    80005d52:	bf75                	j	80005d0e <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
    80005d54:	4481                	li	s1,0
  iunlockput(ip);
    80005d56:	8556                	mv	a0,s5
    80005d58:	ffffe097          	auipc	ra,0xffffe
    80005d5c:	6fe080e7          	jalr	1790(ra) # 80004456 <iunlockput>
  end_op();
    80005d60:	fffff097          	auipc	ra,0xfffff
    80005d64:	20c080e7          	jalr	524(ra) # 80004f6c <end_op>
  p = myproc();
    80005d68:	ffffc097          	auipc	ra,0xffffc
    80005d6c:	12c080e7          	jalr	300(ra) # 80001e94 <myproc>
    80005d70:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005d72:	04853d83          	ld	s11,72(a0)
  sz = PGROUNDUP(sz);
    80005d76:	6785                	lui	a5,0x1
    80005d78:	17fd                	addi	a5,a5,-1
    80005d7a:	94be                	add	s1,s1,a5
    80005d7c:	77fd                	lui	a5,0xfffff
    80005d7e:	8fe5                	and	a5,a5,s1
    80005d80:	def43c23          	sd	a5,-520(s0)
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE)) == 0)
    80005d84:	6609                	lui	a2,0x2
    80005d86:	963e                	add	a2,a2,a5
    80005d88:	85be                	mv	a1,a5
    80005d8a:	855a                	mv	a0,s6
    80005d8c:	ffffc097          	auipc	ra,0xffffc
    80005d90:	c7a080e7          	jalr	-902(ra) # 80001a06 <uvmalloc>
    80005d94:	8d2a                	mv	s10,a0
  ip = 0;
    80005d96:	4a81                	li	s5,0
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE)) == 0)
    80005d98:	18050e63          	beqz	a0,80005f34 <exec+0x334>
  uvmclear(pagetable, sz - 2 * PGSIZE);
    80005d9c:	75f9                	lui	a1,0xffffe
    80005d9e:	95aa                	add	a1,a1,a0
    80005da0:	855a                	mv	a0,s6
    80005da2:	ffffb097          	auipc	ra,0xffffb
    80005da6:	5c0080e7          	jalr	1472(ra) # 80001362 <uvmclear>
  stackbase = sp - PGSIZE;
    80005daa:	7afd                	lui	s5,0xfffff
    80005dac:	9aea                	add	s5,s5,s10
  for (argc = 0; argv[argc]; argc++)
    80005dae:	df043783          	ld	a5,-528(s0)
    80005db2:	6388                	ld	a0,0(a5)
    80005db4:	c149                	beqz	a0,80005e36 <exec+0x236>
    80005db6:	e8840993          	addi	s3,s0,-376
    80005dba:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005dbe:	896a                	mv	s2,s10
  for (argc = 0; argv[argc]; argc++)
    80005dc0:	4481                	li	s1,0
    printf("copyout in exec 1\n"); //TODO: delete
    80005dc2:	00004c17          	auipc	s8,0x4
    80005dc6:	13ec0c13          	addi	s8,s8,318 # 80009f00 <syscalls+0x328>
    sp -= strlen(argv[argc]) + 1;
    80005dca:	ffffb097          	auipc	ra,0xffffb
    80005dce:	078080e7          	jalr	120(ra) # 80000e42 <strlen>
    80005dd2:	0015079b          	addiw	a5,a0,1
    80005dd6:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005dda:	ff097913          	andi	s2,s2,-16
    if (sp < stackbase)
    80005dde:	17596f63          	bltu	s2,s5,80005f5c <exec+0x35c>
    printf("copyout in exec 1\n"); //TODO: delete
    80005de2:	8562                	mv	a0,s8
    80005de4:	ffffa097          	auipc	ra,0xffffa
    80005de8:	790080e7          	jalr	1936(ra) # 80000574 <printf>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005dec:	df043783          	ld	a5,-528(s0)
    80005df0:	0007ba03          	ld	s4,0(a5) # fffffffffffff000 <end+0xffffffff7ffcf000>
    80005df4:	8552                	mv	a0,s4
    80005df6:	ffffb097          	auipc	ra,0xffffb
    80005dfa:	04c080e7          	jalr	76(ra) # 80000e42 <strlen>
    80005dfe:	0015069b          	addiw	a3,a0,1
    80005e02:	8652                	mv	a2,s4
    80005e04:	85ca                	mv	a1,s2
    80005e06:	855a                	mv	a0,s6
    80005e08:	ffffb097          	auipc	ra,0xffffb
    80005e0c:	5ac080e7          	jalr	1452(ra) # 800013b4 <copyout>
    80005e10:	14054a63          	bltz	a0,80005f64 <exec+0x364>
    ustack[argc] = sp;
    80005e14:	0129b023          	sd	s2,0(s3)
  for (argc = 0; argv[argc]; argc++)
    80005e18:	0485                	addi	s1,s1,1
    80005e1a:	df043783          	ld	a5,-528(s0)
    80005e1e:	07a1                	addi	a5,a5,8
    80005e20:	def43823          	sd	a5,-528(s0)
    80005e24:	6388                	ld	a0,0(a5)
    80005e26:	c911                	beqz	a0,80005e3a <exec+0x23a>
    if (argc >= MAXARG)
    80005e28:	09a1                	addi	s3,s3,8
    80005e2a:	fb3c90e3          	bne	s9,s3,80005dca <exec+0x1ca>
  sz = sz1;
    80005e2e:	dfa43c23          	sd	s10,-520(s0)
  ip = 0;
    80005e32:	4a81                	li	s5,0
    80005e34:	a201                	j	80005f34 <exec+0x334>
  sp = sz;
    80005e36:	896a                	mv	s2,s10
  for (argc = 0; argv[argc]; argc++)
    80005e38:	4481                	li	s1,0
  ustack[argc] = 0;
    80005e3a:	00349793          	slli	a5,s1,0x3
    80005e3e:	f9040713          	addi	a4,s0,-112
    80005e42:	97ba                	add	a5,a5,a4
    80005e44:	ee07bc23          	sd	zero,-264(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80005e48:	00148993          	addi	s3,s1,1
    80005e4c:	098e                	slli	s3,s3,0x3
    80005e4e:	41390933          	sub	s2,s2,s3
  sp -= sp % 16;
    80005e52:	ff097913          	andi	s2,s2,-16
  if (sp < stackbase)
    80005e56:	01597663          	bgeu	s2,s5,80005e62 <exec+0x262>
  sz = sz1;
    80005e5a:	dfa43c23          	sd	s10,-520(s0)
  ip = 0;
    80005e5e:	4a81                	li	s5,0
    80005e60:	a8d1                	j	80005f34 <exec+0x334>
  printf("copyout in exec 2\n"); //TODO: delete
    80005e62:	00004517          	auipc	a0,0x4
    80005e66:	0b650513          	addi	a0,a0,182 # 80009f18 <syscalls+0x340>
    80005e6a:	ffffa097          	auipc	ra,0xffffa
    80005e6e:	70a080e7          	jalr	1802(ra) # 80000574 <printf>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    80005e72:	86ce                	mv	a3,s3
    80005e74:	e8840613          	addi	a2,s0,-376
    80005e78:	85ca                	mv	a1,s2
    80005e7a:	855a                	mv	a0,s6
    80005e7c:	ffffb097          	auipc	ra,0xffffb
    80005e80:	538080e7          	jalr	1336(ra) # 800013b4 <copyout>
    80005e84:	0e054463          	bltz	a0,80005f6c <exec+0x36c>
  p->trapframe->a1 = sp;
    80005e88:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80005e8c:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    80005e90:	de843783          	ld	a5,-536(s0)
    80005e94:	0007c703          	lbu	a4,0(a5)
    80005e98:	cf11                	beqz	a4,80005eb4 <exec+0x2b4>
    80005e9a:	0785                	addi	a5,a5,1
    if (*s == '/')
    80005e9c:	02f00693          	li	a3,47
    80005ea0:	a039                	j	80005eae <exec+0x2ae>
      last = s + 1;
    80005ea2:	def43423          	sd	a5,-536(s0)
  for (last = s = path; *s; s++)
    80005ea6:	0785                	addi	a5,a5,1
    80005ea8:	fff7c703          	lbu	a4,-1(a5)
    80005eac:	c701                	beqz	a4,80005eb4 <exec+0x2b4>
    if (*s == '/')
    80005eae:	fed71ce3          	bne	a4,a3,80005ea6 <exec+0x2a6>
    80005eb2:	bfc5                	j	80005ea2 <exec+0x2a2>
  safestrcpy(p->name, last, sizeof(p->name));
    80005eb4:	4641                	li	a2,16
    80005eb6:	de843583          	ld	a1,-536(s0)
    80005eba:	158b8513          	addi	a0,s7,344
    80005ebe:	ffffb097          	auipc	ra,0xffffb
    80005ec2:	f52080e7          	jalr	-174(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005ec6:	050bb983          	ld	s3,80(s7)
  p->pagetable = pagetable;
    80005eca:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005ece:	05abb423          	sd	s10,72(s7)
  p->trapframe->epc = elf.entry; // initial program counter = main
    80005ed2:	058bb783          	ld	a5,88(s7)
    80005ed6:	e6043703          	ld	a4,-416(s0)
    80005eda:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80005edc:	058bb783          	ld	a5,88(s7)
    80005ee0:	0327b823          	sd	s2,48(a5)
  printf("before freepagetable\n");
    80005ee4:	00004517          	auipc	a0,0x4
    80005ee8:	04c50513          	addi	a0,a0,76 # 80009f30 <syscalls+0x358>
    80005eec:	ffffa097          	auipc	ra,0xffffa
    80005ef0:	688080e7          	jalr	1672(ra) # 80000574 <printf>
  proc_freepagetable(oldpagetable, oldsz); // also remove swapfile
    80005ef4:	85ee                	mv	a1,s11
    80005ef6:	854e                	mv	a0,s3
    80005ef8:	ffffc097          	auipc	ra,0xffffc
    80005efc:	0fc080e7          	jalr	252(ra) # 80001ff4 <proc_freepagetable>
  printf("after freepagetable\n");
    80005f00:	00004517          	auipc	a0,0x4
    80005f04:	04850513          	addi	a0,a0,72 # 80009f48 <syscalls+0x370>
    80005f08:	ffffa097          	auipc	ra,0xffffa
    80005f0c:	66c080e7          	jalr	1644(ra) # 80000574 <printf>
  if(p->pid >2){
    80005f10:	030ba703          	lw	a4,48(s7)
    80005f14:	4789                	li	a5,2
    80005f16:	00e7da63          	bge	a5,a4,80005f2a <exec+0x32a>
    p->physical_pages_num = 0;
    80005f1a:	160ba823          	sw	zero,368(s7)
    p->total_pages_num = 0;
    80005f1e:	160baa23          	sw	zero,372(s7)
    p->pages_physc_info.free_spaces = 0;
    80005f22:	280b9023          	sh	zero,640(s7)
    p->pages_swap_info.free_spaces = 0;
    80005f26:	160b9c23          	sh	zero,376(s7)
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005f2a:	0004851b          	sext.w	a0,s1
    80005f2e:	b3bd                	j	80005c9c <exec+0x9c>
    80005f30:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005f34:	df843583          	ld	a1,-520(s0)
    80005f38:	855a                	mv	a0,s6
    80005f3a:	ffffc097          	auipc	ra,0xffffc
    80005f3e:	0ba080e7          	jalr	186(ra) # 80001ff4 <proc_freepagetable>
  if (ip)
    80005f42:	d40a93e3          	bnez	s5,80005c88 <exec+0x88>
  return -1;
    80005f46:	557d                	li	a0,-1
    80005f48:	bb91                	j	80005c9c <exec+0x9c>
    80005f4a:	de943c23          	sd	s1,-520(s0)
    80005f4e:	b7dd                	j	80005f34 <exec+0x334>
    80005f50:	de943c23          	sd	s1,-520(s0)
    80005f54:	b7c5                	j	80005f34 <exec+0x334>
    80005f56:	de943c23          	sd	s1,-520(s0)
    80005f5a:	bfe9                	j	80005f34 <exec+0x334>
  sz = sz1;
    80005f5c:	dfa43c23          	sd	s10,-520(s0)
  ip = 0;
    80005f60:	4a81                	li	s5,0
    80005f62:	bfc9                	j	80005f34 <exec+0x334>
  sz = sz1;
    80005f64:	dfa43c23          	sd	s10,-520(s0)
  ip = 0;
    80005f68:	4a81                	li	s5,0
    80005f6a:	b7e9                	j	80005f34 <exec+0x334>
  sz = sz1;
    80005f6c:	dfa43c23          	sd	s10,-520(s0)
  ip = 0;
    80005f70:	4a81                	li	s5,0
    80005f72:	b7c9                	j	80005f34 <exec+0x334>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005f74:	df843483          	ld	s1,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005f78:	e0843783          	ld	a5,-504(s0)
    80005f7c:	0017869b          	addiw	a3,a5,1
    80005f80:	e0d43423          	sd	a3,-504(s0)
    80005f84:	e0043783          	ld	a5,-512(s0)
    80005f88:	0387879b          	addiw	a5,a5,56
    80005f8c:	e8045703          	lhu	a4,-384(s0)
    80005f90:	dce6d3e3          	bge	a3,a4,80005d56 <exec+0x156>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005f94:	2781                	sext.w	a5,a5
    80005f96:	e0f43023          	sd	a5,-512(s0)
    80005f9a:	03800713          	li	a4,56
    80005f9e:	86be                	mv	a3,a5
    80005fa0:	e1040613          	addi	a2,s0,-496
    80005fa4:	4581                	li	a1,0
    80005fa6:	8556                	mv	a0,s5
    80005fa8:	ffffe097          	auipc	ra,0xffffe
    80005fac:	500080e7          	jalr	1280(ra) # 800044a8 <readi>
    80005fb0:	03800793          	li	a5,56
    80005fb4:	f6f51ee3          	bne	a0,a5,80005f30 <exec+0x330>
    if (ph.type != ELF_PROG_LOAD)
    80005fb8:	e1042783          	lw	a5,-496(s0)
    80005fbc:	4705                	li	a4,1
    80005fbe:	fae79de3          	bne	a5,a4,80005f78 <exec+0x378>
    if (ph.memsz < ph.filesz)
    80005fc2:	e3843603          	ld	a2,-456(s0)
    80005fc6:	e3043783          	ld	a5,-464(s0)
    80005fca:	f8f660e3          	bltu	a2,a5,80005f4a <exec+0x34a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80005fce:	e2043783          	ld	a5,-480(s0)
    80005fd2:	963e                	add	a2,a2,a5
    80005fd4:	f6f66ee3          	bltu	a2,a5,80005f50 <exec+0x350>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005fd8:	85a6                	mv	a1,s1
    80005fda:	855a                	mv	a0,s6
    80005fdc:	ffffc097          	auipc	ra,0xffffc
    80005fe0:	a2a080e7          	jalr	-1494(ra) # 80001a06 <uvmalloc>
    80005fe4:	dea43c23          	sd	a0,-520(s0)
    80005fe8:	d53d                	beqz	a0,80005f56 <exec+0x356>
    if (ph.vaddr % PGSIZE != 0)
    80005fea:	e2043c03          	ld	s8,-480(s0)
    80005fee:	de043783          	ld	a5,-544(s0)
    80005ff2:	00fc77b3          	and	a5,s8,a5
    80005ff6:	ff9d                	bnez	a5,80005f34 <exec+0x334>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005ff8:	e1842c83          	lw	s9,-488(s0)
    80005ffc:	e3042b83          	lw	s7,-464(s0)
  for (i = 0; i < sz; i += PGSIZE)
    80006000:	f60b8ae3          	beqz	s7,80005f74 <exec+0x374>
    80006004:	89de                	mv	s3,s7
    80006006:	4481                	li	s1,0
    80006008:	b32d                	j	80005d32 <exec+0x132>

000000008000600a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000600a:	7179                	addi	sp,sp,-48
    8000600c:	f406                	sd	ra,40(sp)
    8000600e:	f022                	sd	s0,32(sp)
    80006010:	ec26                	sd	s1,24(sp)
    80006012:	e84a                	sd	s2,16(sp)
    80006014:	1800                	addi	s0,sp,48
    80006016:	892e                	mv	s2,a1
    80006018:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000601a:	fdc40593          	addi	a1,s0,-36
    8000601e:	ffffd097          	auipc	ra,0xffffd
    80006022:	664080e7          	jalr	1636(ra) # 80003682 <argint>
    80006026:	04054063          	bltz	a0,80006066 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000602a:	fdc42703          	lw	a4,-36(s0)
    8000602e:	47bd                	li	a5,15
    80006030:	02e7ed63          	bltu	a5,a4,8000606a <argfd+0x60>
    80006034:	ffffc097          	auipc	ra,0xffffc
    80006038:	e60080e7          	jalr	-416(ra) # 80001e94 <myproc>
    8000603c:	fdc42703          	lw	a4,-36(s0)
    80006040:	01a70793          	addi	a5,a4,26
    80006044:	078e                	slli	a5,a5,0x3
    80006046:	953e                	add	a0,a0,a5
    80006048:	611c                	ld	a5,0(a0)
    8000604a:	c395                	beqz	a5,8000606e <argfd+0x64>
    return -1;
  if(pfd)
    8000604c:	00090463          	beqz	s2,80006054 <argfd+0x4a>
    *pfd = fd;
    80006050:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80006054:	4501                	li	a0,0
  if(pf)
    80006056:	c091                	beqz	s1,8000605a <argfd+0x50>
    *pf = f;
    80006058:	e09c                	sd	a5,0(s1)
}
    8000605a:	70a2                	ld	ra,40(sp)
    8000605c:	7402                	ld	s0,32(sp)
    8000605e:	64e2                	ld	s1,24(sp)
    80006060:	6942                	ld	s2,16(sp)
    80006062:	6145                	addi	sp,sp,48
    80006064:	8082                	ret
    return -1;
    80006066:	557d                	li	a0,-1
    80006068:	bfcd                	j	8000605a <argfd+0x50>
    return -1;
    8000606a:	557d                	li	a0,-1
    8000606c:	b7fd                	j	8000605a <argfd+0x50>
    8000606e:	557d                	li	a0,-1
    80006070:	b7ed                	j	8000605a <argfd+0x50>

0000000080006072 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80006072:	1101                	addi	sp,sp,-32
    80006074:	ec06                	sd	ra,24(sp)
    80006076:	e822                	sd	s0,16(sp)
    80006078:	e426                	sd	s1,8(sp)
    8000607a:	1000                	addi	s0,sp,32
    8000607c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000607e:	ffffc097          	auipc	ra,0xffffc
    80006082:	e16080e7          	jalr	-490(ra) # 80001e94 <myproc>
    80006086:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80006088:	0d050793          	addi	a5,a0,208
    8000608c:	4501                	li	a0,0
    8000608e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80006090:	6398                	ld	a4,0(a5)
    80006092:	cb19                	beqz	a4,800060a8 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80006094:	2505                	addiw	a0,a0,1
    80006096:	07a1                	addi	a5,a5,8
    80006098:	fed51ce3          	bne	a0,a3,80006090 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000609c:	557d                	li	a0,-1
}
    8000609e:	60e2                	ld	ra,24(sp)
    800060a0:	6442                	ld	s0,16(sp)
    800060a2:	64a2                	ld	s1,8(sp)
    800060a4:	6105                	addi	sp,sp,32
    800060a6:	8082                	ret
      p->ofile[fd] = f;
    800060a8:	01a50793          	addi	a5,a0,26
    800060ac:	078e                	slli	a5,a5,0x3
    800060ae:	963e                	add	a2,a2,a5
    800060b0:	e204                	sd	s1,0(a2)
      return fd;
    800060b2:	b7f5                	j	8000609e <fdalloc+0x2c>

00000000800060b4 <sys_dup>:

uint64
sys_dup(void)
{
    800060b4:	7179                	addi	sp,sp,-48
    800060b6:	f406                	sd	ra,40(sp)
    800060b8:	f022                	sd	s0,32(sp)
    800060ba:	ec26                	sd	s1,24(sp)
    800060bc:	1800                	addi	s0,sp,48
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    800060be:	fd840613          	addi	a2,s0,-40
    800060c2:	4581                	li	a1,0
    800060c4:	4501                	li	a0,0
    800060c6:	00000097          	auipc	ra,0x0
    800060ca:	f44080e7          	jalr	-188(ra) # 8000600a <argfd>
    return -1;
    800060ce:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800060d0:	02054363          	bltz	a0,800060f6 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800060d4:	fd843503          	ld	a0,-40(s0)
    800060d8:	00000097          	auipc	ra,0x0
    800060dc:	f9a080e7          	jalr	-102(ra) # 80006072 <fdalloc>
    800060e0:	84aa                	mv	s1,a0
    return -1;
    800060e2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800060e4:	00054963          	bltz	a0,800060f6 <sys_dup+0x42>
  filedup(f);
    800060e8:	fd843503          	ld	a0,-40(s0)
    800060ec:	fffff097          	auipc	ra,0xfffff
    800060f0:	27a080e7          	jalr	634(ra) # 80005366 <filedup>
  return fd;
    800060f4:	87a6                	mv	a5,s1
}
    800060f6:	853e                	mv	a0,a5
    800060f8:	70a2                	ld	ra,40(sp)
    800060fa:	7402                	ld	s0,32(sp)
    800060fc:	64e2                	ld	s1,24(sp)
    800060fe:	6145                	addi	sp,sp,48
    80006100:	8082                	ret

0000000080006102 <sys_read>:

uint64
sys_read(void)
{
    80006102:	7179                	addi	sp,sp,-48
    80006104:	f406                	sd	ra,40(sp)
    80006106:	f022                	sd	s0,32(sp)
    80006108:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000610a:	fe840613          	addi	a2,s0,-24
    8000610e:	4581                	li	a1,0
    80006110:	4501                	li	a0,0
    80006112:	00000097          	auipc	ra,0x0
    80006116:	ef8080e7          	jalr	-264(ra) # 8000600a <argfd>
    return -1;
    8000611a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000611c:	04054163          	bltz	a0,8000615e <sys_read+0x5c>
    80006120:	fe440593          	addi	a1,s0,-28
    80006124:	4509                	li	a0,2
    80006126:	ffffd097          	auipc	ra,0xffffd
    8000612a:	55c080e7          	jalr	1372(ra) # 80003682 <argint>
    return -1;
    8000612e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006130:	02054763          	bltz	a0,8000615e <sys_read+0x5c>
    80006134:	fd840593          	addi	a1,s0,-40
    80006138:	4505                	li	a0,1
    8000613a:	ffffd097          	auipc	ra,0xffffd
    8000613e:	56a080e7          	jalr	1386(ra) # 800036a4 <argaddr>
    return -1;
    80006142:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006144:	00054d63          	bltz	a0,8000615e <sys_read+0x5c>
  return fileread(f, p, n);
    80006148:	fe442603          	lw	a2,-28(s0)
    8000614c:	fd843583          	ld	a1,-40(s0)
    80006150:	fe843503          	ld	a0,-24(s0)
    80006154:	fffff097          	auipc	ra,0xfffff
    80006158:	39e080e7          	jalr	926(ra) # 800054f2 <fileread>
    8000615c:	87aa                	mv	a5,a0
}
    8000615e:	853e                	mv	a0,a5
    80006160:	70a2                	ld	ra,40(sp)
    80006162:	7402                	ld	s0,32(sp)
    80006164:	6145                	addi	sp,sp,48
    80006166:	8082                	ret

0000000080006168 <sys_write>:

uint64
sys_write(void)
{
    80006168:	7179                	addi	sp,sp,-48
    8000616a:	f406                	sd	ra,40(sp)
    8000616c:	f022                	sd	s0,32(sp)
    8000616e:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006170:	fe840613          	addi	a2,s0,-24
    80006174:	4581                	li	a1,0
    80006176:	4501                	li	a0,0
    80006178:	00000097          	auipc	ra,0x0
    8000617c:	e92080e7          	jalr	-366(ra) # 8000600a <argfd>
    return -1;
    80006180:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006182:	04054163          	bltz	a0,800061c4 <sys_write+0x5c>
    80006186:	fe440593          	addi	a1,s0,-28
    8000618a:	4509                	li	a0,2
    8000618c:	ffffd097          	auipc	ra,0xffffd
    80006190:	4f6080e7          	jalr	1270(ra) # 80003682 <argint>
    return -1;
    80006194:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006196:	02054763          	bltz	a0,800061c4 <sys_write+0x5c>
    8000619a:	fd840593          	addi	a1,s0,-40
    8000619e:	4505                	li	a0,1
    800061a0:	ffffd097          	auipc	ra,0xffffd
    800061a4:	504080e7          	jalr	1284(ra) # 800036a4 <argaddr>
    return -1;
    800061a8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800061aa:	00054d63          	bltz	a0,800061c4 <sys_write+0x5c>

  return filewrite(f, p, n);
    800061ae:	fe442603          	lw	a2,-28(s0)
    800061b2:	fd843583          	ld	a1,-40(s0)
    800061b6:	fe843503          	ld	a0,-24(s0)
    800061ba:	fffff097          	auipc	ra,0xfffff
    800061be:	3fa080e7          	jalr	1018(ra) # 800055b4 <filewrite>
    800061c2:	87aa                	mv	a5,a0
}
    800061c4:	853e                	mv	a0,a5
    800061c6:	70a2                	ld	ra,40(sp)
    800061c8:	7402                	ld	s0,32(sp)
    800061ca:	6145                	addi	sp,sp,48
    800061cc:	8082                	ret

00000000800061ce <sys_close>:

uint64
sys_close(void)
{
    800061ce:	1101                	addi	sp,sp,-32
    800061d0:	ec06                	sd	ra,24(sp)
    800061d2:	e822                	sd	s0,16(sp)
    800061d4:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    800061d6:	fe040613          	addi	a2,s0,-32
    800061da:	fec40593          	addi	a1,s0,-20
    800061de:	4501                	li	a0,0
    800061e0:	00000097          	auipc	ra,0x0
    800061e4:	e2a080e7          	jalr	-470(ra) # 8000600a <argfd>
    return -1;
    800061e8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800061ea:	02054463          	bltz	a0,80006212 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800061ee:	ffffc097          	auipc	ra,0xffffc
    800061f2:	ca6080e7          	jalr	-858(ra) # 80001e94 <myproc>
    800061f6:	fec42783          	lw	a5,-20(s0)
    800061fa:	07e9                	addi	a5,a5,26
    800061fc:	078e                	slli	a5,a5,0x3
    800061fe:	97aa                	add	a5,a5,a0
    80006200:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80006204:	fe043503          	ld	a0,-32(s0)
    80006208:	fffff097          	auipc	ra,0xfffff
    8000620c:	1b0080e7          	jalr	432(ra) # 800053b8 <fileclose>
  return 0;
    80006210:	4781                	li	a5,0
}
    80006212:	853e                	mv	a0,a5
    80006214:	60e2                	ld	ra,24(sp)
    80006216:	6442                	ld	s0,16(sp)
    80006218:	6105                	addi	sp,sp,32
    8000621a:	8082                	ret

000000008000621c <sys_fstat>:

uint64
sys_fstat(void)
{
    8000621c:	1101                	addi	sp,sp,-32
    8000621e:	ec06                	sd	ra,24(sp)
    80006220:	e822                	sd	s0,16(sp)
    80006222:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006224:	fe840613          	addi	a2,s0,-24
    80006228:	4581                	li	a1,0
    8000622a:	4501                	li	a0,0
    8000622c:	00000097          	auipc	ra,0x0
    80006230:	dde080e7          	jalr	-546(ra) # 8000600a <argfd>
    return -1;
    80006234:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006236:	02054563          	bltz	a0,80006260 <sys_fstat+0x44>
    8000623a:	fe040593          	addi	a1,s0,-32
    8000623e:	4505                	li	a0,1
    80006240:	ffffd097          	auipc	ra,0xffffd
    80006244:	464080e7          	jalr	1124(ra) # 800036a4 <argaddr>
    return -1;
    80006248:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000624a:	00054b63          	bltz	a0,80006260 <sys_fstat+0x44>
  return filestat(f, st);
    8000624e:	fe043583          	ld	a1,-32(s0)
    80006252:	fe843503          	ld	a0,-24(s0)
    80006256:	fffff097          	auipc	ra,0xfffff
    8000625a:	22a080e7          	jalr	554(ra) # 80005480 <filestat>
    8000625e:	87aa                	mv	a5,a0
}
    80006260:	853e                	mv	a0,a5
    80006262:	60e2                	ld	ra,24(sp)
    80006264:	6442                	ld	s0,16(sp)
    80006266:	6105                	addi	sp,sp,32
    80006268:	8082                	ret

000000008000626a <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    8000626a:	7169                	addi	sp,sp,-304
    8000626c:	f606                	sd	ra,296(sp)
    8000626e:	f222                	sd	s0,288(sp)
    80006270:	ee26                	sd	s1,280(sp)
    80006272:	ea4a                	sd	s2,272(sp)
    80006274:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006276:	08000613          	li	a2,128
    8000627a:	ed040593          	addi	a1,s0,-304
    8000627e:	4501                	li	a0,0
    80006280:	ffffd097          	auipc	ra,0xffffd
    80006284:	446080e7          	jalr	1094(ra) # 800036c6 <argstr>
    return -1;
    80006288:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000628a:	10054e63          	bltz	a0,800063a6 <sys_link+0x13c>
    8000628e:	08000613          	li	a2,128
    80006292:	f5040593          	addi	a1,s0,-176
    80006296:	4505                	li	a0,1
    80006298:	ffffd097          	auipc	ra,0xffffd
    8000629c:	42e080e7          	jalr	1070(ra) # 800036c6 <argstr>
    return -1;
    800062a0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800062a2:	10054263          	bltz	a0,800063a6 <sys_link+0x13c>

  begin_op();
    800062a6:	fffff097          	auipc	ra,0xfffff
    800062aa:	c46080e7          	jalr	-954(ra) # 80004eec <begin_op>
  if((ip = namei(old)) == 0){
    800062ae:	ed040513          	addi	a0,s0,-304
    800062b2:	ffffe097          	auipc	ra,0xffffe
    800062b6:	6f8080e7          	jalr	1784(ra) # 800049aa <namei>
    800062ba:	84aa                	mv	s1,a0
    800062bc:	c551                	beqz	a0,80006348 <sys_link+0xde>
    end_op();
    return -1;
  }

  ilock(ip);
    800062be:	ffffe097          	auipc	ra,0xffffe
    800062c2:	f36080e7          	jalr	-202(ra) # 800041f4 <ilock>
  if(ip->type == T_DIR){
    800062c6:	04449703          	lh	a4,68(s1)
    800062ca:	4785                	li	a5,1
    800062cc:	08f70463          	beq	a4,a5,80006354 <sys_link+0xea>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
    800062d0:	04a4d783          	lhu	a5,74(s1)
    800062d4:	2785                	addiw	a5,a5,1
    800062d6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800062da:	8526                	mv	a0,s1
    800062dc:	ffffe097          	auipc	ra,0xffffe
    800062e0:	e4e080e7          	jalr	-434(ra) # 8000412a <iupdate>
  iunlock(ip);
    800062e4:	8526                	mv	a0,s1
    800062e6:	ffffe097          	auipc	ra,0xffffe
    800062ea:	fd0080e7          	jalr	-48(ra) # 800042b6 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    800062ee:	fd040593          	addi	a1,s0,-48
    800062f2:	f5040513          	addi	a0,s0,-176
    800062f6:	ffffe097          	auipc	ra,0xffffe
    800062fa:	6d2080e7          	jalr	1746(ra) # 800049c8 <nameiparent>
    800062fe:	892a                	mv	s2,a0
    80006300:	c935                	beqz	a0,80006374 <sys_link+0x10a>
    goto bad;
  ilock(dp);
    80006302:	ffffe097          	auipc	ra,0xffffe
    80006306:	ef2080e7          	jalr	-270(ra) # 800041f4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000630a:	00092703          	lw	a4,0(s2)
    8000630e:	409c                	lw	a5,0(s1)
    80006310:	04f71d63          	bne	a4,a5,8000636a <sys_link+0x100>
    80006314:	40d0                	lw	a2,4(s1)
    80006316:	fd040593          	addi	a1,s0,-48
    8000631a:	854a                	mv	a0,s2
    8000631c:	ffffe097          	auipc	ra,0xffffe
    80006320:	5cc080e7          	jalr	1484(ra) # 800048e8 <dirlink>
    80006324:	04054363          	bltz	a0,8000636a <sys_link+0x100>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
    80006328:	854a                	mv	a0,s2
    8000632a:	ffffe097          	auipc	ra,0xffffe
    8000632e:	12c080e7          	jalr	300(ra) # 80004456 <iunlockput>
  iput(ip);
    80006332:	8526                	mv	a0,s1
    80006334:	ffffe097          	auipc	ra,0xffffe
    80006338:	07a080e7          	jalr	122(ra) # 800043ae <iput>

  end_op();
    8000633c:	fffff097          	auipc	ra,0xfffff
    80006340:	c30080e7          	jalr	-976(ra) # 80004f6c <end_op>

  return 0;
    80006344:	4781                	li	a5,0
    80006346:	a085                	j	800063a6 <sys_link+0x13c>
    end_op();
    80006348:	fffff097          	auipc	ra,0xfffff
    8000634c:	c24080e7          	jalr	-988(ra) # 80004f6c <end_op>
    return -1;
    80006350:	57fd                	li	a5,-1
    80006352:	a891                	j	800063a6 <sys_link+0x13c>
    iunlockput(ip);
    80006354:	8526                	mv	a0,s1
    80006356:	ffffe097          	auipc	ra,0xffffe
    8000635a:	100080e7          	jalr	256(ra) # 80004456 <iunlockput>
    end_op();
    8000635e:	fffff097          	auipc	ra,0xfffff
    80006362:	c0e080e7          	jalr	-1010(ra) # 80004f6c <end_op>
    return -1;
    80006366:	57fd                	li	a5,-1
    80006368:	a83d                	j	800063a6 <sys_link+0x13c>
    iunlockput(dp);
    8000636a:	854a                	mv	a0,s2
    8000636c:	ffffe097          	auipc	ra,0xffffe
    80006370:	0ea080e7          	jalr	234(ra) # 80004456 <iunlockput>

bad:
  ilock(ip);
    80006374:	8526                	mv	a0,s1
    80006376:	ffffe097          	auipc	ra,0xffffe
    8000637a:	e7e080e7          	jalr	-386(ra) # 800041f4 <ilock>
  ip->nlink--;
    8000637e:	04a4d783          	lhu	a5,74(s1)
    80006382:	37fd                	addiw	a5,a5,-1
    80006384:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006388:	8526                	mv	a0,s1
    8000638a:	ffffe097          	auipc	ra,0xffffe
    8000638e:	da0080e7          	jalr	-608(ra) # 8000412a <iupdate>
  iunlockput(ip);
    80006392:	8526                	mv	a0,s1
    80006394:	ffffe097          	auipc	ra,0xffffe
    80006398:	0c2080e7          	jalr	194(ra) # 80004456 <iunlockput>
  end_op();
    8000639c:	fffff097          	auipc	ra,0xfffff
    800063a0:	bd0080e7          	jalr	-1072(ra) # 80004f6c <end_op>
  return -1;
    800063a4:	57fd                	li	a5,-1
}
    800063a6:	853e                	mv	a0,a5
    800063a8:	70b2                	ld	ra,296(sp)
    800063aa:	7412                	ld	s0,288(sp)
    800063ac:	64f2                	ld	s1,280(sp)
    800063ae:	6952                	ld	s2,272(sp)
    800063b0:	6155                	addi	sp,sp,304
    800063b2:	8082                	ret

00000000800063b4 <isdirempty>:
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800063b4:	4578                	lw	a4,76(a0)
    800063b6:	02000793          	li	a5,32
    800063ba:	04e7fa63          	bgeu	a5,a4,8000640e <isdirempty+0x5a>
{
    800063be:	7179                	addi	sp,sp,-48
    800063c0:	f406                	sd	ra,40(sp)
    800063c2:	f022                	sd	s0,32(sp)
    800063c4:	ec26                	sd	s1,24(sp)
    800063c6:	e84a                	sd	s2,16(sp)
    800063c8:	1800                	addi	s0,sp,48
    800063ca:	892a                	mv	s2,a0
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800063cc:	02000493          	li	s1,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800063d0:	4741                	li	a4,16
    800063d2:	86a6                	mv	a3,s1
    800063d4:	fd040613          	addi	a2,s0,-48
    800063d8:	4581                	li	a1,0
    800063da:	854a                	mv	a0,s2
    800063dc:	ffffe097          	auipc	ra,0xffffe
    800063e0:	0cc080e7          	jalr	204(ra) # 800044a8 <readi>
    800063e4:	47c1                	li	a5,16
    800063e6:	00f51c63          	bne	a0,a5,800063fe <isdirempty+0x4a>
      panic("isdirempty: readi");
    if(de.inum != 0)
    800063ea:	fd045783          	lhu	a5,-48(s0)
    800063ee:	e395                	bnez	a5,80006412 <isdirempty+0x5e>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800063f0:	24c1                	addiw	s1,s1,16
    800063f2:	04c92783          	lw	a5,76(s2)
    800063f6:	fcf4ede3          	bltu	s1,a5,800063d0 <isdirempty+0x1c>
      return 0;
  }
  return 1;
    800063fa:	4505                	li	a0,1
    800063fc:	a821                	j	80006414 <isdirempty+0x60>
      panic("isdirempty: readi");
    800063fe:	00004517          	auipc	a0,0x4
    80006402:	b6250513          	addi	a0,a0,-1182 # 80009f60 <syscalls+0x388>
    80006406:	ffffa097          	auipc	ra,0xffffa
    8000640a:	124080e7          	jalr	292(ra) # 8000052a <panic>
  return 1;
    8000640e:	4505                	li	a0,1
}
    80006410:	8082                	ret
      return 0;
    80006412:	4501                	li	a0,0
}
    80006414:	70a2                	ld	ra,40(sp)
    80006416:	7402                	ld	s0,32(sp)
    80006418:	64e2                	ld	s1,24(sp)
    8000641a:	6942                	ld	s2,16(sp)
    8000641c:	6145                	addi	sp,sp,48
    8000641e:	8082                	ret

0000000080006420 <sys_unlink>:

uint64
sys_unlink(void)
{
    80006420:	7155                	addi	sp,sp,-208
    80006422:	e586                	sd	ra,200(sp)
    80006424:	e1a2                	sd	s0,192(sp)
    80006426:	fd26                	sd	s1,184(sp)
    80006428:	f94a                	sd	s2,176(sp)
    8000642a:	0980                	addi	s0,sp,208
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    8000642c:	08000613          	li	a2,128
    80006430:	f4040593          	addi	a1,s0,-192
    80006434:	4501                	li	a0,0
    80006436:	ffffd097          	auipc	ra,0xffffd
    8000643a:	290080e7          	jalr	656(ra) # 800036c6 <argstr>
    8000643e:	16054363          	bltz	a0,800065a4 <sys_unlink+0x184>
    return -1;

  begin_op();
    80006442:	fffff097          	auipc	ra,0xfffff
    80006446:	aaa080e7          	jalr	-1366(ra) # 80004eec <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000644a:	fc040593          	addi	a1,s0,-64
    8000644e:	f4040513          	addi	a0,s0,-192
    80006452:	ffffe097          	auipc	ra,0xffffe
    80006456:	576080e7          	jalr	1398(ra) # 800049c8 <nameiparent>
    8000645a:	84aa                	mv	s1,a0
    8000645c:	c961                	beqz	a0,8000652c <sys_unlink+0x10c>
    end_op();
    return -1;
  }

  ilock(dp);
    8000645e:	ffffe097          	auipc	ra,0xffffe
    80006462:	d96080e7          	jalr	-618(ra) # 800041f4 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006466:	00004597          	auipc	a1,0x4
    8000646a:	97a58593          	addi	a1,a1,-1670 # 80009de0 <syscalls+0x208>
    8000646e:	fc040513          	addi	a0,s0,-64
    80006472:	ffffe097          	auipc	ra,0xffffe
    80006476:	24c080e7          	jalr	588(ra) # 800046be <namecmp>
    8000647a:	c175                	beqz	a0,8000655e <sys_unlink+0x13e>
    8000647c:	00004597          	auipc	a1,0x4
    80006480:	96c58593          	addi	a1,a1,-1684 # 80009de8 <syscalls+0x210>
    80006484:	fc040513          	addi	a0,s0,-64
    80006488:	ffffe097          	auipc	ra,0xffffe
    8000648c:	236080e7          	jalr	566(ra) # 800046be <namecmp>
    80006490:	c579                	beqz	a0,8000655e <sys_unlink+0x13e>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    80006492:	f3c40613          	addi	a2,s0,-196
    80006496:	fc040593          	addi	a1,s0,-64
    8000649a:	8526                	mv	a0,s1
    8000649c:	ffffe097          	auipc	ra,0xffffe
    800064a0:	23c080e7          	jalr	572(ra) # 800046d8 <dirlookup>
    800064a4:	892a                	mv	s2,a0
    800064a6:	cd45                	beqz	a0,8000655e <sys_unlink+0x13e>
    goto bad;
  ilock(ip);
    800064a8:	ffffe097          	auipc	ra,0xffffe
    800064ac:	d4c080e7          	jalr	-692(ra) # 800041f4 <ilock>

  if(ip->nlink < 1)
    800064b0:	04a91783          	lh	a5,74(s2)
    800064b4:	08f05263          	blez	a5,80006538 <sys_unlink+0x118>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    800064b8:	04491703          	lh	a4,68(s2)
    800064bc:	4785                	li	a5,1
    800064be:	08f70563          	beq	a4,a5,80006548 <sys_unlink+0x128>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    800064c2:	4641                	li	a2,16
    800064c4:	4581                	li	a1,0
    800064c6:	fd040513          	addi	a0,s0,-48
    800064ca:	ffffa097          	auipc	ra,0xffffa
    800064ce:	7f4080e7          	jalr	2036(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800064d2:	4741                	li	a4,16
    800064d4:	f3c42683          	lw	a3,-196(s0)
    800064d8:	fd040613          	addi	a2,s0,-48
    800064dc:	4581                	li	a1,0
    800064de:	8526                	mv	a0,s1
    800064e0:	ffffe097          	auipc	ra,0xffffe
    800064e4:	0c0080e7          	jalr	192(ra) # 800045a0 <writei>
    800064e8:	47c1                	li	a5,16
    800064ea:	08f51a63          	bne	a0,a5,8000657e <sys_unlink+0x15e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    800064ee:	04491703          	lh	a4,68(s2)
    800064f2:	4785                	li	a5,1
    800064f4:	08f70d63          	beq	a4,a5,8000658e <sys_unlink+0x16e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    800064f8:	8526                	mv	a0,s1
    800064fa:	ffffe097          	auipc	ra,0xffffe
    800064fe:	f5c080e7          	jalr	-164(ra) # 80004456 <iunlockput>

  ip->nlink--;
    80006502:	04a95783          	lhu	a5,74(s2)
    80006506:	37fd                	addiw	a5,a5,-1
    80006508:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000650c:	854a                	mv	a0,s2
    8000650e:	ffffe097          	auipc	ra,0xffffe
    80006512:	c1c080e7          	jalr	-996(ra) # 8000412a <iupdate>
  iunlockput(ip);
    80006516:	854a                	mv	a0,s2
    80006518:	ffffe097          	auipc	ra,0xffffe
    8000651c:	f3e080e7          	jalr	-194(ra) # 80004456 <iunlockput>

  end_op();
    80006520:	fffff097          	auipc	ra,0xfffff
    80006524:	a4c080e7          	jalr	-1460(ra) # 80004f6c <end_op>

  return 0;
    80006528:	4501                	li	a0,0
    8000652a:	a0a1                	j	80006572 <sys_unlink+0x152>
    end_op();
    8000652c:	fffff097          	auipc	ra,0xfffff
    80006530:	a40080e7          	jalr	-1472(ra) # 80004f6c <end_op>
    return -1;
    80006534:	557d                	li	a0,-1
    80006536:	a835                	j	80006572 <sys_unlink+0x152>
    panic("unlink: nlink < 1");
    80006538:	00004517          	auipc	a0,0x4
    8000653c:	8b850513          	addi	a0,a0,-1864 # 80009df0 <syscalls+0x218>
    80006540:	ffffa097          	auipc	ra,0xffffa
    80006544:	fea080e7          	jalr	-22(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006548:	854a                	mv	a0,s2
    8000654a:	00000097          	auipc	ra,0x0
    8000654e:	e6a080e7          	jalr	-406(ra) # 800063b4 <isdirempty>
    80006552:	f925                	bnez	a0,800064c2 <sys_unlink+0xa2>
    iunlockput(ip);
    80006554:	854a                	mv	a0,s2
    80006556:	ffffe097          	auipc	ra,0xffffe
    8000655a:	f00080e7          	jalr	-256(ra) # 80004456 <iunlockput>

bad:
  iunlockput(dp);
    8000655e:	8526                	mv	a0,s1
    80006560:	ffffe097          	auipc	ra,0xffffe
    80006564:	ef6080e7          	jalr	-266(ra) # 80004456 <iunlockput>
  end_op();
    80006568:	fffff097          	auipc	ra,0xfffff
    8000656c:	a04080e7          	jalr	-1532(ra) # 80004f6c <end_op>
  return -1;
    80006570:	557d                	li	a0,-1
}
    80006572:	60ae                	ld	ra,200(sp)
    80006574:	640e                	ld	s0,192(sp)
    80006576:	74ea                	ld	s1,184(sp)
    80006578:	794a                	ld	s2,176(sp)
    8000657a:	6169                	addi	sp,sp,208
    8000657c:	8082                	ret
    panic("unlink: writei");
    8000657e:	00004517          	auipc	a0,0x4
    80006582:	88a50513          	addi	a0,a0,-1910 # 80009e08 <syscalls+0x230>
    80006586:	ffffa097          	auipc	ra,0xffffa
    8000658a:	fa4080e7          	jalr	-92(ra) # 8000052a <panic>
    dp->nlink--;
    8000658e:	04a4d783          	lhu	a5,74(s1)
    80006592:	37fd                	addiw	a5,a5,-1
    80006594:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006598:	8526                	mv	a0,s1
    8000659a:	ffffe097          	auipc	ra,0xffffe
    8000659e:	b90080e7          	jalr	-1136(ra) # 8000412a <iupdate>
    800065a2:	bf99                	j	800064f8 <sys_unlink+0xd8>
    return -1;
    800065a4:	557d                	li	a0,-1
    800065a6:	b7f1                	j	80006572 <sys_unlink+0x152>

00000000800065a8 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
    800065a8:	715d                	addi	sp,sp,-80
    800065aa:	e486                	sd	ra,72(sp)
    800065ac:	e0a2                	sd	s0,64(sp)
    800065ae:	fc26                	sd	s1,56(sp)
    800065b0:	f84a                	sd	s2,48(sp)
    800065b2:	f44e                	sd	s3,40(sp)
    800065b4:	f052                	sd	s4,32(sp)
    800065b6:	ec56                	sd	s5,24(sp)
    800065b8:	0880                	addi	s0,sp,80
    800065ba:	89ae                	mv	s3,a1
    800065bc:	8ab2                	mv	s5,a2
    800065be:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800065c0:	fb040593          	addi	a1,s0,-80
    800065c4:	ffffe097          	auipc	ra,0xffffe
    800065c8:	404080e7          	jalr	1028(ra) # 800049c8 <nameiparent>
    800065cc:	892a                	mv	s2,a0
    800065ce:	12050e63          	beqz	a0,8000670a <create+0x162>
    return 0;

  ilock(dp);
    800065d2:	ffffe097          	auipc	ra,0xffffe
    800065d6:	c22080e7          	jalr	-990(ra) # 800041f4 <ilock>
  
  if((ip = dirlookup(dp, name, 0)) != 0){
    800065da:	4601                	li	a2,0
    800065dc:	fb040593          	addi	a1,s0,-80
    800065e0:	854a                	mv	a0,s2
    800065e2:	ffffe097          	auipc	ra,0xffffe
    800065e6:	0f6080e7          	jalr	246(ra) # 800046d8 <dirlookup>
    800065ea:	84aa                	mv	s1,a0
    800065ec:	c921                	beqz	a0,8000663c <create+0x94>
    iunlockput(dp);
    800065ee:	854a                	mv	a0,s2
    800065f0:	ffffe097          	auipc	ra,0xffffe
    800065f4:	e66080e7          	jalr	-410(ra) # 80004456 <iunlockput>
    ilock(ip);
    800065f8:	8526                	mv	a0,s1
    800065fa:	ffffe097          	auipc	ra,0xffffe
    800065fe:	bfa080e7          	jalr	-1030(ra) # 800041f4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006602:	2981                	sext.w	s3,s3
    80006604:	4789                	li	a5,2
    80006606:	02f99463          	bne	s3,a5,8000662e <create+0x86>
    8000660a:	0444d783          	lhu	a5,68(s1)
    8000660e:	37f9                	addiw	a5,a5,-2
    80006610:	17c2                	slli	a5,a5,0x30
    80006612:	93c1                	srli	a5,a5,0x30
    80006614:	4705                	li	a4,1
    80006616:	00f76c63          	bltu	a4,a5,8000662e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000661a:	8526                	mv	a0,s1
    8000661c:	60a6                	ld	ra,72(sp)
    8000661e:	6406                	ld	s0,64(sp)
    80006620:	74e2                	ld	s1,56(sp)
    80006622:	7942                	ld	s2,48(sp)
    80006624:	79a2                	ld	s3,40(sp)
    80006626:	7a02                	ld	s4,32(sp)
    80006628:	6ae2                	ld	s5,24(sp)
    8000662a:	6161                	addi	sp,sp,80
    8000662c:	8082                	ret
    iunlockput(ip);
    8000662e:	8526                	mv	a0,s1
    80006630:	ffffe097          	auipc	ra,0xffffe
    80006634:	e26080e7          	jalr	-474(ra) # 80004456 <iunlockput>
    return 0;
    80006638:	4481                	li	s1,0
    8000663a:	b7c5                	j	8000661a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000663c:	85ce                	mv	a1,s3
    8000663e:	00092503          	lw	a0,0(s2)
    80006642:	ffffe097          	auipc	ra,0xffffe
    80006646:	a1a080e7          	jalr	-1510(ra) # 8000405c <ialloc>
    8000664a:	84aa                	mv	s1,a0
    8000664c:	c521                	beqz	a0,80006694 <create+0xec>
  ilock(ip);
    8000664e:	ffffe097          	auipc	ra,0xffffe
    80006652:	ba6080e7          	jalr	-1114(ra) # 800041f4 <ilock>
  ip->major = major;
    80006656:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000665a:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000665e:	4a05                	li	s4,1
    80006660:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80006664:	8526                	mv	a0,s1
    80006666:	ffffe097          	auipc	ra,0xffffe
    8000666a:	ac4080e7          	jalr	-1340(ra) # 8000412a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000666e:	2981                	sext.w	s3,s3
    80006670:	03498a63          	beq	s3,s4,800066a4 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80006674:	40d0                	lw	a2,4(s1)
    80006676:	fb040593          	addi	a1,s0,-80
    8000667a:	854a                	mv	a0,s2
    8000667c:	ffffe097          	auipc	ra,0xffffe
    80006680:	26c080e7          	jalr	620(ra) # 800048e8 <dirlink>
    80006684:	06054b63          	bltz	a0,800066fa <create+0x152>
  iunlockput(dp);
    80006688:	854a                	mv	a0,s2
    8000668a:	ffffe097          	auipc	ra,0xffffe
    8000668e:	dcc080e7          	jalr	-564(ra) # 80004456 <iunlockput>
  return ip;
    80006692:	b761                	j	8000661a <create+0x72>
    panic("create: ialloc");
    80006694:	00004517          	auipc	a0,0x4
    80006698:	8e450513          	addi	a0,a0,-1820 # 80009f78 <syscalls+0x3a0>
    8000669c:	ffffa097          	auipc	ra,0xffffa
    800066a0:	e8e080e7          	jalr	-370(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    800066a4:	04a95783          	lhu	a5,74(s2)
    800066a8:	2785                	addiw	a5,a5,1
    800066aa:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800066ae:	854a                	mv	a0,s2
    800066b0:	ffffe097          	auipc	ra,0xffffe
    800066b4:	a7a080e7          	jalr	-1414(ra) # 8000412a <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800066b8:	40d0                	lw	a2,4(s1)
    800066ba:	00003597          	auipc	a1,0x3
    800066be:	72658593          	addi	a1,a1,1830 # 80009de0 <syscalls+0x208>
    800066c2:	8526                	mv	a0,s1
    800066c4:	ffffe097          	auipc	ra,0xffffe
    800066c8:	224080e7          	jalr	548(ra) # 800048e8 <dirlink>
    800066cc:	00054f63          	bltz	a0,800066ea <create+0x142>
    800066d0:	00492603          	lw	a2,4(s2)
    800066d4:	00003597          	auipc	a1,0x3
    800066d8:	71458593          	addi	a1,a1,1812 # 80009de8 <syscalls+0x210>
    800066dc:	8526                	mv	a0,s1
    800066de:	ffffe097          	auipc	ra,0xffffe
    800066e2:	20a080e7          	jalr	522(ra) # 800048e8 <dirlink>
    800066e6:	f80557e3          	bgez	a0,80006674 <create+0xcc>
      panic("create dots");
    800066ea:	00004517          	auipc	a0,0x4
    800066ee:	89e50513          	addi	a0,a0,-1890 # 80009f88 <syscalls+0x3b0>
    800066f2:	ffffa097          	auipc	ra,0xffffa
    800066f6:	e38080e7          	jalr	-456(ra) # 8000052a <panic>
    panic("create: dirlink");
    800066fa:	00004517          	auipc	a0,0x4
    800066fe:	89e50513          	addi	a0,a0,-1890 # 80009f98 <syscalls+0x3c0>
    80006702:	ffffa097          	auipc	ra,0xffffa
    80006706:	e28080e7          	jalr	-472(ra) # 8000052a <panic>
    return 0;
    8000670a:	84aa                	mv	s1,a0
    8000670c:	b739                	j	8000661a <create+0x72>

000000008000670e <sys_open>:

uint64
sys_open(void)
{
    8000670e:	7131                	addi	sp,sp,-192
    80006710:	fd06                	sd	ra,184(sp)
    80006712:	f922                	sd	s0,176(sp)
    80006714:	f526                	sd	s1,168(sp)
    80006716:	f14a                	sd	s2,160(sp)
    80006718:	ed4e                	sd	s3,152(sp)
    8000671a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000671c:	08000613          	li	a2,128
    80006720:	f5040593          	addi	a1,s0,-176
    80006724:	4501                	li	a0,0
    80006726:	ffffd097          	auipc	ra,0xffffd
    8000672a:	fa0080e7          	jalr	-96(ra) # 800036c6 <argstr>
    return -1;
    8000672e:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006730:	0c054163          	bltz	a0,800067f2 <sys_open+0xe4>
    80006734:	f4c40593          	addi	a1,s0,-180
    80006738:	4505                	li	a0,1
    8000673a:	ffffd097          	auipc	ra,0xffffd
    8000673e:	f48080e7          	jalr	-184(ra) # 80003682 <argint>
    80006742:	0a054863          	bltz	a0,800067f2 <sys_open+0xe4>

  begin_op();
    80006746:	ffffe097          	auipc	ra,0xffffe
    8000674a:	7a6080e7          	jalr	1958(ra) # 80004eec <begin_op>

  if(omode & O_CREATE){
    8000674e:	f4c42783          	lw	a5,-180(s0)
    80006752:	2007f793          	andi	a5,a5,512
    80006756:	cbdd                	beqz	a5,8000680c <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80006758:	4681                	li	a3,0
    8000675a:	4601                	li	a2,0
    8000675c:	4589                	li	a1,2
    8000675e:	f5040513          	addi	a0,s0,-176
    80006762:	00000097          	auipc	ra,0x0
    80006766:	e46080e7          	jalr	-442(ra) # 800065a8 <create>
    8000676a:	892a                	mv	s2,a0
    if(ip == 0){
    8000676c:	c959                	beqz	a0,80006802 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000676e:	04491703          	lh	a4,68(s2)
    80006772:	478d                	li	a5,3
    80006774:	00f71763          	bne	a4,a5,80006782 <sys_open+0x74>
    80006778:	04695703          	lhu	a4,70(s2)
    8000677c:	47a5                	li	a5,9
    8000677e:	0ce7ec63          	bltu	a5,a4,80006856 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006782:	fffff097          	auipc	ra,0xfffff
    80006786:	b7a080e7          	jalr	-1158(ra) # 800052fc <filealloc>
    8000678a:	89aa                	mv	s3,a0
    8000678c:	10050263          	beqz	a0,80006890 <sys_open+0x182>
    80006790:	00000097          	auipc	ra,0x0
    80006794:	8e2080e7          	jalr	-1822(ra) # 80006072 <fdalloc>
    80006798:	84aa                	mv	s1,a0
    8000679a:	0e054663          	bltz	a0,80006886 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000679e:	04491703          	lh	a4,68(s2)
    800067a2:	478d                	li	a5,3
    800067a4:	0cf70463          	beq	a4,a5,8000686c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800067a8:	4789                	li	a5,2
    800067aa:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800067ae:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800067b2:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800067b6:	f4c42783          	lw	a5,-180(s0)
    800067ba:	0017c713          	xori	a4,a5,1
    800067be:	8b05                	andi	a4,a4,1
    800067c0:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800067c4:	0037f713          	andi	a4,a5,3
    800067c8:	00e03733          	snez	a4,a4
    800067cc:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800067d0:	4007f793          	andi	a5,a5,1024
    800067d4:	c791                	beqz	a5,800067e0 <sys_open+0xd2>
    800067d6:	04491703          	lh	a4,68(s2)
    800067da:	4789                	li	a5,2
    800067dc:	08f70f63          	beq	a4,a5,8000687a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800067e0:	854a                	mv	a0,s2
    800067e2:	ffffe097          	auipc	ra,0xffffe
    800067e6:	ad4080e7          	jalr	-1324(ra) # 800042b6 <iunlock>
  end_op();
    800067ea:	ffffe097          	auipc	ra,0xffffe
    800067ee:	782080e7          	jalr	1922(ra) # 80004f6c <end_op>

  return fd;
}
    800067f2:	8526                	mv	a0,s1
    800067f4:	70ea                	ld	ra,184(sp)
    800067f6:	744a                	ld	s0,176(sp)
    800067f8:	74aa                	ld	s1,168(sp)
    800067fa:	790a                	ld	s2,160(sp)
    800067fc:	69ea                	ld	s3,152(sp)
    800067fe:	6129                	addi	sp,sp,192
    80006800:	8082                	ret
      end_op();
    80006802:	ffffe097          	auipc	ra,0xffffe
    80006806:	76a080e7          	jalr	1898(ra) # 80004f6c <end_op>
      return -1;
    8000680a:	b7e5                	j	800067f2 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000680c:	f5040513          	addi	a0,s0,-176
    80006810:	ffffe097          	auipc	ra,0xffffe
    80006814:	19a080e7          	jalr	410(ra) # 800049aa <namei>
    80006818:	892a                	mv	s2,a0
    8000681a:	c905                	beqz	a0,8000684a <sys_open+0x13c>
    ilock(ip);
    8000681c:	ffffe097          	auipc	ra,0xffffe
    80006820:	9d8080e7          	jalr	-1576(ra) # 800041f4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006824:	04491703          	lh	a4,68(s2)
    80006828:	4785                	li	a5,1
    8000682a:	f4f712e3          	bne	a4,a5,8000676e <sys_open+0x60>
    8000682e:	f4c42783          	lw	a5,-180(s0)
    80006832:	dba1                	beqz	a5,80006782 <sys_open+0x74>
      iunlockput(ip);
    80006834:	854a                	mv	a0,s2
    80006836:	ffffe097          	auipc	ra,0xffffe
    8000683a:	c20080e7          	jalr	-992(ra) # 80004456 <iunlockput>
      end_op();
    8000683e:	ffffe097          	auipc	ra,0xffffe
    80006842:	72e080e7          	jalr	1838(ra) # 80004f6c <end_op>
      return -1;
    80006846:	54fd                	li	s1,-1
    80006848:	b76d                	j	800067f2 <sys_open+0xe4>
      end_op();
    8000684a:	ffffe097          	auipc	ra,0xffffe
    8000684e:	722080e7          	jalr	1826(ra) # 80004f6c <end_op>
      return -1;
    80006852:	54fd                	li	s1,-1
    80006854:	bf79                	j	800067f2 <sys_open+0xe4>
    iunlockput(ip);
    80006856:	854a                	mv	a0,s2
    80006858:	ffffe097          	auipc	ra,0xffffe
    8000685c:	bfe080e7          	jalr	-1026(ra) # 80004456 <iunlockput>
    end_op();
    80006860:	ffffe097          	auipc	ra,0xffffe
    80006864:	70c080e7          	jalr	1804(ra) # 80004f6c <end_op>
    return -1;
    80006868:	54fd                	li	s1,-1
    8000686a:	b761                	j	800067f2 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000686c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006870:	04691783          	lh	a5,70(s2)
    80006874:	02f99223          	sh	a5,36(s3)
    80006878:	bf2d                	j	800067b2 <sys_open+0xa4>
    itrunc(ip);
    8000687a:	854a                	mv	a0,s2
    8000687c:	ffffe097          	auipc	ra,0xffffe
    80006880:	a86080e7          	jalr	-1402(ra) # 80004302 <itrunc>
    80006884:	bfb1                	j	800067e0 <sys_open+0xd2>
      fileclose(f);
    80006886:	854e                	mv	a0,s3
    80006888:	fffff097          	auipc	ra,0xfffff
    8000688c:	b30080e7          	jalr	-1232(ra) # 800053b8 <fileclose>
    iunlockput(ip);
    80006890:	854a                	mv	a0,s2
    80006892:	ffffe097          	auipc	ra,0xffffe
    80006896:	bc4080e7          	jalr	-1084(ra) # 80004456 <iunlockput>
    end_op();
    8000689a:	ffffe097          	auipc	ra,0xffffe
    8000689e:	6d2080e7          	jalr	1746(ra) # 80004f6c <end_op>
    return -1;
    800068a2:	54fd                	li	s1,-1
    800068a4:	b7b9                	j	800067f2 <sys_open+0xe4>

00000000800068a6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800068a6:	7175                	addi	sp,sp,-144
    800068a8:	e506                	sd	ra,136(sp)
    800068aa:	e122                	sd	s0,128(sp)
    800068ac:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800068ae:	ffffe097          	auipc	ra,0xffffe
    800068b2:	63e080e7          	jalr	1598(ra) # 80004eec <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800068b6:	08000613          	li	a2,128
    800068ba:	f7040593          	addi	a1,s0,-144
    800068be:	4501                	li	a0,0
    800068c0:	ffffd097          	auipc	ra,0xffffd
    800068c4:	e06080e7          	jalr	-506(ra) # 800036c6 <argstr>
    800068c8:	02054963          	bltz	a0,800068fa <sys_mkdir+0x54>
    800068cc:	4681                	li	a3,0
    800068ce:	4601                	li	a2,0
    800068d0:	4585                	li	a1,1
    800068d2:	f7040513          	addi	a0,s0,-144
    800068d6:	00000097          	auipc	ra,0x0
    800068da:	cd2080e7          	jalr	-814(ra) # 800065a8 <create>
    800068de:	cd11                	beqz	a0,800068fa <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800068e0:	ffffe097          	auipc	ra,0xffffe
    800068e4:	b76080e7          	jalr	-1162(ra) # 80004456 <iunlockput>
  end_op();
    800068e8:	ffffe097          	auipc	ra,0xffffe
    800068ec:	684080e7          	jalr	1668(ra) # 80004f6c <end_op>
  return 0;
    800068f0:	4501                	li	a0,0
}
    800068f2:	60aa                	ld	ra,136(sp)
    800068f4:	640a                	ld	s0,128(sp)
    800068f6:	6149                	addi	sp,sp,144
    800068f8:	8082                	ret
    end_op();
    800068fa:	ffffe097          	auipc	ra,0xffffe
    800068fe:	672080e7          	jalr	1650(ra) # 80004f6c <end_op>
    return -1;
    80006902:	557d                	li	a0,-1
    80006904:	b7fd                	j	800068f2 <sys_mkdir+0x4c>

0000000080006906 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006906:	7135                	addi	sp,sp,-160
    80006908:	ed06                	sd	ra,152(sp)
    8000690a:	e922                	sd	s0,144(sp)
    8000690c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000690e:	ffffe097          	auipc	ra,0xffffe
    80006912:	5de080e7          	jalr	1502(ra) # 80004eec <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006916:	08000613          	li	a2,128
    8000691a:	f7040593          	addi	a1,s0,-144
    8000691e:	4501                	li	a0,0
    80006920:	ffffd097          	auipc	ra,0xffffd
    80006924:	da6080e7          	jalr	-602(ra) # 800036c6 <argstr>
    80006928:	04054a63          	bltz	a0,8000697c <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000692c:	f6c40593          	addi	a1,s0,-148
    80006930:	4505                	li	a0,1
    80006932:	ffffd097          	auipc	ra,0xffffd
    80006936:	d50080e7          	jalr	-688(ra) # 80003682 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000693a:	04054163          	bltz	a0,8000697c <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000693e:	f6840593          	addi	a1,s0,-152
    80006942:	4509                	li	a0,2
    80006944:	ffffd097          	auipc	ra,0xffffd
    80006948:	d3e080e7          	jalr	-706(ra) # 80003682 <argint>
     argint(1, &major) < 0 ||
    8000694c:	02054863          	bltz	a0,8000697c <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006950:	f6841683          	lh	a3,-152(s0)
    80006954:	f6c41603          	lh	a2,-148(s0)
    80006958:	458d                	li	a1,3
    8000695a:	f7040513          	addi	a0,s0,-144
    8000695e:	00000097          	auipc	ra,0x0
    80006962:	c4a080e7          	jalr	-950(ra) # 800065a8 <create>
     argint(2, &minor) < 0 ||
    80006966:	c919                	beqz	a0,8000697c <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006968:	ffffe097          	auipc	ra,0xffffe
    8000696c:	aee080e7          	jalr	-1298(ra) # 80004456 <iunlockput>
  end_op();
    80006970:	ffffe097          	auipc	ra,0xffffe
    80006974:	5fc080e7          	jalr	1532(ra) # 80004f6c <end_op>
  return 0;
    80006978:	4501                	li	a0,0
    8000697a:	a031                	j	80006986 <sys_mknod+0x80>
    end_op();
    8000697c:	ffffe097          	auipc	ra,0xffffe
    80006980:	5f0080e7          	jalr	1520(ra) # 80004f6c <end_op>
    return -1;
    80006984:	557d                	li	a0,-1
}
    80006986:	60ea                	ld	ra,152(sp)
    80006988:	644a                	ld	s0,144(sp)
    8000698a:	610d                	addi	sp,sp,160
    8000698c:	8082                	ret

000000008000698e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000698e:	7135                	addi	sp,sp,-160
    80006990:	ed06                	sd	ra,152(sp)
    80006992:	e922                	sd	s0,144(sp)
    80006994:	e526                	sd	s1,136(sp)
    80006996:	e14a                	sd	s2,128(sp)
    80006998:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000699a:	ffffb097          	auipc	ra,0xffffb
    8000699e:	4fa080e7          	jalr	1274(ra) # 80001e94 <myproc>
    800069a2:	892a                	mv	s2,a0
  
  begin_op();
    800069a4:	ffffe097          	auipc	ra,0xffffe
    800069a8:	548080e7          	jalr	1352(ra) # 80004eec <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800069ac:	08000613          	li	a2,128
    800069b0:	f6040593          	addi	a1,s0,-160
    800069b4:	4501                	li	a0,0
    800069b6:	ffffd097          	auipc	ra,0xffffd
    800069ba:	d10080e7          	jalr	-752(ra) # 800036c6 <argstr>
    800069be:	04054b63          	bltz	a0,80006a14 <sys_chdir+0x86>
    800069c2:	f6040513          	addi	a0,s0,-160
    800069c6:	ffffe097          	auipc	ra,0xffffe
    800069ca:	fe4080e7          	jalr	-28(ra) # 800049aa <namei>
    800069ce:	84aa                	mv	s1,a0
    800069d0:	c131                	beqz	a0,80006a14 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800069d2:	ffffe097          	auipc	ra,0xffffe
    800069d6:	822080e7          	jalr	-2014(ra) # 800041f4 <ilock>
  if(ip->type != T_DIR){
    800069da:	04449703          	lh	a4,68(s1)
    800069de:	4785                	li	a5,1
    800069e0:	04f71063          	bne	a4,a5,80006a20 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800069e4:	8526                	mv	a0,s1
    800069e6:	ffffe097          	auipc	ra,0xffffe
    800069ea:	8d0080e7          	jalr	-1840(ra) # 800042b6 <iunlock>
  iput(p->cwd);
    800069ee:	15093503          	ld	a0,336(s2)
    800069f2:	ffffe097          	auipc	ra,0xffffe
    800069f6:	9bc080e7          	jalr	-1604(ra) # 800043ae <iput>
  end_op();
    800069fa:	ffffe097          	auipc	ra,0xffffe
    800069fe:	572080e7          	jalr	1394(ra) # 80004f6c <end_op>
  p->cwd = ip;
    80006a02:	14993823          	sd	s1,336(s2)
  return 0;
    80006a06:	4501                	li	a0,0
}
    80006a08:	60ea                	ld	ra,152(sp)
    80006a0a:	644a                	ld	s0,144(sp)
    80006a0c:	64aa                	ld	s1,136(sp)
    80006a0e:	690a                	ld	s2,128(sp)
    80006a10:	610d                	addi	sp,sp,160
    80006a12:	8082                	ret
    end_op();
    80006a14:	ffffe097          	auipc	ra,0xffffe
    80006a18:	558080e7          	jalr	1368(ra) # 80004f6c <end_op>
    return -1;
    80006a1c:	557d                	li	a0,-1
    80006a1e:	b7ed                	j	80006a08 <sys_chdir+0x7a>
    iunlockput(ip);
    80006a20:	8526                	mv	a0,s1
    80006a22:	ffffe097          	auipc	ra,0xffffe
    80006a26:	a34080e7          	jalr	-1484(ra) # 80004456 <iunlockput>
    end_op();
    80006a2a:	ffffe097          	auipc	ra,0xffffe
    80006a2e:	542080e7          	jalr	1346(ra) # 80004f6c <end_op>
    return -1;
    80006a32:	557d                	li	a0,-1
    80006a34:	bfd1                	j	80006a08 <sys_chdir+0x7a>

0000000080006a36 <sys_exec>:

uint64
sys_exec(void)
{
    80006a36:	7145                	addi	sp,sp,-464
    80006a38:	e786                	sd	ra,456(sp)
    80006a3a:	e3a2                	sd	s0,448(sp)
    80006a3c:	ff26                	sd	s1,440(sp)
    80006a3e:	fb4a                	sd	s2,432(sp)
    80006a40:	f74e                	sd	s3,424(sp)
    80006a42:	f352                	sd	s4,416(sp)
    80006a44:	ef56                	sd	s5,408(sp)
    80006a46:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006a48:	08000613          	li	a2,128
    80006a4c:	f4040593          	addi	a1,s0,-192
    80006a50:	4501                	li	a0,0
    80006a52:	ffffd097          	auipc	ra,0xffffd
    80006a56:	c74080e7          	jalr	-908(ra) # 800036c6 <argstr>
    return -1;
    80006a5a:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006a5c:	0c054a63          	bltz	a0,80006b30 <sys_exec+0xfa>
    80006a60:	e3840593          	addi	a1,s0,-456
    80006a64:	4505                	li	a0,1
    80006a66:	ffffd097          	auipc	ra,0xffffd
    80006a6a:	c3e080e7          	jalr	-962(ra) # 800036a4 <argaddr>
    80006a6e:	0c054163          	bltz	a0,80006b30 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006a72:	10000613          	li	a2,256
    80006a76:	4581                	li	a1,0
    80006a78:	e4040513          	addi	a0,s0,-448
    80006a7c:	ffffa097          	auipc	ra,0xffffa
    80006a80:	242080e7          	jalr	578(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006a84:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006a88:	89a6                	mv	s3,s1
    80006a8a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006a8c:	02000a13          	li	s4,32
    80006a90:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006a94:	00391793          	slli	a5,s2,0x3
    80006a98:	e3040593          	addi	a1,s0,-464
    80006a9c:	e3843503          	ld	a0,-456(s0)
    80006aa0:	953e                	add	a0,a0,a5
    80006aa2:	ffffd097          	auipc	ra,0xffffd
    80006aa6:	b46080e7          	jalr	-1210(ra) # 800035e8 <fetchaddr>
    80006aaa:	02054a63          	bltz	a0,80006ade <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006aae:	e3043783          	ld	a5,-464(s0)
    80006ab2:	c3b9                	beqz	a5,80006af8 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006ab4:	ffffa097          	auipc	ra,0xffffa
    80006ab8:	01e080e7          	jalr	30(ra) # 80000ad2 <kalloc>
    80006abc:	85aa                	mv	a1,a0
    80006abe:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006ac2:	cd11                	beqz	a0,80006ade <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006ac4:	6605                	lui	a2,0x1
    80006ac6:	e3043503          	ld	a0,-464(s0)
    80006aca:	ffffd097          	auipc	ra,0xffffd
    80006ace:	b70080e7          	jalr	-1168(ra) # 8000363a <fetchstr>
    80006ad2:	00054663          	bltz	a0,80006ade <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006ad6:	0905                	addi	s2,s2,1
    80006ad8:	09a1                	addi	s3,s3,8
    80006ada:	fb491be3          	bne	s2,s4,80006a90 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006ade:	10048913          	addi	s2,s1,256
    80006ae2:	6088                	ld	a0,0(s1)
    80006ae4:	c529                	beqz	a0,80006b2e <sys_exec+0xf8>
    kfree(argv[i]);
    80006ae6:	ffffa097          	auipc	ra,0xffffa
    80006aea:	ef0080e7          	jalr	-272(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006aee:	04a1                	addi	s1,s1,8
    80006af0:	ff2499e3          	bne	s1,s2,80006ae2 <sys_exec+0xac>
  return -1;
    80006af4:	597d                	li	s2,-1
    80006af6:	a82d                	j	80006b30 <sys_exec+0xfa>
      argv[i] = 0;
    80006af8:	0a8e                	slli	s5,s5,0x3
    80006afa:	fc040793          	addi	a5,s0,-64
    80006afe:	9abe                	add	s5,s5,a5
    80006b00:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffcee80>
  int ret = exec(path, argv);
    80006b04:	e4040593          	addi	a1,s0,-448
    80006b08:	f4040513          	addi	a0,s0,-192
    80006b0c:	fffff097          	auipc	ra,0xfffff
    80006b10:	0f4080e7          	jalr	244(ra) # 80005c00 <exec>
    80006b14:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006b16:	10048993          	addi	s3,s1,256
    80006b1a:	6088                	ld	a0,0(s1)
    80006b1c:	c911                	beqz	a0,80006b30 <sys_exec+0xfa>
    kfree(argv[i]);
    80006b1e:	ffffa097          	auipc	ra,0xffffa
    80006b22:	eb8080e7          	jalr	-328(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006b26:	04a1                	addi	s1,s1,8
    80006b28:	ff3499e3          	bne	s1,s3,80006b1a <sys_exec+0xe4>
    80006b2c:	a011                	j	80006b30 <sys_exec+0xfa>
  return -1;
    80006b2e:	597d                	li	s2,-1
}
    80006b30:	854a                	mv	a0,s2
    80006b32:	60be                	ld	ra,456(sp)
    80006b34:	641e                	ld	s0,448(sp)
    80006b36:	74fa                	ld	s1,440(sp)
    80006b38:	795a                	ld	s2,432(sp)
    80006b3a:	79ba                	ld	s3,424(sp)
    80006b3c:	7a1a                	ld	s4,416(sp)
    80006b3e:	6afa                	ld	s5,408(sp)
    80006b40:	6179                	addi	sp,sp,464
    80006b42:	8082                	ret

0000000080006b44 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006b44:	7139                	addi	sp,sp,-64
    80006b46:	fc06                	sd	ra,56(sp)
    80006b48:	f822                	sd	s0,48(sp)
    80006b4a:	f426                	sd	s1,40(sp)
    80006b4c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006b4e:	ffffb097          	auipc	ra,0xffffb
    80006b52:	346080e7          	jalr	838(ra) # 80001e94 <myproc>
    80006b56:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006b58:	fd840593          	addi	a1,s0,-40
    80006b5c:	4501                	li	a0,0
    80006b5e:	ffffd097          	auipc	ra,0xffffd
    80006b62:	b46080e7          	jalr	-1210(ra) # 800036a4 <argaddr>
    return -1;
    80006b66:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006b68:	0e054063          	bltz	a0,80006c48 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006b6c:	fc840593          	addi	a1,s0,-56
    80006b70:	fd040513          	addi	a0,s0,-48
    80006b74:	fffff097          	auipc	ra,0xfffff
    80006b78:	d6a080e7          	jalr	-662(ra) # 800058de <pipealloc>
    return -1;
    80006b7c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006b7e:	0c054563          	bltz	a0,80006c48 <sys_pipe+0x104>
  fd0 = -1;
    80006b82:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006b86:	fd043503          	ld	a0,-48(s0)
    80006b8a:	fffff097          	auipc	ra,0xfffff
    80006b8e:	4e8080e7          	jalr	1256(ra) # 80006072 <fdalloc>
    80006b92:	fca42223          	sw	a0,-60(s0)
    80006b96:	08054c63          	bltz	a0,80006c2e <sys_pipe+0xea>
    80006b9a:	fc843503          	ld	a0,-56(s0)
    80006b9e:	fffff097          	auipc	ra,0xfffff
    80006ba2:	4d4080e7          	jalr	1236(ra) # 80006072 <fdalloc>
    80006ba6:	fca42023          	sw	a0,-64(s0)
    80006baa:	06054863          	bltz	a0,80006c1a <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006bae:	4691                	li	a3,4
    80006bb0:	fc440613          	addi	a2,s0,-60
    80006bb4:	fd843583          	ld	a1,-40(s0)
    80006bb8:	68a8                	ld	a0,80(s1)
    80006bba:	ffffa097          	auipc	ra,0xffffa
    80006bbe:	7fa080e7          	jalr	2042(ra) # 800013b4 <copyout>
    80006bc2:	02054063          	bltz	a0,80006be2 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006bc6:	4691                	li	a3,4
    80006bc8:	fc040613          	addi	a2,s0,-64
    80006bcc:	fd843583          	ld	a1,-40(s0)
    80006bd0:	0591                	addi	a1,a1,4
    80006bd2:	68a8                	ld	a0,80(s1)
    80006bd4:	ffffa097          	auipc	ra,0xffffa
    80006bd8:	7e0080e7          	jalr	2016(ra) # 800013b4 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006bdc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006bde:	06055563          	bgez	a0,80006c48 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006be2:	fc442783          	lw	a5,-60(s0)
    80006be6:	07e9                	addi	a5,a5,26
    80006be8:	078e                	slli	a5,a5,0x3
    80006bea:	97a6                	add	a5,a5,s1
    80006bec:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006bf0:	fc042503          	lw	a0,-64(s0)
    80006bf4:	0569                	addi	a0,a0,26
    80006bf6:	050e                	slli	a0,a0,0x3
    80006bf8:	9526                	add	a0,a0,s1
    80006bfa:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006bfe:	fd043503          	ld	a0,-48(s0)
    80006c02:	ffffe097          	auipc	ra,0xffffe
    80006c06:	7b6080e7          	jalr	1974(ra) # 800053b8 <fileclose>
    fileclose(wf);
    80006c0a:	fc843503          	ld	a0,-56(s0)
    80006c0e:	ffffe097          	auipc	ra,0xffffe
    80006c12:	7aa080e7          	jalr	1962(ra) # 800053b8 <fileclose>
    return -1;
    80006c16:	57fd                	li	a5,-1
    80006c18:	a805                	j	80006c48 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006c1a:	fc442783          	lw	a5,-60(s0)
    80006c1e:	0007c863          	bltz	a5,80006c2e <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006c22:	01a78513          	addi	a0,a5,26
    80006c26:	050e                	slli	a0,a0,0x3
    80006c28:	9526                	add	a0,a0,s1
    80006c2a:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006c2e:	fd043503          	ld	a0,-48(s0)
    80006c32:	ffffe097          	auipc	ra,0xffffe
    80006c36:	786080e7          	jalr	1926(ra) # 800053b8 <fileclose>
    fileclose(wf);
    80006c3a:	fc843503          	ld	a0,-56(s0)
    80006c3e:	ffffe097          	auipc	ra,0xffffe
    80006c42:	77a080e7          	jalr	1914(ra) # 800053b8 <fileclose>
    return -1;
    80006c46:	57fd                	li	a5,-1
}
    80006c48:	853e                	mv	a0,a5
    80006c4a:	70e2                	ld	ra,56(sp)
    80006c4c:	7442                	ld	s0,48(sp)
    80006c4e:	74a2                	ld	s1,40(sp)
    80006c50:	6121                	addi	sp,sp,64
    80006c52:	8082                	ret
	...

0000000080006c60 <kernelvec>:
    80006c60:	7111                	addi	sp,sp,-256
    80006c62:	e006                	sd	ra,0(sp)
    80006c64:	e40a                	sd	sp,8(sp)
    80006c66:	e80e                	sd	gp,16(sp)
    80006c68:	ec12                	sd	tp,24(sp)
    80006c6a:	f016                	sd	t0,32(sp)
    80006c6c:	f41a                	sd	t1,40(sp)
    80006c6e:	f81e                	sd	t2,48(sp)
    80006c70:	fc22                	sd	s0,56(sp)
    80006c72:	e0a6                	sd	s1,64(sp)
    80006c74:	e4aa                	sd	a0,72(sp)
    80006c76:	e8ae                	sd	a1,80(sp)
    80006c78:	ecb2                	sd	a2,88(sp)
    80006c7a:	f0b6                	sd	a3,96(sp)
    80006c7c:	f4ba                	sd	a4,104(sp)
    80006c7e:	f8be                	sd	a5,112(sp)
    80006c80:	fcc2                	sd	a6,120(sp)
    80006c82:	e146                	sd	a7,128(sp)
    80006c84:	e54a                	sd	s2,136(sp)
    80006c86:	e94e                	sd	s3,144(sp)
    80006c88:	ed52                	sd	s4,152(sp)
    80006c8a:	f156                	sd	s5,160(sp)
    80006c8c:	f55a                	sd	s6,168(sp)
    80006c8e:	f95e                	sd	s7,176(sp)
    80006c90:	fd62                	sd	s8,184(sp)
    80006c92:	e1e6                	sd	s9,192(sp)
    80006c94:	e5ea                	sd	s10,200(sp)
    80006c96:	e9ee                	sd	s11,208(sp)
    80006c98:	edf2                	sd	t3,216(sp)
    80006c9a:	f1f6                	sd	t4,224(sp)
    80006c9c:	f5fa                	sd	t5,232(sp)
    80006c9e:	f9fe                	sd	t6,240(sp)
    80006ca0:	815fc0ef          	jal	ra,800034b4 <kerneltrap>
    80006ca4:	6082                	ld	ra,0(sp)
    80006ca6:	6122                	ld	sp,8(sp)
    80006ca8:	61c2                	ld	gp,16(sp)
    80006caa:	7282                	ld	t0,32(sp)
    80006cac:	7322                	ld	t1,40(sp)
    80006cae:	73c2                	ld	t2,48(sp)
    80006cb0:	7462                	ld	s0,56(sp)
    80006cb2:	6486                	ld	s1,64(sp)
    80006cb4:	6526                	ld	a0,72(sp)
    80006cb6:	65c6                	ld	a1,80(sp)
    80006cb8:	6666                	ld	a2,88(sp)
    80006cba:	7686                	ld	a3,96(sp)
    80006cbc:	7726                	ld	a4,104(sp)
    80006cbe:	77c6                	ld	a5,112(sp)
    80006cc0:	7866                	ld	a6,120(sp)
    80006cc2:	688a                	ld	a7,128(sp)
    80006cc4:	692a                	ld	s2,136(sp)
    80006cc6:	69ca                	ld	s3,144(sp)
    80006cc8:	6a6a                	ld	s4,152(sp)
    80006cca:	7a8a                	ld	s5,160(sp)
    80006ccc:	7b2a                	ld	s6,168(sp)
    80006cce:	7bca                	ld	s7,176(sp)
    80006cd0:	7c6a                	ld	s8,184(sp)
    80006cd2:	6c8e                	ld	s9,192(sp)
    80006cd4:	6d2e                	ld	s10,200(sp)
    80006cd6:	6dce                	ld	s11,208(sp)
    80006cd8:	6e6e                	ld	t3,216(sp)
    80006cda:	7e8e                	ld	t4,224(sp)
    80006cdc:	7f2e                	ld	t5,232(sp)
    80006cde:	7fce                	ld	t6,240(sp)
    80006ce0:	6111                	addi	sp,sp,256
    80006ce2:	10200073          	sret
    80006ce6:	00000013          	nop
    80006cea:	00000013          	nop
    80006cee:	0001                	nop

0000000080006cf0 <timervec>:
    80006cf0:	34051573          	csrrw	a0,mscratch,a0
    80006cf4:	e10c                	sd	a1,0(a0)
    80006cf6:	e510                	sd	a2,8(a0)
    80006cf8:	e914                	sd	a3,16(a0)
    80006cfa:	6d0c                	ld	a1,24(a0)
    80006cfc:	7110                	ld	a2,32(a0)
    80006cfe:	6194                	ld	a3,0(a1)
    80006d00:	96b2                	add	a3,a3,a2
    80006d02:	e194                	sd	a3,0(a1)
    80006d04:	4589                	li	a1,2
    80006d06:	14459073          	csrw	sip,a1
    80006d0a:	6914                	ld	a3,16(a0)
    80006d0c:	6510                	ld	a2,8(a0)
    80006d0e:	610c                	ld	a1,0(a0)
    80006d10:	34051573          	csrrw	a0,mscratch,a0
    80006d14:	30200073          	mret
	...

0000000080006d1a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006d1a:	1141                	addi	sp,sp,-16
    80006d1c:	e422                	sd	s0,8(sp)
    80006d1e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006d20:	0c0007b7          	lui	a5,0xc000
    80006d24:	4705                	li	a4,1
    80006d26:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006d28:	c3d8                	sw	a4,4(a5)
}
    80006d2a:	6422                	ld	s0,8(sp)
    80006d2c:	0141                	addi	sp,sp,16
    80006d2e:	8082                	ret

0000000080006d30 <plicinithart>:

void
plicinithart(void)
{
    80006d30:	1141                	addi	sp,sp,-16
    80006d32:	e406                	sd	ra,8(sp)
    80006d34:	e022                	sd	s0,0(sp)
    80006d36:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006d38:	ffffb097          	auipc	ra,0xffffb
    80006d3c:	130080e7          	jalr	304(ra) # 80001e68 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006d40:	0085171b          	slliw	a4,a0,0x8
    80006d44:	0c0027b7          	lui	a5,0xc002
    80006d48:	97ba                	add	a5,a5,a4
    80006d4a:	40200713          	li	a4,1026
    80006d4e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006d52:	00d5151b          	slliw	a0,a0,0xd
    80006d56:	0c2017b7          	lui	a5,0xc201
    80006d5a:	953e                	add	a0,a0,a5
    80006d5c:	00052023          	sw	zero,0(a0)
}
    80006d60:	60a2                	ld	ra,8(sp)
    80006d62:	6402                	ld	s0,0(sp)
    80006d64:	0141                	addi	sp,sp,16
    80006d66:	8082                	ret

0000000080006d68 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006d68:	1141                	addi	sp,sp,-16
    80006d6a:	e406                	sd	ra,8(sp)
    80006d6c:	e022                	sd	s0,0(sp)
    80006d6e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006d70:	ffffb097          	auipc	ra,0xffffb
    80006d74:	0f8080e7          	jalr	248(ra) # 80001e68 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006d78:	00d5179b          	slliw	a5,a0,0xd
    80006d7c:	0c201537          	lui	a0,0xc201
    80006d80:	953e                	add	a0,a0,a5
  return irq;
}
    80006d82:	4148                	lw	a0,4(a0)
    80006d84:	60a2                	ld	ra,8(sp)
    80006d86:	6402                	ld	s0,0(sp)
    80006d88:	0141                	addi	sp,sp,16
    80006d8a:	8082                	ret

0000000080006d8c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006d8c:	1101                	addi	sp,sp,-32
    80006d8e:	ec06                	sd	ra,24(sp)
    80006d90:	e822                	sd	s0,16(sp)
    80006d92:	e426                	sd	s1,8(sp)
    80006d94:	1000                	addi	s0,sp,32
    80006d96:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006d98:	ffffb097          	auipc	ra,0xffffb
    80006d9c:	0d0080e7          	jalr	208(ra) # 80001e68 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006da0:	00d5151b          	slliw	a0,a0,0xd
    80006da4:	0c2017b7          	lui	a5,0xc201
    80006da8:	97aa                	add	a5,a5,a0
    80006daa:	c3c4                	sw	s1,4(a5)
}
    80006dac:	60e2                	ld	ra,24(sp)
    80006dae:	6442                	ld	s0,16(sp)
    80006db0:	64a2                	ld	s1,8(sp)
    80006db2:	6105                	addi	sp,sp,32
    80006db4:	8082                	ret

0000000080006db6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006db6:	1141                	addi	sp,sp,-16
    80006db8:	e406                	sd	ra,8(sp)
    80006dba:	e022                	sd	s0,0(sp)
    80006dbc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006dbe:	479d                	li	a5,7
    80006dc0:	06a7c963          	blt	a5,a0,80006e32 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006dc4:	00026797          	auipc	a5,0x26
    80006dc8:	23c78793          	addi	a5,a5,572 # 8002d000 <disk>
    80006dcc:	00a78733          	add	a4,a5,a0
    80006dd0:	6789                	lui	a5,0x2
    80006dd2:	97ba                	add	a5,a5,a4
    80006dd4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006dd8:	e7ad                	bnez	a5,80006e42 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006dda:	00451793          	slli	a5,a0,0x4
    80006dde:	00028717          	auipc	a4,0x28
    80006de2:	22270713          	addi	a4,a4,546 # 8002f000 <disk+0x2000>
    80006de6:	6314                	ld	a3,0(a4)
    80006de8:	96be                	add	a3,a3,a5
    80006dea:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006dee:	6314                	ld	a3,0(a4)
    80006df0:	96be                	add	a3,a3,a5
    80006df2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006df6:	6314                	ld	a3,0(a4)
    80006df8:	96be                	add	a3,a3,a5
    80006dfa:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006dfe:	6318                	ld	a4,0(a4)
    80006e00:	97ba                	add	a5,a5,a4
    80006e02:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006e06:	00026797          	auipc	a5,0x26
    80006e0a:	1fa78793          	addi	a5,a5,506 # 8002d000 <disk>
    80006e0e:	97aa                	add	a5,a5,a0
    80006e10:	6509                	lui	a0,0x2
    80006e12:	953e                	add	a0,a0,a5
    80006e14:	4785                	li	a5,1
    80006e16:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006e1a:	00028517          	auipc	a0,0x28
    80006e1e:	1fe50513          	addi	a0,a0,510 # 8002f018 <disk+0x2018>
    80006e22:	ffffb097          	auipc	ra,0xffffb
    80006e26:	7a0080e7          	jalr	1952(ra) # 800025c2 <wakeup>
}
    80006e2a:	60a2                	ld	ra,8(sp)
    80006e2c:	6402                	ld	s0,0(sp)
    80006e2e:	0141                	addi	sp,sp,16
    80006e30:	8082                	ret
    panic("free_desc 1");
    80006e32:	00003517          	auipc	a0,0x3
    80006e36:	17650513          	addi	a0,a0,374 # 80009fa8 <syscalls+0x3d0>
    80006e3a:	ffff9097          	auipc	ra,0xffff9
    80006e3e:	6f0080e7          	jalr	1776(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006e42:	00003517          	auipc	a0,0x3
    80006e46:	17650513          	addi	a0,a0,374 # 80009fb8 <syscalls+0x3e0>
    80006e4a:	ffff9097          	auipc	ra,0xffff9
    80006e4e:	6e0080e7          	jalr	1760(ra) # 8000052a <panic>

0000000080006e52 <virtio_disk_init>:
{
    80006e52:	1101                	addi	sp,sp,-32
    80006e54:	ec06                	sd	ra,24(sp)
    80006e56:	e822                	sd	s0,16(sp)
    80006e58:	e426                	sd	s1,8(sp)
    80006e5a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006e5c:	00003597          	auipc	a1,0x3
    80006e60:	16c58593          	addi	a1,a1,364 # 80009fc8 <syscalls+0x3f0>
    80006e64:	00028517          	auipc	a0,0x28
    80006e68:	2c450513          	addi	a0,a0,708 # 8002f128 <disk+0x2128>
    80006e6c:	ffffa097          	auipc	ra,0xffffa
    80006e70:	cc6080e7          	jalr	-826(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006e74:	100017b7          	lui	a5,0x10001
    80006e78:	4398                	lw	a4,0(a5)
    80006e7a:	2701                	sext.w	a4,a4
    80006e7c:	747277b7          	lui	a5,0x74727
    80006e80:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006e84:	0ef71163          	bne	a4,a5,80006f66 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006e88:	100017b7          	lui	a5,0x10001
    80006e8c:	43dc                	lw	a5,4(a5)
    80006e8e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006e90:	4705                	li	a4,1
    80006e92:	0ce79a63          	bne	a5,a4,80006f66 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006e96:	100017b7          	lui	a5,0x10001
    80006e9a:	479c                	lw	a5,8(a5)
    80006e9c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006e9e:	4709                	li	a4,2
    80006ea0:	0ce79363          	bne	a5,a4,80006f66 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006ea4:	100017b7          	lui	a5,0x10001
    80006ea8:	47d8                	lw	a4,12(a5)
    80006eaa:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006eac:	554d47b7          	lui	a5,0x554d4
    80006eb0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006eb4:	0af71963          	bne	a4,a5,80006f66 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006eb8:	100017b7          	lui	a5,0x10001
    80006ebc:	4705                	li	a4,1
    80006ebe:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006ec0:	470d                	li	a4,3
    80006ec2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006ec4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006ec6:	c7ffe737          	lui	a4,0xc7ffe
    80006eca:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fce75f>
    80006ece:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006ed0:	2701                	sext.w	a4,a4
    80006ed2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006ed4:	472d                	li	a4,11
    80006ed6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006ed8:	473d                	li	a4,15
    80006eda:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006edc:	6705                	lui	a4,0x1
    80006ede:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006ee0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006ee4:	5bdc                	lw	a5,52(a5)
    80006ee6:	2781                	sext.w	a5,a5
  if(max == 0)
    80006ee8:	c7d9                	beqz	a5,80006f76 <virtio_disk_init+0x124>
  if(max < NUM)
    80006eea:	471d                	li	a4,7
    80006eec:	08f77d63          	bgeu	a4,a5,80006f86 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006ef0:	100014b7          	lui	s1,0x10001
    80006ef4:	47a1                	li	a5,8
    80006ef6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006ef8:	6609                	lui	a2,0x2
    80006efa:	4581                	li	a1,0
    80006efc:	00026517          	auipc	a0,0x26
    80006f00:	10450513          	addi	a0,a0,260 # 8002d000 <disk>
    80006f04:	ffffa097          	auipc	ra,0xffffa
    80006f08:	dba080e7          	jalr	-582(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006f0c:	00026717          	auipc	a4,0x26
    80006f10:	0f470713          	addi	a4,a4,244 # 8002d000 <disk>
    80006f14:	00c75793          	srli	a5,a4,0xc
    80006f18:	2781                	sext.w	a5,a5
    80006f1a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006f1c:	00028797          	auipc	a5,0x28
    80006f20:	0e478793          	addi	a5,a5,228 # 8002f000 <disk+0x2000>
    80006f24:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006f26:	00026717          	auipc	a4,0x26
    80006f2a:	15a70713          	addi	a4,a4,346 # 8002d080 <disk+0x80>
    80006f2e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006f30:	00027717          	auipc	a4,0x27
    80006f34:	0d070713          	addi	a4,a4,208 # 8002e000 <disk+0x1000>
    80006f38:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006f3a:	4705                	li	a4,1
    80006f3c:	00e78c23          	sb	a4,24(a5)
    80006f40:	00e78ca3          	sb	a4,25(a5)
    80006f44:	00e78d23          	sb	a4,26(a5)
    80006f48:	00e78da3          	sb	a4,27(a5)
    80006f4c:	00e78e23          	sb	a4,28(a5)
    80006f50:	00e78ea3          	sb	a4,29(a5)
    80006f54:	00e78f23          	sb	a4,30(a5)
    80006f58:	00e78fa3          	sb	a4,31(a5)
}
    80006f5c:	60e2                	ld	ra,24(sp)
    80006f5e:	6442                	ld	s0,16(sp)
    80006f60:	64a2                	ld	s1,8(sp)
    80006f62:	6105                	addi	sp,sp,32
    80006f64:	8082                	ret
    panic("could not find virtio disk");
    80006f66:	00003517          	auipc	a0,0x3
    80006f6a:	07250513          	addi	a0,a0,114 # 80009fd8 <syscalls+0x400>
    80006f6e:	ffff9097          	auipc	ra,0xffff9
    80006f72:	5bc080e7          	jalr	1468(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006f76:	00003517          	auipc	a0,0x3
    80006f7a:	08250513          	addi	a0,a0,130 # 80009ff8 <syscalls+0x420>
    80006f7e:	ffff9097          	auipc	ra,0xffff9
    80006f82:	5ac080e7          	jalr	1452(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006f86:	00003517          	auipc	a0,0x3
    80006f8a:	09250513          	addi	a0,a0,146 # 8000a018 <syscalls+0x440>
    80006f8e:	ffff9097          	auipc	ra,0xffff9
    80006f92:	59c080e7          	jalr	1436(ra) # 8000052a <panic>

0000000080006f96 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006f96:	7119                	addi	sp,sp,-128
    80006f98:	fc86                	sd	ra,120(sp)
    80006f9a:	f8a2                	sd	s0,112(sp)
    80006f9c:	f4a6                	sd	s1,104(sp)
    80006f9e:	f0ca                	sd	s2,96(sp)
    80006fa0:	ecce                	sd	s3,88(sp)
    80006fa2:	e8d2                	sd	s4,80(sp)
    80006fa4:	e4d6                	sd	s5,72(sp)
    80006fa6:	e0da                	sd	s6,64(sp)
    80006fa8:	fc5e                	sd	s7,56(sp)
    80006faa:	f862                	sd	s8,48(sp)
    80006fac:	f466                	sd	s9,40(sp)
    80006fae:	f06a                	sd	s10,32(sp)
    80006fb0:	ec6e                	sd	s11,24(sp)
    80006fb2:	0100                	addi	s0,sp,128
    80006fb4:	8aaa                	mv	s5,a0
    80006fb6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006fb8:	00c52c83          	lw	s9,12(a0)
    80006fbc:	001c9c9b          	slliw	s9,s9,0x1
    80006fc0:	1c82                	slli	s9,s9,0x20
    80006fc2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006fc6:	00028517          	auipc	a0,0x28
    80006fca:	16250513          	addi	a0,a0,354 # 8002f128 <disk+0x2128>
    80006fce:	ffffa097          	auipc	ra,0xffffa
    80006fd2:	bf4080e7          	jalr	-1036(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006fd6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006fd8:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006fda:	00026c17          	auipc	s8,0x26
    80006fde:	026c0c13          	addi	s8,s8,38 # 8002d000 <disk>
    80006fe2:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006fe4:	4b0d                	li	s6,3
    80006fe6:	a0ad                	j	80007050 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006fe8:	00fc0733          	add	a4,s8,a5
    80006fec:	975e                	add	a4,a4,s7
    80006fee:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006ff2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006ff4:	0207c563          	bltz	a5,8000701e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006ff8:	2905                	addiw	s2,s2,1
    80006ffa:	0611                	addi	a2,a2,4
    80006ffc:	19690d63          	beq	s2,s6,80007196 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80007000:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80007002:	00028717          	auipc	a4,0x28
    80007006:	01670713          	addi	a4,a4,22 # 8002f018 <disk+0x2018>
    8000700a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000700c:	00074683          	lbu	a3,0(a4)
    80007010:	fee1                	bnez	a3,80006fe8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80007012:	2785                	addiw	a5,a5,1
    80007014:	0705                	addi	a4,a4,1
    80007016:	fe979be3          	bne	a5,s1,8000700c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000701a:	57fd                	li	a5,-1
    8000701c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000701e:	01205d63          	blez	s2,80007038 <virtio_disk_rw+0xa2>
    80007022:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80007024:	000a2503          	lw	a0,0(s4)
    80007028:	00000097          	auipc	ra,0x0
    8000702c:	d8e080e7          	jalr	-626(ra) # 80006db6 <free_desc>
      for(int j = 0; j < i; j++)
    80007030:	2d85                	addiw	s11,s11,1
    80007032:	0a11                	addi	s4,s4,4
    80007034:	ffb918e3          	bne	s2,s11,80007024 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80007038:	00028597          	auipc	a1,0x28
    8000703c:	0f058593          	addi	a1,a1,240 # 8002f128 <disk+0x2128>
    80007040:	00028517          	auipc	a0,0x28
    80007044:	fd850513          	addi	a0,a0,-40 # 8002f018 <disk+0x2018>
    80007048:	ffffb097          	auipc	ra,0xffffb
    8000704c:	3ee080e7          	jalr	1006(ra) # 80002436 <sleep>
  for(int i = 0; i < 3; i++){
    80007050:	f8040a13          	addi	s4,s0,-128
{
    80007054:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80007056:	894e                	mv	s2,s3
    80007058:	b765                	j	80007000 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000705a:	00028697          	auipc	a3,0x28
    8000705e:	fa66b683          	ld	a3,-90(a3) # 8002f000 <disk+0x2000>
    80007062:	96ba                	add	a3,a3,a4
    80007064:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80007068:	00026817          	auipc	a6,0x26
    8000706c:	f9880813          	addi	a6,a6,-104 # 8002d000 <disk>
    80007070:	00028697          	auipc	a3,0x28
    80007074:	f9068693          	addi	a3,a3,-112 # 8002f000 <disk+0x2000>
    80007078:	6290                	ld	a2,0(a3)
    8000707a:	963a                	add	a2,a2,a4
    8000707c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80007080:	0015e593          	ori	a1,a1,1
    80007084:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80007088:	f8842603          	lw	a2,-120(s0)
    8000708c:	628c                	ld	a1,0(a3)
    8000708e:	972e                	add	a4,a4,a1
    80007090:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80007094:	20050593          	addi	a1,a0,512
    80007098:	0592                	slli	a1,a1,0x4
    8000709a:	95c2                	add	a1,a1,a6
    8000709c:	577d                	li	a4,-1
    8000709e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800070a2:	00461713          	slli	a4,a2,0x4
    800070a6:	6290                	ld	a2,0(a3)
    800070a8:	963a                	add	a2,a2,a4
    800070aa:	03078793          	addi	a5,a5,48
    800070ae:	97c2                	add	a5,a5,a6
    800070b0:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800070b2:	629c                	ld	a5,0(a3)
    800070b4:	97ba                	add	a5,a5,a4
    800070b6:	4605                	li	a2,1
    800070b8:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800070ba:	629c                	ld	a5,0(a3)
    800070bc:	97ba                	add	a5,a5,a4
    800070be:	4809                	li	a6,2
    800070c0:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800070c4:	629c                	ld	a5,0(a3)
    800070c6:	973e                	add	a4,a4,a5
    800070c8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800070cc:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800070d0:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800070d4:	6698                	ld	a4,8(a3)
    800070d6:	00275783          	lhu	a5,2(a4)
    800070da:	8b9d                	andi	a5,a5,7
    800070dc:	0786                	slli	a5,a5,0x1
    800070de:	97ba                	add	a5,a5,a4
    800070e0:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    800070e4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800070e8:	6698                	ld	a4,8(a3)
    800070ea:	00275783          	lhu	a5,2(a4)
    800070ee:	2785                	addiw	a5,a5,1
    800070f0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800070f4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800070f8:	100017b7          	lui	a5,0x10001
    800070fc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80007100:	004aa783          	lw	a5,4(s5)
    80007104:	02c79163          	bne	a5,a2,80007126 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80007108:	00028917          	auipc	s2,0x28
    8000710c:	02090913          	addi	s2,s2,32 # 8002f128 <disk+0x2128>
  while(b->disk == 1) {
    80007110:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80007112:	85ca                	mv	a1,s2
    80007114:	8556                	mv	a0,s5
    80007116:	ffffb097          	auipc	ra,0xffffb
    8000711a:	320080e7          	jalr	800(ra) # 80002436 <sleep>
  while(b->disk == 1) {
    8000711e:	004aa783          	lw	a5,4(s5)
    80007122:	fe9788e3          	beq	a5,s1,80007112 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80007126:	f8042903          	lw	s2,-128(s0)
    8000712a:	20090793          	addi	a5,s2,512
    8000712e:	00479713          	slli	a4,a5,0x4
    80007132:	00026797          	auipc	a5,0x26
    80007136:	ece78793          	addi	a5,a5,-306 # 8002d000 <disk>
    8000713a:	97ba                	add	a5,a5,a4
    8000713c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80007140:	00028997          	auipc	s3,0x28
    80007144:	ec098993          	addi	s3,s3,-320 # 8002f000 <disk+0x2000>
    80007148:	00491713          	slli	a4,s2,0x4
    8000714c:	0009b783          	ld	a5,0(s3)
    80007150:	97ba                	add	a5,a5,a4
    80007152:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80007156:	854a                	mv	a0,s2
    80007158:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000715c:	00000097          	auipc	ra,0x0
    80007160:	c5a080e7          	jalr	-934(ra) # 80006db6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80007164:	8885                	andi	s1,s1,1
    80007166:	f0ed                	bnez	s1,80007148 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80007168:	00028517          	auipc	a0,0x28
    8000716c:	fc050513          	addi	a0,a0,-64 # 8002f128 <disk+0x2128>
    80007170:	ffffa097          	auipc	ra,0xffffa
    80007174:	b06080e7          	jalr	-1274(ra) # 80000c76 <release>
}
    80007178:	70e6                	ld	ra,120(sp)
    8000717a:	7446                	ld	s0,112(sp)
    8000717c:	74a6                	ld	s1,104(sp)
    8000717e:	7906                	ld	s2,96(sp)
    80007180:	69e6                	ld	s3,88(sp)
    80007182:	6a46                	ld	s4,80(sp)
    80007184:	6aa6                	ld	s5,72(sp)
    80007186:	6b06                	ld	s6,64(sp)
    80007188:	7be2                	ld	s7,56(sp)
    8000718a:	7c42                	ld	s8,48(sp)
    8000718c:	7ca2                	ld	s9,40(sp)
    8000718e:	7d02                	ld	s10,32(sp)
    80007190:	6de2                	ld	s11,24(sp)
    80007192:	6109                	addi	sp,sp,128
    80007194:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007196:	f8042503          	lw	a0,-128(s0)
    8000719a:	20050793          	addi	a5,a0,512
    8000719e:	0792                	slli	a5,a5,0x4
  if(write)
    800071a0:	00026817          	auipc	a6,0x26
    800071a4:	e6080813          	addi	a6,a6,-416 # 8002d000 <disk>
    800071a8:	00f80733          	add	a4,a6,a5
    800071ac:	01a036b3          	snez	a3,s10
    800071b0:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800071b4:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800071b8:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800071bc:	7679                	lui	a2,0xffffe
    800071be:	963e                	add	a2,a2,a5
    800071c0:	00028697          	auipc	a3,0x28
    800071c4:	e4068693          	addi	a3,a3,-448 # 8002f000 <disk+0x2000>
    800071c8:	6298                	ld	a4,0(a3)
    800071ca:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800071cc:	0a878593          	addi	a1,a5,168
    800071d0:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    800071d2:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800071d4:	6298                	ld	a4,0(a3)
    800071d6:	9732                	add	a4,a4,a2
    800071d8:	45c1                	li	a1,16
    800071da:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800071dc:	6298                	ld	a4,0(a3)
    800071de:	9732                	add	a4,a4,a2
    800071e0:	4585                	li	a1,1
    800071e2:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800071e6:	f8442703          	lw	a4,-124(s0)
    800071ea:	628c                	ld	a1,0(a3)
    800071ec:	962e                	add	a2,a2,a1
    800071ee:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffce00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    800071f2:	0712                	slli	a4,a4,0x4
    800071f4:	6290                	ld	a2,0(a3)
    800071f6:	963a                	add	a2,a2,a4
    800071f8:	058a8593          	addi	a1,s5,88
    800071fc:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800071fe:	6294                	ld	a3,0(a3)
    80007200:	96ba                	add	a3,a3,a4
    80007202:	40000613          	li	a2,1024
    80007206:	c690                	sw	a2,8(a3)
  if(write)
    80007208:	e40d19e3          	bnez	s10,8000705a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000720c:	00028697          	auipc	a3,0x28
    80007210:	df46b683          	ld	a3,-524(a3) # 8002f000 <disk+0x2000>
    80007214:	96ba                	add	a3,a3,a4
    80007216:	4609                	li	a2,2
    80007218:	00c69623          	sh	a2,12(a3)
    8000721c:	b5b1                	j	80007068 <virtio_disk_rw+0xd2>

000000008000721e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000721e:	1101                	addi	sp,sp,-32
    80007220:	ec06                	sd	ra,24(sp)
    80007222:	e822                	sd	s0,16(sp)
    80007224:	e426                	sd	s1,8(sp)
    80007226:	e04a                	sd	s2,0(sp)
    80007228:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000722a:	00028517          	auipc	a0,0x28
    8000722e:	efe50513          	addi	a0,a0,-258 # 8002f128 <disk+0x2128>
    80007232:	ffffa097          	auipc	ra,0xffffa
    80007236:	990080e7          	jalr	-1648(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000723a:	10001737          	lui	a4,0x10001
    8000723e:	533c                	lw	a5,96(a4)
    80007240:	8b8d                	andi	a5,a5,3
    80007242:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80007244:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80007248:	00028797          	auipc	a5,0x28
    8000724c:	db878793          	addi	a5,a5,-584 # 8002f000 <disk+0x2000>
    80007250:	6b94                	ld	a3,16(a5)
    80007252:	0207d703          	lhu	a4,32(a5)
    80007256:	0026d783          	lhu	a5,2(a3)
    8000725a:	06f70163          	beq	a4,a5,800072bc <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000725e:	00026917          	auipc	s2,0x26
    80007262:	da290913          	addi	s2,s2,-606 # 8002d000 <disk>
    80007266:	00028497          	auipc	s1,0x28
    8000726a:	d9a48493          	addi	s1,s1,-614 # 8002f000 <disk+0x2000>
    __sync_synchronize();
    8000726e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007272:	6898                	ld	a4,16(s1)
    80007274:	0204d783          	lhu	a5,32(s1)
    80007278:	8b9d                	andi	a5,a5,7
    8000727a:	078e                	slli	a5,a5,0x3
    8000727c:	97ba                	add	a5,a5,a4
    8000727e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80007280:	20078713          	addi	a4,a5,512
    80007284:	0712                	slli	a4,a4,0x4
    80007286:	974a                	add	a4,a4,s2
    80007288:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000728c:	e731                	bnez	a4,800072d8 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000728e:	20078793          	addi	a5,a5,512
    80007292:	0792                	slli	a5,a5,0x4
    80007294:	97ca                	add	a5,a5,s2
    80007296:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007298:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000729c:	ffffb097          	auipc	ra,0xffffb
    800072a0:	326080e7          	jalr	806(ra) # 800025c2 <wakeup>

    disk.used_idx += 1;
    800072a4:	0204d783          	lhu	a5,32(s1)
    800072a8:	2785                	addiw	a5,a5,1
    800072aa:	17c2                	slli	a5,a5,0x30
    800072ac:	93c1                	srli	a5,a5,0x30
    800072ae:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800072b2:	6898                	ld	a4,16(s1)
    800072b4:	00275703          	lhu	a4,2(a4)
    800072b8:	faf71be3          	bne	a4,a5,8000726e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800072bc:	00028517          	auipc	a0,0x28
    800072c0:	e6c50513          	addi	a0,a0,-404 # 8002f128 <disk+0x2128>
    800072c4:	ffffa097          	auipc	ra,0xffffa
    800072c8:	9b2080e7          	jalr	-1614(ra) # 80000c76 <release>
}
    800072cc:	60e2                	ld	ra,24(sp)
    800072ce:	6442                	ld	s0,16(sp)
    800072d0:	64a2                	ld	s1,8(sp)
    800072d2:	6902                	ld	s2,0(sp)
    800072d4:	6105                	addi	sp,sp,32
    800072d6:	8082                	ret
      panic("virtio_disk_intr status");
    800072d8:	00003517          	auipc	a0,0x3
    800072dc:	d6050513          	addi	a0,a0,-672 # 8000a038 <syscalls+0x460>
    800072e0:	ffff9097          	auipc	ra,0xffff9
    800072e4:	24a080e7          	jalr	586(ra) # 8000052a <panic>
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
