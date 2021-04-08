
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
    80000068:	23c78793          	addi	a5,a5,572 # 800062a0 <timervec>
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
    80000122:	644080e7          	jalr	1604(ra) # 80002762 <either_copyin>
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
    800001b2:	00002097          	auipc	ra,0x2
    800001b6:	814080e7          	jalr	-2028(ra) # 800019c6 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	17e080e7          	jalr	382(ra) # 80002340 <sleep>
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
    80000202:	50e080e7          	jalr	1294(ra) # 8000270c <either_copyout>
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
    800002e2:	4da080e7          	jalr	1242(ra) # 800027b8 <procdump>
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
    80000436:	09a080e7          	jalr	154(ra) # 800024cc <wakeup>
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
    80000882:	c4e080e7          	jalr	-946(ra) # 800024cc <wakeup>
    
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
    8000090e:	a36080e7          	jalr	-1482(ra) # 80002340 <sleep>
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
    80000b60:	e4e080e7          	jalr	-434(ra) # 800019aa <mycpu>
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
    80000b92:	e1c080e7          	jalr	-484(ra) # 800019aa <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	e10080e7          	jalr	-496(ra) # 800019aa <mycpu>
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
    80000bb6:	df8080e7          	jalr	-520(ra) # 800019aa <mycpu>
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
    80000bf6:	db8080e7          	jalr	-584(ra) # 800019aa <mycpu>
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
    80000c22:	d8c080e7          	jalr	-628(ra) # 800019aa <mycpu>
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
    80000e78:	b26080e7          	jalr	-1242(ra) # 8000199a <cpuid>
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
    80000e94:	b0a080e7          	jalr	-1270(ra) # 8000199a <cpuid>
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
    80000eb6:	d02080e7          	jalr	-766(ra) # 80002bb4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00005097          	auipc	ra,0x5
    80000ebe:	426080e7          	jalr	1062(ra) # 800062e0 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	316080e7          	jalr	790(ra) # 800021d8 <scheduler>
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
    80000f26:	9c8080e7          	jalr	-1592(ra) # 800018ea <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	c62080e7          	jalr	-926(ra) # 80002b8c <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	c82080e7          	jalr	-894(ra) # 80002bb4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00005097          	auipc	ra,0x5
    80000f3e:	390080e7          	jalr	912(ra) # 800062ca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00005097          	auipc	ra,0x5
    80000f46:	39e080e7          	jalr	926(ra) # 800062e0 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	566080e7          	jalr	1382(ra) # 800034b0 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	bf8080e7          	jalr	-1032(ra) # 80003b4a <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	ba6080e7          	jalr	-1114(ra) # 80004b00 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	4a0080e7          	jalr	1184(ra) # 80006402 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	d64080e7          	jalr	-668(ra) # 80001cce <userinit>
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
    80001210:	648080e7          	jalr	1608(ra) # 80001854 <proc_mapstacks>
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

000000008000180c <SRT_compare>:
  return p1->runnable_since - p2->runnable_since;
  // return 0;
}

int
SRT_compare(struct proc *p1,struct proc *p2){
    8000180c:	1101                	addi	sp,sp,-32
    8000180e:	ec06                	sd	ra,24(sp)
    80001810:	e822                	sd	s0,16(sp)
    80001812:	e426                	sd	s1,8(sp)
    80001814:	e04a                	sd	s2,0(sp)
    80001816:	1000                	addi	s0,sp,32
    80001818:	892a                	mv	s2,a0
    8000181a:	84ae                	mv	s1,a1
  printf("\t\t p1->brst=%d \n",p1->average_bursttime);
    8000181c:	456c                	lw	a1,76(a0)
    8000181e:	00007517          	auipc	a0,0x7
    80001822:	9a250513          	addi	a0,a0,-1630 # 800081c0 <digits+0x180>
    80001826:	fffff097          	auipc	ra,0xfffff
    8000182a:	d4e080e7          	jalr	-690(ra) # 80000574 <printf>
  printf("\t\t p2->brst=%d\n",p2->average_bursttime);
    8000182e:	44ec                	lw	a1,76(s1)
    80001830:	00007517          	auipc	a0,0x7
    80001834:	9a850513          	addi	a0,a0,-1624 # 800081d8 <digits+0x198>
    80001838:	fffff097          	auipc	ra,0xfffff
    8000183c:	d3c080e7          	jalr	-708(ra) # 80000574 <printf>
  return p1->average_bursttime - p2->average_bursttime;
    80001840:	04c92503          	lw	a0,76(s2) # 104c <_entry-0x7fffefb4>
    80001844:	44fc                	lw	a5,76(s1)
}
    80001846:	9d1d                	subw	a0,a0,a5
    80001848:	60e2                	ld	ra,24(sp)
    8000184a:	6442                	ld	s0,16(sp)
    8000184c:	64a2                	ld	s1,8(sp)
    8000184e:	6902                	ld	s2,0(sp)
    80001850:	6105                	addi	sp,sp,32
    80001852:	8082                	ret

0000000080001854 <proc_mapstacks>:
proc_mapstacks(pagetable_t kpgtbl) {
    80001854:	7139                	addi	sp,sp,-64
    80001856:	fc06                	sd	ra,56(sp)
    80001858:	f822                	sd	s0,48(sp)
    8000185a:	f426                	sd	s1,40(sp)
    8000185c:	f04a                	sd	s2,32(sp)
    8000185e:	ec4e                	sd	s3,24(sp)
    80001860:	e852                	sd	s4,16(sp)
    80001862:	e456                	sd	s5,8(sp)
    80001864:	e05a                	sd	s6,0(sp)
    80001866:	0080                	addi	s0,sp,64
    80001868:	89aa                	mv	s3,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186a:	00010497          	auipc	s1,0x10
    8000186e:	e6648493          	addi	s1,s1,-410 # 800116d0 <proc>
    uint64 va = KSTACK((int) (p - proc));
    80001872:	8b26                	mv	s6,s1
    80001874:	00006a97          	auipc	s5,0x6
    80001878:	78ca8a93          	addi	s5,s5,1932 # 80008000 <etext>
    8000187c:	04000937          	lui	s2,0x4000
    80001880:	197d                	addi	s2,s2,-1
    80001882:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001884:	00016a17          	auipc	s4,0x16
    80001888:	24ca0a13          	addi	s4,s4,588 # 80017ad0 <tickslock>
    char *pa = kalloc();
    8000188c:	fffff097          	auipc	ra,0xfffff
    80001890:	246080e7          	jalr	582(ra) # 80000ad2 <kalloc>
    80001894:	862a                	mv	a2,a0
    if(pa == 0)
    80001896:	c131                	beqz	a0,800018da <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001898:	416485b3          	sub	a1,s1,s6
    8000189c:	8591                	srai	a1,a1,0x4
    8000189e:	000ab783          	ld	a5,0(s5)
    800018a2:	02f585b3          	mul	a1,a1,a5
    800018a6:	2585                	addiw	a1,a1,1
    800018a8:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018ac:	4719                	li	a4,6
    800018ae:	6685                	lui	a3,0x1
    800018b0:	40b905b3          	sub	a1,s2,a1
    800018b4:	854e                	mv	a0,s3
    800018b6:	00000097          	auipc	ra,0x0
    800018ba:	866080e7          	jalr	-1946(ra) # 8000111c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018be:	19048493          	addi	s1,s1,400
    800018c2:	fd4495e3          	bne	s1,s4,8000188c <proc_mapstacks+0x38>
}
    800018c6:	70e2                	ld	ra,56(sp)
    800018c8:	7442                	ld	s0,48(sp)
    800018ca:	74a2                	ld	s1,40(sp)
    800018cc:	7902                	ld	s2,32(sp)
    800018ce:	69e2                	ld	s3,24(sp)
    800018d0:	6a42                	ld	s4,16(sp)
    800018d2:	6aa2                	ld	s5,8(sp)
    800018d4:	6b02                	ld	s6,0(sp)
    800018d6:	6121                	addi	sp,sp,64
    800018d8:	8082                	ret
      panic("kalloc");
    800018da:	00007517          	auipc	a0,0x7
    800018de:	90e50513          	addi	a0,a0,-1778 # 800081e8 <digits+0x1a8>
    800018e2:	fffff097          	auipc	ra,0xfffff
    800018e6:	c48080e7          	jalr	-952(ra) # 8000052a <panic>

00000000800018ea <procinit>:
{
    800018ea:	7139                	addi	sp,sp,-64
    800018ec:	fc06                	sd	ra,56(sp)
    800018ee:	f822                	sd	s0,48(sp)
    800018f0:	f426                	sd	s1,40(sp)
    800018f2:	f04a                	sd	s2,32(sp)
    800018f4:	ec4e                	sd	s3,24(sp)
    800018f6:	e852                	sd	s4,16(sp)
    800018f8:	e456                	sd	s5,8(sp)
    800018fa:	e05a                	sd	s6,0(sp)
    800018fc:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    800018fe:	00007597          	auipc	a1,0x7
    80001902:	8f258593          	addi	a1,a1,-1806 # 800081f0 <digits+0x1b0>
    80001906:	00010517          	auipc	a0,0x10
    8000190a:	99a50513          	addi	a0,a0,-1638 # 800112a0 <pid_lock>
    8000190e:	fffff097          	auipc	ra,0xfffff
    80001912:	224080e7          	jalr	548(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001916:	00007597          	auipc	a1,0x7
    8000191a:	8e258593          	addi	a1,a1,-1822 # 800081f8 <digits+0x1b8>
    8000191e:	00010517          	auipc	a0,0x10
    80001922:	99a50513          	addi	a0,a0,-1638 # 800112b8 <wait_lock>
    80001926:	fffff097          	auipc	ra,0xfffff
    8000192a:	20c080e7          	jalr	524(ra) # 80000b32 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192e:	00010497          	auipc	s1,0x10
    80001932:	da248493          	addi	s1,s1,-606 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    80001936:	00007b17          	auipc	s6,0x7
    8000193a:	8d2b0b13          	addi	s6,s6,-1838 # 80008208 <digits+0x1c8>
      p->kstack = KSTACK((int) (p - proc));
    8000193e:	8aa6                	mv	s5,s1
    80001940:	00006a17          	auipc	s4,0x6
    80001944:	6c0a0a13          	addi	s4,s4,1728 # 80008000 <etext>
    80001948:	04000937          	lui	s2,0x4000
    8000194c:	197d                	addi	s2,s2,-1
    8000194e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001950:	00016997          	auipc	s3,0x16
    80001954:	18098993          	addi	s3,s3,384 # 80017ad0 <tickslock>
      initlock(&p->lock, "proc");
    80001958:	85da                	mv	a1,s6
    8000195a:	8526                	mv	a0,s1
    8000195c:	fffff097          	auipc	ra,0xfffff
    80001960:	1d6080e7          	jalr	470(ra) # 80000b32 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001964:	415487b3          	sub	a5,s1,s5
    80001968:	8791                	srai	a5,a5,0x4
    8000196a:	000a3703          	ld	a4,0(s4)
    8000196e:	02e787b3          	mul	a5,a5,a4
    80001972:	2785                	addiw	a5,a5,1
    80001974:	00d7979b          	slliw	a5,a5,0xd
    80001978:	40f907b3          	sub	a5,s2,a5
    8000197c:	f4bc                	sd	a5,104(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000197e:	19048493          	addi	s1,s1,400
    80001982:	fd349be3          	bne	s1,s3,80001958 <procinit+0x6e>
}
    80001986:	70e2                	ld	ra,56(sp)
    80001988:	7442                	ld	s0,48(sp)
    8000198a:	74a2                	ld	s1,40(sp)
    8000198c:	7902                	ld	s2,32(sp)
    8000198e:	69e2                	ld	s3,24(sp)
    80001990:	6a42                	ld	s4,16(sp)
    80001992:	6aa2                	ld	s5,8(sp)
    80001994:	6b02                	ld	s6,0(sp)
    80001996:	6121                	addi	sp,sp,64
    80001998:	8082                	ret

000000008000199a <cpuid>:
{
    8000199a:	1141                	addi	sp,sp,-16
    8000199c:	e422                	sd	s0,8(sp)
    8000199e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019a0:	8512                	mv	a0,tp
}
    800019a2:	2501                	sext.w	a0,a0
    800019a4:	6422                	ld	s0,8(sp)
    800019a6:	0141                	addi	sp,sp,16
    800019a8:	8082                	ret

00000000800019aa <mycpu>:
mycpu(void) {
    800019aa:	1141                	addi	sp,sp,-16
    800019ac:	e422                	sd	s0,8(sp)
    800019ae:	0800                	addi	s0,sp,16
    800019b0:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    800019b2:	2781                	sext.w	a5,a5
    800019b4:	079e                	slli	a5,a5,0x7
}
    800019b6:	00010517          	auipc	a0,0x10
    800019ba:	91a50513          	addi	a0,a0,-1766 # 800112d0 <cpus>
    800019be:	953e                	add	a0,a0,a5
    800019c0:	6422                	ld	s0,8(sp)
    800019c2:	0141                	addi	sp,sp,16
    800019c4:	8082                	ret

00000000800019c6 <myproc>:
myproc(void) {
    800019c6:	1101                	addi	sp,sp,-32
    800019c8:	ec06                	sd	ra,24(sp)
    800019ca:	e822                	sd	s0,16(sp)
    800019cc:	e426                	sd	s1,8(sp)
    800019ce:	1000                	addi	s0,sp,32
  push_off();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	1a6080e7          	jalr	422(ra) # 80000b76 <push_off>
    800019d8:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    800019da:	2781                	sext.w	a5,a5
    800019dc:	079e                	slli	a5,a5,0x7
    800019de:	00010717          	auipc	a4,0x10
    800019e2:	8c270713          	addi	a4,a4,-1854 # 800112a0 <pid_lock>
    800019e6:	97ba                	add	a5,a5,a4
    800019e8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ea:	fffff097          	auipc	ra,0xfffff
    800019ee:	22c080e7          	jalr	556(ra) # 80000c16 <pop_off>
}
    800019f2:	8526                	mv	a0,s1
    800019f4:	60e2                	ld	ra,24(sp)
    800019f6:	6442                	ld	s0,16(sp)
    800019f8:	64a2                	ld	s1,8(sp)
    800019fa:	6105                	addi	sp,sp,32
    800019fc:	8082                	ret

00000000800019fe <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019fe:	1141                	addi	sp,sp,-16
    80001a00:	e406                	sd	ra,8(sp)
    80001a02:	e022                	sd	s0,0(sp)
    80001a04:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a06:	00000097          	auipc	ra,0x0
    80001a0a:	fc0080e7          	jalr	-64(ra) # 800019c6 <myproc>
    80001a0e:	fffff097          	auipc	ra,0xfffff
    80001a12:	268080e7          	jalr	616(ra) # 80000c76 <release>

  if (first) {
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	0fa7a783          	lw	a5,250(a5) # 80008b10 <first.1>
    80001a1e:	eb89                	bnez	a5,80001a30 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a20:	00001097          	auipc	ra,0x1
    80001a24:	1ac080e7          	jalr	428(ra) # 80002bcc <usertrapret>
}
    80001a28:	60a2                	ld	ra,8(sp)
    80001a2a:	6402                	ld	s0,0(sp)
    80001a2c:	0141                	addi	sp,sp,16
    80001a2e:	8082                	ret
    first = 0;
    80001a30:	00007797          	auipc	a5,0x7
    80001a34:	0e07a023          	sw	zero,224(a5) # 80008b10 <first.1>
    fsinit(ROOTDEV);
    80001a38:	4505                	li	a0,1
    80001a3a:	00002097          	auipc	ra,0x2
    80001a3e:	090080e7          	jalr	144(ra) # 80003aca <fsinit>
    80001a42:	bff9                	j	80001a20 <forkret+0x22>

0000000080001a44 <allocpid>:
allocpid() {
    80001a44:	1101                	addi	sp,sp,-32
    80001a46:	ec06                	sd	ra,24(sp)
    80001a48:	e822                	sd	s0,16(sp)
    80001a4a:	e426                	sd	s1,8(sp)
    80001a4c:	e04a                	sd	s2,0(sp)
    80001a4e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a50:	00010917          	auipc	s2,0x10
    80001a54:	85090913          	addi	s2,s2,-1968 # 800112a0 <pid_lock>
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	168080e7          	jalr	360(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001a62:	00007797          	auipc	a5,0x7
    80001a66:	0b678793          	addi	a5,a5,182 # 80008b18 <nextpid>
    80001a6a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a6c:	0014871b          	addiw	a4,s1,1
    80001a70:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a72:	854a                	mv	a0,s2
    80001a74:	fffff097          	auipc	ra,0xfffff
    80001a78:	202080e7          	jalr	514(ra) # 80000c76 <release>
}
    80001a7c:	8526                	mv	a0,s1
    80001a7e:	60e2                	ld	ra,24(sp)
    80001a80:	6442                	ld	s0,16(sp)
    80001a82:	64a2                	ld	s1,8(sp)
    80001a84:	6902                	ld	s2,0(sp)
    80001a86:	6105                	addi	sp,sp,32
    80001a88:	8082                	ret

0000000080001a8a <proc_pagetable>:
{
    80001a8a:	1101                	addi	sp,sp,-32
    80001a8c:	ec06                	sd	ra,24(sp)
    80001a8e:	e822                	sd	s0,16(sp)
    80001a90:	e426                	sd	s1,8(sp)
    80001a92:	e04a                	sd	s2,0(sp)
    80001a94:	1000                	addi	s0,sp,32
    80001a96:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a98:	00000097          	auipc	ra,0x0
    80001a9c:	86e080e7          	jalr	-1938(ra) # 80001306 <uvmcreate>
    80001aa0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001aa2:	c121                	beqz	a0,80001ae2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aa4:	4729                	li	a4,10
    80001aa6:	00005697          	auipc	a3,0x5
    80001aaa:	55a68693          	addi	a3,a3,1370 # 80007000 <_trampoline>
    80001aae:	6605                	lui	a2,0x1
    80001ab0:	040005b7          	lui	a1,0x4000
    80001ab4:	15fd                	addi	a1,a1,-1
    80001ab6:	05b2                	slli	a1,a1,0xc
    80001ab8:	fffff097          	auipc	ra,0xfffff
    80001abc:	5d6080e7          	jalr	1494(ra) # 8000108e <mappages>
    80001ac0:	02054863          	bltz	a0,80001af0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ac4:	4719                	li	a4,6
    80001ac6:	08093683          	ld	a3,128(s2)
    80001aca:	6605                	lui	a2,0x1
    80001acc:	020005b7          	lui	a1,0x2000
    80001ad0:	15fd                	addi	a1,a1,-1
    80001ad2:	05b6                	slli	a1,a1,0xd
    80001ad4:	8526                	mv	a0,s1
    80001ad6:	fffff097          	auipc	ra,0xfffff
    80001ada:	5b8080e7          	jalr	1464(ra) # 8000108e <mappages>
    80001ade:	02054163          	bltz	a0,80001b00 <proc_pagetable+0x76>
}
    80001ae2:	8526                	mv	a0,s1
    80001ae4:	60e2                	ld	ra,24(sp)
    80001ae6:	6442                	ld	s0,16(sp)
    80001ae8:	64a2                	ld	s1,8(sp)
    80001aea:	6902                	ld	s2,0(sp)
    80001aec:	6105                	addi	sp,sp,32
    80001aee:	8082                	ret
    uvmfree(pagetable, 0);
    80001af0:	4581                	li	a1,0
    80001af2:	8526                	mv	a0,s1
    80001af4:	00000097          	auipc	ra,0x0
    80001af8:	a0e080e7          	jalr	-1522(ra) # 80001502 <uvmfree>
    return 0;
    80001afc:	4481                	li	s1,0
    80001afe:	b7d5                	j	80001ae2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b00:	4681                	li	a3,0
    80001b02:	4605                	li	a2,1
    80001b04:	040005b7          	lui	a1,0x4000
    80001b08:	15fd                	addi	a1,a1,-1
    80001b0a:	05b2                	slli	a1,a1,0xc
    80001b0c:	8526                	mv	a0,s1
    80001b0e:	fffff097          	auipc	ra,0xfffff
    80001b12:	734080e7          	jalr	1844(ra) # 80001242 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b16:	4581                	li	a1,0
    80001b18:	8526                	mv	a0,s1
    80001b1a:	00000097          	auipc	ra,0x0
    80001b1e:	9e8080e7          	jalr	-1560(ra) # 80001502 <uvmfree>
    return 0;
    80001b22:	4481                	li	s1,0
    80001b24:	bf7d                	j	80001ae2 <proc_pagetable+0x58>

0000000080001b26 <proc_freepagetable>:
{
    80001b26:	1101                	addi	sp,sp,-32
    80001b28:	ec06                	sd	ra,24(sp)
    80001b2a:	e822                	sd	s0,16(sp)
    80001b2c:	e426                	sd	s1,8(sp)
    80001b2e:	e04a                	sd	s2,0(sp)
    80001b30:	1000                	addi	s0,sp,32
    80001b32:	84aa                	mv	s1,a0
    80001b34:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b36:	4681                	li	a3,0
    80001b38:	4605                	li	a2,1
    80001b3a:	040005b7          	lui	a1,0x4000
    80001b3e:	15fd                	addi	a1,a1,-1
    80001b40:	05b2                	slli	a1,a1,0xc
    80001b42:	fffff097          	auipc	ra,0xfffff
    80001b46:	700080e7          	jalr	1792(ra) # 80001242 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b4a:	4681                	li	a3,0
    80001b4c:	4605                	li	a2,1
    80001b4e:	020005b7          	lui	a1,0x2000
    80001b52:	15fd                	addi	a1,a1,-1
    80001b54:	05b6                	slli	a1,a1,0xd
    80001b56:	8526                	mv	a0,s1
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	6ea080e7          	jalr	1770(ra) # 80001242 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b60:	85ca                	mv	a1,s2
    80001b62:	8526                	mv	a0,s1
    80001b64:	00000097          	auipc	ra,0x0
    80001b68:	99e080e7          	jalr	-1634(ra) # 80001502 <uvmfree>
}
    80001b6c:	60e2                	ld	ra,24(sp)
    80001b6e:	6442                	ld	s0,16(sp)
    80001b70:	64a2                	ld	s1,8(sp)
    80001b72:	6902                	ld	s2,0(sp)
    80001b74:	6105                	addi	sp,sp,32
    80001b76:	8082                	ret

0000000080001b78 <freeproc>:
{
    80001b78:	1101                	addi	sp,sp,-32
    80001b7a:	ec06                	sd	ra,24(sp)
    80001b7c:	e822                	sd	s0,16(sp)
    80001b7e:	e426                	sd	s1,8(sp)
    80001b80:	1000                	addi	s0,sp,32
    80001b82:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b84:	6148                	ld	a0,128(a0)
    80001b86:	c509                	beqz	a0,80001b90 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b88:	fffff097          	auipc	ra,0xfffff
    80001b8c:	e4e080e7          	jalr	-434(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001b90:	0804b023          	sd	zero,128(s1)
  if(p->pagetable)
    80001b94:	7ca8                	ld	a0,120(s1)
    80001b96:	c511                	beqz	a0,80001ba2 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b98:	78ac                	ld	a1,112(s1)
    80001b9a:	00000097          	auipc	ra,0x0
    80001b9e:	f8c080e7          	jalr	-116(ra) # 80001b26 <proc_freepagetable>
  p->pagetable = 0;
    80001ba2:	0604bc23          	sd	zero,120(s1)
  p->sz = 0;
    80001ba6:	0604b823          	sd	zero,112(s1)
  p->pid = 0;
    80001baa:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bae:	0604b023          	sd	zero,96(s1)
  p->name[0] = 0;
    80001bb2:	18048023          	sb	zero,384(s1)
  p->chan = 0;
    80001bb6:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bba:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bbe:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bc2:	0004ac23          	sw	zero,24(s1)
}
    80001bc6:	60e2                	ld	ra,24(sp)
    80001bc8:	6442                	ld	s0,16(sp)
    80001bca:	64a2                	ld	s1,8(sp)
    80001bcc:	6105                	addi	sp,sp,32
    80001bce:	8082                	ret

0000000080001bd0 <allocproc>:
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	e04a                	sd	s2,0(sp)
    80001bda:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bdc:	00010497          	auipc	s1,0x10
    80001be0:	af448493          	addi	s1,s1,-1292 # 800116d0 <proc>
    80001be4:	00016917          	auipc	s2,0x16
    80001be8:	eec90913          	addi	s2,s2,-276 # 80017ad0 <tickslock>
    acquire(&p->lock);
    80001bec:	8526                	mv	a0,s1
    80001bee:	fffff097          	auipc	ra,0xfffff
    80001bf2:	fd4080e7          	jalr	-44(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    80001bf6:	4c9c                	lw	a5,24(s1)
    80001bf8:	cf81                	beqz	a5,80001c10 <allocproc+0x40>
      release(&p->lock);
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	fffff097          	auipc	ra,0xfffff
    80001c00:	07a080e7          	jalr	122(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c04:	19048493          	addi	s1,s1,400
    80001c08:	ff2492e3          	bne	s1,s2,80001bec <allocproc+0x1c>
  return 0;
    80001c0c:	4481                	li	s1,0
    80001c0e:	a049                	j	80001c90 <allocproc+0xc0>
  p->pid = allocpid();
    80001c10:	00000097          	auipc	ra,0x0
    80001c14:	e34080e7          	jalr	-460(ra) # 80001a44 <allocpid>
    80001c18:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c1a:	4785                	li	a5,1
    80001c1c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c1e:	fffff097          	auipc	ra,0xfffff
    80001c22:	eb4080e7          	jalr	-332(ra) # 80000ad2 <kalloc>
    80001c26:	892a                	mv	s2,a0
    80001c28:	e0c8                	sd	a0,128(s1)
    80001c2a:	c935                	beqz	a0,80001c9e <allocproc+0xce>
  p->pagetable = proc_pagetable(p);
    80001c2c:	8526                	mv	a0,s1
    80001c2e:	00000097          	auipc	ra,0x0
    80001c32:	e5c080e7          	jalr	-420(ra) # 80001a8a <proc_pagetable>
    80001c36:	892a                	mv	s2,a0
    80001c38:	fca8                	sd	a0,120(s1)
  if(p->pagetable == 0){
    80001c3a:	cd35                	beqz	a0,80001cb6 <allocproc+0xe6>
  memset(&p->context, 0, sizeof(p->context));
    80001c3c:	07000613          	li	a2,112
    80001c40:	4581                	li	a1,0
    80001c42:	08848513          	addi	a0,s1,136
    80001c46:	fffff097          	auipc	ra,0xfffff
    80001c4a:	078080e7          	jalr	120(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80001c4e:	00000797          	auipc	a5,0x0
    80001c52:	db078793          	addi	a5,a5,-592 # 800019fe <forkret>
    80001c56:	e4dc                	sd	a5,136(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c58:	74bc                	ld	a5,104(s1)
    80001c5a:	6705                	lui	a4,0x1
    80001c5c:	97ba                	add	a5,a5,a4
    80001c5e:	e8dc                	sd	a5,144(s1)
  p->ctime = ticks;
    80001c60:	00007797          	auipc	a5,0x7
    80001c64:	3d07a783          	lw	a5,976(a5) # 80009030 <ticks>
    80001c68:	dc9c                	sw	a5,56(s1)
  p->ttime = -1;
    80001c6a:	57fd                	li	a5,-1
    80001c6c:	dcdc                	sw	a5,60(s1)
  p->stime = 0;
    80001c6e:	0404a023          	sw	zero,64(s1)
  p->retime = 0;
    80001c72:	0404a223          	sw	zero,68(s1)
  p->rutime = 0;
    80001c76:	0404a423          	sw	zero,72(s1)
  p->average_bursttime = QUANTUM * 100;
    80001c7a:	1f400793          	li	a5,500
    80001c7e:	c4fc                	sw	a5,76(s1)
  p->current_runtime = 0;
    80001c80:	0404aa23          	sw	zero,84(s1)
  p->decay_factor = 5;
    80001c84:	4795                	li	a5,5
    80001c86:	c8bc                	sw	a5,80(s1)
  p->runnable_since = 0;
    80001c88:	0404ac23          	sw	zero,88(s1)
  p->chosen = 0;
    80001c8c:	0404ae23          	sw	zero,92(s1)
}
    80001c90:	8526                	mv	a0,s1
    80001c92:	60e2                	ld	ra,24(sp)
    80001c94:	6442                	ld	s0,16(sp)
    80001c96:	64a2                	ld	s1,8(sp)
    80001c98:	6902                	ld	s2,0(sp)
    80001c9a:	6105                	addi	sp,sp,32
    80001c9c:	8082                	ret
    freeproc(p);
    80001c9e:	8526                	mv	a0,s1
    80001ca0:	00000097          	auipc	ra,0x0
    80001ca4:	ed8080e7          	jalr	-296(ra) # 80001b78 <freeproc>
    release(&p->lock);
    80001ca8:	8526                	mv	a0,s1
    80001caa:	fffff097          	auipc	ra,0xfffff
    80001cae:	fcc080e7          	jalr	-52(ra) # 80000c76 <release>
    return 0;
    80001cb2:	84ca                	mv	s1,s2
    80001cb4:	bff1                	j	80001c90 <allocproc+0xc0>
    freeproc(p);
    80001cb6:	8526                	mv	a0,s1
    80001cb8:	00000097          	auipc	ra,0x0
    80001cbc:	ec0080e7          	jalr	-320(ra) # 80001b78 <freeproc>
    release(&p->lock);
    80001cc0:	8526                	mv	a0,s1
    80001cc2:	fffff097          	auipc	ra,0xfffff
    80001cc6:	fb4080e7          	jalr	-76(ra) # 80000c76 <release>
    return 0;
    80001cca:	84ca                	mv	s1,s2
    80001ccc:	b7d1                	j	80001c90 <allocproc+0xc0>

0000000080001cce <userinit>:
{
    80001cce:	1101                	addi	sp,sp,-32
    80001cd0:	ec06                	sd	ra,24(sp)
    80001cd2:	e822                	sd	s0,16(sp)
    80001cd4:	e426                	sd	s1,8(sp)
    80001cd6:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cd8:	00000097          	auipc	ra,0x0
    80001cdc:	ef8080e7          	jalr	-264(ra) # 80001bd0 <allocproc>
    80001ce0:	84aa                	mv	s1,a0
  initproc = p;
    80001ce2:	00007797          	auipc	a5,0x7
    80001ce6:	34a7b323          	sd	a0,838(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cea:	03400613          	li	a2,52
    80001cee:	00007597          	auipc	a1,0x7
    80001cf2:	e3258593          	addi	a1,a1,-462 # 80008b20 <initcode>
    80001cf6:	7d28                	ld	a0,120(a0)
    80001cf8:	fffff097          	auipc	ra,0xfffff
    80001cfc:	63c080e7          	jalr	1596(ra) # 80001334 <uvminit>
  p->sz = PGSIZE;
    80001d00:	6785                	lui	a5,0x1
    80001d02:	f8bc                	sd	a5,112(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d04:	60d8                	ld	a4,128(s1)
    80001d06:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d0a:	60d8                	ld	a4,128(s1)
    80001d0c:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d0e:	4641                	li	a2,16
    80001d10:	00006597          	auipc	a1,0x6
    80001d14:	50058593          	addi	a1,a1,1280 # 80008210 <digits+0x1d0>
    80001d18:	18048513          	addi	a0,s1,384
    80001d1c:	fffff097          	auipc	ra,0xfffff
    80001d20:	0f4080e7          	jalr	244(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80001d24:	00006517          	auipc	a0,0x6
    80001d28:	4fc50513          	addi	a0,a0,1276 # 80008220 <digits+0x1e0>
    80001d2c:	00002097          	auipc	ra,0x2
    80001d30:	7cc080e7          	jalr	1996(ra) # 800044f8 <namei>
    80001d34:	16a4bc23          	sd	a0,376(s1)
  p->state = RUNNABLE;
    80001d38:	478d                	li	a5,3
    80001d3a:	cc9c                	sw	a5,24(s1)
  p->runnable_since = ticks;
    80001d3c:	00007797          	auipc	a5,0x7
    80001d40:	2f47a783          	lw	a5,756(a5) # 80009030 <ticks>
    80001d44:	ccbc                	sw	a5,88(s1)
  release(&p->lock);
    80001d46:	8526                	mv	a0,s1
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	f2e080e7          	jalr	-210(ra) # 80000c76 <release>
}
    80001d50:	60e2                	ld	ra,24(sp)
    80001d52:	6442                	ld	s0,16(sp)
    80001d54:	64a2                	ld	s1,8(sp)
    80001d56:	6105                	addi	sp,sp,32
    80001d58:	8082                	ret

0000000080001d5a <growproc>:
{
    80001d5a:	1101                	addi	sp,sp,-32
    80001d5c:	ec06                	sd	ra,24(sp)
    80001d5e:	e822                	sd	s0,16(sp)
    80001d60:	e426                	sd	s1,8(sp)
    80001d62:	e04a                	sd	s2,0(sp)
    80001d64:	1000                	addi	s0,sp,32
    80001d66:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d68:	00000097          	auipc	ra,0x0
    80001d6c:	c5e080e7          	jalr	-930(ra) # 800019c6 <myproc>
    80001d70:	892a                	mv	s2,a0
  sz = p->sz;
    80001d72:	792c                	ld	a1,112(a0)
    80001d74:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d78:	00904f63          	bgtz	s1,80001d96 <growproc+0x3c>
  } else if(n < 0){
    80001d7c:	0204cc63          	bltz	s1,80001db4 <growproc+0x5a>
  p->sz = sz;
    80001d80:	1602                	slli	a2,a2,0x20
    80001d82:	9201                	srli	a2,a2,0x20
    80001d84:	06c93823          	sd	a2,112(s2)
  return 0;
    80001d88:	4501                	li	a0,0
}
    80001d8a:	60e2                	ld	ra,24(sp)
    80001d8c:	6442                	ld	s0,16(sp)
    80001d8e:	64a2                	ld	s1,8(sp)
    80001d90:	6902                	ld	s2,0(sp)
    80001d92:	6105                	addi	sp,sp,32
    80001d94:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d96:	9e25                	addw	a2,a2,s1
    80001d98:	1602                	slli	a2,a2,0x20
    80001d9a:	9201                	srli	a2,a2,0x20
    80001d9c:	1582                	slli	a1,a1,0x20
    80001d9e:	9181                	srli	a1,a1,0x20
    80001da0:	7d28                	ld	a0,120(a0)
    80001da2:	fffff097          	auipc	ra,0xfffff
    80001da6:	64c080e7          	jalr	1612(ra) # 800013ee <uvmalloc>
    80001daa:	0005061b          	sext.w	a2,a0
    80001dae:	fa69                	bnez	a2,80001d80 <growproc+0x26>
      return -1;
    80001db0:	557d                	li	a0,-1
    80001db2:	bfe1                	j	80001d8a <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001db4:	9e25                	addw	a2,a2,s1
    80001db6:	1602                	slli	a2,a2,0x20
    80001db8:	9201                	srli	a2,a2,0x20
    80001dba:	1582                	slli	a1,a1,0x20
    80001dbc:	9181                	srli	a1,a1,0x20
    80001dbe:	7d28                	ld	a0,120(a0)
    80001dc0:	fffff097          	auipc	ra,0xfffff
    80001dc4:	5e6080e7          	jalr	1510(ra) # 800013a6 <uvmdealloc>
    80001dc8:	0005061b          	sext.w	a2,a0
    80001dcc:	bf55                	j	80001d80 <growproc+0x26>

0000000080001dce <perfi>:
perfi(struct proc *proc, struct perf *perf){
    80001dce:	1141                	addi	sp,sp,-16
    80001dd0:	e422                	sd	s0,8(sp)
    80001dd2:	0800                	addi	s0,sp,16
  perf->ctime = proc->ctime;
    80001dd4:	5d1c                	lw	a5,56(a0)
    80001dd6:	c19c                	sw	a5,0(a1)
  perf->ttime = proc->ttime;
    80001dd8:	5d5c                	lw	a5,60(a0)
    80001dda:	c1dc                	sw	a5,4(a1)
  perf->stime = proc->stime;
    80001ddc:	413c                	lw	a5,64(a0)
    80001dde:	c59c                	sw	a5,8(a1)
  perf->retime = proc->retime;
    80001de0:	417c                	lw	a5,68(a0)
    80001de2:	c5dc                	sw	a5,12(a1)
  perf->rutime = proc->rutime;
    80001de4:	453c                	lw	a5,72(a0)
    80001de6:	c99c                	sw	a5,16(a1)
  perf->bursttime = proc->average_bursttime;
    80001de8:	457c                	lw	a5,76(a0)
    80001dea:	c9dc                	sw	a5,20(a1)
}
    80001dec:	6422                	ld	s0,8(sp)
    80001dee:	0141                	addi	sp,sp,16
    80001df0:	8082                	ret

0000000080001df2 <fork>:
{
    80001df2:	7139                	addi	sp,sp,-64
    80001df4:	fc06                	sd	ra,56(sp)
    80001df6:	f822                	sd	s0,48(sp)
    80001df8:	f426                	sd	s1,40(sp)
    80001dfa:	f04a                	sd	s2,32(sp)
    80001dfc:	ec4e                	sd	s3,24(sp)
    80001dfe:	e852                	sd	s4,16(sp)
    80001e00:	e456                	sd	s5,8(sp)
    80001e02:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e04:	00000097          	auipc	ra,0x0
    80001e08:	bc2080e7          	jalr	-1086(ra) # 800019c6 <myproc>
    80001e0c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e0e:	00000097          	auipc	ra,0x0
    80001e12:	dc2080e7          	jalr	-574(ra) # 80001bd0 <allocproc>
    80001e16:	12050a63          	beqz	a0,80001f4a <fork+0x158>
    80001e1a:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e1c:	070ab603          	ld	a2,112(s5)
    80001e20:	7d2c                	ld	a1,120(a0)
    80001e22:	078ab503          	ld	a0,120(s5)
    80001e26:	fffff097          	auipc	ra,0xfffff
    80001e2a:	714080e7          	jalr	1812(ra) # 8000153a <uvmcopy>
    80001e2e:	04054863          	bltz	a0,80001e7e <fork+0x8c>
  np->sz = p->sz;
    80001e32:	070ab783          	ld	a5,112(s5)
    80001e36:	06f9b823          	sd	a5,112(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e3a:	080ab683          	ld	a3,128(s5)
    80001e3e:	87b6                	mv	a5,a3
    80001e40:	0809b703          	ld	a4,128(s3)
    80001e44:	12068693          	addi	a3,a3,288
    80001e48:	0007b803          	ld	a6,0(a5)
    80001e4c:	6788                	ld	a0,8(a5)
    80001e4e:	6b8c                	ld	a1,16(a5)
    80001e50:	6f90                	ld	a2,24(a5)
    80001e52:	01073023          	sd	a6,0(a4)
    80001e56:	e708                	sd	a0,8(a4)
    80001e58:	eb0c                	sd	a1,16(a4)
    80001e5a:	ef10                	sd	a2,24(a4)
    80001e5c:	02078793          	addi	a5,a5,32
    80001e60:	02070713          	addi	a4,a4,32
    80001e64:	fed792e3          	bne	a5,a3,80001e48 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e68:	0809b783          	ld	a5,128(s3)
    80001e6c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e70:	0f8a8493          	addi	s1,s5,248
    80001e74:	0f898913          	addi	s2,s3,248
    80001e78:	178a8a13          	addi	s4,s5,376
    80001e7c:	a00d                	j	80001e9e <fork+0xac>
    freeproc(np);
    80001e7e:	854e                	mv	a0,s3
    80001e80:	00000097          	auipc	ra,0x0
    80001e84:	cf8080e7          	jalr	-776(ra) # 80001b78 <freeproc>
    release(&np->lock);
    80001e88:	854e                	mv	a0,s3
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	dec080e7          	jalr	-532(ra) # 80000c76 <release>
    return -1;
    80001e92:	597d                	li	s2,-1
    80001e94:	a04d                	j	80001f36 <fork+0x144>
  for(i = 0; i < NOFILE; i++)
    80001e96:	04a1                	addi	s1,s1,8
    80001e98:	0921                	addi	s2,s2,8
    80001e9a:	01448b63          	beq	s1,s4,80001eb0 <fork+0xbe>
    if(p->ofile[i])
    80001e9e:	6088                	ld	a0,0(s1)
    80001ea0:	d97d                	beqz	a0,80001e96 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ea2:	00003097          	auipc	ra,0x3
    80001ea6:	cf0080e7          	jalr	-784(ra) # 80004b92 <filedup>
    80001eaa:	00a93023          	sd	a0,0(s2)
    80001eae:	b7e5                	j	80001e96 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001eb0:	178ab503          	ld	a0,376(s5)
    80001eb4:	00002097          	auipc	ra,0x2
    80001eb8:	e50080e7          	jalr	-432(ra) # 80003d04 <idup>
    80001ebc:	16a9bc23          	sd	a0,376(s3)
  np->tracemask = p->tracemask;
    80001ec0:	034aa783          	lw	a5,52(s5)
    80001ec4:	02f9aa23          	sw	a5,52(s3)
  np->decay_factor = p->decay_factor;
    80001ec8:	050aa783          	lw	a5,80(s5)
    80001ecc:	04f9a823          	sw	a5,80(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ed0:	4641                	li	a2,16
    80001ed2:	180a8593          	addi	a1,s5,384
    80001ed6:	18098513          	addi	a0,s3,384
    80001eda:	fffff097          	auipc	ra,0xfffff
    80001ede:	f36080e7          	jalr	-202(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80001ee2:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001ee6:	854e                	mv	a0,s3
    80001ee8:	fffff097          	auipc	ra,0xfffff
    80001eec:	d8e080e7          	jalr	-626(ra) # 80000c76 <release>
  acquire(&wait_lock);
    80001ef0:	0000f497          	auipc	s1,0xf
    80001ef4:	3c848493          	addi	s1,s1,968 # 800112b8 <wait_lock>
    80001ef8:	8526                	mv	a0,s1
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	cc8080e7          	jalr	-824(ra) # 80000bc2 <acquire>
  np->parent = p;
    80001f02:	0759b023          	sd	s5,96(s3)
  release(&wait_lock);
    80001f06:	8526                	mv	a0,s1
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	d6e080e7          	jalr	-658(ra) # 80000c76 <release>
  acquire(&np->lock);
    80001f10:	854e                	mv	a0,s3
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	cb0080e7          	jalr	-848(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80001f1a:	478d                	li	a5,3
    80001f1c:	00f9ac23          	sw	a5,24(s3)
  np->runnable_since = ticks;
    80001f20:	00007797          	auipc	a5,0x7
    80001f24:	1107a783          	lw	a5,272(a5) # 80009030 <ticks>
    80001f28:	04f9ac23          	sw	a5,88(s3)
  release(&np->lock);
    80001f2c:	854e                	mv	a0,s3
    80001f2e:	fffff097          	auipc	ra,0xfffff
    80001f32:	d48080e7          	jalr	-696(ra) # 80000c76 <release>
}
    80001f36:	854a                	mv	a0,s2
    80001f38:	70e2                	ld	ra,56(sp)
    80001f3a:	7442                	ld	s0,48(sp)
    80001f3c:	74a2                	ld	s1,40(sp)
    80001f3e:	7902                	ld	s2,32(sp)
    80001f40:	69e2                	ld	s3,24(sp)
    80001f42:	6a42                	ld	s4,16(sp)
    80001f44:	6aa2                	ld	s5,8(sp)
    80001f46:	6121                	addi	sp,sp,64
    80001f48:	8082                	ret
    return -1;
    80001f4a:	597d                	li	s2,-1
    80001f4c:	b7ed                	j	80001f36 <fork+0x144>

0000000080001f4e <FCFS_compare>:
FCFS_compare(struct proc *p1,struct proc *p2){
    80001f4e:	1141                	addi	sp,sp,-16
    80001f50:	e422                	sd	s0,8(sp)
    80001f52:	0800                	addi	s0,sp,16
  return p1->runnable_since - p2->runnable_since;
    80001f54:	4d28                	lw	a0,88(a0)
    80001f56:	4dbc                	lw	a5,88(a1)
}
    80001f58:	9d1d                	subw	a0,a0,a5
    80001f5a:	6422                	ld	s0,8(sp)
    80001f5c:	0141                	addi	sp,sp,16
    80001f5e:	8082                	ret

0000000080001f60 <CFSD_compare>:
CFSD_compare(struct proc *p1,struct proc *p2){
    80001f60:	1141                	addi	sp,sp,-16
    80001f62:	e422                	sd	s0,8(sp)
    80001f64:	0800                	addi	s0,sp,16
  int p1_priority=(p1->rutime*p1->decay_factor)/(p1->rutime+p1->stime);
    80001f66:	453c                	lw	a5,72(a0)
  int p2_priority=(p2->rutime*p2->decay_factor)/(p2->rutime+p2->stime);
    80001f68:	45b4                	lw	a3,72(a1)
  int p1_priority=(p1->rutime*p1->decay_factor)/(p1->rutime+p1->stime);
    80001f6a:	4938                	lw	a4,80(a0)
    80001f6c:	02f7073b          	mulw	a4,a4,a5
    80001f70:	4128                	lw	a0,64(a0)
    80001f72:	9d3d                	addw	a0,a0,a5
    80001f74:	02a7453b          	divw	a0,a4,a0
  int p2_priority=(p2->rutime*p2->decay_factor)/(p2->rutime+p2->stime);
    80001f78:	49bc                	lw	a5,80(a1)
    80001f7a:	02d787bb          	mulw	a5,a5,a3
    80001f7e:	41b8                	lw	a4,64(a1)
    80001f80:	9f35                	addw	a4,a4,a3
    80001f82:	02e7c7bb          	divw	a5,a5,a4
}
    80001f86:	9d1d                	subw	a0,a0,a5
    80001f88:	6422                	ld	s0,8(sp)
    80001f8a:	0141                	addi	sp,sp,16
    80001f8c:	8082                	ret

0000000080001f8e <default_policy>:
default_policy(){
    80001f8e:	7139                	addi	sp,sp,-64
    80001f90:	fc06                	sd	ra,56(sp)
    80001f92:	f822                	sd	s0,48(sp)
    80001f94:	f426                	sd	s1,40(sp)
    80001f96:	f04a                	sd	s2,32(sp)
    80001f98:	ec4e                	sd	s3,24(sp)
    80001f9a:	e852                	sd	s4,16(sp)
    80001f9c:	e456                	sd	s5,8(sp)
    80001f9e:	e05a                	sd	s6,0(sp)
    80001fa0:	0080                	addi	s0,sp,64
    80001fa2:	8792                	mv	a5,tp
  int id = r_tp();
    80001fa4:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fa6:	00779a93          	slli	s5,a5,0x7
    80001faa:	0000f717          	auipc	a4,0xf
    80001fae:	2f670713          	addi	a4,a4,758 # 800112a0 <pid_lock>
    80001fb2:	9756                	add	a4,a4,s5
    80001fb4:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001fb8:	0000f717          	auipc	a4,0xf
    80001fbc:	32070713          	addi	a4,a4,800 # 800112d8 <cpus+0x8>
    80001fc0:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001fc2:	498d                	li	s3,3
        p->state = RUNNING;
    80001fc4:	4b11                	li	s6,4
        c->proc = p;
    80001fc6:	079e                	slli	a5,a5,0x7
    80001fc8:	0000fa17          	auipc	s4,0xf
    80001fcc:	2d8a0a13          	addi	s4,s4,728 # 800112a0 <pid_lock>
    80001fd0:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fd2:	00016917          	auipc	s2,0x16
    80001fd6:	afe90913          	addi	s2,s2,-1282 # 80017ad0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fda:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fde:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fe2:	10079073          	csrw	sstatus,a5
    80001fe6:	0000f497          	auipc	s1,0xf
    80001fea:	6ea48493          	addi	s1,s1,1770 # 800116d0 <proc>
    80001fee:	a811                	j	80002002 <default_policy+0x74>
      release(&p->lock);
    80001ff0:	8526                	mv	a0,s1
    80001ff2:	fffff097          	auipc	ra,0xfffff
    80001ff6:	c84080e7          	jalr	-892(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ffa:	19048493          	addi	s1,s1,400
    80001ffe:	fd248ee3          	beq	s1,s2,80001fda <default_policy+0x4c>
      acquire(&p->lock);
    80002002:	8526                	mv	a0,s1
    80002004:	fffff097          	auipc	ra,0xfffff
    80002008:	bbe080e7          	jalr	-1090(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE) {
    8000200c:	4c9c                	lw	a5,24(s1)
    8000200e:	ff3791e3          	bne	a5,s3,80001ff0 <default_policy+0x62>
        p->state = RUNNING;
    80002012:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002016:	029a3823          	sd	s1,48(s4)
        p->current_runtime = 0;
    8000201a:	0404aa23          	sw	zero,84(s1)
        swtch(&c->context, &p->context);
    8000201e:	08848593          	addi	a1,s1,136
    80002022:	8556                	mv	a0,s5
    80002024:	00001097          	auipc	ra,0x1
    80002028:	afe080e7          	jalr	-1282(ra) # 80002b22 <swtch>
        c->proc = 0;
    8000202c:	020a3823          	sd	zero,48(s4)
    80002030:	b7c1                	j	80001ff0 <default_policy+0x62>

0000000080002032 <comperative_policy>:
comperative_policy(int (*compare)(struct proc *p1, struct proc *p2)){
    80002032:	7119                	addi	sp,sp,-128
    80002034:	fc86                	sd	ra,120(sp)
    80002036:	f8a2                	sd	s0,112(sp)
    80002038:	f4a6                	sd	s1,104(sp)
    8000203a:	f0ca                	sd	s2,96(sp)
    8000203c:	ecce                	sd	s3,88(sp)
    8000203e:	e8d2                	sd	s4,80(sp)
    80002040:	e4d6                	sd	s5,72(sp)
    80002042:	e0da                	sd	s6,64(sp)
    80002044:	fc5e                	sd	s7,56(sp)
    80002046:	f862                	sd	s8,48(sp)
    80002048:	f466                	sd	s9,40(sp)
    8000204a:	f06a                	sd	s10,32(sp)
    8000204c:	ec6e                	sd	s11,24(sp)
    8000204e:	0100                	addi	s0,sp,128
    80002050:	8baa                	mv	s7,a0
  asm volatile("mv %0, tp" : "=r" (x) );
    80002052:	8492                	mv	s1,tp
  int id = r_tp();
    80002054:	2481                	sext.w	s1,s1
  c->proc = 0;
    80002056:	00749713          	slli	a4,s1,0x7
    8000205a:	0000f797          	auipc	a5,0xf
    8000205e:	24678793          	addi	a5,a5,582 # 800112a0 <pid_lock>
    80002062:	97ba                	add	a5,a5,a4
    80002064:	0207b823          	sd	zero,48(a5)
  struct proc *p1=myproc();
    80002068:	00000097          	auipc	ra,0x0
    8000206c:	95e080e7          	jalr	-1698(ra) # 800019c6 <myproc>
  int mypid=-1;
    80002070:	5b7d                	li	s6,-1
  if(p1 != 0){
    80002072:	c119                	beqz	a0,80002078 <comperative_policy+0x46>
     mypid=p1->pid;
    80002074:	03052b03          	lw	s6,48(a0)
        swtch(&c->context, &next_p->context);
    80002078:	00749713          	slli	a4,s1,0x7
    8000207c:	0000f797          	auipc	a5,0xf
    80002080:	25c78793          	addi	a5,a5,604 # 800112d8 <cpus+0x8>
    80002084:	97ba                	add	a5,a5,a4
    80002086:	f8f43423          	sd	a5,-120(s0)
    8000208a:	4a01                	li	s4,0
          printf("%d acquired procces %d and its runnable and he wants it\n",mypid,p->pid);      
    8000208c:	00006c17          	auipc	s8,0x6
    80002090:	234c0c13          	addi	s8,s8,564 # 800082c0 <digits+0x280>
            printf("sched %d trying to acquire previous next process: %d\n",mypid,next_p->pid);
    80002094:	00006d17          	auipc	s10,0x6
    80002098:	194d0d13          	addi	s10,s10,404 # 80008228 <digits+0x1e8>
            printf("sched %d acquired previous next process: %d\n",mypid,next_p->pid);
    8000209c:	00006c97          	auipc	s9,0x6
    800020a0:	1c4c8c93          	addi	s9,s9,452 # 80008260 <digits+0x220>
    for(p = proc; p < &proc[NPROC]; p++) {
    800020a4:	00016997          	auipc	s3,0x16
    800020a8:	a2c98993          	addi	s3,s3,-1492 # 80017ad0 <tickslock>
        c->proc = next_p;
    800020ac:	0000fd97          	auipc	s11,0xf
    800020b0:	1f4d8d93          	addi	s11,s11,500 # 800112a0 <pid_lock>
    800020b4:	9dba                	add	s11,s11,a4
    800020b6:	a8a9                	j	80002110 <comperative_policy+0xde>
    if(next_p!=0 ){
    800020b8:	040a0c63          	beqz	s4,80002110 <comperative_policy+0xde>
      acquire(&next_p->lock);
    800020bc:	84d2                	mv	s1,s4
    800020be:	8552                	mv	a0,s4
    800020c0:	fffff097          	auipc	ra,0xfffff
    800020c4:	b02080e7          	jalr	-1278(ra) # 80000bc2 <acquire>
      if(next_p->state==RUNNABLE){
    800020c8:	018a2703          	lw	a4,24(s4)
    800020cc:	478d                	li	a5,3
    800020ce:	02f71a63          	bne	a4,a5,80002102 <comperative_policy+0xd0>
        next_p->state = RUNNING;
    800020d2:	4791                	li	a5,4
    800020d4:	00fa2c23          	sw	a5,24(s4)
        c->proc = next_p;
    800020d8:	034db823          	sd	s4,48(s11)
        next_p->current_runtime = 0;
    800020dc:	040a2a23          	sw	zero,84(s4)
        swtch(&c->context, &next_p->context);
    800020e0:	088a0593          	addi	a1,s4,136
    800020e4:	f8843503          	ld	a0,-120(s0)
    800020e8:	00001097          	auipc	ra,0x1
    800020ec:	a3a080e7          	jalr	-1478(ra) # 80002b22 <swtch>
        c->proc=0;
    800020f0:	020db823          	sd	zero,48(s11)
        next_p->runnable_since=ticks+1;
    800020f4:	00007797          	auipc	a5,0x7
    800020f8:	f3c7a783          	lw	a5,-196(a5) # 80009030 <ticks>
    800020fc:	2785                	addiw	a5,a5,1
    800020fe:	04fa2c23          	sw	a5,88(s4)
      next_p->chosen = 0;
    80002102:	040a2e23          	sw	zero,92(s4)
      release(&next_p->lock);
    80002106:	8526                	mv	a0,s1
    80002108:	fffff097          	auipc	ra,0xfffff
    8000210c:	b6e080e7          	jalr	-1170(ra) # 80000c76 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002110:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002114:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002118:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000211c:	0000f497          	auipc	s1,0xf
    80002120:	5b448493          	addi	s1,s1,1460 # 800116d0 <proc>
      if(p->state == RUNNABLE && p->chosen == 0) {
    80002124:	490d                	li	s2,3
          p->chosen=1;
    80002126:	4a85                	li	s5,1
    80002128:	a025                	j	80002150 <comperative_policy+0x11e>
          printf("%d acquired procces %d and its runnable and he wants it\n",mypid,p->pid);      
    8000212a:	5890                	lw	a2,48(s1)
    8000212c:	85da                	mv	a1,s6
    8000212e:	8562                	mv	a0,s8
    80002130:	ffffe097          	auipc	ra,0xffffe
    80002134:	444080e7          	jalr	1092(ra) # 80000574 <printf>
          p->chosen=1;
    80002138:	0554ae23          	sw	s5,92(s1)
    8000213c:	8a26                	mv	s4,s1
      release(&p->lock);
    8000213e:	8526                	mv	a0,s1
    80002140:	fffff097          	auipc	ra,0xfffff
    80002144:	b36080e7          	jalr	-1226(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002148:	19048493          	addi	s1,s1,400
    8000214c:	f73486e3          	beq	s1,s3,800020b8 <comperative_policy+0x86>
      acquire(&p->lock);
    80002150:	8526                	mv	a0,s1
    80002152:	fffff097          	auipc	ra,0xfffff
    80002156:	a70080e7          	jalr	-1424(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE && p->chosen == 0) {
    8000215a:	4c9c                	lw	a5,24(s1)
    8000215c:	ff2791e3          	bne	a5,s2,8000213e <comperative_policy+0x10c>
    80002160:	4cfc                	lw	a5,92(s1)
    80002162:	fff1                	bnez	a5,8000213e <comperative_policy+0x10c>
        if(next_p == 0 || compare(next_p, p) > 0){  
    80002164:	fc0a03e3          	beqz	s4,8000212a <comperative_policy+0xf8>
    80002168:	85a6                	mv	a1,s1
    8000216a:	8552                	mv	a0,s4
    8000216c:	9b82                	jalr	s7
    8000216e:	fca058e3          	blez	a0,8000213e <comperative_policy+0x10c>
          printf("%d acquired procces %d and its runnable and he wants it\n",mypid,p->pid);      
    80002172:	5890                	lw	a2,48(s1)
    80002174:	85da                	mv	a1,s6
    80002176:	8562                	mv	a0,s8
    80002178:	ffffe097          	auipc	ra,0xffffe
    8000217c:	3fc080e7          	jalr	1020(ra) # 80000574 <printf>
          if( next_p!=0 && next_p->chosen==1){
    80002180:	05ca2783          	lw	a5,92(s4)
    80002184:	fb579ae3          	bne	a5,s5,80002138 <comperative_policy+0x106>
            printf("sched %d trying to acquire previous next process: %d\n",mypid,next_p->pid);
    80002188:	030a2603          	lw	a2,48(s4)
    8000218c:	85da                	mv	a1,s6
    8000218e:	856a                	mv	a0,s10
    80002190:	ffffe097          	auipc	ra,0xffffe
    80002194:	3e4080e7          	jalr	996(ra) # 80000574 <printf>
            acquire(&next_p->lock);
    80002198:	8552                	mv	a0,s4
    8000219a:	fffff097          	auipc	ra,0xfffff
    8000219e:	a28080e7          	jalr	-1496(ra) # 80000bc2 <acquire>
            printf("sched %d acquired previous next process: %d\n",mypid,next_p->pid);
    800021a2:	030a2603          	lw	a2,48(s4)
    800021a6:	85da                	mv	a1,s6
    800021a8:	8566                	mv	a0,s9
    800021aa:	ffffe097          	auipc	ra,0xffffe
    800021ae:	3ca080e7          	jalr	970(ra) # 80000574 <printf>
            next_p->chosen = 0;
    800021b2:	040a2e23          	sw	zero,92(s4)
            release(&next_p->lock);
    800021b6:	8552                	mv	a0,s4
    800021b8:	fffff097          	auipc	ra,0xfffff
    800021bc:	abe080e7          	jalr	-1346(ra) # 80000c76 <release>
            printf("sched %d released previous next process: %d\n",mypid,next_p->pid);
    800021c0:	030a2603          	lw	a2,48(s4)
    800021c4:	85da                	mv	a1,s6
    800021c6:	00006517          	auipc	a0,0x6
    800021ca:	0ca50513          	addi	a0,a0,202 # 80008290 <digits+0x250>
    800021ce:	ffffe097          	auipc	ra,0xffffe
    800021d2:	3a6080e7          	jalr	934(ra) # 80000574 <printf>
    800021d6:	b78d                	j	80002138 <comperative_policy+0x106>

00000000800021d8 <scheduler>:
{
    800021d8:	1141                	addi	sp,sp,-16
    800021da:	e406                	sd	ra,8(sp)
    800021dc:	e022                	sd	s0,0(sp)
    800021de:	0800                	addi	s0,sp,16
    printf("SRT schedueling policy active\n");
    800021e0:	00006517          	auipc	a0,0x6
    800021e4:	12050513          	addi	a0,a0,288 # 80008300 <digits+0x2c0>
    800021e8:	ffffe097          	auipc	ra,0xffffe
    800021ec:	38c080e7          	jalr	908(ra) # 80000574 <printf>
    comperative_policy(&SRT_compare);
    800021f0:	fffff517          	auipc	a0,0xfffff
    800021f4:	61c50513          	addi	a0,a0,1564 # 8000180c <SRT_compare>
    800021f8:	00000097          	auipc	ra,0x0
    800021fc:	e3a080e7          	jalr	-454(ra) # 80002032 <comperative_policy>

0000000080002200 <sched>:
{
    80002200:	7179                	addi	sp,sp,-48
    80002202:	f406                	sd	ra,40(sp)
    80002204:	f022                	sd	s0,32(sp)
    80002206:	ec26                	sd	s1,24(sp)
    80002208:	e84a                	sd	s2,16(sp)
    8000220a:	e44e                	sd	s3,8(sp)
    8000220c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000220e:	fffff097          	auipc	ra,0xfffff
    80002212:	7b8080e7          	jalr	1976(ra) # 800019c6 <myproc>
    80002216:	84aa                	mv	s1,a0
  p->average_bursttime =  ALPHA * (ticks - p->runnable_since) + ((100-ALPHA) * p->average_bursttime) / 100;
    80002218:	4d38                	lw	a4,88(a0)
    8000221a:	00007797          	auipc	a5,0x7
    8000221e:	e167a783          	lw	a5,-490(a5) # 80009030 <ticks>
    80002222:	9f99                	subw	a5,a5,a4
    80002224:	03200713          	li	a4,50
    80002228:	02e787bb          	mulw	a5,a5,a4
    8000222c:	4574                	lw	a3,76(a0)
    8000222e:	01f6d71b          	srliw	a4,a3,0x1f
    80002232:	9f35                	addw	a4,a4,a3
    80002234:	4017571b          	sraiw	a4,a4,0x1
    80002238:	9fb9                	addw	a5,a5,a4
    8000223a:	c57c                	sw	a5,76(a0)
  if(!holding(&p->lock))
    8000223c:	fffff097          	auipc	ra,0xfffff
    80002240:	90c080e7          	jalr	-1780(ra) # 80000b48 <holding>
    80002244:	c93d                	beqz	a0,800022ba <sched+0xba>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002246:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002248:	2781                	sext.w	a5,a5
    8000224a:	079e                	slli	a5,a5,0x7
    8000224c:	0000f717          	auipc	a4,0xf
    80002250:	05470713          	addi	a4,a4,84 # 800112a0 <pid_lock>
    80002254:	97ba                	add	a5,a5,a4
    80002256:	0a87a703          	lw	a4,168(a5)
    8000225a:	4785                	li	a5,1
    8000225c:	06f71763          	bne	a4,a5,800022ca <sched+0xca>
  if(p->state == RUNNING)
    80002260:	4c98                	lw	a4,24(s1)
    80002262:	4791                	li	a5,4
    80002264:	06f70b63          	beq	a4,a5,800022da <sched+0xda>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002268:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000226c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000226e:	efb5                	bnez	a5,800022ea <sched+0xea>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002270:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002272:	0000f917          	auipc	s2,0xf
    80002276:	02e90913          	addi	s2,s2,46 # 800112a0 <pid_lock>
    8000227a:	2781                	sext.w	a5,a5
    8000227c:	079e                	slli	a5,a5,0x7
    8000227e:	97ca                	add	a5,a5,s2
    80002280:	0ac7a983          	lw	s3,172(a5)
    80002284:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002286:	2781                	sext.w	a5,a5
    80002288:	079e                	slli	a5,a5,0x7
    8000228a:	0000f597          	auipc	a1,0xf
    8000228e:	04e58593          	addi	a1,a1,78 # 800112d8 <cpus+0x8>
    80002292:	95be                	add	a1,a1,a5
    80002294:	08848513          	addi	a0,s1,136
    80002298:	00001097          	auipc	ra,0x1
    8000229c:	88a080e7          	jalr	-1910(ra) # 80002b22 <swtch>
    800022a0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800022a2:	2781                	sext.w	a5,a5
    800022a4:	079e                	slli	a5,a5,0x7
    800022a6:	97ca                	add	a5,a5,s2
    800022a8:	0b37a623          	sw	s3,172(a5)
}
    800022ac:	70a2                	ld	ra,40(sp)
    800022ae:	7402                	ld	s0,32(sp)
    800022b0:	64e2                	ld	s1,24(sp)
    800022b2:	6942                	ld	s2,16(sp)
    800022b4:	69a2                	ld	s3,8(sp)
    800022b6:	6145                	addi	sp,sp,48
    800022b8:	8082                	ret
    panic("sched p->lock");
    800022ba:	00006517          	auipc	a0,0x6
    800022be:	06650513          	addi	a0,a0,102 # 80008320 <digits+0x2e0>
    800022c2:	ffffe097          	auipc	ra,0xffffe
    800022c6:	268080e7          	jalr	616(ra) # 8000052a <panic>
    panic("sched locks");
    800022ca:	00006517          	auipc	a0,0x6
    800022ce:	06650513          	addi	a0,a0,102 # 80008330 <digits+0x2f0>
    800022d2:	ffffe097          	auipc	ra,0xffffe
    800022d6:	258080e7          	jalr	600(ra) # 8000052a <panic>
    panic("sched running");
    800022da:	00006517          	auipc	a0,0x6
    800022de:	06650513          	addi	a0,a0,102 # 80008340 <digits+0x300>
    800022e2:	ffffe097          	auipc	ra,0xffffe
    800022e6:	248080e7          	jalr	584(ra) # 8000052a <panic>
    panic("sched interruptible");
    800022ea:	00006517          	auipc	a0,0x6
    800022ee:	06650513          	addi	a0,a0,102 # 80008350 <digits+0x310>
    800022f2:	ffffe097          	auipc	ra,0xffffe
    800022f6:	238080e7          	jalr	568(ra) # 8000052a <panic>

00000000800022fa <yield>:
{
    800022fa:	1101                	addi	sp,sp,-32
    800022fc:	ec06                	sd	ra,24(sp)
    800022fe:	e822                	sd	s0,16(sp)
    80002300:	e426                	sd	s1,8(sp)
    80002302:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	6c2080e7          	jalr	1730(ra) # 800019c6 <myproc>
    8000230c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000230e:	fffff097          	auipc	ra,0xfffff
    80002312:	8b4080e7          	jalr	-1868(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    80002316:	478d                	li	a5,3
    80002318:	cc9c                	sw	a5,24(s1)
  p->runnable_since=ticks;
    8000231a:	00007797          	auipc	a5,0x7
    8000231e:	d167a783          	lw	a5,-746(a5) # 80009030 <ticks>
    80002322:	ccbc                	sw	a5,88(s1)
  sched();
    80002324:	00000097          	auipc	ra,0x0
    80002328:	edc080e7          	jalr	-292(ra) # 80002200 <sched>
  release(&p->lock);
    8000232c:	8526                	mv	a0,s1
    8000232e:	fffff097          	auipc	ra,0xfffff
    80002332:	948080e7          	jalr	-1720(ra) # 80000c76 <release>
}
    80002336:	60e2                	ld	ra,24(sp)
    80002338:	6442                	ld	s0,16(sp)
    8000233a:	64a2                	ld	s1,8(sp)
    8000233c:	6105                	addi	sp,sp,32
    8000233e:	8082                	ret

0000000080002340 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002340:	7179                	addi	sp,sp,-48
    80002342:	f406                	sd	ra,40(sp)
    80002344:	f022                	sd	s0,32(sp)
    80002346:	ec26                	sd	s1,24(sp)
    80002348:	e84a                	sd	s2,16(sp)
    8000234a:	e44e                	sd	s3,8(sp)
    8000234c:	1800                	addi	s0,sp,48
    8000234e:	89aa                	mv	s3,a0
    80002350:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	674080e7          	jalr	1652(ra) # 800019c6 <myproc>
    8000235a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000235c:	fffff097          	auipc	ra,0xfffff
    80002360:	866080e7          	jalr	-1946(ra) # 80000bc2 <acquire>
  release(lk);
    80002364:	854a                	mv	a0,s2
    80002366:	fffff097          	auipc	ra,0xfffff
    8000236a:	910080e7          	jalr	-1776(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    8000236e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002372:	4789                	li	a5,2
    80002374:	cc9c                	sw	a5,24(s1)

  sched();
    80002376:	00000097          	auipc	ra,0x0
    8000237a:	e8a080e7          	jalr	-374(ra) # 80002200 <sched>

  // Tidy up.
  p->chan = 0;
    8000237e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002382:	8526                	mv	a0,s1
    80002384:	fffff097          	auipc	ra,0xfffff
    80002388:	8f2080e7          	jalr	-1806(ra) # 80000c76 <release>
  acquire(lk);
    8000238c:	854a                	mv	a0,s2
    8000238e:	fffff097          	auipc	ra,0xfffff
    80002392:	834080e7          	jalr	-1996(ra) # 80000bc2 <acquire>
}
    80002396:	70a2                	ld	ra,40(sp)
    80002398:	7402                	ld	s0,32(sp)
    8000239a:	64e2                	ld	s1,24(sp)
    8000239c:	6942                	ld	s2,16(sp)
    8000239e:	69a2                	ld	s3,8(sp)
    800023a0:	6145                	addi	sp,sp,48
    800023a2:	8082                	ret

00000000800023a4 <wait>:
{
    800023a4:	715d                	addi	sp,sp,-80
    800023a6:	e486                	sd	ra,72(sp)
    800023a8:	e0a2                	sd	s0,64(sp)
    800023aa:	fc26                	sd	s1,56(sp)
    800023ac:	f84a                	sd	s2,48(sp)
    800023ae:	f44e                	sd	s3,40(sp)
    800023b0:	f052                	sd	s4,32(sp)
    800023b2:	ec56                	sd	s5,24(sp)
    800023b4:	e85a                	sd	s6,16(sp)
    800023b6:	e45e                	sd	s7,8(sp)
    800023b8:	e062                	sd	s8,0(sp)
    800023ba:	0880                	addi	s0,sp,80
    800023bc:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	608080e7          	jalr	1544(ra) # 800019c6 <myproc>
    800023c6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023c8:	0000f517          	auipc	a0,0xf
    800023cc:	ef050513          	addi	a0,a0,-272 # 800112b8 <wait_lock>
    800023d0:	ffffe097          	auipc	ra,0xffffe
    800023d4:	7f2080e7          	jalr	2034(ra) # 80000bc2 <acquire>
    havekids = 0;
    800023d8:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800023da:	4a15                	li	s4,5
        havekids = 1;
    800023dc:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800023de:	00015997          	auipc	s3,0x15
    800023e2:	6f298993          	addi	s3,s3,1778 # 80017ad0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023e6:	0000fc17          	auipc	s8,0xf
    800023ea:	ed2c0c13          	addi	s8,s8,-302 # 800112b8 <wait_lock>
    havekids = 0;
    800023ee:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800023f0:	0000f497          	auipc	s1,0xf
    800023f4:	2e048493          	addi	s1,s1,736 # 800116d0 <proc>
    800023f8:	a0bd                	j	80002466 <wait+0xc2>
          pid = np->pid;
    800023fa:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800023fe:	000b0e63          	beqz	s6,8000241a <wait+0x76>
    80002402:	4691                	li	a3,4
    80002404:	02c48613          	addi	a2,s1,44
    80002408:	85da                	mv	a1,s6
    8000240a:	07893503          	ld	a0,120(s2)
    8000240e:	fffff097          	auipc	ra,0xfffff
    80002412:	230080e7          	jalr	560(ra) # 8000163e <copyout>
    80002416:	02054563          	bltz	a0,80002440 <wait+0x9c>
          freeproc(np);
    8000241a:	8526                	mv	a0,s1
    8000241c:	fffff097          	auipc	ra,0xfffff
    80002420:	75c080e7          	jalr	1884(ra) # 80001b78 <freeproc>
          release(&np->lock);
    80002424:	8526                	mv	a0,s1
    80002426:	fffff097          	auipc	ra,0xfffff
    8000242a:	850080e7          	jalr	-1968(ra) # 80000c76 <release>
          release(&wait_lock);
    8000242e:	0000f517          	auipc	a0,0xf
    80002432:	e8a50513          	addi	a0,a0,-374 # 800112b8 <wait_lock>
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	840080e7          	jalr	-1984(ra) # 80000c76 <release>
          return pid;
    8000243e:	a09d                	j	800024a4 <wait+0x100>
            release(&np->lock);
    80002440:	8526                	mv	a0,s1
    80002442:	fffff097          	auipc	ra,0xfffff
    80002446:	834080e7          	jalr	-1996(ra) # 80000c76 <release>
            release(&wait_lock);
    8000244a:	0000f517          	auipc	a0,0xf
    8000244e:	e6e50513          	addi	a0,a0,-402 # 800112b8 <wait_lock>
    80002452:	fffff097          	auipc	ra,0xfffff
    80002456:	824080e7          	jalr	-2012(ra) # 80000c76 <release>
            return -1;
    8000245a:	59fd                	li	s3,-1
    8000245c:	a0a1                	j	800024a4 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    8000245e:	19048493          	addi	s1,s1,400
    80002462:	03348463          	beq	s1,s3,8000248a <wait+0xe6>
      if(np->parent == p){
    80002466:	70bc                	ld	a5,96(s1)
    80002468:	ff279be3          	bne	a5,s2,8000245e <wait+0xba>
        acquire(&np->lock);
    8000246c:	8526                	mv	a0,s1
    8000246e:	ffffe097          	auipc	ra,0xffffe
    80002472:	754080e7          	jalr	1876(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    80002476:	4c9c                	lw	a5,24(s1)
    80002478:	f94781e3          	beq	a5,s4,800023fa <wait+0x56>
        release(&np->lock);
    8000247c:	8526                	mv	a0,s1
    8000247e:	ffffe097          	auipc	ra,0xffffe
    80002482:	7f8080e7          	jalr	2040(ra) # 80000c76 <release>
        havekids = 1;
    80002486:	8756                	mv	a4,s5
    80002488:	bfd9                	j	8000245e <wait+0xba>
    if(!havekids || p->killed){
    8000248a:	c701                	beqz	a4,80002492 <wait+0xee>
    8000248c:	02892783          	lw	a5,40(s2)
    80002490:	c79d                	beqz	a5,800024be <wait+0x11a>
      release(&wait_lock);
    80002492:	0000f517          	auipc	a0,0xf
    80002496:	e2650513          	addi	a0,a0,-474 # 800112b8 <wait_lock>
    8000249a:	ffffe097          	auipc	ra,0xffffe
    8000249e:	7dc080e7          	jalr	2012(ra) # 80000c76 <release>
      return -1;
    800024a2:	59fd                	li	s3,-1
}
    800024a4:	854e                	mv	a0,s3
    800024a6:	60a6                	ld	ra,72(sp)
    800024a8:	6406                	ld	s0,64(sp)
    800024aa:	74e2                	ld	s1,56(sp)
    800024ac:	7942                	ld	s2,48(sp)
    800024ae:	79a2                	ld	s3,40(sp)
    800024b0:	7a02                	ld	s4,32(sp)
    800024b2:	6ae2                	ld	s5,24(sp)
    800024b4:	6b42                	ld	s6,16(sp)
    800024b6:	6ba2                	ld	s7,8(sp)
    800024b8:	6c02                	ld	s8,0(sp)
    800024ba:	6161                	addi	sp,sp,80
    800024bc:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024be:	85e2                	mv	a1,s8
    800024c0:	854a                	mv	a0,s2
    800024c2:	00000097          	auipc	ra,0x0
    800024c6:	e7e080e7          	jalr	-386(ra) # 80002340 <sleep>
    havekids = 0;
    800024ca:	b715                	j	800023ee <wait+0x4a>

00000000800024cc <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800024cc:	7139                	addi	sp,sp,-64
    800024ce:	fc06                	sd	ra,56(sp)
    800024d0:	f822                	sd	s0,48(sp)
    800024d2:	f426                	sd	s1,40(sp)
    800024d4:	f04a                	sd	s2,32(sp)
    800024d6:	ec4e                	sd	s3,24(sp)
    800024d8:	e852                	sd	s4,16(sp)
    800024da:	e456                	sd	s5,8(sp)
    800024dc:	e05a                	sd	s6,0(sp)
    800024de:	0080                	addi	s0,sp,64
    800024e0:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800024e2:	0000f497          	auipc	s1,0xf
    800024e6:	1ee48493          	addi	s1,s1,494 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800024ea:	4989                	li	s3,2
        p->state = RUNNABLE;
    800024ec:	4b0d                	li	s6,3
        p->runnable_since = ticks;
    800024ee:	00007a97          	auipc	s5,0x7
    800024f2:	b42a8a93          	addi	s5,s5,-1214 # 80009030 <ticks>
  for(p = proc; p < &proc[NPROC]; p++) {
    800024f6:	00015917          	auipc	s2,0x15
    800024fa:	5da90913          	addi	s2,s2,1498 # 80017ad0 <tickslock>
    800024fe:	a811                	j	80002512 <wakeup+0x46>
      }
      release(&p->lock);
    80002500:	8526                	mv	a0,s1
    80002502:	ffffe097          	auipc	ra,0xffffe
    80002506:	774080e7          	jalr	1908(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000250a:	19048493          	addi	s1,s1,400
    8000250e:	03248963          	beq	s1,s2,80002540 <wakeup+0x74>
    if(p != myproc()){
    80002512:	fffff097          	auipc	ra,0xfffff
    80002516:	4b4080e7          	jalr	1204(ra) # 800019c6 <myproc>
    8000251a:	fea488e3          	beq	s1,a0,8000250a <wakeup+0x3e>
      acquire(&p->lock);
    8000251e:	8526                	mv	a0,s1
    80002520:	ffffe097          	auipc	ra,0xffffe
    80002524:	6a2080e7          	jalr	1698(ra) # 80000bc2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002528:	4c9c                	lw	a5,24(s1)
    8000252a:	fd379be3          	bne	a5,s3,80002500 <wakeup+0x34>
    8000252e:	709c                	ld	a5,32(s1)
    80002530:	fd4798e3          	bne	a5,s4,80002500 <wakeup+0x34>
        p->state = RUNNABLE;
    80002534:	0164ac23          	sw	s6,24(s1)
        p->runnable_since = ticks;
    80002538:	000aa783          	lw	a5,0(s5)
    8000253c:	ccbc                	sw	a5,88(s1)
    8000253e:	b7c9                	j	80002500 <wakeup+0x34>
    }
  }
}
    80002540:	70e2                	ld	ra,56(sp)
    80002542:	7442                	ld	s0,48(sp)
    80002544:	74a2                	ld	s1,40(sp)
    80002546:	7902                	ld	s2,32(sp)
    80002548:	69e2                	ld	s3,24(sp)
    8000254a:	6a42                	ld	s4,16(sp)
    8000254c:	6aa2                	ld	s5,8(sp)
    8000254e:	6b02                	ld	s6,0(sp)
    80002550:	6121                	addi	sp,sp,64
    80002552:	8082                	ret

0000000080002554 <reparent>:
{
    80002554:	7179                	addi	sp,sp,-48
    80002556:	f406                	sd	ra,40(sp)
    80002558:	f022                	sd	s0,32(sp)
    8000255a:	ec26                	sd	s1,24(sp)
    8000255c:	e84a                	sd	s2,16(sp)
    8000255e:	e44e                	sd	s3,8(sp)
    80002560:	e052                	sd	s4,0(sp)
    80002562:	1800                	addi	s0,sp,48
    80002564:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002566:	0000f497          	auipc	s1,0xf
    8000256a:	16a48493          	addi	s1,s1,362 # 800116d0 <proc>
      pp->parent = initproc;
    8000256e:	00007a17          	auipc	s4,0x7
    80002572:	abaa0a13          	addi	s4,s4,-1350 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002576:	00015997          	auipc	s3,0x15
    8000257a:	55a98993          	addi	s3,s3,1370 # 80017ad0 <tickslock>
    8000257e:	a029                	j	80002588 <reparent+0x34>
    80002580:	19048493          	addi	s1,s1,400
    80002584:	01348d63          	beq	s1,s3,8000259e <reparent+0x4a>
    if(pp->parent == p){
    80002588:	70bc                	ld	a5,96(s1)
    8000258a:	ff279be3          	bne	a5,s2,80002580 <reparent+0x2c>
      pp->parent = initproc;
    8000258e:	000a3503          	ld	a0,0(s4)
    80002592:	f0a8                	sd	a0,96(s1)
      wakeup(initproc);
    80002594:	00000097          	auipc	ra,0x0
    80002598:	f38080e7          	jalr	-200(ra) # 800024cc <wakeup>
    8000259c:	b7d5                	j	80002580 <reparent+0x2c>
}
    8000259e:	70a2                	ld	ra,40(sp)
    800025a0:	7402                	ld	s0,32(sp)
    800025a2:	64e2                	ld	s1,24(sp)
    800025a4:	6942                	ld	s2,16(sp)
    800025a6:	69a2                	ld	s3,8(sp)
    800025a8:	6a02                	ld	s4,0(sp)
    800025aa:	6145                	addi	sp,sp,48
    800025ac:	8082                	ret

00000000800025ae <exit>:
{
    800025ae:	7179                	addi	sp,sp,-48
    800025b0:	f406                	sd	ra,40(sp)
    800025b2:	f022                	sd	s0,32(sp)
    800025b4:	ec26                	sd	s1,24(sp)
    800025b6:	e84a                	sd	s2,16(sp)
    800025b8:	e44e                	sd	s3,8(sp)
    800025ba:	e052                	sd	s4,0(sp)
    800025bc:	1800                	addi	s0,sp,48
    800025be:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800025c0:	fffff097          	auipc	ra,0xfffff
    800025c4:	406080e7          	jalr	1030(ra) # 800019c6 <myproc>
    800025c8:	89aa                	mv	s3,a0
  if(p == initproc)
    800025ca:	00007797          	auipc	a5,0x7
    800025ce:	a5e7b783          	ld	a5,-1442(a5) # 80009028 <initproc>
    800025d2:	0f850493          	addi	s1,a0,248
    800025d6:	17850913          	addi	s2,a0,376
    800025da:	02a79363          	bne	a5,a0,80002600 <exit+0x52>
    panic("init exiting");
    800025de:	00006517          	auipc	a0,0x6
    800025e2:	d8a50513          	addi	a0,a0,-630 # 80008368 <digits+0x328>
    800025e6:	ffffe097          	auipc	ra,0xffffe
    800025ea:	f44080e7          	jalr	-188(ra) # 8000052a <panic>
      fileclose(f);
    800025ee:	00002097          	auipc	ra,0x2
    800025f2:	5f6080e7          	jalr	1526(ra) # 80004be4 <fileclose>
      p->ofile[fd] = 0;
    800025f6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800025fa:	04a1                	addi	s1,s1,8
    800025fc:	01248563          	beq	s1,s2,80002606 <exit+0x58>
    if(p->ofile[fd]){
    80002600:	6088                	ld	a0,0(s1)
    80002602:	f575                	bnez	a0,800025ee <exit+0x40>
    80002604:	bfdd                	j	800025fa <exit+0x4c>
  begin_op();
    80002606:	00002097          	auipc	ra,0x2
    8000260a:	112080e7          	jalr	274(ra) # 80004718 <begin_op>
  iput(p->cwd);
    8000260e:	1789b503          	ld	a0,376(s3)
    80002612:	00002097          	auipc	ra,0x2
    80002616:	8ea080e7          	jalr	-1814(ra) # 80003efc <iput>
  end_op();
    8000261a:	00002097          	auipc	ra,0x2
    8000261e:	17e080e7          	jalr	382(ra) # 80004798 <end_op>
  p->cwd = 0;
    80002622:	1609bc23          	sd	zero,376(s3)
  acquire(&wait_lock);
    80002626:	0000f497          	auipc	s1,0xf
    8000262a:	c9248493          	addi	s1,s1,-878 # 800112b8 <wait_lock>
    8000262e:	8526                	mv	a0,s1
    80002630:	ffffe097          	auipc	ra,0xffffe
    80002634:	592080e7          	jalr	1426(ra) # 80000bc2 <acquire>
  reparent(p);
    80002638:	854e                	mv	a0,s3
    8000263a:	00000097          	auipc	ra,0x0
    8000263e:	f1a080e7          	jalr	-230(ra) # 80002554 <reparent>
  wakeup(p->parent);
    80002642:	0609b503          	ld	a0,96(s3)
    80002646:	00000097          	auipc	ra,0x0
    8000264a:	e86080e7          	jalr	-378(ra) # 800024cc <wakeup>
  acquire(&p->lock);
    8000264e:	854e                	mv	a0,s3
    80002650:	ffffe097          	auipc	ra,0xffffe
    80002654:	572080e7          	jalr	1394(ra) # 80000bc2 <acquire>
  p->xstate = status;
    80002658:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000265c:	4795                	li	a5,5
    8000265e:	00f9ac23          	sw	a5,24(s3)
  p->ttime = ticks; //update termination time
    80002662:	00007797          	auipc	a5,0x7
    80002666:	9ce7a783          	lw	a5,-1586(a5) # 80009030 <ticks>
    8000266a:	02f9ae23          	sw	a5,60(s3)
  release(&wait_lock);
    8000266e:	8526                	mv	a0,s1
    80002670:	ffffe097          	auipc	ra,0xffffe
    80002674:	606080e7          	jalr	1542(ra) # 80000c76 <release>
  sched();
    80002678:	00000097          	auipc	ra,0x0
    8000267c:	b88080e7          	jalr	-1144(ra) # 80002200 <sched>
  panic("zombie exit");
    80002680:	00006517          	auipc	a0,0x6
    80002684:	cf850513          	addi	a0,a0,-776 # 80008378 <digits+0x338>
    80002688:	ffffe097          	auipc	ra,0xffffe
    8000268c:	ea2080e7          	jalr	-350(ra) # 8000052a <panic>

0000000080002690 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002690:	7179                	addi	sp,sp,-48
    80002692:	f406                	sd	ra,40(sp)
    80002694:	f022                	sd	s0,32(sp)
    80002696:	ec26                	sd	s1,24(sp)
    80002698:	e84a                	sd	s2,16(sp)
    8000269a:	e44e                	sd	s3,8(sp)
    8000269c:	1800                	addi	s0,sp,48
    8000269e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800026a0:	0000f497          	auipc	s1,0xf
    800026a4:	03048493          	addi	s1,s1,48 # 800116d0 <proc>
    800026a8:	00015997          	auipc	s3,0x15
    800026ac:	42898993          	addi	s3,s3,1064 # 80017ad0 <tickslock>
    acquire(&p->lock);
    800026b0:	8526                	mv	a0,s1
    800026b2:	ffffe097          	auipc	ra,0xffffe
    800026b6:	510080e7          	jalr	1296(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    800026ba:	589c                	lw	a5,48(s1)
    800026bc:	01278d63          	beq	a5,s2,800026d6 <kill+0x46>
        p->runnable_since=ticks;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800026c0:	8526                	mv	a0,s1
    800026c2:	ffffe097          	auipc	ra,0xffffe
    800026c6:	5b4080e7          	jalr	1460(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800026ca:	19048493          	addi	s1,s1,400
    800026ce:	ff3491e3          	bne	s1,s3,800026b0 <kill+0x20>
  }
  return -1;
    800026d2:	557d                	li	a0,-1
    800026d4:	a829                	j	800026ee <kill+0x5e>
      p->killed = 1;
    800026d6:	4785                	li	a5,1
    800026d8:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800026da:	4c98                	lw	a4,24(s1)
    800026dc:	4789                	li	a5,2
    800026de:	00f70f63          	beq	a4,a5,800026fc <kill+0x6c>
      release(&p->lock);
    800026e2:	8526                	mv	a0,s1
    800026e4:	ffffe097          	auipc	ra,0xffffe
    800026e8:	592080e7          	jalr	1426(ra) # 80000c76 <release>
      return 0;
    800026ec:	4501                	li	a0,0
}
    800026ee:	70a2                	ld	ra,40(sp)
    800026f0:	7402                	ld	s0,32(sp)
    800026f2:	64e2                	ld	s1,24(sp)
    800026f4:	6942                	ld	s2,16(sp)
    800026f6:	69a2                	ld	s3,8(sp)
    800026f8:	6145                	addi	sp,sp,48
    800026fa:	8082                	ret
        p->state = RUNNABLE;
    800026fc:	478d                	li	a5,3
    800026fe:	cc9c                	sw	a5,24(s1)
        p->runnable_since=ticks;
    80002700:	00007797          	auipc	a5,0x7
    80002704:	9307a783          	lw	a5,-1744(a5) # 80009030 <ticks>
    80002708:	ccbc                	sw	a5,88(s1)
    8000270a:	bfe1                	j	800026e2 <kill+0x52>

000000008000270c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000270c:	7179                	addi	sp,sp,-48
    8000270e:	f406                	sd	ra,40(sp)
    80002710:	f022                	sd	s0,32(sp)
    80002712:	ec26                	sd	s1,24(sp)
    80002714:	e84a                	sd	s2,16(sp)
    80002716:	e44e                	sd	s3,8(sp)
    80002718:	e052                	sd	s4,0(sp)
    8000271a:	1800                	addi	s0,sp,48
    8000271c:	84aa                	mv	s1,a0
    8000271e:	892e                	mv	s2,a1
    80002720:	89b2                	mv	s3,a2
    80002722:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002724:	fffff097          	auipc	ra,0xfffff
    80002728:	2a2080e7          	jalr	674(ra) # 800019c6 <myproc>
  if(user_dst){
    8000272c:	c08d                	beqz	s1,8000274e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000272e:	86d2                	mv	a3,s4
    80002730:	864e                	mv	a2,s3
    80002732:	85ca                	mv	a1,s2
    80002734:	7d28                	ld	a0,120(a0)
    80002736:	fffff097          	auipc	ra,0xfffff
    8000273a:	f08080e7          	jalr	-248(ra) # 8000163e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000273e:	70a2                	ld	ra,40(sp)
    80002740:	7402                	ld	s0,32(sp)
    80002742:	64e2                	ld	s1,24(sp)
    80002744:	6942                	ld	s2,16(sp)
    80002746:	69a2                	ld	s3,8(sp)
    80002748:	6a02                	ld	s4,0(sp)
    8000274a:	6145                	addi	sp,sp,48
    8000274c:	8082                	ret
    memmove((char *)dst, src, len);
    8000274e:	000a061b          	sext.w	a2,s4
    80002752:	85ce                	mv	a1,s3
    80002754:	854a                	mv	a0,s2
    80002756:	ffffe097          	auipc	ra,0xffffe
    8000275a:	5c4080e7          	jalr	1476(ra) # 80000d1a <memmove>
    return 0;
    8000275e:	8526                	mv	a0,s1
    80002760:	bff9                	j	8000273e <either_copyout+0x32>

0000000080002762 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002762:	7179                	addi	sp,sp,-48
    80002764:	f406                	sd	ra,40(sp)
    80002766:	f022                	sd	s0,32(sp)
    80002768:	ec26                	sd	s1,24(sp)
    8000276a:	e84a                	sd	s2,16(sp)
    8000276c:	e44e                	sd	s3,8(sp)
    8000276e:	e052                	sd	s4,0(sp)
    80002770:	1800                	addi	s0,sp,48
    80002772:	892a                	mv	s2,a0
    80002774:	84ae                	mv	s1,a1
    80002776:	89b2                	mv	s3,a2
    80002778:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000277a:	fffff097          	auipc	ra,0xfffff
    8000277e:	24c080e7          	jalr	588(ra) # 800019c6 <myproc>
  if(user_src){
    80002782:	c08d                	beqz	s1,800027a4 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002784:	86d2                	mv	a3,s4
    80002786:	864e                	mv	a2,s3
    80002788:	85ca                	mv	a1,s2
    8000278a:	7d28                	ld	a0,120(a0)
    8000278c:	fffff097          	auipc	ra,0xfffff
    80002790:	f3e080e7          	jalr	-194(ra) # 800016ca <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002794:	70a2                	ld	ra,40(sp)
    80002796:	7402                	ld	s0,32(sp)
    80002798:	64e2                	ld	s1,24(sp)
    8000279a:	6942                	ld	s2,16(sp)
    8000279c:	69a2                	ld	s3,8(sp)
    8000279e:	6a02                	ld	s4,0(sp)
    800027a0:	6145                	addi	sp,sp,48
    800027a2:	8082                	ret
    memmove(dst, (char*)src, len);
    800027a4:	000a061b          	sext.w	a2,s4
    800027a8:	85ce                	mv	a1,s3
    800027aa:	854a                	mv	a0,s2
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	56e080e7          	jalr	1390(ra) # 80000d1a <memmove>
    return 0;
    800027b4:	8526                	mv	a0,s1
    800027b6:	bff9                	j	80002794 <either_copyin+0x32>

00000000800027b8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800027b8:	715d                	addi	sp,sp,-80
    800027ba:	e486                	sd	ra,72(sp)
    800027bc:	e0a2                	sd	s0,64(sp)
    800027be:	fc26                	sd	s1,56(sp)
    800027c0:	f84a                	sd	s2,48(sp)
    800027c2:	f44e                	sd	s3,40(sp)
    800027c4:	f052                	sd	s4,32(sp)
    800027c6:	ec56                	sd	s5,24(sp)
    800027c8:	e85a                	sd	s6,16(sp)
    800027ca:	e45e                	sd	s7,8(sp)
    800027cc:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800027ce:	00006517          	auipc	a0,0x6
    800027d2:	8fa50513          	addi	a0,a0,-1798 # 800080c8 <digits+0x88>
    800027d6:	ffffe097          	auipc	ra,0xffffe
    800027da:	d9e080e7          	jalr	-610(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027de:	0000f497          	auipc	s1,0xf
    800027e2:	07248493          	addi	s1,s1,114 # 80011850 <proc+0x180>
    800027e6:	00015917          	auipc	s2,0x15
    800027ea:	46a90913          	addi	s2,s2,1130 # 80017c50 <bcache+0x168>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027ee:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800027f0:	00006997          	auipc	s3,0x6
    800027f4:	b9898993          	addi	s3,s3,-1128 # 80008388 <digits+0x348>
    printf("%d %s %s", p->pid, state, p->name);
    800027f8:	00006a97          	auipc	s5,0x6
    800027fc:	b98a8a93          	addi	s5,s5,-1128 # 80008390 <digits+0x350>
    printf("\n");
    80002800:	00006a17          	auipc	s4,0x6
    80002804:	8c8a0a13          	addi	s4,s4,-1848 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002808:	00006b97          	auipc	s7,0x6
    8000280c:	bc0b8b93          	addi	s7,s7,-1088 # 800083c8 <states.0>
    80002810:	a00d                	j	80002832 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002812:	eb06a583          	lw	a1,-336(a3)
    80002816:	8556                	mv	a0,s5
    80002818:	ffffe097          	auipc	ra,0xffffe
    8000281c:	d5c080e7          	jalr	-676(ra) # 80000574 <printf>
    printf("\n");
    80002820:	8552                	mv	a0,s4
    80002822:	ffffe097          	auipc	ra,0xffffe
    80002826:	d52080e7          	jalr	-686(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000282a:	19048493          	addi	s1,s1,400
    8000282e:	03248263          	beq	s1,s2,80002852 <procdump+0x9a>
    if(p->state == UNUSED)
    80002832:	86a6                	mv	a3,s1
    80002834:	e984a783          	lw	a5,-360(s1)
    80002838:	dbed                	beqz	a5,8000282a <procdump+0x72>
      state = "???";
    8000283a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000283c:	fcfb6be3          	bltu	s6,a5,80002812 <procdump+0x5a>
    80002840:	02079713          	slli	a4,a5,0x20
    80002844:	01d75793          	srli	a5,a4,0x1d
    80002848:	97de                	add	a5,a5,s7
    8000284a:	6390                	ld	a2,0(a5)
    8000284c:	f279                	bnez	a2,80002812 <procdump+0x5a>
      state = "???";
    8000284e:	864e                	mv	a2,s3
    80002850:	b7c9                	j	80002812 <procdump+0x5a>
  }
}
    80002852:	60a6                	ld	ra,72(sp)
    80002854:	6406                	ld	s0,64(sp)
    80002856:	74e2                	ld	s1,56(sp)
    80002858:	7942                	ld	s2,48(sp)
    8000285a:	79a2                	ld	s3,40(sp)
    8000285c:	7a02                	ld	s4,32(sp)
    8000285e:	6ae2                	ld	s5,24(sp)
    80002860:	6b42                	ld	s6,16(sp)
    80002862:	6ba2                	ld	s7,8(sp)
    80002864:	6161                	addi	sp,sp,80
    80002866:	8082                	ret

0000000080002868 <trace>:

// Changes the Trace bit mask for proccess with input pid
// Trace mask determines which system calls will be traced
int
trace(int mask, int pid){
    80002868:	7179                	addi	sp,sp,-48
    8000286a:	f406                	sd	ra,40(sp)
    8000286c:	f022                	sd	s0,32(sp)
    8000286e:	ec26                	sd	s1,24(sp)
    80002870:	e84a                	sd	s2,16(sp)
    80002872:	e44e                	sd	s3,8(sp)
    80002874:	e052                	sd	s4,0(sp)
    80002876:	1800                	addi	s0,sp,48
    80002878:	8a2a                	mv	s4,a0
    8000287a:	892e                	mv	s2,a1
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000287c:	0000f497          	auipc	s1,0xf
    80002880:	e5448493          	addi	s1,s1,-428 # 800116d0 <proc>
    80002884:	00015997          	auipc	s3,0x15
    80002888:	24c98993          	addi	s3,s3,588 # 80017ad0 <tickslock>
    acquire(&p->lock);
    8000288c:	8526                	mv	a0,s1
    8000288e:	ffffe097          	auipc	ra,0xffffe
    80002892:	334080e7          	jalr	820(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    80002896:	589c                	lw	a5,48(s1)
    80002898:	01278d63          	beq	a5,s2,800028b2 <trace+0x4a>
      p->tracemask = mask;
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000289c:	8526                	mv	a0,s1
    8000289e:	ffffe097          	auipc	ra,0xffffe
    800028a2:	3d8080e7          	jalr	984(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800028a6:	19048493          	addi	s1,s1,400
    800028aa:	ff3491e3          	bne	s1,s3,8000288c <trace+0x24>
  }
  return -1;
    800028ae:	557d                	li	a0,-1
    800028b0:	a809                	j	800028c2 <trace+0x5a>
      p->tracemask = mask;
    800028b2:	0344aa23          	sw	s4,52(s1)
      release(&p->lock);
    800028b6:	8526                	mv	a0,s1
    800028b8:	ffffe097          	auipc	ra,0xffffe
    800028bc:	3be080e7          	jalr	958(ra) # 80000c76 <release>
      return 0;
    800028c0:	4501                	li	a0,0
}
    800028c2:	70a2                	ld	ra,40(sp)
    800028c4:	7402                	ld	s0,32(sp)
    800028c6:	64e2                	ld	s1,24(sp)
    800028c8:	6942                	ld	s2,16(sp)
    800028ca:	69a2                	ld	s3,8(sp)
    800028cc:	6a02                	ld	s4,0(sp)
    800028ce:	6145                	addi	sp,sp,48
    800028d0:	8082                	ret

00000000800028d2 <wait_stat>:

int
wait_stat(uint64 stat_addr, uint64 perf_addr){// ass1 
    800028d2:	7119                	addi	sp,sp,-128
    800028d4:	fc86                	sd	ra,120(sp)
    800028d6:	f8a2                	sd	s0,112(sp)
    800028d8:	f4a6                	sd	s1,104(sp)
    800028da:	f0ca                	sd	s2,96(sp)
    800028dc:	ecce                	sd	s3,88(sp)
    800028de:	e8d2                	sd	s4,80(sp)
    800028e0:	e4d6                	sd	s5,72(sp)
    800028e2:	e0da                	sd	s6,64(sp)
    800028e4:	fc5e                	sd	s7,56(sp)
    800028e6:	f862                	sd	s8,48(sp)
    800028e8:	f466                	sd	s9,40(sp)
    800028ea:	0100                	addi	s0,sp,128
    800028ec:	8b2a                	mv	s6,a0
    800028ee:	8bae                	mv	s7,a1
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800028f0:	fffff097          	auipc	ra,0xfffff
    800028f4:	0d6080e7          	jalr	214(ra) # 800019c6 <myproc>
    800028f8:	892a                	mv	s2,a0
  struct perf child_perf;
  acquire(&wait_lock);
    800028fa:	0000f517          	auipc	a0,0xf
    800028fe:	9be50513          	addi	a0,a0,-1602 # 800112b8 <wait_lock>
    80002902:	ffffe097          	auipc	ra,0xffffe
    80002906:	2c0080e7          	jalr	704(ra) # 80000bc2 <acquire>
  
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    8000290a:	4c01                	li	s8,0
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){ 
    8000290c:	4a15                	li	s4,5
        havekids = 1;
    8000290e:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002910:	00015997          	auipc	s3,0x15
    80002914:	1c098993          	addi	s3,s3,448 # 80017ad0 <tickslock>
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002918:	0000fc97          	auipc	s9,0xf
    8000291c:	9a0c8c93          	addi	s9,s9,-1632 # 800112b8 <wait_lock>
    havekids = 0;
    80002920:	8762                	mv	a4,s8
    for(np = proc; np < &proc[NPROC]; np++){
    80002922:	0000f497          	auipc	s1,0xf
    80002926:	dae48493          	addi	s1,s1,-594 # 800116d0 <proc>
    8000292a:	a861                	j	800029c2 <wait_stat+0xf0>
          pid = np->pid;
    8000292c:	0304a983          	lw	s3,48(s1)
          perfi(np, &child_perf);
    80002930:	f8840593          	addi	a1,s0,-120
    80002934:	8526                	mv	a0,s1
    80002936:	fffff097          	auipc	ra,0xfffff
    8000293a:	498080e7          	jalr	1176(ra) # 80001dce <perfi>
          if(stat_addr != 0 && perf_addr != 0 && 
    8000293e:	000b0463          	beqz	s6,80002946 <wait_stat+0x74>
    80002942:	020b9563          	bnez	s7,8000296c <wait_stat+0x9a>
          freeproc(np);
    80002946:	8526                	mv	a0,s1
    80002948:	fffff097          	auipc	ra,0xfffff
    8000294c:	230080e7          	jalr	560(ra) # 80001b78 <freeproc>
          release(&np->lock);
    80002950:	8526                	mv	a0,s1
    80002952:	ffffe097          	auipc	ra,0xffffe
    80002956:	324080e7          	jalr	804(ra) # 80000c76 <release>
          release(&wait_lock);
    8000295a:	0000f517          	auipc	a0,0xf
    8000295e:	95e50513          	addi	a0,a0,-1698 # 800112b8 <wait_lock>
    80002962:	ffffe097          	auipc	ra,0xffffe
    80002966:	314080e7          	jalr	788(ra) # 80000c76 <release>
          return pid;
    8000296a:	a859                	j	80002a00 <wait_stat+0x12e>
            ((copyout(p->pagetable, stat_addr, (char *)&np->xstate,sizeof(np->xstate)) < 0) ||
    8000296c:	4691                	li	a3,4
    8000296e:	02c48613          	addi	a2,s1,44
    80002972:	85da                	mv	a1,s6
    80002974:	07893503          	ld	a0,120(s2)
    80002978:	fffff097          	auipc	ra,0xfffff
    8000297c:	cc6080e7          	jalr	-826(ra) # 8000163e <copyout>
          if(stat_addr != 0 && perf_addr != 0 && 
    80002980:	00054e63          	bltz	a0,8000299c <wait_stat+0xca>
            (copyout(p->pagetable, perf_addr, (char *)&child_perf, sizeof(child_perf)) < 0))){
    80002984:	46e1                	li	a3,24
    80002986:	f8840613          	addi	a2,s0,-120
    8000298a:	85de                	mv	a1,s7
    8000298c:	07893503          	ld	a0,120(s2)
    80002990:	fffff097          	auipc	ra,0xfffff
    80002994:	cae080e7          	jalr	-850(ra) # 8000163e <copyout>
            ((copyout(p->pagetable, stat_addr, (char *)&np->xstate,sizeof(np->xstate)) < 0) ||
    80002998:	fa0557e3          	bgez	a0,80002946 <wait_stat+0x74>
            release(&np->lock);
    8000299c:	8526                	mv	a0,s1
    8000299e:	ffffe097          	auipc	ra,0xffffe
    800029a2:	2d8080e7          	jalr	728(ra) # 80000c76 <release>
            release(&wait_lock);
    800029a6:	0000f517          	auipc	a0,0xf
    800029aa:	91250513          	addi	a0,a0,-1774 # 800112b8 <wait_lock>
    800029ae:	ffffe097          	auipc	ra,0xffffe
    800029b2:	2c8080e7          	jalr	712(ra) # 80000c76 <release>
            return -1;
    800029b6:	59fd                	li	s3,-1
    800029b8:	a0a1                	j	80002a00 <wait_stat+0x12e>
    for(np = proc; np < &proc[NPROC]; np++){
    800029ba:	19048493          	addi	s1,s1,400
    800029be:	03348463          	beq	s1,s3,800029e6 <wait_stat+0x114>
      if(np->parent == p){
    800029c2:	70bc                	ld	a5,96(s1)
    800029c4:	ff279be3          	bne	a5,s2,800029ba <wait_stat+0xe8>
        acquire(&np->lock);
    800029c8:	8526                	mv	a0,s1
    800029ca:	ffffe097          	auipc	ra,0xffffe
    800029ce:	1f8080e7          	jalr	504(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){ 
    800029d2:	4c9c                	lw	a5,24(s1)
    800029d4:	f5478ce3          	beq	a5,s4,8000292c <wait_stat+0x5a>
        release(&np->lock);
    800029d8:	8526                	mv	a0,s1
    800029da:	ffffe097          	auipc	ra,0xffffe
    800029de:	29c080e7          	jalr	668(ra) # 80000c76 <release>
        havekids = 1;
    800029e2:	8756                	mv	a4,s5
    800029e4:	bfd9                	j	800029ba <wait_stat+0xe8>
    if(!havekids || p->killed){
    800029e6:	c701                	beqz	a4,800029ee <wait_stat+0x11c>
    800029e8:	02892783          	lw	a5,40(s2)
    800029ec:	cb85                	beqz	a5,80002a1c <wait_stat+0x14a>
      release(&wait_lock);
    800029ee:	0000f517          	auipc	a0,0xf
    800029f2:	8ca50513          	addi	a0,a0,-1846 # 800112b8 <wait_lock>
    800029f6:	ffffe097          	auipc	ra,0xffffe
    800029fa:	280080e7          	jalr	640(ra) # 80000c76 <release>
      return -1;
    800029fe:	59fd                	li	s3,-1
  }

}
    80002a00:	854e                	mv	a0,s3
    80002a02:	70e6                	ld	ra,120(sp)
    80002a04:	7446                	ld	s0,112(sp)
    80002a06:	74a6                	ld	s1,104(sp)
    80002a08:	7906                	ld	s2,96(sp)
    80002a0a:	69e6                	ld	s3,88(sp)
    80002a0c:	6a46                	ld	s4,80(sp)
    80002a0e:	6aa6                	ld	s5,72(sp)
    80002a10:	6b06                	ld	s6,64(sp)
    80002a12:	7be2                	ld	s7,56(sp)
    80002a14:	7c42                	ld	s8,48(sp)
    80002a16:	7ca2                	ld	s9,40(sp)
    80002a18:	6109                	addi	sp,sp,128
    80002a1a:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002a1c:	85e6                	mv	a1,s9
    80002a1e:	854a                	mv	a0,s2
    80002a20:	00000097          	auipc	ra,0x0
    80002a24:	920080e7          	jalr	-1760(ra) # 80002340 <sleep>
    havekids = 0;
    80002a28:	bde5                	j	80002920 <wait_stat+0x4e>

0000000080002a2a <update_times>:

void
update_times(){
    80002a2a:	7139                	addi	sp,sp,-64
    80002a2c:	fc06                	sd	ra,56(sp)
    80002a2e:	f822                	sd	s0,48(sp)
    80002a30:	f426                	sd	s1,40(sp)
    80002a32:	f04a                	sd	s2,32(sp)
    80002a34:	ec4e                	sd	s3,24(sp)
    80002a36:	e852                	sd	s4,16(sp)
    80002a38:	e456                	sd	s5,8(sp)
    80002a3a:	0080                	addi	s0,sp,64
    struct proc *np;

    for(np = proc; np < &proc[NPROC]; np++){
    80002a3c:	0000f497          	auipc	s1,0xf
    80002a40:	c9448493          	addi	s1,s1,-876 # 800116d0 <proc>
      acquire(&np->lock);
      switch (np->state)
    80002a44:	4a8d                	li	s5,3
    80002a46:	4a11                	li	s4,4
    80002a48:	4989                	li	s3,2
    for(np = proc; np < &proc[NPROC]; np++){
    80002a4a:	00015917          	auipc	s2,0x15
    80002a4e:	08690913          	addi	s2,s2,134 # 80017ad0 <tickslock>
    80002a52:	a829                	j	80002a6c <update_times+0x42>
      {
      case SLEEPING:
        np->stime++;
        break;
      case RUNNABLE:
        np->retime++;
    80002a54:	40fc                	lw	a5,68(s1)
    80002a56:	2785                	addiw	a5,a5,1
    80002a58:	c0fc                	sw	a5,68(s1)
        np->rutime++;
        break;
      default:
        break;
      }
    release(&np->lock);
    80002a5a:	8526                	mv	a0,s1
    80002a5c:	ffffe097          	auipc	ra,0xffffe
    80002a60:	21a080e7          	jalr	538(ra) # 80000c76 <release>
    for(np = proc; np < &proc[NPROC]; np++){
    80002a64:	19048493          	addi	s1,s1,400
    80002a68:	03248963          	beq	s1,s2,80002a9a <update_times+0x70>
      acquire(&np->lock);
    80002a6c:	8526                	mv	a0,s1
    80002a6e:	ffffe097          	auipc	ra,0xffffe
    80002a72:	154080e7          	jalr	340(ra) # 80000bc2 <acquire>
      switch (np->state)
    80002a76:	4c9c                	lw	a5,24(s1)
    80002a78:	fd578ee3          	beq	a5,s5,80002a54 <update_times+0x2a>
    80002a7c:	01478863          	beq	a5,s4,80002a8c <update_times+0x62>
    80002a80:	fd379de3          	bne	a5,s3,80002a5a <update_times+0x30>
        np->stime++;
    80002a84:	40bc                	lw	a5,64(s1)
    80002a86:	2785                	addiw	a5,a5,1
    80002a88:	c0bc                	sw	a5,64(s1)
        break;
    80002a8a:	bfc1                	j	80002a5a <update_times+0x30>
        np->current_runtime++;
    80002a8c:	48fc                	lw	a5,84(s1)
    80002a8e:	2785                	addiw	a5,a5,1
    80002a90:	c8fc                	sw	a5,84(s1)
        np->rutime++;
    80002a92:	44bc                	lw	a5,72(s1)
    80002a94:	2785                	addiw	a5,a5,1
    80002a96:	c4bc                	sw	a5,72(s1)
        break;
    80002a98:	b7c9                	j	80002a5a <update_times+0x30>
    } 
}
    80002a9a:	70e2                	ld	ra,56(sp)
    80002a9c:	7442                	ld	s0,48(sp)
    80002a9e:	74a2                	ld	s1,40(sp)
    80002aa0:	7902                	ld	s2,32(sp)
    80002aa2:	69e2                	ld	s3,24(sp)
    80002aa4:	6a42                	ld	s4,16(sp)
    80002aa6:	6aa2                	ld	s5,8(sp)
    80002aa8:	6121                	addi	sp,sp,64
    80002aaa:	8082                	ret

0000000080002aac <set_priority>:

int
set_priority(int priority){
    80002aac:	7139                	addi	sp,sp,-64
    80002aae:	fc06                	sd	ra,56(sp)
    80002ab0:	f822                	sd	s0,48(sp)
    80002ab2:	f426                	sd	s1,40(sp)
    80002ab4:	f04a                	sd	s2,32(sp)
    80002ab6:	0080                	addi	s0,sp,64
    80002ab8:	84aa                	mv	s1,a0
  struct proc *p = myproc();   
    80002aba:	fffff097          	auipc	ra,0xfffff
    80002abe:	f0c080e7          	jalr	-244(ra) # 800019c6 <myproc>
  int priority_to_decay[5] = {1,3,5,7,25};
    80002ac2:	4785                	li	a5,1
    80002ac4:	fcf42423          	sw	a5,-56(s0)
    80002ac8:	478d                	li	a5,3
    80002aca:	fcf42623          	sw	a5,-52(s0)
    80002ace:	4795                	li	a5,5
    80002ad0:	fcf42823          	sw	a5,-48(s0)
    80002ad4:	479d                	li	a5,7
    80002ad6:	fcf42a23          	sw	a5,-44(s0)
    80002ada:	47e5                	li	a5,25
    80002adc:	fcf42c23          	sw	a5,-40(s0)

  if(priority < 1 || priority > 5)
    80002ae0:	fff4871b          	addiw	a4,s1,-1
    80002ae4:	4791                	li	a5,4
    80002ae6:	02e7ec63          	bltu	a5,a4,80002b1e <set_priority+0x72>
    80002aea:	892a                	mv	s2,a0
    return -1;

  acquire(&p->lock);
    80002aec:	ffffe097          	auipc	ra,0xffffe
    80002af0:	0d6080e7          	jalr	214(ra) # 80000bc2 <acquire>
  p->decay_factor=priority_to_decay[priority-1];
    80002af4:	34fd                	addiw	s1,s1,-1
    80002af6:	048a                	slli	s1,s1,0x2
    80002af8:	fe040793          	addi	a5,s0,-32
    80002afc:	94be                	add	s1,s1,a5
    80002afe:	fe84a783          	lw	a5,-24(s1)
    80002b02:	04f92823          	sw	a5,80(s2)
  release(&p->lock); 
    80002b06:	854a                	mv	a0,s2
    80002b08:	ffffe097          	auipc	ra,0xffffe
    80002b0c:	16e080e7          	jalr	366(ra) # 80000c76 <release>

  return 0;
    80002b10:	4501                	li	a0,0
}
    80002b12:	70e2                	ld	ra,56(sp)
    80002b14:	7442                	ld	s0,48(sp)
    80002b16:	74a2                	ld	s1,40(sp)
    80002b18:	7902                	ld	s2,32(sp)
    80002b1a:	6121                	addi	sp,sp,64
    80002b1c:	8082                	ret
    return -1;
    80002b1e:	557d                	li	a0,-1
    80002b20:	bfcd                	j	80002b12 <set_priority+0x66>

0000000080002b22 <swtch>:
    80002b22:	00153023          	sd	ra,0(a0)
    80002b26:	00253423          	sd	sp,8(a0)
    80002b2a:	e900                	sd	s0,16(a0)
    80002b2c:	ed04                	sd	s1,24(a0)
    80002b2e:	03253023          	sd	s2,32(a0)
    80002b32:	03353423          	sd	s3,40(a0)
    80002b36:	03453823          	sd	s4,48(a0)
    80002b3a:	03553c23          	sd	s5,56(a0)
    80002b3e:	05653023          	sd	s6,64(a0)
    80002b42:	05753423          	sd	s7,72(a0)
    80002b46:	05853823          	sd	s8,80(a0)
    80002b4a:	05953c23          	sd	s9,88(a0)
    80002b4e:	07a53023          	sd	s10,96(a0)
    80002b52:	07b53423          	sd	s11,104(a0)
    80002b56:	0005b083          	ld	ra,0(a1)
    80002b5a:	0085b103          	ld	sp,8(a1)
    80002b5e:	6980                	ld	s0,16(a1)
    80002b60:	6d84                	ld	s1,24(a1)
    80002b62:	0205b903          	ld	s2,32(a1)
    80002b66:	0285b983          	ld	s3,40(a1)
    80002b6a:	0305ba03          	ld	s4,48(a1)
    80002b6e:	0385ba83          	ld	s5,56(a1)
    80002b72:	0405bb03          	ld	s6,64(a1)
    80002b76:	0485bb83          	ld	s7,72(a1)
    80002b7a:	0505bc03          	ld	s8,80(a1)
    80002b7e:	0585bc83          	ld	s9,88(a1)
    80002b82:	0605bd03          	ld	s10,96(a1)
    80002b86:	0685bd83          	ld	s11,104(a1)
    80002b8a:	8082                	ret

0000000080002b8c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002b8c:	1141                	addi	sp,sp,-16
    80002b8e:	e406                	sd	ra,8(sp)
    80002b90:	e022                	sd	s0,0(sp)
    80002b92:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002b94:	00006597          	auipc	a1,0x6
    80002b98:	86458593          	addi	a1,a1,-1948 # 800083f8 <states.0+0x30>
    80002b9c:	00015517          	auipc	a0,0x15
    80002ba0:	f3450513          	addi	a0,a0,-204 # 80017ad0 <tickslock>
    80002ba4:	ffffe097          	auipc	ra,0xffffe
    80002ba8:	f8e080e7          	jalr	-114(ra) # 80000b32 <initlock>
}
    80002bac:	60a2                	ld	ra,8(sp)
    80002bae:	6402                	ld	s0,0(sp)
    80002bb0:	0141                	addi	sp,sp,16
    80002bb2:	8082                	ret

0000000080002bb4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002bb4:	1141                	addi	sp,sp,-16
    80002bb6:	e422                	sd	s0,8(sp)
    80002bb8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bba:	00003797          	auipc	a5,0x3
    80002bbe:	65678793          	addi	a5,a5,1622 # 80006210 <kernelvec>
    80002bc2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002bc6:	6422                	ld	s0,8(sp)
    80002bc8:	0141                	addi	sp,sp,16
    80002bca:	8082                	ret

0000000080002bcc <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002bcc:	1141                	addi	sp,sp,-16
    80002bce:	e406                	sd	ra,8(sp)
    80002bd0:	e022                	sd	s0,0(sp)
    80002bd2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002bd4:	fffff097          	auipc	ra,0xfffff
    80002bd8:	df2080e7          	jalr	-526(ra) # 800019c6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bdc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002be0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002be2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002be6:	00004617          	auipc	a2,0x4
    80002bea:	41a60613          	addi	a2,a2,1050 # 80007000 <_trampoline>
    80002bee:	00004697          	auipc	a3,0x4
    80002bf2:	41268693          	addi	a3,a3,1042 # 80007000 <_trampoline>
    80002bf6:	8e91                	sub	a3,a3,a2
    80002bf8:	040007b7          	lui	a5,0x4000
    80002bfc:	17fd                	addi	a5,a5,-1
    80002bfe:	07b2                	slli	a5,a5,0xc
    80002c00:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c02:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002c06:	6158                	ld	a4,128(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002c08:	180026f3          	csrr	a3,satp
    80002c0c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002c0e:	6158                	ld	a4,128(a0)
    80002c10:	7534                	ld	a3,104(a0)
    80002c12:	6585                	lui	a1,0x1
    80002c14:	96ae                	add	a3,a3,a1
    80002c16:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002c18:	6158                	ld	a4,128(a0)
    80002c1a:	00000697          	auipc	a3,0x0
    80002c1e:	14668693          	addi	a3,a3,326 # 80002d60 <usertrap>
    80002c22:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002c24:	6158                	ld	a4,128(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002c26:	8692                	mv	a3,tp
    80002c28:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c2a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002c2e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002c32:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c36:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002c3a:	6158                	ld	a4,128(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c3c:	6f18                	ld	a4,24(a4)
    80002c3e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002c42:	7d2c                	ld	a1,120(a0)
    80002c44:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002c46:	00004717          	auipc	a4,0x4
    80002c4a:	44a70713          	addi	a4,a4,1098 # 80007090 <userret>
    80002c4e:	8f11                	sub	a4,a4,a2
    80002c50:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002c52:	577d                	li	a4,-1
    80002c54:	177e                	slli	a4,a4,0x3f
    80002c56:	8dd9                	or	a1,a1,a4
    80002c58:	02000537          	lui	a0,0x2000
    80002c5c:	157d                	addi	a0,a0,-1
    80002c5e:	0536                	slli	a0,a0,0xd
    80002c60:	9782                	jalr	a5
}
    80002c62:	60a2                	ld	ra,8(sp)
    80002c64:	6402                	ld	s0,0(sp)
    80002c66:	0141                	addi	sp,sp,16
    80002c68:	8082                	ret

0000000080002c6a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002c6a:	1101                	addi	sp,sp,-32
    80002c6c:	ec06                	sd	ra,24(sp)
    80002c6e:	e822                	sd	s0,16(sp)
    80002c70:	e426                	sd	s1,8(sp)
    80002c72:	e04a                	sd	s2,0(sp)
    80002c74:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002c76:	00015917          	auipc	s2,0x15
    80002c7a:	e5a90913          	addi	s2,s2,-422 # 80017ad0 <tickslock>
    80002c7e:	854a                	mv	a0,s2
    80002c80:	ffffe097          	auipc	ra,0xffffe
    80002c84:	f42080e7          	jalr	-190(ra) # 80000bc2 <acquire>
  ticks++;
    80002c88:	00006497          	auipc	s1,0x6
    80002c8c:	3a848493          	addi	s1,s1,936 # 80009030 <ticks>
    80002c90:	409c                	lw	a5,0(s1)
    80002c92:	2785                	addiw	a5,a5,1
    80002c94:	c09c                	sw	a5,0(s1)
  update_times();
    80002c96:	00000097          	auipc	ra,0x0
    80002c9a:	d94080e7          	jalr	-620(ra) # 80002a2a <update_times>
  wakeup(&ticks);
    80002c9e:	8526                	mv	a0,s1
    80002ca0:	00000097          	auipc	ra,0x0
    80002ca4:	82c080e7          	jalr	-2004(ra) # 800024cc <wakeup>
  release(&tickslock);
    80002ca8:	854a                	mv	a0,s2
    80002caa:	ffffe097          	auipc	ra,0xffffe
    80002cae:	fcc080e7          	jalr	-52(ra) # 80000c76 <release>
}
    80002cb2:	60e2                	ld	ra,24(sp)
    80002cb4:	6442                	ld	s0,16(sp)
    80002cb6:	64a2                	ld	s1,8(sp)
    80002cb8:	6902                	ld	s2,0(sp)
    80002cba:	6105                	addi	sp,sp,32
    80002cbc:	8082                	ret

0000000080002cbe <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002cbe:	1101                	addi	sp,sp,-32
    80002cc0:	ec06                	sd	ra,24(sp)
    80002cc2:	e822                	sd	s0,16(sp)
    80002cc4:	e426                	sd	s1,8(sp)
    80002cc6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cc8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002ccc:	00074d63          	bltz	a4,80002ce6 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002cd0:	57fd                	li	a5,-1
    80002cd2:	17fe                	slli	a5,a5,0x3f
    80002cd4:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002cd6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002cd8:	06f70363          	beq	a4,a5,80002d3e <devintr+0x80>
  }
}
    80002cdc:	60e2                	ld	ra,24(sp)
    80002cde:	6442                	ld	s0,16(sp)
    80002ce0:	64a2                	ld	s1,8(sp)
    80002ce2:	6105                	addi	sp,sp,32
    80002ce4:	8082                	ret
     (scause & 0xff) == 9){
    80002ce6:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002cea:	46a5                	li	a3,9
    80002cec:	fed792e3          	bne	a5,a3,80002cd0 <devintr+0x12>
    int irq = plic_claim();
    80002cf0:	00003097          	auipc	ra,0x3
    80002cf4:	628080e7          	jalr	1576(ra) # 80006318 <plic_claim>
    80002cf8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002cfa:	47a9                	li	a5,10
    80002cfc:	02f50763          	beq	a0,a5,80002d2a <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002d00:	4785                	li	a5,1
    80002d02:	02f50963          	beq	a0,a5,80002d34 <devintr+0x76>
    return 1;
    80002d06:	4505                	li	a0,1
    } else if(irq){
    80002d08:	d8f1                	beqz	s1,80002cdc <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002d0a:	85a6                	mv	a1,s1
    80002d0c:	00005517          	auipc	a0,0x5
    80002d10:	6f450513          	addi	a0,a0,1780 # 80008400 <states.0+0x38>
    80002d14:	ffffe097          	auipc	ra,0xffffe
    80002d18:	860080e7          	jalr	-1952(ra) # 80000574 <printf>
      plic_complete(irq);
    80002d1c:	8526                	mv	a0,s1
    80002d1e:	00003097          	auipc	ra,0x3
    80002d22:	61e080e7          	jalr	1566(ra) # 8000633c <plic_complete>
    return 1;
    80002d26:	4505                	li	a0,1
    80002d28:	bf55                	j	80002cdc <devintr+0x1e>
      uartintr();
    80002d2a:	ffffe097          	auipc	ra,0xffffe
    80002d2e:	c5c080e7          	jalr	-932(ra) # 80000986 <uartintr>
    80002d32:	b7ed                	j	80002d1c <devintr+0x5e>
      virtio_disk_intr();
    80002d34:	00004097          	auipc	ra,0x4
    80002d38:	a9a080e7          	jalr	-1382(ra) # 800067ce <virtio_disk_intr>
    80002d3c:	b7c5                	j	80002d1c <devintr+0x5e>
    if(cpuid() == 0){
    80002d3e:	fffff097          	auipc	ra,0xfffff
    80002d42:	c5c080e7          	jalr	-932(ra) # 8000199a <cpuid>
    80002d46:	c901                	beqz	a0,80002d56 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002d48:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002d4c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002d4e:	14479073          	csrw	sip,a5
    return 2;
    80002d52:	4509                	li	a0,2
    80002d54:	b761                	j	80002cdc <devintr+0x1e>
      clockintr();
    80002d56:	00000097          	auipc	ra,0x0
    80002d5a:	f14080e7          	jalr	-236(ra) # 80002c6a <clockintr>
    80002d5e:	b7ed                	j	80002d48 <devintr+0x8a>

0000000080002d60 <usertrap>:
{
    80002d60:	1101                	addi	sp,sp,-32
    80002d62:	ec06                	sd	ra,24(sp)
    80002d64:	e822                	sd	s0,16(sp)
    80002d66:	e426                	sd	s1,8(sp)
    80002d68:	e04a                	sd	s2,0(sp)
    80002d6a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d6c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002d70:	1007f793          	andi	a5,a5,256
    80002d74:	e3ad                	bnez	a5,80002dd6 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d76:	00003797          	auipc	a5,0x3
    80002d7a:	49a78793          	addi	a5,a5,1178 # 80006210 <kernelvec>
    80002d7e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002d82:	fffff097          	auipc	ra,0xfffff
    80002d86:	c44080e7          	jalr	-956(ra) # 800019c6 <myproc>
    80002d8a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002d8c:	615c                	ld	a5,128(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d8e:	14102773          	csrr	a4,sepc
    80002d92:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d94:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002d98:	47a1                	li	a5,8
    80002d9a:	04f71c63          	bne	a4,a5,80002df2 <usertrap+0x92>
    if(p->killed)
    80002d9e:	551c                	lw	a5,40(a0)
    80002da0:	e3b9                	bnez	a5,80002de6 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002da2:	60d8                	ld	a4,128(s1)
    80002da4:	6f1c                	ld	a5,24(a4)
    80002da6:	0791                	addi	a5,a5,4
    80002da8:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002daa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002dae:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002db2:	10079073          	csrw	sstatus,a5
    syscall();
    80002db6:	00000097          	auipc	ra,0x0
    80002dba:	380080e7          	jalr	896(ra) # 80003136 <syscall>
  if(p->killed)
    80002dbe:	549c                	lw	a5,40(s1)
    80002dc0:	e3dd                	bnez	a5,80002e66 <usertrap+0x106>
  usertrapret();
    80002dc2:	00000097          	auipc	ra,0x0
    80002dc6:	e0a080e7          	jalr	-502(ra) # 80002bcc <usertrapret>
}
    80002dca:	60e2                	ld	ra,24(sp)
    80002dcc:	6442                	ld	s0,16(sp)
    80002dce:	64a2                	ld	s1,8(sp)
    80002dd0:	6902                	ld	s2,0(sp)
    80002dd2:	6105                	addi	sp,sp,32
    80002dd4:	8082                	ret
    panic("usertrap: not from user mode");
    80002dd6:	00005517          	auipc	a0,0x5
    80002dda:	64a50513          	addi	a0,a0,1610 # 80008420 <states.0+0x58>
    80002dde:	ffffd097          	auipc	ra,0xffffd
    80002de2:	74c080e7          	jalr	1868(ra) # 8000052a <panic>
      exit(-1);
    80002de6:	557d                	li	a0,-1
    80002de8:	fffff097          	auipc	ra,0xfffff
    80002dec:	7c6080e7          	jalr	1990(ra) # 800025ae <exit>
    80002df0:	bf4d                	j	80002da2 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002df2:	00000097          	auipc	ra,0x0
    80002df6:	ecc080e7          	jalr	-308(ra) # 80002cbe <devintr>
    80002dfa:	892a                	mv	s2,a0
    80002dfc:	c501                	beqz	a0,80002e04 <usertrap+0xa4>
  if(p->killed)
    80002dfe:	549c                	lw	a5,40(s1)
    80002e00:	c3a1                	beqz	a5,80002e40 <usertrap+0xe0>
    80002e02:	a815                	j	80002e36 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e04:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002e08:	5890                	lw	a2,48(s1)
    80002e0a:	00005517          	auipc	a0,0x5
    80002e0e:	63650513          	addi	a0,a0,1590 # 80008440 <states.0+0x78>
    80002e12:	ffffd097          	auipc	ra,0xffffd
    80002e16:	762080e7          	jalr	1890(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e1a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e1e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e22:	00005517          	auipc	a0,0x5
    80002e26:	64e50513          	addi	a0,a0,1614 # 80008470 <states.0+0xa8>
    80002e2a:	ffffd097          	auipc	ra,0xffffd
    80002e2e:	74a080e7          	jalr	1866(ra) # 80000574 <printf>
    p->killed = 1;
    80002e32:	4785                	li	a5,1
    80002e34:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002e36:	557d                	li	a0,-1
    80002e38:	fffff097          	auipc	ra,0xfffff
    80002e3c:	776080e7          	jalr	1910(ra) # 800025ae <exit>
  if(which_dev == 2 && p->current_runtime >= QUANTUM && is_preemptive==1)
    80002e40:	4789                	li	a5,2
    80002e42:	f8f910e3          	bne	s2,a5,80002dc2 <usertrap+0x62>
    80002e46:	48f8                	lw	a4,84(s1)
    80002e48:	4791                	li	a5,4
    80002e4a:	f6e7dce3          	bge	a5,a4,80002dc2 <usertrap+0x62>
    80002e4e:	00006717          	auipc	a4,0x6
    80002e52:	cc672703          	lw	a4,-826(a4) # 80008b14 <is_preemptive>
    80002e56:	4785                	li	a5,1
    80002e58:	f6f715e3          	bne	a4,a5,80002dc2 <usertrap+0x62>
    yield();
    80002e5c:	fffff097          	auipc	ra,0xfffff
    80002e60:	49e080e7          	jalr	1182(ra) # 800022fa <yield>
    80002e64:	bfb9                	j	80002dc2 <usertrap+0x62>
  int which_dev = 0;
    80002e66:	4901                	li	s2,0
    80002e68:	b7f9                	j	80002e36 <usertrap+0xd6>

0000000080002e6a <kerneltrap>:
{
    80002e6a:	7179                	addi	sp,sp,-48
    80002e6c:	f406                	sd	ra,40(sp)
    80002e6e:	f022                	sd	s0,32(sp)
    80002e70:	ec26                	sd	s1,24(sp)
    80002e72:	e84a                	sd	s2,16(sp)
    80002e74:	e44e                	sd	s3,8(sp)
    80002e76:	e052                	sd	s4,0(sp)
    80002e78:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e7a:	141029f3          	csrr	s3,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e7e:	10002973          	csrr	s2,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e82:	14202a73          	csrr	s4,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002e86:	10097793          	andi	a5,s2,256
    80002e8a:	cf95                	beqz	a5,80002ec6 <kerneltrap+0x5c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e8c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002e90:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002e92:	e3b1                	bnez	a5,80002ed6 <kerneltrap+0x6c>
  if((which_dev = devintr()) == 0){
    80002e94:	00000097          	auipc	ra,0x0
    80002e98:	e2a080e7          	jalr	-470(ra) # 80002cbe <devintr>
    80002e9c:	84aa                	mv	s1,a0
    80002e9e:	c521                	beqz	a0,80002ee6 <kerneltrap+0x7c>
  struct proc *p = myproc();
    80002ea0:	fffff097          	auipc	ra,0xfffff
    80002ea4:	b26080e7          	jalr	-1242(ra) # 800019c6 <myproc>
  if(which_dev == 2 && p != 0 && p->state == RUNNING && p->current_runtime >= QUANTUM && is_preemptive==1)
    80002ea8:	4789                	li	a5,2
    80002eaa:	06f48b63          	beq	s1,a5,80002f20 <kerneltrap+0xb6>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002eae:	14199073          	csrw	sepc,s3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002eb2:	10091073          	csrw	sstatus,s2
}
    80002eb6:	70a2                	ld	ra,40(sp)
    80002eb8:	7402                	ld	s0,32(sp)
    80002eba:	64e2                	ld	s1,24(sp)
    80002ebc:	6942                	ld	s2,16(sp)
    80002ebe:	69a2                	ld	s3,8(sp)
    80002ec0:	6a02                	ld	s4,0(sp)
    80002ec2:	6145                	addi	sp,sp,48
    80002ec4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ec6:	00005517          	auipc	a0,0x5
    80002eca:	5ca50513          	addi	a0,a0,1482 # 80008490 <states.0+0xc8>
    80002ece:	ffffd097          	auipc	ra,0xffffd
    80002ed2:	65c080e7          	jalr	1628(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80002ed6:	00005517          	auipc	a0,0x5
    80002eda:	5e250513          	addi	a0,a0,1506 # 800084b8 <states.0+0xf0>
    80002ede:	ffffd097          	auipc	ra,0xffffd
    80002ee2:	64c080e7          	jalr	1612(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80002ee6:	85d2                	mv	a1,s4
    80002ee8:	00005517          	auipc	a0,0x5
    80002eec:	5f050513          	addi	a0,a0,1520 # 800084d8 <states.0+0x110>
    80002ef0:	ffffd097          	auipc	ra,0xffffd
    80002ef4:	684080e7          	jalr	1668(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ef8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002efc:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f00:	00005517          	auipc	a0,0x5
    80002f04:	5e850513          	addi	a0,a0,1512 # 800084e8 <states.0+0x120>
    80002f08:	ffffd097          	auipc	ra,0xffffd
    80002f0c:	66c080e7          	jalr	1644(ra) # 80000574 <printf>
    panic("kerneltrap");
    80002f10:	00005517          	auipc	a0,0x5
    80002f14:	5f050513          	addi	a0,a0,1520 # 80008500 <states.0+0x138>
    80002f18:	ffffd097          	auipc	ra,0xffffd
    80002f1c:	612080e7          	jalr	1554(ra) # 8000052a <panic>
  if(which_dev == 2 && p != 0 && p->state == RUNNING && p->current_runtime >= QUANTUM && is_preemptive==1)
    80002f20:	d559                	beqz	a0,80002eae <kerneltrap+0x44>
    80002f22:	4d18                	lw	a4,24(a0)
    80002f24:	4791                	li	a5,4
    80002f26:	f8f714e3          	bne	a4,a5,80002eae <kerneltrap+0x44>
    80002f2a:	4978                	lw	a4,84(a0)
    80002f2c:	f8e7d1e3          	bge	a5,a4,80002eae <kerneltrap+0x44>
    80002f30:	00006717          	auipc	a4,0x6
    80002f34:	be472703          	lw	a4,-1052(a4) # 80008b14 <is_preemptive>
    80002f38:	4785                	li	a5,1
    80002f3a:	f6f71ae3          	bne	a4,a5,80002eae <kerneltrap+0x44>
    yield();
    80002f3e:	fffff097          	auipc	ra,0xfffff
    80002f42:	3bc080e7          	jalr	956(ra) # 800022fa <yield>
    80002f46:	b7a5                	j	80002eae <kerneltrap+0x44>

0000000080002f48 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002f48:	1101                	addi	sp,sp,-32
    80002f4a:	ec06                	sd	ra,24(sp)
    80002f4c:	e822                	sd	s0,16(sp)
    80002f4e:	e426                	sd	s1,8(sp)
    80002f50:	1000                	addi	s0,sp,32
    80002f52:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002f54:	fffff097          	auipc	ra,0xfffff
    80002f58:	a72080e7          	jalr	-1422(ra) # 800019c6 <myproc>
  switch (n) {
    80002f5c:	4795                	li	a5,5
    80002f5e:	0497e163          	bltu	a5,s1,80002fa0 <argraw+0x58>
    80002f62:	048a                	slli	s1,s1,0x2
    80002f64:	00005717          	auipc	a4,0x5
    80002f68:	6f470713          	addi	a4,a4,1780 # 80008658 <states.0+0x290>
    80002f6c:	94ba                	add	s1,s1,a4
    80002f6e:	409c                	lw	a5,0(s1)
    80002f70:	97ba                	add	a5,a5,a4
    80002f72:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002f74:	615c                	ld	a5,128(a0)
    80002f76:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002f78:	60e2                	ld	ra,24(sp)
    80002f7a:	6442                	ld	s0,16(sp)
    80002f7c:	64a2                	ld	s1,8(sp)
    80002f7e:	6105                	addi	sp,sp,32
    80002f80:	8082                	ret
    return p->trapframe->a1;
    80002f82:	615c                	ld	a5,128(a0)
    80002f84:	7fa8                	ld	a0,120(a5)
    80002f86:	bfcd                	j	80002f78 <argraw+0x30>
    return p->trapframe->a2;
    80002f88:	615c                	ld	a5,128(a0)
    80002f8a:	63c8                	ld	a0,128(a5)
    80002f8c:	b7f5                	j	80002f78 <argraw+0x30>
    return p->trapframe->a3;
    80002f8e:	615c                	ld	a5,128(a0)
    80002f90:	67c8                	ld	a0,136(a5)
    80002f92:	b7dd                	j	80002f78 <argraw+0x30>
    return p->trapframe->a4;
    80002f94:	615c                	ld	a5,128(a0)
    80002f96:	6bc8                	ld	a0,144(a5)
    80002f98:	b7c5                	j	80002f78 <argraw+0x30>
    return p->trapframe->a5;
    80002f9a:	615c                	ld	a5,128(a0)
    80002f9c:	6fc8                	ld	a0,152(a5)
    80002f9e:	bfe9                	j	80002f78 <argraw+0x30>
  panic("argraw");
    80002fa0:	00005517          	auipc	a0,0x5
    80002fa4:	57050513          	addi	a0,a0,1392 # 80008510 <states.0+0x148>
    80002fa8:	ffffd097          	auipc	ra,0xffffd
    80002fac:	582080e7          	jalr	1410(ra) # 8000052a <panic>

0000000080002fb0 <fetchaddr>:
{
    80002fb0:	1101                	addi	sp,sp,-32
    80002fb2:	ec06                	sd	ra,24(sp)
    80002fb4:	e822                	sd	s0,16(sp)
    80002fb6:	e426                	sd	s1,8(sp)
    80002fb8:	e04a                	sd	s2,0(sp)
    80002fba:	1000                	addi	s0,sp,32
    80002fbc:	84aa                	mv	s1,a0
    80002fbe:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002fc0:	fffff097          	auipc	ra,0xfffff
    80002fc4:	a06080e7          	jalr	-1530(ra) # 800019c6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002fc8:	793c                	ld	a5,112(a0)
    80002fca:	02f4f863          	bgeu	s1,a5,80002ffa <fetchaddr+0x4a>
    80002fce:	00848713          	addi	a4,s1,8
    80002fd2:	02e7e663          	bltu	a5,a4,80002ffe <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002fd6:	46a1                	li	a3,8
    80002fd8:	8626                	mv	a2,s1
    80002fda:	85ca                	mv	a1,s2
    80002fdc:	7d28                	ld	a0,120(a0)
    80002fde:	ffffe097          	auipc	ra,0xffffe
    80002fe2:	6ec080e7          	jalr	1772(ra) # 800016ca <copyin>
    80002fe6:	00a03533          	snez	a0,a0
    80002fea:	40a00533          	neg	a0,a0
}
    80002fee:	60e2                	ld	ra,24(sp)
    80002ff0:	6442                	ld	s0,16(sp)
    80002ff2:	64a2                	ld	s1,8(sp)
    80002ff4:	6902                	ld	s2,0(sp)
    80002ff6:	6105                	addi	sp,sp,32
    80002ff8:	8082                	ret
    return -1;
    80002ffa:	557d                	li	a0,-1
    80002ffc:	bfcd                	j	80002fee <fetchaddr+0x3e>
    80002ffe:	557d                	li	a0,-1
    80003000:	b7fd                	j	80002fee <fetchaddr+0x3e>

0000000080003002 <fetchstr>:
{
    80003002:	7179                	addi	sp,sp,-48
    80003004:	f406                	sd	ra,40(sp)
    80003006:	f022                	sd	s0,32(sp)
    80003008:	ec26                	sd	s1,24(sp)
    8000300a:	e84a                	sd	s2,16(sp)
    8000300c:	e44e                	sd	s3,8(sp)
    8000300e:	1800                	addi	s0,sp,48
    80003010:	892a                	mv	s2,a0
    80003012:	84ae                	mv	s1,a1
    80003014:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003016:	fffff097          	auipc	ra,0xfffff
    8000301a:	9b0080e7          	jalr	-1616(ra) # 800019c6 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    8000301e:	86ce                	mv	a3,s3
    80003020:	864a                	mv	a2,s2
    80003022:	85a6                	mv	a1,s1
    80003024:	7d28                	ld	a0,120(a0)
    80003026:	ffffe097          	auipc	ra,0xffffe
    8000302a:	732080e7          	jalr	1842(ra) # 80001758 <copyinstr>
  if(err < 0)
    8000302e:	00054763          	bltz	a0,8000303c <fetchstr+0x3a>
  return strlen(buf);
    80003032:	8526                	mv	a0,s1
    80003034:	ffffe097          	auipc	ra,0xffffe
    80003038:	e0e080e7          	jalr	-498(ra) # 80000e42 <strlen>
}
    8000303c:	70a2                	ld	ra,40(sp)
    8000303e:	7402                	ld	s0,32(sp)
    80003040:	64e2                	ld	s1,24(sp)
    80003042:	6942                	ld	s2,16(sp)
    80003044:	69a2                	ld	s3,8(sp)
    80003046:	6145                	addi	sp,sp,48
    80003048:	8082                	ret

000000008000304a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    8000304a:	1101                	addi	sp,sp,-32
    8000304c:	ec06                	sd	ra,24(sp)
    8000304e:	e822                	sd	s0,16(sp)
    80003050:	e426                	sd	s1,8(sp)
    80003052:	1000                	addi	s0,sp,32
    80003054:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003056:	00000097          	auipc	ra,0x0
    8000305a:	ef2080e7          	jalr	-270(ra) # 80002f48 <argraw>
    8000305e:	c088                	sw	a0,0(s1)
  return 0;
}
    80003060:	4501                	li	a0,0
    80003062:	60e2                	ld	ra,24(sp)
    80003064:	6442                	ld	s0,16(sp)
    80003066:	64a2                	ld	s1,8(sp)
    80003068:	6105                	addi	sp,sp,32
    8000306a:	8082                	ret

000000008000306c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    8000306c:	1101                	addi	sp,sp,-32
    8000306e:	ec06                	sd	ra,24(sp)
    80003070:	e822                	sd	s0,16(sp)
    80003072:	e426                	sd	s1,8(sp)
    80003074:	1000                	addi	s0,sp,32
    80003076:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003078:	00000097          	auipc	ra,0x0
    8000307c:	ed0080e7          	jalr	-304(ra) # 80002f48 <argraw>
    80003080:	e088                	sd	a0,0(s1)
  return 0;
}
    80003082:	4501                	li	a0,0
    80003084:	60e2                	ld	ra,24(sp)
    80003086:	6442                	ld	s0,16(sp)
    80003088:	64a2                	ld	s1,8(sp)
    8000308a:	6105                	addi	sp,sp,32
    8000308c:	8082                	ret

000000008000308e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000308e:	1101                	addi	sp,sp,-32
    80003090:	ec06                	sd	ra,24(sp)
    80003092:	e822                	sd	s0,16(sp)
    80003094:	e426                	sd	s1,8(sp)
    80003096:	e04a                	sd	s2,0(sp)
    80003098:	1000                	addi	s0,sp,32
    8000309a:	84ae                	mv	s1,a1
    8000309c:	8932                	mv	s2,a2
  *ip = argraw(n);
    8000309e:	00000097          	auipc	ra,0x0
    800030a2:	eaa080e7          	jalr	-342(ra) # 80002f48 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    800030a6:	864a                	mv	a2,s2
    800030a8:	85a6                	mv	a1,s1
    800030aa:	00000097          	auipc	ra,0x0
    800030ae:	f58080e7          	jalr	-168(ra) # 80003002 <fetchstr>
}
    800030b2:	60e2                	ld	ra,24(sp)
    800030b4:	6442                	ld	s0,16(sp)
    800030b6:	64a2                	ld	s1,8(sp)
    800030b8:	6902                	ld	s2,0(sp)
    800030ba:	6105                	addi	sp,sp,32
    800030bc:	8082                	ret

00000000800030be <printtrace>:
[SYS_set_priority] "set_priority",
};


int 
printtrace(int syscallnum,int pid, uint64 ret, int arg){
    800030be:	1141                	addi	sp,sp,-16
    800030c0:	e406                	sd	ra,8(sp)
    800030c2:	e022                	sd	s0,0(sp)
    800030c4:	0800                	addi	s0,sp,16
  if(syscallnum == SYS_fork){
    800030c6:	4785                	li	a5,1
    800030c8:	02f50d63          	beq	a0,a5,80003102 <printtrace+0x44>
    printf("%d: syscall fork NULL -> %d\n",pid,ret);
  }
  else if(syscallnum == SYS_kill || syscallnum == SYS_sbrk){  
    800030cc:	4799                	li	a5,6
    800030ce:	00f50563          	beq	a0,a5,800030d8 <printtrace+0x1a>
    800030d2:	47b1                	li	a5,12
    800030d4:	04f51063          	bne	a0,a5,80003114 <printtrace+0x56>
    printf("%d: syscall %s %d -> %d\n",pid,syscallnames[syscallnum], arg, ret);
    800030d8:	050e                	slli	a0,a0,0x3
    800030da:	00005797          	auipc	a5,0x5
    800030de:	59678793          	addi	a5,a5,1430 # 80008670 <syscallnames>
    800030e2:	953e                	add	a0,a0,a5
    800030e4:	8732                	mv	a4,a2
    800030e6:	6110                	ld	a2,0(a0)
    800030e8:	00005517          	auipc	a0,0x5
    800030ec:	45050513          	addi	a0,a0,1104 # 80008538 <states.0+0x170>
    800030f0:	ffffd097          	auipc	ra,0xffffd
    800030f4:	484080e7          	jalr	1156(ra) # 80000574 <printf>
  }
  else{
    printf("%d: syscall %s -> %d\n",pid,syscallnames[syscallnum],ret);
  }
  return 0;   
}
    800030f8:	4501                	li	a0,0
    800030fa:	60a2                	ld	ra,8(sp)
    800030fc:	6402                	ld	s0,0(sp)
    800030fe:	0141                	addi	sp,sp,16
    80003100:	8082                	ret
    printf("%d: syscall fork NULL -> %d\n",pid,ret);
    80003102:	00005517          	auipc	a0,0x5
    80003106:	41650513          	addi	a0,a0,1046 # 80008518 <states.0+0x150>
    8000310a:	ffffd097          	auipc	ra,0xffffd
    8000310e:	46a080e7          	jalr	1130(ra) # 80000574 <printf>
    80003112:	b7dd                	j	800030f8 <printtrace+0x3a>
    printf("%d: syscall %s -> %d\n",pid,syscallnames[syscallnum],ret);
    80003114:	050e                	slli	a0,a0,0x3
    80003116:	00005797          	auipc	a5,0x5
    8000311a:	55a78793          	addi	a5,a5,1370 # 80008670 <syscallnames>
    8000311e:	953e                	add	a0,a0,a5
    80003120:	86b2                	mv	a3,a2
    80003122:	6110                	ld	a2,0(a0)
    80003124:	00005517          	auipc	a0,0x5
    80003128:	43450513          	addi	a0,a0,1076 # 80008558 <states.0+0x190>
    8000312c:	ffffd097          	auipc	ra,0xffffd
    80003130:	448080e7          	jalr	1096(ra) # 80000574 <printf>
    80003134:	b7d1                	j	800030f8 <printtrace+0x3a>

0000000080003136 <syscall>:


void
syscall(void)
{
    80003136:	715d                	addi	sp,sp,-80
    80003138:	e486                	sd	ra,72(sp)
    8000313a:	e0a2                	sd	s0,64(sp)
    8000313c:	fc26                	sd	s1,56(sp)
    8000313e:	f84a                	sd	s2,48(sp)
    80003140:	f44e                	sd	s3,40(sp)
    80003142:	f052                	sd	s4,32(sp)
    80003144:	ec56                	sd	s5,24(sp)
    80003146:	0880                	addi	s0,sp,80
  int num;
  struct proc *p = myproc();
    80003148:	fffff097          	auipc	ra,0xfffff
    8000314c:	87e080e7          	jalr	-1922(ra) # 800019c6 <myproc>
    80003150:	84aa                	mv	s1,a0
  int tracemask = p->tracemask;

  num = p->trapframe->a7;
    80003152:	615c                	ld	a5,128(a0)
    80003154:	77dc                	ld	a5,168(a5)
    80003156:	0007891b          	sext.w	s2,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000315a:	37fd                	addiw	a5,a5,-1
    8000315c:	475d                	li	a4,23
    8000315e:	04f76c63          	bltu	a4,a5,800031b6 <syscall+0x80>
    80003162:	00391713          	slli	a4,s2,0x3
    80003166:	00005797          	auipc	a5,0x5
    8000316a:	50a78793          	addi	a5,a5,1290 # 80008670 <syscallnames>
    8000316e:	97ba                	add	a5,a5,a4
    80003170:	0c87ba03          	ld	s4,200(a5)
    80003174:	040a0163          	beqz	s4,800031b6 <syscall+0x80>
  int tracemask = p->tracemask;
    80003178:	03452983          	lw	s3,52(a0)
    int arg;
    argint(0, &arg);
    8000317c:	fbc40593          	addi	a1,s0,-68
    80003180:	4501                	li	a0,0
    80003182:	00000097          	auipc	ra,0x0
    80003186:	ec8080e7          	jalr	-312(ra) # 8000304a <argint>

    p->trapframe->a0 = syscalls[num]();
    8000318a:	0804ba83          	ld	s5,128(s1)
    8000318e:	9a02                	jalr	s4
    80003190:	06aab823          	sd	a0,112(s5)

    if(tracemask & (1<<num)){
    80003194:	4129d9bb          	sraw	s3,s3,s2
    80003198:	0019f993          	andi	s3,s3,1
    8000319c:	02098c63          	beqz	s3,800031d4 <syscall+0x9e>
      printtrace(num,p->pid,p->trapframe->a0,arg);
    800031a0:	60dc                	ld	a5,128(s1)
    800031a2:	fbc42683          	lw	a3,-68(s0)
    800031a6:	7bb0                	ld	a2,112(a5)
    800031a8:	588c                	lw	a1,48(s1)
    800031aa:	854a                	mv	a0,s2
    800031ac:	00000097          	auipc	ra,0x0
    800031b0:	f12080e7          	jalr	-238(ra) # 800030be <printtrace>
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800031b4:	a005                	j	800031d4 <syscall+0x9e>
    }
    
  } else {
    printf("%d %s: unknown sys call %d\n",
    800031b6:	86ca                	mv	a3,s2
    800031b8:	18048613          	addi	a2,s1,384
    800031bc:	588c                	lw	a1,48(s1)
    800031be:	00005517          	auipc	a0,0x5
    800031c2:	3b250513          	addi	a0,a0,946 # 80008570 <states.0+0x1a8>
    800031c6:	ffffd097          	auipc	ra,0xffffd
    800031ca:	3ae080e7          	jalr	942(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800031ce:	60dc                	ld	a5,128(s1)
    800031d0:	577d                	li	a4,-1
    800031d2:	fbb8                	sd	a4,112(a5)
  }
}
    800031d4:	60a6                	ld	ra,72(sp)
    800031d6:	6406                	ld	s0,64(sp)
    800031d8:	74e2                	ld	s1,56(sp)
    800031da:	7942                	ld	s2,48(sp)
    800031dc:	79a2                	ld	s3,40(sp)
    800031de:	7a02                	ld	s4,32(sp)
    800031e0:	6ae2                	ld	s5,24(sp)
    800031e2:	6161                	addi	sp,sp,80
    800031e4:	8082                	ret

00000000800031e6 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800031e6:	1101                	addi	sp,sp,-32
    800031e8:	ec06                	sd	ra,24(sp)
    800031ea:	e822                	sd	s0,16(sp)
    800031ec:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800031ee:	fec40593          	addi	a1,s0,-20
    800031f2:	4501                	li	a0,0
    800031f4:	00000097          	auipc	ra,0x0
    800031f8:	e56080e7          	jalr	-426(ra) # 8000304a <argint>
    return -1;
    800031fc:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800031fe:	00054963          	bltz	a0,80003210 <sys_exit+0x2a>
  exit(n);
    80003202:	fec42503          	lw	a0,-20(s0)
    80003206:	fffff097          	auipc	ra,0xfffff
    8000320a:	3a8080e7          	jalr	936(ra) # 800025ae <exit>
  return 0;  // not reached
    8000320e:	4781                	li	a5,0
}
    80003210:	853e                	mv	a0,a5
    80003212:	60e2                	ld	ra,24(sp)
    80003214:	6442                	ld	s0,16(sp)
    80003216:	6105                	addi	sp,sp,32
    80003218:	8082                	ret

000000008000321a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000321a:	1141                	addi	sp,sp,-16
    8000321c:	e406                	sd	ra,8(sp)
    8000321e:	e022                	sd	s0,0(sp)
    80003220:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003222:	ffffe097          	auipc	ra,0xffffe
    80003226:	7a4080e7          	jalr	1956(ra) # 800019c6 <myproc>
}
    8000322a:	5908                	lw	a0,48(a0)
    8000322c:	60a2                	ld	ra,8(sp)
    8000322e:	6402                	ld	s0,0(sp)
    80003230:	0141                	addi	sp,sp,16
    80003232:	8082                	ret

0000000080003234 <sys_fork>:

uint64
sys_fork(void)
{
    80003234:	1141                	addi	sp,sp,-16
    80003236:	e406                	sd	ra,8(sp)
    80003238:	e022                	sd	s0,0(sp)
    8000323a:	0800                	addi	s0,sp,16
  return fork();
    8000323c:	fffff097          	auipc	ra,0xfffff
    80003240:	bb6080e7          	jalr	-1098(ra) # 80001df2 <fork>
}
    80003244:	60a2                	ld	ra,8(sp)
    80003246:	6402                	ld	s0,0(sp)
    80003248:	0141                	addi	sp,sp,16
    8000324a:	8082                	ret

000000008000324c <sys_wait>:

uint64
sys_wait(void)
{
    8000324c:	1101                	addi	sp,sp,-32
    8000324e:	ec06                	sd	ra,24(sp)
    80003250:	e822                	sd	s0,16(sp)
    80003252:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003254:	fe840593          	addi	a1,s0,-24
    80003258:	4501                	li	a0,0
    8000325a:	00000097          	auipc	ra,0x0
    8000325e:	e12080e7          	jalr	-494(ra) # 8000306c <argaddr>
    80003262:	87aa                	mv	a5,a0
    return -1;
    80003264:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003266:	0007c863          	bltz	a5,80003276 <sys_wait+0x2a>
  return wait(p);
    8000326a:	fe843503          	ld	a0,-24(s0)
    8000326e:	fffff097          	auipc	ra,0xfffff
    80003272:	136080e7          	jalr	310(ra) # 800023a4 <wait>
}
    80003276:	60e2                	ld	ra,24(sp)
    80003278:	6442                	ld	s0,16(sp)
    8000327a:	6105                	addi	sp,sp,32
    8000327c:	8082                	ret

000000008000327e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000327e:	7179                	addi	sp,sp,-48
    80003280:	f406                	sd	ra,40(sp)
    80003282:	f022                	sd	s0,32(sp)
    80003284:	ec26                	sd	s1,24(sp)
    80003286:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003288:	fdc40593          	addi	a1,s0,-36
    8000328c:	4501                	li	a0,0
    8000328e:	00000097          	auipc	ra,0x0
    80003292:	dbc080e7          	jalr	-580(ra) # 8000304a <argint>
    return -1;
    80003296:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003298:	00054f63          	bltz	a0,800032b6 <sys_sbrk+0x38>
  addr = myproc()->sz;
    8000329c:	ffffe097          	auipc	ra,0xffffe
    800032a0:	72a080e7          	jalr	1834(ra) # 800019c6 <myproc>
    800032a4:	5924                	lw	s1,112(a0)
  if(growproc(n) < 0)
    800032a6:	fdc42503          	lw	a0,-36(s0)
    800032aa:	fffff097          	auipc	ra,0xfffff
    800032ae:	ab0080e7          	jalr	-1360(ra) # 80001d5a <growproc>
    800032b2:	00054863          	bltz	a0,800032c2 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800032b6:	8526                	mv	a0,s1
    800032b8:	70a2                	ld	ra,40(sp)
    800032ba:	7402                	ld	s0,32(sp)
    800032bc:	64e2                	ld	s1,24(sp)
    800032be:	6145                	addi	sp,sp,48
    800032c0:	8082                	ret
    return -1;
    800032c2:	54fd                	li	s1,-1
    800032c4:	bfcd                	j	800032b6 <sys_sbrk+0x38>

00000000800032c6 <sys_sleep>:

uint64
sys_sleep(void)
{
    800032c6:	7139                	addi	sp,sp,-64
    800032c8:	fc06                	sd	ra,56(sp)
    800032ca:	f822                	sd	s0,48(sp)
    800032cc:	f426                	sd	s1,40(sp)
    800032ce:	f04a                	sd	s2,32(sp)
    800032d0:	ec4e                	sd	s3,24(sp)
    800032d2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800032d4:	fcc40593          	addi	a1,s0,-52
    800032d8:	4501                	li	a0,0
    800032da:	00000097          	auipc	ra,0x0
    800032de:	d70080e7          	jalr	-656(ra) # 8000304a <argint>
    return -1;
    800032e2:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800032e4:	06054563          	bltz	a0,8000334e <sys_sleep+0x88>
  acquire(&tickslock);
    800032e8:	00014517          	auipc	a0,0x14
    800032ec:	7e850513          	addi	a0,a0,2024 # 80017ad0 <tickslock>
    800032f0:	ffffe097          	auipc	ra,0xffffe
    800032f4:	8d2080e7          	jalr	-1838(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    800032f8:	00006917          	auipc	s2,0x6
    800032fc:	d3892903          	lw	s2,-712(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80003300:	fcc42783          	lw	a5,-52(s0)
    80003304:	cf85                	beqz	a5,8000333c <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003306:	00014997          	auipc	s3,0x14
    8000330a:	7ca98993          	addi	s3,s3,1994 # 80017ad0 <tickslock>
    8000330e:	00006497          	auipc	s1,0x6
    80003312:	d2248493          	addi	s1,s1,-734 # 80009030 <ticks>
    if(myproc()->killed){
    80003316:	ffffe097          	auipc	ra,0xffffe
    8000331a:	6b0080e7          	jalr	1712(ra) # 800019c6 <myproc>
    8000331e:	551c                	lw	a5,40(a0)
    80003320:	ef9d                	bnez	a5,8000335e <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003322:	85ce                	mv	a1,s3
    80003324:	8526                	mv	a0,s1
    80003326:	fffff097          	auipc	ra,0xfffff
    8000332a:	01a080e7          	jalr	26(ra) # 80002340 <sleep>
  while(ticks - ticks0 < n){
    8000332e:	409c                	lw	a5,0(s1)
    80003330:	412787bb          	subw	a5,a5,s2
    80003334:	fcc42703          	lw	a4,-52(s0)
    80003338:	fce7efe3          	bltu	a5,a4,80003316 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000333c:	00014517          	auipc	a0,0x14
    80003340:	79450513          	addi	a0,a0,1940 # 80017ad0 <tickslock>
    80003344:	ffffe097          	auipc	ra,0xffffe
    80003348:	932080e7          	jalr	-1742(ra) # 80000c76 <release>
  return 0;
    8000334c:	4781                	li	a5,0
}
    8000334e:	853e                	mv	a0,a5
    80003350:	70e2                	ld	ra,56(sp)
    80003352:	7442                	ld	s0,48(sp)
    80003354:	74a2                	ld	s1,40(sp)
    80003356:	7902                	ld	s2,32(sp)
    80003358:	69e2                	ld	s3,24(sp)
    8000335a:	6121                	addi	sp,sp,64
    8000335c:	8082                	ret
      release(&tickslock);
    8000335e:	00014517          	auipc	a0,0x14
    80003362:	77250513          	addi	a0,a0,1906 # 80017ad0 <tickslock>
    80003366:	ffffe097          	auipc	ra,0xffffe
    8000336a:	910080e7          	jalr	-1776(ra) # 80000c76 <release>
      return -1;
    8000336e:	57fd                	li	a5,-1
    80003370:	bff9                	j	8000334e <sys_sleep+0x88>

0000000080003372 <sys_kill>:

uint64
sys_kill(void)
{
    80003372:	1101                	addi	sp,sp,-32
    80003374:	ec06                	sd	ra,24(sp)
    80003376:	e822                	sd	s0,16(sp)
    80003378:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000337a:	fec40593          	addi	a1,s0,-20
    8000337e:	4501                	li	a0,0
    80003380:	00000097          	auipc	ra,0x0
    80003384:	cca080e7          	jalr	-822(ra) # 8000304a <argint>
    80003388:	87aa                	mv	a5,a0
    return -1;
    8000338a:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000338c:	0007c863          	bltz	a5,8000339c <sys_kill+0x2a>
  return kill(pid);
    80003390:	fec42503          	lw	a0,-20(s0)
    80003394:	fffff097          	auipc	ra,0xfffff
    80003398:	2fc080e7          	jalr	764(ra) # 80002690 <kill>
}
    8000339c:	60e2                	ld	ra,24(sp)
    8000339e:	6442                	ld	s0,16(sp)
    800033a0:	6105                	addi	sp,sp,32
    800033a2:	8082                	ret

00000000800033a4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800033a4:	1101                	addi	sp,sp,-32
    800033a6:	ec06                	sd	ra,24(sp)
    800033a8:	e822                	sd	s0,16(sp)
    800033aa:	e426                	sd	s1,8(sp)
    800033ac:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800033ae:	00014517          	auipc	a0,0x14
    800033b2:	72250513          	addi	a0,a0,1826 # 80017ad0 <tickslock>
    800033b6:	ffffe097          	auipc	ra,0xffffe
    800033ba:	80c080e7          	jalr	-2036(ra) # 80000bc2 <acquire>
  xticks = ticks;
    800033be:	00006497          	auipc	s1,0x6
    800033c2:	c724a483          	lw	s1,-910(s1) # 80009030 <ticks>
  release(&tickslock);
    800033c6:	00014517          	auipc	a0,0x14
    800033ca:	70a50513          	addi	a0,a0,1802 # 80017ad0 <tickslock>
    800033ce:	ffffe097          	auipc	ra,0xffffe
    800033d2:	8a8080e7          	jalr	-1880(ra) # 80000c76 <release>
  return xticks;
}
    800033d6:	02049513          	slli	a0,s1,0x20
    800033da:	9101                	srli	a0,a0,0x20
    800033dc:	60e2                	ld	ra,24(sp)
    800033de:	6442                	ld	s0,16(sp)
    800033e0:	64a2                	ld	s1,8(sp)
    800033e2:	6105                	addi	sp,sp,32
    800033e4:	8082                	ret

00000000800033e6 <sys_trace>:

uint64
sys_trace(void)
{
    800033e6:	1101                	addi	sp,sp,-32
    800033e8:	ec06                	sd	ra,24(sp)
    800033ea:	e822                	sd	s0,16(sp)
    800033ec:	1000                	addi	s0,sp,32
  int mask, pid;

  if(argint(0, &mask) < 0)
    800033ee:	fec40593          	addi	a1,s0,-20
    800033f2:	4501                	li	a0,0
    800033f4:	00000097          	auipc	ra,0x0
    800033f8:	c56080e7          	jalr	-938(ra) # 8000304a <argint>
    return -1;
    800033fc:	57fd                	li	a5,-1
  if(argint(0, &mask) < 0)
    800033fe:	02054563          	bltz	a0,80003428 <sys_trace+0x42>
  if(argint(1, &pid) < 0)
    80003402:	fe840593          	addi	a1,s0,-24
    80003406:	4505                	li	a0,1
    80003408:	00000097          	auipc	ra,0x0
    8000340c:	c42080e7          	jalr	-958(ra) # 8000304a <argint>
    return -1;
    80003410:	57fd                	li	a5,-1
  if(argint(1, &pid) < 0)
    80003412:	00054b63          	bltz	a0,80003428 <sys_trace+0x42>
  return trace(mask, pid);
    80003416:	fe842583          	lw	a1,-24(s0)
    8000341a:	fec42503          	lw	a0,-20(s0)
    8000341e:	fffff097          	auipc	ra,0xfffff
    80003422:	44a080e7          	jalr	1098(ra) # 80002868 <trace>
    80003426:	87aa                	mv	a5,a0
}
    80003428:	853e                	mv	a0,a5
    8000342a:	60e2                	ld	ra,24(sp)
    8000342c:	6442                	ld	s0,16(sp)
    8000342e:	6105                	addi	sp,sp,32
    80003430:	8082                	ret

0000000080003432 <sys_wait_stat>:


uint64
sys_wait_stat(void){
    80003432:	1101                	addi	sp,sp,-32
    80003434:	ec06                	sd	ra,24(sp)
    80003436:	e822                	sd	s0,16(sp)
    80003438:	1000                	addi	s0,sp,32
  uint64 stat;
  uint64 perf;
  if(argaddr(0, &stat) < 0)
    8000343a:	fe840593          	addi	a1,s0,-24
    8000343e:	4501                	li	a0,0
    80003440:	00000097          	auipc	ra,0x0
    80003444:	c2c080e7          	jalr	-980(ra) # 8000306c <argaddr>
    return -1;
    80003448:	57fd                	li	a5,-1
  if(argaddr(0, &stat) < 0)
    8000344a:	02054563          	bltz	a0,80003474 <sys_wait_stat+0x42>
  if(argaddr(1, &perf) < 0)
    8000344e:	fe040593          	addi	a1,s0,-32
    80003452:	4505                	li	a0,1
    80003454:	00000097          	auipc	ra,0x0
    80003458:	c18080e7          	jalr	-1000(ra) # 8000306c <argaddr>
    return -1;
    8000345c:	57fd                	li	a5,-1
  if(argaddr(1, &perf) < 0)
    8000345e:	00054b63          	bltz	a0,80003474 <sys_wait_stat+0x42>
  return wait_stat(stat, perf);
    80003462:	fe043583          	ld	a1,-32(s0)
    80003466:	fe843503          	ld	a0,-24(s0)
    8000346a:	fffff097          	auipc	ra,0xfffff
    8000346e:	468080e7          	jalr	1128(ra) # 800028d2 <wait_stat>
    80003472:	87aa                	mv	a5,a0
}
    80003474:	853e                	mv	a0,a5
    80003476:	60e2                	ld	ra,24(sp)
    80003478:	6442                	ld	s0,16(sp)
    8000347a:	6105                	addi	sp,sp,32
    8000347c:	8082                	ret

000000008000347e <sys_set_priority>:

uint64
sys_set_priority(void){
    8000347e:	1101                	addi	sp,sp,-32
    80003480:	ec06                	sd	ra,24(sp)
    80003482:	e822                	sd	s0,16(sp)
    80003484:	1000                	addi	s0,sp,32
  int priotity;
 if(argint(0,&priotity) < 0)
    80003486:	fec40593          	addi	a1,s0,-20
    8000348a:	4501                	li	a0,0
    8000348c:	00000097          	auipc	ra,0x0
    80003490:	bbe080e7          	jalr	-1090(ra) # 8000304a <argint>
    80003494:	87aa                	mv	a5,a0
    return -1;
    80003496:	557d                	li	a0,-1
 if(argint(0,&priotity) < 0)
    80003498:	0007c863          	bltz	a5,800034a8 <sys_set_priority+0x2a>
  return set_priority(priotity);
    8000349c:	fec42503          	lw	a0,-20(s0)
    800034a0:	fffff097          	auipc	ra,0xfffff
    800034a4:	60c080e7          	jalr	1548(ra) # 80002aac <set_priority>
}
    800034a8:	60e2                	ld	ra,24(sp)
    800034aa:	6442                	ld	s0,16(sp)
    800034ac:	6105                	addi	sp,sp,32
    800034ae:	8082                	ret

00000000800034b0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800034b0:	7179                	addi	sp,sp,-48
    800034b2:	f406                	sd	ra,40(sp)
    800034b4:	f022                	sd	s0,32(sp)
    800034b6:	ec26                	sd	s1,24(sp)
    800034b8:	e84a                	sd	s2,16(sp)
    800034ba:	e44e                	sd	s3,8(sp)
    800034bc:	e052                	sd	s4,0(sp)
    800034be:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800034c0:	00005597          	auipc	a1,0x5
    800034c4:	34058593          	addi	a1,a1,832 # 80008800 <syscalls+0xc8>
    800034c8:	00014517          	auipc	a0,0x14
    800034cc:	62050513          	addi	a0,a0,1568 # 80017ae8 <bcache>
    800034d0:	ffffd097          	auipc	ra,0xffffd
    800034d4:	662080e7          	jalr	1634(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800034d8:	0001c797          	auipc	a5,0x1c
    800034dc:	61078793          	addi	a5,a5,1552 # 8001fae8 <bcache+0x8000>
    800034e0:	0001d717          	auipc	a4,0x1d
    800034e4:	87070713          	addi	a4,a4,-1936 # 8001fd50 <bcache+0x8268>
    800034e8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800034ec:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034f0:	00014497          	auipc	s1,0x14
    800034f4:	61048493          	addi	s1,s1,1552 # 80017b00 <bcache+0x18>
    b->next = bcache.head.next;
    800034f8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800034fa:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800034fc:	00005a17          	auipc	s4,0x5
    80003500:	30ca0a13          	addi	s4,s4,780 # 80008808 <syscalls+0xd0>
    b->next = bcache.head.next;
    80003504:	2b893783          	ld	a5,696(s2)
    80003508:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000350a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000350e:	85d2                	mv	a1,s4
    80003510:	01048513          	addi	a0,s1,16
    80003514:	00001097          	auipc	ra,0x1
    80003518:	4c2080e7          	jalr	1218(ra) # 800049d6 <initsleeplock>
    bcache.head.next->prev = b;
    8000351c:	2b893783          	ld	a5,696(s2)
    80003520:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003522:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003526:	45848493          	addi	s1,s1,1112
    8000352a:	fd349de3          	bne	s1,s3,80003504 <binit+0x54>
  }
}
    8000352e:	70a2                	ld	ra,40(sp)
    80003530:	7402                	ld	s0,32(sp)
    80003532:	64e2                	ld	s1,24(sp)
    80003534:	6942                	ld	s2,16(sp)
    80003536:	69a2                	ld	s3,8(sp)
    80003538:	6a02                	ld	s4,0(sp)
    8000353a:	6145                	addi	sp,sp,48
    8000353c:	8082                	ret

000000008000353e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000353e:	7179                	addi	sp,sp,-48
    80003540:	f406                	sd	ra,40(sp)
    80003542:	f022                	sd	s0,32(sp)
    80003544:	ec26                	sd	s1,24(sp)
    80003546:	e84a                	sd	s2,16(sp)
    80003548:	e44e                	sd	s3,8(sp)
    8000354a:	1800                	addi	s0,sp,48
    8000354c:	892a                	mv	s2,a0
    8000354e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003550:	00014517          	auipc	a0,0x14
    80003554:	59850513          	addi	a0,a0,1432 # 80017ae8 <bcache>
    80003558:	ffffd097          	auipc	ra,0xffffd
    8000355c:	66a080e7          	jalr	1642(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003560:	0001d497          	auipc	s1,0x1d
    80003564:	8404b483          	ld	s1,-1984(s1) # 8001fda0 <bcache+0x82b8>
    80003568:	0001c797          	auipc	a5,0x1c
    8000356c:	7e878793          	addi	a5,a5,2024 # 8001fd50 <bcache+0x8268>
    80003570:	02f48f63          	beq	s1,a5,800035ae <bread+0x70>
    80003574:	873e                	mv	a4,a5
    80003576:	a021                	j	8000357e <bread+0x40>
    80003578:	68a4                	ld	s1,80(s1)
    8000357a:	02e48a63          	beq	s1,a4,800035ae <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000357e:	449c                	lw	a5,8(s1)
    80003580:	ff279ce3          	bne	a5,s2,80003578 <bread+0x3a>
    80003584:	44dc                	lw	a5,12(s1)
    80003586:	ff3799e3          	bne	a5,s3,80003578 <bread+0x3a>
      b->refcnt++;
    8000358a:	40bc                	lw	a5,64(s1)
    8000358c:	2785                	addiw	a5,a5,1
    8000358e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003590:	00014517          	auipc	a0,0x14
    80003594:	55850513          	addi	a0,a0,1368 # 80017ae8 <bcache>
    80003598:	ffffd097          	auipc	ra,0xffffd
    8000359c:	6de080e7          	jalr	1758(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    800035a0:	01048513          	addi	a0,s1,16
    800035a4:	00001097          	auipc	ra,0x1
    800035a8:	46c080e7          	jalr	1132(ra) # 80004a10 <acquiresleep>
      return b;
    800035ac:	a8b9                	j	8000360a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800035ae:	0001c497          	auipc	s1,0x1c
    800035b2:	7ea4b483          	ld	s1,2026(s1) # 8001fd98 <bcache+0x82b0>
    800035b6:	0001c797          	auipc	a5,0x1c
    800035ba:	79a78793          	addi	a5,a5,1946 # 8001fd50 <bcache+0x8268>
    800035be:	00f48863          	beq	s1,a5,800035ce <bread+0x90>
    800035c2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800035c4:	40bc                	lw	a5,64(s1)
    800035c6:	cf81                	beqz	a5,800035de <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800035c8:	64a4                	ld	s1,72(s1)
    800035ca:	fee49de3          	bne	s1,a4,800035c4 <bread+0x86>
  panic("bget: no buffers");
    800035ce:	00005517          	auipc	a0,0x5
    800035d2:	24250513          	addi	a0,a0,578 # 80008810 <syscalls+0xd8>
    800035d6:	ffffd097          	auipc	ra,0xffffd
    800035da:	f54080e7          	jalr	-172(ra) # 8000052a <panic>
      b->dev = dev;
    800035de:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800035e2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800035e6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800035ea:	4785                	li	a5,1
    800035ec:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035ee:	00014517          	auipc	a0,0x14
    800035f2:	4fa50513          	addi	a0,a0,1274 # 80017ae8 <bcache>
    800035f6:	ffffd097          	auipc	ra,0xffffd
    800035fa:	680080e7          	jalr	1664(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    800035fe:	01048513          	addi	a0,s1,16
    80003602:	00001097          	auipc	ra,0x1
    80003606:	40e080e7          	jalr	1038(ra) # 80004a10 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000360a:	409c                	lw	a5,0(s1)
    8000360c:	cb89                	beqz	a5,8000361e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000360e:	8526                	mv	a0,s1
    80003610:	70a2                	ld	ra,40(sp)
    80003612:	7402                	ld	s0,32(sp)
    80003614:	64e2                	ld	s1,24(sp)
    80003616:	6942                	ld	s2,16(sp)
    80003618:	69a2                	ld	s3,8(sp)
    8000361a:	6145                	addi	sp,sp,48
    8000361c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000361e:	4581                	li	a1,0
    80003620:	8526                	mv	a0,s1
    80003622:	00003097          	auipc	ra,0x3
    80003626:	f24080e7          	jalr	-220(ra) # 80006546 <virtio_disk_rw>
    b->valid = 1;
    8000362a:	4785                	li	a5,1
    8000362c:	c09c                	sw	a5,0(s1)
  return b;
    8000362e:	b7c5                	j	8000360e <bread+0xd0>

0000000080003630 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003630:	1101                	addi	sp,sp,-32
    80003632:	ec06                	sd	ra,24(sp)
    80003634:	e822                	sd	s0,16(sp)
    80003636:	e426                	sd	s1,8(sp)
    80003638:	1000                	addi	s0,sp,32
    8000363a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000363c:	0541                	addi	a0,a0,16
    8000363e:	00001097          	auipc	ra,0x1
    80003642:	46c080e7          	jalr	1132(ra) # 80004aaa <holdingsleep>
    80003646:	cd01                	beqz	a0,8000365e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003648:	4585                	li	a1,1
    8000364a:	8526                	mv	a0,s1
    8000364c:	00003097          	auipc	ra,0x3
    80003650:	efa080e7          	jalr	-262(ra) # 80006546 <virtio_disk_rw>
}
    80003654:	60e2                	ld	ra,24(sp)
    80003656:	6442                	ld	s0,16(sp)
    80003658:	64a2                	ld	s1,8(sp)
    8000365a:	6105                	addi	sp,sp,32
    8000365c:	8082                	ret
    panic("bwrite");
    8000365e:	00005517          	auipc	a0,0x5
    80003662:	1ca50513          	addi	a0,a0,458 # 80008828 <syscalls+0xf0>
    80003666:	ffffd097          	auipc	ra,0xffffd
    8000366a:	ec4080e7          	jalr	-316(ra) # 8000052a <panic>

000000008000366e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000366e:	1101                	addi	sp,sp,-32
    80003670:	ec06                	sd	ra,24(sp)
    80003672:	e822                	sd	s0,16(sp)
    80003674:	e426                	sd	s1,8(sp)
    80003676:	e04a                	sd	s2,0(sp)
    80003678:	1000                	addi	s0,sp,32
    8000367a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000367c:	01050913          	addi	s2,a0,16
    80003680:	854a                	mv	a0,s2
    80003682:	00001097          	auipc	ra,0x1
    80003686:	428080e7          	jalr	1064(ra) # 80004aaa <holdingsleep>
    8000368a:	c92d                	beqz	a0,800036fc <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000368c:	854a                	mv	a0,s2
    8000368e:	00001097          	auipc	ra,0x1
    80003692:	3d8080e7          	jalr	984(ra) # 80004a66 <releasesleep>

  acquire(&bcache.lock);
    80003696:	00014517          	auipc	a0,0x14
    8000369a:	45250513          	addi	a0,a0,1106 # 80017ae8 <bcache>
    8000369e:	ffffd097          	auipc	ra,0xffffd
    800036a2:	524080e7          	jalr	1316(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800036a6:	40bc                	lw	a5,64(s1)
    800036a8:	37fd                	addiw	a5,a5,-1
    800036aa:	0007871b          	sext.w	a4,a5
    800036ae:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800036b0:	eb05                	bnez	a4,800036e0 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800036b2:	68bc                	ld	a5,80(s1)
    800036b4:	64b8                	ld	a4,72(s1)
    800036b6:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800036b8:	64bc                	ld	a5,72(s1)
    800036ba:	68b8                	ld	a4,80(s1)
    800036bc:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800036be:	0001c797          	auipc	a5,0x1c
    800036c2:	42a78793          	addi	a5,a5,1066 # 8001fae8 <bcache+0x8000>
    800036c6:	2b87b703          	ld	a4,696(a5)
    800036ca:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800036cc:	0001c717          	auipc	a4,0x1c
    800036d0:	68470713          	addi	a4,a4,1668 # 8001fd50 <bcache+0x8268>
    800036d4:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800036d6:	2b87b703          	ld	a4,696(a5)
    800036da:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800036dc:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800036e0:	00014517          	auipc	a0,0x14
    800036e4:	40850513          	addi	a0,a0,1032 # 80017ae8 <bcache>
    800036e8:	ffffd097          	auipc	ra,0xffffd
    800036ec:	58e080e7          	jalr	1422(ra) # 80000c76 <release>
}
    800036f0:	60e2                	ld	ra,24(sp)
    800036f2:	6442                	ld	s0,16(sp)
    800036f4:	64a2                	ld	s1,8(sp)
    800036f6:	6902                	ld	s2,0(sp)
    800036f8:	6105                	addi	sp,sp,32
    800036fa:	8082                	ret
    panic("brelse");
    800036fc:	00005517          	auipc	a0,0x5
    80003700:	13450513          	addi	a0,a0,308 # 80008830 <syscalls+0xf8>
    80003704:	ffffd097          	auipc	ra,0xffffd
    80003708:	e26080e7          	jalr	-474(ra) # 8000052a <panic>

000000008000370c <bpin>:

void
bpin(struct buf *b) {
    8000370c:	1101                	addi	sp,sp,-32
    8000370e:	ec06                	sd	ra,24(sp)
    80003710:	e822                	sd	s0,16(sp)
    80003712:	e426                	sd	s1,8(sp)
    80003714:	1000                	addi	s0,sp,32
    80003716:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003718:	00014517          	auipc	a0,0x14
    8000371c:	3d050513          	addi	a0,a0,976 # 80017ae8 <bcache>
    80003720:	ffffd097          	auipc	ra,0xffffd
    80003724:	4a2080e7          	jalr	1186(ra) # 80000bc2 <acquire>
  b->refcnt++;
    80003728:	40bc                	lw	a5,64(s1)
    8000372a:	2785                	addiw	a5,a5,1
    8000372c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000372e:	00014517          	auipc	a0,0x14
    80003732:	3ba50513          	addi	a0,a0,954 # 80017ae8 <bcache>
    80003736:	ffffd097          	auipc	ra,0xffffd
    8000373a:	540080e7          	jalr	1344(ra) # 80000c76 <release>
}
    8000373e:	60e2                	ld	ra,24(sp)
    80003740:	6442                	ld	s0,16(sp)
    80003742:	64a2                	ld	s1,8(sp)
    80003744:	6105                	addi	sp,sp,32
    80003746:	8082                	ret

0000000080003748 <bunpin>:

void
bunpin(struct buf *b) {
    80003748:	1101                	addi	sp,sp,-32
    8000374a:	ec06                	sd	ra,24(sp)
    8000374c:	e822                	sd	s0,16(sp)
    8000374e:	e426                	sd	s1,8(sp)
    80003750:	1000                	addi	s0,sp,32
    80003752:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003754:	00014517          	auipc	a0,0x14
    80003758:	39450513          	addi	a0,a0,916 # 80017ae8 <bcache>
    8000375c:	ffffd097          	auipc	ra,0xffffd
    80003760:	466080e7          	jalr	1126(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003764:	40bc                	lw	a5,64(s1)
    80003766:	37fd                	addiw	a5,a5,-1
    80003768:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000376a:	00014517          	auipc	a0,0x14
    8000376e:	37e50513          	addi	a0,a0,894 # 80017ae8 <bcache>
    80003772:	ffffd097          	auipc	ra,0xffffd
    80003776:	504080e7          	jalr	1284(ra) # 80000c76 <release>
}
    8000377a:	60e2                	ld	ra,24(sp)
    8000377c:	6442                	ld	s0,16(sp)
    8000377e:	64a2                	ld	s1,8(sp)
    80003780:	6105                	addi	sp,sp,32
    80003782:	8082                	ret

0000000080003784 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003784:	1101                	addi	sp,sp,-32
    80003786:	ec06                	sd	ra,24(sp)
    80003788:	e822                	sd	s0,16(sp)
    8000378a:	e426                	sd	s1,8(sp)
    8000378c:	e04a                	sd	s2,0(sp)
    8000378e:	1000                	addi	s0,sp,32
    80003790:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003792:	00d5d59b          	srliw	a1,a1,0xd
    80003796:	0001d797          	auipc	a5,0x1d
    8000379a:	a2e7a783          	lw	a5,-1490(a5) # 800201c4 <sb+0x1c>
    8000379e:	9dbd                	addw	a1,a1,a5
    800037a0:	00000097          	auipc	ra,0x0
    800037a4:	d9e080e7          	jalr	-610(ra) # 8000353e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800037a8:	0074f713          	andi	a4,s1,7
    800037ac:	4785                	li	a5,1
    800037ae:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800037b2:	14ce                	slli	s1,s1,0x33
    800037b4:	90d9                	srli	s1,s1,0x36
    800037b6:	00950733          	add	a4,a0,s1
    800037ba:	05874703          	lbu	a4,88(a4)
    800037be:	00e7f6b3          	and	a3,a5,a4
    800037c2:	c69d                	beqz	a3,800037f0 <bfree+0x6c>
    800037c4:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800037c6:	94aa                	add	s1,s1,a0
    800037c8:	fff7c793          	not	a5,a5
    800037cc:	8ff9                	and	a5,a5,a4
    800037ce:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800037d2:	00001097          	auipc	ra,0x1
    800037d6:	11e080e7          	jalr	286(ra) # 800048f0 <log_write>
  brelse(bp);
    800037da:	854a                	mv	a0,s2
    800037dc:	00000097          	auipc	ra,0x0
    800037e0:	e92080e7          	jalr	-366(ra) # 8000366e <brelse>
}
    800037e4:	60e2                	ld	ra,24(sp)
    800037e6:	6442                	ld	s0,16(sp)
    800037e8:	64a2                	ld	s1,8(sp)
    800037ea:	6902                	ld	s2,0(sp)
    800037ec:	6105                	addi	sp,sp,32
    800037ee:	8082                	ret
    panic("freeing free block");
    800037f0:	00005517          	auipc	a0,0x5
    800037f4:	04850513          	addi	a0,a0,72 # 80008838 <syscalls+0x100>
    800037f8:	ffffd097          	auipc	ra,0xffffd
    800037fc:	d32080e7          	jalr	-718(ra) # 8000052a <panic>

0000000080003800 <balloc>:
{
    80003800:	711d                	addi	sp,sp,-96
    80003802:	ec86                	sd	ra,88(sp)
    80003804:	e8a2                	sd	s0,80(sp)
    80003806:	e4a6                	sd	s1,72(sp)
    80003808:	e0ca                	sd	s2,64(sp)
    8000380a:	fc4e                	sd	s3,56(sp)
    8000380c:	f852                	sd	s4,48(sp)
    8000380e:	f456                	sd	s5,40(sp)
    80003810:	f05a                	sd	s6,32(sp)
    80003812:	ec5e                	sd	s7,24(sp)
    80003814:	e862                	sd	s8,16(sp)
    80003816:	e466                	sd	s9,8(sp)
    80003818:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000381a:	0001d797          	auipc	a5,0x1d
    8000381e:	9927a783          	lw	a5,-1646(a5) # 800201ac <sb+0x4>
    80003822:	cbd1                	beqz	a5,800038b6 <balloc+0xb6>
    80003824:	8baa                	mv	s7,a0
    80003826:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003828:	0001db17          	auipc	s6,0x1d
    8000382c:	980b0b13          	addi	s6,s6,-1664 # 800201a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003830:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003832:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003834:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003836:	6c89                	lui	s9,0x2
    80003838:	a831                	j	80003854 <balloc+0x54>
    brelse(bp);
    8000383a:	854a                	mv	a0,s2
    8000383c:	00000097          	auipc	ra,0x0
    80003840:	e32080e7          	jalr	-462(ra) # 8000366e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003844:	015c87bb          	addw	a5,s9,s5
    80003848:	00078a9b          	sext.w	s5,a5
    8000384c:	004b2703          	lw	a4,4(s6)
    80003850:	06eaf363          	bgeu	s5,a4,800038b6 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003854:	41fad79b          	sraiw	a5,s5,0x1f
    80003858:	0137d79b          	srliw	a5,a5,0x13
    8000385c:	015787bb          	addw	a5,a5,s5
    80003860:	40d7d79b          	sraiw	a5,a5,0xd
    80003864:	01cb2583          	lw	a1,28(s6)
    80003868:	9dbd                	addw	a1,a1,a5
    8000386a:	855e                	mv	a0,s7
    8000386c:	00000097          	auipc	ra,0x0
    80003870:	cd2080e7          	jalr	-814(ra) # 8000353e <bread>
    80003874:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003876:	004b2503          	lw	a0,4(s6)
    8000387a:	000a849b          	sext.w	s1,s5
    8000387e:	8662                	mv	a2,s8
    80003880:	faa4fde3          	bgeu	s1,a0,8000383a <balloc+0x3a>
      m = 1 << (bi % 8);
    80003884:	41f6579b          	sraiw	a5,a2,0x1f
    80003888:	01d7d69b          	srliw	a3,a5,0x1d
    8000388c:	00c6873b          	addw	a4,a3,a2
    80003890:	00777793          	andi	a5,a4,7
    80003894:	9f95                	subw	a5,a5,a3
    80003896:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000389a:	4037571b          	sraiw	a4,a4,0x3
    8000389e:	00e906b3          	add	a3,s2,a4
    800038a2:	0586c683          	lbu	a3,88(a3)
    800038a6:	00d7f5b3          	and	a1,a5,a3
    800038aa:	cd91                	beqz	a1,800038c6 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038ac:	2605                	addiw	a2,a2,1
    800038ae:	2485                	addiw	s1,s1,1
    800038b0:	fd4618e3          	bne	a2,s4,80003880 <balloc+0x80>
    800038b4:	b759                	j	8000383a <balloc+0x3a>
  panic("balloc: out of blocks");
    800038b6:	00005517          	auipc	a0,0x5
    800038ba:	f9a50513          	addi	a0,a0,-102 # 80008850 <syscalls+0x118>
    800038be:	ffffd097          	auipc	ra,0xffffd
    800038c2:	c6c080e7          	jalr	-916(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800038c6:	974a                	add	a4,a4,s2
    800038c8:	8fd5                	or	a5,a5,a3
    800038ca:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800038ce:	854a                	mv	a0,s2
    800038d0:	00001097          	auipc	ra,0x1
    800038d4:	020080e7          	jalr	32(ra) # 800048f0 <log_write>
        brelse(bp);
    800038d8:	854a                	mv	a0,s2
    800038da:	00000097          	auipc	ra,0x0
    800038de:	d94080e7          	jalr	-620(ra) # 8000366e <brelse>
  bp = bread(dev, bno);
    800038e2:	85a6                	mv	a1,s1
    800038e4:	855e                	mv	a0,s7
    800038e6:	00000097          	auipc	ra,0x0
    800038ea:	c58080e7          	jalr	-936(ra) # 8000353e <bread>
    800038ee:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800038f0:	40000613          	li	a2,1024
    800038f4:	4581                	li	a1,0
    800038f6:	05850513          	addi	a0,a0,88
    800038fa:	ffffd097          	auipc	ra,0xffffd
    800038fe:	3c4080e7          	jalr	964(ra) # 80000cbe <memset>
  log_write(bp);
    80003902:	854a                	mv	a0,s2
    80003904:	00001097          	auipc	ra,0x1
    80003908:	fec080e7          	jalr	-20(ra) # 800048f0 <log_write>
  brelse(bp);
    8000390c:	854a                	mv	a0,s2
    8000390e:	00000097          	auipc	ra,0x0
    80003912:	d60080e7          	jalr	-672(ra) # 8000366e <brelse>
}
    80003916:	8526                	mv	a0,s1
    80003918:	60e6                	ld	ra,88(sp)
    8000391a:	6446                	ld	s0,80(sp)
    8000391c:	64a6                	ld	s1,72(sp)
    8000391e:	6906                	ld	s2,64(sp)
    80003920:	79e2                	ld	s3,56(sp)
    80003922:	7a42                	ld	s4,48(sp)
    80003924:	7aa2                	ld	s5,40(sp)
    80003926:	7b02                	ld	s6,32(sp)
    80003928:	6be2                	ld	s7,24(sp)
    8000392a:	6c42                	ld	s8,16(sp)
    8000392c:	6ca2                	ld	s9,8(sp)
    8000392e:	6125                	addi	sp,sp,96
    80003930:	8082                	ret

0000000080003932 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003932:	7179                	addi	sp,sp,-48
    80003934:	f406                	sd	ra,40(sp)
    80003936:	f022                	sd	s0,32(sp)
    80003938:	ec26                	sd	s1,24(sp)
    8000393a:	e84a                	sd	s2,16(sp)
    8000393c:	e44e                	sd	s3,8(sp)
    8000393e:	e052                	sd	s4,0(sp)
    80003940:	1800                	addi	s0,sp,48
    80003942:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003944:	47ad                	li	a5,11
    80003946:	04b7fe63          	bgeu	a5,a1,800039a2 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000394a:	ff45849b          	addiw	s1,a1,-12
    8000394e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003952:	0ff00793          	li	a5,255
    80003956:	0ae7e463          	bltu	a5,a4,800039fe <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000395a:	08052583          	lw	a1,128(a0)
    8000395e:	c5b5                	beqz	a1,800039ca <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003960:	00092503          	lw	a0,0(s2)
    80003964:	00000097          	auipc	ra,0x0
    80003968:	bda080e7          	jalr	-1062(ra) # 8000353e <bread>
    8000396c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000396e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003972:	02049713          	slli	a4,s1,0x20
    80003976:	01e75593          	srli	a1,a4,0x1e
    8000397a:	00b784b3          	add	s1,a5,a1
    8000397e:	0004a983          	lw	s3,0(s1)
    80003982:	04098e63          	beqz	s3,800039de <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003986:	8552                	mv	a0,s4
    80003988:	00000097          	auipc	ra,0x0
    8000398c:	ce6080e7          	jalr	-794(ra) # 8000366e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003990:	854e                	mv	a0,s3
    80003992:	70a2                	ld	ra,40(sp)
    80003994:	7402                	ld	s0,32(sp)
    80003996:	64e2                	ld	s1,24(sp)
    80003998:	6942                	ld	s2,16(sp)
    8000399a:	69a2                	ld	s3,8(sp)
    8000399c:	6a02                	ld	s4,0(sp)
    8000399e:	6145                	addi	sp,sp,48
    800039a0:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800039a2:	02059793          	slli	a5,a1,0x20
    800039a6:	01e7d593          	srli	a1,a5,0x1e
    800039aa:	00b504b3          	add	s1,a0,a1
    800039ae:	0504a983          	lw	s3,80(s1)
    800039b2:	fc099fe3          	bnez	s3,80003990 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800039b6:	4108                	lw	a0,0(a0)
    800039b8:	00000097          	auipc	ra,0x0
    800039bc:	e48080e7          	jalr	-440(ra) # 80003800 <balloc>
    800039c0:	0005099b          	sext.w	s3,a0
    800039c4:	0534a823          	sw	s3,80(s1)
    800039c8:	b7e1                	j	80003990 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800039ca:	4108                	lw	a0,0(a0)
    800039cc:	00000097          	auipc	ra,0x0
    800039d0:	e34080e7          	jalr	-460(ra) # 80003800 <balloc>
    800039d4:	0005059b          	sext.w	a1,a0
    800039d8:	08b92023          	sw	a1,128(s2)
    800039dc:	b751                	j	80003960 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800039de:	00092503          	lw	a0,0(s2)
    800039e2:	00000097          	auipc	ra,0x0
    800039e6:	e1e080e7          	jalr	-482(ra) # 80003800 <balloc>
    800039ea:	0005099b          	sext.w	s3,a0
    800039ee:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800039f2:	8552                	mv	a0,s4
    800039f4:	00001097          	auipc	ra,0x1
    800039f8:	efc080e7          	jalr	-260(ra) # 800048f0 <log_write>
    800039fc:	b769                	j	80003986 <bmap+0x54>
  panic("bmap: out of range");
    800039fe:	00005517          	auipc	a0,0x5
    80003a02:	e6a50513          	addi	a0,a0,-406 # 80008868 <syscalls+0x130>
    80003a06:	ffffd097          	auipc	ra,0xffffd
    80003a0a:	b24080e7          	jalr	-1244(ra) # 8000052a <panic>

0000000080003a0e <iget>:
{
    80003a0e:	7179                	addi	sp,sp,-48
    80003a10:	f406                	sd	ra,40(sp)
    80003a12:	f022                	sd	s0,32(sp)
    80003a14:	ec26                	sd	s1,24(sp)
    80003a16:	e84a                	sd	s2,16(sp)
    80003a18:	e44e                	sd	s3,8(sp)
    80003a1a:	e052                	sd	s4,0(sp)
    80003a1c:	1800                	addi	s0,sp,48
    80003a1e:	89aa                	mv	s3,a0
    80003a20:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003a22:	0001c517          	auipc	a0,0x1c
    80003a26:	7a650513          	addi	a0,a0,1958 # 800201c8 <itable>
    80003a2a:	ffffd097          	auipc	ra,0xffffd
    80003a2e:	198080e7          	jalr	408(ra) # 80000bc2 <acquire>
  empty = 0;
    80003a32:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a34:	0001c497          	auipc	s1,0x1c
    80003a38:	7ac48493          	addi	s1,s1,1964 # 800201e0 <itable+0x18>
    80003a3c:	0001e697          	auipc	a3,0x1e
    80003a40:	23468693          	addi	a3,a3,564 # 80021c70 <log>
    80003a44:	a039                	j	80003a52 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a46:	02090b63          	beqz	s2,80003a7c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a4a:	08848493          	addi	s1,s1,136
    80003a4e:	02d48a63          	beq	s1,a3,80003a82 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003a52:	449c                	lw	a5,8(s1)
    80003a54:	fef059e3          	blez	a5,80003a46 <iget+0x38>
    80003a58:	4098                	lw	a4,0(s1)
    80003a5a:	ff3716e3          	bne	a4,s3,80003a46 <iget+0x38>
    80003a5e:	40d8                	lw	a4,4(s1)
    80003a60:	ff4713e3          	bne	a4,s4,80003a46 <iget+0x38>
      ip->ref++;
    80003a64:	2785                	addiw	a5,a5,1
    80003a66:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003a68:	0001c517          	auipc	a0,0x1c
    80003a6c:	76050513          	addi	a0,a0,1888 # 800201c8 <itable>
    80003a70:	ffffd097          	auipc	ra,0xffffd
    80003a74:	206080e7          	jalr	518(ra) # 80000c76 <release>
      return ip;
    80003a78:	8926                	mv	s2,s1
    80003a7a:	a03d                	j	80003aa8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a7c:	f7f9                	bnez	a5,80003a4a <iget+0x3c>
    80003a7e:	8926                	mv	s2,s1
    80003a80:	b7e9                	j	80003a4a <iget+0x3c>
  if(empty == 0)
    80003a82:	02090c63          	beqz	s2,80003aba <iget+0xac>
  ip->dev = dev;
    80003a86:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003a8a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003a8e:	4785                	li	a5,1
    80003a90:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003a94:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003a98:	0001c517          	auipc	a0,0x1c
    80003a9c:	73050513          	addi	a0,a0,1840 # 800201c8 <itable>
    80003aa0:	ffffd097          	auipc	ra,0xffffd
    80003aa4:	1d6080e7          	jalr	470(ra) # 80000c76 <release>
}
    80003aa8:	854a                	mv	a0,s2
    80003aaa:	70a2                	ld	ra,40(sp)
    80003aac:	7402                	ld	s0,32(sp)
    80003aae:	64e2                	ld	s1,24(sp)
    80003ab0:	6942                	ld	s2,16(sp)
    80003ab2:	69a2                	ld	s3,8(sp)
    80003ab4:	6a02                	ld	s4,0(sp)
    80003ab6:	6145                	addi	sp,sp,48
    80003ab8:	8082                	ret
    panic("iget: no inodes");
    80003aba:	00005517          	auipc	a0,0x5
    80003abe:	dc650513          	addi	a0,a0,-570 # 80008880 <syscalls+0x148>
    80003ac2:	ffffd097          	auipc	ra,0xffffd
    80003ac6:	a68080e7          	jalr	-1432(ra) # 8000052a <panic>

0000000080003aca <fsinit>:
fsinit(int dev) {
    80003aca:	7179                	addi	sp,sp,-48
    80003acc:	f406                	sd	ra,40(sp)
    80003ace:	f022                	sd	s0,32(sp)
    80003ad0:	ec26                	sd	s1,24(sp)
    80003ad2:	e84a                	sd	s2,16(sp)
    80003ad4:	e44e                	sd	s3,8(sp)
    80003ad6:	1800                	addi	s0,sp,48
    80003ad8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003ada:	4585                	li	a1,1
    80003adc:	00000097          	auipc	ra,0x0
    80003ae0:	a62080e7          	jalr	-1438(ra) # 8000353e <bread>
    80003ae4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003ae6:	0001c997          	auipc	s3,0x1c
    80003aea:	6c298993          	addi	s3,s3,1730 # 800201a8 <sb>
    80003aee:	02000613          	li	a2,32
    80003af2:	05850593          	addi	a1,a0,88
    80003af6:	854e                	mv	a0,s3
    80003af8:	ffffd097          	auipc	ra,0xffffd
    80003afc:	222080e7          	jalr	546(ra) # 80000d1a <memmove>
  brelse(bp);
    80003b00:	8526                	mv	a0,s1
    80003b02:	00000097          	auipc	ra,0x0
    80003b06:	b6c080e7          	jalr	-1172(ra) # 8000366e <brelse>
  if(sb.magic != FSMAGIC)
    80003b0a:	0009a703          	lw	a4,0(s3)
    80003b0e:	102037b7          	lui	a5,0x10203
    80003b12:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b16:	02f71263          	bne	a4,a5,80003b3a <fsinit+0x70>
  initlog(dev, &sb);
    80003b1a:	0001c597          	auipc	a1,0x1c
    80003b1e:	68e58593          	addi	a1,a1,1678 # 800201a8 <sb>
    80003b22:	854a                	mv	a0,s2
    80003b24:	00001097          	auipc	ra,0x1
    80003b28:	b4e080e7          	jalr	-1202(ra) # 80004672 <initlog>
}
    80003b2c:	70a2                	ld	ra,40(sp)
    80003b2e:	7402                	ld	s0,32(sp)
    80003b30:	64e2                	ld	s1,24(sp)
    80003b32:	6942                	ld	s2,16(sp)
    80003b34:	69a2                	ld	s3,8(sp)
    80003b36:	6145                	addi	sp,sp,48
    80003b38:	8082                	ret
    panic("invalid file system");
    80003b3a:	00005517          	auipc	a0,0x5
    80003b3e:	d5650513          	addi	a0,a0,-682 # 80008890 <syscalls+0x158>
    80003b42:	ffffd097          	auipc	ra,0xffffd
    80003b46:	9e8080e7          	jalr	-1560(ra) # 8000052a <panic>

0000000080003b4a <iinit>:
{
    80003b4a:	7179                	addi	sp,sp,-48
    80003b4c:	f406                	sd	ra,40(sp)
    80003b4e:	f022                	sd	s0,32(sp)
    80003b50:	ec26                	sd	s1,24(sp)
    80003b52:	e84a                	sd	s2,16(sp)
    80003b54:	e44e                	sd	s3,8(sp)
    80003b56:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003b58:	00005597          	auipc	a1,0x5
    80003b5c:	d5058593          	addi	a1,a1,-688 # 800088a8 <syscalls+0x170>
    80003b60:	0001c517          	auipc	a0,0x1c
    80003b64:	66850513          	addi	a0,a0,1640 # 800201c8 <itable>
    80003b68:	ffffd097          	auipc	ra,0xffffd
    80003b6c:	fca080e7          	jalr	-54(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003b70:	0001c497          	auipc	s1,0x1c
    80003b74:	68048493          	addi	s1,s1,1664 # 800201f0 <itable+0x28>
    80003b78:	0001e997          	auipc	s3,0x1e
    80003b7c:	10898993          	addi	s3,s3,264 # 80021c80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003b80:	00005917          	auipc	s2,0x5
    80003b84:	d3090913          	addi	s2,s2,-720 # 800088b0 <syscalls+0x178>
    80003b88:	85ca                	mv	a1,s2
    80003b8a:	8526                	mv	a0,s1
    80003b8c:	00001097          	auipc	ra,0x1
    80003b90:	e4a080e7          	jalr	-438(ra) # 800049d6 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003b94:	08848493          	addi	s1,s1,136
    80003b98:	ff3498e3          	bne	s1,s3,80003b88 <iinit+0x3e>
}
    80003b9c:	70a2                	ld	ra,40(sp)
    80003b9e:	7402                	ld	s0,32(sp)
    80003ba0:	64e2                	ld	s1,24(sp)
    80003ba2:	6942                	ld	s2,16(sp)
    80003ba4:	69a2                	ld	s3,8(sp)
    80003ba6:	6145                	addi	sp,sp,48
    80003ba8:	8082                	ret

0000000080003baa <ialloc>:
{
    80003baa:	715d                	addi	sp,sp,-80
    80003bac:	e486                	sd	ra,72(sp)
    80003bae:	e0a2                	sd	s0,64(sp)
    80003bb0:	fc26                	sd	s1,56(sp)
    80003bb2:	f84a                	sd	s2,48(sp)
    80003bb4:	f44e                	sd	s3,40(sp)
    80003bb6:	f052                	sd	s4,32(sp)
    80003bb8:	ec56                	sd	s5,24(sp)
    80003bba:	e85a                	sd	s6,16(sp)
    80003bbc:	e45e                	sd	s7,8(sp)
    80003bbe:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003bc0:	0001c717          	auipc	a4,0x1c
    80003bc4:	5f472703          	lw	a4,1524(a4) # 800201b4 <sb+0xc>
    80003bc8:	4785                	li	a5,1
    80003bca:	04e7fa63          	bgeu	a5,a4,80003c1e <ialloc+0x74>
    80003bce:	8aaa                	mv	s5,a0
    80003bd0:	8bae                	mv	s7,a1
    80003bd2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003bd4:	0001ca17          	auipc	s4,0x1c
    80003bd8:	5d4a0a13          	addi	s4,s4,1492 # 800201a8 <sb>
    80003bdc:	00048b1b          	sext.w	s6,s1
    80003be0:	0044d793          	srli	a5,s1,0x4
    80003be4:	018a2583          	lw	a1,24(s4)
    80003be8:	9dbd                	addw	a1,a1,a5
    80003bea:	8556                	mv	a0,s5
    80003bec:	00000097          	auipc	ra,0x0
    80003bf0:	952080e7          	jalr	-1710(ra) # 8000353e <bread>
    80003bf4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003bf6:	05850993          	addi	s3,a0,88
    80003bfa:	00f4f793          	andi	a5,s1,15
    80003bfe:	079a                	slli	a5,a5,0x6
    80003c00:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003c02:	00099783          	lh	a5,0(s3)
    80003c06:	c785                	beqz	a5,80003c2e <ialloc+0x84>
    brelse(bp);
    80003c08:	00000097          	auipc	ra,0x0
    80003c0c:	a66080e7          	jalr	-1434(ra) # 8000366e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c10:	0485                	addi	s1,s1,1
    80003c12:	00ca2703          	lw	a4,12(s4)
    80003c16:	0004879b          	sext.w	a5,s1
    80003c1a:	fce7e1e3          	bltu	a5,a4,80003bdc <ialloc+0x32>
  panic("ialloc: no inodes");
    80003c1e:	00005517          	auipc	a0,0x5
    80003c22:	c9a50513          	addi	a0,a0,-870 # 800088b8 <syscalls+0x180>
    80003c26:	ffffd097          	auipc	ra,0xffffd
    80003c2a:	904080e7          	jalr	-1788(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003c2e:	04000613          	li	a2,64
    80003c32:	4581                	li	a1,0
    80003c34:	854e                	mv	a0,s3
    80003c36:	ffffd097          	auipc	ra,0xffffd
    80003c3a:	088080e7          	jalr	136(ra) # 80000cbe <memset>
      dip->type = type;
    80003c3e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003c42:	854a                	mv	a0,s2
    80003c44:	00001097          	auipc	ra,0x1
    80003c48:	cac080e7          	jalr	-852(ra) # 800048f0 <log_write>
      brelse(bp);
    80003c4c:	854a                	mv	a0,s2
    80003c4e:	00000097          	auipc	ra,0x0
    80003c52:	a20080e7          	jalr	-1504(ra) # 8000366e <brelse>
      return iget(dev, inum);
    80003c56:	85da                	mv	a1,s6
    80003c58:	8556                	mv	a0,s5
    80003c5a:	00000097          	auipc	ra,0x0
    80003c5e:	db4080e7          	jalr	-588(ra) # 80003a0e <iget>
}
    80003c62:	60a6                	ld	ra,72(sp)
    80003c64:	6406                	ld	s0,64(sp)
    80003c66:	74e2                	ld	s1,56(sp)
    80003c68:	7942                	ld	s2,48(sp)
    80003c6a:	79a2                	ld	s3,40(sp)
    80003c6c:	7a02                	ld	s4,32(sp)
    80003c6e:	6ae2                	ld	s5,24(sp)
    80003c70:	6b42                	ld	s6,16(sp)
    80003c72:	6ba2                	ld	s7,8(sp)
    80003c74:	6161                	addi	sp,sp,80
    80003c76:	8082                	ret

0000000080003c78 <iupdate>:
{
    80003c78:	1101                	addi	sp,sp,-32
    80003c7a:	ec06                	sd	ra,24(sp)
    80003c7c:	e822                	sd	s0,16(sp)
    80003c7e:	e426                	sd	s1,8(sp)
    80003c80:	e04a                	sd	s2,0(sp)
    80003c82:	1000                	addi	s0,sp,32
    80003c84:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c86:	415c                	lw	a5,4(a0)
    80003c88:	0047d79b          	srliw	a5,a5,0x4
    80003c8c:	0001c597          	auipc	a1,0x1c
    80003c90:	5345a583          	lw	a1,1332(a1) # 800201c0 <sb+0x18>
    80003c94:	9dbd                	addw	a1,a1,a5
    80003c96:	4108                	lw	a0,0(a0)
    80003c98:	00000097          	auipc	ra,0x0
    80003c9c:	8a6080e7          	jalr	-1882(ra) # 8000353e <bread>
    80003ca0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ca2:	05850793          	addi	a5,a0,88
    80003ca6:	40c8                	lw	a0,4(s1)
    80003ca8:	893d                	andi	a0,a0,15
    80003caa:	051a                	slli	a0,a0,0x6
    80003cac:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003cae:	04449703          	lh	a4,68(s1)
    80003cb2:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003cb6:	04649703          	lh	a4,70(s1)
    80003cba:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003cbe:	04849703          	lh	a4,72(s1)
    80003cc2:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003cc6:	04a49703          	lh	a4,74(s1)
    80003cca:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003cce:	44f8                	lw	a4,76(s1)
    80003cd0:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003cd2:	03400613          	li	a2,52
    80003cd6:	05048593          	addi	a1,s1,80
    80003cda:	0531                	addi	a0,a0,12
    80003cdc:	ffffd097          	auipc	ra,0xffffd
    80003ce0:	03e080e7          	jalr	62(ra) # 80000d1a <memmove>
  log_write(bp);
    80003ce4:	854a                	mv	a0,s2
    80003ce6:	00001097          	auipc	ra,0x1
    80003cea:	c0a080e7          	jalr	-1014(ra) # 800048f0 <log_write>
  brelse(bp);
    80003cee:	854a                	mv	a0,s2
    80003cf0:	00000097          	auipc	ra,0x0
    80003cf4:	97e080e7          	jalr	-1666(ra) # 8000366e <brelse>
}
    80003cf8:	60e2                	ld	ra,24(sp)
    80003cfa:	6442                	ld	s0,16(sp)
    80003cfc:	64a2                	ld	s1,8(sp)
    80003cfe:	6902                	ld	s2,0(sp)
    80003d00:	6105                	addi	sp,sp,32
    80003d02:	8082                	ret

0000000080003d04 <idup>:
{
    80003d04:	1101                	addi	sp,sp,-32
    80003d06:	ec06                	sd	ra,24(sp)
    80003d08:	e822                	sd	s0,16(sp)
    80003d0a:	e426                	sd	s1,8(sp)
    80003d0c:	1000                	addi	s0,sp,32
    80003d0e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d10:	0001c517          	auipc	a0,0x1c
    80003d14:	4b850513          	addi	a0,a0,1208 # 800201c8 <itable>
    80003d18:	ffffd097          	auipc	ra,0xffffd
    80003d1c:	eaa080e7          	jalr	-342(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003d20:	449c                	lw	a5,8(s1)
    80003d22:	2785                	addiw	a5,a5,1
    80003d24:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d26:	0001c517          	auipc	a0,0x1c
    80003d2a:	4a250513          	addi	a0,a0,1186 # 800201c8 <itable>
    80003d2e:	ffffd097          	auipc	ra,0xffffd
    80003d32:	f48080e7          	jalr	-184(ra) # 80000c76 <release>
}
    80003d36:	8526                	mv	a0,s1
    80003d38:	60e2                	ld	ra,24(sp)
    80003d3a:	6442                	ld	s0,16(sp)
    80003d3c:	64a2                	ld	s1,8(sp)
    80003d3e:	6105                	addi	sp,sp,32
    80003d40:	8082                	ret

0000000080003d42 <ilock>:
{
    80003d42:	1101                	addi	sp,sp,-32
    80003d44:	ec06                	sd	ra,24(sp)
    80003d46:	e822                	sd	s0,16(sp)
    80003d48:	e426                	sd	s1,8(sp)
    80003d4a:	e04a                	sd	s2,0(sp)
    80003d4c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003d4e:	c115                	beqz	a0,80003d72 <ilock+0x30>
    80003d50:	84aa                	mv	s1,a0
    80003d52:	451c                	lw	a5,8(a0)
    80003d54:	00f05f63          	blez	a5,80003d72 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003d58:	0541                	addi	a0,a0,16
    80003d5a:	00001097          	auipc	ra,0x1
    80003d5e:	cb6080e7          	jalr	-842(ra) # 80004a10 <acquiresleep>
  if(ip->valid == 0){
    80003d62:	40bc                	lw	a5,64(s1)
    80003d64:	cf99                	beqz	a5,80003d82 <ilock+0x40>
}
    80003d66:	60e2                	ld	ra,24(sp)
    80003d68:	6442                	ld	s0,16(sp)
    80003d6a:	64a2                	ld	s1,8(sp)
    80003d6c:	6902                	ld	s2,0(sp)
    80003d6e:	6105                	addi	sp,sp,32
    80003d70:	8082                	ret
    panic("ilock");
    80003d72:	00005517          	auipc	a0,0x5
    80003d76:	b5e50513          	addi	a0,a0,-1186 # 800088d0 <syscalls+0x198>
    80003d7a:	ffffc097          	auipc	ra,0xffffc
    80003d7e:	7b0080e7          	jalr	1968(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d82:	40dc                	lw	a5,4(s1)
    80003d84:	0047d79b          	srliw	a5,a5,0x4
    80003d88:	0001c597          	auipc	a1,0x1c
    80003d8c:	4385a583          	lw	a1,1080(a1) # 800201c0 <sb+0x18>
    80003d90:	9dbd                	addw	a1,a1,a5
    80003d92:	4088                	lw	a0,0(s1)
    80003d94:	fffff097          	auipc	ra,0xfffff
    80003d98:	7aa080e7          	jalr	1962(ra) # 8000353e <bread>
    80003d9c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d9e:	05850593          	addi	a1,a0,88
    80003da2:	40dc                	lw	a5,4(s1)
    80003da4:	8bbd                	andi	a5,a5,15
    80003da6:	079a                	slli	a5,a5,0x6
    80003da8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003daa:	00059783          	lh	a5,0(a1)
    80003dae:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003db2:	00259783          	lh	a5,2(a1)
    80003db6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003dba:	00459783          	lh	a5,4(a1)
    80003dbe:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003dc2:	00659783          	lh	a5,6(a1)
    80003dc6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003dca:	459c                	lw	a5,8(a1)
    80003dcc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003dce:	03400613          	li	a2,52
    80003dd2:	05b1                	addi	a1,a1,12
    80003dd4:	05048513          	addi	a0,s1,80
    80003dd8:	ffffd097          	auipc	ra,0xffffd
    80003ddc:	f42080e7          	jalr	-190(ra) # 80000d1a <memmove>
    brelse(bp);
    80003de0:	854a                	mv	a0,s2
    80003de2:	00000097          	auipc	ra,0x0
    80003de6:	88c080e7          	jalr	-1908(ra) # 8000366e <brelse>
    ip->valid = 1;
    80003dea:	4785                	li	a5,1
    80003dec:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003dee:	04449783          	lh	a5,68(s1)
    80003df2:	fbb5                	bnez	a5,80003d66 <ilock+0x24>
      panic("ilock: no type");
    80003df4:	00005517          	auipc	a0,0x5
    80003df8:	ae450513          	addi	a0,a0,-1308 # 800088d8 <syscalls+0x1a0>
    80003dfc:	ffffc097          	auipc	ra,0xffffc
    80003e00:	72e080e7          	jalr	1838(ra) # 8000052a <panic>

0000000080003e04 <iunlock>:
{
    80003e04:	1101                	addi	sp,sp,-32
    80003e06:	ec06                	sd	ra,24(sp)
    80003e08:	e822                	sd	s0,16(sp)
    80003e0a:	e426                	sd	s1,8(sp)
    80003e0c:	e04a                	sd	s2,0(sp)
    80003e0e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003e10:	c905                	beqz	a0,80003e40 <iunlock+0x3c>
    80003e12:	84aa                	mv	s1,a0
    80003e14:	01050913          	addi	s2,a0,16
    80003e18:	854a                	mv	a0,s2
    80003e1a:	00001097          	auipc	ra,0x1
    80003e1e:	c90080e7          	jalr	-880(ra) # 80004aaa <holdingsleep>
    80003e22:	cd19                	beqz	a0,80003e40 <iunlock+0x3c>
    80003e24:	449c                	lw	a5,8(s1)
    80003e26:	00f05d63          	blez	a5,80003e40 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003e2a:	854a                	mv	a0,s2
    80003e2c:	00001097          	auipc	ra,0x1
    80003e30:	c3a080e7          	jalr	-966(ra) # 80004a66 <releasesleep>
}
    80003e34:	60e2                	ld	ra,24(sp)
    80003e36:	6442                	ld	s0,16(sp)
    80003e38:	64a2                	ld	s1,8(sp)
    80003e3a:	6902                	ld	s2,0(sp)
    80003e3c:	6105                	addi	sp,sp,32
    80003e3e:	8082                	ret
    panic("iunlock");
    80003e40:	00005517          	auipc	a0,0x5
    80003e44:	aa850513          	addi	a0,a0,-1368 # 800088e8 <syscalls+0x1b0>
    80003e48:	ffffc097          	auipc	ra,0xffffc
    80003e4c:	6e2080e7          	jalr	1762(ra) # 8000052a <panic>

0000000080003e50 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003e50:	7179                	addi	sp,sp,-48
    80003e52:	f406                	sd	ra,40(sp)
    80003e54:	f022                	sd	s0,32(sp)
    80003e56:	ec26                	sd	s1,24(sp)
    80003e58:	e84a                	sd	s2,16(sp)
    80003e5a:	e44e                	sd	s3,8(sp)
    80003e5c:	e052                	sd	s4,0(sp)
    80003e5e:	1800                	addi	s0,sp,48
    80003e60:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003e62:	05050493          	addi	s1,a0,80
    80003e66:	08050913          	addi	s2,a0,128
    80003e6a:	a021                	j	80003e72 <itrunc+0x22>
    80003e6c:	0491                	addi	s1,s1,4
    80003e6e:	01248d63          	beq	s1,s2,80003e88 <itrunc+0x38>
    if(ip->addrs[i]){
    80003e72:	408c                	lw	a1,0(s1)
    80003e74:	dde5                	beqz	a1,80003e6c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003e76:	0009a503          	lw	a0,0(s3)
    80003e7a:	00000097          	auipc	ra,0x0
    80003e7e:	90a080e7          	jalr	-1782(ra) # 80003784 <bfree>
      ip->addrs[i] = 0;
    80003e82:	0004a023          	sw	zero,0(s1)
    80003e86:	b7dd                	j	80003e6c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003e88:	0809a583          	lw	a1,128(s3)
    80003e8c:	e185                	bnez	a1,80003eac <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003e8e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003e92:	854e                	mv	a0,s3
    80003e94:	00000097          	auipc	ra,0x0
    80003e98:	de4080e7          	jalr	-540(ra) # 80003c78 <iupdate>
}
    80003e9c:	70a2                	ld	ra,40(sp)
    80003e9e:	7402                	ld	s0,32(sp)
    80003ea0:	64e2                	ld	s1,24(sp)
    80003ea2:	6942                	ld	s2,16(sp)
    80003ea4:	69a2                	ld	s3,8(sp)
    80003ea6:	6a02                	ld	s4,0(sp)
    80003ea8:	6145                	addi	sp,sp,48
    80003eaa:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003eac:	0009a503          	lw	a0,0(s3)
    80003eb0:	fffff097          	auipc	ra,0xfffff
    80003eb4:	68e080e7          	jalr	1678(ra) # 8000353e <bread>
    80003eb8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003eba:	05850493          	addi	s1,a0,88
    80003ebe:	45850913          	addi	s2,a0,1112
    80003ec2:	a021                	j	80003eca <itrunc+0x7a>
    80003ec4:	0491                	addi	s1,s1,4
    80003ec6:	01248b63          	beq	s1,s2,80003edc <itrunc+0x8c>
      if(a[j])
    80003eca:	408c                	lw	a1,0(s1)
    80003ecc:	dde5                	beqz	a1,80003ec4 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003ece:	0009a503          	lw	a0,0(s3)
    80003ed2:	00000097          	auipc	ra,0x0
    80003ed6:	8b2080e7          	jalr	-1870(ra) # 80003784 <bfree>
    80003eda:	b7ed                	j	80003ec4 <itrunc+0x74>
    brelse(bp);
    80003edc:	8552                	mv	a0,s4
    80003ede:	fffff097          	auipc	ra,0xfffff
    80003ee2:	790080e7          	jalr	1936(ra) # 8000366e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ee6:	0809a583          	lw	a1,128(s3)
    80003eea:	0009a503          	lw	a0,0(s3)
    80003eee:	00000097          	auipc	ra,0x0
    80003ef2:	896080e7          	jalr	-1898(ra) # 80003784 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ef6:	0809a023          	sw	zero,128(s3)
    80003efa:	bf51                	j	80003e8e <itrunc+0x3e>

0000000080003efc <iput>:
{
    80003efc:	1101                	addi	sp,sp,-32
    80003efe:	ec06                	sd	ra,24(sp)
    80003f00:	e822                	sd	s0,16(sp)
    80003f02:	e426                	sd	s1,8(sp)
    80003f04:	e04a                	sd	s2,0(sp)
    80003f06:	1000                	addi	s0,sp,32
    80003f08:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f0a:	0001c517          	auipc	a0,0x1c
    80003f0e:	2be50513          	addi	a0,a0,702 # 800201c8 <itable>
    80003f12:	ffffd097          	auipc	ra,0xffffd
    80003f16:	cb0080e7          	jalr	-848(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f1a:	4498                	lw	a4,8(s1)
    80003f1c:	4785                	li	a5,1
    80003f1e:	02f70363          	beq	a4,a5,80003f44 <iput+0x48>
  ip->ref--;
    80003f22:	449c                	lw	a5,8(s1)
    80003f24:	37fd                	addiw	a5,a5,-1
    80003f26:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f28:	0001c517          	auipc	a0,0x1c
    80003f2c:	2a050513          	addi	a0,a0,672 # 800201c8 <itable>
    80003f30:	ffffd097          	auipc	ra,0xffffd
    80003f34:	d46080e7          	jalr	-698(ra) # 80000c76 <release>
}
    80003f38:	60e2                	ld	ra,24(sp)
    80003f3a:	6442                	ld	s0,16(sp)
    80003f3c:	64a2                	ld	s1,8(sp)
    80003f3e:	6902                	ld	s2,0(sp)
    80003f40:	6105                	addi	sp,sp,32
    80003f42:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f44:	40bc                	lw	a5,64(s1)
    80003f46:	dff1                	beqz	a5,80003f22 <iput+0x26>
    80003f48:	04a49783          	lh	a5,74(s1)
    80003f4c:	fbf9                	bnez	a5,80003f22 <iput+0x26>
    acquiresleep(&ip->lock);
    80003f4e:	01048913          	addi	s2,s1,16
    80003f52:	854a                	mv	a0,s2
    80003f54:	00001097          	auipc	ra,0x1
    80003f58:	abc080e7          	jalr	-1348(ra) # 80004a10 <acquiresleep>
    release(&itable.lock);
    80003f5c:	0001c517          	auipc	a0,0x1c
    80003f60:	26c50513          	addi	a0,a0,620 # 800201c8 <itable>
    80003f64:	ffffd097          	auipc	ra,0xffffd
    80003f68:	d12080e7          	jalr	-750(ra) # 80000c76 <release>
    itrunc(ip);
    80003f6c:	8526                	mv	a0,s1
    80003f6e:	00000097          	auipc	ra,0x0
    80003f72:	ee2080e7          	jalr	-286(ra) # 80003e50 <itrunc>
    ip->type = 0;
    80003f76:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003f7a:	8526                	mv	a0,s1
    80003f7c:	00000097          	auipc	ra,0x0
    80003f80:	cfc080e7          	jalr	-772(ra) # 80003c78 <iupdate>
    ip->valid = 0;
    80003f84:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003f88:	854a                	mv	a0,s2
    80003f8a:	00001097          	auipc	ra,0x1
    80003f8e:	adc080e7          	jalr	-1316(ra) # 80004a66 <releasesleep>
    acquire(&itable.lock);
    80003f92:	0001c517          	auipc	a0,0x1c
    80003f96:	23650513          	addi	a0,a0,566 # 800201c8 <itable>
    80003f9a:	ffffd097          	auipc	ra,0xffffd
    80003f9e:	c28080e7          	jalr	-984(ra) # 80000bc2 <acquire>
    80003fa2:	b741                	j	80003f22 <iput+0x26>

0000000080003fa4 <iunlockput>:
{
    80003fa4:	1101                	addi	sp,sp,-32
    80003fa6:	ec06                	sd	ra,24(sp)
    80003fa8:	e822                	sd	s0,16(sp)
    80003faa:	e426                	sd	s1,8(sp)
    80003fac:	1000                	addi	s0,sp,32
    80003fae:	84aa                	mv	s1,a0
  iunlock(ip);
    80003fb0:	00000097          	auipc	ra,0x0
    80003fb4:	e54080e7          	jalr	-428(ra) # 80003e04 <iunlock>
  iput(ip);
    80003fb8:	8526                	mv	a0,s1
    80003fba:	00000097          	auipc	ra,0x0
    80003fbe:	f42080e7          	jalr	-190(ra) # 80003efc <iput>
}
    80003fc2:	60e2                	ld	ra,24(sp)
    80003fc4:	6442                	ld	s0,16(sp)
    80003fc6:	64a2                	ld	s1,8(sp)
    80003fc8:	6105                	addi	sp,sp,32
    80003fca:	8082                	ret

0000000080003fcc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003fcc:	1141                	addi	sp,sp,-16
    80003fce:	e422                	sd	s0,8(sp)
    80003fd0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003fd2:	411c                	lw	a5,0(a0)
    80003fd4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003fd6:	415c                	lw	a5,4(a0)
    80003fd8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003fda:	04451783          	lh	a5,68(a0)
    80003fde:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003fe2:	04a51783          	lh	a5,74(a0)
    80003fe6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003fea:	04c56783          	lwu	a5,76(a0)
    80003fee:	e99c                	sd	a5,16(a1)
}
    80003ff0:	6422                	ld	s0,8(sp)
    80003ff2:	0141                	addi	sp,sp,16
    80003ff4:	8082                	ret

0000000080003ff6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ff6:	457c                	lw	a5,76(a0)
    80003ff8:	0ed7e963          	bltu	a5,a3,800040ea <readi+0xf4>
{
    80003ffc:	7159                	addi	sp,sp,-112
    80003ffe:	f486                	sd	ra,104(sp)
    80004000:	f0a2                	sd	s0,96(sp)
    80004002:	eca6                	sd	s1,88(sp)
    80004004:	e8ca                	sd	s2,80(sp)
    80004006:	e4ce                	sd	s3,72(sp)
    80004008:	e0d2                	sd	s4,64(sp)
    8000400a:	fc56                	sd	s5,56(sp)
    8000400c:	f85a                	sd	s6,48(sp)
    8000400e:	f45e                	sd	s7,40(sp)
    80004010:	f062                	sd	s8,32(sp)
    80004012:	ec66                	sd	s9,24(sp)
    80004014:	e86a                	sd	s10,16(sp)
    80004016:	e46e                	sd	s11,8(sp)
    80004018:	1880                	addi	s0,sp,112
    8000401a:	8baa                	mv	s7,a0
    8000401c:	8c2e                	mv	s8,a1
    8000401e:	8ab2                	mv	s5,a2
    80004020:	84b6                	mv	s1,a3
    80004022:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004024:	9f35                	addw	a4,a4,a3
    return 0;
    80004026:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004028:	0ad76063          	bltu	a4,a3,800040c8 <readi+0xd2>
  if(off + n > ip->size)
    8000402c:	00e7f463          	bgeu	a5,a4,80004034 <readi+0x3e>
    n = ip->size - off;
    80004030:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004034:	0a0b0963          	beqz	s6,800040e6 <readi+0xf0>
    80004038:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000403a:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000403e:	5cfd                	li	s9,-1
    80004040:	a82d                	j	8000407a <readi+0x84>
    80004042:	020a1d93          	slli	s11,s4,0x20
    80004046:	020ddd93          	srli	s11,s11,0x20
    8000404a:	05890793          	addi	a5,s2,88
    8000404e:	86ee                	mv	a3,s11
    80004050:	963e                	add	a2,a2,a5
    80004052:	85d6                	mv	a1,s5
    80004054:	8562                	mv	a0,s8
    80004056:	ffffe097          	auipc	ra,0xffffe
    8000405a:	6b6080e7          	jalr	1718(ra) # 8000270c <either_copyout>
    8000405e:	05950d63          	beq	a0,s9,800040b8 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004062:	854a                	mv	a0,s2
    80004064:	fffff097          	auipc	ra,0xfffff
    80004068:	60a080e7          	jalr	1546(ra) # 8000366e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000406c:	013a09bb          	addw	s3,s4,s3
    80004070:	009a04bb          	addw	s1,s4,s1
    80004074:	9aee                	add	s5,s5,s11
    80004076:	0569f763          	bgeu	s3,s6,800040c4 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000407a:	000ba903          	lw	s2,0(s7)
    8000407e:	00a4d59b          	srliw	a1,s1,0xa
    80004082:	855e                	mv	a0,s7
    80004084:	00000097          	auipc	ra,0x0
    80004088:	8ae080e7          	jalr	-1874(ra) # 80003932 <bmap>
    8000408c:	0005059b          	sext.w	a1,a0
    80004090:	854a                	mv	a0,s2
    80004092:	fffff097          	auipc	ra,0xfffff
    80004096:	4ac080e7          	jalr	1196(ra) # 8000353e <bread>
    8000409a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000409c:	3ff4f613          	andi	a2,s1,1023
    800040a0:	40cd07bb          	subw	a5,s10,a2
    800040a4:	413b073b          	subw	a4,s6,s3
    800040a8:	8a3e                	mv	s4,a5
    800040aa:	2781                	sext.w	a5,a5
    800040ac:	0007069b          	sext.w	a3,a4
    800040b0:	f8f6f9e3          	bgeu	a3,a5,80004042 <readi+0x4c>
    800040b4:	8a3a                	mv	s4,a4
    800040b6:	b771                	j	80004042 <readi+0x4c>
      brelse(bp);
    800040b8:	854a                	mv	a0,s2
    800040ba:	fffff097          	auipc	ra,0xfffff
    800040be:	5b4080e7          	jalr	1460(ra) # 8000366e <brelse>
      tot = -1;
    800040c2:	59fd                	li	s3,-1
  }
  return tot;
    800040c4:	0009851b          	sext.w	a0,s3
}
    800040c8:	70a6                	ld	ra,104(sp)
    800040ca:	7406                	ld	s0,96(sp)
    800040cc:	64e6                	ld	s1,88(sp)
    800040ce:	6946                	ld	s2,80(sp)
    800040d0:	69a6                	ld	s3,72(sp)
    800040d2:	6a06                	ld	s4,64(sp)
    800040d4:	7ae2                	ld	s5,56(sp)
    800040d6:	7b42                	ld	s6,48(sp)
    800040d8:	7ba2                	ld	s7,40(sp)
    800040da:	7c02                	ld	s8,32(sp)
    800040dc:	6ce2                	ld	s9,24(sp)
    800040de:	6d42                	ld	s10,16(sp)
    800040e0:	6da2                	ld	s11,8(sp)
    800040e2:	6165                	addi	sp,sp,112
    800040e4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040e6:	89da                	mv	s3,s6
    800040e8:	bff1                	j	800040c4 <readi+0xce>
    return 0;
    800040ea:	4501                	li	a0,0
}
    800040ec:	8082                	ret

00000000800040ee <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800040ee:	457c                	lw	a5,76(a0)
    800040f0:	10d7e863          	bltu	a5,a3,80004200 <writei+0x112>
{
    800040f4:	7159                	addi	sp,sp,-112
    800040f6:	f486                	sd	ra,104(sp)
    800040f8:	f0a2                	sd	s0,96(sp)
    800040fa:	eca6                	sd	s1,88(sp)
    800040fc:	e8ca                	sd	s2,80(sp)
    800040fe:	e4ce                	sd	s3,72(sp)
    80004100:	e0d2                	sd	s4,64(sp)
    80004102:	fc56                	sd	s5,56(sp)
    80004104:	f85a                	sd	s6,48(sp)
    80004106:	f45e                	sd	s7,40(sp)
    80004108:	f062                	sd	s8,32(sp)
    8000410a:	ec66                	sd	s9,24(sp)
    8000410c:	e86a                	sd	s10,16(sp)
    8000410e:	e46e                	sd	s11,8(sp)
    80004110:	1880                	addi	s0,sp,112
    80004112:	8b2a                	mv	s6,a0
    80004114:	8c2e                	mv	s8,a1
    80004116:	8ab2                	mv	s5,a2
    80004118:	8936                	mv	s2,a3
    8000411a:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    8000411c:	00e687bb          	addw	a5,a3,a4
    80004120:	0ed7e263          	bltu	a5,a3,80004204 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004124:	00043737          	lui	a4,0x43
    80004128:	0ef76063          	bltu	a4,a5,80004208 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000412c:	0c0b8863          	beqz	s7,800041fc <writei+0x10e>
    80004130:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004132:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004136:	5cfd                	li	s9,-1
    80004138:	a091                	j	8000417c <writei+0x8e>
    8000413a:	02099d93          	slli	s11,s3,0x20
    8000413e:	020ddd93          	srli	s11,s11,0x20
    80004142:	05848793          	addi	a5,s1,88
    80004146:	86ee                	mv	a3,s11
    80004148:	8656                	mv	a2,s5
    8000414a:	85e2                	mv	a1,s8
    8000414c:	953e                	add	a0,a0,a5
    8000414e:	ffffe097          	auipc	ra,0xffffe
    80004152:	614080e7          	jalr	1556(ra) # 80002762 <either_copyin>
    80004156:	07950263          	beq	a0,s9,800041ba <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000415a:	8526                	mv	a0,s1
    8000415c:	00000097          	auipc	ra,0x0
    80004160:	794080e7          	jalr	1940(ra) # 800048f0 <log_write>
    brelse(bp);
    80004164:	8526                	mv	a0,s1
    80004166:	fffff097          	auipc	ra,0xfffff
    8000416a:	508080e7          	jalr	1288(ra) # 8000366e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000416e:	01498a3b          	addw	s4,s3,s4
    80004172:	0129893b          	addw	s2,s3,s2
    80004176:	9aee                	add	s5,s5,s11
    80004178:	057a7663          	bgeu	s4,s7,800041c4 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000417c:	000b2483          	lw	s1,0(s6)
    80004180:	00a9559b          	srliw	a1,s2,0xa
    80004184:	855a                	mv	a0,s6
    80004186:	fffff097          	auipc	ra,0xfffff
    8000418a:	7ac080e7          	jalr	1964(ra) # 80003932 <bmap>
    8000418e:	0005059b          	sext.w	a1,a0
    80004192:	8526                	mv	a0,s1
    80004194:	fffff097          	auipc	ra,0xfffff
    80004198:	3aa080e7          	jalr	938(ra) # 8000353e <bread>
    8000419c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000419e:	3ff97513          	andi	a0,s2,1023
    800041a2:	40ad07bb          	subw	a5,s10,a0
    800041a6:	414b873b          	subw	a4,s7,s4
    800041aa:	89be                	mv	s3,a5
    800041ac:	2781                	sext.w	a5,a5
    800041ae:	0007069b          	sext.w	a3,a4
    800041b2:	f8f6f4e3          	bgeu	a3,a5,8000413a <writei+0x4c>
    800041b6:	89ba                	mv	s3,a4
    800041b8:	b749                	j	8000413a <writei+0x4c>
      brelse(bp);
    800041ba:	8526                	mv	a0,s1
    800041bc:	fffff097          	auipc	ra,0xfffff
    800041c0:	4b2080e7          	jalr	1202(ra) # 8000366e <brelse>
  }

  if(off > ip->size)
    800041c4:	04cb2783          	lw	a5,76(s6)
    800041c8:	0127f463          	bgeu	a5,s2,800041d0 <writei+0xe2>
    ip->size = off;
    800041cc:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800041d0:	855a                	mv	a0,s6
    800041d2:	00000097          	auipc	ra,0x0
    800041d6:	aa6080e7          	jalr	-1370(ra) # 80003c78 <iupdate>

  return tot;
    800041da:	000a051b          	sext.w	a0,s4
}
    800041de:	70a6                	ld	ra,104(sp)
    800041e0:	7406                	ld	s0,96(sp)
    800041e2:	64e6                	ld	s1,88(sp)
    800041e4:	6946                	ld	s2,80(sp)
    800041e6:	69a6                	ld	s3,72(sp)
    800041e8:	6a06                	ld	s4,64(sp)
    800041ea:	7ae2                	ld	s5,56(sp)
    800041ec:	7b42                	ld	s6,48(sp)
    800041ee:	7ba2                	ld	s7,40(sp)
    800041f0:	7c02                	ld	s8,32(sp)
    800041f2:	6ce2                	ld	s9,24(sp)
    800041f4:	6d42                	ld	s10,16(sp)
    800041f6:	6da2                	ld	s11,8(sp)
    800041f8:	6165                	addi	sp,sp,112
    800041fa:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041fc:	8a5e                	mv	s4,s7
    800041fe:	bfc9                	j	800041d0 <writei+0xe2>
    return -1;
    80004200:	557d                	li	a0,-1
}
    80004202:	8082                	ret
    return -1;
    80004204:	557d                	li	a0,-1
    80004206:	bfe1                	j	800041de <writei+0xf0>
    return -1;
    80004208:	557d                	li	a0,-1
    8000420a:	bfd1                	j	800041de <writei+0xf0>

000000008000420c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000420c:	1141                	addi	sp,sp,-16
    8000420e:	e406                	sd	ra,8(sp)
    80004210:	e022                	sd	s0,0(sp)
    80004212:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004214:	4639                	li	a2,14
    80004216:	ffffd097          	auipc	ra,0xffffd
    8000421a:	b80080e7          	jalr	-1152(ra) # 80000d96 <strncmp>
}
    8000421e:	60a2                	ld	ra,8(sp)
    80004220:	6402                	ld	s0,0(sp)
    80004222:	0141                	addi	sp,sp,16
    80004224:	8082                	ret

0000000080004226 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004226:	7139                	addi	sp,sp,-64
    80004228:	fc06                	sd	ra,56(sp)
    8000422a:	f822                	sd	s0,48(sp)
    8000422c:	f426                	sd	s1,40(sp)
    8000422e:	f04a                	sd	s2,32(sp)
    80004230:	ec4e                	sd	s3,24(sp)
    80004232:	e852                	sd	s4,16(sp)
    80004234:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004236:	04451703          	lh	a4,68(a0)
    8000423a:	4785                	li	a5,1
    8000423c:	00f71a63          	bne	a4,a5,80004250 <dirlookup+0x2a>
    80004240:	892a                	mv	s2,a0
    80004242:	89ae                	mv	s3,a1
    80004244:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004246:	457c                	lw	a5,76(a0)
    80004248:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000424a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000424c:	e79d                	bnez	a5,8000427a <dirlookup+0x54>
    8000424e:	a8a5                	j	800042c6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004250:	00004517          	auipc	a0,0x4
    80004254:	6a050513          	addi	a0,a0,1696 # 800088f0 <syscalls+0x1b8>
    80004258:	ffffc097          	auipc	ra,0xffffc
    8000425c:	2d2080e7          	jalr	722(ra) # 8000052a <panic>
      panic("dirlookup read");
    80004260:	00004517          	auipc	a0,0x4
    80004264:	6a850513          	addi	a0,a0,1704 # 80008908 <syscalls+0x1d0>
    80004268:	ffffc097          	auipc	ra,0xffffc
    8000426c:	2c2080e7          	jalr	706(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004270:	24c1                	addiw	s1,s1,16
    80004272:	04c92783          	lw	a5,76(s2)
    80004276:	04f4f763          	bgeu	s1,a5,800042c4 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000427a:	4741                	li	a4,16
    8000427c:	86a6                	mv	a3,s1
    8000427e:	fc040613          	addi	a2,s0,-64
    80004282:	4581                	li	a1,0
    80004284:	854a                	mv	a0,s2
    80004286:	00000097          	auipc	ra,0x0
    8000428a:	d70080e7          	jalr	-656(ra) # 80003ff6 <readi>
    8000428e:	47c1                	li	a5,16
    80004290:	fcf518e3          	bne	a0,a5,80004260 <dirlookup+0x3a>
    if(de.inum == 0)
    80004294:	fc045783          	lhu	a5,-64(s0)
    80004298:	dfe1                	beqz	a5,80004270 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000429a:	fc240593          	addi	a1,s0,-62
    8000429e:	854e                	mv	a0,s3
    800042a0:	00000097          	auipc	ra,0x0
    800042a4:	f6c080e7          	jalr	-148(ra) # 8000420c <namecmp>
    800042a8:	f561                	bnez	a0,80004270 <dirlookup+0x4a>
      if(poff)
    800042aa:	000a0463          	beqz	s4,800042b2 <dirlookup+0x8c>
        *poff = off;
    800042ae:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800042b2:	fc045583          	lhu	a1,-64(s0)
    800042b6:	00092503          	lw	a0,0(s2)
    800042ba:	fffff097          	auipc	ra,0xfffff
    800042be:	754080e7          	jalr	1876(ra) # 80003a0e <iget>
    800042c2:	a011                	j	800042c6 <dirlookup+0xa0>
  return 0;
    800042c4:	4501                	li	a0,0
}
    800042c6:	70e2                	ld	ra,56(sp)
    800042c8:	7442                	ld	s0,48(sp)
    800042ca:	74a2                	ld	s1,40(sp)
    800042cc:	7902                	ld	s2,32(sp)
    800042ce:	69e2                	ld	s3,24(sp)
    800042d0:	6a42                	ld	s4,16(sp)
    800042d2:	6121                	addi	sp,sp,64
    800042d4:	8082                	ret

00000000800042d6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800042d6:	711d                	addi	sp,sp,-96
    800042d8:	ec86                	sd	ra,88(sp)
    800042da:	e8a2                	sd	s0,80(sp)
    800042dc:	e4a6                	sd	s1,72(sp)
    800042de:	e0ca                	sd	s2,64(sp)
    800042e0:	fc4e                	sd	s3,56(sp)
    800042e2:	f852                	sd	s4,48(sp)
    800042e4:	f456                	sd	s5,40(sp)
    800042e6:	f05a                	sd	s6,32(sp)
    800042e8:	ec5e                	sd	s7,24(sp)
    800042ea:	e862                	sd	s8,16(sp)
    800042ec:	e466                	sd	s9,8(sp)
    800042ee:	1080                	addi	s0,sp,96
    800042f0:	84aa                	mv	s1,a0
    800042f2:	8aae                	mv	s5,a1
    800042f4:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800042f6:	00054703          	lbu	a4,0(a0)
    800042fa:	02f00793          	li	a5,47
    800042fe:	02f70363          	beq	a4,a5,80004324 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004302:	ffffd097          	auipc	ra,0xffffd
    80004306:	6c4080e7          	jalr	1732(ra) # 800019c6 <myproc>
    8000430a:	17853503          	ld	a0,376(a0)
    8000430e:	00000097          	auipc	ra,0x0
    80004312:	9f6080e7          	jalr	-1546(ra) # 80003d04 <idup>
    80004316:	89aa                	mv	s3,a0
  while(*path == '/')
    80004318:	02f00913          	li	s2,47
  len = path - s;
    8000431c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    8000431e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004320:	4b85                	li	s7,1
    80004322:	a865                	j	800043da <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004324:	4585                	li	a1,1
    80004326:	4505                	li	a0,1
    80004328:	fffff097          	auipc	ra,0xfffff
    8000432c:	6e6080e7          	jalr	1766(ra) # 80003a0e <iget>
    80004330:	89aa                	mv	s3,a0
    80004332:	b7dd                	j	80004318 <namex+0x42>
      iunlockput(ip);
    80004334:	854e                	mv	a0,s3
    80004336:	00000097          	auipc	ra,0x0
    8000433a:	c6e080e7          	jalr	-914(ra) # 80003fa4 <iunlockput>
      return 0;
    8000433e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004340:	854e                	mv	a0,s3
    80004342:	60e6                	ld	ra,88(sp)
    80004344:	6446                	ld	s0,80(sp)
    80004346:	64a6                	ld	s1,72(sp)
    80004348:	6906                	ld	s2,64(sp)
    8000434a:	79e2                	ld	s3,56(sp)
    8000434c:	7a42                	ld	s4,48(sp)
    8000434e:	7aa2                	ld	s5,40(sp)
    80004350:	7b02                	ld	s6,32(sp)
    80004352:	6be2                	ld	s7,24(sp)
    80004354:	6c42                	ld	s8,16(sp)
    80004356:	6ca2                	ld	s9,8(sp)
    80004358:	6125                	addi	sp,sp,96
    8000435a:	8082                	ret
      iunlock(ip);
    8000435c:	854e                	mv	a0,s3
    8000435e:	00000097          	auipc	ra,0x0
    80004362:	aa6080e7          	jalr	-1370(ra) # 80003e04 <iunlock>
      return ip;
    80004366:	bfe9                	j	80004340 <namex+0x6a>
      iunlockput(ip);
    80004368:	854e                	mv	a0,s3
    8000436a:	00000097          	auipc	ra,0x0
    8000436e:	c3a080e7          	jalr	-966(ra) # 80003fa4 <iunlockput>
      return 0;
    80004372:	89e6                	mv	s3,s9
    80004374:	b7f1                	j	80004340 <namex+0x6a>
  len = path - s;
    80004376:	40b48633          	sub	a2,s1,a1
    8000437a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000437e:	099c5463          	bge	s8,s9,80004406 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004382:	4639                	li	a2,14
    80004384:	8552                	mv	a0,s4
    80004386:	ffffd097          	auipc	ra,0xffffd
    8000438a:	994080e7          	jalr	-1644(ra) # 80000d1a <memmove>
  while(*path == '/')
    8000438e:	0004c783          	lbu	a5,0(s1)
    80004392:	01279763          	bne	a5,s2,800043a0 <namex+0xca>
    path++;
    80004396:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004398:	0004c783          	lbu	a5,0(s1)
    8000439c:	ff278de3          	beq	a5,s2,80004396 <namex+0xc0>
    ilock(ip);
    800043a0:	854e                	mv	a0,s3
    800043a2:	00000097          	auipc	ra,0x0
    800043a6:	9a0080e7          	jalr	-1632(ra) # 80003d42 <ilock>
    if(ip->type != T_DIR){
    800043aa:	04499783          	lh	a5,68(s3)
    800043ae:	f97793e3          	bne	a5,s7,80004334 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800043b2:	000a8563          	beqz	s5,800043bc <namex+0xe6>
    800043b6:	0004c783          	lbu	a5,0(s1)
    800043ba:	d3cd                	beqz	a5,8000435c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800043bc:	865a                	mv	a2,s6
    800043be:	85d2                	mv	a1,s4
    800043c0:	854e                	mv	a0,s3
    800043c2:	00000097          	auipc	ra,0x0
    800043c6:	e64080e7          	jalr	-412(ra) # 80004226 <dirlookup>
    800043ca:	8caa                	mv	s9,a0
    800043cc:	dd51                	beqz	a0,80004368 <namex+0x92>
    iunlockput(ip);
    800043ce:	854e                	mv	a0,s3
    800043d0:	00000097          	auipc	ra,0x0
    800043d4:	bd4080e7          	jalr	-1068(ra) # 80003fa4 <iunlockput>
    ip = next;
    800043d8:	89e6                	mv	s3,s9
  while(*path == '/')
    800043da:	0004c783          	lbu	a5,0(s1)
    800043de:	05279763          	bne	a5,s2,8000442c <namex+0x156>
    path++;
    800043e2:	0485                	addi	s1,s1,1
  while(*path == '/')
    800043e4:	0004c783          	lbu	a5,0(s1)
    800043e8:	ff278de3          	beq	a5,s2,800043e2 <namex+0x10c>
  if(*path == 0)
    800043ec:	c79d                	beqz	a5,8000441a <namex+0x144>
    path++;
    800043ee:	85a6                	mv	a1,s1
  len = path - s;
    800043f0:	8cda                	mv	s9,s6
    800043f2:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800043f4:	01278963          	beq	a5,s2,80004406 <namex+0x130>
    800043f8:	dfbd                	beqz	a5,80004376 <namex+0xa0>
    path++;
    800043fa:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800043fc:	0004c783          	lbu	a5,0(s1)
    80004400:	ff279ce3          	bne	a5,s2,800043f8 <namex+0x122>
    80004404:	bf8d                	j	80004376 <namex+0xa0>
    memmove(name, s, len);
    80004406:	2601                	sext.w	a2,a2
    80004408:	8552                	mv	a0,s4
    8000440a:	ffffd097          	auipc	ra,0xffffd
    8000440e:	910080e7          	jalr	-1776(ra) # 80000d1a <memmove>
    name[len] = 0;
    80004412:	9cd2                	add	s9,s9,s4
    80004414:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004418:	bf9d                	j	8000438e <namex+0xb8>
  if(nameiparent){
    8000441a:	f20a83e3          	beqz	s5,80004340 <namex+0x6a>
    iput(ip);
    8000441e:	854e                	mv	a0,s3
    80004420:	00000097          	auipc	ra,0x0
    80004424:	adc080e7          	jalr	-1316(ra) # 80003efc <iput>
    return 0;
    80004428:	4981                	li	s3,0
    8000442a:	bf19                	j	80004340 <namex+0x6a>
  if(*path == 0)
    8000442c:	d7fd                	beqz	a5,8000441a <namex+0x144>
  while(*path != '/' && *path != 0)
    8000442e:	0004c783          	lbu	a5,0(s1)
    80004432:	85a6                	mv	a1,s1
    80004434:	b7d1                	j	800043f8 <namex+0x122>

0000000080004436 <dirlink>:
{
    80004436:	7139                	addi	sp,sp,-64
    80004438:	fc06                	sd	ra,56(sp)
    8000443a:	f822                	sd	s0,48(sp)
    8000443c:	f426                	sd	s1,40(sp)
    8000443e:	f04a                	sd	s2,32(sp)
    80004440:	ec4e                	sd	s3,24(sp)
    80004442:	e852                	sd	s4,16(sp)
    80004444:	0080                	addi	s0,sp,64
    80004446:	892a                	mv	s2,a0
    80004448:	8a2e                	mv	s4,a1
    8000444a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000444c:	4601                	li	a2,0
    8000444e:	00000097          	auipc	ra,0x0
    80004452:	dd8080e7          	jalr	-552(ra) # 80004226 <dirlookup>
    80004456:	e93d                	bnez	a0,800044cc <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004458:	04c92483          	lw	s1,76(s2)
    8000445c:	c49d                	beqz	s1,8000448a <dirlink+0x54>
    8000445e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004460:	4741                	li	a4,16
    80004462:	86a6                	mv	a3,s1
    80004464:	fc040613          	addi	a2,s0,-64
    80004468:	4581                	li	a1,0
    8000446a:	854a                	mv	a0,s2
    8000446c:	00000097          	auipc	ra,0x0
    80004470:	b8a080e7          	jalr	-1142(ra) # 80003ff6 <readi>
    80004474:	47c1                	li	a5,16
    80004476:	06f51163          	bne	a0,a5,800044d8 <dirlink+0xa2>
    if(de.inum == 0)
    8000447a:	fc045783          	lhu	a5,-64(s0)
    8000447e:	c791                	beqz	a5,8000448a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004480:	24c1                	addiw	s1,s1,16
    80004482:	04c92783          	lw	a5,76(s2)
    80004486:	fcf4ede3          	bltu	s1,a5,80004460 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000448a:	4639                	li	a2,14
    8000448c:	85d2                	mv	a1,s4
    8000448e:	fc240513          	addi	a0,s0,-62
    80004492:	ffffd097          	auipc	ra,0xffffd
    80004496:	940080e7          	jalr	-1728(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    8000449a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000449e:	4741                	li	a4,16
    800044a0:	86a6                	mv	a3,s1
    800044a2:	fc040613          	addi	a2,s0,-64
    800044a6:	4581                	li	a1,0
    800044a8:	854a                	mv	a0,s2
    800044aa:	00000097          	auipc	ra,0x0
    800044ae:	c44080e7          	jalr	-956(ra) # 800040ee <writei>
    800044b2:	872a                	mv	a4,a0
    800044b4:	47c1                	li	a5,16
  return 0;
    800044b6:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044b8:	02f71863          	bne	a4,a5,800044e8 <dirlink+0xb2>
}
    800044bc:	70e2                	ld	ra,56(sp)
    800044be:	7442                	ld	s0,48(sp)
    800044c0:	74a2                	ld	s1,40(sp)
    800044c2:	7902                	ld	s2,32(sp)
    800044c4:	69e2                	ld	s3,24(sp)
    800044c6:	6a42                	ld	s4,16(sp)
    800044c8:	6121                	addi	sp,sp,64
    800044ca:	8082                	ret
    iput(ip);
    800044cc:	00000097          	auipc	ra,0x0
    800044d0:	a30080e7          	jalr	-1488(ra) # 80003efc <iput>
    return -1;
    800044d4:	557d                	li	a0,-1
    800044d6:	b7dd                	j	800044bc <dirlink+0x86>
      panic("dirlink read");
    800044d8:	00004517          	auipc	a0,0x4
    800044dc:	44050513          	addi	a0,a0,1088 # 80008918 <syscalls+0x1e0>
    800044e0:	ffffc097          	auipc	ra,0xffffc
    800044e4:	04a080e7          	jalr	74(ra) # 8000052a <panic>
    panic("dirlink");
    800044e8:	00004517          	auipc	a0,0x4
    800044ec:	53850513          	addi	a0,a0,1336 # 80008a20 <syscalls+0x2e8>
    800044f0:	ffffc097          	auipc	ra,0xffffc
    800044f4:	03a080e7          	jalr	58(ra) # 8000052a <panic>

00000000800044f8 <namei>:

struct inode*
namei(char *path)
{
    800044f8:	1101                	addi	sp,sp,-32
    800044fa:	ec06                	sd	ra,24(sp)
    800044fc:	e822                	sd	s0,16(sp)
    800044fe:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004500:	fe040613          	addi	a2,s0,-32
    80004504:	4581                	li	a1,0
    80004506:	00000097          	auipc	ra,0x0
    8000450a:	dd0080e7          	jalr	-560(ra) # 800042d6 <namex>
}
    8000450e:	60e2                	ld	ra,24(sp)
    80004510:	6442                	ld	s0,16(sp)
    80004512:	6105                	addi	sp,sp,32
    80004514:	8082                	ret

0000000080004516 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004516:	1141                	addi	sp,sp,-16
    80004518:	e406                	sd	ra,8(sp)
    8000451a:	e022                	sd	s0,0(sp)
    8000451c:	0800                	addi	s0,sp,16
    8000451e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004520:	4585                	li	a1,1
    80004522:	00000097          	auipc	ra,0x0
    80004526:	db4080e7          	jalr	-588(ra) # 800042d6 <namex>
}
    8000452a:	60a2                	ld	ra,8(sp)
    8000452c:	6402                	ld	s0,0(sp)
    8000452e:	0141                	addi	sp,sp,16
    80004530:	8082                	ret

0000000080004532 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004532:	1101                	addi	sp,sp,-32
    80004534:	ec06                	sd	ra,24(sp)
    80004536:	e822                	sd	s0,16(sp)
    80004538:	e426                	sd	s1,8(sp)
    8000453a:	e04a                	sd	s2,0(sp)
    8000453c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000453e:	0001d917          	auipc	s2,0x1d
    80004542:	73290913          	addi	s2,s2,1842 # 80021c70 <log>
    80004546:	01892583          	lw	a1,24(s2)
    8000454a:	02892503          	lw	a0,40(s2)
    8000454e:	fffff097          	auipc	ra,0xfffff
    80004552:	ff0080e7          	jalr	-16(ra) # 8000353e <bread>
    80004556:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004558:	02c92683          	lw	a3,44(s2)
    8000455c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000455e:	02d05863          	blez	a3,8000458e <write_head+0x5c>
    80004562:	0001d797          	auipc	a5,0x1d
    80004566:	73e78793          	addi	a5,a5,1854 # 80021ca0 <log+0x30>
    8000456a:	05c50713          	addi	a4,a0,92
    8000456e:	36fd                	addiw	a3,a3,-1
    80004570:	02069613          	slli	a2,a3,0x20
    80004574:	01e65693          	srli	a3,a2,0x1e
    80004578:	0001d617          	auipc	a2,0x1d
    8000457c:	72c60613          	addi	a2,a2,1836 # 80021ca4 <log+0x34>
    80004580:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004582:	4390                	lw	a2,0(a5)
    80004584:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004586:	0791                	addi	a5,a5,4
    80004588:	0711                	addi	a4,a4,4
    8000458a:	fed79ce3          	bne	a5,a3,80004582 <write_head+0x50>
  }
  bwrite(buf);
    8000458e:	8526                	mv	a0,s1
    80004590:	fffff097          	auipc	ra,0xfffff
    80004594:	0a0080e7          	jalr	160(ra) # 80003630 <bwrite>
  brelse(buf);
    80004598:	8526                	mv	a0,s1
    8000459a:	fffff097          	auipc	ra,0xfffff
    8000459e:	0d4080e7          	jalr	212(ra) # 8000366e <brelse>
}
    800045a2:	60e2                	ld	ra,24(sp)
    800045a4:	6442                	ld	s0,16(sp)
    800045a6:	64a2                	ld	s1,8(sp)
    800045a8:	6902                	ld	s2,0(sp)
    800045aa:	6105                	addi	sp,sp,32
    800045ac:	8082                	ret

00000000800045ae <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800045ae:	0001d797          	auipc	a5,0x1d
    800045b2:	6ee7a783          	lw	a5,1774(a5) # 80021c9c <log+0x2c>
    800045b6:	0af05d63          	blez	a5,80004670 <install_trans+0xc2>
{
    800045ba:	7139                	addi	sp,sp,-64
    800045bc:	fc06                	sd	ra,56(sp)
    800045be:	f822                	sd	s0,48(sp)
    800045c0:	f426                	sd	s1,40(sp)
    800045c2:	f04a                	sd	s2,32(sp)
    800045c4:	ec4e                	sd	s3,24(sp)
    800045c6:	e852                	sd	s4,16(sp)
    800045c8:	e456                	sd	s5,8(sp)
    800045ca:	e05a                	sd	s6,0(sp)
    800045cc:	0080                	addi	s0,sp,64
    800045ce:	8b2a                	mv	s6,a0
    800045d0:	0001da97          	auipc	s5,0x1d
    800045d4:	6d0a8a93          	addi	s5,s5,1744 # 80021ca0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045d8:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800045da:	0001d997          	auipc	s3,0x1d
    800045de:	69698993          	addi	s3,s3,1686 # 80021c70 <log>
    800045e2:	a00d                	j	80004604 <install_trans+0x56>
    brelse(lbuf);
    800045e4:	854a                	mv	a0,s2
    800045e6:	fffff097          	auipc	ra,0xfffff
    800045ea:	088080e7          	jalr	136(ra) # 8000366e <brelse>
    brelse(dbuf);
    800045ee:	8526                	mv	a0,s1
    800045f0:	fffff097          	auipc	ra,0xfffff
    800045f4:	07e080e7          	jalr	126(ra) # 8000366e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045f8:	2a05                	addiw	s4,s4,1
    800045fa:	0a91                	addi	s5,s5,4
    800045fc:	02c9a783          	lw	a5,44(s3)
    80004600:	04fa5e63          	bge	s4,a5,8000465c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004604:	0189a583          	lw	a1,24(s3)
    80004608:	014585bb          	addw	a1,a1,s4
    8000460c:	2585                	addiw	a1,a1,1
    8000460e:	0289a503          	lw	a0,40(s3)
    80004612:	fffff097          	auipc	ra,0xfffff
    80004616:	f2c080e7          	jalr	-212(ra) # 8000353e <bread>
    8000461a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000461c:	000aa583          	lw	a1,0(s5)
    80004620:	0289a503          	lw	a0,40(s3)
    80004624:	fffff097          	auipc	ra,0xfffff
    80004628:	f1a080e7          	jalr	-230(ra) # 8000353e <bread>
    8000462c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000462e:	40000613          	li	a2,1024
    80004632:	05890593          	addi	a1,s2,88
    80004636:	05850513          	addi	a0,a0,88
    8000463a:	ffffc097          	auipc	ra,0xffffc
    8000463e:	6e0080e7          	jalr	1760(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004642:	8526                	mv	a0,s1
    80004644:	fffff097          	auipc	ra,0xfffff
    80004648:	fec080e7          	jalr	-20(ra) # 80003630 <bwrite>
    if(recovering == 0)
    8000464c:	f80b1ce3          	bnez	s6,800045e4 <install_trans+0x36>
      bunpin(dbuf);
    80004650:	8526                	mv	a0,s1
    80004652:	fffff097          	auipc	ra,0xfffff
    80004656:	0f6080e7          	jalr	246(ra) # 80003748 <bunpin>
    8000465a:	b769                	j	800045e4 <install_trans+0x36>
}
    8000465c:	70e2                	ld	ra,56(sp)
    8000465e:	7442                	ld	s0,48(sp)
    80004660:	74a2                	ld	s1,40(sp)
    80004662:	7902                	ld	s2,32(sp)
    80004664:	69e2                	ld	s3,24(sp)
    80004666:	6a42                	ld	s4,16(sp)
    80004668:	6aa2                	ld	s5,8(sp)
    8000466a:	6b02                	ld	s6,0(sp)
    8000466c:	6121                	addi	sp,sp,64
    8000466e:	8082                	ret
    80004670:	8082                	ret

0000000080004672 <initlog>:
{
    80004672:	7179                	addi	sp,sp,-48
    80004674:	f406                	sd	ra,40(sp)
    80004676:	f022                	sd	s0,32(sp)
    80004678:	ec26                	sd	s1,24(sp)
    8000467a:	e84a                	sd	s2,16(sp)
    8000467c:	e44e                	sd	s3,8(sp)
    8000467e:	1800                	addi	s0,sp,48
    80004680:	892a                	mv	s2,a0
    80004682:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004684:	0001d497          	auipc	s1,0x1d
    80004688:	5ec48493          	addi	s1,s1,1516 # 80021c70 <log>
    8000468c:	00004597          	auipc	a1,0x4
    80004690:	29c58593          	addi	a1,a1,668 # 80008928 <syscalls+0x1f0>
    80004694:	8526                	mv	a0,s1
    80004696:	ffffc097          	auipc	ra,0xffffc
    8000469a:	49c080e7          	jalr	1180(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    8000469e:	0149a583          	lw	a1,20(s3)
    800046a2:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800046a4:	0109a783          	lw	a5,16(s3)
    800046a8:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800046aa:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800046ae:	854a                	mv	a0,s2
    800046b0:	fffff097          	auipc	ra,0xfffff
    800046b4:	e8e080e7          	jalr	-370(ra) # 8000353e <bread>
  log.lh.n = lh->n;
    800046b8:	4d34                	lw	a3,88(a0)
    800046ba:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800046bc:	02d05663          	blez	a3,800046e8 <initlog+0x76>
    800046c0:	05c50793          	addi	a5,a0,92
    800046c4:	0001d717          	auipc	a4,0x1d
    800046c8:	5dc70713          	addi	a4,a4,1500 # 80021ca0 <log+0x30>
    800046cc:	36fd                	addiw	a3,a3,-1
    800046ce:	02069613          	slli	a2,a3,0x20
    800046d2:	01e65693          	srli	a3,a2,0x1e
    800046d6:	06050613          	addi	a2,a0,96
    800046da:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800046dc:	4390                	lw	a2,0(a5)
    800046de:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800046e0:	0791                	addi	a5,a5,4
    800046e2:	0711                	addi	a4,a4,4
    800046e4:	fed79ce3          	bne	a5,a3,800046dc <initlog+0x6a>
  brelse(buf);
    800046e8:	fffff097          	auipc	ra,0xfffff
    800046ec:	f86080e7          	jalr	-122(ra) # 8000366e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800046f0:	4505                	li	a0,1
    800046f2:	00000097          	auipc	ra,0x0
    800046f6:	ebc080e7          	jalr	-324(ra) # 800045ae <install_trans>
  log.lh.n = 0;
    800046fa:	0001d797          	auipc	a5,0x1d
    800046fe:	5a07a123          	sw	zero,1442(a5) # 80021c9c <log+0x2c>
  write_head(); // clear the log
    80004702:	00000097          	auipc	ra,0x0
    80004706:	e30080e7          	jalr	-464(ra) # 80004532 <write_head>
}
    8000470a:	70a2                	ld	ra,40(sp)
    8000470c:	7402                	ld	s0,32(sp)
    8000470e:	64e2                	ld	s1,24(sp)
    80004710:	6942                	ld	s2,16(sp)
    80004712:	69a2                	ld	s3,8(sp)
    80004714:	6145                	addi	sp,sp,48
    80004716:	8082                	ret

0000000080004718 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004718:	1101                	addi	sp,sp,-32
    8000471a:	ec06                	sd	ra,24(sp)
    8000471c:	e822                	sd	s0,16(sp)
    8000471e:	e426                	sd	s1,8(sp)
    80004720:	e04a                	sd	s2,0(sp)
    80004722:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004724:	0001d517          	auipc	a0,0x1d
    80004728:	54c50513          	addi	a0,a0,1356 # 80021c70 <log>
    8000472c:	ffffc097          	auipc	ra,0xffffc
    80004730:	496080e7          	jalr	1174(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    80004734:	0001d497          	auipc	s1,0x1d
    80004738:	53c48493          	addi	s1,s1,1340 # 80021c70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000473c:	4979                	li	s2,30
    8000473e:	a039                	j	8000474c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004740:	85a6                	mv	a1,s1
    80004742:	8526                	mv	a0,s1
    80004744:	ffffe097          	auipc	ra,0xffffe
    80004748:	bfc080e7          	jalr	-1028(ra) # 80002340 <sleep>
    if(log.committing){
    8000474c:	50dc                	lw	a5,36(s1)
    8000474e:	fbed                	bnez	a5,80004740 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004750:	509c                	lw	a5,32(s1)
    80004752:	0017871b          	addiw	a4,a5,1
    80004756:	0007069b          	sext.w	a3,a4
    8000475a:	0027179b          	slliw	a5,a4,0x2
    8000475e:	9fb9                	addw	a5,a5,a4
    80004760:	0017979b          	slliw	a5,a5,0x1
    80004764:	54d8                	lw	a4,44(s1)
    80004766:	9fb9                	addw	a5,a5,a4
    80004768:	00f95963          	bge	s2,a5,8000477a <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000476c:	85a6                	mv	a1,s1
    8000476e:	8526                	mv	a0,s1
    80004770:	ffffe097          	auipc	ra,0xffffe
    80004774:	bd0080e7          	jalr	-1072(ra) # 80002340 <sleep>
    80004778:	bfd1                	j	8000474c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000477a:	0001d517          	auipc	a0,0x1d
    8000477e:	4f650513          	addi	a0,a0,1270 # 80021c70 <log>
    80004782:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004784:	ffffc097          	auipc	ra,0xffffc
    80004788:	4f2080e7          	jalr	1266(ra) # 80000c76 <release>
      break;
    }
  }
}
    8000478c:	60e2                	ld	ra,24(sp)
    8000478e:	6442                	ld	s0,16(sp)
    80004790:	64a2                	ld	s1,8(sp)
    80004792:	6902                	ld	s2,0(sp)
    80004794:	6105                	addi	sp,sp,32
    80004796:	8082                	ret

0000000080004798 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004798:	7139                	addi	sp,sp,-64
    8000479a:	fc06                	sd	ra,56(sp)
    8000479c:	f822                	sd	s0,48(sp)
    8000479e:	f426                	sd	s1,40(sp)
    800047a0:	f04a                	sd	s2,32(sp)
    800047a2:	ec4e                	sd	s3,24(sp)
    800047a4:	e852                	sd	s4,16(sp)
    800047a6:	e456                	sd	s5,8(sp)
    800047a8:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800047aa:	0001d497          	auipc	s1,0x1d
    800047ae:	4c648493          	addi	s1,s1,1222 # 80021c70 <log>
    800047b2:	8526                	mv	a0,s1
    800047b4:	ffffc097          	auipc	ra,0xffffc
    800047b8:	40e080e7          	jalr	1038(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    800047bc:	509c                	lw	a5,32(s1)
    800047be:	37fd                	addiw	a5,a5,-1
    800047c0:	0007891b          	sext.w	s2,a5
    800047c4:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800047c6:	50dc                	lw	a5,36(s1)
    800047c8:	e7b9                	bnez	a5,80004816 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800047ca:	04091e63          	bnez	s2,80004826 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800047ce:	0001d497          	auipc	s1,0x1d
    800047d2:	4a248493          	addi	s1,s1,1186 # 80021c70 <log>
    800047d6:	4785                	li	a5,1
    800047d8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800047da:	8526                	mv	a0,s1
    800047dc:	ffffc097          	auipc	ra,0xffffc
    800047e0:	49a080e7          	jalr	1178(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800047e4:	54dc                	lw	a5,44(s1)
    800047e6:	06f04763          	bgtz	a5,80004854 <end_op+0xbc>
    acquire(&log.lock);
    800047ea:	0001d497          	auipc	s1,0x1d
    800047ee:	48648493          	addi	s1,s1,1158 # 80021c70 <log>
    800047f2:	8526                	mv	a0,s1
    800047f4:	ffffc097          	auipc	ra,0xffffc
    800047f8:	3ce080e7          	jalr	974(ra) # 80000bc2 <acquire>
    log.committing = 0;
    800047fc:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004800:	8526                	mv	a0,s1
    80004802:	ffffe097          	auipc	ra,0xffffe
    80004806:	cca080e7          	jalr	-822(ra) # 800024cc <wakeup>
    release(&log.lock);
    8000480a:	8526                	mv	a0,s1
    8000480c:	ffffc097          	auipc	ra,0xffffc
    80004810:	46a080e7          	jalr	1130(ra) # 80000c76 <release>
}
    80004814:	a03d                	j	80004842 <end_op+0xaa>
    panic("log.committing");
    80004816:	00004517          	auipc	a0,0x4
    8000481a:	11a50513          	addi	a0,a0,282 # 80008930 <syscalls+0x1f8>
    8000481e:	ffffc097          	auipc	ra,0xffffc
    80004822:	d0c080e7          	jalr	-756(ra) # 8000052a <panic>
    wakeup(&log);
    80004826:	0001d497          	auipc	s1,0x1d
    8000482a:	44a48493          	addi	s1,s1,1098 # 80021c70 <log>
    8000482e:	8526                	mv	a0,s1
    80004830:	ffffe097          	auipc	ra,0xffffe
    80004834:	c9c080e7          	jalr	-868(ra) # 800024cc <wakeup>
  release(&log.lock);
    80004838:	8526                	mv	a0,s1
    8000483a:	ffffc097          	auipc	ra,0xffffc
    8000483e:	43c080e7          	jalr	1084(ra) # 80000c76 <release>
}
    80004842:	70e2                	ld	ra,56(sp)
    80004844:	7442                	ld	s0,48(sp)
    80004846:	74a2                	ld	s1,40(sp)
    80004848:	7902                	ld	s2,32(sp)
    8000484a:	69e2                	ld	s3,24(sp)
    8000484c:	6a42                	ld	s4,16(sp)
    8000484e:	6aa2                	ld	s5,8(sp)
    80004850:	6121                	addi	sp,sp,64
    80004852:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004854:	0001da97          	auipc	s5,0x1d
    80004858:	44ca8a93          	addi	s5,s5,1100 # 80021ca0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000485c:	0001da17          	auipc	s4,0x1d
    80004860:	414a0a13          	addi	s4,s4,1044 # 80021c70 <log>
    80004864:	018a2583          	lw	a1,24(s4)
    80004868:	012585bb          	addw	a1,a1,s2
    8000486c:	2585                	addiw	a1,a1,1
    8000486e:	028a2503          	lw	a0,40(s4)
    80004872:	fffff097          	auipc	ra,0xfffff
    80004876:	ccc080e7          	jalr	-820(ra) # 8000353e <bread>
    8000487a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000487c:	000aa583          	lw	a1,0(s5)
    80004880:	028a2503          	lw	a0,40(s4)
    80004884:	fffff097          	auipc	ra,0xfffff
    80004888:	cba080e7          	jalr	-838(ra) # 8000353e <bread>
    8000488c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000488e:	40000613          	li	a2,1024
    80004892:	05850593          	addi	a1,a0,88
    80004896:	05848513          	addi	a0,s1,88
    8000489a:	ffffc097          	auipc	ra,0xffffc
    8000489e:	480080e7          	jalr	1152(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    800048a2:	8526                	mv	a0,s1
    800048a4:	fffff097          	auipc	ra,0xfffff
    800048a8:	d8c080e7          	jalr	-628(ra) # 80003630 <bwrite>
    brelse(from);
    800048ac:	854e                	mv	a0,s3
    800048ae:	fffff097          	auipc	ra,0xfffff
    800048b2:	dc0080e7          	jalr	-576(ra) # 8000366e <brelse>
    brelse(to);
    800048b6:	8526                	mv	a0,s1
    800048b8:	fffff097          	auipc	ra,0xfffff
    800048bc:	db6080e7          	jalr	-586(ra) # 8000366e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800048c0:	2905                	addiw	s2,s2,1
    800048c2:	0a91                	addi	s5,s5,4
    800048c4:	02ca2783          	lw	a5,44(s4)
    800048c8:	f8f94ee3          	blt	s2,a5,80004864 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800048cc:	00000097          	auipc	ra,0x0
    800048d0:	c66080e7          	jalr	-922(ra) # 80004532 <write_head>
    install_trans(0); // Now install writes to home locations
    800048d4:	4501                	li	a0,0
    800048d6:	00000097          	auipc	ra,0x0
    800048da:	cd8080e7          	jalr	-808(ra) # 800045ae <install_trans>
    log.lh.n = 0;
    800048de:	0001d797          	auipc	a5,0x1d
    800048e2:	3a07af23          	sw	zero,958(a5) # 80021c9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800048e6:	00000097          	auipc	ra,0x0
    800048ea:	c4c080e7          	jalr	-948(ra) # 80004532 <write_head>
    800048ee:	bdf5                	j	800047ea <end_op+0x52>

00000000800048f0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800048f0:	1101                	addi	sp,sp,-32
    800048f2:	ec06                	sd	ra,24(sp)
    800048f4:	e822                	sd	s0,16(sp)
    800048f6:	e426                	sd	s1,8(sp)
    800048f8:	e04a                	sd	s2,0(sp)
    800048fa:	1000                	addi	s0,sp,32
    800048fc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800048fe:	0001d917          	auipc	s2,0x1d
    80004902:	37290913          	addi	s2,s2,882 # 80021c70 <log>
    80004906:	854a                	mv	a0,s2
    80004908:	ffffc097          	auipc	ra,0xffffc
    8000490c:	2ba080e7          	jalr	698(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004910:	02c92603          	lw	a2,44(s2)
    80004914:	47f5                	li	a5,29
    80004916:	06c7c563          	blt	a5,a2,80004980 <log_write+0x90>
    8000491a:	0001d797          	auipc	a5,0x1d
    8000491e:	3727a783          	lw	a5,882(a5) # 80021c8c <log+0x1c>
    80004922:	37fd                	addiw	a5,a5,-1
    80004924:	04f65e63          	bge	a2,a5,80004980 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004928:	0001d797          	auipc	a5,0x1d
    8000492c:	3687a783          	lw	a5,872(a5) # 80021c90 <log+0x20>
    80004930:	06f05063          	blez	a5,80004990 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004934:	4781                	li	a5,0
    80004936:	06c05563          	blez	a2,800049a0 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000493a:	44cc                	lw	a1,12(s1)
    8000493c:	0001d717          	auipc	a4,0x1d
    80004940:	36470713          	addi	a4,a4,868 # 80021ca0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004944:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004946:	4314                	lw	a3,0(a4)
    80004948:	04b68c63          	beq	a3,a1,800049a0 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000494c:	2785                	addiw	a5,a5,1
    8000494e:	0711                	addi	a4,a4,4
    80004950:	fef61be3          	bne	a2,a5,80004946 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004954:	0621                	addi	a2,a2,8
    80004956:	060a                	slli	a2,a2,0x2
    80004958:	0001d797          	auipc	a5,0x1d
    8000495c:	31878793          	addi	a5,a5,792 # 80021c70 <log>
    80004960:	963e                	add	a2,a2,a5
    80004962:	44dc                	lw	a5,12(s1)
    80004964:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004966:	8526                	mv	a0,s1
    80004968:	fffff097          	auipc	ra,0xfffff
    8000496c:	da4080e7          	jalr	-604(ra) # 8000370c <bpin>
    log.lh.n++;
    80004970:	0001d717          	auipc	a4,0x1d
    80004974:	30070713          	addi	a4,a4,768 # 80021c70 <log>
    80004978:	575c                	lw	a5,44(a4)
    8000497a:	2785                	addiw	a5,a5,1
    8000497c:	d75c                	sw	a5,44(a4)
    8000497e:	a835                	j	800049ba <log_write+0xca>
    panic("too big a transaction");
    80004980:	00004517          	auipc	a0,0x4
    80004984:	fc050513          	addi	a0,a0,-64 # 80008940 <syscalls+0x208>
    80004988:	ffffc097          	auipc	ra,0xffffc
    8000498c:	ba2080e7          	jalr	-1118(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004990:	00004517          	auipc	a0,0x4
    80004994:	fc850513          	addi	a0,a0,-56 # 80008958 <syscalls+0x220>
    80004998:	ffffc097          	auipc	ra,0xffffc
    8000499c:	b92080e7          	jalr	-1134(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    800049a0:	00878713          	addi	a4,a5,8
    800049a4:	00271693          	slli	a3,a4,0x2
    800049a8:	0001d717          	auipc	a4,0x1d
    800049ac:	2c870713          	addi	a4,a4,712 # 80021c70 <log>
    800049b0:	9736                	add	a4,a4,a3
    800049b2:	44d4                	lw	a3,12(s1)
    800049b4:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800049b6:	faf608e3          	beq	a2,a5,80004966 <log_write+0x76>
  }
  release(&log.lock);
    800049ba:	0001d517          	auipc	a0,0x1d
    800049be:	2b650513          	addi	a0,a0,694 # 80021c70 <log>
    800049c2:	ffffc097          	auipc	ra,0xffffc
    800049c6:	2b4080e7          	jalr	692(ra) # 80000c76 <release>
}
    800049ca:	60e2                	ld	ra,24(sp)
    800049cc:	6442                	ld	s0,16(sp)
    800049ce:	64a2                	ld	s1,8(sp)
    800049d0:	6902                	ld	s2,0(sp)
    800049d2:	6105                	addi	sp,sp,32
    800049d4:	8082                	ret

00000000800049d6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800049d6:	1101                	addi	sp,sp,-32
    800049d8:	ec06                	sd	ra,24(sp)
    800049da:	e822                	sd	s0,16(sp)
    800049dc:	e426                	sd	s1,8(sp)
    800049de:	e04a                	sd	s2,0(sp)
    800049e0:	1000                	addi	s0,sp,32
    800049e2:	84aa                	mv	s1,a0
    800049e4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800049e6:	00004597          	auipc	a1,0x4
    800049ea:	f9258593          	addi	a1,a1,-110 # 80008978 <syscalls+0x240>
    800049ee:	0521                	addi	a0,a0,8
    800049f0:	ffffc097          	auipc	ra,0xffffc
    800049f4:	142080e7          	jalr	322(ra) # 80000b32 <initlock>
  lk->name = name;
    800049f8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800049fc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a00:	0204a423          	sw	zero,40(s1)
}
    80004a04:	60e2                	ld	ra,24(sp)
    80004a06:	6442                	ld	s0,16(sp)
    80004a08:	64a2                	ld	s1,8(sp)
    80004a0a:	6902                	ld	s2,0(sp)
    80004a0c:	6105                	addi	sp,sp,32
    80004a0e:	8082                	ret

0000000080004a10 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004a10:	1101                	addi	sp,sp,-32
    80004a12:	ec06                	sd	ra,24(sp)
    80004a14:	e822                	sd	s0,16(sp)
    80004a16:	e426                	sd	s1,8(sp)
    80004a18:	e04a                	sd	s2,0(sp)
    80004a1a:	1000                	addi	s0,sp,32
    80004a1c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a1e:	00850913          	addi	s2,a0,8
    80004a22:	854a                	mv	a0,s2
    80004a24:	ffffc097          	auipc	ra,0xffffc
    80004a28:	19e080e7          	jalr	414(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    80004a2c:	409c                	lw	a5,0(s1)
    80004a2e:	cb89                	beqz	a5,80004a40 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004a30:	85ca                	mv	a1,s2
    80004a32:	8526                	mv	a0,s1
    80004a34:	ffffe097          	auipc	ra,0xffffe
    80004a38:	90c080e7          	jalr	-1780(ra) # 80002340 <sleep>
  while (lk->locked) {
    80004a3c:	409c                	lw	a5,0(s1)
    80004a3e:	fbed                	bnez	a5,80004a30 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004a40:	4785                	li	a5,1
    80004a42:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004a44:	ffffd097          	auipc	ra,0xffffd
    80004a48:	f82080e7          	jalr	-126(ra) # 800019c6 <myproc>
    80004a4c:	591c                	lw	a5,48(a0)
    80004a4e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004a50:	854a                	mv	a0,s2
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	224080e7          	jalr	548(ra) # 80000c76 <release>
}
    80004a5a:	60e2                	ld	ra,24(sp)
    80004a5c:	6442                	ld	s0,16(sp)
    80004a5e:	64a2                	ld	s1,8(sp)
    80004a60:	6902                	ld	s2,0(sp)
    80004a62:	6105                	addi	sp,sp,32
    80004a64:	8082                	ret

0000000080004a66 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004a66:	1101                	addi	sp,sp,-32
    80004a68:	ec06                	sd	ra,24(sp)
    80004a6a:	e822                	sd	s0,16(sp)
    80004a6c:	e426                	sd	s1,8(sp)
    80004a6e:	e04a                	sd	s2,0(sp)
    80004a70:	1000                	addi	s0,sp,32
    80004a72:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a74:	00850913          	addi	s2,a0,8
    80004a78:	854a                	mv	a0,s2
    80004a7a:	ffffc097          	auipc	ra,0xffffc
    80004a7e:	148080e7          	jalr	328(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80004a82:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a86:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004a8a:	8526                	mv	a0,s1
    80004a8c:	ffffe097          	auipc	ra,0xffffe
    80004a90:	a40080e7          	jalr	-1472(ra) # 800024cc <wakeup>
  release(&lk->lk);
    80004a94:	854a                	mv	a0,s2
    80004a96:	ffffc097          	auipc	ra,0xffffc
    80004a9a:	1e0080e7          	jalr	480(ra) # 80000c76 <release>
}
    80004a9e:	60e2                	ld	ra,24(sp)
    80004aa0:	6442                	ld	s0,16(sp)
    80004aa2:	64a2                	ld	s1,8(sp)
    80004aa4:	6902                	ld	s2,0(sp)
    80004aa6:	6105                	addi	sp,sp,32
    80004aa8:	8082                	ret

0000000080004aaa <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004aaa:	7179                	addi	sp,sp,-48
    80004aac:	f406                	sd	ra,40(sp)
    80004aae:	f022                	sd	s0,32(sp)
    80004ab0:	ec26                	sd	s1,24(sp)
    80004ab2:	e84a                	sd	s2,16(sp)
    80004ab4:	e44e                	sd	s3,8(sp)
    80004ab6:	1800                	addi	s0,sp,48
    80004ab8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004aba:	00850913          	addi	s2,a0,8
    80004abe:	854a                	mv	a0,s2
    80004ac0:	ffffc097          	auipc	ra,0xffffc
    80004ac4:	102080e7          	jalr	258(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ac8:	409c                	lw	a5,0(s1)
    80004aca:	ef99                	bnez	a5,80004ae8 <holdingsleep+0x3e>
    80004acc:	4481                	li	s1,0
  release(&lk->lk);
    80004ace:	854a                	mv	a0,s2
    80004ad0:	ffffc097          	auipc	ra,0xffffc
    80004ad4:	1a6080e7          	jalr	422(ra) # 80000c76 <release>
  return r;
}
    80004ad8:	8526                	mv	a0,s1
    80004ada:	70a2                	ld	ra,40(sp)
    80004adc:	7402                	ld	s0,32(sp)
    80004ade:	64e2                	ld	s1,24(sp)
    80004ae0:	6942                	ld	s2,16(sp)
    80004ae2:	69a2                	ld	s3,8(sp)
    80004ae4:	6145                	addi	sp,sp,48
    80004ae6:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ae8:	0284a983          	lw	s3,40(s1)
    80004aec:	ffffd097          	auipc	ra,0xffffd
    80004af0:	eda080e7          	jalr	-294(ra) # 800019c6 <myproc>
    80004af4:	5904                	lw	s1,48(a0)
    80004af6:	413484b3          	sub	s1,s1,s3
    80004afa:	0014b493          	seqz	s1,s1
    80004afe:	bfc1                	j	80004ace <holdingsleep+0x24>

0000000080004b00 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004b00:	1141                	addi	sp,sp,-16
    80004b02:	e406                	sd	ra,8(sp)
    80004b04:	e022                	sd	s0,0(sp)
    80004b06:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004b08:	00004597          	auipc	a1,0x4
    80004b0c:	e8058593          	addi	a1,a1,-384 # 80008988 <syscalls+0x250>
    80004b10:	0001d517          	auipc	a0,0x1d
    80004b14:	2a850513          	addi	a0,a0,680 # 80021db8 <ftable>
    80004b18:	ffffc097          	auipc	ra,0xffffc
    80004b1c:	01a080e7          	jalr	26(ra) # 80000b32 <initlock>
}
    80004b20:	60a2                	ld	ra,8(sp)
    80004b22:	6402                	ld	s0,0(sp)
    80004b24:	0141                	addi	sp,sp,16
    80004b26:	8082                	ret

0000000080004b28 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004b28:	1101                	addi	sp,sp,-32
    80004b2a:	ec06                	sd	ra,24(sp)
    80004b2c:	e822                	sd	s0,16(sp)
    80004b2e:	e426                	sd	s1,8(sp)
    80004b30:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004b32:	0001d517          	auipc	a0,0x1d
    80004b36:	28650513          	addi	a0,a0,646 # 80021db8 <ftable>
    80004b3a:	ffffc097          	auipc	ra,0xffffc
    80004b3e:	088080e7          	jalr	136(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b42:	0001d497          	auipc	s1,0x1d
    80004b46:	28e48493          	addi	s1,s1,654 # 80021dd0 <ftable+0x18>
    80004b4a:	0001e717          	auipc	a4,0x1e
    80004b4e:	22670713          	addi	a4,a4,550 # 80022d70 <ftable+0xfb8>
    if(f->ref == 0){
    80004b52:	40dc                	lw	a5,4(s1)
    80004b54:	cf99                	beqz	a5,80004b72 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b56:	02848493          	addi	s1,s1,40
    80004b5a:	fee49ce3          	bne	s1,a4,80004b52 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004b5e:	0001d517          	auipc	a0,0x1d
    80004b62:	25a50513          	addi	a0,a0,602 # 80021db8 <ftable>
    80004b66:	ffffc097          	auipc	ra,0xffffc
    80004b6a:	110080e7          	jalr	272(ra) # 80000c76 <release>
  return 0;
    80004b6e:	4481                	li	s1,0
    80004b70:	a819                	j	80004b86 <filealloc+0x5e>
      f->ref = 1;
    80004b72:	4785                	li	a5,1
    80004b74:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004b76:	0001d517          	auipc	a0,0x1d
    80004b7a:	24250513          	addi	a0,a0,578 # 80021db8 <ftable>
    80004b7e:	ffffc097          	auipc	ra,0xffffc
    80004b82:	0f8080e7          	jalr	248(ra) # 80000c76 <release>
}
    80004b86:	8526                	mv	a0,s1
    80004b88:	60e2                	ld	ra,24(sp)
    80004b8a:	6442                	ld	s0,16(sp)
    80004b8c:	64a2                	ld	s1,8(sp)
    80004b8e:	6105                	addi	sp,sp,32
    80004b90:	8082                	ret

0000000080004b92 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b92:	1101                	addi	sp,sp,-32
    80004b94:	ec06                	sd	ra,24(sp)
    80004b96:	e822                	sd	s0,16(sp)
    80004b98:	e426                	sd	s1,8(sp)
    80004b9a:	1000                	addi	s0,sp,32
    80004b9c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b9e:	0001d517          	auipc	a0,0x1d
    80004ba2:	21a50513          	addi	a0,a0,538 # 80021db8 <ftable>
    80004ba6:	ffffc097          	auipc	ra,0xffffc
    80004baa:	01c080e7          	jalr	28(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004bae:	40dc                	lw	a5,4(s1)
    80004bb0:	02f05263          	blez	a5,80004bd4 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004bb4:	2785                	addiw	a5,a5,1
    80004bb6:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004bb8:	0001d517          	auipc	a0,0x1d
    80004bbc:	20050513          	addi	a0,a0,512 # 80021db8 <ftable>
    80004bc0:	ffffc097          	auipc	ra,0xffffc
    80004bc4:	0b6080e7          	jalr	182(ra) # 80000c76 <release>
  return f;
}
    80004bc8:	8526                	mv	a0,s1
    80004bca:	60e2                	ld	ra,24(sp)
    80004bcc:	6442                	ld	s0,16(sp)
    80004bce:	64a2                	ld	s1,8(sp)
    80004bd0:	6105                	addi	sp,sp,32
    80004bd2:	8082                	ret
    panic("filedup");
    80004bd4:	00004517          	auipc	a0,0x4
    80004bd8:	dbc50513          	addi	a0,a0,-580 # 80008990 <syscalls+0x258>
    80004bdc:	ffffc097          	auipc	ra,0xffffc
    80004be0:	94e080e7          	jalr	-1714(ra) # 8000052a <panic>

0000000080004be4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004be4:	7139                	addi	sp,sp,-64
    80004be6:	fc06                	sd	ra,56(sp)
    80004be8:	f822                	sd	s0,48(sp)
    80004bea:	f426                	sd	s1,40(sp)
    80004bec:	f04a                	sd	s2,32(sp)
    80004bee:	ec4e                	sd	s3,24(sp)
    80004bf0:	e852                	sd	s4,16(sp)
    80004bf2:	e456                	sd	s5,8(sp)
    80004bf4:	0080                	addi	s0,sp,64
    80004bf6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004bf8:	0001d517          	auipc	a0,0x1d
    80004bfc:	1c050513          	addi	a0,a0,448 # 80021db8 <ftable>
    80004c00:	ffffc097          	auipc	ra,0xffffc
    80004c04:	fc2080e7          	jalr	-62(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004c08:	40dc                	lw	a5,4(s1)
    80004c0a:	06f05163          	blez	a5,80004c6c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004c0e:	37fd                	addiw	a5,a5,-1
    80004c10:	0007871b          	sext.w	a4,a5
    80004c14:	c0dc                	sw	a5,4(s1)
    80004c16:	06e04363          	bgtz	a4,80004c7c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004c1a:	0004a903          	lw	s2,0(s1)
    80004c1e:	0094ca83          	lbu	s5,9(s1)
    80004c22:	0104ba03          	ld	s4,16(s1)
    80004c26:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004c2a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004c2e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004c32:	0001d517          	auipc	a0,0x1d
    80004c36:	18650513          	addi	a0,a0,390 # 80021db8 <ftable>
    80004c3a:	ffffc097          	auipc	ra,0xffffc
    80004c3e:	03c080e7          	jalr	60(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    80004c42:	4785                	li	a5,1
    80004c44:	04f90d63          	beq	s2,a5,80004c9e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004c48:	3979                	addiw	s2,s2,-2
    80004c4a:	4785                	li	a5,1
    80004c4c:	0527e063          	bltu	a5,s2,80004c8c <fileclose+0xa8>
    begin_op();
    80004c50:	00000097          	auipc	ra,0x0
    80004c54:	ac8080e7          	jalr	-1336(ra) # 80004718 <begin_op>
    iput(ff.ip);
    80004c58:	854e                	mv	a0,s3
    80004c5a:	fffff097          	auipc	ra,0xfffff
    80004c5e:	2a2080e7          	jalr	674(ra) # 80003efc <iput>
    end_op();
    80004c62:	00000097          	auipc	ra,0x0
    80004c66:	b36080e7          	jalr	-1226(ra) # 80004798 <end_op>
    80004c6a:	a00d                	j	80004c8c <fileclose+0xa8>
    panic("fileclose");
    80004c6c:	00004517          	auipc	a0,0x4
    80004c70:	d2c50513          	addi	a0,a0,-724 # 80008998 <syscalls+0x260>
    80004c74:	ffffc097          	auipc	ra,0xffffc
    80004c78:	8b6080e7          	jalr	-1866(ra) # 8000052a <panic>
    release(&ftable.lock);
    80004c7c:	0001d517          	auipc	a0,0x1d
    80004c80:	13c50513          	addi	a0,a0,316 # 80021db8 <ftable>
    80004c84:	ffffc097          	auipc	ra,0xffffc
    80004c88:	ff2080e7          	jalr	-14(ra) # 80000c76 <release>
  }
}
    80004c8c:	70e2                	ld	ra,56(sp)
    80004c8e:	7442                	ld	s0,48(sp)
    80004c90:	74a2                	ld	s1,40(sp)
    80004c92:	7902                	ld	s2,32(sp)
    80004c94:	69e2                	ld	s3,24(sp)
    80004c96:	6a42                	ld	s4,16(sp)
    80004c98:	6aa2                	ld	s5,8(sp)
    80004c9a:	6121                	addi	sp,sp,64
    80004c9c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c9e:	85d6                	mv	a1,s5
    80004ca0:	8552                	mv	a0,s4
    80004ca2:	00000097          	auipc	ra,0x0
    80004ca6:	34c080e7          	jalr	844(ra) # 80004fee <pipeclose>
    80004caa:	b7cd                	j	80004c8c <fileclose+0xa8>

0000000080004cac <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004cac:	715d                	addi	sp,sp,-80
    80004cae:	e486                	sd	ra,72(sp)
    80004cb0:	e0a2                	sd	s0,64(sp)
    80004cb2:	fc26                	sd	s1,56(sp)
    80004cb4:	f84a                	sd	s2,48(sp)
    80004cb6:	f44e                	sd	s3,40(sp)
    80004cb8:	0880                	addi	s0,sp,80
    80004cba:	84aa                	mv	s1,a0
    80004cbc:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004cbe:	ffffd097          	auipc	ra,0xffffd
    80004cc2:	d08080e7          	jalr	-760(ra) # 800019c6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004cc6:	409c                	lw	a5,0(s1)
    80004cc8:	37f9                	addiw	a5,a5,-2
    80004cca:	4705                	li	a4,1
    80004ccc:	04f76763          	bltu	a4,a5,80004d1a <filestat+0x6e>
    80004cd0:	892a                	mv	s2,a0
    ilock(f->ip);
    80004cd2:	6c88                	ld	a0,24(s1)
    80004cd4:	fffff097          	auipc	ra,0xfffff
    80004cd8:	06e080e7          	jalr	110(ra) # 80003d42 <ilock>
    stati(f->ip, &st);
    80004cdc:	fb840593          	addi	a1,s0,-72
    80004ce0:	6c88                	ld	a0,24(s1)
    80004ce2:	fffff097          	auipc	ra,0xfffff
    80004ce6:	2ea080e7          	jalr	746(ra) # 80003fcc <stati>
    iunlock(f->ip);
    80004cea:	6c88                	ld	a0,24(s1)
    80004cec:	fffff097          	auipc	ra,0xfffff
    80004cf0:	118080e7          	jalr	280(ra) # 80003e04 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004cf4:	46e1                	li	a3,24
    80004cf6:	fb840613          	addi	a2,s0,-72
    80004cfa:	85ce                	mv	a1,s3
    80004cfc:	07893503          	ld	a0,120(s2)
    80004d00:	ffffd097          	auipc	ra,0xffffd
    80004d04:	93e080e7          	jalr	-1730(ra) # 8000163e <copyout>
    80004d08:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004d0c:	60a6                	ld	ra,72(sp)
    80004d0e:	6406                	ld	s0,64(sp)
    80004d10:	74e2                	ld	s1,56(sp)
    80004d12:	7942                	ld	s2,48(sp)
    80004d14:	79a2                	ld	s3,40(sp)
    80004d16:	6161                	addi	sp,sp,80
    80004d18:	8082                	ret
  return -1;
    80004d1a:	557d                	li	a0,-1
    80004d1c:	bfc5                	j	80004d0c <filestat+0x60>

0000000080004d1e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004d1e:	7179                	addi	sp,sp,-48
    80004d20:	f406                	sd	ra,40(sp)
    80004d22:	f022                	sd	s0,32(sp)
    80004d24:	ec26                	sd	s1,24(sp)
    80004d26:	e84a                	sd	s2,16(sp)
    80004d28:	e44e                	sd	s3,8(sp)
    80004d2a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004d2c:	00854783          	lbu	a5,8(a0)
    80004d30:	c3d5                	beqz	a5,80004dd4 <fileread+0xb6>
    80004d32:	84aa                	mv	s1,a0
    80004d34:	89ae                	mv	s3,a1
    80004d36:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d38:	411c                	lw	a5,0(a0)
    80004d3a:	4705                	li	a4,1
    80004d3c:	04e78963          	beq	a5,a4,80004d8e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d40:	470d                	li	a4,3
    80004d42:	04e78d63          	beq	a5,a4,80004d9c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d46:	4709                	li	a4,2
    80004d48:	06e79e63          	bne	a5,a4,80004dc4 <fileread+0xa6>
    ilock(f->ip);
    80004d4c:	6d08                	ld	a0,24(a0)
    80004d4e:	fffff097          	auipc	ra,0xfffff
    80004d52:	ff4080e7          	jalr	-12(ra) # 80003d42 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004d56:	874a                	mv	a4,s2
    80004d58:	5094                	lw	a3,32(s1)
    80004d5a:	864e                	mv	a2,s3
    80004d5c:	4585                	li	a1,1
    80004d5e:	6c88                	ld	a0,24(s1)
    80004d60:	fffff097          	auipc	ra,0xfffff
    80004d64:	296080e7          	jalr	662(ra) # 80003ff6 <readi>
    80004d68:	892a                	mv	s2,a0
    80004d6a:	00a05563          	blez	a0,80004d74 <fileread+0x56>
      f->off += r;
    80004d6e:	509c                	lw	a5,32(s1)
    80004d70:	9fa9                	addw	a5,a5,a0
    80004d72:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004d74:	6c88                	ld	a0,24(s1)
    80004d76:	fffff097          	auipc	ra,0xfffff
    80004d7a:	08e080e7          	jalr	142(ra) # 80003e04 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004d7e:	854a                	mv	a0,s2
    80004d80:	70a2                	ld	ra,40(sp)
    80004d82:	7402                	ld	s0,32(sp)
    80004d84:	64e2                	ld	s1,24(sp)
    80004d86:	6942                	ld	s2,16(sp)
    80004d88:	69a2                	ld	s3,8(sp)
    80004d8a:	6145                	addi	sp,sp,48
    80004d8c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d8e:	6908                	ld	a0,16(a0)
    80004d90:	00000097          	auipc	ra,0x0
    80004d94:	3c0080e7          	jalr	960(ra) # 80005150 <piperead>
    80004d98:	892a                	mv	s2,a0
    80004d9a:	b7d5                	j	80004d7e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d9c:	02451783          	lh	a5,36(a0)
    80004da0:	03079693          	slli	a3,a5,0x30
    80004da4:	92c1                	srli	a3,a3,0x30
    80004da6:	4725                	li	a4,9
    80004da8:	02d76863          	bltu	a4,a3,80004dd8 <fileread+0xba>
    80004dac:	0792                	slli	a5,a5,0x4
    80004dae:	0001d717          	auipc	a4,0x1d
    80004db2:	f6a70713          	addi	a4,a4,-150 # 80021d18 <devsw>
    80004db6:	97ba                	add	a5,a5,a4
    80004db8:	639c                	ld	a5,0(a5)
    80004dba:	c38d                	beqz	a5,80004ddc <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004dbc:	4505                	li	a0,1
    80004dbe:	9782                	jalr	a5
    80004dc0:	892a                	mv	s2,a0
    80004dc2:	bf75                	j	80004d7e <fileread+0x60>
    panic("fileread");
    80004dc4:	00004517          	auipc	a0,0x4
    80004dc8:	be450513          	addi	a0,a0,-1052 # 800089a8 <syscalls+0x270>
    80004dcc:	ffffb097          	auipc	ra,0xffffb
    80004dd0:	75e080e7          	jalr	1886(ra) # 8000052a <panic>
    return -1;
    80004dd4:	597d                	li	s2,-1
    80004dd6:	b765                	j	80004d7e <fileread+0x60>
      return -1;
    80004dd8:	597d                	li	s2,-1
    80004dda:	b755                	j	80004d7e <fileread+0x60>
    80004ddc:	597d                	li	s2,-1
    80004dde:	b745                	j	80004d7e <fileread+0x60>

0000000080004de0 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004de0:	715d                	addi	sp,sp,-80
    80004de2:	e486                	sd	ra,72(sp)
    80004de4:	e0a2                	sd	s0,64(sp)
    80004de6:	fc26                	sd	s1,56(sp)
    80004de8:	f84a                	sd	s2,48(sp)
    80004dea:	f44e                	sd	s3,40(sp)
    80004dec:	f052                	sd	s4,32(sp)
    80004dee:	ec56                	sd	s5,24(sp)
    80004df0:	e85a                	sd	s6,16(sp)
    80004df2:	e45e                	sd	s7,8(sp)
    80004df4:	e062                	sd	s8,0(sp)
    80004df6:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004df8:	00954783          	lbu	a5,9(a0)
    80004dfc:	10078663          	beqz	a5,80004f08 <filewrite+0x128>
    80004e00:	892a                	mv	s2,a0
    80004e02:	8aae                	mv	s5,a1
    80004e04:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e06:	411c                	lw	a5,0(a0)
    80004e08:	4705                	li	a4,1
    80004e0a:	02e78263          	beq	a5,a4,80004e2e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e0e:	470d                	li	a4,3
    80004e10:	02e78663          	beq	a5,a4,80004e3c <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004e14:	4709                	li	a4,2
    80004e16:	0ee79163          	bne	a5,a4,80004ef8 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004e1a:	0ac05d63          	blez	a2,80004ed4 <filewrite+0xf4>
    int i = 0;
    80004e1e:	4981                	li	s3,0
    80004e20:	6b05                	lui	s6,0x1
    80004e22:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004e26:	6b85                	lui	s7,0x1
    80004e28:	c00b8b9b          	addiw	s7,s7,-1024
    80004e2c:	a861                	j	80004ec4 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004e2e:	6908                	ld	a0,16(a0)
    80004e30:	00000097          	auipc	ra,0x0
    80004e34:	22e080e7          	jalr	558(ra) # 8000505e <pipewrite>
    80004e38:	8a2a                	mv	s4,a0
    80004e3a:	a045                	j	80004eda <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004e3c:	02451783          	lh	a5,36(a0)
    80004e40:	03079693          	slli	a3,a5,0x30
    80004e44:	92c1                	srli	a3,a3,0x30
    80004e46:	4725                	li	a4,9
    80004e48:	0cd76263          	bltu	a4,a3,80004f0c <filewrite+0x12c>
    80004e4c:	0792                	slli	a5,a5,0x4
    80004e4e:	0001d717          	auipc	a4,0x1d
    80004e52:	eca70713          	addi	a4,a4,-310 # 80021d18 <devsw>
    80004e56:	97ba                	add	a5,a5,a4
    80004e58:	679c                	ld	a5,8(a5)
    80004e5a:	cbdd                	beqz	a5,80004f10 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004e5c:	4505                	li	a0,1
    80004e5e:	9782                	jalr	a5
    80004e60:	8a2a                	mv	s4,a0
    80004e62:	a8a5                	j	80004eda <filewrite+0xfa>
    80004e64:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004e68:	00000097          	auipc	ra,0x0
    80004e6c:	8b0080e7          	jalr	-1872(ra) # 80004718 <begin_op>
      ilock(f->ip);
    80004e70:	01893503          	ld	a0,24(s2)
    80004e74:	fffff097          	auipc	ra,0xfffff
    80004e78:	ece080e7          	jalr	-306(ra) # 80003d42 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004e7c:	8762                	mv	a4,s8
    80004e7e:	02092683          	lw	a3,32(s2)
    80004e82:	01598633          	add	a2,s3,s5
    80004e86:	4585                	li	a1,1
    80004e88:	01893503          	ld	a0,24(s2)
    80004e8c:	fffff097          	auipc	ra,0xfffff
    80004e90:	262080e7          	jalr	610(ra) # 800040ee <writei>
    80004e94:	84aa                	mv	s1,a0
    80004e96:	00a05763          	blez	a0,80004ea4 <filewrite+0xc4>
        f->off += r;
    80004e9a:	02092783          	lw	a5,32(s2)
    80004e9e:	9fa9                	addw	a5,a5,a0
    80004ea0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ea4:	01893503          	ld	a0,24(s2)
    80004ea8:	fffff097          	auipc	ra,0xfffff
    80004eac:	f5c080e7          	jalr	-164(ra) # 80003e04 <iunlock>
      end_op();
    80004eb0:	00000097          	auipc	ra,0x0
    80004eb4:	8e8080e7          	jalr	-1816(ra) # 80004798 <end_op>

      if(r != n1){
    80004eb8:	009c1f63          	bne	s8,s1,80004ed6 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004ebc:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004ec0:	0149db63          	bge	s3,s4,80004ed6 <filewrite+0xf6>
      int n1 = n - i;
    80004ec4:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004ec8:	84be                	mv	s1,a5
    80004eca:	2781                	sext.w	a5,a5
    80004ecc:	f8fb5ce3          	bge	s6,a5,80004e64 <filewrite+0x84>
    80004ed0:	84de                	mv	s1,s7
    80004ed2:	bf49                	j	80004e64 <filewrite+0x84>
    int i = 0;
    80004ed4:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004ed6:	013a1f63          	bne	s4,s3,80004ef4 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004eda:	8552                	mv	a0,s4
    80004edc:	60a6                	ld	ra,72(sp)
    80004ede:	6406                	ld	s0,64(sp)
    80004ee0:	74e2                	ld	s1,56(sp)
    80004ee2:	7942                	ld	s2,48(sp)
    80004ee4:	79a2                	ld	s3,40(sp)
    80004ee6:	7a02                	ld	s4,32(sp)
    80004ee8:	6ae2                	ld	s5,24(sp)
    80004eea:	6b42                	ld	s6,16(sp)
    80004eec:	6ba2                	ld	s7,8(sp)
    80004eee:	6c02                	ld	s8,0(sp)
    80004ef0:	6161                	addi	sp,sp,80
    80004ef2:	8082                	ret
    ret = (i == n ? n : -1);
    80004ef4:	5a7d                	li	s4,-1
    80004ef6:	b7d5                	j	80004eda <filewrite+0xfa>
    panic("filewrite");
    80004ef8:	00004517          	auipc	a0,0x4
    80004efc:	ac050513          	addi	a0,a0,-1344 # 800089b8 <syscalls+0x280>
    80004f00:	ffffb097          	auipc	ra,0xffffb
    80004f04:	62a080e7          	jalr	1578(ra) # 8000052a <panic>
    return -1;
    80004f08:	5a7d                	li	s4,-1
    80004f0a:	bfc1                	j	80004eda <filewrite+0xfa>
      return -1;
    80004f0c:	5a7d                	li	s4,-1
    80004f0e:	b7f1                	j	80004eda <filewrite+0xfa>
    80004f10:	5a7d                	li	s4,-1
    80004f12:	b7e1                	j	80004eda <filewrite+0xfa>

0000000080004f14 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004f14:	7179                	addi	sp,sp,-48
    80004f16:	f406                	sd	ra,40(sp)
    80004f18:	f022                	sd	s0,32(sp)
    80004f1a:	ec26                	sd	s1,24(sp)
    80004f1c:	e84a                	sd	s2,16(sp)
    80004f1e:	e44e                	sd	s3,8(sp)
    80004f20:	e052                	sd	s4,0(sp)
    80004f22:	1800                	addi	s0,sp,48
    80004f24:	84aa                	mv	s1,a0
    80004f26:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004f28:	0005b023          	sd	zero,0(a1)
    80004f2c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004f30:	00000097          	auipc	ra,0x0
    80004f34:	bf8080e7          	jalr	-1032(ra) # 80004b28 <filealloc>
    80004f38:	e088                	sd	a0,0(s1)
    80004f3a:	c551                	beqz	a0,80004fc6 <pipealloc+0xb2>
    80004f3c:	00000097          	auipc	ra,0x0
    80004f40:	bec080e7          	jalr	-1044(ra) # 80004b28 <filealloc>
    80004f44:	00aa3023          	sd	a0,0(s4)
    80004f48:	c92d                	beqz	a0,80004fba <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004f4a:	ffffc097          	auipc	ra,0xffffc
    80004f4e:	b88080e7          	jalr	-1144(ra) # 80000ad2 <kalloc>
    80004f52:	892a                	mv	s2,a0
    80004f54:	c125                	beqz	a0,80004fb4 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004f56:	4985                	li	s3,1
    80004f58:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004f5c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004f60:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004f64:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004f68:	00003597          	auipc	a1,0x3
    80004f6c:	64058593          	addi	a1,a1,1600 # 800085a8 <states.0+0x1e0>
    80004f70:	ffffc097          	auipc	ra,0xffffc
    80004f74:	bc2080e7          	jalr	-1086(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80004f78:	609c                	ld	a5,0(s1)
    80004f7a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004f7e:	609c                	ld	a5,0(s1)
    80004f80:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f84:	609c                	ld	a5,0(s1)
    80004f86:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004f8a:	609c                	ld	a5,0(s1)
    80004f8c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f90:	000a3783          	ld	a5,0(s4)
    80004f94:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f98:	000a3783          	ld	a5,0(s4)
    80004f9c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004fa0:	000a3783          	ld	a5,0(s4)
    80004fa4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004fa8:	000a3783          	ld	a5,0(s4)
    80004fac:	0127b823          	sd	s2,16(a5)
  return 0;
    80004fb0:	4501                	li	a0,0
    80004fb2:	a025                	j	80004fda <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004fb4:	6088                	ld	a0,0(s1)
    80004fb6:	e501                	bnez	a0,80004fbe <pipealloc+0xaa>
    80004fb8:	a039                	j	80004fc6 <pipealloc+0xb2>
    80004fba:	6088                	ld	a0,0(s1)
    80004fbc:	c51d                	beqz	a0,80004fea <pipealloc+0xd6>
    fileclose(*f0);
    80004fbe:	00000097          	auipc	ra,0x0
    80004fc2:	c26080e7          	jalr	-986(ra) # 80004be4 <fileclose>
  if(*f1)
    80004fc6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004fca:	557d                	li	a0,-1
  if(*f1)
    80004fcc:	c799                	beqz	a5,80004fda <pipealloc+0xc6>
    fileclose(*f1);
    80004fce:	853e                	mv	a0,a5
    80004fd0:	00000097          	auipc	ra,0x0
    80004fd4:	c14080e7          	jalr	-1004(ra) # 80004be4 <fileclose>
  return -1;
    80004fd8:	557d                	li	a0,-1
}
    80004fda:	70a2                	ld	ra,40(sp)
    80004fdc:	7402                	ld	s0,32(sp)
    80004fde:	64e2                	ld	s1,24(sp)
    80004fe0:	6942                	ld	s2,16(sp)
    80004fe2:	69a2                	ld	s3,8(sp)
    80004fe4:	6a02                	ld	s4,0(sp)
    80004fe6:	6145                	addi	sp,sp,48
    80004fe8:	8082                	ret
  return -1;
    80004fea:	557d                	li	a0,-1
    80004fec:	b7fd                	j	80004fda <pipealloc+0xc6>

0000000080004fee <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004fee:	1101                	addi	sp,sp,-32
    80004ff0:	ec06                	sd	ra,24(sp)
    80004ff2:	e822                	sd	s0,16(sp)
    80004ff4:	e426                	sd	s1,8(sp)
    80004ff6:	e04a                	sd	s2,0(sp)
    80004ff8:	1000                	addi	s0,sp,32
    80004ffa:	84aa                	mv	s1,a0
    80004ffc:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004ffe:	ffffc097          	auipc	ra,0xffffc
    80005002:	bc4080e7          	jalr	-1084(ra) # 80000bc2 <acquire>
  if(writable){
    80005006:	02090d63          	beqz	s2,80005040 <pipeclose+0x52>
    pi->writeopen = 0;
    8000500a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000500e:	21848513          	addi	a0,s1,536
    80005012:	ffffd097          	auipc	ra,0xffffd
    80005016:	4ba080e7          	jalr	1210(ra) # 800024cc <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000501a:	2204b783          	ld	a5,544(s1)
    8000501e:	eb95                	bnez	a5,80005052 <pipeclose+0x64>
    release(&pi->lock);
    80005020:	8526                	mv	a0,s1
    80005022:	ffffc097          	auipc	ra,0xffffc
    80005026:	c54080e7          	jalr	-940(ra) # 80000c76 <release>
    kfree((char*)pi);
    8000502a:	8526                	mv	a0,s1
    8000502c:	ffffc097          	auipc	ra,0xffffc
    80005030:	9aa080e7          	jalr	-1622(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    80005034:	60e2                	ld	ra,24(sp)
    80005036:	6442                	ld	s0,16(sp)
    80005038:	64a2                	ld	s1,8(sp)
    8000503a:	6902                	ld	s2,0(sp)
    8000503c:	6105                	addi	sp,sp,32
    8000503e:	8082                	ret
    pi->readopen = 0;
    80005040:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005044:	21c48513          	addi	a0,s1,540
    80005048:	ffffd097          	auipc	ra,0xffffd
    8000504c:	484080e7          	jalr	1156(ra) # 800024cc <wakeup>
    80005050:	b7e9                	j	8000501a <pipeclose+0x2c>
    release(&pi->lock);
    80005052:	8526                	mv	a0,s1
    80005054:	ffffc097          	auipc	ra,0xffffc
    80005058:	c22080e7          	jalr	-990(ra) # 80000c76 <release>
}
    8000505c:	bfe1                	j	80005034 <pipeclose+0x46>

000000008000505e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000505e:	711d                	addi	sp,sp,-96
    80005060:	ec86                	sd	ra,88(sp)
    80005062:	e8a2                	sd	s0,80(sp)
    80005064:	e4a6                	sd	s1,72(sp)
    80005066:	e0ca                	sd	s2,64(sp)
    80005068:	fc4e                	sd	s3,56(sp)
    8000506a:	f852                	sd	s4,48(sp)
    8000506c:	f456                	sd	s5,40(sp)
    8000506e:	f05a                	sd	s6,32(sp)
    80005070:	ec5e                	sd	s7,24(sp)
    80005072:	e862                	sd	s8,16(sp)
    80005074:	1080                	addi	s0,sp,96
    80005076:	84aa                	mv	s1,a0
    80005078:	8aae                	mv	s5,a1
    8000507a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000507c:	ffffd097          	auipc	ra,0xffffd
    80005080:	94a080e7          	jalr	-1718(ra) # 800019c6 <myproc>
    80005084:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005086:	8526                	mv	a0,s1
    80005088:	ffffc097          	auipc	ra,0xffffc
    8000508c:	b3a080e7          	jalr	-1222(ra) # 80000bc2 <acquire>
  while(i < n){
    80005090:	0b405363          	blez	s4,80005136 <pipewrite+0xd8>
  int i = 0;
    80005094:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005096:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005098:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000509c:	21c48b93          	addi	s7,s1,540
    800050a0:	a089                	j	800050e2 <pipewrite+0x84>
      release(&pi->lock);
    800050a2:	8526                	mv	a0,s1
    800050a4:	ffffc097          	auipc	ra,0xffffc
    800050a8:	bd2080e7          	jalr	-1070(ra) # 80000c76 <release>
      return -1;
    800050ac:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800050ae:	854a                	mv	a0,s2
    800050b0:	60e6                	ld	ra,88(sp)
    800050b2:	6446                	ld	s0,80(sp)
    800050b4:	64a6                	ld	s1,72(sp)
    800050b6:	6906                	ld	s2,64(sp)
    800050b8:	79e2                	ld	s3,56(sp)
    800050ba:	7a42                	ld	s4,48(sp)
    800050bc:	7aa2                	ld	s5,40(sp)
    800050be:	7b02                	ld	s6,32(sp)
    800050c0:	6be2                	ld	s7,24(sp)
    800050c2:	6c42                	ld	s8,16(sp)
    800050c4:	6125                	addi	sp,sp,96
    800050c6:	8082                	ret
      wakeup(&pi->nread);
    800050c8:	8562                	mv	a0,s8
    800050ca:	ffffd097          	auipc	ra,0xffffd
    800050ce:	402080e7          	jalr	1026(ra) # 800024cc <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800050d2:	85a6                	mv	a1,s1
    800050d4:	855e                	mv	a0,s7
    800050d6:	ffffd097          	auipc	ra,0xffffd
    800050da:	26a080e7          	jalr	618(ra) # 80002340 <sleep>
  while(i < n){
    800050de:	05495d63          	bge	s2,s4,80005138 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    800050e2:	2204a783          	lw	a5,544(s1)
    800050e6:	dfd5                	beqz	a5,800050a2 <pipewrite+0x44>
    800050e8:	0289a783          	lw	a5,40(s3)
    800050ec:	fbdd                	bnez	a5,800050a2 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800050ee:	2184a783          	lw	a5,536(s1)
    800050f2:	21c4a703          	lw	a4,540(s1)
    800050f6:	2007879b          	addiw	a5,a5,512
    800050fa:	fcf707e3          	beq	a4,a5,800050c8 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050fe:	4685                	li	a3,1
    80005100:	01590633          	add	a2,s2,s5
    80005104:	faf40593          	addi	a1,s0,-81
    80005108:	0789b503          	ld	a0,120(s3)
    8000510c:	ffffc097          	auipc	ra,0xffffc
    80005110:	5be080e7          	jalr	1470(ra) # 800016ca <copyin>
    80005114:	03650263          	beq	a0,s6,80005138 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005118:	21c4a783          	lw	a5,540(s1)
    8000511c:	0017871b          	addiw	a4,a5,1
    80005120:	20e4ae23          	sw	a4,540(s1)
    80005124:	1ff7f793          	andi	a5,a5,511
    80005128:	97a6                	add	a5,a5,s1
    8000512a:	faf44703          	lbu	a4,-81(s0)
    8000512e:	00e78c23          	sb	a4,24(a5)
      i++;
    80005132:	2905                	addiw	s2,s2,1
    80005134:	b76d                	j	800050de <pipewrite+0x80>
  int i = 0;
    80005136:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005138:	21848513          	addi	a0,s1,536
    8000513c:	ffffd097          	auipc	ra,0xffffd
    80005140:	390080e7          	jalr	912(ra) # 800024cc <wakeup>
  release(&pi->lock);
    80005144:	8526                	mv	a0,s1
    80005146:	ffffc097          	auipc	ra,0xffffc
    8000514a:	b30080e7          	jalr	-1232(ra) # 80000c76 <release>
  return i;
    8000514e:	b785                	j	800050ae <pipewrite+0x50>

0000000080005150 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005150:	715d                	addi	sp,sp,-80
    80005152:	e486                	sd	ra,72(sp)
    80005154:	e0a2                	sd	s0,64(sp)
    80005156:	fc26                	sd	s1,56(sp)
    80005158:	f84a                	sd	s2,48(sp)
    8000515a:	f44e                	sd	s3,40(sp)
    8000515c:	f052                	sd	s4,32(sp)
    8000515e:	ec56                	sd	s5,24(sp)
    80005160:	e85a                	sd	s6,16(sp)
    80005162:	0880                	addi	s0,sp,80
    80005164:	84aa                	mv	s1,a0
    80005166:	892e                	mv	s2,a1
    80005168:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000516a:	ffffd097          	auipc	ra,0xffffd
    8000516e:	85c080e7          	jalr	-1956(ra) # 800019c6 <myproc>
    80005172:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005174:	8526                	mv	a0,s1
    80005176:	ffffc097          	auipc	ra,0xffffc
    8000517a:	a4c080e7          	jalr	-1460(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000517e:	2184a703          	lw	a4,536(s1)
    80005182:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005186:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000518a:	02f71463          	bne	a4,a5,800051b2 <piperead+0x62>
    8000518e:	2244a783          	lw	a5,548(s1)
    80005192:	c385                	beqz	a5,800051b2 <piperead+0x62>
    if(pr->killed){
    80005194:	028a2783          	lw	a5,40(s4)
    80005198:	ebc1                	bnez	a5,80005228 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000519a:	85a6                	mv	a1,s1
    8000519c:	854e                	mv	a0,s3
    8000519e:	ffffd097          	auipc	ra,0xffffd
    800051a2:	1a2080e7          	jalr	418(ra) # 80002340 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800051a6:	2184a703          	lw	a4,536(s1)
    800051aa:	21c4a783          	lw	a5,540(s1)
    800051ae:	fef700e3          	beq	a4,a5,8000518e <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051b2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051b4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051b6:	05505363          	blez	s5,800051fc <piperead+0xac>
    if(pi->nread == pi->nwrite)
    800051ba:	2184a783          	lw	a5,536(s1)
    800051be:	21c4a703          	lw	a4,540(s1)
    800051c2:	02f70d63          	beq	a4,a5,800051fc <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800051c6:	0017871b          	addiw	a4,a5,1
    800051ca:	20e4ac23          	sw	a4,536(s1)
    800051ce:	1ff7f793          	andi	a5,a5,511
    800051d2:	97a6                	add	a5,a5,s1
    800051d4:	0187c783          	lbu	a5,24(a5)
    800051d8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051dc:	4685                	li	a3,1
    800051de:	fbf40613          	addi	a2,s0,-65
    800051e2:	85ca                	mv	a1,s2
    800051e4:	078a3503          	ld	a0,120(s4)
    800051e8:	ffffc097          	auipc	ra,0xffffc
    800051ec:	456080e7          	jalr	1110(ra) # 8000163e <copyout>
    800051f0:	01650663          	beq	a0,s6,800051fc <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051f4:	2985                	addiw	s3,s3,1
    800051f6:	0905                	addi	s2,s2,1
    800051f8:	fd3a91e3          	bne	s5,s3,800051ba <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800051fc:	21c48513          	addi	a0,s1,540
    80005200:	ffffd097          	auipc	ra,0xffffd
    80005204:	2cc080e7          	jalr	716(ra) # 800024cc <wakeup>
  release(&pi->lock);
    80005208:	8526                	mv	a0,s1
    8000520a:	ffffc097          	auipc	ra,0xffffc
    8000520e:	a6c080e7          	jalr	-1428(ra) # 80000c76 <release>
  return i;
}
    80005212:	854e                	mv	a0,s3
    80005214:	60a6                	ld	ra,72(sp)
    80005216:	6406                	ld	s0,64(sp)
    80005218:	74e2                	ld	s1,56(sp)
    8000521a:	7942                	ld	s2,48(sp)
    8000521c:	79a2                	ld	s3,40(sp)
    8000521e:	7a02                	ld	s4,32(sp)
    80005220:	6ae2                	ld	s5,24(sp)
    80005222:	6b42                	ld	s6,16(sp)
    80005224:	6161                	addi	sp,sp,80
    80005226:	8082                	ret
      release(&pi->lock);
    80005228:	8526                	mv	a0,s1
    8000522a:	ffffc097          	auipc	ra,0xffffc
    8000522e:	a4c080e7          	jalr	-1460(ra) # 80000c76 <release>
      return -1;
    80005232:	59fd                	li	s3,-1
    80005234:	bff9                	j	80005212 <piperead+0xc2>

0000000080005236 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005236:	de010113          	addi	sp,sp,-544
    8000523a:	20113c23          	sd	ra,536(sp)
    8000523e:	20813823          	sd	s0,528(sp)
    80005242:	20913423          	sd	s1,520(sp)
    80005246:	21213023          	sd	s2,512(sp)
    8000524a:	ffce                	sd	s3,504(sp)
    8000524c:	fbd2                	sd	s4,496(sp)
    8000524e:	f7d6                	sd	s5,488(sp)
    80005250:	f3da                	sd	s6,480(sp)
    80005252:	efde                	sd	s7,472(sp)
    80005254:	ebe2                	sd	s8,464(sp)
    80005256:	e7e6                	sd	s9,456(sp)
    80005258:	e3ea                	sd	s10,448(sp)
    8000525a:	ff6e                	sd	s11,440(sp)
    8000525c:	1400                	addi	s0,sp,544
    8000525e:	892a                	mv	s2,a0
    80005260:	dea43423          	sd	a0,-536(s0)
    80005264:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005268:	ffffc097          	auipc	ra,0xffffc
    8000526c:	75e080e7          	jalr	1886(ra) # 800019c6 <myproc>
    80005270:	84aa                	mv	s1,a0

  begin_op();
    80005272:	fffff097          	auipc	ra,0xfffff
    80005276:	4a6080e7          	jalr	1190(ra) # 80004718 <begin_op>

  if((ip = namei(path)) == 0){
    8000527a:	854a                	mv	a0,s2
    8000527c:	fffff097          	auipc	ra,0xfffff
    80005280:	27c080e7          	jalr	636(ra) # 800044f8 <namei>
    80005284:	c93d                	beqz	a0,800052fa <exec+0xc4>
    80005286:	8aaa                	mv	s5,a0
    end_op();
    /////////////////////////////we changed the return value in this case from -1
    return -2;
  }
  ilock(ip);
    80005288:	fffff097          	auipc	ra,0xfffff
    8000528c:	aba080e7          	jalr	-1350(ra) # 80003d42 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005290:	04000713          	li	a4,64
    80005294:	4681                	li	a3,0
    80005296:	e4840613          	addi	a2,s0,-440
    8000529a:	4581                	li	a1,0
    8000529c:	8556                	mv	a0,s5
    8000529e:	fffff097          	auipc	ra,0xfffff
    800052a2:	d58080e7          	jalr	-680(ra) # 80003ff6 <readi>
    800052a6:	04000793          	li	a5,64
    800052aa:	00f51a63          	bne	a0,a5,800052be <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800052ae:	e4842703          	lw	a4,-440(s0)
    800052b2:	464c47b7          	lui	a5,0x464c4
    800052b6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800052ba:	04f70663          	beq	a4,a5,80005306 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800052be:	8556                	mv	a0,s5
    800052c0:	fffff097          	auipc	ra,0xfffff
    800052c4:	ce4080e7          	jalr	-796(ra) # 80003fa4 <iunlockput>
    end_op();
    800052c8:	fffff097          	auipc	ra,0xfffff
    800052cc:	4d0080e7          	jalr	1232(ra) # 80004798 <end_op>
  }
  return -1;
    800052d0:	557d                	li	a0,-1
}
    800052d2:	21813083          	ld	ra,536(sp)
    800052d6:	21013403          	ld	s0,528(sp)
    800052da:	20813483          	ld	s1,520(sp)
    800052de:	20013903          	ld	s2,512(sp)
    800052e2:	79fe                	ld	s3,504(sp)
    800052e4:	7a5e                	ld	s4,496(sp)
    800052e6:	7abe                	ld	s5,488(sp)
    800052e8:	7b1e                	ld	s6,480(sp)
    800052ea:	6bfe                	ld	s7,472(sp)
    800052ec:	6c5e                	ld	s8,464(sp)
    800052ee:	6cbe                	ld	s9,456(sp)
    800052f0:	6d1e                	ld	s10,448(sp)
    800052f2:	7dfa                	ld	s11,440(sp)
    800052f4:	22010113          	addi	sp,sp,544
    800052f8:	8082                	ret
    end_op();
    800052fa:	fffff097          	auipc	ra,0xfffff
    800052fe:	49e080e7          	jalr	1182(ra) # 80004798 <end_op>
    return -2;
    80005302:	5579                	li	a0,-2
    80005304:	b7f9                	j	800052d2 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005306:	8526                	mv	a0,s1
    80005308:	ffffc097          	auipc	ra,0xffffc
    8000530c:	782080e7          	jalr	1922(ra) # 80001a8a <proc_pagetable>
    80005310:	8b2a                	mv	s6,a0
    80005312:	d555                	beqz	a0,800052be <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005314:	e6842783          	lw	a5,-408(s0)
    80005318:	e8045703          	lhu	a4,-384(s0)
    8000531c:	c735                	beqz	a4,80005388 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000531e:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005320:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005324:	6a05                	lui	s4,0x1
    80005326:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000532a:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    8000532e:	6d85                	lui	s11,0x1
    80005330:	7d7d                	lui	s10,0xfffff
    80005332:	ac1d                	j	80005568 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005334:	00003517          	auipc	a0,0x3
    80005338:	69450513          	addi	a0,a0,1684 # 800089c8 <syscalls+0x290>
    8000533c:	ffffb097          	auipc	ra,0xffffb
    80005340:	1ee080e7          	jalr	494(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005344:	874a                	mv	a4,s2
    80005346:	009c86bb          	addw	a3,s9,s1
    8000534a:	4581                	li	a1,0
    8000534c:	8556                	mv	a0,s5
    8000534e:	fffff097          	auipc	ra,0xfffff
    80005352:	ca8080e7          	jalr	-856(ra) # 80003ff6 <readi>
    80005356:	2501                	sext.w	a0,a0
    80005358:	1aa91863          	bne	s2,a0,80005508 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    8000535c:	009d84bb          	addw	s1,s11,s1
    80005360:	013d09bb          	addw	s3,s10,s3
    80005364:	1f74f263          	bgeu	s1,s7,80005548 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80005368:	02049593          	slli	a1,s1,0x20
    8000536c:	9181                	srli	a1,a1,0x20
    8000536e:	95e2                	add	a1,a1,s8
    80005370:	855a                	mv	a0,s6
    80005372:	ffffc097          	auipc	ra,0xffffc
    80005376:	cda080e7          	jalr	-806(ra) # 8000104c <walkaddr>
    8000537a:	862a                	mv	a2,a0
    if(pa == 0)
    8000537c:	dd45                	beqz	a0,80005334 <exec+0xfe>
      n = PGSIZE;
    8000537e:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005380:	fd49f2e3          	bgeu	s3,s4,80005344 <exec+0x10e>
      n = sz - i;
    80005384:	894e                	mv	s2,s3
    80005386:	bf7d                	j	80005344 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005388:	4481                	li	s1,0
  iunlockput(ip);
    8000538a:	8556                	mv	a0,s5
    8000538c:	fffff097          	auipc	ra,0xfffff
    80005390:	c18080e7          	jalr	-1000(ra) # 80003fa4 <iunlockput>
  end_op();
    80005394:	fffff097          	auipc	ra,0xfffff
    80005398:	404080e7          	jalr	1028(ra) # 80004798 <end_op>
  p = myproc();
    8000539c:	ffffc097          	auipc	ra,0xffffc
    800053a0:	62a080e7          	jalr	1578(ra) # 800019c6 <myproc>
    800053a4:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800053a6:	07053d03          	ld	s10,112(a0)
  sz = PGROUNDUP(sz);
    800053aa:	6785                	lui	a5,0x1
    800053ac:	17fd                	addi	a5,a5,-1
    800053ae:	94be                	add	s1,s1,a5
    800053b0:	77fd                	lui	a5,0xfffff
    800053b2:	8fe5                	and	a5,a5,s1
    800053b4:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800053b8:	6609                	lui	a2,0x2
    800053ba:	963e                	add	a2,a2,a5
    800053bc:	85be                	mv	a1,a5
    800053be:	855a                	mv	a0,s6
    800053c0:	ffffc097          	auipc	ra,0xffffc
    800053c4:	02e080e7          	jalr	46(ra) # 800013ee <uvmalloc>
    800053c8:	8c2a                	mv	s8,a0
  ip = 0;
    800053ca:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800053cc:	12050e63          	beqz	a0,80005508 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    800053d0:	75f9                	lui	a1,0xffffe
    800053d2:	95aa                	add	a1,a1,a0
    800053d4:	855a                	mv	a0,s6
    800053d6:	ffffc097          	auipc	ra,0xffffc
    800053da:	236080e7          	jalr	566(ra) # 8000160c <uvmclear>
  stackbase = sp - PGSIZE;
    800053de:	7afd                	lui	s5,0xfffff
    800053e0:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800053e2:	df043783          	ld	a5,-528(s0)
    800053e6:	6388                	ld	a0,0(a5)
    800053e8:	c925                	beqz	a0,80005458 <exec+0x222>
    800053ea:	e8840993          	addi	s3,s0,-376
    800053ee:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    800053f2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800053f4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800053f6:	ffffc097          	auipc	ra,0xffffc
    800053fa:	a4c080e7          	jalr	-1460(ra) # 80000e42 <strlen>
    800053fe:	0015079b          	addiw	a5,a0,1
    80005402:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005406:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000540a:	13596363          	bltu	s2,s5,80005530 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000540e:	df043d83          	ld	s11,-528(s0)
    80005412:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005416:	8552                	mv	a0,s4
    80005418:	ffffc097          	auipc	ra,0xffffc
    8000541c:	a2a080e7          	jalr	-1494(ra) # 80000e42 <strlen>
    80005420:	0015069b          	addiw	a3,a0,1
    80005424:	8652                	mv	a2,s4
    80005426:	85ca                	mv	a1,s2
    80005428:	855a                	mv	a0,s6
    8000542a:	ffffc097          	auipc	ra,0xffffc
    8000542e:	214080e7          	jalr	532(ra) # 8000163e <copyout>
    80005432:	10054363          	bltz	a0,80005538 <exec+0x302>
    ustack[argc] = sp;
    80005436:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000543a:	0485                	addi	s1,s1,1
    8000543c:	008d8793          	addi	a5,s11,8
    80005440:	def43823          	sd	a5,-528(s0)
    80005444:	008db503          	ld	a0,8(s11)
    80005448:	c911                	beqz	a0,8000545c <exec+0x226>
    if(argc >= MAXARG)
    8000544a:	09a1                	addi	s3,s3,8
    8000544c:	fb3c95e3          	bne	s9,s3,800053f6 <exec+0x1c0>
  sz = sz1;
    80005450:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005454:	4a81                	li	s5,0
    80005456:	a84d                	j	80005508 <exec+0x2d2>
  sp = sz;
    80005458:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000545a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000545c:	00349793          	slli	a5,s1,0x3
    80005460:	f9040713          	addi	a4,s0,-112
    80005464:	97ba                	add	a5,a5,a4
    80005466:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    8000546a:	00148693          	addi	a3,s1,1
    8000546e:	068e                	slli	a3,a3,0x3
    80005470:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005474:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005478:	01597663          	bgeu	s2,s5,80005484 <exec+0x24e>
  sz = sz1;
    8000547c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005480:	4a81                	li	s5,0
    80005482:	a059                	j	80005508 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005484:	e8840613          	addi	a2,s0,-376
    80005488:	85ca                	mv	a1,s2
    8000548a:	855a                	mv	a0,s6
    8000548c:	ffffc097          	auipc	ra,0xffffc
    80005490:	1b2080e7          	jalr	434(ra) # 8000163e <copyout>
    80005494:	0a054663          	bltz	a0,80005540 <exec+0x30a>
  p->trapframe->a1 = sp;
    80005498:	080bb783          	ld	a5,128(s7) # 1080 <_entry-0x7fffef80>
    8000549c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800054a0:	de843783          	ld	a5,-536(s0)
    800054a4:	0007c703          	lbu	a4,0(a5)
    800054a8:	cf11                	beqz	a4,800054c4 <exec+0x28e>
    800054aa:	0785                	addi	a5,a5,1
    if(*s == '/')
    800054ac:	02f00693          	li	a3,47
    800054b0:	a039                	j	800054be <exec+0x288>
      last = s+1;
    800054b2:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800054b6:	0785                	addi	a5,a5,1
    800054b8:	fff7c703          	lbu	a4,-1(a5)
    800054bc:	c701                	beqz	a4,800054c4 <exec+0x28e>
    if(*s == '/')
    800054be:	fed71ce3          	bne	a4,a3,800054b6 <exec+0x280>
    800054c2:	bfc5                	j	800054b2 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    800054c4:	4641                	li	a2,16
    800054c6:	de843583          	ld	a1,-536(s0)
    800054ca:	180b8513          	addi	a0,s7,384
    800054ce:	ffffc097          	auipc	ra,0xffffc
    800054d2:	942080e7          	jalr	-1726(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    800054d6:	078bb503          	ld	a0,120(s7)
  p->pagetable = pagetable;
    800054da:	076bbc23          	sd	s6,120(s7)
  p->sz = sz;
    800054de:	078bb823          	sd	s8,112(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800054e2:	080bb783          	ld	a5,128(s7)
    800054e6:	e6043703          	ld	a4,-416(s0)
    800054ea:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800054ec:	080bb783          	ld	a5,128(s7)
    800054f0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800054f4:	85ea                	mv	a1,s10
    800054f6:	ffffc097          	auipc	ra,0xffffc
    800054fa:	630080e7          	jalr	1584(ra) # 80001b26 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800054fe:	0004851b          	sext.w	a0,s1
    80005502:	bbc1                	j	800052d2 <exec+0x9c>
    80005504:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005508:	df843583          	ld	a1,-520(s0)
    8000550c:	855a                	mv	a0,s6
    8000550e:	ffffc097          	auipc	ra,0xffffc
    80005512:	618080e7          	jalr	1560(ra) # 80001b26 <proc_freepagetable>
  if(ip){
    80005516:	da0a94e3          	bnez	s5,800052be <exec+0x88>
  return -1;
    8000551a:	557d                	li	a0,-1
    8000551c:	bb5d                	j	800052d2 <exec+0x9c>
    8000551e:	de943c23          	sd	s1,-520(s0)
    80005522:	b7dd                	j	80005508 <exec+0x2d2>
    80005524:	de943c23          	sd	s1,-520(s0)
    80005528:	b7c5                	j	80005508 <exec+0x2d2>
    8000552a:	de943c23          	sd	s1,-520(s0)
    8000552e:	bfe9                	j	80005508 <exec+0x2d2>
  sz = sz1;
    80005530:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005534:	4a81                	li	s5,0
    80005536:	bfc9                	j	80005508 <exec+0x2d2>
  sz = sz1;
    80005538:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000553c:	4a81                	li	s5,0
    8000553e:	b7e9                	j	80005508 <exec+0x2d2>
  sz = sz1;
    80005540:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005544:	4a81                	li	s5,0
    80005546:	b7c9                	j	80005508 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005548:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000554c:	e0843783          	ld	a5,-504(s0)
    80005550:	0017869b          	addiw	a3,a5,1
    80005554:	e0d43423          	sd	a3,-504(s0)
    80005558:	e0043783          	ld	a5,-512(s0)
    8000555c:	0387879b          	addiw	a5,a5,56
    80005560:	e8045703          	lhu	a4,-384(s0)
    80005564:	e2e6d3e3          	bge	a3,a4,8000538a <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005568:	2781                	sext.w	a5,a5
    8000556a:	e0f43023          	sd	a5,-512(s0)
    8000556e:	03800713          	li	a4,56
    80005572:	86be                	mv	a3,a5
    80005574:	e1040613          	addi	a2,s0,-496
    80005578:	4581                	li	a1,0
    8000557a:	8556                	mv	a0,s5
    8000557c:	fffff097          	auipc	ra,0xfffff
    80005580:	a7a080e7          	jalr	-1414(ra) # 80003ff6 <readi>
    80005584:	03800793          	li	a5,56
    80005588:	f6f51ee3          	bne	a0,a5,80005504 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    8000558c:	e1042783          	lw	a5,-496(s0)
    80005590:	4705                	li	a4,1
    80005592:	fae79de3          	bne	a5,a4,8000554c <exec+0x316>
    if(ph.memsz < ph.filesz)
    80005596:	e3843603          	ld	a2,-456(s0)
    8000559a:	e3043783          	ld	a5,-464(s0)
    8000559e:	f8f660e3          	bltu	a2,a5,8000551e <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800055a2:	e2043783          	ld	a5,-480(s0)
    800055a6:	963e                	add	a2,a2,a5
    800055a8:	f6f66ee3          	bltu	a2,a5,80005524 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800055ac:	85a6                	mv	a1,s1
    800055ae:	855a                	mv	a0,s6
    800055b0:	ffffc097          	auipc	ra,0xffffc
    800055b4:	e3e080e7          	jalr	-450(ra) # 800013ee <uvmalloc>
    800055b8:	dea43c23          	sd	a0,-520(s0)
    800055bc:	d53d                	beqz	a0,8000552a <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    800055be:	e2043c03          	ld	s8,-480(s0)
    800055c2:	de043783          	ld	a5,-544(s0)
    800055c6:	00fc77b3          	and	a5,s8,a5
    800055ca:	ff9d                	bnez	a5,80005508 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800055cc:	e1842c83          	lw	s9,-488(s0)
    800055d0:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800055d4:	f60b8ae3          	beqz	s7,80005548 <exec+0x312>
    800055d8:	89de                	mv	s3,s7
    800055da:	4481                	li	s1,0
    800055dc:	b371                	j	80005368 <exec+0x132>

00000000800055de <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800055de:	7179                	addi	sp,sp,-48
    800055e0:	f406                	sd	ra,40(sp)
    800055e2:	f022                	sd	s0,32(sp)
    800055e4:	ec26                	sd	s1,24(sp)
    800055e6:	e84a                	sd	s2,16(sp)
    800055e8:	1800                	addi	s0,sp,48
    800055ea:	892e                	mv	s2,a1
    800055ec:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800055ee:	fdc40593          	addi	a1,s0,-36
    800055f2:	ffffe097          	auipc	ra,0xffffe
    800055f6:	a58080e7          	jalr	-1448(ra) # 8000304a <argint>
    800055fa:	04054063          	bltz	a0,8000563a <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800055fe:	fdc42703          	lw	a4,-36(s0)
    80005602:	47bd                	li	a5,15
    80005604:	02e7ed63          	bltu	a5,a4,8000563e <argfd+0x60>
    80005608:	ffffc097          	auipc	ra,0xffffc
    8000560c:	3be080e7          	jalr	958(ra) # 800019c6 <myproc>
    80005610:	fdc42703          	lw	a4,-36(s0)
    80005614:	01e70793          	addi	a5,a4,30
    80005618:	078e                	slli	a5,a5,0x3
    8000561a:	953e                	add	a0,a0,a5
    8000561c:	651c                	ld	a5,8(a0)
    8000561e:	c395                	beqz	a5,80005642 <argfd+0x64>
    return -1;
  if(pfd)
    80005620:	00090463          	beqz	s2,80005628 <argfd+0x4a>
    *pfd = fd;
    80005624:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005628:	4501                	li	a0,0
  if(pf)
    8000562a:	c091                	beqz	s1,8000562e <argfd+0x50>
    *pf = f;
    8000562c:	e09c                	sd	a5,0(s1)
}
    8000562e:	70a2                	ld	ra,40(sp)
    80005630:	7402                	ld	s0,32(sp)
    80005632:	64e2                	ld	s1,24(sp)
    80005634:	6942                	ld	s2,16(sp)
    80005636:	6145                	addi	sp,sp,48
    80005638:	8082                	ret
    return -1;
    8000563a:	557d                	li	a0,-1
    8000563c:	bfcd                	j	8000562e <argfd+0x50>
    return -1;
    8000563e:	557d                	li	a0,-1
    80005640:	b7fd                	j	8000562e <argfd+0x50>
    80005642:	557d                	li	a0,-1
    80005644:	b7ed                	j	8000562e <argfd+0x50>

0000000080005646 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005646:	1101                	addi	sp,sp,-32
    80005648:	ec06                	sd	ra,24(sp)
    8000564a:	e822                	sd	s0,16(sp)
    8000564c:	e426                	sd	s1,8(sp)
    8000564e:	1000                	addi	s0,sp,32
    80005650:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005652:	ffffc097          	auipc	ra,0xffffc
    80005656:	374080e7          	jalr	884(ra) # 800019c6 <myproc>
    8000565a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000565c:	0f850793          	addi	a5,a0,248
    80005660:	4501                	li	a0,0
    80005662:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005664:	6398                	ld	a4,0(a5)
    80005666:	cb19                	beqz	a4,8000567c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005668:	2505                	addiw	a0,a0,1
    8000566a:	07a1                	addi	a5,a5,8
    8000566c:	fed51ce3          	bne	a0,a3,80005664 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005670:	557d                	li	a0,-1
}
    80005672:	60e2                	ld	ra,24(sp)
    80005674:	6442                	ld	s0,16(sp)
    80005676:	64a2                	ld	s1,8(sp)
    80005678:	6105                	addi	sp,sp,32
    8000567a:	8082                	ret
      p->ofile[fd] = f;
    8000567c:	01e50793          	addi	a5,a0,30
    80005680:	078e                	slli	a5,a5,0x3
    80005682:	963e                	add	a2,a2,a5
    80005684:	e604                	sd	s1,8(a2)
      return fd;
    80005686:	b7f5                	j	80005672 <fdalloc+0x2c>

0000000080005688 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005688:	715d                	addi	sp,sp,-80
    8000568a:	e486                	sd	ra,72(sp)
    8000568c:	e0a2                	sd	s0,64(sp)
    8000568e:	fc26                	sd	s1,56(sp)
    80005690:	f84a                	sd	s2,48(sp)
    80005692:	f44e                	sd	s3,40(sp)
    80005694:	f052                	sd	s4,32(sp)
    80005696:	ec56                	sd	s5,24(sp)
    80005698:	0880                	addi	s0,sp,80
    8000569a:	89ae                	mv	s3,a1
    8000569c:	8ab2                	mv	s5,a2
    8000569e:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800056a0:	fb040593          	addi	a1,s0,-80
    800056a4:	fffff097          	auipc	ra,0xfffff
    800056a8:	e72080e7          	jalr	-398(ra) # 80004516 <nameiparent>
    800056ac:	892a                	mv	s2,a0
    800056ae:	12050e63          	beqz	a0,800057ea <create+0x162>
    return 0;

  ilock(dp);
    800056b2:	ffffe097          	auipc	ra,0xffffe
    800056b6:	690080e7          	jalr	1680(ra) # 80003d42 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800056ba:	4601                	li	a2,0
    800056bc:	fb040593          	addi	a1,s0,-80
    800056c0:	854a                	mv	a0,s2
    800056c2:	fffff097          	auipc	ra,0xfffff
    800056c6:	b64080e7          	jalr	-1180(ra) # 80004226 <dirlookup>
    800056ca:	84aa                	mv	s1,a0
    800056cc:	c921                	beqz	a0,8000571c <create+0x94>
    iunlockput(dp);
    800056ce:	854a                	mv	a0,s2
    800056d0:	fffff097          	auipc	ra,0xfffff
    800056d4:	8d4080e7          	jalr	-1836(ra) # 80003fa4 <iunlockput>
    ilock(ip);
    800056d8:	8526                	mv	a0,s1
    800056da:	ffffe097          	auipc	ra,0xffffe
    800056de:	668080e7          	jalr	1640(ra) # 80003d42 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800056e2:	2981                	sext.w	s3,s3
    800056e4:	4789                	li	a5,2
    800056e6:	02f99463          	bne	s3,a5,8000570e <create+0x86>
    800056ea:	0444d783          	lhu	a5,68(s1)
    800056ee:	37f9                	addiw	a5,a5,-2
    800056f0:	17c2                	slli	a5,a5,0x30
    800056f2:	93c1                	srli	a5,a5,0x30
    800056f4:	4705                	li	a4,1
    800056f6:	00f76c63          	bltu	a4,a5,8000570e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800056fa:	8526                	mv	a0,s1
    800056fc:	60a6                	ld	ra,72(sp)
    800056fe:	6406                	ld	s0,64(sp)
    80005700:	74e2                	ld	s1,56(sp)
    80005702:	7942                	ld	s2,48(sp)
    80005704:	79a2                	ld	s3,40(sp)
    80005706:	7a02                	ld	s4,32(sp)
    80005708:	6ae2                	ld	s5,24(sp)
    8000570a:	6161                	addi	sp,sp,80
    8000570c:	8082                	ret
    iunlockput(ip);
    8000570e:	8526                	mv	a0,s1
    80005710:	fffff097          	auipc	ra,0xfffff
    80005714:	894080e7          	jalr	-1900(ra) # 80003fa4 <iunlockput>
    return 0;
    80005718:	4481                	li	s1,0
    8000571a:	b7c5                	j	800056fa <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000571c:	85ce                	mv	a1,s3
    8000571e:	00092503          	lw	a0,0(s2)
    80005722:	ffffe097          	auipc	ra,0xffffe
    80005726:	488080e7          	jalr	1160(ra) # 80003baa <ialloc>
    8000572a:	84aa                	mv	s1,a0
    8000572c:	c521                	beqz	a0,80005774 <create+0xec>
  ilock(ip);
    8000572e:	ffffe097          	auipc	ra,0xffffe
    80005732:	614080e7          	jalr	1556(ra) # 80003d42 <ilock>
  ip->major = major;
    80005736:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000573a:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000573e:	4a05                	li	s4,1
    80005740:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005744:	8526                	mv	a0,s1
    80005746:	ffffe097          	auipc	ra,0xffffe
    8000574a:	532080e7          	jalr	1330(ra) # 80003c78 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000574e:	2981                	sext.w	s3,s3
    80005750:	03498a63          	beq	s3,s4,80005784 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005754:	40d0                	lw	a2,4(s1)
    80005756:	fb040593          	addi	a1,s0,-80
    8000575a:	854a                	mv	a0,s2
    8000575c:	fffff097          	auipc	ra,0xfffff
    80005760:	cda080e7          	jalr	-806(ra) # 80004436 <dirlink>
    80005764:	06054b63          	bltz	a0,800057da <create+0x152>
  iunlockput(dp);
    80005768:	854a                	mv	a0,s2
    8000576a:	fffff097          	auipc	ra,0xfffff
    8000576e:	83a080e7          	jalr	-1990(ra) # 80003fa4 <iunlockput>
  return ip;
    80005772:	b761                	j	800056fa <create+0x72>
    panic("create: ialloc");
    80005774:	00003517          	auipc	a0,0x3
    80005778:	27450513          	addi	a0,a0,628 # 800089e8 <syscalls+0x2b0>
    8000577c:	ffffb097          	auipc	ra,0xffffb
    80005780:	dae080e7          	jalr	-594(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    80005784:	04a95783          	lhu	a5,74(s2)
    80005788:	2785                	addiw	a5,a5,1
    8000578a:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000578e:	854a                	mv	a0,s2
    80005790:	ffffe097          	auipc	ra,0xffffe
    80005794:	4e8080e7          	jalr	1256(ra) # 80003c78 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005798:	40d0                	lw	a2,4(s1)
    8000579a:	00003597          	auipc	a1,0x3
    8000579e:	25e58593          	addi	a1,a1,606 # 800089f8 <syscalls+0x2c0>
    800057a2:	8526                	mv	a0,s1
    800057a4:	fffff097          	auipc	ra,0xfffff
    800057a8:	c92080e7          	jalr	-878(ra) # 80004436 <dirlink>
    800057ac:	00054f63          	bltz	a0,800057ca <create+0x142>
    800057b0:	00492603          	lw	a2,4(s2)
    800057b4:	00003597          	auipc	a1,0x3
    800057b8:	24c58593          	addi	a1,a1,588 # 80008a00 <syscalls+0x2c8>
    800057bc:	8526                	mv	a0,s1
    800057be:	fffff097          	auipc	ra,0xfffff
    800057c2:	c78080e7          	jalr	-904(ra) # 80004436 <dirlink>
    800057c6:	f80557e3          	bgez	a0,80005754 <create+0xcc>
      panic("create dots");
    800057ca:	00003517          	auipc	a0,0x3
    800057ce:	23e50513          	addi	a0,a0,574 # 80008a08 <syscalls+0x2d0>
    800057d2:	ffffb097          	auipc	ra,0xffffb
    800057d6:	d58080e7          	jalr	-680(ra) # 8000052a <panic>
    panic("create: dirlink");
    800057da:	00003517          	auipc	a0,0x3
    800057de:	23e50513          	addi	a0,a0,574 # 80008a18 <syscalls+0x2e0>
    800057e2:	ffffb097          	auipc	ra,0xffffb
    800057e6:	d48080e7          	jalr	-696(ra) # 8000052a <panic>
    return 0;
    800057ea:	84aa                	mv	s1,a0
    800057ec:	b739                	j	800056fa <create+0x72>

00000000800057ee <sys_dup>:
{
    800057ee:	7179                	addi	sp,sp,-48
    800057f0:	f406                	sd	ra,40(sp)
    800057f2:	f022                	sd	s0,32(sp)
    800057f4:	ec26                	sd	s1,24(sp)
    800057f6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800057f8:	fd840613          	addi	a2,s0,-40
    800057fc:	4581                	li	a1,0
    800057fe:	4501                	li	a0,0
    80005800:	00000097          	auipc	ra,0x0
    80005804:	dde080e7          	jalr	-546(ra) # 800055de <argfd>
    return -1;
    80005808:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000580a:	02054363          	bltz	a0,80005830 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000580e:	fd843503          	ld	a0,-40(s0)
    80005812:	00000097          	auipc	ra,0x0
    80005816:	e34080e7          	jalr	-460(ra) # 80005646 <fdalloc>
    8000581a:	84aa                	mv	s1,a0
    return -1;
    8000581c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000581e:	00054963          	bltz	a0,80005830 <sys_dup+0x42>
  filedup(f);
    80005822:	fd843503          	ld	a0,-40(s0)
    80005826:	fffff097          	auipc	ra,0xfffff
    8000582a:	36c080e7          	jalr	876(ra) # 80004b92 <filedup>
  return fd;
    8000582e:	87a6                	mv	a5,s1
}
    80005830:	853e                	mv	a0,a5
    80005832:	70a2                	ld	ra,40(sp)
    80005834:	7402                	ld	s0,32(sp)
    80005836:	64e2                	ld	s1,24(sp)
    80005838:	6145                	addi	sp,sp,48
    8000583a:	8082                	ret

000000008000583c <sys_read>:
{
    8000583c:	7179                	addi	sp,sp,-48
    8000583e:	f406                	sd	ra,40(sp)
    80005840:	f022                	sd	s0,32(sp)
    80005842:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005844:	fe840613          	addi	a2,s0,-24
    80005848:	4581                	li	a1,0
    8000584a:	4501                	li	a0,0
    8000584c:	00000097          	auipc	ra,0x0
    80005850:	d92080e7          	jalr	-622(ra) # 800055de <argfd>
    return -1;
    80005854:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005856:	04054163          	bltz	a0,80005898 <sys_read+0x5c>
    8000585a:	fe440593          	addi	a1,s0,-28
    8000585e:	4509                	li	a0,2
    80005860:	ffffd097          	auipc	ra,0xffffd
    80005864:	7ea080e7          	jalr	2026(ra) # 8000304a <argint>
    return -1;
    80005868:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000586a:	02054763          	bltz	a0,80005898 <sys_read+0x5c>
    8000586e:	fd840593          	addi	a1,s0,-40
    80005872:	4505                	li	a0,1
    80005874:	ffffd097          	auipc	ra,0xffffd
    80005878:	7f8080e7          	jalr	2040(ra) # 8000306c <argaddr>
    return -1;
    8000587c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000587e:	00054d63          	bltz	a0,80005898 <sys_read+0x5c>
  return fileread(f, p, n);
    80005882:	fe442603          	lw	a2,-28(s0)
    80005886:	fd843583          	ld	a1,-40(s0)
    8000588a:	fe843503          	ld	a0,-24(s0)
    8000588e:	fffff097          	auipc	ra,0xfffff
    80005892:	490080e7          	jalr	1168(ra) # 80004d1e <fileread>
    80005896:	87aa                	mv	a5,a0
}
    80005898:	853e                	mv	a0,a5
    8000589a:	70a2                	ld	ra,40(sp)
    8000589c:	7402                	ld	s0,32(sp)
    8000589e:	6145                	addi	sp,sp,48
    800058a0:	8082                	ret

00000000800058a2 <sys_write>:
{
    800058a2:	7179                	addi	sp,sp,-48
    800058a4:	f406                	sd	ra,40(sp)
    800058a6:	f022                	sd	s0,32(sp)
    800058a8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058aa:	fe840613          	addi	a2,s0,-24
    800058ae:	4581                	li	a1,0
    800058b0:	4501                	li	a0,0
    800058b2:	00000097          	auipc	ra,0x0
    800058b6:	d2c080e7          	jalr	-724(ra) # 800055de <argfd>
    return -1;
    800058ba:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058bc:	04054163          	bltz	a0,800058fe <sys_write+0x5c>
    800058c0:	fe440593          	addi	a1,s0,-28
    800058c4:	4509                	li	a0,2
    800058c6:	ffffd097          	auipc	ra,0xffffd
    800058ca:	784080e7          	jalr	1924(ra) # 8000304a <argint>
    return -1;
    800058ce:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058d0:	02054763          	bltz	a0,800058fe <sys_write+0x5c>
    800058d4:	fd840593          	addi	a1,s0,-40
    800058d8:	4505                	li	a0,1
    800058da:	ffffd097          	auipc	ra,0xffffd
    800058de:	792080e7          	jalr	1938(ra) # 8000306c <argaddr>
    return -1;
    800058e2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058e4:	00054d63          	bltz	a0,800058fe <sys_write+0x5c>
  return filewrite(f, p, n);
    800058e8:	fe442603          	lw	a2,-28(s0)
    800058ec:	fd843583          	ld	a1,-40(s0)
    800058f0:	fe843503          	ld	a0,-24(s0)
    800058f4:	fffff097          	auipc	ra,0xfffff
    800058f8:	4ec080e7          	jalr	1260(ra) # 80004de0 <filewrite>
    800058fc:	87aa                	mv	a5,a0
}
    800058fe:	853e                	mv	a0,a5
    80005900:	70a2                	ld	ra,40(sp)
    80005902:	7402                	ld	s0,32(sp)
    80005904:	6145                	addi	sp,sp,48
    80005906:	8082                	ret

0000000080005908 <sys_close>:
{
    80005908:	1101                	addi	sp,sp,-32
    8000590a:	ec06                	sd	ra,24(sp)
    8000590c:	e822                	sd	s0,16(sp)
    8000590e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005910:	fe040613          	addi	a2,s0,-32
    80005914:	fec40593          	addi	a1,s0,-20
    80005918:	4501                	li	a0,0
    8000591a:	00000097          	auipc	ra,0x0
    8000591e:	cc4080e7          	jalr	-828(ra) # 800055de <argfd>
    return -1;
    80005922:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005924:	02054463          	bltz	a0,8000594c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005928:	ffffc097          	auipc	ra,0xffffc
    8000592c:	09e080e7          	jalr	158(ra) # 800019c6 <myproc>
    80005930:	fec42783          	lw	a5,-20(s0)
    80005934:	07f9                	addi	a5,a5,30
    80005936:	078e                	slli	a5,a5,0x3
    80005938:	97aa                	add	a5,a5,a0
    8000593a:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    8000593e:	fe043503          	ld	a0,-32(s0)
    80005942:	fffff097          	auipc	ra,0xfffff
    80005946:	2a2080e7          	jalr	674(ra) # 80004be4 <fileclose>
  return 0;
    8000594a:	4781                	li	a5,0
}
    8000594c:	853e                	mv	a0,a5
    8000594e:	60e2                	ld	ra,24(sp)
    80005950:	6442                	ld	s0,16(sp)
    80005952:	6105                	addi	sp,sp,32
    80005954:	8082                	ret

0000000080005956 <sys_fstat>:
{
    80005956:	1101                	addi	sp,sp,-32
    80005958:	ec06                	sd	ra,24(sp)
    8000595a:	e822                	sd	s0,16(sp)
    8000595c:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000595e:	fe840613          	addi	a2,s0,-24
    80005962:	4581                	li	a1,0
    80005964:	4501                	li	a0,0
    80005966:	00000097          	auipc	ra,0x0
    8000596a:	c78080e7          	jalr	-904(ra) # 800055de <argfd>
    return -1;
    8000596e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005970:	02054563          	bltz	a0,8000599a <sys_fstat+0x44>
    80005974:	fe040593          	addi	a1,s0,-32
    80005978:	4505                	li	a0,1
    8000597a:	ffffd097          	auipc	ra,0xffffd
    8000597e:	6f2080e7          	jalr	1778(ra) # 8000306c <argaddr>
    return -1;
    80005982:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005984:	00054b63          	bltz	a0,8000599a <sys_fstat+0x44>
  return filestat(f, st);
    80005988:	fe043583          	ld	a1,-32(s0)
    8000598c:	fe843503          	ld	a0,-24(s0)
    80005990:	fffff097          	auipc	ra,0xfffff
    80005994:	31c080e7          	jalr	796(ra) # 80004cac <filestat>
    80005998:	87aa                	mv	a5,a0
}
    8000599a:	853e                	mv	a0,a5
    8000599c:	60e2                	ld	ra,24(sp)
    8000599e:	6442                	ld	s0,16(sp)
    800059a0:	6105                	addi	sp,sp,32
    800059a2:	8082                	ret

00000000800059a4 <sys_link>:
{
    800059a4:	7169                	addi	sp,sp,-304
    800059a6:	f606                	sd	ra,296(sp)
    800059a8:	f222                	sd	s0,288(sp)
    800059aa:	ee26                	sd	s1,280(sp)
    800059ac:	ea4a                	sd	s2,272(sp)
    800059ae:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059b0:	08000613          	li	a2,128
    800059b4:	ed040593          	addi	a1,s0,-304
    800059b8:	4501                	li	a0,0
    800059ba:	ffffd097          	auipc	ra,0xffffd
    800059be:	6d4080e7          	jalr	1748(ra) # 8000308e <argstr>
    return -1;
    800059c2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059c4:	10054e63          	bltz	a0,80005ae0 <sys_link+0x13c>
    800059c8:	08000613          	li	a2,128
    800059cc:	f5040593          	addi	a1,s0,-176
    800059d0:	4505                	li	a0,1
    800059d2:	ffffd097          	auipc	ra,0xffffd
    800059d6:	6bc080e7          	jalr	1724(ra) # 8000308e <argstr>
    return -1;
    800059da:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059dc:	10054263          	bltz	a0,80005ae0 <sys_link+0x13c>
  begin_op();
    800059e0:	fffff097          	auipc	ra,0xfffff
    800059e4:	d38080e7          	jalr	-712(ra) # 80004718 <begin_op>
  if((ip = namei(old)) == 0){
    800059e8:	ed040513          	addi	a0,s0,-304
    800059ec:	fffff097          	auipc	ra,0xfffff
    800059f0:	b0c080e7          	jalr	-1268(ra) # 800044f8 <namei>
    800059f4:	84aa                	mv	s1,a0
    800059f6:	c551                	beqz	a0,80005a82 <sys_link+0xde>
  ilock(ip);
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	34a080e7          	jalr	842(ra) # 80003d42 <ilock>
  if(ip->type == T_DIR){
    80005a00:	04449703          	lh	a4,68(s1)
    80005a04:	4785                	li	a5,1
    80005a06:	08f70463          	beq	a4,a5,80005a8e <sys_link+0xea>
  ip->nlink++;
    80005a0a:	04a4d783          	lhu	a5,74(s1)
    80005a0e:	2785                	addiw	a5,a5,1
    80005a10:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a14:	8526                	mv	a0,s1
    80005a16:	ffffe097          	auipc	ra,0xffffe
    80005a1a:	262080e7          	jalr	610(ra) # 80003c78 <iupdate>
  iunlock(ip);
    80005a1e:	8526                	mv	a0,s1
    80005a20:	ffffe097          	auipc	ra,0xffffe
    80005a24:	3e4080e7          	jalr	996(ra) # 80003e04 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005a28:	fd040593          	addi	a1,s0,-48
    80005a2c:	f5040513          	addi	a0,s0,-176
    80005a30:	fffff097          	auipc	ra,0xfffff
    80005a34:	ae6080e7          	jalr	-1306(ra) # 80004516 <nameiparent>
    80005a38:	892a                	mv	s2,a0
    80005a3a:	c935                	beqz	a0,80005aae <sys_link+0x10a>
  ilock(dp);
    80005a3c:	ffffe097          	auipc	ra,0xffffe
    80005a40:	306080e7          	jalr	774(ra) # 80003d42 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005a44:	00092703          	lw	a4,0(s2)
    80005a48:	409c                	lw	a5,0(s1)
    80005a4a:	04f71d63          	bne	a4,a5,80005aa4 <sys_link+0x100>
    80005a4e:	40d0                	lw	a2,4(s1)
    80005a50:	fd040593          	addi	a1,s0,-48
    80005a54:	854a                	mv	a0,s2
    80005a56:	fffff097          	auipc	ra,0xfffff
    80005a5a:	9e0080e7          	jalr	-1568(ra) # 80004436 <dirlink>
    80005a5e:	04054363          	bltz	a0,80005aa4 <sys_link+0x100>
  iunlockput(dp);
    80005a62:	854a                	mv	a0,s2
    80005a64:	ffffe097          	auipc	ra,0xffffe
    80005a68:	540080e7          	jalr	1344(ra) # 80003fa4 <iunlockput>
  iput(ip);
    80005a6c:	8526                	mv	a0,s1
    80005a6e:	ffffe097          	auipc	ra,0xffffe
    80005a72:	48e080e7          	jalr	1166(ra) # 80003efc <iput>
  end_op();
    80005a76:	fffff097          	auipc	ra,0xfffff
    80005a7a:	d22080e7          	jalr	-734(ra) # 80004798 <end_op>
  return 0;
    80005a7e:	4781                	li	a5,0
    80005a80:	a085                	j	80005ae0 <sys_link+0x13c>
    end_op();
    80005a82:	fffff097          	auipc	ra,0xfffff
    80005a86:	d16080e7          	jalr	-746(ra) # 80004798 <end_op>
    return -1;
    80005a8a:	57fd                	li	a5,-1
    80005a8c:	a891                	j	80005ae0 <sys_link+0x13c>
    iunlockput(ip);
    80005a8e:	8526                	mv	a0,s1
    80005a90:	ffffe097          	auipc	ra,0xffffe
    80005a94:	514080e7          	jalr	1300(ra) # 80003fa4 <iunlockput>
    end_op();
    80005a98:	fffff097          	auipc	ra,0xfffff
    80005a9c:	d00080e7          	jalr	-768(ra) # 80004798 <end_op>
    return -1;
    80005aa0:	57fd                	li	a5,-1
    80005aa2:	a83d                	j	80005ae0 <sys_link+0x13c>
    iunlockput(dp);
    80005aa4:	854a                	mv	a0,s2
    80005aa6:	ffffe097          	auipc	ra,0xffffe
    80005aaa:	4fe080e7          	jalr	1278(ra) # 80003fa4 <iunlockput>
  ilock(ip);
    80005aae:	8526                	mv	a0,s1
    80005ab0:	ffffe097          	auipc	ra,0xffffe
    80005ab4:	292080e7          	jalr	658(ra) # 80003d42 <ilock>
  ip->nlink--;
    80005ab8:	04a4d783          	lhu	a5,74(s1)
    80005abc:	37fd                	addiw	a5,a5,-1
    80005abe:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ac2:	8526                	mv	a0,s1
    80005ac4:	ffffe097          	auipc	ra,0xffffe
    80005ac8:	1b4080e7          	jalr	436(ra) # 80003c78 <iupdate>
  iunlockput(ip);
    80005acc:	8526                	mv	a0,s1
    80005ace:	ffffe097          	auipc	ra,0xffffe
    80005ad2:	4d6080e7          	jalr	1238(ra) # 80003fa4 <iunlockput>
  end_op();
    80005ad6:	fffff097          	auipc	ra,0xfffff
    80005ada:	cc2080e7          	jalr	-830(ra) # 80004798 <end_op>
  return -1;
    80005ade:	57fd                	li	a5,-1
}
    80005ae0:	853e                	mv	a0,a5
    80005ae2:	70b2                	ld	ra,296(sp)
    80005ae4:	7412                	ld	s0,288(sp)
    80005ae6:	64f2                	ld	s1,280(sp)
    80005ae8:	6952                	ld	s2,272(sp)
    80005aea:	6155                	addi	sp,sp,304
    80005aec:	8082                	ret

0000000080005aee <sys_unlink>:
{
    80005aee:	7151                	addi	sp,sp,-240
    80005af0:	f586                	sd	ra,232(sp)
    80005af2:	f1a2                	sd	s0,224(sp)
    80005af4:	eda6                	sd	s1,216(sp)
    80005af6:	e9ca                	sd	s2,208(sp)
    80005af8:	e5ce                	sd	s3,200(sp)
    80005afa:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005afc:	08000613          	li	a2,128
    80005b00:	f3040593          	addi	a1,s0,-208
    80005b04:	4501                	li	a0,0
    80005b06:	ffffd097          	auipc	ra,0xffffd
    80005b0a:	588080e7          	jalr	1416(ra) # 8000308e <argstr>
    80005b0e:	18054163          	bltz	a0,80005c90 <sys_unlink+0x1a2>
  begin_op();
    80005b12:	fffff097          	auipc	ra,0xfffff
    80005b16:	c06080e7          	jalr	-1018(ra) # 80004718 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005b1a:	fb040593          	addi	a1,s0,-80
    80005b1e:	f3040513          	addi	a0,s0,-208
    80005b22:	fffff097          	auipc	ra,0xfffff
    80005b26:	9f4080e7          	jalr	-1548(ra) # 80004516 <nameiparent>
    80005b2a:	84aa                	mv	s1,a0
    80005b2c:	c979                	beqz	a0,80005c02 <sys_unlink+0x114>
  ilock(dp);
    80005b2e:	ffffe097          	auipc	ra,0xffffe
    80005b32:	214080e7          	jalr	532(ra) # 80003d42 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005b36:	00003597          	auipc	a1,0x3
    80005b3a:	ec258593          	addi	a1,a1,-318 # 800089f8 <syscalls+0x2c0>
    80005b3e:	fb040513          	addi	a0,s0,-80
    80005b42:	ffffe097          	auipc	ra,0xffffe
    80005b46:	6ca080e7          	jalr	1738(ra) # 8000420c <namecmp>
    80005b4a:	14050a63          	beqz	a0,80005c9e <sys_unlink+0x1b0>
    80005b4e:	00003597          	auipc	a1,0x3
    80005b52:	eb258593          	addi	a1,a1,-334 # 80008a00 <syscalls+0x2c8>
    80005b56:	fb040513          	addi	a0,s0,-80
    80005b5a:	ffffe097          	auipc	ra,0xffffe
    80005b5e:	6b2080e7          	jalr	1714(ra) # 8000420c <namecmp>
    80005b62:	12050e63          	beqz	a0,80005c9e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005b66:	f2c40613          	addi	a2,s0,-212
    80005b6a:	fb040593          	addi	a1,s0,-80
    80005b6e:	8526                	mv	a0,s1
    80005b70:	ffffe097          	auipc	ra,0xffffe
    80005b74:	6b6080e7          	jalr	1718(ra) # 80004226 <dirlookup>
    80005b78:	892a                	mv	s2,a0
    80005b7a:	12050263          	beqz	a0,80005c9e <sys_unlink+0x1b0>
  ilock(ip);
    80005b7e:	ffffe097          	auipc	ra,0xffffe
    80005b82:	1c4080e7          	jalr	452(ra) # 80003d42 <ilock>
  if(ip->nlink < 1)
    80005b86:	04a91783          	lh	a5,74(s2)
    80005b8a:	08f05263          	blez	a5,80005c0e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005b8e:	04491703          	lh	a4,68(s2)
    80005b92:	4785                	li	a5,1
    80005b94:	08f70563          	beq	a4,a5,80005c1e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005b98:	4641                	li	a2,16
    80005b9a:	4581                	li	a1,0
    80005b9c:	fc040513          	addi	a0,s0,-64
    80005ba0:	ffffb097          	auipc	ra,0xffffb
    80005ba4:	11e080e7          	jalr	286(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ba8:	4741                	li	a4,16
    80005baa:	f2c42683          	lw	a3,-212(s0)
    80005bae:	fc040613          	addi	a2,s0,-64
    80005bb2:	4581                	li	a1,0
    80005bb4:	8526                	mv	a0,s1
    80005bb6:	ffffe097          	auipc	ra,0xffffe
    80005bba:	538080e7          	jalr	1336(ra) # 800040ee <writei>
    80005bbe:	47c1                	li	a5,16
    80005bc0:	0af51563          	bne	a0,a5,80005c6a <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005bc4:	04491703          	lh	a4,68(s2)
    80005bc8:	4785                	li	a5,1
    80005bca:	0af70863          	beq	a4,a5,80005c7a <sys_unlink+0x18c>
  iunlockput(dp);
    80005bce:	8526                	mv	a0,s1
    80005bd0:	ffffe097          	auipc	ra,0xffffe
    80005bd4:	3d4080e7          	jalr	980(ra) # 80003fa4 <iunlockput>
  ip->nlink--;
    80005bd8:	04a95783          	lhu	a5,74(s2)
    80005bdc:	37fd                	addiw	a5,a5,-1
    80005bde:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005be2:	854a                	mv	a0,s2
    80005be4:	ffffe097          	auipc	ra,0xffffe
    80005be8:	094080e7          	jalr	148(ra) # 80003c78 <iupdate>
  iunlockput(ip);
    80005bec:	854a                	mv	a0,s2
    80005bee:	ffffe097          	auipc	ra,0xffffe
    80005bf2:	3b6080e7          	jalr	950(ra) # 80003fa4 <iunlockput>
  end_op();
    80005bf6:	fffff097          	auipc	ra,0xfffff
    80005bfa:	ba2080e7          	jalr	-1118(ra) # 80004798 <end_op>
  return 0;
    80005bfe:	4501                	li	a0,0
    80005c00:	a84d                	j	80005cb2 <sys_unlink+0x1c4>
    end_op();
    80005c02:	fffff097          	auipc	ra,0xfffff
    80005c06:	b96080e7          	jalr	-1130(ra) # 80004798 <end_op>
    return -1;
    80005c0a:	557d                	li	a0,-1
    80005c0c:	a05d                	j	80005cb2 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005c0e:	00003517          	auipc	a0,0x3
    80005c12:	e1a50513          	addi	a0,a0,-486 # 80008a28 <syscalls+0x2f0>
    80005c16:	ffffb097          	auipc	ra,0xffffb
    80005c1a:	914080e7          	jalr	-1772(ra) # 8000052a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c1e:	04c92703          	lw	a4,76(s2)
    80005c22:	02000793          	li	a5,32
    80005c26:	f6e7f9e3          	bgeu	a5,a4,80005b98 <sys_unlink+0xaa>
    80005c2a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c2e:	4741                	li	a4,16
    80005c30:	86ce                	mv	a3,s3
    80005c32:	f1840613          	addi	a2,s0,-232
    80005c36:	4581                	li	a1,0
    80005c38:	854a                	mv	a0,s2
    80005c3a:	ffffe097          	auipc	ra,0xffffe
    80005c3e:	3bc080e7          	jalr	956(ra) # 80003ff6 <readi>
    80005c42:	47c1                	li	a5,16
    80005c44:	00f51b63          	bne	a0,a5,80005c5a <sys_unlink+0x16c>
    if(de.inum != 0)
    80005c48:	f1845783          	lhu	a5,-232(s0)
    80005c4c:	e7a1                	bnez	a5,80005c94 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c4e:	29c1                	addiw	s3,s3,16
    80005c50:	04c92783          	lw	a5,76(s2)
    80005c54:	fcf9ede3          	bltu	s3,a5,80005c2e <sys_unlink+0x140>
    80005c58:	b781                	j	80005b98 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005c5a:	00003517          	auipc	a0,0x3
    80005c5e:	de650513          	addi	a0,a0,-538 # 80008a40 <syscalls+0x308>
    80005c62:	ffffb097          	auipc	ra,0xffffb
    80005c66:	8c8080e7          	jalr	-1848(ra) # 8000052a <panic>
    panic("unlink: writei");
    80005c6a:	00003517          	auipc	a0,0x3
    80005c6e:	dee50513          	addi	a0,a0,-530 # 80008a58 <syscalls+0x320>
    80005c72:	ffffb097          	auipc	ra,0xffffb
    80005c76:	8b8080e7          	jalr	-1864(ra) # 8000052a <panic>
    dp->nlink--;
    80005c7a:	04a4d783          	lhu	a5,74(s1)
    80005c7e:	37fd                	addiw	a5,a5,-1
    80005c80:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c84:	8526                	mv	a0,s1
    80005c86:	ffffe097          	auipc	ra,0xffffe
    80005c8a:	ff2080e7          	jalr	-14(ra) # 80003c78 <iupdate>
    80005c8e:	b781                	j	80005bce <sys_unlink+0xe0>
    return -1;
    80005c90:	557d                	li	a0,-1
    80005c92:	a005                	j	80005cb2 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005c94:	854a                	mv	a0,s2
    80005c96:	ffffe097          	auipc	ra,0xffffe
    80005c9a:	30e080e7          	jalr	782(ra) # 80003fa4 <iunlockput>
  iunlockput(dp);
    80005c9e:	8526                	mv	a0,s1
    80005ca0:	ffffe097          	auipc	ra,0xffffe
    80005ca4:	304080e7          	jalr	772(ra) # 80003fa4 <iunlockput>
  end_op();
    80005ca8:	fffff097          	auipc	ra,0xfffff
    80005cac:	af0080e7          	jalr	-1296(ra) # 80004798 <end_op>
  return -1;
    80005cb0:	557d                	li	a0,-1
}
    80005cb2:	70ae                	ld	ra,232(sp)
    80005cb4:	740e                	ld	s0,224(sp)
    80005cb6:	64ee                	ld	s1,216(sp)
    80005cb8:	694e                	ld	s2,208(sp)
    80005cba:	69ae                	ld	s3,200(sp)
    80005cbc:	616d                	addi	sp,sp,240
    80005cbe:	8082                	ret

0000000080005cc0 <sys_open>:

uint64
sys_open(void)
{
    80005cc0:	7131                	addi	sp,sp,-192
    80005cc2:	fd06                	sd	ra,184(sp)
    80005cc4:	f922                	sd	s0,176(sp)
    80005cc6:	f526                	sd	s1,168(sp)
    80005cc8:	f14a                	sd	s2,160(sp)
    80005cca:	ed4e                	sd	s3,152(sp)
    80005ccc:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005cce:	08000613          	li	a2,128
    80005cd2:	f5040593          	addi	a1,s0,-176
    80005cd6:	4501                	li	a0,0
    80005cd8:	ffffd097          	auipc	ra,0xffffd
    80005cdc:	3b6080e7          	jalr	950(ra) # 8000308e <argstr>
    return -1;
    80005ce0:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005ce2:	0c054163          	bltz	a0,80005da4 <sys_open+0xe4>
    80005ce6:	f4c40593          	addi	a1,s0,-180
    80005cea:	4505                	li	a0,1
    80005cec:	ffffd097          	auipc	ra,0xffffd
    80005cf0:	35e080e7          	jalr	862(ra) # 8000304a <argint>
    80005cf4:	0a054863          	bltz	a0,80005da4 <sys_open+0xe4>

  begin_op();
    80005cf8:	fffff097          	auipc	ra,0xfffff
    80005cfc:	a20080e7          	jalr	-1504(ra) # 80004718 <begin_op>

  if(omode & O_CREATE){
    80005d00:	f4c42783          	lw	a5,-180(s0)
    80005d04:	2007f793          	andi	a5,a5,512
    80005d08:	cbdd                	beqz	a5,80005dbe <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005d0a:	4681                	li	a3,0
    80005d0c:	4601                	li	a2,0
    80005d0e:	4589                	li	a1,2
    80005d10:	f5040513          	addi	a0,s0,-176
    80005d14:	00000097          	auipc	ra,0x0
    80005d18:	974080e7          	jalr	-1676(ra) # 80005688 <create>
    80005d1c:	892a                	mv	s2,a0
    if(ip == 0){
    80005d1e:	c959                	beqz	a0,80005db4 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005d20:	04491703          	lh	a4,68(s2)
    80005d24:	478d                	li	a5,3
    80005d26:	00f71763          	bne	a4,a5,80005d34 <sys_open+0x74>
    80005d2a:	04695703          	lhu	a4,70(s2)
    80005d2e:	47a5                	li	a5,9
    80005d30:	0ce7ec63          	bltu	a5,a4,80005e08 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005d34:	fffff097          	auipc	ra,0xfffff
    80005d38:	df4080e7          	jalr	-524(ra) # 80004b28 <filealloc>
    80005d3c:	89aa                	mv	s3,a0
    80005d3e:	10050263          	beqz	a0,80005e42 <sys_open+0x182>
    80005d42:	00000097          	auipc	ra,0x0
    80005d46:	904080e7          	jalr	-1788(ra) # 80005646 <fdalloc>
    80005d4a:	84aa                	mv	s1,a0
    80005d4c:	0e054663          	bltz	a0,80005e38 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005d50:	04491703          	lh	a4,68(s2)
    80005d54:	478d                	li	a5,3
    80005d56:	0cf70463          	beq	a4,a5,80005e1e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005d5a:	4789                	li	a5,2
    80005d5c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005d60:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005d64:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005d68:	f4c42783          	lw	a5,-180(s0)
    80005d6c:	0017c713          	xori	a4,a5,1
    80005d70:	8b05                	andi	a4,a4,1
    80005d72:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005d76:	0037f713          	andi	a4,a5,3
    80005d7a:	00e03733          	snez	a4,a4
    80005d7e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005d82:	4007f793          	andi	a5,a5,1024
    80005d86:	c791                	beqz	a5,80005d92 <sys_open+0xd2>
    80005d88:	04491703          	lh	a4,68(s2)
    80005d8c:	4789                	li	a5,2
    80005d8e:	08f70f63          	beq	a4,a5,80005e2c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005d92:	854a                	mv	a0,s2
    80005d94:	ffffe097          	auipc	ra,0xffffe
    80005d98:	070080e7          	jalr	112(ra) # 80003e04 <iunlock>
  end_op();
    80005d9c:	fffff097          	auipc	ra,0xfffff
    80005da0:	9fc080e7          	jalr	-1540(ra) # 80004798 <end_op>

  return fd;
}
    80005da4:	8526                	mv	a0,s1
    80005da6:	70ea                	ld	ra,184(sp)
    80005da8:	744a                	ld	s0,176(sp)
    80005daa:	74aa                	ld	s1,168(sp)
    80005dac:	790a                	ld	s2,160(sp)
    80005dae:	69ea                	ld	s3,152(sp)
    80005db0:	6129                	addi	sp,sp,192
    80005db2:	8082                	ret
      end_op();
    80005db4:	fffff097          	auipc	ra,0xfffff
    80005db8:	9e4080e7          	jalr	-1564(ra) # 80004798 <end_op>
      return -1;
    80005dbc:	b7e5                	j	80005da4 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005dbe:	f5040513          	addi	a0,s0,-176
    80005dc2:	ffffe097          	auipc	ra,0xffffe
    80005dc6:	736080e7          	jalr	1846(ra) # 800044f8 <namei>
    80005dca:	892a                	mv	s2,a0
    80005dcc:	c905                	beqz	a0,80005dfc <sys_open+0x13c>
    ilock(ip);
    80005dce:	ffffe097          	auipc	ra,0xffffe
    80005dd2:	f74080e7          	jalr	-140(ra) # 80003d42 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005dd6:	04491703          	lh	a4,68(s2)
    80005dda:	4785                	li	a5,1
    80005ddc:	f4f712e3          	bne	a4,a5,80005d20 <sys_open+0x60>
    80005de0:	f4c42783          	lw	a5,-180(s0)
    80005de4:	dba1                	beqz	a5,80005d34 <sys_open+0x74>
      iunlockput(ip);
    80005de6:	854a                	mv	a0,s2
    80005de8:	ffffe097          	auipc	ra,0xffffe
    80005dec:	1bc080e7          	jalr	444(ra) # 80003fa4 <iunlockput>
      end_op();
    80005df0:	fffff097          	auipc	ra,0xfffff
    80005df4:	9a8080e7          	jalr	-1624(ra) # 80004798 <end_op>
      return -1;
    80005df8:	54fd                	li	s1,-1
    80005dfa:	b76d                	j	80005da4 <sys_open+0xe4>
      end_op();
    80005dfc:	fffff097          	auipc	ra,0xfffff
    80005e00:	99c080e7          	jalr	-1636(ra) # 80004798 <end_op>
      return -1;
    80005e04:	54fd                	li	s1,-1
    80005e06:	bf79                	j	80005da4 <sys_open+0xe4>
    iunlockput(ip);
    80005e08:	854a                	mv	a0,s2
    80005e0a:	ffffe097          	auipc	ra,0xffffe
    80005e0e:	19a080e7          	jalr	410(ra) # 80003fa4 <iunlockput>
    end_op();
    80005e12:	fffff097          	auipc	ra,0xfffff
    80005e16:	986080e7          	jalr	-1658(ra) # 80004798 <end_op>
    return -1;
    80005e1a:	54fd                	li	s1,-1
    80005e1c:	b761                	j	80005da4 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005e1e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005e22:	04691783          	lh	a5,70(s2)
    80005e26:	02f99223          	sh	a5,36(s3)
    80005e2a:	bf2d                	j	80005d64 <sys_open+0xa4>
    itrunc(ip);
    80005e2c:	854a                	mv	a0,s2
    80005e2e:	ffffe097          	auipc	ra,0xffffe
    80005e32:	022080e7          	jalr	34(ra) # 80003e50 <itrunc>
    80005e36:	bfb1                	j	80005d92 <sys_open+0xd2>
      fileclose(f);
    80005e38:	854e                	mv	a0,s3
    80005e3a:	fffff097          	auipc	ra,0xfffff
    80005e3e:	daa080e7          	jalr	-598(ra) # 80004be4 <fileclose>
    iunlockput(ip);
    80005e42:	854a                	mv	a0,s2
    80005e44:	ffffe097          	auipc	ra,0xffffe
    80005e48:	160080e7          	jalr	352(ra) # 80003fa4 <iunlockput>
    end_op();
    80005e4c:	fffff097          	auipc	ra,0xfffff
    80005e50:	94c080e7          	jalr	-1716(ra) # 80004798 <end_op>
    return -1;
    80005e54:	54fd                	li	s1,-1
    80005e56:	b7b9                	j	80005da4 <sys_open+0xe4>

0000000080005e58 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005e58:	7175                	addi	sp,sp,-144
    80005e5a:	e506                	sd	ra,136(sp)
    80005e5c:	e122                	sd	s0,128(sp)
    80005e5e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005e60:	fffff097          	auipc	ra,0xfffff
    80005e64:	8b8080e7          	jalr	-1864(ra) # 80004718 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005e68:	08000613          	li	a2,128
    80005e6c:	f7040593          	addi	a1,s0,-144
    80005e70:	4501                	li	a0,0
    80005e72:	ffffd097          	auipc	ra,0xffffd
    80005e76:	21c080e7          	jalr	540(ra) # 8000308e <argstr>
    80005e7a:	02054963          	bltz	a0,80005eac <sys_mkdir+0x54>
    80005e7e:	4681                	li	a3,0
    80005e80:	4601                	li	a2,0
    80005e82:	4585                	li	a1,1
    80005e84:	f7040513          	addi	a0,s0,-144
    80005e88:	00000097          	auipc	ra,0x0
    80005e8c:	800080e7          	jalr	-2048(ra) # 80005688 <create>
    80005e90:	cd11                	beqz	a0,80005eac <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e92:	ffffe097          	auipc	ra,0xffffe
    80005e96:	112080e7          	jalr	274(ra) # 80003fa4 <iunlockput>
  end_op();
    80005e9a:	fffff097          	auipc	ra,0xfffff
    80005e9e:	8fe080e7          	jalr	-1794(ra) # 80004798 <end_op>
  return 0;
    80005ea2:	4501                	li	a0,0
}
    80005ea4:	60aa                	ld	ra,136(sp)
    80005ea6:	640a                	ld	s0,128(sp)
    80005ea8:	6149                	addi	sp,sp,144
    80005eaa:	8082                	ret
    end_op();
    80005eac:	fffff097          	auipc	ra,0xfffff
    80005eb0:	8ec080e7          	jalr	-1812(ra) # 80004798 <end_op>
    return -1;
    80005eb4:	557d                	li	a0,-1
    80005eb6:	b7fd                	j	80005ea4 <sys_mkdir+0x4c>

0000000080005eb8 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005eb8:	7135                	addi	sp,sp,-160
    80005eba:	ed06                	sd	ra,152(sp)
    80005ebc:	e922                	sd	s0,144(sp)
    80005ebe:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ec0:	fffff097          	auipc	ra,0xfffff
    80005ec4:	858080e7          	jalr	-1960(ra) # 80004718 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ec8:	08000613          	li	a2,128
    80005ecc:	f7040593          	addi	a1,s0,-144
    80005ed0:	4501                	li	a0,0
    80005ed2:	ffffd097          	auipc	ra,0xffffd
    80005ed6:	1bc080e7          	jalr	444(ra) # 8000308e <argstr>
    80005eda:	04054a63          	bltz	a0,80005f2e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005ede:	f6c40593          	addi	a1,s0,-148
    80005ee2:	4505                	li	a0,1
    80005ee4:	ffffd097          	auipc	ra,0xffffd
    80005ee8:	166080e7          	jalr	358(ra) # 8000304a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005eec:	04054163          	bltz	a0,80005f2e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005ef0:	f6840593          	addi	a1,s0,-152
    80005ef4:	4509                	li	a0,2
    80005ef6:	ffffd097          	auipc	ra,0xffffd
    80005efa:	154080e7          	jalr	340(ra) # 8000304a <argint>
     argint(1, &major) < 0 ||
    80005efe:	02054863          	bltz	a0,80005f2e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005f02:	f6841683          	lh	a3,-152(s0)
    80005f06:	f6c41603          	lh	a2,-148(s0)
    80005f0a:	458d                	li	a1,3
    80005f0c:	f7040513          	addi	a0,s0,-144
    80005f10:	fffff097          	auipc	ra,0xfffff
    80005f14:	778080e7          	jalr	1912(ra) # 80005688 <create>
     argint(2, &minor) < 0 ||
    80005f18:	c919                	beqz	a0,80005f2e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f1a:	ffffe097          	auipc	ra,0xffffe
    80005f1e:	08a080e7          	jalr	138(ra) # 80003fa4 <iunlockput>
  end_op();
    80005f22:	fffff097          	auipc	ra,0xfffff
    80005f26:	876080e7          	jalr	-1930(ra) # 80004798 <end_op>
  return 0;
    80005f2a:	4501                	li	a0,0
    80005f2c:	a031                	j	80005f38 <sys_mknod+0x80>
    end_op();
    80005f2e:	fffff097          	auipc	ra,0xfffff
    80005f32:	86a080e7          	jalr	-1942(ra) # 80004798 <end_op>
    return -1;
    80005f36:	557d                	li	a0,-1
}
    80005f38:	60ea                	ld	ra,152(sp)
    80005f3a:	644a                	ld	s0,144(sp)
    80005f3c:	610d                	addi	sp,sp,160
    80005f3e:	8082                	ret

0000000080005f40 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005f40:	7135                	addi	sp,sp,-160
    80005f42:	ed06                	sd	ra,152(sp)
    80005f44:	e922                	sd	s0,144(sp)
    80005f46:	e526                	sd	s1,136(sp)
    80005f48:	e14a                	sd	s2,128(sp)
    80005f4a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005f4c:	ffffc097          	auipc	ra,0xffffc
    80005f50:	a7a080e7          	jalr	-1414(ra) # 800019c6 <myproc>
    80005f54:	892a                	mv	s2,a0
  
  begin_op();
    80005f56:	ffffe097          	auipc	ra,0xffffe
    80005f5a:	7c2080e7          	jalr	1986(ra) # 80004718 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005f5e:	08000613          	li	a2,128
    80005f62:	f6040593          	addi	a1,s0,-160
    80005f66:	4501                	li	a0,0
    80005f68:	ffffd097          	auipc	ra,0xffffd
    80005f6c:	126080e7          	jalr	294(ra) # 8000308e <argstr>
    80005f70:	04054b63          	bltz	a0,80005fc6 <sys_chdir+0x86>
    80005f74:	f6040513          	addi	a0,s0,-160
    80005f78:	ffffe097          	auipc	ra,0xffffe
    80005f7c:	580080e7          	jalr	1408(ra) # 800044f8 <namei>
    80005f80:	84aa                	mv	s1,a0
    80005f82:	c131                	beqz	a0,80005fc6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005f84:	ffffe097          	auipc	ra,0xffffe
    80005f88:	dbe080e7          	jalr	-578(ra) # 80003d42 <ilock>
  if(ip->type != T_DIR){
    80005f8c:	04449703          	lh	a4,68(s1)
    80005f90:	4785                	li	a5,1
    80005f92:	04f71063          	bne	a4,a5,80005fd2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005f96:	8526                	mv	a0,s1
    80005f98:	ffffe097          	auipc	ra,0xffffe
    80005f9c:	e6c080e7          	jalr	-404(ra) # 80003e04 <iunlock>
  iput(p->cwd);
    80005fa0:	17893503          	ld	a0,376(s2)
    80005fa4:	ffffe097          	auipc	ra,0xffffe
    80005fa8:	f58080e7          	jalr	-168(ra) # 80003efc <iput>
  end_op();
    80005fac:	ffffe097          	auipc	ra,0xffffe
    80005fb0:	7ec080e7          	jalr	2028(ra) # 80004798 <end_op>
  p->cwd = ip;
    80005fb4:	16993c23          	sd	s1,376(s2)
  return 0;
    80005fb8:	4501                	li	a0,0
}
    80005fba:	60ea                	ld	ra,152(sp)
    80005fbc:	644a                	ld	s0,144(sp)
    80005fbe:	64aa                	ld	s1,136(sp)
    80005fc0:	690a                	ld	s2,128(sp)
    80005fc2:	610d                	addi	sp,sp,160
    80005fc4:	8082                	ret
    end_op();
    80005fc6:	ffffe097          	auipc	ra,0xffffe
    80005fca:	7d2080e7          	jalr	2002(ra) # 80004798 <end_op>
    return -1;
    80005fce:	557d                	li	a0,-1
    80005fd0:	b7ed                	j	80005fba <sys_chdir+0x7a>
    iunlockput(ip);
    80005fd2:	8526                	mv	a0,s1
    80005fd4:	ffffe097          	auipc	ra,0xffffe
    80005fd8:	fd0080e7          	jalr	-48(ra) # 80003fa4 <iunlockput>
    end_op();
    80005fdc:	ffffe097          	auipc	ra,0xffffe
    80005fe0:	7bc080e7          	jalr	1980(ra) # 80004798 <end_op>
    return -1;
    80005fe4:	557d                	li	a0,-1
    80005fe6:	bfd1                	j	80005fba <sys_chdir+0x7a>

0000000080005fe8 <sys_exec>:

uint64
sys_exec(void)
{
    80005fe8:	7145                	addi	sp,sp,-464
    80005fea:	e786                	sd	ra,456(sp)
    80005fec:	e3a2                	sd	s0,448(sp)
    80005fee:	ff26                	sd	s1,440(sp)
    80005ff0:	fb4a                	sd	s2,432(sp)
    80005ff2:	f74e                	sd	s3,424(sp)
    80005ff4:	f352                	sd	s4,416(sp)
    80005ff6:	ef56                	sd	s5,408(sp)
    80005ff8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005ffa:	08000613          	li	a2,128
    80005ffe:	f4040593          	addi	a1,s0,-192
    80006002:	4501                	li	a0,0
    80006004:	ffffd097          	auipc	ra,0xffffd
    80006008:	08a080e7          	jalr	138(ra) # 8000308e <argstr>
    return -1;
    8000600c:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000600e:	0c054a63          	bltz	a0,800060e2 <sys_exec+0xfa>
    80006012:	e3840593          	addi	a1,s0,-456
    80006016:	4505                	li	a0,1
    80006018:	ffffd097          	auipc	ra,0xffffd
    8000601c:	054080e7          	jalr	84(ra) # 8000306c <argaddr>
    80006020:	0c054163          	bltz	a0,800060e2 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006024:	10000613          	li	a2,256
    80006028:	4581                	li	a1,0
    8000602a:	e4040513          	addi	a0,s0,-448
    8000602e:	ffffb097          	auipc	ra,0xffffb
    80006032:	c90080e7          	jalr	-880(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006036:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000603a:	89a6                	mv	s3,s1
    8000603c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000603e:	02000a13          	li	s4,32
    80006042:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006046:	00391793          	slli	a5,s2,0x3
    8000604a:	e3040593          	addi	a1,s0,-464
    8000604e:	e3843503          	ld	a0,-456(s0)
    80006052:	953e                	add	a0,a0,a5
    80006054:	ffffd097          	auipc	ra,0xffffd
    80006058:	f5c080e7          	jalr	-164(ra) # 80002fb0 <fetchaddr>
    8000605c:	02054a63          	bltz	a0,80006090 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006060:	e3043783          	ld	a5,-464(s0)
    80006064:	c3b9                	beqz	a5,800060aa <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006066:	ffffb097          	auipc	ra,0xffffb
    8000606a:	a6c080e7          	jalr	-1428(ra) # 80000ad2 <kalloc>
    8000606e:	85aa                	mv	a1,a0
    80006070:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006074:	cd11                	beqz	a0,80006090 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006076:	6605                	lui	a2,0x1
    80006078:	e3043503          	ld	a0,-464(s0)
    8000607c:	ffffd097          	auipc	ra,0xffffd
    80006080:	f86080e7          	jalr	-122(ra) # 80003002 <fetchstr>
    80006084:	00054663          	bltz	a0,80006090 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006088:	0905                	addi	s2,s2,1
    8000608a:	09a1                	addi	s3,s3,8
    8000608c:	fb491be3          	bne	s2,s4,80006042 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006090:	10048913          	addi	s2,s1,256
    80006094:	6088                	ld	a0,0(s1)
    80006096:	c529                	beqz	a0,800060e0 <sys_exec+0xf8>
    kfree(argv[i]);
    80006098:	ffffb097          	auipc	ra,0xffffb
    8000609c:	93e080e7          	jalr	-1730(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060a0:	04a1                	addi	s1,s1,8
    800060a2:	ff2499e3          	bne	s1,s2,80006094 <sys_exec+0xac>
  return -1;
    800060a6:	597d                	li	s2,-1
    800060a8:	a82d                	j	800060e2 <sys_exec+0xfa>
      argv[i] = 0;
    800060aa:	0a8e                	slli	s5,s5,0x3
    800060ac:	fc040793          	addi	a5,s0,-64
    800060b0:	9abe                	add	s5,s5,a5
    800060b2:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd8e80>
  int ret = exec(path, argv);
    800060b6:	e4040593          	addi	a1,s0,-448
    800060ba:	f4040513          	addi	a0,s0,-192
    800060be:	fffff097          	auipc	ra,0xfffff
    800060c2:	178080e7          	jalr	376(ra) # 80005236 <exec>
    800060c6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060c8:	10048993          	addi	s3,s1,256
    800060cc:	6088                	ld	a0,0(s1)
    800060ce:	c911                	beqz	a0,800060e2 <sys_exec+0xfa>
    kfree(argv[i]);
    800060d0:	ffffb097          	auipc	ra,0xffffb
    800060d4:	906080e7          	jalr	-1786(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060d8:	04a1                	addi	s1,s1,8
    800060da:	ff3499e3          	bne	s1,s3,800060cc <sys_exec+0xe4>
    800060de:	a011                	j	800060e2 <sys_exec+0xfa>
  return -1;
    800060e0:	597d                	li	s2,-1
}
    800060e2:	854a                	mv	a0,s2
    800060e4:	60be                	ld	ra,456(sp)
    800060e6:	641e                	ld	s0,448(sp)
    800060e8:	74fa                	ld	s1,440(sp)
    800060ea:	795a                	ld	s2,432(sp)
    800060ec:	79ba                	ld	s3,424(sp)
    800060ee:	7a1a                	ld	s4,416(sp)
    800060f0:	6afa                	ld	s5,408(sp)
    800060f2:	6179                	addi	sp,sp,464
    800060f4:	8082                	ret

00000000800060f6 <sys_pipe>:

uint64
sys_pipe(void)
{
    800060f6:	7139                	addi	sp,sp,-64
    800060f8:	fc06                	sd	ra,56(sp)
    800060fa:	f822                	sd	s0,48(sp)
    800060fc:	f426                	sd	s1,40(sp)
    800060fe:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006100:	ffffc097          	auipc	ra,0xffffc
    80006104:	8c6080e7          	jalr	-1850(ra) # 800019c6 <myproc>
    80006108:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    8000610a:	fd840593          	addi	a1,s0,-40
    8000610e:	4501                	li	a0,0
    80006110:	ffffd097          	auipc	ra,0xffffd
    80006114:	f5c080e7          	jalr	-164(ra) # 8000306c <argaddr>
    return -1;
    80006118:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    8000611a:	0e054063          	bltz	a0,800061fa <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    8000611e:	fc840593          	addi	a1,s0,-56
    80006122:	fd040513          	addi	a0,s0,-48
    80006126:	fffff097          	auipc	ra,0xfffff
    8000612a:	dee080e7          	jalr	-530(ra) # 80004f14 <pipealloc>
    return -1;
    8000612e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006130:	0c054563          	bltz	a0,800061fa <sys_pipe+0x104>
  fd0 = -1;
    80006134:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006138:	fd043503          	ld	a0,-48(s0)
    8000613c:	fffff097          	auipc	ra,0xfffff
    80006140:	50a080e7          	jalr	1290(ra) # 80005646 <fdalloc>
    80006144:	fca42223          	sw	a0,-60(s0)
    80006148:	08054c63          	bltz	a0,800061e0 <sys_pipe+0xea>
    8000614c:	fc843503          	ld	a0,-56(s0)
    80006150:	fffff097          	auipc	ra,0xfffff
    80006154:	4f6080e7          	jalr	1270(ra) # 80005646 <fdalloc>
    80006158:	fca42023          	sw	a0,-64(s0)
    8000615c:	06054863          	bltz	a0,800061cc <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006160:	4691                	li	a3,4
    80006162:	fc440613          	addi	a2,s0,-60
    80006166:	fd843583          	ld	a1,-40(s0)
    8000616a:	7ca8                	ld	a0,120(s1)
    8000616c:	ffffb097          	auipc	ra,0xffffb
    80006170:	4d2080e7          	jalr	1234(ra) # 8000163e <copyout>
    80006174:	02054063          	bltz	a0,80006194 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006178:	4691                	li	a3,4
    8000617a:	fc040613          	addi	a2,s0,-64
    8000617e:	fd843583          	ld	a1,-40(s0)
    80006182:	0591                	addi	a1,a1,4
    80006184:	7ca8                	ld	a0,120(s1)
    80006186:	ffffb097          	auipc	ra,0xffffb
    8000618a:	4b8080e7          	jalr	1208(ra) # 8000163e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000618e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006190:	06055563          	bgez	a0,800061fa <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006194:	fc442783          	lw	a5,-60(s0)
    80006198:	07f9                	addi	a5,a5,30
    8000619a:	078e                	slli	a5,a5,0x3
    8000619c:	97a6                	add	a5,a5,s1
    8000619e:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800061a2:	fc042503          	lw	a0,-64(s0)
    800061a6:	0579                	addi	a0,a0,30
    800061a8:	050e                	slli	a0,a0,0x3
    800061aa:	9526                	add	a0,a0,s1
    800061ac:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    800061b0:	fd043503          	ld	a0,-48(s0)
    800061b4:	fffff097          	auipc	ra,0xfffff
    800061b8:	a30080e7          	jalr	-1488(ra) # 80004be4 <fileclose>
    fileclose(wf);
    800061bc:	fc843503          	ld	a0,-56(s0)
    800061c0:	fffff097          	auipc	ra,0xfffff
    800061c4:	a24080e7          	jalr	-1500(ra) # 80004be4 <fileclose>
    return -1;
    800061c8:	57fd                	li	a5,-1
    800061ca:	a805                	j	800061fa <sys_pipe+0x104>
    if(fd0 >= 0)
    800061cc:	fc442783          	lw	a5,-60(s0)
    800061d0:	0007c863          	bltz	a5,800061e0 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    800061d4:	01e78513          	addi	a0,a5,30
    800061d8:	050e                	slli	a0,a0,0x3
    800061da:	9526                	add	a0,a0,s1
    800061dc:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    800061e0:	fd043503          	ld	a0,-48(s0)
    800061e4:	fffff097          	auipc	ra,0xfffff
    800061e8:	a00080e7          	jalr	-1536(ra) # 80004be4 <fileclose>
    fileclose(wf);
    800061ec:	fc843503          	ld	a0,-56(s0)
    800061f0:	fffff097          	auipc	ra,0xfffff
    800061f4:	9f4080e7          	jalr	-1548(ra) # 80004be4 <fileclose>
    return -1;
    800061f8:	57fd                	li	a5,-1
}
    800061fa:	853e                	mv	a0,a5
    800061fc:	70e2                	ld	ra,56(sp)
    800061fe:	7442                	ld	s0,48(sp)
    80006200:	74a2                	ld	s1,40(sp)
    80006202:	6121                	addi	sp,sp,64
    80006204:	8082                	ret
	...

0000000080006210 <kernelvec>:
    80006210:	7111                	addi	sp,sp,-256
    80006212:	e006                	sd	ra,0(sp)
    80006214:	e40a                	sd	sp,8(sp)
    80006216:	e80e                	sd	gp,16(sp)
    80006218:	ec12                	sd	tp,24(sp)
    8000621a:	f016                	sd	t0,32(sp)
    8000621c:	f41a                	sd	t1,40(sp)
    8000621e:	f81e                	sd	t2,48(sp)
    80006220:	fc22                	sd	s0,56(sp)
    80006222:	e0a6                	sd	s1,64(sp)
    80006224:	e4aa                	sd	a0,72(sp)
    80006226:	e8ae                	sd	a1,80(sp)
    80006228:	ecb2                	sd	a2,88(sp)
    8000622a:	f0b6                	sd	a3,96(sp)
    8000622c:	f4ba                	sd	a4,104(sp)
    8000622e:	f8be                	sd	a5,112(sp)
    80006230:	fcc2                	sd	a6,120(sp)
    80006232:	e146                	sd	a7,128(sp)
    80006234:	e54a                	sd	s2,136(sp)
    80006236:	e94e                	sd	s3,144(sp)
    80006238:	ed52                	sd	s4,152(sp)
    8000623a:	f156                	sd	s5,160(sp)
    8000623c:	f55a                	sd	s6,168(sp)
    8000623e:	f95e                	sd	s7,176(sp)
    80006240:	fd62                	sd	s8,184(sp)
    80006242:	e1e6                	sd	s9,192(sp)
    80006244:	e5ea                	sd	s10,200(sp)
    80006246:	e9ee                	sd	s11,208(sp)
    80006248:	edf2                	sd	t3,216(sp)
    8000624a:	f1f6                	sd	t4,224(sp)
    8000624c:	f5fa                	sd	t5,232(sp)
    8000624e:	f9fe                	sd	t6,240(sp)
    80006250:	c1bfc0ef          	jal	ra,80002e6a <kerneltrap>
    80006254:	6082                	ld	ra,0(sp)
    80006256:	6122                	ld	sp,8(sp)
    80006258:	61c2                	ld	gp,16(sp)
    8000625a:	7282                	ld	t0,32(sp)
    8000625c:	7322                	ld	t1,40(sp)
    8000625e:	73c2                	ld	t2,48(sp)
    80006260:	7462                	ld	s0,56(sp)
    80006262:	6486                	ld	s1,64(sp)
    80006264:	6526                	ld	a0,72(sp)
    80006266:	65c6                	ld	a1,80(sp)
    80006268:	6666                	ld	a2,88(sp)
    8000626a:	7686                	ld	a3,96(sp)
    8000626c:	7726                	ld	a4,104(sp)
    8000626e:	77c6                	ld	a5,112(sp)
    80006270:	7866                	ld	a6,120(sp)
    80006272:	688a                	ld	a7,128(sp)
    80006274:	692a                	ld	s2,136(sp)
    80006276:	69ca                	ld	s3,144(sp)
    80006278:	6a6a                	ld	s4,152(sp)
    8000627a:	7a8a                	ld	s5,160(sp)
    8000627c:	7b2a                	ld	s6,168(sp)
    8000627e:	7bca                	ld	s7,176(sp)
    80006280:	7c6a                	ld	s8,184(sp)
    80006282:	6c8e                	ld	s9,192(sp)
    80006284:	6d2e                	ld	s10,200(sp)
    80006286:	6dce                	ld	s11,208(sp)
    80006288:	6e6e                	ld	t3,216(sp)
    8000628a:	7e8e                	ld	t4,224(sp)
    8000628c:	7f2e                	ld	t5,232(sp)
    8000628e:	7fce                	ld	t6,240(sp)
    80006290:	6111                	addi	sp,sp,256
    80006292:	10200073          	sret
    80006296:	00000013          	nop
    8000629a:	00000013          	nop
    8000629e:	0001                	nop

00000000800062a0 <timervec>:
    800062a0:	34051573          	csrrw	a0,mscratch,a0
    800062a4:	e10c                	sd	a1,0(a0)
    800062a6:	e510                	sd	a2,8(a0)
    800062a8:	e914                	sd	a3,16(a0)
    800062aa:	6d0c                	ld	a1,24(a0)
    800062ac:	7110                	ld	a2,32(a0)
    800062ae:	6194                	ld	a3,0(a1)
    800062b0:	96b2                	add	a3,a3,a2
    800062b2:	e194                	sd	a3,0(a1)
    800062b4:	4589                	li	a1,2
    800062b6:	14459073          	csrw	sip,a1
    800062ba:	6914                	ld	a3,16(a0)
    800062bc:	6510                	ld	a2,8(a0)
    800062be:	610c                	ld	a1,0(a0)
    800062c0:	34051573          	csrrw	a0,mscratch,a0
    800062c4:	30200073          	mret
	...

00000000800062ca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800062ca:	1141                	addi	sp,sp,-16
    800062cc:	e422                	sd	s0,8(sp)
    800062ce:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800062d0:	0c0007b7          	lui	a5,0xc000
    800062d4:	4705                	li	a4,1
    800062d6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800062d8:	c3d8                	sw	a4,4(a5)
}
    800062da:	6422                	ld	s0,8(sp)
    800062dc:	0141                	addi	sp,sp,16
    800062de:	8082                	ret

00000000800062e0 <plicinithart>:

void
plicinithart(void)
{
    800062e0:	1141                	addi	sp,sp,-16
    800062e2:	e406                	sd	ra,8(sp)
    800062e4:	e022                	sd	s0,0(sp)
    800062e6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062e8:	ffffb097          	auipc	ra,0xffffb
    800062ec:	6b2080e7          	jalr	1714(ra) # 8000199a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800062f0:	0085171b          	slliw	a4,a0,0x8
    800062f4:	0c0027b7          	lui	a5,0xc002
    800062f8:	97ba                	add	a5,a5,a4
    800062fa:	40200713          	li	a4,1026
    800062fe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006302:	00d5151b          	slliw	a0,a0,0xd
    80006306:	0c2017b7          	lui	a5,0xc201
    8000630a:	953e                	add	a0,a0,a5
    8000630c:	00052023          	sw	zero,0(a0)
}
    80006310:	60a2                	ld	ra,8(sp)
    80006312:	6402                	ld	s0,0(sp)
    80006314:	0141                	addi	sp,sp,16
    80006316:	8082                	ret

0000000080006318 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006318:	1141                	addi	sp,sp,-16
    8000631a:	e406                	sd	ra,8(sp)
    8000631c:	e022                	sd	s0,0(sp)
    8000631e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006320:	ffffb097          	auipc	ra,0xffffb
    80006324:	67a080e7          	jalr	1658(ra) # 8000199a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006328:	00d5179b          	slliw	a5,a0,0xd
    8000632c:	0c201537          	lui	a0,0xc201
    80006330:	953e                	add	a0,a0,a5
  return irq;
}
    80006332:	4148                	lw	a0,4(a0)
    80006334:	60a2                	ld	ra,8(sp)
    80006336:	6402                	ld	s0,0(sp)
    80006338:	0141                	addi	sp,sp,16
    8000633a:	8082                	ret

000000008000633c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000633c:	1101                	addi	sp,sp,-32
    8000633e:	ec06                	sd	ra,24(sp)
    80006340:	e822                	sd	s0,16(sp)
    80006342:	e426                	sd	s1,8(sp)
    80006344:	1000                	addi	s0,sp,32
    80006346:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006348:	ffffb097          	auipc	ra,0xffffb
    8000634c:	652080e7          	jalr	1618(ra) # 8000199a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006350:	00d5151b          	slliw	a0,a0,0xd
    80006354:	0c2017b7          	lui	a5,0xc201
    80006358:	97aa                	add	a5,a5,a0
    8000635a:	c3c4                	sw	s1,4(a5)
}
    8000635c:	60e2                	ld	ra,24(sp)
    8000635e:	6442                	ld	s0,16(sp)
    80006360:	64a2                	ld	s1,8(sp)
    80006362:	6105                	addi	sp,sp,32
    80006364:	8082                	ret

0000000080006366 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006366:	1141                	addi	sp,sp,-16
    80006368:	e406                	sd	ra,8(sp)
    8000636a:	e022                	sd	s0,0(sp)
    8000636c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000636e:	479d                	li	a5,7
    80006370:	06a7c963          	blt	a5,a0,800063e2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006374:	0001d797          	auipc	a5,0x1d
    80006378:	c8c78793          	addi	a5,a5,-884 # 80023000 <disk>
    8000637c:	00a78733          	add	a4,a5,a0
    80006380:	6789                	lui	a5,0x2
    80006382:	97ba                	add	a5,a5,a4
    80006384:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006388:	e7ad                	bnez	a5,800063f2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000638a:	00451793          	slli	a5,a0,0x4
    8000638e:	0001f717          	auipc	a4,0x1f
    80006392:	c7270713          	addi	a4,a4,-910 # 80025000 <disk+0x2000>
    80006396:	6314                	ld	a3,0(a4)
    80006398:	96be                	add	a3,a3,a5
    8000639a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000639e:	6314                	ld	a3,0(a4)
    800063a0:	96be                	add	a3,a3,a5
    800063a2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800063a6:	6314                	ld	a3,0(a4)
    800063a8:	96be                	add	a3,a3,a5
    800063aa:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    800063ae:	6318                	ld	a4,0(a4)
    800063b0:	97ba                	add	a5,a5,a4
    800063b2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    800063b6:	0001d797          	auipc	a5,0x1d
    800063ba:	c4a78793          	addi	a5,a5,-950 # 80023000 <disk>
    800063be:	97aa                	add	a5,a5,a0
    800063c0:	6509                	lui	a0,0x2
    800063c2:	953e                	add	a0,a0,a5
    800063c4:	4785                	li	a5,1
    800063c6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    800063ca:	0001f517          	auipc	a0,0x1f
    800063ce:	c4e50513          	addi	a0,a0,-946 # 80025018 <disk+0x2018>
    800063d2:	ffffc097          	auipc	ra,0xffffc
    800063d6:	0fa080e7          	jalr	250(ra) # 800024cc <wakeup>
}
    800063da:	60a2                	ld	ra,8(sp)
    800063dc:	6402                	ld	s0,0(sp)
    800063de:	0141                	addi	sp,sp,16
    800063e0:	8082                	ret
    panic("free_desc 1");
    800063e2:	00002517          	auipc	a0,0x2
    800063e6:	68650513          	addi	a0,a0,1670 # 80008a68 <syscalls+0x330>
    800063ea:	ffffa097          	auipc	ra,0xffffa
    800063ee:	140080e7          	jalr	320(ra) # 8000052a <panic>
    panic("free_desc 2");
    800063f2:	00002517          	auipc	a0,0x2
    800063f6:	68650513          	addi	a0,a0,1670 # 80008a78 <syscalls+0x340>
    800063fa:	ffffa097          	auipc	ra,0xffffa
    800063fe:	130080e7          	jalr	304(ra) # 8000052a <panic>

0000000080006402 <virtio_disk_init>:
{
    80006402:	1101                	addi	sp,sp,-32
    80006404:	ec06                	sd	ra,24(sp)
    80006406:	e822                	sd	s0,16(sp)
    80006408:	e426                	sd	s1,8(sp)
    8000640a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000640c:	00002597          	auipc	a1,0x2
    80006410:	67c58593          	addi	a1,a1,1660 # 80008a88 <syscalls+0x350>
    80006414:	0001f517          	auipc	a0,0x1f
    80006418:	d1450513          	addi	a0,a0,-748 # 80025128 <disk+0x2128>
    8000641c:	ffffa097          	auipc	ra,0xffffa
    80006420:	716080e7          	jalr	1814(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006424:	100017b7          	lui	a5,0x10001
    80006428:	4398                	lw	a4,0(a5)
    8000642a:	2701                	sext.w	a4,a4
    8000642c:	747277b7          	lui	a5,0x74727
    80006430:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006434:	0ef71163          	bne	a4,a5,80006516 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006438:	100017b7          	lui	a5,0x10001
    8000643c:	43dc                	lw	a5,4(a5)
    8000643e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006440:	4705                	li	a4,1
    80006442:	0ce79a63          	bne	a5,a4,80006516 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006446:	100017b7          	lui	a5,0x10001
    8000644a:	479c                	lw	a5,8(a5)
    8000644c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000644e:	4709                	li	a4,2
    80006450:	0ce79363          	bne	a5,a4,80006516 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006454:	100017b7          	lui	a5,0x10001
    80006458:	47d8                	lw	a4,12(a5)
    8000645a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000645c:	554d47b7          	lui	a5,0x554d4
    80006460:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006464:	0af71963          	bne	a4,a5,80006516 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006468:	100017b7          	lui	a5,0x10001
    8000646c:	4705                	li	a4,1
    8000646e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006470:	470d                	li	a4,3
    80006472:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006474:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006476:	c7ffe737          	lui	a4,0xc7ffe
    8000647a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    8000647e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006480:	2701                	sext.w	a4,a4
    80006482:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006484:	472d                	li	a4,11
    80006486:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006488:	473d                	li	a4,15
    8000648a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000648c:	6705                	lui	a4,0x1
    8000648e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006490:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006494:	5bdc                	lw	a5,52(a5)
    80006496:	2781                	sext.w	a5,a5
  if(max == 0)
    80006498:	c7d9                	beqz	a5,80006526 <virtio_disk_init+0x124>
  if(max < NUM)
    8000649a:	471d                	li	a4,7
    8000649c:	08f77d63          	bgeu	a4,a5,80006536 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800064a0:	100014b7          	lui	s1,0x10001
    800064a4:	47a1                	li	a5,8
    800064a6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800064a8:	6609                	lui	a2,0x2
    800064aa:	4581                	li	a1,0
    800064ac:	0001d517          	auipc	a0,0x1d
    800064b0:	b5450513          	addi	a0,a0,-1196 # 80023000 <disk>
    800064b4:	ffffb097          	auipc	ra,0xffffb
    800064b8:	80a080e7          	jalr	-2038(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800064bc:	0001d717          	auipc	a4,0x1d
    800064c0:	b4470713          	addi	a4,a4,-1212 # 80023000 <disk>
    800064c4:	00c75793          	srli	a5,a4,0xc
    800064c8:	2781                	sext.w	a5,a5
    800064ca:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    800064cc:	0001f797          	auipc	a5,0x1f
    800064d0:	b3478793          	addi	a5,a5,-1228 # 80025000 <disk+0x2000>
    800064d4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800064d6:	0001d717          	auipc	a4,0x1d
    800064da:	baa70713          	addi	a4,a4,-1110 # 80023080 <disk+0x80>
    800064de:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    800064e0:	0001e717          	auipc	a4,0x1e
    800064e4:	b2070713          	addi	a4,a4,-1248 # 80024000 <disk+0x1000>
    800064e8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800064ea:	4705                	li	a4,1
    800064ec:	00e78c23          	sb	a4,24(a5)
    800064f0:	00e78ca3          	sb	a4,25(a5)
    800064f4:	00e78d23          	sb	a4,26(a5)
    800064f8:	00e78da3          	sb	a4,27(a5)
    800064fc:	00e78e23          	sb	a4,28(a5)
    80006500:	00e78ea3          	sb	a4,29(a5)
    80006504:	00e78f23          	sb	a4,30(a5)
    80006508:	00e78fa3          	sb	a4,31(a5)
}
    8000650c:	60e2                	ld	ra,24(sp)
    8000650e:	6442                	ld	s0,16(sp)
    80006510:	64a2                	ld	s1,8(sp)
    80006512:	6105                	addi	sp,sp,32
    80006514:	8082                	ret
    panic("could not find virtio disk");
    80006516:	00002517          	auipc	a0,0x2
    8000651a:	58250513          	addi	a0,a0,1410 # 80008a98 <syscalls+0x360>
    8000651e:	ffffa097          	auipc	ra,0xffffa
    80006522:	00c080e7          	jalr	12(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006526:	00002517          	auipc	a0,0x2
    8000652a:	59250513          	addi	a0,a0,1426 # 80008ab8 <syscalls+0x380>
    8000652e:	ffffa097          	auipc	ra,0xffffa
    80006532:	ffc080e7          	jalr	-4(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006536:	00002517          	auipc	a0,0x2
    8000653a:	5a250513          	addi	a0,a0,1442 # 80008ad8 <syscalls+0x3a0>
    8000653e:	ffffa097          	auipc	ra,0xffffa
    80006542:	fec080e7          	jalr	-20(ra) # 8000052a <panic>

0000000080006546 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006546:	7119                	addi	sp,sp,-128
    80006548:	fc86                	sd	ra,120(sp)
    8000654a:	f8a2                	sd	s0,112(sp)
    8000654c:	f4a6                	sd	s1,104(sp)
    8000654e:	f0ca                	sd	s2,96(sp)
    80006550:	ecce                	sd	s3,88(sp)
    80006552:	e8d2                	sd	s4,80(sp)
    80006554:	e4d6                	sd	s5,72(sp)
    80006556:	e0da                	sd	s6,64(sp)
    80006558:	fc5e                	sd	s7,56(sp)
    8000655a:	f862                	sd	s8,48(sp)
    8000655c:	f466                	sd	s9,40(sp)
    8000655e:	f06a                	sd	s10,32(sp)
    80006560:	ec6e                	sd	s11,24(sp)
    80006562:	0100                	addi	s0,sp,128
    80006564:	8aaa                	mv	s5,a0
    80006566:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006568:	00c52c83          	lw	s9,12(a0)
    8000656c:	001c9c9b          	slliw	s9,s9,0x1
    80006570:	1c82                	slli	s9,s9,0x20
    80006572:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006576:	0001f517          	auipc	a0,0x1f
    8000657a:	bb250513          	addi	a0,a0,-1102 # 80025128 <disk+0x2128>
    8000657e:	ffffa097          	auipc	ra,0xffffa
    80006582:	644080e7          	jalr	1604(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006586:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006588:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000658a:	0001dc17          	auipc	s8,0x1d
    8000658e:	a76c0c13          	addi	s8,s8,-1418 # 80023000 <disk>
    80006592:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006594:	4b0d                	li	s6,3
    80006596:	a0ad                	j	80006600 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006598:	00fc0733          	add	a4,s8,a5
    8000659c:	975e                	add	a4,a4,s7
    8000659e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800065a2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800065a4:	0207c563          	bltz	a5,800065ce <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800065a8:	2905                	addiw	s2,s2,1
    800065aa:	0611                	addi	a2,a2,4
    800065ac:	19690d63          	beq	s2,s6,80006746 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    800065b0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800065b2:	0001f717          	auipc	a4,0x1f
    800065b6:	a6670713          	addi	a4,a4,-1434 # 80025018 <disk+0x2018>
    800065ba:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800065bc:	00074683          	lbu	a3,0(a4)
    800065c0:	fee1                	bnez	a3,80006598 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800065c2:	2785                	addiw	a5,a5,1
    800065c4:	0705                	addi	a4,a4,1
    800065c6:	fe979be3          	bne	a5,s1,800065bc <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800065ca:	57fd                	li	a5,-1
    800065cc:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800065ce:	01205d63          	blez	s2,800065e8 <virtio_disk_rw+0xa2>
    800065d2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800065d4:	000a2503          	lw	a0,0(s4)
    800065d8:	00000097          	auipc	ra,0x0
    800065dc:	d8e080e7          	jalr	-626(ra) # 80006366 <free_desc>
      for(int j = 0; j < i; j++)
    800065e0:	2d85                	addiw	s11,s11,1
    800065e2:	0a11                	addi	s4,s4,4
    800065e4:	ffb918e3          	bne	s2,s11,800065d4 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065e8:	0001f597          	auipc	a1,0x1f
    800065ec:	b4058593          	addi	a1,a1,-1216 # 80025128 <disk+0x2128>
    800065f0:	0001f517          	auipc	a0,0x1f
    800065f4:	a2850513          	addi	a0,a0,-1496 # 80025018 <disk+0x2018>
    800065f8:	ffffc097          	auipc	ra,0xffffc
    800065fc:	d48080e7          	jalr	-696(ra) # 80002340 <sleep>
  for(int i = 0; i < 3; i++){
    80006600:	f8040a13          	addi	s4,s0,-128
{
    80006604:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006606:	894e                	mv	s2,s3
    80006608:	b765                	j	800065b0 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000660a:	0001f697          	auipc	a3,0x1f
    8000660e:	9f66b683          	ld	a3,-1546(a3) # 80025000 <disk+0x2000>
    80006612:	96ba                	add	a3,a3,a4
    80006614:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006618:	0001d817          	auipc	a6,0x1d
    8000661c:	9e880813          	addi	a6,a6,-1560 # 80023000 <disk>
    80006620:	0001f697          	auipc	a3,0x1f
    80006624:	9e068693          	addi	a3,a3,-1568 # 80025000 <disk+0x2000>
    80006628:	6290                	ld	a2,0(a3)
    8000662a:	963a                	add	a2,a2,a4
    8000662c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006630:	0015e593          	ori	a1,a1,1
    80006634:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006638:	f8842603          	lw	a2,-120(s0)
    8000663c:	628c                	ld	a1,0(a3)
    8000663e:	972e                	add	a4,a4,a1
    80006640:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006644:	20050593          	addi	a1,a0,512
    80006648:	0592                	slli	a1,a1,0x4
    8000664a:	95c2                	add	a1,a1,a6
    8000664c:	577d                	li	a4,-1
    8000664e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006652:	00461713          	slli	a4,a2,0x4
    80006656:	6290                	ld	a2,0(a3)
    80006658:	963a                	add	a2,a2,a4
    8000665a:	03078793          	addi	a5,a5,48
    8000665e:	97c2                	add	a5,a5,a6
    80006660:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006662:	629c                	ld	a5,0(a3)
    80006664:	97ba                	add	a5,a5,a4
    80006666:	4605                	li	a2,1
    80006668:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000666a:	629c                	ld	a5,0(a3)
    8000666c:	97ba                	add	a5,a5,a4
    8000666e:	4809                	li	a6,2
    80006670:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006674:	629c                	ld	a5,0(a3)
    80006676:	973e                	add	a4,a4,a5
    80006678:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000667c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006680:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006684:	6698                	ld	a4,8(a3)
    80006686:	00275783          	lhu	a5,2(a4)
    8000668a:	8b9d                	andi	a5,a5,7
    8000668c:	0786                	slli	a5,a5,0x1
    8000668e:	97ba                	add	a5,a5,a4
    80006690:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006694:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006698:	6698                	ld	a4,8(a3)
    8000669a:	00275783          	lhu	a5,2(a4)
    8000669e:	2785                	addiw	a5,a5,1
    800066a0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800066a4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800066a8:	100017b7          	lui	a5,0x10001
    800066ac:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800066b0:	004aa783          	lw	a5,4(s5)
    800066b4:	02c79163          	bne	a5,a2,800066d6 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800066b8:	0001f917          	auipc	s2,0x1f
    800066bc:	a7090913          	addi	s2,s2,-1424 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    800066c0:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800066c2:	85ca                	mv	a1,s2
    800066c4:	8556                	mv	a0,s5
    800066c6:	ffffc097          	auipc	ra,0xffffc
    800066ca:	c7a080e7          	jalr	-902(ra) # 80002340 <sleep>
  while(b->disk == 1) {
    800066ce:	004aa783          	lw	a5,4(s5)
    800066d2:	fe9788e3          	beq	a5,s1,800066c2 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800066d6:	f8042903          	lw	s2,-128(s0)
    800066da:	20090793          	addi	a5,s2,512
    800066de:	00479713          	slli	a4,a5,0x4
    800066e2:	0001d797          	auipc	a5,0x1d
    800066e6:	91e78793          	addi	a5,a5,-1762 # 80023000 <disk>
    800066ea:	97ba                	add	a5,a5,a4
    800066ec:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800066f0:	0001f997          	auipc	s3,0x1f
    800066f4:	91098993          	addi	s3,s3,-1776 # 80025000 <disk+0x2000>
    800066f8:	00491713          	slli	a4,s2,0x4
    800066fc:	0009b783          	ld	a5,0(s3)
    80006700:	97ba                	add	a5,a5,a4
    80006702:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006706:	854a                	mv	a0,s2
    80006708:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000670c:	00000097          	auipc	ra,0x0
    80006710:	c5a080e7          	jalr	-934(ra) # 80006366 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006714:	8885                	andi	s1,s1,1
    80006716:	f0ed                	bnez	s1,800066f8 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006718:	0001f517          	auipc	a0,0x1f
    8000671c:	a1050513          	addi	a0,a0,-1520 # 80025128 <disk+0x2128>
    80006720:	ffffa097          	auipc	ra,0xffffa
    80006724:	556080e7          	jalr	1366(ra) # 80000c76 <release>
}
    80006728:	70e6                	ld	ra,120(sp)
    8000672a:	7446                	ld	s0,112(sp)
    8000672c:	74a6                	ld	s1,104(sp)
    8000672e:	7906                	ld	s2,96(sp)
    80006730:	69e6                	ld	s3,88(sp)
    80006732:	6a46                	ld	s4,80(sp)
    80006734:	6aa6                	ld	s5,72(sp)
    80006736:	6b06                	ld	s6,64(sp)
    80006738:	7be2                	ld	s7,56(sp)
    8000673a:	7c42                	ld	s8,48(sp)
    8000673c:	7ca2                	ld	s9,40(sp)
    8000673e:	7d02                	ld	s10,32(sp)
    80006740:	6de2                	ld	s11,24(sp)
    80006742:	6109                	addi	sp,sp,128
    80006744:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006746:	f8042503          	lw	a0,-128(s0)
    8000674a:	20050793          	addi	a5,a0,512
    8000674e:	0792                	slli	a5,a5,0x4
  if(write)
    80006750:	0001d817          	auipc	a6,0x1d
    80006754:	8b080813          	addi	a6,a6,-1872 # 80023000 <disk>
    80006758:	00f80733          	add	a4,a6,a5
    8000675c:	01a036b3          	snez	a3,s10
    80006760:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006764:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006768:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000676c:	7679                	lui	a2,0xffffe
    8000676e:	963e                	add	a2,a2,a5
    80006770:	0001f697          	auipc	a3,0x1f
    80006774:	89068693          	addi	a3,a3,-1904 # 80025000 <disk+0x2000>
    80006778:	6298                	ld	a4,0(a3)
    8000677a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000677c:	0a878593          	addi	a1,a5,168
    80006780:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006782:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006784:	6298                	ld	a4,0(a3)
    80006786:	9732                	add	a4,a4,a2
    80006788:	45c1                	li	a1,16
    8000678a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000678c:	6298                	ld	a4,0(a3)
    8000678e:	9732                	add	a4,a4,a2
    80006790:	4585                	li	a1,1
    80006792:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006796:	f8442703          	lw	a4,-124(s0)
    8000679a:	628c                	ld	a1,0(a3)
    8000679c:	962e                	add	a2,a2,a1
    8000679e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    800067a2:	0712                	slli	a4,a4,0x4
    800067a4:	6290                	ld	a2,0(a3)
    800067a6:	963a                	add	a2,a2,a4
    800067a8:	058a8593          	addi	a1,s5,88
    800067ac:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800067ae:	6294                	ld	a3,0(a3)
    800067b0:	96ba                	add	a3,a3,a4
    800067b2:	40000613          	li	a2,1024
    800067b6:	c690                	sw	a2,8(a3)
  if(write)
    800067b8:	e40d19e3          	bnez	s10,8000660a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800067bc:	0001f697          	auipc	a3,0x1f
    800067c0:	8446b683          	ld	a3,-1980(a3) # 80025000 <disk+0x2000>
    800067c4:	96ba                	add	a3,a3,a4
    800067c6:	4609                	li	a2,2
    800067c8:	00c69623          	sh	a2,12(a3)
    800067cc:	b5b1                	j	80006618 <virtio_disk_rw+0xd2>

00000000800067ce <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800067ce:	1101                	addi	sp,sp,-32
    800067d0:	ec06                	sd	ra,24(sp)
    800067d2:	e822                	sd	s0,16(sp)
    800067d4:	e426                	sd	s1,8(sp)
    800067d6:	e04a                	sd	s2,0(sp)
    800067d8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800067da:	0001f517          	auipc	a0,0x1f
    800067de:	94e50513          	addi	a0,a0,-1714 # 80025128 <disk+0x2128>
    800067e2:	ffffa097          	auipc	ra,0xffffa
    800067e6:	3e0080e7          	jalr	992(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800067ea:	10001737          	lui	a4,0x10001
    800067ee:	533c                	lw	a5,96(a4)
    800067f0:	8b8d                	andi	a5,a5,3
    800067f2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800067f4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800067f8:	0001f797          	auipc	a5,0x1f
    800067fc:	80878793          	addi	a5,a5,-2040 # 80025000 <disk+0x2000>
    80006800:	6b94                	ld	a3,16(a5)
    80006802:	0207d703          	lhu	a4,32(a5)
    80006806:	0026d783          	lhu	a5,2(a3)
    8000680a:	06f70163          	beq	a4,a5,8000686c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000680e:	0001c917          	auipc	s2,0x1c
    80006812:	7f290913          	addi	s2,s2,2034 # 80023000 <disk>
    80006816:	0001e497          	auipc	s1,0x1e
    8000681a:	7ea48493          	addi	s1,s1,2026 # 80025000 <disk+0x2000>
    __sync_synchronize();
    8000681e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006822:	6898                	ld	a4,16(s1)
    80006824:	0204d783          	lhu	a5,32(s1)
    80006828:	8b9d                	andi	a5,a5,7
    8000682a:	078e                	slli	a5,a5,0x3
    8000682c:	97ba                	add	a5,a5,a4
    8000682e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006830:	20078713          	addi	a4,a5,512
    80006834:	0712                	slli	a4,a4,0x4
    80006836:	974a                	add	a4,a4,s2
    80006838:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000683c:	e731                	bnez	a4,80006888 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000683e:	20078793          	addi	a5,a5,512
    80006842:	0792                	slli	a5,a5,0x4
    80006844:	97ca                	add	a5,a5,s2
    80006846:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006848:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000684c:	ffffc097          	auipc	ra,0xffffc
    80006850:	c80080e7          	jalr	-896(ra) # 800024cc <wakeup>

    disk.used_idx += 1;
    80006854:	0204d783          	lhu	a5,32(s1)
    80006858:	2785                	addiw	a5,a5,1
    8000685a:	17c2                	slli	a5,a5,0x30
    8000685c:	93c1                	srli	a5,a5,0x30
    8000685e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006862:	6898                	ld	a4,16(s1)
    80006864:	00275703          	lhu	a4,2(a4)
    80006868:	faf71be3          	bne	a4,a5,8000681e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000686c:	0001f517          	auipc	a0,0x1f
    80006870:	8bc50513          	addi	a0,a0,-1860 # 80025128 <disk+0x2128>
    80006874:	ffffa097          	auipc	ra,0xffffa
    80006878:	402080e7          	jalr	1026(ra) # 80000c76 <release>
}
    8000687c:	60e2                	ld	ra,24(sp)
    8000687e:	6442                	ld	s0,16(sp)
    80006880:	64a2                	ld	s1,8(sp)
    80006882:	6902                	ld	s2,0(sp)
    80006884:	6105                	addi	sp,sp,32
    80006886:	8082                	ret
      panic("virtio_disk_intr status");
    80006888:	00002517          	auipc	a0,0x2
    8000688c:	27050513          	addi	a0,a0,624 # 80008af8 <syscalls+0x3c0>
    80006890:	ffffa097          	auipc	ra,0xffffa
    80006894:	c9a080e7          	jalr	-870(ra) # 8000052a <panic>
    80006890:	ffffa097          	auipc	ra,0xffffa
    80006894:	c9a080e7          	jalr	-870(ra) # 8000052a <panic>
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
