
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
    80000068:	dac78793          	addi	a5,a5,-596 # 80006e10 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffbc7ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	de478793          	addi	a5,a5,-540 # 80000e92 <main>
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
    8000011e:	00003097          	auipc	ra,0x3
    80000122:	94c080e7          	jalr	-1716(ra) # 80002a6a <either_copyin>
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
    8000017c:	00012517          	auipc	a0,0x12
    80000180:	00450513          	addi	a0,a0,4 # 80012180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a42080e7          	jalr	-1470(ra) # 80000bc6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00012497          	auipc	s1,0x12
    80000190:	ff448493          	addi	s1,s1,-12 # 80012180 <cons>
      if(myproc()->killed==1){
    80000194:	4905                	li	s2,1
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000196:	00012997          	auipc	s3,0x12
    8000019a:	08298993          	addi	s3,s3,130 # 80012218 <cons+0x98>
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
    800001b2:	00002097          	auipc	ra,0x2
    800001b6:	8ca080e7          	jalr	-1846(ra) # 80001a7c <myproc>
    800001ba:	4d5c                	lw	a5,28(a0)
    800001bc:	07278863          	beq	a5,s2,8000022c <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001c0:	85a6                	mv	a1,s1
    800001c2:	854e                	mv	a0,s3
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	240080e7          	jalr	576(ra) # 80002404 <sleep>
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
    80000200:	00003097          	auipc	ra,0x3
    80000204:	814080e7          	jalr	-2028(ra) # 80002a14 <either_copyout>
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
    80000216:	00012517          	auipc	a0,0x12
    8000021a:	f6a50513          	addi	a0,a0,-150 # 80012180 <cons>
    8000021e:	00001097          	auipc	ra,0x1
    80000222:	a7e080e7          	jalr	-1410(ra) # 80000c9c <release>

  return target - n;
    80000226:	414b853b          	subw	a0,s7,s4
    8000022a:	a811                	j	8000023e <consoleread+0xe8>
        release(&cons.lock);
    8000022c:	00012517          	auipc	a0,0x12
    80000230:	f5450513          	addi	a0,a0,-172 # 80012180 <cons>
    80000234:	00001097          	auipc	ra,0x1
    80000238:	a68080e7          	jalr	-1432(ra) # 80000c9c <release>
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
    80000262:	00012717          	auipc	a4,0x12
    80000266:	faf72b23          	sw	a5,-74(a4) # 80012218 <cons+0x98>
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
    800002bc:	00012517          	auipc	a0,0x12
    800002c0:	ec450513          	addi	a0,a0,-316 # 80012180 <cons>
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
    800002e6:	7de080e7          	jalr	2014(ra) # 80002ac0 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ea:	00012517          	auipc	a0,0x12
    800002ee:	e9650513          	addi	a0,a0,-362 # 80012180 <cons>
    800002f2:	00001097          	auipc	ra,0x1
    800002f6:	9aa080e7          	jalr	-1622(ra) # 80000c9c <release>
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
    8000030e:	00012717          	auipc	a4,0x12
    80000312:	e7270713          	addi	a4,a4,-398 # 80012180 <cons>
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
    80000338:	00012797          	auipc	a5,0x12
    8000033c:	e4878793          	addi	a5,a5,-440 # 80012180 <cons>
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
    80000366:	00012797          	auipc	a5,0x12
    8000036a:	eb27a783          	lw	a5,-334(a5) # 80012218 <cons+0x98>
    8000036e:	0807879b          	addiw	a5,a5,128
    80000372:	f6f61ce3          	bne	a2,a5,800002ea <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000376:	863e                	mv	a2,a5
    80000378:	a07d                	j	80000426 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000037a:	00012717          	auipc	a4,0x12
    8000037e:	e0670713          	addi	a4,a4,-506 # 80012180 <cons>
    80000382:	0a072783          	lw	a5,160(a4)
    80000386:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000038a:	00012497          	auipc	s1,0x12
    8000038e:	df648493          	addi	s1,s1,-522 # 80012180 <cons>
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
    800003c6:	00012717          	auipc	a4,0x12
    800003ca:	dba70713          	addi	a4,a4,-582 # 80012180 <cons>
    800003ce:	0a072783          	lw	a5,160(a4)
    800003d2:	09c72703          	lw	a4,156(a4)
    800003d6:	f0f70ae3          	beq	a4,a5,800002ea <consoleintr+0x3c>
      cons.e--;
    800003da:	37fd                	addiw	a5,a5,-1
    800003dc:	00012717          	auipc	a4,0x12
    800003e0:	e4f72223          	sw	a5,-444(a4) # 80012220 <cons+0xa0>
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
    80000402:	00012797          	auipc	a5,0x12
    80000406:	d7e78793          	addi	a5,a5,-642 # 80012180 <cons>
    8000040a:	0a07a703          	lw	a4,160(a5)
    8000040e:	0017069b          	addiw	a3,a4,1
    80000412:	0006861b          	sext.w	a2,a3
    80000416:	0ad7a023          	sw	a3,160(a5)
    8000041a:	07f77713          	andi	a4,a4,127
    8000041e:	97ba                	add	a5,a5,a4
    80000420:	4729                	li	a4,10
    80000422:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000426:	00012797          	auipc	a5,0x12
    8000042a:	dec7ab23          	sw	a2,-522(a5) # 8001221c <cons+0x9c>
        wakeup(&cons.r);
    8000042e:	00012517          	auipc	a0,0x12
    80000432:	dea50513          	addi	a0,a0,-534 # 80012218 <cons+0x98>
    80000436:	00002097          	auipc	ra,0x2
    8000043a:	190080e7          	jalr	400(ra) # 800025c6 <wakeup>
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
    80000448:	00009597          	auipc	a1,0x9
    8000044c:	bc858593          	addi	a1,a1,-1080 # 80009010 <etext+0x10>
    80000450:	00012517          	auipc	a0,0x12
    80000454:	d3050513          	addi	a0,a0,-720 # 80012180 <cons>
    80000458:	00000097          	auipc	ra,0x0
    8000045c:	6de080e7          	jalr	1758(ra) # 80000b36 <initlock>

  uartinit();
    80000460:	00000097          	auipc	ra,0x0
    80000464:	32a080e7          	jalr	810(ra) # 8000078a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000468:	0003d797          	auipc	a5,0x3d
    8000046c:	70878793          	addi	a5,a5,1800 # 8003db70 <devsw>
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
    800004aa:	00009617          	auipc	a2,0x9
    800004ae:	b9660613          	addi	a2,a2,-1130 # 80009040 <digits>
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
    8000053a:	00012797          	auipc	a5,0x12
    8000053e:	d007a323          	sw	zero,-762(a5) # 80012240 <pr+0x18>
  printf("panic: ");
    80000542:	00009517          	auipc	a0,0x9
    80000546:	ad650513          	addi	a0,a0,-1322 # 80009018 <etext+0x18>
    8000054a:	00000097          	auipc	ra,0x0
    8000054e:	02e080e7          	jalr	46(ra) # 80000578 <printf>
  printf(s);
    80000552:	8526                	mv	a0,s1
    80000554:	00000097          	auipc	ra,0x0
    80000558:	024080e7          	jalr	36(ra) # 80000578 <printf>
  printf("\n");
    8000055c:	00009517          	auipc	a0,0x9
    80000560:	e1450513          	addi	a0,a0,-492 # 80009370 <digits+0x330>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	014080e7          	jalr	20(ra) # 80000578 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000056c:	4785                	li	a5,1
    8000056e:	0000a717          	auipc	a4,0xa
    80000572:	a8f72923          	sw	a5,-1390(a4) # 8000a000 <panicked>
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
    800005aa:	00012d97          	auipc	s11,0x12
    800005ae:	c96dad83          	lw	s11,-874(s11) # 80012240 <pr+0x18>
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
    800005d6:	00009b17          	auipc	s6,0x9
    800005da:	a6ab0b13          	addi	s6,s6,-1430 # 80009040 <digits>
    switch(c){
    800005de:	07300c93          	li	s9,115
    800005e2:	06400c13          	li	s8,100
    800005e6:	a82d                	j	80000620 <printf+0xa8>
    acquire(&pr.lock);
    800005e8:	00012517          	auipc	a0,0x12
    800005ec:	c4050513          	addi	a0,a0,-960 # 80012228 <pr>
    800005f0:	00000097          	auipc	ra,0x0
    800005f4:	5d6080e7          	jalr	1494(ra) # 80000bc6 <acquire>
    800005f8:	bf7d                	j	800005b6 <printf+0x3e>
    panic("null fmt");
    800005fa:	00009517          	auipc	a0,0x9
    800005fe:	a2e50513          	addi	a0,a0,-1490 # 80009028 <etext+0x28>
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
    800006f4:	00009497          	auipc	s1,0x9
    800006f8:	92c48493          	addi	s1,s1,-1748 # 80009020 <etext+0x20>
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
    80000746:	00012517          	auipc	a0,0x12
    8000074a:	ae250513          	addi	a0,a0,-1310 # 80012228 <pr>
    8000074e:	00000097          	auipc	ra,0x0
    80000752:	54e080e7          	jalr	1358(ra) # 80000c9c <release>
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
    80000762:	00012497          	auipc	s1,0x12
    80000766:	ac648493          	addi	s1,s1,-1338 # 80012228 <pr>
    8000076a:	00009597          	auipc	a1,0x9
    8000076e:	8ce58593          	addi	a1,a1,-1842 # 80009038 <etext+0x38>
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
    800007ba:	00009597          	auipc	a1,0x9
    800007be:	89e58593          	addi	a1,a1,-1890 # 80009058 <digits+0x18>
    800007c2:	00012517          	auipc	a0,0x12
    800007c6:	a8650513          	addi	a0,a0,-1402 # 80012248 <uart_tx_lock>
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
    800007ee:	0000a797          	auipc	a5,0xa
    800007f2:	8127a783          	lw	a5,-2030(a5) # 8000a000 <panicked>
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
    80000818:	428080e7          	jalr	1064(ra) # 80000c3c <pop_off>
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
    80000826:	00009797          	auipc	a5,0x9
    8000082a:	7e27b783          	ld	a5,2018(a5) # 8000a008 <uart_tx_r>
    8000082e:	00009717          	auipc	a4,0x9
    80000832:	7e273703          	ld	a4,2018(a4) # 8000a010 <uart_tx_w>
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
    80000850:	00012a17          	auipc	s4,0x12
    80000854:	9f8a0a13          	addi	s4,s4,-1544 # 80012248 <uart_tx_lock>
    uart_tx_r += 1;
    80000858:	00009497          	auipc	s1,0x9
    8000085c:	7b048493          	addi	s1,s1,1968 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000860:	00009997          	auipc	s3,0x9
    80000864:	7b098993          	addi	s3,s3,1968 # 8000a010 <uart_tx_w>
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
    80000886:	d44080e7          	jalr	-700(ra) # 800025c6 <wakeup>
    
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
    800008be:	00012517          	auipc	a0,0x12
    800008c2:	98a50513          	addi	a0,a0,-1654 # 80012248 <uart_tx_lock>
    800008c6:	00000097          	auipc	ra,0x0
    800008ca:	300080e7          	jalr	768(ra) # 80000bc6 <acquire>
  if(panicked){
    800008ce:	00009797          	auipc	a5,0x9
    800008d2:	7327a783          	lw	a5,1842(a5) # 8000a000 <panicked>
    800008d6:	c391                	beqz	a5,800008da <uartputc+0x2e>
    for(;;)
    800008d8:	a001                	j	800008d8 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008da:	00009717          	auipc	a4,0x9
    800008de:	73673703          	ld	a4,1846(a4) # 8000a010 <uart_tx_w>
    800008e2:	00009797          	auipc	a5,0x9
    800008e6:	7267b783          	ld	a5,1830(a5) # 8000a008 <uart_tx_r>
    800008ea:	02078793          	addi	a5,a5,32
    800008ee:	02e79b63          	bne	a5,a4,80000924 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008f2:	00012997          	auipc	s3,0x12
    800008f6:	95698993          	addi	s3,s3,-1706 # 80012248 <uart_tx_lock>
    800008fa:	00009497          	auipc	s1,0x9
    800008fe:	70e48493          	addi	s1,s1,1806 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000902:	00009917          	auipc	s2,0x9
    80000906:	70e90913          	addi	s2,s2,1806 # 8000a010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000090a:	85ce                	mv	a1,s3
    8000090c:	8526                	mv	a0,s1
    8000090e:	00002097          	auipc	ra,0x2
    80000912:	af6080e7          	jalr	-1290(ra) # 80002404 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000916:	00093703          	ld	a4,0(s2)
    8000091a:	609c                	ld	a5,0(s1)
    8000091c:	02078793          	addi	a5,a5,32
    80000920:	fee785e3          	beq	a5,a4,8000090a <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000924:	00012497          	auipc	s1,0x12
    80000928:	92448493          	addi	s1,s1,-1756 # 80012248 <uart_tx_lock>
    8000092c:	01f77793          	andi	a5,a4,31
    80000930:	97a6                	add	a5,a5,s1
    80000932:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000936:	0705                	addi	a4,a4,1
    80000938:	00009797          	auipc	a5,0x9
    8000093c:	6ce7bc23          	sd	a4,1752(a5) # 8000a010 <uart_tx_w>
      uartstart();
    80000940:	00000097          	auipc	ra,0x0
    80000944:	ee6080e7          	jalr	-282(ra) # 80000826 <uartstart>
      release(&uart_tx_lock);
    80000948:	8526                	mv	a0,s1
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	352080e7          	jalr	850(ra) # 80000c9c <release>
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
    800009ac:	00012497          	auipc	s1,0x12
    800009b0:	89c48493          	addi	s1,s1,-1892 # 80012248 <uart_tx_lock>
    800009b4:	8526                	mv	a0,s1
    800009b6:	00000097          	auipc	ra,0x0
    800009ba:	210080e7          	jalr	528(ra) # 80000bc6 <acquire>
  uartstart();
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	e68080e7          	jalr	-408(ra) # 80000826 <uartstart>
  release(&uart_tx_lock);
    800009c6:	8526                	mv	a0,s1
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	2d4080e7          	jalr	724(ra) # 80000c9c <release>
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
    800009ee:	00041797          	auipc	a5,0x41
    800009f2:	61278793          	addi	a5,a5,1554 # 80042000 <end>
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
    80000a0a:	2de080e7          	jalr	734(ra) # 80000ce4 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a0e:	00012917          	auipc	s2,0x12
    80000a12:	87290913          	addi	s2,s2,-1934 # 80012280 <kmem>
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
    80000a30:	270080e7          	jalr	624(ra) # 80000c9c <release>
}
    80000a34:	60e2                	ld	ra,24(sp)
    80000a36:	6442                	ld	s0,16(sp)
    80000a38:	64a2                	ld	s1,8(sp)
    80000a3a:	6902                	ld	s2,0(sp)
    80000a3c:	6105                	addi	sp,sp,32
    80000a3e:	8082                	ret
    panic("kfree");
    80000a40:	00008517          	auipc	a0,0x8
    80000a44:	62050513          	addi	a0,a0,1568 # 80009060 <digits+0x20>
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
    80000aa2:	00008597          	auipc	a1,0x8
    80000aa6:	5c658593          	addi	a1,a1,1478 # 80009068 <digits+0x28>
    80000aaa:	00011517          	auipc	a0,0x11
    80000aae:	7d650513          	addi	a0,a0,2006 # 80012280 <kmem>
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	084080e7          	jalr	132(ra) # 80000b36 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aba:	45c5                	li	a1,17
    80000abc:	05ee                	slli	a1,a1,0x1b
    80000abe:	00041517          	auipc	a0,0x41
    80000ac2:	54250513          	addi	a0,a0,1346 # 80042000 <end>
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
    80000ae0:	00011497          	auipc	s1,0x11
    80000ae4:	7a048493          	addi	s1,s1,1952 # 80012280 <kmem>
    80000ae8:	8526                	mv	a0,s1
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	0dc080e7          	jalr	220(ra) # 80000bc6 <acquire>
  r = kmem.freelist;
    80000af2:	6c84                	ld	s1,24(s1)
  if(r)
    80000af4:	c885                	beqz	s1,80000b24 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af6:	609c                	ld	a5,0(s1)
    80000af8:	00011517          	auipc	a0,0x11
    80000afc:	78850513          	addi	a0,a0,1928 # 80012280 <kmem>
    80000b00:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b02:	00000097          	auipc	ra,0x0
    80000b06:	19a080e7          	jalr	410(ra) # 80000c9c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b0a:	6605                	lui	a2,0x1
    80000b0c:	4595                	li	a1,5
    80000b0e:	8526                	mv	a0,s1
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	1d4080e7          	jalr	468(ra) # 80000ce4 <memset>
  return (void*)r;
}
    80000b18:	8526                	mv	a0,s1
    80000b1a:	60e2                	ld	ra,24(sp)
    80000b1c:	6442                	ld	s0,16(sp)
    80000b1e:	64a2                	ld	s1,8(sp)
    80000b20:	6105                	addi	sp,sp,32
    80000b22:	8082                	ret
  release(&kmem.lock);
    80000b24:	00011517          	auipc	a0,0x11
    80000b28:	75c50513          	addi	a0,a0,1884 # 80012280 <kmem>
    80000b2c:	00000097          	auipc	ra,0x0
    80000b30:	170080e7          	jalr	368(ra) # 80000c9c <release>
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
    80000b64:	ef8080e7          	jalr	-264(ra) # 80001a58 <mycpu>
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
    80000b96:	ec6080e7          	jalr	-314(ra) # 80001a58 <mycpu>
    80000b9a:	5d3c                	lw	a5,120(a0)
    80000b9c:	cf89                	beqz	a5,80000bb6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	eba080e7          	jalr	-326(ra) # 80001a58 <mycpu>
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
    80000bba:	ea2080e7          	jalr	-350(ra) # 80001a58 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bbe:	8085                	srli	s1,s1,0x1
    80000bc0:	8885                	andi	s1,s1,1
    80000bc2:	dd64                	sw	s1,124(a0)
    80000bc4:	bfe9                	j	80000b9e <push_off+0x24>

0000000080000bc6 <acquire>:
acquire(struct spinlock *lk){
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
    80000bfa:	e62080e7          	jalr	-414(ra) # 80001a58 <mycpu>
    80000bfe:	e888                	sd	a0,16(s1)
}
    80000c00:	60e2                	ld	ra,24(sp)
    80000c02:	6442                	ld	s0,16(sp)
    80000c04:	64a2                	ld	s1,8(sp)
    80000c06:	6105                	addi	sp,sp,32
    80000c08:	8082                	ret
    printf("pid=%d tid=%d tried to lock when already holding\n",lk->cpu->proc->pid,mykthread()->tid);//TODO delete
    80000c0a:	689c                	ld	a5,16(s1)
    80000c0c:	639c                	ld	a5,0(a5)
    80000c0e:	53c4                	lw	s1,36(a5)
    80000c10:	00001097          	auipc	ra,0x1
    80000c14:	eac080e7          	jalr	-340(ra) # 80001abc <mykthread>
    80000c18:	5910                	lw	a2,48(a0)
    80000c1a:	85a6                	mv	a1,s1
    80000c1c:	00008517          	auipc	a0,0x8
    80000c20:	45450513          	addi	a0,a0,1108 # 80009070 <digits+0x30>
    80000c24:	00000097          	auipc	ra,0x0
    80000c28:	954080e7          	jalr	-1708(ra) # 80000578 <printf>
    panic("acquire");
    80000c2c:	00008517          	auipc	a0,0x8
    80000c30:	47c50513          	addi	a0,a0,1148 # 800090a8 <digits+0x68>
    80000c34:	00000097          	auipc	ra,0x0
    80000c38:	8fa080e7          	jalr	-1798(ra) # 8000052e <panic>

0000000080000c3c <pop_off>:

void
pop_off(void)
{
    80000c3c:	1141                	addi	sp,sp,-16
    80000c3e:	e406                	sd	ra,8(sp)
    80000c40:	e022                	sd	s0,0(sp)
    80000c42:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c44:	00001097          	auipc	ra,0x1
    80000c48:	e14080e7          	jalr	-492(ra) # 80001a58 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c50:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c52:	e78d                	bnez	a5,80000c7c <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c54:	5d3c                	lw	a5,120(a0)
    80000c56:	02f05b63          	blez	a5,80000c8c <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c5a:	37fd                	addiw	a5,a5,-1
    80000c5c:	0007871b          	sext.w	a4,a5
    80000c60:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c62:	eb09                	bnez	a4,80000c74 <pop_off+0x38>
    80000c64:	5d7c                	lw	a5,124(a0)
    80000c66:	c799                	beqz	a5,80000c74 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c68:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c6c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c70:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c74:	60a2                	ld	ra,8(sp)
    80000c76:	6402                	ld	s0,0(sp)
    80000c78:	0141                	addi	sp,sp,16
    80000c7a:	8082                	ret
    panic("pop_off - interruptible");
    80000c7c:	00008517          	auipc	a0,0x8
    80000c80:	43450513          	addi	a0,a0,1076 # 800090b0 <digits+0x70>
    80000c84:	00000097          	auipc	ra,0x0
    80000c88:	8aa080e7          	jalr	-1878(ra) # 8000052e <panic>
    panic("pop_off");
    80000c8c:	00008517          	auipc	a0,0x8
    80000c90:	43c50513          	addi	a0,a0,1084 # 800090c8 <digits+0x88>
    80000c94:	00000097          	auipc	ra,0x0
    80000c98:	89a080e7          	jalr	-1894(ra) # 8000052e <panic>

0000000080000c9c <release>:
{
    80000c9c:	1101                	addi	sp,sp,-32
    80000c9e:	ec06                	sd	ra,24(sp)
    80000ca0:	e822                	sd	s0,16(sp)
    80000ca2:	e426                	sd	s1,8(sp)
    80000ca4:	1000                	addi	s0,sp,32
    80000ca6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ca8:	00000097          	auipc	ra,0x0
    80000cac:	ea4080e7          	jalr	-348(ra) # 80000b4c <holding>
    80000cb0:	c115                	beqz	a0,80000cd4 <release+0x38>
  lk->cpu = 0;
    80000cb2:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb6:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cba:	0f50000f          	fence	iorw,ow
    80000cbe:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cc2:	00000097          	auipc	ra,0x0
    80000cc6:	f7a080e7          	jalr	-134(ra) # 80000c3c <pop_off>
}
    80000cca:	60e2                	ld	ra,24(sp)
    80000ccc:	6442                	ld	s0,16(sp)
    80000cce:	64a2                	ld	s1,8(sp)
    80000cd0:	6105                	addi	sp,sp,32
    80000cd2:	8082                	ret
    panic("release");
    80000cd4:	00008517          	auipc	a0,0x8
    80000cd8:	3fc50513          	addi	a0,a0,1020 # 800090d0 <digits+0x90>
    80000cdc:	00000097          	auipc	ra,0x0
    80000ce0:	852080e7          	jalr	-1966(ra) # 8000052e <panic>

0000000080000ce4 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ce4:	1141                	addi	sp,sp,-16
    80000ce6:	e422                	sd	s0,8(sp)
    80000ce8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cea:	ca19                	beqz	a2,80000d00 <memset+0x1c>
    80000cec:	87aa                	mv	a5,a0
    80000cee:	1602                	slli	a2,a2,0x20
    80000cf0:	9201                	srli	a2,a2,0x20
    80000cf2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cf6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cfa:	0785                	addi	a5,a5,1
    80000cfc:	fee79de3          	bne	a5,a4,80000cf6 <memset+0x12>
  }
  return dst;
}
    80000d00:	6422                	ld	s0,8(sp)
    80000d02:	0141                	addi	sp,sp,16
    80000d04:	8082                	ret

0000000080000d06 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d06:	1141                	addi	sp,sp,-16
    80000d08:	e422                	sd	s0,8(sp)
    80000d0a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d0c:	ca05                	beqz	a2,80000d3c <memcmp+0x36>
    80000d0e:	fff6069b          	addiw	a3,a2,-1
    80000d12:	1682                	slli	a3,a3,0x20
    80000d14:	9281                	srli	a3,a3,0x20
    80000d16:	0685                	addi	a3,a3,1
    80000d18:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d1a:	00054783          	lbu	a5,0(a0)
    80000d1e:	0005c703          	lbu	a4,0(a1)
    80000d22:	00e79863          	bne	a5,a4,80000d32 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d26:	0505                	addi	a0,a0,1
    80000d28:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d2a:	fed518e3          	bne	a0,a3,80000d1a <memcmp+0x14>
  }

  return 0;
    80000d2e:	4501                	li	a0,0
    80000d30:	a019                	j	80000d36 <memcmp+0x30>
      return *s1 - *s2;
    80000d32:	40e7853b          	subw	a0,a5,a4
}
    80000d36:	6422                	ld	s0,8(sp)
    80000d38:	0141                	addi	sp,sp,16
    80000d3a:	8082                	ret
  return 0;
    80000d3c:	4501                	li	a0,0
    80000d3e:	bfe5                	j	80000d36 <memcmp+0x30>

0000000080000d40 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d40:	1141                	addi	sp,sp,-16
    80000d42:	e422                	sd	s0,8(sp)
    80000d44:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d46:	02a5e563          	bltu	a1,a0,80000d70 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d4a:	fff6069b          	addiw	a3,a2,-1
    80000d4e:	ce11                	beqz	a2,80000d6a <memmove+0x2a>
    80000d50:	1682                	slli	a3,a3,0x20
    80000d52:	9281                	srli	a3,a3,0x20
    80000d54:	0685                	addi	a3,a3,1
    80000d56:	96ae                	add	a3,a3,a1
    80000d58:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d5a:	0585                	addi	a1,a1,1
    80000d5c:	0785                	addi	a5,a5,1
    80000d5e:	fff5c703          	lbu	a4,-1(a1)
    80000d62:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d66:	fed59ae3          	bne	a1,a3,80000d5a <memmove+0x1a>

  return dst;
}
    80000d6a:	6422                	ld	s0,8(sp)
    80000d6c:	0141                	addi	sp,sp,16
    80000d6e:	8082                	ret
  if(s < d && s + n > d){
    80000d70:	02061713          	slli	a4,a2,0x20
    80000d74:	9301                	srli	a4,a4,0x20
    80000d76:	00e587b3          	add	a5,a1,a4
    80000d7a:	fcf578e3          	bgeu	a0,a5,80000d4a <memmove+0xa>
    d += n;
    80000d7e:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d80:	fff6069b          	addiw	a3,a2,-1
    80000d84:	d27d                	beqz	a2,80000d6a <memmove+0x2a>
    80000d86:	02069613          	slli	a2,a3,0x20
    80000d8a:	9201                	srli	a2,a2,0x20
    80000d8c:	fff64613          	not	a2,a2
    80000d90:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d92:	17fd                	addi	a5,a5,-1
    80000d94:	177d                	addi	a4,a4,-1
    80000d96:	0007c683          	lbu	a3,0(a5)
    80000d9a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d9e:	fef61ae3          	bne	a2,a5,80000d92 <memmove+0x52>
    80000da2:	b7e1                	j	80000d6a <memmove+0x2a>

0000000080000da4 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e406                	sd	ra,8(sp)
    80000da8:	e022                	sd	s0,0(sp)
    80000daa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dac:	00000097          	auipc	ra,0x0
    80000db0:	f94080e7          	jalr	-108(ra) # 80000d40 <memmove>
}
    80000db4:	60a2                	ld	ra,8(sp)
    80000db6:	6402                	ld	s0,0(sp)
    80000db8:	0141                	addi	sp,sp,16
    80000dba:	8082                	ret

0000000080000dbc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dbc:	1141                	addi	sp,sp,-16
    80000dbe:	e422                	sd	s0,8(sp)
    80000dc0:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dc2:	ce11                	beqz	a2,80000dde <strncmp+0x22>
    80000dc4:	00054783          	lbu	a5,0(a0)
    80000dc8:	cf89                	beqz	a5,80000de2 <strncmp+0x26>
    80000dca:	0005c703          	lbu	a4,0(a1)
    80000dce:	00f71a63          	bne	a4,a5,80000de2 <strncmp+0x26>
    n--, p++, q++;
    80000dd2:	367d                	addiw	a2,a2,-1
    80000dd4:	0505                	addi	a0,a0,1
    80000dd6:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dd8:	f675                	bnez	a2,80000dc4 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	a809                	j	80000dee <strncmp+0x32>
    80000dde:	4501                	li	a0,0
    80000de0:	a039                	j	80000dee <strncmp+0x32>
  if(n == 0)
    80000de2:	ca09                	beqz	a2,80000df4 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000de4:	00054503          	lbu	a0,0(a0)
    80000de8:	0005c783          	lbu	a5,0(a1)
    80000dec:	9d1d                	subw	a0,a0,a5
}
    80000dee:	6422                	ld	s0,8(sp)
    80000df0:	0141                	addi	sp,sp,16
    80000df2:	8082                	ret
    return 0;
    80000df4:	4501                	li	a0,0
    80000df6:	bfe5                	j	80000dee <strncmp+0x32>

0000000080000df8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000df8:	1141                	addi	sp,sp,-16
    80000dfa:	e422                	sd	s0,8(sp)
    80000dfc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dfe:	872a                	mv	a4,a0
    80000e00:	8832                	mv	a6,a2
    80000e02:	367d                	addiw	a2,a2,-1
    80000e04:	01005963          	blez	a6,80000e16 <strncpy+0x1e>
    80000e08:	0705                	addi	a4,a4,1
    80000e0a:	0005c783          	lbu	a5,0(a1)
    80000e0e:	fef70fa3          	sb	a5,-1(a4)
    80000e12:	0585                	addi	a1,a1,1
    80000e14:	f7f5                	bnez	a5,80000e00 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e16:	86ba                	mv	a3,a4
    80000e18:	00c05c63          	blez	a2,80000e30 <strncpy+0x38>
    *s++ = 0;
    80000e1c:	0685                	addi	a3,a3,1
    80000e1e:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e22:	fff6c793          	not	a5,a3
    80000e26:	9fb9                	addw	a5,a5,a4
    80000e28:	010787bb          	addw	a5,a5,a6
    80000e2c:	fef048e3          	bgtz	a5,80000e1c <strncpy+0x24>
  return os;
}
    80000e30:	6422                	ld	s0,8(sp)
    80000e32:	0141                	addi	sp,sp,16
    80000e34:	8082                	ret

0000000080000e36 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e36:	1141                	addi	sp,sp,-16
    80000e38:	e422                	sd	s0,8(sp)
    80000e3a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e3c:	02c05363          	blez	a2,80000e62 <safestrcpy+0x2c>
    80000e40:	fff6069b          	addiw	a3,a2,-1
    80000e44:	1682                	slli	a3,a3,0x20
    80000e46:	9281                	srli	a3,a3,0x20
    80000e48:	96ae                	add	a3,a3,a1
    80000e4a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e4c:	00d58963          	beq	a1,a3,80000e5e <safestrcpy+0x28>
    80000e50:	0585                	addi	a1,a1,1
    80000e52:	0785                	addi	a5,a5,1
    80000e54:	fff5c703          	lbu	a4,-1(a1)
    80000e58:	fee78fa3          	sb	a4,-1(a5)
    80000e5c:	fb65                	bnez	a4,80000e4c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e5e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e62:	6422                	ld	s0,8(sp)
    80000e64:	0141                	addi	sp,sp,16
    80000e66:	8082                	ret

0000000080000e68 <strlen>:

int
strlen(const char *s)
{
    80000e68:	1141                	addi	sp,sp,-16
    80000e6a:	e422                	sd	s0,8(sp)
    80000e6c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e6e:	00054783          	lbu	a5,0(a0)
    80000e72:	cf91                	beqz	a5,80000e8e <strlen+0x26>
    80000e74:	0505                	addi	a0,a0,1
    80000e76:	87aa                	mv	a5,a0
    80000e78:	4685                	li	a3,1
    80000e7a:	9e89                	subw	a3,a3,a0
    80000e7c:	00f6853b          	addw	a0,a3,a5
    80000e80:	0785                	addi	a5,a5,1
    80000e82:	fff7c703          	lbu	a4,-1(a5)
    80000e86:	fb7d                	bnez	a4,80000e7c <strlen+0x14>
    ;
  return n;
}
    80000e88:	6422                	ld	s0,8(sp)
    80000e8a:	0141                	addi	sp,sp,16
    80000e8c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e8e:	4501                	li	a0,0
    80000e90:	bfe5                	j	80000e88 <strlen+0x20>

0000000080000e92 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e92:	1141                	addi	sp,sp,-16
    80000e94:	e406                	sd	ra,8(sp)
    80000e96:	e022                	sd	s0,0(sp)
    80000e98:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e9a:	00001097          	auipc	ra,0x1
    80000e9e:	bae080e7          	jalr	-1106(ra) # 80001a48 <cpuid>
    userinit();      // first user process
    __sync_synchronize();

    started = 1;
  } else {
    while(started == 0)
    80000ea2:	00009717          	auipc	a4,0x9
    80000ea6:	17670713          	addi	a4,a4,374 # 8000a018 <started>
  if(cpuid() == 0){
    80000eaa:	c139                	beqz	a0,80000ef0 <main+0x5e>
    while(started == 0)
    80000eac:	431c                	lw	a5,0(a4)
    80000eae:	2781                	sext.w	a5,a5
    80000eb0:	dff5                	beqz	a5,80000eac <main+0x1a>
      ;
    __sync_synchronize();
    80000eb2:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eb6:	00001097          	auipc	ra,0x1
    80000eba:	b92080e7          	jalr	-1134(ra) # 80001a48 <cpuid>
    80000ebe:	85aa                	mv	a1,a0
    80000ec0:	00008517          	auipc	a0,0x8
    80000ec4:	23050513          	addi	a0,a0,560 # 800090f0 <digits+0xb0>
    80000ec8:	fffff097          	auipc	ra,0xfffff
    80000ecc:	6b0080e7          	jalr	1712(ra) # 80000578 <printf>
    kvminithart();    // turn on paging
    80000ed0:	00000097          	auipc	ra,0x0
    80000ed4:	0d8080e7          	jalr	216(ra) # 80000fa8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ed8:	00002097          	auipc	ra,0x2
    80000edc:	3e2080e7          	jalr	994(ra) # 800032ba <trapinithart>

    plicinithart();   // ask PLIC for device interrupts
    80000ee0:	00006097          	auipc	ra,0x6
    80000ee4:	f70080e7          	jalr	-144(ra) # 80006e50 <plicinithart>
  }

  scheduler();        
    80000ee8:	00001097          	auipc	ra,0x1
    80000eec:	2e2080e7          	jalr	738(ra) # 800021ca <scheduler>
    consoleinit();
    80000ef0:	fffff097          	auipc	ra,0xfffff
    80000ef4:	550080e7          	jalr	1360(ra) # 80000440 <consoleinit>
    printfinit();
    80000ef8:	00000097          	auipc	ra,0x0
    80000efc:	860080e7          	jalr	-1952(ra) # 80000758 <printfinit>
    printf("\n");
    80000f00:	00008517          	auipc	a0,0x8
    80000f04:	47050513          	addi	a0,a0,1136 # 80009370 <digits+0x330>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	670080e7          	jalr	1648(ra) # 80000578 <printf>
    printf("xv6 kernel is booting\n");
    80000f10:	00008517          	auipc	a0,0x8
    80000f14:	1c850513          	addi	a0,a0,456 # 800090d8 <digits+0x98>
    80000f18:	fffff097          	auipc	ra,0xfffff
    80000f1c:	660080e7          	jalr	1632(ra) # 80000578 <printf>
    printf("\n");
    80000f20:	00008517          	auipc	a0,0x8
    80000f24:	45050513          	addi	a0,a0,1104 # 80009370 <digits+0x330>
    80000f28:	fffff097          	auipc	ra,0xfffff
    80000f2c:	650080e7          	jalr	1616(ra) # 80000578 <printf>
    kinit();         // physical page allocator
    80000f30:	00000097          	auipc	ra,0x0
    80000f34:	b6a080e7          	jalr	-1174(ra) # 80000a9a <kinit>
    kvminit();       // create kernel page table
    80000f38:	00000097          	auipc	ra,0x0
    80000f3c:	310080e7          	jalr	784(ra) # 80001248 <kvminit>
    kvminithart();   // turn on paging
    80000f40:	00000097          	auipc	ra,0x0
    80000f44:	068080e7          	jalr	104(ra) # 80000fa8 <kvminithart>
    procinit();      // process table
    80000f48:	00001097          	auipc	ra,0x1
    80000f4c:	9d2080e7          	jalr	-1582(ra) # 8000191a <procinit>
    trapinit();      // trap vectors
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	342080e7          	jalr	834(ra) # 80003292 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	362080e7          	jalr	866(ra) # 800032ba <trapinithart>
    plicinit();      // set up interrupt controller
    80000f60:	00006097          	auipc	ra,0x6
    80000f64:	eda080e7          	jalr	-294(ra) # 80006e3a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f68:	00006097          	auipc	ra,0x6
    80000f6c:	ee8080e7          	jalr	-280(ra) # 80006e50 <plicinithart>
    binit();         // buffer cache
    80000f70:	00003097          	auipc	ra,0x3
    80000f74:	014080e7          	jalr	20(ra) # 80003f84 <binit>
    iinit();         // inode cache
    80000f78:	00003097          	auipc	ra,0x3
    80000f7c:	6a6080e7          	jalr	1702(ra) # 8000461e <iinit>
    fileinit();      // file table
    80000f80:	00004097          	auipc	ra,0x4
    80000f84:	652080e7          	jalr	1618(ra) # 800055d2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f88:	00006097          	auipc	ra,0x6
    80000f8c:	fea080e7          	jalr	-22(ra) # 80006f72 <virtio_disk_init>
    userinit();      // first user process
    80000f90:	00001097          	auipc	ra,0x1
    80000f94:	f7e080e7          	jalr	-130(ra) # 80001f0e <userinit>
    __sync_synchronize();
    80000f98:	0ff0000f          	fence
    started = 1;
    80000f9c:	4785                	li	a5,1
    80000f9e:	00009717          	auipc	a4,0x9
    80000fa2:	06f72d23          	sw	a5,122(a4) # 8000a018 <started>
    80000fa6:	b789                	j	80000ee8 <main+0x56>

0000000080000fa8 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fa8:	1141                	addi	sp,sp,-16
    80000faa:	e422                	sd	s0,8(sp)
    80000fac:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fae:	00009797          	auipc	a5,0x9
    80000fb2:	0727b783          	ld	a5,114(a5) # 8000a020 <kernel_pagetable>
    80000fb6:	83b1                	srli	a5,a5,0xc
    80000fb8:	577d                	li	a4,-1
    80000fba:	177e                	slli	a4,a4,0x3f
    80000fbc:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fbe:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fc2:	12000073          	sfence.vma
  sfence_vma();
}
    80000fc6:	6422                	ld	s0,8(sp)
    80000fc8:	0141                	addi	sp,sp,16
    80000fca:	8082                	ret

0000000080000fcc <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fcc:	7139                	addi	sp,sp,-64
    80000fce:	fc06                	sd	ra,56(sp)
    80000fd0:	f822                	sd	s0,48(sp)
    80000fd2:	f426                	sd	s1,40(sp)
    80000fd4:	f04a                	sd	s2,32(sp)
    80000fd6:	ec4e                	sd	s3,24(sp)
    80000fd8:	e852                	sd	s4,16(sp)
    80000fda:	e456                	sd	s5,8(sp)
    80000fdc:	e05a                	sd	s6,0(sp)
    80000fde:	0080                	addi	s0,sp,64
    80000fe0:	84aa                	mv	s1,a0
    80000fe2:	89ae                	mv	s3,a1
    80000fe4:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fe6:	57fd                	li	a5,-1
    80000fe8:	83e9                	srli	a5,a5,0x1a
    80000fea:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fec:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fee:	04b7f263          	bgeu	a5,a1,80001032 <walk+0x66>
    panic("walk");
    80000ff2:	00008517          	auipc	a0,0x8
    80000ff6:	11650513          	addi	a0,a0,278 # 80009108 <digits+0xc8>
    80000ffa:	fffff097          	auipc	ra,0xfffff
    80000ffe:	534080e7          	jalr	1332(ra) # 8000052e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001002:	060a8663          	beqz	s5,8000106e <walk+0xa2>
    80001006:	00000097          	auipc	ra,0x0
    8000100a:	ad0080e7          	jalr	-1328(ra) # 80000ad6 <kalloc>
    8000100e:	84aa                	mv	s1,a0
    80001010:	c529                	beqz	a0,8000105a <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001012:	6605                	lui	a2,0x1
    80001014:	4581                	li	a1,0
    80001016:	00000097          	auipc	ra,0x0
    8000101a:	cce080e7          	jalr	-818(ra) # 80000ce4 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000101e:	00c4d793          	srli	a5,s1,0xc
    80001022:	07aa                	slli	a5,a5,0xa
    80001024:	0017e793          	ori	a5,a5,1
    80001028:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000102c:	3a5d                	addiw	s4,s4,-9
    8000102e:	036a0063          	beq	s4,s6,8000104e <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001032:	0149d933          	srl	s2,s3,s4
    80001036:	1ff97913          	andi	s2,s2,511
    8000103a:	090e                	slli	s2,s2,0x3
    8000103c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000103e:	00093483          	ld	s1,0(s2)
    80001042:	0014f793          	andi	a5,s1,1
    80001046:	dfd5                	beqz	a5,80001002 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001048:	80a9                	srli	s1,s1,0xa
    8000104a:	04b2                	slli	s1,s1,0xc
    8000104c:	b7c5                	j	8000102c <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000104e:	00c9d513          	srli	a0,s3,0xc
    80001052:	1ff57513          	andi	a0,a0,511
    80001056:	050e                	slli	a0,a0,0x3
    80001058:	9526                	add	a0,a0,s1
}
    8000105a:	70e2                	ld	ra,56(sp)
    8000105c:	7442                	ld	s0,48(sp)
    8000105e:	74a2                	ld	s1,40(sp)
    80001060:	7902                	ld	s2,32(sp)
    80001062:	69e2                	ld	s3,24(sp)
    80001064:	6a42                	ld	s4,16(sp)
    80001066:	6aa2                	ld	s5,8(sp)
    80001068:	6b02                	ld	s6,0(sp)
    8000106a:	6121                	addi	sp,sp,64
    8000106c:	8082                	ret
        return 0;
    8000106e:	4501                	li	a0,0
    80001070:	b7ed                	j	8000105a <walk+0x8e>

0000000080001072 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001072:	57fd                	li	a5,-1
    80001074:	83e9                	srli	a5,a5,0x1a
    80001076:	00b7f463          	bgeu	a5,a1,8000107e <walkaddr+0xc>
    return 0;
    8000107a:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000107c:	8082                	ret
{
    8000107e:	1141                	addi	sp,sp,-16
    80001080:	e406                	sd	ra,8(sp)
    80001082:	e022                	sd	s0,0(sp)
    80001084:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001086:	4601                	li	a2,0
    80001088:	00000097          	auipc	ra,0x0
    8000108c:	f44080e7          	jalr	-188(ra) # 80000fcc <walk>
  if(pte == 0)
    80001090:	c105                	beqz	a0,800010b0 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001092:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001094:	0117f693          	andi	a3,a5,17
    80001098:	4745                	li	a4,17
    return 0;
    8000109a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000109c:	00e68663          	beq	a3,a4,800010a8 <walkaddr+0x36>
}
    800010a0:	60a2                	ld	ra,8(sp)
    800010a2:	6402                	ld	s0,0(sp)
    800010a4:	0141                	addi	sp,sp,16
    800010a6:	8082                	ret
  pa = PTE2PA(*pte);
    800010a8:	00a7d513          	srli	a0,a5,0xa
    800010ac:	0532                	slli	a0,a0,0xc
  return pa;
    800010ae:	bfcd                	j	800010a0 <walkaddr+0x2e>
    return 0;
    800010b0:	4501                	li	a0,0
    800010b2:	b7fd                	j	800010a0 <walkaddr+0x2e>

00000000800010b4 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010b4:	715d                	addi	sp,sp,-80
    800010b6:	e486                	sd	ra,72(sp)
    800010b8:	e0a2                	sd	s0,64(sp)
    800010ba:	fc26                	sd	s1,56(sp)
    800010bc:	f84a                	sd	s2,48(sp)
    800010be:	f44e                	sd	s3,40(sp)
    800010c0:	f052                	sd	s4,32(sp)
    800010c2:	ec56                	sd	s5,24(sp)
    800010c4:	e85a                	sd	s6,16(sp)
    800010c6:	e45e                	sd	s7,8(sp)
    800010c8:	0880                	addi	s0,sp,80
    800010ca:	8aaa                	mv	s5,a0
    800010cc:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010ce:	777d                	lui	a4,0xfffff
    800010d0:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010d4:	167d                	addi	a2,a2,-1
    800010d6:	00b609b3          	add	s3,a2,a1
    800010da:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010de:	893e                	mv	s2,a5
    800010e0:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010e4:	6b85                	lui	s7,0x1
    800010e6:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010ea:	4605                	li	a2,1
    800010ec:	85ca                	mv	a1,s2
    800010ee:	8556                	mv	a0,s5
    800010f0:	00000097          	auipc	ra,0x0
    800010f4:	edc080e7          	jalr	-292(ra) # 80000fcc <walk>
    800010f8:	c51d                	beqz	a0,80001126 <mappages+0x72>
    if(*pte & PTE_V)
    800010fa:	611c                	ld	a5,0(a0)
    800010fc:	8b85                	andi	a5,a5,1
    800010fe:	ef81                	bnez	a5,80001116 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001100:	80b1                	srli	s1,s1,0xc
    80001102:	04aa                	slli	s1,s1,0xa
    80001104:	0164e4b3          	or	s1,s1,s6
    80001108:	0014e493          	ori	s1,s1,1
    8000110c:	e104                	sd	s1,0(a0)
    if(a == last)
    8000110e:	03390863          	beq	s2,s3,8000113e <mappages+0x8a>
    a += PGSIZE;
    80001112:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001114:	bfc9                	j	800010e6 <mappages+0x32>
      panic("remap");
    80001116:	00008517          	auipc	a0,0x8
    8000111a:	ffa50513          	addi	a0,a0,-6 # 80009110 <digits+0xd0>
    8000111e:	fffff097          	auipc	ra,0xfffff
    80001122:	410080e7          	jalr	1040(ra) # 8000052e <panic>
      return -1;
    80001126:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001128:	60a6                	ld	ra,72(sp)
    8000112a:	6406                	ld	s0,64(sp)
    8000112c:	74e2                	ld	s1,56(sp)
    8000112e:	7942                	ld	s2,48(sp)
    80001130:	79a2                	ld	s3,40(sp)
    80001132:	7a02                	ld	s4,32(sp)
    80001134:	6ae2                	ld	s5,24(sp)
    80001136:	6b42                	ld	s6,16(sp)
    80001138:	6ba2                	ld	s7,8(sp)
    8000113a:	6161                	addi	sp,sp,80
    8000113c:	8082                	ret
  return 0;
    8000113e:	4501                	li	a0,0
    80001140:	b7e5                	j	80001128 <mappages+0x74>

0000000080001142 <kvmmap>:
{
    80001142:	1141                	addi	sp,sp,-16
    80001144:	e406                	sd	ra,8(sp)
    80001146:	e022                	sd	s0,0(sp)
    80001148:	0800                	addi	s0,sp,16
    8000114a:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000114c:	86b2                	mv	a3,a2
    8000114e:	863e                	mv	a2,a5
    80001150:	00000097          	auipc	ra,0x0
    80001154:	f64080e7          	jalr	-156(ra) # 800010b4 <mappages>
    80001158:	e509                	bnez	a0,80001162 <kvmmap+0x20>
}
    8000115a:	60a2                	ld	ra,8(sp)
    8000115c:	6402                	ld	s0,0(sp)
    8000115e:	0141                	addi	sp,sp,16
    80001160:	8082                	ret
    panic("kvmmap");
    80001162:	00008517          	auipc	a0,0x8
    80001166:	fb650513          	addi	a0,a0,-74 # 80009118 <digits+0xd8>
    8000116a:	fffff097          	auipc	ra,0xfffff
    8000116e:	3c4080e7          	jalr	964(ra) # 8000052e <panic>

0000000080001172 <kvmmake>:
{
    80001172:	1101                	addi	sp,sp,-32
    80001174:	ec06                	sd	ra,24(sp)
    80001176:	e822                	sd	s0,16(sp)
    80001178:	e426                	sd	s1,8(sp)
    8000117a:	e04a                	sd	s2,0(sp)
    8000117c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117e:	00000097          	auipc	ra,0x0
    80001182:	958080e7          	jalr	-1704(ra) # 80000ad6 <kalloc>
    80001186:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001188:	6605                	lui	a2,0x1
    8000118a:	4581                	li	a1,0
    8000118c:	00000097          	auipc	ra,0x0
    80001190:	b58080e7          	jalr	-1192(ra) # 80000ce4 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001194:	4719                	li	a4,6
    80001196:	6685                	lui	a3,0x1
    80001198:	10000637          	lui	a2,0x10000
    8000119c:	100005b7          	lui	a1,0x10000
    800011a0:	8526                	mv	a0,s1
    800011a2:	00000097          	auipc	ra,0x0
    800011a6:	fa0080e7          	jalr	-96(ra) # 80001142 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011aa:	4719                	li	a4,6
    800011ac:	6685                	lui	a3,0x1
    800011ae:	10001637          	lui	a2,0x10001
    800011b2:	100015b7          	lui	a1,0x10001
    800011b6:	8526                	mv	a0,s1
    800011b8:	00000097          	auipc	ra,0x0
    800011bc:	f8a080e7          	jalr	-118(ra) # 80001142 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011c0:	4719                	li	a4,6
    800011c2:	004006b7          	lui	a3,0x400
    800011c6:	0c000637          	lui	a2,0xc000
    800011ca:	0c0005b7          	lui	a1,0xc000
    800011ce:	8526                	mv	a0,s1
    800011d0:	00000097          	auipc	ra,0x0
    800011d4:	f72080e7          	jalr	-142(ra) # 80001142 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d8:	00008917          	auipc	s2,0x8
    800011dc:	e2890913          	addi	s2,s2,-472 # 80009000 <etext>
    800011e0:	4729                	li	a4,10
    800011e2:	80008697          	auipc	a3,0x80008
    800011e6:	e1e68693          	addi	a3,a3,-482 # 9000 <_entry-0x7fff7000>
    800011ea:	4605                	li	a2,1
    800011ec:	067e                	slli	a2,a2,0x1f
    800011ee:	85b2                	mv	a1,a2
    800011f0:	8526                	mv	a0,s1
    800011f2:	00000097          	auipc	ra,0x0
    800011f6:	f50080e7          	jalr	-176(ra) # 80001142 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011fa:	4719                	li	a4,6
    800011fc:	46c5                	li	a3,17
    800011fe:	06ee                	slli	a3,a3,0x1b
    80001200:	412686b3          	sub	a3,a3,s2
    80001204:	864a                	mv	a2,s2
    80001206:	85ca                	mv	a1,s2
    80001208:	8526                	mv	a0,s1
    8000120a:	00000097          	auipc	ra,0x0
    8000120e:	f38080e7          	jalr	-200(ra) # 80001142 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001212:	4729                	li	a4,10
    80001214:	6685                	lui	a3,0x1
    80001216:	00007617          	auipc	a2,0x7
    8000121a:	dea60613          	addi	a2,a2,-534 # 80008000 <_trampoline>
    8000121e:	040005b7          	lui	a1,0x4000
    80001222:	15fd                	addi	a1,a1,-1
    80001224:	05b2                	slli	a1,a1,0xc
    80001226:	8526                	mv	a0,s1
    80001228:	00000097          	auipc	ra,0x0
    8000122c:	f1a080e7          	jalr	-230(ra) # 80001142 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001230:	8526                	mv	a0,s1
    80001232:	00000097          	auipc	ra,0x0
    80001236:	600080e7          	jalr	1536(ra) # 80001832 <proc_mapstacks>
}
    8000123a:	8526                	mv	a0,s1
    8000123c:	60e2                	ld	ra,24(sp)
    8000123e:	6442                	ld	s0,16(sp)
    80001240:	64a2                	ld	s1,8(sp)
    80001242:	6902                	ld	s2,0(sp)
    80001244:	6105                	addi	sp,sp,32
    80001246:	8082                	ret

0000000080001248 <kvminit>:
{
    80001248:	1141                	addi	sp,sp,-16
    8000124a:	e406                	sd	ra,8(sp)
    8000124c:	e022                	sd	s0,0(sp)
    8000124e:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001250:	00000097          	auipc	ra,0x0
    80001254:	f22080e7          	jalr	-222(ra) # 80001172 <kvmmake>
    80001258:	00009797          	auipc	a5,0x9
    8000125c:	dca7b423          	sd	a0,-568(a5) # 8000a020 <kernel_pagetable>
}
    80001260:	60a2                	ld	ra,8(sp)
    80001262:	6402                	ld	s0,0(sp)
    80001264:	0141                	addi	sp,sp,16
    80001266:	8082                	ret

0000000080001268 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001268:	715d                	addi	sp,sp,-80
    8000126a:	e486                	sd	ra,72(sp)
    8000126c:	e0a2                	sd	s0,64(sp)
    8000126e:	fc26                	sd	s1,56(sp)
    80001270:	f84a                	sd	s2,48(sp)
    80001272:	f44e                	sd	s3,40(sp)
    80001274:	f052                	sd	s4,32(sp)
    80001276:	ec56                	sd	s5,24(sp)
    80001278:	e85a                	sd	s6,16(sp)
    8000127a:	e45e                	sd	s7,8(sp)
    8000127c:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127e:	03459793          	slli	a5,a1,0x34
    80001282:	e795                	bnez	a5,800012ae <uvmunmap+0x46>
    80001284:	8a2a                	mv	s4,a0
    80001286:	892e                	mv	s2,a1
    80001288:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128a:	0632                	slli	a2,a2,0xc
    8000128c:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001290:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001292:	6b05                	lui	s6,0x1
    80001294:	0735e263          	bltu	a1,s3,800012f8 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001298:	60a6                	ld	ra,72(sp)
    8000129a:	6406                	ld	s0,64(sp)
    8000129c:	74e2                	ld	s1,56(sp)
    8000129e:	7942                	ld	s2,48(sp)
    800012a0:	79a2                	ld	s3,40(sp)
    800012a2:	7a02                	ld	s4,32(sp)
    800012a4:	6ae2                	ld	s5,24(sp)
    800012a6:	6b42                	ld	s6,16(sp)
    800012a8:	6ba2                	ld	s7,8(sp)
    800012aa:	6161                	addi	sp,sp,80
    800012ac:	8082                	ret
    panic("uvmunmap: not aligned");
    800012ae:	00008517          	auipc	a0,0x8
    800012b2:	e7250513          	addi	a0,a0,-398 # 80009120 <digits+0xe0>
    800012b6:	fffff097          	auipc	ra,0xfffff
    800012ba:	278080e7          	jalr	632(ra) # 8000052e <panic>
      panic("uvmunmap: walk");
    800012be:	00008517          	auipc	a0,0x8
    800012c2:	e7a50513          	addi	a0,a0,-390 # 80009138 <digits+0xf8>
    800012c6:	fffff097          	auipc	ra,0xfffff
    800012ca:	268080e7          	jalr	616(ra) # 8000052e <panic>
      panic("uvmunmap: not mapped");
    800012ce:	00008517          	auipc	a0,0x8
    800012d2:	e7a50513          	addi	a0,a0,-390 # 80009148 <digits+0x108>
    800012d6:	fffff097          	auipc	ra,0xfffff
    800012da:	258080e7          	jalr	600(ra) # 8000052e <panic>
      panic("uvmunmap: not a leaf");
    800012de:	00008517          	auipc	a0,0x8
    800012e2:	e8250513          	addi	a0,a0,-382 # 80009160 <digits+0x120>
    800012e6:	fffff097          	auipc	ra,0xfffff
    800012ea:	248080e7          	jalr	584(ra) # 8000052e <panic>
    *pte = 0;
    800012ee:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012f2:	995a                	add	s2,s2,s6
    800012f4:	fb3972e3          	bgeu	s2,s3,80001298 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f8:	4601                	li	a2,0
    800012fa:	85ca                	mv	a1,s2
    800012fc:	8552                	mv	a0,s4
    800012fe:	00000097          	auipc	ra,0x0
    80001302:	cce080e7          	jalr	-818(ra) # 80000fcc <walk>
    80001306:	84aa                	mv	s1,a0
    80001308:	d95d                	beqz	a0,800012be <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000130a:	6108                	ld	a0,0(a0)
    8000130c:	00157793          	andi	a5,a0,1
    80001310:	dfdd                	beqz	a5,800012ce <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001312:	3ff57793          	andi	a5,a0,1023
    80001316:	fd7784e3          	beq	a5,s7,800012de <uvmunmap+0x76>
    if(do_free){
    8000131a:	fc0a8ae3          	beqz	s5,800012ee <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131e:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001320:	0532                	slli	a0,a0,0xc
    80001322:	fffff097          	auipc	ra,0xfffff
    80001326:	6b8080e7          	jalr	1720(ra) # 800009da <kfree>
    8000132a:	b7d1                	j	800012ee <uvmunmap+0x86>

000000008000132c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000132c:	1101                	addi	sp,sp,-32
    8000132e:	ec06                	sd	ra,24(sp)
    80001330:	e822                	sd	s0,16(sp)
    80001332:	e426                	sd	s1,8(sp)
    80001334:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001336:	fffff097          	auipc	ra,0xfffff
    8000133a:	7a0080e7          	jalr	1952(ra) # 80000ad6 <kalloc>
    8000133e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001340:	c519                	beqz	a0,8000134e <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001342:	6605                	lui	a2,0x1
    80001344:	4581                	li	a1,0
    80001346:	00000097          	auipc	ra,0x0
    8000134a:	99e080e7          	jalr	-1634(ra) # 80000ce4 <memset>
  return pagetable;
}
    8000134e:	8526                	mv	a0,s1
    80001350:	60e2                	ld	ra,24(sp)
    80001352:	6442                	ld	s0,16(sp)
    80001354:	64a2                	ld	s1,8(sp)
    80001356:	6105                	addi	sp,sp,32
    80001358:	8082                	ret

000000008000135a <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000135a:	7179                	addi	sp,sp,-48
    8000135c:	f406                	sd	ra,40(sp)
    8000135e:	f022                	sd	s0,32(sp)
    80001360:	ec26                	sd	s1,24(sp)
    80001362:	e84a                	sd	s2,16(sp)
    80001364:	e44e                	sd	s3,8(sp)
    80001366:	e052                	sd	s4,0(sp)
    80001368:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000136a:	6785                	lui	a5,0x1
    8000136c:	04f67863          	bgeu	a2,a5,800013bc <uvminit+0x62>
    80001370:	8a2a                	mv	s4,a0
    80001372:	89ae                	mv	s3,a1
    80001374:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001376:	fffff097          	auipc	ra,0xfffff
    8000137a:	760080e7          	jalr	1888(ra) # 80000ad6 <kalloc>
    8000137e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001380:	6605                	lui	a2,0x1
    80001382:	4581                	li	a1,0
    80001384:	00000097          	auipc	ra,0x0
    80001388:	960080e7          	jalr	-1696(ra) # 80000ce4 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000138c:	4779                	li	a4,30
    8000138e:	86ca                	mv	a3,s2
    80001390:	6605                	lui	a2,0x1
    80001392:	4581                	li	a1,0
    80001394:	8552                	mv	a0,s4
    80001396:	00000097          	auipc	ra,0x0
    8000139a:	d1e080e7          	jalr	-738(ra) # 800010b4 <mappages>
  memmove(mem, src, sz);
    8000139e:	8626                	mv	a2,s1
    800013a0:	85ce                	mv	a1,s3
    800013a2:	854a                	mv	a0,s2
    800013a4:	00000097          	auipc	ra,0x0
    800013a8:	99c080e7          	jalr	-1636(ra) # 80000d40 <memmove>
}
    800013ac:	70a2                	ld	ra,40(sp)
    800013ae:	7402                	ld	s0,32(sp)
    800013b0:	64e2                	ld	s1,24(sp)
    800013b2:	6942                	ld	s2,16(sp)
    800013b4:	69a2                	ld	s3,8(sp)
    800013b6:	6a02                	ld	s4,0(sp)
    800013b8:	6145                	addi	sp,sp,48
    800013ba:	8082                	ret
    panic("inituvm: more than a page");
    800013bc:	00008517          	auipc	a0,0x8
    800013c0:	dbc50513          	addi	a0,a0,-580 # 80009178 <digits+0x138>
    800013c4:	fffff097          	auipc	ra,0xfffff
    800013c8:	16a080e7          	jalr	362(ra) # 8000052e <panic>

00000000800013cc <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013cc:	1101                	addi	sp,sp,-32
    800013ce:	ec06                	sd	ra,24(sp)
    800013d0:	e822                	sd	s0,16(sp)
    800013d2:	e426                	sd	s1,8(sp)
    800013d4:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d6:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d8:	00b67d63          	bgeu	a2,a1,800013f2 <uvmdealloc+0x26>
    800013dc:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013de:	6785                	lui	a5,0x1
    800013e0:	17fd                	addi	a5,a5,-1
    800013e2:	00f60733          	add	a4,a2,a5
    800013e6:	767d                	lui	a2,0xfffff
    800013e8:	8f71                	and	a4,a4,a2
    800013ea:	97ae                	add	a5,a5,a1
    800013ec:	8ff1                	and	a5,a5,a2
    800013ee:	00f76863          	bltu	a4,a5,800013fe <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013f2:	8526                	mv	a0,s1
    800013f4:	60e2                	ld	ra,24(sp)
    800013f6:	6442                	ld	s0,16(sp)
    800013f8:	64a2                	ld	s1,8(sp)
    800013fa:	6105                	addi	sp,sp,32
    800013fc:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fe:	8f99                	sub	a5,a5,a4
    80001400:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001402:	4685                	li	a3,1
    80001404:	0007861b          	sext.w	a2,a5
    80001408:	85ba                	mv	a1,a4
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	e5e080e7          	jalr	-418(ra) # 80001268 <uvmunmap>
    80001412:	b7c5                	j	800013f2 <uvmdealloc+0x26>

0000000080001414 <uvmalloc>:
  if(newsz < oldsz)
    80001414:	0ab66163          	bltu	a2,a1,800014b6 <uvmalloc+0xa2>
{
    80001418:	7139                	addi	sp,sp,-64
    8000141a:	fc06                	sd	ra,56(sp)
    8000141c:	f822                	sd	s0,48(sp)
    8000141e:	f426                	sd	s1,40(sp)
    80001420:	f04a                	sd	s2,32(sp)
    80001422:	ec4e                	sd	s3,24(sp)
    80001424:	e852                	sd	s4,16(sp)
    80001426:	e456                	sd	s5,8(sp)
    80001428:	0080                	addi	s0,sp,64
    8000142a:	8aaa                	mv	s5,a0
    8000142c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142e:	6985                	lui	s3,0x1
    80001430:	19fd                	addi	s3,s3,-1
    80001432:	95ce                	add	a1,a1,s3
    80001434:	79fd                	lui	s3,0xfffff
    80001436:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000143a:	08c9f063          	bgeu	s3,a2,800014ba <uvmalloc+0xa6>
    8000143e:	894e                	mv	s2,s3
    mem = kalloc();
    80001440:	fffff097          	auipc	ra,0xfffff
    80001444:	696080e7          	jalr	1686(ra) # 80000ad6 <kalloc>
    80001448:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144a:	c51d                	beqz	a0,80001478 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000144c:	6605                	lui	a2,0x1
    8000144e:	4581                	li	a1,0
    80001450:	00000097          	auipc	ra,0x0
    80001454:	894080e7          	jalr	-1900(ra) # 80000ce4 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001458:	4779                	li	a4,30
    8000145a:	86a6                	mv	a3,s1
    8000145c:	6605                	lui	a2,0x1
    8000145e:	85ca                	mv	a1,s2
    80001460:	8556                	mv	a0,s5
    80001462:	00000097          	auipc	ra,0x0
    80001466:	c52080e7          	jalr	-942(ra) # 800010b4 <mappages>
    8000146a:	e905                	bnez	a0,8000149a <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146c:	6785                	lui	a5,0x1
    8000146e:	993e                	add	s2,s2,a5
    80001470:	fd4968e3          	bltu	s2,s4,80001440 <uvmalloc+0x2c>
  return newsz;
    80001474:	8552                	mv	a0,s4
    80001476:	a809                	j	80001488 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001478:	864e                	mv	a2,s3
    8000147a:	85ca                	mv	a1,s2
    8000147c:	8556                	mv	a0,s5
    8000147e:	00000097          	auipc	ra,0x0
    80001482:	f4e080e7          	jalr	-178(ra) # 800013cc <uvmdealloc>
      return 0;
    80001486:	4501                	li	a0,0
}
    80001488:	70e2                	ld	ra,56(sp)
    8000148a:	7442                	ld	s0,48(sp)
    8000148c:	74a2                	ld	s1,40(sp)
    8000148e:	7902                	ld	s2,32(sp)
    80001490:	69e2                	ld	s3,24(sp)
    80001492:	6a42                	ld	s4,16(sp)
    80001494:	6aa2                	ld	s5,8(sp)
    80001496:	6121                	addi	sp,sp,64
    80001498:	8082                	ret
      kfree(mem);
    8000149a:	8526                	mv	a0,s1
    8000149c:	fffff097          	auipc	ra,0xfffff
    800014a0:	53e080e7          	jalr	1342(ra) # 800009da <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a4:	864e                	mv	a2,s3
    800014a6:	85ca                	mv	a1,s2
    800014a8:	8556                	mv	a0,s5
    800014aa:	00000097          	auipc	ra,0x0
    800014ae:	f22080e7          	jalr	-222(ra) # 800013cc <uvmdealloc>
      return 0;
    800014b2:	4501                	li	a0,0
    800014b4:	bfd1                	j	80001488 <uvmalloc+0x74>
    return oldsz;
    800014b6:	852e                	mv	a0,a1
}
    800014b8:	8082                	ret
  return newsz;
    800014ba:	8532                	mv	a0,a2
    800014bc:	b7f1                	j	80001488 <uvmalloc+0x74>

00000000800014be <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014be:	7179                	addi	sp,sp,-48
    800014c0:	f406                	sd	ra,40(sp)
    800014c2:	f022                	sd	s0,32(sp)
    800014c4:	ec26                	sd	s1,24(sp)
    800014c6:	e84a                	sd	s2,16(sp)
    800014c8:	e44e                	sd	s3,8(sp)
    800014ca:	e052                	sd	s4,0(sp)
    800014cc:	1800                	addi	s0,sp,48
    800014ce:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d0:	84aa                	mv	s1,a0
    800014d2:	6905                	lui	s2,0x1
    800014d4:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d6:	4985                	li	s3,1
    800014d8:	a821                	j	800014f0 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014da:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014dc:	0532                	slli	a0,a0,0xc
    800014de:	00000097          	auipc	ra,0x0
    800014e2:	fe0080e7          	jalr	-32(ra) # 800014be <freewalk>
      pagetable[i] = 0;
    800014e6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ea:	04a1                	addi	s1,s1,8
    800014ec:	03248163          	beq	s1,s2,8000150e <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014f0:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f2:	00f57793          	andi	a5,a0,15
    800014f6:	ff3782e3          	beq	a5,s3,800014da <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fa:	8905                	andi	a0,a0,1
    800014fc:	d57d                	beqz	a0,800014ea <freewalk+0x2c>
      panic("freewalk: leaf");
    800014fe:	00008517          	auipc	a0,0x8
    80001502:	c9a50513          	addi	a0,a0,-870 # 80009198 <digits+0x158>
    80001506:	fffff097          	auipc	ra,0xfffff
    8000150a:	028080e7          	jalr	40(ra) # 8000052e <panic>
    }
  }
  kfree((void*)pagetable);
    8000150e:	8552                	mv	a0,s4
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	4ca080e7          	jalr	1226(ra) # 800009da <kfree>
}
    80001518:	70a2                	ld	ra,40(sp)
    8000151a:	7402                	ld	s0,32(sp)
    8000151c:	64e2                	ld	s1,24(sp)
    8000151e:	6942                	ld	s2,16(sp)
    80001520:	69a2                	ld	s3,8(sp)
    80001522:	6a02                	ld	s4,0(sp)
    80001524:	6145                	addi	sp,sp,48
    80001526:	8082                	ret

0000000080001528 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001528:	1101                	addi	sp,sp,-32
    8000152a:	ec06                	sd	ra,24(sp)
    8000152c:	e822                	sd	s0,16(sp)
    8000152e:	e426                	sd	s1,8(sp)
    80001530:	1000                	addi	s0,sp,32
    80001532:	84aa                	mv	s1,a0
  if(sz > 0)
    80001534:	e999                	bnez	a1,8000154a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001536:	8526                	mv	a0,s1
    80001538:	00000097          	auipc	ra,0x0
    8000153c:	f86080e7          	jalr	-122(ra) # 800014be <freewalk>
}
    80001540:	60e2                	ld	ra,24(sp)
    80001542:	6442                	ld	s0,16(sp)
    80001544:	64a2                	ld	s1,8(sp)
    80001546:	6105                	addi	sp,sp,32
    80001548:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154a:	6605                	lui	a2,0x1
    8000154c:	167d                	addi	a2,a2,-1
    8000154e:	962e                	add	a2,a2,a1
    80001550:	4685                	li	a3,1
    80001552:	8231                	srli	a2,a2,0xc
    80001554:	4581                	li	a1,0
    80001556:	00000097          	auipc	ra,0x0
    8000155a:	d12080e7          	jalr	-750(ra) # 80001268 <uvmunmap>
    8000155e:	bfe1                	j	80001536 <uvmfree+0xe>

0000000080001560 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001560:	c679                	beqz	a2,8000162e <uvmcopy+0xce>
{
    80001562:	715d                	addi	sp,sp,-80
    80001564:	e486                	sd	ra,72(sp)
    80001566:	e0a2                	sd	s0,64(sp)
    80001568:	fc26                	sd	s1,56(sp)
    8000156a:	f84a                	sd	s2,48(sp)
    8000156c:	f44e                	sd	s3,40(sp)
    8000156e:	f052                	sd	s4,32(sp)
    80001570:	ec56                	sd	s5,24(sp)
    80001572:	e85a                	sd	s6,16(sp)
    80001574:	e45e                	sd	s7,8(sp)
    80001576:	0880                	addi	s0,sp,80
    80001578:	8b2a                	mv	s6,a0
    8000157a:	8aae                	mv	s5,a1
    8000157c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000157e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001580:	4601                	li	a2,0
    80001582:	85ce                	mv	a1,s3
    80001584:	855a                	mv	a0,s6
    80001586:	00000097          	auipc	ra,0x0
    8000158a:	a46080e7          	jalr	-1466(ra) # 80000fcc <walk>
    8000158e:	c531                	beqz	a0,800015da <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001590:	6118                	ld	a4,0(a0)
    80001592:	00177793          	andi	a5,a4,1
    80001596:	cbb1                	beqz	a5,800015ea <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001598:	00a75593          	srli	a1,a4,0xa
    8000159c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a0:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a4:	fffff097          	auipc	ra,0xfffff
    800015a8:	532080e7          	jalr	1330(ra) # 80000ad6 <kalloc>
    800015ac:	892a                	mv	s2,a0
    800015ae:	c939                	beqz	a0,80001604 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b0:	6605                	lui	a2,0x1
    800015b2:	85de                	mv	a1,s7
    800015b4:	fffff097          	auipc	ra,0xfffff
    800015b8:	78c080e7          	jalr	1932(ra) # 80000d40 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015bc:	8726                	mv	a4,s1
    800015be:	86ca                	mv	a3,s2
    800015c0:	6605                	lui	a2,0x1
    800015c2:	85ce                	mv	a1,s3
    800015c4:	8556                	mv	a0,s5
    800015c6:	00000097          	auipc	ra,0x0
    800015ca:	aee080e7          	jalr	-1298(ra) # 800010b4 <mappages>
    800015ce:	e515                	bnez	a0,800015fa <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d0:	6785                	lui	a5,0x1
    800015d2:	99be                	add	s3,s3,a5
    800015d4:	fb49e6e3          	bltu	s3,s4,80001580 <uvmcopy+0x20>
    800015d8:	a081                	j	80001618 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015da:	00008517          	auipc	a0,0x8
    800015de:	bce50513          	addi	a0,a0,-1074 # 800091a8 <digits+0x168>
    800015e2:	fffff097          	auipc	ra,0xfffff
    800015e6:	f4c080e7          	jalr	-180(ra) # 8000052e <panic>
      panic("uvmcopy: page not present");
    800015ea:	00008517          	auipc	a0,0x8
    800015ee:	bde50513          	addi	a0,a0,-1058 # 800091c8 <digits+0x188>
    800015f2:	fffff097          	auipc	ra,0xfffff
    800015f6:	f3c080e7          	jalr	-196(ra) # 8000052e <panic>
      kfree(mem);
    800015fa:	854a                	mv	a0,s2
    800015fc:	fffff097          	auipc	ra,0xfffff
    80001600:	3de080e7          	jalr	990(ra) # 800009da <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001604:	4685                	li	a3,1
    80001606:	00c9d613          	srli	a2,s3,0xc
    8000160a:	4581                	li	a1,0
    8000160c:	8556                	mv	a0,s5
    8000160e:	00000097          	auipc	ra,0x0
    80001612:	c5a080e7          	jalr	-934(ra) # 80001268 <uvmunmap>
  return -1;
    80001616:	557d                	li	a0,-1
}
    80001618:	60a6                	ld	ra,72(sp)
    8000161a:	6406                	ld	s0,64(sp)
    8000161c:	74e2                	ld	s1,56(sp)
    8000161e:	7942                	ld	s2,48(sp)
    80001620:	79a2                	ld	s3,40(sp)
    80001622:	7a02                	ld	s4,32(sp)
    80001624:	6ae2                	ld	s5,24(sp)
    80001626:	6b42                	ld	s6,16(sp)
    80001628:	6ba2                	ld	s7,8(sp)
    8000162a:	6161                	addi	sp,sp,80
    8000162c:	8082                	ret
  return 0;
    8000162e:	4501                	li	a0,0
}
    80001630:	8082                	ret

0000000080001632 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001632:	1141                	addi	sp,sp,-16
    80001634:	e406                	sd	ra,8(sp)
    80001636:	e022                	sd	s0,0(sp)
    80001638:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163a:	4601                	li	a2,0
    8000163c:	00000097          	auipc	ra,0x0
    80001640:	990080e7          	jalr	-1648(ra) # 80000fcc <walk>
  if(pte == 0)
    80001644:	c901                	beqz	a0,80001654 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001646:	611c                	ld	a5,0(a0)
    80001648:	9bbd                	andi	a5,a5,-17
    8000164a:	e11c                	sd	a5,0(a0)
}
    8000164c:	60a2                	ld	ra,8(sp)
    8000164e:	6402                	ld	s0,0(sp)
    80001650:	0141                	addi	sp,sp,16
    80001652:	8082                	ret
    panic("uvmclear");
    80001654:	00008517          	auipc	a0,0x8
    80001658:	b9450513          	addi	a0,a0,-1132 # 800091e8 <digits+0x1a8>
    8000165c:	fffff097          	auipc	ra,0xfffff
    80001660:	ed2080e7          	jalr	-302(ra) # 8000052e <panic>

0000000080001664 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001664:	c6bd                	beqz	a3,800016d2 <copyout+0x6e>
{
    80001666:	715d                	addi	sp,sp,-80
    80001668:	e486                	sd	ra,72(sp)
    8000166a:	e0a2                	sd	s0,64(sp)
    8000166c:	fc26                	sd	s1,56(sp)
    8000166e:	f84a                	sd	s2,48(sp)
    80001670:	f44e                	sd	s3,40(sp)
    80001672:	f052                	sd	s4,32(sp)
    80001674:	ec56                	sd	s5,24(sp)
    80001676:	e85a                	sd	s6,16(sp)
    80001678:	e45e                	sd	s7,8(sp)
    8000167a:	e062                	sd	s8,0(sp)
    8000167c:	0880                	addi	s0,sp,80
    8000167e:	8b2a                	mv	s6,a0
    80001680:	8c2e                	mv	s8,a1
    80001682:	8a32                	mv	s4,a2
    80001684:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001686:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001688:	6a85                	lui	s5,0x1
    8000168a:	a015                	j	800016ae <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168c:	9562                	add	a0,a0,s8
    8000168e:	0004861b          	sext.w	a2,s1
    80001692:	85d2                	mv	a1,s4
    80001694:	41250533          	sub	a0,a0,s2
    80001698:	fffff097          	auipc	ra,0xfffff
    8000169c:	6a8080e7          	jalr	1704(ra) # 80000d40 <memmove>

    len -= n;
    800016a0:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a4:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016a6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016aa:	02098263          	beqz	s3,800016ce <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016ae:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b2:	85ca                	mv	a1,s2
    800016b4:	855a                	mv	a0,s6
    800016b6:	00000097          	auipc	ra,0x0
    800016ba:	9bc080e7          	jalr	-1604(ra) # 80001072 <walkaddr>
    if(pa0 == 0)
    800016be:	cd01                	beqz	a0,800016d6 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c0:	418904b3          	sub	s1,s2,s8
    800016c4:	94d6                	add	s1,s1,s5
    if(n > len)
    800016c6:	fc99f3e3          	bgeu	s3,s1,8000168c <copyout+0x28>
    800016ca:	84ce                	mv	s1,s3
    800016cc:	b7c1                	j	8000168c <copyout+0x28>
  }
  return 0;
    800016ce:	4501                	li	a0,0
    800016d0:	a021                	j	800016d8 <copyout+0x74>
    800016d2:	4501                	li	a0,0
}
    800016d4:	8082                	ret
      return -1;
    800016d6:	557d                	li	a0,-1
}
    800016d8:	60a6                	ld	ra,72(sp)
    800016da:	6406                	ld	s0,64(sp)
    800016dc:	74e2                	ld	s1,56(sp)
    800016de:	7942                	ld	s2,48(sp)
    800016e0:	79a2                	ld	s3,40(sp)
    800016e2:	7a02                	ld	s4,32(sp)
    800016e4:	6ae2                	ld	s5,24(sp)
    800016e6:	6b42                	ld	s6,16(sp)
    800016e8:	6ba2                	ld	s7,8(sp)
    800016ea:	6c02                	ld	s8,0(sp)
    800016ec:	6161                	addi	sp,sp,80
    800016ee:	8082                	ret

00000000800016f0 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f0:	caa5                	beqz	a3,80001760 <copyin+0x70>
{
    800016f2:	715d                	addi	sp,sp,-80
    800016f4:	e486                	sd	ra,72(sp)
    800016f6:	e0a2                	sd	s0,64(sp)
    800016f8:	fc26                	sd	s1,56(sp)
    800016fa:	f84a                	sd	s2,48(sp)
    800016fc:	f44e                	sd	s3,40(sp)
    800016fe:	f052                	sd	s4,32(sp)
    80001700:	ec56                	sd	s5,24(sp)
    80001702:	e85a                	sd	s6,16(sp)
    80001704:	e45e                	sd	s7,8(sp)
    80001706:	e062                	sd	s8,0(sp)
    80001708:	0880                	addi	s0,sp,80
    8000170a:	8b2a                	mv	s6,a0
    8000170c:	8a2e                	mv	s4,a1
    8000170e:	8c32                	mv	s8,a2
    80001710:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001712:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001714:	6a85                	lui	s5,0x1
    80001716:	a01d                	j	8000173c <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001718:	018505b3          	add	a1,a0,s8
    8000171c:	0004861b          	sext.w	a2,s1
    80001720:	412585b3          	sub	a1,a1,s2
    80001724:	8552                	mv	a0,s4
    80001726:	fffff097          	auipc	ra,0xfffff
    8000172a:	61a080e7          	jalr	1562(ra) # 80000d40 <memmove>

    len -= n;
    8000172e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001732:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001734:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001738:	02098263          	beqz	s3,8000175c <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000173c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001740:	85ca                	mv	a1,s2
    80001742:	855a                	mv	a0,s6
    80001744:	00000097          	auipc	ra,0x0
    80001748:	92e080e7          	jalr	-1746(ra) # 80001072 <walkaddr>
    if(pa0 == 0)
    8000174c:	cd01                	beqz	a0,80001764 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000174e:	418904b3          	sub	s1,s2,s8
    80001752:	94d6                	add	s1,s1,s5
    if(n > len)
    80001754:	fc99f2e3          	bgeu	s3,s1,80001718 <copyin+0x28>
    80001758:	84ce                	mv	s1,s3
    8000175a:	bf7d                	j	80001718 <copyin+0x28>
  }
  return 0;
    8000175c:	4501                	li	a0,0
    8000175e:	a021                	j	80001766 <copyin+0x76>
    80001760:	4501                	li	a0,0
}
    80001762:	8082                	ret
      return -1;
    80001764:	557d                	li	a0,-1
}
    80001766:	60a6                	ld	ra,72(sp)
    80001768:	6406                	ld	s0,64(sp)
    8000176a:	74e2                	ld	s1,56(sp)
    8000176c:	7942                	ld	s2,48(sp)
    8000176e:	79a2                	ld	s3,40(sp)
    80001770:	7a02                	ld	s4,32(sp)
    80001772:	6ae2                	ld	s5,24(sp)
    80001774:	6b42                	ld	s6,16(sp)
    80001776:	6ba2                	ld	s7,8(sp)
    80001778:	6c02                	ld	s8,0(sp)
    8000177a:	6161                	addi	sp,sp,80
    8000177c:	8082                	ret

000000008000177e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000177e:	c6c5                	beqz	a3,80001826 <copyinstr+0xa8>
{
    80001780:	715d                	addi	sp,sp,-80
    80001782:	e486                	sd	ra,72(sp)
    80001784:	e0a2                	sd	s0,64(sp)
    80001786:	fc26                	sd	s1,56(sp)
    80001788:	f84a                	sd	s2,48(sp)
    8000178a:	f44e                	sd	s3,40(sp)
    8000178c:	f052                	sd	s4,32(sp)
    8000178e:	ec56                	sd	s5,24(sp)
    80001790:	e85a                	sd	s6,16(sp)
    80001792:	e45e                	sd	s7,8(sp)
    80001794:	0880                	addi	s0,sp,80
    80001796:	8a2a                	mv	s4,a0
    80001798:	8b2e                	mv	s6,a1
    8000179a:	8bb2                	mv	s7,a2
    8000179c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000179e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a0:	6985                	lui	s3,0x1
    800017a2:	a035                	j	800017ce <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017a8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017aa:	0017b793          	seqz	a5,a5
    800017ae:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b2:	60a6                	ld	ra,72(sp)
    800017b4:	6406                	ld	s0,64(sp)
    800017b6:	74e2                	ld	s1,56(sp)
    800017b8:	7942                	ld	s2,48(sp)
    800017ba:	79a2                	ld	s3,40(sp)
    800017bc:	7a02                	ld	s4,32(sp)
    800017be:	6ae2                	ld	s5,24(sp)
    800017c0:	6b42                	ld	s6,16(sp)
    800017c2:	6ba2                	ld	s7,8(sp)
    800017c4:	6161                	addi	sp,sp,80
    800017c6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017c8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017cc:	c8a9                	beqz	s1,8000181e <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017ce:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d2:	85ca                	mv	a1,s2
    800017d4:	8552                	mv	a0,s4
    800017d6:	00000097          	auipc	ra,0x0
    800017da:	89c080e7          	jalr	-1892(ra) # 80001072 <walkaddr>
    if(pa0 == 0)
    800017de:	c131                	beqz	a0,80001822 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017e0:	41790833          	sub	a6,s2,s7
    800017e4:	984e                	add	a6,a6,s3
    if(n > max)
    800017e6:	0104f363          	bgeu	s1,a6,800017ec <copyinstr+0x6e>
    800017ea:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017ec:	955e                	add	a0,a0,s7
    800017ee:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f2:	fc080be3          	beqz	a6,800017c8 <copyinstr+0x4a>
    800017f6:	985a                	add	a6,a6,s6
    800017f8:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fa:	41650633          	sub	a2,a0,s6
    800017fe:	14fd                	addi	s1,s1,-1
    80001800:	9b26                	add	s6,s6,s1
    80001802:	00f60733          	add	a4,a2,a5
    80001806:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffbd000>
    8000180a:	df49                	beqz	a4,800017a4 <copyinstr+0x26>
        *dst = *p;
    8000180c:	00e78023          	sb	a4,0(a5)
      --max;
    80001810:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001814:	0785                	addi	a5,a5,1
    while(n > 0){
    80001816:	ff0796e3          	bne	a5,a6,80001802 <copyinstr+0x84>
      dst++;
    8000181a:	8b42                	mv	s6,a6
    8000181c:	b775                	j	800017c8 <copyinstr+0x4a>
    8000181e:	4781                	li	a5,0
    80001820:	b769                	j	800017aa <copyinstr+0x2c>
      return -1;
    80001822:	557d                	li	a0,-1
    80001824:	b779                	j	800017b2 <copyinstr+0x34>
  int got_null = 0;
    80001826:	4781                	li	a5,0
  if(got_null){
    80001828:	0017b793          	seqz	a5,a5
    8000182c:	40f00533          	neg	a0,a5
}
    80001830:	8082                	ret

0000000080001832 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001832:	711d                	addi	sp,sp,-96
    80001834:	ec86                	sd	ra,88(sp)
    80001836:	e8a2                	sd	s0,80(sp)
    80001838:	e4a6                	sd	s1,72(sp)
    8000183a:	e0ca                	sd	s2,64(sp)
    8000183c:	fc4e                	sd	s3,56(sp)
    8000183e:	f852                	sd	s4,48(sp)
    80001840:	f456                	sd	s5,40(sp)
    80001842:	f05a                	sd	s6,32(sp)
    80001844:	ec5e                	sd	s7,24(sp)
    80001846:	e862                	sd	s8,16(sp)
    80001848:	e466                	sd	s9,8(sp)
    8000184a:	e06a                	sd	s10,0(sp)
    8000184c:	1080                	addi	s0,sp,96
    8000184e:	8b2a                	mv	s6,a0
  struct proc *p;
  struct kthread *t;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001850:	00011997          	auipc	s3,0x11
    80001854:	72098993          	addi	s3,s3,1824 # 80012f70 <proc+0x848>
    80001858:	00033d17          	auipc	s10,0x33
    8000185c:	918d0d13          	addi	s10,s10,-1768 # 80034170 <bcache+0x830>
    int proc_index= (int)(p-proc);
    80001860:	7c7d                	lui	s8,0xfffff
    80001862:	7b8c0c13          	addi	s8,s8,1976 # fffffffffffff7b8 <end+0xffffffff7ffbd7b8>
    80001866:	00007c97          	auipc	s9,0x7
    8000186a:	79acbc83          	ld	s9,1946(s9) # 80009000 <etext>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      int thread_index = (int)(t-p->kthreads);
    8000186e:	00007b97          	auipc	s7,0x7
    80001872:	79ab8b93          	addi	s7,s7,1946 # 80009008 <etext+0x8>
      uint64 va = KSTACK( proc_index * NTHREAD + thread_index);
    80001876:	04000ab7          	lui	s5,0x4000
    8000187a:	1afd                	addi	s5,s5,-1
    8000187c:	0ab2                	slli	s5,s5,0xc
    8000187e:	a839                	j	8000189c <proc_mapstacks+0x6a>
        panic("kalloc");
    80001880:	00008517          	auipc	a0,0x8
    80001884:	97850513          	addi	a0,a0,-1672 # 800091f8 <digits+0x1b8>
    80001888:	fffff097          	auipc	ra,0xfffff
    8000188c:	ca6080e7          	jalr	-858(ra) # 8000052e <panic>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001890:	6785                	lui	a5,0x1
    80001892:	84878793          	addi	a5,a5,-1976 # 848 <_entry-0x7ffff7b8>
    80001896:	99be                	add	s3,s3,a5
    80001898:	07a98363          	beq	s3,s10,800018fe <proc_mapstacks+0xcc>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    8000189c:	a4098a13          	addi	s4,s3,-1472
    int proc_index= (int)(p-proc);
    800018a0:	01898933          	add	s2,s3,s8
    800018a4:	00011797          	auipc	a5,0x11
    800018a8:	e8478793          	addi	a5,a5,-380 # 80012728 <proc>
    800018ac:	40f90933          	sub	s2,s2,a5
    800018b0:	40395913          	srai	s2,s2,0x3
    800018b4:	03990933          	mul	s2,s2,s9
    800018b8:	0039191b          	slliw	s2,s2,0x3
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    800018bc:	84d2                	mv	s1,s4
      char *pa = kalloc();
    800018be:	fffff097          	auipc	ra,0xfffff
    800018c2:	218080e7          	jalr	536(ra) # 80000ad6 <kalloc>
    800018c6:	862a                	mv	a2,a0
      if(pa == 0)
    800018c8:	dd45                	beqz	a0,80001880 <proc_mapstacks+0x4e>
      int thread_index = (int)(t-p->kthreads);
    800018ca:	414485b3          	sub	a1,s1,s4
    800018ce:	858d                	srai	a1,a1,0x3
    800018d0:	000bb783          	ld	a5,0(s7)
    800018d4:	02f585b3          	mul	a1,a1,a5
      uint64 va = KSTACK( proc_index * NTHREAD + thread_index);
    800018d8:	012585bb          	addw	a1,a1,s2
    800018dc:	2585                	addiw	a1,a1,1
    800018de:	00d5959b          	slliw	a1,a1,0xd
      kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018e2:	4719                	li	a4,6
    800018e4:	6685                	lui	a3,0x1
    800018e6:	40ba85b3          	sub	a1,s5,a1
    800018ea:	855a                	mv	a0,s6
    800018ec:	00000097          	auipc	ra,0x0
    800018f0:	856080e7          	jalr	-1962(ra) # 80001142 <kvmmap>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    800018f4:	0b848493          	addi	s1,s1,184
    800018f8:	fd3493e3          	bne	s1,s3,800018be <proc_mapstacks+0x8c>
    800018fc:	bf51                	j	80001890 <proc_mapstacks+0x5e>
    }
  }
}
    800018fe:	60e6                	ld	ra,88(sp)
    80001900:	6446                	ld	s0,80(sp)
    80001902:	64a6                	ld	s1,72(sp)
    80001904:	6906                	ld	s2,64(sp)
    80001906:	79e2                	ld	s3,56(sp)
    80001908:	7a42                	ld	s4,48(sp)
    8000190a:	7aa2                	ld	s5,40(sp)
    8000190c:	7b02                	ld	s6,32(sp)
    8000190e:	6be2                	ld	s7,24(sp)
    80001910:	6c42                	ld	s8,16(sp)
    80001912:	6ca2                	ld	s9,8(sp)
    80001914:	6d02                	ld	s10,0(sp)
    80001916:	6125                	addi	sp,sp,96
    80001918:	8082                	ret

000000008000191a <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    8000191a:	7159                	addi	sp,sp,-112
    8000191c:	f486                	sd	ra,104(sp)
    8000191e:	f0a2                	sd	s0,96(sp)
    80001920:	eca6                	sd	s1,88(sp)
    80001922:	e8ca                	sd	s2,80(sp)
    80001924:	e4ce                	sd	s3,72(sp)
    80001926:	e0d2                	sd	s4,64(sp)
    80001928:	fc56                	sd	s5,56(sp)
    8000192a:	f85a                	sd	s6,48(sp)
    8000192c:	f45e                	sd	s7,40(sp)
    8000192e:	f062                	sd	s8,32(sp)
    80001930:	ec66                	sd	s9,24(sp)
    80001932:	e86a                	sd	s10,16(sp)
    80001934:	e46e                	sd	s11,8(sp)
    80001936:	1880                	addi	s0,sp,112
  struct proc *p;
  struct kthread *t;
  
  initlock(&pid_lock, "nextpid");
    80001938:	00008597          	auipc	a1,0x8
    8000193c:	8c858593          	addi	a1,a1,-1848 # 80009200 <digits+0x1c0>
    80001940:	00011517          	auipc	a0,0x11
    80001944:	96050513          	addi	a0,a0,-1696 # 800122a0 <pid_lock>
    80001948:	fffff097          	auipc	ra,0xfffff
    8000194c:	1ee080e7          	jalr	494(ra) # 80000b36 <initlock>
  initlock(&tid_lock,"nexttid");
    80001950:	00008597          	auipc	a1,0x8
    80001954:	8b858593          	addi	a1,a1,-1864 # 80009208 <digits+0x1c8>
    80001958:	00011517          	auipc	a0,0x11
    8000195c:	96050513          	addi	a0,a0,-1696 # 800122b8 <tid_lock>
    80001960:	fffff097          	auipc	ra,0xfffff
    80001964:	1d6080e7          	jalr	470(ra) # 80000b36 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001968:	00008597          	auipc	a1,0x8
    8000196c:	8a858593          	addi	a1,a1,-1880 # 80009210 <digits+0x1d0>
    80001970:	00011517          	auipc	a0,0x11
    80001974:	96050513          	addi	a0,a0,-1696 # 800122d0 <wait_lock>
    80001978:	fffff097          	auipc	ra,0xfffff
    8000197c:	1be080e7          	jalr	446(ra) # 80000b36 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {      
    80001980:	00011997          	auipc	s3,0x11
    80001984:	5f098993          	addi	s3,s3,1520 # 80012f70 <proc+0x848>
    80001988:	00011c17          	auipc	s8,0x11
    8000198c:	da0c0c13          	addi	s8,s8,-608 # 80012728 <proc>
      initlock(&p->lock, "proc");
      // p->kstack = KSTACK((int) (p - proc));
      int proc_index= (int)(p-proc);
    80001990:	8de2                	mv	s11,s8
    80001992:	00007d17          	auipc	s10,0x7
    80001996:	66ed0d13          	addi	s10,s10,1646 # 80009000 <etext>
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
        initlock(&t->lock, "thread");
    8000199a:	00008b97          	auipc	s7,0x8
    8000199e:	88eb8b93          	addi	s7,s7,-1906 # 80009228 <digits+0x1e8>
        int thread_index = (int)(t-p->kthreads);
    800019a2:	00007b17          	auipc	s6,0x7
    800019a6:	666b0b13          	addi	s6,s6,1638 # 80009008 <etext+0x8>
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    800019aa:	04000ab7          	lui	s5,0x4000
    800019ae:	1afd                	addi	s5,s5,-1
    800019b0:	0ab2                	slli	s5,s5,0xc
  for(p = proc; p < &proc[NPROC]; p++) {      
    800019b2:	6c85                	lui	s9,0x1
    800019b4:	848c8c93          	addi	s9,s9,-1976 # 848 <_entry-0x7ffff7b8>
    800019b8:	a809                	j	800019ca <procinit+0xb0>
    800019ba:	9c66                	add	s8,s8,s9
    800019bc:	99e6                	add	s3,s3,s9
    800019be:	00032797          	auipc	a5,0x32
    800019c2:	f6a78793          	addi	a5,a5,-150 # 80033928 <tickslock>
    800019c6:	06fc0263          	beq	s8,a5,80001a2a <procinit+0x110>
      initlock(&p->lock, "proc");
    800019ca:	00008597          	auipc	a1,0x8
    800019ce:	85658593          	addi	a1,a1,-1962 # 80009220 <digits+0x1e0>
    800019d2:	8562                	mv	a0,s8
    800019d4:	fffff097          	auipc	ra,0xfffff
    800019d8:	162080e7          	jalr	354(ra) # 80000b36 <initlock>
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    800019dc:	288c0a13          	addi	s4,s8,648
      int proc_index= (int)(p-proc);
    800019e0:	41bc0933          	sub	s2,s8,s11
    800019e4:	40395913          	srai	s2,s2,0x3
    800019e8:	000d3783          	ld	a5,0(s10)
    800019ec:	02f90933          	mul	s2,s2,a5
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    800019f0:	0039191b          	slliw	s2,s2,0x3
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    800019f4:	84d2                	mv	s1,s4
        initlock(&t->lock, "thread");
    800019f6:	85de                	mv	a1,s7
    800019f8:	8526                	mv	a0,s1
    800019fa:	fffff097          	auipc	ra,0xfffff
    800019fe:	13c080e7          	jalr	316(ra) # 80000b36 <initlock>
        int thread_index = (int)(t-p->kthreads);
    80001a02:	414487b3          	sub	a5,s1,s4
    80001a06:	878d                	srai	a5,a5,0x3
    80001a08:	000b3703          	ld	a4,0(s6)
    80001a0c:	02e787b3          	mul	a5,a5,a4
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    80001a10:	012787bb          	addw	a5,a5,s2
    80001a14:	2785                	addiw	a5,a5,1
    80001a16:	00d7979b          	slliw	a5,a5,0xd
    80001a1a:	40fa87b3          	sub	a5,s5,a5
    80001a1e:	fc9c                	sd	a5,56(s1)
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001a20:	0b848493          	addi	s1,s1,184
    80001a24:	fd3499e3          	bne	s1,s3,800019f6 <procinit+0xdc>
    80001a28:	bf49                	j	800019ba <procinit+0xa0>
      }
  }
}
    80001a2a:	70a6                	ld	ra,104(sp)
    80001a2c:	7406                	ld	s0,96(sp)
    80001a2e:	64e6                	ld	s1,88(sp)
    80001a30:	6946                	ld	s2,80(sp)
    80001a32:	69a6                	ld	s3,72(sp)
    80001a34:	6a06                	ld	s4,64(sp)
    80001a36:	7ae2                	ld	s5,56(sp)
    80001a38:	7b42                	ld	s6,48(sp)
    80001a3a:	7ba2                	ld	s7,40(sp)
    80001a3c:	7c02                	ld	s8,32(sp)
    80001a3e:	6ce2                	ld	s9,24(sp)
    80001a40:	6d42                	ld	s10,16(sp)
    80001a42:	6da2                	ld	s11,8(sp)
    80001a44:	6165                	addi	sp,sp,112
    80001a46:	8082                	ret

0000000080001a48 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a48:	1141                	addi	sp,sp,-16
    80001a4a:	e422                	sd	s0,8(sp)
    80001a4c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a4e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a50:	2501                	sext.w	a0,a0
    80001a52:	6422                	ld	s0,8(sp)
    80001a54:	0141                	addi	sp,sp,16
    80001a56:	8082                	ret

0000000080001a58 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001a58:	1141                	addi	sp,sp,-16
    80001a5a:	e422                	sd	s0,8(sp)
    80001a5c:	0800                	addi	s0,sp,16
    80001a5e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a60:	0007851b          	sext.w	a0,a5
    80001a64:	00451793          	slli	a5,a0,0x4
    80001a68:	97aa                	add	a5,a5,a0
    80001a6a:	078e                	slli	a5,a5,0x3
  return c;
}
    80001a6c:	00011517          	auipc	a0,0x11
    80001a70:	87c50513          	addi	a0,a0,-1924 # 800122e8 <cpus>
    80001a74:	953e                	add	a0,a0,a5
    80001a76:	6422                	ld	s0,8(sp)
    80001a78:	0141                	addi	sp,sp,16
    80001a7a:	8082                	ret

0000000080001a7c <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001a7c:	1101                	addi	sp,sp,-32
    80001a7e:	ec06                	sd	ra,24(sp)
    80001a80:	e822                	sd	s0,16(sp)
    80001a82:	e426                	sd	s1,8(sp)
    80001a84:	1000                	addi	s0,sp,32
  push_off();
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	0f4080e7          	jalr	244(ra) # 80000b7a <push_off>
    80001a8e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a90:	0007871b          	sext.w	a4,a5
    80001a94:	00471793          	slli	a5,a4,0x4
    80001a98:	97ba                	add	a5,a5,a4
    80001a9a:	078e                	slli	a5,a5,0x3
    80001a9c:	00011717          	auipc	a4,0x11
    80001aa0:	80470713          	addi	a4,a4,-2044 # 800122a0 <pid_lock>
    80001aa4:	97ba                	add	a5,a5,a4
    80001aa6:	67a4                	ld	s1,72(a5)
  pop_off();
    80001aa8:	fffff097          	auipc	ra,0xfffff
    80001aac:	194080e7          	jalr	404(ra) # 80000c3c <pop_off>
  return p;
}//
    80001ab0:	8526                	mv	a0,s1
    80001ab2:	60e2                	ld	ra,24(sp)
    80001ab4:	6442                	ld	s0,16(sp)
    80001ab6:	64a2                	ld	s1,8(sp)
    80001ab8:	6105                	addi	sp,sp,32
    80001aba:	8082                	ret

0000000080001abc <mykthread>:

struct kthread*
mykthread(void){
    80001abc:	1101                	addi	sp,sp,-32
    80001abe:	ec06                	sd	ra,24(sp)
    80001ac0:	e822                	sd	s0,16(sp)
    80001ac2:	e426                	sd	s1,8(sp)
    80001ac4:	1000                	addi	s0,sp,32
  push_off();
    80001ac6:	fffff097          	auipc	ra,0xfffff
    80001aca:	0b4080e7          	jalr	180(ra) # 80000b7a <push_off>
    80001ace:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct kthread *t=c->kthread;
    80001ad0:	0007871b          	sext.w	a4,a5
    80001ad4:	00471793          	slli	a5,a4,0x4
    80001ad8:	97ba                	add	a5,a5,a4
    80001ada:	078e                	slli	a5,a5,0x3
    80001adc:	00010717          	auipc	a4,0x10
    80001ae0:	7c470713          	addi	a4,a4,1988 # 800122a0 <pid_lock>
    80001ae4:	97ba                	add	a5,a5,a4
    80001ae6:	67e4                	ld	s1,200(a5)
  pop_off();
    80001ae8:	fffff097          	auipc	ra,0xfffff
    80001aec:	154080e7          	jalr	340(ra) # 80000c3c <pop_off>
  return t;  
}
    80001af0:	8526                	mv	a0,s1
    80001af2:	60e2                	ld	ra,24(sp)
    80001af4:	6442                	ld	s0,16(sp)
    80001af6:	64a2                	ld	s1,8(sp)
    80001af8:	6105                	addi	sp,sp,32
    80001afa:	8082                	ret

0000000080001afc <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001afc:	1141                	addi	sp,sp,-16
    80001afe:	e406                	sd	ra,8(sp)
    80001b00:	e022                	sd	s0,0(sp)
    80001b02:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  // release(&myproc()->lock);

  release(&mykthread()->lock);    // TODO: check if this change is good
    80001b04:	00000097          	auipc	ra,0x0
    80001b08:	fb8080e7          	jalr	-72(ra) # 80001abc <mykthread>
    80001b0c:	fffff097          	auipc	ra,0xfffff
    80001b10:	190080e7          	jalr	400(ra) # 80000c9c <release>

  if (first) {
    80001b14:	00008797          	auipc	a5,0x8
    80001b18:	f0c7a783          	lw	a5,-244(a5) # 80009a20 <first.1>
    80001b1c:	e795                	bnez	a5,80001b48 <forkret+0x4c>
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }
  printf("ffret%d\n",myproc()->pid);//TODO delete
    80001b1e:	00000097          	auipc	ra,0x0
    80001b22:	f5e080e7          	jalr	-162(ra) # 80001a7c <myproc>
    80001b26:	514c                	lw	a1,36(a0)
    80001b28:	00007517          	auipc	a0,0x7
    80001b2c:	70850513          	addi	a0,a0,1800 # 80009230 <digits+0x1f0>
    80001b30:	fffff097          	auipc	ra,0xfffff
    80001b34:	a48080e7          	jalr	-1464(ra) # 80000578 <printf>


  usertrapret();
    80001b38:	00002097          	auipc	ra,0x2
    80001b3c:	a54080e7          	jalr	-1452(ra) # 8000358c <usertrapret>
}
    80001b40:	60a2                	ld	ra,8(sp)
    80001b42:	6402                	ld	s0,0(sp)
    80001b44:	0141                	addi	sp,sp,16
    80001b46:	8082                	ret
    first = 0;
    80001b48:	00008797          	auipc	a5,0x8
    80001b4c:	ec07ac23          	sw	zero,-296(a5) # 80009a20 <first.1>
    fsinit(ROOTDEV);
    80001b50:	4505                	li	a0,1
    80001b52:	00003097          	auipc	ra,0x3
    80001b56:	a4c080e7          	jalr	-1460(ra) # 8000459e <fsinit>
    80001b5a:	b7d1                	j	80001b1e <forkret+0x22>

0000000080001b5c <allocpid>:
allocpid() {
    80001b5c:	1101                	addi	sp,sp,-32
    80001b5e:	ec06                	sd	ra,24(sp)
    80001b60:	e822                	sd	s0,16(sp)
    80001b62:	e426                	sd	s1,8(sp)
    80001b64:	e04a                	sd	s2,0(sp)
    80001b66:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b68:	00010917          	auipc	s2,0x10
    80001b6c:	73890913          	addi	s2,s2,1848 # 800122a0 <pid_lock>
    80001b70:	854a                	mv	a0,s2
    80001b72:	fffff097          	auipc	ra,0xfffff
    80001b76:	054080e7          	jalr	84(ra) # 80000bc6 <acquire>
  pid = nextpid;
    80001b7a:	00008797          	auipc	a5,0x8
    80001b7e:	eae78793          	addi	a5,a5,-338 # 80009a28 <nextpid>
    80001b82:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b84:	0014871b          	addiw	a4,s1,1
    80001b88:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b8a:	854a                	mv	a0,s2
    80001b8c:	fffff097          	auipc	ra,0xfffff
    80001b90:	110080e7          	jalr	272(ra) # 80000c9c <release>
}
    80001b94:	8526                	mv	a0,s1
    80001b96:	60e2                	ld	ra,24(sp)
    80001b98:	6442                	ld	s0,16(sp)
    80001b9a:	64a2                	ld	s1,8(sp)
    80001b9c:	6902                	ld	s2,0(sp)
    80001b9e:	6105                	addi	sp,sp,32
    80001ba0:	8082                	ret

0000000080001ba2 <alloctid>:
alloctid() {
    80001ba2:	1101                	addi	sp,sp,-32
    80001ba4:	ec06                	sd	ra,24(sp)
    80001ba6:	e822                	sd	s0,16(sp)
    80001ba8:	e426                	sd	s1,8(sp)
    80001baa:	e04a                	sd	s2,0(sp)
    80001bac:	1000                	addi	s0,sp,32
  acquire(&tid_lock);
    80001bae:	00010917          	auipc	s2,0x10
    80001bb2:	70a90913          	addi	s2,s2,1802 # 800122b8 <tid_lock>
    80001bb6:	854a                	mv	a0,s2
    80001bb8:	fffff097          	auipc	ra,0xfffff
    80001bbc:	00e080e7          	jalr	14(ra) # 80000bc6 <acquire>
  tid = nexttid;
    80001bc0:	00008797          	auipc	a5,0x8
    80001bc4:	e6478793          	addi	a5,a5,-412 # 80009a24 <nexttid>
    80001bc8:	4384                	lw	s1,0(a5)
  nexttid = nexttid + 1;
    80001bca:	0014871b          	addiw	a4,s1,1
    80001bce:	c398                	sw	a4,0(a5)
  release(&tid_lock);
    80001bd0:	854a                	mv	a0,s2
    80001bd2:	fffff097          	auipc	ra,0xfffff
    80001bd6:	0ca080e7          	jalr	202(ra) # 80000c9c <release>
}
    80001bda:	8526                	mv	a0,s1
    80001bdc:	60e2                	ld	ra,24(sp)
    80001bde:	6442                	ld	s0,16(sp)
    80001be0:	64a2                	ld	s1,8(sp)
    80001be2:	6902                	ld	s2,0(sp)
    80001be4:	6105                	addi	sp,sp,32
    80001be6:	8082                	ret

0000000080001be8 <init_thread>:
init_thread(struct kthread *t){
    80001be8:	1101                	addi	sp,sp,-32
    80001bea:	ec06                	sd	ra,24(sp)
    80001bec:	e822                	sd	s0,16(sp)
    80001bee:	e426                	sd	s1,8(sp)
    80001bf0:	1000                	addi	s0,sp,32
    80001bf2:	84aa                	mv	s1,a0
  t->state = TUSED;
    80001bf4:	4785                	li	a5,1
    80001bf6:	cd1c                	sw	a5,24(a0)
  t->tid = alloctid();  
    80001bf8:	00000097          	auipc	ra,0x0
    80001bfc:	faa080e7          	jalr	-86(ra) # 80001ba2 <alloctid>
    80001c00:	d888                	sw	a0,48(s1)
  memset(&(t->context), 0, sizeof(t->context));
    80001c02:	07000613          	li	a2,112
    80001c06:	4581                	li	a1,0
    80001c08:	04848513          	addi	a0,s1,72
    80001c0c:	fffff097          	auipc	ra,0xfffff
    80001c10:	0d8080e7          	jalr	216(ra) # 80000ce4 <memset>
  t->context.ra = (uint64)forkret;
    80001c14:	00000797          	auipc	a5,0x0
    80001c18:	ee878793          	addi	a5,a5,-280 # 80001afc <forkret>
    80001c1c:	e4bc                	sd	a5,72(s1)
  t->context.sp = t->kstack + PGSIZE;
    80001c1e:	7c9c                	ld	a5,56(s1)
    80001c20:	6705                	lui	a4,0x1
    80001c22:	97ba                	add	a5,a5,a4
    80001c24:	e8bc                	sd	a5,80(s1)
}
    80001c26:	4501                	li	a0,0
    80001c28:	60e2                	ld	ra,24(sp)
    80001c2a:	6442                	ld	s0,16(sp)
    80001c2c:	64a2                	ld	s1,8(sp)
    80001c2e:	6105                	addi	sp,sp,32
    80001c30:	8082                	ret

0000000080001c32 <proc_pagetable>:
{
    80001c32:	1101                	addi	sp,sp,-32
    80001c34:	ec06                	sd	ra,24(sp)
    80001c36:	e822                	sd	s0,16(sp)
    80001c38:	e426                	sd	s1,8(sp)
    80001c3a:	e04a                	sd	s2,0(sp)
    80001c3c:	1000                	addi	s0,sp,32
    80001c3e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c40:	fffff097          	auipc	ra,0xfffff
    80001c44:	6ec080e7          	jalr	1772(ra) # 8000132c <uvmcreate>
    80001c48:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c4a:	c121                	beqz	a0,80001c8a <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c4c:	4729                	li	a4,10
    80001c4e:	00006697          	auipc	a3,0x6
    80001c52:	3b268693          	addi	a3,a3,946 # 80008000 <_trampoline>
    80001c56:	6605                	lui	a2,0x1
    80001c58:	040005b7          	lui	a1,0x4000
    80001c5c:	15fd                	addi	a1,a1,-1
    80001c5e:	05b2                	slli	a1,a1,0xc
    80001c60:	fffff097          	auipc	ra,0xfffff
    80001c64:	454080e7          	jalr	1108(ra) # 800010b4 <mappages>
    80001c68:	02054863          	bltz	a0,80001c98 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c6c:	4719                	li	a4,6
    80001c6e:	04893683          	ld	a3,72(s2)
    80001c72:	6605                	lui	a2,0x1
    80001c74:	020005b7          	lui	a1,0x2000
    80001c78:	15fd                	addi	a1,a1,-1
    80001c7a:	05b6                	slli	a1,a1,0xd
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	fffff097          	auipc	ra,0xfffff
    80001c82:	436080e7          	jalr	1078(ra) # 800010b4 <mappages>
    80001c86:	02054163          	bltz	a0,80001ca8 <proc_pagetable+0x76>
}
    80001c8a:	8526                	mv	a0,s1
    80001c8c:	60e2                	ld	ra,24(sp)
    80001c8e:	6442                	ld	s0,16(sp)
    80001c90:	64a2                	ld	s1,8(sp)
    80001c92:	6902                	ld	s2,0(sp)
    80001c94:	6105                	addi	sp,sp,32
    80001c96:	8082                	ret
    uvmfree(pagetable, 0);
    80001c98:	4581                	li	a1,0
    80001c9a:	8526                	mv	a0,s1
    80001c9c:	00000097          	auipc	ra,0x0
    80001ca0:	88c080e7          	jalr	-1908(ra) # 80001528 <uvmfree>
    return 0;
    80001ca4:	4481                	li	s1,0
    80001ca6:	b7d5                	j	80001c8a <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ca8:	4681                	li	a3,0
    80001caa:	4605                	li	a2,1
    80001cac:	040005b7          	lui	a1,0x4000
    80001cb0:	15fd                	addi	a1,a1,-1
    80001cb2:	05b2                	slli	a1,a1,0xc
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	fffff097          	auipc	ra,0xfffff
    80001cba:	5b2080e7          	jalr	1458(ra) # 80001268 <uvmunmap>
    uvmfree(pagetable, 0);
    80001cbe:	4581                	li	a1,0
    80001cc0:	8526                	mv	a0,s1
    80001cc2:	00000097          	auipc	ra,0x0
    80001cc6:	866080e7          	jalr	-1946(ra) # 80001528 <uvmfree>
    return 0;
    80001cca:	4481                	li	s1,0
    80001ccc:	bf7d                	j	80001c8a <proc_pagetable+0x58>

0000000080001cce <proc_freepagetable>:
{
    80001cce:	1101                	addi	sp,sp,-32
    80001cd0:	ec06                	sd	ra,24(sp)
    80001cd2:	e822                	sd	s0,16(sp)
    80001cd4:	e426                	sd	s1,8(sp)
    80001cd6:	e04a                	sd	s2,0(sp)
    80001cd8:	1000                	addi	s0,sp,32
    80001cda:	84aa                	mv	s1,a0
    80001cdc:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cde:	4681                	li	a3,0
    80001ce0:	4605                	li	a2,1
    80001ce2:	040005b7          	lui	a1,0x4000
    80001ce6:	15fd                	addi	a1,a1,-1
    80001ce8:	05b2                	slli	a1,a1,0xc
    80001cea:	fffff097          	auipc	ra,0xfffff
    80001cee:	57e080e7          	jalr	1406(ra) # 80001268 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cf2:	4681                	li	a3,0
    80001cf4:	4605                	li	a2,1
    80001cf6:	020005b7          	lui	a1,0x2000
    80001cfa:	15fd                	addi	a1,a1,-1
    80001cfc:	05b6                	slli	a1,a1,0xd
    80001cfe:	8526                	mv	a0,s1
    80001d00:	fffff097          	auipc	ra,0xfffff
    80001d04:	568080e7          	jalr	1384(ra) # 80001268 <uvmunmap>
  uvmfree(pagetable, sz);
    80001d08:	85ca                	mv	a1,s2
    80001d0a:	8526                	mv	a0,s1
    80001d0c:	00000097          	auipc	ra,0x0
    80001d10:	81c080e7          	jalr	-2020(ra) # 80001528 <uvmfree>
}
    80001d14:	60e2                	ld	ra,24(sp)
    80001d16:	6442                	ld	s0,16(sp)
    80001d18:	64a2                	ld	s1,8(sp)
    80001d1a:	6902                	ld	s2,0(sp)
    80001d1c:	6105                	addi	sp,sp,32
    80001d1e:	8082                	ret

0000000080001d20 <freeproc>:
{
    80001d20:	7179                	addi	sp,sp,-48
    80001d22:	f406                	sd	ra,40(sp)
    80001d24:	f022                	sd	s0,32(sp)
    80001d26:	ec26                	sd	s1,24(sp)
    80001d28:	e84a                	sd	s2,16(sp)
    80001d2a:	e44e                	sd	s3,8(sp)
    80001d2c:	1800                	addi	s0,sp,48
    80001d2e:	892a                	mv	s2,a0
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001d30:	28850493          	addi	s1,a0,648
    80001d34:	6985                	lui	s3,0x1
    80001d36:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80001d3a:	99aa                	add	s3,s3,a0
    80001d3c:	a811                	j	80001d50 <freeproc+0x30>
    release(&t->lock);
    80001d3e:	8526                	mv	a0,s1
    80001d40:	fffff097          	auipc	ra,0xfffff
    80001d44:	f5c080e7          	jalr	-164(ra) # 80000c9c <release>
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001d48:	0b848493          	addi	s1,s1,184
    80001d4c:	02998463          	beq	s3,s1,80001d74 <freeproc+0x54>
    acquire(&t->lock);
    80001d50:	8526                	mv	a0,s1
    80001d52:	fffff097          	auipc	ra,0xfffff
    80001d56:	e74080e7          	jalr	-396(ra) # 80000bc6 <acquire>
    if(t->state != TUNUSED)
    80001d5a:	4c9c                	lw	a5,24(s1)
    80001d5c:	d3ed                	beqz	a5,80001d3e <freeproc+0x1e>
  t->tid = 0;
    80001d5e:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80001d62:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80001d66:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80001d6a:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80001d6e:	0004ac23          	sw	zero,24(s1)
}
    80001d72:	b7f1                	j	80001d3e <freeproc+0x1e>
  p->user_trapframe_backup = 0;
    80001d74:	26093c23          	sd	zero,632(s2)
  if(p->pagetable)
    80001d78:	04093503          	ld	a0,64(s2)
    80001d7c:	c519                	beqz	a0,80001d8a <freeproc+0x6a>
    proc_freepagetable(p->pagetable, p->sz);
    80001d7e:	03893583          	ld	a1,56(s2)
    80001d82:	00000097          	auipc	ra,0x0
    80001d86:	f4c080e7          	jalr	-180(ra) # 80001cce <proc_freepagetable>
  p->pagetable = 0;
    80001d8a:	04093023          	sd	zero,64(s2)
  p->sz = 0;
    80001d8e:	02093c23          	sd	zero,56(s2)
  p->pid = 0;
    80001d92:	02092223          	sw	zero,36(s2)
  p->parent = 0;
    80001d96:	02093823          	sd	zero,48(s2)
  p->name[0] = 0;
    80001d9a:	0c090c23          	sb	zero,216(s2)
  p->killed = 0;
    80001d9e:	00092e23          	sw	zero,28(s2)
  p->xstate = 0;
    80001da2:	02092023          	sw	zero,32(s2)
  p->active_threads = 0;
    80001da6:	02092423          	sw	zero,40(s2)
  p->state = UNUSED;
    80001daa:	00092c23          	sw	zero,24(s2)
}
    80001dae:	70a2                	ld	ra,40(sp)
    80001db0:	7402                	ld	s0,32(sp)
    80001db2:	64e2                	ld	s1,24(sp)
    80001db4:	6942                	ld	s2,16(sp)
    80001db6:	69a2                	ld	s3,8(sp)
    80001db8:	6145                	addi	sp,sp,48
    80001dba:	8082                	ret

0000000080001dbc <allocproc>:
{
    80001dbc:	7179                	addi	sp,sp,-48
    80001dbe:	f406                	sd	ra,40(sp)
    80001dc0:	f022                	sd	s0,32(sp)
    80001dc2:	ec26                	sd	s1,24(sp)
    80001dc4:	e84a                	sd	s2,16(sp)
    80001dc6:	e44e                	sd	s3,8(sp)
    80001dc8:	e052                	sd	s4,0(sp)
    80001dca:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dcc:	00011497          	auipc	s1,0x11
    80001dd0:	95c48493          	addi	s1,s1,-1700 # 80012728 <proc>
    80001dd4:	6985                	lui	s3,0x1
    80001dd6:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80001dda:	00032a17          	auipc	s4,0x32
    80001dde:	b4ea0a13          	addi	s4,s4,-1202 # 80033928 <tickslock>
    acquire(&p->lock);
    80001de2:	8926                	mv	s2,s1
    80001de4:	8526                	mv	a0,s1
    80001de6:	fffff097          	auipc	ra,0xfffff
    80001dea:	de0080e7          	jalr	-544(ra) # 80000bc6 <acquire>
    if(p->state == UNUSED) {
    80001dee:	4c9c                	lw	a5,24(s1)
    80001df0:	cb99                	beqz	a5,80001e06 <allocproc+0x4a>
      release(&p->lock);
    80001df2:	8526                	mv	a0,s1
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	ea8080e7          	jalr	-344(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dfc:	94ce                	add	s1,s1,s3
    80001dfe:	ff4492e3          	bne	s1,s4,80001de2 <allocproc+0x26>
  return 0;
    80001e02:	4481                	li	s1,0
    80001e04:	a845                	j	80001eb4 <allocproc+0xf8>
  p->pid = allocpid();
    80001e06:	00000097          	auipc	ra,0x0
    80001e0a:	d56080e7          	jalr	-682(ra) # 80001b5c <allocpid>
    80001e0e:	d0c8                	sw	a0,36(s1)
  p->state = USED;
    80001e10:	4785                	li	a5,1
    80001e12:	cc9c                	sw	a5,24(s1)
  if((p->threads_tf_start =kalloc()) == 0){
    80001e14:	fffff097          	auipc	ra,0xfffff
    80001e18:	cc2080e7          	jalr	-830(ra) # 80000ad6 <kalloc>
    80001e1c:	89aa                	mv	s3,a0
    80001e1e:	e4a8                	sd	a0,72(s1)
    80001e20:	0f848713          	addi	a4,s1,248
    80001e24:	1f848793          	addi	a5,s1,504
    80001e28:	27848693          	addi	a3,s1,632
    80001e2c:	cd49                	beqz	a0,80001ec6 <allocproc+0x10a>
    p->signal_handlers[i] = SIG_DFL;
    80001e2e:	00073023          	sd	zero,0(a4) # 1000 <_entry-0x7ffff000>
    p->handlers_sigmasks[i] = 0;
    80001e32:	0007a023          	sw	zero,0(a5)
  for(int i=0;i<32;i++){
    80001e36:	0721                	addi	a4,a4,8
    80001e38:	0791                	addi	a5,a5,4
    80001e3a:	fed79ae3          	bne	a5,a3,80001e2e <allocproc+0x72>
  p->signal_mask= 0;
    80001e3e:	0e04a623          	sw	zero,236(s1)
  p->pending_signals = 0;
    80001e42:	0e04a423          	sw	zero,232(s1)
  p->active_threads=1;
    80001e46:	4785                	li	a5,1
    80001e48:	d49c                	sw	a5,40(s1)
  p->signal_mask_backup = 0;
    80001e4a:	0e04a823          	sw	zero,240(s1)
  p->handling_user_sig_flag = 0;
    80001e4e:	2804a023          	sw	zero,640(s1)
  p->handling_sig_flag=0;
    80001e52:	2804a223          	sw	zero,644(s1)
  p->pagetable = proc_pagetable(p);
    80001e56:	8526                	mv	a0,s1
    80001e58:	00000097          	auipc	ra,0x0
    80001e5c:	dda080e7          	jalr	-550(ra) # 80001c32 <proc_pagetable>
    80001e60:	89aa                	mv	s3,a0
    80001e62:	e0a8                	sd	a0,64(s1)
  if(p->pagetable == 0){
    80001e64:	cd2d                	beqz	a0,80001ede <allocproc+0x122>
    80001e66:	2a048793          	addi	a5,s1,672
    80001e6a:	64b8                	ld	a4,72(s1)
    80001e6c:	6685                	lui	a3,0x1
    80001e6e:	86068693          	addi	a3,a3,-1952 # 860 <_entry-0x7ffff7a0>
    80001e72:	9936                	add	s2,s2,a3
    t->tid=-1;
    80001e74:	56fd                	li	a3,-1
    t->state=TUNUSED;
    80001e76:	0007a023          	sw	zero,0(a5)
    t->chan=0;
    80001e7a:	0007b423          	sd	zero,8(a5)
    t->tid=-1;
    80001e7e:	cf94                	sw	a3,24(a5)
    t->trapframe = (struct trapframe *)p->threads_tf_start + i;     //TODO: check if good or maybe + i*sizeof(struct trapframe)
    80001e80:	f798                	sd	a4,40(a5)
    t->killed = 0;
    80001e82:	0007a823          	sw	zero,16(a5)
    t->frozen = 0;
    80001e86:	0007ae23          	sw	zero,28(a5)
  for(int i=0;i<NTHREAD;i++){
    80001e8a:	0b878793          	addi	a5,a5,184
    80001e8e:	12070713          	addi	a4,a4,288
    80001e92:	ff2792e3          	bne	a5,s2,80001e76 <allocproc+0xba>
  struct kthread *t= &p->kthreads[0];
    80001e96:	28848913          	addi	s2,s1,648
  acquire(&t->lock);
    80001e9a:	854a                	mv	a0,s2
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	d2a080e7          	jalr	-726(ra) # 80000bc6 <acquire>
  if(init_thread(t) == -1){
    80001ea4:	854a                	mv	a0,s2
    80001ea6:	00000097          	auipc	ra,0x0
    80001eaa:	d42080e7          	jalr	-702(ra) # 80001be8 <init_thread>
    80001eae:	57fd                	li	a5,-1
    80001eb0:	04f50363          	beq	a0,a5,80001ef6 <allocproc+0x13a>
}
    80001eb4:	8526                	mv	a0,s1
    80001eb6:	70a2                	ld	ra,40(sp)
    80001eb8:	7402                	ld	s0,32(sp)
    80001eba:	64e2                	ld	s1,24(sp)
    80001ebc:	6942                	ld	s2,16(sp)
    80001ebe:	69a2                	ld	s3,8(sp)
    80001ec0:	6a02                	ld	s4,0(sp)
    80001ec2:	6145                	addi	sp,sp,48
    80001ec4:	8082                	ret
    freeproc(p);
    80001ec6:	8526                	mv	a0,s1
    80001ec8:	00000097          	auipc	ra,0x0
    80001ecc:	e58080e7          	jalr	-424(ra) # 80001d20 <freeproc>
    release(&p->lock);
    80001ed0:	8526                	mv	a0,s1
    80001ed2:	fffff097          	auipc	ra,0xfffff
    80001ed6:	dca080e7          	jalr	-566(ra) # 80000c9c <release>
    return 0;
    80001eda:	84ce                	mv	s1,s3
    80001edc:	bfe1                	j	80001eb4 <allocproc+0xf8>
    freeproc(p);
    80001ede:	8526                	mv	a0,s1
    80001ee0:	00000097          	auipc	ra,0x0
    80001ee4:	e40080e7          	jalr	-448(ra) # 80001d20 <freeproc>
    release(&p->lock);
    80001ee8:	8526                	mv	a0,s1
    80001eea:	fffff097          	auipc	ra,0xfffff
    80001eee:	db2080e7          	jalr	-590(ra) # 80000c9c <release>
    return 0;
    80001ef2:	84ce                	mv	s1,s3
    80001ef4:	b7c1                	j	80001eb4 <allocproc+0xf8>
    freeproc(p);
    80001ef6:	8526                	mv	a0,s1
    80001ef8:	00000097          	auipc	ra,0x0
    80001efc:	e28080e7          	jalr	-472(ra) # 80001d20 <freeproc>
    release(&p->lock);  
    80001f00:	8526                	mv	a0,s1
    80001f02:	fffff097          	auipc	ra,0xfffff
    80001f06:	d9a080e7          	jalr	-614(ra) # 80000c9c <release>
    return 0;
    80001f0a:	4481                	li	s1,0
    80001f0c:	b765                	j	80001eb4 <allocproc+0xf8>

0000000080001f0e <userinit>:
{
    80001f0e:	1101                	addi	sp,sp,-32
    80001f10:	ec06                	sd	ra,24(sp)
    80001f12:	e822                	sd	s0,16(sp)
    80001f14:	e426                	sd	s1,8(sp)
    80001f16:	1000                	addi	s0,sp,32
    80001f18:	8792                	mv	a5,tp
  p = allocproc();
    80001f1a:	00000097          	auipc	ra,0x0
    80001f1e:	ea2080e7          	jalr	-350(ra) # 80001dbc <allocproc>
    80001f22:	84aa                	mv	s1,a0
  initproc = p;
    80001f24:	00008797          	auipc	a5,0x8
    80001f28:	10a7b223          	sd	a0,260(a5) # 8000a028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001f2c:	03400613          	li	a2,52
    80001f30:	00008597          	auipc	a1,0x8
    80001f34:	b0058593          	addi	a1,a1,-1280 # 80009a30 <initcode>
    80001f38:	6128                	ld	a0,64(a0)
    80001f3a:	fffff097          	auipc	ra,0xfffff
    80001f3e:	420080e7          	jalr	1056(ra) # 8000135a <uvminit>
  p->sz = PGSIZE;
    80001f42:	6785                	lui	a5,0x1
    80001f44:	fc9c                	sd	a5,56(s1)
  t->trapframe->epc = 0;      // user program counter
    80001f46:	2c84b703          	ld	a4,712(s1)
    80001f4a:	00073c23          	sd	zero,24(a4)
  t->trapframe->sp = PGSIZE;  // user stack pointer
    80001f4e:	2c84b703          	ld	a4,712(s1)
    80001f52:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f54:	4641                	li	a2,16
    80001f56:	00007597          	auipc	a1,0x7
    80001f5a:	2ea58593          	addi	a1,a1,746 # 80009240 <digits+0x200>
    80001f5e:	0d848513          	addi	a0,s1,216
    80001f62:	fffff097          	auipc	ra,0xfffff
    80001f66:	ed4080e7          	jalr	-300(ra) # 80000e36 <safestrcpy>
  p->cwd = namei("/");
    80001f6a:	00007517          	auipc	a0,0x7
    80001f6e:	2e650513          	addi	a0,a0,742 # 80009250 <digits+0x210>
    80001f72:	00003097          	auipc	ra,0x3
    80001f76:	058080e7          	jalr	88(ra) # 80004fca <namei>
    80001f7a:	e8e8                	sd	a0,208(s1)
  p->state = RUNNABLE;
    80001f7c:	4789                	li	a5,2
    80001f7e:	cc9c                	sw	a5,24(s1)
  t->state = TRUNNABLE;
    80001f80:	478d                	li	a5,3
    80001f82:	2af4a023          	sw	a5,672(s1)
  release(&p->lock);
    80001f86:	8526                	mv	a0,s1
    80001f88:	fffff097          	auipc	ra,0xfffff
    80001f8c:	d14080e7          	jalr	-748(ra) # 80000c9c <release>
  release(&p->kthreads[0].lock);////////////////////////////////////////////////////////////////check
    80001f90:	28848513          	addi	a0,s1,648
    80001f94:	fffff097          	auipc	ra,0xfffff
    80001f98:	d08080e7          	jalr	-760(ra) # 80000c9c <release>
}
    80001f9c:	60e2                	ld	ra,24(sp)
    80001f9e:	6442                	ld	s0,16(sp)
    80001fa0:	64a2                	ld	s1,8(sp)
    80001fa2:	6105                	addi	sp,sp,32
    80001fa4:	8082                	ret

0000000080001fa6 <growproc>:
{
    80001fa6:	1101                	addi	sp,sp,-32
    80001fa8:	ec06                	sd	ra,24(sp)
    80001faa:	e822                	sd	s0,16(sp)
    80001fac:	e426                	sd	s1,8(sp)
    80001fae:	e04a                	sd	s2,0(sp)
    80001fb0:	1000                	addi	s0,sp,32
    80001fb2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fb4:	00000097          	auipc	ra,0x0
    80001fb8:	ac8080e7          	jalr	-1336(ra) # 80001a7c <myproc>
    80001fbc:	892a                	mv	s2,a0
  sz = p->sz;
    80001fbe:	7d0c                	ld	a1,56(a0)
    80001fc0:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001fc4:	00904f63          	bgtz	s1,80001fe2 <growproc+0x3c>
  } else if(n < 0){
    80001fc8:	0204cc63          	bltz	s1,80002000 <growproc+0x5a>
  p->sz = sz;
    80001fcc:	1602                	slli	a2,a2,0x20
    80001fce:	9201                	srli	a2,a2,0x20
    80001fd0:	02c93c23          	sd	a2,56(s2)
  return 0;
    80001fd4:	4501                	li	a0,0
}
    80001fd6:	60e2                	ld	ra,24(sp)
    80001fd8:	6442                	ld	s0,16(sp)
    80001fda:	64a2                	ld	s1,8(sp)
    80001fdc:	6902                	ld	s2,0(sp)
    80001fde:	6105                	addi	sp,sp,32
    80001fe0:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001fe2:	9e25                	addw	a2,a2,s1
    80001fe4:	1602                	slli	a2,a2,0x20
    80001fe6:	9201                	srli	a2,a2,0x20
    80001fe8:	1582                	slli	a1,a1,0x20
    80001fea:	9181                	srli	a1,a1,0x20
    80001fec:	6128                	ld	a0,64(a0)
    80001fee:	fffff097          	auipc	ra,0xfffff
    80001ff2:	426080e7          	jalr	1062(ra) # 80001414 <uvmalloc>
    80001ff6:	0005061b          	sext.w	a2,a0
    80001ffa:	fa69                	bnez	a2,80001fcc <growproc+0x26>
      return -1;
    80001ffc:	557d                	li	a0,-1
    80001ffe:	bfe1                	j	80001fd6 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002000:	9e25                	addw	a2,a2,s1
    80002002:	1602                	slli	a2,a2,0x20
    80002004:	9201                	srli	a2,a2,0x20
    80002006:	1582                	slli	a1,a1,0x20
    80002008:	9181                	srli	a1,a1,0x20
    8000200a:	6128                	ld	a0,64(a0)
    8000200c:	fffff097          	auipc	ra,0xfffff
    80002010:	3c0080e7          	jalr	960(ra) # 800013cc <uvmdealloc>
    80002014:	0005061b          	sext.w	a2,a0
    80002018:	bf55                	j	80001fcc <growproc+0x26>

000000008000201a <fork>:
{
    8000201a:	7139                	addi	sp,sp,-64
    8000201c:	fc06                	sd	ra,56(sp)
    8000201e:	f822                	sd	s0,48(sp)
    80002020:	f426                	sd	s1,40(sp)
    80002022:	f04a                	sd	s2,32(sp)
    80002024:	ec4e                	sd	s3,24(sp)
    80002026:	e852                	sd	s4,16(sp)
    80002028:	e456                	sd	s5,8(sp)
    8000202a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000202c:	00000097          	auipc	ra,0x0
    80002030:	a50080e7          	jalr	-1456(ra) # 80001a7c <myproc>
    80002034:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    80002036:	00000097          	auipc	ra,0x0
    8000203a:	a86080e7          	jalr	-1402(ra) # 80001abc <mykthread>
    8000203e:	84aa                	mv	s1,a0
  if((np = allocproc()) == 0){//////////////////////////////////////////////////check  lock p and t
    80002040:	00000097          	auipc	ra,0x0
    80002044:	d7c080e7          	jalr	-644(ra) # 80001dbc <allocproc>
    80002048:	16050f63          	beqz	a0,800021c6 <fork+0x1ac>
    8000204c:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000204e:	0389b603          	ld	a2,56(s3)
    80002052:	612c                	ld	a1,64(a0)
    80002054:	0409b503          	ld	a0,64(s3)
    80002058:	fffff097          	auipc	ra,0xfffff
    8000205c:	508080e7          	jalr	1288(ra) # 80001560 <uvmcopy>
    80002060:	06054763          	bltz	a0,800020ce <fork+0xb4>
  np->sz = p->sz;
    80002064:	0389b783          	ld	a5,56(s3)
    80002068:	02f93c23          	sd	a5,56(s2)
  acquire(&wait_lock);/////////////////////////////////////////////////////////////////check
    8000206c:	00010517          	auipc	a0,0x10
    80002070:	26450513          	addi	a0,a0,612 # 800122d0 <wait_lock>
    80002074:	fffff097          	auipc	ra,0xfffff
    80002078:	b52080e7          	jalr	-1198(ra) # 80000bc6 <acquire>
  *(np_first_thread->trapframe) = *(t->trapframe);
    8000207c:	60b4                	ld	a3,64(s1)
    8000207e:	87b6                	mv	a5,a3
    80002080:	2c893703          	ld	a4,712(s2)
    80002084:	12068693          	addi	a3,a3,288
    80002088:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000208c:	6788                	ld	a0,8(a5)
    8000208e:	6b8c                	ld	a1,16(a5)
    80002090:	6f90                	ld	a2,24(a5)
    80002092:	01073023          	sd	a6,0(a4)
    80002096:	e708                	sd	a0,8(a4)
    80002098:	eb0c                	sd	a1,16(a4)
    8000209a:	ef10                	sd	a2,24(a4)
    8000209c:	02078793          	addi	a5,a5,32
    800020a0:	02070713          	addi	a4,a4,32
    800020a4:	fed792e3          	bne	a5,a3,80002088 <fork+0x6e>
  np_first_thread->trapframe->a0 = 0;  // TODO: change reading the ret value from proc a0 to thread a0
    800020a8:	2c893783          	ld	a5,712(s2)
    800020ac:	0607b823          	sd	zero,112(a5)
  release(&wait_lock);////////////////////////////////////////////////////////////////check
    800020b0:	00010517          	auipc	a0,0x10
    800020b4:	22050513          	addi	a0,a0,544 # 800122d0 <wait_lock>
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	be4080e7          	jalr	-1052(ra) # 80000c9c <release>
  for(i = 0; i < NOFILE; i++)
    800020c0:	05098493          	addi	s1,s3,80
    800020c4:	05090a13          	addi	s4,s2,80
    800020c8:	0d098a93          	addi	s5,s3,208
    800020cc:	a00d                	j	800020ee <fork+0xd4>
    freeproc(np);
    800020ce:	854a                	mv	a0,s2
    800020d0:	00000097          	auipc	ra,0x0
    800020d4:	c50080e7          	jalr	-944(ra) # 80001d20 <freeproc>
    release(&np->lock);
    800020d8:	854a                	mv	a0,s2
    800020da:	fffff097          	auipc	ra,0xfffff
    800020de:	bc2080e7          	jalr	-1086(ra) # 80000c9c <release>
    return -1;
    800020e2:	5a7d                	li	s4,-1
    800020e4:	a0f9                	j	800021b2 <fork+0x198>
  for(i = 0; i < NOFILE; i++)
    800020e6:	04a1                	addi	s1,s1,8
    800020e8:	0a21                	addi	s4,s4,8
    800020ea:	01548b63          	beq	s1,s5,80002100 <fork+0xe6>
    if(p->ofile[i])
    800020ee:	6088                	ld	a0,0(s1)
    800020f0:	d97d                	beqz	a0,800020e6 <fork+0xcc>
      np->ofile[i] = filedup(p->ofile[i]);
    800020f2:	00003097          	auipc	ra,0x3
    800020f6:	572080e7          	jalr	1394(ra) # 80005664 <filedup>
    800020fa:	00aa3023          	sd	a0,0(s4)
    800020fe:	b7e5                	j	800020e6 <fork+0xcc>
  np->cwd = idup(p->cwd);
    80002100:	0d09b503          	ld	a0,208(s3)
    80002104:	00002097          	auipc	ra,0x2
    80002108:	6d4080e7          	jalr	1748(ra) # 800047d8 <idup>
    8000210c:	0ca93823          	sd	a0,208(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002110:	4641                	li	a2,16
    80002112:	0d898593          	addi	a1,s3,216
    80002116:	0d890513          	addi	a0,s2,216
    8000211a:	fffff097          	auipc	ra,0xfffff
    8000211e:	d1c080e7          	jalr	-740(ra) # 80000e36 <safestrcpy>
  np->signal_mask = p->signal_mask;
    80002122:	0ec9a783          	lw	a5,236(s3)
    80002126:	0ef92623          	sw	a5,236(s2)
  for(int i=0;i<32;i++){
    8000212a:	0f898693          	addi	a3,s3,248
    8000212e:	0f890713          	addi	a4,s2,248
  np->signal_mask = p->signal_mask;
    80002132:	1f800793          	li	a5,504
  for(int i=0;i<32;i++){
    80002136:	27800513          	li	a0,632
    np->signal_handlers[i] = p->signal_handlers[i];
    8000213a:	6290                	ld	a2,0(a3)
    8000213c:	e310                	sd	a2,0(a4)
    np->handlers_sigmasks[i] = p->handlers_sigmasks[i];
    8000213e:	00f98633          	add	a2,s3,a5
    80002142:	420c                	lw	a1,0(a2)
    80002144:	00f90633          	add	a2,s2,a5
    80002148:	c20c                	sw	a1,0(a2)
  for(int i=0;i<32;i++){
    8000214a:	06a1                	addi	a3,a3,8
    8000214c:	0721                	addi	a4,a4,8
    8000214e:	0791                	addi	a5,a5,4
    80002150:	fea795e3          	bne	a5,a0,8000213a <fork+0x120>
  np-> pending_signals=0;
    80002154:	0e092423          	sw	zero,232(s2)
  pid = np->pid;
    80002158:	02492a03          	lw	s4,36(s2)
  release(&np->lock);
    8000215c:	854a                	mv	a0,s2
    8000215e:	fffff097          	auipc	ra,0xfffff
    80002162:	b3e080e7          	jalr	-1218(ra) # 80000c9c <release>
  acquire(&wait_lock);
    80002166:	00010497          	auipc	s1,0x10
    8000216a:	16a48493          	addi	s1,s1,362 # 800122d0 <wait_lock>
    8000216e:	8526                	mv	a0,s1
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	a56080e7          	jalr	-1450(ra) # 80000bc6 <acquire>
  np->parent = p;
    80002178:	03393823          	sd	s3,48(s2)
  release(&wait_lock);
    8000217c:	8526                	mv	a0,s1
    8000217e:	fffff097          	auipc	ra,0xfffff
    80002182:	b1e080e7          	jalr	-1250(ra) # 80000c9c <release>
  acquire(&np->lock);
    80002186:	854a                	mv	a0,s2
    80002188:	fffff097          	auipc	ra,0xfffff
    8000218c:	a3e080e7          	jalr	-1474(ra) # 80000bc6 <acquire>
  np->state = RUNNABLE;   //TOOD: check if we still need this state or should change
    80002190:	4789                	li	a5,2
    80002192:	00f92c23          	sw	a5,24(s2)
  np_first_thread->state = TRUNNABLE;
    80002196:	478d                	li	a5,3
    80002198:	2af92023          	sw	a5,672(s2)
  release(&np_first_thread->lock);
    8000219c:	28890513          	addi	a0,s2,648
    800021a0:	fffff097          	auipc	ra,0xfffff
    800021a4:	afc080e7          	jalr	-1284(ra) # 80000c9c <release>
  release(&np->lock);
    800021a8:	854a                	mv	a0,s2
    800021aa:	fffff097          	auipc	ra,0xfffff
    800021ae:	af2080e7          	jalr	-1294(ra) # 80000c9c <release>
}
    800021b2:	8552                	mv	a0,s4
    800021b4:	70e2                	ld	ra,56(sp)
    800021b6:	7442                	ld	s0,48(sp)
    800021b8:	74a2                	ld	s1,40(sp)
    800021ba:	7902                	ld	s2,32(sp)
    800021bc:	69e2                	ld	s3,24(sp)
    800021be:	6a42                	ld	s4,16(sp)
    800021c0:	6aa2                	ld	s5,8(sp)
    800021c2:	6121                	addi	sp,sp,64
    800021c4:	8082                	ret
    return -1;
    800021c6:	5a7d                	li	s4,-1
    800021c8:	b7ed                	j	800021b2 <fork+0x198>

00000000800021ca <scheduler>:
{
    800021ca:	711d                	addi	sp,sp,-96
    800021cc:	ec86                	sd	ra,88(sp)
    800021ce:	e8a2                	sd	s0,80(sp)
    800021d0:	e4a6                	sd	s1,72(sp)
    800021d2:	e0ca                	sd	s2,64(sp)
    800021d4:	fc4e                	sd	s3,56(sp)
    800021d6:	f852                	sd	s4,48(sp)
    800021d8:	f456                	sd	s5,40(sp)
    800021da:	f05a                	sd	s6,32(sp)
    800021dc:	ec5e                	sd	s7,24(sp)
    800021de:	e862                	sd	s8,16(sp)
    800021e0:	e466                	sd	s9,8(sp)
    800021e2:	1080                	addi	s0,sp,96
    800021e4:	8792                	mv	a5,tp
  int id = r_tp();
    800021e6:	2781                	sext.w	a5,a5
  c->proc = 0;
    800021e8:	00479713          	slli	a4,a5,0x4
    800021ec:	00f706b3          	add	a3,a4,a5
    800021f0:	00369613          	slli	a2,a3,0x3
    800021f4:	00010697          	auipc	a3,0x10
    800021f8:	0ac68693          	addi	a3,a3,172 # 800122a0 <pid_lock>
    800021fc:	96b2                	add	a3,a3,a2
    800021fe:	0406b423          	sd	zero,72(a3)
  c->kthread=0;
    80002202:	0c06b423          	sd	zero,200(a3)
            swtch(&c->context, &t->context);
    80002206:	00010717          	auipc	a4,0x10
    8000220a:	0ea70713          	addi	a4,a4,234 # 800122f0 <cpus+0x8>
    8000220e:	00e60bb3          	add	s7,a2,a4
            c->proc = p;
    80002212:	8b36                	mv	s6,a3
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002214:	6a85                	lui	s5,0x1
    80002216:	848a8a93          	addi	s5,s5,-1976 # 848 <_entry-0x7ffff7b8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000221a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000221e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002222:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002226:	00010917          	auipc	s2,0x10
    8000222a:	50290913          	addi	s2,s2,1282 # 80012728 <proc>
    8000222e:	a0a5                	j	80002296 <scheduler+0xcc>
          release(&t->lock);
    80002230:	8526                	mv	a0,s1
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	a6a080e7          	jalr	-1430(ra) # 80000c9c <release>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    8000223a:	0b848493          	addi	s1,s1,184
    8000223e:	05348563          	beq	s1,s3,80002288 <scheduler+0xbe>
          acquire(&t->lock);
    80002242:	8526                	mv	a0,s1
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	982080e7          	jalr	-1662(ra) # 80000bc6 <acquire>
          if(t->state == TRUNNABLE && !t->frozen) {
    8000224c:	4c9c                	lw	a5,24(s1)
    8000224e:	ff4791e3          	bne	a5,s4,80002230 <scheduler+0x66>
    80002252:	58dc                	lw	a5,52(s1)
    80002254:	fff1                	bnez	a5,80002230 <scheduler+0x66>
            printf("%d\n",p->pid);
    80002256:	02492583          	lw	a1,36(s2)
    8000225a:	8566                	mv	a0,s9
    8000225c:	ffffe097          	auipc	ra,0xffffe
    80002260:	31c080e7          	jalr	796(ra) # 80000578 <printf>
            t->state = TRUNNING;
    80002264:	4791                	li	a5,4
    80002266:	cc9c                	sw	a5,24(s1)
            c->proc = p;
    80002268:	052b3423          	sd	s2,72(s6)
            c->kthread = t;
    8000226c:	0c9b3423          	sd	s1,200(s6)
            swtch(&c->context, &t->context);
    80002270:	04848593          	addi	a1,s1,72
    80002274:	855e                	mv	a0,s7
    80002276:	00001097          	auipc	ra,0x1
    8000227a:	fb2080e7          	jalr	-78(ra) # 80003228 <swtch>
            c->proc = 0;
    8000227e:	040b3423          	sd	zero,72(s6)
            c->kthread=0;
    80002282:	0c0b3423          	sd	zero,200(s6)
    80002286:	b76d                	j	80002230 <scheduler+0x66>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002288:	9956                	add	s2,s2,s5
    8000228a:	00031797          	auipc	a5,0x31
    8000228e:	69e78793          	addi	a5,a5,1694 # 80033928 <tickslock>
    80002292:	f8f904e3          	beq	s2,a5,8000221a <scheduler+0x50>
      if(p->state == RUNNABLE) {
    80002296:	01892703          	lw	a4,24(s2)
    8000229a:	4789                	li	a5,2
    8000229c:	fef716e3          	bne	a4,a5,80002288 <scheduler+0xbe>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    800022a0:	28890493          	addi	s1,s2,648
          if(t->state == TRUNNABLE && !t->frozen) {
    800022a4:	4a0d                	li	s4,3
            printf("%d\n",p->pid);
    800022a6:	00007c97          	auipc	s9,0x7
    800022aa:	35ac8c93          	addi	s9,s9,858 # 80009600 <states.0+0x1a0>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    800022ae:	015909b3          	add	s3,s2,s5
    800022b2:	bf41                	j	80002242 <scheduler+0x78>

00000000800022b4 <sched>:
{
    800022b4:	7179                	addi	sp,sp,-48
    800022b6:	f406                	sd	ra,40(sp)
    800022b8:	f022                	sd	s0,32(sp)
    800022ba:	ec26                	sd	s1,24(sp)
    800022bc:	e84a                	sd	s2,16(sp)
    800022be:	e44e                	sd	s3,8(sp)
    800022c0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	7ba080e7          	jalr	1978(ra) # 80001a7c <myproc>
    800022ca:	892a                	mv	s2,a0
  struct kthread *t=mykthread();
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	7f0080e7          	jalr	2032(ra) # 80001abc <mykthread>
    800022d4:	84aa                	mv	s1,a0
  if(!holding(&t->lock))
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	876080e7          	jalr	-1930(ra) # 80000b4c <holding>
    800022de:	c959                	beqz	a0,80002374 <sched+0xc0>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022e0:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800022e2:	0007871b          	sext.w	a4,a5
    800022e6:	00471793          	slli	a5,a4,0x4
    800022ea:	97ba                	add	a5,a5,a4
    800022ec:	078e                	slli	a5,a5,0x3
    800022ee:	00010717          	auipc	a4,0x10
    800022f2:	fb270713          	addi	a4,a4,-78 # 800122a0 <pid_lock>
    800022f6:	97ba                	add	a5,a5,a4
    800022f8:	0c07a703          	lw	a4,192(a5)
    800022fc:	4785                	li	a5,1
    800022fe:	08f71363          	bne	a4,a5,80002384 <sched+0xd0>
  if(t->state == TRUNNING){
    80002302:	4c98                	lw	a4,24(s1)
    80002304:	4791                	li	a5,4
    80002306:	08f70763          	beq	a4,a5,80002394 <sched+0xe0>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000230a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000230e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002310:	e7c5                	bnez	a5,800023b8 <sched+0x104>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002312:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002314:	00010917          	auipc	s2,0x10
    80002318:	f8c90913          	addi	s2,s2,-116 # 800122a0 <pid_lock>
    8000231c:	0007871b          	sext.w	a4,a5
    80002320:	00471793          	slli	a5,a4,0x4
    80002324:	97ba                	add	a5,a5,a4
    80002326:	078e                	slli	a5,a5,0x3
    80002328:	97ca                	add	a5,a5,s2
    8000232a:	0c47a983          	lw	s3,196(a5)
    8000232e:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    80002330:	0007859b          	sext.w	a1,a5
    80002334:	00459793          	slli	a5,a1,0x4
    80002338:	97ae                	add	a5,a5,a1
    8000233a:	078e                	slli	a5,a5,0x3
    8000233c:	00010597          	auipc	a1,0x10
    80002340:	fb458593          	addi	a1,a1,-76 # 800122f0 <cpus+0x8>
    80002344:	95be                	add	a1,a1,a5
    80002346:	04848513          	addi	a0,s1,72
    8000234a:	00001097          	auipc	ra,0x1
    8000234e:	ede080e7          	jalr	-290(ra) # 80003228 <swtch>
    80002352:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002354:	0007871b          	sext.w	a4,a5
    80002358:	00471793          	slli	a5,a4,0x4
    8000235c:	97ba                	add	a5,a5,a4
    8000235e:	078e                	slli	a5,a5,0x3
    80002360:	97ca                	add	a5,a5,s2
    80002362:	0d37a223          	sw	s3,196(a5)
}
    80002366:	70a2                	ld	ra,40(sp)
    80002368:	7402                	ld	s0,32(sp)
    8000236a:	64e2                	ld	s1,24(sp)
    8000236c:	6942                	ld	s2,16(sp)
    8000236e:	69a2                	ld	s3,8(sp)
    80002370:	6145                	addi	sp,sp,48
    80002372:	8082                	ret
    panic("sched t->lock");
    80002374:	00007517          	auipc	a0,0x7
    80002378:	ee450513          	addi	a0,a0,-284 # 80009258 <digits+0x218>
    8000237c:	ffffe097          	auipc	ra,0xffffe
    80002380:	1b2080e7          	jalr	434(ra) # 8000052e <panic>
    panic("sched locks");
    80002384:	00007517          	auipc	a0,0x7
    80002388:	ee450513          	addi	a0,a0,-284 # 80009268 <digits+0x228>
    8000238c:	ffffe097          	auipc	ra,0xffffe
    80002390:	1a2080e7          	jalr	418(ra) # 8000052e <panic>
    printf("sched%d\n",p->pid);
    80002394:	02492583          	lw	a1,36(s2)
    80002398:	00007517          	auipc	a0,0x7
    8000239c:	ee050513          	addi	a0,a0,-288 # 80009278 <digits+0x238>
    800023a0:	ffffe097          	auipc	ra,0xffffe
    800023a4:	1d8080e7          	jalr	472(ra) # 80000578 <printf>
    panic("sched running");
    800023a8:	00007517          	auipc	a0,0x7
    800023ac:	ee050513          	addi	a0,a0,-288 # 80009288 <digits+0x248>
    800023b0:	ffffe097          	auipc	ra,0xffffe
    800023b4:	17e080e7          	jalr	382(ra) # 8000052e <panic>
    panic("sched interruptible");
    800023b8:	00007517          	auipc	a0,0x7
    800023bc:	ee050513          	addi	a0,a0,-288 # 80009298 <digits+0x258>
    800023c0:	ffffe097          	auipc	ra,0xffffe
    800023c4:	16e080e7          	jalr	366(ra) # 8000052e <panic>

00000000800023c8 <yield>:
{
    800023c8:	1101                	addi	sp,sp,-32
    800023ca:	ec06                	sd	ra,24(sp)
    800023cc:	e822                	sd	s0,16(sp)
    800023ce:	e426                	sd	s1,8(sp)
    800023d0:	1000                	addi	s0,sp,32
  struct kthread *t =mykthread();
    800023d2:	fffff097          	auipc	ra,0xfffff
    800023d6:	6ea080e7          	jalr	1770(ra) # 80001abc <mykthread>
    800023da:	84aa                	mv	s1,a0
  acquire(&t->lock);
    800023dc:	ffffe097          	auipc	ra,0xffffe
    800023e0:	7ea080e7          	jalr	2026(ra) # 80000bc6 <acquire>
  t->state = TRUNNABLE;
    800023e4:	478d                	li	a5,3
    800023e6:	cc9c                	sw	a5,24(s1)
  sched();
    800023e8:	00000097          	auipc	ra,0x0
    800023ec:	ecc080e7          	jalr	-308(ra) # 800022b4 <sched>
  release(&t->lock);
    800023f0:	8526                	mv	a0,s1
    800023f2:	fffff097          	auipc	ra,0xfffff
    800023f6:	8aa080e7          	jalr	-1878(ra) # 80000c9c <release>
}
    800023fa:	60e2                	ld	ra,24(sp)
    800023fc:	6442                	ld	s0,16(sp)
    800023fe:	64a2                	ld	s1,8(sp)
    80002400:	6105                	addi	sp,sp,32
    80002402:	8082                	ret

0000000080002404 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002404:	7179                	addi	sp,sp,-48
    80002406:	f406                	sd	ra,40(sp)
    80002408:	f022                	sd	s0,32(sp)
    8000240a:	ec26                	sd	s1,24(sp)
    8000240c:	e84a                	sd	s2,16(sp)
    8000240e:	e44e                	sd	s3,8(sp)
    80002410:	e052                	sd	s4,0(sp)
    80002412:	1800                	addi	s0,sp,48
    80002414:	8a2a                	mv	s4,a0
    80002416:	892e                	mv	s2,a1
  // struct proc *p = myproc();
  struct kthread *t=mykthread();
    80002418:	fffff097          	auipc	ra,0xfffff
    8000241c:	6a4080e7          	jalr	1700(ra) # 80001abc <mykthread>
    80002420:	84aa                	mv	s1,a0
  struct proc *p=myproc();
    80002422:	fffff097          	auipc	ra,0xfffff
    80002426:	65a080e7          	jalr	1626(ra) # 80001a7c <myproc>
    8000242a:	89aa                	mv	s3,a0
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.
  acquire(&t->lock);  //DOC: sleeplock1
    8000242c:	8526                	mv	a0,s1
    8000242e:	ffffe097          	auipc	ra,0xffffe
    80002432:	798080e7          	jalr	1944(ra) # 80000bc6 <acquire>
  release(lk);
    80002436:	854a                	mv	a0,s2
    80002438:	fffff097          	auipc	ra,0xfffff
    8000243c:	864080e7          	jalr	-1948(ra) # 80000c9c <release>
  printf("sl-s%d\n",p->pid);//TODO delete
    80002440:	0249a583          	lw	a1,36(s3)
    80002444:	00007517          	auipc	a0,0x7
    80002448:	e6c50513          	addi	a0,a0,-404 # 800092b0 <digits+0x270>
    8000244c:	ffffe097          	auipc	ra,0xffffe
    80002450:	12c080e7          	jalr	300(ra) # 80000578 <printf>
  // Go to sleep.
  t->chan = chan;
    80002454:	0344b023          	sd	s4,32(s1)
  t->state = TSLEEPING;
    80002458:	4789                	li	a5,2
    8000245a:	cc9c                	sw	a5,24(s1)

  sched();
    8000245c:	00000097          	auipc	ra,0x0
    80002460:	e58080e7          	jalr	-424(ra) # 800022b4 <sched>

  // Tidy up.
  t->chan = 0;
    80002464:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&t->lock);
    80002468:	8526                	mv	a0,s1
    8000246a:	fffff097          	auipc	ra,0xfffff
    8000246e:	832080e7          	jalr	-1998(ra) # 80000c9c <release>
  printf("sl-e%d\n",p->pid);//TODO delete
    80002472:	0249a583          	lw	a1,36(s3)
    80002476:	00007517          	auipc	a0,0x7
    8000247a:	e4250513          	addi	a0,a0,-446 # 800092b8 <digits+0x278>
    8000247e:	ffffe097          	auipc	ra,0xffffe
    80002482:	0fa080e7          	jalr	250(ra) # 80000578 <printf>
  acquire(lk);
    80002486:	854a                	mv	a0,s2
    80002488:	ffffe097          	auipc	ra,0xffffe
    8000248c:	73e080e7          	jalr	1854(ra) # 80000bc6 <acquire>
}
    80002490:	70a2                	ld	ra,40(sp)
    80002492:	7402                	ld	s0,32(sp)
    80002494:	64e2                	ld	s1,24(sp)
    80002496:	6942                	ld	s2,16(sp)
    80002498:	69a2                	ld	s3,8(sp)
    8000249a:	6a02                	ld	s4,0(sp)
    8000249c:	6145                	addi	sp,sp,48
    8000249e:	8082                	ret

00000000800024a0 <wait>:
{
    800024a0:	715d                	addi	sp,sp,-80
    800024a2:	e486                	sd	ra,72(sp)
    800024a4:	e0a2                	sd	s0,64(sp)
    800024a6:	fc26                	sd	s1,56(sp)
    800024a8:	f84a                	sd	s2,48(sp)
    800024aa:	f44e                	sd	s3,40(sp)
    800024ac:	f052                	sd	s4,32(sp)
    800024ae:	ec56                	sd	s5,24(sp)
    800024b0:	e85a                	sd	s6,16(sp)
    800024b2:	e45e                	sd	s7,8(sp)
    800024b4:	0880                	addi	s0,sp,80
    800024b6:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800024b8:	fffff097          	auipc	ra,0xfffff
    800024bc:	5c4080e7          	jalr	1476(ra) # 80001a7c <myproc>
    800024c0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024c2:	00010517          	auipc	a0,0x10
    800024c6:	e0e50513          	addi	a0,a0,-498 # 800122d0 <wait_lock>
    800024ca:	ffffe097          	auipc	ra,0xffffe
    800024ce:	6fc080e7          	jalr	1788(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    800024d2:	4b0d                	li	s6,3
        havekids = 1;
    800024d4:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800024d6:	6985                	lui	s3,0x1
    800024d8:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    800024dc:	00031a17          	auipc	s4,0x31
    800024e0:	44ca0a13          	addi	s4,s4,1100 # 80033928 <tickslock>
    havekids = 0;
    800024e4:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    800024e6:	00010497          	auipc	s1,0x10
    800024ea:	24248493          	addi	s1,s1,578 # 80012728 <proc>
    800024ee:	a0b5                	j	8000255a <wait+0xba>
          pid = np->pid;
    800024f0:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800024f4:	000b8e63          	beqz	s7,80002510 <wait+0x70>
    800024f8:	4691                	li	a3,4
    800024fa:	02048613          	addi	a2,s1,32
    800024fe:	85de                	mv	a1,s7
    80002500:	04093503          	ld	a0,64(s2)
    80002504:	fffff097          	auipc	ra,0xfffff
    80002508:	160080e7          	jalr	352(ra) # 80001664 <copyout>
    8000250c:	02054563          	bltz	a0,80002536 <wait+0x96>
          freeproc(np);
    80002510:	8526                	mv	a0,s1
    80002512:	00000097          	auipc	ra,0x0
    80002516:	80e080e7          	jalr	-2034(ra) # 80001d20 <freeproc>
          release(&np->lock);
    8000251a:	8526                	mv	a0,s1
    8000251c:	ffffe097          	auipc	ra,0xffffe
    80002520:	780080e7          	jalr	1920(ra) # 80000c9c <release>
          release(&wait_lock);
    80002524:	00010517          	auipc	a0,0x10
    80002528:	dac50513          	addi	a0,a0,-596 # 800122d0 <wait_lock>
    8000252c:	ffffe097          	auipc	ra,0xffffe
    80002530:	770080e7          	jalr	1904(ra) # 80000c9c <release>
          return pid;
    80002534:	a09d                	j	8000259a <wait+0xfa>
            release(&np->lock);
    80002536:	8526                	mv	a0,s1
    80002538:	ffffe097          	auipc	ra,0xffffe
    8000253c:	764080e7          	jalr	1892(ra) # 80000c9c <release>
            release(&wait_lock);
    80002540:	00010517          	auipc	a0,0x10
    80002544:	d9050513          	addi	a0,a0,-624 # 800122d0 <wait_lock>
    80002548:	ffffe097          	auipc	ra,0xffffe
    8000254c:	754080e7          	jalr	1876(ra) # 80000c9c <release>
            return -1;
    80002550:	59fd                	li	s3,-1
    80002552:	a0a1                	j	8000259a <wait+0xfa>
    for(np = proc; np < &proc[NPROC]; np++){
    80002554:	94ce                	add	s1,s1,s3
    80002556:	03448463          	beq	s1,s4,8000257e <wait+0xde>
      if(np->parent == p){
    8000255a:	789c                	ld	a5,48(s1)
    8000255c:	ff279ce3          	bne	a5,s2,80002554 <wait+0xb4>
        acquire(&np->lock);
    80002560:	8526                	mv	a0,s1
    80002562:	ffffe097          	auipc	ra,0xffffe
    80002566:	664080e7          	jalr	1636(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    8000256a:	4c9c                	lw	a5,24(s1)
    8000256c:	f96782e3          	beq	a5,s6,800024f0 <wait+0x50>
        release(&np->lock);
    80002570:	8526                	mv	a0,s1
    80002572:	ffffe097          	auipc	ra,0xffffe
    80002576:	72a080e7          	jalr	1834(ra) # 80000c9c <release>
        havekids = 1;
    8000257a:	8756                	mv	a4,s5
    8000257c:	bfe1                	j	80002554 <wait+0xb4>
    if(!havekids || p->killed==1){
    8000257e:	c709                	beqz	a4,80002588 <wait+0xe8>
    80002580:	01c92783          	lw	a5,28(s2)
    80002584:	03579763          	bne	a5,s5,800025b2 <wait+0x112>
      release(&wait_lock);
    80002588:	00010517          	auipc	a0,0x10
    8000258c:	d4850513          	addi	a0,a0,-696 # 800122d0 <wait_lock>
    80002590:	ffffe097          	auipc	ra,0xffffe
    80002594:	70c080e7          	jalr	1804(ra) # 80000c9c <release>
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
    800025ae:	6161                	addi	sp,sp,80
    800025b0:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025b2:	00010597          	auipc	a1,0x10
    800025b6:	d1e58593          	addi	a1,a1,-738 # 800122d0 <wait_lock>
    800025ba:	854a                	mv	a0,s2
    800025bc:	00000097          	auipc	ra,0x0
    800025c0:	e48080e7          	jalr	-440(ra) # 80002404 <sleep>
    havekids = 0;
    800025c4:	b705                	j	800024e4 <wait+0x44>

00000000800025c6 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800025c6:	711d                	addi	sp,sp,-96
    800025c8:	ec86                	sd	ra,88(sp)
    800025ca:	e8a2                	sd	s0,80(sp)
    800025cc:	e4a6                	sd	s1,72(sp)
    800025ce:	e0ca                	sd	s2,64(sp)
    800025d0:	fc4e                	sd	s3,56(sp)
    800025d2:	f852                	sd	s4,48(sp)
    800025d4:	f456                	sd	s5,40(sp)
    800025d6:	f05a                	sd	s6,32(sp)
    800025d8:	ec5e                	sd	s7,24(sp)
    800025da:	e862                	sd	s8,16(sp)
    800025dc:	e466                	sd	s9,8(sp)
    800025de:	1080                	addi	s0,sp,96
    800025e0:	8c2a                	mv	s8,a0
  struct proc *p;
  struct kthread *t;
  struct kthread *my_t = mykthread();
    800025e2:	fffff097          	auipc	ra,0xfffff
    800025e6:	4da080e7          	jalr	1242(ra) # 80001abc <mykthread>
    800025ea:	8aaa                	mv	s5,a0

  for(p = proc; p < &proc[NPROC]; p++) {
    800025ec:	00010917          	auipc	s2,0x10
    800025f0:	3c490913          	addi	s2,s2,964 # 800129b0 <proc+0x288>
    800025f4:	00031b97          	auipc	s7,0x31
    800025f8:	5bcb8b93          	addi	s7,s7,1468 # 80033bb0 <bcache+0x270>
    if(p->state == RUNNABLE){
    800025fc:	4989                	li	s3,2
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
        if(t != my_t){
          acquire(&t->lock);
          if(t->state == TSLEEPING && t->chan == chan) {
            t->state = TRUNNABLE;
    800025fe:	4c8d                	li	s9,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002600:	6b05                	lui	s6,0x1
    80002602:	848b0b13          	addi	s6,s6,-1976 # 848 <_entry-0x7ffff7b8>
    80002606:	a82d                	j	80002640 <wakeup+0x7a>
          }
          release(&t->lock);
    80002608:	8526                	mv	a0,s1
    8000260a:	ffffe097          	auipc	ra,0xffffe
    8000260e:	692080e7          	jalr	1682(ra) # 80000c9c <release>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    80002612:	0b848493          	addi	s1,s1,184
    80002616:	03448263          	beq	s1,s4,8000263a <wakeup+0x74>
        if(t != my_t){
    8000261a:	fe9a8ce3          	beq	s5,s1,80002612 <wakeup+0x4c>
          acquire(&t->lock);
    8000261e:	8526                	mv	a0,s1
    80002620:	ffffe097          	auipc	ra,0xffffe
    80002624:	5a6080e7          	jalr	1446(ra) # 80000bc6 <acquire>
          if(t->state == TSLEEPING && t->chan == chan) {
    80002628:	4c9c                	lw	a5,24(s1)
    8000262a:	fd379fe3          	bne	a5,s3,80002608 <wakeup+0x42>
    8000262e:	709c                	ld	a5,32(s1)
    80002630:	fd879ce3          	bne	a5,s8,80002608 <wakeup+0x42>
            t->state = TRUNNABLE;
    80002634:	0194ac23          	sw	s9,24(s1)
    80002638:	bfc1                	j	80002608 <wakeup+0x42>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000263a:	995a                	add	s2,s2,s6
    8000263c:	01790a63          	beq	s2,s7,80002650 <wakeup+0x8a>
    if(p->state == RUNNABLE){
    80002640:	84ca                	mv	s1,s2
    80002642:	d9092783          	lw	a5,-624(s2)
    80002646:	ff379ae3          	bne	a5,s3,8000263a <wakeup+0x74>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    8000264a:	5c090a13          	addi	s4,s2,1472
    8000264e:	b7f1                	j	8000261a <wakeup+0x54>
        }
      }
    }
  }
}
    80002650:	60e6                	ld	ra,88(sp)
    80002652:	6446                	ld	s0,80(sp)
    80002654:	64a6                	ld	s1,72(sp)
    80002656:	6906                	ld	s2,64(sp)
    80002658:	79e2                	ld	s3,56(sp)
    8000265a:	7a42                	ld	s4,48(sp)
    8000265c:	7aa2                	ld	s5,40(sp)
    8000265e:	7b02                	ld	s6,32(sp)
    80002660:	6be2                	ld	s7,24(sp)
    80002662:	6c42                	ld	s8,16(sp)
    80002664:	6ca2                	ld	s9,8(sp)
    80002666:	6125                	addi	sp,sp,96
    80002668:	8082                	ret

000000008000266a <reparent>:
{
    8000266a:	7139                	addi	sp,sp,-64
    8000266c:	fc06                	sd	ra,56(sp)
    8000266e:	f822                	sd	s0,48(sp)
    80002670:	f426                	sd	s1,40(sp)
    80002672:	f04a                	sd	s2,32(sp)
    80002674:	ec4e                	sd	s3,24(sp)
    80002676:	e852                	sd	s4,16(sp)
    80002678:	e456                	sd	s5,8(sp)
    8000267a:	0080                	addi	s0,sp,64
    8000267c:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000267e:	00010497          	auipc	s1,0x10
    80002682:	0aa48493          	addi	s1,s1,170 # 80012728 <proc>
      pp->parent = initproc;
    80002686:	00008a97          	auipc	s5,0x8
    8000268a:	9a2a8a93          	addi	s5,s5,-1630 # 8000a028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000268e:	6905                	lui	s2,0x1
    80002690:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002694:	00031a17          	auipc	s4,0x31
    80002698:	294a0a13          	addi	s4,s4,660 # 80033928 <tickslock>
    8000269c:	a021                	j	800026a4 <reparent+0x3a>
    8000269e:	94ca                	add	s1,s1,s2
    800026a0:	01448d63          	beq	s1,s4,800026ba <reparent+0x50>
    if(pp->parent == p){
    800026a4:	789c                	ld	a5,48(s1)
    800026a6:	ff379ce3          	bne	a5,s3,8000269e <reparent+0x34>
      pp->parent = initproc;
    800026aa:	000ab503          	ld	a0,0(s5)
    800026ae:	f888                	sd	a0,48(s1)
      wakeup(initproc);
    800026b0:	00000097          	auipc	ra,0x0
    800026b4:	f16080e7          	jalr	-234(ra) # 800025c6 <wakeup>
    800026b8:	b7dd                	j	8000269e <reparent+0x34>
}
    800026ba:	70e2                	ld	ra,56(sp)
    800026bc:	7442                	ld	s0,48(sp)
    800026be:	74a2                	ld	s1,40(sp)
    800026c0:	7902                	ld	s2,32(sp)
    800026c2:	69e2                	ld	s3,24(sp)
    800026c4:	6a42                	ld	s4,16(sp)
    800026c6:	6aa2                	ld	s5,8(sp)
    800026c8:	6121                	addi	sp,sp,64
    800026ca:	8082                	ret

00000000800026cc <exit_proccess>:
{
    800026cc:	7139                	addi	sp,sp,-64
    800026ce:	fc06                	sd	ra,56(sp)
    800026d0:	f822                	sd	s0,48(sp)
    800026d2:	f426                	sd	s1,40(sp)
    800026d4:	f04a                	sd	s2,32(sp)
    800026d6:	ec4e                	sd	s3,24(sp)
    800026d8:	e852                	sd	s4,16(sp)
    800026da:	e456                	sd	s5,8(sp)
    800026dc:	0080                	addi	s0,sp,64
    800026de:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    800026e0:	fffff097          	auipc	ra,0xfffff
    800026e4:	39c080e7          	jalr	924(ra) # 80001a7c <myproc>
    800026e8:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    800026ea:	fffff097          	auipc	ra,0xfffff
    800026ee:	3d2080e7          	jalr	978(ra) # 80001abc <mykthread>
    800026f2:	8a2a                	mv	s4,a0
  printf("%d: at e_proc\n",p->pid);
    800026f4:	02492583          	lw	a1,36(s2)
    800026f8:	00007517          	auipc	a0,0x7
    800026fc:	bc850513          	addi	a0,a0,-1080 # 800092c0 <digits+0x280>
    80002700:	ffffe097          	auipc	ra,0xffffe
    80002704:	e78080e7          	jalr	-392(ra) # 80000578 <printf>
  if(p == initproc)
    80002708:	00008797          	auipc	a5,0x8
    8000270c:	9207b783          	ld	a5,-1760(a5) # 8000a028 <initproc>
    80002710:	05090493          	addi	s1,s2,80
    80002714:	0d090993          	addi	s3,s2,208
    80002718:	03279363          	bne	a5,s2,8000273e <exit_proccess+0x72>
    panic("init exiting");
    8000271c:	00007517          	auipc	a0,0x7
    80002720:	bb450513          	addi	a0,a0,-1100 # 800092d0 <digits+0x290>
    80002724:	ffffe097          	auipc	ra,0xffffe
    80002728:	e0a080e7          	jalr	-502(ra) # 8000052e <panic>
      fileclose(f);
    8000272c:	00003097          	auipc	ra,0x3
    80002730:	f8a080e7          	jalr	-118(ra) # 800056b6 <fileclose>
      p->ofile[fd] = 0;
    80002734:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002738:	04a1                	addi	s1,s1,8
    8000273a:	01348563          	beq	s1,s3,80002744 <exit_proccess+0x78>
    if(p->ofile[fd]){
    8000273e:	6088                	ld	a0,0(s1)
    80002740:	f575                	bnez	a0,8000272c <exit_proccess+0x60>
    80002742:	bfdd                	j	80002738 <exit_proccess+0x6c>
  begin_op();
    80002744:	00003097          	auipc	ra,0x3
    80002748:	aa6080e7          	jalr	-1370(ra) # 800051ea <begin_op>
  iput(p->cwd);
    8000274c:	0d093503          	ld	a0,208(s2)
    80002750:	00002097          	auipc	ra,0x2
    80002754:	280080e7          	jalr	640(ra) # 800049d0 <iput>
  end_op();
    80002758:	00003097          	auipc	ra,0x3
    8000275c:	b12080e7          	jalr	-1262(ra) # 8000526a <end_op>
  p->cwd = 0;
    80002760:	0c093823          	sd	zero,208(s2)
  printf("ep-b%d\n",p->pid);//TODO delete
    80002764:	02492583          	lw	a1,36(s2)
    80002768:	00007517          	auipc	a0,0x7
    8000276c:	b7850513          	addi	a0,a0,-1160 # 800092e0 <digits+0x2a0>
    80002770:	ffffe097          	auipc	ra,0xffffe
    80002774:	e08080e7          	jalr	-504(ra) # 80000578 <printf>
  acquire(&wait_lock);
    80002778:	00010497          	auipc	s1,0x10
    8000277c:	b5848493          	addi	s1,s1,-1192 # 800122d0 <wait_lock>
    80002780:	8526                	mv	a0,s1
    80002782:	ffffe097          	auipc	ra,0xffffe
    80002786:	444080e7          	jalr	1092(ra) # 80000bc6 <acquire>
  printf("ep-a%d\n",p->pid);//TODO delete
    8000278a:	02492583          	lw	a1,36(s2)
    8000278e:	00007517          	auipc	a0,0x7
    80002792:	b5a50513          	addi	a0,a0,-1190 # 800092e8 <digits+0x2a8>
    80002796:	ffffe097          	auipc	ra,0xffffe
    8000279a:	de2080e7          	jalr	-542(ra) # 80000578 <printf>
  reparent(p);
    8000279e:	854a                	mv	a0,s2
    800027a0:	00000097          	auipc	ra,0x0
    800027a4:	eca080e7          	jalr	-310(ra) # 8000266a <reparent>
  wakeup(p->parent);
    800027a8:	03093503          	ld	a0,48(s2)
    800027ac:	00000097          	auipc	ra,0x0
    800027b0:	e1a080e7          	jalr	-486(ra) # 800025c6 <wakeup>
  acquire(&p->lock);
    800027b4:	854a                	mv	a0,s2
    800027b6:	ffffe097          	auipc	ra,0xffffe
    800027ba:	410080e7          	jalr	1040(ra) # 80000bc6 <acquire>
  p->xstate = status;
    800027be:	03592023          	sw	s5,32(s2)
  p->state = ZOMBIE;
    800027c2:	478d                	li	a5,3
    800027c4:	00f92c23          	sw	a5,24(s2)
  release(&p->lock);// we added
    800027c8:	854a                	mv	a0,s2
    800027ca:	ffffe097          	auipc	ra,0xffffe
    800027ce:	4d2080e7          	jalr	1234(ra) # 80000c9c <release>
  release(&wait_lock);
    800027d2:	8526                	mv	a0,s1
    800027d4:	ffffe097          	auipc	ra,0xffffe
    800027d8:	4c8080e7          	jalr	1224(ra) # 80000c9c <release>
  acquire(&t->lock);
    800027dc:	8552                	mv	a0,s4
    800027de:	ffffe097          	auipc	ra,0xffffe
    800027e2:	3e8080e7          	jalr	1000(ra) # 80000bc6 <acquire>
  sched();
    800027e6:	00000097          	auipc	ra,0x0
    800027ea:	ace080e7          	jalr	-1330(ra) # 800022b4 <sched>
  printf("zombie exit %d\n",p->pid);
    800027ee:	02492583          	lw	a1,36(s2)
    800027f2:	00007517          	auipc	a0,0x7
    800027f6:	afe50513          	addi	a0,a0,-1282 # 800092f0 <digits+0x2b0>
    800027fa:	ffffe097          	auipc	ra,0xffffe
    800027fe:	d7e080e7          	jalr	-642(ra) # 80000578 <printf>
  panic("zombie exit");
    80002802:	00007517          	auipc	a0,0x7
    80002806:	afe50513          	addi	a0,a0,-1282 # 80009300 <digits+0x2c0>
    8000280a:	ffffe097          	auipc	ra,0xffffe
    8000280e:	d24080e7          	jalr	-732(ra) # 8000052e <panic>

0000000080002812 <kthread_exit>:
kthread_exit(int status){
    80002812:	7179                	addi	sp,sp,-48
    80002814:	f406                	sd	ra,40(sp)
    80002816:	f022                	sd	s0,32(sp)
    80002818:	ec26                	sd	s1,24(sp)
    8000281a:	e84a                	sd	s2,16(sp)
    8000281c:	e44e                	sd	s3,8(sp)
    8000281e:	e052                	sd	s4,0(sp)
    80002820:	1800                	addi	s0,sp,48
    80002822:	89aa                	mv	s3,a0
  struct proc *p = myproc(); 
    80002824:	fffff097          	auipc	ra,0xfffff
    80002828:	258080e7          	jalr	600(ra) # 80001a7c <myproc>
    8000282c:	84aa                	mv	s1,a0
  struct kthread *t=mykthread();
    8000282e:	fffff097          	auipc	ra,0xfffff
    80002832:	28e080e7          	jalr	654(ra) # 80001abc <mykthread>
    80002836:	892a                	mv	s2,a0
  printf("kte-a%d\n",p->pid);//TODO delete
    80002838:	50cc                	lw	a1,36(s1)
    8000283a:	00007517          	auipc	a0,0x7
    8000283e:	ad650513          	addi	a0,a0,-1322 # 80009310 <digits+0x2d0>
    80002842:	ffffe097          	auipc	ra,0xffffe
    80002846:	d36080e7          	jalr	-714(ra) # 80000578 <printf>
  acquire(&p->lock);
    8000284a:	8526                	mv	a0,s1
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	37a080e7          	jalr	890(ra) # 80000bc6 <acquire>
  p->active_threads--;
    80002854:	549c                	lw	a5,40(s1)
    80002856:	37fd                	addiw	a5,a5,-1
    80002858:	00078a1b          	sext.w	s4,a5
    8000285c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000285e:	8526                	mv	a0,s1
    80002860:	ffffe097          	auipc	ra,0xffffe
    80002864:	43c080e7          	jalr	1084(ra) # 80000c9c <release>
  printf("kte-b%d\n",p->pid);//TODO delete
    80002868:	50cc                	lw	a1,36(s1)
    8000286a:	00007517          	auipc	a0,0x7
    8000286e:	ab650513          	addi	a0,a0,-1354 # 80009320 <digits+0x2e0>
    80002872:	ffffe097          	auipc	ra,0xffffe
    80002876:	d06080e7          	jalr	-762(ra) # 80000578 <printf>
  acquire(&t->lock);
    8000287a:	854a                	mv	a0,s2
    8000287c:	ffffe097          	auipc	ra,0xffffe
    80002880:	34a080e7          	jalr	842(ra) # 80000bc6 <acquire>
  t->xstate = status;
    80002884:	03392623          	sw	s3,44(s2)
  t->state  = TUNUSED;
    80002888:	00092c23          	sw	zero,24(s2)
    printf("kte-c%d\n",p->pid);//TODO delete
    8000288c:	50cc                	lw	a1,36(s1)
    8000288e:	00007517          	auipc	a0,0x7
    80002892:	aa250513          	addi	a0,a0,-1374 # 80009330 <digits+0x2f0>
    80002896:	ffffe097          	auipc	ra,0xffffe
    8000289a:	ce2080e7          	jalr	-798(ra) # 80000578 <printf>
  release(&t->lock);////////////////////////////////////////////////////////check
    8000289e:	854a                	mv	a0,s2
    800028a0:	ffffe097          	auipc	ra,0xffffe
    800028a4:	3fc080e7          	jalr	1020(ra) # 80000c9c <release>
  wakeup(t);
    800028a8:	854a                	mv	a0,s2
    800028aa:	00000097          	auipc	ra,0x0
    800028ae:	d1c080e7          	jalr	-740(ra) # 800025c6 <wakeup>
  printf("kte-d%d\n",p->pid);//TODO delete
    800028b2:	50cc                	lw	a1,36(s1)
    800028b4:	00007517          	auipc	a0,0x7
    800028b8:	a8c50513          	addi	a0,a0,-1396 # 80009340 <digits+0x300>
    800028bc:	ffffe097          	auipc	ra,0xffffe
    800028c0:	cbc080e7          	jalr	-836(ra) # 80000578 <printf>
  if(curr_active_threads==0){
    800028c4:	020a1063          	bnez	s4,800028e4 <kthread_exit+0xd2>
      printf("%d: at kt exit 0t\n",p->pid);
    800028c8:	50cc                	lw	a1,36(s1)
    800028ca:	00007517          	auipc	a0,0x7
    800028ce:	a8650513          	addi	a0,a0,-1402 # 80009350 <digits+0x310>
    800028d2:	ffffe097          	auipc	ra,0xffffe
    800028d6:	ca6080e7          	jalr	-858(ra) # 80000578 <printf>
    exit_proccess(status);
    800028da:	854e                	mv	a0,s3
    800028dc:	00000097          	auipc	ra,0x0
    800028e0:	df0080e7          	jalr	-528(ra) # 800026cc <exit_proccess>
    acquire(&t->lock);////////////////////////////////////////////////////////check
    800028e4:	854a                	mv	a0,s2
    800028e6:	ffffe097          	auipc	ra,0xffffe
    800028ea:	2e0080e7          	jalr	736(ra) # 80000bc6 <acquire>
    printf("kte-er%d\n",p->pid);//TODO delete
    800028ee:	50cc                	lw	a1,36(s1)
    800028f0:	00007517          	auipc	a0,0x7
    800028f4:	a7850513          	addi	a0,a0,-1416 # 80009368 <digits+0x328>
    800028f8:	ffffe097          	auipc	ra,0xffffe
    800028fc:	c80080e7          	jalr	-896(ra) # 80000578 <printf>
    sched();
    80002900:	00000097          	auipc	ra,0x0
    80002904:	9b4080e7          	jalr	-1612(ra) # 800022b4 <sched>
    panic("zombie thread exit");
    80002908:	00007517          	auipc	a0,0x7
    8000290c:	a7050513          	addi	a0,a0,-1424 # 80009378 <digits+0x338>
    80002910:	ffffe097          	auipc	ra,0xffffe
    80002914:	c1e080e7          	jalr	-994(ra) # 8000052e <panic>

0000000080002918 <exit>:
exit(int status){
    80002918:	7139                	addi	sp,sp,-64
    8000291a:	fc06                	sd	ra,56(sp)
    8000291c:	f822                	sd	s0,48(sp)
    8000291e:	f426                	sd	s1,40(sp)
    80002920:	f04a                	sd	s2,32(sp)
    80002922:	ec4e                	sd	s3,24(sp)
    80002924:	e852                	sd	s4,16(sp)
    80002926:	e456                	sd	s5,8(sp)
    80002928:	e05a                	sd	s6,0(sp)
    8000292a:	0080                	addi	s0,sp,64
    8000292c:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    8000292e:	fffff097          	auipc	ra,0xfffff
    80002932:	14e080e7          	jalr	334(ra) # 80001a7c <myproc>
    80002936:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80002938:	fffff097          	auipc	ra,0xfffff
    8000293c:	184080e7          	jalr	388(ra) # 80001abc <mykthread>
  printf("e%d\n",p->pid);//TODO delete
    80002940:	02492583          	lw	a1,36(s2)
    80002944:	00007517          	auipc	a0,0x7
    80002948:	a4c50513          	addi	a0,a0,-1460 # 80009390 <digits+0x350>
    8000294c:	ffffe097          	auipc	ra,0xffffe
    80002950:	c2c080e7          	jalr	-980(ra) # 80000578 <printf>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002954:	28890493          	addi	s1,s2,648
    80002958:	6505                	lui	a0,0x1
    8000295a:	84850513          	addi	a0,a0,-1976 # 848 <_entry-0x7ffff7b8>
    8000295e:	992a                	add	s2,s2,a0
    t->killed = 1;
    80002960:	4a05                	li	s4,1
    if(t->state == TSLEEPING)
    80002962:	4989                	li	s3,2
      t->state = TRUNNABLE;
    80002964:	4b0d                	li	s6,3
    80002966:	a811                	j	8000297a <exit+0x62>
    release(&t->lock);
    80002968:	8526                	mv	a0,s1
    8000296a:	ffffe097          	auipc	ra,0xffffe
    8000296e:	332080e7          	jalr	818(ra) # 80000c9c <release>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002972:	0b848493          	addi	s1,s1,184
    80002976:	00990f63          	beq	s2,s1,80002994 <exit+0x7c>
    acquire(&t->lock);
    8000297a:	8526                	mv	a0,s1
    8000297c:	ffffe097          	auipc	ra,0xffffe
    80002980:	24a080e7          	jalr	586(ra) # 80000bc6 <acquire>
    t->killed = 1;
    80002984:	0344a423          	sw	s4,40(s1)
    if(t->state == TSLEEPING)
    80002988:	4c9c                	lw	a5,24(s1)
    8000298a:	fd379fe3          	bne	a5,s3,80002968 <exit+0x50>
      t->state = TRUNNABLE;
    8000298e:	0164ac23          	sw	s6,24(s1)
    80002992:	bfd9                	j	80002968 <exit+0x50>
  kthread_exit(status);
    80002994:	8556                	mv	a0,s5
    80002996:	00000097          	auipc	ra,0x0
    8000299a:	e7c080e7          	jalr	-388(ra) # 80002812 <kthread_exit>

000000008000299e <sig_stop>:
//   return -1;
// }

int
sig_stop(int pid)//TODO delete if not used
{
    8000299e:	7179                	addi	sp,sp,-48
    800029a0:	f406                	sd	ra,40(sp)
    800029a2:	f022                	sd	s0,32(sp)
    800029a4:	ec26                	sd	s1,24(sp)
    800029a6:	e84a                	sd	s2,16(sp)
    800029a8:	e44e                	sd	s3,8(sp)
    800029aa:	e052                	sd	s4,0(sp)
    800029ac:	1800                	addi	s0,sp,48
    800029ae:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800029b0:	00010497          	auipc	s1,0x10
    800029b4:	d7848493          	addi	s1,s1,-648 # 80012728 <proc>
    800029b8:	6985                	lui	s3,0x1
    800029ba:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    800029be:	00031a17          	auipc	s4,0x31
    800029c2:	f6aa0a13          	addi	s4,s4,-150 # 80033928 <tickslock>
    acquire(&p->lock);
    800029c6:	8526                	mv	a0,s1
    800029c8:	ffffe097          	auipc	ra,0xffffe
    800029cc:	1fe080e7          	jalr	510(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    800029d0:	50dc                	lw	a5,36(s1)
    800029d2:	01278c63          	beq	a5,s2,800029ea <sig_stop+0x4c>
      p->pending_signals|=(1<<SIGSTOP);

      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800029d6:	8526                	mv	a0,s1
    800029d8:	ffffe097          	auipc	ra,0xffffe
    800029dc:	2c4080e7          	jalr	708(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800029e0:	94ce                	add	s1,s1,s3
    800029e2:	ff4492e3          	bne	s1,s4,800029c6 <sig_stop+0x28>
  }
  return -1;
    800029e6:	557d                	li	a0,-1
    800029e8:	a831                	j	80002a04 <sig_stop+0x66>
      p->pending_signals|=(1<<SIGSTOP);
    800029ea:	0e84a783          	lw	a5,232(s1)
    800029ee:	00020737          	lui	a4,0x20
    800029f2:	8fd9                	or	a5,a5,a4
    800029f4:	0ef4a423          	sw	a5,232(s1)
      release(&p->lock);
    800029f8:	8526                	mv	a0,s1
    800029fa:	ffffe097          	auipc	ra,0xffffe
    800029fe:	2a2080e7          	jalr	674(ra) # 80000c9c <release>
      return 0;
    80002a02:	4501                	li	a0,0
}
    80002a04:	70a2                	ld	ra,40(sp)
    80002a06:	7402                	ld	s0,32(sp)
    80002a08:	64e2                	ld	s1,24(sp)
    80002a0a:	6942                	ld	s2,16(sp)
    80002a0c:	69a2                	ld	s3,8(sp)
    80002a0e:	6a02                	ld	s4,0(sp)
    80002a10:	6145                	addi	sp,sp,48
    80002a12:	8082                	ret

0000000080002a14 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002a14:	7179                	addi	sp,sp,-48
    80002a16:	f406                	sd	ra,40(sp)
    80002a18:	f022                	sd	s0,32(sp)
    80002a1a:	ec26                	sd	s1,24(sp)
    80002a1c:	e84a                	sd	s2,16(sp)
    80002a1e:	e44e                	sd	s3,8(sp)
    80002a20:	e052                	sd	s4,0(sp)
    80002a22:	1800                	addi	s0,sp,48
    80002a24:	84aa                	mv	s1,a0
    80002a26:	892e                	mv	s2,a1
    80002a28:	89b2                	mv	s3,a2
    80002a2a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a2c:	fffff097          	auipc	ra,0xfffff
    80002a30:	050080e7          	jalr	80(ra) # 80001a7c <myproc>
  if(user_dst){
    80002a34:	c08d                	beqz	s1,80002a56 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002a36:	86d2                	mv	a3,s4
    80002a38:	864e                	mv	a2,s3
    80002a3a:	85ca                	mv	a1,s2
    80002a3c:	6128                	ld	a0,64(a0)
    80002a3e:	fffff097          	auipc	ra,0xfffff
    80002a42:	c26080e7          	jalr	-986(ra) # 80001664 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002a46:	70a2                	ld	ra,40(sp)
    80002a48:	7402                	ld	s0,32(sp)
    80002a4a:	64e2                	ld	s1,24(sp)
    80002a4c:	6942                	ld	s2,16(sp)
    80002a4e:	69a2                	ld	s3,8(sp)
    80002a50:	6a02                	ld	s4,0(sp)
    80002a52:	6145                	addi	sp,sp,48
    80002a54:	8082                	ret
    memmove((char *)dst, src, len);
    80002a56:	000a061b          	sext.w	a2,s4
    80002a5a:	85ce                	mv	a1,s3
    80002a5c:	854a                	mv	a0,s2
    80002a5e:	ffffe097          	auipc	ra,0xffffe
    80002a62:	2e2080e7          	jalr	738(ra) # 80000d40 <memmove>
    return 0;
    80002a66:	8526                	mv	a0,s1
    80002a68:	bff9                	j	80002a46 <either_copyout+0x32>

0000000080002a6a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002a6a:	7179                	addi	sp,sp,-48
    80002a6c:	f406                	sd	ra,40(sp)
    80002a6e:	f022                	sd	s0,32(sp)
    80002a70:	ec26                	sd	s1,24(sp)
    80002a72:	e84a                	sd	s2,16(sp)
    80002a74:	e44e                	sd	s3,8(sp)
    80002a76:	e052                	sd	s4,0(sp)
    80002a78:	1800                	addi	s0,sp,48
    80002a7a:	892a                	mv	s2,a0
    80002a7c:	84ae                	mv	s1,a1
    80002a7e:	89b2                	mv	s3,a2
    80002a80:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a82:	fffff097          	auipc	ra,0xfffff
    80002a86:	ffa080e7          	jalr	-6(ra) # 80001a7c <myproc>
  if(user_src){
    80002a8a:	c08d                	beqz	s1,80002aac <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002a8c:	86d2                	mv	a3,s4
    80002a8e:	864e                	mv	a2,s3
    80002a90:	85ca                	mv	a1,s2
    80002a92:	6128                	ld	a0,64(a0)
    80002a94:	fffff097          	auipc	ra,0xfffff
    80002a98:	c5c080e7          	jalr	-932(ra) # 800016f0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002a9c:	70a2                	ld	ra,40(sp)
    80002a9e:	7402                	ld	s0,32(sp)
    80002aa0:	64e2                	ld	s1,24(sp)
    80002aa2:	6942                	ld	s2,16(sp)
    80002aa4:	69a2                	ld	s3,8(sp)
    80002aa6:	6a02                	ld	s4,0(sp)
    80002aa8:	6145                	addi	sp,sp,48
    80002aaa:	8082                	ret
    memmove(dst, (char*)src, len);
    80002aac:	000a061b          	sext.w	a2,s4
    80002ab0:	85ce                	mv	a1,s3
    80002ab2:	854a                	mv	a0,s2
    80002ab4:	ffffe097          	auipc	ra,0xffffe
    80002ab8:	28c080e7          	jalr	652(ra) # 80000d40 <memmove>
    return 0;
    80002abc:	8526                	mv	a0,s1
    80002abe:	bff9                	j	80002a9c <either_copyin+0x32>

0000000080002ac0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002ac0:	715d                	addi	sp,sp,-80
    80002ac2:	e486                	sd	ra,72(sp)
    80002ac4:	e0a2                	sd	s0,64(sp)
    80002ac6:	fc26                	sd	s1,56(sp)
    80002ac8:	f84a                	sd	s2,48(sp)
    80002aca:	f44e                	sd	s3,40(sp)
    80002acc:	f052                	sd	s4,32(sp)
    80002ace:	ec56                	sd	s5,24(sp)
    80002ad0:	e85a                	sd	s6,16(sp)
    80002ad2:	e45e                	sd	s7,8(sp)
    80002ad4:	e062                	sd	s8,0(sp)
    80002ad6:	0880                	addi	s0,sp,80


  struct proc *p;
  char *state;

  printf("\n");
    80002ad8:	00007517          	auipc	a0,0x7
    80002adc:	89850513          	addi	a0,a0,-1896 # 80009370 <digits+0x330>
    80002ae0:	ffffe097          	auipc	ra,0xffffe
    80002ae4:	a98080e7          	jalr	-1384(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002ae8:	00010497          	auipc	s1,0x10
    80002aec:	d1848493          	addi	s1,s1,-744 # 80012800 <proc+0xd8>
    80002af0:	00031997          	auipc	s3,0x31
    80002af4:	f1098993          	addi	s3,s3,-240 # 80033a00 <bcache+0xc0>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002af8:	4b8d                	li	s7,3
      state = states[p->state];
    else
      state = "???";
    80002afa:	00007a17          	auipc	s4,0x7
    80002afe:	89ea0a13          	addi	s4,s4,-1890 # 80009398 <digits+0x358>
    printf("%d %s %s", p->pid, state, p->name);
    80002b02:	00007b17          	auipc	s6,0x7
    80002b06:	89eb0b13          	addi	s6,s6,-1890 # 800093a0 <digits+0x360>
    printf("\n");
    80002b0a:	00007a97          	auipc	s5,0x7
    80002b0e:	866a8a93          	addi	s5,s5,-1946 # 80009370 <digits+0x330>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b12:	00007c17          	auipc	s8,0x7
    80002b16:	94ec0c13          	addi	s8,s8,-1714 # 80009460 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b1a:	6905                	lui	s2,0x1
    80002b1c:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002b20:	a005                	j	80002b40 <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    80002b22:	f4c6a583          	lw	a1,-180(a3)
    80002b26:	855a                	mv	a0,s6
    80002b28:	ffffe097          	auipc	ra,0xffffe
    80002b2c:	a50080e7          	jalr	-1456(ra) # 80000578 <printf>
    printf("\n");
    80002b30:	8556                	mv	a0,s5
    80002b32:	ffffe097          	auipc	ra,0xffffe
    80002b36:	a46080e7          	jalr	-1466(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b3a:	94ca                	add	s1,s1,s2
    80002b3c:	03348263          	beq	s1,s3,80002b60 <procdump+0xa0>
    if(p->state == UNUSED)
    80002b40:	86a6                	mv	a3,s1
    80002b42:	f404a783          	lw	a5,-192(s1)
    80002b46:	dbf5                	beqz	a5,80002b3a <procdump+0x7a>
      state = "???";
    80002b48:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b4a:	fcfbece3          	bltu	s7,a5,80002b22 <procdump+0x62>
    80002b4e:	02079713          	slli	a4,a5,0x20
    80002b52:	01d75793          	srli	a5,a4,0x1d
    80002b56:	97e2                	add	a5,a5,s8
    80002b58:	6390                	ld	a2,0(a5)
    80002b5a:	f661                	bnez	a2,80002b22 <procdump+0x62>
      state = "???";
    80002b5c:	8652                	mv	a2,s4
    80002b5e:	b7d1                	j	80002b22 <procdump+0x62>
  }
}
    80002b60:	60a6                	ld	ra,72(sp)
    80002b62:	6406                	ld	s0,64(sp)
    80002b64:	74e2                	ld	s1,56(sp)
    80002b66:	7942                	ld	s2,48(sp)
    80002b68:	79a2                	ld	s3,40(sp)
    80002b6a:	7a02                	ld	s4,32(sp)
    80002b6c:	6ae2                	ld	s5,24(sp)
    80002b6e:	6b42                	ld	s6,16(sp)
    80002b70:	6ba2                	ld	s7,8(sp)
    80002b72:	6c02                	ld	s8,0(sp)
    80002b74:	6161                	addi	sp,sp,80
    80002b76:	8082                	ret

0000000080002b78 <is_valid_sigmask>:

int 
is_valid_sigmask(int sigmask){
    80002b78:	1141                	addi	sp,sp,-16
    80002b7a:	e422                	sd	s0,8(sp)
    80002b7c:	0800                	addi	s0,sp,16
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002b7e:	000207b7          	lui	a5,0x20
    80002b82:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002b86:	8d7d                	and	a0,a0,a5
    return 0;
  return 1;
}
    80002b88:	00153513          	seqz	a0,a0
    80002b8c:	6422                	ld	s0,8(sp)
    80002b8e:	0141                	addi	sp,sp,16
    80002b90:	8082                	ret

0000000080002b92 <sigprocmask>:

uint
sigprocmask(uint new_procmask){
    80002b92:	7179                	addi	sp,sp,-48
    80002b94:	f406                	sd	ra,40(sp)
    80002b96:	f022                	sd	s0,32(sp)
    80002b98:	ec26                	sd	s1,24(sp)
    80002b9a:	e84a                	sd	s2,16(sp)
    80002b9c:	e44e                	sd	s3,8(sp)
    80002b9e:	1800                	addi	s0,sp,48
    80002ba0:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002ba2:	fffff097          	auipc	ra,0xfffff
    80002ba6:	eda080e7          	jalr	-294(ra) # 80001a7c <myproc>
  if(is_valid_sigmask(new_procmask) == 0)
    80002baa:	000207b7          	lui	a5,0x20
    80002bae:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002bb2:	00f977b3          	and	a5,s2,a5
    return -1;
    80002bb6:	59fd                	li	s3,-1
  if(is_valid_sigmask(new_procmask) == 0)
    80002bb8:	ef99                	bnez	a5,80002bd6 <sigprocmask+0x44>
    80002bba:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002bbc:	ffffe097          	auipc	ra,0xffffe
    80002bc0:	00a080e7          	jalr	10(ra) # 80000bc6 <acquire>
  int old_procmask = p->signal_mask;
    80002bc4:	0ec4a983          	lw	s3,236(s1)
  p->signal_mask = new_procmask;
    80002bc8:	0f24a623          	sw	s2,236(s1)
  release(&p->lock);
    80002bcc:	8526                	mv	a0,s1
    80002bce:	ffffe097          	auipc	ra,0xffffe
    80002bd2:	0ce080e7          	jalr	206(ra) # 80000c9c <release>
  
  return old_procmask;
}
    80002bd6:	854e                	mv	a0,s3
    80002bd8:	70a2                	ld	ra,40(sp)
    80002bda:	7402                	ld	s0,32(sp)
    80002bdc:	64e2                	ld	s1,24(sp)
    80002bde:	6942                	ld	s2,16(sp)
    80002be0:	69a2                	ld	s3,8(sp)
    80002be2:	6145                	addi	sp,sp,48
    80002be4:	8082                	ret

0000000080002be6 <sigaction>:

 
int 
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
  
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002be6:	0005079b          	sext.w	a5,a0
    80002bea:	477d                	li	a4,31
    80002bec:	0cf76a63          	bltu	a4,a5,80002cc0 <sigaction+0xda>
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
    80002bf0:	7139                	addi	sp,sp,-64
    80002bf2:	fc06                	sd	ra,56(sp)
    80002bf4:	f822                	sd	s0,48(sp)
    80002bf6:	f426                	sd	s1,40(sp)
    80002bf8:	f04a                	sd	s2,32(sp)
    80002bfa:	ec4e                	sd	s3,24(sp)
    80002bfc:	e852                	sd	s4,16(sp)
    80002bfe:	0080                	addi	s0,sp,64
    80002c00:	84aa                	mv	s1,a0
    80002c02:	89ae                	mv	s3,a1
    80002c04:	8a32                	mv	s4,a2
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002c06:	37dd                	addiw	a5,a5,-9
    80002c08:	9bdd                	andi	a5,a5,-9
    80002c0a:	2781                	sext.w	a5,a5
    80002c0c:	cfc5                	beqz	a5,80002cc4 <sigaction+0xde>
    80002c0e:	cdcd                	beqz	a1,80002cc8 <sigaction+0xe2>
    return -1;
  struct proc *p = myproc();
    80002c10:	fffff097          	auipc	ra,0xfffff
    80002c14:	e6c080e7          	jalr	-404(ra) # 80001a7c <myproc>
    80002c18:	892a                	mv	s2,a0

  uint new_mask;
  copyin(p->pagetable, (char *)&new_mask, (uint64)&act->sigmask, sizeof(act->sigmask));
    80002c1a:	4691                	li	a3,4
    80002c1c:	00898613          	addi	a2,s3,8
    80002c20:	fcc40593          	addi	a1,s0,-52
    80002c24:	6128                	ld	a0,64(a0)
    80002c26:	fffff097          	auipc	ra,0xfffff
    80002c2a:	aca080e7          	jalr	-1334(ra) # 800016f0 <copyin>
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002c2e:	fcc42703          	lw	a4,-52(s0)

  if(is_valid_sigmask(new_mask) == 0)
    80002c32:	000207b7          	lui	a5,0x20
    80002c36:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002c3a:	8ff9                	and	a5,a5,a4
    80002c3c:	ebc1                	bnez	a5,80002ccc <sigaction+0xe6>
    return -1;
  acquire(&p->lock);
    80002c3e:	854a                	mv	a0,s2
    80002c40:	ffffe097          	auipc	ra,0xffffe
    80002c44:	f86080e7          	jalr	-122(ra) # 80000bc6 <acquire>

  if(oldact!=0){
    80002c48:	020a0b63          	beqz	s4,80002c7e <sigaction+0x98>
    copyout(p->pagetable, (uint64)&oldact->sa_handler, (char *)&p->signal_handlers[signum], sizeof(act->sa_handler));
    80002c4c:	01f48613          	addi	a2,s1,31
    80002c50:	060e                	slli	a2,a2,0x3
    80002c52:	46a1                	li	a3,8
    80002c54:	964a                	add	a2,a2,s2
    80002c56:	85d2                	mv	a1,s4
    80002c58:	04093503          	ld	a0,64(s2)
    80002c5c:	fffff097          	auipc	ra,0xfffff
    80002c60:	a08080e7          	jalr	-1528(ra) # 80001664 <copyout>
    copyout(p->pagetable, (uint64)&oldact->sigmask, (char *)&p->handlers_sigmasks[signum], sizeof(uint));
    80002c64:	07e48613          	addi	a2,s1,126
    80002c68:	060a                	slli	a2,a2,0x2
    80002c6a:	4691                	li	a3,4
    80002c6c:	964a                	add	a2,a2,s2
    80002c6e:	008a0593          	addi	a1,s4,8
    80002c72:	04093503          	ld	a0,64(s2)
    80002c76:	fffff097          	auipc	ra,0xfffff
    80002c7a:	9ee080e7          	jalr	-1554(ra) # 80001664 <copyout>
  }

  p->handlers_sigmasks[signum]=new_mask;
    80002c7e:	07c48793          	addi	a5,s1,124
    80002c82:	078a                	slli	a5,a5,0x2
    80002c84:	97ca                	add	a5,a5,s2
    80002c86:	fcc42703          	lw	a4,-52(s0)
    80002c8a:	c798                	sw	a4,8(a5)
  copyin(p->pagetable, (char *)&p->signal_handlers[signum], (uint64)&act->sa_handler, sizeof(act->sa_handler));
    80002c8c:	04fd                	addi	s1,s1,31
    80002c8e:	048e                	slli	s1,s1,0x3
    80002c90:	46a1                	li	a3,8
    80002c92:	864e                	mv	a2,s3
    80002c94:	009905b3          	add	a1,s2,s1
    80002c98:	04093503          	ld	a0,64(s2)
    80002c9c:	fffff097          	auipc	ra,0xfffff
    80002ca0:	a54080e7          	jalr	-1452(ra) # 800016f0 <copyin>

  release(&p->lock);
    80002ca4:	854a                	mv	a0,s2
    80002ca6:	ffffe097          	auipc	ra,0xffffe
    80002caa:	ff6080e7          	jalr	-10(ra) # 80000c9c <release>



  return 0;
    80002cae:	4501                	li	a0,0
}
    80002cb0:	70e2                	ld	ra,56(sp)
    80002cb2:	7442                	ld	s0,48(sp)
    80002cb4:	74a2                	ld	s1,40(sp)
    80002cb6:	7902                	ld	s2,32(sp)
    80002cb8:	69e2                	ld	s3,24(sp)
    80002cba:	6a42                	ld	s4,16(sp)
    80002cbc:	6121                	addi	sp,sp,64
    80002cbe:	8082                	ret
    return -1;
    80002cc0:	557d                	li	a0,-1
}
    80002cc2:	8082                	ret
    return -1;
    80002cc4:	557d                	li	a0,-1
    80002cc6:	b7ed                	j	80002cb0 <sigaction+0xca>
    80002cc8:	557d                	li	a0,-1
    80002cca:	b7dd                	j	80002cb0 <sigaction+0xca>
    return -1;
    80002ccc:	557d                	li	a0,-1
    80002cce:	b7cd                	j	80002cb0 <sigaction+0xca>

0000000080002cd0 <sigret>:

void 
sigret(void){
    80002cd0:	1101                	addi	sp,sp,-32
    80002cd2:	ec06                	sd	ra,24(sp)
    80002cd4:	e822                	sd	s0,16(sp)
    80002cd6:	e426                	sd	s1,8(sp)
    80002cd8:	e04a                	sd	s2,0(sp)
    80002cda:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002cdc:	fffff097          	auipc	ra,0xfffff
    80002ce0:	da0080e7          	jalr	-608(ra) # 80001a7c <myproc>
    80002ce4:	84aa                	mv	s1,a0
  struct kthread *t=mykthread();
    80002ce6:	fffff097          	auipc	ra,0xfffff
    80002cea:	dd6080e7          	jalr	-554(ra) # 80001abc <mykthread>
    80002cee:	892a                	mv	s2,a0

  copyin(p->pagetable, (char *)t->trapframe, (uint64)p->user_trapframe_backup, sizeof(struct trapframe));
    80002cf0:	12000693          	li	a3,288
    80002cf4:	2784b603          	ld	a2,632(s1)
    80002cf8:	612c                	ld	a1,64(a0)
    80002cfa:	60a8                	ld	a0,64(s1)
    80002cfc:	fffff097          	auipc	ra,0xfffff
    80002d00:	9f4080e7          	jalr	-1548(ra) # 800016f0 <copyin>

  // restore user stack pointer
  acquire(&p->lock);
    80002d04:	8526                	mv	a0,s1
    80002d06:	ffffe097          	auipc	ra,0xffffe
    80002d0a:	ec0080e7          	jalr	-320(ra) # 80000bc6 <acquire>
  // TODO maybe we will need to also lock the kthread lock
  t->trapframe->sp += sizeof(struct trapframe);
    80002d0e:	04093703          	ld	a4,64(s2)
    80002d12:	7b1c                	ld	a5,48(a4)
    80002d14:	12078793          	addi	a5,a5,288
    80002d18:	fb1c                	sd	a5,48(a4)

  p->signal_mask = p->signal_mask_backup;
    80002d1a:	0f04a783          	lw	a5,240(s1)
    80002d1e:	0ef4a623          	sw	a5,236(s1)
  
  // Allow user signal handler since we finished handling the current
  p->handling_user_sig_flag = 0;
    80002d22:	2804a023          	sw	zero,640(s1)
  // Allow other thread to react to signals
  p->handling_sig_flag = 0;
    80002d26:	2804a223          	sw	zero,644(s1)
  release(&p->lock);
    80002d2a:	8526                	mv	a0,s1
    80002d2c:	ffffe097          	auipc	ra,0xffffe
    80002d30:	f70080e7          	jalr	-144(ra) # 80000c9c <release>
}
    80002d34:	60e2                	ld	ra,24(sp)
    80002d36:	6442                	ld	s0,16(sp)
    80002d38:	64a2                	ld	s1,8(sp)
    80002d3a:	6902                	ld	s2,0(sp)
    80002d3c:	6105                	addi	sp,sp,32
    80002d3e:	8082                	ret

0000000080002d40 <turn_on_bit>:

// we call turn on and turn off when holding p->lock
void
turn_on_bit(struct proc* p, int signum){
    80002d40:	1141                	addi	sp,sp,-16
    80002d42:	e422                	sd	s0,8(sp)
    80002d44:	0800                	addi	s0,sp,16
  if(!(p->pending_signals & (1 << signum)))
    80002d46:	0e852703          	lw	a4,232(a0)
    80002d4a:	4785                	li	a5,1
    80002d4c:	00b795bb          	sllw	a1,a5,a1
    80002d50:	00b777b3          	and	a5,a4,a1
    80002d54:	2781                	sext.w	a5,a5
    80002d56:	e781                	bnez	a5,80002d5e <turn_on_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    80002d58:	8db9                	xor	a1,a1,a4
    80002d5a:	0eb52423          	sw	a1,232(a0)
}
    80002d5e:	6422                	ld	s0,8(sp)
    80002d60:	0141                	addi	sp,sp,16
    80002d62:	8082                	ret

0000000080002d64 <kill>:
{
    80002d64:	7139                	addi	sp,sp,-64
    80002d66:	fc06                	sd	ra,56(sp)
    80002d68:	f822                	sd	s0,48(sp)
    80002d6a:	f426                	sd	s1,40(sp)
    80002d6c:	f04a                	sd	s2,32(sp)
    80002d6e:	ec4e                	sd	s3,24(sp)
    80002d70:	e852                	sd	s4,16(sp)
    80002d72:	e456                	sd	s5,8(sp)
    80002d74:	0080                	addi	s0,sp,64
    80002d76:	892a                	mv	s2,a0
    80002d78:	8aae                	mv	s5,a1
  for(p = proc; p < &proc[NPROC]; p++){
    80002d7a:	00010497          	auipc	s1,0x10
    80002d7e:	9ae48493          	addi	s1,s1,-1618 # 80012728 <proc>
    80002d82:	6985                	lui	s3,0x1
    80002d84:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002d88:	00031a17          	auipc	s4,0x31
    80002d8c:	ba0a0a13          	addi	s4,s4,-1120 # 80033928 <tickslock>
    acquire(&p->lock);
    80002d90:	8526                	mv	a0,s1
    80002d92:	ffffe097          	auipc	ra,0xffffe
    80002d96:	e34080e7          	jalr	-460(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    80002d9a:	50dc                	lw	a5,36(s1)
    80002d9c:	01278c63          	beq	a5,s2,80002db4 <kill+0x50>
    release(&p->lock);
    80002da0:	8526                	mv	a0,s1
    80002da2:	ffffe097          	auipc	ra,0xffffe
    80002da6:	efa080e7          	jalr	-262(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002daa:	94ce                	add	s1,s1,s3
    80002dac:	ff4492e3          	bne	s1,s4,80002d90 <kill+0x2c>
  return -1;
    80002db0:	557d                	li	a0,-1
    80002db2:	a049                	j	80002e34 <kill+0xd0>
      if(p->state != RUNNABLE){
    80002db4:	4c98                	lw	a4,24(s1)
    80002db6:	4789                	li	a5,2
    80002db8:	06f71863          	bne	a4,a5,80002e28 <kill+0xc4>
      if(p->signal_handlers[signum] == (void*)SIG_IGN){
    80002dbc:	01ea8793          	addi	a5,s5,30
    80002dc0:	078e                	slli	a5,a5,0x3
    80002dc2:	97a6                	add	a5,a5,s1
    80002dc4:	6798                	ld	a4,8(a5)
    80002dc6:	4785                	li	a5,1
    80002dc8:	06f70f63          	beq	a4,a5,80002e46 <kill+0xe2>
      turn_on_bit(p,signum);
    80002dcc:	85d6                	mv	a1,s5
    80002dce:	8526                	mv	a0,s1
    80002dd0:	00000097          	auipc	ra,0x0
    80002dd4:	f70080e7          	jalr	-144(ra) # 80002d40 <turn_on_bit>
      release(&p->lock);
    80002dd8:	8526                	mv	a0,s1
    80002dda:	ffffe097          	auipc	ra,0xffffe
    80002dde:	ec2080e7          	jalr	-318(ra) # 80000c9c <release>
      if(signum == SIGKILL){
    80002de2:	47a5                	li	a5,9
      return 0;
    80002de4:	4501                	li	a0,0
      if(signum == SIGKILL){
    80002de6:	04fa9763          	bne	s5,a5,80002e34 <kill+0xd0>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002dea:	28848913          	addi	s2,s1,648
    80002dee:	6785                	lui	a5,0x1
    80002df0:	84878793          	addi	a5,a5,-1976 # 848 <_entry-0x7ffff7b8>
    80002df4:	94be                	add	s1,s1,a5
          if(t->state == RUNNABLE){
    80002df6:	4989                	li	s3,2
    80002df8:	01892783          	lw	a5,24(s2)
    80002dfc:	07378363          	beq	a5,s3,80002e62 <kill+0xfe>
            acquire(&t->lock);
    80002e00:	854a                	mv	a0,s2
    80002e02:	ffffe097          	auipc	ra,0xffffe
    80002e06:	dc4080e7          	jalr	-572(ra) # 80000bc6 <acquire>
            if(t->state==TSLEEPING){
    80002e0a:	01892783          	lw	a5,24(s2)
    80002e0e:	05378363          	beq	a5,s3,80002e54 <kill+0xf0>
            release(&t->lock);
    80002e12:	854a                	mv	a0,s2
    80002e14:	ffffe097          	auipc	ra,0xffffe
    80002e18:	e88080e7          	jalr	-376(ra) # 80000c9c <release>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002e1c:	0b890913          	addi	s2,s2,184
    80002e20:	fc991ce3          	bne	s2,s1,80002df8 <kill+0x94>
      return 0;
    80002e24:	4501                	li	a0,0
    80002e26:	a039                	j	80002e34 <kill+0xd0>
        release(&p->lock);
    80002e28:	8526                	mv	a0,s1
    80002e2a:	ffffe097          	auipc	ra,0xffffe
    80002e2e:	e72080e7          	jalr	-398(ra) # 80000c9c <release>
        return -1;
    80002e32:	557d                	li	a0,-1
}
    80002e34:	70e2                	ld	ra,56(sp)
    80002e36:	7442                	ld	s0,48(sp)
    80002e38:	74a2                	ld	s1,40(sp)
    80002e3a:	7902                	ld	s2,32(sp)
    80002e3c:	69e2                	ld	s3,24(sp)
    80002e3e:	6a42                	ld	s4,16(sp)
    80002e40:	6aa2                	ld	s5,8(sp)
    80002e42:	6121                	addi	sp,sp,64
    80002e44:	8082                	ret
        release(&p->lock);
    80002e46:	8526                	mv	a0,s1
    80002e48:	ffffe097          	auipc	ra,0xffffe
    80002e4c:	e54080e7          	jalr	-428(ra) # 80000c9c <release>
        return 1;
    80002e50:	4505                	li	a0,1
    80002e52:	b7cd                	j	80002e34 <kill+0xd0>
              release(&t->lock);
    80002e54:	854a                	mv	a0,s2
    80002e56:	ffffe097          	auipc	ra,0xffffe
    80002e5a:	e46080e7          	jalr	-442(ra) # 80000c9c <release>
      return 0;
    80002e5e:	4501                	li	a0,0
              break;
    80002e60:	bfd1                	j	80002e34 <kill+0xd0>
      return 0;
    80002e62:	4501                	li	a0,0
    80002e64:	bfc1                	j	80002e34 <kill+0xd0>

0000000080002e66 <turn_off_bit>:

void
turn_off_bit(struct proc* p, int signum){
    80002e66:	1141                	addi	sp,sp,-16
    80002e68:	e422                	sd	s0,8(sp)
    80002e6a:	0800                	addi	s0,sp,16
  if(p->pending_signals & (1 << signum))
    80002e6c:	0e852703          	lw	a4,232(a0)
    80002e70:	4785                	li	a5,1
    80002e72:	00b795bb          	sllw	a1,a5,a1
    80002e76:	00b777b3          	and	a5,a4,a1
    80002e7a:	2781                	sext.w	a5,a5
    80002e7c:	c781                	beqz	a5,80002e84 <turn_off_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    80002e7e:	8db9                	xor	a1,a1,a4
    80002e80:	0eb52423          	sw	a1,232(a0)
}
    80002e84:	6422                	ld	s0,8(sp)
    80002e86:	0141                	addi	sp,sp,16
    80002e88:	8082                	ret

0000000080002e8a <kthread_create>:

int kthread_create(void (*start_func)(), void *stack){
    80002e8a:	7139                	addi	sp,sp,-64
    80002e8c:	fc06                	sd	ra,56(sp)
    80002e8e:	f822                	sd	s0,48(sp)
    80002e90:	f426                	sd	s1,40(sp)
    80002e92:	f04a                	sd	s2,32(sp)
    80002e94:	ec4e                	sd	s3,24(sp)
    80002e96:	e852                	sd	s4,16(sp)
    80002e98:	e456                	sd	s5,8(sp)
    80002e9a:	e05a                	sd	s6,0(sp)
    80002e9c:	0080                	addi	s0,sp,64
    80002e9e:	8b2a                	mv	s6,a0
    80002ea0:	8aae                	mv	s5,a1
  struct proc *p = myproc();
    80002ea2:	fffff097          	auipc	ra,0xfffff
    80002ea6:	bda080e7          	jalr	-1062(ra) # 80001a7c <myproc>
    80002eaa:	8a2a                	mv	s4,a0
  struct kthread *curr_t = mykthread();
    80002eac:	fffff097          	auipc	ra,0xfffff
    80002eb0:	c10080e7          	jalr	-1008(ra) # 80001abc <mykthread>
    80002eb4:	89aa                	mv	s3,a0
  struct kthread *other_t;

  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    80002eb6:	288a0493          	addi	s1,s4,648
    80002eba:	6905                	lui	s2,0x1
    80002ebc:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002ec0:	9952                	add	s2,s2,s4
    80002ec2:	a861                	j	80002f5a <kthread_create+0xd0>
  t->tid = 0;
    80002ec4:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80002ec8:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80002ecc:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80002ed0:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80002ed4:	0004ac23          	sw	zero,24(s1)

    if(curr_t != other_t){
      acquire(&other_t->lock);
      if(other_t->state == TUNUSED){
          freethread(other_t);  // free memory in case this thread entry was previously used
          init_thread(other_t);
    80002ed8:	8526                	mv	a0,s1
    80002eda:	fffff097          	auipc	ra,0xfffff
    80002ede:	d0e080e7          	jalr	-754(ra) # 80001be8 <init_thread>
          
          
          *(other_t->trapframe) = *(curr_t->trapframe);
    80002ee2:	0409b683          	ld	a3,64(s3)
    80002ee6:	87b6                	mv	a5,a3
    80002ee8:	60b8                	ld	a4,64(s1)
    80002eea:	12068693          	addi	a3,a3,288
    80002eee:	0007b803          	ld	a6,0(a5)
    80002ef2:	6788                	ld	a0,8(a5)
    80002ef4:	6b8c                	ld	a1,16(a5)
    80002ef6:	6f90                	ld	a2,24(a5)
    80002ef8:	01073023          	sd	a6,0(a4) # 20000 <_entry-0x7ffe0000>
    80002efc:	e708                	sd	a0,8(a4)
    80002efe:	eb0c                	sd	a1,16(a4)
    80002f00:	ef10                	sd	a2,24(a4)
    80002f02:	02078793          	addi	a5,a5,32
    80002f06:	02070713          	addi	a4,a4,32
    80002f0a:	fed792e3          	bne	a5,a3,80002eee <kthread_create+0x64>
          other_t->trapframe->sp = (uint64)stack + MAX_STACK_SIZE-16;
    80002f0e:	60b8                	ld	a4,64(s1)
    80002f10:	6785                	lui	a5,0x1
    80002f12:	f9078793          	addi	a5,a5,-112 # f90 <_entry-0x7ffff070>
    80002f16:	9abe                	add	s5,s5,a5
    80002f18:	03573823          	sd	s5,48(a4)

          other_t->trapframe->epc = (uint64)start_func;
    80002f1c:	60bc                	ld	a5,64(s1)
    80002f1e:	0167bc23          	sd	s6,24(a5)
          release(&other_t->lock);
    80002f22:	8526                	mv	a0,s1
    80002f24:	ffffe097          	auipc	ra,0xffffe
    80002f28:	d78080e7          	jalr	-648(ra) # 80000c9c <release>
          acquire(&p->lock);
    80002f2c:	8552                	mv	a0,s4
    80002f2e:	ffffe097          	auipc	ra,0xffffe
    80002f32:	c98080e7          	jalr	-872(ra) # 80000bc6 <acquire>
          p->active_threads++;
    80002f36:	028a2783          	lw	a5,40(s4)
    80002f3a:	2785                	addiw	a5,a5,1
    80002f3c:	02fa2423          	sw	a5,40(s4)
          release(&p->lock);
    80002f40:	8552                	mv	a0,s4
    80002f42:	ffffe097          	auipc	ra,0xffffe
    80002f46:	d5a080e7          	jalr	-678(ra) # 80000c9c <release>
          other_t->state = TRUNNABLE;
    80002f4a:	478d                	li	a5,3
    80002f4c:	cc9c                	sw	a5,24(s1)
          return other_t->tid;
    80002f4e:	5888                	lw	a0,48(s1)
    80002f50:	a02d                	j	80002f7a <kthread_create+0xf0>
  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    80002f52:	0b848493          	addi	s1,s1,184
    80002f56:	02990163          	beq	s2,s1,80002f78 <kthread_create+0xee>
    if(curr_t != other_t){
    80002f5a:	fe998ce3          	beq	s3,s1,80002f52 <kthread_create+0xc8>
      acquire(&other_t->lock);
    80002f5e:	8526                	mv	a0,s1
    80002f60:	ffffe097          	auipc	ra,0xffffe
    80002f64:	c66080e7          	jalr	-922(ra) # 80000bc6 <acquire>
      if(other_t->state == TUNUSED){
    80002f68:	4c9c                	lw	a5,24(s1)
    80002f6a:	dfa9                	beqz	a5,80002ec4 <kthread_create+0x3a>
      }
      release(&other_t->lock);
    80002f6c:	8526                	mv	a0,s1
    80002f6e:	ffffe097          	auipc	ra,0xffffe
    80002f72:	d2e080e7          	jalr	-722(ra) # 80000c9c <release>
    80002f76:	bff1                	j	80002f52 <kthread_create+0xc8>
    }
  }
  return -1;
    80002f78:	557d                	li	a0,-1
}
    80002f7a:	70e2                	ld	ra,56(sp)
    80002f7c:	7442                	ld	s0,48(sp)
    80002f7e:	74a2                	ld	s1,40(sp)
    80002f80:	7902                	ld	s2,32(sp)
    80002f82:	69e2                	ld	s3,24(sp)
    80002f84:	6a42                	ld	s4,16(sp)
    80002f86:	6aa2                	ld	s5,8(sp)
    80002f88:	6b02                	ld	s6,0(sp)
    80002f8a:	6121                	addi	sp,sp,64
    80002f8c:	8082                	ret

0000000080002f8e <kthread_join>:



int
kthread_join(int thread_id, int* status){
    80002f8e:	7139                	addi	sp,sp,-64
    80002f90:	fc06                	sd	ra,56(sp)
    80002f92:	f822                	sd	s0,48(sp)
    80002f94:	f426                	sd	s1,40(sp)
    80002f96:	f04a                	sd	s2,32(sp)
    80002f98:	ec4e                	sd	s3,24(sp)
    80002f9a:	e852                	sd	s4,16(sp)
    80002f9c:	e456                	sd	s5,8(sp)
    80002f9e:	e05a                	sd	s6,0(sp)
    80002fa0:	0080                	addi	s0,sp,64
    80002fa2:	8a2a                	mv	s4,a0
    80002fa4:	8b2e                	mv	s6,a1
  struct kthread *nt;
  struct proc *p = myproc();
    80002fa6:	fffff097          	auipc	ra,0xfffff
    80002faa:	ad6080e7          	jalr	-1322(ra) # 80001a7c <myproc>
    80002fae:	8aaa                	mv	s5,a0
  struct kthread *t = mykthread();
    80002fb0:	fffff097          	auipc	ra,0xfffff
    80002fb4:	b0c080e7          	jalr	-1268(ra) # 80001abc <mykthread>



  if(thread_id == t->tid)
    80002fb8:	591c                	lw	a5,48(a0)
    80002fba:	15478563          	beq	a5,s4,80003104 <kthread_join+0x176>
    80002fbe:	89aa                	mv	s3,a0
    return -1;
  acquire(&wait_lock);
    80002fc0:	0000f517          	auipc	a0,0xf
    80002fc4:	31050513          	addi	a0,a0,784 # 800122d0 <wait_lock>
    80002fc8:	ffffe097          	auipc	ra,0xffffe
    80002fcc:	bfe080e7          	jalr	-1026(ra) # 80000bc6 <acquire>
  // Search for thread in the procces threads array
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){
    80002fd0:	288a8913          	addi	s2,s5,648
    80002fd4:	6485                	lui	s1,0x1
    80002fd6:	84848493          	addi	s1,s1,-1976 # 848 <_entry-0x7ffff7b8>
    80002fda:	94d6                	add	s1,s1,s5
    80002fdc:	a029                	j	80002fe6 <kthread_join+0x58>
    80002fde:	0b890913          	addi	s2,s2,184
    80002fe2:	03248363          	beq	s1,s2,80003008 <kthread_join+0x7a>
    if(nt != t){
    80002fe6:	ff298ce3          	beq	s3,s2,80002fde <kthread_join+0x50>
      acquire(&nt->lock);
    80002fea:	854a                	mv	a0,s2
    80002fec:	ffffe097          	auipc	ra,0xffffe
    80002ff0:	bda080e7          	jalr	-1062(ra) # 80000bc6 <acquire>

      if(nt->tid == thread_id){
    80002ff4:	03092783          	lw	a5,48(s2)
    80002ff8:	0b478d63          	beq	a5,s4,800030b2 <kthread_join+0x124>
        //found target thread 
        break;
      }
      release(&nt->lock);
    80002ffc:	854a                	mv	a0,s2
    80002ffe:	ffffe097          	auipc	ra,0xffffe
    80003002:	c9e080e7          	jalr	-866(ra) # 80000c9c <release>
    80003006:	bfe1                	j	80002fde <kthread_join+0x50>
    }
  }

  if(nt->tid != thread_id){
    80003008:	6785                	lui	a5,0x1
    8000300a:	97d6                	add	a5,a5,s5
    8000300c:	8787a783          	lw	a5,-1928(a5) # 878 <_entry-0x7ffff788>
    80003010:	09479763          	bne	a5,s4,8000309e <kthread_join+0x110>
  }
  
  // Wait for thread to terminate
  // still holding nt lock
  for(;;){
      if(nt->state==TUNUSED){
    80003014:	4c9c                	lw	a5,24(s1)
      release(&nt->lock);
      release(&wait_lock);
      return -1;
    }
    release(&nt->lock);
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    80003016:	0000f917          	auipc	s2,0xf
    8000301a:	2ba90913          	addi	s2,s2,698 # 800122d0 <wait_lock>
      if(nt->state==TUNUSED){
    8000301e:	cb8d                	beqz	a5,80003050 <kthread_join+0xc2>
    if(t->killed || nt->tid!=thread_id){
    80003020:	0289a783          	lw	a5,40(s3)
    80003024:	ebc5                	bnez	a5,800030d4 <kthread_join+0x146>
    80003026:	589c                	lw	a5,48(s1)
    80003028:	0b479663          	bne	a5,s4,800030d4 <kthread_join+0x146>
    release(&nt->lock);
    8000302c:	8526                	mv	a0,s1
    8000302e:	ffffe097          	auipc	ra,0xffffe
    80003032:	c6e080e7          	jalr	-914(ra) # 80000c9c <release>
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    80003036:	85ca                	mv	a1,s2
    80003038:	8526                	mv	a0,s1
    8000303a:	fffff097          	auipc	ra,0xfffff
    8000303e:	3ca080e7          	jalr	970(ra) # 80002404 <sleep>
    acquire(&nt->lock);
    80003042:	8526                	mv	a0,s1
    80003044:	ffffe097          	auipc	ra,0xffffe
    80003048:	b82080e7          	jalr	-1150(ra) # 80000bc6 <acquire>
      if(nt->state==TUNUSED){
    8000304c:	4c9c                	lw	a5,24(s1)
    8000304e:	fbe9                	bnez	a5,80003020 <kthread_join+0x92>
        if(status != 0 && copyout(p->pagetable, status, (char *)&nt->xstate,sizeof(nt->xstate)) < 0) {
    80003050:	000b0e63          	beqz	s6,8000306c <kthread_join+0xde>
    80003054:	4691                	li	a3,4
    80003056:	02c48613          	addi	a2,s1,44
    8000305a:	85da                	mv	a1,s6
    8000305c:	040ab503          	ld	a0,64(s5)
    80003060:	ffffe097          	auipc	ra,0xffffe
    80003064:	604080e7          	jalr	1540(ra) # 80001664 <copyout>
    80003068:	04054763          	bltz	a0,800030b6 <kthread_join+0x128>
  t->tid = 0;
    8000306c:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80003070:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80003074:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80003078:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    8000307c:	0004ac23          	sw	zero,24(s1)
        release(&nt->lock);
    80003080:	8526                	mv	a0,s1
    80003082:	ffffe097          	auipc	ra,0xffffe
    80003086:	c1a080e7          	jalr	-998(ra) # 80000c9c <release>
        release(&wait_lock);  //  successfull join
    8000308a:	0000f517          	auipc	a0,0xf
    8000308e:	24650513          	addi	a0,a0,582 # 800122d0 <wait_lock>
    80003092:	ffffe097          	auipc	ra,0xffffe
    80003096:	c0a080e7          	jalr	-1014(ra) # 80000c9c <release>
        return 0;
    8000309a:	4501                	li	a0,0
    8000309c:	a891                	j	800030f0 <kthread_join+0x162>
    release(&wait_lock);
    8000309e:	0000f517          	auipc	a0,0xf
    800030a2:	23250513          	addi	a0,a0,562 # 800122d0 <wait_lock>
    800030a6:	ffffe097          	auipc	ra,0xffffe
    800030aa:	bf6080e7          	jalr	-1034(ra) # 80000c9c <release>
    return -1;
    800030ae:	557d                	li	a0,-1
    800030b0:	a081                	j	800030f0 <kthread_join+0x162>
    800030b2:	84ca                	mv	s1,s2
    800030b4:	b785                	j	80003014 <kthread_join+0x86>
           release(&nt->lock);
    800030b6:	8526                	mv	a0,s1
    800030b8:	ffffe097          	auipc	ra,0xffffe
    800030bc:	be4080e7          	jalr	-1052(ra) # 80000c9c <release>
           release(&wait_lock);
    800030c0:	0000f517          	auipc	a0,0xf
    800030c4:	21050513          	addi	a0,a0,528 # 800122d0 <wait_lock>
    800030c8:	ffffe097          	auipc	ra,0xffffe
    800030cc:	bd4080e7          	jalr	-1068(ra) # 80000c9c <release>
           return -1;                   
    800030d0:	557d                	li	a0,-1
    800030d2:	a839                	j	800030f0 <kthread_join+0x162>
      release(&nt->lock);
    800030d4:	8526                	mv	a0,s1
    800030d6:	ffffe097          	auipc	ra,0xffffe
    800030da:	bc6080e7          	jalr	-1082(ra) # 80000c9c <release>
      release(&wait_lock);
    800030de:	0000f517          	auipc	a0,0xf
    800030e2:	1f250513          	addi	a0,a0,498 # 800122d0 <wait_lock>
    800030e6:	ffffe097          	auipc	ra,0xffffe
    800030ea:	bb6080e7          	jalr	-1098(ra) # 80000c9c <release>
      return -1;
    800030ee:	557d                	li	a0,-1
  }
}
    800030f0:	70e2                	ld	ra,56(sp)
    800030f2:	7442                	ld	s0,48(sp)
    800030f4:	74a2                	ld	s1,40(sp)
    800030f6:	7902                	ld	s2,32(sp)
    800030f8:	69e2                	ld	s3,24(sp)
    800030fa:	6a42                	ld	s4,16(sp)
    800030fc:	6aa2                	ld	s5,8(sp)
    800030fe:	6b02                	ld	s6,0(sp)
    80003100:	6121                	addi	sp,sp,64
    80003102:	8082                	ret
    return -1;
    80003104:	557d                	li	a0,-1
    80003106:	b7ed                	j	800030f0 <kthread_join+0x162>

0000000080003108 <kthread_join_all>:

int
kthread_join_all(){
    80003108:	7179                	addi	sp,sp,-48
    8000310a:	f406                	sd	ra,40(sp)
    8000310c:	f022                	sd	s0,32(sp)
    8000310e:	ec26                	sd	s1,24(sp)
    80003110:	e84a                	sd	s2,16(sp)
    80003112:	e44e                	sd	s3,8(sp)
    80003114:	e052                	sd	s4,0(sp)
    80003116:	1800                	addi	s0,sp,48
  struct proc *p=myproc();
    80003118:	fffff097          	auipc	ra,0xfffff
    8000311c:	964080e7          	jalr	-1692(ra) # 80001a7c <myproc>
    80003120:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    80003122:	fffff097          	auipc	ra,0xfffff
    80003126:	99a080e7          	jalr	-1638(ra) # 80001abc <mykthread>
    8000312a:	8a2a                	mv	s4,a0
  struct kthread *nt;
  int res = 1;
  for(nt = p->kthreads; nt < &p->kthreads[NTHREAD]; nt++){
    8000312c:	28898493          	addi	s1,s3,648
    80003130:	6505                	lui	a0,0x1
    80003132:	84850513          	addi	a0,a0,-1976 # 848 <_entry-0x7ffff7b8>
    80003136:	99aa                	add	s3,s3,a0
  int res = 1;
    80003138:	4905                	li	s2,1
    8000313a:	a029                	j	80003144 <kthread_join_all+0x3c>
  for(nt = p->kthreads; nt < &p->kthreads[NTHREAD]; nt++){
    8000313c:	0b848493          	addi	s1,s1,184
    80003140:	00998e63          	beq	s3,s1,8000315c <kthread_join_all+0x54>
    if(nt != t){
    80003144:	fe9a0ce3          	beq	s4,s1,8000313c <kthread_join_all+0x34>
      int thread_index = (int)(nt - p->kthreads);
      res &= kthread_join(nt->tid,0);
    80003148:	4581                	li	a1,0
    8000314a:	5888                	lw	a0,48(s1)
    8000314c:	00000097          	auipc	ra,0x0
    80003150:	e42080e7          	jalr	-446(ra) # 80002f8e <kthread_join>
    80003154:	01257933          	and	s2,a0,s2
    80003158:	2901                	sext.w	s2,s2
    8000315a:	b7cd                	j	8000313c <kthread_join_all+0x34>
    }
  }

  return res;
}
    8000315c:	854a                	mv	a0,s2
    8000315e:	70a2                	ld	ra,40(sp)
    80003160:	7402                	ld	s0,32(sp)
    80003162:	64e2                	ld	s1,24(sp)
    80003164:	6942                	ld	s2,16(sp)
    80003166:	69a2                	ld	s3,8(sp)
    80003168:	6a02                	ld	s4,0(sp)
    8000316a:	6145                	addi	sp,sp,48
    8000316c:	8082                	ret

000000008000316e <printTF>:


void 
printTF(struct kthread *t){//function for debuging, TODO delete
    8000316e:	7175                	addi	sp,sp,-144
    80003170:	e506                	sd	ra,136(sp)
    80003172:	e122                	sd	s0,128(sp)
    80003174:	fca6                	sd	s1,120(sp)
    80003176:	0900                	addi	s0,sp,144
    80003178:	84aa                	mv	s1,a0
  printf("**************tid=%d*****************\n",t->tid);
    8000317a:	590c                	lw	a1,48(a0)
    8000317c:	00006517          	auipc	a0,0x6
    80003180:	23450513          	addi	a0,a0,564 # 800093b0 <digits+0x370>
    80003184:	ffffd097          	auipc	ra,0xffffd
    80003188:	3f4080e7          	jalr	1012(ra) # 80000578 <printf>
  // printf("t->tf->epc = %p\n",t->trapframe->epc);
  // printf("t->tf->ra = %p\n",t->trapframe->ra);
  // printf("t->tf->kernel_sp = %p\n",t->trapframe->kernel_sp);
  printf("t->kstack = %p\n",t->kstack);
    8000318c:	7c8c                	ld	a1,56(s1)
    8000318e:	00006517          	auipc	a0,0x6
    80003192:	24a50513          	addi	a0,a0,586 # 800093d8 <digits+0x398>
    80003196:	ffffd097          	auipc	ra,0xffffd
    8000319a:	3e2080e7          	jalr	994(ra) # 80000578 <printf>
  printf("t->context = %p\n",t->context);
    8000319e:	04848793          	addi	a5,s1,72
    800031a2:	f7040713          	addi	a4,s0,-144
    800031a6:	0a848693          	addi	a3,s1,168
    800031aa:	0007b803          	ld	a6,0(a5)
    800031ae:	6788                	ld	a0,8(a5)
    800031b0:	6b8c                	ld	a1,16(a5)
    800031b2:	6f90                	ld	a2,24(a5)
    800031b4:	01073023          	sd	a6,0(a4)
    800031b8:	e708                	sd	a0,8(a4)
    800031ba:	eb0c                	sd	a1,16(a4)
    800031bc:	ef10                	sd	a2,24(a4)
    800031be:	02078793          	addi	a5,a5,32
    800031c2:	02070713          	addi	a4,a4,32
    800031c6:	fed792e3          	bne	a5,a3,800031aa <printTF+0x3c>
    800031ca:	6394                	ld	a3,0(a5)
    800031cc:	679c                	ld	a5,8(a5)
    800031ce:	e314                	sd	a3,0(a4)
    800031d0:	e71c                	sd	a5,8(a4)
    800031d2:	f7040593          	addi	a1,s0,-144
    800031d6:	00006517          	auipc	a0,0x6
    800031da:	21250513          	addi	a0,a0,530 # 800093e8 <digits+0x3a8>
    800031de:	ffffd097          	auipc	ra,0xffffd
    800031e2:	39a080e7          	jalr	922(ra) # 80000578 <printf>
  printf("t->tf->sp = %p\n",t->trapframe->sp);
    800031e6:	60bc                	ld	a5,64(s1)
    800031e8:	7b8c                	ld	a1,48(a5)
    800031ea:	00006517          	auipc	a0,0x6
    800031ee:	21650513          	addi	a0,a0,534 # 80009400 <digits+0x3c0>
    800031f2:	ffffd097          	auipc	ra,0xffffd
    800031f6:	386080e7          	jalr	902(ra) # 80000578 <printf>
  printf("t->state = %d\n",t->state);
    800031fa:	4c8c                	lw	a1,24(s1)
    800031fc:	00006517          	auipc	a0,0x6
    80003200:	21450513          	addi	a0,a0,532 # 80009410 <digits+0x3d0>
    80003204:	ffffd097          	auipc	ra,0xffffd
    80003208:	374080e7          	jalr	884(ra) # 80000578 <printf>
  printf("**************************************\n",t->tid);
    8000320c:	588c                	lw	a1,48(s1)
    8000320e:	00006517          	auipc	a0,0x6
    80003212:	21250513          	addi	a0,a0,530 # 80009420 <digits+0x3e0>
    80003216:	ffffd097          	auipc	ra,0xffffd
    8000321a:	362080e7          	jalr	866(ra) # 80000578 <printf>

    8000321e:	60aa                	ld	ra,136(sp)
    80003220:	640a                	ld	s0,128(sp)
    80003222:	74e6                	ld	s1,120(sp)
    80003224:	6149                	addi	sp,sp,144
    80003226:	8082                	ret

0000000080003228 <swtch>:
    80003228:	00153023          	sd	ra,0(a0)
    8000322c:	00253423          	sd	sp,8(a0)
    80003230:	e900                	sd	s0,16(a0)
    80003232:	ed04                	sd	s1,24(a0)
    80003234:	03253023          	sd	s2,32(a0)
    80003238:	03353423          	sd	s3,40(a0)
    8000323c:	03453823          	sd	s4,48(a0)
    80003240:	03553c23          	sd	s5,56(a0)
    80003244:	05653023          	sd	s6,64(a0)
    80003248:	05753423          	sd	s7,72(a0)
    8000324c:	05853823          	sd	s8,80(a0)
    80003250:	05953c23          	sd	s9,88(a0)
    80003254:	07a53023          	sd	s10,96(a0)
    80003258:	07b53423          	sd	s11,104(a0)
    8000325c:	0005b083          	ld	ra,0(a1)
    80003260:	0085b103          	ld	sp,8(a1)
    80003264:	6980                	ld	s0,16(a1)
    80003266:	6d84                	ld	s1,24(a1)
    80003268:	0205b903          	ld	s2,32(a1)
    8000326c:	0285b983          	ld	s3,40(a1)
    80003270:	0305ba03          	ld	s4,48(a1)
    80003274:	0385ba83          	ld	s5,56(a1)
    80003278:	0405bb03          	ld	s6,64(a1)
    8000327c:	0485bb83          	ld	s7,72(a1)
    80003280:	0505bc03          	ld	s8,80(a1)
    80003284:	0585bc83          	ld	s9,88(a1)
    80003288:	0605bd03          	ld	s10,96(a1)
    8000328c:	0685bd83          	ld	s11,104(a1)
    80003290:	8082                	ret

0000000080003292 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80003292:	1141                	addi	sp,sp,-16
    80003294:	e406                	sd	ra,8(sp)
    80003296:	e022                	sd	s0,0(sp)
    80003298:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000329a:	00006597          	auipc	a1,0x6
    8000329e:	1e658593          	addi	a1,a1,486 # 80009480 <states.0+0x20>
    800032a2:	00030517          	auipc	a0,0x30
    800032a6:	68650513          	addi	a0,a0,1670 # 80033928 <tickslock>
    800032aa:	ffffe097          	auipc	ra,0xffffe
    800032ae:	88c080e7          	jalr	-1908(ra) # 80000b36 <initlock>
}
    800032b2:	60a2                	ld	ra,8(sp)
    800032b4:	6402                	ld	s0,0(sp)
    800032b6:	0141                	addi	sp,sp,16
    800032b8:	8082                	ret

00000000800032ba <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800032ba:	1141                	addi	sp,sp,-16
    800032bc:	e422                	sd	s0,8(sp)
    800032be:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800032c0:	00004797          	auipc	a5,0x4
    800032c4:	ac078793          	addi	a5,a5,-1344 # 80006d80 <kernelvec>
    800032c8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800032cc:	6422                	ld	s0,8(sp)
    800032ce:	0141                	addi	sp,sp,16
    800032d0:	8082                	ret

00000000800032d2 <check_should_cont>:
}

int 
check_should_cont(struct proc *p){
  for(int i=0;i<32;i++){
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    800032d2:	0e852303          	lw	t1,232(a0)
    800032d6:	0f850813          	addi	a6,a0,248
    800032da:	4685                	li	a3,1
    800032dc:	4701                	li	a4,0
    800032de:	4885                	li	a7,1
  for(int i=0;i<32;i++){
    800032e0:	4e7d                	li	t3,31
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    800032e2:	4ecd                	li	t4,19
    800032e4:	a801                	j	800032f4 <check_should_cont+0x22>
  for(int i=0;i<32;i++){
    800032e6:	0006879b          	sext.w	a5,a3
    800032ea:	04fe4663          	blt	t3,a5,80003336 <check_should_cont+0x64>
    800032ee:	2705                	addiw	a4,a4,1
    800032f0:	2685                	addiw	a3,a3,1
    800032f2:	0821                	addi	a6,a6,8
    800032f4:	0007059b          	sext.w	a1,a4
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    800032f8:	00e8963b          	sllw	a2,a7,a4
    800032fc:	00c377b3          	and	a5,t1,a2
    80003300:	2781                	sext.w	a5,a5
    80003302:	d3f5                	beqz	a5,800032e6 <check_should_cont+0x14>
    80003304:	0ec52783          	lw	a5,236(a0)
    80003308:	8ff1                	and	a5,a5,a2
    8000330a:	2781                	sext.w	a5,a5
    8000330c:	ffe9                	bnez	a5,800032e6 <check_should_cont+0x14>
    8000330e:	00083783          	ld	a5,0(a6)
    80003312:	01d78563          	beq	a5,t4,8000331c <check_should_cont+0x4a>
    80003316:	fdd598e3          	bne	a1,t4,800032e6 <check_should_cont+0x14>
          (i == SIGCONT && p->signal_handlers[i] == SIG_DFL))){
    8000331a:	fbf1                	bnez	a5,800032ee <check_should_cont+0x1c>
check_should_cont(struct proc *p){
    8000331c:	1141                	addi	sp,sp,-16
    8000331e:	e406                	sd	ra,8(sp)
    80003320:	e022                	sd	s0,0(sp)
    80003322:	0800                	addi	s0,sp,16
        turn_off_bit(p, i);
    80003324:	00000097          	auipc	ra,0x0
    80003328:	b42080e7          	jalr	-1214(ra) # 80002e66 <turn_off_bit>
        return 1;
    8000332c:	4505                	li	a0,1
      }
  }
  return 0;
}
    8000332e:	60a2                	ld	ra,8(sp)
    80003330:	6402                	ld	s0,0(sp)
    80003332:	0141                	addi	sp,sp,16
    80003334:	8082                	ret
  return 0;
    80003336:	4501                	li	a0,0
}
    80003338:	8082                	ret

000000008000333a <handle_stop>:



void
handle_stop(struct proc* p){
    8000333a:	7139                	addi	sp,sp,-64
    8000333c:	fc06                	sd	ra,56(sp)
    8000333e:	f822                	sd	s0,48(sp)
    80003340:	f426                	sd	s1,40(sp)
    80003342:	f04a                	sd	s2,32(sp)
    80003344:	ec4e                	sd	s3,24(sp)
    80003346:	e852                	sd	s4,16(sp)
    80003348:	e456                	sd	s5,8(sp)
    8000334a:	e05a                	sd	s6,0(sp)
    8000334c:	0080                	addi	s0,sp,64
    8000334e:	89aa                	mv	s3,a0

  struct kthread *t;
  struct kthread *curr_t = mykthread();
    80003350:	ffffe097          	auipc	ra,0xffffe
    80003354:	76c080e7          	jalr	1900(ra) # 80001abc <mykthread>
    80003358:	8aaa                	mv	s5,a0


  // Make all other threads belong to the same procces freeze 
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    8000335a:	28898493          	addi	s1,s3,648
    8000335e:	6a05                	lui	s4,0x1
    80003360:	848a0a13          	addi	s4,s4,-1976 # 848 <_entry-0x7ffff7b8>
    80003364:	9a4e                	add	s4,s4,s3
    80003366:	8926                	mv	s2,s1
    if(t!=curr_t){
      acquire(&t->lock);
      t->frozen=1;
    80003368:	4b05                	li	s6,1
    8000336a:	a029                	j	80003374 <handle_stop+0x3a>
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    8000336c:	0b890913          	addi	s2,s2,184
    80003370:	03490163          	beq	s2,s4,80003392 <handle_stop+0x58>
    if(t!=curr_t){
    80003374:	ff2a8ce3          	beq	s5,s2,8000336c <handle_stop+0x32>
      acquire(&t->lock);
    80003378:	854a                	mv	a0,s2
    8000337a:	ffffe097          	auipc	ra,0xffffe
    8000337e:	84c080e7          	jalr	-1972(ra) # 80000bc6 <acquire>
      t->frozen=1;
    80003382:	03692a23          	sw	s6,52(s2)
      release(&t->lock);
    80003386:	854a                	mv	a0,s2
    80003388:	ffffe097          	auipc	ra,0xffffe
    8000338c:	914080e7          	jalr	-1772(ra) # 80000c9c <release>
    80003390:	bff1                	j	8000336c <handle_stop+0x32>
    }
  }
  int should_cont = check_should_cont(p);
    80003392:	854e                	mv	a0,s3
    80003394:	00000097          	auipc	ra,0x0
    80003398:	f3e080e7          	jalr	-194(ra) # 800032d2 <check_should_cont>
  
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    8000339c:	0e89a783          	lw	a5,232(s3)
    800033a0:	2007f793          	andi	a5,a5,512
    800033a4:	e795                	bnez	a5,800033d0 <handle_stop+0x96>
    800033a6:	e50d                	bnez	a0,800033d0 <handle_stop+0x96>
    
    yield();
    800033a8:	fffff097          	auipc	ra,0xfffff
    800033ac:	020080e7          	jalr	32(ra) # 800023c8 <yield>
    should_cont = check_should_cont(p);  
    800033b0:	854e                	mv	a0,s3
    800033b2:	00000097          	auipc	ra,0x0
    800033b6:	f20080e7          	jalr	-224(ra) # 800032d2 <check_should_cont>
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    800033ba:	0e89a783          	lw	a5,232(s3)
    800033be:	2007f793          	andi	a5,a5,512
    800033c2:	e799                	bnez	a5,800033d0 <handle_stop+0x96>
    800033c4:	d175                	beqz	a0,800033a8 <handle_stop+0x6e>
    800033c6:	a029                	j	800033d0 <handle_stop+0x96>
    
  }

  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800033c8:	0b848493          	addi	s1,s1,184
    800033cc:	03448163          	beq	s1,s4,800033ee <handle_stop+0xb4>
    if(t!=curr_t){
    800033d0:	fe9a8ce3          	beq	s5,s1,800033c8 <handle_stop+0x8e>
      acquire(&t->lock);
    800033d4:	8526                	mv	a0,s1
    800033d6:	ffffd097          	auipc	ra,0xffffd
    800033da:	7f0080e7          	jalr	2032(ra) # 80000bc6 <acquire>
      t->frozen=0;
    800033de:	0204aa23          	sw	zero,52(s1)
      release(&t->lock);
    800033e2:	8526                	mv	a0,s1
    800033e4:	ffffe097          	auipc	ra,0xffffe
    800033e8:	8b8080e7          	jalr	-1864(ra) # 80000c9c <release>
    800033ec:	bff1                	j	800033c8 <handle_stop+0x8e>
    }
  }
  if(p->pending_signals&1<<SIGKILL)
    800033ee:	0e89a783          	lw	a5,232(s3)
    800033f2:	2007f793          	andi	a5,a5,512
    800033f6:	c781                	beqz	a5,800033fe <handle_stop+0xc4>
    p->killed=1;
    800033f8:	4785                	li	a5,1
    800033fa:	00f9ae23          	sw	a5,28(s3)
}
    800033fe:	70e2                	ld	ra,56(sp)
    80003400:	7442                	ld	s0,48(sp)
    80003402:	74a2                	ld	s1,40(sp)
    80003404:	7902                	ld	s2,32(sp)
    80003406:	69e2                	ld	s3,24(sp)
    80003408:	6a42                	ld	s4,16(sp)
    8000340a:	6aa2                	ld	s5,8(sp)
    8000340c:	6b02                	ld	s6,0(sp)
    8000340e:	6121                	addi	sp,sp,64
    80003410:	8082                	ret

0000000080003412 <check_pending_signals>:

void 
check_pending_signals(struct proc* p){
    80003412:	711d                	addi	sp,sp,-96
    80003414:	ec86                	sd	ra,88(sp)
    80003416:	e8a2                	sd	s0,80(sp)
    80003418:	e4a6                	sd	s1,72(sp)
    8000341a:	e0ca                	sd	s2,64(sp)
    8000341c:	fc4e                	sd	s3,56(sp)
    8000341e:	f852                	sd	s4,48(sp)
    80003420:	f456                	sd	s5,40(sp)
    80003422:	f05a                	sd	s6,32(sp)
    80003424:	ec5e                	sd	s7,24(sp)
    80003426:	e862                	sd	s8,16(sp)
    80003428:	e466                	sd	s9,8(sp)
    8000342a:	e06a                	sd	s10,0(sp)
    8000342c:	1080                	addi	s0,sp,96
    8000342e:	89aa                	mv	s3,a0
  // if(p->pid==4){
    
  //   if(p->pending_signals & (1<<SIGSTOP))
  //     printf("recieved stop sig\n");
  // }
  struct kthread *t= mykthread();
    80003430:	ffffe097          	auipc	ra,0xffffe
    80003434:	68c080e7          	jalr	1676(ra) # 80001abc <mykthread>
    80003438:	8caa                	mv	s9,a0
  for(int sig_num=0;sig_num<32;sig_num++){
    8000343a:	0f898913          	addi	s2,s3,248
    8000343e:	4481                	li	s1,0
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    80003440:	4a05                	li	s4,1
            p->killed = 1;
            release(&p->lock);
        }
      }

      else if(act.sa_handler==(void*)SIGKILL){
    80003442:	4c25                	li	s8,9
        p->killed=1;
      }else if(act.sa_handler==(void*)SIGSTOP){
    80003444:	4b45                	li	s6,17
        handle_stop(p);
      }      
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    80003446:	4b85                	li	s7,1
        switch (sig_num)
    80003448:	4d4d                	li	s10,19
  for(int sig_num=0;sig_num<32;sig_num++){
    8000344a:	02000a93          	li	s5,32
    8000344e:	a0a1                	j	80003496 <check_pending_signals+0x84>
        switch (sig_num)
    80003450:	03648163          	beq	s1,s6,80003472 <check_pending_signals+0x60>
    80003454:	03a48763          	beq	s1,s10,80003482 <check_pending_signals+0x70>
            acquire(&p->lock);
    80003458:	854e                	mv	a0,s3
    8000345a:	ffffd097          	auipc	ra,0xffffd
    8000345e:	76c080e7          	jalr	1900(ra) # 80000bc6 <acquire>
            p->killed = 1;
    80003462:	0179ae23          	sw	s7,28(s3)
            release(&p->lock);
    80003466:	854e                	mv	a0,s3
    80003468:	ffffe097          	auipc	ra,0xffffe
    8000346c:	834080e7          	jalr	-1996(ra) # 80000c9c <release>
    80003470:	a809                	j	80003482 <check_pending_signals+0x70>
            handle_stop(p);
    80003472:	854e                	mv	a0,s3
    80003474:	00000097          	auipc	ra,0x0
    80003478:	ec6080e7          	jalr	-314(ra) # 8000333a <handle_stop>
            break;
    8000347c:	a019                	j	80003482 <check_pending_signals+0x70>
        p->killed=1;
    8000347e:	0179ae23          	sw	s7,28(s3)
        turn_off_bit(p, sig_num);

        return;
      }

      turn_off_bit(p, sig_num);            
    80003482:	85a6                	mv	a1,s1
    80003484:	854e                	mv	a0,s3
    80003486:	00000097          	auipc	ra,0x0
    8000348a:	9e0080e7          	jalr	-1568(ra) # 80002e66 <turn_off_bit>
  for(int sig_num=0;sig_num<32;sig_num++){
    8000348e:	2485                	addiw	s1,s1,1
    80003490:	0921                	addi	s2,s2,8
    80003492:	0d548963          	beq	s1,s5,80003564 <check_pending_signals+0x152>
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    80003496:	009a173b          	sllw	a4,s4,s1
    8000349a:	0e89a783          	lw	a5,232(s3)
    8000349e:	8ff9                	and	a5,a5,a4
    800034a0:	2781                	sext.w	a5,a5
    800034a2:	d7f5                	beqz	a5,8000348e <check_pending_signals+0x7c>
    800034a4:	0ec9a783          	lw	a5,236(s3)
    800034a8:	8f7d                	and	a4,a4,a5
    800034aa:	2701                	sext.w	a4,a4
    800034ac:	f36d                	bnez	a4,8000348e <check_pending_signals+0x7c>
      act.sa_handler = p->signal_handlers[sig_num];
    800034ae:	00093703          	ld	a4,0(s2)
      if(act.sa_handler == (void*)SIG_DFL){
    800034b2:	df59                	beqz	a4,80003450 <check_pending_signals+0x3e>
      else if(act.sa_handler==(void*)SIGKILL){
    800034b4:	fd8705e3          	beq	a4,s8,8000347e <check_pending_signals+0x6c>
      }else if(act.sa_handler==(void*)SIGSTOP){
    800034b8:	0d670463          	beq	a4,s6,80003580 <check_pending_signals+0x16e>
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    800034bc:	fd7703e3          	beq	a4,s7,80003482 <check_pending_signals+0x70>
    800034c0:	2809a703          	lw	a4,640(s3)
    800034c4:	ff5d                	bnez	a4,80003482 <check_pending_signals+0x70>
      act.sigmask = p->handlers_sigmasks[sig_num];
    800034c6:	07c48713          	addi	a4,s1,124
    800034ca:	070a                	slli	a4,a4,0x2
    800034cc:	974e                	add	a4,a4,s3
    800034ce:	4718                	lw	a4,8(a4)
        p->handling_user_sig_flag = 1;
    800034d0:	4685                	li	a3,1
    800034d2:	28d9a023          	sw	a3,640(s3)
        p->signal_mask_backup = p->signal_mask;
    800034d6:	0ef9a823          	sw	a5,240(s3)
        p->signal_mask= p->handlers_sigmasks[sig_num];
    800034da:	0ee9a623          	sw	a4,236(s3)
        t->trapframe->sp -= sizeof(struct trapframe);
    800034de:	040cb703          	ld	a4,64(s9)
    800034e2:	7b1c                	ld	a5,48(a4)
    800034e4:	ee078793          	addi	a5,a5,-288
    800034e8:	fb1c                	sd	a5,48(a4)
        p->user_trapframe_backup = (struct trapframe* )(t->trapframe->sp);
    800034ea:	040cb783          	ld	a5,64(s9)
    800034ee:	7b8c                	ld	a1,48(a5)
    800034f0:	26b9bc23          	sd	a1,632(s3)
        copyout(p->pagetable, (uint64)p->user_trapframe_backup, (char *)t->trapframe, sizeof(struct trapframe));
    800034f4:	12000693          	li	a3,288
    800034f8:	040cb603          	ld	a2,64(s9)
    800034fc:	0409b503          	ld	a0,64(s3)
    80003500:	ffffe097          	auipc	ra,0xffffe
    80003504:	164080e7          	jalr	356(ra) # 80001664 <copyout>
        uint64 size = (uint64)&end_sigret - (uint64)&call_sigret;
    80003508:	00004697          	auipc	a3,0x4
    8000350c:	f0868693          	addi	a3,a3,-248 # 80007410 <end_sigret>
    80003510:	00004617          	auipc	a2,0x4
    80003514:	ef860613          	addi	a2,a2,-264 # 80007408 <call_sigret>
        t->trapframe->sp -= size;
    80003518:	040cb703          	ld	a4,64(s9)
    8000351c:	40d605b3          	sub	a1,a2,a3
    80003520:	7b1c                	ld	a5,48(a4)
    80003522:	97ae                	add	a5,a5,a1
    80003524:	fb1c                	sd	a5,48(a4)
        copyout(p->pagetable, (uint64)t->trapframe->sp, (char *)&call_sigret, size);
    80003526:	040cb783          	ld	a5,64(s9)
    8000352a:	8e91                	sub	a3,a3,a2
    8000352c:	7b8c                	ld	a1,48(a5)
    8000352e:	0409b503          	ld	a0,64(s3)
    80003532:	ffffe097          	auipc	ra,0xffffe
    80003536:	132080e7          	jalr	306(ra) # 80001664 <copyout>
        t->trapframe->a0 = sig_num;
    8000353a:	040cb783          	ld	a5,64(s9)
    8000353e:	fba4                	sd	s1,112(a5)
        t->trapframe->ra = t->trapframe->sp;
    80003540:	040cb783          	ld	a5,64(s9)
    80003544:	7b98                	ld	a4,48(a5)
    80003546:	f798                	sd	a4,40(a5)
        t->trapframe->epc = (uint64)p->signal_handlers[sig_num];
    80003548:	040cb703          	ld	a4,64(s9)
    8000354c:	01e48793          	addi	a5,s1,30
    80003550:	078e                	slli	a5,a5,0x3
    80003552:	97ce                	add	a5,a5,s3
    80003554:	679c                	ld	a5,8(a5)
    80003556:	ef1c                	sd	a5,24(a4)
        turn_off_bit(p, sig_num);
    80003558:	85a6                	mv	a1,s1
    8000355a:	854e                	mv	a0,s3
    8000355c:	00000097          	auipc	ra,0x0
    80003560:	90a080e7          	jalr	-1782(ra) # 80002e66 <turn_off_bit>
    }
  }
}
    80003564:	60e6                	ld	ra,88(sp)
    80003566:	6446                	ld	s0,80(sp)
    80003568:	64a6                	ld	s1,72(sp)
    8000356a:	6906                	ld	s2,64(sp)
    8000356c:	79e2                	ld	s3,56(sp)
    8000356e:	7a42                	ld	s4,48(sp)
    80003570:	7aa2                	ld	s5,40(sp)
    80003572:	7b02                	ld	s6,32(sp)
    80003574:	6be2                	ld	s7,24(sp)
    80003576:	6c42                	ld	s8,16(sp)
    80003578:	6ca2                	ld	s9,8(sp)
    8000357a:	6d02                	ld	s10,0(sp)
    8000357c:	6125                	addi	sp,sp,96
    8000357e:	8082                	ret
        handle_stop(p);
    80003580:	854e                	mv	a0,s3
    80003582:	00000097          	auipc	ra,0x0
    80003586:	db8080e7          	jalr	-584(ra) # 8000333a <handle_stop>
    8000358a:	bde5                	j	80003482 <check_pending_signals+0x70>

000000008000358c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000358c:	1101                	addi	sp,sp,-32
    8000358e:	ec06                	sd	ra,24(sp)
    80003590:	e822                	sd	s0,16(sp)
    80003592:	e426                	sd	s1,8(sp)
    80003594:	e04a                	sd	s2,0(sp)
    80003596:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003598:	ffffe097          	auipc	ra,0xffffe
    8000359c:	4e4080e7          	jalr	1252(ra) # 80001a7c <myproc>
    800035a0:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    800035a2:	ffffe097          	auipc	ra,0xffffe
    800035a6:	51a080e7          	jalr	1306(ra) # 80001abc <mykthread>
    800035aa:	84aa                	mv	s1,a0
  int mytid = mykthread()->tid;
    800035ac:	ffffe097          	auipc	ra,0xffffe
    800035b0:	510080e7          	jalr	1296(ra) # 80001abc <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800035b4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800035b8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800035ba:	10079073          	csrw	sstatus,a5

  intr_off();
  

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800035be:	00005617          	auipc	a2,0x5
    800035c2:	a4260613          	addi	a2,a2,-1470 # 80008000 <_trampoline>
    800035c6:	00005697          	auipc	a3,0x5
    800035ca:	a3a68693          	addi	a3,a3,-1478 # 80008000 <_trampoline>
    800035ce:	8e91                	sub	a3,a3,a2
    800035d0:	040007b7          	lui	a5,0x4000
    800035d4:	17fd                	addi	a5,a5,-1
    800035d6:	07b2                	slli	a5,a5,0xc
    800035d8:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800035da:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  t->trapframe->kernel_satp = r_satp();         // kernel page table
    800035de:	60b8                	ld	a4,64(s1)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800035e0:	180026f3          	csrr	a3,satp
    800035e4:	e314                	sd	a3,0(a4)
  t->trapframe->kernel_sp = t->kstack + PGSIZE; // process's kernel stack
    800035e6:	60b8                	ld	a4,64(s1)
    800035e8:	7c94                	ld	a3,56(s1)
    800035ea:	6585                	lui	a1,0x1
    800035ec:	96ae                	add	a3,a3,a1
    800035ee:	e714                	sd	a3,8(a4)
  t->trapframe->kernel_trap = (uint64)usertrap;
    800035f0:	60b8                	ld	a4,64(s1)
    800035f2:	00000697          	auipc	a3,0x0
    800035f6:	15e68693          	addi	a3,a3,350 # 80003750 <usertrap>
    800035fa:	eb14                	sd	a3,16(a4)
  t->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800035fc:	60b8                	ld	a4,64(s1)
  asm volatile("mv %0, tp" : "=r" (x) );
    800035fe:	8692                	mv	a3,tp
    80003600:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003602:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80003606:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000360a:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000360e:	10069073          	csrw	sstatus,a3
  w_sstatus(x);
  

  // set S Exception Program Counter to the saved user pc.
  w_sepc(t->trapframe->epc);
    80003612:	60b8                	ld	a4,64(s1)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003614:	6f18                	ld	a4,24(a4)
    80003616:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000361a:	04093583          	ld	a1,64(s2)
    8000361e:	81b1                	srli	a1,a1,0xc
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
 
 
  int thread_ind = (int)(t - p->kthreads);
    80003620:	28890513          	addi	a0,s2,648
    80003624:	40a48533          	sub	a0,s1,a0
    80003628:	850d                	srai	a0,a0,0x3




  ((void (*)(uint64,uint64))fn)(TRAPFRAME + (uint64)(thread_ind * sizeof(struct trapframe)), satp);
    8000362a:	00006497          	auipc	s1,0x6
    8000362e:	9de4b483          	ld	s1,-1570(s1) # 80009008 <etext+0x8>
    80003632:	0295053b          	mulw	a0,a0,s1
    80003636:	00351493          	slli	s1,a0,0x3
    8000363a:	9526                	add	a0,a0,s1
    8000363c:	0516                	slli	a0,a0,0x5
    8000363e:	020006b7          	lui	a3,0x2000
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80003642:	00005717          	auipc	a4,0x5
    80003646:	a4e70713          	addi	a4,a4,-1458 # 80008090 <userret>
    8000364a:	8f11                	sub	a4,a4,a2
    8000364c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME + (uint64)(thread_ind * sizeof(struct trapframe)), satp);
    8000364e:	577d                	li	a4,-1
    80003650:	177e                	slli	a4,a4,0x3f
    80003652:	8dd9                	or	a1,a1,a4
    80003654:	16fd                	addi	a3,a3,-1
    80003656:	06b6                	slli	a3,a3,0xd
    80003658:	9536                	add	a0,a0,a3
    8000365a:	9782                	jalr	a5

}
    8000365c:	60e2                	ld	ra,24(sp)
    8000365e:	6442                	ld	s0,16(sp)
    80003660:	64a2                	ld	s1,8(sp)
    80003662:	6902                	ld	s2,0(sp)
    80003664:	6105                	addi	sp,sp,32
    80003666:	8082                	ret

0000000080003668 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80003668:	1101                	addi	sp,sp,-32
    8000366a:	ec06                	sd	ra,24(sp)
    8000366c:	e822                	sd	s0,16(sp)
    8000366e:	e426                	sd	s1,8(sp)
    80003670:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80003672:	00030497          	auipc	s1,0x30
    80003676:	2b648493          	addi	s1,s1,694 # 80033928 <tickslock>
    8000367a:	8526                	mv	a0,s1
    8000367c:	ffffd097          	auipc	ra,0xffffd
    80003680:	54a080e7          	jalr	1354(ra) # 80000bc6 <acquire>
  ticks++;
    80003684:	00007517          	auipc	a0,0x7
    80003688:	9ac50513          	addi	a0,a0,-1620 # 8000a030 <ticks>
    8000368c:	411c                	lw	a5,0(a0)
    8000368e:	2785                	addiw	a5,a5,1
    80003690:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80003692:	fffff097          	auipc	ra,0xfffff
    80003696:	f34080e7          	jalr	-204(ra) # 800025c6 <wakeup>
  release(&tickslock);
    8000369a:	8526                	mv	a0,s1
    8000369c:	ffffd097          	auipc	ra,0xffffd
    800036a0:	600080e7          	jalr	1536(ra) # 80000c9c <release>
}
    800036a4:	60e2                	ld	ra,24(sp)
    800036a6:	6442                	ld	s0,16(sp)
    800036a8:	64a2                	ld	s1,8(sp)
    800036aa:	6105                	addi	sp,sp,32
    800036ac:	8082                	ret

00000000800036ae <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800036ae:	1101                	addi	sp,sp,-32
    800036b0:	ec06                	sd	ra,24(sp)
    800036b2:	e822                	sd	s0,16(sp)
    800036b4:	e426                	sd	s1,8(sp)
    800036b6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800036b8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800036bc:	00074d63          	bltz	a4,800036d6 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800036c0:	57fd                	li	a5,-1
    800036c2:	17fe                	slli	a5,a5,0x3f
    800036c4:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800036c6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800036c8:	06f70363          	beq	a4,a5,8000372e <devintr+0x80>
  }
}
    800036cc:	60e2                	ld	ra,24(sp)
    800036ce:	6442                	ld	s0,16(sp)
    800036d0:	64a2                	ld	s1,8(sp)
    800036d2:	6105                	addi	sp,sp,32
    800036d4:	8082                	ret
     (scause & 0xff) == 9){
    800036d6:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800036da:	46a5                	li	a3,9
    800036dc:	fed792e3          	bne	a5,a3,800036c0 <devintr+0x12>
    int irq = plic_claim();
    800036e0:	00003097          	auipc	ra,0x3
    800036e4:	7a8080e7          	jalr	1960(ra) # 80006e88 <plic_claim>
    800036e8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800036ea:	47a9                	li	a5,10
    800036ec:	02f50763          	beq	a0,a5,8000371a <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800036f0:	4785                	li	a5,1
    800036f2:	02f50963          	beq	a0,a5,80003724 <devintr+0x76>
    return 1;
    800036f6:	4505                	li	a0,1
    } else if(irq){
    800036f8:	d8f1                	beqz	s1,800036cc <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800036fa:	85a6                	mv	a1,s1
    800036fc:	00006517          	auipc	a0,0x6
    80003700:	d8c50513          	addi	a0,a0,-628 # 80009488 <states.0+0x28>
    80003704:	ffffd097          	auipc	ra,0xffffd
    80003708:	e74080e7          	jalr	-396(ra) # 80000578 <printf>
      plic_complete(irq);
    8000370c:	8526                	mv	a0,s1
    8000370e:	00003097          	auipc	ra,0x3
    80003712:	79e080e7          	jalr	1950(ra) # 80006eac <plic_complete>
    return 1;
    80003716:	4505                	li	a0,1
    80003718:	bf55                	j	800036cc <devintr+0x1e>
      uartintr();
    8000371a:	ffffd097          	auipc	ra,0xffffd
    8000371e:	270080e7          	jalr	624(ra) # 8000098a <uartintr>
    80003722:	b7ed                	j	8000370c <devintr+0x5e>
      virtio_disk_intr();
    80003724:	00004097          	auipc	ra,0x4
    80003728:	c1a080e7          	jalr	-998(ra) # 8000733e <virtio_disk_intr>
    8000372c:	b7c5                	j	8000370c <devintr+0x5e>
    if(cpuid() == 0){
    8000372e:	ffffe097          	auipc	ra,0xffffe
    80003732:	31a080e7          	jalr	794(ra) # 80001a48 <cpuid>
    80003736:	c901                	beqz	a0,80003746 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80003738:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000373c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000373e:	14479073          	csrw	sip,a5
    return 2;
    80003742:	4509                	li	a0,2
    80003744:	b761                	j	800036cc <devintr+0x1e>
      clockintr();
    80003746:	00000097          	auipc	ra,0x0
    8000374a:	f22080e7          	jalr	-222(ra) # 80003668 <clockintr>
    8000374e:	b7ed                	j	80003738 <devintr+0x8a>

0000000080003750 <usertrap>:
{
    80003750:	1101                	addi	sp,sp,-32
    80003752:	ec06                	sd	ra,24(sp)
    80003754:	e822                	sd	s0,16(sp)
    80003756:	e426                	sd	s1,8(sp)
    80003758:	e04a                	sd	s2,0(sp)
    8000375a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000375c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003760:	1007f793          	andi	a5,a5,256
    80003764:	e3dd                	bnez	a5,8000380a <usertrap+0xba>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003766:	00003797          	auipc	a5,0x3
    8000376a:	61a78793          	addi	a5,a5,1562 # 80006d80 <kernelvec>
    8000376e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003772:	ffffe097          	auipc	ra,0xffffe
    80003776:	30a080e7          	jalr	778(ra) # 80001a7c <myproc>
    8000377a:	84aa                	mv	s1,a0
  struct kthread *t = mykthread();
    8000377c:	ffffe097          	auipc	ra,0xffffe
    80003780:	340080e7          	jalr	832(ra) # 80001abc <mykthread>
    80003784:	892a                	mv	s2,a0
  t->trapframe->epc = r_sepc();
    80003786:	613c                	ld	a5,64(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003788:	14102773          	csrr	a4,sepc
    8000378c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000378e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80003792:	47a1                	li	a5,8
    80003794:	08f71f63          	bne	a4,a5,80003832 <usertrap+0xe2>
    if(t->killed == 1)
    80003798:	5518                	lw	a4,40(a0)
    8000379a:	4785                	li	a5,1
    8000379c:	06f70f63          	beq	a4,a5,8000381a <usertrap+0xca>
    else if(p->killed)
    800037a0:	4cdc                	lw	a5,28(s1)
    800037a2:	e3d1                	bnez	a5,80003826 <usertrap+0xd6>
    t->trapframe->epc += 4;
    800037a4:	04093703          	ld	a4,64(s2)
    800037a8:	6f1c                	ld	a5,24(a4)
    800037aa:	0791                	addi	a5,a5,4
    800037ac:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800037ae:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800037b2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800037b6:	10079073          	csrw	sstatus,a5
    syscall();
    800037ba:	00000097          	auipc	ra,0x0
    800037be:	38a080e7          	jalr	906(ra) # 80003b44 <syscall>
  if(holding(&p->lock))
    800037c2:	8526                	mv	a0,s1
    800037c4:	ffffd097          	auipc	ra,0xffffd
    800037c8:	388080e7          	jalr	904(ra) # 80000b4c <holding>
    800037cc:	e95d                	bnez	a0,80003882 <usertrap+0x132>
  acquire(&p->lock);
    800037ce:	8526                	mv	a0,s1
    800037d0:	ffffd097          	auipc	ra,0xffffd
    800037d4:	3f6080e7          	jalr	1014(ra) # 80000bc6 <acquire>
  if(!p->handling_sig_flag){
    800037d8:	2844a783          	lw	a5,644(s1)
    800037dc:	cfc5                	beqz	a5,80003894 <usertrap+0x144>
  release(&p->lock);
    800037de:	8526                	mv	a0,s1
    800037e0:	ffffd097          	auipc	ra,0xffffd
    800037e4:	4bc080e7          	jalr	1212(ra) # 80000c9c <release>
  if(t->killed == 1)
    800037e8:	02892703          	lw	a4,40(s2)
    800037ec:	4785                	li	a5,1
    800037ee:	0cf70863          	beq	a4,a5,800038be <usertrap+0x16e>
  else if(p->killed)
    800037f2:	4cdc                	lw	a5,28(s1)
    800037f4:	ebf9                	bnez	a5,800038ca <usertrap+0x17a>
  usertrapret();
    800037f6:	00000097          	auipc	ra,0x0
    800037fa:	d96080e7          	jalr	-618(ra) # 8000358c <usertrapret>
}
    800037fe:	60e2                	ld	ra,24(sp)
    80003800:	6442                	ld	s0,16(sp)
    80003802:	64a2                	ld	s1,8(sp)
    80003804:	6902                	ld	s2,0(sp)
    80003806:	6105                	addi	sp,sp,32
    80003808:	8082                	ret
    panic("usertrap: not from user mode");
    8000380a:	00006517          	auipc	a0,0x6
    8000380e:	c9e50513          	addi	a0,a0,-866 # 800094a8 <states.0+0x48>
    80003812:	ffffd097          	auipc	ra,0xffffd
    80003816:	d1c080e7          	jalr	-740(ra) # 8000052e <panic>
      kthread_exit(-1); // Kill current thread
    8000381a:	557d                	li	a0,-1
    8000381c:	fffff097          	auipc	ra,0xfffff
    80003820:	ff6080e7          	jalr	-10(ra) # 80002812 <kthread_exit>
    80003824:	b741                	j	800037a4 <usertrap+0x54>
      exit(-1); // Kill the hole procces
    80003826:	557d                	li	a0,-1
    80003828:	fffff097          	auipc	ra,0xfffff
    8000382c:	0f0080e7          	jalr	240(ra) # 80002918 <exit>
    80003830:	bf95                	j	800037a4 <usertrap+0x54>
  else if((which_dev = devintr()) != 0)
    80003832:	00000097          	auipc	ra,0x0
    80003836:	e7c080e7          	jalr	-388(ra) # 800036ae <devintr>
    8000383a:	c909                	beqz	a0,8000384c <usertrap+0xfc>
  if(which_dev == 2)
    8000383c:	4789                	li	a5,2
    8000383e:	f8f512e3          	bne	a0,a5,800037c2 <usertrap+0x72>
    yield();
    80003842:	fffff097          	auipc	ra,0xfffff
    80003846:	b86080e7          	jalr	-1146(ra) # 800023c8 <yield>
    8000384a:	bfa5                	j	800037c2 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000384c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003850:	50d0                	lw	a2,36(s1)
    80003852:	00006517          	auipc	a0,0x6
    80003856:	c7650513          	addi	a0,a0,-906 # 800094c8 <states.0+0x68>
    8000385a:	ffffd097          	auipc	ra,0xffffd
    8000385e:	d1e080e7          	jalr	-738(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003862:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003866:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000386a:	00006517          	auipc	a0,0x6
    8000386e:	c8e50513          	addi	a0,a0,-882 # 800094f8 <states.0+0x98>
    80003872:	ffffd097          	auipc	ra,0xffffd
    80003876:	d06080e7          	jalr	-762(ra) # 80000578 <printf>
    t->killed = 1;
    8000387a:	4785                	li	a5,1
    8000387c:	02f92423          	sw	a5,40(s2)
  if(which_dev == 2)
    80003880:	b789                	j	800037c2 <usertrap+0x72>
    printf("fuck i am holding the lock in usertrap\n");   // TODO : delete
    80003882:	00006517          	auipc	a0,0x6
    80003886:	c9650513          	addi	a0,a0,-874 # 80009518 <states.0+0xb8>
    8000388a:	ffffd097          	auipc	ra,0xffffd
    8000388e:	cee080e7          	jalr	-786(ra) # 80000578 <printf>
    80003892:	bf35                	j	800037ce <usertrap+0x7e>
    p->handling_sig_flag = 1;
    80003894:	4785                	li	a5,1
    80003896:	28f4a223          	sw	a5,644(s1)
    release(&p->lock);
    8000389a:	8526                	mv	a0,s1
    8000389c:	ffffd097          	auipc	ra,0xffffd
    800038a0:	400080e7          	jalr	1024(ra) # 80000c9c <release>
    check_pending_signals(p);
    800038a4:	8526                	mv	a0,s1
    800038a6:	00000097          	auipc	ra,0x0
    800038aa:	b6c080e7          	jalr	-1172(ra) # 80003412 <check_pending_signals>
    acquire(&p->lock);
    800038ae:	8526                	mv	a0,s1
    800038b0:	ffffd097          	auipc	ra,0xffffd
    800038b4:	316080e7          	jalr	790(ra) # 80000bc6 <acquire>
    p->handling_sig_flag = 0;
    800038b8:	2804a223          	sw	zero,644(s1)
    800038bc:	b70d                	j	800037de <usertrap+0x8e>
    kthread_exit(-1); // Kill current thread
    800038be:	557d                	li	a0,-1
    800038c0:	fffff097          	auipc	ra,0xfffff
    800038c4:	f52080e7          	jalr	-174(ra) # 80002812 <kthread_exit>
    800038c8:	b73d                	j	800037f6 <usertrap+0xa6>
    exit(-1); // Kill the hole procces
    800038ca:	557d                	li	a0,-1
    800038cc:	fffff097          	auipc	ra,0xfffff
    800038d0:	04c080e7          	jalr	76(ra) # 80002918 <exit>
    800038d4:	b70d                	j	800037f6 <usertrap+0xa6>

00000000800038d6 <kerneltrap>:
{
    800038d6:	7179                	addi	sp,sp,-48
    800038d8:	f406                	sd	ra,40(sp)
    800038da:	f022                	sd	s0,32(sp)
    800038dc:	ec26                	sd	s1,24(sp)
    800038de:	e84a                	sd	s2,16(sp)
    800038e0:	e44e                	sd	s3,8(sp)
    800038e2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800038e4:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800038e8:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800038ec:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800038f0:	1004f793          	andi	a5,s1,256
    800038f4:	cb85                	beqz	a5,80003924 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800038f6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800038fa:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800038fc:	ef85                	bnez	a5,80003934 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800038fe:	00000097          	auipc	ra,0x0
    80003902:	db0080e7          	jalr	-592(ra) # 800036ae <devintr>
    80003906:	cd1d                	beqz	a0,80003944 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    80003908:	4789                	li	a5,2
    8000390a:	08f50763          	beq	a0,a5,80003998 <kerneltrap+0xc2>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000390e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003912:	10049073          	csrw	sstatus,s1
}
    80003916:	70a2                	ld	ra,40(sp)
    80003918:	7402                	ld	s0,32(sp)
    8000391a:	64e2                	ld	s1,24(sp)
    8000391c:	6942                	ld	s2,16(sp)
    8000391e:	69a2                	ld	s3,8(sp)
    80003920:	6145                	addi	sp,sp,48
    80003922:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003924:	00006517          	auipc	a0,0x6
    80003928:	c1c50513          	addi	a0,a0,-996 # 80009540 <states.0+0xe0>
    8000392c:	ffffd097          	auipc	ra,0xffffd
    80003930:	c02080e7          	jalr	-1022(ra) # 8000052e <panic>
    panic("kerneltrap: interrupts enabled");
    80003934:	00006517          	auipc	a0,0x6
    80003938:	c3450513          	addi	a0,a0,-972 # 80009568 <states.0+0x108>
    8000393c:	ffffd097          	auipc	ra,0xffffd
    80003940:	bf2080e7          	jalr	-1038(ra) # 8000052e <panic>
    printf("thread %d recieved kernel trap\n",mykthread()->tid);
    80003944:	ffffe097          	auipc	ra,0xffffe
    80003948:	178080e7          	jalr	376(ra) # 80001abc <mykthread>
    8000394c:	590c                	lw	a1,48(a0)
    8000394e:	00006517          	auipc	a0,0x6
    80003952:	c3a50513          	addi	a0,a0,-966 # 80009588 <states.0+0x128>
    80003956:	ffffd097          	auipc	ra,0xffffd
    8000395a:	c22080e7          	jalr	-990(ra) # 80000578 <printf>
    printf("scause %p\n", scause);
    8000395e:	85ce                	mv	a1,s3
    80003960:	00006517          	auipc	a0,0x6
    80003964:	c4850513          	addi	a0,a0,-952 # 800095a8 <states.0+0x148>
    80003968:	ffffd097          	auipc	ra,0xffffd
    8000396c:	c10080e7          	jalr	-1008(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003970:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003974:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003978:	00006517          	auipc	a0,0x6
    8000397c:	c4050513          	addi	a0,a0,-960 # 800095b8 <states.0+0x158>
    80003980:	ffffd097          	auipc	ra,0xffffd
    80003984:	bf8080e7          	jalr	-1032(ra) # 80000578 <printf>
    panic("kerneltrap");
    80003988:	00006517          	auipc	a0,0x6
    8000398c:	c4850513          	addi	a0,a0,-952 # 800095d0 <states.0+0x170>
    80003990:	ffffd097          	auipc	ra,0xffffd
    80003994:	b9e080e7          	jalr	-1122(ra) # 8000052e <panic>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    80003998:	ffffe097          	auipc	ra,0xffffe
    8000399c:	0e4080e7          	jalr	228(ra) # 80001a7c <myproc>
    800039a0:	d53d                	beqz	a0,8000390e <kerneltrap+0x38>
    800039a2:	ffffe097          	auipc	ra,0xffffe
    800039a6:	11a080e7          	jalr	282(ra) # 80001abc <mykthread>
    800039aa:	d135                	beqz	a0,8000390e <kerneltrap+0x38>
    800039ac:	ffffe097          	auipc	ra,0xffffe
    800039b0:	110080e7          	jalr	272(ra) # 80001abc <mykthread>
    800039b4:	4d18                	lw	a4,24(a0)
    800039b6:	4791                	li	a5,4
    800039b8:	f4f71be3          	bne	a4,a5,8000390e <kerneltrap+0x38>
    yield();
    800039bc:	fffff097          	auipc	ra,0xfffff
    800039c0:	a0c080e7          	jalr	-1524(ra) # 800023c8 <yield>
    800039c4:	b7a9                	j	8000390e <kerneltrap+0x38>

00000000800039c6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800039c6:	1101                	addi	sp,sp,-32
    800039c8:	ec06                	sd	ra,24(sp)
    800039ca:	e822                	sd	s0,16(sp)
    800039cc:	e426                	sd	s1,8(sp)
    800039ce:	1000                	addi	s0,sp,32
    800039d0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800039d2:	ffffe097          	auipc	ra,0xffffe
    800039d6:	0aa080e7          	jalr	170(ra) # 80001a7c <myproc>
  struct kthread *t = mykthread();
    800039da:	ffffe097          	auipc	ra,0xffffe
    800039de:	0e2080e7          	jalr	226(ra) # 80001abc <mykthread>
  switch (n) {
    800039e2:	4795                	li	a5,5
    800039e4:	0497e163          	bltu	a5,s1,80003a26 <argraw+0x60>
    800039e8:	048a                	slli	s1,s1,0x2
    800039ea:	00006717          	auipc	a4,0x6
    800039ee:	c1e70713          	addi	a4,a4,-994 # 80009608 <states.0+0x1a8>
    800039f2:	94ba                	add	s1,s1,a4
    800039f4:	409c                	lw	a5,0(s1)
    800039f6:	97ba                	add	a5,a5,a4
    800039f8:	8782                	jr	a5
  case 0:
    return t->trapframe->a0;
    800039fa:	613c                	ld	a5,64(a0)
    800039fc:	7ba8                	ld	a0,112(a5)
  case 5:
    return t->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800039fe:	60e2                	ld	ra,24(sp)
    80003a00:	6442                	ld	s0,16(sp)
    80003a02:	64a2                	ld	s1,8(sp)
    80003a04:	6105                	addi	sp,sp,32
    80003a06:	8082                	ret
    return t->trapframe->a1;
    80003a08:	613c                	ld	a5,64(a0)
    80003a0a:	7fa8                	ld	a0,120(a5)
    80003a0c:	bfcd                	j	800039fe <argraw+0x38>
    return t->trapframe->a2;
    80003a0e:	613c                	ld	a5,64(a0)
    80003a10:	63c8                	ld	a0,128(a5)
    80003a12:	b7f5                	j	800039fe <argraw+0x38>
    return t->trapframe->a3;
    80003a14:	613c                	ld	a5,64(a0)
    80003a16:	67c8                	ld	a0,136(a5)
    80003a18:	b7dd                	j	800039fe <argraw+0x38>
    return t->trapframe->a4;
    80003a1a:	613c                	ld	a5,64(a0)
    80003a1c:	6bc8                	ld	a0,144(a5)
    80003a1e:	b7c5                	j	800039fe <argraw+0x38>
    return t->trapframe->a5;
    80003a20:	613c                	ld	a5,64(a0)
    80003a22:	6fc8                	ld	a0,152(a5)
    80003a24:	bfe9                	j	800039fe <argraw+0x38>
  panic("argraw");
    80003a26:	00006517          	auipc	a0,0x6
    80003a2a:	bba50513          	addi	a0,a0,-1094 # 800095e0 <states.0+0x180>
    80003a2e:	ffffd097          	auipc	ra,0xffffd
    80003a32:	b00080e7          	jalr	-1280(ra) # 8000052e <panic>

0000000080003a36 <fetchaddr>:
{
    80003a36:	1101                	addi	sp,sp,-32
    80003a38:	ec06                	sd	ra,24(sp)
    80003a3a:	e822                	sd	s0,16(sp)
    80003a3c:	e426                	sd	s1,8(sp)
    80003a3e:	e04a                	sd	s2,0(sp)
    80003a40:	1000                	addi	s0,sp,32
    80003a42:	84aa                	mv	s1,a0
    80003a44:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003a46:	ffffe097          	auipc	ra,0xffffe
    80003a4a:	036080e7          	jalr	54(ra) # 80001a7c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003a4e:	7d1c                	ld	a5,56(a0)
    80003a50:	02f4f863          	bgeu	s1,a5,80003a80 <fetchaddr+0x4a>
    80003a54:	00848713          	addi	a4,s1,8
    80003a58:	02e7e663          	bltu	a5,a4,80003a84 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003a5c:	46a1                	li	a3,8
    80003a5e:	8626                	mv	a2,s1
    80003a60:	85ca                	mv	a1,s2
    80003a62:	6128                	ld	a0,64(a0)
    80003a64:	ffffe097          	auipc	ra,0xffffe
    80003a68:	c8c080e7          	jalr	-884(ra) # 800016f0 <copyin>
    80003a6c:	00a03533          	snez	a0,a0
    80003a70:	40a00533          	neg	a0,a0
}
    80003a74:	60e2                	ld	ra,24(sp)
    80003a76:	6442                	ld	s0,16(sp)
    80003a78:	64a2                	ld	s1,8(sp)
    80003a7a:	6902                	ld	s2,0(sp)
    80003a7c:	6105                	addi	sp,sp,32
    80003a7e:	8082                	ret
    return -1;
    80003a80:	557d                	li	a0,-1
    80003a82:	bfcd                	j	80003a74 <fetchaddr+0x3e>
    80003a84:	557d                	li	a0,-1
    80003a86:	b7fd                	j	80003a74 <fetchaddr+0x3e>

0000000080003a88 <fetchstr>:
{
    80003a88:	7179                	addi	sp,sp,-48
    80003a8a:	f406                	sd	ra,40(sp)
    80003a8c:	f022                	sd	s0,32(sp)
    80003a8e:	ec26                	sd	s1,24(sp)
    80003a90:	e84a                	sd	s2,16(sp)
    80003a92:	e44e                	sd	s3,8(sp)
    80003a94:	1800                	addi	s0,sp,48
    80003a96:	892a                	mv	s2,a0
    80003a98:	84ae                	mv	s1,a1
    80003a9a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003a9c:	ffffe097          	auipc	ra,0xffffe
    80003aa0:	fe0080e7          	jalr	-32(ra) # 80001a7c <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003aa4:	86ce                	mv	a3,s3
    80003aa6:	864a                	mv	a2,s2
    80003aa8:	85a6                	mv	a1,s1
    80003aaa:	6128                	ld	a0,64(a0)
    80003aac:	ffffe097          	auipc	ra,0xffffe
    80003ab0:	cd2080e7          	jalr	-814(ra) # 8000177e <copyinstr>
  if(err < 0)
    80003ab4:	00054763          	bltz	a0,80003ac2 <fetchstr+0x3a>
  return strlen(buf);
    80003ab8:	8526                	mv	a0,s1
    80003aba:	ffffd097          	auipc	ra,0xffffd
    80003abe:	3ae080e7          	jalr	942(ra) # 80000e68 <strlen>
}
    80003ac2:	70a2                	ld	ra,40(sp)
    80003ac4:	7402                	ld	s0,32(sp)
    80003ac6:	64e2                	ld	s1,24(sp)
    80003ac8:	6942                	ld	s2,16(sp)
    80003aca:	69a2                	ld	s3,8(sp)
    80003acc:	6145                	addi	sp,sp,48
    80003ace:	8082                	ret

0000000080003ad0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003ad0:	1101                	addi	sp,sp,-32
    80003ad2:	ec06                	sd	ra,24(sp)
    80003ad4:	e822                	sd	s0,16(sp)
    80003ad6:	e426                	sd	s1,8(sp)
    80003ad8:	1000                	addi	s0,sp,32
    80003ada:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003adc:	00000097          	auipc	ra,0x0
    80003ae0:	eea080e7          	jalr	-278(ra) # 800039c6 <argraw>
    80003ae4:	c088                	sw	a0,0(s1)
  return 0;
}
    80003ae6:	4501                	li	a0,0
    80003ae8:	60e2                	ld	ra,24(sp)
    80003aea:	6442                	ld	s0,16(sp)
    80003aec:	64a2                	ld	s1,8(sp)
    80003aee:	6105                	addi	sp,sp,32
    80003af0:	8082                	ret

0000000080003af2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003af2:	1101                	addi	sp,sp,-32
    80003af4:	ec06                	sd	ra,24(sp)
    80003af6:	e822                	sd	s0,16(sp)
    80003af8:	e426                	sd	s1,8(sp)
    80003afa:	1000                	addi	s0,sp,32
    80003afc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003afe:	00000097          	auipc	ra,0x0
    80003b02:	ec8080e7          	jalr	-312(ra) # 800039c6 <argraw>
    80003b06:	e088                	sd	a0,0(s1)
  return 0;
}
    80003b08:	4501                	li	a0,0
    80003b0a:	60e2                	ld	ra,24(sp)
    80003b0c:	6442                	ld	s0,16(sp)
    80003b0e:	64a2                	ld	s1,8(sp)
    80003b10:	6105                	addi	sp,sp,32
    80003b12:	8082                	ret

0000000080003b14 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003b14:	1101                	addi	sp,sp,-32
    80003b16:	ec06                	sd	ra,24(sp)
    80003b18:	e822                	sd	s0,16(sp)
    80003b1a:	e426                	sd	s1,8(sp)
    80003b1c:	e04a                	sd	s2,0(sp)
    80003b1e:	1000                	addi	s0,sp,32
    80003b20:	84ae                	mv	s1,a1
    80003b22:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003b24:	00000097          	auipc	ra,0x0
    80003b28:	ea2080e7          	jalr	-350(ra) # 800039c6 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003b2c:	864a                	mv	a2,s2
    80003b2e:	85a6                	mv	a1,s1
    80003b30:	00000097          	auipc	ra,0x0
    80003b34:	f58080e7          	jalr	-168(ra) # 80003a88 <fetchstr>
}
    80003b38:	60e2                	ld	ra,24(sp)
    80003b3a:	6442                	ld	s0,16(sp)
    80003b3c:	64a2                	ld	s1,8(sp)
    80003b3e:	6902                	ld	s2,0(sp)
    80003b40:	6105                	addi	sp,sp,32
    80003b42:	8082                	ret

0000000080003b44 <syscall>:
[SYS_kthread_join] sys_kthread_join,
};

void
syscall(void)
{
    80003b44:	7179                	addi	sp,sp,-48
    80003b46:	f406                	sd	ra,40(sp)
    80003b48:	f022                	sd	s0,32(sp)
    80003b4a:	ec26                	sd	s1,24(sp)
    80003b4c:	e84a                	sd	s2,16(sp)
    80003b4e:	e44e                	sd	s3,8(sp)
    80003b50:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80003b52:	ffffe097          	auipc	ra,0xffffe
    80003b56:	f2a080e7          	jalr	-214(ra) # 80001a7c <myproc>
    80003b5a:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80003b5c:	ffffe097          	auipc	ra,0xffffe
    80003b60:	f60080e7          	jalr	-160(ra) # 80001abc <mykthread>
    80003b64:	84aa                	mv	s1,a0

  num = t->trapframe->a7;
    80003b66:	04053983          	ld	s3,64(a0)
    80003b6a:	0a89b783          	ld	a5,168(s3)
    80003b6e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003b72:	37fd                	addiw	a5,a5,-1
    80003b74:	476d                	li	a4,27
    80003b76:	00f76f63          	bltu	a4,a5,80003b94 <syscall+0x50>
    80003b7a:	00369713          	slli	a4,a3,0x3
    80003b7e:	00006797          	auipc	a5,0x6
    80003b82:	aa278793          	addi	a5,a5,-1374 # 80009620 <syscalls>
    80003b86:	97ba                	add	a5,a5,a4
    80003b88:	639c                	ld	a5,0(a5)
    80003b8a:	c789                	beqz	a5,80003b94 <syscall+0x50>
    t->trapframe->a0 = syscalls[num]();
    80003b8c:	9782                	jalr	a5
    80003b8e:	06a9b823          	sd	a0,112(s3)
    80003b92:	a005                	j	80003bb2 <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003b94:	0d890613          	addi	a2,s2,216
    80003b98:	02492583          	lw	a1,36(s2)
    80003b9c:	00006517          	auipc	a0,0x6
    80003ba0:	a4c50513          	addi	a0,a0,-1460 # 800095e8 <states.0+0x188>
    80003ba4:	ffffd097          	auipc	ra,0xffffd
    80003ba8:	9d4080e7          	jalr	-1580(ra) # 80000578 <printf>
            p->pid, p->name, num);
    t->trapframe->a0 = -1;
    80003bac:	60bc                	ld	a5,64(s1)
    80003bae:	577d                	li	a4,-1
    80003bb0:	fbb8                	sd	a4,112(a5)
  }
}
    80003bb2:	70a2                	ld	ra,40(sp)
    80003bb4:	7402                	ld	s0,32(sp)
    80003bb6:	64e2                	ld	s1,24(sp)
    80003bb8:	6942                	ld	s2,16(sp)
    80003bba:	69a2                	ld	s3,8(sp)
    80003bbc:	6145                	addi	sp,sp,48
    80003bbe:	8082                	ret

0000000080003bc0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003bc0:	1101                	addi	sp,sp,-32
    80003bc2:	ec06                	sd	ra,24(sp)
    80003bc4:	e822                	sd	s0,16(sp)
    80003bc6:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003bc8:	fec40593          	addi	a1,s0,-20
    80003bcc:	4501                	li	a0,0
    80003bce:	00000097          	auipc	ra,0x0
    80003bd2:	f02080e7          	jalr	-254(ra) # 80003ad0 <argint>
    return -1;
    80003bd6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003bd8:	00054963          	bltz	a0,80003bea <sys_exit+0x2a>
  exit(n);
    80003bdc:	fec42503          	lw	a0,-20(s0)
    80003be0:	fffff097          	auipc	ra,0xfffff
    80003be4:	d38080e7          	jalr	-712(ra) # 80002918 <exit>
  return 0;  // not reached
    80003be8:	4781                	li	a5,0
}
    80003bea:	853e                	mv	a0,a5
    80003bec:	60e2                	ld	ra,24(sp)
    80003bee:	6442                	ld	s0,16(sp)
    80003bf0:	6105                	addi	sp,sp,32
    80003bf2:	8082                	ret

0000000080003bf4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003bf4:	1141                	addi	sp,sp,-16
    80003bf6:	e406                	sd	ra,8(sp)
    80003bf8:	e022                	sd	s0,0(sp)
    80003bfa:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003bfc:	ffffe097          	auipc	ra,0xffffe
    80003c00:	e80080e7          	jalr	-384(ra) # 80001a7c <myproc>
}
    80003c04:	5148                	lw	a0,36(a0)
    80003c06:	60a2                	ld	ra,8(sp)
    80003c08:	6402                	ld	s0,0(sp)
    80003c0a:	0141                	addi	sp,sp,16
    80003c0c:	8082                	ret

0000000080003c0e <sys_fork>:

uint64
sys_fork(void)
{
    80003c0e:	1141                	addi	sp,sp,-16
    80003c10:	e406                	sd	ra,8(sp)
    80003c12:	e022                	sd	s0,0(sp)
    80003c14:	0800                	addi	s0,sp,16
  return fork();
    80003c16:	ffffe097          	auipc	ra,0xffffe
    80003c1a:	404080e7          	jalr	1028(ra) # 8000201a <fork>
}
    80003c1e:	60a2                	ld	ra,8(sp)
    80003c20:	6402                	ld	s0,0(sp)
    80003c22:	0141                	addi	sp,sp,16
    80003c24:	8082                	ret

0000000080003c26 <sys_wait>:

uint64
sys_wait(void)
{
    80003c26:	1101                	addi	sp,sp,-32
    80003c28:	ec06                	sd	ra,24(sp)
    80003c2a:	e822                	sd	s0,16(sp)
    80003c2c:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003c2e:	fe840593          	addi	a1,s0,-24
    80003c32:	4501                	li	a0,0
    80003c34:	00000097          	auipc	ra,0x0
    80003c38:	ebe080e7          	jalr	-322(ra) # 80003af2 <argaddr>
    80003c3c:	87aa                	mv	a5,a0
    return -1;
    80003c3e:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003c40:	0007c863          	bltz	a5,80003c50 <sys_wait+0x2a>
  return wait(p);
    80003c44:	fe843503          	ld	a0,-24(s0)
    80003c48:	fffff097          	auipc	ra,0xfffff
    80003c4c:	858080e7          	jalr	-1960(ra) # 800024a0 <wait>
}
    80003c50:	60e2                	ld	ra,24(sp)
    80003c52:	6442                	ld	s0,16(sp)
    80003c54:	6105                	addi	sp,sp,32
    80003c56:	8082                	ret

0000000080003c58 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003c58:	7179                	addi	sp,sp,-48
    80003c5a:	f406                	sd	ra,40(sp)
    80003c5c:	f022                	sd	s0,32(sp)
    80003c5e:	ec26                	sd	s1,24(sp)
    80003c60:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003c62:	fdc40593          	addi	a1,s0,-36
    80003c66:	4501                	li	a0,0
    80003c68:	00000097          	auipc	ra,0x0
    80003c6c:	e68080e7          	jalr	-408(ra) # 80003ad0 <argint>
    return -1;
    80003c70:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003c72:	00054f63          	bltz	a0,80003c90 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003c76:	ffffe097          	auipc	ra,0xffffe
    80003c7a:	e06080e7          	jalr	-506(ra) # 80001a7c <myproc>
    80003c7e:	5d04                	lw	s1,56(a0)
  if(growproc(n) < 0)
    80003c80:	fdc42503          	lw	a0,-36(s0)
    80003c84:	ffffe097          	auipc	ra,0xffffe
    80003c88:	322080e7          	jalr	802(ra) # 80001fa6 <growproc>
    80003c8c:	00054863          	bltz	a0,80003c9c <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003c90:	8526                	mv	a0,s1
    80003c92:	70a2                	ld	ra,40(sp)
    80003c94:	7402                	ld	s0,32(sp)
    80003c96:	64e2                	ld	s1,24(sp)
    80003c98:	6145                	addi	sp,sp,48
    80003c9a:	8082                	ret
    return -1;
    80003c9c:	54fd                	li	s1,-1
    80003c9e:	bfcd                	j	80003c90 <sys_sbrk+0x38>

0000000080003ca0 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003ca0:	7139                	addi	sp,sp,-64
    80003ca2:	fc06                	sd	ra,56(sp)
    80003ca4:	f822                	sd	s0,48(sp)
    80003ca6:	f426                	sd	s1,40(sp)
    80003ca8:	f04a                	sd	s2,32(sp)
    80003caa:	ec4e                	sd	s3,24(sp)
    80003cac:	e852                	sd	s4,16(sp)
    80003cae:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003cb0:	fcc40593          	addi	a1,s0,-52
    80003cb4:	4501                	li	a0,0
    80003cb6:	00000097          	auipc	ra,0x0
    80003cba:	e1a080e7          	jalr	-486(ra) # 80003ad0 <argint>
    return -1;
    80003cbe:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003cc0:	06054763          	bltz	a0,80003d2e <sys_sleep+0x8e>
  acquire(&tickslock);
    80003cc4:	00030517          	auipc	a0,0x30
    80003cc8:	c6450513          	addi	a0,a0,-924 # 80033928 <tickslock>
    80003ccc:	ffffd097          	auipc	ra,0xffffd
    80003cd0:	efa080e7          	jalr	-262(ra) # 80000bc6 <acquire>
  ticks0 = ticks;
    80003cd4:	00006997          	auipc	s3,0x6
    80003cd8:	35c9a983          	lw	s3,860(s3) # 8000a030 <ticks>
  while(ticks - ticks0 < n){
    80003cdc:	fcc42783          	lw	a5,-52(s0)
    80003ce0:	cf95                	beqz	a5,80003d1c <sys_sleep+0x7c>
    if(myproc()->killed==1){
    80003ce2:	4905                	li	s2,1
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003ce4:	00030a17          	auipc	s4,0x30
    80003ce8:	c44a0a13          	addi	s4,s4,-956 # 80033928 <tickslock>
    80003cec:	00006497          	auipc	s1,0x6
    80003cf0:	34448493          	addi	s1,s1,836 # 8000a030 <ticks>
    if(myproc()->killed==1){
    80003cf4:	ffffe097          	auipc	ra,0xffffe
    80003cf8:	d88080e7          	jalr	-632(ra) # 80001a7c <myproc>
    80003cfc:	4d5c                	lw	a5,28(a0)
    80003cfe:	05278163          	beq	a5,s2,80003d40 <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    80003d02:	85d2                	mv	a1,s4
    80003d04:	8526                	mv	a0,s1
    80003d06:	ffffe097          	auipc	ra,0xffffe
    80003d0a:	6fe080e7          	jalr	1790(ra) # 80002404 <sleep>
  while(ticks - ticks0 < n){
    80003d0e:	409c                	lw	a5,0(s1)
    80003d10:	413787bb          	subw	a5,a5,s3
    80003d14:	fcc42703          	lw	a4,-52(s0)
    80003d18:	fce7eee3          	bltu	a5,a4,80003cf4 <sys_sleep+0x54>
  }
  release(&tickslock);
    80003d1c:	00030517          	auipc	a0,0x30
    80003d20:	c0c50513          	addi	a0,a0,-1012 # 80033928 <tickslock>
    80003d24:	ffffd097          	auipc	ra,0xffffd
    80003d28:	f78080e7          	jalr	-136(ra) # 80000c9c <release>
  return 0;
    80003d2c:	4781                	li	a5,0
}
    80003d2e:	853e                	mv	a0,a5
    80003d30:	70e2                	ld	ra,56(sp)
    80003d32:	7442                	ld	s0,48(sp)
    80003d34:	74a2                	ld	s1,40(sp)
    80003d36:	7902                	ld	s2,32(sp)
    80003d38:	69e2                	ld	s3,24(sp)
    80003d3a:	6a42                	ld	s4,16(sp)
    80003d3c:	6121                	addi	sp,sp,64
    80003d3e:	8082                	ret
      release(&tickslock);
    80003d40:	00030517          	auipc	a0,0x30
    80003d44:	be850513          	addi	a0,a0,-1048 # 80033928 <tickslock>
    80003d48:	ffffd097          	auipc	ra,0xffffd
    80003d4c:	f54080e7          	jalr	-172(ra) # 80000c9c <release>
      return -1;
    80003d50:	57fd                	li	a5,-1
    80003d52:	bff1                	j	80003d2e <sys_sleep+0x8e>

0000000080003d54 <sys_kill>:

uint64
sys_kill(void)
{
    80003d54:	1101                	addi	sp,sp,-32
    80003d56:	ec06                	sd	ra,24(sp)
    80003d58:	e822                	sd	s0,16(sp)
    80003d5a:	1000                	addi	s0,sp,32
  int pid;
  int signum;

  if(argint(0, &pid) < 0)
    80003d5c:	fec40593          	addi	a1,s0,-20
    80003d60:	4501                	li	a0,0
    80003d62:	00000097          	auipc	ra,0x0
    80003d66:	d6e080e7          	jalr	-658(ra) # 80003ad0 <argint>
    80003d6a:	87aa                	mv	a5,a0
    return -1;
    80003d6c:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003d6e:	0207c963          	bltz	a5,80003da0 <sys_kill+0x4c>
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003d72:	fe840593          	addi	a1,s0,-24
    80003d76:	4505                	li	a0,1
    80003d78:	00000097          	auipc	ra,0x0
    80003d7c:	d58080e7          	jalr	-680(ra) # 80003ad0 <argint>
    80003d80:	02054463          	bltz	a0,80003da8 <sys_kill+0x54>
    80003d84:	fe842583          	lw	a1,-24(s0)
    80003d88:	0005871b          	sext.w	a4,a1
    80003d8c:	47fd                	li	a5,31
    return -1;
    80003d8e:	557d                	li	a0,-1
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003d90:	00e7e863          	bltu	a5,a4,80003da0 <sys_kill+0x4c>
  return kill(pid, signum);
    80003d94:	fec42503          	lw	a0,-20(s0)
    80003d98:	fffff097          	auipc	ra,0xfffff
    80003d9c:	fcc080e7          	jalr	-52(ra) # 80002d64 <kill>
}
    80003da0:	60e2                	ld	ra,24(sp)
    80003da2:	6442                	ld	s0,16(sp)
    80003da4:	6105                	addi	sp,sp,32
    80003da6:	8082                	ret
    return -1;
    80003da8:	557d                	li	a0,-1
    80003daa:	bfdd                	j	80003da0 <sys_kill+0x4c>

0000000080003dac <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003dac:	1101                	addi	sp,sp,-32
    80003dae:	ec06                	sd	ra,24(sp)
    80003db0:	e822                	sd	s0,16(sp)
    80003db2:	e426                	sd	s1,8(sp)
    80003db4:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003db6:	00030517          	auipc	a0,0x30
    80003dba:	b7250513          	addi	a0,a0,-1166 # 80033928 <tickslock>
    80003dbe:	ffffd097          	auipc	ra,0xffffd
    80003dc2:	e08080e7          	jalr	-504(ra) # 80000bc6 <acquire>
  xticks = ticks;
    80003dc6:	00006497          	auipc	s1,0x6
    80003dca:	26a4a483          	lw	s1,618(s1) # 8000a030 <ticks>
  release(&tickslock);
    80003dce:	00030517          	auipc	a0,0x30
    80003dd2:	b5a50513          	addi	a0,a0,-1190 # 80033928 <tickslock>
    80003dd6:	ffffd097          	auipc	ra,0xffffd
    80003dda:	ec6080e7          	jalr	-314(ra) # 80000c9c <release>
  return xticks;
}
    80003dde:	02049513          	slli	a0,s1,0x20
    80003de2:	9101                	srli	a0,a0,0x20
    80003de4:	60e2                	ld	ra,24(sp)
    80003de6:	6442                	ld	s0,16(sp)
    80003de8:	64a2                	ld	s1,8(sp)
    80003dea:	6105                	addi	sp,sp,32
    80003dec:	8082                	ret

0000000080003dee <sys_sigprocmask>:

uint64
sys_sigprocmask(void)
{
    80003dee:	1101                	addi	sp,sp,-32
    80003df0:	ec06                	sd	ra,24(sp)
    80003df2:	e822                	sd	s0,16(sp)
    80003df4:	1000                	addi	s0,sp,32
  int sigmask;

  if(argint(0, &sigmask) < 0)
    80003df6:	fec40593          	addi	a1,s0,-20
    80003dfa:	4501                	li	a0,0
    80003dfc:	00000097          	auipc	ra,0x0
    80003e00:	cd4080e7          	jalr	-812(ra) # 80003ad0 <argint>
    80003e04:	87aa                	mv	a5,a0
    return -1;
    80003e06:	557d                	li	a0,-1
  if(argint(0, &sigmask) < 0)
    80003e08:	0007ca63          	bltz	a5,80003e1c <sys_sigprocmask+0x2e>
  return sigprocmask((uint)sigmask);
    80003e0c:	fec42503          	lw	a0,-20(s0)
    80003e10:	fffff097          	auipc	ra,0xfffff
    80003e14:	d82080e7          	jalr	-638(ra) # 80002b92 <sigprocmask>
    80003e18:	1502                	slli	a0,a0,0x20
    80003e1a:	9101                	srli	a0,a0,0x20
}
    80003e1c:	60e2                	ld	ra,24(sp)
    80003e1e:	6442                	ld	s0,16(sp)
    80003e20:	6105                	addi	sp,sp,32
    80003e22:	8082                	ret

0000000080003e24 <sys_sigaction>:

uint64
sys_sigaction(void)
{
    80003e24:	7179                	addi	sp,sp,-48
    80003e26:	f406                	sd	ra,40(sp)
    80003e28:	f022                	sd	s0,32(sp)
    80003e2a:	1800                	addi	s0,sp,48
  int signum;
  uint64 newact;
  uint64 oldact;
  
  if(argint(0, &signum) < 0)
    80003e2c:	fec40593          	addi	a1,s0,-20
    80003e30:	4501                	li	a0,0
    80003e32:	00000097          	auipc	ra,0x0
    80003e36:	c9e080e7          	jalr	-866(ra) # 80003ad0 <argint>
    return -1;
    80003e3a:	57fd                	li	a5,-1
  if(argint(0, &signum) < 0)
    80003e3c:	04054163          	bltz	a0,80003e7e <sys_sigaction+0x5a>
  if(argaddr(1, &newact) < 0)
    80003e40:	fe040593          	addi	a1,s0,-32
    80003e44:	4505                	li	a0,1
    80003e46:	00000097          	auipc	ra,0x0
    80003e4a:	cac080e7          	jalr	-852(ra) # 80003af2 <argaddr>
    return -1;
    80003e4e:	57fd                	li	a5,-1
  if(argaddr(1, &newact) < 0)
    80003e50:	02054763          	bltz	a0,80003e7e <sys_sigaction+0x5a>
  if(argaddr(2, &oldact) < 0)
    80003e54:	fd840593          	addi	a1,s0,-40
    80003e58:	4509                	li	a0,2
    80003e5a:	00000097          	auipc	ra,0x0
    80003e5e:	c98080e7          	jalr	-872(ra) # 80003af2 <argaddr>
    return -1;
    80003e62:	57fd                	li	a5,-1
  if(argaddr(2, &oldact) < 0)
    80003e64:	00054d63          	bltz	a0,80003e7e <sys_sigaction+0x5a>

  return sigaction(signum,newact,oldact);
    80003e68:	fd843603          	ld	a2,-40(s0)
    80003e6c:	fe043583          	ld	a1,-32(s0)
    80003e70:	fec42503          	lw	a0,-20(s0)
    80003e74:	fffff097          	auipc	ra,0xfffff
    80003e78:	d72080e7          	jalr	-654(ra) # 80002be6 <sigaction>
    80003e7c:	87aa                	mv	a5,a0
  
}
    80003e7e:	853e                	mv	a0,a5
    80003e80:	70a2                	ld	ra,40(sp)
    80003e82:	7402                	ld	s0,32(sp)
    80003e84:	6145                	addi	sp,sp,48
    80003e86:	8082                	ret

0000000080003e88 <sys_sigret>:
uint64
sys_sigret(void)
{
    80003e88:	1141                	addi	sp,sp,-16
    80003e8a:	e406                	sd	ra,8(sp)
    80003e8c:	e022                	sd	s0,0(sp)
    80003e8e:	0800                	addi	s0,sp,16
  sigret();
    80003e90:	fffff097          	auipc	ra,0xfffff
    80003e94:	e40080e7          	jalr	-448(ra) # 80002cd0 <sigret>
  return 0;
}
    80003e98:	4501                	li	a0,0
    80003e9a:	60a2                	ld	ra,8(sp)
    80003e9c:	6402                	ld	s0,0(sp)
    80003e9e:	0141                	addi	sp,sp,16
    80003ea0:	8082                	ret

0000000080003ea2 <sys_kthread_create>:

uint64
sys_kthread_create(void)
{
    80003ea2:	1101                	addi	sp,sp,-32
    80003ea4:	ec06                	sd	ra,24(sp)
    80003ea6:	e822                	sd	s0,16(sp)
    80003ea8:	1000                	addi	s0,sp,32
  uint64 start_func;
  uint64 stack;
  if(argaddr(0, &start_func) < 0)
    80003eaa:	fe840593          	addi	a1,s0,-24
    80003eae:	4501                	li	a0,0
    80003eb0:	00000097          	auipc	ra,0x0
    80003eb4:	c42080e7          	jalr	-958(ra) # 80003af2 <argaddr>
    80003eb8:	02054463          	bltz	a0,80003ee0 <sys_kthread_create+0x3e>
    return -1;
  if(argaddr(1, &stack) < 0)
    80003ebc:	fe040593          	addi	a1,s0,-32
    80003ec0:	4505                	li	a0,1
    80003ec2:	00000097          	auipc	ra,0x0
    80003ec6:	c30080e7          	jalr	-976(ra) # 80003af2 <argaddr>
    80003eca:	00054b63          	bltz	a0,80003ee0 <sys_kthread_create+0x3e>
    return -1;
  kthread_create(start_func,stack);
    80003ece:	fe043583          	ld	a1,-32(s0)
    80003ed2:	fe843503          	ld	a0,-24(s0)
    80003ed6:	fffff097          	auipc	ra,0xfffff
    80003eda:	fb4080e7          	jalr	-76(ra) # 80002e8a <kthread_create>
}
    80003ede:	a011                	j	80003ee2 <sys_kthread_create+0x40>
    80003ee0:	557d                	li	a0,-1
    80003ee2:	60e2                	ld	ra,24(sp)
    80003ee4:	6442                	ld	s0,16(sp)
    80003ee6:	6105                	addi	sp,sp,32
    80003ee8:	8082                	ret

0000000080003eea <sys_kthread_id>:

uint64
sys_kthread_id(void){
    80003eea:	1141                	addi	sp,sp,-16
    80003eec:	e406                	sd	ra,8(sp)
    80003eee:	e022                	sd	s0,0(sp)
    80003ef0:	0800                	addi	s0,sp,16
  return mykthread()->tid;
    80003ef2:	ffffe097          	auipc	ra,0xffffe
    80003ef6:	bca080e7          	jalr	-1078(ra) # 80001abc <mykthread>
}
    80003efa:	5908                	lw	a0,48(a0)
    80003efc:	60a2                	ld	ra,8(sp)
    80003efe:	6402                	ld	s0,0(sp)
    80003f00:	0141                	addi	sp,sp,16
    80003f02:	8082                	ret

0000000080003f04 <sys_kthread_exit>:

uint64
sys_kthread_exit(void){
    80003f04:	1101                	addi	sp,sp,-32
    80003f06:	ec06                	sd	ra,24(sp)
    80003f08:	e822                	sd	s0,16(sp)
    80003f0a:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003f0c:	fec40593          	addi	a1,s0,-20
    80003f10:	4501                	li	a0,0
    80003f12:	00000097          	auipc	ra,0x0
    80003f16:	bbe080e7          	jalr	-1090(ra) # 80003ad0 <argint>
    return -1;
    80003f1a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003f1c:	00054963          	bltz	a0,80003f2e <sys_kthread_exit+0x2a>
  kthread_exit(n);
    80003f20:	fec42503          	lw	a0,-20(s0)
    80003f24:	fffff097          	auipc	ra,0xfffff
    80003f28:	8ee080e7          	jalr	-1810(ra) # 80002812 <kthread_exit>
  
  return 0;  // not reached
    80003f2c:	4781                	li	a5,0
}
    80003f2e:	853e                	mv	a0,a5
    80003f30:	60e2                	ld	ra,24(sp)
    80003f32:	6442                	ld	s0,16(sp)
    80003f34:	6105                	addi	sp,sp,32
    80003f36:	8082                	ret

0000000080003f38 <sys_kthread_join>:

uint64 
sys_kthread_join(){
    80003f38:	1101                	addi	sp,sp,-32
    80003f3a:	ec06                	sd	ra,24(sp)
    80003f3c:	e822                	sd	s0,16(sp)
    80003f3e:	1000                	addi	s0,sp,32
  int thread_id;
  uint64 status;
  if(argint(0, &thread_id) < 0)
    80003f40:	fec40593          	addi	a1,s0,-20
    80003f44:	4501                	li	a0,0
    80003f46:	00000097          	auipc	ra,0x0
    80003f4a:	b8a080e7          	jalr	-1142(ra) # 80003ad0 <argint>
    return -1;
    80003f4e:	57fd                	li	a5,-1
  if(argint(0, &thread_id) < 0)
    80003f50:	02054563          	bltz	a0,80003f7a <sys_kthread_join+0x42>
  if(argaddr(1, &status) < 0)
    80003f54:	fe040593          	addi	a1,s0,-32
    80003f58:	4505                	li	a0,1
    80003f5a:	00000097          	auipc	ra,0x0
    80003f5e:	b98080e7          	jalr	-1128(ra) # 80003af2 <argaddr>
    return -1;
    80003f62:	57fd                	li	a5,-1
  if(argaddr(1, &status) < 0)
    80003f64:	00054b63          	bltz	a0,80003f7a <sys_kthread_join+0x42>
  
  return kthread_join(thread_id, status);
    80003f68:	fe043583          	ld	a1,-32(s0)
    80003f6c:	fec42503          	lw	a0,-20(s0)
    80003f70:	fffff097          	auipc	ra,0xfffff
    80003f74:	01e080e7          	jalr	30(ra) # 80002f8e <kthread_join>
    80003f78:	87aa                	mv	a5,a0
    80003f7a:	853e                	mv	a0,a5
    80003f7c:	60e2                	ld	ra,24(sp)
    80003f7e:	6442                	ld	s0,16(sp)
    80003f80:	6105                	addi	sp,sp,32
    80003f82:	8082                	ret

0000000080003f84 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003f84:	7179                	addi	sp,sp,-48
    80003f86:	f406                	sd	ra,40(sp)
    80003f88:	f022                	sd	s0,32(sp)
    80003f8a:	ec26                	sd	s1,24(sp)
    80003f8c:	e84a                	sd	s2,16(sp)
    80003f8e:	e44e                	sd	s3,8(sp)
    80003f90:	e052                	sd	s4,0(sp)
    80003f92:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003f94:	00005597          	auipc	a1,0x5
    80003f98:	77458593          	addi	a1,a1,1908 # 80009708 <syscalls+0xe8>
    80003f9c:	00030517          	auipc	a0,0x30
    80003fa0:	9a450513          	addi	a0,a0,-1628 # 80033940 <bcache>
    80003fa4:	ffffd097          	auipc	ra,0xffffd
    80003fa8:	b92080e7          	jalr	-1134(ra) # 80000b36 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003fac:	00038797          	auipc	a5,0x38
    80003fb0:	99478793          	addi	a5,a5,-1644 # 8003b940 <bcache+0x8000>
    80003fb4:	00038717          	auipc	a4,0x38
    80003fb8:	bf470713          	addi	a4,a4,-1036 # 8003bba8 <bcache+0x8268>
    80003fbc:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003fc0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003fc4:	00030497          	auipc	s1,0x30
    80003fc8:	99448493          	addi	s1,s1,-1644 # 80033958 <bcache+0x18>
    b->next = bcache.head.next;
    80003fcc:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003fce:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003fd0:	00005a17          	auipc	s4,0x5
    80003fd4:	740a0a13          	addi	s4,s4,1856 # 80009710 <syscalls+0xf0>
    b->next = bcache.head.next;
    80003fd8:	2b893783          	ld	a5,696(s2)
    80003fdc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003fde:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003fe2:	85d2                	mv	a1,s4
    80003fe4:	01048513          	addi	a0,s1,16
    80003fe8:	00001097          	auipc	ra,0x1
    80003fec:	4c0080e7          	jalr	1216(ra) # 800054a8 <initsleeplock>
    bcache.head.next->prev = b;
    80003ff0:	2b893783          	ld	a5,696(s2)
    80003ff4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003ff6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003ffa:	45848493          	addi	s1,s1,1112
    80003ffe:	fd349de3          	bne	s1,s3,80003fd8 <binit+0x54>
  }
}
    80004002:	70a2                	ld	ra,40(sp)
    80004004:	7402                	ld	s0,32(sp)
    80004006:	64e2                	ld	s1,24(sp)
    80004008:	6942                	ld	s2,16(sp)
    8000400a:	69a2                	ld	s3,8(sp)
    8000400c:	6a02                	ld	s4,0(sp)
    8000400e:	6145                	addi	sp,sp,48
    80004010:	8082                	ret

0000000080004012 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80004012:	7179                	addi	sp,sp,-48
    80004014:	f406                	sd	ra,40(sp)
    80004016:	f022                	sd	s0,32(sp)
    80004018:	ec26                	sd	s1,24(sp)
    8000401a:	e84a                	sd	s2,16(sp)
    8000401c:	e44e                	sd	s3,8(sp)
    8000401e:	1800                	addi	s0,sp,48
    80004020:	892a                	mv	s2,a0
    80004022:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80004024:	00030517          	auipc	a0,0x30
    80004028:	91c50513          	addi	a0,a0,-1764 # 80033940 <bcache>
    8000402c:	ffffd097          	auipc	ra,0xffffd
    80004030:	b9a080e7          	jalr	-1126(ra) # 80000bc6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80004034:	00038497          	auipc	s1,0x38
    80004038:	bc44b483          	ld	s1,-1084(s1) # 8003bbf8 <bcache+0x82b8>
    8000403c:	00038797          	auipc	a5,0x38
    80004040:	b6c78793          	addi	a5,a5,-1172 # 8003bba8 <bcache+0x8268>
    80004044:	02f48f63          	beq	s1,a5,80004082 <bread+0x70>
    80004048:	873e                	mv	a4,a5
    8000404a:	a021                	j	80004052 <bread+0x40>
    8000404c:	68a4                	ld	s1,80(s1)
    8000404e:	02e48a63          	beq	s1,a4,80004082 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80004052:	449c                	lw	a5,8(s1)
    80004054:	ff279ce3          	bne	a5,s2,8000404c <bread+0x3a>
    80004058:	44dc                	lw	a5,12(s1)
    8000405a:	ff3799e3          	bne	a5,s3,8000404c <bread+0x3a>
      b->refcnt++;
    8000405e:	40bc                	lw	a5,64(s1)
    80004060:	2785                	addiw	a5,a5,1
    80004062:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80004064:	00030517          	auipc	a0,0x30
    80004068:	8dc50513          	addi	a0,a0,-1828 # 80033940 <bcache>
    8000406c:	ffffd097          	auipc	ra,0xffffd
    80004070:	c30080e7          	jalr	-976(ra) # 80000c9c <release>
      acquiresleep(&b->lock);
    80004074:	01048513          	addi	a0,s1,16
    80004078:	00001097          	auipc	ra,0x1
    8000407c:	46a080e7          	jalr	1130(ra) # 800054e2 <acquiresleep>
      return b;
    80004080:	a8b9                	j	800040de <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80004082:	00038497          	auipc	s1,0x38
    80004086:	b6e4b483          	ld	s1,-1170(s1) # 8003bbf0 <bcache+0x82b0>
    8000408a:	00038797          	auipc	a5,0x38
    8000408e:	b1e78793          	addi	a5,a5,-1250 # 8003bba8 <bcache+0x8268>
    80004092:	00f48863          	beq	s1,a5,800040a2 <bread+0x90>
    80004096:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80004098:	40bc                	lw	a5,64(s1)
    8000409a:	cf81                	beqz	a5,800040b2 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000409c:	64a4                	ld	s1,72(s1)
    8000409e:	fee49de3          	bne	s1,a4,80004098 <bread+0x86>
  panic("bget: no buffers");
    800040a2:	00005517          	auipc	a0,0x5
    800040a6:	67650513          	addi	a0,a0,1654 # 80009718 <syscalls+0xf8>
    800040aa:	ffffc097          	auipc	ra,0xffffc
    800040ae:	484080e7          	jalr	1156(ra) # 8000052e <panic>
      b->dev = dev;
    800040b2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800040b6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800040ba:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800040be:	4785                	li	a5,1
    800040c0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800040c2:	00030517          	auipc	a0,0x30
    800040c6:	87e50513          	addi	a0,a0,-1922 # 80033940 <bcache>
    800040ca:	ffffd097          	auipc	ra,0xffffd
    800040ce:	bd2080e7          	jalr	-1070(ra) # 80000c9c <release>
      acquiresleep(&b->lock);
    800040d2:	01048513          	addi	a0,s1,16
    800040d6:	00001097          	auipc	ra,0x1
    800040da:	40c080e7          	jalr	1036(ra) # 800054e2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800040de:	409c                	lw	a5,0(s1)
    800040e0:	cb89                	beqz	a5,800040f2 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800040e2:	8526                	mv	a0,s1
    800040e4:	70a2                	ld	ra,40(sp)
    800040e6:	7402                	ld	s0,32(sp)
    800040e8:	64e2                	ld	s1,24(sp)
    800040ea:	6942                	ld	s2,16(sp)
    800040ec:	69a2                	ld	s3,8(sp)
    800040ee:	6145                	addi	sp,sp,48
    800040f0:	8082                	ret
    virtio_disk_rw(b, 0);
    800040f2:	4581                	li	a1,0
    800040f4:	8526                	mv	a0,s1
    800040f6:	00003097          	auipc	ra,0x3
    800040fa:	fc0080e7          	jalr	-64(ra) # 800070b6 <virtio_disk_rw>
    b->valid = 1;
    800040fe:	4785                	li	a5,1
    80004100:	c09c                	sw	a5,0(s1)
  return b;
    80004102:	b7c5                	j	800040e2 <bread+0xd0>

0000000080004104 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80004104:	1101                	addi	sp,sp,-32
    80004106:	ec06                	sd	ra,24(sp)
    80004108:	e822                	sd	s0,16(sp)
    8000410a:	e426                	sd	s1,8(sp)
    8000410c:	1000                	addi	s0,sp,32
    8000410e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004110:	0541                	addi	a0,a0,16
    80004112:	00001097          	auipc	ra,0x1
    80004116:	46a080e7          	jalr	1130(ra) # 8000557c <holdingsleep>
    8000411a:	cd01                	beqz	a0,80004132 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000411c:	4585                	li	a1,1
    8000411e:	8526                	mv	a0,s1
    80004120:	00003097          	auipc	ra,0x3
    80004124:	f96080e7          	jalr	-106(ra) # 800070b6 <virtio_disk_rw>
}
    80004128:	60e2                	ld	ra,24(sp)
    8000412a:	6442                	ld	s0,16(sp)
    8000412c:	64a2                	ld	s1,8(sp)
    8000412e:	6105                	addi	sp,sp,32
    80004130:	8082                	ret
    panic("bwrite");
    80004132:	00005517          	auipc	a0,0x5
    80004136:	5fe50513          	addi	a0,a0,1534 # 80009730 <syscalls+0x110>
    8000413a:	ffffc097          	auipc	ra,0xffffc
    8000413e:	3f4080e7          	jalr	1012(ra) # 8000052e <panic>

0000000080004142 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80004142:	1101                	addi	sp,sp,-32
    80004144:	ec06                	sd	ra,24(sp)
    80004146:	e822                	sd	s0,16(sp)
    80004148:	e426                	sd	s1,8(sp)
    8000414a:	e04a                	sd	s2,0(sp)
    8000414c:	1000                	addi	s0,sp,32
    8000414e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004150:	01050913          	addi	s2,a0,16
    80004154:	854a                	mv	a0,s2
    80004156:	00001097          	auipc	ra,0x1
    8000415a:	426080e7          	jalr	1062(ra) # 8000557c <holdingsleep>
    8000415e:	c92d                	beqz	a0,800041d0 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80004160:	854a                	mv	a0,s2
    80004162:	00001097          	auipc	ra,0x1
    80004166:	3d6080e7          	jalr	982(ra) # 80005538 <releasesleep>

  acquire(&bcache.lock);
    8000416a:	0002f517          	auipc	a0,0x2f
    8000416e:	7d650513          	addi	a0,a0,2006 # 80033940 <bcache>
    80004172:	ffffd097          	auipc	ra,0xffffd
    80004176:	a54080e7          	jalr	-1452(ra) # 80000bc6 <acquire>
  b->refcnt--;
    8000417a:	40bc                	lw	a5,64(s1)
    8000417c:	37fd                	addiw	a5,a5,-1
    8000417e:	0007871b          	sext.w	a4,a5
    80004182:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80004184:	eb05                	bnez	a4,800041b4 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80004186:	68bc                	ld	a5,80(s1)
    80004188:	64b8                	ld	a4,72(s1)
    8000418a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000418c:	64bc                	ld	a5,72(s1)
    8000418e:	68b8                	ld	a4,80(s1)
    80004190:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80004192:	00037797          	auipc	a5,0x37
    80004196:	7ae78793          	addi	a5,a5,1966 # 8003b940 <bcache+0x8000>
    8000419a:	2b87b703          	ld	a4,696(a5)
    8000419e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800041a0:	00038717          	auipc	a4,0x38
    800041a4:	a0870713          	addi	a4,a4,-1528 # 8003bba8 <bcache+0x8268>
    800041a8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800041aa:	2b87b703          	ld	a4,696(a5)
    800041ae:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800041b0:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800041b4:	0002f517          	auipc	a0,0x2f
    800041b8:	78c50513          	addi	a0,a0,1932 # 80033940 <bcache>
    800041bc:	ffffd097          	auipc	ra,0xffffd
    800041c0:	ae0080e7          	jalr	-1312(ra) # 80000c9c <release>
}
    800041c4:	60e2                	ld	ra,24(sp)
    800041c6:	6442                	ld	s0,16(sp)
    800041c8:	64a2                	ld	s1,8(sp)
    800041ca:	6902                	ld	s2,0(sp)
    800041cc:	6105                	addi	sp,sp,32
    800041ce:	8082                	ret
    panic("brelse");
    800041d0:	00005517          	auipc	a0,0x5
    800041d4:	56850513          	addi	a0,a0,1384 # 80009738 <syscalls+0x118>
    800041d8:	ffffc097          	auipc	ra,0xffffc
    800041dc:	356080e7          	jalr	854(ra) # 8000052e <panic>

00000000800041e0 <bpin>:

void
bpin(struct buf *b) {
    800041e0:	1101                	addi	sp,sp,-32
    800041e2:	ec06                	sd	ra,24(sp)
    800041e4:	e822                	sd	s0,16(sp)
    800041e6:	e426                	sd	s1,8(sp)
    800041e8:	1000                	addi	s0,sp,32
    800041ea:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800041ec:	0002f517          	auipc	a0,0x2f
    800041f0:	75450513          	addi	a0,a0,1876 # 80033940 <bcache>
    800041f4:	ffffd097          	auipc	ra,0xffffd
    800041f8:	9d2080e7          	jalr	-1582(ra) # 80000bc6 <acquire>
  b->refcnt++;
    800041fc:	40bc                	lw	a5,64(s1)
    800041fe:	2785                	addiw	a5,a5,1
    80004200:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004202:	0002f517          	auipc	a0,0x2f
    80004206:	73e50513          	addi	a0,a0,1854 # 80033940 <bcache>
    8000420a:	ffffd097          	auipc	ra,0xffffd
    8000420e:	a92080e7          	jalr	-1390(ra) # 80000c9c <release>
}
    80004212:	60e2                	ld	ra,24(sp)
    80004214:	6442                	ld	s0,16(sp)
    80004216:	64a2                	ld	s1,8(sp)
    80004218:	6105                	addi	sp,sp,32
    8000421a:	8082                	ret

000000008000421c <bunpin>:

void
bunpin(struct buf *b) {
    8000421c:	1101                	addi	sp,sp,-32
    8000421e:	ec06                	sd	ra,24(sp)
    80004220:	e822                	sd	s0,16(sp)
    80004222:	e426                	sd	s1,8(sp)
    80004224:	1000                	addi	s0,sp,32
    80004226:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004228:	0002f517          	auipc	a0,0x2f
    8000422c:	71850513          	addi	a0,a0,1816 # 80033940 <bcache>
    80004230:	ffffd097          	auipc	ra,0xffffd
    80004234:	996080e7          	jalr	-1642(ra) # 80000bc6 <acquire>
  b->refcnt--;
    80004238:	40bc                	lw	a5,64(s1)
    8000423a:	37fd                	addiw	a5,a5,-1
    8000423c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000423e:	0002f517          	auipc	a0,0x2f
    80004242:	70250513          	addi	a0,a0,1794 # 80033940 <bcache>
    80004246:	ffffd097          	auipc	ra,0xffffd
    8000424a:	a56080e7          	jalr	-1450(ra) # 80000c9c <release>
}
    8000424e:	60e2                	ld	ra,24(sp)
    80004250:	6442                	ld	s0,16(sp)
    80004252:	64a2                	ld	s1,8(sp)
    80004254:	6105                	addi	sp,sp,32
    80004256:	8082                	ret

0000000080004258 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80004258:	1101                	addi	sp,sp,-32
    8000425a:	ec06                	sd	ra,24(sp)
    8000425c:	e822                	sd	s0,16(sp)
    8000425e:	e426                	sd	s1,8(sp)
    80004260:	e04a                	sd	s2,0(sp)
    80004262:	1000                	addi	s0,sp,32
    80004264:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80004266:	00d5d59b          	srliw	a1,a1,0xd
    8000426a:	00038797          	auipc	a5,0x38
    8000426e:	db27a783          	lw	a5,-590(a5) # 8003c01c <sb+0x1c>
    80004272:	9dbd                	addw	a1,a1,a5
    80004274:	00000097          	auipc	ra,0x0
    80004278:	d9e080e7          	jalr	-610(ra) # 80004012 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000427c:	0074f713          	andi	a4,s1,7
    80004280:	4785                	li	a5,1
    80004282:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80004286:	14ce                	slli	s1,s1,0x33
    80004288:	90d9                	srli	s1,s1,0x36
    8000428a:	00950733          	add	a4,a0,s1
    8000428e:	05874703          	lbu	a4,88(a4)
    80004292:	00e7f6b3          	and	a3,a5,a4
    80004296:	c69d                	beqz	a3,800042c4 <bfree+0x6c>
    80004298:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000429a:	94aa                	add	s1,s1,a0
    8000429c:	fff7c793          	not	a5,a5
    800042a0:	8ff9                	and	a5,a5,a4
    800042a2:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800042a6:	00001097          	auipc	ra,0x1
    800042aa:	11c080e7          	jalr	284(ra) # 800053c2 <log_write>
  brelse(bp);
    800042ae:	854a                	mv	a0,s2
    800042b0:	00000097          	auipc	ra,0x0
    800042b4:	e92080e7          	jalr	-366(ra) # 80004142 <brelse>
}
    800042b8:	60e2                	ld	ra,24(sp)
    800042ba:	6442                	ld	s0,16(sp)
    800042bc:	64a2                	ld	s1,8(sp)
    800042be:	6902                	ld	s2,0(sp)
    800042c0:	6105                	addi	sp,sp,32
    800042c2:	8082                	ret
    panic("freeing free block");
    800042c4:	00005517          	auipc	a0,0x5
    800042c8:	47c50513          	addi	a0,a0,1148 # 80009740 <syscalls+0x120>
    800042cc:	ffffc097          	auipc	ra,0xffffc
    800042d0:	262080e7          	jalr	610(ra) # 8000052e <panic>

00000000800042d4 <balloc>:
{
    800042d4:	711d                	addi	sp,sp,-96
    800042d6:	ec86                	sd	ra,88(sp)
    800042d8:	e8a2                	sd	s0,80(sp)
    800042da:	e4a6                	sd	s1,72(sp)
    800042dc:	e0ca                	sd	s2,64(sp)
    800042de:	fc4e                	sd	s3,56(sp)
    800042e0:	f852                	sd	s4,48(sp)
    800042e2:	f456                	sd	s5,40(sp)
    800042e4:	f05a                	sd	s6,32(sp)
    800042e6:	ec5e                	sd	s7,24(sp)
    800042e8:	e862                	sd	s8,16(sp)
    800042ea:	e466                	sd	s9,8(sp)
    800042ec:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800042ee:	00038797          	auipc	a5,0x38
    800042f2:	d167a783          	lw	a5,-746(a5) # 8003c004 <sb+0x4>
    800042f6:	cbd1                	beqz	a5,8000438a <balloc+0xb6>
    800042f8:	8baa                	mv	s7,a0
    800042fa:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800042fc:	00038b17          	auipc	s6,0x38
    80004300:	d04b0b13          	addi	s6,s6,-764 # 8003c000 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004304:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80004306:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004308:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000430a:	6c89                	lui	s9,0x2
    8000430c:	a831                	j	80004328 <balloc+0x54>
    brelse(bp);
    8000430e:	854a                	mv	a0,s2
    80004310:	00000097          	auipc	ra,0x0
    80004314:	e32080e7          	jalr	-462(ra) # 80004142 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80004318:	015c87bb          	addw	a5,s9,s5
    8000431c:	00078a9b          	sext.w	s5,a5
    80004320:	004b2703          	lw	a4,4(s6)
    80004324:	06eaf363          	bgeu	s5,a4,8000438a <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80004328:	41fad79b          	sraiw	a5,s5,0x1f
    8000432c:	0137d79b          	srliw	a5,a5,0x13
    80004330:	015787bb          	addw	a5,a5,s5
    80004334:	40d7d79b          	sraiw	a5,a5,0xd
    80004338:	01cb2583          	lw	a1,28(s6)
    8000433c:	9dbd                	addw	a1,a1,a5
    8000433e:	855e                	mv	a0,s7
    80004340:	00000097          	auipc	ra,0x0
    80004344:	cd2080e7          	jalr	-814(ra) # 80004012 <bread>
    80004348:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000434a:	004b2503          	lw	a0,4(s6)
    8000434e:	000a849b          	sext.w	s1,s5
    80004352:	8662                	mv	a2,s8
    80004354:	faa4fde3          	bgeu	s1,a0,8000430e <balloc+0x3a>
      m = 1 << (bi % 8);
    80004358:	41f6579b          	sraiw	a5,a2,0x1f
    8000435c:	01d7d69b          	srliw	a3,a5,0x1d
    80004360:	00c6873b          	addw	a4,a3,a2
    80004364:	00777793          	andi	a5,a4,7
    80004368:	9f95                	subw	a5,a5,a3
    8000436a:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000436e:	4037571b          	sraiw	a4,a4,0x3
    80004372:	00e906b3          	add	a3,s2,a4
    80004376:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    8000437a:	00d7f5b3          	and	a1,a5,a3
    8000437e:	cd91                	beqz	a1,8000439a <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004380:	2605                	addiw	a2,a2,1
    80004382:	2485                	addiw	s1,s1,1
    80004384:	fd4618e3          	bne	a2,s4,80004354 <balloc+0x80>
    80004388:	b759                	j	8000430e <balloc+0x3a>
  panic("balloc: out of blocks");
    8000438a:	00005517          	auipc	a0,0x5
    8000438e:	3ce50513          	addi	a0,a0,974 # 80009758 <syscalls+0x138>
    80004392:	ffffc097          	auipc	ra,0xffffc
    80004396:	19c080e7          	jalr	412(ra) # 8000052e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000439a:	974a                	add	a4,a4,s2
    8000439c:	8fd5                	or	a5,a5,a3
    8000439e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800043a2:	854a                	mv	a0,s2
    800043a4:	00001097          	auipc	ra,0x1
    800043a8:	01e080e7          	jalr	30(ra) # 800053c2 <log_write>
        brelse(bp);
    800043ac:	854a                	mv	a0,s2
    800043ae:	00000097          	auipc	ra,0x0
    800043b2:	d94080e7          	jalr	-620(ra) # 80004142 <brelse>
  bp = bread(dev, bno);
    800043b6:	85a6                	mv	a1,s1
    800043b8:	855e                	mv	a0,s7
    800043ba:	00000097          	auipc	ra,0x0
    800043be:	c58080e7          	jalr	-936(ra) # 80004012 <bread>
    800043c2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800043c4:	40000613          	li	a2,1024
    800043c8:	4581                	li	a1,0
    800043ca:	05850513          	addi	a0,a0,88
    800043ce:	ffffd097          	auipc	ra,0xffffd
    800043d2:	916080e7          	jalr	-1770(ra) # 80000ce4 <memset>
  log_write(bp);
    800043d6:	854a                	mv	a0,s2
    800043d8:	00001097          	auipc	ra,0x1
    800043dc:	fea080e7          	jalr	-22(ra) # 800053c2 <log_write>
  brelse(bp);
    800043e0:	854a                	mv	a0,s2
    800043e2:	00000097          	auipc	ra,0x0
    800043e6:	d60080e7          	jalr	-672(ra) # 80004142 <brelse>
}
    800043ea:	8526                	mv	a0,s1
    800043ec:	60e6                	ld	ra,88(sp)
    800043ee:	6446                	ld	s0,80(sp)
    800043f0:	64a6                	ld	s1,72(sp)
    800043f2:	6906                	ld	s2,64(sp)
    800043f4:	79e2                	ld	s3,56(sp)
    800043f6:	7a42                	ld	s4,48(sp)
    800043f8:	7aa2                	ld	s5,40(sp)
    800043fa:	7b02                	ld	s6,32(sp)
    800043fc:	6be2                	ld	s7,24(sp)
    800043fe:	6c42                	ld	s8,16(sp)
    80004400:	6ca2                	ld	s9,8(sp)
    80004402:	6125                	addi	sp,sp,96
    80004404:	8082                	ret

0000000080004406 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80004406:	7179                	addi	sp,sp,-48
    80004408:	f406                	sd	ra,40(sp)
    8000440a:	f022                	sd	s0,32(sp)
    8000440c:	ec26                	sd	s1,24(sp)
    8000440e:	e84a                	sd	s2,16(sp)
    80004410:	e44e                	sd	s3,8(sp)
    80004412:	e052                	sd	s4,0(sp)
    80004414:	1800                	addi	s0,sp,48
    80004416:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80004418:	47ad                	li	a5,11
    8000441a:	04b7fe63          	bgeu	a5,a1,80004476 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000441e:	ff45849b          	addiw	s1,a1,-12
    80004422:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80004426:	0ff00793          	li	a5,255
    8000442a:	0ae7e463          	bltu	a5,a4,800044d2 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000442e:	08052583          	lw	a1,128(a0)
    80004432:	c5b5                	beqz	a1,8000449e <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80004434:	00092503          	lw	a0,0(s2)
    80004438:	00000097          	auipc	ra,0x0
    8000443c:	bda080e7          	jalr	-1062(ra) # 80004012 <bread>
    80004440:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80004442:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80004446:	02049713          	slli	a4,s1,0x20
    8000444a:	01e75593          	srli	a1,a4,0x1e
    8000444e:	00b784b3          	add	s1,a5,a1
    80004452:	0004a983          	lw	s3,0(s1)
    80004456:	04098e63          	beqz	s3,800044b2 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000445a:	8552                	mv	a0,s4
    8000445c:	00000097          	auipc	ra,0x0
    80004460:	ce6080e7          	jalr	-794(ra) # 80004142 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80004464:	854e                	mv	a0,s3
    80004466:	70a2                	ld	ra,40(sp)
    80004468:	7402                	ld	s0,32(sp)
    8000446a:	64e2                	ld	s1,24(sp)
    8000446c:	6942                	ld	s2,16(sp)
    8000446e:	69a2                	ld	s3,8(sp)
    80004470:	6a02                	ld	s4,0(sp)
    80004472:	6145                	addi	sp,sp,48
    80004474:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80004476:	02059793          	slli	a5,a1,0x20
    8000447a:	01e7d593          	srli	a1,a5,0x1e
    8000447e:	00b504b3          	add	s1,a0,a1
    80004482:	0504a983          	lw	s3,80(s1)
    80004486:	fc099fe3          	bnez	s3,80004464 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000448a:	4108                	lw	a0,0(a0)
    8000448c:	00000097          	auipc	ra,0x0
    80004490:	e48080e7          	jalr	-440(ra) # 800042d4 <balloc>
    80004494:	0005099b          	sext.w	s3,a0
    80004498:	0534a823          	sw	s3,80(s1)
    8000449c:	b7e1                	j	80004464 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000449e:	4108                	lw	a0,0(a0)
    800044a0:	00000097          	auipc	ra,0x0
    800044a4:	e34080e7          	jalr	-460(ra) # 800042d4 <balloc>
    800044a8:	0005059b          	sext.w	a1,a0
    800044ac:	08b92023          	sw	a1,128(s2)
    800044b0:	b751                	j	80004434 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800044b2:	00092503          	lw	a0,0(s2)
    800044b6:	00000097          	auipc	ra,0x0
    800044ba:	e1e080e7          	jalr	-482(ra) # 800042d4 <balloc>
    800044be:	0005099b          	sext.w	s3,a0
    800044c2:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800044c6:	8552                	mv	a0,s4
    800044c8:	00001097          	auipc	ra,0x1
    800044cc:	efa080e7          	jalr	-262(ra) # 800053c2 <log_write>
    800044d0:	b769                	j	8000445a <bmap+0x54>
  panic("bmap: out of range");
    800044d2:	00005517          	auipc	a0,0x5
    800044d6:	29e50513          	addi	a0,a0,670 # 80009770 <syscalls+0x150>
    800044da:	ffffc097          	auipc	ra,0xffffc
    800044de:	054080e7          	jalr	84(ra) # 8000052e <panic>

00000000800044e2 <iget>:
{
    800044e2:	7179                	addi	sp,sp,-48
    800044e4:	f406                	sd	ra,40(sp)
    800044e6:	f022                	sd	s0,32(sp)
    800044e8:	ec26                	sd	s1,24(sp)
    800044ea:	e84a                	sd	s2,16(sp)
    800044ec:	e44e                	sd	s3,8(sp)
    800044ee:	e052                	sd	s4,0(sp)
    800044f0:	1800                	addi	s0,sp,48
    800044f2:	89aa                	mv	s3,a0
    800044f4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800044f6:	00038517          	auipc	a0,0x38
    800044fa:	b2a50513          	addi	a0,a0,-1238 # 8003c020 <itable>
    800044fe:	ffffc097          	auipc	ra,0xffffc
    80004502:	6c8080e7          	jalr	1736(ra) # 80000bc6 <acquire>
  empty = 0;
    80004506:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004508:	00038497          	auipc	s1,0x38
    8000450c:	b3048493          	addi	s1,s1,-1232 # 8003c038 <itable+0x18>
    80004510:	00039697          	auipc	a3,0x39
    80004514:	5b868693          	addi	a3,a3,1464 # 8003dac8 <log>
    80004518:	a039                	j	80004526 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000451a:	02090b63          	beqz	s2,80004550 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000451e:	08848493          	addi	s1,s1,136
    80004522:	02d48a63          	beq	s1,a3,80004556 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80004526:	449c                	lw	a5,8(s1)
    80004528:	fef059e3          	blez	a5,8000451a <iget+0x38>
    8000452c:	4098                	lw	a4,0(s1)
    8000452e:	ff3716e3          	bne	a4,s3,8000451a <iget+0x38>
    80004532:	40d8                	lw	a4,4(s1)
    80004534:	ff4713e3          	bne	a4,s4,8000451a <iget+0x38>
      ip->ref++;
    80004538:	2785                	addiw	a5,a5,1
    8000453a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000453c:	00038517          	auipc	a0,0x38
    80004540:	ae450513          	addi	a0,a0,-1308 # 8003c020 <itable>
    80004544:	ffffc097          	auipc	ra,0xffffc
    80004548:	758080e7          	jalr	1880(ra) # 80000c9c <release>
      return ip;
    8000454c:	8926                	mv	s2,s1
    8000454e:	a03d                	j	8000457c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004550:	f7f9                	bnez	a5,8000451e <iget+0x3c>
    80004552:	8926                	mv	s2,s1
    80004554:	b7e9                	j	8000451e <iget+0x3c>
  if(empty == 0)
    80004556:	02090c63          	beqz	s2,8000458e <iget+0xac>
  ip->dev = dev;
    8000455a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000455e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80004562:	4785                	li	a5,1
    80004564:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80004568:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000456c:	00038517          	auipc	a0,0x38
    80004570:	ab450513          	addi	a0,a0,-1356 # 8003c020 <itable>
    80004574:	ffffc097          	auipc	ra,0xffffc
    80004578:	728080e7          	jalr	1832(ra) # 80000c9c <release>
}
    8000457c:	854a                	mv	a0,s2
    8000457e:	70a2                	ld	ra,40(sp)
    80004580:	7402                	ld	s0,32(sp)
    80004582:	64e2                	ld	s1,24(sp)
    80004584:	6942                	ld	s2,16(sp)
    80004586:	69a2                	ld	s3,8(sp)
    80004588:	6a02                	ld	s4,0(sp)
    8000458a:	6145                	addi	sp,sp,48
    8000458c:	8082                	ret
    panic("iget: no inodes");
    8000458e:	00005517          	auipc	a0,0x5
    80004592:	1fa50513          	addi	a0,a0,506 # 80009788 <syscalls+0x168>
    80004596:	ffffc097          	auipc	ra,0xffffc
    8000459a:	f98080e7          	jalr	-104(ra) # 8000052e <panic>

000000008000459e <fsinit>:
fsinit(int dev) {
    8000459e:	7179                	addi	sp,sp,-48
    800045a0:	f406                	sd	ra,40(sp)
    800045a2:	f022                	sd	s0,32(sp)
    800045a4:	ec26                	sd	s1,24(sp)
    800045a6:	e84a                	sd	s2,16(sp)
    800045a8:	e44e                	sd	s3,8(sp)
    800045aa:	1800                	addi	s0,sp,48
    800045ac:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800045ae:	4585                	li	a1,1
    800045b0:	00000097          	auipc	ra,0x0
    800045b4:	a62080e7          	jalr	-1438(ra) # 80004012 <bread>
    800045b8:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800045ba:	00038997          	auipc	s3,0x38
    800045be:	a4698993          	addi	s3,s3,-1466 # 8003c000 <sb>
    800045c2:	02000613          	li	a2,32
    800045c6:	05850593          	addi	a1,a0,88
    800045ca:	854e                	mv	a0,s3
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	774080e7          	jalr	1908(ra) # 80000d40 <memmove>
  brelse(bp);
    800045d4:	8526                	mv	a0,s1
    800045d6:	00000097          	auipc	ra,0x0
    800045da:	b6c080e7          	jalr	-1172(ra) # 80004142 <brelse>
  if(sb.magic != FSMAGIC)
    800045de:	0009a703          	lw	a4,0(s3)
    800045e2:	102037b7          	lui	a5,0x10203
    800045e6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800045ea:	02f71263          	bne	a4,a5,8000460e <fsinit+0x70>
  initlog(dev, &sb);
    800045ee:	00038597          	auipc	a1,0x38
    800045f2:	a1258593          	addi	a1,a1,-1518 # 8003c000 <sb>
    800045f6:	854a                	mv	a0,s2
    800045f8:	00001097          	auipc	ra,0x1
    800045fc:	b4c080e7          	jalr	-1204(ra) # 80005144 <initlog>
}
    80004600:	70a2                	ld	ra,40(sp)
    80004602:	7402                	ld	s0,32(sp)
    80004604:	64e2                	ld	s1,24(sp)
    80004606:	6942                	ld	s2,16(sp)
    80004608:	69a2                	ld	s3,8(sp)
    8000460a:	6145                	addi	sp,sp,48
    8000460c:	8082                	ret
    panic("invalid file system");
    8000460e:	00005517          	auipc	a0,0x5
    80004612:	18a50513          	addi	a0,a0,394 # 80009798 <syscalls+0x178>
    80004616:	ffffc097          	auipc	ra,0xffffc
    8000461a:	f18080e7          	jalr	-232(ra) # 8000052e <panic>

000000008000461e <iinit>:
{
    8000461e:	7179                	addi	sp,sp,-48
    80004620:	f406                	sd	ra,40(sp)
    80004622:	f022                	sd	s0,32(sp)
    80004624:	ec26                	sd	s1,24(sp)
    80004626:	e84a                	sd	s2,16(sp)
    80004628:	e44e                	sd	s3,8(sp)
    8000462a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000462c:	00005597          	auipc	a1,0x5
    80004630:	18458593          	addi	a1,a1,388 # 800097b0 <syscalls+0x190>
    80004634:	00038517          	auipc	a0,0x38
    80004638:	9ec50513          	addi	a0,a0,-1556 # 8003c020 <itable>
    8000463c:	ffffc097          	auipc	ra,0xffffc
    80004640:	4fa080e7          	jalr	1274(ra) # 80000b36 <initlock>
  for(i = 0; i < NINODE; i++) {
    80004644:	00038497          	auipc	s1,0x38
    80004648:	a0448493          	addi	s1,s1,-1532 # 8003c048 <itable+0x28>
    8000464c:	00039997          	auipc	s3,0x39
    80004650:	48c98993          	addi	s3,s3,1164 # 8003dad8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004654:	00005917          	auipc	s2,0x5
    80004658:	16490913          	addi	s2,s2,356 # 800097b8 <syscalls+0x198>
    8000465c:	85ca                	mv	a1,s2
    8000465e:	8526                	mv	a0,s1
    80004660:	00001097          	auipc	ra,0x1
    80004664:	e48080e7          	jalr	-440(ra) # 800054a8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004668:	08848493          	addi	s1,s1,136
    8000466c:	ff3498e3          	bne	s1,s3,8000465c <iinit+0x3e>
}
    80004670:	70a2                	ld	ra,40(sp)
    80004672:	7402                	ld	s0,32(sp)
    80004674:	64e2                	ld	s1,24(sp)
    80004676:	6942                	ld	s2,16(sp)
    80004678:	69a2                	ld	s3,8(sp)
    8000467a:	6145                	addi	sp,sp,48
    8000467c:	8082                	ret

000000008000467e <ialloc>:
{
    8000467e:	715d                	addi	sp,sp,-80
    80004680:	e486                	sd	ra,72(sp)
    80004682:	e0a2                	sd	s0,64(sp)
    80004684:	fc26                	sd	s1,56(sp)
    80004686:	f84a                	sd	s2,48(sp)
    80004688:	f44e                	sd	s3,40(sp)
    8000468a:	f052                	sd	s4,32(sp)
    8000468c:	ec56                	sd	s5,24(sp)
    8000468e:	e85a                	sd	s6,16(sp)
    80004690:	e45e                	sd	s7,8(sp)
    80004692:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80004694:	00038717          	auipc	a4,0x38
    80004698:	97872703          	lw	a4,-1672(a4) # 8003c00c <sb+0xc>
    8000469c:	4785                	li	a5,1
    8000469e:	04e7fa63          	bgeu	a5,a4,800046f2 <ialloc+0x74>
    800046a2:	8aaa                	mv	s5,a0
    800046a4:	8bae                	mv	s7,a1
    800046a6:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800046a8:	00038a17          	auipc	s4,0x38
    800046ac:	958a0a13          	addi	s4,s4,-1704 # 8003c000 <sb>
    800046b0:	00048b1b          	sext.w	s6,s1
    800046b4:	0044d793          	srli	a5,s1,0x4
    800046b8:	018a2583          	lw	a1,24(s4)
    800046bc:	9dbd                	addw	a1,a1,a5
    800046be:	8556                	mv	a0,s5
    800046c0:	00000097          	auipc	ra,0x0
    800046c4:	952080e7          	jalr	-1710(ra) # 80004012 <bread>
    800046c8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800046ca:	05850993          	addi	s3,a0,88
    800046ce:	00f4f793          	andi	a5,s1,15
    800046d2:	079a                	slli	a5,a5,0x6
    800046d4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800046d6:	00099783          	lh	a5,0(s3)
    800046da:	c785                	beqz	a5,80004702 <ialloc+0x84>
    brelse(bp);
    800046dc:	00000097          	auipc	ra,0x0
    800046e0:	a66080e7          	jalr	-1434(ra) # 80004142 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800046e4:	0485                	addi	s1,s1,1
    800046e6:	00ca2703          	lw	a4,12(s4)
    800046ea:	0004879b          	sext.w	a5,s1
    800046ee:	fce7e1e3          	bltu	a5,a4,800046b0 <ialloc+0x32>
  panic("ialloc: no inodes");
    800046f2:	00005517          	auipc	a0,0x5
    800046f6:	0ce50513          	addi	a0,a0,206 # 800097c0 <syscalls+0x1a0>
    800046fa:	ffffc097          	auipc	ra,0xffffc
    800046fe:	e34080e7          	jalr	-460(ra) # 8000052e <panic>
      memset(dip, 0, sizeof(*dip));
    80004702:	04000613          	li	a2,64
    80004706:	4581                	li	a1,0
    80004708:	854e                	mv	a0,s3
    8000470a:	ffffc097          	auipc	ra,0xffffc
    8000470e:	5da080e7          	jalr	1498(ra) # 80000ce4 <memset>
      dip->type = type;
    80004712:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004716:	854a                	mv	a0,s2
    80004718:	00001097          	auipc	ra,0x1
    8000471c:	caa080e7          	jalr	-854(ra) # 800053c2 <log_write>
      brelse(bp);
    80004720:	854a                	mv	a0,s2
    80004722:	00000097          	auipc	ra,0x0
    80004726:	a20080e7          	jalr	-1504(ra) # 80004142 <brelse>
      return iget(dev, inum);
    8000472a:	85da                	mv	a1,s6
    8000472c:	8556                	mv	a0,s5
    8000472e:	00000097          	auipc	ra,0x0
    80004732:	db4080e7          	jalr	-588(ra) # 800044e2 <iget>
}
    80004736:	60a6                	ld	ra,72(sp)
    80004738:	6406                	ld	s0,64(sp)
    8000473a:	74e2                	ld	s1,56(sp)
    8000473c:	7942                	ld	s2,48(sp)
    8000473e:	79a2                	ld	s3,40(sp)
    80004740:	7a02                	ld	s4,32(sp)
    80004742:	6ae2                	ld	s5,24(sp)
    80004744:	6b42                	ld	s6,16(sp)
    80004746:	6ba2                	ld	s7,8(sp)
    80004748:	6161                	addi	sp,sp,80
    8000474a:	8082                	ret

000000008000474c <iupdate>:
{
    8000474c:	1101                	addi	sp,sp,-32
    8000474e:	ec06                	sd	ra,24(sp)
    80004750:	e822                	sd	s0,16(sp)
    80004752:	e426                	sd	s1,8(sp)
    80004754:	e04a                	sd	s2,0(sp)
    80004756:	1000                	addi	s0,sp,32
    80004758:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000475a:	415c                	lw	a5,4(a0)
    8000475c:	0047d79b          	srliw	a5,a5,0x4
    80004760:	00038597          	auipc	a1,0x38
    80004764:	8b85a583          	lw	a1,-1864(a1) # 8003c018 <sb+0x18>
    80004768:	9dbd                	addw	a1,a1,a5
    8000476a:	4108                	lw	a0,0(a0)
    8000476c:	00000097          	auipc	ra,0x0
    80004770:	8a6080e7          	jalr	-1882(ra) # 80004012 <bread>
    80004774:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004776:	05850793          	addi	a5,a0,88
    8000477a:	40c8                	lw	a0,4(s1)
    8000477c:	893d                	andi	a0,a0,15
    8000477e:	051a                	slli	a0,a0,0x6
    80004780:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80004782:	04449703          	lh	a4,68(s1)
    80004786:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000478a:	04649703          	lh	a4,70(s1)
    8000478e:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80004792:	04849703          	lh	a4,72(s1)
    80004796:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000479a:	04a49703          	lh	a4,74(s1)
    8000479e:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800047a2:	44f8                	lw	a4,76(s1)
    800047a4:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800047a6:	03400613          	li	a2,52
    800047aa:	05048593          	addi	a1,s1,80
    800047ae:	0531                	addi	a0,a0,12
    800047b0:	ffffc097          	auipc	ra,0xffffc
    800047b4:	590080e7          	jalr	1424(ra) # 80000d40 <memmove>
  log_write(bp);
    800047b8:	854a                	mv	a0,s2
    800047ba:	00001097          	auipc	ra,0x1
    800047be:	c08080e7          	jalr	-1016(ra) # 800053c2 <log_write>
  brelse(bp);
    800047c2:	854a                	mv	a0,s2
    800047c4:	00000097          	auipc	ra,0x0
    800047c8:	97e080e7          	jalr	-1666(ra) # 80004142 <brelse>
}
    800047cc:	60e2                	ld	ra,24(sp)
    800047ce:	6442                	ld	s0,16(sp)
    800047d0:	64a2                	ld	s1,8(sp)
    800047d2:	6902                	ld	s2,0(sp)
    800047d4:	6105                	addi	sp,sp,32
    800047d6:	8082                	ret

00000000800047d8 <idup>:
{
    800047d8:	1101                	addi	sp,sp,-32
    800047da:	ec06                	sd	ra,24(sp)
    800047dc:	e822                	sd	s0,16(sp)
    800047de:	e426                	sd	s1,8(sp)
    800047e0:	1000                	addi	s0,sp,32
    800047e2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800047e4:	00038517          	auipc	a0,0x38
    800047e8:	83c50513          	addi	a0,a0,-1988 # 8003c020 <itable>
    800047ec:	ffffc097          	auipc	ra,0xffffc
    800047f0:	3da080e7          	jalr	986(ra) # 80000bc6 <acquire>
  ip->ref++;
    800047f4:	449c                	lw	a5,8(s1)
    800047f6:	2785                	addiw	a5,a5,1
    800047f8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800047fa:	00038517          	auipc	a0,0x38
    800047fe:	82650513          	addi	a0,a0,-2010 # 8003c020 <itable>
    80004802:	ffffc097          	auipc	ra,0xffffc
    80004806:	49a080e7          	jalr	1178(ra) # 80000c9c <release>
}
    8000480a:	8526                	mv	a0,s1
    8000480c:	60e2                	ld	ra,24(sp)
    8000480e:	6442                	ld	s0,16(sp)
    80004810:	64a2                	ld	s1,8(sp)
    80004812:	6105                	addi	sp,sp,32
    80004814:	8082                	ret

0000000080004816 <ilock>:
{
    80004816:	1101                	addi	sp,sp,-32
    80004818:	ec06                	sd	ra,24(sp)
    8000481a:	e822                	sd	s0,16(sp)
    8000481c:	e426                	sd	s1,8(sp)
    8000481e:	e04a                	sd	s2,0(sp)
    80004820:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004822:	c115                	beqz	a0,80004846 <ilock+0x30>
    80004824:	84aa                	mv	s1,a0
    80004826:	451c                	lw	a5,8(a0)
    80004828:	00f05f63          	blez	a5,80004846 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000482c:	0541                	addi	a0,a0,16
    8000482e:	00001097          	auipc	ra,0x1
    80004832:	cb4080e7          	jalr	-844(ra) # 800054e2 <acquiresleep>
  if(ip->valid == 0){
    80004836:	40bc                	lw	a5,64(s1)
    80004838:	cf99                	beqz	a5,80004856 <ilock+0x40>
}
    8000483a:	60e2                	ld	ra,24(sp)
    8000483c:	6442                	ld	s0,16(sp)
    8000483e:	64a2                	ld	s1,8(sp)
    80004840:	6902                	ld	s2,0(sp)
    80004842:	6105                	addi	sp,sp,32
    80004844:	8082                	ret
    panic("ilock");
    80004846:	00005517          	auipc	a0,0x5
    8000484a:	f9250513          	addi	a0,a0,-110 # 800097d8 <syscalls+0x1b8>
    8000484e:	ffffc097          	auipc	ra,0xffffc
    80004852:	ce0080e7          	jalr	-800(ra) # 8000052e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004856:	40dc                	lw	a5,4(s1)
    80004858:	0047d79b          	srliw	a5,a5,0x4
    8000485c:	00037597          	auipc	a1,0x37
    80004860:	7bc5a583          	lw	a1,1980(a1) # 8003c018 <sb+0x18>
    80004864:	9dbd                	addw	a1,a1,a5
    80004866:	4088                	lw	a0,0(s1)
    80004868:	fffff097          	auipc	ra,0xfffff
    8000486c:	7aa080e7          	jalr	1962(ra) # 80004012 <bread>
    80004870:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004872:	05850593          	addi	a1,a0,88
    80004876:	40dc                	lw	a5,4(s1)
    80004878:	8bbd                	andi	a5,a5,15
    8000487a:	079a                	slli	a5,a5,0x6
    8000487c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000487e:	00059783          	lh	a5,0(a1)
    80004882:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004886:	00259783          	lh	a5,2(a1)
    8000488a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000488e:	00459783          	lh	a5,4(a1)
    80004892:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004896:	00659783          	lh	a5,6(a1)
    8000489a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000489e:	459c                	lw	a5,8(a1)
    800048a0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800048a2:	03400613          	li	a2,52
    800048a6:	05b1                	addi	a1,a1,12
    800048a8:	05048513          	addi	a0,s1,80
    800048ac:	ffffc097          	auipc	ra,0xffffc
    800048b0:	494080e7          	jalr	1172(ra) # 80000d40 <memmove>
    brelse(bp);
    800048b4:	854a                	mv	a0,s2
    800048b6:	00000097          	auipc	ra,0x0
    800048ba:	88c080e7          	jalr	-1908(ra) # 80004142 <brelse>
    ip->valid = 1;
    800048be:	4785                	li	a5,1
    800048c0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800048c2:	04449783          	lh	a5,68(s1)
    800048c6:	fbb5                	bnez	a5,8000483a <ilock+0x24>
      panic("ilock: no type");
    800048c8:	00005517          	auipc	a0,0x5
    800048cc:	f1850513          	addi	a0,a0,-232 # 800097e0 <syscalls+0x1c0>
    800048d0:	ffffc097          	auipc	ra,0xffffc
    800048d4:	c5e080e7          	jalr	-930(ra) # 8000052e <panic>

00000000800048d8 <iunlock>:
{
    800048d8:	1101                	addi	sp,sp,-32
    800048da:	ec06                	sd	ra,24(sp)
    800048dc:	e822                	sd	s0,16(sp)
    800048de:	e426                	sd	s1,8(sp)
    800048e0:	e04a                	sd	s2,0(sp)
    800048e2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800048e4:	c905                	beqz	a0,80004914 <iunlock+0x3c>
    800048e6:	84aa                	mv	s1,a0
    800048e8:	01050913          	addi	s2,a0,16
    800048ec:	854a                	mv	a0,s2
    800048ee:	00001097          	auipc	ra,0x1
    800048f2:	c8e080e7          	jalr	-882(ra) # 8000557c <holdingsleep>
    800048f6:	cd19                	beqz	a0,80004914 <iunlock+0x3c>
    800048f8:	449c                	lw	a5,8(s1)
    800048fa:	00f05d63          	blez	a5,80004914 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800048fe:	854a                	mv	a0,s2
    80004900:	00001097          	auipc	ra,0x1
    80004904:	c38080e7          	jalr	-968(ra) # 80005538 <releasesleep>
}
    80004908:	60e2                	ld	ra,24(sp)
    8000490a:	6442                	ld	s0,16(sp)
    8000490c:	64a2                	ld	s1,8(sp)
    8000490e:	6902                	ld	s2,0(sp)
    80004910:	6105                	addi	sp,sp,32
    80004912:	8082                	ret
    panic("iunlock");
    80004914:	00005517          	auipc	a0,0x5
    80004918:	edc50513          	addi	a0,a0,-292 # 800097f0 <syscalls+0x1d0>
    8000491c:	ffffc097          	auipc	ra,0xffffc
    80004920:	c12080e7          	jalr	-1006(ra) # 8000052e <panic>

0000000080004924 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004924:	7179                	addi	sp,sp,-48
    80004926:	f406                	sd	ra,40(sp)
    80004928:	f022                	sd	s0,32(sp)
    8000492a:	ec26                	sd	s1,24(sp)
    8000492c:	e84a                	sd	s2,16(sp)
    8000492e:	e44e                	sd	s3,8(sp)
    80004930:	e052                	sd	s4,0(sp)
    80004932:	1800                	addi	s0,sp,48
    80004934:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004936:	05050493          	addi	s1,a0,80
    8000493a:	08050913          	addi	s2,a0,128
    8000493e:	a021                	j	80004946 <itrunc+0x22>
    80004940:	0491                	addi	s1,s1,4
    80004942:	01248d63          	beq	s1,s2,8000495c <itrunc+0x38>
    if(ip->addrs[i]){
    80004946:	408c                	lw	a1,0(s1)
    80004948:	dde5                	beqz	a1,80004940 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000494a:	0009a503          	lw	a0,0(s3)
    8000494e:	00000097          	auipc	ra,0x0
    80004952:	90a080e7          	jalr	-1782(ra) # 80004258 <bfree>
      ip->addrs[i] = 0;
    80004956:	0004a023          	sw	zero,0(s1)
    8000495a:	b7dd                	j	80004940 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000495c:	0809a583          	lw	a1,128(s3)
    80004960:	e185                	bnez	a1,80004980 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004962:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004966:	854e                	mv	a0,s3
    80004968:	00000097          	auipc	ra,0x0
    8000496c:	de4080e7          	jalr	-540(ra) # 8000474c <iupdate>
}
    80004970:	70a2                	ld	ra,40(sp)
    80004972:	7402                	ld	s0,32(sp)
    80004974:	64e2                	ld	s1,24(sp)
    80004976:	6942                	ld	s2,16(sp)
    80004978:	69a2                	ld	s3,8(sp)
    8000497a:	6a02                	ld	s4,0(sp)
    8000497c:	6145                	addi	sp,sp,48
    8000497e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004980:	0009a503          	lw	a0,0(s3)
    80004984:	fffff097          	auipc	ra,0xfffff
    80004988:	68e080e7          	jalr	1678(ra) # 80004012 <bread>
    8000498c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000498e:	05850493          	addi	s1,a0,88
    80004992:	45850913          	addi	s2,a0,1112
    80004996:	a021                	j	8000499e <itrunc+0x7a>
    80004998:	0491                	addi	s1,s1,4
    8000499a:	01248b63          	beq	s1,s2,800049b0 <itrunc+0x8c>
      if(a[j])
    8000499e:	408c                	lw	a1,0(s1)
    800049a0:	dde5                	beqz	a1,80004998 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800049a2:	0009a503          	lw	a0,0(s3)
    800049a6:	00000097          	auipc	ra,0x0
    800049aa:	8b2080e7          	jalr	-1870(ra) # 80004258 <bfree>
    800049ae:	b7ed                	j	80004998 <itrunc+0x74>
    brelse(bp);
    800049b0:	8552                	mv	a0,s4
    800049b2:	fffff097          	auipc	ra,0xfffff
    800049b6:	790080e7          	jalr	1936(ra) # 80004142 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800049ba:	0809a583          	lw	a1,128(s3)
    800049be:	0009a503          	lw	a0,0(s3)
    800049c2:	00000097          	auipc	ra,0x0
    800049c6:	896080e7          	jalr	-1898(ra) # 80004258 <bfree>
    ip->addrs[NDIRECT] = 0;
    800049ca:	0809a023          	sw	zero,128(s3)
    800049ce:	bf51                	j	80004962 <itrunc+0x3e>

00000000800049d0 <iput>:
{
    800049d0:	1101                	addi	sp,sp,-32
    800049d2:	ec06                	sd	ra,24(sp)
    800049d4:	e822                	sd	s0,16(sp)
    800049d6:	e426                	sd	s1,8(sp)
    800049d8:	e04a                	sd	s2,0(sp)
    800049da:	1000                	addi	s0,sp,32
    800049dc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800049de:	00037517          	auipc	a0,0x37
    800049e2:	64250513          	addi	a0,a0,1602 # 8003c020 <itable>
    800049e6:	ffffc097          	auipc	ra,0xffffc
    800049ea:	1e0080e7          	jalr	480(ra) # 80000bc6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800049ee:	4498                	lw	a4,8(s1)
    800049f0:	4785                	li	a5,1
    800049f2:	02f70363          	beq	a4,a5,80004a18 <iput+0x48>
  ip->ref--;
    800049f6:	449c                	lw	a5,8(s1)
    800049f8:	37fd                	addiw	a5,a5,-1
    800049fa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800049fc:	00037517          	auipc	a0,0x37
    80004a00:	62450513          	addi	a0,a0,1572 # 8003c020 <itable>
    80004a04:	ffffc097          	auipc	ra,0xffffc
    80004a08:	298080e7          	jalr	664(ra) # 80000c9c <release>
}
    80004a0c:	60e2                	ld	ra,24(sp)
    80004a0e:	6442                	ld	s0,16(sp)
    80004a10:	64a2                	ld	s1,8(sp)
    80004a12:	6902                	ld	s2,0(sp)
    80004a14:	6105                	addi	sp,sp,32
    80004a16:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004a18:	40bc                	lw	a5,64(s1)
    80004a1a:	dff1                	beqz	a5,800049f6 <iput+0x26>
    80004a1c:	04a49783          	lh	a5,74(s1)
    80004a20:	fbf9                	bnez	a5,800049f6 <iput+0x26>
    acquiresleep(&ip->lock);
    80004a22:	01048913          	addi	s2,s1,16
    80004a26:	854a                	mv	a0,s2
    80004a28:	00001097          	auipc	ra,0x1
    80004a2c:	aba080e7          	jalr	-1350(ra) # 800054e2 <acquiresleep>
    release(&itable.lock);
    80004a30:	00037517          	auipc	a0,0x37
    80004a34:	5f050513          	addi	a0,a0,1520 # 8003c020 <itable>
    80004a38:	ffffc097          	auipc	ra,0xffffc
    80004a3c:	264080e7          	jalr	612(ra) # 80000c9c <release>
    itrunc(ip);
    80004a40:	8526                	mv	a0,s1
    80004a42:	00000097          	auipc	ra,0x0
    80004a46:	ee2080e7          	jalr	-286(ra) # 80004924 <itrunc>
    ip->type = 0;
    80004a4a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004a4e:	8526                	mv	a0,s1
    80004a50:	00000097          	auipc	ra,0x0
    80004a54:	cfc080e7          	jalr	-772(ra) # 8000474c <iupdate>
    ip->valid = 0;
    80004a58:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004a5c:	854a                	mv	a0,s2
    80004a5e:	00001097          	auipc	ra,0x1
    80004a62:	ada080e7          	jalr	-1318(ra) # 80005538 <releasesleep>
    acquire(&itable.lock);
    80004a66:	00037517          	auipc	a0,0x37
    80004a6a:	5ba50513          	addi	a0,a0,1466 # 8003c020 <itable>
    80004a6e:	ffffc097          	auipc	ra,0xffffc
    80004a72:	158080e7          	jalr	344(ra) # 80000bc6 <acquire>
    80004a76:	b741                	j	800049f6 <iput+0x26>

0000000080004a78 <iunlockput>:
{
    80004a78:	1101                	addi	sp,sp,-32
    80004a7a:	ec06                	sd	ra,24(sp)
    80004a7c:	e822                	sd	s0,16(sp)
    80004a7e:	e426                	sd	s1,8(sp)
    80004a80:	1000                	addi	s0,sp,32
    80004a82:	84aa                	mv	s1,a0
  iunlock(ip);
    80004a84:	00000097          	auipc	ra,0x0
    80004a88:	e54080e7          	jalr	-428(ra) # 800048d8 <iunlock>
  iput(ip);
    80004a8c:	8526                	mv	a0,s1
    80004a8e:	00000097          	auipc	ra,0x0
    80004a92:	f42080e7          	jalr	-190(ra) # 800049d0 <iput>
}
    80004a96:	60e2                	ld	ra,24(sp)
    80004a98:	6442                	ld	s0,16(sp)
    80004a9a:	64a2                	ld	s1,8(sp)
    80004a9c:	6105                	addi	sp,sp,32
    80004a9e:	8082                	ret

0000000080004aa0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004aa0:	1141                	addi	sp,sp,-16
    80004aa2:	e422                	sd	s0,8(sp)
    80004aa4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004aa6:	411c                	lw	a5,0(a0)
    80004aa8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004aaa:	415c                	lw	a5,4(a0)
    80004aac:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004aae:	04451783          	lh	a5,68(a0)
    80004ab2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004ab6:	04a51783          	lh	a5,74(a0)
    80004aba:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004abe:	04c56783          	lwu	a5,76(a0)
    80004ac2:	e99c                	sd	a5,16(a1)
}
    80004ac4:	6422                	ld	s0,8(sp)
    80004ac6:	0141                	addi	sp,sp,16
    80004ac8:	8082                	ret

0000000080004aca <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004aca:	457c                	lw	a5,76(a0)
    80004acc:	0ed7e963          	bltu	a5,a3,80004bbe <readi+0xf4>
{
    80004ad0:	7159                	addi	sp,sp,-112
    80004ad2:	f486                	sd	ra,104(sp)
    80004ad4:	f0a2                	sd	s0,96(sp)
    80004ad6:	eca6                	sd	s1,88(sp)
    80004ad8:	e8ca                	sd	s2,80(sp)
    80004ada:	e4ce                	sd	s3,72(sp)
    80004adc:	e0d2                	sd	s4,64(sp)
    80004ade:	fc56                	sd	s5,56(sp)
    80004ae0:	f85a                	sd	s6,48(sp)
    80004ae2:	f45e                	sd	s7,40(sp)
    80004ae4:	f062                	sd	s8,32(sp)
    80004ae6:	ec66                	sd	s9,24(sp)
    80004ae8:	e86a                	sd	s10,16(sp)
    80004aea:	e46e                	sd	s11,8(sp)
    80004aec:	1880                	addi	s0,sp,112
    80004aee:	8baa                	mv	s7,a0
    80004af0:	8c2e                	mv	s8,a1
    80004af2:	8ab2                	mv	s5,a2
    80004af4:	84b6                	mv	s1,a3
    80004af6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004af8:	9f35                	addw	a4,a4,a3
    return 0;
    80004afa:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004afc:	0ad76063          	bltu	a4,a3,80004b9c <readi+0xd2>
  if(off + n > ip->size)
    80004b00:	00e7f463          	bgeu	a5,a4,80004b08 <readi+0x3e>
    n = ip->size - off;
    80004b04:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004b08:	0a0b0963          	beqz	s6,80004bba <readi+0xf0>
    80004b0c:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004b0e:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004b12:	5cfd                	li	s9,-1
    80004b14:	a82d                	j	80004b4e <readi+0x84>
    80004b16:	020a1d93          	slli	s11,s4,0x20
    80004b1a:	020ddd93          	srli	s11,s11,0x20
    80004b1e:	05890793          	addi	a5,s2,88
    80004b22:	86ee                	mv	a3,s11
    80004b24:	963e                	add	a2,a2,a5
    80004b26:	85d6                	mv	a1,s5
    80004b28:	8562                	mv	a0,s8
    80004b2a:	ffffe097          	auipc	ra,0xffffe
    80004b2e:	eea080e7          	jalr	-278(ra) # 80002a14 <either_copyout>
    80004b32:	05950d63          	beq	a0,s9,80004b8c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004b36:	854a                	mv	a0,s2
    80004b38:	fffff097          	auipc	ra,0xfffff
    80004b3c:	60a080e7          	jalr	1546(ra) # 80004142 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004b40:	013a09bb          	addw	s3,s4,s3
    80004b44:	009a04bb          	addw	s1,s4,s1
    80004b48:	9aee                	add	s5,s5,s11
    80004b4a:	0569f763          	bgeu	s3,s6,80004b98 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004b4e:	000ba903          	lw	s2,0(s7)
    80004b52:	00a4d59b          	srliw	a1,s1,0xa
    80004b56:	855e                	mv	a0,s7
    80004b58:	00000097          	auipc	ra,0x0
    80004b5c:	8ae080e7          	jalr	-1874(ra) # 80004406 <bmap>
    80004b60:	0005059b          	sext.w	a1,a0
    80004b64:	854a                	mv	a0,s2
    80004b66:	fffff097          	auipc	ra,0xfffff
    80004b6a:	4ac080e7          	jalr	1196(ra) # 80004012 <bread>
    80004b6e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004b70:	3ff4f613          	andi	a2,s1,1023
    80004b74:	40cd07bb          	subw	a5,s10,a2
    80004b78:	413b073b          	subw	a4,s6,s3
    80004b7c:	8a3e                	mv	s4,a5
    80004b7e:	2781                	sext.w	a5,a5
    80004b80:	0007069b          	sext.w	a3,a4
    80004b84:	f8f6f9e3          	bgeu	a3,a5,80004b16 <readi+0x4c>
    80004b88:	8a3a                	mv	s4,a4
    80004b8a:	b771                	j	80004b16 <readi+0x4c>
      brelse(bp);
    80004b8c:	854a                	mv	a0,s2
    80004b8e:	fffff097          	auipc	ra,0xfffff
    80004b92:	5b4080e7          	jalr	1460(ra) # 80004142 <brelse>
      tot = -1;
    80004b96:	59fd                	li	s3,-1
  }
  return tot;
    80004b98:	0009851b          	sext.w	a0,s3
}
    80004b9c:	70a6                	ld	ra,104(sp)
    80004b9e:	7406                	ld	s0,96(sp)
    80004ba0:	64e6                	ld	s1,88(sp)
    80004ba2:	6946                	ld	s2,80(sp)
    80004ba4:	69a6                	ld	s3,72(sp)
    80004ba6:	6a06                	ld	s4,64(sp)
    80004ba8:	7ae2                	ld	s5,56(sp)
    80004baa:	7b42                	ld	s6,48(sp)
    80004bac:	7ba2                	ld	s7,40(sp)
    80004bae:	7c02                	ld	s8,32(sp)
    80004bb0:	6ce2                	ld	s9,24(sp)
    80004bb2:	6d42                	ld	s10,16(sp)
    80004bb4:	6da2                	ld	s11,8(sp)
    80004bb6:	6165                	addi	sp,sp,112
    80004bb8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004bba:	89da                	mv	s3,s6
    80004bbc:	bff1                	j	80004b98 <readi+0xce>
    return 0;
    80004bbe:	4501                	li	a0,0
}
    80004bc0:	8082                	ret

0000000080004bc2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004bc2:	457c                	lw	a5,76(a0)
    80004bc4:	10d7e863          	bltu	a5,a3,80004cd4 <writei+0x112>
{
    80004bc8:	7159                	addi	sp,sp,-112
    80004bca:	f486                	sd	ra,104(sp)
    80004bcc:	f0a2                	sd	s0,96(sp)
    80004bce:	eca6                	sd	s1,88(sp)
    80004bd0:	e8ca                	sd	s2,80(sp)
    80004bd2:	e4ce                	sd	s3,72(sp)
    80004bd4:	e0d2                	sd	s4,64(sp)
    80004bd6:	fc56                	sd	s5,56(sp)
    80004bd8:	f85a                	sd	s6,48(sp)
    80004bda:	f45e                	sd	s7,40(sp)
    80004bdc:	f062                	sd	s8,32(sp)
    80004bde:	ec66                	sd	s9,24(sp)
    80004be0:	e86a                	sd	s10,16(sp)
    80004be2:	e46e                	sd	s11,8(sp)
    80004be4:	1880                	addi	s0,sp,112
    80004be6:	8b2a                	mv	s6,a0
    80004be8:	8c2e                	mv	s8,a1
    80004bea:	8ab2                	mv	s5,a2
    80004bec:	8936                	mv	s2,a3
    80004bee:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004bf0:	00e687bb          	addw	a5,a3,a4
    80004bf4:	0ed7e263          	bltu	a5,a3,80004cd8 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004bf8:	00043737          	lui	a4,0x43
    80004bfc:	0ef76063          	bltu	a4,a5,80004cdc <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004c00:	0c0b8863          	beqz	s7,80004cd0 <writei+0x10e>
    80004c04:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004c06:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004c0a:	5cfd                	li	s9,-1
    80004c0c:	a091                	j	80004c50 <writei+0x8e>
    80004c0e:	02099d93          	slli	s11,s3,0x20
    80004c12:	020ddd93          	srli	s11,s11,0x20
    80004c16:	05848793          	addi	a5,s1,88
    80004c1a:	86ee                	mv	a3,s11
    80004c1c:	8656                	mv	a2,s5
    80004c1e:	85e2                	mv	a1,s8
    80004c20:	953e                	add	a0,a0,a5
    80004c22:	ffffe097          	auipc	ra,0xffffe
    80004c26:	e48080e7          	jalr	-440(ra) # 80002a6a <either_copyin>
    80004c2a:	07950263          	beq	a0,s9,80004c8e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004c2e:	8526                	mv	a0,s1
    80004c30:	00000097          	auipc	ra,0x0
    80004c34:	792080e7          	jalr	1938(ra) # 800053c2 <log_write>
    brelse(bp);
    80004c38:	8526                	mv	a0,s1
    80004c3a:	fffff097          	auipc	ra,0xfffff
    80004c3e:	508080e7          	jalr	1288(ra) # 80004142 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004c42:	01498a3b          	addw	s4,s3,s4
    80004c46:	0129893b          	addw	s2,s3,s2
    80004c4a:	9aee                	add	s5,s5,s11
    80004c4c:	057a7663          	bgeu	s4,s7,80004c98 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004c50:	000b2483          	lw	s1,0(s6)
    80004c54:	00a9559b          	srliw	a1,s2,0xa
    80004c58:	855a                	mv	a0,s6
    80004c5a:	fffff097          	auipc	ra,0xfffff
    80004c5e:	7ac080e7          	jalr	1964(ra) # 80004406 <bmap>
    80004c62:	0005059b          	sext.w	a1,a0
    80004c66:	8526                	mv	a0,s1
    80004c68:	fffff097          	auipc	ra,0xfffff
    80004c6c:	3aa080e7          	jalr	938(ra) # 80004012 <bread>
    80004c70:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004c72:	3ff97513          	andi	a0,s2,1023
    80004c76:	40ad07bb          	subw	a5,s10,a0
    80004c7a:	414b873b          	subw	a4,s7,s4
    80004c7e:	89be                	mv	s3,a5
    80004c80:	2781                	sext.w	a5,a5
    80004c82:	0007069b          	sext.w	a3,a4
    80004c86:	f8f6f4e3          	bgeu	a3,a5,80004c0e <writei+0x4c>
    80004c8a:	89ba                	mv	s3,a4
    80004c8c:	b749                	j	80004c0e <writei+0x4c>
      brelse(bp);
    80004c8e:	8526                	mv	a0,s1
    80004c90:	fffff097          	auipc	ra,0xfffff
    80004c94:	4b2080e7          	jalr	1202(ra) # 80004142 <brelse>
  }

  if(off > ip->size)
    80004c98:	04cb2783          	lw	a5,76(s6)
    80004c9c:	0127f463          	bgeu	a5,s2,80004ca4 <writei+0xe2>
    ip->size = off;
    80004ca0:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004ca4:	855a                	mv	a0,s6
    80004ca6:	00000097          	auipc	ra,0x0
    80004caa:	aa6080e7          	jalr	-1370(ra) # 8000474c <iupdate>

  return tot;
    80004cae:	000a051b          	sext.w	a0,s4
}
    80004cb2:	70a6                	ld	ra,104(sp)
    80004cb4:	7406                	ld	s0,96(sp)
    80004cb6:	64e6                	ld	s1,88(sp)
    80004cb8:	6946                	ld	s2,80(sp)
    80004cba:	69a6                	ld	s3,72(sp)
    80004cbc:	6a06                	ld	s4,64(sp)
    80004cbe:	7ae2                	ld	s5,56(sp)
    80004cc0:	7b42                	ld	s6,48(sp)
    80004cc2:	7ba2                	ld	s7,40(sp)
    80004cc4:	7c02                	ld	s8,32(sp)
    80004cc6:	6ce2                	ld	s9,24(sp)
    80004cc8:	6d42                	ld	s10,16(sp)
    80004cca:	6da2                	ld	s11,8(sp)
    80004ccc:	6165                	addi	sp,sp,112
    80004cce:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004cd0:	8a5e                	mv	s4,s7
    80004cd2:	bfc9                	j	80004ca4 <writei+0xe2>
    return -1;
    80004cd4:	557d                	li	a0,-1
}
    80004cd6:	8082                	ret
    return -1;
    80004cd8:	557d                	li	a0,-1
    80004cda:	bfe1                	j	80004cb2 <writei+0xf0>
    return -1;
    80004cdc:	557d                	li	a0,-1
    80004cde:	bfd1                	j	80004cb2 <writei+0xf0>

0000000080004ce0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004ce0:	1141                	addi	sp,sp,-16
    80004ce2:	e406                	sd	ra,8(sp)
    80004ce4:	e022                	sd	s0,0(sp)
    80004ce6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004ce8:	4639                	li	a2,14
    80004cea:	ffffc097          	auipc	ra,0xffffc
    80004cee:	0d2080e7          	jalr	210(ra) # 80000dbc <strncmp>
}
    80004cf2:	60a2                	ld	ra,8(sp)
    80004cf4:	6402                	ld	s0,0(sp)
    80004cf6:	0141                	addi	sp,sp,16
    80004cf8:	8082                	ret

0000000080004cfa <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004cfa:	7139                	addi	sp,sp,-64
    80004cfc:	fc06                	sd	ra,56(sp)
    80004cfe:	f822                	sd	s0,48(sp)
    80004d00:	f426                	sd	s1,40(sp)
    80004d02:	f04a                	sd	s2,32(sp)
    80004d04:	ec4e                	sd	s3,24(sp)
    80004d06:	e852                	sd	s4,16(sp)
    80004d08:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004d0a:	04451703          	lh	a4,68(a0)
    80004d0e:	4785                	li	a5,1
    80004d10:	00f71a63          	bne	a4,a5,80004d24 <dirlookup+0x2a>
    80004d14:	892a                	mv	s2,a0
    80004d16:	89ae                	mv	s3,a1
    80004d18:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d1a:	457c                	lw	a5,76(a0)
    80004d1c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004d1e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d20:	e79d                	bnez	a5,80004d4e <dirlookup+0x54>
    80004d22:	a8a5                	j	80004d9a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004d24:	00005517          	auipc	a0,0x5
    80004d28:	ad450513          	addi	a0,a0,-1324 # 800097f8 <syscalls+0x1d8>
    80004d2c:	ffffc097          	auipc	ra,0xffffc
    80004d30:	802080e7          	jalr	-2046(ra) # 8000052e <panic>
      panic("dirlookup read");
    80004d34:	00005517          	auipc	a0,0x5
    80004d38:	adc50513          	addi	a0,a0,-1316 # 80009810 <syscalls+0x1f0>
    80004d3c:	ffffb097          	auipc	ra,0xffffb
    80004d40:	7f2080e7          	jalr	2034(ra) # 8000052e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d44:	24c1                	addiw	s1,s1,16
    80004d46:	04c92783          	lw	a5,76(s2)
    80004d4a:	04f4f763          	bgeu	s1,a5,80004d98 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d4e:	4741                	li	a4,16
    80004d50:	86a6                	mv	a3,s1
    80004d52:	fc040613          	addi	a2,s0,-64
    80004d56:	4581                	li	a1,0
    80004d58:	854a                	mv	a0,s2
    80004d5a:	00000097          	auipc	ra,0x0
    80004d5e:	d70080e7          	jalr	-656(ra) # 80004aca <readi>
    80004d62:	47c1                	li	a5,16
    80004d64:	fcf518e3          	bne	a0,a5,80004d34 <dirlookup+0x3a>
    if(de.inum == 0)
    80004d68:	fc045783          	lhu	a5,-64(s0)
    80004d6c:	dfe1                	beqz	a5,80004d44 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004d6e:	fc240593          	addi	a1,s0,-62
    80004d72:	854e                	mv	a0,s3
    80004d74:	00000097          	auipc	ra,0x0
    80004d78:	f6c080e7          	jalr	-148(ra) # 80004ce0 <namecmp>
    80004d7c:	f561                	bnez	a0,80004d44 <dirlookup+0x4a>
      if(poff)
    80004d7e:	000a0463          	beqz	s4,80004d86 <dirlookup+0x8c>
        *poff = off;
    80004d82:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004d86:	fc045583          	lhu	a1,-64(s0)
    80004d8a:	00092503          	lw	a0,0(s2)
    80004d8e:	fffff097          	auipc	ra,0xfffff
    80004d92:	754080e7          	jalr	1876(ra) # 800044e2 <iget>
    80004d96:	a011                	j	80004d9a <dirlookup+0xa0>
  return 0;
    80004d98:	4501                	li	a0,0
}
    80004d9a:	70e2                	ld	ra,56(sp)
    80004d9c:	7442                	ld	s0,48(sp)
    80004d9e:	74a2                	ld	s1,40(sp)
    80004da0:	7902                	ld	s2,32(sp)
    80004da2:	69e2                	ld	s3,24(sp)
    80004da4:	6a42                	ld	s4,16(sp)
    80004da6:	6121                	addi	sp,sp,64
    80004da8:	8082                	ret

0000000080004daa <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004daa:	711d                	addi	sp,sp,-96
    80004dac:	ec86                	sd	ra,88(sp)
    80004dae:	e8a2                	sd	s0,80(sp)
    80004db0:	e4a6                	sd	s1,72(sp)
    80004db2:	e0ca                	sd	s2,64(sp)
    80004db4:	fc4e                	sd	s3,56(sp)
    80004db6:	f852                	sd	s4,48(sp)
    80004db8:	f456                	sd	s5,40(sp)
    80004dba:	f05a                	sd	s6,32(sp)
    80004dbc:	ec5e                	sd	s7,24(sp)
    80004dbe:	e862                	sd	s8,16(sp)
    80004dc0:	e466                	sd	s9,8(sp)
    80004dc2:	1080                	addi	s0,sp,96
    80004dc4:	84aa                	mv	s1,a0
    80004dc6:	8aae                	mv	s5,a1
    80004dc8:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004dca:	00054703          	lbu	a4,0(a0)
    80004dce:	02f00793          	li	a5,47
    80004dd2:	02f70263          	beq	a4,a5,80004df6 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004dd6:	ffffd097          	auipc	ra,0xffffd
    80004dda:	ca6080e7          	jalr	-858(ra) # 80001a7c <myproc>
    80004dde:	6968                	ld	a0,208(a0)
    80004de0:	00000097          	auipc	ra,0x0
    80004de4:	9f8080e7          	jalr	-1544(ra) # 800047d8 <idup>
    80004de8:	89aa                	mv	s3,a0
  while(*path == '/')
    80004dea:	02f00913          	li	s2,47
  len = path - s;
    80004dee:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004df0:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004df2:	4b85                	li	s7,1
    80004df4:	a865                	j	80004eac <namex+0x102>
    ip = iget(ROOTDEV, ROOTINO);
    80004df6:	4585                	li	a1,1
    80004df8:	4505                	li	a0,1
    80004dfa:	fffff097          	auipc	ra,0xfffff
    80004dfe:	6e8080e7          	jalr	1768(ra) # 800044e2 <iget>
    80004e02:	89aa                	mv	s3,a0
    80004e04:	b7dd                	j	80004dea <namex+0x40>
      iunlockput(ip);
    80004e06:	854e                	mv	a0,s3
    80004e08:	00000097          	auipc	ra,0x0
    80004e0c:	c70080e7          	jalr	-912(ra) # 80004a78 <iunlockput>
      return 0;
    80004e10:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004e12:	854e                	mv	a0,s3
    80004e14:	60e6                	ld	ra,88(sp)
    80004e16:	6446                	ld	s0,80(sp)
    80004e18:	64a6                	ld	s1,72(sp)
    80004e1a:	6906                	ld	s2,64(sp)
    80004e1c:	79e2                	ld	s3,56(sp)
    80004e1e:	7a42                	ld	s4,48(sp)
    80004e20:	7aa2                	ld	s5,40(sp)
    80004e22:	7b02                	ld	s6,32(sp)
    80004e24:	6be2                	ld	s7,24(sp)
    80004e26:	6c42                	ld	s8,16(sp)
    80004e28:	6ca2                	ld	s9,8(sp)
    80004e2a:	6125                	addi	sp,sp,96
    80004e2c:	8082                	ret
      iunlock(ip);
    80004e2e:	854e                	mv	a0,s3
    80004e30:	00000097          	auipc	ra,0x0
    80004e34:	aa8080e7          	jalr	-1368(ra) # 800048d8 <iunlock>
      return ip;
    80004e38:	bfe9                	j	80004e12 <namex+0x68>
      iunlockput(ip);
    80004e3a:	854e                	mv	a0,s3
    80004e3c:	00000097          	auipc	ra,0x0
    80004e40:	c3c080e7          	jalr	-964(ra) # 80004a78 <iunlockput>
      return 0;
    80004e44:	89e6                	mv	s3,s9
    80004e46:	b7f1                	j	80004e12 <namex+0x68>
  len = path - s;
    80004e48:	40b48633          	sub	a2,s1,a1
    80004e4c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004e50:	099c5463          	bge	s8,s9,80004ed8 <namex+0x12e>
    memmove(name, s, DIRSIZ);
    80004e54:	4639                	li	a2,14
    80004e56:	8552                	mv	a0,s4
    80004e58:	ffffc097          	auipc	ra,0xffffc
    80004e5c:	ee8080e7          	jalr	-280(ra) # 80000d40 <memmove>
  while(*path == '/')
    80004e60:	0004c783          	lbu	a5,0(s1)
    80004e64:	01279763          	bne	a5,s2,80004e72 <namex+0xc8>
    path++;
    80004e68:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004e6a:	0004c783          	lbu	a5,0(s1)
    80004e6e:	ff278de3          	beq	a5,s2,80004e68 <namex+0xbe>
    ilock(ip);
    80004e72:	854e                	mv	a0,s3
    80004e74:	00000097          	auipc	ra,0x0
    80004e78:	9a2080e7          	jalr	-1630(ra) # 80004816 <ilock>
    if(ip->type != T_DIR){
    80004e7c:	04499783          	lh	a5,68(s3)
    80004e80:	f97793e3          	bne	a5,s7,80004e06 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004e84:	000a8563          	beqz	s5,80004e8e <namex+0xe4>
    80004e88:	0004c783          	lbu	a5,0(s1)
    80004e8c:	d3cd                	beqz	a5,80004e2e <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004e8e:	865a                	mv	a2,s6
    80004e90:	85d2                	mv	a1,s4
    80004e92:	854e                	mv	a0,s3
    80004e94:	00000097          	auipc	ra,0x0
    80004e98:	e66080e7          	jalr	-410(ra) # 80004cfa <dirlookup>
    80004e9c:	8caa                	mv	s9,a0
    80004e9e:	dd51                	beqz	a0,80004e3a <namex+0x90>
    iunlockput(ip);
    80004ea0:	854e                	mv	a0,s3
    80004ea2:	00000097          	auipc	ra,0x0
    80004ea6:	bd6080e7          	jalr	-1066(ra) # 80004a78 <iunlockput>
    ip = next;
    80004eaa:	89e6                	mv	s3,s9
  while(*path == '/')
    80004eac:	0004c783          	lbu	a5,0(s1)
    80004eb0:	05279763          	bne	a5,s2,80004efe <namex+0x154>
    path++;
    80004eb4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004eb6:	0004c783          	lbu	a5,0(s1)
    80004eba:	ff278de3          	beq	a5,s2,80004eb4 <namex+0x10a>
  if(*path == 0)
    80004ebe:	c79d                	beqz	a5,80004eec <namex+0x142>
    path++;
    80004ec0:	85a6                	mv	a1,s1
  len = path - s;
    80004ec2:	8cda                	mv	s9,s6
    80004ec4:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004ec6:	01278963          	beq	a5,s2,80004ed8 <namex+0x12e>
    80004eca:	dfbd                	beqz	a5,80004e48 <namex+0x9e>
    path++;
    80004ecc:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004ece:	0004c783          	lbu	a5,0(s1)
    80004ed2:	ff279ce3          	bne	a5,s2,80004eca <namex+0x120>
    80004ed6:	bf8d                	j	80004e48 <namex+0x9e>
    memmove(name, s, len);
    80004ed8:	2601                	sext.w	a2,a2
    80004eda:	8552                	mv	a0,s4
    80004edc:	ffffc097          	auipc	ra,0xffffc
    80004ee0:	e64080e7          	jalr	-412(ra) # 80000d40 <memmove>
    name[len] = 0;
    80004ee4:	9cd2                	add	s9,s9,s4
    80004ee6:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004eea:	bf9d                	j	80004e60 <namex+0xb6>
  if(nameiparent){
    80004eec:	f20a83e3          	beqz	s5,80004e12 <namex+0x68>
    iput(ip);
    80004ef0:	854e                	mv	a0,s3
    80004ef2:	00000097          	auipc	ra,0x0
    80004ef6:	ade080e7          	jalr	-1314(ra) # 800049d0 <iput>
    return 0;
    80004efa:	4981                	li	s3,0
    80004efc:	bf19                	j	80004e12 <namex+0x68>
  if(*path == 0)
    80004efe:	d7fd                	beqz	a5,80004eec <namex+0x142>
  while(*path != '/' && *path != 0)
    80004f00:	0004c783          	lbu	a5,0(s1)
    80004f04:	85a6                	mv	a1,s1
    80004f06:	b7d1                	j	80004eca <namex+0x120>

0000000080004f08 <dirlink>:
{
    80004f08:	7139                	addi	sp,sp,-64
    80004f0a:	fc06                	sd	ra,56(sp)
    80004f0c:	f822                	sd	s0,48(sp)
    80004f0e:	f426                	sd	s1,40(sp)
    80004f10:	f04a                	sd	s2,32(sp)
    80004f12:	ec4e                	sd	s3,24(sp)
    80004f14:	e852                	sd	s4,16(sp)
    80004f16:	0080                	addi	s0,sp,64
    80004f18:	892a                	mv	s2,a0
    80004f1a:	8a2e                	mv	s4,a1
    80004f1c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004f1e:	4601                	li	a2,0
    80004f20:	00000097          	auipc	ra,0x0
    80004f24:	dda080e7          	jalr	-550(ra) # 80004cfa <dirlookup>
    80004f28:	e93d                	bnez	a0,80004f9e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004f2a:	04c92483          	lw	s1,76(s2)
    80004f2e:	c49d                	beqz	s1,80004f5c <dirlink+0x54>
    80004f30:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f32:	4741                	li	a4,16
    80004f34:	86a6                	mv	a3,s1
    80004f36:	fc040613          	addi	a2,s0,-64
    80004f3a:	4581                	li	a1,0
    80004f3c:	854a                	mv	a0,s2
    80004f3e:	00000097          	auipc	ra,0x0
    80004f42:	b8c080e7          	jalr	-1140(ra) # 80004aca <readi>
    80004f46:	47c1                	li	a5,16
    80004f48:	06f51163          	bne	a0,a5,80004faa <dirlink+0xa2>
    if(de.inum == 0)
    80004f4c:	fc045783          	lhu	a5,-64(s0)
    80004f50:	c791                	beqz	a5,80004f5c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004f52:	24c1                	addiw	s1,s1,16
    80004f54:	04c92783          	lw	a5,76(s2)
    80004f58:	fcf4ede3          	bltu	s1,a5,80004f32 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004f5c:	4639                	li	a2,14
    80004f5e:	85d2                	mv	a1,s4
    80004f60:	fc240513          	addi	a0,s0,-62
    80004f64:	ffffc097          	auipc	ra,0xffffc
    80004f68:	e94080e7          	jalr	-364(ra) # 80000df8 <strncpy>
  de.inum = inum;
    80004f6c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f70:	4741                	li	a4,16
    80004f72:	86a6                	mv	a3,s1
    80004f74:	fc040613          	addi	a2,s0,-64
    80004f78:	4581                	li	a1,0
    80004f7a:	854a                	mv	a0,s2
    80004f7c:	00000097          	auipc	ra,0x0
    80004f80:	c46080e7          	jalr	-954(ra) # 80004bc2 <writei>
    80004f84:	872a                	mv	a4,a0
    80004f86:	47c1                	li	a5,16
  return 0;
    80004f88:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f8a:	02f71863          	bne	a4,a5,80004fba <dirlink+0xb2>
}
    80004f8e:	70e2                	ld	ra,56(sp)
    80004f90:	7442                	ld	s0,48(sp)
    80004f92:	74a2                	ld	s1,40(sp)
    80004f94:	7902                	ld	s2,32(sp)
    80004f96:	69e2                	ld	s3,24(sp)
    80004f98:	6a42                	ld	s4,16(sp)
    80004f9a:	6121                	addi	sp,sp,64
    80004f9c:	8082                	ret
    iput(ip);
    80004f9e:	00000097          	auipc	ra,0x0
    80004fa2:	a32080e7          	jalr	-1486(ra) # 800049d0 <iput>
    return -1;
    80004fa6:	557d                	li	a0,-1
    80004fa8:	b7dd                	j	80004f8e <dirlink+0x86>
      panic("dirlink read");
    80004faa:	00005517          	auipc	a0,0x5
    80004fae:	87650513          	addi	a0,a0,-1930 # 80009820 <syscalls+0x200>
    80004fb2:	ffffb097          	auipc	ra,0xffffb
    80004fb6:	57c080e7          	jalr	1404(ra) # 8000052e <panic>
    panic("dirlink");
    80004fba:	00005517          	auipc	a0,0x5
    80004fbe:	97650513          	addi	a0,a0,-1674 # 80009930 <syscalls+0x310>
    80004fc2:	ffffb097          	auipc	ra,0xffffb
    80004fc6:	56c080e7          	jalr	1388(ra) # 8000052e <panic>

0000000080004fca <namei>:

struct inode*
namei(char *path)
{
    80004fca:	1101                	addi	sp,sp,-32
    80004fcc:	ec06                	sd	ra,24(sp)
    80004fce:	e822                	sd	s0,16(sp)
    80004fd0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004fd2:	fe040613          	addi	a2,s0,-32
    80004fd6:	4581                	li	a1,0
    80004fd8:	00000097          	auipc	ra,0x0
    80004fdc:	dd2080e7          	jalr	-558(ra) # 80004daa <namex>
}
    80004fe0:	60e2                	ld	ra,24(sp)
    80004fe2:	6442                	ld	s0,16(sp)
    80004fe4:	6105                	addi	sp,sp,32
    80004fe6:	8082                	ret

0000000080004fe8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004fe8:	1141                	addi	sp,sp,-16
    80004fea:	e406                	sd	ra,8(sp)
    80004fec:	e022                	sd	s0,0(sp)
    80004fee:	0800                	addi	s0,sp,16
    80004ff0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004ff2:	4585                	li	a1,1
    80004ff4:	00000097          	auipc	ra,0x0
    80004ff8:	db6080e7          	jalr	-586(ra) # 80004daa <namex>
}
    80004ffc:	60a2                	ld	ra,8(sp)
    80004ffe:	6402                	ld	s0,0(sp)
    80005000:	0141                	addi	sp,sp,16
    80005002:	8082                	ret

0000000080005004 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80005004:	1101                	addi	sp,sp,-32
    80005006:	ec06                	sd	ra,24(sp)
    80005008:	e822                	sd	s0,16(sp)
    8000500a:	e426                	sd	s1,8(sp)
    8000500c:	e04a                	sd	s2,0(sp)
    8000500e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80005010:	00039917          	auipc	s2,0x39
    80005014:	ab890913          	addi	s2,s2,-1352 # 8003dac8 <log>
    80005018:	01892583          	lw	a1,24(s2)
    8000501c:	02892503          	lw	a0,40(s2)
    80005020:	fffff097          	auipc	ra,0xfffff
    80005024:	ff2080e7          	jalr	-14(ra) # 80004012 <bread>
    80005028:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000502a:	02c92683          	lw	a3,44(s2)
    8000502e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80005030:	02d05863          	blez	a3,80005060 <write_head+0x5c>
    80005034:	00039797          	auipc	a5,0x39
    80005038:	ac478793          	addi	a5,a5,-1340 # 8003daf8 <log+0x30>
    8000503c:	05c50713          	addi	a4,a0,92
    80005040:	36fd                	addiw	a3,a3,-1
    80005042:	02069613          	slli	a2,a3,0x20
    80005046:	01e65693          	srli	a3,a2,0x1e
    8000504a:	00039617          	auipc	a2,0x39
    8000504e:	ab260613          	addi	a2,a2,-1358 # 8003dafc <log+0x34>
    80005052:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80005054:	4390                	lw	a2,0(a5)
    80005056:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005058:	0791                	addi	a5,a5,4
    8000505a:	0711                	addi	a4,a4,4
    8000505c:	fed79ce3          	bne	a5,a3,80005054 <write_head+0x50>
  }
  bwrite(buf);
    80005060:	8526                	mv	a0,s1
    80005062:	fffff097          	auipc	ra,0xfffff
    80005066:	0a2080e7          	jalr	162(ra) # 80004104 <bwrite>
  brelse(buf);
    8000506a:	8526                	mv	a0,s1
    8000506c:	fffff097          	auipc	ra,0xfffff
    80005070:	0d6080e7          	jalr	214(ra) # 80004142 <brelse>
}
    80005074:	60e2                	ld	ra,24(sp)
    80005076:	6442                	ld	s0,16(sp)
    80005078:	64a2                	ld	s1,8(sp)
    8000507a:	6902                	ld	s2,0(sp)
    8000507c:	6105                	addi	sp,sp,32
    8000507e:	8082                	ret

0000000080005080 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80005080:	00039797          	auipc	a5,0x39
    80005084:	a747a783          	lw	a5,-1420(a5) # 8003daf4 <log+0x2c>
    80005088:	0af05d63          	blez	a5,80005142 <install_trans+0xc2>
{
    8000508c:	7139                	addi	sp,sp,-64
    8000508e:	fc06                	sd	ra,56(sp)
    80005090:	f822                	sd	s0,48(sp)
    80005092:	f426                	sd	s1,40(sp)
    80005094:	f04a                	sd	s2,32(sp)
    80005096:	ec4e                	sd	s3,24(sp)
    80005098:	e852                	sd	s4,16(sp)
    8000509a:	e456                	sd	s5,8(sp)
    8000509c:	e05a                	sd	s6,0(sp)
    8000509e:	0080                	addi	s0,sp,64
    800050a0:	8b2a                	mv	s6,a0
    800050a2:	00039a97          	auipc	s5,0x39
    800050a6:	a56a8a93          	addi	s5,s5,-1450 # 8003daf8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800050aa:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800050ac:	00039997          	auipc	s3,0x39
    800050b0:	a1c98993          	addi	s3,s3,-1508 # 8003dac8 <log>
    800050b4:	a00d                	j	800050d6 <install_trans+0x56>
    brelse(lbuf);
    800050b6:	854a                	mv	a0,s2
    800050b8:	fffff097          	auipc	ra,0xfffff
    800050bc:	08a080e7          	jalr	138(ra) # 80004142 <brelse>
    brelse(dbuf);
    800050c0:	8526                	mv	a0,s1
    800050c2:	fffff097          	auipc	ra,0xfffff
    800050c6:	080080e7          	jalr	128(ra) # 80004142 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800050ca:	2a05                	addiw	s4,s4,1
    800050cc:	0a91                	addi	s5,s5,4
    800050ce:	02c9a783          	lw	a5,44(s3)
    800050d2:	04fa5e63          	bge	s4,a5,8000512e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800050d6:	0189a583          	lw	a1,24(s3)
    800050da:	014585bb          	addw	a1,a1,s4
    800050de:	2585                	addiw	a1,a1,1
    800050e0:	0289a503          	lw	a0,40(s3)
    800050e4:	fffff097          	auipc	ra,0xfffff
    800050e8:	f2e080e7          	jalr	-210(ra) # 80004012 <bread>
    800050ec:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800050ee:	000aa583          	lw	a1,0(s5)
    800050f2:	0289a503          	lw	a0,40(s3)
    800050f6:	fffff097          	auipc	ra,0xfffff
    800050fa:	f1c080e7          	jalr	-228(ra) # 80004012 <bread>
    800050fe:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80005100:	40000613          	li	a2,1024
    80005104:	05890593          	addi	a1,s2,88
    80005108:	05850513          	addi	a0,a0,88
    8000510c:	ffffc097          	auipc	ra,0xffffc
    80005110:	c34080e7          	jalr	-972(ra) # 80000d40 <memmove>
    bwrite(dbuf);  // write dst to disk
    80005114:	8526                	mv	a0,s1
    80005116:	fffff097          	auipc	ra,0xfffff
    8000511a:	fee080e7          	jalr	-18(ra) # 80004104 <bwrite>
    if(recovering == 0)
    8000511e:	f80b1ce3          	bnez	s6,800050b6 <install_trans+0x36>
      bunpin(dbuf);
    80005122:	8526                	mv	a0,s1
    80005124:	fffff097          	auipc	ra,0xfffff
    80005128:	0f8080e7          	jalr	248(ra) # 8000421c <bunpin>
    8000512c:	b769                	j	800050b6 <install_trans+0x36>
}
    8000512e:	70e2                	ld	ra,56(sp)
    80005130:	7442                	ld	s0,48(sp)
    80005132:	74a2                	ld	s1,40(sp)
    80005134:	7902                	ld	s2,32(sp)
    80005136:	69e2                	ld	s3,24(sp)
    80005138:	6a42                	ld	s4,16(sp)
    8000513a:	6aa2                	ld	s5,8(sp)
    8000513c:	6b02                	ld	s6,0(sp)
    8000513e:	6121                	addi	sp,sp,64
    80005140:	8082                	ret
    80005142:	8082                	ret

0000000080005144 <initlog>:
{
    80005144:	7179                	addi	sp,sp,-48
    80005146:	f406                	sd	ra,40(sp)
    80005148:	f022                	sd	s0,32(sp)
    8000514a:	ec26                	sd	s1,24(sp)
    8000514c:	e84a                	sd	s2,16(sp)
    8000514e:	e44e                	sd	s3,8(sp)
    80005150:	1800                	addi	s0,sp,48
    80005152:	892a                	mv	s2,a0
    80005154:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80005156:	00039497          	auipc	s1,0x39
    8000515a:	97248493          	addi	s1,s1,-1678 # 8003dac8 <log>
    8000515e:	00004597          	auipc	a1,0x4
    80005162:	6d258593          	addi	a1,a1,1746 # 80009830 <syscalls+0x210>
    80005166:	8526                	mv	a0,s1
    80005168:	ffffc097          	auipc	ra,0xffffc
    8000516c:	9ce080e7          	jalr	-1586(ra) # 80000b36 <initlock>
  log.start = sb->logstart;
    80005170:	0149a583          	lw	a1,20(s3)
    80005174:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80005176:	0109a783          	lw	a5,16(s3)
    8000517a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000517c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80005180:	854a                	mv	a0,s2
    80005182:	fffff097          	auipc	ra,0xfffff
    80005186:	e90080e7          	jalr	-368(ra) # 80004012 <bread>
  log.lh.n = lh->n;
    8000518a:	4d34                	lw	a3,88(a0)
    8000518c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000518e:	02d05663          	blez	a3,800051ba <initlog+0x76>
    80005192:	05c50793          	addi	a5,a0,92
    80005196:	00039717          	auipc	a4,0x39
    8000519a:	96270713          	addi	a4,a4,-1694 # 8003daf8 <log+0x30>
    8000519e:	36fd                	addiw	a3,a3,-1
    800051a0:	02069613          	slli	a2,a3,0x20
    800051a4:	01e65693          	srli	a3,a2,0x1e
    800051a8:	06050613          	addi	a2,a0,96
    800051ac:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800051ae:	4390                	lw	a2,0(a5)
    800051b0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800051b2:	0791                	addi	a5,a5,4
    800051b4:	0711                	addi	a4,a4,4
    800051b6:	fed79ce3          	bne	a5,a3,800051ae <initlog+0x6a>
  brelse(buf);
    800051ba:	fffff097          	auipc	ra,0xfffff
    800051be:	f88080e7          	jalr	-120(ra) # 80004142 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800051c2:	4505                	li	a0,1
    800051c4:	00000097          	auipc	ra,0x0
    800051c8:	ebc080e7          	jalr	-324(ra) # 80005080 <install_trans>
  log.lh.n = 0;
    800051cc:	00039797          	auipc	a5,0x39
    800051d0:	9207a423          	sw	zero,-1752(a5) # 8003daf4 <log+0x2c>
  write_head(); // clear the log
    800051d4:	00000097          	auipc	ra,0x0
    800051d8:	e30080e7          	jalr	-464(ra) # 80005004 <write_head>
}
    800051dc:	70a2                	ld	ra,40(sp)
    800051de:	7402                	ld	s0,32(sp)
    800051e0:	64e2                	ld	s1,24(sp)
    800051e2:	6942                	ld	s2,16(sp)
    800051e4:	69a2                	ld	s3,8(sp)
    800051e6:	6145                	addi	sp,sp,48
    800051e8:	8082                	ret

00000000800051ea <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800051ea:	1101                	addi	sp,sp,-32
    800051ec:	ec06                	sd	ra,24(sp)
    800051ee:	e822                	sd	s0,16(sp)
    800051f0:	e426                	sd	s1,8(sp)
    800051f2:	e04a                	sd	s2,0(sp)
    800051f4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800051f6:	00039517          	auipc	a0,0x39
    800051fa:	8d250513          	addi	a0,a0,-1838 # 8003dac8 <log>
    800051fe:	ffffc097          	auipc	ra,0xffffc
    80005202:	9c8080e7          	jalr	-1592(ra) # 80000bc6 <acquire>
  while(1){
    if(log.committing){
    80005206:	00039497          	auipc	s1,0x39
    8000520a:	8c248493          	addi	s1,s1,-1854 # 8003dac8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000520e:	4979                	li	s2,30
    80005210:	a039                	j	8000521e <begin_op+0x34>
      sleep(&log, &log.lock);
    80005212:	85a6                	mv	a1,s1
    80005214:	8526                	mv	a0,s1
    80005216:	ffffd097          	auipc	ra,0xffffd
    8000521a:	1ee080e7          	jalr	494(ra) # 80002404 <sleep>
    if(log.committing){
    8000521e:	50dc                	lw	a5,36(s1)
    80005220:	fbed                	bnez	a5,80005212 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80005222:	509c                	lw	a5,32(s1)
    80005224:	0017871b          	addiw	a4,a5,1
    80005228:	0007069b          	sext.w	a3,a4
    8000522c:	0027179b          	slliw	a5,a4,0x2
    80005230:	9fb9                	addw	a5,a5,a4
    80005232:	0017979b          	slliw	a5,a5,0x1
    80005236:	54d8                	lw	a4,44(s1)
    80005238:	9fb9                	addw	a5,a5,a4
    8000523a:	00f95963          	bge	s2,a5,8000524c <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000523e:	85a6                	mv	a1,s1
    80005240:	8526                	mv	a0,s1
    80005242:	ffffd097          	auipc	ra,0xffffd
    80005246:	1c2080e7          	jalr	450(ra) # 80002404 <sleep>
    8000524a:	bfd1                	j	8000521e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000524c:	00039517          	auipc	a0,0x39
    80005250:	87c50513          	addi	a0,a0,-1924 # 8003dac8 <log>
    80005254:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80005256:	ffffc097          	auipc	ra,0xffffc
    8000525a:	a46080e7          	jalr	-1466(ra) # 80000c9c <release>
      break;
    }
  }
}
    8000525e:	60e2                	ld	ra,24(sp)
    80005260:	6442                	ld	s0,16(sp)
    80005262:	64a2                	ld	s1,8(sp)
    80005264:	6902                	ld	s2,0(sp)
    80005266:	6105                	addi	sp,sp,32
    80005268:	8082                	ret

000000008000526a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000526a:	7139                	addi	sp,sp,-64
    8000526c:	fc06                	sd	ra,56(sp)
    8000526e:	f822                	sd	s0,48(sp)
    80005270:	f426                	sd	s1,40(sp)
    80005272:	f04a                	sd	s2,32(sp)
    80005274:	ec4e                	sd	s3,24(sp)
    80005276:	e852                	sd	s4,16(sp)
    80005278:	e456                	sd	s5,8(sp)
    8000527a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000527c:	00039497          	auipc	s1,0x39
    80005280:	84c48493          	addi	s1,s1,-1972 # 8003dac8 <log>
    80005284:	8526                	mv	a0,s1
    80005286:	ffffc097          	auipc	ra,0xffffc
    8000528a:	940080e7          	jalr	-1728(ra) # 80000bc6 <acquire>
  log.outstanding -= 1;
    8000528e:	509c                	lw	a5,32(s1)
    80005290:	37fd                	addiw	a5,a5,-1
    80005292:	0007891b          	sext.w	s2,a5
    80005296:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80005298:	50dc                	lw	a5,36(s1)
    8000529a:	e7b9                	bnez	a5,800052e8 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000529c:	04091e63          	bnez	s2,800052f8 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800052a0:	00039497          	auipc	s1,0x39
    800052a4:	82848493          	addi	s1,s1,-2008 # 8003dac8 <log>
    800052a8:	4785                	li	a5,1
    800052aa:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800052ac:	8526                	mv	a0,s1
    800052ae:	ffffc097          	auipc	ra,0xffffc
    800052b2:	9ee080e7          	jalr	-1554(ra) # 80000c9c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800052b6:	54dc                	lw	a5,44(s1)
    800052b8:	06f04763          	bgtz	a5,80005326 <end_op+0xbc>
    acquire(&log.lock);
    800052bc:	00039497          	auipc	s1,0x39
    800052c0:	80c48493          	addi	s1,s1,-2036 # 8003dac8 <log>
    800052c4:	8526                	mv	a0,s1
    800052c6:	ffffc097          	auipc	ra,0xffffc
    800052ca:	900080e7          	jalr	-1792(ra) # 80000bc6 <acquire>
    log.committing = 0;
    800052ce:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800052d2:	8526                	mv	a0,s1
    800052d4:	ffffd097          	auipc	ra,0xffffd
    800052d8:	2f2080e7          	jalr	754(ra) # 800025c6 <wakeup>
    release(&log.lock);
    800052dc:	8526                	mv	a0,s1
    800052de:	ffffc097          	auipc	ra,0xffffc
    800052e2:	9be080e7          	jalr	-1602(ra) # 80000c9c <release>
}
    800052e6:	a03d                	j	80005314 <end_op+0xaa>
    panic("log.committing");
    800052e8:	00004517          	auipc	a0,0x4
    800052ec:	55050513          	addi	a0,a0,1360 # 80009838 <syscalls+0x218>
    800052f0:	ffffb097          	auipc	ra,0xffffb
    800052f4:	23e080e7          	jalr	574(ra) # 8000052e <panic>
    wakeup(&log);
    800052f8:	00038497          	auipc	s1,0x38
    800052fc:	7d048493          	addi	s1,s1,2000 # 8003dac8 <log>
    80005300:	8526                	mv	a0,s1
    80005302:	ffffd097          	auipc	ra,0xffffd
    80005306:	2c4080e7          	jalr	708(ra) # 800025c6 <wakeup>
  release(&log.lock);
    8000530a:	8526                	mv	a0,s1
    8000530c:	ffffc097          	auipc	ra,0xffffc
    80005310:	990080e7          	jalr	-1648(ra) # 80000c9c <release>
}
    80005314:	70e2                	ld	ra,56(sp)
    80005316:	7442                	ld	s0,48(sp)
    80005318:	74a2                	ld	s1,40(sp)
    8000531a:	7902                	ld	s2,32(sp)
    8000531c:	69e2                	ld	s3,24(sp)
    8000531e:	6a42                	ld	s4,16(sp)
    80005320:	6aa2                	ld	s5,8(sp)
    80005322:	6121                	addi	sp,sp,64
    80005324:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80005326:	00038a97          	auipc	s5,0x38
    8000532a:	7d2a8a93          	addi	s5,s5,2002 # 8003daf8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000532e:	00038a17          	auipc	s4,0x38
    80005332:	79aa0a13          	addi	s4,s4,1946 # 8003dac8 <log>
    80005336:	018a2583          	lw	a1,24(s4)
    8000533a:	012585bb          	addw	a1,a1,s2
    8000533e:	2585                	addiw	a1,a1,1
    80005340:	028a2503          	lw	a0,40(s4)
    80005344:	fffff097          	auipc	ra,0xfffff
    80005348:	cce080e7          	jalr	-818(ra) # 80004012 <bread>
    8000534c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000534e:	000aa583          	lw	a1,0(s5)
    80005352:	028a2503          	lw	a0,40(s4)
    80005356:	fffff097          	auipc	ra,0xfffff
    8000535a:	cbc080e7          	jalr	-836(ra) # 80004012 <bread>
    8000535e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80005360:	40000613          	li	a2,1024
    80005364:	05850593          	addi	a1,a0,88
    80005368:	05848513          	addi	a0,s1,88
    8000536c:	ffffc097          	auipc	ra,0xffffc
    80005370:	9d4080e7          	jalr	-1580(ra) # 80000d40 <memmove>
    bwrite(to);  // write the log
    80005374:	8526                	mv	a0,s1
    80005376:	fffff097          	auipc	ra,0xfffff
    8000537a:	d8e080e7          	jalr	-626(ra) # 80004104 <bwrite>
    brelse(from);
    8000537e:	854e                	mv	a0,s3
    80005380:	fffff097          	auipc	ra,0xfffff
    80005384:	dc2080e7          	jalr	-574(ra) # 80004142 <brelse>
    brelse(to);
    80005388:	8526                	mv	a0,s1
    8000538a:	fffff097          	auipc	ra,0xfffff
    8000538e:	db8080e7          	jalr	-584(ra) # 80004142 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005392:	2905                	addiw	s2,s2,1
    80005394:	0a91                	addi	s5,s5,4
    80005396:	02ca2783          	lw	a5,44(s4)
    8000539a:	f8f94ee3          	blt	s2,a5,80005336 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000539e:	00000097          	auipc	ra,0x0
    800053a2:	c66080e7          	jalr	-922(ra) # 80005004 <write_head>
    install_trans(0); // Now install writes to home locations
    800053a6:	4501                	li	a0,0
    800053a8:	00000097          	auipc	ra,0x0
    800053ac:	cd8080e7          	jalr	-808(ra) # 80005080 <install_trans>
    log.lh.n = 0;
    800053b0:	00038797          	auipc	a5,0x38
    800053b4:	7407a223          	sw	zero,1860(a5) # 8003daf4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800053b8:	00000097          	auipc	ra,0x0
    800053bc:	c4c080e7          	jalr	-948(ra) # 80005004 <write_head>
    800053c0:	bdf5                	j	800052bc <end_op+0x52>

00000000800053c2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800053c2:	1101                	addi	sp,sp,-32
    800053c4:	ec06                	sd	ra,24(sp)
    800053c6:	e822                	sd	s0,16(sp)
    800053c8:	e426                	sd	s1,8(sp)
    800053ca:	e04a                	sd	s2,0(sp)
    800053cc:	1000                	addi	s0,sp,32
    800053ce:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800053d0:	00038917          	auipc	s2,0x38
    800053d4:	6f890913          	addi	s2,s2,1784 # 8003dac8 <log>
    800053d8:	854a                	mv	a0,s2
    800053da:	ffffb097          	auipc	ra,0xffffb
    800053de:	7ec080e7          	jalr	2028(ra) # 80000bc6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800053e2:	02c92603          	lw	a2,44(s2)
    800053e6:	47f5                	li	a5,29
    800053e8:	06c7c563          	blt	a5,a2,80005452 <log_write+0x90>
    800053ec:	00038797          	auipc	a5,0x38
    800053f0:	6f87a783          	lw	a5,1784(a5) # 8003dae4 <log+0x1c>
    800053f4:	37fd                	addiw	a5,a5,-1
    800053f6:	04f65e63          	bge	a2,a5,80005452 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800053fa:	00038797          	auipc	a5,0x38
    800053fe:	6ee7a783          	lw	a5,1774(a5) # 8003dae8 <log+0x20>
    80005402:	06f05063          	blez	a5,80005462 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80005406:	4781                	li	a5,0
    80005408:	06c05563          	blez	a2,80005472 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000540c:	44cc                	lw	a1,12(s1)
    8000540e:	00038717          	auipc	a4,0x38
    80005412:	6ea70713          	addi	a4,a4,1770 # 8003daf8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80005416:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80005418:	4314                	lw	a3,0(a4)
    8000541a:	04b68c63          	beq	a3,a1,80005472 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000541e:	2785                	addiw	a5,a5,1
    80005420:	0711                	addi	a4,a4,4
    80005422:	fef61be3          	bne	a2,a5,80005418 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80005426:	0621                	addi	a2,a2,8
    80005428:	060a                	slli	a2,a2,0x2
    8000542a:	00038797          	auipc	a5,0x38
    8000542e:	69e78793          	addi	a5,a5,1694 # 8003dac8 <log>
    80005432:	963e                	add	a2,a2,a5
    80005434:	44dc                	lw	a5,12(s1)
    80005436:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80005438:	8526                	mv	a0,s1
    8000543a:	fffff097          	auipc	ra,0xfffff
    8000543e:	da6080e7          	jalr	-602(ra) # 800041e0 <bpin>
    log.lh.n++;
    80005442:	00038717          	auipc	a4,0x38
    80005446:	68670713          	addi	a4,a4,1670 # 8003dac8 <log>
    8000544a:	575c                	lw	a5,44(a4)
    8000544c:	2785                	addiw	a5,a5,1
    8000544e:	d75c                	sw	a5,44(a4)
    80005450:	a835                	j	8000548c <log_write+0xca>
    panic("too big a transaction");
    80005452:	00004517          	auipc	a0,0x4
    80005456:	3f650513          	addi	a0,a0,1014 # 80009848 <syscalls+0x228>
    8000545a:	ffffb097          	auipc	ra,0xffffb
    8000545e:	0d4080e7          	jalr	212(ra) # 8000052e <panic>
    panic("log_write outside of trans");
    80005462:	00004517          	auipc	a0,0x4
    80005466:	3fe50513          	addi	a0,a0,1022 # 80009860 <syscalls+0x240>
    8000546a:	ffffb097          	auipc	ra,0xffffb
    8000546e:	0c4080e7          	jalr	196(ra) # 8000052e <panic>
  log.lh.block[i] = b->blockno;
    80005472:	00878713          	addi	a4,a5,8
    80005476:	00271693          	slli	a3,a4,0x2
    8000547a:	00038717          	auipc	a4,0x38
    8000547e:	64e70713          	addi	a4,a4,1614 # 8003dac8 <log>
    80005482:	9736                	add	a4,a4,a3
    80005484:	44d4                	lw	a3,12(s1)
    80005486:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80005488:	faf608e3          	beq	a2,a5,80005438 <log_write+0x76>
  }
  release(&log.lock);
    8000548c:	00038517          	auipc	a0,0x38
    80005490:	63c50513          	addi	a0,a0,1596 # 8003dac8 <log>
    80005494:	ffffc097          	auipc	ra,0xffffc
    80005498:	808080e7          	jalr	-2040(ra) # 80000c9c <release>
}
    8000549c:	60e2                	ld	ra,24(sp)
    8000549e:	6442                	ld	s0,16(sp)
    800054a0:	64a2                	ld	s1,8(sp)
    800054a2:	6902                	ld	s2,0(sp)
    800054a4:	6105                	addi	sp,sp,32
    800054a6:	8082                	ret

00000000800054a8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800054a8:	1101                	addi	sp,sp,-32
    800054aa:	ec06                	sd	ra,24(sp)
    800054ac:	e822                	sd	s0,16(sp)
    800054ae:	e426                	sd	s1,8(sp)
    800054b0:	e04a                	sd	s2,0(sp)
    800054b2:	1000                	addi	s0,sp,32
    800054b4:	84aa                	mv	s1,a0
    800054b6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800054b8:	00004597          	auipc	a1,0x4
    800054bc:	3c858593          	addi	a1,a1,968 # 80009880 <syscalls+0x260>
    800054c0:	0521                	addi	a0,a0,8
    800054c2:	ffffb097          	auipc	ra,0xffffb
    800054c6:	674080e7          	jalr	1652(ra) # 80000b36 <initlock>
  lk->name = name;
    800054ca:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800054ce:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800054d2:	0204a423          	sw	zero,40(s1)
}
    800054d6:	60e2                	ld	ra,24(sp)
    800054d8:	6442                	ld	s0,16(sp)
    800054da:	64a2                	ld	s1,8(sp)
    800054dc:	6902                	ld	s2,0(sp)
    800054de:	6105                	addi	sp,sp,32
    800054e0:	8082                	ret

00000000800054e2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800054e2:	1101                	addi	sp,sp,-32
    800054e4:	ec06                	sd	ra,24(sp)
    800054e6:	e822                	sd	s0,16(sp)
    800054e8:	e426                	sd	s1,8(sp)
    800054ea:	e04a                	sd	s2,0(sp)
    800054ec:	1000                	addi	s0,sp,32
    800054ee:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800054f0:	00850913          	addi	s2,a0,8
    800054f4:	854a                	mv	a0,s2
    800054f6:	ffffb097          	auipc	ra,0xffffb
    800054fa:	6d0080e7          	jalr	1744(ra) # 80000bc6 <acquire>
  while (lk->locked) {
    800054fe:	409c                	lw	a5,0(s1)
    80005500:	cb89                	beqz	a5,80005512 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80005502:	85ca                	mv	a1,s2
    80005504:	8526                	mv	a0,s1
    80005506:	ffffd097          	auipc	ra,0xffffd
    8000550a:	efe080e7          	jalr	-258(ra) # 80002404 <sleep>
  while (lk->locked) {
    8000550e:	409c                	lw	a5,0(s1)
    80005510:	fbed                	bnez	a5,80005502 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80005512:	4785                	li	a5,1
    80005514:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80005516:	ffffc097          	auipc	ra,0xffffc
    8000551a:	566080e7          	jalr	1382(ra) # 80001a7c <myproc>
    8000551e:	515c                	lw	a5,36(a0)
    80005520:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005522:	854a                	mv	a0,s2
    80005524:	ffffb097          	auipc	ra,0xffffb
    80005528:	778080e7          	jalr	1912(ra) # 80000c9c <release>
}
    8000552c:	60e2                	ld	ra,24(sp)
    8000552e:	6442                	ld	s0,16(sp)
    80005530:	64a2                	ld	s1,8(sp)
    80005532:	6902                	ld	s2,0(sp)
    80005534:	6105                	addi	sp,sp,32
    80005536:	8082                	ret

0000000080005538 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005538:	1101                	addi	sp,sp,-32
    8000553a:	ec06                	sd	ra,24(sp)
    8000553c:	e822                	sd	s0,16(sp)
    8000553e:	e426                	sd	s1,8(sp)
    80005540:	e04a                	sd	s2,0(sp)
    80005542:	1000                	addi	s0,sp,32
    80005544:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005546:	00850913          	addi	s2,a0,8
    8000554a:	854a                	mv	a0,s2
    8000554c:	ffffb097          	auipc	ra,0xffffb
    80005550:	67a080e7          	jalr	1658(ra) # 80000bc6 <acquire>
  lk->locked = 0;
    80005554:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005558:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000555c:	8526                	mv	a0,s1
    8000555e:	ffffd097          	auipc	ra,0xffffd
    80005562:	068080e7          	jalr	104(ra) # 800025c6 <wakeup>
  release(&lk->lk);
    80005566:	854a                	mv	a0,s2
    80005568:	ffffb097          	auipc	ra,0xffffb
    8000556c:	734080e7          	jalr	1844(ra) # 80000c9c <release>
}
    80005570:	60e2                	ld	ra,24(sp)
    80005572:	6442                	ld	s0,16(sp)
    80005574:	64a2                	ld	s1,8(sp)
    80005576:	6902                	ld	s2,0(sp)
    80005578:	6105                	addi	sp,sp,32
    8000557a:	8082                	ret

000000008000557c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000557c:	7179                	addi	sp,sp,-48
    8000557e:	f406                	sd	ra,40(sp)
    80005580:	f022                	sd	s0,32(sp)
    80005582:	ec26                	sd	s1,24(sp)
    80005584:	e84a                	sd	s2,16(sp)
    80005586:	e44e                	sd	s3,8(sp)
    80005588:	1800                	addi	s0,sp,48
    8000558a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000558c:	00850913          	addi	s2,a0,8
    80005590:	854a                	mv	a0,s2
    80005592:	ffffb097          	auipc	ra,0xffffb
    80005596:	634080e7          	jalr	1588(ra) # 80000bc6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000559a:	409c                	lw	a5,0(s1)
    8000559c:	ef99                	bnez	a5,800055ba <holdingsleep+0x3e>
    8000559e:	4481                	li	s1,0
  release(&lk->lk);
    800055a0:	854a                	mv	a0,s2
    800055a2:	ffffb097          	auipc	ra,0xffffb
    800055a6:	6fa080e7          	jalr	1786(ra) # 80000c9c <release>
  return r;
}
    800055aa:	8526                	mv	a0,s1
    800055ac:	70a2                	ld	ra,40(sp)
    800055ae:	7402                	ld	s0,32(sp)
    800055b0:	64e2                	ld	s1,24(sp)
    800055b2:	6942                	ld	s2,16(sp)
    800055b4:	69a2                	ld	s3,8(sp)
    800055b6:	6145                	addi	sp,sp,48
    800055b8:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800055ba:	0284a983          	lw	s3,40(s1)
    800055be:	ffffc097          	auipc	ra,0xffffc
    800055c2:	4be080e7          	jalr	1214(ra) # 80001a7c <myproc>
    800055c6:	5144                	lw	s1,36(a0)
    800055c8:	413484b3          	sub	s1,s1,s3
    800055cc:	0014b493          	seqz	s1,s1
    800055d0:	bfc1                	j	800055a0 <holdingsleep+0x24>

00000000800055d2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800055d2:	1141                	addi	sp,sp,-16
    800055d4:	e406                	sd	ra,8(sp)
    800055d6:	e022                	sd	s0,0(sp)
    800055d8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800055da:	00004597          	auipc	a1,0x4
    800055de:	2b658593          	addi	a1,a1,694 # 80009890 <syscalls+0x270>
    800055e2:	00038517          	auipc	a0,0x38
    800055e6:	62e50513          	addi	a0,a0,1582 # 8003dc10 <ftable>
    800055ea:	ffffb097          	auipc	ra,0xffffb
    800055ee:	54c080e7          	jalr	1356(ra) # 80000b36 <initlock>
}
    800055f2:	60a2                	ld	ra,8(sp)
    800055f4:	6402                	ld	s0,0(sp)
    800055f6:	0141                	addi	sp,sp,16
    800055f8:	8082                	ret

00000000800055fa <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800055fa:	1101                	addi	sp,sp,-32
    800055fc:	ec06                	sd	ra,24(sp)
    800055fe:	e822                	sd	s0,16(sp)
    80005600:	e426                	sd	s1,8(sp)
    80005602:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80005604:	00038517          	auipc	a0,0x38
    80005608:	60c50513          	addi	a0,a0,1548 # 8003dc10 <ftable>
    8000560c:	ffffb097          	auipc	ra,0xffffb
    80005610:	5ba080e7          	jalr	1466(ra) # 80000bc6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005614:	00038497          	auipc	s1,0x38
    80005618:	61448493          	addi	s1,s1,1556 # 8003dc28 <ftable+0x18>
    8000561c:	00039717          	auipc	a4,0x39
    80005620:	5ac70713          	addi	a4,a4,1452 # 8003ebc8 <ftable+0xfb8>
    if(f->ref == 0){
    80005624:	40dc                	lw	a5,4(s1)
    80005626:	cf99                	beqz	a5,80005644 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005628:	02848493          	addi	s1,s1,40
    8000562c:	fee49ce3          	bne	s1,a4,80005624 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005630:	00038517          	auipc	a0,0x38
    80005634:	5e050513          	addi	a0,a0,1504 # 8003dc10 <ftable>
    80005638:	ffffb097          	auipc	ra,0xffffb
    8000563c:	664080e7          	jalr	1636(ra) # 80000c9c <release>
  return 0;
    80005640:	4481                	li	s1,0
    80005642:	a819                	j	80005658 <filealloc+0x5e>
      f->ref = 1;
    80005644:	4785                	li	a5,1
    80005646:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005648:	00038517          	auipc	a0,0x38
    8000564c:	5c850513          	addi	a0,a0,1480 # 8003dc10 <ftable>
    80005650:	ffffb097          	auipc	ra,0xffffb
    80005654:	64c080e7          	jalr	1612(ra) # 80000c9c <release>
}
    80005658:	8526                	mv	a0,s1
    8000565a:	60e2                	ld	ra,24(sp)
    8000565c:	6442                	ld	s0,16(sp)
    8000565e:	64a2                	ld	s1,8(sp)
    80005660:	6105                	addi	sp,sp,32
    80005662:	8082                	ret

0000000080005664 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005664:	1101                	addi	sp,sp,-32
    80005666:	ec06                	sd	ra,24(sp)
    80005668:	e822                	sd	s0,16(sp)
    8000566a:	e426                	sd	s1,8(sp)
    8000566c:	1000                	addi	s0,sp,32
    8000566e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005670:	00038517          	auipc	a0,0x38
    80005674:	5a050513          	addi	a0,a0,1440 # 8003dc10 <ftable>
    80005678:	ffffb097          	auipc	ra,0xffffb
    8000567c:	54e080e7          	jalr	1358(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    80005680:	40dc                	lw	a5,4(s1)
    80005682:	02f05263          	blez	a5,800056a6 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80005686:	2785                	addiw	a5,a5,1
    80005688:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000568a:	00038517          	auipc	a0,0x38
    8000568e:	58650513          	addi	a0,a0,1414 # 8003dc10 <ftable>
    80005692:	ffffb097          	auipc	ra,0xffffb
    80005696:	60a080e7          	jalr	1546(ra) # 80000c9c <release>
  return f;
}
    8000569a:	8526                	mv	a0,s1
    8000569c:	60e2                	ld	ra,24(sp)
    8000569e:	6442                	ld	s0,16(sp)
    800056a0:	64a2                	ld	s1,8(sp)
    800056a2:	6105                	addi	sp,sp,32
    800056a4:	8082                	ret
    panic("filedup");
    800056a6:	00004517          	auipc	a0,0x4
    800056aa:	1f250513          	addi	a0,a0,498 # 80009898 <syscalls+0x278>
    800056ae:	ffffb097          	auipc	ra,0xffffb
    800056b2:	e80080e7          	jalr	-384(ra) # 8000052e <panic>

00000000800056b6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800056b6:	7139                	addi	sp,sp,-64
    800056b8:	fc06                	sd	ra,56(sp)
    800056ba:	f822                	sd	s0,48(sp)
    800056bc:	f426                	sd	s1,40(sp)
    800056be:	f04a                	sd	s2,32(sp)
    800056c0:	ec4e                	sd	s3,24(sp)
    800056c2:	e852                	sd	s4,16(sp)
    800056c4:	e456                	sd	s5,8(sp)
    800056c6:	0080                	addi	s0,sp,64
    800056c8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800056ca:	00038517          	auipc	a0,0x38
    800056ce:	54650513          	addi	a0,a0,1350 # 8003dc10 <ftable>
    800056d2:	ffffb097          	auipc	ra,0xffffb
    800056d6:	4f4080e7          	jalr	1268(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    800056da:	40dc                	lw	a5,4(s1)
    800056dc:	06f05163          	blez	a5,8000573e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800056e0:	37fd                	addiw	a5,a5,-1
    800056e2:	0007871b          	sext.w	a4,a5
    800056e6:	c0dc                	sw	a5,4(s1)
    800056e8:	06e04363          	bgtz	a4,8000574e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800056ec:	0004a903          	lw	s2,0(s1)
    800056f0:	0094ca83          	lbu	s5,9(s1)
    800056f4:	0104ba03          	ld	s4,16(s1)
    800056f8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800056fc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005700:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005704:	00038517          	auipc	a0,0x38
    80005708:	50c50513          	addi	a0,a0,1292 # 8003dc10 <ftable>
    8000570c:	ffffb097          	auipc	ra,0xffffb
    80005710:	590080e7          	jalr	1424(ra) # 80000c9c <release>

  if(ff.type == FD_PIPE){
    80005714:	4785                	li	a5,1
    80005716:	04f90d63          	beq	s2,a5,80005770 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000571a:	3979                	addiw	s2,s2,-2
    8000571c:	4785                	li	a5,1
    8000571e:	0527e063          	bltu	a5,s2,8000575e <fileclose+0xa8>
    begin_op();
    80005722:	00000097          	auipc	ra,0x0
    80005726:	ac8080e7          	jalr	-1336(ra) # 800051ea <begin_op>
    iput(ff.ip);
    8000572a:	854e                	mv	a0,s3
    8000572c:	fffff097          	auipc	ra,0xfffff
    80005730:	2a4080e7          	jalr	676(ra) # 800049d0 <iput>
    end_op();
    80005734:	00000097          	auipc	ra,0x0
    80005738:	b36080e7          	jalr	-1226(ra) # 8000526a <end_op>
    8000573c:	a00d                	j	8000575e <fileclose+0xa8>
    panic("fileclose");
    8000573e:	00004517          	auipc	a0,0x4
    80005742:	16250513          	addi	a0,a0,354 # 800098a0 <syscalls+0x280>
    80005746:	ffffb097          	auipc	ra,0xffffb
    8000574a:	de8080e7          	jalr	-536(ra) # 8000052e <panic>
    release(&ftable.lock);
    8000574e:	00038517          	auipc	a0,0x38
    80005752:	4c250513          	addi	a0,a0,1218 # 8003dc10 <ftable>
    80005756:	ffffb097          	auipc	ra,0xffffb
    8000575a:	546080e7          	jalr	1350(ra) # 80000c9c <release>
  }
}
    8000575e:	70e2                	ld	ra,56(sp)
    80005760:	7442                	ld	s0,48(sp)
    80005762:	74a2                	ld	s1,40(sp)
    80005764:	7902                	ld	s2,32(sp)
    80005766:	69e2                	ld	s3,24(sp)
    80005768:	6a42                	ld	s4,16(sp)
    8000576a:	6aa2                	ld	s5,8(sp)
    8000576c:	6121                	addi	sp,sp,64
    8000576e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005770:	85d6                	mv	a1,s5
    80005772:	8552                	mv	a0,s4
    80005774:	00000097          	auipc	ra,0x0
    80005778:	34c080e7          	jalr	844(ra) # 80005ac0 <pipeclose>
    8000577c:	b7cd                	j	8000575e <fileclose+0xa8>

000000008000577e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000577e:	715d                	addi	sp,sp,-80
    80005780:	e486                	sd	ra,72(sp)
    80005782:	e0a2                	sd	s0,64(sp)
    80005784:	fc26                	sd	s1,56(sp)
    80005786:	f84a                	sd	s2,48(sp)
    80005788:	f44e                	sd	s3,40(sp)
    8000578a:	0880                	addi	s0,sp,80
    8000578c:	84aa                	mv	s1,a0
    8000578e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005790:	ffffc097          	auipc	ra,0xffffc
    80005794:	2ec080e7          	jalr	748(ra) # 80001a7c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005798:	409c                	lw	a5,0(s1)
    8000579a:	37f9                	addiw	a5,a5,-2
    8000579c:	4705                	li	a4,1
    8000579e:	04f76763          	bltu	a4,a5,800057ec <filestat+0x6e>
    800057a2:	892a                	mv	s2,a0
    ilock(f->ip);
    800057a4:	6c88                	ld	a0,24(s1)
    800057a6:	fffff097          	auipc	ra,0xfffff
    800057aa:	070080e7          	jalr	112(ra) # 80004816 <ilock>
    stati(f->ip, &st);
    800057ae:	fb840593          	addi	a1,s0,-72
    800057b2:	6c88                	ld	a0,24(s1)
    800057b4:	fffff097          	auipc	ra,0xfffff
    800057b8:	2ec080e7          	jalr	748(ra) # 80004aa0 <stati>
    iunlock(f->ip);
    800057bc:	6c88                	ld	a0,24(s1)
    800057be:	fffff097          	auipc	ra,0xfffff
    800057c2:	11a080e7          	jalr	282(ra) # 800048d8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800057c6:	46e1                	li	a3,24
    800057c8:	fb840613          	addi	a2,s0,-72
    800057cc:	85ce                	mv	a1,s3
    800057ce:	04093503          	ld	a0,64(s2)
    800057d2:	ffffc097          	auipc	ra,0xffffc
    800057d6:	e92080e7          	jalr	-366(ra) # 80001664 <copyout>
    800057da:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800057de:	60a6                	ld	ra,72(sp)
    800057e0:	6406                	ld	s0,64(sp)
    800057e2:	74e2                	ld	s1,56(sp)
    800057e4:	7942                	ld	s2,48(sp)
    800057e6:	79a2                	ld	s3,40(sp)
    800057e8:	6161                	addi	sp,sp,80
    800057ea:	8082                	ret
  return -1;
    800057ec:	557d                	li	a0,-1
    800057ee:	bfc5                	j	800057de <filestat+0x60>

00000000800057f0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800057f0:	7179                	addi	sp,sp,-48
    800057f2:	f406                	sd	ra,40(sp)
    800057f4:	f022                	sd	s0,32(sp)
    800057f6:	ec26                	sd	s1,24(sp)
    800057f8:	e84a                	sd	s2,16(sp)
    800057fa:	e44e                	sd	s3,8(sp)
    800057fc:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800057fe:	00854783          	lbu	a5,8(a0)
    80005802:	c3d5                	beqz	a5,800058a6 <fileread+0xb6>
    80005804:	84aa                	mv	s1,a0
    80005806:	89ae                	mv	s3,a1
    80005808:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000580a:	411c                	lw	a5,0(a0)
    8000580c:	4705                	li	a4,1
    8000580e:	04e78963          	beq	a5,a4,80005860 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005812:	470d                	li	a4,3
    80005814:	04e78d63          	beq	a5,a4,8000586e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005818:	4709                	li	a4,2
    8000581a:	06e79e63          	bne	a5,a4,80005896 <fileread+0xa6>
    ilock(f->ip);
    8000581e:	6d08                	ld	a0,24(a0)
    80005820:	fffff097          	auipc	ra,0xfffff
    80005824:	ff6080e7          	jalr	-10(ra) # 80004816 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005828:	874a                	mv	a4,s2
    8000582a:	5094                	lw	a3,32(s1)
    8000582c:	864e                	mv	a2,s3
    8000582e:	4585                	li	a1,1
    80005830:	6c88                	ld	a0,24(s1)
    80005832:	fffff097          	auipc	ra,0xfffff
    80005836:	298080e7          	jalr	664(ra) # 80004aca <readi>
    8000583a:	892a                	mv	s2,a0
    8000583c:	00a05563          	blez	a0,80005846 <fileread+0x56>
      f->off += r;
    80005840:	509c                	lw	a5,32(s1)
    80005842:	9fa9                	addw	a5,a5,a0
    80005844:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005846:	6c88                	ld	a0,24(s1)
    80005848:	fffff097          	auipc	ra,0xfffff
    8000584c:	090080e7          	jalr	144(ra) # 800048d8 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005850:	854a                	mv	a0,s2
    80005852:	70a2                	ld	ra,40(sp)
    80005854:	7402                	ld	s0,32(sp)
    80005856:	64e2                	ld	s1,24(sp)
    80005858:	6942                	ld	s2,16(sp)
    8000585a:	69a2                	ld	s3,8(sp)
    8000585c:	6145                	addi	sp,sp,48
    8000585e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005860:	6908                	ld	a0,16(a0)
    80005862:	00000097          	auipc	ra,0x0
    80005866:	3c8080e7          	jalr	968(ra) # 80005c2a <piperead>
    8000586a:	892a                	mv	s2,a0
    8000586c:	b7d5                	j	80005850 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000586e:	02451783          	lh	a5,36(a0)
    80005872:	03079693          	slli	a3,a5,0x30
    80005876:	92c1                	srli	a3,a3,0x30
    80005878:	4725                	li	a4,9
    8000587a:	02d76863          	bltu	a4,a3,800058aa <fileread+0xba>
    8000587e:	0792                	slli	a5,a5,0x4
    80005880:	00038717          	auipc	a4,0x38
    80005884:	2f070713          	addi	a4,a4,752 # 8003db70 <devsw>
    80005888:	97ba                	add	a5,a5,a4
    8000588a:	639c                	ld	a5,0(a5)
    8000588c:	c38d                	beqz	a5,800058ae <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000588e:	4505                	li	a0,1
    80005890:	9782                	jalr	a5
    80005892:	892a                	mv	s2,a0
    80005894:	bf75                	j	80005850 <fileread+0x60>
    panic("fileread");
    80005896:	00004517          	auipc	a0,0x4
    8000589a:	01a50513          	addi	a0,a0,26 # 800098b0 <syscalls+0x290>
    8000589e:	ffffb097          	auipc	ra,0xffffb
    800058a2:	c90080e7          	jalr	-880(ra) # 8000052e <panic>
    return -1;
    800058a6:	597d                	li	s2,-1
    800058a8:	b765                	j	80005850 <fileread+0x60>
      return -1;
    800058aa:	597d                	li	s2,-1
    800058ac:	b755                	j	80005850 <fileread+0x60>
    800058ae:	597d                	li	s2,-1
    800058b0:	b745                	j	80005850 <fileread+0x60>

00000000800058b2 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800058b2:	715d                	addi	sp,sp,-80
    800058b4:	e486                	sd	ra,72(sp)
    800058b6:	e0a2                	sd	s0,64(sp)
    800058b8:	fc26                	sd	s1,56(sp)
    800058ba:	f84a                	sd	s2,48(sp)
    800058bc:	f44e                	sd	s3,40(sp)
    800058be:	f052                	sd	s4,32(sp)
    800058c0:	ec56                	sd	s5,24(sp)
    800058c2:	e85a                	sd	s6,16(sp)
    800058c4:	e45e                	sd	s7,8(sp)
    800058c6:	e062                	sd	s8,0(sp)
    800058c8:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800058ca:	00954783          	lbu	a5,9(a0)
    800058ce:	10078663          	beqz	a5,800059da <filewrite+0x128>
    800058d2:	892a                	mv	s2,a0
    800058d4:	8aae                	mv	s5,a1
    800058d6:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800058d8:	411c                	lw	a5,0(a0)
    800058da:	4705                	li	a4,1
    800058dc:	02e78263          	beq	a5,a4,80005900 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800058e0:	470d                	li	a4,3
    800058e2:	02e78663          	beq	a5,a4,8000590e <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800058e6:	4709                	li	a4,2
    800058e8:	0ee79163          	bne	a5,a4,800059ca <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800058ec:	0ac05d63          	blez	a2,800059a6 <filewrite+0xf4>
    int i = 0;
    800058f0:	4981                	li	s3,0
    800058f2:	6b05                	lui	s6,0x1
    800058f4:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800058f8:	6b85                	lui	s7,0x1
    800058fa:	c00b8b9b          	addiw	s7,s7,-1024
    800058fe:	a861                	j	80005996 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005900:	6908                	ld	a0,16(a0)
    80005902:	00000097          	auipc	ra,0x0
    80005906:	22e080e7          	jalr	558(ra) # 80005b30 <pipewrite>
    8000590a:	8a2a                	mv	s4,a0
    8000590c:	a045                	j	800059ac <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000590e:	02451783          	lh	a5,36(a0)
    80005912:	03079693          	slli	a3,a5,0x30
    80005916:	92c1                	srli	a3,a3,0x30
    80005918:	4725                	li	a4,9
    8000591a:	0cd76263          	bltu	a4,a3,800059de <filewrite+0x12c>
    8000591e:	0792                	slli	a5,a5,0x4
    80005920:	00038717          	auipc	a4,0x38
    80005924:	25070713          	addi	a4,a4,592 # 8003db70 <devsw>
    80005928:	97ba                	add	a5,a5,a4
    8000592a:	679c                	ld	a5,8(a5)
    8000592c:	cbdd                	beqz	a5,800059e2 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    8000592e:	4505                	li	a0,1
    80005930:	9782                	jalr	a5
    80005932:	8a2a                	mv	s4,a0
    80005934:	a8a5                	j	800059ac <filewrite+0xfa>
    80005936:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000593a:	00000097          	auipc	ra,0x0
    8000593e:	8b0080e7          	jalr	-1872(ra) # 800051ea <begin_op>
      ilock(f->ip);
    80005942:	01893503          	ld	a0,24(s2)
    80005946:	fffff097          	auipc	ra,0xfffff
    8000594a:	ed0080e7          	jalr	-304(ra) # 80004816 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000594e:	8762                	mv	a4,s8
    80005950:	02092683          	lw	a3,32(s2)
    80005954:	01598633          	add	a2,s3,s5
    80005958:	4585                	li	a1,1
    8000595a:	01893503          	ld	a0,24(s2)
    8000595e:	fffff097          	auipc	ra,0xfffff
    80005962:	264080e7          	jalr	612(ra) # 80004bc2 <writei>
    80005966:	84aa                	mv	s1,a0
    80005968:	00a05763          	blez	a0,80005976 <filewrite+0xc4>
        f->off += r;
    8000596c:	02092783          	lw	a5,32(s2)
    80005970:	9fa9                	addw	a5,a5,a0
    80005972:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005976:	01893503          	ld	a0,24(s2)
    8000597a:	fffff097          	auipc	ra,0xfffff
    8000597e:	f5e080e7          	jalr	-162(ra) # 800048d8 <iunlock>
      end_op();
    80005982:	00000097          	auipc	ra,0x0
    80005986:	8e8080e7          	jalr	-1816(ra) # 8000526a <end_op>

      if(r != n1){
    8000598a:	009c1f63          	bne	s8,s1,800059a8 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000598e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005992:	0149db63          	bge	s3,s4,800059a8 <filewrite+0xf6>
      int n1 = n - i;
    80005996:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000599a:	84be                	mv	s1,a5
    8000599c:	2781                	sext.w	a5,a5
    8000599e:	f8fb5ce3          	bge	s6,a5,80005936 <filewrite+0x84>
    800059a2:	84de                	mv	s1,s7
    800059a4:	bf49                	j	80005936 <filewrite+0x84>
    int i = 0;
    800059a6:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800059a8:	013a1f63          	bne	s4,s3,800059c6 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800059ac:	8552                	mv	a0,s4
    800059ae:	60a6                	ld	ra,72(sp)
    800059b0:	6406                	ld	s0,64(sp)
    800059b2:	74e2                	ld	s1,56(sp)
    800059b4:	7942                	ld	s2,48(sp)
    800059b6:	79a2                	ld	s3,40(sp)
    800059b8:	7a02                	ld	s4,32(sp)
    800059ba:	6ae2                	ld	s5,24(sp)
    800059bc:	6b42                	ld	s6,16(sp)
    800059be:	6ba2                	ld	s7,8(sp)
    800059c0:	6c02                	ld	s8,0(sp)
    800059c2:	6161                	addi	sp,sp,80
    800059c4:	8082                	ret
    ret = (i == n ? n : -1);
    800059c6:	5a7d                	li	s4,-1
    800059c8:	b7d5                	j	800059ac <filewrite+0xfa>
    panic("filewrite");
    800059ca:	00004517          	auipc	a0,0x4
    800059ce:	ef650513          	addi	a0,a0,-266 # 800098c0 <syscalls+0x2a0>
    800059d2:	ffffb097          	auipc	ra,0xffffb
    800059d6:	b5c080e7          	jalr	-1188(ra) # 8000052e <panic>
    return -1;
    800059da:	5a7d                	li	s4,-1
    800059dc:	bfc1                	j	800059ac <filewrite+0xfa>
      return -1;
    800059de:	5a7d                	li	s4,-1
    800059e0:	b7f1                	j	800059ac <filewrite+0xfa>
    800059e2:	5a7d                	li	s4,-1
    800059e4:	b7e1                	j	800059ac <filewrite+0xfa>

00000000800059e6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800059e6:	7179                	addi	sp,sp,-48
    800059e8:	f406                	sd	ra,40(sp)
    800059ea:	f022                	sd	s0,32(sp)
    800059ec:	ec26                	sd	s1,24(sp)
    800059ee:	e84a                	sd	s2,16(sp)
    800059f0:	e44e                	sd	s3,8(sp)
    800059f2:	e052                	sd	s4,0(sp)
    800059f4:	1800                	addi	s0,sp,48
    800059f6:	84aa                	mv	s1,a0
    800059f8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800059fa:	0005b023          	sd	zero,0(a1)
    800059fe:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005a02:	00000097          	auipc	ra,0x0
    80005a06:	bf8080e7          	jalr	-1032(ra) # 800055fa <filealloc>
    80005a0a:	e088                	sd	a0,0(s1)
    80005a0c:	c551                	beqz	a0,80005a98 <pipealloc+0xb2>
    80005a0e:	00000097          	auipc	ra,0x0
    80005a12:	bec080e7          	jalr	-1044(ra) # 800055fa <filealloc>
    80005a16:	00aa3023          	sd	a0,0(s4)
    80005a1a:	c92d                	beqz	a0,80005a8c <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005a1c:	ffffb097          	auipc	ra,0xffffb
    80005a20:	0ba080e7          	jalr	186(ra) # 80000ad6 <kalloc>
    80005a24:	892a                	mv	s2,a0
    80005a26:	c125                	beqz	a0,80005a86 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005a28:	4985                	li	s3,1
    80005a2a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005a2e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005a32:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005a36:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005a3a:	00004597          	auipc	a1,0x4
    80005a3e:	e9658593          	addi	a1,a1,-362 # 800098d0 <syscalls+0x2b0>
    80005a42:	ffffb097          	auipc	ra,0xffffb
    80005a46:	0f4080e7          	jalr	244(ra) # 80000b36 <initlock>
  (*f0)->type = FD_PIPE;
    80005a4a:	609c                	ld	a5,0(s1)
    80005a4c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005a50:	609c                	ld	a5,0(s1)
    80005a52:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005a56:	609c                	ld	a5,0(s1)
    80005a58:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005a5c:	609c                	ld	a5,0(s1)
    80005a5e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005a62:	000a3783          	ld	a5,0(s4)
    80005a66:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005a6a:	000a3783          	ld	a5,0(s4)
    80005a6e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005a72:	000a3783          	ld	a5,0(s4)
    80005a76:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005a7a:	000a3783          	ld	a5,0(s4)
    80005a7e:	0127b823          	sd	s2,16(a5)
  return 0;
    80005a82:	4501                	li	a0,0
    80005a84:	a025                	j	80005aac <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005a86:	6088                	ld	a0,0(s1)
    80005a88:	e501                	bnez	a0,80005a90 <pipealloc+0xaa>
    80005a8a:	a039                	j	80005a98 <pipealloc+0xb2>
    80005a8c:	6088                	ld	a0,0(s1)
    80005a8e:	c51d                	beqz	a0,80005abc <pipealloc+0xd6>
    fileclose(*f0);
    80005a90:	00000097          	auipc	ra,0x0
    80005a94:	c26080e7          	jalr	-986(ra) # 800056b6 <fileclose>
  if(*f1)
    80005a98:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005a9c:	557d                	li	a0,-1
  if(*f1)
    80005a9e:	c799                	beqz	a5,80005aac <pipealloc+0xc6>
    fileclose(*f1);
    80005aa0:	853e                	mv	a0,a5
    80005aa2:	00000097          	auipc	ra,0x0
    80005aa6:	c14080e7          	jalr	-1004(ra) # 800056b6 <fileclose>
  return -1;
    80005aaa:	557d                	li	a0,-1
}
    80005aac:	70a2                	ld	ra,40(sp)
    80005aae:	7402                	ld	s0,32(sp)
    80005ab0:	64e2                	ld	s1,24(sp)
    80005ab2:	6942                	ld	s2,16(sp)
    80005ab4:	69a2                	ld	s3,8(sp)
    80005ab6:	6a02                	ld	s4,0(sp)
    80005ab8:	6145                	addi	sp,sp,48
    80005aba:	8082                	ret
  return -1;
    80005abc:	557d                	li	a0,-1
    80005abe:	b7fd                	j	80005aac <pipealloc+0xc6>

0000000080005ac0 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005ac0:	1101                	addi	sp,sp,-32
    80005ac2:	ec06                	sd	ra,24(sp)
    80005ac4:	e822                	sd	s0,16(sp)
    80005ac6:	e426                	sd	s1,8(sp)
    80005ac8:	e04a                	sd	s2,0(sp)
    80005aca:	1000                	addi	s0,sp,32
    80005acc:	84aa                	mv	s1,a0
    80005ace:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005ad0:	ffffb097          	auipc	ra,0xffffb
    80005ad4:	0f6080e7          	jalr	246(ra) # 80000bc6 <acquire>
  if(writable){
    80005ad8:	02090d63          	beqz	s2,80005b12 <pipeclose+0x52>
    pi->writeopen = 0;
    80005adc:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005ae0:	21848513          	addi	a0,s1,536
    80005ae4:	ffffd097          	auipc	ra,0xffffd
    80005ae8:	ae2080e7          	jalr	-1310(ra) # 800025c6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005aec:	2204b783          	ld	a5,544(s1)
    80005af0:	eb95                	bnez	a5,80005b24 <pipeclose+0x64>
    release(&pi->lock);
    80005af2:	8526                	mv	a0,s1
    80005af4:	ffffb097          	auipc	ra,0xffffb
    80005af8:	1a8080e7          	jalr	424(ra) # 80000c9c <release>
    kfree((char*)pi);
    80005afc:	8526                	mv	a0,s1
    80005afe:	ffffb097          	auipc	ra,0xffffb
    80005b02:	edc080e7          	jalr	-292(ra) # 800009da <kfree>
  } else
    release(&pi->lock);
}
    80005b06:	60e2                	ld	ra,24(sp)
    80005b08:	6442                	ld	s0,16(sp)
    80005b0a:	64a2                	ld	s1,8(sp)
    80005b0c:	6902                	ld	s2,0(sp)
    80005b0e:	6105                	addi	sp,sp,32
    80005b10:	8082                	ret
    pi->readopen = 0;
    80005b12:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005b16:	21c48513          	addi	a0,s1,540
    80005b1a:	ffffd097          	auipc	ra,0xffffd
    80005b1e:	aac080e7          	jalr	-1364(ra) # 800025c6 <wakeup>
    80005b22:	b7e9                	j	80005aec <pipeclose+0x2c>
    release(&pi->lock);
    80005b24:	8526                	mv	a0,s1
    80005b26:	ffffb097          	auipc	ra,0xffffb
    80005b2a:	176080e7          	jalr	374(ra) # 80000c9c <release>
}
    80005b2e:	bfe1                	j	80005b06 <pipeclose+0x46>

0000000080005b30 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005b30:	7159                	addi	sp,sp,-112
    80005b32:	f486                	sd	ra,104(sp)
    80005b34:	f0a2                	sd	s0,96(sp)
    80005b36:	eca6                	sd	s1,88(sp)
    80005b38:	e8ca                	sd	s2,80(sp)
    80005b3a:	e4ce                	sd	s3,72(sp)
    80005b3c:	e0d2                	sd	s4,64(sp)
    80005b3e:	fc56                	sd	s5,56(sp)
    80005b40:	f85a                	sd	s6,48(sp)
    80005b42:	f45e                	sd	s7,40(sp)
    80005b44:	f062                	sd	s8,32(sp)
    80005b46:	ec66                	sd	s9,24(sp)
    80005b48:	1880                	addi	s0,sp,112
    80005b4a:	84aa                	mv	s1,a0
    80005b4c:	8b2e                	mv	s6,a1
    80005b4e:	8ab2                	mv	s5,a2
  int i = 0;
  struct proc *pr = myproc();
    80005b50:	ffffc097          	auipc	ra,0xffffc
    80005b54:	f2c080e7          	jalr	-212(ra) # 80001a7c <myproc>
    80005b58:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005b5a:	8526                	mv	a0,s1
    80005b5c:	ffffb097          	auipc	ra,0xffffb
    80005b60:	06a080e7          	jalr	106(ra) # 80000bc6 <acquire>
  while(i < n){
    80005b64:	0b505663          	blez	s5,80005c10 <pipewrite+0xe0>
  int i = 0;
    80005b68:	4901                	li	s2,0
    if(pi->readopen == 0 || pr->killed==1){
    80005b6a:	4a05                	li	s4,1
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005b6c:	5bfd                	li	s7,-1
      wakeup(&pi->nread);
    80005b6e:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005b72:	21c48c13          	addi	s8,s1,540
    80005b76:	a091                	j	80005bba <pipewrite+0x8a>
      release(&pi->lock);
    80005b78:	8526                	mv	a0,s1
    80005b7a:	ffffb097          	auipc	ra,0xffffb
    80005b7e:	122080e7          	jalr	290(ra) # 80000c9c <release>
      return -1;
    80005b82:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005b84:	854a                	mv	a0,s2
    80005b86:	70a6                	ld	ra,104(sp)
    80005b88:	7406                	ld	s0,96(sp)
    80005b8a:	64e6                	ld	s1,88(sp)
    80005b8c:	6946                	ld	s2,80(sp)
    80005b8e:	69a6                	ld	s3,72(sp)
    80005b90:	6a06                	ld	s4,64(sp)
    80005b92:	7ae2                	ld	s5,56(sp)
    80005b94:	7b42                	ld	s6,48(sp)
    80005b96:	7ba2                	ld	s7,40(sp)
    80005b98:	7c02                	ld	s8,32(sp)
    80005b9a:	6ce2                	ld	s9,24(sp)
    80005b9c:	6165                	addi	sp,sp,112
    80005b9e:	8082                	ret
      wakeup(&pi->nread);
    80005ba0:	8566                	mv	a0,s9
    80005ba2:	ffffd097          	auipc	ra,0xffffd
    80005ba6:	a24080e7          	jalr	-1500(ra) # 800025c6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005baa:	85a6                	mv	a1,s1
    80005bac:	8562                	mv	a0,s8
    80005bae:	ffffd097          	auipc	ra,0xffffd
    80005bb2:	856080e7          	jalr	-1962(ra) # 80002404 <sleep>
  while(i < n){
    80005bb6:	05595e63          	bge	s2,s5,80005c12 <pipewrite+0xe2>
    if(pi->readopen == 0 || pr->killed==1){
    80005bba:	2204a783          	lw	a5,544(s1)
    80005bbe:	dfcd                	beqz	a5,80005b78 <pipewrite+0x48>
    80005bc0:	01c9a783          	lw	a5,28(s3)
    80005bc4:	fb478ae3          	beq	a5,s4,80005b78 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005bc8:	2184a783          	lw	a5,536(s1)
    80005bcc:	21c4a703          	lw	a4,540(s1)
    80005bd0:	2007879b          	addiw	a5,a5,512
    80005bd4:	fcf706e3          	beq	a4,a5,80005ba0 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005bd8:	86d2                	mv	a3,s4
    80005bda:	01690633          	add	a2,s2,s6
    80005bde:	f9f40593          	addi	a1,s0,-97
    80005be2:	0409b503          	ld	a0,64(s3)
    80005be6:	ffffc097          	auipc	ra,0xffffc
    80005bea:	b0a080e7          	jalr	-1270(ra) # 800016f0 <copyin>
    80005bee:	03750263          	beq	a0,s7,80005c12 <pipewrite+0xe2>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005bf2:	21c4a783          	lw	a5,540(s1)
    80005bf6:	0017871b          	addiw	a4,a5,1
    80005bfa:	20e4ae23          	sw	a4,540(s1)
    80005bfe:	1ff7f793          	andi	a5,a5,511
    80005c02:	97a6                	add	a5,a5,s1
    80005c04:	f9f44703          	lbu	a4,-97(s0)
    80005c08:	00e78c23          	sb	a4,24(a5)
      i++;
    80005c0c:	2905                	addiw	s2,s2,1
    80005c0e:	b765                	j	80005bb6 <pipewrite+0x86>
  int i = 0;
    80005c10:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005c12:	21848513          	addi	a0,s1,536
    80005c16:	ffffd097          	auipc	ra,0xffffd
    80005c1a:	9b0080e7          	jalr	-1616(ra) # 800025c6 <wakeup>
  release(&pi->lock);
    80005c1e:	8526                	mv	a0,s1
    80005c20:	ffffb097          	auipc	ra,0xffffb
    80005c24:	07c080e7          	jalr	124(ra) # 80000c9c <release>
  return i;
    80005c28:	bfb1                	j	80005b84 <pipewrite+0x54>

0000000080005c2a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005c2a:	715d                	addi	sp,sp,-80
    80005c2c:	e486                	sd	ra,72(sp)
    80005c2e:	e0a2                	sd	s0,64(sp)
    80005c30:	fc26                	sd	s1,56(sp)
    80005c32:	f84a                	sd	s2,48(sp)
    80005c34:	f44e                	sd	s3,40(sp)
    80005c36:	f052                	sd	s4,32(sp)
    80005c38:	ec56                	sd	s5,24(sp)
    80005c3a:	e85a                	sd	s6,16(sp)
    80005c3c:	0880                	addi	s0,sp,80
    80005c3e:	84aa                	mv	s1,a0
    80005c40:	892e                	mv	s2,a1
    80005c42:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005c44:	ffffc097          	auipc	ra,0xffffc
    80005c48:	e38080e7          	jalr	-456(ra) # 80001a7c <myproc>
    80005c4c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005c4e:	8526                	mv	a0,s1
    80005c50:	ffffb097          	auipc	ra,0xffffb
    80005c54:	f76080e7          	jalr	-138(ra) # 80000bc6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005c58:	2184a703          	lw	a4,536(s1)
    80005c5c:	21c4a783          	lw	a5,540(s1)
    if(pr->killed==1){
    80005c60:	4985                	li	s3,1
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005c62:	21848b13          	addi	s6,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005c66:	02f71563          	bne	a4,a5,80005c90 <piperead+0x66>
    80005c6a:	2244a783          	lw	a5,548(s1)
    80005c6e:	c38d                	beqz	a5,80005c90 <piperead+0x66>
    if(pr->killed==1){
    80005c70:	01ca2783          	lw	a5,28(s4)
    80005c74:	09378963          	beq	a5,s3,80005d06 <piperead+0xdc>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005c78:	85a6                	mv	a1,s1
    80005c7a:	855a                	mv	a0,s6
    80005c7c:	ffffc097          	auipc	ra,0xffffc
    80005c80:	788080e7          	jalr	1928(ra) # 80002404 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005c84:	2184a703          	lw	a4,536(s1)
    80005c88:	21c4a783          	lw	a5,540(s1)
    80005c8c:	fcf70fe3          	beq	a4,a5,80005c6a <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005c90:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005c92:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005c94:	05505363          	blez	s5,80005cda <piperead+0xb0>
    if(pi->nread == pi->nwrite)
    80005c98:	2184a783          	lw	a5,536(s1)
    80005c9c:	21c4a703          	lw	a4,540(s1)
    80005ca0:	02f70d63          	beq	a4,a5,80005cda <piperead+0xb0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005ca4:	0017871b          	addiw	a4,a5,1
    80005ca8:	20e4ac23          	sw	a4,536(s1)
    80005cac:	1ff7f793          	andi	a5,a5,511
    80005cb0:	97a6                	add	a5,a5,s1
    80005cb2:	0187c783          	lbu	a5,24(a5)
    80005cb6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005cba:	4685                	li	a3,1
    80005cbc:	fbf40613          	addi	a2,s0,-65
    80005cc0:	85ca                	mv	a1,s2
    80005cc2:	040a3503          	ld	a0,64(s4)
    80005cc6:	ffffc097          	auipc	ra,0xffffc
    80005cca:	99e080e7          	jalr	-1634(ra) # 80001664 <copyout>
    80005cce:	01650663          	beq	a0,s6,80005cda <piperead+0xb0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005cd2:	2985                	addiw	s3,s3,1
    80005cd4:	0905                	addi	s2,s2,1
    80005cd6:	fd3a91e3          	bne	s5,s3,80005c98 <piperead+0x6e>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005cda:	21c48513          	addi	a0,s1,540
    80005cde:	ffffd097          	auipc	ra,0xffffd
    80005ce2:	8e8080e7          	jalr	-1816(ra) # 800025c6 <wakeup>
  release(&pi->lock);
    80005ce6:	8526                	mv	a0,s1
    80005ce8:	ffffb097          	auipc	ra,0xffffb
    80005cec:	fb4080e7          	jalr	-76(ra) # 80000c9c <release>
  return i;
}
    80005cf0:	854e                	mv	a0,s3
    80005cf2:	60a6                	ld	ra,72(sp)
    80005cf4:	6406                	ld	s0,64(sp)
    80005cf6:	74e2                	ld	s1,56(sp)
    80005cf8:	7942                	ld	s2,48(sp)
    80005cfa:	79a2                	ld	s3,40(sp)
    80005cfc:	7a02                	ld	s4,32(sp)
    80005cfe:	6ae2                	ld	s5,24(sp)
    80005d00:	6b42                	ld	s6,16(sp)
    80005d02:	6161                	addi	sp,sp,80
    80005d04:	8082                	ret
      release(&pi->lock);
    80005d06:	8526                	mv	a0,s1
    80005d08:	ffffb097          	auipc	ra,0xffffb
    80005d0c:	f94080e7          	jalr	-108(ra) # 80000c9c <release>
      return -1;
    80005d10:	59fd                	li	s3,-1
    80005d12:	bff9                	j	80005cf0 <piperead+0xc6>

0000000080005d14 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005d14:	dd010113          	addi	sp,sp,-560
    80005d18:	22113423          	sd	ra,552(sp)
    80005d1c:	22813023          	sd	s0,544(sp)
    80005d20:	20913c23          	sd	s1,536(sp)
    80005d24:	21213823          	sd	s2,528(sp)
    80005d28:	21313423          	sd	s3,520(sp)
    80005d2c:	21413023          	sd	s4,512(sp)
    80005d30:	ffd6                	sd	s5,504(sp)
    80005d32:	fbda                	sd	s6,496(sp)
    80005d34:	f7de                	sd	s7,488(sp)
    80005d36:	f3e2                	sd	s8,480(sp)
    80005d38:	efe6                	sd	s9,472(sp)
    80005d3a:	ebea                	sd	s10,464(sp)
    80005d3c:	e7ee                	sd	s11,456(sp)
    80005d3e:	1c00                	addi	s0,sp,560
    80005d40:	dea43823          	sd	a0,-528(s0)
    80005d44:	deb43023          	sd	a1,-544(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005d48:	ffffc097          	auipc	ra,0xffffc
    80005d4c:	d34080e7          	jalr	-716(ra) # 80001a7c <myproc>
    80005d50:	89aa                	mv	s3,a0

  struct kthread *t = mykthread();
    80005d52:	ffffc097          	auipc	ra,0xffffc
    80005d56:	d6a080e7          	jalr	-662(ra) # 80001abc <mykthread>
    80005d5a:	8b2a                	mv	s6,a0
  struct kthread *nt;


  // Kill all process threads 
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){ 
    80005d5c:	28898493          	addi	s1,s3,648
    80005d60:	6905                	lui	s2,0x1
    80005d62:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80005d66:	994e                	add	s2,s2,s3
    if(nt!=t && nt->state!=TUNUSED){
      acquire(&nt->lock);
      nt->killed=1;
    80005d68:	4a85                	li	s5,1
      if(nt->state == TSLEEPING){
    80005d6a:	4a09                	li	s4,2
        nt->state = TRUNNABLE;
    80005d6c:	4b8d                	li	s7,3
    80005d6e:	a811                	j	80005d82 <exec+0x6e>
      }
      release(&nt->lock);  
    80005d70:	8526                	mv	a0,s1
    80005d72:	ffffb097          	auipc	ra,0xffffb
    80005d76:	f2a080e7          	jalr	-214(ra) # 80000c9c <release>
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){ 
    80005d7a:	0b848493          	addi	s1,s1,184
    80005d7e:	03248363          	beq	s1,s2,80005da4 <exec+0x90>
    if(nt!=t && nt->state!=TUNUSED){
    80005d82:	fe9b0ce3          	beq	s6,s1,80005d7a <exec+0x66>
    80005d86:	4c9c                	lw	a5,24(s1)
    80005d88:	dbed                	beqz	a5,80005d7a <exec+0x66>
      acquire(&nt->lock);
    80005d8a:	8526                	mv	a0,s1
    80005d8c:	ffffb097          	auipc	ra,0xffffb
    80005d90:	e3a080e7          	jalr	-454(ra) # 80000bc6 <acquire>
      nt->killed=1;
    80005d94:	0354a423          	sw	s5,40(s1)
      if(nt->state == TSLEEPING){
    80005d98:	4c9c                	lw	a5,24(s1)
    80005d9a:	fd479be3          	bne	a5,s4,80005d70 <exec+0x5c>
        nt->state = TRUNNABLE;
    80005d9e:	0174ac23          	sw	s7,24(s1)
    80005da2:	b7f9                	j	80005d70 <exec+0x5c>
    }
  }

  // Wait for all threads to terminate
  kthread_join_all();
    80005da4:	ffffd097          	auipc	ra,0xffffd
    80005da8:	364080e7          	jalr	868(ra) # 80003108 <kthread_join_all>
    
  begin_op();
    80005dac:	fffff097          	auipc	ra,0xfffff
    80005db0:	43e080e7          	jalr	1086(ra) # 800051ea <begin_op>

  if((ip = namei(path)) == 0){
    80005db4:	df043503          	ld	a0,-528(s0)
    80005db8:	fffff097          	auipc	ra,0xfffff
    80005dbc:	212080e7          	jalr	530(ra) # 80004fca <namei>
    80005dc0:	8aaa                	mv	s5,a0
    80005dc2:	cd25                	beqz	a0,80005e3a <exec+0x126>
    end_op();
    return -1;
  }
  ilock(ip);
    80005dc4:	fffff097          	auipc	ra,0xfffff
    80005dc8:	a52080e7          	jalr	-1454(ra) # 80004816 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005dcc:	04000713          	li	a4,64
    80005dd0:	4681                	li	a3,0
    80005dd2:	e4840613          	addi	a2,s0,-440
    80005dd6:	4581                	li	a1,0
    80005dd8:	8556                	mv	a0,s5
    80005dda:	fffff097          	auipc	ra,0xfffff
    80005dde:	cf0080e7          	jalr	-784(ra) # 80004aca <readi>
    80005de2:	04000793          	li	a5,64
    80005de6:	00f51a63          	bne	a0,a5,80005dfa <exec+0xe6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005dea:	e4842703          	lw	a4,-440(s0)
    80005dee:	464c47b7          	lui	a5,0x464c4
    80005df2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005df6:	04f70863          	beq	a4,a5,80005e46 <exec+0x132>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005dfa:	8556                	mv	a0,s5
    80005dfc:	fffff097          	auipc	ra,0xfffff
    80005e00:	c7c080e7          	jalr	-900(ra) # 80004a78 <iunlockput>
    end_op();
    80005e04:	fffff097          	auipc	ra,0xfffff
    80005e08:	466080e7          	jalr	1126(ra) # 8000526a <end_op>
  }
  return -1;
    80005e0c:	557d                	li	a0,-1
}
    80005e0e:	22813083          	ld	ra,552(sp)
    80005e12:	22013403          	ld	s0,544(sp)
    80005e16:	21813483          	ld	s1,536(sp)
    80005e1a:	21013903          	ld	s2,528(sp)
    80005e1e:	20813983          	ld	s3,520(sp)
    80005e22:	20013a03          	ld	s4,512(sp)
    80005e26:	7afe                	ld	s5,504(sp)
    80005e28:	7b5e                	ld	s6,496(sp)
    80005e2a:	7bbe                	ld	s7,488(sp)
    80005e2c:	7c1e                	ld	s8,480(sp)
    80005e2e:	6cfe                	ld	s9,472(sp)
    80005e30:	6d5e                	ld	s10,464(sp)
    80005e32:	6dbe                	ld	s11,456(sp)
    80005e34:	23010113          	addi	sp,sp,560
    80005e38:	8082                	ret
    end_op();
    80005e3a:	fffff097          	auipc	ra,0xfffff
    80005e3e:	430080e7          	jalr	1072(ra) # 8000526a <end_op>
    return -1;
    80005e42:	557d                	li	a0,-1
    80005e44:	b7e9                	j	80005e0e <exec+0xfa>
  if((pagetable = proc_pagetable(p)) == 0)
    80005e46:	854e                	mv	a0,s3
    80005e48:	ffffc097          	auipc	ra,0xffffc
    80005e4c:	dea080e7          	jalr	-534(ra) # 80001c32 <proc_pagetable>
    80005e50:	e0a43423          	sd	a0,-504(s0)
    80005e54:	d15d                	beqz	a0,80005dfa <exec+0xe6>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005e56:	e6842783          	lw	a5,-408(s0)
    80005e5a:	e8045703          	lhu	a4,-384(s0)
    80005e5e:	c73d                	beqz	a4,80005ecc <exec+0x1b8>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005e60:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005e62:	e0043023          	sd	zero,-512(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005e66:	6a05                	lui	s4,0x1
    80005e68:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005e6c:	dce43c23          	sd	a4,-552(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005e70:	6d85                	lui	s11,0x1
    80005e72:	7d7d                	lui	s10,0xfffff
    80005e74:	a4b5                	j	800060e0 <exec+0x3cc>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005e76:	00004517          	auipc	a0,0x4
    80005e7a:	a6250513          	addi	a0,a0,-1438 # 800098d8 <syscalls+0x2b8>
    80005e7e:	ffffa097          	auipc	ra,0xffffa
    80005e82:	6b0080e7          	jalr	1712(ra) # 8000052e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005e86:	874a                	mv	a4,s2
    80005e88:	009c86bb          	addw	a3,s9,s1
    80005e8c:	4581                	li	a1,0
    80005e8e:	8556                	mv	a0,s5
    80005e90:	fffff097          	auipc	ra,0xfffff
    80005e94:	c3a080e7          	jalr	-966(ra) # 80004aca <readi>
    80005e98:	2501                	sext.w	a0,a0
    80005e9a:	1ea91263          	bne	s2,a0,8000607e <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80005e9e:	009d84bb          	addw	s1,s11,s1
    80005ea2:	013d09bb          	addw	s3,s10,s3
    80005ea6:	2174fd63          	bgeu	s1,s7,800060c0 <exec+0x3ac>
    pa = walkaddr(pagetable, va + i);
    80005eaa:	02049593          	slli	a1,s1,0x20
    80005eae:	9181                	srli	a1,a1,0x20
    80005eb0:	95e2                	add	a1,a1,s8
    80005eb2:	e0843503          	ld	a0,-504(s0)
    80005eb6:	ffffb097          	auipc	ra,0xffffb
    80005eba:	1bc080e7          	jalr	444(ra) # 80001072 <walkaddr>
    80005ebe:	862a                	mv	a2,a0
    if(pa == 0)
    80005ec0:	d95d                	beqz	a0,80005e76 <exec+0x162>
      n = PGSIZE;
    80005ec2:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005ec4:	fd49f1e3          	bgeu	s3,s4,80005e86 <exec+0x172>
      n = sz - i;
    80005ec8:	894e                	mv	s2,s3
    80005eca:	bf75                	j	80005e86 <exec+0x172>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005ecc:	4481                	li	s1,0
  iunlockput(ip);
    80005ece:	8556                	mv	a0,s5
    80005ed0:	fffff097          	auipc	ra,0xfffff
    80005ed4:	ba8080e7          	jalr	-1112(ra) # 80004a78 <iunlockput>
  end_op();
    80005ed8:	fffff097          	auipc	ra,0xfffff
    80005edc:	392080e7          	jalr	914(ra) # 8000526a <end_op>
  p = myproc();
    80005ee0:	ffffc097          	auipc	ra,0xffffc
    80005ee4:	b9c080e7          	jalr	-1124(ra) # 80001a7c <myproc>
    80005ee8:	8a2a                	mv	s4,a0
  uint64 oldsz = p->sz;
    80005eea:	03853d03          	ld	s10,56(a0)
  sz = PGROUNDUP(sz);
    80005eee:	6785                	lui	a5,0x1
    80005ef0:	17fd                	addi	a5,a5,-1
    80005ef2:	94be                	add	s1,s1,a5
    80005ef4:	77fd                	lui	a5,0xfffff
    80005ef6:	8fe5                	and	a5,a5,s1
    80005ef8:	def43423          	sd	a5,-536(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005efc:	6609                	lui	a2,0x2
    80005efe:	963e                	add	a2,a2,a5
    80005f00:	85be                	mv	a1,a5
    80005f02:	e0843483          	ld	s1,-504(s0)
    80005f06:	8526                	mv	a0,s1
    80005f08:	ffffb097          	auipc	ra,0xffffb
    80005f0c:	50c080e7          	jalr	1292(ra) # 80001414 <uvmalloc>
    80005f10:	8caa                	mv	s9,a0
  ip = 0;
    80005f12:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005f14:	16050563          	beqz	a0,8000607e <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005f18:	75f9                	lui	a1,0xffffe
    80005f1a:	95aa                	add	a1,a1,a0
    80005f1c:	8526                	mv	a0,s1
    80005f1e:	ffffb097          	auipc	ra,0xffffb
    80005f22:	714080e7          	jalr	1812(ra) # 80001632 <uvmclear>
  stackbase = sp - PGSIZE;
    80005f26:	7bfd                	lui	s7,0xfffff
    80005f28:	9be6                	add	s7,s7,s9
  for(argc = 0; argv[argc]; argc++) {
    80005f2a:	de043783          	ld	a5,-544(s0)
    80005f2e:	6388                	ld	a0,0(a5)
    80005f30:	c92d                	beqz	a0,80005fa2 <exec+0x28e>
    80005f32:	e8840993          	addi	s3,s0,-376
    80005f36:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80005f3a:	8966                	mv	s2,s9
  for(argc = 0; argv[argc]; argc++) {
    80005f3c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005f3e:	ffffb097          	auipc	ra,0xffffb
    80005f42:	f2a080e7          	jalr	-214(ra) # 80000e68 <strlen>
    80005f46:	0015079b          	addiw	a5,a0,1
    80005f4a:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005f4e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005f52:	15796b63          	bltu	s2,s7,800060a8 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005f56:	de043d83          	ld	s11,-544(s0)
    80005f5a:	000dba83          	ld	s5,0(s11) # 1000 <_entry-0x7ffff000>
    80005f5e:	8556                	mv	a0,s5
    80005f60:	ffffb097          	auipc	ra,0xffffb
    80005f64:	f08080e7          	jalr	-248(ra) # 80000e68 <strlen>
    80005f68:	0015069b          	addiw	a3,a0,1
    80005f6c:	8656                	mv	a2,s5
    80005f6e:	85ca                	mv	a1,s2
    80005f70:	e0843503          	ld	a0,-504(s0)
    80005f74:	ffffb097          	auipc	ra,0xffffb
    80005f78:	6f0080e7          	jalr	1776(ra) # 80001664 <copyout>
    80005f7c:	12054a63          	bltz	a0,800060b0 <exec+0x39c>
    ustack[argc] = sp;
    80005f80:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005f84:	0485                	addi	s1,s1,1
    80005f86:	008d8793          	addi	a5,s11,8
    80005f8a:	def43023          	sd	a5,-544(s0)
    80005f8e:	008db503          	ld	a0,8(s11)
    80005f92:	c911                	beqz	a0,80005fa6 <exec+0x292>
    if(argc >= MAXARG)
    80005f94:	09a1                	addi	s3,s3,8
    80005f96:	fb3c14e3          	bne	s8,s3,80005f3e <exec+0x22a>
  sz = sz1;
    80005f9a:	df943423          	sd	s9,-536(s0)
  ip = 0;
    80005f9e:	4a81                	li	s5,0
    80005fa0:	a8f9                	j	8000607e <exec+0x36a>
  sp = sz;
    80005fa2:	8966                	mv	s2,s9
  for(argc = 0; argv[argc]; argc++) {
    80005fa4:	4481                	li	s1,0
  ustack[argc] = 0;
    80005fa6:	00349793          	slli	a5,s1,0x3
    80005faa:	f9040713          	addi	a4,s0,-112
    80005fae:	97ba                	add	a5,a5,a4
    80005fb0:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffbcef8>
  sp -= (argc+1) * sizeof(uint64);
    80005fb4:	00148693          	addi	a3,s1,1
    80005fb8:	068e                	slli	a3,a3,0x3
    80005fba:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005fbe:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005fc2:	01797663          	bgeu	s2,s7,80005fce <exec+0x2ba>
  sz = sz1;
    80005fc6:	df943423          	sd	s9,-536(s0)
  ip = 0;
    80005fca:	4a81                	li	s5,0
    80005fcc:	a84d                	j	8000607e <exec+0x36a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005fce:	e8840613          	addi	a2,s0,-376
    80005fd2:	85ca                	mv	a1,s2
    80005fd4:	e0843503          	ld	a0,-504(s0)
    80005fd8:	ffffb097          	auipc	ra,0xffffb
    80005fdc:	68c080e7          	jalr	1676(ra) # 80001664 <copyout>
    80005fe0:	0c054c63          	bltz	a0,800060b8 <exec+0x3a4>
  t->trapframe->a1 = sp;
    80005fe4:	040b3783          	ld	a5,64(s6)
    80005fe8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005fec:	df043783          	ld	a5,-528(s0)
    80005ff0:	0007c703          	lbu	a4,0(a5)
    80005ff4:	cf11                	beqz	a4,80006010 <exec+0x2fc>
    80005ff6:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005ff8:	02f00693          	li	a3,47
    80005ffc:	a039                	j	8000600a <exec+0x2f6>
      last = s+1;
    80005ffe:	def43823          	sd	a5,-528(s0)
  for(last=s=path; *s; s++)
    80006002:	0785                	addi	a5,a5,1
    80006004:	fff7c703          	lbu	a4,-1(a5)
    80006008:	c701                	beqz	a4,80006010 <exec+0x2fc>
    if(*s == '/')
    8000600a:	fed71ce3          	bne	a4,a3,80006002 <exec+0x2ee>
    8000600e:	bfc5                	j	80005ffe <exec+0x2ea>
  safestrcpy(p->name, last, sizeof(p->name));
    80006010:	4641                	li	a2,16
    80006012:	df043583          	ld	a1,-528(s0)
    80006016:	0d8a0513          	addi	a0,s4,216
    8000601a:	ffffb097          	auipc	ra,0xffffb
    8000601e:	e1c080e7          	jalr	-484(ra) # 80000e36 <safestrcpy>
  for(int i=0; i<32; i++){
    80006022:	0f8a0793          	addi	a5,s4,248
    80006026:	1f8a0713          	addi	a4,s4,504
    8000602a:	85ba                	mv	a1,a4
    if(!((p->signal_handlers[i]) == (void*)SIG_IGN)){
    8000602c:	4605                	li	a2,1
    8000602e:	a029                	j	80006038 <exec+0x324>
  for(int i=0; i<32; i++){
    80006030:	07a1                	addi	a5,a5,8
    80006032:	0711                	addi	a4,a4,4
    80006034:	00f58a63          	beq	a1,a5,80006048 <exec+0x334>
    if(!((p->signal_handlers[i]) == (void*)SIG_IGN)){
    80006038:	6394                	ld	a3,0(a5)
    8000603a:	fec68be3          	beq	a3,a2,80006030 <exec+0x31c>
        p->signal_handlers[i]=SIG_DFL;
    8000603e:	0007b023          	sd	zero,0(a5)
        p->handlers_sigmasks[i]=0;   
    80006042:	00072023          	sw	zero,0(a4)
    80006046:	b7ed                	j	80006030 <exec+0x31c>
  oldpagetable = p->pagetable;
    80006048:	040a3503          	ld	a0,64(s4)
  p->pagetable = pagetable;
    8000604c:	e0843783          	ld	a5,-504(s0)
    80006050:	04fa3023          	sd	a5,64(s4)
  p->sz = sz;
    80006054:	039a3c23          	sd	s9,56(s4)
  t->trapframe->epc = elf.entry;  // initial program counter = main
    80006058:	040b3783          	ld	a5,64(s6)
    8000605c:	e6043703          	ld	a4,-416(s0)
    80006060:	ef98                	sd	a4,24(a5)
  t->trapframe->sp = sp; // initial stack pointer
    80006062:	040b3783          	ld	a5,64(s6)
    80006066:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000606a:	85ea                	mv	a1,s10
    8000606c:	ffffc097          	auipc	ra,0xffffc
    80006070:	c62080e7          	jalr	-926(ra) # 80001cce <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80006074:	0004851b          	sext.w	a0,s1
    80006078:	bb59                	j	80005e0e <exec+0xfa>
    8000607a:	de943423          	sd	s1,-536(s0)
    proc_freepagetable(pagetable, sz);
    8000607e:	de843583          	ld	a1,-536(s0)
    80006082:	e0843503          	ld	a0,-504(s0)
    80006086:	ffffc097          	auipc	ra,0xffffc
    8000608a:	c48080e7          	jalr	-952(ra) # 80001cce <proc_freepagetable>
  if(ip){
    8000608e:	d60a96e3          	bnez	s5,80005dfa <exec+0xe6>
  return -1;
    80006092:	557d                	li	a0,-1
    80006094:	bbad                	j	80005e0e <exec+0xfa>
    80006096:	de943423          	sd	s1,-536(s0)
    8000609a:	b7d5                	j	8000607e <exec+0x36a>
    8000609c:	de943423          	sd	s1,-536(s0)
    800060a0:	bff9                	j	8000607e <exec+0x36a>
    800060a2:	de943423          	sd	s1,-536(s0)
    800060a6:	bfe1                	j	8000607e <exec+0x36a>
  sz = sz1;
    800060a8:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800060ac:	4a81                	li	s5,0
    800060ae:	bfc1                	j	8000607e <exec+0x36a>
  sz = sz1;
    800060b0:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800060b4:	4a81                	li	s5,0
    800060b6:	b7e1                	j	8000607e <exec+0x36a>
  sz = sz1;
    800060b8:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800060bc:	4a81                	li	s5,0
    800060be:	b7c1                	j	8000607e <exec+0x36a>
    sz = sz1;
    800060c0:	de843483          	ld	s1,-536(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800060c4:	e0043783          	ld	a5,-512(s0)
    800060c8:	0017869b          	addiw	a3,a5,1
    800060cc:	e0d43023          	sd	a3,-512(s0)
    800060d0:	df843783          	ld	a5,-520(s0)
    800060d4:	0387879b          	addiw	a5,a5,56
    800060d8:	e8045703          	lhu	a4,-384(s0)
    800060dc:	dee6d9e3          	bge	a3,a4,80005ece <exec+0x1ba>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800060e0:	2781                	sext.w	a5,a5
    800060e2:	def43c23          	sd	a5,-520(s0)
    800060e6:	03800713          	li	a4,56
    800060ea:	86be                	mv	a3,a5
    800060ec:	e1040613          	addi	a2,s0,-496
    800060f0:	4581                	li	a1,0
    800060f2:	8556                	mv	a0,s5
    800060f4:	fffff097          	auipc	ra,0xfffff
    800060f8:	9d6080e7          	jalr	-1578(ra) # 80004aca <readi>
    800060fc:	03800793          	li	a5,56
    80006100:	f6f51de3          	bne	a0,a5,8000607a <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80006104:	e1042783          	lw	a5,-496(s0)
    80006108:	4705                	li	a4,1
    8000610a:	fae79de3          	bne	a5,a4,800060c4 <exec+0x3b0>
    if(ph.memsz < ph.filesz)
    8000610e:	e3843603          	ld	a2,-456(s0)
    80006112:	e3043783          	ld	a5,-464(s0)
    80006116:	f8f660e3          	bltu	a2,a5,80006096 <exec+0x382>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000611a:	e2043783          	ld	a5,-480(s0)
    8000611e:	963e                	add	a2,a2,a5
    80006120:	f6f66ee3          	bltu	a2,a5,8000609c <exec+0x388>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80006124:	85a6                	mv	a1,s1
    80006126:	e0843503          	ld	a0,-504(s0)
    8000612a:	ffffb097          	auipc	ra,0xffffb
    8000612e:	2ea080e7          	jalr	746(ra) # 80001414 <uvmalloc>
    80006132:	dea43423          	sd	a0,-536(s0)
    80006136:	d535                	beqz	a0,800060a2 <exec+0x38e>
    if(ph.vaddr % PGSIZE != 0)
    80006138:	e2043c03          	ld	s8,-480(s0)
    8000613c:	dd843783          	ld	a5,-552(s0)
    80006140:	00fc77b3          	and	a5,s8,a5
    80006144:	ff8d                	bnez	a5,8000607e <exec+0x36a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80006146:	e1842c83          	lw	s9,-488(s0)
    8000614a:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000614e:	f60b89e3          	beqz	s7,800060c0 <exec+0x3ac>
    80006152:	89de                	mv	s3,s7
    80006154:	4481                	li	s1,0
    80006156:	bb91                	j	80005eaa <exec+0x196>

0000000080006158 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80006158:	7179                	addi	sp,sp,-48
    8000615a:	f406                	sd	ra,40(sp)
    8000615c:	f022                	sd	s0,32(sp)
    8000615e:	ec26                	sd	s1,24(sp)
    80006160:	e84a                	sd	s2,16(sp)
    80006162:	1800                	addi	s0,sp,48
    80006164:	892e                	mv	s2,a1
    80006166:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80006168:	fdc40593          	addi	a1,s0,-36
    8000616c:	ffffe097          	auipc	ra,0xffffe
    80006170:	964080e7          	jalr	-1692(ra) # 80003ad0 <argint>
    80006174:	04054063          	bltz	a0,800061b4 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80006178:	fdc42703          	lw	a4,-36(s0)
    8000617c:	47bd                	li	a5,15
    8000617e:	02e7ed63          	bltu	a5,a4,800061b8 <argfd+0x60>
    80006182:	ffffc097          	auipc	ra,0xffffc
    80006186:	8fa080e7          	jalr	-1798(ra) # 80001a7c <myproc>
    8000618a:	fdc42703          	lw	a4,-36(s0)
    8000618e:	00a70793          	addi	a5,a4,10
    80006192:	078e                	slli	a5,a5,0x3
    80006194:	953e                	add	a0,a0,a5
    80006196:	611c                	ld	a5,0(a0)
    80006198:	c395                	beqz	a5,800061bc <argfd+0x64>
    return -1;
  if(pfd)
    8000619a:	00090463          	beqz	s2,800061a2 <argfd+0x4a>
    *pfd = fd;
    8000619e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800061a2:	4501                	li	a0,0
  if(pf)
    800061a4:	c091                	beqz	s1,800061a8 <argfd+0x50>
    *pf = f;
    800061a6:	e09c                	sd	a5,0(s1)
}
    800061a8:	70a2                	ld	ra,40(sp)
    800061aa:	7402                	ld	s0,32(sp)
    800061ac:	64e2                	ld	s1,24(sp)
    800061ae:	6942                	ld	s2,16(sp)
    800061b0:	6145                	addi	sp,sp,48
    800061b2:	8082                	ret
    return -1;
    800061b4:	557d                	li	a0,-1
    800061b6:	bfcd                	j	800061a8 <argfd+0x50>
    return -1;
    800061b8:	557d                	li	a0,-1
    800061ba:	b7fd                	j	800061a8 <argfd+0x50>
    800061bc:	557d                	li	a0,-1
    800061be:	b7ed                	j	800061a8 <argfd+0x50>

00000000800061c0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800061c0:	1101                	addi	sp,sp,-32
    800061c2:	ec06                	sd	ra,24(sp)
    800061c4:	e822                	sd	s0,16(sp)
    800061c6:	e426                	sd	s1,8(sp)
    800061c8:	1000                	addi	s0,sp,32
    800061ca:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800061cc:	ffffc097          	auipc	ra,0xffffc
    800061d0:	8b0080e7          	jalr	-1872(ra) # 80001a7c <myproc>
    800061d4:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800061d6:	05050793          	addi	a5,a0,80
    800061da:	4501                	li	a0,0
    800061dc:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800061de:	6398                	ld	a4,0(a5)
    800061e0:	cb19                	beqz	a4,800061f6 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800061e2:	2505                	addiw	a0,a0,1
    800061e4:	07a1                	addi	a5,a5,8
    800061e6:	fed51ce3          	bne	a0,a3,800061de <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800061ea:	557d                	li	a0,-1
}
    800061ec:	60e2                	ld	ra,24(sp)
    800061ee:	6442                	ld	s0,16(sp)
    800061f0:	64a2                	ld	s1,8(sp)
    800061f2:	6105                	addi	sp,sp,32
    800061f4:	8082                	ret
      p->ofile[fd] = f;
    800061f6:	00a50793          	addi	a5,a0,10
    800061fa:	078e                	slli	a5,a5,0x3
    800061fc:	963e                	add	a2,a2,a5
    800061fe:	e204                	sd	s1,0(a2)
      return fd;
    80006200:	b7f5                	j	800061ec <fdalloc+0x2c>

0000000080006202 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80006202:	715d                	addi	sp,sp,-80
    80006204:	e486                	sd	ra,72(sp)
    80006206:	e0a2                	sd	s0,64(sp)
    80006208:	fc26                	sd	s1,56(sp)
    8000620a:	f84a                	sd	s2,48(sp)
    8000620c:	f44e                	sd	s3,40(sp)
    8000620e:	f052                	sd	s4,32(sp)
    80006210:	ec56                	sd	s5,24(sp)
    80006212:	0880                	addi	s0,sp,80
    80006214:	89ae                	mv	s3,a1
    80006216:	8ab2                	mv	s5,a2
    80006218:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000621a:	fb040593          	addi	a1,s0,-80
    8000621e:	fffff097          	auipc	ra,0xfffff
    80006222:	dca080e7          	jalr	-566(ra) # 80004fe8 <nameiparent>
    80006226:	892a                	mv	s2,a0
    80006228:	12050e63          	beqz	a0,80006364 <create+0x162>
    return 0;

  ilock(dp);
    8000622c:	ffffe097          	auipc	ra,0xffffe
    80006230:	5ea080e7          	jalr	1514(ra) # 80004816 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80006234:	4601                	li	a2,0
    80006236:	fb040593          	addi	a1,s0,-80
    8000623a:	854a                	mv	a0,s2
    8000623c:	fffff097          	auipc	ra,0xfffff
    80006240:	abe080e7          	jalr	-1346(ra) # 80004cfa <dirlookup>
    80006244:	84aa                	mv	s1,a0
    80006246:	c921                	beqz	a0,80006296 <create+0x94>
    iunlockput(dp);
    80006248:	854a                	mv	a0,s2
    8000624a:	fffff097          	auipc	ra,0xfffff
    8000624e:	82e080e7          	jalr	-2002(ra) # 80004a78 <iunlockput>
    ilock(ip);
    80006252:	8526                	mv	a0,s1
    80006254:	ffffe097          	auipc	ra,0xffffe
    80006258:	5c2080e7          	jalr	1474(ra) # 80004816 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000625c:	2981                	sext.w	s3,s3
    8000625e:	4789                	li	a5,2
    80006260:	02f99463          	bne	s3,a5,80006288 <create+0x86>
    80006264:	0444d783          	lhu	a5,68(s1)
    80006268:	37f9                	addiw	a5,a5,-2
    8000626a:	17c2                	slli	a5,a5,0x30
    8000626c:	93c1                	srli	a5,a5,0x30
    8000626e:	4705                	li	a4,1
    80006270:	00f76c63          	bltu	a4,a5,80006288 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80006274:	8526                	mv	a0,s1
    80006276:	60a6                	ld	ra,72(sp)
    80006278:	6406                	ld	s0,64(sp)
    8000627a:	74e2                	ld	s1,56(sp)
    8000627c:	7942                	ld	s2,48(sp)
    8000627e:	79a2                	ld	s3,40(sp)
    80006280:	7a02                	ld	s4,32(sp)
    80006282:	6ae2                	ld	s5,24(sp)
    80006284:	6161                	addi	sp,sp,80
    80006286:	8082                	ret
    iunlockput(ip);
    80006288:	8526                	mv	a0,s1
    8000628a:	ffffe097          	auipc	ra,0xffffe
    8000628e:	7ee080e7          	jalr	2030(ra) # 80004a78 <iunlockput>
    return 0;
    80006292:	4481                	li	s1,0
    80006294:	b7c5                	j	80006274 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80006296:	85ce                	mv	a1,s3
    80006298:	00092503          	lw	a0,0(s2)
    8000629c:	ffffe097          	auipc	ra,0xffffe
    800062a0:	3e2080e7          	jalr	994(ra) # 8000467e <ialloc>
    800062a4:	84aa                	mv	s1,a0
    800062a6:	c521                	beqz	a0,800062ee <create+0xec>
  ilock(ip);
    800062a8:	ffffe097          	auipc	ra,0xffffe
    800062ac:	56e080e7          	jalr	1390(ra) # 80004816 <ilock>
  ip->major = major;
    800062b0:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800062b4:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800062b8:	4a05                	li	s4,1
    800062ba:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800062be:	8526                	mv	a0,s1
    800062c0:	ffffe097          	auipc	ra,0xffffe
    800062c4:	48c080e7          	jalr	1164(ra) # 8000474c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800062c8:	2981                	sext.w	s3,s3
    800062ca:	03498a63          	beq	s3,s4,800062fe <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800062ce:	40d0                	lw	a2,4(s1)
    800062d0:	fb040593          	addi	a1,s0,-80
    800062d4:	854a                	mv	a0,s2
    800062d6:	fffff097          	auipc	ra,0xfffff
    800062da:	c32080e7          	jalr	-974(ra) # 80004f08 <dirlink>
    800062de:	06054b63          	bltz	a0,80006354 <create+0x152>
  iunlockput(dp);
    800062e2:	854a                	mv	a0,s2
    800062e4:	ffffe097          	auipc	ra,0xffffe
    800062e8:	794080e7          	jalr	1940(ra) # 80004a78 <iunlockput>
  return ip;
    800062ec:	b761                	j	80006274 <create+0x72>
    panic("create: ialloc");
    800062ee:	00003517          	auipc	a0,0x3
    800062f2:	60a50513          	addi	a0,a0,1546 # 800098f8 <syscalls+0x2d8>
    800062f6:	ffffa097          	auipc	ra,0xffffa
    800062fa:	238080e7          	jalr	568(ra) # 8000052e <panic>
    dp->nlink++;  // for ".."
    800062fe:	04a95783          	lhu	a5,74(s2)
    80006302:	2785                	addiw	a5,a5,1
    80006304:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80006308:	854a                	mv	a0,s2
    8000630a:	ffffe097          	auipc	ra,0xffffe
    8000630e:	442080e7          	jalr	1090(ra) # 8000474c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80006312:	40d0                	lw	a2,4(s1)
    80006314:	00003597          	auipc	a1,0x3
    80006318:	5f458593          	addi	a1,a1,1524 # 80009908 <syscalls+0x2e8>
    8000631c:	8526                	mv	a0,s1
    8000631e:	fffff097          	auipc	ra,0xfffff
    80006322:	bea080e7          	jalr	-1046(ra) # 80004f08 <dirlink>
    80006326:	00054f63          	bltz	a0,80006344 <create+0x142>
    8000632a:	00492603          	lw	a2,4(s2)
    8000632e:	00003597          	auipc	a1,0x3
    80006332:	5e258593          	addi	a1,a1,1506 # 80009910 <syscalls+0x2f0>
    80006336:	8526                	mv	a0,s1
    80006338:	fffff097          	auipc	ra,0xfffff
    8000633c:	bd0080e7          	jalr	-1072(ra) # 80004f08 <dirlink>
    80006340:	f80557e3          	bgez	a0,800062ce <create+0xcc>
      panic("create dots");
    80006344:	00003517          	auipc	a0,0x3
    80006348:	5d450513          	addi	a0,a0,1492 # 80009918 <syscalls+0x2f8>
    8000634c:	ffffa097          	auipc	ra,0xffffa
    80006350:	1e2080e7          	jalr	482(ra) # 8000052e <panic>
    panic("create: dirlink");
    80006354:	00003517          	auipc	a0,0x3
    80006358:	5d450513          	addi	a0,a0,1492 # 80009928 <syscalls+0x308>
    8000635c:	ffffa097          	auipc	ra,0xffffa
    80006360:	1d2080e7          	jalr	466(ra) # 8000052e <panic>
    return 0;
    80006364:	84aa                	mv	s1,a0
    80006366:	b739                	j	80006274 <create+0x72>

0000000080006368 <sys_dup>:
{
    80006368:	7179                	addi	sp,sp,-48
    8000636a:	f406                	sd	ra,40(sp)
    8000636c:	f022                	sd	s0,32(sp)
    8000636e:	ec26                	sd	s1,24(sp)
    80006370:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80006372:	fd840613          	addi	a2,s0,-40
    80006376:	4581                	li	a1,0
    80006378:	4501                	li	a0,0
    8000637a:	00000097          	auipc	ra,0x0
    8000637e:	dde080e7          	jalr	-546(ra) # 80006158 <argfd>
    return -1;
    80006382:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80006384:	02054363          	bltz	a0,800063aa <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80006388:	fd843503          	ld	a0,-40(s0)
    8000638c:	00000097          	auipc	ra,0x0
    80006390:	e34080e7          	jalr	-460(ra) # 800061c0 <fdalloc>
    80006394:	84aa                	mv	s1,a0
    return -1;
    80006396:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80006398:	00054963          	bltz	a0,800063aa <sys_dup+0x42>
  filedup(f);
    8000639c:	fd843503          	ld	a0,-40(s0)
    800063a0:	fffff097          	auipc	ra,0xfffff
    800063a4:	2c4080e7          	jalr	708(ra) # 80005664 <filedup>
  return fd;
    800063a8:	87a6                	mv	a5,s1
}
    800063aa:	853e                	mv	a0,a5
    800063ac:	70a2                	ld	ra,40(sp)
    800063ae:	7402                	ld	s0,32(sp)
    800063b0:	64e2                	ld	s1,24(sp)
    800063b2:	6145                	addi	sp,sp,48
    800063b4:	8082                	ret

00000000800063b6 <sys_read>:
{
    800063b6:	7179                	addi	sp,sp,-48
    800063b8:	f406                	sd	ra,40(sp)
    800063ba:	f022                	sd	s0,32(sp)
    800063bc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800063be:	fe840613          	addi	a2,s0,-24
    800063c2:	4581                	li	a1,0
    800063c4:	4501                	li	a0,0
    800063c6:	00000097          	auipc	ra,0x0
    800063ca:	d92080e7          	jalr	-622(ra) # 80006158 <argfd>
    return -1;
    800063ce:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800063d0:	04054163          	bltz	a0,80006412 <sys_read+0x5c>
    800063d4:	fe440593          	addi	a1,s0,-28
    800063d8:	4509                	li	a0,2
    800063da:	ffffd097          	auipc	ra,0xffffd
    800063de:	6f6080e7          	jalr	1782(ra) # 80003ad0 <argint>
    return -1;
    800063e2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800063e4:	02054763          	bltz	a0,80006412 <sys_read+0x5c>
    800063e8:	fd840593          	addi	a1,s0,-40
    800063ec:	4505                	li	a0,1
    800063ee:	ffffd097          	auipc	ra,0xffffd
    800063f2:	704080e7          	jalr	1796(ra) # 80003af2 <argaddr>
    return -1;
    800063f6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800063f8:	00054d63          	bltz	a0,80006412 <sys_read+0x5c>
  return fileread(f, p, n);
    800063fc:	fe442603          	lw	a2,-28(s0)
    80006400:	fd843583          	ld	a1,-40(s0)
    80006404:	fe843503          	ld	a0,-24(s0)
    80006408:	fffff097          	auipc	ra,0xfffff
    8000640c:	3e8080e7          	jalr	1000(ra) # 800057f0 <fileread>
    80006410:	87aa                	mv	a5,a0
}
    80006412:	853e                	mv	a0,a5
    80006414:	70a2                	ld	ra,40(sp)
    80006416:	7402                	ld	s0,32(sp)
    80006418:	6145                	addi	sp,sp,48
    8000641a:	8082                	ret

000000008000641c <sys_write>:
{
    8000641c:	7179                	addi	sp,sp,-48
    8000641e:	f406                	sd	ra,40(sp)
    80006420:	f022                	sd	s0,32(sp)
    80006422:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006424:	fe840613          	addi	a2,s0,-24
    80006428:	4581                	li	a1,0
    8000642a:	4501                	li	a0,0
    8000642c:	00000097          	auipc	ra,0x0
    80006430:	d2c080e7          	jalr	-724(ra) # 80006158 <argfd>
    return -1;
    80006434:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006436:	04054163          	bltz	a0,80006478 <sys_write+0x5c>
    8000643a:	fe440593          	addi	a1,s0,-28
    8000643e:	4509                	li	a0,2
    80006440:	ffffd097          	auipc	ra,0xffffd
    80006444:	690080e7          	jalr	1680(ra) # 80003ad0 <argint>
    return -1;
    80006448:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000644a:	02054763          	bltz	a0,80006478 <sys_write+0x5c>
    8000644e:	fd840593          	addi	a1,s0,-40
    80006452:	4505                	li	a0,1
    80006454:	ffffd097          	auipc	ra,0xffffd
    80006458:	69e080e7          	jalr	1694(ra) # 80003af2 <argaddr>
    return -1;
    8000645c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000645e:	00054d63          	bltz	a0,80006478 <sys_write+0x5c>
  return filewrite(f, p, n);
    80006462:	fe442603          	lw	a2,-28(s0)
    80006466:	fd843583          	ld	a1,-40(s0)
    8000646a:	fe843503          	ld	a0,-24(s0)
    8000646e:	fffff097          	auipc	ra,0xfffff
    80006472:	444080e7          	jalr	1092(ra) # 800058b2 <filewrite>
    80006476:	87aa                	mv	a5,a0
}
    80006478:	853e                	mv	a0,a5
    8000647a:	70a2                	ld	ra,40(sp)
    8000647c:	7402                	ld	s0,32(sp)
    8000647e:	6145                	addi	sp,sp,48
    80006480:	8082                	ret

0000000080006482 <sys_close>:
{
    80006482:	1101                	addi	sp,sp,-32
    80006484:	ec06                	sd	ra,24(sp)
    80006486:	e822                	sd	s0,16(sp)
    80006488:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000648a:	fe040613          	addi	a2,s0,-32
    8000648e:	fec40593          	addi	a1,s0,-20
    80006492:	4501                	li	a0,0
    80006494:	00000097          	auipc	ra,0x0
    80006498:	cc4080e7          	jalr	-828(ra) # 80006158 <argfd>
    return -1;
    8000649c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000649e:	02054463          	bltz	a0,800064c6 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800064a2:	ffffb097          	auipc	ra,0xffffb
    800064a6:	5da080e7          	jalr	1498(ra) # 80001a7c <myproc>
    800064aa:	fec42783          	lw	a5,-20(s0)
    800064ae:	07a9                	addi	a5,a5,10
    800064b0:	078e                	slli	a5,a5,0x3
    800064b2:	97aa                	add	a5,a5,a0
    800064b4:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800064b8:	fe043503          	ld	a0,-32(s0)
    800064bc:	fffff097          	auipc	ra,0xfffff
    800064c0:	1fa080e7          	jalr	506(ra) # 800056b6 <fileclose>
  return 0;
    800064c4:	4781                	li	a5,0
}
    800064c6:	853e                	mv	a0,a5
    800064c8:	60e2                	ld	ra,24(sp)
    800064ca:	6442                	ld	s0,16(sp)
    800064cc:	6105                	addi	sp,sp,32
    800064ce:	8082                	ret

00000000800064d0 <sys_fstat>:
{
    800064d0:	1101                	addi	sp,sp,-32
    800064d2:	ec06                	sd	ra,24(sp)
    800064d4:	e822                	sd	s0,16(sp)
    800064d6:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800064d8:	fe840613          	addi	a2,s0,-24
    800064dc:	4581                	li	a1,0
    800064de:	4501                	li	a0,0
    800064e0:	00000097          	auipc	ra,0x0
    800064e4:	c78080e7          	jalr	-904(ra) # 80006158 <argfd>
    return -1;
    800064e8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800064ea:	02054563          	bltz	a0,80006514 <sys_fstat+0x44>
    800064ee:	fe040593          	addi	a1,s0,-32
    800064f2:	4505                	li	a0,1
    800064f4:	ffffd097          	auipc	ra,0xffffd
    800064f8:	5fe080e7          	jalr	1534(ra) # 80003af2 <argaddr>
    return -1;
    800064fc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800064fe:	00054b63          	bltz	a0,80006514 <sys_fstat+0x44>
  return filestat(f, st);
    80006502:	fe043583          	ld	a1,-32(s0)
    80006506:	fe843503          	ld	a0,-24(s0)
    8000650a:	fffff097          	auipc	ra,0xfffff
    8000650e:	274080e7          	jalr	628(ra) # 8000577e <filestat>
    80006512:	87aa                	mv	a5,a0
}
    80006514:	853e                	mv	a0,a5
    80006516:	60e2                	ld	ra,24(sp)
    80006518:	6442                	ld	s0,16(sp)
    8000651a:	6105                	addi	sp,sp,32
    8000651c:	8082                	ret

000000008000651e <sys_link>:
{
    8000651e:	7169                	addi	sp,sp,-304
    80006520:	f606                	sd	ra,296(sp)
    80006522:	f222                	sd	s0,288(sp)
    80006524:	ee26                	sd	s1,280(sp)
    80006526:	ea4a                	sd	s2,272(sp)
    80006528:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000652a:	08000613          	li	a2,128
    8000652e:	ed040593          	addi	a1,s0,-304
    80006532:	4501                	li	a0,0
    80006534:	ffffd097          	auipc	ra,0xffffd
    80006538:	5e0080e7          	jalr	1504(ra) # 80003b14 <argstr>
    return -1;
    8000653c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000653e:	10054e63          	bltz	a0,8000665a <sys_link+0x13c>
    80006542:	08000613          	li	a2,128
    80006546:	f5040593          	addi	a1,s0,-176
    8000654a:	4505                	li	a0,1
    8000654c:	ffffd097          	auipc	ra,0xffffd
    80006550:	5c8080e7          	jalr	1480(ra) # 80003b14 <argstr>
    return -1;
    80006554:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006556:	10054263          	bltz	a0,8000665a <sys_link+0x13c>
  begin_op();
    8000655a:	fffff097          	auipc	ra,0xfffff
    8000655e:	c90080e7          	jalr	-880(ra) # 800051ea <begin_op>
  if((ip = namei(old)) == 0){
    80006562:	ed040513          	addi	a0,s0,-304
    80006566:	fffff097          	auipc	ra,0xfffff
    8000656a:	a64080e7          	jalr	-1436(ra) # 80004fca <namei>
    8000656e:	84aa                	mv	s1,a0
    80006570:	c551                	beqz	a0,800065fc <sys_link+0xde>
  ilock(ip);
    80006572:	ffffe097          	auipc	ra,0xffffe
    80006576:	2a4080e7          	jalr	676(ra) # 80004816 <ilock>
  if(ip->type == T_DIR){
    8000657a:	04449703          	lh	a4,68(s1)
    8000657e:	4785                	li	a5,1
    80006580:	08f70463          	beq	a4,a5,80006608 <sys_link+0xea>
  ip->nlink++;
    80006584:	04a4d783          	lhu	a5,74(s1)
    80006588:	2785                	addiw	a5,a5,1
    8000658a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000658e:	8526                	mv	a0,s1
    80006590:	ffffe097          	auipc	ra,0xffffe
    80006594:	1bc080e7          	jalr	444(ra) # 8000474c <iupdate>
  iunlock(ip);
    80006598:	8526                	mv	a0,s1
    8000659a:	ffffe097          	auipc	ra,0xffffe
    8000659e:	33e080e7          	jalr	830(ra) # 800048d8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800065a2:	fd040593          	addi	a1,s0,-48
    800065a6:	f5040513          	addi	a0,s0,-176
    800065aa:	fffff097          	auipc	ra,0xfffff
    800065ae:	a3e080e7          	jalr	-1474(ra) # 80004fe8 <nameiparent>
    800065b2:	892a                	mv	s2,a0
    800065b4:	c935                	beqz	a0,80006628 <sys_link+0x10a>
  ilock(dp);
    800065b6:	ffffe097          	auipc	ra,0xffffe
    800065ba:	260080e7          	jalr	608(ra) # 80004816 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800065be:	00092703          	lw	a4,0(s2)
    800065c2:	409c                	lw	a5,0(s1)
    800065c4:	04f71d63          	bne	a4,a5,8000661e <sys_link+0x100>
    800065c8:	40d0                	lw	a2,4(s1)
    800065ca:	fd040593          	addi	a1,s0,-48
    800065ce:	854a                	mv	a0,s2
    800065d0:	fffff097          	auipc	ra,0xfffff
    800065d4:	938080e7          	jalr	-1736(ra) # 80004f08 <dirlink>
    800065d8:	04054363          	bltz	a0,8000661e <sys_link+0x100>
  iunlockput(dp);
    800065dc:	854a                	mv	a0,s2
    800065de:	ffffe097          	auipc	ra,0xffffe
    800065e2:	49a080e7          	jalr	1178(ra) # 80004a78 <iunlockput>
  iput(ip);
    800065e6:	8526                	mv	a0,s1
    800065e8:	ffffe097          	auipc	ra,0xffffe
    800065ec:	3e8080e7          	jalr	1000(ra) # 800049d0 <iput>
  end_op();
    800065f0:	fffff097          	auipc	ra,0xfffff
    800065f4:	c7a080e7          	jalr	-902(ra) # 8000526a <end_op>
  return 0;
    800065f8:	4781                	li	a5,0
    800065fa:	a085                	j	8000665a <sys_link+0x13c>
    end_op();
    800065fc:	fffff097          	auipc	ra,0xfffff
    80006600:	c6e080e7          	jalr	-914(ra) # 8000526a <end_op>
    return -1;
    80006604:	57fd                	li	a5,-1
    80006606:	a891                	j	8000665a <sys_link+0x13c>
    iunlockput(ip);
    80006608:	8526                	mv	a0,s1
    8000660a:	ffffe097          	auipc	ra,0xffffe
    8000660e:	46e080e7          	jalr	1134(ra) # 80004a78 <iunlockput>
    end_op();
    80006612:	fffff097          	auipc	ra,0xfffff
    80006616:	c58080e7          	jalr	-936(ra) # 8000526a <end_op>
    return -1;
    8000661a:	57fd                	li	a5,-1
    8000661c:	a83d                	j	8000665a <sys_link+0x13c>
    iunlockput(dp);
    8000661e:	854a                	mv	a0,s2
    80006620:	ffffe097          	auipc	ra,0xffffe
    80006624:	458080e7          	jalr	1112(ra) # 80004a78 <iunlockput>
  ilock(ip);
    80006628:	8526                	mv	a0,s1
    8000662a:	ffffe097          	auipc	ra,0xffffe
    8000662e:	1ec080e7          	jalr	492(ra) # 80004816 <ilock>
  ip->nlink--;
    80006632:	04a4d783          	lhu	a5,74(s1)
    80006636:	37fd                	addiw	a5,a5,-1
    80006638:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000663c:	8526                	mv	a0,s1
    8000663e:	ffffe097          	auipc	ra,0xffffe
    80006642:	10e080e7          	jalr	270(ra) # 8000474c <iupdate>
  iunlockput(ip);
    80006646:	8526                	mv	a0,s1
    80006648:	ffffe097          	auipc	ra,0xffffe
    8000664c:	430080e7          	jalr	1072(ra) # 80004a78 <iunlockput>
  end_op();
    80006650:	fffff097          	auipc	ra,0xfffff
    80006654:	c1a080e7          	jalr	-998(ra) # 8000526a <end_op>
  return -1;
    80006658:	57fd                	li	a5,-1
}
    8000665a:	853e                	mv	a0,a5
    8000665c:	70b2                	ld	ra,296(sp)
    8000665e:	7412                	ld	s0,288(sp)
    80006660:	64f2                	ld	s1,280(sp)
    80006662:	6952                	ld	s2,272(sp)
    80006664:	6155                	addi	sp,sp,304
    80006666:	8082                	ret

0000000080006668 <sys_unlink>:
{
    80006668:	7151                	addi	sp,sp,-240
    8000666a:	f586                	sd	ra,232(sp)
    8000666c:	f1a2                	sd	s0,224(sp)
    8000666e:	eda6                	sd	s1,216(sp)
    80006670:	e9ca                	sd	s2,208(sp)
    80006672:	e5ce                	sd	s3,200(sp)
    80006674:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80006676:	08000613          	li	a2,128
    8000667a:	f3040593          	addi	a1,s0,-208
    8000667e:	4501                	li	a0,0
    80006680:	ffffd097          	auipc	ra,0xffffd
    80006684:	494080e7          	jalr	1172(ra) # 80003b14 <argstr>
    80006688:	18054163          	bltz	a0,8000680a <sys_unlink+0x1a2>
  begin_op();
    8000668c:	fffff097          	auipc	ra,0xfffff
    80006690:	b5e080e7          	jalr	-1186(ra) # 800051ea <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80006694:	fb040593          	addi	a1,s0,-80
    80006698:	f3040513          	addi	a0,s0,-208
    8000669c:	fffff097          	auipc	ra,0xfffff
    800066a0:	94c080e7          	jalr	-1716(ra) # 80004fe8 <nameiparent>
    800066a4:	84aa                	mv	s1,a0
    800066a6:	c979                	beqz	a0,8000677c <sys_unlink+0x114>
  ilock(dp);
    800066a8:	ffffe097          	auipc	ra,0xffffe
    800066ac:	16e080e7          	jalr	366(ra) # 80004816 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800066b0:	00003597          	auipc	a1,0x3
    800066b4:	25858593          	addi	a1,a1,600 # 80009908 <syscalls+0x2e8>
    800066b8:	fb040513          	addi	a0,s0,-80
    800066bc:	ffffe097          	auipc	ra,0xffffe
    800066c0:	624080e7          	jalr	1572(ra) # 80004ce0 <namecmp>
    800066c4:	14050a63          	beqz	a0,80006818 <sys_unlink+0x1b0>
    800066c8:	00003597          	auipc	a1,0x3
    800066cc:	24858593          	addi	a1,a1,584 # 80009910 <syscalls+0x2f0>
    800066d0:	fb040513          	addi	a0,s0,-80
    800066d4:	ffffe097          	auipc	ra,0xffffe
    800066d8:	60c080e7          	jalr	1548(ra) # 80004ce0 <namecmp>
    800066dc:	12050e63          	beqz	a0,80006818 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800066e0:	f2c40613          	addi	a2,s0,-212
    800066e4:	fb040593          	addi	a1,s0,-80
    800066e8:	8526                	mv	a0,s1
    800066ea:	ffffe097          	auipc	ra,0xffffe
    800066ee:	610080e7          	jalr	1552(ra) # 80004cfa <dirlookup>
    800066f2:	892a                	mv	s2,a0
    800066f4:	12050263          	beqz	a0,80006818 <sys_unlink+0x1b0>
  ilock(ip);
    800066f8:	ffffe097          	auipc	ra,0xffffe
    800066fc:	11e080e7          	jalr	286(ra) # 80004816 <ilock>
  if(ip->nlink < 1)
    80006700:	04a91783          	lh	a5,74(s2)
    80006704:	08f05263          	blez	a5,80006788 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006708:	04491703          	lh	a4,68(s2)
    8000670c:	4785                	li	a5,1
    8000670e:	08f70563          	beq	a4,a5,80006798 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80006712:	4641                	li	a2,16
    80006714:	4581                	li	a1,0
    80006716:	fc040513          	addi	a0,s0,-64
    8000671a:	ffffa097          	auipc	ra,0xffffa
    8000671e:	5ca080e7          	jalr	1482(ra) # 80000ce4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006722:	4741                	li	a4,16
    80006724:	f2c42683          	lw	a3,-212(s0)
    80006728:	fc040613          	addi	a2,s0,-64
    8000672c:	4581                	li	a1,0
    8000672e:	8526                	mv	a0,s1
    80006730:	ffffe097          	auipc	ra,0xffffe
    80006734:	492080e7          	jalr	1170(ra) # 80004bc2 <writei>
    80006738:	47c1                	li	a5,16
    8000673a:	0af51563          	bne	a0,a5,800067e4 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000673e:	04491703          	lh	a4,68(s2)
    80006742:	4785                	li	a5,1
    80006744:	0af70863          	beq	a4,a5,800067f4 <sys_unlink+0x18c>
  iunlockput(dp);
    80006748:	8526                	mv	a0,s1
    8000674a:	ffffe097          	auipc	ra,0xffffe
    8000674e:	32e080e7          	jalr	814(ra) # 80004a78 <iunlockput>
  ip->nlink--;
    80006752:	04a95783          	lhu	a5,74(s2)
    80006756:	37fd                	addiw	a5,a5,-1
    80006758:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000675c:	854a                	mv	a0,s2
    8000675e:	ffffe097          	auipc	ra,0xffffe
    80006762:	fee080e7          	jalr	-18(ra) # 8000474c <iupdate>
  iunlockput(ip);
    80006766:	854a                	mv	a0,s2
    80006768:	ffffe097          	auipc	ra,0xffffe
    8000676c:	310080e7          	jalr	784(ra) # 80004a78 <iunlockput>
  end_op();
    80006770:	fffff097          	auipc	ra,0xfffff
    80006774:	afa080e7          	jalr	-1286(ra) # 8000526a <end_op>
  return 0;
    80006778:	4501                	li	a0,0
    8000677a:	a84d                	j	8000682c <sys_unlink+0x1c4>
    end_op();
    8000677c:	fffff097          	auipc	ra,0xfffff
    80006780:	aee080e7          	jalr	-1298(ra) # 8000526a <end_op>
    return -1;
    80006784:	557d                	li	a0,-1
    80006786:	a05d                	j	8000682c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80006788:	00003517          	auipc	a0,0x3
    8000678c:	1b050513          	addi	a0,a0,432 # 80009938 <syscalls+0x318>
    80006790:	ffffa097          	auipc	ra,0xffffa
    80006794:	d9e080e7          	jalr	-610(ra) # 8000052e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006798:	04c92703          	lw	a4,76(s2)
    8000679c:	02000793          	li	a5,32
    800067a0:	f6e7f9e3          	bgeu	a5,a4,80006712 <sys_unlink+0xaa>
    800067a4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800067a8:	4741                	li	a4,16
    800067aa:	86ce                	mv	a3,s3
    800067ac:	f1840613          	addi	a2,s0,-232
    800067b0:	4581                	li	a1,0
    800067b2:	854a                	mv	a0,s2
    800067b4:	ffffe097          	auipc	ra,0xffffe
    800067b8:	316080e7          	jalr	790(ra) # 80004aca <readi>
    800067bc:	47c1                	li	a5,16
    800067be:	00f51b63          	bne	a0,a5,800067d4 <sys_unlink+0x16c>
    if(de.inum != 0)
    800067c2:	f1845783          	lhu	a5,-232(s0)
    800067c6:	e7a1                	bnez	a5,8000680e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800067c8:	29c1                	addiw	s3,s3,16
    800067ca:	04c92783          	lw	a5,76(s2)
    800067ce:	fcf9ede3          	bltu	s3,a5,800067a8 <sys_unlink+0x140>
    800067d2:	b781                	j	80006712 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800067d4:	00003517          	auipc	a0,0x3
    800067d8:	17c50513          	addi	a0,a0,380 # 80009950 <syscalls+0x330>
    800067dc:	ffffa097          	auipc	ra,0xffffa
    800067e0:	d52080e7          	jalr	-686(ra) # 8000052e <panic>
    panic("unlink: writei");
    800067e4:	00003517          	auipc	a0,0x3
    800067e8:	18450513          	addi	a0,a0,388 # 80009968 <syscalls+0x348>
    800067ec:	ffffa097          	auipc	ra,0xffffa
    800067f0:	d42080e7          	jalr	-702(ra) # 8000052e <panic>
    dp->nlink--;
    800067f4:	04a4d783          	lhu	a5,74(s1)
    800067f8:	37fd                	addiw	a5,a5,-1
    800067fa:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800067fe:	8526                	mv	a0,s1
    80006800:	ffffe097          	auipc	ra,0xffffe
    80006804:	f4c080e7          	jalr	-180(ra) # 8000474c <iupdate>
    80006808:	b781                	j	80006748 <sys_unlink+0xe0>
    return -1;
    8000680a:	557d                	li	a0,-1
    8000680c:	a005                	j	8000682c <sys_unlink+0x1c4>
    iunlockput(ip);
    8000680e:	854a                	mv	a0,s2
    80006810:	ffffe097          	auipc	ra,0xffffe
    80006814:	268080e7          	jalr	616(ra) # 80004a78 <iunlockput>
  iunlockput(dp);
    80006818:	8526                	mv	a0,s1
    8000681a:	ffffe097          	auipc	ra,0xffffe
    8000681e:	25e080e7          	jalr	606(ra) # 80004a78 <iunlockput>
  end_op();
    80006822:	fffff097          	auipc	ra,0xfffff
    80006826:	a48080e7          	jalr	-1464(ra) # 8000526a <end_op>
  return -1;
    8000682a:	557d                	li	a0,-1
}
    8000682c:	70ae                	ld	ra,232(sp)
    8000682e:	740e                	ld	s0,224(sp)
    80006830:	64ee                	ld	s1,216(sp)
    80006832:	694e                	ld	s2,208(sp)
    80006834:	69ae                	ld	s3,200(sp)
    80006836:	616d                	addi	sp,sp,240
    80006838:	8082                	ret

000000008000683a <sys_open>:

uint64
sys_open(void)
{
    8000683a:	7131                	addi	sp,sp,-192
    8000683c:	fd06                	sd	ra,184(sp)
    8000683e:	f922                	sd	s0,176(sp)
    80006840:	f526                	sd	s1,168(sp)
    80006842:	f14a                	sd	s2,160(sp)
    80006844:	ed4e                	sd	s3,152(sp)
    80006846:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006848:	08000613          	li	a2,128
    8000684c:	f5040593          	addi	a1,s0,-176
    80006850:	4501                	li	a0,0
    80006852:	ffffd097          	auipc	ra,0xffffd
    80006856:	2c2080e7          	jalr	706(ra) # 80003b14 <argstr>
    return -1;
    8000685a:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000685c:	0c054163          	bltz	a0,8000691e <sys_open+0xe4>
    80006860:	f4c40593          	addi	a1,s0,-180
    80006864:	4505                	li	a0,1
    80006866:	ffffd097          	auipc	ra,0xffffd
    8000686a:	26a080e7          	jalr	618(ra) # 80003ad0 <argint>
    8000686e:	0a054863          	bltz	a0,8000691e <sys_open+0xe4>

  begin_op();
    80006872:	fffff097          	auipc	ra,0xfffff
    80006876:	978080e7          	jalr	-1672(ra) # 800051ea <begin_op>

  if(omode & O_CREATE){
    8000687a:	f4c42783          	lw	a5,-180(s0)
    8000687e:	2007f793          	andi	a5,a5,512
    80006882:	cbdd                	beqz	a5,80006938 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80006884:	4681                	li	a3,0
    80006886:	4601                	li	a2,0
    80006888:	4589                	li	a1,2
    8000688a:	f5040513          	addi	a0,s0,-176
    8000688e:	00000097          	auipc	ra,0x0
    80006892:	974080e7          	jalr	-1676(ra) # 80006202 <create>
    80006896:	892a                	mv	s2,a0
    if(ip == 0){
    80006898:	c959                	beqz	a0,8000692e <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000689a:	04491703          	lh	a4,68(s2)
    8000689e:	478d                	li	a5,3
    800068a0:	00f71763          	bne	a4,a5,800068ae <sys_open+0x74>
    800068a4:	04695703          	lhu	a4,70(s2)
    800068a8:	47a5                	li	a5,9
    800068aa:	0ce7ec63          	bltu	a5,a4,80006982 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800068ae:	fffff097          	auipc	ra,0xfffff
    800068b2:	d4c080e7          	jalr	-692(ra) # 800055fa <filealloc>
    800068b6:	89aa                	mv	s3,a0
    800068b8:	10050263          	beqz	a0,800069bc <sys_open+0x182>
    800068bc:	00000097          	auipc	ra,0x0
    800068c0:	904080e7          	jalr	-1788(ra) # 800061c0 <fdalloc>
    800068c4:	84aa                	mv	s1,a0
    800068c6:	0e054663          	bltz	a0,800069b2 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800068ca:	04491703          	lh	a4,68(s2)
    800068ce:	478d                	li	a5,3
    800068d0:	0cf70463          	beq	a4,a5,80006998 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800068d4:	4789                	li	a5,2
    800068d6:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800068da:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800068de:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800068e2:	f4c42783          	lw	a5,-180(s0)
    800068e6:	0017c713          	xori	a4,a5,1
    800068ea:	8b05                	andi	a4,a4,1
    800068ec:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800068f0:	0037f713          	andi	a4,a5,3
    800068f4:	00e03733          	snez	a4,a4
    800068f8:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800068fc:	4007f793          	andi	a5,a5,1024
    80006900:	c791                	beqz	a5,8000690c <sys_open+0xd2>
    80006902:	04491703          	lh	a4,68(s2)
    80006906:	4789                	li	a5,2
    80006908:	08f70f63          	beq	a4,a5,800069a6 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000690c:	854a                	mv	a0,s2
    8000690e:	ffffe097          	auipc	ra,0xffffe
    80006912:	fca080e7          	jalr	-54(ra) # 800048d8 <iunlock>
  end_op();
    80006916:	fffff097          	auipc	ra,0xfffff
    8000691a:	954080e7          	jalr	-1708(ra) # 8000526a <end_op>

  return fd;
}
    8000691e:	8526                	mv	a0,s1
    80006920:	70ea                	ld	ra,184(sp)
    80006922:	744a                	ld	s0,176(sp)
    80006924:	74aa                	ld	s1,168(sp)
    80006926:	790a                	ld	s2,160(sp)
    80006928:	69ea                	ld	s3,152(sp)
    8000692a:	6129                	addi	sp,sp,192
    8000692c:	8082                	ret
      end_op();
    8000692e:	fffff097          	auipc	ra,0xfffff
    80006932:	93c080e7          	jalr	-1732(ra) # 8000526a <end_op>
      return -1;
    80006936:	b7e5                	j	8000691e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006938:	f5040513          	addi	a0,s0,-176
    8000693c:	ffffe097          	auipc	ra,0xffffe
    80006940:	68e080e7          	jalr	1678(ra) # 80004fca <namei>
    80006944:	892a                	mv	s2,a0
    80006946:	c905                	beqz	a0,80006976 <sys_open+0x13c>
    ilock(ip);
    80006948:	ffffe097          	auipc	ra,0xffffe
    8000694c:	ece080e7          	jalr	-306(ra) # 80004816 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006950:	04491703          	lh	a4,68(s2)
    80006954:	4785                	li	a5,1
    80006956:	f4f712e3          	bne	a4,a5,8000689a <sys_open+0x60>
    8000695a:	f4c42783          	lw	a5,-180(s0)
    8000695e:	dba1                	beqz	a5,800068ae <sys_open+0x74>
      iunlockput(ip);
    80006960:	854a                	mv	a0,s2
    80006962:	ffffe097          	auipc	ra,0xffffe
    80006966:	116080e7          	jalr	278(ra) # 80004a78 <iunlockput>
      end_op();
    8000696a:	fffff097          	auipc	ra,0xfffff
    8000696e:	900080e7          	jalr	-1792(ra) # 8000526a <end_op>
      return -1;
    80006972:	54fd                	li	s1,-1
    80006974:	b76d                	j	8000691e <sys_open+0xe4>
      end_op();
    80006976:	fffff097          	auipc	ra,0xfffff
    8000697a:	8f4080e7          	jalr	-1804(ra) # 8000526a <end_op>
      return -1;
    8000697e:	54fd                	li	s1,-1
    80006980:	bf79                	j	8000691e <sys_open+0xe4>
    iunlockput(ip);
    80006982:	854a                	mv	a0,s2
    80006984:	ffffe097          	auipc	ra,0xffffe
    80006988:	0f4080e7          	jalr	244(ra) # 80004a78 <iunlockput>
    end_op();
    8000698c:	fffff097          	auipc	ra,0xfffff
    80006990:	8de080e7          	jalr	-1826(ra) # 8000526a <end_op>
    return -1;
    80006994:	54fd                	li	s1,-1
    80006996:	b761                	j	8000691e <sys_open+0xe4>
    f->type = FD_DEVICE;
    80006998:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000699c:	04691783          	lh	a5,70(s2)
    800069a0:	02f99223          	sh	a5,36(s3)
    800069a4:	bf2d                	j	800068de <sys_open+0xa4>
    itrunc(ip);
    800069a6:	854a                	mv	a0,s2
    800069a8:	ffffe097          	auipc	ra,0xffffe
    800069ac:	f7c080e7          	jalr	-132(ra) # 80004924 <itrunc>
    800069b0:	bfb1                	j	8000690c <sys_open+0xd2>
      fileclose(f);
    800069b2:	854e                	mv	a0,s3
    800069b4:	fffff097          	auipc	ra,0xfffff
    800069b8:	d02080e7          	jalr	-766(ra) # 800056b6 <fileclose>
    iunlockput(ip);
    800069bc:	854a                	mv	a0,s2
    800069be:	ffffe097          	auipc	ra,0xffffe
    800069c2:	0ba080e7          	jalr	186(ra) # 80004a78 <iunlockput>
    end_op();
    800069c6:	fffff097          	auipc	ra,0xfffff
    800069ca:	8a4080e7          	jalr	-1884(ra) # 8000526a <end_op>
    return -1;
    800069ce:	54fd                	li	s1,-1
    800069d0:	b7b9                	j	8000691e <sys_open+0xe4>

00000000800069d2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800069d2:	7175                	addi	sp,sp,-144
    800069d4:	e506                	sd	ra,136(sp)
    800069d6:	e122                	sd	s0,128(sp)
    800069d8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800069da:	fffff097          	auipc	ra,0xfffff
    800069de:	810080e7          	jalr	-2032(ra) # 800051ea <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800069e2:	08000613          	li	a2,128
    800069e6:	f7040593          	addi	a1,s0,-144
    800069ea:	4501                	li	a0,0
    800069ec:	ffffd097          	auipc	ra,0xffffd
    800069f0:	128080e7          	jalr	296(ra) # 80003b14 <argstr>
    800069f4:	02054963          	bltz	a0,80006a26 <sys_mkdir+0x54>
    800069f8:	4681                	li	a3,0
    800069fa:	4601                	li	a2,0
    800069fc:	4585                	li	a1,1
    800069fe:	f7040513          	addi	a0,s0,-144
    80006a02:	00000097          	auipc	ra,0x0
    80006a06:	800080e7          	jalr	-2048(ra) # 80006202 <create>
    80006a0a:	cd11                	beqz	a0,80006a26 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006a0c:	ffffe097          	auipc	ra,0xffffe
    80006a10:	06c080e7          	jalr	108(ra) # 80004a78 <iunlockput>
  end_op();
    80006a14:	fffff097          	auipc	ra,0xfffff
    80006a18:	856080e7          	jalr	-1962(ra) # 8000526a <end_op>
  return 0;
    80006a1c:	4501                	li	a0,0
}
    80006a1e:	60aa                	ld	ra,136(sp)
    80006a20:	640a                	ld	s0,128(sp)
    80006a22:	6149                	addi	sp,sp,144
    80006a24:	8082                	ret
    end_op();
    80006a26:	fffff097          	auipc	ra,0xfffff
    80006a2a:	844080e7          	jalr	-1980(ra) # 8000526a <end_op>
    return -1;
    80006a2e:	557d                	li	a0,-1
    80006a30:	b7fd                	j	80006a1e <sys_mkdir+0x4c>

0000000080006a32 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006a32:	7135                	addi	sp,sp,-160
    80006a34:	ed06                	sd	ra,152(sp)
    80006a36:	e922                	sd	s0,144(sp)
    80006a38:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006a3a:	ffffe097          	auipc	ra,0xffffe
    80006a3e:	7b0080e7          	jalr	1968(ra) # 800051ea <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006a42:	08000613          	li	a2,128
    80006a46:	f7040593          	addi	a1,s0,-144
    80006a4a:	4501                	li	a0,0
    80006a4c:	ffffd097          	auipc	ra,0xffffd
    80006a50:	0c8080e7          	jalr	200(ra) # 80003b14 <argstr>
    80006a54:	04054a63          	bltz	a0,80006aa8 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80006a58:	f6c40593          	addi	a1,s0,-148
    80006a5c:	4505                	li	a0,1
    80006a5e:	ffffd097          	auipc	ra,0xffffd
    80006a62:	072080e7          	jalr	114(ra) # 80003ad0 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006a66:	04054163          	bltz	a0,80006aa8 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80006a6a:	f6840593          	addi	a1,s0,-152
    80006a6e:	4509                	li	a0,2
    80006a70:	ffffd097          	auipc	ra,0xffffd
    80006a74:	060080e7          	jalr	96(ra) # 80003ad0 <argint>
     argint(1, &major) < 0 ||
    80006a78:	02054863          	bltz	a0,80006aa8 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006a7c:	f6841683          	lh	a3,-152(s0)
    80006a80:	f6c41603          	lh	a2,-148(s0)
    80006a84:	458d                	li	a1,3
    80006a86:	f7040513          	addi	a0,s0,-144
    80006a8a:	fffff097          	auipc	ra,0xfffff
    80006a8e:	778080e7          	jalr	1912(ra) # 80006202 <create>
     argint(2, &minor) < 0 ||
    80006a92:	c919                	beqz	a0,80006aa8 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006a94:	ffffe097          	auipc	ra,0xffffe
    80006a98:	fe4080e7          	jalr	-28(ra) # 80004a78 <iunlockput>
  end_op();
    80006a9c:	ffffe097          	auipc	ra,0xffffe
    80006aa0:	7ce080e7          	jalr	1998(ra) # 8000526a <end_op>
  return 0;
    80006aa4:	4501                	li	a0,0
    80006aa6:	a031                	j	80006ab2 <sys_mknod+0x80>
    end_op();
    80006aa8:	ffffe097          	auipc	ra,0xffffe
    80006aac:	7c2080e7          	jalr	1986(ra) # 8000526a <end_op>
    return -1;
    80006ab0:	557d                	li	a0,-1
}
    80006ab2:	60ea                	ld	ra,152(sp)
    80006ab4:	644a                	ld	s0,144(sp)
    80006ab6:	610d                	addi	sp,sp,160
    80006ab8:	8082                	ret

0000000080006aba <sys_chdir>:

uint64
sys_chdir(void)
{
    80006aba:	7135                	addi	sp,sp,-160
    80006abc:	ed06                	sd	ra,152(sp)
    80006abe:	e922                	sd	s0,144(sp)
    80006ac0:	e526                	sd	s1,136(sp)
    80006ac2:	e14a                	sd	s2,128(sp)
    80006ac4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006ac6:	ffffb097          	auipc	ra,0xffffb
    80006aca:	fb6080e7          	jalr	-74(ra) # 80001a7c <myproc>
    80006ace:	892a                	mv	s2,a0
  
  begin_op();
    80006ad0:	ffffe097          	auipc	ra,0xffffe
    80006ad4:	71a080e7          	jalr	1818(ra) # 800051ea <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006ad8:	08000613          	li	a2,128
    80006adc:	f6040593          	addi	a1,s0,-160
    80006ae0:	4501                	li	a0,0
    80006ae2:	ffffd097          	auipc	ra,0xffffd
    80006ae6:	032080e7          	jalr	50(ra) # 80003b14 <argstr>
    80006aea:	04054b63          	bltz	a0,80006b40 <sys_chdir+0x86>
    80006aee:	f6040513          	addi	a0,s0,-160
    80006af2:	ffffe097          	auipc	ra,0xffffe
    80006af6:	4d8080e7          	jalr	1240(ra) # 80004fca <namei>
    80006afa:	84aa                	mv	s1,a0
    80006afc:	c131                	beqz	a0,80006b40 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006afe:	ffffe097          	auipc	ra,0xffffe
    80006b02:	d18080e7          	jalr	-744(ra) # 80004816 <ilock>
  if(ip->type != T_DIR){
    80006b06:	04449703          	lh	a4,68(s1)
    80006b0a:	4785                	li	a5,1
    80006b0c:	04f71063          	bne	a4,a5,80006b4c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006b10:	8526                	mv	a0,s1
    80006b12:	ffffe097          	auipc	ra,0xffffe
    80006b16:	dc6080e7          	jalr	-570(ra) # 800048d8 <iunlock>
  iput(p->cwd);
    80006b1a:	0d093503          	ld	a0,208(s2)
    80006b1e:	ffffe097          	auipc	ra,0xffffe
    80006b22:	eb2080e7          	jalr	-334(ra) # 800049d0 <iput>
  end_op();
    80006b26:	ffffe097          	auipc	ra,0xffffe
    80006b2a:	744080e7          	jalr	1860(ra) # 8000526a <end_op>
  p->cwd = ip;
    80006b2e:	0c993823          	sd	s1,208(s2)
  return 0;
    80006b32:	4501                	li	a0,0
}
    80006b34:	60ea                	ld	ra,152(sp)
    80006b36:	644a                	ld	s0,144(sp)
    80006b38:	64aa                	ld	s1,136(sp)
    80006b3a:	690a                	ld	s2,128(sp)
    80006b3c:	610d                	addi	sp,sp,160
    80006b3e:	8082                	ret
    end_op();
    80006b40:	ffffe097          	auipc	ra,0xffffe
    80006b44:	72a080e7          	jalr	1834(ra) # 8000526a <end_op>
    return -1;
    80006b48:	557d                	li	a0,-1
    80006b4a:	b7ed                	j	80006b34 <sys_chdir+0x7a>
    iunlockput(ip);
    80006b4c:	8526                	mv	a0,s1
    80006b4e:	ffffe097          	auipc	ra,0xffffe
    80006b52:	f2a080e7          	jalr	-214(ra) # 80004a78 <iunlockput>
    end_op();
    80006b56:	ffffe097          	auipc	ra,0xffffe
    80006b5a:	714080e7          	jalr	1812(ra) # 8000526a <end_op>
    return -1;
    80006b5e:	557d                	li	a0,-1
    80006b60:	bfd1                	j	80006b34 <sys_chdir+0x7a>

0000000080006b62 <sys_exec>:

uint64
sys_exec(void)
{
    80006b62:	7145                	addi	sp,sp,-464
    80006b64:	e786                	sd	ra,456(sp)
    80006b66:	e3a2                	sd	s0,448(sp)
    80006b68:	ff26                	sd	s1,440(sp)
    80006b6a:	fb4a                	sd	s2,432(sp)
    80006b6c:	f74e                	sd	s3,424(sp)
    80006b6e:	f352                	sd	s4,416(sp)
    80006b70:	ef56                	sd	s5,408(sp)
    80006b72:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006b74:	08000613          	li	a2,128
    80006b78:	f4040593          	addi	a1,s0,-192
    80006b7c:	4501                	li	a0,0
    80006b7e:	ffffd097          	auipc	ra,0xffffd
    80006b82:	f96080e7          	jalr	-106(ra) # 80003b14 <argstr>
    return -1;
    80006b86:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006b88:	0c054a63          	bltz	a0,80006c5c <sys_exec+0xfa>
    80006b8c:	e3840593          	addi	a1,s0,-456
    80006b90:	4505                	li	a0,1
    80006b92:	ffffd097          	auipc	ra,0xffffd
    80006b96:	f60080e7          	jalr	-160(ra) # 80003af2 <argaddr>
    80006b9a:	0c054163          	bltz	a0,80006c5c <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006b9e:	10000613          	li	a2,256
    80006ba2:	4581                	li	a1,0
    80006ba4:	e4040513          	addi	a0,s0,-448
    80006ba8:	ffffa097          	auipc	ra,0xffffa
    80006bac:	13c080e7          	jalr	316(ra) # 80000ce4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006bb0:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006bb4:	89a6                	mv	s3,s1
    80006bb6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006bb8:	02000a13          	li	s4,32
    80006bbc:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006bc0:	00391793          	slli	a5,s2,0x3
    80006bc4:	e3040593          	addi	a1,s0,-464
    80006bc8:	e3843503          	ld	a0,-456(s0)
    80006bcc:	953e                	add	a0,a0,a5
    80006bce:	ffffd097          	auipc	ra,0xffffd
    80006bd2:	e68080e7          	jalr	-408(ra) # 80003a36 <fetchaddr>
    80006bd6:	02054a63          	bltz	a0,80006c0a <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006bda:	e3043783          	ld	a5,-464(s0)
    80006bde:	c3b9                	beqz	a5,80006c24 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006be0:	ffffa097          	auipc	ra,0xffffa
    80006be4:	ef6080e7          	jalr	-266(ra) # 80000ad6 <kalloc>
    80006be8:	85aa                	mv	a1,a0
    80006bea:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006bee:	cd11                	beqz	a0,80006c0a <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006bf0:	6605                	lui	a2,0x1
    80006bf2:	e3043503          	ld	a0,-464(s0)
    80006bf6:	ffffd097          	auipc	ra,0xffffd
    80006bfa:	e92080e7          	jalr	-366(ra) # 80003a88 <fetchstr>
    80006bfe:	00054663          	bltz	a0,80006c0a <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006c02:	0905                	addi	s2,s2,1
    80006c04:	09a1                	addi	s3,s3,8
    80006c06:	fb491be3          	bne	s2,s4,80006bbc <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006c0a:	10048913          	addi	s2,s1,256
    80006c0e:	6088                	ld	a0,0(s1)
    80006c10:	c529                	beqz	a0,80006c5a <sys_exec+0xf8>
    kfree(argv[i]);
    80006c12:	ffffa097          	auipc	ra,0xffffa
    80006c16:	dc8080e7          	jalr	-568(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006c1a:	04a1                	addi	s1,s1,8
    80006c1c:	ff2499e3          	bne	s1,s2,80006c0e <sys_exec+0xac>
  return -1;
    80006c20:	597d                	li	s2,-1
    80006c22:	a82d                	j	80006c5c <sys_exec+0xfa>
      argv[i] = 0;
    80006c24:	0a8e                	slli	s5,s5,0x3
    80006c26:	fc040793          	addi	a5,s0,-64
    80006c2a:	9abe                	add	s5,s5,a5
    80006c2c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006c30:	e4040593          	addi	a1,s0,-448
    80006c34:	f4040513          	addi	a0,s0,-192
    80006c38:	fffff097          	auipc	ra,0xfffff
    80006c3c:	0dc080e7          	jalr	220(ra) # 80005d14 <exec>
    80006c40:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006c42:	10048993          	addi	s3,s1,256
    80006c46:	6088                	ld	a0,0(s1)
    80006c48:	c911                	beqz	a0,80006c5c <sys_exec+0xfa>
    kfree(argv[i]);
    80006c4a:	ffffa097          	auipc	ra,0xffffa
    80006c4e:	d90080e7          	jalr	-624(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006c52:	04a1                	addi	s1,s1,8
    80006c54:	ff3499e3          	bne	s1,s3,80006c46 <sys_exec+0xe4>
    80006c58:	a011                	j	80006c5c <sys_exec+0xfa>
  return -1;
    80006c5a:	597d                	li	s2,-1
}
    80006c5c:	854a                	mv	a0,s2
    80006c5e:	60be                	ld	ra,456(sp)
    80006c60:	641e                	ld	s0,448(sp)
    80006c62:	74fa                	ld	s1,440(sp)
    80006c64:	795a                	ld	s2,432(sp)
    80006c66:	79ba                	ld	s3,424(sp)
    80006c68:	7a1a                	ld	s4,416(sp)
    80006c6a:	6afa                	ld	s5,408(sp)
    80006c6c:	6179                	addi	sp,sp,464
    80006c6e:	8082                	ret

0000000080006c70 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006c70:	7139                	addi	sp,sp,-64
    80006c72:	fc06                	sd	ra,56(sp)
    80006c74:	f822                	sd	s0,48(sp)
    80006c76:	f426                	sd	s1,40(sp)
    80006c78:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006c7a:	ffffb097          	auipc	ra,0xffffb
    80006c7e:	e02080e7          	jalr	-510(ra) # 80001a7c <myproc>
    80006c82:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006c84:	fd840593          	addi	a1,s0,-40
    80006c88:	4501                	li	a0,0
    80006c8a:	ffffd097          	auipc	ra,0xffffd
    80006c8e:	e68080e7          	jalr	-408(ra) # 80003af2 <argaddr>
    return -1;
    80006c92:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006c94:	0e054063          	bltz	a0,80006d74 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006c98:	fc840593          	addi	a1,s0,-56
    80006c9c:	fd040513          	addi	a0,s0,-48
    80006ca0:	fffff097          	auipc	ra,0xfffff
    80006ca4:	d46080e7          	jalr	-698(ra) # 800059e6 <pipealloc>
    return -1;
    80006ca8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006caa:	0c054563          	bltz	a0,80006d74 <sys_pipe+0x104>
  fd0 = -1;
    80006cae:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006cb2:	fd043503          	ld	a0,-48(s0)
    80006cb6:	fffff097          	auipc	ra,0xfffff
    80006cba:	50a080e7          	jalr	1290(ra) # 800061c0 <fdalloc>
    80006cbe:	fca42223          	sw	a0,-60(s0)
    80006cc2:	08054c63          	bltz	a0,80006d5a <sys_pipe+0xea>
    80006cc6:	fc843503          	ld	a0,-56(s0)
    80006cca:	fffff097          	auipc	ra,0xfffff
    80006cce:	4f6080e7          	jalr	1270(ra) # 800061c0 <fdalloc>
    80006cd2:	fca42023          	sw	a0,-64(s0)
    80006cd6:	06054863          	bltz	a0,80006d46 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006cda:	4691                	li	a3,4
    80006cdc:	fc440613          	addi	a2,s0,-60
    80006ce0:	fd843583          	ld	a1,-40(s0)
    80006ce4:	60a8                	ld	a0,64(s1)
    80006ce6:	ffffb097          	auipc	ra,0xffffb
    80006cea:	97e080e7          	jalr	-1666(ra) # 80001664 <copyout>
    80006cee:	02054063          	bltz	a0,80006d0e <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006cf2:	4691                	li	a3,4
    80006cf4:	fc040613          	addi	a2,s0,-64
    80006cf8:	fd843583          	ld	a1,-40(s0)
    80006cfc:	0591                	addi	a1,a1,4
    80006cfe:	60a8                	ld	a0,64(s1)
    80006d00:	ffffb097          	auipc	ra,0xffffb
    80006d04:	964080e7          	jalr	-1692(ra) # 80001664 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006d08:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006d0a:	06055563          	bgez	a0,80006d74 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006d0e:	fc442783          	lw	a5,-60(s0)
    80006d12:	07a9                	addi	a5,a5,10
    80006d14:	078e                	slli	a5,a5,0x3
    80006d16:	97a6                	add	a5,a5,s1
    80006d18:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006d1c:	fc042503          	lw	a0,-64(s0)
    80006d20:	0529                	addi	a0,a0,10
    80006d22:	050e                	slli	a0,a0,0x3
    80006d24:	9526                	add	a0,a0,s1
    80006d26:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006d2a:	fd043503          	ld	a0,-48(s0)
    80006d2e:	fffff097          	auipc	ra,0xfffff
    80006d32:	988080e7          	jalr	-1656(ra) # 800056b6 <fileclose>
    fileclose(wf);
    80006d36:	fc843503          	ld	a0,-56(s0)
    80006d3a:	fffff097          	auipc	ra,0xfffff
    80006d3e:	97c080e7          	jalr	-1668(ra) # 800056b6 <fileclose>
    return -1;
    80006d42:	57fd                	li	a5,-1
    80006d44:	a805                	j	80006d74 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006d46:	fc442783          	lw	a5,-60(s0)
    80006d4a:	0007c863          	bltz	a5,80006d5a <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006d4e:	00a78513          	addi	a0,a5,10
    80006d52:	050e                	slli	a0,a0,0x3
    80006d54:	9526                	add	a0,a0,s1
    80006d56:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006d5a:	fd043503          	ld	a0,-48(s0)
    80006d5e:	fffff097          	auipc	ra,0xfffff
    80006d62:	958080e7          	jalr	-1704(ra) # 800056b6 <fileclose>
    fileclose(wf);
    80006d66:	fc843503          	ld	a0,-56(s0)
    80006d6a:	fffff097          	auipc	ra,0xfffff
    80006d6e:	94c080e7          	jalr	-1716(ra) # 800056b6 <fileclose>
    return -1;
    80006d72:	57fd                	li	a5,-1
}
    80006d74:	853e                	mv	a0,a5
    80006d76:	70e2                	ld	ra,56(sp)
    80006d78:	7442                	ld	s0,48(sp)
    80006d7a:	74a2                	ld	s1,40(sp)
    80006d7c:	6121                	addi	sp,sp,64
    80006d7e:	8082                	ret

0000000080006d80 <kernelvec>:
    80006d80:	7111                	addi	sp,sp,-256
    80006d82:	e006                	sd	ra,0(sp)
    80006d84:	e40a                	sd	sp,8(sp)
    80006d86:	e80e                	sd	gp,16(sp)
    80006d88:	ec12                	sd	tp,24(sp)
    80006d8a:	f016                	sd	t0,32(sp)
    80006d8c:	f41a                	sd	t1,40(sp)
    80006d8e:	f81e                	sd	t2,48(sp)
    80006d90:	fc22                	sd	s0,56(sp)
    80006d92:	e0a6                	sd	s1,64(sp)
    80006d94:	e4aa                	sd	a0,72(sp)
    80006d96:	e8ae                	sd	a1,80(sp)
    80006d98:	ecb2                	sd	a2,88(sp)
    80006d9a:	f0b6                	sd	a3,96(sp)
    80006d9c:	f4ba                	sd	a4,104(sp)
    80006d9e:	f8be                	sd	a5,112(sp)
    80006da0:	fcc2                	sd	a6,120(sp)
    80006da2:	e146                	sd	a7,128(sp)
    80006da4:	e54a                	sd	s2,136(sp)
    80006da6:	e94e                	sd	s3,144(sp)
    80006da8:	ed52                	sd	s4,152(sp)
    80006daa:	f156                	sd	s5,160(sp)
    80006dac:	f55a                	sd	s6,168(sp)
    80006dae:	f95e                	sd	s7,176(sp)
    80006db0:	fd62                	sd	s8,184(sp)
    80006db2:	e1e6                	sd	s9,192(sp)
    80006db4:	e5ea                	sd	s10,200(sp)
    80006db6:	e9ee                	sd	s11,208(sp)
    80006db8:	edf2                	sd	t3,216(sp)
    80006dba:	f1f6                	sd	t4,224(sp)
    80006dbc:	f5fa                	sd	t5,232(sp)
    80006dbe:	f9fe                	sd	t6,240(sp)
    80006dc0:	b17fc0ef          	jal	ra,800038d6 <kerneltrap>
    80006dc4:	6082                	ld	ra,0(sp)
    80006dc6:	6122                	ld	sp,8(sp)
    80006dc8:	61c2                	ld	gp,16(sp)
    80006dca:	7282                	ld	t0,32(sp)
    80006dcc:	7322                	ld	t1,40(sp)
    80006dce:	73c2                	ld	t2,48(sp)
    80006dd0:	7462                	ld	s0,56(sp)
    80006dd2:	6486                	ld	s1,64(sp)
    80006dd4:	6526                	ld	a0,72(sp)
    80006dd6:	65c6                	ld	a1,80(sp)
    80006dd8:	6666                	ld	a2,88(sp)
    80006dda:	7686                	ld	a3,96(sp)
    80006ddc:	7726                	ld	a4,104(sp)
    80006dde:	77c6                	ld	a5,112(sp)
    80006de0:	7866                	ld	a6,120(sp)
    80006de2:	688a                	ld	a7,128(sp)
    80006de4:	692a                	ld	s2,136(sp)
    80006de6:	69ca                	ld	s3,144(sp)
    80006de8:	6a6a                	ld	s4,152(sp)
    80006dea:	7a8a                	ld	s5,160(sp)
    80006dec:	7b2a                	ld	s6,168(sp)
    80006dee:	7bca                	ld	s7,176(sp)
    80006df0:	7c6a                	ld	s8,184(sp)
    80006df2:	6c8e                	ld	s9,192(sp)
    80006df4:	6d2e                	ld	s10,200(sp)
    80006df6:	6dce                	ld	s11,208(sp)
    80006df8:	6e6e                	ld	t3,216(sp)
    80006dfa:	7e8e                	ld	t4,224(sp)
    80006dfc:	7f2e                	ld	t5,232(sp)
    80006dfe:	7fce                	ld	t6,240(sp)
    80006e00:	6111                	addi	sp,sp,256
    80006e02:	10200073          	sret
    80006e06:	00000013          	nop
    80006e0a:	00000013          	nop
    80006e0e:	0001                	nop

0000000080006e10 <timervec>:
    80006e10:	34051573          	csrrw	a0,mscratch,a0
    80006e14:	e10c                	sd	a1,0(a0)
    80006e16:	e510                	sd	a2,8(a0)
    80006e18:	e914                	sd	a3,16(a0)
    80006e1a:	6d0c                	ld	a1,24(a0)
    80006e1c:	7110                	ld	a2,32(a0)
    80006e1e:	6194                	ld	a3,0(a1)
    80006e20:	96b2                	add	a3,a3,a2
    80006e22:	e194                	sd	a3,0(a1)
    80006e24:	4589                	li	a1,2
    80006e26:	14459073          	csrw	sip,a1
    80006e2a:	6914                	ld	a3,16(a0)
    80006e2c:	6510                	ld	a2,8(a0)
    80006e2e:	610c                	ld	a1,0(a0)
    80006e30:	34051573          	csrrw	a0,mscratch,a0
    80006e34:	30200073          	mret
	...

0000000080006e3a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006e3a:	1141                	addi	sp,sp,-16
    80006e3c:	e422                	sd	s0,8(sp)
    80006e3e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006e40:	0c0007b7          	lui	a5,0xc000
    80006e44:	4705                	li	a4,1
    80006e46:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006e48:	c3d8                	sw	a4,4(a5)
}
    80006e4a:	6422                	ld	s0,8(sp)
    80006e4c:	0141                	addi	sp,sp,16
    80006e4e:	8082                	ret

0000000080006e50 <plicinithart>:

void
plicinithart(void)
{
    80006e50:	1141                	addi	sp,sp,-16
    80006e52:	e406                	sd	ra,8(sp)
    80006e54:	e022                	sd	s0,0(sp)
    80006e56:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006e58:	ffffb097          	auipc	ra,0xffffb
    80006e5c:	bf0080e7          	jalr	-1040(ra) # 80001a48 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006e60:	0085171b          	slliw	a4,a0,0x8
    80006e64:	0c0027b7          	lui	a5,0xc002
    80006e68:	97ba                	add	a5,a5,a4
    80006e6a:	40200713          	li	a4,1026
    80006e6e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006e72:	00d5151b          	slliw	a0,a0,0xd
    80006e76:	0c2017b7          	lui	a5,0xc201
    80006e7a:	953e                	add	a0,a0,a5
    80006e7c:	00052023          	sw	zero,0(a0)
}
    80006e80:	60a2                	ld	ra,8(sp)
    80006e82:	6402                	ld	s0,0(sp)
    80006e84:	0141                	addi	sp,sp,16
    80006e86:	8082                	ret

0000000080006e88 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006e88:	1141                	addi	sp,sp,-16
    80006e8a:	e406                	sd	ra,8(sp)
    80006e8c:	e022                	sd	s0,0(sp)
    80006e8e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006e90:	ffffb097          	auipc	ra,0xffffb
    80006e94:	bb8080e7          	jalr	-1096(ra) # 80001a48 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006e98:	00d5179b          	slliw	a5,a0,0xd
    80006e9c:	0c201537          	lui	a0,0xc201
    80006ea0:	953e                	add	a0,a0,a5
  return irq;
}
    80006ea2:	4148                	lw	a0,4(a0)
    80006ea4:	60a2                	ld	ra,8(sp)
    80006ea6:	6402                	ld	s0,0(sp)
    80006ea8:	0141                	addi	sp,sp,16
    80006eaa:	8082                	ret

0000000080006eac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006eac:	1101                	addi	sp,sp,-32
    80006eae:	ec06                	sd	ra,24(sp)
    80006eb0:	e822                	sd	s0,16(sp)
    80006eb2:	e426                	sd	s1,8(sp)
    80006eb4:	1000                	addi	s0,sp,32
    80006eb6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006eb8:	ffffb097          	auipc	ra,0xffffb
    80006ebc:	b90080e7          	jalr	-1136(ra) # 80001a48 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006ec0:	00d5151b          	slliw	a0,a0,0xd
    80006ec4:	0c2017b7          	lui	a5,0xc201
    80006ec8:	97aa                	add	a5,a5,a0
    80006eca:	c3c4                	sw	s1,4(a5)
}
    80006ecc:	60e2                	ld	ra,24(sp)
    80006ece:	6442                	ld	s0,16(sp)
    80006ed0:	64a2                	ld	s1,8(sp)
    80006ed2:	6105                	addi	sp,sp,32
    80006ed4:	8082                	ret

0000000080006ed6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006ed6:	1141                	addi	sp,sp,-16
    80006ed8:	e406                	sd	ra,8(sp)
    80006eda:	e022                	sd	s0,0(sp)
    80006edc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006ede:	479d                	li	a5,7
    80006ee0:	06a7c963          	blt	a5,a0,80006f52 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006ee4:	00038797          	auipc	a5,0x38
    80006ee8:	11c78793          	addi	a5,a5,284 # 8003f000 <disk>
    80006eec:	00a78733          	add	a4,a5,a0
    80006ef0:	6789                	lui	a5,0x2
    80006ef2:	97ba                	add	a5,a5,a4
    80006ef4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006ef8:	e7ad                	bnez	a5,80006f62 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006efa:	00451793          	slli	a5,a0,0x4
    80006efe:	0003a717          	auipc	a4,0x3a
    80006f02:	10270713          	addi	a4,a4,258 # 80041000 <disk+0x2000>
    80006f06:	6314                	ld	a3,0(a4)
    80006f08:	96be                	add	a3,a3,a5
    80006f0a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006f0e:	6314                	ld	a3,0(a4)
    80006f10:	96be                	add	a3,a3,a5
    80006f12:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006f16:	6314                	ld	a3,0(a4)
    80006f18:	96be                	add	a3,a3,a5
    80006f1a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006f1e:	6318                	ld	a4,0(a4)
    80006f20:	97ba                	add	a5,a5,a4
    80006f22:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006f26:	00038797          	auipc	a5,0x38
    80006f2a:	0da78793          	addi	a5,a5,218 # 8003f000 <disk>
    80006f2e:	97aa                	add	a5,a5,a0
    80006f30:	6509                	lui	a0,0x2
    80006f32:	953e                	add	a0,a0,a5
    80006f34:	4785                	li	a5,1
    80006f36:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006f3a:	0003a517          	auipc	a0,0x3a
    80006f3e:	0de50513          	addi	a0,a0,222 # 80041018 <disk+0x2018>
    80006f42:	ffffb097          	auipc	ra,0xffffb
    80006f46:	684080e7          	jalr	1668(ra) # 800025c6 <wakeup>
}
    80006f4a:	60a2                	ld	ra,8(sp)
    80006f4c:	6402                	ld	s0,0(sp)
    80006f4e:	0141                	addi	sp,sp,16
    80006f50:	8082                	ret
    panic("free_desc 1");
    80006f52:	00003517          	auipc	a0,0x3
    80006f56:	a2650513          	addi	a0,a0,-1498 # 80009978 <syscalls+0x358>
    80006f5a:	ffff9097          	auipc	ra,0xffff9
    80006f5e:	5d4080e7          	jalr	1492(ra) # 8000052e <panic>
    panic("free_desc 2");
    80006f62:	00003517          	auipc	a0,0x3
    80006f66:	a2650513          	addi	a0,a0,-1498 # 80009988 <syscalls+0x368>
    80006f6a:	ffff9097          	auipc	ra,0xffff9
    80006f6e:	5c4080e7          	jalr	1476(ra) # 8000052e <panic>

0000000080006f72 <virtio_disk_init>:
{
    80006f72:	1101                	addi	sp,sp,-32
    80006f74:	ec06                	sd	ra,24(sp)
    80006f76:	e822                	sd	s0,16(sp)
    80006f78:	e426                	sd	s1,8(sp)
    80006f7a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006f7c:	00003597          	auipc	a1,0x3
    80006f80:	a1c58593          	addi	a1,a1,-1508 # 80009998 <syscalls+0x378>
    80006f84:	0003a517          	auipc	a0,0x3a
    80006f88:	1a450513          	addi	a0,a0,420 # 80041128 <disk+0x2128>
    80006f8c:	ffffa097          	auipc	ra,0xffffa
    80006f90:	baa080e7          	jalr	-1110(ra) # 80000b36 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006f94:	100017b7          	lui	a5,0x10001
    80006f98:	4398                	lw	a4,0(a5)
    80006f9a:	2701                	sext.w	a4,a4
    80006f9c:	747277b7          	lui	a5,0x74727
    80006fa0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006fa4:	0ef71163          	bne	a4,a5,80007086 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006fa8:	100017b7          	lui	a5,0x10001
    80006fac:	43dc                	lw	a5,4(a5)
    80006fae:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006fb0:	4705                	li	a4,1
    80006fb2:	0ce79a63          	bne	a5,a4,80007086 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006fb6:	100017b7          	lui	a5,0x10001
    80006fba:	479c                	lw	a5,8(a5)
    80006fbc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006fbe:	4709                	li	a4,2
    80006fc0:	0ce79363          	bne	a5,a4,80007086 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006fc4:	100017b7          	lui	a5,0x10001
    80006fc8:	47d8                	lw	a4,12(a5)
    80006fca:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006fcc:	554d47b7          	lui	a5,0x554d4
    80006fd0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006fd4:	0af71963          	bne	a4,a5,80007086 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006fd8:	100017b7          	lui	a5,0x10001
    80006fdc:	4705                	li	a4,1
    80006fde:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006fe0:	470d                	li	a4,3
    80006fe2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006fe4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006fe6:	c7ffe737          	lui	a4,0xc7ffe
    80006fea:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fbc75f>
    80006fee:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006ff0:	2701                	sext.w	a4,a4
    80006ff2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006ff4:	472d                	li	a4,11
    80006ff6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006ff8:	473d                	li	a4,15
    80006ffa:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006ffc:	6705                	lui	a4,0x1
    80006ffe:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80007000:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80007004:	5bdc                	lw	a5,52(a5)
    80007006:	2781                	sext.w	a5,a5
  if(max == 0)
    80007008:	c7d9                	beqz	a5,80007096 <virtio_disk_init+0x124>
  if(max < NUM)
    8000700a:	471d                	li	a4,7
    8000700c:	08f77d63          	bgeu	a4,a5,800070a6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80007010:	100014b7          	lui	s1,0x10001
    80007014:	47a1                	li	a5,8
    80007016:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80007018:	6609                	lui	a2,0x2
    8000701a:	4581                	li	a1,0
    8000701c:	00038517          	auipc	a0,0x38
    80007020:	fe450513          	addi	a0,a0,-28 # 8003f000 <disk>
    80007024:	ffffa097          	auipc	ra,0xffffa
    80007028:	cc0080e7          	jalr	-832(ra) # 80000ce4 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000702c:	00038717          	auipc	a4,0x38
    80007030:	fd470713          	addi	a4,a4,-44 # 8003f000 <disk>
    80007034:	00c75793          	srli	a5,a4,0xc
    80007038:	2781                	sext.w	a5,a5
    8000703a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000703c:	0003a797          	auipc	a5,0x3a
    80007040:	fc478793          	addi	a5,a5,-60 # 80041000 <disk+0x2000>
    80007044:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80007046:	00038717          	auipc	a4,0x38
    8000704a:	03a70713          	addi	a4,a4,58 # 8003f080 <disk+0x80>
    8000704e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80007050:	00039717          	auipc	a4,0x39
    80007054:	fb070713          	addi	a4,a4,-80 # 80040000 <disk+0x1000>
    80007058:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000705a:	4705                	li	a4,1
    8000705c:	00e78c23          	sb	a4,24(a5)
    80007060:	00e78ca3          	sb	a4,25(a5)
    80007064:	00e78d23          	sb	a4,26(a5)
    80007068:	00e78da3          	sb	a4,27(a5)
    8000706c:	00e78e23          	sb	a4,28(a5)
    80007070:	00e78ea3          	sb	a4,29(a5)
    80007074:	00e78f23          	sb	a4,30(a5)
    80007078:	00e78fa3          	sb	a4,31(a5)
}
    8000707c:	60e2                	ld	ra,24(sp)
    8000707e:	6442                	ld	s0,16(sp)
    80007080:	64a2                	ld	s1,8(sp)
    80007082:	6105                	addi	sp,sp,32
    80007084:	8082                	ret
    panic("could not find virtio disk");
    80007086:	00003517          	auipc	a0,0x3
    8000708a:	92250513          	addi	a0,a0,-1758 # 800099a8 <syscalls+0x388>
    8000708e:	ffff9097          	auipc	ra,0xffff9
    80007092:	4a0080e7          	jalr	1184(ra) # 8000052e <panic>
    panic("virtio disk has no queue 0");
    80007096:	00003517          	auipc	a0,0x3
    8000709a:	93250513          	addi	a0,a0,-1742 # 800099c8 <syscalls+0x3a8>
    8000709e:	ffff9097          	auipc	ra,0xffff9
    800070a2:	490080e7          	jalr	1168(ra) # 8000052e <panic>
    panic("virtio disk max queue too short");
    800070a6:	00003517          	auipc	a0,0x3
    800070aa:	94250513          	addi	a0,a0,-1726 # 800099e8 <syscalls+0x3c8>
    800070ae:	ffff9097          	auipc	ra,0xffff9
    800070b2:	480080e7          	jalr	1152(ra) # 8000052e <panic>

00000000800070b6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800070b6:	7119                	addi	sp,sp,-128
    800070b8:	fc86                	sd	ra,120(sp)
    800070ba:	f8a2                	sd	s0,112(sp)
    800070bc:	f4a6                	sd	s1,104(sp)
    800070be:	f0ca                	sd	s2,96(sp)
    800070c0:	ecce                	sd	s3,88(sp)
    800070c2:	e8d2                	sd	s4,80(sp)
    800070c4:	e4d6                	sd	s5,72(sp)
    800070c6:	e0da                	sd	s6,64(sp)
    800070c8:	fc5e                	sd	s7,56(sp)
    800070ca:	f862                	sd	s8,48(sp)
    800070cc:	f466                	sd	s9,40(sp)
    800070ce:	f06a                	sd	s10,32(sp)
    800070d0:	ec6e                	sd	s11,24(sp)
    800070d2:	0100                	addi	s0,sp,128
    800070d4:	8aaa                	mv	s5,a0
    800070d6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800070d8:	00c52c83          	lw	s9,12(a0)
    800070dc:	001c9c9b          	slliw	s9,s9,0x1
    800070e0:	1c82                	slli	s9,s9,0x20
    800070e2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800070e6:	0003a517          	auipc	a0,0x3a
    800070ea:	04250513          	addi	a0,a0,66 # 80041128 <disk+0x2128>
    800070ee:	ffffa097          	auipc	ra,0xffffa
    800070f2:	ad8080e7          	jalr	-1320(ra) # 80000bc6 <acquire>
  for(int i = 0; i < 3; i++){
    800070f6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800070f8:	44a1                	li	s1,8
      disk.free[i] = 0;
    800070fa:	00038c17          	auipc	s8,0x38
    800070fe:	f06c0c13          	addi	s8,s8,-250 # 8003f000 <disk>
    80007102:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80007104:	4b0d                	li	s6,3
    80007106:	a0ad                	j	80007170 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80007108:	00fc0733          	add	a4,s8,a5
    8000710c:	975e                	add	a4,a4,s7
    8000710e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80007112:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80007114:	0207c563          	bltz	a5,8000713e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80007118:	2905                	addiw	s2,s2,1
    8000711a:	0611                	addi	a2,a2,4
    8000711c:	19690d63          	beq	s2,s6,800072b6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80007120:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80007122:	0003a717          	auipc	a4,0x3a
    80007126:	ef670713          	addi	a4,a4,-266 # 80041018 <disk+0x2018>
    8000712a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000712c:	00074683          	lbu	a3,0(a4)
    80007130:	fee1                	bnez	a3,80007108 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80007132:	2785                	addiw	a5,a5,1
    80007134:	0705                	addi	a4,a4,1
    80007136:	fe979be3          	bne	a5,s1,8000712c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000713a:	57fd                	li	a5,-1
    8000713c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000713e:	01205d63          	blez	s2,80007158 <virtio_disk_rw+0xa2>
    80007142:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80007144:	000a2503          	lw	a0,0(s4)
    80007148:	00000097          	auipc	ra,0x0
    8000714c:	d8e080e7          	jalr	-626(ra) # 80006ed6 <free_desc>
      for(int j = 0; j < i; j++)
    80007150:	2d85                	addiw	s11,s11,1
    80007152:	0a11                	addi	s4,s4,4
    80007154:	ffb918e3          	bne	s2,s11,80007144 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80007158:	0003a597          	auipc	a1,0x3a
    8000715c:	fd058593          	addi	a1,a1,-48 # 80041128 <disk+0x2128>
    80007160:	0003a517          	auipc	a0,0x3a
    80007164:	eb850513          	addi	a0,a0,-328 # 80041018 <disk+0x2018>
    80007168:	ffffb097          	auipc	ra,0xffffb
    8000716c:	29c080e7          	jalr	668(ra) # 80002404 <sleep>
  for(int i = 0; i < 3; i++){
    80007170:	f8040a13          	addi	s4,s0,-128
{
    80007174:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80007176:	894e                	mv	s2,s3
    80007178:	b765                	j	80007120 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000717a:	0003a697          	auipc	a3,0x3a
    8000717e:	e866b683          	ld	a3,-378(a3) # 80041000 <disk+0x2000>
    80007182:	96ba                	add	a3,a3,a4
    80007184:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80007188:	00038817          	auipc	a6,0x38
    8000718c:	e7880813          	addi	a6,a6,-392 # 8003f000 <disk>
    80007190:	0003a697          	auipc	a3,0x3a
    80007194:	e7068693          	addi	a3,a3,-400 # 80041000 <disk+0x2000>
    80007198:	6290                	ld	a2,0(a3)
    8000719a:	963a                	add	a2,a2,a4
    8000719c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800071a0:	0015e593          	ori	a1,a1,1
    800071a4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800071a8:	f8842603          	lw	a2,-120(s0)
    800071ac:	628c                	ld	a1,0(a3)
    800071ae:	972e                	add	a4,a4,a1
    800071b0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800071b4:	20050593          	addi	a1,a0,512
    800071b8:	0592                	slli	a1,a1,0x4
    800071ba:	95c2                	add	a1,a1,a6
    800071bc:	577d                	li	a4,-1
    800071be:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800071c2:	00461713          	slli	a4,a2,0x4
    800071c6:	6290                	ld	a2,0(a3)
    800071c8:	963a                	add	a2,a2,a4
    800071ca:	03078793          	addi	a5,a5,48
    800071ce:	97c2                	add	a5,a5,a6
    800071d0:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800071d2:	629c                	ld	a5,0(a3)
    800071d4:	97ba                	add	a5,a5,a4
    800071d6:	4605                	li	a2,1
    800071d8:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800071da:	629c                	ld	a5,0(a3)
    800071dc:	97ba                	add	a5,a5,a4
    800071de:	4809                	li	a6,2
    800071e0:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800071e4:	629c                	ld	a5,0(a3)
    800071e6:	973e                	add	a4,a4,a5
    800071e8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800071ec:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800071f0:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800071f4:	6698                	ld	a4,8(a3)
    800071f6:	00275783          	lhu	a5,2(a4)
    800071fa:	8b9d                	andi	a5,a5,7
    800071fc:	0786                	slli	a5,a5,0x1
    800071fe:	97ba                	add	a5,a5,a4
    80007200:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80007204:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80007208:	6698                	ld	a4,8(a3)
    8000720a:	00275783          	lhu	a5,2(a4)
    8000720e:	2785                	addiw	a5,a5,1
    80007210:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80007214:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80007218:	100017b7          	lui	a5,0x10001
    8000721c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80007220:	004aa783          	lw	a5,4(s5)
    80007224:	02c79163          	bne	a5,a2,80007246 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80007228:	0003a917          	auipc	s2,0x3a
    8000722c:	f0090913          	addi	s2,s2,-256 # 80041128 <disk+0x2128>
  while(b->disk == 1) {
    80007230:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80007232:	85ca                	mv	a1,s2
    80007234:	8556                	mv	a0,s5
    80007236:	ffffb097          	auipc	ra,0xffffb
    8000723a:	1ce080e7          	jalr	462(ra) # 80002404 <sleep>
  while(b->disk == 1) {
    8000723e:	004aa783          	lw	a5,4(s5)
    80007242:	fe9788e3          	beq	a5,s1,80007232 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80007246:	f8042903          	lw	s2,-128(s0)
    8000724a:	20090793          	addi	a5,s2,512
    8000724e:	00479713          	slli	a4,a5,0x4
    80007252:	00038797          	auipc	a5,0x38
    80007256:	dae78793          	addi	a5,a5,-594 # 8003f000 <disk>
    8000725a:	97ba                	add	a5,a5,a4
    8000725c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80007260:	0003a997          	auipc	s3,0x3a
    80007264:	da098993          	addi	s3,s3,-608 # 80041000 <disk+0x2000>
    80007268:	00491713          	slli	a4,s2,0x4
    8000726c:	0009b783          	ld	a5,0(s3)
    80007270:	97ba                	add	a5,a5,a4
    80007272:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80007276:	854a                	mv	a0,s2
    80007278:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000727c:	00000097          	auipc	ra,0x0
    80007280:	c5a080e7          	jalr	-934(ra) # 80006ed6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80007284:	8885                	andi	s1,s1,1
    80007286:	f0ed                	bnez	s1,80007268 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80007288:	0003a517          	auipc	a0,0x3a
    8000728c:	ea050513          	addi	a0,a0,-352 # 80041128 <disk+0x2128>
    80007290:	ffffa097          	auipc	ra,0xffffa
    80007294:	a0c080e7          	jalr	-1524(ra) # 80000c9c <release>
}
    80007298:	70e6                	ld	ra,120(sp)
    8000729a:	7446                	ld	s0,112(sp)
    8000729c:	74a6                	ld	s1,104(sp)
    8000729e:	7906                	ld	s2,96(sp)
    800072a0:	69e6                	ld	s3,88(sp)
    800072a2:	6a46                	ld	s4,80(sp)
    800072a4:	6aa6                	ld	s5,72(sp)
    800072a6:	6b06                	ld	s6,64(sp)
    800072a8:	7be2                	ld	s7,56(sp)
    800072aa:	7c42                	ld	s8,48(sp)
    800072ac:	7ca2                	ld	s9,40(sp)
    800072ae:	7d02                	ld	s10,32(sp)
    800072b0:	6de2                	ld	s11,24(sp)
    800072b2:	6109                	addi	sp,sp,128
    800072b4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800072b6:	f8042503          	lw	a0,-128(s0)
    800072ba:	20050793          	addi	a5,a0,512
    800072be:	0792                	slli	a5,a5,0x4
  if(write)
    800072c0:	00038817          	auipc	a6,0x38
    800072c4:	d4080813          	addi	a6,a6,-704 # 8003f000 <disk>
    800072c8:	00f80733          	add	a4,a6,a5
    800072cc:	01a036b3          	snez	a3,s10
    800072d0:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800072d4:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800072d8:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800072dc:	7679                	lui	a2,0xffffe
    800072de:	963e                	add	a2,a2,a5
    800072e0:	0003a697          	auipc	a3,0x3a
    800072e4:	d2068693          	addi	a3,a3,-736 # 80041000 <disk+0x2000>
    800072e8:	6298                	ld	a4,0(a3)
    800072ea:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800072ec:	0a878593          	addi	a1,a5,168
    800072f0:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    800072f2:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800072f4:	6298                	ld	a4,0(a3)
    800072f6:	9732                	add	a4,a4,a2
    800072f8:	45c1                	li	a1,16
    800072fa:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800072fc:	6298                	ld	a4,0(a3)
    800072fe:	9732                	add	a4,a4,a2
    80007300:	4585                	li	a1,1
    80007302:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007306:	f8442703          	lw	a4,-124(s0)
    8000730a:	628c                	ld	a1,0(a3)
    8000730c:	962e                	add	a2,a2,a1
    8000730e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffbc00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80007312:	0712                	slli	a4,a4,0x4
    80007314:	6290                	ld	a2,0(a3)
    80007316:	963a                	add	a2,a2,a4
    80007318:	058a8593          	addi	a1,s5,88
    8000731c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000731e:	6294                	ld	a3,0(a3)
    80007320:	96ba                	add	a3,a3,a4
    80007322:	40000613          	li	a2,1024
    80007326:	c690                	sw	a2,8(a3)
  if(write)
    80007328:	e40d19e3          	bnez	s10,8000717a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000732c:	0003a697          	auipc	a3,0x3a
    80007330:	cd46b683          	ld	a3,-812(a3) # 80041000 <disk+0x2000>
    80007334:	96ba                	add	a3,a3,a4
    80007336:	4609                	li	a2,2
    80007338:	00c69623          	sh	a2,12(a3)
    8000733c:	b5b1                	j	80007188 <virtio_disk_rw+0xd2>

000000008000733e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000733e:	1101                	addi	sp,sp,-32
    80007340:	ec06                	sd	ra,24(sp)
    80007342:	e822                	sd	s0,16(sp)
    80007344:	e426                	sd	s1,8(sp)
    80007346:	e04a                	sd	s2,0(sp)
    80007348:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000734a:	0003a517          	auipc	a0,0x3a
    8000734e:	dde50513          	addi	a0,a0,-546 # 80041128 <disk+0x2128>
    80007352:	ffffa097          	auipc	ra,0xffffa
    80007356:	874080e7          	jalr	-1932(ra) # 80000bc6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000735a:	10001737          	lui	a4,0x10001
    8000735e:	533c                	lw	a5,96(a4)
    80007360:	8b8d                	andi	a5,a5,3
    80007362:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80007364:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80007368:	0003a797          	auipc	a5,0x3a
    8000736c:	c9878793          	addi	a5,a5,-872 # 80041000 <disk+0x2000>
    80007370:	6b94                	ld	a3,16(a5)
    80007372:	0207d703          	lhu	a4,32(a5)
    80007376:	0026d783          	lhu	a5,2(a3)
    8000737a:	06f70163          	beq	a4,a5,800073dc <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000737e:	00038917          	auipc	s2,0x38
    80007382:	c8290913          	addi	s2,s2,-894 # 8003f000 <disk>
    80007386:	0003a497          	auipc	s1,0x3a
    8000738a:	c7a48493          	addi	s1,s1,-902 # 80041000 <disk+0x2000>
    __sync_synchronize();
    8000738e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007392:	6898                	ld	a4,16(s1)
    80007394:	0204d783          	lhu	a5,32(s1)
    80007398:	8b9d                	andi	a5,a5,7
    8000739a:	078e                	slli	a5,a5,0x3
    8000739c:	97ba                	add	a5,a5,a4
    8000739e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800073a0:	20078713          	addi	a4,a5,512
    800073a4:	0712                	slli	a4,a4,0x4
    800073a6:	974a                	add	a4,a4,s2
    800073a8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800073ac:	e731                	bnez	a4,800073f8 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800073ae:	20078793          	addi	a5,a5,512
    800073b2:	0792                	slli	a5,a5,0x4
    800073b4:	97ca                	add	a5,a5,s2
    800073b6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800073b8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800073bc:	ffffb097          	auipc	ra,0xffffb
    800073c0:	20a080e7          	jalr	522(ra) # 800025c6 <wakeup>

    disk.used_idx += 1;
    800073c4:	0204d783          	lhu	a5,32(s1)
    800073c8:	2785                	addiw	a5,a5,1
    800073ca:	17c2                	slli	a5,a5,0x30
    800073cc:	93c1                	srli	a5,a5,0x30
    800073ce:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800073d2:	6898                	ld	a4,16(s1)
    800073d4:	00275703          	lhu	a4,2(a4)
    800073d8:	faf71be3          	bne	a4,a5,8000738e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800073dc:	0003a517          	auipc	a0,0x3a
    800073e0:	d4c50513          	addi	a0,a0,-692 # 80041128 <disk+0x2128>
    800073e4:	ffffa097          	auipc	ra,0xffffa
    800073e8:	8b8080e7          	jalr	-1864(ra) # 80000c9c <release>
}
    800073ec:	60e2                	ld	ra,24(sp)
    800073ee:	6442                	ld	s0,16(sp)
    800073f0:	64a2                	ld	s1,8(sp)
    800073f2:	6902                	ld	s2,0(sp)
    800073f4:	6105                	addi	sp,sp,32
    800073f6:	8082                	ret
      panic("virtio_disk_intr status");
    800073f8:	00002517          	auipc	a0,0x2
    800073fc:	61050513          	addi	a0,a0,1552 # 80009a08 <syscalls+0x3e8>
    80007400:	ffff9097          	auipc	ra,0xffff9
    80007404:	12e080e7          	jalr	302(ra) # 8000052e <panic>

0000000080007408 <call_sigret>:
    80007408:	48e1                	li	a7,24
    8000740a:	00000073          	ecall
    8000740e:	8082                	ret

0000000080007410 <end_sigret>:
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
