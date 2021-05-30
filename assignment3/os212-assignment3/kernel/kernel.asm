
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
    80000122:	4ee080e7          	jalr	1262(ra) # 8000260c <either_copyin>
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
    800001b6:	b5e080e7          	jalr	-1186(ra) # 80001d10 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	046080e7          	jalr	70(ra) # 80002208 <sleep>
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
    80000202:	3b8080e7          	jalr	952(ra) # 800025b6 <either_copyout>
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
    800002e2:	384080e7          	jalr	900(ra) # 80002662 <procdump>
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
    80000436:	f62080e7          	jalr	-158(ra) # 80002394 <wakeup>
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
    80000882:	b16080e7          	jalr	-1258(ra) # 80002394 <wakeup>
    
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
    8000090e:	8fe080e7          	jalr	-1794(ra) # 80002208 <sleep>
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
    80000b60:	198080e7          	jalr	408(ra) # 80001cf4 <mycpu>
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
    80000b92:	166080e7          	jalr	358(ra) # 80001cf4 <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	15a080e7          	jalr	346(ra) # 80001cf4 <mycpu>
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
    80000bb6:	142080e7          	jalr	322(ra) # 80001cf4 <mycpu>
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
    80000bf6:	102080e7          	jalr	258(ra) # 80001cf4 <mycpu>
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
    80000c22:	0d6080e7          	jalr	214(ra) # 80001cf4 <mycpu>
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
    80000e78:	e70080e7          	jalr	-400(ra) # 80001ce4 <cpuid>
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
    80000e94:	e54080e7          	jalr	-428(ra) # 80001ce4 <cpuid>
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
    80000eb6:	0da080e7          	jalr	218(ra) # 80002f8c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00006097          	auipc	ra,0x6
    80000ebe:	c86080e7          	jalr	-890(ra) # 80006b40 <plicinithart>
  }

  scheduler();        
    80000ec2:	00002097          	auipc	ra,0x2
    80000ec6:	e7c080e7          	jalr	-388(ra) # 80002d3e <scheduler>
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
    80000f16:	324080e7          	jalr	804(ra) # 80001236 <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	068080e7          	jalr	104(ra) # 80000f82 <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	d12080e7          	jalr	-750(ra) # 80001c34 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	03a080e7          	jalr	58(ra) # 80002f64 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	05a080e7          	jalr	90(ra) # 80002f8c <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00006097          	auipc	ra,0x6
    80000f3e:	bf0080e7          	jalr	-1040(ra) # 80006b2a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00006097          	auipc	ra,0x6
    80000f46:	bfe080e7          	jalr	-1026(ra) # 80006b40 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00003097          	auipc	ra,0x3
    80000f4e:	88a080e7          	jalr	-1910(ra) # 800037d4 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	f1c080e7          	jalr	-228(ra) # 80003e6e <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	1dc080e7          	jalr	476(ra) # 80005136 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00006097          	auipc	ra,0x6
    80000f66:	d00080e7          	jalr	-768(ra) # 80006c62 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	096080e7          	jalr	150(ra) # 80002000 <userinit>
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
    80001224:	97e080e7          	jalr	-1666(ra) # 80001b9e <proc_mapstacks>
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
    80001578:	79c080e7          	jalr	1948(ra) # 80001d10 <myproc>
    8000157c:	84aa                	mv	s1,a0
  int free_index = get_next_free_space(p->pages_swap_info.free_spaces);
    8000157e:	17855503          	lhu	a0,376(a0)
    80001582:	00001097          	auipc	ra,0x1
    80001586:	190080e7          	jalr	400(ra) # 80002712 <get_next_free_space>
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
    800015fa:	71a080e7          	jalr	1818(ra) # 80001d10 <myproc>
    800015fe:	892a                	mv	s2,a0
  int free_index = get_next_free_space(p->pages_physc_info.free_spaces);
    80001600:	30055503          	lhu	a0,768(a0)
    80001604:	00001097          	auipc	ra,0x1
    80001608:	10e080e7          	jalr	270(ra) # 80002712 <get_next_free_space>
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
    80001644:	7b0080e7          	jalr	1968(ra) # 80002df0 <reset_aging_counter>

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
    800016a2:	672080e7          	jalr	1650(ra) # 80001d10 <myproc>
    800016a6:	84aa                	mv	s1,a0
  int index = get_index_in_page_info_array(a, p->pages_physc_info.pages);
    800016a8:	30850593          	addi	a1,a0,776
    800016ac:	854a                	mv	a0,s2
    800016ae:	00001097          	auipc	ra,0x1
    800016b2:	090080e7          	jalr	144(ra) # 8000273e <get_index_in_page_info_array>
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
    8000170a:	60a080e7          	jalr	1546(ra) # 80001d10 <myproc>
    8000170e:	84aa                	mv	s1,a0
  int index = get_index_in_page_info_array(a, p->pages_swap_info.pages);
    80001710:	18050593          	addi	a1,a0,384
    80001714:	854a                	mv	a0,s2
    80001716:	00001097          	auipc	ra,0x1
    8000171a:	028080e7          	jalr	40(ra) # 8000273e <get_index_in_page_info_array>
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
    80001786:	58e080e7          	jalr	1422(ra) # 80001d10 <myproc>
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
    80001874:	4a0080e7          	jalr	1184(ra) # 80001d10 <myproc>
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
    80001898:	47c080e7          	jalr	1148(ra) # 80001d10 <myproc>
    8000189c:	17052783          	lw	a5,368(a0)
    800018a0:	37fd                	addiw	a5,a5,-1
    800018a2:	16f52823          	sw	a5,368(a0)
          myproc()->total_pages_num--;
    800018a6:	00000097          	auipc	ra,0x0
    800018aa:	46a080e7          	jalr	1130(ra) # 80001d10 <myproc>
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
    80001926:	3ee080e7          	jalr	1006(ra) # 80001d10 <myproc>
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
    800019d0:	4d4080e7          	jalr	1236(ra) # 80002ea0 <get_next_page_to_swap_out>
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
    800019ee:	d78080e7          	jalr	-648(ra) # 80002762 <page_out>
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

0000000080001b9e <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001b9e:	7139                	addi	sp,sp,-64
    80001ba0:	fc06                	sd	ra,56(sp)
    80001ba2:	f822                	sd	s0,48(sp)
    80001ba4:	f426                	sd	s1,40(sp)
    80001ba6:	f04a                	sd	s2,32(sp)
    80001ba8:	ec4e                	sd	s3,24(sp)
    80001baa:	e852                	sd	s4,16(sp)
    80001bac:	e456                	sd	s5,8(sp)
    80001bae:	e05a                	sd	s6,0(sp)
    80001bb0:	0080                	addi	s0,sp,64
    80001bb2:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80001bb4:	00011497          	auipc	s1,0x11
    80001bb8:	b1c48493          	addi	s1,s1,-1252 # 800126d0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001bbc:	8b26                	mv	s6,s1
    80001bbe:	00007a97          	auipc	s5,0x7
    80001bc2:	442a8a93          	addi	s5,s5,1090 # 80009000 <etext>
    80001bc6:	04000937          	lui	s2,0x4000
    80001bca:	197d                	addi	s2,s2,-1
    80001bcc:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001bce:	00023a17          	auipc	s4,0x23
    80001bd2:	f02a0a13          	addi	s4,s4,-254 # 80024ad0 <tickslock>
    char *pa = kalloc();
    80001bd6:	fffff097          	auipc	ra,0xfffff
    80001bda:	efc080e7          	jalr	-260(ra) # 80000ad2 <kalloc>
    80001bde:	862a                	mv	a2,a0
    if (pa == 0)
    80001be0:	c131                	beqz	a0,80001c24 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001be2:	416485b3          	sub	a1,s1,s6
    80001be6:	8591                	srai	a1,a1,0x4
    80001be8:	000ab783          	ld	a5,0(s5)
    80001bec:	02f585b3          	mul	a1,a1,a5
    80001bf0:	2585                	addiw	a1,a1,1
    80001bf2:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001bf6:	4719                	li	a4,6
    80001bf8:	6685                	lui	a3,0x1
    80001bfa:	40b905b3          	sub	a1,s2,a1
    80001bfe:	854e                	mv	a0,s3
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	530080e7          	jalr	1328(ra) # 80001130 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c08:	49048493          	addi	s1,s1,1168
    80001c0c:	fd4495e3          	bne	s1,s4,80001bd6 <proc_mapstacks+0x38>
  }
}
    80001c10:	70e2                	ld	ra,56(sp)
    80001c12:	7442                	ld	s0,48(sp)
    80001c14:	74a2                	ld	s1,40(sp)
    80001c16:	7902                	ld	s2,32(sp)
    80001c18:	69e2                	ld	s3,24(sp)
    80001c1a:	6a42                	ld	s4,16(sp)
    80001c1c:	6aa2                	ld	s5,8(sp)
    80001c1e:	6b02                	ld	s6,0(sp)
    80001c20:	6121                	addi	sp,sp,64
    80001c22:	8082                	ret
      panic("kalloc");
    80001c24:	00007517          	auipc	a0,0x7
    80001c28:	7a450513          	addi	a0,a0,1956 # 800093c8 <digits+0x388>
    80001c2c:	fffff097          	auipc	ra,0xfffff
    80001c30:	8fe080e7          	jalr	-1794(ra) # 8000052a <panic>

0000000080001c34 <procinit>:

// initialize the proc table at boot time.
void procinit(void)
{
    80001c34:	7139                	addi	sp,sp,-64
    80001c36:	fc06                	sd	ra,56(sp)
    80001c38:	f822                	sd	s0,48(sp)
    80001c3a:	f426                	sd	s1,40(sp)
    80001c3c:	f04a                	sd	s2,32(sp)
    80001c3e:	ec4e                	sd	s3,24(sp)
    80001c40:	e852                	sd	s4,16(sp)
    80001c42:	e456                	sd	s5,8(sp)
    80001c44:	e05a                	sd	s6,0(sp)
    80001c46:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001c48:	00007597          	auipc	a1,0x7
    80001c4c:	78858593          	addi	a1,a1,1928 # 800093d0 <digits+0x390>
    80001c50:	00010517          	auipc	a0,0x10
    80001c54:	65050513          	addi	a0,a0,1616 # 800122a0 <pid_lock>
    80001c58:	fffff097          	auipc	ra,0xfffff
    80001c5c:	eda080e7          	jalr	-294(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001c60:	00007597          	auipc	a1,0x7
    80001c64:	77858593          	addi	a1,a1,1912 # 800093d8 <digits+0x398>
    80001c68:	00010517          	auipc	a0,0x10
    80001c6c:	65050513          	addi	a0,a0,1616 # 800122b8 <wait_lock>
    80001c70:	fffff097          	auipc	ra,0xfffff
    80001c74:	ec2080e7          	jalr	-318(ra) # 80000b32 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c78:	00011497          	auipc	s1,0x11
    80001c7c:	a5848493          	addi	s1,s1,-1448 # 800126d0 <proc>
  {
    initlock(&p->lock, "proc");
    80001c80:	00007b17          	auipc	s6,0x7
    80001c84:	768b0b13          	addi	s6,s6,1896 # 800093e8 <digits+0x3a8>
    p->kstack = KSTACK((int)(p - proc));
    80001c88:	8aa6                	mv	s5,s1
    80001c8a:	00007a17          	auipc	s4,0x7
    80001c8e:	376a0a13          	addi	s4,s4,886 # 80009000 <etext>
    80001c92:	04000937          	lui	s2,0x4000
    80001c96:	197d                	addi	s2,s2,-1
    80001c98:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001c9a:	00023997          	auipc	s3,0x23
    80001c9e:	e3698993          	addi	s3,s3,-458 # 80024ad0 <tickslock>
    initlock(&p->lock, "proc");
    80001ca2:	85da                	mv	a1,s6
    80001ca4:	8526                	mv	a0,s1
    80001ca6:	fffff097          	auipc	ra,0xfffff
    80001caa:	e8c080e7          	jalr	-372(ra) # 80000b32 <initlock>
    p->kstack = KSTACK((int)(p - proc));
    80001cae:	415487b3          	sub	a5,s1,s5
    80001cb2:	8791                	srai	a5,a5,0x4
    80001cb4:	000a3703          	ld	a4,0(s4)
    80001cb8:	02e787b3          	mul	a5,a5,a4
    80001cbc:	2785                	addiw	a5,a5,1
    80001cbe:	00d7979b          	slliw	a5,a5,0xd
    80001cc2:	40f907b3          	sub	a5,s2,a5
    80001cc6:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001cc8:	49048493          	addi	s1,s1,1168
    80001ccc:	fd349be3          	bne	s1,s3,80001ca2 <procinit+0x6e>
  }
}
    80001cd0:	70e2                	ld	ra,56(sp)
    80001cd2:	7442                	ld	s0,48(sp)
    80001cd4:	74a2                	ld	s1,40(sp)
    80001cd6:	7902                	ld	s2,32(sp)
    80001cd8:	69e2                	ld	s3,24(sp)
    80001cda:	6a42                	ld	s4,16(sp)
    80001cdc:	6aa2                	ld	s5,8(sp)
    80001cde:	6b02                	ld	s6,0(sp)
    80001ce0:	6121                	addi	sp,sp,64
    80001ce2:	8082                	ret

0000000080001ce4 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001ce4:	1141                	addi	sp,sp,-16
    80001ce6:	e422                	sd	s0,8(sp)
    80001ce8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001cea:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001cec:	2501                	sext.w	a0,a0
    80001cee:	6422                	ld	s0,8(sp)
    80001cf0:	0141                	addi	sp,sp,16
    80001cf2:	8082                	ret

0000000080001cf4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001cf4:	1141                	addi	sp,sp,-16
    80001cf6:	e422                	sd	s0,8(sp)
    80001cf8:	0800                	addi	s0,sp,16
    80001cfa:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001cfc:	2781                	sext.w	a5,a5
    80001cfe:	079e                	slli	a5,a5,0x7
  return c;
}
    80001d00:	00010517          	auipc	a0,0x10
    80001d04:	5d050513          	addi	a0,a0,1488 # 800122d0 <cpus>
    80001d08:	953e                	add	a0,a0,a5
    80001d0a:	6422                	ld	s0,8(sp)
    80001d0c:	0141                	addi	sp,sp,16
    80001d0e:	8082                	ret

0000000080001d10 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001d10:	1101                	addi	sp,sp,-32
    80001d12:	ec06                	sd	ra,24(sp)
    80001d14:	e822                	sd	s0,16(sp)
    80001d16:	e426                	sd	s1,8(sp)
    80001d18:	1000                	addi	s0,sp,32
  push_off();
    80001d1a:	fffff097          	auipc	ra,0xfffff
    80001d1e:	e5c080e7          	jalr	-420(ra) # 80000b76 <push_off>
    80001d22:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001d24:	2781                	sext.w	a5,a5
    80001d26:	079e                	slli	a5,a5,0x7
    80001d28:	00010717          	auipc	a4,0x10
    80001d2c:	57870713          	addi	a4,a4,1400 # 800122a0 <pid_lock>
    80001d30:	97ba                	add	a5,a5,a4
    80001d32:	7b84                	ld	s1,48(a5)
  pop_off();
    80001d34:	fffff097          	auipc	ra,0xfffff
    80001d38:	ee2080e7          	jalr	-286(ra) # 80000c16 <pop_off>
  return p;
}
    80001d3c:	8526                	mv	a0,s1
    80001d3e:	60e2                	ld	ra,24(sp)
    80001d40:	6442                	ld	s0,16(sp)
    80001d42:	64a2                	ld	s1,8(sp)
    80001d44:	6105                	addi	sp,sp,32
    80001d46:	8082                	ret

0000000080001d48 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001d48:	1141                	addi	sp,sp,-16
    80001d4a:	e406                	sd	ra,8(sp)
    80001d4c:	e022                	sd	s0,0(sp)
    80001d4e:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001d50:	00000097          	auipc	ra,0x0
    80001d54:	fc0080e7          	jalr	-64(ra) # 80001d10 <myproc>
    80001d58:	fffff097          	auipc	ra,0xfffff
    80001d5c:	f1e080e7          	jalr	-226(ra) # 80000c76 <release>

  if (first)
    80001d60:	00008797          	auipc	a5,0x8
    80001d64:	fc07a783          	lw	a5,-64(a5) # 80009d20 <first.1>
    80001d68:	eb89                	bnez	a5,80001d7a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001d6a:	00001097          	auipc	ra,0x1
    80001d6e:	23a080e7          	jalr	570(ra) # 80002fa4 <usertrapret>
}
    80001d72:	60a2                	ld	ra,8(sp)
    80001d74:	6402                	ld	s0,0(sp)
    80001d76:	0141                	addi	sp,sp,16
    80001d78:	8082                	ret
    first = 0;
    80001d7a:	00008797          	auipc	a5,0x8
    80001d7e:	fa07a323          	sw	zero,-90(a5) # 80009d20 <first.1>
    fsinit(ROOTDEV);
    80001d82:	4505                	li	a0,1
    80001d84:	00002097          	auipc	ra,0x2
    80001d88:	06a080e7          	jalr	106(ra) # 80003dee <fsinit>
    80001d8c:	bff9                	j	80001d6a <forkret+0x22>

0000000080001d8e <allocpid>:
{
    80001d8e:	1101                	addi	sp,sp,-32
    80001d90:	ec06                	sd	ra,24(sp)
    80001d92:	e822                	sd	s0,16(sp)
    80001d94:	e426                	sd	s1,8(sp)
    80001d96:	e04a                	sd	s2,0(sp)
    80001d98:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001d9a:	00010917          	auipc	s2,0x10
    80001d9e:	50690913          	addi	s2,s2,1286 # 800122a0 <pid_lock>
    80001da2:	854a                	mv	a0,s2
    80001da4:	fffff097          	auipc	ra,0xfffff
    80001da8:	e1e080e7          	jalr	-482(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001dac:	00008797          	auipc	a5,0x8
    80001db0:	f7878793          	addi	a5,a5,-136 # 80009d24 <nextpid>
    80001db4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001db6:	0014871b          	addiw	a4,s1,1
    80001dba:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001dbc:	854a                	mv	a0,s2
    80001dbe:	fffff097          	auipc	ra,0xfffff
    80001dc2:	eb8080e7          	jalr	-328(ra) # 80000c76 <release>
}
    80001dc6:	8526                	mv	a0,s1
    80001dc8:	60e2                	ld	ra,24(sp)
    80001dca:	6442                	ld	s0,16(sp)
    80001dcc:	64a2                	ld	s1,8(sp)
    80001dce:	6902                	ld	s2,0(sp)
    80001dd0:	6105                	addi	sp,sp,32
    80001dd2:	8082                	ret

0000000080001dd4 <proc_pagetable>:
{
    80001dd4:	1101                	addi	sp,sp,-32
    80001dd6:	ec06                	sd	ra,24(sp)
    80001dd8:	e822                	sd	s0,16(sp)
    80001dda:	e426                	sd	s1,8(sp)
    80001ddc:	e04a                	sd	s2,0(sp)
    80001dde:	1000                	addi	s0,sp,32
    80001de0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001de2:	fffff097          	auipc	ra,0xfffff
    80001de6:	474080e7          	jalr	1140(ra) # 80001256 <uvmcreate>
    80001dea:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001dec:	c121                	beqz	a0,80001e2c <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001dee:	4729                	li	a4,10
    80001df0:	00006697          	auipc	a3,0x6
    80001df4:	21068693          	addi	a3,a3,528 # 80008000 <_trampoline>
    80001df8:	6605                	lui	a2,0x1
    80001dfa:	040005b7          	lui	a1,0x4000
    80001dfe:	15fd                	addi	a1,a1,-1
    80001e00:	05b2                	slli	a1,a1,0xc
    80001e02:	fffff097          	auipc	ra,0xfffff
    80001e06:	2a0080e7          	jalr	672(ra) # 800010a2 <mappages>
    80001e0a:	02054863          	bltz	a0,80001e3a <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001e0e:	4719                	li	a4,6
    80001e10:	05893683          	ld	a3,88(s2)
    80001e14:	6605                	lui	a2,0x1
    80001e16:	020005b7          	lui	a1,0x2000
    80001e1a:	15fd                	addi	a1,a1,-1
    80001e1c:	05b6                	slli	a1,a1,0xd
    80001e1e:	8526                	mv	a0,s1
    80001e20:	fffff097          	auipc	ra,0xfffff
    80001e24:	282080e7          	jalr	642(ra) # 800010a2 <mappages>
    80001e28:	02054163          	bltz	a0,80001e4a <proc_pagetable+0x76>
}
    80001e2c:	8526                	mv	a0,s1
    80001e2e:	60e2                	ld	ra,24(sp)
    80001e30:	6442                	ld	s0,16(sp)
    80001e32:	64a2                	ld	s1,8(sp)
    80001e34:	6902                	ld	s2,0(sp)
    80001e36:	6105                	addi	sp,sp,32
    80001e38:	8082                	ret
    uvmfree(pagetable, 0);
    80001e3a:	4581                	li	a1,0
    80001e3c:	8526                	mv	a0,s1
    80001e3e:	00000097          	auipc	ra,0x0
    80001e42:	c30080e7          	jalr	-976(ra) # 80001a6e <uvmfree>
    return 0;
    80001e46:	4481                	li	s1,0
    80001e48:	b7d5                	j	80001e2c <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e4a:	4681                	li	a3,0
    80001e4c:	4605                	li	a2,1
    80001e4e:	040005b7          	lui	a1,0x4000
    80001e52:	15fd                	addi	a1,a1,-1
    80001e54:	05b2                	slli	a1,a1,0xc
    80001e56:	8526                	mv	a0,s1
    80001e58:	00000097          	auipc	ra,0x0
    80001e5c:	908080e7          	jalr	-1784(ra) # 80001760 <uvmunmap>
    uvmfree(pagetable, 0);
    80001e60:	4581                	li	a1,0
    80001e62:	8526                	mv	a0,s1
    80001e64:	00000097          	auipc	ra,0x0
    80001e68:	c0a080e7          	jalr	-1014(ra) # 80001a6e <uvmfree>
    return 0;
    80001e6c:	4481                	li	s1,0
    80001e6e:	bf7d                	j	80001e2c <proc_pagetable+0x58>

0000000080001e70 <proc_freepagetable>:
{
    80001e70:	1101                	addi	sp,sp,-32
    80001e72:	ec06                	sd	ra,24(sp)
    80001e74:	e822                	sd	s0,16(sp)
    80001e76:	e426                	sd	s1,8(sp)
    80001e78:	e04a                	sd	s2,0(sp)
    80001e7a:	1000                	addi	s0,sp,32
    80001e7c:	84aa                	mv	s1,a0
    80001e7e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e80:	4681                	li	a3,0
    80001e82:	4605                	li	a2,1
    80001e84:	040005b7          	lui	a1,0x4000
    80001e88:	15fd                	addi	a1,a1,-1
    80001e8a:	05b2                	slli	a1,a1,0xc
    80001e8c:	00000097          	auipc	ra,0x0
    80001e90:	8d4080e7          	jalr	-1836(ra) # 80001760 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e94:	4681                	li	a3,0
    80001e96:	4605                	li	a2,1
    80001e98:	020005b7          	lui	a1,0x2000
    80001e9c:	15fd                	addi	a1,a1,-1
    80001e9e:	05b6                	slli	a1,a1,0xd
    80001ea0:	8526                	mv	a0,s1
    80001ea2:	00000097          	auipc	ra,0x0
    80001ea6:	8be080e7          	jalr	-1858(ra) # 80001760 <uvmunmap>
  uvmfree(pagetable, sz);
    80001eaa:	85ca                	mv	a1,s2
    80001eac:	8526                	mv	a0,s1
    80001eae:	00000097          	auipc	ra,0x0
    80001eb2:	bc0080e7          	jalr	-1088(ra) # 80001a6e <uvmfree>
}
    80001eb6:	60e2                	ld	ra,24(sp)
    80001eb8:	6442                	ld	s0,16(sp)
    80001eba:	64a2                	ld	s1,8(sp)
    80001ebc:	6902                	ld	s2,0(sp)
    80001ebe:	6105                	addi	sp,sp,32
    80001ec0:	8082                	ret

0000000080001ec2 <freeproc>:
{
    80001ec2:	1101                	addi	sp,sp,-32
    80001ec4:	ec06                	sd	ra,24(sp)
    80001ec6:	e822                	sd	s0,16(sp)
    80001ec8:	e426                	sd	s1,8(sp)
    80001eca:	1000                	addi	s0,sp,32
    80001ecc:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001ece:	6d28                	ld	a0,88(a0)
    80001ed0:	c509                	beqz	a0,80001eda <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001ed2:	fffff097          	auipc	ra,0xfffff
    80001ed6:	b04080e7          	jalr	-1276(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001eda:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001ede:	68a8                	ld	a0,80(s1)
    80001ee0:	c511                	beqz	a0,80001eec <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001ee2:	64ac                	ld	a1,72(s1)
    80001ee4:	00000097          	auipc	ra,0x0
    80001ee8:	f8c080e7          	jalr	-116(ra) # 80001e70 <proc_freepagetable>
  p->pagetable = 0;
    80001eec:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ef0:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ef4:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001ef8:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001efc:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001f00:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001f04:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001f08:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001f0c:	0004ac23          	sw	zero,24(s1)
  p->paging_time = 0;
    80001f10:	4804b423          	sd	zero,1160(s1)
}
    80001f14:	60e2                	ld	ra,24(sp)
    80001f16:	6442                	ld	s0,16(sp)
    80001f18:	64a2                	ld	s1,8(sp)
    80001f1a:	6105                	addi	sp,sp,32
    80001f1c:	8082                	ret

0000000080001f1e <allocproc>:
{
    80001f1e:	1101                	addi	sp,sp,-32
    80001f20:	ec06                	sd	ra,24(sp)
    80001f22:	e822                	sd	s0,16(sp)
    80001f24:	e426                	sd	s1,8(sp)
    80001f26:	e04a                	sd	s2,0(sp)
    80001f28:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001f2a:	00010497          	auipc	s1,0x10
    80001f2e:	7a648493          	addi	s1,s1,1958 # 800126d0 <proc>
    80001f32:	00023917          	auipc	s2,0x23
    80001f36:	b9e90913          	addi	s2,s2,-1122 # 80024ad0 <tickslock>
    acquire(&p->lock);
    80001f3a:	8526                	mv	a0,s1
    80001f3c:	fffff097          	auipc	ra,0xfffff
    80001f40:	c86080e7          	jalr	-890(ra) # 80000bc2 <acquire>
    if (p->state == UNUSED)
    80001f44:	4c9c                	lw	a5,24(s1)
    80001f46:	cf81                	beqz	a5,80001f5e <allocproc+0x40>
      release(&p->lock);
    80001f48:	8526                	mv	a0,s1
    80001f4a:	fffff097          	auipc	ra,0xfffff
    80001f4e:	d2c080e7          	jalr	-724(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001f52:	49048493          	addi	s1,s1,1168
    80001f56:	ff2492e3          	bne	s1,s2,80001f3a <allocproc+0x1c>
  return 0;
    80001f5a:	4481                	li	s1,0
    80001f5c:	a09d                	j	80001fc2 <allocproc+0xa4>
  p->pid = allocpid();
    80001f5e:	00000097          	auipc	ra,0x0
    80001f62:	e30080e7          	jalr	-464(ra) # 80001d8e <allocpid>
    80001f66:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001f68:	4785                	li	a5,1
    80001f6a:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001f6c:	fffff097          	auipc	ra,0xfffff
    80001f70:	b66080e7          	jalr	-1178(ra) # 80000ad2 <kalloc>
    80001f74:	892a                	mv	s2,a0
    80001f76:	eca8                	sd	a0,88(s1)
    80001f78:	cd21                	beqz	a0,80001fd0 <allocproc+0xb2>
  p->pagetable = proc_pagetable(p);
    80001f7a:	8526                	mv	a0,s1
    80001f7c:	00000097          	auipc	ra,0x0
    80001f80:	e58080e7          	jalr	-424(ra) # 80001dd4 <proc_pagetable>
    80001f84:	892a                	mv	s2,a0
    80001f86:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001f88:	c125                	beqz	a0,80001fe8 <allocproc+0xca>
  memset(&p->context, 0, sizeof(p->context));
    80001f8a:	07000613          	li	a2,112
    80001f8e:	4581                	li	a1,0
    80001f90:	06048513          	addi	a0,s1,96
    80001f94:	fffff097          	auipc	ra,0xfffff
    80001f98:	d2a080e7          	jalr	-726(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80001f9c:	00000797          	auipc	a5,0x0
    80001fa0:	dac78793          	addi	a5,a5,-596 # 80001d48 <forkret>
    80001fa4:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001fa6:	60bc                	ld	a5,64(s1)
    80001fa8:	6705                	lui	a4,0x1
    80001faa:	97ba                	add	a5,a5,a4
    80001fac:	f4bc                	sd	a5,104(s1)
  p->physical_pages_num = 0;
    80001fae:	1604a823          	sw	zero,368(s1)
  p->total_pages_num = 0;
    80001fb2:	1604aa23          	sw	zero,372(s1)
  p->pages_physc_info.free_spaces = 0;
    80001fb6:	30049023          	sh	zero,768(s1)
  p->pages_swap_info.free_spaces = 0;
    80001fba:	16049c23          	sh	zero,376(s1)
  p->paging_time = 0;
    80001fbe:	4804b423          	sd	zero,1160(s1)
}
    80001fc2:	8526                	mv	a0,s1
    80001fc4:	60e2                	ld	ra,24(sp)
    80001fc6:	6442                	ld	s0,16(sp)
    80001fc8:	64a2                	ld	s1,8(sp)
    80001fca:	6902                	ld	s2,0(sp)
    80001fcc:	6105                	addi	sp,sp,32
    80001fce:	8082                	ret
    freeproc(p);
    80001fd0:	8526                	mv	a0,s1
    80001fd2:	00000097          	auipc	ra,0x0
    80001fd6:	ef0080e7          	jalr	-272(ra) # 80001ec2 <freeproc>
    release(&p->lock);
    80001fda:	8526                	mv	a0,s1
    80001fdc:	fffff097          	auipc	ra,0xfffff
    80001fe0:	c9a080e7          	jalr	-870(ra) # 80000c76 <release>
    return 0;
    80001fe4:	84ca                	mv	s1,s2
    80001fe6:	bff1                	j	80001fc2 <allocproc+0xa4>
    freeproc(p);
    80001fe8:	8526                	mv	a0,s1
    80001fea:	00000097          	auipc	ra,0x0
    80001fee:	ed8080e7          	jalr	-296(ra) # 80001ec2 <freeproc>
    release(&p->lock);
    80001ff2:	8526                	mv	a0,s1
    80001ff4:	fffff097          	auipc	ra,0xfffff
    80001ff8:	c82080e7          	jalr	-894(ra) # 80000c76 <release>
    return 0;
    80001ffc:	84ca                	mv	s1,s2
    80001ffe:	b7d1                	j	80001fc2 <allocproc+0xa4>

0000000080002000 <userinit>:
{
    80002000:	1101                	addi	sp,sp,-32
    80002002:	ec06                	sd	ra,24(sp)
    80002004:	e822                	sd	s0,16(sp)
    80002006:	e426                	sd	s1,8(sp)
    80002008:	1000                	addi	s0,sp,32
  p = allocproc();
    8000200a:	00000097          	auipc	ra,0x0
    8000200e:	f14080e7          	jalr	-236(ra) # 80001f1e <allocproc>
    80002012:	84aa                	mv	s1,a0
  initproc = p;
    80002014:	00008797          	auipc	a5,0x8
    80002018:	00a7ba23          	sd	a0,20(a5) # 8000a028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    8000201c:	03400613          	li	a2,52
    80002020:	00008597          	auipc	a1,0x8
    80002024:	d1058593          	addi	a1,a1,-752 # 80009d30 <initcode>
    80002028:	6928                	ld	a0,80(a0)
    8000202a:	fffff097          	auipc	ra,0xfffff
    8000202e:	25a080e7          	jalr	602(ra) # 80001284 <uvminit>
  p->sz = PGSIZE;
    80002032:	6785                	lui	a5,0x1
    80002034:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80002036:	6cb8                	ld	a4,88(s1)
    80002038:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    8000203c:	6cb8                	ld	a4,88(s1)
    8000203e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002040:	4641                	li	a2,16
    80002042:	00007597          	auipc	a1,0x7
    80002046:	3ae58593          	addi	a1,a1,942 # 800093f0 <digits+0x3b0>
    8000204a:	15848513          	addi	a0,s1,344
    8000204e:	fffff097          	auipc	ra,0xfffff
    80002052:	dc2080e7          	jalr	-574(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80002056:	00007517          	auipc	a0,0x7
    8000205a:	3aa50513          	addi	a0,a0,938 # 80009400 <digits+0x3c0>
    8000205e:	00002097          	auipc	ra,0x2
    80002062:	7be080e7          	jalr	1982(ra) # 8000481c <namei>
    80002066:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000206a:	478d                	li	a5,3
    8000206c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000206e:	8526                	mv	a0,s1
    80002070:	fffff097          	auipc	ra,0xfffff
    80002074:	c06080e7          	jalr	-1018(ra) # 80000c76 <release>
}
    80002078:	60e2                	ld	ra,24(sp)
    8000207a:	6442                	ld	s0,16(sp)
    8000207c:	64a2                	ld	s1,8(sp)
    8000207e:	6105                	addi	sp,sp,32
    80002080:	8082                	ret

0000000080002082 <growproc>:
{
    80002082:	1101                	addi	sp,sp,-32
    80002084:	ec06                	sd	ra,24(sp)
    80002086:	e822                	sd	s0,16(sp)
    80002088:	e426                	sd	s1,8(sp)
    8000208a:	e04a                	sd	s2,0(sp)
    8000208c:	1000                	addi	s0,sp,32
    8000208e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002090:	00000097          	auipc	ra,0x0
    80002094:	c80080e7          	jalr	-896(ra) # 80001d10 <myproc>
    80002098:	892a                	mv	s2,a0
  sz = p->sz;
    8000209a:	652c                	ld	a1,72(a0)
    8000209c:	0005861b          	sext.w	a2,a1
  if (n > 0)
    800020a0:	00904f63          	bgtz	s1,800020be <growproc+0x3c>
  else if (n < 0)
    800020a4:	0204cc63          	bltz	s1,800020dc <growproc+0x5a>
  p->sz = sz;
    800020a8:	1602                	slli	a2,a2,0x20
    800020aa:	9201                	srli	a2,a2,0x20
    800020ac:	04c93423          	sd	a2,72(s2)
  return 0;
    800020b0:	4501                	li	a0,0
}
    800020b2:	60e2                	ld	ra,24(sp)
    800020b4:	6442                	ld	s0,16(sp)
    800020b6:	64a2                	ld	s1,8(sp)
    800020b8:	6902                	ld	s2,0(sp)
    800020ba:	6105                	addi	sp,sp,32
    800020bc:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0)
    800020be:	9e25                	addw	a2,a2,s1
    800020c0:	1602                	slli	a2,a2,0x20
    800020c2:	9201                	srli	a2,a2,0x20
    800020c4:	1582                	slli	a1,a1,0x20
    800020c6:	9181                	srli	a1,a1,0x20
    800020c8:	6928                	ld	a0,80(a0)
    800020ca:	00000097          	auipc	ra,0x0
    800020ce:	838080e7          	jalr	-1992(ra) # 80001902 <uvmalloc>
    800020d2:	0005061b          	sext.w	a2,a0
    800020d6:	fa69                	bnez	a2,800020a8 <growproc+0x26>
      return -1;
    800020d8:	557d                	li	a0,-1
    800020da:	bfe1                	j	800020b2 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800020dc:	9e25                	addw	a2,a2,s1
    800020de:	1602                	slli	a2,a2,0x20
    800020e0:	9201                	srli	a2,a2,0x20
    800020e2:	1582                	slli	a1,a1,0x20
    800020e4:	9181                	srli	a1,a1,0x20
    800020e6:	6928                	ld	a0,80(a0)
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	7d2080e7          	jalr	2002(ra) # 800018ba <uvmdealloc>
    800020f0:	0005061b          	sext.w	a2,a0
    800020f4:	bf55                	j	800020a8 <growproc+0x26>

00000000800020f6 <sched>:
{
    800020f6:	7179                	addi	sp,sp,-48
    800020f8:	f406                	sd	ra,40(sp)
    800020fa:	f022                	sd	s0,32(sp)
    800020fc:	ec26                	sd	s1,24(sp)
    800020fe:	e84a                	sd	s2,16(sp)
    80002100:	e44e                	sd	s3,8(sp)
    80002102:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002104:	00000097          	auipc	ra,0x0
    80002108:	c0c080e7          	jalr	-1012(ra) # 80001d10 <myproc>
    8000210c:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000210e:	fffff097          	auipc	ra,0xfffff
    80002112:	a3a080e7          	jalr	-1478(ra) # 80000b48 <holding>
    80002116:	c93d                	beqz	a0,8000218c <sched+0x96>
    80002118:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000211a:	2781                	sext.w	a5,a5
    8000211c:	079e                	slli	a5,a5,0x7
    8000211e:	00010717          	auipc	a4,0x10
    80002122:	18270713          	addi	a4,a4,386 # 800122a0 <pid_lock>
    80002126:	97ba                	add	a5,a5,a4
    80002128:	0a87a703          	lw	a4,168(a5) # 10a8 <_entry-0x7fffef58>
    8000212c:	4785                	li	a5,1
    8000212e:	06f71763          	bne	a4,a5,8000219c <sched+0xa6>
  if (p->state == RUNNING)
    80002132:	4c98                	lw	a4,24(s1)
    80002134:	4791                	li	a5,4
    80002136:	06f70b63          	beq	a4,a5,800021ac <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000213a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000213e:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002140:	efb5                	bnez	a5,800021bc <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002142:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002144:	00010917          	auipc	s2,0x10
    80002148:	15c90913          	addi	s2,s2,348 # 800122a0 <pid_lock>
    8000214c:	2781                	sext.w	a5,a5
    8000214e:	079e                	slli	a5,a5,0x7
    80002150:	97ca                	add	a5,a5,s2
    80002152:	0ac7a983          	lw	s3,172(a5)
    80002156:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002158:	2781                	sext.w	a5,a5
    8000215a:	079e                	slli	a5,a5,0x7
    8000215c:	00010597          	auipc	a1,0x10
    80002160:	17c58593          	addi	a1,a1,380 # 800122d8 <cpus+0x8>
    80002164:	95be                	add	a1,a1,a5
    80002166:	06048513          	addi	a0,s1,96
    8000216a:	00001097          	auipc	ra,0x1
    8000216e:	d90080e7          	jalr	-624(ra) # 80002efa <swtch>
    80002172:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002174:	2781                	sext.w	a5,a5
    80002176:	079e                	slli	a5,a5,0x7
    80002178:	97ca                	add	a5,a5,s2
    8000217a:	0b37a623          	sw	s3,172(a5)
}
    8000217e:	70a2                	ld	ra,40(sp)
    80002180:	7402                	ld	s0,32(sp)
    80002182:	64e2                	ld	s1,24(sp)
    80002184:	6942                	ld	s2,16(sp)
    80002186:	69a2                	ld	s3,8(sp)
    80002188:	6145                	addi	sp,sp,48
    8000218a:	8082                	ret
    panic("sched p->lock");
    8000218c:	00007517          	auipc	a0,0x7
    80002190:	27c50513          	addi	a0,a0,636 # 80009408 <digits+0x3c8>
    80002194:	ffffe097          	auipc	ra,0xffffe
    80002198:	396080e7          	jalr	918(ra) # 8000052a <panic>
    panic("sched locks");
    8000219c:	00007517          	auipc	a0,0x7
    800021a0:	27c50513          	addi	a0,a0,636 # 80009418 <digits+0x3d8>
    800021a4:	ffffe097          	auipc	ra,0xffffe
    800021a8:	386080e7          	jalr	902(ra) # 8000052a <panic>
    panic("sched running");
    800021ac:	00007517          	auipc	a0,0x7
    800021b0:	27c50513          	addi	a0,a0,636 # 80009428 <digits+0x3e8>
    800021b4:	ffffe097          	auipc	ra,0xffffe
    800021b8:	376080e7          	jalr	886(ra) # 8000052a <panic>
    panic("sched interruptible");
    800021bc:	00007517          	auipc	a0,0x7
    800021c0:	27c50513          	addi	a0,a0,636 # 80009438 <digits+0x3f8>
    800021c4:	ffffe097          	auipc	ra,0xffffe
    800021c8:	366080e7          	jalr	870(ra) # 8000052a <panic>

00000000800021cc <yield>:
{
    800021cc:	1101                	addi	sp,sp,-32
    800021ce:	ec06                	sd	ra,24(sp)
    800021d0:	e822                	sd	s0,16(sp)
    800021d2:	e426                	sd	s1,8(sp)
    800021d4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021d6:	00000097          	auipc	ra,0x0
    800021da:	b3a080e7          	jalr	-1222(ra) # 80001d10 <myproc>
    800021de:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021e0:	fffff097          	auipc	ra,0xfffff
    800021e4:	9e2080e7          	jalr	-1566(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    800021e8:	478d                	li	a5,3
    800021ea:	cc9c                	sw	a5,24(s1)
  sched();
    800021ec:	00000097          	auipc	ra,0x0
    800021f0:	f0a080e7          	jalr	-246(ra) # 800020f6 <sched>
  release(&p->lock);
    800021f4:	8526                	mv	a0,s1
    800021f6:	fffff097          	auipc	ra,0xfffff
    800021fa:	a80080e7          	jalr	-1408(ra) # 80000c76 <release>
}
    800021fe:	60e2                	ld	ra,24(sp)
    80002200:	6442                	ld	s0,16(sp)
    80002202:	64a2                	ld	s1,8(sp)
    80002204:	6105                	addi	sp,sp,32
    80002206:	8082                	ret

0000000080002208 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002208:	7179                	addi	sp,sp,-48
    8000220a:	f406                	sd	ra,40(sp)
    8000220c:	f022                	sd	s0,32(sp)
    8000220e:	ec26                	sd	s1,24(sp)
    80002210:	e84a                	sd	s2,16(sp)
    80002212:	e44e                	sd	s3,8(sp)
    80002214:	1800                	addi	s0,sp,48
    80002216:	89aa                	mv	s3,a0
    80002218:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000221a:	00000097          	auipc	ra,0x0
    8000221e:	af6080e7          	jalr	-1290(ra) # 80001d10 <myproc>
    80002222:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); //DOC: sleeplock1
    80002224:	fffff097          	auipc	ra,0xfffff
    80002228:	99e080e7          	jalr	-1634(ra) # 80000bc2 <acquire>
  release(lk);
    8000222c:	854a                	mv	a0,s2
    8000222e:	fffff097          	auipc	ra,0xfffff
    80002232:	a48080e7          	jalr	-1464(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    80002236:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000223a:	4789                	li	a5,2
    8000223c:	cc9c                	sw	a5,24(s1)

  sched();
    8000223e:	00000097          	auipc	ra,0x0
    80002242:	eb8080e7          	jalr	-328(ra) # 800020f6 <sched>

  // Tidy up.
  p->chan = 0;
    80002246:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000224a:	8526                	mv	a0,s1
    8000224c:	fffff097          	auipc	ra,0xfffff
    80002250:	a2a080e7          	jalr	-1494(ra) # 80000c76 <release>
  acquire(lk);
    80002254:	854a                	mv	a0,s2
    80002256:	fffff097          	auipc	ra,0xfffff
    8000225a:	96c080e7          	jalr	-1684(ra) # 80000bc2 <acquire>
}
    8000225e:	70a2                	ld	ra,40(sp)
    80002260:	7402                	ld	s0,32(sp)
    80002262:	64e2                	ld	s1,24(sp)
    80002264:	6942                	ld	s2,16(sp)
    80002266:	69a2                	ld	s3,8(sp)
    80002268:	6145                	addi	sp,sp,48
    8000226a:	8082                	ret

000000008000226c <wait>:
{
    8000226c:	715d                	addi	sp,sp,-80
    8000226e:	e486                	sd	ra,72(sp)
    80002270:	e0a2                	sd	s0,64(sp)
    80002272:	fc26                	sd	s1,56(sp)
    80002274:	f84a                	sd	s2,48(sp)
    80002276:	f44e                	sd	s3,40(sp)
    80002278:	f052                	sd	s4,32(sp)
    8000227a:	ec56                	sd	s5,24(sp)
    8000227c:	e85a                	sd	s6,16(sp)
    8000227e:	e45e                	sd	s7,8(sp)
    80002280:	e062                	sd	s8,0(sp)
    80002282:	0880                	addi	s0,sp,80
    80002284:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002286:	00000097          	auipc	ra,0x0
    8000228a:	a8a080e7          	jalr	-1398(ra) # 80001d10 <myproc>
    8000228e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002290:	00010517          	auipc	a0,0x10
    80002294:	02850513          	addi	a0,a0,40 # 800122b8 <wait_lock>
    80002298:	fffff097          	auipc	ra,0xfffff
    8000229c:	92a080e7          	jalr	-1750(ra) # 80000bc2 <acquire>
    havekids = 0;
    800022a0:	4b81                	li	s7,0
        if (np->state == ZOMBIE)
    800022a2:	4a15                	li	s4,5
        havekids = 1;
    800022a4:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800022a6:	00023997          	auipc	s3,0x23
    800022aa:	82a98993          	addi	s3,s3,-2006 # 80024ad0 <tickslock>
    sleep(p, &wait_lock); //DOC: wait-sleep
    800022ae:	00010c17          	auipc	s8,0x10
    800022b2:	00ac0c13          	addi	s8,s8,10 # 800122b8 <wait_lock>
    havekids = 0;
    800022b6:	875e                	mv	a4,s7
    for (np = proc; np < &proc[NPROC]; np++)
    800022b8:	00010497          	auipc	s1,0x10
    800022bc:	41848493          	addi	s1,s1,1048 # 800126d0 <proc>
    800022c0:	a0bd                	j	8000232e <wait+0xc2>
          pid = np->pid;
    800022c2:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022c6:	000b0e63          	beqz	s6,800022e2 <wait+0x76>
    800022ca:	4691                	li	a3,4
    800022cc:	02c48613          	addi	a2,s1,44
    800022d0:	85da                	mv	a1,s6
    800022d2:	05093503          	ld	a0,80(s2)
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	0bc080e7          	jalr	188(ra) # 80001392 <copyout>
    800022de:	02054563          	bltz	a0,80002308 <wait+0x9c>
          freeproc(np);
    800022e2:	8526                	mv	a0,s1
    800022e4:	00000097          	auipc	ra,0x0
    800022e8:	bde080e7          	jalr	-1058(ra) # 80001ec2 <freeproc>
          release(&np->lock);
    800022ec:	8526                	mv	a0,s1
    800022ee:	fffff097          	auipc	ra,0xfffff
    800022f2:	988080e7          	jalr	-1656(ra) # 80000c76 <release>
          release(&wait_lock);
    800022f6:	00010517          	auipc	a0,0x10
    800022fa:	fc250513          	addi	a0,a0,-62 # 800122b8 <wait_lock>
    800022fe:	fffff097          	auipc	ra,0xfffff
    80002302:	978080e7          	jalr	-1672(ra) # 80000c76 <release>
          return pid;
    80002306:	a09d                	j	8000236c <wait+0x100>
            release(&np->lock);
    80002308:	8526                	mv	a0,s1
    8000230a:	fffff097          	auipc	ra,0xfffff
    8000230e:	96c080e7          	jalr	-1684(ra) # 80000c76 <release>
            release(&wait_lock);
    80002312:	00010517          	auipc	a0,0x10
    80002316:	fa650513          	addi	a0,a0,-90 # 800122b8 <wait_lock>
    8000231a:	fffff097          	auipc	ra,0xfffff
    8000231e:	95c080e7          	jalr	-1700(ra) # 80000c76 <release>
            return -1;
    80002322:	59fd                	li	s3,-1
    80002324:	a0a1                	j	8000236c <wait+0x100>
    for (np = proc; np < &proc[NPROC]; np++)
    80002326:	49048493          	addi	s1,s1,1168
    8000232a:	03348463          	beq	s1,s3,80002352 <wait+0xe6>
      if (np->parent == p)
    8000232e:	7c9c                	ld	a5,56(s1)
    80002330:	ff279be3          	bne	a5,s2,80002326 <wait+0xba>
        acquire(&np->lock);
    80002334:	8526                	mv	a0,s1
    80002336:	fffff097          	auipc	ra,0xfffff
    8000233a:	88c080e7          	jalr	-1908(ra) # 80000bc2 <acquire>
        if (np->state == ZOMBIE)
    8000233e:	4c9c                	lw	a5,24(s1)
    80002340:	f94781e3          	beq	a5,s4,800022c2 <wait+0x56>
        release(&np->lock);
    80002344:	8526                	mv	a0,s1
    80002346:	fffff097          	auipc	ra,0xfffff
    8000234a:	930080e7          	jalr	-1744(ra) # 80000c76 <release>
        havekids = 1;
    8000234e:	8756                	mv	a4,s5
    80002350:	bfd9                	j	80002326 <wait+0xba>
    if (!havekids || p->killed)
    80002352:	c701                	beqz	a4,8000235a <wait+0xee>
    80002354:	02892783          	lw	a5,40(s2)
    80002358:	c79d                	beqz	a5,80002386 <wait+0x11a>
      release(&wait_lock);
    8000235a:	00010517          	auipc	a0,0x10
    8000235e:	f5e50513          	addi	a0,a0,-162 # 800122b8 <wait_lock>
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	914080e7          	jalr	-1772(ra) # 80000c76 <release>
      return -1;
    8000236a:	59fd                	li	s3,-1
}
    8000236c:	854e                	mv	a0,s3
    8000236e:	60a6                	ld	ra,72(sp)
    80002370:	6406                	ld	s0,64(sp)
    80002372:	74e2                	ld	s1,56(sp)
    80002374:	7942                	ld	s2,48(sp)
    80002376:	79a2                	ld	s3,40(sp)
    80002378:	7a02                	ld	s4,32(sp)
    8000237a:	6ae2                	ld	s5,24(sp)
    8000237c:	6b42                	ld	s6,16(sp)
    8000237e:	6ba2                	ld	s7,8(sp)
    80002380:	6c02                	ld	s8,0(sp)
    80002382:	6161                	addi	sp,sp,80
    80002384:	8082                	ret
    sleep(p, &wait_lock); //DOC: wait-sleep
    80002386:	85e2                	mv	a1,s8
    80002388:	854a                	mv	a0,s2
    8000238a:	00000097          	auipc	ra,0x0
    8000238e:	e7e080e7          	jalr	-386(ra) # 80002208 <sleep>
    havekids = 0;
    80002392:	b715                	j	800022b6 <wait+0x4a>

0000000080002394 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002394:	7139                	addi	sp,sp,-64
    80002396:	fc06                	sd	ra,56(sp)
    80002398:	f822                	sd	s0,48(sp)
    8000239a:	f426                	sd	s1,40(sp)
    8000239c:	f04a                	sd	s2,32(sp)
    8000239e:	ec4e                	sd	s3,24(sp)
    800023a0:	e852                	sd	s4,16(sp)
    800023a2:	e456                	sd	s5,8(sp)
    800023a4:	0080                	addi	s0,sp,64
    800023a6:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800023a8:	00010497          	auipc	s1,0x10
    800023ac:	32848493          	addi	s1,s1,808 # 800126d0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800023b0:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800023b2:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800023b4:	00022917          	auipc	s2,0x22
    800023b8:	71c90913          	addi	s2,s2,1820 # 80024ad0 <tickslock>
    800023bc:	a811                	j	800023d0 <wakeup+0x3c>
      }
      release(&p->lock);
    800023be:	8526                	mv	a0,s1
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	8b6080e7          	jalr	-1866(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800023c8:	49048493          	addi	s1,s1,1168
    800023cc:	03248663          	beq	s1,s2,800023f8 <wakeup+0x64>
    if (p != myproc())
    800023d0:	00000097          	auipc	ra,0x0
    800023d4:	940080e7          	jalr	-1728(ra) # 80001d10 <myproc>
    800023d8:	fea488e3          	beq	s1,a0,800023c8 <wakeup+0x34>
      acquire(&p->lock);
    800023dc:	8526                	mv	a0,s1
    800023de:	ffffe097          	auipc	ra,0xffffe
    800023e2:	7e4080e7          	jalr	2020(ra) # 80000bc2 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800023e6:	4c9c                	lw	a5,24(s1)
    800023e8:	fd379be3          	bne	a5,s3,800023be <wakeup+0x2a>
    800023ec:	709c                	ld	a5,32(s1)
    800023ee:	fd4798e3          	bne	a5,s4,800023be <wakeup+0x2a>
        p->state = RUNNABLE;
    800023f2:	0154ac23          	sw	s5,24(s1)
    800023f6:	b7e1                	j	800023be <wakeup+0x2a>
    }
  }
}
    800023f8:	70e2                	ld	ra,56(sp)
    800023fa:	7442                	ld	s0,48(sp)
    800023fc:	74a2                	ld	s1,40(sp)
    800023fe:	7902                	ld	s2,32(sp)
    80002400:	69e2                	ld	s3,24(sp)
    80002402:	6a42                	ld	s4,16(sp)
    80002404:	6aa2                	ld	s5,8(sp)
    80002406:	6121                	addi	sp,sp,64
    80002408:	8082                	ret

000000008000240a <reparent>:
{
    8000240a:	7179                	addi	sp,sp,-48
    8000240c:	f406                	sd	ra,40(sp)
    8000240e:	f022                	sd	s0,32(sp)
    80002410:	ec26                	sd	s1,24(sp)
    80002412:	e84a                	sd	s2,16(sp)
    80002414:	e44e                	sd	s3,8(sp)
    80002416:	e052                	sd	s4,0(sp)
    80002418:	1800                	addi	s0,sp,48
    8000241a:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000241c:	00010497          	auipc	s1,0x10
    80002420:	2b448493          	addi	s1,s1,692 # 800126d0 <proc>
      pp->parent = initproc;
    80002424:	00008a17          	auipc	s4,0x8
    80002428:	c04a0a13          	addi	s4,s4,-1020 # 8000a028 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000242c:	00022997          	auipc	s3,0x22
    80002430:	6a498993          	addi	s3,s3,1700 # 80024ad0 <tickslock>
    80002434:	a029                	j	8000243e <reparent+0x34>
    80002436:	49048493          	addi	s1,s1,1168
    8000243a:	01348d63          	beq	s1,s3,80002454 <reparent+0x4a>
    if (pp->parent == p)
    8000243e:	7c9c                	ld	a5,56(s1)
    80002440:	ff279be3          	bne	a5,s2,80002436 <reparent+0x2c>
      pp->parent = initproc;
    80002444:	000a3503          	ld	a0,0(s4)
    80002448:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000244a:	00000097          	auipc	ra,0x0
    8000244e:	f4a080e7          	jalr	-182(ra) # 80002394 <wakeup>
    80002452:	b7d5                	j	80002436 <reparent+0x2c>
}
    80002454:	70a2                	ld	ra,40(sp)
    80002456:	7402                	ld	s0,32(sp)
    80002458:	64e2                	ld	s1,24(sp)
    8000245a:	6942                	ld	s2,16(sp)
    8000245c:	69a2                	ld	s3,8(sp)
    8000245e:	6a02                	ld	s4,0(sp)
    80002460:	6145                	addi	sp,sp,48
    80002462:	8082                	ret

0000000080002464 <exit>:
{
    80002464:	7179                	addi	sp,sp,-48
    80002466:	f406                	sd	ra,40(sp)
    80002468:	f022                	sd	s0,32(sp)
    8000246a:	ec26                	sd	s1,24(sp)
    8000246c:	e84a                	sd	s2,16(sp)
    8000246e:	e44e                	sd	s3,8(sp)
    80002470:	e052                	sd	s4,0(sp)
    80002472:	1800                	addi	s0,sp,48
    80002474:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002476:	00000097          	auipc	ra,0x0
    8000247a:	89a080e7          	jalr	-1894(ra) # 80001d10 <myproc>
    8000247e:	89aa                	mv	s3,a0
  if (p == initproc)
    80002480:	00008797          	auipc	a5,0x8
    80002484:	ba87b783          	ld	a5,-1112(a5) # 8000a028 <initproc>
    80002488:	0d050493          	addi	s1,a0,208
    8000248c:	15050913          	addi	s2,a0,336
    80002490:	02a79363          	bne	a5,a0,800024b6 <exit+0x52>
    panic("init exiting");
    80002494:	00007517          	auipc	a0,0x7
    80002498:	fbc50513          	addi	a0,a0,-68 # 80009450 <digits+0x410>
    8000249c:	ffffe097          	auipc	ra,0xffffe
    800024a0:	08e080e7          	jalr	142(ra) # 8000052a <panic>
      fileclose(f);
    800024a4:	00003097          	auipc	ra,0x3
    800024a8:	d76080e7          	jalr	-650(ra) # 8000521a <fileclose>
      p->ofile[fd] = 0;
    800024ac:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800024b0:	04a1                	addi	s1,s1,8
    800024b2:	01248563          	beq	s1,s2,800024bc <exit+0x58>
    if (p->ofile[fd])
    800024b6:	6088                	ld	a0,0(s1)
    800024b8:	f575                	bnez	a0,800024a4 <exit+0x40>
    800024ba:	bfdd                	j	800024b0 <exit+0x4c>
  removeSwapFile(p);  // Remove swap file of p
    800024bc:	854e                	mv	a0,s3
    800024be:	00002097          	auipc	ra,0x2
    800024c2:	40a080e7          	jalr	1034(ra) # 800048c8 <removeSwapFile>
  begin_op();
    800024c6:	00003097          	auipc	ra,0x3
    800024ca:	888080e7          	jalr	-1912(ra) # 80004d4e <begin_op>
  iput(p->cwd);
    800024ce:	1509b503          	ld	a0,336(s3)
    800024d2:	00002097          	auipc	ra,0x2
    800024d6:	d4e080e7          	jalr	-690(ra) # 80004220 <iput>
  end_op();
    800024da:	00003097          	auipc	ra,0x3
    800024de:	8f4080e7          	jalr	-1804(ra) # 80004dce <end_op>
  p->cwd = 0;
    800024e2:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800024e6:	00010497          	auipc	s1,0x10
    800024ea:	dd248493          	addi	s1,s1,-558 # 800122b8 <wait_lock>
    800024ee:	8526                	mv	a0,s1
    800024f0:	ffffe097          	auipc	ra,0xffffe
    800024f4:	6d2080e7          	jalr	1746(ra) # 80000bc2 <acquire>
  reparent(p);
    800024f8:	854e                	mv	a0,s3
    800024fa:	00000097          	auipc	ra,0x0
    800024fe:	f10080e7          	jalr	-240(ra) # 8000240a <reparent>
  wakeup(p->parent);
    80002502:	0389b503          	ld	a0,56(s3)
    80002506:	00000097          	auipc	ra,0x0
    8000250a:	e8e080e7          	jalr	-370(ra) # 80002394 <wakeup>
  acquire(&p->lock);
    8000250e:	854e                	mv	a0,s3
    80002510:	ffffe097          	auipc	ra,0xffffe
    80002514:	6b2080e7          	jalr	1714(ra) # 80000bc2 <acquire>
  p->xstate = status;
    80002518:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000251c:	4795                	li	a5,5
    8000251e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002522:	8526                	mv	a0,s1
    80002524:	ffffe097          	auipc	ra,0xffffe
    80002528:	752080e7          	jalr	1874(ra) # 80000c76 <release>
  sched();
    8000252c:	00000097          	auipc	ra,0x0
    80002530:	bca080e7          	jalr	-1078(ra) # 800020f6 <sched>
  panic("zombie exit");
    80002534:	00007517          	auipc	a0,0x7
    80002538:	f2c50513          	addi	a0,a0,-212 # 80009460 <digits+0x420>
    8000253c:	ffffe097          	auipc	ra,0xffffe
    80002540:	fee080e7          	jalr	-18(ra) # 8000052a <panic>

0000000080002544 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002544:	7179                	addi	sp,sp,-48
    80002546:	f406                	sd	ra,40(sp)
    80002548:	f022                	sd	s0,32(sp)
    8000254a:	ec26                	sd	s1,24(sp)
    8000254c:	e84a                	sd	s2,16(sp)
    8000254e:	e44e                	sd	s3,8(sp)
    80002550:	1800                	addi	s0,sp,48
    80002552:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002554:	00010497          	auipc	s1,0x10
    80002558:	17c48493          	addi	s1,s1,380 # 800126d0 <proc>
    8000255c:	00022997          	auipc	s3,0x22
    80002560:	57498993          	addi	s3,s3,1396 # 80024ad0 <tickslock>
  {
    acquire(&p->lock);
    80002564:	8526                	mv	a0,s1
    80002566:	ffffe097          	auipc	ra,0xffffe
    8000256a:	65c080e7          	jalr	1628(ra) # 80000bc2 <acquire>
    if (p->pid == pid)
    8000256e:	589c                	lw	a5,48(s1)
    80002570:	01278d63          	beq	a5,s2,8000258a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002574:	8526                	mv	a0,s1
    80002576:	ffffe097          	auipc	ra,0xffffe
    8000257a:	700080e7          	jalr	1792(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000257e:	49048493          	addi	s1,s1,1168
    80002582:	ff3491e3          	bne	s1,s3,80002564 <kill+0x20>
  }
  return -1;
    80002586:	557d                	li	a0,-1
    80002588:	a829                	j	800025a2 <kill+0x5e>
      p->killed = 1;
    8000258a:	4785                	li	a5,1
    8000258c:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    8000258e:	4c98                	lw	a4,24(s1)
    80002590:	4789                	li	a5,2
    80002592:	00f70f63          	beq	a4,a5,800025b0 <kill+0x6c>
      release(&p->lock);
    80002596:	8526                	mv	a0,s1
    80002598:	ffffe097          	auipc	ra,0xffffe
    8000259c:	6de080e7          	jalr	1758(ra) # 80000c76 <release>
      return 0;
    800025a0:	4501                	li	a0,0
}
    800025a2:	70a2                	ld	ra,40(sp)
    800025a4:	7402                	ld	s0,32(sp)
    800025a6:	64e2                	ld	s1,24(sp)
    800025a8:	6942                	ld	s2,16(sp)
    800025aa:	69a2                	ld	s3,8(sp)
    800025ac:	6145                	addi	sp,sp,48
    800025ae:	8082                	ret
        p->state = RUNNABLE;
    800025b0:	478d                	li	a5,3
    800025b2:	cc9c                	sw	a5,24(s1)
    800025b4:	b7cd                	j	80002596 <kill+0x52>

00000000800025b6 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025b6:	7179                	addi	sp,sp,-48
    800025b8:	f406                	sd	ra,40(sp)
    800025ba:	f022                	sd	s0,32(sp)
    800025bc:	ec26                	sd	s1,24(sp)
    800025be:	e84a                	sd	s2,16(sp)
    800025c0:	e44e                	sd	s3,8(sp)
    800025c2:	e052                	sd	s4,0(sp)
    800025c4:	1800                	addi	s0,sp,48
    800025c6:	84aa                	mv	s1,a0
    800025c8:	892e                	mv	s2,a1
    800025ca:	89b2                	mv	s3,a2
    800025cc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025ce:	fffff097          	auipc	ra,0xfffff
    800025d2:	742080e7          	jalr	1858(ra) # 80001d10 <myproc>
  if (user_dst)
    800025d6:	c08d                	beqz	s1,800025f8 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800025d8:	86d2                	mv	a3,s4
    800025da:	864e                	mv	a2,s3
    800025dc:	85ca                	mv	a1,s2
    800025de:	6928                	ld	a0,80(a0)
    800025e0:	fffff097          	auipc	ra,0xfffff
    800025e4:	db2080e7          	jalr	-590(ra) # 80001392 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025e8:	70a2                	ld	ra,40(sp)
    800025ea:	7402                	ld	s0,32(sp)
    800025ec:	64e2                	ld	s1,24(sp)
    800025ee:	6942                	ld	s2,16(sp)
    800025f0:	69a2                	ld	s3,8(sp)
    800025f2:	6a02                	ld	s4,0(sp)
    800025f4:	6145                	addi	sp,sp,48
    800025f6:	8082                	ret
    memmove((char *)dst, src, len);
    800025f8:	000a061b          	sext.w	a2,s4
    800025fc:	85ce                	mv	a1,s3
    800025fe:	854a                	mv	a0,s2
    80002600:	ffffe097          	auipc	ra,0xffffe
    80002604:	71a080e7          	jalr	1818(ra) # 80000d1a <memmove>
    return 0;
    80002608:	8526                	mv	a0,s1
    8000260a:	bff9                	j	800025e8 <either_copyout+0x32>

000000008000260c <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000260c:	7179                	addi	sp,sp,-48
    8000260e:	f406                	sd	ra,40(sp)
    80002610:	f022                	sd	s0,32(sp)
    80002612:	ec26                	sd	s1,24(sp)
    80002614:	e84a                	sd	s2,16(sp)
    80002616:	e44e                	sd	s3,8(sp)
    80002618:	e052                	sd	s4,0(sp)
    8000261a:	1800                	addi	s0,sp,48
    8000261c:	892a                	mv	s2,a0
    8000261e:	84ae                	mv	s1,a1
    80002620:	89b2                	mv	s3,a2
    80002622:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002624:	fffff097          	auipc	ra,0xfffff
    80002628:	6ec080e7          	jalr	1772(ra) # 80001d10 <myproc>
  if (user_src)
    8000262c:	c08d                	beqz	s1,8000264e <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    8000262e:	86d2                	mv	a3,s4
    80002630:	864e                	mv	a2,s3
    80002632:	85ca                	mv	a1,s2
    80002634:	6928                	ld	a0,80(a0)
    80002636:	fffff097          	auipc	ra,0xfffff
    8000263a:	dea080e7          	jalr	-534(ra) # 80001420 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000263e:	70a2                	ld	ra,40(sp)
    80002640:	7402                	ld	s0,32(sp)
    80002642:	64e2                	ld	s1,24(sp)
    80002644:	6942                	ld	s2,16(sp)
    80002646:	69a2                	ld	s3,8(sp)
    80002648:	6a02                	ld	s4,0(sp)
    8000264a:	6145                	addi	sp,sp,48
    8000264c:	8082                	ret
    memmove(dst, (char *)src, len);
    8000264e:	000a061b          	sext.w	a2,s4
    80002652:	85ce                	mv	a1,s3
    80002654:	854a                	mv	a0,s2
    80002656:	ffffe097          	auipc	ra,0xffffe
    8000265a:	6c4080e7          	jalr	1732(ra) # 80000d1a <memmove>
    return 0;
    8000265e:	8526                	mv	a0,s1
    80002660:	bff9                	j	8000263e <either_copyin+0x32>

0000000080002662 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002662:	715d                	addi	sp,sp,-80
    80002664:	e486                	sd	ra,72(sp)
    80002666:	e0a2                	sd	s0,64(sp)
    80002668:	fc26                	sd	s1,56(sp)
    8000266a:	f84a                	sd	s2,48(sp)
    8000266c:	f44e                	sd	s3,40(sp)
    8000266e:	f052                	sd	s4,32(sp)
    80002670:	ec56                	sd	s5,24(sp)
    80002672:	e85a                	sd	s6,16(sp)
    80002674:	e45e                	sd	s7,8(sp)
    80002676:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002678:	00007517          	auipc	a0,0x7
    8000267c:	02050513          	addi	a0,a0,32 # 80009698 <digits+0x658>
    80002680:	ffffe097          	auipc	ra,0xffffe
    80002684:	ef4080e7          	jalr	-268(ra) # 80000574 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002688:	00010497          	auipc	s1,0x10
    8000268c:	1a048493          	addi	s1,s1,416 # 80012828 <proc+0x158>
    80002690:	00022917          	auipc	s2,0x22
    80002694:	59890913          	addi	s2,s2,1432 # 80024c28 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002698:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000269a:	00007997          	auipc	s3,0x7
    8000269e:	dd698993          	addi	s3,s3,-554 # 80009470 <digits+0x430>
    printf("%d %s %s", p->pid, state, p->name);
    800026a2:	00007a97          	auipc	s5,0x7
    800026a6:	dd6a8a93          	addi	s5,s5,-554 # 80009478 <digits+0x438>
    printf("\n");
    800026aa:	00007a17          	auipc	s4,0x7
    800026ae:	feea0a13          	addi	s4,s4,-18 # 80009698 <digits+0x658>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026b2:	00007b97          	auipc	s7,0x7
    800026b6:	016b8b93          	addi	s7,s7,22 # 800096c8 <states.0>
    800026ba:	a00d                	j	800026dc <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026bc:	ed86a583          	lw	a1,-296(a3)
    800026c0:	8556                	mv	a0,s5
    800026c2:	ffffe097          	auipc	ra,0xffffe
    800026c6:	eb2080e7          	jalr	-334(ra) # 80000574 <printf>
    printf("\n");
    800026ca:	8552                	mv	a0,s4
    800026cc:	ffffe097          	auipc	ra,0xffffe
    800026d0:	ea8080e7          	jalr	-344(ra) # 80000574 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800026d4:	49048493          	addi	s1,s1,1168
    800026d8:	03248263          	beq	s1,s2,800026fc <procdump+0x9a>
    if (p->state == UNUSED)
    800026dc:	86a6                	mv	a3,s1
    800026de:	ec04a783          	lw	a5,-320(s1)
    800026e2:	dbed                	beqz	a5,800026d4 <procdump+0x72>
      state = "???";
    800026e4:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026e6:	fcfb6be3          	bltu	s6,a5,800026bc <procdump+0x5a>
    800026ea:	02079713          	slli	a4,a5,0x20
    800026ee:	01d75793          	srli	a5,a4,0x1d
    800026f2:	97de                	add	a5,a5,s7
    800026f4:	6390                	ld	a2,0(a5)
    800026f6:	f279                	bnez	a2,800026bc <procdump+0x5a>
      state = "???";
    800026f8:	864e                	mv	a2,s3
    800026fa:	b7c9                	j	800026bc <procdump+0x5a>
  }
}
    800026fc:	60a6                	ld	ra,72(sp)
    800026fe:	6406                	ld	s0,64(sp)
    80002700:	74e2                	ld	s1,56(sp)
    80002702:	7942                	ld	s2,48(sp)
    80002704:	79a2                	ld	s3,40(sp)
    80002706:	7a02                	ld	s4,32(sp)
    80002708:	6ae2                	ld	s5,24(sp)
    8000270a:	6b42                	ld	s6,16(sp)
    8000270c:	6ba2                	ld	s7,8(sp)
    8000270e:	6161                	addi	sp,sp,80
    80002710:	8082                	ret

0000000080002712 <get_next_free_space>:

// Next free space in swap file
int get_next_free_space(uint16 free_spaces)
{
    80002712:	1141                	addi	sp,sp,-16
    80002714:	e422                	sd	s0,8(sp)
    80002716:	0800                	addi	s0,sp,16
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
  {
    if (!(free_spaces & (1 << i)))
    80002718:	0005071b          	sext.w	a4,a0
    8000271c:	8905                	andi	a0,a0,1
    8000271e:	cd11                	beqz	a0,8000273a <get_next_free_space+0x28>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002720:	4505                	li	a0,1
    80002722:	46c1                	li	a3,16
    if (!(free_spaces & (1 << i)))
    80002724:	40a757bb          	sraw	a5,a4,a0
    80002728:	8b85                	andi	a5,a5,1
    8000272a:	c789                	beqz	a5,80002734 <get_next_free_space+0x22>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000272c:	2505                	addiw	a0,a0,1
    8000272e:	fed51be3          	bne	a0,a3,80002724 <get_next_free_space+0x12>
      return i;
  }
  return -1;
    80002732:	557d                	li	a0,-1
}
    80002734:	6422                	ld	s0,8(sp)
    80002736:	0141                	addi	sp,sp,16
    80002738:	8082                	ret
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000273a:	4501                	li	a0,0
    8000273c:	bfe5                	j	80002734 <get_next_free_space+0x22>

000000008000273e <get_index_in_page_info_array>:

// Get file vm and return file entery inside swap file if exist
int get_index_in_page_info_array(uint64 va, struct page_info *arr)
{
    8000273e:	1141                	addi	sp,sp,-16
    80002740:	e422                	sd	s0,8(sp)
    80002742:	0800                	addi	s0,sp,16
  uint64 rva = PGROUNDDOWN(va);
    80002744:	777d                	lui	a4,0xfffff
    80002746:	8f69                	and	a4,a4,a0
  for (int i = 0; i < MAX_PSYC_PAGES;i++)
    80002748:	4501                	li	a0,0
    8000274a:	46c1                	li	a3,16
  {
    struct page_info *po = &arr[i];
    if (po->va == rva)
    8000274c:	619c                	ld	a5,0(a1)
    8000274e:	00e78763          	beq	a5,a4,8000275c <get_index_in_page_info_array+0x1e>
  for (int i = 0; i < MAX_PSYC_PAGES;i++)
    80002752:	2505                	addiw	a0,a0,1
    80002754:	05e1                	addi	a1,a1,24
    80002756:	fed51be3          	bne	a0,a3,8000274c <get_index_in_page_info_array+0xe>
    {
      return i;
    }
  }
  return -1; // if not found return null
    8000275a:	557d                	li	a0,-1
}
    8000275c:	6422                	ld	s0,8(sp)
    8000275e:	0141                	addi	sp,sp,16
    80002760:	8082                	ret

0000000080002762 <page_out>:
//  free physical memory of page which virtual address va
//  write this page to procs swap file
//  return the new free physical address
uint64
page_out(uint64 va)
{
    80002762:	7179                	addi	sp,sp,-48
    80002764:	f406                	sd	ra,40(sp)
    80002766:	f022                	sd	s0,32(sp)
    80002768:	ec26                	sd	s1,24(sp)
    8000276a:	e84a                	sd	s2,16(sp)
    8000276c:	e44e                	sd	s3,8(sp)
    8000276e:	e052                	sd	s4,0(sp)
    80002770:	1800                	addi	s0,sp,48
    80002772:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002774:	fffff097          	auipc	ra,0xfffff
    80002778:	59c080e7          	jalr	1436(ra) # 80001d10 <myproc>
    8000277c:	8a2a                	mv	s4,a0

  uint64 rva = PGROUNDDOWN(va);
    8000277e:	797d                	lui	s2,0xfffff
    80002780:	0124f933          	and	s2,s1,s2
  // find the addres of the page which sent out
  // amit 30/05/2021
  // uint64 pa = walkaddr(p->pagetable, rva, 1); // return with pte valid = 0 
  //   printf("pageout b\n");

    pte_t *pte  = walk(p->pagetable, va, 0);
    80002784:	4601                	li	a2,0
    80002786:	85a6                	mv	a1,s1
    80002788:	6928                	ld	a0,80(a0)
    8000278a:	fffff097          	auipc	ra,0xfffff
    8000278e:	81c080e7          	jalr	-2020(ra) # 80000fa6 <walk>
    80002792:	89aa                	mv	s3,a0
    uint64 pa = PTE2PA(*pte);
    80002794:	6104                	ld	s1,0(a0)
  // printf("pageout a\n");

  // insert the page to the swap file
  
  int page_index = insert_page_to_swap_file(rva);
    80002796:	854a                	mv	a0,s2
    80002798:	fffff097          	auipc	ra,0xfffff
    8000279c:	dce080e7          	jalr	-562(ra) # 80001566 <insert_page_to_swap_file>

  int start_offset = page_index * PGSIZE;
  if (page_index < 0 || page_index >= MAX_PSYC_PAGES)
    800027a0:	0005079b          	sext.w	a5,a0
    800027a4:	473d                	li	a4,15
    800027a6:	04f76d63          	bltu	a4,a5,80002800 <page_out+0x9e>
    800027aa:	80a9                	srli	s1,s1,0xa
    800027ac:	04b2                	slli	s1,s1,0xc
    800027ae:	00c5161b          	slliw	a2,a0,0xc
    panic("fadge no free index in page_out");

  writeToSwapFile(p, (char *)pa, start_offset, PGSIZE); // Write page to swap file
    800027b2:	6685                	lui	a3,0x1
    800027b4:	2601                	sext.w	a2,a2
    800027b6:	85a6                	mv	a1,s1
    800027b8:	8552                	mv	a0,s4
    800027ba:	00002097          	auipc	ra,0x2
    800027be:	366080e7          	jalr	870(ra) # 80004b20 <writeToSwapFile>

  // Update the ram info struct
  remove_page_from_physical_memory(rva);
    800027c2:	854a                	mv	a0,s2
    800027c4:	fffff097          	auipc	ra,0xfffff
    800027c8:	ecc080e7          	jalr	-308(ra) # 80001690 <remove_page_from_physical_memory>
  p->physical_pages_num--;
    800027cc:	170a2783          	lw	a5,368(s4)
    800027d0:	37fd                	addiw	a5,a5,-1
    800027d2:	16fa2823          	sw	a5,368(s4)
  
  // free space in physical memory
  kfree((void *)pa);
    800027d6:	8526                	mv	a0,s1
    800027d8:	ffffe097          	auipc	ra,0xffffe
    800027dc:	1fe080e7          	jalr	510(ra) # 800009d6 <kfree>

  // walkaddr(p->pagetable, rva, 1); // return with pte valid = 0 
      *pte &= ~PTE_V;  // page table entry now invalid
    800027e0:	0009b783          	ld	a5,0(s3)
    800027e4:	9bf9                	andi	a5,a5,-2
    *pte |= PTE_PG; // paged out to secondary storage
    800027e6:	2007e793          	ori	a5,a5,512
    800027ea:	00f9b023          	sd	a5,0(s3)

  return pa;
}
    800027ee:	8526                	mv	a0,s1
    800027f0:	70a2                	ld	ra,40(sp)
    800027f2:	7402                	ld	s0,32(sp)
    800027f4:	64e2                	ld	s1,24(sp)
    800027f6:	6942                	ld	s2,16(sp)
    800027f8:	69a2                	ld	s3,8(sp)
    800027fa:	6a02                	ld	s4,0(sp)
    800027fc:	6145                	addi	sp,sp,48
    800027fe:	8082                	ret
    panic("fadge no free index in page_out");
    80002800:	00007517          	auipc	a0,0x7
    80002804:	c8850513          	addi	a0,a0,-888 # 80009488 <digits+0x448>
    80002808:	ffffe097          	auipc	ra,0xffffe
    8000280c:	d22080e7          	jalr	-734(ra) # 8000052a <panic>

0000000080002810 <page_in>:

// move page from swap file to physical memory
pte_t *
page_in(uint64 va, pte_t *pte)
{
    80002810:	7139                	addi	sp,sp,-64
    80002812:	fc06                	sd	ra,56(sp)
    80002814:	f822                	sd	s0,48(sp)
    80002816:	f426                	sd	s1,40(sp)
    80002818:	f04a                	sd	s2,32(sp)
    8000281a:	ec4e                	sd	s3,24(sp)
    8000281c:	e852                	sd	s4,16(sp)
    8000281e:	e456                	sd	s5,8(sp)
    80002820:	e05a                	sd	s6,0(sp)
    80002822:	0080                	addi	s0,sp,64
    80002824:	8b2a                	mv	s6,a0
    80002826:	84ae                	mv	s1,a1
  uint64 pa;
  struct proc *p = myproc();
    80002828:	fffff097          	auipc	ra,0xfffff
    8000282c:	4e8080e7          	jalr	1256(ra) # 80001d10 <myproc>
    80002830:	892a                	mv	s2,a0
  uint64 rva = PGROUNDDOWN(va);
    80002832:	7afd                	lui	s5,0xfffff
    80002834:	015b7ab3          	and	s5,s6,s5
  // update swap info
  int swap_old_index = remove_page_from_swap_file(rva);
    80002838:	8556                	mv	a0,s5
    8000283a:	fffff097          	auipc	ra,0xfffff
    8000283e:	ebe080e7          	jalr	-322(ra) # 800016f8 <remove_page_from_swap_file>
  
  if(swap_old_index <0)
    80002842:	06054c63          	bltz	a0,800028ba <page_in+0xaa>
    80002846:	8a2a                	mv	s4,a0
    panic("page_in: index in swap file not found");

  // alloc page in physical memory
  if ((pa = (uint64)kalloc()) == 0){
    80002848:	ffffe097          	auipc	ra,0xffffe
    8000284c:	28a080e7          	jalr	650(ra) # 80000ad2 <kalloc>
    80002850:	89aa                	mv	s3,a0
    80002852:	cd25                	beqz	a0,800028ca <page_in+0xba>
    printf("retrievingpage: kalloc failed\n");
    return -1;
  }

  mappages(p->pagetable, va, PGSIZE, (uint64)pa, PTE_FLAGS(*pte));
    80002854:	6098                	ld	a4,0(s1)
    80002856:	3ff77713          	andi	a4,a4,1023
    8000285a:	86aa                	mv	a3,a0
    8000285c:	6605                	lui	a2,0x1
    8000285e:	85da                	mv	a1,s6
    80002860:	05093503          	ld	a0,80(s2) # fffffffffffff050 <end+0xffffffff7ffcc050>
    80002864:	fffff097          	auipc	ra,0xfffff
    80002868:	83e080e7          	jalr	-1986(ra) # 800010a2 <mappages>


    // update physc info
  int physc_new_index = insert_page_to_physical_memory(rva);
    8000286c:	8556                	mv	a0,s5
    8000286e:	fffff097          	auipc	ra,0xfffff
    80002872:	d78080e7          	jalr	-648(ra) # 800015e6 <insert_page_to_physical_memory>
  p->physical_pages_num++;
    80002876:	17092783          	lw	a5,368(s2)
    8000287a:	2785                	addiw	a5,a5,1
    8000287c:	16f92823          	sw	a5,368(s2)

  // Write to swap file
  int start_offset = swap_old_index * PGSIZE;
  readFromSwapFile(p, (char*)pa, start_offset, PGSIZE);
    80002880:	6685                	lui	a3,0x1
    80002882:	00ca161b          	slliw	a2,s4,0xc
    80002886:	85ce                	mv	a1,s3
    80002888:	854a                	mv	a0,s2
    8000288a:	00002097          	auipc	ra,0x2
    8000288e:	2ba080e7          	jalr	698(ra) # 80004b44 <readFromSwapFile>

  // update pte
  if (!(*pte & PTE_PG))
    80002892:	609c                	ld	a5,0(s1)
    80002894:	2007f713          	andi	a4,a5,512
    80002898:	c339                	beqz	a4,800028de <page_in+0xce>
    panic("page in: page out flag was off");
  *pte = (*pte | PTE_V) &(~PTE_PG);
    8000289a:	dfe7f793          	andi	a5,a5,-514
    8000289e:	0017e793          	ori	a5,a5,1
    800028a2:	e09c                	sd	a5,0(s1)

  return pte;
    800028a4:	8526                	mv	a0,s1
}
    800028a6:	70e2                	ld	ra,56(sp)
    800028a8:	7442                	ld	s0,48(sp)
    800028aa:	74a2                	ld	s1,40(sp)
    800028ac:	7902                	ld	s2,32(sp)
    800028ae:	69e2                	ld	s3,24(sp)
    800028b0:	6a42                	ld	s4,16(sp)
    800028b2:	6aa2                	ld	s5,8(sp)
    800028b4:	6b02                	ld	s6,0(sp)
    800028b6:	6121                	addi	sp,sp,64
    800028b8:	8082                	ret
    panic("page_in: index in swap file not found");
    800028ba:	00007517          	auipc	a0,0x7
    800028be:	bee50513          	addi	a0,a0,-1042 # 800094a8 <digits+0x468>
    800028c2:	ffffe097          	auipc	ra,0xffffe
    800028c6:	c68080e7          	jalr	-920(ra) # 8000052a <panic>
    printf("retrievingpage: kalloc failed\n");
    800028ca:	00007517          	auipc	a0,0x7
    800028ce:	c0650513          	addi	a0,a0,-1018 # 800094d0 <digits+0x490>
    800028d2:	ffffe097          	auipc	ra,0xffffe
    800028d6:	ca2080e7          	jalr	-862(ra) # 80000574 <printf>
    return -1;
    800028da:	557d                	li	a0,-1
    800028dc:	b7e9                	j	800028a6 <page_in+0x96>
    panic("page in: page out flag was off");
    800028de:	00007517          	auipc	a0,0x7
    800028e2:	c1250513          	addi	a0,a0,-1006 # 800094f0 <digits+0x4b0>
    800028e6:	ffffe097          	auipc	ra,0xffffe
    800028ea:	c44080e7          	jalr	-956(ra) # 8000052a <panic>

00000000800028ee <copyFilesInfo>:

void copyFilesInfo(struct proc *p, struct proc *np)
{
    800028ee:	7139                	addi	sp,sp,-64
    800028f0:	fc06                	sd	ra,56(sp)
    800028f2:	f822                	sd	s0,48(sp)
    800028f4:	f426                	sd	s1,40(sp)
    800028f6:	f04a                	sd	s2,32(sp)
    800028f8:	ec4e                	sd	s3,24(sp)
    800028fa:	e852                	sd	s4,16(sp)
    800028fc:	e456                	sd	s5,8(sp)
    800028fe:	e05a                	sd	s6,0(sp)
    80002900:	0080                	addi	s0,sp,64
    80002902:	89aa                	mv	s3,a0
    80002904:	84ae                	mv	s1,a1
  // Copy swapfile
  void *temp_page;

  if (!(temp_page = kalloc()))
    80002906:	ffffe097          	auipc	ra,0xffffe
    8000290a:	1cc080e7          	jalr	460(ra) # 80000ad2 <kalloc>
    8000290e:	8b2a                	mv	s6,a0
    panic("copyFilesInfo: kalloc failed");

  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002910:	4901                	li	s2,0
    80002912:	4a41                	li	s4,16
  if (!(temp_page = kalloc()))
    80002914:	e505                	bnez	a0,8000293c <copyFilesInfo+0x4e>
    panic("copyFilesInfo: kalloc failed");
    80002916:	00007517          	auipc	a0,0x7
    8000291a:	bfa50513          	addi	a0,a0,-1030 # 80009510 <digits+0x4d0>
    8000291e:	ffffe097          	auipc	ra,0xffffe
    80002922:	c0c080e7          	jalr	-1012(ra) # 8000052a <panic>
    if (p->pages_swap_info.free_spaces & (1 << i))
    {
      int res = readFromSwapFile(p, (char *)temp_page, i * PGSIZE, PGSIZE);

      if (res < 0)
        panic("copyFilesInfo: failed read");
    80002926:	00007517          	auipc	a0,0x7
    8000292a:	c0a50513          	addi	a0,a0,-1014 # 80009530 <digits+0x4f0>
    8000292e:	ffffe097          	auipc	ra,0xffffe
    80002932:	bfc080e7          	jalr	-1028(ra) # 8000052a <panic>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002936:	2905                	addiw	s2,s2,1
    80002938:	05490663          	beq	s2,s4,80002984 <copyFilesInfo+0x96>
    if (p->pages_swap_info.free_spaces & (1 << i))
    8000293c:	1789d783          	lhu	a5,376(s3)
    80002940:	4127d7bb          	sraw	a5,a5,s2
    80002944:	8b85                	andi	a5,a5,1
    80002946:	dbe5                	beqz	a5,80002936 <copyFilesInfo+0x48>
      int res = readFromSwapFile(p, (char *)temp_page, i * PGSIZE, PGSIZE);
    80002948:	00c91a9b          	slliw	s5,s2,0xc
    8000294c:	6685                	lui	a3,0x1
    8000294e:	8656                	mv	a2,s5
    80002950:	85da                	mv	a1,s6
    80002952:	854e                	mv	a0,s3
    80002954:	00002097          	auipc	ra,0x2
    80002958:	1f0080e7          	jalr	496(ra) # 80004b44 <readFromSwapFile>
      if (res < 0)
    8000295c:	fc0545e3          	bltz	a0,80002926 <copyFilesInfo+0x38>

      res = writeToSwapFile(np, temp_page, i * PGSIZE, PGSIZE);
    80002960:	6685                	lui	a3,0x1
    80002962:	8656                	mv	a2,s5
    80002964:	85da                	mv	a1,s6
    80002966:	8526                	mv	a0,s1
    80002968:	00002097          	auipc	ra,0x2
    8000296c:	1b8080e7          	jalr	440(ra) # 80004b20 <writeToSwapFile>

      if (res < 0)
    80002970:	fc0553e3          	bgez	a0,80002936 <copyFilesInfo+0x48>
        panic("copyFilesInfo: faild write ");
    80002974:	00007517          	auipc	a0,0x7
    80002978:	bdc50513          	addi	a0,a0,-1060 # 80009550 <digits+0x510>
    8000297c:	ffffe097          	auipc	ra,0xffffe
    80002980:	bae080e7          	jalr	-1106(ra) # 8000052a <panic>
    }
  }

  kfree(temp_page);
    80002984:	855a                	mv	a0,s6
    80002986:	ffffe097          	auipc	ra,0xffffe
    8000298a:	050080e7          	jalr	80(ra) # 800009d6 <kfree>

  // Copy swap and ram structs
  np->pages_swap_info.free_spaces = p->pages_swap_info.free_spaces;
    8000298e:	1789d783          	lhu	a5,376(s3)
    80002992:	16f49c23          	sh	a5,376(s1)
  np->pages_physc_info.free_spaces = p->pages_physc_info.free_spaces;
    80002996:	3009d783          	lhu	a5,768(s3)
    8000299a:	30f49023          	sh	a5,768(s1)

  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000299e:	18098793          	addi	a5,s3,384
    800029a2:	18048593          	addi	a1,s1,384
    800029a6:	30098993          	addi	s3,s3,768
  {
    np->pages_swap_info.pages[i] = p->pages_swap_info.pages[i];
    800029aa:	6398                	ld	a4,0(a5)
    800029ac:	e198                	sd	a4,0(a1)
    800029ae:	6798                	ld	a4,8(a5)
    800029b0:	e598                	sd	a4,8(a1)
    800029b2:	6b98                	ld	a4,16(a5)
    800029b4:	e998                	sd	a4,16(a1)
    np->pages_physc_info.pages[i] = p->pages_physc_info.pages[i];
    800029b6:	1887b703          	ld	a4,392(a5)
    800029ba:	18e5b423          	sd	a4,392(a1)
    800029be:	1907b703          	ld	a4,400(a5)
    800029c2:	18e5b823          	sd	a4,400(a1)
    800029c6:	1987b703          	ld	a4,408(a5)
    800029ca:	18e5bc23          	sd	a4,408(a1)
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    800029ce:	07e1                	addi	a5,a5,24
    800029d0:	05e1                	addi	a1,a1,24
    800029d2:	fd379ce3          	bne	a5,s3,800029aa <copyFilesInfo+0xbc>
  }

}
    800029d6:	70e2                	ld	ra,56(sp)
    800029d8:	7442                	ld	s0,48(sp)
    800029da:	74a2                	ld	s1,40(sp)
    800029dc:	7902                	ld	s2,32(sp)
    800029de:	69e2                	ld	s3,24(sp)
    800029e0:	6a42                	ld	s4,16(sp)
    800029e2:	6aa2                	ld	s5,8(sp)
    800029e4:	6b02                	ld	s6,0(sp)
    800029e6:	6121                	addi	sp,sp,64
    800029e8:	8082                	ret

00000000800029ea <fork>:
{
    800029ea:	7139                	addi	sp,sp,-64
    800029ec:	fc06                	sd	ra,56(sp)
    800029ee:	f822                	sd	s0,48(sp)
    800029f0:	f426                	sd	s1,40(sp)
    800029f2:	f04a                	sd	s2,32(sp)
    800029f4:	ec4e                	sd	s3,24(sp)
    800029f6:	e852                	sd	s4,16(sp)
    800029f8:	e456                	sd	s5,8(sp)
    800029fa:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800029fc:	fffff097          	auipc	ra,0xfffff
    80002a00:	314080e7          	jalr	788(ra) # 80001d10 <myproc>
    80002a04:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80002a06:	fffff097          	auipc	ra,0xfffff
    80002a0a:	518080e7          	jalr	1304(ra) # 80001f1e <allocproc>
    80002a0e:	12050f63          	beqz	a0,80002b4c <fork+0x162>
    80002a12:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002a14:	048ab603          	ld	a2,72(s5) # fffffffffffff048 <end+0xffffffff7ffcc048>
    80002a18:	692c                	ld	a1,80(a0)
    80002a1a:	050ab503          	ld	a0,80(s5)
    80002a1e:	fffff097          	auipc	ra,0xfffff
    80002a22:	088080e7          	jalr	136(ra) # 80001aa6 <uvmcopy>
    80002a26:	04054863          	bltz	a0,80002a76 <fork+0x8c>
  np->sz = p->sz;
    80002a2a:	048ab783          	ld	a5,72(s5)
    80002a2e:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80002a32:	058ab683          	ld	a3,88(s5)
    80002a36:	87b6                	mv	a5,a3
    80002a38:	0589b703          	ld	a4,88(s3)
    80002a3c:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    80002a40:	0007b803          	ld	a6,0(a5)
    80002a44:	6788                	ld	a0,8(a5)
    80002a46:	6b8c                	ld	a1,16(a5)
    80002a48:	6f90                	ld	a2,24(a5)
    80002a4a:	01073023          	sd	a6,0(a4) # fffffffffffff000 <end+0xffffffff7ffcc000>
    80002a4e:	e708                	sd	a0,8(a4)
    80002a50:	eb0c                	sd	a1,16(a4)
    80002a52:	ef10                	sd	a2,24(a4)
    80002a54:	02078793          	addi	a5,a5,32
    80002a58:	02070713          	addi	a4,a4,32
    80002a5c:	fed792e3          	bne	a5,a3,80002a40 <fork+0x56>
  np->trapframe->a0 = 0;
    80002a60:	0589b783          	ld	a5,88(s3)
    80002a64:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80002a68:	0d0a8493          	addi	s1,s5,208
    80002a6c:	0d098913          	addi	s2,s3,208
    80002a70:	150a8a13          	addi	s4,s5,336
    80002a74:	a00d                	j	80002a96 <fork+0xac>
    freeproc(np);
    80002a76:	854e                	mv	a0,s3
    80002a78:	fffff097          	auipc	ra,0xfffff
    80002a7c:	44a080e7          	jalr	1098(ra) # 80001ec2 <freeproc>
    release(&np->lock);
    80002a80:	854e                	mv	a0,s3
    80002a82:	ffffe097          	auipc	ra,0xffffe
    80002a86:	1f4080e7          	jalr	500(ra) # 80000c76 <release>
    return -1;
    80002a8a:	597d                	li	s2,-1
    80002a8c:	a075                	j	80002b38 <fork+0x14e>
  for (i = 0; i < NOFILE; i++)
    80002a8e:	04a1                	addi	s1,s1,8
    80002a90:	0921                	addi	s2,s2,8
    80002a92:	01448b63          	beq	s1,s4,80002aa8 <fork+0xbe>
    if (p->ofile[i])
    80002a96:	6088                	ld	a0,0(s1)
    80002a98:	d97d                	beqz	a0,80002a8e <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80002a9a:	00002097          	auipc	ra,0x2
    80002a9e:	72e080e7          	jalr	1838(ra) # 800051c8 <filedup>
    80002aa2:	00a93023          	sd	a0,0(s2)
    80002aa6:	b7e5                	j	80002a8e <fork+0xa4>
  np->cwd = idup(p->cwd);
    80002aa8:	150ab503          	ld	a0,336(s5)
    80002aac:	00001097          	auipc	ra,0x1
    80002ab0:	57c080e7          	jalr	1404(ra) # 80004028 <idup>
    80002ab4:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002ab8:	4641                	li	a2,16
    80002aba:	158a8593          	addi	a1,s5,344
    80002abe:	15898513          	addi	a0,s3,344
    80002ac2:	ffffe097          	auipc	ra,0xffffe
    80002ac6:	34e080e7          	jalr	846(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80002aca:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002ace:	854e                	mv	a0,s3
    80002ad0:	ffffe097          	auipc	ra,0xffffe
    80002ad4:	1a6080e7          	jalr	422(ra) # 80000c76 <release>
  createSwapFile(np);
    80002ad8:	854e                	mv	a0,s3
    80002ada:	00002097          	auipc	ra,0x2
    80002ade:	f96080e7          	jalr	-106(ra) # 80004a70 <createSwapFile>
    copyFilesInfo(p, np); // TODO: check we need to this for father 1,2 
    80002ae2:	85ce                	mv	a1,s3
    80002ae4:	8556                	mv	a0,s5
    80002ae6:	00000097          	auipc	ra,0x0
    80002aea:	e08080e7          	jalr	-504(ra) # 800028ee <copyFilesInfo>
  np->physical_pages_num = p->physical_pages_num;
    80002aee:	170aa783          	lw	a5,368(s5)
    80002af2:	16f9a823          	sw	a5,368(s3)
  np->total_pages_num = p->total_pages_num;
    80002af6:	174aa783          	lw	a5,372(s5)
    80002afa:	16f9aa23          	sw	a5,372(s3)
  acquire(&wait_lock);
    80002afe:	0000f497          	auipc	s1,0xf
    80002b02:	7ba48493          	addi	s1,s1,1978 # 800122b8 <wait_lock>
    80002b06:	8526                	mv	a0,s1
    80002b08:	ffffe097          	auipc	ra,0xffffe
    80002b0c:	0ba080e7          	jalr	186(ra) # 80000bc2 <acquire>
  np->parent = p;
    80002b10:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002b14:	8526                	mv	a0,s1
    80002b16:	ffffe097          	auipc	ra,0xffffe
    80002b1a:	160080e7          	jalr	352(ra) # 80000c76 <release>
  acquire(&np->lock);
    80002b1e:	854e                	mv	a0,s3
    80002b20:	ffffe097          	auipc	ra,0xffffe
    80002b24:	0a2080e7          	jalr	162(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80002b28:	478d                	li	a5,3
    80002b2a:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002b2e:	854e                	mv	a0,s3
    80002b30:	ffffe097          	auipc	ra,0xffffe
    80002b34:	146080e7          	jalr	326(ra) # 80000c76 <release>
}
    80002b38:	854a                	mv	a0,s2
    80002b3a:	70e2                	ld	ra,56(sp)
    80002b3c:	7442                	ld	s0,48(sp)
    80002b3e:	74a2                	ld	s1,40(sp)
    80002b40:	7902                	ld	s2,32(sp)
    80002b42:	69e2                	ld	s3,24(sp)
    80002b44:	6a42                	ld	s4,16(sp)
    80002b46:	6aa2                	ld	s5,8(sp)
    80002b48:	6121                	addi	sp,sp,64
    80002b4a:	8082                	ret
    return -1;
    80002b4c:	597d                	li	s2,-1
    80002b4e:	b7ed                	j	80002b38 <fork+0x14e>

0000000080002b50 <NFUA_compare>:
  return selected_pg_index;
}

long NFUA_compare(struct page_info *pg1, struct page_info *pg2)
{
  if (!pg1 || !pg2)
    80002b50:	c511                	beqz	a0,80002b5c <NFUA_compare+0xc>
    80002b52:	c589                	beqz	a1,80002b5c <NFUA_compare+0xc>
    panic("NFUA_compare : null input");
  return pg1->aging_counter - pg2->aging_counter;
    80002b54:	6508                	ld	a0,8(a0)
    80002b56:	659c                	ld	a5,8(a1)
}
    80002b58:	8d1d                	sub	a0,a0,a5
    80002b5a:	8082                	ret
{
    80002b5c:	1141                	addi	sp,sp,-16
    80002b5e:	e406                	sd	ra,8(sp)
    80002b60:	e022                	sd	s0,0(sp)
    80002b62:	0800                	addi	s0,sp,16
    panic("NFUA_compare : null input");
    80002b64:	00007517          	auipc	a0,0x7
    80002b68:	a0c50513          	addi	a0,a0,-1524 # 80009570 <digits+0x530>
    80002b6c:	ffffe097          	auipc	ra,0xffffe
    80002b70:	9be080e7          	jalr	-1602(ra) # 8000052a <panic>

0000000080002b74 <SCFIFO_compare>:
  return res;
}

int SCFIFO_compare(struct page_info *pg1, struct page_info *pg2)
{
  if (!pg1 || !pg2)
    80002b74:	c511                	beqz	a0,80002b80 <SCFIFO_compare+0xc>
    80002b76:	c589                	beqz	a1,80002b80 <SCFIFO_compare+0xc>
    panic("SCFIFO_compare : null input");

  return pg1->time_inserted - pg2->time_inserted;
    80002b78:	4908                	lw	a0,16(a0)
    80002b7a:	499c                	lw	a5,16(a1)
}
    80002b7c:	9d1d                	subw	a0,a0,a5
    80002b7e:	8082                	ret
{
    80002b80:	1141                	addi	sp,sp,-16
    80002b82:	e406                	sd	ra,8(sp)
    80002b84:	e022                	sd	s0,0(sp)
    80002b86:	0800                	addi	s0,sp,16
    panic("SCFIFO_compare : null input");
    80002b88:	00007517          	auipc	a0,0x7
    80002b8c:	a0850513          	addi	a0,a0,-1528 # 80009590 <digits+0x550>
    80002b90:	ffffe097          	auipc	ra,0xffffe
    80002b94:	99a080e7          	jalr	-1638(ra) # 8000052a <panic>

0000000080002b98 <countOnes>:

long countOnes(long n)
{
    80002b98:	1141                	addi	sp,sp,-16
    80002b9a:	e422                	sd	s0,8(sp)
    80002b9c:	0800                	addi	s0,sp,16
  int count = 0;
  while (n)
    80002b9e:	c919                	beqz	a0,80002bb4 <countOnes+0x1c>
    80002ba0:	87aa                	mv	a5,a0
  int count = 0;
    80002ba2:	4501                	li	a0,0
  {
    count += n & 1;
    80002ba4:	0017f713          	andi	a4,a5,1
    80002ba8:	9d39                	addw	a0,a0,a4
    n >>= 1;
    80002baa:	8785                	srai	a5,a5,0x1
  while (n)
    80002bac:	ffe5                	bnez	a5,80002ba4 <countOnes+0xc>
  }
  return count;
}
    80002bae:	6422                	ld	s0,8(sp)
    80002bb0:	0141                	addi	sp,sp,16
    80002bb2:	8082                	ret
  int count = 0;
    80002bb4:	4501                	li	a0,0
    80002bb6:	bfe5                	j	80002bae <countOnes+0x16>

0000000080002bb8 <LAPA_compare>:
{
    80002bb8:	7179                	addi	sp,sp,-48
    80002bba:	f406                	sd	ra,40(sp)
    80002bbc:	f022                	sd	s0,32(sp)
    80002bbe:	ec26                	sd	s1,24(sp)
    80002bc0:	e84a                	sd	s2,16(sp)
    80002bc2:	e44e                	sd	s3,8(sp)
    80002bc4:	1800                	addi	s0,sp,48
  if (!pg1 || !pg2)
    80002bc6:	cd0d                	beqz	a0,80002c00 <LAPA_compare+0x48>
    80002bc8:	892e                	mv	s2,a1
    80002bca:	c99d                	beqz	a1,80002c00 <LAPA_compare+0x48>
  int res = countOnes(pg1->aging_counter) - countOnes(pg2->aging_counter);
    80002bcc:	00853983          	ld	s3,8(a0)
    80002bd0:	854e                	mv	a0,s3
    80002bd2:	00000097          	auipc	ra,0x0
    80002bd6:	fc6080e7          	jalr	-58(ra) # 80002b98 <countOnes>
    80002bda:	84aa                	mv	s1,a0
    80002bdc:	00893903          	ld	s2,8(s2)
    80002be0:	854a                	mv	a0,s2
    80002be2:	00000097          	auipc	ra,0x0
    80002be6:	fb6080e7          	jalr	-74(ra) # 80002b98 <countOnes>
    80002bea:	40a487bb          	subw	a5,s1,a0
  return res;
    80002bee:	853e                	mv	a0,a5
  if (res == 0)
    80002bf0:	c385                	beqz	a5,80002c10 <LAPA_compare+0x58>
}
    80002bf2:	70a2                	ld	ra,40(sp)
    80002bf4:	7402                	ld	s0,32(sp)
    80002bf6:	64e2                	ld	s1,24(sp)
    80002bf8:	6942                	ld	s2,16(sp)
    80002bfa:	69a2                	ld	s3,8(sp)
    80002bfc:	6145                	addi	sp,sp,48
    80002bfe:	8082                	ret
    panic("LAPA_compare : null input");
    80002c00:	00007517          	auipc	a0,0x7
    80002c04:	9b050513          	addi	a0,a0,-1616 # 800095b0 <digits+0x570>
    80002c08:	ffffe097          	auipc	ra,0xffffe
    80002c0c:	922080e7          	jalr	-1758(ra) # 8000052a <panic>
    return pg1->aging_counter - pg2->aging_counter;
    80002c10:	41298533          	sub	a0,s3,s2
    80002c14:	bff9                	j	80002bf2 <LAPA_compare+0x3a>

0000000080002c16 <compare_all_pages>:

// Return the index of the page to swap out acording to paging policy
int compare_all_pages(long (*compare)(struct page_info *pg1, struct page_info *pg2))
{
    80002c16:	715d                	addi	sp,sp,-80
    80002c18:	e486                	sd	ra,72(sp)
    80002c1a:	e0a2                	sd	s0,64(sp)
    80002c1c:	fc26                	sd	s1,56(sp)
    80002c1e:	f84a                	sd	s2,48(sp)
    80002c20:	f44e                	sd	s3,40(sp)
    80002c22:	f052                	sd	s4,32(sp)
    80002c24:	ec56                	sd	s5,24(sp)
    80002c26:	e85a                	sd	s6,16(sp)
    80002c28:	e45e                	sd	s7,8(sp)
    80002c2a:	e062                	sd	s8,0(sp)
    80002c2c:	0880                	addi	s0,sp,80
    80002c2e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002c30:	fffff097          	auipc	ra,0xfffff
    80002c34:	0e0080e7          	jalr	224(ra) # 80001d10 <myproc>
    80002c38:	89aa                	mv	s3,a0
  struct page_info *pg_to_swap = 0;
  int min_index = -1;

  

  for (int i=0;i<MAX_PSYC_PAGES;i++)
    80002c3a:	30850913          	addi	s2,a0,776
    80002c3e:	4481                	li	s1,0
  int min_index = -1;
    80002c40:	5bfd                	li	s7,-1
  struct page_info *pg_to_swap = 0;
    80002c42:	4a01                	li	s4,0
  for (int i=0;i<MAX_PSYC_PAGES;i++)
    80002c44:	4ac1                	li	s5,16
    80002c46:	a039                	j	80002c54 <compare_all_pages+0x3e>
    80002c48:	8ba6                	mv	s7,s1
    //     pg->aging_counter |= 0x80000000;
    // #endif
    if ((p->pages_physc_info.free_spaces & (1 << i)) && (!pg_to_swap || compare(pg, pg_to_swap) < 0))
    {
      // in case pg_to_swap have not yet been initialize or the current pg is less needable acording to policy
      pg_to_swap = pg;
    80002c4a:	8a4a                	mv	s4,s2
  for (int i=0;i<MAX_PSYC_PAGES;i++)
    80002c4c:	2485                	addiw	s1,s1,1
    80002c4e:	0961                	addi	s2,s2,24
    80002c50:	03548263          	beq	s1,s5,80002c74 <compare_all_pages+0x5e>
    if ((p->pages_physc_info.free_spaces & (1 << i)) && (!pg_to_swap || compare(pg, pg_to_swap) < 0))
    80002c54:	3009d783          	lhu	a5,768(s3)
    80002c58:	4097d7bb          	sraw	a5,a5,s1
    80002c5c:	8b85                	andi	a5,a5,1
    80002c5e:	d7fd                	beqz	a5,80002c4c <compare_all_pages+0x36>
    80002c60:	fe0a04e3          	beqz	s4,80002c48 <compare_all_pages+0x32>
    80002c64:	85d2                	mv	a1,s4
    80002c66:	854a                	mv	a0,s2
    80002c68:	9b02                	jalr	s6
    80002c6a:	fe0551e3          	bgez	a0,80002c4c <compare_all_pages+0x36>
    80002c6e:	8ba6                	mv	s7,s1
      pg_to_swap = pg;
    80002c70:	8a4a                	mv	s4,s2
    80002c72:	bfe9                	j	80002c4c <compare_all_pages+0x36>
      min_index = i;
    }
  }
  return min_index;
}
    80002c74:	855e                	mv	a0,s7
    80002c76:	60a6                	ld	ra,72(sp)
    80002c78:	6406                	ld	s0,64(sp)
    80002c7a:	74e2                	ld	s1,56(sp)
    80002c7c:	7942                	ld	s2,48(sp)
    80002c7e:	79a2                	ld	s3,40(sp)
    80002c80:	7a02                	ld	s4,32(sp)
    80002c82:	6ae2                	ld	s5,24(sp)
    80002c84:	6b42                	ld	s6,16(sp)
    80002c86:	6ba2                	ld	s7,8(sp)
    80002c88:	6c02                	ld	s8,0(sp)
    80002c8a:	6161                	addi	sp,sp,80
    80002c8c:	8082                	ret

0000000080002c8e <is_accessed>:
  if(acc)
    pg->aging_counter = pg->aging_counter | 0x80000000; // if page was accessed set MSB to 1
}

long is_accessed(struct page_info *pg, int to_reset)
{
    80002c8e:	1101                	addi	sp,sp,-32
    80002c90:	ec06                	sd	ra,24(sp)
    80002c92:	e822                	sd	s0,16(sp)
    80002c94:	e426                	sd	s1,8(sp)
    80002c96:	e04a                	sd	s2,0(sp)
    80002c98:	1000                	addi	s0,sp,32
    80002c9a:	84aa                	mv	s1,a0
    80002c9c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c9e:	fffff097          	auipc	ra,0xfffff
    80002ca2:	072080e7          	jalr	114(ra) # 80001d10 <myproc>
  pte_t *pte = walk(p->pagetable, pg->va, 0);
    80002ca6:	4601                	li	a2,0
    80002ca8:	608c                	ld	a1,0(s1)
    80002caa:	6928                	ld	a0,80(a0)
    80002cac:	ffffe097          	auipc	ra,0xffffe
    80002cb0:	2fa080e7          	jalr	762(ra) # 80000fa6 <walk>
    80002cb4:	87aa                	mv	a5,a0
  long accessed = (*pte & PTE_A);
    80002cb6:	6118                	ld	a4,0(a0)
    80002cb8:	04077513          	andi	a0,a4,64
  if (accessed && to_reset)
    80002cbc:	c511                	beqz	a0,80002cc8 <is_accessed+0x3a>
    80002cbe:	00090563          	beqz	s2,80002cc8 <is_accessed+0x3a>
    *pte ^= PTE_A; // reset accessed flag
    80002cc2:	04074713          	xori	a4,a4,64
    80002cc6:	e398                	sd	a4,0(a5)

  return accessed;
}
    80002cc8:	60e2                	ld	ra,24(sp)
    80002cca:	6442                	ld	s0,16(sp)
    80002ccc:	64a2                	ld	s1,8(sp)
    80002cce:	6902                	ld	s2,0(sp)
    80002cd0:	6105                	addi	sp,sp,32
    80002cd2:	8082                	ret

0000000080002cd4 <update_NFUA_LAPA_counter>:
{
    80002cd4:	1101                	addi	sp,sp,-32
    80002cd6:	ec06                	sd	ra,24(sp)
    80002cd8:	e822                	sd	s0,16(sp)
    80002cda:	e426                	sd	s1,8(sp)
    80002cdc:	1000                	addi	s0,sp,32
    80002cde:	84aa                	mv	s1,a0
  long acc =(long)(is_accessed(pg, 1));
    80002ce0:	4585                	li	a1,1
    80002ce2:	00000097          	auipc	ra,0x0
    80002ce6:	fac080e7          	jalr	-84(ra) # 80002c8e <is_accessed>
  pg->aging_counter = (pg->aging_counter >> 1) ;
    80002cea:	649c                	ld	a5,8(s1)
    80002cec:	8785                	srai	a5,a5,0x1
  if(acc)
    80002cee:	e119                	bnez	a0,80002cf4 <update_NFUA_LAPA_counter+0x20>
  pg->aging_counter = (pg->aging_counter >> 1) ;
    80002cf0:	e49c                	sd	a5,8(s1)
    80002cf2:	a029                	j	80002cfc <update_NFUA_LAPA_counter+0x28>
    pg->aging_counter = pg->aging_counter | 0x80000000; // if page was accessed set MSB to 1
    80002cf4:	4705                	li	a4,1
    80002cf6:	077e                	slli	a4,a4,0x1f
    80002cf8:	8fd9                	or	a5,a5,a4
    80002cfa:	e49c                	sd	a5,8(s1)
}
    80002cfc:	60e2                	ld	ra,24(sp)
    80002cfe:	6442                	ld	s0,16(sp)
    80002d00:	64a2                	ld	s1,8(sp)
    80002d02:	6105                	addi	sp,sp,32
    80002d04:	8082                	ret

0000000080002d06 <update_pages_info>:
{
    80002d06:	1101                	addi	sp,sp,-32
    80002d08:	ec06                	sd	ra,24(sp)
    80002d0a:	e822                	sd	s0,16(sp)
    80002d0c:	e426                	sd	s1,8(sp)
    80002d0e:	e04a                	sd	s2,0(sp)
    80002d10:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002d12:	fffff097          	auipc	ra,0xfffff
    80002d16:	ffe080e7          	jalr	-2(ra) # 80001d10 <myproc>
  for (pg = p->pages_physc_info.pages; pg < &p->pages_physc_info.pages[MAX_PSYC_PAGES]; pg++){
    80002d1a:	30850493          	addi	s1,a0,776
    80002d1e:	48850913          	addi	s2,a0,1160
    update_NFUA_LAPA_counter(pg);
    80002d22:	8526                	mv	a0,s1
    80002d24:	00000097          	auipc	ra,0x0
    80002d28:	fb0080e7          	jalr	-80(ra) # 80002cd4 <update_NFUA_LAPA_counter>
  for (pg = p->pages_physc_info.pages; pg < &p->pages_physc_info.pages[MAX_PSYC_PAGES]; pg++){
    80002d2c:	04e1                	addi	s1,s1,24
    80002d2e:	fe991ae3          	bne	s2,s1,80002d22 <update_pages_info+0x1c>
}
    80002d32:	60e2                	ld	ra,24(sp)
    80002d34:	6442                	ld	s0,16(sp)
    80002d36:	64a2                	ld	s1,8(sp)
    80002d38:	6902                	ld	s2,0(sp)
    80002d3a:	6105                	addi	sp,sp,32
    80002d3c:	8082                	ret

0000000080002d3e <scheduler>:
{
    80002d3e:	715d                	addi	sp,sp,-80
    80002d40:	e486                	sd	ra,72(sp)
    80002d42:	e0a2                	sd	s0,64(sp)
    80002d44:	fc26                	sd	s1,56(sp)
    80002d46:	f84a                	sd	s2,48(sp)
    80002d48:	f44e                	sd	s3,40(sp)
    80002d4a:	f052                	sd	s4,32(sp)
    80002d4c:	ec56                	sd	s5,24(sp)
    80002d4e:	e85a                	sd	s6,16(sp)
    80002d50:	e45e                	sd	s7,8(sp)
    80002d52:	0880                	addi	s0,sp,80
    80002d54:	8792                	mv	a5,tp
  int id = r_tp();
    80002d56:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002d58:	00779b13          	slli	s6,a5,0x7
    80002d5c:	0000f717          	auipc	a4,0xf
    80002d60:	54470713          	addi	a4,a4,1348 # 800122a0 <pid_lock>
    80002d64:	975a                	add	a4,a4,s6
    80002d66:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002d6a:	0000f717          	auipc	a4,0xf
    80002d6e:	56e70713          	addi	a4,a4,1390 # 800122d8 <cpus+0x8>
    80002d72:	9b3a                	add	s6,s6,a4
      if (p->state == RUNNABLE)
    80002d74:	498d                	li	s3,3
        p->state = RUNNING;
    80002d76:	4b91                	li	s7,4
        c->proc = p;
    80002d78:	079e                	slli	a5,a5,0x7
    80002d7a:	0000fa17          	auipc	s4,0xf
    80002d7e:	526a0a13          	addi	s4,s4,1318 # 800122a0 <pid_lock>
    80002d82:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80002d84:	00022917          	auipc	s2,0x22
    80002d88:	d4c90913          	addi	s2,s2,-692 # 80024ad0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d8c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d90:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d94:	10079073          	csrw	sstatus,a5
    80002d98:	00010497          	auipc	s1,0x10
    80002d9c:	93848493          	addi	s1,s1,-1736 # 800126d0 <proc>
        if(p->pid>2){
    80002da0:	4a89                	li	s5,2
    80002da2:	a821                	j	80002dba <scheduler+0x7c>
        c->proc = 0;
    80002da4:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    80002da8:	8526                	mv	a0,s1
    80002daa:	ffffe097          	auipc	ra,0xffffe
    80002dae:	ecc080e7          	jalr	-308(ra) # 80000c76 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002db2:	49048493          	addi	s1,s1,1168
    80002db6:	fd248be3          	beq	s1,s2,80002d8c <scheduler+0x4e>
      acquire(&p->lock);
    80002dba:	8526                	mv	a0,s1
    80002dbc:	ffffe097          	auipc	ra,0xffffe
    80002dc0:	e06080e7          	jalr	-506(ra) # 80000bc2 <acquire>
      if (p->state == RUNNABLE)
    80002dc4:	4c9c                	lw	a5,24(s1)
    80002dc6:	ff3791e3          	bne	a5,s3,80002da8 <scheduler+0x6a>
        p->state = RUNNING;
    80002dca:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80002dce:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002dd2:	06048593          	addi	a1,s1,96
    80002dd6:	855a                	mv	a0,s6
    80002dd8:	00000097          	auipc	ra,0x0
    80002ddc:	122080e7          	jalr	290(ra) # 80002efa <swtch>
        if(p->pid>2){
    80002de0:	589c                	lw	a5,48(s1)
    80002de2:	fcfad1e3          	bge	s5,a5,80002da4 <scheduler+0x66>
          update_pages_info();
    80002de6:	00000097          	auipc	ra,0x0
    80002dea:	f20080e7          	jalr	-224(ra) # 80002d06 <update_pages_info>
    80002dee:	bf5d                	j	80002da4 <scheduler+0x66>

0000000080002df0 <reset_aging_counter>:
void reset_aging_counter(struct page_info *pg)
{
    80002df0:	1141                	addi	sp,sp,-16
    80002df2:	e422                	sd	s0,8(sp)
    80002df4:	0800                	addi	s0,sp,16
  #ifdef NFUA
    pg->aging_counter = 0x00000000;//TODO return to 0
    // pg->aging_counter = 0;//TODO return to 0

  #elif LAPA
    pg->aging_counter = 0xFFFFFFFF;
    80002df6:	57fd                	li	a5,-1
    80002df8:	9381                	srli	a5,a5,0x20
    80002dfa:	e51c                	sd	a5,8(a0)
  #endif
}
    80002dfc:	6422                	ld	s0,8(sp)
    80002dfe:	0141                	addi	sp,sp,16
    80002e00:	8082                	ret

0000000080002e02 <print_pages_from_info_arrs>:

void print_pages_from_info_arrs(){
    80002e02:	7139                	addi	sp,sp,-64
    80002e04:	fc06                	sd	ra,56(sp)
    80002e06:	f822                	sd	s0,48(sp)
    80002e08:	f426                	sd	s1,40(sp)
    80002e0a:	f04a                	sd	s2,32(sp)
    80002e0c:	ec4e                	sd	s3,24(sp)
    80002e0e:	e852                	sd	s4,16(sp)
    80002e10:	e456                	sd	s5,8(sp)
    80002e12:	e05a                	sd	s6,0(sp)
    80002e14:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002e16:	fffff097          	auipc	ra,0xfffff
    80002e1a:	efa080e7          	jalr	-262(ra) # 80001d10 <myproc>
    80002e1e:	89aa                	mv	s3,a0
  printf("\n physic pages \t\t\t\t\t\t\t\tswap file::\n");
    80002e20:	00006517          	auipc	a0,0x6
    80002e24:	7b050513          	addi	a0,a0,1968 # 800095d0 <digits+0x590>
    80002e28:	ffffd097          	auipc	ra,0xffffd
    80002e2c:	74c080e7          	jalr	1868(ra) # 80000574 <printf>
  printf("index\t(va, used, aging)\t\t\t\t\t\t(va , used)  \n ");
    80002e30:	00006517          	auipc	a0,0x6
    80002e34:	7c850513          	addi	a0,a0,1992 # 800095f8 <digits+0x5b8>
    80002e38:	ffffd097          	auipc	ra,0xffffd
    80002e3c:	73c080e7          	jalr	1852(ra) # 80000574 <printf>
  for (int i = 0; i < MAX_PSYC_PAGES; i++){
    80002e40:	18098913          	addi	s2,s3,384
    80002e44:	4481                	li	s1,0
    printf("%d:\t(%p , %d ,\t %p)\t\t(%p , %d)  \n ", i,p->pages_physc_info.pages[i].va, 
      (p->pages_physc_info.free_spaces & (1 << i))>0,
    80002e46:	4b05                	li	s6,1
    printf("%d:\t(%p , %d ,\t %p)\t\t(%p , %d)  \n ", i,p->pages_physc_info.pages[i].va, 
    80002e48:	00006a97          	auipc	s5,0x6
    80002e4c:	7e0a8a93          	addi	s5,s5,2016 # 80009628 <digits+0x5e8>
  for (int i = 0; i < MAX_PSYC_PAGES; i++){
    80002e50:	4a41                	li	s4,16
      (p->pages_physc_info.free_spaces & (1 << i))>0,
    80002e52:	009b16bb          	sllw	a3,s6,s1
      p->pages_physc_info.pages[i].aging_counter,
      p->pages_swap_info.pages[i].va,(p->pages_swap_info.free_spaces&(1<<i))>0);
    80002e56:	1789d803          	lhu	a6,376(s3)
    printf("%d:\t(%p , %d ,\t %p)\t\t(%p , %d)  \n ", i,p->pages_physc_info.pages[i].va, 
    80002e5a:	0106f833          	and	a6,a3,a6
      (p->pages_physc_info.free_spaces & (1 << i))>0,
    80002e5e:	3009d783          	lhu	a5,768(s3)
    printf("%d:\t(%p , %d ,\t %p)\t\t(%p , %d)  \n ", i,p->pages_physc_info.pages[i].va, 
    80002e62:	8efd                	and	a3,a3,a5
    80002e64:	01003833          	snez	a6,a6
    80002e68:	00093783          	ld	a5,0(s2)
    80002e6c:	19093703          	ld	a4,400(s2)
    80002e70:	00d036b3          	snez	a3,a3
    80002e74:	18893603          	ld	a2,392(s2)
    80002e78:	85a6                	mv	a1,s1
    80002e7a:	8556                	mv	a0,s5
    80002e7c:	ffffd097          	auipc	ra,0xffffd
    80002e80:	6f8080e7          	jalr	1784(ra) # 80000574 <printf>
  for (int i = 0; i < MAX_PSYC_PAGES; i++){
    80002e84:	2485                	addiw	s1,s1,1
    80002e86:	0961                	addi	s2,s2,24
    80002e88:	fd4495e3          	bne	s1,s4,80002e52 <print_pages_from_info_arrs+0x50>
  }

    80002e8c:	70e2                	ld	ra,56(sp)
    80002e8e:	7442                	ld	s0,48(sp)
    80002e90:	74a2                	ld	s1,40(sp)
    80002e92:	7902                	ld	s2,32(sp)
    80002e94:	69e2                	ld	s3,24(sp)
    80002e96:	6a42                	ld	s4,16(sp)
    80002e98:	6aa2                	ld	s5,8(sp)
    80002e9a:	6b02                	ld	s6,0(sp)
    80002e9c:	6121                	addi	sp,sp,64
    80002e9e:	8082                	ret

0000000080002ea0 <get_next_page_to_swap_out>:
{
    80002ea0:	1101                	addi	sp,sp,-32
    80002ea2:	ec06                	sd	ra,24(sp)
    80002ea4:	e822                	sd	s0,16(sp)
    80002ea6:	e426                	sd	s1,8(sp)
    80002ea8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002eaa:	fffff097          	auipc	ra,0xfffff
    80002eae:	e66080e7          	jalr	-410(ra) # 80001d10 <myproc>
printf("debug: LOOKING FOR PAGE TO SWAPOUT\n");
    80002eb2:	00006517          	auipc	a0,0x6
    80002eb6:	79e50513          	addi	a0,a0,1950 # 80009650 <digits+0x610>
    80002eba:	ffffd097          	auipc	ra,0xffffd
    80002ebe:	6ba080e7          	jalr	1722(ra) # 80000574 <printf>
print_pages_from_info_arrs();
    80002ec2:	00000097          	auipc	ra,0x0
    80002ec6:	f40080e7          	jalr	-192(ra) # 80002e02 <print_pages_from_info_arrs>
  selected_pg_index = compare_all_pages(LAPA_compare);
    80002eca:	00000517          	auipc	a0,0x0
    80002ece:	cee50513          	addi	a0,a0,-786 # 80002bb8 <LAPA_compare>
    80002ed2:	00000097          	auipc	ra,0x0
    80002ed6:	d44080e7          	jalr	-700(ra) # 80002c16 <compare_all_pages>
    80002eda:	84aa                	mv	s1,a0
  printf("debug: NEXT PAGE TO SWAPOUT = %d\n",selected_pg_index);
    80002edc:	85aa                	mv	a1,a0
    80002ede:	00006517          	auipc	a0,0x6
    80002ee2:	79a50513          	addi	a0,a0,1946 # 80009678 <digits+0x638>
    80002ee6:	ffffd097          	auipc	ra,0xffffd
    80002eea:	68e080e7          	jalr	1678(ra) # 80000574 <printf>
}
    80002eee:	8526                	mv	a0,s1
    80002ef0:	60e2                	ld	ra,24(sp)
    80002ef2:	6442                	ld	s0,16(sp)
    80002ef4:	64a2                	ld	s1,8(sp)
    80002ef6:	6105                	addi	sp,sp,32
    80002ef8:	8082                	ret

0000000080002efa <swtch>:
    80002efa:	00153023          	sd	ra,0(a0)
    80002efe:	00253423          	sd	sp,8(a0)
    80002f02:	e900                	sd	s0,16(a0)
    80002f04:	ed04                	sd	s1,24(a0)
    80002f06:	03253023          	sd	s2,32(a0)
    80002f0a:	03353423          	sd	s3,40(a0)
    80002f0e:	03453823          	sd	s4,48(a0)
    80002f12:	03553c23          	sd	s5,56(a0)
    80002f16:	05653023          	sd	s6,64(a0)
    80002f1a:	05753423          	sd	s7,72(a0)
    80002f1e:	05853823          	sd	s8,80(a0)
    80002f22:	05953c23          	sd	s9,88(a0)
    80002f26:	07a53023          	sd	s10,96(a0)
    80002f2a:	07b53423          	sd	s11,104(a0)
    80002f2e:	0005b083          	ld	ra,0(a1)
    80002f32:	0085b103          	ld	sp,8(a1)
    80002f36:	6980                	ld	s0,16(a1)
    80002f38:	6d84                	ld	s1,24(a1)
    80002f3a:	0205b903          	ld	s2,32(a1)
    80002f3e:	0285b983          	ld	s3,40(a1)
    80002f42:	0305ba03          	ld	s4,48(a1)
    80002f46:	0385ba83          	ld	s5,56(a1)
    80002f4a:	0405bb03          	ld	s6,64(a1)
    80002f4e:	0485bb83          	ld	s7,72(a1)
    80002f52:	0505bc03          	ld	s8,80(a1)
    80002f56:	0585bc83          	ld	s9,88(a1)
    80002f5a:	0605bd03          	ld	s10,96(a1)
    80002f5e:	0685bd83          	ld	s11,104(a1)
    80002f62:	8082                	ret

0000000080002f64 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002f64:	1141                	addi	sp,sp,-16
    80002f66:	e406                	sd	ra,8(sp)
    80002f68:	e022                	sd	s0,0(sp)
    80002f6a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002f6c:	00006597          	auipc	a1,0x6
    80002f70:	78c58593          	addi	a1,a1,1932 # 800096f8 <states.0+0x30>
    80002f74:	00022517          	auipc	a0,0x22
    80002f78:	b5c50513          	addi	a0,a0,-1188 # 80024ad0 <tickslock>
    80002f7c:	ffffe097          	auipc	ra,0xffffe
    80002f80:	bb6080e7          	jalr	-1098(ra) # 80000b32 <initlock>
}
    80002f84:	60a2                	ld	ra,8(sp)
    80002f86:	6402                	ld	s0,0(sp)
    80002f88:	0141                	addi	sp,sp,16
    80002f8a:	8082                	ret

0000000080002f8c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002f8c:	1141                	addi	sp,sp,-16
    80002f8e:	e422                	sd	s0,8(sp)
    80002f90:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002f92:	00004797          	auipc	a5,0x4
    80002f96:	ade78793          	addi	a5,a5,-1314 # 80006a70 <kernelvec>
    80002f9a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002f9e:	6422                	ld	s0,8(sp)
    80002fa0:	0141                	addi	sp,sp,16
    80002fa2:	8082                	ret

0000000080002fa4 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002fa4:	1141                	addi	sp,sp,-16
    80002fa6:	e406                	sd	ra,8(sp)
    80002fa8:	e022                	sd	s0,0(sp)
    80002faa:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002fac:	fffff097          	auipc	ra,0xfffff
    80002fb0:	d64080e7          	jalr	-668(ra) # 80001d10 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fb4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002fb8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002fba:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002fbe:	00005617          	auipc	a2,0x5
    80002fc2:	04260613          	addi	a2,a2,66 # 80008000 <_trampoline>
    80002fc6:	00005697          	auipc	a3,0x5
    80002fca:	03a68693          	addi	a3,a3,58 # 80008000 <_trampoline>
    80002fce:	8e91                	sub	a3,a3,a2
    80002fd0:	040007b7          	lui	a5,0x4000
    80002fd4:	17fd                	addi	a5,a5,-1
    80002fd6:	07b2                	slli	a5,a5,0xc
    80002fd8:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002fda:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002fde:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002fe0:	180026f3          	csrr	a3,satp
    80002fe4:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002fe6:	6d38                	ld	a4,88(a0)
    80002fe8:	6134                	ld	a3,64(a0)
    80002fea:	6585                	lui	a1,0x1
    80002fec:	96ae                	add	a3,a3,a1
    80002fee:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002ff0:	6d38                	ld	a4,88(a0)
    80002ff2:	00000697          	auipc	a3,0x0
    80002ff6:	13868693          	addi	a3,a3,312 # 8000312a <usertrap>
    80002ffa:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002ffc:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002ffe:	8692                	mv	a3,tp
    80003000:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003002:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80003006:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000300a:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000300e:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80003012:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003014:	6f18                	ld	a4,24(a4)
    80003016:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000301a:	692c                	ld	a1,80(a0)
    8000301c:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000301e:	00005717          	auipc	a4,0x5
    80003022:	07270713          	addi	a4,a4,114 # 80008090 <userret>
    80003026:	8f11                	sub	a4,a4,a2
    80003028:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))fn)(TRAPFRAME, satp);
    8000302a:	577d                	li	a4,-1
    8000302c:	177e                	slli	a4,a4,0x3f
    8000302e:	8dd9                	or	a1,a1,a4
    80003030:	02000537          	lui	a0,0x2000
    80003034:	157d                	addi	a0,a0,-1
    80003036:	0536                	slli	a0,a0,0xd
    80003038:	9782                	jalr	a5
}
    8000303a:	60a2                	ld	ra,8(sp)
    8000303c:	6402                	ld	s0,0(sp)
    8000303e:	0141                	addi	sp,sp,16
    80003040:	8082                	ret

0000000080003042 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80003042:	1101                	addi	sp,sp,-32
    80003044:	ec06                	sd	ra,24(sp)
    80003046:	e822                	sd	s0,16(sp)
    80003048:	e426                	sd	s1,8(sp)
    8000304a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000304c:	00022497          	auipc	s1,0x22
    80003050:	a8448493          	addi	s1,s1,-1404 # 80024ad0 <tickslock>
    80003054:	8526                	mv	a0,s1
    80003056:	ffffe097          	auipc	ra,0xffffe
    8000305a:	b6c080e7          	jalr	-1172(ra) # 80000bc2 <acquire>
  ticks++;
    8000305e:	00007517          	auipc	a0,0x7
    80003062:	fd250513          	addi	a0,a0,-46 # 8000a030 <ticks>
    80003066:	411c                	lw	a5,0(a0)
    80003068:	2785                	addiw	a5,a5,1
    8000306a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000306c:	fffff097          	auipc	ra,0xfffff
    80003070:	328080e7          	jalr	808(ra) # 80002394 <wakeup>
  release(&tickslock);
    80003074:	8526                	mv	a0,s1
    80003076:	ffffe097          	auipc	ra,0xffffe
    8000307a:	c00080e7          	jalr	-1024(ra) # 80000c76 <release>
}
    8000307e:	60e2                	ld	ra,24(sp)
    80003080:	6442                	ld	s0,16(sp)
    80003082:	64a2                	ld	s1,8(sp)
    80003084:	6105                	addi	sp,sp,32
    80003086:	8082                	ret

0000000080003088 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80003088:	1101                	addi	sp,sp,-32
    8000308a:	ec06                	sd	ra,24(sp)
    8000308c:	e822                	sd	s0,16(sp)
    8000308e:	e426                	sd	s1,8(sp)
    80003090:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003092:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80003096:	00074d63          	bltz	a4,800030b0 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    8000309a:	57fd                	li	a5,-1
    8000309c:	17fe                	slli	a5,a5,0x3f
    8000309e:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    800030a0:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    800030a2:	06f70363          	beq	a4,a5,80003108 <devintr+0x80>
  }
}
    800030a6:	60e2                	ld	ra,24(sp)
    800030a8:	6442                	ld	s0,16(sp)
    800030aa:	64a2                	ld	s1,8(sp)
    800030ac:	6105                	addi	sp,sp,32
    800030ae:	8082                	ret
      (scause & 0xff) == 9)
    800030b0:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    800030b4:	46a5                	li	a3,9
    800030b6:	fed792e3          	bne	a5,a3,8000309a <devintr+0x12>
    int irq = plic_claim();
    800030ba:	00004097          	auipc	ra,0x4
    800030be:	abe080e7          	jalr	-1346(ra) # 80006b78 <plic_claim>
    800030c2:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    800030c4:	47a9                	li	a5,10
    800030c6:	02f50763          	beq	a0,a5,800030f4 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    800030ca:	4785                	li	a5,1
    800030cc:	02f50963          	beq	a0,a5,800030fe <devintr+0x76>
    return 1;
    800030d0:	4505                	li	a0,1
    else if (irq)
    800030d2:	d8f1                	beqz	s1,800030a6 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800030d4:	85a6                	mv	a1,s1
    800030d6:	00006517          	auipc	a0,0x6
    800030da:	62a50513          	addi	a0,a0,1578 # 80009700 <states.0+0x38>
    800030de:	ffffd097          	auipc	ra,0xffffd
    800030e2:	496080e7          	jalr	1174(ra) # 80000574 <printf>
      plic_complete(irq);
    800030e6:	8526                	mv	a0,s1
    800030e8:	00004097          	auipc	ra,0x4
    800030ec:	ab4080e7          	jalr	-1356(ra) # 80006b9c <plic_complete>
    return 1;
    800030f0:	4505                	li	a0,1
    800030f2:	bf55                	j	800030a6 <devintr+0x1e>
      uartintr();
    800030f4:	ffffe097          	auipc	ra,0xffffe
    800030f8:	892080e7          	jalr	-1902(ra) # 80000986 <uartintr>
    800030fc:	b7ed                	j	800030e6 <devintr+0x5e>
      virtio_disk_intr();
    800030fe:	00004097          	auipc	ra,0x4
    80003102:	f30080e7          	jalr	-208(ra) # 8000702e <virtio_disk_intr>
    80003106:	b7c5                	j	800030e6 <devintr+0x5e>
    if (cpuid() == 0)
    80003108:	fffff097          	auipc	ra,0xfffff
    8000310c:	bdc080e7          	jalr	-1060(ra) # 80001ce4 <cpuid>
    80003110:	c901                	beqz	a0,80003120 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80003112:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80003116:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80003118:	14479073          	csrw	sip,a5
    return 2;
    8000311c:	4509                	li	a0,2
    8000311e:	b761                	j	800030a6 <devintr+0x1e>
      clockintr();
    80003120:	00000097          	auipc	ra,0x0
    80003124:	f22080e7          	jalr	-222(ra) # 80003042 <clockintr>
    80003128:	b7ed                	j	80003112 <devintr+0x8a>

000000008000312a <usertrap>:
{
    8000312a:	7179                	addi	sp,sp,-48
    8000312c:	f406                	sd	ra,40(sp)
    8000312e:	f022                	sd	s0,32(sp)
    80003130:	ec26                	sd	s1,24(sp)
    80003132:	e84a                	sd	s2,16(sp)
    80003134:	e44e                	sd	s3,8(sp)
    80003136:	e052                	sd	s4,0(sp)
    80003138:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000313a:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    8000313e:	1007f793          	andi	a5,a5,256
    80003142:	efd1                	bnez	a5,800031de <usertrap+0xb4>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003144:	00004797          	auipc	a5,0x4
    80003148:	92c78793          	addi	a5,a5,-1748 # 80006a70 <kernelvec>
    8000314c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003150:	fffff097          	auipc	ra,0xfffff
    80003154:	bc0080e7          	jalr	-1088(ra) # 80001d10 <myproc>
    80003158:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000315a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000315c:	14102773          	csrr	a4,sepc
    80003160:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003162:	142027f3          	csrr	a5,scause
  if (trap_cause == 8)
    80003166:	4721                	li	a4,8
    80003168:	08e78363          	beq	a5,a4,800031ee <usertrap+0xc4>
  else if (trap_cause == 13 || trap_cause == 15 || trap_cause == 12)
    8000316c:	473d                	li	a4,15
    8000316e:	00e78663          	beq	a5,a4,8000317a <usertrap+0x50>
    80003172:	17d1                	addi	a5,a5,-12
    80003174:	4705                	li	a4,1
    80003176:	12f76a63          	bltu	a4,a5,800032aa <usertrap+0x180>
    struct proc *p = myproc();
    8000317a:	fffff097          	auipc	ra,0xfffff
    8000317e:	b96080e7          	jalr	-1130(ra) # 80001d10 <myproc>
    80003182:	892a                	mv	s2,a0
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003184:	14302a73          	csrr	s4,stval
    uint64 fault_rva = PGROUNDDOWN(fault_va);
    80003188:	77fd                	lui	a5,0xfffff
    8000318a:	00fa7a33          	and	s4,s4,a5
    pte_t *pte = walk(p->pagetable, fault_rva, 0);
    8000318e:	4601                	li	a2,0
    80003190:	85d2                	mv	a1,s4
    80003192:	6928                	ld	a0,80(a0)
    80003194:	ffffe097          	auipc	ra,0xffffe
    80003198:	e12080e7          	jalr	-494(ra) # 80000fa6 <walk>
    8000319c:	89aa                	mv	s3,a0
    if (!pte || p->pid <= 2)
    8000319e:	cd41                	beqz	a0,80003236 <usertrap+0x10c>
    800031a0:	03092703          	lw	a4,48(s2)
    800031a4:	4789                	li	a5,2
    800031a6:	08e7d863          	bge	a5,a4,80003236 <usertrap+0x10c>
    printf("debug: PAGE FAULT\n");
    800031aa:	00006517          	auipc	a0,0x6
    800031ae:	5d650513          	addi	a0,a0,1494 # 80009780 <states.0+0xb8>
    800031b2:	ffffd097          	auipc	ra,0xffffd
    800031b6:	3c2080e7          	jalr	962(ra) # 80000574 <printf>
    if ((*pte & PTE_PG) && !(*pte & PTE_V))
    800031ba:	0009b783          	ld	a5,0(s3)
    800031be:	2017f693          	andi	a3,a5,513
    800031c2:	20000713          	li	a4,512
    800031c6:	08e68a63          	beq	a3,a4,8000325a <usertrap+0x130>
    else if (*pte & PTE_V)
    800031ca:	8b85                	andi	a5,a5,1
    800031cc:	c3a9                	beqz	a5,8000320e <usertrap+0xe4>
      panic("usertrap: PTE_V should not be valid during page_fault"); //TODO: check if needed/true
    800031ce:	00006517          	auipc	a0,0x6
    800031d2:	5f250513          	addi	a0,a0,1522 # 800097c0 <states.0+0xf8>
    800031d6:	ffffd097          	auipc	ra,0xffffd
    800031da:	354080e7          	jalr	852(ra) # 8000052a <panic>
    panic("usertrap: not from user mode");
    800031de:	00006517          	auipc	a0,0x6
    800031e2:	54250513          	addi	a0,a0,1346 # 80009720 <states.0+0x58>
    800031e6:	ffffd097          	auipc	ra,0xffffd
    800031ea:	344080e7          	jalr	836(ra) # 8000052a <panic>
    if (p->killed)
    800031ee:	551c                	lw	a5,40(a0)
    800031f0:	ef8d                	bnez	a5,8000322a <usertrap+0x100>
    p->trapframe->epc += 4;
    800031f2:	6cb8                	ld	a4,88(s1)
    800031f4:	6f1c                	ld	a5,24(a4)
    800031f6:	0791                	addi	a5,a5,4
    800031f8:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800031fa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800031fe:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003202:	10079073          	csrw	sstatus,a5
    syscall();
    80003206:	00000097          	auipc	ra,0x0
    8000320a:	362080e7          	jalr	866(ra) # 80003568 <syscall>
  if (p->killed)
    8000320e:	549c                	lw	a5,40(s1)
    80003210:	e3e5                	bnez	a5,800032f0 <usertrap+0x1c6>
  usertrapret();
    80003212:	00000097          	auipc	ra,0x0
    80003216:	d92080e7          	jalr	-622(ra) # 80002fa4 <usertrapret>
}
    8000321a:	70a2                	ld	ra,40(sp)
    8000321c:	7402                	ld	s0,32(sp)
    8000321e:	64e2                	ld	s1,24(sp)
    80003220:	6942                	ld	s2,16(sp)
    80003222:	69a2                	ld	s3,8(sp)
    80003224:	6a02                	ld	s4,0(sp)
    80003226:	6145                	addi	sp,sp,48
    80003228:	8082                	ret
      exit(-1);
    8000322a:	557d                	li	a0,-1
    8000322c:	fffff097          	auipc	ra,0xfffff
    80003230:	238080e7          	jalr	568(ra) # 80002464 <exit>
    80003234:	bf7d                	j	800031f2 <usertrap+0xc8>
      printf("seg fault with pid=%d", p->pid);
    80003236:	03092583          	lw	a1,48(s2)
    8000323a:	00006517          	auipc	a0,0x6
    8000323e:	50650513          	addi	a0,a0,1286 # 80009740 <states.0+0x78>
    80003242:	ffffd097          	auipc	ra,0xffffd
    80003246:	332080e7          	jalr	818(ra) # 80000574 <printf>
      panic("usertrap: segmentation fault oh nooooo"); // TODO check if need to kill just the current procces
    8000324a:	00006517          	auipc	a0,0x6
    8000324e:	50e50513          	addi	a0,a0,1294 # 80009758 <states.0+0x90>
    80003252:	ffffd097          	auipc	ra,0xffffd
    80003256:	2d8080e7          	jalr	728(ra) # 8000052a <panic>
      if (p->physical_pages_num >= MAX_PSYC_PAGES)
    8000325a:	17092703          	lw	a4,368(s2)
    8000325e:	47bd                	li	a5,15
    80003260:	02e7d663          	bge	a5,a4,8000328c <usertrap+0x162>
        int page_to_swap_out_index = get_next_page_to_swap_out();
    80003264:	00000097          	auipc	ra,0x0
    80003268:	c3c080e7          	jalr	-964(ra) # 80002ea0 <get_next_page_to_swap_out>
        if (page_to_swap_out_index < 0 || page_to_swap_out_index > MAX_PSYC_PAGES)
    8000326c:	0005071b          	sext.w	a4,a0
    80003270:	47c1                	li	a5,16
    80003272:	02e7e463          	bltu	a5,a4,8000329a <usertrap+0x170>
        uint64 va = p->pages_physc_info.pages[page_to_swap_out_index].va;
    80003276:	00151793          	slli	a5,a0,0x1
    8000327a:	953e                	add	a0,a0,a5
    8000327c:	050e                	slli	a0,a0,0x3
    8000327e:	992a                	add	s2,s2,a0
        uint64 pa = page_out(va);
    80003280:	30893503          	ld	a0,776(s2)
    80003284:	fffff097          	auipc	ra,0xfffff
    80003288:	4de080e7          	jalr	1246(ra) # 80002762 <page_out>
      pte_t *pte_new = page_in(fault_rva, pte);
    8000328c:	85ce                	mv	a1,s3
    8000328e:	8552                	mv	a0,s4
    80003290:	fffff097          	auipc	ra,0xfffff
    80003294:	580080e7          	jalr	1408(ra) # 80002810 <page_in>
    80003298:	bf9d                	j	8000320e <usertrap+0xe4>
          panic("usertrap: did not find page to swap out");
    8000329a:	00006517          	auipc	a0,0x6
    8000329e:	4fe50513          	addi	a0,a0,1278 # 80009798 <states.0+0xd0>
    800032a2:	ffffd097          	auipc	ra,0xffffd
    800032a6:	288080e7          	jalr	648(ra) # 8000052a <panic>
  else if ((which_dev = devintr()) != 0)
    800032aa:	00000097          	auipc	ra,0x0
    800032ae:	dde080e7          	jalr	-546(ra) # 80003088 <devintr>
    800032b2:	892a                	mv	s2,a0
    800032b4:	c501                	beqz	a0,800032bc <usertrap+0x192>
  if (p->killed)
    800032b6:	549c                	lw	a5,40(s1)
    800032b8:	c3b1                	beqz	a5,800032fc <usertrap+0x1d2>
    800032ba:	a825                	j	800032f2 <usertrap+0x1c8>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800032bc:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800032c0:	5890                	lw	a2,48(s1)
    800032c2:	00006517          	auipc	a0,0x6
    800032c6:	53650513          	addi	a0,a0,1334 # 800097f8 <states.0+0x130>
    800032ca:	ffffd097          	auipc	ra,0xffffd
    800032ce:	2aa080e7          	jalr	682(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800032d2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800032d6:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800032da:	00006517          	auipc	a0,0x6
    800032de:	54e50513          	addi	a0,a0,1358 # 80009828 <states.0+0x160>
    800032e2:	ffffd097          	auipc	ra,0xffffd
    800032e6:	292080e7          	jalr	658(ra) # 80000574 <printf>
    p->killed = 1;
    800032ea:	4785                	li	a5,1
    800032ec:	d49c                	sw	a5,40(s1)
  if (p->killed)
    800032ee:	a011                	j	800032f2 <usertrap+0x1c8>
    800032f0:	4901                	li	s2,0
    exit(-1);
    800032f2:	557d                	li	a0,-1
    800032f4:	fffff097          	auipc	ra,0xfffff
    800032f8:	170080e7          	jalr	368(ra) # 80002464 <exit>
  if (which_dev == 2)
    800032fc:	4789                	li	a5,2
    800032fe:	f0f91ae3          	bne	s2,a5,80003212 <usertrap+0xe8>
    yield();
    80003302:	fffff097          	auipc	ra,0xfffff
    80003306:	eca080e7          	jalr	-310(ra) # 800021cc <yield>
    8000330a:	b721                	j	80003212 <usertrap+0xe8>

000000008000330c <kerneltrap>:
{
    8000330c:	7179                	addi	sp,sp,-48
    8000330e:	f406                	sd	ra,40(sp)
    80003310:	f022                	sd	s0,32(sp)
    80003312:	ec26                	sd	s1,24(sp)
    80003314:	e84a                	sd	s2,16(sp)
    80003316:	e44e                	sd	s3,8(sp)
    80003318:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000331a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000331e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003322:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80003326:	1004f793          	andi	a5,s1,256
    8000332a:	cb85                	beqz	a5,8000335a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000332c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003330:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80003332:	ef85                	bnez	a5,8000336a <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80003334:	00000097          	auipc	ra,0x0
    80003338:	d54080e7          	jalr	-684(ra) # 80003088 <devintr>
    8000333c:	cd1d                	beqz	a0,8000337a <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000333e:	4789                	li	a5,2
    80003340:	08f50763          	beq	a0,a5,800033ce <kerneltrap+0xc2>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003344:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003348:	10049073          	csrw	sstatus,s1
}
    8000334c:	70a2                	ld	ra,40(sp)
    8000334e:	7402                	ld	s0,32(sp)
    80003350:	64e2                	ld	s1,24(sp)
    80003352:	6942                	ld	s2,16(sp)
    80003354:	69a2                	ld	s3,8(sp)
    80003356:	6145                	addi	sp,sp,48
    80003358:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000335a:	00006517          	auipc	a0,0x6
    8000335e:	4ee50513          	addi	a0,a0,1262 # 80009848 <states.0+0x180>
    80003362:	ffffd097          	auipc	ra,0xffffd
    80003366:	1c8080e7          	jalr	456(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    8000336a:	00006517          	auipc	a0,0x6
    8000336e:	50650513          	addi	a0,a0,1286 # 80009870 <states.0+0x1a8>
    80003372:	ffffd097          	auipc	ra,0xffffd
    80003376:	1b8080e7          	jalr	440(ra) # 8000052a <panic>
    printf("pid = %d\n",myproc()->pid);
    8000337a:	fffff097          	auipc	ra,0xfffff
    8000337e:	996080e7          	jalr	-1642(ra) # 80001d10 <myproc>
    80003382:	590c                	lw	a1,48(a0)
    80003384:	00006517          	auipc	a0,0x6
    80003388:	50c50513          	addi	a0,a0,1292 # 80009890 <states.0+0x1c8>
    8000338c:	ffffd097          	auipc	ra,0xffffd
    80003390:	1e8080e7          	jalr	488(ra) # 80000574 <printf>
    printf("scause %p\n", scause);
    80003394:	85ce                	mv	a1,s3
    80003396:	00006517          	auipc	a0,0x6
    8000339a:	50a50513          	addi	a0,a0,1290 # 800098a0 <states.0+0x1d8>
    8000339e:	ffffd097          	auipc	ra,0xffffd
    800033a2:	1d6080e7          	jalr	470(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800033a6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800033aa:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800033ae:	00006517          	auipc	a0,0x6
    800033b2:	50250513          	addi	a0,a0,1282 # 800098b0 <states.0+0x1e8>
    800033b6:	ffffd097          	auipc	ra,0xffffd
    800033ba:	1be080e7          	jalr	446(ra) # 80000574 <printf>
    panic("kerneltrap");
    800033be:	00006517          	auipc	a0,0x6
    800033c2:	50a50513          	addi	a0,a0,1290 # 800098c8 <states.0+0x200>
    800033c6:	ffffd097          	auipc	ra,0xffffd
    800033ca:	164080e7          	jalr	356(ra) # 8000052a <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800033ce:	fffff097          	auipc	ra,0xfffff
    800033d2:	942080e7          	jalr	-1726(ra) # 80001d10 <myproc>
    800033d6:	d53d                	beqz	a0,80003344 <kerneltrap+0x38>
    800033d8:	fffff097          	auipc	ra,0xfffff
    800033dc:	938080e7          	jalr	-1736(ra) # 80001d10 <myproc>
    800033e0:	4d18                	lw	a4,24(a0)
    800033e2:	4791                	li	a5,4
    800033e4:	f6f710e3          	bne	a4,a5,80003344 <kerneltrap+0x38>
    yield();
    800033e8:	fffff097          	auipc	ra,0xfffff
    800033ec:	de4080e7          	jalr	-540(ra) # 800021cc <yield>
    800033f0:	bf91                	j	80003344 <kerneltrap+0x38>

00000000800033f2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800033f2:	1101                	addi	sp,sp,-32
    800033f4:	ec06                	sd	ra,24(sp)
    800033f6:	e822                	sd	s0,16(sp)
    800033f8:	e426                	sd	s1,8(sp)
    800033fa:	1000                	addi	s0,sp,32
    800033fc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800033fe:	fffff097          	auipc	ra,0xfffff
    80003402:	912080e7          	jalr	-1774(ra) # 80001d10 <myproc>
  switch (n) {
    80003406:	4795                	li	a5,5
    80003408:	0497e163          	bltu	a5,s1,8000344a <argraw+0x58>
    8000340c:	048a                	slli	s1,s1,0x2
    8000340e:	00006717          	auipc	a4,0x6
    80003412:	4f270713          	addi	a4,a4,1266 # 80009900 <states.0+0x238>
    80003416:	94ba                	add	s1,s1,a4
    80003418:	409c                	lw	a5,0(s1)
    8000341a:	97ba                	add	a5,a5,a4
    8000341c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000341e:	6d3c                	ld	a5,88(a0)
    80003420:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003422:	60e2                	ld	ra,24(sp)
    80003424:	6442                	ld	s0,16(sp)
    80003426:	64a2                	ld	s1,8(sp)
    80003428:	6105                	addi	sp,sp,32
    8000342a:	8082                	ret
    return p->trapframe->a1;
    8000342c:	6d3c                	ld	a5,88(a0)
    8000342e:	7fa8                	ld	a0,120(a5)
    80003430:	bfcd                	j	80003422 <argraw+0x30>
    return p->trapframe->a2;
    80003432:	6d3c                	ld	a5,88(a0)
    80003434:	63c8                	ld	a0,128(a5)
    80003436:	b7f5                	j	80003422 <argraw+0x30>
    return p->trapframe->a3;
    80003438:	6d3c                	ld	a5,88(a0)
    8000343a:	67c8                	ld	a0,136(a5)
    8000343c:	b7dd                	j	80003422 <argraw+0x30>
    return p->trapframe->a4;
    8000343e:	6d3c                	ld	a5,88(a0)
    80003440:	6bc8                	ld	a0,144(a5)
    80003442:	b7c5                	j	80003422 <argraw+0x30>
    return p->trapframe->a5;
    80003444:	6d3c                	ld	a5,88(a0)
    80003446:	6fc8                	ld	a0,152(a5)
    80003448:	bfe9                	j	80003422 <argraw+0x30>
  panic("argraw");
    8000344a:	00006517          	auipc	a0,0x6
    8000344e:	48e50513          	addi	a0,a0,1166 # 800098d8 <states.0+0x210>
    80003452:	ffffd097          	auipc	ra,0xffffd
    80003456:	0d8080e7          	jalr	216(ra) # 8000052a <panic>

000000008000345a <fetchaddr>:
{
    8000345a:	1101                	addi	sp,sp,-32
    8000345c:	ec06                	sd	ra,24(sp)
    8000345e:	e822                	sd	s0,16(sp)
    80003460:	e426                	sd	s1,8(sp)
    80003462:	e04a                	sd	s2,0(sp)
    80003464:	1000                	addi	s0,sp,32
    80003466:	84aa                	mv	s1,a0
    80003468:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000346a:	fffff097          	auipc	ra,0xfffff
    8000346e:	8a6080e7          	jalr	-1882(ra) # 80001d10 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003472:	653c                	ld	a5,72(a0)
    80003474:	02f4f863          	bgeu	s1,a5,800034a4 <fetchaddr+0x4a>
    80003478:	00848713          	addi	a4,s1,8
    8000347c:	02e7e663          	bltu	a5,a4,800034a8 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003480:	46a1                	li	a3,8
    80003482:	8626                	mv	a2,s1
    80003484:	85ca                	mv	a1,s2
    80003486:	6928                	ld	a0,80(a0)
    80003488:	ffffe097          	auipc	ra,0xffffe
    8000348c:	f98080e7          	jalr	-104(ra) # 80001420 <copyin>
    80003490:	00a03533          	snez	a0,a0
    80003494:	40a00533          	neg	a0,a0
}
    80003498:	60e2                	ld	ra,24(sp)
    8000349a:	6442                	ld	s0,16(sp)
    8000349c:	64a2                	ld	s1,8(sp)
    8000349e:	6902                	ld	s2,0(sp)
    800034a0:	6105                	addi	sp,sp,32
    800034a2:	8082                	ret
    return -1;
    800034a4:	557d                	li	a0,-1
    800034a6:	bfcd                	j	80003498 <fetchaddr+0x3e>
    800034a8:	557d                	li	a0,-1
    800034aa:	b7fd                	j	80003498 <fetchaddr+0x3e>

00000000800034ac <fetchstr>:
{
    800034ac:	7179                	addi	sp,sp,-48
    800034ae:	f406                	sd	ra,40(sp)
    800034b0:	f022                	sd	s0,32(sp)
    800034b2:	ec26                	sd	s1,24(sp)
    800034b4:	e84a                	sd	s2,16(sp)
    800034b6:	e44e                	sd	s3,8(sp)
    800034b8:	1800                	addi	s0,sp,48
    800034ba:	892a                	mv	s2,a0
    800034bc:	84ae                	mv	s1,a1
    800034be:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800034c0:	fffff097          	auipc	ra,0xfffff
    800034c4:	850080e7          	jalr	-1968(ra) # 80001d10 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    800034c8:	86ce                	mv	a3,s3
    800034ca:	864a                	mv	a2,s2
    800034cc:	85a6                	mv	a1,s1
    800034ce:	6928                	ld	a0,80(a0)
    800034d0:	ffffe097          	auipc	ra,0xffffe
    800034d4:	fe0080e7          	jalr	-32(ra) # 800014b0 <copyinstr>
  if(err < 0)
    800034d8:	00054763          	bltz	a0,800034e6 <fetchstr+0x3a>
  return strlen(buf);
    800034dc:	8526                	mv	a0,s1
    800034de:	ffffe097          	auipc	ra,0xffffe
    800034e2:	964080e7          	jalr	-1692(ra) # 80000e42 <strlen>
}
    800034e6:	70a2                	ld	ra,40(sp)
    800034e8:	7402                	ld	s0,32(sp)
    800034ea:	64e2                	ld	s1,24(sp)
    800034ec:	6942                	ld	s2,16(sp)
    800034ee:	69a2                	ld	s3,8(sp)
    800034f0:	6145                	addi	sp,sp,48
    800034f2:	8082                	ret

00000000800034f4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800034f4:	1101                	addi	sp,sp,-32
    800034f6:	ec06                	sd	ra,24(sp)
    800034f8:	e822                	sd	s0,16(sp)
    800034fa:	e426                	sd	s1,8(sp)
    800034fc:	1000                	addi	s0,sp,32
    800034fe:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003500:	00000097          	auipc	ra,0x0
    80003504:	ef2080e7          	jalr	-270(ra) # 800033f2 <argraw>
    80003508:	c088                	sw	a0,0(s1)
  return 0;
}
    8000350a:	4501                	li	a0,0
    8000350c:	60e2                	ld	ra,24(sp)
    8000350e:	6442                	ld	s0,16(sp)
    80003510:	64a2                	ld	s1,8(sp)
    80003512:	6105                	addi	sp,sp,32
    80003514:	8082                	ret

0000000080003516 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003516:	1101                	addi	sp,sp,-32
    80003518:	ec06                	sd	ra,24(sp)
    8000351a:	e822                	sd	s0,16(sp)
    8000351c:	e426                	sd	s1,8(sp)
    8000351e:	1000                	addi	s0,sp,32
    80003520:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003522:	00000097          	auipc	ra,0x0
    80003526:	ed0080e7          	jalr	-304(ra) # 800033f2 <argraw>
    8000352a:	e088                	sd	a0,0(s1)
  return 0;
}
    8000352c:	4501                	li	a0,0
    8000352e:	60e2                	ld	ra,24(sp)
    80003530:	6442                	ld	s0,16(sp)
    80003532:	64a2                	ld	s1,8(sp)
    80003534:	6105                	addi	sp,sp,32
    80003536:	8082                	ret

0000000080003538 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003538:	1101                	addi	sp,sp,-32
    8000353a:	ec06                	sd	ra,24(sp)
    8000353c:	e822                	sd	s0,16(sp)
    8000353e:	e426                	sd	s1,8(sp)
    80003540:	e04a                	sd	s2,0(sp)
    80003542:	1000                	addi	s0,sp,32
    80003544:	84ae                	mv	s1,a1
    80003546:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003548:	00000097          	auipc	ra,0x0
    8000354c:	eaa080e7          	jalr	-342(ra) # 800033f2 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003550:	864a                	mv	a2,s2
    80003552:	85a6                	mv	a1,s1
    80003554:	00000097          	auipc	ra,0x0
    80003558:	f58080e7          	jalr	-168(ra) # 800034ac <fetchstr>
}
    8000355c:	60e2                	ld	ra,24(sp)
    8000355e:	6442                	ld	s0,16(sp)
    80003560:	64a2                	ld	s1,8(sp)
    80003562:	6902                	ld	s2,0(sp)
    80003564:	6105                	addi	sp,sp,32
    80003566:	8082                	ret

0000000080003568 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80003568:	1101                	addi	sp,sp,-32
    8000356a:	ec06                	sd	ra,24(sp)
    8000356c:	e822                	sd	s0,16(sp)
    8000356e:	e426                	sd	s1,8(sp)
    80003570:	e04a                	sd	s2,0(sp)
    80003572:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003574:	ffffe097          	auipc	ra,0xffffe
    80003578:	79c080e7          	jalr	1948(ra) # 80001d10 <myproc>
    8000357c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000357e:	05853903          	ld	s2,88(a0)
    80003582:	0a893783          	ld	a5,168(s2)
    80003586:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000358a:	37fd                	addiw	a5,a5,-1
    8000358c:	4751                	li	a4,20
    8000358e:	00f76f63          	bltu	a4,a5,800035ac <syscall+0x44>
    80003592:	00369713          	slli	a4,a3,0x3
    80003596:	00006797          	auipc	a5,0x6
    8000359a:	38278793          	addi	a5,a5,898 # 80009918 <syscalls>
    8000359e:	97ba                	add	a5,a5,a4
    800035a0:	639c                	ld	a5,0(a5)
    800035a2:	c789                	beqz	a5,800035ac <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    800035a4:	9782                	jalr	a5
    800035a6:	06a93823          	sd	a0,112(s2)
    800035aa:	a839                	j	800035c8 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800035ac:	15848613          	addi	a2,s1,344
    800035b0:	588c                	lw	a1,48(s1)
    800035b2:	00006517          	auipc	a0,0x6
    800035b6:	32e50513          	addi	a0,a0,814 # 800098e0 <states.0+0x218>
    800035ba:	ffffd097          	auipc	ra,0xffffd
    800035be:	fba080e7          	jalr	-70(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800035c2:	6cbc                	ld	a5,88(s1)
    800035c4:	577d                	li	a4,-1
    800035c6:	fbb8                	sd	a4,112(a5)
  }
}
    800035c8:	60e2                	ld	ra,24(sp)
    800035ca:	6442                	ld	s0,16(sp)
    800035cc:	64a2                	ld	s1,8(sp)
    800035ce:	6902                	ld	s2,0(sp)
    800035d0:	6105                	addi	sp,sp,32
    800035d2:	8082                	ret

00000000800035d4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800035d4:	1101                	addi	sp,sp,-32
    800035d6:	ec06                	sd	ra,24(sp)
    800035d8:	e822                	sd	s0,16(sp)
    800035da:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800035dc:	fec40593          	addi	a1,s0,-20
    800035e0:	4501                	li	a0,0
    800035e2:	00000097          	auipc	ra,0x0
    800035e6:	f12080e7          	jalr	-238(ra) # 800034f4 <argint>
    return -1;
    800035ea:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800035ec:	00054963          	bltz	a0,800035fe <sys_exit+0x2a>
  exit(n);
    800035f0:	fec42503          	lw	a0,-20(s0)
    800035f4:	fffff097          	auipc	ra,0xfffff
    800035f8:	e70080e7          	jalr	-400(ra) # 80002464 <exit>
  return 0;  // not reached
    800035fc:	4781                	li	a5,0
}
    800035fe:	853e                	mv	a0,a5
    80003600:	60e2                	ld	ra,24(sp)
    80003602:	6442                	ld	s0,16(sp)
    80003604:	6105                	addi	sp,sp,32
    80003606:	8082                	ret

0000000080003608 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003608:	1141                	addi	sp,sp,-16
    8000360a:	e406                	sd	ra,8(sp)
    8000360c:	e022                	sd	s0,0(sp)
    8000360e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003610:	ffffe097          	auipc	ra,0xffffe
    80003614:	700080e7          	jalr	1792(ra) # 80001d10 <myproc>
}
    80003618:	5908                	lw	a0,48(a0)
    8000361a:	60a2                	ld	ra,8(sp)
    8000361c:	6402                	ld	s0,0(sp)
    8000361e:	0141                	addi	sp,sp,16
    80003620:	8082                	ret

0000000080003622 <sys_fork>:

uint64
sys_fork(void)
{
    80003622:	1141                	addi	sp,sp,-16
    80003624:	e406                	sd	ra,8(sp)
    80003626:	e022                	sd	s0,0(sp)
    80003628:	0800                	addi	s0,sp,16
  return fork();
    8000362a:	fffff097          	auipc	ra,0xfffff
    8000362e:	3c0080e7          	jalr	960(ra) # 800029ea <fork>
}
    80003632:	60a2                	ld	ra,8(sp)
    80003634:	6402                	ld	s0,0(sp)
    80003636:	0141                	addi	sp,sp,16
    80003638:	8082                	ret

000000008000363a <sys_wait>:

uint64
sys_wait(void)
{
    8000363a:	1101                	addi	sp,sp,-32
    8000363c:	ec06                	sd	ra,24(sp)
    8000363e:	e822                	sd	s0,16(sp)
    80003640:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003642:	fe840593          	addi	a1,s0,-24
    80003646:	4501                	li	a0,0
    80003648:	00000097          	auipc	ra,0x0
    8000364c:	ece080e7          	jalr	-306(ra) # 80003516 <argaddr>
    80003650:	87aa                	mv	a5,a0
    return -1;
    80003652:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003654:	0007c863          	bltz	a5,80003664 <sys_wait+0x2a>
  return wait(p);
    80003658:	fe843503          	ld	a0,-24(s0)
    8000365c:	fffff097          	auipc	ra,0xfffff
    80003660:	c10080e7          	jalr	-1008(ra) # 8000226c <wait>
}
    80003664:	60e2                	ld	ra,24(sp)
    80003666:	6442                	ld	s0,16(sp)
    80003668:	6105                	addi	sp,sp,32
    8000366a:	8082                	ret

000000008000366c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000366c:	7179                	addi	sp,sp,-48
    8000366e:	f406                	sd	ra,40(sp)
    80003670:	f022                	sd	s0,32(sp)
    80003672:	ec26                	sd	s1,24(sp)
    80003674:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003676:	fdc40593          	addi	a1,s0,-36
    8000367a:	4501                	li	a0,0
    8000367c:	00000097          	auipc	ra,0x0
    80003680:	e78080e7          	jalr	-392(ra) # 800034f4 <argint>
    return -1;
    80003684:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003686:	00054f63          	bltz	a0,800036a4 <sys_sbrk+0x38>
  addr = myproc()->sz;
    8000368a:	ffffe097          	auipc	ra,0xffffe
    8000368e:	686080e7          	jalr	1670(ra) # 80001d10 <myproc>
    80003692:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80003694:	fdc42503          	lw	a0,-36(s0)
    80003698:	fffff097          	auipc	ra,0xfffff
    8000369c:	9ea080e7          	jalr	-1558(ra) # 80002082 <growproc>
    800036a0:	00054863          	bltz	a0,800036b0 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800036a4:	8526                	mv	a0,s1
    800036a6:	70a2                	ld	ra,40(sp)
    800036a8:	7402                	ld	s0,32(sp)
    800036aa:	64e2                	ld	s1,24(sp)
    800036ac:	6145                	addi	sp,sp,48
    800036ae:	8082                	ret
    return -1;
    800036b0:	54fd                	li	s1,-1
    800036b2:	bfcd                	j	800036a4 <sys_sbrk+0x38>

00000000800036b4 <sys_sleep>:

uint64
sys_sleep(void)
{
    800036b4:	7139                	addi	sp,sp,-64
    800036b6:	fc06                	sd	ra,56(sp)
    800036b8:	f822                	sd	s0,48(sp)
    800036ba:	f426                	sd	s1,40(sp)
    800036bc:	f04a                	sd	s2,32(sp)
    800036be:	ec4e                	sd	s3,24(sp)
    800036c0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800036c2:	fcc40593          	addi	a1,s0,-52
    800036c6:	4501                	li	a0,0
    800036c8:	00000097          	auipc	ra,0x0
    800036cc:	e2c080e7          	jalr	-468(ra) # 800034f4 <argint>
    return -1;
    800036d0:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800036d2:	06054563          	bltz	a0,8000373c <sys_sleep+0x88>
  acquire(&tickslock);
    800036d6:	00021517          	auipc	a0,0x21
    800036da:	3fa50513          	addi	a0,a0,1018 # 80024ad0 <tickslock>
    800036de:	ffffd097          	auipc	ra,0xffffd
    800036e2:	4e4080e7          	jalr	1252(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    800036e6:	00007917          	auipc	s2,0x7
    800036ea:	94a92903          	lw	s2,-1718(s2) # 8000a030 <ticks>
  while(ticks - ticks0 < n){
    800036ee:	fcc42783          	lw	a5,-52(s0)
    800036f2:	cf85                	beqz	a5,8000372a <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800036f4:	00021997          	auipc	s3,0x21
    800036f8:	3dc98993          	addi	s3,s3,988 # 80024ad0 <tickslock>
    800036fc:	00007497          	auipc	s1,0x7
    80003700:	93448493          	addi	s1,s1,-1740 # 8000a030 <ticks>
    if(myproc()->killed){
    80003704:	ffffe097          	auipc	ra,0xffffe
    80003708:	60c080e7          	jalr	1548(ra) # 80001d10 <myproc>
    8000370c:	551c                	lw	a5,40(a0)
    8000370e:	ef9d                	bnez	a5,8000374c <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003710:	85ce                	mv	a1,s3
    80003712:	8526                	mv	a0,s1
    80003714:	fffff097          	auipc	ra,0xfffff
    80003718:	af4080e7          	jalr	-1292(ra) # 80002208 <sleep>
  while(ticks - ticks0 < n){
    8000371c:	409c                	lw	a5,0(s1)
    8000371e:	412787bb          	subw	a5,a5,s2
    80003722:	fcc42703          	lw	a4,-52(s0)
    80003726:	fce7efe3          	bltu	a5,a4,80003704 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000372a:	00021517          	auipc	a0,0x21
    8000372e:	3a650513          	addi	a0,a0,934 # 80024ad0 <tickslock>
    80003732:	ffffd097          	auipc	ra,0xffffd
    80003736:	544080e7          	jalr	1348(ra) # 80000c76 <release>
  return 0;
    8000373a:	4781                	li	a5,0
}
    8000373c:	853e                	mv	a0,a5
    8000373e:	70e2                	ld	ra,56(sp)
    80003740:	7442                	ld	s0,48(sp)
    80003742:	74a2                	ld	s1,40(sp)
    80003744:	7902                	ld	s2,32(sp)
    80003746:	69e2                	ld	s3,24(sp)
    80003748:	6121                	addi	sp,sp,64
    8000374a:	8082                	ret
      release(&tickslock);
    8000374c:	00021517          	auipc	a0,0x21
    80003750:	38450513          	addi	a0,a0,900 # 80024ad0 <tickslock>
    80003754:	ffffd097          	auipc	ra,0xffffd
    80003758:	522080e7          	jalr	1314(ra) # 80000c76 <release>
      return -1;
    8000375c:	57fd                	li	a5,-1
    8000375e:	bff9                	j	8000373c <sys_sleep+0x88>

0000000080003760 <sys_kill>:

uint64
sys_kill(void)
{
    80003760:	1101                	addi	sp,sp,-32
    80003762:	ec06                	sd	ra,24(sp)
    80003764:	e822                	sd	s0,16(sp)
    80003766:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003768:	fec40593          	addi	a1,s0,-20
    8000376c:	4501                	li	a0,0
    8000376e:	00000097          	auipc	ra,0x0
    80003772:	d86080e7          	jalr	-634(ra) # 800034f4 <argint>
    80003776:	87aa                	mv	a5,a0
    return -1;
    80003778:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000377a:	0007c863          	bltz	a5,8000378a <sys_kill+0x2a>
  return kill(pid);
    8000377e:	fec42503          	lw	a0,-20(s0)
    80003782:	fffff097          	auipc	ra,0xfffff
    80003786:	dc2080e7          	jalr	-574(ra) # 80002544 <kill>
}
    8000378a:	60e2                	ld	ra,24(sp)
    8000378c:	6442                	ld	s0,16(sp)
    8000378e:	6105                	addi	sp,sp,32
    80003790:	8082                	ret

0000000080003792 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003792:	1101                	addi	sp,sp,-32
    80003794:	ec06                	sd	ra,24(sp)
    80003796:	e822                	sd	s0,16(sp)
    80003798:	e426                	sd	s1,8(sp)
    8000379a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000379c:	00021517          	auipc	a0,0x21
    800037a0:	33450513          	addi	a0,a0,820 # 80024ad0 <tickslock>
    800037a4:	ffffd097          	auipc	ra,0xffffd
    800037a8:	41e080e7          	jalr	1054(ra) # 80000bc2 <acquire>
  xticks = ticks;
    800037ac:	00007497          	auipc	s1,0x7
    800037b0:	8844a483          	lw	s1,-1916(s1) # 8000a030 <ticks>
  release(&tickslock);
    800037b4:	00021517          	auipc	a0,0x21
    800037b8:	31c50513          	addi	a0,a0,796 # 80024ad0 <tickslock>
    800037bc:	ffffd097          	auipc	ra,0xffffd
    800037c0:	4ba080e7          	jalr	1210(ra) # 80000c76 <release>
  return xticks;
}
    800037c4:	02049513          	slli	a0,s1,0x20
    800037c8:	9101                	srli	a0,a0,0x20
    800037ca:	60e2                	ld	ra,24(sp)
    800037cc:	6442                	ld	s0,16(sp)
    800037ce:	64a2                	ld	s1,8(sp)
    800037d0:	6105                	addi	sp,sp,32
    800037d2:	8082                	ret

00000000800037d4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800037d4:	7179                	addi	sp,sp,-48
    800037d6:	f406                	sd	ra,40(sp)
    800037d8:	f022                	sd	s0,32(sp)
    800037da:	ec26                	sd	s1,24(sp)
    800037dc:	e84a                	sd	s2,16(sp)
    800037de:	e44e                	sd	s3,8(sp)
    800037e0:	e052                	sd	s4,0(sp)
    800037e2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800037e4:	00006597          	auipc	a1,0x6
    800037e8:	1e458593          	addi	a1,a1,484 # 800099c8 <syscalls+0xb0>
    800037ec:	00021517          	auipc	a0,0x21
    800037f0:	2fc50513          	addi	a0,a0,764 # 80024ae8 <bcache>
    800037f4:	ffffd097          	auipc	ra,0xffffd
    800037f8:	33e080e7          	jalr	830(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800037fc:	00029797          	auipc	a5,0x29
    80003800:	2ec78793          	addi	a5,a5,748 # 8002cae8 <bcache+0x8000>
    80003804:	00029717          	auipc	a4,0x29
    80003808:	54c70713          	addi	a4,a4,1356 # 8002cd50 <bcache+0x8268>
    8000380c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003810:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003814:	00021497          	auipc	s1,0x21
    80003818:	2ec48493          	addi	s1,s1,748 # 80024b00 <bcache+0x18>
    b->next = bcache.head.next;
    8000381c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000381e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003820:	00006a17          	auipc	s4,0x6
    80003824:	1b0a0a13          	addi	s4,s4,432 # 800099d0 <syscalls+0xb8>
    b->next = bcache.head.next;
    80003828:	2b893783          	ld	a5,696(s2)
    8000382c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000382e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003832:	85d2                	mv	a1,s4
    80003834:	01048513          	addi	a0,s1,16
    80003838:	00001097          	auipc	ra,0x1
    8000383c:	7d4080e7          	jalr	2004(ra) # 8000500c <initsleeplock>
    bcache.head.next->prev = b;
    80003840:	2b893783          	ld	a5,696(s2)
    80003844:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003846:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000384a:	45848493          	addi	s1,s1,1112
    8000384e:	fd349de3          	bne	s1,s3,80003828 <binit+0x54>
  }
}
    80003852:	70a2                	ld	ra,40(sp)
    80003854:	7402                	ld	s0,32(sp)
    80003856:	64e2                	ld	s1,24(sp)
    80003858:	6942                	ld	s2,16(sp)
    8000385a:	69a2                	ld	s3,8(sp)
    8000385c:	6a02                	ld	s4,0(sp)
    8000385e:	6145                	addi	sp,sp,48
    80003860:	8082                	ret

0000000080003862 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003862:	7179                	addi	sp,sp,-48
    80003864:	f406                	sd	ra,40(sp)
    80003866:	f022                	sd	s0,32(sp)
    80003868:	ec26                	sd	s1,24(sp)
    8000386a:	e84a                	sd	s2,16(sp)
    8000386c:	e44e                	sd	s3,8(sp)
    8000386e:	1800                	addi	s0,sp,48
    80003870:	892a                	mv	s2,a0
    80003872:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003874:	00021517          	auipc	a0,0x21
    80003878:	27450513          	addi	a0,a0,628 # 80024ae8 <bcache>
    8000387c:	ffffd097          	auipc	ra,0xffffd
    80003880:	346080e7          	jalr	838(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003884:	00029497          	auipc	s1,0x29
    80003888:	51c4b483          	ld	s1,1308(s1) # 8002cda0 <bcache+0x82b8>
    8000388c:	00029797          	auipc	a5,0x29
    80003890:	4c478793          	addi	a5,a5,1220 # 8002cd50 <bcache+0x8268>
    80003894:	02f48f63          	beq	s1,a5,800038d2 <bread+0x70>
    80003898:	873e                	mv	a4,a5
    8000389a:	a021                	j	800038a2 <bread+0x40>
    8000389c:	68a4                	ld	s1,80(s1)
    8000389e:	02e48a63          	beq	s1,a4,800038d2 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800038a2:	449c                	lw	a5,8(s1)
    800038a4:	ff279ce3          	bne	a5,s2,8000389c <bread+0x3a>
    800038a8:	44dc                	lw	a5,12(s1)
    800038aa:	ff3799e3          	bne	a5,s3,8000389c <bread+0x3a>
      b->refcnt++;
    800038ae:	40bc                	lw	a5,64(s1)
    800038b0:	2785                	addiw	a5,a5,1
    800038b2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800038b4:	00021517          	auipc	a0,0x21
    800038b8:	23450513          	addi	a0,a0,564 # 80024ae8 <bcache>
    800038bc:	ffffd097          	auipc	ra,0xffffd
    800038c0:	3ba080e7          	jalr	954(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    800038c4:	01048513          	addi	a0,s1,16
    800038c8:	00001097          	auipc	ra,0x1
    800038cc:	77e080e7          	jalr	1918(ra) # 80005046 <acquiresleep>
      return b;
    800038d0:	a8b9                	j	8000392e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800038d2:	00029497          	auipc	s1,0x29
    800038d6:	4c64b483          	ld	s1,1222(s1) # 8002cd98 <bcache+0x82b0>
    800038da:	00029797          	auipc	a5,0x29
    800038de:	47678793          	addi	a5,a5,1142 # 8002cd50 <bcache+0x8268>
    800038e2:	00f48863          	beq	s1,a5,800038f2 <bread+0x90>
    800038e6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800038e8:	40bc                	lw	a5,64(s1)
    800038ea:	cf81                	beqz	a5,80003902 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800038ec:	64a4                	ld	s1,72(s1)
    800038ee:	fee49de3          	bne	s1,a4,800038e8 <bread+0x86>
  panic("bget: no buffers");
    800038f2:	00006517          	auipc	a0,0x6
    800038f6:	0e650513          	addi	a0,a0,230 # 800099d8 <syscalls+0xc0>
    800038fa:	ffffd097          	auipc	ra,0xffffd
    800038fe:	c30080e7          	jalr	-976(ra) # 8000052a <panic>
      b->dev = dev;
    80003902:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003906:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000390a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000390e:	4785                	li	a5,1
    80003910:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003912:	00021517          	auipc	a0,0x21
    80003916:	1d650513          	addi	a0,a0,470 # 80024ae8 <bcache>
    8000391a:	ffffd097          	auipc	ra,0xffffd
    8000391e:	35c080e7          	jalr	860(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003922:	01048513          	addi	a0,s1,16
    80003926:	00001097          	auipc	ra,0x1
    8000392a:	720080e7          	jalr	1824(ra) # 80005046 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000392e:	409c                	lw	a5,0(s1)
    80003930:	cb89                	beqz	a5,80003942 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003932:	8526                	mv	a0,s1
    80003934:	70a2                	ld	ra,40(sp)
    80003936:	7402                	ld	s0,32(sp)
    80003938:	64e2                	ld	s1,24(sp)
    8000393a:	6942                	ld	s2,16(sp)
    8000393c:	69a2                	ld	s3,8(sp)
    8000393e:	6145                	addi	sp,sp,48
    80003940:	8082                	ret
    virtio_disk_rw(b, 0);
    80003942:	4581                	li	a1,0
    80003944:	8526                	mv	a0,s1
    80003946:	00003097          	auipc	ra,0x3
    8000394a:	460080e7          	jalr	1120(ra) # 80006da6 <virtio_disk_rw>
    b->valid = 1;
    8000394e:	4785                	li	a5,1
    80003950:	c09c                	sw	a5,0(s1)
  return b;
    80003952:	b7c5                	j	80003932 <bread+0xd0>

0000000080003954 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003954:	1101                	addi	sp,sp,-32
    80003956:	ec06                	sd	ra,24(sp)
    80003958:	e822                	sd	s0,16(sp)
    8000395a:	e426                	sd	s1,8(sp)
    8000395c:	1000                	addi	s0,sp,32
    8000395e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003960:	0541                	addi	a0,a0,16
    80003962:	00001097          	auipc	ra,0x1
    80003966:	77e080e7          	jalr	1918(ra) # 800050e0 <holdingsleep>
    8000396a:	cd01                	beqz	a0,80003982 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000396c:	4585                	li	a1,1
    8000396e:	8526                	mv	a0,s1
    80003970:	00003097          	auipc	ra,0x3
    80003974:	436080e7          	jalr	1078(ra) # 80006da6 <virtio_disk_rw>
}
    80003978:	60e2                	ld	ra,24(sp)
    8000397a:	6442                	ld	s0,16(sp)
    8000397c:	64a2                	ld	s1,8(sp)
    8000397e:	6105                	addi	sp,sp,32
    80003980:	8082                	ret
    panic("bwrite");
    80003982:	00006517          	auipc	a0,0x6
    80003986:	06e50513          	addi	a0,a0,110 # 800099f0 <syscalls+0xd8>
    8000398a:	ffffd097          	auipc	ra,0xffffd
    8000398e:	ba0080e7          	jalr	-1120(ra) # 8000052a <panic>

0000000080003992 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003992:	1101                	addi	sp,sp,-32
    80003994:	ec06                	sd	ra,24(sp)
    80003996:	e822                	sd	s0,16(sp)
    80003998:	e426                	sd	s1,8(sp)
    8000399a:	e04a                	sd	s2,0(sp)
    8000399c:	1000                	addi	s0,sp,32
    8000399e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800039a0:	01050913          	addi	s2,a0,16
    800039a4:	854a                	mv	a0,s2
    800039a6:	00001097          	auipc	ra,0x1
    800039aa:	73a080e7          	jalr	1850(ra) # 800050e0 <holdingsleep>
    800039ae:	c92d                	beqz	a0,80003a20 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800039b0:	854a                	mv	a0,s2
    800039b2:	00001097          	auipc	ra,0x1
    800039b6:	6ea080e7          	jalr	1770(ra) # 8000509c <releasesleep>

  acquire(&bcache.lock);
    800039ba:	00021517          	auipc	a0,0x21
    800039be:	12e50513          	addi	a0,a0,302 # 80024ae8 <bcache>
    800039c2:	ffffd097          	auipc	ra,0xffffd
    800039c6:	200080e7          	jalr	512(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800039ca:	40bc                	lw	a5,64(s1)
    800039cc:	37fd                	addiw	a5,a5,-1
    800039ce:	0007871b          	sext.w	a4,a5
    800039d2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800039d4:	eb05                	bnez	a4,80003a04 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800039d6:	68bc                	ld	a5,80(s1)
    800039d8:	64b8                	ld	a4,72(s1)
    800039da:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800039dc:	64bc                	ld	a5,72(s1)
    800039de:	68b8                	ld	a4,80(s1)
    800039e0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800039e2:	00029797          	auipc	a5,0x29
    800039e6:	10678793          	addi	a5,a5,262 # 8002cae8 <bcache+0x8000>
    800039ea:	2b87b703          	ld	a4,696(a5)
    800039ee:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800039f0:	00029717          	auipc	a4,0x29
    800039f4:	36070713          	addi	a4,a4,864 # 8002cd50 <bcache+0x8268>
    800039f8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800039fa:	2b87b703          	ld	a4,696(a5)
    800039fe:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003a00:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003a04:	00021517          	auipc	a0,0x21
    80003a08:	0e450513          	addi	a0,a0,228 # 80024ae8 <bcache>
    80003a0c:	ffffd097          	auipc	ra,0xffffd
    80003a10:	26a080e7          	jalr	618(ra) # 80000c76 <release>
}
    80003a14:	60e2                	ld	ra,24(sp)
    80003a16:	6442                	ld	s0,16(sp)
    80003a18:	64a2                	ld	s1,8(sp)
    80003a1a:	6902                	ld	s2,0(sp)
    80003a1c:	6105                	addi	sp,sp,32
    80003a1e:	8082                	ret
    panic("brelse");
    80003a20:	00006517          	auipc	a0,0x6
    80003a24:	fd850513          	addi	a0,a0,-40 # 800099f8 <syscalls+0xe0>
    80003a28:	ffffd097          	auipc	ra,0xffffd
    80003a2c:	b02080e7          	jalr	-1278(ra) # 8000052a <panic>

0000000080003a30 <bpin>:

void
bpin(struct buf *b) {
    80003a30:	1101                	addi	sp,sp,-32
    80003a32:	ec06                	sd	ra,24(sp)
    80003a34:	e822                	sd	s0,16(sp)
    80003a36:	e426                	sd	s1,8(sp)
    80003a38:	1000                	addi	s0,sp,32
    80003a3a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003a3c:	00021517          	auipc	a0,0x21
    80003a40:	0ac50513          	addi	a0,a0,172 # 80024ae8 <bcache>
    80003a44:	ffffd097          	auipc	ra,0xffffd
    80003a48:	17e080e7          	jalr	382(ra) # 80000bc2 <acquire>
  b->refcnt++;
    80003a4c:	40bc                	lw	a5,64(s1)
    80003a4e:	2785                	addiw	a5,a5,1
    80003a50:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003a52:	00021517          	auipc	a0,0x21
    80003a56:	09650513          	addi	a0,a0,150 # 80024ae8 <bcache>
    80003a5a:	ffffd097          	auipc	ra,0xffffd
    80003a5e:	21c080e7          	jalr	540(ra) # 80000c76 <release>
}
    80003a62:	60e2                	ld	ra,24(sp)
    80003a64:	6442                	ld	s0,16(sp)
    80003a66:	64a2                	ld	s1,8(sp)
    80003a68:	6105                	addi	sp,sp,32
    80003a6a:	8082                	ret

0000000080003a6c <bunpin>:

void
bunpin(struct buf *b) {
    80003a6c:	1101                	addi	sp,sp,-32
    80003a6e:	ec06                	sd	ra,24(sp)
    80003a70:	e822                	sd	s0,16(sp)
    80003a72:	e426                	sd	s1,8(sp)
    80003a74:	1000                	addi	s0,sp,32
    80003a76:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003a78:	00021517          	auipc	a0,0x21
    80003a7c:	07050513          	addi	a0,a0,112 # 80024ae8 <bcache>
    80003a80:	ffffd097          	auipc	ra,0xffffd
    80003a84:	142080e7          	jalr	322(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003a88:	40bc                	lw	a5,64(s1)
    80003a8a:	37fd                	addiw	a5,a5,-1
    80003a8c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003a8e:	00021517          	auipc	a0,0x21
    80003a92:	05a50513          	addi	a0,a0,90 # 80024ae8 <bcache>
    80003a96:	ffffd097          	auipc	ra,0xffffd
    80003a9a:	1e0080e7          	jalr	480(ra) # 80000c76 <release>
}
    80003a9e:	60e2                	ld	ra,24(sp)
    80003aa0:	6442                	ld	s0,16(sp)
    80003aa2:	64a2                	ld	s1,8(sp)
    80003aa4:	6105                	addi	sp,sp,32
    80003aa6:	8082                	ret

0000000080003aa8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003aa8:	1101                	addi	sp,sp,-32
    80003aaa:	ec06                	sd	ra,24(sp)
    80003aac:	e822                	sd	s0,16(sp)
    80003aae:	e426                	sd	s1,8(sp)
    80003ab0:	e04a                	sd	s2,0(sp)
    80003ab2:	1000                	addi	s0,sp,32
    80003ab4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003ab6:	00d5d59b          	srliw	a1,a1,0xd
    80003aba:	00029797          	auipc	a5,0x29
    80003abe:	70a7a783          	lw	a5,1802(a5) # 8002d1c4 <sb+0x1c>
    80003ac2:	9dbd                	addw	a1,a1,a5
    80003ac4:	00000097          	auipc	ra,0x0
    80003ac8:	d9e080e7          	jalr	-610(ra) # 80003862 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003acc:	0074f713          	andi	a4,s1,7
    80003ad0:	4785                	li	a5,1
    80003ad2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003ad6:	14ce                	slli	s1,s1,0x33
    80003ad8:	90d9                	srli	s1,s1,0x36
    80003ada:	00950733          	add	a4,a0,s1
    80003ade:	05874703          	lbu	a4,88(a4)
    80003ae2:	00e7f6b3          	and	a3,a5,a4
    80003ae6:	c69d                	beqz	a3,80003b14 <bfree+0x6c>
    80003ae8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003aea:	94aa                	add	s1,s1,a0
    80003aec:	fff7c793          	not	a5,a5
    80003af0:	8ff9                	and	a5,a5,a4
    80003af2:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003af6:	00001097          	auipc	ra,0x1
    80003afa:	430080e7          	jalr	1072(ra) # 80004f26 <log_write>
  brelse(bp);
    80003afe:	854a                	mv	a0,s2
    80003b00:	00000097          	auipc	ra,0x0
    80003b04:	e92080e7          	jalr	-366(ra) # 80003992 <brelse>
}
    80003b08:	60e2                	ld	ra,24(sp)
    80003b0a:	6442                	ld	s0,16(sp)
    80003b0c:	64a2                	ld	s1,8(sp)
    80003b0e:	6902                	ld	s2,0(sp)
    80003b10:	6105                	addi	sp,sp,32
    80003b12:	8082                	ret
    panic("freeing free block");
    80003b14:	00006517          	auipc	a0,0x6
    80003b18:	eec50513          	addi	a0,a0,-276 # 80009a00 <syscalls+0xe8>
    80003b1c:	ffffd097          	auipc	ra,0xffffd
    80003b20:	a0e080e7          	jalr	-1522(ra) # 8000052a <panic>

0000000080003b24 <balloc>:
{
    80003b24:	711d                	addi	sp,sp,-96
    80003b26:	ec86                	sd	ra,88(sp)
    80003b28:	e8a2                	sd	s0,80(sp)
    80003b2a:	e4a6                	sd	s1,72(sp)
    80003b2c:	e0ca                	sd	s2,64(sp)
    80003b2e:	fc4e                	sd	s3,56(sp)
    80003b30:	f852                	sd	s4,48(sp)
    80003b32:	f456                	sd	s5,40(sp)
    80003b34:	f05a                	sd	s6,32(sp)
    80003b36:	ec5e                	sd	s7,24(sp)
    80003b38:	e862                	sd	s8,16(sp)
    80003b3a:	e466                	sd	s9,8(sp)
    80003b3c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003b3e:	00029797          	auipc	a5,0x29
    80003b42:	66e7a783          	lw	a5,1646(a5) # 8002d1ac <sb+0x4>
    80003b46:	cbd1                	beqz	a5,80003bda <balloc+0xb6>
    80003b48:	8baa                	mv	s7,a0
    80003b4a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003b4c:	00029b17          	auipc	s6,0x29
    80003b50:	65cb0b13          	addi	s6,s6,1628 # 8002d1a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b54:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003b56:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b58:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003b5a:	6c89                	lui	s9,0x2
    80003b5c:	a831                	j	80003b78 <balloc+0x54>
    brelse(bp);
    80003b5e:	854a                	mv	a0,s2
    80003b60:	00000097          	auipc	ra,0x0
    80003b64:	e32080e7          	jalr	-462(ra) # 80003992 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003b68:	015c87bb          	addw	a5,s9,s5
    80003b6c:	00078a9b          	sext.w	s5,a5
    80003b70:	004b2703          	lw	a4,4(s6)
    80003b74:	06eaf363          	bgeu	s5,a4,80003bda <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003b78:	41fad79b          	sraiw	a5,s5,0x1f
    80003b7c:	0137d79b          	srliw	a5,a5,0x13
    80003b80:	015787bb          	addw	a5,a5,s5
    80003b84:	40d7d79b          	sraiw	a5,a5,0xd
    80003b88:	01cb2583          	lw	a1,28(s6)
    80003b8c:	9dbd                	addw	a1,a1,a5
    80003b8e:	855e                	mv	a0,s7
    80003b90:	00000097          	auipc	ra,0x0
    80003b94:	cd2080e7          	jalr	-814(ra) # 80003862 <bread>
    80003b98:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b9a:	004b2503          	lw	a0,4(s6)
    80003b9e:	000a849b          	sext.w	s1,s5
    80003ba2:	8662                	mv	a2,s8
    80003ba4:	faa4fde3          	bgeu	s1,a0,80003b5e <balloc+0x3a>
      m = 1 << (bi % 8);
    80003ba8:	41f6579b          	sraiw	a5,a2,0x1f
    80003bac:	01d7d69b          	srliw	a3,a5,0x1d
    80003bb0:	00c6873b          	addw	a4,a3,a2
    80003bb4:	00777793          	andi	a5,a4,7
    80003bb8:	9f95                	subw	a5,a5,a3
    80003bba:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003bbe:	4037571b          	sraiw	a4,a4,0x3
    80003bc2:	00e906b3          	add	a3,s2,a4
    80003bc6:	0586c683          	lbu	a3,88(a3)
    80003bca:	00d7f5b3          	and	a1,a5,a3
    80003bce:	cd91                	beqz	a1,80003bea <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003bd0:	2605                	addiw	a2,a2,1
    80003bd2:	2485                	addiw	s1,s1,1
    80003bd4:	fd4618e3          	bne	a2,s4,80003ba4 <balloc+0x80>
    80003bd8:	b759                	j	80003b5e <balloc+0x3a>
  panic("balloc: out of blocks");
    80003bda:	00006517          	auipc	a0,0x6
    80003bde:	e3e50513          	addi	a0,a0,-450 # 80009a18 <syscalls+0x100>
    80003be2:	ffffd097          	auipc	ra,0xffffd
    80003be6:	948080e7          	jalr	-1720(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003bea:	974a                	add	a4,a4,s2
    80003bec:	8fd5                	or	a5,a5,a3
    80003bee:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003bf2:	854a                	mv	a0,s2
    80003bf4:	00001097          	auipc	ra,0x1
    80003bf8:	332080e7          	jalr	818(ra) # 80004f26 <log_write>
        brelse(bp);
    80003bfc:	854a                	mv	a0,s2
    80003bfe:	00000097          	auipc	ra,0x0
    80003c02:	d94080e7          	jalr	-620(ra) # 80003992 <brelse>
  bp = bread(dev, bno);
    80003c06:	85a6                	mv	a1,s1
    80003c08:	855e                	mv	a0,s7
    80003c0a:	00000097          	auipc	ra,0x0
    80003c0e:	c58080e7          	jalr	-936(ra) # 80003862 <bread>
    80003c12:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003c14:	40000613          	li	a2,1024
    80003c18:	4581                	li	a1,0
    80003c1a:	05850513          	addi	a0,a0,88
    80003c1e:	ffffd097          	auipc	ra,0xffffd
    80003c22:	0a0080e7          	jalr	160(ra) # 80000cbe <memset>
  log_write(bp);
    80003c26:	854a                	mv	a0,s2
    80003c28:	00001097          	auipc	ra,0x1
    80003c2c:	2fe080e7          	jalr	766(ra) # 80004f26 <log_write>
  brelse(bp);
    80003c30:	854a                	mv	a0,s2
    80003c32:	00000097          	auipc	ra,0x0
    80003c36:	d60080e7          	jalr	-672(ra) # 80003992 <brelse>
}
    80003c3a:	8526                	mv	a0,s1
    80003c3c:	60e6                	ld	ra,88(sp)
    80003c3e:	6446                	ld	s0,80(sp)
    80003c40:	64a6                	ld	s1,72(sp)
    80003c42:	6906                	ld	s2,64(sp)
    80003c44:	79e2                	ld	s3,56(sp)
    80003c46:	7a42                	ld	s4,48(sp)
    80003c48:	7aa2                	ld	s5,40(sp)
    80003c4a:	7b02                	ld	s6,32(sp)
    80003c4c:	6be2                	ld	s7,24(sp)
    80003c4e:	6c42                	ld	s8,16(sp)
    80003c50:	6ca2                	ld	s9,8(sp)
    80003c52:	6125                	addi	sp,sp,96
    80003c54:	8082                	ret

0000000080003c56 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003c56:	7179                	addi	sp,sp,-48
    80003c58:	f406                	sd	ra,40(sp)
    80003c5a:	f022                	sd	s0,32(sp)
    80003c5c:	ec26                	sd	s1,24(sp)
    80003c5e:	e84a                	sd	s2,16(sp)
    80003c60:	e44e                	sd	s3,8(sp)
    80003c62:	e052                	sd	s4,0(sp)
    80003c64:	1800                	addi	s0,sp,48
    80003c66:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003c68:	47ad                	li	a5,11
    80003c6a:	04b7fe63          	bgeu	a5,a1,80003cc6 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003c6e:	ff45849b          	addiw	s1,a1,-12
    80003c72:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003c76:	0ff00793          	li	a5,255
    80003c7a:	0ae7e463          	bltu	a5,a4,80003d22 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003c7e:	08052583          	lw	a1,128(a0)
    80003c82:	c5b5                	beqz	a1,80003cee <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003c84:	00092503          	lw	a0,0(s2)
    80003c88:	00000097          	auipc	ra,0x0
    80003c8c:	bda080e7          	jalr	-1062(ra) # 80003862 <bread>
    80003c90:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003c92:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003c96:	02049713          	slli	a4,s1,0x20
    80003c9a:	01e75593          	srli	a1,a4,0x1e
    80003c9e:	00b784b3          	add	s1,a5,a1
    80003ca2:	0004a983          	lw	s3,0(s1)
    80003ca6:	04098e63          	beqz	s3,80003d02 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003caa:	8552                	mv	a0,s4
    80003cac:	00000097          	auipc	ra,0x0
    80003cb0:	ce6080e7          	jalr	-794(ra) # 80003992 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003cb4:	854e                	mv	a0,s3
    80003cb6:	70a2                	ld	ra,40(sp)
    80003cb8:	7402                	ld	s0,32(sp)
    80003cba:	64e2                	ld	s1,24(sp)
    80003cbc:	6942                	ld	s2,16(sp)
    80003cbe:	69a2                	ld	s3,8(sp)
    80003cc0:	6a02                	ld	s4,0(sp)
    80003cc2:	6145                	addi	sp,sp,48
    80003cc4:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003cc6:	02059793          	slli	a5,a1,0x20
    80003cca:	01e7d593          	srli	a1,a5,0x1e
    80003cce:	00b504b3          	add	s1,a0,a1
    80003cd2:	0504a983          	lw	s3,80(s1)
    80003cd6:	fc099fe3          	bnez	s3,80003cb4 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003cda:	4108                	lw	a0,0(a0)
    80003cdc:	00000097          	auipc	ra,0x0
    80003ce0:	e48080e7          	jalr	-440(ra) # 80003b24 <balloc>
    80003ce4:	0005099b          	sext.w	s3,a0
    80003ce8:	0534a823          	sw	s3,80(s1)
    80003cec:	b7e1                	j	80003cb4 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003cee:	4108                	lw	a0,0(a0)
    80003cf0:	00000097          	auipc	ra,0x0
    80003cf4:	e34080e7          	jalr	-460(ra) # 80003b24 <balloc>
    80003cf8:	0005059b          	sext.w	a1,a0
    80003cfc:	08b92023          	sw	a1,128(s2)
    80003d00:	b751                	j	80003c84 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003d02:	00092503          	lw	a0,0(s2)
    80003d06:	00000097          	auipc	ra,0x0
    80003d0a:	e1e080e7          	jalr	-482(ra) # 80003b24 <balloc>
    80003d0e:	0005099b          	sext.w	s3,a0
    80003d12:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003d16:	8552                	mv	a0,s4
    80003d18:	00001097          	auipc	ra,0x1
    80003d1c:	20e080e7          	jalr	526(ra) # 80004f26 <log_write>
    80003d20:	b769                	j	80003caa <bmap+0x54>
  panic("bmap: out of range");
    80003d22:	00006517          	auipc	a0,0x6
    80003d26:	d0e50513          	addi	a0,a0,-754 # 80009a30 <syscalls+0x118>
    80003d2a:	ffffd097          	auipc	ra,0xffffd
    80003d2e:	800080e7          	jalr	-2048(ra) # 8000052a <panic>

0000000080003d32 <iget>:
{
    80003d32:	7179                	addi	sp,sp,-48
    80003d34:	f406                	sd	ra,40(sp)
    80003d36:	f022                	sd	s0,32(sp)
    80003d38:	ec26                	sd	s1,24(sp)
    80003d3a:	e84a                	sd	s2,16(sp)
    80003d3c:	e44e                	sd	s3,8(sp)
    80003d3e:	e052                	sd	s4,0(sp)
    80003d40:	1800                	addi	s0,sp,48
    80003d42:	89aa                	mv	s3,a0
    80003d44:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003d46:	00029517          	auipc	a0,0x29
    80003d4a:	48250513          	addi	a0,a0,1154 # 8002d1c8 <itable>
    80003d4e:	ffffd097          	auipc	ra,0xffffd
    80003d52:	e74080e7          	jalr	-396(ra) # 80000bc2 <acquire>
  empty = 0;
    80003d56:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003d58:	00029497          	auipc	s1,0x29
    80003d5c:	48848493          	addi	s1,s1,1160 # 8002d1e0 <itable+0x18>
    80003d60:	0002b697          	auipc	a3,0x2b
    80003d64:	f1068693          	addi	a3,a3,-240 # 8002ec70 <log>
    80003d68:	a039                	j	80003d76 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003d6a:	02090b63          	beqz	s2,80003da0 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003d6e:	08848493          	addi	s1,s1,136
    80003d72:	02d48a63          	beq	s1,a3,80003da6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003d76:	449c                	lw	a5,8(s1)
    80003d78:	fef059e3          	blez	a5,80003d6a <iget+0x38>
    80003d7c:	4098                	lw	a4,0(s1)
    80003d7e:	ff3716e3          	bne	a4,s3,80003d6a <iget+0x38>
    80003d82:	40d8                	lw	a4,4(s1)
    80003d84:	ff4713e3          	bne	a4,s4,80003d6a <iget+0x38>
      ip->ref++;
    80003d88:	2785                	addiw	a5,a5,1
    80003d8a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003d8c:	00029517          	auipc	a0,0x29
    80003d90:	43c50513          	addi	a0,a0,1084 # 8002d1c8 <itable>
    80003d94:	ffffd097          	auipc	ra,0xffffd
    80003d98:	ee2080e7          	jalr	-286(ra) # 80000c76 <release>
      return ip;
    80003d9c:	8926                	mv	s2,s1
    80003d9e:	a03d                	j	80003dcc <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003da0:	f7f9                	bnez	a5,80003d6e <iget+0x3c>
    80003da2:	8926                	mv	s2,s1
    80003da4:	b7e9                	j	80003d6e <iget+0x3c>
  if(empty == 0)
    80003da6:	02090c63          	beqz	s2,80003dde <iget+0xac>
  ip->dev = dev;
    80003daa:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003dae:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003db2:	4785                	li	a5,1
    80003db4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003db8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003dbc:	00029517          	auipc	a0,0x29
    80003dc0:	40c50513          	addi	a0,a0,1036 # 8002d1c8 <itable>
    80003dc4:	ffffd097          	auipc	ra,0xffffd
    80003dc8:	eb2080e7          	jalr	-334(ra) # 80000c76 <release>
}
    80003dcc:	854a                	mv	a0,s2
    80003dce:	70a2                	ld	ra,40(sp)
    80003dd0:	7402                	ld	s0,32(sp)
    80003dd2:	64e2                	ld	s1,24(sp)
    80003dd4:	6942                	ld	s2,16(sp)
    80003dd6:	69a2                	ld	s3,8(sp)
    80003dd8:	6a02                	ld	s4,0(sp)
    80003dda:	6145                	addi	sp,sp,48
    80003ddc:	8082                	ret
    panic("iget: no inodes");
    80003dde:	00006517          	auipc	a0,0x6
    80003de2:	c6a50513          	addi	a0,a0,-918 # 80009a48 <syscalls+0x130>
    80003de6:	ffffc097          	auipc	ra,0xffffc
    80003dea:	744080e7          	jalr	1860(ra) # 8000052a <panic>

0000000080003dee <fsinit>:
fsinit(int dev) {
    80003dee:	7179                	addi	sp,sp,-48
    80003df0:	f406                	sd	ra,40(sp)
    80003df2:	f022                	sd	s0,32(sp)
    80003df4:	ec26                	sd	s1,24(sp)
    80003df6:	e84a                	sd	s2,16(sp)
    80003df8:	e44e                	sd	s3,8(sp)
    80003dfa:	1800                	addi	s0,sp,48
    80003dfc:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003dfe:	4585                	li	a1,1
    80003e00:	00000097          	auipc	ra,0x0
    80003e04:	a62080e7          	jalr	-1438(ra) # 80003862 <bread>
    80003e08:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003e0a:	00029997          	auipc	s3,0x29
    80003e0e:	39e98993          	addi	s3,s3,926 # 8002d1a8 <sb>
    80003e12:	02000613          	li	a2,32
    80003e16:	05850593          	addi	a1,a0,88
    80003e1a:	854e                	mv	a0,s3
    80003e1c:	ffffd097          	auipc	ra,0xffffd
    80003e20:	efe080e7          	jalr	-258(ra) # 80000d1a <memmove>
  brelse(bp);
    80003e24:	8526                	mv	a0,s1
    80003e26:	00000097          	auipc	ra,0x0
    80003e2a:	b6c080e7          	jalr	-1172(ra) # 80003992 <brelse>
  if(sb.magic != FSMAGIC)
    80003e2e:	0009a703          	lw	a4,0(s3)
    80003e32:	102037b7          	lui	a5,0x10203
    80003e36:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003e3a:	02f71263          	bne	a4,a5,80003e5e <fsinit+0x70>
  initlog(dev, &sb);
    80003e3e:	00029597          	auipc	a1,0x29
    80003e42:	36a58593          	addi	a1,a1,874 # 8002d1a8 <sb>
    80003e46:	854a                	mv	a0,s2
    80003e48:	00001097          	auipc	ra,0x1
    80003e4c:	e60080e7          	jalr	-416(ra) # 80004ca8 <initlog>
}
    80003e50:	70a2                	ld	ra,40(sp)
    80003e52:	7402                	ld	s0,32(sp)
    80003e54:	64e2                	ld	s1,24(sp)
    80003e56:	6942                	ld	s2,16(sp)
    80003e58:	69a2                	ld	s3,8(sp)
    80003e5a:	6145                	addi	sp,sp,48
    80003e5c:	8082                	ret
    panic("invalid file system");
    80003e5e:	00006517          	auipc	a0,0x6
    80003e62:	bfa50513          	addi	a0,a0,-1030 # 80009a58 <syscalls+0x140>
    80003e66:	ffffc097          	auipc	ra,0xffffc
    80003e6a:	6c4080e7          	jalr	1732(ra) # 8000052a <panic>

0000000080003e6e <iinit>:
{
    80003e6e:	7179                	addi	sp,sp,-48
    80003e70:	f406                	sd	ra,40(sp)
    80003e72:	f022                	sd	s0,32(sp)
    80003e74:	ec26                	sd	s1,24(sp)
    80003e76:	e84a                	sd	s2,16(sp)
    80003e78:	e44e                	sd	s3,8(sp)
    80003e7a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003e7c:	00006597          	auipc	a1,0x6
    80003e80:	bf458593          	addi	a1,a1,-1036 # 80009a70 <syscalls+0x158>
    80003e84:	00029517          	auipc	a0,0x29
    80003e88:	34450513          	addi	a0,a0,836 # 8002d1c8 <itable>
    80003e8c:	ffffd097          	auipc	ra,0xffffd
    80003e90:	ca6080e7          	jalr	-858(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003e94:	00029497          	auipc	s1,0x29
    80003e98:	35c48493          	addi	s1,s1,860 # 8002d1f0 <itable+0x28>
    80003e9c:	0002b997          	auipc	s3,0x2b
    80003ea0:	de498993          	addi	s3,s3,-540 # 8002ec80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003ea4:	00006917          	auipc	s2,0x6
    80003ea8:	bd490913          	addi	s2,s2,-1068 # 80009a78 <syscalls+0x160>
    80003eac:	85ca                	mv	a1,s2
    80003eae:	8526                	mv	a0,s1
    80003eb0:	00001097          	auipc	ra,0x1
    80003eb4:	15c080e7          	jalr	348(ra) # 8000500c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003eb8:	08848493          	addi	s1,s1,136
    80003ebc:	ff3498e3          	bne	s1,s3,80003eac <iinit+0x3e>
}
    80003ec0:	70a2                	ld	ra,40(sp)
    80003ec2:	7402                	ld	s0,32(sp)
    80003ec4:	64e2                	ld	s1,24(sp)
    80003ec6:	6942                	ld	s2,16(sp)
    80003ec8:	69a2                	ld	s3,8(sp)
    80003eca:	6145                	addi	sp,sp,48
    80003ecc:	8082                	ret

0000000080003ece <ialloc>:
{
    80003ece:	715d                	addi	sp,sp,-80
    80003ed0:	e486                	sd	ra,72(sp)
    80003ed2:	e0a2                	sd	s0,64(sp)
    80003ed4:	fc26                	sd	s1,56(sp)
    80003ed6:	f84a                	sd	s2,48(sp)
    80003ed8:	f44e                	sd	s3,40(sp)
    80003eda:	f052                	sd	s4,32(sp)
    80003edc:	ec56                	sd	s5,24(sp)
    80003ede:	e85a                	sd	s6,16(sp)
    80003ee0:	e45e                	sd	s7,8(sp)
    80003ee2:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ee4:	00029717          	auipc	a4,0x29
    80003ee8:	2d072703          	lw	a4,720(a4) # 8002d1b4 <sb+0xc>
    80003eec:	4785                	li	a5,1
    80003eee:	04e7fa63          	bgeu	a5,a4,80003f42 <ialloc+0x74>
    80003ef2:	8aaa                	mv	s5,a0
    80003ef4:	8bae                	mv	s7,a1
    80003ef6:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003ef8:	00029a17          	auipc	s4,0x29
    80003efc:	2b0a0a13          	addi	s4,s4,688 # 8002d1a8 <sb>
    80003f00:	00048b1b          	sext.w	s6,s1
    80003f04:	0044d793          	srli	a5,s1,0x4
    80003f08:	018a2583          	lw	a1,24(s4)
    80003f0c:	9dbd                	addw	a1,a1,a5
    80003f0e:	8556                	mv	a0,s5
    80003f10:	00000097          	auipc	ra,0x0
    80003f14:	952080e7          	jalr	-1710(ra) # 80003862 <bread>
    80003f18:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003f1a:	05850993          	addi	s3,a0,88
    80003f1e:	00f4f793          	andi	a5,s1,15
    80003f22:	079a                	slli	a5,a5,0x6
    80003f24:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003f26:	00099783          	lh	a5,0(s3)
    80003f2a:	c785                	beqz	a5,80003f52 <ialloc+0x84>
    brelse(bp);
    80003f2c:	00000097          	auipc	ra,0x0
    80003f30:	a66080e7          	jalr	-1434(ra) # 80003992 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003f34:	0485                	addi	s1,s1,1
    80003f36:	00ca2703          	lw	a4,12(s4)
    80003f3a:	0004879b          	sext.w	a5,s1
    80003f3e:	fce7e1e3          	bltu	a5,a4,80003f00 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003f42:	00006517          	auipc	a0,0x6
    80003f46:	b3e50513          	addi	a0,a0,-1218 # 80009a80 <syscalls+0x168>
    80003f4a:	ffffc097          	auipc	ra,0xffffc
    80003f4e:	5e0080e7          	jalr	1504(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003f52:	04000613          	li	a2,64
    80003f56:	4581                	li	a1,0
    80003f58:	854e                	mv	a0,s3
    80003f5a:	ffffd097          	auipc	ra,0xffffd
    80003f5e:	d64080e7          	jalr	-668(ra) # 80000cbe <memset>
      dip->type = type;
    80003f62:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003f66:	854a                	mv	a0,s2
    80003f68:	00001097          	auipc	ra,0x1
    80003f6c:	fbe080e7          	jalr	-66(ra) # 80004f26 <log_write>
      brelse(bp);
    80003f70:	854a                	mv	a0,s2
    80003f72:	00000097          	auipc	ra,0x0
    80003f76:	a20080e7          	jalr	-1504(ra) # 80003992 <brelse>
      return iget(dev, inum);
    80003f7a:	85da                	mv	a1,s6
    80003f7c:	8556                	mv	a0,s5
    80003f7e:	00000097          	auipc	ra,0x0
    80003f82:	db4080e7          	jalr	-588(ra) # 80003d32 <iget>
}
    80003f86:	60a6                	ld	ra,72(sp)
    80003f88:	6406                	ld	s0,64(sp)
    80003f8a:	74e2                	ld	s1,56(sp)
    80003f8c:	7942                	ld	s2,48(sp)
    80003f8e:	79a2                	ld	s3,40(sp)
    80003f90:	7a02                	ld	s4,32(sp)
    80003f92:	6ae2                	ld	s5,24(sp)
    80003f94:	6b42                	ld	s6,16(sp)
    80003f96:	6ba2                	ld	s7,8(sp)
    80003f98:	6161                	addi	sp,sp,80
    80003f9a:	8082                	ret

0000000080003f9c <iupdate>:
{
    80003f9c:	1101                	addi	sp,sp,-32
    80003f9e:	ec06                	sd	ra,24(sp)
    80003fa0:	e822                	sd	s0,16(sp)
    80003fa2:	e426                	sd	s1,8(sp)
    80003fa4:	e04a                	sd	s2,0(sp)
    80003fa6:	1000                	addi	s0,sp,32
    80003fa8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003faa:	415c                	lw	a5,4(a0)
    80003fac:	0047d79b          	srliw	a5,a5,0x4
    80003fb0:	00029597          	auipc	a1,0x29
    80003fb4:	2105a583          	lw	a1,528(a1) # 8002d1c0 <sb+0x18>
    80003fb8:	9dbd                	addw	a1,a1,a5
    80003fba:	4108                	lw	a0,0(a0)
    80003fbc:	00000097          	auipc	ra,0x0
    80003fc0:	8a6080e7          	jalr	-1882(ra) # 80003862 <bread>
    80003fc4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003fc6:	05850793          	addi	a5,a0,88
    80003fca:	40c8                	lw	a0,4(s1)
    80003fcc:	893d                	andi	a0,a0,15
    80003fce:	051a                	slli	a0,a0,0x6
    80003fd0:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003fd2:	04449703          	lh	a4,68(s1)
    80003fd6:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003fda:	04649703          	lh	a4,70(s1)
    80003fde:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003fe2:	04849703          	lh	a4,72(s1)
    80003fe6:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003fea:	04a49703          	lh	a4,74(s1)
    80003fee:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003ff2:	44f8                	lw	a4,76(s1)
    80003ff4:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003ff6:	03400613          	li	a2,52
    80003ffa:	05048593          	addi	a1,s1,80
    80003ffe:	0531                	addi	a0,a0,12
    80004000:	ffffd097          	auipc	ra,0xffffd
    80004004:	d1a080e7          	jalr	-742(ra) # 80000d1a <memmove>
  log_write(bp);
    80004008:	854a                	mv	a0,s2
    8000400a:	00001097          	auipc	ra,0x1
    8000400e:	f1c080e7          	jalr	-228(ra) # 80004f26 <log_write>
  brelse(bp);
    80004012:	854a                	mv	a0,s2
    80004014:	00000097          	auipc	ra,0x0
    80004018:	97e080e7          	jalr	-1666(ra) # 80003992 <brelse>
}
    8000401c:	60e2                	ld	ra,24(sp)
    8000401e:	6442                	ld	s0,16(sp)
    80004020:	64a2                	ld	s1,8(sp)
    80004022:	6902                	ld	s2,0(sp)
    80004024:	6105                	addi	sp,sp,32
    80004026:	8082                	ret

0000000080004028 <idup>:
{
    80004028:	1101                	addi	sp,sp,-32
    8000402a:	ec06                	sd	ra,24(sp)
    8000402c:	e822                	sd	s0,16(sp)
    8000402e:	e426                	sd	s1,8(sp)
    80004030:	1000                	addi	s0,sp,32
    80004032:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004034:	00029517          	auipc	a0,0x29
    80004038:	19450513          	addi	a0,a0,404 # 8002d1c8 <itable>
    8000403c:	ffffd097          	auipc	ra,0xffffd
    80004040:	b86080e7          	jalr	-1146(ra) # 80000bc2 <acquire>
  ip->ref++;
    80004044:	449c                	lw	a5,8(s1)
    80004046:	2785                	addiw	a5,a5,1
    80004048:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000404a:	00029517          	auipc	a0,0x29
    8000404e:	17e50513          	addi	a0,a0,382 # 8002d1c8 <itable>
    80004052:	ffffd097          	auipc	ra,0xffffd
    80004056:	c24080e7          	jalr	-988(ra) # 80000c76 <release>
}
    8000405a:	8526                	mv	a0,s1
    8000405c:	60e2                	ld	ra,24(sp)
    8000405e:	6442                	ld	s0,16(sp)
    80004060:	64a2                	ld	s1,8(sp)
    80004062:	6105                	addi	sp,sp,32
    80004064:	8082                	ret

0000000080004066 <ilock>:
{
    80004066:	1101                	addi	sp,sp,-32
    80004068:	ec06                	sd	ra,24(sp)
    8000406a:	e822                	sd	s0,16(sp)
    8000406c:	e426                	sd	s1,8(sp)
    8000406e:	e04a                	sd	s2,0(sp)
    80004070:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004072:	c115                	beqz	a0,80004096 <ilock+0x30>
    80004074:	84aa                	mv	s1,a0
    80004076:	451c                	lw	a5,8(a0)
    80004078:	00f05f63          	blez	a5,80004096 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000407c:	0541                	addi	a0,a0,16
    8000407e:	00001097          	auipc	ra,0x1
    80004082:	fc8080e7          	jalr	-56(ra) # 80005046 <acquiresleep>
  if(ip->valid == 0){
    80004086:	40bc                	lw	a5,64(s1)
    80004088:	cf99                	beqz	a5,800040a6 <ilock+0x40>
}
    8000408a:	60e2                	ld	ra,24(sp)
    8000408c:	6442                	ld	s0,16(sp)
    8000408e:	64a2                	ld	s1,8(sp)
    80004090:	6902                	ld	s2,0(sp)
    80004092:	6105                	addi	sp,sp,32
    80004094:	8082                	ret
    panic("ilock");
    80004096:	00006517          	auipc	a0,0x6
    8000409a:	a0250513          	addi	a0,a0,-1534 # 80009a98 <syscalls+0x180>
    8000409e:	ffffc097          	auipc	ra,0xffffc
    800040a2:	48c080e7          	jalr	1164(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800040a6:	40dc                	lw	a5,4(s1)
    800040a8:	0047d79b          	srliw	a5,a5,0x4
    800040ac:	00029597          	auipc	a1,0x29
    800040b0:	1145a583          	lw	a1,276(a1) # 8002d1c0 <sb+0x18>
    800040b4:	9dbd                	addw	a1,a1,a5
    800040b6:	4088                	lw	a0,0(s1)
    800040b8:	fffff097          	auipc	ra,0xfffff
    800040bc:	7aa080e7          	jalr	1962(ra) # 80003862 <bread>
    800040c0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800040c2:	05850593          	addi	a1,a0,88
    800040c6:	40dc                	lw	a5,4(s1)
    800040c8:	8bbd                	andi	a5,a5,15
    800040ca:	079a                	slli	a5,a5,0x6
    800040cc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800040ce:	00059783          	lh	a5,0(a1)
    800040d2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800040d6:	00259783          	lh	a5,2(a1)
    800040da:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800040de:	00459783          	lh	a5,4(a1)
    800040e2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800040e6:	00659783          	lh	a5,6(a1)
    800040ea:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800040ee:	459c                	lw	a5,8(a1)
    800040f0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800040f2:	03400613          	li	a2,52
    800040f6:	05b1                	addi	a1,a1,12
    800040f8:	05048513          	addi	a0,s1,80
    800040fc:	ffffd097          	auipc	ra,0xffffd
    80004100:	c1e080e7          	jalr	-994(ra) # 80000d1a <memmove>
    brelse(bp);
    80004104:	854a                	mv	a0,s2
    80004106:	00000097          	auipc	ra,0x0
    8000410a:	88c080e7          	jalr	-1908(ra) # 80003992 <brelse>
    ip->valid = 1;
    8000410e:	4785                	li	a5,1
    80004110:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004112:	04449783          	lh	a5,68(s1)
    80004116:	fbb5                	bnez	a5,8000408a <ilock+0x24>
      panic("ilock: no type");
    80004118:	00006517          	auipc	a0,0x6
    8000411c:	98850513          	addi	a0,a0,-1656 # 80009aa0 <syscalls+0x188>
    80004120:	ffffc097          	auipc	ra,0xffffc
    80004124:	40a080e7          	jalr	1034(ra) # 8000052a <panic>

0000000080004128 <iunlock>:
{
    80004128:	1101                	addi	sp,sp,-32
    8000412a:	ec06                	sd	ra,24(sp)
    8000412c:	e822                	sd	s0,16(sp)
    8000412e:	e426                	sd	s1,8(sp)
    80004130:	e04a                	sd	s2,0(sp)
    80004132:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004134:	c905                	beqz	a0,80004164 <iunlock+0x3c>
    80004136:	84aa                	mv	s1,a0
    80004138:	01050913          	addi	s2,a0,16
    8000413c:	854a                	mv	a0,s2
    8000413e:	00001097          	auipc	ra,0x1
    80004142:	fa2080e7          	jalr	-94(ra) # 800050e0 <holdingsleep>
    80004146:	cd19                	beqz	a0,80004164 <iunlock+0x3c>
    80004148:	449c                	lw	a5,8(s1)
    8000414a:	00f05d63          	blez	a5,80004164 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000414e:	854a                	mv	a0,s2
    80004150:	00001097          	auipc	ra,0x1
    80004154:	f4c080e7          	jalr	-180(ra) # 8000509c <releasesleep>
}
    80004158:	60e2                	ld	ra,24(sp)
    8000415a:	6442                	ld	s0,16(sp)
    8000415c:	64a2                	ld	s1,8(sp)
    8000415e:	6902                	ld	s2,0(sp)
    80004160:	6105                	addi	sp,sp,32
    80004162:	8082                	ret
    panic("iunlock");
    80004164:	00006517          	auipc	a0,0x6
    80004168:	94c50513          	addi	a0,a0,-1716 # 80009ab0 <syscalls+0x198>
    8000416c:	ffffc097          	auipc	ra,0xffffc
    80004170:	3be080e7          	jalr	958(ra) # 8000052a <panic>

0000000080004174 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004174:	7179                	addi	sp,sp,-48
    80004176:	f406                	sd	ra,40(sp)
    80004178:	f022                	sd	s0,32(sp)
    8000417a:	ec26                	sd	s1,24(sp)
    8000417c:	e84a                	sd	s2,16(sp)
    8000417e:	e44e                	sd	s3,8(sp)
    80004180:	e052                	sd	s4,0(sp)
    80004182:	1800                	addi	s0,sp,48
    80004184:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004186:	05050493          	addi	s1,a0,80
    8000418a:	08050913          	addi	s2,a0,128
    8000418e:	a021                	j	80004196 <itrunc+0x22>
    80004190:	0491                	addi	s1,s1,4
    80004192:	01248d63          	beq	s1,s2,800041ac <itrunc+0x38>
    if(ip->addrs[i]){
    80004196:	408c                	lw	a1,0(s1)
    80004198:	dde5                	beqz	a1,80004190 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000419a:	0009a503          	lw	a0,0(s3)
    8000419e:	00000097          	auipc	ra,0x0
    800041a2:	90a080e7          	jalr	-1782(ra) # 80003aa8 <bfree>
      ip->addrs[i] = 0;
    800041a6:	0004a023          	sw	zero,0(s1)
    800041aa:	b7dd                	j	80004190 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800041ac:	0809a583          	lw	a1,128(s3)
    800041b0:	e185                	bnez	a1,800041d0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800041b2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800041b6:	854e                	mv	a0,s3
    800041b8:	00000097          	auipc	ra,0x0
    800041bc:	de4080e7          	jalr	-540(ra) # 80003f9c <iupdate>
}
    800041c0:	70a2                	ld	ra,40(sp)
    800041c2:	7402                	ld	s0,32(sp)
    800041c4:	64e2                	ld	s1,24(sp)
    800041c6:	6942                	ld	s2,16(sp)
    800041c8:	69a2                	ld	s3,8(sp)
    800041ca:	6a02                	ld	s4,0(sp)
    800041cc:	6145                	addi	sp,sp,48
    800041ce:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800041d0:	0009a503          	lw	a0,0(s3)
    800041d4:	fffff097          	auipc	ra,0xfffff
    800041d8:	68e080e7          	jalr	1678(ra) # 80003862 <bread>
    800041dc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800041de:	05850493          	addi	s1,a0,88
    800041e2:	45850913          	addi	s2,a0,1112
    800041e6:	a021                	j	800041ee <itrunc+0x7a>
    800041e8:	0491                	addi	s1,s1,4
    800041ea:	01248b63          	beq	s1,s2,80004200 <itrunc+0x8c>
      if(a[j])
    800041ee:	408c                	lw	a1,0(s1)
    800041f0:	dde5                	beqz	a1,800041e8 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800041f2:	0009a503          	lw	a0,0(s3)
    800041f6:	00000097          	auipc	ra,0x0
    800041fa:	8b2080e7          	jalr	-1870(ra) # 80003aa8 <bfree>
    800041fe:	b7ed                	j	800041e8 <itrunc+0x74>
    brelse(bp);
    80004200:	8552                	mv	a0,s4
    80004202:	fffff097          	auipc	ra,0xfffff
    80004206:	790080e7          	jalr	1936(ra) # 80003992 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000420a:	0809a583          	lw	a1,128(s3)
    8000420e:	0009a503          	lw	a0,0(s3)
    80004212:	00000097          	auipc	ra,0x0
    80004216:	896080e7          	jalr	-1898(ra) # 80003aa8 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000421a:	0809a023          	sw	zero,128(s3)
    8000421e:	bf51                	j	800041b2 <itrunc+0x3e>

0000000080004220 <iput>:
{
    80004220:	1101                	addi	sp,sp,-32
    80004222:	ec06                	sd	ra,24(sp)
    80004224:	e822                	sd	s0,16(sp)
    80004226:	e426                	sd	s1,8(sp)
    80004228:	e04a                	sd	s2,0(sp)
    8000422a:	1000                	addi	s0,sp,32
    8000422c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000422e:	00029517          	auipc	a0,0x29
    80004232:	f9a50513          	addi	a0,a0,-102 # 8002d1c8 <itable>
    80004236:	ffffd097          	auipc	ra,0xffffd
    8000423a:	98c080e7          	jalr	-1652(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000423e:	4498                	lw	a4,8(s1)
    80004240:	4785                	li	a5,1
    80004242:	02f70363          	beq	a4,a5,80004268 <iput+0x48>
  ip->ref--;
    80004246:	449c                	lw	a5,8(s1)
    80004248:	37fd                	addiw	a5,a5,-1
    8000424a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000424c:	00029517          	auipc	a0,0x29
    80004250:	f7c50513          	addi	a0,a0,-132 # 8002d1c8 <itable>
    80004254:	ffffd097          	auipc	ra,0xffffd
    80004258:	a22080e7          	jalr	-1502(ra) # 80000c76 <release>
}
    8000425c:	60e2                	ld	ra,24(sp)
    8000425e:	6442                	ld	s0,16(sp)
    80004260:	64a2                	ld	s1,8(sp)
    80004262:	6902                	ld	s2,0(sp)
    80004264:	6105                	addi	sp,sp,32
    80004266:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004268:	40bc                	lw	a5,64(s1)
    8000426a:	dff1                	beqz	a5,80004246 <iput+0x26>
    8000426c:	04a49783          	lh	a5,74(s1)
    80004270:	fbf9                	bnez	a5,80004246 <iput+0x26>
    acquiresleep(&ip->lock);
    80004272:	01048913          	addi	s2,s1,16
    80004276:	854a                	mv	a0,s2
    80004278:	00001097          	auipc	ra,0x1
    8000427c:	dce080e7          	jalr	-562(ra) # 80005046 <acquiresleep>
    release(&itable.lock);
    80004280:	00029517          	auipc	a0,0x29
    80004284:	f4850513          	addi	a0,a0,-184 # 8002d1c8 <itable>
    80004288:	ffffd097          	auipc	ra,0xffffd
    8000428c:	9ee080e7          	jalr	-1554(ra) # 80000c76 <release>
    itrunc(ip);
    80004290:	8526                	mv	a0,s1
    80004292:	00000097          	auipc	ra,0x0
    80004296:	ee2080e7          	jalr	-286(ra) # 80004174 <itrunc>
    ip->type = 0;
    8000429a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000429e:	8526                	mv	a0,s1
    800042a0:	00000097          	auipc	ra,0x0
    800042a4:	cfc080e7          	jalr	-772(ra) # 80003f9c <iupdate>
    ip->valid = 0;
    800042a8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800042ac:	854a                	mv	a0,s2
    800042ae:	00001097          	auipc	ra,0x1
    800042b2:	dee080e7          	jalr	-530(ra) # 8000509c <releasesleep>
    acquire(&itable.lock);
    800042b6:	00029517          	auipc	a0,0x29
    800042ba:	f1250513          	addi	a0,a0,-238 # 8002d1c8 <itable>
    800042be:	ffffd097          	auipc	ra,0xffffd
    800042c2:	904080e7          	jalr	-1788(ra) # 80000bc2 <acquire>
    800042c6:	b741                	j	80004246 <iput+0x26>

00000000800042c8 <iunlockput>:
{
    800042c8:	1101                	addi	sp,sp,-32
    800042ca:	ec06                	sd	ra,24(sp)
    800042cc:	e822                	sd	s0,16(sp)
    800042ce:	e426                	sd	s1,8(sp)
    800042d0:	1000                	addi	s0,sp,32
    800042d2:	84aa                	mv	s1,a0
  iunlock(ip);
    800042d4:	00000097          	auipc	ra,0x0
    800042d8:	e54080e7          	jalr	-428(ra) # 80004128 <iunlock>
  iput(ip);
    800042dc:	8526                	mv	a0,s1
    800042de:	00000097          	auipc	ra,0x0
    800042e2:	f42080e7          	jalr	-190(ra) # 80004220 <iput>
}
    800042e6:	60e2                	ld	ra,24(sp)
    800042e8:	6442                	ld	s0,16(sp)
    800042ea:	64a2                	ld	s1,8(sp)
    800042ec:	6105                	addi	sp,sp,32
    800042ee:	8082                	ret

00000000800042f0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800042f0:	1141                	addi	sp,sp,-16
    800042f2:	e422                	sd	s0,8(sp)
    800042f4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800042f6:	411c                	lw	a5,0(a0)
    800042f8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800042fa:	415c                	lw	a5,4(a0)
    800042fc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800042fe:	04451783          	lh	a5,68(a0)
    80004302:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004306:	04a51783          	lh	a5,74(a0)
    8000430a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000430e:	04c56783          	lwu	a5,76(a0)
    80004312:	e99c                	sd	a5,16(a1)
}
    80004314:	6422                	ld	s0,8(sp)
    80004316:	0141                	addi	sp,sp,16
    80004318:	8082                	ret

000000008000431a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000431a:	457c                	lw	a5,76(a0)
    8000431c:	0ed7e963          	bltu	a5,a3,8000440e <readi+0xf4>
{
    80004320:	7159                	addi	sp,sp,-112
    80004322:	f486                	sd	ra,104(sp)
    80004324:	f0a2                	sd	s0,96(sp)
    80004326:	eca6                	sd	s1,88(sp)
    80004328:	e8ca                	sd	s2,80(sp)
    8000432a:	e4ce                	sd	s3,72(sp)
    8000432c:	e0d2                	sd	s4,64(sp)
    8000432e:	fc56                	sd	s5,56(sp)
    80004330:	f85a                	sd	s6,48(sp)
    80004332:	f45e                	sd	s7,40(sp)
    80004334:	f062                	sd	s8,32(sp)
    80004336:	ec66                	sd	s9,24(sp)
    80004338:	e86a                	sd	s10,16(sp)
    8000433a:	e46e                	sd	s11,8(sp)
    8000433c:	1880                	addi	s0,sp,112
    8000433e:	8baa                	mv	s7,a0
    80004340:	8c2e                	mv	s8,a1
    80004342:	8ab2                	mv	s5,a2
    80004344:	84b6                	mv	s1,a3
    80004346:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004348:	9f35                	addw	a4,a4,a3
    return 0;
    8000434a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000434c:	0ad76063          	bltu	a4,a3,800043ec <readi+0xd2>
  if(off + n > ip->size)
    80004350:	00e7f463          	bgeu	a5,a4,80004358 <readi+0x3e>
    n = ip->size - off;
    80004354:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004358:	0a0b0963          	beqz	s6,8000440a <readi+0xf0>
    8000435c:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000435e:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004362:	5cfd                	li	s9,-1
    80004364:	a82d                	j	8000439e <readi+0x84>
    80004366:	020a1d93          	slli	s11,s4,0x20
    8000436a:	020ddd93          	srli	s11,s11,0x20
    8000436e:	05890793          	addi	a5,s2,88
    80004372:	86ee                	mv	a3,s11
    80004374:	963e                	add	a2,a2,a5
    80004376:	85d6                	mv	a1,s5
    80004378:	8562                	mv	a0,s8
    8000437a:	ffffe097          	auipc	ra,0xffffe
    8000437e:	23c080e7          	jalr	572(ra) # 800025b6 <either_copyout>
    80004382:	05950d63          	beq	a0,s9,800043dc <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004386:	854a                	mv	a0,s2
    80004388:	fffff097          	auipc	ra,0xfffff
    8000438c:	60a080e7          	jalr	1546(ra) # 80003992 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004390:	013a09bb          	addw	s3,s4,s3
    80004394:	009a04bb          	addw	s1,s4,s1
    80004398:	9aee                	add	s5,s5,s11
    8000439a:	0569f763          	bgeu	s3,s6,800043e8 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000439e:	000ba903          	lw	s2,0(s7)
    800043a2:	00a4d59b          	srliw	a1,s1,0xa
    800043a6:	855e                	mv	a0,s7
    800043a8:	00000097          	auipc	ra,0x0
    800043ac:	8ae080e7          	jalr	-1874(ra) # 80003c56 <bmap>
    800043b0:	0005059b          	sext.w	a1,a0
    800043b4:	854a                	mv	a0,s2
    800043b6:	fffff097          	auipc	ra,0xfffff
    800043ba:	4ac080e7          	jalr	1196(ra) # 80003862 <bread>
    800043be:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800043c0:	3ff4f613          	andi	a2,s1,1023
    800043c4:	40cd07bb          	subw	a5,s10,a2
    800043c8:	413b073b          	subw	a4,s6,s3
    800043cc:	8a3e                	mv	s4,a5
    800043ce:	2781                	sext.w	a5,a5
    800043d0:	0007069b          	sext.w	a3,a4
    800043d4:	f8f6f9e3          	bgeu	a3,a5,80004366 <readi+0x4c>
    800043d8:	8a3a                	mv	s4,a4
    800043da:	b771                	j	80004366 <readi+0x4c>
      brelse(bp);
    800043dc:	854a                	mv	a0,s2
    800043de:	fffff097          	auipc	ra,0xfffff
    800043e2:	5b4080e7          	jalr	1460(ra) # 80003992 <brelse>
      tot = -1;
    800043e6:	59fd                	li	s3,-1
  }
  return tot;
    800043e8:	0009851b          	sext.w	a0,s3
}
    800043ec:	70a6                	ld	ra,104(sp)
    800043ee:	7406                	ld	s0,96(sp)
    800043f0:	64e6                	ld	s1,88(sp)
    800043f2:	6946                	ld	s2,80(sp)
    800043f4:	69a6                	ld	s3,72(sp)
    800043f6:	6a06                	ld	s4,64(sp)
    800043f8:	7ae2                	ld	s5,56(sp)
    800043fa:	7b42                	ld	s6,48(sp)
    800043fc:	7ba2                	ld	s7,40(sp)
    800043fe:	7c02                	ld	s8,32(sp)
    80004400:	6ce2                	ld	s9,24(sp)
    80004402:	6d42                	ld	s10,16(sp)
    80004404:	6da2                	ld	s11,8(sp)
    80004406:	6165                	addi	sp,sp,112
    80004408:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000440a:	89da                	mv	s3,s6
    8000440c:	bff1                	j	800043e8 <readi+0xce>
    return 0;
    8000440e:	4501                	li	a0,0
}
    80004410:	8082                	ret

0000000080004412 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004412:	457c                	lw	a5,76(a0)
    80004414:	10d7e863          	bltu	a5,a3,80004524 <writei+0x112>
{
    80004418:	7159                	addi	sp,sp,-112
    8000441a:	f486                	sd	ra,104(sp)
    8000441c:	f0a2                	sd	s0,96(sp)
    8000441e:	eca6                	sd	s1,88(sp)
    80004420:	e8ca                	sd	s2,80(sp)
    80004422:	e4ce                	sd	s3,72(sp)
    80004424:	e0d2                	sd	s4,64(sp)
    80004426:	fc56                	sd	s5,56(sp)
    80004428:	f85a                	sd	s6,48(sp)
    8000442a:	f45e                	sd	s7,40(sp)
    8000442c:	f062                	sd	s8,32(sp)
    8000442e:	ec66                	sd	s9,24(sp)
    80004430:	e86a                	sd	s10,16(sp)
    80004432:	e46e                	sd	s11,8(sp)
    80004434:	1880                	addi	s0,sp,112
    80004436:	8b2a                	mv	s6,a0
    80004438:	8c2e                	mv	s8,a1
    8000443a:	8ab2                	mv	s5,a2
    8000443c:	8936                	mv	s2,a3
    8000443e:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004440:	00e687bb          	addw	a5,a3,a4
    80004444:	0ed7e263          	bltu	a5,a3,80004528 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004448:	00043737          	lui	a4,0x43
    8000444c:	0ef76063          	bltu	a4,a5,8000452c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004450:	0c0b8863          	beqz	s7,80004520 <writei+0x10e>
    80004454:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004456:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000445a:	5cfd                	li	s9,-1
    8000445c:	a091                	j	800044a0 <writei+0x8e>
    8000445e:	02099d93          	slli	s11,s3,0x20
    80004462:	020ddd93          	srli	s11,s11,0x20
    80004466:	05848793          	addi	a5,s1,88
    8000446a:	86ee                	mv	a3,s11
    8000446c:	8656                	mv	a2,s5
    8000446e:	85e2                	mv	a1,s8
    80004470:	953e                	add	a0,a0,a5
    80004472:	ffffe097          	auipc	ra,0xffffe
    80004476:	19a080e7          	jalr	410(ra) # 8000260c <either_copyin>
    8000447a:	07950263          	beq	a0,s9,800044de <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000447e:	8526                	mv	a0,s1
    80004480:	00001097          	auipc	ra,0x1
    80004484:	aa6080e7          	jalr	-1370(ra) # 80004f26 <log_write>
    brelse(bp);
    80004488:	8526                	mv	a0,s1
    8000448a:	fffff097          	auipc	ra,0xfffff
    8000448e:	508080e7          	jalr	1288(ra) # 80003992 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004492:	01498a3b          	addw	s4,s3,s4
    80004496:	0129893b          	addw	s2,s3,s2
    8000449a:	9aee                	add	s5,s5,s11
    8000449c:	057a7663          	bgeu	s4,s7,800044e8 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800044a0:	000b2483          	lw	s1,0(s6)
    800044a4:	00a9559b          	srliw	a1,s2,0xa
    800044a8:	855a                	mv	a0,s6
    800044aa:	fffff097          	auipc	ra,0xfffff
    800044ae:	7ac080e7          	jalr	1964(ra) # 80003c56 <bmap>
    800044b2:	0005059b          	sext.w	a1,a0
    800044b6:	8526                	mv	a0,s1
    800044b8:	fffff097          	auipc	ra,0xfffff
    800044bc:	3aa080e7          	jalr	938(ra) # 80003862 <bread>
    800044c0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800044c2:	3ff97513          	andi	a0,s2,1023
    800044c6:	40ad07bb          	subw	a5,s10,a0
    800044ca:	414b873b          	subw	a4,s7,s4
    800044ce:	89be                	mv	s3,a5
    800044d0:	2781                	sext.w	a5,a5
    800044d2:	0007069b          	sext.w	a3,a4
    800044d6:	f8f6f4e3          	bgeu	a3,a5,8000445e <writei+0x4c>
    800044da:	89ba                	mv	s3,a4
    800044dc:	b749                	j	8000445e <writei+0x4c>
      brelse(bp);
    800044de:	8526                	mv	a0,s1
    800044e0:	fffff097          	auipc	ra,0xfffff
    800044e4:	4b2080e7          	jalr	1202(ra) # 80003992 <brelse>
  }

  if(off > ip->size)
    800044e8:	04cb2783          	lw	a5,76(s6)
    800044ec:	0127f463          	bgeu	a5,s2,800044f4 <writei+0xe2>
    ip->size = off;
    800044f0:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800044f4:	855a                	mv	a0,s6
    800044f6:	00000097          	auipc	ra,0x0
    800044fa:	aa6080e7          	jalr	-1370(ra) # 80003f9c <iupdate>

  return tot;
    800044fe:	000a051b          	sext.w	a0,s4
}
    80004502:	70a6                	ld	ra,104(sp)
    80004504:	7406                	ld	s0,96(sp)
    80004506:	64e6                	ld	s1,88(sp)
    80004508:	6946                	ld	s2,80(sp)
    8000450a:	69a6                	ld	s3,72(sp)
    8000450c:	6a06                	ld	s4,64(sp)
    8000450e:	7ae2                	ld	s5,56(sp)
    80004510:	7b42                	ld	s6,48(sp)
    80004512:	7ba2                	ld	s7,40(sp)
    80004514:	7c02                	ld	s8,32(sp)
    80004516:	6ce2                	ld	s9,24(sp)
    80004518:	6d42                	ld	s10,16(sp)
    8000451a:	6da2                	ld	s11,8(sp)
    8000451c:	6165                	addi	sp,sp,112
    8000451e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004520:	8a5e                	mv	s4,s7
    80004522:	bfc9                	j	800044f4 <writei+0xe2>
    return -1;
    80004524:	557d                	li	a0,-1
}
    80004526:	8082                	ret
    return -1;
    80004528:	557d                	li	a0,-1
    8000452a:	bfe1                	j	80004502 <writei+0xf0>
    return -1;
    8000452c:	557d                	li	a0,-1
    8000452e:	bfd1                	j	80004502 <writei+0xf0>

0000000080004530 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004530:	1141                	addi	sp,sp,-16
    80004532:	e406                	sd	ra,8(sp)
    80004534:	e022                	sd	s0,0(sp)
    80004536:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004538:	4639                	li	a2,14
    8000453a:	ffffd097          	auipc	ra,0xffffd
    8000453e:	85c080e7          	jalr	-1956(ra) # 80000d96 <strncmp>
}
    80004542:	60a2                	ld	ra,8(sp)
    80004544:	6402                	ld	s0,0(sp)
    80004546:	0141                	addi	sp,sp,16
    80004548:	8082                	ret

000000008000454a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000454a:	7139                	addi	sp,sp,-64
    8000454c:	fc06                	sd	ra,56(sp)
    8000454e:	f822                	sd	s0,48(sp)
    80004550:	f426                	sd	s1,40(sp)
    80004552:	f04a                	sd	s2,32(sp)
    80004554:	ec4e                	sd	s3,24(sp)
    80004556:	e852                	sd	s4,16(sp)
    80004558:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000455a:	04451703          	lh	a4,68(a0)
    8000455e:	4785                	li	a5,1
    80004560:	00f71a63          	bne	a4,a5,80004574 <dirlookup+0x2a>
    80004564:	892a                	mv	s2,a0
    80004566:	89ae                	mv	s3,a1
    80004568:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000456a:	457c                	lw	a5,76(a0)
    8000456c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000456e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004570:	e79d                	bnez	a5,8000459e <dirlookup+0x54>
    80004572:	a8a5                	j	800045ea <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004574:	00005517          	auipc	a0,0x5
    80004578:	54450513          	addi	a0,a0,1348 # 80009ab8 <syscalls+0x1a0>
    8000457c:	ffffc097          	auipc	ra,0xffffc
    80004580:	fae080e7          	jalr	-82(ra) # 8000052a <panic>
      panic("dirlookup read");
    80004584:	00005517          	auipc	a0,0x5
    80004588:	54c50513          	addi	a0,a0,1356 # 80009ad0 <syscalls+0x1b8>
    8000458c:	ffffc097          	auipc	ra,0xffffc
    80004590:	f9e080e7          	jalr	-98(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004594:	24c1                	addiw	s1,s1,16
    80004596:	04c92783          	lw	a5,76(s2)
    8000459a:	04f4f763          	bgeu	s1,a5,800045e8 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000459e:	4741                	li	a4,16
    800045a0:	86a6                	mv	a3,s1
    800045a2:	fc040613          	addi	a2,s0,-64
    800045a6:	4581                	li	a1,0
    800045a8:	854a                	mv	a0,s2
    800045aa:	00000097          	auipc	ra,0x0
    800045ae:	d70080e7          	jalr	-656(ra) # 8000431a <readi>
    800045b2:	47c1                	li	a5,16
    800045b4:	fcf518e3          	bne	a0,a5,80004584 <dirlookup+0x3a>
    if(de.inum == 0)
    800045b8:	fc045783          	lhu	a5,-64(s0)
    800045bc:	dfe1                	beqz	a5,80004594 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800045be:	fc240593          	addi	a1,s0,-62
    800045c2:	854e                	mv	a0,s3
    800045c4:	00000097          	auipc	ra,0x0
    800045c8:	f6c080e7          	jalr	-148(ra) # 80004530 <namecmp>
    800045cc:	f561                	bnez	a0,80004594 <dirlookup+0x4a>
      if(poff)
    800045ce:	000a0463          	beqz	s4,800045d6 <dirlookup+0x8c>
        *poff = off;
    800045d2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800045d6:	fc045583          	lhu	a1,-64(s0)
    800045da:	00092503          	lw	a0,0(s2)
    800045de:	fffff097          	auipc	ra,0xfffff
    800045e2:	754080e7          	jalr	1876(ra) # 80003d32 <iget>
    800045e6:	a011                	j	800045ea <dirlookup+0xa0>
  return 0;
    800045e8:	4501                	li	a0,0
}
    800045ea:	70e2                	ld	ra,56(sp)
    800045ec:	7442                	ld	s0,48(sp)
    800045ee:	74a2                	ld	s1,40(sp)
    800045f0:	7902                	ld	s2,32(sp)
    800045f2:	69e2                	ld	s3,24(sp)
    800045f4:	6a42                	ld	s4,16(sp)
    800045f6:	6121                	addi	sp,sp,64
    800045f8:	8082                	ret

00000000800045fa <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800045fa:	711d                	addi	sp,sp,-96
    800045fc:	ec86                	sd	ra,88(sp)
    800045fe:	e8a2                	sd	s0,80(sp)
    80004600:	e4a6                	sd	s1,72(sp)
    80004602:	e0ca                	sd	s2,64(sp)
    80004604:	fc4e                	sd	s3,56(sp)
    80004606:	f852                	sd	s4,48(sp)
    80004608:	f456                	sd	s5,40(sp)
    8000460a:	f05a                	sd	s6,32(sp)
    8000460c:	ec5e                	sd	s7,24(sp)
    8000460e:	e862                	sd	s8,16(sp)
    80004610:	e466                	sd	s9,8(sp)
    80004612:	1080                	addi	s0,sp,96
    80004614:	84aa                	mv	s1,a0
    80004616:	8aae                	mv	s5,a1
    80004618:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000461a:	00054703          	lbu	a4,0(a0)
    8000461e:	02f00793          	li	a5,47
    80004622:	02f70363          	beq	a4,a5,80004648 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004626:	ffffd097          	auipc	ra,0xffffd
    8000462a:	6ea080e7          	jalr	1770(ra) # 80001d10 <myproc>
    8000462e:	15053503          	ld	a0,336(a0)
    80004632:	00000097          	auipc	ra,0x0
    80004636:	9f6080e7          	jalr	-1546(ra) # 80004028 <idup>
    8000463a:	89aa                	mv	s3,a0
  while(*path == '/')
    8000463c:	02f00913          	li	s2,47
  len = path - s;
    80004640:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004642:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004644:	4b85                	li	s7,1
    80004646:	a865                	j	800046fe <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004648:	4585                	li	a1,1
    8000464a:	4505                	li	a0,1
    8000464c:	fffff097          	auipc	ra,0xfffff
    80004650:	6e6080e7          	jalr	1766(ra) # 80003d32 <iget>
    80004654:	89aa                	mv	s3,a0
    80004656:	b7dd                	j	8000463c <namex+0x42>
      iunlockput(ip);
    80004658:	854e                	mv	a0,s3
    8000465a:	00000097          	auipc	ra,0x0
    8000465e:	c6e080e7          	jalr	-914(ra) # 800042c8 <iunlockput>
      return 0;
    80004662:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004664:	854e                	mv	a0,s3
    80004666:	60e6                	ld	ra,88(sp)
    80004668:	6446                	ld	s0,80(sp)
    8000466a:	64a6                	ld	s1,72(sp)
    8000466c:	6906                	ld	s2,64(sp)
    8000466e:	79e2                	ld	s3,56(sp)
    80004670:	7a42                	ld	s4,48(sp)
    80004672:	7aa2                	ld	s5,40(sp)
    80004674:	7b02                	ld	s6,32(sp)
    80004676:	6be2                	ld	s7,24(sp)
    80004678:	6c42                	ld	s8,16(sp)
    8000467a:	6ca2                	ld	s9,8(sp)
    8000467c:	6125                	addi	sp,sp,96
    8000467e:	8082                	ret
      iunlock(ip);
    80004680:	854e                	mv	a0,s3
    80004682:	00000097          	auipc	ra,0x0
    80004686:	aa6080e7          	jalr	-1370(ra) # 80004128 <iunlock>
      return ip;
    8000468a:	bfe9                	j	80004664 <namex+0x6a>
      iunlockput(ip);
    8000468c:	854e                	mv	a0,s3
    8000468e:	00000097          	auipc	ra,0x0
    80004692:	c3a080e7          	jalr	-966(ra) # 800042c8 <iunlockput>
      return 0;
    80004696:	89e6                	mv	s3,s9
    80004698:	b7f1                	j	80004664 <namex+0x6a>
  len = path - s;
    8000469a:	40b48633          	sub	a2,s1,a1
    8000469e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800046a2:	099c5463          	bge	s8,s9,8000472a <namex+0x130>
    memmove(name, s, DIRSIZ);
    800046a6:	4639                	li	a2,14
    800046a8:	8552                	mv	a0,s4
    800046aa:	ffffc097          	auipc	ra,0xffffc
    800046ae:	670080e7          	jalr	1648(ra) # 80000d1a <memmove>
  while(*path == '/')
    800046b2:	0004c783          	lbu	a5,0(s1)
    800046b6:	01279763          	bne	a5,s2,800046c4 <namex+0xca>
    path++;
    800046ba:	0485                	addi	s1,s1,1
  while(*path == '/')
    800046bc:	0004c783          	lbu	a5,0(s1)
    800046c0:	ff278de3          	beq	a5,s2,800046ba <namex+0xc0>
    ilock(ip);
    800046c4:	854e                	mv	a0,s3
    800046c6:	00000097          	auipc	ra,0x0
    800046ca:	9a0080e7          	jalr	-1632(ra) # 80004066 <ilock>
    if(ip->type != T_DIR){
    800046ce:	04499783          	lh	a5,68(s3)
    800046d2:	f97793e3          	bne	a5,s7,80004658 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800046d6:	000a8563          	beqz	s5,800046e0 <namex+0xe6>
    800046da:	0004c783          	lbu	a5,0(s1)
    800046de:	d3cd                	beqz	a5,80004680 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800046e0:	865a                	mv	a2,s6
    800046e2:	85d2                	mv	a1,s4
    800046e4:	854e                	mv	a0,s3
    800046e6:	00000097          	auipc	ra,0x0
    800046ea:	e64080e7          	jalr	-412(ra) # 8000454a <dirlookup>
    800046ee:	8caa                	mv	s9,a0
    800046f0:	dd51                	beqz	a0,8000468c <namex+0x92>
    iunlockput(ip);
    800046f2:	854e                	mv	a0,s3
    800046f4:	00000097          	auipc	ra,0x0
    800046f8:	bd4080e7          	jalr	-1068(ra) # 800042c8 <iunlockput>
    ip = next;
    800046fc:	89e6                	mv	s3,s9
  while(*path == '/')
    800046fe:	0004c783          	lbu	a5,0(s1)
    80004702:	05279763          	bne	a5,s2,80004750 <namex+0x156>
    path++;
    80004706:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004708:	0004c783          	lbu	a5,0(s1)
    8000470c:	ff278de3          	beq	a5,s2,80004706 <namex+0x10c>
  if(*path == 0)
    80004710:	c79d                	beqz	a5,8000473e <namex+0x144>
    path++;
    80004712:	85a6                	mv	a1,s1
  len = path - s;
    80004714:	8cda                	mv	s9,s6
    80004716:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004718:	01278963          	beq	a5,s2,8000472a <namex+0x130>
    8000471c:	dfbd                	beqz	a5,8000469a <namex+0xa0>
    path++;
    8000471e:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004720:	0004c783          	lbu	a5,0(s1)
    80004724:	ff279ce3          	bne	a5,s2,8000471c <namex+0x122>
    80004728:	bf8d                	j	8000469a <namex+0xa0>
    memmove(name, s, len);
    8000472a:	2601                	sext.w	a2,a2
    8000472c:	8552                	mv	a0,s4
    8000472e:	ffffc097          	auipc	ra,0xffffc
    80004732:	5ec080e7          	jalr	1516(ra) # 80000d1a <memmove>
    name[len] = 0;
    80004736:	9cd2                	add	s9,s9,s4
    80004738:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000473c:	bf9d                	j	800046b2 <namex+0xb8>
  if(nameiparent){
    8000473e:	f20a83e3          	beqz	s5,80004664 <namex+0x6a>
    iput(ip);
    80004742:	854e                	mv	a0,s3
    80004744:	00000097          	auipc	ra,0x0
    80004748:	adc080e7          	jalr	-1316(ra) # 80004220 <iput>
    return 0;
    8000474c:	4981                	li	s3,0
    8000474e:	bf19                	j	80004664 <namex+0x6a>
  if(*path == 0)
    80004750:	d7fd                	beqz	a5,8000473e <namex+0x144>
  while(*path != '/' && *path != 0)
    80004752:	0004c783          	lbu	a5,0(s1)
    80004756:	85a6                	mv	a1,s1
    80004758:	b7d1                	j	8000471c <namex+0x122>

000000008000475a <dirlink>:
{
    8000475a:	7139                	addi	sp,sp,-64
    8000475c:	fc06                	sd	ra,56(sp)
    8000475e:	f822                	sd	s0,48(sp)
    80004760:	f426                	sd	s1,40(sp)
    80004762:	f04a                	sd	s2,32(sp)
    80004764:	ec4e                	sd	s3,24(sp)
    80004766:	e852                	sd	s4,16(sp)
    80004768:	0080                	addi	s0,sp,64
    8000476a:	892a                	mv	s2,a0
    8000476c:	8a2e                	mv	s4,a1
    8000476e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004770:	4601                	li	a2,0
    80004772:	00000097          	auipc	ra,0x0
    80004776:	dd8080e7          	jalr	-552(ra) # 8000454a <dirlookup>
    8000477a:	e93d                	bnez	a0,800047f0 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000477c:	04c92483          	lw	s1,76(s2)
    80004780:	c49d                	beqz	s1,800047ae <dirlink+0x54>
    80004782:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004784:	4741                	li	a4,16
    80004786:	86a6                	mv	a3,s1
    80004788:	fc040613          	addi	a2,s0,-64
    8000478c:	4581                	li	a1,0
    8000478e:	854a                	mv	a0,s2
    80004790:	00000097          	auipc	ra,0x0
    80004794:	b8a080e7          	jalr	-1142(ra) # 8000431a <readi>
    80004798:	47c1                	li	a5,16
    8000479a:	06f51163          	bne	a0,a5,800047fc <dirlink+0xa2>
    if(de.inum == 0)
    8000479e:	fc045783          	lhu	a5,-64(s0)
    800047a2:	c791                	beqz	a5,800047ae <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800047a4:	24c1                	addiw	s1,s1,16
    800047a6:	04c92783          	lw	a5,76(s2)
    800047aa:	fcf4ede3          	bltu	s1,a5,80004784 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800047ae:	4639                	li	a2,14
    800047b0:	85d2                	mv	a1,s4
    800047b2:	fc240513          	addi	a0,s0,-62
    800047b6:	ffffc097          	auipc	ra,0xffffc
    800047ba:	61c080e7          	jalr	1564(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    800047be:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800047c2:	4741                	li	a4,16
    800047c4:	86a6                	mv	a3,s1
    800047c6:	fc040613          	addi	a2,s0,-64
    800047ca:	4581                	li	a1,0
    800047cc:	854a                	mv	a0,s2
    800047ce:	00000097          	auipc	ra,0x0
    800047d2:	c44080e7          	jalr	-956(ra) # 80004412 <writei>
    800047d6:	872a                	mv	a4,a0
    800047d8:	47c1                	li	a5,16
  return 0;
    800047da:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800047dc:	02f71863          	bne	a4,a5,8000480c <dirlink+0xb2>
}
    800047e0:	70e2                	ld	ra,56(sp)
    800047e2:	7442                	ld	s0,48(sp)
    800047e4:	74a2                	ld	s1,40(sp)
    800047e6:	7902                	ld	s2,32(sp)
    800047e8:	69e2                	ld	s3,24(sp)
    800047ea:	6a42                	ld	s4,16(sp)
    800047ec:	6121                	addi	sp,sp,64
    800047ee:	8082                	ret
    iput(ip);
    800047f0:	00000097          	auipc	ra,0x0
    800047f4:	a30080e7          	jalr	-1488(ra) # 80004220 <iput>
    return -1;
    800047f8:	557d                	li	a0,-1
    800047fa:	b7dd                	j	800047e0 <dirlink+0x86>
      panic("dirlink read");
    800047fc:	00005517          	auipc	a0,0x5
    80004800:	2e450513          	addi	a0,a0,740 # 80009ae0 <syscalls+0x1c8>
    80004804:	ffffc097          	auipc	ra,0xffffc
    80004808:	d26080e7          	jalr	-730(ra) # 8000052a <panic>
    panic("dirlink");
    8000480c:	00005517          	auipc	a0,0x5
    80004810:	45c50513          	addi	a0,a0,1116 # 80009c68 <syscalls+0x350>
    80004814:	ffffc097          	auipc	ra,0xffffc
    80004818:	d16080e7          	jalr	-746(ra) # 8000052a <panic>

000000008000481c <namei>:

struct inode*
namei(char *path)
{
    8000481c:	1101                	addi	sp,sp,-32
    8000481e:	ec06                	sd	ra,24(sp)
    80004820:	e822                	sd	s0,16(sp)
    80004822:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004824:	fe040613          	addi	a2,s0,-32
    80004828:	4581                	li	a1,0
    8000482a:	00000097          	auipc	ra,0x0
    8000482e:	dd0080e7          	jalr	-560(ra) # 800045fa <namex>
}
    80004832:	60e2                	ld	ra,24(sp)
    80004834:	6442                	ld	s0,16(sp)
    80004836:	6105                	addi	sp,sp,32
    80004838:	8082                	ret

000000008000483a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000483a:	1141                	addi	sp,sp,-16
    8000483c:	e406                	sd	ra,8(sp)
    8000483e:	e022                	sd	s0,0(sp)
    80004840:	0800                	addi	s0,sp,16
    80004842:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004844:	4585                	li	a1,1
    80004846:	00000097          	auipc	ra,0x0
    8000484a:	db4080e7          	jalr	-588(ra) # 800045fa <namex>
}
    8000484e:	60a2                	ld	ra,8(sp)
    80004850:	6402                	ld	s0,0(sp)
    80004852:	0141                	addi	sp,sp,16
    80004854:	8082                	ret

0000000080004856 <itoa>:


#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
    80004856:	1101                	addi	sp,sp,-32
    80004858:	ec22                	sd	s0,24(sp)
    8000485a:	1000                	addi	s0,sp,32
    8000485c:	872a                	mv	a4,a0
    8000485e:	852e                	mv	a0,a1
    char const digit[] = "0123456789";
    80004860:	00005797          	auipc	a5,0x5
    80004864:	29078793          	addi	a5,a5,656 # 80009af0 <syscalls+0x1d8>
    80004868:	6394                	ld	a3,0(a5)
    8000486a:	fed43023          	sd	a3,-32(s0)
    8000486e:	0087d683          	lhu	a3,8(a5)
    80004872:	fed41423          	sh	a3,-24(s0)
    80004876:	00a7c783          	lbu	a5,10(a5)
    8000487a:	fef40523          	sb	a5,-22(s0)
    char* p = b;
    8000487e:	87ae                	mv	a5,a1
    if(i<0){
    80004880:	02074b63          	bltz	a4,800048b6 <itoa+0x60>
        *p++ = '-';
        i *= -1;
    }
    int shifter = i;
    80004884:	86ba                	mv	a3,a4
    do{ //Move to where representation ends
        ++p;
        shifter = shifter/10;
    80004886:	4629                	li	a2,10
        ++p;
    80004888:	0785                	addi	a5,a5,1
        shifter = shifter/10;
    8000488a:	02c6c6bb          	divw	a3,a3,a2
    }while(shifter);
    8000488e:	feed                	bnez	a3,80004888 <itoa+0x32>
    *p = '\0';
    80004890:	00078023          	sb	zero,0(a5)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
    80004894:	4629                	li	a2,10
    80004896:	17fd                	addi	a5,a5,-1
    80004898:	02c766bb          	remw	a3,a4,a2
    8000489c:	ff040593          	addi	a1,s0,-16
    800048a0:	96ae                	add	a3,a3,a1
    800048a2:	ff06c683          	lbu	a3,-16(a3)
    800048a6:	00d78023          	sb	a3,0(a5)
        i = i/10;
    800048aa:	02c7473b          	divw	a4,a4,a2
    }while(i);
    800048ae:	f765                	bnez	a4,80004896 <itoa+0x40>
    return b;
}
    800048b0:	6462                	ld	s0,24(sp)
    800048b2:	6105                	addi	sp,sp,32
    800048b4:	8082                	ret
        *p++ = '-';
    800048b6:	00158793          	addi	a5,a1,1
    800048ba:	02d00693          	li	a3,45
    800048be:	00d58023          	sb	a3,0(a1)
        i *= -1;
    800048c2:	40e0073b          	negw	a4,a4
    800048c6:	bf7d                	j	80004884 <itoa+0x2e>

00000000800048c8 <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
    800048c8:	711d                	addi	sp,sp,-96
    800048ca:	ec86                	sd	ra,88(sp)
    800048cc:	e8a2                	sd	s0,80(sp)
    800048ce:	e4a6                	sd	s1,72(sp)
    800048d0:	e0ca                	sd	s2,64(sp)
    800048d2:	1080                	addi	s0,sp,96
    800048d4:	84aa                	mv	s1,a0
  //path of proccess
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    800048d6:	4619                	li	a2,6
    800048d8:	00005597          	auipc	a1,0x5
    800048dc:	22858593          	addi	a1,a1,552 # 80009b00 <syscalls+0x1e8>
    800048e0:	fd040513          	addi	a0,s0,-48
    800048e4:	ffffc097          	auipc	ra,0xffffc
    800048e8:	436080e7          	jalr	1078(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    800048ec:	fd640593          	addi	a1,s0,-42
    800048f0:	5888                	lw	a0,48(s1)
    800048f2:	00000097          	auipc	ra,0x0
    800048f6:	f64080e7          	jalr	-156(ra) # 80004856 <itoa>
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ];
  uint off;

  if(0 == p->swapFile)
    800048fa:	1684b503          	ld	a0,360(s1)
    800048fe:	16050763          	beqz	a0,80004a6c <removeSwapFile+0x1a4>
  {
    return -1;
  }
  fileclose(p->swapFile);
    80004902:	00001097          	auipc	ra,0x1
    80004906:	918080e7          	jalr	-1768(ra) # 8000521a <fileclose>

  begin_op();
    8000490a:	00000097          	auipc	ra,0x0
    8000490e:	444080e7          	jalr	1092(ra) # 80004d4e <begin_op>
  if((dp = nameiparent(path, name)) == 0)
    80004912:	fb040593          	addi	a1,s0,-80
    80004916:	fd040513          	addi	a0,s0,-48
    8000491a:	00000097          	auipc	ra,0x0
    8000491e:	f20080e7          	jalr	-224(ra) # 8000483a <nameiparent>
    80004922:	892a                	mv	s2,a0
    80004924:	cd69                	beqz	a0,800049fe <removeSwapFile+0x136>
  {
    end_op();
    return -1;
  }

  ilock(dp);
    80004926:	fffff097          	auipc	ra,0xfffff
    8000492a:	740080e7          	jalr	1856(ra) # 80004066 <ilock>

    // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000492e:	00005597          	auipc	a1,0x5
    80004932:	1da58593          	addi	a1,a1,474 # 80009b08 <syscalls+0x1f0>
    80004936:	fb040513          	addi	a0,s0,-80
    8000493a:	00000097          	auipc	ra,0x0
    8000493e:	bf6080e7          	jalr	-1034(ra) # 80004530 <namecmp>
    80004942:	c57d                	beqz	a0,80004a30 <removeSwapFile+0x168>
    80004944:	00005597          	auipc	a1,0x5
    80004948:	1cc58593          	addi	a1,a1,460 # 80009b10 <syscalls+0x1f8>
    8000494c:	fb040513          	addi	a0,s0,-80
    80004950:	00000097          	auipc	ra,0x0
    80004954:	be0080e7          	jalr	-1056(ra) # 80004530 <namecmp>
    80004958:	cd61                	beqz	a0,80004a30 <removeSwapFile+0x168>
     goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    8000495a:	fac40613          	addi	a2,s0,-84
    8000495e:	fb040593          	addi	a1,s0,-80
    80004962:	854a                	mv	a0,s2
    80004964:	00000097          	auipc	ra,0x0
    80004968:	be6080e7          	jalr	-1050(ra) # 8000454a <dirlookup>
    8000496c:	84aa                	mv	s1,a0
    8000496e:	c169                	beqz	a0,80004a30 <removeSwapFile+0x168>
    goto bad;
  ilock(ip);
    80004970:	fffff097          	auipc	ra,0xfffff
    80004974:	6f6080e7          	jalr	1782(ra) # 80004066 <ilock>

  if(ip->nlink < 1)
    80004978:	04a49783          	lh	a5,74(s1)
    8000497c:	08f05763          	blez	a5,80004a0a <removeSwapFile+0x142>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004980:	04449703          	lh	a4,68(s1)
    80004984:	4785                	li	a5,1
    80004986:	08f70a63          	beq	a4,a5,80004a1a <removeSwapFile+0x152>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    8000498a:	4641                	li	a2,16
    8000498c:	4581                	li	a1,0
    8000498e:	fc040513          	addi	a0,s0,-64
    80004992:	ffffc097          	auipc	ra,0xffffc
    80004996:	32c080e7          	jalr	812(ra) # 80000cbe <memset>
  if(writei(dp,0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000499a:	4741                	li	a4,16
    8000499c:	fac42683          	lw	a3,-84(s0)
    800049a0:	fc040613          	addi	a2,s0,-64
    800049a4:	4581                	li	a1,0
    800049a6:	854a                	mv	a0,s2
    800049a8:	00000097          	auipc	ra,0x0
    800049ac:	a6a080e7          	jalr	-1430(ra) # 80004412 <writei>
    800049b0:	47c1                	li	a5,16
    800049b2:	08f51a63          	bne	a0,a5,80004a46 <removeSwapFile+0x17e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    800049b6:	04449703          	lh	a4,68(s1)
    800049ba:	4785                	li	a5,1
    800049bc:	08f70d63          	beq	a4,a5,80004a56 <removeSwapFile+0x18e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    800049c0:	854a                	mv	a0,s2
    800049c2:	00000097          	auipc	ra,0x0
    800049c6:	906080e7          	jalr	-1786(ra) # 800042c8 <iunlockput>

  ip->nlink--;
    800049ca:	04a4d783          	lhu	a5,74(s1)
    800049ce:	37fd                	addiw	a5,a5,-1
    800049d0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800049d4:	8526                	mv	a0,s1
    800049d6:	fffff097          	auipc	ra,0xfffff
    800049da:	5c6080e7          	jalr	1478(ra) # 80003f9c <iupdate>
  iunlockput(ip);
    800049de:	8526                	mv	a0,s1
    800049e0:	00000097          	auipc	ra,0x0
    800049e4:	8e8080e7          	jalr	-1816(ra) # 800042c8 <iunlockput>

  end_op();
    800049e8:	00000097          	auipc	ra,0x0
    800049ec:	3e6080e7          	jalr	998(ra) # 80004dce <end_op>

  return 0;
    800049f0:	4501                	li	a0,0
  bad:
    iunlockput(dp);
    end_op();
    return -1;

}
    800049f2:	60e6                	ld	ra,88(sp)
    800049f4:	6446                	ld	s0,80(sp)
    800049f6:	64a6                	ld	s1,72(sp)
    800049f8:	6906                	ld	s2,64(sp)
    800049fa:	6125                	addi	sp,sp,96
    800049fc:	8082                	ret
    end_op();
    800049fe:	00000097          	auipc	ra,0x0
    80004a02:	3d0080e7          	jalr	976(ra) # 80004dce <end_op>
    return -1;
    80004a06:	557d                	li	a0,-1
    80004a08:	b7ed                	j	800049f2 <removeSwapFile+0x12a>
    panic("unlink: nlink < 1");
    80004a0a:	00005517          	auipc	a0,0x5
    80004a0e:	10e50513          	addi	a0,a0,270 # 80009b18 <syscalls+0x200>
    80004a12:	ffffc097          	auipc	ra,0xffffc
    80004a16:	b18080e7          	jalr	-1256(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004a1a:	8526                	mv	a0,s1
    80004a1c:	00001097          	auipc	ra,0x1
    80004a20:	7b4080e7          	jalr	1972(ra) # 800061d0 <isdirempty>
    80004a24:	f13d                	bnez	a0,8000498a <removeSwapFile+0xc2>
    iunlockput(ip);
    80004a26:	8526                	mv	a0,s1
    80004a28:	00000097          	auipc	ra,0x0
    80004a2c:	8a0080e7          	jalr	-1888(ra) # 800042c8 <iunlockput>
    iunlockput(dp);
    80004a30:	854a                	mv	a0,s2
    80004a32:	00000097          	auipc	ra,0x0
    80004a36:	896080e7          	jalr	-1898(ra) # 800042c8 <iunlockput>
    end_op();
    80004a3a:	00000097          	auipc	ra,0x0
    80004a3e:	394080e7          	jalr	916(ra) # 80004dce <end_op>
    return -1;
    80004a42:	557d                	li	a0,-1
    80004a44:	b77d                	j	800049f2 <removeSwapFile+0x12a>
    panic("unlink: writei");
    80004a46:	00005517          	auipc	a0,0x5
    80004a4a:	0ea50513          	addi	a0,a0,234 # 80009b30 <syscalls+0x218>
    80004a4e:	ffffc097          	auipc	ra,0xffffc
    80004a52:	adc080e7          	jalr	-1316(ra) # 8000052a <panic>
    dp->nlink--;
    80004a56:	04a95783          	lhu	a5,74(s2)
    80004a5a:	37fd                	addiw	a5,a5,-1
    80004a5c:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80004a60:	854a                	mv	a0,s2
    80004a62:	fffff097          	auipc	ra,0xfffff
    80004a66:	53a080e7          	jalr	1338(ra) # 80003f9c <iupdate>
    80004a6a:	bf99                	j	800049c0 <removeSwapFile+0xf8>
    return -1;
    80004a6c:	557d                	li	a0,-1
    80004a6e:	b751                	j	800049f2 <removeSwapFile+0x12a>

0000000080004a70 <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
    80004a70:	7179                	addi	sp,sp,-48
    80004a72:	f406                	sd	ra,40(sp)
    80004a74:	f022                	sd	s0,32(sp)
    80004a76:	ec26                	sd	s1,24(sp)
    80004a78:	e84a                	sd	s2,16(sp)
    80004a7a:	1800                	addi	s0,sp,48
    80004a7c:	84aa                	mv	s1,a0
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    80004a7e:	4619                	li	a2,6
    80004a80:	00005597          	auipc	a1,0x5
    80004a84:	08058593          	addi	a1,a1,128 # 80009b00 <syscalls+0x1e8>
    80004a88:	fd040513          	addi	a0,s0,-48
    80004a8c:	ffffc097          	auipc	ra,0xffffc
    80004a90:	28e080e7          	jalr	654(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    80004a94:	fd640593          	addi	a1,s0,-42
    80004a98:	5888                	lw	a0,48(s1)
    80004a9a:	00000097          	auipc	ra,0x0
    80004a9e:	dbc080e7          	jalr	-580(ra) # 80004856 <itoa>

  begin_op();
    80004aa2:	00000097          	auipc	ra,0x0
    80004aa6:	2ac080e7          	jalr	684(ra) # 80004d4e <begin_op>

  struct inode * in = create(path, T_FILE, 0, 0);
    80004aaa:	4681                	li	a3,0
    80004aac:	4601                	li	a2,0
    80004aae:	4589                	li	a1,2
    80004ab0:	fd040513          	addi	a0,s0,-48
    80004ab4:	00002097          	auipc	ra,0x2
    80004ab8:	910080e7          	jalr	-1776(ra) # 800063c4 <create>
    80004abc:	892a                	mv	s2,a0
  iunlock(in);
    80004abe:	fffff097          	auipc	ra,0xfffff
    80004ac2:	66a080e7          	jalr	1642(ra) # 80004128 <iunlock>
  p->swapFile = filealloc();  if (p->swapFile == 0)
    80004ac6:	00000097          	auipc	ra,0x0
    80004aca:	698080e7          	jalr	1688(ra) # 8000515e <filealloc>
    80004ace:	16a4b423          	sd	a0,360(s1)
    80004ad2:	cd1d                	beqz	a0,80004b10 <createSwapFile+0xa0>
    panic("no slot for files on /store");

  p->swapFile->ip = in;
    80004ad4:	01253c23          	sd	s2,24(a0)
  p->swapFile->type = FD_INODE;
    80004ad8:	1684b703          	ld	a4,360(s1)
    80004adc:	4789                	li	a5,2
    80004ade:	c31c                	sw	a5,0(a4)
  p->swapFile->off = 0;
    80004ae0:	1684b703          	ld	a4,360(s1)
    80004ae4:	02072023          	sw	zero,32(a4) # 43020 <_entry-0x7ffbcfe0>
  p->swapFile->readable = O_WRONLY;
    80004ae8:	1684b703          	ld	a4,360(s1)
    80004aec:	4685                	li	a3,1
    80004aee:	00d70423          	sb	a3,8(a4)
  p->swapFile->writable = O_RDWR;
    80004af2:	1684b703          	ld	a4,360(s1)
    80004af6:	00f704a3          	sb	a5,9(a4)
    end_op();
    80004afa:	00000097          	auipc	ra,0x0
    80004afe:	2d4080e7          	jalr	724(ra) # 80004dce <end_op>

    return 0;
}
    80004b02:	4501                	li	a0,0
    80004b04:	70a2                	ld	ra,40(sp)
    80004b06:	7402                	ld	s0,32(sp)
    80004b08:	64e2                	ld	s1,24(sp)
    80004b0a:	6942                	ld	s2,16(sp)
    80004b0c:	6145                	addi	sp,sp,48
    80004b0e:	8082                	ret
    panic("no slot for files on /store");
    80004b10:	00005517          	auipc	a0,0x5
    80004b14:	03050513          	addi	a0,a0,48 # 80009b40 <syscalls+0x228>
    80004b18:	ffffc097          	auipc	ra,0xffffc
    80004b1c:	a12080e7          	jalr	-1518(ra) # 8000052a <panic>

0000000080004b20 <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004b20:	1141                	addi	sp,sp,-16
    80004b22:	e406                	sd	ra,8(sp)
    80004b24:	e022                	sd	s0,0(sp)
    80004b26:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004b28:	16853783          	ld	a5,360(a0)
    80004b2c:	d390                	sw	a2,32(a5)
  return kfilewrite(p->swapFile, (uint64)buffer, size);
    80004b2e:	8636                	mv	a2,a3
    80004b30:	16853503          	ld	a0,360(a0)
    80004b34:	00001097          	auipc	ra,0x1
    80004b38:	ad8080e7          	jalr	-1320(ra) # 8000560c <kfilewrite>
}
    80004b3c:	60a2                	ld	ra,8(sp)
    80004b3e:	6402                	ld	s0,0(sp)
    80004b40:	0141                	addi	sp,sp,16
    80004b42:	8082                	ret

0000000080004b44 <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004b44:	1141                	addi	sp,sp,-16
    80004b46:	e406                	sd	ra,8(sp)
    80004b48:	e022                	sd	s0,0(sp)
    80004b4a:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004b4c:	16853783          	ld	a5,360(a0)
    80004b50:	d390                	sw	a2,32(a5)
  return kfileread(p->swapFile, (uint64)buffer,  size);
    80004b52:	8636                	mv	a2,a3
    80004b54:	16853503          	ld	a0,360(a0)
    80004b58:	00001097          	auipc	ra,0x1
    80004b5c:	9f2080e7          	jalr	-1550(ra) # 8000554a <kfileread>
    80004b60:	60a2                	ld	ra,8(sp)
    80004b62:	6402                	ld	s0,0(sp)
    80004b64:	0141                	addi	sp,sp,16
    80004b66:	8082                	ret

0000000080004b68 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004b68:	1101                	addi	sp,sp,-32
    80004b6a:	ec06                	sd	ra,24(sp)
    80004b6c:	e822                	sd	s0,16(sp)
    80004b6e:	e426                	sd	s1,8(sp)
    80004b70:	e04a                	sd	s2,0(sp)
    80004b72:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004b74:	0002a917          	auipc	s2,0x2a
    80004b78:	0fc90913          	addi	s2,s2,252 # 8002ec70 <log>
    80004b7c:	01892583          	lw	a1,24(s2)
    80004b80:	02892503          	lw	a0,40(s2)
    80004b84:	fffff097          	auipc	ra,0xfffff
    80004b88:	cde080e7          	jalr	-802(ra) # 80003862 <bread>
    80004b8c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004b8e:	02c92683          	lw	a3,44(s2)
    80004b92:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004b94:	02d05863          	blez	a3,80004bc4 <write_head+0x5c>
    80004b98:	0002a797          	auipc	a5,0x2a
    80004b9c:	10878793          	addi	a5,a5,264 # 8002eca0 <log+0x30>
    80004ba0:	05c50713          	addi	a4,a0,92
    80004ba4:	36fd                	addiw	a3,a3,-1
    80004ba6:	02069613          	slli	a2,a3,0x20
    80004baa:	01e65693          	srli	a3,a2,0x1e
    80004bae:	0002a617          	auipc	a2,0x2a
    80004bb2:	0f660613          	addi	a2,a2,246 # 8002eca4 <log+0x34>
    80004bb6:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004bb8:	4390                	lw	a2,0(a5)
    80004bba:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004bbc:	0791                	addi	a5,a5,4
    80004bbe:	0711                	addi	a4,a4,4
    80004bc0:	fed79ce3          	bne	a5,a3,80004bb8 <write_head+0x50>
  }
  bwrite(buf);
    80004bc4:	8526                	mv	a0,s1
    80004bc6:	fffff097          	auipc	ra,0xfffff
    80004bca:	d8e080e7          	jalr	-626(ra) # 80003954 <bwrite>
  brelse(buf);
    80004bce:	8526                	mv	a0,s1
    80004bd0:	fffff097          	auipc	ra,0xfffff
    80004bd4:	dc2080e7          	jalr	-574(ra) # 80003992 <brelse>
}
    80004bd8:	60e2                	ld	ra,24(sp)
    80004bda:	6442                	ld	s0,16(sp)
    80004bdc:	64a2                	ld	s1,8(sp)
    80004bde:	6902                	ld	s2,0(sp)
    80004be0:	6105                	addi	sp,sp,32
    80004be2:	8082                	ret

0000000080004be4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004be4:	0002a797          	auipc	a5,0x2a
    80004be8:	0b87a783          	lw	a5,184(a5) # 8002ec9c <log+0x2c>
    80004bec:	0af05d63          	blez	a5,80004ca6 <install_trans+0xc2>
{
    80004bf0:	7139                	addi	sp,sp,-64
    80004bf2:	fc06                	sd	ra,56(sp)
    80004bf4:	f822                	sd	s0,48(sp)
    80004bf6:	f426                	sd	s1,40(sp)
    80004bf8:	f04a                	sd	s2,32(sp)
    80004bfa:	ec4e                	sd	s3,24(sp)
    80004bfc:	e852                	sd	s4,16(sp)
    80004bfe:	e456                	sd	s5,8(sp)
    80004c00:	e05a                	sd	s6,0(sp)
    80004c02:	0080                	addi	s0,sp,64
    80004c04:	8b2a                	mv	s6,a0
    80004c06:	0002aa97          	auipc	s5,0x2a
    80004c0a:	09aa8a93          	addi	s5,s5,154 # 8002eca0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c0e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004c10:	0002a997          	auipc	s3,0x2a
    80004c14:	06098993          	addi	s3,s3,96 # 8002ec70 <log>
    80004c18:	a00d                	j	80004c3a <install_trans+0x56>
    brelse(lbuf);
    80004c1a:	854a                	mv	a0,s2
    80004c1c:	fffff097          	auipc	ra,0xfffff
    80004c20:	d76080e7          	jalr	-650(ra) # 80003992 <brelse>
    brelse(dbuf);
    80004c24:	8526                	mv	a0,s1
    80004c26:	fffff097          	auipc	ra,0xfffff
    80004c2a:	d6c080e7          	jalr	-660(ra) # 80003992 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c2e:	2a05                	addiw	s4,s4,1
    80004c30:	0a91                	addi	s5,s5,4
    80004c32:	02c9a783          	lw	a5,44(s3)
    80004c36:	04fa5e63          	bge	s4,a5,80004c92 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004c3a:	0189a583          	lw	a1,24(s3)
    80004c3e:	014585bb          	addw	a1,a1,s4
    80004c42:	2585                	addiw	a1,a1,1
    80004c44:	0289a503          	lw	a0,40(s3)
    80004c48:	fffff097          	auipc	ra,0xfffff
    80004c4c:	c1a080e7          	jalr	-998(ra) # 80003862 <bread>
    80004c50:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004c52:	000aa583          	lw	a1,0(s5)
    80004c56:	0289a503          	lw	a0,40(s3)
    80004c5a:	fffff097          	auipc	ra,0xfffff
    80004c5e:	c08080e7          	jalr	-1016(ra) # 80003862 <bread>
    80004c62:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004c64:	40000613          	li	a2,1024
    80004c68:	05890593          	addi	a1,s2,88
    80004c6c:	05850513          	addi	a0,a0,88
    80004c70:	ffffc097          	auipc	ra,0xffffc
    80004c74:	0aa080e7          	jalr	170(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004c78:	8526                	mv	a0,s1
    80004c7a:	fffff097          	auipc	ra,0xfffff
    80004c7e:	cda080e7          	jalr	-806(ra) # 80003954 <bwrite>
    if(recovering == 0)
    80004c82:	f80b1ce3          	bnez	s6,80004c1a <install_trans+0x36>
      bunpin(dbuf);
    80004c86:	8526                	mv	a0,s1
    80004c88:	fffff097          	auipc	ra,0xfffff
    80004c8c:	de4080e7          	jalr	-540(ra) # 80003a6c <bunpin>
    80004c90:	b769                	j	80004c1a <install_trans+0x36>
}
    80004c92:	70e2                	ld	ra,56(sp)
    80004c94:	7442                	ld	s0,48(sp)
    80004c96:	74a2                	ld	s1,40(sp)
    80004c98:	7902                	ld	s2,32(sp)
    80004c9a:	69e2                	ld	s3,24(sp)
    80004c9c:	6a42                	ld	s4,16(sp)
    80004c9e:	6aa2                	ld	s5,8(sp)
    80004ca0:	6b02                	ld	s6,0(sp)
    80004ca2:	6121                	addi	sp,sp,64
    80004ca4:	8082                	ret
    80004ca6:	8082                	ret

0000000080004ca8 <initlog>:
{
    80004ca8:	7179                	addi	sp,sp,-48
    80004caa:	f406                	sd	ra,40(sp)
    80004cac:	f022                	sd	s0,32(sp)
    80004cae:	ec26                	sd	s1,24(sp)
    80004cb0:	e84a                	sd	s2,16(sp)
    80004cb2:	e44e                	sd	s3,8(sp)
    80004cb4:	1800                	addi	s0,sp,48
    80004cb6:	892a                	mv	s2,a0
    80004cb8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004cba:	0002a497          	auipc	s1,0x2a
    80004cbe:	fb648493          	addi	s1,s1,-74 # 8002ec70 <log>
    80004cc2:	00005597          	auipc	a1,0x5
    80004cc6:	e9e58593          	addi	a1,a1,-354 # 80009b60 <syscalls+0x248>
    80004cca:	8526                	mv	a0,s1
    80004ccc:	ffffc097          	auipc	ra,0xffffc
    80004cd0:	e66080e7          	jalr	-410(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004cd4:	0149a583          	lw	a1,20(s3)
    80004cd8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004cda:	0109a783          	lw	a5,16(s3)
    80004cde:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004ce0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004ce4:	854a                	mv	a0,s2
    80004ce6:	fffff097          	auipc	ra,0xfffff
    80004cea:	b7c080e7          	jalr	-1156(ra) # 80003862 <bread>
  log.lh.n = lh->n;
    80004cee:	4d34                	lw	a3,88(a0)
    80004cf0:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004cf2:	02d05663          	blez	a3,80004d1e <initlog+0x76>
    80004cf6:	05c50793          	addi	a5,a0,92
    80004cfa:	0002a717          	auipc	a4,0x2a
    80004cfe:	fa670713          	addi	a4,a4,-90 # 8002eca0 <log+0x30>
    80004d02:	36fd                	addiw	a3,a3,-1
    80004d04:	02069613          	slli	a2,a3,0x20
    80004d08:	01e65693          	srli	a3,a2,0x1e
    80004d0c:	06050613          	addi	a2,a0,96
    80004d10:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004d12:	4390                	lw	a2,0(a5)
    80004d14:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004d16:	0791                	addi	a5,a5,4
    80004d18:	0711                	addi	a4,a4,4
    80004d1a:	fed79ce3          	bne	a5,a3,80004d12 <initlog+0x6a>
  brelse(buf);
    80004d1e:	fffff097          	auipc	ra,0xfffff
    80004d22:	c74080e7          	jalr	-908(ra) # 80003992 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004d26:	4505                	li	a0,1
    80004d28:	00000097          	auipc	ra,0x0
    80004d2c:	ebc080e7          	jalr	-324(ra) # 80004be4 <install_trans>
  log.lh.n = 0;
    80004d30:	0002a797          	auipc	a5,0x2a
    80004d34:	f607a623          	sw	zero,-148(a5) # 8002ec9c <log+0x2c>
  write_head(); // clear the log
    80004d38:	00000097          	auipc	ra,0x0
    80004d3c:	e30080e7          	jalr	-464(ra) # 80004b68 <write_head>
}
    80004d40:	70a2                	ld	ra,40(sp)
    80004d42:	7402                	ld	s0,32(sp)
    80004d44:	64e2                	ld	s1,24(sp)
    80004d46:	6942                	ld	s2,16(sp)
    80004d48:	69a2                	ld	s3,8(sp)
    80004d4a:	6145                	addi	sp,sp,48
    80004d4c:	8082                	ret

0000000080004d4e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004d4e:	1101                	addi	sp,sp,-32
    80004d50:	ec06                	sd	ra,24(sp)
    80004d52:	e822                	sd	s0,16(sp)
    80004d54:	e426                	sd	s1,8(sp)
    80004d56:	e04a                	sd	s2,0(sp)
    80004d58:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004d5a:	0002a517          	auipc	a0,0x2a
    80004d5e:	f1650513          	addi	a0,a0,-234 # 8002ec70 <log>
    80004d62:	ffffc097          	auipc	ra,0xffffc
    80004d66:	e60080e7          	jalr	-416(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    80004d6a:	0002a497          	auipc	s1,0x2a
    80004d6e:	f0648493          	addi	s1,s1,-250 # 8002ec70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004d72:	4979                	li	s2,30
    80004d74:	a039                	j	80004d82 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004d76:	85a6                	mv	a1,s1
    80004d78:	8526                	mv	a0,s1
    80004d7a:	ffffd097          	auipc	ra,0xffffd
    80004d7e:	48e080e7          	jalr	1166(ra) # 80002208 <sleep>
    if(log.committing){
    80004d82:	50dc                	lw	a5,36(s1)
    80004d84:	fbed                	bnez	a5,80004d76 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004d86:	509c                	lw	a5,32(s1)
    80004d88:	0017871b          	addiw	a4,a5,1
    80004d8c:	0007069b          	sext.w	a3,a4
    80004d90:	0027179b          	slliw	a5,a4,0x2
    80004d94:	9fb9                	addw	a5,a5,a4
    80004d96:	0017979b          	slliw	a5,a5,0x1
    80004d9a:	54d8                	lw	a4,44(s1)
    80004d9c:	9fb9                	addw	a5,a5,a4
    80004d9e:	00f95963          	bge	s2,a5,80004db0 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004da2:	85a6                	mv	a1,s1
    80004da4:	8526                	mv	a0,s1
    80004da6:	ffffd097          	auipc	ra,0xffffd
    80004daa:	462080e7          	jalr	1122(ra) # 80002208 <sleep>
    80004dae:	bfd1                	j	80004d82 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004db0:	0002a517          	auipc	a0,0x2a
    80004db4:	ec050513          	addi	a0,a0,-320 # 8002ec70 <log>
    80004db8:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004dba:	ffffc097          	auipc	ra,0xffffc
    80004dbe:	ebc080e7          	jalr	-324(ra) # 80000c76 <release>
      break;
    }
  }
}
    80004dc2:	60e2                	ld	ra,24(sp)
    80004dc4:	6442                	ld	s0,16(sp)
    80004dc6:	64a2                	ld	s1,8(sp)
    80004dc8:	6902                	ld	s2,0(sp)
    80004dca:	6105                	addi	sp,sp,32
    80004dcc:	8082                	ret

0000000080004dce <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004dce:	7139                	addi	sp,sp,-64
    80004dd0:	fc06                	sd	ra,56(sp)
    80004dd2:	f822                	sd	s0,48(sp)
    80004dd4:	f426                	sd	s1,40(sp)
    80004dd6:	f04a                	sd	s2,32(sp)
    80004dd8:	ec4e                	sd	s3,24(sp)
    80004dda:	e852                	sd	s4,16(sp)
    80004ddc:	e456                	sd	s5,8(sp)
    80004dde:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004de0:	0002a497          	auipc	s1,0x2a
    80004de4:	e9048493          	addi	s1,s1,-368 # 8002ec70 <log>
    80004de8:	8526                	mv	a0,s1
    80004dea:	ffffc097          	auipc	ra,0xffffc
    80004dee:	dd8080e7          	jalr	-552(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004df2:	509c                	lw	a5,32(s1)
    80004df4:	37fd                	addiw	a5,a5,-1
    80004df6:	0007891b          	sext.w	s2,a5
    80004dfa:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004dfc:	50dc                	lw	a5,36(s1)
    80004dfe:	e7b9                	bnez	a5,80004e4c <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004e00:	04091e63          	bnez	s2,80004e5c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004e04:	0002a497          	auipc	s1,0x2a
    80004e08:	e6c48493          	addi	s1,s1,-404 # 8002ec70 <log>
    80004e0c:	4785                	li	a5,1
    80004e0e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004e10:	8526                	mv	a0,s1
    80004e12:	ffffc097          	auipc	ra,0xffffc
    80004e16:	e64080e7          	jalr	-412(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004e1a:	54dc                	lw	a5,44(s1)
    80004e1c:	06f04763          	bgtz	a5,80004e8a <end_op+0xbc>
    acquire(&log.lock);
    80004e20:	0002a497          	auipc	s1,0x2a
    80004e24:	e5048493          	addi	s1,s1,-432 # 8002ec70 <log>
    80004e28:	8526                	mv	a0,s1
    80004e2a:	ffffc097          	auipc	ra,0xffffc
    80004e2e:	d98080e7          	jalr	-616(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004e32:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004e36:	8526                	mv	a0,s1
    80004e38:	ffffd097          	auipc	ra,0xffffd
    80004e3c:	55c080e7          	jalr	1372(ra) # 80002394 <wakeup>
    release(&log.lock);
    80004e40:	8526                	mv	a0,s1
    80004e42:	ffffc097          	auipc	ra,0xffffc
    80004e46:	e34080e7          	jalr	-460(ra) # 80000c76 <release>
}
    80004e4a:	a03d                	j	80004e78 <end_op+0xaa>
    panic("log.committing");
    80004e4c:	00005517          	auipc	a0,0x5
    80004e50:	d1c50513          	addi	a0,a0,-740 # 80009b68 <syscalls+0x250>
    80004e54:	ffffb097          	auipc	ra,0xffffb
    80004e58:	6d6080e7          	jalr	1750(ra) # 8000052a <panic>
    wakeup(&log);
    80004e5c:	0002a497          	auipc	s1,0x2a
    80004e60:	e1448493          	addi	s1,s1,-492 # 8002ec70 <log>
    80004e64:	8526                	mv	a0,s1
    80004e66:	ffffd097          	auipc	ra,0xffffd
    80004e6a:	52e080e7          	jalr	1326(ra) # 80002394 <wakeup>
  release(&log.lock);
    80004e6e:	8526                	mv	a0,s1
    80004e70:	ffffc097          	auipc	ra,0xffffc
    80004e74:	e06080e7          	jalr	-506(ra) # 80000c76 <release>
}
    80004e78:	70e2                	ld	ra,56(sp)
    80004e7a:	7442                	ld	s0,48(sp)
    80004e7c:	74a2                	ld	s1,40(sp)
    80004e7e:	7902                	ld	s2,32(sp)
    80004e80:	69e2                	ld	s3,24(sp)
    80004e82:	6a42                	ld	s4,16(sp)
    80004e84:	6aa2                	ld	s5,8(sp)
    80004e86:	6121                	addi	sp,sp,64
    80004e88:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004e8a:	0002aa97          	auipc	s5,0x2a
    80004e8e:	e16a8a93          	addi	s5,s5,-490 # 8002eca0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004e92:	0002aa17          	auipc	s4,0x2a
    80004e96:	ddea0a13          	addi	s4,s4,-546 # 8002ec70 <log>
    80004e9a:	018a2583          	lw	a1,24(s4)
    80004e9e:	012585bb          	addw	a1,a1,s2
    80004ea2:	2585                	addiw	a1,a1,1
    80004ea4:	028a2503          	lw	a0,40(s4)
    80004ea8:	fffff097          	auipc	ra,0xfffff
    80004eac:	9ba080e7          	jalr	-1606(ra) # 80003862 <bread>
    80004eb0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004eb2:	000aa583          	lw	a1,0(s5)
    80004eb6:	028a2503          	lw	a0,40(s4)
    80004eba:	fffff097          	auipc	ra,0xfffff
    80004ebe:	9a8080e7          	jalr	-1624(ra) # 80003862 <bread>
    80004ec2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004ec4:	40000613          	li	a2,1024
    80004ec8:	05850593          	addi	a1,a0,88
    80004ecc:	05848513          	addi	a0,s1,88
    80004ed0:	ffffc097          	auipc	ra,0xffffc
    80004ed4:	e4a080e7          	jalr	-438(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004ed8:	8526                	mv	a0,s1
    80004eda:	fffff097          	auipc	ra,0xfffff
    80004ede:	a7a080e7          	jalr	-1414(ra) # 80003954 <bwrite>
    brelse(from);
    80004ee2:	854e                	mv	a0,s3
    80004ee4:	fffff097          	auipc	ra,0xfffff
    80004ee8:	aae080e7          	jalr	-1362(ra) # 80003992 <brelse>
    brelse(to);
    80004eec:	8526                	mv	a0,s1
    80004eee:	fffff097          	auipc	ra,0xfffff
    80004ef2:	aa4080e7          	jalr	-1372(ra) # 80003992 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004ef6:	2905                	addiw	s2,s2,1
    80004ef8:	0a91                	addi	s5,s5,4
    80004efa:	02ca2783          	lw	a5,44(s4)
    80004efe:	f8f94ee3          	blt	s2,a5,80004e9a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004f02:	00000097          	auipc	ra,0x0
    80004f06:	c66080e7          	jalr	-922(ra) # 80004b68 <write_head>
    install_trans(0); // Now install writes to home locations
    80004f0a:	4501                	li	a0,0
    80004f0c:	00000097          	auipc	ra,0x0
    80004f10:	cd8080e7          	jalr	-808(ra) # 80004be4 <install_trans>
    log.lh.n = 0;
    80004f14:	0002a797          	auipc	a5,0x2a
    80004f18:	d807a423          	sw	zero,-632(a5) # 8002ec9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004f1c:	00000097          	auipc	ra,0x0
    80004f20:	c4c080e7          	jalr	-948(ra) # 80004b68 <write_head>
    80004f24:	bdf5                	j	80004e20 <end_op+0x52>

0000000080004f26 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004f26:	1101                	addi	sp,sp,-32
    80004f28:	ec06                	sd	ra,24(sp)
    80004f2a:	e822                	sd	s0,16(sp)
    80004f2c:	e426                	sd	s1,8(sp)
    80004f2e:	e04a                	sd	s2,0(sp)
    80004f30:	1000                	addi	s0,sp,32
    80004f32:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004f34:	0002a917          	auipc	s2,0x2a
    80004f38:	d3c90913          	addi	s2,s2,-708 # 8002ec70 <log>
    80004f3c:	854a                	mv	a0,s2
    80004f3e:	ffffc097          	auipc	ra,0xffffc
    80004f42:	c84080e7          	jalr	-892(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004f46:	02c92603          	lw	a2,44(s2)
    80004f4a:	47f5                	li	a5,29
    80004f4c:	06c7c563          	blt	a5,a2,80004fb6 <log_write+0x90>
    80004f50:	0002a797          	auipc	a5,0x2a
    80004f54:	d3c7a783          	lw	a5,-708(a5) # 8002ec8c <log+0x1c>
    80004f58:	37fd                	addiw	a5,a5,-1
    80004f5a:	04f65e63          	bge	a2,a5,80004fb6 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004f5e:	0002a797          	auipc	a5,0x2a
    80004f62:	d327a783          	lw	a5,-718(a5) # 8002ec90 <log+0x20>
    80004f66:	06f05063          	blez	a5,80004fc6 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004f6a:	4781                	li	a5,0
    80004f6c:	06c05563          	blez	a2,80004fd6 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004f70:	44cc                	lw	a1,12(s1)
    80004f72:	0002a717          	auipc	a4,0x2a
    80004f76:	d2e70713          	addi	a4,a4,-722 # 8002eca0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004f7a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004f7c:	4314                	lw	a3,0(a4)
    80004f7e:	04b68c63          	beq	a3,a1,80004fd6 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004f82:	2785                	addiw	a5,a5,1
    80004f84:	0711                	addi	a4,a4,4
    80004f86:	fef61be3          	bne	a2,a5,80004f7c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004f8a:	0621                	addi	a2,a2,8
    80004f8c:	060a                	slli	a2,a2,0x2
    80004f8e:	0002a797          	auipc	a5,0x2a
    80004f92:	ce278793          	addi	a5,a5,-798 # 8002ec70 <log>
    80004f96:	963e                	add	a2,a2,a5
    80004f98:	44dc                	lw	a5,12(s1)
    80004f9a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004f9c:	8526                	mv	a0,s1
    80004f9e:	fffff097          	auipc	ra,0xfffff
    80004fa2:	a92080e7          	jalr	-1390(ra) # 80003a30 <bpin>
    log.lh.n++;
    80004fa6:	0002a717          	auipc	a4,0x2a
    80004faa:	cca70713          	addi	a4,a4,-822 # 8002ec70 <log>
    80004fae:	575c                	lw	a5,44(a4)
    80004fb0:	2785                	addiw	a5,a5,1
    80004fb2:	d75c                	sw	a5,44(a4)
    80004fb4:	a835                	j	80004ff0 <log_write+0xca>
    panic("too big a transaction");
    80004fb6:	00005517          	auipc	a0,0x5
    80004fba:	bc250513          	addi	a0,a0,-1086 # 80009b78 <syscalls+0x260>
    80004fbe:	ffffb097          	auipc	ra,0xffffb
    80004fc2:	56c080e7          	jalr	1388(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004fc6:	00005517          	auipc	a0,0x5
    80004fca:	bca50513          	addi	a0,a0,-1078 # 80009b90 <syscalls+0x278>
    80004fce:	ffffb097          	auipc	ra,0xffffb
    80004fd2:	55c080e7          	jalr	1372(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004fd6:	00878713          	addi	a4,a5,8
    80004fda:	00271693          	slli	a3,a4,0x2
    80004fde:	0002a717          	auipc	a4,0x2a
    80004fe2:	c9270713          	addi	a4,a4,-878 # 8002ec70 <log>
    80004fe6:	9736                	add	a4,a4,a3
    80004fe8:	44d4                	lw	a3,12(s1)
    80004fea:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004fec:	faf608e3          	beq	a2,a5,80004f9c <log_write+0x76>
  }
  release(&log.lock);
    80004ff0:	0002a517          	auipc	a0,0x2a
    80004ff4:	c8050513          	addi	a0,a0,-896 # 8002ec70 <log>
    80004ff8:	ffffc097          	auipc	ra,0xffffc
    80004ffc:	c7e080e7          	jalr	-898(ra) # 80000c76 <release>
}
    80005000:	60e2                	ld	ra,24(sp)
    80005002:	6442                	ld	s0,16(sp)
    80005004:	64a2                	ld	s1,8(sp)
    80005006:	6902                	ld	s2,0(sp)
    80005008:	6105                	addi	sp,sp,32
    8000500a:	8082                	ret

000000008000500c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000500c:	1101                	addi	sp,sp,-32
    8000500e:	ec06                	sd	ra,24(sp)
    80005010:	e822                	sd	s0,16(sp)
    80005012:	e426                	sd	s1,8(sp)
    80005014:	e04a                	sd	s2,0(sp)
    80005016:	1000                	addi	s0,sp,32
    80005018:	84aa                	mv	s1,a0
    8000501a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000501c:	00005597          	auipc	a1,0x5
    80005020:	b9458593          	addi	a1,a1,-1132 # 80009bb0 <syscalls+0x298>
    80005024:	0521                	addi	a0,a0,8
    80005026:	ffffc097          	auipc	ra,0xffffc
    8000502a:	b0c080e7          	jalr	-1268(ra) # 80000b32 <initlock>
  lk->name = name;
    8000502e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80005032:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005036:	0204a423          	sw	zero,40(s1)
}
    8000503a:	60e2                	ld	ra,24(sp)
    8000503c:	6442                	ld	s0,16(sp)
    8000503e:	64a2                	ld	s1,8(sp)
    80005040:	6902                	ld	s2,0(sp)
    80005042:	6105                	addi	sp,sp,32
    80005044:	8082                	ret

0000000080005046 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80005046:	1101                	addi	sp,sp,-32
    80005048:	ec06                	sd	ra,24(sp)
    8000504a:	e822                	sd	s0,16(sp)
    8000504c:	e426                	sd	s1,8(sp)
    8000504e:	e04a                	sd	s2,0(sp)
    80005050:	1000                	addi	s0,sp,32
    80005052:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005054:	00850913          	addi	s2,a0,8
    80005058:	854a                	mv	a0,s2
    8000505a:	ffffc097          	auipc	ra,0xffffc
    8000505e:	b68080e7          	jalr	-1176(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    80005062:	409c                	lw	a5,0(s1)
    80005064:	cb89                	beqz	a5,80005076 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80005066:	85ca                	mv	a1,s2
    80005068:	8526                	mv	a0,s1
    8000506a:	ffffd097          	auipc	ra,0xffffd
    8000506e:	19e080e7          	jalr	414(ra) # 80002208 <sleep>
  while (lk->locked) {
    80005072:	409c                	lw	a5,0(s1)
    80005074:	fbed                	bnez	a5,80005066 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80005076:	4785                	li	a5,1
    80005078:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000507a:	ffffd097          	auipc	ra,0xffffd
    8000507e:	c96080e7          	jalr	-874(ra) # 80001d10 <myproc>
    80005082:	591c                	lw	a5,48(a0)
    80005084:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005086:	854a                	mv	a0,s2
    80005088:	ffffc097          	auipc	ra,0xffffc
    8000508c:	bee080e7          	jalr	-1042(ra) # 80000c76 <release>
}
    80005090:	60e2                	ld	ra,24(sp)
    80005092:	6442                	ld	s0,16(sp)
    80005094:	64a2                	ld	s1,8(sp)
    80005096:	6902                	ld	s2,0(sp)
    80005098:	6105                	addi	sp,sp,32
    8000509a:	8082                	ret

000000008000509c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000509c:	1101                	addi	sp,sp,-32
    8000509e:	ec06                	sd	ra,24(sp)
    800050a0:	e822                	sd	s0,16(sp)
    800050a2:	e426                	sd	s1,8(sp)
    800050a4:	e04a                	sd	s2,0(sp)
    800050a6:	1000                	addi	s0,sp,32
    800050a8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800050aa:	00850913          	addi	s2,a0,8
    800050ae:	854a                	mv	a0,s2
    800050b0:	ffffc097          	auipc	ra,0xffffc
    800050b4:	b12080e7          	jalr	-1262(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    800050b8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800050bc:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800050c0:	8526                	mv	a0,s1
    800050c2:	ffffd097          	auipc	ra,0xffffd
    800050c6:	2d2080e7          	jalr	722(ra) # 80002394 <wakeup>
  release(&lk->lk);
    800050ca:	854a                	mv	a0,s2
    800050cc:	ffffc097          	auipc	ra,0xffffc
    800050d0:	baa080e7          	jalr	-1110(ra) # 80000c76 <release>
}
    800050d4:	60e2                	ld	ra,24(sp)
    800050d6:	6442                	ld	s0,16(sp)
    800050d8:	64a2                	ld	s1,8(sp)
    800050da:	6902                	ld	s2,0(sp)
    800050dc:	6105                	addi	sp,sp,32
    800050de:	8082                	ret

00000000800050e0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800050e0:	7179                	addi	sp,sp,-48
    800050e2:	f406                	sd	ra,40(sp)
    800050e4:	f022                	sd	s0,32(sp)
    800050e6:	ec26                	sd	s1,24(sp)
    800050e8:	e84a                	sd	s2,16(sp)
    800050ea:	e44e                	sd	s3,8(sp)
    800050ec:	1800                	addi	s0,sp,48
    800050ee:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800050f0:	00850913          	addi	s2,a0,8
    800050f4:	854a                	mv	a0,s2
    800050f6:	ffffc097          	auipc	ra,0xffffc
    800050fa:	acc080e7          	jalr	-1332(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800050fe:	409c                	lw	a5,0(s1)
    80005100:	ef99                	bnez	a5,8000511e <holdingsleep+0x3e>
    80005102:	4481                	li	s1,0
  release(&lk->lk);
    80005104:	854a                	mv	a0,s2
    80005106:	ffffc097          	auipc	ra,0xffffc
    8000510a:	b70080e7          	jalr	-1168(ra) # 80000c76 <release>
  return r;
}
    8000510e:	8526                	mv	a0,s1
    80005110:	70a2                	ld	ra,40(sp)
    80005112:	7402                	ld	s0,32(sp)
    80005114:	64e2                	ld	s1,24(sp)
    80005116:	6942                	ld	s2,16(sp)
    80005118:	69a2                	ld	s3,8(sp)
    8000511a:	6145                	addi	sp,sp,48
    8000511c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000511e:	0284a983          	lw	s3,40(s1)
    80005122:	ffffd097          	auipc	ra,0xffffd
    80005126:	bee080e7          	jalr	-1042(ra) # 80001d10 <myproc>
    8000512a:	5904                	lw	s1,48(a0)
    8000512c:	413484b3          	sub	s1,s1,s3
    80005130:	0014b493          	seqz	s1,s1
    80005134:	bfc1                	j	80005104 <holdingsleep+0x24>

0000000080005136 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80005136:	1141                	addi	sp,sp,-16
    80005138:	e406                	sd	ra,8(sp)
    8000513a:	e022                	sd	s0,0(sp)
    8000513c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000513e:	00005597          	auipc	a1,0x5
    80005142:	a8258593          	addi	a1,a1,-1406 # 80009bc0 <syscalls+0x2a8>
    80005146:	0002a517          	auipc	a0,0x2a
    8000514a:	c7250513          	addi	a0,a0,-910 # 8002edb8 <ftable>
    8000514e:	ffffc097          	auipc	ra,0xffffc
    80005152:	9e4080e7          	jalr	-1564(ra) # 80000b32 <initlock>
}
    80005156:	60a2                	ld	ra,8(sp)
    80005158:	6402                	ld	s0,0(sp)
    8000515a:	0141                	addi	sp,sp,16
    8000515c:	8082                	ret

000000008000515e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000515e:	1101                	addi	sp,sp,-32
    80005160:	ec06                	sd	ra,24(sp)
    80005162:	e822                	sd	s0,16(sp)
    80005164:	e426                	sd	s1,8(sp)
    80005166:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80005168:	0002a517          	auipc	a0,0x2a
    8000516c:	c5050513          	addi	a0,a0,-944 # 8002edb8 <ftable>
    80005170:	ffffc097          	auipc	ra,0xffffc
    80005174:	a52080e7          	jalr	-1454(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005178:	0002a497          	auipc	s1,0x2a
    8000517c:	c5848493          	addi	s1,s1,-936 # 8002edd0 <ftable+0x18>
    80005180:	0002b717          	auipc	a4,0x2b
    80005184:	bf070713          	addi	a4,a4,-1040 # 8002fd70 <ftable+0xfb8>
    if(f->ref == 0){
    80005188:	40dc                	lw	a5,4(s1)
    8000518a:	cf99                	beqz	a5,800051a8 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000518c:	02848493          	addi	s1,s1,40
    80005190:	fee49ce3          	bne	s1,a4,80005188 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005194:	0002a517          	auipc	a0,0x2a
    80005198:	c2450513          	addi	a0,a0,-988 # 8002edb8 <ftable>
    8000519c:	ffffc097          	auipc	ra,0xffffc
    800051a0:	ada080e7          	jalr	-1318(ra) # 80000c76 <release>
  return 0;
    800051a4:	4481                	li	s1,0
    800051a6:	a819                	j	800051bc <filealloc+0x5e>
      f->ref = 1;
    800051a8:	4785                	li	a5,1
    800051aa:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800051ac:	0002a517          	auipc	a0,0x2a
    800051b0:	c0c50513          	addi	a0,a0,-1012 # 8002edb8 <ftable>
    800051b4:	ffffc097          	auipc	ra,0xffffc
    800051b8:	ac2080e7          	jalr	-1342(ra) # 80000c76 <release>
}
    800051bc:	8526                	mv	a0,s1
    800051be:	60e2                	ld	ra,24(sp)
    800051c0:	6442                	ld	s0,16(sp)
    800051c2:	64a2                	ld	s1,8(sp)
    800051c4:	6105                	addi	sp,sp,32
    800051c6:	8082                	ret

00000000800051c8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800051c8:	1101                	addi	sp,sp,-32
    800051ca:	ec06                	sd	ra,24(sp)
    800051cc:	e822                	sd	s0,16(sp)
    800051ce:	e426                	sd	s1,8(sp)
    800051d0:	1000                	addi	s0,sp,32
    800051d2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800051d4:	0002a517          	auipc	a0,0x2a
    800051d8:	be450513          	addi	a0,a0,-1052 # 8002edb8 <ftable>
    800051dc:	ffffc097          	auipc	ra,0xffffc
    800051e0:	9e6080e7          	jalr	-1562(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    800051e4:	40dc                	lw	a5,4(s1)
    800051e6:	02f05263          	blez	a5,8000520a <filedup+0x42>
    panic("filedup");
  f->ref++;
    800051ea:	2785                	addiw	a5,a5,1
    800051ec:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800051ee:	0002a517          	auipc	a0,0x2a
    800051f2:	bca50513          	addi	a0,a0,-1078 # 8002edb8 <ftable>
    800051f6:	ffffc097          	auipc	ra,0xffffc
    800051fa:	a80080e7          	jalr	-1408(ra) # 80000c76 <release>
  return f;
}
    800051fe:	8526                	mv	a0,s1
    80005200:	60e2                	ld	ra,24(sp)
    80005202:	6442                	ld	s0,16(sp)
    80005204:	64a2                	ld	s1,8(sp)
    80005206:	6105                	addi	sp,sp,32
    80005208:	8082                	ret
    panic("filedup");
    8000520a:	00005517          	auipc	a0,0x5
    8000520e:	9be50513          	addi	a0,a0,-1602 # 80009bc8 <syscalls+0x2b0>
    80005212:	ffffb097          	auipc	ra,0xffffb
    80005216:	318080e7          	jalr	792(ra) # 8000052a <panic>

000000008000521a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000521a:	7139                	addi	sp,sp,-64
    8000521c:	fc06                	sd	ra,56(sp)
    8000521e:	f822                	sd	s0,48(sp)
    80005220:	f426                	sd	s1,40(sp)
    80005222:	f04a                	sd	s2,32(sp)
    80005224:	ec4e                	sd	s3,24(sp)
    80005226:	e852                	sd	s4,16(sp)
    80005228:	e456                	sd	s5,8(sp)
    8000522a:	0080                	addi	s0,sp,64
    8000522c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000522e:	0002a517          	auipc	a0,0x2a
    80005232:	b8a50513          	addi	a0,a0,-1142 # 8002edb8 <ftable>
    80005236:	ffffc097          	auipc	ra,0xffffc
    8000523a:	98c080e7          	jalr	-1652(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    8000523e:	40dc                	lw	a5,4(s1)
    80005240:	06f05163          	blez	a5,800052a2 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80005244:	37fd                	addiw	a5,a5,-1
    80005246:	0007871b          	sext.w	a4,a5
    8000524a:	c0dc                	sw	a5,4(s1)
    8000524c:	06e04363          	bgtz	a4,800052b2 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80005250:	0004a903          	lw	s2,0(s1)
    80005254:	0094ca83          	lbu	s5,9(s1)
    80005258:	0104ba03          	ld	s4,16(s1)
    8000525c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80005260:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005264:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005268:	0002a517          	auipc	a0,0x2a
    8000526c:	b5050513          	addi	a0,a0,-1200 # 8002edb8 <ftable>
    80005270:	ffffc097          	auipc	ra,0xffffc
    80005274:	a06080e7          	jalr	-1530(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    80005278:	4785                	li	a5,1
    8000527a:	04f90d63          	beq	s2,a5,800052d4 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000527e:	3979                	addiw	s2,s2,-2
    80005280:	4785                	li	a5,1
    80005282:	0527e063          	bltu	a5,s2,800052c2 <fileclose+0xa8>
    begin_op();
    80005286:	00000097          	auipc	ra,0x0
    8000528a:	ac8080e7          	jalr	-1336(ra) # 80004d4e <begin_op>
    iput(ff.ip);
    8000528e:	854e                	mv	a0,s3
    80005290:	fffff097          	auipc	ra,0xfffff
    80005294:	f90080e7          	jalr	-112(ra) # 80004220 <iput>
    end_op();
    80005298:	00000097          	auipc	ra,0x0
    8000529c:	b36080e7          	jalr	-1226(ra) # 80004dce <end_op>
    800052a0:	a00d                	j	800052c2 <fileclose+0xa8>
    panic("fileclose");
    800052a2:	00005517          	auipc	a0,0x5
    800052a6:	92e50513          	addi	a0,a0,-1746 # 80009bd0 <syscalls+0x2b8>
    800052aa:	ffffb097          	auipc	ra,0xffffb
    800052ae:	280080e7          	jalr	640(ra) # 8000052a <panic>
    release(&ftable.lock);
    800052b2:	0002a517          	auipc	a0,0x2a
    800052b6:	b0650513          	addi	a0,a0,-1274 # 8002edb8 <ftable>
    800052ba:	ffffc097          	auipc	ra,0xffffc
    800052be:	9bc080e7          	jalr	-1604(ra) # 80000c76 <release>
  }
}
    800052c2:	70e2                	ld	ra,56(sp)
    800052c4:	7442                	ld	s0,48(sp)
    800052c6:	74a2                	ld	s1,40(sp)
    800052c8:	7902                	ld	s2,32(sp)
    800052ca:	69e2                	ld	s3,24(sp)
    800052cc:	6a42                	ld	s4,16(sp)
    800052ce:	6aa2                	ld	s5,8(sp)
    800052d0:	6121                	addi	sp,sp,64
    800052d2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800052d4:	85d6                	mv	a1,s5
    800052d6:	8552                	mv	a0,s4
    800052d8:	00000097          	auipc	ra,0x0
    800052dc:	542080e7          	jalr	1346(ra) # 8000581a <pipeclose>
    800052e0:	b7cd                	j	800052c2 <fileclose+0xa8>

00000000800052e2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800052e2:	715d                	addi	sp,sp,-80
    800052e4:	e486                	sd	ra,72(sp)
    800052e6:	e0a2                	sd	s0,64(sp)
    800052e8:	fc26                	sd	s1,56(sp)
    800052ea:	f84a                	sd	s2,48(sp)
    800052ec:	f44e                	sd	s3,40(sp)
    800052ee:	0880                	addi	s0,sp,80
    800052f0:	84aa                	mv	s1,a0
    800052f2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800052f4:	ffffd097          	auipc	ra,0xffffd
    800052f8:	a1c080e7          	jalr	-1508(ra) # 80001d10 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800052fc:	409c                	lw	a5,0(s1)
    800052fe:	37f9                	addiw	a5,a5,-2
    80005300:	4705                	li	a4,1
    80005302:	04f76763          	bltu	a4,a5,80005350 <filestat+0x6e>
    80005306:	892a                	mv	s2,a0
    ilock(f->ip);
    80005308:	6c88                	ld	a0,24(s1)
    8000530a:	fffff097          	auipc	ra,0xfffff
    8000530e:	d5c080e7          	jalr	-676(ra) # 80004066 <ilock>
    stati(f->ip, &st);
    80005312:	fb840593          	addi	a1,s0,-72
    80005316:	6c88                	ld	a0,24(s1)
    80005318:	fffff097          	auipc	ra,0xfffff
    8000531c:	fd8080e7          	jalr	-40(ra) # 800042f0 <stati>
    iunlock(f->ip);
    80005320:	6c88                	ld	a0,24(s1)
    80005322:	fffff097          	auipc	ra,0xfffff
    80005326:	e06080e7          	jalr	-506(ra) # 80004128 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000532a:	46e1                	li	a3,24
    8000532c:	fb840613          	addi	a2,s0,-72
    80005330:	85ce                	mv	a1,s3
    80005332:	05093503          	ld	a0,80(s2)
    80005336:	ffffc097          	auipc	ra,0xffffc
    8000533a:	05c080e7          	jalr	92(ra) # 80001392 <copyout>
    8000533e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80005342:	60a6                	ld	ra,72(sp)
    80005344:	6406                	ld	s0,64(sp)
    80005346:	74e2                	ld	s1,56(sp)
    80005348:	7942                	ld	s2,48(sp)
    8000534a:	79a2                	ld	s3,40(sp)
    8000534c:	6161                	addi	sp,sp,80
    8000534e:	8082                	ret
  return -1;
    80005350:	557d                	li	a0,-1
    80005352:	bfc5                	j	80005342 <filestat+0x60>

0000000080005354 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005354:	7179                	addi	sp,sp,-48
    80005356:	f406                	sd	ra,40(sp)
    80005358:	f022                	sd	s0,32(sp)
    8000535a:	ec26                	sd	s1,24(sp)
    8000535c:	e84a                	sd	s2,16(sp)
    8000535e:	e44e                	sd	s3,8(sp)
    80005360:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005362:	00854783          	lbu	a5,8(a0)
    80005366:	c3d5                	beqz	a5,8000540a <fileread+0xb6>
    80005368:	84aa                	mv	s1,a0
    8000536a:	89ae                	mv	s3,a1
    8000536c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000536e:	411c                	lw	a5,0(a0)
    80005370:	4705                	li	a4,1
    80005372:	04e78963          	beq	a5,a4,800053c4 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005376:	470d                	li	a4,3
    80005378:	04e78d63          	beq	a5,a4,800053d2 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000537c:	4709                	li	a4,2
    8000537e:	06e79e63          	bne	a5,a4,800053fa <fileread+0xa6>
    ilock(f->ip);
    80005382:	6d08                	ld	a0,24(a0)
    80005384:	fffff097          	auipc	ra,0xfffff
    80005388:	ce2080e7          	jalr	-798(ra) # 80004066 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000538c:	874a                	mv	a4,s2
    8000538e:	5094                	lw	a3,32(s1)
    80005390:	864e                	mv	a2,s3
    80005392:	4585                	li	a1,1
    80005394:	6c88                	ld	a0,24(s1)
    80005396:	fffff097          	auipc	ra,0xfffff
    8000539a:	f84080e7          	jalr	-124(ra) # 8000431a <readi>
    8000539e:	892a                	mv	s2,a0
    800053a0:	00a05563          	blez	a0,800053aa <fileread+0x56>
      f->off += r;
    800053a4:	509c                	lw	a5,32(s1)
    800053a6:	9fa9                	addw	a5,a5,a0
    800053a8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800053aa:	6c88                	ld	a0,24(s1)
    800053ac:	fffff097          	auipc	ra,0xfffff
    800053b0:	d7c080e7          	jalr	-644(ra) # 80004128 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800053b4:	854a                	mv	a0,s2
    800053b6:	70a2                	ld	ra,40(sp)
    800053b8:	7402                	ld	s0,32(sp)
    800053ba:	64e2                	ld	s1,24(sp)
    800053bc:	6942                	ld	s2,16(sp)
    800053be:	69a2                	ld	s3,8(sp)
    800053c0:	6145                	addi	sp,sp,48
    800053c2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800053c4:	6908                	ld	a0,16(a0)
    800053c6:	00000097          	auipc	ra,0x0
    800053ca:	5b6080e7          	jalr	1462(ra) # 8000597c <piperead>
    800053ce:	892a                	mv	s2,a0
    800053d0:	b7d5                	j	800053b4 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800053d2:	02451783          	lh	a5,36(a0)
    800053d6:	03079693          	slli	a3,a5,0x30
    800053da:	92c1                	srli	a3,a3,0x30
    800053dc:	4725                	li	a4,9
    800053de:	02d76863          	bltu	a4,a3,8000540e <fileread+0xba>
    800053e2:	0792                	slli	a5,a5,0x4
    800053e4:	0002a717          	auipc	a4,0x2a
    800053e8:	93470713          	addi	a4,a4,-1740 # 8002ed18 <devsw>
    800053ec:	97ba                	add	a5,a5,a4
    800053ee:	639c                	ld	a5,0(a5)
    800053f0:	c38d                	beqz	a5,80005412 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800053f2:	4505                	li	a0,1
    800053f4:	9782                	jalr	a5
    800053f6:	892a                	mv	s2,a0
    800053f8:	bf75                	j	800053b4 <fileread+0x60>
    panic("fileread");
    800053fa:	00004517          	auipc	a0,0x4
    800053fe:	7e650513          	addi	a0,a0,2022 # 80009be0 <syscalls+0x2c8>
    80005402:	ffffb097          	auipc	ra,0xffffb
    80005406:	128080e7          	jalr	296(ra) # 8000052a <panic>
    return -1;
    8000540a:	597d                	li	s2,-1
    8000540c:	b765                	j	800053b4 <fileread+0x60>
      return -1;
    8000540e:	597d                	li	s2,-1
    80005410:	b755                	j	800053b4 <fileread+0x60>
    80005412:	597d                	li	s2,-1
    80005414:	b745                	j	800053b4 <fileread+0x60>

0000000080005416 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80005416:	715d                	addi	sp,sp,-80
    80005418:	e486                	sd	ra,72(sp)
    8000541a:	e0a2                	sd	s0,64(sp)
    8000541c:	fc26                	sd	s1,56(sp)
    8000541e:	f84a                	sd	s2,48(sp)
    80005420:	f44e                	sd	s3,40(sp)
    80005422:	f052                	sd	s4,32(sp)
    80005424:	ec56                	sd	s5,24(sp)
    80005426:	e85a                	sd	s6,16(sp)
    80005428:	e45e                	sd	s7,8(sp)
    8000542a:	e062                	sd	s8,0(sp)
    8000542c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000542e:	00954783          	lbu	a5,9(a0)
    80005432:	10078663          	beqz	a5,8000553e <filewrite+0x128>
    80005436:	892a                	mv	s2,a0
    80005438:	8aae                	mv	s5,a1
    8000543a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000543c:	411c                	lw	a5,0(a0)
    8000543e:	4705                	li	a4,1
    80005440:	02e78263          	beq	a5,a4,80005464 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005444:	470d                	li	a4,3
    80005446:	02e78663          	beq	a5,a4,80005472 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000544a:	4709                	li	a4,2
    8000544c:	0ee79163          	bne	a5,a4,8000552e <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005450:	0ac05d63          	blez	a2,8000550a <filewrite+0xf4>
    int i = 0;
    80005454:	4981                	li	s3,0
    80005456:	6b05                	lui	s6,0x1
    80005458:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000545c:	6b85                	lui	s7,0x1
    8000545e:	c00b8b9b          	addiw	s7,s7,-1024
    80005462:	a861                	j	800054fa <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005464:	6908                	ld	a0,16(a0)
    80005466:	00000097          	auipc	ra,0x0
    8000546a:	424080e7          	jalr	1060(ra) # 8000588a <pipewrite>
    8000546e:	8a2a                	mv	s4,a0
    80005470:	a045                	j	80005510 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005472:	02451783          	lh	a5,36(a0)
    80005476:	03079693          	slli	a3,a5,0x30
    8000547a:	92c1                	srli	a3,a3,0x30
    8000547c:	4725                	li	a4,9
    8000547e:	0cd76263          	bltu	a4,a3,80005542 <filewrite+0x12c>
    80005482:	0792                	slli	a5,a5,0x4
    80005484:	0002a717          	auipc	a4,0x2a
    80005488:	89470713          	addi	a4,a4,-1900 # 8002ed18 <devsw>
    8000548c:	97ba                	add	a5,a5,a4
    8000548e:	679c                	ld	a5,8(a5)
    80005490:	cbdd                	beqz	a5,80005546 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005492:	4505                	li	a0,1
    80005494:	9782                	jalr	a5
    80005496:	8a2a                	mv	s4,a0
    80005498:	a8a5                	j	80005510 <filewrite+0xfa>
    8000549a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000549e:	00000097          	auipc	ra,0x0
    800054a2:	8b0080e7          	jalr	-1872(ra) # 80004d4e <begin_op>
      ilock(f->ip);
    800054a6:	01893503          	ld	a0,24(s2)
    800054aa:	fffff097          	auipc	ra,0xfffff
    800054ae:	bbc080e7          	jalr	-1092(ra) # 80004066 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800054b2:	8762                	mv	a4,s8
    800054b4:	02092683          	lw	a3,32(s2)
    800054b8:	01598633          	add	a2,s3,s5
    800054bc:	4585                	li	a1,1
    800054be:	01893503          	ld	a0,24(s2)
    800054c2:	fffff097          	auipc	ra,0xfffff
    800054c6:	f50080e7          	jalr	-176(ra) # 80004412 <writei>
    800054ca:	84aa                	mv	s1,a0
    800054cc:	00a05763          	blez	a0,800054da <filewrite+0xc4>
        f->off += r;
    800054d0:	02092783          	lw	a5,32(s2)
    800054d4:	9fa9                	addw	a5,a5,a0
    800054d6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800054da:	01893503          	ld	a0,24(s2)
    800054de:	fffff097          	auipc	ra,0xfffff
    800054e2:	c4a080e7          	jalr	-950(ra) # 80004128 <iunlock>
      end_op();
    800054e6:	00000097          	auipc	ra,0x0
    800054ea:	8e8080e7          	jalr	-1816(ra) # 80004dce <end_op>

      if(r != n1){
    800054ee:	009c1f63          	bne	s8,s1,8000550c <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800054f2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800054f6:	0149db63          	bge	s3,s4,8000550c <filewrite+0xf6>
      int n1 = n - i;
    800054fa:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800054fe:	84be                	mv	s1,a5
    80005500:	2781                	sext.w	a5,a5
    80005502:	f8fb5ce3          	bge	s6,a5,8000549a <filewrite+0x84>
    80005506:	84de                	mv	s1,s7
    80005508:	bf49                	j	8000549a <filewrite+0x84>
    int i = 0;
    8000550a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000550c:	013a1f63          	bne	s4,s3,8000552a <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005510:	8552                	mv	a0,s4
    80005512:	60a6                	ld	ra,72(sp)
    80005514:	6406                	ld	s0,64(sp)
    80005516:	74e2                	ld	s1,56(sp)
    80005518:	7942                	ld	s2,48(sp)
    8000551a:	79a2                	ld	s3,40(sp)
    8000551c:	7a02                	ld	s4,32(sp)
    8000551e:	6ae2                	ld	s5,24(sp)
    80005520:	6b42                	ld	s6,16(sp)
    80005522:	6ba2                	ld	s7,8(sp)
    80005524:	6c02                	ld	s8,0(sp)
    80005526:	6161                	addi	sp,sp,80
    80005528:	8082                	ret
    ret = (i == n ? n : -1);
    8000552a:	5a7d                	li	s4,-1
    8000552c:	b7d5                	j	80005510 <filewrite+0xfa>
    panic("filewrite");
    8000552e:	00004517          	auipc	a0,0x4
    80005532:	6c250513          	addi	a0,a0,1730 # 80009bf0 <syscalls+0x2d8>
    80005536:	ffffb097          	auipc	ra,0xffffb
    8000553a:	ff4080e7          	jalr	-12(ra) # 8000052a <panic>
    return -1;
    8000553e:	5a7d                	li	s4,-1
    80005540:	bfc1                	j	80005510 <filewrite+0xfa>
      return -1;
    80005542:	5a7d                	li	s4,-1
    80005544:	b7f1                	j	80005510 <filewrite+0xfa>
    80005546:	5a7d                	li	s4,-1
    80005548:	b7e1                	j	80005510 <filewrite+0xfa>

000000008000554a <kfileread>:

// Read from file f.
// addr is a kernel virtual address.
int
kfileread(struct file *f, uint64 addr, int n)
{
    8000554a:	7179                	addi	sp,sp,-48
    8000554c:	f406                	sd	ra,40(sp)
    8000554e:	f022                	sd	s0,32(sp)
    80005550:	ec26                	sd	s1,24(sp)
    80005552:	e84a                	sd	s2,16(sp)
    80005554:	e44e                	sd	s3,8(sp)
    80005556:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005558:	00854783          	lbu	a5,8(a0)
    8000555c:	c3d5                	beqz	a5,80005600 <kfileread+0xb6>
    8000555e:	84aa                	mv	s1,a0
    80005560:	89ae                	mv	s3,a1
    80005562:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005564:	411c                	lw	a5,0(a0)
    80005566:	4705                	li	a4,1
    80005568:	04e78963          	beq	a5,a4,800055ba <kfileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000556c:	470d                	li	a4,3
    8000556e:	04e78d63          	beq	a5,a4,800055c8 <kfileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005572:	4709                	li	a4,2
    80005574:	06e79e63          	bne	a5,a4,800055f0 <kfileread+0xa6>
    ilock(f->ip);
    80005578:	6d08                	ld	a0,24(a0)
    8000557a:	fffff097          	auipc	ra,0xfffff
    8000557e:	aec080e7          	jalr	-1300(ra) # 80004066 <ilock>
    if((r = readi(f->ip, 0, addr, f->off, n)) > 0)
    80005582:	874a                	mv	a4,s2
    80005584:	5094                	lw	a3,32(s1)
    80005586:	864e                	mv	a2,s3
    80005588:	4581                	li	a1,0
    8000558a:	6c88                	ld	a0,24(s1)
    8000558c:	fffff097          	auipc	ra,0xfffff
    80005590:	d8e080e7          	jalr	-626(ra) # 8000431a <readi>
    80005594:	892a                	mv	s2,a0
    80005596:	00a05563          	blez	a0,800055a0 <kfileread+0x56>
      f->off += r;
    8000559a:	509c                	lw	a5,32(s1)
    8000559c:	9fa9                	addw	a5,a5,a0
    8000559e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800055a0:	6c88                	ld	a0,24(s1)
    800055a2:	fffff097          	auipc	ra,0xfffff
    800055a6:	b86080e7          	jalr	-1146(ra) # 80004128 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800055aa:	854a                	mv	a0,s2
    800055ac:	70a2                	ld	ra,40(sp)
    800055ae:	7402                	ld	s0,32(sp)
    800055b0:	64e2                	ld	s1,24(sp)
    800055b2:	6942                	ld	s2,16(sp)
    800055b4:	69a2                	ld	s3,8(sp)
    800055b6:	6145                	addi	sp,sp,48
    800055b8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800055ba:	6908                	ld	a0,16(a0)
    800055bc:	00000097          	auipc	ra,0x0
    800055c0:	3c0080e7          	jalr	960(ra) # 8000597c <piperead>
    800055c4:	892a                	mv	s2,a0
    800055c6:	b7d5                	j	800055aa <kfileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800055c8:	02451783          	lh	a5,36(a0)
    800055cc:	03079693          	slli	a3,a5,0x30
    800055d0:	92c1                	srli	a3,a3,0x30
    800055d2:	4725                	li	a4,9
    800055d4:	02d76863          	bltu	a4,a3,80005604 <kfileread+0xba>
    800055d8:	0792                	slli	a5,a5,0x4
    800055da:	00029717          	auipc	a4,0x29
    800055de:	73e70713          	addi	a4,a4,1854 # 8002ed18 <devsw>
    800055e2:	97ba                	add	a5,a5,a4
    800055e4:	639c                	ld	a5,0(a5)
    800055e6:	c38d                	beqz	a5,80005608 <kfileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800055e8:	4505                	li	a0,1
    800055ea:	9782                	jalr	a5
    800055ec:	892a                	mv	s2,a0
    800055ee:	bf75                	j	800055aa <kfileread+0x60>
    panic("fileread");
    800055f0:	00004517          	auipc	a0,0x4
    800055f4:	5f050513          	addi	a0,a0,1520 # 80009be0 <syscalls+0x2c8>
    800055f8:	ffffb097          	auipc	ra,0xffffb
    800055fc:	f32080e7          	jalr	-206(ra) # 8000052a <panic>
    return -1;
    80005600:	597d                	li	s2,-1
    80005602:	b765                	j	800055aa <kfileread+0x60>
      return -1;
    80005604:	597d                	li	s2,-1
    80005606:	b755                	j	800055aa <kfileread+0x60>
    80005608:	597d                	li	s2,-1
    8000560a:	b745                	j	800055aa <kfileread+0x60>

000000008000560c <kfilewrite>:

// Write to file f.
// addr is a kernel virtual address.
int
kfilewrite(struct file *f, uint64 addr, int n)
{
    8000560c:	715d                	addi	sp,sp,-80
    8000560e:	e486                	sd	ra,72(sp)
    80005610:	e0a2                	sd	s0,64(sp)
    80005612:	fc26                	sd	s1,56(sp)
    80005614:	f84a                	sd	s2,48(sp)
    80005616:	f44e                	sd	s3,40(sp)
    80005618:	f052                	sd	s4,32(sp)
    8000561a:	ec56                	sd	s5,24(sp)
    8000561c:	e85a                	sd	s6,16(sp)
    8000561e:	e45e                	sd	s7,8(sp)
    80005620:	e062                	sd	s8,0(sp)
    80005622:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005624:	00954783          	lbu	a5,9(a0)
    80005628:	10078663          	beqz	a5,80005734 <kfilewrite+0x128>
    8000562c:	892a                	mv	s2,a0
    8000562e:	8aae                	mv	s5,a1
    80005630:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005632:	411c                	lw	a5,0(a0)
    80005634:	4705                	li	a4,1
    80005636:	02e78263          	beq	a5,a4,8000565a <kfilewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000563a:	470d                	li	a4,3
    8000563c:	02e78663          	beq	a5,a4,80005668 <kfilewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005640:	4709                	li	a4,2
    80005642:	0ee79163          	bne	a5,a4,80005724 <kfilewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005646:	0ac05d63          	blez	a2,80005700 <kfilewrite+0xf4>
    int i = 0;
    8000564a:	4981                	li	s3,0
    8000564c:	6b05                	lui	s6,0x1
    8000564e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005652:	6b85                	lui	s7,0x1
    80005654:	c00b8b9b          	addiw	s7,s7,-1024
    80005658:	a861                	j	800056f0 <kfilewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000565a:	6908                	ld	a0,16(a0)
    8000565c:	00000097          	auipc	ra,0x0
    80005660:	22e080e7          	jalr	558(ra) # 8000588a <pipewrite>
    80005664:	8a2a                	mv	s4,a0
    80005666:	a045                	j	80005706 <kfilewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005668:	02451783          	lh	a5,36(a0)
    8000566c:	03079693          	slli	a3,a5,0x30
    80005670:	92c1                	srli	a3,a3,0x30
    80005672:	4725                	li	a4,9
    80005674:	0cd76263          	bltu	a4,a3,80005738 <kfilewrite+0x12c>
    80005678:	0792                	slli	a5,a5,0x4
    8000567a:	00029717          	auipc	a4,0x29
    8000567e:	69e70713          	addi	a4,a4,1694 # 8002ed18 <devsw>
    80005682:	97ba                	add	a5,a5,a4
    80005684:	679c                	ld	a5,8(a5)
    80005686:	cbdd                	beqz	a5,8000573c <kfilewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005688:	4505                	li	a0,1
    8000568a:	9782                	jalr	a5
    8000568c:	8a2a                	mv	s4,a0
    8000568e:	a8a5                	j	80005706 <kfilewrite+0xfa>
    80005690:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005694:	fffff097          	auipc	ra,0xfffff
    80005698:	6ba080e7          	jalr	1722(ra) # 80004d4e <begin_op>
      ilock(f->ip);
    8000569c:	01893503          	ld	a0,24(s2)
    800056a0:	fffff097          	auipc	ra,0xfffff
    800056a4:	9c6080e7          	jalr	-1594(ra) # 80004066 <ilock>
      if ((r = writei(f->ip, 0, addr + i, f->off, n1)) > 0)
    800056a8:	8762                	mv	a4,s8
    800056aa:	02092683          	lw	a3,32(s2)
    800056ae:	01598633          	add	a2,s3,s5
    800056b2:	4581                	li	a1,0
    800056b4:	01893503          	ld	a0,24(s2)
    800056b8:	fffff097          	auipc	ra,0xfffff
    800056bc:	d5a080e7          	jalr	-678(ra) # 80004412 <writei>
    800056c0:	84aa                	mv	s1,a0
    800056c2:	00a05763          	blez	a0,800056d0 <kfilewrite+0xc4>
        f->off += r;
    800056c6:	02092783          	lw	a5,32(s2)
    800056ca:	9fa9                	addw	a5,a5,a0
    800056cc:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800056d0:	01893503          	ld	a0,24(s2)
    800056d4:	fffff097          	auipc	ra,0xfffff
    800056d8:	a54080e7          	jalr	-1452(ra) # 80004128 <iunlock>
      end_op();
    800056dc:	fffff097          	auipc	ra,0xfffff
    800056e0:	6f2080e7          	jalr	1778(ra) # 80004dce <end_op>

      if(r != n1){
    800056e4:	009c1f63          	bne	s8,s1,80005702 <kfilewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800056e8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800056ec:	0149db63          	bge	s3,s4,80005702 <kfilewrite+0xf6>
      int n1 = n - i;
    800056f0:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800056f4:	84be                	mv	s1,a5
    800056f6:	2781                	sext.w	a5,a5
    800056f8:	f8fb5ce3          	bge	s6,a5,80005690 <kfilewrite+0x84>
    800056fc:	84de                	mv	s1,s7
    800056fe:	bf49                	j	80005690 <kfilewrite+0x84>
    int i = 0;
    80005700:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005702:	013a1f63          	bne	s4,s3,80005720 <kfilewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
    80005706:	8552                	mv	a0,s4
    80005708:	60a6                	ld	ra,72(sp)
    8000570a:	6406                	ld	s0,64(sp)
    8000570c:	74e2                	ld	s1,56(sp)
    8000570e:	7942                	ld	s2,48(sp)
    80005710:	79a2                	ld	s3,40(sp)
    80005712:	7a02                	ld	s4,32(sp)
    80005714:	6ae2                	ld	s5,24(sp)
    80005716:	6b42                	ld	s6,16(sp)
    80005718:	6ba2                	ld	s7,8(sp)
    8000571a:	6c02                	ld	s8,0(sp)
    8000571c:	6161                	addi	sp,sp,80
    8000571e:	8082                	ret
    ret = (i == n ? n : -1);
    80005720:	5a7d                	li	s4,-1
    80005722:	b7d5                	j	80005706 <kfilewrite+0xfa>
    panic("filewrite");
    80005724:	00004517          	auipc	a0,0x4
    80005728:	4cc50513          	addi	a0,a0,1228 # 80009bf0 <syscalls+0x2d8>
    8000572c:	ffffb097          	auipc	ra,0xffffb
    80005730:	dfe080e7          	jalr	-514(ra) # 8000052a <panic>
    return -1;
    80005734:	5a7d                	li	s4,-1
    80005736:	bfc1                	j	80005706 <kfilewrite+0xfa>
      return -1;
    80005738:	5a7d                	li	s4,-1
    8000573a:	b7f1                	j	80005706 <kfilewrite+0xfa>
    8000573c:	5a7d                	li	s4,-1
    8000573e:	b7e1                	j	80005706 <kfilewrite+0xfa>

0000000080005740 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005740:	7179                	addi	sp,sp,-48
    80005742:	f406                	sd	ra,40(sp)
    80005744:	f022                	sd	s0,32(sp)
    80005746:	ec26                	sd	s1,24(sp)
    80005748:	e84a                	sd	s2,16(sp)
    8000574a:	e44e                	sd	s3,8(sp)
    8000574c:	e052                	sd	s4,0(sp)
    8000574e:	1800                	addi	s0,sp,48
    80005750:	84aa                	mv	s1,a0
    80005752:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005754:	0005b023          	sd	zero,0(a1)
    80005758:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000575c:	00000097          	auipc	ra,0x0
    80005760:	a02080e7          	jalr	-1534(ra) # 8000515e <filealloc>
    80005764:	e088                	sd	a0,0(s1)
    80005766:	c551                	beqz	a0,800057f2 <pipealloc+0xb2>
    80005768:	00000097          	auipc	ra,0x0
    8000576c:	9f6080e7          	jalr	-1546(ra) # 8000515e <filealloc>
    80005770:	00aa3023          	sd	a0,0(s4)
    80005774:	c92d                	beqz	a0,800057e6 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005776:	ffffb097          	auipc	ra,0xffffb
    8000577a:	35c080e7          	jalr	860(ra) # 80000ad2 <kalloc>
    8000577e:	892a                	mv	s2,a0
    80005780:	c125                	beqz	a0,800057e0 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005782:	4985                	li	s3,1
    80005784:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005788:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000578c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005790:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005794:	00004597          	auipc	a1,0x4
    80005798:	46c58593          	addi	a1,a1,1132 # 80009c00 <syscalls+0x2e8>
    8000579c:	ffffb097          	auipc	ra,0xffffb
    800057a0:	396080e7          	jalr	918(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    800057a4:	609c                	ld	a5,0(s1)
    800057a6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800057aa:	609c                	ld	a5,0(s1)
    800057ac:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800057b0:	609c                	ld	a5,0(s1)
    800057b2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800057b6:	609c                	ld	a5,0(s1)
    800057b8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800057bc:	000a3783          	ld	a5,0(s4)
    800057c0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800057c4:	000a3783          	ld	a5,0(s4)
    800057c8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800057cc:	000a3783          	ld	a5,0(s4)
    800057d0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800057d4:	000a3783          	ld	a5,0(s4)
    800057d8:	0127b823          	sd	s2,16(a5)
  return 0;
    800057dc:	4501                	li	a0,0
    800057de:	a025                	j	80005806 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800057e0:	6088                	ld	a0,0(s1)
    800057e2:	e501                	bnez	a0,800057ea <pipealloc+0xaa>
    800057e4:	a039                	j	800057f2 <pipealloc+0xb2>
    800057e6:	6088                	ld	a0,0(s1)
    800057e8:	c51d                	beqz	a0,80005816 <pipealloc+0xd6>
    fileclose(*f0);
    800057ea:	00000097          	auipc	ra,0x0
    800057ee:	a30080e7          	jalr	-1488(ra) # 8000521a <fileclose>
  if(*f1)
    800057f2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800057f6:	557d                	li	a0,-1
  if(*f1)
    800057f8:	c799                	beqz	a5,80005806 <pipealloc+0xc6>
    fileclose(*f1);
    800057fa:	853e                	mv	a0,a5
    800057fc:	00000097          	auipc	ra,0x0
    80005800:	a1e080e7          	jalr	-1506(ra) # 8000521a <fileclose>
  return -1;
    80005804:	557d                	li	a0,-1
}
    80005806:	70a2                	ld	ra,40(sp)
    80005808:	7402                	ld	s0,32(sp)
    8000580a:	64e2                	ld	s1,24(sp)
    8000580c:	6942                	ld	s2,16(sp)
    8000580e:	69a2                	ld	s3,8(sp)
    80005810:	6a02                	ld	s4,0(sp)
    80005812:	6145                	addi	sp,sp,48
    80005814:	8082                	ret
  return -1;
    80005816:	557d                	li	a0,-1
    80005818:	b7fd                	j	80005806 <pipealloc+0xc6>

000000008000581a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000581a:	1101                	addi	sp,sp,-32
    8000581c:	ec06                	sd	ra,24(sp)
    8000581e:	e822                	sd	s0,16(sp)
    80005820:	e426                	sd	s1,8(sp)
    80005822:	e04a                	sd	s2,0(sp)
    80005824:	1000                	addi	s0,sp,32
    80005826:	84aa                	mv	s1,a0
    80005828:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000582a:	ffffb097          	auipc	ra,0xffffb
    8000582e:	398080e7          	jalr	920(ra) # 80000bc2 <acquire>
  if(writable){
    80005832:	02090d63          	beqz	s2,8000586c <pipeclose+0x52>
    pi->writeopen = 0;
    80005836:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000583a:	21848513          	addi	a0,s1,536
    8000583e:	ffffd097          	auipc	ra,0xffffd
    80005842:	b56080e7          	jalr	-1194(ra) # 80002394 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005846:	2204b783          	ld	a5,544(s1)
    8000584a:	eb95                	bnez	a5,8000587e <pipeclose+0x64>
    release(&pi->lock);
    8000584c:	8526                	mv	a0,s1
    8000584e:	ffffb097          	auipc	ra,0xffffb
    80005852:	428080e7          	jalr	1064(ra) # 80000c76 <release>
    kfree((char*)pi);
    80005856:	8526                	mv	a0,s1
    80005858:	ffffb097          	auipc	ra,0xffffb
    8000585c:	17e080e7          	jalr	382(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    80005860:	60e2                	ld	ra,24(sp)
    80005862:	6442                	ld	s0,16(sp)
    80005864:	64a2                	ld	s1,8(sp)
    80005866:	6902                	ld	s2,0(sp)
    80005868:	6105                	addi	sp,sp,32
    8000586a:	8082                	ret
    pi->readopen = 0;
    8000586c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005870:	21c48513          	addi	a0,s1,540
    80005874:	ffffd097          	auipc	ra,0xffffd
    80005878:	b20080e7          	jalr	-1248(ra) # 80002394 <wakeup>
    8000587c:	b7e9                	j	80005846 <pipeclose+0x2c>
    release(&pi->lock);
    8000587e:	8526                	mv	a0,s1
    80005880:	ffffb097          	auipc	ra,0xffffb
    80005884:	3f6080e7          	jalr	1014(ra) # 80000c76 <release>
}
    80005888:	bfe1                	j	80005860 <pipeclose+0x46>

000000008000588a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000588a:	711d                	addi	sp,sp,-96
    8000588c:	ec86                	sd	ra,88(sp)
    8000588e:	e8a2                	sd	s0,80(sp)
    80005890:	e4a6                	sd	s1,72(sp)
    80005892:	e0ca                	sd	s2,64(sp)
    80005894:	fc4e                	sd	s3,56(sp)
    80005896:	f852                	sd	s4,48(sp)
    80005898:	f456                	sd	s5,40(sp)
    8000589a:	f05a                	sd	s6,32(sp)
    8000589c:	ec5e                	sd	s7,24(sp)
    8000589e:	e862                	sd	s8,16(sp)
    800058a0:	1080                	addi	s0,sp,96
    800058a2:	84aa                	mv	s1,a0
    800058a4:	8aae                	mv	s5,a1
    800058a6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800058a8:	ffffc097          	auipc	ra,0xffffc
    800058ac:	468080e7          	jalr	1128(ra) # 80001d10 <myproc>
    800058b0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800058b2:	8526                	mv	a0,s1
    800058b4:	ffffb097          	auipc	ra,0xffffb
    800058b8:	30e080e7          	jalr	782(ra) # 80000bc2 <acquire>
  while(i < n){
    800058bc:	0b405363          	blez	s4,80005962 <pipewrite+0xd8>
  int i = 0;
    800058c0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800058c2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800058c4:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800058c8:	21c48b93          	addi	s7,s1,540
    800058cc:	a089                	j	8000590e <pipewrite+0x84>
      release(&pi->lock);
    800058ce:	8526                	mv	a0,s1
    800058d0:	ffffb097          	auipc	ra,0xffffb
    800058d4:	3a6080e7          	jalr	934(ra) # 80000c76 <release>
      return -1;
    800058d8:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800058da:	854a                	mv	a0,s2
    800058dc:	60e6                	ld	ra,88(sp)
    800058de:	6446                	ld	s0,80(sp)
    800058e0:	64a6                	ld	s1,72(sp)
    800058e2:	6906                	ld	s2,64(sp)
    800058e4:	79e2                	ld	s3,56(sp)
    800058e6:	7a42                	ld	s4,48(sp)
    800058e8:	7aa2                	ld	s5,40(sp)
    800058ea:	7b02                	ld	s6,32(sp)
    800058ec:	6be2                	ld	s7,24(sp)
    800058ee:	6c42                	ld	s8,16(sp)
    800058f0:	6125                	addi	sp,sp,96
    800058f2:	8082                	ret
      wakeup(&pi->nread);
    800058f4:	8562                	mv	a0,s8
    800058f6:	ffffd097          	auipc	ra,0xffffd
    800058fa:	a9e080e7          	jalr	-1378(ra) # 80002394 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800058fe:	85a6                	mv	a1,s1
    80005900:	855e                	mv	a0,s7
    80005902:	ffffd097          	auipc	ra,0xffffd
    80005906:	906080e7          	jalr	-1786(ra) # 80002208 <sleep>
  while(i < n){
    8000590a:	05495d63          	bge	s2,s4,80005964 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    8000590e:	2204a783          	lw	a5,544(s1)
    80005912:	dfd5                	beqz	a5,800058ce <pipewrite+0x44>
    80005914:	0289a783          	lw	a5,40(s3)
    80005918:	fbdd                	bnez	a5,800058ce <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000591a:	2184a783          	lw	a5,536(s1)
    8000591e:	21c4a703          	lw	a4,540(s1)
    80005922:	2007879b          	addiw	a5,a5,512
    80005926:	fcf707e3          	beq	a4,a5,800058f4 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000592a:	4685                	li	a3,1
    8000592c:	01590633          	add	a2,s2,s5
    80005930:	faf40593          	addi	a1,s0,-81
    80005934:	0509b503          	ld	a0,80(s3)
    80005938:	ffffc097          	auipc	ra,0xffffc
    8000593c:	ae8080e7          	jalr	-1304(ra) # 80001420 <copyin>
    80005940:	03650263          	beq	a0,s6,80005964 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005944:	21c4a783          	lw	a5,540(s1)
    80005948:	0017871b          	addiw	a4,a5,1
    8000594c:	20e4ae23          	sw	a4,540(s1)
    80005950:	1ff7f793          	andi	a5,a5,511
    80005954:	97a6                	add	a5,a5,s1
    80005956:	faf44703          	lbu	a4,-81(s0)
    8000595a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000595e:	2905                	addiw	s2,s2,1
    80005960:	b76d                	j	8000590a <pipewrite+0x80>
  int i = 0;
    80005962:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005964:	21848513          	addi	a0,s1,536
    80005968:	ffffd097          	auipc	ra,0xffffd
    8000596c:	a2c080e7          	jalr	-1492(ra) # 80002394 <wakeup>
  release(&pi->lock);
    80005970:	8526                	mv	a0,s1
    80005972:	ffffb097          	auipc	ra,0xffffb
    80005976:	304080e7          	jalr	772(ra) # 80000c76 <release>
  return i;
    8000597a:	b785                	j	800058da <pipewrite+0x50>

000000008000597c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000597c:	715d                	addi	sp,sp,-80
    8000597e:	e486                	sd	ra,72(sp)
    80005980:	e0a2                	sd	s0,64(sp)
    80005982:	fc26                	sd	s1,56(sp)
    80005984:	f84a                	sd	s2,48(sp)
    80005986:	f44e                	sd	s3,40(sp)
    80005988:	f052                	sd	s4,32(sp)
    8000598a:	ec56                	sd	s5,24(sp)
    8000598c:	e85a                	sd	s6,16(sp)
    8000598e:	0880                	addi	s0,sp,80
    80005990:	84aa                	mv	s1,a0
    80005992:	892e                	mv	s2,a1
    80005994:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005996:	ffffc097          	auipc	ra,0xffffc
    8000599a:	37a080e7          	jalr	890(ra) # 80001d10 <myproc>
    8000599e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800059a0:	8526                	mv	a0,s1
    800059a2:	ffffb097          	auipc	ra,0xffffb
    800059a6:	220080e7          	jalr	544(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800059aa:	2184a703          	lw	a4,536(s1)
    800059ae:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800059b2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800059b6:	02f71463          	bne	a4,a5,800059de <piperead+0x62>
    800059ba:	2244a783          	lw	a5,548(s1)
    800059be:	c385                	beqz	a5,800059de <piperead+0x62>
    if(pr->killed){
    800059c0:	028a2783          	lw	a5,40(s4)
    800059c4:	ebc1                	bnez	a5,80005a54 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800059c6:	85a6                	mv	a1,s1
    800059c8:	854e                	mv	a0,s3
    800059ca:	ffffd097          	auipc	ra,0xffffd
    800059ce:	83e080e7          	jalr	-1986(ra) # 80002208 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800059d2:	2184a703          	lw	a4,536(s1)
    800059d6:	21c4a783          	lw	a5,540(s1)
    800059da:	fef700e3          	beq	a4,a5,800059ba <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800059de:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800059e0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800059e2:	05505363          	blez	s5,80005a28 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    800059e6:	2184a783          	lw	a5,536(s1)
    800059ea:	21c4a703          	lw	a4,540(s1)
    800059ee:	02f70d63          	beq	a4,a5,80005a28 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800059f2:	0017871b          	addiw	a4,a5,1
    800059f6:	20e4ac23          	sw	a4,536(s1)
    800059fa:	1ff7f793          	andi	a5,a5,511
    800059fe:	97a6                	add	a5,a5,s1
    80005a00:	0187c783          	lbu	a5,24(a5)
    80005a04:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005a08:	4685                	li	a3,1
    80005a0a:	fbf40613          	addi	a2,s0,-65
    80005a0e:	85ca                	mv	a1,s2
    80005a10:	050a3503          	ld	a0,80(s4)
    80005a14:	ffffc097          	auipc	ra,0xffffc
    80005a18:	97e080e7          	jalr	-1666(ra) # 80001392 <copyout>
    80005a1c:	01650663          	beq	a0,s6,80005a28 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005a20:	2985                	addiw	s3,s3,1
    80005a22:	0905                	addi	s2,s2,1
    80005a24:	fd3a91e3          	bne	s5,s3,800059e6 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005a28:	21c48513          	addi	a0,s1,540
    80005a2c:	ffffd097          	auipc	ra,0xffffd
    80005a30:	968080e7          	jalr	-1688(ra) # 80002394 <wakeup>
  release(&pi->lock);
    80005a34:	8526                	mv	a0,s1
    80005a36:	ffffb097          	auipc	ra,0xffffb
    80005a3a:	240080e7          	jalr	576(ra) # 80000c76 <release>
  return i;
}
    80005a3e:	854e                	mv	a0,s3
    80005a40:	60a6                	ld	ra,72(sp)
    80005a42:	6406                	ld	s0,64(sp)
    80005a44:	74e2                	ld	s1,56(sp)
    80005a46:	7942                	ld	s2,48(sp)
    80005a48:	79a2                	ld	s3,40(sp)
    80005a4a:	7a02                	ld	s4,32(sp)
    80005a4c:	6ae2                	ld	s5,24(sp)
    80005a4e:	6b42                	ld	s6,16(sp)
    80005a50:	6161                	addi	sp,sp,80
    80005a52:	8082                	ret
      release(&pi->lock);
    80005a54:	8526                	mv	a0,s1
    80005a56:	ffffb097          	auipc	ra,0xffffb
    80005a5a:	220080e7          	jalr	544(ra) # 80000c76 <release>
      return -1;
    80005a5e:	59fd                	li	s3,-1
    80005a60:	bff9                	j	80005a3e <piperead+0xc2>

0000000080005a62 <exec>:
#include "elf.h"

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int exec(char *path, char **argv)
{
    80005a62:	de010113          	addi	sp,sp,-544
    80005a66:	20113c23          	sd	ra,536(sp)
    80005a6a:	20813823          	sd	s0,528(sp)
    80005a6e:	20913423          	sd	s1,520(sp)
    80005a72:	21213023          	sd	s2,512(sp)
    80005a76:	ffce                	sd	s3,504(sp)
    80005a78:	fbd2                	sd	s4,496(sp)
    80005a7a:	f7d6                	sd	s5,488(sp)
    80005a7c:	f3da                	sd	s6,480(sp)
    80005a7e:	efde                	sd	s7,472(sp)
    80005a80:	ebe2                	sd	s8,464(sp)
    80005a82:	e7e6                	sd	s9,456(sp)
    80005a84:	e3ea                	sd	s10,448(sp)
    80005a86:	ff6e                	sd	s11,440(sp)
    80005a88:	1400                	addi	s0,sp,544
    80005a8a:	892a                	mv	s2,a0
    80005a8c:	dea43423          	sd	a0,-536(s0)
    80005a90:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005a94:	ffffc097          	auipc	ra,0xffffc
    80005a98:	27c080e7          	jalr	636(ra) # 80001d10 <myproc>
    80005a9c:	84aa                	mv	s1,a0



  begin_op();
    80005a9e:	fffff097          	auipc	ra,0xfffff
    80005aa2:	2b0080e7          	jalr	688(ra) # 80004d4e <begin_op>

  if ((ip = namei(path)) == 0)
    80005aa6:	854a                	mv	a0,s2
    80005aa8:	fffff097          	auipc	ra,0xfffff
    80005aac:	d74080e7          	jalr	-652(ra) # 8000481c <namei>
    80005ab0:	c93d                	beqz	a0,80005b26 <exec+0xc4>
    80005ab2:	8aaa                	mv	s5,a0
  {
    end_op();
    return -1;
  }
  ilock(ip);
    80005ab4:	ffffe097          	auipc	ra,0xffffe
    80005ab8:	5b2080e7          	jalr	1458(ra) # 80004066 <ilock>

  // Check ELF header
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005abc:	04000713          	li	a4,64
    80005ac0:	4681                	li	a3,0
    80005ac2:	e4840613          	addi	a2,s0,-440
    80005ac6:	4581                	li	a1,0
    80005ac8:	8556                	mv	a0,s5
    80005aca:	fffff097          	auipc	ra,0xfffff
    80005ace:	850080e7          	jalr	-1968(ra) # 8000431a <readi>
    80005ad2:	04000793          	li	a5,64
    80005ad6:	00f51a63          	bne	a0,a5,80005aea <exec+0x88>
    goto bad;
  if (elf.magic != ELF_MAGIC)
    80005ada:	e4842703          	lw	a4,-440(s0)
    80005ade:	464c47b7          	lui	a5,0x464c4
    80005ae2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005ae6:	04f70663          	beq	a4,a5,80005b32 <exec+0xd0>
bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip)
  {
    iunlockput(ip);
    80005aea:	8556                	mv	a0,s5
    80005aec:	ffffe097          	auipc	ra,0xffffe
    80005af0:	7dc080e7          	jalr	2012(ra) # 800042c8 <iunlockput>
    end_op();
    80005af4:	fffff097          	auipc	ra,0xfffff
    80005af8:	2da080e7          	jalr	730(ra) # 80004dce <end_op>
  }
  return -1;
    80005afc:	557d                	li	a0,-1
}
    80005afe:	21813083          	ld	ra,536(sp)
    80005b02:	21013403          	ld	s0,528(sp)
    80005b06:	20813483          	ld	s1,520(sp)
    80005b0a:	20013903          	ld	s2,512(sp)
    80005b0e:	79fe                	ld	s3,504(sp)
    80005b10:	7a5e                	ld	s4,496(sp)
    80005b12:	7abe                	ld	s5,488(sp)
    80005b14:	7b1e                	ld	s6,480(sp)
    80005b16:	6bfe                	ld	s7,472(sp)
    80005b18:	6c5e                	ld	s8,464(sp)
    80005b1a:	6cbe                	ld	s9,456(sp)
    80005b1c:	6d1e                	ld	s10,448(sp)
    80005b1e:	7dfa                	ld	s11,440(sp)
    80005b20:	22010113          	addi	sp,sp,544
    80005b24:	8082                	ret
    end_op();
    80005b26:	fffff097          	auipc	ra,0xfffff
    80005b2a:	2a8080e7          	jalr	680(ra) # 80004dce <end_op>
    return -1;
    80005b2e:	557d                	li	a0,-1
    80005b30:	b7f9                	j	80005afe <exec+0x9c>
  if ((pagetable = proc_pagetable(p)) == 0)
    80005b32:	8526                	mv	a0,s1
    80005b34:	ffffc097          	auipc	ra,0xffffc
    80005b38:	2a0080e7          	jalr	672(ra) # 80001dd4 <proc_pagetable>
    80005b3c:	8b2a                	mv	s6,a0
    80005b3e:	d555                	beqz	a0,80005aea <exec+0x88>
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005b40:	e6842783          	lw	a5,-408(s0)
    80005b44:	e8045703          	lhu	a4,-384(s0)
    80005b48:	c73d                	beqz	a4,80005bb6 <exec+0x154>
  uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
    80005b4a:	4481                	li	s1,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005b4c:	e0043423          	sd	zero,-504(s0)
    if (ph.vaddr % PGSIZE != 0)
    80005b50:	6a05                	lui	s4,0x1
    80005b52:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005b56:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if ((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for (i = 0; i < sz; i += PGSIZE)
    80005b5a:	6d85                	lui	s11,0x1
    80005b5c:	7d7d                	lui	s10,0xfffff
    80005b5e:	ac89                	j	80005db0 <exec+0x34e>
  {
    pa = walkaddr(pagetable, va + i, 0);
    if (pa == 0)
      panic("loadseg: address should exist");
    80005b60:	00004517          	auipc	a0,0x4
    80005b64:	0a850513          	addi	a0,a0,168 # 80009c08 <syscalls+0x2f0>
    80005b68:	ffffb097          	auipc	ra,0xffffb
    80005b6c:	9c2080e7          	jalr	-1598(ra) # 8000052a <panic>
    if (sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80005b70:	874a                	mv	a4,s2
    80005b72:	009c86bb          	addw	a3,s9,s1
    80005b76:	4581                	li	a1,0
    80005b78:	8556                	mv	a0,s5
    80005b7a:	ffffe097          	auipc	ra,0xffffe
    80005b7e:	7a0080e7          	jalr	1952(ra) # 8000431a <readi>
    80005b82:	2501                	sext.w	a0,a0
    80005b84:	1ca91663          	bne	s2,a0,80005d50 <exec+0x2ee>
  for (i = 0; i < sz; i += PGSIZE)
    80005b88:	009d84bb          	addw	s1,s11,s1
    80005b8c:	013d09bb          	addw	s3,s10,s3
    80005b90:	2174f063          	bgeu	s1,s7,80005d90 <exec+0x32e>
    pa = walkaddr(pagetable, va + i, 0);
    80005b94:	02049593          	slli	a1,s1,0x20
    80005b98:	9181                	srli	a1,a1,0x20
    80005b9a:	4601                	li	a2,0
    80005b9c:	95e2                	add	a1,a1,s8
    80005b9e:	855a                	mv	a0,s6
    80005ba0:	ffffb097          	auipc	ra,0xffffb
    80005ba4:	4ac080e7          	jalr	1196(ra) # 8000104c <walkaddr>
    80005ba8:	862a                	mv	a2,a0
    if (pa == 0)
    80005baa:	d95d                	beqz	a0,80005b60 <exec+0xfe>
      n = PGSIZE;
    80005bac:	8952                	mv	s2,s4
    if (sz - i < PGSIZE)
    80005bae:	fd49f1e3          	bgeu	s3,s4,80005b70 <exec+0x10e>
      n = sz - i;
    80005bb2:	894e                	mv	s2,s3
    80005bb4:	bf75                	j	80005b70 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
    80005bb6:	4481                	li	s1,0
  iunlockput(ip);
    80005bb8:	8556                	mv	a0,s5
    80005bba:	ffffe097          	auipc	ra,0xffffe
    80005bbe:	70e080e7          	jalr	1806(ra) # 800042c8 <iunlockput>
  end_op();
    80005bc2:	fffff097          	auipc	ra,0xfffff
    80005bc6:	20c080e7          	jalr	524(ra) # 80004dce <end_op>
  p = myproc();
    80005bca:	ffffc097          	auipc	ra,0xffffc
    80005bce:	146080e7          	jalr	326(ra) # 80001d10 <myproc>
    80005bd2:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005bd4:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005bd8:	6785                	lui	a5,0x1
    80005bda:	17fd                	addi	a5,a5,-1
    80005bdc:	94be                	add	s1,s1,a5
    80005bde:	77fd                	lui	a5,0xfffff
    80005be0:	8fe5                	and	a5,a5,s1
    80005be2:	def43c23          	sd	a5,-520(s0)
  sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE);
    80005be6:	6609                	lui	a2,0x2
    80005be8:	963e                	add	a2,a2,a5
    80005bea:	85be                	mv	a1,a5
    80005bec:	855a                	mv	a0,s6
    80005bee:	ffffc097          	auipc	ra,0xffffc
    80005bf2:	d14080e7          	jalr	-748(ra) # 80001902 <uvmalloc>
    80005bf6:	8c2a                	mv	s8,a0
  ip = 0;
    80005bf8:	4a81                	li	s5,0
  if ((sz1) == 0)
    80005bfa:	14050b63          	beqz	a0,80005d50 <exec+0x2ee>
  uvmclear(pagetable, sz - 2 * PGSIZE);
    80005bfe:	75f9                	lui	a1,0xffffe
    80005c00:	95aa                	add	a1,a1,a0
    80005c02:	855a                	mv	a0,s6
    80005c04:	ffffb097          	auipc	ra,0xffffb
    80005c08:	75c080e7          	jalr	1884(ra) # 80001360 <uvmclear>
  stackbase = sp - PGSIZE;
    80005c0c:	7afd                	lui	s5,0xfffff
    80005c0e:	9ae2                	add	s5,s5,s8
  for (argc = 0; argv[argc]; argc++)
    80005c10:	df043783          	ld	a5,-528(s0)
    80005c14:	6388                	ld	a0,0(a5)
    80005c16:	c925                	beqz	a0,80005c86 <exec+0x224>
    80005c18:	e8840993          	addi	s3,s0,-376
    80005c1c:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005c20:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    80005c22:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005c24:	ffffb097          	auipc	ra,0xffffb
    80005c28:	21e080e7          	jalr	542(ra) # 80000e42 <strlen>
    80005c2c:	0015079b          	addiw	a5,a0,1
    80005c30:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005c34:	ff097913          	andi	s2,s2,-16
    if (sp < stackbase)
    80005c38:	15596063          	bltu	s2,s5,80005d78 <exec+0x316>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005c3c:	df043d83          	ld	s11,-528(s0)
    80005c40:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005c44:	8552                	mv	a0,s4
    80005c46:	ffffb097          	auipc	ra,0xffffb
    80005c4a:	1fc080e7          	jalr	508(ra) # 80000e42 <strlen>
    80005c4e:	0015069b          	addiw	a3,a0,1
    80005c52:	8652                	mv	a2,s4
    80005c54:	85ca                	mv	a1,s2
    80005c56:	855a                	mv	a0,s6
    80005c58:	ffffb097          	auipc	ra,0xffffb
    80005c5c:	73a080e7          	jalr	1850(ra) # 80001392 <copyout>
    80005c60:	12054063          	bltz	a0,80005d80 <exec+0x31e>
    ustack[argc] = sp;
    80005c64:	0129b023          	sd	s2,0(s3)
  for (argc = 0; argv[argc]; argc++)
    80005c68:	0485                	addi	s1,s1,1
    80005c6a:	008d8793          	addi	a5,s11,8
    80005c6e:	def43823          	sd	a5,-528(s0)
    80005c72:	008db503          	ld	a0,8(s11)
    80005c76:	c911                	beqz	a0,80005c8a <exec+0x228>
    if (argc >= MAXARG)
    80005c78:	09a1                	addi	s3,s3,8
    80005c7a:	fb3c95e3          	bne	s9,s3,80005c24 <exec+0x1c2>
  sz = sz1;
    80005c7e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005c82:	4a81                	li	s5,0
    80005c84:	a0f1                	j	80005d50 <exec+0x2ee>
  sp = sz;
    80005c86:	8962                	mv	s2,s8
  for (argc = 0; argv[argc]; argc++)
    80005c88:	4481                	li	s1,0
  ustack[argc] = 0;
    80005c8a:	00349793          	slli	a5,s1,0x3
    80005c8e:	f9040713          	addi	a4,s0,-112
    80005c92:	97ba                	add	a5,a5,a4
    80005c94:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffcbef8>
  sp -= (argc + 1) * sizeof(uint64);
    80005c98:	00148693          	addi	a3,s1,1
    80005c9c:	068e                	slli	a3,a3,0x3
    80005c9e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005ca2:	ff097913          	andi	s2,s2,-16
  if (sp < stackbase)
    80005ca6:	01597663          	bgeu	s2,s5,80005cb2 <exec+0x250>
  sz = sz1;
    80005caa:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005cae:	4a81                	li	s5,0
    80005cb0:	a045                	j	80005d50 <exec+0x2ee>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    80005cb2:	e8840613          	addi	a2,s0,-376
    80005cb6:	85ca                	mv	a1,s2
    80005cb8:	855a                	mv	a0,s6
    80005cba:	ffffb097          	auipc	ra,0xffffb
    80005cbe:	6d8080e7          	jalr	1752(ra) # 80001392 <copyout>
    80005cc2:	0c054363          	bltz	a0,80005d88 <exec+0x326>
  p->trapframe->a1 = sp;
    80005cc6:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80005cca:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    80005cce:	de843783          	ld	a5,-536(s0)
    80005cd2:	0007c703          	lbu	a4,0(a5)
    80005cd6:	cf11                	beqz	a4,80005cf2 <exec+0x290>
    80005cd8:	0785                	addi	a5,a5,1
    if (*s == '/')
    80005cda:	02f00693          	li	a3,47
    80005cde:	a039                	j	80005cec <exec+0x28a>
      last = s + 1;
    80005ce0:	def43423          	sd	a5,-536(s0)
  for (last = s = path; *s; s++)
    80005ce4:	0785                	addi	a5,a5,1
    80005ce6:	fff7c703          	lbu	a4,-1(a5)
    80005cea:	c701                	beqz	a4,80005cf2 <exec+0x290>
    if (*s == '/')
    80005cec:	fed71ce3          	bne	a4,a3,80005ce4 <exec+0x282>
    80005cf0:	bfc5                	j	80005ce0 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005cf2:	4641                	li	a2,16
    80005cf4:	de843583          	ld	a1,-536(s0)
    80005cf8:	158b8513          	addi	a0,s7,344
    80005cfc:	ffffb097          	auipc	ra,0xffffb
    80005d00:	114080e7          	jalr	276(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005d04:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005d08:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005d0c:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry; // initial program counter = main
    80005d10:	058bb783          	ld	a5,88(s7)
    80005d14:	e6043703          	ld	a4,-416(s0)
    80005d18:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80005d1a:	058bb783          	ld	a5,88(s7)
    80005d1e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz); // also remove swapfile
    80005d22:	85ea                	mv	a1,s10
    80005d24:	ffffc097          	auipc	ra,0xffffc
    80005d28:	14c080e7          	jalr	332(ra) # 80001e70 <proc_freepagetable>
  if(p->pid >2){
    80005d2c:	030ba703          	lw	a4,48(s7)
    80005d30:	4789                	li	a5,2
    80005d32:	00e7da63          	bge	a5,a4,80005d46 <exec+0x2e4>
    p->physical_pages_num = 0;
    80005d36:	160ba823          	sw	zero,368(s7)
    p->total_pages_num = 0;
    80005d3a:	160baa23          	sw	zero,372(s7)
    p->pages_physc_info.free_spaces = 0;
    80005d3e:	300b9023          	sh	zero,768(s7)
    p->pages_swap_info.free_spaces = 0;
    80005d42:	160b9c23          	sh	zero,376(s7)
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005d46:	0004851b          	sext.w	a0,s1
    80005d4a:	bb55                	j	80005afe <exec+0x9c>
    80005d4c:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005d50:	df843583          	ld	a1,-520(s0)
    80005d54:	855a                	mv	a0,s6
    80005d56:	ffffc097          	auipc	ra,0xffffc
    80005d5a:	11a080e7          	jalr	282(ra) # 80001e70 <proc_freepagetable>
  if (ip)
    80005d5e:	d80a96e3          	bnez	s5,80005aea <exec+0x88>
  return -1;
    80005d62:	557d                	li	a0,-1
    80005d64:	bb69                	j	80005afe <exec+0x9c>
    80005d66:	de943c23          	sd	s1,-520(s0)
    80005d6a:	b7dd                	j	80005d50 <exec+0x2ee>
    80005d6c:	de943c23          	sd	s1,-520(s0)
    80005d70:	b7c5                	j	80005d50 <exec+0x2ee>
    80005d72:	de943c23          	sd	s1,-520(s0)
    80005d76:	bfe9                	j	80005d50 <exec+0x2ee>
  sz = sz1;
    80005d78:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005d7c:	4a81                	li	s5,0
    80005d7e:	bfc9                	j	80005d50 <exec+0x2ee>
  sz = sz1;
    80005d80:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005d84:	4a81                	li	s5,0
    80005d86:	b7e9                	j	80005d50 <exec+0x2ee>
  sz = sz1;
    80005d88:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005d8c:	4a81                	li	s5,0
    80005d8e:	b7c9                	j	80005d50 <exec+0x2ee>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005d90:	df843483          	ld	s1,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005d94:	e0843783          	ld	a5,-504(s0)
    80005d98:	0017869b          	addiw	a3,a5,1
    80005d9c:	e0d43423          	sd	a3,-504(s0)
    80005da0:	e0043783          	ld	a5,-512(s0)
    80005da4:	0387879b          	addiw	a5,a5,56
    80005da8:	e8045703          	lhu	a4,-384(s0)
    80005dac:	e0e6d6e3          	bge	a3,a4,80005bb8 <exec+0x156>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005db0:	2781                	sext.w	a5,a5
    80005db2:	e0f43023          	sd	a5,-512(s0)
    80005db6:	03800713          	li	a4,56
    80005dba:	86be                	mv	a3,a5
    80005dbc:	e1040613          	addi	a2,s0,-496
    80005dc0:	4581                	li	a1,0
    80005dc2:	8556                	mv	a0,s5
    80005dc4:	ffffe097          	auipc	ra,0xffffe
    80005dc8:	556080e7          	jalr	1366(ra) # 8000431a <readi>
    80005dcc:	03800793          	li	a5,56
    80005dd0:	f6f51ee3          	bne	a0,a5,80005d4c <exec+0x2ea>
    if (ph.type != ELF_PROG_LOAD)
    80005dd4:	e1042783          	lw	a5,-496(s0)
    80005dd8:	4705                	li	a4,1
    80005dda:	fae79de3          	bne	a5,a4,80005d94 <exec+0x332>
    if (ph.memsz < ph.filesz)
    80005dde:	e3843603          	ld	a2,-456(s0)
    80005de2:	e3043783          	ld	a5,-464(s0)
    80005de6:	f8f660e3          	bltu	a2,a5,80005d66 <exec+0x304>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80005dea:	e2043783          	ld	a5,-480(s0)
    80005dee:	963e                	add	a2,a2,a5
    80005df0:	f6f66ee3          	bltu	a2,a5,80005d6c <exec+0x30a>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005df4:	85a6                	mv	a1,s1
    80005df6:	855a                	mv	a0,s6
    80005df8:	ffffc097          	auipc	ra,0xffffc
    80005dfc:	b0a080e7          	jalr	-1270(ra) # 80001902 <uvmalloc>
    80005e00:	dea43c23          	sd	a0,-520(s0)
    80005e04:	d53d                	beqz	a0,80005d72 <exec+0x310>
    if (ph.vaddr % PGSIZE != 0)
    80005e06:	e2043c03          	ld	s8,-480(s0)
    80005e0a:	de043783          	ld	a5,-544(s0)
    80005e0e:	00fc77b3          	and	a5,s8,a5
    80005e12:	ff9d                	bnez	a5,80005d50 <exec+0x2ee>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005e14:	e1842c83          	lw	s9,-488(s0)
    80005e18:	e3042b83          	lw	s7,-464(s0)
  for (i = 0; i < sz; i += PGSIZE)
    80005e1c:	f60b8ae3          	beqz	s7,80005d90 <exec+0x32e>
    80005e20:	89de                	mv	s3,s7
    80005e22:	4481                	li	s1,0
    80005e24:	bb85                	j	80005b94 <exec+0x132>

0000000080005e26 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005e26:	7179                	addi	sp,sp,-48
    80005e28:	f406                	sd	ra,40(sp)
    80005e2a:	f022                	sd	s0,32(sp)
    80005e2c:	ec26                	sd	s1,24(sp)
    80005e2e:	e84a                	sd	s2,16(sp)
    80005e30:	1800                	addi	s0,sp,48
    80005e32:	892e                	mv	s2,a1
    80005e34:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005e36:	fdc40593          	addi	a1,s0,-36
    80005e3a:	ffffd097          	auipc	ra,0xffffd
    80005e3e:	6ba080e7          	jalr	1722(ra) # 800034f4 <argint>
    80005e42:	04054063          	bltz	a0,80005e82 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005e46:	fdc42703          	lw	a4,-36(s0)
    80005e4a:	47bd                	li	a5,15
    80005e4c:	02e7ed63          	bltu	a5,a4,80005e86 <argfd+0x60>
    80005e50:	ffffc097          	auipc	ra,0xffffc
    80005e54:	ec0080e7          	jalr	-320(ra) # 80001d10 <myproc>
    80005e58:	fdc42703          	lw	a4,-36(s0)
    80005e5c:	01a70793          	addi	a5,a4,26
    80005e60:	078e                	slli	a5,a5,0x3
    80005e62:	953e                	add	a0,a0,a5
    80005e64:	611c                	ld	a5,0(a0)
    80005e66:	c395                	beqz	a5,80005e8a <argfd+0x64>
    return -1;
  if(pfd)
    80005e68:	00090463          	beqz	s2,80005e70 <argfd+0x4a>
    *pfd = fd;
    80005e6c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005e70:	4501                	li	a0,0
  if(pf)
    80005e72:	c091                	beqz	s1,80005e76 <argfd+0x50>
    *pf = f;
    80005e74:	e09c                	sd	a5,0(s1)
}
    80005e76:	70a2                	ld	ra,40(sp)
    80005e78:	7402                	ld	s0,32(sp)
    80005e7a:	64e2                	ld	s1,24(sp)
    80005e7c:	6942                	ld	s2,16(sp)
    80005e7e:	6145                	addi	sp,sp,48
    80005e80:	8082                	ret
    return -1;
    80005e82:	557d                	li	a0,-1
    80005e84:	bfcd                	j	80005e76 <argfd+0x50>
    return -1;
    80005e86:	557d                	li	a0,-1
    80005e88:	b7fd                	j	80005e76 <argfd+0x50>
    80005e8a:	557d                	li	a0,-1
    80005e8c:	b7ed                	j	80005e76 <argfd+0x50>

0000000080005e8e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005e8e:	1101                	addi	sp,sp,-32
    80005e90:	ec06                	sd	ra,24(sp)
    80005e92:	e822                	sd	s0,16(sp)
    80005e94:	e426                	sd	s1,8(sp)
    80005e96:	1000                	addi	s0,sp,32
    80005e98:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005e9a:	ffffc097          	auipc	ra,0xffffc
    80005e9e:	e76080e7          	jalr	-394(ra) # 80001d10 <myproc>
    80005ea2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005ea4:	0d050793          	addi	a5,a0,208
    80005ea8:	4501                	li	a0,0
    80005eaa:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005eac:	6398                	ld	a4,0(a5)
    80005eae:	cb19                	beqz	a4,80005ec4 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005eb0:	2505                	addiw	a0,a0,1
    80005eb2:	07a1                	addi	a5,a5,8
    80005eb4:	fed51ce3          	bne	a0,a3,80005eac <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005eb8:	557d                	li	a0,-1
}
    80005eba:	60e2                	ld	ra,24(sp)
    80005ebc:	6442                	ld	s0,16(sp)
    80005ebe:	64a2                	ld	s1,8(sp)
    80005ec0:	6105                	addi	sp,sp,32
    80005ec2:	8082                	ret
      p->ofile[fd] = f;
    80005ec4:	01a50793          	addi	a5,a0,26
    80005ec8:	078e                	slli	a5,a5,0x3
    80005eca:	963e                	add	a2,a2,a5
    80005ecc:	e204                	sd	s1,0(a2)
      return fd;
    80005ece:	b7f5                	j	80005eba <fdalloc+0x2c>

0000000080005ed0 <sys_dup>:

uint64
sys_dup(void)
{
    80005ed0:	7179                	addi	sp,sp,-48
    80005ed2:	f406                	sd	ra,40(sp)
    80005ed4:	f022                	sd	s0,32(sp)
    80005ed6:	ec26                	sd	s1,24(sp)
    80005ed8:	1800                	addi	s0,sp,48
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    80005eda:	fd840613          	addi	a2,s0,-40
    80005ede:	4581                	li	a1,0
    80005ee0:	4501                	li	a0,0
    80005ee2:	00000097          	auipc	ra,0x0
    80005ee6:	f44080e7          	jalr	-188(ra) # 80005e26 <argfd>
    return -1;
    80005eea:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005eec:	02054363          	bltz	a0,80005f12 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005ef0:	fd843503          	ld	a0,-40(s0)
    80005ef4:	00000097          	auipc	ra,0x0
    80005ef8:	f9a080e7          	jalr	-102(ra) # 80005e8e <fdalloc>
    80005efc:	84aa                	mv	s1,a0
    return -1;
    80005efe:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005f00:	00054963          	bltz	a0,80005f12 <sys_dup+0x42>
  filedup(f);
    80005f04:	fd843503          	ld	a0,-40(s0)
    80005f08:	fffff097          	auipc	ra,0xfffff
    80005f0c:	2c0080e7          	jalr	704(ra) # 800051c8 <filedup>
  return fd;
    80005f10:	87a6                	mv	a5,s1
}
    80005f12:	853e                	mv	a0,a5
    80005f14:	70a2                	ld	ra,40(sp)
    80005f16:	7402                	ld	s0,32(sp)
    80005f18:	64e2                	ld	s1,24(sp)
    80005f1a:	6145                	addi	sp,sp,48
    80005f1c:	8082                	ret

0000000080005f1e <sys_read>:

uint64
sys_read(void)
{
    80005f1e:	7179                	addi	sp,sp,-48
    80005f20:	f406                	sd	ra,40(sp)
    80005f22:	f022                	sd	s0,32(sp)
    80005f24:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f26:	fe840613          	addi	a2,s0,-24
    80005f2a:	4581                	li	a1,0
    80005f2c:	4501                	li	a0,0
    80005f2e:	00000097          	auipc	ra,0x0
    80005f32:	ef8080e7          	jalr	-264(ra) # 80005e26 <argfd>
    return -1;
    80005f36:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f38:	04054163          	bltz	a0,80005f7a <sys_read+0x5c>
    80005f3c:	fe440593          	addi	a1,s0,-28
    80005f40:	4509                	li	a0,2
    80005f42:	ffffd097          	auipc	ra,0xffffd
    80005f46:	5b2080e7          	jalr	1458(ra) # 800034f4 <argint>
    return -1;
    80005f4a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f4c:	02054763          	bltz	a0,80005f7a <sys_read+0x5c>
    80005f50:	fd840593          	addi	a1,s0,-40
    80005f54:	4505                	li	a0,1
    80005f56:	ffffd097          	auipc	ra,0xffffd
    80005f5a:	5c0080e7          	jalr	1472(ra) # 80003516 <argaddr>
    return -1;
    80005f5e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f60:	00054d63          	bltz	a0,80005f7a <sys_read+0x5c>
  return fileread(f, p, n);
    80005f64:	fe442603          	lw	a2,-28(s0)
    80005f68:	fd843583          	ld	a1,-40(s0)
    80005f6c:	fe843503          	ld	a0,-24(s0)
    80005f70:	fffff097          	auipc	ra,0xfffff
    80005f74:	3e4080e7          	jalr	996(ra) # 80005354 <fileread>
    80005f78:	87aa                	mv	a5,a0
}
    80005f7a:	853e                	mv	a0,a5
    80005f7c:	70a2                	ld	ra,40(sp)
    80005f7e:	7402                	ld	s0,32(sp)
    80005f80:	6145                	addi	sp,sp,48
    80005f82:	8082                	ret

0000000080005f84 <sys_write>:

uint64
sys_write(void)
{
    80005f84:	7179                	addi	sp,sp,-48
    80005f86:	f406                	sd	ra,40(sp)
    80005f88:	f022                	sd	s0,32(sp)
    80005f8a:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f8c:	fe840613          	addi	a2,s0,-24
    80005f90:	4581                	li	a1,0
    80005f92:	4501                	li	a0,0
    80005f94:	00000097          	auipc	ra,0x0
    80005f98:	e92080e7          	jalr	-366(ra) # 80005e26 <argfd>
    return -1;
    80005f9c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f9e:	04054163          	bltz	a0,80005fe0 <sys_write+0x5c>
    80005fa2:	fe440593          	addi	a1,s0,-28
    80005fa6:	4509                	li	a0,2
    80005fa8:	ffffd097          	auipc	ra,0xffffd
    80005fac:	54c080e7          	jalr	1356(ra) # 800034f4 <argint>
    return -1;
    80005fb0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005fb2:	02054763          	bltz	a0,80005fe0 <sys_write+0x5c>
    80005fb6:	fd840593          	addi	a1,s0,-40
    80005fba:	4505                	li	a0,1
    80005fbc:	ffffd097          	auipc	ra,0xffffd
    80005fc0:	55a080e7          	jalr	1370(ra) # 80003516 <argaddr>
    return -1;
    80005fc4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005fc6:	00054d63          	bltz	a0,80005fe0 <sys_write+0x5c>

  return filewrite(f, p, n);
    80005fca:	fe442603          	lw	a2,-28(s0)
    80005fce:	fd843583          	ld	a1,-40(s0)
    80005fd2:	fe843503          	ld	a0,-24(s0)
    80005fd6:	fffff097          	auipc	ra,0xfffff
    80005fda:	440080e7          	jalr	1088(ra) # 80005416 <filewrite>
    80005fde:	87aa                	mv	a5,a0
}
    80005fe0:	853e                	mv	a0,a5
    80005fe2:	70a2                	ld	ra,40(sp)
    80005fe4:	7402                	ld	s0,32(sp)
    80005fe6:	6145                	addi	sp,sp,48
    80005fe8:	8082                	ret

0000000080005fea <sys_close>:

uint64
sys_close(void)
{
    80005fea:	1101                	addi	sp,sp,-32
    80005fec:	ec06                	sd	ra,24(sp)
    80005fee:	e822                	sd	s0,16(sp)
    80005ff0:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    80005ff2:	fe040613          	addi	a2,s0,-32
    80005ff6:	fec40593          	addi	a1,s0,-20
    80005ffa:	4501                	li	a0,0
    80005ffc:	00000097          	auipc	ra,0x0
    80006000:	e2a080e7          	jalr	-470(ra) # 80005e26 <argfd>
    return -1;
    80006004:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80006006:	02054463          	bltz	a0,8000602e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000600a:	ffffc097          	auipc	ra,0xffffc
    8000600e:	d06080e7          	jalr	-762(ra) # 80001d10 <myproc>
    80006012:	fec42783          	lw	a5,-20(s0)
    80006016:	07e9                	addi	a5,a5,26
    80006018:	078e                	slli	a5,a5,0x3
    8000601a:	97aa                	add	a5,a5,a0
    8000601c:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80006020:	fe043503          	ld	a0,-32(s0)
    80006024:	fffff097          	auipc	ra,0xfffff
    80006028:	1f6080e7          	jalr	502(ra) # 8000521a <fileclose>
  return 0;
    8000602c:	4781                	li	a5,0
}
    8000602e:	853e                	mv	a0,a5
    80006030:	60e2                	ld	ra,24(sp)
    80006032:	6442                	ld	s0,16(sp)
    80006034:	6105                	addi	sp,sp,32
    80006036:	8082                	ret

0000000080006038 <sys_fstat>:

uint64
sys_fstat(void)
{
    80006038:	1101                	addi	sp,sp,-32
    8000603a:	ec06                	sd	ra,24(sp)
    8000603c:	e822                	sd	s0,16(sp)
    8000603e:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006040:	fe840613          	addi	a2,s0,-24
    80006044:	4581                	li	a1,0
    80006046:	4501                	li	a0,0
    80006048:	00000097          	auipc	ra,0x0
    8000604c:	dde080e7          	jalr	-546(ra) # 80005e26 <argfd>
    return -1;
    80006050:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006052:	02054563          	bltz	a0,8000607c <sys_fstat+0x44>
    80006056:	fe040593          	addi	a1,s0,-32
    8000605a:	4505                	li	a0,1
    8000605c:	ffffd097          	auipc	ra,0xffffd
    80006060:	4ba080e7          	jalr	1210(ra) # 80003516 <argaddr>
    return -1;
    80006064:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006066:	00054b63          	bltz	a0,8000607c <sys_fstat+0x44>
  return filestat(f, st);
    8000606a:	fe043583          	ld	a1,-32(s0)
    8000606e:	fe843503          	ld	a0,-24(s0)
    80006072:	fffff097          	auipc	ra,0xfffff
    80006076:	270080e7          	jalr	624(ra) # 800052e2 <filestat>
    8000607a:	87aa                	mv	a5,a0
}
    8000607c:	853e                	mv	a0,a5
    8000607e:	60e2                	ld	ra,24(sp)
    80006080:	6442                	ld	s0,16(sp)
    80006082:	6105                	addi	sp,sp,32
    80006084:	8082                	ret

0000000080006086 <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    80006086:	7169                	addi	sp,sp,-304
    80006088:	f606                	sd	ra,296(sp)
    8000608a:	f222                	sd	s0,288(sp)
    8000608c:	ee26                	sd	s1,280(sp)
    8000608e:	ea4a                	sd	s2,272(sp)
    80006090:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006092:	08000613          	li	a2,128
    80006096:	ed040593          	addi	a1,s0,-304
    8000609a:	4501                	li	a0,0
    8000609c:	ffffd097          	auipc	ra,0xffffd
    800060a0:	49c080e7          	jalr	1180(ra) # 80003538 <argstr>
    return -1;
    800060a4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800060a6:	10054e63          	bltz	a0,800061c2 <sys_link+0x13c>
    800060aa:	08000613          	li	a2,128
    800060ae:	f5040593          	addi	a1,s0,-176
    800060b2:	4505                	li	a0,1
    800060b4:	ffffd097          	auipc	ra,0xffffd
    800060b8:	484080e7          	jalr	1156(ra) # 80003538 <argstr>
    return -1;
    800060bc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800060be:	10054263          	bltz	a0,800061c2 <sys_link+0x13c>

  begin_op();
    800060c2:	fffff097          	auipc	ra,0xfffff
    800060c6:	c8c080e7          	jalr	-884(ra) # 80004d4e <begin_op>
  if((ip = namei(old)) == 0){
    800060ca:	ed040513          	addi	a0,s0,-304
    800060ce:	ffffe097          	auipc	ra,0xffffe
    800060d2:	74e080e7          	jalr	1870(ra) # 8000481c <namei>
    800060d6:	84aa                	mv	s1,a0
    800060d8:	c551                	beqz	a0,80006164 <sys_link+0xde>
    end_op();
    return -1;
  }

  ilock(ip);
    800060da:	ffffe097          	auipc	ra,0xffffe
    800060de:	f8c080e7          	jalr	-116(ra) # 80004066 <ilock>
  if(ip->type == T_DIR){
    800060e2:	04449703          	lh	a4,68(s1)
    800060e6:	4785                	li	a5,1
    800060e8:	08f70463          	beq	a4,a5,80006170 <sys_link+0xea>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
    800060ec:	04a4d783          	lhu	a5,74(s1)
    800060f0:	2785                	addiw	a5,a5,1
    800060f2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800060f6:	8526                	mv	a0,s1
    800060f8:	ffffe097          	auipc	ra,0xffffe
    800060fc:	ea4080e7          	jalr	-348(ra) # 80003f9c <iupdate>
  iunlock(ip);
    80006100:	8526                	mv	a0,s1
    80006102:	ffffe097          	auipc	ra,0xffffe
    80006106:	026080e7          	jalr	38(ra) # 80004128 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    8000610a:	fd040593          	addi	a1,s0,-48
    8000610e:	f5040513          	addi	a0,s0,-176
    80006112:	ffffe097          	auipc	ra,0xffffe
    80006116:	728080e7          	jalr	1832(ra) # 8000483a <nameiparent>
    8000611a:	892a                	mv	s2,a0
    8000611c:	c935                	beqz	a0,80006190 <sys_link+0x10a>
    goto bad;
  ilock(dp);
    8000611e:	ffffe097          	auipc	ra,0xffffe
    80006122:	f48080e7          	jalr	-184(ra) # 80004066 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80006126:	00092703          	lw	a4,0(s2)
    8000612a:	409c                	lw	a5,0(s1)
    8000612c:	04f71d63          	bne	a4,a5,80006186 <sys_link+0x100>
    80006130:	40d0                	lw	a2,4(s1)
    80006132:	fd040593          	addi	a1,s0,-48
    80006136:	854a                	mv	a0,s2
    80006138:	ffffe097          	auipc	ra,0xffffe
    8000613c:	622080e7          	jalr	1570(ra) # 8000475a <dirlink>
    80006140:	04054363          	bltz	a0,80006186 <sys_link+0x100>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
    80006144:	854a                	mv	a0,s2
    80006146:	ffffe097          	auipc	ra,0xffffe
    8000614a:	182080e7          	jalr	386(ra) # 800042c8 <iunlockput>
  iput(ip);
    8000614e:	8526                	mv	a0,s1
    80006150:	ffffe097          	auipc	ra,0xffffe
    80006154:	0d0080e7          	jalr	208(ra) # 80004220 <iput>

  end_op();
    80006158:	fffff097          	auipc	ra,0xfffff
    8000615c:	c76080e7          	jalr	-906(ra) # 80004dce <end_op>

  return 0;
    80006160:	4781                	li	a5,0
    80006162:	a085                	j	800061c2 <sys_link+0x13c>
    end_op();
    80006164:	fffff097          	auipc	ra,0xfffff
    80006168:	c6a080e7          	jalr	-918(ra) # 80004dce <end_op>
    return -1;
    8000616c:	57fd                	li	a5,-1
    8000616e:	a891                	j	800061c2 <sys_link+0x13c>
    iunlockput(ip);
    80006170:	8526                	mv	a0,s1
    80006172:	ffffe097          	auipc	ra,0xffffe
    80006176:	156080e7          	jalr	342(ra) # 800042c8 <iunlockput>
    end_op();
    8000617a:	fffff097          	auipc	ra,0xfffff
    8000617e:	c54080e7          	jalr	-940(ra) # 80004dce <end_op>
    return -1;
    80006182:	57fd                	li	a5,-1
    80006184:	a83d                	j	800061c2 <sys_link+0x13c>
    iunlockput(dp);
    80006186:	854a                	mv	a0,s2
    80006188:	ffffe097          	auipc	ra,0xffffe
    8000618c:	140080e7          	jalr	320(ra) # 800042c8 <iunlockput>

bad:
  ilock(ip);
    80006190:	8526                	mv	a0,s1
    80006192:	ffffe097          	auipc	ra,0xffffe
    80006196:	ed4080e7          	jalr	-300(ra) # 80004066 <ilock>
  ip->nlink--;
    8000619a:	04a4d783          	lhu	a5,74(s1)
    8000619e:	37fd                	addiw	a5,a5,-1
    800061a0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800061a4:	8526                	mv	a0,s1
    800061a6:	ffffe097          	auipc	ra,0xffffe
    800061aa:	df6080e7          	jalr	-522(ra) # 80003f9c <iupdate>
  iunlockput(ip);
    800061ae:	8526                	mv	a0,s1
    800061b0:	ffffe097          	auipc	ra,0xffffe
    800061b4:	118080e7          	jalr	280(ra) # 800042c8 <iunlockput>
  end_op();
    800061b8:	fffff097          	auipc	ra,0xfffff
    800061bc:	c16080e7          	jalr	-1002(ra) # 80004dce <end_op>
  return -1;
    800061c0:	57fd                	li	a5,-1
}
    800061c2:	853e                	mv	a0,a5
    800061c4:	70b2                	ld	ra,296(sp)
    800061c6:	7412                	ld	s0,288(sp)
    800061c8:	64f2                	ld	s1,280(sp)
    800061ca:	6952                	ld	s2,272(sp)
    800061cc:	6155                	addi	sp,sp,304
    800061ce:	8082                	ret

00000000800061d0 <isdirempty>:
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800061d0:	4578                	lw	a4,76(a0)
    800061d2:	02000793          	li	a5,32
    800061d6:	04e7fa63          	bgeu	a5,a4,8000622a <isdirempty+0x5a>
{
    800061da:	7179                	addi	sp,sp,-48
    800061dc:	f406                	sd	ra,40(sp)
    800061de:	f022                	sd	s0,32(sp)
    800061e0:	ec26                	sd	s1,24(sp)
    800061e2:	e84a                	sd	s2,16(sp)
    800061e4:	1800                	addi	s0,sp,48
    800061e6:	892a                	mv	s2,a0
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800061e8:	02000493          	li	s1,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800061ec:	4741                	li	a4,16
    800061ee:	86a6                	mv	a3,s1
    800061f0:	fd040613          	addi	a2,s0,-48
    800061f4:	4581                	li	a1,0
    800061f6:	854a                	mv	a0,s2
    800061f8:	ffffe097          	auipc	ra,0xffffe
    800061fc:	122080e7          	jalr	290(ra) # 8000431a <readi>
    80006200:	47c1                	li	a5,16
    80006202:	00f51c63          	bne	a0,a5,8000621a <isdirempty+0x4a>
      panic("isdirempty: readi");
    if(de.inum != 0)
    80006206:	fd045783          	lhu	a5,-48(s0)
    8000620a:	e395                	bnez	a5,8000622e <isdirempty+0x5e>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000620c:	24c1                	addiw	s1,s1,16
    8000620e:	04c92783          	lw	a5,76(s2)
    80006212:	fcf4ede3          	bltu	s1,a5,800061ec <isdirempty+0x1c>
      return 0;
  }
  return 1;
    80006216:	4505                	li	a0,1
    80006218:	a821                	j	80006230 <isdirempty+0x60>
      panic("isdirempty: readi");
    8000621a:	00004517          	auipc	a0,0x4
    8000621e:	a0e50513          	addi	a0,a0,-1522 # 80009c28 <syscalls+0x310>
    80006222:	ffffa097          	auipc	ra,0xffffa
    80006226:	308080e7          	jalr	776(ra) # 8000052a <panic>
  return 1;
    8000622a:	4505                	li	a0,1
}
    8000622c:	8082                	ret
      return 0;
    8000622e:	4501                	li	a0,0
}
    80006230:	70a2                	ld	ra,40(sp)
    80006232:	7402                	ld	s0,32(sp)
    80006234:	64e2                	ld	s1,24(sp)
    80006236:	6942                	ld	s2,16(sp)
    80006238:	6145                	addi	sp,sp,48
    8000623a:	8082                	ret

000000008000623c <sys_unlink>:

uint64
sys_unlink(void)
{
    8000623c:	7155                	addi	sp,sp,-208
    8000623e:	e586                	sd	ra,200(sp)
    80006240:	e1a2                	sd	s0,192(sp)
    80006242:	fd26                	sd	s1,184(sp)
    80006244:	f94a                	sd	s2,176(sp)
    80006246:	0980                	addi	s0,sp,208
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    80006248:	08000613          	li	a2,128
    8000624c:	f4040593          	addi	a1,s0,-192
    80006250:	4501                	li	a0,0
    80006252:	ffffd097          	auipc	ra,0xffffd
    80006256:	2e6080e7          	jalr	742(ra) # 80003538 <argstr>
    8000625a:	16054363          	bltz	a0,800063c0 <sys_unlink+0x184>
    return -1;

  begin_op();
    8000625e:	fffff097          	auipc	ra,0xfffff
    80006262:	af0080e7          	jalr	-1296(ra) # 80004d4e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80006266:	fc040593          	addi	a1,s0,-64
    8000626a:	f4040513          	addi	a0,s0,-192
    8000626e:	ffffe097          	auipc	ra,0xffffe
    80006272:	5cc080e7          	jalr	1484(ra) # 8000483a <nameiparent>
    80006276:	84aa                	mv	s1,a0
    80006278:	c961                	beqz	a0,80006348 <sys_unlink+0x10c>
    end_op();
    return -1;
  }

  ilock(dp);
    8000627a:	ffffe097          	auipc	ra,0xffffe
    8000627e:	dec080e7          	jalr	-532(ra) # 80004066 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006282:	00004597          	auipc	a1,0x4
    80006286:	88658593          	addi	a1,a1,-1914 # 80009b08 <syscalls+0x1f0>
    8000628a:	fc040513          	addi	a0,s0,-64
    8000628e:	ffffe097          	auipc	ra,0xffffe
    80006292:	2a2080e7          	jalr	674(ra) # 80004530 <namecmp>
    80006296:	c175                	beqz	a0,8000637a <sys_unlink+0x13e>
    80006298:	00004597          	auipc	a1,0x4
    8000629c:	87858593          	addi	a1,a1,-1928 # 80009b10 <syscalls+0x1f8>
    800062a0:	fc040513          	addi	a0,s0,-64
    800062a4:	ffffe097          	auipc	ra,0xffffe
    800062a8:	28c080e7          	jalr	652(ra) # 80004530 <namecmp>
    800062ac:	c579                	beqz	a0,8000637a <sys_unlink+0x13e>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    800062ae:	f3c40613          	addi	a2,s0,-196
    800062b2:	fc040593          	addi	a1,s0,-64
    800062b6:	8526                	mv	a0,s1
    800062b8:	ffffe097          	auipc	ra,0xffffe
    800062bc:	292080e7          	jalr	658(ra) # 8000454a <dirlookup>
    800062c0:	892a                	mv	s2,a0
    800062c2:	cd45                	beqz	a0,8000637a <sys_unlink+0x13e>
    goto bad;
  ilock(ip);
    800062c4:	ffffe097          	auipc	ra,0xffffe
    800062c8:	da2080e7          	jalr	-606(ra) # 80004066 <ilock>

  if(ip->nlink < 1)
    800062cc:	04a91783          	lh	a5,74(s2)
    800062d0:	08f05263          	blez	a5,80006354 <sys_unlink+0x118>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    800062d4:	04491703          	lh	a4,68(s2)
    800062d8:	4785                	li	a5,1
    800062da:	08f70563          	beq	a4,a5,80006364 <sys_unlink+0x128>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    800062de:	4641                	li	a2,16
    800062e0:	4581                	li	a1,0
    800062e2:	fd040513          	addi	a0,s0,-48
    800062e6:	ffffb097          	auipc	ra,0xffffb
    800062ea:	9d8080e7          	jalr	-1576(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800062ee:	4741                	li	a4,16
    800062f0:	f3c42683          	lw	a3,-196(s0)
    800062f4:	fd040613          	addi	a2,s0,-48
    800062f8:	4581                	li	a1,0
    800062fa:	8526                	mv	a0,s1
    800062fc:	ffffe097          	auipc	ra,0xffffe
    80006300:	116080e7          	jalr	278(ra) # 80004412 <writei>
    80006304:	47c1                	li	a5,16
    80006306:	08f51a63          	bne	a0,a5,8000639a <sys_unlink+0x15e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    8000630a:	04491703          	lh	a4,68(s2)
    8000630e:	4785                	li	a5,1
    80006310:	08f70d63          	beq	a4,a5,800063aa <sys_unlink+0x16e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    80006314:	8526                	mv	a0,s1
    80006316:	ffffe097          	auipc	ra,0xffffe
    8000631a:	fb2080e7          	jalr	-78(ra) # 800042c8 <iunlockput>

  ip->nlink--;
    8000631e:	04a95783          	lhu	a5,74(s2)
    80006322:	37fd                	addiw	a5,a5,-1
    80006324:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80006328:	854a                	mv	a0,s2
    8000632a:	ffffe097          	auipc	ra,0xffffe
    8000632e:	c72080e7          	jalr	-910(ra) # 80003f9c <iupdate>
  iunlockput(ip);
    80006332:	854a                	mv	a0,s2
    80006334:	ffffe097          	auipc	ra,0xffffe
    80006338:	f94080e7          	jalr	-108(ra) # 800042c8 <iunlockput>

  end_op();
    8000633c:	fffff097          	auipc	ra,0xfffff
    80006340:	a92080e7          	jalr	-1390(ra) # 80004dce <end_op>

  return 0;
    80006344:	4501                	li	a0,0
    80006346:	a0a1                	j	8000638e <sys_unlink+0x152>
    end_op();
    80006348:	fffff097          	auipc	ra,0xfffff
    8000634c:	a86080e7          	jalr	-1402(ra) # 80004dce <end_op>
    return -1;
    80006350:	557d                	li	a0,-1
    80006352:	a835                	j	8000638e <sys_unlink+0x152>
    panic("unlink: nlink < 1");
    80006354:	00003517          	auipc	a0,0x3
    80006358:	7c450513          	addi	a0,a0,1988 # 80009b18 <syscalls+0x200>
    8000635c:	ffffa097          	auipc	ra,0xffffa
    80006360:	1ce080e7          	jalr	462(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006364:	854a                	mv	a0,s2
    80006366:	00000097          	auipc	ra,0x0
    8000636a:	e6a080e7          	jalr	-406(ra) # 800061d0 <isdirempty>
    8000636e:	f925                	bnez	a0,800062de <sys_unlink+0xa2>
    iunlockput(ip);
    80006370:	854a                	mv	a0,s2
    80006372:	ffffe097          	auipc	ra,0xffffe
    80006376:	f56080e7          	jalr	-170(ra) # 800042c8 <iunlockput>

bad:
  iunlockput(dp);
    8000637a:	8526                	mv	a0,s1
    8000637c:	ffffe097          	auipc	ra,0xffffe
    80006380:	f4c080e7          	jalr	-180(ra) # 800042c8 <iunlockput>
  end_op();
    80006384:	fffff097          	auipc	ra,0xfffff
    80006388:	a4a080e7          	jalr	-1462(ra) # 80004dce <end_op>
  return -1;
    8000638c:	557d                	li	a0,-1
}
    8000638e:	60ae                	ld	ra,200(sp)
    80006390:	640e                	ld	s0,192(sp)
    80006392:	74ea                	ld	s1,184(sp)
    80006394:	794a                	ld	s2,176(sp)
    80006396:	6169                	addi	sp,sp,208
    80006398:	8082                	ret
    panic("unlink: writei");
    8000639a:	00003517          	auipc	a0,0x3
    8000639e:	79650513          	addi	a0,a0,1942 # 80009b30 <syscalls+0x218>
    800063a2:	ffffa097          	auipc	ra,0xffffa
    800063a6:	188080e7          	jalr	392(ra) # 8000052a <panic>
    dp->nlink--;
    800063aa:	04a4d783          	lhu	a5,74(s1)
    800063ae:	37fd                	addiw	a5,a5,-1
    800063b0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800063b4:	8526                	mv	a0,s1
    800063b6:	ffffe097          	auipc	ra,0xffffe
    800063ba:	be6080e7          	jalr	-1050(ra) # 80003f9c <iupdate>
    800063be:	bf99                	j	80006314 <sys_unlink+0xd8>
    return -1;
    800063c0:	557d                	li	a0,-1
    800063c2:	b7f1                	j	8000638e <sys_unlink+0x152>

00000000800063c4 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
    800063c4:	715d                	addi	sp,sp,-80
    800063c6:	e486                	sd	ra,72(sp)
    800063c8:	e0a2                	sd	s0,64(sp)
    800063ca:	fc26                	sd	s1,56(sp)
    800063cc:	f84a                	sd	s2,48(sp)
    800063ce:	f44e                	sd	s3,40(sp)
    800063d0:	f052                	sd	s4,32(sp)
    800063d2:	ec56                	sd	s5,24(sp)
    800063d4:	0880                	addi	s0,sp,80
    800063d6:	89ae                	mv	s3,a1
    800063d8:	8ab2                	mv	s5,a2
    800063da:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800063dc:	fb040593          	addi	a1,s0,-80
    800063e0:	ffffe097          	auipc	ra,0xffffe
    800063e4:	45a080e7          	jalr	1114(ra) # 8000483a <nameiparent>
    800063e8:	892a                	mv	s2,a0
    800063ea:	12050e63          	beqz	a0,80006526 <create+0x162>
    return 0;

  ilock(dp);
    800063ee:	ffffe097          	auipc	ra,0xffffe
    800063f2:	c78080e7          	jalr	-904(ra) # 80004066 <ilock>
  
  if((ip = dirlookup(dp, name, 0)) != 0){
    800063f6:	4601                	li	a2,0
    800063f8:	fb040593          	addi	a1,s0,-80
    800063fc:	854a                	mv	a0,s2
    800063fe:	ffffe097          	auipc	ra,0xffffe
    80006402:	14c080e7          	jalr	332(ra) # 8000454a <dirlookup>
    80006406:	84aa                	mv	s1,a0
    80006408:	c921                	beqz	a0,80006458 <create+0x94>
    iunlockput(dp);
    8000640a:	854a                	mv	a0,s2
    8000640c:	ffffe097          	auipc	ra,0xffffe
    80006410:	ebc080e7          	jalr	-324(ra) # 800042c8 <iunlockput>
    ilock(ip);
    80006414:	8526                	mv	a0,s1
    80006416:	ffffe097          	auipc	ra,0xffffe
    8000641a:	c50080e7          	jalr	-944(ra) # 80004066 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000641e:	2981                	sext.w	s3,s3
    80006420:	4789                	li	a5,2
    80006422:	02f99463          	bne	s3,a5,8000644a <create+0x86>
    80006426:	0444d783          	lhu	a5,68(s1)
    8000642a:	37f9                	addiw	a5,a5,-2
    8000642c:	17c2                	slli	a5,a5,0x30
    8000642e:	93c1                	srli	a5,a5,0x30
    80006430:	4705                	li	a4,1
    80006432:	00f76c63          	bltu	a4,a5,8000644a <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80006436:	8526                	mv	a0,s1
    80006438:	60a6                	ld	ra,72(sp)
    8000643a:	6406                	ld	s0,64(sp)
    8000643c:	74e2                	ld	s1,56(sp)
    8000643e:	7942                	ld	s2,48(sp)
    80006440:	79a2                	ld	s3,40(sp)
    80006442:	7a02                	ld	s4,32(sp)
    80006444:	6ae2                	ld	s5,24(sp)
    80006446:	6161                	addi	sp,sp,80
    80006448:	8082                	ret
    iunlockput(ip);
    8000644a:	8526                	mv	a0,s1
    8000644c:	ffffe097          	auipc	ra,0xffffe
    80006450:	e7c080e7          	jalr	-388(ra) # 800042c8 <iunlockput>
    return 0;
    80006454:	4481                	li	s1,0
    80006456:	b7c5                	j	80006436 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80006458:	85ce                	mv	a1,s3
    8000645a:	00092503          	lw	a0,0(s2)
    8000645e:	ffffe097          	auipc	ra,0xffffe
    80006462:	a70080e7          	jalr	-1424(ra) # 80003ece <ialloc>
    80006466:	84aa                	mv	s1,a0
    80006468:	c521                	beqz	a0,800064b0 <create+0xec>
  ilock(ip);
    8000646a:	ffffe097          	auipc	ra,0xffffe
    8000646e:	bfc080e7          	jalr	-1028(ra) # 80004066 <ilock>
  ip->major = major;
    80006472:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80006476:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000647a:	4a05                	li	s4,1
    8000647c:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80006480:	8526                	mv	a0,s1
    80006482:	ffffe097          	auipc	ra,0xffffe
    80006486:	b1a080e7          	jalr	-1254(ra) # 80003f9c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000648a:	2981                	sext.w	s3,s3
    8000648c:	03498a63          	beq	s3,s4,800064c0 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80006490:	40d0                	lw	a2,4(s1)
    80006492:	fb040593          	addi	a1,s0,-80
    80006496:	854a                	mv	a0,s2
    80006498:	ffffe097          	auipc	ra,0xffffe
    8000649c:	2c2080e7          	jalr	706(ra) # 8000475a <dirlink>
    800064a0:	06054b63          	bltz	a0,80006516 <create+0x152>
  iunlockput(dp);
    800064a4:	854a                	mv	a0,s2
    800064a6:	ffffe097          	auipc	ra,0xffffe
    800064aa:	e22080e7          	jalr	-478(ra) # 800042c8 <iunlockput>
  return ip;
    800064ae:	b761                	j	80006436 <create+0x72>
    panic("create: ialloc");
    800064b0:	00003517          	auipc	a0,0x3
    800064b4:	79050513          	addi	a0,a0,1936 # 80009c40 <syscalls+0x328>
    800064b8:	ffffa097          	auipc	ra,0xffffa
    800064bc:	072080e7          	jalr	114(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    800064c0:	04a95783          	lhu	a5,74(s2)
    800064c4:	2785                	addiw	a5,a5,1
    800064c6:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800064ca:	854a                	mv	a0,s2
    800064cc:	ffffe097          	auipc	ra,0xffffe
    800064d0:	ad0080e7          	jalr	-1328(ra) # 80003f9c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800064d4:	40d0                	lw	a2,4(s1)
    800064d6:	00003597          	auipc	a1,0x3
    800064da:	63258593          	addi	a1,a1,1586 # 80009b08 <syscalls+0x1f0>
    800064de:	8526                	mv	a0,s1
    800064e0:	ffffe097          	auipc	ra,0xffffe
    800064e4:	27a080e7          	jalr	634(ra) # 8000475a <dirlink>
    800064e8:	00054f63          	bltz	a0,80006506 <create+0x142>
    800064ec:	00492603          	lw	a2,4(s2)
    800064f0:	00003597          	auipc	a1,0x3
    800064f4:	62058593          	addi	a1,a1,1568 # 80009b10 <syscalls+0x1f8>
    800064f8:	8526                	mv	a0,s1
    800064fa:	ffffe097          	auipc	ra,0xffffe
    800064fe:	260080e7          	jalr	608(ra) # 8000475a <dirlink>
    80006502:	f80557e3          	bgez	a0,80006490 <create+0xcc>
      panic("create dots");
    80006506:	00003517          	auipc	a0,0x3
    8000650a:	74a50513          	addi	a0,a0,1866 # 80009c50 <syscalls+0x338>
    8000650e:	ffffa097          	auipc	ra,0xffffa
    80006512:	01c080e7          	jalr	28(ra) # 8000052a <panic>
    panic("create: dirlink");
    80006516:	00003517          	auipc	a0,0x3
    8000651a:	74a50513          	addi	a0,a0,1866 # 80009c60 <syscalls+0x348>
    8000651e:	ffffa097          	auipc	ra,0xffffa
    80006522:	00c080e7          	jalr	12(ra) # 8000052a <panic>
    return 0;
    80006526:	84aa                	mv	s1,a0
    80006528:	b739                	j	80006436 <create+0x72>

000000008000652a <sys_open>:

uint64
sys_open(void)
{
    8000652a:	7131                	addi	sp,sp,-192
    8000652c:	fd06                	sd	ra,184(sp)
    8000652e:	f922                	sd	s0,176(sp)
    80006530:	f526                	sd	s1,168(sp)
    80006532:	f14a                	sd	s2,160(sp)
    80006534:	ed4e                	sd	s3,152(sp)
    80006536:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006538:	08000613          	li	a2,128
    8000653c:	f5040593          	addi	a1,s0,-176
    80006540:	4501                	li	a0,0
    80006542:	ffffd097          	auipc	ra,0xffffd
    80006546:	ff6080e7          	jalr	-10(ra) # 80003538 <argstr>
    return -1;
    8000654a:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000654c:	0c054163          	bltz	a0,8000660e <sys_open+0xe4>
    80006550:	f4c40593          	addi	a1,s0,-180
    80006554:	4505                	li	a0,1
    80006556:	ffffd097          	auipc	ra,0xffffd
    8000655a:	f9e080e7          	jalr	-98(ra) # 800034f4 <argint>
    8000655e:	0a054863          	bltz	a0,8000660e <sys_open+0xe4>

  begin_op();
    80006562:	ffffe097          	auipc	ra,0xffffe
    80006566:	7ec080e7          	jalr	2028(ra) # 80004d4e <begin_op>

  if(omode & O_CREATE){
    8000656a:	f4c42783          	lw	a5,-180(s0)
    8000656e:	2007f793          	andi	a5,a5,512
    80006572:	cbdd                	beqz	a5,80006628 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80006574:	4681                	li	a3,0
    80006576:	4601                	li	a2,0
    80006578:	4589                	li	a1,2
    8000657a:	f5040513          	addi	a0,s0,-176
    8000657e:	00000097          	auipc	ra,0x0
    80006582:	e46080e7          	jalr	-442(ra) # 800063c4 <create>
    80006586:	892a                	mv	s2,a0
    if(ip == 0){
    80006588:	c959                	beqz	a0,8000661e <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000658a:	04491703          	lh	a4,68(s2)
    8000658e:	478d                	li	a5,3
    80006590:	00f71763          	bne	a4,a5,8000659e <sys_open+0x74>
    80006594:	04695703          	lhu	a4,70(s2)
    80006598:	47a5                	li	a5,9
    8000659a:	0ce7ec63          	bltu	a5,a4,80006672 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000659e:	fffff097          	auipc	ra,0xfffff
    800065a2:	bc0080e7          	jalr	-1088(ra) # 8000515e <filealloc>
    800065a6:	89aa                	mv	s3,a0
    800065a8:	10050263          	beqz	a0,800066ac <sys_open+0x182>
    800065ac:	00000097          	auipc	ra,0x0
    800065b0:	8e2080e7          	jalr	-1822(ra) # 80005e8e <fdalloc>
    800065b4:	84aa                	mv	s1,a0
    800065b6:	0e054663          	bltz	a0,800066a2 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800065ba:	04491703          	lh	a4,68(s2)
    800065be:	478d                	li	a5,3
    800065c0:	0cf70463          	beq	a4,a5,80006688 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800065c4:	4789                	li	a5,2
    800065c6:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800065ca:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800065ce:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800065d2:	f4c42783          	lw	a5,-180(s0)
    800065d6:	0017c713          	xori	a4,a5,1
    800065da:	8b05                	andi	a4,a4,1
    800065dc:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800065e0:	0037f713          	andi	a4,a5,3
    800065e4:	00e03733          	snez	a4,a4
    800065e8:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800065ec:	4007f793          	andi	a5,a5,1024
    800065f0:	c791                	beqz	a5,800065fc <sys_open+0xd2>
    800065f2:	04491703          	lh	a4,68(s2)
    800065f6:	4789                	li	a5,2
    800065f8:	08f70f63          	beq	a4,a5,80006696 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800065fc:	854a                	mv	a0,s2
    800065fe:	ffffe097          	auipc	ra,0xffffe
    80006602:	b2a080e7          	jalr	-1238(ra) # 80004128 <iunlock>
  end_op();
    80006606:	ffffe097          	auipc	ra,0xffffe
    8000660a:	7c8080e7          	jalr	1992(ra) # 80004dce <end_op>

  return fd;
}
    8000660e:	8526                	mv	a0,s1
    80006610:	70ea                	ld	ra,184(sp)
    80006612:	744a                	ld	s0,176(sp)
    80006614:	74aa                	ld	s1,168(sp)
    80006616:	790a                	ld	s2,160(sp)
    80006618:	69ea                	ld	s3,152(sp)
    8000661a:	6129                	addi	sp,sp,192
    8000661c:	8082                	ret
      end_op();
    8000661e:	ffffe097          	auipc	ra,0xffffe
    80006622:	7b0080e7          	jalr	1968(ra) # 80004dce <end_op>
      return -1;
    80006626:	b7e5                	j	8000660e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006628:	f5040513          	addi	a0,s0,-176
    8000662c:	ffffe097          	auipc	ra,0xffffe
    80006630:	1f0080e7          	jalr	496(ra) # 8000481c <namei>
    80006634:	892a                	mv	s2,a0
    80006636:	c905                	beqz	a0,80006666 <sys_open+0x13c>
    ilock(ip);
    80006638:	ffffe097          	auipc	ra,0xffffe
    8000663c:	a2e080e7          	jalr	-1490(ra) # 80004066 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006640:	04491703          	lh	a4,68(s2)
    80006644:	4785                	li	a5,1
    80006646:	f4f712e3          	bne	a4,a5,8000658a <sys_open+0x60>
    8000664a:	f4c42783          	lw	a5,-180(s0)
    8000664e:	dba1                	beqz	a5,8000659e <sys_open+0x74>
      iunlockput(ip);
    80006650:	854a                	mv	a0,s2
    80006652:	ffffe097          	auipc	ra,0xffffe
    80006656:	c76080e7          	jalr	-906(ra) # 800042c8 <iunlockput>
      end_op();
    8000665a:	ffffe097          	auipc	ra,0xffffe
    8000665e:	774080e7          	jalr	1908(ra) # 80004dce <end_op>
      return -1;
    80006662:	54fd                	li	s1,-1
    80006664:	b76d                	j	8000660e <sys_open+0xe4>
      end_op();
    80006666:	ffffe097          	auipc	ra,0xffffe
    8000666a:	768080e7          	jalr	1896(ra) # 80004dce <end_op>
      return -1;
    8000666e:	54fd                	li	s1,-1
    80006670:	bf79                	j	8000660e <sys_open+0xe4>
    iunlockput(ip);
    80006672:	854a                	mv	a0,s2
    80006674:	ffffe097          	auipc	ra,0xffffe
    80006678:	c54080e7          	jalr	-940(ra) # 800042c8 <iunlockput>
    end_op();
    8000667c:	ffffe097          	auipc	ra,0xffffe
    80006680:	752080e7          	jalr	1874(ra) # 80004dce <end_op>
    return -1;
    80006684:	54fd                	li	s1,-1
    80006686:	b761                	j	8000660e <sys_open+0xe4>
    f->type = FD_DEVICE;
    80006688:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000668c:	04691783          	lh	a5,70(s2)
    80006690:	02f99223          	sh	a5,36(s3)
    80006694:	bf2d                	j	800065ce <sys_open+0xa4>
    itrunc(ip);
    80006696:	854a                	mv	a0,s2
    80006698:	ffffe097          	auipc	ra,0xffffe
    8000669c:	adc080e7          	jalr	-1316(ra) # 80004174 <itrunc>
    800066a0:	bfb1                	j	800065fc <sys_open+0xd2>
      fileclose(f);
    800066a2:	854e                	mv	a0,s3
    800066a4:	fffff097          	auipc	ra,0xfffff
    800066a8:	b76080e7          	jalr	-1162(ra) # 8000521a <fileclose>
    iunlockput(ip);
    800066ac:	854a                	mv	a0,s2
    800066ae:	ffffe097          	auipc	ra,0xffffe
    800066b2:	c1a080e7          	jalr	-998(ra) # 800042c8 <iunlockput>
    end_op();
    800066b6:	ffffe097          	auipc	ra,0xffffe
    800066ba:	718080e7          	jalr	1816(ra) # 80004dce <end_op>
    return -1;
    800066be:	54fd                	li	s1,-1
    800066c0:	b7b9                	j	8000660e <sys_open+0xe4>

00000000800066c2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800066c2:	7175                	addi	sp,sp,-144
    800066c4:	e506                	sd	ra,136(sp)
    800066c6:	e122                	sd	s0,128(sp)
    800066c8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800066ca:	ffffe097          	auipc	ra,0xffffe
    800066ce:	684080e7          	jalr	1668(ra) # 80004d4e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800066d2:	08000613          	li	a2,128
    800066d6:	f7040593          	addi	a1,s0,-144
    800066da:	4501                	li	a0,0
    800066dc:	ffffd097          	auipc	ra,0xffffd
    800066e0:	e5c080e7          	jalr	-420(ra) # 80003538 <argstr>
    800066e4:	02054963          	bltz	a0,80006716 <sys_mkdir+0x54>
    800066e8:	4681                	li	a3,0
    800066ea:	4601                	li	a2,0
    800066ec:	4585                	li	a1,1
    800066ee:	f7040513          	addi	a0,s0,-144
    800066f2:	00000097          	auipc	ra,0x0
    800066f6:	cd2080e7          	jalr	-814(ra) # 800063c4 <create>
    800066fa:	cd11                	beqz	a0,80006716 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800066fc:	ffffe097          	auipc	ra,0xffffe
    80006700:	bcc080e7          	jalr	-1076(ra) # 800042c8 <iunlockput>
  end_op();
    80006704:	ffffe097          	auipc	ra,0xffffe
    80006708:	6ca080e7          	jalr	1738(ra) # 80004dce <end_op>
  return 0;
    8000670c:	4501                	li	a0,0
}
    8000670e:	60aa                	ld	ra,136(sp)
    80006710:	640a                	ld	s0,128(sp)
    80006712:	6149                	addi	sp,sp,144
    80006714:	8082                	ret
    end_op();
    80006716:	ffffe097          	auipc	ra,0xffffe
    8000671a:	6b8080e7          	jalr	1720(ra) # 80004dce <end_op>
    return -1;
    8000671e:	557d                	li	a0,-1
    80006720:	b7fd                	j	8000670e <sys_mkdir+0x4c>

0000000080006722 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006722:	7135                	addi	sp,sp,-160
    80006724:	ed06                	sd	ra,152(sp)
    80006726:	e922                	sd	s0,144(sp)
    80006728:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000672a:	ffffe097          	auipc	ra,0xffffe
    8000672e:	624080e7          	jalr	1572(ra) # 80004d4e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006732:	08000613          	li	a2,128
    80006736:	f7040593          	addi	a1,s0,-144
    8000673a:	4501                	li	a0,0
    8000673c:	ffffd097          	auipc	ra,0xffffd
    80006740:	dfc080e7          	jalr	-516(ra) # 80003538 <argstr>
    80006744:	04054a63          	bltz	a0,80006798 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80006748:	f6c40593          	addi	a1,s0,-148
    8000674c:	4505                	li	a0,1
    8000674e:	ffffd097          	auipc	ra,0xffffd
    80006752:	da6080e7          	jalr	-602(ra) # 800034f4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006756:	04054163          	bltz	a0,80006798 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000675a:	f6840593          	addi	a1,s0,-152
    8000675e:	4509                	li	a0,2
    80006760:	ffffd097          	auipc	ra,0xffffd
    80006764:	d94080e7          	jalr	-620(ra) # 800034f4 <argint>
     argint(1, &major) < 0 ||
    80006768:	02054863          	bltz	a0,80006798 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000676c:	f6841683          	lh	a3,-152(s0)
    80006770:	f6c41603          	lh	a2,-148(s0)
    80006774:	458d                	li	a1,3
    80006776:	f7040513          	addi	a0,s0,-144
    8000677a:	00000097          	auipc	ra,0x0
    8000677e:	c4a080e7          	jalr	-950(ra) # 800063c4 <create>
     argint(2, &minor) < 0 ||
    80006782:	c919                	beqz	a0,80006798 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006784:	ffffe097          	auipc	ra,0xffffe
    80006788:	b44080e7          	jalr	-1212(ra) # 800042c8 <iunlockput>
  end_op();
    8000678c:	ffffe097          	auipc	ra,0xffffe
    80006790:	642080e7          	jalr	1602(ra) # 80004dce <end_op>
  return 0;
    80006794:	4501                	li	a0,0
    80006796:	a031                	j	800067a2 <sys_mknod+0x80>
    end_op();
    80006798:	ffffe097          	auipc	ra,0xffffe
    8000679c:	636080e7          	jalr	1590(ra) # 80004dce <end_op>
    return -1;
    800067a0:	557d                	li	a0,-1
}
    800067a2:	60ea                	ld	ra,152(sp)
    800067a4:	644a                	ld	s0,144(sp)
    800067a6:	610d                	addi	sp,sp,160
    800067a8:	8082                	ret

00000000800067aa <sys_chdir>:

uint64
sys_chdir(void)
{
    800067aa:	7135                	addi	sp,sp,-160
    800067ac:	ed06                	sd	ra,152(sp)
    800067ae:	e922                	sd	s0,144(sp)
    800067b0:	e526                	sd	s1,136(sp)
    800067b2:	e14a                	sd	s2,128(sp)
    800067b4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800067b6:	ffffb097          	auipc	ra,0xffffb
    800067ba:	55a080e7          	jalr	1370(ra) # 80001d10 <myproc>
    800067be:	892a                	mv	s2,a0
  
  begin_op();
    800067c0:	ffffe097          	auipc	ra,0xffffe
    800067c4:	58e080e7          	jalr	1422(ra) # 80004d4e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800067c8:	08000613          	li	a2,128
    800067cc:	f6040593          	addi	a1,s0,-160
    800067d0:	4501                	li	a0,0
    800067d2:	ffffd097          	auipc	ra,0xffffd
    800067d6:	d66080e7          	jalr	-666(ra) # 80003538 <argstr>
    800067da:	04054b63          	bltz	a0,80006830 <sys_chdir+0x86>
    800067de:	f6040513          	addi	a0,s0,-160
    800067e2:	ffffe097          	auipc	ra,0xffffe
    800067e6:	03a080e7          	jalr	58(ra) # 8000481c <namei>
    800067ea:	84aa                	mv	s1,a0
    800067ec:	c131                	beqz	a0,80006830 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800067ee:	ffffe097          	auipc	ra,0xffffe
    800067f2:	878080e7          	jalr	-1928(ra) # 80004066 <ilock>
  if(ip->type != T_DIR){
    800067f6:	04449703          	lh	a4,68(s1)
    800067fa:	4785                	li	a5,1
    800067fc:	04f71063          	bne	a4,a5,8000683c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006800:	8526                	mv	a0,s1
    80006802:	ffffe097          	auipc	ra,0xffffe
    80006806:	926080e7          	jalr	-1754(ra) # 80004128 <iunlock>
  iput(p->cwd);
    8000680a:	15093503          	ld	a0,336(s2)
    8000680e:	ffffe097          	auipc	ra,0xffffe
    80006812:	a12080e7          	jalr	-1518(ra) # 80004220 <iput>
  end_op();
    80006816:	ffffe097          	auipc	ra,0xffffe
    8000681a:	5b8080e7          	jalr	1464(ra) # 80004dce <end_op>
  p->cwd = ip;
    8000681e:	14993823          	sd	s1,336(s2)
  return 0;
    80006822:	4501                	li	a0,0
}
    80006824:	60ea                	ld	ra,152(sp)
    80006826:	644a                	ld	s0,144(sp)
    80006828:	64aa                	ld	s1,136(sp)
    8000682a:	690a                	ld	s2,128(sp)
    8000682c:	610d                	addi	sp,sp,160
    8000682e:	8082                	ret
    end_op();
    80006830:	ffffe097          	auipc	ra,0xffffe
    80006834:	59e080e7          	jalr	1438(ra) # 80004dce <end_op>
    return -1;
    80006838:	557d                	li	a0,-1
    8000683a:	b7ed                	j	80006824 <sys_chdir+0x7a>
    iunlockput(ip);
    8000683c:	8526                	mv	a0,s1
    8000683e:	ffffe097          	auipc	ra,0xffffe
    80006842:	a8a080e7          	jalr	-1398(ra) # 800042c8 <iunlockput>
    end_op();
    80006846:	ffffe097          	auipc	ra,0xffffe
    8000684a:	588080e7          	jalr	1416(ra) # 80004dce <end_op>
    return -1;
    8000684e:	557d                	li	a0,-1
    80006850:	bfd1                	j	80006824 <sys_chdir+0x7a>

0000000080006852 <sys_exec>:

uint64
sys_exec(void)
{
    80006852:	7145                	addi	sp,sp,-464
    80006854:	e786                	sd	ra,456(sp)
    80006856:	e3a2                	sd	s0,448(sp)
    80006858:	ff26                	sd	s1,440(sp)
    8000685a:	fb4a                	sd	s2,432(sp)
    8000685c:	f74e                	sd	s3,424(sp)
    8000685e:	f352                	sd	s4,416(sp)
    80006860:	ef56                	sd	s5,408(sp)
    80006862:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006864:	08000613          	li	a2,128
    80006868:	f4040593          	addi	a1,s0,-192
    8000686c:	4501                	li	a0,0
    8000686e:	ffffd097          	auipc	ra,0xffffd
    80006872:	cca080e7          	jalr	-822(ra) # 80003538 <argstr>
    return -1;
    80006876:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006878:	0c054a63          	bltz	a0,8000694c <sys_exec+0xfa>
    8000687c:	e3840593          	addi	a1,s0,-456
    80006880:	4505                	li	a0,1
    80006882:	ffffd097          	auipc	ra,0xffffd
    80006886:	c94080e7          	jalr	-876(ra) # 80003516 <argaddr>
    8000688a:	0c054163          	bltz	a0,8000694c <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    8000688e:	10000613          	li	a2,256
    80006892:	4581                	li	a1,0
    80006894:	e4040513          	addi	a0,s0,-448
    80006898:	ffffa097          	auipc	ra,0xffffa
    8000689c:	426080e7          	jalr	1062(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800068a0:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800068a4:	89a6                	mv	s3,s1
    800068a6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800068a8:	02000a13          	li	s4,32
    800068ac:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800068b0:	00391793          	slli	a5,s2,0x3
    800068b4:	e3040593          	addi	a1,s0,-464
    800068b8:	e3843503          	ld	a0,-456(s0)
    800068bc:	953e                	add	a0,a0,a5
    800068be:	ffffd097          	auipc	ra,0xffffd
    800068c2:	b9c080e7          	jalr	-1124(ra) # 8000345a <fetchaddr>
    800068c6:	02054a63          	bltz	a0,800068fa <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    800068ca:	e3043783          	ld	a5,-464(s0)
    800068ce:	c3b9                	beqz	a5,80006914 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800068d0:	ffffa097          	auipc	ra,0xffffa
    800068d4:	202080e7          	jalr	514(ra) # 80000ad2 <kalloc>
    800068d8:	85aa                	mv	a1,a0
    800068da:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800068de:	cd11                	beqz	a0,800068fa <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800068e0:	6605                	lui	a2,0x1
    800068e2:	e3043503          	ld	a0,-464(s0)
    800068e6:	ffffd097          	auipc	ra,0xffffd
    800068ea:	bc6080e7          	jalr	-1082(ra) # 800034ac <fetchstr>
    800068ee:	00054663          	bltz	a0,800068fa <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    800068f2:	0905                	addi	s2,s2,1
    800068f4:	09a1                	addi	s3,s3,8
    800068f6:	fb491be3          	bne	s2,s4,800068ac <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800068fa:	10048913          	addi	s2,s1,256
    800068fe:	6088                	ld	a0,0(s1)
    80006900:	c529                	beqz	a0,8000694a <sys_exec+0xf8>
    kfree(argv[i]);
    80006902:	ffffa097          	auipc	ra,0xffffa
    80006906:	0d4080e7          	jalr	212(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000690a:	04a1                	addi	s1,s1,8
    8000690c:	ff2499e3          	bne	s1,s2,800068fe <sys_exec+0xac>
  return -1;
    80006910:	597d                	li	s2,-1
    80006912:	a82d                	j	8000694c <sys_exec+0xfa>
      argv[i] = 0;
    80006914:	0a8e                	slli	s5,s5,0x3
    80006916:	fc040793          	addi	a5,s0,-64
    8000691a:	9abe                	add	s5,s5,a5
    8000691c:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffcbe80>
  int ret = exec(path, argv);
    80006920:	e4040593          	addi	a1,s0,-448
    80006924:	f4040513          	addi	a0,s0,-192
    80006928:	fffff097          	auipc	ra,0xfffff
    8000692c:	13a080e7          	jalr	314(ra) # 80005a62 <exec>
    80006930:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006932:	10048993          	addi	s3,s1,256
    80006936:	6088                	ld	a0,0(s1)
    80006938:	c911                	beqz	a0,8000694c <sys_exec+0xfa>
    kfree(argv[i]);
    8000693a:	ffffa097          	auipc	ra,0xffffa
    8000693e:	09c080e7          	jalr	156(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006942:	04a1                	addi	s1,s1,8
    80006944:	ff3499e3          	bne	s1,s3,80006936 <sys_exec+0xe4>
    80006948:	a011                	j	8000694c <sys_exec+0xfa>
  return -1;
    8000694a:	597d                	li	s2,-1
}
    8000694c:	854a                	mv	a0,s2
    8000694e:	60be                	ld	ra,456(sp)
    80006950:	641e                	ld	s0,448(sp)
    80006952:	74fa                	ld	s1,440(sp)
    80006954:	795a                	ld	s2,432(sp)
    80006956:	79ba                	ld	s3,424(sp)
    80006958:	7a1a                	ld	s4,416(sp)
    8000695a:	6afa                	ld	s5,408(sp)
    8000695c:	6179                	addi	sp,sp,464
    8000695e:	8082                	ret

0000000080006960 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006960:	7139                	addi	sp,sp,-64
    80006962:	fc06                	sd	ra,56(sp)
    80006964:	f822                	sd	s0,48(sp)
    80006966:	f426                	sd	s1,40(sp)
    80006968:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000696a:	ffffb097          	auipc	ra,0xffffb
    8000696e:	3a6080e7          	jalr	934(ra) # 80001d10 <myproc>
    80006972:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006974:	fd840593          	addi	a1,s0,-40
    80006978:	4501                	li	a0,0
    8000697a:	ffffd097          	auipc	ra,0xffffd
    8000697e:	b9c080e7          	jalr	-1124(ra) # 80003516 <argaddr>
    return -1;
    80006982:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006984:	0e054063          	bltz	a0,80006a64 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006988:	fc840593          	addi	a1,s0,-56
    8000698c:	fd040513          	addi	a0,s0,-48
    80006990:	fffff097          	auipc	ra,0xfffff
    80006994:	db0080e7          	jalr	-592(ra) # 80005740 <pipealloc>
    return -1;
    80006998:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000699a:	0c054563          	bltz	a0,80006a64 <sys_pipe+0x104>
  fd0 = -1;
    8000699e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800069a2:	fd043503          	ld	a0,-48(s0)
    800069a6:	fffff097          	auipc	ra,0xfffff
    800069aa:	4e8080e7          	jalr	1256(ra) # 80005e8e <fdalloc>
    800069ae:	fca42223          	sw	a0,-60(s0)
    800069b2:	08054c63          	bltz	a0,80006a4a <sys_pipe+0xea>
    800069b6:	fc843503          	ld	a0,-56(s0)
    800069ba:	fffff097          	auipc	ra,0xfffff
    800069be:	4d4080e7          	jalr	1236(ra) # 80005e8e <fdalloc>
    800069c2:	fca42023          	sw	a0,-64(s0)
    800069c6:	06054863          	bltz	a0,80006a36 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800069ca:	4691                	li	a3,4
    800069cc:	fc440613          	addi	a2,s0,-60
    800069d0:	fd843583          	ld	a1,-40(s0)
    800069d4:	68a8                	ld	a0,80(s1)
    800069d6:	ffffb097          	auipc	ra,0xffffb
    800069da:	9bc080e7          	jalr	-1604(ra) # 80001392 <copyout>
    800069de:	02054063          	bltz	a0,800069fe <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800069e2:	4691                	li	a3,4
    800069e4:	fc040613          	addi	a2,s0,-64
    800069e8:	fd843583          	ld	a1,-40(s0)
    800069ec:	0591                	addi	a1,a1,4
    800069ee:	68a8                	ld	a0,80(s1)
    800069f0:	ffffb097          	auipc	ra,0xffffb
    800069f4:	9a2080e7          	jalr	-1630(ra) # 80001392 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800069f8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800069fa:	06055563          	bgez	a0,80006a64 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    800069fe:	fc442783          	lw	a5,-60(s0)
    80006a02:	07e9                	addi	a5,a5,26
    80006a04:	078e                	slli	a5,a5,0x3
    80006a06:	97a6                	add	a5,a5,s1
    80006a08:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006a0c:	fc042503          	lw	a0,-64(s0)
    80006a10:	0569                	addi	a0,a0,26
    80006a12:	050e                	slli	a0,a0,0x3
    80006a14:	9526                	add	a0,a0,s1
    80006a16:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006a1a:	fd043503          	ld	a0,-48(s0)
    80006a1e:	ffffe097          	auipc	ra,0xffffe
    80006a22:	7fc080e7          	jalr	2044(ra) # 8000521a <fileclose>
    fileclose(wf);
    80006a26:	fc843503          	ld	a0,-56(s0)
    80006a2a:	ffffe097          	auipc	ra,0xffffe
    80006a2e:	7f0080e7          	jalr	2032(ra) # 8000521a <fileclose>
    return -1;
    80006a32:	57fd                	li	a5,-1
    80006a34:	a805                	j	80006a64 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006a36:	fc442783          	lw	a5,-60(s0)
    80006a3a:	0007c863          	bltz	a5,80006a4a <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006a3e:	01a78513          	addi	a0,a5,26
    80006a42:	050e                	slli	a0,a0,0x3
    80006a44:	9526                	add	a0,a0,s1
    80006a46:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006a4a:	fd043503          	ld	a0,-48(s0)
    80006a4e:	ffffe097          	auipc	ra,0xffffe
    80006a52:	7cc080e7          	jalr	1996(ra) # 8000521a <fileclose>
    fileclose(wf);
    80006a56:	fc843503          	ld	a0,-56(s0)
    80006a5a:	ffffe097          	auipc	ra,0xffffe
    80006a5e:	7c0080e7          	jalr	1984(ra) # 8000521a <fileclose>
    return -1;
    80006a62:	57fd                	li	a5,-1
}
    80006a64:	853e                	mv	a0,a5
    80006a66:	70e2                	ld	ra,56(sp)
    80006a68:	7442                	ld	s0,48(sp)
    80006a6a:	74a2                	ld	s1,40(sp)
    80006a6c:	6121                	addi	sp,sp,64
    80006a6e:	8082                	ret

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
    80006ab0:	85dfc0ef          	jal	ra,8000330c <kerneltrap>
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
    80006b4c:	19c080e7          	jalr	412(ra) # 80001ce4 <cpuid>
  
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
    80006b84:	164080e7          	jalr	356(ra) # 80001ce4 <cpuid>
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
    80006bac:	13c080e7          	jalr	316(ra) # 80001ce4 <cpuid>
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
    80006c36:	762080e7          	jalr	1890(ra) # 80002394 <wakeup>
}
    80006c3a:	60a2                	ld	ra,8(sp)
    80006c3c:	6402                	ld	s0,0(sp)
    80006c3e:	0141                	addi	sp,sp,16
    80006c40:	8082                	ret
    panic("free_desc 1");
    80006c42:	00003517          	auipc	a0,0x3
    80006c46:	02e50513          	addi	a0,a0,46 # 80009c70 <syscalls+0x358>
    80006c4a:	ffffa097          	auipc	ra,0xffffa
    80006c4e:	8e0080e7          	jalr	-1824(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006c52:	00003517          	auipc	a0,0x3
    80006c56:	02e50513          	addi	a0,a0,46 # 80009c80 <syscalls+0x368>
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
    80006c70:	02458593          	addi	a1,a1,36 # 80009c90 <syscalls+0x378>
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
    80006d7a:	f2a50513          	addi	a0,a0,-214 # 80009ca0 <syscalls+0x388>
    80006d7e:	ffff9097          	auipc	ra,0xffff9
    80006d82:	7ac080e7          	jalr	1964(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006d86:	00003517          	auipc	a0,0x3
    80006d8a:	f3a50513          	addi	a0,a0,-198 # 80009cc0 <syscalls+0x3a8>
    80006d8e:	ffff9097          	auipc	ra,0xffff9
    80006d92:	79c080e7          	jalr	1948(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006d96:	00003517          	auipc	a0,0x3
    80006d9a:	f4a50513          	addi	a0,a0,-182 # 80009ce0 <syscalls+0x3c8>
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
    80006e5c:	3b0080e7          	jalr	944(ra) # 80002208 <sleep>
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
    80006f2a:	2e2080e7          	jalr	738(ra) # 80002208 <sleep>
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
    800070b0:	2e8080e7          	jalr	744(ra) # 80002394 <wakeup>

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
    800070ec:	c1850513          	addi	a0,a0,-1000 # 80009d00 <syscalls+0x3e8>
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
