
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
    80000068:	b2c78793          	addi	a5,a5,-1236 # 80006b90 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffcb7ff>
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
    80000122:	510080e7          	jalr	1296(ra) # 8000262e <either_copyin>
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
    8000017c:	00012517          	auipc	a0,0x12
    80000180:	00450513          	addi	a0,a0,4 # 80012180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a3e080e7          	jalr	-1474(ra) # 80000bc2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00012497          	auipc	s1,0x12
    80000190:	ff448493          	addi	s1,s1,-12 # 80012180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000194:	00012917          	auipc	s2,0x12
    80000198:	08490913          	addi	s2,s2,132 # 80012218 <cons+0x98>
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
    800001b6:	b80080e7          	jalr	-1152(ra) # 80001d32 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	068080e7          	jalr	104(ra) # 8000222a <sleep>
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
    80000202:	3da080e7          	jalr	986(ra) # 800025d8 <either_copyout>
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
    80000212:	00012517          	auipc	a0,0x12
    80000216:	f6e50513          	addi	a0,a0,-146 # 80012180 <cons>
    8000021a:	00001097          	auipc	ra,0x1
    8000021e:	a5c080e7          	jalr	-1444(ra) # 80000c76 <release>

  return target - n;
    80000222:	413b053b          	subw	a0,s6,s3
    80000226:	a811                	j	8000023a <consoleread+0xe4>
        release(&cons.lock);
    80000228:	00012517          	auipc	a0,0x12
    8000022c:	f5850513          	addi	a0,a0,-168 # 80012180 <cons>
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
    8000025e:	00012717          	auipc	a4,0x12
    80000262:	faf72d23          	sw	a5,-70(a4) # 80012218 <cons+0x98>
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
    800002b8:	00012517          	auipc	a0,0x12
    800002bc:	ec850513          	addi	a0,a0,-312 # 80012180 <cons>
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
    800002e2:	3a6080e7          	jalr	934(ra) # 80002684 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002e6:	00012517          	auipc	a0,0x12
    800002ea:	e9a50513          	addi	a0,a0,-358 # 80012180 <cons>
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
    8000030a:	00012717          	auipc	a4,0x12
    8000030e:	e7670713          	addi	a4,a4,-394 # 80012180 <cons>
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
    80000334:	00012797          	auipc	a5,0x12
    80000338:	e4c78793          	addi	a5,a5,-436 # 80012180 <cons>
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
    80000362:	00012797          	auipc	a5,0x12
    80000366:	eb67a783          	lw	a5,-330(a5) # 80012218 <cons+0x98>
    8000036a:	0807879b          	addiw	a5,a5,128
    8000036e:	f6f61ce3          	bne	a2,a5,800002e6 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000372:	863e                	mv	a2,a5
    80000374:	a07d                	j	80000422 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000376:	00012717          	auipc	a4,0x12
    8000037a:	e0a70713          	addi	a4,a4,-502 # 80012180 <cons>
    8000037e:	0a072783          	lw	a5,160(a4)
    80000382:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000386:	00012497          	auipc	s1,0x12
    8000038a:	dfa48493          	addi	s1,s1,-518 # 80012180 <cons>
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
    800003c2:	00012717          	auipc	a4,0x12
    800003c6:	dbe70713          	addi	a4,a4,-578 # 80012180 <cons>
    800003ca:	0a072783          	lw	a5,160(a4)
    800003ce:	09c72703          	lw	a4,156(a4)
    800003d2:	f0f70ae3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003d6:	37fd                	addiw	a5,a5,-1
    800003d8:	00012717          	auipc	a4,0x12
    800003dc:	e4f72423          	sw	a5,-440(a4) # 80012220 <cons+0xa0>
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
    800003fe:	00012797          	auipc	a5,0x12
    80000402:	d8278793          	addi	a5,a5,-638 # 80012180 <cons>
    80000406:	0a07a703          	lw	a4,160(a5)
    8000040a:	0017069b          	addiw	a3,a4,1
    8000040e:	0006861b          	sext.w	a2,a3
    80000412:	0ad7a023          	sw	a3,160(a5)
    80000416:	07f77713          	andi	a4,a4,127
    8000041a:	97ba                	add	a5,a5,a4
    8000041c:	4729                	li	a4,10
    8000041e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000422:	00012797          	auipc	a5,0x12
    80000426:	dec7ad23          	sw	a2,-518(a5) # 8001221c <cons+0x9c>
        wakeup(&cons.r);
    8000042a:	00012517          	auipc	a0,0x12
    8000042e:	dee50513          	addi	a0,a0,-530 # 80012218 <cons+0x98>
    80000432:	00002097          	auipc	ra,0x2
    80000436:	f84080e7          	jalr	-124(ra) # 800023b6 <wakeup>
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
    8000044c:	00012517          	auipc	a0,0x12
    80000450:	d3450513          	addi	a0,a0,-716 # 80012180 <cons>
    80000454:	00000097          	auipc	ra,0x0
    80000458:	6de080e7          	jalr	1758(ra) # 80000b32 <initlock>

  uartinit();
    8000045c:	00000097          	auipc	ra,0x0
    80000460:	32a080e7          	jalr	810(ra) # 80000786 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000464:	0002f797          	auipc	a5,0x2f
    80000468:	8b478793          	addi	a5,a5,-1868 # 8002ed18 <devsw>
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
    80000536:	00012797          	auipc	a5,0x12
    8000053a:	d007a523          	sw	zero,-758(a5) # 80012240 <pr+0x18>
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
    8000055c:	14050513          	addi	a0,a0,320 # 80009698 <digits+0x658>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	014080e7          	jalr	20(ra) # 80000574 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000568:	4785                	li	a5,1
    8000056a:	0000a717          	auipc	a4,0xa
    8000056e:	a8f72b23          	sw	a5,-1386(a4) # 8000a000 <panicked>
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
    800005a6:	00012d97          	auipc	s11,0x12
    800005aa:	c9adad83          	lw	s11,-870(s11) # 80012240 <pr+0x18>
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
    800005e4:	00012517          	auipc	a0,0x12
    800005e8:	c4450513          	addi	a0,a0,-956 # 80012228 <pr>
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
    80000742:	00012517          	auipc	a0,0x12
    80000746:	ae650513          	addi	a0,a0,-1306 # 80012228 <pr>
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
    8000075e:	00012497          	auipc	s1,0x12
    80000762:	aca48493          	addi	s1,s1,-1334 # 80012228 <pr>
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
    800007be:	00012517          	auipc	a0,0x12
    800007c2:	a8a50513          	addi	a0,a0,-1398 # 80012248 <uart_tx_lock>
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
    800007ea:	0000a797          	auipc	a5,0xa
    800007ee:	8167a783          	lw	a5,-2026(a5) # 8000a000 <panicked>
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
    80000822:	00009797          	auipc	a5,0x9
    80000826:	7e67b783          	ld	a5,2022(a5) # 8000a008 <uart_tx_r>
    8000082a:	00009717          	auipc	a4,0x9
    8000082e:	7e673703          	ld	a4,2022(a4) # 8000a010 <uart_tx_w>
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
    8000084c:	00012a17          	auipc	s4,0x12
    80000850:	9fca0a13          	addi	s4,s4,-1540 # 80012248 <uart_tx_lock>
    uart_tx_r += 1;
    80000854:	00009497          	auipc	s1,0x9
    80000858:	7b448493          	addi	s1,s1,1972 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000085c:	00009997          	auipc	s3,0x9
    80000860:	7b498993          	addi	s3,s3,1972 # 8000a010 <uart_tx_w>
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
    80000882:	b38080e7          	jalr	-1224(ra) # 800023b6 <wakeup>
    
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
    800008ba:	00012517          	auipc	a0,0x12
    800008be:	98e50513          	addi	a0,a0,-1650 # 80012248 <uart_tx_lock>
    800008c2:	00000097          	auipc	ra,0x0
    800008c6:	300080e7          	jalr	768(ra) # 80000bc2 <acquire>
  if(panicked){
    800008ca:	00009797          	auipc	a5,0x9
    800008ce:	7367a783          	lw	a5,1846(a5) # 8000a000 <panicked>
    800008d2:	c391                	beqz	a5,800008d6 <uartputc+0x2e>
    for(;;)
    800008d4:	a001                	j	800008d4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008d6:	00009717          	auipc	a4,0x9
    800008da:	73a73703          	ld	a4,1850(a4) # 8000a010 <uart_tx_w>
    800008de:	00009797          	auipc	a5,0x9
    800008e2:	72a7b783          	ld	a5,1834(a5) # 8000a008 <uart_tx_r>
    800008e6:	02078793          	addi	a5,a5,32
    800008ea:	02e79b63          	bne	a5,a4,80000920 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008ee:	00012997          	auipc	s3,0x12
    800008f2:	95a98993          	addi	s3,s3,-1702 # 80012248 <uart_tx_lock>
    800008f6:	00009497          	auipc	s1,0x9
    800008fa:	71248493          	addi	s1,s1,1810 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fe:	00009917          	auipc	s2,0x9
    80000902:	71290913          	addi	s2,s2,1810 # 8000a010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000906:	85ce                	mv	a1,s3
    80000908:	8526                	mv	a0,s1
    8000090a:	00002097          	auipc	ra,0x2
    8000090e:	920080e7          	jalr	-1760(ra) # 8000222a <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000912:	00093703          	ld	a4,0(s2)
    80000916:	609c                	ld	a5,0(s1)
    80000918:	02078793          	addi	a5,a5,32
    8000091c:	fee785e3          	beq	a5,a4,80000906 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000920:	00012497          	auipc	s1,0x12
    80000924:	92848493          	addi	s1,s1,-1752 # 80012248 <uart_tx_lock>
    80000928:	01f77793          	andi	a5,a4,31
    8000092c:	97a6                	add	a5,a5,s1
    8000092e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000932:	0705                	addi	a4,a4,1
    80000934:	00009797          	auipc	a5,0x9
    80000938:	6ce7be23          	sd	a4,1756(a5) # 8000a010 <uart_tx_w>
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
    800009a8:	00012497          	auipc	s1,0x12
    800009ac:	8a048493          	addi	s1,s1,-1888 # 80012248 <uart_tx_lock>
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
    800009ea:	00032797          	auipc	a5,0x32
    800009ee:	61678793          	addi	a5,a5,1558 # 80033000 <end>
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
    80000a0a:	00012917          	auipc	s2,0x12
    80000a0e:	87690913          	addi	s2,s2,-1930 # 80012280 <kmem>
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
    80000aa6:	00011517          	auipc	a0,0x11
    80000aaa:	7da50513          	addi	a0,a0,2010 # 80012280 <kmem>
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	084080e7          	jalr	132(ra) # 80000b32 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ab6:	45c5                	li	a1,17
    80000ab8:	05ee                	slli	a1,a1,0x1b
    80000aba:	00032517          	auipc	a0,0x32
    80000abe:	54650513          	addi	a0,a0,1350 # 80033000 <end>
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
    80000adc:	00011497          	auipc	s1,0x11
    80000ae0:	7a448493          	addi	s1,s1,1956 # 80012280 <kmem>
    80000ae4:	8526                	mv	a0,s1
    80000ae6:	00000097          	auipc	ra,0x0
    80000aea:	0dc080e7          	jalr	220(ra) # 80000bc2 <acquire>
  r = kmem.freelist;
    80000aee:	6c84                	ld	s1,24(s1)
  if(r)
    80000af0:	c885                	beqz	s1,80000b20 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af2:	609c                	ld	a5,0(s1)
    80000af4:	00011517          	auipc	a0,0x11
    80000af8:	78c50513          	addi	a0,a0,1932 # 80012280 <kmem>
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
    80000b20:	00011517          	auipc	a0,0x11
    80000b24:	76050513          	addi	a0,a0,1888 # 80012280 <kmem>
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
    80000b60:	1ba080e7          	jalr	442(ra) # 80001d16 <mycpu>
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
    80000b92:	188080e7          	jalr	392(ra) # 80001d16 <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	17c080e7          	jalr	380(ra) # 80001d16 <mycpu>
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
    80000bb6:	164080e7          	jalr	356(ra) # 80001d16 <mycpu>
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
    80000bf6:	124080e7          	jalr	292(ra) # 80001d16 <mycpu>
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
    80000c22:	0f8080e7          	jalr	248(ra) # 80001d16 <mycpu>
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
    80000e78:	e92080e7          	jalr	-366(ra) # 80001d06 <cpuid>
    __sync_synchronize();


    started = 1;
  } else {
    while(started == 0)
    80000e7c:	00009717          	auipc	a4,0x9
    80000e80:	19c70713          	addi	a4,a4,412 # 8000a018 <started>
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
    80000e94:	e76080e7          	jalr	-394(ra) # 80001d06 <cpuid>
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
    80000eb6:	168080e7          	jalr	360(ra) # 8000301a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00006097          	auipc	ra,0x6
    80000ebe:	d16080e7          	jalr	-746(ra) # 80006bd0 <plicinithart>
  }

  scheduler();        
    80000ec2:	00002097          	auipc	ra,0x2
    80000ec6:	ea4080e7          	jalr	-348(ra) # 80002d66 <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00008517          	auipc	a0,0x8
    80000ede:	7be50513          	addi	a0,a0,1982 # 80009698 <digits+0x658>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00008517          	auipc	a0,0x8
    80000eee:	1b650513          	addi	a0,a0,438 # 800090a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00008517          	auipc	a0,0x8
    80000efe:	79e50513          	addi	a0,a0,1950 # 80009698 <digits+0x658>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    kinit();         // physical page allocator
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	b8c080e7          	jalr	-1140(ra) # 80000a96 <kinit>
    kvminit();       // create kernel page table
    80000f12:	00000097          	auipc	ra,0x0
    80000f16:	33c080e7          	jalr	828(ra) # 8000124e <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	068080e7          	jalr	104(ra) # 80000f82 <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	d34080e7          	jalr	-716(ra) # 80001c56 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	0c8080e7          	jalr	200(ra) # 80002ff2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	0e8080e7          	jalr	232(ra) # 8000301a <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00006097          	auipc	ra,0x6
    80000f3e:	c80080e7          	jalr	-896(ra) # 80006bba <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00006097          	auipc	ra,0x6
    80000f46:	c8e080e7          	jalr	-882(ra) # 80006bd0 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00003097          	auipc	ra,0x3
    80000f4e:	91a080e7          	jalr	-1766(ra) # 80003864 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	fac080e7          	jalr	-84(ra) # 80003efe <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	26c080e7          	jalr	620(ra) # 800051c6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00006097          	auipc	ra,0x6
    80000f66:	d90080e7          	jalr	-624(ra) # 80006cf2 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	0b8080e7          	jalr	184(ra) # 80002022 <userinit>
    __sync_synchronize();
    80000f72:	0ff0000f          	fence
    started = 1;
    80000f76:	4785                	li	a5,1
    80000f78:	00009717          	auipc	a4,0x9
    80000f7c:	0af72023          	sw	a5,160(a4) # 8000a018 <started>
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
    80000f88:	00009797          	auipc	a5,0x9
    80000f8c:	0987b783          	ld	a5,152(a5) # 8000a020 <kernel_pagetable>
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
// Look up a virtual address, return the physical address,
// or 0 if not mapped.
// Can only be used to look up user pages.
uint64
walkaddr(pagetable_t pagetable, uint64 va, int to_page_out)
{
    8000104c:	7179                	addi	sp,sp,-48
    8000104e:	f406                	sd	ra,40(sp)
    80001050:	f022                	sd	s0,32(sp)
    80001052:	ec26                	sd	s1,24(sp)
    80001054:	e84a                	sd	s2,16(sp)
    80001056:	e44e                	sd	s3,8(sp)
    80001058:	1800                	addi	s0,sp,48
    8000105a:	892a                	mv	s2,a0
    8000105c:	84ae                	mv	s1,a1
    8000105e:	89b2                	mv	s3,a2
  
  // check if we have space in phsical addres or in case the

  pte_t *pte;
  uint64 pa;
  struct proc *p = myproc();
    80001060:	00001097          	auipc	ra,0x1
    80001064:	cd2080e7          	jalr	-814(ra) # 80001d32 <myproc>

  if (va >= MAXVA)
    80001068:	57fd                	li	a5,-1
    8000106a:	83e9                	srli	a5,a5,0x1a
    return 0;
    8000106c:	4501                	li	a0,0
  if (va >= MAXVA)
    8000106e:	0097f963          	bgeu	a5,s1,80001080 <walkaddr+0x34>
      panic("walkaddr: fack pte is not valid ");
    *pte &= ~PTE_V;  // page table entry now invalid
    *pte |= PTE_PG; // paged out to secondary storage
  }
  return pa;
}
    80001072:	70a2                	ld	ra,40(sp)
    80001074:	7402                	ld	s0,32(sp)
    80001076:	64e2                	ld	s1,24(sp)
    80001078:	6942                	ld	s2,16(sp)
    8000107a:	69a2                	ld	s3,8(sp)
    8000107c:	6145                	addi	sp,sp,48
    8000107e:	8082                	ret
  pte = walk(pagetable, va, 0);
    80001080:	4601                	li	a2,0
    80001082:	85a6                	mv	a1,s1
    80001084:	854a                	mv	a0,s2
    80001086:	00000097          	auipc	ra,0x0
    8000108a:	f20080e7          	jalr	-224(ra) # 80000fa6 <walk>
    8000108e:	872a                	mv	a4,a0
  if (pte == 0 || !(*pte & PTE_V)){
    80001090:	c11d                	beqz	a0,800010b6 <walkaddr+0x6a>
    80001092:	6114                	ld	a3,0(a0)
  if ((*pte & PTE_U) == 0)
    80001094:	0116f613          	andi	a2,a3,17
    80001098:	47c5                	li	a5,17
    return 0;
    8000109a:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    8000109c:	fcf61be3          	bne	a2,a5,80001072 <walkaddr+0x26>
  pa = PTE2PA(*pte);
    800010a0:	00a6d793          	srli	a5,a3,0xa
    800010a4:	00c79513          	slli	a0,a5,0xc
  if (to_page_out)
    800010a8:	fc0985e3          	beqz	s3,80001072 <walkaddr+0x26>
    *pte &= ~PTE_V;  // page table entry now invalid
    800010ac:	9af9                	andi	a3,a3,-2
    *pte |= PTE_PG; // paged out to secondary storage
    800010ae:	2006e693          	ori	a3,a3,512
    800010b2:	e314                	sd	a3,0(a4)
    800010b4:	bf7d                	j	80001072 <walkaddr+0x26>
      return 0;
    800010b6:	4501                	li	a0,0
    800010b8:	bf6d                	j	80001072 <walkaddr+0x26>

00000000800010ba <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010ba:	715d                	addi	sp,sp,-80
    800010bc:	e486                	sd	ra,72(sp)
    800010be:	e0a2                	sd	s0,64(sp)
    800010c0:	fc26                	sd	s1,56(sp)
    800010c2:	f84a                	sd	s2,48(sp)
    800010c4:	f44e                	sd	s3,40(sp)
    800010c6:	f052                	sd	s4,32(sp)
    800010c8:	ec56                	sd	s5,24(sp)
    800010ca:	e85a                	sd	s6,16(sp)
    800010cc:	e45e                	sd	s7,8(sp)
    800010ce:	0880                	addi	s0,sp,80
    800010d0:	8aaa                	mv	s5,a0
    800010d2:	8b3a                	mv	s6,a4

  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010d4:	777d                	lui	a4,0xfffff
    800010d6:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010da:	167d                	addi	a2,a2,-1
    800010dc:	00b609b3          	add	s3,a2,a1
    800010e0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010e4:	893e                	mv	s2,a5
    800010e6:	40f68a33          	sub	s4,a3,a5
    if (*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    800010ea:	6b85                	lui	s7,0x1
    800010ec:	012a04b3          	add	s1,s4,s2
    if ((pte = walk(pagetable, a, 1)) == 0)
    800010f0:	4605                	li	a2,1
    800010f2:	85ca                	mv	a1,s2
    800010f4:	8556                	mv	a0,s5
    800010f6:	00000097          	auipc	ra,0x0
    800010fa:	eb0080e7          	jalr	-336(ra) # 80000fa6 <walk>
    800010fe:	c51d                	beqz	a0,8000112c <mappages+0x72>
    if (*pte & PTE_V)
    80001100:	611c                	ld	a5,0(a0)
    80001102:	8b85                	andi	a5,a5,1
    80001104:	ef81                	bnez	a5,8000111c <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001106:	80b1                	srli	s1,s1,0xc
    80001108:	04aa                	slli	s1,s1,0xa
    8000110a:	0164e4b3          	or	s1,s1,s6
    8000110e:	0014e493          	ori	s1,s1,1
    80001112:	e104                	sd	s1,0(a0)
    if (a == last)
    80001114:	03390863          	beq	s2,s3,80001144 <mappages+0x8a>
    a += PGSIZE;
    80001118:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    8000111a:	bfc9                	j	800010ec <mappages+0x32>
      panic("remap");
    8000111c:	00008517          	auipc	a0,0x8
    80001120:	fbc50513          	addi	a0,a0,-68 # 800090d8 <digits+0x98>
    80001124:	fffff097          	auipc	ra,0xfffff
    80001128:	406080e7          	jalr	1030(ra) # 8000052a <panic>
      return -1;
    8000112c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000112e:	60a6                	ld	ra,72(sp)
    80001130:	6406                	ld	s0,64(sp)
    80001132:	74e2                	ld	s1,56(sp)
    80001134:	7942                	ld	s2,48(sp)
    80001136:	79a2                	ld	s3,40(sp)
    80001138:	7a02                	ld	s4,32(sp)
    8000113a:	6ae2                	ld	s5,24(sp)
    8000113c:	6b42                	ld	s6,16(sp)
    8000113e:	6ba2                	ld	s7,8(sp)
    80001140:	6161                	addi	sp,sp,80
    80001142:	8082                	ret
  return 0;
    80001144:	4501                	li	a0,0
    80001146:	b7e5                	j	8000112e <mappages+0x74>

0000000080001148 <kvmmap>:
{
    80001148:	1141                	addi	sp,sp,-16
    8000114a:	e406                	sd	ra,8(sp)
    8000114c:	e022                	sd	s0,0(sp)
    8000114e:	0800                	addi	s0,sp,16
    80001150:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001152:	86b2                	mv	a3,a2
    80001154:	863e                	mv	a2,a5
    80001156:	00000097          	auipc	ra,0x0
    8000115a:	f64080e7          	jalr	-156(ra) # 800010ba <mappages>
    8000115e:	e509                	bnez	a0,80001168 <kvmmap+0x20>
}
    80001160:	60a2                	ld	ra,8(sp)
    80001162:	6402                	ld	s0,0(sp)
    80001164:	0141                	addi	sp,sp,16
    80001166:	8082                	ret
    panic("kvmmap");
    80001168:	00008517          	auipc	a0,0x8
    8000116c:	f7850513          	addi	a0,a0,-136 # 800090e0 <digits+0xa0>
    80001170:	fffff097          	auipc	ra,0xfffff
    80001174:	3ba080e7          	jalr	954(ra) # 8000052a <panic>

0000000080001178 <kvmmake>:
{
    80001178:	1101                	addi	sp,sp,-32
    8000117a:	ec06                	sd	ra,24(sp)
    8000117c:	e822                	sd	s0,16(sp)
    8000117e:	e426                	sd	s1,8(sp)
    80001180:	e04a                	sd	s2,0(sp)
    80001182:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    80001184:	00000097          	auipc	ra,0x0
    80001188:	94e080e7          	jalr	-1714(ra) # 80000ad2 <kalloc>
    8000118c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000118e:	6605                	lui	a2,0x1
    80001190:	4581                	li	a1,0
    80001192:	00000097          	auipc	ra,0x0
    80001196:	b2c080e7          	jalr	-1236(ra) # 80000cbe <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000119a:	4719                	li	a4,6
    8000119c:	6685                	lui	a3,0x1
    8000119e:	10000637          	lui	a2,0x10000
    800011a2:	100005b7          	lui	a1,0x10000
    800011a6:	8526                	mv	a0,s1
    800011a8:	00000097          	auipc	ra,0x0
    800011ac:	fa0080e7          	jalr	-96(ra) # 80001148 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011b0:	4719                	li	a4,6
    800011b2:	6685                	lui	a3,0x1
    800011b4:	10001637          	lui	a2,0x10001
    800011b8:	100015b7          	lui	a1,0x10001
    800011bc:	8526                	mv	a0,s1
    800011be:	00000097          	auipc	ra,0x0
    800011c2:	f8a080e7          	jalr	-118(ra) # 80001148 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011c6:	4719                	li	a4,6
    800011c8:	004006b7          	lui	a3,0x400
    800011cc:	0c000637          	lui	a2,0xc000
    800011d0:	0c0005b7          	lui	a1,0xc000
    800011d4:	8526                	mv	a0,s1
    800011d6:	00000097          	auipc	ra,0x0
    800011da:	f72080e7          	jalr	-142(ra) # 80001148 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    800011de:	00008917          	auipc	s2,0x8
    800011e2:	e2290913          	addi	s2,s2,-478 # 80009000 <etext>
    800011e6:	4729                	li	a4,10
    800011e8:	80008697          	auipc	a3,0x80008
    800011ec:	e1868693          	addi	a3,a3,-488 # 9000 <_entry-0x7fff7000>
    800011f0:	4605                	li	a2,1
    800011f2:	067e                	slli	a2,a2,0x1f
    800011f4:	85b2                	mv	a1,a2
    800011f6:	8526                	mv	a0,s1
    800011f8:	00000097          	auipc	ra,0x0
    800011fc:	f50080e7          	jalr	-176(ra) # 80001148 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext, PTE_R | PTE_W);
    80001200:	4719                	li	a4,6
    80001202:	46c5                	li	a3,17
    80001204:	06ee                	slli	a3,a3,0x1b
    80001206:	412686b3          	sub	a3,a3,s2
    8000120a:	864a                	mv	a2,s2
    8000120c:	85ca                	mv	a1,s2
    8000120e:	8526                	mv	a0,s1
    80001210:	00000097          	auipc	ra,0x0
    80001214:	f38080e7          	jalr	-200(ra) # 80001148 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001218:	4729                	li	a4,10
    8000121a:	6685                	lui	a3,0x1
    8000121c:	00007617          	auipc	a2,0x7
    80001220:	de460613          	addi	a2,a2,-540 # 80008000 <_trampoline>
    80001224:	040005b7          	lui	a1,0x4000
    80001228:	15fd                	addi	a1,a1,-1
    8000122a:	05b2                	slli	a1,a1,0xc
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	f1a080e7          	jalr	-230(ra) # 80001148 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001236:	8526                	mv	a0,s1
    80001238:	00001097          	auipc	ra,0x1
    8000123c:	988080e7          	jalr	-1656(ra) # 80001bc0 <proc_mapstacks>
}
    80001240:	8526                	mv	a0,s1
    80001242:	60e2                	ld	ra,24(sp)
    80001244:	6442                	ld	s0,16(sp)
    80001246:	64a2                	ld	s1,8(sp)
    80001248:	6902                	ld	s2,0(sp)
    8000124a:	6105                	addi	sp,sp,32
    8000124c:	8082                	ret

000000008000124e <kvminit>:
{
    8000124e:	1141                	addi	sp,sp,-16
    80001250:	e406                	sd	ra,8(sp)
    80001252:	e022                	sd	s0,0(sp)
    80001254:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001256:	00000097          	auipc	ra,0x0
    8000125a:	f22080e7          	jalr	-222(ra) # 80001178 <kvmmake>
    8000125e:	00009797          	auipc	a5,0x9
    80001262:	dca7b123          	sd	a0,-574(a5) # 8000a020 <kernel_pagetable>
}
    80001266:	60a2                	ld	ra,8(sp)
    80001268:	6402                	ld	s0,0(sp)
    8000126a:	0141                	addi	sp,sp,16
    8000126c:	8082                	ret

000000008000126e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000126e:	1101                	addi	sp,sp,-32
    80001270:	ec06                	sd	ra,24(sp)
    80001272:	e822                	sd	s0,16(sp)
    80001274:	e426                	sd	s1,8(sp)
    80001276:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80001278:	00000097          	auipc	ra,0x0
    8000127c:	85a080e7          	jalr	-1958(ra) # 80000ad2 <kalloc>
    80001280:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001282:	c519                	beqz	a0,80001290 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001284:	6605                	lui	a2,0x1
    80001286:	4581                	li	a1,0
    80001288:	00000097          	auipc	ra,0x0
    8000128c:	a36080e7          	jalr	-1482(ra) # 80000cbe <memset>
  return pagetable;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvminit>:

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
  char *mem;

  if (sz >= PGSIZE)
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67863          	bgeu	a2,a5,800012fe <uvminit+0x62>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800012b8:	00000097          	auipc	ra,0x0
    800012bc:	81a080e7          	jalr	-2022(ra) # 80000ad2 <kalloc>
    800012c0:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012c2:	6605                	lui	a2,0x1
    800012c4:	4581                	li	a1,0
    800012c6:	00000097          	auipc	ra,0x0
    800012ca:	9f8080e7          	jalr	-1544(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W | PTE_R | PTE_X | PTE_U);
    800012ce:	4779                	li	a4,30
    800012d0:	86ca                	mv	a3,s2
    800012d2:	6605                	lui	a2,0x1
    800012d4:	4581                	li	a1,0
    800012d6:	8552                	mv	a0,s4
    800012d8:	00000097          	auipc	ra,0x0
    800012dc:	de2080e7          	jalr	-542(ra) # 800010ba <mappages>
  memmove(mem, src, sz);
    800012e0:	8626                	mv	a2,s1
    800012e2:	85ce                	mv	a1,s3
    800012e4:	854a                	mv	a0,s2
    800012e6:	00000097          	auipc	ra,0x0
    800012ea:	a34080e7          	jalr	-1484(ra) # 80000d1a <memmove>
}
    800012ee:	70a2                	ld	ra,40(sp)
    800012f0:	7402                	ld	s0,32(sp)
    800012f2:	64e2                	ld	s1,24(sp)
    800012f4:	6942                	ld	s2,16(sp)
    800012f6:	69a2                	ld	s3,8(sp)
    800012f8:	6a02                	ld	s4,0(sp)
    800012fa:	6145                	addi	sp,sp,48
    800012fc:	8082                	ret
    panic("inituvm: more than a page");
    800012fe:	00008517          	auipc	a0,0x8
    80001302:	dea50513          	addi	a0,a0,-534 # 800090e8 <digits+0xa8>
    80001306:	fffff097          	auipc	ra,0xfffff
    8000130a:	224080e7          	jalr	548(ra) # 8000052a <panic>

000000008000130e <freewalk>:
}

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void freewalk(pagetable_t pagetable)
{
    8000130e:	7179                	addi	sp,sp,-48
    80001310:	f406                	sd	ra,40(sp)
    80001312:	f022                	sd	s0,32(sp)
    80001314:	ec26                	sd	s1,24(sp)
    80001316:	e84a                	sd	s2,16(sp)
    80001318:	e44e                	sd	s3,8(sp)
    8000131a:	e052                	sd	s4,0(sp)
    8000131c:	1800                	addi	s0,sp,48
    8000131e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++)
    80001320:	84aa                	mv	s1,a0
    80001322:	6905                	lui	s2,0x1
    80001324:	992a                	add	s2,s2,a0
  {
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80001326:	4985                	li	s3,1
    80001328:	a821                	j	80001340 <freewalk+0x32>
    {
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000132a:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000132c:	0532                	slli	a0,a0,0xc
    8000132e:	00000097          	auipc	ra,0x0
    80001332:	fe0080e7          	jalr	-32(ra) # 8000130e <freewalk>
      pagetable[i] = 0;
    80001336:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++)
    8000133a:	04a1                	addi	s1,s1,8
    8000133c:	03248163          	beq	s1,s2,8000135e <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001340:	6088                	ld	a0,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80001342:	00f57793          	andi	a5,a0,15
    80001346:	ff3782e3          	beq	a5,s3,8000132a <freewalk+0x1c>
    }
    else if (pte & PTE_V)
    8000134a:	8905                	andi	a0,a0,1
    8000134c:	d57d                	beqz	a0,8000133a <freewalk+0x2c>
    {
      panic("freewalk: leaf");
    8000134e:	00008517          	auipc	a0,0x8
    80001352:	dba50513          	addi	a0,a0,-582 # 80009108 <digits+0xc8>
    80001356:	fffff097          	auipc	ra,0xfffff
    8000135a:	1d4080e7          	jalr	468(ra) # 8000052a <panic>
    }
  }
  kfree((void *)pagetable);
    8000135e:	8552                	mv	a0,s4
    80001360:	fffff097          	auipc	ra,0xfffff
    80001364:	676080e7          	jalr	1654(ra) # 800009d6 <kfree>
}
    80001368:	70a2                	ld	ra,40(sp)
    8000136a:	7402                	ld	s0,32(sp)
    8000136c:	64e2                	ld	s1,24(sp)
    8000136e:	6942                	ld	s2,16(sp)
    80001370:	69a2                	ld	s3,8(sp)
    80001372:	6a02                	ld	s4,0(sp)
    80001374:	6145                	addi	sp,sp,48
    80001376:	8082                	ret

0000000080001378 <uvmclear>:
}

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void uvmclear(pagetable_t pagetable, uint64 va)
{
    80001378:	1141                	addi	sp,sp,-16
    8000137a:	e406                	sd	ra,8(sp)
    8000137c:	e022                	sd	s0,0(sp)
    8000137e:	0800                	addi	s0,sp,16

  pte_t *pte;

  pte = walk(pagetable, va, 0);
    80001380:	4601                	li	a2,0
    80001382:	00000097          	auipc	ra,0x0
    80001386:	c24080e7          	jalr	-988(ra) # 80000fa6 <walk>
  if (pte == 0)
    8000138a:	c901                	beqz	a0,8000139a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000138c:	611c                	ld	a5,0(a0)
    8000138e:	9bbd                	andi	a5,a5,-17
    80001390:	e11c                	sd	a5,0(a0)
}
    80001392:	60a2                	ld	ra,8(sp)
    80001394:	6402                	ld	s0,0(sp)
    80001396:	0141                	addi	sp,sp,16
    80001398:	8082                	ret
    panic("uvmclear");
    8000139a:	00008517          	auipc	a0,0x8
    8000139e:	d7e50513          	addi	a0,a0,-642 # 80009118 <digits+0xd8>
    800013a2:	fffff097          	auipc	ra,0xfffff
    800013a6:	188080e7          	jalr	392(ra) # 8000052a <panic>

00000000800013aa <copyout>:
// Copy len bytes from src to virtual address dstva in a given page table.
// Return 0 on success, -1 on error.
int copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  while (len > 0)
    800013aa:	caa5                	beqz	a3,8000141a <copyout+0x70>
{
    800013ac:	715d                	addi	sp,sp,-80
    800013ae:	e486                	sd	ra,72(sp)
    800013b0:	e0a2                	sd	s0,64(sp)
    800013b2:	fc26                	sd	s1,56(sp)
    800013b4:	f84a                	sd	s2,48(sp)
    800013b6:	f44e                	sd	s3,40(sp)
    800013b8:	f052                	sd	s4,32(sp)
    800013ba:	ec56                	sd	s5,24(sp)
    800013bc:	e85a                	sd	s6,16(sp)
    800013be:	e45e                	sd	s7,8(sp)
    800013c0:	e062                	sd	s8,0(sp)
    800013c2:	0880                	addi	s0,sp,80
    800013c4:	8b2a                	mv	s6,a0
    800013c6:	8c2e                	mv	s8,a1
    800013c8:	8a32                	mv	s4,a2
    800013ca:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(dstva);
    800013cc:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0, 0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800013ce:	6a85                	lui	s5,0x1
    800013d0:	a015                	j	800013f4 <copyout+0x4a>
    if (n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800013d2:	9562                	add	a0,a0,s8
    800013d4:	0004861b          	sext.w	a2,s1
    800013d8:	85d2                	mv	a1,s4
    800013da:	41250533          	sub	a0,a0,s2
    800013de:	00000097          	auipc	ra,0x0
    800013e2:	93c080e7          	jalr	-1732(ra) # 80000d1a <memmove>

    len -= n;
    800013e6:	409989b3          	sub	s3,s3,s1
    src += n;
    800013ea:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800013ec:	01590c33          	add	s8,s2,s5
  while (len > 0)
    800013f0:	02098363          	beqz	s3,80001416 <copyout+0x6c>
    va0 = PGROUNDDOWN(dstva);
    800013f4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0, 0);
    800013f8:	4601                	li	a2,0
    800013fa:	85ca                	mv	a1,s2
    800013fc:	855a                	mv	a0,s6
    800013fe:	00000097          	auipc	ra,0x0
    80001402:	c4e080e7          	jalr	-946(ra) # 8000104c <walkaddr>
    if (pa0 == 0)
    80001406:	cd01                	beqz	a0,8000141e <copyout+0x74>
    n = PGSIZE - (dstva - va0);
    80001408:	418904b3          	sub	s1,s2,s8
    8000140c:	94d6                	add	s1,s1,s5
    if (n > len)
    8000140e:	fc99f2e3          	bgeu	s3,s1,800013d2 <copyout+0x28>
    80001412:	84ce                	mv	s1,s3
    80001414:	bf7d                	j	800013d2 <copyout+0x28>
  }

  return 0;
    80001416:	4501                	li	a0,0
    80001418:	a021                	j	80001420 <copyout+0x76>
    8000141a:	4501                	li	a0,0
}
    8000141c:	8082                	ret
      return -1;
    8000141e:	557d                	li	a0,-1
}
    80001420:	60a6                	ld	ra,72(sp)
    80001422:	6406                	ld	s0,64(sp)
    80001424:	74e2                	ld	s1,56(sp)
    80001426:	7942                	ld	s2,48(sp)
    80001428:	79a2                	ld	s3,40(sp)
    8000142a:	7a02                	ld	s4,32(sp)
    8000142c:	6ae2                	ld	s5,24(sp)
    8000142e:	6b42                	ld	s6,16(sp)
    80001430:	6ba2                	ld	s7,8(sp)
    80001432:	6c02                	ld	s8,0(sp)
    80001434:	6161                	addi	sp,sp,80
    80001436:	8082                	ret

0000000080001438 <copyin>:
int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{

  uint64 n, va0, pa0;

  while (len > 0)
    80001438:	caad                	beqz	a3,800014aa <copyin+0x72>
{
    8000143a:	715d                	addi	sp,sp,-80
    8000143c:	e486                	sd	ra,72(sp)
    8000143e:	e0a2                	sd	s0,64(sp)
    80001440:	fc26                	sd	s1,56(sp)
    80001442:	f84a                	sd	s2,48(sp)
    80001444:	f44e                	sd	s3,40(sp)
    80001446:	f052                	sd	s4,32(sp)
    80001448:	ec56                	sd	s5,24(sp)
    8000144a:	e85a                	sd	s6,16(sp)
    8000144c:	e45e                	sd	s7,8(sp)
    8000144e:	e062                	sd	s8,0(sp)
    80001450:	0880                	addi	s0,sp,80
    80001452:	8b2a                	mv	s6,a0
    80001454:	8a2e                	mv	s4,a1
    80001456:	8c32                	mv	s8,a2
    80001458:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(srcva);
    8000145a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0, 0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000145c:	6a85                	lui	s5,0x1
    8000145e:	a01d                	j	80001484 <copyin+0x4c>
    if (n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001460:	018505b3          	add	a1,a0,s8
    80001464:	0004861b          	sext.w	a2,s1
    80001468:	412585b3          	sub	a1,a1,s2
    8000146c:	8552                	mv	a0,s4
    8000146e:	00000097          	auipc	ra,0x0
    80001472:	8ac080e7          	jalr	-1876(ra) # 80000d1a <memmove>

    len -= n;
    80001476:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000147a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000147c:	01590c33          	add	s8,s2,s5
  while (len > 0)
    80001480:	02098363          	beqz	s3,800014a6 <copyin+0x6e>
    va0 = PGROUNDDOWN(srcva);
    80001484:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0, 0);
    80001488:	4601                	li	a2,0
    8000148a:	85ca                	mv	a1,s2
    8000148c:	855a                	mv	a0,s6
    8000148e:	00000097          	auipc	ra,0x0
    80001492:	bbe080e7          	jalr	-1090(ra) # 8000104c <walkaddr>
    if (pa0 == 0)
    80001496:	cd01                	beqz	a0,800014ae <copyin+0x76>
    n = PGSIZE - (srcva - va0);
    80001498:	418904b3          	sub	s1,s2,s8
    8000149c:	94d6                	add	s1,s1,s5
    if (n > len)
    8000149e:	fc99f1e3          	bgeu	s3,s1,80001460 <copyin+0x28>
    800014a2:	84ce                	mv	s1,s3
    800014a4:	bf75                	j	80001460 <copyin+0x28>
  }

  return 0;
    800014a6:	4501                	li	a0,0
    800014a8:	a021                	j	800014b0 <copyin+0x78>
    800014aa:	4501                	li	a0,0
}
    800014ac:	8082                	ret
      return -1;
    800014ae:	557d                	li	a0,-1
}
    800014b0:	60a6                	ld	ra,72(sp)
    800014b2:	6406                	ld	s0,64(sp)
    800014b4:	74e2                	ld	s1,56(sp)
    800014b6:	7942                	ld	s2,48(sp)
    800014b8:	79a2                	ld	s3,40(sp)
    800014ba:	7a02                	ld	s4,32(sp)
    800014bc:	6ae2                	ld	s5,24(sp)
    800014be:	6b42                	ld	s6,16(sp)
    800014c0:	6ba2                	ld	s7,8(sp)
    800014c2:	6c02                	ld	s8,0(sp)
    800014c4:	6161                	addi	sp,sp,80
    800014c6:	8082                	ret

00000000800014c8 <copyinstr>:
int copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0)
    800014c8:	c6cd                	beqz	a3,80001572 <copyinstr+0xaa>
{
    800014ca:	715d                	addi	sp,sp,-80
    800014cc:	e486                	sd	ra,72(sp)
    800014ce:	e0a2                	sd	s0,64(sp)
    800014d0:	fc26                	sd	s1,56(sp)
    800014d2:	f84a                	sd	s2,48(sp)
    800014d4:	f44e                	sd	s3,40(sp)
    800014d6:	f052                	sd	s4,32(sp)
    800014d8:	ec56                	sd	s5,24(sp)
    800014da:	e85a                	sd	s6,16(sp)
    800014dc:	e45e                	sd	s7,8(sp)
    800014de:	0880                	addi	s0,sp,80
    800014e0:	8a2a                	mv	s4,a0
    800014e2:	8b2e                	mv	s6,a1
    800014e4:	8bb2                	mv	s7,a2
    800014e6:	84b6                	mv	s1,a3
  {
    va0 = PGROUNDDOWN(srcva);
    800014e8:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0, 0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014ea:	6985                	lui	s3,0x1
    800014ec:	a035                	j	80001518 <copyinstr+0x50>
    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0)
    {
      if (*p == '\0')
      {
        *dst = '\0';
    800014ee:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800014f2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null)
    800014f4:	0017b793          	seqz	a5,a5
    800014f8:	40f00533          	neg	a0,a5
  }
  else
  {
    return -1;
  }
} 
    800014fc:	60a6                	ld	ra,72(sp)
    800014fe:	6406                	ld	s0,64(sp)
    80001500:	74e2                	ld	s1,56(sp)
    80001502:	7942                	ld	s2,48(sp)
    80001504:	79a2                	ld	s3,40(sp)
    80001506:	7a02                	ld	s4,32(sp)
    80001508:	6ae2                	ld	s5,24(sp)
    8000150a:	6b42                	ld	s6,16(sp)
    8000150c:	6ba2                	ld	s7,8(sp)
    8000150e:	6161                	addi	sp,sp,80
    80001510:	8082                	ret
    srcva = va0 + PGSIZE;
    80001512:	01390bb3          	add	s7,s2,s3
  while (got_null == 0 && max > 0)
    80001516:	c8b1                	beqz	s1,8000156a <copyinstr+0xa2>
    va0 = PGROUNDDOWN(srcva);
    80001518:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0, 0);
    8000151c:	4601                	li	a2,0
    8000151e:	85ca                	mv	a1,s2
    80001520:	8552                	mv	a0,s4
    80001522:	00000097          	auipc	ra,0x0
    80001526:	b2a080e7          	jalr	-1238(ra) # 8000104c <walkaddr>
    if (pa0 == 0)
    8000152a:	c131                	beqz	a0,8000156e <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    8000152c:	41790833          	sub	a6,s2,s7
    80001530:	984e                	add	a6,a6,s3
    if (n > max)
    80001532:	0104f363          	bgeu	s1,a6,80001538 <copyinstr+0x70>
    80001536:	8826                	mv	a6,s1
    char *p = (char *)(pa0 + (srcva - va0));
    80001538:	955e                	add	a0,a0,s7
    8000153a:	41250533          	sub	a0,a0,s2
    while (n > 0)
    8000153e:	fc080ae3          	beqz	a6,80001512 <copyinstr+0x4a>
    80001542:	985a                	add	a6,a6,s6
    80001544:	87da                	mv	a5,s6
      if (*p == '\0')
    80001546:	41650633          	sub	a2,a0,s6
    8000154a:	14fd                	addi	s1,s1,-1
    8000154c:	9b26                	add	s6,s6,s1
    8000154e:	00f60733          	add	a4,a2,a5
    80001552:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffcc000>
    80001556:	df41                	beqz	a4,800014ee <copyinstr+0x26>
        *dst = *p;
    80001558:	00e78023          	sb	a4,0(a5)
      --max;
    8000155c:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001560:	0785                	addi	a5,a5,1
    while (n > 0)
    80001562:	ff0796e3          	bne	a5,a6,8000154e <copyinstr+0x86>
      dst++;
    80001566:	8b42                	mv	s6,a6
    80001568:	b76d                	j	80001512 <copyinstr+0x4a>
    8000156a:	4781                	li	a5,0
    8000156c:	b761                	j	800014f4 <copyinstr+0x2c>
      return -1;
    8000156e:	557d                	li	a0,-1
    80001570:	b771                	j	800014fc <copyinstr+0x34>
  int got_null = 0;
    80001572:	4781                	li	a5,0
  if (got_null)
    80001574:	0017b793          	seqz	a5,a5
    80001578:	40f00533          	neg	a0,a5
} 
    8000157c:	8082                	ret

000000008000157e <insert_page_to_swap_file>:
// Update data structure
int insert_page_to_swap_file(uint64 a)
{
    8000157e:	1101                	addi	sp,sp,-32
    80001580:	ec06                	sd	ra,24(sp)
    80001582:	e822                	sd	s0,16(sp)
    80001584:	e426                	sd	s1,8(sp)
    80001586:	e04a                	sd	s2,0(sp)
    80001588:	1000                	addi	s0,sp,32
    8000158a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000158c:	00000097          	auipc	ra,0x0
    80001590:	7a6080e7          	jalr	1958(ra) # 80001d32 <myproc>
    80001594:	84aa                	mv	s1,a0
  int free_index = get_next_free_space(p->pages_swap_info.free_spaces);
    80001596:	17855503          	lhu	a0,376(a0)
    8000159a:	00001097          	auipc	ra,0x1
    8000159e:	19a080e7          	jalr	410(ra) # 80002734 <get_next_free_space>
  if (free_index < 0 || free_index >= MAX_PSYC_PAGES)
    800015a2:	0005071b          	sext.w	a4,a0
    800015a6:	47bd                	li	a5,15
    800015a8:	02e7eb63          	bltu	a5,a4,800015de <insert_page_to_swap_file+0x60>
    panic("insert_swap: no free index in swap arr");
  p->pages_swap_info.pages[free_index].va = a;                // Set va of page
    800015ac:	00151793          	slli	a5,a0,0x1
    800015b0:	97aa                	add	a5,a5,a0
    800015b2:	078e                	slli	a5,a5,0x3
    800015b4:	97a6                	add	a5,a5,s1
    800015b6:	1927b023          	sd	s2,384(a5)

  if (p->pages_swap_info.free_spaces & (1 << free_index))
    800015ba:	1784d783          	lhu	a5,376(s1)
    800015be:	40a7d73b          	sraw	a4,a5,a0
    800015c2:	8b05                	andi	a4,a4,1
    800015c4:	e70d                	bnez	a4,800015ee <insert_page_to_swap_file+0x70>
    panic("insert_swap: tried to set free space flag when it is already set");
  p->pages_swap_info.free_spaces |= (1 << free_index); // Mark space as occupied
    800015c6:	4705                	li	a4,1
    800015c8:	00a7173b          	sllw	a4,a4,a0
    800015cc:	8fd9                	or	a5,a5,a4
    800015ce:	16f49c23          	sh	a5,376(s1)

  return free_index;
}
    800015d2:	60e2                	ld	ra,24(sp)
    800015d4:	6442                	ld	s0,16(sp)
    800015d6:	64a2                	ld	s1,8(sp)
    800015d8:	6902                	ld	s2,0(sp)
    800015da:	6105                	addi	sp,sp,32
    800015dc:	8082                	ret
    panic("insert_swap: no free index in swap arr");
    800015de:	00008517          	auipc	a0,0x8
    800015e2:	b4a50513          	addi	a0,a0,-1206 # 80009128 <digits+0xe8>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f44080e7          	jalr	-188(ra) # 8000052a <panic>
    panic("insert_swap: tried to set free space flag when it is already set");
    800015ee:	00008517          	auipc	a0,0x8
    800015f2:	b6250513          	addi	a0,a0,-1182 # 80009150 <digits+0x110>
    800015f6:	fffff097          	auipc	ra,0xfffff
    800015fa:	f34080e7          	jalr	-204(ra) # 8000052a <panic>

00000000800015fe <insert_page_to_physical_memory>:
// Update data structure
int insert_page_to_physical_memory(uint64 a)
{
    800015fe:	7179                	addi	sp,sp,-48
    80001600:	f406                	sd	ra,40(sp)
    80001602:	f022                	sd	s0,32(sp)
    80001604:	ec26                	sd	s1,24(sp)
    80001606:	e84a                	sd	s2,16(sp)
    80001608:	e44e                	sd	s3,8(sp)
    8000160a:	1800                	addi	s0,sp,48
    8000160c:	89aa                	mv	s3,a0
  struct proc *p = myproc();
    8000160e:	00000097          	auipc	ra,0x0
    80001612:	724080e7          	jalr	1828(ra) # 80001d32 <myproc>
    80001616:	892a                	mv	s2,a0
  int free_index = get_next_free_space(p->pages_physc_info.free_spaces);
    80001618:	30055503          	lhu	a0,768(a0)
    8000161c:	00001097          	auipc	ra,0x1
    80001620:	118080e7          	jalr	280(ra) # 80002734 <get_next_free_space>
  if (free_index < 0 || free_index >= MAX_PSYC_PAGES)
    80001624:	0005071b          	sext.w	a4,a0
    80001628:	47bd                	li	a5,15
    8000162a:	04e7ef63          	bltu	a5,a4,80001688 <insert_page_to_physical_memory+0x8a>
    8000162e:	84aa                	mv	s1,a0
    panic("insert_phys: no free index in physc arr");
  p->pages_physc_info.pages[free_index].va = a;                // Set va of page
    80001630:	00151793          	slli	a5,a0,0x1
    80001634:	00a78733          	add	a4,a5,a0
    80001638:	070e                	slli	a4,a4,0x3
    8000163a:	974a                	add	a4,a4,s2
    8000163c:	31373423          	sd	s3,776(a4)
  p->pages_physc_info.pages[free_index].time_inserted = p->paging_time; //  Update insertion time
    80001640:	48893683          	ld	a3,1160(s2) # 1488 <_entry-0x7fffeb78>
    80001644:	30d72c23          	sw	a3,792(a4)
  p->paging_time++;
    80001648:	0685                	addi	a3,a3,1
    8000164a:	48d93423          	sd	a3,1160(s2)
  reset_aging_counter(&(p->pages_physc_info.pages[free_index]));
    8000164e:	953e                	add	a0,a0,a5
    80001650:	050e                	slli	a0,a0,0x3
    80001652:	30850513          	addi	a0,a0,776
    80001656:	954a                	add	a0,a0,s2
    80001658:	00001097          	auipc	ra,0x1
    8000165c:	7c0080e7          	jalr	1984(ra) # 80002e18 <reset_aging_counter>

  if (p->pages_physc_info.free_spaces & (1 << free_index))
    80001660:	30095783          	lhu	a5,768(s2)
    80001664:	4097d73b          	sraw	a4,a5,s1
    80001668:	8b05                	andi	a4,a4,1
    8000166a:	e71d                	bnez	a4,80001698 <insert_page_to_physical_memory+0x9a>
    panic("insert_phys: tried to set free space flag when it is already set");
  p->pages_physc_info.free_spaces |= (1 << free_index); // Mark space as occupied
    8000166c:	4705                	li	a4,1
    8000166e:	0097173b          	sllw	a4,a4,s1
    80001672:	8fd9                	or	a5,a5,a4
    80001674:	30f91023          	sh	a5,768(s2)

  return free_index;
}
    80001678:	8526                	mv	a0,s1
    8000167a:	70a2                	ld	ra,40(sp)
    8000167c:	7402                	ld	s0,32(sp)
    8000167e:	64e2                	ld	s1,24(sp)
    80001680:	6942                	ld	s2,16(sp)
    80001682:	69a2                	ld	s3,8(sp)
    80001684:	6145                	addi	sp,sp,48
    80001686:	8082                	ret
    panic("insert_phys: no free index in physc arr");
    80001688:	00008517          	auipc	a0,0x8
    8000168c:	b1050513          	addi	a0,a0,-1264 # 80009198 <digits+0x158>
    80001690:	fffff097          	auipc	ra,0xfffff
    80001694:	e9a080e7          	jalr	-358(ra) # 8000052a <panic>
    panic("insert_phys: tried to set free space flag when it is already set");
    80001698:	00008517          	auipc	a0,0x8
    8000169c:	b2850513          	addi	a0,a0,-1240 # 800091c0 <digits+0x180>
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	e8a080e7          	jalr	-374(ra) # 8000052a <panic>

00000000800016a8 <remove_page_from_physical_memory>:

// Update data structure
int remove_page_from_physical_memory(uint64 a)
{
    800016a8:	1101                	addi	sp,sp,-32
    800016aa:	ec06                	sd	ra,24(sp)
    800016ac:	e822                	sd	s0,16(sp)
    800016ae:	e426                	sd	s1,8(sp)
    800016b0:	e04a                	sd	s2,0(sp)
    800016b2:	1000                	addi	s0,sp,32
    800016b4:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800016b6:	00000097          	auipc	ra,0x0
    800016ba:	67c080e7          	jalr	1660(ra) # 80001d32 <myproc>
    800016be:	84aa                	mv	s1,a0
  int index = get_index_in_page_info_array(a, p->pages_physc_info.pages);
    800016c0:	30850593          	addi	a1,a0,776
    800016c4:	854a                	mv	a0,s2
    800016c6:	00001097          	auipc	ra,0x1
    800016ca:	09a080e7          	jalr	154(ra) # 80002760 <get_index_in_page_info_array>
  if (index < 0 || index >= MAX_PSYC_PAGES)
    800016ce:	0005071b          	sext.w	a4,a0
    800016d2:	47bd                	li	a5,15
    800016d4:	02e7ec63          	bltu	a5,a4,8000170c <remove_page_from_physical_memory+0x64>
    return -1; // page is not in phisical mem
  // panic("remove_page_from_physical_memory: not found page to free ");
  if (!(p->pages_physc_info.free_spaces & (1 << index)))
    800016d8:	3004d783          	lhu	a5,768(s1)
    800016dc:	40a7d73b          	sraw	a4,a5,a0
    800016e0:	8b05                	andi	a4,a4,1
    800016e2:	cf09                	beqz	a4,800016fc <remove_page_from_physical_memory+0x54>
    panic("remove_page_from_physical_memory: free space flag should be set but is unset");
  p->pages_physc_info.free_spaces ^= (1 << index);
    800016e4:	4705                	li	a4,1
    800016e6:	00a7173b          	sllw	a4,a4,a0
    800016ea:	8fb9                	xor	a5,a5,a4
    800016ec:	30f49023          	sh	a5,768(s1)

  return index;
}
    800016f0:	60e2                	ld	ra,24(sp)
    800016f2:	6442                	ld	s0,16(sp)
    800016f4:	64a2                	ld	s1,8(sp)
    800016f6:	6902                	ld	s2,0(sp)
    800016f8:	6105                	addi	sp,sp,32
    800016fa:	8082                	ret
    panic("remove_page_from_physical_memory: free space flag should be set but is unset");
    800016fc:	00008517          	auipc	a0,0x8
    80001700:	b0c50513          	addi	a0,a0,-1268 # 80009208 <digits+0x1c8>
    80001704:	fffff097          	auipc	ra,0xfffff
    80001708:	e26080e7          	jalr	-474(ra) # 8000052a <panic>
    return -1; // page is not in phisical mem
    8000170c:	557d                	li	a0,-1
    8000170e:	b7cd                	j	800016f0 <remove_page_from_physical_memory+0x48>

0000000080001710 <remove_page_from_swap_file>:

// Update data structure
int remove_page_from_swap_file(uint64 a)
{
    80001710:	1101                	addi	sp,sp,-32
    80001712:	ec06                	sd	ra,24(sp)
    80001714:	e822                	sd	s0,16(sp)
    80001716:	e426                	sd	s1,8(sp)
    80001718:	e04a                	sd	s2,0(sp)
    8000171a:	1000                	addi	s0,sp,32
    8000171c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000171e:	00000097          	auipc	ra,0x0
    80001722:	614080e7          	jalr	1556(ra) # 80001d32 <myproc>
    80001726:	84aa                	mv	s1,a0
  int index = get_index_in_page_info_array(a, p->pages_swap_info.pages);
    80001728:	18050593          	addi	a1,a0,384
    8000172c:	854a                	mv	a0,s2
    8000172e:	00001097          	auipc	ra,0x1
    80001732:	032080e7          	jalr	50(ra) # 80002760 <get_index_in_page_info_array>
  if (index < 0 || index >= MAX_PSYC_PAGES)
    80001736:	0005071b          	sext.w	a4,a0
    8000173a:	47bd                	li	a5,15
    8000173c:	02e7ec63          	bltu	a5,a4,80001774 <remove_page_from_swap_file+0x64>
    return -1; // page is not in phisical mem
  // panic("remove_page_from_physical_memory: not found page to free ");
  if (!(p->pages_swap_info.free_spaces & (1 << index)))
    80001740:	1784d783          	lhu	a5,376(s1)
    80001744:	40a7d73b          	sraw	a4,a5,a0
    80001748:	8b05                	andi	a4,a4,1
    8000174a:	cf09                	beqz	a4,80001764 <remove_page_from_swap_file+0x54>
    panic("remove_page_from_swap_file: free space flag should be set but is unset");
  p->pages_swap_info.free_spaces ^= (1 << index);
    8000174c:	4705                	li	a4,1
    8000174e:	00a7173b          	sllw	a4,a4,a0
    80001752:	8fb9                	xor	a5,a5,a4
    80001754:	16f49c23          	sh	a5,376(s1)

  return index;
    80001758:	60e2                	ld	ra,24(sp)
    8000175a:	6442                	ld	s0,16(sp)
    8000175c:	64a2                	ld	s1,8(sp)
    8000175e:	6902                	ld	s2,0(sp)
    80001760:	6105                	addi	sp,sp,32
    80001762:	8082                	ret
    panic("remove_page_from_swap_file: free space flag should be set but is unset");
    80001764:	00008517          	auipc	a0,0x8
    80001768:	af450513          	addi	a0,a0,-1292 # 80009258 <digits+0x218>
    8000176c:	fffff097          	auipc	ra,0xfffff
    80001770:	dbe080e7          	jalr	-578(ra) # 8000052a <panic>
    return -1; // page is not in phisical mem
    80001774:	557d                	li	a0,-1
    80001776:	b7cd                	j	80001758 <remove_page_from_swap_file+0x48>

0000000080001778 <uvmunmap>:
{
    80001778:	711d                	addi	sp,sp,-96
    8000177a:	ec86                	sd	ra,88(sp)
    8000177c:	e8a2                	sd	s0,80(sp)
    8000177e:	e4a6                	sd	s1,72(sp)
    80001780:	e0ca                	sd	s2,64(sp)
    80001782:	fc4e                	sd	s3,56(sp)
    80001784:	f852                	sd	s4,48(sp)
    80001786:	f456                	sd	s5,40(sp)
    80001788:	f05a                	sd	s6,32(sp)
    8000178a:	ec5e                	sd	s7,24(sp)
    8000178c:	e862                	sd	s8,16(sp)
    8000178e:	e466                	sd	s9,8(sp)
    80001790:	1080                	addi	s0,sp,96
  if ((va % PGSIZE) != 0)
    80001792:	03459793          	slli	a5,a1,0x34
    80001796:	eb8d                	bnez	a5,800017c8 <uvmunmap+0x50>
    80001798:	89aa                	mv	s3,a0
    8000179a:	892e                	mv	s2,a1
    8000179c:	8b36                	mv	s6,a3
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    8000179e:	0632                	slli	a2,a2,0xc
    800017a0:	00b60a33          	add	s4,a2,a1
    if (PTE_FLAGS(*pte) == PTE_V)
    800017a4:	4b85                	li	s7,1
      if (myproc()->pid > 2 && pagetable == myproc()->pagetable)
    800017a6:	4c09                	li	s8,2
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    800017a8:	6a85                	lui	s5,0x1
    800017aa:	0b45e563          	bltu	a1,s4,80001854 <uvmunmap+0xdc>
}
    800017ae:	60e6                	ld	ra,88(sp)
    800017b0:	6446                	ld	s0,80(sp)
    800017b2:	64a6                	ld	s1,72(sp)
    800017b4:	6906                	ld	s2,64(sp)
    800017b6:	79e2                	ld	s3,56(sp)
    800017b8:	7a42                	ld	s4,48(sp)
    800017ba:	7aa2                	ld	s5,40(sp)
    800017bc:	7b02                	ld	s6,32(sp)
    800017be:	6be2                	ld	s7,24(sp)
    800017c0:	6c42                	ld	s8,16(sp)
    800017c2:	6ca2                	ld	s9,8(sp)
    800017c4:	6125                	addi	sp,sp,96
    800017c6:	8082                	ret
    panic("uvmunmap: not aligned");
    800017c8:	00008517          	auipc	a0,0x8
    800017cc:	ad850513          	addi	a0,a0,-1320 # 800092a0 <digits+0x260>
    800017d0:	fffff097          	auipc	ra,0xfffff
    800017d4:	d5a080e7          	jalr	-678(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    800017d8:	00008517          	auipc	a0,0x8
    800017dc:	ae050513          	addi	a0,a0,-1312 # 800092b8 <digits+0x278>
    800017e0:	fffff097          	auipc	ra,0xfffff
    800017e4:	d4a080e7          	jalr	-694(ra) # 8000052a <panic>
        struct proc *p = myproc();
    800017e8:	00000097          	auipc	ra,0x0
    800017ec:	54a080e7          	jalr	1354(ra) # 80001d32 <myproc>
    800017f0:	8caa                	mv	s9,a0
        if((*pte & PTE_PG)  && pagetable == p->pagetable){  // page is swapped out
    800017f2:	609c                	ld	a5,0(s1)
    800017f4:	2007f793          	andi	a5,a5,512
    800017f8:	cb8d                	beqz	a5,8000182a <uvmunmap+0xb2>
    800017fa:	693c                	ld	a5,80(a0)
    800017fc:	05379963          	bne	a5,s3,8000184e <uvmunmap+0xd6>
          if(remove_page_from_swap_file(a)<0)
    80001800:	854a                	mv	a0,s2
    80001802:	00000097          	auipc	ra,0x0
    80001806:	f0e080e7          	jalr	-242(ra) # 80001710 <remove_page_from_swap_file>
    8000180a:	00054863          	bltz	a0,8000181a <uvmunmap+0xa2>
          p->total_pages_num--;
    8000180e:	174ca783          	lw	a5,372(s9)
    80001812:	37fd                	addiw	a5,a5,-1
    80001814:	16fcaa23          	sw	a5,372(s9)
          continue;
    80001818:	a81d                	j	8000184e <uvmunmap+0xd6>
            panic("uvmunmap: cant find file bos");
    8000181a:	00008517          	auipc	a0,0x8
    8000181e:	aae50513          	addi	a0,a0,-1362 # 800092c8 <digits+0x288>
    80001822:	fffff097          	auipc	ra,0xfffff
    80001826:	d08080e7          	jalr	-760(ra) # 8000052a <panic>
          panic("uvmunmap: not mapped");
    8000182a:	00008517          	auipc	a0,0x8
    8000182e:	abe50513          	addi	a0,a0,-1346 # 800092e8 <digits+0x2a8>
    80001832:	fffff097          	auipc	ra,0xfffff
    80001836:	cf8080e7          	jalr	-776(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    8000183a:	00008517          	auipc	a0,0x8
    8000183e:	ac650513          	addi	a0,a0,-1338 # 80009300 <digits+0x2c0>
    80001842:	fffff097          	auipc	ra,0xfffff
    80001846:	ce8080e7          	jalr	-792(ra) # 8000052a <panic>
    *pte = 0;
    8000184a:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    8000184e:	9956                	add	s2,s2,s5
    80001850:	f5497fe3          	bgeu	s2,s4,800017ae <uvmunmap+0x36>
    if ((pte = walk(pagetable, a, 0)) == 0){
    80001854:	4601                	li	a2,0
    80001856:	85ca                	mv	a1,s2
    80001858:	854e                	mv	a0,s3
    8000185a:	fffff097          	auipc	ra,0xfffff
    8000185e:	74c080e7          	jalr	1868(ra) # 80000fa6 <walk>
    80001862:	84aa                	mv	s1,a0
    80001864:	d935                	beqz	a0,800017d8 <uvmunmap+0x60>
    if ((*pte & PTE_V) == 0){
    80001866:	611c                	ld	a5,0(a0)
    80001868:	0017f713          	andi	a4,a5,1
    8000186c:	df35                	beqz	a4,800017e8 <uvmunmap+0x70>
    if (PTE_FLAGS(*pte) == PTE_V)
    8000186e:	3ff7f713          	andi	a4,a5,1023
    80001872:	fd7704e3          	beq	a4,s7,8000183a <uvmunmap+0xc2>
    if (do_free)
    80001876:	fc0b0ae3          	beqz	s6,8000184a <uvmunmap+0xd2>
      uint64 pa = PTE2PA(*pte);
    8000187a:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    8000187c:	00c79513          	slli	a0,a5,0xc
    80001880:	fffff097          	auipc	ra,0xfffff
    80001884:	156080e7          	jalr	342(ra) # 800009d6 <kfree>
      if (myproc()->pid > 2 && pagetable == myproc()->pagetable)
    80001888:	00000097          	auipc	ra,0x0
    8000188c:	4aa080e7          	jalr	1194(ra) # 80001d32 <myproc>
    80001890:	591c                	lw	a5,48(a0)
    80001892:	fafc5ce3          	bge	s8,a5,8000184a <uvmunmap+0xd2>
    80001896:	00000097          	auipc	ra,0x0
    8000189a:	49c080e7          	jalr	1180(ra) # 80001d32 <myproc>
    8000189e:	693c                	ld	a5,80(a0)
    800018a0:	fb3795e3          	bne	a5,s3,8000184a <uvmunmap+0xd2>
        if (remove_page_from_physical_memory(a) >= 0)
    800018a4:	854a                	mv	a0,s2
    800018a6:	00000097          	auipc	ra,0x0
    800018aa:	e02080e7          	jalr	-510(ra) # 800016a8 <remove_page_from_physical_memory>
    800018ae:	f8054ee3          	bltz	a0,8000184a <uvmunmap+0xd2>
          myproc()->physical_pages_num--;
    800018b2:	00000097          	auipc	ra,0x0
    800018b6:	480080e7          	jalr	1152(ra) # 80001d32 <myproc>
    800018ba:	17052783          	lw	a5,368(a0)
    800018be:	37fd                	addiw	a5,a5,-1
    800018c0:	16f52823          	sw	a5,368(a0)
          myproc()->total_pages_num--;
    800018c4:	00000097          	auipc	ra,0x0
    800018c8:	46e080e7          	jalr	1134(ra) # 80001d32 <myproc>
    800018cc:	17452783          	lw	a5,372(a0)
    800018d0:	37fd                	addiw	a5,a5,-1
    800018d2:	16f52a23          	sw	a5,372(a0)
    800018d6:	bf95                	j	8000184a <uvmunmap+0xd2>

00000000800018d8 <uvmdealloc>:
{
    800018d8:	1101                	addi	sp,sp,-32
    800018da:	ec06                	sd	ra,24(sp)
    800018dc:	e822                	sd	s0,16(sp)
    800018de:	e426                	sd	s1,8(sp)
    800018e0:	1000                	addi	s0,sp,32
    return oldsz;
    800018e2:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    800018e4:	00b67d63          	bgeu	a2,a1,800018fe <uvmdealloc+0x26>
    800018e8:	84b2                	mv	s1,a2
  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    800018ea:	6785                	lui	a5,0x1
    800018ec:	17fd                	addi	a5,a5,-1
    800018ee:	00f60733          	add	a4,a2,a5
    800018f2:	767d                	lui	a2,0xfffff
    800018f4:	8f71                	and	a4,a4,a2
    800018f6:	97ae                	add	a5,a5,a1
    800018f8:	8ff1                	and	a5,a5,a2
    800018fa:	00f76863          	bltu	a4,a5,8000190a <uvmdealloc+0x32>
}
    800018fe:	8526                	mv	a0,s1
    80001900:	60e2                	ld	ra,24(sp)
    80001902:	6442                	ld	s0,16(sp)
    80001904:	64a2                	ld	s1,8(sp)
    80001906:	6105                	addi	sp,sp,32
    80001908:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000190a:	8f99                	sub	a5,a5,a4
    8000190c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000190e:	4685                	li	a3,1
    80001910:	0007861b          	sext.w	a2,a5
    80001914:	85ba                	mv	a1,a4
    80001916:	00000097          	auipc	ra,0x0
    8000191a:	e62080e7          	jalr	-414(ra) # 80001778 <uvmunmap>
    8000191e:	b7c5                	j	800018fe <uvmdealloc+0x26>

0000000080001920 <uvmalloc>:
  if (newsz < oldsz)
    80001920:	16b66463          	bltu	a2,a1,80001a88 <uvmalloc+0x168>
{
    80001924:	715d                	addi	sp,sp,-80
    80001926:	e486                	sd	ra,72(sp)
    80001928:	e0a2                	sd	s0,64(sp)
    8000192a:	fc26                	sd	s1,56(sp)
    8000192c:	f84a                	sd	s2,48(sp)
    8000192e:	f44e                	sd	s3,40(sp)
    80001930:	f052                	sd	s4,32(sp)
    80001932:	ec56                	sd	s5,24(sp)
    80001934:	e85a                	sd	s6,16(sp)
    80001936:	e45e                	sd	s7,8(sp)
    80001938:	e062                	sd	s8,0(sp)
    8000193a:	0880                	addi	s0,sp,80
    8000193c:	8b2a                	mv	s6,a0
    8000193e:	8ab2                	mv	s5,a2
  oldsz = PGROUNDUP(oldsz);
    80001940:	6b85                	lui	s7,0x1
    80001942:	1bfd                	addi	s7,s7,-1
    80001944:	95de                	add	a1,a1,s7
    80001946:	7bfd                	lui	s7,0xfffff
    80001948:	0175fbb3          	and	s7,a1,s7
  for (a = oldsz; a < newsz; a += PGSIZE)
    8000194c:	14cbf063          	bgeu	s7,a2,80001a8c <uvmalloc+0x16c>
    80001950:	89de                	mv	s3,s7
    if (p->pid > 2)
    80001952:	4a09                	li	s4,2
      if (p->total_pages_num >= MAX_TOTAL_PAGES)
    80001954:	4c7d                	li	s8,31
      while (p->physical_pages_num >= MAX_PSYC_PAGES)
    80001956:	493d                	li	s2,15
    80001958:	a8a5                	j	800019d0 <uvmalloc+0xb0>
        panic("uvmalloc: proc out of space!");
    8000195a:	00008517          	auipc	a0,0x8
    8000195e:	9be50513          	addi	a0,a0,-1602 # 80009318 <digits+0x2d8>
    80001962:	fffff097          	auipc	ra,0xfffff
    80001966:	bc8080e7          	jalr	-1080(ra) # 8000052a <panic>
          printf("panic recieved for pid=%d\n",p->pid);
    8000196a:	588c                	lw	a1,48(s1)
    8000196c:	00008517          	auipc	a0,0x8
    80001970:	9cc50513          	addi	a0,a0,-1588 # 80009338 <digits+0x2f8>
    80001974:	fffff097          	auipc	ra,0xfffff
    80001978:	c00080e7          	jalr	-1024(ra) # 80000574 <printf>
          panic("uvmalloc: did not find the page to swap out!");
    8000197c:	00008517          	auipc	a0,0x8
    80001980:	9dc50513          	addi	a0,a0,-1572 # 80009358 <digits+0x318>
    80001984:	fffff097          	auipc	ra,0xfffff
    80001988:	ba6080e7          	jalr	-1114(ra) # 8000052a <panic>
    mem = kalloc();
    8000198c:	fffff097          	auipc	ra,0xfffff
    80001990:	146080e7          	jalr	326(ra) # 80000ad2 <kalloc>
    80001994:	84aa                	mv	s1,a0
    if (mem == 0)
    80001996:	c549                	beqz	a0,80001a20 <uvmalloc+0x100>
    memset(mem, 0, PGSIZE);
    80001998:	6605                	lui	a2,0x1
    8000199a:	4581                	li	a1,0
    8000199c:	fffff097          	auipc	ra,0xfffff
    800019a0:	322080e7          	jalr	802(ra) # 80000cbe <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W | PTE_X | PTE_R | PTE_U) != 0)
    800019a4:	4779                	li	a4,30
    800019a6:	86a6                	mv	a3,s1
    800019a8:	6605                	lui	a2,0x1
    800019aa:	85ce                	mv	a1,s3
    800019ac:	855a                	mv	a0,s6
    800019ae:	fffff097          	auipc	ra,0xfffff
    800019b2:	70c080e7          	jalr	1804(ra) # 800010ba <mappages>
    800019b6:	e949                	bnez	a0,80001a48 <uvmalloc+0x128>
    struct proc *p2 = myproc();
    800019b8:	00000097          	auipc	ra,0x0
    800019bc:	37a080e7          	jalr	890(ra) # 80001d32 <myproc>
    800019c0:	84aa                	mv	s1,a0
    if (p2->pid > 2)
    800019c2:	591c                	lw	a5,48(a0)
    800019c4:	0afa4063          	blt	s4,a5,80001a64 <uvmalloc+0x144>
  for (a = oldsz; a < newsz; a += PGSIZE)
    800019c8:	6785                	lui	a5,0x1
    800019ca:	99be                	add	s3,s3,a5
    800019cc:	0b59fc63          	bgeu	s3,s5,80001a84 <uvmalloc+0x164>
    struct proc *p = myproc();
    800019d0:	00000097          	auipc	ra,0x0
    800019d4:	362080e7          	jalr	866(ra) # 80001d32 <myproc>
    800019d8:	84aa                	mv	s1,a0
    if (p->pid > 2)
    800019da:	591c                	lw	a5,48(a0)
    800019dc:	fafa58e3          	bge	s4,a5,8000198c <uvmalloc+0x6c>
      if (p->total_pages_num >= MAX_TOTAL_PAGES)
    800019e0:	17452783          	lw	a5,372(a0)
    800019e4:	f6fc4be3          	blt	s8,a5,8000195a <uvmalloc+0x3a>
      while (p->physical_pages_num >= MAX_PSYC_PAGES)
    800019e8:	17052783          	lw	a5,368(a0)
    800019ec:	faf950e3          	bge	s2,a5,8000198c <uvmalloc+0x6c>
        int i = get_next_page_to_swap_out();
    800019f0:	00001097          	auipc	ra,0x1
    800019f4:	4d8080e7          	jalr	1240(ra) # 80002ec8 <get_next_page_to_swap_out>
        if (i < 0 || i >= MAX_PSYC_PAGES){
    800019f8:	0005079b          	sext.w	a5,a0
    800019fc:	f6f967e3          	bltu	s2,a5,8000196a <uvmalloc+0x4a>
        uint64 rva = p->pages_physc_info.pages[i].va;
    80001a00:	00151793          	slli	a5,a0,0x1
    80001a04:	97aa                	add	a5,a5,a0
    80001a06:	078e                	slli	a5,a5,0x3
    80001a08:	97a6                	add	a5,a5,s1
        page_out(rva);
    80001a0a:	3087b503          	ld	a0,776(a5) # 1308 <_entry-0x7fffecf8>
    80001a0e:	00001097          	auipc	ra,0x1
    80001a12:	d76080e7          	jalr	-650(ra) # 80002784 <page_out>
      while (p->physical_pages_num >= MAX_PSYC_PAGES)
    80001a16:	1704a783          	lw	a5,368(s1)
    80001a1a:	fcf94be3          	blt	s2,a5,800019f0 <uvmalloc+0xd0>
    80001a1e:	b7bd                	j	8000198c <uvmalloc+0x6c>
      uvmdealloc(pagetable, a, oldsz);
    80001a20:	865e                	mv	a2,s7
    80001a22:	85ce                	mv	a1,s3
    80001a24:	855a                	mv	a0,s6
    80001a26:	00000097          	auipc	ra,0x0
    80001a2a:	eb2080e7          	jalr	-334(ra) # 800018d8 <uvmdealloc>
      return 0;
    80001a2e:	4501                	li	a0,0
}
    80001a30:	60a6                	ld	ra,72(sp)
    80001a32:	6406                	ld	s0,64(sp)
    80001a34:	74e2                	ld	s1,56(sp)
    80001a36:	7942                	ld	s2,48(sp)
    80001a38:	79a2                	ld	s3,40(sp)
    80001a3a:	7a02                	ld	s4,32(sp)
    80001a3c:	6ae2                	ld	s5,24(sp)
    80001a3e:	6b42                	ld	s6,16(sp)
    80001a40:	6ba2                	ld	s7,8(sp)
    80001a42:	6c02                	ld	s8,0(sp)
    80001a44:	6161                	addi	sp,sp,80
    80001a46:	8082                	ret
      kfree(mem);
    80001a48:	8526                	mv	a0,s1
    80001a4a:	fffff097          	auipc	ra,0xfffff
    80001a4e:	f8c080e7          	jalr	-116(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001a52:	865e                	mv	a2,s7
    80001a54:	85ce                	mv	a1,s3
    80001a56:	855a                	mv	a0,s6
    80001a58:	00000097          	auipc	ra,0x0
    80001a5c:	e80080e7          	jalr	-384(ra) # 800018d8 <uvmdealloc>
      return 0;
    80001a60:	4501                	li	a0,0
    80001a62:	b7f9                	j	80001a30 <uvmalloc+0x110>
      insert_page_to_physical_memory(a);
    80001a64:	854e                	mv	a0,s3
    80001a66:	00000097          	auipc	ra,0x0
    80001a6a:	b98080e7          	jalr	-1128(ra) # 800015fe <insert_page_to_physical_memory>
      p2->total_pages_num++;
    80001a6e:	1744a783          	lw	a5,372(s1)
    80001a72:	2785                	addiw	a5,a5,1
    80001a74:	16f4aa23          	sw	a5,372(s1)
      p2->physical_pages_num++;
    80001a78:	1704a783          	lw	a5,368(s1)
    80001a7c:	2785                	addiw	a5,a5,1
    80001a7e:	16f4a823          	sw	a5,368(s1)
    80001a82:	b799                	j	800019c8 <uvmalloc+0xa8>
  return newsz;
    80001a84:	8556                	mv	a0,s5
    80001a86:	b76d                	j	80001a30 <uvmalloc+0x110>
    return oldsz;
    80001a88:	852e                	mv	a0,a1
}
    80001a8a:	8082                	ret
  return newsz;
    80001a8c:	8532                	mv	a0,a2
    80001a8e:	b74d                	j	80001a30 <uvmalloc+0x110>

0000000080001a90 <uvmfree>:
{
    80001a90:	1101                	addi	sp,sp,-32
    80001a92:	ec06                	sd	ra,24(sp)
    80001a94:	e822                	sd	s0,16(sp)
    80001a96:	e426                	sd	s1,8(sp)
    80001a98:	1000                	addi	s0,sp,32
    80001a9a:	84aa                	mv	s1,a0
  if (sz > 0)
    80001a9c:	e999                	bnez	a1,80001ab2 <uvmfree+0x22>
  freewalk(pagetable);
    80001a9e:	8526                	mv	a0,s1
    80001aa0:	00000097          	auipc	ra,0x0
    80001aa4:	86e080e7          	jalr	-1938(ra) # 8000130e <freewalk>
}
    80001aa8:	60e2                	ld	ra,24(sp)
    80001aaa:	6442                	ld	s0,16(sp)
    80001aac:	64a2                	ld	s1,8(sp)
    80001aae:	6105                	addi	sp,sp,32
    80001ab0:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001ab2:	6605                	lui	a2,0x1
    80001ab4:	167d                	addi	a2,a2,-1
    80001ab6:	962e                	add	a2,a2,a1
    80001ab8:	4685                	li	a3,1
    80001aba:	8231                	srli	a2,a2,0xc
    80001abc:	4581                	li	a1,0
    80001abe:	00000097          	auipc	ra,0x0
    80001ac2:	cba080e7          	jalr	-838(ra) # 80001778 <uvmunmap>
    80001ac6:	bfe1                	j	80001a9e <uvmfree+0xe>

0000000080001ac8 <uvmcopy>:
  for (i = 0; i < sz; i += PGSIZE)
    80001ac8:	ca65                	beqz	a2,80001bb8 <uvmcopy+0xf0>
{
    80001aca:	715d                	addi	sp,sp,-80
    80001acc:	e486                	sd	ra,72(sp)
    80001ace:	e0a2                	sd	s0,64(sp)
    80001ad0:	fc26                	sd	s1,56(sp)
    80001ad2:	f84a                	sd	s2,48(sp)
    80001ad4:	f44e                	sd	s3,40(sp)
    80001ad6:	f052                	sd	s4,32(sp)
    80001ad8:	ec56                	sd	s5,24(sp)
    80001ada:	e85a                	sd	s6,16(sp)
    80001adc:	e45e                	sd	s7,8(sp)
    80001ade:	0880                	addi	s0,sp,80
    80001ae0:	8aaa                	mv	s5,a0
    80001ae2:	8a2e                	mv	s4,a1
    80001ae4:	89b2                	mv	s3,a2
  for (i = 0; i < sz; i += PGSIZE)
    80001ae6:	4901                	li	s2,0
    80001ae8:	a08d                	j	80001b4a <uvmcopy+0x82>
      panic("uvmcopy: pte should exist");
    80001aea:	00008517          	auipc	a0,0x8
    80001aee:	89e50513          	addi	a0,a0,-1890 # 80009388 <digits+0x348>
    80001af2:	fffff097          	auipc	ra,0xfffff
    80001af6:	a38080e7          	jalr	-1480(ra) # 8000052a <panic>
        panic("uvmcopy: page not present");
    80001afa:	00008517          	auipc	a0,0x8
    80001afe:	8ae50513          	addi	a0,a0,-1874 # 800093a8 <digits+0x368>
    80001b02:	fffff097          	auipc	ra,0xfffff
    80001b06:	a28080e7          	jalr	-1496(ra) # 8000052a <panic>
    pa = PTE2PA(*pte);
    80001b0a:	00a75593          	srli	a1,a4,0xa
    80001b0e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001b12:	3ff77493          	andi	s1,a4,1023
    if ((mem = kalloc()) == 0)
    80001b16:	fffff097          	auipc	ra,0xfffff
    80001b1a:	fbc080e7          	jalr	-68(ra) # 80000ad2 <kalloc>
    80001b1e:	8b2a                	mv	s6,a0
    80001b20:	c52d                	beqz	a0,80001b8a <uvmcopy+0xc2>
    memmove(mem, (char *)pa, PGSIZE);
    80001b22:	6605                	lui	a2,0x1
    80001b24:	85de                	mv	a1,s7
    80001b26:	fffff097          	auipc	ra,0xfffff
    80001b2a:	1f4080e7          	jalr	500(ra) # 80000d1a <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    80001b2e:	8726                	mv	a4,s1
    80001b30:	86da                	mv	a3,s6
    80001b32:	6605                	lui	a2,0x1
    80001b34:	85ca                	mv	a1,s2
    80001b36:	8552                	mv	a0,s4
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	582080e7          	jalr	1410(ra) # 800010ba <mappages>
    80001b40:	e121                	bnez	a0,80001b80 <uvmcopy+0xb8>
  for (i = 0; i < sz; i += PGSIZE)
    80001b42:	6785                	lui	a5,0x1
    80001b44:	993e                	add	s2,s2,a5
    80001b46:	05397d63          	bgeu	s2,s3,80001ba0 <uvmcopy+0xd8>
    if ((pte = walk(old, i, 0)) == 0){
    80001b4a:	4601                	li	a2,0
    80001b4c:	85ca                	mv	a1,s2
    80001b4e:	8556                	mv	a0,s5
    80001b50:	fffff097          	auipc	ra,0xfffff
    80001b54:	456080e7          	jalr	1110(ra) # 80000fa6 <walk>
    80001b58:	84aa                	mv	s1,a0
    80001b5a:	d941                	beqz	a0,80001aea <uvmcopy+0x22>
    if ((*pte & PTE_V) == 0){
    80001b5c:	6118                	ld	a4,0(a0)
    80001b5e:	00177793          	andi	a5,a4,1
    80001b62:	f7c5                	bnez	a5,80001b0a <uvmcopy+0x42>
      if(!(*pte & PTE_PG))
    80001b64:	20077713          	andi	a4,a4,512
    80001b68:	db49                	beqz	a4,80001afa <uvmcopy+0x32>
      if((np_pte = walk(new, i, 1)) == 0)
    80001b6a:	4605                	li	a2,1
    80001b6c:	85ca                	mv	a1,s2
    80001b6e:	8552                	mv	a0,s4
    80001b70:	fffff097          	auipc	ra,0xfffff
    80001b74:	436080e7          	jalr	1078(ra) # 80000fa6 <walk>
    80001b78:	c131                	beqz	a0,80001bbc <uvmcopy+0xf4>
      *np_pte = *pte; 
    80001b7a:	609c                	ld	a5,0(s1)
    80001b7c:	e11c                	sd	a5,0(a0)
      continue;
    80001b7e:	b7d1                	j	80001b42 <uvmcopy+0x7a>
      kfree(mem);
    80001b80:	855a                	mv	a0,s6
    80001b82:	fffff097          	auipc	ra,0xfffff
    80001b86:	e54080e7          	jalr	-428(ra) # 800009d6 <kfree>
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001b8a:	4685                	li	a3,1
    80001b8c:	00c95613          	srli	a2,s2,0xc
    80001b90:	4581                	li	a1,0
    80001b92:	8552                	mv	a0,s4
    80001b94:	00000097          	auipc	ra,0x0
    80001b98:	be4080e7          	jalr	-1052(ra) # 80001778 <uvmunmap>
  return -1;
    80001b9c:	557d                	li	a0,-1
    80001b9e:	a011                	j	80001ba2 <uvmcopy+0xda>
  return 0;
    80001ba0:	4501                	li	a0,0
}
    80001ba2:	60a6                	ld	ra,72(sp)
    80001ba4:	6406                	ld	s0,64(sp)
    80001ba6:	74e2                	ld	s1,56(sp)
    80001ba8:	7942                	ld	s2,48(sp)
    80001baa:	79a2                	ld	s3,40(sp)
    80001bac:	7a02                	ld	s4,32(sp)
    80001bae:	6ae2                	ld	s5,24(sp)
    80001bb0:	6b42                	ld	s6,16(sp)
    80001bb2:	6ba2                	ld	s7,8(sp)
    80001bb4:	6161                	addi	sp,sp,80
    80001bb6:	8082                	ret
  return 0;
    80001bb8:	4501                	li	a0,0
}
    80001bba:	8082                	ret
        return -1;
    80001bbc:	557d                	li	a0,-1
    80001bbe:	b7d5                	j	80001ba2 <uvmcopy+0xda>

0000000080001bc0 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001bc0:	7139                	addi	sp,sp,-64
    80001bc2:	fc06                	sd	ra,56(sp)
    80001bc4:	f822                	sd	s0,48(sp)
    80001bc6:	f426                	sd	s1,40(sp)
    80001bc8:	f04a                	sd	s2,32(sp)
    80001bca:	ec4e                	sd	s3,24(sp)
    80001bcc:	e852                	sd	s4,16(sp)
    80001bce:	e456                	sd	s5,8(sp)
    80001bd0:	e05a                	sd	s6,0(sp)
    80001bd2:	0080                	addi	s0,sp,64
    80001bd4:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80001bd6:	00011497          	auipc	s1,0x11
    80001bda:	afa48493          	addi	s1,s1,-1286 # 800126d0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001bde:	8b26                	mv	s6,s1
    80001be0:	00007a97          	auipc	s5,0x7
    80001be4:	420a8a93          	addi	s5,s5,1056 # 80009000 <etext>
    80001be8:	04000937          	lui	s2,0x4000
    80001bec:	197d                	addi	s2,s2,-1
    80001bee:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001bf0:	00023a17          	auipc	s4,0x23
    80001bf4:	ee0a0a13          	addi	s4,s4,-288 # 80024ad0 <tickslock>
    char *pa = kalloc();
    80001bf8:	fffff097          	auipc	ra,0xfffff
    80001bfc:	eda080e7          	jalr	-294(ra) # 80000ad2 <kalloc>
    80001c00:	862a                	mv	a2,a0
    if (pa == 0)
    80001c02:	c131                	beqz	a0,80001c46 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001c04:	416485b3          	sub	a1,s1,s6
    80001c08:	8591                	srai	a1,a1,0x4
    80001c0a:	000ab783          	ld	a5,0(s5)
    80001c0e:	02f585b3          	mul	a1,a1,a5
    80001c12:	2585                	addiw	a1,a1,1
    80001c14:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001c18:	4719                	li	a4,6
    80001c1a:	6685                	lui	a3,0x1
    80001c1c:	40b905b3          	sub	a1,s2,a1
    80001c20:	854e                	mv	a0,s3
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	526080e7          	jalr	1318(ra) # 80001148 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c2a:	49048493          	addi	s1,s1,1168
    80001c2e:	fd4495e3          	bne	s1,s4,80001bf8 <proc_mapstacks+0x38>
  }
}
    80001c32:	70e2                	ld	ra,56(sp)
    80001c34:	7442                	ld	s0,48(sp)
    80001c36:	74a2                	ld	s1,40(sp)
    80001c38:	7902                	ld	s2,32(sp)
    80001c3a:	69e2                	ld	s3,24(sp)
    80001c3c:	6a42                	ld	s4,16(sp)
    80001c3e:	6aa2                	ld	s5,8(sp)
    80001c40:	6b02                	ld	s6,0(sp)
    80001c42:	6121                	addi	sp,sp,64
    80001c44:	8082                	ret
      panic("kalloc");
    80001c46:	00007517          	auipc	a0,0x7
    80001c4a:	78250513          	addi	a0,a0,1922 # 800093c8 <digits+0x388>
    80001c4e:	fffff097          	auipc	ra,0xfffff
    80001c52:	8dc080e7          	jalr	-1828(ra) # 8000052a <panic>

0000000080001c56 <procinit>:

// initialize the proc table at boot time.
void procinit(void)
{
    80001c56:	7139                	addi	sp,sp,-64
    80001c58:	fc06                	sd	ra,56(sp)
    80001c5a:	f822                	sd	s0,48(sp)
    80001c5c:	f426                	sd	s1,40(sp)
    80001c5e:	f04a                	sd	s2,32(sp)
    80001c60:	ec4e                	sd	s3,24(sp)
    80001c62:	e852                	sd	s4,16(sp)
    80001c64:	e456                	sd	s5,8(sp)
    80001c66:	e05a                	sd	s6,0(sp)
    80001c68:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001c6a:	00007597          	auipc	a1,0x7
    80001c6e:	76658593          	addi	a1,a1,1894 # 800093d0 <digits+0x390>
    80001c72:	00010517          	auipc	a0,0x10
    80001c76:	62e50513          	addi	a0,a0,1582 # 800122a0 <pid_lock>
    80001c7a:	fffff097          	auipc	ra,0xfffff
    80001c7e:	eb8080e7          	jalr	-328(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001c82:	00007597          	auipc	a1,0x7
    80001c86:	75658593          	addi	a1,a1,1878 # 800093d8 <digits+0x398>
    80001c8a:	00010517          	auipc	a0,0x10
    80001c8e:	62e50513          	addi	a0,a0,1582 # 800122b8 <wait_lock>
    80001c92:	fffff097          	auipc	ra,0xfffff
    80001c96:	ea0080e7          	jalr	-352(ra) # 80000b32 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c9a:	00011497          	auipc	s1,0x11
    80001c9e:	a3648493          	addi	s1,s1,-1482 # 800126d0 <proc>
  {
    initlock(&p->lock, "proc");
    80001ca2:	00007b17          	auipc	s6,0x7
    80001ca6:	746b0b13          	addi	s6,s6,1862 # 800093e8 <digits+0x3a8>
    p->kstack = KSTACK((int)(p - proc));
    80001caa:	8aa6                	mv	s5,s1
    80001cac:	00007a17          	auipc	s4,0x7
    80001cb0:	354a0a13          	addi	s4,s4,852 # 80009000 <etext>
    80001cb4:	04000937          	lui	s2,0x4000
    80001cb8:	197d                	addi	s2,s2,-1
    80001cba:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001cbc:	00023997          	auipc	s3,0x23
    80001cc0:	e1498993          	addi	s3,s3,-492 # 80024ad0 <tickslock>
    initlock(&p->lock, "proc");
    80001cc4:	85da                	mv	a1,s6
    80001cc6:	8526                	mv	a0,s1
    80001cc8:	fffff097          	auipc	ra,0xfffff
    80001ccc:	e6a080e7          	jalr	-406(ra) # 80000b32 <initlock>
    p->kstack = KSTACK((int)(p - proc));
    80001cd0:	415487b3          	sub	a5,s1,s5
    80001cd4:	8791                	srai	a5,a5,0x4
    80001cd6:	000a3703          	ld	a4,0(s4)
    80001cda:	02e787b3          	mul	a5,a5,a4
    80001cde:	2785                	addiw	a5,a5,1
    80001ce0:	00d7979b          	slliw	a5,a5,0xd
    80001ce4:	40f907b3          	sub	a5,s2,a5
    80001ce8:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001cea:	49048493          	addi	s1,s1,1168
    80001cee:	fd349be3          	bne	s1,s3,80001cc4 <procinit+0x6e>
  }
}
    80001cf2:	70e2                	ld	ra,56(sp)
    80001cf4:	7442                	ld	s0,48(sp)
    80001cf6:	74a2                	ld	s1,40(sp)
    80001cf8:	7902                	ld	s2,32(sp)
    80001cfa:	69e2                	ld	s3,24(sp)
    80001cfc:	6a42                	ld	s4,16(sp)
    80001cfe:	6aa2                	ld	s5,8(sp)
    80001d00:	6b02                	ld	s6,0(sp)
    80001d02:	6121                	addi	sp,sp,64
    80001d04:	8082                	ret

0000000080001d06 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001d06:	1141                	addi	sp,sp,-16
    80001d08:	e422                	sd	s0,8(sp)
    80001d0a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d0c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001d0e:	2501                	sext.w	a0,a0
    80001d10:	6422                	ld	s0,8(sp)
    80001d12:	0141                	addi	sp,sp,16
    80001d14:	8082                	ret

0000000080001d16 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001d16:	1141                	addi	sp,sp,-16
    80001d18:	e422                	sd	s0,8(sp)
    80001d1a:	0800                	addi	s0,sp,16
    80001d1c:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001d1e:	2781                	sext.w	a5,a5
    80001d20:	079e                	slli	a5,a5,0x7
  return c;
}
    80001d22:	00010517          	auipc	a0,0x10
    80001d26:	5ae50513          	addi	a0,a0,1454 # 800122d0 <cpus>
    80001d2a:	953e                	add	a0,a0,a5
    80001d2c:	6422                	ld	s0,8(sp)
    80001d2e:	0141                	addi	sp,sp,16
    80001d30:	8082                	ret

0000000080001d32 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001d32:	1101                	addi	sp,sp,-32
    80001d34:	ec06                	sd	ra,24(sp)
    80001d36:	e822                	sd	s0,16(sp)
    80001d38:	e426                	sd	s1,8(sp)
    80001d3a:	1000                	addi	s0,sp,32
  push_off();
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	e3a080e7          	jalr	-454(ra) # 80000b76 <push_off>
    80001d44:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001d46:	2781                	sext.w	a5,a5
    80001d48:	079e                	slli	a5,a5,0x7
    80001d4a:	00010717          	auipc	a4,0x10
    80001d4e:	55670713          	addi	a4,a4,1366 # 800122a0 <pid_lock>
    80001d52:	97ba                	add	a5,a5,a4
    80001d54:	7b84                	ld	s1,48(a5)
  pop_off();
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	ec0080e7          	jalr	-320(ra) # 80000c16 <pop_off>
  return p;
}
    80001d5e:	8526                	mv	a0,s1
    80001d60:	60e2                	ld	ra,24(sp)
    80001d62:	6442                	ld	s0,16(sp)
    80001d64:	64a2                	ld	s1,8(sp)
    80001d66:	6105                	addi	sp,sp,32
    80001d68:	8082                	ret

0000000080001d6a <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001d6a:	1141                	addi	sp,sp,-16
    80001d6c:	e406                	sd	ra,8(sp)
    80001d6e:	e022                	sd	s0,0(sp)
    80001d70:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001d72:	00000097          	auipc	ra,0x0
    80001d76:	fc0080e7          	jalr	-64(ra) # 80001d32 <myproc>
    80001d7a:	fffff097          	auipc	ra,0xfffff
    80001d7e:	efc080e7          	jalr	-260(ra) # 80000c76 <release>

  if (first)
    80001d82:	00008797          	auipc	a5,0x8
    80001d86:	f5e7a783          	lw	a5,-162(a5) # 80009ce0 <first.1>
    80001d8a:	eb89                	bnez	a5,80001d9c <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001d8c:	00001097          	auipc	ra,0x1
    80001d90:	2a6080e7          	jalr	678(ra) # 80003032 <usertrapret>
}
    80001d94:	60a2                	ld	ra,8(sp)
    80001d96:	6402                	ld	s0,0(sp)
    80001d98:	0141                	addi	sp,sp,16
    80001d9a:	8082                	ret
    first = 0;
    80001d9c:	00008797          	auipc	a5,0x8
    80001da0:	f407a223          	sw	zero,-188(a5) # 80009ce0 <first.1>
    fsinit(ROOTDEV);
    80001da4:	4505                	li	a0,1
    80001da6:	00002097          	auipc	ra,0x2
    80001daa:	0d8080e7          	jalr	216(ra) # 80003e7e <fsinit>
    80001dae:	bff9                	j	80001d8c <forkret+0x22>

0000000080001db0 <allocpid>:
{
    80001db0:	1101                	addi	sp,sp,-32
    80001db2:	ec06                	sd	ra,24(sp)
    80001db4:	e822                	sd	s0,16(sp)
    80001db6:	e426                	sd	s1,8(sp)
    80001db8:	e04a                	sd	s2,0(sp)
    80001dba:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001dbc:	00010917          	auipc	s2,0x10
    80001dc0:	4e490913          	addi	s2,s2,1252 # 800122a0 <pid_lock>
    80001dc4:	854a                	mv	a0,s2
    80001dc6:	fffff097          	auipc	ra,0xfffff
    80001dca:	dfc080e7          	jalr	-516(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001dce:	00008797          	auipc	a5,0x8
    80001dd2:	f1678793          	addi	a5,a5,-234 # 80009ce4 <nextpid>
    80001dd6:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001dd8:	0014871b          	addiw	a4,s1,1
    80001ddc:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001dde:	854a                	mv	a0,s2
    80001de0:	fffff097          	auipc	ra,0xfffff
    80001de4:	e96080e7          	jalr	-362(ra) # 80000c76 <release>
}
    80001de8:	8526                	mv	a0,s1
    80001dea:	60e2                	ld	ra,24(sp)
    80001dec:	6442                	ld	s0,16(sp)
    80001dee:	64a2                	ld	s1,8(sp)
    80001df0:	6902                	ld	s2,0(sp)
    80001df2:	6105                	addi	sp,sp,32
    80001df4:	8082                	ret

0000000080001df6 <proc_pagetable>:
{
    80001df6:	1101                	addi	sp,sp,-32
    80001df8:	ec06                	sd	ra,24(sp)
    80001dfa:	e822                	sd	s0,16(sp)
    80001dfc:	e426                	sd	s1,8(sp)
    80001dfe:	e04a                	sd	s2,0(sp)
    80001e00:	1000                	addi	s0,sp,32
    80001e02:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001e04:	fffff097          	auipc	ra,0xfffff
    80001e08:	46a080e7          	jalr	1130(ra) # 8000126e <uvmcreate>
    80001e0c:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001e0e:	c121                	beqz	a0,80001e4e <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001e10:	4729                	li	a4,10
    80001e12:	00006697          	auipc	a3,0x6
    80001e16:	1ee68693          	addi	a3,a3,494 # 80008000 <_trampoline>
    80001e1a:	6605                	lui	a2,0x1
    80001e1c:	040005b7          	lui	a1,0x4000
    80001e20:	15fd                	addi	a1,a1,-1
    80001e22:	05b2                	slli	a1,a1,0xc
    80001e24:	fffff097          	auipc	ra,0xfffff
    80001e28:	296080e7          	jalr	662(ra) # 800010ba <mappages>
    80001e2c:	02054863          	bltz	a0,80001e5c <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001e30:	4719                	li	a4,6
    80001e32:	05893683          	ld	a3,88(s2)
    80001e36:	6605                	lui	a2,0x1
    80001e38:	020005b7          	lui	a1,0x2000
    80001e3c:	15fd                	addi	a1,a1,-1
    80001e3e:	05b6                	slli	a1,a1,0xd
    80001e40:	8526                	mv	a0,s1
    80001e42:	fffff097          	auipc	ra,0xfffff
    80001e46:	278080e7          	jalr	632(ra) # 800010ba <mappages>
    80001e4a:	02054163          	bltz	a0,80001e6c <proc_pagetable+0x76>
}
    80001e4e:	8526                	mv	a0,s1
    80001e50:	60e2                	ld	ra,24(sp)
    80001e52:	6442                	ld	s0,16(sp)
    80001e54:	64a2                	ld	s1,8(sp)
    80001e56:	6902                	ld	s2,0(sp)
    80001e58:	6105                	addi	sp,sp,32
    80001e5a:	8082                	ret
    uvmfree(pagetable, 0);
    80001e5c:	4581                	li	a1,0
    80001e5e:	8526                	mv	a0,s1
    80001e60:	00000097          	auipc	ra,0x0
    80001e64:	c30080e7          	jalr	-976(ra) # 80001a90 <uvmfree>
    return 0;
    80001e68:	4481                	li	s1,0
    80001e6a:	b7d5                	j	80001e4e <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e6c:	4681                	li	a3,0
    80001e6e:	4605                	li	a2,1
    80001e70:	040005b7          	lui	a1,0x4000
    80001e74:	15fd                	addi	a1,a1,-1
    80001e76:	05b2                	slli	a1,a1,0xc
    80001e78:	8526                	mv	a0,s1
    80001e7a:	00000097          	auipc	ra,0x0
    80001e7e:	8fe080e7          	jalr	-1794(ra) # 80001778 <uvmunmap>
    uvmfree(pagetable, 0);
    80001e82:	4581                	li	a1,0
    80001e84:	8526                	mv	a0,s1
    80001e86:	00000097          	auipc	ra,0x0
    80001e8a:	c0a080e7          	jalr	-1014(ra) # 80001a90 <uvmfree>
    return 0;
    80001e8e:	4481                	li	s1,0
    80001e90:	bf7d                	j	80001e4e <proc_pagetable+0x58>

0000000080001e92 <proc_freepagetable>:
{
    80001e92:	1101                	addi	sp,sp,-32
    80001e94:	ec06                	sd	ra,24(sp)
    80001e96:	e822                	sd	s0,16(sp)
    80001e98:	e426                	sd	s1,8(sp)
    80001e9a:	e04a                	sd	s2,0(sp)
    80001e9c:	1000                	addi	s0,sp,32
    80001e9e:	84aa                	mv	s1,a0
    80001ea0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ea2:	4681                	li	a3,0
    80001ea4:	4605                	li	a2,1
    80001ea6:	040005b7          	lui	a1,0x4000
    80001eaa:	15fd                	addi	a1,a1,-1
    80001eac:	05b2                	slli	a1,a1,0xc
    80001eae:	00000097          	auipc	ra,0x0
    80001eb2:	8ca080e7          	jalr	-1846(ra) # 80001778 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001eb6:	4681                	li	a3,0
    80001eb8:	4605                	li	a2,1
    80001eba:	020005b7          	lui	a1,0x2000
    80001ebe:	15fd                	addi	a1,a1,-1
    80001ec0:	05b6                	slli	a1,a1,0xd
    80001ec2:	8526                	mv	a0,s1
    80001ec4:	00000097          	auipc	ra,0x0
    80001ec8:	8b4080e7          	jalr	-1868(ra) # 80001778 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ecc:	85ca                	mv	a1,s2
    80001ece:	8526                	mv	a0,s1
    80001ed0:	00000097          	auipc	ra,0x0
    80001ed4:	bc0080e7          	jalr	-1088(ra) # 80001a90 <uvmfree>
}
    80001ed8:	60e2                	ld	ra,24(sp)
    80001eda:	6442                	ld	s0,16(sp)
    80001edc:	64a2                	ld	s1,8(sp)
    80001ede:	6902                	ld	s2,0(sp)
    80001ee0:	6105                	addi	sp,sp,32
    80001ee2:	8082                	ret

0000000080001ee4 <freeproc>:
{
    80001ee4:	1101                	addi	sp,sp,-32
    80001ee6:	ec06                	sd	ra,24(sp)
    80001ee8:	e822                	sd	s0,16(sp)
    80001eea:	e426                	sd	s1,8(sp)
    80001eec:	1000                	addi	s0,sp,32
    80001eee:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001ef0:	6d28                	ld	a0,88(a0)
    80001ef2:	c509                	beqz	a0,80001efc <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001ef4:	fffff097          	auipc	ra,0xfffff
    80001ef8:	ae2080e7          	jalr	-1310(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001efc:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001f00:	68a8                	ld	a0,80(s1)
    80001f02:	c511                	beqz	a0,80001f0e <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001f04:	64ac                	ld	a1,72(s1)
    80001f06:	00000097          	auipc	ra,0x0
    80001f0a:	f8c080e7          	jalr	-116(ra) # 80001e92 <proc_freepagetable>
  p->pagetable = 0;
    80001f0e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001f12:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001f16:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001f1a:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001f1e:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001f22:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001f26:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001f2a:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001f2e:	0004ac23          	sw	zero,24(s1)
  p->paging_time = 0;
    80001f32:	4804b423          	sd	zero,1160(s1)
}
    80001f36:	60e2                	ld	ra,24(sp)
    80001f38:	6442                	ld	s0,16(sp)
    80001f3a:	64a2                	ld	s1,8(sp)
    80001f3c:	6105                	addi	sp,sp,32
    80001f3e:	8082                	ret

0000000080001f40 <allocproc>:
{
    80001f40:	1101                	addi	sp,sp,-32
    80001f42:	ec06                	sd	ra,24(sp)
    80001f44:	e822                	sd	s0,16(sp)
    80001f46:	e426                	sd	s1,8(sp)
    80001f48:	e04a                	sd	s2,0(sp)
    80001f4a:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001f4c:	00010497          	auipc	s1,0x10
    80001f50:	78448493          	addi	s1,s1,1924 # 800126d0 <proc>
    80001f54:	00023917          	auipc	s2,0x23
    80001f58:	b7c90913          	addi	s2,s2,-1156 # 80024ad0 <tickslock>
    acquire(&p->lock);
    80001f5c:	8526                	mv	a0,s1
    80001f5e:	fffff097          	auipc	ra,0xfffff
    80001f62:	c64080e7          	jalr	-924(ra) # 80000bc2 <acquire>
    if (p->state == UNUSED)
    80001f66:	4c9c                	lw	a5,24(s1)
    80001f68:	cf81                	beqz	a5,80001f80 <allocproc+0x40>
      release(&p->lock);
    80001f6a:	8526                	mv	a0,s1
    80001f6c:	fffff097          	auipc	ra,0xfffff
    80001f70:	d0a080e7          	jalr	-758(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001f74:	49048493          	addi	s1,s1,1168
    80001f78:	ff2492e3          	bne	s1,s2,80001f5c <allocproc+0x1c>
  return 0;
    80001f7c:	4481                	li	s1,0
    80001f7e:	a09d                	j	80001fe4 <allocproc+0xa4>
  p->pid = allocpid();
    80001f80:	00000097          	auipc	ra,0x0
    80001f84:	e30080e7          	jalr	-464(ra) # 80001db0 <allocpid>
    80001f88:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001f8a:	4785                	li	a5,1
    80001f8c:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001f8e:	fffff097          	auipc	ra,0xfffff
    80001f92:	b44080e7          	jalr	-1212(ra) # 80000ad2 <kalloc>
    80001f96:	892a                	mv	s2,a0
    80001f98:	eca8                	sd	a0,88(s1)
    80001f9a:	cd21                	beqz	a0,80001ff2 <allocproc+0xb2>
  p->pagetable = proc_pagetable(p);
    80001f9c:	8526                	mv	a0,s1
    80001f9e:	00000097          	auipc	ra,0x0
    80001fa2:	e58080e7          	jalr	-424(ra) # 80001df6 <proc_pagetable>
    80001fa6:	892a                	mv	s2,a0
    80001fa8:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001faa:	c125                	beqz	a0,8000200a <allocproc+0xca>
  memset(&p->context, 0, sizeof(p->context));
    80001fac:	07000613          	li	a2,112
    80001fb0:	4581                	li	a1,0
    80001fb2:	06048513          	addi	a0,s1,96
    80001fb6:	fffff097          	auipc	ra,0xfffff
    80001fba:	d08080e7          	jalr	-760(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80001fbe:	00000797          	auipc	a5,0x0
    80001fc2:	dac78793          	addi	a5,a5,-596 # 80001d6a <forkret>
    80001fc6:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001fc8:	60bc                	ld	a5,64(s1)
    80001fca:	6705                	lui	a4,0x1
    80001fcc:	97ba                	add	a5,a5,a4
    80001fce:	f4bc                	sd	a5,104(s1)
  p->physical_pages_num = 0;
    80001fd0:	1604a823          	sw	zero,368(s1)
  p->total_pages_num = 0;
    80001fd4:	1604aa23          	sw	zero,372(s1)
  p->pages_physc_info.free_spaces = 0;
    80001fd8:	30049023          	sh	zero,768(s1)
  p->pages_swap_info.free_spaces = 0;
    80001fdc:	16049c23          	sh	zero,376(s1)
  p->paging_time = 0;
    80001fe0:	4804b423          	sd	zero,1160(s1)
}
    80001fe4:	8526                	mv	a0,s1
    80001fe6:	60e2                	ld	ra,24(sp)
    80001fe8:	6442                	ld	s0,16(sp)
    80001fea:	64a2                	ld	s1,8(sp)
    80001fec:	6902                	ld	s2,0(sp)
    80001fee:	6105                	addi	sp,sp,32
    80001ff0:	8082                	ret
    freeproc(p);
    80001ff2:	8526                	mv	a0,s1
    80001ff4:	00000097          	auipc	ra,0x0
    80001ff8:	ef0080e7          	jalr	-272(ra) # 80001ee4 <freeproc>
    release(&p->lock);
    80001ffc:	8526                	mv	a0,s1
    80001ffe:	fffff097          	auipc	ra,0xfffff
    80002002:	c78080e7          	jalr	-904(ra) # 80000c76 <release>
    return 0;
    80002006:	84ca                	mv	s1,s2
    80002008:	bff1                	j	80001fe4 <allocproc+0xa4>
    freeproc(p);
    8000200a:	8526                	mv	a0,s1
    8000200c:	00000097          	auipc	ra,0x0
    80002010:	ed8080e7          	jalr	-296(ra) # 80001ee4 <freeproc>
    release(&p->lock);
    80002014:	8526                	mv	a0,s1
    80002016:	fffff097          	auipc	ra,0xfffff
    8000201a:	c60080e7          	jalr	-928(ra) # 80000c76 <release>
    return 0;
    8000201e:	84ca                	mv	s1,s2
    80002020:	b7d1                	j	80001fe4 <allocproc+0xa4>

0000000080002022 <userinit>:
{
    80002022:	1101                	addi	sp,sp,-32
    80002024:	ec06                	sd	ra,24(sp)
    80002026:	e822                	sd	s0,16(sp)
    80002028:	e426                	sd	s1,8(sp)
    8000202a:	1000                	addi	s0,sp,32
  p = allocproc();
    8000202c:	00000097          	auipc	ra,0x0
    80002030:	f14080e7          	jalr	-236(ra) # 80001f40 <allocproc>
    80002034:	84aa                	mv	s1,a0
  initproc = p;
    80002036:	00008797          	auipc	a5,0x8
    8000203a:	fea7b923          	sd	a0,-14(a5) # 8000a028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    8000203e:	03400613          	li	a2,52
    80002042:	00008597          	auipc	a1,0x8
    80002046:	cae58593          	addi	a1,a1,-850 # 80009cf0 <initcode>
    8000204a:	6928                	ld	a0,80(a0)
    8000204c:	fffff097          	auipc	ra,0xfffff
    80002050:	250080e7          	jalr	592(ra) # 8000129c <uvminit>
  p->sz = PGSIZE;
    80002054:	6785                	lui	a5,0x1
    80002056:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80002058:	6cb8                	ld	a4,88(s1)
    8000205a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    8000205e:	6cb8                	ld	a4,88(s1)
    80002060:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002062:	4641                	li	a2,16
    80002064:	00007597          	auipc	a1,0x7
    80002068:	38c58593          	addi	a1,a1,908 # 800093f0 <digits+0x3b0>
    8000206c:	15848513          	addi	a0,s1,344
    80002070:	fffff097          	auipc	ra,0xfffff
    80002074:	da0080e7          	jalr	-608(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80002078:	00007517          	auipc	a0,0x7
    8000207c:	38850513          	addi	a0,a0,904 # 80009400 <digits+0x3c0>
    80002080:	00003097          	auipc	ra,0x3
    80002084:	82c080e7          	jalr	-2004(ra) # 800048ac <namei>
    80002088:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000208c:	478d                	li	a5,3
    8000208e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80002090:	8526                	mv	a0,s1
    80002092:	fffff097          	auipc	ra,0xfffff
    80002096:	be4080e7          	jalr	-1052(ra) # 80000c76 <release>
}
    8000209a:	60e2                	ld	ra,24(sp)
    8000209c:	6442                	ld	s0,16(sp)
    8000209e:	64a2                	ld	s1,8(sp)
    800020a0:	6105                	addi	sp,sp,32
    800020a2:	8082                	ret

00000000800020a4 <growproc>:
{
    800020a4:	1101                	addi	sp,sp,-32
    800020a6:	ec06                	sd	ra,24(sp)
    800020a8:	e822                	sd	s0,16(sp)
    800020aa:	e426                	sd	s1,8(sp)
    800020ac:	e04a                	sd	s2,0(sp)
    800020ae:	1000                	addi	s0,sp,32
    800020b0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800020b2:	00000097          	auipc	ra,0x0
    800020b6:	c80080e7          	jalr	-896(ra) # 80001d32 <myproc>
    800020ba:	892a                	mv	s2,a0
  sz = p->sz;
    800020bc:	652c                	ld	a1,72(a0)
    800020be:	0005861b          	sext.w	a2,a1
  if (n > 0)
    800020c2:	00904f63          	bgtz	s1,800020e0 <growproc+0x3c>
  else if (n < 0)
    800020c6:	0204cc63          	bltz	s1,800020fe <growproc+0x5a>
  p->sz = sz;
    800020ca:	1602                	slli	a2,a2,0x20
    800020cc:	9201                	srli	a2,a2,0x20
    800020ce:	04c93423          	sd	a2,72(s2)
  return 0;
    800020d2:	4501                	li	a0,0
}
    800020d4:	60e2                	ld	ra,24(sp)
    800020d6:	6442                	ld	s0,16(sp)
    800020d8:	64a2                	ld	s1,8(sp)
    800020da:	6902                	ld	s2,0(sp)
    800020dc:	6105                	addi	sp,sp,32
    800020de:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0)
    800020e0:	9e25                	addw	a2,a2,s1
    800020e2:	1602                	slli	a2,a2,0x20
    800020e4:	9201                	srli	a2,a2,0x20
    800020e6:	1582                	slli	a1,a1,0x20
    800020e8:	9181                	srli	a1,a1,0x20
    800020ea:	6928                	ld	a0,80(a0)
    800020ec:	00000097          	auipc	ra,0x0
    800020f0:	834080e7          	jalr	-1996(ra) # 80001920 <uvmalloc>
    800020f4:	0005061b          	sext.w	a2,a0
    800020f8:	fa69                	bnez	a2,800020ca <growproc+0x26>
      return -1;
    800020fa:	557d                	li	a0,-1
    800020fc:	bfe1                	j	800020d4 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800020fe:	9e25                	addw	a2,a2,s1
    80002100:	1602                	slli	a2,a2,0x20
    80002102:	9201                	srli	a2,a2,0x20
    80002104:	1582                	slli	a1,a1,0x20
    80002106:	9181                	srli	a1,a1,0x20
    80002108:	6928                	ld	a0,80(a0)
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	7ce080e7          	jalr	1998(ra) # 800018d8 <uvmdealloc>
    80002112:	0005061b          	sext.w	a2,a0
    80002116:	bf55                	j	800020ca <growproc+0x26>

0000000080002118 <sched>:
{
    80002118:	7179                	addi	sp,sp,-48
    8000211a:	f406                	sd	ra,40(sp)
    8000211c:	f022                	sd	s0,32(sp)
    8000211e:	ec26                	sd	s1,24(sp)
    80002120:	e84a                	sd	s2,16(sp)
    80002122:	e44e                	sd	s3,8(sp)
    80002124:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002126:	00000097          	auipc	ra,0x0
    8000212a:	c0c080e7          	jalr	-1012(ra) # 80001d32 <myproc>
    8000212e:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002130:	fffff097          	auipc	ra,0xfffff
    80002134:	a18080e7          	jalr	-1512(ra) # 80000b48 <holding>
    80002138:	c93d                	beqz	a0,800021ae <sched+0x96>
    8000213a:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000213c:	2781                	sext.w	a5,a5
    8000213e:	079e                	slli	a5,a5,0x7
    80002140:	00010717          	auipc	a4,0x10
    80002144:	16070713          	addi	a4,a4,352 # 800122a0 <pid_lock>
    80002148:	97ba                	add	a5,a5,a4
    8000214a:	0a87a703          	lw	a4,168(a5) # 10a8 <_entry-0x7fffef58>
    8000214e:	4785                	li	a5,1
    80002150:	06f71763          	bne	a4,a5,800021be <sched+0xa6>
  if (p->state == RUNNING)
    80002154:	4c98                	lw	a4,24(s1)
    80002156:	4791                	li	a5,4
    80002158:	06f70b63          	beq	a4,a5,800021ce <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000215c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002160:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002162:	efb5                	bnez	a5,800021de <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002164:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002166:	00010917          	auipc	s2,0x10
    8000216a:	13a90913          	addi	s2,s2,314 # 800122a0 <pid_lock>
    8000216e:	2781                	sext.w	a5,a5
    80002170:	079e                	slli	a5,a5,0x7
    80002172:	97ca                	add	a5,a5,s2
    80002174:	0ac7a983          	lw	s3,172(a5)
    80002178:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000217a:	2781                	sext.w	a5,a5
    8000217c:	079e                	slli	a5,a5,0x7
    8000217e:	00010597          	auipc	a1,0x10
    80002182:	15a58593          	addi	a1,a1,346 # 800122d8 <cpus+0x8>
    80002186:	95be                	add	a1,a1,a5
    80002188:	06048513          	addi	a0,s1,96
    8000218c:	00001097          	auipc	ra,0x1
    80002190:	dfc080e7          	jalr	-516(ra) # 80002f88 <swtch>
    80002194:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002196:	2781                	sext.w	a5,a5
    80002198:	079e                	slli	a5,a5,0x7
    8000219a:	97ca                	add	a5,a5,s2
    8000219c:	0b37a623          	sw	s3,172(a5)
}
    800021a0:	70a2                	ld	ra,40(sp)
    800021a2:	7402                	ld	s0,32(sp)
    800021a4:	64e2                	ld	s1,24(sp)
    800021a6:	6942                	ld	s2,16(sp)
    800021a8:	69a2                	ld	s3,8(sp)
    800021aa:	6145                	addi	sp,sp,48
    800021ac:	8082                	ret
    panic("sched p->lock");
    800021ae:	00007517          	auipc	a0,0x7
    800021b2:	25a50513          	addi	a0,a0,602 # 80009408 <digits+0x3c8>
    800021b6:	ffffe097          	auipc	ra,0xffffe
    800021ba:	374080e7          	jalr	884(ra) # 8000052a <panic>
    panic("sched locks");
    800021be:	00007517          	auipc	a0,0x7
    800021c2:	25a50513          	addi	a0,a0,602 # 80009418 <digits+0x3d8>
    800021c6:	ffffe097          	auipc	ra,0xffffe
    800021ca:	364080e7          	jalr	868(ra) # 8000052a <panic>
    panic("sched running");
    800021ce:	00007517          	auipc	a0,0x7
    800021d2:	25a50513          	addi	a0,a0,602 # 80009428 <digits+0x3e8>
    800021d6:	ffffe097          	auipc	ra,0xffffe
    800021da:	354080e7          	jalr	852(ra) # 8000052a <panic>
    panic("sched interruptible");
    800021de:	00007517          	auipc	a0,0x7
    800021e2:	25a50513          	addi	a0,a0,602 # 80009438 <digits+0x3f8>
    800021e6:	ffffe097          	auipc	ra,0xffffe
    800021ea:	344080e7          	jalr	836(ra) # 8000052a <panic>

00000000800021ee <yield>:
{
    800021ee:	1101                	addi	sp,sp,-32
    800021f0:	ec06                	sd	ra,24(sp)
    800021f2:	e822                	sd	s0,16(sp)
    800021f4:	e426                	sd	s1,8(sp)
    800021f6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021f8:	00000097          	auipc	ra,0x0
    800021fc:	b3a080e7          	jalr	-1222(ra) # 80001d32 <myproc>
    80002200:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002202:	fffff097          	auipc	ra,0xfffff
    80002206:	9c0080e7          	jalr	-1600(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    8000220a:	478d                	li	a5,3
    8000220c:	cc9c                	sw	a5,24(s1)
  sched();
    8000220e:	00000097          	auipc	ra,0x0
    80002212:	f0a080e7          	jalr	-246(ra) # 80002118 <sched>
  release(&p->lock);
    80002216:	8526                	mv	a0,s1
    80002218:	fffff097          	auipc	ra,0xfffff
    8000221c:	a5e080e7          	jalr	-1442(ra) # 80000c76 <release>
}
    80002220:	60e2                	ld	ra,24(sp)
    80002222:	6442                	ld	s0,16(sp)
    80002224:	64a2                	ld	s1,8(sp)
    80002226:	6105                	addi	sp,sp,32
    80002228:	8082                	ret

000000008000222a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000222a:	7179                	addi	sp,sp,-48
    8000222c:	f406                	sd	ra,40(sp)
    8000222e:	f022                	sd	s0,32(sp)
    80002230:	ec26                	sd	s1,24(sp)
    80002232:	e84a                	sd	s2,16(sp)
    80002234:	e44e                	sd	s3,8(sp)
    80002236:	1800                	addi	s0,sp,48
    80002238:	89aa                	mv	s3,a0
    8000223a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000223c:	00000097          	auipc	ra,0x0
    80002240:	af6080e7          	jalr	-1290(ra) # 80001d32 <myproc>
    80002244:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); //DOC: sleeplock1
    80002246:	fffff097          	auipc	ra,0xfffff
    8000224a:	97c080e7          	jalr	-1668(ra) # 80000bc2 <acquire>
  release(lk);
    8000224e:	854a                	mv	a0,s2
    80002250:	fffff097          	auipc	ra,0xfffff
    80002254:	a26080e7          	jalr	-1498(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    80002258:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000225c:	4789                	li	a5,2
    8000225e:	cc9c                	sw	a5,24(s1)

  sched();
    80002260:	00000097          	auipc	ra,0x0
    80002264:	eb8080e7          	jalr	-328(ra) # 80002118 <sched>

  // Tidy up.
  p->chan = 0;
    80002268:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000226c:	8526                	mv	a0,s1
    8000226e:	fffff097          	auipc	ra,0xfffff
    80002272:	a08080e7          	jalr	-1528(ra) # 80000c76 <release>
  acquire(lk);
    80002276:	854a                	mv	a0,s2
    80002278:	fffff097          	auipc	ra,0xfffff
    8000227c:	94a080e7          	jalr	-1718(ra) # 80000bc2 <acquire>
}
    80002280:	70a2                	ld	ra,40(sp)
    80002282:	7402                	ld	s0,32(sp)
    80002284:	64e2                	ld	s1,24(sp)
    80002286:	6942                	ld	s2,16(sp)
    80002288:	69a2                	ld	s3,8(sp)
    8000228a:	6145                	addi	sp,sp,48
    8000228c:	8082                	ret

000000008000228e <wait>:
{
    8000228e:	715d                	addi	sp,sp,-80
    80002290:	e486                	sd	ra,72(sp)
    80002292:	e0a2                	sd	s0,64(sp)
    80002294:	fc26                	sd	s1,56(sp)
    80002296:	f84a                	sd	s2,48(sp)
    80002298:	f44e                	sd	s3,40(sp)
    8000229a:	f052                	sd	s4,32(sp)
    8000229c:	ec56                	sd	s5,24(sp)
    8000229e:	e85a                	sd	s6,16(sp)
    800022a0:	e45e                	sd	s7,8(sp)
    800022a2:	e062                	sd	s8,0(sp)
    800022a4:	0880                	addi	s0,sp,80
    800022a6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022a8:	00000097          	auipc	ra,0x0
    800022ac:	a8a080e7          	jalr	-1398(ra) # 80001d32 <myproc>
    800022b0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800022b2:	00010517          	auipc	a0,0x10
    800022b6:	00650513          	addi	a0,a0,6 # 800122b8 <wait_lock>
    800022ba:	fffff097          	auipc	ra,0xfffff
    800022be:	908080e7          	jalr	-1784(ra) # 80000bc2 <acquire>
    havekids = 0;
    800022c2:	4b81                	li	s7,0
        if (np->state == ZOMBIE)
    800022c4:	4a15                	li	s4,5
        havekids = 1;
    800022c6:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800022c8:	00023997          	auipc	s3,0x23
    800022cc:	80898993          	addi	s3,s3,-2040 # 80024ad0 <tickslock>
    sleep(p, &wait_lock); //DOC: wait-sleep
    800022d0:	00010c17          	auipc	s8,0x10
    800022d4:	fe8c0c13          	addi	s8,s8,-24 # 800122b8 <wait_lock>
    havekids = 0;
    800022d8:	875e                	mv	a4,s7
    for (np = proc; np < &proc[NPROC]; np++)
    800022da:	00010497          	auipc	s1,0x10
    800022de:	3f648493          	addi	s1,s1,1014 # 800126d0 <proc>
    800022e2:	a0bd                	j	80002350 <wait+0xc2>
          pid = np->pid;
    800022e4:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022e8:	000b0e63          	beqz	s6,80002304 <wait+0x76>
    800022ec:	4691                	li	a3,4
    800022ee:	02c48613          	addi	a2,s1,44
    800022f2:	85da                	mv	a1,s6
    800022f4:	05093503          	ld	a0,80(s2)
    800022f8:	fffff097          	auipc	ra,0xfffff
    800022fc:	0b2080e7          	jalr	178(ra) # 800013aa <copyout>
    80002300:	02054563          	bltz	a0,8000232a <wait+0x9c>
          freeproc(np);
    80002304:	8526                	mv	a0,s1
    80002306:	00000097          	auipc	ra,0x0
    8000230a:	bde080e7          	jalr	-1058(ra) # 80001ee4 <freeproc>
          release(&np->lock);
    8000230e:	8526                	mv	a0,s1
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	966080e7          	jalr	-1690(ra) # 80000c76 <release>
          release(&wait_lock);
    80002318:	00010517          	auipc	a0,0x10
    8000231c:	fa050513          	addi	a0,a0,-96 # 800122b8 <wait_lock>
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	956080e7          	jalr	-1706(ra) # 80000c76 <release>
          return pid;
    80002328:	a09d                	j	8000238e <wait+0x100>
            release(&np->lock);
    8000232a:	8526                	mv	a0,s1
    8000232c:	fffff097          	auipc	ra,0xfffff
    80002330:	94a080e7          	jalr	-1718(ra) # 80000c76 <release>
            release(&wait_lock);
    80002334:	00010517          	auipc	a0,0x10
    80002338:	f8450513          	addi	a0,a0,-124 # 800122b8 <wait_lock>
    8000233c:	fffff097          	auipc	ra,0xfffff
    80002340:	93a080e7          	jalr	-1734(ra) # 80000c76 <release>
            return -1;
    80002344:	59fd                	li	s3,-1
    80002346:	a0a1                	j	8000238e <wait+0x100>
    for (np = proc; np < &proc[NPROC]; np++)
    80002348:	49048493          	addi	s1,s1,1168
    8000234c:	03348463          	beq	s1,s3,80002374 <wait+0xe6>
      if (np->parent == p)
    80002350:	7c9c                	ld	a5,56(s1)
    80002352:	ff279be3          	bne	a5,s2,80002348 <wait+0xba>
        acquire(&np->lock);
    80002356:	8526                	mv	a0,s1
    80002358:	fffff097          	auipc	ra,0xfffff
    8000235c:	86a080e7          	jalr	-1942(ra) # 80000bc2 <acquire>
        if (np->state == ZOMBIE)
    80002360:	4c9c                	lw	a5,24(s1)
    80002362:	f94781e3          	beq	a5,s4,800022e4 <wait+0x56>
        release(&np->lock);
    80002366:	8526                	mv	a0,s1
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	90e080e7          	jalr	-1778(ra) # 80000c76 <release>
        havekids = 1;
    80002370:	8756                	mv	a4,s5
    80002372:	bfd9                	j	80002348 <wait+0xba>
    if (!havekids || p->killed)
    80002374:	c701                	beqz	a4,8000237c <wait+0xee>
    80002376:	02892783          	lw	a5,40(s2)
    8000237a:	c79d                	beqz	a5,800023a8 <wait+0x11a>
      release(&wait_lock);
    8000237c:	00010517          	auipc	a0,0x10
    80002380:	f3c50513          	addi	a0,a0,-196 # 800122b8 <wait_lock>
    80002384:	fffff097          	auipc	ra,0xfffff
    80002388:	8f2080e7          	jalr	-1806(ra) # 80000c76 <release>
      return -1;
    8000238c:	59fd                	li	s3,-1
}
    8000238e:	854e                	mv	a0,s3
    80002390:	60a6                	ld	ra,72(sp)
    80002392:	6406                	ld	s0,64(sp)
    80002394:	74e2                	ld	s1,56(sp)
    80002396:	7942                	ld	s2,48(sp)
    80002398:	79a2                	ld	s3,40(sp)
    8000239a:	7a02                	ld	s4,32(sp)
    8000239c:	6ae2                	ld	s5,24(sp)
    8000239e:	6b42                	ld	s6,16(sp)
    800023a0:	6ba2                	ld	s7,8(sp)
    800023a2:	6c02                	ld	s8,0(sp)
    800023a4:	6161                	addi	sp,sp,80
    800023a6:	8082                	ret
    sleep(p, &wait_lock); //DOC: wait-sleep
    800023a8:	85e2                	mv	a1,s8
    800023aa:	854a                	mv	a0,s2
    800023ac:	00000097          	auipc	ra,0x0
    800023b0:	e7e080e7          	jalr	-386(ra) # 8000222a <sleep>
    havekids = 0;
    800023b4:	b715                	j	800022d8 <wait+0x4a>

00000000800023b6 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800023b6:	7139                	addi	sp,sp,-64
    800023b8:	fc06                	sd	ra,56(sp)
    800023ba:	f822                	sd	s0,48(sp)
    800023bc:	f426                	sd	s1,40(sp)
    800023be:	f04a                	sd	s2,32(sp)
    800023c0:	ec4e                	sd	s3,24(sp)
    800023c2:	e852                	sd	s4,16(sp)
    800023c4:	e456                	sd	s5,8(sp)
    800023c6:	0080                	addi	s0,sp,64
    800023c8:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800023ca:	00010497          	auipc	s1,0x10
    800023ce:	30648493          	addi	s1,s1,774 # 800126d0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800023d2:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800023d4:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800023d6:	00022917          	auipc	s2,0x22
    800023da:	6fa90913          	addi	s2,s2,1786 # 80024ad0 <tickslock>
    800023de:	a811                	j	800023f2 <wakeup+0x3c>
      }
      release(&p->lock);
    800023e0:	8526                	mv	a0,s1
    800023e2:	fffff097          	auipc	ra,0xfffff
    800023e6:	894080e7          	jalr	-1900(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800023ea:	49048493          	addi	s1,s1,1168
    800023ee:	03248663          	beq	s1,s2,8000241a <wakeup+0x64>
    if (p != myproc())
    800023f2:	00000097          	auipc	ra,0x0
    800023f6:	940080e7          	jalr	-1728(ra) # 80001d32 <myproc>
    800023fa:	fea488e3          	beq	s1,a0,800023ea <wakeup+0x34>
      acquire(&p->lock);
    800023fe:	8526                	mv	a0,s1
    80002400:	ffffe097          	auipc	ra,0xffffe
    80002404:	7c2080e7          	jalr	1986(ra) # 80000bc2 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002408:	4c9c                	lw	a5,24(s1)
    8000240a:	fd379be3          	bne	a5,s3,800023e0 <wakeup+0x2a>
    8000240e:	709c                	ld	a5,32(s1)
    80002410:	fd4798e3          	bne	a5,s4,800023e0 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002414:	0154ac23          	sw	s5,24(s1)
    80002418:	b7e1                	j	800023e0 <wakeup+0x2a>
    }
  }
}
    8000241a:	70e2                	ld	ra,56(sp)
    8000241c:	7442                	ld	s0,48(sp)
    8000241e:	74a2                	ld	s1,40(sp)
    80002420:	7902                	ld	s2,32(sp)
    80002422:	69e2                	ld	s3,24(sp)
    80002424:	6a42                	ld	s4,16(sp)
    80002426:	6aa2                	ld	s5,8(sp)
    80002428:	6121                	addi	sp,sp,64
    8000242a:	8082                	ret

000000008000242c <reparent>:
{
    8000242c:	7179                	addi	sp,sp,-48
    8000242e:	f406                	sd	ra,40(sp)
    80002430:	f022                	sd	s0,32(sp)
    80002432:	ec26                	sd	s1,24(sp)
    80002434:	e84a                	sd	s2,16(sp)
    80002436:	e44e                	sd	s3,8(sp)
    80002438:	e052                	sd	s4,0(sp)
    8000243a:	1800                	addi	s0,sp,48
    8000243c:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000243e:	00010497          	auipc	s1,0x10
    80002442:	29248493          	addi	s1,s1,658 # 800126d0 <proc>
      pp->parent = initproc;
    80002446:	00008a17          	auipc	s4,0x8
    8000244a:	be2a0a13          	addi	s4,s4,-1054 # 8000a028 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000244e:	00022997          	auipc	s3,0x22
    80002452:	68298993          	addi	s3,s3,1666 # 80024ad0 <tickslock>
    80002456:	a029                	j	80002460 <reparent+0x34>
    80002458:	49048493          	addi	s1,s1,1168
    8000245c:	01348d63          	beq	s1,s3,80002476 <reparent+0x4a>
    if (pp->parent == p)
    80002460:	7c9c                	ld	a5,56(s1)
    80002462:	ff279be3          	bne	a5,s2,80002458 <reparent+0x2c>
      pp->parent = initproc;
    80002466:	000a3503          	ld	a0,0(s4)
    8000246a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000246c:	00000097          	auipc	ra,0x0
    80002470:	f4a080e7          	jalr	-182(ra) # 800023b6 <wakeup>
    80002474:	b7d5                	j	80002458 <reparent+0x2c>
}
    80002476:	70a2                	ld	ra,40(sp)
    80002478:	7402                	ld	s0,32(sp)
    8000247a:	64e2                	ld	s1,24(sp)
    8000247c:	6942                	ld	s2,16(sp)
    8000247e:	69a2                	ld	s3,8(sp)
    80002480:	6a02                	ld	s4,0(sp)
    80002482:	6145                	addi	sp,sp,48
    80002484:	8082                	ret

0000000080002486 <exit>:
{
    80002486:	7179                	addi	sp,sp,-48
    80002488:	f406                	sd	ra,40(sp)
    8000248a:	f022                	sd	s0,32(sp)
    8000248c:	ec26                	sd	s1,24(sp)
    8000248e:	e84a                	sd	s2,16(sp)
    80002490:	e44e                	sd	s3,8(sp)
    80002492:	e052                	sd	s4,0(sp)
    80002494:	1800                	addi	s0,sp,48
    80002496:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002498:	00000097          	auipc	ra,0x0
    8000249c:	89a080e7          	jalr	-1894(ra) # 80001d32 <myproc>
    800024a0:	89aa                	mv	s3,a0
  if (p == initproc)
    800024a2:	00008797          	auipc	a5,0x8
    800024a6:	b867b783          	ld	a5,-1146(a5) # 8000a028 <initproc>
    800024aa:	0d050493          	addi	s1,a0,208
    800024ae:	15050913          	addi	s2,a0,336
    800024b2:	02a79363          	bne	a5,a0,800024d8 <exit+0x52>
    panic("init exiting");
    800024b6:	00007517          	auipc	a0,0x7
    800024ba:	f9a50513          	addi	a0,a0,-102 # 80009450 <digits+0x410>
    800024be:	ffffe097          	auipc	ra,0xffffe
    800024c2:	06c080e7          	jalr	108(ra) # 8000052a <panic>
      fileclose(f);
    800024c6:	00003097          	auipc	ra,0x3
    800024ca:	de4080e7          	jalr	-540(ra) # 800052aa <fileclose>
      p->ofile[fd] = 0;
    800024ce:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800024d2:	04a1                	addi	s1,s1,8
    800024d4:	01248563          	beq	s1,s2,800024de <exit+0x58>
    if (p->ofile[fd])
    800024d8:	6088                	ld	a0,0(s1)
    800024da:	f575                	bnez	a0,800024c6 <exit+0x40>
    800024dc:	bfdd                	j	800024d2 <exit+0x4c>
  removeSwapFile(p); // Remove swap file of p
    800024de:	854e                	mv	a0,s3
    800024e0:	00002097          	auipc	ra,0x2
    800024e4:	478080e7          	jalr	1144(ra) # 80004958 <removeSwapFile>
  begin_op();
    800024e8:	00003097          	auipc	ra,0x3
    800024ec:	8f6080e7          	jalr	-1802(ra) # 80004dde <begin_op>
  iput(p->cwd);
    800024f0:	1509b503          	ld	a0,336(s3)
    800024f4:	00002097          	auipc	ra,0x2
    800024f8:	dbc080e7          	jalr	-580(ra) # 800042b0 <iput>
  end_op();
    800024fc:	00003097          	auipc	ra,0x3
    80002500:	962080e7          	jalr	-1694(ra) # 80004e5e <end_op>
  p->cwd = 0;
    80002504:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002508:	00010497          	auipc	s1,0x10
    8000250c:	db048493          	addi	s1,s1,-592 # 800122b8 <wait_lock>
    80002510:	8526                	mv	a0,s1
    80002512:	ffffe097          	auipc	ra,0xffffe
    80002516:	6b0080e7          	jalr	1712(ra) # 80000bc2 <acquire>
  reparent(p);
    8000251a:	854e                	mv	a0,s3
    8000251c:	00000097          	auipc	ra,0x0
    80002520:	f10080e7          	jalr	-240(ra) # 8000242c <reparent>
  wakeup(p->parent);
    80002524:	0389b503          	ld	a0,56(s3)
    80002528:	00000097          	auipc	ra,0x0
    8000252c:	e8e080e7          	jalr	-370(ra) # 800023b6 <wakeup>
  acquire(&p->lock);
    80002530:	854e                	mv	a0,s3
    80002532:	ffffe097          	auipc	ra,0xffffe
    80002536:	690080e7          	jalr	1680(ra) # 80000bc2 <acquire>
  p->xstate = status;
    8000253a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000253e:	4795                	li	a5,5
    80002540:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002544:	8526                	mv	a0,s1
    80002546:	ffffe097          	auipc	ra,0xffffe
    8000254a:	730080e7          	jalr	1840(ra) # 80000c76 <release>
  sched();
    8000254e:	00000097          	auipc	ra,0x0
    80002552:	bca080e7          	jalr	-1078(ra) # 80002118 <sched>
  panic("zombie exit");
    80002556:	00007517          	auipc	a0,0x7
    8000255a:	f0a50513          	addi	a0,a0,-246 # 80009460 <digits+0x420>
    8000255e:	ffffe097          	auipc	ra,0xffffe
    80002562:	fcc080e7          	jalr	-52(ra) # 8000052a <panic>

0000000080002566 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002566:	7179                	addi	sp,sp,-48
    80002568:	f406                	sd	ra,40(sp)
    8000256a:	f022                	sd	s0,32(sp)
    8000256c:	ec26                	sd	s1,24(sp)
    8000256e:	e84a                	sd	s2,16(sp)
    80002570:	e44e                	sd	s3,8(sp)
    80002572:	1800                	addi	s0,sp,48
    80002574:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002576:	00010497          	auipc	s1,0x10
    8000257a:	15a48493          	addi	s1,s1,346 # 800126d0 <proc>
    8000257e:	00022997          	auipc	s3,0x22
    80002582:	55298993          	addi	s3,s3,1362 # 80024ad0 <tickslock>
  {
    acquire(&p->lock);
    80002586:	8526                	mv	a0,s1
    80002588:	ffffe097          	auipc	ra,0xffffe
    8000258c:	63a080e7          	jalr	1594(ra) # 80000bc2 <acquire>
    if (p->pid == pid)
    80002590:	589c                	lw	a5,48(s1)
    80002592:	01278d63          	beq	a5,s2,800025ac <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002596:	8526                	mv	a0,s1
    80002598:	ffffe097          	auipc	ra,0xffffe
    8000259c:	6de080e7          	jalr	1758(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800025a0:	49048493          	addi	s1,s1,1168
    800025a4:	ff3491e3          	bne	s1,s3,80002586 <kill+0x20>
  }
  return -1;
    800025a8:	557d                	li	a0,-1
    800025aa:	a829                	j	800025c4 <kill+0x5e>
      p->killed = 1;
    800025ac:	4785                	li	a5,1
    800025ae:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800025b0:	4c98                	lw	a4,24(s1)
    800025b2:	4789                	li	a5,2
    800025b4:	00f70f63          	beq	a4,a5,800025d2 <kill+0x6c>
      release(&p->lock);
    800025b8:	8526                	mv	a0,s1
    800025ba:	ffffe097          	auipc	ra,0xffffe
    800025be:	6bc080e7          	jalr	1724(ra) # 80000c76 <release>
      return 0;
    800025c2:	4501                	li	a0,0
}
    800025c4:	70a2                	ld	ra,40(sp)
    800025c6:	7402                	ld	s0,32(sp)
    800025c8:	64e2                	ld	s1,24(sp)
    800025ca:	6942                	ld	s2,16(sp)
    800025cc:	69a2                	ld	s3,8(sp)
    800025ce:	6145                	addi	sp,sp,48
    800025d0:	8082                	ret
        p->state = RUNNABLE;
    800025d2:	478d                	li	a5,3
    800025d4:	cc9c                	sw	a5,24(s1)
    800025d6:	b7cd                	j	800025b8 <kill+0x52>

00000000800025d8 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025d8:	7179                	addi	sp,sp,-48
    800025da:	f406                	sd	ra,40(sp)
    800025dc:	f022                	sd	s0,32(sp)
    800025de:	ec26                	sd	s1,24(sp)
    800025e0:	e84a                	sd	s2,16(sp)
    800025e2:	e44e                	sd	s3,8(sp)
    800025e4:	e052                	sd	s4,0(sp)
    800025e6:	1800                	addi	s0,sp,48
    800025e8:	84aa                	mv	s1,a0
    800025ea:	892e                	mv	s2,a1
    800025ec:	89b2                	mv	s3,a2
    800025ee:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025f0:	fffff097          	auipc	ra,0xfffff
    800025f4:	742080e7          	jalr	1858(ra) # 80001d32 <myproc>
  if (user_dst)
    800025f8:	c08d                	beqz	s1,8000261a <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800025fa:	86d2                	mv	a3,s4
    800025fc:	864e                	mv	a2,s3
    800025fe:	85ca                	mv	a1,s2
    80002600:	6928                	ld	a0,80(a0)
    80002602:	fffff097          	auipc	ra,0xfffff
    80002606:	da8080e7          	jalr	-600(ra) # 800013aa <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000260a:	70a2                	ld	ra,40(sp)
    8000260c:	7402                	ld	s0,32(sp)
    8000260e:	64e2                	ld	s1,24(sp)
    80002610:	6942                	ld	s2,16(sp)
    80002612:	69a2                	ld	s3,8(sp)
    80002614:	6a02                	ld	s4,0(sp)
    80002616:	6145                	addi	sp,sp,48
    80002618:	8082                	ret
    memmove((char *)dst, src, len);
    8000261a:	000a061b          	sext.w	a2,s4
    8000261e:	85ce                	mv	a1,s3
    80002620:	854a                	mv	a0,s2
    80002622:	ffffe097          	auipc	ra,0xffffe
    80002626:	6f8080e7          	jalr	1784(ra) # 80000d1a <memmove>
    return 0;
    8000262a:	8526                	mv	a0,s1
    8000262c:	bff9                	j	8000260a <either_copyout+0x32>

000000008000262e <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000262e:	7179                	addi	sp,sp,-48
    80002630:	f406                	sd	ra,40(sp)
    80002632:	f022                	sd	s0,32(sp)
    80002634:	ec26                	sd	s1,24(sp)
    80002636:	e84a                	sd	s2,16(sp)
    80002638:	e44e                	sd	s3,8(sp)
    8000263a:	e052                	sd	s4,0(sp)
    8000263c:	1800                	addi	s0,sp,48
    8000263e:	892a                	mv	s2,a0
    80002640:	84ae                	mv	s1,a1
    80002642:	89b2                	mv	s3,a2
    80002644:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002646:	fffff097          	auipc	ra,0xfffff
    8000264a:	6ec080e7          	jalr	1772(ra) # 80001d32 <myproc>
  if (user_src)
    8000264e:	c08d                	beqz	s1,80002670 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002650:	86d2                	mv	a3,s4
    80002652:	864e                	mv	a2,s3
    80002654:	85ca                	mv	a1,s2
    80002656:	6928                	ld	a0,80(a0)
    80002658:	fffff097          	auipc	ra,0xfffff
    8000265c:	de0080e7          	jalr	-544(ra) # 80001438 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002660:	70a2                	ld	ra,40(sp)
    80002662:	7402                	ld	s0,32(sp)
    80002664:	64e2                	ld	s1,24(sp)
    80002666:	6942                	ld	s2,16(sp)
    80002668:	69a2                	ld	s3,8(sp)
    8000266a:	6a02                	ld	s4,0(sp)
    8000266c:	6145                	addi	sp,sp,48
    8000266e:	8082                	ret
    memmove(dst, (char *)src, len);
    80002670:	000a061b          	sext.w	a2,s4
    80002674:	85ce                	mv	a1,s3
    80002676:	854a                	mv	a0,s2
    80002678:	ffffe097          	auipc	ra,0xffffe
    8000267c:	6a2080e7          	jalr	1698(ra) # 80000d1a <memmove>
    return 0;
    80002680:	8526                	mv	a0,s1
    80002682:	bff9                	j	80002660 <either_copyin+0x32>

0000000080002684 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002684:	715d                	addi	sp,sp,-80
    80002686:	e486                	sd	ra,72(sp)
    80002688:	e0a2                	sd	s0,64(sp)
    8000268a:	fc26                	sd	s1,56(sp)
    8000268c:	f84a                	sd	s2,48(sp)
    8000268e:	f44e                	sd	s3,40(sp)
    80002690:	f052                	sd	s4,32(sp)
    80002692:	ec56                	sd	s5,24(sp)
    80002694:	e85a                	sd	s6,16(sp)
    80002696:	e45e                	sd	s7,8(sp)
    80002698:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    8000269a:	00007517          	auipc	a0,0x7
    8000269e:	ffe50513          	addi	a0,a0,-2 # 80009698 <digits+0x658>
    800026a2:	ffffe097          	auipc	ra,0xffffe
    800026a6:	ed2080e7          	jalr	-302(ra) # 80000574 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800026aa:	00010497          	auipc	s1,0x10
    800026ae:	17e48493          	addi	s1,s1,382 # 80012828 <proc+0x158>
    800026b2:	00022917          	auipc	s2,0x22
    800026b6:	57690913          	addi	s2,s2,1398 # 80024c28 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026ba:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800026bc:	00007997          	auipc	s3,0x7
    800026c0:	db498993          	addi	s3,s3,-588 # 80009470 <digits+0x430>
    printf("%d %s %s", p->pid, state, p->name);
    800026c4:	00007a97          	auipc	s5,0x7
    800026c8:	db4a8a93          	addi	s5,s5,-588 # 80009478 <digits+0x438>
    printf("\n");
    800026cc:	00007a17          	auipc	s4,0x7
    800026d0:	fcca0a13          	addi	s4,s4,-52 # 80009698 <digits+0x658>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026d4:	00007b97          	auipc	s7,0x7
    800026d8:	ff4b8b93          	addi	s7,s7,-12 # 800096c8 <states.0>
    800026dc:	a00d                	j	800026fe <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026de:	ed86a583          	lw	a1,-296(a3)
    800026e2:	8556                	mv	a0,s5
    800026e4:	ffffe097          	auipc	ra,0xffffe
    800026e8:	e90080e7          	jalr	-368(ra) # 80000574 <printf>
    printf("\n");
    800026ec:	8552                	mv	a0,s4
    800026ee:	ffffe097          	auipc	ra,0xffffe
    800026f2:	e86080e7          	jalr	-378(ra) # 80000574 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800026f6:	49048493          	addi	s1,s1,1168
    800026fa:	03248263          	beq	s1,s2,8000271e <procdump+0x9a>
    if (p->state == UNUSED)
    800026fe:	86a6                	mv	a3,s1
    80002700:	ec04a783          	lw	a5,-320(s1)
    80002704:	dbed                	beqz	a5,800026f6 <procdump+0x72>
      state = "???";
    80002706:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002708:	fcfb6be3          	bltu	s6,a5,800026de <procdump+0x5a>
    8000270c:	02079713          	slli	a4,a5,0x20
    80002710:	01d75793          	srli	a5,a4,0x1d
    80002714:	97de                	add	a5,a5,s7
    80002716:	6390                	ld	a2,0(a5)
    80002718:	f279                	bnez	a2,800026de <procdump+0x5a>
      state = "???";
    8000271a:	864e                	mv	a2,s3
    8000271c:	b7c9                	j	800026de <procdump+0x5a>
  }
}
    8000271e:	60a6                	ld	ra,72(sp)
    80002720:	6406                	ld	s0,64(sp)
    80002722:	74e2                	ld	s1,56(sp)
    80002724:	7942                	ld	s2,48(sp)
    80002726:	79a2                	ld	s3,40(sp)
    80002728:	7a02                	ld	s4,32(sp)
    8000272a:	6ae2                	ld	s5,24(sp)
    8000272c:	6b42                	ld	s6,16(sp)
    8000272e:	6ba2                	ld	s7,8(sp)
    80002730:	6161                	addi	sp,sp,80
    80002732:	8082                	ret

0000000080002734 <get_next_free_space>:

// Next free space in swap file
int get_next_free_space(uint16 free_spaces)
{
    80002734:	1141                	addi	sp,sp,-16
    80002736:	e422                	sd	s0,8(sp)
    80002738:	0800                	addi	s0,sp,16
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
  {
    if (!(free_spaces & (1 << i)))
    8000273a:	0005071b          	sext.w	a4,a0
    8000273e:	8905                	andi	a0,a0,1
    80002740:	cd11                	beqz	a0,8000275c <get_next_free_space+0x28>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002742:	4505                	li	a0,1
    80002744:	46c1                	li	a3,16
    if (!(free_spaces & (1 << i)))
    80002746:	40a757bb          	sraw	a5,a4,a0
    8000274a:	8b85                	andi	a5,a5,1
    8000274c:	c789                	beqz	a5,80002756 <get_next_free_space+0x22>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000274e:	2505                	addiw	a0,a0,1
    80002750:	fed51be3          	bne	a0,a3,80002746 <get_next_free_space+0x12>
      return i;
  }
  return -1;
    80002754:	557d                	li	a0,-1
}
    80002756:	6422                	ld	s0,8(sp)
    80002758:	0141                	addi	sp,sp,16
    8000275a:	8082                	ret
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000275c:	4501                	li	a0,0
    8000275e:	bfe5                	j	80002756 <get_next_free_space+0x22>

0000000080002760 <get_index_in_page_info_array>:

// Get file vm and return file entery inside swap file if exist
int get_index_in_page_info_array(uint64 va, struct page_info *arr)
{
    80002760:	1141                	addi	sp,sp,-16
    80002762:	e422                	sd	s0,8(sp)
    80002764:	0800                	addi	s0,sp,16
  uint64 rva = PGROUNDDOWN(va);
    80002766:	777d                	lui	a4,0xfffff
    80002768:	8f69                	and	a4,a4,a0
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000276a:	4501                	li	a0,0
    8000276c:	46c1                	li	a3,16
  {
    struct page_info *po = &arr[i];
    if (po->va == rva)
    8000276e:	619c                	ld	a5,0(a1)
    80002770:	00e78763          	beq	a5,a4,8000277e <get_index_in_page_info_array+0x1e>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002774:	2505                	addiw	a0,a0,1
    80002776:	05e1                	addi	a1,a1,24
    80002778:	fed51be3          	bne	a0,a3,8000276e <get_index_in_page_info_array+0xe>
    {
      return i;
    }
  }
  return -1; // if not found return null
    8000277c:	557d                	li	a0,-1
}
    8000277e:	6422                	ld	s0,8(sp)
    80002780:	0141                	addi	sp,sp,16
    80002782:	8082                	ret

0000000080002784 <page_out>:
//  free physical memory of page which virtual address va
//  write this page to procs swap file
//  return the new free physical address
uint64
page_out(uint64 va)
{
    80002784:	7179                	addi	sp,sp,-48
    80002786:	f406                	sd	ra,40(sp)
    80002788:	f022                	sd	s0,32(sp)
    8000278a:	ec26                	sd	s1,24(sp)
    8000278c:	e84a                	sd	s2,16(sp)
    8000278e:	e44e                	sd	s3,8(sp)
    80002790:	e052                	sd	s4,0(sp)
    80002792:	1800                	addi	s0,sp,48
    80002794:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002796:	fffff097          	auipc	ra,0xfffff
    8000279a:	59c080e7          	jalr	1436(ra) # 80001d32 <myproc>
    8000279e:	8a2a                	mv	s4,a0

  uint64 rva = PGROUNDDOWN(va);
    800027a0:	797d                	lui	s2,0xfffff
    800027a2:	0124f933          	and	s2,s1,s2

  // find the addrres of the page which sent out
  pte_t *pte = walk(p->pagetable, va, 0);
    800027a6:	4601                	li	a2,0
    800027a8:	85a6                	mv	a1,s1
    800027aa:	6928                	ld	a0,80(a0)
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	7fa080e7          	jalr	2042(ra) # 80000fa6 <walk>
    800027b4:	89aa                	mv	s3,a0
  uint64 pa = PTE2PA(*pte);
    800027b6:	6104                	ld	s1,0(a0)

  // insert the page to the swap file

  int page_index = insert_page_to_swap_file(rva);
    800027b8:	854a                	mv	a0,s2
    800027ba:	fffff097          	auipc	ra,0xfffff
    800027be:	dc4080e7          	jalr	-572(ra) # 8000157e <insert_page_to_swap_file>

  int start_offset = page_index * PGSIZE;
  if (page_index < 0 || page_index >= MAX_PSYC_PAGES)
    800027c2:	0005079b          	sext.w	a5,a0
    800027c6:	473d                	li	a4,15
    800027c8:	04f76d63          	bltu	a4,a5,80002822 <page_out+0x9e>
    800027cc:	80a9                	srli	s1,s1,0xa
    800027ce:	04b2                	slli	s1,s1,0xc
    800027d0:	00c5161b          	slliw	a2,a0,0xc
    panic("fadge no free index in page_out");

  writeToSwapFile(p, (char *)pa, start_offset, PGSIZE); // Write page to swap file
    800027d4:	6685                	lui	a3,0x1
    800027d6:	2601                	sext.w	a2,a2
    800027d8:	85a6                	mv	a1,s1
    800027da:	8552                	mv	a0,s4
    800027dc:	00002097          	auipc	ra,0x2
    800027e0:	3d4080e7          	jalr	980(ra) # 80004bb0 <writeToSwapFile>

  // Update the ram info struct
  remove_page_from_physical_memory(rva);
    800027e4:	854a                	mv	a0,s2
    800027e6:	fffff097          	auipc	ra,0xfffff
    800027ea:	ec2080e7          	jalr	-318(ra) # 800016a8 <remove_page_from_physical_memory>
  p->physical_pages_num--;
    800027ee:	170a2783          	lw	a5,368(s4)
    800027f2:	37fd                	addiw	a5,a5,-1
    800027f4:	16fa2823          	sw	a5,368(s4)

  // free space in physical memory
  kfree((void *)pa);
    800027f8:	8526                	mv	a0,s1
    800027fa:	ffffe097          	auipc	ra,0xffffe
    800027fe:	1dc080e7          	jalr	476(ra) # 800009d6 <kfree>

  *pte &= ~PTE_V; // page table entry now invalid
    80002802:	0009b783          	ld	a5,0(s3)
    80002806:	9bf9                	andi	a5,a5,-2
  *pte |= PTE_PG; // paged out to secondary storage
    80002808:	2007e793          	ori	a5,a5,512
    8000280c:	00f9b023          	sd	a5,0(s3)

  return pa;
}
    80002810:	8526                	mv	a0,s1
    80002812:	70a2                	ld	ra,40(sp)
    80002814:	7402                	ld	s0,32(sp)
    80002816:	64e2                	ld	s1,24(sp)
    80002818:	6942                	ld	s2,16(sp)
    8000281a:	69a2                	ld	s3,8(sp)
    8000281c:	6a02                	ld	s4,0(sp)
    8000281e:	6145                	addi	sp,sp,48
    80002820:	8082                	ret
    panic("fadge no free index in page_out");
    80002822:	00007517          	auipc	a0,0x7
    80002826:	c6650513          	addi	a0,a0,-922 # 80009488 <digits+0x448>
    8000282a:	ffffe097          	auipc	ra,0xffffe
    8000282e:	d00080e7          	jalr	-768(ra) # 8000052a <panic>

0000000080002832 <page_in>:

// move page from swap file to physical memory
pte_t *
page_in(uint64 va, pte_t *pte)
{
    80002832:	7139                	addi	sp,sp,-64
    80002834:	fc06                	sd	ra,56(sp)
    80002836:	f822                	sd	s0,48(sp)
    80002838:	f426                	sd	s1,40(sp)
    8000283a:	f04a                	sd	s2,32(sp)
    8000283c:	ec4e                	sd	s3,24(sp)
    8000283e:	e852                	sd	s4,16(sp)
    80002840:	e456                	sd	s5,8(sp)
    80002842:	e05a                	sd	s6,0(sp)
    80002844:	0080                	addi	s0,sp,64
    80002846:	8b2a                	mv	s6,a0
    80002848:	892e                	mv	s2,a1
  uint64 pa;
  struct proc *p = myproc();
    8000284a:	fffff097          	auipc	ra,0xfffff
    8000284e:	4e8080e7          	jalr	1256(ra) # 80001d32 <myproc>
    80002852:	89aa                	mv	s3,a0
  uint64 rva = PGROUNDDOWN(va);
    80002854:	7afd                	lui	s5,0xfffff
    80002856:	015b7ab3          	and	s5,s6,s5
  // update swap info
  int swap_old_index = remove_page_from_swap_file(rva);
    8000285a:	8556                	mv	a0,s5
    8000285c:	fffff097          	auipc	ra,0xfffff
    80002860:	eb4080e7          	jalr	-332(ra) # 80001710 <remove_page_from_swap_file>

  if (swap_old_index < 0)
    80002864:	08054063          	bltz	a0,800028e4 <page_in+0xb2>
    80002868:	8a2a                	mv	s4,a0
    panic("page_in: index in swap file not found");

  // alloc page in physical memory
  if ((pa = (uint64)kalloc()) == 0)
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	268080e7          	jalr	616(ra) # 80000ad2 <kalloc>
    80002872:	84aa                	mv	s1,a0
    80002874:	c141                	beqz	a0,800028f4 <page_in+0xc2>
  {
    printf("retrievingpage: kalloc failed\n");
    return 0;
  }

  mappages(p->pagetable, va, PGSIZE, (uint64)pa, PTE_FLAGS(*pte));
    80002876:	00093703          	ld	a4,0(s2) # fffffffffffff000 <end+0xffffffff7ffcc000>
    8000287a:	3ff77713          	andi	a4,a4,1023
    8000287e:	86aa                	mv	a3,a0
    80002880:	6605                	lui	a2,0x1
    80002882:	85da                	mv	a1,s6
    80002884:	0509b503          	ld	a0,80(s3)
    80002888:	fffff097          	auipc	ra,0xfffff
    8000288c:	832080e7          	jalr	-1998(ra) # 800010ba <mappages>

  // update physc info
  insert_page_to_physical_memory(rva);
    80002890:	8556                	mv	a0,s5
    80002892:	fffff097          	auipc	ra,0xfffff
    80002896:	d6c080e7          	jalr	-660(ra) # 800015fe <insert_page_to_physical_memory>
  p->physical_pages_num++;
    8000289a:	1709a783          	lw	a5,368(s3)
    8000289e:	2785                	addiw	a5,a5,1
    800028a0:	16f9a823          	sw	a5,368(s3)

  // Write to swap file
  int start_offset = swap_old_index * PGSIZE;
  readFromSwapFile(p, (char *)pa, start_offset, PGSIZE);
    800028a4:	6685                	lui	a3,0x1
    800028a6:	00ca161b          	slliw	a2,s4,0xc
    800028aa:	85a6                	mv	a1,s1
    800028ac:	854e                	mv	a0,s3
    800028ae:	00002097          	auipc	ra,0x2
    800028b2:	326080e7          	jalr	806(ra) # 80004bd4 <readFromSwapFile>

  // update pte
  if (!(*pte & PTE_PG))
    800028b6:	00093783          	ld	a5,0(s2)
    800028ba:	2007f713          	andi	a4,a5,512
    800028be:	c721                	beqz	a4,80002906 <page_in+0xd4>
    panic("page in: page out flag was off");
  *pte = (*pte | PTE_V) & (~PTE_PG);
    800028c0:	dfe7f793          	andi	a5,a5,-514
    800028c4:	0017e793          	ori	a5,a5,1
    800028c8:	00f93023          	sd	a5,0(s2)

  return pte;
    800028cc:	84ca                	mv	s1,s2
}
    800028ce:	8526                	mv	a0,s1
    800028d0:	70e2                	ld	ra,56(sp)
    800028d2:	7442                	ld	s0,48(sp)
    800028d4:	74a2                	ld	s1,40(sp)
    800028d6:	7902                	ld	s2,32(sp)
    800028d8:	69e2                	ld	s3,24(sp)
    800028da:	6a42                	ld	s4,16(sp)
    800028dc:	6aa2                	ld	s5,8(sp)
    800028de:	6b02                	ld	s6,0(sp)
    800028e0:	6121                	addi	sp,sp,64
    800028e2:	8082                	ret
    panic("page_in: index in swap file not found");
    800028e4:	00007517          	auipc	a0,0x7
    800028e8:	bc450513          	addi	a0,a0,-1084 # 800094a8 <digits+0x468>
    800028ec:	ffffe097          	auipc	ra,0xffffe
    800028f0:	c3e080e7          	jalr	-962(ra) # 8000052a <panic>
    printf("retrievingpage: kalloc failed\n");
    800028f4:	00007517          	auipc	a0,0x7
    800028f8:	bdc50513          	addi	a0,a0,-1060 # 800094d0 <digits+0x490>
    800028fc:	ffffe097          	auipc	ra,0xffffe
    80002900:	c78080e7          	jalr	-904(ra) # 80000574 <printf>
    return 0;
    80002904:	b7e9                	j	800028ce <page_in+0x9c>
    panic("page in: page out flag was off");
    80002906:	00007517          	auipc	a0,0x7
    8000290a:	bea50513          	addi	a0,a0,-1046 # 800094f0 <digits+0x4b0>
    8000290e:	ffffe097          	auipc	ra,0xffffe
    80002912:	c1c080e7          	jalr	-996(ra) # 8000052a <panic>

0000000080002916 <copyFilesInfo>:

void copyFilesInfo(struct proc *p, struct proc *np)
{
    80002916:	7139                	addi	sp,sp,-64
    80002918:	fc06                	sd	ra,56(sp)
    8000291a:	f822                	sd	s0,48(sp)
    8000291c:	f426                	sd	s1,40(sp)
    8000291e:	f04a                	sd	s2,32(sp)
    80002920:	ec4e                	sd	s3,24(sp)
    80002922:	e852                	sd	s4,16(sp)
    80002924:	e456                	sd	s5,8(sp)
    80002926:	e05a                	sd	s6,0(sp)
    80002928:	0080                	addi	s0,sp,64
    8000292a:	89aa                	mv	s3,a0
    8000292c:	84ae                	mv	s1,a1
  // Copy swapfile
  void *temp_page;

  if (!(temp_page = kalloc()))
    8000292e:	ffffe097          	auipc	ra,0xffffe
    80002932:	1a4080e7          	jalr	420(ra) # 80000ad2 <kalloc>
    80002936:	8b2a                	mv	s6,a0
    panic("copyFilesInfo: kalloc failed");

  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002938:	4901                	li	s2,0
    8000293a:	4a41                	li	s4,16
  if (!(temp_page = kalloc()))
    8000293c:	e505                	bnez	a0,80002964 <copyFilesInfo+0x4e>
    panic("copyFilesInfo: kalloc failed");
    8000293e:	00007517          	auipc	a0,0x7
    80002942:	bd250513          	addi	a0,a0,-1070 # 80009510 <digits+0x4d0>
    80002946:	ffffe097          	auipc	ra,0xffffe
    8000294a:	be4080e7          	jalr	-1052(ra) # 8000052a <panic>
    if (p->pages_swap_info.free_spaces & (1 << i))
    {
      int res = readFromSwapFile(p, (char *)temp_page, i * PGSIZE, PGSIZE);

      if (res < 0)
        panic("copyFilesInfo: failed read");
    8000294e:	00007517          	auipc	a0,0x7
    80002952:	be250513          	addi	a0,a0,-1054 # 80009530 <digits+0x4f0>
    80002956:	ffffe097          	auipc	ra,0xffffe
    8000295a:	bd4080e7          	jalr	-1068(ra) # 8000052a <panic>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000295e:	2905                	addiw	s2,s2,1
    80002960:	05490663          	beq	s2,s4,800029ac <copyFilesInfo+0x96>
    if (p->pages_swap_info.free_spaces & (1 << i))
    80002964:	1789d783          	lhu	a5,376(s3)
    80002968:	4127d7bb          	sraw	a5,a5,s2
    8000296c:	8b85                	andi	a5,a5,1
    8000296e:	dbe5                	beqz	a5,8000295e <copyFilesInfo+0x48>
      int res = readFromSwapFile(p, (char *)temp_page, i * PGSIZE, PGSIZE);
    80002970:	00c91a9b          	slliw	s5,s2,0xc
    80002974:	6685                	lui	a3,0x1
    80002976:	8656                	mv	a2,s5
    80002978:	85da                	mv	a1,s6
    8000297a:	854e                	mv	a0,s3
    8000297c:	00002097          	auipc	ra,0x2
    80002980:	258080e7          	jalr	600(ra) # 80004bd4 <readFromSwapFile>
      if (res < 0)
    80002984:	fc0545e3          	bltz	a0,8000294e <copyFilesInfo+0x38>

      res = writeToSwapFile(np, temp_page, i * PGSIZE, PGSIZE);
    80002988:	6685                	lui	a3,0x1
    8000298a:	8656                	mv	a2,s5
    8000298c:	85da                	mv	a1,s6
    8000298e:	8526                	mv	a0,s1
    80002990:	00002097          	auipc	ra,0x2
    80002994:	220080e7          	jalr	544(ra) # 80004bb0 <writeToSwapFile>

      if (res < 0)
    80002998:	fc0553e3          	bgez	a0,8000295e <copyFilesInfo+0x48>
        panic("copyFilesInfo: faild write ");
    8000299c:	00007517          	auipc	a0,0x7
    800029a0:	bb450513          	addi	a0,a0,-1100 # 80009550 <digits+0x510>
    800029a4:	ffffe097          	auipc	ra,0xffffe
    800029a8:	b86080e7          	jalr	-1146(ra) # 8000052a <panic>
    }
  }

  kfree(temp_page);
    800029ac:	855a                	mv	a0,s6
    800029ae:	ffffe097          	auipc	ra,0xffffe
    800029b2:	028080e7          	jalr	40(ra) # 800009d6 <kfree>

  // Copy swap and ram structs
  np->pages_swap_info.free_spaces = p->pages_swap_info.free_spaces;
    800029b6:	1789d783          	lhu	a5,376(s3)
    800029ba:	16f49c23          	sh	a5,376(s1)
  np->pages_physc_info.free_spaces = p->pages_physc_info.free_spaces;
    800029be:	3009d783          	lhu	a5,768(s3)
    800029c2:	30f49023          	sh	a5,768(s1)

  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    800029c6:	18098793          	addi	a5,s3,384
    800029ca:	18048593          	addi	a1,s1,384
    800029ce:	30098993          	addi	s3,s3,768
  {
    np->pages_swap_info.pages[i] = p->pages_swap_info.pages[i];
    800029d2:	6398                	ld	a4,0(a5)
    800029d4:	e198                	sd	a4,0(a1)
    800029d6:	6798                	ld	a4,8(a5)
    800029d8:	e598                	sd	a4,8(a1)
    800029da:	6b98                	ld	a4,16(a5)
    800029dc:	e998                	sd	a4,16(a1)
    np->pages_physc_info.pages[i] = p->pages_physc_info.pages[i];
    800029de:	1887b703          	ld	a4,392(a5)
    800029e2:	18e5b423          	sd	a4,392(a1)
    800029e6:	1907b703          	ld	a4,400(a5)
    800029ea:	18e5b823          	sd	a4,400(a1)
    800029ee:	1987b703          	ld	a4,408(a5)
    800029f2:	18e5bc23          	sd	a4,408(a1)
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    800029f6:	07e1                	addi	a5,a5,24
    800029f8:	05e1                	addi	a1,a1,24
    800029fa:	fd379ce3          	bne	a5,s3,800029d2 <copyFilesInfo+0xbc>
  }
}
    800029fe:	70e2                	ld	ra,56(sp)
    80002a00:	7442                	ld	s0,48(sp)
    80002a02:	74a2                	ld	s1,40(sp)
    80002a04:	7902                	ld	s2,32(sp)
    80002a06:	69e2                	ld	s3,24(sp)
    80002a08:	6a42                	ld	s4,16(sp)
    80002a0a:	6aa2                	ld	s5,8(sp)
    80002a0c:	6b02                	ld	s6,0(sp)
    80002a0e:	6121                	addi	sp,sp,64
    80002a10:	8082                	ret

0000000080002a12 <fork>:
{
    80002a12:	7139                	addi	sp,sp,-64
    80002a14:	fc06                	sd	ra,56(sp)
    80002a16:	f822                	sd	s0,48(sp)
    80002a18:	f426                	sd	s1,40(sp)
    80002a1a:	f04a                	sd	s2,32(sp)
    80002a1c:	ec4e                	sd	s3,24(sp)
    80002a1e:	e852                	sd	s4,16(sp)
    80002a20:	e456                	sd	s5,8(sp)
    80002a22:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002a24:	fffff097          	auipc	ra,0xfffff
    80002a28:	30e080e7          	jalr	782(ra) # 80001d32 <myproc>
    80002a2c:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80002a2e:	fffff097          	auipc	ra,0xfffff
    80002a32:	512080e7          	jalr	1298(ra) # 80001f40 <allocproc>
    80002a36:	12050f63          	beqz	a0,80002b74 <fork+0x162>
    80002a3a:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002a3c:	048ab603          	ld	a2,72(s5) # fffffffffffff048 <end+0xffffffff7ffcc048>
    80002a40:	692c                	ld	a1,80(a0)
    80002a42:	050ab503          	ld	a0,80(s5)
    80002a46:	fffff097          	auipc	ra,0xfffff
    80002a4a:	082080e7          	jalr	130(ra) # 80001ac8 <uvmcopy>
    80002a4e:	04054863          	bltz	a0,80002a9e <fork+0x8c>
  np->sz = p->sz;
    80002a52:	048ab783          	ld	a5,72(s5)
    80002a56:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80002a5a:	058ab683          	ld	a3,88(s5)
    80002a5e:	87b6                	mv	a5,a3
    80002a60:	0589b703          	ld	a4,88(s3)
    80002a64:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    80002a68:	0007b803          	ld	a6,0(a5)
    80002a6c:	6788                	ld	a0,8(a5)
    80002a6e:	6b8c                	ld	a1,16(a5)
    80002a70:	6f90                	ld	a2,24(a5)
    80002a72:	01073023          	sd	a6,0(a4) # fffffffffffff000 <end+0xffffffff7ffcc000>
    80002a76:	e708                	sd	a0,8(a4)
    80002a78:	eb0c                	sd	a1,16(a4)
    80002a7a:	ef10                	sd	a2,24(a4)
    80002a7c:	02078793          	addi	a5,a5,32
    80002a80:	02070713          	addi	a4,a4,32
    80002a84:	fed792e3          	bne	a5,a3,80002a68 <fork+0x56>
  np->trapframe->a0 = 0;
    80002a88:	0589b783          	ld	a5,88(s3)
    80002a8c:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80002a90:	0d0a8493          	addi	s1,s5,208
    80002a94:	0d098913          	addi	s2,s3,208
    80002a98:	150a8a13          	addi	s4,s5,336
    80002a9c:	a00d                	j	80002abe <fork+0xac>
    freeproc(np);
    80002a9e:	854e                	mv	a0,s3
    80002aa0:	fffff097          	auipc	ra,0xfffff
    80002aa4:	444080e7          	jalr	1092(ra) # 80001ee4 <freeproc>
    release(&np->lock);
    80002aa8:	854e                	mv	a0,s3
    80002aaa:	ffffe097          	auipc	ra,0xffffe
    80002aae:	1cc080e7          	jalr	460(ra) # 80000c76 <release>
    return -1;
    80002ab2:	597d                	li	s2,-1
    80002ab4:	a075                	j	80002b60 <fork+0x14e>
  for (i = 0; i < NOFILE; i++)
    80002ab6:	04a1                	addi	s1,s1,8
    80002ab8:	0921                	addi	s2,s2,8
    80002aba:	01448b63          	beq	s1,s4,80002ad0 <fork+0xbe>
    if (p->ofile[i])
    80002abe:	6088                	ld	a0,0(s1)
    80002ac0:	d97d                	beqz	a0,80002ab6 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80002ac2:	00002097          	auipc	ra,0x2
    80002ac6:	796080e7          	jalr	1942(ra) # 80005258 <filedup>
    80002aca:	00a93023          	sd	a0,0(s2)
    80002ace:	b7e5                	j	80002ab6 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80002ad0:	150ab503          	ld	a0,336(s5)
    80002ad4:	00001097          	auipc	ra,0x1
    80002ad8:	5e4080e7          	jalr	1508(ra) # 800040b8 <idup>
    80002adc:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002ae0:	4641                	li	a2,16
    80002ae2:	158a8593          	addi	a1,s5,344
    80002ae6:	15898513          	addi	a0,s3,344
    80002aea:	ffffe097          	auipc	ra,0xffffe
    80002aee:	326080e7          	jalr	806(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80002af2:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002af6:	854e                	mv	a0,s3
    80002af8:	ffffe097          	auipc	ra,0xffffe
    80002afc:	17e080e7          	jalr	382(ra) # 80000c76 <release>
  createSwapFile(np);
    80002b00:	854e                	mv	a0,s3
    80002b02:	00002097          	auipc	ra,0x2
    80002b06:	ffe080e7          	jalr	-2(ra) # 80004b00 <createSwapFile>
  copyFilesInfo(p, np); // TODO: check we need to this for father 1,2
    80002b0a:	85ce                	mv	a1,s3
    80002b0c:	8556                	mv	a0,s5
    80002b0e:	00000097          	auipc	ra,0x0
    80002b12:	e08080e7          	jalr	-504(ra) # 80002916 <copyFilesInfo>
  np->physical_pages_num = p->physical_pages_num;
    80002b16:	170aa783          	lw	a5,368(s5)
    80002b1a:	16f9a823          	sw	a5,368(s3)
  np->total_pages_num = p->total_pages_num;
    80002b1e:	174aa783          	lw	a5,372(s5)
    80002b22:	16f9aa23          	sw	a5,372(s3)
  acquire(&wait_lock);
    80002b26:	0000f497          	auipc	s1,0xf
    80002b2a:	79248493          	addi	s1,s1,1938 # 800122b8 <wait_lock>
    80002b2e:	8526                	mv	a0,s1
    80002b30:	ffffe097          	auipc	ra,0xffffe
    80002b34:	092080e7          	jalr	146(ra) # 80000bc2 <acquire>
  np->parent = p;
    80002b38:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002b3c:	8526                	mv	a0,s1
    80002b3e:	ffffe097          	auipc	ra,0xffffe
    80002b42:	138080e7          	jalr	312(ra) # 80000c76 <release>
  acquire(&np->lock);
    80002b46:	854e                	mv	a0,s3
    80002b48:	ffffe097          	auipc	ra,0xffffe
    80002b4c:	07a080e7          	jalr	122(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80002b50:	478d                	li	a5,3
    80002b52:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002b56:	854e                	mv	a0,s3
    80002b58:	ffffe097          	auipc	ra,0xffffe
    80002b5c:	11e080e7          	jalr	286(ra) # 80000c76 <release>
}
    80002b60:	854a                	mv	a0,s2
    80002b62:	70e2                	ld	ra,56(sp)
    80002b64:	7442                	ld	s0,48(sp)
    80002b66:	74a2                	ld	s1,40(sp)
    80002b68:	7902                	ld	s2,32(sp)
    80002b6a:	69e2                	ld	s3,24(sp)
    80002b6c:	6a42                	ld	s4,16(sp)
    80002b6e:	6aa2                	ld	s5,8(sp)
    80002b70:	6121                	addi	sp,sp,64
    80002b72:	8082                	ret
    return -1;
    80002b74:	597d                	li	s2,-1
    80002b76:	b7ed                	j	80002b60 <fork+0x14e>

0000000080002b78 <NFUA_compare>:
  return selected_pg_index;
}

long NFUA_compare(struct page_info *pg1, struct page_info *pg2)
{
  if (!pg1 || !pg2)
    80002b78:	c511                	beqz	a0,80002b84 <NFUA_compare+0xc>
    80002b7a:	c589                	beqz	a1,80002b84 <NFUA_compare+0xc>
    panic("NFUA_compare : null input");
  return pg1->aging_counter - pg2->aging_counter;
    80002b7c:	6508                	ld	a0,8(a0)
    80002b7e:	659c                	ld	a5,8(a1)
}
    80002b80:	8d1d                	sub	a0,a0,a5
    80002b82:	8082                	ret
{
    80002b84:	1141                	addi	sp,sp,-16
    80002b86:	e406                	sd	ra,8(sp)
    80002b88:	e022                	sd	s0,0(sp)
    80002b8a:	0800                	addi	s0,sp,16
    panic("NFUA_compare : null input");
    80002b8c:	00007517          	auipc	a0,0x7
    80002b90:	9e450513          	addi	a0,a0,-1564 # 80009570 <digits+0x530>
    80002b94:	ffffe097          	auipc	ra,0xffffe
    80002b98:	996080e7          	jalr	-1642(ra) # 8000052a <panic>

0000000080002b9c <SCFIFO_compare>:
  return res;
}

int SCFIFO_compare(struct page_info *pg1, struct page_info *pg2)
{
  if (!pg1 || !pg2)
    80002b9c:	c511                	beqz	a0,80002ba8 <SCFIFO_compare+0xc>
    80002b9e:	c589                	beqz	a1,80002ba8 <SCFIFO_compare+0xc>
    panic("SCFIFO_compare : null input");

  return pg1->time_inserted - pg2->time_inserted;
    80002ba0:	4908                	lw	a0,16(a0)
    80002ba2:	499c                	lw	a5,16(a1)
}
    80002ba4:	9d1d                	subw	a0,a0,a5
    80002ba6:	8082                	ret
{
    80002ba8:	1141                	addi	sp,sp,-16
    80002baa:	e406                	sd	ra,8(sp)
    80002bac:	e022                	sd	s0,0(sp)
    80002bae:	0800                	addi	s0,sp,16
    panic("SCFIFO_compare : null input");
    80002bb0:	00007517          	auipc	a0,0x7
    80002bb4:	9e050513          	addi	a0,a0,-1568 # 80009590 <digits+0x550>
    80002bb8:	ffffe097          	auipc	ra,0xffffe
    80002bbc:	972080e7          	jalr	-1678(ra) # 8000052a <panic>

0000000080002bc0 <countOnes>:

long countOnes(long n)
{
    80002bc0:	1141                	addi	sp,sp,-16
    80002bc2:	e422                	sd	s0,8(sp)
    80002bc4:	0800                	addi	s0,sp,16
  int count = 0;
  while (n)
    80002bc6:	c919                	beqz	a0,80002bdc <countOnes+0x1c>
    80002bc8:	87aa                	mv	a5,a0
  int count = 0;
    80002bca:	4501                	li	a0,0
  {
    count += n & 1;
    80002bcc:	0017f713          	andi	a4,a5,1
    80002bd0:	9d39                	addw	a0,a0,a4
    n >>= 1;
    80002bd2:	8785                	srai	a5,a5,0x1
  while (n)
    80002bd4:	ffe5                	bnez	a5,80002bcc <countOnes+0xc>
  }
  return count;
}
    80002bd6:	6422                	ld	s0,8(sp)
    80002bd8:	0141                	addi	sp,sp,16
    80002bda:	8082                	ret
  int count = 0;
    80002bdc:	4501                	li	a0,0
    80002bde:	bfe5                	j	80002bd6 <countOnes+0x16>

0000000080002be0 <LAPA_compare>:
{
    80002be0:	7179                	addi	sp,sp,-48
    80002be2:	f406                	sd	ra,40(sp)
    80002be4:	f022                	sd	s0,32(sp)
    80002be6:	ec26                	sd	s1,24(sp)
    80002be8:	e84a                	sd	s2,16(sp)
    80002bea:	e44e                	sd	s3,8(sp)
    80002bec:	1800                	addi	s0,sp,48
  if (!pg1 || !pg2)
    80002bee:	cd0d                	beqz	a0,80002c28 <LAPA_compare+0x48>
    80002bf0:	892e                	mv	s2,a1
    80002bf2:	c99d                	beqz	a1,80002c28 <LAPA_compare+0x48>
  int res = countOnes(pg1->aging_counter) - countOnes(pg2->aging_counter);
    80002bf4:	00853983          	ld	s3,8(a0)
    80002bf8:	854e                	mv	a0,s3
    80002bfa:	00000097          	auipc	ra,0x0
    80002bfe:	fc6080e7          	jalr	-58(ra) # 80002bc0 <countOnes>
    80002c02:	84aa                	mv	s1,a0
    80002c04:	00893903          	ld	s2,8(s2)
    80002c08:	854a                	mv	a0,s2
    80002c0a:	00000097          	auipc	ra,0x0
    80002c0e:	fb6080e7          	jalr	-74(ra) # 80002bc0 <countOnes>
    80002c12:	40a487bb          	subw	a5,s1,a0
  return res;
    80002c16:	853e                	mv	a0,a5
  if (res == 0)
    80002c18:	c385                	beqz	a5,80002c38 <LAPA_compare+0x58>
}
    80002c1a:	70a2                	ld	ra,40(sp)
    80002c1c:	7402                	ld	s0,32(sp)
    80002c1e:	64e2                	ld	s1,24(sp)
    80002c20:	6942                	ld	s2,16(sp)
    80002c22:	69a2                	ld	s3,8(sp)
    80002c24:	6145                	addi	sp,sp,48
    80002c26:	8082                	ret
    panic("LAPA_compare : null input");
    80002c28:	00007517          	auipc	a0,0x7
    80002c2c:	98850513          	addi	a0,a0,-1656 # 800095b0 <digits+0x570>
    80002c30:	ffffe097          	auipc	ra,0xffffe
    80002c34:	8fa080e7          	jalr	-1798(ra) # 8000052a <panic>
    return pg1->aging_counter - pg2->aging_counter;
    80002c38:	41298533          	sub	a0,s3,s2
    80002c3c:	bff9                	j	80002c1a <LAPA_compare+0x3a>

0000000080002c3e <compare_all_pages>:

// Return the index of the page to swap out acording to paging policy
int compare_all_pages(long (*compare)(struct page_info *pg1, struct page_info *pg2))
{
    80002c3e:	715d                	addi	sp,sp,-80
    80002c40:	e486                	sd	ra,72(sp)
    80002c42:	e0a2                	sd	s0,64(sp)
    80002c44:	fc26                	sd	s1,56(sp)
    80002c46:	f84a                	sd	s2,48(sp)
    80002c48:	f44e                	sd	s3,40(sp)
    80002c4a:	f052                	sd	s4,32(sp)
    80002c4c:	ec56                	sd	s5,24(sp)
    80002c4e:	e85a                	sd	s6,16(sp)
    80002c50:	e45e                	sd	s7,8(sp)
    80002c52:	e062                	sd	s8,0(sp)
    80002c54:	0880                	addi	s0,sp,80
    80002c56:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002c58:	fffff097          	auipc	ra,0xfffff
    80002c5c:	0da080e7          	jalr	218(ra) # 80001d32 <myproc>
    80002c60:	89aa                	mv	s3,a0

  struct page_info *pg_to_swap = 0;
  int min_index = -1;

  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002c62:	30850913          	addi	s2,a0,776
    80002c66:	4481                	li	s1,0
  int min_index = -1;
    80002c68:	5bfd                	li	s7,-1
  struct page_info *pg_to_swap = 0;
    80002c6a:	4a01                	li	s4,0
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002c6c:	4ac1                	li	s5,16
    80002c6e:	a039                	j	80002c7c <compare_all_pages+0x3e>
    80002c70:	8ba6                	mv	s7,s1
    //     pg->aging_counter |= 0x80000000;
    // #endif
    if ((p->pages_physc_info.free_spaces & (1 << i)) && (!pg_to_swap || compare(pg, pg_to_swap) < 0))
    {
      // in case pg_to_swap have not yet been initialize or the current pg is less needable acording to policy
      pg_to_swap = pg;
    80002c72:	8a4a                	mv	s4,s2
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002c74:	2485                	addiw	s1,s1,1
    80002c76:	0961                	addi	s2,s2,24
    80002c78:	03548263          	beq	s1,s5,80002c9c <compare_all_pages+0x5e>
    if ((p->pages_physc_info.free_spaces & (1 << i)) && (!pg_to_swap || compare(pg, pg_to_swap) < 0))
    80002c7c:	3009d783          	lhu	a5,768(s3)
    80002c80:	4097d7bb          	sraw	a5,a5,s1
    80002c84:	8b85                	andi	a5,a5,1
    80002c86:	d7fd                	beqz	a5,80002c74 <compare_all_pages+0x36>
    80002c88:	fe0a04e3          	beqz	s4,80002c70 <compare_all_pages+0x32>
    80002c8c:	85d2                	mv	a1,s4
    80002c8e:	854a                	mv	a0,s2
    80002c90:	9b02                	jalr	s6
    80002c92:	fe0551e3          	bgez	a0,80002c74 <compare_all_pages+0x36>
    80002c96:	8ba6                	mv	s7,s1
      pg_to_swap = pg;
    80002c98:	8a4a                	mv	s4,s2
    80002c9a:	bfe9                	j	80002c74 <compare_all_pages+0x36>
      min_index = i;
    }
  }
  return min_index;
}
    80002c9c:	855e                	mv	a0,s7
    80002c9e:	60a6                	ld	ra,72(sp)
    80002ca0:	6406                	ld	s0,64(sp)
    80002ca2:	74e2                	ld	s1,56(sp)
    80002ca4:	7942                	ld	s2,48(sp)
    80002ca6:	79a2                	ld	s3,40(sp)
    80002ca8:	7a02                	ld	s4,32(sp)
    80002caa:	6ae2                	ld	s5,24(sp)
    80002cac:	6b42                	ld	s6,16(sp)
    80002cae:	6ba2                	ld	s7,8(sp)
    80002cb0:	6c02                	ld	s8,0(sp)
    80002cb2:	6161                	addi	sp,sp,80
    80002cb4:	8082                	ret

0000000080002cb6 <is_accessed>:
  if (acc)
    pg->aging_counter = pg->aging_counter | 0x80000000; // if page was accessed set MSB to 1
}

long is_accessed(struct page_info *pg, int to_reset)
{
    80002cb6:	1101                	addi	sp,sp,-32
    80002cb8:	ec06                	sd	ra,24(sp)
    80002cba:	e822                	sd	s0,16(sp)
    80002cbc:	e426                	sd	s1,8(sp)
    80002cbe:	e04a                	sd	s2,0(sp)
    80002cc0:	1000                	addi	s0,sp,32
    80002cc2:	84aa                	mv	s1,a0
    80002cc4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002cc6:	fffff097          	auipc	ra,0xfffff
    80002cca:	06c080e7          	jalr	108(ra) # 80001d32 <myproc>
  pte_t *pte = walk(p->pagetable, pg->va, 0);
    80002cce:	4601                	li	a2,0
    80002cd0:	608c                	ld	a1,0(s1)
    80002cd2:	6928                	ld	a0,80(a0)
    80002cd4:	ffffe097          	auipc	ra,0xffffe
    80002cd8:	2d2080e7          	jalr	722(ra) # 80000fa6 <walk>
    80002cdc:	87aa                	mv	a5,a0
  long accessed = (*pte & PTE_A);
    80002cde:	6118                	ld	a4,0(a0)
    80002ce0:	04077513          	andi	a0,a4,64
  if (accessed && to_reset)
    80002ce4:	c511                	beqz	a0,80002cf0 <is_accessed+0x3a>
    80002ce6:	00090563          	beqz	s2,80002cf0 <is_accessed+0x3a>
    *pte ^= PTE_A; // reset accessed flag
    80002cea:	04074713          	xori	a4,a4,64
    80002cee:	e398                	sd	a4,0(a5)

  return accessed;
}
    80002cf0:	60e2                	ld	ra,24(sp)
    80002cf2:	6442                	ld	s0,16(sp)
    80002cf4:	64a2                	ld	s1,8(sp)
    80002cf6:	6902                	ld	s2,0(sp)
    80002cf8:	6105                	addi	sp,sp,32
    80002cfa:	8082                	ret

0000000080002cfc <update_NFUA_LAPA_counter>:
{
    80002cfc:	1101                	addi	sp,sp,-32
    80002cfe:	ec06                	sd	ra,24(sp)
    80002d00:	e822                	sd	s0,16(sp)
    80002d02:	e426                	sd	s1,8(sp)
    80002d04:	1000                	addi	s0,sp,32
    80002d06:	84aa                	mv	s1,a0
  long acc = (long)(is_accessed(pg, 1));
    80002d08:	4585                	li	a1,1
    80002d0a:	00000097          	auipc	ra,0x0
    80002d0e:	fac080e7          	jalr	-84(ra) # 80002cb6 <is_accessed>
  pg->aging_counter = (pg->aging_counter >> 1);
    80002d12:	649c                	ld	a5,8(s1)
    80002d14:	8785                	srai	a5,a5,0x1
  if (acc)
    80002d16:	e119                	bnez	a0,80002d1c <update_NFUA_LAPA_counter+0x20>
  pg->aging_counter = (pg->aging_counter >> 1);
    80002d18:	e49c                	sd	a5,8(s1)
    80002d1a:	a029                	j	80002d24 <update_NFUA_LAPA_counter+0x28>
    pg->aging_counter = pg->aging_counter | 0x80000000; // if page was accessed set MSB to 1
    80002d1c:	4705                	li	a4,1
    80002d1e:	077e                	slli	a4,a4,0x1f
    80002d20:	8fd9                	or	a5,a5,a4
    80002d22:	e49c                	sd	a5,8(s1)
}
    80002d24:	60e2                	ld	ra,24(sp)
    80002d26:	6442                	ld	s0,16(sp)
    80002d28:	64a2                	ld	s1,8(sp)
    80002d2a:	6105                	addi	sp,sp,32
    80002d2c:	8082                	ret

0000000080002d2e <update_pages_info>:
{
    80002d2e:	1101                	addi	sp,sp,-32
    80002d30:	ec06                	sd	ra,24(sp)
    80002d32:	e822                	sd	s0,16(sp)
    80002d34:	e426                	sd	s1,8(sp)
    80002d36:	e04a                	sd	s2,0(sp)
    80002d38:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002d3a:	fffff097          	auipc	ra,0xfffff
    80002d3e:	ff8080e7          	jalr	-8(ra) # 80001d32 <myproc>
  for (pg = p->pages_physc_info.pages; pg < &p->pages_physc_info.pages[MAX_PSYC_PAGES]; pg++)
    80002d42:	30850493          	addi	s1,a0,776
    80002d46:	48850913          	addi	s2,a0,1160
    update_NFUA_LAPA_counter(pg);
    80002d4a:	8526                	mv	a0,s1
    80002d4c:	00000097          	auipc	ra,0x0
    80002d50:	fb0080e7          	jalr	-80(ra) # 80002cfc <update_NFUA_LAPA_counter>
  for (pg = p->pages_physc_info.pages; pg < &p->pages_physc_info.pages[MAX_PSYC_PAGES]; pg++)
    80002d54:	04e1                	addi	s1,s1,24
    80002d56:	fe991ae3          	bne	s2,s1,80002d4a <update_pages_info+0x1c>
}
    80002d5a:	60e2                	ld	ra,24(sp)
    80002d5c:	6442                	ld	s0,16(sp)
    80002d5e:	64a2                	ld	s1,8(sp)
    80002d60:	6902                	ld	s2,0(sp)
    80002d62:	6105                	addi	sp,sp,32
    80002d64:	8082                	ret

0000000080002d66 <scheduler>:
{
    80002d66:	715d                	addi	sp,sp,-80
    80002d68:	e486                	sd	ra,72(sp)
    80002d6a:	e0a2                	sd	s0,64(sp)
    80002d6c:	fc26                	sd	s1,56(sp)
    80002d6e:	f84a                	sd	s2,48(sp)
    80002d70:	f44e                	sd	s3,40(sp)
    80002d72:	f052                	sd	s4,32(sp)
    80002d74:	ec56                	sd	s5,24(sp)
    80002d76:	e85a                	sd	s6,16(sp)
    80002d78:	e45e                	sd	s7,8(sp)
    80002d7a:	0880                	addi	s0,sp,80
    80002d7c:	8792                	mv	a5,tp
  int id = r_tp();
    80002d7e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002d80:	00779b13          	slli	s6,a5,0x7
    80002d84:	0000f717          	auipc	a4,0xf
    80002d88:	51c70713          	addi	a4,a4,1308 # 800122a0 <pid_lock>
    80002d8c:	975a                	add	a4,a4,s6
    80002d8e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002d92:	0000f717          	auipc	a4,0xf
    80002d96:	54670713          	addi	a4,a4,1350 # 800122d8 <cpus+0x8>
    80002d9a:	9b3a                	add	s6,s6,a4
      if (p->state == RUNNABLE)
    80002d9c:	498d                	li	s3,3
        p->state = RUNNING;
    80002d9e:	4b91                	li	s7,4
        c->proc = p;
    80002da0:	079e                	slli	a5,a5,0x7
    80002da2:	0000fa17          	auipc	s4,0xf
    80002da6:	4fea0a13          	addi	s4,s4,1278 # 800122a0 <pid_lock>
    80002daa:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80002dac:	00022917          	auipc	s2,0x22
    80002db0:	d2490913          	addi	s2,s2,-732 # 80024ad0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002db4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002db8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dbc:	10079073          	csrw	sstatus,a5
    80002dc0:	00010497          	auipc	s1,0x10
    80002dc4:	91048493          	addi	s1,s1,-1776 # 800126d0 <proc>
        if (p->pid > 2)
    80002dc8:	4a89                	li	s5,2
    80002dca:	a821                	j	80002de2 <scheduler+0x7c>
        c->proc = 0;
    80002dcc:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    80002dd0:	8526                	mv	a0,s1
    80002dd2:	ffffe097          	auipc	ra,0xffffe
    80002dd6:	ea4080e7          	jalr	-348(ra) # 80000c76 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002dda:	49048493          	addi	s1,s1,1168
    80002dde:	fd248be3          	beq	s1,s2,80002db4 <scheduler+0x4e>
      acquire(&p->lock);
    80002de2:	8526                	mv	a0,s1
    80002de4:	ffffe097          	auipc	ra,0xffffe
    80002de8:	dde080e7          	jalr	-546(ra) # 80000bc2 <acquire>
      if (p->state == RUNNABLE)
    80002dec:	4c9c                	lw	a5,24(s1)
    80002dee:	ff3791e3          	bne	a5,s3,80002dd0 <scheduler+0x6a>
        p->state = RUNNING;
    80002df2:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80002df6:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002dfa:	06048593          	addi	a1,s1,96
    80002dfe:	855a                	mv	a0,s6
    80002e00:	00000097          	auipc	ra,0x0
    80002e04:	188080e7          	jalr	392(ra) # 80002f88 <swtch>
        if (p->pid > 2)
    80002e08:	589c                	lw	a5,48(s1)
    80002e0a:	fcfad1e3          	bge	s5,a5,80002dcc <scheduler+0x66>
          update_pages_info();
    80002e0e:	00000097          	auipc	ra,0x0
    80002e12:	f20080e7          	jalr	-224(ra) # 80002d2e <update_pages_info>
    80002e16:	bf5d                	j	80002dcc <scheduler+0x66>

0000000080002e18 <reset_aging_counter>:
void reset_aging_counter(struct page_info *pg)
{
    80002e18:	1141                	addi	sp,sp,-16
    80002e1a:	e422                	sd	s0,8(sp)
    80002e1c:	0800                	addi	s0,sp,16
#ifdef NFUA
  pg->aging_counter = 0x00000000; //TODO return to 0
  // pg->aging_counter = 0;//TODO return to 0

#elif LAPA
  pg->aging_counter = 0xFFFFFFFF;
    80002e1e:	57fd                	li	a5,-1
    80002e20:	9381                	srli	a5,a5,0x20
    80002e22:	e51c                	sd	a5,8(a0)
#endif
}
    80002e24:	6422                	ld	s0,8(sp)
    80002e26:	0141                	addi	sp,sp,16
    80002e28:	8082                	ret

0000000080002e2a <print_pages_from_info_arrs>:

void print_pages_from_info_arrs()
{
    80002e2a:	7139                	addi	sp,sp,-64
    80002e2c:	fc06                	sd	ra,56(sp)
    80002e2e:	f822                	sd	s0,48(sp)
    80002e30:	f426                	sd	s1,40(sp)
    80002e32:	f04a                	sd	s2,32(sp)
    80002e34:	ec4e                	sd	s3,24(sp)
    80002e36:	e852                	sd	s4,16(sp)
    80002e38:	e456                	sd	s5,8(sp)
    80002e3a:	e05a                	sd	s6,0(sp)
    80002e3c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002e3e:	fffff097          	auipc	ra,0xfffff
    80002e42:	ef4080e7          	jalr	-268(ra) # 80001d32 <myproc>
    80002e46:	89aa                	mv	s3,a0
  printf("\n physic pages \t\t\t\t\t\t\t\tswap file::\n");
    80002e48:	00006517          	auipc	a0,0x6
    80002e4c:	78850513          	addi	a0,a0,1928 # 800095d0 <digits+0x590>
    80002e50:	ffffd097          	auipc	ra,0xffffd
    80002e54:	724080e7          	jalr	1828(ra) # 80000574 <printf>
  printf("index\t(va, used, aging)\t\t\t\t\t\t(va , used)  \n ");
    80002e58:	00006517          	auipc	a0,0x6
    80002e5c:	7a050513          	addi	a0,a0,1952 # 800095f8 <digits+0x5b8>
    80002e60:	ffffd097          	auipc	ra,0xffffd
    80002e64:	714080e7          	jalr	1812(ra) # 80000574 <printf>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002e68:	18098913          	addi	s2,s3,384
    80002e6c:	4481                	li	s1,0
  {
    printf("%d:\t(%p , %d ,\t %p)\t\t(%p , %d)  \n ", i, p->pages_physc_info.pages[i].va,
           (p->pages_physc_info.free_spaces & (1 << i)) > 0,
    80002e6e:	4b05                	li	s6,1
    printf("%d:\t(%p , %d ,\t %p)\t\t(%p , %d)  \n ", i, p->pages_physc_info.pages[i].va,
    80002e70:	00006a97          	auipc	s5,0x6
    80002e74:	7b8a8a93          	addi	s5,s5,1976 # 80009628 <digits+0x5e8>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002e78:	4a41                	li	s4,16
           (p->pages_physc_info.free_spaces & (1 << i)) > 0,
    80002e7a:	009b16bb          	sllw	a3,s6,s1
           p->pages_physc_info.pages[i].aging_counter,
           p->pages_swap_info.pages[i].va, (p->pages_swap_info.free_spaces & (1 << i)) > 0);
    80002e7e:	1789d803          	lhu	a6,376(s3)
    printf("%d:\t(%p , %d ,\t %p)\t\t(%p , %d)  \n ", i, p->pages_physc_info.pages[i].va,
    80002e82:	0106f833          	and	a6,a3,a6
           (p->pages_physc_info.free_spaces & (1 << i)) > 0,
    80002e86:	3009d783          	lhu	a5,768(s3)
    printf("%d:\t(%p , %d ,\t %p)\t\t(%p , %d)  \n ", i, p->pages_physc_info.pages[i].va,
    80002e8a:	8efd                	and	a3,a3,a5
    80002e8c:	01003833          	snez	a6,a6
    80002e90:	00093783          	ld	a5,0(s2)
    80002e94:	19093703          	ld	a4,400(s2)
    80002e98:	00d036b3          	snez	a3,a3
    80002e9c:	18893603          	ld	a2,392(s2)
    80002ea0:	85a6                	mv	a1,s1
    80002ea2:	8556                	mv	a0,s5
    80002ea4:	ffffd097          	auipc	ra,0xffffd
    80002ea8:	6d0080e7          	jalr	1744(ra) # 80000574 <printf>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002eac:	2485                	addiw	s1,s1,1
    80002eae:	0961                	addi	s2,s2,24
    80002eb0:	fd4495e3          	bne	s1,s4,80002e7a <print_pages_from_info_arrs+0x50>
  }
}
    80002eb4:	70e2                	ld	ra,56(sp)
    80002eb6:	7442                	ld	s0,48(sp)
    80002eb8:	74a2                	ld	s1,40(sp)
    80002eba:	7902                	ld	s2,32(sp)
    80002ebc:	69e2                	ld	s3,24(sp)
    80002ebe:	6a42                	ld	s4,16(sp)
    80002ec0:	6aa2                	ld	s5,8(sp)
    80002ec2:	6b02                	ld	s6,0(sp)
    80002ec4:	6121                	addi	sp,sp,64
    80002ec6:	8082                	ret

0000000080002ec8 <get_next_page_to_swap_out>:
{
    80002ec8:	1101                	addi	sp,sp,-32
    80002eca:	ec06                	sd	ra,24(sp)
    80002ecc:	e822                	sd	s0,16(sp)
    80002ece:	e426                	sd	s1,8(sp)
    80002ed0:	1000                	addi	s0,sp,32
  printf("debug: LOOKING FOR PAGE TO SWAPOUT\n");
    80002ed2:	00006517          	auipc	a0,0x6
    80002ed6:	77e50513          	addi	a0,a0,1918 # 80009650 <digits+0x610>
    80002eda:	ffffd097          	auipc	ra,0xffffd
    80002ede:	69a080e7          	jalr	1690(ra) # 80000574 <printf>
  print_pages_from_info_arrs();
    80002ee2:	00000097          	auipc	ra,0x0
    80002ee6:	f48080e7          	jalr	-184(ra) # 80002e2a <print_pages_from_info_arrs>
  selected_pg_index = compare_all_pages(LAPA_compare);
    80002eea:	00000517          	auipc	a0,0x0
    80002eee:	cf650513          	addi	a0,a0,-778 # 80002be0 <LAPA_compare>
    80002ef2:	00000097          	auipc	ra,0x0
    80002ef6:	d4c080e7          	jalr	-692(ra) # 80002c3e <compare_all_pages>
    80002efa:	84aa                	mv	s1,a0
  printf("debug: NEXT PAGE TO SWAPOUT = %d\n", selected_pg_index);
    80002efc:	85aa                	mv	a1,a0
    80002efe:	00006517          	auipc	a0,0x6
    80002f02:	77a50513          	addi	a0,a0,1914 # 80009678 <digits+0x638>
    80002f06:	ffffd097          	auipc	ra,0xffffd
    80002f0a:	66e080e7          	jalr	1646(ra) # 80000574 <printf>
}
    80002f0e:	8526                	mv	a0,s1
    80002f10:	60e2                	ld	ra,24(sp)
    80002f12:	6442                	ld	s0,16(sp)
    80002f14:	64a2                	ld	s1,8(sp)
    80002f16:	6105                	addi	sp,sp,32
    80002f18:	8082                	ret

0000000080002f1a <lazy_allocate>:
    
//----------------------------------------------BONUS
uint64 lazy_allocate(uint64 va)
{
    80002f1a:	7179                	addi	sp,sp,-48
    80002f1c:	f406                	sd	ra,40(sp)
    80002f1e:	f022                	sd	s0,32(sp)
    80002f20:	ec26                	sd	s1,24(sp)
    80002f22:	e84a                	sd	s2,16(sp)
    80002f24:	e44e                	sd	s3,8(sp)
    80002f26:	1800                	addi	s0,sp,48
  uint64 rva = PGROUNDDOWN(va);
    80002f28:	797d                	lui	s2,0xfffff
    80002f2a:	01257933          	and	s2,a0,s2
  char *pa = kalloc();
    80002f2e:	ffffe097          	auipc	ra,0xffffe
    80002f32:	ba4080e7          	jalr	-1116(ra) # 80000ad2 <kalloc>
  if ( pa <= 0)
    80002f36:	c539                	beqz	a0,80002f84 <lazy_allocate+0x6a>
    80002f38:	84aa                	mv	s1,a0
    return -1;

  memset(pa, 0, PGSIZE);
    80002f3a:	6605                	lui	a2,0x1
    80002f3c:	4581                	li	a1,0
    80002f3e:	ffffe097          	auipc	ra,0xffffe
    80002f42:	d80080e7          	jalr	-640(ra) # 80000cbe <memset>

  if (mappages(myproc()->pagetable, rva, PGSIZE, (uint64)pa, PTE_W | PTE_X | PTE_R | PTE_U) < 0){
    80002f46:	fffff097          	auipc	ra,0xfffff
    80002f4a:	dec080e7          	jalr	-532(ra) # 80001d32 <myproc>
    80002f4e:	89a6                	mv	s3,s1
    80002f50:	4779                	li	a4,30
    80002f52:	86a6                	mv	a3,s1
    80002f54:	6605                	lui	a2,0x1
    80002f56:	85ca                	mv	a1,s2
    80002f58:	6928                	ld	a0,80(a0)
    80002f5a:	ffffe097          	auipc	ra,0xffffe
    80002f5e:	160080e7          	jalr	352(ra) # 800010ba <mappages>
    80002f62:	00054a63          	bltz	a0,80002f76 <lazy_allocate+0x5c>
    return -1;
  }


  return (uint64)pa;
}
    80002f66:	854e                	mv	a0,s3
    80002f68:	70a2                	ld	ra,40(sp)
    80002f6a:	7402                	ld	s0,32(sp)
    80002f6c:	64e2                	ld	s1,24(sp)
    80002f6e:	6942                	ld	s2,16(sp)
    80002f70:	69a2                	ld	s3,8(sp)
    80002f72:	6145                	addi	sp,sp,48
    80002f74:	8082                	ret
    kfree(pa);
    80002f76:	8526                	mv	a0,s1
    80002f78:	ffffe097          	auipc	ra,0xffffe
    80002f7c:	a5e080e7          	jalr	-1442(ra) # 800009d6 <kfree>
    return -1;
    80002f80:	59fd                	li	s3,-1
    80002f82:	b7d5                	j	80002f66 <lazy_allocate+0x4c>
    return -1;
    80002f84:	59fd                	li	s3,-1
    80002f86:	b7c5                	j	80002f66 <lazy_allocate+0x4c>

0000000080002f88 <swtch>:
    80002f88:	00153023          	sd	ra,0(a0)
    80002f8c:	00253423          	sd	sp,8(a0)
    80002f90:	e900                	sd	s0,16(a0)
    80002f92:	ed04                	sd	s1,24(a0)
    80002f94:	03253023          	sd	s2,32(a0)
    80002f98:	03353423          	sd	s3,40(a0)
    80002f9c:	03453823          	sd	s4,48(a0)
    80002fa0:	03553c23          	sd	s5,56(a0)
    80002fa4:	05653023          	sd	s6,64(a0)
    80002fa8:	05753423          	sd	s7,72(a0)
    80002fac:	05853823          	sd	s8,80(a0)
    80002fb0:	05953c23          	sd	s9,88(a0)
    80002fb4:	07a53023          	sd	s10,96(a0)
    80002fb8:	07b53423          	sd	s11,104(a0)
    80002fbc:	0005b083          	ld	ra,0(a1)
    80002fc0:	0085b103          	ld	sp,8(a1)
    80002fc4:	6980                	ld	s0,16(a1)
    80002fc6:	6d84                	ld	s1,24(a1)
    80002fc8:	0205b903          	ld	s2,32(a1)
    80002fcc:	0285b983          	ld	s3,40(a1)
    80002fd0:	0305ba03          	ld	s4,48(a1)
    80002fd4:	0385ba83          	ld	s5,56(a1)
    80002fd8:	0405bb03          	ld	s6,64(a1)
    80002fdc:	0485bb83          	ld	s7,72(a1)
    80002fe0:	0505bc03          	ld	s8,80(a1)
    80002fe4:	0585bc83          	ld	s9,88(a1)
    80002fe8:	0605bd03          	ld	s10,96(a1)
    80002fec:	0685bd83          	ld	s11,104(a1)
    80002ff0:	8082                	ret

0000000080002ff2 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002ff2:	1141                	addi	sp,sp,-16
    80002ff4:	e406                	sd	ra,8(sp)
    80002ff6:	e022                	sd	s0,0(sp)
    80002ff8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002ffa:	00006597          	auipc	a1,0x6
    80002ffe:	6fe58593          	addi	a1,a1,1790 # 800096f8 <states.0+0x30>
    80003002:	00022517          	auipc	a0,0x22
    80003006:	ace50513          	addi	a0,a0,-1330 # 80024ad0 <tickslock>
    8000300a:	ffffe097          	auipc	ra,0xffffe
    8000300e:	b28080e7          	jalr	-1240(ra) # 80000b32 <initlock>
}
    80003012:	60a2                	ld	ra,8(sp)
    80003014:	6402                	ld	s0,0(sp)
    80003016:	0141                	addi	sp,sp,16
    80003018:	8082                	ret

000000008000301a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    8000301a:	1141                	addi	sp,sp,-16
    8000301c:	e422                	sd	s0,8(sp)
    8000301e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003020:	00004797          	auipc	a5,0x4
    80003024:	ae078793          	addi	a5,a5,-1312 # 80006b00 <kernelvec>
    80003028:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000302c:	6422                	ld	s0,8(sp)
    8000302e:	0141                	addi	sp,sp,16
    80003030:	8082                	ret

0000000080003032 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80003032:	1141                	addi	sp,sp,-16
    80003034:	e406                	sd	ra,8(sp)
    80003036:	e022                	sd	s0,0(sp)
    80003038:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000303a:	fffff097          	auipc	ra,0xfffff
    8000303e:	cf8080e7          	jalr	-776(ra) # 80001d32 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003042:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80003046:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003048:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000304c:	00005617          	auipc	a2,0x5
    80003050:	fb460613          	addi	a2,a2,-76 # 80008000 <_trampoline>
    80003054:	00005697          	auipc	a3,0x5
    80003058:	fac68693          	addi	a3,a3,-84 # 80008000 <_trampoline>
    8000305c:	8e91                	sub	a3,a3,a2
    8000305e:	040007b7          	lui	a5,0x4000
    80003062:	17fd                	addi	a5,a5,-1
    80003064:	07b2                	slli	a5,a5,0xc
    80003066:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003068:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000306c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000306e:	180026f3          	csrr	a3,satp
    80003072:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80003074:	6d38                	ld	a4,88(a0)
    80003076:	6134                	ld	a3,64(a0)
    80003078:	6585                	lui	a1,0x1
    8000307a:	96ae                	add	a3,a3,a1
    8000307c:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000307e:	6d38                	ld	a4,88(a0)
    80003080:	00000697          	auipc	a3,0x0
    80003084:	13868693          	addi	a3,a3,312 # 800031b8 <usertrap>
    80003088:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    8000308a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000308c:	8692                	mv	a3,tp
    8000308e:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003090:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80003094:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80003098:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000309c:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800030a0:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800030a2:	6f18                	ld	a4,24(a4)
    800030a4:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800030a8:	692c                	ld	a1,80(a0)
    800030aa:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800030ac:	00005717          	auipc	a4,0x5
    800030b0:	fe470713          	addi	a4,a4,-28 # 80008090 <userret>
    800030b4:	8f11                	sub	a4,a4,a2
    800030b6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))fn)(TRAPFRAME, satp);
    800030b8:	577d                	li	a4,-1
    800030ba:	177e                	slli	a4,a4,0x3f
    800030bc:	8dd9                	or	a1,a1,a4
    800030be:	02000537          	lui	a0,0x2000
    800030c2:	157d                	addi	a0,a0,-1
    800030c4:	0536                	slli	a0,a0,0xd
    800030c6:	9782                	jalr	a5
}
    800030c8:	60a2                	ld	ra,8(sp)
    800030ca:	6402                	ld	s0,0(sp)
    800030cc:	0141                	addi	sp,sp,16
    800030ce:	8082                	ret

00000000800030d0 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    800030d0:	1101                	addi	sp,sp,-32
    800030d2:	ec06                	sd	ra,24(sp)
    800030d4:	e822                	sd	s0,16(sp)
    800030d6:	e426                	sd	s1,8(sp)
    800030d8:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800030da:	00022497          	auipc	s1,0x22
    800030de:	9f648493          	addi	s1,s1,-1546 # 80024ad0 <tickslock>
    800030e2:	8526                	mv	a0,s1
    800030e4:	ffffe097          	auipc	ra,0xffffe
    800030e8:	ade080e7          	jalr	-1314(ra) # 80000bc2 <acquire>
  ticks++;
    800030ec:	00007517          	auipc	a0,0x7
    800030f0:	f4450513          	addi	a0,a0,-188 # 8000a030 <ticks>
    800030f4:	411c                	lw	a5,0(a0)
    800030f6:	2785                	addiw	a5,a5,1
    800030f8:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800030fa:	fffff097          	auipc	ra,0xfffff
    800030fe:	2bc080e7          	jalr	700(ra) # 800023b6 <wakeup>
  release(&tickslock);
    80003102:	8526                	mv	a0,s1
    80003104:	ffffe097          	auipc	ra,0xffffe
    80003108:	b72080e7          	jalr	-1166(ra) # 80000c76 <release>
}
    8000310c:	60e2                	ld	ra,24(sp)
    8000310e:	6442                	ld	s0,16(sp)
    80003110:	64a2                	ld	s1,8(sp)
    80003112:	6105                	addi	sp,sp,32
    80003114:	8082                	ret

0000000080003116 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80003116:	1101                	addi	sp,sp,-32
    80003118:	ec06                	sd	ra,24(sp)
    8000311a:	e822                	sd	s0,16(sp)
    8000311c:	e426                	sd	s1,8(sp)
    8000311e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003120:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80003124:	00074d63          	bltz	a4,8000313e <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80003128:	57fd                	li	a5,-1
    8000312a:	17fe                	slli	a5,a5,0x3f
    8000312c:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    8000312e:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80003130:	06f70363          	beq	a4,a5,80003196 <devintr+0x80>
  }
}
    80003134:	60e2                	ld	ra,24(sp)
    80003136:	6442                	ld	s0,16(sp)
    80003138:	64a2                	ld	s1,8(sp)
    8000313a:	6105                	addi	sp,sp,32
    8000313c:	8082                	ret
      (scause & 0xff) == 9)
    8000313e:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    80003142:	46a5                	li	a3,9
    80003144:	fed792e3          	bne	a5,a3,80003128 <devintr+0x12>
    int irq = plic_claim();
    80003148:	00004097          	auipc	ra,0x4
    8000314c:	ac0080e7          	jalr	-1344(ra) # 80006c08 <plic_claim>
    80003150:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80003152:	47a9                	li	a5,10
    80003154:	02f50763          	beq	a0,a5,80003182 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80003158:	4785                	li	a5,1
    8000315a:	02f50963          	beq	a0,a5,8000318c <devintr+0x76>
    return 1;
    8000315e:	4505                	li	a0,1
    else if (irq)
    80003160:	d8f1                	beqz	s1,80003134 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80003162:	85a6                	mv	a1,s1
    80003164:	00006517          	auipc	a0,0x6
    80003168:	59c50513          	addi	a0,a0,1436 # 80009700 <states.0+0x38>
    8000316c:	ffffd097          	auipc	ra,0xffffd
    80003170:	408080e7          	jalr	1032(ra) # 80000574 <printf>
      plic_complete(irq);
    80003174:	8526                	mv	a0,s1
    80003176:	00004097          	auipc	ra,0x4
    8000317a:	ab6080e7          	jalr	-1354(ra) # 80006c2c <plic_complete>
    return 1;
    8000317e:	4505                	li	a0,1
    80003180:	bf55                	j	80003134 <devintr+0x1e>
      uartintr();
    80003182:	ffffe097          	auipc	ra,0xffffe
    80003186:	804080e7          	jalr	-2044(ra) # 80000986 <uartintr>
    8000318a:	b7ed                	j	80003174 <devintr+0x5e>
      virtio_disk_intr();
    8000318c:	00004097          	auipc	ra,0x4
    80003190:	f32080e7          	jalr	-206(ra) # 800070be <virtio_disk_intr>
    80003194:	b7c5                	j	80003174 <devintr+0x5e>
    if (cpuid() == 0)
    80003196:	fffff097          	auipc	ra,0xfffff
    8000319a:	b70080e7          	jalr	-1168(ra) # 80001d06 <cpuid>
    8000319e:	c901                	beqz	a0,800031ae <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800031a0:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800031a4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800031a6:	14479073          	csrw	sip,a5
    return 2;
    800031aa:	4509                	li	a0,2
    800031ac:	b761                	j	80003134 <devintr+0x1e>
      clockintr();
    800031ae:	00000097          	auipc	ra,0x0
    800031b2:	f22080e7          	jalr	-222(ra) # 800030d0 <clockintr>
    800031b6:	b7ed                	j	800031a0 <devintr+0x8a>

00000000800031b8 <usertrap>:
{
    800031b8:	7179                	addi	sp,sp,-48
    800031ba:	f406                	sd	ra,40(sp)
    800031bc:	f022                	sd	s0,32(sp)
    800031be:	ec26                	sd	s1,24(sp)
    800031c0:	e84a                	sd	s2,16(sp)
    800031c2:	e44e                	sd	s3,8(sp)
    800031c4:	e052                	sd	s4,0(sp)
    800031c6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800031c8:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800031cc:	1007f793          	andi	a5,a5,256
    800031d0:	ebd9                	bnez	a5,80003266 <usertrap+0xae>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800031d2:	00004797          	auipc	a5,0x4
    800031d6:	92e78793          	addi	a5,a5,-1746 # 80006b00 <kernelvec>
    800031da:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800031de:	fffff097          	auipc	ra,0xfffff
    800031e2:	b54080e7          	jalr	-1196(ra) # 80001d32 <myproc>
    800031e6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800031e8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800031ea:	14102773          	csrr	a4,sepc
    800031ee:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800031f0:	142027f3          	csrr	a5,scause
  if (trap_cause == 8)
    800031f4:	4721                	li	a4,8
    800031f6:	08e78063          	beq	a5,a4,80003276 <usertrap+0xbe>
  else if (trap_cause == 13 || trap_cause == 15 || trap_cause == 12)
    800031fa:	473d                	li	a4,15
    800031fc:	00e78663          	beq	a5,a4,80003208 <usertrap+0x50>
    80003200:	17d1                	addi	a5,a5,-12
    80003202:	4705                	li	a4,1
    80003204:	12f76b63          	bltu	a4,a5,8000333a <usertrap+0x182>
    struct proc *p = myproc();
    80003208:	fffff097          	auipc	ra,0xfffff
    8000320c:	b2a080e7          	jalr	-1238(ra) # 80001d32 <myproc>
    80003210:	892a                	mv	s2,a0
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003212:	143029f3          	csrr	s3,stval
    uint64 fault_rva = PGROUNDDOWN(fault_va);
    80003216:	7a7d                	lui	s4,0xfffff
    80003218:	0149fa33          	and	s4,s3,s4
    printf("in page fault,va=%p,rva = %p\n",fault_va,fault_rva);
    8000321c:	8652                	mv	a2,s4
    8000321e:	85ce                	mv	a1,s3
    80003220:	00006517          	auipc	a0,0x6
    80003224:	52050513          	addi	a0,a0,1312 # 80009740 <states.0+0x78>
    80003228:	ffffd097          	auipc	ra,0xffffd
    8000322c:	34c080e7          	jalr	844(ra) # 80000574 <printf>
    pte_t *pte = walk(p->pagetable, fault_va, 0);
    80003230:	4601                	li	a2,0
    80003232:	85ce                	mv	a1,s3
    80003234:	05093503          	ld	a0,80(s2) # fffffffffffff050 <end+0xffffffff7ffcc050>
    80003238:	ffffe097          	auipc	ra,0xffffe
    8000323c:	d6e080e7          	jalr	-658(ra) # 80000fa6 <walk>
    80003240:	89aa                	mv	s3,a0
    if (!pte || p->pid <= 2)
    80003242:	c511                	beqz	a0,8000324e <usertrap+0x96>
    80003244:	03092703          	lw	a4,48(s2)
    80003248:	4789                	li	a5,2
    8000324a:	06e7ca63          	blt	a5,a4,800032be <usertrap+0x106>
      printf("segfault with SELCTION!=NONE\n");
    8000324e:	00006517          	auipc	a0,0x6
    80003252:	51250513          	addi	a0,a0,1298 # 80009760 <states.0+0x98>
    80003256:	ffffd097          	auipc	ra,0xffffd
    8000325a:	31e080e7          	jalr	798(ra) # 80000574 <printf>
      p->killed = 1 ;
    8000325e:	4785                	li	a5,1
    80003260:	02f92423          	sw	a5,40(s2)
      goto end;
    80003264:	a80d                	j	80003296 <usertrap+0xde>
    panic("usertrap: not from user mode");
    80003266:	00006517          	auipc	a0,0x6
    8000326a:	4ba50513          	addi	a0,a0,1210 # 80009720 <states.0+0x58>
    8000326e:	ffffd097          	auipc	ra,0xffffd
    80003272:	2bc080e7          	jalr	700(ra) # 8000052a <panic>
    if (p->killed)
    80003276:	551c                	lw	a5,40(a0)
    80003278:	ef8d                	bnez	a5,800032b2 <usertrap+0xfa>
    p->trapframe->epc += 4;
    8000327a:	6cb8                	ld	a4,88(s1)
    8000327c:	6f1c                	ld	a5,24(a4)
    8000327e:	0791                	addi	a5,a5,4
    80003280:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003282:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003286:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000328a:	10079073          	csrw	sstatus,a5
    syscall();
    8000328e:	00000097          	auipc	ra,0x0
    80003292:	36a080e7          	jalr	874(ra) # 800035f8 <syscall>
  if (p->killed)
    80003296:	549c                	lw	a5,40(s1)
    80003298:	e7e5                	bnez	a5,80003380 <usertrap+0x1c8>
  usertrapret();
    8000329a:	00000097          	auipc	ra,0x0
    8000329e:	d98080e7          	jalr	-616(ra) # 80003032 <usertrapret>
}
    800032a2:	70a2                	ld	ra,40(sp)
    800032a4:	7402                	ld	s0,32(sp)
    800032a6:	64e2                	ld	s1,24(sp)
    800032a8:	6942                	ld	s2,16(sp)
    800032aa:	69a2                	ld	s3,8(sp)
    800032ac:	6a02                	ld	s4,0(sp)
    800032ae:	6145                	addi	sp,sp,48
    800032b0:	8082                	ret
      exit(-1);
    800032b2:	557d                	li	a0,-1
    800032b4:	fffff097          	auipc	ra,0xfffff
    800032b8:	1d2080e7          	jalr	466(ra) # 80002486 <exit>
    800032bc:	bf7d                	j	8000327a <usertrap+0xc2>
    printf("debug: PAGE FAULT\n");
    800032be:	00006517          	auipc	a0,0x6
    800032c2:	4c250513          	addi	a0,a0,1218 # 80009780 <states.0+0xb8>
    800032c6:	ffffd097          	auipc	ra,0xffffd
    800032ca:	2ae080e7          	jalr	686(ra) # 80000574 <printf>
    if ((*pte & PTE_PG) && !(*pte & PTE_V))
    800032ce:	0009b783          	ld	a5,0(s3)
    800032d2:	2017f693          	andi	a3,a5,513
    800032d6:	20000713          	li	a4,512
    800032da:	00e68863          	beq	a3,a4,800032ea <usertrap+0x132>
    else if (*pte & PTE_V)
    800032de:	8b85                	andi	a5,a5,1
    800032e0:	dbdd                	beqz	a5,80003296 <usertrap+0xde>
      p->killed = 1;  // PTE should be invalid in case of page paged out
    800032e2:	4785                	li	a5,1
    800032e4:	02f92423          	sw	a5,40(s2)
      goto end;
    800032e8:	b77d                	j	80003296 <usertrap+0xde>
      if (p->physical_pages_num >= MAX_PSYC_PAGES)
    800032ea:	17092703          	lw	a4,368(s2)
    800032ee:	47bd                	li	a5,15
    800032f0:	02e7d663          	bge	a5,a4,8000331c <usertrap+0x164>
        int page_to_swap_out_index = get_next_page_to_swap_out();
    800032f4:	00000097          	auipc	ra,0x0
    800032f8:	bd4080e7          	jalr	-1068(ra) # 80002ec8 <get_next_page_to_swap_out>
        if (page_to_swap_out_index < 0 || page_to_swap_out_index > MAX_PSYC_PAGES){
    800032fc:	0005071b          	sext.w	a4,a0
    80003300:	47c1                	li	a5,16
    80003302:	02e7e463          	bltu	a5,a4,8000332a <usertrap+0x172>
        uint64 va = p->pages_physc_info.pages[page_to_swap_out_index].va;
    80003306:	00151793          	slli	a5,a0,0x1
    8000330a:	97aa                	add	a5,a5,a0
    8000330c:	078e                	slli	a5,a5,0x3
    8000330e:	993e                	add	s2,s2,a5
       page_out(va);
    80003310:	30893503          	ld	a0,776(s2)
    80003314:	fffff097          	auipc	ra,0xfffff
    80003318:	470080e7          	jalr	1136(ra) # 80002784 <page_out>
     page_in(fault_rva, pte);
    8000331c:	85ce                	mv	a1,s3
    8000331e:	8552                	mv	a0,s4
    80003320:	fffff097          	auipc	ra,0xfffff
    80003324:	512080e7          	jalr	1298(ra) # 80002832 <page_in>
    80003328:	b7bd                	j	80003296 <usertrap+0xde>
          panic("usertrap: did not find page to swap out");
    8000332a:	00006517          	auipc	a0,0x6
    8000332e:	46e50513          	addi	a0,a0,1134 # 80009798 <states.0+0xd0>
    80003332:	ffffd097          	auipc	ra,0xffffd
    80003336:	1f8080e7          	jalr	504(ra) # 8000052a <panic>
  else if ((which_dev = devintr()) != 0)
    8000333a:	00000097          	auipc	ra,0x0
    8000333e:	ddc080e7          	jalr	-548(ra) # 80003116 <devintr>
    80003342:	892a                	mv	s2,a0
    80003344:	c501                	beqz	a0,8000334c <usertrap+0x194>
  if (p->killed)
    80003346:	549c                	lw	a5,40(s1)
    80003348:	c3b1                	beqz	a5,8000338c <usertrap+0x1d4>
    8000334a:	a825                	j	80003382 <usertrap+0x1ca>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000334c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003350:	5890                	lw	a2,48(s1)
    80003352:	00006517          	auipc	a0,0x6
    80003356:	46e50513          	addi	a0,a0,1134 # 800097c0 <states.0+0xf8>
    8000335a:	ffffd097          	auipc	ra,0xffffd
    8000335e:	21a080e7          	jalr	538(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003362:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003366:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000336a:	00006517          	auipc	a0,0x6
    8000336e:	48650513          	addi	a0,a0,1158 # 800097f0 <states.0+0x128>
    80003372:	ffffd097          	auipc	ra,0xffffd
    80003376:	202080e7          	jalr	514(ra) # 80000574 <printf>
    p->killed = 1;
    8000337a:	4785                	li	a5,1
    8000337c:	d49c                	sw	a5,40(s1)
  if (p->killed)
    8000337e:	a011                	j	80003382 <usertrap+0x1ca>
    80003380:	4901                	li	s2,0
    exit(-1);
    80003382:	557d                	li	a0,-1
    80003384:	fffff097          	auipc	ra,0xfffff
    80003388:	102080e7          	jalr	258(ra) # 80002486 <exit>
  if (which_dev == 2)
    8000338c:	4789                	li	a5,2
    8000338e:	f0f916e3          	bne	s2,a5,8000329a <usertrap+0xe2>
    yield();
    80003392:	fffff097          	auipc	ra,0xfffff
    80003396:	e5c080e7          	jalr	-420(ra) # 800021ee <yield>
    8000339a:	b701                	j	8000329a <usertrap+0xe2>

000000008000339c <kerneltrap>:
{
    8000339c:	7179                	addi	sp,sp,-48
    8000339e:	f406                	sd	ra,40(sp)
    800033a0:	f022                	sd	s0,32(sp)
    800033a2:	ec26                	sd	s1,24(sp)
    800033a4:	e84a                	sd	s2,16(sp)
    800033a6:	e44e                	sd	s3,8(sp)
    800033a8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800033aa:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800033ae:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800033b2:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    800033b6:	1004f793          	andi	a5,s1,256
    800033ba:	cb85                	beqz	a5,800033ea <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800033bc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800033c0:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800033c2:	ef85                	bnez	a5,800033fa <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    800033c4:	00000097          	auipc	ra,0x0
    800033c8:	d52080e7          	jalr	-686(ra) # 80003116 <devintr>
    800033cc:	cd1d                	beqz	a0,8000340a <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800033ce:	4789                	li	a5,2
    800033d0:	08f50763          	beq	a0,a5,8000345e <kerneltrap+0xc2>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800033d4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800033d8:	10049073          	csrw	sstatus,s1
}
    800033dc:	70a2                	ld	ra,40(sp)
    800033de:	7402                	ld	s0,32(sp)
    800033e0:	64e2                	ld	s1,24(sp)
    800033e2:	6942                	ld	s2,16(sp)
    800033e4:	69a2                	ld	s3,8(sp)
    800033e6:	6145                	addi	sp,sp,48
    800033e8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800033ea:	00006517          	auipc	a0,0x6
    800033ee:	42650513          	addi	a0,a0,1062 # 80009810 <states.0+0x148>
    800033f2:	ffffd097          	auipc	ra,0xffffd
    800033f6:	138080e7          	jalr	312(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    800033fa:	00006517          	auipc	a0,0x6
    800033fe:	43e50513          	addi	a0,a0,1086 # 80009838 <states.0+0x170>
    80003402:	ffffd097          	auipc	ra,0xffffd
    80003406:	128080e7          	jalr	296(ra) # 8000052a <panic>
    printf("pid = %d\n",myproc()->pid);
    8000340a:	fffff097          	auipc	ra,0xfffff
    8000340e:	928080e7          	jalr	-1752(ra) # 80001d32 <myproc>
    80003412:	590c                	lw	a1,48(a0)
    80003414:	00006517          	auipc	a0,0x6
    80003418:	44450513          	addi	a0,a0,1092 # 80009858 <states.0+0x190>
    8000341c:	ffffd097          	auipc	ra,0xffffd
    80003420:	158080e7          	jalr	344(ra) # 80000574 <printf>
    printf("scause %p\n", scause);
    80003424:	85ce                	mv	a1,s3
    80003426:	00006517          	auipc	a0,0x6
    8000342a:	44250513          	addi	a0,a0,1090 # 80009868 <states.0+0x1a0>
    8000342e:	ffffd097          	auipc	ra,0xffffd
    80003432:	146080e7          	jalr	326(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003436:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000343a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000343e:	00006517          	auipc	a0,0x6
    80003442:	43a50513          	addi	a0,a0,1082 # 80009878 <states.0+0x1b0>
    80003446:	ffffd097          	auipc	ra,0xffffd
    8000344a:	12e080e7          	jalr	302(ra) # 80000574 <printf>
    panic("kerneltrap");
    8000344e:	00006517          	auipc	a0,0x6
    80003452:	44250513          	addi	a0,a0,1090 # 80009890 <states.0+0x1c8>
    80003456:	ffffd097          	auipc	ra,0xffffd
    8000345a:	0d4080e7          	jalr	212(ra) # 8000052a <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000345e:	fffff097          	auipc	ra,0xfffff
    80003462:	8d4080e7          	jalr	-1836(ra) # 80001d32 <myproc>
    80003466:	d53d                	beqz	a0,800033d4 <kerneltrap+0x38>
    80003468:	fffff097          	auipc	ra,0xfffff
    8000346c:	8ca080e7          	jalr	-1846(ra) # 80001d32 <myproc>
    80003470:	4d18                	lw	a4,24(a0)
    80003472:	4791                	li	a5,4
    80003474:	f6f710e3          	bne	a4,a5,800033d4 <kerneltrap+0x38>
    yield();
    80003478:	fffff097          	auipc	ra,0xfffff
    8000347c:	d76080e7          	jalr	-650(ra) # 800021ee <yield>
    80003480:	bf91                	j	800033d4 <kerneltrap+0x38>

0000000080003482 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003482:	1101                	addi	sp,sp,-32
    80003484:	ec06                	sd	ra,24(sp)
    80003486:	e822                	sd	s0,16(sp)
    80003488:	e426                	sd	s1,8(sp)
    8000348a:	1000                	addi	s0,sp,32
    8000348c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000348e:	fffff097          	auipc	ra,0xfffff
    80003492:	8a4080e7          	jalr	-1884(ra) # 80001d32 <myproc>
  switch (n) {
    80003496:	4795                	li	a5,5
    80003498:	0497e163          	bltu	a5,s1,800034da <argraw+0x58>
    8000349c:	048a                	slli	s1,s1,0x2
    8000349e:	00006717          	auipc	a4,0x6
    800034a2:	42a70713          	addi	a4,a4,1066 # 800098c8 <states.0+0x200>
    800034a6:	94ba                	add	s1,s1,a4
    800034a8:	409c                	lw	a5,0(s1)
    800034aa:	97ba                	add	a5,a5,a4
    800034ac:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800034ae:	6d3c                	ld	a5,88(a0)
    800034b0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800034b2:	60e2                	ld	ra,24(sp)
    800034b4:	6442                	ld	s0,16(sp)
    800034b6:	64a2                	ld	s1,8(sp)
    800034b8:	6105                	addi	sp,sp,32
    800034ba:	8082                	ret
    return p->trapframe->a1;
    800034bc:	6d3c                	ld	a5,88(a0)
    800034be:	7fa8                	ld	a0,120(a5)
    800034c0:	bfcd                	j	800034b2 <argraw+0x30>
    return p->trapframe->a2;
    800034c2:	6d3c                	ld	a5,88(a0)
    800034c4:	63c8                	ld	a0,128(a5)
    800034c6:	b7f5                	j	800034b2 <argraw+0x30>
    return p->trapframe->a3;
    800034c8:	6d3c                	ld	a5,88(a0)
    800034ca:	67c8                	ld	a0,136(a5)
    800034cc:	b7dd                	j	800034b2 <argraw+0x30>
    return p->trapframe->a4;
    800034ce:	6d3c                	ld	a5,88(a0)
    800034d0:	6bc8                	ld	a0,144(a5)
    800034d2:	b7c5                	j	800034b2 <argraw+0x30>
    return p->trapframe->a5;
    800034d4:	6d3c                	ld	a5,88(a0)
    800034d6:	6fc8                	ld	a0,152(a5)
    800034d8:	bfe9                	j	800034b2 <argraw+0x30>
  panic("argraw");
    800034da:	00006517          	auipc	a0,0x6
    800034de:	3c650513          	addi	a0,a0,966 # 800098a0 <states.0+0x1d8>
    800034e2:	ffffd097          	auipc	ra,0xffffd
    800034e6:	048080e7          	jalr	72(ra) # 8000052a <panic>

00000000800034ea <fetchaddr>:
{
    800034ea:	1101                	addi	sp,sp,-32
    800034ec:	ec06                	sd	ra,24(sp)
    800034ee:	e822                	sd	s0,16(sp)
    800034f0:	e426                	sd	s1,8(sp)
    800034f2:	e04a                	sd	s2,0(sp)
    800034f4:	1000                	addi	s0,sp,32
    800034f6:	84aa                	mv	s1,a0
    800034f8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800034fa:	fffff097          	auipc	ra,0xfffff
    800034fe:	838080e7          	jalr	-1992(ra) # 80001d32 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003502:	653c                	ld	a5,72(a0)
    80003504:	02f4f863          	bgeu	s1,a5,80003534 <fetchaddr+0x4a>
    80003508:	00848713          	addi	a4,s1,8
    8000350c:	02e7e663          	bltu	a5,a4,80003538 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003510:	46a1                	li	a3,8
    80003512:	8626                	mv	a2,s1
    80003514:	85ca                	mv	a1,s2
    80003516:	6928                	ld	a0,80(a0)
    80003518:	ffffe097          	auipc	ra,0xffffe
    8000351c:	f20080e7          	jalr	-224(ra) # 80001438 <copyin>
    80003520:	00a03533          	snez	a0,a0
    80003524:	40a00533          	neg	a0,a0
}
    80003528:	60e2                	ld	ra,24(sp)
    8000352a:	6442                	ld	s0,16(sp)
    8000352c:	64a2                	ld	s1,8(sp)
    8000352e:	6902                	ld	s2,0(sp)
    80003530:	6105                	addi	sp,sp,32
    80003532:	8082                	ret
    return -1;
    80003534:	557d                	li	a0,-1
    80003536:	bfcd                	j	80003528 <fetchaddr+0x3e>
    80003538:	557d                	li	a0,-1
    8000353a:	b7fd                	j	80003528 <fetchaddr+0x3e>

000000008000353c <fetchstr>:
{
    8000353c:	7179                	addi	sp,sp,-48
    8000353e:	f406                	sd	ra,40(sp)
    80003540:	f022                	sd	s0,32(sp)
    80003542:	ec26                	sd	s1,24(sp)
    80003544:	e84a                	sd	s2,16(sp)
    80003546:	e44e                	sd	s3,8(sp)
    80003548:	1800                	addi	s0,sp,48
    8000354a:	892a                	mv	s2,a0
    8000354c:	84ae                	mv	s1,a1
    8000354e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003550:	ffffe097          	auipc	ra,0xffffe
    80003554:	7e2080e7          	jalr	2018(ra) # 80001d32 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003558:	86ce                	mv	a3,s3
    8000355a:	864a                	mv	a2,s2
    8000355c:	85a6                	mv	a1,s1
    8000355e:	6928                	ld	a0,80(a0)
    80003560:	ffffe097          	auipc	ra,0xffffe
    80003564:	f68080e7          	jalr	-152(ra) # 800014c8 <copyinstr>
  if(err < 0)
    80003568:	00054763          	bltz	a0,80003576 <fetchstr+0x3a>
  return strlen(buf);
    8000356c:	8526                	mv	a0,s1
    8000356e:	ffffe097          	auipc	ra,0xffffe
    80003572:	8d4080e7          	jalr	-1836(ra) # 80000e42 <strlen>
}
    80003576:	70a2                	ld	ra,40(sp)
    80003578:	7402                	ld	s0,32(sp)
    8000357a:	64e2                	ld	s1,24(sp)
    8000357c:	6942                	ld	s2,16(sp)
    8000357e:	69a2                	ld	s3,8(sp)
    80003580:	6145                	addi	sp,sp,48
    80003582:	8082                	ret

0000000080003584 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003584:	1101                	addi	sp,sp,-32
    80003586:	ec06                	sd	ra,24(sp)
    80003588:	e822                	sd	s0,16(sp)
    8000358a:	e426                	sd	s1,8(sp)
    8000358c:	1000                	addi	s0,sp,32
    8000358e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003590:	00000097          	auipc	ra,0x0
    80003594:	ef2080e7          	jalr	-270(ra) # 80003482 <argraw>
    80003598:	c088                	sw	a0,0(s1)
  return 0;
}
    8000359a:	4501                	li	a0,0
    8000359c:	60e2                	ld	ra,24(sp)
    8000359e:	6442                	ld	s0,16(sp)
    800035a0:	64a2                	ld	s1,8(sp)
    800035a2:	6105                	addi	sp,sp,32
    800035a4:	8082                	ret

00000000800035a6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800035a6:	1101                	addi	sp,sp,-32
    800035a8:	ec06                	sd	ra,24(sp)
    800035aa:	e822                	sd	s0,16(sp)
    800035ac:	e426                	sd	s1,8(sp)
    800035ae:	1000                	addi	s0,sp,32
    800035b0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800035b2:	00000097          	auipc	ra,0x0
    800035b6:	ed0080e7          	jalr	-304(ra) # 80003482 <argraw>
    800035ba:	e088                	sd	a0,0(s1)
  return 0;
}
    800035bc:	4501                	li	a0,0
    800035be:	60e2                	ld	ra,24(sp)
    800035c0:	6442                	ld	s0,16(sp)
    800035c2:	64a2                	ld	s1,8(sp)
    800035c4:	6105                	addi	sp,sp,32
    800035c6:	8082                	ret

00000000800035c8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800035c8:	1101                	addi	sp,sp,-32
    800035ca:	ec06                	sd	ra,24(sp)
    800035cc:	e822                	sd	s0,16(sp)
    800035ce:	e426                	sd	s1,8(sp)
    800035d0:	e04a                	sd	s2,0(sp)
    800035d2:	1000                	addi	s0,sp,32
    800035d4:	84ae                	mv	s1,a1
    800035d6:	8932                	mv	s2,a2
  *ip = argraw(n);
    800035d8:	00000097          	auipc	ra,0x0
    800035dc:	eaa080e7          	jalr	-342(ra) # 80003482 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    800035e0:	864a                	mv	a2,s2
    800035e2:	85a6                	mv	a1,s1
    800035e4:	00000097          	auipc	ra,0x0
    800035e8:	f58080e7          	jalr	-168(ra) # 8000353c <fetchstr>
}
    800035ec:	60e2                	ld	ra,24(sp)
    800035ee:	6442                	ld	s0,16(sp)
    800035f0:	64a2                	ld	s1,8(sp)
    800035f2:	6902                	ld	s2,0(sp)
    800035f4:	6105                	addi	sp,sp,32
    800035f6:	8082                	ret

00000000800035f8 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    800035f8:	1101                	addi	sp,sp,-32
    800035fa:	ec06                	sd	ra,24(sp)
    800035fc:	e822                	sd	s0,16(sp)
    800035fe:	e426                	sd	s1,8(sp)
    80003600:	e04a                	sd	s2,0(sp)
    80003602:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003604:	ffffe097          	auipc	ra,0xffffe
    80003608:	72e080e7          	jalr	1838(ra) # 80001d32 <myproc>
    8000360c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000360e:	05853903          	ld	s2,88(a0)
    80003612:	0a893783          	ld	a5,168(s2)
    80003616:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000361a:	37fd                	addiw	a5,a5,-1
    8000361c:	4751                	li	a4,20
    8000361e:	00f76f63          	bltu	a4,a5,8000363c <syscall+0x44>
    80003622:	00369713          	slli	a4,a3,0x3
    80003626:	00006797          	auipc	a5,0x6
    8000362a:	2ba78793          	addi	a5,a5,698 # 800098e0 <syscalls>
    8000362e:	97ba                	add	a5,a5,a4
    80003630:	639c                	ld	a5,0(a5)
    80003632:	c789                	beqz	a5,8000363c <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80003634:	9782                	jalr	a5
    80003636:	06a93823          	sd	a0,112(s2)
    8000363a:	a839                	j	80003658 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000363c:	15848613          	addi	a2,s1,344
    80003640:	588c                	lw	a1,48(s1)
    80003642:	00006517          	auipc	a0,0x6
    80003646:	26650513          	addi	a0,a0,614 # 800098a8 <states.0+0x1e0>
    8000364a:	ffffd097          	auipc	ra,0xffffd
    8000364e:	f2a080e7          	jalr	-214(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003652:	6cbc                	ld	a5,88(s1)
    80003654:	577d                	li	a4,-1
    80003656:	fbb8                	sd	a4,112(a5)
  }
}
    80003658:	60e2                	ld	ra,24(sp)
    8000365a:	6442                	ld	s0,16(sp)
    8000365c:	64a2                	ld	s1,8(sp)
    8000365e:	6902                	ld	s2,0(sp)
    80003660:	6105                	addi	sp,sp,32
    80003662:	8082                	ret

0000000080003664 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003664:	1101                	addi	sp,sp,-32
    80003666:	ec06                	sd	ra,24(sp)
    80003668:	e822                	sd	s0,16(sp)
    8000366a:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    8000366c:	fec40593          	addi	a1,s0,-20
    80003670:	4501                	li	a0,0
    80003672:	00000097          	auipc	ra,0x0
    80003676:	f12080e7          	jalr	-238(ra) # 80003584 <argint>
    return -1;
    8000367a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000367c:	00054963          	bltz	a0,8000368e <sys_exit+0x2a>
  exit(n);
    80003680:	fec42503          	lw	a0,-20(s0)
    80003684:	fffff097          	auipc	ra,0xfffff
    80003688:	e02080e7          	jalr	-510(ra) # 80002486 <exit>
  return 0;  // not reached
    8000368c:	4781                	li	a5,0
}
    8000368e:	853e                	mv	a0,a5
    80003690:	60e2                	ld	ra,24(sp)
    80003692:	6442                	ld	s0,16(sp)
    80003694:	6105                	addi	sp,sp,32
    80003696:	8082                	ret

0000000080003698 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003698:	1141                	addi	sp,sp,-16
    8000369a:	e406                	sd	ra,8(sp)
    8000369c:	e022                	sd	s0,0(sp)
    8000369e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800036a0:	ffffe097          	auipc	ra,0xffffe
    800036a4:	692080e7          	jalr	1682(ra) # 80001d32 <myproc>
}
    800036a8:	5908                	lw	a0,48(a0)
    800036aa:	60a2                	ld	ra,8(sp)
    800036ac:	6402                	ld	s0,0(sp)
    800036ae:	0141                	addi	sp,sp,16
    800036b0:	8082                	ret

00000000800036b2 <sys_fork>:

uint64
sys_fork(void)
{
    800036b2:	1141                	addi	sp,sp,-16
    800036b4:	e406                	sd	ra,8(sp)
    800036b6:	e022                	sd	s0,0(sp)
    800036b8:	0800                	addi	s0,sp,16
  return fork();
    800036ba:	fffff097          	auipc	ra,0xfffff
    800036be:	358080e7          	jalr	856(ra) # 80002a12 <fork>
}
    800036c2:	60a2                	ld	ra,8(sp)
    800036c4:	6402                	ld	s0,0(sp)
    800036c6:	0141                	addi	sp,sp,16
    800036c8:	8082                	ret

00000000800036ca <sys_wait>:

uint64
sys_wait(void)
{
    800036ca:	1101                	addi	sp,sp,-32
    800036cc:	ec06                	sd	ra,24(sp)
    800036ce:	e822                	sd	s0,16(sp)
    800036d0:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    800036d2:	fe840593          	addi	a1,s0,-24
    800036d6:	4501                	li	a0,0
    800036d8:	00000097          	auipc	ra,0x0
    800036dc:	ece080e7          	jalr	-306(ra) # 800035a6 <argaddr>
    800036e0:	87aa                	mv	a5,a0
    return -1;
    800036e2:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800036e4:	0007c863          	bltz	a5,800036f4 <sys_wait+0x2a>
  return wait(p);
    800036e8:	fe843503          	ld	a0,-24(s0)
    800036ec:	fffff097          	auipc	ra,0xfffff
    800036f0:	ba2080e7          	jalr	-1118(ra) # 8000228e <wait>
}
    800036f4:	60e2                	ld	ra,24(sp)
    800036f6:	6442                	ld	s0,16(sp)
    800036f8:	6105                	addi	sp,sp,32
    800036fa:	8082                	ret

00000000800036fc <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800036fc:	7179                	addi	sp,sp,-48
    800036fe:	f406                	sd	ra,40(sp)
    80003700:	f022                	sd	s0,32(sp)
    80003702:	ec26                	sd	s1,24(sp)
    80003704:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003706:	fdc40593          	addi	a1,s0,-36
    8000370a:	4501                	li	a0,0
    8000370c:	00000097          	auipc	ra,0x0
    80003710:	e78080e7          	jalr	-392(ra) # 80003584 <argint>
    return -1;
    80003714:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003716:	00054f63          	bltz	a0,80003734 <sys_sbrk+0x38>
  addr = myproc()->sz;
    8000371a:	ffffe097          	auipc	ra,0xffffe
    8000371e:	618080e7          	jalr	1560(ra) # 80001d32 <myproc>
    80003722:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80003724:	fdc42503          	lw	a0,-36(s0)
    80003728:	fffff097          	auipc	ra,0xfffff
    8000372c:	97c080e7          	jalr	-1668(ra) # 800020a4 <growproc>
    80003730:	00054863          	bltz	a0,80003740 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003734:	8526                	mv	a0,s1
    80003736:	70a2                	ld	ra,40(sp)
    80003738:	7402                	ld	s0,32(sp)
    8000373a:	64e2                	ld	s1,24(sp)
    8000373c:	6145                	addi	sp,sp,48
    8000373e:	8082                	ret
    return -1;
    80003740:	54fd                	li	s1,-1
    80003742:	bfcd                	j	80003734 <sys_sbrk+0x38>

0000000080003744 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003744:	7139                	addi	sp,sp,-64
    80003746:	fc06                	sd	ra,56(sp)
    80003748:	f822                	sd	s0,48(sp)
    8000374a:	f426                	sd	s1,40(sp)
    8000374c:	f04a                	sd	s2,32(sp)
    8000374e:	ec4e                	sd	s3,24(sp)
    80003750:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003752:	fcc40593          	addi	a1,s0,-52
    80003756:	4501                	li	a0,0
    80003758:	00000097          	auipc	ra,0x0
    8000375c:	e2c080e7          	jalr	-468(ra) # 80003584 <argint>
    return -1;
    80003760:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003762:	06054563          	bltz	a0,800037cc <sys_sleep+0x88>
  acquire(&tickslock);
    80003766:	00021517          	auipc	a0,0x21
    8000376a:	36a50513          	addi	a0,a0,874 # 80024ad0 <tickslock>
    8000376e:	ffffd097          	auipc	ra,0xffffd
    80003772:	454080e7          	jalr	1108(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    80003776:	00007917          	auipc	s2,0x7
    8000377a:	8ba92903          	lw	s2,-1862(s2) # 8000a030 <ticks>
  while(ticks - ticks0 < n){
    8000377e:	fcc42783          	lw	a5,-52(s0)
    80003782:	cf85                	beqz	a5,800037ba <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003784:	00021997          	auipc	s3,0x21
    80003788:	34c98993          	addi	s3,s3,844 # 80024ad0 <tickslock>
    8000378c:	00007497          	auipc	s1,0x7
    80003790:	8a448493          	addi	s1,s1,-1884 # 8000a030 <ticks>
    if(myproc()->killed){
    80003794:	ffffe097          	auipc	ra,0xffffe
    80003798:	59e080e7          	jalr	1438(ra) # 80001d32 <myproc>
    8000379c:	551c                	lw	a5,40(a0)
    8000379e:	ef9d                	bnez	a5,800037dc <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    800037a0:	85ce                	mv	a1,s3
    800037a2:	8526                	mv	a0,s1
    800037a4:	fffff097          	auipc	ra,0xfffff
    800037a8:	a86080e7          	jalr	-1402(ra) # 8000222a <sleep>
  while(ticks - ticks0 < n){
    800037ac:	409c                	lw	a5,0(s1)
    800037ae:	412787bb          	subw	a5,a5,s2
    800037b2:	fcc42703          	lw	a4,-52(s0)
    800037b6:	fce7efe3          	bltu	a5,a4,80003794 <sys_sleep+0x50>
  }
  release(&tickslock);
    800037ba:	00021517          	auipc	a0,0x21
    800037be:	31650513          	addi	a0,a0,790 # 80024ad0 <tickslock>
    800037c2:	ffffd097          	auipc	ra,0xffffd
    800037c6:	4b4080e7          	jalr	1204(ra) # 80000c76 <release>
  return 0;
    800037ca:	4781                	li	a5,0
}
    800037cc:	853e                	mv	a0,a5
    800037ce:	70e2                	ld	ra,56(sp)
    800037d0:	7442                	ld	s0,48(sp)
    800037d2:	74a2                	ld	s1,40(sp)
    800037d4:	7902                	ld	s2,32(sp)
    800037d6:	69e2                	ld	s3,24(sp)
    800037d8:	6121                	addi	sp,sp,64
    800037da:	8082                	ret
      release(&tickslock);
    800037dc:	00021517          	auipc	a0,0x21
    800037e0:	2f450513          	addi	a0,a0,756 # 80024ad0 <tickslock>
    800037e4:	ffffd097          	auipc	ra,0xffffd
    800037e8:	492080e7          	jalr	1170(ra) # 80000c76 <release>
      return -1;
    800037ec:	57fd                	li	a5,-1
    800037ee:	bff9                	j	800037cc <sys_sleep+0x88>

00000000800037f0 <sys_kill>:

uint64
sys_kill(void)
{
    800037f0:	1101                	addi	sp,sp,-32
    800037f2:	ec06                	sd	ra,24(sp)
    800037f4:	e822                	sd	s0,16(sp)
    800037f6:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800037f8:	fec40593          	addi	a1,s0,-20
    800037fc:	4501                	li	a0,0
    800037fe:	00000097          	auipc	ra,0x0
    80003802:	d86080e7          	jalr	-634(ra) # 80003584 <argint>
    80003806:	87aa                	mv	a5,a0
    return -1;
    80003808:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000380a:	0007c863          	bltz	a5,8000381a <sys_kill+0x2a>
  return kill(pid);
    8000380e:	fec42503          	lw	a0,-20(s0)
    80003812:	fffff097          	auipc	ra,0xfffff
    80003816:	d54080e7          	jalr	-684(ra) # 80002566 <kill>
}
    8000381a:	60e2                	ld	ra,24(sp)
    8000381c:	6442                	ld	s0,16(sp)
    8000381e:	6105                	addi	sp,sp,32
    80003820:	8082                	ret

0000000080003822 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003822:	1101                	addi	sp,sp,-32
    80003824:	ec06                	sd	ra,24(sp)
    80003826:	e822                	sd	s0,16(sp)
    80003828:	e426                	sd	s1,8(sp)
    8000382a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000382c:	00021517          	auipc	a0,0x21
    80003830:	2a450513          	addi	a0,a0,676 # 80024ad0 <tickslock>
    80003834:	ffffd097          	auipc	ra,0xffffd
    80003838:	38e080e7          	jalr	910(ra) # 80000bc2 <acquire>
  xticks = ticks;
    8000383c:	00006497          	auipc	s1,0x6
    80003840:	7f44a483          	lw	s1,2036(s1) # 8000a030 <ticks>
  release(&tickslock);
    80003844:	00021517          	auipc	a0,0x21
    80003848:	28c50513          	addi	a0,a0,652 # 80024ad0 <tickslock>
    8000384c:	ffffd097          	auipc	ra,0xffffd
    80003850:	42a080e7          	jalr	1066(ra) # 80000c76 <release>
  return xticks;
}
    80003854:	02049513          	slli	a0,s1,0x20
    80003858:	9101                	srli	a0,a0,0x20
    8000385a:	60e2                	ld	ra,24(sp)
    8000385c:	6442                	ld	s0,16(sp)
    8000385e:	64a2                	ld	s1,8(sp)
    80003860:	6105                	addi	sp,sp,32
    80003862:	8082                	ret

0000000080003864 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003864:	7179                	addi	sp,sp,-48
    80003866:	f406                	sd	ra,40(sp)
    80003868:	f022                	sd	s0,32(sp)
    8000386a:	ec26                	sd	s1,24(sp)
    8000386c:	e84a                	sd	s2,16(sp)
    8000386e:	e44e                	sd	s3,8(sp)
    80003870:	e052                	sd	s4,0(sp)
    80003872:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003874:	00006597          	auipc	a1,0x6
    80003878:	11c58593          	addi	a1,a1,284 # 80009990 <syscalls+0xb0>
    8000387c:	00021517          	auipc	a0,0x21
    80003880:	26c50513          	addi	a0,a0,620 # 80024ae8 <bcache>
    80003884:	ffffd097          	auipc	ra,0xffffd
    80003888:	2ae080e7          	jalr	686(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000388c:	00029797          	auipc	a5,0x29
    80003890:	25c78793          	addi	a5,a5,604 # 8002cae8 <bcache+0x8000>
    80003894:	00029717          	auipc	a4,0x29
    80003898:	4bc70713          	addi	a4,a4,1212 # 8002cd50 <bcache+0x8268>
    8000389c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800038a0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800038a4:	00021497          	auipc	s1,0x21
    800038a8:	25c48493          	addi	s1,s1,604 # 80024b00 <bcache+0x18>
    b->next = bcache.head.next;
    800038ac:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800038ae:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800038b0:	00006a17          	auipc	s4,0x6
    800038b4:	0e8a0a13          	addi	s4,s4,232 # 80009998 <syscalls+0xb8>
    b->next = bcache.head.next;
    800038b8:	2b893783          	ld	a5,696(s2)
    800038bc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800038be:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800038c2:	85d2                	mv	a1,s4
    800038c4:	01048513          	addi	a0,s1,16
    800038c8:	00001097          	auipc	ra,0x1
    800038cc:	7d4080e7          	jalr	2004(ra) # 8000509c <initsleeplock>
    bcache.head.next->prev = b;
    800038d0:	2b893783          	ld	a5,696(s2)
    800038d4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800038d6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800038da:	45848493          	addi	s1,s1,1112
    800038de:	fd349de3          	bne	s1,s3,800038b8 <binit+0x54>
  }
}
    800038e2:	70a2                	ld	ra,40(sp)
    800038e4:	7402                	ld	s0,32(sp)
    800038e6:	64e2                	ld	s1,24(sp)
    800038e8:	6942                	ld	s2,16(sp)
    800038ea:	69a2                	ld	s3,8(sp)
    800038ec:	6a02                	ld	s4,0(sp)
    800038ee:	6145                	addi	sp,sp,48
    800038f0:	8082                	ret

00000000800038f2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800038f2:	7179                	addi	sp,sp,-48
    800038f4:	f406                	sd	ra,40(sp)
    800038f6:	f022                	sd	s0,32(sp)
    800038f8:	ec26                	sd	s1,24(sp)
    800038fa:	e84a                	sd	s2,16(sp)
    800038fc:	e44e                	sd	s3,8(sp)
    800038fe:	1800                	addi	s0,sp,48
    80003900:	892a                	mv	s2,a0
    80003902:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003904:	00021517          	auipc	a0,0x21
    80003908:	1e450513          	addi	a0,a0,484 # 80024ae8 <bcache>
    8000390c:	ffffd097          	auipc	ra,0xffffd
    80003910:	2b6080e7          	jalr	694(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003914:	00029497          	auipc	s1,0x29
    80003918:	48c4b483          	ld	s1,1164(s1) # 8002cda0 <bcache+0x82b8>
    8000391c:	00029797          	auipc	a5,0x29
    80003920:	43478793          	addi	a5,a5,1076 # 8002cd50 <bcache+0x8268>
    80003924:	02f48f63          	beq	s1,a5,80003962 <bread+0x70>
    80003928:	873e                	mv	a4,a5
    8000392a:	a021                	j	80003932 <bread+0x40>
    8000392c:	68a4                	ld	s1,80(s1)
    8000392e:	02e48a63          	beq	s1,a4,80003962 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003932:	449c                	lw	a5,8(s1)
    80003934:	ff279ce3          	bne	a5,s2,8000392c <bread+0x3a>
    80003938:	44dc                	lw	a5,12(s1)
    8000393a:	ff3799e3          	bne	a5,s3,8000392c <bread+0x3a>
      b->refcnt++;
    8000393e:	40bc                	lw	a5,64(s1)
    80003940:	2785                	addiw	a5,a5,1
    80003942:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003944:	00021517          	auipc	a0,0x21
    80003948:	1a450513          	addi	a0,a0,420 # 80024ae8 <bcache>
    8000394c:	ffffd097          	auipc	ra,0xffffd
    80003950:	32a080e7          	jalr	810(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003954:	01048513          	addi	a0,s1,16
    80003958:	00001097          	auipc	ra,0x1
    8000395c:	77e080e7          	jalr	1918(ra) # 800050d6 <acquiresleep>
      return b;
    80003960:	a8b9                	j	800039be <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003962:	00029497          	auipc	s1,0x29
    80003966:	4364b483          	ld	s1,1078(s1) # 8002cd98 <bcache+0x82b0>
    8000396a:	00029797          	auipc	a5,0x29
    8000396e:	3e678793          	addi	a5,a5,998 # 8002cd50 <bcache+0x8268>
    80003972:	00f48863          	beq	s1,a5,80003982 <bread+0x90>
    80003976:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003978:	40bc                	lw	a5,64(s1)
    8000397a:	cf81                	beqz	a5,80003992 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000397c:	64a4                	ld	s1,72(s1)
    8000397e:	fee49de3          	bne	s1,a4,80003978 <bread+0x86>
  panic("bget: no buffers");
    80003982:	00006517          	auipc	a0,0x6
    80003986:	01e50513          	addi	a0,a0,30 # 800099a0 <syscalls+0xc0>
    8000398a:	ffffd097          	auipc	ra,0xffffd
    8000398e:	ba0080e7          	jalr	-1120(ra) # 8000052a <panic>
      b->dev = dev;
    80003992:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003996:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000399a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000399e:	4785                	li	a5,1
    800039a0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800039a2:	00021517          	auipc	a0,0x21
    800039a6:	14650513          	addi	a0,a0,326 # 80024ae8 <bcache>
    800039aa:	ffffd097          	auipc	ra,0xffffd
    800039ae:	2cc080e7          	jalr	716(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    800039b2:	01048513          	addi	a0,s1,16
    800039b6:	00001097          	auipc	ra,0x1
    800039ba:	720080e7          	jalr	1824(ra) # 800050d6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800039be:	409c                	lw	a5,0(s1)
    800039c0:	cb89                	beqz	a5,800039d2 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800039c2:	8526                	mv	a0,s1
    800039c4:	70a2                	ld	ra,40(sp)
    800039c6:	7402                	ld	s0,32(sp)
    800039c8:	64e2                	ld	s1,24(sp)
    800039ca:	6942                	ld	s2,16(sp)
    800039cc:	69a2                	ld	s3,8(sp)
    800039ce:	6145                	addi	sp,sp,48
    800039d0:	8082                	ret
    virtio_disk_rw(b, 0);
    800039d2:	4581                	li	a1,0
    800039d4:	8526                	mv	a0,s1
    800039d6:	00003097          	auipc	ra,0x3
    800039da:	460080e7          	jalr	1120(ra) # 80006e36 <virtio_disk_rw>
    b->valid = 1;
    800039de:	4785                	li	a5,1
    800039e0:	c09c                	sw	a5,0(s1)
  return b;
    800039e2:	b7c5                	j	800039c2 <bread+0xd0>

00000000800039e4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800039e4:	1101                	addi	sp,sp,-32
    800039e6:	ec06                	sd	ra,24(sp)
    800039e8:	e822                	sd	s0,16(sp)
    800039ea:	e426                	sd	s1,8(sp)
    800039ec:	1000                	addi	s0,sp,32
    800039ee:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800039f0:	0541                	addi	a0,a0,16
    800039f2:	00001097          	auipc	ra,0x1
    800039f6:	77e080e7          	jalr	1918(ra) # 80005170 <holdingsleep>
    800039fa:	cd01                	beqz	a0,80003a12 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800039fc:	4585                	li	a1,1
    800039fe:	8526                	mv	a0,s1
    80003a00:	00003097          	auipc	ra,0x3
    80003a04:	436080e7          	jalr	1078(ra) # 80006e36 <virtio_disk_rw>
}
    80003a08:	60e2                	ld	ra,24(sp)
    80003a0a:	6442                	ld	s0,16(sp)
    80003a0c:	64a2                	ld	s1,8(sp)
    80003a0e:	6105                	addi	sp,sp,32
    80003a10:	8082                	ret
    panic("bwrite");
    80003a12:	00006517          	auipc	a0,0x6
    80003a16:	fa650513          	addi	a0,a0,-90 # 800099b8 <syscalls+0xd8>
    80003a1a:	ffffd097          	auipc	ra,0xffffd
    80003a1e:	b10080e7          	jalr	-1264(ra) # 8000052a <panic>

0000000080003a22 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003a22:	1101                	addi	sp,sp,-32
    80003a24:	ec06                	sd	ra,24(sp)
    80003a26:	e822                	sd	s0,16(sp)
    80003a28:	e426                	sd	s1,8(sp)
    80003a2a:	e04a                	sd	s2,0(sp)
    80003a2c:	1000                	addi	s0,sp,32
    80003a2e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003a30:	01050913          	addi	s2,a0,16
    80003a34:	854a                	mv	a0,s2
    80003a36:	00001097          	auipc	ra,0x1
    80003a3a:	73a080e7          	jalr	1850(ra) # 80005170 <holdingsleep>
    80003a3e:	c92d                	beqz	a0,80003ab0 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003a40:	854a                	mv	a0,s2
    80003a42:	00001097          	auipc	ra,0x1
    80003a46:	6ea080e7          	jalr	1770(ra) # 8000512c <releasesleep>

  acquire(&bcache.lock);
    80003a4a:	00021517          	auipc	a0,0x21
    80003a4e:	09e50513          	addi	a0,a0,158 # 80024ae8 <bcache>
    80003a52:	ffffd097          	auipc	ra,0xffffd
    80003a56:	170080e7          	jalr	368(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003a5a:	40bc                	lw	a5,64(s1)
    80003a5c:	37fd                	addiw	a5,a5,-1
    80003a5e:	0007871b          	sext.w	a4,a5
    80003a62:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003a64:	eb05                	bnez	a4,80003a94 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003a66:	68bc                	ld	a5,80(s1)
    80003a68:	64b8                	ld	a4,72(s1)
    80003a6a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003a6c:	64bc                	ld	a5,72(s1)
    80003a6e:	68b8                	ld	a4,80(s1)
    80003a70:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003a72:	00029797          	auipc	a5,0x29
    80003a76:	07678793          	addi	a5,a5,118 # 8002cae8 <bcache+0x8000>
    80003a7a:	2b87b703          	ld	a4,696(a5)
    80003a7e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003a80:	00029717          	auipc	a4,0x29
    80003a84:	2d070713          	addi	a4,a4,720 # 8002cd50 <bcache+0x8268>
    80003a88:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003a8a:	2b87b703          	ld	a4,696(a5)
    80003a8e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003a90:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003a94:	00021517          	auipc	a0,0x21
    80003a98:	05450513          	addi	a0,a0,84 # 80024ae8 <bcache>
    80003a9c:	ffffd097          	auipc	ra,0xffffd
    80003aa0:	1da080e7          	jalr	474(ra) # 80000c76 <release>
}
    80003aa4:	60e2                	ld	ra,24(sp)
    80003aa6:	6442                	ld	s0,16(sp)
    80003aa8:	64a2                	ld	s1,8(sp)
    80003aaa:	6902                	ld	s2,0(sp)
    80003aac:	6105                	addi	sp,sp,32
    80003aae:	8082                	ret
    panic("brelse");
    80003ab0:	00006517          	auipc	a0,0x6
    80003ab4:	f1050513          	addi	a0,a0,-240 # 800099c0 <syscalls+0xe0>
    80003ab8:	ffffd097          	auipc	ra,0xffffd
    80003abc:	a72080e7          	jalr	-1422(ra) # 8000052a <panic>

0000000080003ac0 <bpin>:

void
bpin(struct buf *b) {
    80003ac0:	1101                	addi	sp,sp,-32
    80003ac2:	ec06                	sd	ra,24(sp)
    80003ac4:	e822                	sd	s0,16(sp)
    80003ac6:	e426                	sd	s1,8(sp)
    80003ac8:	1000                	addi	s0,sp,32
    80003aca:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003acc:	00021517          	auipc	a0,0x21
    80003ad0:	01c50513          	addi	a0,a0,28 # 80024ae8 <bcache>
    80003ad4:	ffffd097          	auipc	ra,0xffffd
    80003ad8:	0ee080e7          	jalr	238(ra) # 80000bc2 <acquire>
  b->refcnt++;
    80003adc:	40bc                	lw	a5,64(s1)
    80003ade:	2785                	addiw	a5,a5,1
    80003ae0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003ae2:	00021517          	auipc	a0,0x21
    80003ae6:	00650513          	addi	a0,a0,6 # 80024ae8 <bcache>
    80003aea:	ffffd097          	auipc	ra,0xffffd
    80003aee:	18c080e7          	jalr	396(ra) # 80000c76 <release>
}
    80003af2:	60e2                	ld	ra,24(sp)
    80003af4:	6442                	ld	s0,16(sp)
    80003af6:	64a2                	ld	s1,8(sp)
    80003af8:	6105                	addi	sp,sp,32
    80003afa:	8082                	ret

0000000080003afc <bunpin>:

void
bunpin(struct buf *b) {
    80003afc:	1101                	addi	sp,sp,-32
    80003afe:	ec06                	sd	ra,24(sp)
    80003b00:	e822                	sd	s0,16(sp)
    80003b02:	e426                	sd	s1,8(sp)
    80003b04:	1000                	addi	s0,sp,32
    80003b06:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003b08:	00021517          	auipc	a0,0x21
    80003b0c:	fe050513          	addi	a0,a0,-32 # 80024ae8 <bcache>
    80003b10:	ffffd097          	auipc	ra,0xffffd
    80003b14:	0b2080e7          	jalr	178(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003b18:	40bc                	lw	a5,64(s1)
    80003b1a:	37fd                	addiw	a5,a5,-1
    80003b1c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003b1e:	00021517          	auipc	a0,0x21
    80003b22:	fca50513          	addi	a0,a0,-54 # 80024ae8 <bcache>
    80003b26:	ffffd097          	auipc	ra,0xffffd
    80003b2a:	150080e7          	jalr	336(ra) # 80000c76 <release>
}
    80003b2e:	60e2                	ld	ra,24(sp)
    80003b30:	6442                	ld	s0,16(sp)
    80003b32:	64a2                	ld	s1,8(sp)
    80003b34:	6105                	addi	sp,sp,32
    80003b36:	8082                	ret

0000000080003b38 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003b38:	1101                	addi	sp,sp,-32
    80003b3a:	ec06                	sd	ra,24(sp)
    80003b3c:	e822                	sd	s0,16(sp)
    80003b3e:	e426                	sd	s1,8(sp)
    80003b40:	e04a                	sd	s2,0(sp)
    80003b42:	1000                	addi	s0,sp,32
    80003b44:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003b46:	00d5d59b          	srliw	a1,a1,0xd
    80003b4a:	00029797          	auipc	a5,0x29
    80003b4e:	67a7a783          	lw	a5,1658(a5) # 8002d1c4 <sb+0x1c>
    80003b52:	9dbd                	addw	a1,a1,a5
    80003b54:	00000097          	auipc	ra,0x0
    80003b58:	d9e080e7          	jalr	-610(ra) # 800038f2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003b5c:	0074f713          	andi	a4,s1,7
    80003b60:	4785                	li	a5,1
    80003b62:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003b66:	14ce                	slli	s1,s1,0x33
    80003b68:	90d9                	srli	s1,s1,0x36
    80003b6a:	00950733          	add	a4,a0,s1
    80003b6e:	05874703          	lbu	a4,88(a4)
    80003b72:	00e7f6b3          	and	a3,a5,a4
    80003b76:	c69d                	beqz	a3,80003ba4 <bfree+0x6c>
    80003b78:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003b7a:	94aa                	add	s1,s1,a0
    80003b7c:	fff7c793          	not	a5,a5
    80003b80:	8ff9                	and	a5,a5,a4
    80003b82:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003b86:	00001097          	auipc	ra,0x1
    80003b8a:	430080e7          	jalr	1072(ra) # 80004fb6 <log_write>
  brelse(bp);
    80003b8e:	854a                	mv	a0,s2
    80003b90:	00000097          	auipc	ra,0x0
    80003b94:	e92080e7          	jalr	-366(ra) # 80003a22 <brelse>
}
    80003b98:	60e2                	ld	ra,24(sp)
    80003b9a:	6442                	ld	s0,16(sp)
    80003b9c:	64a2                	ld	s1,8(sp)
    80003b9e:	6902                	ld	s2,0(sp)
    80003ba0:	6105                	addi	sp,sp,32
    80003ba2:	8082                	ret
    panic("freeing free block");
    80003ba4:	00006517          	auipc	a0,0x6
    80003ba8:	e2450513          	addi	a0,a0,-476 # 800099c8 <syscalls+0xe8>
    80003bac:	ffffd097          	auipc	ra,0xffffd
    80003bb0:	97e080e7          	jalr	-1666(ra) # 8000052a <panic>

0000000080003bb4 <balloc>:
{
    80003bb4:	711d                	addi	sp,sp,-96
    80003bb6:	ec86                	sd	ra,88(sp)
    80003bb8:	e8a2                	sd	s0,80(sp)
    80003bba:	e4a6                	sd	s1,72(sp)
    80003bbc:	e0ca                	sd	s2,64(sp)
    80003bbe:	fc4e                	sd	s3,56(sp)
    80003bc0:	f852                	sd	s4,48(sp)
    80003bc2:	f456                	sd	s5,40(sp)
    80003bc4:	f05a                	sd	s6,32(sp)
    80003bc6:	ec5e                	sd	s7,24(sp)
    80003bc8:	e862                	sd	s8,16(sp)
    80003bca:	e466                	sd	s9,8(sp)
    80003bcc:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003bce:	00029797          	auipc	a5,0x29
    80003bd2:	5de7a783          	lw	a5,1502(a5) # 8002d1ac <sb+0x4>
    80003bd6:	cbd1                	beqz	a5,80003c6a <balloc+0xb6>
    80003bd8:	8baa                	mv	s7,a0
    80003bda:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003bdc:	00029b17          	auipc	s6,0x29
    80003be0:	5ccb0b13          	addi	s6,s6,1484 # 8002d1a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003be4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003be6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003be8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003bea:	6c89                	lui	s9,0x2
    80003bec:	a831                	j	80003c08 <balloc+0x54>
    brelse(bp);
    80003bee:	854a                	mv	a0,s2
    80003bf0:	00000097          	auipc	ra,0x0
    80003bf4:	e32080e7          	jalr	-462(ra) # 80003a22 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003bf8:	015c87bb          	addw	a5,s9,s5
    80003bfc:	00078a9b          	sext.w	s5,a5
    80003c00:	004b2703          	lw	a4,4(s6)
    80003c04:	06eaf363          	bgeu	s5,a4,80003c6a <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003c08:	41fad79b          	sraiw	a5,s5,0x1f
    80003c0c:	0137d79b          	srliw	a5,a5,0x13
    80003c10:	015787bb          	addw	a5,a5,s5
    80003c14:	40d7d79b          	sraiw	a5,a5,0xd
    80003c18:	01cb2583          	lw	a1,28(s6)
    80003c1c:	9dbd                	addw	a1,a1,a5
    80003c1e:	855e                	mv	a0,s7
    80003c20:	00000097          	auipc	ra,0x0
    80003c24:	cd2080e7          	jalr	-814(ra) # 800038f2 <bread>
    80003c28:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c2a:	004b2503          	lw	a0,4(s6)
    80003c2e:	000a849b          	sext.w	s1,s5
    80003c32:	8662                	mv	a2,s8
    80003c34:	faa4fde3          	bgeu	s1,a0,80003bee <balloc+0x3a>
      m = 1 << (bi % 8);
    80003c38:	41f6579b          	sraiw	a5,a2,0x1f
    80003c3c:	01d7d69b          	srliw	a3,a5,0x1d
    80003c40:	00c6873b          	addw	a4,a3,a2
    80003c44:	00777793          	andi	a5,a4,7
    80003c48:	9f95                	subw	a5,a5,a3
    80003c4a:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003c4e:	4037571b          	sraiw	a4,a4,0x3
    80003c52:	00e906b3          	add	a3,s2,a4
    80003c56:	0586c683          	lbu	a3,88(a3)
    80003c5a:	00d7f5b3          	and	a1,a5,a3
    80003c5e:	cd91                	beqz	a1,80003c7a <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c60:	2605                	addiw	a2,a2,1
    80003c62:	2485                	addiw	s1,s1,1
    80003c64:	fd4618e3          	bne	a2,s4,80003c34 <balloc+0x80>
    80003c68:	b759                	j	80003bee <balloc+0x3a>
  panic("balloc: out of blocks");
    80003c6a:	00006517          	auipc	a0,0x6
    80003c6e:	d7650513          	addi	a0,a0,-650 # 800099e0 <syscalls+0x100>
    80003c72:	ffffd097          	auipc	ra,0xffffd
    80003c76:	8b8080e7          	jalr	-1864(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003c7a:	974a                	add	a4,a4,s2
    80003c7c:	8fd5                	or	a5,a5,a3
    80003c7e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003c82:	854a                	mv	a0,s2
    80003c84:	00001097          	auipc	ra,0x1
    80003c88:	332080e7          	jalr	818(ra) # 80004fb6 <log_write>
        brelse(bp);
    80003c8c:	854a                	mv	a0,s2
    80003c8e:	00000097          	auipc	ra,0x0
    80003c92:	d94080e7          	jalr	-620(ra) # 80003a22 <brelse>
  bp = bread(dev, bno);
    80003c96:	85a6                	mv	a1,s1
    80003c98:	855e                	mv	a0,s7
    80003c9a:	00000097          	auipc	ra,0x0
    80003c9e:	c58080e7          	jalr	-936(ra) # 800038f2 <bread>
    80003ca2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003ca4:	40000613          	li	a2,1024
    80003ca8:	4581                	li	a1,0
    80003caa:	05850513          	addi	a0,a0,88
    80003cae:	ffffd097          	auipc	ra,0xffffd
    80003cb2:	010080e7          	jalr	16(ra) # 80000cbe <memset>
  log_write(bp);
    80003cb6:	854a                	mv	a0,s2
    80003cb8:	00001097          	auipc	ra,0x1
    80003cbc:	2fe080e7          	jalr	766(ra) # 80004fb6 <log_write>
  brelse(bp);
    80003cc0:	854a                	mv	a0,s2
    80003cc2:	00000097          	auipc	ra,0x0
    80003cc6:	d60080e7          	jalr	-672(ra) # 80003a22 <brelse>
}
    80003cca:	8526                	mv	a0,s1
    80003ccc:	60e6                	ld	ra,88(sp)
    80003cce:	6446                	ld	s0,80(sp)
    80003cd0:	64a6                	ld	s1,72(sp)
    80003cd2:	6906                	ld	s2,64(sp)
    80003cd4:	79e2                	ld	s3,56(sp)
    80003cd6:	7a42                	ld	s4,48(sp)
    80003cd8:	7aa2                	ld	s5,40(sp)
    80003cda:	7b02                	ld	s6,32(sp)
    80003cdc:	6be2                	ld	s7,24(sp)
    80003cde:	6c42                	ld	s8,16(sp)
    80003ce0:	6ca2                	ld	s9,8(sp)
    80003ce2:	6125                	addi	sp,sp,96
    80003ce4:	8082                	ret

0000000080003ce6 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003ce6:	7179                	addi	sp,sp,-48
    80003ce8:	f406                	sd	ra,40(sp)
    80003cea:	f022                	sd	s0,32(sp)
    80003cec:	ec26                	sd	s1,24(sp)
    80003cee:	e84a                	sd	s2,16(sp)
    80003cf0:	e44e                	sd	s3,8(sp)
    80003cf2:	e052                	sd	s4,0(sp)
    80003cf4:	1800                	addi	s0,sp,48
    80003cf6:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003cf8:	47ad                	li	a5,11
    80003cfa:	04b7fe63          	bgeu	a5,a1,80003d56 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003cfe:	ff45849b          	addiw	s1,a1,-12
    80003d02:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003d06:	0ff00793          	li	a5,255
    80003d0a:	0ae7e463          	bltu	a5,a4,80003db2 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003d0e:	08052583          	lw	a1,128(a0)
    80003d12:	c5b5                	beqz	a1,80003d7e <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003d14:	00092503          	lw	a0,0(s2)
    80003d18:	00000097          	auipc	ra,0x0
    80003d1c:	bda080e7          	jalr	-1062(ra) # 800038f2 <bread>
    80003d20:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003d22:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003d26:	02049713          	slli	a4,s1,0x20
    80003d2a:	01e75593          	srli	a1,a4,0x1e
    80003d2e:	00b784b3          	add	s1,a5,a1
    80003d32:	0004a983          	lw	s3,0(s1)
    80003d36:	04098e63          	beqz	s3,80003d92 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003d3a:	8552                	mv	a0,s4
    80003d3c:	00000097          	auipc	ra,0x0
    80003d40:	ce6080e7          	jalr	-794(ra) # 80003a22 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003d44:	854e                	mv	a0,s3
    80003d46:	70a2                	ld	ra,40(sp)
    80003d48:	7402                	ld	s0,32(sp)
    80003d4a:	64e2                	ld	s1,24(sp)
    80003d4c:	6942                	ld	s2,16(sp)
    80003d4e:	69a2                	ld	s3,8(sp)
    80003d50:	6a02                	ld	s4,0(sp)
    80003d52:	6145                	addi	sp,sp,48
    80003d54:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003d56:	02059793          	slli	a5,a1,0x20
    80003d5a:	01e7d593          	srli	a1,a5,0x1e
    80003d5e:	00b504b3          	add	s1,a0,a1
    80003d62:	0504a983          	lw	s3,80(s1)
    80003d66:	fc099fe3          	bnez	s3,80003d44 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003d6a:	4108                	lw	a0,0(a0)
    80003d6c:	00000097          	auipc	ra,0x0
    80003d70:	e48080e7          	jalr	-440(ra) # 80003bb4 <balloc>
    80003d74:	0005099b          	sext.w	s3,a0
    80003d78:	0534a823          	sw	s3,80(s1)
    80003d7c:	b7e1                	j	80003d44 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003d7e:	4108                	lw	a0,0(a0)
    80003d80:	00000097          	auipc	ra,0x0
    80003d84:	e34080e7          	jalr	-460(ra) # 80003bb4 <balloc>
    80003d88:	0005059b          	sext.w	a1,a0
    80003d8c:	08b92023          	sw	a1,128(s2)
    80003d90:	b751                	j	80003d14 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003d92:	00092503          	lw	a0,0(s2)
    80003d96:	00000097          	auipc	ra,0x0
    80003d9a:	e1e080e7          	jalr	-482(ra) # 80003bb4 <balloc>
    80003d9e:	0005099b          	sext.w	s3,a0
    80003da2:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003da6:	8552                	mv	a0,s4
    80003da8:	00001097          	auipc	ra,0x1
    80003dac:	20e080e7          	jalr	526(ra) # 80004fb6 <log_write>
    80003db0:	b769                	j	80003d3a <bmap+0x54>
  panic("bmap: out of range");
    80003db2:	00006517          	auipc	a0,0x6
    80003db6:	c4650513          	addi	a0,a0,-954 # 800099f8 <syscalls+0x118>
    80003dba:	ffffc097          	auipc	ra,0xffffc
    80003dbe:	770080e7          	jalr	1904(ra) # 8000052a <panic>

0000000080003dc2 <iget>:
{
    80003dc2:	7179                	addi	sp,sp,-48
    80003dc4:	f406                	sd	ra,40(sp)
    80003dc6:	f022                	sd	s0,32(sp)
    80003dc8:	ec26                	sd	s1,24(sp)
    80003dca:	e84a                	sd	s2,16(sp)
    80003dcc:	e44e                	sd	s3,8(sp)
    80003dce:	e052                	sd	s4,0(sp)
    80003dd0:	1800                	addi	s0,sp,48
    80003dd2:	89aa                	mv	s3,a0
    80003dd4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003dd6:	00029517          	auipc	a0,0x29
    80003dda:	3f250513          	addi	a0,a0,1010 # 8002d1c8 <itable>
    80003dde:	ffffd097          	auipc	ra,0xffffd
    80003de2:	de4080e7          	jalr	-540(ra) # 80000bc2 <acquire>
  empty = 0;
    80003de6:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003de8:	00029497          	auipc	s1,0x29
    80003dec:	3f848493          	addi	s1,s1,1016 # 8002d1e0 <itable+0x18>
    80003df0:	0002b697          	auipc	a3,0x2b
    80003df4:	e8068693          	addi	a3,a3,-384 # 8002ec70 <log>
    80003df8:	a039                	j	80003e06 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003dfa:	02090b63          	beqz	s2,80003e30 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003dfe:	08848493          	addi	s1,s1,136
    80003e02:	02d48a63          	beq	s1,a3,80003e36 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003e06:	449c                	lw	a5,8(s1)
    80003e08:	fef059e3          	blez	a5,80003dfa <iget+0x38>
    80003e0c:	4098                	lw	a4,0(s1)
    80003e0e:	ff3716e3          	bne	a4,s3,80003dfa <iget+0x38>
    80003e12:	40d8                	lw	a4,4(s1)
    80003e14:	ff4713e3          	bne	a4,s4,80003dfa <iget+0x38>
      ip->ref++;
    80003e18:	2785                	addiw	a5,a5,1
    80003e1a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003e1c:	00029517          	auipc	a0,0x29
    80003e20:	3ac50513          	addi	a0,a0,940 # 8002d1c8 <itable>
    80003e24:	ffffd097          	auipc	ra,0xffffd
    80003e28:	e52080e7          	jalr	-430(ra) # 80000c76 <release>
      return ip;
    80003e2c:	8926                	mv	s2,s1
    80003e2e:	a03d                	j	80003e5c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003e30:	f7f9                	bnez	a5,80003dfe <iget+0x3c>
    80003e32:	8926                	mv	s2,s1
    80003e34:	b7e9                	j	80003dfe <iget+0x3c>
  if(empty == 0)
    80003e36:	02090c63          	beqz	s2,80003e6e <iget+0xac>
  ip->dev = dev;
    80003e3a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003e3e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003e42:	4785                	li	a5,1
    80003e44:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003e48:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003e4c:	00029517          	auipc	a0,0x29
    80003e50:	37c50513          	addi	a0,a0,892 # 8002d1c8 <itable>
    80003e54:	ffffd097          	auipc	ra,0xffffd
    80003e58:	e22080e7          	jalr	-478(ra) # 80000c76 <release>
}
    80003e5c:	854a                	mv	a0,s2
    80003e5e:	70a2                	ld	ra,40(sp)
    80003e60:	7402                	ld	s0,32(sp)
    80003e62:	64e2                	ld	s1,24(sp)
    80003e64:	6942                	ld	s2,16(sp)
    80003e66:	69a2                	ld	s3,8(sp)
    80003e68:	6a02                	ld	s4,0(sp)
    80003e6a:	6145                	addi	sp,sp,48
    80003e6c:	8082                	ret
    panic("iget: no inodes");
    80003e6e:	00006517          	auipc	a0,0x6
    80003e72:	ba250513          	addi	a0,a0,-1118 # 80009a10 <syscalls+0x130>
    80003e76:	ffffc097          	auipc	ra,0xffffc
    80003e7a:	6b4080e7          	jalr	1716(ra) # 8000052a <panic>

0000000080003e7e <fsinit>:
fsinit(int dev) {
    80003e7e:	7179                	addi	sp,sp,-48
    80003e80:	f406                	sd	ra,40(sp)
    80003e82:	f022                	sd	s0,32(sp)
    80003e84:	ec26                	sd	s1,24(sp)
    80003e86:	e84a                	sd	s2,16(sp)
    80003e88:	e44e                	sd	s3,8(sp)
    80003e8a:	1800                	addi	s0,sp,48
    80003e8c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003e8e:	4585                	li	a1,1
    80003e90:	00000097          	auipc	ra,0x0
    80003e94:	a62080e7          	jalr	-1438(ra) # 800038f2 <bread>
    80003e98:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003e9a:	00029997          	auipc	s3,0x29
    80003e9e:	30e98993          	addi	s3,s3,782 # 8002d1a8 <sb>
    80003ea2:	02000613          	li	a2,32
    80003ea6:	05850593          	addi	a1,a0,88
    80003eaa:	854e                	mv	a0,s3
    80003eac:	ffffd097          	auipc	ra,0xffffd
    80003eb0:	e6e080e7          	jalr	-402(ra) # 80000d1a <memmove>
  brelse(bp);
    80003eb4:	8526                	mv	a0,s1
    80003eb6:	00000097          	auipc	ra,0x0
    80003eba:	b6c080e7          	jalr	-1172(ra) # 80003a22 <brelse>
  if(sb.magic != FSMAGIC)
    80003ebe:	0009a703          	lw	a4,0(s3)
    80003ec2:	102037b7          	lui	a5,0x10203
    80003ec6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003eca:	02f71263          	bne	a4,a5,80003eee <fsinit+0x70>
  initlog(dev, &sb);
    80003ece:	00029597          	auipc	a1,0x29
    80003ed2:	2da58593          	addi	a1,a1,730 # 8002d1a8 <sb>
    80003ed6:	854a                	mv	a0,s2
    80003ed8:	00001097          	auipc	ra,0x1
    80003edc:	e60080e7          	jalr	-416(ra) # 80004d38 <initlog>
}
    80003ee0:	70a2                	ld	ra,40(sp)
    80003ee2:	7402                	ld	s0,32(sp)
    80003ee4:	64e2                	ld	s1,24(sp)
    80003ee6:	6942                	ld	s2,16(sp)
    80003ee8:	69a2                	ld	s3,8(sp)
    80003eea:	6145                	addi	sp,sp,48
    80003eec:	8082                	ret
    panic("invalid file system");
    80003eee:	00006517          	auipc	a0,0x6
    80003ef2:	b3250513          	addi	a0,a0,-1230 # 80009a20 <syscalls+0x140>
    80003ef6:	ffffc097          	auipc	ra,0xffffc
    80003efa:	634080e7          	jalr	1588(ra) # 8000052a <panic>

0000000080003efe <iinit>:
{
    80003efe:	7179                	addi	sp,sp,-48
    80003f00:	f406                	sd	ra,40(sp)
    80003f02:	f022                	sd	s0,32(sp)
    80003f04:	ec26                	sd	s1,24(sp)
    80003f06:	e84a                	sd	s2,16(sp)
    80003f08:	e44e                	sd	s3,8(sp)
    80003f0a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003f0c:	00006597          	auipc	a1,0x6
    80003f10:	b2c58593          	addi	a1,a1,-1236 # 80009a38 <syscalls+0x158>
    80003f14:	00029517          	auipc	a0,0x29
    80003f18:	2b450513          	addi	a0,a0,692 # 8002d1c8 <itable>
    80003f1c:	ffffd097          	auipc	ra,0xffffd
    80003f20:	c16080e7          	jalr	-1002(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003f24:	00029497          	auipc	s1,0x29
    80003f28:	2cc48493          	addi	s1,s1,716 # 8002d1f0 <itable+0x28>
    80003f2c:	0002b997          	auipc	s3,0x2b
    80003f30:	d5498993          	addi	s3,s3,-684 # 8002ec80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003f34:	00006917          	auipc	s2,0x6
    80003f38:	b0c90913          	addi	s2,s2,-1268 # 80009a40 <syscalls+0x160>
    80003f3c:	85ca                	mv	a1,s2
    80003f3e:	8526                	mv	a0,s1
    80003f40:	00001097          	auipc	ra,0x1
    80003f44:	15c080e7          	jalr	348(ra) # 8000509c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003f48:	08848493          	addi	s1,s1,136
    80003f4c:	ff3498e3          	bne	s1,s3,80003f3c <iinit+0x3e>
}
    80003f50:	70a2                	ld	ra,40(sp)
    80003f52:	7402                	ld	s0,32(sp)
    80003f54:	64e2                	ld	s1,24(sp)
    80003f56:	6942                	ld	s2,16(sp)
    80003f58:	69a2                	ld	s3,8(sp)
    80003f5a:	6145                	addi	sp,sp,48
    80003f5c:	8082                	ret

0000000080003f5e <ialloc>:
{
    80003f5e:	715d                	addi	sp,sp,-80
    80003f60:	e486                	sd	ra,72(sp)
    80003f62:	e0a2                	sd	s0,64(sp)
    80003f64:	fc26                	sd	s1,56(sp)
    80003f66:	f84a                	sd	s2,48(sp)
    80003f68:	f44e                	sd	s3,40(sp)
    80003f6a:	f052                	sd	s4,32(sp)
    80003f6c:	ec56                	sd	s5,24(sp)
    80003f6e:	e85a                	sd	s6,16(sp)
    80003f70:	e45e                	sd	s7,8(sp)
    80003f72:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003f74:	00029717          	auipc	a4,0x29
    80003f78:	24072703          	lw	a4,576(a4) # 8002d1b4 <sb+0xc>
    80003f7c:	4785                	li	a5,1
    80003f7e:	04e7fa63          	bgeu	a5,a4,80003fd2 <ialloc+0x74>
    80003f82:	8aaa                	mv	s5,a0
    80003f84:	8bae                	mv	s7,a1
    80003f86:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003f88:	00029a17          	auipc	s4,0x29
    80003f8c:	220a0a13          	addi	s4,s4,544 # 8002d1a8 <sb>
    80003f90:	00048b1b          	sext.w	s6,s1
    80003f94:	0044d793          	srli	a5,s1,0x4
    80003f98:	018a2583          	lw	a1,24(s4)
    80003f9c:	9dbd                	addw	a1,a1,a5
    80003f9e:	8556                	mv	a0,s5
    80003fa0:	00000097          	auipc	ra,0x0
    80003fa4:	952080e7          	jalr	-1710(ra) # 800038f2 <bread>
    80003fa8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003faa:	05850993          	addi	s3,a0,88
    80003fae:	00f4f793          	andi	a5,s1,15
    80003fb2:	079a                	slli	a5,a5,0x6
    80003fb4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003fb6:	00099783          	lh	a5,0(s3)
    80003fba:	c785                	beqz	a5,80003fe2 <ialloc+0x84>
    brelse(bp);
    80003fbc:	00000097          	auipc	ra,0x0
    80003fc0:	a66080e7          	jalr	-1434(ra) # 80003a22 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003fc4:	0485                	addi	s1,s1,1
    80003fc6:	00ca2703          	lw	a4,12(s4)
    80003fca:	0004879b          	sext.w	a5,s1
    80003fce:	fce7e1e3          	bltu	a5,a4,80003f90 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003fd2:	00006517          	auipc	a0,0x6
    80003fd6:	a7650513          	addi	a0,a0,-1418 # 80009a48 <syscalls+0x168>
    80003fda:	ffffc097          	auipc	ra,0xffffc
    80003fde:	550080e7          	jalr	1360(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003fe2:	04000613          	li	a2,64
    80003fe6:	4581                	li	a1,0
    80003fe8:	854e                	mv	a0,s3
    80003fea:	ffffd097          	auipc	ra,0xffffd
    80003fee:	cd4080e7          	jalr	-812(ra) # 80000cbe <memset>
      dip->type = type;
    80003ff2:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003ff6:	854a                	mv	a0,s2
    80003ff8:	00001097          	auipc	ra,0x1
    80003ffc:	fbe080e7          	jalr	-66(ra) # 80004fb6 <log_write>
      brelse(bp);
    80004000:	854a                	mv	a0,s2
    80004002:	00000097          	auipc	ra,0x0
    80004006:	a20080e7          	jalr	-1504(ra) # 80003a22 <brelse>
      return iget(dev, inum);
    8000400a:	85da                	mv	a1,s6
    8000400c:	8556                	mv	a0,s5
    8000400e:	00000097          	auipc	ra,0x0
    80004012:	db4080e7          	jalr	-588(ra) # 80003dc2 <iget>
}
    80004016:	60a6                	ld	ra,72(sp)
    80004018:	6406                	ld	s0,64(sp)
    8000401a:	74e2                	ld	s1,56(sp)
    8000401c:	7942                	ld	s2,48(sp)
    8000401e:	79a2                	ld	s3,40(sp)
    80004020:	7a02                	ld	s4,32(sp)
    80004022:	6ae2                	ld	s5,24(sp)
    80004024:	6b42                	ld	s6,16(sp)
    80004026:	6ba2                	ld	s7,8(sp)
    80004028:	6161                	addi	sp,sp,80
    8000402a:	8082                	ret

000000008000402c <iupdate>:
{
    8000402c:	1101                	addi	sp,sp,-32
    8000402e:	ec06                	sd	ra,24(sp)
    80004030:	e822                	sd	s0,16(sp)
    80004032:	e426                	sd	s1,8(sp)
    80004034:	e04a                	sd	s2,0(sp)
    80004036:	1000                	addi	s0,sp,32
    80004038:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000403a:	415c                	lw	a5,4(a0)
    8000403c:	0047d79b          	srliw	a5,a5,0x4
    80004040:	00029597          	auipc	a1,0x29
    80004044:	1805a583          	lw	a1,384(a1) # 8002d1c0 <sb+0x18>
    80004048:	9dbd                	addw	a1,a1,a5
    8000404a:	4108                	lw	a0,0(a0)
    8000404c:	00000097          	auipc	ra,0x0
    80004050:	8a6080e7          	jalr	-1882(ra) # 800038f2 <bread>
    80004054:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004056:	05850793          	addi	a5,a0,88
    8000405a:	40c8                	lw	a0,4(s1)
    8000405c:	893d                	andi	a0,a0,15
    8000405e:	051a                	slli	a0,a0,0x6
    80004060:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80004062:	04449703          	lh	a4,68(s1)
    80004066:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000406a:	04649703          	lh	a4,70(s1)
    8000406e:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80004072:	04849703          	lh	a4,72(s1)
    80004076:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000407a:	04a49703          	lh	a4,74(s1)
    8000407e:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80004082:	44f8                	lw	a4,76(s1)
    80004084:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004086:	03400613          	li	a2,52
    8000408a:	05048593          	addi	a1,s1,80
    8000408e:	0531                	addi	a0,a0,12
    80004090:	ffffd097          	auipc	ra,0xffffd
    80004094:	c8a080e7          	jalr	-886(ra) # 80000d1a <memmove>
  log_write(bp);
    80004098:	854a                	mv	a0,s2
    8000409a:	00001097          	auipc	ra,0x1
    8000409e:	f1c080e7          	jalr	-228(ra) # 80004fb6 <log_write>
  brelse(bp);
    800040a2:	854a                	mv	a0,s2
    800040a4:	00000097          	auipc	ra,0x0
    800040a8:	97e080e7          	jalr	-1666(ra) # 80003a22 <brelse>
}
    800040ac:	60e2                	ld	ra,24(sp)
    800040ae:	6442                	ld	s0,16(sp)
    800040b0:	64a2                	ld	s1,8(sp)
    800040b2:	6902                	ld	s2,0(sp)
    800040b4:	6105                	addi	sp,sp,32
    800040b6:	8082                	ret

00000000800040b8 <idup>:
{
    800040b8:	1101                	addi	sp,sp,-32
    800040ba:	ec06                	sd	ra,24(sp)
    800040bc:	e822                	sd	s0,16(sp)
    800040be:	e426                	sd	s1,8(sp)
    800040c0:	1000                	addi	s0,sp,32
    800040c2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800040c4:	00029517          	auipc	a0,0x29
    800040c8:	10450513          	addi	a0,a0,260 # 8002d1c8 <itable>
    800040cc:	ffffd097          	auipc	ra,0xffffd
    800040d0:	af6080e7          	jalr	-1290(ra) # 80000bc2 <acquire>
  ip->ref++;
    800040d4:	449c                	lw	a5,8(s1)
    800040d6:	2785                	addiw	a5,a5,1
    800040d8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800040da:	00029517          	auipc	a0,0x29
    800040de:	0ee50513          	addi	a0,a0,238 # 8002d1c8 <itable>
    800040e2:	ffffd097          	auipc	ra,0xffffd
    800040e6:	b94080e7          	jalr	-1132(ra) # 80000c76 <release>
}
    800040ea:	8526                	mv	a0,s1
    800040ec:	60e2                	ld	ra,24(sp)
    800040ee:	6442                	ld	s0,16(sp)
    800040f0:	64a2                	ld	s1,8(sp)
    800040f2:	6105                	addi	sp,sp,32
    800040f4:	8082                	ret

00000000800040f6 <ilock>:
{
    800040f6:	1101                	addi	sp,sp,-32
    800040f8:	ec06                	sd	ra,24(sp)
    800040fa:	e822                	sd	s0,16(sp)
    800040fc:	e426                	sd	s1,8(sp)
    800040fe:	e04a                	sd	s2,0(sp)
    80004100:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004102:	c115                	beqz	a0,80004126 <ilock+0x30>
    80004104:	84aa                	mv	s1,a0
    80004106:	451c                	lw	a5,8(a0)
    80004108:	00f05f63          	blez	a5,80004126 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000410c:	0541                	addi	a0,a0,16
    8000410e:	00001097          	auipc	ra,0x1
    80004112:	fc8080e7          	jalr	-56(ra) # 800050d6 <acquiresleep>
  if(ip->valid == 0){
    80004116:	40bc                	lw	a5,64(s1)
    80004118:	cf99                	beqz	a5,80004136 <ilock+0x40>
}
    8000411a:	60e2                	ld	ra,24(sp)
    8000411c:	6442                	ld	s0,16(sp)
    8000411e:	64a2                	ld	s1,8(sp)
    80004120:	6902                	ld	s2,0(sp)
    80004122:	6105                	addi	sp,sp,32
    80004124:	8082                	ret
    panic("ilock");
    80004126:	00006517          	auipc	a0,0x6
    8000412a:	93a50513          	addi	a0,a0,-1734 # 80009a60 <syscalls+0x180>
    8000412e:	ffffc097          	auipc	ra,0xffffc
    80004132:	3fc080e7          	jalr	1020(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004136:	40dc                	lw	a5,4(s1)
    80004138:	0047d79b          	srliw	a5,a5,0x4
    8000413c:	00029597          	auipc	a1,0x29
    80004140:	0845a583          	lw	a1,132(a1) # 8002d1c0 <sb+0x18>
    80004144:	9dbd                	addw	a1,a1,a5
    80004146:	4088                	lw	a0,0(s1)
    80004148:	fffff097          	auipc	ra,0xfffff
    8000414c:	7aa080e7          	jalr	1962(ra) # 800038f2 <bread>
    80004150:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004152:	05850593          	addi	a1,a0,88
    80004156:	40dc                	lw	a5,4(s1)
    80004158:	8bbd                	andi	a5,a5,15
    8000415a:	079a                	slli	a5,a5,0x6
    8000415c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000415e:	00059783          	lh	a5,0(a1)
    80004162:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004166:	00259783          	lh	a5,2(a1)
    8000416a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000416e:	00459783          	lh	a5,4(a1)
    80004172:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004176:	00659783          	lh	a5,6(a1)
    8000417a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000417e:	459c                	lw	a5,8(a1)
    80004180:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004182:	03400613          	li	a2,52
    80004186:	05b1                	addi	a1,a1,12
    80004188:	05048513          	addi	a0,s1,80
    8000418c:	ffffd097          	auipc	ra,0xffffd
    80004190:	b8e080e7          	jalr	-1138(ra) # 80000d1a <memmove>
    brelse(bp);
    80004194:	854a                	mv	a0,s2
    80004196:	00000097          	auipc	ra,0x0
    8000419a:	88c080e7          	jalr	-1908(ra) # 80003a22 <brelse>
    ip->valid = 1;
    8000419e:	4785                	li	a5,1
    800041a0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800041a2:	04449783          	lh	a5,68(s1)
    800041a6:	fbb5                	bnez	a5,8000411a <ilock+0x24>
      panic("ilock: no type");
    800041a8:	00006517          	auipc	a0,0x6
    800041ac:	8c050513          	addi	a0,a0,-1856 # 80009a68 <syscalls+0x188>
    800041b0:	ffffc097          	auipc	ra,0xffffc
    800041b4:	37a080e7          	jalr	890(ra) # 8000052a <panic>

00000000800041b8 <iunlock>:
{
    800041b8:	1101                	addi	sp,sp,-32
    800041ba:	ec06                	sd	ra,24(sp)
    800041bc:	e822                	sd	s0,16(sp)
    800041be:	e426                	sd	s1,8(sp)
    800041c0:	e04a                	sd	s2,0(sp)
    800041c2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800041c4:	c905                	beqz	a0,800041f4 <iunlock+0x3c>
    800041c6:	84aa                	mv	s1,a0
    800041c8:	01050913          	addi	s2,a0,16
    800041cc:	854a                	mv	a0,s2
    800041ce:	00001097          	auipc	ra,0x1
    800041d2:	fa2080e7          	jalr	-94(ra) # 80005170 <holdingsleep>
    800041d6:	cd19                	beqz	a0,800041f4 <iunlock+0x3c>
    800041d8:	449c                	lw	a5,8(s1)
    800041da:	00f05d63          	blez	a5,800041f4 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800041de:	854a                	mv	a0,s2
    800041e0:	00001097          	auipc	ra,0x1
    800041e4:	f4c080e7          	jalr	-180(ra) # 8000512c <releasesleep>
}
    800041e8:	60e2                	ld	ra,24(sp)
    800041ea:	6442                	ld	s0,16(sp)
    800041ec:	64a2                	ld	s1,8(sp)
    800041ee:	6902                	ld	s2,0(sp)
    800041f0:	6105                	addi	sp,sp,32
    800041f2:	8082                	ret
    panic("iunlock");
    800041f4:	00006517          	auipc	a0,0x6
    800041f8:	88450513          	addi	a0,a0,-1916 # 80009a78 <syscalls+0x198>
    800041fc:	ffffc097          	auipc	ra,0xffffc
    80004200:	32e080e7          	jalr	814(ra) # 8000052a <panic>

0000000080004204 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004204:	7179                	addi	sp,sp,-48
    80004206:	f406                	sd	ra,40(sp)
    80004208:	f022                	sd	s0,32(sp)
    8000420a:	ec26                	sd	s1,24(sp)
    8000420c:	e84a                	sd	s2,16(sp)
    8000420e:	e44e                	sd	s3,8(sp)
    80004210:	e052                	sd	s4,0(sp)
    80004212:	1800                	addi	s0,sp,48
    80004214:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004216:	05050493          	addi	s1,a0,80
    8000421a:	08050913          	addi	s2,a0,128
    8000421e:	a021                	j	80004226 <itrunc+0x22>
    80004220:	0491                	addi	s1,s1,4
    80004222:	01248d63          	beq	s1,s2,8000423c <itrunc+0x38>
    if(ip->addrs[i]){
    80004226:	408c                	lw	a1,0(s1)
    80004228:	dde5                	beqz	a1,80004220 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000422a:	0009a503          	lw	a0,0(s3)
    8000422e:	00000097          	auipc	ra,0x0
    80004232:	90a080e7          	jalr	-1782(ra) # 80003b38 <bfree>
      ip->addrs[i] = 0;
    80004236:	0004a023          	sw	zero,0(s1)
    8000423a:	b7dd                	j	80004220 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000423c:	0809a583          	lw	a1,128(s3)
    80004240:	e185                	bnez	a1,80004260 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004242:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004246:	854e                	mv	a0,s3
    80004248:	00000097          	auipc	ra,0x0
    8000424c:	de4080e7          	jalr	-540(ra) # 8000402c <iupdate>
}
    80004250:	70a2                	ld	ra,40(sp)
    80004252:	7402                	ld	s0,32(sp)
    80004254:	64e2                	ld	s1,24(sp)
    80004256:	6942                	ld	s2,16(sp)
    80004258:	69a2                	ld	s3,8(sp)
    8000425a:	6a02                	ld	s4,0(sp)
    8000425c:	6145                	addi	sp,sp,48
    8000425e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004260:	0009a503          	lw	a0,0(s3)
    80004264:	fffff097          	auipc	ra,0xfffff
    80004268:	68e080e7          	jalr	1678(ra) # 800038f2 <bread>
    8000426c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000426e:	05850493          	addi	s1,a0,88
    80004272:	45850913          	addi	s2,a0,1112
    80004276:	a021                	j	8000427e <itrunc+0x7a>
    80004278:	0491                	addi	s1,s1,4
    8000427a:	01248b63          	beq	s1,s2,80004290 <itrunc+0x8c>
      if(a[j])
    8000427e:	408c                	lw	a1,0(s1)
    80004280:	dde5                	beqz	a1,80004278 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80004282:	0009a503          	lw	a0,0(s3)
    80004286:	00000097          	auipc	ra,0x0
    8000428a:	8b2080e7          	jalr	-1870(ra) # 80003b38 <bfree>
    8000428e:	b7ed                	j	80004278 <itrunc+0x74>
    brelse(bp);
    80004290:	8552                	mv	a0,s4
    80004292:	fffff097          	auipc	ra,0xfffff
    80004296:	790080e7          	jalr	1936(ra) # 80003a22 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000429a:	0809a583          	lw	a1,128(s3)
    8000429e:	0009a503          	lw	a0,0(s3)
    800042a2:	00000097          	auipc	ra,0x0
    800042a6:	896080e7          	jalr	-1898(ra) # 80003b38 <bfree>
    ip->addrs[NDIRECT] = 0;
    800042aa:	0809a023          	sw	zero,128(s3)
    800042ae:	bf51                	j	80004242 <itrunc+0x3e>

00000000800042b0 <iput>:
{
    800042b0:	1101                	addi	sp,sp,-32
    800042b2:	ec06                	sd	ra,24(sp)
    800042b4:	e822                	sd	s0,16(sp)
    800042b6:	e426                	sd	s1,8(sp)
    800042b8:	e04a                	sd	s2,0(sp)
    800042ba:	1000                	addi	s0,sp,32
    800042bc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800042be:	00029517          	auipc	a0,0x29
    800042c2:	f0a50513          	addi	a0,a0,-246 # 8002d1c8 <itable>
    800042c6:	ffffd097          	auipc	ra,0xffffd
    800042ca:	8fc080e7          	jalr	-1796(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800042ce:	4498                	lw	a4,8(s1)
    800042d0:	4785                	li	a5,1
    800042d2:	02f70363          	beq	a4,a5,800042f8 <iput+0x48>
  ip->ref--;
    800042d6:	449c                	lw	a5,8(s1)
    800042d8:	37fd                	addiw	a5,a5,-1
    800042da:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800042dc:	00029517          	auipc	a0,0x29
    800042e0:	eec50513          	addi	a0,a0,-276 # 8002d1c8 <itable>
    800042e4:	ffffd097          	auipc	ra,0xffffd
    800042e8:	992080e7          	jalr	-1646(ra) # 80000c76 <release>
}
    800042ec:	60e2                	ld	ra,24(sp)
    800042ee:	6442                	ld	s0,16(sp)
    800042f0:	64a2                	ld	s1,8(sp)
    800042f2:	6902                	ld	s2,0(sp)
    800042f4:	6105                	addi	sp,sp,32
    800042f6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800042f8:	40bc                	lw	a5,64(s1)
    800042fa:	dff1                	beqz	a5,800042d6 <iput+0x26>
    800042fc:	04a49783          	lh	a5,74(s1)
    80004300:	fbf9                	bnez	a5,800042d6 <iput+0x26>
    acquiresleep(&ip->lock);
    80004302:	01048913          	addi	s2,s1,16
    80004306:	854a                	mv	a0,s2
    80004308:	00001097          	auipc	ra,0x1
    8000430c:	dce080e7          	jalr	-562(ra) # 800050d6 <acquiresleep>
    release(&itable.lock);
    80004310:	00029517          	auipc	a0,0x29
    80004314:	eb850513          	addi	a0,a0,-328 # 8002d1c8 <itable>
    80004318:	ffffd097          	auipc	ra,0xffffd
    8000431c:	95e080e7          	jalr	-1698(ra) # 80000c76 <release>
    itrunc(ip);
    80004320:	8526                	mv	a0,s1
    80004322:	00000097          	auipc	ra,0x0
    80004326:	ee2080e7          	jalr	-286(ra) # 80004204 <itrunc>
    ip->type = 0;
    8000432a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000432e:	8526                	mv	a0,s1
    80004330:	00000097          	auipc	ra,0x0
    80004334:	cfc080e7          	jalr	-772(ra) # 8000402c <iupdate>
    ip->valid = 0;
    80004338:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000433c:	854a                	mv	a0,s2
    8000433e:	00001097          	auipc	ra,0x1
    80004342:	dee080e7          	jalr	-530(ra) # 8000512c <releasesleep>
    acquire(&itable.lock);
    80004346:	00029517          	auipc	a0,0x29
    8000434a:	e8250513          	addi	a0,a0,-382 # 8002d1c8 <itable>
    8000434e:	ffffd097          	auipc	ra,0xffffd
    80004352:	874080e7          	jalr	-1932(ra) # 80000bc2 <acquire>
    80004356:	b741                	j	800042d6 <iput+0x26>

0000000080004358 <iunlockput>:
{
    80004358:	1101                	addi	sp,sp,-32
    8000435a:	ec06                	sd	ra,24(sp)
    8000435c:	e822                	sd	s0,16(sp)
    8000435e:	e426                	sd	s1,8(sp)
    80004360:	1000                	addi	s0,sp,32
    80004362:	84aa                	mv	s1,a0
  iunlock(ip);
    80004364:	00000097          	auipc	ra,0x0
    80004368:	e54080e7          	jalr	-428(ra) # 800041b8 <iunlock>
  iput(ip);
    8000436c:	8526                	mv	a0,s1
    8000436e:	00000097          	auipc	ra,0x0
    80004372:	f42080e7          	jalr	-190(ra) # 800042b0 <iput>
}
    80004376:	60e2                	ld	ra,24(sp)
    80004378:	6442                	ld	s0,16(sp)
    8000437a:	64a2                	ld	s1,8(sp)
    8000437c:	6105                	addi	sp,sp,32
    8000437e:	8082                	ret

0000000080004380 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004380:	1141                	addi	sp,sp,-16
    80004382:	e422                	sd	s0,8(sp)
    80004384:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004386:	411c                	lw	a5,0(a0)
    80004388:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000438a:	415c                	lw	a5,4(a0)
    8000438c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000438e:	04451783          	lh	a5,68(a0)
    80004392:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004396:	04a51783          	lh	a5,74(a0)
    8000439a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000439e:	04c56783          	lwu	a5,76(a0)
    800043a2:	e99c                	sd	a5,16(a1)
}
    800043a4:	6422                	ld	s0,8(sp)
    800043a6:	0141                	addi	sp,sp,16
    800043a8:	8082                	ret

00000000800043aa <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800043aa:	457c                	lw	a5,76(a0)
    800043ac:	0ed7e963          	bltu	a5,a3,8000449e <readi+0xf4>
{
    800043b0:	7159                	addi	sp,sp,-112
    800043b2:	f486                	sd	ra,104(sp)
    800043b4:	f0a2                	sd	s0,96(sp)
    800043b6:	eca6                	sd	s1,88(sp)
    800043b8:	e8ca                	sd	s2,80(sp)
    800043ba:	e4ce                	sd	s3,72(sp)
    800043bc:	e0d2                	sd	s4,64(sp)
    800043be:	fc56                	sd	s5,56(sp)
    800043c0:	f85a                	sd	s6,48(sp)
    800043c2:	f45e                	sd	s7,40(sp)
    800043c4:	f062                	sd	s8,32(sp)
    800043c6:	ec66                	sd	s9,24(sp)
    800043c8:	e86a                	sd	s10,16(sp)
    800043ca:	e46e                	sd	s11,8(sp)
    800043cc:	1880                	addi	s0,sp,112
    800043ce:	8baa                	mv	s7,a0
    800043d0:	8c2e                	mv	s8,a1
    800043d2:	8ab2                	mv	s5,a2
    800043d4:	84b6                	mv	s1,a3
    800043d6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800043d8:	9f35                	addw	a4,a4,a3
    return 0;
    800043da:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800043dc:	0ad76063          	bltu	a4,a3,8000447c <readi+0xd2>
  if(off + n > ip->size)
    800043e0:	00e7f463          	bgeu	a5,a4,800043e8 <readi+0x3e>
    n = ip->size - off;
    800043e4:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800043e8:	0a0b0963          	beqz	s6,8000449a <readi+0xf0>
    800043ec:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800043ee:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800043f2:	5cfd                	li	s9,-1
    800043f4:	a82d                	j	8000442e <readi+0x84>
    800043f6:	020a1d93          	slli	s11,s4,0x20
    800043fa:	020ddd93          	srli	s11,s11,0x20
    800043fe:	05890793          	addi	a5,s2,88
    80004402:	86ee                	mv	a3,s11
    80004404:	963e                	add	a2,a2,a5
    80004406:	85d6                	mv	a1,s5
    80004408:	8562                	mv	a0,s8
    8000440a:	ffffe097          	auipc	ra,0xffffe
    8000440e:	1ce080e7          	jalr	462(ra) # 800025d8 <either_copyout>
    80004412:	05950d63          	beq	a0,s9,8000446c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004416:	854a                	mv	a0,s2
    80004418:	fffff097          	auipc	ra,0xfffff
    8000441c:	60a080e7          	jalr	1546(ra) # 80003a22 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004420:	013a09bb          	addw	s3,s4,s3
    80004424:	009a04bb          	addw	s1,s4,s1
    80004428:	9aee                	add	s5,s5,s11
    8000442a:	0569f763          	bgeu	s3,s6,80004478 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000442e:	000ba903          	lw	s2,0(s7)
    80004432:	00a4d59b          	srliw	a1,s1,0xa
    80004436:	855e                	mv	a0,s7
    80004438:	00000097          	auipc	ra,0x0
    8000443c:	8ae080e7          	jalr	-1874(ra) # 80003ce6 <bmap>
    80004440:	0005059b          	sext.w	a1,a0
    80004444:	854a                	mv	a0,s2
    80004446:	fffff097          	auipc	ra,0xfffff
    8000444a:	4ac080e7          	jalr	1196(ra) # 800038f2 <bread>
    8000444e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004450:	3ff4f613          	andi	a2,s1,1023
    80004454:	40cd07bb          	subw	a5,s10,a2
    80004458:	413b073b          	subw	a4,s6,s3
    8000445c:	8a3e                	mv	s4,a5
    8000445e:	2781                	sext.w	a5,a5
    80004460:	0007069b          	sext.w	a3,a4
    80004464:	f8f6f9e3          	bgeu	a3,a5,800043f6 <readi+0x4c>
    80004468:	8a3a                	mv	s4,a4
    8000446a:	b771                	j	800043f6 <readi+0x4c>
      brelse(bp);
    8000446c:	854a                	mv	a0,s2
    8000446e:	fffff097          	auipc	ra,0xfffff
    80004472:	5b4080e7          	jalr	1460(ra) # 80003a22 <brelse>
      tot = -1;
    80004476:	59fd                	li	s3,-1
  }
  return tot;
    80004478:	0009851b          	sext.w	a0,s3
}
    8000447c:	70a6                	ld	ra,104(sp)
    8000447e:	7406                	ld	s0,96(sp)
    80004480:	64e6                	ld	s1,88(sp)
    80004482:	6946                	ld	s2,80(sp)
    80004484:	69a6                	ld	s3,72(sp)
    80004486:	6a06                	ld	s4,64(sp)
    80004488:	7ae2                	ld	s5,56(sp)
    8000448a:	7b42                	ld	s6,48(sp)
    8000448c:	7ba2                	ld	s7,40(sp)
    8000448e:	7c02                	ld	s8,32(sp)
    80004490:	6ce2                	ld	s9,24(sp)
    80004492:	6d42                	ld	s10,16(sp)
    80004494:	6da2                	ld	s11,8(sp)
    80004496:	6165                	addi	sp,sp,112
    80004498:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000449a:	89da                	mv	s3,s6
    8000449c:	bff1                	j	80004478 <readi+0xce>
    return 0;
    8000449e:	4501                	li	a0,0
}
    800044a0:	8082                	ret

00000000800044a2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800044a2:	457c                	lw	a5,76(a0)
    800044a4:	10d7e863          	bltu	a5,a3,800045b4 <writei+0x112>
{
    800044a8:	7159                	addi	sp,sp,-112
    800044aa:	f486                	sd	ra,104(sp)
    800044ac:	f0a2                	sd	s0,96(sp)
    800044ae:	eca6                	sd	s1,88(sp)
    800044b0:	e8ca                	sd	s2,80(sp)
    800044b2:	e4ce                	sd	s3,72(sp)
    800044b4:	e0d2                	sd	s4,64(sp)
    800044b6:	fc56                	sd	s5,56(sp)
    800044b8:	f85a                	sd	s6,48(sp)
    800044ba:	f45e                	sd	s7,40(sp)
    800044bc:	f062                	sd	s8,32(sp)
    800044be:	ec66                	sd	s9,24(sp)
    800044c0:	e86a                	sd	s10,16(sp)
    800044c2:	e46e                	sd	s11,8(sp)
    800044c4:	1880                	addi	s0,sp,112
    800044c6:	8b2a                	mv	s6,a0
    800044c8:	8c2e                	mv	s8,a1
    800044ca:	8ab2                	mv	s5,a2
    800044cc:	8936                	mv	s2,a3
    800044ce:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    800044d0:	00e687bb          	addw	a5,a3,a4
    800044d4:	0ed7e263          	bltu	a5,a3,800045b8 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800044d8:	00043737          	lui	a4,0x43
    800044dc:	0ef76063          	bltu	a4,a5,800045bc <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800044e0:	0c0b8863          	beqz	s7,800045b0 <writei+0x10e>
    800044e4:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800044e6:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800044ea:	5cfd                	li	s9,-1
    800044ec:	a091                	j	80004530 <writei+0x8e>
    800044ee:	02099d93          	slli	s11,s3,0x20
    800044f2:	020ddd93          	srli	s11,s11,0x20
    800044f6:	05848793          	addi	a5,s1,88
    800044fa:	86ee                	mv	a3,s11
    800044fc:	8656                	mv	a2,s5
    800044fe:	85e2                	mv	a1,s8
    80004500:	953e                	add	a0,a0,a5
    80004502:	ffffe097          	auipc	ra,0xffffe
    80004506:	12c080e7          	jalr	300(ra) # 8000262e <either_copyin>
    8000450a:	07950263          	beq	a0,s9,8000456e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000450e:	8526                	mv	a0,s1
    80004510:	00001097          	auipc	ra,0x1
    80004514:	aa6080e7          	jalr	-1370(ra) # 80004fb6 <log_write>
    brelse(bp);
    80004518:	8526                	mv	a0,s1
    8000451a:	fffff097          	auipc	ra,0xfffff
    8000451e:	508080e7          	jalr	1288(ra) # 80003a22 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004522:	01498a3b          	addw	s4,s3,s4
    80004526:	0129893b          	addw	s2,s3,s2
    8000452a:	9aee                	add	s5,s5,s11
    8000452c:	057a7663          	bgeu	s4,s7,80004578 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004530:	000b2483          	lw	s1,0(s6)
    80004534:	00a9559b          	srliw	a1,s2,0xa
    80004538:	855a                	mv	a0,s6
    8000453a:	fffff097          	auipc	ra,0xfffff
    8000453e:	7ac080e7          	jalr	1964(ra) # 80003ce6 <bmap>
    80004542:	0005059b          	sext.w	a1,a0
    80004546:	8526                	mv	a0,s1
    80004548:	fffff097          	auipc	ra,0xfffff
    8000454c:	3aa080e7          	jalr	938(ra) # 800038f2 <bread>
    80004550:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004552:	3ff97513          	andi	a0,s2,1023
    80004556:	40ad07bb          	subw	a5,s10,a0
    8000455a:	414b873b          	subw	a4,s7,s4
    8000455e:	89be                	mv	s3,a5
    80004560:	2781                	sext.w	a5,a5
    80004562:	0007069b          	sext.w	a3,a4
    80004566:	f8f6f4e3          	bgeu	a3,a5,800044ee <writei+0x4c>
    8000456a:	89ba                	mv	s3,a4
    8000456c:	b749                	j	800044ee <writei+0x4c>
      brelse(bp);
    8000456e:	8526                	mv	a0,s1
    80004570:	fffff097          	auipc	ra,0xfffff
    80004574:	4b2080e7          	jalr	1202(ra) # 80003a22 <brelse>
  }

  if(off > ip->size)
    80004578:	04cb2783          	lw	a5,76(s6)
    8000457c:	0127f463          	bgeu	a5,s2,80004584 <writei+0xe2>
    ip->size = off;
    80004580:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004584:	855a                	mv	a0,s6
    80004586:	00000097          	auipc	ra,0x0
    8000458a:	aa6080e7          	jalr	-1370(ra) # 8000402c <iupdate>

  return tot;
    8000458e:	000a051b          	sext.w	a0,s4
}
    80004592:	70a6                	ld	ra,104(sp)
    80004594:	7406                	ld	s0,96(sp)
    80004596:	64e6                	ld	s1,88(sp)
    80004598:	6946                	ld	s2,80(sp)
    8000459a:	69a6                	ld	s3,72(sp)
    8000459c:	6a06                	ld	s4,64(sp)
    8000459e:	7ae2                	ld	s5,56(sp)
    800045a0:	7b42                	ld	s6,48(sp)
    800045a2:	7ba2                	ld	s7,40(sp)
    800045a4:	7c02                	ld	s8,32(sp)
    800045a6:	6ce2                	ld	s9,24(sp)
    800045a8:	6d42                	ld	s10,16(sp)
    800045aa:	6da2                	ld	s11,8(sp)
    800045ac:	6165                	addi	sp,sp,112
    800045ae:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800045b0:	8a5e                	mv	s4,s7
    800045b2:	bfc9                	j	80004584 <writei+0xe2>
    return -1;
    800045b4:	557d                	li	a0,-1
}
    800045b6:	8082                	ret
    return -1;
    800045b8:	557d                	li	a0,-1
    800045ba:	bfe1                	j	80004592 <writei+0xf0>
    return -1;
    800045bc:	557d                	li	a0,-1
    800045be:	bfd1                	j	80004592 <writei+0xf0>

00000000800045c0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800045c0:	1141                	addi	sp,sp,-16
    800045c2:	e406                	sd	ra,8(sp)
    800045c4:	e022                	sd	s0,0(sp)
    800045c6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800045c8:	4639                	li	a2,14
    800045ca:	ffffc097          	auipc	ra,0xffffc
    800045ce:	7cc080e7          	jalr	1996(ra) # 80000d96 <strncmp>
}
    800045d2:	60a2                	ld	ra,8(sp)
    800045d4:	6402                	ld	s0,0(sp)
    800045d6:	0141                	addi	sp,sp,16
    800045d8:	8082                	ret

00000000800045da <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800045da:	7139                	addi	sp,sp,-64
    800045dc:	fc06                	sd	ra,56(sp)
    800045de:	f822                	sd	s0,48(sp)
    800045e0:	f426                	sd	s1,40(sp)
    800045e2:	f04a                	sd	s2,32(sp)
    800045e4:	ec4e                	sd	s3,24(sp)
    800045e6:	e852                	sd	s4,16(sp)
    800045e8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800045ea:	04451703          	lh	a4,68(a0)
    800045ee:	4785                	li	a5,1
    800045f0:	00f71a63          	bne	a4,a5,80004604 <dirlookup+0x2a>
    800045f4:	892a                	mv	s2,a0
    800045f6:	89ae                	mv	s3,a1
    800045f8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800045fa:	457c                	lw	a5,76(a0)
    800045fc:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800045fe:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004600:	e79d                	bnez	a5,8000462e <dirlookup+0x54>
    80004602:	a8a5                	j	8000467a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004604:	00005517          	auipc	a0,0x5
    80004608:	47c50513          	addi	a0,a0,1148 # 80009a80 <syscalls+0x1a0>
    8000460c:	ffffc097          	auipc	ra,0xffffc
    80004610:	f1e080e7          	jalr	-226(ra) # 8000052a <panic>
      panic("dirlookup read");
    80004614:	00005517          	auipc	a0,0x5
    80004618:	48450513          	addi	a0,a0,1156 # 80009a98 <syscalls+0x1b8>
    8000461c:	ffffc097          	auipc	ra,0xffffc
    80004620:	f0e080e7          	jalr	-242(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004624:	24c1                	addiw	s1,s1,16
    80004626:	04c92783          	lw	a5,76(s2)
    8000462a:	04f4f763          	bgeu	s1,a5,80004678 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000462e:	4741                	li	a4,16
    80004630:	86a6                	mv	a3,s1
    80004632:	fc040613          	addi	a2,s0,-64
    80004636:	4581                	li	a1,0
    80004638:	854a                	mv	a0,s2
    8000463a:	00000097          	auipc	ra,0x0
    8000463e:	d70080e7          	jalr	-656(ra) # 800043aa <readi>
    80004642:	47c1                	li	a5,16
    80004644:	fcf518e3          	bne	a0,a5,80004614 <dirlookup+0x3a>
    if(de.inum == 0)
    80004648:	fc045783          	lhu	a5,-64(s0)
    8000464c:	dfe1                	beqz	a5,80004624 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000464e:	fc240593          	addi	a1,s0,-62
    80004652:	854e                	mv	a0,s3
    80004654:	00000097          	auipc	ra,0x0
    80004658:	f6c080e7          	jalr	-148(ra) # 800045c0 <namecmp>
    8000465c:	f561                	bnez	a0,80004624 <dirlookup+0x4a>
      if(poff)
    8000465e:	000a0463          	beqz	s4,80004666 <dirlookup+0x8c>
        *poff = off;
    80004662:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004666:	fc045583          	lhu	a1,-64(s0)
    8000466a:	00092503          	lw	a0,0(s2)
    8000466e:	fffff097          	auipc	ra,0xfffff
    80004672:	754080e7          	jalr	1876(ra) # 80003dc2 <iget>
    80004676:	a011                	j	8000467a <dirlookup+0xa0>
  return 0;
    80004678:	4501                	li	a0,0
}
    8000467a:	70e2                	ld	ra,56(sp)
    8000467c:	7442                	ld	s0,48(sp)
    8000467e:	74a2                	ld	s1,40(sp)
    80004680:	7902                	ld	s2,32(sp)
    80004682:	69e2                	ld	s3,24(sp)
    80004684:	6a42                	ld	s4,16(sp)
    80004686:	6121                	addi	sp,sp,64
    80004688:	8082                	ret

000000008000468a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000468a:	711d                	addi	sp,sp,-96
    8000468c:	ec86                	sd	ra,88(sp)
    8000468e:	e8a2                	sd	s0,80(sp)
    80004690:	e4a6                	sd	s1,72(sp)
    80004692:	e0ca                	sd	s2,64(sp)
    80004694:	fc4e                	sd	s3,56(sp)
    80004696:	f852                	sd	s4,48(sp)
    80004698:	f456                	sd	s5,40(sp)
    8000469a:	f05a                	sd	s6,32(sp)
    8000469c:	ec5e                	sd	s7,24(sp)
    8000469e:	e862                	sd	s8,16(sp)
    800046a0:	e466                	sd	s9,8(sp)
    800046a2:	1080                	addi	s0,sp,96
    800046a4:	84aa                	mv	s1,a0
    800046a6:	8aae                	mv	s5,a1
    800046a8:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800046aa:	00054703          	lbu	a4,0(a0)
    800046ae:	02f00793          	li	a5,47
    800046b2:	02f70363          	beq	a4,a5,800046d8 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800046b6:	ffffd097          	auipc	ra,0xffffd
    800046ba:	67c080e7          	jalr	1660(ra) # 80001d32 <myproc>
    800046be:	15053503          	ld	a0,336(a0)
    800046c2:	00000097          	auipc	ra,0x0
    800046c6:	9f6080e7          	jalr	-1546(ra) # 800040b8 <idup>
    800046ca:	89aa                	mv	s3,a0
  while(*path == '/')
    800046cc:	02f00913          	li	s2,47
  len = path - s;
    800046d0:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800046d2:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800046d4:	4b85                	li	s7,1
    800046d6:	a865                	j	8000478e <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800046d8:	4585                	li	a1,1
    800046da:	4505                	li	a0,1
    800046dc:	fffff097          	auipc	ra,0xfffff
    800046e0:	6e6080e7          	jalr	1766(ra) # 80003dc2 <iget>
    800046e4:	89aa                	mv	s3,a0
    800046e6:	b7dd                	j	800046cc <namex+0x42>
      iunlockput(ip);
    800046e8:	854e                	mv	a0,s3
    800046ea:	00000097          	auipc	ra,0x0
    800046ee:	c6e080e7          	jalr	-914(ra) # 80004358 <iunlockput>
      return 0;
    800046f2:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800046f4:	854e                	mv	a0,s3
    800046f6:	60e6                	ld	ra,88(sp)
    800046f8:	6446                	ld	s0,80(sp)
    800046fa:	64a6                	ld	s1,72(sp)
    800046fc:	6906                	ld	s2,64(sp)
    800046fe:	79e2                	ld	s3,56(sp)
    80004700:	7a42                	ld	s4,48(sp)
    80004702:	7aa2                	ld	s5,40(sp)
    80004704:	7b02                	ld	s6,32(sp)
    80004706:	6be2                	ld	s7,24(sp)
    80004708:	6c42                	ld	s8,16(sp)
    8000470a:	6ca2                	ld	s9,8(sp)
    8000470c:	6125                	addi	sp,sp,96
    8000470e:	8082                	ret
      iunlock(ip);
    80004710:	854e                	mv	a0,s3
    80004712:	00000097          	auipc	ra,0x0
    80004716:	aa6080e7          	jalr	-1370(ra) # 800041b8 <iunlock>
      return ip;
    8000471a:	bfe9                	j	800046f4 <namex+0x6a>
      iunlockput(ip);
    8000471c:	854e                	mv	a0,s3
    8000471e:	00000097          	auipc	ra,0x0
    80004722:	c3a080e7          	jalr	-966(ra) # 80004358 <iunlockput>
      return 0;
    80004726:	89e6                	mv	s3,s9
    80004728:	b7f1                	j	800046f4 <namex+0x6a>
  len = path - s;
    8000472a:	40b48633          	sub	a2,s1,a1
    8000472e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004732:	099c5463          	bge	s8,s9,800047ba <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004736:	4639                	li	a2,14
    80004738:	8552                	mv	a0,s4
    8000473a:	ffffc097          	auipc	ra,0xffffc
    8000473e:	5e0080e7          	jalr	1504(ra) # 80000d1a <memmove>
  while(*path == '/')
    80004742:	0004c783          	lbu	a5,0(s1)
    80004746:	01279763          	bne	a5,s2,80004754 <namex+0xca>
    path++;
    8000474a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000474c:	0004c783          	lbu	a5,0(s1)
    80004750:	ff278de3          	beq	a5,s2,8000474a <namex+0xc0>
    ilock(ip);
    80004754:	854e                	mv	a0,s3
    80004756:	00000097          	auipc	ra,0x0
    8000475a:	9a0080e7          	jalr	-1632(ra) # 800040f6 <ilock>
    if(ip->type != T_DIR){
    8000475e:	04499783          	lh	a5,68(s3)
    80004762:	f97793e3          	bne	a5,s7,800046e8 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004766:	000a8563          	beqz	s5,80004770 <namex+0xe6>
    8000476a:	0004c783          	lbu	a5,0(s1)
    8000476e:	d3cd                	beqz	a5,80004710 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004770:	865a                	mv	a2,s6
    80004772:	85d2                	mv	a1,s4
    80004774:	854e                	mv	a0,s3
    80004776:	00000097          	auipc	ra,0x0
    8000477a:	e64080e7          	jalr	-412(ra) # 800045da <dirlookup>
    8000477e:	8caa                	mv	s9,a0
    80004780:	dd51                	beqz	a0,8000471c <namex+0x92>
    iunlockput(ip);
    80004782:	854e                	mv	a0,s3
    80004784:	00000097          	auipc	ra,0x0
    80004788:	bd4080e7          	jalr	-1068(ra) # 80004358 <iunlockput>
    ip = next;
    8000478c:	89e6                	mv	s3,s9
  while(*path == '/')
    8000478e:	0004c783          	lbu	a5,0(s1)
    80004792:	05279763          	bne	a5,s2,800047e0 <namex+0x156>
    path++;
    80004796:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004798:	0004c783          	lbu	a5,0(s1)
    8000479c:	ff278de3          	beq	a5,s2,80004796 <namex+0x10c>
  if(*path == 0)
    800047a0:	c79d                	beqz	a5,800047ce <namex+0x144>
    path++;
    800047a2:	85a6                	mv	a1,s1
  len = path - s;
    800047a4:	8cda                	mv	s9,s6
    800047a6:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800047a8:	01278963          	beq	a5,s2,800047ba <namex+0x130>
    800047ac:	dfbd                	beqz	a5,8000472a <namex+0xa0>
    path++;
    800047ae:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800047b0:	0004c783          	lbu	a5,0(s1)
    800047b4:	ff279ce3          	bne	a5,s2,800047ac <namex+0x122>
    800047b8:	bf8d                	j	8000472a <namex+0xa0>
    memmove(name, s, len);
    800047ba:	2601                	sext.w	a2,a2
    800047bc:	8552                	mv	a0,s4
    800047be:	ffffc097          	auipc	ra,0xffffc
    800047c2:	55c080e7          	jalr	1372(ra) # 80000d1a <memmove>
    name[len] = 0;
    800047c6:	9cd2                	add	s9,s9,s4
    800047c8:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800047cc:	bf9d                	j	80004742 <namex+0xb8>
  if(nameiparent){
    800047ce:	f20a83e3          	beqz	s5,800046f4 <namex+0x6a>
    iput(ip);
    800047d2:	854e                	mv	a0,s3
    800047d4:	00000097          	auipc	ra,0x0
    800047d8:	adc080e7          	jalr	-1316(ra) # 800042b0 <iput>
    return 0;
    800047dc:	4981                	li	s3,0
    800047de:	bf19                	j	800046f4 <namex+0x6a>
  if(*path == 0)
    800047e0:	d7fd                	beqz	a5,800047ce <namex+0x144>
  while(*path != '/' && *path != 0)
    800047e2:	0004c783          	lbu	a5,0(s1)
    800047e6:	85a6                	mv	a1,s1
    800047e8:	b7d1                	j	800047ac <namex+0x122>

00000000800047ea <dirlink>:
{
    800047ea:	7139                	addi	sp,sp,-64
    800047ec:	fc06                	sd	ra,56(sp)
    800047ee:	f822                	sd	s0,48(sp)
    800047f0:	f426                	sd	s1,40(sp)
    800047f2:	f04a                	sd	s2,32(sp)
    800047f4:	ec4e                	sd	s3,24(sp)
    800047f6:	e852                	sd	s4,16(sp)
    800047f8:	0080                	addi	s0,sp,64
    800047fa:	892a                	mv	s2,a0
    800047fc:	8a2e                	mv	s4,a1
    800047fe:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004800:	4601                	li	a2,0
    80004802:	00000097          	auipc	ra,0x0
    80004806:	dd8080e7          	jalr	-552(ra) # 800045da <dirlookup>
    8000480a:	e93d                	bnez	a0,80004880 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000480c:	04c92483          	lw	s1,76(s2)
    80004810:	c49d                	beqz	s1,8000483e <dirlink+0x54>
    80004812:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004814:	4741                	li	a4,16
    80004816:	86a6                	mv	a3,s1
    80004818:	fc040613          	addi	a2,s0,-64
    8000481c:	4581                	li	a1,0
    8000481e:	854a                	mv	a0,s2
    80004820:	00000097          	auipc	ra,0x0
    80004824:	b8a080e7          	jalr	-1142(ra) # 800043aa <readi>
    80004828:	47c1                	li	a5,16
    8000482a:	06f51163          	bne	a0,a5,8000488c <dirlink+0xa2>
    if(de.inum == 0)
    8000482e:	fc045783          	lhu	a5,-64(s0)
    80004832:	c791                	beqz	a5,8000483e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004834:	24c1                	addiw	s1,s1,16
    80004836:	04c92783          	lw	a5,76(s2)
    8000483a:	fcf4ede3          	bltu	s1,a5,80004814 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000483e:	4639                	li	a2,14
    80004840:	85d2                	mv	a1,s4
    80004842:	fc240513          	addi	a0,s0,-62
    80004846:	ffffc097          	auipc	ra,0xffffc
    8000484a:	58c080e7          	jalr	1420(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    8000484e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004852:	4741                	li	a4,16
    80004854:	86a6                	mv	a3,s1
    80004856:	fc040613          	addi	a2,s0,-64
    8000485a:	4581                	li	a1,0
    8000485c:	854a                	mv	a0,s2
    8000485e:	00000097          	auipc	ra,0x0
    80004862:	c44080e7          	jalr	-956(ra) # 800044a2 <writei>
    80004866:	872a                	mv	a4,a0
    80004868:	47c1                	li	a5,16
  return 0;
    8000486a:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000486c:	02f71863          	bne	a4,a5,8000489c <dirlink+0xb2>
}
    80004870:	70e2                	ld	ra,56(sp)
    80004872:	7442                	ld	s0,48(sp)
    80004874:	74a2                	ld	s1,40(sp)
    80004876:	7902                	ld	s2,32(sp)
    80004878:	69e2                	ld	s3,24(sp)
    8000487a:	6a42                	ld	s4,16(sp)
    8000487c:	6121                	addi	sp,sp,64
    8000487e:	8082                	ret
    iput(ip);
    80004880:	00000097          	auipc	ra,0x0
    80004884:	a30080e7          	jalr	-1488(ra) # 800042b0 <iput>
    return -1;
    80004888:	557d                	li	a0,-1
    8000488a:	b7dd                	j	80004870 <dirlink+0x86>
      panic("dirlink read");
    8000488c:	00005517          	auipc	a0,0x5
    80004890:	21c50513          	addi	a0,a0,540 # 80009aa8 <syscalls+0x1c8>
    80004894:	ffffc097          	auipc	ra,0xffffc
    80004898:	c96080e7          	jalr	-874(ra) # 8000052a <panic>
    panic("dirlink");
    8000489c:	00005517          	auipc	a0,0x5
    800048a0:	39450513          	addi	a0,a0,916 # 80009c30 <syscalls+0x350>
    800048a4:	ffffc097          	auipc	ra,0xffffc
    800048a8:	c86080e7          	jalr	-890(ra) # 8000052a <panic>

00000000800048ac <namei>:

struct inode*
namei(char *path)
{
    800048ac:	1101                	addi	sp,sp,-32
    800048ae:	ec06                	sd	ra,24(sp)
    800048b0:	e822                	sd	s0,16(sp)
    800048b2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800048b4:	fe040613          	addi	a2,s0,-32
    800048b8:	4581                	li	a1,0
    800048ba:	00000097          	auipc	ra,0x0
    800048be:	dd0080e7          	jalr	-560(ra) # 8000468a <namex>
}
    800048c2:	60e2                	ld	ra,24(sp)
    800048c4:	6442                	ld	s0,16(sp)
    800048c6:	6105                	addi	sp,sp,32
    800048c8:	8082                	ret

00000000800048ca <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800048ca:	1141                	addi	sp,sp,-16
    800048cc:	e406                	sd	ra,8(sp)
    800048ce:	e022                	sd	s0,0(sp)
    800048d0:	0800                	addi	s0,sp,16
    800048d2:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800048d4:	4585                	li	a1,1
    800048d6:	00000097          	auipc	ra,0x0
    800048da:	db4080e7          	jalr	-588(ra) # 8000468a <namex>
}
    800048de:	60a2                	ld	ra,8(sp)
    800048e0:	6402                	ld	s0,0(sp)
    800048e2:	0141                	addi	sp,sp,16
    800048e4:	8082                	ret

00000000800048e6 <itoa>:


#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
    800048e6:	1101                	addi	sp,sp,-32
    800048e8:	ec22                	sd	s0,24(sp)
    800048ea:	1000                	addi	s0,sp,32
    800048ec:	872a                	mv	a4,a0
    800048ee:	852e                	mv	a0,a1
    char const digit[] = "0123456789";
    800048f0:	00005797          	auipc	a5,0x5
    800048f4:	1c878793          	addi	a5,a5,456 # 80009ab8 <syscalls+0x1d8>
    800048f8:	6394                	ld	a3,0(a5)
    800048fa:	fed43023          	sd	a3,-32(s0)
    800048fe:	0087d683          	lhu	a3,8(a5)
    80004902:	fed41423          	sh	a3,-24(s0)
    80004906:	00a7c783          	lbu	a5,10(a5)
    8000490a:	fef40523          	sb	a5,-22(s0)
    char* p = b;
    8000490e:	87ae                	mv	a5,a1
    if(i<0){
    80004910:	02074b63          	bltz	a4,80004946 <itoa+0x60>
        *p++ = '-';
        i *= -1;
    }
    int shifter = i;
    80004914:	86ba                	mv	a3,a4
    do{ //Move to where representation ends
        ++p;
        shifter = shifter/10;
    80004916:	4629                	li	a2,10
        ++p;
    80004918:	0785                	addi	a5,a5,1
        shifter = shifter/10;
    8000491a:	02c6c6bb          	divw	a3,a3,a2
    }while(shifter);
    8000491e:	feed                	bnez	a3,80004918 <itoa+0x32>
    *p = '\0';
    80004920:	00078023          	sb	zero,0(a5)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
    80004924:	4629                	li	a2,10
    80004926:	17fd                	addi	a5,a5,-1
    80004928:	02c766bb          	remw	a3,a4,a2
    8000492c:	ff040593          	addi	a1,s0,-16
    80004930:	96ae                	add	a3,a3,a1
    80004932:	ff06c683          	lbu	a3,-16(a3)
    80004936:	00d78023          	sb	a3,0(a5)
        i = i/10;
    8000493a:	02c7473b          	divw	a4,a4,a2
    }while(i);
    8000493e:	f765                	bnez	a4,80004926 <itoa+0x40>
    return b;
}
    80004940:	6462                	ld	s0,24(sp)
    80004942:	6105                	addi	sp,sp,32
    80004944:	8082                	ret
        *p++ = '-';
    80004946:	00158793          	addi	a5,a1,1
    8000494a:	02d00693          	li	a3,45
    8000494e:	00d58023          	sb	a3,0(a1)
        i *= -1;
    80004952:	40e0073b          	negw	a4,a4
    80004956:	bf7d                	j	80004914 <itoa+0x2e>

0000000080004958 <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
    80004958:	711d                	addi	sp,sp,-96
    8000495a:	ec86                	sd	ra,88(sp)
    8000495c:	e8a2                	sd	s0,80(sp)
    8000495e:	e4a6                	sd	s1,72(sp)
    80004960:	e0ca                	sd	s2,64(sp)
    80004962:	1080                	addi	s0,sp,96
    80004964:	84aa                	mv	s1,a0
  //path of proccess
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    80004966:	4619                	li	a2,6
    80004968:	00005597          	auipc	a1,0x5
    8000496c:	16058593          	addi	a1,a1,352 # 80009ac8 <syscalls+0x1e8>
    80004970:	fd040513          	addi	a0,s0,-48
    80004974:	ffffc097          	auipc	ra,0xffffc
    80004978:	3a6080e7          	jalr	934(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    8000497c:	fd640593          	addi	a1,s0,-42
    80004980:	5888                	lw	a0,48(s1)
    80004982:	00000097          	auipc	ra,0x0
    80004986:	f64080e7          	jalr	-156(ra) # 800048e6 <itoa>
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ];
  uint off;

  if(0 == p->swapFile)
    8000498a:	1684b503          	ld	a0,360(s1)
    8000498e:	16050763          	beqz	a0,80004afc <removeSwapFile+0x1a4>
  {
    return -1;
  }
  fileclose(p->swapFile);
    80004992:	00001097          	auipc	ra,0x1
    80004996:	918080e7          	jalr	-1768(ra) # 800052aa <fileclose>

  begin_op();
    8000499a:	00000097          	auipc	ra,0x0
    8000499e:	444080e7          	jalr	1092(ra) # 80004dde <begin_op>
  if((dp = nameiparent(path, name)) == 0)
    800049a2:	fb040593          	addi	a1,s0,-80
    800049a6:	fd040513          	addi	a0,s0,-48
    800049aa:	00000097          	auipc	ra,0x0
    800049ae:	f20080e7          	jalr	-224(ra) # 800048ca <nameiparent>
    800049b2:	892a                	mv	s2,a0
    800049b4:	cd69                	beqz	a0,80004a8e <removeSwapFile+0x136>
  {
    end_op();
    return -1;
  }

  ilock(dp);
    800049b6:	fffff097          	auipc	ra,0xfffff
    800049ba:	740080e7          	jalr	1856(ra) # 800040f6 <ilock>

    // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800049be:	00005597          	auipc	a1,0x5
    800049c2:	11258593          	addi	a1,a1,274 # 80009ad0 <syscalls+0x1f0>
    800049c6:	fb040513          	addi	a0,s0,-80
    800049ca:	00000097          	auipc	ra,0x0
    800049ce:	bf6080e7          	jalr	-1034(ra) # 800045c0 <namecmp>
    800049d2:	c57d                	beqz	a0,80004ac0 <removeSwapFile+0x168>
    800049d4:	00005597          	auipc	a1,0x5
    800049d8:	10458593          	addi	a1,a1,260 # 80009ad8 <syscalls+0x1f8>
    800049dc:	fb040513          	addi	a0,s0,-80
    800049e0:	00000097          	auipc	ra,0x0
    800049e4:	be0080e7          	jalr	-1056(ra) # 800045c0 <namecmp>
    800049e8:	cd61                	beqz	a0,80004ac0 <removeSwapFile+0x168>
     goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    800049ea:	fac40613          	addi	a2,s0,-84
    800049ee:	fb040593          	addi	a1,s0,-80
    800049f2:	854a                	mv	a0,s2
    800049f4:	00000097          	auipc	ra,0x0
    800049f8:	be6080e7          	jalr	-1050(ra) # 800045da <dirlookup>
    800049fc:	84aa                	mv	s1,a0
    800049fe:	c169                	beqz	a0,80004ac0 <removeSwapFile+0x168>
    goto bad;
  ilock(ip);
    80004a00:	fffff097          	auipc	ra,0xfffff
    80004a04:	6f6080e7          	jalr	1782(ra) # 800040f6 <ilock>

  if(ip->nlink < 1)
    80004a08:	04a49783          	lh	a5,74(s1)
    80004a0c:	08f05763          	blez	a5,80004a9a <removeSwapFile+0x142>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004a10:	04449703          	lh	a4,68(s1)
    80004a14:	4785                	li	a5,1
    80004a16:	08f70a63          	beq	a4,a5,80004aaa <removeSwapFile+0x152>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    80004a1a:	4641                	li	a2,16
    80004a1c:	4581                	li	a1,0
    80004a1e:	fc040513          	addi	a0,s0,-64
    80004a22:	ffffc097          	auipc	ra,0xffffc
    80004a26:	29c080e7          	jalr	668(ra) # 80000cbe <memset>
  if(writei(dp,0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004a2a:	4741                	li	a4,16
    80004a2c:	fac42683          	lw	a3,-84(s0)
    80004a30:	fc040613          	addi	a2,s0,-64
    80004a34:	4581                	li	a1,0
    80004a36:	854a                	mv	a0,s2
    80004a38:	00000097          	auipc	ra,0x0
    80004a3c:	a6a080e7          	jalr	-1430(ra) # 800044a2 <writei>
    80004a40:	47c1                	li	a5,16
    80004a42:	08f51a63          	bne	a0,a5,80004ad6 <removeSwapFile+0x17e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    80004a46:	04449703          	lh	a4,68(s1)
    80004a4a:	4785                	li	a5,1
    80004a4c:	08f70d63          	beq	a4,a5,80004ae6 <removeSwapFile+0x18e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    80004a50:	854a                	mv	a0,s2
    80004a52:	00000097          	auipc	ra,0x0
    80004a56:	906080e7          	jalr	-1786(ra) # 80004358 <iunlockput>

  ip->nlink--;
    80004a5a:	04a4d783          	lhu	a5,74(s1)
    80004a5e:	37fd                	addiw	a5,a5,-1
    80004a60:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004a64:	8526                	mv	a0,s1
    80004a66:	fffff097          	auipc	ra,0xfffff
    80004a6a:	5c6080e7          	jalr	1478(ra) # 8000402c <iupdate>
  iunlockput(ip);
    80004a6e:	8526                	mv	a0,s1
    80004a70:	00000097          	auipc	ra,0x0
    80004a74:	8e8080e7          	jalr	-1816(ra) # 80004358 <iunlockput>

  end_op();
    80004a78:	00000097          	auipc	ra,0x0
    80004a7c:	3e6080e7          	jalr	998(ra) # 80004e5e <end_op>

  return 0;
    80004a80:	4501                	li	a0,0
  bad:
    iunlockput(dp);
    end_op();
    return -1;

}
    80004a82:	60e6                	ld	ra,88(sp)
    80004a84:	6446                	ld	s0,80(sp)
    80004a86:	64a6                	ld	s1,72(sp)
    80004a88:	6906                	ld	s2,64(sp)
    80004a8a:	6125                	addi	sp,sp,96
    80004a8c:	8082                	ret
    end_op();
    80004a8e:	00000097          	auipc	ra,0x0
    80004a92:	3d0080e7          	jalr	976(ra) # 80004e5e <end_op>
    return -1;
    80004a96:	557d                	li	a0,-1
    80004a98:	b7ed                	j	80004a82 <removeSwapFile+0x12a>
    panic("unlink: nlink < 1");
    80004a9a:	00005517          	auipc	a0,0x5
    80004a9e:	04650513          	addi	a0,a0,70 # 80009ae0 <syscalls+0x200>
    80004aa2:	ffffc097          	auipc	ra,0xffffc
    80004aa6:	a88080e7          	jalr	-1400(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004aaa:	8526                	mv	a0,s1
    80004aac:	00001097          	auipc	ra,0x1
    80004ab0:	7b4080e7          	jalr	1972(ra) # 80006260 <isdirempty>
    80004ab4:	f13d                	bnez	a0,80004a1a <removeSwapFile+0xc2>
    iunlockput(ip);
    80004ab6:	8526                	mv	a0,s1
    80004ab8:	00000097          	auipc	ra,0x0
    80004abc:	8a0080e7          	jalr	-1888(ra) # 80004358 <iunlockput>
    iunlockput(dp);
    80004ac0:	854a                	mv	a0,s2
    80004ac2:	00000097          	auipc	ra,0x0
    80004ac6:	896080e7          	jalr	-1898(ra) # 80004358 <iunlockput>
    end_op();
    80004aca:	00000097          	auipc	ra,0x0
    80004ace:	394080e7          	jalr	916(ra) # 80004e5e <end_op>
    return -1;
    80004ad2:	557d                	li	a0,-1
    80004ad4:	b77d                	j	80004a82 <removeSwapFile+0x12a>
    panic("unlink: writei");
    80004ad6:	00005517          	auipc	a0,0x5
    80004ada:	02250513          	addi	a0,a0,34 # 80009af8 <syscalls+0x218>
    80004ade:	ffffc097          	auipc	ra,0xffffc
    80004ae2:	a4c080e7          	jalr	-1460(ra) # 8000052a <panic>
    dp->nlink--;
    80004ae6:	04a95783          	lhu	a5,74(s2)
    80004aea:	37fd                	addiw	a5,a5,-1
    80004aec:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80004af0:	854a                	mv	a0,s2
    80004af2:	fffff097          	auipc	ra,0xfffff
    80004af6:	53a080e7          	jalr	1338(ra) # 8000402c <iupdate>
    80004afa:	bf99                	j	80004a50 <removeSwapFile+0xf8>
    return -1;
    80004afc:	557d                	li	a0,-1
    80004afe:	b751                	j	80004a82 <removeSwapFile+0x12a>

0000000080004b00 <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
    80004b00:	7179                	addi	sp,sp,-48
    80004b02:	f406                	sd	ra,40(sp)
    80004b04:	f022                	sd	s0,32(sp)
    80004b06:	ec26                	sd	s1,24(sp)
    80004b08:	e84a                	sd	s2,16(sp)
    80004b0a:	1800                	addi	s0,sp,48
    80004b0c:	84aa                	mv	s1,a0
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    80004b0e:	4619                	li	a2,6
    80004b10:	00005597          	auipc	a1,0x5
    80004b14:	fb858593          	addi	a1,a1,-72 # 80009ac8 <syscalls+0x1e8>
    80004b18:	fd040513          	addi	a0,s0,-48
    80004b1c:	ffffc097          	auipc	ra,0xffffc
    80004b20:	1fe080e7          	jalr	510(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    80004b24:	fd640593          	addi	a1,s0,-42
    80004b28:	5888                	lw	a0,48(s1)
    80004b2a:	00000097          	auipc	ra,0x0
    80004b2e:	dbc080e7          	jalr	-580(ra) # 800048e6 <itoa>

  begin_op();
    80004b32:	00000097          	auipc	ra,0x0
    80004b36:	2ac080e7          	jalr	684(ra) # 80004dde <begin_op>

  struct inode * in = create(path, T_FILE, 0, 0);
    80004b3a:	4681                	li	a3,0
    80004b3c:	4601                	li	a2,0
    80004b3e:	4589                	li	a1,2
    80004b40:	fd040513          	addi	a0,s0,-48
    80004b44:	00002097          	auipc	ra,0x2
    80004b48:	910080e7          	jalr	-1776(ra) # 80006454 <create>
    80004b4c:	892a                	mv	s2,a0
  iunlock(in);
    80004b4e:	fffff097          	auipc	ra,0xfffff
    80004b52:	66a080e7          	jalr	1642(ra) # 800041b8 <iunlock>
  p->swapFile = filealloc();  if (p->swapFile == 0)
    80004b56:	00000097          	auipc	ra,0x0
    80004b5a:	698080e7          	jalr	1688(ra) # 800051ee <filealloc>
    80004b5e:	16a4b423          	sd	a0,360(s1)
    80004b62:	cd1d                	beqz	a0,80004ba0 <createSwapFile+0xa0>
    panic("no slot for files on /store");

  p->swapFile->ip = in;
    80004b64:	01253c23          	sd	s2,24(a0)
  p->swapFile->type = FD_INODE;
    80004b68:	1684b703          	ld	a4,360(s1)
    80004b6c:	4789                	li	a5,2
    80004b6e:	c31c                	sw	a5,0(a4)
  p->swapFile->off = 0;
    80004b70:	1684b703          	ld	a4,360(s1)
    80004b74:	02072023          	sw	zero,32(a4) # 43020 <_entry-0x7ffbcfe0>
  p->swapFile->readable = O_WRONLY;
    80004b78:	1684b703          	ld	a4,360(s1)
    80004b7c:	4685                	li	a3,1
    80004b7e:	00d70423          	sb	a3,8(a4)
  p->swapFile->writable = O_RDWR;
    80004b82:	1684b703          	ld	a4,360(s1)
    80004b86:	00f704a3          	sb	a5,9(a4)
    end_op();
    80004b8a:	00000097          	auipc	ra,0x0
    80004b8e:	2d4080e7          	jalr	724(ra) # 80004e5e <end_op>

    return 0;
}
    80004b92:	4501                	li	a0,0
    80004b94:	70a2                	ld	ra,40(sp)
    80004b96:	7402                	ld	s0,32(sp)
    80004b98:	64e2                	ld	s1,24(sp)
    80004b9a:	6942                	ld	s2,16(sp)
    80004b9c:	6145                	addi	sp,sp,48
    80004b9e:	8082                	ret
    panic("no slot for files on /store");
    80004ba0:	00005517          	auipc	a0,0x5
    80004ba4:	f6850513          	addi	a0,a0,-152 # 80009b08 <syscalls+0x228>
    80004ba8:	ffffc097          	auipc	ra,0xffffc
    80004bac:	982080e7          	jalr	-1662(ra) # 8000052a <panic>

0000000080004bb0 <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004bb0:	1141                	addi	sp,sp,-16
    80004bb2:	e406                	sd	ra,8(sp)
    80004bb4:	e022                	sd	s0,0(sp)
    80004bb6:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004bb8:	16853783          	ld	a5,360(a0)
    80004bbc:	d390                	sw	a2,32(a5)
  return kfilewrite(p->swapFile, (uint64)buffer, size);
    80004bbe:	8636                	mv	a2,a3
    80004bc0:	16853503          	ld	a0,360(a0)
    80004bc4:	00001097          	auipc	ra,0x1
    80004bc8:	ad8080e7          	jalr	-1320(ra) # 8000569c <kfilewrite>
}
    80004bcc:	60a2                	ld	ra,8(sp)
    80004bce:	6402                	ld	s0,0(sp)
    80004bd0:	0141                	addi	sp,sp,16
    80004bd2:	8082                	ret

0000000080004bd4 <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004bd4:	1141                	addi	sp,sp,-16
    80004bd6:	e406                	sd	ra,8(sp)
    80004bd8:	e022                	sd	s0,0(sp)
    80004bda:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004bdc:	16853783          	ld	a5,360(a0)
    80004be0:	d390                	sw	a2,32(a5)
  return kfileread(p->swapFile, (uint64)buffer,  size);
    80004be2:	8636                	mv	a2,a3
    80004be4:	16853503          	ld	a0,360(a0)
    80004be8:	00001097          	auipc	ra,0x1
    80004bec:	9f2080e7          	jalr	-1550(ra) # 800055da <kfileread>
    80004bf0:	60a2                	ld	ra,8(sp)
    80004bf2:	6402                	ld	s0,0(sp)
    80004bf4:	0141                	addi	sp,sp,16
    80004bf6:	8082                	ret

0000000080004bf8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004bf8:	1101                	addi	sp,sp,-32
    80004bfa:	ec06                	sd	ra,24(sp)
    80004bfc:	e822                	sd	s0,16(sp)
    80004bfe:	e426                	sd	s1,8(sp)
    80004c00:	e04a                	sd	s2,0(sp)
    80004c02:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004c04:	0002a917          	auipc	s2,0x2a
    80004c08:	06c90913          	addi	s2,s2,108 # 8002ec70 <log>
    80004c0c:	01892583          	lw	a1,24(s2)
    80004c10:	02892503          	lw	a0,40(s2)
    80004c14:	fffff097          	auipc	ra,0xfffff
    80004c18:	cde080e7          	jalr	-802(ra) # 800038f2 <bread>
    80004c1c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004c1e:	02c92683          	lw	a3,44(s2)
    80004c22:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004c24:	02d05863          	blez	a3,80004c54 <write_head+0x5c>
    80004c28:	0002a797          	auipc	a5,0x2a
    80004c2c:	07878793          	addi	a5,a5,120 # 8002eca0 <log+0x30>
    80004c30:	05c50713          	addi	a4,a0,92
    80004c34:	36fd                	addiw	a3,a3,-1
    80004c36:	02069613          	slli	a2,a3,0x20
    80004c3a:	01e65693          	srli	a3,a2,0x1e
    80004c3e:	0002a617          	auipc	a2,0x2a
    80004c42:	06660613          	addi	a2,a2,102 # 8002eca4 <log+0x34>
    80004c46:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004c48:	4390                	lw	a2,0(a5)
    80004c4a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004c4c:	0791                	addi	a5,a5,4
    80004c4e:	0711                	addi	a4,a4,4
    80004c50:	fed79ce3          	bne	a5,a3,80004c48 <write_head+0x50>
  }
  bwrite(buf);
    80004c54:	8526                	mv	a0,s1
    80004c56:	fffff097          	auipc	ra,0xfffff
    80004c5a:	d8e080e7          	jalr	-626(ra) # 800039e4 <bwrite>
  brelse(buf);
    80004c5e:	8526                	mv	a0,s1
    80004c60:	fffff097          	auipc	ra,0xfffff
    80004c64:	dc2080e7          	jalr	-574(ra) # 80003a22 <brelse>
}
    80004c68:	60e2                	ld	ra,24(sp)
    80004c6a:	6442                	ld	s0,16(sp)
    80004c6c:	64a2                	ld	s1,8(sp)
    80004c6e:	6902                	ld	s2,0(sp)
    80004c70:	6105                	addi	sp,sp,32
    80004c72:	8082                	ret

0000000080004c74 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c74:	0002a797          	auipc	a5,0x2a
    80004c78:	0287a783          	lw	a5,40(a5) # 8002ec9c <log+0x2c>
    80004c7c:	0af05d63          	blez	a5,80004d36 <install_trans+0xc2>
{
    80004c80:	7139                	addi	sp,sp,-64
    80004c82:	fc06                	sd	ra,56(sp)
    80004c84:	f822                	sd	s0,48(sp)
    80004c86:	f426                	sd	s1,40(sp)
    80004c88:	f04a                	sd	s2,32(sp)
    80004c8a:	ec4e                	sd	s3,24(sp)
    80004c8c:	e852                	sd	s4,16(sp)
    80004c8e:	e456                	sd	s5,8(sp)
    80004c90:	e05a                	sd	s6,0(sp)
    80004c92:	0080                	addi	s0,sp,64
    80004c94:	8b2a                	mv	s6,a0
    80004c96:	0002aa97          	auipc	s5,0x2a
    80004c9a:	00aa8a93          	addi	s5,s5,10 # 8002eca0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c9e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004ca0:	0002a997          	auipc	s3,0x2a
    80004ca4:	fd098993          	addi	s3,s3,-48 # 8002ec70 <log>
    80004ca8:	a00d                	j	80004cca <install_trans+0x56>
    brelse(lbuf);
    80004caa:	854a                	mv	a0,s2
    80004cac:	fffff097          	auipc	ra,0xfffff
    80004cb0:	d76080e7          	jalr	-650(ra) # 80003a22 <brelse>
    brelse(dbuf);
    80004cb4:	8526                	mv	a0,s1
    80004cb6:	fffff097          	auipc	ra,0xfffff
    80004cba:	d6c080e7          	jalr	-660(ra) # 80003a22 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004cbe:	2a05                	addiw	s4,s4,1
    80004cc0:	0a91                	addi	s5,s5,4
    80004cc2:	02c9a783          	lw	a5,44(s3)
    80004cc6:	04fa5e63          	bge	s4,a5,80004d22 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004cca:	0189a583          	lw	a1,24(s3)
    80004cce:	014585bb          	addw	a1,a1,s4
    80004cd2:	2585                	addiw	a1,a1,1
    80004cd4:	0289a503          	lw	a0,40(s3)
    80004cd8:	fffff097          	auipc	ra,0xfffff
    80004cdc:	c1a080e7          	jalr	-998(ra) # 800038f2 <bread>
    80004ce0:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004ce2:	000aa583          	lw	a1,0(s5)
    80004ce6:	0289a503          	lw	a0,40(s3)
    80004cea:	fffff097          	auipc	ra,0xfffff
    80004cee:	c08080e7          	jalr	-1016(ra) # 800038f2 <bread>
    80004cf2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004cf4:	40000613          	li	a2,1024
    80004cf8:	05890593          	addi	a1,s2,88
    80004cfc:	05850513          	addi	a0,a0,88
    80004d00:	ffffc097          	auipc	ra,0xffffc
    80004d04:	01a080e7          	jalr	26(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004d08:	8526                	mv	a0,s1
    80004d0a:	fffff097          	auipc	ra,0xfffff
    80004d0e:	cda080e7          	jalr	-806(ra) # 800039e4 <bwrite>
    if(recovering == 0)
    80004d12:	f80b1ce3          	bnez	s6,80004caa <install_trans+0x36>
      bunpin(dbuf);
    80004d16:	8526                	mv	a0,s1
    80004d18:	fffff097          	auipc	ra,0xfffff
    80004d1c:	de4080e7          	jalr	-540(ra) # 80003afc <bunpin>
    80004d20:	b769                	j	80004caa <install_trans+0x36>
}
    80004d22:	70e2                	ld	ra,56(sp)
    80004d24:	7442                	ld	s0,48(sp)
    80004d26:	74a2                	ld	s1,40(sp)
    80004d28:	7902                	ld	s2,32(sp)
    80004d2a:	69e2                	ld	s3,24(sp)
    80004d2c:	6a42                	ld	s4,16(sp)
    80004d2e:	6aa2                	ld	s5,8(sp)
    80004d30:	6b02                	ld	s6,0(sp)
    80004d32:	6121                	addi	sp,sp,64
    80004d34:	8082                	ret
    80004d36:	8082                	ret

0000000080004d38 <initlog>:
{
    80004d38:	7179                	addi	sp,sp,-48
    80004d3a:	f406                	sd	ra,40(sp)
    80004d3c:	f022                	sd	s0,32(sp)
    80004d3e:	ec26                	sd	s1,24(sp)
    80004d40:	e84a                	sd	s2,16(sp)
    80004d42:	e44e                	sd	s3,8(sp)
    80004d44:	1800                	addi	s0,sp,48
    80004d46:	892a                	mv	s2,a0
    80004d48:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004d4a:	0002a497          	auipc	s1,0x2a
    80004d4e:	f2648493          	addi	s1,s1,-218 # 8002ec70 <log>
    80004d52:	00005597          	auipc	a1,0x5
    80004d56:	dd658593          	addi	a1,a1,-554 # 80009b28 <syscalls+0x248>
    80004d5a:	8526                	mv	a0,s1
    80004d5c:	ffffc097          	auipc	ra,0xffffc
    80004d60:	dd6080e7          	jalr	-554(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004d64:	0149a583          	lw	a1,20(s3)
    80004d68:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004d6a:	0109a783          	lw	a5,16(s3)
    80004d6e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004d70:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004d74:	854a                	mv	a0,s2
    80004d76:	fffff097          	auipc	ra,0xfffff
    80004d7a:	b7c080e7          	jalr	-1156(ra) # 800038f2 <bread>
  log.lh.n = lh->n;
    80004d7e:	4d34                	lw	a3,88(a0)
    80004d80:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004d82:	02d05663          	blez	a3,80004dae <initlog+0x76>
    80004d86:	05c50793          	addi	a5,a0,92
    80004d8a:	0002a717          	auipc	a4,0x2a
    80004d8e:	f1670713          	addi	a4,a4,-234 # 8002eca0 <log+0x30>
    80004d92:	36fd                	addiw	a3,a3,-1
    80004d94:	02069613          	slli	a2,a3,0x20
    80004d98:	01e65693          	srli	a3,a2,0x1e
    80004d9c:	06050613          	addi	a2,a0,96
    80004da0:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004da2:	4390                	lw	a2,0(a5)
    80004da4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004da6:	0791                	addi	a5,a5,4
    80004da8:	0711                	addi	a4,a4,4
    80004daa:	fed79ce3          	bne	a5,a3,80004da2 <initlog+0x6a>
  brelse(buf);
    80004dae:	fffff097          	auipc	ra,0xfffff
    80004db2:	c74080e7          	jalr	-908(ra) # 80003a22 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004db6:	4505                	li	a0,1
    80004db8:	00000097          	auipc	ra,0x0
    80004dbc:	ebc080e7          	jalr	-324(ra) # 80004c74 <install_trans>
  log.lh.n = 0;
    80004dc0:	0002a797          	auipc	a5,0x2a
    80004dc4:	ec07ae23          	sw	zero,-292(a5) # 8002ec9c <log+0x2c>
  write_head(); // clear the log
    80004dc8:	00000097          	auipc	ra,0x0
    80004dcc:	e30080e7          	jalr	-464(ra) # 80004bf8 <write_head>
}
    80004dd0:	70a2                	ld	ra,40(sp)
    80004dd2:	7402                	ld	s0,32(sp)
    80004dd4:	64e2                	ld	s1,24(sp)
    80004dd6:	6942                	ld	s2,16(sp)
    80004dd8:	69a2                	ld	s3,8(sp)
    80004dda:	6145                	addi	sp,sp,48
    80004ddc:	8082                	ret

0000000080004dde <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004dde:	1101                	addi	sp,sp,-32
    80004de0:	ec06                	sd	ra,24(sp)
    80004de2:	e822                	sd	s0,16(sp)
    80004de4:	e426                	sd	s1,8(sp)
    80004de6:	e04a                	sd	s2,0(sp)
    80004de8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004dea:	0002a517          	auipc	a0,0x2a
    80004dee:	e8650513          	addi	a0,a0,-378 # 8002ec70 <log>
    80004df2:	ffffc097          	auipc	ra,0xffffc
    80004df6:	dd0080e7          	jalr	-560(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    80004dfa:	0002a497          	auipc	s1,0x2a
    80004dfe:	e7648493          	addi	s1,s1,-394 # 8002ec70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004e02:	4979                	li	s2,30
    80004e04:	a039                	j	80004e12 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004e06:	85a6                	mv	a1,s1
    80004e08:	8526                	mv	a0,s1
    80004e0a:	ffffd097          	auipc	ra,0xffffd
    80004e0e:	420080e7          	jalr	1056(ra) # 8000222a <sleep>
    if(log.committing){
    80004e12:	50dc                	lw	a5,36(s1)
    80004e14:	fbed                	bnez	a5,80004e06 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004e16:	509c                	lw	a5,32(s1)
    80004e18:	0017871b          	addiw	a4,a5,1
    80004e1c:	0007069b          	sext.w	a3,a4
    80004e20:	0027179b          	slliw	a5,a4,0x2
    80004e24:	9fb9                	addw	a5,a5,a4
    80004e26:	0017979b          	slliw	a5,a5,0x1
    80004e2a:	54d8                	lw	a4,44(s1)
    80004e2c:	9fb9                	addw	a5,a5,a4
    80004e2e:	00f95963          	bge	s2,a5,80004e40 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004e32:	85a6                	mv	a1,s1
    80004e34:	8526                	mv	a0,s1
    80004e36:	ffffd097          	auipc	ra,0xffffd
    80004e3a:	3f4080e7          	jalr	1012(ra) # 8000222a <sleep>
    80004e3e:	bfd1                	j	80004e12 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004e40:	0002a517          	auipc	a0,0x2a
    80004e44:	e3050513          	addi	a0,a0,-464 # 8002ec70 <log>
    80004e48:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004e4a:	ffffc097          	auipc	ra,0xffffc
    80004e4e:	e2c080e7          	jalr	-468(ra) # 80000c76 <release>
      break;
    }
  }
}
    80004e52:	60e2                	ld	ra,24(sp)
    80004e54:	6442                	ld	s0,16(sp)
    80004e56:	64a2                	ld	s1,8(sp)
    80004e58:	6902                	ld	s2,0(sp)
    80004e5a:	6105                	addi	sp,sp,32
    80004e5c:	8082                	ret

0000000080004e5e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004e5e:	7139                	addi	sp,sp,-64
    80004e60:	fc06                	sd	ra,56(sp)
    80004e62:	f822                	sd	s0,48(sp)
    80004e64:	f426                	sd	s1,40(sp)
    80004e66:	f04a                	sd	s2,32(sp)
    80004e68:	ec4e                	sd	s3,24(sp)
    80004e6a:	e852                	sd	s4,16(sp)
    80004e6c:	e456                	sd	s5,8(sp)
    80004e6e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004e70:	0002a497          	auipc	s1,0x2a
    80004e74:	e0048493          	addi	s1,s1,-512 # 8002ec70 <log>
    80004e78:	8526                	mv	a0,s1
    80004e7a:	ffffc097          	auipc	ra,0xffffc
    80004e7e:	d48080e7          	jalr	-696(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004e82:	509c                	lw	a5,32(s1)
    80004e84:	37fd                	addiw	a5,a5,-1
    80004e86:	0007891b          	sext.w	s2,a5
    80004e8a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004e8c:	50dc                	lw	a5,36(s1)
    80004e8e:	e7b9                	bnez	a5,80004edc <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004e90:	04091e63          	bnez	s2,80004eec <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004e94:	0002a497          	auipc	s1,0x2a
    80004e98:	ddc48493          	addi	s1,s1,-548 # 8002ec70 <log>
    80004e9c:	4785                	li	a5,1
    80004e9e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004ea0:	8526                	mv	a0,s1
    80004ea2:	ffffc097          	auipc	ra,0xffffc
    80004ea6:	dd4080e7          	jalr	-556(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004eaa:	54dc                	lw	a5,44(s1)
    80004eac:	06f04763          	bgtz	a5,80004f1a <end_op+0xbc>
    acquire(&log.lock);
    80004eb0:	0002a497          	auipc	s1,0x2a
    80004eb4:	dc048493          	addi	s1,s1,-576 # 8002ec70 <log>
    80004eb8:	8526                	mv	a0,s1
    80004eba:	ffffc097          	auipc	ra,0xffffc
    80004ebe:	d08080e7          	jalr	-760(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004ec2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004ec6:	8526                	mv	a0,s1
    80004ec8:	ffffd097          	auipc	ra,0xffffd
    80004ecc:	4ee080e7          	jalr	1262(ra) # 800023b6 <wakeup>
    release(&log.lock);
    80004ed0:	8526                	mv	a0,s1
    80004ed2:	ffffc097          	auipc	ra,0xffffc
    80004ed6:	da4080e7          	jalr	-604(ra) # 80000c76 <release>
}
    80004eda:	a03d                	j	80004f08 <end_op+0xaa>
    panic("log.committing");
    80004edc:	00005517          	auipc	a0,0x5
    80004ee0:	c5450513          	addi	a0,a0,-940 # 80009b30 <syscalls+0x250>
    80004ee4:	ffffb097          	auipc	ra,0xffffb
    80004ee8:	646080e7          	jalr	1606(ra) # 8000052a <panic>
    wakeup(&log);
    80004eec:	0002a497          	auipc	s1,0x2a
    80004ef0:	d8448493          	addi	s1,s1,-636 # 8002ec70 <log>
    80004ef4:	8526                	mv	a0,s1
    80004ef6:	ffffd097          	auipc	ra,0xffffd
    80004efa:	4c0080e7          	jalr	1216(ra) # 800023b6 <wakeup>
  release(&log.lock);
    80004efe:	8526                	mv	a0,s1
    80004f00:	ffffc097          	auipc	ra,0xffffc
    80004f04:	d76080e7          	jalr	-650(ra) # 80000c76 <release>
}
    80004f08:	70e2                	ld	ra,56(sp)
    80004f0a:	7442                	ld	s0,48(sp)
    80004f0c:	74a2                	ld	s1,40(sp)
    80004f0e:	7902                	ld	s2,32(sp)
    80004f10:	69e2                	ld	s3,24(sp)
    80004f12:	6a42                	ld	s4,16(sp)
    80004f14:	6aa2                	ld	s5,8(sp)
    80004f16:	6121                	addi	sp,sp,64
    80004f18:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004f1a:	0002aa97          	auipc	s5,0x2a
    80004f1e:	d86a8a93          	addi	s5,s5,-634 # 8002eca0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004f22:	0002aa17          	auipc	s4,0x2a
    80004f26:	d4ea0a13          	addi	s4,s4,-690 # 8002ec70 <log>
    80004f2a:	018a2583          	lw	a1,24(s4)
    80004f2e:	012585bb          	addw	a1,a1,s2
    80004f32:	2585                	addiw	a1,a1,1
    80004f34:	028a2503          	lw	a0,40(s4)
    80004f38:	fffff097          	auipc	ra,0xfffff
    80004f3c:	9ba080e7          	jalr	-1606(ra) # 800038f2 <bread>
    80004f40:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004f42:	000aa583          	lw	a1,0(s5)
    80004f46:	028a2503          	lw	a0,40(s4)
    80004f4a:	fffff097          	auipc	ra,0xfffff
    80004f4e:	9a8080e7          	jalr	-1624(ra) # 800038f2 <bread>
    80004f52:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004f54:	40000613          	li	a2,1024
    80004f58:	05850593          	addi	a1,a0,88
    80004f5c:	05848513          	addi	a0,s1,88
    80004f60:	ffffc097          	auipc	ra,0xffffc
    80004f64:	dba080e7          	jalr	-582(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004f68:	8526                	mv	a0,s1
    80004f6a:	fffff097          	auipc	ra,0xfffff
    80004f6e:	a7a080e7          	jalr	-1414(ra) # 800039e4 <bwrite>
    brelse(from);
    80004f72:	854e                	mv	a0,s3
    80004f74:	fffff097          	auipc	ra,0xfffff
    80004f78:	aae080e7          	jalr	-1362(ra) # 80003a22 <brelse>
    brelse(to);
    80004f7c:	8526                	mv	a0,s1
    80004f7e:	fffff097          	auipc	ra,0xfffff
    80004f82:	aa4080e7          	jalr	-1372(ra) # 80003a22 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004f86:	2905                	addiw	s2,s2,1
    80004f88:	0a91                	addi	s5,s5,4
    80004f8a:	02ca2783          	lw	a5,44(s4)
    80004f8e:	f8f94ee3          	blt	s2,a5,80004f2a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004f92:	00000097          	auipc	ra,0x0
    80004f96:	c66080e7          	jalr	-922(ra) # 80004bf8 <write_head>
    install_trans(0); // Now install writes to home locations
    80004f9a:	4501                	li	a0,0
    80004f9c:	00000097          	auipc	ra,0x0
    80004fa0:	cd8080e7          	jalr	-808(ra) # 80004c74 <install_trans>
    log.lh.n = 0;
    80004fa4:	0002a797          	auipc	a5,0x2a
    80004fa8:	ce07ac23          	sw	zero,-776(a5) # 8002ec9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004fac:	00000097          	auipc	ra,0x0
    80004fb0:	c4c080e7          	jalr	-948(ra) # 80004bf8 <write_head>
    80004fb4:	bdf5                	j	80004eb0 <end_op+0x52>

0000000080004fb6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004fb6:	1101                	addi	sp,sp,-32
    80004fb8:	ec06                	sd	ra,24(sp)
    80004fba:	e822                	sd	s0,16(sp)
    80004fbc:	e426                	sd	s1,8(sp)
    80004fbe:	e04a                	sd	s2,0(sp)
    80004fc0:	1000                	addi	s0,sp,32
    80004fc2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004fc4:	0002a917          	auipc	s2,0x2a
    80004fc8:	cac90913          	addi	s2,s2,-852 # 8002ec70 <log>
    80004fcc:	854a                	mv	a0,s2
    80004fce:	ffffc097          	auipc	ra,0xffffc
    80004fd2:	bf4080e7          	jalr	-1036(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004fd6:	02c92603          	lw	a2,44(s2)
    80004fda:	47f5                	li	a5,29
    80004fdc:	06c7c563          	blt	a5,a2,80005046 <log_write+0x90>
    80004fe0:	0002a797          	auipc	a5,0x2a
    80004fe4:	cac7a783          	lw	a5,-852(a5) # 8002ec8c <log+0x1c>
    80004fe8:	37fd                	addiw	a5,a5,-1
    80004fea:	04f65e63          	bge	a2,a5,80005046 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004fee:	0002a797          	auipc	a5,0x2a
    80004ff2:	ca27a783          	lw	a5,-862(a5) # 8002ec90 <log+0x20>
    80004ff6:	06f05063          	blez	a5,80005056 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004ffa:	4781                	li	a5,0
    80004ffc:	06c05563          	blez	a2,80005066 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80005000:	44cc                	lw	a1,12(s1)
    80005002:	0002a717          	auipc	a4,0x2a
    80005006:	c9e70713          	addi	a4,a4,-866 # 8002eca0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000500a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000500c:	4314                	lw	a3,0(a4)
    8000500e:	04b68c63          	beq	a3,a1,80005066 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80005012:	2785                	addiw	a5,a5,1
    80005014:	0711                	addi	a4,a4,4
    80005016:	fef61be3          	bne	a2,a5,8000500c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000501a:	0621                	addi	a2,a2,8
    8000501c:	060a                	slli	a2,a2,0x2
    8000501e:	0002a797          	auipc	a5,0x2a
    80005022:	c5278793          	addi	a5,a5,-942 # 8002ec70 <log>
    80005026:	963e                	add	a2,a2,a5
    80005028:	44dc                	lw	a5,12(s1)
    8000502a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000502c:	8526                	mv	a0,s1
    8000502e:	fffff097          	auipc	ra,0xfffff
    80005032:	a92080e7          	jalr	-1390(ra) # 80003ac0 <bpin>
    log.lh.n++;
    80005036:	0002a717          	auipc	a4,0x2a
    8000503a:	c3a70713          	addi	a4,a4,-966 # 8002ec70 <log>
    8000503e:	575c                	lw	a5,44(a4)
    80005040:	2785                	addiw	a5,a5,1
    80005042:	d75c                	sw	a5,44(a4)
    80005044:	a835                	j	80005080 <log_write+0xca>
    panic("too big a transaction");
    80005046:	00005517          	auipc	a0,0x5
    8000504a:	afa50513          	addi	a0,a0,-1286 # 80009b40 <syscalls+0x260>
    8000504e:	ffffb097          	auipc	ra,0xffffb
    80005052:	4dc080e7          	jalr	1244(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80005056:	00005517          	auipc	a0,0x5
    8000505a:	b0250513          	addi	a0,a0,-1278 # 80009b58 <syscalls+0x278>
    8000505e:	ffffb097          	auipc	ra,0xffffb
    80005062:	4cc080e7          	jalr	1228(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80005066:	00878713          	addi	a4,a5,8
    8000506a:	00271693          	slli	a3,a4,0x2
    8000506e:	0002a717          	auipc	a4,0x2a
    80005072:	c0270713          	addi	a4,a4,-1022 # 8002ec70 <log>
    80005076:	9736                	add	a4,a4,a3
    80005078:	44d4                	lw	a3,12(s1)
    8000507a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000507c:	faf608e3          	beq	a2,a5,8000502c <log_write+0x76>
  }
  release(&log.lock);
    80005080:	0002a517          	auipc	a0,0x2a
    80005084:	bf050513          	addi	a0,a0,-1040 # 8002ec70 <log>
    80005088:	ffffc097          	auipc	ra,0xffffc
    8000508c:	bee080e7          	jalr	-1042(ra) # 80000c76 <release>
}
    80005090:	60e2                	ld	ra,24(sp)
    80005092:	6442                	ld	s0,16(sp)
    80005094:	64a2                	ld	s1,8(sp)
    80005096:	6902                	ld	s2,0(sp)
    80005098:	6105                	addi	sp,sp,32
    8000509a:	8082                	ret

000000008000509c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000509c:	1101                	addi	sp,sp,-32
    8000509e:	ec06                	sd	ra,24(sp)
    800050a0:	e822                	sd	s0,16(sp)
    800050a2:	e426                	sd	s1,8(sp)
    800050a4:	e04a                	sd	s2,0(sp)
    800050a6:	1000                	addi	s0,sp,32
    800050a8:	84aa                	mv	s1,a0
    800050aa:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800050ac:	00005597          	auipc	a1,0x5
    800050b0:	acc58593          	addi	a1,a1,-1332 # 80009b78 <syscalls+0x298>
    800050b4:	0521                	addi	a0,a0,8
    800050b6:	ffffc097          	auipc	ra,0xffffc
    800050ba:	a7c080e7          	jalr	-1412(ra) # 80000b32 <initlock>
  lk->name = name;
    800050be:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800050c2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800050c6:	0204a423          	sw	zero,40(s1)
}
    800050ca:	60e2                	ld	ra,24(sp)
    800050cc:	6442                	ld	s0,16(sp)
    800050ce:	64a2                	ld	s1,8(sp)
    800050d0:	6902                	ld	s2,0(sp)
    800050d2:	6105                	addi	sp,sp,32
    800050d4:	8082                	ret

00000000800050d6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800050d6:	1101                	addi	sp,sp,-32
    800050d8:	ec06                	sd	ra,24(sp)
    800050da:	e822                	sd	s0,16(sp)
    800050dc:	e426                	sd	s1,8(sp)
    800050de:	e04a                	sd	s2,0(sp)
    800050e0:	1000                	addi	s0,sp,32
    800050e2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800050e4:	00850913          	addi	s2,a0,8
    800050e8:	854a                	mv	a0,s2
    800050ea:	ffffc097          	auipc	ra,0xffffc
    800050ee:	ad8080e7          	jalr	-1320(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    800050f2:	409c                	lw	a5,0(s1)
    800050f4:	cb89                	beqz	a5,80005106 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800050f6:	85ca                	mv	a1,s2
    800050f8:	8526                	mv	a0,s1
    800050fa:	ffffd097          	auipc	ra,0xffffd
    800050fe:	130080e7          	jalr	304(ra) # 8000222a <sleep>
  while (lk->locked) {
    80005102:	409c                	lw	a5,0(s1)
    80005104:	fbed                	bnez	a5,800050f6 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80005106:	4785                	li	a5,1
    80005108:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000510a:	ffffd097          	auipc	ra,0xffffd
    8000510e:	c28080e7          	jalr	-984(ra) # 80001d32 <myproc>
    80005112:	591c                	lw	a5,48(a0)
    80005114:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005116:	854a                	mv	a0,s2
    80005118:	ffffc097          	auipc	ra,0xffffc
    8000511c:	b5e080e7          	jalr	-1186(ra) # 80000c76 <release>
}
    80005120:	60e2                	ld	ra,24(sp)
    80005122:	6442                	ld	s0,16(sp)
    80005124:	64a2                	ld	s1,8(sp)
    80005126:	6902                	ld	s2,0(sp)
    80005128:	6105                	addi	sp,sp,32
    8000512a:	8082                	ret

000000008000512c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000512c:	1101                	addi	sp,sp,-32
    8000512e:	ec06                	sd	ra,24(sp)
    80005130:	e822                	sd	s0,16(sp)
    80005132:	e426                	sd	s1,8(sp)
    80005134:	e04a                	sd	s2,0(sp)
    80005136:	1000                	addi	s0,sp,32
    80005138:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000513a:	00850913          	addi	s2,a0,8
    8000513e:	854a                	mv	a0,s2
    80005140:	ffffc097          	auipc	ra,0xffffc
    80005144:	a82080e7          	jalr	-1406(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80005148:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000514c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80005150:	8526                	mv	a0,s1
    80005152:	ffffd097          	auipc	ra,0xffffd
    80005156:	264080e7          	jalr	612(ra) # 800023b6 <wakeup>
  release(&lk->lk);
    8000515a:	854a                	mv	a0,s2
    8000515c:	ffffc097          	auipc	ra,0xffffc
    80005160:	b1a080e7          	jalr	-1254(ra) # 80000c76 <release>
}
    80005164:	60e2                	ld	ra,24(sp)
    80005166:	6442                	ld	s0,16(sp)
    80005168:	64a2                	ld	s1,8(sp)
    8000516a:	6902                	ld	s2,0(sp)
    8000516c:	6105                	addi	sp,sp,32
    8000516e:	8082                	ret

0000000080005170 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80005170:	7179                	addi	sp,sp,-48
    80005172:	f406                	sd	ra,40(sp)
    80005174:	f022                	sd	s0,32(sp)
    80005176:	ec26                	sd	s1,24(sp)
    80005178:	e84a                	sd	s2,16(sp)
    8000517a:	e44e                	sd	s3,8(sp)
    8000517c:	1800                	addi	s0,sp,48
    8000517e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80005180:	00850913          	addi	s2,a0,8
    80005184:	854a                	mv	a0,s2
    80005186:	ffffc097          	auipc	ra,0xffffc
    8000518a:	a3c080e7          	jalr	-1476(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000518e:	409c                	lw	a5,0(s1)
    80005190:	ef99                	bnez	a5,800051ae <holdingsleep+0x3e>
    80005192:	4481                	li	s1,0
  release(&lk->lk);
    80005194:	854a                	mv	a0,s2
    80005196:	ffffc097          	auipc	ra,0xffffc
    8000519a:	ae0080e7          	jalr	-1312(ra) # 80000c76 <release>
  return r;
}
    8000519e:	8526                	mv	a0,s1
    800051a0:	70a2                	ld	ra,40(sp)
    800051a2:	7402                	ld	s0,32(sp)
    800051a4:	64e2                	ld	s1,24(sp)
    800051a6:	6942                	ld	s2,16(sp)
    800051a8:	69a2                	ld	s3,8(sp)
    800051aa:	6145                	addi	sp,sp,48
    800051ac:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800051ae:	0284a983          	lw	s3,40(s1)
    800051b2:	ffffd097          	auipc	ra,0xffffd
    800051b6:	b80080e7          	jalr	-1152(ra) # 80001d32 <myproc>
    800051ba:	5904                	lw	s1,48(a0)
    800051bc:	413484b3          	sub	s1,s1,s3
    800051c0:	0014b493          	seqz	s1,s1
    800051c4:	bfc1                	j	80005194 <holdingsleep+0x24>

00000000800051c6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800051c6:	1141                	addi	sp,sp,-16
    800051c8:	e406                	sd	ra,8(sp)
    800051ca:	e022                	sd	s0,0(sp)
    800051cc:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800051ce:	00005597          	auipc	a1,0x5
    800051d2:	9ba58593          	addi	a1,a1,-1606 # 80009b88 <syscalls+0x2a8>
    800051d6:	0002a517          	auipc	a0,0x2a
    800051da:	be250513          	addi	a0,a0,-1054 # 8002edb8 <ftable>
    800051de:	ffffc097          	auipc	ra,0xffffc
    800051e2:	954080e7          	jalr	-1708(ra) # 80000b32 <initlock>
}
    800051e6:	60a2                	ld	ra,8(sp)
    800051e8:	6402                	ld	s0,0(sp)
    800051ea:	0141                	addi	sp,sp,16
    800051ec:	8082                	ret

00000000800051ee <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800051ee:	1101                	addi	sp,sp,-32
    800051f0:	ec06                	sd	ra,24(sp)
    800051f2:	e822                	sd	s0,16(sp)
    800051f4:	e426                	sd	s1,8(sp)
    800051f6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800051f8:	0002a517          	auipc	a0,0x2a
    800051fc:	bc050513          	addi	a0,a0,-1088 # 8002edb8 <ftable>
    80005200:	ffffc097          	auipc	ra,0xffffc
    80005204:	9c2080e7          	jalr	-1598(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005208:	0002a497          	auipc	s1,0x2a
    8000520c:	bc848493          	addi	s1,s1,-1080 # 8002edd0 <ftable+0x18>
    80005210:	0002b717          	auipc	a4,0x2b
    80005214:	b6070713          	addi	a4,a4,-1184 # 8002fd70 <ftable+0xfb8>
    if(f->ref == 0){
    80005218:	40dc                	lw	a5,4(s1)
    8000521a:	cf99                	beqz	a5,80005238 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000521c:	02848493          	addi	s1,s1,40
    80005220:	fee49ce3          	bne	s1,a4,80005218 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005224:	0002a517          	auipc	a0,0x2a
    80005228:	b9450513          	addi	a0,a0,-1132 # 8002edb8 <ftable>
    8000522c:	ffffc097          	auipc	ra,0xffffc
    80005230:	a4a080e7          	jalr	-1462(ra) # 80000c76 <release>
  return 0;
    80005234:	4481                	li	s1,0
    80005236:	a819                	j	8000524c <filealloc+0x5e>
      f->ref = 1;
    80005238:	4785                	li	a5,1
    8000523a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000523c:	0002a517          	auipc	a0,0x2a
    80005240:	b7c50513          	addi	a0,a0,-1156 # 8002edb8 <ftable>
    80005244:	ffffc097          	auipc	ra,0xffffc
    80005248:	a32080e7          	jalr	-1486(ra) # 80000c76 <release>
}
    8000524c:	8526                	mv	a0,s1
    8000524e:	60e2                	ld	ra,24(sp)
    80005250:	6442                	ld	s0,16(sp)
    80005252:	64a2                	ld	s1,8(sp)
    80005254:	6105                	addi	sp,sp,32
    80005256:	8082                	ret

0000000080005258 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005258:	1101                	addi	sp,sp,-32
    8000525a:	ec06                	sd	ra,24(sp)
    8000525c:	e822                	sd	s0,16(sp)
    8000525e:	e426                	sd	s1,8(sp)
    80005260:	1000                	addi	s0,sp,32
    80005262:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005264:	0002a517          	auipc	a0,0x2a
    80005268:	b5450513          	addi	a0,a0,-1196 # 8002edb8 <ftable>
    8000526c:	ffffc097          	auipc	ra,0xffffc
    80005270:	956080e7          	jalr	-1706(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80005274:	40dc                	lw	a5,4(s1)
    80005276:	02f05263          	blez	a5,8000529a <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000527a:	2785                	addiw	a5,a5,1
    8000527c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000527e:	0002a517          	auipc	a0,0x2a
    80005282:	b3a50513          	addi	a0,a0,-1222 # 8002edb8 <ftable>
    80005286:	ffffc097          	auipc	ra,0xffffc
    8000528a:	9f0080e7          	jalr	-1552(ra) # 80000c76 <release>
  return f;
}
    8000528e:	8526                	mv	a0,s1
    80005290:	60e2                	ld	ra,24(sp)
    80005292:	6442                	ld	s0,16(sp)
    80005294:	64a2                	ld	s1,8(sp)
    80005296:	6105                	addi	sp,sp,32
    80005298:	8082                	ret
    panic("filedup");
    8000529a:	00005517          	auipc	a0,0x5
    8000529e:	8f650513          	addi	a0,a0,-1802 # 80009b90 <syscalls+0x2b0>
    800052a2:	ffffb097          	auipc	ra,0xffffb
    800052a6:	288080e7          	jalr	648(ra) # 8000052a <panic>

00000000800052aa <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800052aa:	7139                	addi	sp,sp,-64
    800052ac:	fc06                	sd	ra,56(sp)
    800052ae:	f822                	sd	s0,48(sp)
    800052b0:	f426                	sd	s1,40(sp)
    800052b2:	f04a                	sd	s2,32(sp)
    800052b4:	ec4e                	sd	s3,24(sp)
    800052b6:	e852                	sd	s4,16(sp)
    800052b8:	e456                	sd	s5,8(sp)
    800052ba:	0080                	addi	s0,sp,64
    800052bc:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800052be:	0002a517          	auipc	a0,0x2a
    800052c2:	afa50513          	addi	a0,a0,-1286 # 8002edb8 <ftable>
    800052c6:	ffffc097          	auipc	ra,0xffffc
    800052ca:	8fc080e7          	jalr	-1796(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    800052ce:	40dc                	lw	a5,4(s1)
    800052d0:	06f05163          	blez	a5,80005332 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800052d4:	37fd                	addiw	a5,a5,-1
    800052d6:	0007871b          	sext.w	a4,a5
    800052da:	c0dc                	sw	a5,4(s1)
    800052dc:	06e04363          	bgtz	a4,80005342 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800052e0:	0004a903          	lw	s2,0(s1)
    800052e4:	0094ca83          	lbu	s5,9(s1)
    800052e8:	0104ba03          	ld	s4,16(s1)
    800052ec:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800052f0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800052f4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800052f8:	0002a517          	auipc	a0,0x2a
    800052fc:	ac050513          	addi	a0,a0,-1344 # 8002edb8 <ftable>
    80005300:	ffffc097          	auipc	ra,0xffffc
    80005304:	976080e7          	jalr	-1674(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    80005308:	4785                	li	a5,1
    8000530a:	04f90d63          	beq	s2,a5,80005364 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000530e:	3979                	addiw	s2,s2,-2
    80005310:	4785                	li	a5,1
    80005312:	0527e063          	bltu	a5,s2,80005352 <fileclose+0xa8>
    begin_op();
    80005316:	00000097          	auipc	ra,0x0
    8000531a:	ac8080e7          	jalr	-1336(ra) # 80004dde <begin_op>
    iput(ff.ip);
    8000531e:	854e                	mv	a0,s3
    80005320:	fffff097          	auipc	ra,0xfffff
    80005324:	f90080e7          	jalr	-112(ra) # 800042b0 <iput>
    end_op();
    80005328:	00000097          	auipc	ra,0x0
    8000532c:	b36080e7          	jalr	-1226(ra) # 80004e5e <end_op>
    80005330:	a00d                	j	80005352 <fileclose+0xa8>
    panic("fileclose");
    80005332:	00005517          	auipc	a0,0x5
    80005336:	86650513          	addi	a0,a0,-1946 # 80009b98 <syscalls+0x2b8>
    8000533a:	ffffb097          	auipc	ra,0xffffb
    8000533e:	1f0080e7          	jalr	496(ra) # 8000052a <panic>
    release(&ftable.lock);
    80005342:	0002a517          	auipc	a0,0x2a
    80005346:	a7650513          	addi	a0,a0,-1418 # 8002edb8 <ftable>
    8000534a:	ffffc097          	auipc	ra,0xffffc
    8000534e:	92c080e7          	jalr	-1748(ra) # 80000c76 <release>
  }
}
    80005352:	70e2                	ld	ra,56(sp)
    80005354:	7442                	ld	s0,48(sp)
    80005356:	74a2                	ld	s1,40(sp)
    80005358:	7902                	ld	s2,32(sp)
    8000535a:	69e2                	ld	s3,24(sp)
    8000535c:	6a42                	ld	s4,16(sp)
    8000535e:	6aa2                	ld	s5,8(sp)
    80005360:	6121                	addi	sp,sp,64
    80005362:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005364:	85d6                	mv	a1,s5
    80005366:	8552                	mv	a0,s4
    80005368:	00000097          	auipc	ra,0x0
    8000536c:	542080e7          	jalr	1346(ra) # 800058aa <pipeclose>
    80005370:	b7cd                	j	80005352 <fileclose+0xa8>

0000000080005372 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005372:	715d                	addi	sp,sp,-80
    80005374:	e486                	sd	ra,72(sp)
    80005376:	e0a2                	sd	s0,64(sp)
    80005378:	fc26                	sd	s1,56(sp)
    8000537a:	f84a                	sd	s2,48(sp)
    8000537c:	f44e                	sd	s3,40(sp)
    8000537e:	0880                	addi	s0,sp,80
    80005380:	84aa                	mv	s1,a0
    80005382:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005384:	ffffd097          	auipc	ra,0xffffd
    80005388:	9ae080e7          	jalr	-1618(ra) # 80001d32 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000538c:	409c                	lw	a5,0(s1)
    8000538e:	37f9                	addiw	a5,a5,-2
    80005390:	4705                	li	a4,1
    80005392:	04f76763          	bltu	a4,a5,800053e0 <filestat+0x6e>
    80005396:	892a                	mv	s2,a0
    ilock(f->ip);
    80005398:	6c88                	ld	a0,24(s1)
    8000539a:	fffff097          	auipc	ra,0xfffff
    8000539e:	d5c080e7          	jalr	-676(ra) # 800040f6 <ilock>
    stati(f->ip, &st);
    800053a2:	fb840593          	addi	a1,s0,-72
    800053a6:	6c88                	ld	a0,24(s1)
    800053a8:	fffff097          	auipc	ra,0xfffff
    800053ac:	fd8080e7          	jalr	-40(ra) # 80004380 <stati>
    iunlock(f->ip);
    800053b0:	6c88                	ld	a0,24(s1)
    800053b2:	fffff097          	auipc	ra,0xfffff
    800053b6:	e06080e7          	jalr	-506(ra) # 800041b8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800053ba:	46e1                	li	a3,24
    800053bc:	fb840613          	addi	a2,s0,-72
    800053c0:	85ce                	mv	a1,s3
    800053c2:	05093503          	ld	a0,80(s2)
    800053c6:	ffffc097          	auipc	ra,0xffffc
    800053ca:	fe4080e7          	jalr	-28(ra) # 800013aa <copyout>
    800053ce:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800053d2:	60a6                	ld	ra,72(sp)
    800053d4:	6406                	ld	s0,64(sp)
    800053d6:	74e2                	ld	s1,56(sp)
    800053d8:	7942                	ld	s2,48(sp)
    800053da:	79a2                	ld	s3,40(sp)
    800053dc:	6161                	addi	sp,sp,80
    800053de:	8082                	ret
  return -1;
    800053e0:	557d                	li	a0,-1
    800053e2:	bfc5                	j	800053d2 <filestat+0x60>

00000000800053e4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800053e4:	7179                	addi	sp,sp,-48
    800053e6:	f406                	sd	ra,40(sp)
    800053e8:	f022                	sd	s0,32(sp)
    800053ea:	ec26                	sd	s1,24(sp)
    800053ec:	e84a                	sd	s2,16(sp)
    800053ee:	e44e                	sd	s3,8(sp)
    800053f0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800053f2:	00854783          	lbu	a5,8(a0)
    800053f6:	c3d5                	beqz	a5,8000549a <fileread+0xb6>
    800053f8:	84aa                	mv	s1,a0
    800053fa:	89ae                	mv	s3,a1
    800053fc:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800053fe:	411c                	lw	a5,0(a0)
    80005400:	4705                	li	a4,1
    80005402:	04e78963          	beq	a5,a4,80005454 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005406:	470d                	li	a4,3
    80005408:	04e78d63          	beq	a5,a4,80005462 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000540c:	4709                	li	a4,2
    8000540e:	06e79e63          	bne	a5,a4,8000548a <fileread+0xa6>
    ilock(f->ip);
    80005412:	6d08                	ld	a0,24(a0)
    80005414:	fffff097          	auipc	ra,0xfffff
    80005418:	ce2080e7          	jalr	-798(ra) # 800040f6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000541c:	874a                	mv	a4,s2
    8000541e:	5094                	lw	a3,32(s1)
    80005420:	864e                	mv	a2,s3
    80005422:	4585                	li	a1,1
    80005424:	6c88                	ld	a0,24(s1)
    80005426:	fffff097          	auipc	ra,0xfffff
    8000542a:	f84080e7          	jalr	-124(ra) # 800043aa <readi>
    8000542e:	892a                	mv	s2,a0
    80005430:	00a05563          	blez	a0,8000543a <fileread+0x56>
      f->off += r;
    80005434:	509c                	lw	a5,32(s1)
    80005436:	9fa9                	addw	a5,a5,a0
    80005438:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000543a:	6c88                	ld	a0,24(s1)
    8000543c:	fffff097          	auipc	ra,0xfffff
    80005440:	d7c080e7          	jalr	-644(ra) # 800041b8 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005444:	854a                	mv	a0,s2
    80005446:	70a2                	ld	ra,40(sp)
    80005448:	7402                	ld	s0,32(sp)
    8000544a:	64e2                	ld	s1,24(sp)
    8000544c:	6942                	ld	s2,16(sp)
    8000544e:	69a2                	ld	s3,8(sp)
    80005450:	6145                	addi	sp,sp,48
    80005452:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005454:	6908                	ld	a0,16(a0)
    80005456:	00000097          	auipc	ra,0x0
    8000545a:	5b6080e7          	jalr	1462(ra) # 80005a0c <piperead>
    8000545e:	892a                	mv	s2,a0
    80005460:	b7d5                	j	80005444 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005462:	02451783          	lh	a5,36(a0)
    80005466:	03079693          	slli	a3,a5,0x30
    8000546a:	92c1                	srli	a3,a3,0x30
    8000546c:	4725                	li	a4,9
    8000546e:	02d76863          	bltu	a4,a3,8000549e <fileread+0xba>
    80005472:	0792                	slli	a5,a5,0x4
    80005474:	0002a717          	auipc	a4,0x2a
    80005478:	8a470713          	addi	a4,a4,-1884 # 8002ed18 <devsw>
    8000547c:	97ba                	add	a5,a5,a4
    8000547e:	639c                	ld	a5,0(a5)
    80005480:	c38d                	beqz	a5,800054a2 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005482:	4505                	li	a0,1
    80005484:	9782                	jalr	a5
    80005486:	892a                	mv	s2,a0
    80005488:	bf75                	j	80005444 <fileread+0x60>
    panic("fileread");
    8000548a:	00004517          	auipc	a0,0x4
    8000548e:	71e50513          	addi	a0,a0,1822 # 80009ba8 <syscalls+0x2c8>
    80005492:	ffffb097          	auipc	ra,0xffffb
    80005496:	098080e7          	jalr	152(ra) # 8000052a <panic>
    return -1;
    8000549a:	597d                	li	s2,-1
    8000549c:	b765                	j	80005444 <fileread+0x60>
      return -1;
    8000549e:	597d                	li	s2,-1
    800054a0:	b755                	j	80005444 <fileread+0x60>
    800054a2:	597d                	li	s2,-1
    800054a4:	b745                	j	80005444 <fileread+0x60>

00000000800054a6 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800054a6:	715d                	addi	sp,sp,-80
    800054a8:	e486                	sd	ra,72(sp)
    800054aa:	e0a2                	sd	s0,64(sp)
    800054ac:	fc26                	sd	s1,56(sp)
    800054ae:	f84a                	sd	s2,48(sp)
    800054b0:	f44e                	sd	s3,40(sp)
    800054b2:	f052                	sd	s4,32(sp)
    800054b4:	ec56                	sd	s5,24(sp)
    800054b6:	e85a                	sd	s6,16(sp)
    800054b8:	e45e                	sd	s7,8(sp)
    800054ba:	e062                	sd	s8,0(sp)
    800054bc:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800054be:	00954783          	lbu	a5,9(a0)
    800054c2:	10078663          	beqz	a5,800055ce <filewrite+0x128>
    800054c6:	892a                	mv	s2,a0
    800054c8:	8aae                	mv	s5,a1
    800054ca:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800054cc:	411c                	lw	a5,0(a0)
    800054ce:	4705                	li	a4,1
    800054d0:	02e78263          	beq	a5,a4,800054f4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800054d4:	470d                	li	a4,3
    800054d6:	02e78663          	beq	a5,a4,80005502 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800054da:	4709                	li	a4,2
    800054dc:	0ee79163          	bne	a5,a4,800055be <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800054e0:	0ac05d63          	blez	a2,8000559a <filewrite+0xf4>
    int i = 0;
    800054e4:	4981                	li	s3,0
    800054e6:	6b05                	lui	s6,0x1
    800054e8:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800054ec:	6b85                	lui	s7,0x1
    800054ee:	c00b8b9b          	addiw	s7,s7,-1024
    800054f2:	a861                	j	8000558a <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800054f4:	6908                	ld	a0,16(a0)
    800054f6:	00000097          	auipc	ra,0x0
    800054fa:	424080e7          	jalr	1060(ra) # 8000591a <pipewrite>
    800054fe:	8a2a                	mv	s4,a0
    80005500:	a045                	j	800055a0 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005502:	02451783          	lh	a5,36(a0)
    80005506:	03079693          	slli	a3,a5,0x30
    8000550a:	92c1                	srli	a3,a3,0x30
    8000550c:	4725                	li	a4,9
    8000550e:	0cd76263          	bltu	a4,a3,800055d2 <filewrite+0x12c>
    80005512:	0792                	slli	a5,a5,0x4
    80005514:	0002a717          	auipc	a4,0x2a
    80005518:	80470713          	addi	a4,a4,-2044 # 8002ed18 <devsw>
    8000551c:	97ba                	add	a5,a5,a4
    8000551e:	679c                	ld	a5,8(a5)
    80005520:	cbdd                	beqz	a5,800055d6 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005522:	4505                	li	a0,1
    80005524:	9782                	jalr	a5
    80005526:	8a2a                	mv	s4,a0
    80005528:	a8a5                	j	800055a0 <filewrite+0xfa>
    8000552a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000552e:	00000097          	auipc	ra,0x0
    80005532:	8b0080e7          	jalr	-1872(ra) # 80004dde <begin_op>
      ilock(f->ip);
    80005536:	01893503          	ld	a0,24(s2)
    8000553a:	fffff097          	auipc	ra,0xfffff
    8000553e:	bbc080e7          	jalr	-1092(ra) # 800040f6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005542:	8762                	mv	a4,s8
    80005544:	02092683          	lw	a3,32(s2)
    80005548:	01598633          	add	a2,s3,s5
    8000554c:	4585                	li	a1,1
    8000554e:	01893503          	ld	a0,24(s2)
    80005552:	fffff097          	auipc	ra,0xfffff
    80005556:	f50080e7          	jalr	-176(ra) # 800044a2 <writei>
    8000555a:	84aa                	mv	s1,a0
    8000555c:	00a05763          	blez	a0,8000556a <filewrite+0xc4>
        f->off += r;
    80005560:	02092783          	lw	a5,32(s2)
    80005564:	9fa9                	addw	a5,a5,a0
    80005566:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000556a:	01893503          	ld	a0,24(s2)
    8000556e:	fffff097          	auipc	ra,0xfffff
    80005572:	c4a080e7          	jalr	-950(ra) # 800041b8 <iunlock>
      end_op();
    80005576:	00000097          	auipc	ra,0x0
    8000557a:	8e8080e7          	jalr	-1816(ra) # 80004e5e <end_op>

      if(r != n1){
    8000557e:	009c1f63          	bne	s8,s1,8000559c <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005582:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005586:	0149db63          	bge	s3,s4,8000559c <filewrite+0xf6>
      int n1 = n - i;
    8000558a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000558e:	84be                	mv	s1,a5
    80005590:	2781                	sext.w	a5,a5
    80005592:	f8fb5ce3          	bge	s6,a5,8000552a <filewrite+0x84>
    80005596:	84de                	mv	s1,s7
    80005598:	bf49                	j	8000552a <filewrite+0x84>
    int i = 0;
    8000559a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000559c:	013a1f63          	bne	s4,s3,800055ba <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800055a0:	8552                	mv	a0,s4
    800055a2:	60a6                	ld	ra,72(sp)
    800055a4:	6406                	ld	s0,64(sp)
    800055a6:	74e2                	ld	s1,56(sp)
    800055a8:	7942                	ld	s2,48(sp)
    800055aa:	79a2                	ld	s3,40(sp)
    800055ac:	7a02                	ld	s4,32(sp)
    800055ae:	6ae2                	ld	s5,24(sp)
    800055b0:	6b42                	ld	s6,16(sp)
    800055b2:	6ba2                	ld	s7,8(sp)
    800055b4:	6c02                	ld	s8,0(sp)
    800055b6:	6161                	addi	sp,sp,80
    800055b8:	8082                	ret
    ret = (i == n ? n : -1);
    800055ba:	5a7d                	li	s4,-1
    800055bc:	b7d5                	j	800055a0 <filewrite+0xfa>
    panic("filewrite");
    800055be:	00004517          	auipc	a0,0x4
    800055c2:	5fa50513          	addi	a0,a0,1530 # 80009bb8 <syscalls+0x2d8>
    800055c6:	ffffb097          	auipc	ra,0xffffb
    800055ca:	f64080e7          	jalr	-156(ra) # 8000052a <panic>
    return -1;
    800055ce:	5a7d                	li	s4,-1
    800055d0:	bfc1                	j	800055a0 <filewrite+0xfa>
      return -1;
    800055d2:	5a7d                	li	s4,-1
    800055d4:	b7f1                	j	800055a0 <filewrite+0xfa>
    800055d6:	5a7d                	li	s4,-1
    800055d8:	b7e1                	j	800055a0 <filewrite+0xfa>

00000000800055da <kfileread>:

// Read from file f.
// addr is a kernel virtual address.
int
kfileread(struct file *f, uint64 addr, int n)
{
    800055da:	7179                	addi	sp,sp,-48
    800055dc:	f406                	sd	ra,40(sp)
    800055de:	f022                	sd	s0,32(sp)
    800055e0:	ec26                	sd	s1,24(sp)
    800055e2:	e84a                	sd	s2,16(sp)
    800055e4:	e44e                	sd	s3,8(sp)
    800055e6:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800055e8:	00854783          	lbu	a5,8(a0)
    800055ec:	c3d5                	beqz	a5,80005690 <kfileread+0xb6>
    800055ee:	84aa                	mv	s1,a0
    800055f0:	89ae                	mv	s3,a1
    800055f2:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800055f4:	411c                	lw	a5,0(a0)
    800055f6:	4705                	li	a4,1
    800055f8:	04e78963          	beq	a5,a4,8000564a <kfileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800055fc:	470d                	li	a4,3
    800055fe:	04e78d63          	beq	a5,a4,80005658 <kfileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005602:	4709                	li	a4,2
    80005604:	06e79e63          	bne	a5,a4,80005680 <kfileread+0xa6>
    ilock(f->ip);
    80005608:	6d08                	ld	a0,24(a0)
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	aec080e7          	jalr	-1300(ra) # 800040f6 <ilock>
    if((r = readi(f->ip, 0, addr, f->off, n)) > 0)
    80005612:	874a                	mv	a4,s2
    80005614:	5094                	lw	a3,32(s1)
    80005616:	864e                	mv	a2,s3
    80005618:	4581                	li	a1,0
    8000561a:	6c88                	ld	a0,24(s1)
    8000561c:	fffff097          	auipc	ra,0xfffff
    80005620:	d8e080e7          	jalr	-626(ra) # 800043aa <readi>
    80005624:	892a                	mv	s2,a0
    80005626:	00a05563          	blez	a0,80005630 <kfileread+0x56>
      f->off += r;
    8000562a:	509c                	lw	a5,32(s1)
    8000562c:	9fa9                	addw	a5,a5,a0
    8000562e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005630:	6c88                	ld	a0,24(s1)
    80005632:	fffff097          	auipc	ra,0xfffff
    80005636:	b86080e7          	jalr	-1146(ra) # 800041b8 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000563a:	854a                	mv	a0,s2
    8000563c:	70a2                	ld	ra,40(sp)
    8000563e:	7402                	ld	s0,32(sp)
    80005640:	64e2                	ld	s1,24(sp)
    80005642:	6942                	ld	s2,16(sp)
    80005644:	69a2                	ld	s3,8(sp)
    80005646:	6145                	addi	sp,sp,48
    80005648:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000564a:	6908                	ld	a0,16(a0)
    8000564c:	00000097          	auipc	ra,0x0
    80005650:	3c0080e7          	jalr	960(ra) # 80005a0c <piperead>
    80005654:	892a                	mv	s2,a0
    80005656:	b7d5                	j	8000563a <kfileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005658:	02451783          	lh	a5,36(a0)
    8000565c:	03079693          	slli	a3,a5,0x30
    80005660:	92c1                	srli	a3,a3,0x30
    80005662:	4725                	li	a4,9
    80005664:	02d76863          	bltu	a4,a3,80005694 <kfileread+0xba>
    80005668:	0792                	slli	a5,a5,0x4
    8000566a:	00029717          	auipc	a4,0x29
    8000566e:	6ae70713          	addi	a4,a4,1710 # 8002ed18 <devsw>
    80005672:	97ba                	add	a5,a5,a4
    80005674:	639c                	ld	a5,0(a5)
    80005676:	c38d                	beqz	a5,80005698 <kfileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005678:	4505                	li	a0,1
    8000567a:	9782                	jalr	a5
    8000567c:	892a                	mv	s2,a0
    8000567e:	bf75                	j	8000563a <kfileread+0x60>
    panic("fileread");
    80005680:	00004517          	auipc	a0,0x4
    80005684:	52850513          	addi	a0,a0,1320 # 80009ba8 <syscalls+0x2c8>
    80005688:	ffffb097          	auipc	ra,0xffffb
    8000568c:	ea2080e7          	jalr	-350(ra) # 8000052a <panic>
    return -1;
    80005690:	597d                	li	s2,-1
    80005692:	b765                	j	8000563a <kfileread+0x60>
      return -1;
    80005694:	597d                	li	s2,-1
    80005696:	b755                	j	8000563a <kfileread+0x60>
    80005698:	597d                	li	s2,-1
    8000569a:	b745                	j	8000563a <kfileread+0x60>

000000008000569c <kfilewrite>:

// Write to file f.
// addr is a kernel virtual address.
int
kfilewrite(struct file *f, uint64 addr, int n)
{
    8000569c:	715d                	addi	sp,sp,-80
    8000569e:	e486                	sd	ra,72(sp)
    800056a0:	e0a2                	sd	s0,64(sp)
    800056a2:	fc26                	sd	s1,56(sp)
    800056a4:	f84a                	sd	s2,48(sp)
    800056a6:	f44e                	sd	s3,40(sp)
    800056a8:	f052                	sd	s4,32(sp)
    800056aa:	ec56                	sd	s5,24(sp)
    800056ac:	e85a                	sd	s6,16(sp)
    800056ae:	e45e                	sd	s7,8(sp)
    800056b0:	e062                	sd	s8,0(sp)
    800056b2:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800056b4:	00954783          	lbu	a5,9(a0)
    800056b8:	10078663          	beqz	a5,800057c4 <kfilewrite+0x128>
    800056bc:	892a                	mv	s2,a0
    800056be:	8aae                	mv	s5,a1
    800056c0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800056c2:	411c                	lw	a5,0(a0)
    800056c4:	4705                	li	a4,1
    800056c6:	02e78263          	beq	a5,a4,800056ea <kfilewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800056ca:	470d                	li	a4,3
    800056cc:	02e78663          	beq	a5,a4,800056f8 <kfilewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800056d0:	4709                	li	a4,2
    800056d2:	0ee79163          	bne	a5,a4,800057b4 <kfilewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800056d6:	0ac05d63          	blez	a2,80005790 <kfilewrite+0xf4>
    int i = 0;
    800056da:	4981                	li	s3,0
    800056dc:	6b05                	lui	s6,0x1
    800056de:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800056e2:	6b85                	lui	s7,0x1
    800056e4:	c00b8b9b          	addiw	s7,s7,-1024
    800056e8:	a861                	j	80005780 <kfilewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800056ea:	6908                	ld	a0,16(a0)
    800056ec:	00000097          	auipc	ra,0x0
    800056f0:	22e080e7          	jalr	558(ra) # 8000591a <pipewrite>
    800056f4:	8a2a                	mv	s4,a0
    800056f6:	a045                	j	80005796 <kfilewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800056f8:	02451783          	lh	a5,36(a0)
    800056fc:	03079693          	slli	a3,a5,0x30
    80005700:	92c1                	srli	a3,a3,0x30
    80005702:	4725                	li	a4,9
    80005704:	0cd76263          	bltu	a4,a3,800057c8 <kfilewrite+0x12c>
    80005708:	0792                	slli	a5,a5,0x4
    8000570a:	00029717          	auipc	a4,0x29
    8000570e:	60e70713          	addi	a4,a4,1550 # 8002ed18 <devsw>
    80005712:	97ba                	add	a5,a5,a4
    80005714:	679c                	ld	a5,8(a5)
    80005716:	cbdd                	beqz	a5,800057cc <kfilewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005718:	4505                	li	a0,1
    8000571a:	9782                	jalr	a5
    8000571c:	8a2a                	mv	s4,a0
    8000571e:	a8a5                	j	80005796 <kfilewrite+0xfa>
    80005720:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005724:	fffff097          	auipc	ra,0xfffff
    80005728:	6ba080e7          	jalr	1722(ra) # 80004dde <begin_op>
      ilock(f->ip);
    8000572c:	01893503          	ld	a0,24(s2)
    80005730:	fffff097          	auipc	ra,0xfffff
    80005734:	9c6080e7          	jalr	-1594(ra) # 800040f6 <ilock>
      if ((r = writei(f->ip, 0, addr + i, f->off, n1)) > 0)
    80005738:	8762                	mv	a4,s8
    8000573a:	02092683          	lw	a3,32(s2)
    8000573e:	01598633          	add	a2,s3,s5
    80005742:	4581                	li	a1,0
    80005744:	01893503          	ld	a0,24(s2)
    80005748:	fffff097          	auipc	ra,0xfffff
    8000574c:	d5a080e7          	jalr	-678(ra) # 800044a2 <writei>
    80005750:	84aa                	mv	s1,a0
    80005752:	00a05763          	blez	a0,80005760 <kfilewrite+0xc4>
        f->off += r;
    80005756:	02092783          	lw	a5,32(s2)
    8000575a:	9fa9                	addw	a5,a5,a0
    8000575c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005760:	01893503          	ld	a0,24(s2)
    80005764:	fffff097          	auipc	ra,0xfffff
    80005768:	a54080e7          	jalr	-1452(ra) # 800041b8 <iunlock>
      end_op();
    8000576c:	fffff097          	auipc	ra,0xfffff
    80005770:	6f2080e7          	jalr	1778(ra) # 80004e5e <end_op>

      if(r != n1){
    80005774:	009c1f63          	bne	s8,s1,80005792 <kfilewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005778:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000577c:	0149db63          	bge	s3,s4,80005792 <kfilewrite+0xf6>
      int n1 = n - i;
    80005780:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005784:	84be                	mv	s1,a5
    80005786:	2781                	sext.w	a5,a5
    80005788:	f8fb5ce3          	bge	s6,a5,80005720 <kfilewrite+0x84>
    8000578c:	84de                	mv	s1,s7
    8000578e:	bf49                	j	80005720 <kfilewrite+0x84>
    int i = 0;
    80005790:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005792:	013a1f63          	bne	s4,s3,800057b0 <kfilewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
    80005796:	8552                	mv	a0,s4
    80005798:	60a6                	ld	ra,72(sp)
    8000579a:	6406                	ld	s0,64(sp)
    8000579c:	74e2                	ld	s1,56(sp)
    8000579e:	7942                	ld	s2,48(sp)
    800057a0:	79a2                	ld	s3,40(sp)
    800057a2:	7a02                	ld	s4,32(sp)
    800057a4:	6ae2                	ld	s5,24(sp)
    800057a6:	6b42                	ld	s6,16(sp)
    800057a8:	6ba2                	ld	s7,8(sp)
    800057aa:	6c02                	ld	s8,0(sp)
    800057ac:	6161                	addi	sp,sp,80
    800057ae:	8082                	ret
    ret = (i == n ? n : -1);
    800057b0:	5a7d                	li	s4,-1
    800057b2:	b7d5                	j	80005796 <kfilewrite+0xfa>
    panic("filewrite");
    800057b4:	00004517          	auipc	a0,0x4
    800057b8:	40450513          	addi	a0,a0,1028 # 80009bb8 <syscalls+0x2d8>
    800057bc:	ffffb097          	auipc	ra,0xffffb
    800057c0:	d6e080e7          	jalr	-658(ra) # 8000052a <panic>
    return -1;
    800057c4:	5a7d                	li	s4,-1
    800057c6:	bfc1                	j	80005796 <kfilewrite+0xfa>
      return -1;
    800057c8:	5a7d                	li	s4,-1
    800057ca:	b7f1                	j	80005796 <kfilewrite+0xfa>
    800057cc:	5a7d                	li	s4,-1
    800057ce:	b7e1                	j	80005796 <kfilewrite+0xfa>

00000000800057d0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800057d0:	7179                	addi	sp,sp,-48
    800057d2:	f406                	sd	ra,40(sp)
    800057d4:	f022                	sd	s0,32(sp)
    800057d6:	ec26                	sd	s1,24(sp)
    800057d8:	e84a                	sd	s2,16(sp)
    800057da:	e44e                	sd	s3,8(sp)
    800057dc:	e052                	sd	s4,0(sp)
    800057de:	1800                	addi	s0,sp,48
    800057e0:	84aa                	mv	s1,a0
    800057e2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800057e4:	0005b023          	sd	zero,0(a1)
    800057e8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800057ec:	00000097          	auipc	ra,0x0
    800057f0:	a02080e7          	jalr	-1534(ra) # 800051ee <filealloc>
    800057f4:	e088                	sd	a0,0(s1)
    800057f6:	c551                	beqz	a0,80005882 <pipealloc+0xb2>
    800057f8:	00000097          	auipc	ra,0x0
    800057fc:	9f6080e7          	jalr	-1546(ra) # 800051ee <filealloc>
    80005800:	00aa3023          	sd	a0,0(s4)
    80005804:	c92d                	beqz	a0,80005876 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005806:	ffffb097          	auipc	ra,0xffffb
    8000580a:	2cc080e7          	jalr	716(ra) # 80000ad2 <kalloc>
    8000580e:	892a                	mv	s2,a0
    80005810:	c125                	beqz	a0,80005870 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005812:	4985                	li	s3,1
    80005814:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005818:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000581c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005820:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005824:	00004597          	auipc	a1,0x4
    80005828:	3a458593          	addi	a1,a1,932 # 80009bc8 <syscalls+0x2e8>
    8000582c:	ffffb097          	auipc	ra,0xffffb
    80005830:	306080e7          	jalr	774(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80005834:	609c                	ld	a5,0(s1)
    80005836:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000583a:	609c                	ld	a5,0(s1)
    8000583c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005840:	609c                	ld	a5,0(s1)
    80005842:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005846:	609c                	ld	a5,0(s1)
    80005848:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000584c:	000a3783          	ld	a5,0(s4)
    80005850:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005854:	000a3783          	ld	a5,0(s4)
    80005858:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000585c:	000a3783          	ld	a5,0(s4)
    80005860:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005864:	000a3783          	ld	a5,0(s4)
    80005868:	0127b823          	sd	s2,16(a5)
  return 0;
    8000586c:	4501                	li	a0,0
    8000586e:	a025                	j	80005896 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005870:	6088                	ld	a0,0(s1)
    80005872:	e501                	bnez	a0,8000587a <pipealloc+0xaa>
    80005874:	a039                	j	80005882 <pipealloc+0xb2>
    80005876:	6088                	ld	a0,0(s1)
    80005878:	c51d                	beqz	a0,800058a6 <pipealloc+0xd6>
    fileclose(*f0);
    8000587a:	00000097          	auipc	ra,0x0
    8000587e:	a30080e7          	jalr	-1488(ra) # 800052aa <fileclose>
  if(*f1)
    80005882:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005886:	557d                	li	a0,-1
  if(*f1)
    80005888:	c799                	beqz	a5,80005896 <pipealloc+0xc6>
    fileclose(*f1);
    8000588a:	853e                	mv	a0,a5
    8000588c:	00000097          	auipc	ra,0x0
    80005890:	a1e080e7          	jalr	-1506(ra) # 800052aa <fileclose>
  return -1;
    80005894:	557d                	li	a0,-1
}
    80005896:	70a2                	ld	ra,40(sp)
    80005898:	7402                	ld	s0,32(sp)
    8000589a:	64e2                	ld	s1,24(sp)
    8000589c:	6942                	ld	s2,16(sp)
    8000589e:	69a2                	ld	s3,8(sp)
    800058a0:	6a02                	ld	s4,0(sp)
    800058a2:	6145                	addi	sp,sp,48
    800058a4:	8082                	ret
  return -1;
    800058a6:	557d                	li	a0,-1
    800058a8:	b7fd                	j	80005896 <pipealloc+0xc6>

00000000800058aa <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800058aa:	1101                	addi	sp,sp,-32
    800058ac:	ec06                	sd	ra,24(sp)
    800058ae:	e822                	sd	s0,16(sp)
    800058b0:	e426                	sd	s1,8(sp)
    800058b2:	e04a                	sd	s2,0(sp)
    800058b4:	1000                	addi	s0,sp,32
    800058b6:	84aa                	mv	s1,a0
    800058b8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800058ba:	ffffb097          	auipc	ra,0xffffb
    800058be:	308080e7          	jalr	776(ra) # 80000bc2 <acquire>
  if(writable){
    800058c2:	02090d63          	beqz	s2,800058fc <pipeclose+0x52>
    pi->writeopen = 0;
    800058c6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800058ca:	21848513          	addi	a0,s1,536
    800058ce:	ffffd097          	auipc	ra,0xffffd
    800058d2:	ae8080e7          	jalr	-1304(ra) # 800023b6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800058d6:	2204b783          	ld	a5,544(s1)
    800058da:	eb95                	bnez	a5,8000590e <pipeclose+0x64>
    release(&pi->lock);
    800058dc:	8526                	mv	a0,s1
    800058de:	ffffb097          	auipc	ra,0xffffb
    800058e2:	398080e7          	jalr	920(ra) # 80000c76 <release>
    kfree((char*)pi);
    800058e6:	8526                	mv	a0,s1
    800058e8:	ffffb097          	auipc	ra,0xffffb
    800058ec:	0ee080e7          	jalr	238(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    800058f0:	60e2                	ld	ra,24(sp)
    800058f2:	6442                	ld	s0,16(sp)
    800058f4:	64a2                	ld	s1,8(sp)
    800058f6:	6902                	ld	s2,0(sp)
    800058f8:	6105                	addi	sp,sp,32
    800058fa:	8082                	ret
    pi->readopen = 0;
    800058fc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005900:	21c48513          	addi	a0,s1,540
    80005904:	ffffd097          	auipc	ra,0xffffd
    80005908:	ab2080e7          	jalr	-1358(ra) # 800023b6 <wakeup>
    8000590c:	b7e9                	j	800058d6 <pipeclose+0x2c>
    release(&pi->lock);
    8000590e:	8526                	mv	a0,s1
    80005910:	ffffb097          	auipc	ra,0xffffb
    80005914:	366080e7          	jalr	870(ra) # 80000c76 <release>
}
    80005918:	bfe1                	j	800058f0 <pipeclose+0x46>

000000008000591a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000591a:	711d                	addi	sp,sp,-96
    8000591c:	ec86                	sd	ra,88(sp)
    8000591e:	e8a2                	sd	s0,80(sp)
    80005920:	e4a6                	sd	s1,72(sp)
    80005922:	e0ca                	sd	s2,64(sp)
    80005924:	fc4e                	sd	s3,56(sp)
    80005926:	f852                	sd	s4,48(sp)
    80005928:	f456                	sd	s5,40(sp)
    8000592a:	f05a                	sd	s6,32(sp)
    8000592c:	ec5e                	sd	s7,24(sp)
    8000592e:	e862                	sd	s8,16(sp)
    80005930:	1080                	addi	s0,sp,96
    80005932:	84aa                	mv	s1,a0
    80005934:	8aae                	mv	s5,a1
    80005936:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005938:	ffffc097          	auipc	ra,0xffffc
    8000593c:	3fa080e7          	jalr	1018(ra) # 80001d32 <myproc>
    80005940:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005942:	8526                	mv	a0,s1
    80005944:	ffffb097          	auipc	ra,0xffffb
    80005948:	27e080e7          	jalr	638(ra) # 80000bc2 <acquire>
  while(i < n){
    8000594c:	0b405363          	blez	s4,800059f2 <pipewrite+0xd8>
  int i = 0;
    80005950:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005952:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005954:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005958:	21c48b93          	addi	s7,s1,540
    8000595c:	a089                	j	8000599e <pipewrite+0x84>
      release(&pi->lock);
    8000595e:	8526                	mv	a0,s1
    80005960:	ffffb097          	auipc	ra,0xffffb
    80005964:	316080e7          	jalr	790(ra) # 80000c76 <release>
      return -1;
    80005968:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000596a:	854a                	mv	a0,s2
    8000596c:	60e6                	ld	ra,88(sp)
    8000596e:	6446                	ld	s0,80(sp)
    80005970:	64a6                	ld	s1,72(sp)
    80005972:	6906                	ld	s2,64(sp)
    80005974:	79e2                	ld	s3,56(sp)
    80005976:	7a42                	ld	s4,48(sp)
    80005978:	7aa2                	ld	s5,40(sp)
    8000597a:	7b02                	ld	s6,32(sp)
    8000597c:	6be2                	ld	s7,24(sp)
    8000597e:	6c42                	ld	s8,16(sp)
    80005980:	6125                	addi	sp,sp,96
    80005982:	8082                	ret
      wakeup(&pi->nread);
    80005984:	8562                	mv	a0,s8
    80005986:	ffffd097          	auipc	ra,0xffffd
    8000598a:	a30080e7          	jalr	-1488(ra) # 800023b6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000598e:	85a6                	mv	a1,s1
    80005990:	855e                	mv	a0,s7
    80005992:	ffffd097          	auipc	ra,0xffffd
    80005996:	898080e7          	jalr	-1896(ra) # 8000222a <sleep>
  while(i < n){
    8000599a:	05495d63          	bge	s2,s4,800059f4 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    8000599e:	2204a783          	lw	a5,544(s1)
    800059a2:	dfd5                	beqz	a5,8000595e <pipewrite+0x44>
    800059a4:	0289a783          	lw	a5,40(s3)
    800059a8:	fbdd                	bnez	a5,8000595e <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800059aa:	2184a783          	lw	a5,536(s1)
    800059ae:	21c4a703          	lw	a4,540(s1)
    800059b2:	2007879b          	addiw	a5,a5,512
    800059b6:	fcf707e3          	beq	a4,a5,80005984 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800059ba:	4685                	li	a3,1
    800059bc:	01590633          	add	a2,s2,s5
    800059c0:	faf40593          	addi	a1,s0,-81
    800059c4:	0509b503          	ld	a0,80(s3)
    800059c8:	ffffc097          	auipc	ra,0xffffc
    800059cc:	a70080e7          	jalr	-1424(ra) # 80001438 <copyin>
    800059d0:	03650263          	beq	a0,s6,800059f4 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800059d4:	21c4a783          	lw	a5,540(s1)
    800059d8:	0017871b          	addiw	a4,a5,1
    800059dc:	20e4ae23          	sw	a4,540(s1)
    800059e0:	1ff7f793          	andi	a5,a5,511
    800059e4:	97a6                	add	a5,a5,s1
    800059e6:	faf44703          	lbu	a4,-81(s0)
    800059ea:	00e78c23          	sb	a4,24(a5)
      i++;
    800059ee:	2905                	addiw	s2,s2,1
    800059f0:	b76d                	j	8000599a <pipewrite+0x80>
  int i = 0;
    800059f2:	4901                	li	s2,0
  wakeup(&pi->nread);
    800059f4:	21848513          	addi	a0,s1,536
    800059f8:	ffffd097          	auipc	ra,0xffffd
    800059fc:	9be080e7          	jalr	-1602(ra) # 800023b6 <wakeup>
  release(&pi->lock);
    80005a00:	8526                	mv	a0,s1
    80005a02:	ffffb097          	auipc	ra,0xffffb
    80005a06:	274080e7          	jalr	628(ra) # 80000c76 <release>
  return i;
    80005a0a:	b785                	j	8000596a <pipewrite+0x50>

0000000080005a0c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005a0c:	715d                	addi	sp,sp,-80
    80005a0e:	e486                	sd	ra,72(sp)
    80005a10:	e0a2                	sd	s0,64(sp)
    80005a12:	fc26                	sd	s1,56(sp)
    80005a14:	f84a                	sd	s2,48(sp)
    80005a16:	f44e                	sd	s3,40(sp)
    80005a18:	f052                	sd	s4,32(sp)
    80005a1a:	ec56                	sd	s5,24(sp)
    80005a1c:	e85a                	sd	s6,16(sp)
    80005a1e:	0880                	addi	s0,sp,80
    80005a20:	84aa                	mv	s1,a0
    80005a22:	892e                	mv	s2,a1
    80005a24:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005a26:	ffffc097          	auipc	ra,0xffffc
    80005a2a:	30c080e7          	jalr	780(ra) # 80001d32 <myproc>
    80005a2e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005a30:	8526                	mv	a0,s1
    80005a32:	ffffb097          	auipc	ra,0xffffb
    80005a36:	190080e7          	jalr	400(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005a3a:	2184a703          	lw	a4,536(s1)
    80005a3e:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005a42:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005a46:	02f71463          	bne	a4,a5,80005a6e <piperead+0x62>
    80005a4a:	2244a783          	lw	a5,548(s1)
    80005a4e:	c385                	beqz	a5,80005a6e <piperead+0x62>
    if(pr->killed){
    80005a50:	028a2783          	lw	a5,40(s4)
    80005a54:	ebc1                	bnez	a5,80005ae4 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005a56:	85a6                	mv	a1,s1
    80005a58:	854e                	mv	a0,s3
    80005a5a:	ffffc097          	auipc	ra,0xffffc
    80005a5e:	7d0080e7          	jalr	2000(ra) # 8000222a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005a62:	2184a703          	lw	a4,536(s1)
    80005a66:	21c4a783          	lw	a5,540(s1)
    80005a6a:	fef700e3          	beq	a4,a5,80005a4a <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005a6e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005a70:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005a72:	05505363          	blez	s5,80005ab8 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80005a76:	2184a783          	lw	a5,536(s1)
    80005a7a:	21c4a703          	lw	a4,540(s1)
    80005a7e:	02f70d63          	beq	a4,a5,80005ab8 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005a82:	0017871b          	addiw	a4,a5,1
    80005a86:	20e4ac23          	sw	a4,536(s1)
    80005a8a:	1ff7f793          	andi	a5,a5,511
    80005a8e:	97a6                	add	a5,a5,s1
    80005a90:	0187c783          	lbu	a5,24(a5)
    80005a94:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005a98:	4685                	li	a3,1
    80005a9a:	fbf40613          	addi	a2,s0,-65
    80005a9e:	85ca                	mv	a1,s2
    80005aa0:	050a3503          	ld	a0,80(s4)
    80005aa4:	ffffc097          	auipc	ra,0xffffc
    80005aa8:	906080e7          	jalr	-1786(ra) # 800013aa <copyout>
    80005aac:	01650663          	beq	a0,s6,80005ab8 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005ab0:	2985                	addiw	s3,s3,1
    80005ab2:	0905                	addi	s2,s2,1
    80005ab4:	fd3a91e3          	bne	s5,s3,80005a76 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005ab8:	21c48513          	addi	a0,s1,540
    80005abc:	ffffd097          	auipc	ra,0xffffd
    80005ac0:	8fa080e7          	jalr	-1798(ra) # 800023b6 <wakeup>
  release(&pi->lock);
    80005ac4:	8526                	mv	a0,s1
    80005ac6:	ffffb097          	auipc	ra,0xffffb
    80005aca:	1b0080e7          	jalr	432(ra) # 80000c76 <release>
  return i;
}
    80005ace:	854e                	mv	a0,s3
    80005ad0:	60a6                	ld	ra,72(sp)
    80005ad2:	6406                	ld	s0,64(sp)
    80005ad4:	74e2                	ld	s1,56(sp)
    80005ad6:	7942                	ld	s2,48(sp)
    80005ad8:	79a2                	ld	s3,40(sp)
    80005ada:	7a02                	ld	s4,32(sp)
    80005adc:	6ae2                	ld	s5,24(sp)
    80005ade:	6b42                	ld	s6,16(sp)
    80005ae0:	6161                	addi	sp,sp,80
    80005ae2:	8082                	ret
      release(&pi->lock);
    80005ae4:	8526                	mv	a0,s1
    80005ae6:	ffffb097          	auipc	ra,0xffffb
    80005aea:	190080e7          	jalr	400(ra) # 80000c76 <release>
      return -1;
    80005aee:	59fd                	li	s3,-1
    80005af0:	bff9                	j	80005ace <piperead+0xc2>

0000000080005af2 <exec>:
#include "elf.h"

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int exec(char *path, char **argv)
{
    80005af2:	de010113          	addi	sp,sp,-544
    80005af6:	20113c23          	sd	ra,536(sp)
    80005afa:	20813823          	sd	s0,528(sp)
    80005afe:	20913423          	sd	s1,520(sp)
    80005b02:	21213023          	sd	s2,512(sp)
    80005b06:	ffce                	sd	s3,504(sp)
    80005b08:	fbd2                	sd	s4,496(sp)
    80005b0a:	f7d6                	sd	s5,488(sp)
    80005b0c:	f3da                	sd	s6,480(sp)
    80005b0e:	efde                	sd	s7,472(sp)
    80005b10:	ebe2                	sd	s8,464(sp)
    80005b12:	e7e6                	sd	s9,456(sp)
    80005b14:	e3ea                	sd	s10,448(sp)
    80005b16:	ff6e                	sd	s11,440(sp)
    80005b18:	1400                	addi	s0,sp,544
    80005b1a:	892a                	mv	s2,a0
    80005b1c:	dea43423          	sd	a0,-536(s0)
    80005b20:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005b24:	ffffc097          	auipc	ra,0xffffc
    80005b28:	20e080e7          	jalr	526(ra) # 80001d32 <myproc>
    80005b2c:	84aa                	mv	s1,a0



  begin_op();
    80005b2e:	fffff097          	auipc	ra,0xfffff
    80005b32:	2b0080e7          	jalr	688(ra) # 80004dde <begin_op>

  if ((ip = namei(path)) == 0)
    80005b36:	854a                	mv	a0,s2
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	d74080e7          	jalr	-652(ra) # 800048ac <namei>
    80005b40:	c93d                	beqz	a0,80005bb6 <exec+0xc4>
    80005b42:	8aaa                	mv	s5,a0
  {
    end_op();
    return -1;
  }
  ilock(ip);
    80005b44:	ffffe097          	auipc	ra,0xffffe
    80005b48:	5b2080e7          	jalr	1458(ra) # 800040f6 <ilock>

  // Check ELF header
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005b4c:	04000713          	li	a4,64
    80005b50:	4681                	li	a3,0
    80005b52:	e4840613          	addi	a2,s0,-440
    80005b56:	4581                	li	a1,0
    80005b58:	8556                	mv	a0,s5
    80005b5a:	fffff097          	auipc	ra,0xfffff
    80005b5e:	850080e7          	jalr	-1968(ra) # 800043aa <readi>
    80005b62:	04000793          	li	a5,64
    80005b66:	00f51a63          	bne	a0,a5,80005b7a <exec+0x88>
    goto bad;
  if (elf.magic != ELF_MAGIC)
    80005b6a:	e4842703          	lw	a4,-440(s0)
    80005b6e:	464c47b7          	lui	a5,0x464c4
    80005b72:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005b76:	04f70663          	beq	a4,a5,80005bc2 <exec+0xd0>
bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip)
  {
    iunlockput(ip);
    80005b7a:	8556                	mv	a0,s5
    80005b7c:	ffffe097          	auipc	ra,0xffffe
    80005b80:	7dc080e7          	jalr	2012(ra) # 80004358 <iunlockput>
    end_op();
    80005b84:	fffff097          	auipc	ra,0xfffff
    80005b88:	2da080e7          	jalr	730(ra) # 80004e5e <end_op>
  }
  return -1;
    80005b8c:	557d                	li	a0,-1
}
    80005b8e:	21813083          	ld	ra,536(sp)
    80005b92:	21013403          	ld	s0,528(sp)
    80005b96:	20813483          	ld	s1,520(sp)
    80005b9a:	20013903          	ld	s2,512(sp)
    80005b9e:	79fe                	ld	s3,504(sp)
    80005ba0:	7a5e                	ld	s4,496(sp)
    80005ba2:	7abe                	ld	s5,488(sp)
    80005ba4:	7b1e                	ld	s6,480(sp)
    80005ba6:	6bfe                	ld	s7,472(sp)
    80005ba8:	6c5e                	ld	s8,464(sp)
    80005baa:	6cbe                	ld	s9,456(sp)
    80005bac:	6d1e                	ld	s10,448(sp)
    80005bae:	7dfa                	ld	s11,440(sp)
    80005bb0:	22010113          	addi	sp,sp,544
    80005bb4:	8082                	ret
    end_op();
    80005bb6:	fffff097          	auipc	ra,0xfffff
    80005bba:	2a8080e7          	jalr	680(ra) # 80004e5e <end_op>
    return -1;
    80005bbe:	557d                	li	a0,-1
    80005bc0:	b7f9                	j	80005b8e <exec+0x9c>
  if ((pagetable = proc_pagetable(p)) == 0)
    80005bc2:	8526                	mv	a0,s1
    80005bc4:	ffffc097          	auipc	ra,0xffffc
    80005bc8:	232080e7          	jalr	562(ra) # 80001df6 <proc_pagetable>
    80005bcc:	8b2a                	mv	s6,a0
    80005bce:	d555                	beqz	a0,80005b7a <exec+0x88>
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005bd0:	e6842783          	lw	a5,-408(s0)
    80005bd4:	e8045703          	lhu	a4,-384(s0)
    80005bd8:	c73d                	beqz	a4,80005c46 <exec+0x154>
  uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
    80005bda:	4481                	li	s1,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005bdc:	e0043423          	sd	zero,-504(s0)
    if (ph.vaddr % PGSIZE != 0)
    80005be0:	6a05                	lui	s4,0x1
    80005be2:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005be6:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if ((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for (i = 0; i < sz; i += PGSIZE)
    80005bea:	6d85                	lui	s11,0x1
    80005bec:	7d7d                	lui	s10,0xfffff
    80005bee:	ac89                	j	80005e40 <exec+0x34e>
  {
    pa = walkaddr(pagetable, va + i, 0);
    if (pa == 0)
      panic("loadseg: address should exist");
    80005bf0:	00004517          	auipc	a0,0x4
    80005bf4:	fe050513          	addi	a0,a0,-32 # 80009bd0 <syscalls+0x2f0>
    80005bf8:	ffffb097          	auipc	ra,0xffffb
    80005bfc:	932080e7          	jalr	-1742(ra) # 8000052a <panic>
    if (sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80005c00:	874a                	mv	a4,s2
    80005c02:	009c86bb          	addw	a3,s9,s1
    80005c06:	4581                	li	a1,0
    80005c08:	8556                	mv	a0,s5
    80005c0a:	ffffe097          	auipc	ra,0xffffe
    80005c0e:	7a0080e7          	jalr	1952(ra) # 800043aa <readi>
    80005c12:	2501                	sext.w	a0,a0
    80005c14:	1ca91663          	bne	s2,a0,80005de0 <exec+0x2ee>
  for (i = 0; i < sz; i += PGSIZE)
    80005c18:	009d84bb          	addw	s1,s11,s1
    80005c1c:	013d09bb          	addw	s3,s10,s3
    80005c20:	2174f063          	bgeu	s1,s7,80005e20 <exec+0x32e>
    pa = walkaddr(pagetable, va + i, 0);
    80005c24:	02049593          	slli	a1,s1,0x20
    80005c28:	9181                	srli	a1,a1,0x20
    80005c2a:	4601                	li	a2,0
    80005c2c:	95e2                	add	a1,a1,s8
    80005c2e:	855a                	mv	a0,s6
    80005c30:	ffffb097          	auipc	ra,0xffffb
    80005c34:	41c080e7          	jalr	1052(ra) # 8000104c <walkaddr>
    80005c38:	862a                	mv	a2,a0
    if (pa == 0)
    80005c3a:	d95d                	beqz	a0,80005bf0 <exec+0xfe>
      n = PGSIZE;
    80005c3c:	8952                	mv	s2,s4
    if (sz - i < PGSIZE)
    80005c3e:	fd49f1e3          	bgeu	s3,s4,80005c00 <exec+0x10e>
      n = sz - i;
    80005c42:	894e                	mv	s2,s3
    80005c44:	bf75                	j	80005c00 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
    80005c46:	4481                	li	s1,0
  iunlockput(ip);
    80005c48:	8556                	mv	a0,s5
    80005c4a:	ffffe097          	auipc	ra,0xffffe
    80005c4e:	70e080e7          	jalr	1806(ra) # 80004358 <iunlockput>
  end_op();
    80005c52:	fffff097          	auipc	ra,0xfffff
    80005c56:	20c080e7          	jalr	524(ra) # 80004e5e <end_op>
  p = myproc();
    80005c5a:	ffffc097          	auipc	ra,0xffffc
    80005c5e:	0d8080e7          	jalr	216(ra) # 80001d32 <myproc>
    80005c62:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005c64:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005c68:	6785                	lui	a5,0x1
    80005c6a:	17fd                	addi	a5,a5,-1
    80005c6c:	94be                	add	s1,s1,a5
    80005c6e:	77fd                	lui	a5,0xfffff
    80005c70:	8fe5                	and	a5,a5,s1
    80005c72:	def43c23          	sd	a5,-520(s0)
  sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE);
    80005c76:	6609                	lui	a2,0x2
    80005c78:	963e                	add	a2,a2,a5
    80005c7a:	85be                	mv	a1,a5
    80005c7c:	855a                	mv	a0,s6
    80005c7e:	ffffc097          	auipc	ra,0xffffc
    80005c82:	ca2080e7          	jalr	-862(ra) # 80001920 <uvmalloc>
    80005c86:	8c2a                	mv	s8,a0
  ip = 0;
    80005c88:	4a81                	li	s5,0
  if ((sz1) == 0)
    80005c8a:	14050b63          	beqz	a0,80005de0 <exec+0x2ee>
  uvmclear(pagetable, sz - 2 * PGSIZE);
    80005c8e:	75f9                	lui	a1,0xffffe
    80005c90:	95aa                	add	a1,a1,a0
    80005c92:	855a                	mv	a0,s6
    80005c94:	ffffb097          	auipc	ra,0xffffb
    80005c98:	6e4080e7          	jalr	1764(ra) # 80001378 <uvmclear>
  stackbase = sp - PGSIZE;
    80005c9c:	7afd                	lui	s5,0xfffff
    80005c9e:	9ae2                	add	s5,s5,s8
  for (argc = 0; argv[argc]; argc++)
    80005ca0:	df043783          	ld	a5,-528(s0)
    80005ca4:	6388                	ld	a0,0(a5)
    80005ca6:	c925                	beqz	a0,80005d16 <exec+0x224>
    80005ca8:	e8840993          	addi	s3,s0,-376
    80005cac:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005cb0:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    80005cb2:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005cb4:	ffffb097          	auipc	ra,0xffffb
    80005cb8:	18e080e7          	jalr	398(ra) # 80000e42 <strlen>
    80005cbc:	0015079b          	addiw	a5,a0,1
    80005cc0:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005cc4:	ff097913          	andi	s2,s2,-16
    if (sp < stackbase)
    80005cc8:	15596063          	bltu	s2,s5,80005e08 <exec+0x316>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005ccc:	df043d83          	ld	s11,-528(s0)
    80005cd0:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005cd4:	8552                	mv	a0,s4
    80005cd6:	ffffb097          	auipc	ra,0xffffb
    80005cda:	16c080e7          	jalr	364(ra) # 80000e42 <strlen>
    80005cde:	0015069b          	addiw	a3,a0,1
    80005ce2:	8652                	mv	a2,s4
    80005ce4:	85ca                	mv	a1,s2
    80005ce6:	855a                	mv	a0,s6
    80005ce8:	ffffb097          	auipc	ra,0xffffb
    80005cec:	6c2080e7          	jalr	1730(ra) # 800013aa <copyout>
    80005cf0:	12054063          	bltz	a0,80005e10 <exec+0x31e>
    ustack[argc] = sp;
    80005cf4:	0129b023          	sd	s2,0(s3)
  for (argc = 0; argv[argc]; argc++)
    80005cf8:	0485                	addi	s1,s1,1
    80005cfa:	008d8793          	addi	a5,s11,8
    80005cfe:	def43823          	sd	a5,-528(s0)
    80005d02:	008db503          	ld	a0,8(s11)
    80005d06:	c911                	beqz	a0,80005d1a <exec+0x228>
    if (argc >= MAXARG)
    80005d08:	09a1                	addi	s3,s3,8
    80005d0a:	fb3c95e3          	bne	s9,s3,80005cb4 <exec+0x1c2>
  sz = sz1;
    80005d0e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005d12:	4a81                	li	s5,0
    80005d14:	a0f1                	j	80005de0 <exec+0x2ee>
  sp = sz;
    80005d16:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    80005d18:	4481                	li	s1,0
  ustack[argc] = 0;
    80005d1a:	00349793          	slli	a5,s1,0x3
    80005d1e:	f9040713          	addi	a4,s0,-112
    80005d22:	97ba                	add	a5,a5,a4
    80005d24:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffcbef8>
  sp -= (argc + 1) * sizeof(uint64);
    80005d28:	00148693          	addi	a3,s1,1
    80005d2c:	068e                	slli	a3,a3,0x3
    80005d2e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005d32:	ff097913          	andi	s2,s2,-16
  if (sp < stackbase)
    80005d36:	01597663          	bgeu	s2,s5,80005d42 <exec+0x250>
  sz = sz1;
    80005d3a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005d3e:	4a81                	li	s5,0
    80005d40:	a045                	j	80005de0 <exec+0x2ee>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    80005d42:	e8840613          	addi	a2,s0,-376
    80005d46:	85ca                	mv	a1,s2
    80005d48:	855a                	mv	a0,s6
    80005d4a:	ffffb097          	auipc	ra,0xffffb
    80005d4e:	660080e7          	jalr	1632(ra) # 800013aa <copyout>
    80005d52:	0c054363          	bltz	a0,80005e18 <exec+0x326>
  p->trapframe->a1 = sp;
    80005d56:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80005d5a:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    80005d5e:	de843783          	ld	a5,-536(s0)
    80005d62:	0007c703          	lbu	a4,0(a5)
    80005d66:	cf11                	beqz	a4,80005d82 <exec+0x290>
    80005d68:	0785                	addi	a5,a5,1
    if (*s == '/')
    80005d6a:	02f00693          	li	a3,47
    80005d6e:	a039                	j	80005d7c <exec+0x28a>
      last = s + 1;
    80005d70:	def43423          	sd	a5,-536(s0)
  for (last = s = path; *s; s++)
    80005d74:	0785                	addi	a5,a5,1
    80005d76:	fff7c703          	lbu	a4,-1(a5)
    80005d7a:	c701                	beqz	a4,80005d82 <exec+0x290>
    if (*s == '/')
    80005d7c:	fed71ce3          	bne	a4,a3,80005d74 <exec+0x282>
    80005d80:	bfc5                	j	80005d70 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005d82:	4641                	li	a2,16
    80005d84:	de843583          	ld	a1,-536(s0)
    80005d88:	158b8513          	addi	a0,s7,344
    80005d8c:	ffffb097          	auipc	ra,0xffffb
    80005d90:	084080e7          	jalr	132(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005d94:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005d98:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005d9c:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry; // initial program counter = main
    80005da0:	058bb783          	ld	a5,88(s7)
    80005da4:	e6043703          	ld	a4,-416(s0)
    80005da8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80005daa:	058bb783          	ld	a5,88(s7)
    80005dae:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz); // also remove swapfile
    80005db2:	85ea                	mv	a1,s10
    80005db4:	ffffc097          	auipc	ra,0xffffc
    80005db8:	0de080e7          	jalr	222(ra) # 80001e92 <proc_freepagetable>
  if(p->pid >2){
    80005dbc:	030ba703          	lw	a4,48(s7)
    80005dc0:	4789                	li	a5,2
    80005dc2:	00e7da63          	bge	a5,a4,80005dd6 <exec+0x2e4>
    p->physical_pages_num = 0;
    80005dc6:	160ba823          	sw	zero,368(s7)
    p->total_pages_num = 0;
    80005dca:	160baa23          	sw	zero,372(s7)
    p->pages_physc_info.free_spaces = 0;
    80005dce:	300b9023          	sh	zero,768(s7)
    p->pages_swap_info.free_spaces = 0;
    80005dd2:	160b9c23          	sh	zero,376(s7)
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005dd6:	0004851b          	sext.w	a0,s1
    80005dda:	bb55                	j	80005b8e <exec+0x9c>
    80005ddc:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005de0:	df843583          	ld	a1,-520(s0)
    80005de4:	855a                	mv	a0,s6
    80005de6:	ffffc097          	auipc	ra,0xffffc
    80005dea:	0ac080e7          	jalr	172(ra) # 80001e92 <proc_freepagetable>
  if (ip)
    80005dee:	d80a96e3          	bnez	s5,80005b7a <exec+0x88>
  return -1;
    80005df2:	557d                	li	a0,-1
    80005df4:	bb69                	j	80005b8e <exec+0x9c>
    80005df6:	de943c23          	sd	s1,-520(s0)
    80005dfa:	b7dd                	j	80005de0 <exec+0x2ee>
    80005dfc:	de943c23          	sd	s1,-520(s0)
    80005e00:	b7c5                	j	80005de0 <exec+0x2ee>
    80005e02:	de943c23          	sd	s1,-520(s0)
    80005e06:	bfe9                	j	80005de0 <exec+0x2ee>
  sz = sz1;
    80005e08:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005e0c:	4a81                	li	s5,0
    80005e0e:	bfc9                	j	80005de0 <exec+0x2ee>
  sz = sz1;
    80005e10:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005e14:	4a81                	li	s5,0
    80005e16:	b7e9                	j	80005de0 <exec+0x2ee>
  sz = sz1;
    80005e18:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005e1c:	4a81                	li	s5,0
    80005e1e:	b7c9                	j	80005de0 <exec+0x2ee>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005e20:	df843483          	ld	s1,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005e24:	e0843783          	ld	a5,-504(s0)
    80005e28:	0017869b          	addiw	a3,a5,1
    80005e2c:	e0d43423          	sd	a3,-504(s0)
    80005e30:	e0043783          	ld	a5,-512(s0)
    80005e34:	0387879b          	addiw	a5,a5,56
    80005e38:	e8045703          	lhu	a4,-384(s0)
    80005e3c:	e0e6d6e3          	bge	a3,a4,80005c48 <exec+0x156>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005e40:	2781                	sext.w	a5,a5
    80005e42:	e0f43023          	sd	a5,-512(s0)
    80005e46:	03800713          	li	a4,56
    80005e4a:	86be                	mv	a3,a5
    80005e4c:	e1040613          	addi	a2,s0,-496
    80005e50:	4581                	li	a1,0
    80005e52:	8556                	mv	a0,s5
    80005e54:	ffffe097          	auipc	ra,0xffffe
    80005e58:	556080e7          	jalr	1366(ra) # 800043aa <readi>
    80005e5c:	03800793          	li	a5,56
    80005e60:	f6f51ee3          	bne	a0,a5,80005ddc <exec+0x2ea>
    if (ph.type != ELF_PROG_LOAD)
    80005e64:	e1042783          	lw	a5,-496(s0)
    80005e68:	4705                	li	a4,1
    80005e6a:	fae79de3          	bne	a5,a4,80005e24 <exec+0x332>
    if (ph.memsz < ph.filesz)
    80005e6e:	e3843603          	ld	a2,-456(s0)
    80005e72:	e3043783          	ld	a5,-464(s0)
    80005e76:	f8f660e3          	bltu	a2,a5,80005df6 <exec+0x304>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80005e7a:	e2043783          	ld	a5,-480(s0)
    80005e7e:	963e                	add	a2,a2,a5
    80005e80:	f6f66ee3          	bltu	a2,a5,80005dfc <exec+0x30a>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005e84:	85a6                	mv	a1,s1
    80005e86:	855a                	mv	a0,s6
    80005e88:	ffffc097          	auipc	ra,0xffffc
    80005e8c:	a98080e7          	jalr	-1384(ra) # 80001920 <uvmalloc>
    80005e90:	dea43c23          	sd	a0,-520(s0)
    80005e94:	d53d                	beqz	a0,80005e02 <exec+0x310>
    if (ph.vaddr % PGSIZE != 0)
    80005e96:	e2043c03          	ld	s8,-480(s0)
    80005e9a:	de043783          	ld	a5,-544(s0)
    80005e9e:	00fc77b3          	and	a5,s8,a5
    80005ea2:	ff9d                	bnez	a5,80005de0 <exec+0x2ee>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005ea4:	e1842c83          	lw	s9,-488(s0)
    80005ea8:	e3042b83          	lw	s7,-464(s0)
  for (i = 0; i < sz; i += PGSIZE)
    80005eac:	f60b8ae3          	beqz	s7,80005e20 <exec+0x32e>
    80005eb0:	89de                	mv	s3,s7
    80005eb2:	4481                	li	s1,0
    80005eb4:	bb85                	j	80005c24 <exec+0x132>

0000000080005eb6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005eb6:	7179                	addi	sp,sp,-48
    80005eb8:	f406                	sd	ra,40(sp)
    80005eba:	f022                	sd	s0,32(sp)
    80005ebc:	ec26                	sd	s1,24(sp)
    80005ebe:	e84a                	sd	s2,16(sp)
    80005ec0:	1800                	addi	s0,sp,48
    80005ec2:	892e                	mv	s2,a1
    80005ec4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005ec6:	fdc40593          	addi	a1,s0,-36
    80005eca:	ffffd097          	auipc	ra,0xffffd
    80005ece:	6ba080e7          	jalr	1722(ra) # 80003584 <argint>
    80005ed2:	04054063          	bltz	a0,80005f12 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005ed6:	fdc42703          	lw	a4,-36(s0)
    80005eda:	47bd                	li	a5,15
    80005edc:	02e7ed63          	bltu	a5,a4,80005f16 <argfd+0x60>
    80005ee0:	ffffc097          	auipc	ra,0xffffc
    80005ee4:	e52080e7          	jalr	-430(ra) # 80001d32 <myproc>
    80005ee8:	fdc42703          	lw	a4,-36(s0)
    80005eec:	01a70793          	addi	a5,a4,26
    80005ef0:	078e                	slli	a5,a5,0x3
    80005ef2:	953e                	add	a0,a0,a5
    80005ef4:	611c                	ld	a5,0(a0)
    80005ef6:	c395                	beqz	a5,80005f1a <argfd+0x64>
    return -1;
  if(pfd)
    80005ef8:	00090463          	beqz	s2,80005f00 <argfd+0x4a>
    *pfd = fd;
    80005efc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005f00:	4501                	li	a0,0
  if(pf)
    80005f02:	c091                	beqz	s1,80005f06 <argfd+0x50>
    *pf = f;
    80005f04:	e09c                	sd	a5,0(s1)
}
    80005f06:	70a2                	ld	ra,40(sp)
    80005f08:	7402                	ld	s0,32(sp)
    80005f0a:	64e2                	ld	s1,24(sp)
    80005f0c:	6942                	ld	s2,16(sp)
    80005f0e:	6145                	addi	sp,sp,48
    80005f10:	8082                	ret
    return -1;
    80005f12:	557d                	li	a0,-1
    80005f14:	bfcd                	j	80005f06 <argfd+0x50>
    return -1;
    80005f16:	557d                	li	a0,-1
    80005f18:	b7fd                	j	80005f06 <argfd+0x50>
    80005f1a:	557d                	li	a0,-1
    80005f1c:	b7ed                	j	80005f06 <argfd+0x50>

0000000080005f1e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005f1e:	1101                	addi	sp,sp,-32
    80005f20:	ec06                	sd	ra,24(sp)
    80005f22:	e822                	sd	s0,16(sp)
    80005f24:	e426                	sd	s1,8(sp)
    80005f26:	1000                	addi	s0,sp,32
    80005f28:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005f2a:	ffffc097          	auipc	ra,0xffffc
    80005f2e:	e08080e7          	jalr	-504(ra) # 80001d32 <myproc>
    80005f32:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005f34:	0d050793          	addi	a5,a0,208
    80005f38:	4501                	li	a0,0
    80005f3a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005f3c:	6398                	ld	a4,0(a5)
    80005f3e:	cb19                	beqz	a4,80005f54 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005f40:	2505                	addiw	a0,a0,1
    80005f42:	07a1                	addi	a5,a5,8
    80005f44:	fed51ce3          	bne	a0,a3,80005f3c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005f48:	557d                	li	a0,-1
}
    80005f4a:	60e2                	ld	ra,24(sp)
    80005f4c:	6442                	ld	s0,16(sp)
    80005f4e:	64a2                	ld	s1,8(sp)
    80005f50:	6105                	addi	sp,sp,32
    80005f52:	8082                	ret
      p->ofile[fd] = f;
    80005f54:	01a50793          	addi	a5,a0,26
    80005f58:	078e                	slli	a5,a5,0x3
    80005f5a:	963e                	add	a2,a2,a5
    80005f5c:	e204                	sd	s1,0(a2)
      return fd;
    80005f5e:	b7f5                	j	80005f4a <fdalloc+0x2c>

0000000080005f60 <sys_dup>:

uint64
sys_dup(void)
{
    80005f60:	7179                	addi	sp,sp,-48
    80005f62:	f406                	sd	ra,40(sp)
    80005f64:	f022                	sd	s0,32(sp)
    80005f66:	ec26                	sd	s1,24(sp)
    80005f68:	1800                	addi	s0,sp,48
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    80005f6a:	fd840613          	addi	a2,s0,-40
    80005f6e:	4581                	li	a1,0
    80005f70:	4501                	li	a0,0
    80005f72:	00000097          	auipc	ra,0x0
    80005f76:	f44080e7          	jalr	-188(ra) # 80005eb6 <argfd>
    return -1;
    80005f7a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005f7c:	02054363          	bltz	a0,80005fa2 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005f80:	fd843503          	ld	a0,-40(s0)
    80005f84:	00000097          	auipc	ra,0x0
    80005f88:	f9a080e7          	jalr	-102(ra) # 80005f1e <fdalloc>
    80005f8c:	84aa                	mv	s1,a0
    return -1;
    80005f8e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005f90:	00054963          	bltz	a0,80005fa2 <sys_dup+0x42>
  filedup(f);
    80005f94:	fd843503          	ld	a0,-40(s0)
    80005f98:	fffff097          	auipc	ra,0xfffff
    80005f9c:	2c0080e7          	jalr	704(ra) # 80005258 <filedup>
  return fd;
    80005fa0:	87a6                	mv	a5,s1
}
    80005fa2:	853e                	mv	a0,a5
    80005fa4:	70a2                	ld	ra,40(sp)
    80005fa6:	7402                	ld	s0,32(sp)
    80005fa8:	64e2                	ld	s1,24(sp)
    80005faa:	6145                	addi	sp,sp,48
    80005fac:	8082                	ret

0000000080005fae <sys_read>:

uint64
sys_read(void)
{
    80005fae:	7179                	addi	sp,sp,-48
    80005fb0:	f406                	sd	ra,40(sp)
    80005fb2:	f022                	sd	s0,32(sp)
    80005fb4:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005fb6:	fe840613          	addi	a2,s0,-24
    80005fba:	4581                	li	a1,0
    80005fbc:	4501                	li	a0,0
    80005fbe:	00000097          	auipc	ra,0x0
    80005fc2:	ef8080e7          	jalr	-264(ra) # 80005eb6 <argfd>
    return -1;
    80005fc6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005fc8:	04054163          	bltz	a0,8000600a <sys_read+0x5c>
    80005fcc:	fe440593          	addi	a1,s0,-28
    80005fd0:	4509                	li	a0,2
    80005fd2:	ffffd097          	auipc	ra,0xffffd
    80005fd6:	5b2080e7          	jalr	1458(ra) # 80003584 <argint>
    return -1;
    80005fda:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005fdc:	02054763          	bltz	a0,8000600a <sys_read+0x5c>
    80005fe0:	fd840593          	addi	a1,s0,-40
    80005fe4:	4505                	li	a0,1
    80005fe6:	ffffd097          	auipc	ra,0xffffd
    80005fea:	5c0080e7          	jalr	1472(ra) # 800035a6 <argaddr>
    return -1;
    80005fee:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ff0:	00054d63          	bltz	a0,8000600a <sys_read+0x5c>
  return fileread(f, p, n);
    80005ff4:	fe442603          	lw	a2,-28(s0)
    80005ff8:	fd843583          	ld	a1,-40(s0)
    80005ffc:	fe843503          	ld	a0,-24(s0)
    80006000:	fffff097          	auipc	ra,0xfffff
    80006004:	3e4080e7          	jalr	996(ra) # 800053e4 <fileread>
    80006008:	87aa                	mv	a5,a0
}
    8000600a:	853e                	mv	a0,a5
    8000600c:	70a2                	ld	ra,40(sp)
    8000600e:	7402                	ld	s0,32(sp)
    80006010:	6145                	addi	sp,sp,48
    80006012:	8082                	ret

0000000080006014 <sys_write>:

uint64
sys_write(void)
{
    80006014:	7179                	addi	sp,sp,-48
    80006016:	f406                	sd	ra,40(sp)
    80006018:	f022                	sd	s0,32(sp)
    8000601a:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000601c:	fe840613          	addi	a2,s0,-24
    80006020:	4581                	li	a1,0
    80006022:	4501                	li	a0,0
    80006024:	00000097          	auipc	ra,0x0
    80006028:	e92080e7          	jalr	-366(ra) # 80005eb6 <argfd>
    return -1;
    8000602c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000602e:	04054163          	bltz	a0,80006070 <sys_write+0x5c>
    80006032:	fe440593          	addi	a1,s0,-28
    80006036:	4509                	li	a0,2
    80006038:	ffffd097          	auipc	ra,0xffffd
    8000603c:	54c080e7          	jalr	1356(ra) # 80003584 <argint>
    return -1;
    80006040:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006042:	02054763          	bltz	a0,80006070 <sys_write+0x5c>
    80006046:	fd840593          	addi	a1,s0,-40
    8000604a:	4505                	li	a0,1
    8000604c:	ffffd097          	auipc	ra,0xffffd
    80006050:	55a080e7          	jalr	1370(ra) # 800035a6 <argaddr>
    return -1;
    80006054:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006056:	00054d63          	bltz	a0,80006070 <sys_write+0x5c>

  return filewrite(f, p, n);
    8000605a:	fe442603          	lw	a2,-28(s0)
    8000605e:	fd843583          	ld	a1,-40(s0)
    80006062:	fe843503          	ld	a0,-24(s0)
    80006066:	fffff097          	auipc	ra,0xfffff
    8000606a:	440080e7          	jalr	1088(ra) # 800054a6 <filewrite>
    8000606e:	87aa                	mv	a5,a0
}
    80006070:	853e                	mv	a0,a5
    80006072:	70a2                	ld	ra,40(sp)
    80006074:	7402                	ld	s0,32(sp)
    80006076:	6145                	addi	sp,sp,48
    80006078:	8082                	ret

000000008000607a <sys_close>:

uint64
sys_close(void)
{
    8000607a:	1101                	addi	sp,sp,-32
    8000607c:	ec06                	sd	ra,24(sp)
    8000607e:	e822                	sd	s0,16(sp)
    80006080:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    80006082:	fe040613          	addi	a2,s0,-32
    80006086:	fec40593          	addi	a1,s0,-20
    8000608a:	4501                	li	a0,0
    8000608c:	00000097          	auipc	ra,0x0
    80006090:	e2a080e7          	jalr	-470(ra) # 80005eb6 <argfd>
    return -1;
    80006094:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80006096:	02054463          	bltz	a0,800060be <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000609a:	ffffc097          	auipc	ra,0xffffc
    8000609e:	c98080e7          	jalr	-872(ra) # 80001d32 <myproc>
    800060a2:	fec42783          	lw	a5,-20(s0)
    800060a6:	07e9                	addi	a5,a5,26
    800060a8:	078e                	slli	a5,a5,0x3
    800060aa:	97aa                	add	a5,a5,a0
    800060ac:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800060b0:	fe043503          	ld	a0,-32(s0)
    800060b4:	fffff097          	auipc	ra,0xfffff
    800060b8:	1f6080e7          	jalr	502(ra) # 800052aa <fileclose>
  return 0;
    800060bc:	4781                	li	a5,0
}
    800060be:	853e                	mv	a0,a5
    800060c0:	60e2                	ld	ra,24(sp)
    800060c2:	6442                	ld	s0,16(sp)
    800060c4:	6105                	addi	sp,sp,32
    800060c6:	8082                	ret

00000000800060c8 <sys_fstat>:

uint64
sys_fstat(void)
{
    800060c8:	1101                	addi	sp,sp,-32
    800060ca:	ec06                	sd	ra,24(sp)
    800060cc:	e822                	sd	s0,16(sp)
    800060ce:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800060d0:	fe840613          	addi	a2,s0,-24
    800060d4:	4581                	li	a1,0
    800060d6:	4501                	li	a0,0
    800060d8:	00000097          	auipc	ra,0x0
    800060dc:	dde080e7          	jalr	-546(ra) # 80005eb6 <argfd>
    return -1;
    800060e0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800060e2:	02054563          	bltz	a0,8000610c <sys_fstat+0x44>
    800060e6:	fe040593          	addi	a1,s0,-32
    800060ea:	4505                	li	a0,1
    800060ec:	ffffd097          	auipc	ra,0xffffd
    800060f0:	4ba080e7          	jalr	1210(ra) # 800035a6 <argaddr>
    return -1;
    800060f4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800060f6:	00054b63          	bltz	a0,8000610c <sys_fstat+0x44>
  return filestat(f, st);
    800060fa:	fe043583          	ld	a1,-32(s0)
    800060fe:	fe843503          	ld	a0,-24(s0)
    80006102:	fffff097          	auipc	ra,0xfffff
    80006106:	270080e7          	jalr	624(ra) # 80005372 <filestat>
    8000610a:	87aa                	mv	a5,a0
}
    8000610c:	853e                	mv	a0,a5
    8000610e:	60e2                	ld	ra,24(sp)
    80006110:	6442                	ld	s0,16(sp)
    80006112:	6105                	addi	sp,sp,32
    80006114:	8082                	ret

0000000080006116 <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    80006116:	7169                	addi	sp,sp,-304
    80006118:	f606                	sd	ra,296(sp)
    8000611a:	f222                	sd	s0,288(sp)
    8000611c:	ee26                	sd	s1,280(sp)
    8000611e:	ea4a                	sd	s2,272(sp)
    80006120:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006122:	08000613          	li	a2,128
    80006126:	ed040593          	addi	a1,s0,-304
    8000612a:	4501                	li	a0,0
    8000612c:	ffffd097          	auipc	ra,0xffffd
    80006130:	49c080e7          	jalr	1180(ra) # 800035c8 <argstr>
    return -1;
    80006134:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006136:	10054e63          	bltz	a0,80006252 <sys_link+0x13c>
    8000613a:	08000613          	li	a2,128
    8000613e:	f5040593          	addi	a1,s0,-176
    80006142:	4505                	li	a0,1
    80006144:	ffffd097          	auipc	ra,0xffffd
    80006148:	484080e7          	jalr	1156(ra) # 800035c8 <argstr>
    return -1;
    8000614c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000614e:	10054263          	bltz	a0,80006252 <sys_link+0x13c>

  begin_op();
    80006152:	fffff097          	auipc	ra,0xfffff
    80006156:	c8c080e7          	jalr	-884(ra) # 80004dde <begin_op>
  if((ip = namei(old)) == 0){
    8000615a:	ed040513          	addi	a0,s0,-304
    8000615e:	ffffe097          	auipc	ra,0xffffe
    80006162:	74e080e7          	jalr	1870(ra) # 800048ac <namei>
    80006166:	84aa                	mv	s1,a0
    80006168:	c551                	beqz	a0,800061f4 <sys_link+0xde>
    end_op();
    return -1;
  }

  ilock(ip);
    8000616a:	ffffe097          	auipc	ra,0xffffe
    8000616e:	f8c080e7          	jalr	-116(ra) # 800040f6 <ilock>
  if(ip->type == T_DIR){
    80006172:	04449703          	lh	a4,68(s1)
    80006176:	4785                	li	a5,1
    80006178:	08f70463          	beq	a4,a5,80006200 <sys_link+0xea>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
    8000617c:	04a4d783          	lhu	a5,74(s1)
    80006180:	2785                	addiw	a5,a5,1
    80006182:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006186:	8526                	mv	a0,s1
    80006188:	ffffe097          	auipc	ra,0xffffe
    8000618c:	ea4080e7          	jalr	-348(ra) # 8000402c <iupdate>
  iunlock(ip);
    80006190:	8526                	mv	a0,s1
    80006192:	ffffe097          	auipc	ra,0xffffe
    80006196:	026080e7          	jalr	38(ra) # 800041b8 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    8000619a:	fd040593          	addi	a1,s0,-48
    8000619e:	f5040513          	addi	a0,s0,-176
    800061a2:	ffffe097          	auipc	ra,0xffffe
    800061a6:	728080e7          	jalr	1832(ra) # 800048ca <nameiparent>
    800061aa:	892a                	mv	s2,a0
    800061ac:	c935                	beqz	a0,80006220 <sys_link+0x10a>
    goto bad;
  ilock(dp);
    800061ae:	ffffe097          	auipc	ra,0xffffe
    800061b2:	f48080e7          	jalr	-184(ra) # 800040f6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800061b6:	00092703          	lw	a4,0(s2)
    800061ba:	409c                	lw	a5,0(s1)
    800061bc:	04f71d63          	bne	a4,a5,80006216 <sys_link+0x100>
    800061c0:	40d0                	lw	a2,4(s1)
    800061c2:	fd040593          	addi	a1,s0,-48
    800061c6:	854a                	mv	a0,s2
    800061c8:	ffffe097          	auipc	ra,0xffffe
    800061cc:	622080e7          	jalr	1570(ra) # 800047ea <dirlink>
    800061d0:	04054363          	bltz	a0,80006216 <sys_link+0x100>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
    800061d4:	854a                	mv	a0,s2
    800061d6:	ffffe097          	auipc	ra,0xffffe
    800061da:	182080e7          	jalr	386(ra) # 80004358 <iunlockput>
  iput(ip);
    800061de:	8526                	mv	a0,s1
    800061e0:	ffffe097          	auipc	ra,0xffffe
    800061e4:	0d0080e7          	jalr	208(ra) # 800042b0 <iput>

  end_op();
    800061e8:	fffff097          	auipc	ra,0xfffff
    800061ec:	c76080e7          	jalr	-906(ra) # 80004e5e <end_op>

  return 0;
    800061f0:	4781                	li	a5,0
    800061f2:	a085                	j	80006252 <sys_link+0x13c>
    end_op();
    800061f4:	fffff097          	auipc	ra,0xfffff
    800061f8:	c6a080e7          	jalr	-918(ra) # 80004e5e <end_op>
    return -1;
    800061fc:	57fd                	li	a5,-1
    800061fe:	a891                	j	80006252 <sys_link+0x13c>
    iunlockput(ip);
    80006200:	8526                	mv	a0,s1
    80006202:	ffffe097          	auipc	ra,0xffffe
    80006206:	156080e7          	jalr	342(ra) # 80004358 <iunlockput>
    end_op();
    8000620a:	fffff097          	auipc	ra,0xfffff
    8000620e:	c54080e7          	jalr	-940(ra) # 80004e5e <end_op>
    return -1;
    80006212:	57fd                	li	a5,-1
    80006214:	a83d                	j	80006252 <sys_link+0x13c>
    iunlockput(dp);
    80006216:	854a                	mv	a0,s2
    80006218:	ffffe097          	auipc	ra,0xffffe
    8000621c:	140080e7          	jalr	320(ra) # 80004358 <iunlockput>

bad:
  ilock(ip);
    80006220:	8526                	mv	a0,s1
    80006222:	ffffe097          	auipc	ra,0xffffe
    80006226:	ed4080e7          	jalr	-300(ra) # 800040f6 <ilock>
  ip->nlink--;
    8000622a:	04a4d783          	lhu	a5,74(s1)
    8000622e:	37fd                	addiw	a5,a5,-1
    80006230:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006234:	8526                	mv	a0,s1
    80006236:	ffffe097          	auipc	ra,0xffffe
    8000623a:	df6080e7          	jalr	-522(ra) # 8000402c <iupdate>
  iunlockput(ip);
    8000623e:	8526                	mv	a0,s1
    80006240:	ffffe097          	auipc	ra,0xffffe
    80006244:	118080e7          	jalr	280(ra) # 80004358 <iunlockput>
  end_op();
    80006248:	fffff097          	auipc	ra,0xfffff
    8000624c:	c16080e7          	jalr	-1002(ra) # 80004e5e <end_op>
  return -1;
    80006250:	57fd                	li	a5,-1
}
    80006252:	853e                	mv	a0,a5
    80006254:	70b2                	ld	ra,296(sp)
    80006256:	7412                	ld	s0,288(sp)
    80006258:	64f2                	ld	s1,280(sp)
    8000625a:	6952                	ld	s2,272(sp)
    8000625c:	6155                	addi	sp,sp,304
    8000625e:	8082                	ret

0000000080006260 <isdirempty>:
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006260:	4578                	lw	a4,76(a0)
    80006262:	02000793          	li	a5,32
    80006266:	04e7fa63          	bgeu	a5,a4,800062ba <isdirempty+0x5a>
{
    8000626a:	7179                	addi	sp,sp,-48
    8000626c:	f406                	sd	ra,40(sp)
    8000626e:	f022                	sd	s0,32(sp)
    80006270:	ec26                	sd	s1,24(sp)
    80006272:	e84a                	sd	s2,16(sp)
    80006274:	1800                	addi	s0,sp,48
    80006276:	892a                	mv	s2,a0
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006278:	02000493          	li	s1,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000627c:	4741                	li	a4,16
    8000627e:	86a6                	mv	a3,s1
    80006280:	fd040613          	addi	a2,s0,-48
    80006284:	4581                	li	a1,0
    80006286:	854a                	mv	a0,s2
    80006288:	ffffe097          	auipc	ra,0xffffe
    8000628c:	122080e7          	jalr	290(ra) # 800043aa <readi>
    80006290:	47c1                	li	a5,16
    80006292:	00f51c63          	bne	a0,a5,800062aa <isdirempty+0x4a>
      panic("isdirempty: readi");
    if(de.inum != 0)
    80006296:	fd045783          	lhu	a5,-48(s0)
    8000629a:	e395                	bnez	a5,800062be <isdirempty+0x5e>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000629c:	24c1                	addiw	s1,s1,16
    8000629e:	04c92783          	lw	a5,76(s2)
    800062a2:	fcf4ede3          	bltu	s1,a5,8000627c <isdirempty+0x1c>
      return 0;
  }
  return 1;
    800062a6:	4505                	li	a0,1
    800062a8:	a821                	j	800062c0 <isdirempty+0x60>
      panic("isdirempty: readi");
    800062aa:	00004517          	auipc	a0,0x4
    800062ae:	94650513          	addi	a0,a0,-1722 # 80009bf0 <syscalls+0x310>
    800062b2:	ffffa097          	auipc	ra,0xffffa
    800062b6:	278080e7          	jalr	632(ra) # 8000052a <panic>
  return 1;
    800062ba:	4505                	li	a0,1
}
    800062bc:	8082                	ret
      return 0;
    800062be:	4501                	li	a0,0
}
    800062c0:	70a2                	ld	ra,40(sp)
    800062c2:	7402                	ld	s0,32(sp)
    800062c4:	64e2                	ld	s1,24(sp)
    800062c6:	6942                	ld	s2,16(sp)
    800062c8:	6145                	addi	sp,sp,48
    800062ca:	8082                	ret

00000000800062cc <sys_unlink>:

uint64
sys_unlink(void)
{
    800062cc:	7155                	addi	sp,sp,-208
    800062ce:	e586                	sd	ra,200(sp)
    800062d0:	e1a2                	sd	s0,192(sp)
    800062d2:	fd26                	sd	s1,184(sp)
    800062d4:	f94a                	sd	s2,176(sp)
    800062d6:	0980                	addi	s0,sp,208
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    800062d8:	08000613          	li	a2,128
    800062dc:	f4040593          	addi	a1,s0,-192
    800062e0:	4501                	li	a0,0
    800062e2:	ffffd097          	auipc	ra,0xffffd
    800062e6:	2e6080e7          	jalr	742(ra) # 800035c8 <argstr>
    800062ea:	16054363          	bltz	a0,80006450 <sys_unlink+0x184>
    return -1;

  begin_op();
    800062ee:	fffff097          	auipc	ra,0xfffff
    800062f2:	af0080e7          	jalr	-1296(ra) # 80004dde <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800062f6:	fc040593          	addi	a1,s0,-64
    800062fa:	f4040513          	addi	a0,s0,-192
    800062fe:	ffffe097          	auipc	ra,0xffffe
    80006302:	5cc080e7          	jalr	1484(ra) # 800048ca <nameiparent>
    80006306:	84aa                	mv	s1,a0
    80006308:	c961                	beqz	a0,800063d8 <sys_unlink+0x10c>
    end_op();
    return -1;
  }

  ilock(dp);
    8000630a:	ffffe097          	auipc	ra,0xffffe
    8000630e:	dec080e7          	jalr	-532(ra) # 800040f6 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006312:	00003597          	auipc	a1,0x3
    80006316:	7be58593          	addi	a1,a1,1982 # 80009ad0 <syscalls+0x1f0>
    8000631a:	fc040513          	addi	a0,s0,-64
    8000631e:	ffffe097          	auipc	ra,0xffffe
    80006322:	2a2080e7          	jalr	674(ra) # 800045c0 <namecmp>
    80006326:	c175                	beqz	a0,8000640a <sys_unlink+0x13e>
    80006328:	00003597          	auipc	a1,0x3
    8000632c:	7b058593          	addi	a1,a1,1968 # 80009ad8 <syscalls+0x1f8>
    80006330:	fc040513          	addi	a0,s0,-64
    80006334:	ffffe097          	auipc	ra,0xffffe
    80006338:	28c080e7          	jalr	652(ra) # 800045c0 <namecmp>
    8000633c:	c579                	beqz	a0,8000640a <sys_unlink+0x13e>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    8000633e:	f3c40613          	addi	a2,s0,-196
    80006342:	fc040593          	addi	a1,s0,-64
    80006346:	8526                	mv	a0,s1
    80006348:	ffffe097          	auipc	ra,0xffffe
    8000634c:	292080e7          	jalr	658(ra) # 800045da <dirlookup>
    80006350:	892a                	mv	s2,a0
    80006352:	cd45                	beqz	a0,8000640a <sys_unlink+0x13e>
    goto bad;
  ilock(ip);
    80006354:	ffffe097          	auipc	ra,0xffffe
    80006358:	da2080e7          	jalr	-606(ra) # 800040f6 <ilock>

  if(ip->nlink < 1)
    8000635c:	04a91783          	lh	a5,74(s2)
    80006360:	08f05263          	blez	a5,800063e4 <sys_unlink+0x118>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006364:	04491703          	lh	a4,68(s2)
    80006368:	4785                	li	a5,1
    8000636a:	08f70563          	beq	a4,a5,800063f4 <sys_unlink+0x128>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    8000636e:	4641                	li	a2,16
    80006370:	4581                	li	a1,0
    80006372:	fd040513          	addi	a0,s0,-48
    80006376:	ffffb097          	auipc	ra,0xffffb
    8000637a:	948080e7          	jalr	-1720(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000637e:	4741                	li	a4,16
    80006380:	f3c42683          	lw	a3,-196(s0)
    80006384:	fd040613          	addi	a2,s0,-48
    80006388:	4581                	li	a1,0
    8000638a:	8526                	mv	a0,s1
    8000638c:	ffffe097          	auipc	ra,0xffffe
    80006390:	116080e7          	jalr	278(ra) # 800044a2 <writei>
    80006394:	47c1                	li	a5,16
    80006396:	08f51a63          	bne	a0,a5,8000642a <sys_unlink+0x15e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    8000639a:	04491703          	lh	a4,68(s2)
    8000639e:	4785                	li	a5,1
    800063a0:	08f70d63          	beq	a4,a5,8000643a <sys_unlink+0x16e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    800063a4:	8526                	mv	a0,s1
    800063a6:	ffffe097          	auipc	ra,0xffffe
    800063aa:	fb2080e7          	jalr	-78(ra) # 80004358 <iunlockput>

  ip->nlink--;
    800063ae:	04a95783          	lhu	a5,74(s2)
    800063b2:	37fd                	addiw	a5,a5,-1
    800063b4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800063b8:	854a                	mv	a0,s2
    800063ba:	ffffe097          	auipc	ra,0xffffe
    800063be:	c72080e7          	jalr	-910(ra) # 8000402c <iupdate>
  iunlockput(ip);
    800063c2:	854a                	mv	a0,s2
    800063c4:	ffffe097          	auipc	ra,0xffffe
    800063c8:	f94080e7          	jalr	-108(ra) # 80004358 <iunlockput>

  end_op();
    800063cc:	fffff097          	auipc	ra,0xfffff
    800063d0:	a92080e7          	jalr	-1390(ra) # 80004e5e <end_op>

  return 0;
    800063d4:	4501                	li	a0,0
    800063d6:	a0a1                	j	8000641e <sys_unlink+0x152>
    end_op();
    800063d8:	fffff097          	auipc	ra,0xfffff
    800063dc:	a86080e7          	jalr	-1402(ra) # 80004e5e <end_op>
    return -1;
    800063e0:	557d                	li	a0,-1
    800063e2:	a835                	j	8000641e <sys_unlink+0x152>
    panic("unlink: nlink < 1");
    800063e4:	00003517          	auipc	a0,0x3
    800063e8:	6fc50513          	addi	a0,a0,1788 # 80009ae0 <syscalls+0x200>
    800063ec:	ffffa097          	auipc	ra,0xffffa
    800063f0:	13e080e7          	jalr	318(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800063f4:	854a                	mv	a0,s2
    800063f6:	00000097          	auipc	ra,0x0
    800063fa:	e6a080e7          	jalr	-406(ra) # 80006260 <isdirempty>
    800063fe:	f925                	bnez	a0,8000636e <sys_unlink+0xa2>
    iunlockput(ip);
    80006400:	854a                	mv	a0,s2
    80006402:	ffffe097          	auipc	ra,0xffffe
    80006406:	f56080e7          	jalr	-170(ra) # 80004358 <iunlockput>

bad:
  iunlockput(dp);
    8000640a:	8526                	mv	a0,s1
    8000640c:	ffffe097          	auipc	ra,0xffffe
    80006410:	f4c080e7          	jalr	-180(ra) # 80004358 <iunlockput>
  end_op();
    80006414:	fffff097          	auipc	ra,0xfffff
    80006418:	a4a080e7          	jalr	-1462(ra) # 80004e5e <end_op>
  return -1;
    8000641c:	557d                	li	a0,-1
}
    8000641e:	60ae                	ld	ra,200(sp)
    80006420:	640e                	ld	s0,192(sp)
    80006422:	74ea                	ld	s1,184(sp)
    80006424:	794a                	ld	s2,176(sp)
    80006426:	6169                	addi	sp,sp,208
    80006428:	8082                	ret
    panic("unlink: writei");
    8000642a:	00003517          	auipc	a0,0x3
    8000642e:	6ce50513          	addi	a0,a0,1742 # 80009af8 <syscalls+0x218>
    80006432:	ffffa097          	auipc	ra,0xffffa
    80006436:	0f8080e7          	jalr	248(ra) # 8000052a <panic>
    dp->nlink--;
    8000643a:	04a4d783          	lhu	a5,74(s1)
    8000643e:	37fd                	addiw	a5,a5,-1
    80006440:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006444:	8526                	mv	a0,s1
    80006446:	ffffe097          	auipc	ra,0xffffe
    8000644a:	be6080e7          	jalr	-1050(ra) # 8000402c <iupdate>
    8000644e:	bf99                	j	800063a4 <sys_unlink+0xd8>
    return -1;
    80006450:	557d                	li	a0,-1
    80006452:	b7f1                	j	8000641e <sys_unlink+0x152>

0000000080006454 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
    80006454:	715d                	addi	sp,sp,-80
    80006456:	e486                	sd	ra,72(sp)
    80006458:	e0a2                	sd	s0,64(sp)
    8000645a:	fc26                	sd	s1,56(sp)
    8000645c:	f84a                	sd	s2,48(sp)
    8000645e:	f44e                	sd	s3,40(sp)
    80006460:	f052                	sd	s4,32(sp)
    80006462:	ec56                	sd	s5,24(sp)
    80006464:	0880                	addi	s0,sp,80
    80006466:	89ae                	mv	s3,a1
    80006468:	8ab2                	mv	s5,a2
    8000646a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000646c:	fb040593          	addi	a1,s0,-80
    80006470:	ffffe097          	auipc	ra,0xffffe
    80006474:	45a080e7          	jalr	1114(ra) # 800048ca <nameiparent>
    80006478:	892a                	mv	s2,a0
    8000647a:	12050e63          	beqz	a0,800065b6 <create+0x162>
    return 0;

  ilock(dp);
    8000647e:	ffffe097          	auipc	ra,0xffffe
    80006482:	c78080e7          	jalr	-904(ra) # 800040f6 <ilock>
  
  if((ip = dirlookup(dp, name, 0)) != 0){
    80006486:	4601                	li	a2,0
    80006488:	fb040593          	addi	a1,s0,-80
    8000648c:	854a                	mv	a0,s2
    8000648e:	ffffe097          	auipc	ra,0xffffe
    80006492:	14c080e7          	jalr	332(ra) # 800045da <dirlookup>
    80006496:	84aa                	mv	s1,a0
    80006498:	c921                	beqz	a0,800064e8 <create+0x94>
    iunlockput(dp);
    8000649a:	854a                	mv	a0,s2
    8000649c:	ffffe097          	auipc	ra,0xffffe
    800064a0:	ebc080e7          	jalr	-324(ra) # 80004358 <iunlockput>
    ilock(ip);
    800064a4:	8526                	mv	a0,s1
    800064a6:	ffffe097          	auipc	ra,0xffffe
    800064aa:	c50080e7          	jalr	-944(ra) # 800040f6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800064ae:	2981                	sext.w	s3,s3
    800064b0:	4789                	li	a5,2
    800064b2:	02f99463          	bne	s3,a5,800064da <create+0x86>
    800064b6:	0444d783          	lhu	a5,68(s1)
    800064ba:	37f9                	addiw	a5,a5,-2
    800064bc:	17c2                	slli	a5,a5,0x30
    800064be:	93c1                	srli	a5,a5,0x30
    800064c0:	4705                	li	a4,1
    800064c2:	00f76c63          	bltu	a4,a5,800064da <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800064c6:	8526                	mv	a0,s1
    800064c8:	60a6                	ld	ra,72(sp)
    800064ca:	6406                	ld	s0,64(sp)
    800064cc:	74e2                	ld	s1,56(sp)
    800064ce:	7942                	ld	s2,48(sp)
    800064d0:	79a2                	ld	s3,40(sp)
    800064d2:	7a02                	ld	s4,32(sp)
    800064d4:	6ae2                	ld	s5,24(sp)
    800064d6:	6161                	addi	sp,sp,80
    800064d8:	8082                	ret
    iunlockput(ip);
    800064da:	8526                	mv	a0,s1
    800064dc:	ffffe097          	auipc	ra,0xffffe
    800064e0:	e7c080e7          	jalr	-388(ra) # 80004358 <iunlockput>
    return 0;
    800064e4:	4481                	li	s1,0
    800064e6:	b7c5                	j	800064c6 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800064e8:	85ce                	mv	a1,s3
    800064ea:	00092503          	lw	a0,0(s2)
    800064ee:	ffffe097          	auipc	ra,0xffffe
    800064f2:	a70080e7          	jalr	-1424(ra) # 80003f5e <ialloc>
    800064f6:	84aa                	mv	s1,a0
    800064f8:	c521                	beqz	a0,80006540 <create+0xec>
  ilock(ip);
    800064fa:	ffffe097          	auipc	ra,0xffffe
    800064fe:	bfc080e7          	jalr	-1028(ra) # 800040f6 <ilock>
  ip->major = major;
    80006502:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80006506:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000650a:	4a05                	li	s4,1
    8000650c:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80006510:	8526                	mv	a0,s1
    80006512:	ffffe097          	auipc	ra,0xffffe
    80006516:	b1a080e7          	jalr	-1254(ra) # 8000402c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000651a:	2981                	sext.w	s3,s3
    8000651c:	03498a63          	beq	s3,s4,80006550 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80006520:	40d0                	lw	a2,4(s1)
    80006522:	fb040593          	addi	a1,s0,-80
    80006526:	854a                	mv	a0,s2
    80006528:	ffffe097          	auipc	ra,0xffffe
    8000652c:	2c2080e7          	jalr	706(ra) # 800047ea <dirlink>
    80006530:	06054b63          	bltz	a0,800065a6 <create+0x152>
  iunlockput(dp);
    80006534:	854a                	mv	a0,s2
    80006536:	ffffe097          	auipc	ra,0xffffe
    8000653a:	e22080e7          	jalr	-478(ra) # 80004358 <iunlockput>
  return ip;
    8000653e:	b761                	j	800064c6 <create+0x72>
    panic("create: ialloc");
    80006540:	00003517          	auipc	a0,0x3
    80006544:	6c850513          	addi	a0,a0,1736 # 80009c08 <syscalls+0x328>
    80006548:	ffffa097          	auipc	ra,0xffffa
    8000654c:	fe2080e7          	jalr	-30(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    80006550:	04a95783          	lhu	a5,74(s2)
    80006554:	2785                	addiw	a5,a5,1
    80006556:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000655a:	854a                	mv	a0,s2
    8000655c:	ffffe097          	auipc	ra,0xffffe
    80006560:	ad0080e7          	jalr	-1328(ra) # 8000402c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80006564:	40d0                	lw	a2,4(s1)
    80006566:	00003597          	auipc	a1,0x3
    8000656a:	56a58593          	addi	a1,a1,1386 # 80009ad0 <syscalls+0x1f0>
    8000656e:	8526                	mv	a0,s1
    80006570:	ffffe097          	auipc	ra,0xffffe
    80006574:	27a080e7          	jalr	634(ra) # 800047ea <dirlink>
    80006578:	00054f63          	bltz	a0,80006596 <create+0x142>
    8000657c:	00492603          	lw	a2,4(s2)
    80006580:	00003597          	auipc	a1,0x3
    80006584:	55858593          	addi	a1,a1,1368 # 80009ad8 <syscalls+0x1f8>
    80006588:	8526                	mv	a0,s1
    8000658a:	ffffe097          	auipc	ra,0xffffe
    8000658e:	260080e7          	jalr	608(ra) # 800047ea <dirlink>
    80006592:	f80557e3          	bgez	a0,80006520 <create+0xcc>
      panic("create dots");
    80006596:	00003517          	auipc	a0,0x3
    8000659a:	68250513          	addi	a0,a0,1666 # 80009c18 <syscalls+0x338>
    8000659e:	ffffa097          	auipc	ra,0xffffa
    800065a2:	f8c080e7          	jalr	-116(ra) # 8000052a <panic>
    panic("create: dirlink");
    800065a6:	00003517          	auipc	a0,0x3
    800065aa:	68250513          	addi	a0,a0,1666 # 80009c28 <syscalls+0x348>
    800065ae:	ffffa097          	auipc	ra,0xffffa
    800065b2:	f7c080e7          	jalr	-132(ra) # 8000052a <panic>
    return 0;
    800065b6:	84aa                	mv	s1,a0
    800065b8:	b739                	j	800064c6 <create+0x72>

00000000800065ba <sys_open>:

uint64
sys_open(void)
{
    800065ba:	7131                	addi	sp,sp,-192
    800065bc:	fd06                	sd	ra,184(sp)
    800065be:	f922                	sd	s0,176(sp)
    800065c0:	f526                	sd	s1,168(sp)
    800065c2:	f14a                	sd	s2,160(sp)
    800065c4:	ed4e                	sd	s3,152(sp)
    800065c6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800065c8:	08000613          	li	a2,128
    800065cc:	f5040593          	addi	a1,s0,-176
    800065d0:	4501                	li	a0,0
    800065d2:	ffffd097          	auipc	ra,0xffffd
    800065d6:	ff6080e7          	jalr	-10(ra) # 800035c8 <argstr>
    return -1;
    800065da:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800065dc:	0c054163          	bltz	a0,8000669e <sys_open+0xe4>
    800065e0:	f4c40593          	addi	a1,s0,-180
    800065e4:	4505                	li	a0,1
    800065e6:	ffffd097          	auipc	ra,0xffffd
    800065ea:	f9e080e7          	jalr	-98(ra) # 80003584 <argint>
    800065ee:	0a054863          	bltz	a0,8000669e <sys_open+0xe4>

  begin_op();
    800065f2:	ffffe097          	auipc	ra,0xffffe
    800065f6:	7ec080e7          	jalr	2028(ra) # 80004dde <begin_op>

  if(omode & O_CREATE){
    800065fa:	f4c42783          	lw	a5,-180(s0)
    800065fe:	2007f793          	andi	a5,a5,512
    80006602:	cbdd                	beqz	a5,800066b8 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80006604:	4681                	li	a3,0
    80006606:	4601                	li	a2,0
    80006608:	4589                	li	a1,2
    8000660a:	f5040513          	addi	a0,s0,-176
    8000660e:	00000097          	auipc	ra,0x0
    80006612:	e46080e7          	jalr	-442(ra) # 80006454 <create>
    80006616:	892a                	mv	s2,a0
    if(ip == 0){
    80006618:	c959                	beqz	a0,800066ae <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000661a:	04491703          	lh	a4,68(s2)
    8000661e:	478d                	li	a5,3
    80006620:	00f71763          	bne	a4,a5,8000662e <sys_open+0x74>
    80006624:	04695703          	lhu	a4,70(s2)
    80006628:	47a5                	li	a5,9
    8000662a:	0ce7ec63          	bltu	a5,a4,80006702 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000662e:	fffff097          	auipc	ra,0xfffff
    80006632:	bc0080e7          	jalr	-1088(ra) # 800051ee <filealloc>
    80006636:	89aa                	mv	s3,a0
    80006638:	10050263          	beqz	a0,8000673c <sys_open+0x182>
    8000663c:	00000097          	auipc	ra,0x0
    80006640:	8e2080e7          	jalr	-1822(ra) # 80005f1e <fdalloc>
    80006644:	84aa                	mv	s1,a0
    80006646:	0e054663          	bltz	a0,80006732 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000664a:	04491703          	lh	a4,68(s2)
    8000664e:	478d                	li	a5,3
    80006650:	0cf70463          	beq	a4,a5,80006718 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006654:	4789                	li	a5,2
    80006656:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000665a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000665e:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80006662:	f4c42783          	lw	a5,-180(s0)
    80006666:	0017c713          	xori	a4,a5,1
    8000666a:	8b05                	andi	a4,a4,1
    8000666c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006670:	0037f713          	andi	a4,a5,3
    80006674:	00e03733          	snez	a4,a4
    80006678:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000667c:	4007f793          	andi	a5,a5,1024
    80006680:	c791                	beqz	a5,8000668c <sys_open+0xd2>
    80006682:	04491703          	lh	a4,68(s2)
    80006686:	4789                	li	a5,2
    80006688:	08f70f63          	beq	a4,a5,80006726 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000668c:	854a                	mv	a0,s2
    8000668e:	ffffe097          	auipc	ra,0xffffe
    80006692:	b2a080e7          	jalr	-1238(ra) # 800041b8 <iunlock>
  end_op();
    80006696:	ffffe097          	auipc	ra,0xffffe
    8000669a:	7c8080e7          	jalr	1992(ra) # 80004e5e <end_op>

  return fd;
}
    8000669e:	8526                	mv	a0,s1
    800066a0:	70ea                	ld	ra,184(sp)
    800066a2:	744a                	ld	s0,176(sp)
    800066a4:	74aa                	ld	s1,168(sp)
    800066a6:	790a                	ld	s2,160(sp)
    800066a8:	69ea                	ld	s3,152(sp)
    800066aa:	6129                	addi	sp,sp,192
    800066ac:	8082                	ret
      end_op();
    800066ae:	ffffe097          	auipc	ra,0xffffe
    800066b2:	7b0080e7          	jalr	1968(ra) # 80004e5e <end_op>
      return -1;
    800066b6:	b7e5                	j	8000669e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800066b8:	f5040513          	addi	a0,s0,-176
    800066bc:	ffffe097          	auipc	ra,0xffffe
    800066c0:	1f0080e7          	jalr	496(ra) # 800048ac <namei>
    800066c4:	892a                	mv	s2,a0
    800066c6:	c905                	beqz	a0,800066f6 <sys_open+0x13c>
    ilock(ip);
    800066c8:	ffffe097          	auipc	ra,0xffffe
    800066cc:	a2e080e7          	jalr	-1490(ra) # 800040f6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800066d0:	04491703          	lh	a4,68(s2)
    800066d4:	4785                	li	a5,1
    800066d6:	f4f712e3          	bne	a4,a5,8000661a <sys_open+0x60>
    800066da:	f4c42783          	lw	a5,-180(s0)
    800066de:	dba1                	beqz	a5,8000662e <sys_open+0x74>
      iunlockput(ip);
    800066e0:	854a                	mv	a0,s2
    800066e2:	ffffe097          	auipc	ra,0xffffe
    800066e6:	c76080e7          	jalr	-906(ra) # 80004358 <iunlockput>
      end_op();
    800066ea:	ffffe097          	auipc	ra,0xffffe
    800066ee:	774080e7          	jalr	1908(ra) # 80004e5e <end_op>
      return -1;
    800066f2:	54fd                	li	s1,-1
    800066f4:	b76d                	j	8000669e <sys_open+0xe4>
      end_op();
    800066f6:	ffffe097          	auipc	ra,0xffffe
    800066fa:	768080e7          	jalr	1896(ra) # 80004e5e <end_op>
      return -1;
    800066fe:	54fd                	li	s1,-1
    80006700:	bf79                	j	8000669e <sys_open+0xe4>
    iunlockput(ip);
    80006702:	854a                	mv	a0,s2
    80006704:	ffffe097          	auipc	ra,0xffffe
    80006708:	c54080e7          	jalr	-940(ra) # 80004358 <iunlockput>
    end_op();
    8000670c:	ffffe097          	auipc	ra,0xffffe
    80006710:	752080e7          	jalr	1874(ra) # 80004e5e <end_op>
    return -1;
    80006714:	54fd                	li	s1,-1
    80006716:	b761                	j	8000669e <sys_open+0xe4>
    f->type = FD_DEVICE;
    80006718:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000671c:	04691783          	lh	a5,70(s2)
    80006720:	02f99223          	sh	a5,36(s3)
    80006724:	bf2d                	j	8000665e <sys_open+0xa4>
    itrunc(ip);
    80006726:	854a                	mv	a0,s2
    80006728:	ffffe097          	auipc	ra,0xffffe
    8000672c:	adc080e7          	jalr	-1316(ra) # 80004204 <itrunc>
    80006730:	bfb1                	j	8000668c <sys_open+0xd2>
      fileclose(f);
    80006732:	854e                	mv	a0,s3
    80006734:	fffff097          	auipc	ra,0xfffff
    80006738:	b76080e7          	jalr	-1162(ra) # 800052aa <fileclose>
    iunlockput(ip);
    8000673c:	854a                	mv	a0,s2
    8000673e:	ffffe097          	auipc	ra,0xffffe
    80006742:	c1a080e7          	jalr	-998(ra) # 80004358 <iunlockput>
    end_op();
    80006746:	ffffe097          	auipc	ra,0xffffe
    8000674a:	718080e7          	jalr	1816(ra) # 80004e5e <end_op>
    return -1;
    8000674e:	54fd                	li	s1,-1
    80006750:	b7b9                	j	8000669e <sys_open+0xe4>

0000000080006752 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006752:	7175                	addi	sp,sp,-144
    80006754:	e506                	sd	ra,136(sp)
    80006756:	e122                	sd	s0,128(sp)
    80006758:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000675a:	ffffe097          	auipc	ra,0xffffe
    8000675e:	684080e7          	jalr	1668(ra) # 80004dde <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006762:	08000613          	li	a2,128
    80006766:	f7040593          	addi	a1,s0,-144
    8000676a:	4501                	li	a0,0
    8000676c:	ffffd097          	auipc	ra,0xffffd
    80006770:	e5c080e7          	jalr	-420(ra) # 800035c8 <argstr>
    80006774:	02054963          	bltz	a0,800067a6 <sys_mkdir+0x54>
    80006778:	4681                	li	a3,0
    8000677a:	4601                	li	a2,0
    8000677c:	4585                	li	a1,1
    8000677e:	f7040513          	addi	a0,s0,-144
    80006782:	00000097          	auipc	ra,0x0
    80006786:	cd2080e7          	jalr	-814(ra) # 80006454 <create>
    8000678a:	cd11                	beqz	a0,800067a6 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000678c:	ffffe097          	auipc	ra,0xffffe
    80006790:	bcc080e7          	jalr	-1076(ra) # 80004358 <iunlockput>
  end_op();
    80006794:	ffffe097          	auipc	ra,0xffffe
    80006798:	6ca080e7          	jalr	1738(ra) # 80004e5e <end_op>
  return 0;
    8000679c:	4501                	li	a0,0
}
    8000679e:	60aa                	ld	ra,136(sp)
    800067a0:	640a                	ld	s0,128(sp)
    800067a2:	6149                	addi	sp,sp,144
    800067a4:	8082                	ret
    end_op();
    800067a6:	ffffe097          	auipc	ra,0xffffe
    800067aa:	6b8080e7          	jalr	1720(ra) # 80004e5e <end_op>
    return -1;
    800067ae:	557d                	li	a0,-1
    800067b0:	b7fd                	j	8000679e <sys_mkdir+0x4c>

00000000800067b2 <sys_mknod>:

uint64
sys_mknod(void)
{
    800067b2:	7135                	addi	sp,sp,-160
    800067b4:	ed06                	sd	ra,152(sp)
    800067b6:	e922                	sd	s0,144(sp)
    800067b8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800067ba:	ffffe097          	auipc	ra,0xffffe
    800067be:	624080e7          	jalr	1572(ra) # 80004dde <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800067c2:	08000613          	li	a2,128
    800067c6:	f7040593          	addi	a1,s0,-144
    800067ca:	4501                	li	a0,0
    800067cc:	ffffd097          	auipc	ra,0xffffd
    800067d0:	dfc080e7          	jalr	-516(ra) # 800035c8 <argstr>
    800067d4:	04054a63          	bltz	a0,80006828 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800067d8:	f6c40593          	addi	a1,s0,-148
    800067dc:	4505                	li	a0,1
    800067de:	ffffd097          	auipc	ra,0xffffd
    800067e2:	da6080e7          	jalr	-602(ra) # 80003584 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800067e6:	04054163          	bltz	a0,80006828 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800067ea:	f6840593          	addi	a1,s0,-152
    800067ee:	4509                	li	a0,2
    800067f0:	ffffd097          	auipc	ra,0xffffd
    800067f4:	d94080e7          	jalr	-620(ra) # 80003584 <argint>
     argint(1, &major) < 0 ||
    800067f8:	02054863          	bltz	a0,80006828 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800067fc:	f6841683          	lh	a3,-152(s0)
    80006800:	f6c41603          	lh	a2,-148(s0)
    80006804:	458d                	li	a1,3
    80006806:	f7040513          	addi	a0,s0,-144
    8000680a:	00000097          	auipc	ra,0x0
    8000680e:	c4a080e7          	jalr	-950(ra) # 80006454 <create>
     argint(2, &minor) < 0 ||
    80006812:	c919                	beqz	a0,80006828 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006814:	ffffe097          	auipc	ra,0xffffe
    80006818:	b44080e7          	jalr	-1212(ra) # 80004358 <iunlockput>
  end_op();
    8000681c:	ffffe097          	auipc	ra,0xffffe
    80006820:	642080e7          	jalr	1602(ra) # 80004e5e <end_op>
  return 0;
    80006824:	4501                	li	a0,0
    80006826:	a031                	j	80006832 <sys_mknod+0x80>
    end_op();
    80006828:	ffffe097          	auipc	ra,0xffffe
    8000682c:	636080e7          	jalr	1590(ra) # 80004e5e <end_op>
    return -1;
    80006830:	557d                	li	a0,-1
}
    80006832:	60ea                	ld	ra,152(sp)
    80006834:	644a                	ld	s0,144(sp)
    80006836:	610d                	addi	sp,sp,160
    80006838:	8082                	ret

000000008000683a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000683a:	7135                	addi	sp,sp,-160
    8000683c:	ed06                	sd	ra,152(sp)
    8000683e:	e922                	sd	s0,144(sp)
    80006840:	e526                	sd	s1,136(sp)
    80006842:	e14a                	sd	s2,128(sp)
    80006844:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006846:	ffffb097          	auipc	ra,0xffffb
    8000684a:	4ec080e7          	jalr	1260(ra) # 80001d32 <myproc>
    8000684e:	892a                	mv	s2,a0
  
  begin_op();
    80006850:	ffffe097          	auipc	ra,0xffffe
    80006854:	58e080e7          	jalr	1422(ra) # 80004dde <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006858:	08000613          	li	a2,128
    8000685c:	f6040593          	addi	a1,s0,-160
    80006860:	4501                	li	a0,0
    80006862:	ffffd097          	auipc	ra,0xffffd
    80006866:	d66080e7          	jalr	-666(ra) # 800035c8 <argstr>
    8000686a:	04054b63          	bltz	a0,800068c0 <sys_chdir+0x86>
    8000686e:	f6040513          	addi	a0,s0,-160
    80006872:	ffffe097          	auipc	ra,0xffffe
    80006876:	03a080e7          	jalr	58(ra) # 800048ac <namei>
    8000687a:	84aa                	mv	s1,a0
    8000687c:	c131                	beqz	a0,800068c0 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000687e:	ffffe097          	auipc	ra,0xffffe
    80006882:	878080e7          	jalr	-1928(ra) # 800040f6 <ilock>
  if(ip->type != T_DIR){
    80006886:	04449703          	lh	a4,68(s1)
    8000688a:	4785                	li	a5,1
    8000688c:	04f71063          	bne	a4,a5,800068cc <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006890:	8526                	mv	a0,s1
    80006892:	ffffe097          	auipc	ra,0xffffe
    80006896:	926080e7          	jalr	-1754(ra) # 800041b8 <iunlock>
  iput(p->cwd);
    8000689a:	15093503          	ld	a0,336(s2)
    8000689e:	ffffe097          	auipc	ra,0xffffe
    800068a2:	a12080e7          	jalr	-1518(ra) # 800042b0 <iput>
  end_op();
    800068a6:	ffffe097          	auipc	ra,0xffffe
    800068aa:	5b8080e7          	jalr	1464(ra) # 80004e5e <end_op>
  p->cwd = ip;
    800068ae:	14993823          	sd	s1,336(s2)
  return 0;
    800068b2:	4501                	li	a0,0
}
    800068b4:	60ea                	ld	ra,152(sp)
    800068b6:	644a                	ld	s0,144(sp)
    800068b8:	64aa                	ld	s1,136(sp)
    800068ba:	690a                	ld	s2,128(sp)
    800068bc:	610d                	addi	sp,sp,160
    800068be:	8082                	ret
    end_op();
    800068c0:	ffffe097          	auipc	ra,0xffffe
    800068c4:	59e080e7          	jalr	1438(ra) # 80004e5e <end_op>
    return -1;
    800068c8:	557d                	li	a0,-1
    800068ca:	b7ed                	j	800068b4 <sys_chdir+0x7a>
    iunlockput(ip);
    800068cc:	8526                	mv	a0,s1
    800068ce:	ffffe097          	auipc	ra,0xffffe
    800068d2:	a8a080e7          	jalr	-1398(ra) # 80004358 <iunlockput>
    end_op();
    800068d6:	ffffe097          	auipc	ra,0xffffe
    800068da:	588080e7          	jalr	1416(ra) # 80004e5e <end_op>
    return -1;
    800068de:	557d                	li	a0,-1
    800068e0:	bfd1                	j	800068b4 <sys_chdir+0x7a>

00000000800068e2 <sys_exec>:

uint64
sys_exec(void)
{
    800068e2:	7145                	addi	sp,sp,-464
    800068e4:	e786                	sd	ra,456(sp)
    800068e6:	e3a2                	sd	s0,448(sp)
    800068e8:	ff26                	sd	s1,440(sp)
    800068ea:	fb4a                	sd	s2,432(sp)
    800068ec:	f74e                	sd	s3,424(sp)
    800068ee:	f352                	sd	s4,416(sp)
    800068f0:	ef56                	sd	s5,408(sp)
    800068f2:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800068f4:	08000613          	li	a2,128
    800068f8:	f4040593          	addi	a1,s0,-192
    800068fc:	4501                	li	a0,0
    800068fe:	ffffd097          	auipc	ra,0xffffd
    80006902:	cca080e7          	jalr	-822(ra) # 800035c8 <argstr>
    return -1;
    80006906:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006908:	0c054a63          	bltz	a0,800069dc <sys_exec+0xfa>
    8000690c:	e3840593          	addi	a1,s0,-456
    80006910:	4505                	li	a0,1
    80006912:	ffffd097          	auipc	ra,0xffffd
    80006916:	c94080e7          	jalr	-876(ra) # 800035a6 <argaddr>
    8000691a:	0c054163          	bltz	a0,800069dc <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    8000691e:	10000613          	li	a2,256
    80006922:	4581                	li	a1,0
    80006924:	e4040513          	addi	a0,s0,-448
    80006928:	ffffa097          	auipc	ra,0xffffa
    8000692c:	396080e7          	jalr	918(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006930:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006934:	89a6                	mv	s3,s1
    80006936:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006938:	02000a13          	li	s4,32
    8000693c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006940:	00391793          	slli	a5,s2,0x3
    80006944:	e3040593          	addi	a1,s0,-464
    80006948:	e3843503          	ld	a0,-456(s0)
    8000694c:	953e                	add	a0,a0,a5
    8000694e:	ffffd097          	auipc	ra,0xffffd
    80006952:	b9c080e7          	jalr	-1124(ra) # 800034ea <fetchaddr>
    80006956:	02054a63          	bltz	a0,8000698a <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    8000695a:	e3043783          	ld	a5,-464(s0)
    8000695e:	c3b9                	beqz	a5,800069a4 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006960:	ffffa097          	auipc	ra,0xffffa
    80006964:	172080e7          	jalr	370(ra) # 80000ad2 <kalloc>
    80006968:	85aa                	mv	a1,a0
    8000696a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000696e:	cd11                	beqz	a0,8000698a <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006970:	6605                	lui	a2,0x1
    80006972:	e3043503          	ld	a0,-464(s0)
    80006976:	ffffd097          	auipc	ra,0xffffd
    8000697a:	bc6080e7          	jalr	-1082(ra) # 8000353c <fetchstr>
    8000697e:	00054663          	bltz	a0,8000698a <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006982:	0905                	addi	s2,s2,1
    80006984:	09a1                	addi	s3,s3,8
    80006986:	fb491be3          	bne	s2,s4,8000693c <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000698a:	10048913          	addi	s2,s1,256
    8000698e:	6088                	ld	a0,0(s1)
    80006990:	c529                	beqz	a0,800069da <sys_exec+0xf8>
    kfree(argv[i]);
    80006992:	ffffa097          	auipc	ra,0xffffa
    80006996:	044080e7          	jalr	68(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000699a:	04a1                	addi	s1,s1,8
    8000699c:	ff2499e3          	bne	s1,s2,8000698e <sys_exec+0xac>
  return -1;
    800069a0:	597d                	li	s2,-1
    800069a2:	a82d                	j	800069dc <sys_exec+0xfa>
      argv[i] = 0;
    800069a4:	0a8e                	slli	s5,s5,0x3
    800069a6:	fc040793          	addi	a5,s0,-64
    800069aa:	9abe                	add	s5,s5,a5
    800069ac:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffcbe80>
  int ret = exec(path, argv);
    800069b0:	e4040593          	addi	a1,s0,-448
    800069b4:	f4040513          	addi	a0,s0,-192
    800069b8:	fffff097          	auipc	ra,0xfffff
    800069bc:	13a080e7          	jalr	314(ra) # 80005af2 <exec>
    800069c0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800069c2:	10048993          	addi	s3,s1,256
    800069c6:	6088                	ld	a0,0(s1)
    800069c8:	c911                	beqz	a0,800069dc <sys_exec+0xfa>
    kfree(argv[i]);
    800069ca:	ffffa097          	auipc	ra,0xffffa
    800069ce:	00c080e7          	jalr	12(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800069d2:	04a1                	addi	s1,s1,8
    800069d4:	ff3499e3          	bne	s1,s3,800069c6 <sys_exec+0xe4>
    800069d8:	a011                	j	800069dc <sys_exec+0xfa>
  return -1;
    800069da:	597d                	li	s2,-1
}
    800069dc:	854a                	mv	a0,s2
    800069de:	60be                	ld	ra,456(sp)
    800069e0:	641e                	ld	s0,448(sp)
    800069e2:	74fa                	ld	s1,440(sp)
    800069e4:	795a                	ld	s2,432(sp)
    800069e6:	79ba                	ld	s3,424(sp)
    800069e8:	7a1a                	ld	s4,416(sp)
    800069ea:	6afa                	ld	s5,408(sp)
    800069ec:	6179                	addi	sp,sp,464
    800069ee:	8082                	ret

00000000800069f0 <sys_pipe>:

uint64
sys_pipe(void)
{
    800069f0:	7139                	addi	sp,sp,-64
    800069f2:	fc06                	sd	ra,56(sp)
    800069f4:	f822                	sd	s0,48(sp)
    800069f6:	f426                	sd	s1,40(sp)
    800069f8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800069fa:	ffffb097          	auipc	ra,0xffffb
    800069fe:	338080e7          	jalr	824(ra) # 80001d32 <myproc>
    80006a02:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006a04:	fd840593          	addi	a1,s0,-40
    80006a08:	4501                	li	a0,0
    80006a0a:	ffffd097          	auipc	ra,0xffffd
    80006a0e:	b9c080e7          	jalr	-1124(ra) # 800035a6 <argaddr>
    return -1;
    80006a12:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006a14:	0e054063          	bltz	a0,80006af4 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006a18:	fc840593          	addi	a1,s0,-56
    80006a1c:	fd040513          	addi	a0,s0,-48
    80006a20:	fffff097          	auipc	ra,0xfffff
    80006a24:	db0080e7          	jalr	-592(ra) # 800057d0 <pipealloc>
    return -1;
    80006a28:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006a2a:	0c054563          	bltz	a0,80006af4 <sys_pipe+0x104>
  fd0 = -1;
    80006a2e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006a32:	fd043503          	ld	a0,-48(s0)
    80006a36:	fffff097          	auipc	ra,0xfffff
    80006a3a:	4e8080e7          	jalr	1256(ra) # 80005f1e <fdalloc>
    80006a3e:	fca42223          	sw	a0,-60(s0)
    80006a42:	08054c63          	bltz	a0,80006ada <sys_pipe+0xea>
    80006a46:	fc843503          	ld	a0,-56(s0)
    80006a4a:	fffff097          	auipc	ra,0xfffff
    80006a4e:	4d4080e7          	jalr	1236(ra) # 80005f1e <fdalloc>
    80006a52:	fca42023          	sw	a0,-64(s0)
    80006a56:	06054863          	bltz	a0,80006ac6 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006a5a:	4691                	li	a3,4
    80006a5c:	fc440613          	addi	a2,s0,-60
    80006a60:	fd843583          	ld	a1,-40(s0)
    80006a64:	68a8                	ld	a0,80(s1)
    80006a66:	ffffb097          	auipc	ra,0xffffb
    80006a6a:	944080e7          	jalr	-1724(ra) # 800013aa <copyout>
    80006a6e:	02054063          	bltz	a0,80006a8e <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006a72:	4691                	li	a3,4
    80006a74:	fc040613          	addi	a2,s0,-64
    80006a78:	fd843583          	ld	a1,-40(s0)
    80006a7c:	0591                	addi	a1,a1,4
    80006a7e:	68a8                	ld	a0,80(s1)
    80006a80:	ffffb097          	auipc	ra,0xffffb
    80006a84:	92a080e7          	jalr	-1750(ra) # 800013aa <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006a88:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006a8a:	06055563          	bgez	a0,80006af4 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006a8e:	fc442783          	lw	a5,-60(s0)
    80006a92:	07e9                	addi	a5,a5,26
    80006a94:	078e                	slli	a5,a5,0x3
    80006a96:	97a6                	add	a5,a5,s1
    80006a98:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006a9c:	fc042503          	lw	a0,-64(s0)
    80006aa0:	0569                	addi	a0,a0,26
    80006aa2:	050e                	slli	a0,a0,0x3
    80006aa4:	9526                	add	a0,a0,s1
    80006aa6:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006aaa:	fd043503          	ld	a0,-48(s0)
    80006aae:	ffffe097          	auipc	ra,0xffffe
    80006ab2:	7fc080e7          	jalr	2044(ra) # 800052aa <fileclose>
    fileclose(wf);
    80006ab6:	fc843503          	ld	a0,-56(s0)
    80006aba:	ffffe097          	auipc	ra,0xffffe
    80006abe:	7f0080e7          	jalr	2032(ra) # 800052aa <fileclose>
    return -1;
    80006ac2:	57fd                	li	a5,-1
    80006ac4:	a805                	j	80006af4 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006ac6:	fc442783          	lw	a5,-60(s0)
    80006aca:	0007c863          	bltz	a5,80006ada <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006ace:	01a78513          	addi	a0,a5,26
    80006ad2:	050e                	slli	a0,a0,0x3
    80006ad4:	9526                	add	a0,a0,s1
    80006ad6:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006ada:	fd043503          	ld	a0,-48(s0)
    80006ade:	ffffe097          	auipc	ra,0xffffe
    80006ae2:	7cc080e7          	jalr	1996(ra) # 800052aa <fileclose>
    fileclose(wf);
    80006ae6:	fc843503          	ld	a0,-56(s0)
    80006aea:	ffffe097          	auipc	ra,0xffffe
    80006aee:	7c0080e7          	jalr	1984(ra) # 800052aa <fileclose>
    return -1;
    80006af2:	57fd                	li	a5,-1
}
    80006af4:	853e                	mv	a0,a5
    80006af6:	70e2                	ld	ra,56(sp)
    80006af8:	7442                	ld	s0,48(sp)
    80006afa:	74a2                	ld	s1,40(sp)
    80006afc:	6121                	addi	sp,sp,64
    80006afe:	8082                	ret

0000000080006b00 <kernelvec>:
    80006b00:	7111                	addi	sp,sp,-256
    80006b02:	e006                	sd	ra,0(sp)
    80006b04:	e40a                	sd	sp,8(sp)
    80006b06:	e80e                	sd	gp,16(sp)
    80006b08:	ec12                	sd	tp,24(sp)
    80006b0a:	f016                	sd	t0,32(sp)
    80006b0c:	f41a                	sd	t1,40(sp)
    80006b0e:	f81e                	sd	t2,48(sp)
    80006b10:	fc22                	sd	s0,56(sp)
    80006b12:	e0a6                	sd	s1,64(sp)
    80006b14:	e4aa                	sd	a0,72(sp)
    80006b16:	e8ae                	sd	a1,80(sp)
    80006b18:	ecb2                	sd	a2,88(sp)
    80006b1a:	f0b6                	sd	a3,96(sp)
    80006b1c:	f4ba                	sd	a4,104(sp)
    80006b1e:	f8be                	sd	a5,112(sp)
    80006b20:	fcc2                	sd	a6,120(sp)
    80006b22:	e146                	sd	a7,128(sp)
    80006b24:	e54a                	sd	s2,136(sp)
    80006b26:	e94e                	sd	s3,144(sp)
    80006b28:	ed52                	sd	s4,152(sp)
    80006b2a:	f156                	sd	s5,160(sp)
    80006b2c:	f55a                	sd	s6,168(sp)
    80006b2e:	f95e                	sd	s7,176(sp)
    80006b30:	fd62                	sd	s8,184(sp)
    80006b32:	e1e6                	sd	s9,192(sp)
    80006b34:	e5ea                	sd	s10,200(sp)
    80006b36:	e9ee                	sd	s11,208(sp)
    80006b38:	edf2                	sd	t3,216(sp)
    80006b3a:	f1f6                	sd	t4,224(sp)
    80006b3c:	f5fa                	sd	t5,232(sp)
    80006b3e:	f9fe                	sd	t6,240(sp)
    80006b40:	85dfc0ef          	jal	ra,8000339c <kerneltrap>
    80006b44:	6082                	ld	ra,0(sp)
    80006b46:	6122                	ld	sp,8(sp)
    80006b48:	61c2                	ld	gp,16(sp)
    80006b4a:	7282                	ld	t0,32(sp)
    80006b4c:	7322                	ld	t1,40(sp)
    80006b4e:	73c2                	ld	t2,48(sp)
    80006b50:	7462                	ld	s0,56(sp)
    80006b52:	6486                	ld	s1,64(sp)
    80006b54:	6526                	ld	a0,72(sp)
    80006b56:	65c6                	ld	a1,80(sp)
    80006b58:	6666                	ld	a2,88(sp)
    80006b5a:	7686                	ld	a3,96(sp)
    80006b5c:	7726                	ld	a4,104(sp)
    80006b5e:	77c6                	ld	a5,112(sp)
    80006b60:	7866                	ld	a6,120(sp)
    80006b62:	688a                	ld	a7,128(sp)
    80006b64:	692a                	ld	s2,136(sp)
    80006b66:	69ca                	ld	s3,144(sp)
    80006b68:	6a6a                	ld	s4,152(sp)
    80006b6a:	7a8a                	ld	s5,160(sp)
    80006b6c:	7b2a                	ld	s6,168(sp)
    80006b6e:	7bca                	ld	s7,176(sp)
    80006b70:	7c6a                	ld	s8,184(sp)
    80006b72:	6c8e                	ld	s9,192(sp)
    80006b74:	6d2e                	ld	s10,200(sp)
    80006b76:	6dce                	ld	s11,208(sp)
    80006b78:	6e6e                	ld	t3,216(sp)
    80006b7a:	7e8e                	ld	t4,224(sp)
    80006b7c:	7f2e                	ld	t5,232(sp)
    80006b7e:	7fce                	ld	t6,240(sp)
    80006b80:	6111                	addi	sp,sp,256
    80006b82:	10200073          	sret
    80006b86:	00000013          	nop
    80006b8a:	00000013          	nop
    80006b8e:	0001                	nop

0000000080006b90 <timervec>:
    80006b90:	34051573          	csrrw	a0,mscratch,a0
    80006b94:	e10c                	sd	a1,0(a0)
    80006b96:	e510                	sd	a2,8(a0)
    80006b98:	e914                	sd	a3,16(a0)
    80006b9a:	6d0c                	ld	a1,24(a0)
    80006b9c:	7110                	ld	a2,32(a0)
    80006b9e:	6194                	ld	a3,0(a1)
    80006ba0:	96b2                	add	a3,a3,a2
    80006ba2:	e194                	sd	a3,0(a1)
    80006ba4:	4589                	li	a1,2
    80006ba6:	14459073          	csrw	sip,a1
    80006baa:	6914                	ld	a3,16(a0)
    80006bac:	6510                	ld	a2,8(a0)
    80006bae:	610c                	ld	a1,0(a0)
    80006bb0:	34051573          	csrrw	a0,mscratch,a0
    80006bb4:	30200073          	mret
	...

0000000080006bba <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006bba:	1141                	addi	sp,sp,-16
    80006bbc:	e422                	sd	s0,8(sp)
    80006bbe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006bc0:	0c0007b7          	lui	a5,0xc000
    80006bc4:	4705                	li	a4,1
    80006bc6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006bc8:	c3d8                	sw	a4,4(a5)
}
    80006bca:	6422                	ld	s0,8(sp)
    80006bcc:	0141                	addi	sp,sp,16
    80006bce:	8082                	ret

0000000080006bd0 <plicinithart>:

void
plicinithart(void)
{
    80006bd0:	1141                	addi	sp,sp,-16
    80006bd2:	e406                	sd	ra,8(sp)
    80006bd4:	e022                	sd	s0,0(sp)
    80006bd6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006bd8:	ffffb097          	auipc	ra,0xffffb
    80006bdc:	12e080e7          	jalr	302(ra) # 80001d06 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006be0:	0085171b          	slliw	a4,a0,0x8
    80006be4:	0c0027b7          	lui	a5,0xc002
    80006be8:	97ba                	add	a5,a5,a4
    80006bea:	40200713          	li	a4,1026
    80006bee:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006bf2:	00d5151b          	slliw	a0,a0,0xd
    80006bf6:	0c2017b7          	lui	a5,0xc201
    80006bfa:	953e                	add	a0,a0,a5
    80006bfc:	00052023          	sw	zero,0(a0)
}
    80006c00:	60a2                	ld	ra,8(sp)
    80006c02:	6402                	ld	s0,0(sp)
    80006c04:	0141                	addi	sp,sp,16
    80006c06:	8082                	ret

0000000080006c08 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006c08:	1141                	addi	sp,sp,-16
    80006c0a:	e406                	sd	ra,8(sp)
    80006c0c:	e022                	sd	s0,0(sp)
    80006c0e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006c10:	ffffb097          	auipc	ra,0xffffb
    80006c14:	0f6080e7          	jalr	246(ra) # 80001d06 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006c18:	00d5179b          	slliw	a5,a0,0xd
    80006c1c:	0c201537          	lui	a0,0xc201
    80006c20:	953e                	add	a0,a0,a5
  return irq;
}
    80006c22:	4148                	lw	a0,4(a0)
    80006c24:	60a2                	ld	ra,8(sp)
    80006c26:	6402                	ld	s0,0(sp)
    80006c28:	0141                	addi	sp,sp,16
    80006c2a:	8082                	ret

0000000080006c2c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006c2c:	1101                	addi	sp,sp,-32
    80006c2e:	ec06                	sd	ra,24(sp)
    80006c30:	e822                	sd	s0,16(sp)
    80006c32:	e426                	sd	s1,8(sp)
    80006c34:	1000                	addi	s0,sp,32
    80006c36:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006c38:	ffffb097          	auipc	ra,0xffffb
    80006c3c:	0ce080e7          	jalr	206(ra) # 80001d06 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006c40:	00d5151b          	slliw	a0,a0,0xd
    80006c44:	0c2017b7          	lui	a5,0xc201
    80006c48:	97aa                	add	a5,a5,a0
    80006c4a:	c3c4                	sw	s1,4(a5)
}
    80006c4c:	60e2                	ld	ra,24(sp)
    80006c4e:	6442                	ld	s0,16(sp)
    80006c50:	64a2                	ld	s1,8(sp)
    80006c52:	6105                	addi	sp,sp,32
    80006c54:	8082                	ret

0000000080006c56 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006c56:	1141                	addi	sp,sp,-16
    80006c58:	e406                	sd	ra,8(sp)
    80006c5a:	e022                	sd	s0,0(sp)
    80006c5c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006c5e:	479d                	li	a5,7
    80006c60:	06a7c963          	blt	a5,a0,80006cd2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006c64:	00029797          	auipc	a5,0x29
    80006c68:	39c78793          	addi	a5,a5,924 # 80030000 <disk>
    80006c6c:	00a78733          	add	a4,a5,a0
    80006c70:	6789                	lui	a5,0x2
    80006c72:	97ba                	add	a5,a5,a4
    80006c74:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006c78:	e7ad                	bnez	a5,80006ce2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006c7a:	00451793          	slli	a5,a0,0x4
    80006c7e:	0002b717          	auipc	a4,0x2b
    80006c82:	38270713          	addi	a4,a4,898 # 80032000 <disk+0x2000>
    80006c86:	6314                	ld	a3,0(a4)
    80006c88:	96be                	add	a3,a3,a5
    80006c8a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006c8e:	6314                	ld	a3,0(a4)
    80006c90:	96be                	add	a3,a3,a5
    80006c92:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006c96:	6314                	ld	a3,0(a4)
    80006c98:	96be                	add	a3,a3,a5
    80006c9a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006c9e:	6318                	ld	a4,0(a4)
    80006ca0:	97ba                	add	a5,a5,a4
    80006ca2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006ca6:	00029797          	auipc	a5,0x29
    80006caa:	35a78793          	addi	a5,a5,858 # 80030000 <disk>
    80006cae:	97aa                	add	a5,a5,a0
    80006cb0:	6509                	lui	a0,0x2
    80006cb2:	953e                	add	a0,a0,a5
    80006cb4:	4785                	li	a5,1
    80006cb6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006cba:	0002b517          	auipc	a0,0x2b
    80006cbe:	35e50513          	addi	a0,a0,862 # 80032018 <disk+0x2018>
    80006cc2:	ffffb097          	auipc	ra,0xffffb
    80006cc6:	6f4080e7          	jalr	1780(ra) # 800023b6 <wakeup>
}
    80006cca:	60a2                	ld	ra,8(sp)
    80006ccc:	6402                	ld	s0,0(sp)
    80006cce:	0141                	addi	sp,sp,16
    80006cd0:	8082                	ret
    panic("free_desc 1");
    80006cd2:	00003517          	auipc	a0,0x3
    80006cd6:	f6650513          	addi	a0,a0,-154 # 80009c38 <syscalls+0x358>
    80006cda:	ffffa097          	auipc	ra,0xffffa
    80006cde:	850080e7          	jalr	-1968(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006ce2:	00003517          	auipc	a0,0x3
    80006ce6:	f6650513          	addi	a0,a0,-154 # 80009c48 <syscalls+0x368>
    80006cea:	ffffa097          	auipc	ra,0xffffa
    80006cee:	840080e7          	jalr	-1984(ra) # 8000052a <panic>

0000000080006cf2 <virtio_disk_init>:
{
    80006cf2:	1101                	addi	sp,sp,-32
    80006cf4:	ec06                	sd	ra,24(sp)
    80006cf6:	e822                	sd	s0,16(sp)
    80006cf8:	e426                	sd	s1,8(sp)
    80006cfa:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006cfc:	00003597          	auipc	a1,0x3
    80006d00:	f5c58593          	addi	a1,a1,-164 # 80009c58 <syscalls+0x378>
    80006d04:	0002b517          	auipc	a0,0x2b
    80006d08:	42450513          	addi	a0,a0,1060 # 80032128 <disk+0x2128>
    80006d0c:	ffffa097          	auipc	ra,0xffffa
    80006d10:	e26080e7          	jalr	-474(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006d14:	100017b7          	lui	a5,0x10001
    80006d18:	4398                	lw	a4,0(a5)
    80006d1a:	2701                	sext.w	a4,a4
    80006d1c:	747277b7          	lui	a5,0x74727
    80006d20:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006d24:	0ef71163          	bne	a4,a5,80006e06 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006d28:	100017b7          	lui	a5,0x10001
    80006d2c:	43dc                	lw	a5,4(a5)
    80006d2e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006d30:	4705                	li	a4,1
    80006d32:	0ce79a63          	bne	a5,a4,80006e06 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006d36:	100017b7          	lui	a5,0x10001
    80006d3a:	479c                	lw	a5,8(a5)
    80006d3c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006d3e:	4709                	li	a4,2
    80006d40:	0ce79363          	bne	a5,a4,80006e06 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006d44:	100017b7          	lui	a5,0x10001
    80006d48:	47d8                	lw	a4,12(a5)
    80006d4a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006d4c:	554d47b7          	lui	a5,0x554d4
    80006d50:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006d54:	0af71963          	bne	a4,a5,80006e06 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006d58:	100017b7          	lui	a5,0x10001
    80006d5c:	4705                	li	a4,1
    80006d5e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006d60:	470d                	li	a4,3
    80006d62:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006d64:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006d66:	c7ffe737          	lui	a4,0xc7ffe
    80006d6a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fcb75f>
    80006d6e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006d70:	2701                	sext.w	a4,a4
    80006d72:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006d74:	472d                	li	a4,11
    80006d76:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006d78:	473d                	li	a4,15
    80006d7a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006d7c:	6705                	lui	a4,0x1
    80006d7e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006d80:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006d84:	5bdc                	lw	a5,52(a5)
    80006d86:	2781                	sext.w	a5,a5
  if(max == 0)
    80006d88:	c7d9                	beqz	a5,80006e16 <virtio_disk_init+0x124>
  if(max < NUM)
    80006d8a:	471d                	li	a4,7
    80006d8c:	08f77d63          	bgeu	a4,a5,80006e26 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006d90:	100014b7          	lui	s1,0x10001
    80006d94:	47a1                	li	a5,8
    80006d96:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006d98:	6609                	lui	a2,0x2
    80006d9a:	4581                	li	a1,0
    80006d9c:	00029517          	auipc	a0,0x29
    80006da0:	26450513          	addi	a0,a0,612 # 80030000 <disk>
    80006da4:	ffffa097          	auipc	ra,0xffffa
    80006da8:	f1a080e7          	jalr	-230(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006dac:	00029717          	auipc	a4,0x29
    80006db0:	25470713          	addi	a4,a4,596 # 80030000 <disk>
    80006db4:	00c75793          	srli	a5,a4,0xc
    80006db8:	2781                	sext.w	a5,a5
    80006dba:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006dbc:	0002b797          	auipc	a5,0x2b
    80006dc0:	24478793          	addi	a5,a5,580 # 80032000 <disk+0x2000>
    80006dc4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006dc6:	00029717          	auipc	a4,0x29
    80006dca:	2ba70713          	addi	a4,a4,698 # 80030080 <disk+0x80>
    80006dce:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006dd0:	0002a717          	auipc	a4,0x2a
    80006dd4:	23070713          	addi	a4,a4,560 # 80031000 <disk+0x1000>
    80006dd8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006dda:	4705                	li	a4,1
    80006ddc:	00e78c23          	sb	a4,24(a5)
    80006de0:	00e78ca3          	sb	a4,25(a5)
    80006de4:	00e78d23          	sb	a4,26(a5)
    80006de8:	00e78da3          	sb	a4,27(a5)
    80006dec:	00e78e23          	sb	a4,28(a5)
    80006df0:	00e78ea3          	sb	a4,29(a5)
    80006df4:	00e78f23          	sb	a4,30(a5)
    80006df8:	00e78fa3          	sb	a4,31(a5)
}
    80006dfc:	60e2                	ld	ra,24(sp)
    80006dfe:	6442                	ld	s0,16(sp)
    80006e00:	64a2                	ld	s1,8(sp)
    80006e02:	6105                	addi	sp,sp,32
    80006e04:	8082                	ret
    panic("could not find virtio disk");
    80006e06:	00003517          	auipc	a0,0x3
    80006e0a:	e6250513          	addi	a0,a0,-414 # 80009c68 <syscalls+0x388>
    80006e0e:	ffff9097          	auipc	ra,0xffff9
    80006e12:	71c080e7          	jalr	1820(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006e16:	00003517          	auipc	a0,0x3
    80006e1a:	e7250513          	addi	a0,a0,-398 # 80009c88 <syscalls+0x3a8>
    80006e1e:	ffff9097          	auipc	ra,0xffff9
    80006e22:	70c080e7          	jalr	1804(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006e26:	00003517          	auipc	a0,0x3
    80006e2a:	e8250513          	addi	a0,a0,-382 # 80009ca8 <syscalls+0x3c8>
    80006e2e:	ffff9097          	auipc	ra,0xffff9
    80006e32:	6fc080e7          	jalr	1788(ra) # 8000052a <panic>

0000000080006e36 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006e36:	7119                	addi	sp,sp,-128
    80006e38:	fc86                	sd	ra,120(sp)
    80006e3a:	f8a2                	sd	s0,112(sp)
    80006e3c:	f4a6                	sd	s1,104(sp)
    80006e3e:	f0ca                	sd	s2,96(sp)
    80006e40:	ecce                	sd	s3,88(sp)
    80006e42:	e8d2                	sd	s4,80(sp)
    80006e44:	e4d6                	sd	s5,72(sp)
    80006e46:	e0da                	sd	s6,64(sp)
    80006e48:	fc5e                	sd	s7,56(sp)
    80006e4a:	f862                	sd	s8,48(sp)
    80006e4c:	f466                	sd	s9,40(sp)
    80006e4e:	f06a                	sd	s10,32(sp)
    80006e50:	ec6e                	sd	s11,24(sp)
    80006e52:	0100                	addi	s0,sp,128
    80006e54:	8aaa                	mv	s5,a0
    80006e56:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006e58:	00c52c83          	lw	s9,12(a0)
    80006e5c:	001c9c9b          	slliw	s9,s9,0x1
    80006e60:	1c82                	slli	s9,s9,0x20
    80006e62:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006e66:	0002b517          	auipc	a0,0x2b
    80006e6a:	2c250513          	addi	a0,a0,706 # 80032128 <disk+0x2128>
    80006e6e:	ffffa097          	auipc	ra,0xffffa
    80006e72:	d54080e7          	jalr	-684(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006e76:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006e78:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006e7a:	00029c17          	auipc	s8,0x29
    80006e7e:	186c0c13          	addi	s8,s8,390 # 80030000 <disk>
    80006e82:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006e84:	4b0d                	li	s6,3
    80006e86:	a0ad                	j	80006ef0 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006e88:	00fc0733          	add	a4,s8,a5
    80006e8c:	975e                	add	a4,a4,s7
    80006e8e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006e92:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006e94:	0207c563          	bltz	a5,80006ebe <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006e98:	2905                	addiw	s2,s2,1
    80006e9a:	0611                	addi	a2,a2,4
    80006e9c:	19690d63          	beq	s2,s6,80007036 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006ea0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006ea2:	0002b717          	auipc	a4,0x2b
    80006ea6:	17670713          	addi	a4,a4,374 # 80032018 <disk+0x2018>
    80006eaa:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006eac:	00074683          	lbu	a3,0(a4)
    80006eb0:	fee1                	bnez	a3,80006e88 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006eb2:	2785                	addiw	a5,a5,1
    80006eb4:	0705                	addi	a4,a4,1
    80006eb6:	fe979be3          	bne	a5,s1,80006eac <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006eba:	57fd                	li	a5,-1
    80006ebc:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006ebe:	01205d63          	blez	s2,80006ed8 <virtio_disk_rw+0xa2>
    80006ec2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006ec4:	000a2503          	lw	a0,0(s4)
    80006ec8:	00000097          	auipc	ra,0x0
    80006ecc:	d8e080e7          	jalr	-626(ra) # 80006c56 <free_desc>
      for(int j = 0; j < i; j++)
    80006ed0:	2d85                	addiw	s11,s11,1
    80006ed2:	0a11                	addi	s4,s4,4
    80006ed4:	ffb918e3          	bne	s2,s11,80006ec4 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006ed8:	0002b597          	auipc	a1,0x2b
    80006edc:	25058593          	addi	a1,a1,592 # 80032128 <disk+0x2128>
    80006ee0:	0002b517          	auipc	a0,0x2b
    80006ee4:	13850513          	addi	a0,a0,312 # 80032018 <disk+0x2018>
    80006ee8:	ffffb097          	auipc	ra,0xffffb
    80006eec:	342080e7          	jalr	834(ra) # 8000222a <sleep>
  for(int i = 0; i < 3; i++){
    80006ef0:	f8040a13          	addi	s4,s0,-128
{
    80006ef4:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006ef6:	894e                	mv	s2,s3
    80006ef8:	b765                	j	80006ea0 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006efa:	0002b697          	auipc	a3,0x2b
    80006efe:	1066b683          	ld	a3,262(a3) # 80032000 <disk+0x2000>
    80006f02:	96ba                	add	a3,a3,a4
    80006f04:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006f08:	00029817          	auipc	a6,0x29
    80006f0c:	0f880813          	addi	a6,a6,248 # 80030000 <disk>
    80006f10:	0002b697          	auipc	a3,0x2b
    80006f14:	0f068693          	addi	a3,a3,240 # 80032000 <disk+0x2000>
    80006f18:	6290                	ld	a2,0(a3)
    80006f1a:	963a                	add	a2,a2,a4
    80006f1c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006f20:	0015e593          	ori	a1,a1,1
    80006f24:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006f28:	f8842603          	lw	a2,-120(s0)
    80006f2c:	628c                	ld	a1,0(a3)
    80006f2e:	972e                	add	a4,a4,a1
    80006f30:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006f34:	20050593          	addi	a1,a0,512
    80006f38:	0592                	slli	a1,a1,0x4
    80006f3a:	95c2                	add	a1,a1,a6
    80006f3c:	577d                	li	a4,-1
    80006f3e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006f42:	00461713          	slli	a4,a2,0x4
    80006f46:	6290                	ld	a2,0(a3)
    80006f48:	963a                	add	a2,a2,a4
    80006f4a:	03078793          	addi	a5,a5,48
    80006f4e:	97c2                	add	a5,a5,a6
    80006f50:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006f52:	629c                	ld	a5,0(a3)
    80006f54:	97ba                	add	a5,a5,a4
    80006f56:	4605                	li	a2,1
    80006f58:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006f5a:	629c                	ld	a5,0(a3)
    80006f5c:	97ba                	add	a5,a5,a4
    80006f5e:	4809                	li	a6,2
    80006f60:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006f64:	629c                	ld	a5,0(a3)
    80006f66:	973e                	add	a4,a4,a5
    80006f68:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006f6c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006f70:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006f74:	6698                	ld	a4,8(a3)
    80006f76:	00275783          	lhu	a5,2(a4)
    80006f7a:	8b9d                	andi	a5,a5,7
    80006f7c:	0786                	slli	a5,a5,0x1
    80006f7e:	97ba                	add	a5,a5,a4
    80006f80:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006f84:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006f88:	6698                	ld	a4,8(a3)
    80006f8a:	00275783          	lhu	a5,2(a4)
    80006f8e:	2785                	addiw	a5,a5,1
    80006f90:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006f94:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006f98:	100017b7          	lui	a5,0x10001
    80006f9c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006fa0:	004aa783          	lw	a5,4(s5)
    80006fa4:	02c79163          	bne	a5,a2,80006fc6 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006fa8:	0002b917          	auipc	s2,0x2b
    80006fac:	18090913          	addi	s2,s2,384 # 80032128 <disk+0x2128>
  while(b->disk == 1) {
    80006fb0:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006fb2:	85ca                	mv	a1,s2
    80006fb4:	8556                	mv	a0,s5
    80006fb6:	ffffb097          	auipc	ra,0xffffb
    80006fba:	274080e7          	jalr	628(ra) # 8000222a <sleep>
  while(b->disk == 1) {
    80006fbe:	004aa783          	lw	a5,4(s5)
    80006fc2:	fe9788e3          	beq	a5,s1,80006fb2 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006fc6:	f8042903          	lw	s2,-128(s0)
    80006fca:	20090793          	addi	a5,s2,512
    80006fce:	00479713          	slli	a4,a5,0x4
    80006fd2:	00029797          	auipc	a5,0x29
    80006fd6:	02e78793          	addi	a5,a5,46 # 80030000 <disk>
    80006fda:	97ba                	add	a5,a5,a4
    80006fdc:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006fe0:	0002b997          	auipc	s3,0x2b
    80006fe4:	02098993          	addi	s3,s3,32 # 80032000 <disk+0x2000>
    80006fe8:	00491713          	slli	a4,s2,0x4
    80006fec:	0009b783          	ld	a5,0(s3)
    80006ff0:	97ba                	add	a5,a5,a4
    80006ff2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006ff6:	854a                	mv	a0,s2
    80006ff8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006ffc:	00000097          	auipc	ra,0x0
    80007000:	c5a080e7          	jalr	-934(ra) # 80006c56 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80007004:	8885                	andi	s1,s1,1
    80007006:	f0ed                	bnez	s1,80006fe8 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80007008:	0002b517          	auipc	a0,0x2b
    8000700c:	12050513          	addi	a0,a0,288 # 80032128 <disk+0x2128>
    80007010:	ffffa097          	auipc	ra,0xffffa
    80007014:	c66080e7          	jalr	-922(ra) # 80000c76 <release>
}
    80007018:	70e6                	ld	ra,120(sp)
    8000701a:	7446                	ld	s0,112(sp)
    8000701c:	74a6                	ld	s1,104(sp)
    8000701e:	7906                	ld	s2,96(sp)
    80007020:	69e6                	ld	s3,88(sp)
    80007022:	6a46                	ld	s4,80(sp)
    80007024:	6aa6                	ld	s5,72(sp)
    80007026:	6b06                	ld	s6,64(sp)
    80007028:	7be2                	ld	s7,56(sp)
    8000702a:	7c42                	ld	s8,48(sp)
    8000702c:	7ca2                	ld	s9,40(sp)
    8000702e:	7d02                	ld	s10,32(sp)
    80007030:	6de2                	ld	s11,24(sp)
    80007032:	6109                	addi	sp,sp,128
    80007034:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007036:	f8042503          	lw	a0,-128(s0)
    8000703a:	20050793          	addi	a5,a0,512
    8000703e:	0792                	slli	a5,a5,0x4
  if(write)
    80007040:	00029817          	auipc	a6,0x29
    80007044:	fc080813          	addi	a6,a6,-64 # 80030000 <disk>
    80007048:	00f80733          	add	a4,a6,a5
    8000704c:	01a036b3          	snez	a3,s10
    80007050:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80007054:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80007058:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000705c:	7679                	lui	a2,0xffffe
    8000705e:	963e                	add	a2,a2,a5
    80007060:	0002b697          	auipc	a3,0x2b
    80007064:	fa068693          	addi	a3,a3,-96 # 80032000 <disk+0x2000>
    80007068:	6298                	ld	a4,0(a3)
    8000706a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000706c:	0a878593          	addi	a1,a5,168
    80007070:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007072:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80007074:	6298                	ld	a4,0(a3)
    80007076:	9732                	add	a4,a4,a2
    80007078:	45c1                	li	a1,16
    8000707a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000707c:	6298                	ld	a4,0(a3)
    8000707e:	9732                	add	a4,a4,a2
    80007080:	4585                	li	a1,1
    80007082:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007086:	f8442703          	lw	a4,-124(s0)
    8000708a:	628c                	ld	a1,0(a3)
    8000708c:	962e                	add	a2,a2,a1
    8000708e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffcb00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80007092:	0712                	slli	a4,a4,0x4
    80007094:	6290                	ld	a2,0(a3)
    80007096:	963a                	add	a2,a2,a4
    80007098:	058a8593          	addi	a1,s5,88
    8000709c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000709e:	6294                	ld	a3,0(a3)
    800070a0:	96ba                	add	a3,a3,a4
    800070a2:	40000613          	li	a2,1024
    800070a6:	c690                	sw	a2,8(a3)
  if(write)
    800070a8:	e40d19e3          	bnez	s10,80006efa <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800070ac:	0002b697          	auipc	a3,0x2b
    800070b0:	f546b683          	ld	a3,-172(a3) # 80032000 <disk+0x2000>
    800070b4:	96ba                	add	a3,a3,a4
    800070b6:	4609                	li	a2,2
    800070b8:	00c69623          	sh	a2,12(a3)
    800070bc:	b5b1                	j	80006f08 <virtio_disk_rw+0xd2>

00000000800070be <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800070be:	1101                	addi	sp,sp,-32
    800070c0:	ec06                	sd	ra,24(sp)
    800070c2:	e822                	sd	s0,16(sp)
    800070c4:	e426                	sd	s1,8(sp)
    800070c6:	e04a                	sd	s2,0(sp)
    800070c8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800070ca:	0002b517          	auipc	a0,0x2b
    800070ce:	05e50513          	addi	a0,a0,94 # 80032128 <disk+0x2128>
    800070d2:	ffffa097          	auipc	ra,0xffffa
    800070d6:	af0080e7          	jalr	-1296(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800070da:	10001737          	lui	a4,0x10001
    800070de:	533c                	lw	a5,96(a4)
    800070e0:	8b8d                	andi	a5,a5,3
    800070e2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800070e4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800070e8:	0002b797          	auipc	a5,0x2b
    800070ec:	f1878793          	addi	a5,a5,-232 # 80032000 <disk+0x2000>
    800070f0:	6b94                	ld	a3,16(a5)
    800070f2:	0207d703          	lhu	a4,32(a5)
    800070f6:	0026d783          	lhu	a5,2(a3)
    800070fa:	06f70163          	beq	a4,a5,8000715c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800070fe:	00029917          	auipc	s2,0x29
    80007102:	f0290913          	addi	s2,s2,-254 # 80030000 <disk>
    80007106:	0002b497          	auipc	s1,0x2b
    8000710a:	efa48493          	addi	s1,s1,-262 # 80032000 <disk+0x2000>
    __sync_synchronize();
    8000710e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007112:	6898                	ld	a4,16(s1)
    80007114:	0204d783          	lhu	a5,32(s1)
    80007118:	8b9d                	andi	a5,a5,7
    8000711a:	078e                	slli	a5,a5,0x3
    8000711c:	97ba                	add	a5,a5,a4
    8000711e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80007120:	20078713          	addi	a4,a5,512
    80007124:	0712                	slli	a4,a4,0x4
    80007126:	974a                	add	a4,a4,s2
    80007128:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000712c:	e731                	bnez	a4,80007178 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000712e:	20078793          	addi	a5,a5,512
    80007132:	0792                	slli	a5,a5,0x4
    80007134:	97ca                	add	a5,a5,s2
    80007136:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007138:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000713c:	ffffb097          	auipc	ra,0xffffb
    80007140:	27a080e7          	jalr	634(ra) # 800023b6 <wakeup>

    disk.used_idx += 1;
    80007144:	0204d783          	lhu	a5,32(s1)
    80007148:	2785                	addiw	a5,a5,1
    8000714a:	17c2                	slli	a5,a5,0x30
    8000714c:	93c1                	srli	a5,a5,0x30
    8000714e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007152:	6898                	ld	a4,16(s1)
    80007154:	00275703          	lhu	a4,2(a4)
    80007158:	faf71be3          	bne	a4,a5,8000710e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000715c:	0002b517          	auipc	a0,0x2b
    80007160:	fcc50513          	addi	a0,a0,-52 # 80032128 <disk+0x2128>
    80007164:	ffffa097          	auipc	ra,0xffffa
    80007168:	b12080e7          	jalr	-1262(ra) # 80000c76 <release>
}
    8000716c:	60e2                	ld	ra,24(sp)
    8000716e:	6442                	ld	s0,16(sp)
    80007170:	64a2                	ld	s1,8(sp)
    80007172:	6902                	ld	s2,0(sp)
    80007174:	6105                	addi	sp,sp,32
    80007176:	8082                	ret
      panic("virtio_disk_intr status");
    80007178:	00003517          	auipc	a0,0x3
    8000717c:	b5050513          	addi	a0,a0,-1200 # 80009cc8 <syscalls+0x3e8>
    80007180:	ffff9097          	auipc	ra,0xffff9
    80007184:	3aa080e7          	jalr	938(ra) # 8000052a <panic>
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
