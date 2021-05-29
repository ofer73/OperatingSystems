
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
    80000068:	a9c78793          	addi	a5,a5,-1380 # 80006b00 <timervec>
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
    80000122:	512080e7          	jalr	1298(ra) # 80002630 <either_copyin>
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
    800001b6:	b82080e7          	jalr	-1150(ra) # 80001d34 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	06a080e7          	jalr	106(ra) # 8000222c <sleep>
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
    80000202:	3dc080e7          	jalr	988(ra) # 800025da <either_copyout>
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
    800002e2:	3a8080e7          	jalr	936(ra) # 80002686 <procdump>
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
    80000436:	f86080e7          	jalr	-122(ra) # 800023b8 <wakeup>
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
    8000055c:	0a850513          	addi	a0,a0,168 # 80009600 <digits+0x5c0>
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
    80000882:	b3a080e7          	jalr	-1222(ra) # 800023b8 <wakeup>
    
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
    8000090e:	922080e7          	jalr	-1758(ra) # 8000222c <sleep>
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
    80000b60:	1bc080e7          	jalr	444(ra) # 80001d18 <mycpu>
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
    80000b92:	18a080e7          	jalr	394(ra) # 80001d18 <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	17e080e7          	jalr	382(ra) # 80001d18 <mycpu>
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
    80000bb6:	166080e7          	jalr	358(ra) # 80001d18 <mycpu>
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
    80000bf6:	126080e7          	jalr	294(ra) # 80001d18 <mycpu>
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
    80000c22:	0fa080e7          	jalr	250(ra) # 80001d18 <mycpu>
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
    80000e78:	e94080e7          	jalr	-364(ra) # 80001d08 <cpuid>
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
    80000e94:	e78080e7          	jalr	-392(ra) # 80001d08 <cpuid>
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
    80000eb6:	0ce080e7          	jalr	206(ra) # 80002f80 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00006097          	auipc	ra,0x6
    80000ebe:	c86080e7          	jalr	-890(ra) # 80006b40 <plicinithart>
  }

  scheduler();        
    80000ec2:	00002097          	auipc	ra,0x2
    80000ec6:	dec080e7          	jalr	-532(ra) # 80002cae <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00008517          	auipc	a0,0x8
    80000ede:	72650513          	addi	a0,a0,1830 # 80009600 <digits+0x5c0>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00008517          	auipc	a0,0x8
    80000eee:	1b650513          	addi	a0,a0,438 # 800090a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00008517          	auipc	a0,0x8
    80000efe:	70650513          	addi	a0,a0,1798 # 80009600 <digits+0x5c0>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    kinit();         // physical page allocator
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	b8c080e7          	jalr	-1140(ra) # 80000a96 <kinit>
    kvminit();       // create kernel page table
    80000f12:	00000097          	auipc	ra,0x0
    80000f16:	324080e7          	jalr	804(ra) # 80001236 <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	068080e7          	jalr	104(ra) # 80000f82 <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	d36080e7          	jalr	-714(ra) # 80001c58 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	02e080e7          	jalr	46(ra) # 80002f58 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	04e080e7          	jalr	78(ra) # 80002f80 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00006097          	auipc	ra,0x6
    80000f3e:	bf0080e7          	jalr	-1040(ra) # 80006b2a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00006097          	auipc	ra,0x6
    80000f46:	bfe080e7          	jalr	-1026(ra) # 80006b40 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00003097          	auipc	ra,0x3
    80000f4e:	87e080e7          	jalr	-1922(ra) # 800037c8 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	f10080e7          	jalr	-240(ra) # 80003e62 <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	1d0080e7          	jalr	464(ra) # 8000512a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00006097          	auipc	ra,0x6
    80000f66:	d00080e7          	jalr	-768(ra) # 80006c62 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	0ba080e7          	jalr	186(ra) # 80002024 <userinit>
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
    *pte &= ~PTE_V;  // page table entry now invalid
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
    80001070:	c51d                	beqz	a0,8000109e <walkaddr+0x52>
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
    *pte &= ~PTE_V;  // page table entry now invalid
    80001094:	9af9                	andi	a3,a3,-2
    *pte |= PTE_PG; // paged out to secondary storage
    80001096:	2006e693          	ori	a3,a3,512
    8000109a:	e314                	sd	a3,0(a4)
    8000109c:	b7d5                	j	80001080 <walkaddr+0x34>
    return 0;
    8000109e:	4501                	li	a0,0
    800010a0:	b7c5                	j	80001080 <walkaddr+0x34>

00000000800010a2 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a2:	715d                	addi	sp,sp,-80
    800010a4:	e486                	sd	ra,72(sp)
    800010a6:	e0a2                	sd	s0,64(sp)
    800010a8:	fc26                	sd	s1,56(sp)
    800010aa:	f84a                	sd	s2,48(sp)
    800010ac:	f44e                	sd	s3,40(sp)
    800010ae:	f052                	sd	s4,32(sp)
    800010b0:	ec56                	sd	s5,24(sp)
    800010b2:	e85a                	sd	s6,16(sp)
    800010b4:	e45e                	sd	s7,8(sp)
    800010b6:	0880                	addi	s0,sp,80
    800010b8:	8aaa                	mv	s5,a0
    800010ba:	8b3a                	mv	s6,a4

  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010bc:	777d                	lui	a4,0xfffff
    800010be:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c2:	167d                	addi	a2,a2,-1
    800010c4:	00b609b3          	add	s3,a2,a1
    800010c8:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010cc:	893e                	mv	s2,a5
    800010ce:	40f68a33          	sub	s4,a3,a5
    if (*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    800010d2:	6b85                	lui	s7,0x1
    800010d4:	012a04b3          	add	s1,s4,s2
    if ((pte = walk(pagetable, a, 1)) == 0)
    800010d8:	4605                	li	a2,1
    800010da:	85ca                	mv	a1,s2
    800010dc:	8556                	mv	a0,s5
    800010de:	00000097          	auipc	ra,0x0
    800010e2:	ec8080e7          	jalr	-312(ra) # 80000fa6 <walk>
    800010e6:	c51d                	beqz	a0,80001114 <mappages+0x72>
    if (*pte & PTE_V)
    800010e8:	611c                	ld	a5,0(a0)
    800010ea:	8b85                	andi	a5,a5,1
    800010ec:	ef81                	bnez	a5,80001104 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ee:	80b1                	srli	s1,s1,0xc
    800010f0:	04aa                	slli	s1,s1,0xa
    800010f2:	0164e4b3          	or	s1,s1,s6
    800010f6:	0014e493          	ori	s1,s1,1
    800010fa:	e104                	sd	s1,0(a0)
    if (a == last)
    800010fc:	03390863          	beq	s2,s3,8000112c <mappages+0x8a>
    a += PGSIZE;
    80001100:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001102:	bfc9                	j	800010d4 <mappages+0x32>
      panic("remap");
    80001104:	00008517          	auipc	a0,0x8
    80001108:	fd450513          	addi	a0,a0,-44 # 800090d8 <digits+0x98>
    8000110c:	fffff097          	auipc	ra,0xfffff
    80001110:	41e080e7          	jalr	1054(ra) # 8000052a <panic>
      return -1;
    80001114:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001116:	60a6                	ld	ra,72(sp)
    80001118:	6406                	ld	s0,64(sp)
    8000111a:	74e2                	ld	s1,56(sp)
    8000111c:	7942                	ld	s2,48(sp)
    8000111e:	79a2                	ld	s3,40(sp)
    80001120:	7a02                	ld	s4,32(sp)
    80001122:	6ae2                	ld	s5,24(sp)
    80001124:	6b42                	ld	s6,16(sp)
    80001126:	6ba2                	ld	s7,8(sp)
    80001128:	6161                	addi	sp,sp,80
    8000112a:	8082                	ret
  return 0;
    8000112c:	4501                	li	a0,0
    8000112e:	b7e5                	j	80001116 <mappages+0x74>

0000000080001130 <kvmmap>:
{
    80001130:	1141                	addi	sp,sp,-16
    80001132:	e406                	sd	ra,8(sp)
    80001134:	e022                	sd	s0,0(sp)
    80001136:	0800                	addi	s0,sp,16
    80001138:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000113a:	86b2                	mv	a3,a2
    8000113c:	863e                	mv	a2,a5
    8000113e:	00000097          	auipc	ra,0x0
    80001142:	f64080e7          	jalr	-156(ra) # 800010a2 <mappages>
    80001146:	e509                	bnez	a0,80001150 <kvmmap+0x20>
}
    80001148:	60a2                	ld	ra,8(sp)
    8000114a:	6402                	ld	s0,0(sp)
    8000114c:	0141                	addi	sp,sp,16
    8000114e:	8082                	ret
    panic("kvmmap");
    80001150:	00008517          	auipc	a0,0x8
    80001154:	f9050513          	addi	a0,a0,-112 # 800090e0 <digits+0xa0>
    80001158:	fffff097          	auipc	ra,0xfffff
    8000115c:	3d2080e7          	jalr	978(ra) # 8000052a <panic>

0000000080001160 <kvmmake>:
{
    80001160:	1101                	addi	sp,sp,-32
    80001162:	ec06                	sd	ra,24(sp)
    80001164:	e822                	sd	s0,16(sp)
    80001166:	e426                	sd	s1,8(sp)
    80001168:	e04a                	sd	s2,0(sp)
    8000116a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    8000116c:	00000097          	auipc	ra,0x0
    80001170:	966080e7          	jalr	-1690(ra) # 80000ad2 <kalloc>
    80001174:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001176:	6605                	lui	a2,0x1
    80001178:	4581                	li	a1,0
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	b44080e7          	jalr	-1212(ra) # 80000cbe <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001182:	4719                	li	a4,6
    80001184:	6685                	lui	a3,0x1
    80001186:	10000637          	lui	a2,0x10000
    8000118a:	100005b7          	lui	a1,0x10000
    8000118e:	8526                	mv	a0,s1
    80001190:	00000097          	auipc	ra,0x0
    80001194:	fa0080e7          	jalr	-96(ra) # 80001130 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001198:	4719                	li	a4,6
    8000119a:	6685                	lui	a3,0x1
    8000119c:	10001637          	lui	a2,0x10001
    800011a0:	100015b7          	lui	a1,0x10001
    800011a4:	8526                	mv	a0,s1
    800011a6:	00000097          	auipc	ra,0x0
    800011aa:	f8a080e7          	jalr	-118(ra) # 80001130 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011ae:	4719                	li	a4,6
    800011b0:	004006b7          	lui	a3,0x400
    800011b4:	0c000637          	lui	a2,0xc000
    800011b8:	0c0005b7          	lui	a1,0xc000
    800011bc:	8526                	mv	a0,s1
    800011be:	00000097          	auipc	ra,0x0
    800011c2:	f72080e7          	jalr	-142(ra) # 80001130 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    800011c6:	00008917          	auipc	s2,0x8
    800011ca:	e3a90913          	addi	s2,s2,-454 # 80009000 <etext>
    800011ce:	4729                	li	a4,10
    800011d0:	80008697          	auipc	a3,0x80008
    800011d4:	e3068693          	addi	a3,a3,-464 # 9000 <_entry-0x7fff7000>
    800011d8:	4605                	li	a2,1
    800011da:	067e                	slli	a2,a2,0x1f
    800011dc:	85b2                	mv	a1,a2
    800011de:	8526                	mv	a0,s1
    800011e0:	00000097          	auipc	ra,0x0
    800011e4:	f50080e7          	jalr	-176(ra) # 80001130 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext, PTE_R | PTE_W);
    800011e8:	4719                	li	a4,6
    800011ea:	46c5                	li	a3,17
    800011ec:	06ee                	slli	a3,a3,0x1b
    800011ee:	412686b3          	sub	a3,a3,s2
    800011f2:	864a                	mv	a2,s2
    800011f4:	85ca                	mv	a1,s2
    800011f6:	8526                	mv	a0,s1
    800011f8:	00000097          	auipc	ra,0x0
    800011fc:	f38080e7          	jalr	-200(ra) # 80001130 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001200:	4729                	li	a4,10
    80001202:	6685                	lui	a3,0x1
    80001204:	00007617          	auipc	a2,0x7
    80001208:	dfc60613          	addi	a2,a2,-516 # 80008000 <_trampoline>
    8000120c:	040005b7          	lui	a1,0x4000
    80001210:	15fd                	addi	a1,a1,-1
    80001212:	05b2                	slli	a1,a1,0xc
    80001214:	8526                	mv	a0,s1
    80001216:	00000097          	auipc	ra,0x0
    8000121a:	f1a080e7          	jalr	-230(ra) # 80001130 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000121e:	8526                	mv	a0,s1
    80001220:	00001097          	auipc	ra,0x1
    80001224:	9a2080e7          	jalr	-1630(ra) # 80001bc2 <proc_mapstacks>
}
    80001228:	8526                	mv	a0,s1
    8000122a:	60e2                	ld	ra,24(sp)
    8000122c:	6442                	ld	s0,16(sp)
    8000122e:	64a2                	ld	s1,8(sp)
    80001230:	6902                	ld	s2,0(sp)
    80001232:	6105                	addi	sp,sp,32
    80001234:	8082                	ret

0000000080001236 <kvminit>:
{
    80001236:	1141                	addi	sp,sp,-16
    80001238:	e406                	sd	ra,8(sp)
    8000123a:	e022                	sd	s0,0(sp)
    8000123c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000123e:	00000097          	auipc	ra,0x0
    80001242:	f22080e7          	jalr	-222(ra) # 80001160 <kvmmake>
    80001246:	00009797          	auipc	a5,0x9
    8000124a:	dca7bd23          	sd	a0,-550(a5) # 8000a020 <kernel_pagetable>
}
    8000124e:	60a2                	ld	ra,8(sp)
    80001250:	6402                	ld	s0,0(sp)
    80001252:	0141                	addi	sp,sp,16
    80001254:	8082                	ret

0000000080001256 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001256:	1101                	addi	sp,sp,-32
    80001258:	ec06                	sd	ra,24(sp)
    8000125a:	e822                	sd	s0,16(sp)
    8000125c:	e426                	sd	s1,8(sp)
    8000125e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80001260:	00000097          	auipc	ra,0x0
    80001264:	872080e7          	jalr	-1934(ra) # 80000ad2 <kalloc>
    80001268:	84aa                	mv	s1,a0
  if (pagetable == 0)
    8000126a:	c519                	beqz	a0,80001278 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000126c:	6605                	lui	a2,0x1
    8000126e:	4581                	li	a1,0
    80001270:	00000097          	auipc	ra,0x0
    80001274:	a4e080e7          	jalr	-1458(ra) # 80000cbe <memset>
  return pagetable;
}
    80001278:	8526                	mv	a0,s1
    8000127a:	60e2                	ld	ra,24(sp)
    8000127c:	6442                	ld	s0,16(sp)
    8000127e:	64a2                	ld	s1,8(sp)
    80001280:	6105                	addi	sp,sp,32
    80001282:	8082                	ret

0000000080001284 <uvminit>:

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001284:	7179                	addi	sp,sp,-48
    80001286:	f406                	sd	ra,40(sp)
    80001288:	f022                	sd	s0,32(sp)
    8000128a:	ec26                	sd	s1,24(sp)
    8000128c:	e84a                	sd	s2,16(sp)
    8000128e:	e44e                	sd	s3,8(sp)
    80001290:	e052                	sd	s4,0(sp)
    80001292:	1800                	addi	s0,sp,48
  char *mem;

  if (sz >= PGSIZE)
    80001294:	6785                	lui	a5,0x1
    80001296:	04f67863          	bgeu	a2,a5,800012e6 <uvminit+0x62>
    8000129a:	8a2a                	mv	s4,a0
    8000129c:	89ae                	mv	s3,a1
    8000129e:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800012a0:	00000097          	auipc	ra,0x0
    800012a4:	832080e7          	jalr	-1998(ra) # 80000ad2 <kalloc>
    800012a8:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012aa:	6605                	lui	a2,0x1
    800012ac:	4581                	li	a1,0
    800012ae:	00000097          	auipc	ra,0x0
    800012b2:	a10080e7          	jalr	-1520(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W | PTE_R | PTE_X | PTE_U);
    800012b6:	4779                	li	a4,30
    800012b8:	86ca                	mv	a3,s2
    800012ba:	6605                	lui	a2,0x1
    800012bc:	4581                	li	a1,0
    800012be:	8552                	mv	a0,s4
    800012c0:	00000097          	auipc	ra,0x0
    800012c4:	de2080e7          	jalr	-542(ra) # 800010a2 <mappages>
  memmove(mem, src, sz);
    800012c8:	8626                	mv	a2,s1
    800012ca:	85ce                	mv	a1,s3
    800012cc:	854a                	mv	a0,s2
    800012ce:	00000097          	auipc	ra,0x0
    800012d2:	a4c080e7          	jalr	-1460(ra) # 80000d1a <memmove>
}
    800012d6:	70a2                	ld	ra,40(sp)
    800012d8:	7402                	ld	s0,32(sp)
    800012da:	64e2                	ld	s1,24(sp)
    800012dc:	6942                	ld	s2,16(sp)
    800012de:	69a2                	ld	s3,8(sp)
    800012e0:	6a02                	ld	s4,0(sp)
    800012e2:	6145                	addi	sp,sp,48
    800012e4:	8082                	ret
    panic("inituvm: more than a page");
    800012e6:	00008517          	auipc	a0,0x8
    800012ea:	e0250513          	addi	a0,a0,-510 # 800090e8 <digits+0xa8>
    800012ee:	fffff097          	auipc	ra,0xfffff
    800012f2:	23c080e7          	jalr	572(ra) # 8000052a <panic>

00000000800012f6 <freewalk>:
}

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void freewalk(pagetable_t pagetable)
{
    800012f6:	7179                	addi	sp,sp,-48
    800012f8:	f406                	sd	ra,40(sp)
    800012fa:	f022                	sd	s0,32(sp)
    800012fc:	ec26                	sd	s1,24(sp)
    800012fe:	e84a                	sd	s2,16(sp)
    80001300:	e44e                	sd	s3,8(sp)
    80001302:	e052                	sd	s4,0(sp)
    80001304:	1800                	addi	s0,sp,48
    80001306:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++)
    80001308:	84aa                	mv	s1,a0
    8000130a:	6905                	lui	s2,0x1
    8000130c:	992a                	add	s2,s2,a0
  {
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    8000130e:	4985                	li	s3,1
    80001310:	a821                	j	80001328 <freewalk+0x32>
    {
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001312:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001314:	0532                	slli	a0,a0,0xc
    80001316:	00000097          	auipc	ra,0x0
    8000131a:	fe0080e7          	jalr	-32(ra) # 800012f6 <freewalk>
      pagetable[i] = 0;
    8000131e:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++)
    80001322:	04a1                	addi	s1,s1,8
    80001324:	03248163          	beq	s1,s2,80001346 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001328:	6088                	ld	a0,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    8000132a:	00f57793          	andi	a5,a0,15
    8000132e:	ff3782e3          	beq	a5,s3,80001312 <freewalk+0x1c>
    }
    else if (pte & PTE_V)
    80001332:	8905                	andi	a0,a0,1
    80001334:	d57d                	beqz	a0,80001322 <freewalk+0x2c>
    {
      panic("freewalk: leaf");
    80001336:	00008517          	auipc	a0,0x8
    8000133a:	dd250513          	addi	a0,a0,-558 # 80009108 <digits+0xc8>
    8000133e:	fffff097          	auipc	ra,0xfffff
    80001342:	1ec080e7          	jalr	492(ra) # 8000052a <panic>
    }
  }
  kfree((void *)pagetable);
    80001346:	8552                	mv	a0,s4
    80001348:	fffff097          	auipc	ra,0xfffff
    8000134c:	68e080e7          	jalr	1678(ra) # 800009d6 <kfree>
}
    80001350:	70a2                	ld	ra,40(sp)
    80001352:	7402                	ld	s0,32(sp)
    80001354:	64e2                	ld	s1,24(sp)
    80001356:	6942                	ld	s2,16(sp)
    80001358:	69a2                	ld	s3,8(sp)
    8000135a:	6a02                	ld	s4,0(sp)
    8000135c:	6145                	addi	sp,sp,48
    8000135e:	8082                	ret

0000000080001360 <uvmclear>:
}

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void uvmclear(pagetable_t pagetable, uint64 va)
{
    80001360:	1141                	addi	sp,sp,-16
    80001362:	e406                	sd	ra,8(sp)
    80001364:	e022                	sd	s0,0(sp)
    80001366:	0800                	addi	s0,sp,16

  pte_t *pte;

  pte = walk(pagetable, va, 0);
    80001368:	4601                	li	a2,0
    8000136a:	00000097          	auipc	ra,0x0
    8000136e:	c3c080e7          	jalr	-964(ra) # 80000fa6 <walk>
  if (pte == 0)
    80001372:	c901                	beqz	a0,80001382 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001374:	611c                	ld	a5,0(a0)
    80001376:	9bbd                	andi	a5,a5,-17
    80001378:	e11c                	sd	a5,0(a0)
}
    8000137a:	60a2                	ld	ra,8(sp)
    8000137c:	6402                	ld	s0,0(sp)
    8000137e:	0141                	addi	sp,sp,16
    80001380:	8082                	ret
    panic("uvmclear");
    80001382:	00008517          	auipc	a0,0x8
    80001386:	d9650513          	addi	a0,a0,-618 # 80009118 <digits+0xd8>
    8000138a:	fffff097          	auipc	ra,0xfffff
    8000138e:	1a0080e7          	jalr	416(ra) # 8000052a <panic>

0000000080001392 <copyout>:
// Copy len bytes from src to virtual address dstva in a given page table.
// Return 0 on success, -1 on error.
int copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  while (len > 0)
    80001392:	caa5                	beqz	a3,80001402 <copyout+0x70>
{
    80001394:	715d                	addi	sp,sp,-80
    80001396:	e486                	sd	ra,72(sp)
    80001398:	e0a2                	sd	s0,64(sp)
    8000139a:	fc26                	sd	s1,56(sp)
    8000139c:	f84a                	sd	s2,48(sp)
    8000139e:	f44e                	sd	s3,40(sp)
    800013a0:	f052                	sd	s4,32(sp)
    800013a2:	ec56                	sd	s5,24(sp)
    800013a4:	e85a                	sd	s6,16(sp)
    800013a6:	e45e                	sd	s7,8(sp)
    800013a8:	e062                	sd	s8,0(sp)
    800013aa:	0880                	addi	s0,sp,80
    800013ac:	8b2a                	mv	s6,a0
    800013ae:	8c2e                	mv	s8,a1
    800013b0:	8a32                	mv	s4,a2
    800013b2:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(dstva);
    800013b4:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0, 0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800013b6:	6a85                	lui	s5,0x1
    800013b8:	a015                	j	800013dc <copyout+0x4a>
    if (n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800013ba:	9562                	add	a0,a0,s8
    800013bc:	0004861b          	sext.w	a2,s1
    800013c0:	85d2                	mv	a1,s4
    800013c2:	41250533          	sub	a0,a0,s2
    800013c6:	00000097          	auipc	ra,0x0
    800013ca:	954080e7          	jalr	-1708(ra) # 80000d1a <memmove>

    len -= n;
    800013ce:	409989b3          	sub	s3,s3,s1
    src += n;
    800013d2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800013d4:	01590c33          	add	s8,s2,s5
  while (len > 0)
    800013d8:	02098363          	beqz	s3,800013fe <copyout+0x6c>
    va0 = PGROUNDDOWN(dstva);
    800013dc:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0, 0);
    800013e0:	4601                	li	a2,0
    800013e2:	85ca                	mv	a1,s2
    800013e4:	855a                	mv	a0,s6
    800013e6:	00000097          	auipc	ra,0x0
    800013ea:	c66080e7          	jalr	-922(ra) # 8000104c <walkaddr>
    if (pa0 == 0)
    800013ee:	cd01                	beqz	a0,80001406 <copyout+0x74>
    n = PGSIZE - (dstva - va0);
    800013f0:	418904b3          	sub	s1,s2,s8
    800013f4:	94d6                	add	s1,s1,s5
    if (n > len)
    800013f6:	fc99f2e3          	bgeu	s3,s1,800013ba <copyout+0x28>
    800013fa:	84ce                	mv	s1,s3
    800013fc:	bf7d                	j	800013ba <copyout+0x28>
  }

  return 0;
    800013fe:	4501                	li	a0,0
    80001400:	a021                	j	80001408 <copyout+0x76>
    80001402:	4501                	li	a0,0
}
    80001404:	8082                	ret
      return -1;
    80001406:	557d                	li	a0,-1
}
    80001408:	60a6                	ld	ra,72(sp)
    8000140a:	6406                	ld	s0,64(sp)
    8000140c:	74e2                	ld	s1,56(sp)
    8000140e:	7942                	ld	s2,48(sp)
    80001410:	79a2                	ld	s3,40(sp)
    80001412:	7a02                	ld	s4,32(sp)
    80001414:	6ae2                	ld	s5,24(sp)
    80001416:	6b42                	ld	s6,16(sp)
    80001418:	6ba2                	ld	s7,8(sp)
    8000141a:	6c02                	ld	s8,0(sp)
    8000141c:	6161                	addi	sp,sp,80
    8000141e:	8082                	ret

0000000080001420 <copyin>:
int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{

  uint64 n, va0, pa0;

  while (len > 0)
    80001420:	caad                	beqz	a3,80001492 <copyin+0x72>
{
    80001422:	715d                	addi	sp,sp,-80
    80001424:	e486                	sd	ra,72(sp)
    80001426:	e0a2                	sd	s0,64(sp)
    80001428:	fc26                	sd	s1,56(sp)
    8000142a:	f84a                	sd	s2,48(sp)
    8000142c:	f44e                	sd	s3,40(sp)
    8000142e:	f052                	sd	s4,32(sp)
    80001430:	ec56                	sd	s5,24(sp)
    80001432:	e85a                	sd	s6,16(sp)
    80001434:	e45e                	sd	s7,8(sp)
    80001436:	e062                	sd	s8,0(sp)
    80001438:	0880                	addi	s0,sp,80
    8000143a:	8b2a                	mv	s6,a0
    8000143c:	8a2e                	mv	s4,a1
    8000143e:	8c32                	mv	s8,a2
    80001440:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(srcva);
    80001442:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0, 0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001444:	6a85                	lui	s5,0x1
    80001446:	a01d                	j	8000146c <copyin+0x4c>
    if (n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001448:	018505b3          	add	a1,a0,s8
    8000144c:	0004861b          	sext.w	a2,s1
    80001450:	412585b3          	sub	a1,a1,s2
    80001454:	8552                	mv	a0,s4
    80001456:	00000097          	auipc	ra,0x0
    8000145a:	8c4080e7          	jalr	-1852(ra) # 80000d1a <memmove>

    len -= n;
    8000145e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001462:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001464:	01590c33          	add	s8,s2,s5
  while (len > 0)
    80001468:	02098363          	beqz	s3,8000148e <copyin+0x6e>
    va0 = PGROUNDDOWN(srcva);
    8000146c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0, 0);
    80001470:	4601                	li	a2,0
    80001472:	85ca                	mv	a1,s2
    80001474:	855a                	mv	a0,s6
    80001476:	00000097          	auipc	ra,0x0
    8000147a:	bd6080e7          	jalr	-1066(ra) # 8000104c <walkaddr>
    if (pa0 == 0)
    8000147e:	cd01                	beqz	a0,80001496 <copyin+0x76>
    n = PGSIZE - (srcva - va0);
    80001480:	418904b3          	sub	s1,s2,s8
    80001484:	94d6                	add	s1,s1,s5
    if (n > len)
    80001486:	fc99f1e3          	bgeu	s3,s1,80001448 <copyin+0x28>
    8000148a:	84ce                	mv	s1,s3
    8000148c:	bf75                	j	80001448 <copyin+0x28>
  }

  return 0;
    8000148e:	4501                	li	a0,0
    80001490:	a021                	j	80001498 <copyin+0x78>
    80001492:	4501                	li	a0,0
}
    80001494:	8082                	ret
      return -1;
    80001496:	557d                	li	a0,-1
}
    80001498:	60a6                	ld	ra,72(sp)
    8000149a:	6406                	ld	s0,64(sp)
    8000149c:	74e2                	ld	s1,56(sp)
    8000149e:	7942                	ld	s2,48(sp)
    800014a0:	79a2                	ld	s3,40(sp)
    800014a2:	7a02                	ld	s4,32(sp)
    800014a4:	6ae2                	ld	s5,24(sp)
    800014a6:	6b42                	ld	s6,16(sp)
    800014a8:	6ba2                	ld	s7,8(sp)
    800014aa:	6c02                	ld	s8,0(sp)
    800014ac:	6161                	addi	sp,sp,80
    800014ae:	8082                	ret

00000000800014b0 <copyinstr>:
int copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0)
    800014b0:	c6cd                	beqz	a3,8000155a <copyinstr+0xaa>
{
    800014b2:	715d                	addi	sp,sp,-80
    800014b4:	e486                	sd	ra,72(sp)
    800014b6:	e0a2                	sd	s0,64(sp)
    800014b8:	fc26                	sd	s1,56(sp)
    800014ba:	f84a                	sd	s2,48(sp)
    800014bc:	f44e                	sd	s3,40(sp)
    800014be:	f052                	sd	s4,32(sp)
    800014c0:	ec56                	sd	s5,24(sp)
    800014c2:	e85a                	sd	s6,16(sp)
    800014c4:	e45e                	sd	s7,8(sp)
    800014c6:	0880                	addi	s0,sp,80
    800014c8:	8a2a                	mv	s4,a0
    800014ca:	8b2e                	mv	s6,a1
    800014cc:	8bb2                	mv	s7,a2
    800014ce:	84b6                	mv	s1,a3
  {
    va0 = PGROUNDDOWN(srcva);
    800014d0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0, 0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014d2:	6985                	lui	s3,0x1
    800014d4:	a035                	j	80001500 <copyinstr+0x50>
    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0)
    {
      if (*p == '\0')
      {
        *dst = '\0';
    800014d6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800014da:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null)
    800014dc:	0017b793          	seqz	a5,a5
    800014e0:	40f00533          	neg	a0,a5
  }
  else
  {
    return -1;
  }
} 
    800014e4:	60a6                	ld	ra,72(sp)
    800014e6:	6406                	ld	s0,64(sp)
    800014e8:	74e2                	ld	s1,56(sp)
    800014ea:	7942                	ld	s2,48(sp)
    800014ec:	79a2                	ld	s3,40(sp)
    800014ee:	7a02                	ld	s4,32(sp)
    800014f0:	6ae2                	ld	s5,24(sp)
    800014f2:	6b42                	ld	s6,16(sp)
    800014f4:	6ba2                	ld	s7,8(sp)
    800014f6:	6161                	addi	sp,sp,80
    800014f8:	8082                	ret
    srcva = va0 + PGSIZE;
    800014fa:	01390bb3          	add	s7,s2,s3
  while (got_null == 0 && max > 0)
    800014fe:	c8b1                	beqz	s1,80001552 <copyinstr+0xa2>
    va0 = PGROUNDDOWN(srcva);
    80001500:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0, 0);
    80001504:	4601                	li	a2,0
    80001506:	85ca                	mv	a1,s2
    80001508:	8552                	mv	a0,s4
    8000150a:	00000097          	auipc	ra,0x0
    8000150e:	b42080e7          	jalr	-1214(ra) # 8000104c <walkaddr>
    if (pa0 == 0)
    80001512:	c131                	beqz	a0,80001556 <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    80001514:	41790833          	sub	a6,s2,s7
    80001518:	984e                	add	a6,a6,s3
    if (n > max)
    8000151a:	0104f363          	bgeu	s1,a6,80001520 <copyinstr+0x70>
    8000151e:	8826                	mv	a6,s1
    char *p = (char *)(pa0 + (srcva - va0));
    80001520:	955e                	add	a0,a0,s7
    80001522:	41250533          	sub	a0,a0,s2
    while (n > 0)
    80001526:	fc080ae3          	beqz	a6,800014fa <copyinstr+0x4a>
    8000152a:	985a                	add	a6,a6,s6
    8000152c:	87da                	mv	a5,s6
      if (*p == '\0')
    8000152e:	41650633          	sub	a2,a0,s6
    80001532:	14fd                	addi	s1,s1,-1
    80001534:	9b26                	add	s6,s6,s1
    80001536:	00f60733          	add	a4,a2,a5
    8000153a:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffcc000>
    8000153e:	df41                	beqz	a4,800014d6 <copyinstr+0x26>
        *dst = *p;
    80001540:	00e78023          	sb	a4,0(a5)
      --max;
    80001544:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001548:	0785                	addi	a5,a5,1
    while (n > 0)
    8000154a:	ff0796e3          	bne	a5,a6,80001536 <copyinstr+0x86>
      dst++;
    8000154e:	8b42                	mv	s6,a6
    80001550:	b76d                	j	800014fa <copyinstr+0x4a>
    80001552:	4781                	li	a5,0
    80001554:	b761                	j	800014dc <copyinstr+0x2c>
      return -1;
    80001556:	557d                	li	a0,-1
    80001558:	b771                	j	800014e4 <copyinstr+0x34>
  int got_null = 0;
    8000155a:	4781                	li	a5,0
  if (got_null)
    8000155c:	0017b793          	seqz	a5,a5
    80001560:	40f00533          	neg	a0,a5
} 
    80001564:	8082                	ret

0000000080001566 <insert_page_to_swap_file>:
// Update data structure
int insert_page_to_swap_file(uint64 a)
{
    80001566:	1101                	addi	sp,sp,-32
    80001568:	ec06                	sd	ra,24(sp)
    8000156a:	e822                	sd	s0,16(sp)
    8000156c:	e426                	sd	s1,8(sp)
    8000156e:	e04a                	sd	s2,0(sp)
    80001570:	1000                	addi	s0,sp,32
    80001572:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001574:	00000097          	auipc	ra,0x0
    80001578:	7c0080e7          	jalr	1984(ra) # 80001d34 <myproc>
    8000157c:	84aa                	mv	s1,a0
  int free_index = get_next_free_space(p->pages_swap_info.free_spaces);
    8000157e:	17855503          	lhu	a0,376(a0)
    80001582:	00001097          	auipc	ra,0x1
    80001586:	1b4080e7          	jalr	436(ra) # 80002736 <get_next_free_space>
  if (free_index < 0 || free_index >= MAX_PSYC_PAGES)
    8000158a:	0005071b          	sext.w	a4,a0
    8000158e:	47bd                	li	a5,15
    80001590:	02e7eb63          	bltu	a5,a4,800015c6 <insert_page_to_swap_file+0x60>
    panic("insert_swap: no free index in swap arr");
  p->pages_swap_info.pages[free_index].va = a;                // Set va of page
    80001594:	00151793          	slli	a5,a0,0x1
    80001598:	97aa                	add	a5,a5,a0
    8000159a:	078e                	slli	a5,a5,0x3
    8000159c:	97a6                	add	a5,a5,s1
    8000159e:	1927b023          	sd	s2,384(a5)

  if (p->pages_swap_info.free_spaces & (1 << free_index))
    800015a2:	1784d783          	lhu	a5,376(s1)
    800015a6:	40a7d73b          	sraw	a4,a5,a0
    800015aa:	8b05                	andi	a4,a4,1
    800015ac:	e70d                	bnez	a4,800015d6 <insert_page_to_swap_file+0x70>
    panic("insert_swap: tried to set free space flag when it is already set");
  p->pages_swap_info.free_spaces |= (1 << free_index); // Mark space as occupied
    800015ae:	4705                	li	a4,1
    800015b0:	00a7173b          	sllw	a4,a4,a0
    800015b4:	8fd9                	or	a5,a5,a4
    800015b6:	16f49c23          	sh	a5,376(s1)

  return free_index;
}
    800015ba:	60e2                	ld	ra,24(sp)
    800015bc:	6442                	ld	s0,16(sp)
    800015be:	64a2                	ld	s1,8(sp)
    800015c0:	6902                	ld	s2,0(sp)
    800015c2:	6105                	addi	sp,sp,32
    800015c4:	8082                	ret
    panic("insert_swap: no free index in swap arr");
    800015c6:	00008517          	auipc	a0,0x8
    800015ca:	b6250513          	addi	a0,a0,-1182 # 80009128 <digits+0xe8>
    800015ce:	fffff097          	auipc	ra,0xfffff
    800015d2:	f5c080e7          	jalr	-164(ra) # 8000052a <panic>
    panic("insert_swap: tried to set free space flag when it is already set");
    800015d6:	00008517          	auipc	a0,0x8
    800015da:	b7a50513          	addi	a0,a0,-1158 # 80009150 <digits+0x110>
    800015de:	fffff097          	auipc	ra,0xfffff
    800015e2:	f4c080e7          	jalr	-180(ra) # 8000052a <panic>

00000000800015e6 <insert_page_to_physical_memory>:
// Update data structure
int insert_page_to_physical_memory(uint64 a)
{
    800015e6:	7179                	addi	sp,sp,-48
    800015e8:	f406                	sd	ra,40(sp)
    800015ea:	f022                	sd	s0,32(sp)
    800015ec:	ec26                	sd	s1,24(sp)
    800015ee:	e84a                	sd	s2,16(sp)
    800015f0:	e44e                	sd	s3,8(sp)
    800015f2:	1800                	addi	s0,sp,48
    800015f4:	89aa                	mv	s3,a0
  struct proc *p = myproc();
    800015f6:	00000097          	auipc	ra,0x0
    800015fa:	73e080e7          	jalr	1854(ra) # 80001d34 <myproc>
    800015fe:	892a                	mv	s2,a0
  int free_index = get_next_free_space(p->pages_physc_info.free_spaces);
    80001600:	30055503          	lhu	a0,768(a0)
    80001604:	00001097          	auipc	ra,0x1
    80001608:	132080e7          	jalr	306(ra) # 80002736 <get_next_free_space>
  if (free_index < 0 || free_index >= MAX_PSYC_PAGES)
    8000160c:	0005071b          	sext.w	a4,a0
    80001610:	47bd                	li	a5,15
    80001612:	04e7ef63          	bltu	a5,a4,80001670 <insert_page_to_physical_memory+0x8a>
    80001616:	84aa                	mv	s1,a0
    panic("insert_phys: no free index in physc arr");
  p->pages_physc_info.pages[free_index].va = a;                // Set va of page
    80001618:	00151793          	slli	a5,a0,0x1
    8000161c:	00a78733          	add	a4,a5,a0
    80001620:	070e                	slli	a4,a4,0x3
    80001622:	974a                	add	a4,a4,s2
    80001624:	31373423          	sd	s3,776(a4)
  p->pages_physc_info.pages[free_index].time_inserted = p->paging_time; //  Update insertion time
    80001628:	48893683          	ld	a3,1160(s2) # 1488 <_entry-0x7fffeb78>
    8000162c:	30d72c23          	sw	a3,792(a4)
  p->paging_time++;
    80001630:	0685                	addi	a3,a3,1
    80001632:	48d93423          	sd	a3,1160(s2)
  reset_aging_counter(&(p->pages_physc_info.pages[free_index]));
    80001636:	953e                	add	a0,a0,a5
    80001638:	050e                	slli	a0,a0,0x3
    8000163a:	30850513          	addi	a0,a0,776
    8000163e:	954a                	add	a0,a0,s2
    80001640:	00001097          	auipc	ra,0x1
    80001644:	720080e7          	jalr	1824(ra) # 80002d60 <reset_aging_counter>

  if (p->pages_physc_info.free_spaces & (1 << free_index))
    80001648:	30095783          	lhu	a5,768(s2)
    8000164c:	4097d73b          	sraw	a4,a5,s1
    80001650:	8b05                	andi	a4,a4,1
    80001652:	e71d                	bnez	a4,80001680 <insert_page_to_physical_memory+0x9a>
    panic("insert_phys: tried to set free space flag when it is already set");
  p->pages_physc_info.free_spaces |= (1 << free_index); // Mark space as occupied
    80001654:	4705                	li	a4,1
    80001656:	0097173b          	sllw	a4,a4,s1
    8000165a:	8fd9                	or	a5,a5,a4
    8000165c:	30f91023          	sh	a5,768(s2)

  return free_index;
}
    80001660:	8526                	mv	a0,s1
    80001662:	70a2                	ld	ra,40(sp)
    80001664:	7402                	ld	s0,32(sp)
    80001666:	64e2                	ld	s1,24(sp)
    80001668:	6942                	ld	s2,16(sp)
    8000166a:	69a2                	ld	s3,8(sp)
    8000166c:	6145                	addi	sp,sp,48
    8000166e:	8082                	ret
    panic("insert_phys: no free index in physc arr");
    80001670:	00008517          	auipc	a0,0x8
    80001674:	b2850513          	addi	a0,a0,-1240 # 80009198 <digits+0x158>
    80001678:	fffff097          	auipc	ra,0xfffff
    8000167c:	eb2080e7          	jalr	-334(ra) # 8000052a <panic>
    panic("insert_phys: tried to set free space flag when it is already set");
    80001680:	00008517          	auipc	a0,0x8
    80001684:	b4050513          	addi	a0,a0,-1216 # 800091c0 <digits+0x180>
    80001688:	fffff097          	auipc	ra,0xfffff
    8000168c:	ea2080e7          	jalr	-350(ra) # 8000052a <panic>

0000000080001690 <remove_page_from_physical_memory>:

// Update data structure
int remove_page_from_physical_memory(uint64 a)
{
    80001690:	1101                	addi	sp,sp,-32
    80001692:	ec06                	sd	ra,24(sp)
    80001694:	e822                	sd	s0,16(sp)
    80001696:	e426                	sd	s1,8(sp)
    80001698:	e04a                	sd	s2,0(sp)
    8000169a:	1000                	addi	s0,sp,32
    8000169c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000169e:	00000097          	auipc	ra,0x0
    800016a2:	696080e7          	jalr	1686(ra) # 80001d34 <myproc>
    800016a6:	84aa                	mv	s1,a0
  int index = get_index_in_page_info_array(a, p->pages_physc_info.pages);
    800016a8:	30850593          	addi	a1,a0,776
    800016ac:	854a                	mv	a0,s2
    800016ae:	00001097          	auipc	ra,0x1
    800016b2:	0b4080e7          	jalr	180(ra) # 80002762 <get_index_in_page_info_array>
  if (index < 0 || index >= MAX_PSYC_PAGES)
    800016b6:	0005071b          	sext.w	a4,a0
    800016ba:	47bd                	li	a5,15
    800016bc:	02e7ec63          	bltu	a5,a4,800016f4 <remove_page_from_physical_memory+0x64>
    return -1; // page is not in phisical mem
  // panic("remove_page_from_physical_memory: not found page to free ");
  if (!(p->pages_physc_info.free_spaces & (1 << index)))
    800016c0:	3004d783          	lhu	a5,768(s1)
    800016c4:	40a7d73b          	sraw	a4,a5,a0
    800016c8:	8b05                	andi	a4,a4,1
    800016ca:	cf09                	beqz	a4,800016e4 <remove_page_from_physical_memory+0x54>
    panic("remove_page_from_physical_memory: free space flag should be set but is unset");
  p->pages_physc_info.free_spaces ^= (1 << index);
    800016cc:	4705                	li	a4,1
    800016ce:	00a7173b          	sllw	a4,a4,a0
    800016d2:	8fb9                	xor	a5,a5,a4
    800016d4:	30f49023          	sh	a5,768(s1)

  return index;
}
    800016d8:	60e2                	ld	ra,24(sp)
    800016da:	6442                	ld	s0,16(sp)
    800016dc:	64a2                	ld	s1,8(sp)
    800016de:	6902                	ld	s2,0(sp)
    800016e0:	6105                	addi	sp,sp,32
    800016e2:	8082                	ret
    panic("remove_page_from_physical_memory: free space flag should be set but is unset");
    800016e4:	00008517          	auipc	a0,0x8
    800016e8:	b2450513          	addi	a0,a0,-1244 # 80009208 <digits+0x1c8>
    800016ec:	fffff097          	auipc	ra,0xfffff
    800016f0:	e3e080e7          	jalr	-450(ra) # 8000052a <panic>
    return -1; // page is not in phisical mem
    800016f4:	557d                	li	a0,-1
    800016f6:	b7cd                	j	800016d8 <remove_page_from_physical_memory+0x48>

00000000800016f8 <remove_page_from_swap_file>:

// Update data structure
int remove_page_from_swap_file(uint64 a)
{
    800016f8:	1101                	addi	sp,sp,-32
    800016fa:	ec06                	sd	ra,24(sp)
    800016fc:	e822                	sd	s0,16(sp)
    800016fe:	e426                	sd	s1,8(sp)
    80001700:	e04a                	sd	s2,0(sp)
    80001702:	1000                	addi	s0,sp,32
    80001704:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001706:	00000097          	auipc	ra,0x0
    8000170a:	62e080e7          	jalr	1582(ra) # 80001d34 <myproc>
    8000170e:	84aa                	mv	s1,a0
  int index = get_index_in_page_info_array(a, p->pages_swap_info.pages);
    80001710:	18050593          	addi	a1,a0,384
    80001714:	854a                	mv	a0,s2
    80001716:	00001097          	auipc	ra,0x1
    8000171a:	04c080e7          	jalr	76(ra) # 80002762 <get_index_in_page_info_array>
  if (index < 0 || index >= MAX_PSYC_PAGES)
    8000171e:	0005071b          	sext.w	a4,a0
    80001722:	47bd                	li	a5,15
    80001724:	02e7ec63          	bltu	a5,a4,8000175c <remove_page_from_swap_file+0x64>
    return -1; // page is not in phisical mem
  // panic("remove_page_from_physical_memory: not found page to free ");
  if (!(p->pages_swap_info.free_spaces & (1 << index)))
    80001728:	1784d783          	lhu	a5,376(s1)
    8000172c:	40a7d73b          	sraw	a4,a5,a0
    80001730:	8b05                	andi	a4,a4,1
    80001732:	cf09                	beqz	a4,8000174c <remove_page_from_swap_file+0x54>
    panic("remove_page_from_swap_file: free space flag should be set but is unset");
  p->pages_swap_info.free_spaces ^= (1 << index);
    80001734:	4705                	li	a4,1
    80001736:	00a7173b          	sllw	a4,a4,a0
    8000173a:	8fb9                	xor	a5,a5,a4
    8000173c:	16f49c23          	sh	a5,376(s1)

  return index;
    80001740:	60e2                	ld	ra,24(sp)
    80001742:	6442                	ld	s0,16(sp)
    80001744:	64a2                	ld	s1,8(sp)
    80001746:	6902                	ld	s2,0(sp)
    80001748:	6105                	addi	sp,sp,32
    8000174a:	8082                	ret
    panic("remove_page_from_swap_file: free space flag should be set but is unset");
    8000174c:	00008517          	auipc	a0,0x8
    80001750:	b0c50513          	addi	a0,a0,-1268 # 80009258 <digits+0x218>
    80001754:	fffff097          	auipc	ra,0xfffff
    80001758:	dd6080e7          	jalr	-554(ra) # 8000052a <panic>
    return -1; // page is not in phisical mem
    8000175c:	557d                	li	a0,-1
    8000175e:	b7cd                	j	80001740 <remove_page_from_swap_file+0x48>

0000000080001760 <uvmunmap>:
{
    80001760:	711d                	addi	sp,sp,-96
    80001762:	ec86                	sd	ra,88(sp)
    80001764:	e8a2                	sd	s0,80(sp)
    80001766:	e4a6                	sd	s1,72(sp)
    80001768:	e0ca                	sd	s2,64(sp)
    8000176a:	fc4e                	sd	s3,56(sp)
    8000176c:	f852                	sd	s4,48(sp)
    8000176e:	f456                	sd	s5,40(sp)
    80001770:	f05a                	sd	s6,32(sp)
    80001772:	ec5e                	sd	s7,24(sp)
    80001774:	e862                	sd	s8,16(sp)
    80001776:	e466                	sd	s9,8(sp)
    80001778:	1080                	addi	s0,sp,96
    8000177a:	89aa                	mv	s3,a0
    8000177c:	892e                	mv	s2,a1
    8000177e:	8a32                	mv	s4,a2
    80001780:	8b36                	mv	s6,a3
  struct proc *p = myproc();
    80001782:	00000097          	auipc	ra,0x0
    80001786:	5b2080e7          	jalr	1458(ra) # 80001d34 <myproc>
  if ((va % PGSIZE) != 0)
    8000178a:	03491793          	slli	a5,s2,0x34
    8000178e:	e795                	bnez	a5,800017ba <uvmunmap+0x5a>
    80001790:	8c2a                	mv	s8,a0
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80001792:	0a32                	slli	s4,s4,0xc
    80001794:	9a4a                	add	s4,s4,s2
    if (PTE_FLAGS(*pte) == PTE_V)
    80001796:	4b85                	li	s7,1
      if (myproc()->pid > 2 && pagetable == p->pagetable)
    80001798:	4c89                	li	s9,2
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    8000179a:	6a85                	lui	s5,0x1
    8000179c:	07496a63          	bltu	s2,s4,80001810 <uvmunmap+0xb0>
}
    800017a0:	60e6                	ld	ra,88(sp)
    800017a2:	6446                	ld	s0,80(sp)
    800017a4:	64a6                	ld	s1,72(sp)
    800017a6:	6906                	ld	s2,64(sp)
    800017a8:	79e2                	ld	s3,56(sp)
    800017aa:	7a42                	ld	s4,48(sp)
    800017ac:	7aa2                	ld	s5,40(sp)
    800017ae:	7b02                	ld	s6,32(sp)
    800017b0:	6be2                	ld	s7,24(sp)
    800017b2:	6c42                	ld	s8,16(sp)
    800017b4:	6ca2                	ld	s9,8(sp)
    800017b6:	6125                	addi	sp,sp,96
    800017b8:	8082                	ret
    panic("uvmunmap: not aligned");
    800017ba:	00008517          	auipc	a0,0x8
    800017be:	ae650513          	addi	a0,a0,-1306 # 800092a0 <digits+0x260>
    800017c2:	fffff097          	auipc	ra,0xfffff
    800017c6:	d68080e7          	jalr	-664(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    800017ca:	00008517          	auipc	a0,0x8
    800017ce:	aee50513          	addi	a0,a0,-1298 # 800092b8 <digits+0x278>
    800017d2:	fffff097          	auipc	ra,0xfffff
    800017d6:	d58080e7          	jalr	-680(ra) # 8000052a <panic>
          panic("uvmunmap: cant find file bos");
    800017da:	00008517          	auipc	a0,0x8
    800017de:	aee50513          	addi	a0,a0,-1298 # 800092c8 <digits+0x288>
    800017e2:	fffff097          	auipc	ra,0xfffff
    800017e6:	d48080e7          	jalr	-696(ra) # 8000052a <panic>
        panic("uvmunmap: not mapped");
    800017ea:	00008517          	auipc	a0,0x8
    800017ee:	afe50513          	addi	a0,a0,-1282 # 800092e8 <digits+0x2a8>
    800017f2:	fffff097          	auipc	ra,0xfffff
    800017f6:	d38080e7          	jalr	-712(ra) # 8000052a <panic>
    if (PTE_FLAGS(*pte) == PTE_V)
    800017fa:	3ff7f713          	andi	a4,a5,1023
    800017fe:	05770a63          	beq	a4,s7,80001852 <uvmunmap+0xf2>
    if (do_free)
    80001802:	060b1063          	bnez	s6,80001862 <uvmunmap+0x102>
    *pte = 0;
    80001806:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    8000180a:	9956                	add	s2,s2,s5
    8000180c:	f9497ae3          	bgeu	s2,s4,800017a0 <uvmunmap+0x40>
    if ((pte = walk(pagetable, a, 0)) == 0)
    80001810:	4601                	li	a2,0
    80001812:	85ca                	mv	a1,s2
    80001814:	854e                	mv	a0,s3
    80001816:	fffff097          	auipc	ra,0xfffff
    8000181a:	790080e7          	jalr	1936(ra) # 80000fa6 <walk>
    8000181e:	84aa                	mv	s1,a0
    80001820:	d54d                	beqz	a0,800017ca <uvmunmap+0x6a>
    if ((*pte & PTE_V) == 0){
    80001822:	611c                	ld	a5,0(a0)
    80001824:	0017f713          	andi	a4,a5,1
    80001828:	fb69                	bnez	a4,800017fa <uvmunmap+0x9a>
      if((*pte & PTE_PG)  && pagetable == p->pagetable){  // page is swapped out
    8000182a:	2007f793          	andi	a5,a5,512
    8000182e:	dfd5                	beqz	a5,800017ea <uvmunmap+0x8a>
    80001830:	050c3783          	ld	a5,80(s8)
    80001834:	fd379be3          	bne	a5,s3,8000180a <uvmunmap+0xaa>
        if(remove_page_from_swap_file(a)<0)
    80001838:	854a                	mv	a0,s2
    8000183a:	00000097          	auipc	ra,0x0
    8000183e:	ebe080e7          	jalr	-322(ra) # 800016f8 <remove_page_from_swap_file>
    80001842:	f8054ce3          	bltz	a0,800017da <uvmunmap+0x7a>
        p->total_pages_num--;
    80001846:	174c2783          	lw	a5,372(s8)
    8000184a:	37fd                	addiw	a5,a5,-1
    8000184c:	16fc2a23          	sw	a5,372(s8)
        continue;
    80001850:	bf6d                	j	8000180a <uvmunmap+0xaa>
      panic("uvmunmap: not a leaf");
    80001852:	00008517          	auipc	a0,0x8
    80001856:	aae50513          	addi	a0,a0,-1362 # 80009300 <digits+0x2c0>
    8000185a:	fffff097          	auipc	ra,0xfffff
    8000185e:	cd0080e7          	jalr	-816(ra) # 8000052a <panic>
      uint64 pa = PTE2PA(*pte);
    80001862:	00a7d513          	srli	a0,a5,0xa
      kfree((void *)pa);
    80001866:	0532                	slli	a0,a0,0xc
    80001868:	fffff097          	auipc	ra,0xfffff
    8000186c:	16e080e7          	jalr	366(ra) # 800009d6 <kfree>
      if (myproc()->pid > 2 && pagetable == p->pagetable)
    80001870:	00000097          	auipc	ra,0x0
    80001874:	4c4080e7          	jalr	1220(ra) # 80001d34 <myproc>
    80001878:	591c                	lw	a5,48(a0)
    8000187a:	f8fcd6e3          	bge	s9,a5,80001806 <uvmunmap+0xa6>
    8000187e:	050c3783          	ld	a5,80(s8)
    80001882:	f93792e3          	bne	a5,s3,80001806 <uvmunmap+0xa6>
        if (remove_page_from_physical_memory(a) >= 0)
    80001886:	854a                	mv	a0,s2
    80001888:	00000097          	auipc	ra,0x0
    8000188c:	e08080e7          	jalr	-504(ra) # 80001690 <remove_page_from_physical_memory>
    80001890:	f6054be3          	bltz	a0,80001806 <uvmunmap+0xa6>
          myproc()->physical_pages_num--;
    80001894:	00000097          	auipc	ra,0x0
    80001898:	4a0080e7          	jalr	1184(ra) # 80001d34 <myproc>
    8000189c:	17052783          	lw	a5,368(a0)
    800018a0:	37fd                	addiw	a5,a5,-1
    800018a2:	16f52823          	sw	a5,368(a0)
          myproc()->total_pages_num--;
    800018a6:	00000097          	auipc	ra,0x0
    800018aa:	48e080e7          	jalr	1166(ra) # 80001d34 <myproc>
    800018ae:	17452783          	lw	a5,372(a0)
    800018b2:	37fd                	addiw	a5,a5,-1
    800018b4:	16f52a23          	sw	a5,372(a0)
    800018b8:	b7b9                	j	80001806 <uvmunmap+0xa6>

00000000800018ba <uvmdealloc>:
{
    800018ba:	1101                	addi	sp,sp,-32
    800018bc:	ec06                	sd	ra,24(sp)
    800018be:	e822                	sd	s0,16(sp)
    800018c0:	e426                	sd	s1,8(sp)
    800018c2:	1000                	addi	s0,sp,32
    return oldsz;
    800018c4:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    800018c6:	00b67d63          	bgeu	a2,a1,800018e0 <uvmdealloc+0x26>
    800018ca:	84b2                	mv	s1,a2
  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    800018cc:	6785                	lui	a5,0x1
    800018ce:	17fd                	addi	a5,a5,-1
    800018d0:	00f60733          	add	a4,a2,a5
    800018d4:	767d                	lui	a2,0xfffff
    800018d6:	8f71                	and	a4,a4,a2
    800018d8:	97ae                	add	a5,a5,a1
    800018da:	8ff1                	and	a5,a5,a2
    800018dc:	00f76863          	bltu	a4,a5,800018ec <uvmdealloc+0x32>
}
    800018e0:	8526                	mv	a0,s1
    800018e2:	60e2                	ld	ra,24(sp)
    800018e4:	6442                	ld	s0,16(sp)
    800018e6:	64a2                	ld	s1,8(sp)
    800018e8:	6105                	addi	sp,sp,32
    800018ea:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800018ec:	8f99                	sub	a5,a5,a4
    800018ee:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800018f0:	4685                	li	a3,1
    800018f2:	0007861b          	sext.w	a2,a5
    800018f6:	85ba                	mv	a1,a4
    800018f8:	00000097          	auipc	ra,0x0
    800018fc:	e68080e7          	jalr	-408(ra) # 80001760 <uvmunmap>
    80001900:	b7c5                	j	800018e0 <uvmdealloc+0x26>

0000000080001902 <uvmalloc>:
{
    80001902:	711d                	addi	sp,sp,-96
    80001904:	ec86                	sd	ra,88(sp)
    80001906:	e8a2                	sd	s0,80(sp)
    80001908:	e4a6                	sd	s1,72(sp)
    8000190a:	e0ca                	sd	s2,64(sp)
    8000190c:	fc4e                	sd	s3,56(sp)
    8000190e:	f852                	sd	s4,48(sp)
    80001910:	f456                	sd	s5,40(sp)
    80001912:	f05a                	sd	s6,32(sp)
    80001914:	ec5e                	sd	s7,24(sp)
    80001916:	e862                	sd	s8,16(sp)
    80001918:	e466                	sd	s9,8(sp)
    8000191a:	1080                	addi	s0,sp,96
    8000191c:	8b2a                	mv	s6,a0
    8000191e:	892e                	mv	s2,a1
    80001920:	8ab2                	mv	s5,a2
  struct proc *p = myproc();
    80001922:	00000097          	auipc	ra,0x0
    80001926:	412080e7          	jalr	1042(ra) # 80001d34 <myproc>
  if (newsz < oldsz)
    8000192a:	132ae263          	bltu	s5,s2,80001a4e <uvmalloc+0x14c>
    8000192e:	84aa                	mv	s1,a0
  oldsz = PGROUNDUP(oldsz);
    80001930:	6b85                	lui	s7,0x1
    80001932:	1bfd                	addi	s7,s7,-1
    80001934:	995e                	add	s2,s2,s7
    80001936:	7bfd                	lui	s7,0xfffff
    80001938:	01797bb3          	and	s7,s2,s7
  for (a = oldsz; a < newsz; a += PGSIZE)
    8000193c:	135bf763          	bgeu	s7,s5,80001a6a <uvmalloc+0x168>
    80001940:	89de                	mv	s3,s7
    if (p->pid > 2)
    80001942:	4a09                	li	s4,2
      if (p->total_pages_num >= MAX_TOTAL_PAGES)
    80001944:	4c7d                	li	s8,31
      while (p->physical_pages_num >= MAX_PSYC_PAGES)
    80001946:	493d                	li	s2,15
    80001948:	a0bd                	j	800019b6 <uvmalloc+0xb4>
        panic("uvmalloc: proc out of space!");
    8000194a:	00008517          	auipc	a0,0x8
    8000194e:	9ce50513          	addi	a0,a0,-1586 # 80009318 <digits+0x2d8>
    80001952:	fffff097          	auipc	ra,0xfffff
    80001956:	bd8080e7          	jalr	-1064(ra) # 8000052a <panic>
          printf("panic recieved for pid=%d\n",p->pid);
    8000195a:	588c                	lw	a1,48(s1)
    8000195c:	00008517          	auipc	a0,0x8
    80001960:	9dc50513          	addi	a0,a0,-1572 # 80009338 <digits+0x2f8>
    80001964:	fffff097          	auipc	ra,0xfffff
    80001968:	c10080e7          	jalr	-1008(ra) # 80000574 <printf>
          panic("uvmalloc: did not find the page to swap out!");
    8000196c:	00008517          	auipc	a0,0x8
    80001970:	9ec50513          	addi	a0,a0,-1556 # 80009358 <digits+0x318>
    80001974:	fffff097          	auipc	ra,0xfffff
    80001978:	bb6080e7          	jalr	-1098(ra) # 8000052a <panic>
    mem = kalloc();
    8000197c:	fffff097          	auipc	ra,0xfffff
    80001980:	156080e7          	jalr	342(ra) # 80000ad2 <kalloc>
    80001984:	8caa                	mv	s9,a0
    if (mem == 0)
    80001986:	c93d                	beqz	a0,800019fc <uvmalloc+0xfa>
    memset(mem, 0, PGSIZE);
    80001988:	6605                	lui	a2,0x1
    8000198a:	4581                	li	a1,0
    8000198c:	fffff097          	auipc	ra,0xfffff
    80001990:	332080e7          	jalr	818(ra) # 80000cbe <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W | PTE_X | PTE_R | PTE_U) != 0)
    80001994:	4779                	li	a4,30
    80001996:	86e6                	mv	a3,s9
    80001998:	6605                	lui	a2,0x1
    8000199a:	85ce                	mv	a1,s3
    8000199c:	855a                	mv	a0,s6
    8000199e:	fffff097          	auipc	ra,0xfffff
    800019a2:	704080e7          	jalr	1796(ra) # 800010a2 <mappages>
    800019a6:	e525                	bnez	a0,80001a0e <uvmalloc+0x10c>
    if (p->pid > 2)
    800019a8:	589c                	lw	a5,48(s1)
    800019aa:	08fa4063          	blt	s4,a5,80001a2a <uvmalloc+0x128>
  for (a = oldsz; a < newsz; a += PGSIZE)
    800019ae:	6785                	lui	a5,0x1
    800019b0:	99be                	add	s3,s3,a5
    800019b2:	0959fc63          	bgeu	s3,s5,80001a4a <uvmalloc+0x148>
    if (p->pid > 2)
    800019b6:	589c                	lw	a5,48(s1)
    800019b8:	fcfa52e3          	bge	s4,a5,8000197c <uvmalloc+0x7a>
      if (p->total_pages_num >= MAX_TOTAL_PAGES)
    800019bc:	1744a783          	lw	a5,372(s1)
    800019c0:	f8fc45e3          	blt	s8,a5,8000194a <uvmalloc+0x48>
      while (p->physical_pages_num >= MAX_PSYC_PAGES)
    800019c4:	1704a783          	lw	a5,368(s1)
    800019c8:	faf95ae3          	bge	s2,a5,8000197c <uvmalloc+0x7a>
        int i = get_next_page_to_swap_out();
    800019cc:	00001097          	auipc	ra,0x1
    800019d0:	4e0080e7          	jalr	1248(ra) # 80002eac <get_next_page_to_swap_out>
        if (i < 0 || i >= MAX_PSYC_PAGES){
    800019d4:	0005079b          	sext.w	a5,a0
    800019d8:	f8f961e3          	bltu	s2,a5,8000195a <uvmalloc+0x58>
        uint64 rva = p->pages_physc_info.pages[i].va;
    800019dc:	00151793          	slli	a5,a0,0x1
    800019e0:	97aa                	add	a5,a5,a0
    800019e2:	078e                	slli	a5,a5,0x3
    800019e4:	97a6                	add	a5,a5,s1
        page_out(rva);
    800019e6:	3087b503          	ld	a0,776(a5) # 1308 <_entry-0x7fffecf8>
    800019ea:	00001097          	auipc	ra,0x1
    800019ee:	d9c080e7          	jalr	-612(ra) # 80002786 <page_out>
      while (p->physical_pages_num >= MAX_PSYC_PAGES)
    800019f2:	1704a783          	lw	a5,368(s1)
    800019f6:	fcf94be3          	blt	s2,a5,800019cc <uvmalloc+0xca>
    800019fa:	b749                	j	8000197c <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    800019fc:	865e                	mv	a2,s7
    800019fe:	85ce                	mv	a1,s3
    80001a00:	855a                	mv	a0,s6
    80001a02:	00000097          	auipc	ra,0x0
    80001a06:	eb8080e7          	jalr	-328(ra) # 800018ba <uvmdealloc>
      return 0;
    80001a0a:	4501                	li	a0,0
    80001a0c:	a091                	j	80001a50 <uvmalloc+0x14e>
      kfree(mem);
    80001a0e:	8566                	mv	a0,s9
    80001a10:	fffff097          	auipc	ra,0xfffff
    80001a14:	fc6080e7          	jalr	-58(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001a18:	865e                	mv	a2,s7
    80001a1a:	85ce                	mv	a1,s3
    80001a1c:	855a                	mv	a0,s6
    80001a1e:	00000097          	auipc	ra,0x0
    80001a22:	e9c080e7          	jalr	-356(ra) # 800018ba <uvmdealloc>
      return 0;
    80001a26:	4501                	li	a0,0
    80001a28:	a025                	j	80001a50 <uvmalloc+0x14e>
      insert_page_to_physical_memory(a);
    80001a2a:	854e                	mv	a0,s3
    80001a2c:	00000097          	auipc	ra,0x0
    80001a30:	bba080e7          	jalr	-1094(ra) # 800015e6 <insert_page_to_physical_memory>
      p->total_pages_num++;
    80001a34:	1744a783          	lw	a5,372(s1)
    80001a38:	2785                	addiw	a5,a5,1
    80001a3a:	16f4aa23          	sw	a5,372(s1)
      p->physical_pages_num++;
    80001a3e:	1704a783          	lw	a5,368(s1)
    80001a42:	2785                	addiw	a5,a5,1
    80001a44:	16f4a823          	sw	a5,368(s1)
    80001a48:	b79d                	j	800019ae <uvmalloc+0xac>
  return newsz;
    80001a4a:	8556                	mv	a0,s5
    80001a4c:	a011                	j	80001a50 <uvmalloc+0x14e>
    return oldsz;
    80001a4e:	854a                	mv	a0,s2
}
    80001a50:	60e6                	ld	ra,88(sp)
    80001a52:	6446                	ld	s0,80(sp)
    80001a54:	64a6                	ld	s1,72(sp)
    80001a56:	6906                	ld	s2,64(sp)
    80001a58:	79e2                	ld	s3,56(sp)
    80001a5a:	7a42                	ld	s4,48(sp)
    80001a5c:	7aa2                	ld	s5,40(sp)
    80001a5e:	7b02                	ld	s6,32(sp)
    80001a60:	6be2                	ld	s7,24(sp)
    80001a62:	6c42                	ld	s8,16(sp)
    80001a64:	6ca2                	ld	s9,8(sp)
    80001a66:	6125                	addi	sp,sp,96
    80001a68:	8082                	ret
  return newsz;
    80001a6a:	8556                	mv	a0,s5
    80001a6c:	b7d5                	j	80001a50 <uvmalloc+0x14e>

0000000080001a6e <uvmfree>:
{
    80001a6e:	1101                	addi	sp,sp,-32
    80001a70:	ec06                	sd	ra,24(sp)
    80001a72:	e822                	sd	s0,16(sp)
    80001a74:	e426                	sd	s1,8(sp)
    80001a76:	1000                	addi	s0,sp,32
    80001a78:	84aa                	mv	s1,a0
  if (sz > 0)
    80001a7a:	e999                	bnez	a1,80001a90 <uvmfree+0x22>
  freewalk(pagetable);
    80001a7c:	8526                	mv	a0,s1
    80001a7e:	00000097          	auipc	ra,0x0
    80001a82:	878080e7          	jalr	-1928(ra) # 800012f6 <freewalk>
}
    80001a86:	60e2                	ld	ra,24(sp)
    80001a88:	6442                	ld	s0,16(sp)
    80001a8a:	64a2                	ld	s1,8(sp)
    80001a8c:	6105                	addi	sp,sp,32
    80001a8e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001a90:	6605                	lui	a2,0x1
    80001a92:	167d                	addi	a2,a2,-1
    80001a94:	962e                	add	a2,a2,a1
    80001a96:	4685                	li	a3,1
    80001a98:	8231                	srli	a2,a2,0xc
    80001a9a:	4581                	li	a1,0
    80001a9c:	00000097          	auipc	ra,0x0
    80001aa0:	cc4080e7          	jalr	-828(ra) # 80001760 <uvmunmap>
    80001aa4:	bfe1                	j	80001a7c <uvmfree+0xe>

0000000080001aa6 <uvmcopy>:
  for (i = 0; i < sz; i += PGSIZE)
    80001aa6:	ca65                	beqz	a2,80001b96 <uvmcopy+0xf0>
{
    80001aa8:	715d                	addi	sp,sp,-80
    80001aaa:	e486                	sd	ra,72(sp)
    80001aac:	e0a2                	sd	s0,64(sp)
    80001aae:	fc26                	sd	s1,56(sp)
    80001ab0:	f84a                	sd	s2,48(sp)
    80001ab2:	f44e                	sd	s3,40(sp)
    80001ab4:	f052                	sd	s4,32(sp)
    80001ab6:	ec56                	sd	s5,24(sp)
    80001ab8:	e85a                	sd	s6,16(sp)
    80001aba:	e45e                	sd	s7,8(sp)
    80001abc:	0880                	addi	s0,sp,80
    80001abe:	8aaa                	mv	s5,a0
    80001ac0:	8a2e                	mv	s4,a1
    80001ac2:	89b2                	mv	s3,a2
  for (i = 0; i < sz; i += PGSIZE)
    80001ac4:	4901                	li	s2,0
    80001ac6:	a08d                	j	80001b28 <uvmcopy+0x82>
      panic("uvmcopy: pte should exist");
    80001ac8:	00008517          	auipc	a0,0x8
    80001acc:	8c050513          	addi	a0,a0,-1856 # 80009388 <digits+0x348>
    80001ad0:	fffff097          	auipc	ra,0xfffff
    80001ad4:	a5a080e7          	jalr	-1446(ra) # 8000052a <panic>
        panic("uvmcopy: page not present");
    80001ad8:	00008517          	auipc	a0,0x8
    80001adc:	8d050513          	addi	a0,a0,-1840 # 800093a8 <digits+0x368>
    80001ae0:	fffff097          	auipc	ra,0xfffff
    80001ae4:	a4a080e7          	jalr	-1462(ra) # 8000052a <panic>
    pa = PTE2PA(*pte);
    80001ae8:	00a75593          	srli	a1,a4,0xa
    80001aec:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001af0:	3ff77493          	andi	s1,a4,1023
    if ((mem = kalloc()) == 0)
    80001af4:	fffff097          	auipc	ra,0xfffff
    80001af8:	fde080e7          	jalr	-34(ra) # 80000ad2 <kalloc>
    80001afc:	8b2a                	mv	s6,a0
    80001afe:	c52d                	beqz	a0,80001b68 <uvmcopy+0xc2>
    memmove(mem, (char *)pa, PGSIZE);
    80001b00:	6605                	lui	a2,0x1
    80001b02:	85de                	mv	a1,s7
    80001b04:	fffff097          	auipc	ra,0xfffff
    80001b08:	216080e7          	jalr	534(ra) # 80000d1a <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    80001b0c:	8726                	mv	a4,s1
    80001b0e:	86da                	mv	a3,s6
    80001b10:	6605                	lui	a2,0x1
    80001b12:	85ca                	mv	a1,s2
    80001b14:	8552                	mv	a0,s4
    80001b16:	fffff097          	auipc	ra,0xfffff
    80001b1a:	58c080e7          	jalr	1420(ra) # 800010a2 <mappages>
    80001b1e:	e121                	bnez	a0,80001b5e <uvmcopy+0xb8>
  for (i = 0; i < sz; i += PGSIZE)
    80001b20:	6785                	lui	a5,0x1
    80001b22:	993e                	add	s2,s2,a5
    80001b24:	05397d63          	bgeu	s2,s3,80001b7e <uvmcopy+0xd8>
    if ((pte = walk(old, i, 0)) == 0)
    80001b28:	4601                	li	a2,0
    80001b2a:	85ca                	mv	a1,s2
    80001b2c:	8556                	mv	a0,s5
    80001b2e:	fffff097          	auipc	ra,0xfffff
    80001b32:	478080e7          	jalr	1144(ra) # 80000fa6 <walk>
    80001b36:	84aa                	mv	s1,a0
    80001b38:	d941                	beqz	a0,80001ac8 <uvmcopy+0x22>
    if ((*pte & PTE_V) == 0){
    80001b3a:	6118                	ld	a4,0(a0)
    80001b3c:	00177793          	andi	a5,a4,1
    80001b40:	f7c5                	bnez	a5,80001ae8 <uvmcopy+0x42>
      if(!(*pte & PTE_PG))
    80001b42:	20077713          	andi	a4,a4,512
    80001b46:	db49                	beqz	a4,80001ad8 <uvmcopy+0x32>
      if((np_pte = walk(new, i, 1)) == 0)
    80001b48:	4605                	li	a2,1
    80001b4a:	85ca                	mv	a1,s2
    80001b4c:	8552                	mv	a0,s4
    80001b4e:	fffff097          	auipc	ra,0xfffff
    80001b52:	458080e7          	jalr	1112(ra) # 80000fa6 <walk>
    80001b56:	c131                	beqz	a0,80001b9a <uvmcopy+0xf4>
      *np_pte = *pte; 
    80001b58:	609c                	ld	a5,0(s1)
    80001b5a:	e11c                	sd	a5,0(a0)
      continue;
    80001b5c:	b7d1                	j	80001b20 <uvmcopy+0x7a>
      kfree(mem);
    80001b5e:	855a                	mv	a0,s6
    80001b60:	fffff097          	auipc	ra,0xfffff
    80001b64:	e76080e7          	jalr	-394(ra) # 800009d6 <kfree>
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001b68:	4685                	li	a3,1
    80001b6a:	00c95613          	srli	a2,s2,0xc
    80001b6e:	4581                	li	a1,0
    80001b70:	8552                	mv	a0,s4
    80001b72:	00000097          	auipc	ra,0x0
    80001b76:	bee080e7          	jalr	-1042(ra) # 80001760 <uvmunmap>
  return -1;
    80001b7a:	557d                	li	a0,-1
    80001b7c:	a011                	j	80001b80 <uvmcopy+0xda>
  return 0;
    80001b7e:	4501                	li	a0,0
}
    80001b80:	60a6                	ld	ra,72(sp)
    80001b82:	6406                	ld	s0,64(sp)
    80001b84:	74e2                	ld	s1,56(sp)
    80001b86:	7942                	ld	s2,48(sp)
    80001b88:	79a2                	ld	s3,40(sp)
    80001b8a:	7a02                	ld	s4,32(sp)
    80001b8c:	6ae2                	ld	s5,24(sp)
    80001b8e:	6b42                	ld	s6,16(sp)
    80001b90:	6ba2                	ld	s7,8(sp)
    80001b92:	6161                	addi	sp,sp,80
    80001b94:	8082                	ret
  return 0;
    80001b96:	4501                	li	a0,0
}
    80001b98:	8082                	ret
        return -1;
    80001b9a:	557d                	li	a0,-1
    80001b9c:	b7d5                	j	80001b80 <uvmcopy+0xda>

0000000080001b9e <NFUA_compare>:
  return selected_pg_index;
}

long NFUA_compare(struct page_info *pg1, struct page_info *pg2)
{
  if (!pg1 || !pg2)
    80001b9e:	c511                	beqz	a0,80001baa <NFUA_compare+0xc>
    80001ba0:	c589                	beqz	a1,80001baa <NFUA_compare+0xc>
    panic("NFUA_compare : null input");
  return pg1->aging_counter - pg2->aging_counter;
    80001ba2:	6508                	ld	a0,8(a0)
    80001ba4:	659c                	ld	a5,8(a1)
}
    80001ba6:	8d1d                	sub	a0,a0,a5
    80001ba8:	8082                	ret
{
    80001baa:	1141                	addi	sp,sp,-16
    80001bac:	e406                	sd	ra,8(sp)
    80001bae:	e022                	sd	s0,0(sp)
    80001bb0:	0800                	addi	s0,sp,16
    panic("NFUA_compare : null input");
    80001bb2:	00008517          	auipc	a0,0x8
    80001bb6:	81650513          	addi	a0,a0,-2026 # 800093c8 <digits+0x388>
    80001bba:	fffff097          	auipc	ra,0xfffff
    80001bbe:	970080e7          	jalr	-1680(ra) # 8000052a <panic>

0000000080001bc2 <proc_mapstacks>:
{
    80001bc2:	7139                	addi	sp,sp,-64
    80001bc4:	fc06                	sd	ra,56(sp)
    80001bc6:	f822                	sd	s0,48(sp)
    80001bc8:	f426                	sd	s1,40(sp)
    80001bca:	f04a                	sd	s2,32(sp)
    80001bcc:	ec4e                	sd	s3,24(sp)
    80001bce:	e852                	sd	s4,16(sp)
    80001bd0:	e456                	sd	s5,8(sp)
    80001bd2:	e05a                	sd	s6,0(sp)
    80001bd4:	0080                	addi	s0,sp,64
    80001bd6:	89aa                	mv	s3,a0
  for (p = proc; p < &proc[NPROC]; p++)
    80001bd8:	00011497          	auipc	s1,0x11
    80001bdc:	af848493          	addi	s1,s1,-1288 # 800126d0 <proc>
    uint64 va = KSTACK((int)(p - proc));
    80001be0:	8b26                	mv	s6,s1
    80001be2:	00007a97          	auipc	s5,0x7
    80001be6:	41ea8a93          	addi	s5,s5,1054 # 80009000 <etext>
    80001bea:	04000937          	lui	s2,0x4000
    80001bee:	197d                	addi	s2,s2,-1
    80001bf0:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001bf2:	00023a17          	auipc	s4,0x23
    80001bf6:	edea0a13          	addi	s4,s4,-290 # 80024ad0 <tickslock>
    char *pa = kalloc();
    80001bfa:	fffff097          	auipc	ra,0xfffff
    80001bfe:	ed8080e7          	jalr	-296(ra) # 80000ad2 <kalloc>
    80001c02:	862a                	mv	a2,a0
    if (pa == 0)
    80001c04:	c131                	beqz	a0,80001c48 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001c06:	416485b3          	sub	a1,s1,s6
    80001c0a:	8591                	srai	a1,a1,0x4
    80001c0c:	000ab783          	ld	a5,0(s5)
    80001c10:	02f585b3          	mul	a1,a1,a5
    80001c14:	2585                	addiw	a1,a1,1
    80001c16:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001c1a:	4719                	li	a4,6
    80001c1c:	6685                	lui	a3,0x1
    80001c1e:	40b905b3          	sub	a1,s2,a1
    80001c22:	854e                	mv	a0,s3
    80001c24:	fffff097          	auipc	ra,0xfffff
    80001c28:	50c080e7          	jalr	1292(ra) # 80001130 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c2c:	49048493          	addi	s1,s1,1168
    80001c30:	fd4495e3          	bne	s1,s4,80001bfa <proc_mapstacks+0x38>
}
    80001c34:	70e2                	ld	ra,56(sp)
    80001c36:	7442                	ld	s0,48(sp)
    80001c38:	74a2                	ld	s1,40(sp)
    80001c3a:	7902                	ld	s2,32(sp)
    80001c3c:	69e2                	ld	s3,24(sp)
    80001c3e:	6a42                	ld	s4,16(sp)
    80001c40:	6aa2                	ld	s5,8(sp)
    80001c42:	6b02                	ld	s6,0(sp)
    80001c44:	6121                	addi	sp,sp,64
    80001c46:	8082                	ret
      panic("kalloc");
    80001c48:	00007517          	auipc	a0,0x7
    80001c4c:	7a050513          	addi	a0,a0,1952 # 800093e8 <digits+0x3a8>
    80001c50:	fffff097          	auipc	ra,0xfffff
    80001c54:	8da080e7          	jalr	-1830(ra) # 8000052a <panic>

0000000080001c58 <procinit>:
{
    80001c58:	7139                	addi	sp,sp,-64
    80001c5a:	fc06                	sd	ra,56(sp)
    80001c5c:	f822                	sd	s0,48(sp)
    80001c5e:	f426                	sd	s1,40(sp)
    80001c60:	f04a                	sd	s2,32(sp)
    80001c62:	ec4e                	sd	s3,24(sp)
    80001c64:	e852                	sd	s4,16(sp)
    80001c66:	e456                	sd	s5,8(sp)
    80001c68:	e05a                	sd	s6,0(sp)
    80001c6a:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    80001c6c:	00007597          	auipc	a1,0x7
    80001c70:	78458593          	addi	a1,a1,1924 # 800093f0 <digits+0x3b0>
    80001c74:	00010517          	auipc	a0,0x10
    80001c78:	62c50513          	addi	a0,a0,1580 # 800122a0 <pid_lock>
    80001c7c:	fffff097          	auipc	ra,0xfffff
    80001c80:	eb6080e7          	jalr	-330(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001c84:	00007597          	auipc	a1,0x7
    80001c88:	77458593          	addi	a1,a1,1908 # 800093f8 <digits+0x3b8>
    80001c8c:	00010517          	auipc	a0,0x10
    80001c90:	62c50513          	addi	a0,a0,1580 # 800122b8 <wait_lock>
    80001c94:	fffff097          	auipc	ra,0xfffff
    80001c98:	e9e080e7          	jalr	-354(ra) # 80000b32 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c9c:	00011497          	auipc	s1,0x11
    80001ca0:	a3448493          	addi	s1,s1,-1484 # 800126d0 <proc>
    initlock(&p->lock, "proc");
    80001ca4:	00007b17          	auipc	s6,0x7
    80001ca8:	764b0b13          	addi	s6,s6,1892 # 80009408 <digits+0x3c8>
    p->kstack = KSTACK((int)(p - proc));
    80001cac:	8aa6                	mv	s5,s1
    80001cae:	00007a17          	auipc	s4,0x7
    80001cb2:	352a0a13          	addi	s4,s4,850 # 80009000 <etext>
    80001cb6:	04000937          	lui	s2,0x4000
    80001cba:	197d                	addi	s2,s2,-1
    80001cbc:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001cbe:	00023997          	auipc	s3,0x23
    80001cc2:	e1298993          	addi	s3,s3,-494 # 80024ad0 <tickslock>
    initlock(&p->lock, "proc");
    80001cc6:	85da                	mv	a1,s6
    80001cc8:	8526                	mv	a0,s1
    80001cca:	fffff097          	auipc	ra,0xfffff
    80001cce:	e68080e7          	jalr	-408(ra) # 80000b32 <initlock>
    p->kstack = KSTACK((int)(p - proc));
    80001cd2:	415487b3          	sub	a5,s1,s5
    80001cd6:	8791                	srai	a5,a5,0x4
    80001cd8:	000a3703          	ld	a4,0(s4)
    80001cdc:	02e787b3          	mul	a5,a5,a4
    80001ce0:	2785                	addiw	a5,a5,1
    80001ce2:	00d7979b          	slliw	a5,a5,0xd
    80001ce6:	40f907b3          	sub	a5,s2,a5
    80001cea:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001cec:	49048493          	addi	s1,s1,1168
    80001cf0:	fd349be3          	bne	s1,s3,80001cc6 <procinit+0x6e>
}
    80001cf4:	70e2                	ld	ra,56(sp)
    80001cf6:	7442                	ld	s0,48(sp)
    80001cf8:	74a2                	ld	s1,40(sp)
    80001cfa:	7902                	ld	s2,32(sp)
    80001cfc:	69e2                	ld	s3,24(sp)
    80001cfe:	6a42                	ld	s4,16(sp)
    80001d00:	6aa2                	ld	s5,8(sp)
    80001d02:	6b02                	ld	s6,0(sp)
    80001d04:	6121                	addi	sp,sp,64
    80001d06:	8082                	ret

0000000080001d08 <cpuid>:
{
    80001d08:	1141                	addi	sp,sp,-16
    80001d0a:	e422                	sd	s0,8(sp)
    80001d0c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d0e:	8512                	mv	a0,tp
}
    80001d10:	2501                	sext.w	a0,a0
    80001d12:	6422                	ld	s0,8(sp)
    80001d14:	0141                	addi	sp,sp,16
    80001d16:	8082                	ret

0000000080001d18 <mycpu>:
{
    80001d18:	1141                	addi	sp,sp,-16
    80001d1a:	e422                	sd	s0,8(sp)
    80001d1c:	0800                	addi	s0,sp,16
    80001d1e:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001d20:	2781                	sext.w	a5,a5
    80001d22:	079e                	slli	a5,a5,0x7
}
    80001d24:	00010517          	auipc	a0,0x10
    80001d28:	5ac50513          	addi	a0,a0,1452 # 800122d0 <cpus>
    80001d2c:	953e                	add	a0,a0,a5
    80001d2e:	6422                	ld	s0,8(sp)
    80001d30:	0141                	addi	sp,sp,16
    80001d32:	8082                	ret

0000000080001d34 <myproc>:
{
    80001d34:	1101                	addi	sp,sp,-32
    80001d36:	ec06                	sd	ra,24(sp)
    80001d38:	e822                	sd	s0,16(sp)
    80001d3a:	e426                	sd	s1,8(sp)
    80001d3c:	1000                	addi	s0,sp,32
  push_off();
    80001d3e:	fffff097          	auipc	ra,0xfffff
    80001d42:	e38080e7          	jalr	-456(ra) # 80000b76 <push_off>
    80001d46:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001d48:	2781                	sext.w	a5,a5
    80001d4a:	079e                	slli	a5,a5,0x7
    80001d4c:	00010717          	auipc	a4,0x10
    80001d50:	55470713          	addi	a4,a4,1364 # 800122a0 <pid_lock>
    80001d54:	97ba                	add	a5,a5,a4
    80001d56:	7b84                	ld	s1,48(a5)
  pop_off();
    80001d58:	fffff097          	auipc	ra,0xfffff
    80001d5c:	ebe080e7          	jalr	-322(ra) # 80000c16 <pop_off>
}
    80001d60:	8526                	mv	a0,s1
    80001d62:	60e2                	ld	ra,24(sp)
    80001d64:	6442                	ld	s0,16(sp)
    80001d66:	64a2                	ld	s1,8(sp)
    80001d68:	6105                	addi	sp,sp,32
    80001d6a:	8082                	ret

0000000080001d6c <forkret>:
{
    80001d6c:	1141                	addi	sp,sp,-16
    80001d6e:	e406                	sd	ra,8(sp)
    80001d70:	e022                	sd	s0,0(sp)
    80001d72:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001d74:	00000097          	auipc	ra,0x0
    80001d78:	fc0080e7          	jalr	-64(ra) # 80001d34 <myproc>
    80001d7c:	fffff097          	auipc	ra,0xfffff
    80001d80:	efa080e7          	jalr	-262(ra) # 80000c76 <release>
  if (first)
    80001d84:	00008797          	auipc	a5,0x8
    80001d88:	f7c7a783          	lw	a5,-132(a5) # 80009d00 <first.1>
    80001d8c:	eb89                	bnez	a5,80001d9e <forkret+0x32>
  usertrapret();
    80001d8e:	00001097          	auipc	ra,0x1
    80001d92:	20a080e7          	jalr	522(ra) # 80002f98 <usertrapret>
}
    80001d96:	60a2                	ld	ra,8(sp)
    80001d98:	6402                	ld	s0,0(sp)
    80001d9a:	0141                	addi	sp,sp,16
    80001d9c:	8082                	ret
    first = 0;
    80001d9e:	00008797          	auipc	a5,0x8
    80001da2:	f607a123          	sw	zero,-158(a5) # 80009d00 <first.1>
    fsinit(ROOTDEV);
    80001da6:	4505                	li	a0,1
    80001da8:	00002097          	auipc	ra,0x2
    80001dac:	03a080e7          	jalr	58(ra) # 80003de2 <fsinit>
    80001db0:	bff9                	j	80001d8e <forkret+0x22>

0000000080001db2 <allocpid>:
{
    80001db2:	1101                	addi	sp,sp,-32
    80001db4:	ec06                	sd	ra,24(sp)
    80001db6:	e822                	sd	s0,16(sp)
    80001db8:	e426                	sd	s1,8(sp)
    80001dba:	e04a                	sd	s2,0(sp)
    80001dbc:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001dbe:	00010917          	auipc	s2,0x10
    80001dc2:	4e290913          	addi	s2,s2,1250 # 800122a0 <pid_lock>
    80001dc6:	854a                	mv	a0,s2
    80001dc8:	fffff097          	auipc	ra,0xfffff
    80001dcc:	dfa080e7          	jalr	-518(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001dd0:	00008797          	auipc	a5,0x8
    80001dd4:	f3478793          	addi	a5,a5,-204 # 80009d04 <nextpid>
    80001dd8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001dda:	0014871b          	addiw	a4,s1,1
    80001dde:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001de0:	854a                	mv	a0,s2
    80001de2:	fffff097          	auipc	ra,0xfffff
    80001de6:	e94080e7          	jalr	-364(ra) # 80000c76 <release>
}
    80001dea:	8526                	mv	a0,s1
    80001dec:	60e2                	ld	ra,24(sp)
    80001dee:	6442                	ld	s0,16(sp)
    80001df0:	64a2                	ld	s1,8(sp)
    80001df2:	6902                	ld	s2,0(sp)
    80001df4:	6105                	addi	sp,sp,32
    80001df6:	8082                	ret

0000000080001df8 <proc_pagetable>:
{
    80001df8:	1101                	addi	sp,sp,-32
    80001dfa:	ec06                	sd	ra,24(sp)
    80001dfc:	e822                	sd	s0,16(sp)
    80001dfe:	e426                	sd	s1,8(sp)
    80001e00:	e04a                	sd	s2,0(sp)
    80001e02:	1000                	addi	s0,sp,32
    80001e04:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001e06:	fffff097          	auipc	ra,0xfffff
    80001e0a:	450080e7          	jalr	1104(ra) # 80001256 <uvmcreate>
    80001e0e:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001e10:	c121                	beqz	a0,80001e50 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001e12:	4729                	li	a4,10
    80001e14:	00006697          	auipc	a3,0x6
    80001e18:	1ec68693          	addi	a3,a3,492 # 80008000 <_trampoline>
    80001e1c:	6605                	lui	a2,0x1
    80001e1e:	040005b7          	lui	a1,0x4000
    80001e22:	15fd                	addi	a1,a1,-1
    80001e24:	05b2                	slli	a1,a1,0xc
    80001e26:	fffff097          	auipc	ra,0xfffff
    80001e2a:	27c080e7          	jalr	636(ra) # 800010a2 <mappages>
    80001e2e:	02054863          	bltz	a0,80001e5e <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001e32:	4719                	li	a4,6
    80001e34:	05893683          	ld	a3,88(s2)
    80001e38:	6605                	lui	a2,0x1
    80001e3a:	020005b7          	lui	a1,0x2000
    80001e3e:	15fd                	addi	a1,a1,-1
    80001e40:	05b6                	slli	a1,a1,0xd
    80001e42:	8526                	mv	a0,s1
    80001e44:	fffff097          	auipc	ra,0xfffff
    80001e48:	25e080e7          	jalr	606(ra) # 800010a2 <mappages>
    80001e4c:	02054163          	bltz	a0,80001e6e <proc_pagetable+0x76>
}
    80001e50:	8526                	mv	a0,s1
    80001e52:	60e2                	ld	ra,24(sp)
    80001e54:	6442                	ld	s0,16(sp)
    80001e56:	64a2                	ld	s1,8(sp)
    80001e58:	6902                	ld	s2,0(sp)
    80001e5a:	6105                	addi	sp,sp,32
    80001e5c:	8082                	ret
    uvmfree(pagetable, 0);
    80001e5e:	4581                	li	a1,0
    80001e60:	8526                	mv	a0,s1
    80001e62:	00000097          	auipc	ra,0x0
    80001e66:	c0c080e7          	jalr	-1012(ra) # 80001a6e <uvmfree>
    return 0;
    80001e6a:	4481                	li	s1,0
    80001e6c:	b7d5                	j	80001e50 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e6e:	4681                	li	a3,0
    80001e70:	4605                	li	a2,1
    80001e72:	040005b7          	lui	a1,0x4000
    80001e76:	15fd                	addi	a1,a1,-1
    80001e78:	05b2                	slli	a1,a1,0xc
    80001e7a:	8526                	mv	a0,s1
    80001e7c:	00000097          	auipc	ra,0x0
    80001e80:	8e4080e7          	jalr	-1820(ra) # 80001760 <uvmunmap>
    uvmfree(pagetable, 0);
    80001e84:	4581                	li	a1,0
    80001e86:	8526                	mv	a0,s1
    80001e88:	00000097          	auipc	ra,0x0
    80001e8c:	be6080e7          	jalr	-1050(ra) # 80001a6e <uvmfree>
    return 0;
    80001e90:	4481                	li	s1,0
    80001e92:	bf7d                	j	80001e50 <proc_pagetable+0x58>

0000000080001e94 <proc_freepagetable>:
{
    80001e94:	1101                	addi	sp,sp,-32
    80001e96:	ec06                	sd	ra,24(sp)
    80001e98:	e822                	sd	s0,16(sp)
    80001e9a:	e426                	sd	s1,8(sp)
    80001e9c:	e04a                	sd	s2,0(sp)
    80001e9e:	1000                	addi	s0,sp,32
    80001ea0:	84aa                	mv	s1,a0
    80001ea2:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ea4:	4681                	li	a3,0
    80001ea6:	4605                	li	a2,1
    80001ea8:	040005b7          	lui	a1,0x4000
    80001eac:	15fd                	addi	a1,a1,-1
    80001eae:	05b2                	slli	a1,a1,0xc
    80001eb0:	00000097          	auipc	ra,0x0
    80001eb4:	8b0080e7          	jalr	-1872(ra) # 80001760 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001eb8:	4681                	li	a3,0
    80001eba:	4605                	li	a2,1
    80001ebc:	020005b7          	lui	a1,0x2000
    80001ec0:	15fd                	addi	a1,a1,-1
    80001ec2:	05b6                	slli	a1,a1,0xd
    80001ec4:	8526                	mv	a0,s1
    80001ec6:	00000097          	auipc	ra,0x0
    80001eca:	89a080e7          	jalr	-1894(ra) # 80001760 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ece:	85ca                	mv	a1,s2
    80001ed0:	8526                	mv	a0,s1
    80001ed2:	00000097          	auipc	ra,0x0
    80001ed6:	b9c080e7          	jalr	-1124(ra) # 80001a6e <uvmfree>
}
    80001eda:	60e2                	ld	ra,24(sp)
    80001edc:	6442                	ld	s0,16(sp)
    80001ede:	64a2                	ld	s1,8(sp)
    80001ee0:	6902                	ld	s2,0(sp)
    80001ee2:	6105                	addi	sp,sp,32
    80001ee4:	8082                	ret

0000000080001ee6 <freeproc>:
{
    80001ee6:	1101                	addi	sp,sp,-32
    80001ee8:	ec06                	sd	ra,24(sp)
    80001eea:	e822                	sd	s0,16(sp)
    80001eec:	e426                	sd	s1,8(sp)
    80001eee:	1000                	addi	s0,sp,32
    80001ef0:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001ef2:	6d28                	ld	a0,88(a0)
    80001ef4:	c509                	beqz	a0,80001efe <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001ef6:	fffff097          	auipc	ra,0xfffff
    80001efa:	ae0080e7          	jalr	-1312(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001efe:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001f02:	68a8                	ld	a0,80(s1)
    80001f04:	c511                	beqz	a0,80001f10 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001f06:	64ac                	ld	a1,72(s1)
    80001f08:	00000097          	auipc	ra,0x0
    80001f0c:	f8c080e7          	jalr	-116(ra) # 80001e94 <proc_freepagetable>
  p->pagetable = 0;
    80001f10:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001f14:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001f18:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001f1c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001f20:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001f24:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001f28:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001f2c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001f30:	0004ac23          	sw	zero,24(s1)
  p->paging_time = 0;
    80001f34:	4804b423          	sd	zero,1160(s1)
}
    80001f38:	60e2                	ld	ra,24(sp)
    80001f3a:	6442                	ld	s0,16(sp)
    80001f3c:	64a2                	ld	s1,8(sp)
    80001f3e:	6105                	addi	sp,sp,32
    80001f40:	8082                	ret

0000000080001f42 <allocproc>:
{
    80001f42:	1101                	addi	sp,sp,-32
    80001f44:	ec06                	sd	ra,24(sp)
    80001f46:	e822                	sd	s0,16(sp)
    80001f48:	e426                	sd	s1,8(sp)
    80001f4a:	e04a                	sd	s2,0(sp)
    80001f4c:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001f4e:	00010497          	auipc	s1,0x10
    80001f52:	78248493          	addi	s1,s1,1922 # 800126d0 <proc>
    80001f56:	00023917          	auipc	s2,0x23
    80001f5a:	b7a90913          	addi	s2,s2,-1158 # 80024ad0 <tickslock>
    acquire(&p->lock);
    80001f5e:	8526                	mv	a0,s1
    80001f60:	fffff097          	auipc	ra,0xfffff
    80001f64:	c62080e7          	jalr	-926(ra) # 80000bc2 <acquire>
    if (p->state == UNUSED)
    80001f68:	4c9c                	lw	a5,24(s1)
    80001f6a:	cf81                	beqz	a5,80001f82 <allocproc+0x40>
      release(&p->lock);
    80001f6c:	8526                	mv	a0,s1
    80001f6e:	fffff097          	auipc	ra,0xfffff
    80001f72:	d08080e7          	jalr	-760(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001f76:	49048493          	addi	s1,s1,1168
    80001f7a:	ff2492e3          	bne	s1,s2,80001f5e <allocproc+0x1c>
  return 0;
    80001f7e:	4481                	li	s1,0
    80001f80:	a09d                	j	80001fe6 <allocproc+0xa4>
  p->pid = allocpid();
    80001f82:	00000097          	auipc	ra,0x0
    80001f86:	e30080e7          	jalr	-464(ra) # 80001db2 <allocpid>
    80001f8a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001f8c:	4785                	li	a5,1
    80001f8e:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001f90:	fffff097          	auipc	ra,0xfffff
    80001f94:	b42080e7          	jalr	-1214(ra) # 80000ad2 <kalloc>
    80001f98:	892a                	mv	s2,a0
    80001f9a:	eca8                	sd	a0,88(s1)
    80001f9c:	cd21                	beqz	a0,80001ff4 <allocproc+0xb2>
  p->pagetable = proc_pagetable(p);
    80001f9e:	8526                	mv	a0,s1
    80001fa0:	00000097          	auipc	ra,0x0
    80001fa4:	e58080e7          	jalr	-424(ra) # 80001df8 <proc_pagetable>
    80001fa8:	892a                	mv	s2,a0
    80001faa:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001fac:	c125                	beqz	a0,8000200c <allocproc+0xca>
  memset(&p->context, 0, sizeof(p->context));
    80001fae:	07000613          	li	a2,112
    80001fb2:	4581                	li	a1,0
    80001fb4:	06048513          	addi	a0,s1,96
    80001fb8:	fffff097          	auipc	ra,0xfffff
    80001fbc:	d06080e7          	jalr	-762(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80001fc0:	00000797          	auipc	a5,0x0
    80001fc4:	dac78793          	addi	a5,a5,-596 # 80001d6c <forkret>
    80001fc8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001fca:	60bc                	ld	a5,64(s1)
    80001fcc:	6705                	lui	a4,0x1
    80001fce:	97ba                	add	a5,a5,a4
    80001fd0:	f4bc                	sd	a5,104(s1)
  p->physical_pages_num = 0;
    80001fd2:	1604a823          	sw	zero,368(s1)
  p->total_pages_num = 0;
    80001fd6:	1604aa23          	sw	zero,372(s1)
  p->pages_physc_info.free_spaces = 0;
    80001fda:	30049023          	sh	zero,768(s1)
  p->pages_swap_info.free_spaces = 0;
    80001fde:	16049c23          	sh	zero,376(s1)
  p->paging_time = 0;
    80001fe2:	4804b423          	sd	zero,1160(s1)
}
    80001fe6:	8526                	mv	a0,s1
    80001fe8:	60e2                	ld	ra,24(sp)
    80001fea:	6442                	ld	s0,16(sp)
    80001fec:	64a2                	ld	s1,8(sp)
    80001fee:	6902                	ld	s2,0(sp)
    80001ff0:	6105                	addi	sp,sp,32
    80001ff2:	8082                	ret
    freeproc(p);
    80001ff4:	8526                	mv	a0,s1
    80001ff6:	00000097          	auipc	ra,0x0
    80001ffa:	ef0080e7          	jalr	-272(ra) # 80001ee6 <freeproc>
    release(&p->lock);
    80001ffe:	8526                	mv	a0,s1
    80002000:	fffff097          	auipc	ra,0xfffff
    80002004:	c76080e7          	jalr	-906(ra) # 80000c76 <release>
    return 0;
    80002008:	84ca                	mv	s1,s2
    8000200a:	bff1                	j	80001fe6 <allocproc+0xa4>
    freeproc(p);
    8000200c:	8526                	mv	a0,s1
    8000200e:	00000097          	auipc	ra,0x0
    80002012:	ed8080e7          	jalr	-296(ra) # 80001ee6 <freeproc>
    release(&p->lock);
    80002016:	8526                	mv	a0,s1
    80002018:	fffff097          	auipc	ra,0xfffff
    8000201c:	c5e080e7          	jalr	-930(ra) # 80000c76 <release>
    return 0;
    80002020:	84ca                	mv	s1,s2
    80002022:	b7d1                	j	80001fe6 <allocproc+0xa4>

0000000080002024 <userinit>:
{
    80002024:	1101                	addi	sp,sp,-32
    80002026:	ec06                	sd	ra,24(sp)
    80002028:	e822                	sd	s0,16(sp)
    8000202a:	e426                	sd	s1,8(sp)
    8000202c:	1000                	addi	s0,sp,32
  p = allocproc();
    8000202e:	00000097          	auipc	ra,0x0
    80002032:	f14080e7          	jalr	-236(ra) # 80001f42 <allocproc>
    80002036:	84aa                	mv	s1,a0
  initproc = p;
    80002038:	00008797          	auipc	a5,0x8
    8000203c:	fea7b823          	sd	a0,-16(a5) # 8000a028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80002040:	03400613          	li	a2,52
    80002044:	00008597          	auipc	a1,0x8
    80002048:	ccc58593          	addi	a1,a1,-820 # 80009d10 <initcode>
    8000204c:	6928                	ld	a0,80(a0)
    8000204e:	fffff097          	auipc	ra,0xfffff
    80002052:	236080e7          	jalr	566(ra) # 80001284 <uvminit>
  p->sz = PGSIZE;
    80002056:	6785                	lui	a5,0x1
    80002058:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    8000205a:	6cb8                	ld	a4,88(s1)
    8000205c:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80002060:	6cb8                	ld	a4,88(s1)
    80002062:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002064:	4641                	li	a2,16
    80002066:	00007597          	auipc	a1,0x7
    8000206a:	3aa58593          	addi	a1,a1,938 # 80009410 <digits+0x3d0>
    8000206e:	15848513          	addi	a0,s1,344
    80002072:	fffff097          	auipc	ra,0xfffff
    80002076:	d9e080e7          	jalr	-610(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    8000207a:	00007517          	auipc	a0,0x7
    8000207e:	3a650513          	addi	a0,a0,934 # 80009420 <digits+0x3e0>
    80002082:	00002097          	auipc	ra,0x2
    80002086:	78e080e7          	jalr	1934(ra) # 80004810 <namei>
    8000208a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000208e:	478d                	li	a5,3
    80002090:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80002092:	8526                	mv	a0,s1
    80002094:	fffff097          	auipc	ra,0xfffff
    80002098:	be2080e7          	jalr	-1054(ra) # 80000c76 <release>
}
    8000209c:	60e2                	ld	ra,24(sp)
    8000209e:	6442                	ld	s0,16(sp)
    800020a0:	64a2                	ld	s1,8(sp)
    800020a2:	6105                	addi	sp,sp,32
    800020a4:	8082                	ret

00000000800020a6 <growproc>:
{
    800020a6:	1101                	addi	sp,sp,-32
    800020a8:	ec06                	sd	ra,24(sp)
    800020aa:	e822                	sd	s0,16(sp)
    800020ac:	e426                	sd	s1,8(sp)
    800020ae:	e04a                	sd	s2,0(sp)
    800020b0:	1000                	addi	s0,sp,32
    800020b2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800020b4:	00000097          	auipc	ra,0x0
    800020b8:	c80080e7          	jalr	-896(ra) # 80001d34 <myproc>
    800020bc:	892a                	mv	s2,a0
  sz = p->sz;
    800020be:	652c                	ld	a1,72(a0)
    800020c0:	0005861b          	sext.w	a2,a1
  if (n > 0)
    800020c4:	00904f63          	bgtz	s1,800020e2 <growproc+0x3c>
  else if (n < 0)
    800020c8:	0204cc63          	bltz	s1,80002100 <growproc+0x5a>
  p->sz = sz;
    800020cc:	1602                	slli	a2,a2,0x20
    800020ce:	9201                	srli	a2,a2,0x20
    800020d0:	04c93423          	sd	a2,72(s2)
  return 0;
    800020d4:	4501                	li	a0,0
}
    800020d6:	60e2                	ld	ra,24(sp)
    800020d8:	6442                	ld	s0,16(sp)
    800020da:	64a2                	ld	s1,8(sp)
    800020dc:	6902                	ld	s2,0(sp)
    800020de:	6105                	addi	sp,sp,32
    800020e0:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0)
    800020e2:	9e25                	addw	a2,a2,s1
    800020e4:	1602                	slli	a2,a2,0x20
    800020e6:	9201                	srli	a2,a2,0x20
    800020e8:	1582                	slli	a1,a1,0x20
    800020ea:	9181                	srli	a1,a1,0x20
    800020ec:	6928                	ld	a0,80(a0)
    800020ee:	00000097          	auipc	ra,0x0
    800020f2:	814080e7          	jalr	-2028(ra) # 80001902 <uvmalloc>
    800020f6:	0005061b          	sext.w	a2,a0
    800020fa:	fa69                	bnez	a2,800020cc <growproc+0x26>
      return -1;
    800020fc:	557d                	li	a0,-1
    800020fe:	bfe1                	j	800020d6 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002100:	9e25                	addw	a2,a2,s1
    80002102:	1602                	slli	a2,a2,0x20
    80002104:	9201                	srli	a2,a2,0x20
    80002106:	1582                	slli	a1,a1,0x20
    80002108:	9181                	srli	a1,a1,0x20
    8000210a:	6928                	ld	a0,80(a0)
    8000210c:	fffff097          	auipc	ra,0xfffff
    80002110:	7ae080e7          	jalr	1966(ra) # 800018ba <uvmdealloc>
    80002114:	0005061b          	sext.w	a2,a0
    80002118:	bf55                	j	800020cc <growproc+0x26>

000000008000211a <sched>:
{
    8000211a:	7179                	addi	sp,sp,-48
    8000211c:	f406                	sd	ra,40(sp)
    8000211e:	f022                	sd	s0,32(sp)
    80002120:	ec26                	sd	s1,24(sp)
    80002122:	e84a                	sd	s2,16(sp)
    80002124:	e44e                	sd	s3,8(sp)
    80002126:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002128:	00000097          	auipc	ra,0x0
    8000212c:	c0c080e7          	jalr	-1012(ra) # 80001d34 <myproc>
    80002130:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002132:	fffff097          	auipc	ra,0xfffff
    80002136:	a16080e7          	jalr	-1514(ra) # 80000b48 <holding>
    8000213a:	c93d                	beqz	a0,800021b0 <sched+0x96>
    8000213c:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000213e:	2781                	sext.w	a5,a5
    80002140:	079e                	slli	a5,a5,0x7
    80002142:	00010717          	auipc	a4,0x10
    80002146:	15e70713          	addi	a4,a4,350 # 800122a0 <pid_lock>
    8000214a:	97ba                	add	a5,a5,a4
    8000214c:	0a87a703          	lw	a4,168(a5) # 10a8 <_entry-0x7fffef58>
    80002150:	4785                	li	a5,1
    80002152:	06f71763          	bne	a4,a5,800021c0 <sched+0xa6>
  if (p->state == RUNNING)
    80002156:	4c98                	lw	a4,24(s1)
    80002158:	4791                	li	a5,4
    8000215a:	06f70b63          	beq	a4,a5,800021d0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000215e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002162:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002164:	efb5                	bnez	a5,800021e0 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002166:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002168:	00010917          	auipc	s2,0x10
    8000216c:	13890913          	addi	s2,s2,312 # 800122a0 <pid_lock>
    80002170:	2781                	sext.w	a5,a5
    80002172:	079e                	slli	a5,a5,0x7
    80002174:	97ca                	add	a5,a5,s2
    80002176:	0ac7a983          	lw	s3,172(a5)
    8000217a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000217c:	2781                	sext.w	a5,a5
    8000217e:	079e                	slli	a5,a5,0x7
    80002180:	00010597          	auipc	a1,0x10
    80002184:	15858593          	addi	a1,a1,344 # 800122d8 <cpus+0x8>
    80002188:	95be                	add	a1,a1,a5
    8000218a:	06048513          	addi	a0,s1,96
    8000218e:	00001097          	auipc	ra,0x1
    80002192:	d60080e7          	jalr	-672(ra) # 80002eee <swtch>
    80002196:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002198:	2781                	sext.w	a5,a5
    8000219a:	079e                	slli	a5,a5,0x7
    8000219c:	97ca                	add	a5,a5,s2
    8000219e:	0b37a623          	sw	s3,172(a5)
}
    800021a2:	70a2                	ld	ra,40(sp)
    800021a4:	7402                	ld	s0,32(sp)
    800021a6:	64e2                	ld	s1,24(sp)
    800021a8:	6942                	ld	s2,16(sp)
    800021aa:	69a2                	ld	s3,8(sp)
    800021ac:	6145                	addi	sp,sp,48
    800021ae:	8082                	ret
    panic("sched p->lock");
    800021b0:	00007517          	auipc	a0,0x7
    800021b4:	27850513          	addi	a0,a0,632 # 80009428 <digits+0x3e8>
    800021b8:	ffffe097          	auipc	ra,0xffffe
    800021bc:	372080e7          	jalr	882(ra) # 8000052a <panic>
    panic("sched locks");
    800021c0:	00007517          	auipc	a0,0x7
    800021c4:	27850513          	addi	a0,a0,632 # 80009438 <digits+0x3f8>
    800021c8:	ffffe097          	auipc	ra,0xffffe
    800021cc:	362080e7          	jalr	866(ra) # 8000052a <panic>
    panic("sched running");
    800021d0:	00007517          	auipc	a0,0x7
    800021d4:	27850513          	addi	a0,a0,632 # 80009448 <digits+0x408>
    800021d8:	ffffe097          	auipc	ra,0xffffe
    800021dc:	352080e7          	jalr	850(ra) # 8000052a <panic>
    panic("sched interruptible");
    800021e0:	00007517          	auipc	a0,0x7
    800021e4:	27850513          	addi	a0,a0,632 # 80009458 <digits+0x418>
    800021e8:	ffffe097          	auipc	ra,0xffffe
    800021ec:	342080e7          	jalr	834(ra) # 8000052a <panic>

00000000800021f0 <yield>:
{
    800021f0:	1101                	addi	sp,sp,-32
    800021f2:	ec06                	sd	ra,24(sp)
    800021f4:	e822                	sd	s0,16(sp)
    800021f6:	e426                	sd	s1,8(sp)
    800021f8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021fa:	00000097          	auipc	ra,0x0
    800021fe:	b3a080e7          	jalr	-1222(ra) # 80001d34 <myproc>
    80002202:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002204:	fffff097          	auipc	ra,0xfffff
    80002208:	9be080e7          	jalr	-1602(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    8000220c:	478d                	li	a5,3
    8000220e:	cc9c                	sw	a5,24(s1)
  sched();
    80002210:	00000097          	auipc	ra,0x0
    80002214:	f0a080e7          	jalr	-246(ra) # 8000211a <sched>
  release(&p->lock);
    80002218:	8526                	mv	a0,s1
    8000221a:	fffff097          	auipc	ra,0xfffff
    8000221e:	a5c080e7          	jalr	-1444(ra) # 80000c76 <release>
}
    80002222:	60e2                	ld	ra,24(sp)
    80002224:	6442                	ld	s0,16(sp)
    80002226:	64a2                	ld	s1,8(sp)
    80002228:	6105                	addi	sp,sp,32
    8000222a:	8082                	ret

000000008000222c <sleep>:
{
    8000222c:	7179                	addi	sp,sp,-48
    8000222e:	f406                	sd	ra,40(sp)
    80002230:	f022                	sd	s0,32(sp)
    80002232:	ec26                	sd	s1,24(sp)
    80002234:	e84a                	sd	s2,16(sp)
    80002236:	e44e                	sd	s3,8(sp)
    80002238:	1800                	addi	s0,sp,48
    8000223a:	89aa                	mv	s3,a0
    8000223c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000223e:	00000097          	auipc	ra,0x0
    80002242:	af6080e7          	jalr	-1290(ra) # 80001d34 <myproc>
    80002246:	84aa                	mv	s1,a0
  acquire(&p->lock); //DOC: sleeplock1
    80002248:	fffff097          	auipc	ra,0xfffff
    8000224c:	97a080e7          	jalr	-1670(ra) # 80000bc2 <acquire>
  release(lk);
    80002250:	854a                	mv	a0,s2
    80002252:	fffff097          	auipc	ra,0xfffff
    80002256:	a24080e7          	jalr	-1500(ra) # 80000c76 <release>
  p->chan = chan;
    8000225a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000225e:	4789                	li	a5,2
    80002260:	cc9c                	sw	a5,24(s1)
  sched();
    80002262:	00000097          	auipc	ra,0x0
    80002266:	eb8080e7          	jalr	-328(ra) # 8000211a <sched>
  p->chan = 0;
    8000226a:	0204b023          	sd	zero,32(s1)
  release(&p->lock);
    8000226e:	8526                	mv	a0,s1
    80002270:	fffff097          	auipc	ra,0xfffff
    80002274:	a06080e7          	jalr	-1530(ra) # 80000c76 <release>
  acquire(lk);
    80002278:	854a                	mv	a0,s2
    8000227a:	fffff097          	auipc	ra,0xfffff
    8000227e:	948080e7          	jalr	-1720(ra) # 80000bc2 <acquire>
}
    80002282:	70a2                	ld	ra,40(sp)
    80002284:	7402                	ld	s0,32(sp)
    80002286:	64e2                	ld	s1,24(sp)
    80002288:	6942                	ld	s2,16(sp)
    8000228a:	69a2                	ld	s3,8(sp)
    8000228c:	6145                	addi	sp,sp,48
    8000228e:	8082                	ret

0000000080002290 <wait>:
{
    80002290:	715d                	addi	sp,sp,-80
    80002292:	e486                	sd	ra,72(sp)
    80002294:	e0a2                	sd	s0,64(sp)
    80002296:	fc26                	sd	s1,56(sp)
    80002298:	f84a                	sd	s2,48(sp)
    8000229a:	f44e                	sd	s3,40(sp)
    8000229c:	f052                	sd	s4,32(sp)
    8000229e:	ec56                	sd	s5,24(sp)
    800022a0:	e85a                	sd	s6,16(sp)
    800022a2:	e45e                	sd	s7,8(sp)
    800022a4:	e062                	sd	s8,0(sp)
    800022a6:	0880                	addi	s0,sp,80
    800022a8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022aa:	00000097          	auipc	ra,0x0
    800022ae:	a8a080e7          	jalr	-1398(ra) # 80001d34 <myproc>
    800022b2:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800022b4:	00010517          	auipc	a0,0x10
    800022b8:	00450513          	addi	a0,a0,4 # 800122b8 <wait_lock>
    800022bc:	fffff097          	auipc	ra,0xfffff
    800022c0:	906080e7          	jalr	-1786(ra) # 80000bc2 <acquire>
    havekids = 0;
    800022c4:	4b81                	li	s7,0
        if (np->state == ZOMBIE)
    800022c6:	4a15                	li	s4,5
        havekids = 1;
    800022c8:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800022ca:	00023997          	auipc	s3,0x23
    800022ce:	80698993          	addi	s3,s3,-2042 # 80024ad0 <tickslock>
    sleep(p, &wait_lock); //DOC: wait-sleep
    800022d2:	00010c17          	auipc	s8,0x10
    800022d6:	fe6c0c13          	addi	s8,s8,-26 # 800122b8 <wait_lock>
    havekids = 0;
    800022da:	875e                	mv	a4,s7
    for (np = proc; np < &proc[NPROC]; np++)
    800022dc:	00010497          	auipc	s1,0x10
    800022e0:	3f448493          	addi	s1,s1,1012 # 800126d0 <proc>
    800022e4:	a0bd                	j	80002352 <wait+0xc2>
          pid = np->pid;
    800022e6:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022ea:	000b0e63          	beqz	s6,80002306 <wait+0x76>
    800022ee:	4691                	li	a3,4
    800022f0:	02c48613          	addi	a2,s1,44
    800022f4:	85da                	mv	a1,s6
    800022f6:	05093503          	ld	a0,80(s2)
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	098080e7          	jalr	152(ra) # 80001392 <copyout>
    80002302:	02054563          	bltz	a0,8000232c <wait+0x9c>
          freeproc(np);
    80002306:	8526                	mv	a0,s1
    80002308:	00000097          	auipc	ra,0x0
    8000230c:	bde080e7          	jalr	-1058(ra) # 80001ee6 <freeproc>
          release(&np->lock);
    80002310:	8526                	mv	a0,s1
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	964080e7          	jalr	-1692(ra) # 80000c76 <release>
          release(&wait_lock);
    8000231a:	00010517          	auipc	a0,0x10
    8000231e:	f9e50513          	addi	a0,a0,-98 # 800122b8 <wait_lock>
    80002322:	fffff097          	auipc	ra,0xfffff
    80002326:	954080e7          	jalr	-1708(ra) # 80000c76 <release>
          return pid;
    8000232a:	a09d                	j	80002390 <wait+0x100>
            release(&np->lock);
    8000232c:	8526                	mv	a0,s1
    8000232e:	fffff097          	auipc	ra,0xfffff
    80002332:	948080e7          	jalr	-1720(ra) # 80000c76 <release>
            release(&wait_lock);
    80002336:	00010517          	auipc	a0,0x10
    8000233a:	f8250513          	addi	a0,a0,-126 # 800122b8 <wait_lock>
    8000233e:	fffff097          	auipc	ra,0xfffff
    80002342:	938080e7          	jalr	-1736(ra) # 80000c76 <release>
            return -1;
    80002346:	59fd                	li	s3,-1
    80002348:	a0a1                	j	80002390 <wait+0x100>
    for (np = proc; np < &proc[NPROC]; np++)
    8000234a:	49048493          	addi	s1,s1,1168
    8000234e:	03348463          	beq	s1,s3,80002376 <wait+0xe6>
      if (np->parent == p)
    80002352:	7c9c                	ld	a5,56(s1)
    80002354:	ff279be3          	bne	a5,s2,8000234a <wait+0xba>
        acquire(&np->lock);
    80002358:	8526                	mv	a0,s1
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	868080e7          	jalr	-1944(ra) # 80000bc2 <acquire>
        if (np->state == ZOMBIE)
    80002362:	4c9c                	lw	a5,24(s1)
    80002364:	f94781e3          	beq	a5,s4,800022e6 <wait+0x56>
        release(&np->lock);
    80002368:	8526                	mv	a0,s1
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	90c080e7          	jalr	-1780(ra) # 80000c76 <release>
        havekids = 1;
    80002372:	8756                	mv	a4,s5
    80002374:	bfd9                	j	8000234a <wait+0xba>
    if (!havekids || p->killed)
    80002376:	c701                	beqz	a4,8000237e <wait+0xee>
    80002378:	02892783          	lw	a5,40(s2)
    8000237c:	c79d                	beqz	a5,800023aa <wait+0x11a>
      release(&wait_lock);
    8000237e:	00010517          	auipc	a0,0x10
    80002382:	f3a50513          	addi	a0,a0,-198 # 800122b8 <wait_lock>
    80002386:	fffff097          	auipc	ra,0xfffff
    8000238a:	8f0080e7          	jalr	-1808(ra) # 80000c76 <release>
      return -1;
    8000238e:	59fd                	li	s3,-1
}
    80002390:	854e                	mv	a0,s3
    80002392:	60a6                	ld	ra,72(sp)
    80002394:	6406                	ld	s0,64(sp)
    80002396:	74e2                	ld	s1,56(sp)
    80002398:	7942                	ld	s2,48(sp)
    8000239a:	79a2                	ld	s3,40(sp)
    8000239c:	7a02                	ld	s4,32(sp)
    8000239e:	6ae2                	ld	s5,24(sp)
    800023a0:	6b42                	ld	s6,16(sp)
    800023a2:	6ba2                	ld	s7,8(sp)
    800023a4:	6c02                	ld	s8,0(sp)
    800023a6:	6161                	addi	sp,sp,80
    800023a8:	8082                	ret
    sleep(p, &wait_lock); //DOC: wait-sleep
    800023aa:	85e2                	mv	a1,s8
    800023ac:	854a                	mv	a0,s2
    800023ae:	00000097          	auipc	ra,0x0
    800023b2:	e7e080e7          	jalr	-386(ra) # 8000222c <sleep>
    havekids = 0;
    800023b6:	b715                	j	800022da <wait+0x4a>

00000000800023b8 <wakeup>:
{
    800023b8:	7139                	addi	sp,sp,-64
    800023ba:	fc06                	sd	ra,56(sp)
    800023bc:	f822                	sd	s0,48(sp)
    800023be:	f426                	sd	s1,40(sp)
    800023c0:	f04a                	sd	s2,32(sp)
    800023c2:	ec4e                	sd	s3,24(sp)
    800023c4:	e852                	sd	s4,16(sp)
    800023c6:	e456                	sd	s5,8(sp)
    800023c8:	0080                	addi	s0,sp,64
    800023ca:	8a2a                	mv	s4,a0
  for (p = proc; p < &proc[NPROC]; p++)
    800023cc:	00010497          	auipc	s1,0x10
    800023d0:	30448493          	addi	s1,s1,772 # 800126d0 <proc>
      if (p->state == SLEEPING && p->chan == chan)
    800023d4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800023d6:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800023d8:	00022917          	auipc	s2,0x22
    800023dc:	6f890913          	addi	s2,s2,1784 # 80024ad0 <tickslock>
    800023e0:	a811                	j	800023f4 <wakeup+0x3c>
      release(&p->lock);
    800023e2:	8526                	mv	a0,s1
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	892080e7          	jalr	-1902(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800023ec:	49048493          	addi	s1,s1,1168
    800023f0:	03248663          	beq	s1,s2,8000241c <wakeup+0x64>
    if (p != myproc())
    800023f4:	00000097          	auipc	ra,0x0
    800023f8:	940080e7          	jalr	-1728(ra) # 80001d34 <myproc>
    800023fc:	fea488e3          	beq	s1,a0,800023ec <wakeup+0x34>
      acquire(&p->lock);
    80002400:	8526                	mv	a0,s1
    80002402:	ffffe097          	auipc	ra,0xffffe
    80002406:	7c0080e7          	jalr	1984(ra) # 80000bc2 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    8000240a:	4c9c                	lw	a5,24(s1)
    8000240c:	fd379be3          	bne	a5,s3,800023e2 <wakeup+0x2a>
    80002410:	709c                	ld	a5,32(s1)
    80002412:	fd4798e3          	bne	a5,s4,800023e2 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002416:	0154ac23          	sw	s5,24(s1)
    8000241a:	b7e1                	j	800023e2 <wakeup+0x2a>
}
    8000241c:	70e2                	ld	ra,56(sp)
    8000241e:	7442                	ld	s0,48(sp)
    80002420:	74a2                	ld	s1,40(sp)
    80002422:	7902                	ld	s2,32(sp)
    80002424:	69e2                	ld	s3,24(sp)
    80002426:	6a42                	ld	s4,16(sp)
    80002428:	6aa2                	ld	s5,8(sp)
    8000242a:	6121                	addi	sp,sp,64
    8000242c:	8082                	ret

000000008000242e <reparent>:
{
    8000242e:	7179                	addi	sp,sp,-48
    80002430:	f406                	sd	ra,40(sp)
    80002432:	f022                	sd	s0,32(sp)
    80002434:	ec26                	sd	s1,24(sp)
    80002436:	e84a                	sd	s2,16(sp)
    80002438:	e44e                	sd	s3,8(sp)
    8000243a:	e052                	sd	s4,0(sp)
    8000243c:	1800                	addi	s0,sp,48
    8000243e:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002440:	00010497          	auipc	s1,0x10
    80002444:	29048493          	addi	s1,s1,656 # 800126d0 <proc>
      pp->parent = initproc;
    80002448:	00008a17          	auipc	s4,0x8
    8000244c:	be0a0a13          	addi	s4,s4,-1056 # 8000a028 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002450:	00022997          	auipc	s3,0x22
    80002454:	68098993          	addi	s3,s3,1664 # 80024ad0 <tickslock>
    80002458:	a029                	j	80002462 <reparent+0x34>
    8000245a:	49048493          	addi	s1,s1,1168
    8000245e:	01348d63          	beq	s1,s3,80002478 <reparent+0x4a>
    if (pp->parent == p)
    80002462:	7c9c                	ld	a5,56(s1)
    80002464:	ff279be3          	bne	a5,s2,8000245a <reparent+0x2c>
      pp->parent = initproc;
    80002468:	000a3503          	ld	a0,0(s4)
    8000246c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000246e:	00000097          	auipc	ra,0x0
    80002472:	f4a080e7          	jalr	-182(ra) # 800023b8 <wakeup>
    80002476:	b7d5                	j	8000245a <reparent+0x2c>
}
    80002478:	70a2                	ld	ra,40(sp)
    8000247a:	7402                	ld	s0,32(sp)
    8000247c:	64e2                	ld	s1,24(sp)
    8000247e:	6942                	ld	s2,16(sp)
    80002480:	69a2                	ld	s3,8(sp)
    80002482:	6a02                	ld	s4,0(sp)
    80002484:	6145                	addi	sp,sp,48
    80002486:	8082                	ret

0000000080002488 <exit>:
{
    80002488:	7179                	addi	sp,sp,-48
    8000248a:	f406                	sd	ra,40(sp)
    8000248c:	f022                	sd	s0,32(sp)
    8000248e:	ec26                	sd	s1,24(sp)
    80002490:	e84a                	sd	s2,16(sp)
    80002492:	e44e                	sd	s3,8(sp)
    80002494:	e052                	sd	s4,0(sp)
    80002496:	1800                	addi	s0,sp,48
    80002498:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000249a:	00000097          	auipc	ra,0x0
    8000249e:	89a080e7          	jalr	-1894(ra) # 80001d34 <myproc>
    800024a2:	89aa                	mv	s3,a0
  if (p == initproc)
    800024a4:	00008797          	auipc	a5,0x8
    800024a8:	b847b783          	ld	a5,-1148(a5) # 8000a028 <initproc>
    800024ac:	0d050493          	addi	s1,a0,208
    800024b0:	15050913          	addi	s2,a0,336
    800024b4:	02a79363          	bne	a5,a0,800024da <exit+0x52>
    panic("init exiting");
    800024b8:	00007517          	auipc	a0,0x7
    800024bc:	fb850513          	addi	a0,a0,-72 # 80009470 <digits+0x430>
    800024c0:	ffffe097          	auipc	ra,0xffffe
    800024c4:	06a080e7          	jalr	106(ra) # 8000052a <panic>
      fileclose(f);
    800024c8:	00003097          	auipc	ra,0x3
    800024cc:	d46080e7          	jalr	-698(ra) # 8000520e <fileclose>
      p->ofile[fd] = 0;
    800024d0:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800024d4:	04a1                	addi	s1,s1,8
    800024d6:	01248563          	beq	s1,s2,800024e0 <exit+0x58>
    if (p->ofile[fd])
    800024da:	6088                	ld	a0,0(s1)
    800024dc:	f575                	bnez	a0,800024c8 <exit+0x40>
    800024de:	bfdd                	j	800024d4 <exit+0x4c>
  removeSwapFile(p);  // Remove swap file of p
    800024e0:	854e                	mv	a0,s3
    800024e2:	00002097          	auipc	ra,0x2
    800024e6:	3da080e7          	jalr	986(ra) # 800048bc <removeSwapFile>
  begin_op();
    800024ea:	00003097          	auipc	ra,0x3
    800024ee:	858080e7          	jalr	-1960(ra) # 80004d42 <begin_op>
  iput(p->cwd);
    800024f2:	1509b503          	ld	a0,336(s3)
    800024f6:	00002097          	auipc	ra,0x2
    800024fa:	d1e080e7          	jalr	-738(ra) # 80004214 <iput>
  end_op();
    800024fe:	00003097          	auipc	ra,0x3
    80002502:	8c4080e7          	jalr	-1852(ra) # 80004dc2 <end_op>
  p->cwd = 0;
    80002506:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000250a:	00010497          	auipc	s1,0x10
    8000250e:	dae48493          	addi	s1,s1,-594 # 800122b8 <wait_lock>
    80002512:	8526                	mv	a0,s1
    80002514:	ffffe097          	auipc	ra,0xffffe
    80002518:	6ae080e7          	jalr	1710(ra) # 80000bc2 <acquire>
  reparent(p);
    8000251c:	854e                	mv	a0,s3
    8000251e:	00000097          	auipc	ra,0x0
    80002522:	f10080e7          	jalr	-240(ra) # 8000242e <reparent>
  wakeup(p->parent);
    80002526:	0389b503          	ld	a0,56(s3)
    8000252a:	00000097          	auipc	ra,0x0
    8000252e:	e8e080e7          	jalr	-370(ra) # 800023b8 <wakeup>
  acquire(&p->lock);
    80002532:	854e                	mv	a0,s3
    80002534:	ffffe097          	auipc	ra,0xffffe
    80002538:	68e080e7          	jalr	1678(ra) # 80000bc2 <acquire>
  p->xstate = status;
    8000253c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002540:	4795                	li	a5,5
    80002542:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002546:	8526                	mv	a0,s1
    80002548:	ffffe097          	auipc	ra,0xffffe
    8000254c:	72e080e7          	jalr	1838(ra) # 80000c76 <release>
  sched();
    80002550:	00000097          	auipc	ra,0x0
    80002554:	bca080e7          	jalr	-1078(ra) # 8000211a <sched>
  panic("zombie exit");
    80002558:	00007517          	auipc	a0,0x7
    8000255c:	f2850513          	addi	a0,a0,-216 # 80009480 <digits+0x440>
    80002560:	ffffe097          	auipc	ra,0xffffe
    80002564:	fca080e7          	jalr	-54(ra) # 8000052a <panic>

0000000080002568 <kill>:
{
    80002568:	7179                	addi	sp,sp,-48
    8000256a:	f406                	sd	ra,40(sp)
    8000256c:	f022                	sd	s0,32(sp)
    8000256e:	ec26                	sd	s1,24(sp)
    80002570:	e84a                	sd	s2,16(sp)
    80002572:	e44e                	sd	s3,8(sp)
    80002574:	1800                	addi	s0,sp,48
    80002576:	892a                	mv	s2,a0
  for (p = proc; p < &proc[NPROC]; p++)
    80002578:	00010497          	auipc	s1,0x10
    8000257c:	15848493          	addi	s1,s1,344 # 800126d0 <proc>
    80002580:	00022997          	auipc	s3,0x22
    80002584:	55098993          	addi	s3,s3,1360 # 80024ad0 <tickslock>
    acquire(&p->lock);
    80002588:	8526                	mv	a0,s1
    8000258a:	ffffe097          	auipc	ra,0xffffe
    8000258e:	638080e7          	jalr	1592(ra) # 80000bc2 <acquire>
    if (p->pid == pid)
    80002592:	589c                	lw	a5,48(s1)
    80002594:	01278d63          	beq	a5,s2,800025ae <kill+0x46>
    release(&p->lock);
    80002598:	8526                	mv	a0,s1
    8000259a:	ffffe097          	auipc	ra,0xffffe
    8000259e:	6dc080e7          	jalr	1756(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800025a2:	49048493          	addi	s1,s1,1168
    800025a6:	ff3491e3          	bne	s1,s3,80002588 <kill+0x20>
  return -1;
    800025aa:	557d                	li	a0,-1
    800025ac:	a829                	j	800025c6 <kill+0x5e>
      p->killed = 1;
    800025ae:	4785                	li	a5,1
    800025b0:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800025b2:	4c98                	lw	a4,24(s1)
    800025b4:	4789                	li	a5,2
    800025b6:	00f70f63          	beq	a4,a5,800025d4 <kill+0x6c>
      release(&p->lock);
    800025ba:	8526                	mv	a0,s1
    800025bc:	ffffe097          	auipc	ra,0xffffe
    800025c0:	6ba080e7          	jalr	1722(ra) # 80000c76 <release>
      return 0;
    800025c4:	4501                	li	a0,0
}
    800025c6:	70a2                	ld	ra,40(sp)
    800025c8:	7402                	ld	s0,32(sp)
    800025ca:	64e2                	ld	s1,24(sp)
    800025cc:	6942                	ld	s2,16(sp)
    800025ce:	69a2                	ld	s3,8(sp)
    800025d0:	6145                	addi	sp,sp,48
    800025d2:	8082                	ret
        p->state = RUNNABLE;
    800025d4:	478d                	li	a5,3
    800025d6:	cc9c                	sw	a5,24(s1)
    800025d8:	b7cd                	j	800025ba <kill+0x52>

00000000800025da <either_copyout>:
{
    800025da:	7179                	addi	sp,sp,-48
    800025dc:	f406                	sd	ra,40(sp)
    800025de:	f022                	sd	s0,32(sp)
    800025e0:	ec26                	sd	s1,24(sp)
    800025e2:	e84a                	sd	s2,16(sp)
    800025e4:	e44e                	sd	s3,8(sp)
    800025e6:	e052                	sd	s4,0(sp)
    800025e8:	1800                	addi	s0,sp,48
    800025ea:	84aa                	mv	s1,a0
    800025ec:	892e                	mv	s2,a1
    800025ee:	89b2                	mv	s3,a2
    800025f0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025f2:	fffff097          	auipc	ra,0xfffff
    800025f6:	742080e7          	jalr	1858(ra) # 80001d34 <myproc>
  if (user_dst)
    800025fa:	c08d                	beqz	s1,8000261c <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800025fc:	86d2                	mv	a3,s4
    800025fe:	864e                	mv	a2,s3
    80002600:	85ca                	mv	a1,s2
    80002602:	6928                	ld	a0,80(a0)
    80002604:	fffff097          	auipc	ra,0xfffff
    80002608:	d8e080e7          	jalr	-626(ra) # 80001392 <copyout>
}
    8000260c:	70a2                	ld	ra,40(sp)
    8000260e:	7402                	ld	s0,32(sp)
    80002610:	64e2                	ld	s1,24(sp)
    80002612:	6942                	ld	s2,16(sp)
    80002614:	69a2                	ld	s3,8(sp)
    80002616:	6a02                	ld	s4,0(sp)
    80002618:	6145                	addi	sp,sp,48
    8000261a:	8082                	ret
    memmove((char *)dst, src, len);
    8000261c:	000a061b          	sext.w	a2,s4
    80002620:	85ce                	mv	a1,s3
    80002622:	854a                	mv	a0,s2
    80002624:	ffffe097          	auipc	ra,0xffffe
    80002628:	6f6080e7          	jalr	1782(ra) # 80000d1a <memmove>
    return 0;
    8000262c:	8526                	mv	a0,s1
    8000262e:	bff9                	j	8000260c <either_copyout+0x32>

0000000080002630 <either_copyin>:
{
    80002630:	7179                	addi	sp,sp,-48
    80002632:	f406                	sd	ra,40(sp)
    80002634:	f022                	sd	s0,32(sp)
    80002636:	ec26                	sd	s1,24(sp)
    80002638:	e84a                	sd	s2,16(sp)
    8000263a:	e44e                	sd	s3,8(sp)
    8000263c:	e052                	sd	s4,0(sp)
    8000263e:	1800                	addi	s0,sp,48
    80002640:	892a                	mv	s2,a0
    80002642:	84ae                	mv	s1,a1
    80002644:	89b2                	mv	s3,a2
    80002646:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002648:	fffff097          	auipc	ra,0xfffff
    8000264c:	6ec080e7          	jalr	1772(ra) # 80001d34 <myproc>
  if (user_src)
    80002650:	c08d                	beqz	s1,80002672 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002652:	86d2                	mv	a3,s4
    80002654:	864e                	mv	a2,s3
    80002656:	85ca                	mv	a1,s2
    80002658:	6928                	ld	a0,80(a0)
    8000265a:	fffff097          	auipc	ra,0xfffff
    8000265e:	dc6080e7          	jalr	-570(ra) # 80001420 <copyin>
}
    80002662:	70a2                	ld	ra,40(sp)
    80002664:	7402                	ld	s0,32(sp)
    80002666:	64e2                	ld	s1,24(sp)
    80002668:	6942                	ld	s2,16(sp)
    8000266a:	69a2                	ld	s3,8(sp)
    8000266c:	6a02                	ld	s4,0(sp)
    8000266e:	6145                	addi	sp,sp,48
    80002670:	8082                	ret
    memmove(dst, (char *)src, len);
    80002672:	000a061b          	sext.w	a2,s4
    80002676:	85ce                	mv	a1,s3
    80002678:	854a                	mv	a0,s2
    8000267a:	ffffe097          	auipc	ra,0xffffe
    8000267e:	6a0080e7          	jalr	1696(ra) # 80000d1a <memmove>
    return 0;
    80002682:	8526                	mv	a0,s1
    80002684:	bff9                	j	80002662 <either_copyin+0x32>

0000000080002686 <procdump>:
{
    80002686:	715d                	addi	sp,sp,-80
    80002688:	e486                	sd	ra,72(sp)
    8000268a:	e0a2                	sd	s0,64(sp)
    8000268c:	fc26                	sd	s1,56(sp)
    8000268e:	f84a                	sd	s2,48(sp)
    80002690:	f44e                	sd	s3,40(sp)
    80002692:	f052                	sd	s4,32(sp)
    80002694:	ec56                	sd	s5,24(sp)
    80002696:	e85a                	sd	s6,16(sp)
    80002698:	e45e                	sd	s7,8(sp)
    8000269a:	0880                	addi	s0,sp,80
  printf("\n");
    8000269c:	00007517          	auipc	a0,0x7
    800026a0:	f6450513          	addi	a0,a0,-156 # 80009600 <digits+0x5c0>
    800026a4:	ffffe097          	auipc	ra,0xffffe
    800026a8:	ed0080e7          	jalr	-304(ra) # 80000574 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800026ac:	00010497          	auipc	s1,0x10
    800026b0:	17c48493          	addi	s1,s1,380 # 80012828 <proc+0x158>
    800026b4:	00022917          	auipc	s2,0x22
    800026b8:	57490913          	addi	s2,s2,1396 # 80024c28 <bcache+0x140>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026bc:	4b15                	li	s6,5
      state = "???";
    800026be:	00007997          	auipc	s3,0x7
    800026c2:	dd298993          	addi	s3,s3,-558 # 80009490 <digits+0x450>
    printf("%d %s %s", p->pid, state, p->name);
    800026c6:	00007a97          	auipc	s5,0x7
    800026ca:	dd2a8a93          	addi	s5,s5,-558 # 80009498 <digits+0x458>
    printf("\n");
    800026ce:	00007a17          	auipc	s4,0x7
    800026d2:	f32a0a13          	addi	s4,s4,-206 # 80009600 <digits+0x5c0>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026d6:	00007b97          	auipc	s7,0x7
    800026da:	feab8b93          	addi	s7,s7,-22 # 800096c0 <states.0>
    800026de:	a00d                	j	80002700 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026e0:	ed86a583          	lw	a1,-296(a3)
    800026e4:	8556                	mv	a0,s5
    800026e6:	ffffe097          	auipc	ra,0xffffe
    800026ea:	e8e080e7          	jalr	-370(ra) # 80000574 <printf>
    printf("\n");
    800026ee:	8552                	mv	a0,s4
    800026f0:	ffffe097          	auipc	ra,0xffffe
    800026f4:	e84080e7          	jalr	-380(ra) # 80000574 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800026f8:	49048493          	addi	s1,s1,1168
    800026fc:	03248263          	beq	s1,s2,80002720 <procdump+0x9a>
    if (p->state == UNUSED)
    80002700:	86a6                	mv	a3,s1
    80002702:	ec04a783          	lw	a5,-320(s1)
    80002706:	dbed                	beqz	a5,800026f8 <procdump+0x72>
      state = "???";
    80002708:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000270a:	fcfb6be3          	bltu	s6,a5,800026e0 <procdump+0x5a>
    8000270e:	02079713          	slli	a4,a5,0x20
    80002712:	01d75793          	srli	a5,a4,0x1d
    80002716:	97de                	add	a5,a5,s7
    80002718:	6390                	ld	a2,0(a5)
    8000271a:	f279                	bnez	a2,800026e0 <procdump+0x5a>
      state = "???";
    8000271c:	864e                	mv	a2,s3
    8000271e:	b7c9                	j	800026e0 <procdump+0x5a>
}
    80002720:	60a6                	ld	ra,72(sp)
    80002722:	6406                	ld	s0,64(sp)
    80002724:	74e2                	ld	s1,56(sp)
    80002726:	7942                	ld	s2,48(sp)
    80002728:	79a2                	ld	s3,40(sp)
    8000272a:	7a02                	ld	s4,32(sp)
    8000272c:	6ae2                	ld	s5,24(sp)
    8000272e:	6b42                	ld	s6,16(sp)
    80002730:	6ba2                	ld	s7,8(sp)
    80002732:	6161                	addi	sp,sp,80
    80002734:	8082                	ret

0000000080002736 <get_next_free_space>:
{
    80002736:	1141                	addi	sp,sp,-16
    80002738:	e422                	sd	s0,8(sp)
    8000273a:	0800                	addi	s0,sp,16
    if (!(free_spaces & (1 << i)))
    8000273c:	0005071b          	sext.w	a4,a0
    80002740:	8905                	andi	a0,a0,1
    80002742:	cd11                	beqz	a0,8000275e <get_next_free_space+0x28>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002744:	4505                	li	a0,1
    80002746:	46c1                	li	a3,16
    if (!(free_spaces & (1 << i)))
    80002748:	40a757bb          	sraw	a5,a4,a0
    8000274c:	8b85                	andi	a5,a5,1
    8000274e:	c789                	beqz	a5,80002758 <get_next_free_space+0x22>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002750:	2505                	addiw	a0,a0,1
    80002752:	fed51be3          	bne	a0,a3,80002748 <get_next_free_space+0x12>
  return -1;
    80002756:	557d                	li	a0,-1
}
    80002758:	6422                	ld	s0,8(sp)
    8000275a:	0141                	addi	sp,sp,16
    8000275c:	8082                	ret
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000275e:	4501                	li	a0,0
    80002760:	bfe5                	j	80002758 <get_next_free_space+0x22>

0000000080002762 <get_index_in_page_info_array>:
{
    80002762:	1141                	addi	sp,sp,-16
    80002764:	e422                	sd	s0,8(sp)
    80002766:	0800                	addi	s0,sp,16
  uint64 rva = PGROUNDDOWN(va);
    80002768:	777d                	lui	a4,0xfffff
    8000276a:	8f69                	and	a4,a4,a0
  for (int i = 0; i < MAX_PSYC_PAGES;i++)
    8000276c:	4501                	li	a0,0
    8000276e:	46c1                	li	a3,16
    if (po->va == rva)
    80002770:	619c                	ld	a5,0(a1)
    80002772:	00e78763          	beq	a5,a4,80002780 <get_index_in_page_info_array+0x1e>
  for (int i = 0; i < MAX_PSYC_PAGES;i++)
    80002776:	2505                	addiw	a0,a0,1
    80002778:	05e1                	addi	a1,a1,24
    8000277a:	fed51be3          	bne	a0,a3,80002770 <get_index_in_page_info_array+0xe>
  return -1; // if not found return null
    8000277e:	557d                	li	a0,-1
}
    80002780:	6422                	ld	s0,8(sp)
    80002782:	0141                	addi	sp,sp,16
    80002784:	8082                	ret

0000000080002786 <page_out>:
{
    80002786:	7179                	addi	sp,sp,-48
    80002788:	f406                	sd	ra,40(sp)
    8000278a:	f022                	sd	s0,32(sp)
    8000278c:	ec26                	sd	s1,24(sp)
    8000278e:	e84a                	sd	s2,16(sp)
    80002790:	e44e                	sd	s3,8(sp)
    80002792:	1800                	addi	s0,sp,48
    80002794:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002796:	fffff097          	auipc	ra,0xfffff
    8000279a:	59e080e7          	jalr	1438(ra) # 80001d34 <myproc>
    8000279e:	892a                	mv	s2,a0
  uint64 rva = PGROUNDDOWN(va);
    800027a0:	757d                	lui	a0,0xfffff
    800027a2:	8ce9                	and	s1,s1,a0
  uint64 pa = walkaddr(p->pagetable, rva, 1); // return with pte valid = 0
    800027a4:	4605                	li	a2,1
    800027a6:	85a6                	mv	a1,s1
    800027a8:	05093503          	ld	a0,80(s2)
    800027ac:	fffff097          	auipc	ra,0xfffff
    800027b0:	8a0080e7          	jalr	-1888(ra) # 8000104c <walkaddr>
    800027b4:	89aa                	mv	s3,a0
  int page_index = insert_page_to_swap_file(rva);
    800027b6:	8526                	mv	a0,s1
    800027b8:	fffff097          	auipc	ra,0xfffff
    800027bc:	dae080e7          	jalr	-594(ra) # 80001566 <insert_page_to_swap_file>
  if (page_index < 0 || page_index >= MAX_PSYC_PAGES)
    800027c0:	0005079b          	sext.w	a5,a0
    800027c4:	473d                	li	a4,15
    800027c6:	04f76363          	bltu	a4,a5,8000280c <page_out+0x86>
    800027ca:	00c5161b          	slliw	a2,a0,0xc
  writeToSwapFile(p, (char *)pa, start_offset, PGSIZE); // Write page to swap file
    800027ce:	6685                	lui	a3,0x1
    800027d0:	2601                	sext.w	a2,a2
    800027d2:	85ce                	mv	a1,s3
    800027d4:	854a                	mv	a0,s2
    800027d6:	00002097          	auipc	ra,0x2
    800027da:	33e080e7          	jalr	830(ra) # 80004b14 <writeToSwapFile>
  remove_page_from_physical_memory(rva);
    800027de:	8526                	mv	a0,s1
    800027e0:	fffff097          	auipc	ra,0xfffff
    800027e4:	eb0080e7          	jalr	-336(ra) # 80001690 <remove_page_from_physical_memory>
  p->physical_pages_num--;
    800027e8:	17092783          	lw	a5,368(s2)
    800027ec:	37fd                	addiw	a5,a5,-1
    800027ee:	16f92823          	sw	a5,368(s2)
  kfree((void *)pa);
    800027f2:	854e                	mv	a0,s3
    800027f4:	ffffe097          	auipc	ra,0xffffe
    800027f8:	1e2080e7          	jalr	482(ra) # 800009d6 <kfree>
}
    800027fc:	854e                	mv	a0,s3
    800027fe:	70a2                	ld	ra,40(sp)
    80002800:	7402                	ld	s0,32(sp)
    80002802:	64e2                	ld	s1,24(sp)
    80002804:	6942                	ld	s2,16(sp)
    80002806:	69a2                	ld	s3,8(sp)
    80002808:	6145                	addi	sp,sp,48
    8000280a:	8082                	ret
    panic("fadge no free index in page_out");
    8000280c:	00007517          	auipc	a0,0x7
    80002810:	c9c50513          	addi	a0,a0,-868 # 800094a8 <digits+0x468>
    80002814:	ffffe097          	auipc	ra,0xffffe
    80002818:	d16080e7          	jalr	-746(ra) # 8000052a <panic>

000000008000281c <page_in>:
{
    8000281c:	7139                	addi	sp,sp,-64
    8000281e:	fc06                	sd	ra,56(sp)
    80002820:	f822                	sd	s0,48(sp)
    80002822:	f426                	sd	s1,40(sp)
    80002824:	f04a                	sd	s2,32(sp)
    80002826:	ec4e                	sd	s3,24(sp)
    80002828:	e852                	sd	s4,16(sp)
    8000282a:	e456                	sd	s5,8(sp)
    8000282c:	e05a                	sd	s6,0(sp)
    8000282e:	0080                	addi	s0,sp,64
    80002830:	8b2a                	mv	s6,a0
    80002832:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80002834:	fffff097          	auipc	ra,0xfffff
    80002838:	500080e7          	jalr	1280(ra) # 80001d34 <myproc>
    8000283c:	892a                	mv	s2,a0
  uint64 rva = PGROUNDDOWN(va);
    8000283e:	7afd                	lui	s5,0xfffff
    80002840:	015b7ab3          	and	s5,s6,s5
  int swap_old_index = remove_page_from_swap_file(rva);
    80002844:	8556                	mv	a0,s5
    80002846:	fffff097          	auipc	ra,0xfffff
    8000284a:	eb2080e7          	jalr	-334(ra) # 800016f8 <remove_page_from_swap_file>
  if(swap_old_index <0)
    8000284e:	06054c63          	bltz	a0,800028c6 <page_in+0xaa>
    80002852:	8a2a                	mv	s4,a0
  if ((pa = (uint64)kalloc()) == 0){
    80002854:	ffffe097          	auipc	ra,0xffffe
    80002858:	27e080e7          	jalr	638(ra) # 80000ad2 <kalloc>
    8000285c:	89aa                	mv	s3,a0
    8000285e:	cd25                	beqz	a0,800028d6 <page_in+0xba>
  mappages(p->pagetable, va, PGSIZE, (uint64)pa, PTE_FLAGS(*pte));
    80002860:	6098                	ld	a4,0(s1)
    80002862:	3ff77713          	andi	a4,a4,1023
    80002866:	86aa                	mv	a3,a0
    80002868:	6605                	lui	a2,0x1
    8000286a:	85da                	mv	a1,s6
    8000286c:	05093503          	ld	a0,80(s2)
    80002870:	fffff097          	auipc	ra,0xfffff
    80002874:	832080e7          	jalr	-1998(ra) # 800010a2 <mappages>
  int physc_new_index = insert_page_to_physical_memory(rva);
    80002878:	8556                	mv	a0,s5
    8000287a:	fffff097          	auipc	ra,0xfffff
    8000287e:	d6c080e7          	jalr	-660(ra) # 800015e6 <insert_page_to_physical_memory>
  p->physical_pages_num++;
    80002882:	17092783          	lw	a5,368(s2)
    80002886:	2785                	addiw	a5,a5,1
    80002888:	16f92823          	sw	a5,368(s2)
  readFromSwapFile(p, (char*)pa, start_offset, PGSIZE);
    8000288c:	6685                	lui	a3,0x1
    8000288e:	00ca161b          	slliw	a2,s4,0xc
    80002892:	85ce                	mv	a1,s3
    80002894:	854a                	mv	a0,s2
    80002896:	00002097          	auipc	ra,0x2
    8000289a:	2a2080e7          	jalr	674(ra) # 80004b38 <readFromSwapFile>
  if (!(*pte & PTE_PG))
    8000289e:	609c                	ld	a5,0(s1)
    800028a0:	2007f713          	andi	a4,a5,512
    800028a4:	c339                	beqz	a4,800028ea <page_in+0xce>
  *pte = (*pte | PTE_V) &(~PTE_PG);
    800028a6:	dfe7f793          	andi	a5,a5,-514
    800028aa:	0017e793          	ori	a5,a5,1
    800028ae:	e09c                	sd	a5,0(s1)
  return pte;
    800028b0:	8526                	mv	a0,s1
}
    800028b2:	70e2                	ld	ra,56(sp)
    800028b4:	7442                	ld	s0,48(sp)
    800028b6:	74a2                	ld	s1,40(sp)
    800028b8:	7902                	ld	s2,32(sp)
    800028ba:	69e2                	ld	s3,24(sp)
    800028bc:	6a42                	ld	s4,16(sp)
    800028be:	6aa2                	ld	s5,8(sp)
    800028c0:	6b02                	ld	s6,0(sp)
    800028c2:	6121                	addi	sp,sp,64
    800028c4:	8082                	ret
    panic("page_in: index in swap file not found");
    800028c6:	00007517          	auipc	a0,0x7
    800028ca:	c0250513          	addi	a0,a0,-1022 # 800094c8 <digits+0x488>
    800028ce:	ffffe097          	auipc	ra,0xffffe
    800028d2:	c5c080e7          	jalr	-932(ra) # 8000052a <panic>
    printf("retrievingpage: kalloc failed\n");
    800028d6:	00007517          	auipc	a0,0x7
    800028da:	c1a50513          	addi	a0,a0,-998 # 800094f0 <digits+0x4b0>
    800028de:	ffffe097          	auipc	ra,0xffffe
    800028e2:	c96080e7          	jalr	-874(ra) # 80000574 <printf>
    return -1;
    800028e6:	557d                	li	a0,-1
    800028e8:	b7e9                	j	800028b2 <page_in+0x96>
    panic("page in: page out flag was off");
    800028ea:	00007517          	auipc	a0,0x7
    800028ee:	c2650513          	addi	a0,a0,-986 # 80009510 <digits+0x4d0>
    800028f2:	ffffe097          	auipc	ra,0xffffe
    800028f6:	c38080e7          	jalr	-968(ra) # 8000052a <panic>

00000000800028fa <copyFilesInfo>:
{
    800028fa:	7139                	addi	sp,sp,-64
    800028fc:	fc06                	sd	ra,56(sp)
    800028fe:	f822                	sd	s0,48(sp)
    80002900:	f426                	sd	s1,40(sp)
    80002902:	f04a                	sd	s2,32(sp)
    80002904:	ec4e                	sd	s3,24(sp)
    80002906:	e852                	sd	s4,16(sp)
    80002908:	e456                	sd	s5,8(sp)
    8000290a:	e05a                	sd	s6,0(sp)
    8000290c:	0080                	addi	s0,sp,64
    8000290e:	89aa                	mv	s3,a0
    80002910:	84ae                	mv	s1,a1
  if (!(temp_page = kalloc()))
    80002912:	ffffe097          	auipc	ra,0xffffe
    80002916:	1c0080e7          	jalr	448(ra) # 80000ad2 <kalloc>
    8000291a:	8b2a                	mv	s6,a0
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000291c:	4901                	li	s2,0
    8000291e:	4a41                	li	s4,16
  if (!(temp_page = kalloc()))
    80002920:	e505                	bnez	a0,80002948 <copyFilesInfo+0x4e>
    panic("copyFilesInfo: kalloc failed");
    80002922:	00007517          	auipc	a0,0x7
    80002926:	c0e50513          	addi	a0,a0,-1010 # 80009530 <digits+0x4f0>
    8000292a:	ffffe097          	auipc	ra,0xffffe
    8000292e:	c00080e7          	jalr	-1024(ra) # 8000052a <panic>
        panic("copyFilesInfo: failed read");
    80002932:	00007517          	auipc	a0,0x7
    80002936:	c1e50513          	addi	a0,a0,-994 # 80009550 <digits+0x510>
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	bf0080e7          	jalr	-1040(ra) # 8000052a <panic>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002942:	2905                	addiw	s2,s2,1
    80002944:	05490663          	beq	s2,s4,80002990 <copyFilesInfo+0x96>
    if (p->pages_swap_info.free_spaces & (1 << i))
    80002948:	1789d783          	lhu	a5,376(s3)
    8000294c:	4127d7bb          	sraw	a5,a5,s2
    80002950:	8b85                	andi	a5,a5,1
    80002952:	dbe5                	beqz	a5,80002942 <copyFilesInfo+0x48>
      int res = readFromSwapFile(p, (char *)temp_page, i * PGSIZE, PGSIZE);
    80002954:	00c91a9b          	slliw	s5,s2,0xc
    80002958:	6685                	lui	a3,0x1
    8000295a:	8656                	mv	a2,s5
    8000295c:	85da                	mv	a1,s6
    8000295e:	854e                	mv	a0,s3
    80002960:	00002097          	auipc	ra,0x2
    80002964:	1d8080e7          	jalr	472(ra) # 80004b38 <readFromSwapFile>
      if (res < 0)
    80002968:	fc0545e3          	bltz	a0,80002932 <copyFilesInfo+0x38>
      res = writeToSwapFile(np, temp_page, i * PGSIZE, PGSIZE);
    8000296c:	6685                	lui	a3,0x1
    8000296e:	8656                	mv	a2,s5
    80002970:	85da                	mv	a1,s6
    80002972:	8526                	mv	a0,s1
    80002974:	00002097          	auipc	ra,0x2
    80002978:	1a0080e7          	jalr	416(ra) # 80004b14 <writeToSwapFile>
      if (res < 0)
    8000297c:	fc0553e3          	bgez	a0,80002942 <copyFilesInfo+0x48>
        panic("copyFilesInfo: faild write ");
    80002980:	00007517          	auipc	a0,0x7
    80002984:	bf050513          	addi	a0,a0,-1040 # 80009570 <digits+0x530>
    80002988:	ffffe097          	auipc	ra,0xffffe
    8000298c:	ba2080e7          	jalr	-1118(ra) # 8000052a <panic>
  kfree(temp_page);
    80002990:	855a                	mv	a0,s6
    80002992:	ffffe097          	auipc	ra,0xffffe
    80002996:	044080e7          	jalr	68(ra) # 800009d6 <kfree>
  np->pages_swap_info.free_spaces = p->pages_swap_info.free_spaces;
    8000299a:	1789d783          	lhu	a5,376(s3)
    8000299e:	16f49c23          	sh	a5,376(s1)
  np->pages_physc_info.free_spaces = p->pages_physc_info.free_spaces;
    800029a2:	3009d783          	lhu	a5,768(s3)
    800029a6:	30f49023          	sh	a5,768(s1)
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    800029aa:	18098793          	addi	a5,s3,384
    800029ae:	18048593          	addi	a1,s1,384
    800029b2:	30098993          	addi	s3,s3,768
    np->pages_swap_info.pages[i] = p->pages_swap_info.pages[i];
    800029b6:	6398                	ld	a4,0(a5)
    800029b8:	e198                	sd	a4,0(a1)
    800029ba:	6798                	ld	a4,8(a5)
    800029bc:	e598                	sd	a4,8(a1)
    800029be:	6b98                	ld	a4,16(a5)
    800029c0:	e998                	sd	a4,16(a1)
    np->pages_physc_info.pages[i] = p->pages_physc_info.pages[i];
    800029c2:	1887b703          	ld	a4,392(a5)
    800029c6:	18e5b423          	sd	a4,392(a1)
    800029ca:	1907b703          	ld	a4,400(a5)
    800029ce:	18e5b823          	sd	a4,400(a1)
    800029d2:	1987b703          	ld	a4,408(a5)
    800029d6:	18e5bc23          	sd	a4,408(a1)
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    800029da:	07e1                	addi	a5,a5,24
    800029dc:	05e1                	addi	a1,a1,24
    800029de:	fd379ce3          	bne	a5,s3,800029b6 <copyFilesInfo+0xbc>
}
    800029e2:	70e2                	ld	ra,56(sp)
    800029e4:	7442                	ld	s0,48(sp)
    800029e6:	74a2                	ld	s1,40(sp)
    800029e8:	7902                	ld	s2,32(sp)
    800029ea:	69e2                	ld	s3,24(sp)
    800029ec:	6a42                	ld	s4,16(sp)
    800029ee:	6aa2                	ld	s5,8(sp)
    800029f0:	6b02                	ld	s6,0(sp)
    800029f2:	6121                	addi	sp,sp,64
    800029f4:	8082                	ret

00000000800029f6 <fork>:
{
    800029f6:	7139                	addi	sp,sp,-64
    800029f8:	fc06                	sd	ra,56(sp)
    800029fa:	f822                	sd	s0,48(sp)
    800029fc:	f426                	sd	s1,40(sp)
    800029fe:	f04a                	sd	s2,32(sp)
    80002a00:	ec4e                	sd	s3,24(sp)
    80002a02:	e852                	sd	s4,16(sp)
    80002a04:	e456                	sd	s5,8(sp)
    80002a06:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002a08:	fffff097          	auipc	ra,0xfffff
    80002a0c:	32c080e7          	jalr	812(ra) # 80001d34 <myproc>
    80002a10:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80002a12:	fffff097          	auipc	ra,0xfffff
    80002a16:	530080e7          	jalr	1328(ra) # 80001f42 <allocproc>
    80002a1a:	12050f63          	beqz	a0,80002b58 <fork+0x162>
    80002a1e:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002a20:	048ab603          	ld	a2,72(s5) # fffffffffffff048 <end+0xffffffff7ffcc048>
    80002a24:	692c                	ld	a1,80(a0)
    80002a26:	050ab503          	ld	a0,80(s5)
    80002a2a:	fffff097          	auipc	ra,0xfffff
    80002a2e:	07c080e7          	jalr	124(ra) # 80001aa6 <uvmcopy>
    80002a32:	04054863          	bltz	a0,80002a82 <fork+0x8c>
  np->sz = p->sz;
    80002a36:	048ab783          	ld	a5,72(s5)
    80002a3a:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80002a3e:	058ab683          	ld	a3,88(s5)
    80002a42:	87b6                	mv	a5,a3
    80002a44:	0589b703          	ld	a4,88(s3)
    80002a48:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    80002a4c:	0007b803          	ld	a6,0(a5)
    80002a50:	6788                	ld	a0,8(a5)
    80002a52:	6b8c                	ld	a1,16(a5)
    80002a54:	6f90                	ld	a2,24(a5)
    80002a56:	01073023          	sd	a6,0(a4) # fffffffffffff000 <end+0xffffffff7ffcc000>
    80002a5a:	e708                	sd	a0,8(a4)
    80002a5c:	eb0c                	sd	a1,16(a4)
    80002a5e:	ef10                	sd	a2,24(a4)
    80002a60:	02078793          	addi	a5,a5,32
    80002a64:	02070713          	addi	a4,a4,32
    80002a68:	fed792e3          	bne	a5,a3,80002a4c <fork+0x56>
  np->trapframe->a0 = 0;
    80002a6c:	0589b783          	ld	a5,88(s3)
    80002a70:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80002a74:	0d0a8493          	addi	s1,s5,208
    80002a78:	0d098913          	addi	s2,s3,208
    80002a7c:	150a8a13          	addi	s4,s5,336
    80002a80:	a00d                	j	80002aa2 <fork+0xac>
    freeproc(np);
    80002a82:	854e                	mv	a0,s3
    80002a84:	fffff097          	auipc	ra,0xfffff
    80002a88:	462080e7          	jalr	1122(ra) # 80001ee6 <freeproc>
    release(&np->lock);
    80002a8c:	854e                	mv	a0,s3
    80002a8e:	ffffe097          	auipc	ra,0xffffe
    80002a92:	1e8080e7          	jalr	488(ra) # 80000c76 <release>
    return -1;
    80002a96:	597d                	li	s2,-1
    80002a98:	a075                	j	80002b44 <fork+0x14e>
  for (i = 0; i < NOFILE; i++)
    80002a9a:	04a1                	addi	s1,s1,8
    80002a9c:	0921                	addi	s2,s2,8
    80002a9e:	01448b63          	beq	s1,s4,80002ab4 <fork+0xbe>
    if (p->ofile[i])
    80002aa2:	6088                	ld	a0,0(s1)
    80002aa4:	d97d                	beqz	a0,80002a9a <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80002aa6:	00002097          	auipc	ra,0x2
    80002aaa:	716080e7          	jalr	1814(ra) # 800051bc <filedup>
    80002aae:	00a93023          	sd	a0,0(s2)
    80002ab2:	b7e5                	j	80002a9a <fork+0xa4>
  np->cwd = idup(p->cwd);
    80002ab4:	150ab503          	ld	a0,336(s5)
    80002ab8:	00001097          	auipc	ra,0x1
    80002abc:	564080e7          	jalr	1380(ra) # 8000401c <idup>
    80002ac0:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002ac4:	4641                	li	a2,16
    80002ac6:	158a8593          	addi	a1,s5,344
    80002aca:	15898513          	addi	a0,s3,344
    80002ace:	ffffe097          	auipc	ra,0xffffe
    80002ad2:	342080e7          	jalr	834(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80002ad6:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002ada:	854e                	mv	a0,s3
    80002adc:	ffffe097          	auipc	ra,0xffffe
    80002ae0:	19a080e7          	jalr	410(ra) # 80000c76 <release>
  createSwapFile(np);
    80002ae4:	854e                	mv	a0,s3
    80002ae6:	00002097          	auipc	ra,0x2
    80002aea:	f7e080e7          	jalr	-130(ra) # 80004a64 <createSwapFile>
    copyFilesInfo(p, np); // TODO: check we need to this for father 1,2 
    80002aee:	85ce                	mv	a1,s3
    80002af0:	8556                	mv	a0,s5
    80002af2:	00000097          	auipc	ra,0x0
    80002af6:	e08080e7          	jalr	-504(ra) # 800028fa <copyFilesInfo>
  np->physical_pages_num = p->physical_pages_num;
    80002afa:	170aa783          	lw	a5,368(s5)
    80002afe:	16f9a823          	sw	a5,368(s3)
  np->total_pages_num = p->total_pages_num;
    80002b02:	174aa783          	lw	a5,372(s5)
    80002b06:	16f9aa23          	sw	a5,372(s3)
  acquire(&wait_lock);
    80002b0a:	0000f497          	auipc	s1,0xf
    80002b0e:	7ae48493          	addi	s1,s1,1966 # 800122b8 <wait_lock>
    80002b12:	8526                	mv	a0,s1
    80002b14:	ffffe097          	auipc	ra,0xffffe
    80002b18:	0ae080e7          	jalr	174(ra) # 80000bc2 <acquire>
  np->parent = p;
    80002b1c:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002b20:	8526                	mv	a0,s1
    80002b22:	ffffe097          	auipc	ra,0xffffe
    80002b26:	154080e7          	jalr	340(ra) # 80000c76 <release>
  acquire(&np->lock);
    80002b2a:	854e                	mv	a0,s3
    80002b2c:	ffffe097          	auipc	ra,0xffffe
    80002b30:	096080e7          	jalr	150(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80002b34:	478d                	li	a5,3
    80002b36:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002b3a:	854e                	mv	a0,s3
    80002b3c:	ffffe097          	auipc	ra,0xffffe
    80002b40:	13a080e7          	jalr	314(ra) # 80000c76 <release>
}
    80002b44:	854a                	mv	a0,s2
    80002b46:	70e2                	ld	ra,56(sp)
    80002b48:	7442                	ld	s0,48(sp)
    80002b4a:	74a2                	ld	s1,40(sp)
    80002b4c:	7902                	ld	s2,32(sp)
    80002b4e:	69e2                	ld	s3,24(sp)
    80002b50:	6a42                	ld	s4,16(sp)
    80002b52:	6aa2                	ld	s5,8(sp)
    80002b54:	6121                	addi	sp,sp,64
    80002b56:	8082                	ret
    return -1;
    80002b58:	597d                	li	s2,-1
    80002b5a:	b7ed                	j	80002b44 <fork+0x14e>

0000000080002b5c <SCFIFO_compare>:
  return res;
}

int SCFIFO_compare(struct page_info *pg1, struct page_info *pg2)
{
  if (!pg1 || !pg2)
    80002b5c:	c511                	beqz	a0,80002b68 <SCFIFO_compare+0xc>
    80002b5e:	c589                	beqz	a1,80002b68 <SCFIFO_compare+0xc>
    panic("SCFIFO_compare : null input");

  return pg1->time_inserted - pg2->time_inserted;
    80002b60:	4908                	lw	a0,16(a0)
    80002b62:	499c                	lw	a5,16(a1)
}
    80002b64:	9d1d                	subw	a0,a0,a5
    80002b66:	8082                	ret
{
    80002b68:	1141                	addi	sp,sp,-16
    80002b6a:	e406                	sd	ra,8(sp)
    80002b6c:	e022                	sd	s0,0(sp)
    80002b6e:	0800                	addi	s0,sp,16
    panic("SCFIFO_compare : null input");
    80002b70:	00007517          	auipc	a0,0x7
    80002b74:	a2050513          	addi	a0,a0,-1504 # 80009590 <digits+0x550>
    80002b78:	ffffe097          	auipc	ra,0xffffe
    80002b7c:	9b2080e7          	jalr	-1614(ra) # 8000052a <panic>

0000000080002b80 <countOnes>:

long countOnes(long n)
{
    80002b80:	1141                	addi	sp,sp,-16
    80002b82:	e422                	sd	s0,8(sp)
    80002b84:	0800                	addi	s0,sp,16
  int count = 0;
  while (n)
    80002b86:	c919                	beqz	a0,80002b9c <countOnes+0x1c>
    80002b88:	87aa                	mv	a5,a0
  int count = 0;
    80002b8a:	4501                	li	a0,0
  {
    count += n & 1;
    80002b8c:	0017f713          	andi	a4,a5,1
    80002b90:	9d39                	addw	a0,a0,a4
    n >>= 1;
    80002b92:	8785                	srai	a5,a5,0x1
  while (n)
    80002b94:	ffe5                	bnez	a5,80002b8c <countOnes+0xc>
  }
  return count;
}
    80002b96:	6422                	ld	s0,8(sp)
    80002b98:	0141                	addi	sp,sp,16
    80002b9a:	8082                	ret
  int count = 0;
    80002b9c:	4501                	li	a0,0
    80002b9e:	bfe5                	j	80002b96 <countOnes+0x16>

0000000080002ba0 <LAPA_compare>:
{
    80002ba0:	7179                	addi	sp,sp,-48
    80002ba2:	f406                	sd	ra,40(sp)
    80002ba4:	f022                	sd	s0,32(sp)
    80002ba6:	ec26                	sd	s1,24(sp)
    80002ba8:	e84a                	sd	s2,16(sp)
    80002baa:	e44e                	sd	s3,8(sp)
    80002bac:	1800                	addi	s0,sp,48
  if (!pg1 || !pg2)
    80002bae:	cd0d                	beqz	a0,80002be8 <LAPA_compare+0x48>
    80002bb0:	892e                	mv	s2,a1
    80002bb2:	c99d                	beqz	a1,80002be8 <LAPA_compare+0x48>
  int res = countOnes(pg1->aging_counter) - countOnes(pg2->aging_counter);
    80002bb4:	00853983          	ld	s3,8(a0)
    80002bb8:	854e                	mv	a0,s3
    80002bba:	00000097          	auipc	ra,0x0
    80002bbe:	fc6080e7          	jalr	-58(ra) # 80002b80 <countOnes>
    80002bc2:	84aa                	mv	s1,a0
    80002bc4:	00893903          	ld	s2,8(s2)
    80002bc8:	854a                	mv	a0,s2
    80002bca:	00000097          	auipc	ra,0x0
    80002bce:	fb6080e7          	jalr	-74(ra) # 80002b80 <countOnes>
    80002bd2:	40a487bb          	subw	a5,s1,a0
  return res;
    80002bd6:	853e                	mv	a0,a5
  if (res == 0)
    80002bd8:	c385                	beqz	a5,80002bf8 <LAPA_compare+0x58>
}
    80002bda:	70a2                	ld	ra,40(sp)
    80002bdc:	7402                	ld	s0,32(sp)
    80002bde:	64e2                	ld	s1,24(sp)
    80002be0:	6942                	ld	s2,16(sp)
    80002be2:	69a2                	ld	s3,8(sp)
    80002be4:	6145                	addi	sp,sp,48
    80002be6:	8082                	ret
    panic("LAPA_compare : null input");
    80002be8:	00007517          	auipc	a0,0x7
    80002bec:	9c850513          	addi	a0,a0,-1592 # 800095b0 <digits+0x570>
    80002bf0:	ffffe097          	auipc	ra,0xffffe
    80002bf4:	93a080e7          	jalr	-1734(ra) # 8000052a <panic>
    return pg1->aging_counter - pg2->aging_counter;
    80002bf8:	41298533          	sub	a0,s3,s2
    80002bfc:	bff9                	j	80002bda <LAPA_compare+0x3a>

0000000080002bfe <is_accessed>:
  if(acc)
    pg->aging_counter = pg->aging_counter | 0x80000000; // if page was accessed set MSB to 1
}

long is_accessed(struct page_info *pg, int to_reset)
{
    80002bfe:	1101                	addi	sp,sp,-32
    80002c00:	ec06                	sd	ra,24(sp)
    80002c02:	e822                	sd	s0,16(sp)
    80002c04:	e426                	sd	s1,8(sp)
    80002c06:	e04a                	sd	s2,0(sp)
    80002c08:	1000                	addi	s0,sp,32
    80002c0a:	84aa                	mv	s1,a0
    80002c0c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c0e:	fffff097          	auipc	ra,0xfffff
    80002c12:	126080e7          	jalr	294(ra) # 80001d34 <myproc>
  pte_t *pte = walk(p->pagetable, pg->va, 0);
    80002c16:	4601                	li	a2,0
    80002c18:	608c                	ld	a1,0(s1)
    80002c1a:	6928                	ld	a0,80(a0)
    80002c1c:	ffffe097          	auipc	ra,0xffffe
    80002c20:	38a080e7          	jalr	906(ra) # 80000fa6 <walk>
    80002c24:	87aa                	mv	a5,a0
  long accessed = (*pte & PTE_A);
    80002c26:	6118                	ld	a4,0(a0)
    80002c28:	04077513          	andi	a0,a4,64
  if (accessed && to_reset)
    80002c2c:	c511                	beqz	a0,80002c38 <is_accessed+0x3a>
    80002c2e:	00090563          	beqz	s2,80002c38 <is_accessed+0x3a>
    *pte ^= PTE_A; // reset accessed flag
    80002c32:	04074713          	xori	a4,a4,64
    80002c36:	e398                	sd	a4,0(a5)

  return accessed;
}
    80002c38:	60e2                	ld	ra,24(sp)
    80002c3a:	6442                	ld	s0,16(sp)
    80002c3c:	64a2                	ld	s1,8(sp)
    80002c3e:	6902                	ld	s2,0(sp)
    80002c40:	6105                	addi	sp,sp,32
    80002c42:	8082                	ret

0000000080002c44 <update_NFUA_LAPA_counter>:
{
    80002c44:	1101                	addi	sp,sp,-32
    80002c46:	ec06                	sd	ra,24(sp)
    80002c48:	e822                	sd	s0,16(sp)
    80002c4a:	e426                	sd	s1,8(sp)
    80002c4c:	1000                	addi	s0,sp,32
    80002c4e:	84aa                	mv	s1,a0
  long acc =(long)(is_accessed(pg, 1));
    80002c50:	4585                	li	a1,1
    80002c52:	00000097          	auipc	ra,0x0
    80002c56:	fac080e7          	jalr	-84(ra) # 80002bfe <is_accessed>
  pg->aging_counter = (pg->aging_counter >> 1) ;
    80002c5a:	649c                	ld	a5,8(s1)
    80002c5c:	8785                	srai	a5,a5,0x1
  if(acc)
    80002c5e:	e119                	bnez	a0,80002c64 <update_NFUA_LAPA_counter+0x20>
  pg->aging_counter = (pg->aging_counter >> 1) ;
    80002c60:	e49c                	sd	a5,8(s1)
    80002c62:	a029                	j	80002c6c <update_NFUA_LAPA_counter+0x28>
    pg->aging_counter = pg->aging_counter | 0x80000000; // if page was accessed set MSB to 1
    80002c64:	4705                	li	a4,1
    80002c66:	077e                	slli	a4,a4,0x1f
    80002c68:	8fd9                	or	a5,a5,a4
    80002c6a:	e49c                	sd	a5,8(s1)
}
    80002c6c:	60e2                	ld	ra,24(sp)
    80002c6e:	6442                	ld	s0,16(sp)
    80002c70:	64a2                	ld	s1,8(sp)
    80002c72:	6105                	addi	sp,sp,32
    80002c74:	8082                	ret

0000000080002c76 <update_pages_info>:
{
    80002c76:	1101                	addi	sp,sp,-32
    80002c78:	ec06                	sd	ra,24(sp)
    80002c7a:	e822                	sd	s0,16(sp)
    80002c7c:	e426                	sd	s1,8(sp)
    80002c7e:	e04a                	sd	s2,0(sp)
    80002c80:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002c82:	fffff097          	auipc	ra,0xfffff
    80002c86:	0b2080e7          	jalr	178(ra) # 80001d34 <myproc>
  for (pg = p->pages_physc_info.pages; pg < &p->pages_physc_info.pages[MAX_PSYC_PAGES]; pg++){
    80002c8a:	30850493          	addi	s1,a0,776
    80002c8e:	48850913          	addi	s2,a0,1160
    update_NFUA_LAPA_counter(pg);
    80002c92:	8526                	mv	a0,s1
    80002c94:	00000097          	auipc	ra,0x0
    80002c98:	fb0080e7          	jalr	-80(ra) # 80002c44 <update_NFUA_LAPA_counter>
  for (pg = p->pages_physc_info.pages; pg < &p->pages_physc_info.pages[MAX_PSYC_PAGES]; pg++){
    80002c9c:	04e1                	addi	s1,s1,24
    80002c9e:	fe991ae3          	bne	s2,s1,80002c92 <update_pages_info+0x1c>
}
    80002ca2:	60e2                	ld	ra,24(sp)
    80002ca4:	6442                	ld	s0,16(sp)
    80002ca6:	64a2                	ld	s1,8(sp)
    80002ca8:	6902                	ld	s2,0(sp)
    80002caa:	6105                	addi	sp,sp,32
    80002cac:	8082                	ret

0000000080002cae <scheduler>:
{
    80002cae:	715d                	addi	sp,sp,-80
    80002cb0:	e486                	sd	ra,72(sp)
    80002cb2:	e0a2                	sd	s0,64(sp)
    80002cb4:	fc26                	sd	s1,56(sp)
    80002cb6:	f84a                	sd	s2,48(sp)
    80002cb8:	f44e                	sd	s3,40(sp)
    80002cba:	f052                	sd	s4,32(sp)
    80002cbc:	ec56                	sd	s5,24(sp)
    80002cbe:	e85a                	sd	s6,16(sp)
    80002cc0:	e45e                	sd	s7,8(sp)
    80002cc2:	0880                	addi	s0,sp,80
    80002cc4:	8792                	mv	a5,tp
  int id = r_tp();
    80002cc6:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002cc8:	00779b13          	slli	s6,a5,0x7
    80002ccc:	0000f717          	auipc	a4,0xf
    80002cd0:	5d470713          	addi	a4,a4,1492 # 800122a0 <pid_lock>
    80002cd4:	975a                	add	a4,a4,s6
    80002cd6:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002cda:	0000f717          	auipc	a4,0xf
    80002cde:	5fe70713          	addi	a4,a4,1534 # 800122d8 <cpus+0x8>
    80002ce2:	9b3a                	add	s6,s6,a4
      if (p->state == RUNNABLE)
    80002ce4:	498d                	li	s3,3
        p->state = RUNNING;
    80002ce6:	4b91                	li	s7,4
        c->proc = p;
    80002ce8:	079e                	slli	a5,a5,0x7
    80002cea:	0000fa17          	auipc	s4,0xf
    80002cee:	5b6a0a13          	addi	s4,s4,1462 # 800122a0 <pid_lock>
    80002cf2:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80002cf4:	00022917          	auipc	s2,0x22
    80002cf8:	ddc90913          	addi	s2,s2,-548 # 80024ad0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cfc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d00:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d04:	10079073          	csrw	sstatus,a5
    80002d08:	00010497          	auipc	s1,0x10
    80002d0c:	9c848493          	addi	s1,s1,-1592 # 800126d0 <proc>
        if(p->pid>2){
    80002d10:	4a89                	li	s5,2
    80002d12:	a821                	j	80002d2a <scheduler+0x7c>
        c->proc = 0;
    80002d14:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    80002d18:	8526                	mv	a0,s1
    80002d1a:	ffffe097          	auipc	ra,0xffffe
    80002d1e:	f5c080e7          	jalr	-164(ra) # 80000c76 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002d22:	49048493          	addi	s1,s1,1168
    80002d26:	fd248be3          	beq	s1,s2,80002cfc <scheduler+0x4e>
      acquire(&p->lock);
    80002d2a:	8526                	mv	a0,s1
    80002d2c:	ffffe097          	auipc	ra,0xffffe
    80002d30:	e96080e7          	jalr	-362(ra) # 80000bc2 <acquire>
      if (p->state == RUNNABLE)
    80002d34:	4c9c                	lw	a5,24(s1)
    80002d36:	ff3791e3          	bne	a5,s3,80002d18 <scheduler+0x6a>
        p->state = RUNNING;
    80002d3a:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80002d3e:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002d42:	06048593          	addi	a1,s1,96
    80002d46:	855a                	mv	a0,s6
    80002d48:	00000097          	auipc	ra,0x0
    80002d4c:	1a6080e7          	jalr	422(ra) # 80002eee <swtch>
        if(p->pid>2){
    80002d50:	589c                	lw	a5,48(s1)
    80002d52:	fcfad1e3          	bge	s5,a5,80002d14 <scheduler+0x66>
          update_pages_info();
    80002d56:	00000097          	auipc	ra,0x0
    80002d5a:	f20080e7          	jalr	-224(ra) # 80002c76 <update_pages_info>
    80002d5e:	bf5d                	j	80002d14 <scheduler+0x66>

0000000080002d60 <reset_aging_counter>:
void reset_aging_counter(struct page_info *pg)
{
    80002d60:	1141                	addi	sp,sp,-16
    80002d62:	e422                	sd	s0,8(sp)
    80002d64:	0800                	addi	s0,sp,16
  #ifdef NFUA
    pg->aging_counter = 0x00000002;//TODO return to 0
    80002d66:	4789                	li	a5,2
    80002d68:	e51c                	sd	a5,8(a0)
    // pg->aging_counter = 0;//TODO return to 0

  #elif LAPA
    pg->aging_counter = 0xFFFFFFFF;
  #endif
}
    80002d6a:	6422                	ld	s0,8(sp)
    80002d6c:	0141                	addi	sp,sp,16
    80002d6e:	8082                	ret

0000000080002d70 <print_pages_from_info_arrs>:

void print_pages_from_info_arrs(){
    80002d70:	7139                	addi	sp,sp,-64
    80002d72:	fc06                	sd	ra,56(sp)
    80002d74:	f822                	sd	s0,48(sp)
    80002d76:	f426                	sd	s1,40(sp)
    80002d78:	f04a                	sd	s2,32(sp)
    80002d7a:	ec4e                	sd	s3,24(sp)
    80002d7c:	e852                	sd	s4,16(sp)
    80002d7e:	e456                	sd	s5,8(sp)
    80002d80:	e05a                	sd	s6,0(sp)
    80002d82:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002d84:	fffff097          	auipc	ra,0xfffff
    80002d88:	fb0080e7          	jalr	-80(ra) # 80001d34 <myproc>
    80002d8c:	89aa                	mv	s3,a0
  printf("pid = %d\n",p->pid);
    80002d8e:	590c                	lw	a1,48(a0)
    80002d90:	00007517          	auipc	a0,0x7
    80002d94:	84050513          	addi	a0,a0,-1984 # 800095d0 <digits+0x590>
    80002d98:	ffffd097          	auipc	ra,0xffffd
    80002d9c:	7dc080e7          	jalr	2012(ra) # 80000574 <printf>
  printf("\n physic pages \t\t\t\t\t\tswap file::\n");
    80002da0:	00007517          	auipc	a0,0x7
    80002da4:	84050513          	addi	a0,a0,-1984 # 800095e0 <digits+0x5a0>
    80002da8:	ffffd097          	auipc	ra,0xffffd
    80002dac:	7cc080e7          	jalr	1996(ra) # 80000574 <printf>
  printf("index\t(va used \t aging)\t\t\t\t(va , used)  \n ");
    80002db0:	00007517          	auipc	a0,0x7
    80002db4:	85850513          	addi	a0,a0,-1960 # 80009608 <digits+0x5c8>
    80002db8:	ffffd097          	auipc	ra,0xffffd
    80002dbc:	7bc080e7          	jalr	1980(ra) # 80000574 <printf>
  for (int i = 0; i < MAX_PSYC_PAGES; i++){
    80002dc0:	18098913          	addi	s2,s3,384
    80002dc4:	4481                	li	s1,0
    printf("%d:\t(%p , %d ,\t %p)\t\t(%p , %d)  \n ", i,p->pages_physc_info.pages[i].va, 
      (p->pages_physc_info.free_spaces & (1 << i))>0,
    80002dc6:	4b05                	li	s6,1
    printf("%d:\t(%p , %d ,\t %p)\t\t(%p , %d)  \n ", i,p->pages_physc_info.pages[i].va, 
    80002dc8:	00007a97          	auipc	s5,0x7
    80002dcc:	870a8a93          	addi	s5,s5,-1936 # 80009638 <digits+0x5f8>
  for (int i = 0; i < MAX_PSYC_PAGES; i++){
    80002dd0:	4a41                	li	s4,16
      (p->pages_physc_info.free_spaces & (1 << i))>0,
    80002dd2:	009b17bb          	sllw	a5,s6,s1
    printf("%d:\t(%p , %d ,\t %p)\t\t(%p , %d)  \n ", i,p->pages_physc_info.pages[i].va, 
    80002dd6:	1789d803          	lhu	a6,376(s3)
      (p->pages_physc_info.free_spaces & (1 << i))>0,
    80002dda:	3009d683          	lhu	a3,768(s3)
    printf("%d:\t(%p , %d ,\t %p)\t\t(%p , %d)  \n ", i,p->pages_physc_info.pages[i].va, 
    80002dde:	8efd                	and	a3,a3,a5
    80002de0:	0107f833          	and	a6,a5,a6
    80002de4:	00093783          	ld	a5,0(s2)
    80002de8:	19093703          	ld	a4,400(s2)
    80002dec:	00d036b3          	snez	a3,a3
    80002df0:	18893603          	ld	a2,392(s2)
    80002df4:	85a6                	mv	a1,s1
    80002df6:	8556                	mv	a0,s5
    80002df8:	ffffd097          	auipc	ra,0xffffd
    80002dfc:	77c080e7          	jalr	1916(ra) # 80000574 <printf>
  for (int i = 0; i < MAX_PSYC_PAGES; i++){
    80002e00:	2485                	addiw	s1,s1,1
    80002e02:	0961                	addi	s2,s2,24
    80002e04:	fd4497e3          	bne	s1,s4,80002dd2 <print_pages_from_info_arrs+0x62>
      p->pages_physc_info.pages[i].aging_counter,
      p->pages_swap_info.pages[i].va,p->pages_swap_info.free_spaces&(1<<i));
  }

    80002e08:	70e2                	ld	ra,56(sp)
    80002e0a:	7442                	ld	s0,48(sp)
    80002e0c:	74a2                	ld	s1,40(sp)
    80002e0e:	7902                	ld	s2,32(sp)
    80002e10:	69e2                	ld	s3,24(sp)
    80002e12:	6a42                	ld	s4,16(sp)
    80002e14:	6aa2                	ld	s5,8(sp)
    80002e16:	6b02                	ld	s6,0(sp)
    80002e18:	6121                	addi	sp,sp,64
    80002e1a:	8082                	ret

0000000080002e1c <compare_all_pages>:
{
    80002e1c:	715d                	addi	sp,sp,-80
    80002e1e:	e486                	sd	ra,72(sp)
    80002e20:	e0a2                	sd	s0,64(sp)
    80002e22:	fc26                	sd	s1,56(sp)
    80002e24:	f84a                	sd	s2,48(sp)
    80002e26:	f44e                	sd	s3,40(sp)
    80002e28:	f052                	sd	s4,32(sp)
    80002e2a:	ec56                	sd	s5,24(sp)
    80002e2c:	e85a                	sd	s6,16(sp)
    80002e2e:	e45e                	sd	s7,8(sp)
    80002e30:	e062                	sd	s8,0(sp)
    80002e32:	0880                	addi	s0,sp,80
    80002e34:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002e36:	fffff097          	auipc	ra,0xfffff
    80002e3a:	efe080e7          	jalr	-258(ra) # 80001d34 <myproc>
    80002e3e:	89aa                	mv	s3,a0
  printf("compare all pages:\n");
    80002e40:	00007517          	auipc	a0,0x7
    80002e44:	82050513          	addi	a0,a0,-2016 # 80009660 <digits+0x620>
    80002e48:	ffffd097          	auipc	ra,0xffffd
    80002e4c:	72c080e7          	jalr	1836(ra) # 80000574 <printf>
  print_pages_from_info_arrs();
    80002e50:	00000097          	auipc	ra,0x0
    80002e54:	f20080e7          	jalr	-224(ra) # 80002d70 <print_pages_from_info_arrs>
  for (int i=0;i<MAX_PSYC_PAGES;i++)
    80002e58:	30898913          	addi	s2,s3,776
    80002e5c:	4481                	li	s1,0
  int min_index = -1;
    80002e5e:	5bfd                	li	s7,-1
  struct page_info *pg_to_swap = 0;
    80002e60:	4a01                	li	s4,0
  for (int i=0;i<MAX_PSYC_PAGES;i++)
    80002e62:	4ac1                	li	s5,16
    80002e64:	a039                	j	80002e72 <compare_all_pages+0x56>
    80002e66:	8ba6                	mv	s7,s1
      pg_to_swap = pg;
    80002e68:	8a4a                	mv	s4,s2
  for (int i=0;i<MAX_PSYC_PAGES;i++)
    80002e6a:	2485                	addiw	s1,s1,1
    80002e6c:	0961                	addi	s2,s2,24
    80002e6e:	03548263          	beq	s1,s5,80002e92 <compare_all_pages+0x76>
    if ((p->pages_physc_info.free_spaces & (1 << i)) && (!pg_to_swap || compare(pg, pg_to_swap) < 0))
    80002e72:	3009d783          	lhu	a5,768(s3)
    80002e76:	4097d7bb          	sraw	a5,a5,s1
    80002e7a:	8b85                	andi	a5,a5,1
    80002e7c:	d7fd                	beqz	a5,80002e6a <compare_all_pages+0x4e>
    80002e7e:	fe0a04e3          	beqz	s4,80002e66 <compare_all_pages+0x4a>
    80002e82:	85d2                	mv	a1,s4
    80002e84:	854a                	mv	a0,s2
    80002e86:	9b02                	jalr	s6
    80002e88:	fe0551e3          	bgez	a0,80002e6a <compare_all_pages+0x4e>
    80002e8c:	8ba6                	mv	s7,s1
      pg_to_swap = pg;
    80002e8e:	8a4a                	mv	s4,s2
    80002e90:	bfe9                	j	80002e6a <compare_all_pages+0x4e>
}
    80002e92:	855e                	mv	a0,s7
    80002e94:	60a6                	ld	ra,72(sp)
    80002e96:	6406                	ld	s0,64(sp)
    80002e98:	74e2                	ld	s1,56(sp)
    80002e9a:	7942                	ld	s2,48(sp)
    80002e9c:	79a2                	ld	s3,40(sp)
    80002e9e:	7a02                	ld	s4,32(sp)
    80002ea0:	6ae2                	ld	s5,24(sp)
    80002ea2:	6b42                	ld	s6,16(sp)
    80002ea4:	6ba2                	ld	s7,8(sp)
    80002ea6:	6c02                	ld	s8,0(sp)
    80002ea8:	6161                	addi	sp,sp,80
    80002eaa:	8082                	ret

0000000080002eac <get_next_page_to_swap_out>:
{
    80002eac:	1101                	addi	sp,sp,-32
    80002eae:	ec06                	sd	ra,24(sp)
    80002eb0:	e822                	sd	s0,16(sp)
    80002eb2:	e426                	sd	s1,8(sp)
    80002eb4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002eb6:	fffff097          	auipc	ra,0xfffff
    80002eba:	e7e080e7          	jalr	-386(ra) # 80001d34 <myproc>
  selected_pg_index = compare_all_pages(NFUA_compare);
    80002ebe:	fffff517          	auipc	a0,0xfffff
    80002ec2:	ce050513          	addi	a0,a0,-800 # 80001b9e <NFUA_compare>
    80002ec6:	00000097          	auipc	ra,0x0
    80002eca:	f56080e7          	jalr	-170(ra) # 80002e1c <compare_all_pages>
    80002ece:	84aa                	mv	s1,a0
  printf("next page to swapout = %d\n",selected_pg_index);
    80002ed0:	85aa                	mv	a1,a0
    80002ed2:	00006517          	auipc	a0,0x6
    80002ed6:	7a650513          	addi	a0,a0,1958 # 80009678 <digits+0x638>
    80002eda:	ffffd097          	auipc	ra,0xffffd
    80002ede:	69a080e7          	jalr	1690(ra) # 80000574 <printf>
}
    80002ee2:	8526                	mv	a0,s1
    80002ee4:	60e2                	ld	ra,24(sp)
    80002ee6:	6442                	ld	s0,16(sp)
    80002ee8:	64a2                	ld	s1,8(sp)
    80002eea:	6105                	addi	sp,sp,32
    80002eec:	8082                	ret

0000000080002eee <swtch>:
    80002eee:	00153023          	sd	ra,0(a0)
    80002ef2:	00253423          	sd	sp,8(a0)
    80002ef6:	e900                	sd	s0,16(a0)
    80002ef8:	ed04                	sd	s1,24(a0)
    80002efa:	03253023          	sd	s2,32(a0)
    80002efe:	03353423          	sd	s3,40(a0)
    80002f02:	03453823          	sd	s4,48(a0)
    80002f06:	03553c23          	sd	s5,56(a0)
    80002f0a:	05653023          	sd	s6,64(a0)
    80002f0e:	05753423          	sd	s7,72(a0)
    80002f12:	05853823          	sd	s8,80(a0)
    80002f16:	05953c23          	sd	s9,88(a0)
    80002f1a:	07a53023          	sd	s10,96(a0)
    80002f1e:	07b53423          	sd	s11,104(a0)
    80002f22:	0005b083          	ld	ra,0(a1)
    80002f26:	0085b103          	ld	sp,8(a1)
    80002f2a:	6980                	ld	s0,16(a1)
    80002f2c:	6d84                	ld	s1,24(a1)
    80002f2e:	0205b903          	ld	s2,32(a1)
    80002f32:	0285b983          	ld	s3,40(a1)
    80002f36:	0305ba03          	ld	s4,48(a1)
    80002f3a:	0385ba83          	ld	s5,56(a1)
    80002f3e:	0405bb03          	ld	s6,64(a1)
    80002f42:	0485bb83          	ld	s7,72(a1)
    80002f46:	0505bc03          	ld	s8,80(a1)
    80002f4a:	0585bc83          	ld	s9,88(a1)
    80002f4e:	0605bd03          	ld	s10,96(a1)
    80002f52:	0685bd83          	ld	s11,104(a1)
    80002f56:	8082                	ret

0000000080002f58 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002f58:	1141                	addi	sp,sp,-16
    80002f5a:	e406                	sd	ra,8(sp)
    80002f5c:	e022                	sd	s0,0(sp)
    80002f5e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002f60:	00006597          	auipc	a1,0x6
    80002f64:	79058593          	addi	a1,a1,1936 # 800096f0 <states.0+0x30>
    80002f68:	00022517          	auipc	a0,0x22
    80002f6c:	b6850513          	addi	a0,a0,-1176 # 80024ad0 <tickslock>
    80002f70:	ffffe097          	auipc	ra,0xffffe
    80002f74:	bc2080e7          	jalr	-1086(ra) # 80000b32 <initlock>
}
    80002f78:	60a2                	ld	ra,8(sp)
    80002f7a:	6402                	ld	s0,0(sp)
    80002f7c:	0141                	addi	sp,sp,16
    80002f7e:	8082                	ret

0000000080002f80 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002f80:	1141                	addi	sp,sp,-16
    80002f82:	e422                	sd	s0,8(sp)
    80002f84:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002f86:	00004797          	auipc	a5,0x4
    80002f8a:	aea78793          	addi	a5,a5,-1302 # 80006a70 <kernelvec>
    80002f8e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002f92:	6422                	ld	s0,8(sp)
    80002f94:	0141                	addi	sp,sp,16
    80002f96:	8082                	ret

0000000080002f98 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002f98:	1141                	addi	sp,sp,-16
    80002f9a:	e406                	sd	ra,8(sp)
    80002f9c:	e022                	sd	s0,0(sp)
    80002f9e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002fa0:	fffff097          	auipc	ra,0xfffff
    80002fa4:	d94080e7          	jalr	-620(ra) # 80001d34 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fa8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002fac:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002fae:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002fb2:	00005617          	auipc	a2,0x5
    80002fb6:	04e60613          	addi	a2,a2,78 # 80008000 <_trampoline>
    80002fba:	00005697          	auipc	a3,0x5
    80002fbe:	04668693          	addi	a3,a3,70 # 80008000 <_trampoline>
    80002fc2:	8e91                	sub	a3,a3,a2
    80002fc4:	040007b7          	lui	a5,0x4000
    80002fc8:	17fd                	addi	a5,a5,-1
    80002fca:	07b2                	slli	a5,a5,0xc
    80002fcc:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002fce:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002fd2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002fd4:	180026f3          	csrr	a3,satp
    80002fd8:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002fda:	6d38                	ld	a4,88(a0)
    80002fdc:	6134                	ld	a3,64(a0)
    80002fde:	6585                	lui	a1,0x1
    80002fe0:	96ae                	add	a3,a3,a1
    80002fe2:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002fe4:	6d38                	ld	a4,88(a0)
    80002fe6:	00000697          	auipc	a3,0x0
    80002fea:	13868693          	addi	a3,a3,312 # 8000311e <usertrap>
    80002fee:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002ff0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002ff2:	8692                	mv	a3,tp
    80002ff4:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ff6:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002ffa:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002ffe:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003002:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80003006:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003008:	6f18                	ld	a4,24(a4)
    8000300a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000300e:	692c                	ld	a1,80(a0)
    80003010:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80003012:	00005717          	auipc	a4,0x5
    80003016:	07e70713          	addi	a4,a4,126 # 80008090 <userret>
    8000301a:	8f11                	sub	a4,a4,a2
    8000301c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))fn)(TRAPFRAME, satp);
    8000301e:	577d                	li	a4,-1
    80003020:	177e                	slli	a4,a4,0x3f
    80003022:	8dd9                	or	a1,a1,a4
    80003024:	02000537          	lui	a0,0x2000
    80003028:	157d                	addi	a0,a0,-1
    8000302a:	0536                	slli	a0,a0,0xd
    8000302c:	9782                	jalr	a5
}
    8000302e:	60a2                	ld	ra,8(sp)
    80003030:	6402                	ld	s0,0(sp)
    80003032:	0141                	addi	sp,sp,16
    80003034:	8082                	ret

0000000080003036 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80003036:	1101                	addi	sp,sp,-32
    80003038:	ec06                	sd	ra,24(sp)
    8000303a:	e822                	sd	s0,16(sp)
    8000303c:	e426                	sd	s1,8(sp)
    8000303e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80003040:	00022497          	auipc	s1,0x22
    80003044:	a9048493          	addi	s1,s1,-1392 # 80024ad0 <tickslock>
    80003048:	8526                	mv	a0,s1
    8000304a:	ffffe097          	auipc	ra,0xffffe
    8000304e:	b78080e7          	jalr	-1160(ra) # 80000bc2 <acquire>
  ticks++;
    80003052:	00007517          	auipc	a0,0x7
    80003056:	fde50513          	addi	a0,a0,-34 # 8000a030 <ticks>
    8000305a:	411c                	lw	a5,0(a0)
    8000305c:	2785                	addiw	a5,a5,1
    8000305e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80003060:	fffff097          	auipc	ra,0xfffff
    80003064:	358080e7          	jalr	856(ra) # 800023b8 <wakeup>
  release(&tickslock);
    80003068:	8526                	mv	a0,s1
    8000306a:	ffffe097          	auipc	ra,0xffffe
    8000306e:	c0c080e7          	jalr	-1012(ra) # 80000c76 <release>
}
    80003072:	60e2                	ld	ra,24(sp)
    80003074:	6442                	ld	s0,16(sp)
    80003076:	64a2                	ld	s1,8(sp)
    80003078:	6105                	addi	sp,sp,32
    8000307a:	8082                	ret

000000008000307c <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    8000307c:	1101                	addi	sp,sp,-32
    8000307e:	ec06                	sd	ra,24(sp)
    80003080:	e822                	sd	s0,16(sp)
    80003082:	e426                	sd	s1,8(sp)
    80003084:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003086:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    8000308a:	00074d63          	bltz	a4,800030a4 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    8000308e:	57fd                	li	a5,-1
    80003090:	17fe                	slli	a5,a5,0x3f
    80003092:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80003094:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80003096:	06f70363          	beq	a4,a5,800030fc <devintr+0x80>
  }
}
    8000309a:	60e2                	ld	ra,24(sp)
    8000309c:	6442                	ld	s0,16(sp)
    8000309e:	64a2                	ld	s1,8(sp)
    800030a0:	6105                	addi	sp,sp,32
    800030a2:	8082                	ret
      (scause & 0xff) == 9)
    800030a4:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    800030a8:	46a5                	li	a3,9
    800030aa:	fed792e3          	bne	a5,a3,8000308e <devintr+0x12>
    int irq = plic_claim();
    800030ae:	00004097          	auipc	ra,0x4
    800030b2:	aca080e7          	jalr	-1334(ra) # 80006b78 <plic_claim>
    800030b6:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    800030b8:	47a9                	li	a5,10
    800030ba:	02f50763          	beq	a0,a5,800030e8 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    800030be:	4785                	li	a5,1
    800030c0:	02f50963          	beq	a0,a5,800030f2 <devintr+0x76>
    return 1;
    800030c4:	4505                	li	a0,1
    else if (irq)
    800030c6:	d8f1                	beqz	s1,8000309a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800030c8:	85a6                	mv	a1,s1
    800030ca:	00006517          	auipc	a0,0x6
    800030ce:	62e50513          	addi	a0,a0,1582 # 800096f8 <states.0+0x38>
    800030d2:	ffffd097          	auipc	ra,0xffffd
    800030d6:	4a2080e7          	jalr	1186(ra) # 80000574 <printf>
      plic_complete(irq);
    800030da:	8526                	mv	a0,s1
    800030dc:	00004097          	auipc	ra,0x4
    800030e0:	ac0080e7          	jalr	-1344(ra) # 80006b9c <plic_complete>
    return 1;
    800030e4:	4505                	li	a0,1
    800030e6:	bf55                	j	8000309a <devintr+0x1e>
      uartintr();
    800030e8:	ffffe097          	auipc	ra,0xffffe
    800030ec:	89e080e7          	jalr	-1890(ra) # 80000986 <uartintr>
    800030f0:	b7ed                	j	800030da <devintr+0x5e>
      virtio_disk_intr();
    800030f2:	00004097          	auipc	ra,0x4
    800030f6:	f3c080e7          	jalr	-196(ra) # 8000702e <virtio_disk_intr>
    800030fa:	b7c5                	j	800030da <devintr+0x5e>
    if (cpuid() == 0)
    800030fc:	fffff097          	auipc	ra,0xfffff
    80003100:	c0c080e7          	jalr	-1012(ra) # 80001d08 <cpuid>
    80003104:	c901                	beqz	a0,80003114 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80003106:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000310a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000310c:	14479073          	csrw	sip,a5
    return 2;
    80003110:	4509                	li	a0,2
    80003112:	b761                	j	8000309a <devintr+0x1e>
      clockintr();
    80003114:	00000097          	auipc	ra,0x0
    80003118:	f22080e7          	jalr	-222(ra) # 80003036 <clockintr>
    8000311c:	b7ed                	j	80003106 <devintr+0x8a>

000000008000311e <usertrap>:
{
    8000311e:	7179                	addi	sp,sp,-48
    80003120:	f406                	sd	ra,40(sp)
    80003122:	f022                	sd	s0,32(sp)
    80003124:	ec26                	sd	s1,24(sp)
    80003126:	e84a                	sd	s2,16(sp)
    80003128:	e44e                	sd	s3,8(sp)
    8000312a:	e052                	sd	s4,0(sp)
    8000312c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000312e:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80003132:	1007f793          	andi	a5,a5,256
    80003136:	efd1                	bnez	a5,800031d2 <usertrap+0xb4>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003138:	00004797          	auipc	a5,0x4
    8000313c:	93878793          	addi	a5,a5,-1736 # 80006a70 <kernelvec>
    80003140:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003144:	fffff097          	auipc	ra,0xfffff
    80003148:	bf0080e7          	jalr	-1040(ra) # 80001d34 <myproc>
    8000314c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000314e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003150:	14102773          	csrr	a4,sepc
    80003154:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003156:	142027f3          	csrr	a5,scause
  if (trap_cause == 8)
    8000315a:	4721                	li	a4,8
    8000315c:	08e78363          	beq	a5,a4,800031e2 <usertrap+0xc4>
  else if (trap_cause == 13 || trap_cause == 15 || trap_cause == 12)
    80003160:	473d                	li	a4,15
    80003162:	00e78663          	beq	a5,a4,8000316e <usertrap+0x50>
    80003166:	17d1                	addi	a5,a5,-12
    80003168:	4705                	li	a4,1
    8000316a:	12f76a63          	bltu	a4,a5,8000329e <usertrap+0x180>
    struct proc *p = myproc();
    8000316e:	fffff097          	auipc	ra,0xfffff
    80003172:	bc6080e7          	jalr	-1082(ra) # 80001d34 <myproc>
    80003176:	892a                	mv	s2,a0
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003178:	14302a73          	csrr	s4,stval
    uint64 fault_rva = PGROUNDDOWN(fault_va);
    8000317c:	77fd                	lui	a5,0xfffff
    8000317e:	00fa7a33          	and	s4,s4,a5
    pte_t *pte = walk(p->pagetable, fault_rva, 0);
    80003182:	4601                	li	a2,0
    80003184:	85d2                	mv	a1,s4
    80003186:	6928                	ld	a0,80(a0)
    80003188:	ffffe097          	auipc	ra,0xffffe
    8000318c:	e1e080e7          	jalr	-482(ra) # 80000fa6 <walk>
    80003190:	89aa                	mv	s3,a0
    if (!pte || p->pid <= 2)
    80003192:	cd41                	beqz	a0,8000322a <usertrap+0x10c>
    80003194:	03092703          	lw	a4,48(s2)
    80003198:	4789                	li	a5,2
    8000319a:	08e7d863          	bge	a5,a4,8000322a <usertrap+0x10c>
    printf("debug: PAGE FAULT\n");
    8000319e:	00006517          	auipc	a0,0x6
    800031a2:	5da50513          	addi	a0,a0,1498 # 80009778 <states.0+0xb8>
    800031a6:	ffffd097          	auipc	ra,0xffffd
    800031aa:	3ce080e7          	jalr	974(ra) # 80000574 <printf>
    if ((*pte & PTE_PG) && !(*pte & PTE_V))
    800031ae:	0009b783          	ld	a5,0(s3)
    800031b2:	2017f693          	andi	a3,a5,513
    800031b6:	20000713          	li	a4,512
    800031ba:	08e68a63          	beq	a3,a4,8000324e <usertrap+0x130>
    else if (*pte & PTE_V)
    800031be:	8b85                	andi	a5,a5,1
    800031c0:	c3a9                	beqz	a5,80003202 <usertrap+0xe4>
      panic("usertrap: PTE_V should not be valid during page_fault"); //TODO: check if needed/true
    800031c2:	00006517          	auipc	a0,0x6
    800031c6:	5f650513          	addi	a0,a0,1526 # 800097b8 <states.0+0xf8>
    800031ca:	ffffd097          	auipc	ra,0xffffd
    800031ce:	360080e7          	jalr	864(ra) # 8000052a <panic>
    panic("usertrap: not from user mode");
    800031d2:	00006517          	auipc	a0,0x6
    800031d6:	54650513          	addi	a0,a0,1350 # 80009718 <states.0+0x58>
    800031da:	ffffd097          	auipc	ra,0xffffd
    800031de:	350080e7          	jalr	848(ra) # 8000052a <panic>
    if (p->killed)
    800031e2:	551c                	lw	a5,40(a0)
    800031e4:	ef8d                	bnez	a5,8000321e <usertrap+0x100>
    p->trapframe->epc += 4;
    800031e6:	6cb8                	ld	a4,88(s1)
    800031e8:	6f1c                	ld	a5,24(a4)
    800031ea:	0791                	addi	a5,a5,4
    800031ec:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800031ee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800031f2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800031f6:	10079073          	csrw	sstatus,a5
    syscall();
    800031fa:	00000097          	auipc	ra,0x0
    800031fe:	362080e7          	jalr	866(ra) # 8000355c <syscall>
  if (p->killed)
    80003202:	549c                	lw	a5,40(s1)
    80003204:	e3e5                	bnez	a5,800032e4 <usertrap+0x1c6>
  usertrapret();
    80003206:	00000097          	auipc	ra,0x0
    8000320a:	d92080e7          	jalr	-622(ra) # 80002f98 <usertrapret>
}
    8000320e:	70a2                	ld	ra,40(sp)
    80003210:	7402                	ld	s0,32(sp)
    80003212:	64e2                	ld	s1,24(sp)
    80003214:	6942                	ld	s2,16(sp)
    80003216:	69a2                	ld	s3,8(sp)
    80003218:	6a02                	ld	s4,0(sp)
    8000321a:	6145                	addi	sp,sp,48
    8000321c:	8082                	ret
      exit(-1);
    8000321e:	557d                	li	a0,-1
    80003220:	fffff097          	auipc	ra,0xfffff
    80003224:	268080e7          	jalr	616(ra) # 80002488 <exit>
    80003228:	bf7d                	j	800031e6 <usertrap+0xc8>
      printf("seg fault with pid=%d", p->pid);
    8000322a:	03092583          	lw	a1,48(s2)
    8000322e:	00006517          	auipc	a0,0x6
    80003232:	50a50513          	addi	a0,a0,1290 # 80009738 <states.0+0x78>
    80003236:	ffffd097          	auipc	ra,0xffffd
    8000323a:	33e080e7          	jalr	830(ra) # 80000574 <printf>
      panic("usertrap: segmentation fault oh nooooo"); // TODO check if need to kill just the current procces
    8000323e:	00006517          	auipc	a0,0x6
    80003242:	51250513          	addi	a0,a0,1298 # 80009750 <states.0+0x90>
    80003246:	ffffd097          	auipc	ra,0xffffd
    8000324a:	2e4080e7          	jalr	740(ra) # 8000052a <panic>
      if (p->physical_pages_num >= MAX_PSYC_PAGES)
    8000324e:	17092703          	lw	a4,368(s2)
    80003252:	47bd                	li	a5,15
    80003254:	02e7d663          	bge	a5,a4,80003280 <usertrap+0x162>
        int page_to_swap_out_index = get_next_page_to_swap_out();
    80003258:	00000097          	auipc	ra,0x0
    8000325c:	c54080e7          	jalr	-940(ra) # 80002eac <get_next_page_to_swap_out>
        if (page_to_swap_out_index < 0 || page_to_swap_out_index > MAX_PSYC_PAGES)
    80003260:	0005071b          	sext.w	a4,a0
    80003264:	47c1                	li	a5,16
    80003266:	02e7e463          	bltu	a5,a4,8000328e <usertrap+0x170>
        uint64 va = p->pages_physc_info.pages[page_to_swap_out_index].va;
    8000326a:	00151793          	slli	a5,a0,0x1
    8000326e:	953e                	add	a0,a0,a5
    80003270:	050e                	slli	a0,a0,0x3
    80003272:	992a                	add	s2,s2,a0
        uint64 pa = page_out(va);
    80003274:	30893503          	ld	a0,776(s2)
    80003278:	fffff097          	auipc	ra,0xfffff
    8000327c:	50e080e7          	jalr	1294(ra) # 80002786 <page_out>
      pte_t *pte_new = page_in(fault_rva, pte);
    80003280:	85ce                	mv	a1,s3
    80003282:	8552                	mv	a0,s4
    80003284:	fffff097          	auipc	ra,0xfffff
    80003288:	598080e7          	jalr	1432(ra) # 8000281c <page_in>
    8000328c:	bf9d                	j	80003202 <usertrap+0xe4>
          panic("usertrap: did not find page to swap out");
    8000328e:	00006517          	auipc	a0,0x6
    80003292:	50250513          	addi	a0,a0,1282 # 80009790 <states.0+0xd0>
    80003296:	ffffd097          	auipc	ra,0xffffd
    8000329a:	294080e7          	jalr	660(ra) # 8000052a <panic>
  else if ((which_dev = devintr()) != 0)
    8000329e:	00000097          	auipc	ra,0x0
    800032a2:	dde080e7          	jalr	-546(ra) # 8000307c <devintr>
    800032a6:	892a                	mv	s2,a0
    800032a8:	c501                	beqz	a0,800032b0 <usertrap+0x192>
  if (p->killed)
    800032aa:	549c                	lw	a5,40(s1)
    800032ac:	c3b1                	beqz	a5,800032f0 <usertrap+0x1d2>
    800032ae:	a825                	j	800032e6 <usertrap+0x1c8>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800032b0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800032b4:	5890                	lw	a2,48(s1)
    800032b6:	00006517          	auipc	a0,0x6
    800032ba:	53a50513          	addi	a0,a0,1338 # 800097f0 <states.0+0x130>
    800032be:	ffffd097          	auipc	ra,0xffffd
    800032c2:	2b6080e7          	jalr	694(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800032c6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800032ca:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800032ce:	00006517          	auipc	a0,0x6
    800032d2:	55250513          	addi	a0,a0,1362 # 80009820 <states.0+0x160>
    800032d6:	ffffd097          	auipc	ra,0xffffd
    800032da:	29e080e7          	jalr	670(ra) # 80000574 <printf>
    p->killed = 1;
    800032de:	4785                	li	a5,1
    800032e0:	d49c                	sw	a5,40(s1)
  if (p->killed)
    800032e2:	a011                	j	800032e6 <usertrap+0x1c8>
    800032e4:	4901                	li	s2,0
    exit(-1);
    800032e6:	557d                	li	a0,-1
    800032e8:	fffff097          	auipc	ra,0xfffff
    800032ec:	1a0080e7          	jalr	416(ra) # 80002488 <exit>
  if (which_dev == 2)
    800032f0:	4789                	li	a5,2
    800032f2:	f0f91ae3          	bne	s2,a5,80003206 <usertrap+0xe8>
    yield();
    800032f6:	fffff097          	auipc	ra,0xfffff
    800032fa:	efa080e7          	jalr	-262(ra) # 800021f0 <yield>
    800032fe:	b721                	j	80003206 <usertrap+0xe8>

0000000080003300 <kerneltrap>:
{
    80003300:	7179                	addi	sp,sp,-48
    80003302:	f406                	sd	ra,40(sp)
    80003304:	f022                	sd	s0,32(sp)
    80003306:	ec26                	sd	s1,24(sp)
    80003308:	e84a                	sd	s2,16(sp)
    8000330a:	e44e                	sd	s3,8(sp)
    8000330c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000330e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003312:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003316:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    8000331a:	1004f793          	andi	a5,s1,256
    8000331e:	cb85                	beqz	a5,8000334e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003320:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003324:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80003326:	ef85                	bnez	a5,8000335e <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80003328:	00000097          	auipc	ra,0x0
    8000332c:	d54080e7          	jalr	-684(ra) # 8000307c <devintr>
    80003330:	cd1d                	beqz	a0,8000336e <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003332:	4789                	li	a5,2
    80003334:	08f50763          	beq	a0,a5,800033c2 <kerneltrap+0xc2>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003338:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000333c:	10049073          	csrw	sstatus,s1
}
    80003340:	70a2                	ld	ra,40(sp)
    80003342:	7402                	ld	s0,32(sp)
    80003344:	64e2                	ld	s1,24(sp)
    80003346:	6942                	ld	s2,16(sp)
    80003348:	69a2                	ld	s3,8(sp)
    8000334a:	6145                	addi	sp,sp,48
    8000334c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000334e:	00006517          	auipc	a0,0x6
    80003352:	4f250513          	addi	a0,a0,1266 # 80009840 <states.0+0x180>
    80003356:	ffffd097          	auipc	ra,0xffffd
    8000335a:	1d4080e7          	jalr	468(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    8000335e:	00006517          	auipc	a0,0x6
    80003362:	50a50513          	addi	a0,a0,1290 # 80009868 <states.0+0x1a8>
    80003366:	ffffd097          	auipc	ra,0xffffd
    8000336a:	1c4080e7          	jalr	452(ra) # 8000052a <panic>
    printf("pid = %d\n",myproc()->pid);
    8000336e:	fffff097          	auipc	ra,0xfffff
    80003372:	9c6080e7          	jalr	-1594(ra) # 80001d34 <myproc>
    80003376:	590c                	lw	a1,48(a0)
    80003378:	00006517          	auipc	a0,0x6
    8000337c:	25850513          	addi	a0,a0,600 # 800095d0 <digits+0x590>
    80003380:	ffffd097          	auipc	ra,0xffffd
    80003384:	1f4080e7          	jalr	500(ra) # 80000574 <printf>
    printf("scause %p\n", scause);
    80003388:	85ce                	mv	a1,s3
    8000338a:	00006517          	auipc	a0,0x6
    8000338e:	4fe50513          	addi	a0,a0,1278 # 80009888 <states.0+0x1c8>
    80003392:	ffffd097          	auipc	ra,0xffffd
    80003396:	1e2080e7          	jalr	482(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000339a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000339e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800033a2:	00006517          	auipc	a0,0x6
    800033a6:	4f650513          	addi	a0,a0,1270 # 80009898 <states.0+0x1d8>
    800033aa:	ffffd097          	auipc	ra,0xffffd
    800033ae:	1ca080e7          	jalr	458(ra) # 80000574 <printf>
    panic("kerneltrap");
    800033b2:	00006517          	auipc	a0,0x6
    800033b6:	4fe50513          	addi	a0,a0,1278 # 800098b0 <states.0+0x1f0>
    800033ba:	ffffd097          	auipc	ra,0xffffd
    800033be:	170080e7          	jalr	368(ra) # 8000052a <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800033c2:	fffff097          	auipc	ra,0xfffff
    800033c6:	972080e7          	jalr	-1678(ra) # 80001d34 <myproc>
    800033ca:	d53d                	beqz	a0,80003338 <kerneltrap+0x38>
    800033cc:	fffff097          	auipc	ra,0xfffff
    800033d0:	968080e7          	jalr	-1688(ra) # 80001d34 <myproc>
    800033d4:	4d18                	lw	a4,24(a0)
    800033d6:	4791                	li	a5,4
    800033d8:	f6f710e3          	bne	a4,a5,80003338 <kerneltrap+0x38>
    yield();
    800033dc:	fffff097          	auipc	ra,0xfffff
    800033e0:	e14080e7          	jalr	-492(ra) # 800021f0 <yield>
    800033e4:	bf91                	j	80003338 <kerneltrap+0x38>

00000000800033e6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800033e6:	1101                	addi	sp,sp,-32
    800033e8:	ec06                	sd	ra,24(sp)
    800033ea:	e822                	sd	s0,16(sp)
    800033ec:	e426                	sd	s1,8(sp)
    800033ee:	1000                	addi	s0,sp,32
    800033f0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800033f2:	fffff097          	auipc	ra,0xfffff
    800033f6:	942080e7          	jalr	-1726(ra) # 80001d34 <myproc>
  switch (n) {
    800033fa:	4795                	li	a5,5
    800033fc:	0497e163          	bltu	a5,s1,8000343e <argraw+0x58>
    80003400:	048a                	slli	s1,s1,0x2
    80003402:	00006717          	auipc	a4,0x6
    80003406:	4e670713          	addi	a4,a4,1254 # 800098e8 <states.0+0x228>
    8000340a:	94ba                	add	s1,s1,a4
    8000340c:	409c                	lw	a5,0(s1)
    8000340e:	97ba                	add	a5,a5,a4
    80003410:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003412:	6d3c                	ld	a5,88(a0)
    80003414:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003416:	60e2                	ld	ra,24(sp)
    80003418:	6442                	ld	s0,16(sp)
    8000341a:	64a2                	ld	s1,8(sp)
    8000341c:	6105                	addi	sp,sp,32
    8000341e:	8082                	ret
    return p->trapframe->a1;
    80003420:	6d3c                	ld	a5,88(a0)
    80003422:	7fa8                	ld	a0,120(a5)
    80003424:	bfcd                	j	80003416 <argraw+0x30>
    return p->trapframe->a2;
    80003426:	6d3c                	ld	a5,88(a0)
    80003428:	63c8                	ld	a0,128(a5)
    8000342a:	b7f5                	j	80003416 <argraw+0x30>
    return p->trapframe->a3;
    8000342c:	6d3c                	ld	a5,88(a0)
    8000342e:	67c8                	ld	a0,136(a5)
    80003430:	b7dd                	j	80003416 <argraw+0x30>
    return p->trapframe->a4;
    80003432:	6d3c                	ld	a5,88(a0)
    80003434:	6bc8                	ld	a0,144(a5)
    80003436:	b7c5                	j	80003416 <argraw+0x30>
    return p->trapframe->a5;
    80003438:	6d3c                	ld	a5,88(a0)
    8000343a:	6fc8                	ld	a0,152(a5)
    8000343c:	bfe9                	j	80003416 <argraw+0x30>
  panic("argraw");
    8000343e:	00006517          	auipc	a0,0x6
    80003442:	48250513          	addi	a0,a0,1154 # 800098c0 <states.0+0x200>
    80003446:	ffffd097          	auipc	ra,0xffffd
    8000344a:	0e4080e7          	jalr	228(ra) # 8000052a <panic>

000000008000344e <fetchaddr>:
{
    8000344e:	1101                	addi	sp,sp,-32
    80003450:	ec06                	sd	ra,24(sp)
    80003452:	e822                	sd	s0,16(sp)
    80003454:	e426                	sd	s1,8(sp)
    80003456:	e04a                	sd	s2,0(sp)
    80003458:	1000                	addi	s0,sp,32
    8000345a:	84aa                	mv	s1,a0
    8000345c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000345e:	fffff097          	auipc	ra,0xfffff
    80003462:	8d6080e7          	jalr	-1834(ra) # 80001d34 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003466:	653c                	ld	a5,72(a0)
    80003468:	02f4f863          	bgeu	s1,a5,80003498 <fetchaddr+0x4a>
    8000346c:	00848713          	addi	a4,s1,8
    80003470:	02e7e663          	bltu	a5,a4,8000349c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003474:	46a1                	li	a3,8
    80003476:	8626                	mv	a2,s1
    80003478:	85ca                	mv	a1,s2
    8000347a:	6928                	ld	a0,80(a0)
    8000347c:	ffffe097          	auipc	ra,0xffffe
    80003480:	fa4080e7          	jalr	-92(ra) # 80001420 <copyin>
    80003484:	00a03533          	snez	a0,a0
    80003488:	40a00533          	neg	a0,a0
}
    8000348c:	60e2                	ld	ra,24(sp)
    8000348e:	6442                	ld	s0,16(sp)
    80003490:	64a2                	ld	s1,8(sp)
    80003492:	6902                	ld	s2,0(sp)
    80003494:	6105                	addi	sp,sp,32
    80003496:	8082                	ret
    return -1;
    80003498:	557d                	li	a0,-1
    8000349a:	bfcd                	j	8000348c <fetchaddr+0x3e>
    8000349c:	557d                	li	a0,-1
    8000349e:	b7fd                	j	8000348c <fetchaddr+0x3e>

00000000800034a0 <fetchstr>:
{
    800034a0:	7179                	addi	sp,sp,-48
    800034a2:	f406                	sd	ra,40(sp)
    800034a4:	f022                	sd	s0,32(sp)
    800034a6:	ec26                	sd	s1,24(sp)
    800034a8:	e84a                	sd	s2,16(sp)
    800034aa:	e44e                	sd	s3,8(sp)
    800034ac:	1800                	addi	s0,sp,48
    800034ae:	892a                	mv	s2,a0
    800034b0:	84ae                	mv	s1,a1
    800034b2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800034b4:	fffff097          	auipc	ra,0xfffff
    800034b8:	880080e7          	jalr	-1920(ra) # 80001d34 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    800034bc:	86ce                	mv	a3,s3
    800034be:	864a                	mv	a2,s2
    800034c0:	85a6                	mv	a1,s1
    800034c2:	6928                	ld	a0,80(a0)
    800034c4:	ffffe097          	auipc	ra,0xffffe
    800034c8:	fec080e7          	jalr	-20(ra) # 800014b0 <copyinstr>
  if(err < 0)
    800034cc:	00054763          	bltz	a0,800034da <fetchstr+0x3a>
  return strlen(buf);
    800034d0:	8526                	mv	a0,s1
    800034d2:	ffffe097          	auipc	ra,0xffffe
    800034d6:	970080e7          	jalr	-1680(ra) # 80000e42 <strlen>
}
    800034da:	70a2                	ld	ra,40(sp)
    800034dc:	7402                	ld	s0,32(sp)
    800034de:	64e2                	ld	s1,24(sp)
    800034e0:	6942                	ld	s2,16(sp)
    800034e2:	69a2                	ld	s3,8(sp)
    800034e4:	6145                	addi	sp,sp,48
    800034e6:	8082                	ret

00000000800034e8 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800034e8:	1101                	addi	sp,sp,-32
    800034ea:	ec06                	sd	ra,24(sp)
    800034ec:	e822                	sd	s0,16(sp)
    800034ee:	e426                	sd	s1,8(sp)
    800034f0:	1000                	addi	s0,sp,32
    800034f2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800034f4:	00000097          	auipc	ra,0x0
    800034f8:	ef2080e7          	jalr	-270(ra) # 800033e6 <argraw>
    800034fc:	c088                	sw	a0,0(s1)
  return 0;
}
    800034fe:	4501                	li	a0,0
    80003500:	60e2                	ld	ra,24(sp)
    80003502:	6442                	ld	s0,16(sp)
    80003504:	64a2                	ld	s1,8(sp)
    80003506:	6105                	addi	sp,sp,32
    80003508:	8082                	ret

000000008000350a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    8000350a:	1101                	addi	sp,sp,-32
    8000350c:	ec06                	sd	ra,24(sp)
    8000350e:	e822                	sd	s0,16(sp)
    80003510:	e426                	sd	s1,8(sp)
    80003512:	1000                	addi	s0,sp,32
    80003514:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003516:	00000097          	auipc	ra,0x0
    8000351a:	ed0080e7          	jalr	-304(ra) # 800033e6 <argraw>
    8000351e:	e088                	sd	a0,0(s1)
  return 0;
}
    80003520:	4501                	li	a0,0
    80003522:	60e2                	ld	ra,24(sp)
    80003524:	6442                	ld	s0,16(sp)
    80003526:	64a2                	ld	s1,8(sp)
    80003528:	6105                	addi	sp,sp,32
    8000352a:	8082                	ret

000000008000352c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000352c:	1101                	addi	sp,sp,-32
    8000352e:	ec06                	sd	ra,24(sp)
    80003530:	e822                	sd	s0,16(sp)
    80003532:	e426                	sd	s1,8(sp)
    80003534:	e04a                	sd	s2,0(sp)
    80003536:	1000                	addi	s0,sp,32
    80003538:	84ae                	mv	s1,a1
    8000353a:	8932                	mv	s2,a2
  *ip = argraw(n);
    8000353c:	00000097          	auipc	ra,0x0
    80003540:	eaa080e7          	jalr	-342(ra) # 800033e6 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003544:	864a                	mv	a2,s2
    80003546:	85a6                	mv	a1,s1
    80003548:	00000097          	auipc	ra,0x0
    8000354c:	f58080e7          	jalr	-168(ra) # 800034a0 <fetchstr>
}
    80003550:	60e2                	ld	ra,24(sp)
    80003552:	6442                	ld	s0,16(sp)
    80003554:	64a2                	ld	s1,8(sp)
    80003556:	6902                	ld	s2,0(sp)
    80003558:	6105                	addi	sp,sp,32
    8000355a:	8082                	ret

000000008000355c <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    8000355c:	1101                	addi	sp,sp,-32
    8000355e:	ec06                	sd	ra,24(sp)
    80003560:	e822                	sd	s0,16(sp)
    80003562:	e426                	sd	s1,8(sp)
    80003564:	e04a                	sd	s2,0(sp)
    80003566:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003568:	ffffe097          	auipc	ra,0xffffe
    8000356c:	7cc080e7          	jalr	1996(ra) # 80001d34 <myproc>
    80003570:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003572:	05853903          	ld	s2,88(a0)
    80003576:	0a893783          	ld	a5,168(s2)
    8000357a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000357e:	37fd                	addiw	a5,a5,-1
    80003580:	4751                	li	a4,20
    80003582:	00f76f63          	bltu	a4,a5,800035a0 <syscall+0x44>
    80003586:	00369713          	slli	a4,a3,0x3
    8000358a:	00006797          	auipc	a5,0x6
    8000358e:	37678793          	addi	a5,a5,886 # 80009900 <syscalls>
    80003592:	97ba                	add	a5,a5,a4
    80003594:	639c                	ld	a5,0(a5)
    80003596:	c789                	beqz	a5,800035a0 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80003598:	9782                	jalr	a5
    8000359a:	06a93823          	sd	a0,112(s2)
    8000359e:	a839                	j	800035bc <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800035a0:	15848613          	addi	a2,s1,344
    800035a4:	588c                	lw	a1,48(s1)
    800035a6:	00006517          	auipc	a0,0x6
    800035aa:	32250513          	addi	a0,a0,802 # 800098c8 <states.0+0x208>
    800035ae:	ffffd097          	auipc	ra,0xffffd
    800035b2:	fc6080e7          	jalr	-58(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800035b6:	6cbc                	ld	a5,88(s1)
    800035b8:	577d                	li	a4,-1
    800035ba:	fbb8                	sd	a4,112(a5)
  }
}
    800035bc:	60e2                	ld	ra,24(sp)
    800035be:	6442                	ld	s0,16(sp)
    800035c0:	64a2                	ld	s1,8(sp)
    800035c2:	6902                	ld	s2,0(sp)
    800035c4:	6105                	addi	sp,sp,32
    800035c6:	8082                	ret

00000000800035c8 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800035c8:	1101                	addi	sp,sp,-32
    800035ca:	ec06                	sd	ra,24(sp)
    800035cc:	e822                	sd	s0,16(sp)
    800035ce:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800035d0:	fec40593          	addi	a1,s0,-20
    800035d4:	4501                	li	a0,0
    800035d6:	00000097          	auipc	ra,0x0
    800035da:	f12080e7          	jalr	-238(ra) # 800034e8 <argint>
    return -1;
    800035de:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800035e0:	00054963          	bltz	a0,800035f2 <sys_exit+0x2a>
  exit(n);
    800035e4:	fec42503          	lw	a0,-20(s0)
    800035e8:	fffff097          	auipc	ra,0xfffff
    800035ec:	ea0080e7          	jalr	-352(ra) # 80002488 <exit>
  return 0;  // not reached
    800035f0:	4781                	li	a5,0
}
    800035f2:	853e                	mv	a0,a5
    800035f4:	60e2                	ld	ra,24(sp)
    800035f6:	6442                	ld	s0,16(sp)
    800035f8:	6105                	addi	sp,sp,32
    800035fa:	8082                	ret

00000000800035fc <sys_getpid>:

uint64
sys_getpid(void)
{
    800035fc:	1141                	addi	sp,sp,-16
    800035fe:	e406                	sd	ra,8(sp)
    80003600:	e022                	sd	s0,0(sp)
    80003602:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003604:	ffffe097          	auipc	ra,0xffffe
    80003608:	730080e7          	jalr	1840(ra) # 80001d34 <myproc>
}
    8000360c:	5908                	lw	a0,48(a0)
    8000360e:	60a2                	ld	ra,8(sp)
    80003610:	6402                	ld	s0,0(sp)
    80003612:	0141                	addi	sp,sp,16
    80003614:	8082                	ret

0000000080003616 <sys_fork>:

uint64
sys_fork(void)
{
    80003616:	1141                	addi	sp,sp,-16
    80003618:	e406                	sd	ra,8(sp)
    8000361a:	e022                	sd	s0,0(sp)
    8000361c:	0800                	addi	s0,sp,16
  return fork();
    8000361e:	fffff097          	auipc	ra,0xfffff
    80003622:	3d8080e7          	jalr	984(ra) # 800029f6 <fork>
}
    80003626:	60a2                	ld	ra,8(sp)
    80003628:	6402                	ld	s0,0(sp)
    8000362a:	0141                	addi	sp,sp,16
    8000362c:	8082                	ret

000000008000362e <sys_wait>:

uint64
sys_wait(void)
{
    8000362e:	1101                	addi	sp,sp,-32
    80003630:	ec06                	sd	ra,24(sp)
    80003632:	e822                	sd	s0,16(sp)
    80003634:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003636:	fe840593          	addi	a1,s0,-24
    8000363a:	4501                	li	a0,0
    8000363c:	00000097          	auipc	ra,0x0
    80003640:	ece080e7          	jalr	-306(ra) # 8000350a <argaddr>
    80003644:	87aa                	mv	a5,a0
    return -1;
    80003646:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003648:	0007c863          	bltz	a5,80003658 <sys_wait+0x2a>
  return wait(p);
    8000364c:	fe843503          	ld	a0,-24(s0)
    80003650:	fffff097          	auipc	ra,0xfffff
    80003654:	c40080e7          	jalr	-960(ra) # 80002290 <wait>
}
    80003658:	60e2                	ld	ra,24(sp)
    8000365a:	6442                	ld	s0,16(sp)
    8000365c:	6105                	addi	sp,sp,32
    8000365e:	8082                	ret

0000000080003660 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003660:	7179                	addi	sp,sp,-48
    80003662:	f406                	sd	ra,40(sp)
    80003664:	f022                	sd	s0,32(sp)
    80003666:	ec26                	sd	s1,24(sp)
    80003668:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000366a:	fdc40593          	addi	a1,s0,-36
    8000366e:	4501                	li	a0,0
    80003670:	00000097          	auipc	ra,0x0
    80003674:	e78080e7          	jalr	-392(ra) # 800034e8 <argint>
    return -1;
    80003678:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    8000367a:	00054f63          	bltz	a0,80003698 <sys_sbrk+0x38>
  addr = myproc()->sz;
    8000367e:	ffffe097          	auipc	ra,0xffffe
    80003682:	6b6080e7          	jalr	1718(ra) # 80001d34 <myproc>
    80003686:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80003688:	fdc42503          	lw	a0,-36(s0)
    8000368c:	fffff097          	auipc	ra,0xfffff
    80003690:	a1a080e7          	jalr	-1510(ra) # 800020a6 <growproc>
    80003694:	00054863          	bltz	a0,800036a4 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003698:	8526                	mv	a0,s1
    8000369a:	70a2                	ld	ra,40(sp)
    8000369c:	7402                	ld	s0,32(sp)
    8000369e:	64e2                	ld	s1,24(sp)
    800036a0:	6145                	addi	sp,sp,48
    800036a2:	8082                	ret
    return -1;
    800036a4:	54fd                	li	s1,-1
    800036a6:	bfcd                	j	80003698 <sys_sbrk+0x38>

00000000800036a8 <sys_sleep>:

uint64
sys_sleep(void)
{
    800036a8:	7139                	addi	sp,sp,-64
    800036aa:	fc06                	sd	ra,56(sp)
    800036ac:	f822                	sd	s0,48(sp)
    800036ae:	f426                	sd	s1,40(sp)
    800036b0:	f04a                	sd	s2,32(sp)
    800036b2:	ec4e                	sd	s3,24(sp)
    800036b4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800036b6:	fcc40593          	addi	a1,s0,-52
    800036ba:	4501                	li	a0,0
    800036bc:	00000097          	auipc	ra,0x0
    800036c0:	e2c080e7          	jalr	-468(ra) # 800034e8 <argint>
    return -1;
    800036c4:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800036c6:	06054563          	bltz	a0,80003730 <sys_sleep+0x88>
  acquire(&tickslock);
    800036ca:	00021517          	auipc	a0,0x21
    800036ce:	40650513          	addi	a0,a0,1030 # 80024ad0 <tickslock>
    800036d2:	ffffd097          	auipc	ra,0xffffd
    800036d6:	4f0080e7          	jalr	1264(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    800036da:	00007917          	auipc	s2,0x7
    800036de:	95692903          	lw	s2,-1706(s2) # 8000a030 <ticks>
  while(ticks - ticks0 < n){
    800036e2:	fcc42783          	lw	a5,-52(s0)
    800036e6:	cf85                	beqz	a5,8000371e <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800036e8:	00021997          	auipc	s3,0x21
    800036ec:	3e898993          	addi	s3,s3,1000 # 80024ad0 <tickslock>
    800036f0:	00007497          	auipc	s1,0x7
    800036f4:	94048493          	addi	s1,s1,-1728 # 8000a030 <ticks>
    if(myproc()->killed){
    800036f8:	ffffe097          	auipc	ra,0xffffe
    800036fc:	63c080e7          	jalr	1596(ra) # 80001d34 <myproc>
    80003700:	551c                	lw	a5,40(a0)
    80003702:	ef9d                	bnez	a5,80003740 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003704:	85ce                	mv	a1,s3
    80003706:	8526                	mv	a0,s1
    80003708:	fffff097          	auipc	ra,0xfffff
    8000370c:	b24080e7          	jalr	-1244(ra) # 8000222c <sleep>
  while(ticks - ticks0 < n){
    80003710:	409c                	lw	a5,0(s1)
    80003712:	412787bb          	subw	a5,a5,s2
    80003716:	fcc42703          	lw	a4,-52(s0)
    8000371a:	fce7efe3          	bltu	a5,a4,800036f8 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000371e:	00021517          	auipc	a0,0x21
    80003722:	3b250513          	addi	a0,a0,946 # 80024ad0 <tickslock>
    80003726:	ffffd097          	auipc	ra,0xffffd
    8000372a:	550080e7          	jalr	1360(ra) # 80000c76 <release>
  return 0;
    8000372e:	4781                	li	a5,0
}
    80003730:	853e                	mv	a0,a5
    80003732:	70e2                	ld	ra,56(sp)
    80003734:	7442                	ld	s0,48(sp)
    80003736:	74a2                	ld	s1,40(sp)
    80003738:	7902                	ld	s2,32(sp)
    8000373a:	69e2                	ld	s3,24(sp)
    8000373c:	6121                	addi	sp,sp,64
    8000373e:	8082                	ret
      release(&tickslock);
    80003740:	00021517          	auipc	a0,0x21
    80003744:	39050513          	addi	a0,a0,912 # 80024ad0 <tickslock>
    80003748:	ffffd097          	auipc	ra,0xffffd
    8000374c:	52e080e7          	jalr	1326(ra) # 80000c76 <release>
      return -1;
    80003750:	57fd                	li	a5,-1
    80003752:	bff9                	j	80003730 <sys_sleep+0x88>

0000000080003754 <sys_kill>:

uint64
sys_kill(void)
{
    80003754:	1101                	addi	sp,sp,-32
    80003756:	ec06                	sd	ra,24(sp)
    80003758:	e822                	sd	s0,16(sp)
    8000375a:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000375c:	fec40593          	addi	a1,s0,-20
    80003760:	4501                	li	a0,0
    80003762:	00000097          	auipc	ra,0x0
    80003766:	d86080e7          	jalr	-634(ra) # 800034e8 <argint>
    8000376a:	87aa                	mv	a5,a0
    return -1;
    8000376c:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000376e:	0007c863          	bltz	a5,8000377e <sys_kill+0x2a>
  return kill(pid);
    80003772:	fec42503          	lw	a0,-20(s0)
    80003776:	fffff097          	auipc	ra,0xfffff
    8000377a:	df2080e7          	jalr	-526(ra) # 80002568 <kill>
}
    8000377e:	60e2                	ld	ra,24(sp)
    80003780:	6442                	ld	s0,16(sp)
    80003782:	6105                	addi	sp,sp,32
    80003784:	8082                	ret

0000000080003786 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003786:	1101                	addi	sp,sp,-32
    80003788:	ec06                	sd	ra,24(sp)
    8000378a:	e822                	sd	s0,16(sp)
    8000378c:	e426                	sd	s1,8(sp)
    8000378e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003790:	00021517          	auipc	a0,0x21
    80003794:	34050513          	addi	a0,a0,832 # 80024ad0 <tickslock>
    80003798:	ffffd097          	auipc	ra,0xffffd
    8000379c:	42a080e7          	jalr	1066(ra) # 80000bc2 <acquire>
  xticks = ticks;
    800037a0:	00007497          	auipc	s1,0x7
    800037a4:	8904a483          	lw	s1,-1904(s1) # 8000a030 <ticks>
  release(&tickslock);
    800037a8:	00021517          	auipc	a0,0x21
    800037ac:	32850513          	addi	a0,a0,808 # 80024ad0 <tickslock>
    800037b0:	ffffd097          	auipc	ra,0xffffd
    800037b4:	4c6080e7          	jalr	1222(ra) # 80000c76 <release>
  return xticks;
}
    800037b8:	02049513          	slli	a0,s1,0x20
    800037bc:	9101                	srli	a0,a0,0x20
    800037be:	60e2                	ld	ra,24(sp)
    800037c0:	6442                	ld	s0,16(sp)
    800037c2:	64a2                	ld	s1,8(sp)
    800037c4:	6105                	addi	sp,sp,32
    800037c6:	8082                	ret

00000000800037c8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800037c8:	7179                	addi	sp,sp,-48
    800037ca:	f406                	sd	ra,40(sp)
    800037cc:	f022                	sd	s0,32(sp)
    800037ce:	ec26                	sd	s1,24(sp)
    800037d0:	e84a                	sd	s2,16(sp)
    800037d2:	e44e                	sd	s3,8(sp)
    800037d4:	e052                	sd	s4,0(sp)
    800037d6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800037d8:	00006597          	auipc	a1,0x6
    800037dc:	1d858593          	addi	a1,a1,472 # 800099b0 <syscalls+0xb0>
    800037e0:	00021517          	auipc	a0,0x21
    800037e4:	30850513          	addi	a0,a0,776 # 80024ae8 <bcache>
    800037e8:	ffffd097          	auipc	ra,0xffffd
    800037ec:	34a080e7          	jalr	842(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800037f0:	00029797          	auipc	a5,0x29
    800037f4:	2f878793          	addi	a5,a5,760 # 8002cae8 <bcache+0x8000>
    800037f8:	00029717          	auipc	a4,0x29
    800037fc:	55870713          	addi	a4,a4,1368 # 8002cd50 <bcache+0x8268>
    80003800:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003804:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003808:	00021497          	auipc	s1,0x21
    8000380c:	2f848493          	addi	s1,s1,760 # 80024b00 <bcache+0x18>
    b->next = bcache.head.next;
    80003810:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003812:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003814:	00006a17          	auipc	s4,0x6
    80003818:	1a4a0a13          	addi	s4,s4,420 # 800099b8 <syscalls+0xb8>
    b->next = bcache.head.next;
    8000381c:	2b893783          	ld	a5,696(s2)
    80003820:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003822:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003826:	85d2                	mv	a1,s4
    80003828:	01048513          	addi	a0,s1,16
    8000382c:	00001097          	auipc	ra,0x1
    80003830:	7d4080e7          	jalr	2004(ra) # 80005000 <initsleeplock>
    bcache.head.next->prev = b;
    80003834:	2b893783          	ld	a5,696(s2)
    80003838:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000383a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000383e:	45848493          	addi	s1,s1,1112
    80003842:	fd349de3          	bne	s1,s3,8000381c <binit+0x54>
  }
}
    80003846:	70a2                	ld	ra,40(sp)
    80003848:	7402                	ld	s0,32(sp)
    8000384a:	64e2                	ld	s1,24(sp)
    8000384c:	6942                	ld	s2,16(sp)
    8000384e:	69a2                	ld	s3,8(sp)
    80003850:	6a02                	ld	s4,0(sp)
    80003852:	6145                	addi	sp,sp,48
    80003854:	8082                	ret

0000000080003856 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003856:	7179                	addi	sp,sp,-48
    80003858:	f406                	sd	ra,40(sp)
    8000385a:	f022                	sd	s0,32(sp)
    8000385c:	ec26                	sd	s1,24(sp)
    8000385e:	e84a                	sd	s2,16(sp)
    80003860:	e44e                	sd	s3,8(sp)
    80003862:	1800                	addi	s0,sp,48
    80003864:	892a                	mv	s2,a0
    80003866:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003868:	00021517          	auipc	a0,0x21
    8000386c:	28050513          	addi	a0,a0,640 # 80024ae8 <bcache>
    80003870:	ffffd097          	auipc	ra,0xffffd
    80003874:	352080e7          	jalr	850(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003878:	00029497          	auipc	s1,0x29
    8000387c:	5284b483          	ld	s1,1320(s1) # 8002cda0 <bcache+0x82b8>
    80003880:	00029797          	auipc	a5,0x29
    80003884:	4d078793          	addi	a5,a5,1232 # 8002cd50 <bcache+0x8268>
    80003888:	02f48f63          	beq	s1,a5,800038c6 <bread+0x70>
    8000388c:	873e                	mv	a4,a5
    8000388e:	a021                	j	80003896 <bread+0x40>
    80003890:	68a4                	ld	s1,80(s1)
    80003892:	02e48a63          	beq	s1,a4,800038c6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003896:	449c                	lw	a5,8(s1)
    80003898:	ff279ce3          	bne	a5,s2,80003890 <bread+0x3a>
    8000389c:	44dc                	lw	a5,12(s1)
    8000389e:	ff3799e3          	bne	a5,s3,80003890 <bread+0x3a>
      b->refcnt++;
    800038a2:	40bc                	lw	a5,64(s1)
    800038a4:	2785                	addiw	a5,a5,1
    800038a6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800038a8:	00021517          	auipc	a0,0x21
    800038ac:	24050513          	addi	a0,a0,576 # 80024ae8 <bcache>
    800038b0:	ffffd097          	auipc	ra,0xffffd
    800038b4:	3c6080e7          	jalr	966(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    800038b8:	01048513          	addi	a0,s1,16
    800038bc:	00001097          	auipc	ra,0x1
    800038c0:	77e080e7          	jalr	1918(ra) # 8000503a <acquiresleep>
      return b;
    800038c4:	a8b9                	j	80003922 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800038c6:	00029497          	auipc	s1,0x29
    800038ca:	4d24b483          	ld	s1,1234(s1) # 8002cd98 <bcache+0x82b0>
    800038ce:	00029797          	auipc	a5,0x29
    800038d2:	48278793          	addi	a5,a5,1154 # 8002cd50 <bcache+0x8268>
    800038d6:	00f48863          	beq	s1,a5,800038e6 <bread+0x90>
    800038da:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800038dc:	40bc                	lw	a5,64(s1)
    800038de:	cf81                	beqz	a5,800038f6 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800038e0:	64a4                	ld	s1,72(s1)
    800038e2:	fee49de3          	bne	s1,a4,800038dc <bread+0x86>
  panic("bget: no buffers");
    800038e6:	00006517          	auipc	a0,0x6
    800038ea:	0da50513          	addi	a0,a0,218 # 800099c0 <syscalls+0xc0>
    800038ee:	ffffd097          	auipc	ra,0xffffd
    800038f2:	c3c080e7          	jalr	-964(ra) # 8000052a <panic>
      b->dev = dev;
    800038f6:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800038fa:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800038fe:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003902:	4785                	li	a5,1
    80003904:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003906:	00021517          	auipc	a0,0x21
    8000390a:	1e250513          	addi	a0,a0,482 # 80024ae8 <bcache>
    8000390e:	ffffd097          	auipc	ra,0xffffd
    80003912:	368080e7          	jalr	872(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003916:	01048513          	addi	a0,s1,16
    8000391a:	00001097          	auipc	ra,0x1
    8000391e:	720080e7          	jalr	1824(ra) # 8000503a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003922:	409c                	lw	a5,0(s1)
    80003924:	cb89                	beqz	a5,80003936 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003926:	8526                	mv	a0,s1
    80003928:	70a2                	ld	ra,40(sp)
    8000392a:	7402                	ld	s0,32(sp)
    8000392c:	64e2                	ld	s1,24(sp)
    8000392e:	6942                	ld	s2,16(sp)
    80003930:	69a2                	ld	s3,8(sp)
    80003932:	6145                	addi	sp,sp,48
    80003934:	8082                	ret
    virtio_disk_rw(b, 0);
    80003936:	4581                	li	a1,0
    80003938:	8526                	mv	a0,s1
    8000393a:	00003097          	auipc	ra,0x3
    8000393e:	46c080e7          	jalr	1132(ra) # 80006da6 <virtio_disk_rw>
    b->valid = 1;
    80003942:	4785                	li	a5,1
    80003944:	c09c                	sw	a5,0(s1)
  return b;
    80003946:	b7c5                	j	80003926 <bread+0xd0>

0000000080003948 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003948:	1101                	addi	sp,sp,-32
    8000394a:	ec06                	sd	ra,24(sp)
    8000394c:	e822                	sd	s0,16(sp)
    8000394e:	e426                	sd	s1,8(sp)
    80003950:	1000                	addi	s0,sp,32
    80003952:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003954:	0541                	addi	a0,a0,16
    80003956:	00001097          	auipc	ra,0x1
    8000395a:	77e080e7          	jalr	1918(ra) # 800050d4 <holdingsleep>
    8000395e:	cd01                	beqz	a0,80003976 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003960:	4585                	li	a1,1
    80003962:	8526                	mv	a0,s1
    80003964:	00003097          	auipc	ra,0x3
    80003968:	442080e7          	jalr	1090(ra) # 80006da6 <virtio_disk_rw>
}
    8000396c:	60e2                	ld	ra,24(sp)
    8000396e:	6442                	ld	s0,16(sp)
    80003970:	64a2                	ld	s1,8(sp)
    80003972:	6105                	addi	sp,sp,32
    80003974:	8082                	ret
    panic("bwrite");
    80003976:	00006517          	auipc	a0,0x6
    8000397a:	06250513          	addi	a0,a0,98 # 800099d8 <syscalls+0xd8>
    8000397e:	ffffd097          	auipc	ra,0xffffd
    80003982:	bac080e7          	jalr	-1108(ra) # 8000052a <panic>

0000000080003986 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003986:	1101                	addi	sp,sp,-32
    80003988:	ec06                	sd	ra,24(sp)
    8000398a:	e822                	sd	s0,16(sp)
    8000398c:	e426                	sd	s1,8(sp)
    8000398e:	e04a                	sd	s2,0(sp)
    80003990:	1000                	addi	s0,sp,32
    80003992:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003994:	01050913          	addi	s2,a0,16
    80003998:	854a                	mv	a0,s2
    8000399a:	00001097          	auipc	ra,0x1
    8000399e:	73a080e7          	jalr	1850(ra) # 800050d4 <holdingsleep>
    800039a2:	c92d                	beqz	a0,80003a14 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800039a4:	854a                	mv	a0,s2
    800039a6:	00001097          	auipc	ra,0x1
    800039aa:	6ea080e7          	jalr	1770(ra) # 80005090 <releasesleep>

  acquire(&bcache.lock);
    800039ae:	00021517          	auipc	a0,0x21
    800039b2:	13a50513          	addi	a0,a0,314 # 80024ae8 <bcache>
    800039b6:	ffffd097          	auipc	ra,0xffffd
    800039ba:	20c080e7          	jalr	524(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800039be:	40bc                	lw	a5,64(s1)
    800039c0:	37fd                	addiw	a5,a5,-1
    800039c2:	0007871b          	sext.w	a4,a5
    800039c6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800039c8:	eb05                	bnez	a4,800039f8 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800039ca:	68bc                	ld	a5,80(s1)
    800039cc:	64b8                	ld	a4,72(s1)
    800039ce:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800039d0:	64bc                	ld	a5,72(s1)
    800039d2:	68b8                	ld	a4,80(s1)
    800039d4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800039d6:	00029797          	auipc	a5,0x29
    800039da:	11278793          	addi	a5,a5,274 # 8002cae8 <bcache+0x8000>
    800039de:	2b87b703          	ld	a4,696(a5)
    800039e2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800039e4:	00029717          	auipc	a4,0x29
    800039e8:	36c70713          	addi	a4,a4,876 # 8002cd50 <bcache+0x8268>
    800039ec:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800039ee:	2b87b703          	ld	a4,696(a5)
    800039f2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800039f4:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800039f8:	00021517          	auipc	a0,0x21
    800039fc:	0f050513          	addi	a0,a0,240 # 80024ae8 <bcache>
    80003a00:	ffffd097          	auipc	ra,0xffffd
    80003a04:	276080e7          	jalr	630(ra) # 80000c76 <release>
}
    80003a08:	60e2                	ld	ra,24(sp)
    80003a0a:	6442                	ld	s0,16(sp)
    80003a0c:	64a2                	ld	s1,8(sp)
    80003a0e:	6902                	ld	s2,0(sp)
    80003a10:	6105                	addi	sp,sp,32
    80003a12:	8082                	ret
    panic("brelse");
    80003a14:	00006517          	auipc	a0,0x6
    80003a18:	fcc50513          	addi	a0,a0,-52 # 800099e0 <syscalls+0xe0>
    80003a1c:	ffffd097          	auipc	ra,0xffffd
    80003a20:	b0e080e7          	jalr	-1266(ra) # 8000052a <panic>

0000000080003a24 <bpin>:

void
bpin(struct buf *b) {
    80003a24:	1101                	addi	sp,sp,-32
    80003a26:	ec06                	sd	ra,24(sp)
    80003a28:	e822                	sd	s0,16(sp)
    80003a2a:	e426                	sd	s1,8(sp)
    80003a2c:	1000                	addi	s0,sp,32
    80003a2e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003a30:	00021517          	auipc	a0,0x21
    80003a34:	0b850513          	addi	a0,a0,184 # 80024ae8 <bcache>
    80003a38:	ffffd097          	auipc	ra,0xffffd
    80003a3c:	18a080e7          	jalr	394(ra) # 80000bc2 <acquire>
  b->refcnt++;
    80003a40:	40bc                	lw	a5,64(s1)
    80003a42:	2785                	addiw	a5,a5,1
    80003a44:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003a46:	00021517          	auipc	a0,0x21
    80003a4a:	0a250513          	addi	a0,a0,162 # 80024ae8 <bcache>
    80003a4e:	ffffd097          	auipc	ra,0xffffd
    80003a52:	228080e7          	jalr	552(ra) # 80000c76 <release>
}
    80003a56:	60e2                	ld	ra,24(sp)
    80003a58:	6442                	ld	s0,16(sp)
    80003a5a:	64a2                	ld	s1,8(sp)
    80003a5c:	6105                	addi	sp,sp,32
    80003a5e:	8082                	ret

0000000080003a60 <bunpin>:

void
bunpin(struct buf *b) {
    80003a60:	1101                	addi	sp,sp,-32
    80003a62:	ec06                	sd	ra,24(sp)
    80003a64:	e822                	sd	s0,16(sp)
    80003a66:	e426                	sd	s1,8(sp)
    80003a68:	1000                	addi	s0,sp,32
    80003a6a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003a6c:	00021517          	auipc	a0,0x21
    80003a70:	07c50513          	addi	a0,a0,124 # 80024ae8 <bcache>
    80003a74:	ffffd097          	auipc	ra,0xffffd
    80003a78:	14e080e7          	jalr	334(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003a7c:	40bc                	lw	a5,64(s1)
    80003a7e:	37fd                	addiw	a5,a5,-1
    80003a80:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003a82:	00021517          	auipc	a0,0x21
    80003a86:	06650513          	addi	a0,a0,102 # 80024ae8 <bcache>
    80003a8a:	ffffd097          	auipc	ra,0xffffd
    80003a8e:	1ec080e7          	jalr	492(ra) # 80000c76 <release>
}
    80003a92:	60e2                	ld	ra,24(sp)
    80003a94:	6442                	ld	s0,16(sp)
    80003a96:	64a2                	ld	s1,8(sp)
    80003a98:	6105                	addi	sp,sp,32
    80003a9a:	8082                	ret

0000000080003a9c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003a9c:	1101                	addi	sp,sp,-32
    80003a9e:	ec06                	sd	ra,24(sp)
    80003aa0:	e822                	sd	s0,16(sp)
    80003aa2:	e426                	sd	s1,8(sp)
    80003aa4:	e04a                	sd	s2,0(sp)
    80003aa6:	1000                	addi	s0,sp,32
    80003aa8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003aaa:	00d5d59b          	srliw	a1,a1,0xd
    80003aae:	00029797          	auipc	a5,0x29
    80003ab2:	7167a783          	lw	a5,1814(a5) # 8002d1c4 <sb+0x1c>
    80003ab6:	9dbd                	addw	a1,a1,a5
    80003ab8:	00000097          	auipc	ra,0x0
    80003abc:	d9e080e7          	jalr	-610(ra) # 80003856 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003ac0:	0074f713          	andi	a4,s1,7
    80003ac4:	4785                	li	a5,1
    80003ac6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003aca:	14ce                	slli	s1,s1,0x33
    80003acc:	90d9                	srli	s1,s1,0x36
    80003ace:	00950733          	add	a4,a0,s1
    80003ad2:	05874703          	lbu	a4,88(a4)
    80003ad6:	00e7f6b3          	and	a3,a5,a4
    80003ada:	c69d                	beqz	a3,80003b08 <bfree+0x6c>
    80003adc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003ade:	94aa                	add	s1,s1,a0
    80003ae0:	fff7c793          	not	a5,a5
    80003ae4:	8ff9                	and	a5,a5,a4
    80003ae6:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003aea:	00001097          	auipc	ra,0x1
    80003aee:	430080e7          	jalr	1072(ra) # 80004f1a <log_write>
  brelse(bp);
    80003af2:	854a                	mv	a0,s2
    80003af4:	00000097          	auipc	ra,0x0
    80003af8:	e92080e7          	jalr	-366(ra) # 80003986 <brelse>
}
    80003afc:	60e2                	ld	ra,24(sp)
    80003afe:	6442                	ld	s0,16(sp)
    80003b00:	64a2                	ld	s1,8(sp)
    80003b02:	6902                	ld	s2,0(sp)
    80003b04:	6105                	addi	sp,sp,32
    80003b06:	8082                	ret
    panic("freeing free block");
    80003b08:	00006517          	auipc	a0,0x6
    80003b0c:	ee050513          	addi	a0,a0,-288 # 800099e8 <syscalls+0xe8>
    80003b10:	ffffd097          	auipc	ra,0xffffd
    80003b14:	a1a080e7          	jalr	-1510(ra) # 8000052a <panic>

0000000080003b18 <balloc>:
{
    80003b18:	711d                	addi	sp,sp,-96
    80003b1a:	ec86                	sd	ra,88(sp)
    80003b1c:	e8a2                	sd	s0,80(sp)
    80003b1e:	e4a6                	sd	s1,72(sp)
    80003b20:	e0ca                	sd	s2,64(sp)
    80003b22:	fc4e                	sd	s3,56(sp)
    80003b24:	f852                	sd	s4,48(sp)
    80003b26:	f456                	sd	s5,40(sp)
    80003b28:	f05a                	sd	s6,32(sp)
    80003b2a:	ec5e                	sd	s7,24(sp)
    80003b2c:	e862                	sd	s8,16(sp)
    80003b2e:	e466                	sd	s9,8(sp)
    80003b30:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003b32:	00029797          	auipc	a5,0x29
    80003b36:	67a7a783          	lw	a5,1658(a5) # 8002d1ac <sb+0x4>
    80003b3a:	cbd1                	beqz	a5,80003bce <balloc+0xb6>
    80003b3c:	8baa                	mv	s7,a0
    80003b3e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003b40:	00029b17          	auipc	s6,0x29
    80003b44:	668b0b13          	addi	s6,s6,1640 # 8002d1a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b48:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003b4a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b4c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003b4e:	6c89                	lui	s9,0x2
    80003b50:	a831                	j	80003b6c <balloc+0x54>
    brelse(bp);
    80003b52:	854a                	mv	a0,s2
    80003b54:	00000097          	auipc	ra,0x0
    80003b58:	e32080e7          	jalr	-462(ra) # 80003986 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003b5c:	015c87bb          	addw	a5,s9,s5
    80003b60:	00078a9b          	sext.w	s5,a5
    80003b64:	004b2703          	lw	a4,4(s6)
    80003b68:	06eaf363          	bgeu	s5,a4,80003bce <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003b6c:	41fad79b          	sraiw	a5,s5,0x1f
    80003b70:	0137d79b          	srliw	a5,a5,0x13
    80003b74:	015787bb          	addw	a5,a5,s5
    80003b78:	40d7d79b          	sraiw	a5,a5,0xd
    80003b7c:	01cb2583          	lw	a1,28(s6)
    80003b80:	9dbd                	addw	a1,a1,a5
    80003b82:	855e                	mv	a0,s7
    80003b84:	00000097          	auipc	ra,0x0
    80003b88:	cd2080e7          	jalr	-814(ra) # 80003856 <bread>
    80003b8c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b8e:	004b2503          	lw	a0,4(s6)
    80003b92:	000a849b          	sext.w	s1,s5
    80003b96:	8662                	mv	a2,s8
    80003b98:	faa4fde3          	bgeu	s1,a0,80003b52 <balloc+0x3a>
      m = 1 << (bi % 8);
    80003b9c:	41f6579b          	sraiw	a5,a2,0x1f
    80003ba0:	01d7d69b          	srliw	a3,a5,0x1d
    80003ba4:	00c6873b          	addw	a4,a3,a2
    80003ba8:	00777793          	andi	a5,a4,7
    80003bac:	9f95                	subw	a5,a5,a3
    80003bae:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003bb2:	4037571b          	sraiw	a4,a4,0x3
    80003bb6:	00e906b3          	add	a3,s2,a4
    80003bba:	0586c683          	lbu	a3,88(a3)
    80003bbe:	00d7f5b3          	and	a1,a5,a3
    80003bc2:	cd91                	beqz	a1,80003bde <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003bc4:	2605                	addiw	a2,a2,1
    80003bc6:	2485                	addiw	s1,s1,1
    80003bc8:	fd4618e3          	bne	a2,s4,80003b98 <balloc+0x80>
    80003bcc:	b759                	j	80003b52 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003bce:	00006517          	auipc	a0,0x6
    80003bd2:	e3250513          	addi	a0,a0,-462 # 80009a00 <syscalls+0x100>
    80003bd6:	ffffd097          	auipc	ra,0xffffd
    80003bda:	954080e7          	jalr	-1708(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003bde:	974a                	add	a4,a4,s2
    80003be0:	8fd5                	or	a5,a5,a3
    80003be2:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003be6:	854a                	mv	a0,s2
    80003be8:	00001097          	auipc	ra,0x1
    80003bec:	332080e7          	jalr	818(ra) # 80004f1a <log_write>
        brelse(bp);
    80003bf0:	854a                	mv	a0,s2
    80003bf2:	00000097          	auipc	ra,0x0
    80003bf6:	d94080e7          	jalr	-620(ra) # 80003986 <brelse>
  bp = bread(dev, bno);
    80003bfa:	85a6                	mv	a1,s1
    80003bfc:	855e                	mv	a0,s7
    80003bfe:	00000097          	auipc	ra,0x0
    80003c02:	c58080e7          	jalr	-936(ra) # 80003856 <bread>
    80003c06:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003c08:	40000613          	li	a2,1024
    80003c0c:	4581                	li	a1,0
    80003c0e:	05850513          	addi	a0,a0,88
    80003c12:	ffffd097          	auipc	ra,0xffffd
    80003c16:	0ac080e7          	jalr	172(ra) # 80000cbe <memset>
  log_write(bp);
    80003c1a:	854a                	mv	a0,s2
    80003c1c:	00001097          	auipc	ra,0x1
    80003c20:	2fe080e7          	jalr	766(ra) # 80004f1a <log_write>
  brelse(bp);
    80003c24:	854a                	mv	a0,s2
    80003c26:	00000097          	auipc	ra,0x0
    80003c2a:	d60080e7          	jalr	-672(ra) # 80003986 <brelse>
}
    80003c2e:	8526                	mv	a0,s1
    80003c30:	60e6                	ld	ra,88(sp)
    80003c32:	6446                	ld	s0,80(sp)
    80003c34:	64a6                	ld	s1,72(sp)
    80003c36:	6906                	ld	s2,64(sp)
    80003c38:	79e2                	ld	s3,56(sp)
    80003c3a:	7a42                	ld	s4,48(sp)
    80003c3c:	7aa2                	ld	s5,40(sp)
    80003c3e:	7b02                	ld	s6,32(sp)
    80003c40:	6be2                	ld	s7,24(sp)
    80003c42:	6c42                	ld	s8,16(sp)
    80003c44:	6ca2                	ld	s9,8(sp)
    80003c46:	6125                	addi	sp,sp,96
    80003c48:	8082                	ret

0000000080003c4a <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003c4a:	7179                	addi	sp,sp,-48
    80003c4c:	f406                	sd	ra,40(sp)
    80003c4e:	f022                	sd	s0,32(sp)
    80003c50:	ec26                	sd	s1,24(sp)
    80003c52:	e84a                	sd	s2,16(sp)
    80003c54:	e44e                	sd	s3,8(sp)
    80003c56:	e052                	sd	s4,0(sp)
    80003c58:	1800                	addi	s0,sp,48
    80003c5a:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003c5c:	47ad                	li	a5,11
    80003c5e:	04b7fe63          	bgeu	a5,a1,80003cba <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003c62:	ff45849b          	addiw	s1,a1,-12
    80003c66:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003c6a:	0ff00793          	li	a5,255
    80003c6e:	0ae7e463          	bltu	a5,a4,80003d16 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003c72:	08052583          	lw	a1,128(a0)
    80003c76:	c5b5                	beqz	a1,80003ce2 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003c78:	00092503          	lw	a0,0(s2)
    80003c7c:	00000097          	auipc	ra,0x0
    80003c80:	bda080e7          	jalr	-1062(ra) # 80003856 <bread>
    80003c84:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003c86:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003c8a:	02049713          	slli	a4,s1,0x20
    80003c8e:	01e75593          	srli	a1,a4,0x1e
    80003c92:	00b784b3          	add	s1,a5,a1
    80003c96:	0004a983          	lw	s3,0(s1)
    80003c9a:	04098e63          	beqz	s3,80003cf6 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003c9e:	8552                	mv	a0,s4
    80003ca0:	00000097          	auipc	ra,0x0
    80003ca4:	ce6080e7          	jalr	-794(ra) # 80003986 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003ca8:	854e                	mv	a0,s3
    80003caa:	70a2                	ld	ra,40(sp)
    80003cac:	7402                	ld	s0,32(sp)
    80003cae:	64e2                	ld	s1,24(sp)
    80003cb0:	6942                	ld	s2,16(sp)
    80003cb2:	69a2                	ld	s3,8(sp)
    80003cb4:	6a02                	ld	s4,0(sp)
    80003cb6:	6145                	addi	sp,sp,48
    80003cb8:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003cba:	02059793          	slli	a5,a1,0x20
    80003cbe:	01e7d593          	srli	a1,a5,0x1e
    80003cc2:	00b504b3          	add	s1,a0,a1
    80003cc6:	0504a983          	lw	s3,80(s1)
    80003cca:	fc099fe3          	bnez	s3,80003ca8 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003cce:	4108                	lw	a0,0(a0)
    80003cd0:	00000097          	auipc	ra,0x0
    80003cd4:	e48080e7          	jalr	-440(ra) # 80003b18 <balloc>
    80003cd8:	0005099b          	sext.w	s3,a0
    80003cdc:	0534a823          	sw	s3,80(s1)
    80003ce0:	b7e1                	j	80003ca8 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003ce2:	4108                	lw	a0,0(a0)
    80003ce4:	00000097          	auipc	ra,0x0
    80003ce8:	e34080e7          	jalr	-460(ra) # 80003b18 <balloc>
    80003cec:	0005059b          	sext.w	a1,a0
    80003cf0:	08b92023          	sw	a1,128(s2)
    80003cf4:	b751                	j	80003c78 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003cf6:	00092503          	lw	a0,0(s2)
    80003cfa:	00000097          	auipc	ra,0x0
    80003cfe:	e1e080e7          	jalr	-482(ra) # 80003b18 <balloc>
    80003d02:	0005099b          	sext.w	s3,a0
    80003d06:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003d0a:	8552                	mv	a0,s4
    80003d0c:	00001097          	auipc	ra,0x1
    80003d10:	20e080e7          	jalr	526(ra) # 80004f1a <log_write>
    80003d14:	b769                	j	80003c9e <bmap+0x54>
  panic("bmap: out of range");
    80003d16:	00006517          	auipc	a0,0x6
    80003d1a:	d0250513          	addi	a0,a0,-766 # 80009a18 <syscalls+0x118>
    80003d1e:	ffffd097          	auipc	ra,0xffffd
    80003d22:	80c080e7          	jalr	-2036(ra) # 8000052a <panic>

0000000080003d26 <iget>:
{
    80003d26:	7179                	addi	sp,sp,-48
    80003d28:	f406                	sd	ra,40(sp)
    80003d2a:	f022                	sd	s0,32(sp)
    80003d2c:	ec26                	sd	s1,24(sp)
    80003d2e:	e84a                	sd	s2,16(sp)
    80003d30:	e44e                	sd	s3,8(sp)
    80003d32:	e052                	sd	s4,0(sp)
    80003d34:	1800                	addi	s0,sp,48
    80003d36:	89aa                	mv	s3,a0
    80003d38:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003d3a:	00029517          	auipc	a0,0x29
    80003d3e:	48e50513          	addi	a0,a0,1166 # 8002d1c8 <itable>
    80003d42:	ffffd097          	auipc	ra,0xffffd
    80003d46:	e80080e7          	jalr	-384(ra) # 80000bc2 <acquire>
  empty = 0;
    80003d4a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003d4c:	00029497          	auipc	s1,0x29
    80003d50:	49448493          	addi	s1,s1,1172 # 8002d1e0 <itable+0x18>
    80003d54:	0002b697          	auipc	a3,0x2b
    80003d58:	f1c68693          	addi	a3,a3,-228 # 8002ec70 <log>
    80003d5c:	a039                	j	80003d6a <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003d5e:	02090b63          	beqz	s2,80003d94 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003d62:	08848493          	addi	s1,s1,136
    80003d66:	02d48a63          	beq	s1,a3,80003d9a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003d6a:	449c                	lw	a5,8(s1)
    80003d6c:	fef059e3          	blez	a5,80003d5e <iget+0x38>
    80003d70:	4098                	lw	a4,0(s1)
    80003d72:	ff3716e3          	bne	a4,s3,80003d5e <iget+0x38>
    80003d76:	40d8                	lw	a4,4(s1)
    80003d78:	ff4713e3          	bne	a4,s4,80003d5e <iget+0x38>
      ip->ref++;
    80003d7c:	2785                	addiw	a5,a5,1
    80003d7e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003d80:	00029517          	auipc	a0,0x29
    80003d84:	44850513          	addi	a0,a0,1096 # 8002d1c8 <itable>
    80003d88:	ffffd097          	auipc	ra,0xffffd
    80003d8c:	eee080e7          	jalr	-274(ra) # 80000c76 <release>
      return ip;
    80003d90:	8926                	mv	s2,s1
    80003d92:	a03d                	j	80003dc0 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003d94:	f7f9                	bnez	a5,80003d62 <iget+0x3c>
    80003d96:	8926                	mv	s2,s1
    80003d98:	b7e9                	j	80003d62 <iget+0x3c>
  if(empty == 0)
    80003d9a:	02090c63          	beqz	s2,80003dd2 <iget+0xac>
  ip->dev = dev;
    80003d9e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003da2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003da6:	4785                	li	a5,1
    80003da8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003dac:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003db0:	00029517          	auipc	a0,0x29
    80003db4:	41850513          	addi	a0,a0,1048 # 8002d1c8 <itable>
    80003db8:	ffffd097          	auipc	ra,0xffffd
    80003dbc:	ebe080e7          	jalr	-322(ra) # 80000c76 <release>
}
    80003dc0:	854a                	mv	a0,s2
    80003dc2:	70a2                	ld	ra,40(sp)
    80003dc4:	7402                	ld	s0,32(sp)
    80003dc6:	64e2                	ld	s1,24(sp)
    80003dc8:	6942                	ld	s2,16(sp)
    80003dca:	69a2                	ld	s3,8(sp)
    80003dcc:	6a02                	ld	s4,0(sp)
    80003dce:	6145                	addi	sp,sp,48
    80003dd0:	8082                	ret
    panic("iget: no inodes");
    80003dd2:	00006517          	auipc	a0,0x6
    80003dd6:	c5e50513          	addi	a0,a0,-930 # 80009a30 <syscalls+0x130>
    80003dda:	ffffc097          	auipc	ra,0xffffc
    80003dde:	750080e7          	jalr	1872(ra) # 8000052a <panic>

0000000080003de2 <fsinit>:
fsinit(int dev) {
    80003de2:	7179                	addi	sp,sp,-48
    80003de4:	f406                	sd	ra,40(sp)
    80003de6:	f022                	sd	s0,32(sp)
    80003de8:	ec26                	sd	s1,24(sp)
    80003dea:	e84a                	sd	s2,16(sp)
    80003dec:	e44e                	sd	s3,8(sp)
    80003dee:	1800                	addi	s0,sp,48
    80003df0:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003df2:	4585                	li	a1,1
    80003df4:	00000097          	auipc	ra,0x0
    80003df8:	a62080e7          	jalr	-1438(ra) # 80003856 <bread>
    80003dfc:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003dfe:	00029997          	auipc	s3,0x29
    80003e02:	3aa98993          	addi	s3,s3,938 # 8002d1a8 <sb>
    80003e06:	02000613          	li	a2,32
    80003e0a:	05850593          	addi	a1,a0,88
    80003e0e:	854e                	mv	a0,s3
    80003e10:	ffffd097          	auipc	ra,0xffffd
    80003e14:	f0a080e7          	jalr	-246(ra) # 80000d1a <memmove>
  brelse(bp);
    80003e18:	8526                	mv	a0,s1
    80003e1a:	00000097          	auipc	ra,0x0
    80003e1e:	b6c080e7          	jalr	-1172(ra) # 80003986 <brelse>
  if(sb.magic != FSMAGIC)
    80003e22:	0009a703          	lw	a4,0(s3)
    80003e26:	102037b7          	lui	a5,0x10203
    80003e2a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003e2e:	02f71263          	bne	a4,a5,80003e52 <fsinit+0x70>
  initlog(dev, &sb);
    80003e32:	00029597          	auipc	a1,0x29
    80003e36:	37658593          	addi	a1,a1,886 # 8002d1a8 <sb>
    80003e3a:	854a                	mv	a0,s2
    80003e3c:	00001097          	auipc	ra,0x1
    80003e40:	e60080e7          	jalr	-416(ra) # 80004c9c <initlog>
}
    80003e44:	70a2                	ld	ra,40(sp)
    80003e46:	7402                	ld	s0,32(sp)
    80003e48:	64e2                	ld	s1,24(sp)
    80003e4a:	6942                	ld	s2,16(sp)
    80003e4c:	69a2                	ld	s3,8(sp)
    80003e4e:	6145                	addi	sp,sp,48
    80003e50:	8082                	ret
    panic("invalid file system");
    80003e52:	00006517          	auipc	a0,0x6
    80003e56:	bee50513          	addi	a0,a0,-1042 # 80009a40 <syscalls+0x140>
    80003e5a:	ffffc097          	auipc	ra,0xffffc
    80003e5e:	6d0080e7          	jalr	1744(ra) # 8000052a <panic>

0000000080003e62 <iinit>:
{
    80003e62:	7179                	addi	sp,sp,-48
    80003e64:	f406                	sd	ra,40(sp)
    80003e66:	f022                	sd	s0,32(sp)
    80003e68:	ec26                	sd	s1,24(sp)
    80003e6a:	e84a                	sd	s2,16(sp)
    80003e6c:	e44e                	sd	s3,8(sp)
    80003e6e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003e70:	00006597          	auipc	a1,0x6
    80003e74:	be858593          	addi	a1,a1,-1048 # 80009a58 <syscalls+0x158>
    80003e78:	00029517          	auipc	a0,0x29
    80003e7c:	35050513          	addi	a0,a0,848 # 8002d1c8 <itable>
    80003e80:	ffffd097          	auipc	ra,0xffffd
    80003e84:	cb2080e7          	jalr	-846(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003e88:	00029497          	auipc	s1,0x29
    80003e8c:	36848493          	addi	s1,s1,872 # 8002d1f0 <itable+0x28>
    80003e90:	0002b997          	auipc	s3,0x2b
    80003e94:	df098993          	addi	s3,s3,-528 # 8002ec80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003e98:	00006917          	auipc	s2,0x6
    80003e9c:	bc890913          	addi	s2,s2,-1080 # 80009a60 <syscalls+0x160>
    80003ea0:	85ca                	mv	a1,s2
    80003ea2:	8526                	mv	a0,s1
    80003ea4:	00001097          	auipc	ra,0x1
    80003ea8:	15c080e7          	jalr	348(ra) # 80005000 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003eac:	08848493          	addi	s1,s1,136
    80003eb0:	ff3498e3          	bne	s1,s3,80003ea0 <iinit+0x3e>
}
    80003eb4:	70a2                	ld	ra,40(sp)
    80003eb6:	7402                	ld	s0,32(sp)
    80003eb8:	64e2                	ld	s1,24(sp)
    80003eba:	6942                	ld	s2,16(sp)
    80003ebc:	69a2                	ld	s3,8(sp)
    80003ebe:	6145                	addi	sp,sp,48
    80003ec0:	8082                	ret

0000000080003ec2 <ialloc>:
{
    80003ec2:	715d                	addi	sp,sp,-80
    80003ec4:	e486                	sd	ra,72(sp)
    80003ec6:	e0a2                	sd	s0,64(sp)
    80003ec8:	fc26                	sd	s1,56(sp)
    80003eca:	f84a                	sd	s2,48(sp)
    80003ecc:	f44e                	sd	s3,40(sp)
    80003ece:	f052                	sd	s4,32(sp)
    80003ed0:	ec56                	sd	s5,24(sp)
    80003ed2:	e85a                	sd	s6,16(sp)
    80003ed4:	e45e                	sd	s7,8(sp)
    80003ed6:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ed8:	00029717          	auipc	a4,0x29
    80003edc:	2dc72703          	lw	a4,732(a4) # 8002d1b4 <sb+0xc>
    80003ee0:	4785                	li	a5,1
    80003ee2:	04e7fa63          	bgeu	a5,a4,80003f36 <ialloc+0x74>
    80003ee6:	8aaa                	mv	s5,a0
    80003ee8:	8bae                	mv	s7,a1
    80003eea:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003eec:	00029a17          	auipc	s4,0x29
    80003ef0:	2bca0a13          	addi	s4,s4,700 # 8002d1a8 <sb>
    80003ef4:	00048b1b          	sext.w	s6,s1
    80003ef8:	0044d793          	srli	a5,s1,0x4
    80003efc:	018a2583          	lw	a1,24(s4)
    80003f00:	9dbd                	addw	a1,a1,a5
    80003f02:	8556                	mv	a0,s5
    80003f04:	00000097          	auipc	ra,0x0
    80003f08:	952080e7          	jalr	-1710(ra) # 80003856 <bread>
    80003f0c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003f0e:	05850993          	addi	s3,a0,88
    80003f12:	00f4f793          	andi	a5,s1,15
    80003f16:	079a                	slli	a5,a5,0x6
    80003f18:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003f1a:	00099783          	lh	a5,0(s3)
    80003f1e:	c785                	beqz	a5,80003f46 <ialloc+0x84>
    brelse(bp);
    80003f20:	00000097          	auipc	ra,0x0
    80003f24:	a66080e7          	jalr	-1434(ra) # 80003986 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003f28:	0485                	addi	s1,s1,1
    80003f2a:	00ca2703          	lw	a4,12(s4)
    80003f2e:	0004879b          	sext.w	a5,s1
    80003f32:	fce7e1e3          	bltu	a5,a4,80003ef4 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003f36:	00006517          	auipc	a0,0x6
    80003f3a:	b3250513          	addi	a0,a0,-1230 # 80009a68 <syscalls+0x168>
    80003f3e:	ffffc097          	auipc	ra,0xffffc
    80003f42:	5ec080e7          	jalr	1516(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003f46:	04000613          	li	a2,64
    80003f4a:	4581                	li	a1,0
    80003f4c:	854e                	mv	a0,s3
    80003f4e:	ffffd097          	auipc	ra,0xffffd
    80003f52:	d70080e7          	jalr	-656(ra) # 80000cbe <memset>
      dip->type = type;
    80003f56:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003f5a:	854a                	mv	a0,s2
    80003f5c:	00001097          	auipc	ra,0x1
    80003f60:	fbe080e7          	jalr	-66(ra) # 80004f1a <log_write>
      brelse(bp);
    80003f64:	854a                	mv	a0,s2
    80003f66:	00000097          	auipc	ra,0x0
    80003f6a:	a20080e7          	jalr	-1504(ra) # 80003986 <brelse>
      return iget(dev, inum);
    80003f6e:	85da                	mv	a1,s6
    80003f70:	8556                	mv	a0,s5
    80003f72:	00000097          	auipc	ra,0x0
    80003f76:	db4080e7          	jalr	-588(ra) # 80003d26 <iget>
}
    80003f7a:	60a6                	ld	ra,72(sp)
    80003f7c:	6406                	ld	s0,64(sp)
    80003f7e:	74e2                	ld	s1,56(sp)
    80003f80:	7942                	ld	s2,48(sp)
    80003f82:	79a2                	ld	s3,40(sp)
    80003f84:	7a02                	ld	s4,32(sp)
    80003f86:	6ae2                	ld	s5,24(sp)
    80003f88:	6b42                	ld	s6,16(sp)
    80003f8a:	6ba2                	ld	s7,8(sp)
    80003f8c:	6161                	addi	sp,sp,80
    80003f8e:	8082                	ret

0000000080003f90 <iupdate>:
{
    80003f90:	1101                	addi	sp,sp,-32
    80003f92:	ec06                	sd	ra,24(sp)
    80003f94:	e822                	sd	s0,16(sp)
    80003f96:	e426                	sd	s1,8(sp)
    80003f98:	e04a                	sd	s2,0(sp)
    80003f9a:	1000                	addi	s0,sp,32
    80003f9c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003f9e:	415c                	lw	a5,4(a0)
    80003fa0:	0047d79b          	srliw	a5,a5,0x4
    80003fa4:	00029597          	auipc	a1,0x29
    80003fa8:	21c5a583          	lw	a1,540(a1) # 8002d1c0 <sb+0x18>
    80003fac:	9dbd                	addw	a1,a1,a5
    80003fae:	4108                	lw	a0,0(a0)
    80003fb0:	00000097          	auipc	ra,0x0
    80003fb4:	8a6080e7          	jalr	-1882(ra) # 80003856 <bread>
    80003fb8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003fba:	05850793          	addi	a5,a0,88
    80003fbe:	40c8                	lw	a0,4(s1)
    80003fc0:	893d                	andi	a0,a0,15
    80003fc2:	051a                	slli	a0,a0,0x6
    80003fc4:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003fc6:	04449703          	lh	a4,68(s1)
    80003fca:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003fce:	04649703          	lh	a4,70(s1)
    80003fd2:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003fd6:	04849703          	lh	a4,72(s1)
    80003fda:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003fde:	04a49703          	lh	a4,74(s1)
    80003fe2:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003fe6:	44f8                	lw	a4,76(s1)
    80003fe8:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003fea:	03400613          	li	a2,52
    80003fee:	05048593          	addi	a1,s1,80
    80003ff2:	0531                	addi	a0,a0,12
    80003ff4:	ffffd097          	auipc	ra,0xffffd
    80003ff8:	d26080e7          	jalr	-730(ra) # 80000d1a <memmove>
  log_write(bp);
    80003ffc:	854a                	mv	a0,s2
    80003ffe:	00001097          	auipc	ra,0x1
    80004002:	f1c080e7          	jalr	-228(ra) # 80004f1a <log_write>
  brelse(bp);
    80004006:	854a                	mv	a0,s2
    80004008:	00000097          	auipc	ra,0x0
    8000400c:	97e080e7          	jalr	-1666(ra) # 80003986 <brelse>
}
    80004010:	60e2                	ld	ra,24(sp)
    80004012:	6442                	ld	s0,16(sp)
    80004014:	64a2                	ld	s1,8(sp)
    80004016:	6902                	ld	s2,0(sp)
    80004018:	6105                	addi	sp,sp,32
    8000401a:	8082                	ret

000000008000401c <idup>:
{
    8000401c:	1101                	addi	sp,sp,-32
    8000401e:	ec06                	sd	ra,24(sp)
    80004020:	e822                	sd	s0,16(sp)
    80004022:	e426                	sd	s1,8(sp)
    80004024:	1000                	addi	s0,sp,32
    80004026:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004028:	00029517          	auipc	a0,0x29
    8000402c:	1a050513          	addi	a0,a0,416 # 8002d1c8 <itable>
    80004030:	ffffd097          	auipc	ra,0xffffd
    80004034:	b92080e7          	jalr	-1134(ra) # 80000bc2 <acquire>
  ip->ref++;
    80004038:	449c                	lw	a5,8(s1)
    8000403a:	2785                	addiw	a5,a5,1
    8000403c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000403e:	00029517          	auipc	a0,0x29
    80004042:	18a50513          	addi	a0,a0,394 # 8002d1c8 <itable>
    80004046:	ffffd097          	auipc	ra,0xffffd
    8000404a:	c30080e7          	jalr	-976(ra) # 80000c76 <release>
}
    8000404e:	8526                	mv	a0,s1
    80004050:	60e2                	ld	ra,24(sp)
    80004052:	6442                	ld	s0,16(sp)
    80004054:	64a2                	ld	s1,8(sp)
    80004056:	6105                	addi	sp,sp,32
    80004058:	8082                	ret

000000008000405a <ilock>:
{
    8000405a:	1101                	addi	sp,sp,-32
    8000405c:	ec06                	sd	ra,24(sp)
    8000405e:	e822                	sd	s0,16(sp)
    80004060:	e426                	sd	s1,8(sp)
    80004062:	e04a                	sd	s2,0(sp)
    80004064:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004066:	c115                	beqz	a0,8000408a <ilock+0x30>
    80004068:	84aa                	mv	s1,a0
    8000406a:	451c                	lw	a5,8(a0)
    8000406c:	00f05f63          	blez	a5,8000408a <ilock+0x30>
  acquiresleep(&ip->lock);
    80004070:	0541                	addi	a0,a0,16
    80004072:	00001097          	auipc	ra,0x1
    80004076:	fc8080e7          	jalr	-56(ra) # 8000503a <acquiresleep>
  if(ip->valid == 0){
    8000407a:	40bc                	lw	a5,64(s1)
    8000407c:	cf99                	beqz	a5,8000409a <ilock+0x40>
}
    8000407e:	60e2                	ld	ra,24(sp)
    80004080:	6442                	ld	s0,16(sp)
    80004082:	64a2                	ld	s1,8(sp)
    80004084:	6902                	ld	s2,0(sp)
    80004086:	6105                	addi	sp,sp,32
    80004088:	8082                	ret
    panic("ilock");
    8000408a:	00006517          	auipc	a0,0x6
    8000408e:	9f650513          	addi	a0,a0,-1546 # 80009a80 <syscalls+0x180>
    80004092:	ffffc097          	auipc	ra,0xffffc
    80004096:	498080e7          	jalr	1176(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000409a:	40dc                	lw	a5,4(s1)
    8000409c:	0047d79b          	srliw	a5,a5,0x4
    800040a0:	00029597          	auipc	a1,0x29
    800040a4:	1205a583          	lw	a1,288(a1) # 8002d1c0 <sb+0x18>
    800040a8:	9dbd                	addw	a1,a1,a5
    800040aa:	4088                	lw	a0,0(s1)
    800040ac:	fffff097          	auipc	ra,0xfffff
    800040b0:	7aa080e7          	jalr	1962(ra) # 80003856 <bread>
    800040b4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800040b6:	05850593          	addi	a1,a0,88
    800040ba:	40dc                	lw	a5,4(s1)
    800040bc:	8bbd                	andi	a5,a5,15
    800040be:	079a                	slli	a5,a5,0x6
    800040c0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800040c2:	00059783          	lh	a5,0(a1)
    800040c6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800040ca:	00259783          	lh	a5,2(a1)
    800040ce:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800040d2:	00459783          	lh	a5,4(a1)
    800040d6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800040da:	00659783          	lh	a5,6(a1)
    800040de:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800040e2:	459c                	lw	a5,8(a1)
    800040e4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800040e6:	03400613          	li	a2,52
    800040ea:	05b1                	addi	a1,a1,12
    800040ec:	05048513          	addi	a0,s1,80
    800040f0:	ffffd097          	auipc	ra,0xffffd
    800040f4:	c2a080e7          	jalr	-982(ra) # 80000d1a <memmove>
    brelse(bp);
    800040f8:	854a                	mv	a0,s2
    800040fa:	00000097          	auipc	ra,0x0
    800040fe:	88c080e7          	jalr	-1908(ra) # 80003986 <brelse>
    ip->valid = 1;
    80004102:	4785                	li	a5,1
    80004104:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004106:	04449783          	lh	a5,68(s1)
    8000410a:	fbb5                	bnez	a5,8000407e <ilock+0x24>
      panic("ilock: no type");
    8000410c:	00006517          	auipc	a0,0x6
    80004110:	97c50513          	addi	a0,a0,-1668 # 80009a88 <syscalls+0x188>
    80004114:	ffffc097          	auipc	ra,0xffffc
    80004118:	416080e7          	jalr	1046(ra) # 8000052a <panic>

000000008000411c <iunlock>:
{
    8000411c:	1101                	addi	sp,sp,-32
    8000411e:	ec06                	sd	ra,24(sp)
    80004120:	e822                	sd	s0,16(sp)
    80004122:	e426                	sd	s1,8(sp)
    80004124:	e04a                	sd	s2,0(sp)
    80004126:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004128:	c905                	beqz	a0,80004158 <iunlock+0x3c>
    8000412a:	84aa                	mv	s1,a0
    8000412c:	01050913          	addi	s2,a0,16
    80004130:	854a                	mv	a0,s2
    80004132:	00001097          	auipc	ra,0x1
    80004136:	fa2080e7          	jalr	-94(ra) # 800050d4 <holdingsleep>
    8000413a:	cd19                	beqz	a0,80004158 <iunlock+0x3c>
    8000413c:	449c                	lw	a5,8(s1)
    8000413e:	00f05d63          	blez	a5,80004158 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80004142:	854a                	mv	a0,s2
    80004144:	00001097          	auipc	ra,0x1
    80004148:	f4c080e7          	jalr	-180(ra) # 80005090 <releasesleep>
}
    8000414c:	60e2                	ld	ra,24(sp)
    8000414e:	6442                	ld	s0,16(sp)
    80004150:	64a2                	ld	s1,8(sp)
    80004152:	6902                	ld	s2,0(sp)
    80004154:	6105                	addi	sp,sp,32
    80004156:	8082                	ret
    panic("iunlock");
    80004158:	00006517          	auipc	a0,0x6
    8000415c:	94050513          	addi	a0,a0,-1728 # 80009a98 <syscalls+0x198>
    80004160:	ffffc097          	auipc	ra,0xffffc
    80004164:	3ca080e7          	jalr	970(ra) # 8000052a <panic>

0000000080004168 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004168:	7179                	addi	sp,sp,-48
    8000416a:	f406                	sd	ra,40(sp)
    8000416c:	f022                	sd	s0,32(sp)
    8000416e:	ec26                	sd	s1,24(sp)
    80004170:	e84a                	sd	s2,16(sp)
    80004172:	e44e                	sd	s3,8(sp)
    80004174:	e052                	sd	s4,0(sp)
    80004176:	1800                	addi	s0,sp,48
    80004178:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000417a:	05050493          	addi	s1,a0,80
    8000417e:	08050913          	addi	s2,a0,128
    80004182:	a021                	j	8000418a <itrunc+0x22>
    80004184:	0491                	addi	s1,s1,4
    80004186:	01248d63          	beq	s1,s2,800041a0 <itrunc+0x38>
    if(ip->addrs[i]){
    8000418a:	408c                	lw	a1,0(s1)
    8000418c:	dde5                	beqz	a1,80004184 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000418e:	0009a503          	lw	a0,0(s3)
    80004192:	00000097          	auipc	ra,0x0
    80004196:	90a080e7          	jalr	-1782(ra) # 80003a9c <bfree>
      ip->addrs[i] = 0;
    8000419a:	0004a023          	sw	zero,0(s1)
    8000419e:	b7dd                	j	80004184 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800041a0:	0809a583          	lw	a1,128(s3)
    800041a4:	e185                	bnez	a1,800041c4 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800041a6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800041aa:	854e                	mv	a0,s3
    800041ac:	00000097          	auipc	ra,0x0
    800041b0:	de4080e7          	jalr	-540(ra) # 80003f90 <iupdate>
}
    800041b4:	70a2                	ld	ra,40(sp)
    800041b6:	7402                	ld	s0,32(sp)
    800041b8:	64e2                	ld	s1,24(sp)
    800041ba:	6942                	ld	s2,16(sp)
    800041bc:	69a2                	ld	s3,8(sp)
    800041be:	6a02                	ld	s4,0(sp)
    800041c0:	6145                	addi	sp,sp,48
    800041c2:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800041c4:	0009a503          	lw	a0,0(s3)
    800041c8:	fffff097          	auipc	ra,0xfffff
    800041cc:	68e080e7          	jalr	1678(ra) # 80003856 <bread>
    800041d0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800041d2:	05850493          	addi	s1,a0,88
    800041d6:	45850913          	addi	s2,a0,1112
    800041da:	a021                	j	800041e2 <itrunc+0x7a>
    800041dc:	0491                	addi	s1,s1,4
    800041de:	01248b63          	beq	s1,s2,800041f4 <itrunc+0x8c>
      if(a[j])
    800041e2:	408c                	lw	a1,0(s1)
    800041e4:	dde5                	beqz	a1,800041dc <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800041e6:	0009a503          	lw	a0,0(s3)
    800041ea:	00000097          	auipc	ra,0x0
    800041ee:	8b2080e7          	jalr	-1870(ra) # 80003a9c <bfree>
    800041f2:	b7ed                	j	800041dc <itrunc+0x74>
    brelse(bp);
    800041f4:	8552                	mv	a0,s4
    800041f6:	fffff097          	auipc	ra,0xfffff
    800041fa:	790080e7          	jalr	1936(ra) # 80003986 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800041fe:	0809a583          	lw	a1,128(s3)
    80004202:	0009a503          	lw	a0,0(s3)
    80004206:	00000097          	auipc	ra,0x0
    8000420a:	896080e7          	jalr	-1898(ra) # 80003a9c <bfree>
    ip->addrs[NDIRECT] = 0;
    8000420e:	0809a023          	sw	zero,128(s3)
    80004212:	bf51                	j	800041a6 <itrunc+0x3e>

0000000080004214 <iput>:
{
    80004214:	1101                	addi	sp,sp,-32
    80004216:	ec06                	sd	ra,24(sp)
    80004218:	e822                	sd	s0,16(sp)
    8000421a:	e426                	sd	s1,8(sp)
    8000421c:	e04a                	sd	s2,0(sp)
    8000421e:	1000                	addi	s0,sp,32
    80004220:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004222:	00029517          	auipc	a0,0x29
    80004226:	fa650513          	addi	a0,a0,-90 # 8002d1c8 <itable>
    8000422a:	ffffd097          	auipc	ra,0xffffd
    8000422e:	998080e7          	jalr	-1640(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004232:	4498                	lw	a4,8(s1)
    80004234:	4785                	li	a5,1
    80004236:	02f70363          	beq	a4,a5,8000425c <iput+0x48>
  ip->ref--;
    8000423a:	449c                	lw	a5,8(s1)
    8000423c:	37fd                	addiw	a5,a5,-1
    8000423e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004240:	00029517          	auipc	a0,0x29
    80004244:	f8850513          	addi	a0,a0,-120 # 8002d1c8 <itable>
    80004248:	ffffd097          	auipc	ra,0xffffd
    8000424c:	a2e080e7          	jalr	-1490(ra) # 80000c76 <release>
}
    80004250:	60e2                	ld	ra,24(sp)
    80004252:	6442                	ld	s0,16(sp)
    80004254:	64a2                	ld	s1,8(sp)
    80004256:	6902                	ld	s2,0(sp)
    80004258:	6105                	addi	sp,sp,32
    8000425a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000425c:	40bc                	lw	a5,64(s1)
    8000425e:	dff1                	beqz	a5,8000423a <iput+0x26>
    80004260:	04a49783          	lh	a5,74(s1)
    80004264:	fbf9                	bnez	a5,8000423a <iput+0x26>
    acquiresleep(&ip->lock);
    80004266:	01048913          	addi	s2,s1,16
    8000426a:	854a                	mv	a0,s2
    8000426c:	00001097          	auipc	ra,0x1
    80004270:	dce080e7          	jalr	-562(ra) # 8000503a <acquiresleep>
    release(&itable.lock);
    80004274:	00029517          	auipc	a0,0x29
    80004278:	f5450513          	addi	a0,a0,-172 # 8002d1c8 <itable>
    8000427c:	ffffd097          	auipc	ra,0xffffd
    80004280:	9fa080e7          	jalr	-1542(ra) # 80000c76 <release>
    itrunc(ip);
    80004284:	8526                	mv	a0,s1
    80004286:	00000097          	auipc	ra,0x0
    8000428a:	ee2080e7          	jalr	-286(ra) # 80004168 <itrunc>
    ip->type = 0;
    8000428e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004292:	8526                	mv	a0,s1
    80004294:	00000097          	auipc	ra,0x0
    80004298:	cfc080e7          	jalr	-772(ra) # 80003f90 <iupdate>
    ip->valid = 0;
    8000429c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800042a0:	854a                	mv	a0,s2
    800042a2:	00001097          	auipc	ra,0x1
    800042a6:	dee080e7          	jalr	-530(ra) # 80005090 <releasesleep>
    acquire(&itable.lock);
    800042aa:	00029517          	auipc	a0,0x29
    800042ae:	f1e50513          	addi	a0,a0,-226 # 8002d1c8 <itable>
    800042b2:	ffffd097          	auipc	ra,0xffffd
    800042b6:	910080e7          	jalr	-1776(ra) # 80000bc2 <acquire>
    800042ba:	b741                	j	8000423a <iput+0x26>

00000000800042bc <iunlockput>:
{
    800042bc:	1101                	addi	sp,sp,-32
    800042be:	ec06                	sd	ra,24(sp)
    800042c0:	e822                	sd	s0,16(sp)
    800042c2:	e426                	sd	s1,8(sp)
    800042c4:	1000                	addi	s0,sp,32
    800042c6:	84aa                	mv	s1,a0
  iunlock(ip);
    800042c8:	00000097          	auipc	ra,0x0
    800042cc:	e54080e7          	jalr	-428(ra) # 8000411c <iunlock>
  iput(ip);
    800042d0:	8526                	mv	a0,s1
    800042d2:	00000097          	auipc	ra,0x0
    800042d6:	f42080e7          	jalr	-190(ra) # 80004214 <iput>
}
    800042da:	60e2                	ld	ra,24(sp)
    800042dc:	6442                	ld	s0,16(sp)
    800042de:	64a2                	ld	s1,8(sp)
    800042e0:	6105                	addi	sp,sp,32
    800042e2:	8082                	ret

00000000800042e4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800042e4:	1141                	addi	sp,sp,-16
    800042e6:	e422                	sd	s0,8(sp)
    800042e8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800042ea:	411c                	lw	a5,0(a0)
    800042ec:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800042ee:	415c                	lw	a5,4(a0)
    800042f0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800042f2:	04451783          	lh	a5,68(a0)
    800042f6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800042fa:	04a51783          	lh	a5,74(a0)
    800042fe:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004302:	04c56783          	lwu	a5,76(a0)
    80004306:	e99c                	sd	a5,16(a1)
}
    80004308:	6422                	ld	s0,8(sp)
    8000430a:	0141                	addi	sp,sp,16
    8000430c:	8082                	ret

000000008000430e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000430e:	457c                	lw	a5,76(a0)
    80004310:	0ed7e963          	bltu	a5,a3,80004402 <readi+0xf4>
{
    80004314:	7159                	addi	sp,sp,-112
    80004316:	f486                	sd	ra,104(sp)
    80004318:	f0a2                	sd	s0,96(sp)
    8000431a:	eca6                	sd	s1,88(sp)
    8000431c:	e8ca                	sd	s2,80(sp)
    8000431e:	e4ce                	sd	s3,72(sp)
    80004320:	e0d2                	sd	s4,64(sp)
    80004322:	fc56                	sd	s5,56(sp)
    80004324:	f85a                	sd	s6,48(sp)
    80004326:	f45e                	sd	s7,40(sp)
    80004328:	f062                	sd	s8,32(sp)
    8000432a:	ec66                	sd	s9,24(sp)
    8000432c:	e86a                	sd	s10,16(sp)
    8000432e:	e46e                	sd	s11,8(sp)
    80004330:	1880                	addi	s0,sp,112
    80004332:	8baa                	mv	s7,a0
    80004334:	8c2e                	mv	s8,a1
    80004336:	8ab2                	mv	s5,a2
    80004338:	84b6                	mv	s1,a3
    8000433a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000433c:	9f35                	addw	a4,a4,a3
    return 0;
    8000433e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004340:	0ad76063          	bltu	a4,a3,800043e0 <readi+0xd2>
  if(off + n > ip->size)
    80004344:	00e7f463          	bgeu	a5,a4,8000434c <readi+0x3e>
    n = ip->size - off;
    80004348:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000434c:	0a0b0963          	beqz	s6,800043fe <readi+0xf0>
    80004350:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004352:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004356:	5cfd                	li	s9,-1
    80004358:	a82d                	j	80004392 <readi+0x84>
    8000435a:	020a1d93          	slli	s11,s4,0x20
    8000435e:	020ddd93          	srli	s11,s11,0x20
    80004362:	05890793          	addi	a5,s2,88
    80004366:	86ee                	mv	a3,s11
    80004368:	963e                	add	a2,a2,a5
    8000436a:	85d6                	mv	a1,s5
    8000436c:	8562                	mv	a0,s8
    8000436e:	ffffe097          	auipc	ra,0xffffe
    80004372:	26c080e7          	jalr	620(ra) # 800025da <either_copyout>
    80004376:	05950d63          	beq	a0,s9,800043d0 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000437a:	854a                	mv	a0,s2
    8000437c:	fffff097          	auipc	ra,0xfffff
    80004380:	60a080e7          	jalr	1546(ra) # 80003986 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004384:	013a09bb          	addw	s3,s4,s3
    80004388:	009a04bb          	addw	s1,s4,s1
    8000438c:	9aee                	add	s5,s5,s11
    8000438e:	0569f763          	bgeu	s3,s6,800043dc <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004392:	000ba903          	lw	s2,0(s7)
    80004396:	00a4d59b          	srliw	a1,s1,0xa
    8000439a:	855e                	mv	a0,s7
    8000439c:	00000097          	auipc	ra,0x0
    800043a0:	8ae080e7          	jalr	-1874(ra) # 80003c4a <bmap>
    800043a4:	0005059b          	sext.w	a1,a0
    800043a8:	854a                	mv	a0,s2
    800043aa:	fffff097          	auipc	ra,0xfffff
    800043ae:	4ac080e7          	jalr	1196(ra) # 80003856 <bread>
    800043b2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800043b4:	3ff4f613          	andi	a2,s1,1023
    800043b8:	40cd07bb          	subw	a5,s10,a2
    800043bc:	413b073b          	subw	a4,s6,s3
    800043c0:	8a3e                	mv	s4,a5
    800043c2:	2781                	sext.w	a5,a5
    800043c4:	0007069b          	sext.w	a3,a4
    800043c8:	f8f6f9e3          	bgeu	a3,a5,8000435a <readi+0x4c>
    800043cc:	8a3a                	mv	s4,a4
    800043ce:	b771                	j	8000435a <readi+0x4c>
      brelse(bp);
    800043d0:	854a                	mv	a0,s2
    800043d2:	fffff097          	auipc	ra,0xfffff
    800043d6:	5b4080e7          	jalr	1460(ra) # 80003986 <brelse>
      tot = -1;
    800043da:	59fd                	li	s3,-1
  }
  return tot;
    800043dc:	0009851b          	sext.w	a0,s3
}
    800043e0:	70a6                	ld	ra,104(sp)
    800043e2:	7406                	ld	s0,96(sp)
    800043e4:	64e6                	ld	s1,88(sp)
    800043e6:	6946                	ld	s2,80(sp)
    800043e8:	69a6                	ld	s3,72(sp)
    800043ea:	6a06                	ld	s4,64(sp)
    800043ec:	7ae2                	ld	s5,56(sp)
    800043ee:	7b42                	ld	s6,48(sp)
    800043f0:	7ba2                	ld	s7,40(sp)
    800043f2:	7c02                	ld	s8,32(sp)
    800043f4:	6ce2                	ld	s9,24(sp)
    800043f6:	6d42                	ld	s10,16(sp)
    800043f8:	6da2                	ld	s11,8(sp)
    800043fa:	6165                	addi	sp,sp,112
    800043fc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800043fe:	89da                	mv	s3,s6
    80004400:	bff1                	j	800043dc <readi+0xce>
    return 0;
    80004402:	4501                	li	a0,0
}
    80004404:	8082                	ret

0000000080004406 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004406:	457c                	lw	a5,76(a0)
    80004408:	10d7e863          	bltu	a5,a3,80004518 <writei+0x112>
{
    8000440c:	7159                	addi	sp,sp,-112
    8000440e:	f486                	sd	ra,104(sp)
    80004410:	f0a2                	sd	s0,96(sp)
    80004412:	eca6                	sd	s1,88(sp)
    80004414:	e8ca                	sd	s2,80(sp)
    80004416:	e4ce                	sd	s3,72(sp)
    80004418:	e0d2                	sd	s4,64(sp)
    8000441a:	fc56                	sd	s5,56(sp)
    8000441c:	f85a                	sd	s6,48(sp)
    8000441e:	f45e                	sd	s7,40(sp)
    80004420:	f062                	sd	s8,32(sp)
    80004422:	ec66                	sd	s9,24(sp)
    80004424:	e86a                	sd	s10,16(sp)
    80004426:	e46e                	sd	s11,8(sp)
    80004428:	1880                	addi	s0,sp,112
    8000442a:	8b2a                	mv	s6,a0
    8000442c:	8c2e                	mv	s8,a1
    8000442e:	8ab2                	mv	s5,a2
    80004430:	8936                	mv	s2,a3
    80004432:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004434:	00e687bb          	addw	a5,a3,a4
    80004438:	0ed7e263          	bltu	a5,a3,8000451c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000443c:	00043737          	lui	a4,0x43
    80004440:	0ef76063          	bltu	a4,a5,80004520 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004444:	0c0b8863          	beqz	s7,80004514 <writei+0x10e>
    80004448:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000444a:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000444e:	5cfd                	li	s9,-1
    80004450:	a091                	j	80004494 <writei+0x8e>
    80004452:	02099d93          	slli	s11,s3,0x20
    80004456:	020ddd93          	srli	s11,s11,0x20
    8000445a:	05848793          	addi	a5,s1,88
    8000445e:	86ee                	mv	a3,s11
    80004460:	8656                	mv	a2,s5
    80004462:	85e2                	mv	a1,s8
    80004464:	953e                	add	a0,a0,a5
    80004466:	ffffe097          	auipc	ra,0xffffe
    8000446a:	1ca080e7          	jalr	458(ra) # 80002630 <either_copyin>
    8000446e:	07950263          	beq	a0,s9,800044d2 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004472:	8526                	mv	a0,s1
    80004474:	00001097          	auipc	ra,0x1
    80004478:	aa6080e7          	jalr	-1370(ra) # 80004f1a <log_write>
    brelse(bp);
    8000447c:	8526                	mv	a0,s1
    8000447e:	fffff097          	auipc	ra,0xfffff
    80004482:	508080e7          	jalr	1288(ra) # 80003986 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004486:	01498a3b          	addw	s4,s3,s4
    8000448a:	0129893b          	addw	s2,s3,s2
    8000448e:	9aee                	add	s5,s5,s11
    80004490:	057a7663          	bgeu	s4,s7,800044dc <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004494:	000b2483          	lw	s1,0(s6)
    80004498:	00a9559b          	srliw	a1,s2,0xa
    8000449c:	855a                	mv	a0,s6
    8000449e:	fffff097          	auipc	ra,0xfffff
    800044a2:	7ac080e7          	jalr	1964(ra) # 80003c4a <bmap>
    800044a6:	0005059b          	sext.w	a1,a0
    800044aa:	8526                	mv	a0,s1
    800044ac:	fffff097          	auipc	ra,0xfffff
    800044b0:	3aa080e7          	jalr	938(ra) # 80003856 <bread>
    800044b4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800044b6:	3ff97513          	andi	a0,s2,1023
    800044ba:	40ad07bb          	subw	a5,s10,a0
    800044be:	414b873b          	subw	a4,s7,s4
    800044c2:	89be                	mv	s3,a5
    800044c4:	2781                	sext.w	a5,a5
    800044c6:	0007069b          	sext.w	a3,a4
    800044ca:	f8f6f4e3          	bgeu	a3,a5,80004452 <writei+0x4c>
    800044ce:	89ba                	mv	s3,a4
    800044d0:	b749                	j	80004452 <writei+0x4c>
      brelse(bp);
    800044d2:	8526                	mv	a0,s1
    800044d4:	fffff097          	auipc	ra,0xfffff
    800044d8:	4b2080e7          	jalr	1202(ra) # 80003986 <brelse>
  }

  if(off > ip->size)
    800044dc:	04cb2783          	lw	a5,76(s6)
    800044e0:	0127f463          	bgeu	a5,s2,800044e8 <writei+0xe2>
    ip->size = off;
    800044e4:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800044e8:	855a                	mv	a0,s6
    800044ea:	00000097          	auipc	ra,0x0
    800044ee:	aa6080e7          	jalr	-1370(ra) # 80003f90 <iupdate>

  return tot;
    800044f2:	000a051b          	sext.w	a0,s4
}
    800044f6:	70a6                	ld	ra,104(sp)
    800044f8:	7406                	ld	s0,96(sp)
    800044fa:	64e6                	ld	s1,88(sp)
    800044fc:	6946                	ld	s2,80(sp)
    800044fe:	69a6                	ld	s3,72(sp)
    80004500:	6a06                	ld	s4,64(sp)
    80004502:	7ae2                	ld	s5,56(sp)
    80004504:	7b42                	ld	s6,48(sp)
    80004506:	7ba2                	ld	s7,40(sp)
    80004508:	7c02                	ld	s8,32(sp)
    8000450a:	6ce2                	ld	s9,24(sp)
    8000450c:	6d42                	ld	s10,16(sp)
    8000450e:	6da2                	ld	s11,8(sp)
    80004510:	6165                	addi	sp,sp,112
    80004512:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004514:	8a5e                	mv	s4,s7
    80004516:	bfc9                	j	800044e8 <writei+0xe2>
    return -1;
    80004518:	557d                	li	a0,-1
}
    8000451a:	8082                	ret
    return -1;
    8000451c:	557d                	li	a0,-1
    8000451e:	bfe1                	j	800044f6 <writei+0xf0>
    return -1;
    80004520:	557d                	li	a0,-1
    80004522:	bfd1                	j	800044f6 <writei+0xf0>

0000000080004524 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004524:	1141                	addi	sp,sp,-16
    80004526:	e406                	sd	ra,8(sp)
    80004528:	e022                	sd	s0,0(sp)
    8000452a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000452c:	4639                	li	a2,14
    8000452e:	ffffd097          	auipc	ra,0xffffd
    80004532:	868080e7          	jalr	-1944(ra) # 80000d96 <strncmp>
}
    80004536:	60a2                	ld	ra,8(sp)
    80004538:	6402                	ld	s0,0(sp)
    8000453a:	0141                	addi	sp,sp,16
    8000453c:	8082                	ret

000000008000453e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000453e:	7139                	addi	sp,sp,-64
    80004540:	fc06                	sd	ra,56(sp)
    80004542:	f822                	sd	s0,48(sp)
    80004544:	f426                	sd	s1,40(sp)
    80004546:	f04a                	sd	s2,32(sp)
    80004548:	ec4e                	sd	s3,24(sp)
    8000454a:	e852                	sd	s4,16(sp)
    8000454c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000454e:	04451703          	lh	a4,68(a0)
    80004552:	4785                	li	a5,1
    80004554:	00f71a63          	bne	a4,a5,80004568 <dirlookup+0x2a>
    80004558:	892a                	mv	s2,a0
    8000455a:	89ae                	mv	s3,a1
    8000455c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000455e:	457c                	lw	a5,76(a0)
    80004560:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004562:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004564:	e79d                	bnez	a5,80004592 <dirlookup+0x54>
    80004566:	a8a5                	j	800045de <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004568:	00005517          	auipc	a0,0x5
    8000456c:	53850513          	addi	a0,a0,1336 # 80009aa0 <syscalls+0x1a0>
    80004570:	ffffc097          	auipc	ra,0xffffc
    80004574:	fba080e7          	jalr	-70(ra) # 8000052a <panic>
      panic("dirlookup read");
    80004578:	00005517          	auipc	a0,0x5
    8000457c:	54050513          	addi	a0,a0,1344 # 80009ab8 <syscalls+0x1b8>
    80004580:	ffffc097          	auipc	ra,0xffffc
    80004584:	faa080e7          	jalr	-86(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004588:	24c1                	addiw	s1,s1,16
    8000458a:	04c92783          	lw	a5,76(s2)
    8000458e:	04f4f763          	bgeu	s1,a5,800045dc <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004592:	4741                	li	a4,16
    80004594:	86a6                	mv	a3,s1
    80004596:	fc040613          	addi	a2,s0,-64
    8000459a:	4581                	li	a1,0
    8000459c:	854a                	mv	a0,s2
    8000459e:	00000097          	auipc	ra,0x0
    800045a2:	d70080e7          	jalr	-656(ra) # 8000430e <readi>
    800045a6:	47c1                	li	a5,16
    800045a8:	fcf518e3          	bne	a0,a5,80004578 <dirlookup+0x3a>
    if(de.inum == 0)
    800045ac:	fc045783          	lhu	a5,-64(s0)
    800045b0:	dfe1                	beqz	a5,80004588 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800045b2:	fc240593          	addi	a1,s0,-62
    800045b6:	854e                	mv	a0,s3
    800045b8:	00000097          	auipc	ra,0x0
    800045bc:	f6c080e7          	jalr	-148(ra) # 80004524 <namecmp>
    800045c0:	f561                	bnez	a0,80004588 <dirlookup+0x4a>
      if(poff)
    800045c2:	000a0463          	beqz	s4,800045ca <dirlookup+0x8c>
        *poff = off;
    800045c6:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800045ca:	fc045583          	lhu	a1,-64(s0)
    800045ce:	00092503          	lw	a0,0(s2)
    800045d2:	fffff097          	auipc	ra,0xfffff
    800045d6:	754080e7          	jalr	1876(ra) # 80003d26 <iget>
    800045da:	a011                	j	800045de <dirlookup+0xa0>
  return 0;
    800045dc:	4501                	li	a0,0
}
    800045de:	70e2                	ld	ra,56(sp)
    800045e0:	7442                	ld	s0,48(sp)
    800045e2:	74a2                	ld	s1,40(sp)
    800045e4:	7902                	ld	s2,32(sp)
    800045e6:	69e2                	ld	s3,24(sp)
    800045e8:	6a42                	ld	s4,16(sp)
    800045ea:	6121                	addi	sp,sp,64
    800045ec:	8082                	ret

00000000800045ee <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800045ee:	711d                	addi	sp,sp,-96
    800045f0:	ec86                	sd	ra,88(sp)
    800045f2:	e8a2                	sd	s0,80(sp)
    800045f4:	e4a6                	sd	s1,72(sp)
    800045f6:	e0ca                	sd	s2,64(sp)
    800045f8:	fc4e                	sd	s3,56(sp)
    800045fa:	f852                	sd	s4,48(sp)
    800045fc:	f456                	sd	s5,40(sp)
    800045fe:	f05a                	sd	s6,32(sp)
    80004600:	ec5e                	sd	s7,24(sp)
    80004602:	e862                	sd	s8,16(sp)
    80004604:	e466                	sd	s9,8(sp)
    80004606:	1080                	addi	s0,sp,96
    80004608:	84aa                	mv	s1,a0
    8000460a:	8aae                	mv	s5,a1
    8000460c:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000460e:	00054703          	lbu	a4,0(a0)
    80004612:	02f00793          	li	a5,47
    80004616:	02f70363          	beq	a4,a5,8000463c <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000461a:	ffffd097          	auipc	ra,0xffffd
    8000461e:	71a080e7          	jalr	1818(ra) # 80001d34 <myproc>
    80004622:	15053503          	ld	a0,336(a0)
    80004626:	00000097          	auipc	ra,0x0
    8000462a:	9f6080e7          	jalr	-1546(ra) # 8000401c <idup>
    8000462e:	89aa                	mv	s3,a0
  while(*path == '/')
    80004630:	02f00913          	li	s2,47
  len = path - s;
    80004634:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004636:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004638:	4b85                	li	s7,1
    8000463a:	a865                	j	800046f2 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000463c:	4585                	li	a1,1
    8000463e:	4505                	li	a0,1
    80004640:	fffff097          	auipc	ra,0xfffff
    80004644:	6e6080e7          	jalr	1766(ra) # 80003d26 <iget>
    80004648:	89aa                	mv	s3,a0
    8000464a:	b7dd                	j	80004630 <namex+0x42>
      iunlockput(ip);
    8000464c:	854e                	mv	a0,s3
    8000464e:	00000097          	auipc	ra,0x0
    80004652:	c6e080e7          	jalr	-914(ra) # 800042bc <iunlockput>
      return 0;
    80004656:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004658:	854e                	mv	a0,s3
    8000465a:	60e6                	ld	ra,88(sp)
    8000465c:	6446                	ld	s0,80(sp)
    8000465e:	64a6                	ld	s1,72(sp)
    80004660:	6906                	ld	s2,64(sp)
    80004662:	79e2                	ld	s3,56(sp)
    80004664:	7a42                	ld	s4,48(sp)
    80004666:	7aa2                	ld	s5,40(sp)
    80004668:	7b02                	ld	s6,32(sp)
    8000466a:	6be2                	ld	s7,24(sp)
    8000466c:	6c42                	ld	s8,16(sp)
    8000466e:	6ca2                	ld	s9,8(sp)
    80004670:	6125                	addi	sp,sp,96
    80004672:	8082                	ret
      iunlock(ip);
    80004674:	854e                	mv	a0,s3
    80004676:	00000097          	auipc	ra,0x0
    8000467a:	aa6080e7          	jalr	-1370(ra) # 8000411c <iunlock>
      return ip;
    8000467e:	bfe9                	j	80004658 <namex+0x6a>
      iunlockput(ip);
    80004680:	854e                	mv	a0,s3
    80004682:	00000097          	auipc	ra,0x0
    80004686:	c3a080e7          	jalr	-966(ra) # 800042bc <iunlockput>
      return 0;
    8000468a:	89e6                	mv	s3,s9
    8000468c:	b7f1                	j	80004658 <namex+0x6a>
  len = path - s;
    8000468e:	40b48633          	sub	a2,s1,a1
    80004692:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004696:	099c5463          	bge	s8,s9,8000471e <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000469a:	4639                	li	a2,14
    8000469c:	8552                	mv	a0,s4
    8000469e:	ffffc097          	auipc	ra,0xffffc
    800046a2:	67c080e7          	jalr	1660(ra) # 80000d1a <memmove>
  while(*path == '/')
    800046a6:	0004c783          	lbu	a5,0(s1)
    800046aa:	01279763          	bne	a5,s2,800046b8 <namex+0xca>
    path++;
    800046ae:	0485                	addi	s1,s1,1
  while(*path == '/')
    800046b0:	0004c783          	lbu	a5,0(s1)
    800046b4:	ff278de3          	beq	a5,s2,800046ae <namex+0xc0>
    ilock(ip);
    800046b8:	854e                	mv	a0,s3
    800046ba:	00000097          	auipc	ra,0x0
    800046be:	9a0080e7          	jalr	-1632(ra) # 8000405a <ilock>
    if(ip->type != T_DIR){
    800046c2:	04499783          	lh	a5,68(s3)
    800046c6:	f97793e3          	bne	a5,s7,8000464c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800046ca:	000a8563          	beqz	s5,800046d4 <namex+0xe6>
    800046ce:	0004c783          	lbu	a5,0(s1)
    800046d2:	d3cd                	beqz	a5,80004674 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800046d4:	865a                	mv	a2,s6
    800046d6:	85d2                	mv	a1,s4
    800046d8:	854e                	mv	a0,s3
    800046da:	00000097          	auipc	ra,0x0
    800046de:	e64080e7          	jalr	-412(ra) # 8000453e <dirlookup>
    800046e2:	8caa                	mv	s9,a0
    800046e4:	dd51                	beqz	a0,80004680 <namex+0x92>
    iunlockput(ip);
    800046e6:	854e                	mv	a0,s3
    800046e8:	00000097          	auipc	ra,0x0
    800046ec:	bd4080e7          	jalr	-1068(ra) # 800042bc <iunlockput>
    ip = next;
    800046f0:	89e6                	mv	s3,s9
  while(*path == '/')
    800046f2:	0004c783          	lbu	a5,0(s1)
    800046f6:	05279763          	bne	a5,s2,80004744 <namex+0x156>
    path++;
    800046fa:	0485                	addi	s1,s1,1
  while(*path == '/')
    800046fc:	0004c783          	lbu	a5,0(s1)
    80004700:	ff278de3          	beq	a5,s2,800046fa <namex+0x10c>
  if(*path == 0)
    80004704:	c79d                	beqz	a5,80004732 <namex+0x144>
    path++;
    80004706:	85a6                	mv	a1,s1
  len = path - s;
    80004708:	8cda                	mv	s9,s6
    8000470a:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    8000470c:	01278963          	beq	a5,s2,8000471e <namex+0x130>
    80004710:	dfbd                	beqz	a5,8000468e <namex+0xa0>
    path++;
    80004712:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004714:	0004c783          	lbu	a5,0(s1)
    80004718:	ff279ce3          	bne	a5,s2,80004710 <namex+0x122>
    8000471c:	bf8d                	j	8000468e <namex+0xa0>
    memmove(name, s, len);
    8000471e:	2601                	sext.w	a2,a2
    80004720:	8552                	mv	a0,s4
    80004722:	ffffc097          	auipc	ra,0xffffc
    80004726:	5f8080e7          	jalr	1528(ra) # 80000d1a <memmove>
    name[len] = 0;
    8000472a:	9cd2                	add	s9,s9,s4
    8000472c:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004730:	bf9d                	j	800046a6 <namex+0xb8>
  if(nameiparent){
    80004732:	f20a83e3          	beqz	s5,80004658 <namex+0x6a>
    iput(ip);
    80004736:	854e                	mv	a0,s3
    80004738:	00000097          	auipc	ra,0x0
    8000473c:	adc080e7          	jalr	-1316(ra) # 80004214 <iput>
    return 0;
    80004740:	4981                	li	s3,0
    80004742:	bf19                	j	80004658 <namex+0x6a>
  if(*path == 0)
    80004744:	d7fd                	beqz	a5,80004732 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004746:	0004c783          	lbu	a5,0(s1)
    8000474a:	85a6                	mv	a1,s1
    8000474c:	b7d1                	j	80004710 <namex+0x122>

000000008000474e <dirlink>:
{
    8000474e:	7139                	addi	sp,sp,-64
    80004750:	fc06                	sd	ra,56(sp)
    80004752:	f822                	sd	s0,48(sp)
    80004754:	f426                	sd	s1,40(sp)
    80004756:	f04a                	sd	s2,32(sp)
    80004758:	ec4e                	sd	s3,24(sp)
    8000475a:	e852                	sd	s4,16(sp)
    8000475c:	0080                	addi	s0,sp,64
    8000475e:	892a                	mv	s2,a0
    80004760:	8a2e                	mv	s4,a1
    80004762:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004764:	4601                	li	a2,0
    80004766:	00000097          	auipc	ra,0x0
    8000476a:	dd8080e7          	jalr	-552(ra) # 8000453e <dirlookup>
    8000476e:	e93d                	bnez	a0,800047e4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004770:	04c92483          	lw	s1,76(s2)
    80004774:	c49d                	beqz	s1,800047a2 <dirlink+0x54>
    80004776:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004778:	4741                	li	a4,16
    8000477a:	86a6                	mv	a3,s1
    8000477c:	fc040613          	addi	a2,s0,-64
    80004780:	4581                	li	a1,0
    80004782:	854a                	mv	a0,s2
    80004784:	00000097          	auipc	ra,0x0
    80004788:	b8a080e7          	jalr	-1142(ra) # 8000430e <readi>
    8000478c:	47c1                	li	a5,16
    8000478e:	06f51163          	bne	a0,a5,800047f0 <dirlink+0xa2>
    if(de.inum == 0)
    80004792:	fc045783          	lhu	a5,-64(s0)
    80004796:	c791                	beqz	a5,800047a2 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004798:	24c1                	addiw	s1,s1,16
    8000479a:	04c92783          	lw	a5,76(s2)
    8000479e:	fcf4ede3          	bltu	s1,a5,80004778 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800047a2:	4639                	li	a2,14
    800047a4:	85d2                	mv	a1,s4
    800047a6:	fc240513          	addi	a0,s0,-62
    800047aa:	ffffc097          	auipc	ra,0xffffc
    800047ae:	628080e7          	jalr	1576(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    800047b2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800047b6:	4741                	li	a4,16
    800047b8:	86a6                	mv	a3,s1
    800047ba:	fc040613          	addi	a2,s0,-64
    800047be:	4581                	li	a1,0
    800047c0:	854a                	mv	a0,s2
    800047c2:	00000097          	auipc	ra,0x0
    800047c6:	c44080e7          	jalr	-956(ra) # 80004406 <writei>
    800047ca:	872a                	mv	a4,a0
    800047cc:	47c1                	li	a5,16
  return 0;
    800047ce:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800047d0:	02f71863          	bne	a4,a5,80004800 <dirlink+0xb2>
}
    800047d4:	70e2                	ld	ra,56(sp)
    800047d6:	7442                	ld	s0,48(sp)
    800047d8:	74a2                	ld	s1,40(sp)
    800047da:	7902                	ld	s2,32(sp)
    800047dc:	69e2                	ld	s3,24(sp)
    800047de:	6a42                	ld	s4,16(sp)
    800047e0:	6121                	addi	sp,sp,64
    800047e2:	8082                	ret
    iput(ip);
    800047e4:	00000097          	auipc	ra,0x0
    800047e8:	a30080e7          	jalr	-1488(ra) # 80004214 <iput>
    return -1;
    800047ec:	557d                	li	a0,-1
    800047ee:	b7dd                	j	800047d4 <dirlink+0x86>
      panic("dirlink read");
    800047f0:	00005517          	auipc	a0,0x5
    800047f4:	2d850513          	addi	a0,a0,728 # 80009ac8 <syscalls+0x1c8>
    800047f8:	ffffc097          	auipc	ra,0xffffc
    800047fc:	d32080e7          	jalr	-718(ra) # 8000052a <panic>
    panic("dirlink");
    80004800:	00005517          	auipc	a0,0x5
    80004804:	45050513          	addi	a0,a0,1104 # 80009c50 <syscalls+0x350>
    80004808:	ffffc097          	auipc	ra,0xffffc
    8000480c:	d22080e7          	jalr	-734(ra) # 8000052a <panic>

0000000080004810 <namei>:

struct inode*
namei(char *path)
{
    80004810:	1101                	addi	sp,sp,-32
    80004812:	ec06                	sd	ra,24(sp)
    80004814:	e822                	sd	s0,16(sp)
    80004816:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004818:	fe040613          	addi	a2,s0,-32
    8000481c:	4581                	li	a1,0
    8000481e:	00000097          	auipc	ra,0x0
    80004822:	dd0080e7          	jalr	-560(ra) # 800045ee <namex>
}
    80004826:	60e2                	ld	ra,24(sp)
    80004828:	6442                	ld	s0,16(sp)
    8000482a:	6105                	addi	sp,sp,32
    8000482c:	8082                	ret

000000008000482e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000482e:	1141                	addi	sp,sp,-16
    80004830:	e406                	sd	ra,8(sp)
    80004832:	e022                	sd	s0,0(sp)
    80004834:	0800                	addi	s0,sp,16
    80004836:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004838:	4585                	li	a1,1
    8000483a:	00000097          	auipc	ra,0x0
    8000483e:	db4080e7          	jalr	-588(ra) # 800045ee <namex>
}
    80004842:	60a2                	ld	ra,8(sp)
    80004844:	6402                	ld	s0,0(sp)
    80004846:	0141                	addi	sp,sp,16
    80004848:	8082                	ret

000000008000484a <itoa>:


#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
    8000484a:	1101                	addi	sp,sp,-32
    8000484c:	ec22                	sd	s0,24(sp)
    8000484e:	1000                	addi	s0,sp,32
    80004850:	872a                	mv	a4,a0
    80004852:	852e                	mv	a0,a1
    char const digit[] = "0123456789";
    80004854:	00005797          	auipc	a5,0x5
    80004858:	28478793          	addi	a5,a5,644 # 80009ad8 <syscalls+0x1d8>
    8000485c:	6394                	ld	a3,0(a5)
    8000485e:	fed43023          	sd	a3,-32(s0)
    80004862:	0087d683          	lhu	a3,8(a5)
    80004866:	fed41423          	sh	a3,-24(s0)
    8000486a:	00a7c783          	lbu	a5,10(a5)
    8000486e:	fef40523          	sb	a5,-22(s0)
    char* p = b;
    80004872:	87ae                	mv	a5,a1
    if(i<0){
    80004874:	02074b63          	bltz	a4,800048aa <itoa+0x60>
        *p++ = '-';
        i *= -1;
    }
    int shifter = i;
    80004878:	86ba                	mv	a3,a4
    do{ //Move to where representation ends
        ++p;
        shifter = shifter/10;
    8000487a:	4629                	li	a2,10
        ++p;
    8000487c:	0785                	addi	a5,a5,1
        shifter = shifter/10;
    8000487e:	02c6c6bb          	divw	a3,a3,a2
    }while(shifter);
    80004882:	feed                	bnez	a3,8000487c <itoa+0x32>
    *p = '\0';
    80004884:	00078023          	sb	zero,0(a5)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
    80004888:	4629                	li	a2,10
    8000488a:	17fd                	addi	a5,a5,-1
    8000488c:	02c766bb          	remw	a3,a4,a2
    80004890:	ff040593          	addi	a1,s0,-16
    80004894:	96ae                	add	a3,a3,a1
    80004896:	ff06c683          	lbu	a3,-16(a3)
    8000489a:	00d78023          	sb	a3,0(a5)
        i = i/10;
    8000489e:	02c7473b          	divw	a4,a4,a2
    }while(i);
    800048a2:	f765                	bnez	a4,8000488a <itoa+0x40>
    return b;
}
    800048a4:	6462                	ld	s0,24(sp)
    800048a6:	6105                	addi	sp,sp,32
    800048a8:	8082                	ret
        *p++ = '-';
    800048aa:	00158793          	addi	a5,a1,1
    800048ae:	02d00693          	li	a3,45
    800048b2:	00d58023          	sb	a3,0(a1)
        i *= -1;
    800048b6:	40e0073b          	negw	a4,a4
    800048ba:	bf7d                	j	80004878 <itoa+0x2e>

00000000800048bc <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
    800048bc:	711d                	addi	sp,sp,-96
    800048be:	ec86                	sd	ra,88(sp)
    800048c0:	e8a2                	sd	s0,80(sp)
    800048c2:	e4a6                	sd	s1,72(sp)
    800048c4:	e0ca                	sd	s2,64(sp)
    800048c6:	1080                	addi	s0,sp,96
    800048c8:	84aa                	mv	s1,a0
  //path of proccess
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    800048ca:	4619                	li	a2,6
    800048cc:	00005597          	auipc	a1,0x5
    800048d0:	21c58593          	addi	a1,a1,540 # 80009ae8 <syscalls+0x1e8>
    800048d4:	fd040513          	addi	a0,s0,-48
    800048d8:	ffffc097          	auipc	ra,0xffffc
    800048dc:	442080e7          	jalr	1090(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    800048e0:	fd640593          	addi	a1,s0,-42
    800048e4:	5888                	lw	a0,48(s1)
    800048e6:	00000097          	auipc	ra,0x0
    800048ea:	f64080e7          	jalr	-156(ra) # 8000484a <itoa>
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ];
  uint off;

  if(0 == p->swapFile)
    800048ee:	1684b503          	ld	a0,360(s1)
    800048f2:	16050763          	beqz	a0,80004a60 <removeSwapFile+0x1a4>
  {
    return -1;
  }
  fileclose(p->swapFile);
    800048f6:	00001097          	auipc	ra,0x1
    800048fa:	918080e7          	jalr	-1768(ra) # 8000520e <fileclose>

  begin_op();
    800048fe:	00000097          	auipc	ra,0x0
    80004902:	444080e7          	jalr	1092(ra) # 80004d42 <begin_op>
  if((dp = nameiparent(path, name)) == 0)
    80004906:	fb040593          	addi	a1,s0,-80
    8000490a:	fd040513          	addi	a0,s0,-48
    8000490e:	00000097          	auipc	ra,0x0
    80004912:	f20080e7          	jalr	-224(ra) # 8000482e <nameiparent>
    80004916:	892a                	mv	s2,a0
    80004918:	cd69                	beqz	a0,800049f2 <removeSwapFile+0x136>
  {
    end_op();
    return -1;
  }

  ilock(dp);
    8000491a:	fffff097          	auipc	ra,0xfffff
    8000491e:	740080e7          	jalr	1856(ra) # 8000405a <ilock>

    // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004922:	00005597          	auipc	a1,0x5
    80004926:	1ce58593          	addi	a1,a1,462 # 80009af0 <syscalls+0x1f0>
    8000492a:	fb040513          	addi	a0,s0,-80
    8000492e:	00000097          	auipc	ra,0x0
    80004932:	bf6080e7          	jalr	-1034(ra) # 80004524 <namecmp>
    80004936:	c57d                	beqz	a0,80004a24 <removeSwapFile+0x168>
    80004938:	00005597          	auipc	a1,0x5
    8000493c:	1c058593          	addi	a1,a1,448 # 80009af8 <syscalls+0x1f8>
    80004940:	fb040513          	addi	a0,s0,-80
    80004944:	00000097          	auipc	ra,0x0
    80004948:	be0080e7          	jalr	-1056(ra) # 80004524 <namecmp>
    8000494c:	cd61                	beqz	a0,80004a24 <removeSwapFile+0x168>
     goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    8000494e:	fac40613          	addi	a2,s0,-84
    80004952:	fb040593          	addi	a1,s0,-80
    80004956:	854a                	mv	a0,s2
    80004958:	00000097          	auipc	ra,0x0
    8000495c:	be6080e7          	jalr	-1050(ra) # 8000453e <dirlookup>
    80004960:	84aa                	mv	s1,a0
    80004962:	c169                	beqz	a0,80004a24 <removeSwapFile+0x168>
    goto bad;
  ilock(ip);
    80004964:	fffff097          	auipc	ra,0xfffff
    80004968:	6f6080e7          	jalr	1782(ra) # 8000405a <ilock>

  if(ip->nlink < 1)
    8000496c:	04a49783          	lh	a5,74(s1)
    80004970:	08f05763          	blez	a5,800049fe <removeSwapFile+0x142>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004974:	04449703          	lh	a4,68(s1)
    80004978:	4785                	li	a5,1
    8000497a:	08f70a63          	beq	a4,a5,80004a0e <removeSwapFile+0x152>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    8000497e:	4641                	li	a2,16
    80004980:	4581                	li	a1,0
    80004982:	fc040513          	addi	a0,s0,-64
    80004986:	ffffc097          	auipc	ra,0xffffc
    8000498a:	338080e7          	jalr	824(ra) # 80000cbe <memset>
  if(writei(dp,0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000498e:	4741                	li	a4,16
    80004990:	fac42683          	lw	a3,-84(s0)
    80004994:	fc040613          	addi	a2,s0,-64
    80004998:	4581                	li	a1,0
    8000499a:	854a                	mv	a0,s2
    8000499c:	00000097          	auipc	ra,0x0
    800049a0:	a6a080e7          	jalr	-1430(ra) # 80004406 <writei>
    800049a4:	47c1                	li	a5,16
    800049a6:	08f51a63          	bne	a0,a5,80004a3a <removeSwapFile+0x17e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    800049aa:	04449703          	lh	a4,68(s1)
    800049ae:	4785                	li	a5,1
    800049b0:	08f70d63          	beq	a4,a5,80004a4a <removeSwapFile+0x18e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    800049b4:	854a                	mv	a0,s2
    800049b6:	00000097          	auipc	ra,0x0
    800049ba:	906080e7          	jalr	-1786(ra) # 800042bc <iunlockput>

  ip->nlink--;
    800049be:	04a4d783          	lhu	a5,74(s1)
    800049c2:	37fd                	addiw	a5,a5,-1
    800049c4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800049c8:	8526                	mv	a0,s1
    800049ca:	fffff097          	auipc	ra,0xfffff
    800049ce:	5c6080e7          	jalr	1478(ra) # 80003f90 <iupdate>
  iunlockput(ip);
    800049d2:	8526                	mv	a0,s1
    800049d4:	00000097          	auipc	ra,0x0
    800049d8:	8e8080e7          	jalr	-1816(ra) # 800042bc <iunlockput>

  end_op();
    800049dc:	00000097          	auipc	ra,0x0
    800049e0:	3e6080e7          	jalr	998(ra) # 80004dc2 <end_op>

  return 0;
    800049e4:	4501                	li	a0,0
    iunlockput(dp);
    end_op();
    return -1;
    printf("end RemoveSwapFile\n"); //TODO: delete

}
    800049e6:	60e6                	ld	ra,88(sp)
    800049e8:	6446                	ld	s0,80(sp)
    800049ea:	64a6                	ld	s1,72(sp)
    800049ec:	6906                	ld	s2,64(sp)
    800049ee:	6125                	addi	sp,sp,96
    800049f0:	8082                	ret
    end_op();
    800049f2:	00000097          	auipc	ra,0x0
    800049f6:	3d0080e7          	jalr	976(ra) # 80004dc2 <end_op>
    return -1;
    800049fa:	557d                	li	a0,-1
    800049fc:	b7ed                	j	800049e6 <removeSwapFile+0x12a>
    panic("unlink: nlink < 1");
    800049fe:	00005517          	auipc	a0,0x5
    80004a02:	10250513          	addi	a0,a0,258 # 80009b00 <syscalls+0x200>
    80004a06:	ffffc097          	auipc	ra,0xffffc
    80004a0a:	b24080e7          	jalr	-1244(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004a0e:	8526                	mv	a0,s1
    80004a10:	00001097          	auipc	ra,0x1
    80004a14:	7b4080e7          	jalr	1972(ra) # 800061c4 <isdirempty>
    80004a18:	f13d                	bnez	a0,8000497e <removeSwapFile+0xc2>
    iunlockput(ip);
    80004a1a:	8526                	mv	a0,s1
    80004a1c:	00000097          	auipc	ra,0x0
    80004a20:	8a0080e7          	jalr	-1888(ra) # 800042bc <iunlockput>
    iunlockput(dp);
    80004a24:	854a                	mv	a0,s2
    80004a26:	00000097          	auipc	ra,0x0
    80004a2a:	896080e7          	jalr	-1898(ra) # 800042bc <iunlockput>
    end_op();
    80004a2e:	00000097          	auipc	ra,0x0
    80004a32:	394080e7          	jalr	916(ra) # 80004dc2 <end_op>
    return -1;
    80004a36:	557d                	li	a0,-1
    80004a38:	b77d                	j	800049e6 <removeSwapFile+0x12a>
    panic("unlink: writei");
    80004a3a:	00005517          	auipc	a0,0x5
    80004a3e:	0de50513          	addi	a0,a0,222 # 80009b18 <syscalls+0x218>
    80004a42:	ffffc097          	auipc	ra,0xffffc
    80004a46:	ae8080e7          	jalr	-1304(ra) # 8000052a <panic>
    dp->nlink--;
    80004a4a:	04a95783          	lhu	a5,74(s2)
    80004a4e:	37fd                	addiw	a5,a5,-1
    80004a50:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80004a54:	854a                	mv	a0,s2
    80004a56:	fffff097          	auipc	ra,0xfffff
    80004a5a:	53a080e7          	jalr	1338(ra) # 80003f90 <iupdate>
    80004a5e:	bf99                	j	800049b4 <removeSwapFile+0xf8>
    return -1;
    80004a60:	557d                	li	a0,-1
    80004a62:	b751                	j	800049e6 <removeSwapFile+0x12a>

0000000080004a64 <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
    80004a64:	7179                	addi	sp,sp,-48
    80004a66:	f406                	sd	ra,40(sp)
    80004a68:	f022                	sd	s0,32(sp)
    80004a6a:	ec26                	sd	s1,24(sp)
    80004a6c:	e84a                	sd	s2,16(sp)
    80004a6e:	1800                	addi	s0,sp,48
    80004a70:	84aa                	mv	s1,a0
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    80004a72:	4619                	li	a2,6
    80004a74:	00005597          	auipc	a1,0x5
    80004a78:	07458593          	addi	a1,a1,116 # 80009ae8 <syscalls+0x1e8>
    80004a7c:	fd040513          	addi	a0,s0,-48
    80004a80:	ffffc097          	auipc	ra,0xffffc
    80004a84:	29a080e7          	jalr	666(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    80004a88:	fd640593          	addi	a1,s0,-42
    80004a8c:	5888                	lw	a0,48(s1)
    80004a8e:	00000097          	auipc	ra,0x0
    80004a92:	dbc080e7          	jalr	-580(ra) # 8000484a <itoa>

  begin_op();
    80004a96:	00000097          	auipc	ra,0x0
    80004a9a:	2ac080e7          	jalr	684(ra) # 80004d42 <begin_op>

  struct inode * in = create(path, T_FILE, 0, 0);
    80004a9e:	4681                	li	a3,0
    80004aa0:	4601                	li	a2,0
    80004aa2:	4589                	li	a1,2
    80004aa4:	fd040513          	addi	a0,s0,-48
    80004aa8:	00002097          	auipc	ra,0x2
    80004aac:	910080e7          	jalr	-1776(ra) # 800063b8 <create>
    80004ab0:	892a                	mv	s2,a0
  iunlock(in);
    80004ab2:	fffff097          	auipc	ra,0xfffff
    80004ab6:	66a080e7          	jalr	1642(ra) # 8000411c <iunlock>
  p->swapFile = filealloc();  if (p->swapFile == 0)
    80004aba:	00000097          	auipc	ra,0x0
    80004abe:	698080e7          	jalr	1688(ra) # 80005152 <filealloc>
    80004ac2:	16a4b423          	sd	a0,360(s1)
    80004ac6:	cd1d                	beqz	a0,80004b04 <createSwapFile+0xa0>
    panic("no slot for files on /store");

  p->swapFile->ip = in;
    80004ac8:	01253c23          	sd	s2,24(a0)
  p->swapFile->type = FD_INODE;
    80004acc:	1684b703          	ld	a4,360(s1)
    80004ad0:	4789                	li	a5,2
    80004ad2:	c31c                	sw	a5,0(a4)
  p->swapFile->off = 0;
    80004ad4:	1684b703          	ld	a4,360(s1)
    80004ad8:	02072023          	sw	zero,32(a4) # 43020 <_entry-0x7ffbcfe0>
  p->swapFile->readable = O_WRONLY;
    80004adc:	1684b703          	ld	a4,360(s1)
    80004ae0:	4685                	li	a3,1
    80004ae2:	00d70423          	sb	a3,8(a4)
  p->swapFile->writable = O_RDWR;
    80004ae6:	1684b703          	ld	a4,360(s1)
    80004aea:	00f704a3          	sb	a5,9(a4)
    end_op();
    80004aee:	00000097          	auipc	ra,0x0
    80004af2:	2d4080e7          	jalr	724(ra) # 80004dc2 <end_op>

    return 0;
}
    80004af6:	4501                	li	a0,0
    80004af8:	70a2                	ld	ra,40(sp)
    80004afa:	7402                	ld	s0,32(sp)
    80004afc:	64e2                	ld	s1,24(sp)
    80004afe:	6942                	ld	s2,16(sp)
    80004b00:	6145                	addi	sp,sp,48
    80004b02:	8082                	ret
    panic("no slot for files on /store");
    80004b04:	00005517          	auipc	a0,0x5
    80004b08:	02450513          	addi	a0,a0,36 # 80009b28 <syscalls+0x228>
    80004b0c:	ffffc097          	auipc	ra,0xffffc
    80004b10:	a1e080e7          	jalr	-1506(ra) # 8000052a <panic>

0000000080004b14 <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004b14:	1141                	addi	sp,sp,-16
    80004b16:	e406                	sd	ra,8(sp)
    80004b18:	e022                	sd	s0,0(sp)
    80004b1a:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004b1c:	16853783          	ld	a5,360(a0)
    80004b20:	d390                	sw	a2,32(a5)
  return kfilewrite(p->swapFile, (uint64)buffer, size);
    80004b22:	8636                	mv	a2,a3
    80004b24:	16853503          	ld	a0,360(a0)
    80004b28:	00001097          	auipc	ra,0x1
    80004b2c:	ad8080e7          	jalr	-1320(ra) # 80005600 <kfilewrite>
}
    80004b30:	60a2                	ld	ra,8(sp)
    80004b32:	6402                	ld	s0,0(sp)
    80004b34:	0141                	addi	sp,sp,16
    80004b36:	8082                	ret

0000000080004b38 <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004b38:	1141                	addi	sp,sp,-16
    80004b3a:	e406                	sd	ra,8(sp)
    80004b3c:	e022                	sd	s0,0(sp)
    80004b3e:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004b40:	16853783          	ld	a5,360(a0)
    80004b44:	d390                	sw	a2,32(a5)
  return kfileread(p->swapFile, (uint64)buffer,  size);
    80004b46:	8636                	mv	a2,a3
    80004b48:	16853503          	ld	a0,360(a0)
    80004b4c:	00001097          	auipc	ra,0x1
    80004b50:	9f2080e7          	jalr	-1550(ra) # 8000553e <kfileread>
    80004b54:	60a2                	ld	ra,8(sp)
    80004b56:	6402                	ld	s0,0(sp)
    80004b58:	0141                	addi	sp,sp,16
    80004b5a:	8082                	ret

0000000080004b5c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004b5c:	1101                	addi	sp,sp,-32
    80004b5e:	ec06                	sd	ra,24(sp)
    80004b60:	e822                	sd	s0,16(sp)
    80004b62:	e426                	sd	s1,8(sp)
    80004b64:	e04a                	sd	s2,0(sp)
    80004b66:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004b68:	0002a917          	auipc	s2,0x2a
    80004b6c:	10890913          	addi	s2,s2,264 # 8002ec70 <log>
    80004b70:	01892583          	lw	a1,24(s2)
    80004b74:	02892503          	lw	a0,40(s2)
    80004b78:	fffff097          	auipc	ra,0xfffff
    80004b7c:	cde080e7          	jalr	-802(ra) # 80003856 <bread>
    80004b80:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004b82:	02c92683          	lw	a3,44(s2)
    80004b86:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004b88:	02d05863          	blez	a3,80004bb8 <write_head+0x5c>
    80004b8c:	0002a797          	auipc	a5,0x2a
    80004b90:	11478793          	addi	a5,a5,276 # 8002eca0 <log+0x30>
    80004b94:	05c50713          	addi	a4,a0,92
    80004b98:	36fd                	addiw	a3,a3,-1
    80004b9a:	02069613          	slli	a2,a3,0x20
    80004b9e:	01e65693          	srli	a3,a2,0x1e
    80004ba2:	0002a617          	auipc	a2,0x2a
    80004ba6:	10260613          	addi	a2,a2,258 # 8002eca4 <log+0x34>
    80004baa:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004bac:	4390                	lw	a2,0(a5)
    80004bae:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004bb0:	0791                	addi	a5,a5,4
    80004bb2:	0711                	addi	a4,a4,4
    80004bb4:	fed79ce3          	bne	a5,a3,80004bac <write_head+0x50>
  }
  bwrite(buf);
    80004bb8:	8526                	mv	a0,s1
    80004bba:	fffff097          	auipc	ra,0xfffff
    80004bbe:	d8e080e7          	jalr	-626(ra) # 80003948 <bwrite>
  brelse(buf);
    80004bc2:	8526                	mv	a0,s1
    80004bc4:	fffff097          	auipc	ra,0xfffff
    80004bc8:	dc2080e7          	jalr	-574(ra) # 80003986 <brelse>
}
    80004bcc:	60e2                	ld	ra,24(sp)
    80004bce:	6442                	ld	s0,16(sp)
    80004bd0:	64a2                	ld	s1,8(sp)
    80004bd2:	6902                	ld	s2,0(sp)
    80004bd4:	6105                	addi	sp,sp,32
    80004bd6:	8082                	ret

0000000080004bd8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004bd8:	0002a797          	auipc	a5,0x2a
    80004bdc:	0c47a783          	lw	a5,196(a5) # 8002ec9c <log+0x2c>
    80004be0:	0af05d63          	blez	a5,80004c9a <install_trans+0xc2>
{
    80004be4:	7139                	addi	sp,sp,-64
    80004be6:	fc06                	sd	ra,56(sp)
    80004be8:	f822                	sd	s0,48(sp)
    80004bea:	f426                	sd	s1,40(sp)
    80004bec:	f04a                	sd	s2,32(sp)
    80004bee:	ec4e                	sd	s3,24(sp)
    80004bf0:	e852                	sd	s4,16(sp)
    80004bf2:	e456                	sd	s5,8(sp)
    80004bf4:	e05a                	sd	s6,0(sp)
    80004bf6:	0080                	addi	s0,sp,64
    80004bf8:	8b2a                	mv	s6,a0
    80004bfa:	0002aa97          	auipc	s5,0x2a
    80004bfe:	0a6a8a93          	addi	s5,s5,166 # 8002eca0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c02:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004c04:	0002a997          	auipc	s3,0x2a
    80004c08:	06c98993          	addi	s3,s3,108 # 8002ec70 <log>
    80004c0c:	a00d                	j	80004c2e <install_trans+0x56>
    brelse(lbuf);
    80004c0e:	854a                	mv	a0,s2
    80004c10:	fffff097          	auipc	ra,0xfffff
    80004c14:	d76080e7          	jalr	-650(ra) # 80003986 <brelse>
    brelse(dbuf);
    80004c18:	8526                	mv	a0,s1
    80004c1a:	fffff097          	auipc	ra,0xfffff
    80004c1e:	d6c080e7          	jalr	-660(ra) # 80003986 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c22:	2a05                	addiw	s4,s4,1
    80004c24:	0a91                	addi	s5,s5,4
    80004c26:	02c9a783          	lw	a5,44(s3)
    80004c2a:	04fa5e63          	bge	s4,a5,80004c86 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004c2e:	0189a583          	lw	a1,24(s3)
    80004c32:	014585bb          	addw	a1,a1,s4
    80004c36:	2585                	addiw	a1,a1,1
    80004c38:	0289a503          	lw	a0,40(s3)
    80004c3c:	fffff097          	auipc	ra,0xfffff
    80004c40:	c1a080e7          	jalr	-998(ra) # 80003856 <bread>
    80004c44:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004c46:	000aa583          	lw	a1,0(s5)
    80004c4a:	0289a503          	lw	a0,40(s3)
    80004c4e:	fffff097          	auipc	ra,0xfffff
    80004c52:	c08080e7          	jalr	-1016(ra) # 80003856 <bread>
    80004c56:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004c58:	40000613          	li	a2,1024
    80004c5c:	05890593          	addi	a1,s2,88
    80004c60:	05850513          	addi	a0,a0,88
    80004c64:	ffffc097          	auipc	ra,0xffffc
    80004c68:	0b6080e7          	jalr	182(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004c6c:	8526                	mv	a0,s1
    80004c6e:	fffff097          	auipc	ra,0xfffff
    80004c72:	cda080e7          	jalr	-806(ra) # 80003948 <bwrite>
    if(recovering == 0)
    80004c76:	f80b1ce3          	bnez	s6,80004c0e <install_trans+0x36>
      bunpin(dbuf);
    80004c7a:	8526                	mv	a0,s1
    80004c7c:	fffff097          	auipc	ra,0xfffff
    80004c80:	de4080e7          	jalr	-540(ra) # 80003a60 <bunpin>
    80004c84:	b769                	j	80004c0e <install_trans+0x36>
}
    80004c86:	70e2                	ld	ra,56(sp)
    80004c88:	7442                	ld	s0,48(sp)
    80004c8a:	74a2                	ld	s1,40(sp)
    80004c8c:	7902                	ld	s2,32(sp)
    80004c8e:	69e2                	ld	s3,24(sp)
    80004c90:	6a42                	ld	s4,16(sp)
    80004c92:	6aa2                	ld	s5,8(sp)
    80004c94:	6b02                	ld	s6,0(sp)
    80004c96:	6121                	addi	sp,sp,64
    80004c98:	8082                	ret
    80004c9a:	8082                	ret

0000000080004c9c <initlog>:
{
    80004c9c:	7179                	addi	sp,sp,-48
    80004c9e:	f406                	sd	ra,40(sp)
    80004ca0:	f022                	sd	s0,32(sp)
    80004ca2:	ec26                	sd	s1,24(sp)
    80004ca4:	e84a                	sd	s2,16(sp)
    80004ca6:	e44e                	sd	s3,8(sp)
    80004ca8:	1800                	addi	s0,sp,48
    80004caa:	892a                	mv	s2,a0
    80004cac:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004cae:	0002a497          	auipc	s1,0x2a
    80004cb2:	fc248493          	addi	s1,s1,-62 # 8002ec70 <log>
    80004cb6:	00005597          	auipc	a1,0x5
    80004cba:	e9258593          	addi	a1,a1,-366 # 80009b48 <syscalls+0x248>
    80004cbe:	8526                	mv	a0,s1
    80004cc0:	ffffc097          	auipc	ra,0xffffc
    80004cc4:	e72080e7          	jalr	-398(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004cc8:	0149a583          	lw	a1,20(s3)
    80004ccc:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004cce:	0109a783          	lw	a5,16(s3)
    80004cd2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004cd4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004cd8:	854a                	mv	a0,s2
    80004cda:	fffff097          	auipc	ra,0xfffff
    80004cde:	b7c080e7          	jalr	-1156(ra) # 80003856 <bread>
  log.lh.n = lh->n;
    80004ce2:	4d34                	lw	a3,88(a0)
    80004ce4:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004ce6:	02d05663          	blez	a3,80004d12 <initlog+0x76>
    80004cea:	05c50793          	addi	a5,a0,92
    80004cee:	0002a717          	auipc	a4,0x2a
    80004cf2:	fb270713          	addi	a4,a4,-78 # 8002eca0 <log+0x30>
    80004cf6:	36fd                	addiw	a3,a3,-1
    80004cf8:	02069613          	slli	a2,a3,0x20
    80004cfc:	01e65693          	srli	a3,a2,0x1e
    80004d00:	06050613          	addi	a2,a0,96
    80004d04:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004d06:	4390                	lw	a2,0(a5)
    80004d08:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004d0a:	0791                	addi	a5,a5,4
    80004d0c:	0711                	addi	a4,a4,4
    80004d0e:	fed79ce3          	bne	a5,a3,80004d06 <initlog+0x6a>
  brelse(buf);
    80004d12:	fffff097          	auipc	ra,0xfffff
    80004d16:	c74080e7          	jalr	-908(ra) # 80003986 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004d1a:	4505                	li	a0,1
    80004d1c:	00000097          	auipc	ra,0x0
    80004d20:	ebc080e7          	jalr	-324(ra) # 80004bd8 <install_trans>
  log.lh.n = 0;
    80004d24:	0002a797          	auipc	a5,0x2a
    80004d28:	f607ac23          	sw	zero,-136(a5) # 8002ec9c <log+0x2c>
  write_head(); // clear the log
    80004d2c:	00000097          	auipc	ra,0x0
    80004d30:	e30080e7          	jalr	-464(ra) # 80004b5c <write_head>
}
    80004d34:	70a2                	ld	ra,40(sp)
    80004d36:	7402                	ld	s0,32(sp)
    80004d38:	64e2                	ld	s1,24(sp)
    80004d3a:	6942                	ld	s2,16(sp)
    80004d3c:	69a2                	ld	s3,8(sp)
    80004d3e:	6145                	addi	sp,sp,48
    80004d40:	8082                	ret

0000000080004d42 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004d42:	1101                	addi	sp,sp,-32
    80004d44:	ec06                	sd	ra,24(sp)
    80004d46:	e822                	sd	s0,16(sp)
    80004d48:	e426                	sd	s1,8(sp)
    80004d4a:	e04a                	sd	s2,0(sp)
    80004d4c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004d4e:	0002a517          	auipc	a0,0x2a
    80004d52:	f2250513          	addi	a0,a0,-222 # 8002ec70 <log>
    80004d56:	ffffc097          	auipc	ra,0xffffc
    80004d5a:	e6c080e7          	jalr	-404(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    80004d5e:	0002a497          	auipc	s1,0x2a
    80004d62:	f1248493          	addi	s1,s1,-238 # 8002ec70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004d66:	4979                	li	s2,30
    80004d68:	a039                	j	80004d76 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004d6a:	85a6                	mv	a1,s1
    80004d6c:	8526                	mv	a0,s1
    80004d6e:	ffffd097          	auipc	ra,0xffffd
    80004d72:	4be080e7          	jalr	1214(ra) # 8000222c <sleep>
    if(log.committing){
    80004d76:	50dc                	lw	a5,36(s1)
    80004d78:	fbed                	bnez	a5,80004d6a <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004d7a:	509c                	lw	a5,32(s1)
    80004d7c:	0017871b          	addiw	a4,a5,1
    80004d80:	0007069b          	sext.w	a3,a4
    80004d84:	0027179b          	slliw	a5,a4,0x2
    80004d88:	9fb9                	addw	a5,a5,a4
    80004d8a:	0017979b          	slliw	a5,a5,0x1
    80004d8e:	54d8                	lw	a4,44(s1)
    80004d90:	9fb9                	addw	a5,a5,a4
    80004d92:	00f95963          	bge	s2,a5,80004da4 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004d96:	85a6                	mv	a1,s1
    80004d98:	8526                	mv	a0,s1
    80004d9a:	ffffd097          	auipc	ra,0xffffd
    80004d9e:	492080e7          	jalr	1170(ra) # 8000222c <sleep>
    80004da2:	bfd1                	j	80004d76 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004da4:	0002a517          	auipc	a0,0x2a
    80004da8:	ecc50513          	addi	a0,a0,-308 # 8002ec70 <log>
    80004dac:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004dae:	ffffc097          	auipc	ra,0xffffc
    80004db2:	ec8080e7          	jalr	-312(ra) # 80000c76 <release>
      break;
    }
  }
}
    80004db6:	60e2                	ld	ra,24(sp)
    80004db8:	6442                	ld	s0,16(sp)
    80004dba:	64a2                	ld	s1,8(sp)
    80004dbc:	6902                	ld	s2,0(sp)
    80004dbe:	6105                	addi	sp,sp,32
    80004dc0:	8082                	ret

0000000080004dc2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004dc2:	7139                	addi	sp,sp,-64
    80004dc4:	fc06                	sd	ra,56(sp)
    80004dc6:	f822                	sd	s0,48(sp)
    80004dc8:	f426                	sd	s1,40(sp)
    80004dca:	f04a                	sd	s2,32(sp)
    80004dcc:	ec4e                	sd	s3,24(sp)
    80004dce:	e852                	sd	s4,16(sp)
    80004dd0:	e456                	sd	s5,8(sp)
    80004dd2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004dd4:	0002a497          	auipc	s1,0x2a
    80004dd8:	e9c48493          	addi	s1,s1,-356 # 8002ec70 <log>
    80004ddc:	8526                	mv	a0,s1
    80004dde:	ffffc097          	auipc	ra,0xffffc
    80004de2:	de4080e7          	jalr	-540(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004de6:	509c                	lw	a5,32(s1)
    80004de8:	37fd                	addiw	a5,a5,-1
    80004dea:	0007891b          	sext.w	s2,a5
    80004dee:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004df0:	50dc                	lw	a5,36(s1)
    80004df2:	e7b9                	bnez	a5,80004e40 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004df4:	04091e63          	bnez	s2,80004e50 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004df8:	0002a497          	auipc	s1,0x2a
    80004dfc:	e7848493          	addi	s1,s1,-392 # 8002ec70 <log>
    80004e00:	4785                	li	a5,1
    80004e02:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004e04:	8526                	mv	a0,s1
    80004e06:	ffffc097          	auipc	ra,0xffffc
    80004e0a:	e70080e7          	jalr	-400(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004e0e:	54dc                	lw	a5,44(s1)
    80004e10:	06f04763          	bgtz	a5,80004e7e <end_op+0xbc>
    acquire(&log.lock);
    80004e14:	0002a497          	auipc	s1,0x2a
    80004e18:	e5c48493          	addi	s1,s1,-420 # 8002ec70 <log>
    80004e1c:	8526                	mv	a0,s1
    80004e1e:	ffffc097          	auipc	ra,0xffffc
    80004e22:	da4080e7          	jalr	-604(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004e26:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004e2a:	8526                	mv	a0,s1
    80004e2c:	ffffd097          	auipc	ra,0xffffd
    80004e30:	58c080e7          	jalr	1420(ra) # 800023b8 <wakeup>
    release(&log.lock);
    80004e34:	8526                	mv	a0,s1
    80004e36:	ffffc097          	auipc	ra,0xffffc
    80004e3a:	e40080e7          	jalr	-448(ra) # 80000c76 <release>
}
    80004e3e:	a03d                	j	80004e6c <end_op+0xaa>
    panic("log.committing");
    80004e40:	00005517          	auipc	a0,0x5
    80004e44:	d1050513          	addi	a0,a0,-752 # 80009b50 <syscalls+0x250>
    80004e48:	ffffb097          	auipc	ra,0xffffb
    80004e4c:	6e2080e7          	jalr	1762(ra) # 8000052a <panic>
    wakeup(&log);
    80004e50:	0002a497          	auipc	s1,0x2a
    80004e54:	e2048493          	addi	s1,s1,-480 # 8002ec70 <log>
    80004e58:	8526                	mv	a0,s1
    80004e5a:	ffffd097          	auipc	ra,0xffffd
    80004e5e:	55e080e7          	jalr	1374(ra) # 800023b8 <wakeup>
  release(&log.lock);
    80004e62:	8526                	mv	a0,s1
    80004e64:	ffffc097          	auipc	ra,0xffffc
    80004e68:	e12080e7          	jalr	-494(ra) # 80000c76 <release>
}
    80004e6c:	70e2                	ld	ra,56(sp)
    80004e6e:	7442                	ld	s0,48(sp)
    80004e70:	74a2                	ld	s1,40(sp)
    80004e72:	7902                	ld	s2,32(sp)
    80004e74:	69e2                	ld	s3,24(sp)
    80004e76:	6a42                	ld	s4,16(sp)
    80004e78:	6aa2                	ld	s5,8(sp)
    80004e7a:	6121                	addi	sp,sp,64
    80004e7c:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004e7e:	0002aa97          	auipc	s5,0x2a
    80004e82:	e22a8a93          	addi	s5,s5,-478 # 8002eca0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004e86:	0002aa17          	auipc	s4,0x2a
    80004e8a:	deaa0a13          	addi	s4,s4,-534 # 8002ec70 <log>
    80004e8e:	018a2583          	lw	a1,24(s4)
    80004e92:	012585bb          	addw	a1,a1,s2
    80004e96:	2585                	addiw	a1,a1,1
    80004e98:	028a2503          	lw	a0,40(s4)
    80004e9c:	fffff097          	auipc	ra,0xfffff
    80004ea0:	9ba080e7          	jalr	-1606(ra) # 80003856 <bread>
    80004ea4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004ea6:	000aa583          	lw	a1,0(s5)
    80004eaa:	028a2503          	lw	a0,40(s4)
    80004eae:	fffff097          	auipc	ra,0xfffff
    80004eb2:	9a8080e7          	jalr	-1624(ra) # 80003856 <bread>
    80004eb6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004eb8:	40000613          	li	a2,1024
    80004ebc:	05850593          	addi	a1,a0,88
    80004ec0:	05848513          	addi	a0,s1,88
    80004ec4:	ffffc097          	auipc	ra,0xffffc
    80004ec8:	e56080e7          	jalr	-426(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004ecc:	8526                	mv	a0,s1
    80004ece:	fffff097          	auipc	ra,0xfffff
    80004ed2:	a7a080e7          	jalr	-1414(ra) # 80003948 <bwrite>
    brelse(from);
    80004ed6:	854e                	mv	a0,s3
    80004ed8:	fffff097          	auipc	ra,0xfffff
    80004edc:	aae080e7          	jalr	-1362(ra) # 80003986 <brelse>
    brelse(to);
    80004ee0:	8526                	mv	a0,s1
    80004ee2:	fffff097          	auipc	ra,0xfffff
    80004ee6:	aa4080e7          	jalr	-1372(ra) # 80003986 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004eea:	2905                	addiw	s2,s2,1
    80004eec:	0a91                	addi	s5,s5,4
    80004eee:	02ca2783          	lw	a5,44(s4)
    80004ef2:	f8f94ee3          	blt	s2,a5,80004e8e <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004ef6:	00000097          	auipc	ra,0x0
    80004efa:	c66080e7          	jalr	-922(ra) # 80004b5c <write_head>
    install_trans(0); // Now install writes to home locations
    80004efe:	4501                	li	a0,0
    80004f00:	00000097          	auipc	ra,0x0
    80004f04:	cd8080e7          	jalr	-808(ra) # 80004bd8 <install_trans>
    log.lh.n = 0;
    80004f08:	0002a797          	auipc	a5,0x2a
    80004f0c:	d807aa23          	sw	zero,-620(a5) # 8002ec9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004f10:	00000097          	auipc	ra,0x0
    80004f14:	c4c080e7          	jalr	-948(ra) # 80004b5c <write_head>
    80004f18:	bdf5                	j	80004e14 <end_op+0x52>

0000000080004f1a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004f1a:	1101                	addi	sp,sp,-32
    80004f1c:	ec06                	sd	ra,24(sp)
    80004f1e:	e822                	sd	s0,16(sp)
    80004f20:	e426                	sd	s1,8(sp)
    80004f22:	e04a                	sd	s2,0(sp)
    80004f24:	1000                	addi	s0,sp,32
    80004f26:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004f28:	0002a917          	auipc	s2,0x2a
    80004f2c:	d4890913          	addi	s2,s2,-696 # 8002ec70 <log>
    80004f30:	854a                	mv	a0,s2
    80004f32:	ffffc097          	auipc	ra,0xffffc
    80004f36:	c90080e7          	jalr	-880(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004f3a:	02c92603          	lw	a2,44(s2)
    80004f3e:	47f5                	li	a5,29
    80004f40:	06c7c563          	blt	a5,a2,80004faa <log_write+0x90>
    80004f44:	0002a797          	auipc	a5,0x2a
    80004f48:	d487a783          	lw	a5,-696(a5) # 8002ec8c <log+0x1c>
    80004f4c:	37fd                	addiw	a5,a5,-1
    80004f4e:	04f65e63          	bge	a2,a5,80004faa <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004f52:	0002a797          	auipc	a5,0x2a
    80004f56:	d3e7a783          	lw	a5,-706(a5) # 8002ec90 <log+0x20>
    80004f5a:	06f05063          	blez	a5,80004fba <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004f5e:	4781                	li	a5,0
    80004f60:	06c05563          	blez	a2,80004fca <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004f64:	44cc                	lw	a1,12(s1)
    80004f66:	0002a717          	auipc	a4,0x2a
    80004f6a:	d3a70713          	addi	a4,a4,-710 # 8002eca0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004f6e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004f70:	4314                	lw	a3,0(a4)
    80004f72:	04b68c63          	beq	a3,a1,80004fca <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004f76:	2785                	addiw	a5,a5,1
    80004f78:	0711                	addi	a4,a4,4
    80004f7a:	fef61be3          	bne	a2,a5,80004f70 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004f7e:	0621                	addi	a2,a2,8
    80004f80:	060a                	slli	a2,a2,0x2
    80004f82:	0002a797          	auipc	a5,0x2a
    80004f86:	cee78793          	addi	a5,a5,-786 # 8002ec70 <log>
    80004f8a:	963e                	add	a2,a2,a5
    80004f8c:	44dc                	lw	a5,12(s1)
    80004f8e:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004f90:	8526                	mv	a0,s1
    80004f92:	fffff097          	auipc	ra,0xfffff
    80004f96:	a92080e7          	jalr	-1390(ra) # 80003a24 <bpin>
    log.lh.n++;
    80004f9a:	0002a717          	auipc	a4,0x2a
    80004f9e:	cd670713          	addi	a4,a4,-810 # 8002ec70 <log>
    80004fa2:	575c                	lw	a5,44(a4)
    80004fa4:	2785                	addiw	a5,a5,1
    80004fa6:	d75c                	sw	a5,44(a4)
    80004fa8:	a835                	j	80004fe4 <log_write+0xca>
    panic("too big a transaction");
    80004faa:	00005517          	auipc	a0,0x5
    80004fae:	bb650513          	addi	a0,a0,-1098 # 80009b60 <syscalls+0x260>
    80004fb2:	ffffb097          	auipc	ra,0xffffb
    80004fb6:	578080e7          	jalr	1400(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004fba:	00005517          	auipc	a0,0x5
    80004fbe:	bbe50513          	addi	a0,a0,-1090 # 80009b78 <syscalls+0x278>
    80004fc2:	ffffb097          	auipc	ra,0xffffb
    80004fc6:	568080e7          	jalr	1384(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004fca:	00878713          	addi	a4,a5,8
    80004fce:	00271693          	slli	a3,a4,0x2
    80004fd2:	0002a717          	auipc	a4,0x2a
    80004fd6:	c9e70713          	addi	a4,a4,-866 # 8002ec70 <log>
    80004fda:	9736                	add	a4,a4,a3
    80004fdc:	44d4                	lw	a3,12(s1)
    80004fde:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004fe0:	faf608e3          	beq	a2,a5,80004f90 <log_write+0x76>
  }
  release(&log.lock);
    80004fe4:	0002a517          	auipc	a0,0x2a
    80004fe8:	c8c50513          	addi	a0,a0,-884 # 8002ec70 <log>
    80004fec:	ffffc097          	auipc	ra,0xffffc
    80004ff0:	c8a080e7          	jalr	-886(ra) # 80000c76 <release>
}
    80004ff4:	60e2                	ld	ra,24(sp)
    80004ff6:	6442                	ld	s0,16(sp)
    80004ff8:	64a2                	ld	s1,8(sp)
    80004ffa:	6902                	ld	s2,0(sp)
    80004ffc:	6105                	addi	sp,sp,32
    80004ffe:	8082                	ret

0000000080005000 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80005000:	1101                	addi	sp,sp,-32
    80005002:	ec06                	sd	ra,24(sp)
    80005004:	e822                	sd	s0,16(sp)
    80005006:	e426                	sd	s1,8(sp)
    80005008:	e04a                	sd	s2,0(sp)
    8000500a:	1000                	addi	s0,sp,32
    8000500c:	84aa                	mv	s1,a0
    8000500e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80005010:	00005597          	auipc	a1,0x5
    80005014:	b8858593          	addi	a1,a1,-1144 # 80009b98 <syscalls+0x298>
    80005018:	0521                	addi	a0,a0,8
    8000501a:	ffffc097          	auipc	ra,0xffffc
    8000501e:	b18080e7          	jalr	-1256(ra) # 80000b32 <initlock>
  lk->name = name;
    80005022:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80005026:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000502a:	0204a423          	sw	zero,40(s1)
}
    8000502e:	60e2                	ld	ra,24(sp)
    80005030:	6442                	ld	s0,16(sp)
    80005032:	64a2                	ld	s1,8(sp)
    80005034:	6902                	ld	s2,0(sp)
    80005036:	6105                	addi	sp,sp,32
    80005038:	8082                	ret

000000008000503a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000503a:	1101                	addi	sp,sp,-32
    8000503c:	ec06                	sd	ra,24(sp)
    8000503e:	e822                	sd	s0,16(sp)
    80005040:	e426                	sd	s1,8(sp)
    80005042:	e04a                	sd	s2,0(sp)
    80005044:	1000                	addi	s0,sp,32
    80005046:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005048:	00850913          	addi	s2,a0,8
    8000504c:	854a                	mv	a0,s2
    8000504e:	ffffc097          	auipc	ra,0xffffc
    80005052:	b74080e7          	jalr	-1164(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    80005056:	409c                	lw	a5,0(s1)
    80005058:	cb89                	beqz	a5,8000506a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000505a:	85ca                	mv	a1,s2
    8000505c:	8526                	mv	a0,s1
    8000505e:	ffffd097          	auipc	ra,0xffffd
    80005062:	1ce080e7          	jalr	462(ra) # 8000222c <sleep>
  while (lk->locked) {
    80005066:	409c                	lw	a5,0(s1)
    80005068:	fbed                	bnez	a5,8000505a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000506a:	4785                	li	a5,1
    8000506c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000506e:	ffffd097          	auipc	ra,0xffffd
    80005072:	cc6080e7          	jalr	-826(ra) # 80001d34 <myproc>
    80005076:	591c                	lw	a5,48(a0)
    80005078:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000507a:	854a                	mv	a0,s2
    8000507c:	ffffc097          	auipc	ra,0xffffc
    80005080:	bfa080e7          	jalr	-1030(ra) # 80000c76 <release>
}
    80005084:	60e2                	ld	ra,24(sp)
    80005086:	6442                	ld	s0,16(sp)
    80005088:	64a2                	ld	s1,8(sp)
    8000508a:	6902                	ld	s2,0(sp)
    8000508c:	6105                	addi	sp,sp,32
    8000508e:	8082                	ret

0000000080005090 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005090:	1101                	addi	sp,sp,-32
    80005092:	ec06                	sd	ra,24(sp)
    80005094:	e822                	sd	s0,16(sp)
    80005096:	e426                	sd	s1,8(sp)
    80005098:	e04a                	sd	s2,0(sp)
    8000509a:	1000                	addi	s0,sp,32
    8000509c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000509e:	00850913          	addi	s2,a0,8
    800050a2:	854a                	mv	a0,s2
    800050a4:	ffffc097          	auipc	ra,0xffffc
    800050a8:	b1e080e7          	jalr	-1250(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    800050ac:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800050b0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800050b4:	8526                	mv	a0,s1
    800050b6:	ffffd097          	auipc	ra,0xffffd
    800050ba:	302080e7          	jalr	770(ra) # 800023b8 <wakeup>
  release(&lk->lk);
    800050be:	854a                	mv	a0,s2
    800050c0:	ffffc097          	auipc	ra,0xffffc
    800050c4:	bb6080e7          	jalr	-1098(ra) # 80000c76 <release>
}
    800050c8:	60e2                	ld	ra,24(sp)
    800050ca:	6442                	ld	s0,16(sp)
    800050cc:	64a2                	ld	s1,8(sp)
    800050ce:	6902                	ld	s2,0(sp)
    800050d0:	6105                	addi	sp,sp,32
    800050d2:	8082                	ret

00000000800050d4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800050d4:	7179                	addi	sp,sp,-48
    800050d6:	f406                	sd	ra,40(sp)
    800050d8:	f022                	sd	s0,32(sp)
    800050da:	ec26                	sd	s1,24(sp)
    800050dc:	e84a                	sd	s2,16(sp)
    800050de:	e44e                	sd	s3,8(sp)
    800050e0:	1800                	addi	s0,sp,48
    800050e2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800050e4:	00850913          	addi	s2,a0,8
    800050e8:	854a                	mv	a0,s2
    800050ea:	ffffc097          	auipc	ra,0xffffc
    800050ee:	ad8080e7          	jalr	-1320(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800050f2:	409c                	lw	a5,0(s1)
    800050f4:	ef99                	bnez	a5,80005112 <holdingsleep+0x3e>
    800050f6:	4481                	li	s1,0
  release(&lk->lk);
    800050f8:	854a                	mv	a0,s2
    800050fa:	ffffc097          	auipc	ra,0xffffc
    800050fe:	b7c080e7          	jalr	-1156(ra) # 80000c76 <release>
  return r;
}
    80005102:	8526                	mv	a0,s1
    80005104:	70a2                	ld	ra,40(sp)
    80005106:	7402                	ld	s0,32(sp)
    80005108:	64e2                	ld	s1,24(sp)
    8000510a:	6942                	ld	s2,16(sp)
    8000510c:	69a2                	ld	s3,8(sp)
    8000510e:	6145                	addi	sp,sp,48
    80005110:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80005112:	0284a983          	lw	s3,40(s1)
    80005116:	ffffd097          	auipc	ra,0xffffd
    8000511a:	c1e080e7          	jalr	-994(ra) # 80001d34 <myproc>
    8000511e:	5904                	lw	s1,48(a0)
    80005120:	413484b3          	sub	s1,s1,s3
    80005124:	0014b493          	seqz	s1,s1
    80005128:	bfc1                	j	800050f8 <holdingsleep+0x24>

000000008000512a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000512a:	1141                	addi	sp,sp,-16
    8000512c:	e406                	sd	ra,8(sp)
    8000512e:	e022                	sd	s0,0(sp)
    80005130:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80005132:	00005597          	auipc	a1,0x5
    80005136:	a7658593          	addi	a1,a1,-1418 # 80009ba8 <syscalls+0x2a8>
    8000513a:	0002a517          	auipc	a0,0x2a
    8000513e:	c7e50513          	addi	a0,a0,-898 # 8002edb8 <ftable>
    80005142:	ffffc097          	auipc	ra,0xffffc
    80005146:	9f0080e7          	jalr	-1552(ra) # 80000b32 <initlock>
}
    8000514a:	60a2                	ld	ra,8(sp)
    8000514c:	6402                	ld	s0,0(sp)
    8000514e:	0141                	addi	sp,sp,16
    80005150:	8082                	ret

0000000080005152 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80005152:	1101                	addi	sp,sp,-32
    80005154:	ec06                	sd	ra,24(sp)
    80005156:	e822                	sd	s0,16(sp)
    80005158:	e426                	sd	s1,8(sp)
    8000515a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000515c:	0002a517          	auipc	a0,0x2a
    80005160:	c5c50513          	addi	a0,a0,-932 # 8002edb8 <ftable>
    80005164:	ffffc097          	auipc	ra,0xffffc
    80005168:	a5e080e7          	jalr	-1442(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000516c:	0002a497          	auipc	s1,0x2a
    80005170:	c6448493          	addi	s1,s1,-924 # 8002edd0 <ftable+0x18>
    80005174:	0002b717          	auipc	a4,0x2b
    80005178:	bfc70713          	addi	a4,a4,-1028 # 8002fd70 <ftable+0xfb8>
    if(f->ref == 0){
    8000517c:	40dc                	lw	a5,4(s1)
    8000517e:	cf99                	beqz	a5,8000519c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005180:	02848493          	addi	s1,s1,40
    80005184:	fee49ce3          	bne	s1,a4,8000517c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005188:	0002a517          	auipc	a0,0x2a
    8000518c:	c3050513          	addi	a0,a0,-976 # 8002edb8 <ftable>
    80005190:	ffffc097          	auipc	ra,0xffffc
    80005194:	ae6080e7          	jalr	-1306(ra) # 80000c76 <release>
  return 0;
    80005198:	4481                	li	s1,0
    8000519a:	a819                	j	800051b0 <filealloc+0x5e>
      f->ref = 1;
    8000519c:	4785                	li	a5,1
    8000519e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800051a0:	0002a517          	auipc	a0,0x2a
    800051a4:	c1850513          	addi	a0,a0,-1000 # 8002edb8 <ftable>
    800051a8:	ffffc097          	auipc	ra,0xffffc
    800051ac:	ace080e7          	jalr	-1330(ra) # 80000c76 <release>
}
    800051b0:	8526                	mv	a0,s1
    800051b2:	60e2                	ld	ra,24(sp)
    800051b4:	6442                	ld	s0,16(sp)
    800051b6:	64a2                	ld	s1,8(sp)
    800051b8:	6105                	addi	sp,sp,32
    800051ba:	8082                	ret

00000000800051bc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800051bc:	1101                	addi	sp,sp,-32
    800051be:	ec06                	sd	ra,24(sp)
    800051c0:	e822                	sd	s0,16(sp)
    800051c2:	e426                	sd	s1,8(sp)
    800051c4:	1000                	addi	s0,sp,32
    800051c6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800051c8:	0002a517          	auipc	a0,0x2a
    800051cc:	bf050513          	addi	a0,a0,-1040 # 8002edb8 <ftable>
    800051d0:	ffffc097          	auipc	ra,0xffffc
    800051d4:	9f2080e7          	jalr	-1550(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    800051d8:	40dc                	lw	a5,4(s1)
    800051da:	02f05263          	blez	a5,800051fe <filedup+0x42>
    panic("filedup");
  f->ref++;
    800051de:	2785                	addiw	a5,a5,1
    800051e0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800051e2:	0002a517          	auipc	a0,0x2a
    800051e6:	bd650513          	addi	a0,a0,-1066 # 8002edb8 <ftable>
    800051ea:	ffffc097          	auipc	ra,0xffffc
    800051ee:	a8c080e7          	jalr	-1396(ra) # 80000c76 <release>
  return f;
}
    800051f2:	8526                	mv	a0,s1
    800051f4:	60e2                	ld	ra,24(sp)
    800051f6:	6442                	ld	s0,16(sp)
    800051f8:	64a2                	ld	s1,8(sp)
    800051fa:	6105                	addi	sp,sp,32
    800051fc:	8082                	ret
    panic("filedup");
    800051fe:	00005517          	auipc	a0,0x5
    80005202:	9b250513          	addi	a0,a0,-1614 # 80009bb0 <syscalls+0x2b0>
    80005206:	ffffb097          	auipc	ra,0xffffb
    8000520a:	324080e7          	jalr	804(ra) # 8000052a <panic>

000000008000520e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000520e:	7139                	addi	sp,sp,-64
    80005210:	fc06                	sd	ra,56(sp)
    80005212:	f822                	sd	s0,48(sp)
    80005214:	f426                	sd	s1,40(sp)
    80005216:	f04a                	sd	s2,32(sp)
    80005218:	ec4e                	sd	s3,24(sp)
    8000521a:	e852                	sd	s4,16(sp)
    8000521c:	e456                	sd	s5,8(sp)
    8000521e:	0080                	addi	s0,sp,64
    80005220:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80005222:	0002a517          	auipc	a0,0x2a
    80005226:	b9650513          	addi	a0,a0,-1130 # 8002edb8 <ftable>
    8000522a:	ffffc097          	auipc	ra,0xffffc
    8000522e:	998080e7          	jalr	-1640(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80005232:	40dc                	lw	a5,4(s1)
    80005234:	06f05163          	blez	a5,80005296 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80005238:	37fd                	addiw	a5,a5,-1
    8000523a:	0007871b          	sext.w	a4,a5
    8000523e:	c0dc                	sw	a5,4(s1)
    80005240:	06e04363          	bgtz	a4,800052a6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80005244:	0004a903          	lw	s2,0(s1)
    80005248:	0094ca83          	lbu	s5,9(s1)
    8000524c:	0104ba03          	ld	s4,16(s1)
    80005250:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80005254:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005258:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000525c:	0002a517          	auipc	a0,0x2a
    80005260:	b5c50513          	addi	a0,a0,-1188 # 8002edb8 <ftable>
    80005264:	ffffc097          	auipc	ra,0xffffc
    80005268:	a12080e7          	jalr	-1518(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    8000526c:	4785                	li	a5,1
    8000526e:	04f90d63          	beq	s2,a5,800052c8 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80005272:	3979                	addiw	s2,s2,-2
    80005274:	4785                	li	a5,1
    80005276:	0527e063          	bltu	a5,s2,800052b6 <fileclose+0xa8>
    begin_op();
    8000527a:	00000097          	auipc	ra,0x0
    8000527e:	ac8080e7          	jalr	-1336(ra) # 80004d42 <begin_op>
    iput(ff.ip);
    80005282:	854e                	mv	a0,s3
    80005284:	fffff097          	auipc	ra,0xfffff
    80005288:	f90080e7          	jalr	-112(ra) # 80004214 <iput>
    end_op();
    8000528c:	00000097          	auipc	ra,0x0
    80005290:	b36080e7          	jalr	-1226(ra) # 80004dc2 <end_op>
    80005294:	a00d                	j	800052b6 <fileclose+0xa8>
    panic("fileclose");
    80005296:	00005517          	auipc	a0,0x5
    8000529a:	92250513          	addi	a0,a0,-1758 # 80009bb8 <syscalls+0x2b8>
    8000529e:	ffffb097          	auipc	ra,0xffffb
    800052a2:	28c080e7          	jalr	652(ra) # 8000052a <panic>
    release(&ftable.lock);
    800052a6:	0002a517          	auipc	a0,0x2a
    800052aa:	b1250513          	addi	a0,a0,-1262 # 8002edb8 <ftable>
    800052ae:	ffffc097          	auipc	ra,0xffffc
    800052b2:	9c8080e7          	jalr	-1592(ra) # 80000c76 <release>
  }
}
    800052b6:	70e2                	ld	ra,56(sp)
    800052b8:	7442                	ld	s0,48(sp)
    800052ba:	74a2                	ld	s1,40(sp)
    800052bc:	7902                	ld	s2,32(sp)
    800052be:	69e2                	ld	s3,24(sp)
    800052c0:	6a42                	ld	s4,16(sp)
    800052c2:	6aa2                	ld	s5,8(sp)
    800052c4:	6121                	addi	sp,sp,64
    800052c6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800052c8:	85d6                	mv	a1,s5
    800052ca:	8552                	mv	a0,s4
    800052cc:	00000097          	auipc	ra,0x0
    800052d0:	542080e7          	jalr	1346(ra) # 8000580e <pipeclose>
    800052d4:	b7cd                	j	800052b6 <fileclose+0xa8>

00000000800052d6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800052d6:	715d                	addi	sp,sp,-80
    800052d8:	e486                	sd	ra,72(sp)
    800052da:	e0a2                	sd	s0,64(sp)
    800052dc:	fc26                	sd	s1,56(sp)
    800052de:	f84a                	sd	s2,48(sp)
    800052e0:	f44e                	sd	s3,40(sp)
    800052e2:	0880                	addi	s0,sp,80
    800052e4:	84aa                	mv	s1,a0
    800052e6:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800052e8:	ffffd097          	auipc	ra,0xffffd
    800052ec:	a4c080e7          	jalr	-1460(ra) # 80001d34 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800052f0:	409c                	lw	a5,0(s1)
    800052f2:	37f9                	addiw	a5,a5,-2
    800052f4:	4705                	li	a4,1
    800052f6:	04f76763          	bltu	a4,a5,80005344 <filestat+0x6e>
    800052fa:	892a                	mv	s2,a0
    ilock(f->ip);
    800052fc:	6c88                	ld	a0,24(s1)
    800052fe:	fffff097          	auipc	ra,0xfffff
    80005302:	d5c080e7          	jalr	-676(ra) # 8000405a <ilock>
    stati(f->ip, &st);
    80005306:	fb840593          	addi	a1,s0,-72
    8000530a:	6c88                	ld	a0,24(s1)
    8000530c:	fffff097          	auipc	ra,0xfffff
    80005310:	fd8080e7          	jalr	-40(ra) # 800042e4 <stati>
    iunlock(f->ip);
    80005314:	6c88                	ld	a0,24(s1)
    80005316:	fffff097          	auipc	ra,0xfffff
    8000531a:	e06080e7          	jalr	-506(ra) # 8000411c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000531e:	46e1                	li	a3,24
    80005320:	fb840613          	addi	a2,s0,-72
    80005324:	85ce                	mv	a1,s3
    80005326:	05093503          	ld	a0,80(s2)
    8000532a:	ffffc097          	auipc	ra,0xffffc
    8000532e:	068080e7          	jalr	104(ra) # 80001392 <copyout>
    80005332:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80005336:	60a6                	ld	ra,72(sp)
    80005338:	6406                	ld	s0,64(sp)
    8000533a:	74e2                	ld	s1,56(sp)
    8000533c:	7942                	ld	s2,48(sp)
    8000533e:	79a2                	ld	s3,40(sp)
    80005340:	6161                	addi	sp,sp,80
    80005342:	8082                	ret
  return -1;
    80005344:	557d                	li	a0,-1
    80005346:	bfc5                	j	80005336 <filestat+0x60>

0000000080005348 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005348:	7179                	addi	sp,sp,-48
    8000534a:	f406                	sd	ra,40(sp)
    8000534c:	f022                	sd	s0,32(sp)
    8000534e:	ec26                	sd	s1,24(sp)
    80005350:	e84a                	sd	s2,16(sp)
    80005352:	e44e                	sd	s3,8(sp)
    80005354:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005356:	00854783          	lbu	a5,8(a0)
    8000535a:	c3d5                	beqz	a5,800053fe <fileread+0xb6>
    8000535c:	84aa                	mv	s1,a0
    8000535e:	89ae                	mv	s3,a1
    80005360:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005362:	411c                	lw	a5,0(a0)
    80005364:	4705                	li	a4,1
    80005366:	04e78963          	beq	a5,a4,800053b8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000536a:	470d                	li	a4,3
    8000536c:	04e78d63          	beq	a5,a4,800053c6 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005370:	4709                	li	a4,2
    80005372:	06e79e63          	bne	a5,a4,800053ee <fileread+0xa6>
    ilock(f->ip);
    80005376:	6d08                	ld	a0,24(a0)
    80005378:	fffff097          	auipc	ra,0xfffff
    8000537c:	ce2080e7          	jalr	-798(ra) # 8000405a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005380:	874a                	mv	a4,s2
    80005382:	5094                	lw	a3,32(s1)
    80005384:	864e                	mv	a2,s3
    80005386:	4585                	li	a1,1
    80005388:	6c88                	ld	a0,24(s1)
    8000538a:	fffff097          	auipc	ra,0xfffff
    8000538e:	f84080e7          	jalr	-124(ra) # 8000430e <readi>
    80005392:	892a                	mv	s2,a0
    80005394:	00a05563          	blez	a0,8000539e <fileread+0x56>
      f->off += r;
    80005398:	509c                	lw	a5,32(s1)
    8000539a:	9fa9                	addw	a5,a5,a0
    8000539c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000539e:	6c88                	ld	a0,24(s1)
    800053a0:	fffff097          	auipc	ra,0xfffff
    800053a4:	d7c080e7          	jalr	-644(ra) # 8000411c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800053a8:	854a                	mv	a0,s2
    800053aa:	70a2                	ld	ra,40(sp)
    800053ac:	7402                	ld	s0,32(sp)
    800053ae:	64e2                	ld	s1,24(sp)
    800053b0:	6942                	ld	s2,16(sp)
    800053b2:	69a2                	ld	s3,8(sp)
    800053b4:	6145                	addi	sp,sp,48
    800053b6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800053b8:	6908                	ld	a0,16(a0)
    800053ba:	00000097          	auipc	ra,0x0
    800053be:	5b6080e7          	jalr	1462(ra) # 80005970 <piperead>
    800053c2:	892a                	mv	s2,a0
    800053c4:	b7d5                	j	800053a8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800053c6:	02451783          	lh	a5,36(a0)
    800053ca:	03079693          	slli	a3,a5,0x30
    800053ce:	92c1                	srli	a3,a3,0x30
    800053d0:	4725                	li	a4,9
    800053d2:	02d76863          	bltu	a4,a3,80005402 <fileread+0xba>
    800053d6:	0792                	slli	a5,a5,0x4
    800053d8:	0002a717          	auipc	a4,0x2a
    800053dc:	94070713          	addi	a4,a4,-1728 # 8002ed18 <devsw>
    800053e0:	97ba                	add	a5,a5,a4
    800053e2:	639c                	ld	a5,0(a5)
    800053e4:	c38d                	beqz	a5,80005406 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800053e6:	4505                	li	a0,1
    800053e8:	9782                	jalr	a5
    800053ea:	892a                	mv	s2,a0
    800053ec:	bf75                	j	800053a8 <fileread+0x60>
    panic("fileread");
    800053ee:	00004517          	auipc	a0,0x4
    800053f2:	7da50513          	addi	a0,a0,2010 # 80009bc8 <syscalls+0x2c8>
    800053f6:	ffffb097          	auipc	ra,0xffffb
    800053fa:	134080e7          	jalr	308(ra) # 8000052a <panic>
    return -1;
    800053fe:	597d                	li	s2,-1
    80005400:	b765                	j	800053a8 <fileread+0x60>
      return -1;
    80005402:	597d                	li	s2,-1
    80005404:	b755                	j	800053a8 <fileread+0x60>
    80005406:	597d                	li	s2,-1
    80005408:	b745                	j	800053a8 <fileread+0x60>

000000008000540a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000540a:	715d                	addi	sp,sp,-80
    8000540c:	e486                	sd	ra,72(sp)
    8000540e:	e0a2                	sd	s0,64(sp)
    80005410:	fc26                	sd	s1,56(sp)
    80005412:	f84a                	sd	s2,48(sp)
    80005414:	f44e                	sd	s3,40(sp)
    80005416:	f052                	sd	s4,32(sp)
    80005418:	ec56                	sd	s5,24(sp)
    8000541a:	e85a                	sd	s6,16(sp)
    8000541c:	e45e                	sd	s7,8(sp)
    8000541e:	e062                	sd	s8,0(sp)
    80005420:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005422:	00954783          	lbu	a5,9(a0)
    80005426:	10078663          	beqz	a5,80005532 <filewrite+0x128>
    8000542a:	892a                	mv	s2,a0
    8000542c:	8aae                	mv	s5,a1
    8000542e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005430:	411c                	lw	a5,0(a0)
    80005432:	4705                	li	a4,1
    80005434:	02e78263          	beq	a5,a4,80005458 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005438:	470d                	li	a4,3
    8000543a:	02e78663          	beq	a5,a4,80005466 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000543e:	4709                	li	a4,2
    80005440:	0ee79163          	bne	a5,a4,80005522 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005444:	0ac05d63          	blez	a2,800054fe <filewrite+0xf4>
    int i = 0;
    80005448:	4981                	li	s3,0
    8000544a:	6b05                	lui	s6,0x1
    8000544c:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005450:	6b85                	lui	s7,0x1
    80005452:	c00b8b9b          	addiw	s7,s7,-1024
    80005456:	a861                	j	800054ee <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005458:	6908                	ld	a0,16(a0)
    8000545a:	00000097          	auipc	ra,0x0
    8000545e:	424080e7          	jalr	1060(ra) # 8000587e <pipewrite>
    80005462:	8a2a                	mv	s4,a0
    80005464:	a045                	j	80005504 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005466:	02451783          	lh	a5,36(a0)
    8000546a:	03079693          	slli	a3,a5,0x30
    8000546e:	92c1                	srli	a3,a3,0x30
    80005470:	4725                	li	a4,9
    80005472:	0cd76263          	bltu	a4,a3,80005536 <filewrite+0x12c>
    80005476:	0792                	slli	a5,a5,0x4
    80005478:	0002a717          	auipc	a4,0x2a
    8000547c:	8a070713          	addi	a4,a4,-1888 # 8002ed18 <devsw>
    80005480:	97ba                	add	a5,a5,a4
    80005482:	679c                	ld	a5,8(a5)
    80005484:	cbdd                	beqz	a5,8000553a <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005486:	4505                	li	a0,1
    80005488:	9782                	jalr	a5
    8000548a:	8a2a                	mv	s4,a0
    8000548c:	a8a5                	j	80005504 <filewrite+0xfa>
    8000548e:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005492:	00000097          	auipc	ra,0x0
    80005496:	8b0080e7          	jalr	-1872(ra) # 80004d42 <begin_op>
      ilock(f->ip);
    8000549a:	01893503          	ld	a0,24(s2)
    8000549e:	fffff097          	auipc	ra,0xfffff
    800054a2:	bbc080e7          	jalr	-1092(ra) # 8000405a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800054a6:	8762                	mv	a4,s8
    800054a8:	02092683          	lw	a3,32(s2)
    800054ac:	01598633          	add	a2,s3,s5
    800054b0:	4585                	li	a1,1
    800054b2:	01893503          	ld	a0,24(s2)
    800054b6:	fffff097          	auipc	ra,0xfffff
    800054ba:	f50080e7          	jalr	-176(ra) # 80004406 <writei>
    800054be:	84aa                	mv	s1,a0
    800054c0:	00a05763          	blez	a0,800054ce <filewrite+0xc4>
        f->off += r;
    800054c4:	02092783          	lw	a5,32(s2)
    800054c8:	9fa9                	addw	a5,a5,a0
    800054ca:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800054ce:	01893503          	ld	a0,24(s2)
    800054d2:	fffff097          	auipc	ra,0xfffff
    800054d6:	c4a080e7          	jalr	-950(ra) # 8000411c <iunlock>
      end_op();
    800054da:	00000097          	auipc	ra,0x0
    800054de:	8e8080e7          	jalr	-1816(ra) # 80004dc2 <end_op>

      if(r != n1){
    800054e2:	009c1f63          	bne	s8,s1,80005500 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800054e6:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800054ea:	0149db63          	bge	s3,s4,80005500 <filewrite+0xf6>
      int n1 = n - i;
    800054ee:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800054f2:	84be                	mv	s1,a5
    800054f4:	2781                	sext.w	a5,a5
    800054f6:	f8fb5ce3          	bge	s6,a5,8000548e <filewrite+0x84>
    800054fa:	84de                	mv	s1,s7
    800054fc:	bf49                	j	8000548e <filewrite+0x84>
    int i = 0;
    800054fe:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005500:	013a1f63          	bne	s4,s3,8000551e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005504:	8552                	mv	a0,s4
    80005506:	60a6                	ld	ra,72(sp)
    80005508:	6406                	ld	s0,64(sp)
    8000550a:	74e2                	ld	s1,56(sp)
    8000550c:	7942                	ld	s2,48(sp)
    8000550e:	79a2                	ld	s3,40(sp)
    80005510:	7a02                	ld	s4,32(sp)
    80005512:	6ae2                	ld	s5,24(sp)
    80005514:	6b42                	ld	s6,16(sp)
    80005516:	6ba2                	ld	s7,8(sp)
    80005518:	6c02                	ld	s8,0(sp)
    8000551a:	6161                	addi	sp,sp,80
    8000551c:	8082                	ret
    ret = (i == n ? n : -1);
    8000551e:	5a7d                	li	s4,-1
    80005520:	b7d5                	j	80005504 <filewrite+0xfa>
    panic("filewrite");
    80005522:	00004517          	auipc	a0,0x4
    80005526:	6b650513          	addi	a0,a0,1718 # 80009bd8 <syscalls+0x2d8>
    8000552a:	ffffb097          	auipc	ra,0xffffb
    8000552e:	000080e7          	jalr	ra # 8000052a <panic>
    return -1;
    80005532:	5a7d                	li	s4,-1
    80005534:	bfc1                	j	80005504 <filewrite+0xfa>
      return -1;
    80005536:	5a7d                	li	s4,-1
    80005538:	b7f1                	j	80005504 <filewrite+0xfa>
    8000553a:	5a7d                	li	s4,-1
    8000553c:	b7e1                	j	80005504 <filewrite+0xfa>

000000008000553e <kfileread>:

// Read from file f.
// addr is a kernel virtual address.
int
kfileread(struct file *f, uint64 addr, int n)
{
    8000553e:	7179                	addi	sp,sp,-48
    80005540:	f406                	sd	ra,40(sp)
    80005542:	f022                	sd	s0,32(sp)
    80005544:	ec26                	sd	s1,24(sp)
    80005546:	e84a                	sd	s2,16(sp)
    80005548:	e44e                	sd	s3,8(sp)
    8000554a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000554c:	00854783          	lbu	a5,8(a0)
    80005550:	c3d5                	beqz	a5,800055f4 <kfileread+0xb6>
    80005552:	84aa                	mv	s1,a0
    80005554:	89ae                	mv	s3,a1
    80005556:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005558:	411c                	lw	a5,0(a0)
    8000555a:	4705                	li	a4,1
    8000555c:	04e78963          	beq	a5,a4,800055ae <kfileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005560:	470d                	li	a4,3
    80005562:	04e78d63          	beq	a5,a4,800055bc <kfileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005566:	4709                	li	a4,2
    80005568:	06e79e63          	bne	a5,a4,800055e4 <kfileread+0xa6>
    ilock(f->ip);
    8000556c:	6d08                	ld	a0,24(a0)
    8000556e:	fffff097          	auipc	ra,0xfffff
    80005572:	aec080e7          	jalr	-1300(ra) # 8000405a <ilock>
    if((r = readi(f->ip, 0, addr, f->off, n)) > 0)
    80005576:	874a                	mv	a4,s2
    80005578:	5094                	lw	a3,32(s1)
    8000557a:	864e                	mv	a2,s3
    8000557c:	4581                	li	a1,0
    8000557e:	6c88                	ld	a0,24(s1)
    80005580:	fffff097          	auipc	ra,0xfffff
    80005584:	d8e080e7          	jalr	-626(ra) # 8000430e <readi>
    80005588:	892a                	mv	s2,a0
    8000558a:	00a05563          	blez	a0,80005594 <kfileread+0x56>
      f->off += r;
    8000558e:	509c                	lw	a5,32(s1)
    80005590:	9fa9                	addw	a5,a5,a0
    80005592:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005594:	6c88                	ld	a0,24(s1)
    80005596:	fffff097          	auipc	ra,0xfffff
    8000559a:	b86080e7          	jalr	-1146(ra) # 8000411c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000559e:	854a                	mv	a0,s2
    800055a0:	70a2                	ld	ra,40(sp)
    800055a2:	7402                	ld	s0,32(sp)
    800055a4:	64e2                	ld	s1,24(sp)
    800055a6:	6942                	ld	s2,16(sp)
    800055a8:	69a2                	ld	s3,8(sp)
    800055aa:	6145                	addi	sp,sp,48
    800055ac:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800055ae:	6908                	ld	a0,16(a0)
    800055b0:	00000097          	auipc	ra,0x0
    800055b4:	3c0080e7          	jalr	960(ra) # 80005970 <piperead>
    800055b8:	892a                	mv	s2,a0
    800055ba:	b7d5                	j	8000559e <kfileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800055bc:	02451783          	lh	a5,36(a0)
    800055c0:	03079693          	slli	a3,a5,0x30
    800055c4:	92c1                	srli	a3,a3,0x30
    800055c6:	4725                	li	a4,9
    800055c8:	02d76863          	bltu	a4,a3,800055f8 <kfileread+0xba>
    800055cc:	0792                	slli	a5,a5,0x4
    800055ce:	00029717          	auipc	a4,0x29
    800055d2:	74a70713          	addi	a4,a4,1866 # 8002ed18 <devsw>
    800055d6:	97ba                	add	a5,a5,a4
    800055d8:	639c                	ld	a5,0(a5)
    800055da:	c38d                	beqz	a5,800055fc <kfileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800055dc:	4505                	li	a0,1
    800055de:	9782                	jalr	a5
    800055e0:	892a                	mv	s2,a0
    800055e2:	bf75                	j	8000559e <kfileread+0x60>
    panic("fileread");
    800055e4:	00004517          	auipc	a0,0x4
    800055e8:	5e450513          	addi	a0,a0,1508 # 80009bc8 <syscalls+0x2c8>
    800055ec:	ffffb097          	auipc	ra,0xffffb
    800055f0:	f3e080e7          	jalr	-194(ra) # 8000052a <panic>
    return -1;
    800055f4:	597d                	li	s2,-1
    800055f6:	b765                	j	8000559e <kfileread+0x60>
      return -1;
    800055f8:	597d                	li	s2,-1
    800055fa:	b755                	j	8000559e <kfileread+0x60>
    800055fc:	597d                	li	s2,-1
    800055fe:	b745                	j	8000559e <kfileread+0x60>

0000000080005600 <kfilewrite>:

// Write to file f.
// addr is a kernel virtual address.
int
kfilewrite(struct file *f, uint64 addr, int n)
{
    80005600:	715d                	addi	sp,sp,-80
    80005602:	e486                	sd	ra,72(sp)
    80005604:	e0a2                	sd	s0,64(sp)
    80005606:	fc26                	sd	s1,56(sp)
    80005608:	f84a                	sd	s2,48(sp)
    8000560a:	f44e                	sd	s3,40(sp)
    8000560c:	f052                	sd	s4,32(sp)
    8000560e:	ec56                	sd	s5,24(sp)
    80005610:	e85a                	sd	s6,16(sp)
    80005612:	e45e                	sd	s7,8(sp)
    80005614:	e062                	sd	s8,0(sp)
    80005616:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005618:	00954783          	lbu	a5,9(a0)
    8000561c:	10078663          	beqz	a5,80005728 <kfilewrite+0x128>
    80005620:	892a                	mv	s2,a0
    80005622:	8aae                	mv	s5,a1
    80005624:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005626:	411c                	lw	a5,0(a0)
    80005628:	4705                	li	a4,1
    8000562a:	02e78263          	beq	a5,a4,8000564e <kfilewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000562e:	470d                	li	a4,3
    80005630:	02e78663          	beq	a5,a4,8000565c <kfilewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005634:	4709                	li	a4,2
    80005636:	0ee79163          	bne	a5,a4,80005718 <kfilewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000563a:	0ac05d63          	blez	a2,800056f4 <kfilewrite+0xf4>
    int i = 0;
    8000563e:	4981                	li	s3,0
    80005640:	6b05                	lui	s6,0x1
    80005642:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005646:	6b85                	lui	s7,0x1
    80005648:	c00b8b9b          	addiw	s7,s7,-1024
    8000564c:	a861                	j	800056e4 <kfilewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000564e:	6908                	ld	a0,16(a0)
    80005650:	00000097          	auipc	ra,0x0
    80005654:	22e080e7          	jalr	558(ra) # 8000587e <pipewrite>
    80005658:	8a2a                	mv	s4,a0
    8000565a:	a045                	j	800056fa <kfilewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000565c:	02451783          	lh	a5,36(a0)
    80005660:	03079693          	slli	a3,a5,0x30
    80005664:	92c1                	srli	a3,a3,0x30
    80005666:	4725                	li	a4,9
    80005668:	0cd76263          	bltu	a4,a3,8000572c <kfilewrite+0x12c>
    8000566c:	0792                	slli	a5,a5,0x4
    8000566e:	00029717          	auipc	a4,0x29
    80005672:	6aa70713          	addi	a4,a4,1706 # 8002ed18 <devsw>
    80005676:	97ba                	add	a5,a5,a4
    80005678:	679c                	ld	a5,8(a5)
    8000567a:	cbdd                	beqz	a5,80005730 <kfilewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    8000567c:	4505                	li	a0,1
    8000567e:	9782                	jalr	a5
    80005680:	8a2a                	mv	s4,a0
    80005682:	a8a5                	j	800056fa <kfilewrite+0xfa>
    80005684:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005688:	fffff097          	auipc	ra,0xfffff
    8000568c:	6ba080e7          	jalr	1722(ra) # 80004d42 <begin_op>
      ilock(f->ip);
    80005690:	01893503          	ld	a0,24(s2)
    80005694:	fffff097          	auipc	ra,0xfffff
    80005698:	9c6080e7          	jalr	-1594(ra) # 8000405a <ilock>
      if ((r = writei(f->ip, 0, addr + i, f->off, n1)) > 0)
    8000569c:	8762                	mv	a4,s8
    8000569e:	02092683          	lw	a3,32(s2)
    800056a2:	01598633          	add	a2,s3,s5
    800056a6:	4581                	li	a1,0
    800056a8:	01893503          	ld	a0,24(s2)
    800056ac:	fffff097          	auipc	ra,0xfffff
    800056b0:	d5a080e7          	jalr	-678(ra) # 80004406 <writei>
    800056b4:	84aa                	mv	s1,a0
    800056b6:	00a05763          	blez	a0,800056c4 <kfilewrite+0xc4>
        f->off += r;
    800056ba:	02092783          	lw	a5,32(s2)
    800056be:	9fa9                	addw	a5,a5,a0
    800056c0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800056c4:	01893503          	ld	a0,24(s2)
    800056c8:	fffff097          	auipc	ra,0xfffff
    800056cc:	a54080e7          	jalr	-1452(ra) # 8000411c <iunlock>
      end_op();
    800056d0:	fffff097          	auipc	ra,0xfffff
    800056d4:	6f2080e7          	jalr	1778(ra) # 80004dc2 <end_op>

      if(r != n1){
    800056d8:	009c1f63          	bne	s8,s1,800056f6 <kfilewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800056dc:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800056e0:	0149db63          	bge	s3,s4,800056f6 <kfilewrite+0xf6>
      int n1 = n - i;
    800056e4:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800056e8:	84be                	mv	s1,a5
    800056ea:	2781                	sext.w	a5,a5
    800056ec:	f8fb5ce3          	bge	s6,a5,80005684 <kfilewrite+0x84>
    800056f0:	84de                	mv	s1,s7
    800056f2:	bf49                	j	80005684 <kfilewrite+0x84>
    int i = 0;
    800056f4:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800056f6:	013a1f63          	bne	s4,s3,80005714 <kfilewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
    800056fa:	8552                	mv	a0,s4
    800056fc:	60a6                	ld	ra,72(sp)
    800056fe:	6406                	ld	s0,64(sp)
    80005700:	74e2                	ld	s1,56(sp)
    80005702:	7942                	ld	s2,48(sp)
    80005704:	79a2                	ld	s3,40(sp)
    80005706:	7a02                	ld	s4,32(sp)
    80005708:	6ae2                	ld	s5,24(sp)
    8000570a:	6b42                	ld	s6,16(sp)
    8000570c:	6ba2                	ld	s7,8(sp)
    8000570e:	6c02                	ld	s8,0(sp)
    80005710:	6161                	addi	sp,sp,80
    80005712:	8082                	ret
    ret = (i == n ? n : -1);
    80005714:	5a7d                	li	s4,-1
    80005716:	b7d5                	j	800056fa <kfilewrite+0xfa>
    panic("filewrite");
    80005718:	00004517          	auipc	a0,0x4
    8000571c:	4c050513          	addi	a0,a0,1216 # 80009bd8 <syscalls+0x2d8>
    80005720:	ffffb097          	auipc	ra,0xffffb
    80005724:	e0a080e7          	jalr	-502(ra) # 8000052a <panic>
    return -1;
    80005728:	5a7d                	li	s4,-1
    8000572a:	bfc1                	j	800056fa <kfilewrite+0xfa>
      return -1;
    8000572c:	5a7d                	li	s4,-1
    8000572e:	b7f1                	j	800056fa <kfilewrite+0xfa>
    80005730:	5a7d                	li	s4,-1
    80005732:	b7e1                	j	800056fa <kfilewrite+0xfa>

0000000080005734 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005734:	7179                	addi	sp,sp,-48
    80005736:	f406                	sd	ra,40(sp)
    80005738:	f022                	sd	s0,32(sp)
    8000573a:	ec26                	sd	s1,24(sp)
    8000573c:	e84a                	sd	s2,16(sp)
    8000573e:	e44e                	sd	s3,8(sp)
    80005740:	e052                	sd	s4,0(sp)
    80005742:	1800                	addi	s0,sp,48
    80005744:	84aa                	mv	s1,a0
    80005746:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005748:	0005b023          	sd	zero,0(a1)
    8000574c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005750:	00000097          	auipc	ra,0x0
    80005754:	a02080e7          	jalr	-1534(ra) # 80005152 <filealloc>
    80005758:	e088                	sd	a0,0(s1)
    8000575a:	c551                	beqz	a0,800057e6 <pipealloc+0xb2>
    8000575c:	00000097          	auipc	ra,0x0
    80005760:	9f6080e7          	jalr	-1546(ra) # 80005152 <filealloc>
    80005764:	00aa3023          	sd	a0,0(s4)
    80005768:	c92d                	beqz	a0,800057da <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000576a:	ffffb097          	auipc	ra,0xffffb
    8000576e:	368080e7          	jalr	872(ra) # 80000ad2 <kalloc>
    80005772:	892a                	mv	s2,a0
    80005774:	c125                	beqz	a0,800057d4 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005776:	4985                	li	s3,1
    80005778:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000577c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005780:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005784:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005788:	00004597          	auipc	a1,0x4
    8000578c:	46058593          	addi	a1,a1,1120 # 80009be8 <syscalls+0x2e8>
    80005790:	ffffb097          	auipc	ra,0xffffb
    80005794:	3a2080e7          	jalr	930(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80005798:	609c                	ld	a5,0(s1)
    8000579a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000579e:	609c                	ld	a5,0(s1)
    800057a0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800057a4:	609c                	ld	a5,0(s1)
    800057a6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800057aa:	609c                	ld	a5,0(s1)
    800057ac:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800057b0:	000a3783          	ld	a5,0(s4)
    800057b4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800057b8:	000a3783          	ld	a5,0(s4)
    800057bc:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800057c0:	000a3783          	ld	a5,0(s4)
    800057c4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800057c8:	000a3783          	ld	a5,0(s4)
    800057cc:	0127b823          	sd	s2,16(a5)
  return 0;
    800057d0:	4501                	li	a0,0
    800057d2:	a025                	j	800057fa <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800057d4:	6088                	ld	a0,0(s1)
    800057d6:	e501                	bnez	a0,800057de <pipealloc+0xaa>
    800057d8:	a039                	j	800057e6 <pipealloc+0xb2>
    800057da:	6088                	ld	a0,0(s1)
    800057dc:	c51d                	beqz	a0,8000580a <pipealloc+0xd6>
    fileclose(*f0);
    800057de:	00000097          	auipc	ra,0x0
    800057e2:	a30080e7          	jalr	-1488(ra) # 8000520e <fileclose>
  if(*f1)
    800057e6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800057ea:	557d                	li	a0,-1
  if(*f1)
    800057ec:	c799                	beqz	a5,800057fa <pipealloc+0xc6>
    fileclose(*f1);
    800057ee:	853e                	mv	a0,a5
    800057f0:	00000097          	auipc	ra,0x0
    800057f4:	a1e080e7          	jalr	-1506(ra) # 8000520e <fileclose>
  return -1;
    800057f8:	557d                	li	a0,-1
}
    800057fa:	70a2                	ld	ra,40(sp)
    800057fc:	7402                	ld	s0,32(sp)
    800057fe:	64e2                	ld	s1,24(sp)
    80005800:	6942                	ld	s2,16(sp)
    80005802:	69a2                	ld	s3,8(sp)
    80005804:	6a02                	ld	s4,0(sp)
    80005806:	6145                	addi	sp,sp,48
    80005808:	8082                	ret
  return -1;
    8000580a:	557d                	li	a0,-1
    8000580c:	b7fd                	j	800057fa <pipealloc+0xc6>

000000008000580e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000580e:	1101                	addi	sp,sp,-32
    80005810:	ec06                	sd	ra,24(sp)
    80005812:	e822                	sd	s0,16(sp)
    80005814:	e426                	sd	s1,8(sp)
    80005816:	e04a                	sd	s2,0(sp)
    80005818:	1000                	addi	s0,sp,32
    8000581a:	84aa                	mv	s1,a0
    8000581c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000581e:	ffffb097          	auipc	ra,0xffffb
    80005822:	3a4080e7          	jalr	932(ra) # 80000bc2 <acquire>
  if(writable){
    80005826:	02090d63          	beqz	s2,80005860 <pipeclose+0x52>
    pi->writeopen = 0;
    8000582a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000582e:	21848513          	addi	a0,s1,536
    80005832:	ffffd097          	auipc	ra,0xffffd
    80005836:	b86080e7          	jalr	-1146(ra) # 800023b8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000583a:	2204b783          	ld	a5,544(s1)
    8000583e:	eb95                	bnez	a5,80005872 <pipeclose+0x64>
    release(&pi->lock);
    80005840:	8526                	mv	a0,s1
    80005842:	ffffb097          	auipc	ra,0xffffb
    80005846:	434080e7          	jalr	1076(ra) # 80000c76 <release>
    kfree((char*)pi);
    8000584a:	8526                	mv	a0,s1
    8000584c:	ffffb097          	auipc	ra,0xffffb
    80005850:	18a080e7          	jalr	394(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    80005854:	60e2                	ld	ra,24(sp)
    80005856:	6442                	ld	s0,16(sp)
    80005858:	64a2                	ld	s1,8(sp)
    8000585a:	6902                	ld	s2,0(sp)
    8000585c:	6105                	addi	sp,sp,32
    8000585e:	8082                	ret
    pi->readopen = 0;
    80005860:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005864:	21c48513          	addi	a0,s1,540
    80005868:	ffffd097          	auipc	ra,0xffffd
    8000586c:	b50080e7          	jalr	-1200(ra) # 800023b8 <wakeup>
    80005870:	b7e9                	j	8000583a <pipeclose+0x2c>
    release(&pi->lock);
    80005872:	8526                	mv	a0,s1
    80005874:	ffffb097          	auipc	ra,0xffffb
    80005878:	402080e7          	jalr	1026(ra) # 80000c76 <release>
}
    8000587c:	bfe1                	j	80005854 <pipeclose+0x46>

000000008000587e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000587e:	711d                	addi	sp,sp,-96
    80005880:	ec86                	sd	ra,88(sp)
    80005882:	e8a2                	sd	s0,80(sp)
    80005884:	e4a6                	sd	s1,72(sp)
    80005886:	e0ca                	sd	s2,64(sp)
    80005888:	fc4e                	sd	s3,56(sp)
    8000588a:	f852                	sd	s4,48(sp)
    8000588c:	f456                	sd	s5,40(sp)
    8000588e:	f05a                	sd	s6,32(sp)
    80005890:	ec5e                	sd	s7,24(sp)
    80005892:	e862                	sd	s8,16(sp)
    80005894:	1080                	addi	s0,sp,96
    80005896:	84aa                	mv	s1,a0
    80005898:	8aae                	mv	s5,a1
    8000589a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000589c:	ffffc097          	auipc	ra,0xffffc
    800058a0:	498080e7          	jalr	1176(ra) # 80001d34 <myproc>
    800058a4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800058a6:	8526                	mv	a0,s1
    800058a8:	ffffb097          	auipc	ra,0xffffb
    800058ac:	31a080e7          	jalr	794(ra) # 80000bc2 <acquire>
  while(i < n){
    800058b0:	0b405363          	blez	s4,80005956 <pipewrite+0xd8>
  int i = 0;
    800058b4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800058b6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800058b8:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800058bc:	21c48b93          	addi	s7,s1,540
    800058c0:	a089                	j	80005902 <pipewrite+0x84>
      release(&pi->lock);
    800058c2:	8526                	mv	a0,s1
    800058c4:	ffffb097          	auipc	ra,0xffffb
    800058c8:	3b2080e7          	jalr	946(ra) # 80000c76 <release>
      return -1;
    800058cc:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800058ce:	854a                	mv	a0,s2
    800058d0:	60e6                	ld	ra,88(sp)
    800058d2:	6446                	ld	s0,80(sp)
    800058d4:	64a6                	ld	s1,72(sp)
    800058d6:	6906                	ld	s2,64(sp)
    800058d8:	79e2                	ld	s3,56(sp)
    800058da:	7a42                	ld	s4,48(sp)
    800058dc:	7aa2                	ld	s5,40(sp)
    800058de:	7b02                	ld	s6,32(sp)
    800058e0:	6be2                	ld	s7,24(sp)
    800058e2:	6c42                	ld	s8,16(sp)
    800058e4:	6125                	addi	sp,sp,96
    800058e6:	8082                	ret
      wakeup(&pi->nread);
    800058e8:	8562                	mv	a0,s8
    800058ea:	ffffd097          	auipc	ra,0xffffd
    800058ee:	ace080e7          	jalr	-1330(ra) # 800023b8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800058f2:	85a6                	mv	a1,s1
    800058f4:	855e                	mv	a0,s7
    800058f6:	ffffd097          	auipc	ra,0xffffd
    800058fa:	936080e7          	jalr	-1738(ra) # 8000222c <sleep>
  while(i < n){
    800058fe:	05495d63          	bge	s2,s4,80005958 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80005902:	2204a783          	lw	a5,544(s1)
    80005906:	dfd5                	beqz	a5,800058c2 <pipewrite+0x44>
    80005908:	0289a783          	lw	a5,40(s3)
    8000590c:	fbdd                	bnez	a5,800058c2 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000590e:	2184a783          	lw	a5,536(s1)
    80005912:	21c4a703          	lw	a4,540(s1)
    80005916:	2007879b          	addiw	a5,a5,512
    8000591a:	fcf707e3          	beq	a4,a5,800058e8 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000591e:	4685                	li	a3,1
    80005920:	01590633          	add	a2,s2,s5
    80005924:	faf40593          	addi	a1,s0,-81
    80005928:	0509b503          	ld	a0,80(s3)
    8000592c:	ffffc097          	auipc	ra,0xffffc
    80005930:	af4080e7          	jalr	-1292(ra) # 80001420 <copyin>
    80005934:	03650263          	beq	a0,s6,80005958 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005938:	21c4a783          	lw	a5,540(s1)
    8000593c:	0017871b          	addiw	a4,a5,1
    80005940:	20e4ae23          	sw	a4,540(s1)
    80005944:	1ff7f793          	andi	a5,a5,511
    80005948:	97a6                	add	a5,a5,s1
    8000594a:	faf44703          	lbu	a4,-81(s0)
    8000594e:	00e78c23          	sb	a4,24(a5)
      i++;
    80005952:	2905                	addiw	s2,s2,1
    80005954:	b76d                	j	800058fe <pipewrite+0x80>
  int i = 0;
    80005956:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005958:	21848513          	addi	a0,s1,536
    8000595c:	ffffd097          	auipc	ra,0xffffd
    80005960:	a5c080e7          	jalr	-1444(ra) # 800023b8 <wakeup>
  release(&pi->lock);
    80005964:	8526                	mv	a0,s1
    80005966:	ffffb097          	auipc	ra,0xffffb
    8000596a:	310080e7          	jalr	784(ra) # 80000c76 <release>
  return i;
    8000596e:	b785                	j	800058ce <pipewrite+0x50>

0000000080005970 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005970:	715d                	addi	sp,sp,-80
    80005972:	e486                	sd	ra,72(sp)
    80005974:	e0a2                	sd	s0,64(sp)
    80005976:	fc26                	sd	s1,56(sp)
    80005978:	f84a                	sd	s2,48(sp)
    8000597a:	f44e                	sd	s3,40(sp)
    8000597c:	f052                	sd	s4,32(sp)
    8000597e:	ec56                	sd	s5,24(sp)
    80005980:	e85a                	sd	s6,16(sp)
    80005982:	0880                	addi	s0,sp,80
    80005984:	84aa                	mv	s1,a0
    80005986:	892e                	mv	s2,a1
    80005988:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000598a:	ffffc097          	auipc	ra,0xffffc
    8000598e:	3aa080e7          	jalr	938(ra) # 80001d34 <myproc>
    80005992:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005994:	8526                	mv	a0,s1
    80005996:	ffffb097          	auipc	ra,0xffffb
    8000599a:	22c080e7          	jalr	556(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000599e:	2184a703          	lw	a4,536(s1)
    800059a2:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800059a6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800059aa:	02f71463          	bne	a4,a5,800059d2 <piperead+0x62>
    800059ae:	2244a783          	lw	a5,548(s1)
    800059b2:	c385                	beqz	a5,800059d2 <piperead+0x62>
    if(pr->killed){
    800059b4:	028a2783          	lw	a5,40(s4)
    800059b8:	ebc1                	bnez	a5,80005a48 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800059ba:	85a6                	mv	a1,s1
    800059bc:	854e                	mv	a0,s3
    800059be:	ffffd097          	auipc	ra,0xffffd
    800059c2:	86e080e7          	jalr	-1938(ra) # 8000222c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800059c6:	2184a703          	lw	a4,536(s1)
    800059ca:	21c4a783          	lw	a5,540(s1)
    800059ce:	fef700e3          	beq	a4,a5,800059ae <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800059d2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800059d4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800059d6:	05505363          	blez	s5,80005a1c <piperead+0xac>
    if(pi->nread == pi->nwrite)
    800059da:	2184a783          	lw	a5,536(s1)
    800059de:	21c4a703          	lw	a4,540(s1)
    800059e2:	02f70d63          	beq	a4,a5,80005a1c <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800059e6:	0017871b          	addiw	a4,a5,1
    800059ea:	20e4ac23          	sw	a4,536(s1)
    800059ee:	1ff7f793          	andi	a5,a5,511
    800059f2:	97a6                	add	a5,a5,s1
    800059f4:	0187c783          	lbu	a5,24(a5)
    800059f8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800059fc:	4685                	li	a3,1
    800059fe:	fbf40613          	addi	a2,s0,-65
    80005a02:	85ca                	mv	a1,s2
    80005a04:	050a3503          	ld	a0,80(s4)
    80005a08:	ffffc097          	auipc	ra,0xffffc
    80005a0c:	98a080e7          	jalr	-1654(ra) # 80001392 <copyout>
    80005a10:	01650663          	beq	a0,s6,80005a1c <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005a14:	2985                	addiw	s3,s3,1
    80005a16:	0905                	addi	s2,s2,1
    80005a18:	fd3a91e3          	bne	s5,s3,800059da <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005a1c:	21c48513          	addi	a0,s1,540
    80005a20:	ffffd097          	auipc	ra,0xffffd
    80005a24:	998080e7          	jalr	-1640(ra) # 800023b8 <wakeup>
  release(&pi->lock);
    80005a28:	8526                	mv	a0,s1
    80005a2a:	ffffb097          	auipc	ra,0xffffb
    80005a2e:	24c080e7          	jalr	588(ra) # 80000c76 <release>
  return i;
}
    80005a32:	854e                	mv	a0,s3
    80005a34:	60a6                	ld	ra,72(sp)
    80005a36:	6406                	ld	s0,64(sp)
    80005a38:	74e2                	ld	s1,56(sp)
    80005a3a:	7942                	ld	s2,48(sp)
    80005a3c:	79a2                	ld	s3,40(sp)
    80005a3e:	7a02                	ld	s4,32(sp)
    80005a40:	6ae2                	ld	s5,24(sp)
    80005a42:	6b42                	ld	s6,16(sp)
    80005a44:	6161                	addi	sp,sp,80
    80005a46:	8082                	ret
      release(&pi->lock);
    80005a48:	8526                	mv	a0,s1
    80005a4a:	ffffb097          	auipc	ra,0xffffb
    80005a4e:	22c080e7          	jalr	556(ra) # 80000c76 <release>
      return -1;
    80005a52:	59fd                	li	s3,-1
    80005a54:	bff9                	j	80005a32 <piperead+0xc2>

0000000080005a56 <exec>:
#include "elf.h"

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int exec(char *path, char **argv)
{
    80005a56:	de010113          	addi	sp,sp,-544
    80005a5a:	20113c23          	sd	ra,536(sp)
    80005a5e:	20813823          	sd	s0,528(sp)
    80005a62:	20913423          	sd	s1,520(sp)
    80005a66:	21213023          	sd	s2,512(sp)
    80005a6a:	ffce                	sd	s3,504(sp)
    80005a6c:	fbd2                	sd	s4,496(sp)
    80005a6e:	f7d6                	sd	s5,488(sp)
    80005a70:	f3da                	sd	s6,480(sp)
    80005a72:	efde                	sd	s7,472(sp)
    80005a74:	ebe2                	sd	s8,464(sp)
    80005a76:	e7e6                	sd	s9,456(sp)
    80005a78:	e3ea                	sd	s10,448(sp)
    80005a7a:	ff6e                	sd	s11,440(sp)
    80005a7c:	1400                	addi	s0,sp,544
    80005a7e:	892a                	mv	s2,a0
    80005a80:	dea43423          	sd	a0,-536(s0)
    80005a84:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005a88:	ffffc097          	auipc	ra,0xffffc
    80005a8c:	2ac080e7          	jalr	684(ra) # 80001d34 <myproc>
    80005a90:	84aa                	mv	s1,a0

  begin_op();
    80005a92:	fffff097          	auipc	ra,0xfffff
    80005a96:	2b0080e7          	jalr	688(ra) # 80004d42 <begin_op>

  if ((ip = namei(path)) == 0)
    80005a9a:	854a                	mv	a0,s2
    80005a9c:	fffff097          	auipc	ra,0xfffff
    80005aa0:	d74080e7          	jalr	-652(ra) # 80004810 <namei>
    80005aa4:	c93d                	beqz	a0,80005b1a <exec+0xc4>
    80005aa6:	8aaa                	mv	s5,a0
  {
    end_op();
    return -1;
  }
  ilock(ip);
    80005aa8:	ffffe097          	auipc	ra,0xffffe
    80005aac:	5b2080e7          	jalr	1458(ra) # 8000405a <ilock>

  // Check ELF header
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005ab0:	04000713          	li	a4,64
    80005ab4:	4681                	li	a3,0
    80005ab6:	e4840613          	addi	a2,s0,-440
    80005aba:	4581                	li	a1,0
    80005abc:	8556                	mv	a0,s5
    80005abe:	fffff097          	auipc	ra,0xfffff
    80005ac2:	850080e7          	jalr	-1968(ra) # 8000430e <readi>
    80005ac6:	04000793          	li	a5,64
    80005aca:	00f51a63          	bne	a0,a5,80005ade <exec+0x88>
    goto bad;
  if (elf.magic != ELF_MAGIC)
    80005ace:	e4842703          	lw	a4,-440(s0)
    80005ad2:	464c47b7          	lui	a5,0x464c4
    80005ad6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005ada:	04f70663          	beq	a4,a5,80005b26 <exec+0xd0>
bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip)
  {
    iunlockput(ip);
    80005ade:	8556                	mv	a0,s5
    80005ae0:	ffffe097          	auipc	ra,0xffffe
    80005ae4:	7dc080e7          	jalr	2012(ra) # 800042bc <iunlockput>
    end_op();
    80005ae8:	fffff097          	auipc	ra,0xfffff
    80005aec:	2da080e7          	jalr	730(ra) # 80004dc2 <end_op>
  }
  return -1;
    80005af0:	557d                	li	a0,-1
}
    80005af2:	21813083          	ld	ra,536(sp)
    80005af6:	21013403          	ld	s0,528(sp)
    80005afa:	20813483          	ld	s1,520(sp)
    80005afe:	20013903          	ld	s2,512(sp)
    80005b02:	79fe                	ld	s3,504(sp)
    80005b04:	7a5e                	ld	s4,496(sp)
    80005b06:	7abe                	ld	s5,488(sp)
    80005b08:	7b1e                	ld	s6,480(sp)
    80005b0a:	6bfe                	ld	s7,472(sp)
    80005b0c:	6c5e                	ld	s8,464(sp)
    80005b0e:	6cbe                	ld	s9,456(sp)
    80005b10:	6d1e                	ld	s10,448(sp)
    80005b12:	7dfa                	ld	s11,440(sp)
    80005b14:	22010113          	addi	sp,sp,544
    80005b18:	8082                	ret
    end_op();
    80005b1a:	fffff097          	auipc	ra,0xfffff
    80005b1e:	2a8080e7          	jalr	680(ra) # 80004dc2 <end_op>
    return -1;
    80005b22:	557d                	li	a0,-1
    80005b24:	b7f9                	j	80005af2 <exec+0x9c>
  if ((pagetable = proc_pagetable(p)) == 0)
    80005b26:	8526                	mv	a0,s1
    80005b28:	ffffc097          	auipc	ra,0xffffc
    80005b2c:	2d0080e7          	jalr	720(ra) # 80001df8 <proc_pagetable>
    80005b30:	8b2a                	mv	s6,a0
    80005b32:	d555                	beqz	a0,80005ade <exec+0x88>
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005b34:	e6842783          	lw	a5,-408(s0)
    80005b38:	e8045703          	lhu	a4,-384(s0)
    80005b3c:	c73d                	beqz	a4,80005baa <exec+0x154>
  uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
    80005b3e:	4481                	li	s1,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005b40:	e0043423          	sd	zero,-504(s0)
    if (ph.vaddr % PGSIZE != 0)
    80005b44:	6a05                	lui	s4,0x1
    80005b46:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005b4a:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if ((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for (i = 0; i < sz; i += PGSIZE)
    80005b4e:	6d85                	lui	s11,0x1
    80005b50:	7d7d                	lui	s10,0xfffff
    80005b52:	ac89                	j	80005da4 <exec+0x34e>
  {
    pa = walkaddr(pagetable, va + i, 0);
    if (pa == 0)
      panic("loadseg: address should exist");
    80005b54:	00004517          	auipc	a0,0x4
    80005b58:	09c50513          	addi	a0,a0,156 # 80009bf0 <syscalls+0x2f0>
    80005b5c:	ffffb097          	auipc	ra,0xffffb
    80005b60:	9ce080e7          	jalr	-1586(ra) # 8000052a <panic>
    if (sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80005b64:	874a                	mv	a4,s2
    80005b66:	009c86bb          	addw	a3,s9,s1
    80005b6a:	4581                	li	a1,0
    80005b6c:	8556                	mv	a0,s5
    80005b6e:	ffffe097          	auipc	ra,0xffffe
    80005b72:	7a0080e7          	jalr	1952(ra) # 8000430e <readi>
    80005b76:	2501                	sext.w	a0,a0
    80005b78:	1ca91663          	bne	s2,a0,80005d44 <exec+0x2ee>
  for (i = 0; i < sz; i += PGSIZE)
    80005b7c:	009d84bb          	addw	s1,s11,s1
    80005b80:	013d09bb          	addw	s3,s10,s3
    80005b84:	2174f063          	bgeu	s1,s7,80005d84 <exec+0x32e>
    pa = walkaddr(pagetable, va + i, 0);
    80005b88:	02049593          	slli	a1,s1,0x20
    80005b8c:	9181                	srli	a1,a1,0x20
    80005b8e:	4601                	li	a2,0
    80005b90:	95e2                	add	a1,a1,s8
    80005b92:	855a                	mv	a0,s6
    80005b94:	ffffb097          	auipc	ra,0xffffb
    80005b98:	4b8080e7          	jalr	1208(ra) # 8000104c <walkaddr>
    80005b9c:	862a                	mv	a2,a0
    if (pa == 0)
    80005b9e:	d95d                	beqz	a0,80005b54 <exec+0xfe>
      n = PGSIZE;
    80005ba0:	8952                	mv	s2,s4
    if (sz - i < PGSIZE)
    80005ba2:	fd49f1e3          	bgeu	s3,s4,80005b64 <exec+0x10e>
      n = sz - i;
    80005ba6:	894e                	mv	s2,s3
    80005ba8:	bf75                	j	80005b64 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
    80005baa:	4481                	li	s1,0
  iunlockput(ip);
    80005bac:	8556                	mv	a0,s5
    80005bae:	ffffe097          	auipc	ra,0xffffe
    80005bb2:	70e080e7          	jalr	1806(ra) # 800042bc <iunlockput>
  end_op();
    80005bb6:	fffff097          	auipc	ra,0xfffff
    80005bba:	20c080e7          	jalr	524(ra) # 80004dc2 <end_op>
  p = myproc();
    80005bbe:	ffffc097          	auipc	ra,0xffffc
    80005bc2:	176080e7          	jalr	374(ra) # 80001d34 <myproc>
    80005bc6:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005bc8:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005bcc:	6785                	lui	a5,0x1
    80005bce:	17fd                	addi	a5,a5,-1
    80005bd0:	94be                	add	s1,s1,a5
    80005bd2:	77fd                	lui	a5,0xfffff
    80005bd4:	8fe5                	and	a5,a5,s1
    80005bd6:	def43c23          	sd	a5,-520(s0)
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE)) == 0)
    80005bda:	6609                	lui	a2,0x2
    80005bdc:	963e                	add	a2,a2,a5
    80005bde:	85be                	mv	a1,a5
    80005be0:	855a                	mv	a0,s6
    80005be2:	ffffc097          	auipc	ra,0xffffc
    80005be6:	d20080e7          	jalr	-736(ra) # 80001902 <uvmalloc>
    80005bea:	8c2a                	mv	s8,a0
  ip = 0;
    80005bec:	4a81                	li	s5,0
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE)) == 0)
    80005bee:	14050b63          	beqz	a0,80005d44 <exec+0x2ee>
  uvmclear(pagetable, sz - 2 * PGSIZE);
    80005bf2:	75f9                	lui	a1,0xffffe
    80005bf4:	95aa                	add	a1,a1,a0
    80005bf6:	855a                	mv	a0,s6
    80005bf8:	ffffb097          	auipc	ra,0xffffb
    80005bfc:	768080e7          	jalr	1896(ra) # 80001360 <uvmclear>
  stackbase = sp - PGSIZE;
    80005c00:	7afd                	lui	s5,0xfffff
    80005c02:	9ae2                	add	s5,s5,s8
  for (argc = 0; argv[argc]; argc++)
    80005c04:	df043783          	ld	a5,-528(s0)
    80005c08:	6388                	ld	a0,0(a5)
    80005c0a:	c925                	beqz	a0,80005c7a <exec+0x224>
    80005c0c:	e8840993          	addi	s3,s0,-376
    80005c10:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005c14:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    80005c16:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005c18:	ffffb097          	auipc	ra,0xffffb
    80005c1c:	22a080e7          	jalr	554(ra) # 80000e42 <strlen>
    80005c20:	0015079b          	addiw	a5,a0,1
    80005c24:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005c28:	ff097913          	andi	s2,s2,-16
    if (sp < stackbase)
    80005c2c:	15596063          	bltu	s2,s5,80005d6c <exec+0x316>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005c30:	df043d83          	ld	s11,-528(s0)
    80005c34:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005c38:	8552                	mv	a0,s4
    80005c3a:	ffffb097          	auipc	ra,0xffffb
    80005c3e:	208080e7          	jalr	520(ra) # 80000e42 <strlen>
    80005c42:	0015069b          	addiw	a3,a0,1
    80005c46:	8652                	mv	a2,s4
    80005c48:	85ca                	mv	a1,s2
    80005c4a:	855a                	mv	a0,s6
    80005c4c:	ffffb097          	auipc	ra,0xffffb
    80005c50:	746080e7          	jalr	1862(ra) # 80001392 <copyout>
    80005c54:	12054063          	bltz	a0,80005d74 <exec+0x31e>
    ustack[argc] = sp;
    80005c58:	0129b023          	sd	s2,0(s3)
  for (argc = 0; argv[argc]; argc++)
    80005c5c:	0485                	addi	s1,s1,1
    80005c5e:	008d8793          	addi	a5,s11,8
    80005c62:	def43823          	sd	a5,-528(s0)
    80005c66:	008db503          	ld	a0,8(s11)
    80005c6a:	c911                	beqz	a0,80005c7e <exec+0x228>
    if (argc >= MAXARG)
    80005c6c:	09a1                	addi	s3,s3,8
    80005c6e:	fb3c95e3          	bne	s9,s3,80005c18 <exec+0x1c2>
  sz = sz1;
    80005c72:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005c76:	4a81                	li	s5,0
    80005c78:	a0f1                	j	80005d44 <exec+0x2ee>
  sp = sz;
    80005c7a:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    80005c7c:	4481                	li	s1,0
  ustack[argc] = 0;
    80005c7e:	00349793          	slli	a5,s1,0x3
    80005c82:	f9040713          	addi	a4,s0,-112
    80005c86:	97ba                	add	a5,a5,a4
    80005c88:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffcbef8>
  sp -= (argc + 1) * sizeof(uint64);
    80005c8c:	00148693          	addi	a3,s1,1
    80005c90:	068e                	slli	a3,a3,0x3
    80005c92:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005c96:	ff097913          	andi	s2,s2,-16
  if (sp < stackbase)
    80005c9a:	01597663          	bgeu	s2,s5,80005ca6 <exec+0x250>
  sz = sz1;
    80005c9e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005ca2:	4a81                	li	s5,0
    80005ca4:	a045                	j	80005d44 <exec+0x2ee>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    80005ca6:	e8840613          	addi	a2,s0,-376
    80005caa:	85ca                	mv	a1,s2
    80005cac:	855a                	mv	a0,s6
    80005cae:	ffffb097          	auipc	ra,0xffffb
    80005cb2:	6e4080e7          	jalr	1764(ra) # 80001392 <copyout>
    80005cb6:	0c054363          	bltz	a0,80005d7c <exec+0x326>
  p->trapframe->a1 = sp;
    80005cba:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80005cbe:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    80005cc2:	de843783          	ld	a5,-536(s0)
    80005cc6:	0007c703          	lbu	a4,0(a5)
    80005cca:	cf11                	beqz	a4,80005ce6 <exec+0x290>
    80005ccc:	0785                	addi	a5,a5,1
    if (*s == '/')
    80005cce:	02f00693          	li	a3,47
    80005cd2:	a039                	j	80005ce0 <exec+0x28a>
      last = s + 1;
    80005cd4:	def43423          	sd	a5,-536(s0)
  for (last = s = path; *s; s++)
    80005cd8:	0785                	addi	a5,a5,1
    80005cda:	fff7c703          	lbu	a4,-1(a5)
    80005cde:	c701                	beqz	a4,80005ce6 <exec+0x290>
    if (*s == '/')
    80005ce0:	fed71ce3          	bne	a4,a3,80005cd8 <exec+0x282>
    80005ce4:	bfc5                	j	80005cd4 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005ce6:	4641                	li	a2,16
    80005ce8:	de843583          	ld	a1,-536(s0)
    80005cec:	158b8513          	addi	a0,s7,344
    80005cf0:	ffffb097          	auipc	ra,0xffffb
    80005cf4:	120080e7          	jalr	288(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005cf8:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005cfc:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005d00:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry; // initial program counter = main
    80005d04:	058bb783          	ld	a5,88(s7)
    80005d08:	e6043703          	ld	a4,-416(s0)
    80005d0c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80005d0e:	058bb783          	ld	a5,88(s7)
    80005d12:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz); // also remove swapfile
    80005d16:	85ea                	mv	a1,s10
    80005d18:	ffffc097          	auipc	ra,0xffffc
    80005d1c:	17c080e7          	jalr	380(ra) # 80001e94 <proc_freepagetable>
  if(p->pid >2){
    80005d20:	030ba703          	lw	a4,48(s7)
    80005d24:	4789                	li	a5,2
    80005d26:	00e7da63          	bge	a5,a4,80005d3a <exec+0x2e4>
    p->physical_pages_num = 0;
    80005d2a:	160ba823          	sw	zero,368(s7)
    p->total_pages_num = 0;
    80005d2e:	160baa23          	sw	zero,372(s7)
    p->pages_physc_info.free_spaces = 0;
    80005d32:	300b9023          	sh	zero,768(s7)
    p->pages_swap_info.free_spaces = 0;
    80005d36:	160b9c23          	sh	zero,376(s7)
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005d3a:	0004851b          	sext.w	a0,s1
    80005d3e:	bb55                	j	80005af2 <exec+0x9c>
    80005d40:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005d44:	df843583          	ld	a1,-520(s0)
    80005d48:	855a                	mv	a0,s6
    80005d4a:	ffffc097          	auipc	ra,0xffffc
    80005d4e:	14a080e7          	jalr	330(ra) # 80001e94 <proc_freepagetable>
  if (ip)
    80005d52:	d80a96e3          	bnez	s5,80005ade <exec+0x88>
  return -1;
    80005d56:	557d                	li	a0,-1
    80005d58:	bb69                	j	80005af2 <exec+0x9c>
    80005d5a:	de943c23          	sd	s1,-520(s0)
    80005d5e:	b7dd                	j	80005d44 <exec+0x2ee>
    80005d60:	de943c23          	sd	s1,-520(s0)
    80005d64:	b7c5                	j	80005d44 <exec+0x2ee>
    80005d66:	de943c23          	sd	s1,-520(s0)
    80005d6a:	bfe9                	j	80005d44 <exec+0x2ee>
  sz = sz1;
    80005d6c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005d70:	4a81                	li	s5,0
    80005d72:	bfc9                	j	80005d44 <exec+0x2ee>
  sz = sz1;
    80005d74:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005d78:	4a81                	li	s5,0
    80005d7a:	b7e9                	j	80005d44 <exec+0x2ee>
  sz = sz1;
    80005d7c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005d80:	4a81                	li	s5,0
    80005d82:	b7c9                	j	80005d44 <exec+0x2ee>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005d84:	df843483          	ld	s1,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005d88:	e0843783          	ld	a5,-504(s0)
    80005d8c:	0017869b          	addiw	a3,a5,1
    80005d90:	e0d43423          	sd	a3,-504(s0)
    80005d94:	e0043783          	ld	a5,-512(s0)
    80005d98:	0387879b          	addiw	a5,a5,56
    80005d9c:	e8045703          	lhu	a4,-384(s0)
    80005da0:	e0e6d6e3          	bge	a3,a4,80005bac <exec+0x156>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005da4:	2781                	sext.w	a5,a5
    80005da6:	e0f43023          	sd	a5,-512(s0)
    80005daa:	03800713          	li	a4,56
    80005dae:	86be                	mv	a3,a5
    80005db0:	e1040613          	addi	a2,s0,-496
    80005db4:	4581                	li	a1,0
    80005db6:	8556                	mv	a0,s5
    80005db8:	ffffe097          	auipc	ra,0xffffe
    80005dbc:	556080e7          	jalr	1366(ra) # 8000430e <readi>
    80005dc0:	03800793          	li	a5,56
    80005dc4:	f6f51ee3          	bne	a0,a5,80005d40 <exec+0x2ea>
    if (ph.type != ELF_PROG_LOAD)
    80005dc8:	e1042783          	lw	a5,-496(s0)
    80005dcc:	4705                	li	a4,1
    80005dce:	fae79de3          	bne	a5,a4,80005d88 <exec+0x332>
    if (ph.memsz < ph.filesz)
    80005dd2:	e3843603          	ld	a2,-456(s0)
    80005dd6:	e3043783          	ld	a5,-464(s0)
    80005dda:	f8f660e3          	bltu	a2,a5,80005d5a <exec+0x304>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80005dde:	e2043783          	ld	a5,-480(s0)
    80005de2:	963e                	add	a2,a2,a5
    80005de4:	f6f66ee3          	bltu	a2,a5,80005d60 <exec+0x30a>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005de8:	85a6                	mv	a1,s1
    80005dea:	855a                	mv	a0,s6
    80005dec:	ffffc097          	auipc	ra,0xffffc
    80005df0:	b16080e7          	jalr	-1258(ra) # 80001902 <uvmalloc>
    80005df4:	dea43c23          	sd	a0,-520(s0)
    80005df8:	d53d                	beqz	a0,80005d66 <exec+0x310>
    if (ph.vaddr % PGSIZE != 0)
    80005dfa:	e2043c03          	ld	s8,-480(s0)
    80005dfe:	de043783          	ld	a5,-544(s0)
    80005e02:	00fc77b3          	and	a5,s8,a5
    80005e06:	ff9d                	bnez	a5,80005d44 <exec+0x2ee>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005e08:	e1842c83          	lw	s9,-488(s0)
    80005e0c:	e3042b83          	lw	s7,-464(s0)
  for (i = 0; i < sz; i += PGSIZE)
    80005e10:	f60b8ae3          	beqz	s7,80005d84 <exec+0x32e>
    80005e14:	89de                	mv	s3,s7
    80005e16:	4481                	li	s1,0
    80005e18:	bb85                	j	80005b88 <exec+0x132>

0000000080005e1a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005e1a:	7179                	addi	sp,sp,-48
    80005e1c:	f406                	sd	ra,40(sp)
    80005e1e:	f022                	sd	s0,32(sp)
    80005e20:	ec26                	sd	s1,24(sp)
    80005e22:	e84a                	sd	s2,16(sp)
    80005e24:	1800                	addi	s0,sp,48
    80005e26:	892e                	mv	s2,a1
    80005e28:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005e2a:	fdc40593          	addi	a1,s0,-36
    80005e2e:	ffffd097          	auipc	ra,0xffffd
    80005e32:	6ba080e7          	jalr	1722(ra) # 800034e8 <argint>
    80005e36:	04054063          	bltz	a0,80005e76 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005e3a:	fdc42703          	lw	a4,-36(s0)
    80005e3e:	47bd                	li	a5,15
    80005e40:	02e7ed63          	bltu	a5,a4,80005e7a <argfd+0x60>
    80005e44:	ffffc097          	auipc	ra,0xffffc
    80005e48:	ef0080e7          	jalr	-272(ra) # 80001d34 <myproc>
    80005e4c:	fdc42703          	lw	a4,-36(s0)
    80005e50:	01a70793          	addi	a5,a4,26
    80005e54:	078e                	slli	a5,a5,0x3
    80005e56:	953e                	add	a0,a0,a5
    80005e58:	611c                	ld	a5,0(a0)
    80005e5a:	c395                	beqz	a5,80005e7e <argfd+0x64>
    return -1;
  if(pfd)
    80005e5c:	00090463          	beqz	s2,80005e64 <argfd+0x4a>
    *pfd = fd;
    80005e60:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005e64:	4501                	li	a0,0
  if(pf)
    80005e66:	c091                	beqz	s1,80005e6a <argfd+0x50>
    *pf = f;
    80005e68:	e09c                	sd	a5,0(s1)
}
    80005e6a:	70a2                	ld	ra,40(sp)
    80005e6c:	7402                	ld	s0,32(sp)
    80005e6e:	64e2                	ld	s1,24(sp)
    80005e70:	6942                	ld	s2,16(sp)
    80005e72:	6145                	addi	sp,sp,48
    80005e74:	8082                	ret
    return -1;
    80005e76:	557d                	li	a0,-1
    80005e78:	bfcd                	j	80005e6a <argfd+0x50>
    return -1;
    80005e7a:	557d                	li	a0,-1
    80005e7c:	b7fd                	j	80005e6a <argfd+0x50>
    80005e7e:	557d                	li	a0,-1
    80005e80:	b7ed                	j	80005e6a <argfd+0x50>

0000000080005e82 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005e82:	1101                	addi	sp,sp,-32
    80005e84:	ec06                	sd	ra,24(sp)
    80005e86:	e822                	sd	s0,16(sp)
    80005e88:	e426                	sd	s1,8(sp)
    80005e8a:	1000                	addi	s0,sp,32
    80005e8c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005e8e:	ffffc097          	auipc	ra,0xffffc
    80005e92:	ea6080e7          	jalr	-346(ra) # 80001d34 <myproc>
    80005e96:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005e98:	0d050793          	addi	a5,a0,208
    80005e9c:	4501                	li	a0,0
    80005e9e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005ea0:	6398                	ld	a4,0(a5)
    80005ea2:	cb19                	beqz	a4,80005eb8 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005ea4:	2505                	addiw	a0,a0,1
    80005ea6:	07a1                	addi	a5,a5,8
    80005ea8:	fed51ce3          	bne	a0,a3,80005ea0 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005eac:	557d                	li	a0,-1
}
    80005eae:	60e2                	ld	ra,24(sp)
    80005eb0:	6442                	ld	s0,16(sp)
    80005eb2:	64a2                	ld	s1,8(sp)
    80005eb4:	6105                	addi	sp,sp,32
    80005eb6:	8082                	ret
      p->ofile[fd] = f;
    80005eb8:	01a50793          	addi	a5,a0,26
    80005ebc:	078e                	slli	a5,a5,0x3
    80005ebe:	963e                	add	a2,a2,a5
    80005ec0:	e204                	sd	s1,0(a2)
      return fd;
    80005ec2:	b7f5                	j	80005eae <fdalloc+0x2c>

0000000080005ec4 <sys_dup>:

uint64
sys_dup(void)
{
    80005ec4:	7179                	addi	sp,sp,-48
    80005ec6:	f406                	sd	ra,40(sp)
    80005ec8:	f022                	sd	s0,32(sp)
    80005eca:	ec26                	sd	s1,24(sp)
    80005ecc:	1800                	addi	s0,sp,48
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    80005ece:	fd840613          	addi	a2,s0,-40
    80005ed2:	4581                	li	a1,0
    80005ed4:	4501                	li	a0,0
    80005ed6:	00000097          	auipc	ra,0x0
    80005eda:	f44080e7          	jalr	-188(ra) # 80005e1a <argfd>
    return -1;
    80005ede:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005ee0:	02054363          	bltz	a0,80005f06 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005ee4:	fd843503          	ld	a0,-40(s0)
    80005ee8:	00000097          	auipc	ra,0x0
    80005eec:	f9a080e7          	jalr	-102(ra) # 80005e82 <fdalloc>
    80005ef0:	84aa                	mv	s1,a0
    return -1;
    80005ef2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005ef4:	00054963          	bltz	a0,80005f06 <sys_dup+0x42>
  filedup(f);
    80005ef8:	fd843503          	ld	a0,-40(s0)
    80005efc:	fffff097          	auipc	ra,0xfffff
    80005f00:	2c0080e7          	jalr	704(ra) # 800051bc <filedup>
  return fd;
    80005f04:	87a6                	mv	a5,s1
}
    80005f06:	853e                	mv	a0,a5
    80005f08:	70a2                	ld	ra,40(sp)
    80005f0a:	7402                	ld	s0,32(sp)
    80005f0c:	64e2                	ld	s1,24(sp)
    80005f0e:	6145                	addi	sp,sp,48
    80005f10:	8082                	ret

0000000080005f12 <sys_read>:

uint64
sys_read(void)
{
    80005f12:	7179                	addi	sp,sp,-48
    80005f14:	f406                	sd	ra,40(sp)
    80005f16:	f022                	sd	s0,32(sp)
    80005f18:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f1a:	fe840613          	addi	a2,s0,-24
    80005f1e:	4581                	li	a1,0
    80005f20:	4501                	li	a0,0
    80005f22:	00000097          	auipc	ra,0x0
    80005f26:	ef8080e7          	jalr	-264(ra) # 80005e1a <argfd>
    return -1;
    80005f2a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f2c:	04054163          	bltz	a0,80005f6e <sys_read+0x5c>
    80005f30:	fe440593          	addi	a1,s0,-28
    80005f34:	4509                	li	a0,2
    80005f36:	ffffd097          	auipc	ra,0xffffd
    80005f3a:	5b2080e7          	jalr	1458(ra) # 800034e8 <argint>
    return -1;
    80005f3e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f40:	02054763          	bltz	a0,80005f6e <sys_read+0x5c>
    80005f44:	fd840593          	addi	a1,s0,-40
    80005f48:	4505                	li	a0,1
    80005f4a:	ffffd097          	auipc	ra,0xffffd
    80005f4e:	5c0080e7          	jalr	1472(ra) # 8000350a <argaddr>
    return -1;
    80005f52:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f54:	00054d63          	bltz	a0,80005f6e <sys_read+0x5c>
  return fileread(f, p, n);
    80005f58:	fe442603          	lw	a2,-28(s0)
    80005f5c:	fd843583          	ld	a1,-40(s0)
    80005f60:	fe843503          	ld	a0,-24(s0)
    80005f64:	fffff097          	auipc	ra,0xfffff
    80005f68:	3e4080e7          	jalr	996(ra) # 80005348 <fileread>
    80005f6c:	87aa                	mv	a5,a0
}
    80005f6e:	853e                	mv	a0,a5
    80005f70:	70a2                	ld	ra,40(sp)
    80005f72:	7402                	ld	s0,32(sp)
    80005f74:	6145                	addi	sp,sp,48
    80005f76:	8082                	ret

0000000080005f78 <sys_write>:

uint64
sys_write(void)
{
    80005f78:	7179                	addi	sp,sp,-48
    80005f7a:	f406                	sd	ra,40(sp)
    80005f7c:	f022                	sd	s0,32(sp)
    80005f7e:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f80:	fe840613          	addi	a2,s0,-24
    80005f84:	4581                	li	a1,0
    80005f86:	4501                	li	a0,0
    80005f88:	00000097          	auipc	ra,0x0
    80005f8c:	e92080e7          	jalr	-366(ra) # 80005e1a <argfd>
    return -1;
    80005f90:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f92:	04054163          	bltz	a0,80005fd4 <sys_write+0x5c>
    80005f96:	fe440593          	addi	a1,s0,-28
    80005f9a:	4509                	li	a0,2
    80005f9c:	ffffd097          	auipc	ra,0xffffd
    80005fa0:	54c080e7          	jalr	1356(ra) # 800034e8 <argint>
    return -1;
    80005fa4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005fa6:	02054763          	bltz	a0,80005fd4 <sys_write+0x5c>
    80005faa:	fd840593          	addi	a1,s0,-40
    80005fae:	4505                	li	a0,1
    80005fb0:	ffffd097          	auipc	ra,0xffffd
    80005fb4:	55a080e7          	jalr	1370(ra) # 8000350a <argaddr>
    return -1;
    80005fb8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005fba:	00054d63          	bltz	a0,80005fd4 <sys_write+0x5c>

  return filewrite(f, p, n);
    80005fbe:	fe442603          	lw	a2,-28(s0)
    80005fc2:	fd843583          	ld	a1,-40(s0)
    80005fc6:	fe843503          	ld	a0,-24(s0)
    80005fca:	fffff097          	auipc	ra,0xfffff
    80005fce:	440080e7          	jalr	1088(ra) # 8000540a <filewrite>
    80005fd2:	87aa                	mv	a5,a0
}
    80005fd4:	853e                	mv	a0,a5
    80005fd6:	70a2                	ld	ra,40(sp)
    80005fd8:	7402                	ld	s0,32(sp)
    80005fda:	6145                	addi	sp,sp,48
    80005fdc:	8082                	ret

0000000080005fde <sys_close>:

uint64
sys_close(void)
{
    80005fde:	1101                	addi	sp,sp,-32
    80005fe0:	ec06                	sd	ra,24(sp)
    80005fe2:	e822                	sd	s0,16(sp)
    80005fe4:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    80005fe6:	fe040613          	addi	a2,s0,-32
    80005fea:	fec40593          	addi	a1,s0,-20
    80005fee:	4501                	li	a0,0
    80005ff0:	00000097          	auipc	ra,0x0
    80005ff4:	e2a080e7          	jalr	-470(ra) # 80005e1a <argfd>
    return -1;
    80005ff8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005ffa:	02054463          	bltz	a0,80006022 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005ffe:	ffffc097          	auipc	ra,0xffffc
    80006002:	d36080e7          	jalr	-714(ra) # 80001d34 <myproc>
    80006006:	fec42783          	lw	a5,-20(s0)
    8000600a:	07e9                	addi	a5,a5,26
    8000600c:	078e                	slli	a5,a5,0x3
    8000600e:	97aa                	add	a5,a5,a0
    80006010:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80006014:	fe043503          	ld	a0,-32(s0)
    80006018:	fffff097          	auipc	ra,0xfffff
    8000601c:	1f6080e7          	jalr	502(ra) # 8000520e <fileclose>
  return 0;
    80006020:	4781                	li	a5,0
}
    80006022:	853e                	mv	a0,a5
    80006024:	60e2                	ld	ra,24(sp)
    80006026:	6442                	ld	s0,16(sp)
    80006028:	6105                	addi	sp,sp,32
    8000602a:	8082                	ret

000000008000602c <sys_fstat>:

uint64
sys_fstat(void)
{
    8000602c:	1101                	addi	sp,sp,-32
    8000602e:	ec06                	sd	ra,24(sp)
    80006030:	e822                	sd	s0,16(sp)
    80006032:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006034:	fe840613          	addi	a2,s0,-24
    80006038:	4581                	li	a1,0
    8000603a:	4501                	li	a0,0
    8000603c:	00000097          	auipc	ra,0x0
    80006040:	dde080e7          	jalr	-546(ra) # 80005e1a <argfd>
    return -1;
    80006044:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006046:	02054563          	bltz	a0,80006070 <sys_fstat+0x44>
    8000604a:	fe040593          	addi	a1,s0,-32
    8000604e:	4505                	li	a0,1
    80006050:	ffffd097          	auipc	ra,0xffffd
    80006054:	4ba080e7          	jalr	1210(ra) # 8000350a <argaddr>
    return -1;
    80006058:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000605a:	00054b63          	bltz	a0,80006070 <sys_fstat+0x44>
  return filestat(f, st);
    8000605e:	fe043583          	ld	a1,-32(s0)
    80006062:	fe843503          	ld	a0,-24(s0)
    80006066:	fffff097          	auipc	ra,0xfffff
    8000606a:	270080e7          	jalr	624(ra) # 800052d6 <filestat>
    8000606e:	87aa                	mv	a5,a0
}
    80006070:	853e                	mv	a0,a5
    80006072:	60e2                	ld	ra,24(sp)
    80006074:	6442                	ld	s0,16(sp)
    80006076:	6105                	addi	sp,sp,32
    80006078:	8082                	ret

000000008000607a <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    8000607a:	7169                	addi	sp,sp,-304
    8000607c:	f606                	sd	ra,296(sp)
    8000607e:	f222                	sd	s0,288(sp)
    80006080:	ee26                	sd	s1,280(sp)
    80006082:	ea4a                	sd	s2,272(sp)
    80006084:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006086:	08000613          	li	a2,128
    8000608a:	ed040593          	addi	a1,s0,-304
    8000608e:	4501                	li	a0,0
    80006090:	ffffd097          	auipc	ra,0xffffd
    80006094:	49c080e7          	jalr	1180(ra) # 8000352c <argstr>
    return -1;
    80006098:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000609a:	10054e63          	bltz	a0,800061b6 <sys_link+0x13c>
    8000609e:	08000613          	li	a2,128
    800060a2:	f5040593          	addi	a1,s0,-176
    800060a6:	4505                	li	a0,1
    800060a8:	ffffd097          	auipc	ra,0xffffd
    800060ac:	484080e7          	jalr	1156(ra) # 8000352c <argstr>
    return -1;
    800060b0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800060b2:	10054263          	bltz	a0,800061b6 <sys_link+0x13c>

  begin_op();
    800060b6:	fffff097          	auipc	ra,0xfffff
    800060ba:	c8c080e7          	jalr	-884(ra) # 80004d42 <begin_op>
  if((ip = namei(old)) == 0){
    800060be:	ed040513          	addi	a0,s0,-304
    800060c2:	ffffe097          	auipc	ra,0xffffe
    800060c6:	74e080e7          	jalr	1870(ra) # 80004810 <namei>
    800060ca:	84aa                	mv	s1,a0
    800060cc:	c551                	beqz	a0,80006158 <sys_link+0xde>
    end_op();
    return -1;
  }

  ilock(ip);
    800060ce:	ffffe097          	auipc	ra,0xffffe
    800060d2:	f8c080e7          	jalr	-116(ra) # 8000405a <ilock>
  if(ip->type == T_DIR){
    800060d6:	04449703          	lh	a4,68(s1)
    800060da:	4785                	li	a5,1
    800060dc:	08f70463          	beq	a4,a5,80006164 <sys_link+0xea>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
    800060e0:	04a4d783          	lhu	a5,74(s1)
    800060e4:	2785                	addiw	a5,a5,1
    800060e6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800060ea:	8526                	mv	a0,s1
    800060ec:	ffffe097          	auipc	ra,0xffffe
    800060f0:	ea4080e7          	jalr	-348(ra) # 80003f90 <iupdate>
  iunlock(ip);
    800060f4:	8526                	mv	a0,s1
    800060f6:	ffffe097          	auipc	ra,0xffffe
    800060fa:	026080e7          	jalr	38(ra) # 8000411c <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    800060fe:	fd040593          	addi	a1,s0,-48
    80006102:	f5040513          	addi	a0,s0,-176
    80006106:	ffffe097          	auipc	ra,0xffffe
    8000610a:	728080e7          	jalr	1832(ra) # 8000482e <nameiparent>
    8000610e:	892a                	mv	s2,a0
    80006110:	c935                	beqz	a0,80006184 <sys_link+0x10a>
    goto bad;
  ilock(dp);
    80006112:	ffffe097          	auipc	ra,0xffffe
    80006116:	f48080e7          	jalr	-184(ra) # 8000405a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000611a:	00092703          	lw	a4,0(s2)
    8000611e:	409c                	lw	a5,0(s1)
    80006120:	04f71d63          	bne	a4,a5,8000617a <sys_link+0x100>
    80006124:	40d0                	lw	a2,4(s1)
    80006126:	fd040593          	addi	a1,s0,-48
    8000612a:	854a                	mv	a0,s2
    8000612c:	ffffe097          	auipc	ra,0xffffe
    80006130:	622080e7          	jalr	1570(ra) # 8000474e <dirlink>
    80006134:	04054363          	bltz	a0,8000617a <sys_link+0x100>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
    80006138:	854a                	mv	a0,s2
    8000613a:	ffffe097          	auipc	ra,0xffffe
    8000613e:	182080e7          	jalr	386(ra) # 800042bc <iunlockput>
  iput(ip);
    80006142:	8526                	mv	a0,s1
    80006144:	ffffe097          	auipc	ra,0xffffe
    80006148:	0d0080e7          	jalr	208(ra) # 80004214 <iput>

  end_op();
    8000614c:	fffff097          	auipc	ra,0xfffff
    80006150:	c76080e7          	jalr	-906(ra) # 80004dc2 <end_op>

  return 0;
    80006154:	4781                	li	a5,0
    80006156:	a085                	j	800061b6 <sys_link+0x13c>
    end_op();
    80006158:	fffff097          	auipc	ra,0xfffff
    8000615c:	c6a080e7          	jalr	-918(ra) # 80004dc2 <end_op>
    return -1;
    80006160:	57fd                	li	a5,-1
    80006162:	a891                	j	800061b6 <sys_link+0x13c>
    iunlockput(ip);
    80006164:	8526                	mv	a0,s1
    80006166:	ffffe097          	auipc	ra,0xffffe
    8000616a:	156080e7          	jalr	342(ra) # 800042bc <iunlockput>
    end_op();
    8000616e:	fffff097          	auipc	ra,0xfffff
    80006172:	c54080e7          	jalr	-940(ra) # 80004dc2 <end_op>
    return -1;
    80006176:	57fd                	li	a5,-1
    80006178:	a83d                	j	800061b6 <sys_link+0x13c>
    iunlockput(dp);
    8000617a:	854a                	mv	a0,s2
    8000617c:	ffffe097          	auipc	ra,0xffffe
    80006180:	140080e7          	jalr	320(ra) # 800042bc <iunlockput>

bad:
  ilock(ip);
    80006184:	8526                	mv	a0,s1
    80006186:	ffffe097          	auipc	ra,0xffffe
    8000618a:	ed4080e7          	jalr	-300(ra) # 8000405a <ilock>
  ip->nlink--;
    8000618e:	04a4d783          	lhu	a5,74(s1)
    80006192:	37fd                	addiw	a5,a5,-1
    80006194:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006198:	8526                	mv	a0,s1
    8000619a:	ffffe097          	auipc	ra,0xffffe
    8000619e:	df6080e7          	jalr	-522(ra) # 80003f90 <iupdate>
  iunlockput(ip);
    800061a2:	8526                	mv	a0,s1
    800061a4:	ffffe097          	auipc	ra,0xffffe
    800061a8:	118080e7          	jalr	280(ra) # 800042bc <iunlockput>
  end_op();
    800061ac:	fffff097          	auipc	ra,0xfffff
    800061b0:	c16080e7          	jalr	-1002(ra) # 80004dc2 <end_op>
  return -1;
    800061b4:	57fd                	li	a5,-1
}
    800061b6:	853e                	mv	a0,a5
    800061b8:	70b2                	ld	ra,296(sp)
    800061ba:	7412                	ld	s0,288(sp)
    800061bc:	64f2                	ld	s1,280(sp)
    800061be:	6952                	ld	s2,272(sp)
    800061c0:	6155                	addi	sp,sp,304
    800061c2:	8082                	ret

00000000800061c4 <isdirempty>:
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800061c4:	4578                	lw	a4,76(a0)
    800061c6:	02000793          	li	a5,32
    800061ca:	04e7fa63          	bgeu	a5,a4,8000621e <isdirempty+0x5a>
{
    800061ce:	7179                	addi	sp,sp,-48
    800061d0:	f406                	sd	ra,40(sp)
    800061d2:	f022                	sd	s0,32(sp)
    800061d4:	ec26                	sd	s1,24(sp)
    800061d6:	e84a                	sd	s2,16(sp)
    800061d8:	1800                	addi	s0,sp,48
    800061da:	892a                	mv	s2,a0
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800061dc:	02000493          	li	s1,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800061e0:	4741                	li	a4,16
    800061e2:	86a6                	mv	a3,s1
    800061e4:	fd040613          	addi	a2,s0,-48
    800061e8:	4581                	li	a1,0
    800061ea:	854a                	mv	a0,s2
    800061ec:	ffffe097          	auipc	ra,0xffffe
    800061f0:	122080e7          	jalr	290(ra) # 8000430e <readi>
    800061f4:	47c1                	li	a5,16
    800061f6:	00f51c63          	bne	a0,a5,8000620e <isdirempty+0x4a>
      panic("isdirempty: readi");
    if(de.inum != 0)
    800061fa:	fd045783          	lhu	a5,-48(s0)
    800061fe:	e395                	bnez	a5,80006222 <isdirempty+0x5e>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006200:	24c1                	addiw	s1,s1,16
    80006202:	04c92783          	lw	a5,76(s2)
    80006206:	fcf4ede3          	bltu	s1,a5,800061e0 <isdirempty+0x1c>
      return 0;
  }
  return 1;
    8000620a:	4505                	li	a0,1
    8000620c:	a821                	j	80006224 <isdirempty+0x60>
      panic("isdirempty: readi");
    8000620e:	00004517          	auipc	a0,0x4
    80006212:	a0250513          	addi	a0,a0,-1534 # 80009c10 <syscalls+0x310>
    80006216:	ffffa097          	auipc	ra,0xffffa
    8000621a:	314080e7          	jalr	788(ra) # 8000052a <panic>
  return 1;
    8000621e:	4505                	li	a0,1
}
    80006220:	8082                	ret
      return 0;
    80006222:	4501                	li	a0,0
}
    80006224:	70a2                	ld	ra,40(sp)
    80006226:	7402                	ld	s0,32(sp)
    80006228:	64e2                	ld	s1,24(sp)
    8000622a:	6942                	ld	s2,16(sp)
    8000622c:	6145                	addi	sp,sp,48
    8000622e:	8082                	ret

0000000080006230 <sys_unlink>:

uint64
sys_unlink(void)
{
    80006230:	7155                	addi	sp,sp,-208
    80006232:	e586                	sd	ra,200(sp)
    80006234:	e1a2                	sd	s0,192(sp)
    80006236:	fd26                	sd	s1,184(sp)
    80006238:	f94a                	sd	s2,176(sp)
    8000623a:	0980                	addi	s0,sp,208
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    8000623c:	08000613          	li	a2,128
    80006240:	f4040593          	addi	a1,s0,-192
    80006244:	4501                	li	a0,0
    80006246:	ffffd097          	auipc	ra,0xffffd
    8000624a:	2e6080e7          	jalr	742(ra) # 8000352c <argstr>
    8000624e:	16054363          	bltz	a0,800063b4 <sys_unlink+0x184>
    return -1;

  begin_op();
    80006252:	fffff097          	auipc	ra,0xfffff
    80006256:	af0080e7          	jalr	-1296(ra) # 80004d42 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000625a:	fc040593          	addi	a1,s0,-64
    8000625e:	f4040513          	addi	a0,s0,-192
    80006262:	ffffe097          	auipc	ra,0xffffe
    80006266:	5cc080e7          	jalr	1484(ra) # 8000482e <nameiparent>
    8000626a:	84aa                	mv	s1,a0
    8000626c:	c961                	beqz	a0,8000633c <sys_unlink+0x10c>
    end_op();
    return -1;
  }

  ilock(dp);
    8000626e:	ffffe097          	auipc	ra,0xffffe
    80006272:	dec080e7          	jalr	-532(ra) # 8000405a <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006276:	00004597          	auipc	a1,0x4
    8000627a:	87a58593          	addi	a1,a1,-1926 # 80009af0 <syscalls+0x1f0>
    8000627e:	fc040513          	addi	a0,s0,-64
    80006282:	ffffe097          	auipc	ra,0xffffe
    80006286:	2a2080e7          	jalr	674(ra) # 80004524 <namecmp>
    8000628a:	c175                	beqz	a0,8000636e <sys_unlink+0x13e>
    8000628c:	00004597          	auipc	a1,0x4
    80006290:	86c58593          	addi	a1,a1,-1940 # 80009af8 <syscalls+0x1f8>
    80006294:	fc040513          	addi	a0,s0,-64
    80006298:	ffffe097          	auipc	ra,0xffffe
    8000629c:	28c080e7          	jalr	652(ra) # 80004524 <namecmp>
    800062a0:	c579                	beqz	a0,8000636e <sys_unlink+0x13e>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    800062a2:	f3c40613          	addi	a2,s0,-196
    800062a6:	fc040593          	addi	a1,s0,-64
    800062aa:	8526                	mv	a0,s1
    800062ac:	ffffe097          	auipc	ra,0xffffe
    800062b0:	292080e7          	jalr	658(ra) # 8000453e <dirlookup>
    800062b4:	892a                	mv	s2,a0
    800062b6:	cd45                	beqz	a0,8000636e <sys_unlink+0x13e>
    goto bad;
  ilock(ip);
    800062b8:	ffffe097          	auipc	ra,0xffffe
    800062bc:	da2080e7          	jalr	-606(ra) # 8000405a <ilock>

  if(ip->nlink < 1)
    800062c0:	04a91783          	lh	a5,74(s2)
    800062c4:	08f05263          	blez	a5,80006348 <sys_unlink+0x118>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    800062c8:	04491703          	lh	a4,68(s2)
    800062cc:	4785                	li	a5,1
    800062ce:	08f70563          	beq	a4,a5,80006358 <sys_unlink+0x128>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    800062d2:	4641                	li	a2,16
    800062d4:	4581                	li	a1,0
    800062d6:	fd040513          	addi	a0,s0,-48
    800062da:	ffffb097          	auipc	ra,0xffffb
    800062de:	9e4080e7          	jalr	-1564(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800062e2:	4741                	li	a4,16
    800062e4:	f3c42683          	lw	a3,-196(s0)
    800062e8:	fd040613          	addi	a2,s0,-48
    800062ec:	4581                	li	a1,0
    800062ee:	8526                	mv	a0,s1
    800062f0:	ffffe097          	auipc	ra,0xffffe
    800062f4:	116080e7          	jalr	278(ra) # 80004406 <writei>
    800062f8:	47c1                	li	a5,16
    800062fa:	08f51a63          	bne	a0,a5,8000638e <sys_unlink+0x15e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    800062fe:	04491703          	lh	a4,68(s2)
    80006302:	4785                	li	a5,1
    80006304:	08f70d63          	beq	a4,a5,8000639e <sys_unlink+0x16e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    80006308:	8526                	mv	a0,s1
    8000630a:	ffffe097          	auipc	ra,0xffffe
    8000630e:	fb2080e7          	jalr	-78(ra) # 800042bc <iunlockput>

  ip->nlink--;
    80006312:	04a95783          	lhu	a5,74(s2)
    80006316:	37fd                	addiw	a5,a5,-1
    80006318:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000631c:	854a                	mv	a0,s2
    8000631e:	ffffe097          	auipc	ra,0xffffe
    80006322:	c72080e7          	jalr	-910(ra) # 80003f90 <iupdate>
  iunlockput(ip);
    80006326:	854a                	mv	a0,s2
    80006328:	ffffe097          	auipc	ra,0xffffe
    8000632c:	f94080e7          	jalr	-108(ra) # 800042bc <iunlockput>

  end_op();
    80006330:	fffff097          	auipc	ra,0xfffff
    80006334:	a92080e7          	jalr	-1390(ra) # 80004dc2 <end_op>

  return 0;
    80006338:	4501                	li	a0,0
    8000633a:	a0a1                	j	80006382 <sys_unlink+0x152>
    end_op();
    8000633c:	fffff097          	auipc	ra,0xfffff
    80006340:	a86080e7          	jalr	-1402(ra) # 80004dc2 <end_op>
    return -1;
    80006344:	557d                	li	a0,-1
    80006346:	a835                	j	80006382 <sys_unlink+0x152>
    panic("unlink: nlink < 1");
    80006348:	00003517          	auipc	a0,0x3
    8000634c:	7b850513          	addi	a0,a0,1976 # 80009b00 <syscalls+0x200>
    80006350:	ffffa097          	auipc	ra,0xffffa
    80006354:	1da080e7          	jalr	474(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006358:	854a                	mv	a0,s2
    8000635a:	00000097          	auipc	ra,0x0
    8000635e:	e6a080e7          	jalr	-406(ra) # 800061c4 <isdirempty>
    80006362:	f925                	bnez	a0,800062d2 <sys_unlink+0xa2>
    iunlockput(ip);
    80006364:	854a                	mv	a0,s2
    80006366:	ffffe097          	auipc	ra,0xffffe
    8000636a:	f56080e7          	jalr	-170(ra) # 800042bc <iunlockput>

bad:
  iunlockput(dp);
    8000636e:	8526                	mv	a0,s1
    80006370:	ffffe097          	auipc	ra,0xffffe
    80006374:	f4c080e7          	jalr	-180(ra) # 800042bc <iunlockput>
  end_op();
    80006378:	fffff097          	auipc	ra,0xfffff
    8000637c:	a4a080e7          	jalr	-1462(ra) # 80004dc2 <end_op>
  return -1;
    80006380:	557d                	li	a0,-1
}
    80006382:	60ae                	ld	ra,200(sp)
    80006384:	640e                	ld	s0,192(sp)
    80006386:	74ea                	ld	s1,184(sp)
    80006388:	794a                	ld	s2,176(sp)
    8000638a:	6169                	addi	sp,sp,208
    8000638c:	8082                	ret
    panic("unlink: writei");
    8000638e:	00003517          	auipc	a0,0x3
    80006392:	78a50513          	addi	a0,a0,1930 # 80009b18 <syscalls+0x218>
    80006396:	ffffa097          	auipc	ra,0xffffa
    8000639a:	194080e7          	jalr	404(ra) # 8000052a <panic>
    dp->nlink--;
    8000639e:	04a4d783          	lhu	a5,74(s1)
    800063a2:	37fd                	addiw	a5,a5,-1
    800063a4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800063a8:	8526                	mv	a0,s1
    800063aa:	ffffe097          	auipc	ra,0xffffe
    800063ae:	be6080e7          	jalr	-1050(ra) # 80003f90 <iupdate>
    800063b2:	bf99                	j	80006308 <sys_unlink+0xd8>
    return -1;
    800063b4:	557d                	li	a0,-1
    800063b6:	b7f1                	j	80006382 <sys_unlink+0x152>

00000000800063b8 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
    800063b8:	715d                	addi	sp,sp,-80
    800063ba:	e486                	sd	ra,72(sp)
    800063bc:	e0a2                	sd	s0,64(sp)
    800063be:	fc26                	sd	s1,56(sp)
    800063c0:	f84a                	sd	s2,48(sp)
    800063c2:	f44e                	sd	s3,40(sp)
    800063c4:	f052                	sd	s4,32(sp)
    800063c6:	ec56                	sd	s5,24(sp)
    800063c8:	0880                	addi	s0,sp,80
    800063ca:	89ae                	mv	s3,a1
    800063cc:	8ab2                	mv	s5,a2
    800063ce:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800063d0:	fb040593          	addi	a1,s0,-80
    800063d4:	ffffe097          	auipc	ra,0xffffe
    800063d8:	45a080e7          	jalr	1114(ra) # 8000482e <nameiparent>
    800063dc:	892a                	mv	s2,a0
    800063de:	12050e63          	beqz	a0,8000651a <create+0x162>
    return 0;

  ilock(dp);
    800063e2:	ffffe097          	auipc	ra,0xffffe
    800063e6:	c78080e7          	jalr	-904(ra) # 8000405a <ilock>
  
  if((ip = dirlookup(dp, name, 0)) != 0){
    800063ea:	4601                	li	a2,0
    800063ec:	fb040593          	addi	a1,s0,-80
    800063f0:	854a                	mv	a0,s2
    800063f2:	ffffe097          	auipc	ra,0xffffe
    800063f6:	14c080e7          	jalr	332(ra) # 8000453e <dirlookup>
    800063fa:	84aa                	mv	s1,a0
    800063fc:	c921                	beqz	a0,8000644c <create+0x94>
    iunlockput(dp);
    800063fe:	854a                	mv	a0,s2
    80006400:	ffffe097          	auipc	ra,0xffffe
    80006404:	ebc080e7          	jalr	-324(ra) # 800042bc <iunlockput>
    ilock(ip);
    80006408:	8526                	mv	a0,s1
    8000640a:	ffffe097          	auipc	ra,0xffffe
    8000640e:	c50080e7          	jalr	-944(ra) # 8000405a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006412:	2981                	sext.w	s3,s3
    80006414:	4789                	li	a5,2
    80006416:	02f99463          	bne	s3,a5,8000643e <create+0x86>
    8000641a:	0444d783          	lhu	a5,68(s1)
    8000641e:	37f9                	addiw	a5,a5,-2
    80006420:	17c2                	slli	a5,a5,0x30
    80006422:	93c1                	srli	a5,a5,0x30
    80006424:	4705                	li	a4,1
    80006426:	00f76c63          	bltu	a4,a5,8000643e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000642a:	8526                	mv	a0,s1
    8000642c:	60a6                	ld	ra,72(sp)
    8000642e:	6406                	ld	s0,64(sp)
    80006430:	74e2                	ld	s1,56(sp)
    80006432:	7942                	ld	s2,48(sp)
    80006434:	79a2                	ld	s3,40(sp)
    80006436:	7a02                	ld	s4,32(sp)
    80006438:	6ae2                	ld	s5,24(sp)
    8000643a:	6161                	addi	sp,sp,80
    8000643c:	8082                	ret
    iunlockput(ip);
    8000643e:	8526                	mv	a0,s1
    80006440:	ffffe097          	auipc	ra,0xffffe
    80006444:	e7c080e7          	jalr	-388(ra) # 800042bc <iunlockput>
    return 0;
    80006448:	4481                	li	s1,0
    8000644a:	b7c5                	j	8000642a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000644c:	85ce                	mv	a1,s3
    8000644e:	00092503          	lw	a0,0(s2)
    80006452:	ffffe097          	auipc	ra,0xffffe
    80006456:	a70080e7          	jalr	-1424(ra) # 80003ec2 <ialloc>
    8000645a:	84aa                	mv	s1,a0
    8000645c:	c521                	beqz	a0,800064a4 <create+0xec>
  ilock(ip);
    8000645e:	ffffe097          	auipc	ra,0xffffe
    80006462:	bfc080e7          	jalr	-1028(ra) # 8000405a <ilock>
  ip->major = major;
    80006466:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000646a:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000646e:	4a05                	li	s4,1
    80006470:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80006474:	8526                	mv	a0,s1
    80006476:	ffffe097          	auipc	ra,0xffffe
    8000647a:	b1a080e7          	jalr	-1254(ra) # 80003f90 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000647e:	2981                	sext.w	s3,s3
    80006480:	03498a63          	beq	s3,s4,800064b4 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80006484:	40d0                	lw	a2,4(s1)
    80006486:	fb040593          	addi	a1,s0,-80
    8000648a:	854a                	mv	a0,s2
    8000648c:	ffffe097          	auipc	ra,0xffffe
    80006490:	2c2080e7          	jalr	706(ra) # 8000474e <dirlink>
    80006494:	06054b63          	bltz	a0,8000650a <create+0x152>
  iunlockput(dp);
    80006498:	854a                	mv	a0,s2
    8000649a:	ffffe097          	auipc	ra,0xffffe
    8000649e:	e22080e7          	jalr	-478(ra) # 800042bc <iunlockput>
  return ip;
    800064a2:	b761                	j	8000642a <create+0x72>
    panic("create: ialloc");
    800064a4:	00003517          	auipc	a0,0x3
    800064a8:	78450513          	addi	a0,a0,1924 # 80009c28 <syscalls+0x328>
    800064ac:	ffffa097          	auipc	ra,0xffffa
    800064b0:	07e080e7          	jalr	126(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    800064b4:	04a95783          	lhu	a5,74(s2)
    800064b8:	2785                	addiw	a5,a5,1
    800064ba:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800064be:	854a                	mv	a0,s2
    800064c0:	ffffe097          	auipc	ra,0xffffe
    800064c4:	ad0080e7          	jalr	-1328(ra) # 80003f90 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800064c8:	40d0                	lw	a2,4(s1)
    800064ca:	00003597          	auipc	a1,0x3
    800064ce:	62658593          	addi	a1,a1,1574 # 80009af0 <syscalls+0x1f0>
    800064d2:	8526                	mv	a0,s1
    800064d4:	ffffe097          	auipc	ra,0xffffe
    800064d8:	27a080e7          	jalr	634(ra) # 8000474e <dirlink>
    800064dc:	00054f63          	bltz	a0,800064fa <create+0x142>
    800064e0:	00492603          	lw	a2,4(s2)
    800064e4:	00003597          	auipc	a1,0x3
    800064e8:	61458593          	addi	a1,a1,1556 # 80009af8 <syscalls+0x1f8>
    800064ec:	8526                	mv	a0,s1
    800064ee:	ffffe097          	auipc	ra,0xffffe
    800064f2:	260080e7          	jalr	608(ra) # 8000474e <dirlink>
    800064f6:	f80557e3          	bgez	a0,80006484 <create+0xcc>
      panic("create dots");
    800064fa:	00003517          	auipc	a0,0x3
    800064fe:	73e50513          	addi	a0,a0,1854 # 80009c38 <syscalls+0x338>
    80006502:	ffffa097          	auipc	ra,0xffffa
    80006506:	028080e7          	jalr	40(ra) # 8000052a <panic>
    panic("create: dirlink");
    8000650a:	00003517          	auipc	a0,0x3
    8000650e:	73e50513          	addi	a0,a0,1854 # 80009c48 <syscalls+0x348>
    80006512:	ffffa097          	auipc	ra,0xffffa
    80006516:	018080e7          	jalr	24(ra) # 8000052a <panic>
    return 0;
    8000651a:	84aa                	mv	s1,a0
    8000651c:	b739                	j	8000642a <create+0x72>

000000008000651e <sys_open>:

uint64
sys_open(void)
{
    8000651e:	7131                	addi	sp,sp,-192
    80006520:	fd06                	sd	ra,184(sp)
    80006522:	f922                	sd	s0,176(sp)
    80006524:	f526                	sd	s1,168(sp)
    80006526:	f14a                	sd	s2,160(sp)
    80006528:	ed4e                	sd	s3,152(sp)
    8000652a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000652c:	08000613          	li	a2,128
    80006530:	f5040593          	addi	a1,s0,-176
    80006534:	4501                	li	a0,0
    80006536:	ffffd097          	auipc	ra,0xffffd
    8000653a:	ff6080e7          	jalr	-10(ra) # 8000352c <argstr>
    return -1;
    8000653e:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006540:	0c054163          	bltz	a0,80006602 <sys_open+0xe4>
    80006544:	f4c40593          	addi	a1,s0,-180
    80006548:	4505                	li	a0,1
    8000654a:	ffffd097          	auipc	ra,0xffffd
    8000654e:	f9e080e7          	jalr	-98(ra) # 800034e8 <argint>
    80006552:	0a054863          	bltz	a0,80006602 <sys_open+0xe4>

  begin_op();
    80006556:	ffffe097          	auipc	ra,0xffffe
    8000655a:	7ec080e7          	jalr	2028(ra) # 80004d42 <begin_op>

  if(omode & O_CREATE){
    8000655e:	f4c42783          	lw	a5,-180(s0)
    80006562:	2007f793          	andi	a5,a5,512
    80006566:	cbdd                	beqz	a5,8000661c <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80006568:	4681                	li	a3,0
    8000656a:	4601                	li	a2,0
    8000656c:	4589                	li	a1,2
    8000656e:	f5040513          	addi	a0,s0,-176
    80006572:	00000097          	auipc	ra,0x0
    80006576:	e46080e7          	jalr	-442(ra) # 800063b8 <create>
    8000657a:	892a                	mv	s2,a0
    if(ip == 0){
    8000657c:	c959                	beqz	a0,80006612 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000657e:	04491703          	lh	a4,68(s2)
    80006582:	478d                	li	a5,3
    80006584:	00f71763          	bne	a4,a5,80006592 <sys_open+0x74>
    80006588:	04695703          	lhu	a4,70(s2)
    8000658c:	47a5                	li	a5,9
    8000658e:	0ce7ec63          	bltu	a5,a4,80006666 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006592:	fffff097          	auipc	ra,0xfffff
    80006596:	bc0080e7          	jalr	-1088(ra) # 80005152 <filealloc>
    8000659a:	89aa                	mv	s3,a0
    8000659c:	10050263          	beqz	a0,800066a0 <sys_open+0x182>
    800065a0:	00000097          	auipc	ra,0x0
    800065a4:	8e2080e7          	jalr	-1822(ra) # 80005e82 <fdalloc>
    800065a8:	84aa                	mv	s1,a0
    800065aa:	0e054663          	bltz	a0,80006696 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800065ae:	04491703          	lh	a4,68(s2)
    800065b2:	478d                	li	a5,3
    800065b4:	0cf70463          	beq	a4,a5,8000667c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800065b8:	4789                	li	a5,2
    800065ba:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800065be:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800065c2:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800065c6:	f4c42783          	lw	a5,-180(s0)
    800065ca:	0017c713          	xori	a4,a5,1
    800065ce:	8b05                	andi	a4,a4,1
    800065d0:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800065d4:	0037f713          	andi	a4,a5,3
    800065d8:	00e03733          	snez	a4,a4
    800065dc:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800065e0:	4007f793          	andi	a5,a5,1024
    800065e4:	c791                	beqz	a5,800065f0 <sys_open+0xd2>
    800065e6:	04491703          	lh	a4,68(s2)
    800065ea:	4789                	li	a5,2
    800065ec:	08f70f63          	beq	a4,a5,8000668a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800065f0:	854a                	mv	a0,s2
    800065f2:	ffffe097          	auipc	ra,0xffffe
    800065f6:	b2a080e7          	jalr	-1238(ra) # 8000411c <iunlock>
  end_op();
    800065fa:	ffffe097          	auipc	ra,0xffffe
    800065fe:	7c8080e7          	jalr	1992(ra) # 80004dc2 <end_op>

  return fd;
}
    80006602:	8526                	mv	a0,s1
    80006604:	70ea                	ld	ra,184(sp)
    80006606:	744a                	ld	s0,176(sp)
    80006608:	74aa                	ld	s1,168(sp)
    8000660a:	790a                	ld	s2,160(sp)
    8000660c:	69ea                	ld	s3,152(sp)
    8000660e:	6129                	addi	sp,sp,192
    80006610:	8082                	ret
      end_op();
    80006612:	ffffe097          	auipc	ra,0xffffe
    80006616:	7b0080e7          	jalr	1968(ra) # 80004dc2 <end_op>
      return -1;
    8000661a:	b7e5                	j	80006602 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000661c:	f5040513          	addi	a0,s0,-176
    80006620:	ffffe097          	auipc	ra,0xffffe
    80006624:	1f0080e7          	jalr	496(ra) # 80004810 <namei>
    80006628:	892a                	mv	s2,a0
    8000662a:	c905                	beqz	a0,8000665a <sys_open+0x13c>
    ilock(ip);
    8000662c:	ffffe097          	auipc	ra,0xffffe
    80006630:	a2e080e7          	jalr	-1490(ra) # 8000405a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006634:	04491703          	lh	a4,68(s2)
    80006638:	4785                	li	a5,1
    8000663a:	f4f712e3          	bne	a4,a5,8000657e <sys_open+0x60>
    8000663e:	f4c42783          	lw	a5,-180(s0)
    80006642:	dba1                	beqz	a5,80006592 <sys_open+0x74>
      iunlockput(ip);
    80006644:	854a                	mv	a0,s2
    80006646:	ffffe097          	auipc	ra,0xffffe
    8000664a:	c76080e7          	jalr	-906(ra) # 800042bc <iunlockput>
      end_op();
    8000664e:	ffffe097          	auipc	ra,0xffffe
    80006652:	774080e7          	jalr	1908(ra) # 80004dc2 <end_op>
      return -1;
    80006656:	54fd                	li	s1,-1
    80006658:	b76d                	j	80006602 <sys_open+0xe4>
      end_op();
    8000665a:	ffffe097          	auipc	ra,0xffffe
    8000665e:	768080e7          	jalr	1896(ra) # 80004dc2 <end_op>
      return -1;
    80006662:	54fd                	li	s1,-1
    80006664:	bf79                	j	80006602 <sys_open+0xe4>
    iunlockput(ip);
    80006666:	854a                	mv	a0,s2
    80006668:	ffffe097          	auipc	ra,0xffffe
    8000666c:	c54080e7          	jalr	-940(ra) # 800042bc <iunlockput>
    end_op();
    80006670:	ffffe097          	auipc	ra,0xffffe
    80006674:	752080e7          	jalr	1874(ra) # 80004dc2 <end_op>
    return -1;
    80006678:	54fd                	li	s1,-1
    8000667a:	b761                	j	80006602 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000667c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006680:	04691783          	lh	a5,70(s2)
    80006684:	02f99223          	sh	a5,36(s3)
    80006688:	bf2d                	j	800065c2 <sys_open+0xa4>
    itrunc(ip);
    8000668a:	854a                	mv	a0,s2
    8000668c:	ffffe097          	auipc	ra,0xffffe
    80006690:	adc080e7          	jalr	-1316(ra) # 80004168 <itrunc>
    80006694:	bfb1                	j	800065f0 <sys_open+0xd2>
      fileclose(f);
    80006696:	854e                	mv	a0,s3
    80006698:	fffff097          	auipc	ra,0xfffff
    8000669c:	b76080e7          	jalr	-1162(ra) # 8000520e <fileclose>
    iunlockput(ip);
    800066a0:	854a                	mv	a0,s2
    800066a2:	ffffe097          	auipc	ra,0xffffe
    800066a6:	c1a080e7          	jalr	-998(ra) # 800042bc <iunlockput>
    end_op();
    800066aa:	ffffe097          	auipc	ra,0xffffe
    800066ae:	718080e7          	jalr	1816(ra) # 80004dc2 <end_op>
    return -1;
    800066b2:	54fd                	li	s1,-1
    800066b4:	b7b9                	j	80006602 <sys_open+0xe4>

00000000800066b6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800066b6:	7175                	addi	sp,sp,-144
    800066b8:	e506                	sd	ra,136(sp)
    800066ba:	e122                	sd	s0,128(sp)
    800066bc:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800066be:	ffffe097          	auipc	ra,0xffffe
    800066c2:	684080e7          	jalr	1668(ra) # 80004d42 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800066c6:	08000613          	li	a2,128
    800066ca:	f7040593          	addi	a1,s0,-144
    800066ce:	4501                	li	a0,0
    800066d0:	ffffd097          	auipc	ra,0xffffd
    800066d4:	e5c080e7          	jalr	-420(ra) # 8000352c <argstr>
    800066d8:	02054963          	bltz	a0,8000670a <sys_mkdir+0x54>
    800066dc:	4681                	li	a3,0
    800066de:	4601                	li	a2,0
    800066e0:	4585                	li	a1,1
    800066e2:	f7040513          	addi	a0,s0,-144
    800066e6:	00000097          	auipc	ra,0x0
    800066ea:	cd2080e7          	jalr	-814(ra) # 800063b8 <create>
    800066ee:	cd11                	beqz	a0,8000670a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800066f0:	ffffe097          	auipc	ra,0xffffe
    800066f4:	bcc080e7          	jalr	-1076(ra) # 800042bc <iunlockput>
  end_op();
    800066f8:	ffffe097          	auipc	ra,0xffffe
    800066fc:	6ca080e7          	jalr	1738(ra) # 80004dc2 <end_op>
  return 0;
    80006700:	4501                	li	a0,0
}
    80006702:	60aa                	ld	ra,136(sp)
    80006704:	640a                	ld	s0,128(sp)
    80006706:	6149                	addi	sp,sp,144
    80006708:	8082                	ret
    end_op();
    8000670a:	ffffe097          	auipc	ra,0xffffe
    8000670e:	6b8080e7          	jalr	1720(ra) # 80004dc2 <end_op>
    return -1;
    80006712:	557d                	li	a0,-1
    80006714:	b7fd                	j	80006702 <sys_mkdir+0x4c>

0000000080006716 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006716:	7135                	addi	sp,sp,-160
    80006718:	ed06                	sd	ra,152(sp)
    8000671a:	e922                	sd	s0,144(sp)
    8000671c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000671e:	ffffe097          	auipc	ra,0xffffe
    80006722:	624080e7          	jalr	1572(ra) # 80004d42 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006726:	08000613          	li	a2,128
    8000672a:	f7040593          	addi	a1,s0,-144
    8000672e:	4501                	li	a0,0
    80006730:	ffffd097          	auipc	ra,0xffffd
    80006734:	dfc080e7          	jalr	-516(ra) # 8000352c <argstr>
    80006738:	04054a63          	bltz	a0,8000678c <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000673c:	f6c40593          	addi	a1,s0,-148
    80006740:	4505                	li	a0,1
    80006742:	ffffd097          	auipc	ra,0xffffd
    80006746:	da6080e7          	jalr	-602(ra) # 800034e8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000674a:	04054163          	bltz	a0,8000678c <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000674e:	f6840593          	addi	a1,s0,-152
    80006752:	4509                	li	a0,2
    80006754:	ffffd097          	auipc	ra,0xffffd
    80006758:	d94080e7          	jalr	-620(ra) # 800034e8 <argint>
     argint(1, &major) < 0 ||
    8000675c:	02054863          	bltz	a0,8000678c <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006760:	f6841683          	lh	a3,-152(s0)
    80006764:	f6c41603          	lh	a2,-148(s0)
    80006768:	458d                	li	a1,3
    8000676a:	f7040513          	addi	a0,s0,-144
    8000676e:	00000097          	auipc	ra,0x0
    80006772:	c4a080e7          	jalr	-950(ra) # 800063b8 <create>
     argint(2, &minor) < 0 ||
    80006776:	c919                	beqz	a0,8000678c <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006778:	ffffe097          	auipc	ra,0xffffe
    8000677c:	b44080e7          	jalr	-1212(ra) # 800042bc <iunlockput>
  end_op();
    80006780:	ffffe097          	auipc	ra,0xffffe
    80006784:	642080e7          	jalr	1602(ra) # 80004dc2 <end_op>
  return 0;
    80006788:	4501                	li	a0,0
    8000678a:	a031                	j	80006796 <sys_mknod+0x80>
    end_op();
    8000678c:	ffffe097          	auipc	ra,0xffffe
    80006790:	636080e7          	jalr	1590(ra) # 80004dc2 <end_op>
    return -1;
    80006794:	557d                	li	a0,-1
}
    80006796:	60ea                	ld	ra,152(sp)
    80006798:	644a                	ld	s0,144(sp)
    8000679a:	610d                	addi	sp,sp,160
    8000679c:	8082                	ret

000000008000679e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000679e:	7135                	addi	sp,sp,-160
    800067a0:	ed06                	sd	ra,152(sp)
    800067a2:	e922                	sd	s0,144(sp)
    800067a4:	e526                	sd	s1,136(sp)
    800067a6:	e14a                	sd	s2,128(sp)
    800067a8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800067aa:	ffffb097          	auipc	ra,0xffffb
    800067ae:	58a080e7          	jalr	1418(ra) # 80001d34 <myproc>
    800067b2:	892a                	mv	s2,a0
  
  begin_op();
    800067b4:	ffffe097          	auipc	ra,0xffffe
    800067b8:	58e080e7          	jalr	1422(ra) # 80004d42 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800067bc:	08000613          	li	a2,128
    800067c0:	f6040593          	addi	a1,s0,-160
    800067c4:	4501                	li	a0,0
    800067c6:	ffffd097          	auipc	ra,0xffffd
    800067ca:	d66080e7          	jalr	-666(ra) # 8000352c <argstr>
    800067ce:	04054b63          	bltz	a0,80006824 <sys_chdir+0x86>
    800067d2:	f6040513          	addi	a0,s0,-160
    800067d6:	ffffe097          	auipc	ra,0xffffe
    800067da:	03a080e7          	jalr	58(ra) # 80004810 <namei>
    800067de:	84aa                	mv	s1,a0
    800067e0:	c131                	beqz	a0,80006824 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800067e2:	ffffe097          	auipc	ra,0xffffe
    800067e6:	878080e7          	jalr	-1928(ra) # 8000405a <ilock>
  if(ip->type != T_DIR){
    800067ea:	04449703          	lh	a4,68(s1)
    800067ee:	4785                	li	a5,1
    800067f0:	04f71063          	bne	a4,a5,80006830 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800067f4:	8526                	mv	a0,s1
    800067f6:	ffffe097          	auipc	ra,0xffffe
    800067fa:	926080e7          	jalr	-1754(ra) # 8000411c <iunlock>
  iput(p->cwd);
    800067fe:	15093503          	ld	a0,336(s2)
    80006802:	ffffe097          	auipc	ra,0xffffe
    80006806:	a12080e7          	jalr	-1518(ra) # 80004214 <iput>
  end_op();
    8000680a:	ffffe097          	auipc	ra,0xffffe
    8000680e:	5b8080e7          	jalr	1464(ra) # 80004dc2 <end_op>
  p->cwd = ip;
    80006812:	14993823          	sd	s1,336(s2)
  return 0;
    80006816:	4501                	li	a0,0
}
    80006818:	60ea                	ld	ra,152(sp)
    8000681a:	644a                	ld	s0,144(sp)
    8000681c:	64aa                	ld	s1,136(sp)
    8000681e:	690a                	ld	s2,128(sp)
    80006820:	610d                	addi	sp,sp,160
    80006822:	8082                	ret
    end_op();
    80006824:	ffffe097          	auipc	ra,0xffffe
    80006828:	59e080e7          	jalr	1438(ra) # 80004dc2 <end_op>
    return -1;
    8000682c:	557d                	li	a0,-1
    8000682e:	b7ed                	j	80006818 <sys_chdir+0x7a>
    iunlockput(ip);
    80006830:	8526                	mv	a0,s1
    80006832:	ffffe097          	auipc	ra,0xffffe
    80006836:	a8a080e7          	jalr	-1398(ra) # 800042bc <iunlockput>
    end_op();
    8000683a:	ffffe097          	auipc	ra,0xffffe
    8000683e:	588080e7          	jalr	1416(ra) # 80004dc2 <end_op>
    return -1;
    80006842:	557d                	li	a0,-1
    80006844:	bfd1                	j	80006818 <sys_chdir+0x7a>

0000000080006846 <sys_exec>:

uint64
sys_exec(void)
{
    80006846:	7145                	addi	sp,sp,-464
    80006848:	e786                	sd	ra,456(sp)
    8000684a:	e3a2                	sd	s0,448(sp)
    8000684c:	ff26                	sd	s1,440(sp)
    8000684e:	fb4a                	sd	s2,432(sp)
    80006850:	f74e                	sd	s3,424(sp)
    80006852:	f352                	sd	s4,416(sp)
    80006854:	ef56                	sd	s5,408(sp)
    80006856:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006858:	08000613          	li	a2,128
    8000685c:	f4040593          	addi	a1,s0,-192
    80006860:	4501                	li	a0,0
    80006862:	ffffd097          	auipc	ra,0xffffd
    80006866:	cca080e7          	jalr	-822(ra) # 8000352c <argstr>
    return -1;
    8000686a:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000686c:	0c054a63          	bltz	a0,80006940 <sys_exec+0xfa>
    80006870:	e3840593          	addi	a1,s0,-456
    80006874:	4505                	li	a0,1
    80006876:	ffffd097          	auipc	ra,0xffffd
    8000687a:	c94080e7          	jalr	-876(ra) # 8000350a <argaddr>
    8000687e:	0c054163          	bltz	a0,80006940 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006882:	10000613          	li	a2,256
    80006886:	4581                	li	a1,0
    80006888:	e4040513          	addi	a0,s0,-448
    8000688c:	ffffa097          	auipc	ra,0xffffa
    80006890:	432080e7          	jalr	1074(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006894:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006898:	89a6                	mv	s3,s1
    8000689a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000689c:	02000a13          	li	s4,32
    800068a0:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800068a4:	00391793          	slli	a5,s2,0x3
    800068a8:	e3040593          	addi	a1,s0,-464
    800068ac:	e3843503          	ld	a0,-456(s0)
    800068b0:	953e                	add	a0,a0,a5
    800068b2:	ffffd097          	auipc	ra,0xffffd
    800068b6:	b9c080e7          	jalr	-1124(ra) # 8000344e <fetchaddr>
    800068ba:	02054a63          	bltz	a0,800068ee <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    800068be:	e3043783          	ld	a5,-464(s0)
    800068c2:	c3b9                	beqz	a5,80006908 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800068c4:	ffffa097          	auipc	ra,0xffffa
    800068c8:	20e080e7          	jalr	526(ra) # 80000ad2 <kalloc>
    800068cc:	85aa                	mv	a1,a0
    800068ce:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800068d2:	cd11                	beqz	a0,800068ee <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800068d4:	6605                	lui	a2,0x1
    800068d6:	e3043503          	ld	a0,-464(s0)
    800068da:	ffffd097          	auipc	ra,0xffffd
    800068de:	bc6080e7          	jalr	-1082(ra) # 800034a0 <fetchstr>
    800068e2:	00054663          	bltz	a0,800068ee <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    800068e6:	0905                	addi	s2,s2,1
    800068e8:	09a1                	addi	s3,s3,8
    800068ea:	fb491be3          	bne	s2,s4,800068a0 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800068ee:	10048913          	addi	s2,s1,256
    800068f2:	6088                	ld	a0,0(s1)
    800068f4:	c529                	beqz	a0,8000693e <sys_exec+0xf8>
    kfree(argv[i]);
    800068f6:	ffffa097          	auipc	ra,0xffffa
    800068fa:	0e0080e7          	jalr	224(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800068fe:	04a1                	addi	s1,s1,8
    80006900:	ff2499e3          	bne	s1,s2,800068f2 <sys_exec+0xac>
  return -1;
    80006904:	597d                	li	s2,-1
    80006906:	a82d                	j	80006940 <sys_exec+0xfa>
      argv[i] = 0;
    80006908:	0a8e                	slli	s5,s5,0x3
    8000690a:	fc040793          	addi	a5,s0,-64
    8000690e:	9abe                	add	s5,s5,a5
    80006910:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffcbe80>
  int ret = exec(path, argv);
    80006914:	e4040593          	addi	a1,s0,-448
    80006918:	f4040513          	addi	a0,s0,-192
    8000691c:	fffff097          	auipc	ra,0xfffff
    80006920:	13a080e7          	jalr	314(ra) # 80005a56 <exec>
    80006924:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006926:	10048993          	addi	s3,s1,256
    8000692a:	6088                	ld	a0,0(s1)
    8000692c:	c911                	beqz	a0,80006940 <sys_exec+0xfa>
    kfree(argv[i]);
    8000692e:	ffffa097          	auipc	ra,0xffffa
    80006932:	0a8080e7          	jalr	168(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006936:	04a1                	addi	s1,s1,8
    80006938:	ff3499e3          	bne	s1,s3,8000692a <sys_exec+0xe4>
    8000693c:	a011                	j	80006940 <sys_exec+0xfa>
  return -1;
    8000693e:	597d                	li	s2,-1
}
    80006940:	854a                	mv	a0,s2
    80006942:	60be                	ld	ra,456(sp)
    80006944:	641e                	ld	s0,448(sp)
    80006946:	74fa                	ld	s1,440(sp)
    80006948:	795a                	ld	s2,432(sp)
    8000694a:	79ba                	ld	s3,424(sp)
    8000694c:	7a1a                	ld	s4,416(sp)
    8000694e:	6afa                	ld	s5,408(sp)
    80006950:	6179                	addi	sp,sp,464
    80006952:	8082                	ret

0000000080006954 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006954:	7139                	addi	sp,sp,-64
    80006956:	fc06                	sd	ra,56(sp)
    80006958:	f822                	sd	s0,48(sp)
    8000695a:	f426                	sd	s1,40(sp)
    8000695c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000695e:	ffffb097          	auipc	ra,0xffffb
    80006962:	3d6080e7          	jalr	982(ra) # 80001d34 <myproc>
    80006966:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006968:	fd840593          	addi	a1,s0,-40
    8000696c:	4501                	li	a0,0
    8000696e:	ffffd097          	auipc	ra,0xffffd
    80006972:	b9c080e7          	jalr	-1124(ra) # 8000350a <argaddr>
    return -1;
    80006976:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006978:	0e054063          	bltz	a0,80006a58 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    8000697c:	fc840593          	addi	a1,s0,-56
    80006980:	fd040513          	addi	a0,s0,-48
    80006984:	fffff097          	auipc	ra,0xfffff
    80006988:	db0080e7          	jalr	-592(ra) # 80005734 <pipealloc>
    return -1;
    8000698c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000698e:	0c054563          	bltz	a0,80006a58 <sys_pipe+0x104>
  fd0 = -1;
    80006992:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006996:	fd043503          	ld	a0,-48(s0)
    8000699a:	fffff097          	auipc	ra,0xfffff
    8000699e:	4e8080e7          	jalr	1256(ra) # 80005e82 <fdalloc>
    800069a2:	fca42223          	sw	a0,-60(s0)
    800069a6:	08054c63          	bltz	a0,80006a3e <sys_pipe+0xea>
    800069aa:	fc843503          	ld	a0,-56(s0)
    800069ae:	fffff097          	auipc	ra,0xfffff
    800069b2:	4d4080e7          	jalr	1236(ra) # 80005e82 <fdalloc>
    800069b6:	fca42023          	sw	a0,-64(s0)
    800069ba:	06054863          	bltz	a0,80006a2a <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800069be:	4691                	li	a3,4
    800069c0:	fc440613          	addi	a2,s0,-60
    800069c4:	fd843583          	ld	a1,-40(s0)
    800069c8:	68a8                	ld	a0,80(s1)
    800069ca:	ffffb097          	auipc	ra,0xffffb
    800069ce:	9c8080e7          	jalr	-1592(ra) # 80001392 <copyout>
    800069d2:	02054063          	bltz	a0,800069f2 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800069d6:	4691                	li	a3,4
    800069d8:	fc040613          	addi	a2,s0,-64
    800069dc:	fd843583          	ld	a1,-40(s0)
    800069e0:	0591                	addi	a1,a1,4
    800069e2:	68a8                	ld	a0,80(s1)
    800069e4:	ffffb097          	auipc	ra,0xffffb
    800069e8:	9ae080e7          	jalr	-1618(ra) # 80001392 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800069ec:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800069ee:	06055563          	bgez	a0,80006a58 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    800069f2:	fc442783          	lw	a5,-60(s0)
    800069f6:	07e9                	addi	a5,a5,26
    800069f8:	078e                	slli	a5,a5,0x3
    800069fa:	97a6                	add	a5,a5,s1
    800069fc:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006a00:	fc042503          	lw	a0,-64(s0)
    80006a04:	0569                	addi	a0,a0,26
    80006a06:	050e                	slli	a0,a0,0x3
    80006a08:	9526                	add	a0,a0,s1
    80006a0a:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006a0e:	fd043503          	ld	a0,-48(s0)
    80006a12:	ffffe097          	auipc	ra,0xffffe
    80006a16:	7fc080e7          	jalr	2044(ra) # 8000520e <fileclose>
    fileclose(wf);
    80006a1a:	fc843503          	ld	a0,-56(s0)
    80006a1e:	ffffe097          	auipc	ra,0xffffe
    80006a22:	7f0080e7          	jalr	2032(ra) # 8000520e <fileclose>
    return -1;
    80006a26:	57fd                	li	a5,-1
    80006a28:	a805                	j	80006a58 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006a2a:	fc442783          	lw	a5,-60(s0)
    80006a2e:	0007c863          	bltz	a5,80006a3e <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006a32:	01a78513          	addi	a0,a5,26
    80006a36:	050e                	slli	a0,a0,0x3
    80006a38:	9526                	add	a0,a0,s1
    80006a3a:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006a3e:	fd043503          	ld	a0,-48(s0)
    80006a42:	ffffe097          	auipc	ra,0xffffe
    80006a46:	7cc080e7          	jalr	1996(ra) # 8000520e <fileclose>
    fileclose(wf);
    80006a4a:	fc843503          	ld	a0,-56(s0)
    80006a4e:	ffffe097          	auipc	ra,0xffffe
    80006a52:	7c0080e7          	jalr	1984(ra) # 8000520e <fileclose>
    return -1;
    80006a56:	57fd                	li	a5,-1
}
    80006a58:	853e                	mv	a0,a5
    80006a5a:	70e2                	ld	ra,56(sp)
    80006a5c:	7442                	ld	s0,48(sp)
    80006a5e:	74a2                	ld	s1,40(sp)
    80006a60:	6121                	addi	sp,sp,64
    80006a62:	8082                	ret
	...

0000000080006a70 <kernelvec>:
    80006a70:	7111                	addi	sp,sp,-256
    80006a72:	e006                	sd	ra,0(sp)
    80006a74:	e40a                	sd	sp,8(sp)
    80006a76:	e80e                	sd	gp,16(sp)
    80006a78:	ec12                	sd	tp,24(sp)
    80006a7a:	f016                	sd	t0,32(sp)
    80006a7c:	f41a                	sd	t1,40(sp)
    80006a7e:	f81e                	sd	t2,48(sp)
    80006a80:	fc22                	sd	s0,56(sp)
    80006a82:	e0a6                	sd	s1,64(sp)
    80006a84:	e4aa                	sd	a0,72(sp)
    80006a86:	e8ae                	sd	a1,80(sp)
    80006a88:	ecb2                	sd	a2,88(sp)
    80006a8a:	f0b6                	sd	a3,96(sp)
    80006a8c:	f4ba                	sd	a4,104(sp)
    80006a8e:	f8be                	sd	a5,112(sp)
    80006a90:	fcc2                	sd	a6,120(sp)
    80006a92:	e146                	sd	a7,128(sp)
    80006a94:	e54a                	sd	s2,136(sp)
    80006a96:	e94e                	sd	s3,144(sp)
    80006a98:	ed52                	sd	s4,152(sp)
    80006a9a:	f156                	sd	s5,160(sp)
    80006a9c:	f55a                	sd	s6,168(sp)
    80006a9e:	f95e                	sd	s7,176(sp)
    80006aa0:	fd62                	sd	s8,184(sp)
    80006aa2:	e1e6                	sd	s9,192(sp)
    80006aa4:	e5ea                	sd	s10,200(sp)
    80006aa6:	e9ee                	sd	s11,208(sp)
    80006aa8:	edf2                	sd	t3,216(sp)
    80006aaa:	f1f6                	sd	t4,224(sp)
    80006aac:	f5fa                	sd	t5,232(sp)
    80006aae:	f9fe                	sd	t6,240(sp)
    80006ab0:	851fc0ef          	jal	ra,80003300 <kerneltrap>
    80006ab4:	6082                	ld	ra,0(sp)
    80006ab6:	6122                	ld	sp,8(sp)
    80006ab8:	61c2                	ld	gp,16(sp)
    80006aba:	7282                	ld	t0,32(sp)
    80006abc:	7322                	ld	t1,40(sp)
    80006abe:	73c2                	ld	t2,48(sp)
    80006ac0:	7462                	ld	s0,56(sp)
    80006ac2:	6486                	ld	s1,64(sp)
    80006ac4:	6526                	ld	a0,72(sp)
    80006ac6:	65c6                	ld	a1,80(sp)
    80006ac8:	6666                	ld	a2,88(sp)
    80006aca:	7686                	ld	a3,96(sp)
    80006acc:	7726                	ld	a4,104(sp)
    80006ace:	77c6                	ld	a5,112(sp)
    80006ad0:	7866                	ld	a6,120(sp)
    80006ad2:	688a                	ld	a7,128(sp)
    80006ad4:	692a                	ld	s2,136(sp)
    80006ad6:	69ca                	ld	s3,144(sp)
    80006ad8:	6a6a                	ld	s4,152(sp)
    80006ada:	7a8a                	ld	s5,160(sp)
    80006adc:	7b2a                	ld	s6,168(sp)
    80006ade:	7bca                	ld	s7,176(sp)
    80006ae0:	7c6a                	ld	s8,184(sp)
    80006ae2:	6c8e                	ld	s9,192(sp)
    80006ae4:	6d2e                	ld	s10,200(sp)
    80006ae6:	6dce                	ld	s11,208(sp)
    80006ae8:	6e6e                	ld	t3,216(sp)
    80006aea:	7e8e                	ld	t4,224(sp)
    80006aec:	7f2e                	ld	t5,232(sp)
    80006aee:	7fce                	ld	t6,240(sp)
    80006af0:	6111                	addi	sp,sp,256
    80006af2:	10200073          	sret
    80006af6:	00000013          	nop
    80006afa:	00000013          	nop
    80006afe:	0001                	nop

0000000080006b00 <timervec>:
    80006b00:	34051573          	csrrw	a0,mscratch,a0
    80006b04:	e10c                	sd	a1,0(a0)
    80006b06:	e510                	sd	a2,8(a0)
    80006b08:	e914                	sd	a3,16(a0)
    80006b0a:	6d0c                	ld	a1,24(a0)
    80006b0c:	7110                	ld	a2,32(a0)
    80006b0e:	6194                	ld	a3,0(a1)
    80006b10:	96b2                	add	a3,a3,a2
    80006b12:	e194                	sd	a3,0(a1)
    80006b14:	4589                	li	a1,2
    80006b16:	14459073          	csrw	sip,a1
    80006b1a:	6914                	ld	a3,16(a0)
    80006b1c:	6510                	ld	a2,8(a0)
    80006b1e:	610c                	ld	a1,0(a0)
    80006b20:	34051573          	csrrw	a0,mscratch,a0
    80006b24:	30200073          	mret
	...

0000000080006b2a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006b2a:	1141                	addi	sp,sp,-16
    80006b2c:	e422                	sd	s0,8(sp)
    80006b2e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006b30:	0c0007b7          	lui	a5,0xc000
    80006b34:	4705                	li	a4,1
    80006b36:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006b38:	c3d8                	sw	a4,4(a5)
}
    80006b3a:	6422                	ld	s0,8(sp)
    80006b3c:	0141                	addi	sp,sp,16
    80006b3e:	8082                	ret

0000000080006b40 <plicinithart>:

void
plicinithart(void)
{
    80006b40:	1141                	addi	sp,sp,-16
    80006b42:	e406                	sd	ra,8(sp)
    80006b44:	e022                	sd	s0,0(sp)
    80006b46:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006b48:	ffffb097          	auipc	ra,0xffffb
    80006b4c:	1c0080e7          	jalr	448(ra) # 80001d08 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006b50:	0085171b          	slliw	a4,a0,0x8
    80006b54:	0c0027b7          	lui	a5,0xc002
    80006b58:	97ba                	add	a5,a5,a4
    80006b5a:	40200713          	li	a4,1026
    80006b5e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006b62:	00d5151b          	slliw	a0,a0,0xd
    80006b66:	0c2017b7          	lui	a5,0xc201
    80006b6a:	953e                	add	a0,a0,a5
    80006b6c:	00052023          	sw	zero,0(a0)
}
    80006b70:	60a2                	ld	ra,8(sp)
    80006b72:	6402                	ld	s0,0(sp)
    80006b74:	0141                	addi	sp,sp,16
    80006b76:	8082                	ret

0000000080006b78 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006b78:	1141                	addi	sp,sp,-16
    80006b7a:	e406                	sd	ra,8(sp)
    80006b7c:	e022                	sd	s0,0(sp)
    80006b7e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006b80:	ffffb097          	auipc	ra,0xffffb
    80006b84:	188080e7          	jalr	392(ra) # 80001d08 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006b88:	00d5179b          	slliw	a5,a0,0xd
    80006b8c:	0c201537          	lui	a0,0xc201
    80006b90:	953e                	add	a0,a0,a5
  return irq;
}
    80006b92:	4148                	lw	a0,4(a0)
    80006b94:	60a2                	ld	ra,8(sp)
    80006b96:	6402                	ld	s0,0(sp)
    80006b98:	0141                	addi	sp,sp,16
    80006b9a:	8082                	ret

0000000080006b9c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006b9c:	1101                	addi	sp,sp,-32
    80006b9e:	ec06                	sd	ra,24(sp)
    80006ba0:	e822                	sd	s0,16(sp)
    80006ba2:	e426                	sd	s1,8(sp)
    80006ba4:	1000                	addi	s0,sp,32
    80006ba6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006ba8:	ffffb097          	auipc	ra,0xffffb
    80006bac:	160080e7          	jalr	352(ra) # 80001d08 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006bb0:	00d5151b          	slliw	a0,a0,0xd
    80006bb4:	0c2017b7          	lui	a5,0xc201
    80006bb8:	97aa                	add	a5,a5,a0
    80006bba:	c3c4                	sw	s1,4(a5)
}
    80006bbc:	60e2                	ld	ra,24(sp)
    80006bbe:	6442                	ld	s0,16(sp)
    80006bc0:	64a2                	ld	s1,8(sp)
    80006bc2:	6105                	addi	sp,sp,32
    80006bc4:	8082                	ret

0000000080006bc6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006bc6:	1141                	addi	sp,sp,-16
    80006bc8:	e406                	sd	ra,8(sp)
    80006bca:	e022                	sd	s0,0(sp)
    80006bcc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006bce:	479d                	li	a5,7
    80006bd0:	06a7c963          	blt	a5,a0,80006c42 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006bd4:	00029797          	auipc	a5,0x29
    80006bd8:	42c78793          	addi	a5,a5,1068 # 80030000 <disk>
    80006bdc:	00a78733          	add	a4,a5,a0
    80006be0:	6789                	lui	a5,0x2
    80006be2:	97ba                	add	a5,a5,a4
    80006be4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006be8:	e7ad                	bnez	a5,80006c52 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006bea:	00451793          	slli	a5,a0,0x4
    80006bee:	0002b717          	auipc	a4,0x2b
    80006bf2:	41270713          	addi	a4,a4,1042 # 80032000 <disk+0x2000>
    80006bf6:	6314                	ld	a3,0(a4)
    80006bf8:	96be                	add	a3,a3,a5
    80006bfa:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006bfe:	6314                	ld	a3,0(a4)
    80006c00:	96be                	add	a3,a3,a5
    80006c02:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006c06:	6314                	ld	a3,0(a4)
    80006c08:	96be                	add	a3,a3,a5
    80006c0a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006c0e:	6318                	ld	a4,0(a4)
    80006c10:	97ba                	add	a5,a5,a4
    80006c12:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006c16:	00029797          	auipc	a5,0x29
    80006c1a:	3ea78793          	addi	a5,a5,1002 # 80030000 <disk>
    80006c1e:	97aa                	add	a5,a5,a0
    80006c20:	6509                	lui	a0,0x2
    80006c22:	953e                	add	a0,a0,a5
    80006c24:	4785                	li	a5,1
    80006c26:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006c2a:	0002b517          	auipc	a0,0x2b
    80006c2e:	3ee50513          	addi	a0,a0,1006 # 80032018 <disk+0x2018>
    80006c32:	ffffb097          	auipc	ra,0xffffb
    80006c36:	786080e7          	jalr	1926(ra) # 800023b8 <wakeup>
}
    80006c3a:	60a2                	ld	ra,8(sp)
    80006c3c:	6402                	ld	s0,0(sp)
    80006c3e:	0141                	addi	sp,sp,16
    80006c40:	8082                	ret
    panic("free_desc 1");
    80006c42:	00003517          	auipc	a0,0x3
    80006c46:	01650513          	addi	a0,a0,22 # 80009c58 <syscalls+0x358>
    80006c4a:	ffffa097          	auipc	ra,0xffffa
    80006c4e:	8e0080e7          	jalr	-1824(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006c52:	00003517          	auipc	a0,0x3
    80006c56:	01650513          	addi	a0,a0,22 # 80009c68 <syscalls+0x368>
    80006c5a:	ffffa097          	auipc	ra,0xffffa
    80006c5e:	8d0080e7          	jalr	-1840(ra) # 8000052a <panic>

0000000080006c62 <virtio_disk_init>:
{
    80006c62:	1101                	addi	sp,sp,-32
    80006c64:	ec06                	sd	ra,24(sp)
    80006c66:	e822                	sd	s0,16(sp)
    80006c68:	e426                	sd	s1,8(sp)
    80006c6a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006c6c:	00003597          	auipc	a1,0x3
    80006c70:	00c58593          	addi	a1,a1,12 # 80009c78 <syscalls+0x378>
    80006c74:	0002b517          	auipc	a0,0x2b
    80006c78:	4b450513          	addi	a0,a0,1204 # 80032128 <disk+0x2128>
    80006c7c:	ffffa097          	auipc	ra,0xffffa
    80006c80:	eb6080e7          	jalr	-330(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006c84:	100017b7          	lui	a5,0x10001
    80006c88:	4398                	lw	a4,0(a5)
    80006c8a:	2701                	sext.w	a4,a4
    80006c8c:	747277b7          	lui	a5,0x74727
    80006c90:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006c94:	0ef71163          	bne	a4,a5,80006d76 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006c98:	100017b7          	lui	a5,0x10001
    80006c9c:	43dc                	lw	a5,4(a5)
    80006c9e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006ca0:	4705                	li	a4,1
    80006ca2:	0ce79a63          	bne	a5,a4,80006d76 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006ca6:	100017b7          	lui	a5,0x10001
    80006caa:	479c                	lw	a5,8(a5)
    80006cac:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006cae:	4709                	li	a4,2
    80006cb0:	0ce79363          	bne	a5,a4,80006d76 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006cb4:	100017b7          	lui	a5,0x10001
    80006cb8:	47d8                	lw	a4,12(a5)
    80006cba:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006cbc:	554d47b7          	lui	a5,0x554d4
    80006cc0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006cc4:	0af71963          	bne	a4,a5,80006d76 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006cc8:	100017b7          	lui	a5,0x10001
    80006ccc:	4705                	li	a4,1
    80006cce:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006cd0:	470d                	li	a4,3
    80006cd2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006cd4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006cd6:	c7ffe737          	lui	a4,0xc7ffe
    80006cda:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fcb75f>
    80006cde:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006ce0:	2701                	sext.w	a4,a4
    80006ce2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006ce4:	472d                	li	a4,11
    80006ce6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006ce8:	473d                	li	a4,15
    80006cea:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006cec:	6705                	lui	a4,0x1
    80006cee:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006cf0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006cf4:	5bdc                	lw	a5,52(a5)
    80006cf6:	2781                	sext.w	a5,a5
  if(max == 0)
    80006cf8:	c7d9                	beqz	a5,80006d86 <virtio_disk_init+0x124>
  if(max < NUM)
    80006cfa:	471d                	li	a4,7
    80006cfc:	08f77d63          	bgeu	a4,a5,80006d96 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006d00:	100014b7          	lui	s1,0x10001
    80006d04:	47a1                	li	a5,8
    80006d06:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006d08:	6609                	lui	a2,0x2
    80006d0a:	4581                	li	a1,0
    80006d0c:	00029517          	auipc	a0,0x29
    80006d10:	2f450513          	addi	a0,a0,756 # 80030000 <disk>
    80006d14:	ffffa097          	auipc	ra,0xffffa
    80006d18:	faa080e7          	jalr	-86(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006d1c:	00029717          	auipc	a4,0x29
    80006d20:	2e470713          	addi	a4,a4,740 # 80030000 <disk>
    80006d24:	00c75793          	srli	a5,a4,0xc
    80006d28:	2781                	sext.w	a5,a5
    80006d2a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006d2c:	0002b797          	auipc	a5,0x2b
    80006d30:	2d478793          	addi	a5,a5,724 # 80032000 <disk+0x2000>
    80006d34:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006d36:	00029717          	auipc	a4,0x29
    80006d3a:	34a70713          	addi	a4,a4,842 # 80030080 <disk+0x80>
    80006d3e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006d40:	0002a717          	auipc	a4,0x2a
    80006d44:	2c070713          	addi	a4,a4,704 # 80031000 <disk+0x1000>
    80006d48:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006d4a:	4705                	li	a4,1
    80006d4c:	00e78c23          	sb	a4,24(a5)
    80006d50:	00e78ca3          	sb	a4,25(a5)
    80006d54:	00e78d23          	sb	a4,26(a5)
    80006d58:	00e78da3          	sb	a4,27(a5)
    80006d5c:	00e78e23          	sb	a4,28(a5)
    80006d60:	00e78ea3          	sb	a4,29(a5)
    80006d64:	00e78f23          	sb	a4,30(a5)
    80006d68:	00e78fa3          	sb	a4,31(a5)
}
    80006d6c:	60e2                	ld	ra,24(sp)
    80006d6e:	6442                	ld	s0,16(sp)
    80006d70:	64a2                	ld	s1,8(sp)
    80006d72:	6105                	addi	sp,sp,32
    80006d74:	8082                	ret
    panic("could not find virtio disk");
    80006d76:	00003517          	auipc	a0,0x3
    80006d7a:	f1250513          	addi	a0,a0,-238 # 80009c88 <syscalls+0x388>
    80006d7e:	ffff9097          	auipc	ra,0xffff9
    80006d82:	7ac080e7          	jalr	1964(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006d86:	00003517          	auipc	a0,0x3
    80006d8a:	f2250513          	addi	a0,a0,-222 # 80009ca8 <syscalls+0x3a8>
    80006d8e:	ffff9097          	auipc	ra,0xffff9
    80006d92:	79c080e7          	jalr	1948(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006d96:	00003517          	auipc	a0,0x3
    80006d9a:	f3250513          	addi	a0,a0,-206 # 80009cc8 <syscalls+0x3c8>
    80006d9e:	ffff9097          	auipc	ra,0xffff9
    80006da2:	78c080e7          	jalr	1932(ra) # 8000052a <panic>

0000000080006da6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006da6:	7119                	addi	sp,sp,-128
    80006da8:	fc86                	sd	ra,120(sp)
    80006daa:	f8a2                	sd	s0,112(sp)
    80006dac:	f4a6                	sd	s1,104(sp)
    80006dae:	f0ca                	sd	s2,96(sp)
    80006db0:	ecce                	sd	s3,88(sp)
    80006db2:	e8d2                	sd	s4,80(sp)
    80006db4:	e4d6                	sd	s5,72(sp)
    80006db6:	e0da                	sd	s6,64(sp)
    80006db8:	fc5e                	sd	s7,56(sp)
    80006dba:	f862                	sd	s8,48(sp)
    80006dbc:	f466                	sd	s9,40(sp)
    80006dbe:	f06a                	sd	s10,32(sp)
    80006dc0:	ec6e                	sd	s11,24(sp)
    80006dc2:	0100                	addi	s0,sp,128
    80006dc4:	8aaa                	mv	s5,a0
    80006dc6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006dc8:	00c52c83          	lw	s9,12(a0)
    80006dcc:	001c9c9b          	slliw	s9,s9,0x1
    80006dd0:	1c82                	slli	s9,s9,0x20
    80006dd2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006dd6:	0002b517          	auipc	a0,0x2b
    80006dda:	35250513          	addi	a0,a0,850 # 80032128 <disk+0x2128>
    80006dde:	ffffa097          	auipc	ra,0xffffa
    80006de2:	de4080e7          	jalr	-540(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006de6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006de8:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006dea:	00029c17          	auipc	s8,0x29
    80006dee:	216c0c13          	addi	s8,s8,534 # 80030000 <disk>
    80006df2:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006df4:	4b0d                	li	s6,3
    80006df6:	a0ad                	j	80006e60 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006df8:	00fc0733          	add	a4,s8,a5
    80006dfc:	975e                	add	a4,a4,s7
    80006dfe:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006e02:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006e04:	0207c563          	bltz	a5,80006e2e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006e08:	2905                	addiw	s2,s2,1
    80006e0a:	0611                	addi	a2,a2,4
    80006e0c:	19690d63          	beq	s2,s6,80006fa6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006e10:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006e12:	0002b717          	auipc	a4,0x2b
    80006e16:	20670713          	addi	a4,a4,518 # 80032018 <disk+0x2018>
    80006e1a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006e1c:	00074683          	lbu	a3,0(a4)
    80006e20:	fee1                	bnez	a3,80006df8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006e22:	2785                	addiw	a5,a5,1
    80006e24:	0705                	addi	a4,a4,1
    80006e26:	fe979be3          	bne	a5,s1,80006e1c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006e2a:	57fd                	li	a5,-1
    80006e2c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006e2e:	01205d63          	blez	s2,80006e48 <virtio_disk_rw+0xa2>
    80006e32:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006e34:	000a2503          	lw	a0,0(s4)
    80006e38:	00000097          	auipc	ra,0x0
    80006e3c:	d8e080e7          	jalr	-626(ra) # 80006bc6 <free_desc>
      for(int j = 0; j < i; j++)
    80006e40:	2d85                	addiw	s11,s11,1
    80006e42:	0a11                	addi	s4,s4,4
    80006e44:	ffb918e3          	bne	s2,s11,80006e34 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006e48:	0002b597          	auipc	a1,0x2b
    80006e4c:	2e058593          	addi	a1,a1,736 # 80032128 <disk+0x2128>
    80006e50:	0002b517          	auipc	a0,0x2b
    80006e54:	1c850513          	addi	a0,a0,456 # 80032018 <disk+0x2018>
    80006e58:	ffffb097          	auipc	ra,0xffffb
    80006e5c:	3d4080e7          	jalr	980(ra) # 8000222c <sleep>
  for(int i = 0; i < 3; i++){
    80006e60:	f8040a13          	addi	s4,s0,-128
{
    80006e64:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006e66:	894e                	mv	s2,s3
    80006e68:	b765                	j	80006e10 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006e6a:	0002b697          	auipc	a3,0x2b
    80006e6e:	1966b683          	ld	a3,406(a3) # 80032000 <disk+0x2000>
    80006e72:	96ba                	add	a3,a3,a4
    80006e74:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006e78:	00029817          	auipc	a6,0x29
    80006e7c:	18880813          	addi	a6,a6,392 # 80030000 <disk>
    80006e80:	0002b697          	auipc	a3,0x2b
    80006e84:	18068693          	addi	a3,a3,384 # 80032000 <disk+0x2000>
    80006e88:	6290                	ld	a2,0(a3)
    80006e8a:	963a                	add	a2,a2,a4
    80006e8c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006e90:	0015e593          	ori	a1,a1,1
    80006e94:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006e98:	f8842603          	lw	a2,-120(s0)
    80006e9c:	628c                	ld	a1,0(a3)
    80006e9e:	972e                	add	a4,a4,a1
    80006ea0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006ea4:	20050593          	addi	a1,a0,512
    80006ea8:	0592                	slli	a1,a1,0x4
    80006eaa:	95c2                	add	a1,a1,a6
    80006eac:	577d                	li	a4,-1
    80006eae:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006eb2:	00461713          	slli	a4,a2,0x4
    80006eb6:	6290                	ld	a2,0(a3)
    80006eb8:	963a                	add	a2,a2,a4
    80006eba:	03078793          	addi	a5,a5,48
    80006ebe:	97c2                	add	a5,a5,a6
    80006ec0:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006ec2:	629c                	ld	a5,0(a3)
    80006ec4:	97ba                	add	a5,a5,a4
    80006ec6:	4605                	li	a2,1
    80006ec8:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006eca:	629c                	ld	a5,0(a3)
    80006ecc:	97ba                	add	a5,a5,a4
    80006ece:	4809                	li	a6,2
    80006ed0:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006ed4:	629c                	ld	a5,0(a3)
    80006ed6:	973e                	add	a4,a4,a5
    80006ed8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006edc:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006ee0:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006ee4:	6698                	ld	a4,8(a3)
    80006ee6:	00275783          	lhu	a5,2(a4)
    80006eea:	8b9d                	andi	a5,a5,7
    80006eec:	0786                	slli	a5,a5,0x1
    80006eee:	97ba                	add	a5,a5,a4
    80006ef0:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006ef4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006ef8:	6698                	ld	a4,8(a3)
    80006efa:	00275783          	lhu	a5,2(a4)
    80006efe:	2785                	addiw	a5,a5,1
    80006f00:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006f04:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006f08:	100017b7          	lui	a5,0x10001
    80006f0c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006f10:	004aa783          	lw	a5,4(s5)
    80006f14:	02c79163          	bne	a5,a2,80006f36 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006f18:	0002b917          	auipc	s2,0x2b
    80006f1c:	21090913          	addi	s2,s2,528 # 80032128 <disk+0x2128>
  while(b->disk == 1) {
    80006f20:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006f22:	85ca                	mv	a1,s2
    80006f24:	8556                	mv	a0,s5
    80006f26:	ffffb097          	auipc	ra,0xffffb
    80006f2a:	306080e7          	jalr	774(ra) # 8000222c <sleep>
  while(b->disk == 1) {
    80006f2e:	004aa783          	lw	a5,4(s5)
    80006f32:	fe9788e3          	beq	a5,s1,80006f22 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006f36:	f8042903          	lw	s2,-128(s0)
    80006f3a:	20090793          	addi	a5,s2,512
    80006f3e:	00479713          	slli	a4,a5,0x4
    80006f42:	00029797          	auipc	a5,0x29
    80006f46:	0be78793          	addi	a5,a5,190 # 80030000 <disk>
    80006f4a:	97ba                	add	a5,a5,a4
    80006f4c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006f50:	0002b997          	auipc	s3,0x2b
    80006f54:	0b098993          	addi	s3,s3,176 # 80032000 <disk+0x2000>
    80006f58:	00491713          	slli	a4,s2,0x4
    80006f5c:	0009b783          	ld	a5,0(s3)
    80006f60:	97ba                	add	a5,a5,a4
    80006f62:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006f66:	854a                	mv	a0,s2
    80006f68:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006f6c:	00000097          	auipc	ra,0x0
    80006f70:	c5a080e7          	jalr	-934(ra) # 80006bc6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006f74:	8885                	andi	s1,s1,1
    80006f76:	f0ed                	bnez	s1,80006f58 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006f78:	0002b517          	auipc	a0,0x2b
    80006f7c:	1b050513          	addi	a0,a0,432 # 80032128 <disk+0x2128>
    80006f80:	ffffa097          	auipc	ra,0xffffa
    80006f84:	cf6080e7          	jalr	-778(ra) # 80000c76 <release>
}
    80006f88:	70e6                	ld	ra,120(sp)
    80006f8a:	7446                	ld	s0,112(sp)
    80006f8c:	74a6                	ld	s1,104(sp)
    80006f8e:	7906                	ld	s2,96(sp)
    80006f90:	69e6                	ld	s3,88(sp)
    80006f92:	6a46                	ld	s4,80(sp)
    80006f94:	6aa6                	ld	s5,72(sp)
    80006f96:	6b06                	ld	s6,64(sp)
    80006f98:	7be2                	ld	s7,56(sp)
    80006f9a:	7c42                	ld	s8,48(sp)
    80006f9c:	7ca2                	ld	s9,40(sp)
    80006f9e:	7d02                	ld	s10,32(sp)
    80006fa0:	6de2                	ld	s11,24(sp)
    80006fa2:	6109                	addi	sp,sp,128
    80006fa4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006fa6:	f8042503          	lw	a0,-128(s0)
    80006faa:	20050793          	addi	a5,a0,512
    80006fae:	0792                	slli	a5,a5,0x4
  if(write)
    80006fb0:	00029817          	auipc	a6,0x29
    80006fb4:	05080813          	addi	a6,a6,80 # 80030000 <disk>
    80006fb8:	00f80733          	add	a4,a6,a5
    80006fbc:	01a036b3          	snez	a3,s10
    80006fc0:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006fc4:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006fc8:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006fcc:	7679                	lui	a2,0xffffe
    80006fce:	963e                	add	a2,a2,a5
    80006fd0:	0002b697          	auipc	a3,0x2b
    80006fd4:	03068693          	addi	a3,a3,48 # 80032000 <disk+0x2000>
    80006fd8:	6298                	ld	a4,0(a3)
    80006fda:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006fdc:	0a878593          	addi	a1,a5,168
    80006fe0:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006fe2:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006fe4:	6298                	ld	a4,0(a3)
    80006fe6:	9732                	add	a4,a4,a2
    80006fe8:	45c1                	li	a1,16
    80006fea:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006fec:	6298                	ld	a4,0(a3)
    80006fee:	9732                	add	a4,a4,a2
    80006ff0:	4585                	li	a1,1
    80006ff2:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006ff6:	f8442703          	lw	a4,-124(s0)
    80006ffa:	628c                	ld	a1,0(a3)
    80006ffc:	962e                	add	a2,a2,a1
    80006ffe:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffcb00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80007002:	0712                	slli	a4,a4,0x4
    80007004:	6290                	ld	a2,0(a3)
    80007006:	963a                	add	a2,a2,a4
    80007008:	058a8593          	addi	a1,s5,88
    8000700c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000700e:	6294                	ld	a3,0(a3)
    80007010:	96ba                	add	a3,a3,a4
    80007012:	40000613          	li	a2,1024
    80007016:	c690                	sw	a2,8(a3)
  if(write)
    80007018:	e40d19e3          	bnez	s10,80006e6a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000701c:	0002b697          	auipc	a3,0x2b
    80007020:	fe46b683          	ld	a3,-28(a3) # 80032000 <disk+0x2000>
    80007024:	96ba                	add	a3,a3,a4
    80007026:	4609                	li	a2,2
    80007028:	00c69623          	sh	a2,12(a3)
    8000702c:	b5b1                	j	80006e78 <virtio_disk_rw+0xd2>

000000008000702e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000702e:	1101                	addi	sp,sp,-32
    80007030:	ec06                	sd	ra,24(sp)
    80007032:	e822                	sd	s0,16(sp)
    80007034:	e426                	sd	s1,8(sp)
    80007036:	e04a                	sd	s2,0(sp)
    80007038:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000703a:	0002b517          	auipc	a0,0x2b
    8000703e:	0ee50513          	addi	a0,a0,238 # 80032128 <disk+0x2128>
    80007042:	ffffa097          	auipc	ra,0xffffa
    80007046:	b80080e7          	jalr	-1152(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000704a:	10001737          	lui	a4,0x10001
    8000704e:	533c                	lw	a5,96(a4)
    80007050:	8b8d                	andi	a5,a5,3
    80007052:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80007054:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80007058:	0002b797          	auipc	a5,0x2b
    8000705c:	fa878793          	addi	a5,a5,-88 # 80032000 <disk+0x2000>
    80007060:	6b94                	ld	a3,16(a5)
    80007062:	0207d703          	lhu	a4,32(a5)
    80007066:	0026d783          	lhu	a5,2(a3)
    8000706a:	06f70163          	beq	a4,a5,800070cc <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000706e:	00029917          	auipc	s2,0x29
    80007072:	f9290913          	addi	s2,s2,-110 # 80030000 <disk>
    80007076:	0002b497          	auipc	s1,0x2b
    8000707a:	f8a48493          	addi	s1,s1,-118 # 80032000 <disk+0x2000>
    __sync_synchronize();
    8000707e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007082:	6898                	ld	a4,16(s1)
    80007084:	0204d783          	lhu	a5,32(s1)
    80007088:	8b9d                	andi	a5,a5,7
    8000708a:	078e                	slli	a5,a5,0x3
    8000708c:	97ba                	add	a5,a5,a4
    8000708e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80007090:	20078713          	addi	a4,a5,512
    80007094:	0712                	slli	a4,a4,0x4
    80007096:	974a                	add	a4,a4,s2
    80007098:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000709c:	e731                	bnez	a4,800070e8 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000709e:	20078793          	addi	a5,a5,512
    800070a2:	0792                	slli	a5,a5,0x4
    800070a4:	97ca                	add	a5,a5,s2
    800070a6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800070a8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800070ac:	ffffb097          	auipc	ra,0xffffb
    800070b0:	30c080e7          	jalr	780(ra) # 800023b8 <wakeup>

    disk.used_idx += 1;
    800070b4:	0204d783          	lhu	a5,32(s1)
    800070b8:	2785                	addiw	a5,a5,1
    800070ba:	17c2                	slli	a5,a5,0x30
    800070bc:	93c1                	srli	a5,a5,0x30
    800070be:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800070c2:	6898                	ld	a4,16(s1)
    800070c4:	00275703          	lhu	a4,2(a4)
    800070c8:	faf71be3          	bne	a4,a5,8000707e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800070cc:	0002b517          	auipc	a0,0x2b
    800070d0:	05c50513          	addi	a0,a0,92 # 80032128 <disk+0x2128>
    800070d4:	ffffa097          	auipc	ra,0xffffa
    800070d8:	ba2080e7          	jalr	-1118(ra) # 80000c76 <release>
}
    800070dc:	60e2                	ld	ra,24(sp)
    800070de:	6442                	ld	s0,16(sp)
    800070e0:	64a2                	ld	s1,8(sp)
    800070e2:	6902                	ld	s2,0(sp)
    800070e4:	6105                	addi	sp,sp,32
    800070e6:	8082                	ret
      panic("virtio_disk_intr status");
    800070e8:	00003517          	auipc	a0,0x3
    800070ec:	c0050513          	addi	a0,a0,-1024 # 80009ce8 <syscalls+0x3e8>
    800070f0:	ffff9097          	auipc	ra,0xffff9
    800070f4:	43a080e7          	jalr	1082(ra) # 8000052a <panic>
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
