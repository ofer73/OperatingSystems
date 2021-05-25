
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
    80000068:	9dc78793          	addi	a5,a5,-1572 # 80006a40 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffcf7ff>
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
    80000122:	3ea080e7          	jalr	1002(ra) # 80002508 <either_copyin>
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
    800001b6:	9c4080e7          	jalr	-1596(ra) # 80001b76 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	f4c080e7          	jalr	-180(ra) # 8000210e <sleep>
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
    80000202:	2b4080e7          	jalr	692(ra) # 800024b2 <either_copyout>
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
    800002e2:	280080e7          	jalr	640(ra) # 8000255e <procdump>
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
    80000436:	e68080e7          	jalr	-408(ra) # 8000229a <wakeup>
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
    80000464:	0002a797          	auipc	a5,0x2a
    80000468:	6b478793          	addi	a5,a5,1716 # 8002ab18 <devsw>
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
    8000055c:	b7050513          	addi	a0,a0,-1168 # 800090c8 <digits+0x88>
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
    80000882:	a1c080e7          	jalr	-1508(ra) # 8000229a <wakeup>
    
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
    8000090e:	804080e7          	jalr	-2044(ra) # 8000210e <sleep>
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
    800009ea:	0002e797          	auipc	a5,0x2e
    800009ee:	61678793          	addi	a5,a5,1558 # 8002f000 <end>
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
    80000aba:	0002e517          	auipc	a0,0x2e
    80000abe:	54650513          	addi	a0,a0,1350 # 8002f000 <end>
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
    80000b60:	ffe080e7          	jalr	-2(ra) # 80001b5a <mycpu>
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
    80000b92:	fcc080e7          	jalr	-52(ra) # 80001b5a <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	fc0080e7          	jalr	-64(ra) # 80001b5a <mycpu>
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
    80000bb6:	fa8080e7          	jalr	-88(ra) # 80001b5a <mycpu>
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
    80000bf6:	f68080e7          	jalr	-152(ra) # 80001b5a <mycpu>
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
    80000c22:	f3c080e7          	jalr	-196(ra) # 80001b5a <mycpu>
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
    80000e78:	cd6080e7          	jalr	-810(ra) # 80001b4a <cpuid>
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
    80000e94:	cba080e7          	jalr	-838(ra) # 80001b4a <cpuid>
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
    80000eb6:	034080e7          	jalr	52(ra) # 80002ee6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00006097          	auipc	ra,0x6
    80000ebe:	bc6080e7          	jalr	-1082(ra) # 80006a80 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	09a080e7          	jalr	154(ra) # 80001f5c <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00008517          	auipc	a0,0x8
    80000ede:	1ee50513          	addi	a0,a0,494 # 800090c8 <digits+0x88>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00008517          	auipc	a0,0x8
    80000eee:	1b650513          	addi	a0,a0,438 # 800090a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00008517          	auipc	a0,0x8
    80000efe:	1ce50513          	addi	a0,a0,462 # 800090c8 <digits+0x88>
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
    80000f26:	b78080e7          	jalr	-1160(ra) # 80001a9a <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	f94080e7          	jalr	-108(ra) # 80002ebe <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	fb4080e7          	jalr	-76(ra) # 80002ee6 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00006097          	auipc	ra,0x6
    80000f3e:	b30080e7          	jalr	-1232(ra) # 80006a6a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00006097          	auipc	ra,0x6
    80000f46:	b3e080e7          	jalr	-1218(ra) # 80006a80 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	7d8080e7          	jalr	2008(ra) # 80003722 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	e6a080e7          	jalr	-406(ra) # 80003dbc <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	12a080e7          	jalr	298(ra) # 80005084 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00006097          	auipc	ra,0x6
    80000f66:	c40080e7          	jalr	-960(ra) # 80006ba2 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	efc080e7          	jalr	-260(ra) # 80001e66 <userinit>
    __sync_synchronize();
    80000f72:	0ff0000f          	fence
    started = 1;
    80000f76:	4785                	li	a5,1
    80000f78:	00009717          	auipc	a4,0x9
    80000f7c:	0af72023          	sw	a5,160(a4) # 8000a018 <started>
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
    80000fcc:	00008517          	auipc	a0,0x8
    80000fd0:	10450513          	addi	a0,a0,260 # 800090d0 <digits+0x90>
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
  // check if we have space in phsical addres or in case the 

  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000104c:	57fd                	li	a5,-1
    8000104e:	83e9                	srli	a5,a5,0x1a
    80001050:	00b7f463          	bgeu	a5,a1,80001058 <walkaddr+0xc>
    return 0;
    80001054:	4501                	li	a0,0
    *pte ^= PTE_V;     // page table entry now invalid
    *pte |= PTE_PG;    // paged out to secondary storage

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
  if(pte == 0)
    80001070:	c905                	beqz	a0,800010a0 <walkaddr+0x54>
  if((*pte & PTE_V) == 0)
    80001072:	6114                	ld	a3,0(a0)
  if((*pte & PTE_U) == 0)
    80001074:	0116f613          	andi	a2,a3,17
    80001078:	47c5                	li	a5,17
    return 0;
    8000107a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
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
  if(to_page_out){  // case we are paging out need to update flags in pte
    80001092:	d4fd                	beqz	s1,80001080 <walkaddr+0x34>
    *pte ^= PTE_V;     // page table entry now invalid
    80001094:	0016c693          	xori	a3,a3,1
    *pte |= PTE_PG;    // paged out to secondary storage
    80001098:	2006e693          	ori	a3,a3,512
    8000109c:	e314                	sd	a3,0(a4)
    8000109e:	b7cd                	j	80001080 <walkaddr+0x34>
    return 0;
    800010a0:	4501                	li	a0,0
    800010a2:	bff9                	j	80001080 <walkaddr+0x34>

00000000800010a4 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
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
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d4:	6b85                	lui	s7,0x1
    800010d6:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010da:	4605                	li	a2,1
    800010dc:	85ca                	mv	a1,s2
    800010de:	8556                	mv	a0,s5
    800010e0:	00000097          	auipc	ra,0x0
    800010e4:	ec6080e7          	jalr	-314(ra) # 80000fa6 <walk>
    800010e8:	c51d                	beqz	a0,80001116 <mappages+0x72>
    if(*pte & PTE_V)
    800010ea:	611c                	ld	a5,0(a0)
    800010ec:	8b85                	andi	a5,a5,1
    800010ee:	ef81                	bnez	a5,80001106 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010f0:	80b1                	srli	s1,s1,0xc
    800010f2:	04aa                	slli	s1,s1,0xa
    800010f4:	0164e4b3          	or	s1,s1,s6
    800010f8:	0014e493          	ori	s1,s1,1
    800010fc:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fe:	03390863          	beq	s2,s3,8000112e <mappages+0x8a>
    a += PGSIZE;
    80001102:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
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
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
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
  kpgtbl = (pagetable_t) kalloc();
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
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
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
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
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
    80001222:	00000097          	auipc	ra,0x0
    80001226:	7e2080e7          	jalr	2018(ra) # 80001a04 <proc_mapstacks>
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
    80001248:	00009797          	auipc	a5,0x9
    8000124c:	dca7bc23          	sd	a0,-552(a5) # 8000a020 <kernel_pagetable>
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
  pagetable = (pagetable_t) kalloc();
    80001262:	00000097          	auipc	ra,0x0
    80001266:	870080e7          	jalr	-1936(ra) # 80000ad2 <kalloc>
    8000126a:	84aa                	mv	s1,a0
  if(pagetable == 0)
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
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
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

  if(sz >= PGSIZE)
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
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
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

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
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
  for(int i = 0; i < 512; i++){
    8000130a:	84aa                	mv	s1,a0
    8000130c:	6905                	lui	s2,0x1
    8000130e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001310:	4985                	li	s3,1
    80001312:	a821                	j	8000132a <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001314:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001316:	0532                	slli	a0,a0,0xc
    80001318:	00000097          	auipc	ra,0x0
    8000131c:	fe0080e7          	jalr	-32(ra) # 800012f8 <freewalk>
      pagetable[i] = 0;
    80001320:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001324:	04a1                	addi	s1,s1,8
    80001326:	03248163          	beq	s1,s2,80001348 <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000132a:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000132c:	00f57793          	andi	a5,a0,15
    80001330:	ff3782e3          	beq	a5,s3,80001314 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001334:	8905                	andi	a0,a0,1
    80001336:	d57d                	beqz	a0,80001324 <freewalk+0x2c>
      panic("freewalk: leaf");
    80001338:	00008517          	auipc	a0,0x8
    8000133c:	dd050513          	addi	a0,a0,-560 # 80009108 <digits+0xc8>
    80001340:	fffff097          	auipc	ra,0xfffff
    80001344:	1ea080e7          	jalr	490(ra) # 8000052a <panic>
    }
  }
  kfree((void*)pagetable);
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

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001362:	1141                	addi	sp,sp,-16
    80001364:	e406                	sd	ra,8(sp)
    80001366:	e022                	sd	s0,0(sp)
    80001368:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000136a:	4601                	li	a2,0
    8000136c:	00000097          	auipc	ra,0x0
    80001370:	c3a080e7          	jalr	-966(ra) # 80000fa6 <walk>
  if(pte == 0)
    80001374:	c901                	beqz	a0,80001384 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001376:	611c                	ld	a5,0(a0)
    80001378:	9bbd                	andi	a5,a5,-17
    8000137a:	e11c                	sd	a5,0(a0)
}
    8000137c:	60a2                	ld	ra,8(sp)
    8000137e:	6402                	ld	s0,0(sp)
    80001380:	0141                	addi	sp,sp,16
    80001382:	8082                	ret
    panic("uvmclear");
    80001384:	00008517          	auipc	a0,0x8
    80001388:	d9450513          	addi	a0,a0,-620 # 80009118 <digits+0xd8>
    8000138c:	fffff097          	auipc	ra,0xfffff
    80001390:	19e080e7          	jalr	414(ra) # 8000052a <panic>

0000000080001394 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001394:	caa5                	beqz	a3,80001404 <copyout+0x70>
{
    80001396:	715d                	addi	sp,sp,-80
    80001398:	e486                	sd	ra,72(sp)
    8000139a:	e0a2                	sd	s0,64(sp)
    8000139c:	fc26                	sd	s1,56(sp)
    8000139e:	f84a                	sd	s2,48(sp)
    800013a0:	f44e                	sd	s3,40(sp)
    800013a2:	f052                	sd	s4,32(sp)
    800013a4:	ec56                	sd	s5,24(sp)
    800013a6:	e85a                	sd	s6,16(sp)
    800013a8:	e45e                	sd	s7,8(sp)
    800013aa:	e062                	sd	s8,0(sp)
    800013ac:	0880                	addi	s0,sp,80
    800013ae:	8b2a                	mv	s6,a0
    800013b0:	8c2e                	mv	s8,a1
    800013b2:	8a32                	mv	s4,a2
    800013b4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800013b6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0, 0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800013b8:	6a85                	lui	s5,0x1
    800013ba:	a015                	j	800013de <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800013bc:	9562                	add	a0,a0,s8
    800013be:	0004861b          	sext.w	a2,s1
    800013c2:	85d2                	mv	a1,s4
    800013c4:	41250533          	sub	a0,a0,s2
    800013c8:	00000097          	auipc	ra,0x0
    800013cc:	952080e7          	jalr	-1710(ra) # 80000d1a <memmove>

    len -= n;
    800013d0:	409989b3          	sub	s3,s3,s1
    src += n;
    800013d4:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800013d6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800013da:	02098363          	beqz	s3,80001400 <copyout+0x6c>
    va0 = PGROUNDDOWN(dstva);
    800013de:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0, 0);
    800013e2:	4601                	li	a2,0
    800013e4:	85ca                	mv	a1,s2
    800013e6:	855a                	mv	a0,s6
    800013e8:	00000097          	auipc	ra,0x0
    800013ec:	c64080e7          	jalr	-924(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    800013f0:	cd01                	beqz	a0,80001408 <copyout+0x74>
    n = PGSIZE - (dstva - va0);
    800013f2:	418904b3          	sub	s1,s2,s8
    800013f6:	94d6                	add	s1,s1,s5
    if(n > len)
    800013f8:	fc99f2e3          	bgeu	s3,s1,800013bc <copyout+0x28>
    800013fc:	84ce                	mv	s1,s3
    800013fe:	bf7d                	j	800013bc <copyout+0x28>
  }
  return 0;
    80001400:	4501                	li	a0,0
    80001402:	a021                	j	8000140a <copyout+0x76>
    80001404:	4501                	li	a0,0
}
    80001406:	8082                	ret
      return -1;
    80001408:	557d                	li	a0,-1
}
    8000140a:	60a6                	ld	ra,72(sp)
    8000140c:	6406                	ld	s0,64(sp)
    8000140e:	74e2                	ld	s1,56(sp)
    80001410:	7942                	ld	s2,48(sp)
    80001412:	79a2                	ld	s3,40(sp)
    80001414:	7a02                	ld	s4,32(sp)
    80001416:	6ae2                	ld	s5,24(sp)
    80001418:	6b42                	ld	s6,16(sp)
    8000141a:	6ba2                	ld	s7,8(sp)
    8000141c:	6c02                	ld	s8,0(sp)
    8000141e:	6161                	addi	sp,sp,80
    80001420:	8082                	ret

0000000080001422 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001422:	caad                	beqz	a3,80001494 <copyin+0x72>
{
    80001424:	715d                	addi	sp,sp,-80
    80001426:	e486                	sd	ra,72(sp)
    80001428:	e0a2                	sd	s0,64(sp)
    8000142a:	fc26                	sd	s1,56(sp)
    8000142c:	f84a                	sd	s2,48(sp)
    8000142e:	f44e                	sd	s3,40(sp)
    80001430:	f052                	sd	s4,32(sp)
    80001432:	ec56                	sd	s5,24(sp)
    80001434:	e85a                	sd	s6,16(sp)
    80001436:	e45e                	sd	s7,8(sp)
    80001438:	e062                	sd	s8,0(sp)
    8000143a:	0880                	addi	s0,sp,80
    8000143c:	8b2a                	mv	s6,a0
    8000143e:	8a2e                	mv	s4,a1
    80001440:	8c32                	mv	s8,a2
    80001442:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001444:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0, 0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001446:	6a85                	lui	s5,0x1
    80001448:	a01d                	j	8000146e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000144a:	018505b3          	add	a1,a0,s8
    8000144e:	0004861b          	sext.w	a2,s1
    80001452:	412585b3          	sub	a1,a1,s2
    80001456:	8552                	mv	a0,s4
    80001458:	00000097          	auipc	ra,0x0
    8000145c:	8c2080e7          	jalr	-1854(ra) # 80000d1a <memmove>

    len -= n;
    80001460:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001464:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001466:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000146a:	02098363          	beqz	s3,80001490 <copyin+0x6e>
    va0 = PGROUNDDOWN(srcva);
    8000146e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0, 0);
    80001472:	4601                	li	a2,0
    80001474:	85ca                	mv	a1,s2
    80001476:	855a                	mv	a0,s6
    80001478:	00000097          	auipc	ra,0x0
    8000147c:	bd4080e7          	jalr	-1068(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001480:	cd01                	beqz	a0,80001498 <copyin+0x76>
    n = PGSIZE - (srcva - va0);
    80001482:	418904b3          	sub	s1,s2,s8
    80001486:	94d6                	add	s1,s1,s5
    if(n > len)
    80001488:	fc99f1e3          	bgeu	s3,s1,8000144a <copyin+0x28>
    8000148c:	84ce                	mv	s1,s3
    8000148e:	bf75                	j	8000144a <copyin+0x28>
  }
  return 0;
    80001490:	4501                	li	a0,0
    80001492:	a021                	j	8000149a <copyin+0x78>
    80001494:	4501                	li	a0,0
}
    80001496:	8082                	ret
      return -1;
    80001498:	557d                	li	a0,-1
}
    8000149a:	60a6                	ld	ra,72(sp)
    8000149c:	6406                	ld	s0,64(sp)
    8000149e:	74e2                	ld	s1,56(sp)
    800014a0:	7942                	ld	s2,48(sp)
    800014a2:	79a2                	ld	s3,40(sp)
    800014a4:	7a02                	ld	s4,32(sp)
    800014a6:	6ae2                	ld	s5,24(sp)
    800014a8:	6b42                	ld	s6,16(sp)
    800014aa:	6ba2                	ld	s7,8(sp)
    800014ac:	6c02                	ld	s8,0(sp)
    800014ae:	6161                	addi	sp,sp,80
    800014b0:	8082                	ret

00000000800014b2 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800014b2:	c6cd                	beqz	a3,8000155c <copyinstr+0xaa>
{
    800014b4:	715d                	addi	sp,sp,-80
    800014b6:	e486                	sd	ra,72(sp)
    800014b8:	e0a2                	sd	s0,64(sp)
    800014ba:	fc26                	sd	s1,56(sp)
    800014bc:	f84a                	sd	s2,48(sp)
    800014be:	f44e                	sd	s3,40(sp)
    800014c0:	f052                	sd	s4,32(sp)
    800014c2:	ec56                	sd	s5,24(sp)
    800014c4:	e85a                	sd	s6,16(sp)
    800014c6:	e45e                	sd	s7,8(sp)
    800014c8:	0880                	addi	s0,sp,80
    800014ca:	8a2a                	mv	s4,a0
    800014cc:	8b2e                	mv	s6,a1
    800014ce:	8bb2                	mv	s7,a2
    800014d0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800014d2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0, 0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014d4:	6985                	lui	s3,0x1
    800014d6:	a035                	j	80001502 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800014d8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800014dc:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800014de:	0017b793          	seqz	a5,a5
    800014e2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800014e6:	60a6                	ld	ra,72(sp)
    800014e8:	6406                	ld	s0,64(sp)
    800014ea:	74e2                	ld	s1,56(sp)
    800014ec:	7942                	ld	s2,48(sp)
    800014ee:	79a2                	ld	s3,40(sp)
    800014f0:	7a02                	ld	s4,32(sp)
    800014f2:	6ae2                	ld	s5,24(sp)
    800014f4:	6b42                	ld	s6,16(sp)
    800014f6:	6ba2                	ld	s7,8(sp)
    800014f8:	6161                	addi	sp,sp,80
    800014fa:	8082                	ret
    srcva = va0 + PGSIZE;
    800014fc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001500:	c8b1                	beqz	s1,80001554 <copyinstr+0xa2>
    va0 = PGROUNDDOWN(srcva);
    80001502:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0, 0);
    80001506:	4601                	li	a2,0
    80001508:	85ca                	mv	a1,s2
    8000150a:	8552                	mv	a0,s4
    8000150c:	00000097          	auipc	ra,0x0
    80001510:	b40080e7          	jalr	-1216(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001514:	c131                	beqz	a0,80001558 <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    80001516:	41790833          	sub	a6,s2,s7
    8000151a:	984e                	add	a6,a6,s3
    if(n > max)
    8000151c:	0104f363          	bgeu	s1,a6,80001522 <copyinstr+0x70>
    80001520:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001522:	955e                	add	a0,a0,s7
    80001524:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001528:	fc080ae3          	beqz	a6,800014fc <copyinstr+0x4a>
    8000152c:	985a                	add	a6,a6,s6
    8000152e:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001530:	41650633          	sub	a2,a0,s6
    80001534:	14fd                	addi	s1,s1,-1
    80001536:	9b26                	add	s6,s6,s1
    80001538:	00f60733          	add	a4,a2,a5
    8000153c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd0000>
    80001540:	df41                	beqz	a4,800014d8 <copyinstr+0x26>
        *dst = *p;
    80001542:	00e78023          	sb	a4,0(a5)
      --max;
    80001546:	40fb04b3          	sub	s1,s6,a5
      dst++;
    8000154a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000154c:	ff0796e3          	bne	a5,a6,80001538 <copyinstr+0x86>
      dst++;
    80001550:	8b42                	mv	s6,a6
    80001552:	b76d                	j	800014fc <copyinstr+0x4a>
    80001554:	4781                	li	a5,0
    80001556:	b761                	j	800014de <copyinstr+0x2c>
      return -1;
    80001558:	557d                	li	a0,-1
    8000155a:	b771                	j	800014e6 <copyinstr+0x34>
  int got_null = 0;
    8000155c:	4781                	li	a5,0
  if(got_null){
    8000155e:	0017b793          	seqz	a5,a5
    80001562:	40f00533          	neg	a0,a5
}
    80001566:	8082                	ret

0000000080001568 <insert_page_to_physical_memory>:

// Update data structure
int insert_page_to_physical_memory(uint64 a)
{
    80001568:	7179                	addi	sp,sp,-48
    8000156a:	f406                	sd	ra,40(sp)
    8000156c:	f022                	sd	s0,32(sp)
    8000156e:	ec26                	sd	s1,24(sp)
    80001570:	e84a                	sd	s2,16(sp)
    80001572:	e44e                	sd	s3,8(sp)
    80001574:	1800                	addi	s0,sp,48
    80001576:	89aa                	mv	s3,a0
  struct proc *p = myproc();
    80001578:	00000097          	auipc	ra,0x0
    8000157c:	5fe080e7          	jalr	1534(ra) # 80001b76 <myproc>
    80001580:	84aa                	mv	s1,a0
  int free_index = get_index_in_page_info_array(a, p->pages_physc_info.pages);
    80001582:	28850593          	addi	a1,a0,648
    80001586:	854e                	mv	a0,s3
    80001588:	00001097          	auipc	ra,0x1
    8000158c:	0b2080e7          	jalr	178(ra) # 8000263a <get_index_in_page_info_array>
  if (free_index < 0 || free_index >= MAX_PSYC_PAGES)
    80001590:	0005071b          	sext.w	a4,a0
    80001594:	47bd                	li	a5,15
    80001596:	06e7e563          	bltu	a5,a4,80001600 <insert_page_to_physical_memory+0x98>
    8000159a:	892a                	mv	s2,a0
    panic("uvmalloc: no free index in physc arr");
  p->pages_physc_info.pages[free_index].va = a;                // Set va of page
    8000159c:	00451793          	slli	a5,a0,0x4
    800015a0:	97a6                	add	a5,a5,s1
    800015a2:	2937b423          	sd	s3,648(a5)
  p->pages_physc_info.pages[free_index].time_inserted = ticks; //  Update insertion time
    800015a6:	00009717          	auipc	a4,0x9
    800015aa:	a8a72703          	lw	a4,-1398(a4) # 8000a030 <ticks>
    800015ae:	28e7aa23          	sw	a4,660(a5)
  reset_aging_counter(&p->pages_physc_info.pages[free_index]);
    800015b2:	0512                	slli	a0,a0,0x4
    800015b4:	28850513          	addi	a0,a0,648
    800015b8:	9526                	add	a0,a0,s1
    800015ba:	00002097          	auipc	ra,0x2
    800015be:	88e080e7          	jalr	-1906(ra) # 80002e48 <reset_aging_counter>
  if (p->pages_physc_info.free_spaces & (1 << free_index))
    800015c2:	2804d783          	lhu	a5,640(s1)
    800015c6:	4127d73b          	sraw	a4,a5,s2
    800015ca:	8b05                	andi	a4,a4,1
    800015cc:	e331                	bnez	a4,80001610 <insert_page_to_physical_memory+0xa8>
    panic("page_in: tried to set free space flag when it is already set");
  p->pages_physc_info.free_spaces |= (1 << free_index); // Mark space as occupied
    800015ce:	4505                	li	a0,1
    800015d0:	0125193b          	sllw	s2,a0,s2
    800015d4:	0127e7b3          	or	a5,a5,s2
    800015d8:	28f49023          	sh	a5,640(s1)
  p->physical_pages_num++;
    800015dc:	1704a783          	lw	a5,368(s1)
    800015e0:	2785                	addiw	a5,a5,1
    800015e2:	16f4a823          	sw	a5,368(s1)
  p->total_pages_num++;
    800015e6:	1744a783          	lw	a5,372(s1)
    800015ea:	2785                	addiw	a5,a5,1
    800015ec:	16f4aa23          	sw	a5,372(s1)

  return 0;
}
    800015f0:	4501                	li	a0,0
    800015f2:	70a2                	ld	ra,40(sp)
    800015f4:	7402                	ld	s0,32(sp)
    800015f6:	64e2                	ld	s1,24(sp)
    800015f8:	6942                	ld	s2,16(sp)
    800015fa:	69a2                	ld	s3,8(sp)
    800015fc:	6145                	addi	sp,sp,48
    800015fe:	8082                	ret
    panic("uvmalloc: no free index in physc arr");
    80001600:	00008517          	auipc	a0,0x8
    80001604:	b2850513          	addi	a0,a0,-1240 # 80009128 <digits+0xe8>
    80001608:	fffff097          	auipc	ra,0xfffff
    8000160c:	f22080e7          	jalr	-222(ra) # 8000052a <panic>
    panic("page_in: tried to set free space flag when it is already set");
    80001610:	00008517          	auipc	a0,0x8
    80001614:	b4050513          	addi	a0,a0,-1216 # 80009150 <digits+0x110>
    80001618:	fffff097          	auipc	ra,0xfffff
    8000161c:	f12080e7          	jalr	-238(ra) # 8000052a <panic>

0000000080001620 <remove_page_from_physical_memory>:

// Update data structure
int remove_page_from_physical_memory(uint64 a)
{
    80001620:	1101                	addi	sp,sp,-32
    80001622:	ec06                	sd	ra,24(sp)
    80001624:	e822                	sd	s0,16(sp)
    80001626:	e426                	sd	s1,8(sp)
    80001628:	e04a                	sd	s2,0(sp)
    8000162a:	1000                	addi	s0,sp,32
    8000162c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000162e:	00000097          	auipc	ra,0x0
    80001632:	548080e7          	jalr	1352(ra) # 80001b76 <myproc>
    80001636:	84aa                	mv	s1,a0
  int index = get_index_in_page_info_array(a, p->pages_physc_info.pages);
    80001638:	28850593          	addi	a1,a0,648
    8000163c:	854a                	mv	a0,s2
    8000163e:	00001097          	auipc	ra,0x1
    80001642:	ffc080e7          	jalr	-4(ra) # 8000263a <get_index_in_page_info_array>
  if (!(p->pages_physc_info.free_spaces & (1 << index)))
    80001646:	2804d783          	lhu	a5,640(s1)
    8000164a:	40a7d73b          	sraw	a4,a5,a0
    8000164e:	8b05                	andi	a4,a4,1
    80001650:	cb05                	beqz	a4,80001680 <remove_page_from_physical_memory+0x60>
    panic("uvmunmap: free space flag should be set but is unset");
  p->pages_physc_info.free_spaces ^= (1 << index);
    80001652:	4705                	li	a4,1
    80001654:	00a7153b          	sllw	a0,a4,a0
    80001658:	8fa9                	xor	a5,a5,a0
    8000165a:	28f49023          	sh	a5,640(s1)
  p->physical_pages_num--;
    8000165e:	1704a783          	lw	a5,368(s1)
    80001662:	37fd                	addiw	a5,a5,-1
    80001664:	16f4a823          	sw	a5,368(s1)
  p->total_pages_num--;
    80001668:	1744a783          	lw	a5,372(s1)
    8000166c:	37fd                	addiw	a5,a5,-1
    8000166e:	16f4aa23          	sw	a5,372(s1)
  return 0;
    80001672:	4501                	li	a0,0
    80001674:	60e2                	ld	ra,24(sp)
    80001676:	6442                	ld	s0,16(sp)
    80001678:	64a2                	ld	s1,8(sp)
    8000167a:	6902                	ld	s2,0(sp)
    8000167c:	6105                	addi	sp,sp,32
    8000167e:	8082                	ret
    panic("uvmunmap: free space flag should be set but is unset");
    80001680:	00008517          	auipc	a0,0x8
    80001684:	b1050513          	addi	a0,a0,-1264 # 80009190 <digits+0x150>
    80001688:	fffff097          	auipc	ra,0xfffff
    8000168c:	ea2080e7          	jalr	-350(ra) # 8000052a <panic>

0000000080001690 <uvmunmap>:
{
    80001690:	715d                	addi	sp,sp,-80
    80001692:	e486                	sd	ra,72(sp)
    80001694:	e0a2                	sd	s0,64(sp)
    80001696:	fc26                	sd	s1,56(sp)
    80001698:	f84a                	sd	s2,48(sp)
    8000169a:	f44e                	sd	s3,40(sp)
    8000169c:	f052                	sd	s4,32(sp)
    8000169e:	ec56                	sd	s5,24(sp)
    800016a0:	e85a                	sd	s6,16(sp)
    800016a2:	e45e                	sd	s7,8(sp)
    800016a4:	e062                	sd	s8,0(sp)
    800016a6:	0880                	addi	s0,sp,80
  if((va % PGSIZE) != 0)
    800016a8:	03459793          	slli	a5,a1,0x34
    800016ac:	eb85                	bnez	a5,800016dc <uvmunmap+0x4c>
    800016ae:	8a2a                	mv	s4,a0
    800016b0:	892e                	mv	s2,a1
    800016b2:	8ab6                	mv	s5,a3
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800016b4:	0632                	slli	a2,a2,0xc
    800016b6:	00b609b3          	add	s3,a2,a1
    if(PTE_FLAGS(*pte) == PTE_V)
    800016ba:	4c05                	li	s8,1
    if(myproc()->pid >2)
    800016bc:	4b89                	li	s7,2
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800016be:	6b05                	lui	s6,0x1
    800016c0:	0735ea63          	bltu	a1,s3,80001734 <uvmunmap+0xa4>
}
    800016c4:	60a6                	ld	ra,72(sp)
    800016c6:	6406                	ld	s0,64(sp)
    800016c8:	74e2                	ld	s1,56(sp)
    800016ca:	7942                	ld	s2,48(sp)
    800016cc:	79a2                	ld	s3,40(sp)
    800016ce:	7a02                	ld	s4,32(sp)
    800016d0:	6ae2                	ld	s5,24(sp)
    800016d2:	6b42                	ld	s6,16(sp)
    800016d4:	6ba2                	ld	s7,8(sp)
    800016d6:	6c02                	ld	s8,0(sp)
    800016d8:	6161                	addi	sp,sp,80
    800016da:	8082                	ret
    panic("uvmunmap: not aligned");
    800016dc:	00008517          	auipc	a0,0x8
    800016e0:	aec50513          	addi	a0,a0,-1300 # 800091c8 <digits+0x188>
    800016e4:	fffff097          	auipc	ra,0xfffff
    800016e8:	e46080e7          	jalr	-442(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    800016ec:	00008517          	auipc	a0,0x8
    800016f0:	af450513          	addi	a0,a0,-1292 # 800091e0 <digits+0x1a0>
    800016f4:	fffff097          	auipc	ra,0xfffff
    800016f8:	e36080e7          	jalr	-458(ra) # 8000052a <panic>
      panic("uvmunmap: not mapped");
    800016fc:	00008517          	auipc	a0,0x8
    80001700:	af450513          	addi	a0,a0,-1292 # 800091f0 <digits+0x1b0>
    80001704:	fffff097          	auipc	ra,0xfffff
    80001708:	e26080e7          	jalr	-474(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    8000170c:	00008517          	auipc	a0,0x8
    80001710:	afc50513          	addi	a0,a0,-1284 # 80009208 <digits+0x1c8>
    80001714:	fffff097          	auipc	ra,0xfffff
    80001718:	e16080e7          	jalr	-490(ra) # 8000052a <panic>
    *pte = 0;
    8000171c:	0004b023          	sd	zero,0(s1)
    if(myproc()->pid >2)
    80001720:	00000097          	auipc	ra,0x0
    80001724:	456080e7          	jalr	1110(ra) # 80001b76 <myproc>
    80001728:	591c                	lw	a5,48(a0)
    8000172a:	02fbcf63          	blt	s7,a5,80001768 <uvmunmap+0xd8>
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000172e:	995a                	add	s2,s2,s6
    80001730:	f9397ae3          	bgeu	s2,s3,800016c4 <uvmunmap+0x34>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001734:	4601                	li	a2,0
    80001736:	85ca                	mv	a1,s2
    80001738:	8552                	mv	a0,s4
    8000173a:	00000097          	auipc	ra,0x0
    8000173e:	86c080e7          	jalr	-1940(ra) # 80000fa6 <walk>
    80001742:	84aa                	mv	s1,a0
    80001744:	d545                	beqz	a0,800016ec <uvmunmap+0x5c>
    if((*pte & PTE_V) == 0)
    80001746:	6108                	ld	a0,0(a0)
    80001748:	00157793          	andi	a5,a0,1
    8000174c:	dbc5                	beqz	a5,800016fc <uvmunmap+0x6c>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000174e:	3ff57793          	andi	a5,a0,1023
    80001752:	fb878de3          	beq	a5,s8,8000170c <uvmunmap+0x7c>
    if(do_free){
    80001756:	fc0a83e3          	beqz	s5,8000171c <uvmunmap+0x8c>
      uint64 pa = PTE2PA(*pte);
    8000175a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000175c:	0532                	slli	a0,a0,0xc
    8000175e:	fffff097          	auipc	ra,0xfffff
    80001762:	278080e7          	jalr	632(ra) # 800009d6 <kfree>
    80001766:	bf5d                	j	8000171c <uvmunmap+0x8c>
      remove_page_from_physical_memory(a);  // Update our physical memory data structure
    80001768:	854a                	mv	a0,s2
    8000176a:	00000097          	auipc	ra,0x0
    8000176e:	eb6080e7          	jalr	-330(ra) # 80001620 <remove_page_from_physical_memory>
    80001772:	bf75                	j	8000172e <uvmunmap+0x9e>

0000000080001774 <uvmdealloc>:
{
    80001774:	1101                	addi	sp,sp,-32
    80001776:	ec06                	sd	ra,24(sp)
    80001778:	e822                	sd	s0,16(sp)
    8000177a:	e426                	sd	s1,8(sp)
    8000177c:	1000                	addi	s0,sp,32
    return oldsz;
    8000177e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001780:	00b67d63          	bgeu	a2,a1,8000179a <uvmdealloc+0x26>
    80001784:	84b2                	mv	s1,a2
  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001786:	6785                	lui	a5,0x1
    80001788:	17fd                	addi	a5,a5,-1
    8000178a:	00f60733          	add	a4,a2,a5
    8000178e:	767d                	lui	a2,0xfffff
    80001790:	8f71                	and	a4,a4,a2
    80001792:	97ae                	add	a5,a5,a1
    80001794:	8ff1                	and	a5,a5,a2
    80001796:	00f76863          	bltu	a4,a5,800017a6 <uvmdealloc+0x32>
}
    8000179a:	8526                	mv	a0,s1
    8000179c:	60e2                	ld	ra,24(sp)
    8000179e:	6442                	ld	s0,16(sp)
    800017a0:	64a2                	ld	s1,8(sp)
    800017a2:	6105                	addi	sp,sp,32
    800017a4:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800017a6:	8f99                	sub	a5,a5,a4
    800017a8:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800017aa:	4685                	li	a3,1
    800017ac:	0007861b          	sext.w	a2,a5
    800017b0:	85ba                	mv	a1,a4
    800017b2:	00000097          	auipc	ra,0x0
    800017b6:	ede080e7          	jalr	-290(ra) # 80001690 <uvmunmap>
    800017ba:	b7c5                	j	8000179a <uvmdealloc+0x26>

00000000800017bc <uvmalloc>:
{
    800017bc:	711d                	addi	sp,sp,-96
    800017be:	ec86                	sd	ra,88(sp)
    800017c0:	e8a2                	sd	s0,80(sp)
    800017c2:	e4a6                	sd	s1,72(sp)
    800017c4:	e0ca                	sd	s2,64(sp)
    800017c6:	fc4e                	sd	s3,56(sp)
    800017c8:	f852                	sd	s4,48(sp)
    800017ca:	f456                	sd	s5,40(sp)
    800017cc:	f05a                	sd	s6,32(sp)
    800017ce:	ec5e                	sd	s7,24(sp)
    800017d0:	e862                	sd	s8,16(sp)
    800017d2:	e466                	sd	s9,8(sp)
    800017d4:	1080                	addi	s0,sp,96
    800017d6:	8baa                	mv	s7,a0
    800017d8:	8c2e                	mv	s8,a1
    800017da:	8b32                	mv	s6,a2
  struct proc *p = myproc();
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	39a080e7          	jalr	922(ra) # 80001b76 <myproc>
  if(newsz < oldsz)
    800017e4:	0d8b6963          	bltu	s6,s8,800018b6 <uvmalloc+0xfa>
    800017e8:	84aa                	mv	s1,a0
  oldsz = PGROUNDUP(oldsz);
    800017ea:	6785                	lui	a5,0x1
    800017ec:	17fd                	addi	a5,a5,-1
    800017ee:	9c3e                	add	s8,s8,a5
    800017f0:	77fd                	lui	a5,0xfffff
    800017f2:	00fc7c33          	and	s8,s8,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800017f6:	0d6c7e63          	bgeu	s8,s6,800018d2 <uvmalloc+0x116>
    800017fa:	89e2                	mv	s3,s8
    if (p->pid > 2)
    800017fc:	4a89                	li	s5,2
      if(p->total_pages_num >=MAX_TOTAL_PAGES)
    800017fe:	4cfd                	li	s9,31
      while(p->physical_pages_num > MAX_PSYC_PAGES){
    80001800:	4a41                	li	s4,16
    80001802:	a0b1                	j	8000184e <uvmalloc+0x92>
        panic("uvmalloc: proc out of space!");
    80001804:	00008517          	auipc	a0,0x8
    80001808:	a1c50513          	addi	a0,a0,-1508 # 80009220 <digits+0x1e0>
    8000180c:	fffff097          	auipc	ra,0xfffff
    80001810:	d1e080e7          	jalr	-738(ra) # 8000052a <panic>
    mem = kalloc();
    80001814:	fffff097          	auipc	ra,0xfffff
    80001818:	2be080e7          	jalr	702(ra) # 80000ad2 <kalloc>
    8000181c:	892a                	mv	s2,a0
    if(mem == 0){
    8000181e:	cd29                	beqz	a0,80001878 <uvmalloc+0xbc>
    memset(mem, 0, PGSIZE);
    80001820:	6605                	lui	a2,0x1
    80001822:	4581                	li	a1,0
    80001824:	fffff097          	auipc	ra,0xfffff
    80001828:	49a080e7          	jalr	1178(ra) # 80000cbe <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000182c:	4779                	li	a4,30
    8000182e:	86ca                	mv	a3,s2
    80001830:	6605                	lui	a2,0x1
    80001832:	85ce                	mv	a1,s3
    80001834:	855e                	mv	a0,s7
    80001836:	00000097          	auipc	ra,0x0
    8000183a:	86e080e7          	jalr	-1938(ra) # 800010a4 <mappages>
    8000183e:	e531                	bnez	a0,8000188a <uvmalloc+0xce>
    if (p->pid > 2){
    80001840:	589c                	lw	a5,48(s1)
    80001842:	06fac263          	blt	s5,a5,800018a6 <uvmalloc+0xea>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001846:	6785                	lui	a5,0x1
    80001848:	99be                	add	s3,s3,a5
    8000184a:	0769f463          	bgeu	s3,s6,800018b2 <uvmalloc+0xf6>
    if (p->pid > 2)
    8000184e:	589c                	lw	a5,48(s1)
    80001850:	fcfad2e3          	bge	s5,a5,80001814 <uvmalloc+0x58>
      if(p->total_pages_num >=MAX_TOTAL_PAGES)
    80001854:	1744a783          	lw	a5,372(s1)
    80001858:	fafcc6e3          	blt	s9,a5,80001804 <uvmalloc+0x48>
      while(p->physical_pages_num > MAX_PSYC_PAGES){
    8000185c:	1704a783          	lw	a5,368(s1)
    80001860:	fafa5ae3          	bge	s4,a5,80001814 <uvmalloc+0x58>
        page_out(va);
    80001864:	4515                	li	a0,5
    80001866:	00001097          	auipc	ra,0x1
    8000186a:	dfa080e7          	jalr	-518(ra) # 80002660 <page_out>
      while(p->physical_pages_num > MAX_PSYC_PAGES){
    8000186e:	1704a783          	lw	a5,368(s1)
    80001872:	fefa49e3          	blt	s4,a5,80001864 <uvmalloc+0xa8>
    80001876:	bf79                	j	80001814 <uvmalloc+0x58>
      uvmdealloc(pagetable, a, oldsz);
    80001878:	8662                	mv	a2,s8
    8000187a:	85ce                	mv	a1,s3
    8000187c:	855e                	mv	a0,s7
    8000187e:	00000097          	auipc	ra,0x0
    80001882:	ef6080e7          	jalr	-266(ra) # 80001774 <uvmdealloc>
      return 0;
    80001886:	4501                	li	a0,0
    80001888:	a805                	j	800018b8 <uvmalloc+0xfc>
      kfree(mem);
    8000188a:	854a                	mv	a0,s2
    8000188c:	fffff097          	auipc	ra,0xfffff
    80001890:	14a080e7          	jalr	330(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001894:	8662                	mv	a2,s8
    80001896:	85ce                	mv	a1,s3
    80001898:	855e                	mv	a0,s7
    8000189a:	00000097          	auipc	ra,0x0
    8000189e:	eda080e7          	jalr	-294(ra) # 80001774 <uvmdealloc>
      return 0;
    800018a2:	4501                	li	a0,0
    800018a4:	a811                	j	800018b8 <uvmalloc+0xfc>
      insert_page_to_physical_memory(a);
    800018a6:	854e                	mv	a0,s3
    800018a8:	00000097          	auipc	ra,0x0
    800018ac:	cc0080e7          	jalr	-832(ra) # 80001568 <insert_page_to_physical_memory>
    800018b0:	bf59                	j	80001846 <uvmalloc+0x8a>
  return newsz;
    800018b2:	855a                	mv	a0,s6
    800018b4:	a011                	j	800018b8 <uvmalloc+0xfc>
    return oldsz;
    800018b6:	8562                	mv	a0,s8
}
    800018b8:	60e6                	ld	ra,88(sp)
    800018ba:	6446                	ld	s0,80(sp)
    800018bc:	64a6                	ld	s1,72(sp)
    800018be:	6906                	ld	s2,64(sp)
    800018c0:	79e2                	ld	s3,56(sp)
    800018c2:	7a42                	ld	s4,48(sp)
    800018c4:	7aa2                	ld	s5,40(sp)
    800018c6:	7b02                	ld	s6,32(sp)
    800018c8:	6be2                	ld	s7,24(sp)
    800018ca:	6c42                	ld	s8,16(sp)
    800018cc:	6ca2                	ld	s9,8(sp)
    800018ce:	6125                	addi	sp,sp,96
    800018d0:	8082                	ret
  return newsz;
    800018d2:	855a                	mv	a0,s6
    800018d4:	b7d5                	j	800018b8 <uvmalloc+0xfc>

00000000800018d6 <uvmfree>:
{
    800018d6:	1101                	addi	sp,sp,-32
    800018d8:	ec06                	sd	ra,24(sp)
    800018da:	e822                	sd	s0,16(sp)
    800018dc:	e426                	sd	s1,8(sp)
    800018de:	1000                	addi	s0,sp,32
    800018e0:	84aa                	mv	s1,a0
  if(sz > 0)
    800018e2:	e999                	bnez	a1,800018f8 <uvmfree+0x22>
  freewalk(pagetable);
    800018e4:	8526                	mv	a0,s1
    800018e6:	00000097          	auipc	ra,0x0
    800018ea:	a12080e7          	jalr	-1518(ra) # 800012f8 <freewalk>
}
    800018ee:	60e2                	ld	ra,24(sp)
    800018f0:	6442                	ld	s0,16(sp)
    800018f2:	64a2                	ld	s1,8(sp)
    800018f4:	6105                	addi	sp,sp,32
    800018f6:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800018f8:	6605                	lui	a2,0x1
    800018fa:	167d                	addi	a2,a2,-1
    800018fc:	962e                	add	a2,a2,a1
    800018fe:	4685                	li	a3,1
    80001900:	8231                	srli	a2,a2,0xc
    80001902:	4581                	li	a1,0
    80001904:	00000097          	auipc	ra,0x0
    80001908:	d8c080e7          	jalr	-628(ra) # 80001690 <uvmunmap>
    8000190c:	bfe1                	j	800018e4 <uvmfree+0xe>

000000008000190e <uvmcopy>:
  for(i = 0; i < sz; i += PGSIZE){
    8000190e:	c679                	beqz	a2,800019dc <uvmcopy+0xce>
{
    80001910:	715d                	addi	sp,sp,-80
    80001912:	e486                	sd	ra,72(sp)
    80001914:	e0a2                	sd	s0,64(sp)
    80001916:	fc26                	sd	s1,56(sp)
    80001918:	f84a                	sd	s2,48(sp)
    8000191a:	f44e                	sd	s3,40(sp)
    8000191c:	f052                	sd	s4,32(sp)
    8000191e:	ec56                	sd	s5,24(sp)
    80001920:	e85a                	sd	s6,16(sp)
    80001922:	e45e                	sd	s7,8(sp)
    80001924:	0880                	addi	s0,sp,80
    80001926:	8b2a                	mv	s6,a0
    80001928:	8aae                	mv	s5,a1
    8000192a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000192c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000192e:	4601                	li	a2,0
    80001930:	85ce                	mv	a1,s3
    80001932:	855a                	mv	a0,s6
    80001934:	fffff097          	auipc	ra,0xfffff
    80001938:	672080e7          	jalr	1650(ra) # 80000fa6 <walk>
    8000193c:	c531                	beqz	a0,80001988 <uvmcopy+0x7a>
    if((*pte & PTE_V) == 0)
    8000193e:	6118                	ld	a4,0(a0)
    80001940:	00177793          	andi	a5,a4,1
    80001944:	cbb1                	beqz	a5,80001998 <uvmcopy+0x8a>
    pa = PTE2PA(*pte);
    80001946:	00a75593          	srli	a1,a4,0xa
    8000194a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000194e:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001952:	fffff097          	auipc	ra,0xfffff
    80001956:	180080e7          	jalr	384(ra) # 80000ad2 <kalloc>
    8000195a:	892a                	mv	s2,a0
    8000195c:	c939                	beqz	a0,800019b2 <uvmcopy+0xa4>
    memmove(mem, (char*)pa, PGSIZE);
    8000195e:	6605                	lui	a2,0x1
    80001960:	85de                	mv	a1,s7
    80001962:	fffff097          	auipc	ra,0xfffff
    80001966:	3b8080e7          	jalr	952(ra) # 80000d1a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000196a:	8726                	mv	a4,s1
    8000196c:	86ca                	mv	a3,s2
    8000196e:	6605                	lui	a2,0x1
    80001970:	85ce                	mv	a1,s3
    80001972:	8556                	mv	a0,s5
    80001974:	fffff097          	auipc	ra,0xfffff
    80001978:	730080e7          	jalr	1840(ra) # 800010a4 <mappages>
    8000197c:	e515                	bnez	a0,800019a8 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000197e:	6785                	lui	a5,0x1
    80001980:	99be                	add	s3,s3,a5
    80001982:	fb49e6e3          	bltu	s3,s4,8000192e <uvmcopy+0x20>
    80001986:	a081                	j	800019c6 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001988:	00008517          	auipc	a0,0x8
    8000198c:	8b850513          	addi	a0,a0,-1864 # 80009240 <digits+0x200>
    80001990:	fffff097          	auipc	ra,0xfffff
    80001994:	b9a080e7          	jalr	-1126(ra) # 8000052a <panic>
      panic("uvmcopy: page not present");
    80001998:	00008517          	auipc	a0,0x8
    8000199c:	8c850513          	addi	a0,a0,-1848 # 80009260 <digits+0x220>
    800019a0:	fffff097          	auipc	ra,0xfffff
    800019a4:	b8a080e7          	jalr	-1142(ra) # 8000052a <panic>
      kfree(mem);
    800019a8:	854a                	mv	a0,s2
    800019aa:	fffff097          	auipc	ra,0xfffff
    800019ae:	02c080e7          	jalr	44(ra) # 800009d6 <kfree>
  uvmunmap(new, 0, i / PGSIZE, 1);
    800019b2:	4685                	li	a3,1
    800019b4:	00c9d613          	srli	a2,s3,0xc
    800019b8:	4581                	li	a1,0
    800019ba:	8556                	mv	a0,s5
    800019bc:	00000097          	auipc	ra,0x0
    800019c0:	cd4080e7          	jalr	-812(ra) # 80001690 <uvmunmap>
  return -1;
    800019c4:	557d                	li	a0,-1
}
    800019c6:	60a6                	ld	ra,72(sp)
    800019c8:	6406                	ld	s0,64(sp)
    800019ca:	74e2                	ld	s1,56(sp)
    800019cc:	7942                	ld	s2,48(sp)
    800019ce:	79a2                	ld	s3,40(sp)
    800019d0:	7a02                	ld	s4,32(sp)
    800019d2:	6ae2                	ld	s5,24(sp)
    800019d4:	6b42                	ld	s6,16(sp)
    800019d6:	6ba2                	ld	s7,8(sp)
    800019d8:	6161                	addi	sp,sp,80
    800019da:	8082                	ret
  return 0;
    800019dc:	4501                	li	a0,0
}
    800019de:	8082                	ret

00000000800019e0 <SCFIFO_compare>:
  return res;
}

int SCFIFO_compare(struct page_info *pg1, struct page_info *pg2)
{
  if (!pg1 || !pg2)
    800019e0:	c511                	beqz	a0,800019ec <SCFIFO_compare+0xc>
    800019e2:	c589                	beqz	a1,800019ec <SCFIFO_compare+0xc>
    panic("SCFIFO_compare : null input");

  return pg1->time_inserted - pg2->time_inserted;
    800019e4:	4548                	lw	a0,12(a0)
    800019e6:	45dc                	lw	a5,12(a1)
}
    800019e8:	9d1d                	subw	a0,a0,a5
    800019ea:	8082                	ret
{
    800019ec:	1141                	addi	sp,sp,-16
    800019ee:	e406                	sd	ra,8(sp)
    800019f0:	e022                	sd	s0,0(sp)
    800019f2:	0800                	addi	s0,sp,16
    panic("SCFIFO_compare : null input");
    800019f4:	00008517          	auipc	a0,0x8
    800019f8:	88c50513          	addi	a0,a0,-1908 # 80009280 <digits+0x240>
    800019fc:	fffff097          	auipc	ra,0xfffff
    80001a00:	b2e080e7          	jalr	-1234(ra) # 8000052a <panic>

0000000080001a04 <proc_mapstacks>:
{
    80001a04:	7139                	addi	sp,sp,-64
    80001a06:	fc06                	sd	ra,56(sp)
    80001a08:	f822                	sd	s0,48(sp)
    80001a0a:	f426                	sd	s1,40(sp)
    80001a0c:	f04a                	sd	s2,32(sp)
    80001a0e:	ec4e                	sd	s3,24(sp)
    80001a10:	e852                	sd	s4,16(sp)
    80001a12:	e456                	sd	s5,8(sp)
    80001a14:	e05a                	sd	s6,0(sp)
    80001a16:	0080                	addi	s0,sp,64
    80001a18:	89aa                	mv	s3,a0
  for (p = proc; p < &proc[NPROC]; p++)
    80001a1a:	00011497          	auipc	s1,0x11
    80001a1e:	cb648493          	addi	s1,s1,-842 # 800126d0 <proc>
    uint64 va = KSTACK((int)(p - proc));
    80001a22:	8b26                	mv	s6,s1
    80001a24:	00007a97          	auipc	s5,0x7
    80001a28:	5dca8a93          	addi	s5,s5,1500 # 80009000 <etext>
    80001a2c:	04000937          	lui	s2,0x4000
    80001a30:	197d                	addi	s2,s2,-1
    80001a32:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001a34:	0001fa17          	auipc	s4,0x1f
    80001a38:	e9ca0a13          	addi	s4,s4,-356 # 800208d0 <tickslock>
    char *pa = kalloc();
    80001a3c:	fffff097          	auipc	ra,0xfffff
    80001a40:	096080e7          	jalr	150(ra) # 80000ad2 <kalloc>
    80001a44:	862a                	mv	a2,a0
    if (pa == 0)
    80001a46:	c131                	beqz	a0,80001a8a <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001a48:	416485b3          	sub	a1,s1,s6
    80001a4c:	858d                	srai	a1,a1,0x3
    80001a4e:	000ab783          	ld	a5,0(s5)
    80001a52:	02f585b3          	mul	a1,a1,a5
    80001a56:	2585                	addiw	a1,a1,1
    80001a58:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a5c:	4719                	li	a4,6
    80001a5e:	6685                	lui	a3,0x1
    80001a60:	40b905b3          	sub	a1,s2,a1
    80001a64:	854e                	mv	a0,s3
    80001a66:	fffff097          	auipc	ra,0xfffff
    80001a6a:	6cc080e7          	jalr	1740(ra) # 80001132 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a6e:	38848493          	addi	s1,s1,904
    80001a72:	fd4495e3          	bne	s1,s4,80001a3c <proc_mapstacks+0x38>
}
    80001a76:	70e2                	ld	ra,56(sp)
    80001a78:	7442                	ld	s0,48(sp)
    80001a7a:	74a2                	ld	s1,40(sp)
    80001a7c:	7902                	ld	s2,32(sp)
    80001a7e:	69e2                	ld	s3,24(sp)
    80001a80:	6a42                	ld	s4,16(sp)
    80001a82:	6aa2                	ld	s5,8(sp)
    80001a84:	6b02                	ld	s6,0(sp)
    80001a86:	6121                	addi	sp,sp,64
    80001a88:	8082                	ret
      panic("kalloc");
    80001a8a:	00008517          	auipc	a0,0x8
    80001a8e:	81650513          	addi	a0,a0,-2026 # 800092a0 <digits+0x260>
    80001a92:	fffff097          	auipc	ra,0xfffff
    80001a96:	a98080e7          	jalr	-1384(ra) # 8000052a <panic>

0000000080001a9a <procinit>:
{
    80001a9a:	7139                	addi	sp,sp,-64
    80001a9c:	fc06                	sd	ra,56(sp)
    80001a9e:	f822                	sd	s0,48(sp)
    80001aa0:	f426                	sd	s1,40(sp)
    80001aa2:	f04a                	sd	s2,32(sp)
    80001aa4:	ec4e                	sd	s3,24(sp)
    80001aa6:	e852                	sd	s4,16(sp)
    80001aa8:	e456                	sd	s5,8(sp)
    80001aaa:	e05a                	sd	s6,0(sp)
    80001aac:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    80001aae:	00007597          	auipc	a1,0x7
    80001ab2:	7fa58593          	addi	a1,a1,2042 # 800092a8 <digits+0x268>
    80001ab6:	00010517          	auipc	a0,0x10
    80001aba:	7ea50513          	addi	a0,a0,2026 # 800122a0 <pid_lock>
    80001abe:	fffff097          	auipc	ra,0xfffff
    80001ac2:	074080e7          	jalr	116(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001ac6:	00007597          	auipc	a1,0x7
    80001aca:	7ea58593          	addi	a1,a1,2026 # 800092b0 <digits+0x270>
    80001ace:	00010517          	auipc	a0,0x10
    80001ad2:	7ea50513          	addi	a0,a0,2026 # 800122b8 <wait_lock>
    80001ad6:	fffff097          	auipc	ra,0xfffff
    80001ada:	05c080e7          	jalr	92(ra) # 80000b32 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001ade:	00011497          	auipc	s1,0x11
    80001ae2:	bf248493          	addi	s1,s1,-1038 # 800126d0 <proc>
    initlock(&p->lock, "proc");
    80001ae6:	00007b17          	auipc	s6,0x7
    80001aea:	7dab0b13          	addi	s6,s6,2010 # 800092c0 <digits+0x280>
    p->kstack = KSTACK((int)(p - proc));
    80001aee:	8aa6                	mv	s5,s1
    80001af0:	00007a17          	auipc	s4,0x7
    80001af4:	510a0a13          	addi	s4,s4,1296 # 80009000 <etext>
    80001af8:	04000937          	lui	s2,0x4000
    80001afc:	197d                	addi	s2,s2,-1
    80001afe:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001b00:	0001f997          	auipc	s3,0x1f
    80001b04:	dd098993          	addi	s3,s3,-560 # 800208d0 <tickslock>
    initlock(&p->lock, "proc");
    80001b08:	85da                	mv	a1,s6
    80001b0a:	8526                	mv	a0,s1
    80001b0c:	fffff097          	auipc	ra,0xfffff
    80001b10:	026080e7          	jalr	38(ra) # 80000b32 <initlock>
    p->kstack = KSTACK((int)(p - proc));
    80001b14:	415487b3          	sub	a5,s1,s5
    80001b18:	878d                	srai	a5,a5,0x3
    80001b1a:	000a3703          	ld	a4,0(s4)
    80001b1e:	02e787b3          	mul	a5,a5,a4
    80001b22:	2785                	addiw	a5,a5,1
    80001b24:	00d7979b          	slliw	a5,a5,0xd
    80001b28:	40f907b3          	sub	a5,s2,a5
    80001b2c:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001b2e:	38848493          	addi	s1,s1,904
    80001b32:	fd349be3          	bne	s1,s3,80001b08 <procinit+0x6e>
}
    80001b36:	70e2                	ld	ra,56(sp)
    80001b38:	7442                	ld	s0,48(sp)
    80001b3a:	74a2                	ld	s1,40(sp)
    80001b3c:	7902                	ld	s2,32(sp)
    80001b3e:	69e2                	ld	s3,24(sp)
    80001b40:	6a42                	ld	s4,16(sp)
    80001b42:	6aa2                	ld	s5,8(sp)
    80001b44:	6b02                	ld	s6,0(sp)
    80001b46:	6121                	addi	sp,sp,64
    80001b48:	8082                	ret

0000000080001b4a <cpuid>:
{
    80001b4a:	1141                	addi	sp,sp,-16
    80001b4c:	e422                	sd	s0,8(sp)
    80001b4e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b50:	8512                	mv	a0,tp
}
    80001b52:	2501                	sext.w	a0,a0
    80001b54:	6422                	ld	s0,8(sp)
    80001b56:	0141                	addi	sp,sp,16
    80001b58:	8082                	ret

0000000080001b5a <mycpu>:
{
    80001b5a:	1141                	addi	sp,sp,-16
    80001b5c:	e422                	sd	s0,8(sp)
    80001b5e:	0800                	addi	s0,sp,16
    80001b60:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001b62:	2781                	sext.w	a5,a5
    80001b64:	079e                	slli	a5,a5,0x7
}
    80001b66:	00010517          	auipc	a0,0x10
    80001b6a:	76a50513          	addi	a0,a0,1898 # 800122d0 <cpus>
    80001b6e:	953e                	add	a0,a0,a5
    80001b70:	6422                	ld	s0,8(sp)
    80001b72:	0141                	addi	sp,sp,16
    80001b74:	8082                	ret

0000000080001b76 <myproc>:
{
    80001b76:	1101                	addi	sp,sp,-32
    80001b78:	ec06                	sd	ra,24(sp)
    80001b7a:	e822                	sd	s0,16(sp)
    80001b7c:	e426                	sd	s1,8(sp)
    80001b7e:	1000                	addi	s0,sp,32
  push_off();
    80001b80:	fffff097          	auipc	ra,0xfffff
    80001b84:	ff6080e7          	jalr	-10(ra) # 80000b76 <push_off>
    80001b88:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001b8a:	2781                	sext.w	a5,a5
    80001b8c:	079e                	slli	a5,a5,0x7
    80001b8e:	00010717          	auipc	a4,0x10
    80001b92:	71270713          	addi	a4,a4,1810 # 800122a0 <pid_lock>
    80001b96:	97ba                	add	a5,a5,a4
    80001b98:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b9a:	fffff097          	auipc	ra,0xfffff
    80001b9e:	07c080e7          	jalr	124(ra) # 80000c16 <pop_off>
}
    80001ba2:	8526                	mv	a0,s1
    80001ba4:	60e2                	ld	ra,24(sp)
    80001ba6:	6442                	ld	s0,16(sp)
    80001ba8:	64a2                	ld	s1,8(sp)
    80001baa:	6105                	addi	sp,sp,32
    80001bac:	8082                	ret

0000000080001bae <forkret>:
{
    80001bae:	1141                	addi	sp,sp,-16
    80001bb0:	e406                	sd	ra,8(sp)
    80001bb2:	e022                	sd	s0,0(sp)
    80001bb4:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001bb6:	00000097          	auipc	ra,0x0
    80001bba:	fc0080e7          	jalr	-64(ra) # 80001b76 <myproc>
    80001bbe:	fffff097          	auipc	ra,0xfffff
    80001bc2:	0b8080e7          	jalr	184(ra) # 80000c76 <release>
  if (first)
    80001bc6:	00008797          	auipc	a5,0x8
    80001bca:	0ba7a783          	lw	a5,186(a5) # 80009c80 <first.1>
    80001bce:	eb89                	bnez	a5,80001be0 <forkret+0x32>
  usertrapret();
    80001bd0:	00001097          	auipc	ra,0x1
    80001bd4:	32e080e7          	jalr	814(ra) # 80002efe <usertrapret>
}
    80001bd8:	60a2                	ld	ra,8(sp)
    80001bda:	6402                	ld	s0,0(sp)
    80001bdc:	0141                	addi	sp,sp,16
    80001bde:	8082                	ret
    first = 0;
    80001be0:	00008797          	auipc	a5,0x8
    80001be4:	0a07a023          	sw	zero,160(a5) # 80009c80 <first.1>
    fsinit(ROOTDEV);
    80001be8:	4505                	li	a0,1
    80001bea:	00002097          	auipc	ra,0x2
    80001bee:	152080e7          	jalr	338(ra) # 80003d3c <fsinit>
    80001bf2:	bff9                	j	80001bd0 <forkret+0x22>

0000000080001bf4 <allocpid>:
{
    80001bf4:	1101                	addi	sp,sp,-32
    80001bf6:	ec06                	sd	ra,24(sp)
    80001bf8:	e822                	sd	s0,16(sp)
    80001bfa:	e426                	sd	s1,8(sp)
    80001bfc:	e04a                	sd	s2,0(sp)
    80001bfe:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c00:	00010917          	auipc	s2,0x10
    80001c04:	6a090913          	addi	s2,s2,1696 # 800122a0 <pid_lock>
    80001c08:	854a                	mv	a0,s2
    80001c0a:	fffff097          	auipc	ra,0xfffff
    80001c0e:	fb8080e7          	jalr	-72(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001c12:	00008797          	auipc	a5,0x8
    80001c16:	07278793          	addi	a5,a5,114 # 80009c84 <nextpid>
    80001c1a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c1c:	0014871b          	addiw	a4,s1,1
    80001c20:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c22:	854a                	mv	a0,s2
    80001c24:	fffff097          	auipc	ra,0xfffff
    80001c28:	052080e7          	jalr	82(ra) # 80000c76 <release>
}
    80001c2c:	8526                	mv	a0,s1
    80001c2e:	60e2                	ld	ra,24(sp)
    80001c30:	6442                	ld	s0,16(sp)
    80001c32:	64a2                	ld	s1,8(sp)
    80001c34:	6902                	ld	s2,0(sp)
    80001c36:	6105                	addi	sp,sp,32
    80001c38:	8082                	ret

0000000080001c3a <proc_pagetable>:
{
    80001c3a:	1101                	addi	sp,sp,-32
    80001c3c:	ec06                	sd	ra,24(sp)
    80001c3e:	e822                	sd	s0,16(sp)
    80001c40:	e426                	sd	s1,8(sp)
    80001c42:	e04a                	sd	s2,0(sp)
    80001c44:	1000                	addi	s0,sp,32
    80001c46:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c48:	fffff097          	auipc	ra,0xfffff
    80001c4c:	610080e7          	jalr	1552(ra) # 80001258 <uvmcreate>
    80001c50:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001c52:	c121                	beqz	a0,80001c92 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c54:	4729                	li	a4,10
    80001c56:	00006697          	auipc	a3,0x6
    80001c5a:	3aa68693          	addi	a3,a3,938 # 80008000 <_trampoline>
    80001c5e:	6605                	lui	a2,0x1
    80001c60:	040005b7          	lui	a1,0x4000
    80001c64:	15fd                	addi	a1,a1,-1
    80001c66:	05b2                	slli	a1,a1,0xc
    80001c68:	fffff097          	auipc	ra,0xfffff
    80001c6c:	43c080e7          	jalr	1084(ra) # 800010a4 <mappages>
    80001c70:	02054863          	bltz	a0,80001ca0 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c74:	4719                	li	a4,6
    80001c76:	05893683          	ld	a3,88(s2)
    80001c7a:	6605                	lui	a2,0x1
    80001c7c:	020005b7          	lui	a1,0x2000
    80001c80:	15fd                	addi	a1,a1,-1
    80001c82:	05b6                	slli	a1,a1,0xd
    80001c84:	8526                	mv	a0,s1
    80001c86:	fffff097          	auipc	ra,0xfffff
    80001c8a:	41e080e7          	jalr	1054(ra) # 800010a4 <mappages>
    80001c8e:	02054163          	bltz	a0,80001cb0 <proc_pagetable+0x76>
}
    80001c92:	8526                	mv	a0,s1
    80001c94:	60e2                	ld	ra,24(sp)
    80001c96:	6442                	ld	s0,16(sp)
    80001c98:	64a2                	ld	s1,8(sp)
    80001c9a:	6902                	ld	s2,0(sp)
    80001c9c:	6105                	addi	sp,sp,32
    80001c9e:	8082                	ret
    uvmfree(pagetable, 0);
    80001ca0:	4581                	li	a1,0
    80001ca2:	8526                	mv	a0,s1
    80001ca4:	00000097          	auipc	ra,0x0
    80001ca8:	c32080e7          	jalr	-974(ra) # 800018d6 <uvmfree>
    return 0;
    80001cac:	4481                	li	s1,0
    80001cae:	b7d5                	j	80001c92 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cb0:	4681                	li	a3,0
    80001cb2:	4605                	li	a2,1
    80001cb4:	040005b7          	lui	a1,0x4000
    80001cb8:	15fd                	addi	a1,a1,-1
    80001cba:	05b2                	slli	a1,a1,0xc
    80001cbc:	8526                	mv	a0,s1
    80001cbe:	00000097          	auipc	ra,0x0
    80001cc2:	9d2080e7          	jalr	-1582(ra) # 80001690 <uvmunmap>
    uvmfree(pagetable, 0);
    80001cc6:	4581                	li	a1,0
    80001cc8:	8526                	mv	a0,s1
    80001cca:	00000097          	auipc	ra,0x0
    80001cce:	c0c080e7          	jalr	-1012(ra) # 800018d6 <uvmfree>
    return 0;
    80001cd2:	4481                	li	s1,0
    80001cd4:	bf7d                	j	80001c92 <proc_pagetable+0x58>

0000000080001cd6 <proc_freepagetable>:
{
    80001cd6:	1101                	addi	sp,sp,-32
    80001cd8:	ec06                	sd	ra,24(sp)
    80001cda:	e822                	sd	s0,16(sp)
    80001cdc:	e426                	sd	s1,8(sp)
    80001cde:	e04a                	sd	s2,0(sp)
    80001ce0:	1000                	addi	s0,sp,32
    80001ce2:	84aa                	mv	s1,a0
    80001ce4:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ce6:	4681                	li	a3,0
    80001ce8:	4605                	li	a2,1
    80001cea:	040005b7          	lui	a1,0x4000
    80001cee:	15fd                	addi	a1,a1,-1
    80001cf0:	05b2                	slli	a1,a1,0xc
    80001cf2:	00000097          	auipc	ra,0x0
    80001cf6:	99e080e7          	jalr	-1634(ra) # 80001690 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cfa:	4681                	li	a3,0
    80001cfc:	4605                	li	a2,1
    80001cfe:	020005b7          	lui	a1,0x2000
    80001d02:	15fd                	addi	a1,a1,-1
    80001d04:	05b6                	slli	a1,a1,0xd
    80001d06:	8526                	mv	a0,s1
    80001d08:	00000097          	auipc	ra,0x0
    80001d0c:	988080e7          	jalr	-1656(ra) # 80001690 <uvmunmap>
  uvmfree(pagetable, sz);
    80001d10:	85ca                	mv	a1,s2
    80001d12:	8526                	mv	a0,s1
    80001d14:	00000097          	auipc	ra,0x0
    80001d18:	bc2080e7          	jalr	-1086(ra) # 800018d6 <uvmfree>
}
    80001d1c:	60e2                	ld	ra,24(sp)
    80001d1e:	6442                	ld	s0,16(sp)
    80001d20:	64a2                	ld	s1,8(sp)
    80001d22:	6902                	ld	s2,0(sp)
    80001d24:	6105                	addi	sp,sp,32
    80001d26:	8082                	ret

0000000080001d28 <freeproc>:
{
    80001d28:	1101                	addi	sp,sp,-32
    80001d2a:	ec06                	sd	ra,24(sp)
    80001d2c:	e822                	sd	s0,16(sp)
    80001d2e:	e426                	sd	s1,8(sp)
    80001d30:	1000                	addi	s0,sp,32
    80001d32:	84aa                	mv	s1,a0
  removeSwapFile(p);
    80001d34:	00003097          	auipc	ra,0x3
    80001d38:	ae2080e7          	jalr	-1310(ra) # 80004816 <removeSwapFile>
  if (p->trapframe)
    80001d3c:	6ca8                	ld	a0,88(s1)
    80001d3e:	c509                	beqz	a0,80001d48 <freeproc+0x20>
    kfree((void *)p->trapframe);
    80001d40:	fffff097          	auipc	ra,0xfffff
    80001d44:	c96080e7          	jalr	-874(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001d48:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001d4c:	68a8                	ld	a0,80(s1)
    80001d4e:	c511                	beqz	a0,80001d5a <freeproc+0x32>
    proc_freepagetable(p->pagetable, p->sz);
    80001d50:	64ac                	ld	a1,72(s1)
    80001d52:	00000097          	auipc	ra,0x0
    80001d56:	f84080e7          	jalr	-124(ra) # 80001cd6 <proc_freepagetable>
  p->pagetable = 0;
    80001d5a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001d5e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001d62:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001d66:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001d6a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001d6e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001d72:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001d76:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001d7a:	0004ac23          	sw	zero,24(s1)
}
    80001d7e:	60e2                	ld	ra,24(sp)
    80001d80:	6442                	ld	s0,16(sp)
    80001d82:	64a2                	ld	s1,8(sp)
    80001d84:	6105                	addi	sp,sp,32
    80001d86:	8082                	ret

0000000080001d88 <allocproc>:
{
    80001d88:	1101                	addi	sp,sp,-32
    80001d8a:	ec06                	sd	ra,24(sp)
    80001d8c:	e822                	sd	s0,16(sp)
    80001d8e:	e426                	sd	s1,8(sp)
    80001d90:	e04a                	sd	s2,0(sp)
    80001d92:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001d94:	00011497          	auipc	s1,0x11
    80001d98:	93c48493          	addi	s1,s1,-1732 # 800126d0 <proc>
    80001d9c:	0001f917          	auipc	s2,0x1f
    80001da0:	b3490913          	addi	s2,s2,-1228 # 800208d0 <tickslock>
    acquire(&p->lock);
    80001da4:	8526                	mv	a0,s1
    80001da6:	fffff097          	auipc	ra,0xfffff
    80001daa:	e1c080e7          	jalr	-484(ra) # 80000bc2 <acquire>
    if (p->state == UNUSED)
    80001dae:	4c9c                	lw	a5,24(s1)
    80001db0:	cf81                	beqz	a5,80001dc8 <allocproc+0x40>
      release(&p->lock);
    80001db2:	8526                	mv	a0,s1
    80001db4:	fffff097          	auipc	ra,0xfffff
    80001db8:	ec2080e7          	jalr	-318(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001dbc:	38848493          	addi	s1,s1,904
    80001dc0:	ff2492e3          	bne	s1,s2,80001da4 <allocproc+0x1c>
  return 0;
    80001dc4:	4481                	li	s1,0
    80001dc6:	a08d                	j	80001e28 <allocproc+0xa0>
  p->pid = allocpid();
    80001dc8:	00000097          	auipc	ra,0x0
    80001dcc:	e2c080e7          	jalr	-468(ra) # 80001bf4 <allocpid>
    80001dd0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001dd2:	4785                	li	a5,1
    80001dd4:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001dd6:	fffff097          	auipc	ra,0xfffff
    80001dda:	cfc080e7          	jalr	-772(ra) # 80000ad2 <kalloc>
    80001dde:	892a                	mv	s2,a0
    80001de0:	eca8                	sd	a0,88(s1)
    80001de2:	c931                	beqz	a0,80001e36 <allocproc+0xae>
  p->pagetable = proc_pagetable(p);
    80001de4:	8526                	mv	a0,s1
    80001de6:	00000097          	auipc	ra,0x0
    80001dea:	e54080e7          	jalr	-428(ra) # 80001c3a <proc_pagetable>
    80001dee:	892a                	mv	s2,a0
    80001df0:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001df2:	cd31                	beqz	a0,80001e4e <allocproc+0xc6>
  memset(&p->context, 0, sizeof(p->context));
    80001df4:	07000613          	li	a2,112
    80001df8:	4581                	li	a1,0
    80001dfa:	06048513          	addi	a0,s1,96
    80001dfe:	fffff097          	auipc	ra,0xfffff
    80001e02:	ec0080e7          	jalr	-320(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80001e06:	00000797          	auipc	a5,0x0
    80001e0a:	da878793          	addi	a5,a5,-600 # 80001bae <forkret>
    80001e0e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001e10:	60bc                	ld	a5,64(s1)
    80001e12:	6705                	lui	a4,0x1
    80001e14:	97ba                	add	a5,a5,a4
    80001e16:	f4bc                	sd	a5,104(s1)
  p->physical_pages_num = 0;
    80001e18:	1604a823          	sw	zero,368(s1)
  p->total_pages_num = 0;
    80001e1c:	1604aa23          	sw	zero,372(s1)
  p->pages_physc_info.free_spaces = 0;
    80001e20:	28049023          	sh	zero,640(s1)
  p->pages_swap_info.free_spaces = 0;
    80001e24:	16049c23          	sh	zero,376(s1)
}
    80001e28:	8526                	mv	a0,s1
    80001e2a:	60e2                	ld	ra,24(sp)
    80001e2c:	6442                	ld	s0,16(sp)
    80001e2e:	64a2                	ld	s1,8(sp)
    80001e30:	6902                	ld	s2,0(sp)
    80001e32:	6105                	addi	sp,sp,32
    80001e34:	8082                	ret
    freeproc(p);
    80001e36:	8526                	mv	a0,s1
    80001e38:	00000097          	auipc	ra,0x0
    80001e3c:	ef0080e7          	jalr	-272(ra) # 80001d28 <freeproc>
    release(&p->lock);
    80001e40:	8526                	mv	a0,s1
    80001e42:	fffff097          	auipc	ra,0xfffff
    80001e46:	e34080e7          	jalr	-460(ra) # 80000c76 <release>
    return 0;
    80001e4a:	84ca                	mv	s1,s2
    80001e4c:	bff1                	j	80001e28 <allocproc+0xa0>
    freeproc(p);
    80001e4e:	8526                	mv	a0,s1
    80001e50:	00000097          	auipc	ra,0x0
    80001e54:	ed8080e7          	jalr	-296(ra) # 80001d28 <freeproc>
    release(&p->lock);
    80001e58:	8526                	mv	a0,s1
    80001e5a:	fffff097          	auipc	ra,0xfffff
    80001e5e:	e1c080e7          	jalr	-484(ra) # 80000c76 <release>
    return 0;
    80001e62:	84ca                	mv	s1,s2
    80001e64:	b7d1                	j	80001e28 <allocproc+0xa0>

0000000080001e66 <userinit>:
{
    80001e66:	1101                	addi	sp,sp,-32
    80001e68:	ec06                	sd	ra,24(sp)
    80001e6a:	e822                	sd	s0,16(sp)
    80001e6c:	e426                	sd	s1,8(sp)
    80001e6e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e70:	00000097          	auipc	ra,0x0
    80001e74:	f18080e7          	jalr	-232(ra) # 80001d88 <allocproc>
    80001e78:	84aa                	mv	s1,a0
  initproc = p;
    80001e7a:	00008797          	auipc	a5,0x8
    80001e7e:	1aa7b723          	sd	a0,430(a5) # 8000a028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001e82:	03400613          	li	a2,52
    80001e86:	00008597          	auipc	a1,0x8
    80001e8a:	e0a58593          	addi	a1,a1,-502 # 80009c90 <initcode>
    80001e8e:	6928                	ld	a0,80(a0)
    80001e90:	fffff097          	auipc	ra,0xfffff
    80001e94:	3f6080e7          	jalr	1014(ra) # 80001286 <uvminit>
  p->sz = PGSIZE;
    80001e98:	6785                	lui	a5,0x1
    80001e9a:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001e9c:	6cb8                	ld	a4,88(s1)
    80001e9e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001ea2:	6cb8                	ld	a4,88(s1)
    80001ea4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ea6:	4641                	li	a2,16
    80001ea8:	00007597          	auipc	a1,0x7
    80001eac:	42058593          	addi	a1,a1,1056 # 800092c8 <digits+0x288>
    80001eb0:	15848513          	addi	a0,s1,344
    80001eb4:	fffff097          	auipc	ra,0xfffff
    80001eb8:	f5c080e7          	jalr	-164(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80001ebc:	00007517          	auipc	a0,0x7
    80001ec0:	41c50513          	addi	a0,a0,1052 # 800092d8 <digits+0x298>
    80001ec4:	00003097          	auipc	ra,0x3
    80001ec8:	8a6080e7          	jalr	-1882(ra) # 8000476a <namei>
    80001ecc:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ed0:	478d                	li	a5,3
    80001ed2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ed4:	8526                	mv	a0,s1
    80001ed6:	fffff097          	auipc	ra,0xfffff
    80001eda:	da0080e7          	jalr	-608(ra) # 80000c76 <release>
}
    80001ede:	60e2                	ld	ra,24(sp)
    80001ee0:	6442                	ld	s0,16(sp)
    80001ee2:	64a2                	ld	s1,8(sp)
    80001ee4:	6105                	addi	sp,sp,32
    80001ee6:	8082                	ret

0000000080001ee8 <growproc>:
{
    80001ee8:	1101                	addi	sp,sp,-32
    80001eea:	ec06                	sd	ra,24(sp)
    80001eec:	e822                	sd	s0,16(sp)
    80001eee:	e426                	sd	s1,8(sp)
    80001ef0:	e04a                	sd	s2,0(sp)
    80001ef2:	1000                	addi	s0,sp,32
    80001ef4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001ef6:	00000097          	auipc	ra,0x0
    80001efa:	c80080e7          	jalr	-896(ra) # 80001b76 <myproc>
    80001efe:	892a                	mv	s2,a0
  sz = p->sz;
    80001f00:	652c                	ld	a1,72(a0)
    80001f02:	0005861b          	sext.w	a2,a1
  if (n > 0)
    80001f06:	00904f63          	bgtz	s1,80001f24 <growproc+0x3c>
  else if (n < 0)
    80001f0a:	0204cc63          	bltz	s1,80001f42 <growproc+0x5a>
  p->sz = sz;
    80001f0e:	1602                	slli	a2,a2,0x20
    80001f10:	9201                	srli	a2,a2,0x20
    80001f12:	04c93423          	sd	a2,72(s2)
  return 0;
    80001f16:	4501                	li	a0,0
}
    80001f18:	60e2                	ld	ra,24(sp)
    80001f1a:	6442                	ld	s0,16(sp)
    80001f1c:	64a2                	ld	s1,8(sp)
    80001f1e:	6902                	ld	s2,0(sp)
    80001f20:	6105                	addi	sp,sp,32
    80001f22:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0)
    80001f24:	9e25                	addw	a2,a2,s1
    80001f26:	1602                	slli	a2,a2,0x20
    80001f28:	9201                	srli	a2,a2,0x20
    80001f2a:	1582                	slli	a1,a1,0x20
    80001f2c:	9181                	srli	a1,a1,0x20
    80001f2e:	6928                	ld	a0,80(a0)
    80001f30:	00000097          	auipc	ra,0x0
    80001f34:	88c080e7          	jalr	-1908(ra) # 800017bc <uvmalloc>
    80001f38:	0005061b          	sext.w	a2,a0
    80001f3c:	fa69                	bnez	a2,80001f0e <growproc+0x26>
      return -1;
    80001f3e:	557d                	li	a0,-1
    80001f40:	bfe1                	j	80001f18 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f42:	9e25                	addw	a2,a2,s1
    80001f44:	1602                	slli	a2,a2,0x20
    80001f46:	9201                	srli	a2,a2,0x20
    80001f48:	1582                	slli	a1,a1,0x20
    80001f4a:	9181                	srli	a1,a1,0x20
    80001f4c:	6928                	ld	a0,80(a0)
    80001f4e:	00000097          	auipc	ra,0x0
    80001f52:	826080e7          	jalr	-2010(ra) # 80001774 <uvmdealloc>
    80001f56:	0005061b          	sext.w	a2,a0
    80001f5a:	bf55                	j	80001f0e <growproc+0x26>

0000000080001f5c <scheduler>:
{
    80001f5c:	7139                	addi	sp,sp,-64
    80001f5e:	fc06                	sd	ra,56(sp)
    80001f60:	f822                	sd	s0,48(sp)
    80001f62:	f426                	sd	s1,40(sp)
    80001f64:	f04a                	sd	s2,32(sp)
    80001f66:	ec4e                	sd	s3,24(sp)
    80001f68:	e852                	sd	s4,16(sp)
    80001f6a:	e456                	sd	s5,8(sp)
    80001f6c:	e05a                	sd	s6,0(sp)
    80001f6e:	0080                	addi	s0,sp,64
    80001f70:	8792                	mv	a5,tp
  int id = r_tp();
    80001f72:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f74:	00779a93          	slli	s5,a5,0x7
    80001f78:	00010717          	auipc	a4,0x10
    80001f7c:	32870713          	addi	a4,a4,808 # 800122a0 <pid_lock>
    80001f80:	9756                	add	a4,a4,s5
    80001f82:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f86:	00010717          	auipc	a4,0x10
    80001f8a:	35270713          	addi	a4,a4,850 # 800122d8 <cpus+0x8>
    80001f8e:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    80001f90:	498d                	li	s3,3
        p->state = RUNNING;
    80001f92:	4b11                	li	s6,4
        c->proc = p;
    80001f94:	079e                	slli	a5,a5,0x7
    80001f96:	00010a17          	auipc	s4,0x10
    80001f9a:	30aa0a13          	addi	s4,s4,778 # 800122a0 <pid_lock>
    80001f9e:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80001fa0:	0001f917          	auipc	s2,0x1f
    80001fa4:	93090913          	addi	s2,s2,-1744 # 800208d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fa8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fac:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fb0:	10079073          	csrw	sstatus,a5
    80001fb4:	00010497          	auipc	s1,0x10
    80001fb8:	71c48493          	addi	s1,s1,1820 # 800126d0 <proc>
    80001fbc:	a811                	j	80001fd0 <scheduler+0x74>
      release(&p->lock);
    80001fbe:	8526                	mv	a0,s1
    80001fc0:	fffff097          	auipc	ra,0xfffff
    80001fc4:	cb6080e7          	jalr	-842(ra) # 80000c76 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001fc8:	38848493          	addi	s1,s1,904
    80001fcc:	fd248ee3          	beq	s1,s2,80001fa8 <scheduler+0x4c>
      acquire(&p->lock);
    80001fd0:	8526                	mv	a0,s1
    80001fd2:	fffff097          	auipc	ra,0xfffff
    80001fd6:	bf0080e7          	jalr	-1040(ra) # 80000bc2 <acquire>
      if (p->state == RUNNABLE)
    80001fda:	4c9c                	lw	a5,24(s1)
    80001fdc:	ff3791e3          	bne	a5,s3,80001fbe <scheduler+0x62>
        p->state = RUNNING;
    80001fe0:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fe4:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fe8:	06048593          	addi	a1,s1,96
    80001fec:	8556                	mv	a0,s5
    80001fee:	00001097          	auipc	ra,0x1
    80001ff2:	e66080e7          	jalr	-410(ra) # 80002e54 <swtch>
        c->proc = 0;
    80001ff6:	020a3823          	sd	zero,48(s4)
    80001ffa:	b7d1                	j	80001fbe <scheduler+0x62>

0000000080001ffc <sched>:
{
    80001ffc:	7179                	addi	sp,sp,-48
    80001ffe:	f406                	sd	ra,40(sp)
    80002000:	f022                	sd	s0,32(sp)
    80002002:	ec26                	sd	s1,24(sp)
    80002004:	e84a                	sd	s2,16(sp)
    80002006:	e44e                	sd	s3,8(sp)
    80002008:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000200a:	00000097          	auipc	ra,0x0
    8000200e:	b6c080e7          	jalr	-1172(ra) # 80001b76 <myproc>
    80002012:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002014:	fffff097          	auipc	ra,0xfffff
    80002018:	b34080e7          	jalr	-1228(ra) # 80000b48 <holding>
    8000201c:	c93d                	beqz	a0,80002092 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000201e:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002020:	2781                	sext.w	a5,a5
    80002022:	079e                	slli	a5,a5,0x7
    80002024:	00010717          	auipc	a4,0x10
    80002028:	27c70713          	addi	a4,a4,636 # 800122a0 <pid_lock>
    8000202c:	97ba                	add	a5,a5,a4
    8000202e:	0a87a703          	lw	a4,168(a5) # 10a8 <_entry-0x7fffef58>
    80002032:	4785                	li	a5,1
    80002034:	06f71763          	bne	a4,a5,800020a2 <sched+0xa6>
  if (p->state == RUNNING)
    80002038:	4c98                	lw	a4,24(s1)
    8000203a:	4791                	li	a5,4
    8000203c:	06f70b63          	beq	a4,a5,800020b2 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002040:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002044:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002046:	efb5                	bnez	a5,800020c2 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002048:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000204a:	00010917          	auipc	s2,0x10
    8000204e:	25690913          	addi	s2,s2,598 # 800122a0 <pid_lock>
    80002052:	2781                	sext.w	a5,a5
    80002054:	079e                	slli	a5,a5,0x7
    80002056:	97ca                	add	a5,a5,s2
    80002058:	0ac7a983          	lw	s3,172(a5)
    8000205c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000205e:	2781                	sext.w	a5,a5
    80002060:	079e                	slli	a5,a5,0x7
    80002062:	00010597          	auipc	a1,0x10
    80002066:	27658593          	addi	a1,a1,630 # 800122d8 <cpus+0x8>
    8000206a:	95be                	add	a1,a1,a5
    8000206c:	06048513          	addi	a0,s1,96
    80002070:	00001097          	auipc	ra,0x1
    80002074:	de4080e7          	jalr	-540(ra) # 80002e54 <swtch>
    80002078:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000207a:	2781                	sext.w	a5,a5
    8000207c:	079e                	slli	a5,a5,0x7
    8000207e:	97ca                	add	a5,a5,s2
    80002080:	0b37a623          	sw	s3,172(a5)
}
    80002084:	70a2                	ld	ra,40(sp)
    80002086:	7402                	ld	s0,32(sp)
    80002088:	64e2                	ld	s1,24(sp)
    8000208a:	6942                	ld	s2,16(sp)
    8000208c:	69a2                	ld	s3,8(sp)
    8000208e:	6145                	addi	sp,sp,48
    80002090:	8082                	ret
    panic("sched p->lock");
    80002092:	00007517          	auipc	a0,0x7
    80002096:	24e50513          	addi	a0,a0,590 # 800092e0 <digits+0x2a0>
    8000209a:	ffffe097          	auipc	ra,0xffffe
    8000209e:	490080e7          	jalr	1168(ra) # 8000052a <panic>
    panic("sched locks");
    800020a2:	00007517          	auipc	a0,0x7
    800020a6:	24e50513          	addi	a0,a0,590 # 800092f0 <digits+0x2b0>
    800020aa:	ffffe097          	auipc	ra,0xffffe
    800020ae:	480080e7          	jalr	1152(ra) # 8000052a <panic>
    panic("sched running");
    800020b2:	00007517          	auipc	a0,0x7
    800020b6:	24e50513          	addi	a0,a0,590 # 80009300 <digits+0x2c0>
    800020ba:	ffffe097          	auipc	ra,0xffffe
    800020be:	470080e7          	jalr	1136(ra) # 8000052a <panic>
    panic("sched interruptible");
    800020c2:	00007517          	auipc	a0,0x7
    800020c6:	24e50513          	addi	a0,a0,590 # 80009310 <digits+0x2d0>
    800020ca:	ffffe097          	auipc	ra,0xffffe
    800020ce:	460080e7          	jalr	1120(ra) # 8000052a <panic>

00000000800020d2 <yield>:
{
    800020d2:	1101                	addi	sp,sp,-32
    800020d4:	ec06                	sd	ra,24(sp)
    800020d6:	e822                	sd	s0,16(sp)
    800020d8:	e426                	sd	s1,8(sp)
    800020da:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020dc:	00000097          	auipc	ra,0x0
    800020e0:	a9a080e7          	jalr	-1382(ra) # 80001b76 <myproc>
    800020e4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020e6:	fffff097          	auipc	ra,0xfffff
    800020ea:	adc080e7          	jalr	-1316(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    800020ee:	478d                	li	a5,3
    800020f0:	cc9c                	sw	a5,24(s1)
  sched();
    800020f2:	00000097          	auipc	ra,0x0
    800020f6:	f0a080e7          	jalr	-246(ra) # 80001ffc <sched>
  release(&p->lock);
    800020fa:	8526                	mv	a0,s1
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	b7a080e7          	jalr	-1158(ra) # 80000c76 <release>
}
    80002104:	60e2                	ld	ra,24(sp)
    80002106:	6442                	ld	s0,16(sp)
    80002108:	64a2                	ld	s1,8(sp)
    8000210a:	6105                	addi	sp,sp,32
    8000210c:	8082                	ret

000000008000210e <sleep>:
{
    8000210e:	7179                	addi	sp,sp,-48
    80002110:	f406                	sd	ra,40(sp)
    80002112:	f022                	sd	s0,32(sp)
    80002114:	ec26                	sd	s1,24(sp)
    80002116:	e84a                	sd	s2,16(sp)
    80002118:	e44e                	sd	s3,8(sp)
    8000211a:	1800                	addi	s0,sp,48
    8000211c:	89aa                	mv	s3,a0
    8000211e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002120:	00000097          	auipc	ra,0x0
    80002124:	a56080e7          	jalr	-1450(ra) # 80001b76 <myproc>
    80002128:	84aa                	mv	s1,a0
  acquire(&p->lock); //DOC: sleeplock1
    8000212a:	fffff097          	auipc	ra,0xfffff
    8000212e:	a98080e7          	jalr	-1384(ra) # 80000bc2 <acquire>
  release(lk);
    80002132:	854a                	mv	a0,s2
    80002134:	fffff097          	auipc	ra,0xfffff
    80002138:	b42080e7          	jalr	-1214(ra) # 80000c76 <release>
  p->chan = chan;
    8000213c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002140:	4789                	li	a5,2
    80002142:	cc9c                	sw	a5,24(s1)
  sched();
    80002144:	00000097          	auipc	ra,0x0
    80002148:	eb8080e7          	jalr	-328(ra) # 80001ffc <sched>
  p->chan = 0;
    8000214c:	0204b023          	sd	zero,32(s1)
  release(&p->lock);
    80002150:	8526                	mv	a0,s1
    80002152:	fffff097          	auipc	ra,0xfffff
    80002156:	b24080e7          	jalr	-1244(ra) # 80000c76 <release>
  acquire(lk);
    8000215a:	854a                	mv	a0,s2
    8000215c:	fffff097          	auipc	ra,0xfffff
    80002160:	a66080e7          	jalr	-1434(ra) # 80000bc2 <acquire>
}
    80002164:	70a2                	ld	ra,40(sp)
    80002166:	7402                	ld	s0,32(sp)
    80002168:	64e2                	ld	s1,24(sp)
    8000216a:	6942                	ld	s2,16(sp)
    8000216c:	69a2                	ld	s3,8(sp)
    8000216e:	6145                	addi	sp,sp,48
    80002170:	8082                	ret

0000000080002172 <wait>:
{
    80002172:	715d                	addi	sp,sp,-80
    80002174:	e486                	sd	ra,72(sp)
    80002176:	e0a2                	sd	s0,64(sp)
    80002178:	fc26                	sd	s1,56(sp)
    8000217a:	f84a                	sd	s2,48(sp)
    8000217c:	f44e                	sd	s3,40(sp)
    8000217e:	f052                	sd	s4,32(sp)
    80002180:	ec56                	sd	s5,24(sp)
    80002182:	e85a                	sd	s6,16(sp)
    80002184:	e45e                	sd	s7,8(sp)
    80002186:	e062                	sd	s8,0(sp)
    80002188:	0880                	addi	s0,sp,80
    8000218a:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000218c:	00000097          	auipc	ra,0x0
    80002190:	9ea080e7          	jalr	-1558(ra) # 80001b76 <myproc>
    80002194:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002196:	00010517          	auipc	a0,0x10
    8000219a:	12250513          	addi	a0,a0,290 # 800122b8 <wait_lock>
    8000219e:	fffff097          	auipc	ra,0xfffff
    800021a2:	a24080e7          	jalr	-1500(ra) # 80000bc2 <acquire>
    havekids = 0;
    800021a6:	4b81                	li	s7,0
        if (np->state == ZOMBIE)
    800021a8:	4a15                	li	s4,5
        havekids = 1;
    800021aa:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800021ac:	0001e997          	auipc	s3,0x1e
    800021b0:	72498993          	addi	s3,s3,1828 # 800208d0 <tickslock>
    sleep(p, &wait_lock); //DOC: wait-sleep
    800021b4:	00010c17          	auipc	s8,0x10
    800021b8:	104c0c13          	addi	s8,s8,260 # 800122b8 <wait_lock>
    havekids = 0;
    800021bc:	875e                	mv	a4,s7
    for (np = proc; np < &proc[NPROC]; np++)
    800021be:	00010497          	auipc	s1,0x10
    800021c2:	51248493          	addi	s1,s1,1298 # 800126d0 <proc>
    800021c6:	a0bd                	j	80002234 <wait+0xc2>
          pid = np->pid;
    800021c8:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800021cc:	000b0e63          	beqz	s6,800021e8 <wait+0x76>
    800021d0:	4691                	li	a3,4
    800021d2:	02c48613          	addi	a2,s1,44
    800021d6:	85da                	mv	a1,s6
    800021d8:	05093503          	ld	a0,80(s2)
    800021dc:	fffff097          	auipc	ra,0xfffff
    800021e0:	1b8080e7          	jalr	440(ra) # 80001394 <copyout>
    800021e4:	02054563          	bltz	a0,8000220e <wait+0x9c>
          freeproc(np);
    800021e8:	8526                	mv	a0,s1
    800021ea:	00000097          	auipc	ra,0x0
    800021ee:	b3e080e7          	jalr	-1218(ra) # 80001d28 <freeproc>
          release(&np->lock);
    800021f2:	8526                	mv	a0,s1
    800021f4:	fffff097          	auipc	ra,0xfffff
    800021f8:	a82080e7          	jalr	-1406(ra) # 80000c76 <release>
          release(&wait_lock);
    800021fc:	00010517          	auipc	a0,0x10
    80002200:	0bc50513          	addi	a0,a0,188 # 800122b8 <wait_lock>
    80002204:	fffff097          	auipc	ra,0xfffff
    80002208:	a72080e7          	jalr	-1422(ra) # 80000c76 <release>
          return pid;
    8000220c:	a09d                	j	80002272 <wait+0x100>
            release(&np->lock);
    8000220e:	8526                	mv	a0,s1
    80002210:	fffff097          	auipc	ra,0xfffff
    80002214:	a66080e7          	jalr	-1434(ra) # 80000c76 <release>
            release(&wait_lock);
    80002218:	00010517          	auipc	a0,0x10
    8000221c:	0a050513          	addi	a0,a0,160 # 800122b8 <wait_lock>
    80002220:	fffff097          	auipc	ra,0xfffff
    80002224:	a56080e7          	jalr	-1450(ra) # 80000c76 <release>
            return -1;
    80002228:	59fd                	li	s3,-1
    8000222a:	a0a1                	j	80002272 <wait+0x100>
    for (np = proc; np < &proc[NPROC]; np++)
    8000222c:	38848493          	addi	s1,s1,904
    80002230:	03348463          	beq	s1,s3,80002258 <wait+0xe6>
      if (np->parent == p)
    80002234:	7c9c                	ld	a5,56(s1)
    80002236:	ff279be3          	bne	a5,s2,8000222c <wait+0xba>
        acquire(&np->lock);
    8000223a:	8526                	mv	a0,s1
    8000223c:	fffff097          	auipc	ra,0xfffff
    80002240:	986080e7          	jalr	-1658(ra) # 80000bc2 <acquire>
        if (np->state == ZOMBIE)
    80002244:	4c9c                	lw	a5,24(s1)
    80002246:	f94781e3          	beq	a5,s4,800021c8 <wait+0x56>
        release(&np->lock);
    8000224a:	8526                	mv	a0,s1
    8000224c:	fffff097          	auipc	ra,0xfffff
    80002250:	a2a080e7          	jalr	-1494(ra) # 80000c76 <release>
        havekids = 1;
    80002254:	8756                	mv	a4,s5
    80002256:	bfd9                	j	8000222c <wait+0xba>
    if (!havekids || p->killed)
    80002258:	c701                	beqz	a4,80002260 <wait+0xee>
    8000225a:	02892783          	lw	a5,40(s2)
    8000225e:	c79d                	beqz	a5,8000228c <wait+0x11a>
      release(&wait_lock);
    80002260:	00010517          	auipc	a0,0x10
    80002264:	05850513          	addi	a0,a0,88 # 800122b8 <wait_lock>
    80002268:	fffff097          	auipc	ra,0xfffff
    8000226c:	a0e080e7          	jalr	-1522(ra) # 80000c76 <release>
      return -1;
    80002270:	59fd                	li	s3,-1
}
    80002272:	854e                	mv	a0,s3
    80002274:	60a6                	ld	ra,72(sp)
    80002276:	6406                	ld	s0,64(sp)
    80002278:	74e2                	ld	s1,56(sp)
    8000227a:	7942                	ld	s2,48(sp)
    8000227c:	79a2                	ld	s3,40(sp)
    8000227e:	7a02                	ld	s4,32(sp)
    80002280:	6ae2                	ld	s5,24(sp)
    80002282:	6b42                	ld	s6,16(sp)
    80002284:	6ba2                	ld	s7,8(sp)
    80002286:	6c02                	ld	s8,0(sp)
    80002288:	6161                	addi	sp,sp,80
    8000228a:	8082                	ret
    sleep(p, &wait_lock); //DOC: wait-sleep
    8000228c:	85e2                	mv	a1,s8
    8000228e:	854a                	mv	a0,s2
    80002290:	00000097          	auipc	ra,0x0
    80002294:	e7e080e7          	jalr	-386(ra) # 8000210e <sleep>
    havekids = 0;
    80002298:	b715                	j	800021bc <wait+0x4a>

000000008000229a <wakeup>:
{
    8000229a:	7139                	addi	sp,sp,-64
    8000229c:	fc06                	sd	ra,56(sp)
    8000229e:	f822                	sd	s0,48(sp)
    800022a0:	f426                	sd	s1,40(sp)
    800022a2:	f04a                	sd	s2,32(sp)
    800022a4:	ec4e                	sd	s3,24(sp)
    800022a6:	e852                	sd	s4,16(sp)
    800022a8:	e456                	sd	s5,8(sp)
    800022aa:	0080                	addi	s0,sp,64
    800022ac:	8a2a                	mv	s4,a0
  for (p = proc; p < &proc[NPROC]; p++)
    800022ae:	00010497          	auipc	s1,0x10
    800022b2:	42248493          	addi	s1,s1,1058 # 800126d0 <proc>
      if (p->state == SLEEPING && p->chan == chan)
    800022b6:	4989                	li	s3,2
        p->state = RUNNABLE;
    800022b8:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800022ba:	0001e917          	auipc	s2,0x1e
    800022be:	61690913          	addi	s2,s2,1558 # 800208d0 <tickslock>
    800022c2:	a811                	j	800022d6 <wakeup+0x3c>
      release(&p->lock);
    800022c4:	8526                	mv	a0,s1
    800022c6:	fffff097          	auipc	ra,0xfffff
    800022ca:	9b0080e7          	jalr	-1616(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800022ce:	38848493          	addi	s1,s1,904
    800022d2:	03248663          	beq	s1,s2,800022fe <wakeup+0x64>
    if (p != myproc())
    800022d6:	00000097          	auipc	ra,0x0
    800022da:	8a0080e7          	jalr	-1888(ra) # 80001b76 <myproc>
    800022de:	fea488e3          	beq	s1,a0,800022ce <wakeup+0x34>
      acquire(&p->lock);
    800022e2:	8526                	mv	a0,s1
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	8de080e7          	jalr	-1826(ra) # 80000bc2 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800022ec:	4c9c                	lw	a5,24(s1)
    800022ee:	fd379be3          	bne	a5,s3,800022c4 <wakeup+0x2a>
    800022f2:	709c                	ld	a5,32(s1)
    800022f4:	fd4798e3          	bne	a5,s4,800022c4 <wakeup+0x2a>
        p->state = RUNNABLE;
    800022f8:	0154ac23          	sw	s5,24(s1)
    800022fc:	b7e1                	j	800022c4 <wakeup+0x2a>
}
    800022fe:	70e2                	ld	ra,56(sp)
    80002300:	7442                	ld	s0,48(sp)
    80002302:	74a2                	ld	s1,40(sp)
    80002304:	7902                	ld	s2,32(sp)
    80002306:	69e2                	ld	s3,24(sp)
    80002308:	6a42                	ld	s4,16(sp)
    8000230a:	6aa2                	ld	s5,8(sp)
    8000230c:	6121                	addi	sp,sp,64
    8000230e:	8082                	ret

0000000080002310 <reparent>:
{
    80002310:	7179                	addi	sp,sp,-48
    80002312:	f406                	sd	ra,40(sp)
    80002314:	f022                	sd	s0,32(sp)
    80002316:	ec26                	sd	s1,24(sp)
    80002318:	e84a                	sd	s2,16(sp)
    8000231a:	e44e                	sd	s3,8(sp)
    8000231c:	e052                	sd	s4,0(sp)
    8000231e:	1800                	addi	s0,sp,48
    80002320:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002322:	00010497          	auipc	s1,0x10
    80002326:	3ae48493          	addi	s1,s1,942 # 800126d0 <proc>
      pp->parent = initproc;
    8000232a:	00008a17          	auipc	s4,0x8
    8000232e:	cfea0a13          	addi	s4,s4,-770 # 8000a028 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002332:	0001e997          	auipc	s3,0x1e
    80002336:	59e98993          	addi	s3,s3,1438 # 800208d0 <tickslock>
    8000233a:	a029                	j	80002344 <reparent+0x34>
    8000233c:	38848493          	addi	s1,s1,904
    80002340:	01348d63          	beq	s1,s3,8000235a <reparent+0x4a>
    if (pp->parent == p)
    80002344:	7c9c                	ld	a5,56(s1)
    80002346:	ff279be3          	bne	a5,s2,8000233c <reparent+0x2c>
      pp->parent = initproc;
    8000234a:	000a3503          	ld	a0,0(s4)
    8000234e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002350:	00000097          	auipc	ra,0x0
    80002354:	f4a080e7          	jalr	-182(ra) # 8000229a <wakeup>
    80002358:	b7d5                	j	8000233c <reparent+0x2c>
}
    8000235a:	70a2                	ld	ra,40(sp)
    8000235c:	7402                	ld	s0,32(sp)
    8000235e:	64e2                	ld	s1,24(sp)
    80002360:	6942                	ld	s2,16(sp)
    80002362:	69a2                	ld	s3,8(sp)
    80002364:	6a02                	ld	s4,0(sp)
    80002366:	6145                	addi	sp,sp,48
    80002368:	8082                	ret

000000008000236a <exit>:
{
    8000236a:	7179                	addi	sp,sp,-48
    8000236c:	f406                	sd	ra,40(sp)
    8000236e:	f022                	sd	s0,32(sp)
    80002370:	ec26                	sd	s1,24(sp)
    80002372:	e84a                	sd	s2,16(sp)
    80002374:	e44e                	sd	s3,8(sp)
    80002376:	e052                	sd	s4,0(sp)
    80002378:	1800                	addi	s0,sp,48
    8000237a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	7fa080e7          	jalr	2042(ra) # 80001b76 <myproc>
    80002384:	89aa                	mv	s3,a0
  if (p == initproc)
    80002386:	00008797          	auipc	a5,0x8
    8000238a:	ca27b783          	ld	a5,-862(a5) # 8000a028 <initproc>
    8000238e:	0d050493          	addi	s1,a0,208
    80002392:	15050913          	addi	s2,a0,336
    80002396:	02a79363          	bne	a5,a0,800023bc <exit+0x52>
    panic("init exiting");
    8000239a:	00007517          	auipc	a0,0x7
    8000239e:	f8e50513          	addi	a0,a0,-114 # 80009328 <digits+0x2e8>
    800023a2:	ffffe097          	auipc	ra,0xffffe
    800023a6:	188080e7          	jalr	392(ra) # 8000052a <panic>
      fileclose(f);
    800023aa:	00003097          	auipc	ra,0x3
    800023ae:	dbe080e7          	jalr	-578(ra) # 80005168 <fileclose>
      p->ofile[fd] = 0;
    800023b2:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800023b6:	04a1                	addi	s1,s1,8
    800023b8:	01248563          	beq	s1,s2,800023c2 <exit+0x58>
    if (p->ofile[fd])
    800023bc:	6088                	ld	a0,0(s1)
    800023be:	f575                	bnez	a0,800023aa <exit+0x40>
    800023c0:	bfdd                	j	800023b6 <exit+0x4c>
  begin_op();
    800023c2:	00003097          	auipc	ra,0x3
    800023c6:	8da080e7          	jalr	-1830(ra) # 80004c9c <begin_op>
  iput(p->cwd);
    800023ca:	1509b503          	ld	a0,336(s3)
    800023ce:	00002097          	auipc	ra,0x2
    800023d2:	da0080e7          	jalr	-608(ra) # 8000416e <iput>
  end_op();
    800023d6:	00003097          	auipc	ra,0x3
    800023da:	946080e7          	jalr	-1722(ra) # 80004d1c <end_op>
  p->cwd = 0;
    800023de:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800023e2:	00010497          	auipc	s1,0x10
    800023e6:	ed648493          	addi	s1,s1,-298 # 800122b8 <wait_lock>
    800023ea:	8526                	mv	a0,s1
    800023ec:	ffffe097          	auipc	ra,0xffffe
    800023f0:	7d6080e7          	jalr	2006(ra) # 80000bc2 <acquire>
  reparent(p);
    800023f4:	854e                	mv	a0,s3
    800023f6:	00000097          	auipc	ra,0x0
    800023fa:	f1a080e7          	jalr	-230(ra) # 80002310 <reparent>
  wakeup(p->parent);
    800023fe:	0389b503          	ld	a0,56(s3)
    80002402:	00000097          	auipc	ra,0x0
    80002406:	e98080e7          	jalr	-360(ra) # 8000229a <wakeup>
  acquire(&p->lock);
    8000240a:	854e                	mv	a0,s3
    8000240c:	ffffe097          	auipc	ra,0xffffe
    80002410:	7b6080e7          	jalr	1974(ra) # 80000bc2 <acquire>
  p->xstate = status;
    80002414:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002418:	4795                	li	a5,5
    8000241a:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000241e:	8526                	mv	a0,s1
    80002420:	fffff097          	auipc	ra,0xfffff
    80002424:	856080e7          	jalr	-1962(ra) # 80000c76 <release>
  sched();
    80002428:	00000097          	auipc	ra,0x0
    8000242c:	bd4080e7          	jalr	-1068(ra) # 80001ffc <sched>
  panic("zombie exit");
    80002430:	00007517          	auipc	a0,0x7
    80002434:	f0850513          	addi	a0,a0,-248 # 80009338 <digits+0x2f8>
    80002438:	ffffe097          	auipc	ra,0xffffe
    8000243c:	0f2080e7          	jalr	242(ra) # 8000052a <panic>

0000000080002440 <kill>:
{
    80002440:	7179                	addi	sp,sp,-48
    80002442:	f406                	sd	ra,40(sp)
    80002444:	f022                	sd	s0,32(sp)
    80002446:	ec26                	sd	s1,24(sp)
    80002448:	e84a                	sd	s2,16(sp)
    8000244a:	e44e                	sd	s3,8(sp)
    8000244c:	1800                	addi	s0,sp,48
    8000244e:	892a                	mv	s2,a0
  for (p = proc; p < &proc[NPROC]; p++)
    80002450:	00010497          	auipc	s1,0x10
    80002454:	28048493          	addi	s1,s1,640 # 800126d0 <proc>
    80002458:	0001e997          	auipc	s3,0x1e
    8000245c:	47898993          	addi	s3,s3,1144 # 800208d0 <tickslock>
    acquire(&p->lock);
    80002460:	8526                	mv	a0,s1
    80002462:	ffffe097          	auipc	ra,0xffffe
    80002466:	760080e7          	jalr	1888(ra) # 80000bc2 <acquire>
    if (p->pid == pid)
    8000246a:	589c                	lw	a5,48(s1)
    8000246c:	01278d63          	beq	a5,s2,80002486 <kill+0x46>
    release(&p->lock);
    80002470:	8526                	mv	a0,s1
    80002472:	fffff097          	auipc	ra,0xfffff
    80002476:	804080e7          	jalr	-2044(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000247a:	38848493          	addi	s1,s1,904
    8000247e:	ff3491e3          	bne	s1,s3,80002460 <kill+0x20>
  return -1;
    80002482:	557d                	li	a0,-1
    80002484:	a829                	j	8000249e <kill+0x5e>
      p->killed = 1;
    80002486:	4785                	li	a5,1
    80002488:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    8000248a:	4c98                	lw	a4,24(s1)
    8000248c:	4789                	li	a5,2
    8000248e:	00f70f63          	beq	a4,a5,800024ac <kill+0x6c>
      release(&p->lock);
    80002492:	8526                	mv	a0,s1
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	7e2080e7          	jalr	2018(ra) # 80000c76 <release>
      return 0;
    8000249c:	4501                	li	a0,0
}
    8000249e:	70a2                	ld	ra,40(sp)
    800024a0:	7402                	ld	s0,32(sp)
    800024a2:	64e2                	ld	s1,24(sp)
    800024a4:	6942                	ld	s2,16(sp)
    800024a6:	69a2                	ld	s3,8(sp)
    800024a8:	6145                	addi	sp,sp,48
    800024aa:	8082                	ret
        p->state = RUNNABLE;
    800024ac:	478d                	li	a5,3
    800024ae:	cc9c                	sw	a5,24(s1)
    800024b0:	b7cd                	j	80002492 <kill+0x52>

00000000800024b2 <either_copyout>:
{
    800024b2:	7179                	addi	sp,sp,-48
    800024b4:	f406                	sd	ra,40(sp)
    800024b6:	f022                	sd	s0,32(sp)
    800024b8:	ec26                	sd	s1,24(sp)
    800024ba:	e84a                	sd	s2,16(sp)
    800024bc:	e44e                	sd	s3,8(sp)
    800024be:	e052                	sd	s4,0(sp)
    800024c0:	1800                	addi	s0,sp,48
    800024c2:	84aa                	mv	s1,a0
    800024c4:	892e                	mv	s2,a1
    800024c6:	89b2                	mv	s3,a2
    800024c8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024ca:	fffff097          	auipc	ra,0xfffff
    800024ce:	6ac080e7          	jalr	1708(ra) # 80001b76 <myproc>
  if (user_dst)
    800024d2:	c08d                	beqz	s1,800024f4 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024d4:	86d2                	mv	a3,s4
    800024d6:	864e                	mv	a2,s3
    800024d8:	85ca                	mv	a1,s2
    800024da:	6928                	ld	a0,80(a0)
    800024dc:	fffff097          	auipc	ra,0xfffff
    800024e0:	eb8080e7          	jalr	-328(ra) # 80001394 <copyout>
}
    800024e4:	70a2                	ld	ra,40(sp)
    800024e6:	7402                	ld	s0,32(sp)
    800024e8:	64e2                	ld	s1,24(sp)
    800024ea:	6942                	ld	s2,16(sp)
    800024ec:	69a2                	ld	s3,8(sp)
    800024ee:	6a02                	ld	s4,0(sp)
    800024f0:	6145                	addi	sp,sp,48
    800024f2:	8082                	ret
    memmove((char *)dst, src, len);
    800024f4:	000a061b          	sext.w	a2,s4
    800024f8:	85ce                	mv	a1,s3
    800024fa:	854a                	mv	a0,s2
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	81e080e7          	jalr	-2018(ra) # 80000d1a <memmove>
    return 0;
    80002504:	8526                	mv	a0,s1
    80002506:	bff9                	j	800024e4 <either_copyout+0x32>

0000000080002508 <either_copyin>:
{
    80002508:	7179                	addi	sp,sp,-48
    8000250a:	f406                	sd	ra,40(sp)
    8000250c:	f022                	sd	s0,32(sp)
    8000250e:	ec26                	sd	s1,24(sp)
    80002510:	e84a                	sd	s2,16(sp)
    80002512:	e44e                	sd	s3,8(sp)
    80002514:	e052                	sd	s4,0(sp)
    80002516:	1800                	addi	s0,sp,48
    80002518:	892a                	mv	s2,a0
    8000251a:	84ae                	mv	s1,a1
    8000251c:	89b2                	mv	s3,a2
    8000251e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002520:	fffff097          	auipc	ra,0xfffff
    80002524:	656080e7          	jalr	1622(ra) # 80001b76 <myproc>
  if (user_src)
    80002528:	c08d                	beqz	s1,8000254a <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000252a:	86d2                	mv	a3,s4
    8000252c:	864e                	mv	a2,s3
    8000252e:	85ca                	mv	a1,s2
    80002530:	6928                	ld	a0,80(a0)
    80002532:	fffff097          	auipc	ra,0xfffff
    80002536:	ef0080e7          	jalr	-272(ra) # 80001422 <copyin>
}
    8000253a:	70a2                	ld	ra,40(sp)
    8000253c:	7402                	ld	s0,32(sp)
    8000253e:	64e2                	ld	s1,24(sp)
    80002540:	6942                	ld	s2,16(sp)
    80002542:	69a2                	ld	s3,8(sp)
    80002544:	6a02                	ld	s4,0(sp)
    80002546:	6145                	addi	sp,sp,48
    80002548:	8082                	ret
    memmove(dst, (char *)src, len);
    8000254a:	000a061b          	sext.w	a2,s4
    8000254e:	85ce                	mv	a1,s3
    80002550:	854a                	mv	a0,s2
    80002552:	ffffe097          	auipc	ra,0xffffe
    80002556:	7c8080e7          	jalr	1992(ra) # 80000d1a <memmove>
    return 0;
    8000255a:	8526                	mv	a0,s1
    8000255c:	bff9                	j	8000253a <either_copyin+0x32>

000000008000255e <procdump>:
{
    8000255e:	715d                	addi	sp,sp,-80
    80002560:	e486                	sd	ra,72(sp)
    80002562:	e0a2                	sd	s0,64(sp)
    80002564:	fc26                	sd	s1,56(sp)
    80002566:	f84a                	sd	s2,48(sp)
    80002568:	f44e                	sd	s3,40(sp)
    8000256a:	f052                	sd	s4,32(sp)
    8000256c:	ec56                	sd	s5,24(sp)
    8000256e:	e85a                	sd	s6,16(sp)
    80002570:	e45e                	sd	s7,8(sp)
    80002572:	0880                	addi	s0,sp,80
  printf("\n");
    80002574:	00007517          	auipc	a0,0x7
    80002578:	b5450513          	addi	a0,a0,-1196 # 800090c8 <digits+0x88>
    8000257c:	ffffe097          	auipc	ra,0xffffe
    80002580:	ff8080e7          	jalr	-8(ra) # 80000574 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002584:	00010497          	auipc	s1,0x10
    80002588:	2a448493          	addi	s1,s1,676 # 80012828 <proc+0x158>
    8000258c:	0001e917          	auipc	s2,0x1e
    80002590:	49c90913          	addi	s2,s2,1180 # 80020a28 <bcache+0x140>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002594:	4b15                	li	s6,5
      state = "???";
    80002596:	00007997          	auipc	s3,0x7
    8000259a:	db298993          	addi	s3,s3,-590 # 80009348 <digits+0x308>
    printf("%d %s %s", p->pid, state, p->name);
    8000259e:	00007a97          	auipc	s5,0x7
    800025a2:	db2a8a93          	addi	s5,s5,-590 # 80009350 <digits+0x310>
    printf("\n");
    800025a6:	00007a17          	auipc	s4,0x7
    800025aa:	b22a0a13          	addi	s4,s4,-1246 # 800090c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025ae:	00007b97          	auipc	s7,0x7
    800025b2:	072b8b93          	addi	s7,s7,114 # 80009620 <states.0>
    800025b6:	a00d                	j	800025d8 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025b8:	ed86a583          	lw	a1,-296(a3)
    800025bc:	8556                	mv	a0,s5
    800025be:	ffffe097          	auipc	ra,0xffffe
    800025c2:	fb6080e7          	jalr	-74(ra) # 80000574 <printf>
    printf("\n");
    800025c6:	8552                	mv	a0,s4
    800025c8:	ffffe097          	auipc	ra,0xffffe
    800025cc:	fac080e7          	jalr	-84(ra) # 80000574 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800025d0:	38848493          	addi	s1,s1,904
    800025d4:	03248263          	beq	s1,s2,800025f8 <procdump+0x9a>
    if (p->state == UNUSED)
    800025d8:	86a6                	mv	a3,s1
    800025da:	ec04a783          	lw	a5,-320(s1)
    800025de:	dbed                	beqz	a5,800025d0 <procdump+0x72>
      state = "???";
    800025e0:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025e2:	fcfb6be3          	bltu	s6,a5,800025b8 <procdump+0x5a>
    800025e6:	02079713          	slli	a4,a5,0x20
    800025ea:	01d75793          	srli	a5,a4,0x1d
    800025ee:	97de                	add	a5,a5,s7
    800025f0:	6390                	ld	a2,0(a5)
    800025f2:	f279                	bnez	a2,800025b8 <procdump+0x5a>
      state = "???";
    800025f4:	864e                	mv	a2,s3
    800025f6:	b7c9                	j	800025b8 <procdump+0x5a>
}
    800025f8:	60a6                	ld	ra,72(sp)
    800025fa:	6406                	ld	s0,64(sp)
    800025fc:	74e2                	ld	s1,56(sp)
    800025fe:	7942                	ld	s2,48(sp)
    80002600:	79a2                	ld	s3,40(sp)
    80002602:	7a02                	ld	s4,32(sp)
    80002604:	6ae2                	ld	s5,24(sp)
    80002606:	6b42                	ld	s6,16(sp)
    80002608:	6ba2                	ld	s7,8(sp)
    8000260a:	6161                	addi	sp,sp,80
    8000260c:	8082                	ret

000000008000260e <next_free_space>:
{
    8000260e:	1141                	addi	sp,sp,-16
    80002610:	e422                	sd	s0,8(sp)
    80002612:	0800                	addi	s0,sp,16
    if (!(free_spaces & (1 << i)))
    80002614:	0005071b          	sext.w	a4,a0
    80002618:	8905                	andi	a0,a0,1
    8000261a:	cd11                	beqz	a0,80002636 <next_free_space+0x28>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000261c:	4505                	li	a0,1
    8000261e:	46c1                	li	a3,16
    if (!(free_spaces & (1 << i)))
    80002620:	40a757bb          	sraw	a5,a4,a0
    80002624:	8b85                	andi	a5,a5,1
    80002626:	c789                	beqz	a5,80002630 <next_free_space+0x22>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002628:	2505                	addiw	a0,a0,1
    8000262a:	fed51be3          	bne	a0,a3,80002620 <next_free_space+0x12>
  return -1;
    8000262e:	557d                	li	a0,-1
}
    80002630:	6422                	ld	s0,8(sp)
    80002632:	0141                	addi	sp,sp,16
    80002634:	8082                	ret
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002636:	4501                	li	a0,0
    80002638:	bfe5                	j	80002630 <next_free_space+0x22>

000000008000263a <get_index_in_page_info_array>:
{
    8000263a:	1141                	addi	sp,sp,-16
    8000263c:	e422                	sd	s0,8(sp)
    8000263e:	0800                	addi	s0,sp,16
  uint64 rva = PGROUNDDOWN(va);
    80002640:	777d                	lui	a4,0xfffff
    80002642:	8f69                	and	a4,a4,a0
  for (int i = 0; i < MAX_TOTAL_PAGES; i++)
    80002644:	4501                	li	a0,0
    80002646:	02000693          	li	a3,32
    if (po->va == rva)
    8000264a:	619c                	ld	a5,0(a1)
    8000264c:	00e78763          	beq	a5,a4,8000265a <get_index_in_page_info_array+0x20>
  for (int i = 0; i < MAX_TOTAL_PAGES; i++)
    80002650:	2505                	addiw	a0,a0,1
    80002652:	05c1                	addi	a1,a1,16
    80002654:	fed51be3          	bne	a0,a3,8000264a <get_index_in_page_info_array+0x10>
  return -1; // if not found return null
    80002658:	557d                	li	a0,-1
}
    8000265a:	6422                	ld	s0,8(sp)
    8000265c:	0141                	addi	sp,sp,16
    8000265e:	8082                	ret

0000000080002660 <page_out>:
{
    80002660:	7179                	addi	sp,sp,-48
    80002662:	f406                	sd	ra,40(sp)
    80002664:	f022                	sd	s0,32(sp)
    80002666:	ec26                	sd	s1,24(sp)
    80002668:	e84a                	sd	s2,16(sp)
    8000266a:	e44e                	sd	s3,8(sp)
    8000266c:	e052                	sd	s4,0(sp)
    8000266e:	1800                	addi	s0,sp,48
    80002670:	89aa                	mv	s3,a0
  struct proc *p = myproc();
    80002672:	fffff097          	auipc	ra,0xfffff
    80002676:	504080e7          	jalr	1284(ra) # 80001b76 <myproc>
    8000267a:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000267c:	ffffe097          	auipc	ra,0xffffe
    80002680:	4cc080e7          	jalr	1228(ra) # 80000b48 <holding>
    80002684:	cd55                	beqz	a0,80002740 <page_out+0xe0>
  uint64 pa = walkaddr(p->pagetable, rva, 1); // return with pte valid = 0
    80002686:	4605                	li	a2,1
    80002688:	75fd                	lui	a1,0xfffff
    8000268a:	00b9f5b3          	and	a1,s3,a1
    8000268e:	68a8                	ld	a0,80(s1)
    80002690:	fffff097          	auipc	ra,0xfffff
    80002694:	9bc080e7          	jalr	-1604(ra) # 8000104c <walkaddr>
    80002698:	8a2a                	mv	s4,a0
  int free_index = next_free_space(p->pages_swap_info.free_spaces);
    8000269a:	1784d503          	lhu	a0,376(s1)
    8000269e:	00000097          	auipc	ra,0x0
    800026a2:	f70080e7          	jalr	-144(ra) # 8000260e <next_free_space>
    800026a6:	892a                	mv	s2,a0
  if (free_index < 0)
    800026a8:	0a054463          	bltz	a0,80002750 <page_out+0xf0>
  p->pages_swap_info.pages[free_index].va = va; // Save location of page in swapfile
    800026ac:	01750793          	addi	a5,a0,23
    800026b0:	0792                	slli	a5,a5,0x4
    800026b2:	97a6                	add	a5,a5,s1
    800026b4:	0137b823          	sd	s3,16(a5)
  int start_offset = free_index * PGSIZE;
    800026b8:	00c5161b          	slliw	a2,a0,0xc
  if (free_index < 0 || free_index >= MAX_PSYC_PAGES)
    800026bc:	0005079b          	sext.w	a5,a0
    800026c0:	473d                	li	a4,15
    800026c2:	08f76f63          	bltu	a4,a5,80002760 <page_out+0x100>
  writeToSwapFile(p, (char *)pa, start_offset, PGSIZE); // Write page to swap file
    800026c6:	6685                	lui	a3,0x1
    800026c8:	2601                	sext.w	a2,a2
    800026ca:	85d2                	mv	a1,s4
    800026cc:	8526                	mv	a0,s1
    800026ce:	00002097          	auipc	ra,0x2
    800026d2:	3a0080e7          	jalr	928(ra) # 80004a6e <writeToSwapFile>
  int old_index = get_index_in_page_info_array(va, p->pages_physc_info.pages);
    800026d6:	28848593          	addi	a1,s1,648
    800026da:	854e                	mv	a0,s3
    800026dc:	00000097          	auipc	ra,0x0
    800026e0:	f5e080e7          	jalr	-162(ra) # 8000263a <get_index_in_page_info_array>
  if (old_index < 0)
    800026e4:	08054663          	bltz	a0,80002770 <page_out+0x110>
  if (!(p->pages_physc_info.free_spaces & (1 << old_index)))
    800026e8:	2804d783          	lhu	a5,640(s1)
    800026ec:	40a7d73b          	sraw	a4,a5,a0
    800026f0:	8b05                	andi	a4,a4,1
    800026f2:	c759                	beqz	a4,80002780 <page_out+0x120>
  p->pages_physc_info.free_spaces ^= (1 << old_index); // set old space in physc arr as free
    800026f4:	4705                	li	a4,1
    800026f6:	00a7153b          	sllw	a0,a4,a0
    800026fa:	8fa9                	xor	a5,a5,a0
    800026fc:	28f49023          	sh	a5,640(s1)
  if (p->pages_swap_info.free_spaces & (1 << free_index))
    80002700:	1784d783          	lhu	a5,376(s1)
    80002704:	4127d73b          	sraw	a4,a5,s2
    80002708:	8b05                	andi	a4,a4,1
    8000270a:	e359                	bnez	a4,80002790 <page_out+0x130>
  p->pages_swap_info.free_spaces |= (1 << free_index); // mark new space in swap arr as occupied
    8000270c:	4505                	li	a0,1
    8000270e:	0125193b          	sllw	s2,a0,s2
    80002712:	0127e7b3          	or	a5,a5,s2
    80002716:	16f49c23          	sh	a5,376(s1)
  p->physical_pages_num--;
    8000271a:	1704a783          	lw	a5,368(s1)
    8000271e:	37fd                	addiw	a5,a5,-1
    80002720:	16f4a823          	sw	a5,368(s1)
  kfree((void *)pa);
    80002724:	8552                	mv	a0,s4
    80002726:	ffffe097          	auipc	ra,0xffffe
    8000272a:	2b0080e7          	jalr	688(ra) # 800009d6 <kfree>
}
    8000272e:	8552                	mv	a0,s4
    80002730:	70a2                	ld	ra,40(sp)
    80002732:	7402                	ld	s0,32(sp)
    80002734:	64e2                	ld	s1,24(sp)
    80002736:	6942                	ld	s2,16(sp)
    80002738:	69a2                	ld	s3,8(sp)
    8000273a:	6a02                	ld	s4,0(sp)
    8000273c:	6145                	addi	sp,sp,48
    8000273e:	8082                	ret
    panic("fadge we are not holding the lock in page_out");
    80002740:	00007517          	auipc	a0,0x7
    80002744:	c2050513          	addi	a0,a0,-992 # 80009360 <digits+0x320>
    80002748:	ffffe097          	auipc	ra,0xffffe
    8000274c:	de2080e7          	jalr	-542(ra) # 8000052a <panic>
    panic("page out: free index in swap file not found");
    80002750:	00007517          	auipc	a0,0x7
    80002754:	c4050513          	addi	a0,a0,-960 # 80009390 <digits+0x350>
    80002758:	ffffe097          	auipc	ra,0xffffe
    8000275c:	dd2080e7          	jalr	-558(ra) # 8000052a <panic>
    panic("fadge no free index in page_out");
    80002760:	00007517          	auipc	a0,0x7
    80002764:	c6050513          	addi	a0,a0,-928 # 800093c0 <digits+0x380>
    80002768:	ffffe097          	auipc	ra,0xffffe
    8000276c:	dc2080e7          	jalr	-574(ra) # 8000052a <panic>
    panic("page out: physc page not found");
    80002770:	00007517          	auipc	a0,0x7
    80002774:	c7050513          	addi	a0,a0,-912 # 800093e0 <digits+0x3a0>
    80002778:	ffffe097          	auipc	ra,0xffffe
    8000277c:	db2080e7          	jalr	-590(ra) # 8000052a <panic>
    panic("page_in: tried to reset free space flag when it is not set");
    80002780:	00007517          	auipc	a0,0x7
    80002784:	c8050513          	addi	a0,a0,-896 # 80009400 <digits+0x3c0>
    80002788:	ffffe097          	auipc	ra,0xffffe
    8000278c:	da2080e7          	jalr	-606(ra) # 8000052a <panic>
    panic("page_in: tried to set free space flag when it is already set");
    80002790:	00007517          	auipc	a0,0x7
    80002794:	9c050513          	addi	a0,a0,-1600 # 80009150 <digits+0x110>
    80002798:	ffffe097          	auipc	ra,0xffffe
    8000279c:	d92080e7          	jalr	-622(ra) # 8000052a <panic>

00000000800027a0 <page_in>:
{
    800027a0:	7139                	addi	sp,sp,-64
    800027a2:	fc06                	sd	ra,56(sp)
    800027a4:	f822                	sd	s0,48(sp)
    800027a6:	f426                	sd	s1,40(sp)
    800027a8:	f04a                	sd	s2,32(sp)
    800027aa:	ec4e                	sd	s3,24(sp)
    800027ac:	e852                	sd	s4,16(sp)
    800027ae:	e456                	sd	s5,8(sp)
    800027b0:	e05a                	sd	s6,0(sp)
    800027b2:	0080                	addi	s0,sp,64
    800027b4:	8b2a                	mv	s6,a0
    800027b6:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800027b8:	fffff097          	auipc	ra,0xfffff
    800027bc:	3be080e7          	jalr	958(ra) # 80001b76 <myproc>
    800027c0:	892a                	mv	s2,a0
  int page_index_swapfile = get_index_in_page_info_array(va, p->pages_swap_info.pages);
    800027c2:	18050593          	addi	a1,a0,384
    800027c6:	855a                	mv	a0,s6
    800027c8:	00000097          	auipc	ra,0x0
    800027cc:	e72080e7          	jalr	-398(ra) # 8000263a <get_index_in_page_info_array>
    800027d0:	84aa                	mv	s1,a0
  int page_index_phsical = next_free_space(p->pages_physc_info.free_spaces);
    800027d2:	28095a03          	lhu	s4,640(s2)
    800027d6:	8552                	mv	a0,s4
    800027d8:	00000097          	auipc	ra,0x0
    800027dc:	e36080e7          	jalr	-458(ra) # 8000260e <next_free_space>
  if (page_index_swapfile < 0 || page_index_swapfile >= MAX_PSYC_PAGES)
    800027e0:	0004869b          	sext.w	a3,s1
    800027e4:	473d                	li	a4,15
    800027e6:	0ad76e63          	bltu	a4,a3,800028a2 <page_in+0x102>
    800027ea:	87aa                	mv	a5,a0
  if (page_index_phsical < 0 || page_index_phsical >= MAX_PSYC_PAGES)
    800027ec:	0005071b          	sext.w	a4,a0
    800027f0:	46bd                	li	a3,15
    800027f2:	0ce6e063          	bltu	a3,a4,800028b2 <page_in+0x112>
  int start_offset = page_index_swapfile * PGSIZE;
    800027f6:	00c49a9b          	slliw	s5,s1,0xc
  if (!(p->pages_swap_info.free_spaces & (1 << page_index_swapfile)))
    800027fa:	17895703          	lhu	a4,376(s2)
    800027fe:	409756bb          	sraw	a3,a4,s1
    80002802:	8a85                	andi	a3,a3,1
    80002804:	cedd                	beqz	a3,800028c2 <page_in+0x122>
  p->pages_swap_info.free_spaces ^= (1 << page_index_swapfile); // mark space as free
    80002806:	4505                	li	a0,1
    80002808:	009514bb          	sllw	s1,a0,s1
    8000280c:	8f25                	xor	a4,a4,s1
    8000280e:	16e91c23          	sh	a4,376(s2)
  if (p->pages_physc_info.free_spaces & (1 << page_index_phsical))
    80002812:	40fa573b          	sraw	a4,s4,a5
    80002816:	8b05                	andi	a4,a4,1
    80002818:	ef4d                	bnez	a4,800028d2 <page_in+0x132>
  p->pages_physc_info.free_spaces |= 1 << page_index_phsical;          // mark space as occupied
    8000281a:	4705                	li	a4,1
    8000281c:	00f7173b          	sllw	a4,a4,a5
    80002820:	00ea6a33          	or	s4,s4,a4
    80002824:	29491023          	sh	s4,640(s2)
  p->pages_physc_info.pages[page_index_phsical].va = va;               // save va of physc page
    80002828:	0792                	slli	a5,a5,0x4
    8000282a:	97ca                	add	a5,a5,s2
    8000282c:	2967b423          	sd	s6,648(a5)
  p->pages_physc_info.pages[page_index_phsical].time_inserted = ticks; // save insertion time for FIFO paging policy
    80002830:	00008717          	auipc	a4,0x8
    80002834:	80072703          	lw	a4,-2048(a4) # 8000a030 <ticks>
    80002838:	28e7aa23          	sw	a4,660(a5)
  void *pa = kalloc();
    8000283c:	ffffe097          	auipc	ra,0xffffe
    80002840:	296080e7          	jalr	662(ra) # 80000ad2 <kalloc>
    80002844:	84aa                	mv	s1,a0
  if (!pa)
    80002846:	cd51                	beqz	a0,800028e2 <page_in+0x142>
  memset(pa, 0, PGSIZE);
    80002848:	6605                	lui	a2,0x1
    8000284a:	4581                	li	a1,0
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	472080e7          	jalr	1138(ra) # 80000cbe <memset>
  readFromSwapFile(p, pa, start_offset, PGSIZE);
    80002854:	6685                	lui	a3,0x1
    80002856:	000a861b          	sext.w	a2,s5
    8000285a:	85a6                	mv	a1,s1
    8000285c:	854a                	mv	a0,s2
    8000285e:	00002097          	auipc	ra,0x2
    80002862:	234080e7          	jalr	564(ra) # 80004a92 <readFromSwapFile>
  if (!(*pte & PTE_PG) || *pte & PTE_V)
    80002866:	0009b783          	ld	a5,0(s3)
    8000286a:	2017f793          	andi	a5,a5,513
    8000286e:	20000713          	li	a4,512
    80002872:	08e79063          	bne	a5,a4,800028f2 <page_in+0x152>
  *pte = PA2PTE(pa) ^ PTE_V ^ PTE_PG;
    80002876:	80b1                	srli	s1,s1,0xc
    80002878:	04aa                	slli	s1,s1,0xa
    8000287a:	2014c493          	xori	s1,s1,513
    8000287e:	0099b023          	sd	s1,0(s3)
  p->physical_pages_num++;
    80002882:	17092783          	lw	a5,368(s2)
    80002886:	2785                	addiw	a5,a5,1
    80002888:	16f92823          	sw	a5,368(s2)
}
    8000288c:	854e                	mv	a0,s3
    8000288e:	70e2                	ld	ra,56(sp)
    80002890:	7442                	ld	s0,48(sp)
    80002892:	74a2                	ld	s1,40(sp)
    80002894:	7902                	ld	s2,32(sp)
    80002896:	69e2                	ld	s3,24(sp)
    80002898:	6a42                	ld	s4,16(sp)
    8000289a:	6aa2                	ld	s5,8(sp)
    8000289c:	6b02                	ld	s6,0(sp)
    8000289e:	6121                	addi	sp,sp,64
    800028a0:	8082                	ret
    panic("page_in: index in swap file not found");
    800028a2:	00007517          	auipc	a0,0x7
    800028a6:	b9e50513          	addi	a0,a0,-1122 # 80009440 <digits+0x400>
    800028aa:	ffffe097          	auipc	ra,0xffffe
    800028ae:	c80080e7          	jalr	-896(ra) # 8000052a <panic>
    panic("page_in: free index in physc arr not found");
    800028b2:	00007517          	auipc	a0,0x7
    800028b6:	bb650513          	addi	a0,a0,-1098 # 80009468 <digits+0x428>
    800028ba:	ffffe097          	auipc	ra,0xffffe
    800028be:	c70080e7          	jalr	-912(ra) # 8000052a <panic>
    panic("page_in: tried to reset free space flag when it is not set");
    800028c2:	00007517          	auipc	a0,0x7
    800028c6:	b3e50513          	addi	a0,a0,-1218 # 80009400 <digits+0x3c0>
    800028ca:	ffffe097          	auipc	ra,0xffffe
    800028ce:	c60080e7          	jalr	-928(ra) # 8000052a <panic>
    panic("page_in: tried to set free space flag when it is already set");
    800028d2:	00007517          	auipc	a0,0x7
    800028d6:	87e50513          	addi	a0,a0,-1922 # 80009150 <digits+0x110>
    800028da:	ffffe097          	auipc	ra,0xffffe
    800028de:	c50080e7          	jalr	-944(ra) # 8000052a <panic>
    panic("page in: fack kalloc failed in page_in");
    800028e2:	00007517          	auipc	a0,0x7
    800028e6:	bb650513          	addi	a0,a0,-1098 # 80009498 <digits+0x458>
    800028ea:	ffffe097          	auipc	ra,0xffffe
    800028ee:	c40080e7          	jalr	-960(ra) # 8000052a <panic>
    panic("page in: page out flag was off or valid flag was on");
    800028f2:	00007517          	auipc	a0,0x7
    800028f6:	bce50513          	addi	a0,a0,-1074 # 800094c0 <digits+0x480>
    800028fa:	ffffe097          	auipc	ra,0xffffe
    800028fe:	c30080e7          	jalr	-976(ra) # 8000052a <panic>

0000000080002902 <copyFilesInfo>:
{
    80002902:	711d                	addi	sp,sp,-96
    80002904:	ec86                	sd	ra,88(sp)
    80002906:	e8a2                	sd	s0,80(sp)
    80002908:	e4a6                	sd	s1,72(sp)
    8000290a:	e0ca                	sd	s2,64(sp)
    8000290c:	fc4e                	sd	s3,56(sp)
    8000290e:	f852                	sd	s4,48(sp)
    80002910:	f456                	sd	s5,40(sp)
    80002912:	f05a                	sd	s6,32(sp)
    80002914:	ec5e                	sd	s7,24(sp)
    80002916:	e862                	sd	s8,16(sp)
    80002918:	e466                	sd	s9,8(sp)
    8000291a:	1080                	addi	s0,sp,96
    8000291c:	89aa                	mv	s3,a0
    8000291e:	84ae                	mv	s1,a1
  printf("1\n");
    80002920:	00007517          	auipc	a0,0x7
    80002924:	bd850513          	addi	a0,a0,-1064 # 800094f8 <digits+0x4b8>
    80002928:	ffffe097          	auipc	ra,0xffffe
    8000292c:	c4c080e7          	jalr	-948(ra) # 80000574 <printf>
  if (!(temp_page = kalloc()))
    80002930:	ffffe097          	auipc	ra,0xffffe
    80002934:	1a2080e7          	jalr	418(ra) # 80000ad2 <kalloc>
    80002938:	c50d                	beqz	a0,80002962 <copyFilesInfo+0x60>
    8000293a:	8b2a                	mv	s6,a0
  printf("2\n");
    8000293c:	00007517          	auipc	a0,0x7
    80002940:	be450513          	addi	a0,a0,-1052 # 80009520 <digits+0x4e0>
    80002944:	ffffe097          	auipc	ra,0xffffe
    80002948:	c30080e7          	jalr	-976(ra) # 80000574 <printf>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000294c:	4901                	li	s2,0
      printf("f1\n");
    8000294e:	00007c17          	auipc	s8,0x7
    80002952:	bdac0c13          	addi	s8,s8,-1062 # 80009528 <digits+0x4e8>
      printf("f2\n");
    80002956:	00007b97          	auipc	s7,0x7
    8000295a:	bfab8b93          	addi	s7,s7,-1030 # 80009550 <digits+0x510>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000295e:	4ac1                	li	s5,16
    80002960:	a025                	j	80002988 <copyFilesInfo+0x86>
    panic("copyFilesInfo: kalloc failed");
    80002962:	00007517          	auipc	a0,0x7
    80002966:	b9e50513          	addi	a0,a0,-1122 # 80009500 <digits+0x4c0>
    8000296a:	ffffe097          	auipc	ra,0xffffe
    8000296e:	bc0080e7          	jalr	-1088(ra) # 8000052a <panic>
        panic("copyFilesInfo: failed read");
    80002972:	00007517          	auipc	a0,0x7
    80002976:	bbe50513          	addi	a0,a0,-1090 # 80009530 <digits+0x4f0>
    8000297a:	ffffe097          	auipc	ra,0xffffe
    8000297e:	bb0080e7          	jalr	-1104(ra) # 8000052a <panic>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002982:	2905                	addiw	s2,s2,1
    80002984:	07590263          	beq	s2,s5,800029e8 <copyFilesInfo+0xe6>
    if (p->pages_swap_info.free_spaces & (1 << i))
    80002988:	1789d783          	lhu	a5,376(s3)
    8000298c:	4127d7bb          	sraw	a5,a5,s2
    80002990:	8b85                	andi	a5,a5,1
    80002992:	dbe5                	beqz	a5,80002982 <copyFilesInfo+0x80>
      int res = readFromSwapFile(p, (char *)temp_page, i * PGSIZE, PGSIZE);
    80002994:	00c91c9b          	slliw	s9,s2,0xc
    80002998:	6685                	lui	a3,0x1
    8000299a:	8666                	mv	a2,s9
    8000299c:	85da                	mv	a1,s6
    8000299e:	854e                	mv	a0,s3
    800029a0:	00002097          	auipc	ra,0x2
    800029a4:	0f2080e7          	jalr	242(ra) # 80004a92 <readFromSwapFile>
    800029a8:	8a2a                	mv	s4,a0
      printf("f1\n");
    800029aa:	8562                	mv	a0,s8
    800029ac:	ffffe097          	auipc	ra,0xffffe
    800029b0:	bc8080e7          	jalr	-1080(ra) # 80000574 <printf>
      if (res < 0)
    800029b4:	fa0a4fe3          	bltz	s4,80002972 <copyFilesInfo+0x70>
      res = writeToSwapFile(np, temp_page, i * PGSIZE, PGSIZE);
    800029b8:	6685                	lui	a3,0x1
    800029ba:	8666                	mv	a2,s9
    800029bc:	85da                	mv	a1,s6
    800029be:	8526                	mv	a0,s1
    800029c0:	00002097          	auipc	ra,0x2
    800029c4:	0ae080e7          	jalr	174(ra) # 80004a6e <writeToSwapFile>
    800029c8:	8a2a                	mv	s4,a0
      printf("f2\n");
    800029ca:	855e                	mv	a0,s7
    800029cc:	ffffe097          	auipc	ra,0xffffe
    800029d0:	ba8080e7          	jalr	-1112(ra) # 80000574 <printf>
      if (res < 0)
    800029d4:	fa0a57e3          	bgez	s4,80002982 <copyFilesInfo+0x80>
        panic("copyFilesInfo: faild write ");
    800029d8:	00007517          	auipc	a0,0x7
    800029dc:	b8050513          	addi	a0,a0,-1152 # 80009558 <digits+0x518>
    800029e0:	ffffe097          	auipc	ra,0xffffe
    800029e4:	b4a080e7          	jalr	-1206(ra) # 8000052a <panic>
  printf("3\n");
    800029e8:	00007517          	auipc	a0,0x7
    800029ec:	b9050513          	addi	a0,a0,-1136 # 80009578 <digits+0x538>
    800029f0:	ffffe097          	auipc	ra,0xffffe
    800029f4:	b84080e7          	jalr	-1148(ra) # 80000574 <printf>
  kfree(temp_page);
    800029f8:	855a                	mv	a0,s6
    800029fa:	ffffe097          	auipc	ra,0xffffe
    800029fe:	fdc080e7          	jalr	-36(ra) # 800009d6 <kfree>
  printf("4\n");
    80002a02:	00007517          	auipc	a0,0x7
    80002a06:	b7e50513          	addi	a0,a0,-1154 # 80009580 <digits+0x540>
    80002a0a:	ffffe097          	auipc	ra,0xffffe
    80002a0e:	b6a080e7          	jalr	-1174(ra) # 80000574 <printf>
  np->pages_swap_info.free_spaces = p->pages_swap_info.free_spaces;
    80002a12:	1789d783          	lhu	a5,376(s3)
    80002a16:	16f49c23          	sh	a5,376(s1)
  np->pages_physc_info.free_spaces = p->pages_physc_info.free_spaces;
    80002a1a:	2809d783          	lhu	a5,640(s3)
    80002a1e:	28f49023          	sh	a5,640(s1)
      printf("5\n");
    80002a22:	00007517          	auipc	a0,0x7
    80002a26:	b6650513          	addi	a0,a0,-1178 # 80009588 <digits+0x548>
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	b4a080e7          	jalr	-1206(ra) # 80000574 <printf>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002a32:	18098793          	addi	a5,s3,384
    80002a36:	18048593          	addi	a1,s1,384
    80002a3a:	28098993          	addi	s3,s3,640
    np->pages_swap_info.pages[i] = p->pages_swap_info.pages[i];
    80002a3e:	6398                	ld	a4,0(a5)
    80002a40:	e198                	sd	a4,0(a1)
    80002a42:	6798                	ld	a4,8(a5)
    80002a44:	e598                	sd	a4,8(a1)
    np->pages_physc_info.pages[i] = p->pages_physc_info.pages[i];
    80002a46:	1087b703          	ld	a4,264(a5)
    80002a4a:	10e5b423          	sd	a4,264(a1) # fffffffffffff108 <end+0xffffffff7ffd0108>
    80002a4e:	1107b703          	ld	a4,272(a5)
    80002a52:	10e5b823          	sd	a4,272(a1)
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002a56:	07c1                	addi	a5,a5,16
    80002a58:	05c1                	addi	a1,a1,16
    80002a5a:	ff3792e3          	bne	a5,s3,80002a3e <copyFilesInfo+0x13c>
printf("6\n");
    80002a5e:	00007517          	auipc	a0,0x7
    80002a62:	b3250513          	addi	a0,a0,-1230 # 80009590 <digits+0x550>
    80002a66:	ffffe097          	auipc	ra,0xffffe
    80002a6a:	b0e080e7          	jalr	-1266(ra) # 80000574 <printf>
}
    80002a6e:	60e6                	ld	ra,88(sp)
    80002a70:	6446                	ld	s0,80(sp)
    80002a72:	64a6                	ld	s1,72(sp)
    80002a74:	6906                	ld	s2,64(sp)
    80002a76:	79e2                	ld	s3,56(sp)
    80002a78:	7a42                	ld	s4,48(sp)
    80002a7a:	7aa2                	ld	s5,40(sp)
    80002a7c:	7b02                	ld	s6,32(sp)
    80002a7e:	6be2                	ld	s7,24(sp)
    80002a80:	6c42                	ld	s8,16(sp)
    80002a82:	6ca2                	ld	s9,8(sp)
    80002a84:	6125                	addi	sp,sp,96
    80002a86:	8082                	ret

0000000080002a88 <fork>:
{
    80002a88:	7139                	addi	sp,sp,-64
    80002a8a:	fc06                	sd	ra,56(sp)
    80002a8c:	f822                	sd	s0,48(sp)
    80002a8e:	f426                	sd	s1,40(sp)
    80002a90:	f04a                	sd	s2,32(sp)
    80002a92:	ec4e                	sd	s3,24(sp)
    80002a94:	e852                	sd	s4,16(sp)
    80002a96:	e456                	sd	s5,8(sp)
    80002a98:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002a9a:	fffff097          	auipc	ra,0xfffff
    80002a9e:	0dc080e7          	jalr	220(ra) # 80001b76 <myproc>
    80002aa2:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80002aa4:	fffff097          	auipc	ra,0xfffff
    80002aa8:	2e4080e7          	jalr	740(ra) # 80001d88 <allocproc>
    80002aac:	18050563          	beqz	a0,80002c36 <fork+0x1ae>
    80002ab0:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002ab2:	048ab603          	ld	a2,72(s5)
    80002ab6:	692c                	ld	a1,80(a0)
    80002ab8:	050ab503          	ld	a0,80(s5)
    80002abc:	fffff097          	auipc	ra,0xfffff
    80002ac0:	e52080e7          	jalr	-430(ra) # 8000190e <uvmcopy>
    80002ac4:	04054863          	bltz	a0,80002b14 <fork+0x8c>
  np->sz = p->sz;
    80002ac8:	048ab783          	ld	a5,72(s5)
    80002acc:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80002ad0:	058ab683          	ld	a3,88(s5)
    80002ad4:	87b6                	mv	a5,a3
    80002ad6:	0589b703          	ld	a4,88(s3)
    80002ada:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    80002ade:	0007b803          	ld	a6,0(a5)
    80002ae2:	6788                	ld	a0,8(a5)
    80002ae4:	6b8c                	ld	a1,16(a5)
    80002ae6:	6f90                	ld	a2,24(a5)
    80002ae8:	01073023          	sd	a6,0(a4)
    80002aec:	e708                	sd	a0,8(a4)
    80002aee:	eb0c                	sd	a1,16(a4)
    80002af0:	ef10                	sd	a2,24(a4)
    80002af2:	02078793          	addi	a5,a5,32
    80002af6:	02070713          	addi	a4,a4,32
    80002afa:	fed792e3          	bne	a5,a3,80002ade <fork+0x56>
  np->trapframe->a0 = 0;
    80002afe:	0589b783          	ld	a5,88(s3)
    80002b02:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80002b06:	0d0a8493          	addi	s1,s5,208
    80002b0a:	0d098913          	addi	s2,s3,208
    80002b0e:	150a8a13          	addi	s4,s5,336
    80002b12:	a00d                	j	80002b34 <fork+0xac>
    freeproc(np);
    80002b14:	854e                	mv	a0,s3
    80002b16:	fffff097          	auipc	ra,0xfffff
    80002b1a:	212080e7          	jalr	530(ra) # 80001d28 <freeproc>
    release(&np->lock);
    80002b1e:	854e                	mv	a0,s3
    80002b20:	ffffe097          	auipc	ra,0xffffe
    80002b24:	156080e7          	jalr	342(ra) # 80000c76 <release>
    return -1;
    80002b28:	597d                	li	s2,-1
    80002b2a:	a0ed                	j	80002c14 <fork+0x18c>
  for (i = 0; i < NOFILE; i++)
    80002b2c:	04a1                	addi	s1,s1,8
    80002b2e:	0921                	addi	s2,s2,8
    80002b30:	01448b63          	beq	s1,s4,80002b46 <fork+0xbe>
    if (p->ofile[i])
    80002b34:	6088                	ld	a0,0(s1)
    80002b36:	d97d                	beqz	a0,80002b2c <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80002b38:	00002097          	auipc	ra,0x2
    80002b3c:	5de080e7          	jalr	1502(ra) # 80005116 <filedup>
    80002b40:	00a93023          	sd	a0,0(s2)
    80002b44:	b7e5                	j	80002b2c <fork+0xa4>
  np->cwd = idup(p->cwd);
    80002b46:	150ab503          	ld	a0,336(s5)
    80002b4a:	00001097          	auipc	ra,0x1
    80002b4e:	42c080e7          	jalr	1068(ra) # 80003f76 <idup>
    80002b52:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002b56:	4641                	li	a2,16
    80002b58:	158a8593          	addi	a1,s5,344
    80002b5c:	15898513          	addi	a0,s3,344
    80002b60:	ffffe097          	auipc	ra,0xffffe
    80002b64:	2b0080e7          	jalr	688(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80002b68:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002b6c:	854e                	mv	a0,s3
    80002b6e:	ffffe097          	auipc	ra,0xffffe
    80002b72:	108080e7          	jalr	264(ra) # 80000c76 <release>
  createSwapFile(np);
    80002b76:	854e                	mv	a0,s3
    80002b78:	00002097          	auipc	ra,0x2
    80002b7c:	e46080e7          	jalr	-442(ra) # 800049be <createSwapFile>
    printf("28.25\n");
    80002b80:	00007517          	auipc	a0,0x7
    80002b84:	a1850513          	addi	a0,a0,-1512 # 80009598 <digits+0x558>
    80002b88:	ffffe097          	auipc	ra,0xffffe
    80002b8c:	9ec080e7          	jalr	-1556(ra) # 80000574 <printf>
  if(p->pid >2 )
    80002b90:	030aa703          	lw	a4,48(s5)
    80002b94:	4789                	li	a5,2
    80002b96:	08e7c963          	blt	a5,a4,80002c28 <fork+0x1a0>
  printf("28.50\n");
    80002b9a:	00007517          	auipc	a0,0x7
    80002b9e:	a0650513          	addi	a0,a0,-1530 # 800095a0 <digits+0x560>
    80002ba2:	ffffe097          	auipc	ra,0xffffe
    80002ba6:	9d2080e7          	jalr	-1582(ra) # 80000574 <printf>
  np->physical_pages_num = p->physical_pages_num;
    80002baa:	170aa783          	lw	a5,368(s5)
    80002bae:	16f9a823          	sw	a5,368(s3)
  np->total_pages_num = p->total_pages_num;
    80002bb2:	174aa783          	lw	a5,372(s5)
    80002bb6:	16f9aa23          	sw	a5,372(s3)
  printf("29\n");
    80002bba:	00007517          	auipc	a0,0x7
    80002bbe:	9ee50513          	addi	a0,a0,-1554 # 800095a8 <digits+0x568>
    80002bc2:	ffffe097          	auipc	ra,0xffffe
    80002bc6:	9b2080e7          	jalr	-1614(ra) # 80000574 <printf>
  acquire(&wait_lock);
    80002bca:	0000f497          	auipc	s1,0xf
    80002bce:	6ee48493          	addi	s1,s1,1774 # 800122b8 <wait_lock>
    80002bd2:	8526                	mv	a0,s1
    80002bd4:	ffffe097          	auipc	ra,0xffffe
    80002bd8:	fee080e7          	jalr	-18(ra) # 80000bc2 <acquire>
  np->parent = p;
    80002bdc:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002be0:	8526                	mv	a0,s1
    80002be2:	ffffe097          	auipc	ra,0xffffe
    80002be6:	094080e7          	jalr	148(ra) # 80000c76 <release>
  acquire(&np->lock);
    80002bea:	854e                	mv	a0,s3
    80002bec:	ffffe097          	auipc	ra,0xffffe
    80002bf0:	fd6080e7          	jalr	-42(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80002bf4:	478d                	li	a5,3
    80002bf6:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002bfa:	854e                	mv	a0,s3
    80002bfc:	ffffe097          	auipc	ra,0xffffe
    80002c00:	07a080e7          	jalr	122(ra) # 80000c76 <release>
    printf("30\n");
    80002c04:	00007517          	auipc	a0,0x7
    80002c08:	9ac50513          	addi	a0,a0,-1620 # 800095b0 <digits+0x570>
    80002c0c:	ffffe097          	auipc	ra,0xffffe
    80002c10:	968080e7          	jalr	-1688(ra) # 80000574 <printf>
}
    80002c14:	854a                	mv	a0,s2
    80002c16:	70e2                	ld	ra,56(sp)
    80002c18:	7442                	ld	s0,48(sp)
    80002c1a:	74a2                	ld	s1,40(sp)
    80002c1c:	7902                	ld	s2,32(sp)
    80002c1e:	69e2                	ld	s3,24(sp)
    80002c20:	6a42                	ld	s4,16(sp)
    80002c22:	6aa2                	ld	s5,8(sp)
    80002c24:	6121                	addi	sp,sp,64
    80002c26:	8082                	ret
    copyFilesInfo(p, np);
    80002c28:	85ce                	mv	a1,s3
    80002c2a:	8556                	mv	a0,s5
    80002c2c:	00000097          	auipc	ra,0x0
    80002c30:	cd6080e7          	jalr	-810(ra) # 80002902 <copyFilesInfo>
    80002c34:	b79d                	j	80002b9a <fork+0x112>
    return -1;
    80002c36:	597d                	li	s2,-1
    80002c38:	bff1                	j	80002c14 <fork+0x18c>

0000000080002c3a <NFUA_compare>:
  if (!pg1 || !pg2)
    80002c3a:	c511                	beqz	a0,80002c46 <NFUA_compare+0xc>
    80002c3c:	c589                	beqz	a1,80002c46 <NFUA_compare+0xc>
  return pg1->aging_counter - pg2->aging_counter;
    80002c3e:	4508                	lw	a0,8(a0)
    80002c40:	459c                	lw	a5,8(a1)
}
    80002c42:	9d1d                	subw	a0,a0,a5
    80002c44:	8082                	ret
{
    80002c46:	1141                	addi	sp,sp,-16
    80002c48:	e406                	sd	ra,8(sp)
    80002c4a:	e022                	sd	s0,0(sp)
    80002c4c:	0800                	addi	s0,sp,16
    panic("NFUA_compare : null input");
    80002c4e:	00007517          	auipc	a0,0x7
    80002c52:	96a50513          	addi	a0,a0,-1686 # 800095b8 <digits+0x578>
    80002c56:	ffffe097          	auipc	ra,0xffffe
    80002c5a:	8d4080e7          	jalr	-1836(ra) # 8000052a <panic>

0000000080002c5e <countOnes>:

int countOnes(uint n)
{
    80002c5e:	1141                	addi	sp,sp,-16
    80002c60:	e422                	sd	s0,8(sp)
    80002c62:	0800                	addi	s0,sp,16
  int count = 0;
  while (n)
    80002c64:	cd01                	beqz	a0,80002c7c <countOnes+0x1e>
    80002c66:	87aa                	mv	a5,a0
  int count = 0;
    80002c68:	4501                	li	a0,0
  {
    count += n & 1;
    80002c6a:	0017f713          	andi	a4,a5,1
    80002c6e:	9d39                	addw	a0,a0,a4
    n >>= 1;
    80002c70:	0017d79b          	srliw	a5,a5,0x1
  while (n)
    80002c74:	fbfd                	bnez	a5,80002c6a <countOnes+0xc>
  }
  return count;
}
    80002c76:	6422                	ld	s0,8(sp)
    80002c78:	0141                	addi	sp,sp,16
    80002c7a:	8082                	ret
  int count = 0;
    80002c7c:	4501                	li	a0,0
    80002c7e:	bfe5                	j	80002c76 <countOnes+0x18>

0000000080002c80 <LAPA_compare>:
{
    80002c80:	7179                	addi	sp,sp,-48
    80002c82:	f406                	sd	ra,40(sp)
    80002c84:	f022                	sd	s0,32(sp)
    80002c86:	ec26                	sd	s1,24(sp)
    80002c88:	e84a                	sd	s2,16(sp)
    80002c8a:	e44e                	sd	s3,8(sp)
    80002c8c:	1800                	addi	s0,sp,48
  if (!pg1 || !pg2)
    80002c8e:	cd05                	beqz	a0,80002cc6 <LAPA_compare+0x46>
    80002c90:	892e                	mv	s2,a1
    80002c92:	c995                	beqz	a1,80002cc6 <LAPA_compare+0x46>
  int res = countOnes(pg1->aging_counter) - countOnes(pg2->aging_counter);
    80002c94:	00852983          	lw	s3,8(a0)
    80002c98:	854e                	mv	a0,s3
    80002c9a:	00000097          	auipc	ra,0x0
    80002c9e:	fc4080e7          	jalr	-60(ra) # 80002c5e <countOnes>
    80002ca2:	84aa                	mv	s1,a0
    80002ca4:	00892903          	lw	s2,8(s2)
    80002ca8:	854a                	mv	a0,s2
    80002caa:	00000097          	auipc	ra,0x0
    80002cae:	fb4080e7          	jalr	-76(ra) # 80002c5e <countOnes>
    80002cb2:	40a4853b          	subw	a0,s1,a0
  if (res == 0)
    80002cb6:	c105                	beqz	a0,80002cd6 <LAPA_compare+0x56>
}
    80002cb8:	70a2                	ld	ra,40(sp)
    80002cba:	7402                	ld	s0,32(sp)
    80002cbc:	64e2                	ld	s1,24(sp)
    80002cbe:	6942                	ld	s2,16(sp)
    80002cc0:	69a2                	ld	s3,8(sp)
    80002cc2:	6145                	addi	sp,sp,48
    80002cc4:	8082                	ret
    panic("LAPA_compare : null input");
    80002cc6:	00007517          	auipc	a0,0x7
    80002cca:	91250513          	addi	a0,a0,-1774 # 800095d8 <digits+0x598>
    80002cce:	ffffe097          	auipc	ra,0xffffe
    80002cd2:	85c080e7          	jalr	-1956(ra) # 8000052a <panic>
    return pg1->aging_counter - pg2->aging_counter;
    80002cd6:	4129853b          	subw	a0,s3,s2
    80002cda:	bff9                	j	80002cb8 <LAPA_compare+0x38>

0000000080002cdc <compare_all_pages>:

// Return the index of the page to swap out acording to paging policy
int compare_all_pages(int (*compare)(struct page_info *pg1, struct page_info *pg2))
{
    80002cdc:	715d                	addi	sp,sp,-80
    80002cde:	e486                	sd	ra,72(sp)
    80002ce0:	e0a2                	sd	s0,64(sp)
    80002ce2:	fc26                	sd	s1,56(sp)
    80002ce4:	f84a                	sd	s2,48(sp)
    80002ce6:	f44e                	sd	s3,40(sp)
    80002ce8:	f052                	sd	s4,32(sp)
    80002cea:	ec56                	sd	s5,24(sp)
    80002cec:	e85a                	sd	s6,16(sp)
    80002cee:	e45e                	sd	s7,8(sp)
    80002cf0:	0880                	addi	s0,sp,80
    80002cf2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002cf4:	fffff097          	auipc	ra,0xfffff
    80002cf8:	e82080e7          	jalr	-382(ra) # 80001b76 <myproc>
    80002cfc:	89aa                	mv	s3,a0
  struct page_info *pg;
  struct page_info *pg_to_swap = 0;
  int min_index = -1;
  int i = 0;
  for (pg = p->pages_physc_info.pages; pg <= &p->pages_physc_info.pages[MAX_PSYC_PAGES]; pg++)
    80002cfe:	28850493          	addi	s1,a0,648
    80002d02:	39850a93          	addi	s5,a0,920
  int i = 0;
    80002d06:	4901                	li	s2,0
  int min_index = -1;
    80002d08:	5bfd                	li	s7,-1
  struct page_info *pg_to_swap = 0;
    80002d0a:	4a01                	li	s4,0
    80002d0c:	a039                	j	80002d1a <compare_all_pages+0x3e>
    80002d0e:	8bca                	mv	s7,s2
    80002d10:	8a26                	mv	s4,s1
    {
      // in case pg_to_swap have not yet been initialize or the current pg is less needable acording to policy
      pg_to_swap = pg;
      min_index = i;
    }
    i++;
    80002d12:	2905                	addiw	s2,s2,1
  for (pg = p->pages_physc_info.pages; pg <= &p->pages_physc_info.pages[MAX_PSYC_PAGES]; pg++)
    80002d14:	04c1                	addi	s1,s1,16
    80002d16:	029a8263          	beq	s5,s1,80002d3a <compare_all_pages+0x5e>
    if (!(p->pages_physc_info.free_spaces & (1 << i)) && (!pg_to_swap || compare(pg, pg_to_swap) < 0))
    80002d1a:	2809d783          	lhu	a5,640(s3)
    80002d1e:	4127d7bb          	sraw	a5,a5,s2
    80002d22:	8b85                	andi	a5,a5,1
    80002d24:	f7fd                	bnez	a5,80002d12 <compare_all_pages+0x36>
    80002d26:	fe0a04e3          	beqz	s4,80002d0e <compare_all_pages+0x32>
    80002d2a:	85d2                	mv	a1,s4
    80002d2c:	8526                	mv	a0,s1
    80002d2e:	9b02                	jalr	s6
    80002d30:	fe0551e3          	bgez	a0,80002d12 <compare_all_pages+0x36>
    80002d34:	8bca                	mv	s7,s2
    80002d36:	8a26                	mv	s4,s1
    80002d38:	bfe9                	j	80002d12 <compare_all_pages+0x36>
  }

  return min_index;
}
    80002d3a:	855e                	mv	a0,s7
    80002d3c:	60a6                	ld	ra,72(sp)
    80002d3e:	6406                	ld	s0,64(sp)
    80002d40:	74e2                	ld	s1,56(sp)
    80002d42:	7942                	ld	s2,48(sp)
    80002d44:	79a2                	ld	s3,40(sp)
    80002d46:	7a02                	ld	s4,32(sp)
    80002d48:	6ae2                	ld	s5,24(sp)
    80002d4a:	6b42                	ld	s6,16(sp)
    80002d4c:	6ba2                	ld	s7,8(sp)
    80002d4e:	6161                	addi	sp,sp,80
    80002d50:	8082                	ret

0000000080002d52 <update_pages_info>:

void update_pages_info()
{
    80002d52:	1141                	addi	sp,sp,-16
    80002d54:	e422                	sd	s0,8(sp)
    80002d56:	0800                	addi	s0,sp,16
  struct proc *p = myproc();

  for (pg = p->pages_physc_info.pages; pg <= &p->pages_physc_info.pages[MAX_PSYC_PAGES]; pg++)
    update_NFUA_LAPA_counter(pg);
#endif
}
    80002d58:	6422                	ld	s0,8(sp)
    80002d5a:	0141                	addi	sp,sp,16
    80002d5c:	8082                	ret

0000000080002d5e <is_accessed>:
{
  pg->aging_counter = (pg->aging_counter >> 1) | (is_accessed(pg, 1) << 31);
}

int is_accessed(struct page_info *pg, int to_reset)
{
    80002d5e:	1101                	addi	sp,sp,-32
    80002d60:	ec06                	sd	ra,24(sp)
    80002d62:	e822                	sd	s0,16(sp)
    80002d64:	e426                	sd	s1,8(sp)
    80002d66:	e04a                	sd	s2,0(sp)
    80002d68:	1000                	addi	s0,sp,32
    80002d6a:	84aa                	mv	s1,a0
    80002d6c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d6e:	fffff097          	auipc	ra,0xfffff
    80002d72:	e08080e7          	jalr	-504(ra) # 80001b76 <myproc>
  pte_t *pte = walk(p->pagetable, pg->va, 0);
    80002d76:	4601                	li	a2,0
    80002d78:	608c                	ld	a1,0(s1)
    80002d7a:	6928                	ld	a0,80(a0)
    80002d7c:	ffffe097          	auipc	ra,0xffffe
    80002d80:	22a080e7          	jalr	554(ra) # 80000fa6 <walk>
    80002d84:	87aa                	mv	a5,a0
  int accessed = (*pte & PTE_A);
    80002d86:	6118                	ld	a4,0(a0)
    80002d88:	04077513          	andi	a0,a4,64
  if (accessed && to_reset)
    80002d8c:	c511                	beqz	a0,80002d98 <is_accessed+0x3a>
    80002d8e:	00090563          	beqz	s2,80002d98 <is_accessed+0x3a>
    *pte ^= PTE_A; // reset accessed flag
    80002d92:	04074713          	xori	a4,a4,64
    80002d96:	e398                	sd	a4,0(a5)

  return accessed;
}
    80002d98:	60e2                	ld	ra,24(sp)
    80002d9a:	6442                	ld	s0,16(sp)
    80002d9c:	64a2                	ld	s1,8(sp)
    80002d9e:	6902                	ld	s2,0(sp)
    80002da0:	6105                	addi	sp,sp,32
    80002da2:	8082                	ret

0000000080002da4 <get_next_page_to_swap_out>:
{
    80002da4:	7179                	addi	sp,sp,-48
    80002da6:	f406                	sd	ra,40(sp)
    80002da8:	f022                	sd	s0,32(sp)
    80002daa:	ec26                	sd	s1,24(sp)
    80002dac:	e84a                	sd	s2,16(sp)
    80002dae:	e44e                	sd	s3,8(sp)
    80002db0:	e052                	sd	s4,0(sp)
    80002db2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002db4:	fffff097          	auipc	ra,0xfffff
    80002db8:	dc2080e7          	jalr	-574(ra) # 80001b76 <myproc>
    80002dbc:	892a                	mv	s2,a0
    selected_pg_index = compare_all_pages(SCFIFO_compare);
    80002dbe:	fffff997          	auipc	s3,0xfffff
    80002dc2:	c2298993          	addi	s3,s3,-990 # 800019e0 <SCFIFO_compare>
        p->pages_physc_info.pages[selected_pg_index].time_inserted = ticks;
    80002dc6:	00007a17          	auipc	s4,0x7
    80002dca:	26aa0a13          	addi	s4,s4,618 # 8000a030 <ticks>
    selected_pg_index = compare_all_pages(SCFIFO_compare);
    80002dce:	854e                	mv	a0,s3
    80002dd0:	00000097          	auipc	ra,0x0
    80002dd4:	f0c080e7          	jalr	-244(ra) # 80002cdc <compare_all_pages>
    80002dd8:	84aa                	mv	s1,a0
    if (selected_pg_index >= 0)
    80002dda:	fe054ae3          	bltz	a0,80002dce <get_next_page_to_swap_out+0x2a>
      int accessed = is_accessed(&p->pages_physc_info.pages[selected_pg_index], 1);
    80002dde:	0512                	slli	a0,a0,0x4
    80002de0:	28850513          	addi	a0,a0,648
    80002de4:	4585                	li	a1,1
    80002de6:	954a                	add	a0,a0,s2
    80002de8:	00000097          	auipc	ra,0x0
    80002dec:	f76080e7          	jalr	-138(ra) # 80002d5e <is_accessed>
      if (accessed)
    80002df0:	c909                	beqz	a0,80002e02 <get_next_page_to_swap_out+0x5e>
        p->pages_physc_info.pages[selected_pg_index].time_inserted = ticks;
    80002df2:	02848493          	addi	s1,s1,40
    80002df6:	0492                	slli	s1,s1,0x4
    80002df8:	94ca                	add	s1,s1,s2
    80002dfa:	000a2783          	lw	a5,0(s4)
    80002dfe:	c8dc                	sw	a5,20(s1)
  while (selected_pg_index < 0)
    80002e00:	b7f9                	j	80002dce <get_next_page_to_swap_out+0x2a>
}
    80002e02:	8526                	mv	a0,s1
    80002e04:	70a2                	ld	ra,40(sp)
    80002e06:	7402                	ld	s0,32(sp)
    80002e08:	64e2                	ld	s1,24(sp)
    80002e0a:	6942                	ld	s2,16(sp)
    80002e0c:	69a2                	ld	s3,8(sp)
    80002e0e:	6a02                	ld	s4,0(sp)
    80002e10:	6145                	addi	sp,sp,48
    80002e12:	8082                	ret

0000000080002e14 <update_NFUA_LAPA_counter>:
{
    80002e14:	1101                	addi	sp,sp,-32
    80002e16:	ec06                	sd	ra,24(sp)
    80002e18:	e822                	sd	s0,16(sp)
    80002e1a:	e426                	sd	s1,8(sp)
    80002e1c:	e04a                	sd	s2,0(sp)
    80002e1e:	1000                	addi	s0,sp,32
    80002e20:	84aa                	mv	s1,a0
  pg->aging_counter = (pg->aging_counter >> 1) | (is_accessed(pg, 1) << 31);
    80002e22:	451c                	lw	a5,8(a0)
    80002e24:	0017d91b          	srliw	s2,a5,0x1
    80002e28:	4585                	li	a1,1
    80002e2a:	00000097          	auipc	ra,0x0
    80002e2e:	f34080e7          	jalr	-204(ra) # 80002d5e <is_accessed>
    80002e32:	01f5179b          	slliw	a5,a0,0x1f
    80002e36:	0127e7b3          	or	a5,a5,s2
    80002e3a:	c49c                	sw	a5,8(s1)
}
    80002e3c:	60e2                	ld	ra,24(sp)
    80002e3e:	6442                	ld	s0,16(sp)
    80002e40:	64a2                	ld	s1,8(sp)
    80002e42:	6902                	ld	s2,0(sp)
    80002e44:	6105                	addi	sp,sp,32
    80002e46:	8082                	ret

0000000080002e48 <reset_aging_counter>:
void reset_aging_counter(struct page_info *pg)
{
    80002e48:	1141                	addi	sp,sp,-16
    80002e4a:	e422                	sd	s0,8(sp)
    80002e4c:	0800                	addi	s0,sp,16
#ifdef NFUA
  pg->aging_counter = 0;
#elif LAPA
  pg->aging_counter = ~0;
#endif
    80002e4e:	6422                	ld	s0,8(sp)
    80002e50:	0141                	addi	sp,sp,16
    80002e52:	8082                	ret

0000000080002e54 <swtch>:
    80002e54:	00153023          	sd	ra,0(a0)
    80002e58:	00253423          	sd	sp,8(a0)
    80002e5c:	e900                	sd	s0,16(a0)
    80002e5e:	ed04                	sd	s1,24(a0)
    80002e60:	03253023          	sd	s2,32(a0)
    80002e64:	03353423          	sd	s3,40(a0)
    80002e68:	03453823          	sd	s4,48(a0)
    80002e6c:	03553c23          	sd	s5,56(a0)
    80002e70:	05653023          	sd	s6,64(a0)
    80002e74:	05753423          	sd	s7,72(a0)
    80002e78:	05853823          	sd	s8,80(a0)
    80002e7c:	05953c23          	sd	s9,88(a0)
    80002e80:	07a53023          	sd	s10,96(a0)
    80002e84:	07b53423          	sd	s11,104(a0)
    80002e88:	0005b083          	ld	ra,0(a1)
    80002e8c:	0085b103          	ld	sp,8(a1)
    80002e90:	6980                	ld	s0,16(a1)
    80002e92:	6d84                	ld	s1,24(a1)
    80002e94:	0205b903          	ld	s2,32(a1)
    80002e98:	0285b983          	ld	s3,40(a1)
    80002e9c:	0305ba03          	ld	s4,48(a1)
    80002ea0:	0385ba83          	ld	s5,56(a1)
    80002ea4:	0405bb03          	ld	s6,64(a1)
    80002ea8:	0485bb83          	ld	s7,72(a1)
    80002eac:	0505bc03          	ld	s8,80(a1)
    80002eb0:	0585bc83          	ld	s9,88(a1)
    80002eb4:	0605bd03          	ld	s10,96(a1)
    80002eb8:	0685bd83          	ld	s11,104(a1)
    80002ebc:	8082                	ret

0000000080002ebe <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002ebe:	1141                	addi	sp,sp,-16
    80002ec0:	e406                	sd	ra,8(sp)
    80002ec2:	e022                	sd	s0,0(sp)
    80002ec4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002ec6:	00006597          	auipc	a1,0x6
    80002eca:	78a58593          	addi	a1,a1,1930 # 80009650 <states.0+0x30>
    80002ece:	0001e517          	auipc	a0,0x1e
    80002ed2:	a0250513          	addi	a0,a0,-1534 # 800208d0 <tickslock>
    80002ed6:	ffffe097          	auipc	ra,0xffffe
    80002eda:	c5c080e7          	jalr	-932(ra) # 80000b32 <initlock>
}
    80002ede:	60a2                	ld	ra,8(sp)
    80002ee0:	6402                	ld	s0,0(sp)
    80002ee2:	0141                	addi	sp,sp,16
    80002ee4:	8082                	ret

0000000080002ee6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002ee6:	1141                	addi	sp,sp,-16
    80002ee8:	e422                	sd	s0,8(sp)
    80002eea:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002eec:	00004797          	auipc	a5,0x4
    80002ef0:	ac478793          	addi	a5,a5,-1340 # 800069b0 <kernelvec>
    80002ef4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002ef8:	6422                	ld	s0,8(sp)
    80002efa:	0141                	addi	sp,sp,16
    80002efc:	8082                	ret

0000000080002efe <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002efe:	1141                	addi	sp,sp,-16
    80002f00:	e406                	sd	ra,8(sp)
    80002f02:	e022                	sd	s0,0(sp)
    80002f04:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002f06:	fffff097          	auipc	ra,0xfffff
    80002f0a:	c70080e7          	jalr	-912(ra) # 80001b76 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f0e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002f12:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f14:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002f18:	00005617          	auipc	a2,0x5
    80002f1c:	0e860613          	addi	a2,a2,232 # 80008000 <_trampoline>
    80002f20:	00005697          	auipc	a3,0x5
    80002f24:	0e068693          	addi	a3,a3,224 # 80008000 <_trampoline>
    80002f28:	8e91                	sub	a3,a3,a2
    80002f2a:	040007b7          	lui	a5,0x4000
    80002f2e:	17fd                	addi	a5,a5,-1
    80002f30:	07b2                	slli	a5,a5,0xc
    80002f32:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002f34:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002f38:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002f3a:	180026f3          	csrr	a3,satp
    80002f3e:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002f40:	6d38                	ld	a4,88(a0)
    80002f42:	6134                	ld	a3,64(a0)
    80002f44:	6585                	lui	a1,0x1
    80002f46:	96ae                	add	a3,a3,a1
    80002f48:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002f4a:	6d38                	ld	a4,88(a0)
    80002f4c:	00000697          	auipc	a3,0x0
    80002f50:	13868693          	addi	a3,a3,312 # 80003084 <usertrap>
    80002f54:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002f56:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002f58:	8692                	mv	a3,tp
    80002f5a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f5c:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002f60:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002f64:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f68:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002f6c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002f6e:	6f18                	ld	a4,24(a4)
    80002f70:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002f74:	692c                	ld	a1,80(a0)
    80002f76:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002f78:	00005717          	auipc	a4,0x5
    80002f7c:	11870713          	addi	a4,a4,280 # 80008090 <userret>
    80002f80:	8f11                	sub	a4,a4,a2
    80002f82:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))fn)(TRAPFRAME, satp);
    80002f84:	577d                	li	a4,-1
    80002f86:	177e                	slli	a4,a4,0x3f
    80002f88:	8dd9                	or	a1,a1,a4
    80002f8a:	02000537          	lui	a0,0x2000
    80002f8e:	157d                	addi	a0,a0,-1
    80002f90:	0536                	slli	a0,a0,0xd
    80002f92:	9782                	jalr	a5
}
    80002f94:	60a2                	ld	ra,8(sp)
    80002f96:	6402                	ld	s0,0(sp)
    80002f98:	0141                	addi	sp,sp,16
    80002f9a:	8082                	ret

0000000080002f9c <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002f9c:	1101                	addi	sp,sp,-32
    80002f9e:	ec06                	sd	ra,24(sp)
    80002fa0:	e822                	sd	s0,16(sp)
    80002fa2:	e426                	sd	s1,8(sp)
    80002fa4:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002fa6:	0001e497          	auipc	s1,0x1e
    80002faa:	92a48493          	addi	s1,s1,-1750 # 800208d0 <tickslock>
    80002fae:	8526                	mv	a0,s1
    80002fb0:	ffffe097          	auipc	ra,0xffffe
    80002fb4:	c12080e7          	jalr	-1006(ra) # 80000bc2 <acquire>
  ticks++;
    80002fb8:	00007517          	auipc	a0,0x7
    80002fbc:	07850513          	addi	a0,a0,120 # 8000a030 <ticks>
    80002fc0:	411c                	lw	a5,0(a0)
    80002fc2:	2785                	addiw	a5,a5,1
    80002fc4:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002fc6:	fffff097          	auipc	ra,0xfffff
    80002fca:	2d4080e7          	jalr	724(ra) # 8000229a <wakeup>
  release(&tickslock);
    80002fce:	8526                	mv	a0,s1
    80002fd0:	ffffe097          	auipc	ra,0xffffe
    80002fd4:	ca6080e7          	jalr	-858(ra) # 80000c76 <release>
}
    80002fd8:	60e2                	ld	ra,24(sp)
    80002fda:	6442                	ld	s0,16(sp)
    80002fdc:	64a2                	ld	s1,8(sp)
    80002fde:	6105                	addi	sp,sp,32
    80002fe0:	8082                	ret

0000000080002fe2 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002fe2:	1101                	addi	sp,sp,-32
    80002fe4:	ec06                	sd	ra,24(sp)
    80002fe6:	e822                	sd	s0,16(sp)
    80002fe8:	e426                	sd	s1,8(sp)
    80002fea:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fec:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002ff0:	00074d63          	bltz	a4,8000300a <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002ff4:	57fd                	li	a5,-1
    80002ff6:	17fe                	slli	a5,a5,0x3f
    80002ff8:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002ffa:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002ffc:	06f70363          	beq	a4,a5,80003062 <devintr+0x80>
  }
}
    80003000:	60e2                	ld	ra,24(sp)
    80003002:	6442                	ld	s0,16(sp)
    80003004:	64a2                	ld	s1,8(sp)
    80003006:	6105                	addi	sp,sp,32
    80003008:	8082                	ret
      (scause & 0xff) == 9)
    8000300a:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    8000300e:	46a5                	li	a3,9
    80003010:	fed792e3          	bne	a5,a3,80002ff4 <devintr+0x12>
    int irq = plic_claim();
    80003014:	00004097          	auipc	ra,0x4
    80003018:	aa4080e7          	jalr	-1372(ra) # 80006ab8 <plic_claim>
    8000301c:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    8000301e:	47a9                	li	a5,10
    80003020:	02f50763          	beq	a0,a5,8000304e <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80003024:	4785                	li	a5,1
    80003026:	02f50963          	beq	a0,a5,80003058 <devintr+0x76>
    return 1;
    8000302a:	4505                	li	a0,1
    else if (irq)
    8000302c:	d8f1                	beqz	s1,80003000 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000302e:	85a6                	mv	a1,s1
    80003030:	00006517          	auipc	a0,0x6
    80003034:	62850513          	addi	a0,a0,1576 # 80009658 <states.0+0x38>
    80003038:	ffffd097          	auipc	ra,0xffffd
    8000303c:	53c080e7          	jalr	1340(ra) # 80000574 <printf>
      plic_complete(irq);
    80003040:	8526                	mv	a0,s1
    80003042:	00004097          	auipc	ra,0x4
    80003046:	a9a080e7          	jalr	-1382(ra) # 80006adc <plic_complete>
    return 1;
    8000304a:	4505                	li	a0,1
    8000304c:	bf55                	j	80003000 <devintr+0x1e>
      uartintr();
    8000304e:	ffffe097          	auipc	ra,0xffffe
    80003052:	938080e7          	jalr	-1736(ra) # 80000986 <uartintr>
    80003056:	b7ed                	j	80003040 <devintr+0x5e>
      virtio_disk_intr();
    80003058:	00004097          	auipc	ra,0x4
    8000305c:	f16080e7          	jalr	-234(ra) # 80006f6e <virtio_disk_intr>
    80003060:	b7c5                	j	80003040 <devintr+0x5e>
    if (cpuid() == 0)
    80003062:	fffff097          	auipc	ra,0xfffff
    80003066:	ae8080e7          	jalr	-1304(ra) # 80001b4a <cpuid>
    8000306a:	c901                	beqz	a0,8000307a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000306c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80003070:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80003072:	14479073          	csrw	sip,a5
    return 2;
    80003076:	4509                	li	a0,2
    80003078:	b761                	j	80003000 <devintr+0x1e>
      clockintr();
    8000307a:	00000097          	auipc	ra,0x0
    8000307e:	f22080e7          	jalr	-222(ra) # 80002f9c <clockintr>
    80003082:	b7ed                	j	8000306c <devintr+0x8a>

0000000080003084 <usertrap>:
{
    80003084:	7179                	addi	sp,sp,-48
    80003086:	f406                	sd	ra,40(sp)
    80003088:	f022                	sd	s0,32(sp)
    8000308a:	ec26                	sd	s1,24(sp)
    8000308c:	e84a                	sd	s2,16(sp)
    8000308e:	e44e                	sd	s3,8(sp)
    80003090:	e052                	sd	s4,0(sp)
    80003092:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003094:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80003098:	1007f793          	andi	a5,a5,256
    8000309c:	e7a1                	bnez	a5,800030e4 <usertrap+0x60>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000309e:	00004797          	auipc	a5,0x4
    800030a2:	91278793          	addi	a5,a5,-1774 # 800069b0 <kernelvec>
    800030a6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800030aa:	fffff097          	auipc	ra,0xfffff
    800030ae:	acc080e7          	jalr	-1332(ra) # 80001b76 <myproc>
    800030b2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800030b4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030b6:	14102773          	csrr	a4,sepc
    800030ba:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800030bc:	142027f3          	csrr	a5,scause
  if (trap_cause == 8)
    800030c0:	4721                	li	a4,8
    800030c2:	02e78963          	beq	a5,a4,800030f4 <usertrap+0x70>
  else if (trap_cause == 13 || trap_cause == 15)
    800030c6:	9bf5                	andi	a5,a5,-3
    800030c8:	4735                	li	a4,13
    800030ca:	06e78a63          	beq	a5,a4,8000313e <usertrap+0xba>
  else if ((which_dev = devintr()) != 0)
    800030ce:	00000097          	auipc	ra,0x0
    800030d2:	f14080e7          	jalr	-236(ra) # 80002fe2 <devintr>
    800030d6:	892a                	mv	s2,a0
    800030d8:	14050663          	beqz	a0,80003224 <usertrap+0x1a0>
  if (p->killed)
    800030dc:	549c                	lw	a5,40(s1)
    800030de:	18078363          	beqz	a5,80003264 <usertrap+0x1e0>
    800030e2:	aaa5                	j	8000325a <usertrap+0x1d6>
    panic("usertrap: not from user mode");
    800030e4:	00006517          	auipc	a0,0x6
    800030e8:	59450513          	addi	a0,a0,1428 # 80009678 <states.0+0x58>
    800030ec:	ffffd097          	auipc	ra,0xffffd
    800030f0:	43e080e7          	jalr	1086(ra) # 8000052a <panic>
    if (p->killed)
    800030f4:	551c                	lw	a5,40(a0)
    800030f6:	ef95                	bnez	a5,80003132 <usertrap+0xae>
    p->trapframe->epc += 4;
    800030f8:	6cb8                	ld	a4,88(s1)
    800030fa:	6f1c                	ld	a5,24(a4)
    800030fc:	0791                	addi	a5,a5,4
    800030fe:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003100:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003104:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003108:	10079073          	csrw	sstatus,a5
    syscall();
    8000310c:	00000097          	auipc	ra,0x0
    80003110:	3aa080e7          	jalr	938(ra) # 800034b6 <syscall>
  if (p->killed)
    80003114:	549c                	lw	a5,40(s1)
    80003116:	14079163          	bnez	a5,80003258 <usertrap+0x1d4>
  usertrapret();
    8000311a:	00000097          	auipc	ra,0x0
    8000311e:	de4080e7          	jalr	-540(ra) # 80002efe <usertrapret>
}
    80003122:	70a2                	ld	ra,40(sp)
    80003124:	7402                	ld	s0,32(sp)
    80003126:	64e2                	ld	s1,24(sp)
    80003128:	6942                	ld	s2,16(sp)
    8000312a:	69a2                	ld	s3,8(sp)
    8000312c:	6a02                	ld	s4,0(sp)
    8000312e:	6145                	addi	sp,sp,48
    80003130:	8082                	ret
      exit(-1);
    80003132:	557d                	li	a0,-1
    80003134:	fffff097          	auipc	ra,0xfffff
    80003138:	236080e7          	jalr	566(ra) # 8000236a <exit>
    8000313c:	bf75                	j	800030f8 <usertrap+0x74>
    struct proc *p = myproc();
    8000313e:	fffff097          	auipc	ra,0xfffff
    80003142:	a38080e7          	jalr	-1480(ra) # 80001b76 <myproc>
    80003146:	892a                	mv	s2,a0
    printf("inside page fault usertrap\n"); //TODO delete
    80003148:	00006517          	auipc	a0,0x6
    8000314c:	55050513          	addi	a0,a0,1360 # 80009698 <states.0+0x78>
    80003150:	ffffd097          	auipc	ra,0xffffd
    80003154:	424080e7          	jalr	1060(ra) # 80000574 <printf>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003158:	14302a73          	csrr	s4,stval
    uint64 fault_rva = PGROUNDDOWN(fault_va);
    8000315c:	77fd                	lui	a5,0xfffff
    8000315e:	00fa7a33          	and	s4,s4,a5
    pte_t *pte = walk(p->pagetable, fault_rva, 0);
    80003162:	4601                	li	a2,0
    80003164:	85d2                	mv	a1,s4
    80003166:	05093503          	ld	a0,80(s2)
    8000316a:	ffffe097          	auipc	ra,0xffffe
    8000316e:	e3c080e7          	jalr	-452(ra) # 80000fa6 <walk>
    80003172:	89aa                	mv	s3,a0
    if (!pte || p->pid <= 2)
    80003174:	c51d                	beqz	a0,800031a2 <usertrap+0x11e>
    80003176:	03092703          	lw	a4,48(s2)
    8000317a:	4789                	li	a5,2
    8000317c:	02e7d363          	bge	a5,a4,800031a2 <usertrap+0x11e>
    if (*pte & PTE_PG && !(*pte & PTE_V))
    80003180:	611c                	ld	a5,0(a0)
    80003182:	2017f693          	andi	a3,a5,513
    80003186:	20000713          	li	a4,512
    8000318a:	02e68e63          	beq	a3,a4,800031c6 <usertrap+0x142>
    else if (*pte & PTE_V)
    8000318e:	8b85                	andi	a5,a5,1
    80003190:	d3d1                	beqz	a5,80003114 <usertrap+0x90>
      panic("usertrap: PTE_V should not be valid during page_fault"); //TODO: check if needed/true
    80003192:	00006517          	auipc	a0,0x6
    80003196:	5a650513          	addi	a0,a0,1446 # 80009738 <states.0+0x118>
    8000319a:	ffffd097          	auipc	ra,0xffffd
    8000319e:	390080e7          	jalr	912(ra) # 8000052a <panic>
      printf("seg fault with pid=%d", p->pid);
    800031a2:	03092583          	lw	a1,48(s2)
    800031a6:	00006517          	auipc	a0,0x6
    800031aa:	51250513          	addi	a0,a0,1298 # 800096b8 <states.0+0x98>
    800031ae:	ffffd097          	auipc	ra,0xffffd
    800031b2:	3c6080e7          	jalr	966(ra) # 80000574 <printf>
      panic("usertrap: segmentation fault oh nooooo"); // TODO check if need to kill just the current procces
    800031b6:	00006517          	auipc	a0,0x6
    800031ba:	51a50513          	addi	a0,a0,1306 # 800096d0 <states.0+0xb0>
    800031be:	ffffd097          	auipc	ra,0xffffd
    800031c2:	36c080e7          	jalr	876(ra) # 8000052a <panic>
      if (p->physical_pages_num >= MAX_PSYC_PAGES)
    800031c6:	17092703          	lw	a4,368(s2)
    800031ca:	47bd                	li	a5,15
    800031cc:	02e7c263          	blt	a5,a4,800031f0 <usertrap+0x16c>
        pte_t *pte_new = page_in(fault_rva, pte);
    800031d0:	85ce                	mv	a1,s3
    800031d2:	8552                	mv	a0,s4
    800031d4:	fffff097          	auipc	ra,0xfffff
    800031d8:	5cc080e7          	jalr	1484(ra) # 800027a0 <page_in>
    800031dc:	85aa                	mv	a1,a0
        printf("usertrap: pte_new = %p", pte_new); // TODO delete
    800031de:	00006517          	auipc	a0,0x6
    800031e2:	54250513          	addi	a0,a0,1346 # 80009720 <states.0+0x100>
    800031e6:	ffffd097          	auipc	ra,0xffffd
    800031ea:	38e080e7          	jalr	910(ra) # 80000574 <printf>
    800031ee:	b71d                	j	80003114 <usertrap+0x90>
        int page_to_swap_out_index = get_next_page_to_swap_out();
    800031f0:	00000097          	auipc	ra,0x0
    800031f4:	bb4080e7          	jalr	-1100(ra) # 80002da4 <get_next_page_to_swap_out>
        uint64 va = p->pages_swap_info.pages[page_to_swap_out_index].va;
    800031f8:	01750793          	addi	a5,a0,23
    800031fc:	0792                	slli	a5,a5,0x4
    800031fe:	993e                	add	s2,s2,a5
    80003200:	01093903          	ld	s2,16(s2)
        uint64 pa = page_out(va);
    80003204:	854a                	mv	a0,s2
    80003206:	fffff097          	auipc	ra,0xfffff
    8000320a:	45a080e7          	jalr	1114(ra) # 80002660 <page_out>
    8000320e:	862a                	mv	a2,a0
        printf("paged out page with va = %p pa = %p\n", va, pa); //TODO delete
    80003210:	85ca                	mv	a1,s2
    80003212:	00006517          	auipc	a0,0x6
    80003216:	4e650513          	addi	a0,a0,1254 # 800096f8 <states.0+0xd8>
    8000321a:	ffffd097          	auipc	ra,0xffffd
    8000321e:	35a080e7          	jalr	858(ra) # 80000574 <printf>
    80003222:	b77d                	j	800031d0 <usertrap+0x14c>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003224:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003228:	5890                	lw	a2,48(s1)
    8000322a:	00006517          	auipc	a0,0x6
    8000322e:	54650513          	addi	a0,a0,1350 # 80009770 <states.0+0x150>
    80003232:	ffffd097          	auipc	ra,0xffffd
    80003236:	342080e7          	jalr	834(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000323a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000323e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003242:	00006517          	auipc	a0,0x6
    80003246:	55e50513          	addi	a0,a0,1374 # 800097a0 <states.0+0x180>
    8000324a:	ffffd097          	auipc	ra,0xffffd
    8000324e:	32a080e7          	jalr	810(ra) # 80000574 <printf>
    p->killed = 1;
    80003252:	4785                	li	a5,1
    80003254:	d49c                	sw	a5,40(s1)
  if (p->killed)
    80003256:	a011                	j	8000325a <usertrap+0x1d6>
    80003258:	4901                	li	s2,0
    exit(-1);
    8000325a:	557d                	li	a0,-1
    8000325c:	fffff097          	auipc	ra,0xfffff
    80003260:	10e080e7          	jalr	270(ra) # 8000236a <exit>
  if (which_dev == 2)
    80003264:	4789                	li	a5,2
    80003266:	eaf91ae3          	bne	s2,a5,8000311a <usertrap+0x96>
    yield();
    8000326a:	fffff097          	auipc	ra,0xfffff
    8000326e:	e68080e7          	jalr	-408(ra) # 800020d2 <yield>
    80003272:	b565                	j	8000311a <usertrap+0x96>

0000000080003274 <kerneltrap>:
{
    80003274:	7179                	addi	sp,sp,-48
    80003276:	f406                	sd	ra,40(sp)
    80003278:	f022                	sd	s0,32(sp)
    8000327a:	ec26                	sd	s1,24(sp)
    8000327c:	e84a                	sd	s2,16(sp)
    8000327e:	e44e                	sd	s3,8(sp)
    80003280:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003282:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003286:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000328a:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    8000328e:	1004f793          	andi	a5,s1,256
    80003292:	cb85                	beqz	a5,800032c2 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003294:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003298:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    8000329a:	ef85                	bnez	a5,800032d2 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    8000329c:	00000097          	auipc	ra,0x0
    800032a0:	d46080e7          	jalr	-698(ra) # 80002fe2 <devintr>
    800032a4:	cd1d                	beqz	a0,800032e2 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800032a6:	4789                	li	a5,2
    800032a8:	06f50a63          	beq	a0,a5,8000331c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800032ac:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800032b0:	10049073          	csrw	sstatus,s1
}
    800032b4:	70a2                	ld	ra,40(sp)
    800032b6:	7402                	ld	s0,32(sp)
    800032b8:	64e2                	ld	s1,24(sp)
    800032ba:	6942                	ld	s2,16(sp)
    800032bc:	69a2                	ld	s3,8(sp)
    800032be:	6145                	addi	sp,sp,48
    800032c0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800032c2:	00006517          	auipc	a0,0x6
    800032c6:	4fe50513          	addi	a0,a0,1278 # 800097c0 <states.0+0x1a0>
    800032ca:	ffffd097          	auipc	ra,0xffffd
    800032ce:	260080e7          	jalr	608(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    800032d2:	00006517          	auipc	a0,0x6
    800032d6:	51650513          	addi	a0,a0,1302 # 800097e8 <states.0+0x1c8>
    800032da:	ffffd097          	auipc	ra,0xffffd
    800032de:	250080e7          	jalr	592(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    800032e2:	85ce                	mv	a1,s3
    800032e4:	00006517          	auipc	a0,0x6
    800032e8:	52450513          	addi	a0,a0,1316 # 80009808 <states.0+0x1e8>
    800032ec:	ffffd097          	auipc	ra,0xffffd
    800032f0:	288080e7          	jalr	648(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800032f4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800032f8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800032fc:	00006517          	auipc	a0,0x6
    80003300:	51c50513          	addi	a0,a0,1308 # 80009818 <states.0+0x1f8>
    80003304:	ffffd097          	auipc	ra,0xffffd
    80003308:	270080e7          	jalr	624(ra) # 80000574 <printf>
    panic("kerneltrap");
    8000330c:	00006517          	auipc	a0,0x6
    80003310:	52450513          	addi	a0,a0,1316 # 80009830 <states.0+0x210>
    80003314:	ffffd097          	auipc	ra,0xffffd
    80003318:	216080e7          	jalr	534(ra) # 8000052a <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000331c:	fffff097          	auipc	ra,0xfffff
    80003320:	85a080e7          	jalr	-1958(ra) # 80001b76 <myproc>
    80003324:	d541                	beqz	a0,800032ac <kerneltrap+0x38>
    80003326:	fffff097          	auipc	ra,0xfffff
    8000332a:	850080e7          	jalr	-1968(ra) # 80001b76 <myproc>
    8000332e:	4d18                	lw	a4,24(a0)
    80003330:	4791                	li	a5,4
    80003332:	f6f71de3          	bne	a4,a5,800032ac <kerneltrap+0x38>
    yield();
    80003336:	fffff097          	auipc	ra,0xfffff
    8000333a:	d9c080e7          	jalr	-612(ra) # 800020d2 <yield>
    8000333e:	b7bd                	j	800032ac <kerneltrap+0x38>

0000000080003340 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003340:	1101                	addi	sp,sp,-32
    80003342:	ec06                	sd	ra,24(sp)
    80003344:	e822                	sd	s0,16(sp)
    80003346:	e426                	sd	s1,8(sp)
    80003348:	1000                	addi	s0,sp,32
    8000334a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000334c:	fffff097          	auipc	ra,0xfffff
    80003350:	82a080e7          	jalr	-2006(ra) # 80001b76 <myproc>
  switch (n) {
    80003354:	4795                	li	a5,5
    80003356:	0497e163          	bltu	a5,s1,80003398 <argraw+0x58>
    8000335a:	048a                	slli	s1,s1,0x2
    8000335c:	00006717          	auipc	a4,0x6
    80003360:	50c70713          	addi	a4,a4,1292 # 80009868 <states.0+0x248>
    80003364:	94ba                	add	s1,s1,a4
    80003366:	409c                	lw	a5,0(s1)
    80003368:	97ba                	add	a5,a5,a4
    8000336a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000336c:	6d3c                	ld	a5,88(a0)
    8000336e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003370:	60e2                	ld	ra,24(sp)
    80003372:	6442                	ld	s0,16(sp)
    80003374:	64a2                	ld	s1,8(sp)
    80003376:	6105                	addi	sp,sp,32
    80003378:	8082                	ret
    return p->trapframe->a1;
    8000337a:	6d3c                	ld	a5,88(a0)
    8000337c:	7fa8                	ld	a0,120(a5)
    8000337e:	bfcd                	j	80003370 <argraw+0x30>
    return p->trapframe->a2;
    80003380:	6d3c                	ld	a5,88(a0)
    80003382:	63c8                	ld	a0,128(a5)
    80003384:	b7f5                	j	80003370 <argraw+0x30>
    return p->trapframe->a3;
    80003386:	6d3c                	ld	a5,88(a0)
    80003388:	67c8                	ld	a0,136(a5)
    8000338a:	b7dd                	j	80003370 <argraw+0x30>
    return p->trapframe->a4;
    8000338c:	6d3c                	ld	a5,88(a0)
    8000338e:	6bc8                	ld	a0,144(a5)
    80003390:	b7c5                	j	80003370 <argraw+0x30>
    return p->trapframe->a5;
    80003392:	6d3c                	ld	a5,88(a0)
    80003394:	6fc8                	ld	a0,152(a5)
    80003396:	bfe9                	j	80003370 <argraw+0x30>
  panic("argraw");
    80003398:	00006517          	auipc	a0,0x6
    8000339c:	4a850513          	addi	a0,a0,1192 # 80009840 <states.0+0x220>
    800033a0:	ffffd097          	auipc	ra,0xffffd
    800033a4:	18a080e7          	jalr	394(ra) # 8000052a <panic>

00000000800033a8 <fetchaddr>:
{
    800033a8:	1101                	addi	sp,sp,-32
    800033aa:	ec06                	sd	ra,24(sp)
    800033ac:	e822                	sd	s0,16(sp)
    800033ae:	e426                	sd	s1,8(sp)
    800033b0:	e04a                	sd	s2,0(sp)
    800033b2:	1000                	addi	s0,sp,32
    800033b4:	84aa                	mv	s1,a0
    800033b6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800033b8:	ffffe097          	auipc	ra,0xffffe
    800033bc:	7be080e7          	jalr	1982(ra) # 80001b76 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    800033c0:	653c                	ld	a5,72(a0)
    800033c2:	02f4f863          	bgeu	s1,a5,800033f2 <fetchaddr+0x4a>
    800033c6:	00848713          	addi	a4,s1,8
    800033ca:	02e7e663          	bltu	a5,a4,800033f6 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800033ce:	46a1                	li	a3,8
    800033d0:	8626                	mv	a2,s1
    800033d2:	85ca                	mv	a1,s2
    800033d4:	6928                	ld	a0,80(a0)
    800033d6:	ffffe097          	auipc	ra,0xffffe
    800033da:	04c080e7          	jalr	76(ra) # 80001422 <copyin>
    800033de:	00a03533          	snez	a0,a0
    800033e2:	40a00533          	neg	a0,a0
}
    800033e6:	60e2                	ld	ra,24(sp)
    800033e8:	6442                	ld	s0,16(sp)
    800033ea:	64a2                	ld	s1,8(sp)
    800033ec:	6902                	ld	s2,0(sp)
    800033ee:	6105                	addi	sp,sp,32
    800033f0:	8082                	ret
    return -1;
    800033f2:	557d                	li	a0,-1
    800033f4:	bfcd                	j	800033e6 <fetchaddr+0x3e>
    800033f6:	557d                	li	a0,-1
    800033f8:	b7fd                	j	800033e6 <fetchaddr+0x3e>

00000000800033fa <fetchstr>:
{
    800033fa:	7179                	addi	sp,sp,-48
    800033fc:	f406                	sd	ra,40(sp)
    800033fe:	f022                	sd	s0,32(sp)
    80003400:	ec26                	sd	s1,24(sp)
    80003402:	e84a                	sd	s2,16(sp)
    80003404:	e44e                	sd	s3,8(sp)
    80003406:	1800                	addi	s0,sp,48
    80003408:	892a                	mv	s2,a0
    8000340a:	84ae                	mv	s1,a1
    8000340c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000340e:	ffffe097          	auipc	ra,0xffffe
    80003412:	768080e7          	jalr	1896(ra) # 80001b76 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003416:	86ce                	mv	a3,s3
    80003418:	864a                	mv	a2,s2
    8000341a:	85a6                	mv	a1,s1
    8000341c:	6928                	ld	a0,80(a0)
    8000341e:	ffffe097          	auipc	ra,0xffffe
    80003422:	094080e7          	jalr	148(ra) # 800014b2 <copyinstr>
  if(err < 0)
    80003426:	00054763          	bltz	a0,80003434 <fetchstr+0x3a>
  return strlen(buf);
    8000342a:	8526                	mv	a0,s1
    8000342c:	ffffe097          	auipc	ra,0xffffe
    80003430:	a16080e7          	jalr	-1514(ra) # 80000e42 <strlen>
}
    80003434:	70a2                	ld	ra,40(sp)
    80003436:	7402                	ld	s0,32(sp)
    80003438:	64e2                	ld	s1,24(sp)
    8000343a:	6942                	ld	s2,16(sp)
    8000343c:	69a2                	ld	s3,8(sp)
    8000343e:	6145                	addi	sp,sp,48
    80003440:	8082                	ret

0000000080003442 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003442:	1101                	addi	sp,sp,-32
    80003444:	ec06                	sd	ra,24(sp)
    80003446:	e822                	sd	s0,16(sp)
    80003448:	e426                	sd	s1,8(sp)
    8000344a:	1000                	addi	s0,sp,32
    8000344c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000344e:	00000097          	auipc	ra,0x0
    80003452:	ef2080e7          	jalr	-270(ra) # 80003340 <argraw>
    80003456:	c088                	sw	a0,0(s1)
  return 0;
}
    80003458:	4501                	li	a0,0
    8000345a:	60e2                	ld	ra,24(sp)
    8000345c:	6442                	ld	s0,16(sp)
    8000345e:	64a2                	ld	s1,8(sp)
    80003460:	6105                	addi	sp,sp,32
    80003462:	8082                	ret

0000000080003464 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003464:	1101                	addi	sp,sp,-32
    80003466:	ec06                	sd	ra,24(sp)
    80003468:	e822                	sd	s0,16(sp)
    8000346a:	e426                	sd	s1,8(sp)
    8000346c:	1000                	addi	s0,sp,32
    8000346e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003470:	00000097          	auipc	ra,0x0
    80003474:	ed0080e7          	jalr	-304(ra) # 80003340 <argraw>
    80003478:	e088                	sd	a0,0(s1)
  return 0;
}
    8000347a:	4501                	li	a0,0
    8000347c:	60e2                	ld	ra,24(sp)
    8000347e:	6442                	ld	s0,16(sp)
    80003480:	64a2                	ld	s1,8(sp)
    80003482:	6105                	addi	sp,sp,32
    80003484:	8082                	ret

0000000080003486 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003486:	1101                	addi	sp,sp,-32
    80003488:	ec06                	sd	ra,24(sp)
    8000348a:	e822                	sd	s0,16(sp)
    8000348c:	e426                	sd	s1,8(sp)
    8000348e:	e04a                	sd	s2,0(sp)
    80003490:	1000                	addi	s0,sp,32
    80003492:	84ae                	mv	s1,a1
    80003494:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003496:	00000097          	auipc	ra,0x0
    8000349a:	eaa080e7          	jalr	-342(ra) # 80003340 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    8000349e:	864a                	mv	a2,s2
    800034a0:	85a6                	mv	a1,s1
    800034a2:	00000097          	auipc	ra,0x0
    800034a6:	f58080e7          	jalr	-168(ra) # 800033fa <fetchstr>
}
    800034aa:	60e2                	ld	ra,24(sp)
    800034ac:	6442                	ld	s0,16(sp)
    800034ae:	64a2                	ld	s1,8(sp)
    800034b0:	6902                	ld	s2,0(sp)
    800034b2:	6105                	addi	sp,sp,32
    800034b4:	8082                	ret

00000000800034b6 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    800034b6:	1101                	addi	sp,sp,-32
    800034b8:	ec06                	sd	ra,24(sp)
    800034ba:	e822                	sd	s0,16(sp)
    800034bc:	e426                	sd	s1,8(sp)
    800034be:	e04a                	sd	s2,0(sp)
    800034c0:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800034c2:	ffffe097          	auipc	ra,0xffffe
    800034c6:	6b4080e7          	jalr	1716(ra) # 80001b76 <myproc>
    800034ca:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800034cc:	05853903          	ld	s2,88(a0)
    800034d0:	0a893783          	ld	a5,168(s2)
    800034d4:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800034d8:	37fd                	addiw	a5,a5,-1
    800034da:	4751                	li	a4,20
    800034dc:	00f76f63          	bltu	a4,a5,800034fa <syscall+0x44>
    800034e0:	00369713          	slli	a4,a3,0x3
    800034e4:	00006797          	auipc	a5,0x6
    800034e8:	39c78793          	addi	a5,a5,924 # 80009880 <syscalls>
    800034ec:	97ba                	add	a5,a5,a4
    800034ee:	639c                	ld	a5,0(a5)
    800034f0:	c789                	beqz	a5,800034fa <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    800034f2:	9782                	jalr	a5
    800034f4:	06a93823          	sd	a0,112(s2)
    800034f8:	a839                	j	80003516 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800034fa:	15848613          	addi	a2,s1,344
    800034fe:	588c                	lw	a1,48(s1)
    80003500:	00006517          	auipc	a0,0x6
    80003504:	34850513          	addi	a0,a0,840 # 80009848 <states.0+0x228>
    80003508:	ffffd097          	auipc	ra,0xffffd
    8000350c:	06c080e7          	jalr	108(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003510:	6cbc                	ld	a5,88(s1)
    80003512:	577d                	li	a4,-1
    80003514:	fbb8                	sd	a4,112(a5)
  }
}
    80003516:	60e2                	ld	ra,24(sp)
    80003518:	6442                	ld	s0,16(sp)
    8000351a:	64a2                	ld	s1,8(sp)
    8000351c:	6902                	ld	s2,0(sp)
    8000351e:	6105                	addi	sp,sp,32
    80003520:	8082                	ret

0000000080003522 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003522:	1101                	addi	sp,sp,-32
    80003524:	ec06                	sd	ra,24(sp)
    80003526:	e822                	sd	s0,16(sp)
    80003528:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    8000352a:	fec40593          	addi	a1,s0,-20
    8000352e:	4501                	li	a0,0
    80003530:	00000097          	auipc	ra,0x0
    80003534:	f12080e7          	jalr	-238(ra) # 80003442 <argint>
    return -1;
    80003538:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000353a:	00054963          	bltz	a0,8000354c <sys_exit+0x2a>
  exit(n);
    8000353e:	fec42503          	lw	a0,-20(s0)
    80003542:	fffff097          	auipc	ra,0xfffff
    80003546:	e28080e7          	jalr	-472(ra) # 8000236a <exit>
  return 0;  // not reached
    8000354a:	4781                	li	a5,0
}
    8000354c:	853e                	mv	a0,a5
    8000354e:	60e2                	ld	ra,24(sp)
    80003550:	6442                	ld	s0,16(sp)
    80003552:	6105                	addi	sp,sp,32
    80003554:	8082                	ret

0000000080003556 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003556:	1141                	addi	sp,sp,-16
    80003558:	e406                	sd	ra,8(sp)
    8000355a:	e022                	sd	s0,0(sp)
    8000355c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000355e:	ffffe097          	auipc	ra,0xffffe
    80003562:	618080e7          	jalr	1560(ra) # 80001b76 <myproc>
}
    80003566:	5908                	lw	a0,48(a0)
    80003568:	60a2                	ld	ra,8(sp)
    8000356a:	6402                	ld	s0,0(sp)
    8000356c:	0141                	addi	sp,sp,16
    8000356e:	8082                	ret

0000000080003570 <sys_fork>:

uint64
sys_fork(void)
{
    80003570:	1141                	addi	sp,sp,-16
    80003572:	e406                	sd	ra,8(sp)
    80003574:	e022                	sd	s0,0(sp)
    80003576:	0800                	addi	s0,sp,16
  return fork();
    80003578:	fffff097          	auipc	ra,0xfffff
    8000357c:	510080e7          	jalr	1296(ra) # 80002a88 <fork>
}
    80003580:	60a2                	ld	ra,8(sp)
    80003582:	6402                	ld	s0,0(sp)
    80003584:	0141                	addi	sp,sp,16
    80003586:	8082                	ret

0000000080003588 <sys_wait>:

uint64
sys_wait(void)
{
    80003588:	1101                	addi	sp,sp,-32
    8000358a:	ec06                	sd	ra,24(sp)
    8000358c:	e822                	sd	s0,16(sp)
    8000358e:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003590:	fe840593          	addi	a1,s0,-24
    80003594:	4501                	li	a0,0
    80003596:	00000097          	auipc	ra,0x0
    8000359a:	ece080e7          	jalr	-306(ra) # 80003464 <argaddr>
    8000359e:	87aa                	mv	a5,a0
    return -1;
    800035a0:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800035a2:	0007c863          	bltz	a5,800035b2 <sys_wait+0x2a>
  return wait(p);
    800035a6:	fe843503          	ld	a0,-24(s0)
    800035aa:	fffff097          	auipc	ra,0xfffff
    800035ae:	bc8080e7          	jalr	-1080(ra) # 80002172 <wait>
}
    800035b2:	60e2                	ld	ra,24(sp)
    800035b4:	6442                	ld	s0,16(sp)
    800035b6:	6105                	addi	sp,sp,32
    800035b8:	8082                	ret

00000000800035ba <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800035ba:	7179                	addi	sp,sp,-48
    800035bc:	f406                	sd	ra,40(sp)
    800035be:	f022                	sd	s0,32(sp)
    800035c0:	ec26                	sd	s1,24(sp)
    800035c2:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800035c4:	fdc40593          	addi	a1,s0,-36
    800035c8:	4501                	li	a0,0
    800035ca:	00000097          	auipc	ra,0x0
    800035ce:	e78080e7          	jalr	-392(ra) # 80003442 <argint>
    return -1;
    800035d2:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    800035d4:	00054f63          	bltz	a0,800035f2 <sys_sbrk+0x38>
  addr = myproc()->sz;
    800035d8:	ffffe097          	auipc	ra,0xffffe
    800035dc:	59e080e7          	jalr	1438(ra) # 80001b76 <myproc>
    800035e0:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    800035e2:	fdc42503          	lw	a0,-36(s0)
    800035e6:	fffff097          	auipc	ra,0xfffff
    800035ea:	902080e7          	jalr	-1790(ra) # 80001ee8 <growproc>
    800035ee:	00054863          	bltz	a0,800035fe <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800035f2:	8526                	mv	a0,s1
    800035f4:	70a2                	ld	ra,40(sp)
    800035f6:	7402                	ld	s0,32(sp)
    800035f8:	64e2                	ld	s1,24(sp)
    800035fa:	6145                	addi	sp,sp,48
    800035fc:	8082                	ret
    return -1;
    800035fe:	54fd                	li	s1,-1
    80003600:	bfcd                	j	800035f2 <sys_sbrk+0x38>

0000000080003602 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003602:	7139                	addi	sp,sp,-64
    80003604:	fc06                	sd	ra,56(sp)
    80003606:	f822                	sd	s0,48(sp)
    80003608:	f426                	sd	s1,40(sp)
    8000360a:	f04a                	sd	s2,32(sp)
    8000360c:	ec4e                	sd	s3,24(sp)
    8000360e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003610:	fcc40593          	addi	a1,s0,-52
    80003614:	4501                	li	a0,0
    80003616:	00000097          	auipc	ra,0x0
    8000361a:	e2c080e7          	jalr	-468(ra) # 80003442 <argint>
    return -1;
    8000361e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003620:	06054563          	bltz	a0,8000368a <sys_sleep+0x88>
  acquire(&tickslock);
    80003624:	0001d517          	auipc	a0,0x1d
    80003628:	2ac50513          	addi	a0,a0,684 # 800208d0 <tickslock>
    8000362c:	ffffd097          	auipc	ra,0xffffd
    80003630:	596080e7          	jalr	1430(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    80003634:	00007917          	auipc	s2,0x7
    80003638:	9fc92903          	lw	s2,-1540(s2) # 8000a030 <ticks>
  while(ticks - ticks0 < n){
    8000363c:	fcc42783          	lw	a5,-52(s0)
    80003640:	cf85                	beqz	a5,80003678 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003642:	0001d997          	auipc	s3,0x1d
    80003646:	28e98993          	addi	s3,s3,654 # 800208d0 <tickslock>
    8000364a:	00007497          	auipc	s1,0x7
    8000364e:	9e648493          	addi	s1,s1,-1562 # 8000a030 <ticks>
    if(myproc()->killed){
    80003652:	ffffe097          	auipc	ra,0xffffe
    80003656:	524080e7          	jalr	1316(ra) # 80001b76 <myproc>
    8000365a:	551c                	lw	a5,40(a0)
    8000365c:	ef9d                	bnez	a5,8000369a <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000365e:	85ce                	mv	a1,s3
    80003660:	8526                	mv	a0,s1
    80003662:	fffff097          	auipc	ra,0xfffff
    80003666:	aac080e7          	jalr	-1364(ra) # 8000210e <sleep>
  while(ticks - ticks0 < n){
    8000366a:	409c                	lw	a5,0(s1)
    8000366c:	412787bb          	subw	a5,a5,s2
    80003670:	fcc42703          	lw	a4,-52(s0)
    80003674:	fce7efe3          	bltu	a5,a4,80003652 <sys_sleep+0x50>
  }
  release(&tickslock);
    80003678:	0001d517          	auipc	a0,0x1d
    8000367c:	25850513          	addi	a0,a0,600 # 800208d0 <tickslock>
    80003680:	ffffd097          	auipc	ra,0xffffd
    80003684:	5f6080e7          	jalr	1526(ra) # 80000c76 <release>
  return 0;
    80003688:	4781                	li	a5,0
}
    8000368a:	853e                	mv	a0,a5
    8000368c:	70e2                	ld	ra,56(sp)
    8000368e:	7442                	ld	s0,48(sp)
    80003690:	74a2                	ld	s1,40(sp)
    80003692:	7902                	ld	s2,32(sp)
    80003694:	69e2                	ld	s3,24(sp)
    80003696:	6121                	addi	sp,sp,64
    80003698:	8082                	ret
      release(&tickslock);
    8000369a:	0001d517          	auipc	a0,0x1d
    8000369e:	23650513          	addi	a0,a0,566 # 800208d0 <tickslock>
    800036a2:	ffffd097          	auipc	ra,0xffffd
    800036a6:	5d4080e7          	jalr	1492(ra) # 80000c76 <release>
      return -1;
    800036aa:	57fd                	li	a5,-1
    800036ac:	bff9                	j	8000368a <sys_sleep+0x88>

00000000800036ae <sys_kill>:

uint64
sys_kill(void)
{
    800036ae:	1101                	addi	sp,sp,-32
    800036b0:	ec06                	sd	ra,24(sp)
    800036b2:	e822                	sd	s0,16(sp)
    800036b4:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800036b6:	fec40593          	addi	a1,s0,-20
    800036ba:	4501                	li	a0,0
    800036bc:	00000097          	auipc	ra,0x0
    800036c0:	d86080e7          	jalr	-634(ra) # 80003442 <argint>
    800036c4:	87aa                	mv	a5,a0
    return -1;
    800036c6:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800036c8:	0007c863          	bltz	a5,800036d8 <sys_kill+0x2a>
  return kill(pid);
    800036cc:	fec42503          	lw	a0,-20(s0)
    800036d0:	fffff097          	auipc	ra,0xfffff
    800036d4:	d70080e7          	jalr	-656(ra) # 80002440 <kill>
}
    800036d8:	60e2                	ld	ra,24(sp)
    800036da:	6442                	ld	s0,16(sp)
    800036dc:	6105                	addi	sp,sp,32
    800036de:	8082                	ret

00000000800036e0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800036e0:	1101                	addi	sp,sp,-32
    800036e2:	ec06                	sd	ra,24(sp)
    800036e4:	e822                	sd	s0,16(sp)
    800036e6:	e426                	sd	s1,8(sp)
    800036e8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800036ea:	0001d517          	auipc	a0,0x1d
    800036ee:	1e650513          	addi	a0,a0,486 # 800208d0 <tickslock>
    800036f2:	ffffd097          	auipc	ra,0xffffd
    800036f6:	4d0080e7          	jalr	1232(ra) # 80000bc2 <acquire>
  xticks = ticks;
    800036fa:	00007497          	auipc	s1,0x7
    800036fe:	9364a483          	lw	s1,-1738(s1) # 8000a030 <ticks>
  release(&tickslock);
    80003702:	0001d517          	auipc	a0,0x1d
    80003706:	1ce50513          	addi	a0,a0,462 # 800208d0 <tickslock>
    8000370a:	ffffd097          	auipc	ra,0xffffd
    8000370e:	56c080e7          	jalr	1388(ra) # 80000c76 <release>
  return xticks;
}
    80003712:	02049513          	slli	a0,s1,0x20
    80003716:	9101                	srli	a0,a0,0x20
    80003718:	60e2                	ld	ra,24(sp)
    8000371a:	6442                	ld	s0,16(sp)
    8000371c:	64a2                	ld	s1,8(sp)
    8000371e:	6105                	addi	sp,sp,32
    80003720:	8082                	ret

0000000080003722 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003722:	7179                	addi	sp,sp,-48
    80003724:	f406                	sd	ra,40(sp)
    80003726:	f022                	sd	s0,32(sp)
    80003728:	ec26                	sd	s1,24(sp)
    8000372a:	e84a                	sd	s2,16(sp)
    8000372c:	e44e                	sd	s3,8(sp)
    8000372e:	e052                	sd	s4,0(sp)
    80003730:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003732:	00006597          	auipc	a1,0x6
    80003736:	1fe58593          	addi	a1,a1,510 # 80009930 <syscalls+0xb0>
    8000373a:	0001d517          	auipc	a0,0x1d
    8000373e:	1ae50513          	addi	a0,a0,430 # 800208e8 <bcache>
    80003742:	ffffd097          	auipc	ra,0xffffd
    80003746:	3f0080e7          	jalr	1008(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000374a:	00025797          	auipc	a5,0x25
    8000374e:	19e78793          	addi	a5,a5,414 # 800288e8 <bcache+0x8000>
    80003752:	00025717          	auipc	a4,0x25
    80003756:	3fe70713          	addi	a4,a4,1022 # 80028b50 <bcache+0x8268>
    8000375a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000375e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003762:	0001d497          	auipc	s1,0x1d
    80003766:	19e48493          	addi	s1,s1,414 # 80020900 <bcache+0x18>
    b->next = bcache.head.next;
    8000376a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000376c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000376e:	00006a17          	auipc	s4,0x6
    80003772:	1caa0a13          	addi	s4,s4,458 # 80009938 <syscalls+0xb8>
    b->next = bcache.head.next;
    80003776:	2b893783          	ld	a5,696(s2)
    8000377a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000377c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003780:	85d2                	mv	a1,s4
    80003782:	01048513          	addi	a0,s1,16
    80003786:	00001097          	auipc	ra,0x1
    8000378a:	7d4080e7          	jalr	2004(ra) # 80004f5a <initsleeplock>
    bcache.head.next->prev = b;
    8000378e:	2b893783          	ld	a5,696(s2)
    80003792:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003794:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003798:	45848493          	addi	s1,s1,1112
    8000379c:	fd349de3          	bne	s1,s3,80003776 <binit+0x54>
  }
}
    800037a0:	70a2                	ld	ra,40(sp)
    800037a2:	7402                	ld	s0,32(sp)
    800037a4:	64e2                	ld	s1,24(sp)
    800037a6:	6942                	ld	s2,16(sp)
    800037a8:	69a2                	ld	s3,8(sp)
    800037aa:	6a02                	ld	s4,0(sp)
    800037ac:	6145                	addi	sp,sp,48
    800037ae:	8082                	ret

00000000800037b0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800037b0:	7179                	addi	sp,sp,-48
    800037b2:	f406                	sd	ra,40(sp)
    800037b4:	f022                	sd	s0,32(sp)
    800037b6:	ec26                	sd	s1,24(sp)
    800037b8:	e84a                	sd	s2,16(sp)
    800037ba:	e44e                	sd	s3,8(sp)
    800037bc:	1800                	addi	s0,sp,48
    800037be:	892a                	mv	s2,a0
    800037c0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800037c2:	0001d517          	auipc	a0,0x1d
    800037c6:	12650513          	addi	a0,a0,294 # 800208e8 <bcache>
    800037ca:	ffffd097          	auipc	ra,0xffffd
    800037ce:	3f8080e7          	jalr	1016(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800037d2:	00025497          	auipc	s1,0x25
    800037d6:	3ce4b483          	ld	s1,974(s1) # 80028ba0 <bcache+0x82b8>
    800037da:	00025797          	auipc	a5,0x25
    800037de:	37678793          	addi	a5,a5,886 # 80028b50 <bcache+0x8268>
    800037e2:	02f48f63          	beq	s1,a5,80003820 <bread+0x70>
    800037e6:	873e                	mv	a4,a5
    800037e8:	a021                	j	800037f0 <bread+0x40>
    800037ea:	68a4                	ld	s1,80(s1)
    800037ec:	02e48a63          	beq	s1,a4,80003820 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800037f0:	449c                	lw	a5,8(s1)
    800037f2:	ff279ce3          	bne	a5,s2,800037ea <bread+0x3a>
    800037f6:	44dc                	lw	a5,12(s1)
    800037f8:	ff3799e3          	bne	a5,s3,800037ea <bread+0x3a>
      b->refcnt++;
    800037fc:	40bc                	lw	a5,64(s1)
    800037fe:	2785                	addiw	a5,a5,1
    80003800:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003802:	0001d517          	auipc	a0,0x1d
    80003806:	0e650513          	addi	a0,a0,230 # 800208e8 <bcache>
    8000380a:	ffffd097          	auipc	ra,0xffffd
    8000380e:	46c080e7          	jalr	1132(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003812:	01048513          	addi	a0,s1,16
    80003816:	00001097          	auipc	ra,0x1
    8000381a:	77e080e7          	jalr	1918(ra) # 80004f94 <acquiresleep>
      return b;
    8000381e:	a8b9                	j	8000387c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003820:	00025497          	auipc	s1,0x25
    80003824:	3784b483          	ld	s1,888(s1) # 80028b98 <bcache+0x82b0>
    80003828:	00025797          	auipc	a5,0x25
    8000382c:	32878793          	addi	a5,a5,808 # 80028b50 <bcache+0x8268>
    80003830:	00f48863          	beq	s1,a5,80003840 <bread+0x90>
    80003834:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003836:	40bc                	lw	a5,64(s1)
    80003838:	cf81                	beqz	a5,80003850 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000383a:	64a4                	ld	s1,72(s1)
    8000383c:	fee49de3          	bne	s1,a4,80003836 <bread+0x86>
  panic("bget: no buffers");
    80003840:	00006517          	auipc	a0,0x6
    80003844:	10050513          	addi	a0,a0,256 # 80009940 <syscalls+0xc0>
    80003848:	ffffd097          	auipc	ra,0xffffd
    8000384c:	ce2080e7          	jalr	-798(ra) # 8000052a <panic>
      b->dev = dev;
    80003850:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003854:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003858:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000385c:	4785                	li	a5,1
    8000385e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003860:	0001d517          	auipc	a0,0x1d
    80003864:	08850513          	addi	a0,a0,136 # 800208e8 <bcache>
    80003868:	ffffd097          	auipc	ra,0xffffd
    8000386c:	40e080e7          	jalr	1038(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003870:	01048513          	addi	a0,s1,16
    80003874:	00001097          	auipc	ra,0x1
    80003878:	720080e7          	jalr	1824(ra) # 80004f94 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000387c:	409c                	lw	a5,0(s1)
    8000387e:	cb89                	beqz	a5,80003890 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003880:	8526                	mv	a0,s1
    80003882:	70a2                	ld	ra,40(sp)
    80003884:	7402                	ld	s0,32(sp)
    80003886:	64e2                	ld	s1,24(sp)
    80003888:	6942                	ld	s2,16(sp)
    8000388a:	69a2                	ld	s3,8(sp)
    8000388c:	6145                	addi	sp,sp,48
    8000388e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003890:	4581                	li	a1,0
    80003892:	8526                	mv	a0,s1
    80003894:	00003097          	auipc	ra,0x3
    80003898:	452080e7          	jalr	1106(ra) # 80006ce6 <virtio_disk_rw>
    b->valid = 1;
    8000389c:	4785                	li	a5,1
    8000389e:	c09c                	sw	a5,0(s1)
  return b;
    800038a0:	b7c5                	j	80003880 <bread+0xd0>

00000000800038a2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800038a2:	1101                	addi	sp,sp,-32
    800038a4:	ec06                	sd	ra,24(sp)
    800038a6:	e822                	sd	s0,16(sp)
    800038a8:	e426                	sd	s1,8(sp)
    800038aa:	1000                	addi	s0,sp,32
    800038ac:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800038ae:	0541                	addi	a0,a0,16
    800038b0:	00001097          	auipc	ra,0x1
    800038b4:	77e080e7          	jalr	1918(ra) # 8000502e <holdingsleep>
    800038b8:	cd01                	beqz	a0,800038d0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800038ba:	4585                	li	a1,1
    800038bc:	8526                	mv	a0,s1
    800038be:	00003097          	auipc	ra,0x3
    800038c2:	428080e7          	jalr	1064(ra) # 80006ce6 <virtio_disk_rw>
}
    800038c6:	60e2                	ld	ra,24(sp)
    800038c8:	6442                	ld	s0,16(sp)
    800038ca:	64a2                	ld	s1,8(sp)
    800038cc:	6105                	addi	sp,sp,32
    800038ce:	8082                	ret
    panic("bwrite");
    800038d0:	00006517          	auipc	a0,0x6
    800038d4:	08850513          	addi	a0,a0,136 # 80009958 <syscalls+0xd8>
    800038d8:	ffffd097          	auipc	ra,0xffffd
    800038dc:	c52080e7          	jalr	-942(ra) # 8000052a <panic>

00000000800038e0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800038e0:	1101                	addi	sp,sp,-32
    800038e2:	ec06                	sd	ra,24(sp)
    800038e4:	e822                	sd	s0,16(sp)
    800038e6:	e426                	sd	s1,8(sp)
    800038e8:	e04a                	sd	s2,0(sp)
    800038ea:	1000                	addi	s0,sp,32
    800038ec:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800038ee:	01050913          	addi	s2,a0,16
    800038f2:	854a                	mv	a0,s2
    800038f4:	00001097          	auipc	ra,0x1
    800038f8:	73a080e7          	jalr	1850(ra) # 8000502e <holdingsleep>
    800038fc:	c92d                	beqz	a0,8000396e <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800038fe:	854a                	mv	a0,s2
    80003900:	00001097          	auipc	ra,0x1
    80003904:	6ea080e7          	jalr	1770(ra) # 80004fea <releasesleep>

  acquire(&bcache.lock);
    80003908:	0001d517          	auipc	a0,0x1d
    8000390c:	fe050513          	addi	a0,a0,-32 # 800208e8 <bcache>
    80003910:	ffffd097          	auipc	ra,0xffffd
    80003914:	2b2080e7          	jalr	690(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003918:	40bc                	lw	a5,64(s1)
    8000391a:	37fd                	addiw	a5,a5,-1
    8000391c:	0007871b          	sext.w	a4,a5
    80003920:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003922:	eb05                	bnez	a4,80003952 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003924:	68bc                	ld	a5,80(s1)
    80003926:	64b8                	ld	a4,72(s1)
    80003928:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000392a:	64bc                	ld	a5,72(s1)
    8000392c:	68b8                	ld	a4,80(s1)
    8000392e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003930:	00025797          	auipc	a5,0x25
    80003934:	fb878793          	addi	a5,a5,-72 # 800288e8 <bcache+0x8000>
    80003938:	2b87b703          	ld	a4,696(a5)
    8000393c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000393e:	00025717          	auipc	a4,0x25
    80003942:	21270713          	addi	a4,a4,530 # 80028b50 <bcache+0x8268>
    80003946:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003948:	2b87b703          	ld	a4,696(a5)
    8000394c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000394e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003952:	0001d517          	auipc	a0,0x1d
    80003956:	f9650513          	addi	a0,a0,-106 # 800208e8 <bcache>
    8000395a:	ffffd097          	auipc	ra,0xffffd
    8000395e:	31c080e7          	jalr	796(ra) # 80000c76 <release>
}
    80003962:	60e2                	ld	ra,24(sp)
    80003964:	6442                	ld	s0,16(sp)
    80003966:	64a2                	ld	s1,8(sp)
    80003968:	6902                	ld	s2,0(sp)
    8000396a:	6105                	addi	sp,sp,32
    8000396c:	8082                	ret
    panic("brelse");
    8000396e:	00006517          	auipc	a0,0x6
    80003972:	ff250513          	addi	a0,a0,-14 # 80009960 <syscalls+0xe0>
    80003976:	ffffd097          	auipc	ra,0xffffd
    8000397a:	bb4080e7          	jalr	-1100(ra) # 8000052a <panic>

000000008000397e <bpin>:

void
bpin(struct buf *b) {
    8000397e:	1101                	addi	sp,sp,-32
    80003980:	ec06                	sd	ra,24(sp)
    80003982:	e822                	sd	s0,16(sp)
    80003984:	e426                	sd	s1,8(sp)
    80003986:	1000                	addi	s0,sp,32
    80003988:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000398a:	0001d517          	auipc	a0,0x1d
    8000398e:	f5e50513          	addi	a0,a0,-162 # 800208e8 <bcache>
    80003992:	ffffd097          	auipc	ra,0xffffd
    80003996:	230080e7          	jalr	560(ra) # 80000bc2 <acquire>
  b->refcnt++;
    8000399a:	40bc                	lw	a5,64(s1)
    8000399c:	2785                	addiw	a5,a5,1
    8000399e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800039a0:	0001d517          	auipc	a0,0x1d
    800039a4:	f4850513          	addi	a0,a0,-184 # 800208e8 <bcache>
    800039a8:	ffffd097          	auipc	ra,0xffffd
    800039ac:	2ce080e7          	jalr	718(ra) # 80000c76 <release>
}
    800039b0:	60e2                	ld	ra,24(sp)
    800039b2:	6442                	ld	s0,16(sp)
    800039b4:	64a2                	ld	s1,8(sp)
    800039b6:	6105                	addi	sp,sp,32
    800039b8:	8082                	ret

00000000800039ba <bunpin>:

void
bunpin(struct buf *b) {
    800039ba:	1101                	addi	sp,sp,-32
    800039bc:	ec06                	sd	ra,24(sp)
    800039be:	e822                	sd	s0,16(sp)
    800039c0:	e426                	sd	s1,8(sp)
    800039c2:	1000                	addi	s0,sp,32
    800039c4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800039c6:	0001d517          	auipc	a0,0x1d
    800039ca:	f2250513          	addi	a0,a0,-222 # 800208e8 <bcache>
    800039ce:	ffffd097          	auipc	ra,0xffffd
    800039d2:	1f4080e7          	jalr	500(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800039d6:	40bc                	lw	a5,64(s1)
    800039d8:	37fd                	addiw	a5,a5,-1
    800039da:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800039dc:	0001d517          	auipc	a0,0x1d
    800039e0:	f0c50513          	addi	a0,a0,-244 # 800208e8 <bcache>
    800039e4:	ffffd097          	auipc	ra,0xffffd
    800039e8:	292080e7          	jalr	658(ra) # 80000c76 <release>
}
    800039ec:	60e2                	ld	ra,24(sp)
    800039ee:	6442                	ld	s0,16(sp)
    800039f0:	64a2                	ld	s1,8(sp)
    800039f2:	6105                	addi	sp,sp,32
    800039f4:	8082                	ret

00000000800039f6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800039f6:	1101                	addi	sp,sp,-32
    800039f8:	ec06                	sd	ra,24(sp)
    800039fa:	e822                	sd	s0,16(sp)
    800039fc:	e426                	sd	s1,8(sp)
    800039fe:	e04a                	sd	s2,0(sp)
    80003a00:	1000                	addi	s0,sp,32
    80003a02:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003a04:	00d5d59b          	srliw	a1,a1,0xd
    80003a08:	00025797          	auipc	a5,0x25
    80003a0c:	5bc7a783          	lw	a5,1468(a5) # 80028fc4 <sb+0x1c>
    80003a10:	9dbd                	addw	a1,a1,a5
    80003a12:	00000097          	auipc	ra,0x0
    80003a16:	d9e080e7          	jalr	-610(ra) # 800037b0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003a1a:	0074f713          	andi	a4,s1,7
    80003a1e:	4785                	li	a5,1
    80003a20:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003a24:	14ce                	slli	s1,s1,0x33
    80003a26:	90d9                	srli	s1,s1,0x36
    80003a28:	00950733          	add	a4,a0,s1
    80003a2c:	05874703          	lbu	a4,88(a4)
    80003a30:	00e7f6b3          	and	a3,a5,a4
    80003a34:	c69d                	beqz	a3,80003a62 <bfree+0x6c>
    80003a36:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003a38:	94aa                	add	s1,s1,a0
    80003a3a:	fff7c793          	not	a5,a5
    80003a3e:	8ff9                	and	a5,a5,a4
    80003a40:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003a44:	00001097          	auipc	ra,0x1
    80003a48:	430080e7          	jalr	1072(ra) # 80004e74 <log_write>
  brelse(bp);
    80003a4c:	854a                	mv	a0,s2
    80003a4e:	00000097          	auipc	ra,0x0
    80003a52:	e92080e7          	jalr	-366(ra) # 800038e0 <brelse>
}
    80003a56:	60e2                	ld	ra,24(sp)
    80003a58:	6442                	ld	s0,16(sp)
    80003a5a:	64a2                	ld	s1,8(sp)
    80003a5c:	6902                	ld	s2,0(sp)
    80003a5e:	6105                	addi	sp,sp,32
    80003a60:	8082                	ret
    panic("freeing free block");
    80003a62:	00006517          	auipc	a0,0x6
    80003a66:	f0650513          	addi	a0,a0,-250 # 80009968 <syscalls+0xe8>
    80003a6a:	ffffd097          	auipc	ra,0xffffd
    80003a6e:	ac0080e7          	jalr	-1344(ra) # 8000052a <panic>

0000000080003a72 <balloc>:
{
    80003a72:	711d                	addi	sp,sp,-96
    80003a74:	ec86                	sd	ra,88(sp)
    80003a76:	e8a2                	sd	s0,80(sp)
    80003a78:	e4a6                	sd	s1,72(sp)
    80003a7a:	e0ca                	sd	s2,64(sp)
    80003a7c:	fc4e                	sd	s3,56(sp)
    80003a7e:	f852                	sd	s4,48(sp)
    80003a80:	f456                	sd	s5,40(sp)
    80003a82:	f05a                	sd	s6,32(sp)
    80003a84:	ec5e                	sd	s7,24(sp)
    80003a86:	e862                	sd	s8,16(sp)
    80003a88:	e466                	sd	s9,8(sp)
    80003a8a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003a8c:	00025797          	auipc	a5,0x25
    80003a90:	5207a783          	lw	a5,1312(a5) # 80028fac <sb+0x4>
    80003a94:	cbd1                	beqz	a5,80003b28 <balloc+0xb6>
    80003a96:	8baa                	mv	s7,a0
    80003a98:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003a9a:	00025b17          	auipc	s6,0x25
    80003a9e:	50eb0b13          	addi	s6,s6,1294 # 80028fa8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003aa2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003aa4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003aa6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003aa8:	6c89                	lui	s9,0x2
    80003aaa:	a831                	j	80003ac6 <balloc+0x54>
    brelse(bp);
    80003aac:	854a                	mv	a0,s2
    80003aae:	00000097          	auipc	ra,0x0
    80003ab2:	e32080e7          	jalr	-462(ra) # 800038e0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003ab6:	015c87bb          	addw	a5,s9,s5
    80003aba:	00078a9b          	sext.w	s5,a5
    80003abe:	004b2703          	lw	a4,4(s6)
    80003ac2:	06eaf363          	bgeu	s5,a4,80003b28 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003ac6:	41fad79b          	sraiw	a5,s5,0x1f
    80003aca:	0137d79b          	srliw	a5,a5,0x13
    80003ace:	015787bb          	addw	a5,a5,s5
    80003ad2:	40d7d79b          	sraiw	a5,a5,0xd
    80003ad6:	01cb2583          	lw	a1,28(s6)
    80003ada:	9dbd                	addw	a1,a1,a5
    80003adc:	855e                	mv	a0,s7
    80003ade:	00000097          	auipc	ra,0x0
    80003ae2:	cd2080e7          	jalr	-814(ra) # 800037b0 <bread>
    80003ae6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ae8:	004b2503          	lw	a0,4(s6)
    80003aec:	000a849b          	sext.w	s1,s5
    80003af0:	8662                	mv	a2,s8
    80003af2:	faa4fde3          	bgeu	s1,a0,80003aac <balloc+0x3a>
      m = 1 << (bi % 8);
    80003af6:	41f6579b          	sraiw	a5,a2,0x1f
    80003afa:	01d7d69b          	srliw	a3,a5,0x1d
    80003afe:	00c6873b          	addw	a4,a3,a2
    80003b02:	00777793          	andi	a5,a4,7
    80003b06:	9f95                	subw	a5,a5,a3
    80003b08:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003b0c:	4037571b          	sraiw	a4,a4,0x3
    80003b10:	00e906b3          	add	a3,s2,a4
    80003b14:	0586c683          	lbu	a3,88(a3)
    80003b18:	00d7f5b3          	and	a1,a5,a3
    80003b1c:	cd91                	beqz	a1,80003b38 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b1e:	2605                	addiw	a2,a2,1
    80003b20:	2485                	addiw	s1,s1,1
    80003b22:	fd4618e3          	bne	a2,s4,80003af2 <balloc+0x80>
    80003b26:	b759                	j	80003aac <balloc+0x3a>
  panic("balloc: out of blocks");
    80003b28:	00006517          	auipc	a0,0x6
    80003b2c:	e5850513          	addi	a0,a0,-424 # 80009980 <syscalls+0x100>
    80003b30:	ffffd097          	auipc	ra,0xffffd
    80003b34:	9fa080e7          	jalr	-1542(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003b38:	974a                	add	a4,a4,s2
    80003b3a:	8fd5                	or	a5,a5,a3
    80003b3c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003b40:	854a                	mv	a0,s2
    80003b42:	00001097          	auipc	ra,0x1
    80003b46:	332080e7          	jalr	818(ra) # 80004e74 <log_write>
        brelse(bp);
    80003b4a:	854a                	mv	a0,s2
    80003b4c:	00000097          	auipc	ra,0x0
    80003b50:	d94080e7          	jalr	-620(ra) # 800038e0 <brelse>
  bp = bread(dev, bno);
    80003b54:	85a6                	mv	a1,s1
    80003b56:	855e                	mv	a0,s7
    80003b58:	00000097          	auipc	ra,0x0
    80003b5c:	c58080e7          	jalr	-936(ra) # 800037b0 <bread>
    80003b60:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003b62:	40000613          	li	a2,1024
    80003b66:	4581                	li	a1,0
    80003b68:	05850513          	addi	a0,a0,88
    80003b6c:	ffffd097          	auipc	ra,0xffffd
    80003b70:	152080e7          	jalr	338(ra) # 80000cbe <memset>
  log_write(bp);
    80003b74:	854a                	mv	a0,s2
    80003b76:	00001097          	auipc	ra,0x1
    80003b7a:	2fe080e7          	jalr	766(ra) # 80004e74 <log_write>
  brelse(bp);
    80003b7e:	854a                	mv	a0,s2
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	d60080e7          	jalr	-672(ra) # 800038e0 <brelse>
}
    80003b88:	8526                	mv	a0,s1
    80003b8a:	60e6                	ld	ra,88(sp)
    80003b8c:	6446                	ld	s0,80(sp)
    80003b8e:	64a6                	ld	s1,72(sp)
    80003b90:	6906                	ld	s2,64(sp)
    80003b92:	79e2                	ld	s3,56(sp)
    80003b94:	7a42                	ld	s4,48(sp)
    80003b96:	7aa2                	ld	s5,40(sp)
    80003b98:	7b02                	ld	s6,32(sp)
    80003b9a:	6be2                	ld	s7,24(sp)
    80003b9c:	6c42                	ld	s8,16(sp)
    80003b9e:	6ca2                	ld	s9,8(sp)
    80003ba0:	6125                	addi	sp,sp,96
    80003ba2:	8082                	ret

0000000080003ba4 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003ba4:	7179                	addi	sp,sp,-48
    80003ba6:	f406                	sd	ra,40(sp)
    80003ba8:	f022                	sd	s0,32(sp)
    80003baa:	ec26                	sd	s1,24(sp)
    80003bac:	e84a                	sd	s2,16(sp)
    80003bae:	e44e                	sd	s3,8(sp)
    80003bb0:	e052                	sd	s4,0(sp)
    80003bb2:	1800                	addi	s0,sp,48
    80003bb4:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003bb6:	47ad                	li	a5,11
    80003bb8:	04b7fe63          	bgeu	a5,a1,80003c14 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003bbc:	ff45849b          	addiw	s1,a1,-12
    80003bc0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003bc4:	0ff00793          	li	a5,255
    80003bc8:	0ae7e463          	bltu	a5,a4,80003c70 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003bcc:	08052583          	lw	a1,128(a0)
    80003bd0:	c5b5                	beqz	a1,80003c3c <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003bd2:	00092503          	lw	a0,0(s2)
    80003bd6:	00000097          	auipc	ra,0x0
    80003bda:	bda080e7          	jalr	-1062(ra) # 800037b0 <bread>
    80003bde:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003be0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003be4:	02049713          	slli	a4,s1,0x20
    80003be8:	01e75593          	srli	a1,a4,0x1e
    80003bec:	00b784b3          	add	s1,a5,a1
    80003bf0:	0004a983          	lw	s3,0(s1)
    80003bf4:	04098e63          	beqz	s3,80003c50 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003bf8:	8552                	mv	a0,s4
    80003bfa:	00000097          	auipc	ra,0x0
    80003bfe:	ce6080e7          	jalr	-794(ra) # 800038e0 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003c02:	854e                	mv	a0,s3
    80003c04:	70a2                	ld	ra,40(sp)
    80003c06:	7402                	ld	s0,32(sp)
    80003c08:	64e2                	ld	s1,24(sp)
    80003c0a:	6942                	ld	s2,16(sp)
    80003c0c:	69a2                	ld	s3,8(sp)
    80003c0e:	6a02                	ld	s4,0(sp)
    80003c10:	6145                	addi	sp,sp,48
    80003c12:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003c14:	02059793          	slli	a5,a1,0x20
    80003c18:	01e7d593          	srli	a1,a5,0x1e
    80003c1c:	00b504b3          	add	s1,a0,a1
    80003c20:	0504a983          	lw	s3,80(s1)
    80003c24:	fc099fe3          	bnez	s3,80003c02 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003c28:	4108                	lw	a0,0(a0)
    80003c2a:	00000097          	auipc	ra,0x0
    80003c2e:	e48080e7          	jalr	-440(ra) # 80003a72 <balloc>
    80003c32:	0005099b          	sext.w	s3,a0
    80003c36:	0534a823          	sw	s3,80(s1)
    80003c3a:	b7e1                	j	80003c02 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003c3c:	4108                	lw	a0,0(a0)
    80003c3e:	00000097          	auipc	ra,0x0
    80003c42:	e34080e7          	jalr	-460(ra) # 80003a72 <balloc>
    80003c46:	0005059b          	sext.w	a1,a0
    80003c4a:	08b92023          	sw	a1,128(s2)
    80003c4e:	b751                	j	80003bd2 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003c50:	00092503          	lw	a0,0(s2)
    80003c54:	00000097          	auipc	ra,0x0
    80003c58:	e1e080e7          	jalr	-482(ra) # 80003a72 <balloc>
    80003c5c:	0005099b          	sext.w	s3,a0
    80003c60:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003c64:	8552                	mv	a0,s4
    80003c66:	00001097          	auipc	ra,0x1
    80003c6a:	20e080e7          	jalr	526(ra) # 80004e74 <log_write>
    80003c6e:	b769                	j	80003bf8 <bmap+0x54>
  panic("bmap: out of range");
    80003c70:	00006517          	auipc	a0,0x6
    80003c74:	d2850513          	addi	a0,a0,-728 # 80009998 <syscalls+0x118>
    80003c78:	ffffd097          	auipc	ra,0xffffd
    80003c7c:	8b2080e7          	jalr	-1870(ra) # 8000052a <panic>

0000000080003c80 <iget>:
{
    80003c80:	7179                	addi	sp,sp,-48
    80003c82:	f406                	sd	ra,40(sp)
    80003c84:	f022                	sd	s0,32(sp)
    80003c86:	ec26                	sd	s1,24(sp)
    80003c88:	e84a                	sd	s2,16(sp)
    80003c8a:	e44e                	sd	s3,8(sp)
    80003c8c:	e052                	sd	s4,0(sp)
    80003c8e:	1800                	addi	s0,sp,48
    80003c90:	89aa                	mv	s3,a0
    80003c92:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003c94:	00025517          	auipc	a0,0x25
    80003c98:	33450513          	addi	a0,a0,820 # 80028fc8 <itable>
    80003c9c:	ffffd097          	auipc	ra,0xffffd
    80003ca0:	f26080e7          	jalr	-218(ra) # 80000bc2 <acquire>
  empty = 0;
    80003ca4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ca6:	00025497          	auipc	s1,0x25
    80003caa:	33a48493          	addi	s1,s1,826 # 80028fe0 <itable+0x18>
    80003cae:	00027697          	auipc	a3,0x27
    80003cb2:	dc268693          	addi	a3,a3,-574 # 8002aa70 <log>
    80003cb6:	a039                	j	80003cc4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003cb8:	02090b63          	beqz	s2,80003cee <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003cbc:	08848493          	addi	s1,s1,136
    80003cc0:	02d48a63          	beq	s1,a3,80003cf4 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003cc4:	449c                	lw	a5,8(s1)
    80003cc6:	fef059e3          	blez	a5,80003cb8 <iget+0x38>
    80003cca:	4098                	lw	a4,0(s1)
    80003ccc:	ff3716e3          	bne	a4,s3,80003cb8 <iget+0x38>
    80003cd0:	40d8                	lw	a4,4(s1)
    80003cd2:	ff4713e3          	bne	a4,s4,80003cb8 <iget+0x38>
      ip->ref++;
    80003cd6:	2785                	addiw	a5,a5,1
    80003cd8:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003cda:	00025517          	auipc	a0,0x25
    80003cde:	2ee50513          	addi	a0,a0,750 # 80028fc8 <itable>
    80003ce2:	ffffd097          	auipc	ra,0xffffd
    80003ce6:	f94080e7          	jalr	-108(ra) # 80000c76 <release>
      return ip;
    80003cea:	8926                	mv	s2,s1
    80003cec:	a03d                	j	80003d1a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003cee:	f7f9                	bnez	a5,80003cbc <iget+0x3c>
    80003cf0:	8926                	mv	s2,s1
    80003cf2:	b7e9                	j	80003cbc <iget+0x3c>
  if(empty == 0)
    80003cf4:	02090c63          	beqz	s2,80003d2c <iget+0xac>
  ip->dev = dev;
    80003cf8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003cfc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003d00:	4785                	li	a5,1
    80003d02:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003d06:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003d0a:	00025517          	auipc	a0,0x25
    80003d0e:	2be50513          	addi	a0,a0,702 # 80028fc8 <itable>
    80003d12:	ffffd097          	auipc	ra,0xffffd
    80003d16:	f64080e7          	jalr	-156(ra) # 80000c76 <release>
}
    80003d1a:	854a                	mv	a0,s2
    80003d1c:	70a2                	ld	ra,40(sp)
    80003d1e:	7402                	ld	s0,32(sp)
    80003d20:	64e2                	ld	s1,24(sp)
    80003d22:	6942                	ld	s2,16(sp)
    80003d24:	69a2                	ld	s3,8(sp)
    80003d26:	6a02                	ld	s4,0(sp)
    80003d28:	6145                	addi	sp,sp,48
    80003d2a:	8082                	ret
    panic("iget: no inodes");
    80003d2c:	00006517          	auipc	a0,0x6
    80003d30:	c8450513          	addi	a0,a0,-892 # 800099b0 <syscalls+0x130>
    80003d34:	ffffc097          	auipc	ra,0xffffc
    80003d38:	7f6080e7          	jalr	2038(ra) # 8000052a <panic>

0000000080003d3c <fsinit>:
fsinit(int dev) {
    80003d3c:	7179                	addi	sp,sp,-48
    80003d3e:	f406                	sd	ra,40(sp)
    80003d40:	f022                	sd	s0,32(sp)
    80003d42:	ec26                	sd	s1,24(sp)
    80003d44:	e84a                	sd	s2,16(sp)
    80003d46:	e44e                	sd	s3,8(sp)
    80003d48:	1800                	addi	s0,sp,48
    80003d4a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003d4c:	4585                	li	a1,1
    80003d4e:	00000097          	auipc	ra,0x0
    80003d52:	a62080e7          	jalr	-1438(ra) # 800037b0 <bread>
    80003d56:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003d58:	00025997          	auipc	s3,0x25
    80003d5c:	25098993          	addi	s3,s3,592 # 80028fa8 <sb>
    80003d60:	02000613          	li	a2,32
    80003d64:	05850593          	addi	a1,a0,88
    80003d68:	854e                	mv	a0,s3
    80003d6a:	ffffd097          	auipc	ra,0xffffd
    80003d6e:	fb0080e7          	jalr	-80(ra) # 80000d1a <memmove>
  brelse(bp);
    80003d72:	8526                	mv	a0,s1
    80003d74:	00000097          	auipc	ra,0x0
    80003d78:	b6c080e7          	jalr	-1172(ra) # 800038e0 <brelse>
  if(sb.magic != FSMAGIC)
    80003d7c:	0009a703          	lw	a4,0(s3)
    80003d80:	102037b7          	lui	a5,0x10203
    80003d84:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003d88:	02f71263          	bne	a4,a5,80003dac <fsinit+0x70>
  initlog(dev, &sb);
    80003d8c:	00025597          	auipc	a1,0x25
    80003d90:	21c58593          	addi	a1,a1,540 # 80028fa8 <sb>
    80003d94:	854a                	mv	a0,s2
    80003d96:	00001097          	auipc	ra,0x1
    80003d9a:	e60080e7          	jalr	-416(ra) # 80004bf6 <initlog>
}
    80003d9e:	70a2                	ld	ra,40(sp)
    80003da0:	7402                	ld	s0,32(sp)
    80003da2:	64e2                	ld	s1,24(sp)
    80003da4:	6942                	ld	s2,16(sp)
    80003da6:	69a2                	ld	s3,8(sp)
    80003da8:	6145                	addi	sp,sp,48
    80003daa:	8082                	ret
    panic("invalid file system");
    80003dac:	00006517          	auipc	a0,0x6
    80003db0:	c1450513          	addi	a0,a0,-1004 # 800099c0 <syscalls+0x140>
    80003db4:	ffffc097          	auipc	ra,0xffffc
    80003db8:	776080e7          	jalr	1910(ra) # 8000052a <panic>

0000000080003dbc <iinit>:
{
    80003dbc:	7179                	addi	sp,sp,-48
    80003dbe:	f406                	sd	ra,40(sp)
    80003dc0:	f022                	sd	s0,32(sp)
    80003dc2:	ec26                	sd	s1,24(sp)
    80003dc4:	e84a                	sd	s2,16(sp)
    80003dc6:	e44e                	sd	s3,8(sp)
    80003dc8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003dca:	00006597          	auipc	a1,0x6
    80003dce:	c0e58593          	addi	a1,a1,-1010 # 800099d8 <syscalls+0x158>
    80003dd2:	00025517          	auipc	a0,0x25
    80003dd6:	1f650513          	addi	a0,a0,502 # 80028fc8 <itable>
    80003dda:	ffffd097          	auipc	ra,0xffffd
    80003dde:	d58080e7          	jalr	-680(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003de2:	00025497          	auipc	s1,0x25
    80003de6:	20e48493          	addi	s1,s1,526 # 80028ff0 <itable+0x28>
    80003dea:	00027997          	auipc	s3,0x27
    80003dee:	c9698993          	addi	s3,s3,-874 # 8002aa80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003df2:	00006917          	auipc	s2,0x6
    80003df6:	bee90913          	addi	s2,s2,-1042 # 800099e0 <syscalls+0x160>
    80003dfa:	85ca                	mv	a1,s2
    80003dfc:	8526                	mv	a0,s1
    80003dfe:	00001097          	auipc	ra,0x1
    80003e02:	15c080e7          	jalr	348(ra) # 80004f5a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003e06:	08848493          	addi	s1,s1,136
    80003e0a:	ff3498e3          	bne	s1,s3,80003dfa <iinit+0x3e>
}
    80003e0e:	70a2                	ld	ra,40(sp)
    80003e10:	7402                	ld	s0,32(sp)
    80003e12:	64e2                	ld	s1,24(sp)
    80003e14:	6942                	ld	s2,16(sp)
    80003e16:	69a2                	ld	s3,8(sp)
    80003e18:	6145                	addi	sp,sp,48
    80003e1a:	8082                	ret

0000000080003e1c <ialloc>:
{
    80003e1c:	715d                	addi	sp,sp,-80
    80003e1e:	e486                	sd	ra,72(sp)
    80003e20:	e0a2                	sd	s0,64(sp)
    80003e22:	fc26                	sd	s1,56(sp)
    80003e24:	f84a                	sd	s2,48(sp)
    80003e26:	f44e                	sd	s3,40(sp)
    80003e28:	f052                	sd	s4,32(sp)
    80003e2a:	ec56                	sd	s5,24(sp)
    80003e2c:	e85a                	sd	s6,16(sp)
    80003e2e:	e45e                	sd	s7,8(sp)
    80003e30:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e32:	00025717          	auipc	a4,0x25
    80003e36:	18272703          	lw	a4,386(a4) # 80028fb4 <sb+0xc>
    80003e3a:	4785                	li	a5,1
    80003e3c:	04e7fa63          	bgeu	a5,a4,80003e90 <ialloc+0x74>
    80003e40:	8aaa                	mv	s5,a0
    80003e42:	8bae                	mv	s7,a1
    80003e44:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003e46:	00025a17          	auipc	s4,0x25
    80003e4a:	162a0a13          	addi	s4,s4,354 # 80028fa8 <sb>
    80003e4e:	00048b1b          	sext.w	s6,s1
    80003e52:	0044d793          	srli	a5,s1,0x4
    80003e56:	018a2583          	lw	a1,24(s4)
    80003e5a:	9dbd                	addw	a1,a1,a5
    80003e5c:	8556                	mv	a0,s5
    80003e5e:	00000097          	auipc	ra,0x0
    80003e62:	952080e7          	jalr	-1710(ra) # 800037b0 <bread>
    80003e66:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003e68:	05850993          	addi	s3,a0,88
    80003e6c:	00f4f793          	andi	a5,s1,15
    80003e70:	079a                	slli	a5,a5,0x6
    80003e72:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003e74:	00099783          	lh	a5,0(s3)
    80003e78:	c785                	beqz	a5,80003ea0 <ialloc+0x84>
    brelse(bp);
    80003e7a:	00000097          	auipc	ra,0x0
    80003e7e:	a66080e7          	jalr	-1434(ra) # 800038e0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e82:	0485                	addi	s1,s1,1
    80003e84:	00ca2703          	lw	a4,12(s4)
    80003e88:	0004879b          	sext.w	a5,s1
    80003e8c:	fce7e1e3          	bltu	a5,a4,80003e4e <ialloc+0x32>
  panic("ialloc: no inodes");
    80003e90:	00006517          	auipc	a0,0x6
    80003e94:	b5850513          	addi	a0,a0,-1192 # 800099e8 <syscalls+0x168>
    80003e98:	ffffc097          	auipc	ra,0xffffc
    80003e9c:	692080e7          	jalr	1682(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003ea0:	04000613          	li	a2,64
    80003ea4:	4581                	li	a1,0
    80003ea6:	854e                	mv	a0,s3
    80003ea8:	ffffd097          	auipc	ra,0xffffd
    80003eac:	e16080e7          	jalr	-490(ra) # 80000cbe <memset>
      dip->type = type;
    80003eb0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003eb4:	854a                	mv	a0,s2
    80003eb6:	00001097          	auipc	ra,0x1
    80003eba:	fbe080e7          	jalr	-66(ra) # 80004e74 <log_write>
      brelse(bp);
    80003ebe:	854a                	mv	a0,s2
    80003ec0:	00000097          	auipc	ra,0x0
    80003ec4:	a20080e7          	jalr	-1504(ra) # 800038e0 <brelse>
      return iget(dev, inum);
    80003ec8:	85da                	mv	a1,s6
    80003eca:	8556                	mv	a0,s5
    80003ecc:	00000097          	auipc	ra,0x0
    80003ed0:	db4080e7          	jalr	-588(ra) # 80003c80 <iget>
}
    80003ed4:	60a6                	ld	ra,72(sp)
    80003ed6:	6406                	ld	s0,64(sp)
    80003ed8:	74e2                	ld	s1,56(sp)
    80003eda:	7942                	ld	s2,48(sp)
    80003edc:	79a2                	ld	s3,40(sp)
    80003ede:	7a02                	ld	s4,32(sp)
    80003ee0:	6ae2                	ld	s5,24(sp)
    80003ee2:	6b42                	ld	s6,16(sp)
    80003ee4:	6ba2                	ld	s7,8(sp)
    80003ee6:	6161                	addi	sp,sp,80
    80003ee8:	8082                	ret

0000000080003eea <iupdate>:
{
    80003eea:	1101                	addi	sp,sp,-32
    80003eec:	ec06                	sd	ra,24(sp)
    80003eee:	e822                	sd	s0,16(sp)
    80003ef0:	e426                	sd	s1,8(sp)
    80003ef2:	e04a                	sd	s2,0(sp)
    80003ef4:	1000                	addi	s0,sp,32
    80003ef6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ef8:	415c                	lw	a5,4(a0)
    80003efa:	0047d79b          	srliw	a5,a5,0x4
    80003efe:	00025597          	auipc	a1,0x25
    80003f02:	0c25a583          	lw	a1,194(a1) # 80028fc0 <sb+0x18>
    80003f06:	9dbd                	addw	a1,a1,a5
    80003f08:	4108                	lw	a0,0(a0)
    80003f0a:	00000097          	auipc	ra,0x0
    80003f0e:	8a6080e7          	jalr	-1882(ra) # 800037b0 <bread>
    80003f12:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003f14:	05850793          	addi	a5,a0,88
    80003f18:	40c8                	lw	a0,4(s1)
    80003f1a:	893d                	andi	a0,a0,15
    80003f1c:	051a                	slli	a0,a0,0x6
    80003f1e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003f20:	04449703          	lh	a4,68(s1)
    80003f24:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003f28:	04649703          	lh	a4,70(s1)
    80003f2c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003f30:	04849703          	lh	a4,72(s1)
    80003f34:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003f38:	04a49703          	lh	a4,74(s1)
    80003f3c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003f40:	44f8                	lw	a4,76(s1)
    80003f42:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003f44:	03400613          	li	a2,52
    80003f48:	05048593          	addi	a1,s1,80
    80003f4c:	0531                	addi	a0,a0,12
    80003f4e:	ffffd097          	auipc	ra,0xffffd
    80003f52:	dcc080e7          	jalr	-564(ra) # 80000d1a <memmove>
  log_write(bp);
    80003f56:	854a                	mv	a0,s2
    80003f58:	00001097          	auipc	ra,0x1
    80003f5c:	f1c080e7          	jalr	-228(ra) # 80004e74 <log_write>
  brelse(bp);
    80003f60:	854a                	mv	a0,s2
    80003f62:	00000097          	auipc	ra,0x0
    80003f66:	97e080e7          	jalr	-1666(ra) # 800038e0 <brelse>
}
    80003f6a:	60e2                	ld	ra,24(sp)
    80003f6c:	6442                	ld	s0,16(sp)
    80003f6e:	64a2                	ld	s1,8(sp)
    80003f70:	6902                	ld	s2,0(sp)
    80003f72:	6105                	addi	sp,sp,32
    80003f74:	8082                	ret

0000000080003f76 <idup>:
{
    80003f76:	1101                	addi	sp,sp,-32
    80003f78:	ec06                	sd	ra,24(sp)
    80003f7a:	e822                	sd	s0,16(sp)
    80003f7c:	e426                	sd	s1,8(sp)
    80003f7e:	1000                	addi	s0,sp,32
    80003f80:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f82:	00025517          	auipc	a0,0x25
    80003f86:	04650513          	addi	a0,a0,70 # 80028fc8 <itable>
    80003f8a:	ffffd097          	auipc	ra,0xffffd
    80003f8e:	c38080e7          	jalr	-968(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003f92:	449c                	lw	a5,8(s1)
    80003f94:	2785                	addiw	a5,a5,1
    80003f96:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f98:	00025517          	auipc	a0,0x25
    80003f9c:	03050513          	addi	a0,a0,48 # 80028fc8 <itable>
    80003fa0:	ffffd097          	auipc	ra,0xffffd
    80003fa4:	cd6080e7          	jalr	-810(ra) # 80000c76 <release>
}
    80003fa8:	8526                	mv	a0,s1
    80003faa:	60e2                	ld	ra,24(sp)
    80003fac:	6442                	ld	s0,16(sp)
    80003fae:	64a2                	ld	s1,8(sp)
    80003fb0:	6105                	addi	sp,sp,32
    80003fb2:	8082                	ret

0000000080003fb4 <ilock>:
{
    80003fb4:	1101                	addi	sp,sp,-32
    80003fb6:	ec06                	sd	ra,24(sp)
    80003fb8:	e822                	sd	s0,16(sp)
    80003fba:	e426                	sd	s1,8(sp)
    80003fbc:	e04a                	sd	s2,0(sp)
    80003fbe:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003fc0:	c115                	beqz	a0,80003fe4 <ilock+0x30>
    80003fc2:	84aa                	mv	s1,a0
    80003fc4:	451c                	lw	a5,8(a0)
    80003fc6:	00f05f63          	blez	a5,80003fe4 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003fca:	0541                	addi	a0,a0,16
    80003fcc:	00001097          	auipc	ra,0x1
    80003fd0:	fc8080e7          	jalr	-56(ra) # 80004f94 <acquiresleep>
  if(ip->valid == 0){
    80003fd4:	40bc                	lw	a5,64(s1)
    80003fd6:	cf99                	beqz	a5,80003ff4 <ilock+0x40>
}
    80003fd8:	60e2                	ld	ra,24(sp)
    80003fda:	6442                	ld	s0,16(sp)
    80003fdc:	64a2                	ld	s1,8(sp)
    80003fde:	6902                	ld	s2,0(sp)
    80003fe0:	6105                	addi	sp,sp,32
    80003fe2:	8082                	ret
    panic("ilock");
    80003fe4:	00006517          	auipc	a0,0x6
    80003fe8:	a1c50513          	addi	a0,a0,-1508 # 80009a00 <syscalls+0x180>
    80003fec:	ffffc097          	auipc	ra,0xffffc
    80003ff0:	53e080e7          	jalr	1342(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ff4:	40dc                	lw	a5,4(s1)
    80003ff6:	0047d79b          	srliw	a5,a5,0x4
    80003ffa:	00025597          	auipc	a1,0x25
    80003ffe:	fc65a583          	lw	a1,-58(a1) # 80028fc0 <sb+0x18>
    80004002:	9dbd                	addw	a1,a1,a5
    80004004:	4088                	lw	a0,0(s1)
    80004006:	fffff097          	auipc	ra,0xfffff
    8000400a:	7aa080e7          	jalr	1962(ra) # 800037b0 <bread>
    8000400e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004010:	05850593          	addi	a1,a0,88
    80004014:	40dc                	lw	a5,4(s1)
    80004016:	8bbd                	andi	a5,a5,15
    80004018:	079a                	slli	a5,a5,0x6
    8000401a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000401c:	00059783          	lh	a5,0(a1)
    80004020:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004024:	00259783          	lh	a5,2(a1)
    80004028:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000402c:	00459783          	lh	a5,4(a1)
    80004030:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004034:	00659783          	lh	a5,6(a1)
    80004038:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000403c:	459c                	lw	a5,8(a1)
    8000403e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004040:	03400613          	li	a2,52
    80004044:	05b1                	addi	a1,a1,12
    80004046:	05048513          	addi	a0,s1,80
    8000404a:	ffffd097          	auipc	ra,0xffffd
    8000404e:	cd0080e7          	jalr	-816(ra) # 80000d1a <memmove>
    brelse(bp);
    80004052:	854a                	mv	a0,s2
    80004054:	00000097          	auipc	ra,0x0
    80004058:	88c080e7          	jalr	-1908(ra) # 800038e0 <brelse>
    ip->valid = 1;
    8000405c:	4785                	li	a5,1
    8000405e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004060:	04449783          	lh	a5,68(s1)
    80004064:	fbb5                	bnez	a5,80003fd8 <ilock+0x24>
      panic("ilock: no type");
    80004066:	00006517          	auipc	a0,0x6
    8000406a:	9a250513          	addi	a0,a0,-1630 # 80009a08 <syscalls+0x188>
    8000406e:	ffffc097          	auipc	ra,0xffffc
    80004072:	4bc080e7          	jalr	1212(ra) # 8000052a <panic>

0000000080004076 <iunlock>:
{
    80004076:	1101                	addi	sp,sp,-32
    80004078:	ec06                	sd	ra,24(sp)
    8000407a:	e822                	sd	s0,16(sp)
    8000407c:	e426                	sd	s1,8(sp)
    8000407e:	e04a                	sd	s2,0(sp)
    80004080:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004082:	c905                	beqz	a0,800040b2 <iunlock+0x3c>
    80004084:	84aa                	mv	s1,a0
    80004086:	01050913          	addi	s2,a0,16
    8000408a:	854a                	mv	a0,s2
    8000408c:	00001097          	auipc	ra,0x1
    80004090:	fa2080e7          	jalr	-94(ra) # 8000502e <holdingsleep>
    80004094:	cd19                	beqz	a0,800040b2 <iunlock+0x3c>
    80004096:	449c                	lw	a5,8(s1)
    80004098:	00f05d63          	blez	a5,800040b2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000409c:	854a                	mv	a0,s2
    8000409e:	00001097          	auipc	ra,0x1
    800040a2:	f4c080e7          	jalr	-180(ra) # 80004fea <releasesleep>
}
    800040a6:	60e2                	ld	ra,24(sp)
    800040a8:	6442                	ld	s0,16(sp)
    800040aa:	64a2                	ld	s1,8(sp)
    800040ac:	6902                	ld	s2,0(sp)
    800040ae:	6105                	addi	sp,sp,32
    800040b0:	8082                	ret
    panic("iunlock");
    800040b2:	00006517          	auipc	a0,0x6
    800040b6:	96650513          	addi	a0,a0,-1690 # 80009a18 <syscalls+0x198>
    800040ba:	ffffc097          	auipc	ra,0xffffc
    800040be:	470080e7          	jalr	1136(ra) # 8000052a <panic>

00000000800040c2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800040c2:	7179                	addi	sp,sp,-48
    800040c4:	f406                	sd	ra,40(sp)
    800040c6:	f022                	sd	s0,32(sp)
    800040c8:	ec26                	sd	s1,24(sp)
    800040ca:	e84a                	sd	s2,16(sp)
    800040cc:	e44e                	sd	s3,8(sp)
    800040ce:	e052                	sd	s4,0(sp)
    800040d0:	1800                	addi	s0,sp,48
    800040d2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800040d4:	05050493          	addi	s1,a0,80
    800040d8:	08050913          	addi	s2,a0,128
    800040dc:	a021                	j	800040e4 <itrunc+0x22>
    800040de:	0491                	addi	s1,s1,4
    800040e0:	01248d63          	beq	s1,s2,800040fa <itrunc+0x38>
    if(ip->addrs[i]){
    800040e4:	408c                	lw	a1,0(s1)
    800040e6:	dde5                	beqz	a1,800040de <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800040e8:	0009a503          	lw	a0,0(s3)
    800040ec:	00000097          	auipc	ra,0x0
    800040f0:	90a080e7          	jalr	-1782(ra) # 800039f6 <bfree>
      ip->addrs[i] = 0;
    800040f4:	0004a023          	sw	zero,0(s1)
    800040f8:	b7dd                	j	800040de <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800040fa:	0809a583          	lw	a1,128(s3)
    800040fe:	e185                	bnez	a1,8000411e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004100:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004104:	854e                	mv	a0,s3
    80004106:	00000097          	auipc	ra,0x0
    8000410a:	de4080e7          	jalr	-540(ra) # 80003eea <iupdate>
}
    8000410e:	70a2                	ld	ra,40(sp)
    80004110:	7402                	ld	s0,32(sp)
    80004112:	64e2                	ld	s1,24(sp)
    80004114:	6942                	ld	s2,16(sp)
    80004116:	69a2                	ld	s3,8(sp)
    80004118:	6a02                	ld	s4,0(sp)
    8000411a:	6145                	addi	sp,sp,48
    8000411c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000411e:	0009a503          	lw	a0,0(s3)
    80004122:	fffff097          	auipc	ra,0xfffff
    80004126:	68e080e7          	jalr	1678(ra) # 800037b0 <bread>
    8000412a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000412c:	05850493          	addi	s1,a0,88
    80004130:	45850913          	addi	s2,a0,1112
    80004134:	a021                	j	8000413c <itrunc+0x7a>
    80004136:	0491                	addi	s1,s1,4
    80004138:	01248b63          	beq	s1,s2,8000414e <itrunc+0x8c>
      if(a[j])
    8000413c:	408c                	lw	a1,0(s1)
    8000413e:	dde5                	beqz	a1,80004136 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80004140:	0009a503          	lw	a0,0(s3)
    80004144:	00000097          	auipc	ra,0x0
    80004148:	8b2080e7          	jalr	-1870(ra) # 800039f6 <bfree>
    8000414c:	b7ed                	j	80004136 <itrunc+0x74>
    brelse(bp);
    8000414e:	8552                	mv	a0,s4
    80004150:	fffff097          	auipc	ra,0xfffff
    80004154:	790080e7          	jalr	1936(ra) # 800038e0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004158:	0809a583          	lw	a1,128(s3)
    8000415c:	0009a503          	lw	a0,0(s3)
    80004160:	00000097          	auipc	ra,0x0
    80004164:	896080e7          	jalr	-1898(ra) # 800039f6 <bfree>
    ip->addrs[NDIRECT] = 0;
    80004168:	0809a023          	sw	zero,128(s3)
    8000416c:	bf51                	j	80004100 <itrunc+0x3e>

000000008000416e <iput>:
{
    8000416e:	1101                	addi	sp,sp,-32
    80004170:	ec06                	sd	ra,24(sp)
    80004172:	e822                	sd	s0,16(sp)
    80004174:	e426                	sd	s1,8(sp)
    80004176:	e04a                	sd	s2,0(sp)
    80004178:	1000                	addi	s0,sp,32
    8000417a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000417c:	00025517          	auipc	a0,0x25
    80004180:	e4c50513          	addi	a0,a0,-436 # 80028fc8 <itable>
    80004184:	ffffd097          	auipc	ra,0xffffd
    80004188:	a3e080e7          	jalr	-1474(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000418c:	4498                	lw	a4,8(s1)
    8000418e:	4785                	li	a5,1
    80004190:	02f70363          	beq	a4,a5,800041b6 <iput+0x48>
  ip->ref--;
    80004194:	449c                	lw	a5,8(s1)
    80004196:	37fd                	addiw	a5,a5,-1
    80004198:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000419a:	00025517          	auipc	a0,0x25
    8000419e:	e2e50513          	addi	a0,a0,-466 # 80028fc8 <itable>
    800041a2:	ffffd097          	auipc	ra,0xffffd
    800041a6:	ad4080e7          	jalr	-1324(ra) # 80000c76 <release>
}
    800041aa:	60e2                	ld	ra,24(sp)
    800041ac:	6442                	ld	s0,16(sp)
    800041ae:	64a2                	ld	s1,8(sp)
    800041b0:	6902                	ld	s2,0(sp)
    800041b2:	6105                	addi	sp,sp,32
    800041b4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800041b6:	40bc                	lw	a5,64(s1)
    800041b8:	dff1                	beqz	a5,80004194 <iput+0x26>
    800041ba:	04a49783          	lh	a5,74(s1)
    800041be:	fbf9                	bnez	a5,80004194 <iput+0x26>
    acquiresleep(&ip->lock);
    800041c0:	01048913          	addi	s2,s1,16
    800041c4:	854a                	mv	a0,s2
    800041c6:	00001097          	auipc	ra,0x1
    800041ca:	dce080e7          	jalr	-562(ra) # 80004f94 <acquiresleep>
    release(&itable.lock);
    800041ce:	00025517          	auipc	a0,0x25
    800041d2:	dfa50513          	addi	a0,a0,-518 # 80028fc8 <itable>
    800041d6:	ffffd097          	auipc	ra,0xffffd
    800041da:	aa0080e7          	jalr	-1376(ra) # 80000c76 <release>
    itrunc(ip);
    800041de:	8526                	mv	a0,s1
    800041e0:	00000097          	auipc	ra,0x0
    800041e4:	ee2080e7          	jalr	-286(ra) # 800040c2 <itrunc>
    ip->type = 0;
    800041e8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800041ec:	8526                	mv	a0,s1
    800041ee:	00000097          	auipc	ra,0x0
    800041f2:	cfc080e7          	jalr	-772(ra) # 80003eea <iupdate>
    ip->valid = 0;
    800041f6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800041fa:	854a                	mv	a0,s2
    800041fc:	00001097          	auipc	ra,0x1
    80004200:	dee080e7          	jalr	-530(ra) # 80004fea <releasesleep>
    acquire(&itable.lock);
    80004204:	00025517          	auipc	a0,0x25
    80004208:	dc450513          	addi	a0,a0,-572 # 80028fc8 <itable>
    8000420c:	ffffd097          	auipc	ra,0xffffd
    80004210:	9b6080e7          	jalr	-1610(ra) # 80000bc2 <acquire>
    80004214:	b741                	j	80004194 <iput+0x26>

0000000080004216 <iunlockput>:
{
    80004216:	1101                	addi	sp,sp,-32
    80004218:	ec06                	sd	ra,24(sp)
    8000421a:	e822                	sd	s0,16(sp)
    8000421c:	e426                	sd	s1,8(sp)
    8000421e:	1000                	addi	s0,sp,32
    80004220:	84aa                	mv	s1,a0
  iunlock(ip);
    80004222:	00000097          	auipc	ra,0x0
    80004226:	e54080e7          	jalr	-428(ra) # 80004076 <iunlock>
  iput(ip);
    8000422a:	8526                	mv	a0,s1
    8000422c:	00000097          	auipc	ra,0x0
    80004230:	f42080e7          	jalr	-190(ra) # 8000416e <iput>
}
    80004234:	60e2                	ld	ra,24(sp)
    80004236:	6442                	ld	s0,16(sp)
    80004238:	64a2                	ld	s1,8(sp)
    8000423a:	6105                	addi	sp,sp,32
    8000423c:	8082                	ret

000000008000423e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000423e:	1141                	addi	sp,sp,-16
    80004240:	e422                	sd	s0,8(sp)
    80004242:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004244:	411c                	lw	a5,0(a0)
    80004246:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004248:	415c                	lw	a5,4(a0)
    8000424a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000424c:	04451783          	lh	a5,68(a0)
    80004250:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004254:	04a51783          	lh	a5,74(a0)
    80004258:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000425c:	04c56783          	lwu	a5,76(a0)
    80004260:	e99c                	sd	a5,16(a1)
}
    80004262:	6422                	ld	s0,8(sp)
    80004264:	0141                	addi	sp,sp,16
    80004266:	8082                	ret

0000000080004268 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004268:	457c                	lw	a5,76(a0)
    8000426a:	0ed7e963          	bltu	a5,a3,8000435c <readi+0xf4>
{
    8000426e:	7159                	addi	sp,sp,-112
    80004270:	f486                	sd	ra,104(sp)
    80004272:	f0a2                	sd	s0,96(sp)
    80004274:	eca6                	sd	s1,88(sp)
    80004276:	e8ca                	sd	s2,80(sp)
    80004278:	e4ce                	sd	s3,72(sp)
    8000427a:	e0d2                	sd	s4,64(sp)
    8000427c:	fc56                	sd	s5,56(sp)
    8000427e:	f85a                	sd	s6,48(sp)
    80004280:	f45e                	sd	s7,40(sp)
    80004282:	f062                	sd	s8,32(sp)
    80004284:	ec66                	sd	s9,24(sp)
    80004286:	e86a                	sd	s10,16(sp)
    80004288:	e46e                	sd	s11,8(sp)
    8000428a:	1880                	addi	s0,sp,112
    8000428c:	8baa                	mv	s7,a0
    8000428e:	8c2e                	mv	s8,a1
    80004290:	8ab2                	mv	s5,a2
    80004292:	84b6                	mv	s1,a3
    80004294:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004296:	9f35                	addw	a4,a4,a3
    return 0;
    80004298:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000429a:	0ad76063          	bltu	a4,a3,8000433a <readi+0xd2>
  if(off + n > ip->size)
    8000429e:	00e7f463          	bgeu	a5,a4,800042a6 <readi+0x3e>
    n = ip->size - off;
    800042a2:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042a6:	0a0b0963          	beqz	s6,80004358 <readi+0xf0>
    800042aa:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800042ac:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800042b0:	5cfd                	li	s9,-1
    800042b2:	a82d                	j	800042ec <readi+0x84>
    800042b4:	020a1d93          	slli	s11,s4,0x20
    800042b8:	020ddd93          	srli	s11,s11,0x20
    800042bc:	05890793          	addi	a5,s2,88
    800042c0:	86ee                	mv	a3,s11
    800042c2:	963e                	add	a2,a2,a5
    800042c4:	85d6                	mv	a1,s5
    800042c6:	8562                	mv	a0,s8
    800042c8:	ffffe097          	auipc	ra,0xffffe
    800042cc:	1ea080e7          	jalr	490(ra) # 800024b2 <either_copyout>
    800042d0:	05950d63          	beq	a0,s9,8000432a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800042d4:	854a                	mv	a0,s2
    800042d6:	fffff097          	auipc	ra,0xfffff
    800042da:	60a080e7          	jalr	1546(ra) # 800038e0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042de:	013a09bb          	addw	s3,s4,s3
    800042e2:	009a04bb          	addw	s1,s4,s1
    800042e6:	9aee                	add	s5,s5,s11
    800042e8:	0569f763          	bgeu	s3,s6,80004336 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800042ec:	000ba903          	lw	s2,0(s7)
    800042f0:	00a4d59b          	srliw	a1,s1,0xa
    800042f4:	855e                	mv	a0,s7
    800042f6:	00000097          	auipc	ra,0x0
    800042fa:	8ae080e7          	jalr	-1874(ra) # 80003ba4 <bmap>
    800042fe:	0005059b          	sext.w	a1,a0
    80004302:	854a                	mv	a0,s2
    80004304:	fffff097          	auipc	ra,0xfffff
    80004308:	4ac080e7          	jalr	1196(ra) # 800037b0 <bread>
    8000430c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000430e:	3ff4f613          	andi	a2,s1,1023
    80004312:	40cd07bb          	subw	a5,s10,a2
    80004316:	413b073b          	subw	a4,s6,s3
    8000431a:	8a3e                	mv	s4,a5
    8000431c:	2781                	sext.w	a5,a5
    8000431e:	0007069b          	sext.w	a3,a4
    80004322:	f8f6f9e3          	bgeu	a3,a5,800042b4 <readi+0x4c>
    80004326:	8a3a                	mv	s4,a4
    80004328:	b771                	j	800042b4 <readi+0x4c>
      brelse(bp);
    8000432a:	854a                	mv	a0,s2
    8000432c:	fffff097          	auipc	ra,0xfffff
    80004330:	5b4080e7          	jalr	1460(ra) # 800038e0 <brelse>
      tot = -1;
    80004334:	59fd                	li	s3,-1
  }
  return tot;
    80004336:	0009851b          	sext.w	a0,s3
}
    8000433a:	70a6                	ld	ra,104(sp)
    8000433c:	7406                	ld	s0,96(sp)
    8000433e:	64e6                	ld	s1,88(sp)
    80004340:	6946                	ld	s2,80(sp)
    80004342:	69a6                	ld	s3,72(sp)
    80004344:	6a06                	ld	s4,64(sp)
    80004346:	7ae2                	ld	s5,56(sp)
    80004348:	7b42                	ld	s6,48(sp)
    8000434a:	7ba2                	ld	s7,40(sp)
    8000434c:	7c02                	ld	s8,32(sp)
    8000434e:	6ce2                	ld	s9,24(sp)
    80004350:	6d42                	ld	s10,16(sp)
    80004352:	6da2                	ld	s11,8(sp)
    80004354:	6165                	addi	sp,sp,112
    80004356:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004358:	89da                	mv	s3,s6
    8000435a:	bff1                	j	80004336 <readi+0xce>
    return 0;
    8000435c:	4501                	li	a0,0
}
    8000435e:	8082                	ret

0000000080004360 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004360:	457c                	lw	a5,76(a0)
    80004362:	10d7e863          	bltu	a5,a3,80004472 <writei+0x112>
{
    80004366:	7159                	addi	sp,sp,-112
    80004368:	f486                	sd	ra,104(sp)
    8000436a:	f0a2                	sd	s0,96(sp)
    8000436c:	eca6                	sd	s1,88(sp)
    8000436e:	e8ca                	sd	s2,80(sp)
    80004370:	e4ce                	sd	s3,72(sp)
    80004372:	e0d2                	sd	s4,64(sp)
    80004374:	fc56                	sd	s5,56(sp)
    80004376:	f85a                	sd	s6,48(sp)
    80004378:	f45e                	sd	s7,40(sp)
    8000437a:	f062                	sd	s8,32(sp)
    8000437c:	ec66                	sd	s9,24(sp)
    8000437e:	e86a                	sd	s10,16(sp)
    80004380:	e46e                	sd	s11,8(sp)
    80004382:	1880                	addi	s0,sp,112
    80004384:	8b2a                	mv	s6,a0
    80004386:	8c2e                	mv	s8,a1
    80004388:	8ab2                	mv	s5,a2
    8000438a:	8936                	mv	s2,a3
    8000438c:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    8000438e:	00e687bb          	addw	a5,a3,a4
    80004392:	0ed7e263          	bltu	a5,a3,80004476 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004396:	00043737          	lui	a4,0x43
    8000439a:	0ef76063          	bltu	a4,a5,8000447a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000439e:	0c0b8863          	beqz	s7,8000446e <writei+0x10e>
    800043a2:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800043a4:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800043a8:	5cfd                	li	s9,-1
    800043aa:	a091                	j	800043ee <writei+0x8e>
    800043ac:	02099d93          	slli	s11,s3,0x20
    800043b0:	020ddd93          	srli	s11,s11,0x20
    800043b4:	05848793          	addi	a5,s1,88
    800043b8:	86ee                	mv	a3,s11
    800043ba:	8656                	mv	a2,s5
    800043bc:	85e2                	mv	a1,s8
    800043be:	953e                	add	a0,a0,a5
    800043c0:	ffffe097          	auipc	ra,0xffffe
    800043c4:	148080e7          	jalr	328(ra) # 80002508 <either_copyin>
    800043c8:	07950263          	beq	a0,s9,8000442c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800043cc:	8526                	mv	a0,s1
    800043ce:	00001097          	auipc	ra,0x1
    800043d2:	aa6080e7          	jalr	-1370(ra) # 80004e74 <log_write>
    brelse(bp);
    800043d6:	8526                	mv	a0,s1
    800043d8:	fffff097          	auipc	ra,0xfffff
    800043dc:	508080e7          	jalr	1288(ra) # 800038e0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043e0:	01498a3b          	addw	s4,s3,s4
    800043e4:	0129893b          	addw	s2,s3,s2
    800043e8:	9aee                	add	s5,s5,s11
    800043ea:	057a7663          	bgeu	s4,s7,80004436 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800043ee:	000b2483          	lw	s1,0(s6)
    800043f2:	00a9559b          	srliw	a1,s2,0xa
    800043f6:	855a                	mv	a0,s6
    800043f8:	fffff097          	auipc	ra,0xfffff
    800043fc:	7ac080e7          	jalr	1964(ra) # 80003ba4 <bmap>
    80004400:	0005059b          	sext.w	a1,a0
    80004404:	8526                	mv	a0,s1
    80004406:	fffff097          	auipc	ra,0xfffff
    8000440a:	3aa080e7          	jalr	938(ra) # 800037b0 <bread>
    8000440e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004410:	3ff97513          	andi	a0,s2,1023
    80004414:	40ad07bb          	subw	a5,s10,a0
    80004418:	414b873b          	subw	a4,s7,s4
    8000441c:	89be                	mv	s3,a5
    8000441e:	2781                	sext.w	a5,a5
    80004420:	0007069b          	sext.w	a3,a4
    80004424:	f8f6f4e3          	bgeu	a3,a5,800043ac <writei+0x4c>
    80004428:	89ba                	mv	s3,a4
    8000442a:	b749                	j	800043ac <writei+0x4c>
      brelse(bp);
    8000442c:	8526                	mv	a0,s1
    8000442e:	fffff097          	auipc	ra,0xfffff
    80004432:	4b2080e7          	jalr	1202(ra) # 800038e0 <brelse>
  }

  if(off > ip->size)
    80004436:	04cb2783          	lw	a5,76(s6)
    8000443a:	0127f463          	bgeu	a5,s2,80004442 <writei+0xe2>
    ip->size = off;
    8000443e:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004442:	855a                	mv	a0,s6
    80004444:	00000097          	auipc	ra,0x0
    80004448:	aa6080e7          	jalr	-1370(ra) # 80003eea <iupdate>

  return tot;
    8000444c:	000a051b          	sext.w	a0,s4
}
    80004450:	70a6                	ld	ra,104(sp)
    80004452:	7406                	ld	s0,96(sp)
    80004454:	64e6                	ld	s1,88(sp)
    80004456:	6946                	ld	s2,80(sp)
    80004458:	69a6                	ld	s3,72(sp)
    8000445a:	6a06                	ld	s4,64(sp)
    8000445c:	7ae2                	ld	s5,56(sp)
    8000445e:	7b42                	ld	s6,48(sp)
    80004460:	7ba2                	ld	s7,40(sp)
    80004462:	7c02                	ld	s8,32(sp)
    80004464:	6ce2                	ld	s9,24(sp)
    80004466:	6d42                	ld	s10,16(sp)
    80004468:	6da2                	ld	s11,8(sp)
    8000446a:	6165                	addi	sp,sp,112
    8000446c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000446e:	8a5e                	mv	s4,s7
    80004470:	bfc9                	j	80004442 <writei+0xe2>
    return -1;
    80004472:	557d                	li	a0,-1
}
    80004474:	8082                	ret
    return -1;
    80004476:	557d                	li	a0,-1
    80004478:	bfe1                	j	80004450 <writei+0xf0>
    return -1;
    8000447a:	557d                	li	a0,-1
    8000447c:	bfd1                	j	80004450 <writei+0xf0>

000000008000447e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000447e:	1141                	addi	sp,sp,-16
    80004480:	e406                	sd	ra,8(sp)
    80004482:	e022                	sd	s0,0(sp)
    80004484:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004486:	4639                	li	a2,14
    80004488:	ffffd097          	auipc	ra,0xffffd
    8000448c:	90e080e7          	jalr	-1778(ra) # 80000d96 <strncmp>
}
    80004490:	60a2                	ld	ra,8(sp)
    80004492:	6402                	ld	s0,0(sp)
    80004494:	0141                	addi	sp,sp,16
    80004496:	8082                	ret

0000000080004498 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004498:	7139                	addi	sp,sp,-64
    8000449a:	fc06                	sd	ra,56(sp)
    8000449c:	f822                	sd	s0,48(sp)
    8000449e:	f426                	sd	s1,40(sp)
    800044a0:	f04a                	sd	s2,32(sp)
    800044a2:	ec4e                	sd	s3,24(sp)
    800044a4:	e852                	sd	s4,16(sp)
    800044a6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800044a8:	04451703          	lh	a4,68(a0)
    800044ac:	4785                	li	a5,1
    800044ae:	00f71a63          	bne	a4,a5,800044c2 <dirlookup+0x2a>
    800044b2:	892a                	mv	s2,a0
    800044b4:	89ae                	mv	s3,a1
    800044b6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800044b8:	457c                	lw	a5,76(a0)
    800044ba:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800044bc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044be:	e79d                	bnez	a5,800044ec <dirlookup+0x54>
    800044c0:	a8a5                	j	80004538 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800044c2:	00005517          	auipc	a0,0x5
    800044c6:	55e50513          	addi	a0,a0,1374 # 80009a20 <syscalls+0x1a0>
    800044ca:	ffffc097          	auipc	ra,0xffffc
    800044ce:	060080e7          	jalr	96(ra) # 8000052a <panic>
      panic("dirlookup read");
    800044d2:	00005517          	auipc	a0,0x5
    800044d6:	56650513          	addi	a0,a0,1382 # 80009a38 <syscalls+0x1b8>
    800044da:	ffffc097          	auipc	ra,0xffffc
    800044de:	050080e7          	jalr	80(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044e2:	24c1                	addiw	s1,s1,16
    800044e4:	04c92783          	lw	a5,76(s2)
    800044e8:	04f4f763          	bgeu	s1,a5,80004536 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044ec:	4741                	li	a4,16
    800044ee:	86a6                	mv	a3,s1
    800044f0:	fc040613          	addi	a2,s0,-64
    800044f4:	4581                	li	a1,0
    800044f6:	854a                	mv	a0,s2
    800044f8:	00000097          	auipc	ra,0x0
    800044fc:	d70080e7          	jalr	-656(ra) # 80004268 <readi>
    80004500:	47c1                	li	a5,16
    80004502:	fcf518e3          	bne	a0,a5,800044d2 <dirlookup+0x3a>
    if(de.inum == 0)
    80004506:	fc045783          	lhu	a5,-64(s0)
    8000450a:	dfe1                	beqz	a5,800044e2 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000450c:	fc240593          	addi	a1,s0,-62
    80004510:	854e                	mv	a0,s3
    80004512:	00000097          	auipc	ra,0x0
    80004516:	f6c080e7          	jalr	-148(ra) # 8000447e <namecmp>
    8000451a:	f561                	bnez	a0,800044e2 <dirlookup+0x4a>
      if(poff)
    8000451c:	000a0463          	beqz	s4,80004524 <dirlookup+0x8c>
        *poff = off;
    80004520:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004524:	fc045583          	lhu	a1,-64(s0)
    80004528:	00092503          	lw	a0,0(s2)
    8000452c:	fffff097          	auipc	ra,0xfffff
    80004530:	754080e7          	jalr	1876(ra) # 80003c80 <iget>
    80004534:	a011                	j	80004538 <dirlookup+0xa0>
  return 0;
    80004536:	4501                	li	a0,0
}
    80004538:	70e2                	ld	ra,56(sp)
    8000453a:	7442                	ld	s0,48(sp)
    8000453c:	74a2                	ld	s1,40(sp)
    8000453e:	7902                	ld	s2,32(sp)
    80004540:	69e2                	ld	s3,24(sp)
    80004542:	6a42                	ld	s4,16(sp)
    80004544:	6121                	addi	sp,sp,64
    80004546:	8082                	ret

0000000080004548 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004548:	711d                	addi	sp,sp,-96
    8000454a:	ec86                	sd	ra,88(sp)
    8000454c:	e8a2                	sd	s0,80(sp)
    8000454e:	e4a6                	sd	s1,72(sp)
    80004550:	e0ca                	sd	s2,64(sp)
    80004552:	fc4e                	sd	s3,56(sp)
    80004554:	f852                	sd	s4,48(sp)
    80004556:	f456                	sd	s5,40(sp)
    80004558:	f05a                	sd	s6,32(sp)
    8000455a:	ec5e                	sd	s7,24(sp)
    8000455c:	e862                	sd	s8,16(sp)
    8000455e:	e466                	sd	s9,8(sp)
    80004560:	1080                	addi	s0,sp,96
    80004562:	84aa                	mv	s1,a0
    80004564:	8aae                	mv	s5,a1
    80004566:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004568:	00054703          	lbu	a4,0(a0)
    8000456c:	02f00793          	li	a5,47
    80004570:	02f70363          	beq	a4,a5,80004596 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004574:	ffffd097          	auipc	ra,0xffffd
    80004578:	602080e7          	jalr	1538(ra) # 80001b76 <myproc>
    8000457c:	15053503          	ld	a0,336(a0)
    80004580:	00000097          	auipc	ra,0x0
    80004584:	9f6080e7          	jalr	-1546(ra) # 80003f76 <idup>
    80004588:	89aa                	mv	s3,a0
  while(*path == '/')
    8000458a:	02f00913          	li	s2,47
  len = path - s;
    8000458e:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004590:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004592:	4b85                	li	s7,1
    80004594:	a865                	j	8000464c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004596:	4585                	li	a1,1
    80004598:	4505                	li	a0,1
    8000459a:	fffff097          	auipc	ra,0xfffff
    8000459e:	6e6080e7          	jalr	1766(ra) # 80003c80 <iget>
    800045a2:	89aa                	mv	s3,a0
    800045a4:	b7dd                	j	8000458a <namex+0x42>
      iunlockput(ip);
    800045a6:	854e                	mv	a0,s3
    800045a8:	00000097          	auipc	ra,0x0
    800045ac:	c6e080e7          	jalr	-914(ra) # 80004216 <iunlockput>
      return 0;
    800045b0:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800045b2:	854e                	mv	a0,s3
    800045b4:	60e6                	ld	ra,88(sp)
    800045b6:	6446                	ld	s0,80(sp)
    800045b8:	64a6                	ld	s1,72(sp)
    800045ba:	6906                	ld	s2,64(sp)
    800045bc:	79e2                	ld	s3,56(sp)
    800045be:	7a42                	ld	s4,48(sp)
    800045c0:	7aa2                	ld	s5,40(sp)
    800045c2:	7b02                	ld	s6,32(sp)
    800045c4:	6be2                	ld	s7,24(sp)
    800045c6:	6c42                	ld	s8,16(sp)
    800045c8:	6ca2                	ld	s9,8(sp)
    800045ca:	6125                	addi	sp,sp,96
    800045cc:	8082                	ret
      iunlock(ip);
    800045ce:	854e                	mv	a0,s3
    800045d0:	00000097          	auipc	ra,0x0
    800045d4:	aa6080e7          	jalr	-1370(ra) # 80004076 <iunlock>
      return ip;
    800045d8:	bfe9                	j	800045b2 <namex+0x6a>
      iunlockput(ip);
    800045da:	854e                	mv	a0,s3
    800045dc:	00000097          	auipc	ra,0x0
    800045e0:	c3a080e7          	jalr	-966(ra) # 80004216 <iunlockput>
      return 0;
    800045e4:	89e6                	mv	s3,s9
    800045e6:	b7f1                	j	800045b2 <namex+0x6a>
  len = path - s;
    800045e8:	40b48633          	sub	a2,s1,a1
    800045ec:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800045f0:	099c5463          	bge	s8,s9,80004678 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800045f4:	4639                	li	a2,14
    800045f6:	8552                	mv	a0,s4
    800045f8:	ffffc097          	auipc	ra,0xffffc
    800045fc:	722080e7          	jalr	1826(ra) # 80000d1a <memmove>
  while(*path == '/')
    80004600:	0004c783          	lbu	a5,0(s1)
    80004604:	01279763          	bne	a5,s2,80004612 <namex+0xca>
    path++;
    80004608:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000460a:	0004c783          	lbu	a5,0(s1)
    8000460e:	ff278de3          	beq	a5,s2,80004608 <namex+0xc0>
    ilock(ip);
    80004612:	854e                	mv	a0,s3
    80004614:	00000097          	auipc	ra,0x0
    80004618:	9a0080e7          	jalr	-1632(ra) # 80003fb4 <ilock>
    if(ip->type != T_DIR){
    8000461c:	04499783          	lh	a5,68(s3)
    80004620:	f97793e3          	bne	a5,s7,800045a6 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004624:	000a8563          	beqz	s5,8000462e <namex+0xe6>
    80004628:	0004c783          	lbu	a5,0(s1)
    8000462c:	d3cd                	beqz	a5,800045ce <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000462e:	865a                	mv	a2,s6
    80004630:	85d2                	mv	a1,s4
    80004632:	854e                	mv	a0,s3
    80004634:	00000097          	auipc	ra,0x0
    80004638:	e64080e7          	jalr	-412(ra) # 80004498 <dirlookup>
    8000463c:	8caa                	mv	s9,a0
    8000463e:	dd51                	beqz	a0,800045da <namex+0x92>
    iunlockput(ip);
    80004640:	854e                	mv	a0,s3
    80004642:	00000097          	auipc	ra,0x0
    80004646:	bd4080e7          	jalr	-1068(ra) # 80004216 <iunlockput>
    ip = next;
    8000464a:	89e6                	mv	s3,s9
  while(*path == '/')
    8000464c:	0004c783          	lbu	a5,0(s1)
    80004650:	05279763          	bne	a5,s2,8000469e <namex+0x156>
    path++;
    80004654:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004656:	0004c783          	lbu	a5,0(s1)
    8000465a:	ff278de3          	beq	a5,s2,80004654 <namex+0x10c>
  if(*path == 0)
    8000465e:	c79d                	beqz	a5,8000468c <namex+0x144>
    path++;
    80004660:	85a6                	mv	a1,s1
  len = path - s;
    80004662:	8cda                	mv	s9,s6
    80004664:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004666:	01278963          	beq	a5,s2,80004678 <namex+0x130>
    8000466a:	dfbd                	beqz	a5,800045e8 <namex+0xa0>
    path++;
    8000466c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000466e:	0004c783          	lbu	a5,0(s1)
    80004672:	ff279ce3          	bne	a5,s2,8000466a <namex+0x122>
    80004676:	bf8d                	j	800045e8 <namex+0xa0>
    memmove(name, s, len);
    80004678:	2601                	sext.w	a2,a2
    8000467a:	8552                	mv	a0,s4
    8000467c:	ffffc097          	auipc	ra,0xffffc
    80004680:	69e080e7          	jalr	1694(ra) # 80000d1a <memmove>
    name[len] = 0;
    80004684:	9cd2                	add	s9,s9,s4
    80004686:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000468a:	bf9d                	j	80004600 <namex+0xb8>
  if(nameiparent){
    8000468c:	f20a83e3          	beqz	s5,800045b2 <namex+0x6a>
    iput(ip);
    80004690:	854e                	mv	a0,s3
    80004692:	00000097          	auipc	ra,0x0
    80004696:	adc080e7          	jalr	-1316(ra) # 8000416e <iput>
    return 0;
    8000469a:	4981                	li	s3,0
    8000469c:	bf19                	j	800045b2 <namex+0x6a>
  if(*path == 0)
    8000469e:	d7fd                	beqz	a5,8000468c <namex+0x144>
  while(*path != '/' && *path != 0)
    800046a0:	0004c783          	lbu	a5,0(s1)
    800046a4:	85a6                	mv	a1,s1
    800046a6:	b7d1                	j	8000466a <namex+0x122>

00000000800046a8 <dirlink>:
{
    800046a8:	7139                	addi	sp,sp,-64
    800046aa:	fc06                	sd	ra,56(sp)
    800046ac:	f822                	sd	s0,48(sp)
    800046ae:	f426                	sd	s1,40(sp)
    800046b0:	f04a                	sd	s2,32(sp)
    800046b2:	ec4e                	sd	s3,24(sp)
    800046b4:	e852                	sd	s4,16(sp)
    800046b6:	0080                	addi	s0,sp,64
    800046b8:	892a                	mv	s2,a0
    800046ba:	8a2e                	mv	s4,a1
    800046bc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800046be:	4601                	li	a2,0
    800046c0:	00000097          	auipc	ra,0x0
    800046c4:	dd8080e7          	jalr	-552(ra) # 80004498 <dirlookup>
    800046c8:	e93d                	bnez	a0,8000473e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046ca:	04c92483          	lw	s1,76(s2)
    800046ce:	c49d                	beqz	s1,800046fc <dirlink+0x54>
    800046d0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046d2:	4741                	li	a4,16
    800046d4:	86a6                	mv	a3,s1
    800046d6:	fc040613          	addi	a2,s0,-64
    800046da:	4581                	li	a1,0
    800046dc:	854a                	mv	a0,s2
    800046de:	00000097          	auipc	ra,0x0
    800046e2:	b8a080e7          	jalr	-1142(ra) # 80004268 <readi>
    800046e6:	47c1                	li	a5,16
    800046e8:	06f51163          	bne	a0,a5,8000474a <dirlink+0xa2>
    if(de.inum == 0)
    800046ec:	fc045783          	lhu	a5,-64(s0)
    800046f0:	c791                	beqz	a5,800046fc <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046f2:	24c1                	addiw	s1,s1,16
    800046f4:	04c92783          	lw	a5,76(s2)
    800046f8:	fcf4ede3          	bltu	s1,a5,800046d2 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800046fc:	4639                	li	a2,14
    800046fe:	85d2                	mv	a1,s4
    80004700:	fc240513          	addi	a0,s0,-62
    80004704:	ffffc097          	auipc	ra,0xffffc
    80004708:	6ce080e7          	jalr	1742(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    8000470c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004710:	4741                	li	a4,16
    80004712:	86a6                	mv	a3,s1
    80004714:	fc040613          	addi	a2,s0,-64
    80004718:	4581                	li	a1,0
    8000471a:	854a                	mv	a0,s2
    8000471c:	00000097          	auipc	ra,0x0
    80004720:	c44080e7          	jalr	-956(ra) # 80004360 <writei>
    80004724:	872a                	mv	a4,a0
    80004726:	47c1                	li	a5,16
  return 0;
    80004728:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000472a:	02f71863          	bne	a4,a5,8000475a <dirlink+0xb2>
}
    8000472e:	70e2                	ld	ra,56(sp)
    80004730:	7442                	ld	s0,48(sp)
    80004732:	74a2                	ld	s1,40(sp)
    80004734:	7902                	ld	s2,32(sp)
    80004736:	69e2                	ld	s3,24(sp)
    80004738:	6a42                	ld	s4,16(sp)
    8000473a:	6121                	addi	sp,sp,64
    8000473c:	8082                	ret
    iput(ip);
    8000473e:	00000097          	auipc	ra,0x0
    80004742:	a30080e7          	jalr	-1488(ra) # 8000416e <iput>
    return -1;
    80004746:	557d                	li	a0,-1
    80004748:	b7dd                	j	8000472e <dirlink+0x86>
      panic("dirlink read");
    8000474a:	00005517          	auipc	a0,0x5
    8000474e:	2fe50513          	addi	a0,a0,766 # 80009a48 <syscalls+0x1c8>
    80004752:	ffffc097          	auipc	ra,0xffffc
    80004756:	dd8080e7          	jalr	-552(ra) # 8000052a <panic>
    panic("dirlink");
    8000475a:	00005517          	auipc	a0,0x5
    8000475e:	47650513          	addi	a0,a0,1142 # 80009bd0 <syscalls+0x350>
    80004762:	ffffc097          	auipc	ra,0xffffc
    80004766:	dc8080e7          	jalr	-568(ra) # 8000052a <panic>

000000008000476a <namei>:

struct inode*
namei(char *path)
{
    8000476a:	1101                	addi	sp,sp,-32
    8000476c:	ec06                	sd	ra,24(sp)
    8000476e:	e822                	sd	s0,16(sp)
    80004770:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004772:	fe040613          	addi	a2,s0,-32
    80004776:	4581                	li	a1,0
    80004778:	00000097          	auipc	ra,0x0
    8000477c:	dd0080e7          	jalr	-560(ra) # 80004548 <namex>
}
    80004780:	60e2                	ld	ra,24(sp)
    80004782:	6442                	ld	s0,16(sp)
    80004784:	6105                	addi	sp,sp,32
    80004786:	8082                	ret

0000000080004788 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004788:	1141                	addi	sp,sp,-16
    8000478a:	e406                	sd	ra,8(sp)
    8000478c:	e022                	sd	s0,0(sp)
    8000478e:	0800                	addi	s0,sp,16
    80004790:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004792:	4585                	li	a1,1
    80004794:	00000097          	auipc	ra,0x0
    80004798:	db4080e7          	jalr	-588(ra) # 80004548 <namex>
}
    8000479c:	60a2                	ld	ra,8(sp)
    8000479e:	6402                	ld	s0,0(sp)
    800047a0:	0141                	addi	sp,sp,16
    800047a2:	8082                	ret

00000000800047a4 <itoa>:


#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
    800047a4:	1101                	addi	sp,sp,-32
    800047a6:	ec22                	sd	s0,24(sp)
    800047a8:	1000                	addi	s0,sp,32
    800047aa:	872a                	mv	a4,a0
    800047ac:	852e                	mv	a0,a1
    char const digit[] = "0123456789";
    800047ae:	00005797          	auipc	a5,0x5
    800047b2:	2aa78793          	addi	a5,a5,682 # 80009a58 <syscalls+0x1d8>
    800047b6:	6394                	ld	a3,0(a5)
    800047b8:	fed43023          	sd	a3,-32(s0)
    800047bc:	0087d683          	lhu	a3,8(a5)
    800047c0:	fed41423          	sh	a3,-24(s0)
    800047c4:	00a7c783          	lbu	a5,10(a5)
    800047c8:	fef40523          	sb	a5,-22(s0)
    char* p = b;
    800047cc:	87ae                	mv	a5,a1
    if(i<0){
    800047ce:	02074b63          	bltz	a4,80004804 <itoa+0x60>
        *p++ = '-';
        i *= -1;
    }
    int shifter = i;
    800047d2:	86ba                	mv	a3,a4
    do{ //Move to where representation ends
        ++p;
        shifter = shifter/10;
    800047d4:	4629                	li	a2,10
        ++p;
    800047d6:	0785                	addi	a5,a5,1
        shifter = shifter/10;
    800047d8:	02c6c6bb          	divw	a3,a3,a2
    }while(shifter);
    800047dc:	feed                	bnez	a3,800047d6 <itoa+0x32>
    *p = '\0';
    800047de:	00078023          	sb	zero,0(a5)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
    800047e2:	4629                	li	a2,10
    800047e4:	17fd                	addi	a5,a5,-1
    800047e6:	02c766bb          	remw	a3,a4,a2
    800047ea:	ff040593          	addi	a1,s0,-16
    800047ee:	96ae                	add	a3,a3,a1
    800047f0:	ff06c683          	lbu	a3,-16(a3)
    800047f4:	00d78023          	sb	a3,0(a5)
        i = i/10;
    800047f8:	02c7473b          	divw	a4,a4,a2
    }while(i);
    800047fc:	f765                	bnez	a4,800047e4 <itoa+0x40>
    return b;
}
    800047fe:	6462                	ld	s0,24(sp)
    80004800:	6105                	addi	sp,sp,32
    80004802:	8082                	ret
        *p++ = '-';
    80004804:	00158793          	addi	a5,a1,1
    80004808:	02d00693          	li	a3,45
    8000480c:	00d58023          	sb	a3,0(a1)
        i *= -1;
    80004810:	40e0073b          	negw	a4,a4
    80004814:	bf7d                	j	800047d2 <itoa+0x2e>

0000000080004816 <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
    80004816:	711d                	addi	sp,sp,-96
    80004818:	ec86                	sd	ra,88(sp)
    8000481a:	e8a2                	sd	s0,80(sp)
    8000481c:	e4a6                	sd	s1,72(sp)
    8000481e:	e0ca                	sd	s2,64(sp)
    80004820:	1080                	addi	s0,sp,96
    80004822:	84aa                	mv	s1,a0
  //path of proccess
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    80004824:	4619                	li	a2,6
    80004826:	00005597          	auipc	a1,0x5
    8000482a:	24258593          	addi	a1,a1,578 # 80009a68 <syscalls+0x1e8>
    8000482e:	fd040513          	addi	a0,s0,-48
    80004832:	ffffc097          	auipc	ra,0xffffc
    80004836:	4e8080e7          	jalr	1256(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    8000483a:	fd640593          	addi	a1,s0,-42
    8000483e:	5888                	lw	a0,48(s1)
    80004840:	00000097          	auipc	ra,0x0
    80004844:	f64080e7          	jalr	-156(ra) # 800047a4 <itoa>
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ];
  uint off;

  if(0 == p->swapFile)
    80004848:	1684b503          	ld	a0,360(s1)
    8000484c:	16050763          	beqz	a0,800049ba <removeSwapFile+0x1a4>
  {
    return -1;
  }
  fileclose(p->swapFile);
    80004850:	00001097          	auipc	ra,0x1
    80004854:	918080e7          	jalr	-1768(ra) # 80005168 <fileclose>

  begin_op();
    80004858:	00000097          	auipc	ra,0x0
    8000485c:	444080e7          	jalr	1092(ra) # 80004c9c <begin_op>
  if((dp = nameiparent(path, name)) == 0)
    80004860:	fb040593          	addi	a1,s0,-80
    80004864:	fd040513          	addi	a0,s0,-48
    80004868:	00000097          	auipc	ra,0x0
    8000486c:	f20080e7          	jalr	-224(ra) # 80004788 <nameiparent>
    80004870:	892a                	mv	s2,a0
    80004872:	cd69                	beqz	a0,8000494c <removeSwapFile+0x136>
  {
    end_op();
    return -1;
  }

  ilock(dp);
    80004874:	fffff097          	auipc	ra,0xfffff
    80004878:	740080e7          	jalr	1856(ra) # 80003fb4 <ilock>

    // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000487c:	00005597          	auipc	a1,0x5
    80004880:	1f458593          	addi	a1,a1,500 # 80009a70 <syscalls+0x1f0>
    80004884:	fb040513          	addi	a0,s0,-80
    80004888:	00000097          	auipc	ra,0x0
    8000488c:	bf6080e7          	jalr	-1034(ra) # 8000447e <namecmp>
    80004890:	c57d                	beqz	a0,8000497e <removeSwapFile+0x168>
    80004892:	00005597          	auipc	a1,0x5
    80004896:	1e658593          	addi	a1,a1,486 # 80009a78 <syscalls+0x1f8>
    8000489a:	fb040513          	addi	a0,s0,-80
    8000489e:	00000097          	auipc	ra,0x0
    800048a2:	be0080e7          	jalr	-1056(ra) # 8000447e <namecmp>
    800048a6:	cd61                	beqz	a0,8000497e <removeSwapFile+0x168>
     goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    800048a8:	fac40613          	addi	a2,s0,-84
    800048ac:	fb040593          	addi	a1,s0,-80
    800048b0:	854a                	mv	a0,s2
    800048b2:	00000097          	auipc	ra,0x0
    800048b6:	be6080e7          	jalr	-1050(ra) # 80004498 <dirlookup>
    800048ba:	84aa                	mv	s1,a0
    800048bc:	c169                	beqz	a0,8000497e <removeSwapFile+0x168>
    goto bad;
  ilock(ip);
    800048be:	fffff097          	auipc	ra,0xfffff
    800048c2:	6f6080e7          	jalr	1782(ra) # 80003fb4 <ilock>

  if(ip->nlink < 1)
    800048c6:	04a49783          	lh	a5,74(s1)
    800048ca:	08f05763          	blez	a5,80004958 <removeSwapFile+0x142>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    800048ce:	04449703          	lh	a4,68(s1)
    800048d2:	4785                	li	a5,1
    800048d4:	08f70a63          	beq	a4,a5,80004968 <removeSwapFile+0x152>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    800048d8:	4641                	li	a2,16
    800048da:	4581                	li	a1,0
    800048dc:	fc040513          	addi	a0,s0,-64
    800048e0:	ffffc097          	auipc	ra,0xffffc
    800048e4:	3de080e7          	jalr	990(ra) # 80000cbe <memset>
  if(writei(dp,0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800048e8:	4741                	li	a4,16
    800048ea:	fac42683          	lw	a3,-84(s0)
    800048ee:	fc040613          	addi	a2,s0,-64
    800048f2:	4581                	li	a1,0
    800048f4:	854a                	mv	a0,s2
    800048f6:	00000097          	auipc	ra,0x0
    800048fa:	a6a080e7          	jalr	-1430(ra) # 80004360 <writei>
    800048fe:	47c1                	li	a5,16
    80004900:	08f51a63          	bne	a0,a5,80004994 <removeSwapFile+0x17e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    80004904:	04449703          	lh	a4,68(s1)
    80004908:	4785                	li	a5,1
    8000490a:	08f70d63          	beq	a4,a5,800049a4 <removeSwapFile+0x18e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    8000490e:	854a                	mv	a0,s2
    80004910:	00000097          	auipc	ra,0x0
    80004914:	906080e7          	jalr	-1786(ra) # 80004216 <iunlockput>

  ip->nlink--;
    80004918:	04a4d783          	lhu	a5,74(s1)
    8000491c:	37fd                	addiw	a5,a5,-1
    8000491e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004922:	8526                	mv	a0,s1
    80004924:	fffff097          	auipc	ra,0xfffff
    80004928:	5c6080e7          	jalr	1478(ra) # 80003eea <iupdate>
  iunlockput(ip);
    8000492c:	8526                	mv	a0,s1
    8000492e:	00000097          	auipc	ra,0x0
    80004932:	8e8080e7          	jalr	-1816(ra) # 80004216 <iunlockput>

  end_op();
    80004936:	00000097          	auipc	ra,0x0
    8000493a:	3e6080e7          	jalr	998(ra) # 80004d1c <end_op>

  return 0;
    8000493e:	4501                	li	a0,0
  bad:
    iunlockput(dp);
    end_op();
    return -1;

}
    80004940:	60e6                	ld	ra,88(sp)
    80004942:	6446                	ld	s0,80(sp)
    80004944:	64a6                	ld	s1,72(sp)
    80004946:	6906                	ld	s2,64(sp)
    80004948:	6125                	addi	sp,sp,96
    8000494a:	8082                	ret
    end_op();
    8000494c:	00000097          	auipc	ra,0x0
    80004950:	3d0080e7          	jalr	976(ra) # 80004d1c <end_op>
    return -1;
    80004954:	557d                	li	a0,-1
    80004956:	b7ed                	j	80004940 <removeSwapFile+0x12a>
    panic("unlink: nlink < 1");
    80004958:	00005517          	auipc	a0,0x5
    8000495c:	12850513          	addi	a0,a0,296 # 80009a80 <syscalls+0x200>
    80004960:	ffffc097          	auipc	ra,0xffffc
    80004964:	bca080e7          	jalr	-1078(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004968:	8526                	mv	a0,s1
    8000496a:	00001097          	auipc	ra,0x1
    8000496e:	79a080e7          	jalr	1946(ra) # 80006104 <isdirempty>
    80004972:	f13d                	bnez	a0,800048d8 <removeSwapFile+0xc2>
    iunlockput(ip);
    80004974:	8526                	mv	a0,s1
    80004976:	00000097          	auipc	ra,0x0
    8000497a:	8a0080e7          	jalr	-1888(ra) # 80004216 <iunlockput>
    iunlockput(dp);
    8000497e:	854a                	mv	a0,s2
    80004980:	00000097          	auipc	ra,0x0
    80004984:	896080e7          	jalr	-1898(ra) # 80004216 <iunlockput>
    end_op();
    80004988:	00000097          	auipc	ra,0x0
    8000498c:	394080e7          	jalr	916(ra) # 80004d1c <end_op>
    return -1;
    80004990:	557d                	li	a0,-1
    80004992:	b77d                	j	80004940 <removeSwapFile+0x12a>
    panic("unlink: writei");
    80004994:	00005517          	auipc	a0,0x5
    80004998:	10450513          	addi	a0,a0,260 # 80009a98 <syscalls+0x218>
    8000499c:	ffffc097          	auipc	ra,0xffffc
    800049a0:	b8e080e7          	jalr	-1138(ra) # 8000052a <panic>
    dp->nlink--;
    800049a4:	04a95783          	lhu	a5,74(s2)
    800049a8:	37fd                	addiw	a5,a5,-1
    800049aa:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800049ae:	854a                	mv	a0,s2
    800049b0:	fffff097          	auipc	ra,0xfffff
    800049b4:	53a080e7          	jalr	1338(ra) # 80003eea <iupdate>
    800049b8:	bf99                	j	8000490e <removeSwapFile+0xf8>
    return -1;
    800049ba:	557d                	li	a0,-1
    800049bc:	b751                	j	80004940 <removeSwapFile+0x12a>

00000000800049be <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
    800049be:	7179                	addi	sp,sp,-48
    800049c0:	f406                	sd	ra,40(sp)
    800049c2:	f022                	sd	s0,32(sp)
    800049c4:	ec26                	sd	s1,24(sp)
    800049c6:	e84a                	sd	s2,16(sp)
    800049c8:	1800                	addi	s0,sp,48
    800049ca:	84aa                	mv	s1,a0

  char path[DIGITS];
  memmove(path,"/.swap", 6);
    800049cc:	4619                	li	a2,6
    800049ce:	00005597          	auipc	a1,0x5
    800049d2:	09a58593          	addi	a1,a1,154 # 80009a68 <syscalls+0x1e8>
    800049d6:	fd040513          	addi	a0,s0,-48
    800049da:	ffffc097          	auipc	ra,0xffffc
    800049de:	340080e7          	jalr	832(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    800049e2:	fd640593          	addi	a1,s0,-42
    800049e6:	5888                	lw	a0,48(s1)
    800049e8:	00000097          	auipc	ra,0x0
    800049ec:	dbc080e7          	jalr	-580(ra) # 800047a4 <itoa>

  begin_op();
    800049f0:	00000097          	auipc	ra,0x0
    800049f4:	2ac080e7          	jalr	684(ra) # 80004c9c <begin_op>
  
  struct inode * in = create(path, T_FILE, 0, 0);
    800049f8:	4681                	li	a3,0
    800049fa:	4601                	li	a2,0
    800049fc:	4589                	li	a1,2
    800049fe:	fd040513          	addi	a0,s0,-48
    80004a02:	00002097          	auipc	ra,0x2
    80004a06:	8f6080e7          	jalr	-1802(ra) # 800062f8 <create>
    80004a0a:	892a                	mv	s2,a0
  iunlock(in);
    80004a0c:	fffff097          	auipc	ra,0xfffff
    80004a10:	66a080e7          	jalr	1642(ra) # 80004076 <iunlock>
  p->swapFile = filealloc();
    80004a14:	00000097          	auipc	ra,0x0
    80004a18:	698080e7          	jalr	1688(ra) # 800050ac <filealloc>
    80004a1c:	16a4b423          	sd	a0,360(s1)
  if (p->swapFile == 0)
    80004a20:	cd1d                	beqz	a0,80004a5e <createSwapFile+0xa0>
    panic("no slot for files on /store");

  p->swapFile->ip = in;
    80004a22:	01253c23          	sd	s2,24(a0)
  p->swapFile->type = FD_INODE;
    80004a26:	1684b703          	ld	a4,360(s1)
    80004a2a:	4789                	li	a5,2
    80004a2c:	c31c                	sw	a5,0(a4)
  p->swapFile->off = 0;
    80004a2e:	1684b703          	ld	a4,360(s1)
    80004a32:	02072023          	sw	zero,32(a4) # 43020 <_entry-0x7ffbcfe0>
  p->swapFile->readable = O_WRONLY;
    80004a36:	1684b703          	ld	a4,360(s1)
    80004a3a:	4685                	li	a3,1
    80004a3c:	00d70423          	sb	a3,8(a4)
  p->swapFile->writable = O_RDWR;
    80004a40:	1684b703          	ld	a4,360(s1)
    80004a44:	00f704a3          	sb	a5,9(a4)
    end_op();
    80004a48:	00000097          	auipc	ra,0x0
    80004a4c:	2d4080e7          	jalr	724(ra) # 80004d1c <end_op>

    return 0;
}
    80004a50:	4501                	li	a0,0
    80004a52:	70a2                	ld	ra,40(sp)
    80004a54:	7402                	ld	s0,32(sp)
    80004a56:	64e2                	ld	s1,24(sp)
    80004a58:	6942                	ld	s2,16(sp)
    80004a5a:	6145                	addi	sp,sp,48
    80004a5c:	8082                	ret
    panic("no slot for files on /store");
    80004a5e:	00005517          	auipc	a0,0x5
    80004a62:	04a50513          	addi	a0,a0,74 # 80009aa8 <syscalls+0x228>
    80004a66:	ffffc097          	auipc	ra,0xffffc
    80004a6a:	ac4080e7          	jalr	-1340(ra) # 8000052a <panic>

0000000080004a6e <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004a6e:	1141                	addi	sp,sp,-16
    80004a70:	e406                	sd	ra,8(sp)
    80004a72:	e022                	sd	s0,0(sp)
    80004a74:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004a76:	16853783          	ld	a5,360(a0)
    80004a7a:	d390                	sw	a2,32(a5)
  return kfilewrite(p->swapFile, (uint64)buffer, size);
    80004a7c:	8636                	mv	a2,a3
    80004a7e:	16853503          	ld	a0,360(a0)
    80004a82:	00001097          	auipc	ra,0x1
    80004a86:	ad8080e7          	jalr	-1320(ra) # 8000555a <kfilewrite>
}
    80004a8a:	60a2                	ld	ra,8(sp)
    80004a8c:	6402                	ld	s0,0(sp)
    80004a8e:	0141                	addi	sp,sp,16
    80004a90:	8082                	ret

0000000080004a92 <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004a92:	1141                	addi	sp,sp,-16
    80004a94:	e406                	sd	ra,8(sp)
    80004a96:	e022                	sd	s0,0(sp)
    80004a98:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004a9a:	16853783          	ld	a5,360(a0)
    80004a9e:	d390                	sw	a2,32(a5)
  return kfileread(p->swapFile, (uint64)buffer,  size);
    80004aa0:	8636                	mv	a2,a3
    80004aa2:	16853503          	ld	a0,360(a0)
    80004aa6:	00001097          	auipc	ra,0x1
    80004aaa:	9f2080e7          	jalr	-1550(ra) # 80005498 <kfileread>
    80004aae:	60a2                	ld	ra,8(sp)
    80004ab0:	6402                	ld	s0,0(sp)
    80004ab2:	0141                	addi	sp,sp,16
    80004ab4:	8082                	ret

0000000080004ab6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004ab6:	1101                	addi	sp,sp,-32
    80004ab8:	ec06                	sd	ra,24(sp)
    80004aba:	e822                	sd	s0,16(sp)
    80004abc:	e426                	sd	s1,8(sp)
    80004abe:	e04a                	sd	s2,0(sp)
    80004ac0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004ac2:	00026917          	auipc	s2,0x26
    80004ac6:	fae90913          	addi	s2,s2,-82 # 8002aa70 <log>
    80004aca:	01892583          	lw	a1,24(s2)
    80004ace:	02892503          	lw	a0,40(s2)
    80004ad2:	fffff097          	auipc	ra,0xfffff
    80004ad6:	cde080e7          	jalr	-802(ra) # 800037b0 <bread>
    80004ada:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004adc:	02c92683          	lw	a3,44(s2)
    80004ae0:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004ae2:	02d05863          	blez	a3,80004b12 <write_head+0x5c>
    80004ae6:	00026797          	auipc	a5,0x26
    80004aea:	fba78793          	addi	a5,a5,-70 # 8002aaa0 <log+0x30>
    80004aee:	05c50713          	addi	a4,a0,92
    80004af2:	36fd                	addiw	a3,a3,-1
    80004af4:	02069613          	slli	a2,a3,0x20
    80004af8:	01e65693          	srli	a3,a2,0x1e
    80004afc:	00026617          	auipc	a2,0x26
    80004b00:	fa860613          	addi	a2,a2,-88 # 8002aaa4 <log+0x34>
    80004b04:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004b06:	4390                	lw	a2,0(a5)
    80004b08:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004b0a:	0791                	addi	a5,a5,4
    80004b0c:	0711                	addi	a4,a4,4
    80004b0e:	fed79ce3          	bne	a5,a3,80004b06 <write_head+0x50>
  }
  bwrite(buf);
    80004b12:	8526                	mv	a0,s1
    80004b14:	fffff097          	auipc	ra,0xfffff
    80004b18:	d8e080e7          	jalr	-626(ra) # 800038a2 <bwrite>
  brelse(buf);
    80004b1c:	8526                	mv	a0,s1
    80004b1e:	fffff097          	auipc	ra,0xfffff
    80004b22:	dc2080e7          	jalr	-574(ra) # 800038e0 <brelse>
}
    80004b26:	60e2                	ld	ra,24(sp)
    80004b28:	6442                	ld	s0,16(sp)
    80004b2a:	64a2                	ld	s1,8(sp)
    80004b2c:	6902                	ld	s2,0(sp)
    80004b2e:	6105                	addi	sp,sp,32
    80004b30:	8082                	ret

0000000080004b32 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b32:	00026797          	auipc	a5,0x26
    80004b36:	f6a7a783          	lw	a5,-150(a5) # 8002aa9c <log+0x2c>
    80004b3a:	0af05d63          	blez	a5,80004bf4 <install_trans+0xc2>
{
    80004b3e:	7139                	addi	sp,sp,-64
    80004b40:	fc06                	sd	ra,56(sp)
    80004b42:	f822                	sd	s0,48(sp)
    80004b44:	f426                	sd	s1,40(sp)
    80004b46:	f04a                	sd	s2,32(sp)
    80004b48:	ec4e                	sd	s3,24(sp)
    80004b4a:	e852                	sd	s4,16(sp)
    80004b4c:	e456                	sd	s5,8(sp)
    80004b4e:	e05a                	sd	s6,0(sp)
    80004b50:	0080                	addi	s0,sp,64
    80004b52:	8b2a                	mv	s6,a0
    80004b54:	00026a97          	auipc	s5,0x26
    80004b58:	f4ca8a93          	addi	s5,s5,-180 # 8002aaa0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b5c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004b5e:	00026997          	auipc	s3,0x26
    80004b62:	f1298993          	addi	s3,s3,-238 # 8002aa70 <log>
    80004b66:	a00d                	j	80004b88 <install_trans+0x56>
    brelse(lbuf);
    80004b68:	854a                	mv	a0,s2
    80004b6a:	fffff097          	auipc	ra,0xfffff
    80004b6e:	d76080e7          	jalr	-650(ra) # 800038e0 <brelse>
    brelse(dbuf);
    80004b72:	8526                	mv	a0,s1
    80004b74:	fffff097          	auipc	ra,0xfffff
    80004b78:	d6c080e7          	jalr	-660(ra) # 800038e0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b7c:	2a05                	addiw	s4,s4,1
    80004b7e:	0a91                	addi	s5,s5,4
    80004b80:	02c9a783          	lw	a5,44(s3)
    80004b84:	04fa5e63          	bge	s4,a5,80004be0 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004b88:	0189a583          	lw	a1,24(s3)
    80004b8c:	014585bb          	addw	a1,a1,s4
    80004b90:	2585                	addiw	a1,a1,1
    80004b92:	0289a503          	lw	a0,40(s3)
    80004b96:	fffff097          	auipc	ra,0xfffff
    80004b9a:	c1a080e7          	jalr	-998(ra) # 800037b0 <bread>
    80004b9e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004ba0:	000aa583          	lw	a1,0(s5)
    80004ba4:	0289a503          	lw	a0,40(s3)
    80004ba8:	fffff097          	auipc	ra,0xfffff
    80004bac:	c08080e7          	jalr	-1016(ra) # 800037b0 <bread>
    80004bb0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004bb2:	40000613          	li	a2,1024
    80004bb6:	05890593          	addi	a1,s2,88
    80004bba:	05850513          	addi	a0,a0,88
    80004bbe:	ffffc097          	auipc	ra,0xffffc
    80004bc2:	15c080e7          	jalr	348(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004bc6:	8526                	mv	a0,s1
    80004bc8:	fffff097          	auipc	ra,0xfffff
    80004bcc:	cda080e7          	jalr	-806(ra) # 800038a2 <bwrite>
    if(recovering == 0)
    80004bd0:	f80b1ce3          	bnez	s6,80004b68 <install_trans+0x36>
      bunpin(dbuf);
    80004bd4:	8526                	mv	a0,s1
    80004bd6:	fffff097          	auipc	ra,0xfffff
    80004bda:	de4080e7          	jalr	-540(ra) # 800039ba <bunpin>
    80004bde:	b769                	j	80004b68 <install_trans+0x36>
}
    80004be0:	70e2                	ld	ra,56(sp)
    80004be2:	7442                	ld	s0,48(sp)
    80004be4:	74a2                	ld	s1,40(sp)
    80004be6:	7902                	ld	s2,32(sp)
    80004be8:	69e2                	ld	s3,24(sp)
    80004bea:	6a42                	ld	s4,16(sp)
    80004bec:	6aa2                	ld	s5,8(sp)
    80004bee:	6b02                	ld	s6,0(sp)
    80004bf0:	6121                	addi	sp,sp,64
    80004bf2:	8082                	ret
    80004bf4:	8082                	ret

0000000080004bf6 <initlog>:
{
    80004bf6:	7179                	addi	sp,sp,-48
    80004bf8:	f406                	sd	ra,40(sp)
    80004bfa:	f022                	sd	s0,32(sp)
    80004bfc:	ec26                	sd	s1,24(sp)
    80004bfe:	e84a                	sd	s2,16(sp)
    80004c00:	e44e                	sd	s3,8(sp)
    80004c02:	1800                	addi	s0,sp,48
    80004c04:	892a                	mv	s2,a0
    80004c06:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004c08:	00026497          	auipc	s1,0x26
    80004c0c:	e6848493          	addi	s1,s1,-408 # 8002aa70 <log>
    80004c10:	00005597          	auipc	a1,0x5
    80004c14:	eb858593          	addi	a1,a1,-328 # 80009ac8 <syscalls+0x248>
    80004c18:	8526                	mv	a0,s1
    80004c1a:	ffffc097          	auipc	ra,0xffffc
    80004c1e:	f18080e7          	jalr	-232(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004c22:	0149a583          	lw	a1,20(s3)
    80004c26:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004c28:	0109a783          	lw	a5,16(s3)
    80004c2c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004c2e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004c32:	854a                	mv	a0,s2
    80004c34:	fffff097          	auipc	ra,0xfffff
    80004c38:	b7c080e7          	jalr	-1156(ra) # 800037b0 <bread>
  log.lh.n = lh->n;
    80004c3c:	4d34                	lw	a3,88(a0)
    80004c3e:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004c40:	02d05663          	blez	a3,80004c6c <initlog+0x76>
    80004c44:	05c50793          	addi	a5,a0,92
    80004c48:	00026717          	auipc	a4,0x26
    80004c4c:	e5870713          	addi	a4,a4,-424 # 8002aaa0 <log+0x30>
    80004c50:	36fd                	addiw	a3,a3,-1
    80004c52:	02069613          	slli	a2,a3,0x20
    80004c56:	01e65693          	srli	a3,a2,0x1e
    80004c5a:	06050613          	addi	a2,a0,96
    80004c5e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004c60:	4390                	lw	a2,0(a5)
    80004c62:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004c64:	0791                	addi	a5,a5,4
    80004c66:	0711                	addi	a4,a4,4
    80004c68:	fed79ce3          	bne	a5,a3,80004c60 <initlog+0x6a>
  brelse(buf);
    80004c6c:	fffff097          	auipc	ra,0xfffff
    80004c70:	c74080e7          	jalr	-908(ra) # 800038e0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004c74:	4505                	li	a0,1
    80004c76:	00000097          	auipc	ra,0x0
    80004c7a:	ebc080e7          	jalr	-324(ra) # 80004b32 <install_trans>
  log.lh.n = 0;
    80004c7e:	00026797          	auipc	a5,0x26
    80004c82:	e007af23          	sw	zero,-482(a5) # 8002aa9c <log+0x2c>
  write_head(); // clear the log
    80004c86:	00000097          	auipc	ra,0x0
    80004c8a:	e30080e7          	jalr	-464(ra) # 80004ab6 <write_head>
}
    80004c8e:	70a2                	ld	ra,40(sp)
    80004c90:	7402                	ld	s0,32(sp)
    80004c92:	64e2                	ld	s1,24(sp)
    80004c94:	6942                	ld	s2,16(sp)
    80004c96:	69a2                	ld	s3,8(sp)
    80004c98:	6145                	addi	sp,sp,48
    80004c9a:	8082                	ret

0000000080004c9c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004c9c:	1101                	addi	sp,sp,-32
    80004c9e:	ec06                	sd	ra,24(sp)
    80004ca0:	e822                	sd	s0,16(sp)
    80004ca2:	e426                	sd	s1,8(sp)
    80004ca4:	e04a                	sd	s2,0(sp)
    80004ca6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004ca8:	00026517          	auipc	a0,0x26
    80004cac:	dc850513          	addi	a0,a0,-568 # 8002aa70 <log>
    80004cb0:	ffffc097          	auipc	ra,0xffffc
    80004cb4:	f12080e7          	jalr	-238(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    80004cb8:	00026497          	auipc	s1,0x26
    80004cbc:	db848493          	addi	s1,s1,-584 # 8002aa70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004cc0:	4979                	li	s2,30
    80004cc2:	a039                	j	80004cd0 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004cc4:	85a6                	mv	a1,s1
    80004cc6:	8526                	mv	a0,s1
    80004cc8:	ffffd097          	auipc	ra,0xffffd
    80004ccc:	446080e7          	jalr	1094(ra) # 8000210e <sleep>
    if(log.committing){
    80004cd0:	50dc                	lw	a5,36(s1)
    80004cd2:	fbed                	bnez	a5,80004cc4 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004cd4:	509c                	lw	a5,32(s1)
    80004cd6:	0017871b          	addiw	a4,a5,1
    80004cda:	0007069b          	sext.w	a3,a4
    80004cde:	0027179b          	slliw	a5,a4,0x2
    80004ce2:	9fb9                	addw	a5,a5,a4
    80004ce4:	0017979b          	slliw	a5,a5,0x1
    80004ce8:	54d8                	lw	a4,44(s1)
    80004cea:	9fb9                	addw	a5,a5,a4
    80004cec:	00f95963          	bge	s2,a5,80004cfe <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004cf0:	85a6                	mv	a1,s1
    80004cf2:	8526                	mv	a0,s1
    80004cf4:	ffffd097          	auipc	ra,0xffffd
    80004cf8:	41a080e7          	jalr	1050(ra) # 8000210e <sleep>
    80004cfc:	bfd1                	j	80004cd0 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004cfe:	00026517          	auipc	a0,0x26
    80004d02:	d7250513          	addi	a0,a0,-654 # 8002aa70 <log>
    80004d06:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004d08:	ffffc097          	auipc	ra,0xffffc
    80004d0c:	f6e080e7          	jalr	-146(ra) # 80000c76 <release>
      break;
    }
  }
}
    80004d10:	60e2                	ld	ra,24(sp)
    80004d12:	6442                	ld	s0,16(sp)
    80004d14:	64a2                	ld	s1,8(sp)
    80004d16:	6902                	ld	s2,0(sp)
    80004d18:	6105                	addi	sp,sp,32
    80004d1a:	8082                	ret

0000000080004d1c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004d1c:	7139                	addi	sp,sp,-64
    80004d1e:	fc06                	sd	ra,56(sp)
    80004d20:	f822                	sd	s0,48(sp)
    80004d22:	f426                	sd	s1,40(sp)
    80004d24:	f04a                	sd	s2,32(sp)
    80004d26:	ec4e                	sd	s3,24(sp)
    80004d28:	e852                	sd	s4,16(sp)
    80004d2a:	e456                	sd	s5,8(sp)
    80004d2c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004d2e:	00026497          	auipc	s1,0x26
    80004d32:	d4248493          	addi	s1,s1,-702 # 8002aa70 <log>
    80004d36:	8526                	mv	a0,s1
    80004d38:	ffffc097          	auipc	ra,0xffffc
    80004d3c:	e8a080e7          	jalr	-374(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004d40:	509c                	lw	a5,32(s1)
    80004d42:	37fd                	addiw	a5,a5,-1
    80004d44:	0007891b          	sext.w	s2,a5
    80004d48:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004d4a:	50dc                	lw	a5,36(s1)
    80004d4c:	e7b9                	bnez	a5,80004d9a <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004d4e:	04091e63          	bnez	s2,80004daa <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004d52:	00026497          	auipc	s1,0x26
    80004d56:	d1e48493          	addi	s1,s1,-738 # 8002aa70 <log>
    80004d5a:	4785                	li	a5,1
    80004d5c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004d5e:	8526                	mv	a0,s1
    80004d60:	ffffc097          	auipc	ra,0xffffc
    80004d64:	f16080e7          	jalr	-234(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004d68:	54dc                	lw	a5,44(s1)
    80004d6a:	06f04763          	bgtz	a5,80004dd8 <end_op+0xbc>
    acquire(&log.lock);
    80004d6e:	00026497          	auipc	s1,0x26
    80004d72:	d0248493          	addi	s1,s1,-766 # 8002aa70 <log>
    80004d76:	8526                	mv	a0,s1
    80004d78:	ffffc097          	auipc	ra,0xffffc
    80004d7c:	e4a080e7          	jalr	-438(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004d80:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004d84:	8526                	mv	a0,s1
    80004d86:	ffffd097          	auipc	ra,0xffffd
    80004d8a:	514080e7          	jalr	1300(ra) # 8000229a <wakeup>
    release(&log.lock);
    80004d8e:	8526                	mv	a0,s1
    80004d90:	ffffc097          	auipc	ra,0xffffc
    80004d94:	ee6080e7          	jalr	-282(ra) # 80000c76 <release>
}
    80004d98:	a03d                	j	80004dc6 <end_op+0xaa>
    panic("log.committing");
    80004d9a:	00005517          	auipc	a0,0x5
    80004d9e:	d3650513          	addi	a0,a0,-714 # 80009ad0 <syscalls+0x250>
    80004da2:	ffffb097          	auipc	ra,0xffffb
    80004da6:	788080e7          	jalr	1928(ra) # 8000052a <panic>
    wakeup(&log);
    80004daa:	00026497          	auipc	s1,0x26
    80004dae:	cc648493          	addi	s1,s1,-826 # 8002aa70 <log>
    80004db2:	8526                	mv	a0,s1
    80004db4:	ffffd097          	auipc	ra,0xffffd
    80004db8:	4e6080e7          	jalr	1254(ra) # 8000229a <wakeup>
  release(&log.lock);
    80004dbc:	8526                	mv	a0,s1
    80004dbe:	ffffc097          	auipc	ra,0xffffc
    80004dc2:	eb8080e7          	jalr	-328(ra) # 80000c76 <release>
}
    80004dc6:	70e2                	ld	ra,56(sp)
    80004dc8:	7442                	ld	s0,48(sp)
    80004dca:	74a2                	ld	s1,40(sp)
    80004dcc:	7902                	ld	s2,32(sp)
    80004dce:	69e2                	ld	s3,24(sp)
    80004dd0:	6a42                	ld	s4,16(sp)
    80004dd2:	6aa2                	ld	s5,8(sp)
    80004dd4:	6121                	addi	sp,sp,64
    80004dd6:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004dd8:	00026a97          	auipc	s5,0x26
    80004ddc:	cc8a8a93          	addi	s5,s5,-824 # 8002aaa0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004de0:	00026a17          	auipc	s4,0x26
    80004de4:	c90a0a13          	addi	s4,s4,-880 # 8002aa70 <log>
    80004de8:	018a2583          	lw	a1,24(s4)
    80004dec:	012585bb          	addw	a1,a1,s2
    80004df0:	2585                	addiw	a1,a1,1
    80004df2:	028a2503          	lw	a0,40(s4)
    80004df6:	fffff097          	auipc	ra,0xfffff
    80004dfa:	9ba080e7          	jalr	-1606(ra) # 800037b0 <bread>
    80004dfe:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004e00:	000aa583          	lw	a1,0(s5)
    80004e04:	028a2503          	lw	a0,40(s4)
    80004e08:	fffff097          	auipc	ra,0xfffff
    80004e0c:	9a8080e7          	jalr	-1624(ra) # 800037b0 <bread>
    80004e10:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004e12:	40000613          	li	a2,1024
    80004e16:	05850593          	addi	a1,a0,88
    80004e1a:	05848513          	addi	a0,s1,88
    80004e1e:	ffffc097          	auipc	ra,0xffffc
    80004e22:	efc080e7          	jalr	-260(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004e26:	8526                	mv	a0,s1
    80004e28:	fffff097          	auipc	ra,0xfffff
    80004e2c:	a7a080e7          	jalr	-1414(ra) # 800038a2 <bwrite>
    brelse(from);
    80004e30:	854e                	mv	a0,s3
    80004e32:	fffff097          	auipc	ra,0xfffff
    80004e36:	aae080e7          	jalr	-1362(ra) # 800038e0 <brelse>
    brelse(to);
    80004e3a:	8526                	mv	a0,s1
    80004e3c:	fffff097          	auipc	ra,0xfffff
    80004e40:	aa4080e7          	jalr	-1372(ra) # 800038e0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004e44:	2905                	addiw	s2,s2,1
    80004e46:	0a91                	addi	s5,s5,4
    80004e48:	02ca2783          	lw	a5,44(s4)
    80004e4c:	f8f94ee3          	blt	s2,a5,80004de8 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004e50:	00000097          	auipc	ra,0x0
    80004e54:	c66080e7          	jalr	-922(ra) # 80004ab6 <write_head>
    install_trans(0); // Now install writes to home locations
    80004e58:	4501                	li	a0,0
    80004e5a:	00000097          	auipc	ra,0x0
    80004e5e:	cd8080e7          	jalr	-808(ra) # 80004b32 <install_trans>
    log.lh.n = 0;
    80004e62:	00026797          	auipc	a5,0x26
    80004e66:	c207ad23          	sw	zero,-966(a5) # 8002aa9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004e6a:	00000097          	auipc	ra,0x0
    80004e6e:	c4c080e7          	jalr	-948(ra) # 80004ab6 <write_head>
    80004e72:	bdf5                	j	80004d6e <end_op+0x52>

0000000080004e74 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004e74:	1101                	addi	sp,sp,-32
    80004e76:	ec06                	sd	ra,24(sp)
    80004e78:	e822                	sd	s0,16(sp)
    80004e7a:	e426                	sd	s1,8(sp)
    80004e7c:	e04a                	sd	s2,0(sp)
    80004e7e:	1000                	addi	s0,sp,32
    80004e80:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004e82:	00026917          	auipc	s2,0x26
    80004e86:	bee90913          	addi	s2,s2,-1042 # 8002aa70 <log>
    80004e8a:	854a                	mv	a0,s2
    80004e8c:	ffffc097          	auipc	ra,0xffffc
    80004e90:	d36080e7          	jalr	-714(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004e94:	02c92603          	lw	a2,44(s2)
    80004e98:	47f5                	li	a5,29
    80004e9a:	06c7c563          	blt	a5,a2,80004f04 <log_write+0x90>
    80004e9e:	00026797          	auipc	a5,0x26
    80004ea2:	bee7a783          	lw	a5,-1042(a5) # 8002aa8c <log+0x1c>
    80004ea6:	37fd                	addiw	a5,a5,-1
    80004ea8:	04f65e63          	bge	a2,a5,80004f04 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004eac:	00026797          	auipc	a5,0x26
    80004eb0:	be47a783          	lw	a5,-1052(a5) # 8002aa90 <log+0x20>
    80004eb4:	06f05063          	blez	a5,80004f14 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004eb8:	4781                	li	a5,0
    80004eba:	06c05563          	blez	a2,80004f24 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004ebe:	44cc                	lw	a1,12(s1)
    80004ec0:	00026717          	auipc	a4,0x26
    80004ec4:	be070713          	addi	a4,a4,-1056 # 8002aaa0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004ec8:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004eca:	4314                	lw	a3,0(a4)
    80004ecc:	04b68c63          	beq	a3,a1,80004f24 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004ed0:	2785                	addiw	a5,a5,1
    80004ed2:	0711                	addi	a4,a4,4
    80004ed4:	fef61be3          	bne	a2,a5,80004eca <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004ed8:	0621                	addi	a2,a2,8
    80004eda:	060a                	slli	a2,a2,0x2
    80004edc:	00026797          	auipc	a5,0x26
    80004ee0:	b9478793          	addi	a5,a5,-1132 # 8002aa70 <log>
    80004ee4:	963e                	add	a2,a2,a5
    80004ee6:	44dc                	lw	a5,12(s1)
    80004ee8:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004eea:	8526                	mv	a0,s1
    80004eec:	fffff097          	auipc	ra,0xfffff
    80004ef0:	a92080e7          	jalr	-1390(ra) # 8000397e <bpin>
    log.lh.n++;
    80004ef4:	00026717          	auipc	a4,0x26
    80004ef8:	b7c70713          	addi	a4,a4,-1156 # 8002aa70 <log>
    80004efc:	575c                	lw	a5,44(a4)
    80004efe:	2785                	addiw	a5,a5,1
    80004f00:	d75c                	sw	a5,44(a4)
    80004f02:	a835                	j	80004f3e <log_write+0xca>
    panic("too big a transaction");
    80004f04:	00005517          	auipc	a0,0x5
    80004f08:	bdc50513          	addi	a0,a0,-1060 # 80009ae0 <syscalls+0x260>
    80004f0c:	ffffb097          	auipc	ra,0xffffb
    80004f10:	61e080e7          	jalr	1566(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004f14:	00005517          	auipc	a0,0x5
    80004f18:	be450513          	addi	a0,a0,-1052 # 80009af8 <syscalls+0x278>
    80004f1c:	ffffb097          	auipc	ra,0xffffb
    80004f20:	60e080e7          	jalr	1550(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004f24:	00878713          	addi	a4,a5,8
    80004f28:	00271693          	slli	a3,a4,0x2
    80004f2c:	00026717          	auipc	a4,0x26
    80004f30:	b4470713          	addi	a4,a4,-1212 # 8002aa70 <log>
    80004f34:	9736                	add	a4,a4,a3
    80004f36:	44d4                	lw	a3,12(s1)
    80004f38:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004f3a:	faf608e3          	beq	a2,a5,80004eea <log_write+0x76>
  }
  release(&log.lock);
    80004f3e:	00026517          	auipc	a0,0x26
    80004f42:	b3250513          	addi	a0,a0,-1230 # 8002aa70 <log>
    80004f46:	ffffc097          	auipc	ra,0xffffc
    80004f4a:	d30080e7          	jalr	-720(ra) # 80000c76 <release>
}
    80004f4e:	60e2                	ld	ra,24(sp)
    80004f50:	6442                	ld	s0,16(sp)
    80004f52:	64a2                	ld	s1,8(sp)
    80004f54:	6902                	ld	s2,0(sp)
    80004f56:	6105                	addi	sp,sp,32
    80004f58:	8082                	ret

0000000080004f5a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004f5a:	1101                	addi	sp,sp,-32
    80004f5c:	ec06                	sd	ra,24(sp)
    80004f5e:	e822                	sd	s0,16(sp)
    80004f60:	e426                	sd	s1,8(sp)
    80004f62:	e04a                	sd	s2,0(sp)
    80004f64:	1000                	addi	s0,sp,32
    80004f66:	84aa                	mv	s1,a0
    80004f68:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004f6a:	00005597          	auipc	a1,0x5
    80004f6e:	bae58593          	addi	a1,a1,-1106 # 80009b18 <syscalls+0x298>
    80004f72:	0521                	addi	a0,a0,8
    80004f74:	ffffc097          	auipc	ra,0xffffc
    80004f78:	bbe080e7          	jalr	-1090(ra) # 80000b32 <initlock>
  lk->name = name;
    80004f7c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004f80:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004f84:	0204a423          	sw	zero,40(s1)
}
    80004f88:	60e2                	ld	ra,24(sp)
    80004f8a:	6442                	ld	s0,16(sp)
    80004f8c:	64a2                	ld	s1,8(sp)
    80004f8e:	6902                	ld	s2,0(sp)
    80004f90:	6105                	addi	sp,sp,32
    80004f92:	8082                	ret

0000000080004f94 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004f94:	1101                	addi	sp,sp,-32
    80004f96:	ec06                	sd	ra,24(sp)
    80004f98:	e822                	sd	s0,16(sp)
    80004f9a:	e426                	sd	s1,8(sp)
    80004f9c:	e04a                	sd	s2,0(sp)
    80004f9e:	1000                	addi	s0,sp,32
    80004fa0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004fa2:	00850913          	addi	s2,a0,8
    80004fa6:	854a                	mv	a0,s2
    80004fa8:	ffffc097          	auipc	ra,0xffffc
    80004fac:	c1a080e7          	jalr	-998(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    80004fb0:	409c                	lw	a5,0(s1)
    80004fb2:	cb89                	beqz	a5,80004fc4 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004fb4:	85ca                	mv	a1,s2
    80004fb6:	8526                	mv	a0,s1
    80004fb8:	ffffd097          	auipc	ra,0xffffd
    80004fbc:	156080e7          	jalr	342(ra) # 8000210e <sleep>
  while (lk->locked) {
    80004fc0:	409c                	lw	a5,0(s1)
    80004fc2:	fbed                	bnez	a5,80004fb4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004fc4:	4785                	li	a5,1
    80004fc6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004fc8:	ffffd097          	auipc	ra,0xffffd
    80004fcc:	bae080e7          	jalr	-1106(ra) # 80001b76 <myproc>
    80004fd0:	591c                	lw	a5,48(a0)
    80004fd2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004fd4:	854a                	mv	a0,s2
    80004fd6:	ffffc097          	auipc	ra,0xffffc
    80004fda:	ca0080e7          	jalr	-864(ra) # 80000c76 <release>
}
    80004fde:	60e2                	ld	ra,24(sp)
    80004fe0:	6442                	ld	s0,16(sp)
    80004fe2:	64a2                	ld	s1,8(sp)
    80004fe4:	6902                	ld	s2,0(sp)
    80004fe6:	6105                	addi	sp,sp,32
    80004fe8:	8082                	ret

0000000080004fea <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004fea:	1101                	addi	sp,sp,-32
    80004fec:	ec06                	sd	ra,24(sp)
    80004fee:	e822                	sd	s0,16(sp)
    80004ff0:	e426                	sd	s1,8(sp)
    80004ff2:	e04a                	sd	s2,0(sp)
    80004ff4:	1000                	addi	s0,sp,32
    80004ff6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004ff8:	00850913          	addi	s2,a0,8
    80004ffc:	854a                	mv	a0,s2
    80004ffe:	ffffc097          	auipc	ra,0xffffc
    80005002:	bc4080e7          	jalr	-1084(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80005006:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000500a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000500e:	8526                	mv	a0,s1
    80005010:	ffffd097          	auipc	ra,0xffffd
    80005014:	28a080e7          	jalr	650(ra) # 8000229a <wakeup>
  release(&lk->lk);
    80005018:	854a                	mv	a0,s2
    8000501a:	ffffc097          	auipc	ra,0xffffc
    8000501e:	c5c080e7          	jalr	-932(ra) # 80000c76 <release>
}
    80005022:	60e2                	ld	ra,24(sp)
    80005024:	6442                	ld	s0,16(sp)
    80005026:	64a2                	ld	s1,8(sp)
    80005028:	6902                	ld	s2,0(sp)
    8000502a:	6105                	addi	sp,sp,32
    8000502c:	8082                	ret

000000008000502e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000502e:	7179                	addi	sp,sp,-48
    80005030:	f406                	sd	ra,40(sp)
    80005032:	f022                	sd	s0,32(sp)
    80005034:	ec26                	sd	s1,24(sp)
    80005036:	e84a                	sd	s2,16(sp)
    80005038:	e44e                	sd	s3,8(sp)
    8000503a:	1800                	addi	s0,sp,48
    8000503c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000503e:	00850913          	addi	s2,a0,8
    80005042:	854a                	mv	a0,s2
    80005044:	ffffc097          	auipc	ra,0xffffc
    80005048:	b7e080e7          	jalr	-1154(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000504c:	409c                	lw	a5,0(s1)
    8000504e:	ef99                	bnez	a5,8000506c <holdingsleep+0x3e>
    80005050:	4481                	li	s1,0
  release(&lk->lk);
    80005052:	854a                	mv	a0,s2
    80005054:	ffffc097          	auipc	ra,0xffffc
    80005058:	c22080e7          	jalr	-990(ra) # 80000c76 <release>
  return r;
}
    8000505c:	8526                	mv	a0,s1
    8000505e:	70a2                	ld	ra,40(sp)
    80005060:	7402                	ld	s0,32(sp)
    80005062:	64e2                	ld	s1,24(sp)
    80005064:	6942                	ld	s2,16(sp)
    80005066:	69a2                	ld	s3,8(sp)
    80005068:	6145                	addi	sp,sp,48
    8000506a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000506c:	0284a983          	lw	s3,40(s1)
    80005070:	ffffd097          	auipc	ra,0xffffd
    80005074:	b06080e7          	jalr	-1274(ra) # 80001b76 <myproc>
    80005078:	5904                	lw	s1,48(a0)
    8000507a:	413484b3          	sub	s1,s1,s3
    8000507e:	0014b493          	seqz	s1,s1
    80005082:	bfc1                	j	80005052 <holdingsleep+0x24>

0000000080005084 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80005084:	1141                	addi	sp,sp,-16
    80005086:	e406                	sd	ra,8(sp)
    80005088:	e022                	sd	s0,0(sp)
    8000508a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000508c:	00005597          	auipc	a1,0x5
    80005090:	a9c58593          	addi	a1,a1,-1380 # 80009b28 <syscalls+0x2a8>
    80005094:	00026517          	auipc	a0,0x26
    80005098:	b2450513          	addi	a0,a0,-1244 # 8002abb8 <ftable>
    8000509c:	ffffc097          	auipc	ra,0xffffc
    800050a0:	a96080e7          	jalr	-1386(ra) # 80000b32 <initlock>
}
    800050a4:	60a2                	ld	ra,8(sp)
    800050a6:	6402                	ld	s0,0(sp)
    800050a8:	0141                	addi	sp,sp,16
    800050aa:	8082                	ret

00000000800050ac <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800050ac:	1101                	addi	sp,sp,-32
    800050ae:	ec06                	sd	ra,24(sp)
    800050b0:	e822                	sd	s0,16(sp)
    800050b2:	e426                	sd	s1,8(sp)
    800050b4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800050b6:	00026517          	auipc	a0,0x26
    800050ba:	b0250513          	addi	a0,a0,-1278 # 8002abb8 <ftable>
    800050be:	ffffc097          	auipc	ra,0xffffc
    800050c2:	b04080e7          	jalr	-1276(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800050c6:	00026497          	auipc	s1,0x26
    800050ca:	b0a48493          	addi	s1,s1,-1270 # 8002abd0 <ftable+0x18>
    800050ce:	00027717          	auipc	a4,0x27
    800050d2:	aa270713          	addi	a4,a4,-1374 # 8002bb70 <ftable+0xfb8>
    if(f->ref == 0){
    800050d6:	40dc                	lw	a5,4(s1)
    800050d8:	cf99                	beqz	a5,800050f6 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800050da:	02848493          	addi	s1,s1,40
    800050de:	fee49ce3          	bne	s1,a4,800050d6 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800050e2:	00026517          	auipc	a0,0x26
    800050e6:	ad650513          	addi	a0,a0,-1322 # 8002abb8 <ftable>
    800050ea:	ffffc097          	auipc	ra,0xffffc
    800050ee:	b8c080e7          	jalr	-1140(ra) # 80000c76 <release>
  return 0;
    800050f2:	4481                	li	s1,0
    800050f4:	a819                	j	8000510a <filealloc+0x5e>
      f->ref = 1;
    800050f6:	4785                	li	a5,1
    800050f8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800050fa:	00026517          	auipc	a0,0x26
    800050fe:	abe50513          	addi	a0,a0,-1346 # 8002abb8 <ftable>
    80005102:	ffffc097          	auipc	ra,0xffffc
    80005106:	b74080e7          	jalr	-1164(ra) # 80000c76 <release>
}
    8000510a:	8526                	mv	a0,s1
    8000510c:	60e2                	ld	ra,24(sp)
    8000510e:	6442                	ld	s0,16(sp)
    80005110:	64a2                	ld	s1,8(sp)
    80005112:	6105                	addi	sp,sp,32
    80005114:	8082                	ret

0000000080005116 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005116:	1101                	addi	sp,sp,-32
    80005118:	ec06                	sd	ra,24(sp)
    8000511a:	e822                	sd	s0,16(sp)
    8000511c:	e426                	sd	s1,8(sp)
    8000511e:	1000                	addi	s0,sp,32
    80005120:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005122:	00026517          	auipc	a0,0x26
    80005126:	a9650513          	addi	a0,a0,-1386 # 8002abb8 <ftable>
    8000512a:	ffffc097          	auipc	ra,0xffffc
    8000512e:	a98080e7          	jalr	-1384(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80005132:	40dc                	lw	a5,4(s1)
    80005134:	02f05263          	blez	a5,80005158 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80005138:	2785                	addiw	a5,a5,1
    8000513a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000513c:	00026517          	auipc	a0,0x26
    80005140:	a7c50513          	addi	a0,a0,-1412 # 8002abb8 <ftable>
    80005144:	ffffc097          	auipc	ra,0xffffc
    80005148:	b32080e7          	jalr	-1230(ra) # 80000c76 <release>
  return f;
}
    8000514c:	8526                	mv	a0,s1
    8000514e:	60e2                	ld	ra,24(sp)
    80005150:	6442                	ld	s0,16(sp)
    80005152:	64a2                	ld	s1,8(sp)
    80005154:	6105                	addi	sp,sp,32
    80005156:	8082                	ret
    panic("filedup");
    80005158:	00005517          	auipc	a0,0x5
    8000515c:	9d850513          	addi	a0,a0,-1576 # 80009b30 <syscalls+0x2b0>
    80005160:	ffffb097          	auipc	ra,0xffffb
    80005164:	3ca080e7          	jalr	970(ra) # 8000052a <panic>

0000000080005168 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80005168:	7139                	addi	sp,sp,-64
    8000516a:	fc06                	sd	ra,56(sp)
    8000516c:	f822                	sd	s0,48(sp)
    8000516e:	f426                	sd	s1,40(sp)
    80005170:	f04a                	sd	s2,32(sp)
    80005172:	ec4e                	sd	s3,24(sp)
    80005174:	e852                	sd	s4,16(sp)
    80005176:	e456                	sd	s5,8(sp)
    80005178:	0080                	addi	s0,sp,64
    8000517a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000517c:	00026517          	auipc	a0,0x26
    80005180:	a3c50513          	addi	a0,a0,-1476 # 8002abb8 <ftable>
    80005184:	ffffc097          	auipc	ra,0xffffc
    80005188:	a3e080e7          	jalr	-1474(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    8000518c:	40dc                	lw	a5,4(s1)
    8000518e:	06f05163          	blez	a5,800051f0 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80005192:	37fd                	addiw	a5,a5,-1
    80005194:	0007871b          	sext.w	a4,a5
    80005198:	c0dc                	sw	a5,4(s1)
    8000519a:	06e04363          	bgtz	a4,80005200 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000519e:	0004a903          	lw	s2,0(s1)
    800051a2:	0094ca83          	lbu	s5,9(s1)
    800051a6:	0104ba03          	ld	s4,16(s1)
    800051aa:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800051ae:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800051b2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800051b6:	00026517          	auipc	a0,0x26
    800051ba:	a0250513          	addi	a0,a0,-1534 # 8002abb8 <ftable>
    800051be:	ffffc097          	auipc	ra,0xffffc
    800051c2:	ab8080e7          	jalr	-1352(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    800051c6:	4785                	li	a5,1
    800051c8:	04f90d63          	beq	s2,a5,80005222 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800051cc:	3979                	addiw	s2,s2,-2
    800051ce:	4785                	li	a5,1
    800051d0:	0527e063          	bltu	a5,s2,80005210 <fileclose+0xa8>
    begin_op();
    800051d4:	00000097          	auipc	ra,0x0
    800051d8:	ac8080e7          	jalr	-1336(ra) # 80004c9c <begin_op>
    iput(ff.ip);
    800051dc:	854e                	mv	a0,s3
    800051de:	fffff097          	auipc	ra,0xfffff
    800051e2:	f90080e7          	jalr	-112(ra) # 8000416e <iput>
    end_op();
    800051e6:	00000097          	auipc	ra,0x0
    800051ea:	b36080e7          	jalr	-1226(ra) # 80004d1c <end_op>
    800051ee:	a00d                	j	80005210 <fileclose+0xa8>
    panic("fileclose");
    800051f0:	00005517          	auipc	a0,0x5
    800051f4:	94850513          	addi	a0,a0,-1720 # 80009b38 <syscalls+0x2b8>
    800051f8:	ffffb097          	auipc	ra,0xffffb
    800051fc:	332080e7          	jalr	818(ra) # 8000052a <panic>
    release(&ftable.lock);
    80005200:	00026517          	auipc	a0,0x26
    80005204:	9b850513          	addi	a0,a0,-1608 # 8002abb8 <ftable>
    80005208:	ffffc097          	auipc	ra,0xffffc
    8000520c:	a6e080e7          	jalr	-1426(ra) # 80000c76 <release>
  }
}
    80005210:	70e2                	ld	ra,56(sp)
    80005212:	7442                	ld	s0,48(sp)
    80005214:	74a2                	ld	s1,40(sp)
    80005216:	7902                	ld	s2,32(sp)
    80005218:	69e2                	ld	s3,24(sp)
    8000521a:	6a42                	ld	s4,16(sp)
    8000521c:	6aa2                	ld	s5,8(sp)
    8000521e:	6121                	addi	sp,sp,64
    80005220:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005222:	85d6                	mv	a1,s5
    80005224:	8552                	mv	a0,s4
    80005226:	00000097          	auipc	ra,0x0
    8000522a:	542080e7          	jalr	1346(ra) # 80005768 <pipeclose>
    8000522e:	b7cd                	j	80005210 <fileclose+0xa8>

0000000080005230 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005230:	715d                	addi	sp,sp,-80
    80005232:	e486                	sd	ra,72(sp)
    80005234:	e0a2                	sd	s0,64(sp)
    80005236:	fc26                	sd	s1,56(sp)
    80005238:	f84a                	sd	s2,48(sp)
    8000523a:	f44e                	sd	s3,40(sp)
    8000523c:	0880                	addi	s0,sp,80
    8000523e:	84aa                	mv	s1,a0
    80005240:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005242:	ffffd097          	auipc	ra,0xffffd
    80005246:	934080e7          	jalr	-1740(ra) # 80001b76 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000524a:	409c                	lw	a5,0(s1)
    8000524c:	37f9                	addiw	a5,a5,-2
    8000524e:	4705                	li	a4,1
    80005250:	04f76763          	bltu	a4,a5,8000529e <filestat+0x6e>
    80005254:	892a                	mv	s2,a0
    ilock(f->ip);
    80005256:	6c88                	ld	a0,24(s1)
    80005258:	fffff097          	auipc	ra,0xfffff
    8000525c:	d5c080e7          	jalr	-676(ra) # 80003fb4 <ilock>
    stati(f->ip, &st);
    80005260:	fb840593          	addi	a1,s0,-72
    80005264:	6c88                	ld	a0,24(s1)
    80005266:	fffff097          	auipc	ra,0xfffff
    8000526a:	fd8080e7          	jalr	-40(ra) # 8000423e <stati>
    iunlock(f->ip);
    8000526e:	6c88                	ld	a0,24(s1)
    80005270:	fffff097          	auipc	ra,0xfffff
    80005274:	e06080e7          	jalr	-506(ra) # 80004076 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005278:	46e1                	li	a3,24
    8000527a:	fb840613          	addi	a2,s0,-72
    8000527e:	85ce                	mv	a1,s3
    80005280:	05093503          	ld	a0,80(s2)
    80005284:	ffffc097          	auipc	ra,0xffffc
    80005288:	110080e7          	jalr	272(ra) # 80001394 <copyout>
    8000528c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80005290:	60a6                	ld	ra,72(sp)
    80005292:	6406                	ld	s0,64(sp)
    80005294:	74e2                	ld	s1,56(sp)
    80005296:	7942                	ld	s2,48(sp)
    80005298:	79a2                	ld	s3,40(sp)
    8000529a:	6161                	addi	sp,sp,80
    8000529c:	8082                	ret
  return -1;
    8000529e:	557d                	li	a0,-1
    800052a0:	bfc5                	j	80005290 <filestat+0x60>

00000000800052a2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800052a2:	7179                	addi	sp,sp,-48
    800052a4:	f406                	sd	ra,40(sp)
    800052a6:	f022                	sd	s0,32(sp)
    800052a8:	ec26                	sd	s1,24(sp)
    800052aa:	e84a                	sd	s2,16(sp)
    800052ac:	e44e                	sd	s3,8(sp)
    800052ae:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800052b0:	00854783          	lbu	a5,8(a0)
    800052b4:	c3d5                	beqz	a5,80005358 <fileread+0xb6>
    800052b6:	84aa                	mv	s1,a0
    800052b8:	89ae                	mv	s3,a1
    800052ba:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800052bc:	411c                	lw	a5,0(a0)
    800052be:	4705                	li	a4,1
    800052c0:	04e78963          	beq	a5,a4,80005312 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800052c4:	470d                	li	a4,3
    800052c6:	04e78d63          	beq	a5,a4,80005320 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800052ca:	4709                	li	a4,2
    800052cc:	06e79e63          	bne	a5,a4,80005348 <fileread+0xa6>
    ilock(f->ip);
    800052d0:	6d08                	ld	a0,24(a0)
    800052d2:	fffff097          	auipc	ra,0xfffff
    800052d6:	ce2080e7          	jalr	-798(ra) # 80003fb4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800052da:	874a                	mv	a4,s2
    800052dc:	5094                	lw	a3,32(s1)
    800052de:	864e                	mv	a2,s3
    800052e0:	4585                	li	a1,1
    800052e2:	6c88                	ld	a0,24(s1)
    800052e4:	fffff097          	auipc	ra,0xfffff
    800052e8:	f84080e7          	jalr	-124(ra) # 80004268 <readi>
    800052ec:	892a                	mv	s2,a0
    800052ee:	00a05563          	blez	a0,800052f8 <fileread+0x56>
      f->off += r;
    800052f2:	509c                	lw	a5,32(s1)
    800052f4:	9fa9                	addw	a5,a5,a0
    800052f6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800052f8:	6c88                	ld	a0,24(s1)
    800052fa:	fffff097          	auipc	ra,0xfffff
    800052fe:	d7c080e7          	jalr	-644(ra) # 80004076 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005302:	854a                	mv	a0,s2
    80005304:	70a2                	ld	ra,40(sp)
    80005306:	7402                	ld	s0,32(sp)
    80005308:	64e2                	ld	s1,24(sp)
    8000530a:	6942                	ld	s2,16(sp)
    8000530c:	69a2                	ld	s3,8(sp)
    8000530e:	6145                	addi	sp,sp,48
    80005310:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005312:	6908                	ld	a0,16(a0)
    80005314:	00000097          	auipc	ra,0x0
    80005318:	5b6080e7          	jalr	1462(ra) # 800058ca <piperead>
    8000531c:	892a                	mv	s2,a0
    8000531e:	b7d5                	j	80005302 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005320:	02451783          	lh	a5,36(a0)
    80005324:	03079693          	slli	a3,a5,0x30
    80005328:	92c1                	srli	a3,a3,0x30
    8000532a:	4725                	li	a4,9
    8000532c:	02d76863          	bltu	a4,a3,8000535c <fileread+0xba>
    80005330:	0792                	slli	a5,a5,0x4
    80005332:	00025717          	auipc	a4,0x25
    80005336:	7e670713          	addi	a4,a4,2022 # 8002ab18 <devsw>
    8000533a:	97ba                	add	a5,a5,a4
    8000533c:	639c                	ld	a5,0(a5)
    8000533e:	c38d                	beqz	a5,80005360 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005340:	4505                	li	a0,1
    80005342:	9782                	jalr	a5
    80005344:	892a                	mv	s2,a0
    80005346:	bf75                	j	80005302 <fileread+0x60>
    panic("fileread");
    80005348:	00005517          	auipc	a0,0x5
    8000534c:	80050513          	addi	a0,a0,-2048 # 80009b48 <syscalls+0x2c8>
    80005350:	ffffb097          	auipc	ra,0xffffb
    80005354:	1da080e7          	jalr	474(ra) # 8000052a <panic>
    return -1;
    80005358:	597d                	li	s2,-1
    8000535a:	b765                	j	80005302 <fileread+0x60>
      return -1;
    8000535c:	597d                	li	s2,-1
    8000535e:	b755                	j	80005302 <fileread+0x60>
    80005360:	597d                	li	s2,-1
    80005362:	b745                	j	80005302 <fileread+0x60>

0000000080005364 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80005364:	715d                	addi	sp,sp,-80
    80005366:	e486                	sd	ra,72(sp)
    80005368:	e0a2                	sd	s0,64(sp)
    8000536a:	fc26                	sd	s1,56(sp)
    8000536c:	f84a                	sd	s2,48(sp)
    8000536e:	f44e                	sd	s3,40(sp)
    80005370:	f052                	sd	s4,32(sp)
    80005372:	ec56                	sd	s5,24(sp)
    80005374:	e85a                	sd	s6,16(sp)
    80005376:	e45e                	sd	s7,8(sp)
    80005378:	e062                	sd	s8,0(sp)
    8000537a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000537c:	00954783          	lbu	a5,9(a0)
    80005380:	10078663          	beqz	a5,8000548c <filewrite+0x128>
    80005384:	892a                	mv	s2,a0
    80005386:	8aae                	mv	s5,a1
    80005388:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000538a:	411c                	lw	a5,0(a0)
    8000538c:	4705                	li	a4,1
    8000538e:	02e78263          	beq	a5,a4,800053b2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005392:	470d                	li	a4,3
    80005394:	02e78663          	beq	a5,a4,800053c0 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005398:	4709                	li	a4,2
    8000539a:	0ee79163          	bne	a5,a4,8000547c <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000539e:	0ac05d63          	blez	a2,80005458 <filewrite+0xf4>
    int i = 0;
    800053a2:	4981                	li	s3,0
    800053a4:	6b05                	lui	s6,0x1
    800053a6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800053aa:	6b85                	lui	s7,0x1
    800053ac:	c00b8b9b          	addiw	s7,s7,-1024
    800053b0:	a861                	j	80005448 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800053b2:	6908                	ld	a0,16(a0)
    800053b4:	00000097          	auipc	ra,0x0
    800053b8:	424080e7          	jalr	1060(ra) # 800057d8 <pipewrite>
    800053bc:	8a2a                	mv	s4,a0
    800053be:	a045                	j	8000545e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800053c0:	02451783          	lh	a5,36(a0)
    800053c4:	03079693          	slli	a3,a5,0x30
    800053c8:	92c1                	srli	a3,a3,0x30
    800053ca:	4725                	li	a4,9
    800053cc:	0cd76263          	bltu	a4,a3,80005490 <filewrite+0x12c>
    800053d0:	0792                	slli	a5,a5,0x4
    800053d2:	00025717          	auipc	a4,0x25
    800053d6:	74670713          	addi	a4,a4,1862 # 8002ab18 <devsw>
    800053da:	97ba                	add	a5,a5,a4
    800053dc:	679c                	ld	a5,8(a5)
    800053de:	cbdd                	beqz	a5,80005494 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800053e0:	4505                	li	a0,1
    800053e2:	9782                	jalr	a5
    800053e4:	8a2a                	mv	s4,a0
    800053e6:	a8a5                	j	8000545e <filewrite+0xfa>
    800053e8:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800053ec:	00000097          	auipc	ra,0x0
    800053f0:	8b0080e7          	jalr	-1872(ra) # 80004c9c <begin_op>
      ilock(f->ip);
    800053f4:	01893503          	ld	a0,24(s2)
    800053f8:	fffff097          	auipc	ra,0xfffff
    800053fc:	bbc080e7          	jalr	-1092(ra) # 80003fb4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005400:	8762                	mv	a4,s8
    80005402:	02092683          	lw	a3,32(s2)
    80005406:	01598633          	add	a2,s3,s5
    8000540a:	4585                	li	a1,1
    8000540c:	01893503          	ld	a0,24(s2)
    80005410:	fffff097          	auipc	ra,0xfffff
    80005414:	f50080e7          	jalr	-176(ra) # 80004360 <writei>
    80005418:	84aa                	mv	s1,a0
    8000541a:	00a05763          	blez	a0,80005428 <filewrite+0xc4>
        f->off += r;
    8000541e:	02092783          	lw	a5,32(s2)
    80005422:	9fa9                	addw	a5,a5,a0
    80005424:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005428:	01893503          	ld	a0,24(s2)
    8000542c:	fffff097          	auipc	ra,0xfffff
    80005430:	c4a080e7          	jalr	-950(ra) # 80004076 <iunlock>
      end_op();
    80005434:	00000097          	auipc	ra,0x0
    80005438:	8e8080e7          	jalr	-1816(ra) # 80004d1c <end_op>

      if(r != n1){
    8000543c:	009c1f63          	bne	s8,s1,8000545a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005440:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005444:	0149db63          	bge	s3,s4,8000545a <filewrite+0xf6>
      int n1 = n - i;
    80005448:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000544c:	84be                	mv	s1,a5
    8000544e:	2781                	sext.w	a5,a5
    80005450:	f8fb5ce3          	bge	s6,a5,800053e8 <filewrite+0x84>
    80005454:	84de                	mv	s1,s7
    80005456:	bf49                	j	800053e8 <filewrite+0x84>
    int i = 0;
    80005458:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000545a:	013a1f63          	bne	s4,s3,80005478 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000545e:	8552                	mv	a0,s4
    80005460:	60a6                	ld	ra,72(sp)
    80005462:	6406                	ld	s0,64(sp)
    80005464:	74e2                	ld	s1,56(sp)
    80005466:	7942                	ld	s2,48(sp)
    80005468:	79a2                	ld	s3,40(sp)
    8000546a:	7a02                	ld	s4,32(sp)
    8000546c:	6ae2                	ld	s5,24(sp)
    8000546e:	6b42                	ld	s6,16(sp)
    80005470:	6ba2                	ld	s7,8(sp)
    80005472:	6c02                	ld	s8,0(sp)
    80005474:	6161                	addi	sp,sp,80
    80005476:	8082                	ret
    ret = (i == n ? n : -1);
    80005478:	5a7d                	li	s4,-1
    8000547a:	b7d5                	j	8000545e <filewrite+0xfa>
    panic("filewrite");
    8000547c:	00004517          	auipc	a0,0x4
    80005480:	6dc50513          	addi	a0,a0,1756 # 80009b58 <syscalls+0x2d8>
    80005484:	ffffb097          	auipc	ra,0xffffb
    80005488:	0a6080e7          	jalr	166(ra) # 8000052a <panic>
    return -1;
    8000548c:	5a7d                	li	s4,-1
    8000548e:	bfc1                	j	8000545e <filewrite+0xfa>
      return -1;
    80005490:	5a7d                	li	s4,-1
    80005492:	b7f1                	j	8000545e <filewrite+0xfa>
    80005494:	5a7d                	li	s4,-1
    80005496:	b7e1                	j	8000545e <filewrite+0xfa>

0000000080005498 <kfileread>:

// Read from file f.
// addr is a kernel virtual address.
int
kfileread(struct file *f, uint64 addr, int n)
{
    80005498:	7179                	addi	sp,sp,-48
    8000549a:	f406                	sd	ra,40(sp)
    8000549c:	f022                	sd	s0,32(sp)
    8000549e:	ec26                	sd	s1,24(sp)
    800054a0:	e84a                	sd	s2,16(sp)
    800054a2:	e44e                	sd	s3,8(sp)
    800054a4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800054a6:	00854783          	lbu	a5,8(a0)
    800054aa:	c3d5                	beqz	a5,8000554e <kfileread+0xb6>
    800054ac:	84aa                	mv	s1,a0
    800054ae:	89ae                	mv	s3,a1
    800054b0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800054b2:	411c                	lw	a5,0(a0)
    800054b4:	4705                	li	a4,1
    800054b6:	04e78963          	beq	a5,a4,80005508 <kfileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800054ba:	470d                	li	a4,3
    800054bc:	04e78d63          	beq	a5,a4,80005516 <kfileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800054c0:	4709                	li	a4,2
    800054c2:	06e79e63          	bne	a5,a4,8000553e <kfileread+0xa6>
    ilock(f->ip);
    800054c6:	6d08                	ld	a0,24(a0)
    800054c8:	fffff097          	auipc	ra,0xfffff
    800054cc:	aec080e7          	jalr	-1300(ra) # 80003fb4 <ilock>
    if((r = readi(f->ip, 0, addr, f->off, n)) > 0)
    800054d0:	874a                	mv	a4,s2
    800054d2:	5094                	lw	a3,32(s1)
    800054d4:	864e                	mv	a2,s3
    800054d6:	4581                	li	a1,0
    800054d8:	6c88                	ld	a0,24(s1)
    800054da:	fffff097          	auipc	ra,0xfffff
    800054de:	d8e080e7          	jalr	-626(ra) # 80004268 <readi>
    800054e2:	892a                	mv	s2,a0
    800054e4:	00a05563          	blez	a0,800054ee <kfileread+0x56>
      f->off += r;
    800054e8:	509c                	lw	a5,32(s1)
    800054ea:	9fa9                	addw	a5,a5,a0
    800054ec:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800054ee:	6c88                	ld	a0,24(s1)
    800054f0:	fffff097          	auipc	ra,0xfffff
    800054f4:	b86080e7          	jalr	-1146(ra) # 80004076 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800054f8:	854a                	mv	a0,s2
    800054fa:	70a2                	ld	ra,40(sp)
    800054fc:	7402                	ld	s0,32(sp)
    800054fe:	64e2                	ld	s1,24(sp)
    80005500:	6942                	ld	s2,16(sp)
    80005502:	69a2                	ld	s3,8(sp)
    80005504:	6145                	addi	sp,sp,48
    80005506:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005508:	6908                	ld	a0,16(a0)
    8000550a:	00000097          	auipc	ra,0x0
    8000550e:	3c0080e7          	jalr	960(ra) # 800058ca <piperead>
    80005512:	892a                	mv	s2,a0
    80005514:	b7d5                	j	800054f8 <kfileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005516:	02451783          	lh	a5,36(a0)
    8000551a:	03079693          	slli	a3,a5,0x30
    8000551e:	92c1                	srli	a3,a3,0x30
    80005520:	4725                	li	a4,9
    80005522:	02d76863          	bltu	a4,a3,80005552 <kfileread+0xba>
    80005526:	0792                	slli	a5,a5,0x4
    80005528:	00025717          	auipc	a4,0x25
    8000552c:	5f070713          	addi	a4,a4,1520 # 8002ab18 <devsw>
    80005530:	97ba                	add	a5,a5,a4
    80005532:	639c                	ld	a5,0(a5)
    80005534:	c38d                	beqz	a5,80005556 <kfileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005536:	4505                	li	a0,1
    80005538:	9782                	jalr	a5
    8000553a:	892a                	mv	s2,a0
    8000553c:	bf75                	j	800054f8 <kfileread+0x60>
    panic("fileread");
    8000553e:	00004517          	auipc	a0,0x4
    80005542:	60a50513          	addi	a0,a0,1546 # 80009b48 <syscalls+0x2c8>
    80005546:	ffffb097          	auipc	ra,0xffffb
    8000554a:	fe4080e7          	jalr	-28(ra) # 8000052a <panic>
    return -1;
    8000554e:	597d                	li	s2,-1
    80005550:	b765                	j	800054f8 <kfileread+0x60>
      return -1;
    80005552:	597d                	li	s2,-1
    80005554:	b755                	j	800054f8 <kfileread+0x60>
    80005556:	597d                	li	s2,-1
    80005558:	b745                	j	800054f8 <kfileread+0x60>

000000008000555a <kfilewrite>:

// Write to file f.
// addr is a kernel virtual address.
int
kfilewrite(struct file *f, uint64 addr, int n)
{
    8000555a:	715d                	addi	sp,sp,-80
    8000555c:	e486                	sd	ra,72(sp)
    8000555e:	e0a2                	sd	s0,64(sp)
    80005560:	fc26                	sd	s1,56(sp)
    80005562:	f84a                	sd	s2,48(sp)
    80005564:	f44e                	sd	s3,40(sp)
    80005566:	f052                	sd	s4,32(sp)
    80005568:	ec56                	sd	s5,24(sp)
    8000556a:	e85a                	sd	s6,16(sp)
    8000556c:	e45e                	sd	s7,8(sp)
    8000556e:	e062                	sd	s8,0(sp)
    80005570:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005572:	00954783          	lbu	a5,9(a0)
    80005576:	10078663          	beqz	a5,80005682 <kfilewrite+0x128>
    8000557a:	892a                	mv	s2,a0
    8000557c:	8aae                	mv	s5,a1
    8000557e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005580:	411c                	lw	a5,0(a0)
    80005582:	4705                	li	a4,1
    80005584:	02e78263          	beq	a5,a4,800055a8 <kfilewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005588:	470d                	li	a4,3
    8000558a:	02e78663          	beq	a5,a4,800055b6 <kfilewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000558e:	4709                	li	a4,2
    80005590:	0ee79163          	bne	a5,a4,80005672 <kfilewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005594:	0ac05d63          	blez	a2,8000564e <kfilewrite+0xf4>
    int i = 0;
    80005598:	4981                	li	s3,0
    8000559a:	6b05                	lui	s6,0x1
    8000559c:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800055a0:	6b85                	lui	s7,0x1
    800055a2:	c00b8b9b          	addiw	s7,s7,-1024
    800055a6:	a861                	j	8000563e <kfilewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800055a8:	6908                	ld	a0,16(a0)
    800055aa:	00000097          	auipc	ra,0x0
    800055ae:	22e080e7          	jalr	558(ra) # 800057d8 <pipewrite>
    800055b2:	8a2a                	mv	s4,a0
    800055b4:	a045                	j	80005654 <kfilewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800055b6:	02451783          	lh	a5,36(a0)
    800055ba:	03079693          	slli	a3,a5,0x30
    800055be:	92c1                	srli	a3,a3,0x30
    800055c0:	4725                	li	a4,9
    800055c2:	0cd76263          	bltu	a4,a3,80005686 <kfilewrite+0x12c>
    800055c6:	0792                	slli	a5,a5,0x4
    800055c8:	00025717          	auipc	a4,0x25
    800055cc:	55070713          	addi	a4,a4,1360 # 8002ab18 <devsw>
    800055d0:	97ba                	add	a5,a5,a4
    800055d2:	679c                	ld	a5,8(a5)
    800055d4:	cbdd                	beqz	a5,8000568a <kfilewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800055d6:	4505                	li	a0,1
    800055d8:	9782                	jalr	a5
    800055da:	8a2a                	mv	s4,a0
    800055dc:	a8a5                	j	80005654 <kfilewrite+0xfa>
    800055de:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800055e2:	fffff097          	auipc	ra,0xfffff
    800055e6:	6ba080e7          	jalr	1722(ra) # 80004c9c <begin_op>
      ilock(f->ip);
    800055ea:	01893503          	ld	a0,24(s2)
    800055ee:	fffff097          	auipc	ra,0xfffff
    800055f2:	9c6080e7          	jalr	-1594(ra) # 80003fb4 <ilock>
      if ((r = writei(f->ip, 0, addr + i, f->off, n1)) > 0)
    800055f6:	8762                	mv	a4,s8
    800055f8:	02092683          	lw	a3,32(s2)
    800055fc:	01598633          	add	a2,s3,s5
    80005600:	4581                	li	a1,0
    80005602:	01893503          	ld	a0,24(s2)
    80005606:	fffff097          	auipc	ra,0xfffff
    8000560a:	d5a080e7          	jalr	-678(ra) # 80004360 <writei>
    8000560e:	84aa                	mv	s1,a0
    80005610:	00a05763          	blez	a0,8000561e <kfilewrite+0xc4>
        f->off += r;
    80005614:	02092783          	lw	a5,32(s2)
    80005618:	9fa9                	addw	a5,a5,a0
    8000561a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000561e:	01893503          	ld	a0,24(s2)
    80005622:	fffff097          	auipc	ra,0xfffff
    80005626:	a54080e7          	jalr	-1452(ra) # 80004076 <iunlock>
      end_op();
    8000562a:	fffff097          	auipc	ra,0xfffff
    8000562e:	6f2080e7          	jalr	1778(ra) # 80004d1c <end_op>

      if(r != n1){
    80005632:	009c1f63          	bne	s8,s1,80005650 <kfilewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005636:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000563a:	0149db63          	bge	s3,s4,80005650 <kfilewrite+0xf6>
      int n1 = n - i;
    8000563e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005642:	84be                	mv	s1,a5
    80005644:	2781                	sext.w	a5,a5
    80005646:	f8fb5ce3          	bge	s6,a5,800055de <kfilewrite+0x84>
    8000564a:	84de                	mv	s1,s7
    8000564c:	bf49                	j	800055de <kfilewrite+0x84>
    int i = 0;
    8000564e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005650:	013a1f63          	bne	s4,s3,8000566e <kfilewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
    80005654:	8552                	mv	a0,s4
    80005656:	60a6                	ld	ra,72(sp)
    80005658:	6406                	ld	s0,64(sp)
    8000565a:	74e2                	ld	s1,56(sp)
    8000565c:	7942                	ld	s2,48(sp)
    8000565e:	79a2                	ld	s3,40(sp)
    80005660:	7a02                	ld	s4,32(sp)
    80005662:	6ae2                	ld	s5,24(sp)
    80005664:	6b42                	ld	s6,16(sp)
    80005666:	6ba2                	ld	s7,8(sp)
    80005668:	6c02                	ld	s8,0(sp)
    8000566a:	6161                	addi	sp,sp,80
    8000566c:	8082                	ret
    ret = (i == n ? n : -1);
    8000566e:	5a7d                	li	s4,-1
    80005670:	b7d5                	j	80005654 <kfilewrite+0xfa>
    panic("filewrite");
    80005672:	00004517          	auipc	a0,0x4
    80005676:	4e650513          	addi	a0,a0,1254 # 80009b58 <syscalls+0x2d8>
    8000567a:	ffffb097          	auipc	ra,0xffffb
    8000567e:	eb0080e7          	jalr	-336(ra) # 8000052a <panic>
    return -1;
    80005682:	5a7d                	li	s4,-1
    80005684:	bfc1                	j	80005654 <kfilewrite+0xfa>
      return -1;
    80005686:	5a7d                	li	s4,-1
    80005688:	b7f1                	j	80005654 <kfilewrite+0xfa>
    8000568a:	5a7d                	li	s4,-1
    8000568c:	b7e1                	j	80005654 <kfilewrite+0xfa>

000000008000568e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000568e:	7179                	addi	sp,sp,-48
    80005690:	f406                	sd	ra,40(sp)
    80005692:	f022                	sd	s0,32(sp)
    80005694:	ec26                	sd	s1,24(sp)
    80005696:	e84a                	sd	s2,16(sp)
    80005698:	e44e                	sd	s3,8(sp)
    8000569a:	e052                	sd	s4,0(sp)
    8000569c:	1800                	addi	s0,sp,48
    8000569e:	84aa                	mv	s1,a0
    800056a0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800056a2:	0005b023          	sd	zero,0(a1)
    800056a6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800056aa:	00000097          	auipc	ra,0x0
    800056ae:	a02080e7          	jalr	-1534(ra) # 800050ac <filealloc>
    800056b2:	e088                	sd	a0,0(s1)
    800056b4:	c551                	beqz	a0,80005740 <pipealloc+0xb2>
    800056b6:	00000097          	auipc	ra,0x0
    800056ba:	9f6080e7          	jalr	-1546(ra) # 800050ac <filealloc>
    800056be:	00aa3023          	sd	a0,0(s4)
    800056c2:	c92d                	beqz	a0,80005734 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800056c4:	ffffb097          	auipc	ra,0xffffb
    800056c8:	40e080e7          	jalr	1038(ra) # 80000ad2 <kalloc>
    800056cc:	892a                	mv	s2,a0
    800056ce:	c125                	beqz	a0,8000572e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800056d0:	4985                	li	s3,1
    800056d2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800056d6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800056da:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800056de:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800056e2:	00004597          	auipc	a1,0x4
    800056e6:	48658593          	addi	a1,a1,1158 # 80009b68 <syscalls+0x2e8>
    800056ea:	ffffb097          	auipc	ra,0xffffb
    800056ee:	448080e7          	jalr	1096(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    800056f2:	609c                	ld	a5,0(s1)
    800056f4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800056f8:	609c                	ld	a5,0(s1)
    800056fa:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800056fe:	609c                	ld	a5,0(s1)
    80005700:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005704:	609c                	ld	a5,0(s1)
    80005706:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000570a:	000a3783          	ld	a5,0(s4)
    8000570e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005712:	000a3783          	ld	a5,0(s4)
    80005716:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000571a:	000a3783          	ld	a5,0(s4)
    8000571e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005722:	000a3783          	ld	a5,0(s4)
    80005726:	0127b823          	sd	s2,16(a5)
  return 0;
    8000572a:	4501                	li	a0,0
    8000572c:	a025                	j	80005754 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000572e:	6088                	ld	a0,0(s1)
    80005730:	e501                	bnez	a0,80005738 <pipealloc+0xaa>
    80005732:	a039                	j	80005740 <pipealloc+0xb2>
    80005734:	6088                	ld	a0,0(s1)
    80005736:	c51d                	beqz	a0,80005764 <pipealloc+0xd6>
    fileclose(*f0);
    80005738:	00000097          	auipc	ra,0x0
    8000573c:	a30080e7          	jalr	-1488(ra) # 80005168 <fileclose>
  if(*f1)
    80005740:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005744:	557d                	li	a0,-1
  if(*f1)
    80005746:	c799                	beqz	a5,80005754 <pipealloc+0xc6>
    fileclose(*f1);
    80005748:	853e                	mv	a0,a5
    8000574a:	00000097          	auipc	ra,0x0
    8000574e:	a1e080e7          	jalr	-1506(ra) # 80005168 <fileclose>
  return -1;
    80005752:	557d                	li	a0,-1
}
    80005754:	70a2                	ld	ra,40(sp)
    80005756:	7402                	ld	s0,32(sp)
    80005758:	64e2                	ld	s1,24(sp)
    8000575a:	6942                	ld	s2,16(sp)
    8000575c:	69a2                	ld	s3,8(sp)
    8000575e:	6a02                	ld	s4,0(sp)
    80005760:	6145                	addi	sp,sp,48
    80005762:	8082                	ret
  return -1;
    80005764:	557d                	li	a0,-1
    80005766:	b7fd                	j	80005754 <pipealloc+0xc6>

0000000080005768 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005768:	1101                	addi	sp,sp,-32
    8000576a:	ec06                	sd	ra,24(sp)
    8000576c:	e822                	sd	s0,16(sp)
    8000576e:	e426                	sd	s1,8(sp)
    80005770:	e04a                	sd	s2,0(sp)
    80005772:	1000                	addi	s0,sp,32
    80005774:	84aa                	mv	s1,a0
    80005776:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005778:	ffffb097          	auipc	ra,0xffffb
    8000577c:	44a080e7          	jalr	1098(ra) # 80000bc2 <acquire>
  if(writable){
    80005780:	02090d63          	beqz	s2,800057ba <pipeclose+0x52>
    pi->writeopen = 0;
    80005784:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005788:	21848513          	addi	a0,s1,536
    8000578c:	ffffd097          	auipc	ra,0xffffd
    80005790:	b0e080e7          	jalr	-1266(ra) # 8000229a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005794:	2204b783          	ld	a5,544(s1)
    80005798:	eb95                	bnez	a5,800057cc <pipeclose+0x64>
    release(&pi->lock);
    8000579a:	8526                	mv	a0,s1
    8000579c:	ffffb097          	auipc	ra,0xffffb
    800057a0:	4da080e7          	jalr	1242(ra) # 80000c76 <release>
    kfree((char*)pi);
    800057a4:	8526                	mv	a0,s1
    800057a6:	ffffb097          	auipc	ra,0xffffb
    800057aa:	230080e7          	jalr	560(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    800057ae:	60e2                	ld	ra,24(sp)
    800057b0:	6442                	ld	s0,16(sp)
    800057b2:	64a2                	ld	s1,8(sp)
    800057b4:	6902                	ld	s2,0(sp)
    800057b6:	6105                	addi	sp,sp,32
    800057b8:	8082                	ret
    pi->readopen = 0;
    800057ba:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800057be:	21c48513          	addi	a0,s1,540
    800057c2:	ffffd097          	auipc	ra,0xffffd
    800057c6:	ad8080e7          	jalr	-1320(ra) # 8000229a <wakeup>
    800057ca:	b7e9                	j	80005794 <pipeclose+0x2c>
    release(&pi->lock);
    800057cc:	8526                	mv	a0,s1
    800057ce:	ffffb097          	auipc	ra,0xffffb
    800057d2:	4a8080e7          	jalr	1192(ra) # 80000c76 <release>
}
    800057d6:	bfe1                	j	800057ae <pipeclose+0x46>

00000000800057d8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800057d8:	711d                	addi	sp,sp,-96
    800057da:	ec86                	sd	ra,88(sp)
    800057dc:	e8a2                	sd	s0,80(sp)
    800057de:	e4a6                	sd	s1,72(sp)
    800057e0:	e0ca                	sd	s2,64(sp)
    800057e2:	fc4e                	sd	s3,56(sp)
    800057e4:	f852                	sd	s4,48(sp)
    800057e6:	f456                	sd	s5,40(sp)
    800057e8:	f05a                	sd	s6,32(sp)
    800057ea:	ec5e                	sd	s7,24(sp)
    800057ec:	e862                	sd	s8,16(sp)
    800057ee:	1080                	addi	s0,sp,96
    800057f0:	84aa                	mv	s1,a0
    800057f2:	8aae                	mv	s5,a1
    800057f4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800057f6:	ffffc097          	auipc	ra,0xffffc
    800057fa:	380080e7          	jalr	896(ra) # 80001b76 <myproc>
    800057fe:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005800:	8526                	mv	a0,s1
    80005802:	ffffb097          	auipc	ra,0xffffb
    80005806:	3c0080e7          	jalr	960(ra) # 80000bc2 <acquire>
  while(i < n){
    8000580a:	0b405363          	blez	s4,800058b0 <pipewrite+0xd8>
  int i = 0;
    8000580e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005810:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005812:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005816:	21c48b93          	addi	s7,s1,540
    8000581a:	a089                	j	8000585c <pipewrite+0x84>
      release(&pi->lock);
    8000581c:	8526                	mv	a0,s1
    8000581e:	ffffb097          	auipc	ra,0xffffb
    80005822:	458080e7          	jalr	1112(ra) # 80000c76 <release>
      return -1;
    80005826:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005828:	854a                	mv	a0,s2
    8000582a:	60e6                	ld	ra,88(sp)
    8000582c:	6446                	ld	s0,80(sp)
    8000582e:	64a6                	ld	s1,72(sp)
    80005830:	6906                	ld	s2,64(sp)
    80005832:	79e2                	ld	s3,56(sp)
    80005834:	7a42                	ld	s4,48(sp)
    80005836:	7aa2                	ld	s5,40(sp)
    80005838:	7b02                	ld	s6,32(sp)
    8000583a:	6be2                	ld	s7,24(sp)
    8000583c:	6c42                	ld	s8,16(sp)
    8000583e:	6125                	addi	sp,sp,96
    80005840:	8082                	ret
      wakeup(&pi->nread);
    80005842:	8562                	mv	a0,s8
    80005844:	ffffd097          	auipc	ra,0xffffd
    80005848:	a56080e7          	jalr	-1450(ra) # 8000229a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000584c:	85a6                	mv	a1,s1
    8000584e:	855e                	mv	a0,s7
    80005850:	ffffd097          	auipc	ra,0xffffd
    80005854:	8be080e7          	jalr	-1858(ra) # 8000210e <sleep>
  while(i < n){
    80005858:	05495d63          	bge	s2,s4,800058b2 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    8000585c:	2204a783          	lw	a5,544(s1)
    80005860:	dfd5                	beqz	a5,8000581c <pipewrite+0x44>
    80005862:	0289a783          	lw	a5,40(s3)
    80005866:	fbdd                	bnez	a5,8000581c <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005868:	2184a783          	lw	a5,536(s1)
    8000586c:	21c4a703          	lw	a4,540(s1)
    80005870:	2007879b          	addiw	a5,a5,512
    80005874:	fcf707e3          	beq	a4,a5,80005842 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005878:	4685                	li	a3,1
    8000587a:	01590633          	add	a2,s2,s5
    8000587e:	faf40593          	addi	a1,s0,-81
    80005882:	0509b503          	ld	a0,80(s3)
    80005886:	ffffc097          	auipc	ra,0xffffc
    8000588a:	b9c080e7          	jalr	-1124(ra) # 80001422 <copyin>
    8000588e:	03650263          	beq	a0,s6,800058b2 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005892:	21c4a783          	lw	a5,540(s1)
    80005896:	0017871b          	addiw	a4,a5,1
    8000589a:	20e4ae23          	sw	a4,540(s1)
    8000589e:	1ff7f793          	andi	a5,a5,511
    800058a2:	97a6                	add	a5,a5,s1
    800058a4:	faf44703          	lbu	a4,-81(s0)
    800058a8:	00e78c23          	sb	a4,24(a5)
      i++;
    800058ac:	2905                	addiw	s2,s2,1
    800058ae:	b76d                	j	80005858 <pipewrite+0x80>
  int i = 0;
    800058b0:	4901                	li	s2,0
  wakeup(&pi->nread);
    800058b2:	21848513          	addi	a0,s1,536
    800058b6:	ffffd097          	auipc	ra,0xffffd
    800058ba:	9e4080e7          	jalr	-1564(ra) # 8000229a <wakeup>
  release(&pi->lock);
    800058be:	8526                	mv	a0,s1
    800058c0:	ffffb097          	auipc	ra,0xffffb
    800058c4:	3b6080e7          	jalr	950(ra) # 80000c76 <release>
  return i;
    800058c8:	b785                	j	80005828 <pipewrite+0x50>

00000000800058ca <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800058ca:	715d                	addi	sp,sp,-80
    800058cc:	e486                	sd	ra,72(sp)
    800058ce:	e0a2                	sd	s0,64(sp)
    800058d0:	fc26                	sd	s1,56(sp)
    800058d2:	f84a                	sd	s2,48(sp)
    800058d4:	f44e                	sd	s3,40(sp)
    800058d6:	f052                	sd	s4,32(sp)
    800058d8:	ec56                	sd	s5,24(sp)
    800058da:	e85a                	sd	s6,16(sp)
    800058dc:	0880                	addi	s0,sp,80
    800058de:	84aa                	mv	s1,a0
    800058e0:	892e                	mv	s2,a1
    800058e2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800058e4:	ffffc097          	auipc	ra,0xffffc
    800058e8:	292080e7          	jalr	658(ra) # 80001b76 <myproc>
    800058ec:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800058ee:	8526                	mv	a0,s1
    800058f0:	ffffb097          	auipc	ra,0xffffb
    800058f4:	2d2080e7          	jalr	722(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800058f8:	2184a703          	lw	a4,536(s1)
    800058fc:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005900:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005904:	02f71463          	bne	a4,a5,8000592c <piperead+0x62>
    80005908:	2244a783          	lw	a5,548(s1)
    8000590c:	c385                	beqz	a5,8000592c <piperead+0x62>
    if(pr->killed){
    8000590e:	028a2783          	lw	a5,40(s4)
    80005912:	ebc1                	bnez	a5,800059a2 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005914:	85a6                	mv	a1,s1
    80005916:	854e                	mv	a0,s3
    80005918:	ffffc097          	auipc	ra,0xffffc
    8000591c:	7f6080e7          	jalr	2038(ra) # 8000210e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005920:	2184a703          	lw	a4,536(s1)
    80005924:	21c4a783          	lw	a5,540(s1)
    80005928:	fef700e3          	beq	a4,a5,80005908 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000592c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000592e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005930:	05505363          	blez	s5,80005976 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80005934:	2184a783          	lw	a5,536(s1)
    80005938:	21c4a703          	lw	a4,540(s1)
    8000593c:	02f70d63          	beq	a4,a5,80005976 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005940:	0017871b          	addiw	a4,a5,1
    80005944:	20e4ac23          	sw	a4,536(s1)
    80005948:	1ff7f793          	andi	a5,a5,511
    8000594c:	97a6                	add	a5,a5,s1
    8000594e:	0187c783          	lbu	a5,24(a5)
    80005952:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005956:	4685                	li	a3,1
    80005958:	fbf40613          	addi	a2,s0,-65
    8000595c:	85ca                	mv	a1,s2
    8000595e:	050a3503          	ld	a0,80(s4)
    80005962:	ffffc097          	auipc	ra,0xffffc
    80005966:	a32080e7          	jalr	-1486(ra) # 80001394 <copyout>
    8000596a:	01650663          	beq	a0,s6,80005976 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000596e:	2985                	addiw	s3,s3,1
    80005970:	0905                	addi	s2,s2,1
    80005972:	fd3a91e3          	bne	s5,s3,80005934 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005976:	21c48513          	addi	a0,s1,540
    8000597a:	ffffd097          	auipc	ra,0xffffd
    8000597e:	920080e7          	jalr	-1760(ra) # 8000229a <wakeup>
  release(&pi->lock);
    80005982:	8526                	mv	a0,s1
    80005984:	ffffb097          	auipc	ra,0xffffb
    80005988:	2f2080e7          	jalr	754(ra) # 80000c76 <release>
  return i;
}
    8000598c:	854e                	mv	a0,s3
    8000598e:	60a6                	ld	ra,72(sp)
    80005990:	6406                	ld	s0,64(sp)
    80005992:	74e2                	ld	s1,56(sp)
    80005994:	7942                	ld	s2,48(sp)
    80005996:	79a2                	ld	s3,40(sp)
    80005998:	7a02                	ld	s4,32(sp)
    8000599a:	6ae2                	ld	s5,24(sp)
    8000599c:	6b42                	ld	s6,16(sp)
    8000599e:	6161                	addi	sp,sp,80
    800059a0:	8082                	ret
      release(&pi->lock);
    800059a2:	8526                	mv	a0,s1
    800059a4:	ffffb097          	auipc	ra,0xffffb
    800059a8:	2d2080e7          	jalr	722(ra) # 80000c76 <release>
      return -1;
    800059ac:	59fd                	li	s3,-1
    800059ae:	bff9                	j	8000598c <piperead+0xc2>

00000000800059b0 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    800059b0:	de010113          	addi	sp,sp,-544
    800059b4:	20113c23          	sd	ra,536(sp)
    800059b8:	20813823          	sd	s0,528(sp)
    800059bc:	20913423          	sd	s1,520(sp)
    800059c0:	21213023          	sd	s2,512(sp)
    800059c4:	ffce                	sd	s3,504(sp)
    800059c6:	fbd2                	sd	s4,496(sp)
    800059c8:	f7d6                	sd	s5,488(sp)
    800059ca:	f3da                	sd	s6,480(sp)
    800059cc:	efde                	sd	s7,472(sp)
    800059ce:	ebe2                	sd	s8,464(sp)
    800059d0:	e7e6                	sd	s9,456(sp)
    800059d2:	e3ea                	sd	s10,448(sp)
    800059d4:	ff6e                	sd	s11,440(sp)
    800059d6:	1400                	addi	s0,sp,544
    800059d8:	892a                	mv	s2,a0
    800059da:	dea43423          	sd	a0,-536(s0)
    800059de:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800059e2:	ffffc097          	auipc	ra,0xffffc
    800059e6:	194080e7          	jalr	404(ra) # 80001b76 <myproc>
    800059ea:	84aa                	mv	s1,a0

  begin_op();
    800059ec:	fffff097          	auipc	ra,0xfffff
    800059f0:	2b0080e7          	jalr	688(ra) # 80004c9c <begin_op>

  if((ip = namei(path)) == 0){
    800059f4:	854a                	mv	a0,s2
    800059f6:	fffff097          	auipc	ra,0xfffff
    800059fa:	d74080e7          	jalr	-652(ra) # 8000476a <namei>
    800059fe:	c93d                	beqz	a0,80005a74 <exec+0xc4>
    80005a00:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005a02:	ffffe097          	auipc	ra,0xffffe
    80005a06:	5b2080e7          	jalr	1458(ra) # 80003fb4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005a0a:	04000713          	li	a4,64
    80005a0e:	4681                	li	a3,0
    80005a10:	e4840613          	addi	a2,s0,-440
    80005a14:	4581                	li	a1,0
    80005a16:	8556                	mv	a0,s5
    80005a18:	fffff097          	auipc	ra,0xfffff
    80005a1c:	850080e7          	jalr	-1968(ra) # 80004268 <readi>
    80005a20:	04000793          	li	a5,64
    80005a24:	00f51a63          	bne	a0,a5,80005a38 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005a28:	e4842703          	lw	a4,-440(s0)
    80005a2c:	464c47b7          	lui	a5,0x464c4
    80005a30:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005a34:	04f70663          	beq	a4,a5,80005a80 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005a38:	8556                	mv	a0,s5
    80005a3a:	ffffe097          	auipc	ra,0xffffe
    80005a3e:	7dc080e7          	jalr	2012(ra) # 80004216 <iunlockput>
    end_op();
    80005a42:	fffff097          	auipc	ra,0xfffff
    80005a46:	2da080e7          	jalr	730(ra) # 80004d1c <end_op>
  }
  return -1;
    80005a4a:	557d                	li	a0,-1
}
    80005a4c:	21813083          	ld	ra,536(sp)
    80005a50:	21013403          	ld	s0,528(sp)
    80005a54:	20813483          	ld	s1,520(sp)
    80005a58:	20013903          	ld	s2,512(sp)
    80005a5c:	79fe                	ld	s3,504(sp)
    80005a5e:	7a5e                	ld	s4,496(sp)
    80005a60:	7abe                	ld	s5,488(sp)
    80005a62:	7b1e                	ld	s6,480(sp)
    80005a64:	6bfe                	ld	s7,472(sp)
    80005a66:	6c5e                	ld	s8,464(sp)
    80005a68:	6cbe                	ld	s9,456(sp)
    80005a6a:	6d1e                	ld	s10,448(sp)
    80005a6c:	7dfa                	ld	s11,440(sp)
    80005a6e:	22010113          	addi	sp,sp,544
    80005a72:	8082                	ret
    end_op();
    80005a74:	fffff097          	auipc	ra,0xfffff
    80005a78:	2a8080e7          	jalr	680(ra) # 80004d1c <end_op>
    return -1;
    80005a7c:	557d                	li	a0,-1
    80005a7e:	b7f9                	j	80005a4c <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005a80:	8526                	mv	a0,s1
    80005a82:	ffffc097          	auipc	ra,0xffffc
    80005a86:	1b8080e7          	jalr	440(ra) # 80001c3a <proc_pagetable>
    80005a8a:	8b2a                	mv	s6,a0
    80005a8c:	d555                	beqz	a0,80005a38 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005a8e:	e6842783          	lw	a5,-408(s0)
    80005a92:	e8045703          	lhu	a4,-384(s0)
    80005a96:	c73d                	beqz	a4,80005b04 <exec+0x154>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005a98:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005a9a:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005a9e:	6a05                	lui	s4,0x1
    80005aa0:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005aa4:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005aa8:	6d85                	lui	s11,0x1
    80005aaa:	7d7d                	lui	s10,0xfffff
    80005aac:	ac25                	j	80005ce4 <exec+0x334>
    pa = walkaddr(pagetable, va + i, 0);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005aae:	00004517          	auipc	a0,0x4
    80005ab2:	0c250513          	addi	a0,a0,194 # 80009b70 <syscalls+0x2f0>
    80005ab6:	ffffb097          	auipc	ra,0xffffb
    80005aba:	a74080e7          	jalr	-1420(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005abe:	874a                	mv	a4,s2
    80005ac0:	009c86bb          	addw	a3,s9,s1
    80005ac4:	4581                	li	a1,0
    80005ac6:	8556                	mv	a0,s5
    80005ac8:	ffffe097          	auipc	ra,0xffffe
    80005acc:	7a0080e7          	jalr	1952(ra) # 80004268 <readi>
    80005ad0:	2501                	sext.w	a0,a0
    80005ad2:	1aa91963          	bne	s2,a0,80005c84 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80005ad6:	009d84bb          	addw	s1,s11,s1
    80005ada:	013d09bb          	addw	s3,s10,s3
    80005ade:	1f74f363          	bgeu	s1,s7,80005cc4 <exec+0x314>
    pa = walkaddr(pagetable, va + i, 0);
    80005ae2:	02049593          	slli	a1,s1,0x20
    80005ae6:	9181                	srli	a1,a1,0x20
    80005ae8:	4601                	li	a2,0
    80005aea:	95e2                	add	a1,a1,s8
    80005aec:	855a                	mv	a0,s6
    80005aee:	ffffb097          	auipc	ra,0xffffb
    80005af2:	55e080e7          	jalr	1374(ra) # 8000104c <walkaddr>
    80005af6:	862a                	mv	a2,a0
    if(pa == 0)
    80005af8:	d95d                	beqz	a0,80005aae <exec+0xfe>
      n = PGSIZE;
    80005afa:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005afc:	fd49f1e3          	bgeu	s3,s4,80005abe <exec+0x10e>
      n = sz - i;
    80005b00:	894e                	mv	s2,s3
    80005b02:	bf75                	j	80005abe <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005b04:	4481                	li	s1,0
  iunlockput(ip);
    80005b06:	8556                	mv	a0,s5
    80005b08:	ffffe097          	auipc	ra,0xffffe
    80005b0c:	70e080e7          	jalr	1806(ra) # 80004216 <iunlockput>
  end_op();
    80005b10:	fffff097          	auipc	ra,0xfffff
    80005b14:	20c080e7          	jalr	524(ra) # 80004d1c <end_op>
  p = myproc();
    80005b18:	ffffc097          	auipc	ra,0xffffc
    80005b1c:	05e080e7          	jalr	94(ra) # 80001b76 <myproc>
    80005b20:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005b22:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005b26:	6785                	lui	a5,0x1
    80005b28:	17fd                	addi	a5,a5,-1
    80005b2a:	94be                	add	s1,s1,a5
    80005b2c:	77fd                	lui	a5,0xfffff
    80005b2e:	8fe5                	and	a5,a5,s1
    80005b30:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005b34:	6609                	lui	a2,0x2
    80005b36:	963e                	add	a2,a2,a5
    80005b38:	85be                	mv	a1,a5
    80005b3a:	855a                	mv	a0,s6
    80005b3c:	ffffc097          	auipc	ra,0xffffc
    80005b40:	c80080e7          	jalr	-896(ra) # 800017bc <uvmalloc>
    80005b44:	8c2a                	mv	s8,a0
  ip = 0;
    80005b46:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005b48:	12050e63          	beqz	a0,80005c84 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005b4c:	75f9                	lui	a1,0xffffe
    80005b4e:	95aa                	add	a1,a1,a0
    80005b50:	855a                	mv	a0,s6
    80005b52:	ffffc097          	auipc	ra,0xffffc
    80005b56:	810080e7          	jalr	-2032(ra) # 80001362 <uvmclear>
  stackbase = sp - PGSIZE;
    80005b5a:	7afd                	lui	s5,0xfffff
    80005b5c:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005b5e:	df043783          	ld	a5,-528(s0)
    80005b62:	6388                	ld	a0,0(a5)
    80005b64:	c925                	beqz	a0,80005bd4 <exec+0x224>
    80005b66:	e8840993          	addi	s3,s0,-376
    80005b6a:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005b6e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005b70:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005b72:	ffffb097          	auipc	ra,0xffffb
    80005b76:	2d0080e7          	jalr	720(ra) # 80000e42 <strlen>
    80005b7a:	0015079b          	addiw	a5,a0,1
    80005b7e:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005b82:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005b86:	13596363          	bltu	s2,s5,80005cac <exec+0x2fc>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005b8a:	df043d83          	ld	s11,-528(s0)
    80005b8e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005b92:	8552                	mv	a0,s4
    80005b94:	ffffb097          	auipc	ra,0xffffb
    80005b98:	2ae080e7          	jalr	686(ra) # 80000e42 <strlen>
    80005b9c:	0015069b          	addiw	a3,a0,1
    80005ba0:	8652                	mv	a2,s4
    80005ba2:	85ca                	mv	a1,s2
    80005ba4:	855a                	mv	a0,s6
    80005ba6:	ffffb097          	auipc	ra,0xffffb
    80005baa:	7ee080e7          	jalr	2030(ra) # 80001394 <copyout>
    80005bae:	10054363          	bltz	a0,80005cb4 <exec+0x304>
    ustack[argc] = sp;
    80005bb2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005bb6:	0485                	addi	s1,s1,1
    80005bb8:	008d8793          	addi	a5,s11,8
    80005bbc:	def43823          	sd	a5,-528(s0)
    80005bc0:	008db503          	ld	a0,8(s11)
    80005bc4:	c911                	beqz	a0,80005bd8 <exec+0x228>
    if(argc >= MAXARG)
    80005bc6:	09a1                	addi	s3,s3,8
    80005bc8:	fb3c95e3          	bne	s9,s3,80005b72 <exec+0x1c2>
  sz = sz1;
    80005bcc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005bd0:	4a81                	li	s5,0
    80005bd2:	a84d                	j	80005c84 <exec+0x2d4>
  sp = sz;
    80005bd4:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005bd6:	4481                	li	s1,0
  ustack[argc] = 0;
    80005bd8:	00349793          	slli	a5,s1,0x3
    80005bdc:	f9040713          	addi	a4,s0,-112
    80005be0:	97ba                	add	a5,a5,a4
    80005be2:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffcfef8>
  sp -= (argc+1) * sizeof(uint64);
    80005be6:	00148693          	addi	a3,s1,1
    80005bea:	068e                	slli	a3,a3,0x3
    80005bec:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005bf0:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005bf4:	01597663          	bgeu	s2,s5,80005c00 <exec+0x250>
  sz = sz1;
    80005bf8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005bfc:	4a81                	li	s5,0
    80005bfe:	a059                	j	80005c84 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005c00:	e8840613          	addi	a2,s0,-376
    80005c04:	85ca                	mv	a1,s2
    80005c06:	855a                	mv	a0,s6
    80005c08:	ffffb097          	auipc	ra,0xffffb
    80005c0c:	78c080e7          	jalr	1932(ra) # 80001394 <copyout>
    80005c10:	0a054663          	bltz	a0,80005cbc <exec+0x30c>
  p->trapframe->a1 = sp;
    80005c14:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80005c18:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005c1c:	de843783          	ld	a5,-536(s0)
    80005c20:	0007c703          	lbu	a4,0(a5)
    80005c24:	cf11                	beqz	a4,80005c40 <exec+0x290>
    80005c26:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005c28:	02f00693          	li	a3,47
    80005c2c:	a039                	j	80005c3a <exec+0x28a>
      last = s+1;
    80005c2e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005c32:	0785                	addi	a5,a5,1
    80005c34:	fff7c703          	lbu	a4,-1(a5)
    80005c38:	c701                	beqz	a4,80005c40 <exec+0x290>
    if(*s == '/')
    80005c3a:	fed71ce3          	bne	a4,a3,80005c32 <exec+0x282>
    80005c3e:	bfc5                	j	80005c2e <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005c40:	4641                	li	a2,16
    80005c42:	de843583          	ld	a1,-536(s0)
    80005c46:	158b8513          	addi	a0,s7,344
    80005c4a:	ffffb097          	auipc	ra,0xffffb
    80005c4e:	1c6080e7          	jalr	454(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005c52:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005c56:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005c5a:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005c5e:	058bb783          	ld	a5,88(s7)
    80005c62:	e6043703          	ld	a4,-416(s0)
    80005c66:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005c68:	058bb783          	ld	a5,88(s7)
    80005c6c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005c70:	85ea                	mv	a1,s10
    80005c72:	ffffc097          	auipc	ra,0xffffc
    80005c76:	064080e7          	jalr	100(ra) # 80001cd6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005c7a:	0004851b          	sext.w	a0,s1
    80005c7e:	b3f9                	j	80005a4c <exec+0x9c>
    80005c80:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005c84:	df843583          	ld	a1,-520(s0)
    80005c88:	855a                	mv	a0,s6
    80005c8a:	ffffc097          	auipc	ra,0xffffc
    80005c8e:	04c080e7          	jalr	76(ra) # 80001cd6 <proc_freepagetable>
  if(ip){
    80005c92:	da0a93e3          	bnez	s5,80005a38 <exec+0x88>
  return -1;
    80005c96:	557d                	li	a0,-1
    80005c98:	bb55                	j	80005a4c <exec+0x9c>
    80005c9a:	de943c23          	sd	s1,-520(s0)
    80005c9e:	b7dd                	j	80005c84 <exec+0x2d4>
    80005ca0:	de943c23          	sd	s1,-520(s0)
    80005ca4:	b7c5                	j	80005c84 <exec+0x2d4>
    80005ca6:	de943c23          	sd	s1,-520(s0)
    80005caa:	bfe9                	j	80005c84 <exec+0x2d4>
  sz = sz1;
    80005cac:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005cb0:	4a81                	li	s5,0
    80005cb2:	bfc9                	j	80005c84 <exec+0x2d4>
  sz = sz1;
    80005cb4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005cb8:	4a81                	li	s5,0
    80005cba:	b7e9                	j	80005c84 <exec+0x2d4>
  sz = sz1;
    80005cbc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005cc0:	4a81                	li	s5,0
    80005cc2:	b7c9                	j	80005c84 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005cc4:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005cc8:	e0843783          	ld	a5,-504(s0)
    80005ccc:	0017869b          	addiw	a3,a5,1
    80005cd0:	e0d43423          	sd	a3,-504(s0)
    80005cd4:	e0043783          	ld	a5,-512(s0)
    80005cd8:	0387879b          	addiw	a5,a5,56
    80005cdc:	e8045703          	lhu	a4,-384(s0)
    80005ce0:	e2e6d3e3          	bge	a3,a4,80005b06 <exec+0x156>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005ce4:	2781                	sext.w	a5,a5
    80005ce6:	e0f43023          	sd	a5,-512(s0)
    80005cea:	03800713          	li	a4,56
    80005cee:	86be                	mv	a3,a5
    80005cf0:	e1040613          	addi	a2,s0,-496
    80005cf4:	4581                	li	a1,0
    80005cf6:	8556                	mv	a0,s5
    80005cf8:	ffffe097          	auipc	ra,0xffffe
    80005cfc:	570080e7          	jalr	1392(ra) # 80004268 <readi>
    80005d00:	03800793          	li	a5,56
    80005d04:	f6f51ee3          	bne	a0,a5,80005c80 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    80005d08:	e1042783          	lw	a5,-496(s0)
    80005d0c:	4705                	li	a4,1
    80005d0e:	fae79de3          	bne	a5,a4,80005cc8 <exec+0x318>
    if(ph.memsz < ph.filesz)
    80005d12:	e3843603          	ld	a2,-456(s0)
    80005d16:	e3043783          	ld	a5,-464(s0)
    80005d1a:	f8f660e3          	bltu	a2,a5,80005c9a <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005d1e:	e2043783          	ld	a5,-480(s0)
    80005d22:	963e                	add	a2,a2,a5
    80005d24:	f6f66ee3          	bltu	a2,a5,80005ca0 <exec+0x2f0>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005d28:	85a6                	mv	a1,s1
    80005d2a:	855a                	mv	a0,s6
    80005d2c:	ffffc097          	auipc	ra,0xffffc
    80005d30:	a90080e7          	jalr	-1392(ra) # 800017bc <uvmalloc>
    80005d34:	dea43c23          	sd	a0,-520(s0)
    80005d38:	d53d                	beqz	a0,80005ca6 <exec+0x2f6>
    if(ph.vaddr % PGSIZE != 0)
    80005d3a:	e2043c03          	ld	s8,-480(s0)
    80005d3e:	de043783          	ld	a5,-544(s0)
    80005d42:	00fc77b3          	and	a5,s8,a5
    80005d46:	ff9d                	bnez	a5,80005c84 <exec+0x2d4>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005d48:	e1842c83          	lw	s9,-488(s0)
    80005d4c:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005d50:	f60b8ae3          	beqz	s7,80005cc4 <exec+0x314>
    80005d54:	89de                	mv	s3,s7
    80005d56:	4481                	li	s1,0
    80005d58:	b369                	j	80005ae2 <exec+0x132>

0000000080005d5a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005d5a:	7179                	addi	sp,sp,-48
    80005d5c:	f406                	sd	ra,40(sp)
    80005d5e:	f022                	sd	s0,32(sp)
    80005d60:	ec26                	sd	s1,24(sp)
    80005d62:	e84a                	sd	s2,16(sp)
    80005d64:	1800                	addi	s0,sp,48
    80005d66:	892e                	mv	s2,a1
    80005d68:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005d6a:	fdc40593          	addi	a1,s0,-36
    80005d6e:	ffffd097          	auipc	ra,0xffffd
    80005d72:	6d4080e7          	jalr	1748(ra) # 80003442 <argint>
    80005d76:	04054063          	bltz	a0,80005db6 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005d7a:	fdc42703          	lw	a4,-36(s0)
    80005d7e:	47bd                	li	a5,15
    80005d80:	02e7ed63          	bltu	a5,a4,80005dba <argfd+0x60>
    80005d84:	ffffc097          	auipc	ra,0xffffc
    80005d88:	df2080e7          	jalr	-526(ra) # 80001b76 <myproc>
    80005d8c:	fdc42703          	lw	a4,-36(s0)
    80005d90:	01a70793          	addi	a5,a4,26
    80005d94:	078e                	slli	a5,a5,0x3
    80005d96:	953e                	add	a0,a0,a5
    80005d98:	611c                	ld	a5,0(a0)
    80005d9a:	c395                	beqz	a5,80005dbe <argfd+0x64>
    return -1;
  if(pfd)
    80005d9c:	00090463          	beqz	s2,80005da4 <argfd+0x4a>
    *pfd = fd;
    80005da0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005da4:	4501                	li	a0,0
  if(pf)
    80005da6:	c091                	beqz	s1,80005daa <argfd+0x50>
    *pf = f;
    80005da8:	e09c                	sd	a5,0(s1)
}
    80005daa:	70a2                	ld	ra,40(sp)
    80005dac:	7402                	ld	s0,32(sp)
    80005dae:	64e2                	ld	s1,24(sp)
    80005db0:	6942                	ld	s2,16(sp)
    80005db2:	6145                	addi	sp,sp,48
    80005db4:	8082                	ret
    return -1;
    80005db6:	557d                	li	a0,-1
    80005db8:	bfcd                	j	80005daa <argfd+0x50>
    return -1;
    80005dba:	557d                	li	a0,-1
    80005dbc:	b7fd                	j	80005daa <argfd+0x50>
    80005dbe:	557d                	li	a0,-1
    80005dc0:	b7ed                	j	80005daa <argfd+0x50>

0000000080005dc2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005dc2:	1101                	addi	sp,sp,-32
    80005dc4:	ec06                	sd	ra,24(sp)
    80005dc6:	e822                	sd	s0,16(sp)
    80005dc8:	e426                	sd	s1,8(sp)
    80005dca:	1000                	addi	s0,sp,32
    80005dcc:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005dce:	ffffc097          	auipc	ra,0xffffc
    80005dd2:	da8080e7          	jalr	-600(ra) # 80001b76 <myproc>
    80005dd6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005dd8:	0d050793          	addi	a5,a0,208
    80005ddc:	4501                	li	a0,0
    80005dde:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005de0:	6398                	ld	a4,0(a5)
    80005de2:	cb19                	beqz	a4,80005df8 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005de4:	2505                	addiw	a0,a0,1
    80005de6:	07a1                	addi	a5,a5,8
    80005de8:	fed51ce3          	bne	a0,a3,80005de0 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005dec:	557d                	li	a0,-1
}
    80005dee:	60e2                	ld	ra,24(sp)
    80005df0:	6442                	ld	s0,16(sp)
    80005df2:	64a2                	ld	s1,8(sp)
    80005df4:	6105                	addi	sp,sp,32
    80005df6:	8082                	ret
      p->ofile[fd] = f;
    80005df8:	01a50793          	addi	a5,a0,26
    80005dfc:	078e                	slli	a5,a5,0x3
    80005dfe:	963e                	add	a2,a2,a5
    80005e00:	e204                	sd	s1,0(a2)
      return fd;
    80005e02:	b7f5                	j	80005dee <fdalloc+0x2c>

0000000080005e04 <sys_dup>:

uint64
sys_dup(void)
{
    80005e04:	7179                	addi	sp,sp,-48
    80005e06:	f406                	sd	ra,40(sp)
    80005e08:	f022                	sd	s0,32(sp)
    80005e0a:	ec26                	sd	s1,24(sp)
    80005e0c:	1800                	addi	s0,sp,48
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    80005e0e:	fd840613          	addi	a2,s0,-40
    80005e12:	4581                	li	a1,0
    80005e14:	4501                	li	a0,0
    80005e16:	00000097          	auipc	ra,0x0
    80005e1a:	f44080e7          	jalr	-188(ra) # 80005d5a <argfd>
    return -1;
    80005e1e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005e20:	02054363          	bltz	a0,80005e46 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005e24:	fd843503          	ld	a0,-40(s0)
    80005e28:	00000097          	auipc	ra,0x0
    80005e2c:	f9a080e7          	jalr	-102(ra) # 80005dc2 <fdalloc>
    80005e30:	84aa                	mv	s1,a0
    return -1;
    80005e32:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005e34:	00054963          	bltz	a0,80005e46 <sys_dup+0x42>
  filedup(f);
    80005e38:	fd843503          	ld	a0,-40(s0)
    80005e3c:	fffff097          	auipc	ra,0xfffff
    80005e40:	2da080e7          	jalr	730(ra) # 80005116 <filedup>
  return fd;
    80005e44:	87a6                	mv	a5,s1
}
    80005e46:	853e                	mv	a0,a5
    80005e48:	70a2                	ld	ra,40(sp)
    80005e4a:	7402                	ld	s0,32(sp)
    80005e4c:	64e2                	ld	s1,24(sp)
    80005e4e:	6145                	addi	sp,sp,48
    80005e50:	8082                	ret

0000000080005e52 <sys_read>:

uint64
sys_read(void)
{
    80005e52:	7179                	addi	sp,sp,-48
    80005e54:	f406                	sd	ra,40(sp)
    80005e56:	f022                	sd	s0,32(sp)
    80005e58:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005e5a:	fe840613          	addi	a2,s0,-24
    80005e5e:	4581                	li	a1,0
    80005e60:	4501                	li	a0,0
    80005e62:	00000097          	auipc	ra,0x0
    80005e66:	ef8080e7          	jalr	-264(ra) # 80005d5a <argfd>
    return -1;
    80005e6a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005e6c:	04054163          	bltz	a0,80005eae <sys_read+0x5c>
    80005e70:	fe440593          	addi	a1,s0,-28
    80005e74:	4509                	li	a0,2
    80005e76:	ffffd097          	auipc	ra,0xffffd
    80005e7a:	5cc080e7          	jalr	1484(ra) # 80003442 <argint>
    return -1;
    80005e7e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005e80:	02054763          	bltz	a0,80005eae <sys_read+0x5c>
    80005e84:	fd840593          	addi	a1,s0,-40
    80005e88:	4505                	li	a0,1
    80005e8a:	ffffd097          	auipc	ra,0xffffd
    80005e8e:	5da080e7          	jalr	1498(ra) # 80003464 <argaddr>
    return -1;
    80005e92:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005e94:	00054d63          	bltz	a0,80005eae <sys_read+0x5c>
  return fileread(f, p, n);
    80005e98:	fe442603          	lw	a2,-28(s0)
    80005e9c:	fd843583          	ld	a1,-40(s0)
    80005ea0:	fe843503          	ld	a0,-24(s0)
    80005ea4:	fffff097          	auipc	ra,0xfffff
    80005ea8:	3fe080e7          	jalr	1022(ra) # 800052a2 <fileread>
    80005eac:	87aa                	mv	a5,a0
}
    80005eae:	853e                	mv	a0,a5
    80005eb0:	70a2                	ld	ra,40(sp)
    80005eb2:	7402                	ld	s0,32(sp)
    80005eb4:	6145                	addi	sp,sp,48
    80005eb6:	8082                	ret

0000000080005eb8 <sys_write>:

uint64
sys_write(void)
{
    80005eb8:	7179                	addi	sp,sp,-48
    80005eba:	f406                	sd	ra,40(sp)
    80005ebc:	f022                	sd	s0,32(sp)
    80005ebe:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ec0:	fe840613          	addi	a2,s0,-24
    80005ec4:	4581                	li	a1,0
    80005ec6:	4501                	li	a0,0
    80005ec8:	00000097          	auipc	ra,0x0
    80005ecc:	e92080e7          	jalr	-366(ra) # 80005d5a <argfd>
    return -1;
    80005ed0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ed2:	04054163          	bltz	a0,80005f14 <sys_write+0x5c>
    80005ed6:	fe440593          	addi	a1,s0,-28
    80005eda:	4509                	li	a0,2
    80005edc:	ffffd097          	auipc	ra,0xffffd
    80005ee0:	566080e7          	jalr	1382(ra) # 80003442 <argint>
    return -1;
    80005ee4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ee6:	02054763          	bltz	a0,80005f14 <sys_write+0x5c>
    80005eea:	fd840593          	addi	a1,s0,-40
    80005eee:	4505                	li	a0,1
    80005ef0:	ffffd097          	auipc	ra,0xffffd
    80005ef4:	574080e7          	jalr	1396(ra) # 80003464 <argaddr>
    return -1;
    80005ef8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005efa:	00054d63          	bltz	a0,80005f14 <sys_write+0x5c>

  return filewrite(f, p, n);
    80005efe:	fe442603          	lw	a2,-28(s0)
    80005f02:	fd843583          	ld	a1,-40(s0)
    80005f06:	fe843503          	ld	a0,-24(s0)
    80005f0a:	fffff097          	auipc	ra,0xfffff
    80005f0e:	45a080e7          	jalr	1114(ra) # 80005364 <filewrite>
    80005f12:	87aa                	mv	a5,a0
}
    80005f14:	853e                	mv	a0,a5
    80005f16:	70a2                	ld	ra,40(sp)
    80005f18:	7402                	ld	s0,32(sp)
    80005f1a:	6145                	addi	sp,sp,48
    80005f1c:	8082                	ret

0000000080005f1e <sys_close>:

uint64
sys_close(void)
{
    80005f1e:	1101                	addi	sp,sp,-32
    80005f20:	ec06                	sd	ra,24(sp)
    80005f22:	e822                	sd	s0,16(sp)
    80005f24:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    80005f26:	fe040613          	addi	a2,s0,-32
    80005f2a:	fec40593          	addi	a1,s0,-20
    80005f2e:	4501                	li	a0,0
    80005f30:	00000097          	auipc	ra,0x0
    80005f34:	e2a080e7          	jalr	-470(ra) # 80005d5a <argfd>
    return -1;
    80005f38:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005f3a:	02054463          	bltz	a0,80005f62 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005f3e:	ffffc097          	auipc	ra,0xffffc
    80005f42:	c38080e7          	jalr	-968(ra) # 80001b76 <myproc>
    80005f46:	fec42783          	lw	a5,-20(s0)
    80005f4a:	07e9                	addi	a5,a5,26
    80005f4c:	078e                	slli	a5,a5,0x3
    80005f4e:	97aa                	add	a5,a5,a0
    80005f50:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005f54:	fe043503          	ld	a0,-32(s0)
    80005f58:	fffff097          	auipc	ra,0xfffff
    80005f5c:	210080e7          	jalr	528(ra) # 80005168 <fileclose>
  return 0;
    80005f60:	4781                	li	a5,0
}
    80005f62:	853e                	mv	a0,a5
    80005f64:	60e2                	ld	ra,24(sp)
    80005f66:	6442                	ld	s0,16(sp)
    80005f68:	6105                	addi	sp,sp,32
    80005f6a:	8082                	ret

0000000080005f6c <sys_fstat>:

uint64
sys_fstat(void)
{
    80005f6c:	1101                	addi	sp,sp,-32
    80005f6e:	ec06                	sd	ra,24(sp)
    80005f70:	e822                	sd	s0,16(sp)
    80005f72:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005f74:	fe840613          	addi	a2,s0,-24
    80005f78:	4581                	li	a1,0
    80005f7a:	4501                	li	a0,0
    80005f7c:	00000097          	auipc	ra,0x0
    80005f80:	dde080e7          	jalr	-546(ra) # 80005d5a <argfd>
    return -1;
    80005f84:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005f86:	02054563          	bltz	a0,80005fb0 <sys_fstat+0x44>
    80005f8a:	fe040593          	addi	a1,s0,-32
    80005f8e:	4505                	li	a0,1
    80005f90:	ffffd097          	auipc	ra,0xffffd
    80005f94:	4d4080e7          	jalr	1236(ra) # 80003464 <argaddr>
    return -1;
    80005f98:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005f9a:	00054b63          	bltz	a0,80005fb0 <sys_fstat+0x44>
  return filestat(f, st);
    80005f9e:	fe043583          	ld	a1,-32(s0)
    80005fa2:	fe843503          	ld	a0,-24(s0)
    80005fa6:	fffff097          	auipc	ra,0xfffff
    80005faa:	28a080e7          	jalr	650(ra) # 80005230 <filestat>
    80005fae:	87aa                	mv	a5,a0
}
    80005fb0:	853e                	mv	a0,a5
    80005fb2:	60e2                	ld	ra,24(sp)
    80005fb4:	6442                	ld	s0,16(sp)
    80005fb6:	6105                	addi	sp,sp,32
    80005fb8:	8082                	ret

0000000080005fba <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    80005fba:	7169                	addi	sp,sp,-304
    80005fbc:	f606                	sd	ra,296(sp)
    80005fbe:	f222                	sd	s0,288(sp)
    80005fc0:	ee26                	sd	s1,280(sp)
    80005fc2:	ea4a                	sd	s2,272(sp)
    80005fc4:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005fc6:	08000613          	li	a2,128
    80005fca:	ed040593          	addi	a1,s0,-304
    80005fce:	4501                	li	a0,0
    80005fd0:	ffffd097          	auipc	ra,0xffffd
    80005fd4:	4b6080e7          	jalr	1206(ra) # 80003486 <argstr>
    return -1;
    80005fd8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005fda:	10054e63          	bltz	a0,800060f6 <sys_link+0x13c>
    80005fde:	08000613          	li	a2,128
    80005fe2:	f5040593          	addi	a1,s0,-176
    80005fe6:	4505                	li	a0,1
    80005fe8:	ffffd097          	auipc	ra,0xffffd
    80005fec:	49e080e7          	jalr	1182(ra) # 80003486 <argstr>
    return -1;
    80005ff0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005ff2:	10054263          	bltz	a0,800060f6 <sys_link+0x13c>

  begin_op();
    80005ff6:	fffff097          	auipc	ra,0xfffff
    80005ffa:	ca6080e7          	jalr	-858(ra) # 80004c9c <begin_op>
  if((ip = namei(old)) == 0){
    80005ffe:	ed040513          	addi	a0,s0,-304
    80006002:	ffffe097          	auipc	ra,0xffffe
    80006006:	768080e7          	jalr	1896(ra) # 8000476a <namei>
    8000600a:	84aa                	mv	s1,a0
    8000600c:	c551                	beqz	a0,80006098 <sys_link+0xde>
    end_op();
    return -1;
  }

  ilock(ip);
    8000600e:	ffffe097          	auipc	ra,0xffffe
    80006012:	fa6080e7          	jalr	-90(ra) # 80003fb4 <ilock>
  if(ip->type == T_DIR){
    80006016:	04449703          	lh	a4,68(s1)
    8000601a:	4785                	li	a5,1
    8000601c:	08f70463          	beq	a4,a5,800060a4 <sys_link+0xea>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
    80006020:	04a4d783          	lhu	a5,74(s1)
    80006024:	2785                	addiw	a5,a5,1
    80006026:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000602a:	8526                	mv	a0,s1
    8000602c:	ffffe097          	auipc	ra,0xffffe
    80006030:	ebe080e7          	jalr	-322(ra) # 80003eea <iupdate>
  iunlock(ip);
    80006034:	8526                	mv	a0,s1
    80006036:	ffffe097          	auipc	ra,0xffffe
    8000603a:	040080e7          	jalr	64(ra) # 80004076 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    8000603e:	fd040593          	addi	a1,s0,-48
    80006042:	f5040513          	addi	a0,s0,-176
    80006046:	ffffe097          	auipc	ra,0xffffe
    8000604a:	742080e7          	jalr	1858(ra) # 80004788 <nameiparent>
    8000604e:	892a                	mv	s2,a0
    80006050:	c935                	beqz	a0,800060c4 <sys_link+0x10a>
    goto bad;
  ilock(dp);
    80006052:	ffffe097          	auipc	ra,0xffffe
    80006056:	f62080e7          	jalr	-158(ra) # 80003fb4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000605a:	00092703          	lw	a4,0(s2)
    8000605e:	409c                	lw	a5,0(s1)
    80006060:	04f71d63          	bne	a4,a5,800060ba <sys_link+0x100>
    80006064:	40d0                	lw	a2,4(s1)
    80006066:	fd040593          	addi	a1,s0,-48
    8000606a:	854a                	mv	a0,s2
    8000606c:	ffffe097          	auipc	ra,0xffffe
    80006070:	63c080e7          	jalr	1596(ra) # 800046a8 <dirlink>
    80006074:	04054363          	bltz	a0,800060ba <sys_link+0x100>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
    80006078:	854a                	mv	a0,s2
    8000607a:	ffffe097          	auipc	ra,0xffffe
    8000607e:	19c080e7          	jalr	412(ra) # 80004216 <iunlockput>
  iput(ip);
    80006082:	8526                	mv	a0,s1
    80006084:	ffffe097          	auipc	ra,0xffffe
    80006088:	0ea080e7          	jalr	234(ra) # 8000416e <iput>

  end_op();
    8000608c:	fffff097          	auipc	ra,0xfffff
    80006090:	c90080e7          	jalr	-880(ra) # 80004d1c <end_op>

  return 0;
    80006094:	4781                	li	a5,0
    80006096:	a085                	j	800060f6 <sys_link+0x13c>
    end_op();
    80006098:	fffff097          	auipc	ra,0xfffff
    8000609c:	c84080e7          	jalr	-892(ra) # 80004d1c <end_op>
    return -1;
    800060a0:	57fd                	li	a5,-1
    800060a2:	a891                	j	800060f6 <sys_link+0x13c>
    iunlockput(ip);
    800060a4:	8526                	mv	a0,s1
    800060a6:	ffffe097          	auipc	ra,0xffffe
    800060aa:	170080e7          	jalr	368(ra) # 80004216 <iunlockput>
    end_op();
    800060ae:	fffff097          	auipc	ra,0xfffff
    800060b2:	c6e080e7          	jalr	-914(ra) # 80004d1c <end_op>
    return -1;
    800060b6:	57fd                	li	a5,-1
    800060b8:	a83d                	j	800060f6 <sys_link+0x13c>
    iunlockput(dp);
    800060ba:	854a                	mv	a0,s2
    800060bc:	ffffe097          	auipc	ra,0xffffe
    800060c0:	15a080e7          	jalr	346(ra) # 80004216 <iunlockput>

bad:
  ilock(ip);
    800060c4:	8526                	mv	a0,s1
    800060c6:	ffffe097          	auipc	ra,0xffffe
    800060ca:	eee080e7          	jalr	-274(ra) # 80003fb4 <ilock>
  ip->nlink--;
    800060ce:	04a4d783          	lhu	a5,74(s1)
    800060d2:	37fd                	addiw	a5,a5,-1
    800060d4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800060d8:	8526                	mv	a0,s1
    800060da:	ffffe097          	auipc	ra,0xffffe
    800060de:	e10080e7          	jalr	-496(ra) # 80003eea <iupdate>
  iunlockput(ip);
    800060e2:	8526                	mv	a0,s1
    800060e4:	ffffe097          	auipc	ra,0xffffe
    800060e8:	132080e7          	jalr	306(ra) # 80004216 <iunlockput>
  end_op();
    800060ec:	fffff097          	auipc	ra,0xfffff
    800060f0:	c30080e7          	jalr	-976(ra) # 80004d1c <end_op>
  return -1;
    800060f4:	57fd                	li	a5,-1
}
    800060f6:	853e                	mv	a0,a5
    800060f8:	70b2                	ld	ra,296(sp)
    800060fa:	7412                	ld	s0,288(sp)
    800060fc:	64f2                	ld	s1,280(sp)
    800060fe:	6952                	ld	s2,272(sp)
    80006100:	6155                	addi	sp,sp,304
    80006102:	8082                	ret

0000000080006104 <isdirempty>:
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006104:	4578                	lw	a4,76(a0)
    80006106:	02000793          	li	a5,32
    8000610a:	04e7fa63          	bgeu	a5,a4,8000615e <isdirempty+0x5a>
{
    8000610e:	7179                	addi	sp,sp,-48
    80006110:	f406                	sd	ra,40(sp)
    80006112:	f022                	sd	s0,32(sp)
    80006114:	ec26                	sd	s1,24(sp)
    80006116:	e84a                	sd	s2,16(sp)
    80006118:	1800                	addi	s0,sp,48
    8000611a:	892a                	mv	s2,a0
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000611c:	02000493          	li	s1,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006120:	4741                	li	a4,16
    80006122:	86a6                	mv	a3,s1
    80006124:	fd040613          	addi	a2,s0,-48
    80006128:	4581                	li	a1,0
    8000612a:	854a                	mv	a0,s2
    8000612c:	ffffe097          	auipc	ra,0xffffe
    80006130:	13c080e7          	jalr	316(ra) # 80004268 <readi>
    80006134:	47c1                	li	a5,16
    80006136:	00f51c63          	bne	a0,a5,8000614e <isdirempty+0x4a>
      panic("isdirempty: readi");
    if(de.inum != 0)
    8000613a:	fd045783          	lhu	a5,-48(s0)
    8000613e:	e395                	bnez	a5,80006162 <isdirempty+0x5e>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006140:	24c1                	addiw	s1,s1,16
    80006142:	04c92783          	lw	a5,76(s2)
    80006146:	fcf4ede3          	bltu	s1,a5,80006120 <isdirempty+0x1c>
      return 0;
  }
  return 1;
    8000614a:	4505                	li	a0,1
    8000614c:	a821                	j	80006164 <isdirempty+0x60>
      panic("isdirempty: readi");
    8000614e:	00004517          	auipc	a0,0x4
    80006152:	a4250513          	addi	a0,a0,-1470 # 80009b90 <syscalls+0x310>
    80006156:	ffffa097          	auipc	ra,0xffffa
    8000615a:	3d4080e7          	jalr	980(ra) # 8000052a <panic>
  return 1;
    8000615e:	4505                	li	a0,1
}
    80006160:	8082                	ret
      return 0;
    80006162:	4501                	li	a0,0
}
    80006164:	70a2                	ld	ra,40(sp)
    80006166:	7402                	ld	s0,32(sp)
    80006168:	64e2                	ld	s1,24(sp)
    8000616a:	6942                	ld	s2,16(sp)
    8000616c:	6145                	addi	sp,sp,48
    8000616e:	8082                	ret

0000000080006170 <sys_unlink>:

uint64
sys_unlink(void)
{
    80006170:	7155                	addi	sp,sp,-208
    80006172:	e586                	sd	ra,200(sp)
    80006174:	e1a2                	sd	s0,192(sp)
    80006176:	fd26                	sd	s1,184(sp)
    80006178:	f94a                	sd	s2,176(sp)
    8000617a:	0980                	addi	s0,sp,208
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    8000617c:	08000613          	li	a2,128
    80006180:	f4040593          	addi	a1,s0,-192
    80006184:	4501                	li	a0,0
    80006186:	ffffd097          	auipc	ra,0xffffd
    8000618a:	300080e7          	jalr	768(ra) # 80003486 <argstr>
    8000618e:	16054363          	bltz	a0,800062f4 <sys_unlink+0x184>
    return -1;

  begin_op();
    80006192:	fffff097          	auipc	ra,0xfffff
    80006196:	b0a080e7          	jalr	-1270(ra) # 80004c9c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000619a:	fc040593          	addi	a1,s0,-64
    8000619e:	f4040513          	addi	a0,s0,-192
    800061a2:	ffffe097          	auipc	ra,0xffffe
    800061a6:	5e6080e7          	jalr	1510(ra) # 80004788 <nameiparent>
    800061aa:	84aa                	mv	s1,a0
    800061ac:	c961                	beqz	a0,8000627c <sys_unlink+0x10c>
    end_op();
    return -1;
  }

  ilock(dp);
    800061ae:	ffffe097          	auipc	ra,0xffffe
    800061b2:	e06080e7          	jalr	-506(ra) # 80003fb4 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800061b6:	00004597          	auipc	a1,0x4
    800061ba:	8ba58593          	addi	a1,a1,-1862 # 80009a70 <syscalls+0x1f0>
    800061be:	fc040513          	addi	a0,s0,-64
    800061c2:	ffffe097          	auipc	ra,0xffffe
    800061c6:	2bc080e7          	jalr	700(ra) # 8000447e <namecmp>
    800061ca:	c175                	beqz	a0,800062ae <sys_unlink+0x13e>
    800061cc:	00004597          	auipc	a1,0x4
    800061d0:	8ac58593          	addi	a1,a1,-1876 # 80009a78 <syscalls+0x1f8>
    800061d4:	fc040513          	addi	a0,s0,-64
    800061d8:	ffffe097          	auipc	ra,0xffffe
    800061dc:	2a6080e7          	jalr	678(ra) # 8000447e <namecmp>
    800061e0:	c579                	beqz	a0,800062ae <sys_unlink+0x13e>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    800061e2:	f3c40613          	addi	a2,s0,-196
    800061e6:	fc040593          	addi	a1,s0,-64
    800061ea:	8526                	mv	a0,s1
    800061ec:	ffffe097          	auipc	ra,0xffffe
    800061f0:	2ac080e7          	jalr	684(ra) # 80004498 <dirlookup>
    800061f4:	892a                	mv	s2,a0
    800061f6:	cd45                	beqz	a0,800062ae <sys_unlink+0x13e>
    goto bad;
  ilock(ip);
    800061f8:	ffffe097          	auipc	ra,0xffffe
    800061fc:	dbc080e7          	jalr	-580(ra) # 80003fb4 <ilock>

  if(ip->nlink < 1)
    80006200:	04a91783          	lh	a5,74(s2)
    80006204:	08f05263          	blez	a5,80006288 <sys_unlink+0x118>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006208:	04491703          	lh	a4,68(s2)
    8000620c:	4785                	li	a5,1
    8000620e:	08f70563          	beq	a4,a5,80006298 <sys_unlink+0x128>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    80006212:	4641                	li	a2,16
    80006214:	4581                	li	a1,0
    80006216:	fd040513          	addi	a0,s0,-48
    8000621a:	ffffb097          	auipc	ra,0xffffb
    8000621e:	aa4080e7          	jalr	-1372(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006222:	4741                	li	a4,16
    80006224:	f3c42683          	lw	a3,-196(s0)
    80006228:	fd040613          	addi	a2,s0,-48
    8000622c:	4581                	li	a1,0
    8000622e:	8526                	mv	a0,s1
    80006230:	ffffe097          	auipc	ra,0xffffe
    80006234:	130080e7          	jalr	304(ra) # 80004360 <writei>
    80006238:	47c1                	li	a5,16
    8000623a:	08f51a63          	bne	a0,a5,800062ce <sys_unlink+0x15e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    8000623e:	04491703          	lh	a4,68(s2)
    80006242:	4785                	li	a5,1
    80006244:	08f70d63          	beq	a4,a5,800062de <sys_unlink+0x16e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    80006248:	8526                	mv	a0,s1
    8000624a:	ffffe097          	auipc	ra,0xffffe
    8000624e:	fcc080e7          	jalr	-52(ra) # 80004216 <iunlockput>

  ip->nlink--;
    80006252:	04a95783          	lhu	a5,74(s2)
    80006256:	37fd                	addiw	a5,a5,-1
    80006258:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000625c:	854a                	mv	a0,s2
    8000625e:	ffffe097          	auipc	ra,0xffffe
    80006262:	c8c080e7          	jalr	-884(ra) # 80003eea <iupdate>
  iunlockput(ip);
    80006266:	854a                	mv	a0,s2
    80006268:	ffffe097          	auipc	ra,0xffffe
    8000626c:	fae080e7          	jalr	-82(ra) # 80004216 <iunlockput>

  end_op();
    80006270:	fffff097          	auipc	ra,0xfffff
    80006274:	aac080e7          	jalr	-1364(ra) # 80004d1c <end_op>

  return 0;
    80006278:	4501                	li	a0,0
    8000627a:	a0a1                	j	800062c2 <sys_unlink+0x152>
    end_op();
    8000627c:	fffff097          	auipc	ra,0xfffff
    80006280:	aa0080e7          	jalr	-1376(ra) # 80004d1c <end_op>
    return -1;
    80006284:	557d                	li	a0,-1
    80006286:	a835                	j	800062c2 <sys_unlink+0x152>
    panic("unlink: nlink < 1");
    80006288:	00003517          	auipc	a0,0x3
    8000628c:	7f850513          	addi	a0,a0,2040 # 80009a80 <syscalls+0x200>
    80006290:	ffffa097          	auipc	ra,0xffffa
    80006294:	29a080e7          	jalr	666(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006298:	854a                	mv	a0,s2
    8000629a:	00000097          	auipc	ra,0x0
    8000629e:	e6a080e7          	jalr	-406(ra) # 80006104 <isdirempty>
    800062a2:	f925                	bnez	a0,80006212 <sys_unlink+0xa2>
    iunlockput(ip);
    800062a4:	854a                	mv	a0,s2
    800062a6:	ffffe097          	auipc	ra,0xffffe
    800062aa:	f70080e7          	jalr	-144(ra) # 80004216 <iunlockput>

bad:
  iunlockput(dp);
    800062ae:	8526                	mv	a0,s1
    800062b0:	ffffe097          	auipc	ra,0xffffe
    800062b4:	f66080e7          	jalr	-154(ra) # 80004216 <iunlockput>
  end_op();
    800062b8:	fffff097          	auipc	ra,0xfffff
    800062bc:	a64080e7          	jalr	-1436(ra) # 80004d1c <end_op>
  return -1;
    800062c0:	557d                	li	a0,-1
}
    800062c2:	60ae                	ld	ra,200(sp)
    800062c4:	640e                	ld	s0,192(sp)
    800062c6:	74ea                	ld	s1,184(sp)
    800062c8:	794a                	ld	s2,176(sp)
    800062ca:	6169                	addi	sp,sp,208
    800062cc:	8082                	ret
    panic("unlink: writei");
    800062ce:	00003517          	auipc	a0,0x3
    800062d2:	7ca50513          	addi	a0,a0,1994 # 80009a98 <syscalls+0x218>
    800062d6:	ffffa097          	auipc	ra,0xffffa
    800062da:	254080e7          	jalr	596(ra) # 8000052a <panic>
    dp->nlink--;
    800062de:	04a4d783          	lhu	a5,74(s1)
    800062e2:	37fd                	addiw	a5,a5,-1
    800062e4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800062e8:	8526                	mv	a0,s1
    800062ea:	ffffe097          	auipc	ra,0xffffe
    800062ee:	c00080e7          	jalr	-1024(ra) # 80003eea <iupdate>
    800062f2:	bf99                	j	80006248 <sys_unlink+0xd8>
    return -1;
    800062f4:	557d                	li	a0,-1
    800062f6:	b7f1                	j	800062c2 <sys_unlink+0x152>

00000000800062f8 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
    800062f8:	715d                	addi	sp,sp,-80
    800062fa:	e486                	sd	ra,72(sp)
    800062fc:	e0a2                	sd	s0,64(sp)
    800062fe:	fc26                	sd	s1,56(sp)
    80006300:	f84a                	sd	s2,48(sp)
    80006302:	f44e                	sd	s3,40(sp)
    80006304:	f052                	sd	s4,32(sp)
    80006306:	ec56                	sd	s5,24(sp)
    80006308:	0880                	addi	s0,sp,80
    8000630a:	89ae                	mv	s3,a1
    8000630c:	8ab2                	mv	s5,a2
    8000630e:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80006310:	fb040593          	addi	a1,s0,-80
    80006314:	ffffe097          	auipc	ra,0xffffe
    80006318:	474080e7          	jalr	1140(ra) # 80004788 <nameiparent>
    8000631c:	892a                	mv	s2,a0
    8000631e:	12050e63          	beqz	a0,8000645a <create+0x162>
    return 0;

  ilock(dp);
    80006322:	ffffe097          	auipc	ra,0xffffe
    80006326:	c92080e7          	jalr	-878(ra) # 80003fb4 <ilock>
  
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000632a:	4601                	li	a2,0
    8000632c:	fb040593          	addi	a1,s0,-80
    80006330:	854a                	mv	a0,s2
    80006332:	ffffe097          	auipc	ra,0xffffe
    80006336:	166080e7          	jalr	358(ra) # 80004498 <dirlookup>
    8000633a:	84aa                	mv	s1,a0
    8000633c:	c921                	beqz	a0,8000638c <create+0x94>
    iunlockput(dp);
    8000633e:	854a                	mv	a0,s2
    80006340:	ffffe097          	auipc	ra,0xffffe
    80006344:	ed6080e7          	jalr	-298(ra) # 80004216 <iunlockput>
    ilock(ip);
    80006348:	8526                	mv	a0,s1
    8000634a:	ffffe097          	auipc	ra,0xffffe
    8000634e:	c6a080e7          	jalr	-918(ra) # 80003fb4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006352:	2981                	sext.w	s3,s3
    80006354:	4789                	li	a5,2
    80006356:	02f99463          	bne	s3,a5,8000637e <create+0x86>
    8000635a:	0444d783          	lhu	a5,68(s1)
    8000635e:	37f9                	addiw	a5,a5,-2
    80006360:	17c2                	slli	a5,a5,0x30
    80006362:	93c1                	srli	a5,a5,0x30
    80006364:	4705                	li	a4,1
    80006366:	00f76c63          	bltu	a4,a5,8000637e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000636a:	8526                	mv	a0,s1
    8000636c:	60a6                	ld	ra,72(sp)
    8000636e:	6406                	ld	s0,64(sp)
    80006370:	74e2                	ld	s1,56(sp)
    80006372:	7942                	ld	s2,48(sp)
    80006374:	79a2                	ld	s3,40(sp)
    80006376:	7a02                	ld	s4,32(sp)
    80006378:	6ae2                	ld	s5,24(sp)
    8000637a:	6161                	addi	sp,sp,80
    8000637c:	8082                	ret
    iunlockput(ip);
    8000637e:	8526                	mv	a0,s1
    80006380:	ffffe097          	auipc	ra,0xffffe
    80006384:	e96080e7          	jalr	-362(ra) # 80004216 <iunlockput>
    return 0;
    80006388:	4481                	li	s1,0
    8000638a:	b7c5                	j	8000636a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000638c:	85ce                	mv	a1,s3
    8000638e:	00092503          	lw	a0,0(s2)
    80006392:	ffffe097          	auipc	ra,0xffffe
    80006396:	a8a080e7          	jalr	-1398(ra) # 80003e1c <ialloc>
    8000639a:	84aa                	mv	s1,a0
    8000639c:	c521                	beqz	a0,800063e4 <create+0xec>
  ilock(ip);
    8000639e:	ffffe097          	auipc	ra,0xffffe
    800063a2:	c16080e7          	jalr	-1002(ra) # 80003fb4 <ilock>
  ip->major = major;
    800063a6:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800063aa:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800063ae:	4a05                	li	s4,1
    800063b0:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800063b4:	8526                	mv	a0,s1
    800063b6:	ffffe097          	auipc	ra,0xffffe
    800063ba:	b34080e7          	jalr	-1228(ra) # 80003eea <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800063be:	2981                	sext.w	s3,s3
    800063c0:	03498a63          	beq	s3,s4,800063f4 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800063c4:	40d0                	lw	a2,4(s1)
    800063c6:	fb040593          	addi	a1,s0,-80
    800063ca:	854a                	mv	a0,s2
    800063cc:	ffffe097          	auipc	ra,0xffffe
    800063d0:	2dc080e7          	jalr	732(ra) # 800046a8 <dirlink>
    800063d4:	06054b63          	bltz	a0,8000644a <create+0x152>
  iunlockput(dp);
    800063d8:	854a                	mv	a0,s2
    800063da:	ffffe097          	auipc	ra,0xffffe
    800063de:	e3c080e7          	jalr	-452(ra) # 80004216 <iunlockput>
  return ip;
    800063e2:	b761                	j	8000636a <create+0x72>
    panic("create: ialloc");
    800063e4:	00003517          	auipc	a0,0x3
    800063e8:	7c450513          	addi	a0,a0,1988 # 80009ba8 <syscalls+0x328>
    800063ec:	ffffa097          	auipc	ra,0xffffa
    800063f0:	13e080e7          	jalr	318(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    800063f4:	04a95783          	lhu	a5,74(s2)
    800063f8:	2785                	addiw	a5,a5,1
    800063fa:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800063fe:	854a                	mv	a0,s2
    80006400:	ffffe097          	auipc	ra,0xffffe
    80006404:	aea080e7          	jalr	-1302(ra) # 80003eea <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80006408:	40d0                	lw	a2,4(s1)
    8000640a:	00003597          	auipc	a1,0x3
    8000640e:	66658593          	addi	a1,a1,1638 # 80009a70 <syscalls+0x1f0>
    80006412:	8526                	mv	a0,s1
    80006414:	ffffe097          	auipc	ra,0xffffe
    80006418:	294080e7          	jalr	660(ra) # 800046a8 <dirlink>
    8000641c:	00054f63          	bltz	a0,8000643a <create+0x142>
    80006420:	00492603          	lw	a2,4(s2)
    80006424:	00003597          	auipc	a1,0x3
    80006428:	65458593          	addi	a1,a1,1620 # 80009a78 <syscalls+0x1f8>
    8000642c:	8526                	mv	a0,s1
    8000642e:	ffffe097          	auipc	ra,0xffffe
    80006432:	27a080e7          	jalr	634(ra) # 800046a8 <dirlink>
    80006436:	f80557e3          	bgez	a0,800063c4 <create+0xcc>
      panic("create dots");
    8000643a:	00003517          	auipc	a0,0x3
    8000643e:	77e50513          	addi	a0,a0,1918 # 80009bb8 <syscalls+0x338>
    80006442:	ffffa097          	auipc	ra,0xffffa
    80006446:	0e8080e7          	jalr	232(ra) # 8000052a <panic>
    panic("create: dirlink");
    8000644a:	00003517          	auipc	a0,0x3
    8000644e:	77e50513          	addi	a0,a0,1918 # 80009bc8 <syscalls+0x348>
    80006452:	ffffa097          	auipc	ra,0xffffa
    80006456:	0d8080e7          	jalr	216(ra) # 8000052a <panic>
    return 0;
    8000645a:	84aa                	mv	s1,a0
    8000645c:	b739                	j	8000636a <create+0x72>

000000008000645e <sys_open>:

uint64
sys_open(void)
{
    8000645e:	7131                	addi	sp,sp,-192
    80006460:	fd06                	sd	ra,184(sp)
    80006462:	f922                	sd	s0,176(sp)
    80006464:	f526                	sd	s1,168(sp)
    80006466:	f14a                	sd	s2,160(sp)
    80006468:	ed4e                	sd	s3,152(sp)
    8000646a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000646c:	08000613          	li	a2,128
    80006470:	f5040593          	addi	a1,s0,-176
    80006474:	4501                	li	a0,0
    80006476:	ffffd097          	auipc	ra,0xffffd
    8000647a:	010080e7          	jalr	16(ra) # 80003486 <argstr>
    return -1;
    8000647e:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006480:	0c054163          	bltz	a0,80006542 <sys_open+0xe4>
    80006484:	f4c40593          	addi	a1,s0,-180
    80006488:	4505                	li	a0,1
    8000648a:	ffffd097          	auipc	ra,0xffffd
    8000648e:	fb8080e7          	jalr	-72(ra) # 80003442 <argint>
    80006492:	0a054863          	bltz	a0,80006542 <sys_open+0xe4>

  begin_op();
    80006496:	fffff097          	auipc	ra,0xfffff
    8000649a:	806080e7          	jalr	-2042(ra) # 80004c9c <begin_op>

  if(omode & O_CREATE){
    8000649e:	f4c42783          	lw	a5,-180(s0)
    800064a2:	2007f793          	andi	a5,a5,512
    800064a6:	cbdd                	beqz	a5,8000655c <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800064a8:	4681                	li	a3,0
    800064aa:	4601                	li	a2,0
    800064ac:	4589                	li	a1,2
    800064ae:	f5040513          	addi	a0,s0,-176
    800064b2:	00000097          	auipc	ra,0x0
    800064b6:	e46080e7          	jalr	-442(ra) # 800062f8 <create>
    800064ba:	892a                	mv	s2,a0
    if(ip == 0){
    800064bc:	c959                	beqz	a0,80006552 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800064be:	04491703          	lh	a4,68(s2)
    800064c2:	478d                	li	a5,3
    800064c4:	00f71763          	bne	a4,a5,800064d2 <sys_open+0x74>
    800064c8:	04695703          	lhu	a4,70(s2)
    800064cc:	47a5                	li	a5,9
    800064ce:	0ce7ec63          	bltu	a5,a4,800065a6 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800064d2:	fffff097          	auipc	ra,0xfffff
    800064d6:	bda080e7          	jalr	-1062(ra) # 800050ac <filealloc>
    800064da:	89aa                	mv	s3,a0
    800064dc:	10050263          	beqz	a0,800065e0 <sys_open+0x182>
    800064e0:	00000097          	auipc	ra,0x0
    800064e4:	8e2080e7          	jalr	-1822(ra) # 80005dc2 <fdalloc>
    800064e8:	84aa                	mv	s1,a0
    800064ea:	0e054663          	bltz	a0,800065d6 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800064ee:	04491703          	lh	a4,68(s2)
    800064f2:	478d                	li	a5,3
    800064f4:	0cf70463          	beq	a4,a5,800065bc <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800064f8:	4789                	li	a5,2
    800064fa:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800064fe:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80006502:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80006506:	f4c42783          	lw	a5,-180(s0)
    8000650a:	0017c713          	xori	a4,a5,1
    8000650e:	8b05                	andi	a4,a4,1
    80006510:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006514:	0037f713          	andi	a4,a5,3
    80006518:	00e03733          	snez	a4,a4
    8000651c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006520:	4007f793          	andi	a5,a5,1024
    80006524:	c791                	beqz	a5,80006530 <sys_open+0xd2>
    80006526:	04491703          	lh	a4,68(s2)
    8000652a:	4789                	li	a5,2
    8000652c:	08f70f63          	beq	a4,a5,800065ca <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006530:	854a                	mv	a0,s2
    80006532:	ffffe097          	auipc	ra,0xffffe
    80006536:	b44080e7          	jalr	-1212(ra) # 80004076 <iunlock>
  end_op();
    8000653a:	ffffe097          	auipc	ra,0xffffe
    8000653e:	7e2080e7          	jalr	2018(ra) # 80004d1c <end_op>

  return fd;
}
    80006542:	8526                	mv	a0,s1
    80006544:	70ea                	ld	ra,184(sp)
    80006546:	744a                	ld	s0,176(sp)
    80006548:	74aa                	ld	s1,168(sp)
    8000654a:	790a                	ld	s2,160(sp)
    8000654c:	69ea                	ld	s3,152(sp)
    8000654e:	6129                	addi	sp,sp,192
    80006550:	8082                	ret
      end_op();
    80006552:	ffffe097          	auipc	ra,0xffffe
    80006556:	7ca080e7          	jalr	1994(ra) # 80004d1c <end_op>
      return -1;
    8000655a:	b7e5                	j	80006542 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000655c:	f5040513          	addi	a0,s0,-176
    80006560:	ffffe097          	auipc	ra,0xffffe
    80006564:	20a080e7          	jalr	522(ra) # 8000476a <namei>
    80006568:	892a                	mv	s2,a0
    8000656a:	c905                	beqz	a0,8000659a <sys_open+0x13c>
    ilock(ip);
    8000656c:	ffffe097          	auipc	ra,0xffffe
    80006570:	a48080e7          	jalr	-1464(ra) # 80003fb4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006574:	04491703          	lh	a4,68(s2)
    80006578:	4785                	li	a5,1
    8000657a:	f4f712e3          	bne	a4,a5,800064be <sys_open+0x60>
    8000657e:	f4c42783          	lw	a5,-180(s0)
    80006582:	dba1                	beqz	a5,800064d2 <sys_open+0x74>
      iunlockput(ip);
    80006584:	854a                	mv	a0,s2
    80006586:	ffffe097          	auipc	ra,0xffffe
    8000658a:	c90080e7          	jalr	-880(ra) # 80004216 <iunlockput>
      end_op();
    8000658e:	ffffe097          	auipc	ra,0xffffe
    80006592:	78e080e7          	jalr	1934(ra) # 80004d1c <end_op>
      return -1;
    80006596:	54fd                	li	s1,-1
    80006598:	b76d                	j	80006542 <sys_open+0xe4>
      end_op();
    8000659a:	ffffe097          	auipc	ra,0xffffe
    8000659e:	782080e7          	jalr	1922(ra) # 80004d1c <end_op>
      return -1;
    800065a2:	54fd                	li	s1,-1
    800065a4:	bf79                	j	80006542 <sys_open+0xe4>
    iunlockput(ip);
    800065a6:	854a                	mv	a0,s2
    800065a8:	ffffe097          	auipc	ra,0xffffe
    800065ac:	c6e080e7          	jalr	-914(ra) # 80004216 <iunlockput>
    end_op();
    800065b0:	ffffe097          	auipc	ra,0xffffe
    800065b4:	76c080e7          	jalr	1900(ra) # 80004d1c <end_op>
    return -1;
    800065b8:	54fd                	li	s1,-1
    800065ba:	b761                	j	80006542 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800065bc:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800065c0:	04691783          	lh	a5,70(s2)
    800065c4:	02f99223          	sh	a5,36(s3)
    800065c8:	bf2d                	j	80006502 <sys_open+0xa4>
    itrunc(ip);
    800065ca:	854a                	mv	a0,s2
    800065cc:	ffffe097          	auipc	ra,0xffffe
    800065d0:	af6080e7          	jalr	-1290(ra) # 800040c2 <itrunc>
    800065d4:	bfb1                	j	80006530 <sys_open+0xd2>
      fileclose(f);
    800065d6:	854e                	mv	a0,s3
    800065d8:	fffff097          	auipc	ra,0xfffff
    800065dc:	b90080e7          	jalr	-1136(ra) # 80005168 <fileclose>
    iunlockput(ip);
    800065e0:	854a                	mv	a0,s2
    800065e2:	ffffe097          	auipc	ra,0xffffe
    800065e6:	c34080e7          	jalr	-972(ra) # 80004216 <iunlockput>
    end_op();
    800065ea:	ffffe097          	auipc	ra,0xffffe
    800065ee:	732080e7          	jalr	1842(ra) # 80004d1c <end_op>
    return -1;
    800065f2:	54fd                	li	s1,-1
    800065f4:	b7b9                	j	80006542 <sys_open+0xe4>

00000000800065f6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800065f6:	7175                	addi	sp,sp,-144
    800065f8:	e506                	sd	ra,136(sp)
    800065fa:	e122                	sd	s0,128(sp)
    800065fc:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800065fe:	ffffe097          	auipc	ra,0xffffe
    80006602:	69e080e7          	jalr	1694(ra) # 80004c9c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006606:	08000613          	li	a2,128
    8000660a:	f7040593          	addi	a1,s0,-144
    8000660e:	4501                	li	a0,0
    80006610:	ffffd097          	auipc	ra,0xffffd
    80006614:	e76080e7          	jalr	-394(ra) # 80003486 <argstr>
    80006618:	02054963          	bltz	a0,8000664a <sys_mkdir+0x54>
    8000661c:	4681                	li	a3,0
    8000661e:	4601                	li	a2,0
    80006620:	4585                	li	a1,1
    80006622:	f7040513          	addi	a0,s0,-144
    80006626:	00000097          	auipc	ra,0x0
    8000662a:	cd2080e7          	jalr	-814(ra) # 800062f8 <create>
    8000662e:	cd11                	beqz	a0,8000664a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006630:	ffffe097          	auipc	ra,0xffffe
    80006634:	be6080e7          	jalr	-1050(ra) # 80004216 <iunlockput>
  end_op();
    80006638:	ffffe097          	auipc	ra,0xffffe
    8000663c:	6e4080e7          	jalr	1764(ra) # 80004d1c <end_op>
  return 0;
    80006640:	4501                	li	a0,0
}
    80006642:	60aa                	ld	ra,136(sp)
    80006644:	640a                	ld	s0,128(sp)
    80006646:	6149                	addi	sp,sp,144
    80006648:	8082                	ret
    end_op();
    8000664a:	ffffe097          	auipc	ra,0xffffe
    8000664e:	6d2080e7          	jalr	1746(ra) # 80004d1c <end_op>
    return -1;
    80006652:	557d                	li	a0,-1
    80006654:	b7fd                	j	80006642 <sys_mkdir+0x4c>

0000000080006656 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006656:	7135                	addi	sp,sp,-160
    80006658:	ed06                	sd	ra,152(sp)
    8000665a:	e922                	sd	s0,144(sp)
    8000665c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000665e:	ffffe097          	auipc	ra,0xffffe
    80006662:	63e080e7          	jalr	1598(ra) # 80004c9c <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006666:	08000613          	li	a2,128
    8000666a:	f7040593          	addi	a1,s0,-144
    8000666e:	4501                	li	a0,0
    80006670:	ffffd097          	auipc	ra,0xffffd
    80006674:	e16080e7          	jalr	-490(ra) # 80003486 <argstr>
    80006678:	04054a63          	bltz	a0,800066cc <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000667c:	f6c40593          	addi	a1,s0,-148
    80006680:	4505                	li	a0,1
    80006682:	ffffd097          	auipc	ra,0xffffd
    80006686:	dc0080e7          	jalr	-576(ra) # 80003442 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000668a:	04054163          	bltz	a0,800066cc <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000668e:	f6840593          	addi	a1,s0,-152
    80006692:	4509                	li	a0,2
    80006694:	ffffd097          	auipc	ra,0xffffd
    80006698:	dae080e7          	jalr	-594(ra) # 80003442 <argint>
     argint(1, &major) < 0 ||
    8000669c:	02054863          	bltz	a0,800066cc <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800066a0:	f6841683          	lh	a3,-152(s0)
    800066a4:	f6c41603          	lh	a2,-148(s0)
    800066a8:	458d                	li	a1,3
    800066aa:	f7040513          	addi	a0,s0,-144
    800066ae:	00000097          	auipc	ra,0x0
    800066b2:	c4a080e7          	jalr	-950(ra) # 800062f8 <create>
     argint(2, &minor) < 0 ||
    800066b6:	c919                	beqz	a0,800066cc <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800066b8:	ffffe097          	auipc	ra,0xffffe
    800066bc:	b5e080e7          	jalr	-1186(ra) # 80004216 <iunlockput>
  end_op();
    800066c0:	ffffe097          	auipc	ra,0xffffe
    800066c4:	65c080e7          	jalr	1628(ra) # 80004d1c <end_op>
  return 0;
    800066c8:	4501                	li	a0,0
    800066ca:	a031                	j	800066d6 <sys_mknod+0x80>
    end_op();
    800066cc:	ffffe097          	auipc	ra,0xffffe
    800066d0:	650080e7          	jalr	1616(ra) # 80004d1c <end_op>
    return -1;
    800066d4:	557d                	li	a0,-1
}
    800066d6:	60ea                	ld	ra,152(sp)
    800066d8:	644a                	ld	s0,144(sp)
    800066da:	610d                	addi	sp,sp,160
    800066dc:	8082                	ret

00000000800066de <sys_chdir>:

uint64
sys_chdir(void)
{
    800066de:	7135                	addi	sp,sp,-160
    800066e0:	ed06                	sd	ra,152(sp)
    800066e2:	e922                	sd	s0,144(sp)
    800066e4:	e526                	sd	s1,136(sp)
    800066e6:	e14a                	sd	s2,128(sp)
    800066e8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800066ea:	ffffb097          	auipc	ra,0xffffb
    800066ee:	48c080e7          	jalr	1164(ra) # 80001b76 <myproc>
    800066f2:	892a                	mv	s2,a0
  
  begin_op();
    800066f4:	ffffe097          	auipc	ra,0xffffe
    800066f8:	5a8080e7          	jalr	1448(ra) # 80004c9c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800066fc:	08000613          	li	a2,128
    80006700:	f6040593          	addi	a1,s0,-160
    80006704:	4501                	li	a0,0
    80006706:	ffffd097          	auipc	ra,0xffffd
    8000670a:	d80080e7          	jalr	-640(ra) # 80003486 <argstr>
    8000670e:	04054b63          	bltz	a0,80006764 <sys_chdir+0x86>
    80006712:	f6040513          	addi	a0,s0,-160
    80006716:	ffffe097          	auipc	ra,0xffffe
    8000671a:	054080e7          	jalr	84(ra) # 8000476a <namei>
    8000671e:	84aa                	mv	s1,a0
    80006720:	c131                	beqz	a0,80006764 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006722:	ffffe097          	auipc	ra,0xffffe
    80006726:	892080e7          	jalr	-1902(ra) # 80003fb4 <ilock>
  if(ip->type != T_DIR){
    8000672a:	04449703          	lh	a4,68(s1)
    8000672e:	4785                	li	a5,1
    80006730:	04f71063          	bne	a4,a5,80006770 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006734:	8526                	mv	a0,s1
    80006736:	ffffe097          	auipc	ra,0xffffe
    8000673a:	940080e7          	jalr	-1728(ra) # 80004076 <iunlock>
  iput(p->cwd);
    8000673e:	15093503          	ld	a0,336(s2)
    80006742:	ffffe097          	auipc	ra,0xffffe
    80006746:	a2c080e7          	jalr	-1492(ra) # 8000416e <iput>
  end_op();
    8000674a:	ffffe097          	auipc	ra,0xffffe
    8000674e:	5d2080e7          	jalr	1490(ra) # 80004d1c <end_op>
  p->cwd = ip;
    80006752:	14993823          	sd	s1,336(s2)
  return 0;
    80006756:	4501                	li	a0,0
}
    80006758:	60ea                	ld	ra,152(sp)
    8000675a:	644a                	ld	s0,144(sp)
    8000675c:	64aa                	ld	s1,136(sp)
    8000675e:	690a                	ld	s2,128(sp)
    80006760:	610d                	addi	sp,sp,160
    80006762:	8082                	ret
    end_op();
    80006764:	ffffe097          	auipc	ra,0xffffe
    80006768:	5b8080e7          	jalr	1464(ra) # 80004d1c <end_op>
    return -1;
    8000676c:	557d                	li	a0,-1
    8000676e:	b7ed                	j	80006758 <sys_chdir+0x7a>
    iunlockput(ip);
    80006770:	8526                	mv	a0,s1
    80006772:	ffffe097          	auipc	ra,0xffffe
    80006776:	aa4080e7          	jalr	-1372(ra) # 80004216 <iunlockput>
    end_op();
    8000677a:	ffffe097          	auipc	ra,0xffffe
    8000677e:	5a2080e7          	jalr	1442(ra) # 80004d1c <end_op>
    return -1;
    80006782:	557d                	li	a0,-1
    80006784:	bfd1                	j	80006758 <sys_chdir+0x7a>

0000000080006786 <sys_exec>:

uint64
sys_exec(void)
{
    80006786:	7145                	addi	sp,sp,-464
    80006788:	e786                	sd	ra,456(sp)
    8000678a:	e3a2                	sd	s0,448(sp)
    8000678c:	ff26                	sd	s1,440(sp)
    8000678e:	fb4a                	sd	s2,432(sp)
    80006790:	f74e                	sd	s3,424(sp)
    80006792:	f352                	sd	s4,416(sp)
    80006794:	ef56                	sd	s5,408(sp)
    80006796:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006798:	08000613          	li	a2,128
    8000679c:	f4040593          	addi	a1,s0,-192
    800067a0:	4501                	li	a0,0
    800067a2:	ffffd097          	auipc	ra,0xffffd
    800067a6:	ce4080e7          	jalr	-796(ra) # 80003486 <argstr>
    return -1;
    800067aa:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800067ac:	0c054a63          	bltz	a0,80006880 <sys_exec+0xfa>
    800067b0:	e3840593          	addi	a1,s0,-456
    800067b4:	4505                	li	a0,1
    800067b6:	ffffd097          	auipc	ra,0xffffd
    800067ba:	cae080e7          	jalr	-850(ra) # 80003464 <argaddr>
    800067be:	0c054163          	bltz	a0,80006880 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800067c2:	10000613          	li	a2,256
    800067c6:	4581                	li	a1,0
    800067c8:	e4040513          	addi	a0,s0,-448
    800067cc:	ffffa097          	auipc	ra,0xffffa
    800067d0:	4f2080e7          	jalr	1266(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800067d4:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800067d8:	89a6                	mv	s3,s1
    800067da:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800067dc:	02000a13          	li	s4,32
    800067e0:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800067e4:	00391793          	slli	a5,s2,0x3
    800067e8:	e3040593          	addi	a1,s0,-464
    800067ec:	e3843503          	ld	a0,-456(s0)
    800067f0:	953e                	add	a0,a0,a5
    800067f2:	ffffd097          	auipc	ra,0xffffd
    800067f6:	bb6080e7          	jalr	-1098(ra) # 800033a8 <fetchaddr>
    800067fa:	02054a63          	bltz	a0,8000682e <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    800067fe:	e3043783          	ld	a5,-464(s0)
    80006802:	c3b9                	beqz	a5,80006848 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006804:	ffffa097          	auipc	ra,0xffffa
    80006808:	2ce080e7          	jalr	718(ra) # 80000ad2 <kalloc>
    8000680c:	85aa                	mv	a1,a0
    8000680e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006812:	cd11                	beqz	a0,8000682e <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006814:	6605                	lui	a2,0x1
    80006816:	e3043503          	ld	a0,-464(s0)
    8000681a:	ffffd097          	auipc	ra,0xffffd
    8000681e:	be0080e7          	jalr	-1056(ra) # 800033fa <fetchstr>
    80006822:	00054663          	bltz	a0,8000682e <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006826:	0905                	addi	s2,s2,1
    80006828:	09a1                	addi	s3,s3,8
    8000682a:	fb491be3          	bne	s2,s4,800067e0 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000682e:	10048913          	addi	s2,s1,256
    80006832:	6088                	ld	a0,0(s1)
    80006834:	c529                	beqz	a0,8000687e <sys_exec+0xf8>
    kfree(argv[i]);
    80006836:	ffffa097          	auipc	ra,0xffffa
    8000683a:	1a0080e7          	jalr	416(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000683e:	04a1                	addi	s1,s1,8
    80006840:	ff2499e3          	bne	s1,s2,80006832 <sys_exec+0xac>
  return -1;
    80006844:	597d                	li	s2,-1
    80006846:	a82d                	j	80006880 <sys_exec+0xfa>
      argv[i] = 0;
    80006848:	0a8e                	slli	s5,s5,0x3
    8000684a:	fc040793          	addi	a5,s0,-64
    8000684e:	9abe                	add	s5,s5,a5
    80006850:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffcfe80>
  int ret = exec(path, argv);
    80006854:	e4040593          	addi	a1,s0,-448
    80006858:	f4040513          	addi	a0,s0,-192
    8000685c:	fffff097          	auipc	ra,0xfffff
    80006860:	154080e7          	jalr	340(ra) # 800059b0 <exec>
    80006864:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006866:	10048993          	addi	s3,s1,256
    8000686a:	6088                	ld	a0,0(s1)
    8000686c:	c911                	beqz	a0,80006880 <sys_exec+0xfa>
    kfree(argv[i]);
    8000686e:	ffffa097          	auipc	ra,0xffffa
    80006872:	168080e7          	jalr	360(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006876:	04a1                	addi	s1,s1,8
    80006878:	ff3499e3          	bne	s1,s3,8000686a <sys_exec+0xe4>
    8000687c:	a011                	j	80006880 <sys_exec+0xfa>
  return -1;
    8000687e:	597d                	li	s2,-1
}
    80006880:	854a                	mv	a0,s2
    80006882:	60be                	ld	ra,456(sp)
    80006884:	641e                	ld	s0,448(sp)
    80006886:	74fa                	ld	s1,440(sp)
    80006888:	795a                	ld	s2,432(sp)
    8000688a:	79ba                	ld	s3,424(sp)
    8000688c:	7a1a                	ld	s4,416(sp)
    8000688e:	6afa                	ld	s5,408(sp)
    80006890:	6179                	addi	sp,sp,464
    80006892:	8082                	ret

0000000080006894 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006894:	7139                	addi	sp,sp,-64
    80006896:	fc06                	sd	ra,56(sp)
    80006898:	f822                	sd	s0,48(sp)
    8000689a:	f426                	sd	s1,40(sp)
    8000689c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000689e:	ffffb097          	auipc	ra,0xffffb
    800068a2:	2d8080e7          	jalr	728(ra) # 80001b76 <myproc>
    800068a6:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800068a8:	fd840593          	addi	a1,s0,-40
    800068ac:	4501                	li	a0,0
    800068ae:	ffffd097          	auipc	ra,0xffffd
    800068b2:	bb6080e7          	jalr	-1098(ra) # 80003464 <argaddr>
    return -1;
    800068b6:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800068b8:	0e054063          	bltz	a0,80006998 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800068bc:	fc840593          	addi	a1,s0,-56
    800068c0:	fd040513          	addi	a0,s0,-48
    800068c4:	fffff097          	auipc	ra,0xfffff
    800068c8:	dca080e7          	jalr	-566(ra) # 8000568e <pipealloc>
    return -1;
    800068cc:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800068ce:	0c054563          	bltz	a0,80006998 <sys_pipe+0x104>
  fd0 = -1;
    800068d2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800068d6:	fd043503          	ld	a0,-48(s0)
    800068da:	fffff097          	auipc	ra,0xfffff
    800068de:	4e8080e7          	jalr	1256(ra) # 80005dc2 <fdalloc>
    800068e2:	fca42223          	sw	a0,-60(s0)
    800068e6:	08054c63          	bltz	a0,8000697e <sys_pipe+0xea>
    800068ea:	fc843503          	ld	a0,-56(s0)
    800068ee:	fffff097          	auipc	ra,0xfffff
    800068f2:	4d4080e7          	jalr	1236(ra) # 80005dc2 <fdalloc>
    800068f6:	fca42023          	sw	a0,-64(s0)
    800068fa:	06054863          	bltz	a0,8000696a <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800068fe:	4691                	li	a3,4
    80006900:	fc440613          	addi	a2,s0,-60
    80006904:	fd843583          	ld	a1,-40(s0)
    80006908:	68a8                	ld	a0,80(s1)
    8000690a:	ffffb097          	auipc	ra,0xffffb
    8000690e:	a8a080e7          	jalr	-1398(ra) # 80001394 <copyout>
    80006912:	02054063          	bltz	a0,80006932 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006916:	4691                	li	a3,4
    80006918:	fc040613          	addi	a2,s0,-64
    8000691c:	fd843583          	ld	a1,-40(s0)
    80006920:	0591                	addi	a1,a1,4
    80006922:	68a8                	ld	a0,80(s1)
    80006924:	ffffb097          	auipc	ra,0xffffb
    80006928:	a70080e7          	jalr	-1424(ra) # 80001394 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000692c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000692e:	06055563          	bgez	a0,80006998 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006932:	fc442783          	lw	a5,-60(s0)
    80006936:	07e9                	addi	a5,a5,26
    80006938:	078e                	slli	a5,a5,0x3
    8000693a:	97a6                	add	a5,a5,s1
    8000693c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006940:	fc042503          	lw	a0,-64(s0)
    80006944:	0569                	addi	a0,a0,26
    80006946:	050e                	slli	a0,a0,0x3
    80006948:	9526                	add	a0,a0,s1
    8000694a:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    8000694e:	fd043503          	ld	a0,-48(s0)
    80006952:	fffff097          	auipc	ra,0xfffff
    80006956:	816080e7          	jalr	-2026(ra) # 80005168 <fileclose>
    fileclose(wf);
    8000695a:	fc843503          	ld	a0,-56(s0)
    8000695e:	fffff097          	auipc	ra,0xfffff
    80006962:	80a080e7          	jalr	-2038(ra) # 80005168 <fileclose>
    return -1;
    80006966:	57fd                	li	a5,-1
    80006968:	a805                	j	80006998 <sys_pipe+0x104>
    if(fd0 >= 0)
    8000696a:	fc442783          	lw	a5,-60(s0)
    8000696e:	0007c863          	bltz	a5,8000697e <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006972:	01a78513          	addi	a0,a5,26
    80006976:	050e                	slli	a0,a0,0x3
    80006978:	9526                	add	a0,a0,s1
    8000697a:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    8000697e:	fd043503          	ld	a0,-48(s0)
    80006982:	ffffe097          	auipc	ra,0xffffe
    80006986:	7e6080e7          	jalr	2022(ra) # 80005168 <fileclose>
    fileclose(wf);
    8000698a:	fc843503          	ld	a0,-56(s0)
    8000698e:	ffffe097          	auipc	ra,0xffffe
    80006992:	7da080e7          	jalr	2010(ra) # 80005168 <fileclose>
    return -1;
    80006996:	57fd                	li	a5,-1
}
    80006998:	853e                	mv	a0,a5
    8000699a:	70e2                	ld	ra,56(sp)
    8000699c:	7442                	ld	s0,48(sp)
    8000699e:	74a2                	ld	s1,40(sp)
    800069a0:	6121                	addi	sp,sp,64
    800069a2:	8082                	ret
	...

00000000800069b0 <kernelvec>:
    800069b0:	7111                	addi	sp,sp,-256
    800069b2:	e006                	sd	ra,0(sp)
    800069b4:	e40a                	sd	sp,8(sp)
    800069b6:	e80e                	sd	gp,16(sp)
    800069b8:	ec12                	sd	tp,24(sp)
    800069ba:	f016                	sd	t0,32(sp)
    800069bc:	f41a                	sd	t1,40(sp)
    800069be:	f81e                	sd	t2,48(sp)
    800069c0:	fc22                	sd	s0,56(sp)
    800069c2:	e0a6                	sd	s1,64(sp)
    800069c4:	e4aa                	sd	a0,72(sp)
    800069c6:	e8ae                	sd	a1,80(sp)
    800069c8:	ecb2                	sd	a2,88(sp)
    800069ca:	f0b6                	sd	a3,96(sp)
    800069cc:	f4ba                	sd	a4,104(sp)
    800069ce:	f8be                	sd	a5,112(sp)
    800069d0:	fcc2                	sd	a6,120(sp)
    800069d2:	e146                	sd	a7,128(sp)
    800069d4:	e54a                	sd	s2,136(sp)
    800069d6:	e94e                	sd	s3,144(sp)
    800069d8:	ed52                	sd	s4,152(sp)
    800069da:	f156                	sd	s5,160(sp)
    800069dc:	f55a                	sd	s6,168(sp)
    800069de:	f95e                	sd	s7,176(sp)
    800069e0:	fd62                	sd	s8,184(sp)
    800069e2:	e1e6                	sd	s9,192(sp)
    800069e4:	e5ea                	sd	s10,200(sp)
    800069e6:	e9ee                	sd	s11,208(sp)
    800069e8:	edf2                	sd	t3,216(sp)
    800069ea:	f1f6                	sd	t4,224(sp)
    800069ec:	f5fa                	sd	t5,232(sp)
    800069ee:	f9fe                	sd	t6,240(sp)
    800069f0:	885fc0ef          	jal	ra,80003274 <kerneltrap>
    800069f4:	6082                	ld	ra,0(sp)
    800069f6:	6122                	ld	sp,8(sp)
    800069f8:	61c2                	ld	gp,16(sp)
    800069fa:	7282                	ld	t0,32(sp)
    800069fc:	7322                	ld	t1,40(sp)
    800069fe:	73c2                	ld	t2,48(sp)
    80006a00:	7462                	ld	s0,56(sp)
    80006a02:	6486                	ld	s1,64(sp)
    80006a04:	6526                	ld	a0,72(sp)
    80006a06:	65c6                	ld	a1,80(sp)
    80006a08:	6666                	ld	a2,88(sp)
    80006a0a:	7686                	ld	a3,96(sp)
    80006a0c:	7726                	ld	a4,104(sp)
    80006a0e:	77c6                	ld	a5,112(sp)
    80006a10:	7866                	ld	a6,120(sp)
    80006a12:	688a                	ld	a7,128(sp)
    80006a14:	692a                	ld	s2,136(sp)
    80006a16:	69ca                	ld	s3,144(sp)
    80006a18:	6a6a                	ld	s4,152(sp)
    80006a1a:	7a8a                	ld	s5,160(sp)
    80006a1c:	7b2a                	ld	s6,168(sp)
    80006a1e:	7bca                	ld	s7,176(sp)
    80006a20:	7c6a                	ld	s8,184(sp)
    80006a22:	6c8e                	ld	s9,192(sp)
    80006a24:	6d2e                	ld	s10,200(sp)
    80006a26:	6dce                	ld	s11,208(sp)
    80006a28:	6e6e                	ld	t3,216(sp)
    80006a2a:	7e8e                	ld	t4,224(sp)
    80006a2c:	7f2e                	ld	t5,232(sp)
    80006a2e:	7fce                	ld	t6,240(sp)
    80006a30:	6111                	addi	sp,sp,256
    80006a32:	10200073          	sret
    80006a36:	00000013          	nop
    80006a3a:	00000013          	nop
    80006a3e:	0001                	nop

0000000080006a40 <timervec>:
    80006a40:	34051573          	csrrw	a0,mscratch,a0
    80006a44:	e10c                	sd	a1,0(a0)
    80006a46:	e510                	sd	a2,8(a0)
    80006a48:	e914                	sd	a3,16(a0)
    80006a4a:	6d0c                	ld	a1,24(a0)
    80006a4c:	7110                	ld	a2,32(a0)
    80006a4e:	6194                	ld	a3,0(a1)
    80006a50:	96b2                	add	a3,a3,a2
    80006a52:	e194                	sd	a3,0(a1)
    80006a54:	4589                	li	a1,2
    80006a56:	14459073          	csrw	sip,a1
    80006a5a:	6914                	ld	a3,16(a0)
    80006a5c:	6510                	ld	a2,8(a0)
    80006a5e:	610c                	ld	a1,0(a0)
    80006a60:	34051573          	csrrw	a0,mscratch,a0
    80006a64:	30200073          	mret
	...

0000000080006a6a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006a6a:	1141                	addi	sp,sp,-16
    80006a6c:	e422                	sd	s0,8(sp)
    80006a6e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006a70:	0c0007b7          	lui	a5,0xc000
    80006a74:	4705                	li	a4,1
    80006a76:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006a78:	c3d8                	sw	a4,4(a5)
}
    80006a7a:	6422                	ld	s0,8(sp)
    80006a7c:	0141                	addi	sp,sp,16
    80006a7e:	8082                	ret

0000000080006a80 <plicinithart>:

void
plicinithart(void)
{
    80006a80:	1141                	addi	sp,sp,-16
    80006a82:	e406                	sd	ra,8(sp)
    80006a84:	e022                	sd	s0,0(sp)
    80006a86:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006a88:	ffffb097          	auipc	ra,0xffffb
    80006a8c:	0c2080e7          	jalr	194(ra) # 80001b4a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006a90:	0085171b          	slliw	a4,a0,0x8
    80006a94:	0c0027b7          	lui	a5,0xc002
    80006a98:	97ba                	add	a5,a5,a4
    80006a9a:	40200713          	li	a4,1026
    80006a9e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006aa2:	00d5151b          	slliw	a0,a0,0xd
    80006aa6:	0c2017b7          	lui	a5,0xc201
    80006aaa:	953e                	add	a0,a0,a5
    80006aac:	00052023          	sw	zero,0(a0)
}
    80006ab0:	60a2                	ld	ra,8(sp)
    80006ab2:	6402                	ld	s0,0(sp)
    80006ab4:	0141                	addi	sp,sp,16
    80006ab6:	8082                	ret

0000000080006ab8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006ab8:	1141                	addi	sp,sp,-16
    80006aba:	e406                	sd	ra,8(sp)
    80006abc:	e022                	sd	s0,0(sp)
    80006abe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006ac0:	ffffb097          	auipc	ra,0xffffb
    80006ac4:	08a080e7          	jalr	138(ra) # 80001b4a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006ac8:	00d5179b          	slliw	a5,a0,0xd
    80006acc:	0c201537          	lui	a0,0xc201
    80006ad0:	953e                	add	a0,a0,a5
  return irq;
}
    80006ad2:	4148                	lw	a0,4(a0)
    80006ad4:	60a2                	ld	ra,8(sp)
    80006ad6:	6402                	ld	s0,0(sp)
    80006ad8:	0141                	addi	sp,sp,16
    80006ada:	8082                	ret

0000000080006adc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006adc:	1101                	addi	sp,sp,-32
    80006ade:	ec06                	sd	ra,24(sp)
    80006ae0:	e822                	sd	s0,16(sp)
    80006ae2:	e426                	sd	s1,8(sp)
    80006ae4:	1000                	addi	s0,sp,32
    80006ae6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006ae8:	ffffb097          	auipc	ra,0xffffb
    80006aec:	062080e7          	jalr	98(ra) # 80001b4a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006af0:	00d5151b          	slliw	a0,a0,0xd
    80006af4:	0c2017b7          	lui	a5,0xc201
    80006af8:	97aa                	add	a5,a5,a0
    80006afa:	c3c4                	sw	s1,4(a5)
}
    80006afc:	60e2                	ld	ra,24(sp)
    80006afe:	6442                	ld	s0,16(sp)
    80006b00:	64a2                	ld	s1,8(sp)
    80006b02:	6105                	addi	sp,sp,32
    80006b04:	8082                	ret

0000000080006b06 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006b06:	1141                	addi	sp,sp,-16
    80006b08:	e406                	sd	ra,8(sp)
    80006b0a:	e022                	sd	s0,0(sp)
    80006b0c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006b0e:	479d                	li	a5,7
    80006b10:	06a7c963          	blt	a5,a0,80006b82 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006b14:	00025797          	auipc	a5,0x25
    80006b18:	4ec78793          	addi	a5,a5,1260 # 8002c000 <disk>
    80006b1c:	00a78733          	add	a4,a5,a0
    80006b20:	6789                	lui	a5,0x2
    80006b22:	97ba                	add	a5,a5,a4
    80006b24:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006b28:	e7ad                	bnez	a5,80006b92 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006b2a:	00451793          	slli	a5,a0,0x4
    80006b2e:	00027717          	auipc	a4,0x27
    80006b32:	4d270713          	addi	a4,a4,1234 # 8002e000 <disk+0x2000>
    80006b36:	6314                	ld	a3,0(a4)
    80006b38:	96be                	add	a3,a3,a5
    80006b3a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006b3e:	6314                	ld	a3,0(a4)
    80006b40:	96be                	add	a3,a3,a5
    80006b42:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006b46:	6314                	ld	a3,0(a4)
    80006b48:	96be                	add	a3,a3,a5
    80006b4a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006b4e:	6318                	ld	a4,0(a4)
    80006b50:	97ba                	add	a5,a5,a4
    80006b52:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006b56:	00025797          	auipc	a5,0x25
    80006b5a:	4aa78793          	addi	a5,a5,1194 # 8002c000 <disk>
    80006b5e:	97aa                	add	a5,a5,a0
    80006b60:	6509                	lui	a0,0x2
    80006b62:	953e                	add	a0,a0,a5
    80006b64:	4785                	li	a5,1
    80006b66:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006b6a:	00027517          	auipc	a0,0x27
    80006b6e:	4ae50513          	addi	a0,a0,1198 # 8002e018 <disk+0x2018>
    80006b72:	ffffb097          	auipc	ra,0xffffb
    80006b76:	728080e7          	jalr	1832(ra) # 8000229a <wakeup>
}
    80006b7a:	60a2                	ld	ra,8(sp)
    80006b7c:	6402                	ld	s0,0(sp)
    80006b7e:	0141                	addi	sp,sp,16
    80006b80:	8082                	ret
    panic("free_desc 1");
    80006b82:	00003517          	auipc	a0,0x3
    80006b86:	05650513          	addi	a0,a0,86 # 80009bd8 <syscalls+0x358>
    80006b8a:	ffffa097          	auipc	ra,0xffffa
    80006b8e:	9a0080e7          	jalr	-1632(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006b92:	00003517          	auipc	a0,0x3
    80006b96:	05650513          	addi	a0,a0,86 # 80009be8 <syscalls+0x368>
    80006b9a:	ffffa097          	auipc	ra,0xffffa
    80006b9e:	990080e7          	jalr	-1648(ra) # 8000052a <panic>

0000000080006ba2 <virtio_disk_init>:
{
    80006ba2:	1101                	addi	sp,sp,-32
    80006ba4:	ec06                	sd	ra,24(sp)
    80006ba6:	e822                	sd	s0,16(sp)
    80006ba8:	e426                	sd	s1,8(sp)
    80006baa:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006bac:	00003597          	auipc	a1,0x3
    80006bb0:	04c58593          	addi	a1,a1,76 # 80009bf8 <syscalls+0x378>
    80006bb4:	00027517          	auipc	a0,0x27
    80006bb8:	57450513          	addi	a0,a0,1396 # 8002e128 <disk+0x2128>
    80006bbc:	ffffa097          	auipc	ra,0xffffa
    80006bc0:	f76080e7          	jalr	-138(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006bc4:	100017b7          	lui	a5,0x10001
    80006bc8:	4398                	lw	a4,0(a5)
    80006bca:	2701                	sext.w	a4,a4
    80006bcc:	747277b7          	lui	a5,0x74727
    80006bd0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006bd4:	0ef71163          	bne	a4,a5,80006cb6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006bd8:	100017b7          	lui	a5,0x10001
    80006bdc:	43dc                	lw	a5,4(a5)
    80006bde:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006be0:	4705                	li	a4,1
    80006be2:	0ce79a63          	bne	a5,a4,80006cb6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006be6:	100017b7          	lui	a5,0x10001
    80006bea:	479c                	lw	a5,8(a5)
    80006bec:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006bee:	4709                	li	a4,2
    80006bf0:	0ce79363          	bne	a5,a4,80006cb6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006bf4:	100017b7          	lui	a5,0x10001
    80006bf8:	47d8                	lw	a4,12(a5)
    80006bfa:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006bfc:	554d47b7          	lui	a5,0x554d4
    80006c00:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006c04:	0af71963          	bne	a4,a5,80006cb6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c08:	100017b7          	lui	a5,0x10001
    80006c0c:	4705                	li	a4,1
    80006c0e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c10:	470d                	li	a4,3
    80006c12:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006c14:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006c16:	c7ffe737          	lui	a4,0xc7ffe
    80006c1a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fcf75f>
    80006c1e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006c20:	2701                	sext.w	a4,a4
    80006c22:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c24:	472d                	li	a4,11
    80006c26:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c28:	473d                	li	a4,15
    80006c2a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006c2c:	6705                	lui	a4,0x1
    80006c2e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006c30:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006c34:	5bdc                	lw	a5,52(a5)
    80006c36:	2781                	sext.w	a5,a5
  if(max == 0)
    80006c38:	c7d9                	beqz	a5,80006cc6 <virtio_disk_init+0x124>
  if(max < NUM)
    80006c3a:	471d                	li	a4,7
    80006c3c:	08f77d63          	bgeu	a4,a5,80006cd6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006c40:	100014b7          	lui	s1,0x10001
    80006c44:	47a1                	li	a5,8
    80006c46:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006c48:	6609                	lui	a2,0x2
    80006c4a:	4581                	li	a1,0
    80006c4c:	00025517          	auipc	a0,0x25
    80006c50:	3b450513          	addi	a0,a0,948 # 8002c000 <disk>
    80006c54:	ffffa097          	auipc	ra,0xffffa
    80006c58:	06a080e7          	jalr	106(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006c5c:	00025717          	auipc	a4,0x25
    80006c60:	3a470713          	addi	a4,a4,932 # 8002c000 <disk>
    80006c64:	00c75793          	srli	a5,a4,0xc
    80006c68:	2781                	sext.w	a5,a5
    80006c6a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006c6c:	00027797          	auipc	a5,0x27
    80006c70:	39478793          	addi	a5,a5,916 # 8002e000 <disk+0x2000>
    80006c74:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006c76:	00025717          	auipc	a4,0x25
    80006c7a:	40a70713          	addi	a4,a4,1034 # 8002c080 <disk+0x80>
    80006c7e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006c80:	00026717          	auipc	a4,0x26
    80006c84:	38070713          	addi	a4,a4,896 # 8002d000 <disk+0x1000>
    80006c88:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006c8a:	4705                	li	a4,1
    80006c8c:	00e78c23          	sb	a4,24(a5)
    80006c90:	00e78ca3          	sb	a4,25(a5)
    80006c94:	00e78d23          	sb	a4,26(a5)
    80006c98:	00e78da3          	sb	a4,27(a5)
    80006c9c:	00e78e23          	sb	a4,28(a5)
    80006ca0:	00e78ea3          	sb	a4,29(a5)
    80006ca4:	00e78f23          	sb	a4,30(a5)
    80006ca8:	00e78fa3          	sb	a4,31(a5)
}
    80006cac:	60e2                	ld	ra,24(sp)
    80006cae:	6442                	ld	s0,16(sp)
    80006cb0:	64a2                	ld	s1,8(sp)
    80006cb2:	6105                	addi	sp,sp,32
    80006cb4:	8082                	ret
    panic("could not find virtio disk");
    80006cb6:	00003517          	auipc	a0,0x3
    80006cba:	f5250513          	addi	a0,a0,-174 # 80009c08 <syscalls+0x388>
    80006cbe:	ffffa097          	auipc	ra,0xffffa
    80006cc2:	86c080e7          	jalr	-1940(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006cc6:	00003517          	auipc	a0,0x3
    80006cca:	f6250513          	addi	a0,a0,-158 # 80009c28 <syscalls+0x3a8>
    80006cce:	ffffa097          	auipc	ra,0xffffa
    80006cd2:	85c080e7          	jalr	-1956(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006cd6:	00003517          	auipc	a0,0x3
    80006cda:	f7250513          	addi	a0,a0,-142 # 80009c48 <syscalls+0x3c8>
    80006cde:	ffffa097          	auipc	ra,0xffffa
    80006ce2:	84c080e7          	jalr	-1972(ra) # 8000052a <panic>

0000000080006ce6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006ce6:	7119                	addi	sp,sp,-128
    80006ce8:	fc86                	sd	ra,120(sp)
    80006cea:	f8a2                	sd	s0,112(sp)
    80006cec:	f4a6                	sd	s1,104(sp)
    80006cee:	f0ca                	sd	s2,96(sp)
    80006cf0:	ecce                	sd	s3,88(sp)
    80006cf2:	e8d2                	sd	s4,80(sp)
    80006cf4:	e4d6                	sd	s5,72(sp)
    80006cf6:	e0da                	sd	s6,64(sp)
    80006cf8:	fc5e                	sd	s7,56(sp)
    80006cfa:	f862                	sd	s8,48(sp)
    80006cfc:	f466                	sd	s9,40(sp)
    80006cfe:	f06a                	sd	s10,32(sp)
    80006d00:	ec6e                	sd	s11,24(sp)
    80006d02:	0100                	addi	s0,sp,128
    80006d04:	8aaa                	mv	s5,a0
    80006d06:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006d08:	00c52c83          	lw	s9,12(a0)
    80006d0c:	001c9c9b          	slliw	s9,s9,0x1
    80006d10:	1c82                	slli	s9,s9,0x20
    80006d12:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006d16:	00027517          	auipc	a0,0x27
    80006d1a:	41250513          	addi	a0,a0,1042 # 8002e128 <disk+0x2128>
    80006d1e:	ffffa097          	auipc	ra,0xffffa
    80006d22:	ea4080e7          	jalr	-348(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006d26:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006d28:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006d2a:	00025c17          	auipc	s8,0x25
    80006d2e:	2d6c0c13          	addi	s8,s8,726 # 8002c000 <disk>
    80006d32:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006d34:	4b0d                	li	s6,3
    80006d36:	a0ad                	j	80006da0 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006d38:	00fc0733          	add	a4,s8,a5
    80006d3c:	975e                	add	a4,a4,s7
    80006d3e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006d42:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006d44:	0207c563          	bltz	a5,80006d6e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006d48:	2905                	addiw	s2,s2,1
    80006d4a:	0611                	addi	a2,a2,4
    80006d4c:	19690d63          	beq	s2,s6,80006ee6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006d50:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006d52:	00027717          	auipc	a4,0x27
    80006d56:	2c670713          	addi	a4,a4,710 # 8002e018 <disk+0x2018>
    80006d5a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006d5c:	00074683          	lbu	a3,0(a4)
    80006d60:	fee1                	bnez	a3,80006d38 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006d62:	2785                	addiw	a5,a5,1
    80006d64:	0705                	addi	a4,a4,1
    80006d66:	fe979be3          	bne	a5,s1,80006d5c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006d6a:	57fd                	li	a5,-1
    80006d6c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006d6e:	01205d63          	blez	s2,80006d88 <virtio_disk_rw+0xa2>
    80006d72:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006d74:	000a2503          	lw	a0,0(s4)
    80006d78:	00000097          	auipc	ra,0x0
    80006d7c:	d8e080e7          	jalr	-626(ra) # 80006b06 <free_desc>
      for(int j = 0; j < i; j++)
    80006d80:	2d85                	addiw	s11,s11,1
    80006d82:	0a11                	addi	s4,s4,4
    80006d84:	ffb918e3          	bne	s2,s11,80006d74 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006d88:	00027597          	auipc	a1,0x27
    80006d8c:	3a058593          	addi	a1,a1,928 # 8002e128 <disk+0x2128>
    80006d90:	00027517          	auipc	a0,0x27
    80006d94:	28850513          	addi	a0,a0,648 # 8002e018 <disk+0x2018>
    80006d98:	ffffb097          	auipc	ra,0xffffb
    80006d9c:	376080e7          	jalr	886(ra) # 8000210e <sleep>
  for(int i = 0; i < 3; i++){
    80006da0:	f8040a13          	addi	s4,s0,-128
{
    80006da4:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006da6:	894e                	mv	s2,s3
    80006da8:	b765                	j	80006d50 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006daa:	00027697          	auipc	a3,0x27
    80006dae:	2566b683          	ld	a3,598(a3) # 8002e000 <disk+0x2000>
    80006db2:	96ba                	add	a3,a3,a4
    80006db4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006db8:	00025817          	auipc	a6,0x25
    80006dbc:	24880813          	addi	a6,a6,584 # 8002c000 <disk>
    80006dc0:	00027697          	auipc	a3,0x27
    80006dc4:	24068693          	addi	a3,a3,576 # 8002e000 <disk+0x2000>
    80006dc8:	6290                	ld	a2,0(a3)
    80006dca:	963a                	add	a2,a2,a4
    80006dcc:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006dd0:	0015e593          	ori	a1,a1,1
    80006dd4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006dd8:	f8842603          	lw	a2,-120(s0)
    80006ddc:	628c                	ld	a1,0(a3)
    80006dde:	972e                	add	a4,a4,a1
    80006de0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006de4:	20050593          	addi	a1,a0,512
    80006de8:	0592                	slli	a1,a1,0x4
    80006dea:	95c2                	add	a1,a1,a6
    80006dec:	577d                	li	a4,-1
    80006dee:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006df2:	00461713          	slli	a4,a2,0x4
    80006df6:	6290                	ld	a2,0(a3)
    80006df8:	963a                	add	a2,a2,a4
    80006dfa:	03078793          	addi	a5,a5,48
    80006dfe:	97c2                	add	a5,a5,a6
    80006e00:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006e02:	629c                	ld	a5,0(a3)
    80006e04:	97ba                	add	a5,a5,a4
    80006e06:	4605                	li	a2,1
    80006e08:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006e0a:	629c                	ld	a5,0(a3)
    80006e0c:	97ba                	add	a5,a5,a4
    80006e0e:	4809                	li	a6,2
    80006e10:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006e14:	629c                	ld	a5,0(a3)
    80006e16:	973e                	add	a4,a4,a5
    80006e18:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006e1c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006e20:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006e24:	6698                	ld	a4,8(a3)
    80006e26:	00275783          	lhu	a5,2(a4)
    80006e2a:	8b9d                	andi	a5,a5,7
    80006e2c:	0786                	slli	a5,a5,0x1
    80006e2e:	97ba                	add	a5,a5,a4
    80006e30:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006e34:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006e38:	6698                	ld	a4,8(a3)
    80006e3a:	00275783          	lhu	a5,2(a4)
    80006e3e:	2785                	addiw	a5,a5,1
    80006e40:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006e44:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006e48:	100017b7          	lui	a5,0x10001
    80006e4c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006e50:	004aa783          	lw	a5,4(s5)
    80006e54:	02c79163          	bne	a5,a2,80006e76 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006e58:	00027917          	auipc	s2,0x27
    80006e5c:	2d090913          	addi	s2,s2,720 # 8002e128 <disk+0x2128>
  while(b->disk == 1) {
    80006e60:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006e62:	85ca                	mv	a1,s2
    80006e64:	8556                	mv	a0,s5
    80006e66:	ffffb097          	auipc	ra,0xffffb
    80006e6a:	2a8080e7          	jalr	680(ra) # 8000210e <sleep>
  while(b->disk == 1) {
    80006e6e:	004aa783          	lw	a5,4(s5)
    80006e72:	fe9788e3          	beq	a5,s1,80006e62 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006e76:	f8042903          	lw	s2,-128(s0)
    80006e7a:	20090793          	addi	a5,s2,512
    80006e7e:	00479713          	slli	a4,a5,0x4
    80006e82:	00025797          	auipc	a5,0x25
    80006e86:	17e78793          	addi	a5,a5,382 # 8002c000 <disk>
    80006e8a:	97ba                	add	a5,a5,a4
    80006e8c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006e90:	00027997          	auipc	s3,0x27
    80006e94:	17098993          	addi	s3,s3,368 # 8002e000 <disk+0x2000>
    80006e98:	00491713          	slli	a4,s2,0x4
    80006e9c:	0009b783          	ld	a5,0(s3)
    80006ea0:	97ba                	add	a5,a5,a4
    80006ea2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006ea6:	854a                	mv	a0,s2
    80006ea8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006eac:	00000097          	auipc	ra,0x0
    80006eb0:	c5a080e7          	jalr	-934(ra) # 80006b06 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006eb4:	8885                	andi	s1,s1,1
    80006eb6:	f0ed                	bnez	s1,80006e98 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006eb8:	00027517          	auipc	a0,0x27
    80006ebc:	27050513          	addi	a0,a0,624 # 8002e128 <disk+0x2128>
    80006ec0:	ffffa097          	auipc	ra,0xffffa
    80006ec4:	db6080e7          	jalr	-586(ra) # 80000c76 <release>
}
    80006ec8:	70e6                	ld	ra,120(sp)
    80006eca:	7446                	ld	s0,112(sp)
    80006ecc:	74a6                	ld	s1,104(sp)
    80006ece:	7906                	ld	s2,96(sp)
    80006ed0:	69e6                	ld	s3,88(sp)
    80006ed2:	6a46                	ld	s4,80(sp)
    80006ed4:	6aa6                	ld	s5,72(sp)
    80006ed6:	6b06                	ld	s6,64(sp)
    80006ed8:	7be2                	ld	s7,56(sp)
    80006eda:	7c42                	ld	s8,48(sp)
    80006edc:	7ca2                	ld	s9,40(sp)
    80006ede:	7d02                	ld	s10,32(sp)
    80006ee0:	6de2                	ld	s11,24(sp)
    80006ee2:	6109                	addi	sp,sp,128
    80006ee4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006ee6:	f8042503          	lw	a0,-128(s0)
    80006eea:	20050793          	addi	a5,a0,512
    80006eee:	0792                	slli	a5,a5,0x4
  if(write)
    80006ef0:	00025817          	auipc	a6,0x25
    80006ef4:	11080813          	addi	a6,a6,272 # 8002c000 <disk>
    80006ef8:	00f80733          	add	a4,a6,a5
    80006efc:	01a036b3          	snez	a3,s10
    80006f00:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006f04:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006f08:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006f0c:	7679                	lui	a2,0xffffe
    80006f0e:	963e                	add	a2,a2,a5
    80006f10:	00027697          	auipc	a3,0x27
    80006f14:	0f068693          	addi	a3,a3,240 # 8002e000 <disk+0x2000>
    80006f18:	6298                	ld	a4,0(a3)
    80006f1a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006f1c:	0a878593          	addi	a1,a5,168
    80006f20:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006f22:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006f24:	6298                	ld	a4,0(a3)
    80006f26:	9732                	add	a4,a4,a2
    80006f28:	45c1                	li	a1,16
    80006f2a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006f2c:	6298                	ld	a4,0(a3)
    80006f2e:	9732                	add	a4,a4,a2
    80006f30:	4585                	li	a1,1
    80006f32:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006f36:	f8442703          	lw	a4,-124(s0)
    80006f3a:	628c                	ld	a1,0(a3)
    80006f3c:	962e                	add	a2,a2,a1
    80006f3e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffcf00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006f42:	0712                	slli	a4,a4,0x4
    80006f44:	6290                	ld	a2,0(a3)
    80006f46:	963a                	add	a2,a2,a4
    80006f48:	058a8593          	addi	a1,s5,88
    80006f4c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006f4e:	6294                	ld	a3,0(a3)
    80006f50:	96ba                	add	a3,a3,a4
    80006f52:	40000613          	li	a2,1024
    80006f56:	c690                	sw	a2,8(a3)
  if(write)
    80006f58:	e40d19e3          	bnez	s10,80006daa <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006f5c:	00027697          	auipc	a3,0x27
    80006f60:	0a46b683          	ld	a3,164(a3) # 8002e000 <disk+0x2000>
    80006f64:	96ba                	add	a3,a3,a4
    80006f66:	4609                	li	a2,2
    80006f68:	00c69623          	sh	a2,12(a3)
    80006f6c:	b5b1                	j	80006db8 <virtio_disk_rw+0xd2>

0000000080006f6e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006f6e:	1101                	addi	sp,sp,-32
    80006f70:	ec06                	sd	ra,24(sp)
    80006f72:	e822                	sd	s0,16(sp)
    80006f74:	e426                	sd	s1,8(sp)
    80006f76:	e04a                	sd	s2,0(sp)
    80006f78:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006f7a:	00027517          	auipc	a0,0x27
    80006f7e:	1ae50513          	addi	a0,a0,430 # 8002e128 <disk+0x2128>
    80006f82:	ffffa097          	auipc	ra,0xffffa
    80006f86:	c40080e7          	jalr	-960(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006f8a:	10001737          	lui	a4,0x10001
    80006f8e:	533c                	lw	a5,96(a4)
    80006f90:	8b8d                	andi	a5,a5,3
    80006f92:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006f94:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006f98:	00027797          	auipc	a5,0x27
    80006f9c:	06878793          	addi	a5,a5,104 # 8002e000 <disk+0x2000>
    80006fa0:	6b94                	ld	a3,16(a5)
    80006fa2:	0207d703          	lhu	a4,32(a5)
    80006fa6:	0026d783          	lhu	a5,2(a3)
    80006faa:	06f70163          	beq	a4,a5,8000700c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006fae:	00025917          	auipc	s2,0x25
    80006fb2:	05290913          	addi	s2,s2,82 # 8002c000 <disk>
    80006fb6:	00027497          	auipc	s1,0x27
    80006fba:	04a48493          	addi	s1,s1,74 # 8002e000 <disk+0x2000>
    __sync_synchronize();
    80006fbe:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006fc2:	6898                	ld	a4,16(s1)
    80006fc4:	0204d783          	lhu	a5,32(s1)
    80006fc8:	8b9d                	andi	a5,a5,7
    80006fca:	078e                	slli	a5,a5,0x3
    80006fcc:	97ba                	add	a5,a5,a4
    80006fce:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006fd0:	20078713          	addi	a4,a5,512
    80006fd4:	0712                	slli	a4,a4,0x4
    80006fd6:	974a                	add	a4,a4,s2
    80006fd8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80006fdc:	e731                	bnez	a4,80007028 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006fde:	20078793          	addi	a5,a5,512
    80006fe2:	0792                	slli	a5,a5,0x4
    80006fe4:	97ca                	add	a5,a5,s2
    80006fe6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006fe8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006fec:	ffffb097          	auipc	ra,0xffffb
    80006ff0:	2ae080e7          	jalr	686(ra) # 8000229a <wakeup>

    disk.used_idx += 1;
    80006ff4:	0204d783          	lhu	a5,32(s1)
    80006ff8:	2785                	addiw	a5,a5,1
    80006ffa:	17c2                	slli	a5,a5,0x30
    80006ffc:	93c1                	srli	a5,a5,0x30
    80006ffe:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007002:	6898                	ld	a4,16(s1)
    80007004:	00275703          	lhu	a4,2(a4)
    80007008:	faf71be3          	bne	a4,a5,80006fbe <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000700c:	00027517          	auipc	a0,0x27
    80007010:	11c50513          	addi	a0,a0,284 # 8002e128 <disk+0x2128>
    80007014:	ffffa097          	auipc	ra,0xffffa
    80007018:	c62080e7          	jalr	-926(ra) # 80000c76 <release>
}
    8000701c:	60e2                	ld	ra,24(sp)
    8000701e:	6442                	ld	s0,16(sp)
    80007020:	64a2                	ld	s1,8(sp)
    80007022:	6902                	ld	s2,0(sp)
    80007024:	6105                	addi	sp,sp,32
    80007026:	8082                	ret
      panic("virtio_disk_intr status");
    80007028:	00003517          	auipc	a0,0x3
    8000702c:	c4050513          	addi	a0,a0,-960 # 80009c68 <syscalls+0x3e8>
    80007030:	ffff9097          	auipc	ra,0xffff9
    80007034:	4fa080e7          	jalr	1274(ra) # 8000052a <panic>
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
