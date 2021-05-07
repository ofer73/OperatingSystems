
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
    80000068:	dec78793          	addi	a5,a5,-532 # 80006e50 <timervec>
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
    80000122:	94a080e7          	jalr	-1718(ra) # 80002a68 <either_copyin>
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
    800001c8:	284080e7          	jalr	644(ra) # 80002448 <sleep>
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
    80000204:	812080e7          	jalr	-2030(ra) # 80002a12 <either_copyout>
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
    800002e6:	7dc080e7          	jalr	2012(ra) # 80002abe <procdump>
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
    8000043a:	1a6080e7          	jalr	422(ra) # 800025dc <wakeup>
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
    80000560:	d7450513          	addi	a0,a0,-652 # 800092d0 <digits+0x290>
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
    80000886:	d5a080e7          	jalr	-678(ra) # 800025dc <wakeup>
    
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
    80000912:	b3a080e7          	jalr	-1222(ra) # 80002448 <sleep>
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
    80000edc:	420080e7          	jalr	1056(ra) # 800032f8 <trapinithart>

    plicinithart();   // ask PLIC for device interrupts
    80000ee0:	00006097          	auipc	ra,0x6
    80000ee4:	fb0080e7          	jalr	-80(ra) # 80006e90 <plicinithart>
  }

  scheduler();        
    80000ee8:	00001097          	auipc	ra,0x1
    80000eec:	2f6080e7          	jalr	758(ra) # 800021de <scheduler>
    consoleinit();
    80000ef0:	fffff097          	auipc	ra,0xfffff
    80000ef4:	550080e7          	jalr	1360(ra) # 80000440 <consoleinit>
    printfinit();
    80000ef8:	00000097          	auipc	ra,0x0
    80000efc:	860080e7          	jalr	-1952(ra) # 80000758 <printfinit>
    printf("\n");
    80000f00:	00008517          	auipc	a0,0x8
    80000f04:	3d050513          	addi	a0,a0,976 # 800092d0 <digits+0x290>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	670080e7          	jalr	1648(ra) # 80000578 <printf>
    printf("xv6 kernel is booting\n");
    80000f10:	00008517          	auipc	a0,0x8
    80000f14:	1c850513          	addi	a0,a0,456 # 800090d8 <digits+0x98>
    80000f18:	fffff097          	auipc	ra,0xfffff
    80000f1c:	660080e7          	jalr	1632(ra) # 80000578 <printf>
    printf("\n");
    80000f20:	00008517          	auipc	a0,0x8
    80000f24:	3b050513          	addi	a0,a0,944 # 800092d0 <digits+0x290>
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
    80000f54:	380080e7          	jalr	896(ra) # 800032d0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	3a0080e7          	jalr	928(ra) # 800032f8 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f60:	00006097          	auipc	ra,0x6
    80000f64:	f1a080e7          	jalr	-230(ra) # 80006e7a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f68:	00006097          	auipc	ra,0x6
    80000f6c:	f28080e7          	jalr	-216(ra) # 80006e90 <plicinithart>
    binit();         // buffer cache
    80000f70:	00003097          	auipc	ra,0x3
    80000f74:	052080e7          	jalr	82(ra) # 80003fc2 <binit>
    iinit();         // inode cache
    80000f78:	00003097          	auipc	ra,0x3
    80000f7c:	6e4080e7          	jalr	1764(ra) # 8000465c <iinit>
    fileinit();      // file table
    80000f80:	00004097          	auipc	ra,0x4
    80000f84:	690080e7          	jalr	1680(ra) # 80005610 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f88:	00006097          	auipc	ra,0x6
    80000f8c:	02a080e7          	jalr	42(ra) # 80006fb2 <virtio_disk_init>
    userinit();      // first user process
    80000f90:	00001097          	auipc	ra,0x1
    80000f94:	f5c080e7          	jalr	-164(ra) # 80001eec <userinit>
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
    80001b18:	f2c7a783          	lw	a5,-212(a5) # 80009a40 <first.1>
    80001b1c:	eb89                	bnez	a5,80001b2e <forkret+0x32>
    fsinit(ROOTDEV);
  }
  // printf("ffret%d\n",myproc()->pid);//TODO delete


  usertrapret();
    80001b1e:	00002097          	auipc	ra,0x2
    80001b22:	aac080e7          	jalr	-1364(ra) # 800035ca <usertrapret>
}
    80001b26:	60a2                	ld	ra,8(sp)
    80001b28:	6402                	ld	s0,0(sp)
    80001b2a:	0141                	addi	sp,sp,16
    80001b2c:	8082                	ret
    first = 0;
    80001b2e:	00008797          	auipc	a5,0x8
    80001b32:	f007a923          	sw	zero,-238(a5) # 80009a40 <first.1>
    fsinit(ROOTDEV);
    80001b36:	4505                	li	a0,1
    80001b38:	00003097          	auipc	ra,0x3
    80001b3c:	aa4080e7          	jalr	-1372(ra) # 800045dc <fsinit>
    80001b40:	bff9                	j	80001b1e <forkret+0x22>

0000000080001b42 <allocpid>:
allocpid() {
    80001b42:	1101                	addi	sp,sp,-32
    80001b44:	ec06                	sd	ra,24(sp)
    80001b46:	e822                	sd	s0,16(sp)
    80001b48:	e426                	sd	s1,8(sp)
    80001b4a:	e04a                	sd	s2,0(sp)
    80001b4c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b4e:	00010917          	auipc	s2,0x10
    80001b52:	75290913          	addi	s2,s2,1874 # 800122a0 <pid_lock>
    80001b56:	854a                	mv	a0,s2
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	06e080e7          	jalr	110(ra) # 80000bc6 <acquire>
  pid = nextpid;
    80001b60:	00008797          	auipc	a5,0x8
    80001b64:	ee878793          	addi	a5,a5,-280 # 80009a48 <nextpid>
    80001b68:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b6a:	0014871b          	addiw	a4,s1,1
    80001b6e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b70:	854a                	mv	a0,s2
    80001b72:	fffff097          	auipc	ra,0xfffff
    80001b76:	12a080e7          	jalr	298(ra) # 80000c9c <release>
}
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	60e2                	ld	ra,24(sp)
    80001b7e:	6442                	ld	s0,16(sp)
    80001b80:	64a2                	ld	s1,8(sp)
    80001b82:	6902                	ld	s2,0(sp)
    80001b84:	6105                	addi	sp,sp,32
    80001b86:	8082                	ret

0000000080001b88 <alloctid>:
alloctid() {
    80001b88:	1101                	addi	sp,sp,-32
    80001b8a:	ec06                	sd	ra,24(sp)
    80001b8c:	e822                	sd	s0,16(sp)
    80001b8e:	e426                	sd	s1,8(sp)
    80001b90:	e04a                	sd	s2,0(sp)
    80001b92:	1000                	addi	s0,sp,32
  acquire(&tid_lock);
    80001b94:	00010917          	auipc	s2,0x10
    80001b98:	72490913          	addi	s2,s2,1828 # 800122b8 <tid_lock>
    80001b9c:	854a                	mv	a0,s2
    80001b9e:	fffff097          	auipc	ra,0xfffff
    80001ba2:	028080e7          	jalr	40(ra) # 80000bc6 <acquire>
  tid = nexttid;
    80001ba6:	00008797          	auipc	a5,0x8
    80001baa:	e9e78793          	addi	a5,a5,-354 # 80009a44 <nexttid>
    80001bae:	4384                	lw	s1,0(a5)
  nexttid = nexttid + 1;
    80001bb0:	0014871b          	addiw	a4,s1,1
    80001bb4:	c398                	sw	a4,0(a5)
  release(&tid_lock);
    80001bb6:	854a                	mv	a0,s2
    80001bb8:	fffff097          	auipc	ra,0xfffff
    80001bbc:	0e4080e7          	jalr	228(ra) # 80000c9c <release>
}
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	60e2                	ld	ra,24(sp)
    80001bc4:	6442                	ld	s0,16(sp)
    80001bc6:	64a2                	ld	s1,8(sp)
    80001bc8:	6902                	ld	s2,0(sp)
    80001bca:	6105                	addi	sp,sp,32
    80001bcc:	8082                	ret

0000000080001bce <init_thread>:
init_thread(struct kthread *t){
    80001bce:	1101                	addi	sp,sp,-32
    80001bd0:	ec06                	sd	ra,24(sp)
    80001bd2:	e822                	sd	s0,16(sp)
    80001bd4:	e426                	sd	s1,8(sp)
    80001bd6:	1000                	addi	s0,sp,32
    80001bd8:	84aa                	mv	s1,a0
  t->state = TUSED;
    80001bda:	4785                	li	a5,1
    80001bdc:	cd1c                	sw	a5,24(a0)
  t->tid = alloctid();  
    80001bde:	00000097          	auipc	ra,0x0
    80001be2:	faa080e7          	jalr	-86(ra) # 80001b88 <alloctid>
    80001be6:	d888                	sw	a0,48(s1)
  memset(&(t->context), 0, sizeof(t->context));
    80001be8:	07000613          	li	a2,112
    80001bec:	4581                	li	a1,0
    80001bee:	04848513          	addi	a0,s1,72
    80001bf2:	fffff097          	auipc	ra,0xfffff
    80001bf6:	0f2080e7          	jalr	242(ra) # 80000ce4 <memset>
  t->context.ra = (uint64)forkret;
    80001bfa:	00000797          	auipc	a5,0x0
    80001bfe:	f0278793          	addi	a5,a5,-254 # 80001afc <forkret>
    80001c02:	e4bc                	sd	a5,72(s1)
  t->context.sp = t->kstack + PGSIZE;
    80001c04:	7c9c                	ld	a5,56(s1)
    80001c06:	6705                	lui	a4,0x1
    80001c08:	97ba                	add	a5,a5,a4
    80001c0a:	e8bc                	sd	a5,80(s1)
}
    80001c0c:	4501                	li	a0,0
    80001c0e:	60e2                	ld	ra,24(sp)
    80001c10:	6442                	ld	s0,16(sp)
    80001c12:	64a2                	ld	s1,8(sp)
    80001c14:	6105                	addi	sp,sp,32
    80001c16:	8082                	ret

0000000080001c18 <proc_pagetable>:
{
    80001c18:	1101                	addi	sp,sp,-32
    80001c1a:	ec06                	sd	ra,24(sp)
    80001c1c:	e822                	sd	s0,16(sp)
    80001c1e:	e426                	sd	s1,8(sp)
    80001c20:	e04a                	sd	s2,0(sp)
    80001c22:	1000                	addi	s0,sp,32
    80001c24:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c26:	fffff097          	auipc	ra,0xfffff
    80001c2a:	706080e7          	jalr	1798(ra) # 8000132c <uvmcreate>
    80001c2e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c30:	c121                	beqz	a0,80001c70 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c32:	4729                	li	a4,10
    80001c34:	00006697          	auipc	a3,0x6
    80001c38:	3cc68693          	addi	a3,a3,972 # 80008000 <_trampoline>
    80001c3c:	6605                	lui	a2,0x1
    80001c3e:	040005b7          	lui	a1,0x4000
    80001c42:	15fd                	addi	a1,a1,-1
    80001c44:	05b2                	slli	a1,a1,0xc
    80001c46:	fffff097          	auipc	ra,0xfffff
    80001c4a:	46e080e7          	jalr	1134(ra) # 800010b4 <mappages>
    80001c4e:	02054863          	bltz	a0,80001c7e <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c52:	4719                	li	a4,6
    80001c54:	04893683          	ld	a3,72(s2)
    80001c58:	6605                	lui	a2,0x1
    80001c5a:	020005b7          	lui	a1,0x2000
    80001c5e:	15fd                	addi	a1,a1,-1
    80001c60:	05b6                	slli	a1,a1,0xd
    80001c62:	8526                	mv	a0,s1
    80001c64:	fffff097          	auipc	ra,0xfffff
    80001c68:	450080e7          	jalr	1104(ra) # 800010b4 <mappages>
    80001c6c:	02054163          	bltz	a0,80001c8e <proc_pagetable+0x76>
}
    80001c70:	8526                	mv	a0,s1
    80001c72:	60e2                	ld	ra,24(sp)
    80001c74:	6442                	ld	s0,16(sp)
    80001c76:	64a2                	ld	s1,8(sp)
    80001c78:	6902                	ld	s2,0(sp)
    80001c7a:	6105                	addi	sp,sp,32
    80001c7c:	8082                	ret
    uvmfree(pagetable, 0);
    80001c7e:	4581                	li	a1,0
    80001c80:	8526                	mv	a0,s1
    80001c82:	00000097          	auipc	ra,0x0
    80001c86:	8a6080e7          	jalr	-1882(ra) # 80001528 <uvmfree>
    return 0;
    80001c8a:	4481                	li	s1,0
    80001c8c:	b7d5                	j	80001c70 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c8e:	4681                	li	a3,0
    80001c90:	4605                	li	a2,1
    80001c92:	040005b7          	lui	a1,0x4000
    80001c96:	15fd                	addi	a1,a1,-1
    80001c98:	05b2                	slli	a1,a1,0xc
    80001c9a:	8526                	mv	a0,s1
    80001c9c:	fffff097          	auipc	ra,0xfffff
    80001ca0:	5cc080e7          	jalr	1484(ra) # 80001268 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ca4:	4581                	li	a1,0
    80001ca6:	8526                	mv	a0,s1
    80001ca8:	00000097          	auipc	ra,0x0
    80001cac:	880080e7          	jalr	-1920(ra) # 80001528 <uvmfree>
    return 0;
    80001cb0:	4481                	li	s1,0
    80001cb2:	bf7d                	j	80001c70 <proc_pagetable+0x58>

0000000080001cb4 <proc_freepagetable>:
{
    80001cb4:	1101                	addi	sp,sp,-32
    80001cb6:	ec06                	sd	ra,24(sp)
    80001cb8:	e822                	sd	s0,16(sp)
    80001cba:	e426                	sd	s1,8(sp)
    80001cbc:	e04a                	sd	s2,0(sp)
    80001cbe:	1000                	addi	s0,sp,32
    80001cc0:	84aa                	mv	s1,a0
    80001cc2:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cc4:	4681                	li	a3,0
    80001cc6:	4605                	li	a2,1
    80001cc8:	040005b7          	lui	a1,0x4000
    80001ccc:	15fd                	addi	a1,a1,-1
    80001cce:	05b2                	slli	a1,a1,0xc
    80001cd0:	fffff097          	auipc	ra,0xfffff
    80001cd4:	598080e7          	jalr	1432(ra) # 80001268 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cd8:	4681                	li	a3,0
    80001cda:	4605                	li	a2,1
    80001cdc:	020005b7          	lui	a1,0x2000
    80001ce0:	15fd                	addi	a1,a1,-1
    80001ce2:	05b6                	slli	a1,a1,0xd
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	fffff097          	auipc	ra,0xfffff
    80001cea:	582080e7          	jalr	1410(ra) # 80001268 <uvmunmap>
  uvmfree(pagetable, sz);
    80001cee:	85ca                	mv	a1,s2
    80001cf0:	8526                	mv	a0,s1
    80001cf2:	00000097          	auipc	ra,0x0
    80001cf6:	836080e7          	jalr	-1994(ra) # 80001528 <uvmfree>
}
    80001cfa:	60e2                	ld	ra,24(sp)
    80001cfc:	6442                	ld	s0,16(sp)
    80001cfe:	64a2                	ld	s1,8(sp)
    80001d00:	6902                	ld	s2,0(sp)
    80001d02:	6105                	addi	sp,sp,32
    80001d04:	8082                	ret

0000000080001d06 <freeproc>:
{
    80001d06:	7179                	addi	sp,sp,-48
    80001d08:	f406                	sd	ra,40(sp)
    80001d0a:	f022                	sd	s0,32(sp)
    80001d0c:	ec26                	sd	s1,24(sp)
    80001d0e:	e84a                	sd	s2,16(sp)
    80001d10:	e44e                	sd	s3,8(sp)
    80001d12:	1800                	addi	s0,sp,48
    80001d14:	892a                	mv	s2,a0
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001d16:	28850493          	addi	s1,a0,648
    80001d1a:	6985                	lui	s3,0x1
    80001d1c:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80001d20:	99aa                	add	s3,s3,a0
    acquire(&t->lock);
    80001d22:	8526                	mv	a0,s1
    80001d24:	fffff097          	auipc	ra,0xfffff
    80001d28:	ea2080e7          	jalr	-350(ra) # 80000bc6 <acquire>
  t->tid = 0;
    80001d2c:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80001d30:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80001d34:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80001d38:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80001d3c:	0004ac23          	sw	zero,24(s1)
    release(&t->lock);
    80001d40:	8526                	mv	a0,s1
    80001d42:	fffff097          	auipc	ra,0xfffff
    80001d46:	f5a080e7          	jalr	-166(ra) # 80000c9c <release>
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001d4a:	0b848493          	addi	s1,s1,184
    80001d4e:	fc999ae3          	bne	s3,s1,80001d22 <freeproc+0x1c>
  p->user_trapframe_backup = 0;
    80001d52:	26093c23          	sd	zero,632(s2)
  if(p->pagetable)
    80001d56:	04093503          	ld	a0,64(s2)
    80001d5a:	c519                	beqz	a0,80001d68 <freeproc+0x62>
    proc_freepagetable(p->pagetable, p->sz);
    80001d5c:	03893583          	ld	a1,56(s2)
    80001d60:	00000097          	auipc	ra,0x0
    80001d64:	f54080e7          	jalr	-172(ra) # 80001cb4 <proc_freepagetable>
  p->pagetable = 0;
    80001d68:	04093023          	sd	zero,64(s2)
  p->sz = 0;
    80001d6c:	02093c23          	sd	zero,56(s2)
  p->pid = 0;
    80001d70:	02092223          	sw	zero,36(s2)
  p->parent = 0;
    80001d74:	02093823          	sd	zero,48(s2)
  p->name[0] = 0;
    80001d78:	0c090c23          	sb	zero,216(s2)
  p->killed = 0;
    80001d7c:	00092e23          	sw	zero,28(s2)
  p->xstate = 0;
    80001d80:	02092023          	sw	zero,32(s2)
  p->active_threads = 0;
    80001d84:	02092423          	sw	zero,40(s2)
  p->state = UNUSED;
    80001d88:	00092c23          	sw	zero,24(s2)
}
    80001d8c:	70a2                	ld	ra,40(sp)
    80001d8e:	7402                	ld	s0,32(sp)
    80001d90:	64e2                	ld	s1,24(sp)
    80001d92:	6942                	ld	s2,16(sp)
    80001d94:	69a2                	ld	s3,8(sp)
    80001d96:	6145                	addi	sp,sp,48
    80001d98:	8082                	ret

0000000080001d9a <allocproc>:
{
    80001d9a:	7179                	addi	sp,sp,-48
    80001d9c:	f406                	sd	ra,40(sp)
    80001d9e:	f022                	sd	s0,32(sp)
    80001da0:	ec26                	sd	s1,24(sp)
    80001da2:	e84a                	sd	s2,16(sp)
    80001da4:	e44e                	sd	s3,8(sp)
    80001da6:	e052                	sd	s4,0(sp)
    80001da8:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001daa:	00011497          	auipc	s1,0x11
    80001dae:	97e48493          	addi	s1,s1,-1666 # 80012728 <proc>
    80001db2:	6985                	lui	s3,0x1
    80001db4:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80001db8:	00032a17          	auipc	s4,0x32
    80001dbc:	b70a0a13          	addi	s4,s4,-1168 # 80033928 <tickslock>
    acquire(&p->lock);
    80001dc0:	8926                	mv	s2,s1
    80001dc2:	8526                	mv	a0,s1
    80001dc4:	fffff097          	auipc	ra,0xfffff
    80001dc8:	e02080e7          	jalr	-510(ra) # 80000bc6 <acquire>
    if(p->state == UNUSED) {
    80001dcc:	4c9c                	lw	a5,24(s1)
    80001dce:	cb99                	beqz	a5,80001de4 <allocproc+0x4a>
      release(&p->lock);
    80001dd0:	8526                	mv	a0,s1
    80001dd2:	fffff097          	auipc	ra,0xfffff
    80001dd6:	eca080e7          	jalr	-310(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dda:	94ce                	add	s1,s1,s3
    80001ddc:	ff4492e3          	bne	s1,s4,80001dc0 <allocproc+0x26>
  return 0;
    80001de0:	4481                	li	s1,0
    80001de2:	a845                	j	80001e92 <allocproc+0xf8>
  p->pid = allocpid();
    80001de4:	00000097          	auipc	ra,0x0
    80001de8:	d5e080e7          	jalr	-674(ra) # 80001b42 <allocpid>
    80001dec:	d0c8                	sw	a0,36(s1)
  p->state = USED;
    80001dee:	4785                	li	a5,1
    80001df0:	cc9c                	sw	a5,24(s1)
  if((p->threads_tf_start =kalloc()) == 0){
    80001df2:	fffff097          	auipc	ra,0xfffff
    80001df6:	ce4080e7          	jalr	-796(ra) # 80000ad6 <kalloc>
    80001dfa:	89aa                	mv	s3,a0
    80001dfc:	e4a8                	sd	a0,72(s1)
    80001dfe:	0f848713          	addi	a4,s1,248
    80001e02:	1f848793          	addi	a5,s1,504
    80001e06:	27848693          	addi	a3,s1,632
    80001e0a:	cd49                	beqz	a0,80001ea4 <allocproc+0x10a>
    p->signal_handlers[i] = SIG_DFL;
    80001e0c:	00073023          	sd	zero,0(a4) # 1000 <_entry-0x7ffff000>
    p->handlers_sigmasks[i] = 0;
    80001e10:	0007a023          	sw	zero,0(a5)
  for(int i=0;i<32;i++){
    80001e14:	0721                	addi	a4,a4,8
    80001e16:	0791                	addi	a5,a5,4
    80001e18:	fed79ae3          	bne	a5,a3,80001e0c <allocproc+0x72>
  p->signal_mask= 0;
    80001e1c:	0e04a623          	sw	zero,236(s1)
  p->pending_signals = 0;
    80001e20:	0e04a423          	sw	zero,232(s1)
  p->active_threads=1;
    80001e24:	4785                	li	a5,1
    80001e26:	d49c                	sw	a5,40(s1)
  p->signal_mask_backup = 0;
    80001e28:	0e04a823          	sw	zero,240(s1)
  p->handling_user_sig_flag = 0;
    80001e2c:	2804a023          	sw	zero,640(s1)
  p->handling_sig_flag=0;
    80001e30:	2804a223          	sw	zero,644(s1)
  p->pagetable = proc_pagetable(p);
    80001e34:	8526                	mv	a0,s1
    80001e36:	00000097          	auipc	ra,0x0
    80001e3a:	de2080e7          	jalr	-542(ra) # 80001c18 <proc_pagetable>
    80001e3e:	89aa                	mv	s3,a0
    80001e40:	e0a8                	sd	a0,64(s1)
  if(p->pagetable == 0){
    80001e42:	cd2d                	beqz	a0,80001ebc <allocproc+0x122>
    80001e44:	2a048793          	addi	a5,s1,672
    80001e48:	64b8                	ld	a4,72(s1)
    80001e4a:	6685                	lui	a3,0x1
    80001e4c:	86068693          	addi	a3,a3,-1952 # 860 <_entry-0x7ffff7a0>
    80001e50:	9936                	add	s2,s2,a3
    t->tid=-1;
    80001e52:	56fd                	li	a3,-1
    t->state=TUNUSED;
    80001e54:	0007a023          	sw	zero,0(a5)
    t->chan=0;
    80001e58:	0007b423          	sd	zero,8(a5)
    t->tid=-1;
    80001e5c:	cf94                	sw	a3,24(a5)
    t->trapframe = (struct trapframe *)p->threads_tf_start + i;     //TODO: check if good or maybe + i*sizeof(struct trapframe)
    80001e5e:	f798                	sd	a4,40(a5)
    t->killed = 0;
    80001e60:	0007a823          	sw	zero,16(a5)
    t->frozen = 0;
    80001e64:	0007ae23          	sw	zero,28(a5)
  for(int i=0;i<NTHREAD;i++){
    80001e68:	0b878793          	addi	a5,a5,184
    80001e6c:	12070713          	addi	a4,a4,288
    80001e70:	ff2792e3          	bne	a5,s2,80001e54 <allocproc+0xba>
  struct kthread *t= &p->kthreads[0];
    80001e74:	28848913          	addi	s2,s1,648
  acquire(&t->lock);
    80001e78:	854a                	mv	a0,s2
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	d4c080e7          	jalr	-692(ra) # 80000bc6 <acquire>
  if(init_thread(t) == -1){
    80001e82:	854a                	mv	a0,s2
    80001e84:	00000097          	auipc	ra,0x0
    80001e88:	d4a080e7          	jalr	-694(ra) # 80001bce <init_thread>
    80001e8c:	57fd                	li	a5,-1
    80001e8e:	04f50363          	beq	a0,a5,80001ed4 <allocproc+0x13a>
}
    80001e92:	8526                	mv	a0,s1
    80001e94:	70a2                	ld	ra,40(sp)
    80001e96:	7402                	ld	s0,32(sp)
    80001e98:	64e2                	ld	s1,24(sp)
    80001e9a:	6942                	ld	s2,16(sp)
    80001e9c:	69a2                	ld	s3,8(sp)
    80001e9e:	6a02                	ld	s4,0(sp)
    80001ea0:	6145                	addi	sp,sp,48
    80001ea2:	8082                	ret
    freeproc(p);
    80001ea4:	8526                	mv	a0,s1
    80001ea6:	00000097          	auipc	ra,0x0
    80001eaa:	e60080e7          	jalr	-416(ra) # 80001d06 <freeproc>
    release(&p->lock);
    80001eae:	8526                	mv	a0,s1
    80001eb0:	fffff097          	auipc	ra,0xfffff
    80001eb4:	dec080e7          	jalr	-532(ra) # 80000c9c <release>
    return 0;
    80001eb8:	84ce                	mv	s1,s3
    80001eba:	bfe1                	j	80001e92 <allocproc+0xf8>
    freeproc(p);
    80001ebc:	8526                	mv	a0,s1
    80001ebe:	00000097          	auipc	ra,0x0
    80001ec2:	e48080e7          	jalr	-440(ra) # 80001d06 <freeproc>
    release(&p->lock);
    80001ec6:	8526                	mv	a0,s1
    80001ec8:	fffff097          	auipc	ra,0xfffff
    80001ecc:	dd4080e7          	jalr	-556(ra) # 80000c9c <release>
    return 0;
    80001ed0:	84ce                	mv	s1,s3
    80001ed2:	b7c1                	j	80001e92 <allocproc+0xf8>
    freeproc(p);
    80001ed4:	8526                	mv	a0,s1
    80001ed6:	00000097          	auipc	ra,0x0
    80001eda:	e30080e7          	jalr	-464(ra) # 80001d06 <freeproc>
    release(&p->lock);  
    80001ede:	8526                	mv	a0,s1
    80001ee0:	fffff097          	auipc	ra,0xfffff
    80001ee4:	dbc080e7          	jalr	-580(ra) # 80000c9c <release>
    return 0;
    80001ee8:	4481                	li	s1,0
    80001eea:	b765                	j	80001e92 <allocproc+0xf8>

0000000080001eec <userinit>:
{
    80001eec:	1101                	addi	sp,sp,-32
    80001eee:	ec06                	sd	ra,24(sp)
    80001ef0:	e822                	sd	s0,16(sp)
    80001ef2:	e426                	sd	s1,8(sp)
    80001ef4:	1000                	addi	s0,sp,32
    80001ef6:	8792                	mv	a5,tp
  p = allocproc();
    80001ef8:	00000097          	auipc	ra,0x0
    80001efc:	ea2080e7          	jalr	-350(ra) # 80001d9a <allocproc>
    80001f00:	84aa                	mv	s1,a0
  initproc = p;
    80001f02:	00008797          	auipc	a5,0x8
    80001f06:	12a7b323          	sd	a0,294(a5) # 8000a028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001f0a:	03400613          	li	a2,52
    80001f0e:	00008597          	auipc	a1,0x8
    80001f12:	b4258593          	addi	a1,a1,-1214 # 80009a50 <initcode>
    80001f16:	6128                	ld	a0,64(a0)
    80001f18:	fffff097          	auipc	ra,0xfffff
    80001f1c:	442080e7          	jalr	1090(ra) # 8000135a <uvminit>
  p->sz = PGSIZE;
    80001f20:	6785                	lui	a5,0x1
    80001f22:	fc9c                	sd	a5,56(s1)
  t->trapframe->epc = 0;      // user program counter
    80001f24:	2c84b703          	ld	a4,712(s1)
    80001f28:	00073c23          	sd	zero,24(a4)
  t->trapframe->sp = PGSIZE;  // user stack pointer
    80001f2c:	2c84b703          	ld	a4,712(s1)
    80001f30:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f32:	4641                	li	a2,16
    80001f34:	00007597          	auipc	a1,0x7
    80001f38:	2fc58593          	addi	a1,a1,764 # 80009230 <digits+0x1f0>
    80001f3c:	0d848513          	addi	a0,s1,216
    80001f40:	fffff097          	auipc	ra,0xfffff
    80001f44:	ef6080e7          	jalr	-266(ra) # 80000e36 <safestrcpy>
  p->cwd = namei("/");
    80001f48:	00007517          	auipc	a0,0x7
    80001f4c:	2f850513          	addi	a0,a0,760 # 80009240 <digits+0x200>
    80001f50:	00003097          	auipc	ra,0x3
    80001f54:	0b8080e7          	jalr	184(ra) # 80005008 <namei>
    80001f58:	e8e8                	sd	a0,208(s1)
  p->state = RUNNABLE;
    80001f5a:	4789                	li	a5,2
    80001f5c:	cc9c                	sw	a5,24(s1)
  t->state = TRUNNABLE;
    80001f5e:	478d                	li	a5,3
    80001f60:	2af4a023          	sw	a5,672(s1)
  release(&p->lock);
    80001f64:	8526                	mv	a0,s1
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	d36080e7          	jalr	-714(ra) # 80000c9c <release>
  release(&p->kthreads[0].lock);////////////////////////////////////////////////////////////////check
    80001f6e:	28848513          	addi	a0,s1,648
    80001f72:	fffff097          	auipc	ra,0xfffff
    80001f76:	d2a080e7          	jalr	-726(ra) # 80000c9c <release>
}
    80001f7a:	60e2                	ld	ra,24(sp)
    80001f7c:	6442                	ld	s0,16(sp)
    80001f7e:	64a2                	ld	s1,8(sp)
    80001f80:	6105                	addi	sp,sp,32
    80001f82:	8082                	ret

0000000080001f84 <growproc>:
{
    80001f84:	1101                	addi	sp,sp,-32
    80001f86:	ec06                	sd	ra,24(sp)
    80001f88:	e822                	sd	s0,16(sp)
    80001f8a:	e426                	sd	s1,8(sp)
    80001f8c:	e04a                	sd	s2,0(sp)
    80001f8e:	1000                	addi	s0,sp,32
    80001f90:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f92:	00000097          	auipc	ra,0x0
    80001f96:	aea080e7          	jalr	-1302(ra) # 80001a7c <myproc>
    80001f9a:	892a                	mv	s2,a0
  sz = p->sz;
    80001f9c:	7d0c                	ld	a1,56(a0)
    80001f9e:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001fa2:	00904f63          	bgtz	s1,80001fc0 <growproc+0x3c>
  } else if(n < 0){
    80001fa6:	0204cc63          	bltz	s1,80001fde <growproc+0x5a>
  p->sz = sz;
    80001faa:	1602                	slli	a2,a2,0x20
    80001fac:	9201                	srli	a2,a2,0x20
    80001fae:	02c93c23          	sd	a2,56(s2)
  return 0;
    80001fb2:	4501                	li	a0,0
}
    80001fb4:	60e2                	ld	ra,24(sp)
    80001fb6:	6442                	ld	s0,16(sp)
    80001fb8:	64a2                	ld	s1,8(sp)
    80001fba:	6902                	ld	s2,0(sp)
    80001fbc:	6105                	addi	sp,sp,32
    80001fbe:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001fc0:	9e25                	addw	a2,a2,s1
    80001fc2:	1602                	slli	a2,a2,0x20
    80001fc4:	9201                	srli	a2,a2,0x20
    80001fc6:	1582                	slli	a1,a1,0x20
    80001fc8:	9181                	srli	a1,a1,0x20
    80001fca:	6128                	ld	a0,64(a0)
    80001fcc:	fffff097          	auipc	ra,0xfffff
    80001fd0:	448080e7          	jalr	1096(ra) # 80001414 <uvmalloc>
    80001fd4:	0005061b          	sext.w	a2,a0
    80001fd8:	fa69                	bnez	a2,80001faa <growproc+0x26>
      return -1;
    80001fda:	557d                	li	a0,-1
    80001fdc:	bfe1                	j	80001fb4 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001fde:	9e25                	addw	a2,a2,s1
    80001fe0:	1602                	slli	a2,a2,0x20
    80001fe2:	9201                	srli	a2,a2,0x20
    80001fe4:	1582                	slli	a1,a1,0x20
    80001fe6:	9181                	srli	a1,a1,0x20
    80001fe8:	6128                	ld	a0,64(a0)
    80001fea:	fffff097          	auipc	ra,0xfffff
    80001fee:	3e2080e7          	jalr	994(ra) # 800013cc <uvmdealloc>
    80001ff2:	0005061b          	sext.w	a2,a0
    80001ff6:	bf55                	j	80001faa <growproc+0x26>

0000000080001ff8 <fork>:
{
    80001ff8:	7139                	addi	sp,sp,-64
    80001ffa:	fc06                	sd	ra,56(sp)
    80001ffc:	f822                	sd	s0,48(sp)
    80001ffe:	f426                	sd	s1,40(sp)
    80002000:	f04a                	sd	s2,32(sp)
    80002002:	ec4e                	sd	s3,24(sp)
    80002004:	e852                	sd	s4,16(sp)
    80002006:	e456                	sd	s5,8(sp)
    80002008:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000200a:	00000097          	auipc	ra,0x0
    8000200e:	a72080e7          	jalr	-1422(ra) # 80001a7c <myproc>
    80002012:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    80002014:	00000097          	auipc	ra,0x0
    80002018:	aa8080e7          	jalr	-1368(ra) # 80001abc <mykthread>
    8000201c:	84aa                	mv	s1,a0
  if((np = allocproc()) == 0){//////////////////////////////////////////////////check  lock p and t
    8000201e:	00000097          	auipc	ra,0x0
    80002022:	d7c080e7          	jalr	-644(ra) # 80001d9a <allocproc>
    80002026:	1a050a63          	beqz	a0,800021da <fork+0x1e2>
    8000202a:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000202c:	0389b603          	ld	a2,56(s3)
    80002030:	612c                	ld	a1,64(a0)
    80002032:	0409b503          	ld	a0,64(s3)
    80002036:	fffff097          	auipc	ra,0xfffff
    8000203a:	52a080e7          	jalr	1322(ra) # 80001560 <uvmcopy>
    8000203e:	06054763          	bltz	a0,800020ac <fork+0xb4>
  np->sz = p->sz;
    80002042:	0389b783          	ld	a5,56(s3)
    80002046:	02f93c23          	sd	a5,56(s2)
  acquire(&wait_lock);/////////////////////////////////////////////////////////////////check
    8000204a:	00010517          	auipc	a0,0x10
    8000204e:	28650513          	addi	a0,a0,646 # 800122d0 <wait_lock>
    80002052:	fffff097          	auipc	ra,0xfffff
    80002056:	b74080e7          	jalr	-1164(ra) # 80000bc6 <acquire>
  *(np_first_thread->trapframe) = *(t->trapframe);
    8000205a:	60b4                	ld	a3,64(s1)
    8000205c:	87b6                	mv	a5,a3
    8000205e:	2c893703          	ld	a4,712(s2)
    80002062:	12068693          	addi	a3,a3,288
    80002066:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000206a:	6788                	ld	a0,8(a5)
    8000206c:	6b8c                	ld	a1,16(a5)
    8000206e:	6f90                	ld	a2,24(a5)
    80002070:	01073023          	sd	a6,0(a4)
    80002074:	e708                	sd	a0,8(a4)
    80002076:	eb0c                	sd	a1,16(a4)
    80002078:	ef10                	sd	a2,24(a4)
    8000207a:	02078793          	addi	a5,a5,32
    8000207e:	02070713          	addi	a4,a4,32
    80002082:	fed792e3          	bne	a5,a3,80002066 <fork+0x6e>
  np_first_thread->trapframe->a0 = 0;  // TODO: change reading the ret value from proc a0 to thread a0
    80002086:	2c893783          	ld	a5,712(s2)
    8000208a:	0607b823          	sd	zero,112(a5)
  release(&wait_lock);////////////////////////////////////////////////////////////////check
    8000208e:	00010517          	auipc	a0,0x10
    80002092:	24250513          	addi	a0,a0,578 # 800122d0 <wait_lock>
    80002096:	fffff097          	auipc	ra,0xfffff
    8000209a:	c06080e7          	jalr	-1018(ra) # 80000c9c <release>
  for(i = 0; i < NOFILE; i++)
    8000209e:	05098493          	addi	s1,s3,80
    800020a2:	05090a13          	addi	s4,s2,80
    800020a6:	0d098a93          	addi	s5,s3,208
    800020aa:	a00d                	j	800020cc <fork+0xd4>
    freeproc(np);
    800020ac:	854a                	mv	a0,s2
    800020ae:	00000097          	auipc	ra,0x0
    800020b2:	c58080e7          	jalr	-936(ra) # 80001d06 <freeproc>
    release(&np->lock);
    800020b6:	854a                	mv	a0,s2
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	be4080e7          	jalr	-1052(ra) # 80000c9c <release>
    return -1;
    800020c0:	5a7d                	li	s4,-1
    800020c2:	a211                	j	800021c6 <fork+0x1ce>
  for(i = 0; i < NOFILE; i++)
    800020c4:	04a1                	addi	s1,s1,8
    800020c6:	0a21                	addi	s4,s4,8
    800020c8:	01548b63          	beq	s1,s5,800020de <fork+0xe6>
    if(p->ofile[i])
    800020cc:	6088                	ld	a0,0(s1)
    800020ce:	d97d                	beqz	a0,800020c4 <fork+0xcc>
      np->ofile[i] = filedup(p->ofile[i]);
    800020d0:	00003097          	auipc	ra,0x3
    800020d4:	5d2080e7          	jalr	1490(ra) # 800056a2 <filedup>
    800020d8:	00aa3023          	sd	a0,0(s4)
    800020dc:	b7e5                	j	800020c4 <fork+0xcc>
  np->cwd = idup(p->cwd);
    800020de:	0d09b503          	ld	a0,208(s3)
    800020e2:	00002097          	auipc	ra,0x2
    800020e6:	734080e7          	jalr	1844(ra) # 80004816 <idup>
    800020ea:	0ca93823          	sd	a0,208(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020ee:	4641                	li	a2,16
    800020f0:	0d898593          	addi	a1,s3,216
    800020f4:	0d890513          	addi	a0,s2,216
    800020f8:	fffff097          	auipc	ra,0xfffff
    800020fc:	d3e080e7          	jalr	-706(ra) # 80000e36 <safestrcpy>
  np->signal_mask = p->signal_mask;
    80002100:	0ec9a783          	lw	a5,236(s3)
    80002104:	0ef92623          	sw	a5,236(s2)
  for(int i=0;i<32;i++){
    80002108:	0f898693          	addi	a3,s3,248
    8000210c:	0f890713          	addi	a4,s2,248
  np->signal_mask = p->signal_mask;
    80002110:	1f800793          	li	a5,504
  for(int i=0;i<32;i++){
    80002114:	27800513          	li	a0,632
    np->signal_handlers[i] = p->signal_handlers[i];
    80002118:	6290                	ld	a2,0(a3)
    8000211a:	e310                	sd	a2,0(a4)
    np->handlers_sigmasks[i] = p->handlers_sigmasks[i];
    8000211c:	00f98633          	add	a2,s3,a5
    80002120:	420c                	lw	a1,0(a2)
    80002122:	00f90633          	add	a2,s2,a5
    80002126:	c20c                	sw	a1,0(a2)
  for(int i=0;i<32;i++){
    80002128:	06a1                	addi	a3,a3,8
    8000212a:	0721                	addi	a4,a4,8
    8000212c:	0791                	addi	a5,a5,4
    8000212e:	fea795e3          	bne	a5,a0,80002118 <fork+0x120>
  np-> pending_signals=0;
    80002132:	0e092423          	sw	zero,232(s2)
  pid = np->pid;
    80002136:	02492a03          	lw	s4,36(s2)
  release(&np->lock);
    8000213a:	854a                	mv	a0,s2
    8000213c:	fffff097          	auipc	ra,0xfffff
    80002140:	b60080e7          	jalr	-1184(ra) # 80000c9c <release>
  acquire(&wait_lock);
    80002144:	00010497          	auipc	s1,0x10
    80002148:	18c48493          	addi	s1,s1,396 # 800122d0 <wait_lock>
    8000214c:	8526                	mv	a0,s1
    8000214e:	fffff097          	auipc	ra,0xfffff
    80002152:	a78080e7          	jalr	-1416(ra) # 80000bc6 <acquire>
  np->parent = p;
    80002156:	03393823          	sd	s3,48(s2)
  release(&wait_lock);
    8000215a:	8526                	mv	a0,s1
    8000215c:	fffff097          	auipc	ra,0xfffff
    80002160:	b40080e7          	jalr	-1216(ra) # 80000c9c <release>
  acquire(&np->lock);
    80002164:	854a                	mv	a0,s2
    80002166:	fffff097          	auipc	ra,0xfffff
    8000216a:	a60080e7          	jalr	-1440(ra) # 80000bc6 <acquire>
  int proc_index= (int)(np-proc);//TODO delete
    8000216e:	00010797          	auipc	a5,0x10
    80002172:	5ba78793          	addi	a5,a5,1466 # 80012728 <proc>
    80002176:	40f90633          	sub	a2,s2,a5
    8000217a:	860d                	srai	a2,a2,0x3
    8000217c:	00007597          	auipc	a1,0x7
    80002180:	e845b583          	ld	a1,-380(a1) # 80009000 <etext>
  int my_proc_index= (int)(p-proc);// TODO delete
    80002184:	40f989b3          	sub	s3,s3,a5
    80002188:	4039d993          	srai	s3,s3,0x3
  printf("%d:at fork idx%d->runable\n",my_proc_index,proc_index);//TODO delete
    8000218c:	02b6063b          	mulw	a2,a2,a1
    80002190:	02b985bb          	mulw	a1,s3,a1
    80002194:	00007517          	auipc	a0,0x7
    80002198:	0b450513          	addi	a0,a0,180 # 80009248 <digits+0x208>
    8000219c:	ffffe097          	auipc	ra,0xffffe
    800021a0:	3dc080e7          	jalr	988(ra) # 80000578 <printf>
  np->state = RUNNABLE;   //TOOD: check if we still need this state or should change
    800021a4:	4789                	li	a5,2
    800021a6:	00f92c23          	sw	a5,24(s2)
  np_first_thread->state = TRUNNABLE;
    800021aa:	478d                	li	a5,3
    800021ac:	2af92023          	sw	a5,672(s2)
  release(&np_first_thread->lock);
    800021b0:	28890513          	addi	a0,s2,648
    800021b4:	fffff097          	auipc	ra,0xfffff
    800021b8:	ae8080e7          	jalr	-1304(ra) # 80000c9c <release>
  release(&np->lock);
    800021bc:	854a                	mv	a0,s2
    800021be:	fffff097          	auipc	ra,0xfffff
    800021c2:	ade080e7          	jalr	-1314(ra) # 80000c9c <release>
}
    800021c6:	8552                	mv	a0,s4
    800021c8:	70e2                	ld	ra,56(sp)
    800021ca:	7442                	ld	s0,48(sp)
    800021cc:	74a2                	ld	s1,40(sp)
    800021ce:	7902                	ld	s2,32(sp)
    800021d0:	69e2                	ld	s3,24(sp)
    800021d2:	6a42                	ld	s4,16(sp)
    800021d4:	6aa2                	ld	s5,8(sp)
    800021d6:	6121                	addi	sp,sp,64
    800021d8:	8082                	ret
    return -1;
    800021da:	5a7d                	li	s4,-1
    800021dc:	b7ed                	j	800021c6 <fork+0x1ce>

00000000800021de <scheduler>:
{
    800021de:	711d                	addi	sp,sp,-96
    800021e0:	ec86                	sd	ra,88(sp)
    800021e2:	e8a2                	sd	s0,80(sp)
    800021e4:	e4a6                	sd	s1,72(sp)
    800021e6:	e0ca                	sd	s2,64(sp)
    800021e8:	fc4e                	sd	s3,56(sp)
    800021ea:	f852                	sd	s4,48(sp)
    800021ec:	f456                	sd	s5,40(sp)
    800021ee:	f05a                	sd	s6,32(sp)
    800021f0:	ec5e                	sd	s7,24(sp)
    800021f2:	e862                	sd	s8,16(sp)
    800021f4:	e466                	sd	s9,8(sp)
    800021f6:	e06a                	sd	s10,0(sp)
    800021f8:	1080                	addi	s0,sp,96
    800021fa:	8792                	mv	a5,tp
  int id = r_tp();
    800021fc:	2781                	sext.w	a5,a5
  c->proc = 0;
    800021fe:	00479713          	slli	a4,a5,0x4
    80002202:	00f706b3          	add	a3,a4,a5
    80002206:	00369613          	slli	a2,a3,0x3
    8000220a:	00010697          	auipc	a3,0x10
    8000220e:	09668693          	addi	a3,a3,150 # 800122a0 <pid_lock>
    80002212:	96b2                	add	a3,a3,a2
    80002214:	0406b423          	sd	zero,72(a3)
  c->kthread=0;
    80002218:	0c06b423          	sd	zero,200(a3)
            swtch(&c->context, &t->context);
    8000221c:	00010717          	auipc	a4,0x10
    80002220:	0d470713          	addi	a4,a4,212 # 800122f0 <cpus+0x8>
    80002224:	00e60bb3          	add	s7,a2,a4
            c->proc = p;
    80002228:	8b36                	mv	s6,a3
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    8000222a:	6a85                	lui	s5,0x1
    8000222c:	848a8a93          	addi	s5,s5,-1976 # 848 <_entry-0x7ffff7b8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002230:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002234:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002238:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000223c:	00010917          	auipc	s2,0x10
    80002240:	4ec90913          	addi	s2,s2,1260 # 80012728 <proc>
    80002244:	a09d                	j	800022aa <scheduler+0xcc>
          release(&t->lock);
    80002246:	8526                	mv	a0,s1
    80002248:	fffff097          	auipc	ra,0xfffff
    8000224c:	a54080e7          	jalr	-1452(ra) # 80000c9c <release>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002250:	0b848493          	addi	s1,s1,184
    80002254:	05348463          	beq	s1,s3,8000229c <scheduler+0xbe>
          acquire(&t->lock);
    80002258:	8526                	mv	a0,s1
    8000225a:	fffff097          	auipc	ra,0xfffff
    8000225e:	96c080e7          	jalr	-1684(ra) # 80000bc6 <acquire>
          if(t->state == TRUNNABLE && !t->frozen) {
    80002262:	4c9c                	lw	a5,24(s1)
    80002264:	ff4791e3          	bne	a5,s4,80002246 <scheduler+0x68>
    80002268:	58dc                	lw	a5,52(s1)
    8000226a:	fff1                	bnez	a5,80002246 <scheduler+0x68>
            printf("%d\n",proc_index);
    8000226c:	85e6                	mv	a1,s9
    8000226e:	856a                	mv	a0,s10
    80002270:	ffffe097          	auipc	ra,0xffffe
    80002274:	308080e7          	jalr	776(ra) # 80000578 <printf>
            t->state = TRUNNING;
    80002278:	4791                	li	a5,4
    8000227a:	cc9c                	sw	a5,24(s1)
            c->proc = p;
    8000227c:	052b3423          	sd	s2,72(s6)
            c->kthread = t;
    80002280:	0c9b3423          	sd	s1,200(s6)
            swtch(&c->context, &t->context);
    80002284:	04848593          	addi	a1,s1,72
    80002288:	855e                	mv	a0,s7
    8000228a:	00001097          	auipc	ra,0x1
    8000228e:	fdc080e7          	jalr	-36(ra) # 80003266 <swtch>
            c->proc = 0;
    80002292:	040b3423          	sd	zero,72(s6)
            c->kthread=0;
    80002296:	0c0b3423          	sd	zero,200(s6)
    8000229a:	b775                	j	80002246 <scheduler+0x68>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000229c:	9956                	add	s2,s2,s5
    8000229e:	00031797          	auipc	a5,0x31
    800022a2:	68a78793          	addi	a5,a5,1674 # 80033928 <tickslock>
    800022a6:	f8f905e3          	beq	s2,a5,80002230 <scheduler+0x52>
      if(p->state == RUNNABLE) {
    800022aa:	01892703          	lw	a4,24(s2)
    800022ae:	4789                	li	a5,2
    800022b0:	fef716e3          	bne	a4,a5,8000229c <scheduler+0xbe>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    800022b4:	28890493          	addi	s1,s2,648
            int proc_index= (int)(p-proc);// TODO delete
    800022b8:	00010797          	auipc	a5,0x10
    800022bc:	47078793          	addi	a5,a5,1136 # 80012728 <proc>
    800022c0:	40f907b3          	sub	a5,s2,a5
    800022c4:	878d                	srai	a5,a5,0x3
    800022c6:	00007c97          	auipc	s9,0x7
    800022ca:	d3acbc83          	ld	s9,-710(s9) # 80009000 <etext>
    800022ce:	03978cbb          	mulw	s9,a5,s9
          if(t->state == TRUNNABLE && !t->frozen) {
    800022d2:	4a0d                	li	s4,3
            printf("%d\n",proc_index);
    800022d4:	00007d17          	auipc	s10,0x7
    800022d8:	344d0d13          	addi	s10,s10,836 # 80009618 <states.0+0x1a0>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    800022dc:	015909b3          	add	s3,s2,s5
    800022e0:	bfa5                	j	80002258 <scheduler+0x7a>

00000000800022e2 <sched>:
{
    800022e2:	7179                	addi	sp,sp,-48
    800022e4:	f406                	sd	ra,40(sp)
    800022e6:	f022                	sd	s0,32(sp)
    800022e8:	ec26                	sd	s1,24(sp)
    800022ea:	e84a                	sd	s2,16(sp)
    800022ec:	e44e                	sd	s3,8(sp)
    800022ee:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800022f0:	fffff097          	auipc	ra,0xfffff
    800022f4:	78c080e7          	jalr	1932(ra) # 80001a7c <myproc>
    800022f8:	892a                	mv	s2,a0
  struct kthread *t=mykthread();
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	7c2080e7          	jalr	1986(ra) # 80001abc <mykthread>
    80002302:	84aa                	mv	s1,a0
  if(!holding(&t->lock))
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	848080e7          	jalr	-1976(ra) # 80000b4c <holding>
    8000230c:	c959                	beqz	a0,800023a2 <sched+0xc0>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000230e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002310:	0007871b          	sext.w	a4,a5
    80002314:	00471793          	slli	a5,a4,0x4
    80002318:	97ba                	add	a5,a5,a4
    8000231a:	078e                	slli	a5,a5,0x3
    8000231c:	00010717          	auipc	a4,0x10
    80002320:	f8470713          	addi	a4,a4,-124 # 800122a0 <pid_lock>
    80002324:	97ba                	add	a5,a5,a4
    80002326:	0c07a703          	lw	a4,192(a5)
    8000232a:	4785                	li	a5,1
    8000232c:	08f71363          	bne	a4,a5,800023b2 <sched+0xd0>
  if(t->state == TRUNNING){
    80002330:	4c98                	lw	a4,24(s1)
    80002332:	4791                	li	a5,4
    80002334:	08f70763          	beq	a4,a5,800023c2 <sched+0xe0>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002338:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000233c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000233e:	efdd                	bnez	a5,800023fc <sched+0x11a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002340:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002342:	00010917          	auipc	s2,0x10
    80002346:	f5e90913          	addi	s2,s2,-162 # 800122a0 <pid_lock>
    8000234a:	0007871b          	sext.w	a4,a5
    8000234e:	00471793          	slli	a5,a4,0x4
    80002352:	97ba                	add	a5,a5,a4
    80002354:	078e                	slli	a5,a5,0x3
    80002356:	97ca                	add	a5,a5,s2
    80002358:	0c47a983          	lw	s3,196(a5)
    8000235c:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    8000235e:	0007859b          	sext.w	a1,a5
    80002362:	00459793          	slli	a5,a1,0x4
    80002366:	97ae                	add	a5,a5,a1
    80002368:	078e                	slli	a5,a5,0x3
    8000236a:	00010597          	auipc	a1,0x10
    8000236e:	f8658593          	addi	a1,a1,-122 # 800122f0 <cpus+0x8>
    80002372:	95be                	add	a1,a1,a5
    80002374:	04848513          	addi	a0,s1,72
    80002378:	00001097          	auipc	ra,0x1
    8000237c:	eee080e7          	jalr	-274(ra) # 80003266 <swtch>
    80002380:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002382:	0007871b          	sext.w	a4,a5
    80002386:	00471793          	slli	a5,a4,0x4
    8000238a:	97ba                	add	a5,a5,a4
    8000238c:	078e                	slli	a5,a5,0x3
    8000238e:	97ca                	add	a5,a5,s2
    80002390:	0d37a223          	sw	s3,196(a5)
}
    80002394:	70a2                	ld	ra,40(sp)
    80002396:	7402                	ld	s0,32(sp)
    80002398:	64e2                	ld	s1,24(sp)
    8000239a:	6942                	ld	s2,16(sp)
    8000239c:	69a2                	ld	s3,8(sp)
    8000239e:	6145                	addi	sp,sp,48
    800023a0:	8082                	ret
    panic("sched t->lock");
    800023a2:	00007517          	auipc	a0,0x7
    800023a6:	ec650513          	addi	a0,a0,-314 # 80009268 <digits+0x228>
    800023aa:	ffffe097          	auipc	ra,0xffffe
    800023ae:	184080e7          	jalr	388(ra) # 8000052e <panic>
    panic("sched locks");
    800023b2:	00007517          	auipc	a0,0x7
    800023b6:	ec650513          	addi	a0,a0,-314 # 80009278 <digits+0x238>
    800023ba:	ffffe097          	auipc	ra,0xffffe
    800023be:	174080e7          	jalr	372(ra) # 8000052e <panic>
              int proc_index= (int)(p-proc);// TODO delete
    800023c2:	00010797          	auipc	a5,0x10
    800023c6:	36678793          	addi	a5,a5,870 # 80012728 <proc>
    800023ca:	40f907b3          	sub	a5,s2,a5
    800023ce:	878d                	srai	a5,a5,0x3
    printf("sched%d\n",proc_index);
    800023d0:	00007597          	auipc	a1,0x7
    800023d4:	c305b583          	ld	a1,-976(a1) # 80009000 <etext>
    800023d8:	02b785bb          	mulw	a1,a5,a1
    800023dc:	00007517          	auipc	a0,0x7
    800023e0:	eac50513          	addi	a0,a0,-340 # 80009288 <digits+0x248>
    800023e4:	ffffe097          	auipc	ra,0xffffe
    800023e8:	194080e7          	jalr	404(ra) # 80000578 <printf>
    panic("sched running");
    800023ec:	00007517          	auipc	a0,0x7
    800023f0:	eac50513          	addi	a0,a0,-340 # 80009298 <digits+0x258>
    800023f4:	ffffe097          	auipc	ra,0xffffe
    800023f8:	13a080e7          	jalr	314(ra) # 8000052e <panic>
    panic("sched interruptible");
    800023fc:	00007517          	auipc	a0,0x7
    80002400:	eac50513          	addi	a0,a0,-340 # 800092a8 <digits+0x268>
    80002404:	ffffe097          	auipc	ra,0xffffe
    80002408:	12a080e7          	jalr	298(ra) # 8000052e <panic>

000000008000240c <yield>:
{
    8000240c:	1101                	addi	sp,sp,-32
    8000240e:	ec06                	sd	ra,24(sp)
    80002410:	e822                	sd	s0,16(sp)
    80002412:	e426                	sd	s1,8(sp)
    80002414:	1000                	addi	s0,sp,32
  struct kthread *t =mykthread();
    80002416:	fffff097          	auipc	ra,0xfffff
    8000241a:	6a6080e7          	jalr	1702(ra) # 80001abc <mykthread>
    8000241e:	84aa                	mv	s1,a0
  acquire(&t->lock);
    80002420:	ffffe097          	auipc	ra,0xffffe
    80002424:	7a6080e7          	jalr	1958(ra) # 80000bc6 <acquire>
  t->state = TRUNNABLE;
    80002428:	478d                	li	a5,3
    8000242a:	cc9c                	sw	a5,24(s1)
  sched();
    8000242c:	00000097          	auipc	ra,0x0
    80002430:	eb6080e7          	jalr	-330(ra) # 800022e2 <sched>
  release(&t->lock);
    80002434:	8526                	mv	a0,s1
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	866080e7          	jalr	-1946(ra) # 80000c9c <release>
}
    8000243e:	60e2                	ld	ra,24(sp)
    80002440:	6442                	ld	s0,16(sp)
    80002442:	64a2                	ld	s1,8(sp)
    80002444:	6105                	addi	sp,sp,32
    80002446:	8082                	ret

0000000080002448 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002448:	7179                	addi	sp,sp,-48
    8000244a:	f406                	sd	ra,40(sp)
    8000244c:	f022                	sd	s0,32(sp)
    8000244e:	ec26                	sd	s1,24(sp)
    80002450:	e84a                	sd	s2,16(sp)
    80002452:	e44e                	sd	s3,8(sp)
    80002454:	1800                	addi	s0,sp,48
    80002456:	89aa                	mv	s3,a0
    80002458:	892e                	mv	s2,a1
  // struct proc *p = myproc();
  struct kthread *t=mykthread();
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	662080e7          	jalr	1634(ra) # 80001abc <mykthread>
    80002462:	84aa                	mv	s1,a0
  struct proc *p=myproc();
    80002464:	fffff097          	auipc	ra,0xfffff
    80002468:	618080e7          	jalr	1560(ra) # 80001a7c <myproc>
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.
  acquire(&t->lock);  //DOC: sleeplock1
    8000246c:	8526                	mv	a0,s1
    8000246e:	ffffe097          	auipc	ra,0xffffe
    80002472:	758080e7          	jalr	1880(ra) # 80000bc6 <acquire>
  release(lk);
    80002476:	854a                	mv	a0,s2
    80002478:	fffff097          	auipc	ra,0xfffff
    8000247c:	824080e7          	jalr	-2012(ra) # 80000c9c <release>
  // printf("sl-s%d\n",p->pid);//TODO delete
  // Go to sleep.
  t->chan = chan;
    80002480:	0334b023          	sd	s3,32(s1)
  t->state = TSLEEPING;
    80002484:	4789                	li	a5,2
    80002486:	cc9c                	sw	a5,24(s1)

  sched();
    80002488:	00000097          	auipc	ra,0x0
    8000248c:	e5a080e7          	jalr	-422(ra) # 800022e2 <sched>

  // Tidy up.
  t->chan = 0;
    80002490:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&t->lock);
    80002494:	8526                	mv	a0,s1
    80002496:	fffff097          	auipc	ra,0xfffff
    8000249a:	806080e7          	jalr	-2042(ra) # 80000c9c <release>
  // printf("sl-e%d\n",p->pid);//TODO delete
  acquire(lk);
    8000249e:	854a                	mv	a0,s2
    800024a0:	ffffe097          	auipc	ra,0xffffe
    800024a4:	726080e7          	jalr	1830(ra) # 80000bc6 <acquire>
}
    800024a8:	70a2                	ld	ra,40(sp)
    800024aa:	7402                	ld	s0,32(sp)
    800024ac:	64e2                	ld	s1,24(sp)
    800024ae:	6942                	ld	s2,16(sp)
    800024b0:	69a2                	ld	s3,8(sp)
    800024b2:	6145                	addi	sp,sp,48
    800024b4:	8082                	ret

00000000800024b6 <wait>:
{
    800024b6:	715d                	addi	sp,sp,-80
    800024b8:	e486                	sd	ra,72(sp)
    800024ba:	e0a2                	sd	s0,64(sp)
    800024bc:	fc26                	sd	s1,56(sp)
    800024be:	f84a                	sd	s2,48(sp)
    800024c0:	f44e                	sd	s3,40(sp)
    800024c2:	f052                	sd	s4,32(sp)
    800024c4:	ec56                	sd	s5,24(sp)
    800024c6:	e85a                	sd	s6,16(sp)
    800024c8:	e45e                	sd	s7,8(sp)
    800024ca:	0880                	addi	s0,sp,80
    800024cc:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800024ce:	fffff097          	auipc	ra,0xfffff
    800024d2:	5ae080e7          	jalr	1454(ra) # 80001a7c <myproc>
    800024d6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024d8:	00010517          	auipc	a0,0x10
    800024dc:	df850513          	addi	a0,a0,-520 # 800122d0 <wait_lock>
    800024e0:	ffffe097          	auipc	ra,0xffffe
    800024e4:	6e6080e7          	jalr	1766(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    800024e8:	4b0d                	li	s6,3
        havekids = 1;
    800024ea:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800024ec:	6985                	lui	s3,0x1
    800024ee:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    800024f2:	00031a17          	auipc	s4,0x31
    800024f6:	436a0a13          	addi	s4,s4,1078 # 80033928 <tickslock>
    havekids = 0;
    800024fa:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    800024fc:	00010497          	auipc	s1,0x10
    80002500:	22c48493          	addi	s1,s1,556 # 80012728 <proc>
    80002504:	a0b5                	j	80002570 <wait+0xba>
          pid = np->pid;
    80002506:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000250a:	000b8e63          	beqz	s7,80002526 <wait+0x70>
    8000250e:	4691                	li	a3,4
    80002510:	02048613          	addi	a2,s1,32
    80002514:	85de                	mv	a1,s7
    80002516:	04093503          	ld	a0,64(s2)
    8000251a:	fffff097          	auipc	ra,0xfffff
    8000251e:	14a080e7          	jalr	330(ra) # 80001664 <copyout>
    80002522:	02054563          	bltz	a0,8000254c <wait+0x96>
          freeproc(np);
    80002526:	8526                	mv	a0,s1
    80002528:	fffff097          	auipc	ra,0xfffff
    8000252c:	7de080e7          	jalr	2014(ra) # 80001d06 <freeproc>
          release(&np->lock);
    80002530:	8526                	mv	a0,s1
    80002532:	ffffe097          	auipc	ra,0xffffe
    80002536:	76a080e7          	jalr	1898(ra) # 80000c9c <release>
          release(&wait_lock);
    8000253a:	00010517          	auipc	a0,0x10
    8000253e:	d9650513          	addi	a0,a0,-618 # 800122d0 <wait_lock>
    80002542:	ffffe097          	auipc	ra,0xffffe
    80002546:	75a080e7          	jalr	1882(ra) # 80000c9c <release>
          return pid;
    8000254a:	a09d                	j	800025b0 <wait+0xfa>
            release(&np->lock);
    8000254c:	8526                	mv	a0,s1
    8000254e:	ffffe097          	auipc	ra,0xffffe
    80002552:	74e080e7          	jalr	1870(ra) # 80000c9c <release>
            release(&wait_lock);
    80002556:	00010517          	auipc	a0,0x10
    8000255a:	d7a50513          	addi	a0,a0,-646 # 800122d0 <wait_lock>
    8000255e:	ffffe097          	auipc	ra,0xffffe
    80002562:	73e080e7          	jalr	1854(ra) # 80000c9c <release>
            return -1;
    80002566:	59fd                	li	s3,-1
    80002568:	a0a1                	j	800025b0 <wait+0xfa>
    for(np = proc; np < &proc[NPROC]; np++){
    8000256a:	94ce                	add	s1,s1,s3
    8000256c:	03448463          	beq	s1,s4,80002594 <wait+0xde>
      if(np->parent == p){
    80002570:	789c                	ld	a5,48(s1)
    80002572:	ff279ce3          	bne	a5,s2,8000256a <wait+0xb4>
        acquire(&np->lock);
    80002576:	8526                	mv	a0,s1
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	64e080e7          	jalr	1614(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    80002580:	4c9c                	lw	a5,24(s1)
    80002582:	f96782e3          	beq	a5,s6,80002506 <wait+0x50>
        release(&np->lock);
    80002586:	8526                	mv	a0,s1
    80002588:	ffffe097          	auipc	ra,0xffffe
    8000258c:	714080e7          	jalr	1812(ra) # 80000c9c <release>
        havekids = 1;
    80002590:	8756                	mv	a4,s5
    80002592:	bfe1                	j	8000256a <wait+0xb4>
    if(!havekids || p->killed==1){
    80002594:	c709                	beqz	a4,8000259e <wait+0xe8>
    80002596:	01c92783          	lw	a5,28(s2)
    8000259a:	03579763          	bne	a5,s5,800025c8 <wait+0x112>
      release(&wait_lock);
    8000259e:	00010517          	auipc	a0,0x10
    800025a2:	d3250513          	addi	a0,a0,-718 # 800122d0 <wait_lock>
    800025a6:	ffffe097          	auipc	ra,0xffffe
    800025aa:	6f6080e7          	jalr	1782(ra) # 80000c9c <release>
      return -1;
    800025ae:	59fd                	li	s3,-1
}
    800025b0:	854e                	mv	a0,s3
    800025b2:	60a6                	ld	ra,72(sp)
    800025b4:	6406                	ld	s0,64(sp)
    800025b6:	74e2                	ld	s1,56(sp)
    800025b8:	7942                	ld	s2,48(sp)
    800025ba:	79a2                	ld	s3,40(sp)
    800025bc:	7a02                	ld	s4,32(sp)
    800025be:	6ae2                	ld	s5,24(sp)
    800025c0:	6b42                	ld	s6,16(sp)
    800025c2:	6ba2                	ld	s7,8(sp)
    800025c4:	6161                	addi	sp,sp,80
    800025c6:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025c8:	00010597          	auipc	a1,0x10
    800025cc:	d0858593          	addi	a1,a1,-760 # 800122d0 <wait_lock>
    800025d0:	854a                	mv	a0,s2
    800025d2:	00000097          	auipc	ra,0x0
    800025d6:	e76080e7          	jalr	-394(ra) # 80002448 <sleep>
    havekids = 0;
    800025da:	b705                	j	800024fa <wait+0x44>

00000000800025dc <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800025dc:	711d                	addi	sp,sp,-96
    800025de:	ec86                	sd	ra,88(sp)
    800025e0:	e8a2                	sd	s0,80(sp)
    800025e2:	e4a6                	sd	s1,72(sp)
    800025e4:	e0ca                	sd	s2,64(sp)
    800025e6:	fc4e                	sd	s3,56(sp)
    800025e8:	f852                	sd	s4,48(sp)
    800025ea:	f456                	sd	s5,40(sp)
    800025ec:	f05a                	sd	s6,32(sp)
    800025ee:	ec5e                	sd	s7,24(sp)
    800025f0:	e862                	sd	s8,16(sp)
    800025f2:	e466                	sd	s9,8(sp)
    800025f4:	1080                	addi	s0,sp,96
    800025f6:	8c2a                	mv	s8,a0
  struct proc *p;
  struct kthread *t;
  struct kthread *my_t = mykthread();
    800025f8:	fffff097          	auipc	ra,0xfffff
    800025fc:	4c4080e7          	jalr	1220(ra) # 80001abc <mykthread>
    80002600:	8aaa                	mv	s5,a0

  for(p = proc; p < &proc[NPROC]; p++) {
    80002602:	00010917          	auipc	s2,0x10
    80002606:	3ae90913          	addi	s2,s2,942 # 800129b0 <proc+0x288>
    8000260a:	00031b97          	auipc	s7,0x31
    8000260e:	5a6b8b93          	addi	s7,s7,1446 # 80033bb0 <bcache+0x270>
    // acquire(&p->lock);
    if(p->state == RUNNABLE){
    80002612:	4989                	li	s3,2
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
        if(t != my_t){
          acquire(&t->lock);
          if(t->state == TSLEEPING && t->chan == chan) {
            t->state = TRUNNABLE;
    80002614:	4c8d                	li	s9,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002616:	6b05                	lui	s6,0x1
    80002618:	848b0b13          	addi	s6,s6,-1976 # 848 <_entry-0x7ffff7b8>
    8000261c:	a82d                	j	80002656 <wakeup+0x7a>
          }
          release(&t->lock);
    8000261e:	8526                	mv	a0,s1
    80002620:	ffffe097          	auipc	ra,0xffffe
    80002624:	67c080e7          	jalr	1660(ra) # 80000c9c <release>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    80002628:	0b848493          	addi	s1,s1,184
    8000262c:	03448263          	beq	s1,s4,80002650 <wakeup+0x74>
        if(t != my_t){
    80002630:	fe9a8ce3          	beq	s5,s1,80002628 <wakeup+0x4c>
          acquire(&t->lock);
    80002634:	8526                	mv	a0,s1
    80002636:	ffffe097          	auipc	ra,0xffffe
    8000263a:	590080e7          	jalr	1424(ra) # 80000bc6 <acquire>
          if(t->state == TSLEEPING && t->chan == chan) {
    8000263e:	4c9c                	lw	a5,24(s1)
    80002640:	fd379fe3          	bne	a5,s3,8000261e <wakeup+0x42>
    80002644:	709c                	ld	a5,32(s1)
    80002646:	fd879ce3          	bne	a5,s8,8000261e <wakeup+0x42>
            t->state = TRUNNABLE;
    8000264a:	0194ac23          	sw	s9,24(s1)
    8000264e:	bfc1                	j	8000261e <wakeup+0x42>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002650:	995a                	add	s2,s2,s6
    80002652:	01790a63          	beq	s2,s7,80002666 <wakeup+0x8a>
    if(p->state == RUNNABLE){
    80002656:	84ca                	mv	s1,s2
    80002658:	d9092783          	lw	a5,-624(s2)
    8000265c:	ff379ae3          	bne	a5,s3,80002650 <wakeup+0x74>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    80002660:	5c090a13          	addi	s4,s2,1472
    80002664:	b7f1                	j	80002630 <wakeup+0x54>
        }
      }
    }
    // release(&p->lock);
  }
}
    80002666:	60e6                	ld	ra,88(sp)
    80002668:	6446                	ld	s0,80(sp)
    8000266a:	64a6                	ld	s1,72(sp)
    8000266c:	6906                	ld	s2,64(sp)
    8000266e:	79e2                	ld	s3,56(sp)
    80002670:	7a42                	ld	s4,48(sp)
    80002672:	7aa2                	ld	s5,40(sp)
    80002674:	7b02                	ld	s6,32(sp)
    80002676:	6be2                	ld	s7,24(sp)
    80002678:	6c42                	ld	s8,16(sp)
    8000267a:	6ca2                	ld	s9,8(sp)
    8000267c:	6125                	addi	sp,sp,96
    8000267e:	8082                	ret

0000000080002680 <reparent>:
{
    80002680:	7139                	addi	sp,sp,-64
    80002682:	fc06                	sd	ra,56(sp)
    80002684:	f822                	sd	s0,48(sp)
    80002686:	f426                	sd	s1,40(sp)
    80002688:	f04a                	sd	s2,32(sp)
    8000268a:	ec4e                	sd	s3,24(sp)
    8000268c:	e852                	sd	s4,16(sp)
    8000268e:	e456                	sd	s5,8(sp)
    80002690:	0080                	addi	s0,sp,64
    80002692:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002694:	00010497          	auipc	s1,0x10
    80002698:	09448493          	addi	s1,s1,148 # 80012728 <proc>
      pp->parent = initproc;
    8000269c:	00008a97          	auipc	s5,0x8
    800026a0:	98ca8a93          	addi	s5,s5,-1652 # 8000a028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800026a4:	6905                	lui	s2,0x1
    800026a6:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    800026aa:	00031a17          	auipc	s4,0x31
    800026ae:	27ea0a13          	addi	s4,s4,638 # 80033928 <tickslock>
    800026b2:	a021                	j	800026ba <reparent+0x3a>
    800026b4:	94ca                	add	s1,s1,s2
    800026b6:	01448d63          	beq	s1,s4,800026d0 <reparent+0x50>
    if(pp->parent == p){
    800026ba:	789c                	ld	a5,48(s1)
    800026bc:	ff379ce3          	bne	a5,s3,800026b4 <reparent+0x34>
      pp->parent = initproc;
    800026c0:	000ab503          	ld	a0,0(s5)
    800026c4:	f888                	sd	a0,48(s1)
      wakeup(initproc);
    800026c6:	00000097          	auipc	ra,0x0
    800026ca:	f16080e7          	jalr	-234(ra) # 800025dc <wakeup>
    800026ce:	b7dd                	j	800026b4 <reparent+0x34>
}
    800026d0:	70e2                	ld	ra,56(sp)
    800026d2:	7442                	ld	s0,48(sp)
    800026d4:	74a2                	ld	s1,40(sp)
    800026d6:	7902                	ld	s2,32(sp)
    800026d8:	69e2                	ld	s3,24(sp)
    800026da:	6a42                	ld	s4,16(sp)
    800026dc:	6aa2                	ld	s5,8(sp)
    800026de:	6121                	addi	sp,sp,64
    800026e0:	8082                	ret

00000000800026e2 <exit_proccess>:
{
    800026e2:	7139                	addi	sp,sp,-64
    800026e4:	fc06                	sd	ra,56(sp)
    800026e6:	f822                	sd	s0,48(sp)
    800026e8:	f426                	sd	s1,40(sp)
    800026ea:	f04a                	sd	s2,32(sp)
    800026ec:	ec4e                	sd	s3,24(sp)
    800026ee:	e852                	sd	s4,16(sp)
    800026f0:	e456                	sd	s5,8(sp)
    800026f2:	e05a                	sd	s6,0(sp)
    800026f4:	0080                	addi	s0,sp,64
    800026f6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800026f8:	fffff097          	auipc	ra,0xfffff
    800026fc:	384080e7          	jalr	900(ra) # 80001a7c <myproc>
    80002700:	8a2a                	mv	s4,a0
  struct kthread *t = mykthread();
    80002702:	fffff097          	auipc	ra,0xfffff
    80002706:	3ba080e7          	jalr	954(ra) # 80001abc <mykthread>
    8000270a:	8aaa                	mv	s5,a0
  int proc_index= (int)(p-proc);// TODO delete
    8000270c:	00010997          	auipc	s3,0x10
    80002710:	01c98993          	addi	s3,s3,28 # 80012728 <proc>
    80002714:	413a09b3          	sub	s3,s4,s3
    80002718:	4039d993          	srai	s3,s3,0x3
    8000271c:	00007797          	auipc	a5,0x7
    80002720:	8e47b783          	ld	a5,-1820(a5) # 80009000 <etext>
    80002724:	02f989bb          	mulw	s3,s3,a5
  printf("%d dx: at e_proc\n",proc_index);// TODO delete
    80002728:	85ce                	mv	a1,s3
    8000272a:	00007517          	auipc	a0,0x7
    8000272e:	b9650513          	addi	a0,a0,-1130 # 800092c0 <digits+0x280>
    80002732:	ffffe097          	auipc	ra,0xffffe
    80002736:	e46080e7          	jalr	-442(ra) # 80000578 <printf>
  if(p == initproc)
    8000273a:	00008797          	auipc	a5,0x8
    8000273e:	8ee7b783          	ld	a5,-1810(a5) # 8000a028 <initproc>
    80002742:	050a0493          	addi	s1,s4,80
    80002746:	0d0a0913          	addi	s2,s4,208
    8000274a:	03479363          	bne	a5,s4,80002770 <exit_proccess+0x8e>
    panic("init exiting");
    8000274e:	00007517          	auipc	a0,0x7
    80002752:	b8a50513          	addi	a0,a0,-1142 # 800092d8 <digits+0x298>
    80002756:	ffffe097          	auipc	ra,0xffffe
    8000275a:	dd8080e7          	jalr	-552(ra) # 8000052e <panic>
      fileclose(f);
    8000275e:	00003097          	auipc	ra,0x3
    80002762:	f96080e7          	jalr	-106(ra) # 800056f4 <fileclose>
      p->ofile[fd] = 0;
    80002766:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000276a:	04a1                	addi	s1,s1,8
    8000276c:	01248563          	beq	s1,s2,80002776 <exit_proccess+0x94>
    if(p->ofile[fd]){
    80002770:	6088                	ld	a0,0(s1)
    80002772:	f575                	bnez	a0,8000275e <exit_proccess+0x7c>
    80002774:	bfdd                	j	8000276a <exit_proccess+0x88>
  printf("%d dx: at e_proc_b\n",proc_index);// TODO delete
    80002776:	85ce                	mv	a1,s3
    80002778:	00007517          	auipc	a0,0x7
    8000277c:	b7050513          	addi	a0,a0,-1168 # 800092e8 <digits+0x2a8>
    80002780:	ffffe097          	auipc	ra,0xffffe
    80002784:	df8080e7          	jalr	-520(ra) # 80000578 <printf>
  begin_op();
    80002788:	00003097          	auipc	ra,0x3
    8000278c:	aa0080e7          	jalr	-1376(ra) # 80005228 <begin_op>
  iput(p->cwd);
    80002790:	0d0a3503          	ld	a0,208(s4)
    80002794:	00002097          	auipc	ra,0x2
    80002798:	27a080e7          	jalr	634(ra) # 80004a0e <iput>
  end_op();
    8000279c:	00003097          	auipc	ra,0x3
    800027a0:	b0c080e7          	jalr	-1268(ra) # 800052a8 <end_op>
  p->cwd = 0;
    800027a4:	0c0a3823          	sd	zero,208(s4)
  acquire(&wait_lock);
    800027a8:	00010497          	auipc	s1,0x10
    800027ac:	b2848493          	addi	s1,s1,-1240 # 800122d0 <wait_lock>
    800027b0:	8526                	mv	a0,s1
    800027b2:	ffffe097          	auipc	ra,0xffffe
    800027b6:	414080e7          	jalr	1044(ra) # 80000bc6 <acquire>
  printf("%d dx: at e_proc_c\n",proc_index);// TODO delete
    800027ba:	85ce                	mv	a1,s3
    800027bc:	00007517          	auipc	a0,0x7
    800027c0:	b4450513          	addi	a0,a0,-1212 # 80009300 <digits+0x2c0>
    800027c4:	ffffe097          	auipc	ra,0xffffe
    800027c8:	db4080e7          	jalr	-588(ra) # 80000578 <printf>
  reparent(p);
    800027cc:	8552                	mv	a0,s4
    800027ce:	00000097          	auipc	ra,0x0
    800027d2:	eb2080e7          	jalr	-334(ra) # 80002680 <reparent>
  printf("%d dx: at e_proc_d\n",proc_index);// TODO delete
    800027d6:	85ce                	mv	a1,s3
    800027d8:	00007517          	auipc	a0,0x7
    800027dc:	b4050513          	addi	a0,a0,-1216 # 80009318 <digits+0x2d8>
    800027e0:	ffffe097          	auipc	ra,0xffffe
    800027e4:	d98080e7          	jalr	-616(ra) # 80000578 <printf>
  wakeup(p->parent);
    800027e8:	030a3503          	ld	a0,48(s4)
    800027ec:	00000097          	auipc	ra,0x0
    800027f0:	df0080e7          	jalr	-528(ra) # 800025dc <wakeup>
  printf("%d dx: at e_proc_e\n",proc_index);// TODO delete
    800027f4:	85ce                	mv	a1,s3
    800027f6:	00007517          	auipc	a0,0x7
    800027fa:	b3a50513          	addi	a0,a0,-1222 # 80009330 <digits+0x2f0>
    800027fe:	ffffe097          	auipc	ra,0xffffe
    80002802:	d7a080e7          	jalr	-646(ra) # 80000578 <printf>
  acquire(&p->lock);
    80002806:	8552                	mv	a0,s4
    80002808:	ffffe097          	auipc	ra,0xffffe
    8000280c:	3be080e7          	jalr	958(ra) # 80000bc6 <acquire>
  printf("%d dx: at e_proc_f\n",proc_index);// TODO delete
    80002810:	85ce                	mv	a1,s3
    80002812:	00007517          	auipc	a0,0x7
    80002816:	b3650513          	addi	a0,a0,-1226 # 80009348 <digits+0x308>
    8000281a:	ffffe097          	auipc	ra,0xffffe
    8000281e:	d5e080e7          	jalr	-674(ra) # 80000578 <printf>
  p->xstate = status;
    80002822:	036a2023          	sw	s6,32(s4)
  p->state = ZOMBIE;
    80002826:	478d                	li	a5,3
    80002828:	00fa2c23          	sw	a5,24(s4)
  t->state=TZOMBIE;
    8000282c:	4795                	li	a5,5
    8000282e:	00faac23          	sw	a5,24(s5)
  release(&wait_lock);
    80002832:	8526                	mv	a0,s1
    80002834:	ffffe097          	auipc	ra,0xffffe
    80002838:	468080e7          	jalr	1128(ra) # 80000c9c <release>
  acquire(&t->lock);
    8000283c:	8556                	mv	a0,s5
    8000283e:	ffffe097          	auipc	ra,0xffffe
    80002842:	388080e7          	jalr	904(ra) # 80000bc6 <acquire>
  release(&p->lock);// ze po achav :) 
    80002846:	8552                	mv	a0,s4
    80002848:	ffffe097          	auipc	ra,0xffffe
    8000284c:	454080e7          	jalr	1108(ra) # 80000c9c <release>
  printf("%d dx: at e_proc_g\n",proc_index);// TODO delete
    80002850:	85ce                	mv	a1,s3
    80002852:	00007517          	auipc	a0,0x7
    80002856:	b0e50513          	addi	a0,a0,-1266 # 80009360 <digits+0x320>
    8000285a:	ffffe097          	auipc	ra,0xffffe
    8000285e:	d1e080e7          	jalr	-738(ra) # 80000578 <printf>
  sched();
    80002862:	00000097          	auipc	ra,0x0
    80002866:	a80080e7          	jalr	-1408(ra) # 800022e2 <sched>
  printf("zombie exit %d\n",proc_index);
    8000286a:	85ce                	mv	a1,s3
    8000286c:	00007517          	auipc	a0,0x7
    80002870:	b0c50513          	addi	a0,a0,-1268 # 80009378 <digits+0x338>
    80002874:	ffffe097          	auipc	ra,0xffffe
    80002878:	d04080e7          	jalr	-764(ra) # 80000578 <printf>
  panic("zombie exit");
    8000287c:	00007517          	auipc	a0,0x7
    80002880:	b0c50513          	addi	a0,a0,-1268 # 80009388 <digits+0x348>
    80002884:	ffffe097          	auipc	ra,0xffffe
    80002888:	caa080e7          	jalr	-854(ra) # 8000052e <panic>

000000008000288c <kthread_exit>:
kthread_exit(int status){
    8000288c:	7179                	addi	sp,sp,-48
    8000288e:	f406                	sd	ra,40(sp)
    80002890:	f022                	sd	s0,32(sp)
    80002892:	ec26                	sd	s1,24(sp)
    80002894:	e84a                	sd	s2,16(sp)
    80002896:	e44e                	sd	s3,8(sp)
    80002898:	e052                	sd	s4,0(sp)
    8000289a:	1800                	addi	s0,sp,48
    8000289c:	89aa                	mv	s3,a0
  struct proc *p = myproc(); 
    8000289e:	fffff097          	auipc	ra,0xfffff
    800028a2:	1de080e7          	jalr	478(ra) # 80001a7c <myproc>
    800028a6:	892a                	mv	s2,a0
  struct kthread *t=mykthread();
    800028a8:	fffff097          	auipc	ra,0xfffff
    800028ac:	214080e7          	jalr	532(ra) # 80001abc <mykthread>
    800028b0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800028b2:	854a                	mv	a0,s2
    800028b4:	ffffe097          	auipc	ra,0xffffe
    800028b8:	312080e7          	jalr	786(ra) # 80000bc6 <acquire>
  p->active_threads--;
    800028bc:	02892783          	lw	a5,40(s2)
    800028c0:	37fd                	addiw	a5,a5,-1
    800028c2:	00078a1b          	sext.w	s4,a5
    800028c6:	02f92423          	sw	a5,40(s2)
  release(&p->lock);
    800028ca:	854a                	mv	a0,s2
    800028cc:	ffffe097          	auipc	ra,0xffffe
    800028d0:	3d0080e7          	jalr	976(ra) # 80000c9c <release>
  acquire(&t->lock);
    800028d4:	8526                	mv	a0,s1
    800028d6:	ffffe097          	auipc	ra,0xffffe
    800028da:	2f0080e7          	jalr	752(ra) # 80000bc6 <acquire>
  t->xstate = status;
    800028de:	0334a623          	sw	s3,44(s1)
  t->state  = TZOMBIE;
    800028e2:	4795                	li	a5,5
    800028e4:	cc9c                	sw	a5,24(s1)
  release(&t->lock);////////////////////////////////////////////////////////check
    800028e6:	8526                	mv	a0,s1
    800028e8:	ffffe097          	auipc	ra,0xffffe
    800028ec:	3b4080e7          	jalr	948(ra) # 80000c9c <release>
  wakeup(t);
    800028f0:	8526                	mv	a0,s1
    800028f2:	00000097          	auipc	ra,0x0
    800028f6:	cea080e7          	jalr	-790(ra) # 800025dc <wakeup>
  if(curr_active_threads==0){
    800028fa:	000a1763          	bnez	s4,80002908 <kthread_exit+0x7c>
    exit_proccess(status);
    800028fe:	854e                	mv	a0,s3
    80002900:	00000097          	auipc	ra,0x0
    80002904:	de2080e7          	jalr	-542(ra) # 800026e2 <exit_proccess>
    acquire(&t->lock);////////////////////////////////////////////////////////check
    80002908:	8526                	mv	a0,s1
    8000290a:	ffffe097          	auipc	ra,0xffffe
    8000290e:	2bc080e7          	jalr	700(ra) # 80000bc6 <acquire>
    sched();
    80002912:	00000097          	auipc	ra,0x0
    80002916:	9d0080e7          	jalr	-1584(ra) # 800022e2 <sched>
    panic("zombie thread exit");
    8000291a:	00007517          	auipc	a0,0x7
    8000291e:	a7e50513          	addi	a0,a0,-1410 # 80009398 <digits+0x358>
    80002922:	ffffe097          	auipc	ra,0xffffe
    80002926:	c0c080e7          	jalr	-1012(ra) # 8000052e <panic>

000000008000292a <exit>:
exit(int status){
    8000292a:	7139                	addi	sp,sp,-64
    8000292c:	fc06                	sd	ra,56(sp)
    8000292e:	f822                	sd	s0,48(sp)
    80002930:	f426                	sd	s1,40(sp)
    80002932:	f04a                	sd	s2,32(sp)
    80002934:	ec4e                	sd	s3,24(sp)
    80002936:	e852                	sd	s4,16(sp)
    80002938:	e456                	sd	s5,8(sp)
    8000293a:	e05a                	sd	s6,0(sp)
    8000293c:	0080                	addi	s0,sp,64
    8000293e:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    80002940:	fffff097          	auipc	ra,0xfffff
    80002944:	13c080e7          	jalr	316(ra) # 80001a7c <myproc>
    80002948:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    8000294a:	fffff097          	auipc	ra,0xfffff
    8000294e:	172080e7          	jalr	370(ra) # 80001abc <mykthread>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002952:	28890493          	addi	s1,s2,648
    80002956:	6505                	lui	a0,0x1
    80002958:	84850513          	addi	a0,a0,-1976 # 848 <_entry-0x7ffff7b8>
    8000295c:	992a                	add	s2,s2,a0
    t->killed = 1;
    8000295e:	4a05                	li	s4,1
    if(t->state == TSLEEPING)
    80002960:	4989                	li	s3,2
      t->state = TRUNNABLE;
    80002962:	4b0d                	li	s6,3
    80002964:	a811                	j	80002978 <exit+0x4e>
    release(&t->lock);
    80002966:	8526                	mv	a0,s1
    80002968:	ffffe097          	auipc	ra,0xffffe
    8000296c:	334080e7          	jalr	820(ra) # 80000c9c <release>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002970:	0b848493          	addi	s1,s1,184
    80002974:	00990f63          	beq	s2,s1,80002992 <exit+0x68>
    acquire(&t->lock);
    80002978:	8526                	mv	a0,s1
    8000297a:	ffffe097          	auipc	ra,0xffffe
    8000297e:	24c080e7          	jalr	588(ra) # 80000bc6 <acquire>
    t->killed = 1;
    80002982:	0344a423          	sw	s4,40(s1)
    if(t->state == TSLEEPING)
    80002986:	4c9c                	lw	a5,24(s1)
    80002988:	fd379fe3          	bne	a5,s3,80002966 <exit+0x3c>
      t->state = TRUNNABLE;
    8000298c:	0164ac23          	sw	s6,24(s1)
    80002990:	bfd9                	j	80002966 <exit+0x3c>
  kthread_exit(status);
    80002992:	8556                	mv	a0,s5
    80002994:	00000097          	auipc	ra,0x0
    80002998:	ef8080e7          	jalr	-264(ra) # 8000288c <kthread_exit>

000000008000299c <sig_stop>:
//   return -1;
// }

int
sig_stop(int pid)//TODO delete if not used
{
    8000299c:	7179                	addi	sp,sp,-48
    8000299e:	f406                	sd	ra,40(sp)
    800029a0:	f022                	sd	s0,32(sp)
    800029a2:	ec26                	sd	s1,24(sp)
    800029a4:	e84a                	sd	s2,16(sp)
    800029a6:	e44e                	sd	s3,8(sp)
    800029a8:	e052                	sd	s4,0(sp)
    800029aa:	1800                	addi	s0,sp,48
    800029ac:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800029ae:	00010497          	auipc	s1,0x10
    800029b2:	d7a48493          	addi	s1,s1,-646 # 80012728 <proc>
    800029b6:	6985                	lui	s3,0x1
    800029b8:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    800029bc:	00031a17          	auipc	s4,0x31
    800029c0:	f6ca0a13          	addi	s4,s4,-148 # 80033928 <tickslock>
    acquire(&p->lock);
    800029c4:	8526                	mv	a0,s1
    800029c6:	ffffe097          	auipc	ra,0xffffe
    800029ca:	200080e7          	jalr	512(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    800029ce:	50dc                	lw	a5,36(s1)
    800029d0:	01278c63          	beq	a5,s2,800029e8 <sig_stop+0x4c>
      p->pending_signals|=(1<<SIGSTOP);

      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800029d4:	8526                	mv	a0,s1
    800029d6:	ffffe097          	auipc	ra,0xffffe
    800029da:	2c6080e7          	jalr	710(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800029de:	94ce                	add	s1,s1,s3
    800029e0:	ff4492e3          	bne	s1,s4,800029c4 <sig_stop+0x28>
  }
  return -1;
    800029e4:	557d                	li	a0,-1
    800029e6:	a831                	j	80002a02 <sig_stop+0x66>
      p->pending_signals|=(1<<SIGSTOP);
    800029e8:	0e84a783          	lw	a5,232(s1)
    800029ec:	00020737          	lui	a4,0x20
    800029f0:	8fd9                	or	a5,a5,a4
    800029f2:	0ef4a423          	sw	a5,232(s1)
      release(&p->lock);
    800029f6:	8526                	mv	a0,s1
    800029f8:	ffffe097          	auipc	ra,0xffffe
    800029fc:	2a4080e7          	jalr	676(ra) # 80000c9c <release>
      return 0;
    80002a00:	4501                	li	a0,0
}
    80002a02:	70a2                	ld	ra,40(sp)
    80002a04:	7402                	ld	s0,32(sp)
    80002a06:	64e2                	ld	s1,24(sp)
    80002a08:	6942                	ld	s2,16(sp)
    80002a0a:	69a2                	ld	s3,8(sp)
    80002a0c:	6a02                	ld	s4,0(sp)
    80002a0e:	6145                	addi	sp,sp,48
    80002a10:	8082                	ret

0000000080002a12 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002a12:	7179                	addi	sp,sp,-48
    80002a14:	f406                	sd	ra,40(sp)
    80002a16:	f022                	sd	s0,32(sp)
    80002a18:	ec26                	sd	s1,24(sp)
    80002a1a:	e84a                	sd	s2,16(sp)
    80002a1c:	e44e                	sd	s3,8(sp)
    80002a1e:	e052                	sd	s4,0(sp)
    80002a20:	1800                	addi	s0,sp,48
    80002a22:	84aa                	mv	s1,a0
    80002a24:	892e                	mv	s2,a1
    80002a26:	89b2                	mv	s3,a2
    80002a28:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a2a:	fffff097          	auipc	ra,0xfffff
    80002a2e:	052080e7          	jalr	82(ra) # 80001a7c <myproc>
  if(user_dst){
    80002a32:	c08d                	beqz	s1,80002a54 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002a34:	86d2                	mv	a3,s4
    80002a36:	864e                	mv	a2,s3
    80002a38:	85ca                	mv	a1,s2
    80002a3a:	6128                	ld	a0,64(a0)
    80002a3c:	fffff097          	auipc	ra,0xfffff
    80002a40:	c28080e7          	jalr	-984(ra) # 80001664 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002a44:	70a2                	ld	ra,40(sp)
    80002a46:	7402                	ld	s0,32(sp)
    80002a48:	64e2                	ld	s1,24(sp)
    80002a4a:	6942                	ld	s2,16(sp)
    80002a4c:	69a2                	ld	s3,8(sp)
    80002a4e:	6a02                	ld	s4,0(sp)
    80002a50:	6145                	addi	sp,sp,48
    80002a52:	8082                	ret
    memmove((char *)dst, src, len);
    80002a54:	000a061b          	sext.w	a2,s4
    80002a58:	85ce                	mv	a1,s3
    80002a5a:	854a                	mv	a0,s2
    80002a5c:	ffffe097          	auipc	ra,0xffffe
    80002a60:	2e4080e7          	jalr	740(ra) # 80000d40 <memmove>
    return 0;
    80002a64:	8526                	mv	a0,s1
    80002a66:	bff9                	j	80002a44 <either_copyout+0x32>

0000000080002a68 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002a68:	7179                	addi	sp,sp,-48
    80002a6a:	f406                	sd	ra,40(sp)
    80002a6c:	f022                	sd	s0,32(sp)
    80002a6e:	ec26                	sd	s1,24(sp)
    80002a70:	e84a                	sd	s2,16(sp)
    80002a72:	e44e                	sd	s3,8(sp)
    80002a74:	e052                	sd	s4,0(sp)
    80002a76:	1800                	addi	s0,sp,48
    80002a78:	892a                	mv	s2,a0
    80002a7a:	84ae                	mv	s1,a1
    80002a7c:	89b2                	mv	s3,a2
    80002a7e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a80:	fffff097          	auipc	ra,0xfffff
    80002a84:	ffc080e7          	jalr	-4(ra) # 80001a7c <myproc>
  if(user_src){
    80002a88:	c08d                	beqz	s1,80002aaa <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002a8a:	86d2                	mv	a3,s4
    80002a8c:	864e                	mv	a2,s3
    80002a8e:	85ca                	mv	a1,s2
    80002a90:	6128                	ld	a0,64(a0)
    80002a92:	fffff097          	auipc	ra,0xfffff
    80002a96:	c5e080e7          	jalr	-930(ra) # 800016f0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002a9a:	70a2                	ld	ra,40(sp)
    80002a9c:	7402                	ld	s0,32(sp)
    80002a9e:	64e2                	ld	s1,24(sp)
    80002aa0:	6942                	ld	s2,16(sp)
    80002aa2:	69a2                	ld	s3,8(sp)
    80002aa4:	6a02                	ld	s4,0(sp)
    80002aa6:	6145                	addi	sp,sp,48
    80002aa8:	8082                	ret
    memmove(dst, (char*)src, len);
    80002aaa:	000a061b          	sext.w	a2,s4
    80002aae:	85ce                	mv	a1,s3
    80002ab0:	854a                	mv	a0,s2
    80002ab2:	ffffe097          	auipc	ra,0xffffe
    80002ab6:	28e080e7          	jalr	654(ra) # 80000d40 <memmove>
    return 0;
    80002aba:	8526                	mv	a0,s1
    80002abc:	bff9                	j	80002a9a <either_copyin+0x32>

0000000080002abe <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002abe:	715d                	addi	sp,sp,-80
    80002ac0:	e486                	sd	ra,72(sp)
    80002ac2:	e0a2                	sd	s0,64(sp)
    80002ac4:	fc26                	sd	s1,56(sp)
    80002ac6:	f84a                	sd	s2,48(sp)
    80002ac8:	f44e                	sd	s3,40(sp)
    80002aca:	f052                	sd	s4,32(sp)
    80002acc:	ec56                	sd	s5,24(sp)
    80002ace:	e85a                	sd	s6,16(sp)
    80002ad0:	e45e                	sd	s7,8(sp)
    80002ad2:	e062                	sd	s8,0(sp)
    80002ad4:	0880                	addi	s0,sp,80


  struct proc *p;
  char *state;

  printf("\n");
    80002ad6:	00006517          	auipc	a0,0x6
    80002ada:	7fa50513          	addi	a0,a0,2042 # 800092d0 <digits+0x290>
    80002ade:	ffffe097          	auipc	ra,0xffffe
    80002ae2:	a9a080e7          	jalr	-1382(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002ae6:	00010497          	auipc	s1,0x10
    80002aea:	d1a48493          	addi	s1,s1,-742 # 80012800 <proc+0xd8>
    80002aee:	00031997          	auipc	s3,0x31
    80002af2:	f1298993          	addi	s3,s3,-238 # 80033a00 <bcache+0xc0>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002af6:	4b8d                	li	s7,3
      state = states[p->state];
    else
      state = "???";
    80002af8:	00007a17          	auipc	s4,0x7
    80002afc:	8b8a0a13          	addi	s4,s4,-1864 # 800093b0 <digits+0x370>
    printf("%d %s %s", p->pid, state, p->name);
    80002b00:	00007b17          	auipc	s6,0x7
    80002b04:	8b8b0b13          	addi	s6,s6,-1864 # 800093b8 <digits+0x378>
    printf("\n");
    80002b08:	00006a97          	auipc	s5,0x6
    80002b0c:	7c8a8a93          	addi	s5,s5,1992 # 800092d0 <digits+0x290>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b10:	00007c17          	auipc	s8,0x7
    80002b14:	968c0c13          	addi	s8,s8,-1688 # 80009478 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b18:	6905                	lui	s2,0x1
    80002b1a:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002b1e:	a005                	j	80002b3e <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    80002b20:	f4c6a583          	lw	a1,-180(a3)
    80002b24:	855a                	mv	a0,s6
    80002b26:	ffffe097          	auipc	ra,0xffffe
    80002b2a:	a52080e7          	jalr	-1454(ra) # 80000578 <printf>
    printf("\n");
    80002b2e:	8556                	mv	a0,s5
    80002b30:	ffffe097          	auipc	ra,0xffffe
    80002b34:	a48080e7          	jalr	-1464(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b38:	94ca                	add	s1,s1,s2
    80002b3a:	03348263          	beq	s1,s3,80002b5e <procdump+0xa0>
    if(p->state == UNUSED)
    80002b3e:	86a6                	mv	a3,s1
    80002b40:	f404a783          	lw	a5,-192(s1)
    80002b44:	dbf5                	beqz	a5,80002b38 <procdump+0x7a>
      state = "???";
    80002b46:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b48:	fcfbece3          	bltu	s7,a5,80002b20 <procdump+0x62>
    80002b4c:	02079713          	slli	a4,a5,0x20
    80002b50:	01d75793          	srli	a5,a4,0x1d
    80002b54:	97e2                	add	a5,a5,s8
    80002b56:	6390                	ld	a2,0(a5)
    80002b58:	f661                	bnez	a2,80002b20 <procdump+0x62>
      state = "???";
    80002b5a:	8652                	mv	a2,s4
    80002b5c:	b7d1                	j	80002b20 <procdump+0x62>
  }
}
    80002b5e:	60a6                	ld	ra,72(sp)
    80002b60:	6406                	ld	s0,64(sp)
    80002b62:	74e2                	ld	s1,56(sp)
    80002b64:	7942                	ld	s2,48(sp)
    80002b66:	79a2                	ld	s3,40(sp)
    80002b68:	7a02                	ld	s4,32(sp)
    80002b6a:	6ae2                	ld	s5,24(sp)
    80002b6c:	6b42                	ld	s6,16(sp)
    80002b6e:	6ba2                	ld	s7,8(sp)
    80002b70:	6c02                	ld	s8,0(sp)
    80002b72:	6161                	addi	sp,sp,80
    80002b74:	8082                	ret

0000000080002b76 <is_valid_sigmask>:

int 
is_valid_sigmask(int sigmask){
    80002b76:	1141                	addi	sp,sp,-16
    80002b78:	e422                	sd	s0,8(sp)
    80002b7a:	0800                	addi	s0,sp,16
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002b7c:	000207b7          	lui	a5,0x20
    80002b80:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002b84:	8d7d                	and	a0,a0,a5
    return 0;
  return 1;
}
    80002b86:	00153513          	seqz	a0,a0
    80002b8a:	6422                	ld	s0,8(sp)
    80002b8c:	0141                	addi	sp,sp,16
    80002b8e:	8082                	ret

0000000080002b90 <sigprocmask>:

uint
sigprocmask(uint new_procmask){
    80002b90:	7179                	addi	sp,sp,-48
    80002b92:	f406                	sd	ra,40(sp)
    80002b94:	f022                	sd	s0,32(sp)
    80002b96:	ec26                	sd	s1,24(sp)
    80002b98:	e84a                	sd	s2,16(sp)
    80002b9a:	e44e                	sd	s3,8(sp)
    80002b9c:	1800                	addi	s0,sp,48
    80002b9e:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002ba0:	fffff097          	auipc	ra,0xfffff
    80002ba4:	edc080e7          	jalr	-292(ra) # 80001a7c <myproc>
  if(is_valid_sigmask(new_procmask) == 0)
    80002ba8:	000207b7          	lui	a5,0x20
    80002bac:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002bb0:	00f977b3          	and	a5,s2,a5
    return -1;
    80002bb4:	59fd                	li	s3,-1
  if(is_valid_sigmask(new_procmask) == 0)
    80002bb6:	ef99                	bnez	a5,80002bd4 <sigprocmask+0x44>
    80002bb8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002bba:	ffffe097          	auipc	ra,0xffffe
    80002bbe:	00c080e7          	jalr	12(ra) # 80000bc6 <acquire>
  int old_procmask = p->signal_mask;
    80002bc2:	0ec4a983          	lw	s3,236(s1)
  p->signal_mask = new_procmask;
    80002bc6:	0f24a623          	sw	s2,236(s1)
  release(&p->lock);
    80002bca:	8526                	mv	a0,s1
    80002bcc:	ffffe097          	auipc	ra,0xffffe
    80002bd0:	0d0080e7          	jalr	208(ra) # 80000c9c <release>
  
  return old_procmask;
}
    80002bd4:	854e                	mv	a0,s3
    80002bd6:	70a2                	ld	ra,40(sp)
    80002bd8:	7402                	ld	s0,32(sp)
    80002bda:	64e2                	ld	s1,24(sp)
    80002bdc:	6942                	ld	s2,16(sp)
    80002bde:	69a2                	ld	s3,8(sp)
    80002be0:	6145                	addi	sp,sp,48
    80002be2:	8082                	ret

0000000080002be4 <sigaction>:

 
int 
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
  
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002be4:	0005079b          	sext.w	a5,a0
    80002be8:	477d                	li	a4,31
    80002bea:	0cf76a63          	bltu	a4,a5,80002cbe <sigaction+0xda>
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
    80002bee:	7139                	addi	sp,sp,-64
    80002bf0:	fc06                	sd	ra,56(sp)
    80002bf2:	f822                	sd	s0,48(sp)
    80002bf4:	f426                	sd	s1,40(sp)
    80002bf6:	f04a                	sd	s2,32(sp)
    80002bf8:	ec4e                	sd	s3,24(sp)
    80002bfa:	e852                	sd	s4,16(sp)
    80002bfc:	0080                	addi	s0,sp,64
    80002bfe:	84aa                	mv	s1,a0
    80002c00:	89ae                	mv	s3,a1
    80002c02:	8a32                	mv	s4,a2
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002c04:	37dd                	addiw	a5,a5,-9
    80002c06:	9bdd                	andi	a5,a5,-9
    80002c08:	2781                	sext.w	a5,a5
    80002c0a:	cfc5                	beqz	a5,80002cc2 <sigaction+0xde>
    80002c0c:	cdcd                	beqz	a1,80002cc6 <sigaction+0xe2>
    return -1;
  struct proc *p = myproc();
    80002c0e:	fffff097          	auipc	ra,0xfffff
    80002c12:	e6e080e7          	jalr	-402(ra) # 80001a7c <myproc>
    80002c16:	892a                	mv	s2,a0

  uint new_mask;
  copyin(p->pagetable, (char *)&new_mask, (uint64)&act->sigmask, sizeof(act->sigmask));
    80002c18:	4691                	li	a3,4
    80002c1a:	00898613          	addi	a2,s3,8
    80002c1e:	fcc40593          	addi	a1,s0,-52
    80002c22:	6128                	ld	a0,64(a0)
    80002c24:	fffff097          	auipc	ra,0xfffff
    80002c28:	acc080e7          	jalr	-1332(ra) # 800016f0 <copyin>
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002c2c:	fcc42703          	lw	a4,-52(s0)

  if(is_valid_sigmask(new_mask) == 0)
    80002c30:	000207b7          	lui	a5,0x20
    80002c34:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002c38:	8ff9                	and	a5,a5,a4
    80002c3a:	ebc1                	bnez	a5,80002cca <sigaction+0xe6>
    return -1;
  acquire(&p->lock);
    80002c3c:	854a                	mv	a0,s2
    80002c3e:	ffffe097          	auipc	ra,0xffffe
    80002c42:	f88080e7          	jalr	-120(ra) # 80000bc6 <acquire>

  if(oldact!=0){
    80002c46:	020a0b63          	beqz	s4,80002c7c <sigaction+0x98>
    copyout(p->pagetable, (uint64)&oldact->sa_handler, (char *)&p->signal_handlers[signum], sizeof(act->sa_handler));
    80002c4a:	01f48613          	addi	a2,s1,31
    80002c4e:	060e                	slli	a2,a2,0x3
    80002c50:	46a1                	li	a3,8
    80002c52:	964a                	add	a2,a2,s2
    80002c54:	85d2                	mv	a1,s4
    80002c56:	04093503          	ld	a0,64(s2)
    80002c5a:	fffff097          	auipc	ra,0xfffff
    80002c5e:	a0a080e7          	jalr	-1526(ra) # 80001664 <copyout>
    copyout(p->pagetable, (uint64)&oldact->sigmask, (char *)&p->handlers_sigmasks[signum], sizeof(uint));
    80002c62:	07e48613          	addi	a2,s1,126
    80002c66:	060a                	slli	a2,a2,0x2
    80002c68:	4691                	li	a3,4
    80002c6a:	964a                	add	a2,a2,s2
    80002c6c:	008a0593          	addi	a1,s4,8
    80002c70:	04093503          	ld	a0,64(s2)
    80002c74:	fffff097          	auipc	ra,0xfffff
    80002c78:	9f0080e7          	jalr	-1552(ra) # 80001664 <copyout>
  }

  p->handlers_sigmasks[signum]=new_mask;
    80002c7c:	07c48793          	addi	a5,s1,124
    80002c80:	078a                	slli	a5,a5,0x2
    80002c82:	97ca                	add	a5,a5,s2
    80002c84:	fcc42703          	lw	a4,-52(s0)
    80002c88:	c798                	sw	a4,8(a5)
  copyin(p->pagetable, (char *)&p->signal_handlers[signum], (uint64)&act->sa_handler, sizeof(act->sa_handler));
    80002c8a:	04fd                	addi	s1,s1,31
    80002c8c:	048e                	slli	s1,s1,0x3
    80002c8e:	46a1                	li	a3,8
    80002c90:	864e                	mv	a2,s3
    80002c92:	009905b3          	add	a1,s2,s1
    80002c96:	04093503          	ld	a0,64(s2)
    80002c9a:	fffff097          	auipc	ra,0xfffff
    80002c9e:	a56080e7          	jalr	-1450(ra) # 800016f0 <copyin>

  release(&p->lock);
    80002ca2:	854a                	mv	a0,s2
    80002ca4:	ffffe097          	auipc	ra,0xffffe
    80002ca8:	ff8080e7          	jalr	-8(ra) # 80000c9c <release>



  return 0;
    80002cac:	4501                	li	a0,0
}
    80002cae:	70e2                	ld	ra,56(sp)
    80002cb0:	7442                	ld	s0,48(sp)
    80002cb2:	74a2                	ld	s1,40(sp)
    80002cb4:	7902                	ld	s2,32(sp)
    80002cb6:	69e2                	ld	s3,24(sp)
    80002cb8:	6a42                	ld	s4,16(sp)
    80002cba:	6121                	addi	sp,sp,64
    80002cbc:	8082                	ret
    return -1;
    80002cbe:	557d                	li	a0,-1
}
    80002cc0:	8082                	ret
    return -1;
    80002cc2:	557d                	li	a0,-1
    80002cc4:	b7ed                	j	80002cae <sigaction+0xca>
    80002cc6:	557d                	li	a0,-1
    80002cc8:	b7dd                	j	80002cae <sigaction+0xca>
    return -1;
    80002cca:	557d                	li	a0,-1
    80002ccc:	b7cd                	j	80002cae <sigaction+0xca>

0000000080002cce <sigret>:

void 
sigret(void){
    80002cce:	1101                	addi	sp,sp,-32
    80002cd0:	ec06                	sd	ra,24(sp)
    80002cd2:	e822                	sd	s0,16(sp)
    80002cd4:	e426                	sd	s1,8(sp)
    80002cd6:	e04a                	sd	s2,0(sp)
    80002cd8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002cda:	fffff097          	auipc	ra,0xfffff
    80002cde:	da2080e7          	jalr	-606(ra) # 80001a7c <myproc>
    80002ce2:	84aa                	mv	s1,a0
  struct kthread *t=mykthread();
    80002ce4:	fffff097          	auipc	ra,0xfffff
    80002ce8:	dd8080e7          	jalr	-552(ra) # 80001abc <mykthread>
    80002cec:	892a                	mv	s2,a0

  copyin(p->pagetable, (char *)t->trapframe, (uint64)p->user_trapframe_backup, sizeof(struct trapframe));
    80002cee:	12000693          	li	a3,288
    80002cf2:	2784b603          	ld	a2,632(s1)
    80002cf6:	612c                	ld	a1,64(a0)
    80002cf8:	60a8                	ld	a0,64(s1)
    80002cfa:	fffff097          	auipc	ra,0xfffff
    80002cfe:	9f6080e7          	jalr	-1546(ra) # 800016f0 <copyin>

  // restore user stack pointer
  acquire(&p->lock);
    80002d02:	8526                	mv	a0,s1
    80002d04:	ffffe097          	auipc	ra,0xffffe
    80002d08:	ec2080e7          	jalr	-318(ra) # 80000bc6 <acquire>
  // TODO maybe we will need to also lock the kthread lock
  t->trapframe->sp += sizeof(struct trapframe);
    80002d0c:	04093703          	ld	a4,64(s2)
    80002d10:	7b1c                	ld	a5,48(a4)
    80002d12:	12078793          	addi	a5,a5,288
    80002d16:	fb1c                	sd	a5,48(a4)

  p->signal_mask = p->signal_mask_backup;
    80002d18:	0f04a783          	lw	a5,240(s1)
    80002d1c:	0ef4a623          	sw	a5,236(s1)
  
  // Allow user signal handler since we finished handling the current
  p->handling_user_sig_flag = 0;
    80002d20:	2804a023          	sw	zero,640(s1)
  // Allow other thread to react to signals
  p->handling_sig_flag = 0;
    80002d24:	2804a223          	sw	zero,644(s1)
  release(&p->lock);
    80002d28:	8526                	mv	a0,s1
    80002d2a:	ffffe097          	auipc	ra,0xffffe
    80002d2e:	f72080e7          	jalr	-142(ra) # 80000c9c <release>
}
    80002d32:	60e2                	ld	ra,24(sp)
    80002d34:	6442                	ld	s0,16(sp)
    80002d36:	64a2                	ld	s1,8(sp)
    80002d38:	6902                	ld	s2,0(sp)
    80002d3a:	6105                	addi	sp,sp,32
    80002d3c:	8082                	ret

0000000080002d3e <turn_on_bit>:

// we call turn on and turn off when holding p->lock
void
turn_on_bit(struct proc* p, int signum){
    80002d3e:	1141                	addi	sp,sp,-16
    80002d40:	e422                	sd	s0,8(sp)
    80002d42:	0800                	addi	s0,sp,16
  if(!(p->pending_signals & (1 << signum)))
    80002d44:	0e852703          	lw	a4,232(a0)
    80002d48:	4785                	li	a5,1
    80002d4a:	00b795bb          	sllw	a1,a5,a1
    80002d4e:	00b777b3          	and	a5,a4,a1
    80002d52:	2781                	sext.w	a5,a5
    80002d54:	e781                	bnez	a5,80002d5c <turn_on_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    80002d56:	8db9                	xor	a1,a1,a4
    80002d58:	0eb52423          	sw	a1,232(a0)
}
    80002d5c:	6422                	ld	s0,8(sp)
    80002d5e:	0141                	addi	sp,sp,16
    80002d60:	8082                	ret

0000000080002d62 <kill>:
{
    80002d62:	7139                	addi	sp,sp,-64
    80002d64:	fc06                	sd	ra,56(sp)
    80002d66:	f822                	sd	s0,48(sp)
    80002d68:	f426                	sd	s1,40(sp)
    80002d6a:	f04a                	sd	s2,32(sp)
    80002d6c:	ec4e                	sd	s3,24(sp)
    80002d6e:	e852                	sd	s4,16(sp)
    80002d70:	e456                	sd	s5,8(sp)
    80002d72:	0080                	addi	s0,sp,64
    80002d74:	892a                	mv	s2,a0
    80002d76:	8aae                	mv	s5,a1
  for(p = proc; p < &proc[NPROC]; p++){
    80002d78:	00010497          	auipc	s1,0x10
    80002d7c:	9b048493          	addi	s1,s1,-1616 # 80012728 <proc>
    80002d80:	6985                	lui	s3,0x1
    80002d82:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002d86:	00031a17          	auipc	s4,0x31
    80002d8a:	ba2a0a13          	addi	s4,s4,-1118 # 80033928 <tickslock>
    acquire(&p->lock);
    80002d8e:	8526                	mv	a0,s1
    80002d90:	ffffe097          	auipc	ra,0xffffe
    80002d94:	e36080e7          	jalr	-458(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    80002d98:	50dc                	lw	a5,36(s1)
    80002d9a:	01278c63          	beq	a5,s2,80002db2 <kill+0x50>
    release(&p->lock);
    80002d9e:	8526                	mv	a0,s1
    80002da0:	ffffe097          	auipc	ra,0xffffe
    80002da4:	efc080e7          	jalr	-260(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002da8:	94ce                	add	s1,s1,s3
    80002daa:	ff4492e3          	bne	s1,s4,80002d8e <kill+0x2c>
  return -1;
    80002dae:	557d                	li	a0,-1
    80002db0:	a049                	j	80002e32 <kill+0xd0>
      if(p->state != RUNNABLE){
    80002db2:	4c98                	lw	a4,24(s1)
    80002db4:	4789                	li	a5,2
    80002db6:	06f71863          	bne	a4,a5,80002e26 <kill+0xc4>
      if(p->signal_handlers[signum] == (void*)SIG_IGN){
    80002dba:	01ea8793          	addi	a5,s5,30
    80002dbe:	078e                	slli	a5,a5,0x3
    80002dc0:	97a6                	add	a5,a5,s1
    80002dc2:	6798                	ld	a4,8(a5)
    80002dc4:	4785                	li	a5,1
    80002dc6:	06f70f63          	beq	a4,a5,80002e44 <kill+0xe2>
      turn_on_bit(p,signum);
    80002dca:	85d6                	mv	a1,s5
    80002dcc:	8526                	mv	a0,s1
    80002dce:	00000097          	auipc	ra,0x0
    80002dd2:	f70080e7          	jalr	-144(ra) # 80002d3e <turn_on_bit>
      release(&p->lock);
    80002dd6:	8526                	mv	a0,s1
    80002dd8:	ffffe097          	auipc	ra,0xffffe
    80002ddc:	ec4080e7          	jalr	-316(ra) # 80000c9c <release>
      if(signum == SIGKILL){
    80002de0:	47a5                	li	a5,9
      return 0;
    80002de2:	4501                	li	a0,0
      if(signum == SIGKILL){
    80002de4:	04fa9763          	bne	s5,a5,80002e32 <kill+0xd0>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002de8:	28848913          	addi	s2,s1,648
    80002dec:	6785                	lui	a5,0x1
    80002dee:	84878793          	addi	a5,a5,-1976 # 848 <_entry-0x7ffff7b8>
    80002df2:	94be                	add	s1,s1,a5
          if(t->state == RUNNABLE){
    80002df4:	4989                	li	s3,2
    80002df6:	01892783          	lw	a5,24(s2)
    80002dfa:	07378363          	beq	a5,s3,80002e60 <kill+0xfe>
            acquire(&t->lock);
    80002dfe:	854a                	mv	a0,s2
    80002e00:	ffffe097          	auipc	ra,0xffffe
    80002e04:	dc6080e7          	jalr	-570(ra) # 80000bc6 <acquire>
            if(t->state==TSLEEPING){
    80002e08:	01892783          	lw	a5,24(s2)
    80002e0c:	05378363          	beq	a5,s3,80002e52 <kill+0xf0>
            release(&t->lock);
    80002e10:	854a                	mv	a0,s2
    80002e12:	ffffe097          	auipc	ra,0xffffe
    80002e16:	e8a080e7          	jalr	-374(ra) # 80000c9c <release>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002e1a:	0b890913          	addi	s2,s2,184
    80002e1e:	fc991ce3          	bne	s2,s1,80002df6 <kill+0x94>
      return 0;
    80002e22:	4501                	li	a0,0
    80002e24:	a039                	j	80002e32 <kill+0xd0>
        release(&p->lock);
    80002e26:	8526                	mv	a0,s1
    80002e28:	ffffe097          	auipc	ra,0xffffe
    80002e2c:	e74080e7          	jalr	-396(ra) # 80000c9c <release>
        return -1;
    80002e30:	557d                	li	a0,-1
}
    80002e32:	70e2                	ld	ra,56(sp)
    80002e34:	7442                	ld	s0,48(sp)
    80002e36:	74a2                	ld	s1,40(sp)
    80002e38:	7902                	ld	s2,32(sp)
    80002e3a:	69e2                	ld	s3,24(sp)
    80002e3c:	6a42                	ld	s4,16(sp)
    80002e3e:	6aa2                	ld	s5,8(sp)
    80002e40:	6121                	addi	sp,sp,64
    80002e42:	8082                	ret
        release(&p->lock);
    80002e44:	8526                	mv	a0,s1
    80002e46:	ffffe097          	auipc	ra,0xffffe
    80002e4a:	e56080e7          	jalr	-426(ra) # 80000c9c <release>
        return 1;
    80002e4e:	4505                	li	a0,1
    80002e50:	b7cd                	j	80002e32 <kill+0xd0>
              release(&t->lock);
    80002e52:	854a                	mv	a0,s2
    80002e54:	ffffe097          	auipc	ra,0xffffe
    80002e58:	e48080e7          	jalr	-440(ra) # 80000c9c <release>
      return 0;
    80002e5c:	4501                	li	a0,0
              break;
    80002e5e:	bfd1                	j	80002e32 <kill+0xd0>
      return 0;
    80002e60:	4501                	li	a0,0
    80002e62:	bfc1                	j	80002e32 <kill+0xd0>

0000000080002e64 <turn_off_bit>:

void
turn_off_bit(struct proc* p, int signum){
    80002e64:	1141                	addi	sp,sp,-16
    80002e66:	e422                	sd	s0,8(sp)
    80002e68:	0800                	addi	s0,sp,16
  if(p->pending_signals & (1 << signum))
    80002e6a:	0e852703          	lw	a4,232(a0)
    80002e6e:	4785                	li	a5,1
    80002e70:	00b795bb          	sllw	a1,a5,a1
    80002e74:	00b777b3          	and	a5,a4,a1
    80002e78:	2781                	sext.w	a5,a5
    80002e7a:	c781                	beqz	a5,80002e82 <turn_off_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    80002e7c:	8db9                	xor	a1,a1,a4
    80002e7e:	0eb52423          	sw	a1,232(a0)
}
    80002e82:	6422                	ld	s0,8(sp)
    80002e84:	0141                	addi	sp,sp,16
    80002e86:	8082                	ret

0000000080002e88 <kthread_create>:

int kthread_create(void (*start_func)(), void *stack){
    80002e88:	7139                	addi	sp,sp,-64
    80002e8a:	fc06                	sd	ra,56(sp)
    80002e8c:	f822                	sd	s0,48(sp)
    80002e8e:	f426                	sd	s1,40(sp)
    80002e90:	f04a                	sd	s2,32(sp)
    80002e92:	ec4e                	sd	s3,24(sp)
    80002e94:	e852                	sd	s4,16(sp)
    80002e96:	e456                	sd	s5,8(sp)
    80002e98:	e05a                	sd	s6,0(sp)
    80002e9a:	0080                	addi	s0,sp,64
    80002e9c:	8b2a                	mv	s6,a0
    80002e9e:	8aae                	mv	s5,a1
  struct proc *p = myproc();
    80002ea0:	fffff097          	auipc	ra,0xfffff
    80002ea4:	bdc080e7          	jalr	-1060(ra) # 80001a7c <myproc>
    80002ea8:	8a2a                	mv	s4,a0
  struct kthread *curr_t = mykthread();
    80002eaa:	fffff097          	auipc	ra,0xfffff
    80002eae:	c12080e7          	jalr	-1006(ra) # 80001abc <mykthread>
    80002eb2:	89aa                	mv	s3,a0
  struct kthread *other_t;

  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    80002eb4:	288a0493          	addi	s1,s4,648
    80002eb8:	6905                	lui	s2,0x1
    80002eba:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002ebe:	9952                	add	s2,s2,s4
    80002ec0:	a861                	j	80002f58 <kthread_create+0xd0>
  t->tid = 0;
    80002ec2:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80002ec6:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80002eca:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80002ece:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80002ed2:	0004ac23          	sw	zero,24(s1)

    if(curr_t != other_t){
      acquire(&other_t->lock);
      if(other_t->state == TUNUSED){
          freethread(other_t);  // free memory in case this thread entry was previously used
          init_thread(other_t);
    80002ed6:	8526                	mv	a0,s1
    80002ed8:	fffff097          	auipc	ra,0xfffff
    80002edc:	cf6080e7          	jalr	-778(ra) # 80001bce <init_thread>
          
          
          *(other_t->trapframe) = *(curr_t->trapframe);
    80002ee0:	0409b683          	ld	a3,64(s3)
    80002ee4:	87b6                	mv	a5,a3
    80002ee6:	60b8                	ld	a4,64(s1)
    80002ee8:	12068693          	addi	a3,a3,288
    80002eec:	0007b803          	ld	a6,0(a5)
    80002ef0:	6788                	ld	a0,8(a5)
    80002ef2:	6b8c                	ld	a1,16(a5)
    80002ef4:	6f90                	ld	a2,24(a5)
    80002ef6:	01073023          	sd	a6,0(a4) # 20000 <_entry-0x7ffe0000>
    80002efa:	e708                	sd	a0,8(a4)
    80002efc:	eb0c                	sd	a1,16(a4)
    80002efe:	ef10                	sd	a2,24(a4)
    80002f00:	02078793          	addi	a5,a5,32
    80002f04:	02070713          	addi	a4,a4,32
    80002f08:	fed792e3          	bne	a5,a3,80002eec <kthread_create+0x64>
          other_t->trapframe->sp = (uint64)stack + MAX_STACK_SIZE-16;
    80002f0c:	60b8                	ld	a4,64(s1)
    80002f0e:	6785                	lui	a5,0x1
    80002f10:	f9078793          	addi	a5,a5,-112 # f90 <_entry-0x7ffff070>
    80002f14:	9abe                	add	s5,s5,a5
    80002f16:	03573823          	sd	s5,48(a4)

          other_t->trapframe->epc = (uint64)start_func;
    80002f1a:	60bc                	ld	a5,64(s1)
    80002f1c:	0167bc23          	sd	s6,24(a5)
          release(&other_t->lock);
    80002f20:	8526                	mv	a0,s1
    80002f22:	ffffe097          	auipc	ra,0xffffe
    80002f26:	d7a080e7          	jalr	-646(ra) # 80000c9c <release>
          acquire(&p->lock);
    80002f2a:	8552                	mv	a0,s4
    80002f2c:	ffffe097          	auipc	ra,0xffffe
    80002f30:	c9a080e7          	jalr	-870(ra) # 80000bc6 <acquire>
          p->active_threads++;
    80002f34:	028a2783          	lw	a5,40(s4)
    80002f38:	2785                	addiw	a5,a5,1
    80002f3a:	02fa2423          	sw	a5,40(s4)
          release(&p->lock);
    80002f3e:	8552                	mv	a0,s4
    80002f40:	ffffe097          	auipc	ra,0xffffe
    80002f44:	d5c080e7          	jalr	-676(ra) # 80000c9c <release>
          other_t->state = TRUNNABLE;
    80002f48:	478d                	li	a5,3
    80002f4a:	cc9c                	sw	a5,24(s1)
          return other_t->tid;
    80002f4c:	5888                	lw	a0,48(s1)
    80002f4e:	a02d                	j	80002f78 <kthread_create+0xf0>
  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    80002f50:	0b848493          	addi	s1,s1,184
    80002f54:	02990163          	beq	s2,s1,80002f76 <kthread_create+0xee>
    if(curr_t != other_t){
    80002f58:	fe998ce3          	beq	s3,s1,80002f50 <kthread_create+0xc8>
      acquire(&other_t->lock);
    80002f5c:	8526                	mv	a0,s1
    80002f5e:	ffffe097          	auipc	ra,0xffffe
    80002f62:	c68080e7          	jalr	-920(ra) # 80000bc6 <acquire>
      if(other_t->state == TUNUSED){
    80002f66:	4c9c                	lw	a5,24(s1)
    80002f68:	dfa9                	beqz	a5,80002ec2 <kthread_create+0x3a>
      }
      release(&other_t->lock);
    80002f6a:	8526                	mv	a0,s1
    80002f6c:	ffffe097          	auipc	ra,0xffffe
    80002f70:	d30080e7          	jalr	-720(ra) # 80000c9c <release>
    80002f74:	bff1                	j	80002f50 <kthread_create+0xc8>
    }
  }
  return -1;
    80002f76:	557d                	li	a0,-1
}
    80002f78:	70e2                	ld	ra,56(sp)
    80002f7a:	7442                	ld	s0,48(sp)
    80002f7c:	74a2                	ld	s1,40(sp)
    80002f7e:	7902                	ld	s2,32(sp)
    80002f80:	69e2                	ld	s3,24(sp)
    80002f82:	6a42                	ld	s4,16(sp)
    80002f84:	6aa2                	ld	s5,8(sp)
    80002f86:	6b02                	ld	s6,0(sp)
    80002f88:	6121                	addi	sp,sp,64
    80002f8a:	8082                	ret

0000000080002f8c <kthread_join>:



int
kthread_join(int thread_id, int* status){
    80002f8c:	715d                	addi	sp,sp,-80
    80002f8e:	e486                	sd	ra,72(sp)
    80002f90:	e0a2                	sd	s0,64(sp)
    80002f92:	fc26                	sd	s1,56(sp)
    80002f94:	f84a                	sd	s2,48(sp)
    80002f96:	f44e                	sd	s3,40(sp)
    80002f98:	f052                	sd	s4,32(sp)
    80002f9a:	ec56                	sd	s5,24(sp)
    80002f9c:	e85a                	sd	s6,16(sp)
    80002f9e:	e45e                	sd	s7,8(sp)
    80002fa0:	0880                	addi	s0,sp,80
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
    80002fba:	17478a63          	beq	a5,s4,8000312e <kthread_join+0x1a2>
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
    80002fdc:	a039                	j	80002fea <kthread_join+0x5e>
    80002fde:	84ca                	mv	s1,s2
    80002fe0:	a825                	j	80003018 <kthread_join+0x8c>
    80002fe2:	0b890913          	addi	s2,s2,184
    80002fe6:	02990363          	beq	s2,s1,8000300c <kthread_join+0x80>
    if(nt != t){
    80002fea:	ff298ce3          	beq	s3,s2,80002fe2 <kthread_join+0x56>
      acquire(&nt->lock);
    80002fee:	854a                	mv	a0,s2
    80002ff0:	ffffe097          	auipc	ra,0xffffe
    80002ff4:	bd6080e7          	jalr	-1066(ra) # 80000bc6 <acquire>

      if(nt->tid == thread_id){
    80002ff8:	03092783          	lw	a5,48(s2)
    80002ffc:	ff4781e3          	beq	a5,s4,80002fde <kthread_join+0x52>
        //found target thread 
        goto found;
      }
      release(&nt->lock);
    80003000:	854a                	mv	a0,s2
    80003002:	ffffe097          	auipc	ra,0xffffe
    80003006:	c9a080e7          	jalr	-870(ra) # 80000c9c <release>
    8000300a:	bfe1                	j	80002fe2 <kthread_join+0x56>
    }
  }

  if(nt->tid != thread_id){
    8000300c:	6785                	lui	a5,0x1
    8000300e:	97d6                	add	a5,a5,s5
    80003010:	8787a783          	lw	a5,-1928(a5) # 878 <_entry-0x7ffff788>
    80003014:	09479c63          	bne	a5,s4,800030ac <kthread_join+0x120>
  found:
  // printf("%d:join to %d\n",p->pid,thread_id);  // TODO delete
  // Wait for thread to terminate
  // still holding nt lock
  for(;;){
      if(nt->state==TZOMBIE){
    80003018:	4c9c                	lw	a5,24(s1)
    8000301a:	4715                	li	a4,5
    8000301c:	04e78163          	beq	a5,a4,8000305e <kthread_join+0xd2>
      release(&nt->lock);
      release(&wait_lock);
      return -1;
    }
    release(&nt->lock);
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    80003020:	0000fb97          	auipc	s7,0xf
    80003024:	2b0b8b93          	addi	s7,s7,688 # 800122d0 <wait_lock>
      if(nt->state==TZOMBIE){
    80003028:	4915                	li	s2,5
      else if(nt->state==TUNUSED){ // in case someone already free that thread
    8000302a:	cbd5                	beqz	a5,800030de <kthread_join+0x152>
    if(t->killed || nt->tid!=thread_id){
    8000302c:	0289a783          	lw	a5,40(s3)
    80003030:	e3e5                	bnez	a5,80003110 <kthread_join+0x184>
    80003032:	589c                	lw	a5,48(s1)
    80003034:	0d479e63          	bne	a5,s4,80003110 <kthread_join+0x184>
    release(&nt->lock);
    80003038:	8526                	mv	a0,s1
    8000303a:	ffffe097          	auipc	ra,0xffffe
    8000303e:	c62080e7          	jalr	-926(ra) # 80000c9c <release>
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    80003042:	85de                	mv	a1,s7
    80003044:	8526                	mv	a0,s1
    80003046:	fffff097          	auipc	ra,0xfffff
    8000304a:	402080e7          	jalr	1026(ra) # 80002448 <sleep>
    acquire(&nt->lock);
    8000304e:	8526                	mv	a0,s1
    80003050:	ffffe097          	auipc	ra,0xffffe
    80003054:	b76080e7          	jalr	-1162(ra) # 80000bc6 <acquire>
      if(nt->state==TZOMBIE){
    80003058:	4c9c                	lw	a5,24(s1)
    8000305a:	fd2798e3          	bne	a5,s2,8000302a <kthread_join+0x9e>
        if(status != 0 && copyout(p->pagetable, status, (char *)&nt->xstate,sizeof(nt->xstate)) < 0) {
    8000305e:	000b0e63          	beqz	s6,8000307a <kthread_join+0xee>
    80003062:	4691                	li	a3,4
    80003064:	02c48613          	addi	a2,s1,44
    80003068:	85da                	mv	a1,s6
    8000306a:	040ab503          	ld	a0,64(s5)
    8000306e:	ffffe097          	auipc	ra,0xffffe
    80003072:	5f6080e7          	jalr	1526(ra) # 80001664 <copyout>
    80003076:	04054563          	bltz	a0,800030c0 <kthread_join+0x134>
  t->tid = 0;
    8000307a:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    8000307e:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80003082:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80003086:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    8000308a:	0004ac23          	sw	zero,24(s1)
        release(&nt->lock);
    8000308e:	8526                	mv	a0,s1
    80003090:	ffffe097          	auipc	ra,0xffffe
    80003094:	c0c080e7          	jalr	-1012(ra) # 80000c9c <release>
        release(&wait_lock);  //  successfull join     
    80003098:	0000f517          	auipc	a0,0xf
    8000309c:	23850513          	addi	a0,a0,568 # 800122d0 <wait_lock>
    800030a0:	ffffe097          	auipc	ra,0xffffe
    800030a4:	bfc080e7          	jalr	-1028(ra) # 80000c9c <release>
        return 0;
    800030a8:	4501                	li	a0,0
    800030aa:	a059                	j	80003130 <kthread_join+0x1a4>
    release(&wait_lock);
    800030ac:	0000f517          	auipc	a0,0xf
    800030b0:	22450513          	addi	a0,a0,548 # 800122d0 <wait_lock>
    800030b4:	ffffe097          	auipc	ra,0xffffe
    800030b8:	be8080e7          	jalr	-1048(ra) # 80000c9c <release>
    return -1;
    800030bc:	557d                	li	a0,-1
    800030be:	a88d                	j	80003130 <kthread_join+0x1a4>
           release(&nt->lock);
    800030c0:	8526                	mv	a0,s1
    800030c2:	ffffe097          	auipc	ra,0xffffe
    800030c6:	bda080e7          	jalr	-1062(ra) # 80000c9c <release>
           release(&wait_lock);
    800030ca:	0000f517          	auipc	a0,0xf
    800030ce:	20650513          	addi	a0,a0,518 # 800122d0 <wait_lock>
    800030d2:	ffffe097          	auipc	ra,0xffffe
    800030d6:	bca080e7          	jalr	-1078(ra) # 80000c9c <release>
           return -1;                   
    800030da:	557d                	li	a0,-1
    800030dc:	a891                	j	80003130 <kthread_join+0x1a4>
  t->tid = 0;
    800030de:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    800030e2:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    800030e6:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    800030ea:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    800030ee:	0004ac23          	sw	zero,24(s1)
        release(&nt->lock);
    800030f2:	8526                	mv	a0,s1
    800030f4:	ffffe097          	auipc	ra,0xffffe
    800030f8:	ba8080e7          	jalr	-1112(ra) # 80000c9c <release>
        release(&wait_lock);  //  successfull join
    800030fc:	0000f517          	auipc	a0,0xf
    80003100:	1d450513          	addi	a0,a0,468 # 800122d0 <wait_lock>
    80003104:	ffffe097          	auipc	ra,0xffffe
    80003108:	b98080e7          	jalr	-1128(ra) # 80000c9c <release>
        return 1; //thread already exited
    8000310c:	4505                	li	a0,1
    8000310e:	a00d                	j	80003130 <kthread_join+0x1a4>
      release(&nt->lock);
    80003110:	8526                	mv	a0,s1
    80003112:	ffffe097          	auipc	ra,0xffffe
    80003116:	b8a080e7          	jalr	-1142(ra) # 80000c9c <release>
      release(&wait_lock);
    8000311a:	0000f517          	auipc	a0,0xf
    8000311e:	1b650513          	addi	a0,a0,438 # 800122d0 <wait_lock>
    80003122:	ffffe097          	auipc	ra,0xffffe
    80003126:	b7a080e7          	jalr	-1158(ra) # 80000c9c <release>
      return -1;
    8000312a:	557d                	li	a0,-1
    8000312c:	a011                	j	80003130 <kthread_join+0x1a4>
    return -1;
    8000312e:	557d                	li	a0,-1
  }
}
    80003130:	60a6                	ld	ra,72(sp)
    80003132:	6406                	ld	s0,64(sp)
    80003134:	74e2                	ld	s1,56(sp)
    80003136:	7942                	ld	s2,48(sp)
    80003138:	79a2                	ld	s3,40(sp)
    8000313a:	7a02                	ld	s4,32(sp)
    8000313c:	6ae2                	ld	s5,24(sp)
    8000313e:	6b42                	ld	s6,16(sp)
    80003140:	6ba2                	ld	s7,8(sp)
    80003142:	6161                	addi	sp,sp,80
    80003144:	8082                	ret

0000000080003146 <kthread_join_all>:

int
kthread_join_all(){
    80003146:	7179                	addi	sp,sp,-48
    80003148:	f406                	sd	ra,40(sp)
    8000314a:	f022                	sd	s0,32(sp)
    8000314c:	ec26                	sd	s1,24(sp)
    8000314e:	e84a                	sd	s2,16(sp)
    80003150:	e44e                	sd	s3,8(sp)
    80003152:	e052                	sd	s4,0(sp)
    80003154:	1800                	addi	s0,sp,48
  struct proc *p=myproc();
    80003156:	fffff097          	auipc	ra,0xfffff
    8000315a:	926080e7          	jalr	-1754(ra) # 80001a7c <myproc>
    8000315e:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    80003160:	fffff097          	auipc	ra,0xfffff
    80003164:	95c080e7          	jalr	-1700(ra) # 80001abc <mykthread>
    80003168:	8a2a                	mv	s4,a0
  struct kthread *nt;
  int res = 1;
  for(nt = p->kthreads; nt < &p->kthreads[NTHREAD]; nt++){
    8000316a:	28898493          	addi	s1,s3,648
    8000316e:	6505                	lui	a0,0x1
    80003170:	84850513          	addi	a0,a0,-1976 # 848 <_entry-0x7ffff7b8>
    80003174:	99aa                	add	s3,s3,a0
  int res = 1;
    80003176:	4905                	li	s2,1
    80003178:	a029                	j	80003182 <kthread_join_all+0x3c>
  for(nt = p->kthreads; nt < &p->kthreads[NTHREAD]; nt++){
    8000317a:	0b848493          	addi	s1,s1,184
    8000317e:	00998e63          	beq	s3,s1,8000319a <kthread_join_all+0x54>
    if(nt != t){
    80003182:	fe9a0ce3          	beq	s4,s1,8000317a <kthread_join_all+0x34>
      res &= kthread_join(nt->tid,0);
    80003186:	4581                	li	a1,0
    80003188:	5888                	lw	a0,48(s1)
    8000318a:	00000097          	auipc	ra,0x0
    8000318e:	e02080e7          	jalr	-510(ra) # 80002f8c <kthread_join>
    80003192:	01257933          	and	s2,a0,s2
    80003196:	2901                	sext.w	s2,s2
    80003198:	b7cd                	j	8000317a <kthread_join_all+0x34>
    }
  }

  return res;
}
    8000319a:	854a                	mv	a0,s2
    8000319c:	70a2                	ld	ra,40(sp)
    8000319e:	7402                	ld	s0,32(sp)
    800031a0:	64e2                	ld	s1,24(sp)
    800031a2:	6942                	ld	s2,16(sp)
    800031a4:	69a2                	ld	s3,8(sp)
    800031a6:	6a02                	ld	s4,0(sp)
    800031a8:	6145                	addi	sp,sp,48
    800031aa:	8082                	ret

00000000800031ac <printTF>:


void 
printTF(struct kthread *t){//function for debuging, TODO delete
    800031ac:	7175                	addi	sp,sp,-144
    800031ae:	e506                	sd	ra,136(sp)
    800031b0:	e122                	sd	s0,128(sp)
    800031b2:	fca6                	sd	s1,120(sp)
    800031b4:	0900                	addi	s0,sp,144
    800031b6:	84aa                	mv	s1,a0
  printf("**************tid=%d*****************\n",t->tid);
    800031b8:	590c                	lw	a1,48(a0)
    800031ba:	00006517          	auipc	a0,0x6
    800031be:	20e50513          	addi	a0,a0,526 # 800093c8 <digits+0x388>
    800031c2:	ffffd097          	auipc	ra,0xffffd
    800031c6:	3b6080e7          	jalr	950(ra) # 80000578 <printf>
  // printf("t->tf->epc = %p\n",t->trapframe->epc);
  // printf("t->tf->ra = %p\n",t->trapframe->ra);
  // printf("t->tf->kernel_sp = %p\n",t->trapframe->kernel_sp);
  printf("t->kstack = %p\n",t->kstack);
    800031ca:	7c8c                	ld	a1,56(s1)
    800031cc:	00006517          	auipc	a0,0x6
    800031d0:	22450513          	addi	a0,a0,548 # 800093f0 <digits+0x3b0>
    800031d4:	ffffd097          	auipc	ra,0xffffd
    800031d8:	3a4080e7          	jalr	932(ra) # 80000578 <printf>
  printf("t->context = %p\n",t->context);
    800031dc:	04848793          	addi	a5,s1,72
    800031e0:	f7040713          	addi	a4,s0,-144
    800031e4:	0a848693          	addi	a3,s1,168
    800031e8:	0007b803          	ld	a6,0(a5)
    800031ec:	6788                	ld	a0,8(a5)
    800031ee:	6b8c                	ld	a1,16(a5)
    800031f0:	6f90                	ld	a2,24(a5)
    800031f2:	01073023          	sd	a6,0(a4)
    800031f6:	e708                	sd	a0,8(a4)
    800031f8:	eb0c                	sd	a1,16(a4)
    800031fa:	ef10                	sd	a2,24(a4)
    800031fc:	02078793          	addi	a5,a5,32
    80003200:	02070713          	addi	a4,a4,32
    80003204:	fed792e3          	bne	a5,a3,800031e8 <printTF+0x3c>
    80003208:	6394                	ld	a3,0(a5)
    8000320a:	679c                	ld	a5,8(a5)
    8000320c:	e314                	sd	a3,0(a4)
    8000320e:	e71c                	sd	a5,8(a4)
    80003210:	f7040593          	addi	a1,s0,-144
    80003214:	00006517          	auipc	a0,0x6
    80003218:	1ec50513          	addi	a0,a0,492 # 80009400 <digits+0x3c0>
    8000321c:	ffffd097          	auipc	ra,0xffffd
    80003220:	35c080e7          	jalr	860(ra) # 80000578 <printf>
  printf("t->tf->sp = %p\n",t->trapframe->sp);
    80003224:	60bc                	ld	a5,64(s1)
    80003226:	7b8c                	ld	a1,48(a5)
    80003228:	00006517          	auipc	a0,0x6
    8000322c:	1f050513          	addi	a0,a0,496 # 80009418 <digits+0x3d8>
    80003230:	ffffd097          	auipc	ra,0xffffd
    80003234:	348080e7          	jalr	840(ra) # 80000578 <printf>
  printf("t->state = %d\n",t->state);
    80003238:	4c8c                	lw	a1,24(s1)
    8000323a:	00006517          	auipc	a0,0x6
    8000323e:	1ee50513          	addi	a0,a0,494 # 80009428 <digits+0x3e8>
    80003242:	ffffd097          	auipc	ra,0xffffd
    80003246:	336080e7          	jalr	822(ra) # 80000578 <printf>
  printf("**************************************\n",t->tid);
    8000324a:	588c                	lw	a1,48(s1)
    8000324c:	00006517          	auipc	a0,0x6
    80003250:	1ec50513          	addi	a0,a0,492 # 80009438 <digits+0x3f8>
    80003254:	ffffd097          	auipc	ra,0xffffd
    80003258:	324080e7          	jalr	804(ra) # 80000578 <printf>

    8000325c:	60aa                	ld	ra,136(sp)
    8000325e:	640a                	ld	s0,128(sp)
    80003260:	74e6                	ld	s1,120(sp)
    80003262:	6149                	addi	sp,sp,144
    80003264:	8082                	ret

0000000080003266 <swtch>:
    80003266:	00153023          	sd	ra,0(a0)
    8000326a:	00253423          	sd	sp,8(a0)
    8000326e:	e900                	sd	s0,16(a0)
    80003270:	ed04                	sd	s1,24(a0)
    80003272:	03253023          	sd	s2,32(a0)
    80003276:	03353423          	sd	s3,40(a0)
    8000327a:	03453823          	sd	s4,48(a0)
    8000327e:	03553c23          	sd	s5,56(a0)
    80003282:	05653023          	sd	s6,64(a0)
    80003286:	05753423          	sd	s7,72(a0)
    8000328a:	05853823          	sd	s8,80(a0)
    8000328e:	05953c23          	sd	s9,88(a0)
    80003292:	07a53023          	sd	s10,96(a0)
    80003296:	07b53423          	sd	s11,104(a0)
    8000329a:	0005b083          	ld	ra,0(a1)
    8000329e:	0085b103          	ld	sp,8(a1)
    800032a2:	6980                	ld	s0,16(a1)
    800032a4:	6d84                	ld	s1,24(a1)
    800032a6:	0205b903          	ld	s2,32(a1)
    800032aa:	0285b983          	ld	s3,40(a1)
    800032ae:	0305ba03          	ld	s4,48(a1)
    800032b2:	0385ba83          	ld	s5,56(a1)
    800032b6:	0405bb03          	ld	s6,64(a1)
    800032ba:	0485bb83          	ld	s7,72(a1)
    800032be:	0505bc03          	ld	s8,80(a1)
    800032c2:	0585bc83          	ld	s9,88(a1)
    800032c6:	0605bd03          	ld	s10,96(a1)
    800032ca:	0685bd83          	ld	s11,104(a1)
    800032ce:	8082                	ret

00000000800032d0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800032d0:	1141                	addi	sp,sp,-16
    800032d2:	e406                	sd	ra,8(sp)
    800032d4:	e022                	sd	s0,0(sp)
    800032d6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800032d8:	00006597          	auipc	a1,0x6
    800032dc:	1c058593          	addi	a1,a1,448 # 80009498 <states.0+0x20>
    800032e0:	00030517          	auipc	a0,0x30
    800032e4:	64850513          	addi	a0,a0,1608 # 80033928 <tickslock>
    800032e8:	ffffe097          	auipc	ra,0xffffe
    800032ec:	84e080e7          	jalr	-1970(ra) # 80000b36 <initlock>
}
    800032f0:	60a2                	ld	ra,8(sp)
    800032f2:	6402                	ld	s0,0(sp)
    800032f4:	0141                	addi	sp,sp,16
    800032f6:	8082                	ret

00000000800032f8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800032f8:	1141                	addi	sp,sp,-16
    800032fa:	e422                	sd	s0,8(sp)
    800032fc:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800032fe:	00004797          	auipc	a5,0x4
    80003302:	ac278793          	addi	a5,a5,-1342 # 80006dc0 <kernelvec>
    80003306:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000330a:	6422                	ld	s0,8(sp)
    8000330c:	0141                	addi	sp,sp,16
    8000330e:	8082                	ret

0000000080003310 <check_should_cont>:
}

int 
check_should_cont(struct proc *p){
  for(int i=0;i<32;i++){
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    80003310:	0e852303          	lw	t1,232(a0)
    80003314:	0f850813          	addi	a6,a0,248
    80003318:	4685                	li	a3,1
    8000331a:	4701                	li	a4,0
    8000331c:	4885                	li	a7,1
  for(int i=0;i<32;i++){
    8000331e:	4e7d                	li	t3,31
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    80003320:	4ecd                	li	t4,19
    80003322:	a801                	j	80003332 <check_should_cont+0x22>
  for(int i=0;i<32;i++){
    80003324:	0006879b          	sext.w	a5,a3
    80003328:	04fe4663          	blt	t3,a5,80003374 <check_should_cont+0x64>
    8000332c:	2705                	addiw	a4,a4,1
    8000332e:	2685                	addiw	a3,a3,1
    80003330:	0821                	addi	a6,a6,8
    80003332:	0007059b          	sext.w	a1,a4
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    80003336:	00e8963b          	sllw	a2,a7,a4
    8000333a:	00c377b3          	and	a5,t1,a2
    8000333e:	2781                	sext.w	a5,a5
    80003340:	d3f5                	beqz	a5,80003324 <check_should_cont+0x14>
    80003342:	0ec52783          	lw	a5,236(a0)
    80003346:	8ff1                	and	a5,a5,a2
    80003348:	2781                	sext.w	a5,a5
    8000334a:	ffe9                	bnez	a5,80003324 <check_should_cont+0x14>
    8000334c:	00083783          	ld	a5,0(a6)
    80003350:	01d78563          	beq	a5,t4,8000335a <check_should_cont+0x4a>
    80003354:	fdd598e3          	bne	a1,t4,80003324 <check_should_cont+0x14>
          (i == SIGCONT && p->signal_handlers[i] == SIG_DFL))){
    80003358:	fbf1                	bnez	a5,8000332c <check_should_cont+0x1c>
check_should_cont(struct proc *p){
    8000335a:	1141                	addi	sp,sp,-16
    8000335c:	e406                	sd	ra,8(sp)
    8000335e:	e022                	sd	s0,0(sp)
    80003360:	0800                	addi	s0,sp,16
        turn_off_bit(p, i);
    80003362:	00000097          	auipc	ra,0x0
    80003366:	b02080e7          	jalr	-1278(ra) # 80002e64 <turn_off_bit>
        return 1;
    8000336a:	4505                	li	a0,1
      }
  }
  return 0;
}
    8000336c:	60a2                	ld	ra,8(sp)
    8000336e:	6402                	ld	s0,0(sp)
    80003370:	0141                	addi	sp,sp,16
    80003372:	8082                	ret
  return 0;
    80003374:	4501                	li	a0,0
}
    80003376:	8082                	ret

0000000080003378 <handle_stop>:



void
handle_stop(struct proc* p){
    80003378:	7139                	addi	sp,sp,-64
    8000337a:	fc06                	sd	ra,56(sp)
    8000337c:	f822                	sd	s0,48(sp)
    8000337e:	f426                	sd	s1,40(sp)
    80003380:	f04a                	sd	s2,32(sp)
    80003382:	ec4e                	sd	s3,24(sp)
    80003384:	e852                	sd	s4,16(sp)
    80003386:	e456                	sd	s5,8(sp)
    80003388:	e05a                	sd	s6,0(sp)
    8000338a:	0080                	addi	s0,sp,64
    8000338c:	89aa                	mv	s3,a0

  struct kthread *t;
  struct kthread *curr_t = mykthread();
    8000338e:	ffffe097          	auipc	ra,0xffffe
    80003392:	72e080e7          	jalr	1838(ra) # 80001abc <mykthread>
    80003396:	8aaa                	mv	s5,a0


  // Make all other threads belong to the same procces freeze 
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    80003398:	28898493          	addi	s1,s3,648
    8000339c:	6a05                	lui	s4,0x1
    8000339e:	848a0a13          	addi	s4,s4,-1976 # 848 <_entry-0x7ffff7b8>
    800033a2:	9a4e                	add	s4,s4,s3
    800033a4:	8926                	mv	s2,s1
    if(t!=curr_t){
      acquire(&t->lock);
      t->frozen=1;
    800033a6:	4b05                	li	s6,1
    800033a8:	a029                	j	800033b2 <handle_stop+0x3a>
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800033aa:	0b890913          	addi	s2,s2,184
    800033ae:	03490163          	beq	s2,s4,800033d0 <handle_stop+0x58>
    if(t!=curr_t){
    800033b2:	ff2a8ce3          	beq	s5,s2,800033aa <handle_stop+0x32>
      acquire(&t->lock);
    800033b6:	854a                	mv	a0,s2
    800033b8:	ffffe097          	auipc	ra,0xffffe
    800033bc:	80e080e7          	jalr	-2034(ra) # 80000bc6 <acquire>
      t->frozen=1;
    800033c0:	03692a23          	sw	s6,52(s2)
      release(&t->lock);
    800033c4:	854a                	mv	a0,s2
    800033c6:	ffffe097          	auipc	ra,0xffffe
    800033ca:	8d6080e7          	jalr	-1834(ra) # 80000c9c <release>
    800033ce:	bff1                	j	800033aa <handle_stop+0x32>
    }
  }
  int should_cont = check_should_cont(p);
    800033d0:	854e                	mv	a0,s3
    800033d2:	00000097          	auipc	ra,0x0
    800033d6:	f3e080e7          	jalr	-194(ra) # 80003310 <check_should_cont>
  
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    800033da:	0e89a783          	lw	a5,232(s3)
    800033de:	2007f793          	andi	a5,a5,512
    800033e2:	e795                	bnez	a5,8000340e <handle_stop+0x96>
    800033e4:	e50d                	bnez	a0,8000340e <handle_stop+0x96>
    
    yield();
    800033e6:	fffff097          	auipc	ra,0xfffff
    800033ea:	026080e7          	jalr	38(ra) # 8000240c <yield>
    should_cont = check_should_cont(p);  
    800033ee:	854e                	mv	a0,s3
    800033f0:	00000097          	auipc	ra,0x0
    800033f4:	f20080e7          	jalr	-224(ra) # 80003310 <check_should_cont>
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    800033f8:	0e89a783          	lw	a5,232(s3)
    800033fc:	2007f793          	andi	a5,a5,512
    80003400:	e799                	bnez	a5,8000340e <handle_stop+0x96>
    80003402:	d175                	beqz	a0,800033e6 <handle_stop+0x6e>
    80003404:	a029                	j	8000340e <handle_stop+0x96>
    
  }

  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    80003406:	0b848493          	addi	s1,s1,184
    8000340a:	03448163          	beq	s1,s4,8000342c <handle_stop+0xb4>
    if(t!=curr_t){
    8000340e:	fe9a8ce3          	beq	s5,s1,80003406 <handle_stop+0x8e>
      acquire(&t->lock);
    80003412:	8526                	mv	a0,s1
    80003414:	ffffd097          	auipc	ra,0xffffd
    80003418:	7b2080e7          	jalr	1970(ra) # 80000bc6 <acquire>
      t->frozen=0;
    8000341c:	0204aa23          	sw	zero,52(s1)
      release(&t->lock);
    80003420:	8526                	mv	a0,s1
    80003422:	ffffe097          	auipc	ra,0xffffe
    80003426:	87a080e7          	jalr	-1926(ra) # 80000c9c <release>
    8000342a:	bff1                	j	80003406 <handle_stop+0x8e>
    }
  }
  if(p->pending_signals&1<<SIGKILL)
    8000342c:	0e89a783          	lw	a5,232(s3)
    80003430:	2007f793          	andi	a5,a5,512
    80003434:	c781                	beqz	a5,8000343c <handle_stop+0xc4>
    p->killed=1;
    80003436:	4785                	li	a5,1
    80003438:	00f9ae23          	sw	a5,28(s3)
}
    8000343c:	70e2                	ld	ra,56(sp)
    8000343e:	7442                	ld	s0,48(sp)
    80003440:	74a2                	ld	s1,40(sp)
    80003442:	7902                	ld	s2,32(sp)
    80003444:	69e2                	ld	s3,24(sp)
    80003446:	6a42                	ld	s4,16(sp)
    80003448:	6aa2                	ld	s5,8(sp)
    8000344a:	6b02                	ld	s6,0(sp)
    8000344c:	6121                	addi	sp,sp,64
    8000344e:	8082                	ret

0000000080003450 <check_pending_signals>:

void 
check_pending_signals(struct proc* p){
    80003450:	711d                	addi	sp,sp,-96
    80003452:	ec86                	sd	ra,88(sp)
    80003454:	e8a2                	sd	s0,80(sp)
    80003456:	e4a6                	sd	s1,72(sp)
    80003458:	e0ca                	sd	s2,64(sp)
    8000345a:	fc4e                	sd	s3,56(sp)
    8000345c:	f852                	sd	s4,48(sp)
    8000345e:	f456                	sd	s5,40(sp)
    80003460:	f05a                	sd	s6,32(sp)
    80003462:	ec5e                	sd	s7,24(sp)
    80003464:	e862                	sd	s8,16(sp)
    80003466:	e466                	sd	s9,8(sp)
    80003468:	e06a                	sd	s10,0(sp)
    8000346a:	1080                	addi	s0,sp,96
    8000346c:	89aa                	mv	s3,a0
  // if(p->pid==4){
    
  //   if(p->pending_signals & (1<<SIGSTOP))
  //     printf("recieved stop sig\n");
  // }
  struct kthread *t= mykthread();
    8000346e:	ffffe097          	auipc	ra,0xffffe
    80003472:	64e080e7          	jalr	1614(ra) # 80001abc <mykthread>
    80003476:	8caa                	mv	s9,a0
  for(int sig_num=0;sig_num<32;sig_num++){
    80003478:	0f898913          	addi	s2,s3,248
    8000347c:	4481                	li	s1,0
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    8000347e:	4a05                	li	s4,1
            p->killed = 1;
            release(&p->lock);
        }
      }

      else if(act.sa_handler==(void*)SIGKILL){
    80003480:	4c25                	li	s8,9
        p->killed=1;
      }else if(act.sa_handler==(void*)SIGSTOP){
    80003482:	4b45                	li	s6,17
        handle_stop(p);
      }      
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    80003484:	4b85                	li	s7,1
        switch (sig_num)
    80003486:	4d4d                	li	s10,19
  for(int sig_num=0;sig_num<32;sig_num++){
    80003488:	02000a93          	li	s5,32
    8000348c:	a0a1                	j	800034d4 <check_pending_signals+0x84>
        switch (sig_num)
    8000348e:	03648163          	beq	s1,s6,800034b0 <check_pending_signals+0x60>
    80003492:	03a48763          	beq	s1,s10,800034c0 <check_pending_signals+0x70>
            acquire(&p->lock);
    80003496:	854e                	mv	a0,s3
    80003498:	ffffd097          	auipc	ra,0xffffd
    8000349c:	72e080e7          	jalr	1838(ra) # 80000bc6 <acquire>
            p->killed = 1;
    800034a0:	0179ae23          	sw	s7,28(s3)
            release(&p->lock);
    800034a4:	854e                	mv	a0,s3
    800034a6:	ffffd097          	auipc	ra,0xffffd
    800034aa:	7f6080e7          	jalr	2038(ra) # 80000c9c <release>
    800034ae:	a809                	j	800034c0 <check_pending_signals+0x70>
            handle_stop(p);
    800034b0:	854e                	mv	a0,s3
    800034b2:	00000097          	auipc	ra,0x0
    800034b6:	ec6080e7          	jalr	-314(ra) # 80003378 <handle_stop>
            break;
    800034ba:	a019                	j	800034c0 <check_pending_signals+0x70>
        p->killed=1;
    800034bc:	0179ae23          	sw	s7,28(s3)
        turn_off_bit(p, sig_num);

        return;
      }

      turn_off_bit(p, sig_num);            
    800034c0:	85a6                	mv	a1,s1
    800034c2:	854e                	mv	a0,s3
    800034c4:	00000097          	auipc	ra,0x0
    800034c8:	9a0080e7          	jalr	-1632(ra) # 80002e64 <turn_off_bit>
  for(int sig_num=0;sig_num<32;sig_num++){
    800034cc:	2485                	addiw	s1,s1,1
    800034ce:	0921                	addi	s2,s2,8
    800034d0:	0d548963          	beq	s1,s5,800035a2 <check_pending_signals+0x152>
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    800034d4:	009a173b          	sllw	a4,s4,s1
    800034d8:	0e89a783          	lw	a5,232(s3)
    800034dc:	8ff9                	and	a5,a5,a4
    800034de:	2781                	sext.w	a5,a5
    800034e0:	d7f5                	beqz	a5,800034cc <check_pending_signals+0x7c>
    800034e2:	0ec9a783          	lw	a5,236(s3)
    800034e6:	8f7d                	and	a4,a4,a5
    800034e8:	2701                	sext.w	a4,a4
    800034ea:	f36d                	bnez	a4,800034cc <check_pending_signals+0x7c>
      act.sa_handler = p->signal_handlers[sig_num];
    800034ec:	00093703          	ld	a4,0(s2)
      if(act.sa_handler == (void*)SIG_DFL){
    800034f0:	df59                	beqz	a4,8000348e <check_pending_signals+0x3e>
      else if(act.sa_handler==(void*)SIGKILL){
    800034f2:	fd8705e3          	beq	a4,s8,800034bc <check_pending_signals+0x6c>
      }else if(act.sa_handler==(void*)SIGSTOP){
    800034f6:	0d670463          	beq	a4,s6,800035be <check_pending_signals+0x16e>
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    800034fa:	fd7703e3          	beq	a4,s7,800034c0 <check_pending_signals+0x70>
    800034fe:	2809a703          	lw	a4,640(s3)
    80003502:	ff5d                	bnez	a4,800034c0 <check_pending_signals+0x70>
      act.sigmask = p->handlers_sigmasks[sig_num];
    80003504:	07c48713          	addi	a4,s1,124
    80003508:	070a                	slli	a4,a4,0x2
    8000350a:	974e                	add	a4,a4,s3
    8000350c:	4718                	lw	a4,8(a4)
        p->handling_user_sig_flag = 1;
    8000350e:	4685                	li	a3,1
    80003510:	28d9a023          	sw	a3,640(s3)
        p->signal_mask_backup = p->signal_mask;
    80003514:	0ef9a823          	sw	a5,240(s3)
        p->signal_mask= p->handlers_sigmasks[sig_num];
    80003518:	0ee9a623          	sw	a4,236(s3)
        t->trapframe->sp -= sizeof(struct trapframe);
    8000351c:	040cb703          	ld	a4,64(s9)
    80003520:	7b1c                	ld	a5,48(a4)
    80003522:	ee078793          	addi	a5,a5,-288
    80003526:	fb1c                	sd	a5,48(a4)
        p->user_trapframe_backup = (struct trapframe* )(t->trapframe->sp);
    80003528:	040cb783          	ld	a5,64(s9)
    8000352c:	7b8c                	ld	a1,48(a5)
    8000352e:	26b9bc23          	sd	a1,632(s3)
        copyout(p->pagetable, (uint64)p->user_trapframe_backup, (char *)t->trapframe, sizeof(struct trapframe));
    80003532:	12000693          	li	a3,288
    80003536:	040cb603          	ld	a2,64(s9)
    8000353a:	0409b503          	ld	a0,64(s3)
    8000353e:	ffffe097          	auipc	ra,0xffffe
    80003542:	126080e7          	jalr	294(ra) # 80001664 <copyout>
        uint64 size = (uint64)&end_sigret - (uint64)&call_sigret;
    80003546:	00004697          	auipc	a3,0x4
    8000354a:	f0a68693          	addi	a3,a3,-246 # 80007450 <end_sigret>
    8000354e:	00004617          	auipc	a2,0x4
    80003552:	efa60613          	addi	a2,a2,-262 # 80007448 <call_sigret>
        t->trapframe->sp -= size;
    80003556:	040cb703          	ld	a4,64(s9)
    8000355a:	40d605b3          	sub	a1,a2,a3
    8000355e:	7b1c                	ld	a5,48(a4)
    80003560:	97ae                	add	a5,a5,a1
    80003562:	fb1c                	sd	a5,48(a4)
        copyout(p->pagetable, (uint64)t->trapframe->sp, (char *)&call_sigret, size);
    80003564:	040cb783          	ld	a5,64(s9)
    80003568:	8e91                	sub	a3,a3,a2
    8000356a:	7b8c                	ld	a1,48(a5)
    8000356c:	0409b503          	ld	a0,64(s3)
    80003570:	ffffe097          	auipc	ra,0xffffe
    80003574:	0f4080e7          	jalr	244(ra) # 80001664 <copyout>
        t->trapframe->a0 = sig_num;
    80003578:	040cb783          	ld	a5,64(s9)
    8000357c:	fba4                	sd	s1,112(a5)
        t->trapframe->ra = t->trapframe->sp;
    8000357e:	040cb783          	ld	a5,64(s9)
    80003582:	7b98                	ld	a4,48(a5)
    80003584:	f798                	sd	a4,40(a5)
        t->trapframe->epc = (uint64)p->signal_handlers[sig_num];
    80003586:	040cb703          	ld	a4,64(s9)
    8000358a:	01e48793          	addi	a5,s1,30
    8000358e:	078e                	slli	a5,a5,0x3
    80003590:	97ce                	add	a5,a5,s3
    80003592:	679c                	ld	a5,8(a5)
    80003594:	ef1c                	sd	a5,24(a4)
        turn_off_bit(p, sig_num);
    80003596:	85a6                	mv	a1,s1
    80003598:	854e                	mv	a0,s3
    8000359a:	00000097          	auipc	ra,0x0
    8000359e:	8ca080e7          	jalr	-1846(ra) # 80002e64 <turn_off_bit>
    }
  }
}
    800035a2:	60e6                	ld	ra,88(sp)
    800035a4:	6446                	ld	s0,80(sp)
    800035a6:	64a6                	ld	s1,72(sp)
    800035a8:	6906                	ld	s2,64(sp)
    800035aa:	79e2                	ld	s3,56(sp)
    800035ac:	7a42                	ld	s4,48(sp)
    800035ae:	7aa2                	ld	s5,40(sp)
    800035b0:	7b02                	ld	s6,32(sp)
    800035b2:	6be2                	ld	s7,24(sp)
    800035b4:	6c42                	ld	s8,16(sp)
    800035b6:	6ca2                	ld	s9,8(sp)
    800035b8:	6d02                	ld	s10,0(sp)
    800035ba:	6125                	addi	sp,sp,96
    800035bc:	8082                	ret
        handle_stop(p);
    800035be:	854e                	mv	a0,s3
    800035c0:	00000097          	auipc	ra,0x0
    800035c4:	db8080e7          	jalr	-584(ra) # 80003378 <handle_stop>
    800035c8:	bde5                	j	800034c0 <check_pending_signals+0x70>

00000000800035ca <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800035ca:	1101                	addi	sp,sp,-32
    800035cc:	ec06                	sd	ra,24(sp)
    800035ce:	e822                	sd	s0,16(sp)
    800035d0:	e426                	sd	s1,8(sp)
    800035d2:	e04a                	sd	s2,0(sp)
    800035d4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800035d6:	ffffe097          	auipc	ra,0xffffe
    800035da:	4a6080e7          	jalr	1190(ra) # 80001a7c <myproc>
    800035de:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    800035e0:	ffffe097          	auipc	ra,0xffffe
    800035e4:	4dc080e7          	jalr	1244(ra) # 80001abc <mykthread>
    800035e8:	84aa                	mv	s1,a0
  int mytid = mykthread()->tid;
    800035ea:	ffffe097          	auipc	ra,0xffffe
    800035ee:	4d2080e7          	jalr	1234(ra) # 80001abc <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800035f2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800035f6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800035f8:	10079073          	csrw	sstatus,a5

  intr_off();
  

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800035fc:	00005617          	auipc	a2,0x5
    80003600:	a0460613          	addi	a2,a2,-1532 # 80008000 <_trampoline>
    80003604:	00005697          	auipc	a3,0x5
    80003608:	9fc68693          	addi	a3,a3,-1540 # 80008000 <_trampoline>
    8000360c:	8e91                	sub	a3,a3,a2
    8000360e:	040007b7          	lui	a5,0x4000
    80003612:	17fd                	addi	a5,a5,-1
    80003614:	07b2                	slli	a5,a5,0xc
    80003616:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003618:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  t->trapframe->kernel_satp = r_satp();         // kernel page table
    8000361c:	60b8                	ld	a4,64(s1)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000361e:	180026f3          	csrr	a3,satp
    80003622:	e314                	sd	a3,0(a4)
  t->trapframe->kernel_sp = t->kstack + PGSIZE; // process's kernel stack
    80003624:	60b8                	ld	a4,64(s1)
    80003626:	7c94                	ld	a3,56(s1)
    80003628:	6585                	lui	a1,0x1
    8000362a:	96ae                	add	a3,a3,a1
    8000362c:	e714                	sd	a3,8(a4)
  t->trapframe->kernel_trap = (uint64)usertrap;
    8000362e:	60b8                	ld	a4,64(s1)
    80003630:	00000697          	auipc	a3,0x0
    80003634:	15e68693          	addi	a3,a3,350 # 8000378e <usertrap>
    80003638:	eb14                	sd	a3,16(a4)
  t->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000363a:	60b8                	ld	a4,64(s1)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000363c:	8692                	mv	a3,tp
    8000363e:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003640:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80003644:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80003648:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000364c:	10069073          	csrw	sstatus,a3
  w_sstatus(x);
  

  // set S Exception Program Counter to the saved user pc.
  w_sepc(t->trapframe->epc);
    80003650:	60b8                	ld	a4,64(s1)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003652:	6f18                	ld	a4,24(a4)
    80003654:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80003658:	04093583          	ld	a1,64(s2)
    8000365c:	81b1                	srli	a1,a1,0xc
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
 
 
  int thread_ind = (int)(t - p->kthreads);
    8000365e:	28890513          	addi	a0,s2,648
    80003662:	40a48533          	sub	a0,s1,a0
    80003666:	850d                	srai	a0,a0,0x3




  ((void (*)(uint64,uint64))fn)(TRAPFRAME + (uint64)(thread_ind * sizeof(struct trapframe)), satp);
    80003668:	00006497          	auipc	s1,0x6
    8000366c:	9a04b483          	ld	s1,-1632(s1) # 80009008 <etext+0x8>
    80003670:	0295053b          	mulw	a0,a0,s1
    80003674:	00351493          	slli	s1,a0,0x3
    80003678:	9526                	add	a0,a0,s1
    8000367a:	0516                	slli	a0,a0,0x5
    8000367c:	020006b7          	lui	a3,0x2000
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80003680:	00005717          	auipc	a4,0x5
    80003684:	a1070713          	addi	a4,a4,-1520 # 80008090 <userret>
    80003688:	8f11                	sub	a4,a4,a2
    8000368a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME + (uint64)(thread_ind * sizeof(struct trapframe)), satp);
    8000368c:	577d                	li	a4,-1
    8000368e:	177e                	slli	a4,a4,0x3f
    80003690:	8dd9                	or	a1,a1,a4
    80003692:	16fd                	addi	a3,a3,-1
    80003694:	06b6                	slli	a3,a3,0xd
    80003696:	9536                	add	a0,a0,a3
    80003698:	9782                	jalr	a5

}
    8000369a:	60e2                	ld	ra,24(sp)
    8000369c:	6442                	ld	s0,16(sp)
    8000369e:	64a2                	ld	s1,8(sp)
    800036a0:	6902                	ld	s2,0(sp)
    800036a2:	6105                	addi	sp,sp,32
    800036a4:	8082                	ret

00000000800036a6 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800036a6:	1101                	addi	sp,sp,-32
    800036a8:	ec06                	sd	ra,24(sp)
    800036aa:	e822                	sd	s0,16(sp)
    800036ac:	e426                	sd	s1,8(sp)
    800036ae:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800036b0:	00030497          	auipc	s1,0x30
    800036b4:	27848493          	addi	s1,s1,632 # 80033928 <tickslock>
    800036b8:	8526                	mv	a0,s1
    800036ba:	ffffd097          	auipc	ra,0xffffd
    800036be:	50c080e7          	jalr	1292(ra) # 80000bc6 <acquire>
  ticks++;
    800036c2:	00007517          	auipc	a0,0x7
    800036c6:	96e50513          	addi	a0,a0,-1682 # 8000a030 <ticks>
    800036ca:	411c                	lw	a5,0(a0)
    800036cc:	2785                	addiw	a5,a5,1
    800036ce:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800036d0:	fffff097          	auipc	ra,0xfffff
    800036d4:	f0c080e7          	jalr	-244(ra) # 800025dc <wakeup>
  release(&tickslock);
    800036d8:	8526                	mv	a0,s1
    800036da:	ffffd097          	auipc	ra,0xffffd
    800036de:	5c2080e7          	jalr	1474(ra) # 80000c9c <release>
}
    800036e2:	60e2                	ld	ra,24(sp)
    800036e4:	6442                	ld	s0,16(sp)
    800036e6:	64a2                	ld	s1,8(sp)
    800036e8:	6105                	addi	sp,sp,32
    800036ea:	8082                	ret

00000000800036ec <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800036ec:	1101                	addi	sp,sp,-32
    800036ee:	ec06                	sd	ra,24(sp)
    800036f0:	e822                	sd	s0,16(sp)
    800036f2:	e426                	sd	s1,8(sp)
    800036f4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800036f6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800036fa:	00074d63          	bltz	a4,80003714 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800036fe:	57fd                	li	a5,-1
    80003700:	17fe                	slli	a5,a5,0x3f
    80003702:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80003704:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80003706:	06f70363          	beq	a4,a5,8000376c <devintr+0x80>
  }
}
    8000370a:	60e2                	ld	ra,24(sp)
    8000370c:	6442                	ld	s0,16(sp)
    8000370e:	64a2                	ld	s1,8(sp)
    80003710:	6105                	addi	sp,sp,32
    80003712:	8082                	ret
     (scause & 0xff) == 9){
    80003714:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80003718:	46a5                	li	a3,9
    8000371a:	fed792e3          	bne	a5,a3,800036fe <devintr+0x12>
    int irq = plic_claim();
    8000371e:	00003097          	auipc	ra,0x3
    80003722:	7aa080e7          	jalr	1962(ra) # 80006ec8 <plic_claim>
    80003726:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80003728:	47a9                	li	a5,10
    8000372a:	02f50763          	beq	a0,a5,80003758 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000372e:	4785                	li	a5,1
    80003730:	02f50963          	beq	a0,a5,80003762 <devintr+0x76>
    return 1;
    80003734:	4505                	li	a0,1
    } else if(irq){
    80003736:	d8f1                	beqz	s1,8000370a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80003738:	85a6                	mv	a1,s1
    8000373a:	00006517          	auipc	a0,0x6
    8000373e:	d6650513          	addi	a0,a0,-666 # 800094a0 <states.0+0x28>
    80003742:	ffffd097          	auipc	ra,0xffffd
    80003746:	e36080e7          	jalr	-458(ra) # 80000578 <printf>
      plic_complete(irq);
    8000374a:	8526                	mv	a0,s1
    8000374c:	00003097          	auipc	ra,0x3
    80003750:	7a0080e7          	jalr	1952(ra) # 80006eec <plic_complete>
    return 1;
    80003754:	4505                	li	a0,1
    80003756:	bf55                	j	8000370a <devintr+0x1e>
      uartintr();
    80003758:	ffffd097          	auipc	ra,0xffffd
    8000375c:	232080e7          	jalr	562(ra) # 8000098a <uartintr>
    80003760:	b7ed                	j	8000374a <devintr+0x5e>
      virtio_disk_intr();
    80003762:	00004097          	auipc	ra,0x4
    80003766:	c1c080e7          	jalr	-996(ra) # 8000737e <virtio_disk_intr>
    8000376a:	b7c5                	j	8000374a <devintr+0x5e>
    if(cpuid() == 0){
    8000376c:	ffffe097          	auipc	ra,0xffffe
    80003770:	2dc080e7          	jalr	732(ra) # 80001a48 <cpuid>
    80003774:	c901                	beqz	a0,80003784 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80003776:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000377a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000377c:	14479073          	csrw	sip,a5
    return 2;
    80003780:	4509                	li	a0,2
    80003782:	b761                	j	8000370a <devintr+0x1e>
      clockintr();
    80003784:	00000097          	auipc	ra,0x0
    80003788:	f22080e7          	jalr	-222(ra) # 800036a6 <clockintr>
    8000378c:	b7ed                	j	80003776 <devintr+0x8a>

000000008000378e <usertrap>:
{
    8000378e:	1101                	addi	sp,sp,-32
    80003790:	ec06                	sd	ra,24(sp)
    80003792:	e822                	sd	s0,16(sp)
    80003794:	e426                	sd	s1,8(sp)
    80003796:	e04a                	sd	s2,0(sp)
    80003798:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000379a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000379e:	1007f793          	andi	a5,a5,256
    800037a2:	e3dd                	bnez	a5,80003848 <usertrap+0xba>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800037a4:	00003797          	auipc	a5,0x3
    800037a8:	61c78793          	addi	a5,a5,1564 # 80006dc0 <kernelvec>
    800037ac:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800037b0:	ffffe097          	auipc	ra,0xffffe
    800037b4:	2cc080e7          	jalr	716(ra) # 80001a7c <myproc>
    800037b8:	84aa                	mv	s1,a0
  struct kthread *t = mykthread();
    800037ba:	ffffe097          	auipc	ra,0xffffe
    800037be:	302080e7          	jalr	770(ra) # 80001abc <mykthread>
    800037c2:	892a                	mv	s2,a0
  t->trapframe->epc = r_sepc();
    800037c4:	613c                	ld	a5,64(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800037c6:	14102773          	csrr	a4,sepc
    800037ca:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800037cc:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800037d0:	47a1                	li	a5,8
    800037d2:	08f71f63          	bne	a4,a5,80003870 <usertrap+0xe2>
    if(t->killed == 1)
    800037d6:	5518                	lw	a4,40(a0)
    800037d8:	4785                	li	a5,1
    800037da:	06f70f63          	beq	a4,a5,80003858 <usertrap+0xca>
    else if(p->killed)
    800037de:	4cdc                	lw	a5,28(s1)
    800037e0:	e3d1                	bnez	a5,80003864 <usertrap+0xd6>
    t->trapframe->epc += 4;
    800037e2:	04093703          	ld	a4,64(s2)
    800037e6:	6f1c                	ld	a5,24(a4)
    800037e8:	0791                	addi	a5,a5,4
    800037ea:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800037ec:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800037f0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800037f4:	10079073          	csrw	sstatus,a5
    syscall();
    800037f8:	00000097          	auipc	ra,0x0
    800037fc:	38a080e7          	jalr	906(ra) # 80003b82 <syscall>
  if(holding(&p->lock))
    80003800:	8526                	mv	a0,s1
    80003802:	ffffd097          	auipc	ra,0xffffd
    80003806:	34a080e7          	jalr	842(ra) # 80000b4c <holding>
    8000380a:	e95d                	bnez	a0,800038c0 <usertrap+0x132>
  acquire(&p->lock);
    8000380c:	8526                	mv	a0,s1
    8000380e:	ffffd097          	auipc	ra,0xffffd
    80003812:	3b8080e7          	jalr	952(ra) # 80000bc6 <acquire>
  if(!p->handling_sig_flag){
    80003816:	2844a783          	lw	a5,644(s1)
    8000381a:	cfc5                	beqz	a5,800038d2 <usertrap+0x144>
  release(&p->lock);
    8000381c:	8526                	mv	a0,s1
    8000381e:	ffffd097          	auipc	ra,0xffffd
    80003822:	47e080e7          	jalr	1150(ra) # 80000c9c <release>
  if(t->killed == 1)
    80003826:	02892703          	lw	a4,40(s2)
    8000382a:	4785                	li	a5,1
    8000382c:	0cf70863          	beq	a4,a5,800038fc <usertrap+0x16e>
  else if(p->killed)
    80003830:	4cdc                	lw	a5,28(s1)
    80003832:	ebf9                	bnez	a5,80003908 <usertrap+0x17a>
  usertrapret();
    80003834:	00000097          	auipc	ra,0x0
    80003838:	d96080e7          	jalr	-618(ra) # 800035ca <usertrapret>
}
    8000383c:	60e2                	ld	ra,24(sp)
    8000383e:	6442                	ld	s0,16(sp)
    80003840:	64a2                	ld	s1,8(sp)
    80003842:	6902                	ld	s2,0(sp)
    80003844:	6105                	addi	sp,sp,32
    80003846:	8082                	ret
    panic("usertrap: not from user mode");
    80003848:	00006517          	auipc	a0,0x6
    8000384c:	c7850513          	addi	a0,a0,-904 # 800094c0 <states.0+0x48>
    80003850:	ffffd097          	auipc	ra,0xffffd
    80003854:	cde080e7          	jalr	-802(ra) # 8000052e <panic>
      kthread_exit(-1); // Kill current thread
    80003858:	557d                	li	a0,-1
    8000385a:	fffff097          	auipc	ra,0xfffff
    8000385e:	032080e7          	jalr	50(ra) # 8000288c <kthread_exit>
    80003862:	b741                	j	800037e2 <usertrap+0x54>
      exit(-1); // Kill the hole procces
    80003864:	557d                	li	a0,-1
    80003866:	fffff097          	auipc	ra,0xfffff
    8000386a:	0c4080e7          	jalr	196(ra) # 8000292a <exit>
    8000386e:	bf95                	j	800037e2 <usertrap+0x54>
  else if((which_dev = devintr()) != 0)
    80003870:	00000097          	auipc	ra,0x0
    80003874:	e7c080e7          	jalr	-388(ra) # 800036ec <devintr>
    80003878:	c909                	beqz	a0,8000388a <usertrap+0xfc>
  if(which_dev == 2)
    8000387a:	4789                	li	a5,2
    8000387c:	f8f512e3          	bne	a0,a5,80003800 <usertrap+0x72>
    yield();
    80003880:	fffff097          	auipc	ra,0xfffff
    80003884:	b8c080e7          	jalr	-1140(ra) # 8000240c <yield>
    80003888:	bfa5                	j	80003800 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000388a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000388e:	50d0                	lw	a2,36(s1)
    80003890:	00006517          	auipc	a0,0x6
    80003894:	c5050513          	addi	a0,a0,-944 # 800094e0 <states.0+0x68>
    80003898:	ffffd097          	auipc	ra,0xffffd
    8000389c:	ce0080e7          	jalr	-800(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800038a0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800038a4:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800038a8:	00006517          	auipc	a0,0x6
    800038ac:	c6850513          	addi	a0,a0,-920 # 80009510 <states.0+0x98>
    800038b0:	ffffd097          	auipc	ra,0xffffd
    800038b4:	cc8080e7          	jalr	-824(ra) # 80000578 <printf>
    t->killed = 1;
    800038b8:	4785                	li	a5,1
    800038ba:	02f92423          	sw	a5,40(s2)
  if(which_dev == 2)
    800038be:	b789                	j	80003800 <usertrap+0x72>
    printf("fuck i am holding the lock in usertrap\n");   // TODO : delete
    800038c0:	00006517          	auipc	a0,0x6
    800038c4:	c7050513          	addi	a0,a0,-912 # 80009530 <states.0+0xb8>
    800038c8:	ffffd097          	auipc	ra,0xffffd
    800038cc:	cb0080e7          	jalr	-848(ra) # 80000578 <printf>
    800038d0:	bf35                	j	8000380c <usertrap+0x7e>
    p->handling_sig_flag = 1;
    800038d2:	4785                	li	a5,1
    800038d4:	28f4a223          	sw	a5,644(s1)
    release(&p->lock);
    800038d8:	8526                	mv	a0,s1
    800038da:	ffffd097          	auipc	ra,0xffffd
    800038de:	3c2080e7          	jalr	962(ra) # 80000c9c <release>
    check_pending_signals(p);
    800038e2:	8526                	mv	a0,s1
    800038e4:	00000097          	auipc	ra,0x0
    800038e8:	b6c080e7          	jalr	-1172(ra) # 80003450 <check_pending_signals>
    acquire(&p->lock);
    800038ec:	8526                	mv	a0,s1
    800038ee:	ffffd097          	auipc	ra,0xffffd
    800038f2:	2d8080e7          	jalr	728(ra) # 80000bc6 <acquire>
    p->handling_sig_flag = 0;
    800038f6:	2804a223          	sw	zero,644(s1)
    800038fa:	b70d                	j	8000381c <usertrap+0x8e>
    kthread_exit(-1); // Kill current thread
    800038fc:	557d                	li	a0,-1
    800038fe:	fffff097          	auipc	ra,0xfffff
    80003902:	f8e080e7          	jalr	-114(ra) # 8000288c <kthread_exit>
    80003906:	b73d                	j	80003834 <usertrap+0xa6>
    exit(-1); // Kill the hole procces
    80003908:	557d                	li	a0,-1
    8000390a:	fffff097          	auipc	ra,0xfffff
    8000390e:	020080e7          	jalr	32(ra) # 8000292a <exit>
    80003912:	b70d                	j	80003834 <usertrap+0xa6>

0000000080003914 <kerneltrap>:
{
    80003914:	7179                	addi	sp,sp,-48
    80003916:	f406                	sd	ra,40(sp)
    80003918:	f022                	sd	s0,32(sp)
    8000391a:	ec26                	sd	s1,24(sp)
    8000391c:	e84a                	sd	s2,16(sp)
    8000391e:	e44e                	sd	s3,8(sp)
    80003920:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003922:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003926:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000392a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000392e:	1004f793          	andi	a5,s1,256
    80003932:	cb85                	beqz	a5,80003962 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003934:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003938:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000393a:	ef85                	bnez	a5,80003972 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000393c:	00000097          	auipc	ra,0x0
    80003940:	db0080e7          	jalr	-592(ra) # 800036ec <devintr>
    80003944:	cd1d                	beqz	a0,80003982 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    80003946:	4789                	li	a5,2
    80003948:	08f50763          	beq	a0,a5,800039d6 <kerneltrap+0xc2>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000394c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003950:	10049073          	csrw	sstatus,s1
}
    80003954:	70a2                	ld	ra,40(sp)
    80003956:	7402                	ld	s0,32(sp)
    80003958:	64e2                	ld	s1,24(sp)
    8000395a:	6942                	ld	s2,16(sp)
    8000395c:	69a2                	ld	s3,8(sp)
    8000395e:	6145                	addi	sp,sp,48
    80003960:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003962:	00006517          	auipc	a0,0x6
    80003966:	bf650513          	addi	a0,a0,-1034 # 80009558 <states.0+0xe0>
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	bc4080e7          	jalr	-1084(ra) # 8000052e <panic>
    panic("kerneltrap: interrupts enabled");
    80003972:	00006517          	auipc	a0,0x6
    80003976:	c0e50513          	addi	a0,a0,-1010 # 80009580 <states.0+0x108>
    8000397a:	ffffd097          	auipc	ra,0xffffd
    8000397e:	bb4080e7          	jalr	-1100(ra) # 8000052e <panic>
    printf("proc %d recieved kernel trap\n",myproc()->pid);
    80003982:	ffffe097          	auipc	ra,0xffffe
    80003986:	0fa080e7          	jalr	250(ra) # 80001a7c <myproc>
    8000398a:	514c                	lw	a1,36(a0)
    8000398c:	00006517          	auipc	a0,0x6
    80003990:	c1450513          	addi	a0,a0,-1004 # 800095a0 <states.0+0x128>
    80003994:	ffffd097          	auipc	ra,0xffffd
    80003998:	be4080e7          	jalr	-1052(ra) # 80000578 <printf>
    printf("scause %p\n", scause);
    8000399c:	85ce                	mv	a1,s3
    8000399e:	00006517          	auipc	a0,0x6
    800039a2:	c2250513          	addi	a0,a0,-990 # 800095c0 <states.0+0x148>
    800039a6:	ffffd097          	auipc	ra,0xffffd
    800039aa:	bd2080e7          	jalr	-1070(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800039ae:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800039b2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800039b6:	00006517          	auipc	a0,0x6
    800039ba:	c1a50513          	addi	a0,a0,-998 # 800095d0 <states.0+0x158>
    800039be:	ffffd097          	auipc	ra,0xffffd
    800039c2:	bba080e7          	jalr	-1094(ra) # 80000578 <printf>
    panic("kerneltrap");
    800039c6:	00006517          	auipc	a0,0x6
    800039ca:	c2250513          	addi	a0,a0,-990 # 800095e8 <states.0+0x170>
    800039ce:	ffffd097          	auipc	ra,0xffffd
    800039d2:	b60080e7          	jalr	-1184(ra) # 8000052e <panic>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    800039d6:	ffffe097          	auipc	ra,0xffffe
    800039da:	0a6080e7          	jalr	166(ra) # 80001a7c <myproc>
    800039de:	d53d                	beqz	a0,8000394c <kerneltrap+0x38>
    800039e0:	ffffe097          	auipc	ra,0xffffe
    800039e4:	0dc080e7          	jalr	220(ra) # 80001abc <mykthread>
    800039e8:	d135                	beqz	a0,8000394c <kerneltrap+0x38>
    800039ea:	ffffe097          	auipc	ra,0xffffe
    800039ee:	0d2080e7          	jalr	210(ra) # 80001abc <mykthread>
    800039f2:	4d18                	lw	a4,24(a0)
    800039f4:	4791                	li	a5,4
    800039f6:	f4f71be3          	bne	a4,a5,8000394c <kerneltrap+0x38>
    yield();
    800039fa:	fffff097          	auipc	ra,0xfffff
    800039fe:	a12080e7          	jalr	-1518(ra) # 8000240c <yield>
    80003a02:	b7a9                	j	8000394c <kerneltrap+0x38>

0000000080003a04 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003a04:	1101                	addi	sp,sp,-32
    80003a06:	ec06                	sd	ra,24(sp)
    80003a08:	e822                	sd	s0,16(sp)
    80003a0a:	e426                	sd	s1,8(sp)
    80003a0c:	1000                	addi	s0,sp,32
    80003a0e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003a10:	ffffe097          	auipc	ra,0xffffe
    80003a14:	06c080e7          	jalr	108(ra) # 80001a7c <myproc>
  struct kthread *t = mykthread();
    80003a18:	ffffe097          	auipc	ra,0xffffe
    80003a1c:	0a4080e7          	jalr	164(ra) # 80001abc <mykthread>
  switch (n) {
    80003a20:	4795                	li	a5,5
    80003a22:	0497e163          	bltu	a5,s1,80003a64 <argraw+0x60>
    80003a26:	048a                	slli	s1,s1,0x2
    80003a28:	00006717          	auipc	a4,0x6
    80003a2c:	bf870713          	addi	a4,a4,-1032 # 80009620 <states.0+0x1a8>
    80003a30:	94ba                	add	s1,s1,a4
    80003a32:	409c                	lw	a5,0(s1)
    80003a34:	97ba                	add	a5,a5,a4
    80003a36:	8782                	jr	a5
  case 0:
    return t->trapframe->a0;
    80003a38:	613c                	ld	a5,64(a0)
    80003a3a:	7ba8                	ld	a0,112(a5)
  case 5:
    return t->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003a3c:	60e2                	ld	ra,24(sp)
    80003a3e:	6442                	ld	s0,16(sp)
    80003a40:	64a2                	ld	s1,8(sp)
    80003a42:	6105                	addi	sp,sp,32
    80003a44:	8082                	ret
    return t->trapframe->a1;
    80003a46:	613c                	ld	a5,64(a0)
    80003a48:	7fa8                	ld	a0,120(a5)
    80003a4a:	bfcd                	j	80003a3c <argraw+0x38>
    return t->trapframe->a2;
    80003a4c:	613c                	ld	a5,64(a0)
    80003a4e:	63c8                	ld	a0,128(a5)
    80003a50:	b7f5                	j	80003a3c <argraw+0x38>
    return t->trapframe->a3;
    80003a52:	613c                	ld	a5,64(a0)
    80003a54:	67c8                	ld	a0,136(a5)
    80003a56:	b7dd                	j	80003a3c <argraw+0x38>
    return t->trapframe->a4;
    80003a58:	613c                	ld	a5,64(a0)
    80003a5a:	6bc8                	ld	a0,144(a5)
    80003a5c:	b7c5                	j	80003a3c <argraw+0x38>
    return t->trapframe->a5;
    80003a5e:	613c                	ld	a5,64(a0)
    80003a60:	6fc8                	ld	a0,152(a5)
    80003a62:	bfe9                	j	80003a3c <argraw+0x38>
  panic("argraw");
    80003a64:	00006517          	auipc	a0,0x6
    80003a68:	b9450513          	addi	a0,a0,-1132 # 800095f8 <states.0+0x180>
    80003a6c:	ffffd097          	auipc	ra,0xffffd
    80003a70:	ac2080e7          	jalr	-1342(ra) # 8000052e <panic>

0000000080003a74 <fetchaddr>:
{
    80003a74:	1101                	addi	sp,sp,-32
    80003a76:	ec06                	sd	ra,24(sp)
    80003a78:	e822                	sd	s0,16(sp)
    80003a7a:	e426                	sd	s1,8(sp)
    80003a7c:	e04a                	sd	s2,0(sp)
    80003a7e:	1000                	addi	s0,sp,32
    80003a80:	84aa                	mv	s1,a0
    80003a82:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003a84:	ffffe097          	auipc	ra,0xffffe
    80003a88:	ff8080e7          	jalr	-8(ra) # 80001a7c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003a8c:	7d1c                	ld	a5,56(a0)
    80003a8e:	02f4f863          	bgeu	s1,a5,80003abe <fetchaddr+0x4a>
    80003a92:	00848713          	addi	a4,s1,8
    80003a96:	02e7e663          	bltu	a5,a4,80003ac2 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003a9a:	46a1                	li	a3,8
    80003a9c:	8626                	mv	a2,s1
    80003a9e:	85ca                	mv	a1,s2
    80003aa0:	6128                	ld	a0,64(a0)
    80003aa2:	ffffe097          	auipc	ra,0xffffe
    80003aa6:	c4e080e7          	jalr	-946(ra) # 800016f0 <copyin>
    80003aaa:	00a03533          	snez	a0,a0
    80003aae:	40a00533          	neg	a0,a0
}
    80003ab2:	60e2                	ld	ra,24(sp)
    80003ab4:	6442                	ld	s0,16(sp)
    80003ab6:	64a2                	ld	s1,8(sp)
    80003ab8:	6902                	ld	s2,0(sp)
    80003aba:	6105                	addi	sp,sp,32
    80003abc:	8082                	ret
    return -1;
    80003abe:	557d                	li	a0,-1
    80003ac0:	bfcd                	j	80003ab2 <fetchaddr+0x3e>
    80003ac2:	557d                	li	a0,-1
    80003ac4:	b7fd                	j	80003ab2 <fetchaddr+0x3e>

0000000080003ac6 <fetchstr>:
{
    80003ac6:	7179                	addi	sp,sp,-48
    80003ac8:	f406                	sd	ra,40(sp)
    80003aca:	f022                	sd	s0,32(sp)
    80003acc:	ec26                	sd	s1,24(sp)
    80003ace:	e84a                	sd	s2,16(sp)
    80003ad0:	e44e                	sd	s3,8(sp)
    80003ad2:	1800                	addi	s0,sp,48
    80003ad4:	892a                	mv	s2,a0
    80003ad6:	84ae                	mv	s1,a1
    80003ad8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003ada:	ffffe097          	auipc	ra,0xffffe
    80003ade:	fa2080e7          	jalr	-94(ra) # 80001a7c <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003ae2:	86ce                	mv	a3,s3
    80003ae4:	864a                	mv	a2,s2
    80003ae6:	85a6                	mv	a1,s1
    80003ae8:	6128                	ld	a0,64(a0)
    80003aea:	ffffe097          	auipc	ra,0xffffe
    80003aee:	c94080e7          	jalr	-876(ra) # 8000177e <copyinstr>
  if(err < 0)
    80003af2:	00054763          	bltz	a0,80003b00 <fetchstr+0x3a>
  return strlen(buf);
    80003af6:	8526                	mv	a0,s1
    80003af8:	ffffd097          	auipc	ra,0xffffd
    80003afc:	370080e7          	jalr	880(ra) # 80000e68 <strlen>
}
    80003b00:	70a2                	ld	ra,40(sp)
    80003b02:	7402                	ld	s0,32(sp)
    80003b04:	64e2                	ld	s1,24(sp)
    80003b06:	6942                	ld	s2,16(sp)
    80003b08:	69a2                	ld	s3,8(sp)
    80003b0a:	6145                	addi	sp,sp,48
    80003b0c:	8082                	ret

0000000080003b0e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003b0e:	1101                	addi	sp,sp,-32
    80003b10:	ec06                	sd	ra,24(sp)
    80003b12:	e822                	sd	s0,16(sp)
    80003b14:	e426                	sd	s1,8(sp)
    80003b16:	1000                	addi	s0,sp,32
    80003b18:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003b1a:	00000097          	auipc	ra,0x0
    80003b1e:	eea080e7          	jalr	-278(ra) # 80003a04 <argraw>
    80003b22:	c088                	sw	a0,0(s1)
  return 0;
}
    80003b24:	4501                	li	a0,0
    80003b26:	60e2                	ld	ra,24(sp)
    80003b28:	6442                	ld	s0,16(sp)
    80003b2a:	64a2                	ld	s1,8(sp)
    80003b2c:	6105                	addi	sp,sp,32
    80003b2e:	8082                	ret

0000000080003b30 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003b30:	1101                	addi	sp,sp,-32
    80003b32:	ec06                	sd	ra,24(sp)
    80003b34:	e822                	sd	s0,16(sp)
    80003b36:	e426                	sd	s1,8(sp)
    80003b38:	1000                	addi	s0,sp,32
    80003b3a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003b3c:	00000097          	auipc	ra,0x0
    80003b40:	ec8080e7          	jalr	-312(ra) # 80003a04 <argraw>
    80003b44:	e088                	sd	a0,0(s1)
  return 0;
}
    80003b46:	4501                	li	a0,0
    80003b48:	60e2                	ld	ra,24(sp)
    80003b4a:	6442                	ld	s0,16(sp)
    80003b4c:	64a2                	ld	s1,8(sp)
    80003b4e:	6105                	addi	sp,sp,32
    80003b50:	8082                	ret

0000000080003b52 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003b52:	1101                	addi	sp,sp,-32
    80003b54:	ec06                	sd	ra,24(sp)
    80003b56:	e822                	sd	s0,16(sp)
    80003b58:	e426                	sd	s1,8(sp)
    80003b5a:	e04a                	sd	s2,0(sp)
    80003b5c:	1000                	addi	s0,sp,32
    80003b5e:	84ae                	mv	s1,a1
    80003b60:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003b62:	00000097          	auipc	ra,0x0
    80003b66:	ea2080e7          	jalr	-350(ra) # 80003a04 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003b6a:	864a                	mv	a2,s2
    80003b6c:	85a6                	mv	a1,s1
    80003b6e:	00000097          	auipc	ra,0x0
    80003b72:	f58080e7          	jalr	-168(ra) # 80003ac6 <fetchstr>
}
    80003b76:	60e2                	ld	ra,24(sp)
    80003b78:	6442                	ld	s0,16(sp)
    80003b7a:	64a2                	ld	s1,8(sp)
    80003b7c:	6902                	ld	s2,0(sp)
    80003b7e:	6105                	addi	sp,sp,32
    80003b80:	8082                	ret

0000000080003b82 <syscall>:
[SYS_kthread_join] sys_kthread_join,
};

void
syscall(void)
{
    80003b82:	7179                	addi	sp,sp,-48
    80003b84:	f406                	sd	ra,40(sp)
    80003b86:	f022                	sd	s0,32(sp)
    80003b88:	ec26                	sd	s1,24(sp)
    80003b8a:	e84a                	sd	s2,16(sp)
    80003b8c:	e44e                	sd	s3,8(sp)
    80003b8e:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80003b90:	ffffe097          	auipc	ra,0xffffe
    80003b94:	eec080e7          	jalr	-276(ra) # 80001a7c <myproc>
    80003b98:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80003b9a:	ffffe097          	auipc	ra,0xffffe
    80003b9e:	f22080e7          	jalr	-222(ra) # 80001abc <mykthread>
    80003ba2:	84aa                	mv	s1,a0

  num = t->trapframe->a7;
    80003ba4:	04053983          	ld	s3,64(a0)
    80003ba8:	0a89b783          	ld	a5,168(s3)
    80003bac:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003bb0:	37fd                	addiw	a5,a5,-1
    80003bb2:	476d                	li	a4,27
    80003bb4:	00f76f63          	bltu	a4,a5,80003bd2 <syscall+0x50>
    80003bb8:	00369713          	slli	a4,a3,0x3
    80003bbc:	00006797          	auipc	a5,0x6
    80003bc0:	a7c78793          	addi	a5,a5,-1412 # 80009638 <syscalls>
    80003bc4:	97ba                	add	a5,a5,a4
    80003bc6:	639c                	ld	a5,0(a5)
    80003bc8:	c789                	beqz	a5,80003bd2 <syscall+0x50>
    t->trapframe->a0 = syscalls[num]();
    80003bca:	9782                	jalr	a5
    80003bcc:	06a9b823          	sd	a0,112(s3)
    80003bd0:	a005                	j	80003bf0 <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003bd2:	0d890613          	addi	a2,s2,216
    80003bd6:	02492583          	lw	a1,36(s2)
    80003bda:	00006517          	auipc	a0,0x6
    80003bde:	a2650513          	addi	a0,a0,-1498 # 80009600 <states.0+0x188>
    80003be2:	ffffd097          	auipc	ra,0xffffd
    80003be6:	996080e7          	jalr	-1642(ra) # 80000578 <printf>
            p->pid, p->name, num);
    t->trapframe->a0 = -1;
    80003bea:	60bc                	ld	a5,64(s1)
    80003bec:	577d                	li	a4,-1
    80003bee:	fbb8                	sd	a4,112(a5)
  }
}
    80003bf0:	70a2                	ld	ra,40(sp)
    80003bf2:	7402                	ld	s0,32(sp)
    80003bf4:	64e2                	ld	s1,24(sp)
    80003bf6:	6942                	ld	s2,16(sp)
    80003bf8:	69a2                	ld	s3,8(sp)
    80003bfa:	6145                	addi	sp,sp,48
    80003bfc:	8082                	ret

0000000080003bfe <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003bfe:	1101                	addi	sp,sp,-32
    80003c00:	ec06                	sd	ra,24(sp)
    80003c02:	e822                	sd	s0,16(sp)
    80003c04:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003c06:	fec40593          	addi	a1,s0,-20
    80003c0a:	4501                	li	a0,0
    80003c0c:	00000097          	auipc	ra,0x0
    80003c10:	f02080e7          	jalr	-254(ra) # 80003b0e <argint>
    return -1;
    80003c14:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003c16:	00054963          	bltz	a0,80003c28 <sys_exit+0x2a>
  exit(n);
    80003c1a:	fec42503          	lw	a0,-20(s0)
    80003c1e:	fffff097          	auipc	ra,0xfffff
    80003c22:	d0c080e7          	jalr	-756(ra) # 8000292a <exit>
  return 0;  // not reached
    80003c26:	4781                	li	a5,0
}
    80003c28:	853e                	mv	a0,a5
    80003c2a:	60e2                	ld	ra,24(sp)
    80003c2c:	6442                	ld	s0,16(sp)
    80003c2e:	6105                	addi	sp,sp,32
    80003c30:	8082                	ret

0000000080003c32 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003c32:	1141                	addi	sp,sp,-16
    80003c34:	e406                	sd	ra,8(sp)
    80003c36:	e022                	sd	s0,0(sp)
    80003c38:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003c3a:	ffffe097          	auipc	ra,0xffffe
    80003c3e:	e42080e7          	jalr	-446(ra) # 80001a7c <myproc>
}
    80003c42:	5148                	lw	a0,36(a0)
    80003c44:	60a2                	ld	ra,8(sp)
    80003c46:	6402                	ld	s0,0(sp)
    80003c48:	0141                	addi	sp,sp,16
    80003c4a:	8082                	ret

0000000080003c4c <sys_fork>:

uint64
sys_fork(void)
{
    80003c4c:	1141                	addi	sp,sp,-16
    80003c4e:	e406                	sd	ra,8(sp)
    80003c50:	e022                	sd	s0,0(sp)
    80003c52:	0800                	addi	s0,sp,16
  return fork();
    80003c54:	ffffe097          	auipc	ra,0xffffe
    80003c58:	3a4080e7          	jalr	932(ra) # 80001ff8 <fork>
}
    80003c5c:	60a2                	ld	ra,8(sp)
    80003c5e:	6402                	ld	s0,0(sp)
    80003c60:	0141                	addi	sp,sp,16
    80003c62:	8082                	ret

0000000080003c64 <sys_wait>:

uint64
sys_wait(void)
{
    80003c64:	1101                	addi	sp,sp,-32
    80003c66:	ec06                	sd	ra,24(sp)
    80003c68:	e822                	sd	s0,16(sp)
    80003c6a:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003c6c:	fe840593          	addi	a1,s0,-24
    80003c70:	4501                	li	a0,0
    80003c72:	00000097          	auipc	ra,0x0
    80003c76:	ebe080e7          	jalr	-322(ra) # 80003b30 <argaddr>
    80003c7a:	87aa                	mv	a5,a0
    return -1;
    80003c7c:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003c7e:	0007c863          	bltz	a5,80003c8e <sys_wait+0x2a>
  return wait(p);
    80003c82:	fe843503          	ld	a0,-24(s0)
    80003c86:	fffff097          	auipc	ra,0xfffff
    80003c8a:	830080e7          	jalr	-2000(ra) # 800024b6 <wait>
}
    80003c8e:	60e2                	ld	ra,24(sp)
    80003c90:	6442                	ld	s0,16(sp)
    80003c92:	6105                	addi	sp,sp,32
    80003c94:	8082                	ret

0000000080003c96 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003c96:	7179                	addi	sp,sp,-48
    80003c98:	f406                	sd	ra,40(sp)
    80003c9a:	f022                	sd	s0,32(sp)
    80003c9c:	ec26                	sd	s1,24(sp)
    80003c9e:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003ca0:	fdc40593          	addi	a1,s0,-36
    80003ca4:	4501                	li	a0,0
    80003ca6:	00000097          	auipc	ra,0x0
    80003caa:	e68080e7          	jalr	-408(ra) # 80003b0e <argint>
    return -1;
    80003cae:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003cb0:	00054f63          	bltz	a0,80003cce <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003cb4:	ffffe097          	auipc	ra,0xffffe
    80003cb8:	dc8080e7          	jalr	-568(ra) # 80001a7c <myproc>
    80003cbc:	5d04                	lw	s1,56(a0)
  if(growproc(n) < 0)
    80003cbe:	fdc42503          	lw	a0,-36(s0)
    80003cc2:	ffffe097          	auipc	ra,0xffffe
    80003cc6:	2c2080e7          	jalr	706(ra) # 80001f84 <growproc>
    80003cca:	00054863          	bltz	a0,80003cda <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003cce:	8526                	mv	a0,s1
    80003cd0:	70a2                	ld	ra,40(sp)
    80003cd2:	7402                	ld	s0,32(sp)
    80003cd4:	64e2                	ld	s1,24(sp)
    80003cd6:	6145                	addi	sp,sp,48
    80003cd8:	8082                	ret
    return -1;
    80003cda:	54fd                	li	s1,-1
    80003cdc:	bfcd                	j	80003cce <sys_sbrk+0x38>

0000000080003cde <sys_sleep>:

uint64
sys_sleep(void)
{
    80003cde:	7139                	addi	sp,sp,-64
    80003ce0:	fc06                	sd	ra,56(sp)
    80003ce2:	f822                	sd	s0,48(sp)
    80003ce4:	f426                	sd	s1,40(sp)
    80003ce6:	f04a                	sd	s2,32(sp)
    80003ce8:	ec4e                	sd	s3,24(sp)
    80003cea:	e852                	sd	s4,16(sp)
    80003cec:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003cee:	fcc40593          	addi	a1,s0,-52
    80003cf2:	4501                	li	a0,0
    80003cf4:	00000097          	auipc	ra,0x0
    80003cf8:	e1a080e7          	jalr	-486(ra) # 80003b0e <argint>
    return -1;
    80003cfc:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003cfe:	06054763          	bltz	a0,80003d6c <sys_sleep+0x8e>
  acquire(&tickslock);
    80003d02:	00030517          	auipc	a0,0x30
    80003d06:	c2650513          	addi	a0,a0,-986 # 80033928 <tickslock>
    80003d0a:	ffffd097          	auipc	ra,0xffffd
    80003d0e:	ebc080e7          	jalr	-324(ra) # 80000bc6 <acquire>
  ticks0 = ticks;
    80003d12:	00006997          	auipc	s3,0x6
    80003d16:	31e9a983          	lw	s3,798(s3) # 8000a030 <ticks>
  while(ticks - ticks0 < n){
    80003d1a:	fcc42783          	lw	a5,-52(s0)
    80003d1e:	cf95                	beqz	a5,80003d5a <sys_sleep+0x7c>
    if(myproc()->killed==1){
    80003d20:	4905                	li	s2,1
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003d22:	00030a17          	auipc	s4,0x30
    80003d26:	c06a0a13          	addi	s4,s4,-1018 # 80033928 <tickslock>
    80003d2a:	00006497          	auipc	s1,0x6
    80003d2e:	30648493          	addi	s1,s1,774 # 8000a030 <ticks>
    if(myproc()->killed==1){
    80003d32:	ffffe097          	auipc	ra,0xffffe
    80003d36:	d4a080e7          	jalr	-694(ra) # 80001a7c <myproc>
    80003d3a:	4d5c                	lw	a5,28(a0)
    80003d3c:	05278163          	beq	a5,s2,80003d7e <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    80003d40:	85d2                	mv	a1,s4
    80003d42:	8526                	mv	a0,s1
    80003d44:	ffffe097          	auipc	ra,0xffffe
    80003d48:	704080e7          	jalr	1796(ra) # 80002448 <sleep>
  while(ticks - ticks0 < n){
    80003d4c:	409c                	lw	a5,0(s1)
    80003d4e:	413787bb          	subw	a5,a5,s3
    80003d52:	fcc42703          	lw	a4,-52(s0)
    80003d56:	fce7eee3          	bltu	a5,a4,80003d32 <sys_sleep+0x54>
  }
  release(&tickslock);
    80003d5a:	00030517          	auipc	a0,0x30
    80003d5e:	bce50513          	addi	a0,a0,-1074 # 80033928 <tickslock>
    80003d62:	ffffd097          	auipc	ra,0xffffd
    80003d66:	f3a080e7          	jalr	-198(ra) # 80000c9c <release>
  return 0;
    80003d6a:	4781                	li	a5,0
}
    80003d6c:	853e                	mv	a0,a5
    80003d6e:	70e2                	ld	ra,56(sp)
    80003d70:	7442                	ld	s0,48(sp)
    80003d72:	74a2                	ld	s1,40(sp)
    80003d74:	7902                	ld	s2,32(sp)
    80003d76:	69e2                	ld	s3,24(sp)
    80003d78:	6a42                	ld	s4,16(sp)
    80003d7a:	6121                	addi	sp,sp,64
    80003d7c:	8082                	ret
      release(&tickslock);
    80003d7e:	00030517          	auipc	a0,0x30
    80003d82:	baa50513          	addi	a0,a0,-1110 # 80033928 <tickslock>
    80003d86:	ffffd097          	auipc	ra,0xffffd
    80003d8a:	f16080e7          	jalr	-234(ra) # 80000c9c <release>
      return -1;
    80003d8e:	57fd                	li	a5,-1
    80003d90:	bff1                	j	80003d6c <sys_sleep+0x8e>

0000000080003d92 <sys_kill>:

uint64
sys_kill(void)
{
    80003d92:	1101                	addi	sp,sp,-32
    80003d94:	ec06                	sd	ra,24(sp)
    80003d96:	e822                	sd	s0,16(sp)
    80003d98:	1000                	addi	s0,sp,32
  int pid;
  int signum;

  if(argint(0, &pid) < 0)
    80003d9a:	fec40593          	addi	a1,s0,-20
    80003d9e:	4501                	li	a0,0
    80003da0:	00000097          	auipc	ra,0x0
    80003da4:	d6e080e7          	jalr	-658(ra) # 80003b0e <argint>
    80003da8:	87aa                	mv	a5,a0
    return -1;
    80003daa:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003dac:	0207c963          	bltz	a5,80003dde <sys_kill+0x4c>
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003db0:	fe840593          	addi	a1,s0,-24
    80003db4:	4505                	li	a0,1
    80003db6:	00000097          	auipc	ra,0x0
    80003dba:	d58080e7          	jalr	-680(ra) # 80003b0e <argint>
    80003dbe:	02054463          	bltz	a0,80003de6 <sys_kill+0x54>
    80003dc2:	fe842583          	lw	a1,-24(s0)
    80003dc6:	0005871b          	sext.w	a4,a1
    80003dca:	47fd                	li	a5,31
    return -1;
    80003dcc:	557d                	li	a0,-1
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003dce:	00e7e863          	bltu	a5,a4,80003dde <sys_kill+0x4c>
  return kill(pid, signum);
    80003dd2:	fec42503          	lw	a0,-20(s0)
    80003dd6:	fffff097          	auipc	ra,0xfffff
    80003dda:	f8c080e7          	jalr	-116(ra) # 80002d62 <kill>
}
    80003dde:	60e2                	ld	ra,24(sp)
    80003de0:	6442                	ld	s0,16(sp)
    80003de2:	6105                	addi	sp,sp,32
    80003de4:	8082                	ret
    return -1;
    80003de6:	557d                	li	a0,-1
    80003de8:	bfdd                	j	80003dde <sys_kill+0x4c>

0000000080003dea <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003dea:	1101                	addi	sp,sp,-32
    80003dec:	ec06                	sd	ra,24(sp)
    80003dee:	e822                	sd	s0,16(sp)
    80003df0:	e426                	sd	s1,8(sp)
    80003df2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003df4:	00030517          	auipc	a0,0x30
    80003df8:	b3450513          	addi	a0,a0,-1228 # 80033928 <tickslock>
    80003dfc:	ffffd097          	auipc	ra,0xffffd
    80003e00:	dca080e7          	jalr	-566(ra) # 80000bc6 <acquire>
  xticks = ticks;
    80003e04:	00006497          	auipc	s1,0x6
    80003e08:	22c4a483          	lw	s1,556(s1) # 8000a030 <ticks>
  release(&tickslock);
    80003e0c:	00030517          	auipc	a0,0x30
    80003e10:	b1c50513          	addi	a0,a0,-1252 # 80033928 <tickslock>
    80003e14:	ffffd097          	auipc	ra,0xffffd
    80003e18:	e88080e7          	jalr	-376(ra) # 80000c9c <release>
  return xticks;
}
    80003e1c:	02049513          	slli	a0,s1,0x20
    80003e20:	9101                	srli	a0,a0,0x20
    80003e22:	60e2                	ld	ra,24(sp)
    80003e24:	6442                	ld	s0,16(sp)
    80003e26:	64a2                	ld	s1,8(sp)
    80003e28:	6105                	addi	sp,sp,32
    80003e2a:	8082                	ret

0000000080003e2c <sys_sigprocmask>:

uint64
sys_sigprocmask(void)
{
    80003e2c:	1101                	addi	sp,sp,-32
    80003e2e:	ec06                	sd	ra,24(sp)
    80003e30:	e822                	sd	s0,16(sp)
    80003e32:	1000                	addi	s0,sp,32
  int sigmask;

  if(argint(0, &sigmask) < 0)
    80003e34:	fec40593          	addi	a1,s0,-20
    80003e38:	4501                	li	a0,0
    80003e3a:	00000097          	auipc	ra,0x0
    80003e3e:	cd4080e7          	jalr	-812(ra) # 80003b0e <argint>
    80003e42:	87aa                	mv	a5,a0
    return -1;
    80003e44:	557d                	li	a0,-1
  if(argint(0, &sigmask) < 0)
    80003e46:	0007ca63          	bltz	a5,80003e5a <sys_sigprocmask+0x2e>
  return sigprocmask((uint)sigmask);
    80003e4a:	fec42503          	lw	a0,-20(s0)
    80003e4e:	fffff097          	auipc	ra,0xfffff
    80003e52:	d42080e7          	jalr	-702(ra) # 80002b90 <sigprocmask>
    80003e56:	1502                	slli	a0,a0,0x20
    80003e58:	9101                	srli	a0,a0,0x20
}
    80003e5a:	60e2                	ld	ra,24(sp)
    80003e5c:	6442                	ld	s0,16(sp)
    80003e5e:	6105                	addi	sp,sp,32
    80003e60:	8082                	ret

0000000080003e62 <sys_sigaction>:

uint64
sys_sigaction(void)
{
    80003e62:	7179                	addi	sp,sp,-48
    80003e64:	f406                	sd	ra,40(sp)
    80003e66:	f022                	sd	s0,32(sp)
    80003e68:	1800                	addi	s0,sp,48
  int signum;
  uint64 newact;
  uint64 oldact;
  
  if(argint(0, &signum) < 0)
    80003e6a:	fec40593          	addi	a1,s0,-20
    80003e6e:	4501                	li	a0,0
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	c9e080e7          	jalr	-866(ra) # 80003b0e <argint>
    return -1;
    80003e78:	57fd                	li	a5,-1
  if(argint(0, &signum) < 0)
    80003e7a:	04054163          	bltz	a0,80003ebc <sys_sigaction+0x5a>
  if(argaddr(1, &newact) < 0)
    80003e7e:	fe040593          	addi	a1,s0,-32
    80003e82:	4505                	li	a0,1
    80003e84:	00000097          	auipc	ra,0x0
    80003e88:	cac080e7          	jalr	-852(ra) # 80003b30 <argaddr>
    return -1;
    80003e8c:	57fd                	li	a5,-1
  if(argaddr(1, &newact) < 0)
    80003e8e:	02054763          	bltz	a0,80003ebc <sys_sigaction+0x5a>
  if(argaddr(2, &oldact) < 0)
    80003e92:	fd840593          	addi	a1,s0,-40
    80003e96:	4509                	li	a0,2
    80003e98:	00000097          	auipc	ra,0x0
    80003e9c:	c98080e7          	jalr	-872(ra) # 80003b30 <argaddr>
    return -1;
    80003ea0:	57fd                	li	a5,-1
  if(argaddr(2, &oldact) < 0)
    80003ea2:	00054d63          	bltz	a0,80003ebc <sys_sigaction+0x5a>

  return sigaction(signum,newact,oldact);
    80003ea6:	fd843603          	ld	a2,-40(s0)
    80003eaa:	fe043583          	ld	a1,-32(s0)
    80003eae:	fec42503          	lw	a0,-20(s0)
    80003eb2:	fffff097          	auipc	ra,0xfffff
    80003eb6:	d32080e7          	jalr	-718(ra) # 80002be4 <sigaction>
    80003eba:	87aa                	mv	a5,a0
  
}
    80003ebc:	853e                	mv	a0,a5
    80003ebe:	70a2                	ld	ra,40(sp)
    80003ec0:	7402                	ld	s0,32(sp)
    80003ec2:	6145                	addi	sp,sp,48
    80003ec4:	8082                	ret

0000000080003ec6 <sys_sigret>:
uint64
sys_sigret(void)
{
    80003ec6:	1141                	addi	sp,sp,-16
    80003ec8:	e406                	sd	ra,8(sp)
    80003eca:	e022                	sd	s0,0(sp)
    80003ecc:	0800                	addi	s0,sp,16
  sigret();
    80003ece:	fffff097          	auipc	ra,0xfffff
    80003ed2:	e00080e7          	jalr	-512(ra) # 80002cce <sigret>
  return 0;
}
    80003ed6:	4501                	li	a0,0
    80003ed8:	60a2                	ld	ra,8(sp)
    80003eda:	6402                	ld	s0,0(sp)
    80003edc:	0141                	addi	sp,sp,16
    80003ede:	8082                	ret

0000000080003ee0 <sys_kthread_create>:

uint64
sys_kthread_create(void)
{
    80003ee0:	1101                	addi	sp,sp,-32
    80003ee2:	ec06                	sd	ra,24(sp)
    80003ee4:	e822                	sd	s0,16(sp)
    80003ee6:	1000                	addi	s0,sp,32
  uint64 start_func;
  uint64 stack;
  if(argaddr(0, &start_func) < 0)
    80003ee8:	fe840593          	addi	a1,s0,-24
    80003eec:	4501                	li	a0,0
    80003eee:	00000097          	auipc	ra,0x0
    80003ef2:	c42080e7          	jalr	-958(ra) # 80003b30 <argaddr>
    80003ef6:	02054463          	bltz	a0,80003f1e <sys_kthread_create+0x3e>
    return -1;
  if(argaddr(1, &stack) < 0)
    80003efa:	fe040593          	addi	a1,s0,-32
    80003efe:	4505                	li	a0,1
    80003f00:	00000097          	auipc	ra,0x0
    80003f04:	c30080e7          	jalr	-976(ra) # 80003b30 <argaddr>
    80003f08:	00054b63          	bltz	a0,80003f1e <sys_kthread_create+0x3e>
    return -1;
  kthread_create(start_func,stack);
    80003f0c:	fe043583          	ld	a1,-32(s0)
    80003f10:	fe843503          	ld	a0,-24(s0)
    80003f14:	fffff097          	auipc	ra,0xfffff
    80003f18:	f74080e7          	jalr	-140(ra) # 80002e88 <kthread_create>
}
    80003f1c:	a011                	j	80003f20 <sys_kthread_create+0x40>
    80003f1e:	557d                	li	a0,-1
    80003f20:	60e2                	ld	ra,24(sp)
    80003f22:	6442                	ld	s0,16(sp)
    80003f24:	6105                	addi	sp,sp,32
    80003f26:	8082                	ret

0000000080003f28 <sys_kthread_id>:

uint64
sys_kthread_id(void){
    80003f28:	1141                	addi	sp,sp,-16
    80003f2a:	e406                	sd	ra,8(sp)
    80003f2c:	e022                	sd	s0,0(sp)
    80003f2e:	0800                	addi	s0,sp,16
  return mykthread()->tid;
    80003f30:	ffffe097          	auipc	ra,0xffffe
    80003f34:	b8c080e7          	jalr	-1140(ra) # 80001abc <mykthread>
}
    80003f38:	5908                	lw	a0,48(a0)
    80003f3a:	60a2                	ld	ra,8(sp)
    80003f3c:	6402                	ld	s0,0(sp)
    80003f3e:	0141                	addi	sp,sp,16
    80003f40:	8082                	ret

0000000080003f42 <sys_kthread_exit>:

uint64
sys_kthread_exit(void){
    80003f42:	1101                	addi	sp,sp,-32
    80003f44:	ec06                	sd	ra,24(sp)
    80003f46:	e822                	sd	s0,16(sp)
    80003f48:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003f4a:	fec40593          	addi	a1,s0,-20
    80003f4e:	4501                	li	a0,0
    80003f50:	00000097          	auipc	ra,0x0
    80003f54:	bbe080e7          	jalr	-1090(ra) # 80003b0e <argint>
    return -1;
    80003f58:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003f5a:	00054963          	bltz	a0,80003f6c <sys_kthread_exit+0x2a>
  kthread_exit(n);
    80003f5e:	fec42503          	lw	a0,-20(s0)
    80003f62:	fffff097          	auipc	ra,0xfffff
    80003f66:	92a080e7          	jalr	-1750(ra) # 8000288c <kthread_exit>
  
  return 0;  // not reached
    80003f6a:	4781                	li	a5,0
}
    80003f6c:	853e                	mv	a0,a5
    80003f6e:	60e2                	ld	ra,24(sp)
    80003f70:	6442                	ld	s0,16(sp)
    80003f72:	6105                	addi	sp,sp,32
    80003f74:	8082                	ret

0000000080003f76 <sys_kthread_join>:

uint64 
sys_kthread_join(){
    80003f76:	1101                	addi	sp,sp,-32
    80003f78:	ec06                	sd	ra,24(sp)
    80003f7a:	e822                	sd	s0,16(sp)
    80003f7c:	1000                	addi	s0,sp,32
  int thread_id;
  uint64 status;
  if(argint(0, &thread_id) < 0)
    80003f7e:	fec40593          	addi	a1,s0,-20
    80003f82:	4501                	li	a0,0
    80003f84:	00000097          	auipc	ra,0x0
    80003f88:	b8a080e7          	jalr	-1142(ra) # 80003b0e <argint>
    return -1;
    80003f8c:	57fd                	li	a5,-1
  if(argint(0, &thread_id) < 0)
    80003f8e:	02054563          	bltz	a0,80003fb8 <sys_kthread_join+0x42>
  if(argaddr(1, &status) < 0)
    80003f92:	fe040593          	addi	a1,s0,-32
    80003f96:	4505                	li	a0,1
    80003f98:	00000097          	auipc	ra,0x0
    80003f9c:	b98080e7          	jalr	-1128(ra) # 80003b30 <argaddr>
    return -1;
    80003fa0:	57fd                	li	a5,-1
  if(argaddr(1, &status) < 0)
    80003fa2:	00054b63          	bltz	a0,80003fb8 <sys_kthread_join+0x42>
  
  return kthread_join(thread_id, status);
    80003fa6:	fe043583          	ld	a1,-32(s0)
    80003faa:	fec42503          	lw	a0,-20(s0)
    80003fae:	fffff097          	auipc	ra,0xfffff
    80003fb2:	fde080e7          	jalr	-34(ra) # 80002f8c <kthread_join>
    80003fb6:	87aa                	mv	a5,a0
    80003fb8:	853e                	mv	a0,a5
    80003fba:	60e2                	ld	ra,24(sp)
    80003fbc:	6442                	ld	s0,16(sp)
    80003fbe:	6105                	addi	sp,sp,32
    80003fc0:	8082                	ret

0000000080003fc2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003fc2:	7179                	addi	sp,sp,-48
    80003fc4:	f406                	sd	ra,40(sp)
    80003fc6:	f022                	sd	s0,32(sp)
    80003fc8:	ec26                	sd	s1,24(sp)
    80003fca:	e84a                	sd	s2,16(sp)
    80003fcc:	e44e                	sd	s3,8(sp)
    80003fce:	e052                	sd	s4,0(sp)
    80003fd0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003fd2:	00005597          	auipc	a1,0x5
    80003fd6:	74e58593          	addi	a1,a1,1870 # 80009720 <syscalls+0xe8>
    80003fda:	00030517          	auipc	a0,0x30
    80003fde:	96650513          	addi	a0,a0,-1690 # 80033940 <bcache>
    80003fe2:	ffffd097          	auipc	ra,0xffffd
    80003fe6:	b54080e7          	jalr	-1196(ra) # 80000b36 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003fea:	00038797          	auipc	a5,0x38
    80003fee:	95678793          	addi	a5,a5,-1706 # 8003b940 <bcache+0x8000>
    80003ff2:	00038717          	auipc	a4,0x38
    80003ff6:	bb670713          	addi	a4,a4,-1098 # 8003bba8 <bcache+0x8268>
    80003ffa:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003ffe:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80004002:	00030497          	auipc	s1,0x30
    80004006:	95648493          	addi	s1,s1,-1706 # 80033958 <bcache+0x18>
    b->next = bcache.head.next;
    8000400a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000400c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000400e:	00005a17          	auipc	s4,0x5
    80004012:	71aa0a13          	addi	s4,s4,1818 # 80009728 <syscalls+0xf0>
    b->next = bcache.head.next;
    80004016:	2b893783          	ld	a5,696(s2)
    8000401a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000401c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80004020:	85d2                	mv	a1,s4
    80004022:	01048513          	addi	a0,s1,16
    80004026:	00001097          	auipc	ra,0x1
    8000402a:	4c0080e7          	jalr	1216(ra) # 800054e6 <initsleeplock>
    bcache.head.next->prev = b;
    8000402e:	2b893783          	ld	a5,696(s2)
    80004032:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80004034:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80004038:	45848493          	addi	s1,s1,1112
    8000403c:	fd349de3          	bne	s1,s3,80004016 <binit+0x54>
  }
}
    80004040:	70a2                	ld	ra,40(sp)
    80004042:	7402                	ld	s0,32(sp)
    80004044:	64e2                	ld	s1,24(sp)
    80004046:	6942                	ld	s2,16(sp)
    80004048:	69a2                	ld	s3,8(sp)
    8000404a:	6a02                	ld	s4,0(sp)
    8000404c:	6145                	addi	sp,sp,48
    8000404e:	8082                	ret

0000000080004050 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80004050:	7179                	addi	sp,sp,-48
    80004052:	f406                	sd	ra,40(sp)
    80004054:	f022                	sd	s0,32(sp)
    80004056:	ec26                	sd	s1,24(sp)
    80004058:	e84a                	sd	s2,16(sp)
    8000405a:	e44e                	sd	s3,8(sp)
    8000405c:	1800                	addi	s0,sp,48
    8000405e:	892a                	mv	s2,a0
    80004060:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80004062:	00030517          	auipc	a0,0x30
    80004066:	8de50513          	addi	a0,a0,-1826 # 80033940 <bcache>
    8000406a:	ffffd097          	auipc	ra,0xffffd
    8000406e:	b5c080e7          	jalr	-1188(ra) # 80000bc6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80004072:	00038497          	auipc	s1,0x38
    80004076:	b864b483          	ld	s1,-1146(s1) # 8003bbf8 <bcache+0x82b8>
    8000407a:	00038797          	auipc	a5,0x38
    8000407e:	b2e78793          	addi	a5,a5,-1234 # 8003bba8 <bcache+0x8268>
    80004082:	02f48f63          	beq	s1,a5,800040c0 <bread+0x70>
    80004086:	873e                	mv	a4,a5
    80004088:	a021                	j	80004090 <bread+0x40>
    8000408a:	68a4                	ld	s1,80(s1)
    8000408c:	02e48a63          	beq	s1,a4,800040c0 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80004090:	449c                	lw	a5,8(s1)
    80004092:	ff279ce3          	bne	a5,s2,8000408a <bread+0x3a>
    80004096:	44dc                	lw	a5,12(s1)
    80004098:	ff3799e3          	bne	a5,s3,8000408a <bread+0x3a>
      b->refcnt++;
    8000409c:	40bc                	lw	a5,64(s1)
    8000409e:	2785                	addiw	a5,a5,1
    800040a0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800040a2:	00030517          	auipc	a0,0x30
    800040a6:	89e50513          	addi	a0,a0,-1890 # 80033940 <bcache>
    800040aa:	ffffd097          	auipc	ra,0xffffd
    800040ae:	bf2080e7          	jalr	-1038(ra) # 80000c9c <release>
      acquiresleep(&b->lock);
    800040b2:	01048513          	addi	a0,s1,16
    800040b6:	00001097          	auipc	ra,0x1
    800040ba:	46a080e7          	jalr	1130(ra) # 80005520 <acquiresleep>
      return b;
    800040be:	a8b9                	j	8000411c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800040c0:	00038497          	auipc	s1,0x38
    800040c4:	b304b483          	ld	s1,-1232(s1) # 8003bbf0 <bcache+0x82b0>
    800040c8:	00038797          	auipc	a5,0x38
    800040cc:	ae078793          	addi	a5,a5,-1312 # 8003bba8 <bcache+0x8268>
    800040d0:	00f48863          	beq	s1,a5,800040e0 <bread+0x90>
    800040d4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800040d6:	40bc                	lw	a5,64(s1)
    800040d8:	cf81                	beqz	a5,800040f0 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800040da:	64a4                	ld	s1,72(s1)
    800040dc:	fee49de3          	bne	s1,a4,800040d6 <bread+0x86>
  panic("bget: no buffers");
    800040e0:	00005517          	auipc	a0,0x5
    800040e4:	65050513          	addi	a0,a0,1616 # 80009730 <syscalls+0xf8>
    800040e8:	ffffc097          	auipc	ra,0xffffc
    800040ec:	446080e7          	jalr	1094(ra) # 8000052e <panic>
      b->dev = dev;
    800040f0:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800040f4:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800040f8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800040fc:	4785                	li	a5,1
    800040fe:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80004100:	00030517          	auipc	a0,0x30
    80004104:	84050513          	addi	a0,a0,-1984 # 80033940 <bcache>
    80004108:	ffffd097          	auipc	ra,0xffffd
    8000410c:	b94080e7          	jalr	-1132(ra) # 80000c9c <release>
      acquiresleep(&b->lock);
    80004110:	01048513          	addi	a0,s1,16
    80004114:	00001097          	auipc	ra,0x1
    80004118:	40c080e7          	jalr	1036(ra) # 80005520 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000411c:	409c                	lw	a5,0(s1)
    8000411e:	cb89                	beqz	a5,80004130 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80004120:	8526                	mv	a0,s1
    80004122:	70a2                	ld	ra,40(sp)
    80004124:	7402                	ld	s0,32(sp)
    80004126:	64e2                	ld	s1,24(sp)
    80004128:	6942                	ld	s2,16(sp)
    8000412a:	69a2                	ld	s3,8(sp)
    8000412c:	6145                	addi	sp,sp,48
    8000412e:	8082                	ret
    virtio_disk_rw(b, 0);
    80004130:	4581                	li	a1,0
    80004132:	8526                	mv	a0,s1
    80004134:	00003097          	auipc	ra,0x3
    80004138:	fc2080e7          	jalr	-62(ra) # 800070f6 <virtio_disk_rw>
    b->valid = 1;
    8000413c:	4785                	li	a5,1
    8000413e:	c09c                	sw	a5,0(s1)
  return b;
    80004140:	b7c5                	j	80004120 <bread+0xd0>

0000000080004142 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80004142:	1101                	addi	sp,sp,-32
    80004144:	ec06                	sd	ra,24(sp)
    80004146:	e822                	sd	s0,16(sp)
    80004148:	e426                	sd	s1,8(sp)
    8000414a:	1000                	addi	s0,sp,32
    8000414c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000414e:	0541                	addi	a0,a0,16
    80004150:	00001097          	auipc	ra,0x1
    80004154:	46a080e7          	jalr	1130(ra) # 800055ba <holdingsleep>
    80004158:	cd01                	beqz	a0,80004170 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000415a:	4585                	li	a1,1
    8000415c:	8526                	mv	a0,s1
    8000415e:	00003097          	auipc	ra,0x3
    80004162:	f98080e7          	jalr	-104(ra) # 800070f6 <virtio_disk_rw>
}
    80004166:	60e2                	ld	ra,24(sp)
    80004168:	6442                	ld	s0,16(sp)
    8000416a:	64a2                	ld	s1,8(sp)
    8000416c:	6105                	addi	sp,sp,32
    8000416e:	8082                	ret
    panic("bwrite");
    80004170:	00005517          	auipc	a0,0x5
    80004174:	5d850513          	addi	a0,a0,1496 # 80009748 <syscalls+0x110>
    80004178:	ffffc097          	auipc	ra,0xffffc
    8000417c:	3b6080e7          	jalr	950(ra) # 8000052e <panic>

0000000080004180 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80004180:	1101                	addi	sp,sp,-32
    80004182:	ec06                	sd	ra,24(sp)
    80004184:	e822                	sd	s0,16(sp)
    80004186:	e426                	sd	s1,8(sp)
    80004188:	e04a                	sd	s2,0(sp)
    8000418a:	1000                	addi	s0,sp,32
    8000418c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000418e:	01050913          	addi	s2,a0,16
    80004192:	854a                	mv	a0,s2
    80004194:	00001097          	auipc	ra,0x1
    80004198:	426080e7          	jalr	1062(ra) # 800055ba <holdingsleep>
    8000419c:	c92d                	beqz	a0,8000420e <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000419e:	854a                	mv	a0,s2
    800041a0:	00001097          	auipc	ra,0x1
    800041a4:	3d6080e7          	jalr	982(ra) # 80005576 <releasesleep>

  acquire(&bcache.lock);
    800041a8:	0002f517          	auipc	a0,0x2f
    800041ac:	79850513          	addi	a0,a0,1944 # 80033940 <bcache>
    800041b0:	ffffd097          	auipc	ra,0xffffd
    800041b4:	a16080e7          	jalr	-1514(ra) # 80000bc6 <acquire>
  b->refcnt--;
    800041b8:	40bc                	lw	a5,64(s1)
    800041ba:	37fd                	addiw	a5,a5,-1
    800041bc:	0007871b          	sext.w	a4,a5
    800041c0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800041c2:	eb05                	bnez	a4,800041f2 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800041c4:	68bc                	ld	a5,80(s1)
    800041c6:	64b8                	ld	a4,72(s1)
    800041c8:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800041ca:	64bc                	ld	a5,72(s1)
    800041cc:	68b8                	ld	a4,80(s1)
    800041ce:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800041d0:	00037797          	auipc	a5,0x37
    800041d4:	77078793          	addi	a5,a5,1904 # 8003b940 <bcache+0x8000>
    800041d8:	2b87b703          	ld	a4,696(a5)
    800041dc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800041de:	00038717          	auipc	a4,0x38
    800041e2:	9ca70713          	addi	a4,a4,-1590 # 8003bba8 <bcache+0x8268>
    800041e6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800041e8:	2b87b703          	ld	a4,696(a5)
    800041ec:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800041ee:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800041f2:	0002f517          	auipc	a0,0x2f
    800041f6:	74e50513          	addi	a0,a0,1870 # 80033940 <bcache>
    800041fa:	ffffd097          	auipc	ra,0xffffd
    800041fe:	aa2080e7          	jalr	-1374(ra) # 80000c9c <release>
}
    80004202:	60e2                	ld	ra,24(sp)
    80004204:	6442                	ld	s0,16(sp)
    80004206:	64a2                	ld	s1,8(sp)
    80004208:	6902                	ld	s2,0(sp)
    8000420a:	6105                	addi	sp,sp,32
    8000420c:	8082                	ret
    panic("brelse");
    8000420e:	00005517          	auipc	a0,0x5
    80004212:	54250513          	addi	a0,a0,1346 # 80009750 <syscalls+0x118>
    80004216:	ffffc097          	auipc	ra,0xffffc
    8000421a:	318080e7          	jalr	792(ra) # 8000052e <panic>

000000008000421e <bpin>:

void
bpin(struct buf *b) {
    8000421e:	1101                	addi	sp,sp,-32
    80004220:	ec06                	sd	ra,24(sp)
    80004222:	e822                	sd	s0,16(sp)
    80004224:	e426                	sd	s1,8(sp)
    80004226:	1000                	addi	s0,sp,32
    80004228:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000422a:	0002f517          	auipc	a0,0x2f
    8000422e:	71650513          	addi	a0,a0,1814 # 80033940 <bcache>
    80004232:	ffffd097          	auipc	ra,0xffffd
    80004236:	994080e7          	jalr	-1644(ra) # 80000bc6 <acquire>
  b->refcnt++;
    8000423a:	40bc                	lw	a5,64(s1)
    8000423c:	2785                	addiw	a5,a5,1
    8000423e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004240:	0002f517          	auipc	a0,0x2f
    80004244:	70050513          	addi	a0,a0,1792 # 80033940 <bcache>
    80004248:	ffffd097          	auipc	ra,0xffffd
    8000424c:	a54080e7          	jalr	-1452(ra) # 80000c9c <release>
}
    80004250:	60e2                	ld	ra,24(sp)
    80004252:	6442                	ld	s0,16(sp)
    80004254:	64a2                	ld	s1,8(sp)
    80004256:	6105                	addi	sp,sp,32
    80004258:	8082                	ret

000000008000425a <bunpin>:

void
bunpin(struct buf *b) {
    8000425a:	1101                	addi	sp,sp,-32
    8000425c:	ec06                	sd	ra,24(sp)
    8000425e:	e822                	sd	s0,16(sp)
    80004260:	e426                	sd	s1,8(sp)
    80004262:	1000                	addi	s0,sp,32
    80004264:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004266:	0002f517          	auipc	a0,0x2f
    8000426a:	6da50513          	addi	a0,a0,1754 # 80033940 <bcache>
    8000426e:	ffffd097          	auipc	ra,0xffffd
    80004272:	958080e7          	jalr	-1704(ra) # 80000bc6 <acquire>
  b->refcnt--;
    80004276:	40bc                	lw	a5,64(s1)
    80004278:	37fd                	addiw	a5,a5,-1
    8000427a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000427c:	0002f517          	auipc	a0,0x2f
    80004280:	6c450513          	addi	a0,a0,1732 # 80033940 <bcache>
    80004284:	ffffd097          	auipc	ra,0xffffd
    80004288:	a18080e7          	jalr	-1512(ra) # 80000c9c <release>
}
    8000428c:	60e2                	ld	ra,24(sp)
    8000428e:	6442                	ld	s0,16(sp)
    80004290:	64a2                	ld	s1,8(sp)
    80004292:	6105                	addi	sp,sp,32
    80004294:	8082                	ret

0000000080004296 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80004296:	1101                	addi	sp,sp,-32
    80004298:	ec06                	sd	ra,24(sp)
    8000429a:	e822                	sd	s0,16(sp)
    8000429c:	e426                	sd	s1,8(sp)
    8000429e:	e04a                	sd	s2,0(sp)
    800042a0:	1000                	addi	s0,sp,32
    800042a2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800042a4:	00d5d59b          	srliw	a1,a1,0xd
    800042a8:	00038797          	auipc	a5,0x38
    800042ac:	d747a783          	lw	a5,-652(a5) # 8003c01c <sb+0x1c>
    800042b0:	9dbd                	addw	a1,a1,a5
    800042b2:	00000097          	auipc	ra,0x0
    800042b6:	d9e080e7          	jalr	-610(ra) # 80004050 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800042ba:	0074f713          	andi	a4,s1,7
    800042be:	4785                	li	a5,1
    800042c0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800042c4:	14ce                	slli	s1,s1,0x33
    800042c6:	90d9                	srli	s1,s1,0x36
    800042c8:	00950733          	add	a4,a0,s1
    800042cc:	05874703          	lbu	a4,88(a4)
    800042d0:	00e7f6b3          	and	a3,a5,a4
    800042d4:	c69d                	beqz	a3,80004302 <bfree+0x6c>
    800042d6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800042d8:	94aa                	add	s1,s1,a0
    800042da:	fff7c793          	not	a5,a5
    800042de:	8ff9                	and	a5,a5,a4
    800042e0:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800042e4:	00001097          	auipc	ra,0x1
    800042e8:	11c080e7          	jalr	284(ra) # 80005400 <log_write>
  brelse(bp);
    800042ec:	854a                	mv	a0,s2
    800042ee:	00000097          	auipc	ra,0x0
    800042f2:	e92080e7          	jalr	-366(ra) # 80004180 <brelse>
}
    800042f6:	60e2                	ld	ra,24(sp)
    800042f8:	6442                	ld	s0,16(sp)
    800042fa:	64a2                	ld	s1,8(sp)
    800042fc:	6902                	ld	s2,0(sp)
    800042fe:	6105                	addi	sp,sp,32
    80004300:	8082                	ret
    panic("freeing free block");
    80004302:	00005517          	auipc	a0,0x5
    80004306:	45650513          	addi	a0,a0,1110 # 80009758 <syscalls+0x120>
    8000430a:	ffffc097          	auipc	ra,0xffffc
    8000430e:	224080e7          	jalr	548(ra) # 8000052e <panic>

0000000080004312 <balloc>:
{
    80004312:	711d                	addi	sp,sp,-96
    80004314:	ec86                	sd	ra,88(sp)
    80004316:	e8a2                	sd	s0,80(sp)
    80004318:	e4a6                	sd	s1,72(sp)
    8000431a:	e0ca                	sd	s2,64(sp)
    8000431c:	fc4e                	sd	s3,56(sp)
    8000431e:	f852                	sd	s4,48(sp)
    80004320:	f456                	sd	s5,40(sp)
    80004322:	f05a                	sd	s6,32(sp)
    80004324:	ec5e                	sd	s7,24(sp)
    80004326:	e862                	sd	s8,16(sp)
    80004328:	e466                	sd	s9,8(sp)
    8000432a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000432c:	00038797          	auipc	a5,0x38
    80004330:	cd87a783          	lw	a5,-808(a5) # 8003c004 <sb+0x4>
    80004334:	cbd1                	beqz	a5,800043c8 <balloc+0xb6>
    80004336:	8baa                	mv	s7,a0
    80004338:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000433a:	00038b17          	auipc	s6,0x38
    8000433e:	cc6b0b13          	addi	s6,s6,-826 # 8003c000 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004342:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80004344:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004346:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80004348:	6c89                	lui	s9,0x2
    8000434a:	a831                	j	80004366 <balloc+0x54>
    brelse(bp);
    8000434c:	854a                	mv	a0,s2
    8000434e:	00000097          	auipc	ra,0x0
    80004352:	e32080e7          	jalr	-462(ra) # 80004180 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80004356:	015c87bb          	addw	a5,s9,s5
    8000435a:	00078a9b          	sext.w	s5,a5
    8000435e:	004b2703          	lw	a4,4(s6)
    80004362:	06eaf363          	bgeu	s5,a4,800043c8 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80004366:	41fad79b          	sraiw	a5,s5,0x1f
    8000436a:	0137d79b          	srliw	a5,a5,0x13
    8000436e:	015787bb          	addw	a5,a5,s5
    80004372:	40d7d79b          	sraiw	a5,a5,0xd
    80004376:	01cb2583          	lw	a1,28(s6)
    8000437a:	9dbd                	addw	a1,a1,a5
    8000437c:	855e                	mv	a0,s7
    8000437e:	00000097          	auipc	ra,0x0
    80004382:	cd2080e7          	jalr	-814(ra) # 80004050 <bread>
    80004386:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004388:	004b2503          	lw	a0,4(s6)
    8000438c:	000a849b          	sext.w	s1,s5
    80004390:	8662                	mv	a2,s8
    80004392:	faa4fde3          	bgeu	s1,a0,8000434c <balloc+0x3a>
      m = 1 << (bi % 8);
    80004396:	41f6579b          	sraiw	a5,a2,0x1f
    8000439a:	01d7d69b          	srliw	a3,a5,0x1d
    8000439e:	00c6873b          	addw	a4,a3,a2
    800043a2:	00777793          	andi	a5,a4,7
    800043a6:	9f95                	subw	a5,a5,a3
    800043a8:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800043ac:	4037571b          	sraiw	a4,a4,0x3
    800043b0:	00e906b3          	add	a3,s2,a4
    800043b4:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    800043b8:	00d7f5b3          	and	a1,a5,a3
    800043bc:	cd91                	beqz	a1,800043d8 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800043be:	2605                	addiw	a2,a2,1
    800043c0:	2485                	addiw	s1,s1,1
    800043c2:	fd4618e3          	bne	a2,s4,80004392 <balloc+0x80>
    800043c6:	b759                	j	8000434c <balloc+0x3a>
  panic("balloc: out of blocks");
    800043c8:	00005517          	auipc	a0,0x5
    800043cc:	3a850513          	addi	a0,a0,936 # 80009770 <syscalls+0x138>
    800043d0:	ffffc097          	auipc	ra,0xffffc
    800043d4:	15e080e7          	jalr	350(ra) # 8000052e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800043d8:	974a                	add	a4,a4,s2
    800043da:	8fd5                	or	a5,a5,a3
    800043dc:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800043e0:	854a                	mv	a0,s2
    800043e2:	00001097          	auipc	ra,0x1
    800043e6:	01e080e7          	jalr	30(ra) # 80005400 <log_write>
        brelse(bp);
    800043ea:	854a                	mv	a0,s2
    800043ec:	00000097          	auipc	ra,0x0
    800043f0:	d94080e7          	jalr	-620(ra) # 80004180 <brelse>
  bp = bread(dev, bno);
    800043f4:	85a6                	mv	a1,s1
    800043f6:	855e                	mv	a0,s7
    800043f8:	00000097          	auipc	ra,0x0
    800043fc:	c58080e7          	jalr	-936(ra) # 80004050 <bread>
    80004400:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80004402:	40000613          	li	a2,1024
    80004406:	4581                	li	a1,0
    80004408:	05850513          	addi	a0,a0,88
    8000440c:	ffffd097          	auipc	ra,0xffffd
    80004410:	8d8080e7          	jalr	-1832(ra) # 80000ce4 <memset>
  log_write(bp);
    80004414:	854a                	mv	a0,s2
    80004416:	00001097          	auipc	ra,0x1
    8000441a:	fea080e7          	jalr	-22(ra) # 80005400 <log_write>
  brelse(bp);
    8000441e:	854a                	mv	a0,s2
    80004420:	00000097          	auipc	ra,0x0
    80004424:	d60080e7          	jalr	-672(ra) # 80004180 <brelse>
}
    80004428:	8526                	mv	a0,s1
    8000442a:	60e6                	ld	ra,88(sp)
    8000442c:	6446                	ld	s0,80(sp)
    8000442e:	64a6                	ld	s1,72(sp)
    80004430:	6906                	ld	s2,64(sp)
    80004432:	79e2                	ld	s3,56(sp)
    80004434:	7a42                	ld	s4,48(sp)
    80004436:	7aa2                	ld	s5,40(sp)
    80004438:	7b02                	ld	s6,32(sp)
    8000443a:	6be2                	ld	s7,24(sp)
    8000443c:	6c42                	ld	s8,16(sp)
    8000443e:	6ca2                	ld	s9,8(sp)
    80004440:	6125                	addi	sp,sp,96
    80004442:	8082                	ret

0000000080004444 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80004444:	7179                	addi	sp,sp,-48
    80004446:	f406                	sd	ra,40(sp)
    80004448:	f022                	sd	s0,32(sp)
    8000444a:	ec26                	sd	s1,24(sp)
    8000444c:	e84a                	sd	s2,16(sp)
    8000444e:	e44e                	sd	s3,8(sp)
    80004450:	e052                	sd	s4,0(sp)
    80004452:	1800                	addi	s0,sp,48
    80004454:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80004456:	47ad                	li	a5,11
    80004458:	04b7fe63          	bgeu	a5,a1,800044b4 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000445c:	ff45849b          	addiw	s1,a1,-12
    80004460:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80004464:	0ff00793          	li	a5,255
    80004468:	0ae7e463          	bltu	a5,a4,80004510 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000446c:	08052583          	lw	a1,128(a0)
    80004470:	c5b5                	beqz	a1,800044dc <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80004472:	00092503          	lw	a0,0(s2)
    80004476:	00000097          	auipc	ra,0x0
    8000447a:	bda080e7          	jalr	-1062(ra) # 80004050 <bread>
    8000447e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80004480:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80004484:	02049713          	slli	a4,s1,0x20
    80004488:	01e75593          	srli	a1,a4,0x1e
    8000448c:	00b784b3          	add	s1,a5,a1
    80004490:	0004a983          	lw	s3,0(s1)
    80004494:	04098e63          	beqz	s3,800044f0 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80004498:	8552                	mv	a0,s4
    8000449a:	00000097          	auipc	ra,0x0
    8000449e:	ce6080e7          	jalr	-794(ra) # 80004180 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800044a2:	854e                	mv	a0,s3
    800044a4:	70a2                	ld	ra,40(sp)
    800044a6:	7402                	ld	s0,32(sp)
    800044a8:	64e2                	ld	s1,24(sp)
    800044aa:	6942                	ld	s2,16(sp)
    800044ac:	69a2                	ld	s3,8(sp)
    800044ae:	6a02                	ld	s4,0(sp)
    800044b0:	6145                	addi	sp,sp,48
    800044b2:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800044b4:	02059793          	slli	a5,a1,0x20
    800044b8:	01e7d593          	srli	a1,a5,0x1e
    800044bc:	00b504b3          	add	s1,a0,a1
    800044c0:	0504a983          	lw	s3,80(s1)
    800044c4:	fc099fe3          	bnez	s3,800044a2 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800044c8:	4108                	lw	a0,0(a0)
    800044ca:	00000097          	auipc	ra,0x0
    800044ce:	e48080e7          	jalr	-440(ra) # 80004312 <balloc>
    800044d2:	0005099b          	sext.w	s3,a0
    800044d6:	0534a823          	sw	s3,80(s1)
    800044da:	b7e1                	j	800044a2 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800044dc:	4108                	lw	a0,0(a0)
    800044de:	00000097          	auipc	ra,0x0
    800044e2:	e34080e7          	jalr	-460(ra) # 80004312 <balloc>
    800044e6:	0005059b          	sext.w	a1,a0
    800044ea:	08b92023          	sw	a1,128(s2)
    800044ee:	b751                	j	80004472 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800044f0:	00092503          	lw	a0,0(s2)
    800044f4:	00000097          	auipc	ra,0x0
    800044f8:	e1e080e7          	jalr	-482(ra) # 80004312 <balloc>
    800044fc:	0005099b          	sext.w	s3,a0
    80004500:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80004504:	8552                	mv	a0,s4
    80004506:	00001097          	auipc	ra,0x1
    8000450a:	efa080e7          	jalr	-262(ra) # 80005400 <log_write>
    8000450e:	b769                	j	80004498 <bmap+0x54>
  panic("bmap: out of range");
    80004510:	00005517          	auipc	a0,0x5
    80004514:	27850513          	addi	a0,a0,632 # 80009788 <syscalls+0x150>
    80004518:	ffffc097          	auipc	ra,0xffffc
    8000451c:	016080e7          	jalr	22(ra) # 8000052e <panic>

0000000080004520 <iget>:
{
    80004520:	7179                	addi	sp,sp,-48
    80004522:	f406                	sd	ra,40(sp)
    80004524:	f022                	sd	s0,32(sp)
    80004526:	ec26                	sd	s1,24(sp)
    80004528:	e84a                	sd	s2,16(sp)
    8000452a:	e44e                	sd	s3,8(sp)
    8000452c:	e052                	sd	s4,0(sp)
    8000452e:	1800                	addi	s0,sp,48
    80004530:	89aa                	mv	s3,a0
    80004532:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80004534:	00038517          	auipc	a0,0x38
    80004538:	aec50513          	addi	a0,a0,-1300 # 8003c020 <itable>
    8000453c:	ffffc097          	auipc	ra,0xffffc
    80004540:	68a080e7          	jalr	1674(ra) # 80000bc6 <acquire>
  empty = 0;
    80004544:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004546:	00038497          	auipc	s1,0x38
    8000454a:	af248493          	addi	s1,s1,-1294 # 8003c038 <itable+0x18>
    8000454e:	00039697          	auipc	a3,0x39
    80004552:	57a68693          	addi	a3,a3,1402 # 8003dac8 <log>
    80004556:	a039                	j	80004564 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004558:	02090b63          	beqz	s2,8000458e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000455c:	08848493          	addi	s1,s1,136
    80004560:	02d48a63          	beq	s1,a3,80004594 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80004564:	449c                	lw	a5,8(s1)
    80004566:	fef059e3          	blez	a5,80004558 <iget+0x38>
    8000456a:	4098                	lw	a4,0(s1)
    8000456c:	ff3716e3          	bne	a4,s3,80004558 <iget+0x38>
    80004570:	40d8                	lw	a4,4(s1)
    80004572:	ff4713e3          	bne	a4,s4,80004558 <iget+0x38>
      ip->ref++;
    80004576:	2785                	addiw	a5,a5,1
    80004578:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000457a:	00038517          	auipc	a0,0x38
    8000457e:	aa650513          	addi	a0,a0,-1370 # 8003c020 <itable>
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	71a080e7          	jalr	1818(ra) # 80000c9c <release>
      return ip;
    8000458a:	8926                	mv	s2,s1
    8000458c:	a03d                	j	800045ba <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000458e:	f7f9                	bnez	a5,8000455c <iget+0x3c>
    80004590:	8926                	mv	s2,s1
    80004592:	b7e9                	j	8000455c <iget+0x3c>
  if(empty == 0)
    80004594:	02090c63          	beqz	s2,800045cc <iget+0xac>
  ip->dev = dev;
    80004598:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000459c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800045a0:	4785                	li	a5,1
    800045a2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800045a6:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800045aa:	00038517          	auipc	a0,0x38
    800045ae:	a7650513          	addi	a0,a0,-1418 # 8003c020 <itable>
    800045b2:	ffffc097          	auipc	ra,0xffffc
    800045b6:	6ea080e7          	jalr	1770(ra) # 80000c9c <release>
}
    800045ba:	854a                	mv	a0,s2
    800045bc:	70a2                	ld	ra,40(sp)
    800045be:	7402                	ld	s0,32(sp)
    800045c0:	64e2                	ld	s1,24(sp)
    800045c2:	6942                	ld	s2,16(sp)
    800045c4:	69a2                	ld	s3,8(sp)
    800045c6:	6a02                	ld	s4,0(sp)
    800045c8:	6145                	addi	sp,sp,48
    800045ca:	8082                	ret
    panic("iget: no inodes");
    800045cc:	00005517          	auipc	a0,0x5
    800045d0:	1d450513          	addi	a0,a0,468 # 800097a0 <syscalls+0x168>
    800045d4:	ffffc097          	auipc	ra,0xffffc
    800045d8:	f5a080e7          	jalr	-166(ra) # 8000052e <panic>

00000000800045dc <fsinit>:
fsinit(int dev) {
    800045dc:	7179                	addi	sp,sp,-48
    800045de:	f406                	sd	ra,40(sp)
    800045e0:	f022                	sd	s0,32(sp)
    800045e2:	ec26                	sd	s1,24(sp)
    800045e4:	e84a                	sd	s2,16(sp)
    800045e6:	e44e                	sd	s3,8(sp)
    800045e8:	1800                	addi	s0,sp,48
    800045ea:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800045ec:	4585                	li	a1,1
    800045ee:	00000097          	auipc	ra,0x0
    800045f2:	a62080e7          	jalr	-1438(ra) # 80004050 <bread>
    800045f6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800045f8:	00038997          	auipc	s3,0x38
    800045fc:	a0898993          	addi	s3,s3,-1528 # 8003c000 <sb>
    80004600:	02000613          	li	a2,32
    80004604:	05850593          	addi	a1,a0,88
    80004608:	854e                	mv	a0,s3
    8000460a:	ffffc097          	auipc	ra,0xffffc
    8000460e:	736080e7          	jalr	1846(ra) # 80000d40 <memmove>
  brelse(bp);
    80004612:	8526                	mv	a0,s1
    80004614:	00000097          	auipc	ra,0x0
    80004618:	b6c080e7          	jalr	-1172(ra) # 80004180 <brelse>
  if(sb.magic != FSMAGIC)
    8000461c:	0009a703          	lw	a4,0(s3)
    80004620:	102037b7          	lui	a5,0x10203
    80004624:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80004628:	02f71263          	bne	a4,a5,8000464c <fsinit+0x70>
  initlog(dev, &sb);
    8000462c:	00038597          	auipc	a1,0x38
    80004630:	9d458593          	addi	a1,a1,-1580 # 8003c000 <sb>
    80004634:	854a                	mv	a0,s2
    80004636:	00001097          	auipc	ra,0x1
    8000463a:	b4c080e7          	jalr	-1204(ra) # 80005182 <initlog>
}
    8000463e:	70a2                	ld	ra,40(sp)
    80004640:	7402                	ld	s0,32(sp)
    80004642:	64e2                	ld	s1,24(sp)
    80004644:	6942                	ld	s2,16(sp)
    80004646:	69a2                	ld	s3,8(sp)
    80004648:	6145                	addi	sp,sp,48
    8000464a:	8082                	ret
    panic("invalid file system");
    8000464c:	00005517          	auipc	a0,0x5
    80004650:	16450513          	addi	a0,a0,356 # 800097b0 <syscalls+0x178>
    80004654:	ffffc097          	auipc	ra,0xffffc
    80004658:	eda080e7          	jalr	-294(ra) # 8000052e <panic>

000000008000465c <iinit>:
{
    8000465c:	7179                	addi	sp,sp,-48
    8000465e:	f406                	sd	ra,40(sp)
    80004660:	f022                	sd	s0,32(sp)
    80004662:	ec26                	sd	s1,24(sp)
    80004664:	e84a                	sd	s2,16(sp)
    80004666:	e44e                	sd	s3,8(sp)
    80004668:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000466a:	00005597          	auipc	a1,0x5
    8000466e:	15e58593          	addi	a1,a1,350 # 800097c8 <syscalls+0x190>
    80004672:	00038517          	auipc	a0,0x38
    80004676:	9ae50513          	addi	a0,a0,-1618 # 8003c020 <itable>
    8000467a:	ffffc097          	auipc	ra,0xffffc
    8000467e:	4bc080e7          	jalr	1212(ra) # 80000b36 <initlock>
  for(i = 0; i < NINODE; i++) {
    80004682:	00038497          	auipc	s1,0x38
    80004686:	9c648493          	addi	s1,s1,-1594 # 8003c048 <itable+0x28>
    8000468a:	00039997          	auipc	s3,0x39
    8000468e:	44e98993          	addi	s3,s3,1102 # 8003dad8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004692:	00005917          	auipc	s2,0x5
    80004696:	13e90913          	addi	s2,s2,318 # 800097d0 <syscalls+0x198>
    8000469a:	85ca                	mv	a1,s2
    8000469c:	8526                	mv	a0,s1
    8000469e:	00001097          	auipc	ra,0x1
    800046a2:	e48080e7          	jalr	-440(ra) # 800054e6 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800046a6:	08848493          	addi	s1,s1,136
    800046aa:	ff3498e3          	bne	s1,s3,8000469a <iinit+0x3e>
}
    800046ae:	70a2                	ld	ra,40(sp)
    800046b0:	7402                	ld	s0,32(sp)
    800046b2:	64e2                	ld	s1,24(sp)
    800046b4:	6942                	ld	s2,16(sp)
    800046b6:	69a2                	ld	s3,8(sp)
    800046b8:	6145                	addi	sp,sp,48
    800046ba:	8082                	ret

00000000800046bc <ialloc>:
{
    800046bc:	715d                	addi	sp,sp,-80
    800046be:	e486                	sd	ra,72(sp)
    800046c0:	e0a2                	sd	s0,64(sp)
    800046c2:	fc26                	sd	s1,56(sp)
    800046c4:	f84a                	sd	s2,48(sp)
    800046c6:	f44e                	sd	s3,40(sp)
    800046c8:	f052                	sd	s4,32(sp)
    800046ca:	ec56                	sd	s5,24(sp)
    800046cc:	e85a                	sd	s6,16(sp)
    800046ce:	e45e                	sd	s7,8(sp)
    800046d0:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800046d2:	00038717          	auipc	a4,0x38
    800046d6:	93a72703          	lw	a4,-1734(a4) # 8003c00c <sb+0xc>
    800046da:	4785                	li	a5,1
    800046dc:	04e7fa63          	bgeu	a5,a4,80004730 <ialloc+0x74>
    800046e0:	8aaa                	mv	s5,a0
    800046e2:	8bae                	mv	s7,a1
    800046e4:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800046e6:	00038a17          	auipc	s4,0x38
    800046ea:	91aa0a13          	addi	s4,s4,-1766 # 8003c000 <sb>
    800046ee:	00048b1b          	sext.w	s6,s1
    800046f2:	0044d793          	srli	a5,s1,0x4
    800046f6:	018a2583          	lw	a1,24(s4)
    800046fa:	9dbd                	addw	a1,a1,a5
    800046fc:	8556                	mv	a0,s5
    800046fe:	00000097          	auipc	ra,0x0
    80004702:	952080e7          	jalr	-1710(ra) # 80004050 <bread>
    80004706:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80004708:	05850993          	addi	s3,a0,88
    8000470c:	00f4f793          	andi	a5,s1,15
    80004710:	079a                	slli	a5,a5,0x6
    80004712:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80004714:	00099783          	lh	a5,0(s3)
    80004718:	c785                	beqz	a5,80004740 <ialloc+0x84>
    brelse(bp);
    8000471a:	00000097          	auipc	ra,0x0
    8000471e:	a66080e7          	jalr	-1434(ra) # 80004180 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80004722:	0485                	addi	s1,s1,1
    80004724:	00ca2703          	lw	a4,12(s4)
    80004728:	0004879b          	sext.w	a5,s1
    8000472c:	fce7e1e3          	bltu	a5,a4,800046ee <ialloc+0x32>
  panic("ialloc: no inodes");
    80004730:	00005517          	auipc	a0,0x5
    80004734:	0a850513          	addi	a0,a0,168 # 800097d8 <syscalls+0x1a0>
    80004738:	ffffc097          	auipc	ra,0xffffc
    8000473c:	df6080e7          	jalr	-522(ra) # 8000052e <panic>
      memset(dip, 0, sizeof(*dip));
    80004740:	04000613          	li	a2,64
    80004744:	4581                	li	a1,0
    80004746:	854e                	mv	a0,s3
    80004748:	ffffc097          	auipc	ra,0xffffc
    8000474c:	59c080e7          	jalr	1436(ra) # 80000ce4 <memset>
      dip->type = type;
    80004750:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004754:	854a                	mv	a0,s2
    80004756:	00001097          	auipc	ra,0x1
    8000475a:	caa080e7          	jalr	-854(ra) # 80005400 <log_write>
      brelse(bp);
    8000475e:	854a                	mv	a0,s2
    80004760:	00000097          	auipc	ra,0x0
    80004764:	a20080e7          	jalr	-1504(ra) # 80004180 <brelse>
      return iget(dev, inum);
    80004768:	85da                	mv	a1,s6
    8000476a:	8556                	mv	a0,s5
    8000476c:	00000097          	auipc	ra,0x0
    80004770:	db4080e7          	jalr	-588(ra) # 80004520 <iget>
}
    80004774:	60a6                	ld	ra,72(sp)
    80004776:	6406                	ld	s0,64(sp)
    80004778:	74e2                	ld	s1,56(sp)
    8000477a:	7942                	ld	s2,48(sp)
    8000477c:	79a2                	ld	s3,40(sp)
    8000477e:	7a02                	ld	s4,32(sp)
    80004780:	6ae2                	ld	s5,24(sp)
    80004782:	6b42                	ld	s6,16(sp)
    80004784:	6ba2                	ld	s7,8(sp)
    80004786:	6161                	addi	sp,sp,80
    80004788:	8082                	ret

000000008000478a <iupdate>:
{
    8000478a:	1101                	addi	sp,sp,-32
    8000478c:	ec06                	sd	ra,24(sp)
    8000478e:	e822                	sd	s0,16(sp)
    80004790:	e426                	sd	s1,8(sp)
    80004792:	e04a                	sd	s2,0(sp)
    80004794:	1000                	addi	s0,sp,32
    80004796:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004798:	415c                	lw	a5,4(a0)
    8000479a:	0047d79b          	srliw	a5,a5,0x4
    8000479e:	00038597          	auipc	a1,0x38
    800047a2:	87a5a583          	lw	a1,-1926(a1) # 8003c018 <sb+0x18>
    800047a6:	9dbd                	addw	a1,a1,a5
    800047a8:	4108                	lw	a0,0(a0)
    800047aa:	00000097          	auipc	ra,0x0
    800047ae:	8a6080e7          	jalr	-1882(ra) # 80004050 <bread>
    800047b2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800047b4:	05850793          	addi	a5,a0,88
    800047b8:	40c8                	lw	a0,4(s1)
    800047ba:	893d                	andi	a0,a0,15
    800047bc:	051a                	slli	a0,a0,0x6
    800047be:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800047c0:	04449703          	lh	a4,68(s1)
    800047c4:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800047c8:	04649703          	lh	a4,70(s1)
    800047cc:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800047d0:	04849703          	lh	a4,72(s1)
    800047d4:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800047d8:	04a49703          	lh	a4,74(s1)
    800047dc:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800047e0:	44f8                	lw	a4,76(s1)
    800047e2:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800047e4:	03400613          	li	a2,52
    800047e8:	05048593          	addi	a1,s1,80
    800047ec:	0531                	addi	a0,a0,12
    800047ee:	ffffc097          	auipc	ra,0xffffc
    800047f2:	552080e7          	jalr	1362(ra) # 80000d40 <memmove>
  log_write(bp);
    800047f6:	854a                	mv	a0,s2
    800047f8:	00001097          	auipc	ra,0x1
    800047fc:	c08080e7          	jalr	-1016(ra) # 80005400 <log_write>
  brelse(bp);
    80004800:	854a                	mv	a0,s2
    80004802:	00000097          	auipc	ra,0x0
    80004806:	97e080e7          	jalr	-1666(ra) # 80004180 <brelse>
}
    8000480a:	60e2                	ld	ra,24(sp)
    8000480c:	6442                	ld	s0,16(sp)
    8000480e:	64a2                	ld	s1,8(sp)
    80004810:	6902                	ld	s2,0(sp)
    80004812:	6105                	addi	sp,sp,32
    80004814:	8082                	ret

0000000080004816 <idup>:
{
    80004816:	1101                	addi	sp,sp,-32
    80004818:	ec06                	sd	ra,24(sp)
    8000481a:	e822                	sd	s0,16(sp)
    8000481c:	e426                	sd	s1,8(sp)
    8000481e:	1000                	addi	s0,sp,32
    80004820:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004822:	00037517          	auipc	a0,0x37
    80004826:	7fe50513          	addi	a0,a0,2046 # 8003c020 <itable>
    8000482a:	ffffc097          	auipc	ra,0xffffc
    8000482e:	39c080e7          	jalr	924(ra) # 80000bc6 <acquire>
  ip->ref++;
    80004832:	449c                	lw	a5,8(s1)
    80004834:	2785                	addiw	a5,a5,1
    80004836:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004838:	00037517          	auipc	a0,0x37
    8000483c:	7e850513          	addi	a0,a0,2024 # 8003c020 <itable>
    80004840:	ffffc097          	auipc	ra,0xffffc
    80004844:	45c080e7          	jalr	1116(ra) # 80000c9c <release>
}
    80004848:	8526                	mv	a0,s1
    8000484a:	60e2                	ld	ra,24(sp)
    8000484c:	6442                	ld	s0,16(sp)
    8000484e:	64a2                	ld	s1,8(sp)
    80004850:	6105                	addi	sp,sp,32
    80004852:	8082                	ret

0000000080004854 <ilock>:
{
    80004854:	1101                	addi	sp,sp,-32
    80004856:	ec06                	sd	ra,24(sp)
    80004858:	e822                	sd	s0,16(sp)
    8000485a:	e426                	sd	s1,8(sp)
    8000485c:	e04a                	sd	s2,0(sp)
    8000485e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004860:	c115                	beqz	a0,80004884 <ilock+0x30>
    80004862:	84aa                	mv	s1,a0
    80004864:	451c                	lw	a5,8(a0)
    80004866:	00f05f63          	blez	a5,80004884 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000486a:	0541                	addi	a0,a0,16
    8000486c:	00001097          	auipc	ra,0x1
    80004870:	cb4080e7          	jalr	-844(ra) # 80005520 <acquiresleep>
  if(ip->valid == 0){
    80004874:	40bc                	lw	a5,64(s1)
    80004876:	cf99                	beqz	a5,80004894 <ilock+0x40>
}
    80004878:	60e2                	ld	ra,24(sp)
    8000487a:	6442                	ld	s0,16(sp)
    8000487c:	64a2                	ld	s1,8(sp)
    8000487e:	6902                	ld	s2,0(sp)
    80004880:	6105                	addi	sp,sp,32
    80004882:	8082                	ret
    panic("ilock");
    80004884:	00005517          	auipc	a0,0x5
    80004888:	f6c50513          	addi	a0,a0,-148 # 800097f0 <syscalls+0x1b8>
    8000488c:	ffffc097          	auipc	ra,0xffffc
    80004890:	ca2080e7          	jalr	-862(ra) # 8000052e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004894:	40dc                	lw	a5,4(s1)
    80004896:	0047d79b          	srliw	a5,a5,0x4
    8000489a:	00037597          	auipc	a1,0x37
    8000489e:	77e5a583          	lw	a1,1918(a1) # 8003c018 <sb+0x18>
    800048a2:	9dbd                	addw	a1,a1,a5
    800048a4:	4088                	lw	a0,0(s1)
    800048a6:	fffff097          	auipc	ra,0xfffff
    800048aa:	7aa080e7          	jalr	1962(ra) # 80004050 <bread>
    800048ae:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800048b0:	05850593          	addi	a1,a0,88
    800048b4:	40dc                	lw	a5,4(s1)
    800048b6:	8bbd                	andi	a5,a5,15
    800048b8:	079a                	slli	a5,a5,0x6
    800048ba:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800048bc:	00059783          	lh	a5,0(a1)
    800048c0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800048c4:	00259783          	lh	a5,2(a1)
    800048c8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800048cc:	00459783          	lh	a5,4(a1)
    800048d0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800048d4:	00659783          	lh	a5,6(a1)
    800048d8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800048dc:	459c                	lw	a5,8(a1)
    800048de:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800048e0:	03400613          	li	a2,52
    800048e4:	05b1                	addi	a1,a1,12
    800048e6:	05048513          	addi	a0,s1,80
    800048ea:	ffffc097          	auipc	ra,0xffffc
    800048ee:	456080e7          	jalr	1110(ra) # 80000d40 <memmove>
    brelse(bp);
    800048f2:	854a                	mv	a0,s2
    800048f4:	00000097          	auipc	ra,0x0
    800048f8:	88c080e7          	jalr	-1908(ra) # 80004180 <brelse>
    ip->valid = 1;
    800048fc:	4785                	li	a5,1
    800048fe:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004900:	04449783          	lh	a5,68(s1)
    80004904:	fbb5                	bnez	a5,80004878 <ilock+0x24>
      panic("ilock: no type");
    80004906:	00005517          	auipc	a0,0x5
    8000490a:	ef250513          	addi	a0,a0,-270 # 800097f8 <syscalls+0x1c0>
    8000490e:	ffffc097          	auipc	ra,0xffffc
    80004912:	c20080e7          	jalr	-992(ra) # 8000052e <panic>

0000000080004916 <iunlock>:
{
    80004916:	1101                	addi	sp,sp,-32
    80004918:	ec06                	sd	ra,24(sp)
    8000491a:	e822                	sd	s0,16(sp)
    8000491c:	e426                	sd	s1,8(sp)
    8000491e:	e04a                	sd	s2,0(sp)
    80004920:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004922:	c905                	beqz	a0,80004952 <iunlock+0x3c>
    80004924:	84aa                	mv	s1,a0
    80004926:	01050913          	addi	s2,a0,16
    8000492a:	854a                	mv	a0,s2
    8000492c:	00001097          	auipc	ra,0x1
    80004930:	c8e080e7          	jalr	-882(ra) # 800055ba <holdingsleep>
    80004934:	cd19                	beqz	a0,80004952 <iunlock+0x3c>
    80004936:	449c                	lw	a5,8(s1)
    80004938:	00f05d63          	blez	a5,80004952 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000493c:	854a                	mv	a0,s2
    8000493e:	00001097          	auipc	ra,0x1
    80004942:	c38080e7          	jalr	-968(ra) # 80005576 <releasesleep>
}
    80004946:	60e2                	ld	ra,24(sp)
    80004948:	6442                	ld	s0,16(sp)
    8000494a:	64a2                	ld	s1,8(sp)
    8000494c:	6902                	ld	s2,0(sp)
    8000494e:	6105                	addi	sp,sp,32
    80004950:	8082                	ret
    panic("iunlock");
    80004952:	00005517          	auipc	a0,0x5
    80004956:	eb650513          	addi	a0,a0,-330 # 80009808 <syscalls+0x1d0>
    8000495a:	ffffc097          	auipc	ra,0xffffc
    8000495e:	bd4080e7          	jalr	-1068(ra) # 8000052e <panic>

0000000080004962 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004962:	7179                	addi	sp,sp,-48
    80004964:	f406                	sd	ra,40(sp)
    80004966:	f022                	sd	s0,32(sp)
    80004968:	ec26                	sd	s1,24(sp)
    8000496a:	e84a                	sd	s2,16(sp)
    8000496c:	e44e                	sd	s3,8(sp)
    8000496e:	e052                	sd	s4,0(sp)
    80004970:	1800                	addi	s0,sp,48
    80004972:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004974:	05050493          	addi	s1,a0,80
    80004978:	08050913          	addi	s2,a0,128
    8000497c:	a021                	j	80004984 <itrunc+0x22>
    8000497e:	0491                	addi	s1,s1,4
    80004980:	01248d63          	beq	s1,s2,8000499a <itrunc+0x38>
    if(ip->addrs[i]){
    80004984:	408c                	lw	a1,0(s1)
    80004986:	dde5                	beqz	a1,8000497e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80004988:	0009a503          	lw	a0,0(s3)
    8000498c:	00000097          	auipc	ra,0x0
    80004990:	90a080e7          	jalr	-1782(ra) # 80004296 <bfree>
      ip->addrs[i] = 0;
    80004994:	0004a023          	sw	zero,0(s1)
    80004998:	b7dd                	j	8000497e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000499a:	0809a583          	lw	a1,128(s3)
    8000499e:	e185                	bnez	a1,800049be <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800049a0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800049a4:	854e                	mv	a0,s3
    800049a6:	00000097          	auipc	ra,0x0
    800049aa:	de4080e7          	jalr	-540(ra) # 8000478a <iupdate>
}
    800049ae:	70a2                	ld	ra,40(sp)
    800049b0:	7402                	ld	s0,32(sp)
    800049b2:	64e2                	ld	s1,24(sp)
    800049b4:	6942                	ld	s2,16(sp)
    800049b6:	69a2                	ld	s3,8(sp)
    800049b8:	6a02                	ld	s4,0(sp)
    800049ba:	6145                	addi	sp,sp,48
    800049bc:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800049be:	0009a503          	lw	a0,0(s3)
    800049c2:	fffff097          	auipc	ra,0xfffff
    800049c6:	68e080e7          	jalr	1678(ra) # 80004050 <bread>
    800049ca:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800049cc:	05850493          	addi	s1,a0,88
    800049d0:	45850913          	addi	s2,a0,1112
    800049d4:	a021                	j	800049dc <itrunc+0x7a>
    800049d6:	0491                	addi	s1,s1,4
    800049d8:	01248b63          	beq	s1,s2,800049ee <itrunc+0x8c>
      if(a[j])
    800049dc:	408c                	lw	a1,0(s1)
    800049de:	dde5                	beqz	a1,800049d6 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800049e0:	0009a503          	lw	a0,0(s3)
    800049e4:	00000097          	auipc	ra,0x0
    800049e8:	8b2080e7          	jalr	-1870(ra) # 80004296 <bfree>
    800049ec:	b7ed                	j	800049d6 <itrunc+0x74>
    brelse(bp);
    800049ee:	8552                	mv	a0,s4
    800049f0:	fffff097          	auipc	ra,0xfffff
    800049f4:	790080e7          	jalr	1936(ra) # 80004180 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800049f8:	0809a583          	lw	a1,128(s3)
    800049fc:	0009a503          	lw	a0,0(s3)
    80004a00:	00000097          	auipc	ra,0x0
    80004a04:	896080e7          	jalr	-1898(ra) # 80004296 <bfree>
    ip->addrs[NDIRECT] = 0;
    80004a08:	0809a023          	sw	zero,128(s3)
    80004a0c:	bf51                	j	800049a0 <itrunc+0x3e>

0000000080004a0e <iput>:
{
    80004a0e:	1101                	addi	sp,sp,-32
    80004a10:	ec06                	sd	ra,24(sp)
    80004a12:	e822                	sd	s0,16(sp)
    80004a14:	e426                	sd	s1,8(sp)
    80004a16:	e04a                	sd	s2,0(sp)
    80004a18:	1000                	addi	s0,sp,32
    80004a1a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004a1c:	00037517          	auipc	a0,0x37
    80004a20:	60450513          	addi	a0,a0,1540 # 8003c020 <itable>
    80004a24:	ffffc097          	auipc	ra,0xffffc
    80004a28:	1a2080e7          	jalr	418(ra) # 80000bc6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004a2c:	4498                	lw	a4,8(s1)
    80004a2e:	4785                	li	a5,1
    80004a30:	02f70363          	beq	a4,a5,80004a56 <iput+0x48>
  ip->ref--;
    80004a34:	449c                	lw	a5,8(s1)
    80004a36:	37fd                	addiw	a5,a5,-1
    80004a38:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004a3a:	00037517          	auipc	a0,0x37
    80004a3e:	5e650513          	addi	a0,a0,1510 # 8003c020 <itable>
    80004a42:	ffffc097          	auipc	ra,0xffffc
    80004a46:	25a080e7          	jalr	602(ra) # 80000c9c <release>
}
    80004a4a:	60e2                	ld	ra,24(sp)
    80004a4c:	6442                	ld	s0,16(sp)
    80004a4e:	64a2                	ld	s1,8(sp)
    80004a50:	6902                	ld	s2,0(sp)
    80004a52:	6105                	addi	sp,sp,32
    80004a54:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004a56:	40bc                	lw	a5,64(s1)
    80004a58:	dff1                	beqz	a5,80004a34 <iput+0x26>
    80004a5a:	04a49783          	lh	a5,74(s1)
    80004a5e:	fbf9                	bnez	a5,80004a34 <iput+0x26>
    acquiresleep(&ip->lock);
    80004a60:	01048913          	addi	s2,s1,16
    80004a64:	854a                	mv	a0,s2
    80004a66:	00001097          	auipc	ra,0x1
    80004a6a:	aba080e7          	jalr	-1350(ra) # 80005520 <acquiresleep>
    release(&itable.lock);
    80004a6e:	00037517          	auipc	a0,0x37
    80004a72:	5b250513          	addi	a0,a0,1458 # 8003c020 <itable>
    80004a76:	ffffc097          	auipc	ra,0xffffc
    80004a7a:	226080e7          	jalr	550(ra) # 80000c9c <release>
    itrunc(ip);
    80004a7e:	8526                	mv	a0,s1
    80004a80:	00000097          	auipc	ra,0x0
    80004a84:	ee2080e7          	jalr	-286(ra) # 80004962 <itrunc>
    ip->type = 0;
    80004a88:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004a8c:	8526                	mv	a0,s1
    80004a8e:	00000097          	auipc	ra,0x0
    80004a92:	cfc080e7          	jalr	-772(ra) # 8000478a <iupdate>
    ip->valid = 0;
    80004a96:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004a9a:	854a                	mv	a0,s2
    80004a9c:	00001097          	auipc	ra,0x1
    80004aa0:	ada080e7          	jalr	-1318(ra) # 80005576 <releasesleep>
    acquire(&itable.lock);
    80004aa4:	00037517          	auipc	a0,0x37
    80004aa8:	57c50513          	addi	a0,a0,1404 # 8003c020 <itable>
    80004aac:	ffffc097          	auipc	ra,0xffffc
    80004ab0:	11a080e7          	jalr	282(ra) # 80000bc6 <acquire>
    80004ab4:	b741                	j	80004a34 <iput+0x26>

0000000080004ab6 <iunlockput>:
{
    80004ab6:	1101                	addi	sp,sp,-32
    80004ab8:	ec06                	sd	ra,24(sp)
    80004aba:	e822                	sd	s0,16(sp)
    80004abc:	e426                	sd	s1,8(sp)
    80004abe:	1000                	addi	s0,sp,32
    80004ac0:	84aa                	mv	s1,a0
  iunlock(ip);
    80004ac2:	00000097          	auipc	ra,0x0
    80004ac6:	e54080e7          	jalr	-428(ra) # 80004916 <iunlock>
  iput(ip);
    80004aca:	8526                	mv	a0,s1
    80004acc:	00000097          	auipc	ra,0x0
    80004ad0:	f42080e7          	jalr	-190(ra) # 80004a0e <iput>
}
    80004ad4:	60e2                	ld	ra,24(sp)
    80004ad6:	6442                	ld	s0,16(sp)
    80004ad8:	64a2                	ld	s1,8(sp)
    80004ada:	6105                	addi	sp,sp,32
    80004adc:	8082                	ret

0000000080004ade <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004ade:	1141                	addi	sp,sp,-16
    80004ae0:	e422                	sd	s0,8(sp)
    80004ae2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004ae4:	411c                	lw	a5,0(a0)
    80004ae6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004ae8:	415c                	lw	a5,4(a0)
    80004aea:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004aec:	04451783          	lh	a5,68(a0)
    80004af0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004af4:	04a51783          	lh	a5,74(a0)
    80004af8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004afc:	04c56783          	lwu	a5,76(a0)
    80004b00:	e99c                	sd	a5,16(a1)
}
    80004b02:	6422                	ld	s0,8(sp)
    80004b04:	0141                	addi	sp,sp,16
    80004b06:	8082                	ret

0000000080004b08 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004b08:	457c                	lw	a5,76(a0)
    80004b0a:	0ed7e963          	bltu	a5,a3,80004bfc <readi+0xf4>
{
    80004b0e:	7159                	addi	sp,sp,-112
    80004b10:	f486                	sd	ra,104(sp)
    80004b12:	f0a2                	sd	s0,96(sp)
    80004b14:	eca6                	sd	s1,88(sp)
    80004b16:	e8ca                	sd	s2,80(sp)
    80004b18:	e4ce                	sd	s3,72(sp)
    80004b1a:	e0d2                	sd	s4,64(sp)
    80004b1c:	fc56                	sd	s5,56(sp)
    80004b1e:	f85a                	sd	s6,48(sp)
    80004b20:	f45e                	sd	s7,40(sp)
    80004b22:	f062                	sd	s8,32(sp)
    80004b24:	ec66                	sd	s9,24(sp)
    80004b26:	e86a                	sd	s10,16(sp)
    80004b28:	e46e                	sd	s11,8(sp)
    80004b2a:	1880                	addi	s0,sp,112
    80004b2c:	8baa                	mv	s7,a0
    80004b2e:	8c2e                	mv	s8,a1
    80004b30:	8ab2                	mv	s5,a2
    80004b32:	84b6                	mv	s1,a3
    80004b34:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004b36:	9f35                	addw	a4,a4,a3
    return 0;
    80004b38:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004b3a:	0ad76063          	bltu	a4,a3,80004bda <readi+0xd2>
  if(off + n > ip->size)
    80004b3e:	00e7f463          	bgeu	a5,a4,80004b46 <readi+0x3e>
    n = ip->size - off;
    80004b42:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004b46:	0a0b0963          	beqz	s6,80004bf8 <readi+0xf0>
    80004b4a:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004b4c:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004b50:	5cfd                	li	s9,-1
    80004b52:	a82d                	j	80004b8c <readi+0x84>
    80004b54:	020a1d93          	slli	s11,s4,0x20
    80004b58:	020ddd93          	srli	s11,s11,0x20
    80004b5c:	05890793          	addi	a5,s2,88
    80004b60:	86ee                	mv	a3,s11
    80004b62:	963e                	add	a2,a2,a5
    80004b64:	85d6                	mv	a1,s5
    80004b66:	8562                	mv	a0,s8
    80004b68:	ffffe097          	auipc	ra,0xffffe
    80004b6c:	eaa080e7          	jalr	-342(ra) # 80002a12 <either_copyout>
    80004b70:	05950d63          	beq	a0,s9,80004bca <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004b74:	854a                	mv	a0,s2
    80004b76:	fffff097          	auipc	ra,0xfffff
    80004b7a:	60a080e7          	jalr	1546(ra) # 80004180 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004b7e:	013a09bb          	addw	s3,s4,s3
    80004b82:	009a04bb          	addw	s1,s4,s1
    80004b86:	9aee                	add	s5,s5,s11
    80004b88:	0569f763          	bgeu	s3,s6,80004bd6 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004b8c:	000ba903          	lw	s2,0(s7)
    80004b90:	00a4d59b          	srliw	a1,s1,0xa
    80004b94:	855e                	mv	a0,s7
    80004b96:	00000097          	auipc	ra,0x0
    80004b9a:	8ae080e7          	jalr	-1874(ra) # 80004444 <bmap>
    80004b9e:	0005059b          	sext.w	a1,a0
    80004ba2:	854a                	mv	a0,s2
    80004ba4:	fffff097          	auipc	ra,0xfffff
    80004ba8:	4ac080e7          	jalr	1196(ra) # 80004050 <bread>
    80004bac:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004bae:	3ff4f613          	andi	a2,s1,1023
    80004bb2:	40cd07bb          	subw	a5,s10,a2
    80004bb6:	413b073b          	subw	a4,s6,s3
    80004bba:	8a3e                	mv	s4,a5
    80004bbc:	2781                	sext.w	a5,a5
    80004bbe:	0007069b          	sext.w	a3,a4
    80004bc2:	f8f6f9e3          	bgeu	a3,a5,80004b54 <readi+0x4c>
    80004bc6:	8a3a                	mv	s4,a4
    80004bc8:	b771                	j	80004b54 <readi+0x4c>
      brelse(bp);
    80004bca:	854a                	mv	a0,s2
    80004bcc:	fffff097          	auipc	ra,0xfffff
    80004bd0:	5b4080e7          	jalr	1460(ra) # 80004180 <brelse>
      tot = -1;
    80004bd4:	59fd                	li	s3,-1
  }
  return tot;
    80004bd6:	0009851b          	sext.w	a0,s3
}
    80004bda:	70a6                	ld	ra,104(sp)
    80004bdc:	7406                	ld	s0,96(sp)
    80004bde:	64e6                	ld	s1,88(sp)
    80004be0:	6946                	ld	s2,80(sp)
    80004be2:	69a6                	ld	s3,72(sp)
    80004be4:	6a06                	ld	s4,64(sp)
    80004be6:	7ae2                	ld	s5,56(sp)
    80004be8:	7b42                	ld	s6,48(sp)
    80004bea:	7ba2                	ld	s7,40(sp)
    80004bec:	7c02                	ld	s8,32(sp)
    80004bee:	6ce2                	ld	s9,24(sp)
    80004bf0:	6d42                	ld	s10,16(sp)
    80004bf2:	6da2                	ld	s11,8(sp)
    80004bf4:	6165                	addi	sp,sp,112
    80004bf6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004bf8:	89da                	mv	s3,s6
    80004bfa:	bff1                	j	80004bd6 <readi+0xce>
    return 0;
    80004bfc:	4501                	li	a0,0
}
    80004bfe:	8082                	ret

0000000080004c00 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004c00:	457c                	lw	a5,76(a0)
    80004c02:	10d7e863          	bltu	a5,a3,80004d12 <writei+0x112>
{
    80004c06:	7159                	addi	sp,sp,-112
    80004c08:	f486                	sd	ra,104(sp)
    80004c0a:	f0a2                	sd	s0,96(sp)
    80004c0c:	eca6                	sd	s1,88(sp)
    80004c0e:	e8ca                	sd	s2,80(sp)
    80004c10:	e4ce                	sd	s3,72(sp)
    80004c12:	e0d2                	sd	s4,64(sp)
    80004c14:	fc56                	sd	s5,56(sp)
    80004c16:	f85a                	sd	s6,48(sp)
    80004c18:	f45e                	sd	s7,40(sp)
    80004c1a:	f062                	sd	s8,32(sp)
    80004c1c:	ec66                	sd	s9,24(sp)
    80004c1e:	e86a                	sd	s10,16(sp)
    80004c20:	e46e                	sd	s11,8(sp)
    80004c22:	1880                	addi	s0,sp,112
    80004c24:	8b2a                	mv	s6,a0
    80004c26:	8c2e                	mv	s8,a1
    80004c28:	8ab2                	mv	s5,a2
    80004c2a:	8936                	mv	s2,a3
    80004c2c:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004c2e:	00e687bb          	addw	a5,a3,a4
    80004c32:	0ed7e263          	bltu	a5,a3,80004d16 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004c36:	00043737          	lui	a4,0x43
    80004c3a:	0ef76063          	bltu	a4,a5,80004d1a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004c3e:	0c0b8863          	beqz	s7,80004d0e <writei+0x10e>
    80004c42:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004c44:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004c48:	5cfd                	li	s9,-1
    80004c4a:	a091                	j	80004c8e <writei+0x8e>
    80004c4c:	02099d93          	slli	s11,s3,0x20
    80004c50:	020ddd93          	srli	s11,s11,0x20
    80004c54:	05848793          	addi	a5,s1,88
    80004c58:	86ee                	mv	a3,s11
    80004c5a:	8656                	mv	a2,s5
    80004c5c:	85e2                	mv	a1,s8
    80004c5e:	953e                	add	a0,a0,a5
    80004c60:	ffffe097          	auipc	ra,0xffffe
    80004c64:	e08080e7          	jalr	-504(ra) # 80002a68 <either_copyin>
    80004c68:	07950263          	beq	a0,s9,80004ccc <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004c6c:	8526                	mv	a0,s1
    80004c6e:	00000097          	auipc	ra,0x0
    80004c72:	792080e7          	jalr	1938(ra) # 80005400 <log_write>
    brelse(bp);
    80004c76:	8526                	mv	a0,s1
    80004c78:	fffff097          	auipc	ra,0xfffff
    80004c7c:	508080e7          	jalr	1288(ra) # 80004180 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004c80:	01498a3b          	addw	s4,s3,s4
    80004c84:	0129893b          	addw	s2,s3,s2
    80004c88:	9aee                	add	s5,s5,s11
    80004c8a:	057a7663          	bgeu	s4,s7,80004cd6 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004c8e:	000b2483          	lw	s1,0(s6)
    80004c92:	00a9559b          	srliw	a1,s2,0xa
    80004c96:	855a                	mv	a0,s6
    80004c98:	fffff097          	auipc	ra,0xfffff
    80004c9c:	7ac080e7          	jalr	1964(ra) # 80004444 <bmap>
    80004ca0:	0005059b          	sext.w	a1,a0
    80004ca4:	8526                	mv	a0,s1
    80004ca6:	fffff097          	auipc	ra,0xfffff
    80004caa:	3aa080e7          	jalr	938(ra) # 80004050 <bread>
    80004cae:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004cb0:	3ff97513          	andi	a0,s2,1023
    80004cb4:	40ad07bb          	subw	a5,s10,a0
    80004cb8:	414b873b          	subw	a4,s7,s4
    80004cbc:	89be                	mv	s3,a5
    80004cbe:	2781                	sext.w	a5,a5
    80004cc0:	0007069b          	sext.w	a3,a4
    80004cc4:	f8f6f4e3          	bgeu	a3,a5,80004c4c <writei+0x4c>
    80004cc8:	89ba                	mv	s3,a4
    80004cca:	b749                	j	80004c4c <writei+0x4c>
      brelse(bp);
    80004ccc:	8526                	mv	a0,s1
    80004cce:	fffff097          	auipc	ra,0xfffff
    80004cd2:	4b2080e7          	jalr	1202(ra) # 80004180 <brelse>
  }

  if(off > ip->size)
    80004cd6:	04cb2783          	lw	a5,76(s6)
    80004cda:	0127f463          	bgeu	a5,s2,80004ce2 <writei+0xe2>
    ip->size = off;
    80004cde:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004ce2:	855a                	mv	a0,s6
    80004ce4:	00000097          	auipc	ra,0x0
    80004ce8:	aa6080e7          	jalr	-1370(ra) # 8000478a <iupdate>

  return tot;
    80004cec:	000a051b          	sext.w	a0,s4
}
    80004cf0:	70a6                	ld	ra,104(sp)
    80004cf2:	7406                	ld	s0,96(sp)
    80004cf4:	64e6                	ld	s1,88(sp)
    80004cf6:	6946                	ld	s2,80(sp)
    80004cf8:	69a6                	ld	s3,72(sp)
    80004cfa:	6a06                	ld	s4,64(sp)
    80004cfc:	7ae2                	ld	s5,56(sp)
    80004cfe:	7b42                	ld	s6,48(sp)
    80004d00:	7ba2                	ld	s7,40(sp)
    80004d02:	7c02                	ld	s8,32(sp)
    80004d04:	6ce2                	ld	s9,24(sp)
    80004d06:	6d42                	ld	s10,16(sp)
    80004d08:	6da2                	ld	s11,8(sp)
    80004d0a:	6165                	addi	sp,sp,112
    80004d0c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004d0e:	8a5e                	mv	s4,s7
    80004d10:	bfc9                	j	80004ce2 <writei+0xe2>
    return -1;
    80004d12:	557d                	li	a0,-1
}
    80004d14:	8082                	ret
    return -1;
    80004d16:	557d                	li	a0,-1
    80004d18:	bfe1                	j	80004cf0 <writei+0xf0>
    return -1;
    80004d1a:	557d                	li	a0,-1
    80004d1c:	bfd1                	j	80004cf0 <writei+0xf0>

0000000080004d1e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004d1e:	1141                	addi	sp,sp,-16
    80004d20:	e406                	sd	ra,8(sp)
    80004d22:	e022                	sd	s0,0(sp)
    80004d24:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004d26:	4639                	li	a2,14
    80004d28:	ffffc097          	auipc	ra,0xffffc
    80004d2c:	094080e7          	jalr	148(ra) # 80000dbc <strncmp>
}
    80004d30:	60a2                	ld	ra,8(sp)
    80004d32:	6402                	ld	s0,0(sp)
    80004d34:	0141                	addi	sp,sp,16
    80004d36:	8082                	ret

0000000080004d38 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004d38:	7139                	addi	sp,sp,-64
    80004d3a:	fc06                	sd	ra,56(sp)
    80004d3c:	f822                	sd	s0,48(sp)
    80004d3e:	f426                	sd	s1,40(sp)
    80004d40:	f04a                	sd	s2,32(sp)
    80004d42:	ec4e                	sd	s3,24(sp)
    80004d44:	e852                	sd	s4,16(sp)
    80004d46:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004d48:	04451703          	lh	a4,68(a0)
    80004d4c:	4785                	li	a5,1
    80004d4e:	00f71a63          	bne	a4,a5,80004d62 <dirlookup+0x2a>
    80004d52:	892a                	mv	s2,a0
    80004d54:	89ae                	mv	s3,a1
    80004d56:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d58:	457c                	lw	a5,76(a0)
    80004d5a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004d5c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d5e:	e79d                	bnez	a5,80004d8c <dirlookup+0x54>
    80004d60:	a8a5                	j	80004dd8 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004d62:	00005517          	auipc	a0,0x5
    80004d66:	aae50513          	addi	a0,a0,-1362 # 80009810 <syscalls+0x1d8>
    80004d6a:	ffffb097          	auipc	ra,0xffffb
    80004d6e:	7c4080e7          	jalr	1988(ra) # 8000052e <panic>
      panic("dirlookup read");
    80004d72:	00005517          	auipc	a0,0x5
    80004d76:	ab650513          	addi	a0,a0,-1354 # 80009828 <syscalls+0x1f0>
    80004d7a:	ffffb097          	auipc	ra,0xffffb
    80004d7e:	7b4080e7          	jalr	1972(ra) # 8000052e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d82:	24c1                	addiw	s1,s1,16
    80004d84:	04c92783          	lw	a5,76(s2)
    80004d88:	04f4f763          	bgeu	s1,a5,80004dd6 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d8c:	4741                	li	a4,16
    80004d8e:	86a6                	mv	a3,s1
    80004d90:	fc040613          	addi	a2,s0,-64
    80004d94:	4581                	li	a1,0
    80004d96:	854a                	mv	a0,s2
    80004d98:	00000097          	auipc	ra,0x0
    80004d9c:	d70080e7          	jalr	-656(ra) # 80004b08 <readi>
    80004da0:	47c1                	li	a5,16
    80004da2:	fcf518e3          	bne	a0,a5,80004d72 <dirlookup+0x3a>
    if(de.inum == 0)
    80004da6:	fc045783          	lhu	a5,-64(s0)
    80004daa:	dfe1                	beqz	a5,80004d82 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004dac:	fc240593          	addi	a1,s0,-62
    80004db0:	854e                	mv	a0,s3
    80004db2:	00000097          	auipc	ra,0x0
    80004db6:	f6c080e7          	jalr	-148(ra) # 80004d1e <namecmp>
    80004dba:	f561                	bnez	a0,80004d82 <dirlookup+0x4a>
      if(poff)
    80004dbc:	000a0463          	beqz	s4,80004dc4 <dirlookup+0x8c>
        *poff = off;
    80004dc0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004dc4:	fc045583          	lhu	a1,-64(s0)
    80004dc8:	00092503          	lw	a0,0(s2)
    80004dcc:	fffff097          	auipc	ra,0xfffff
    80004dd0:	754080e7          	jalr	1876(ra) # 80004520 <iget>
    80004dd4:	a011                	j	80004dd8 <dirlookup+0xa0>
  return 0;
    80004dd6:	4501                	li	a0,0
}
    80004dd8:	70e2                	ld	ra,56(sp)
    80004dda:	7442                	ld	s0,48(sp)
    80004ddc:	74a2                	ld	s1,40(sp)
    80004dde:	7902                	ld	s2,32(sp)
    80004de0:	69e2                	ld	s3,24(sp)
    80004de2:	6a42                	ld	s4,16(sp)
    80004de4:	6121                	addi	sp,sp,64
    80004de6:	8082                	ret

0000000080004de8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004de8:	711d                	addi	sp,sp,-96
    80004dea:	ec86                	sd	ra,88(sp)
    80004dec:	e8a2                	sd	s0,80(sp)
    80004dee:	e4a6                	sd	s1,72(sp)
    80004df0:	e0ca                	sd	s2,64(sp)
    80004df2:	fc4e                	sd	s3,56(sp)
    80004df4:	f852                	sd	s4,48(sp)
    80004df6:	f456                	sd	s5,40(sp)
    80004df8:	f05a                	sd	s6,32(sp)
    80004dfa:	ec5e                	sd	s7,24(sp)
    80004dfc:	e862                	sd	s8,16(sp)
    80004dfe:	e466                	sd	s9,8(sp)
    80004e00:	1080                	addi	s0,sp,96
    80004e02:	84aa                	mv	s1,a0
    80004e04:	8aae                	mv	s5,a1
    80004e06:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004e08:	00054703          	lbu	a4,0(a0)
    80004e0c:	02f00793          	li	a5,47
    80004e10:	02f70263          	beq	a4,a5,80004e34 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004e14:	ffffd097          	auipc	ra,0xffffd
    80004e18:	c68080e7          	jalr	-920(ra) # 80001a7c <myproc>
    80004e1c:	6968                	ld	a0,208(a0)
    80004e1e:	00000097          	auipc	ra,0x0
    80004e22:	9f8080e7          	jalr	-1544(ra) # 80004816 <idup>
    80004e26:	89aa                	mv	s3,a0
  while(*path == '/')
    80004e28:	02f00913          	li	s2,47
  len = path - s;
    80004e2c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004e2e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004e30:	4b85                	li	s7,1
    80004e32:	a865                	j	80004eea <namex+0x102>
    ip = iget(ROOTDEV, ROOTINO);
    80004e34:	4585                	li	a1,1
    80004e36:	4505                	li	a0,1
    80004e38:	fffff097          	auipc	ra,0xfffff
    80004e3c:	6e8080e7          	jalr	1768(ra) # 80004520 <iget>
    80004e40:	89aa                	mv	s3,a0
    80004e42:	b7dd                	j	80004e28 <namex+0x40>
      iunlockput(ip);
    80004e44:	854e                	mv	a0,s3
    80004e46:	00000097          	auipc	ra,0x0
    80004e4a:	c70080e7          	jalr	-912(ra) # 80004ab6 <iunlockput>
      return 0;
    80004e4e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004e50:	854e                	mv	a0,s3
    80004e52:	60e6                	ld	ra,88(sp)
    80004e54:	6446                	ld	s0,80(sp)
    80004e56:	64a6                	ld	s1,72(sp)
    80004e58:	6906                	ld	s2,64(sp)
    80004e5a:	79e2                	ld	s3,56(sp)
    80004e5c:	7a42                	ld	s4,48(sp)
    80004e5e:	7aa2                	ld	s5,40(sp)
    80004e60:	7b02                	ld	s6,32(sp)
    80004e62:	6be2                	ld	s7,24(sp)
    80004e64:	6c42                	ld	s8,16(sp)
    80004e66:	6ca2                	ld	s9,8(sp)
    80004e68:	6125                	addi	sp,sp,96
    80004e6a:	8082                	ret
      iunlock(ip);
    80004e6c:	854e                	mv	a0,s3
    80004e6e:	00000097          	auipc	ra,0x0
    80004e72:	aa8080e7          	jalr	-1368(ra) # 80004916 <iunlock>
      return ip;
    80004e76:	bfe9                	j	80004e50 <namex+0x68>
      iunlockput(ip);
    80004e78:	854e                	mv	a0,s3
    80004e7a:	00000097          	auipc	ra,0x0
    80004e7e:	c3c080e7          	jalr	-964(ra) # 80004ab6 <iunlockput>
      return 0;
    80004e82:	89e6                	mv	s3,s9
    80004e84:	b7f1                	j	80004e50 <namex+0x68>
  len = path - s;
    80004e86:	40b48633          	sub	a2,s1,a1
    80004e8a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004e8e:	099c5463          	bge	s8,s9,80004f16 <namex+0x12e>
    memmove(name, s, DIRSIZ);
    80004e92:	4639                	li	a2,14
    80004e94:	8552                	mv	a0,s4
    80004e96:	ffffc097          	auipc	ra,0xffffc
    80004e9a:	eaa080e7          	jalr	-342(ra) # 80000d40 <memmove>
  while(*path == '/')
    80004e9e:	0004c783          	lbu	a5,0(s1)
    80004ea2:	01279763          	bne	a5,s2,80004eb0 <namex+0xc8>
    path++;
    80004ea6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004ea8:	0004c783          	lbu	a5,0(s1)
    80004eac:	ff278de3          	beq	a5,s2,80004ea6 <namex+0xbe>
    ilock(ip);
    80004eb0:	854e                	mv	a0,s3
    80004eb2:	00000097          	auipc	ra,0x0
    80004eb6:	9a2080e7          	jalr	-1630(ra) # 80004854 <ilock>
    if(ip->type != T_DIR){
    80004eba:	04499783          	lh	a5,68(s3)
    80004ebe:	f97793e3          	bne	a5,s7,80004e44 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004ec2:	000a8563          	beqz	s5,80004ecc <namex+0xe4>
    80004ec6:	0004c783          	lbu	a5,0(s1)
    80004eca:	d3cd                	beqz	a5,80004e6c <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004ecc:	865a                	mv	a2,s6
    80004ece:	85d2                	mv	a1,s4
    80004ed0:	854e                	mv	a0,s3
    80004ed2:	00000097          	auipc	ra,0x0
    80004ed6:	e66080e7          	jalr	-410(ra) # 80004d38 <dirlookup>
    80004eda:	8caa                	mv	s9,a0
    80004edc:	dd51                	beqz	a0,80004e78 <namex+0x90>
    iunlockput(ip);
    80004ede:	854e                	mv	a0,s3
    80004ee0:	00000097          	auipc	ra,0x0
    80004ee4:	bd6080e7          	jalr	-1066(ra) # 80004ab6 <iunlockput>
    ip = next;
    80004ee8:	89e6                	mv	s3,s9
  while(*path == '/')
    80004eea:	0004c783          	lbu	a5,0(s1)
    80004eee:	05279763          	bne	a5,s2,80004f3c <namex+0x154>
    path++;
    80004ef2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004ef4:	0004c783          	lbu	a5,0(s1)
    80004ef8:	ff278de3          	beq	a5,s2,80004ef2 <namex+0x10a>
  if(*path == 0)
    80004efc:	c79d                	beqz	a5,80004f2a <namex+0x142>
    path++;
    80004efe:	85a6                	mv	a1,s1
  len = path - s;
    80004f00:	8cda                	mv	s9,s6
    80004f02:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004f04:	01278963          	beq	a5,s2,80004f16 <namex+0x12e>
    80004f08:	dfbd                	beqz	a5,80004e86 <namex+0x9e>
    path++;
    80004f0a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004f0c:	0004c783          	lbu	a5,0(s1)
    80004f10:	ff279ce3          	bne	a5,s2,80004f08 <namex+0x120>
    80004f14:	bf8d                	j	80004e86 <namex+0x9e>
    memmove(name, s, len);
    80004f16:	2601                	sext.w	a2,a2
    80004f18:	8552                	mv	a0,s4
    80004f1a:	ffffc097          	auipc	ra,0xffffc
    80004f1e:	e26080e7          	jalr	-474(ra) # 80000d40 <memmove>
    name[len] = 0;
    80004f22:	9cd2                	add	s9,s9,s4
    80004f24:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004f28:	bf9d                	j	80004e9e <namex+0xb6>
  if(nameiparent){
    80004f2a:	f20a83e3          	beqz	s5,80004e50 <namex+0x68>
    iput(ip);
    80004f2e:	854e                	mv	a0,s3
    80004f30:	00000097          	auipc	ra,0x0
    80004f34:	ade080e7          	jalr	-1314(ra) # 80004a0e <iput>
    return 0;
    80004f38:	4981                	li	s3,0
    80004f3a:	bf19                	j	80004e50 <namex+0x68>
  if(*path == 0)
    80004f3c:	d7fd                	beqz	a5,80004f2a <namex+0x142>
  while(*path != '/' && *path != 0)
    80004f3e:	0004c783          	lbu	a5,0(s1)
    80004f42:	85a6                	mv	a1,s1
    80004f44:	b7d1                	j	80004f08 <namex+0x120>

0000000080004f46 <dirlink>:
{
    80004f46:	7139                	addi	sp,sp,-64
    80004f48:	fc06                	sd	ra,56(sp)
    80004f4a:	f822                	sd	s0,48(sp)
    80004f4c:	f426                	sd	s1,40(sp)
    80004f4e:	f04a                	sd	s2,32(sp)
    80004f50:	ec4e                	sd	s3,24(sp)
    80004f52:	e852                	sd	s4,16(sp)
    80004f54:	0080                	addi	s0,sp,64
    80004f56:	892a                	mv	s2,a0
    80004f58:	8a2e                	mv	s4,a1
    80004f5a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004f5c:	4601                	li	a2,0
    80004f5e:	00000097          	auipc	ra,0x0
    80004f62:	dda080e7          	jalr	-550(ra) # 80004d38 <dirlookup>
    80004f66:	e93d                	bnez	a0,80004fdc <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004f68:	04c92483          	lw	s1,76(s2)
    80004f6c:	c49d                	beqz	s1,80004f9a <dirlink+0x54>
    80004f6e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f70:	4741                	li	a4,16
    80004f72:	86a6                	mv	a3,s1
    80004f74:	fc040613          	addi	a2,s0,-64
    80004f78:	4581                	li	a1,0
    80004f7a:	854a                	mv	a0,s2
    80004f7c:	00000097          	auipc	ra,0x0
    80004f80:	b8c080e7          	jalr	-1140(ra) # 80004b08 <readi>
    80004f84:	47c1                	li	a5,16
    80004f86:	06f51163          	bne	a0,a5,80004fe8 <dirlink+0xa2>
    if(de.inum == 0)
    80004f8a:	fc045783          	lhu	a5,-64(s0)
    80004f8e:	c791                	beqz	a5,80004f9a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004f90:	24c1                	addiw	s1,s1,16
    80004f92:	04c92783          	lw	a5,76(s2)
    80004f96:	fcf4ede3          	bltu	s1,a5,80004f70 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004f9a:	4639                	li	a2,14
    80004f9c:	85d2                	mv	a1,s4
    80004f9e:	fc240513          	addi	a0,s0,-62
    80004fa2:	ffffc097          	auipc	ra,0xffffc
    80004fa6:	e56080e7          	jalr	-426(ra) # 80000df8 <strncpy>
  de.inum = inum;
    80004faa:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004fae:	4741                	li	a4,16
    80004fb0:	86a6                	mv	a3,s1
    80004fb2:	fc040613          	addi	a2,s0,-64
    80004fb6:	4581                	li	a1,0
    80004fb8:	854a                	mv	a0,s2
    80004fba:	00000097          	auipc	ra,0x0
    80004fbe:	c46080e7          	jalr	-954(ra) # 80004c00 <writei>
    80004fc2:	872a                	mv	a4,a0
    80004fc4:	47c1                	li	a5,16
  return 0;
    80004fc6:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004fc8:	02f71863          	bne	a4,a5,80004ff8 <dirlink+0xb2>
}
    80004fcc:	70e2                	ld	ra,56(sp)
    80004fce:	7442                	ld	s0,48(sp)
    80004fd0:	74a2                	ld	s1,40(sp)
    80004fd2:	7902                	ld	s2,32(sp)
    80004fd4:	69e2                	ld	s3,24(sp)
    80004fd6:	6a42                	ld	s4,16(sp)
    80004fd8:	6121                	addi	sp,sp,64
    80004fda:	8082                	ret
    iput(ip);
    80004fdc:	00000097          	auipc	ra,0x0
    80004fe0:	a32080e7          	jalr	-1486(ra) # 80004a0e <iput>
    return -1;
    80004fe4:	557d                	li	a0,-1
    80004fe6:	b7dd                	j	80004fcc <dirlink+0x86>
      panic("dirlink read");
    80004fe8:	00005517          	auipc	a0,0x5
    80004fec:	85050513          	addi	a0,a0,-1968 # 80009838 <syscalls+0x200>
    80004ff0:	ffffb097          	auipc	ra,0xffffb
    80004ff4:	53e080e7          	jalr	1342(ra) # 8000052e <panic>
    panic("dirlink");
    80004ff8:	00005517          	auipc	a0,0x5
    80004ffc:	95050513          	addi	a0,a0,-1712 # 80009948 <syscalls+0x310>
    80005000:	ffffb097          	auipc	ra,0xffffb
    80005004:	52e080e7          	jalr	1326(ra) # 8000052e <panic>

0000000080005008 <namei>:

struct inode*
namei(char *path)
{
    80005008:	1101                	addi	sp,sp,-32
    8000500a:	ec06                	sd	ra,24(sp)
    8000500c:	e822                	sd	s0,16(sp)
    8000500e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80005010:	fe040613          	addi	a2,s0,-32
    80005014:	4581                	li	a1,0
    80005016:	00000097          	auipc	ra,0x0
    8000501a:	dd2080e7          	jalr	-558(ra) # 80004de8 <namex>
}
    8000501e:	60e2                	ld	ra,24(sp)
    80005020:	6442                	ld	s0,16(sp)
    80005022:	6105                	addi	sp,sp,32
    80005024:	8082                	ret

0000000080005026 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80005026:	1141                	addi	sp,sp,-16
    80005028:	e406                	sd	ra,8(sp)
    8000502a:	e022                	sd	s0,0(sp)
    8000502c:	0800                	addi	s0,sp,16
    8000502e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80005030:	4585                	li	a1,1
    80005032:	00000097          	auipc	ra,0x0
    80005036:	db6080e7          	jalr	-586(ra) # 80004de8 <namex>
}
    8000503a:	60a2                	ld	ra,8(sp)
    8000503c:	6402                	ld	s0,0(sp)
    8000503e:	0141                	addi	sp,sp,16
    80005040:	8082                	ret

0000000080005042 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80005042:	1101                	addi	sp,sp,-32
    80005044:	ec06                	sd	ra,24(sp)
    80005046:	e822                	sd	s0,16(sp)
    80005048:	e426                	sd	s1,8(sp)
    8000504a:	e04a                	sd	s2,0(sp)
    8000504c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000504e:	00039917          	auipc	s2,0x39
    80005052:	a7a90913          	addi	s2,s2,-1414 # 8003dac8 <log>
    80005056:	01892583          	lw	a1,24(s2)
    8000505a:	02892503          	lw	a0,40(s2)
    8000505e:	fffff097          	auipc	ra,0xfffff
    80005062:	ff2080e7          	jalr	-14(ra) # 80004050 <bread>
    80005066:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80005068:	02c92683          	lw	a3,44(s2)
    8000506c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000506e:	02d05863          	blez	a3,8000509e <write_head+0x5c>
    80005072:	00039797          	auipc	a5,0x39
    80005076:	a8678793          	addi	a5,a5,-1402 # 8003daf8 <log+0x30>
    8000507a:	05c50713          	addi	a4,a0,92
    8000507e:	36fd                	addiw	a3,a3,-1
    80005080:	02069613          	slli	a2,a3,0x20
    80005084:	01e65693          	srli	a3,a2,0x1e
    80005088:	00039617          	auipc	a2,0x39
    8000508c:	a7460613          	addi	a2,a2,-1420 # 8003dafc <log+0x34>
    80005090:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80005092:	4390                	lw	a2,0(a5)
    80005094:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005096:	0791                	addi	a5,a5,4
    80005098:	0711                	addi	a4,a4,4
    8000509a:	fed79ce3          	bne	a5,a3,80005092 <write_head+0x50>
  }
  bwrite(buf);
    8000509e:	8526                	mv	a0,s1
    800050a0:	fffff097          	auipc	ra,0xfffff
    800050a4:	0a2080e7          	jalr	162(ra) # 80004142 <bwrite>
  brelse(buf);
    800050a8:	8526                	mv	a0,s1
    800050aa:	fffff097          	auipc	ra,0xfffff
    800050ae:	0d6080e7          	jalr	214(ra) # 80004180 <brelse>
}
    800050b2:	60e2                	ld	ra,24(sp)
    800050b4:	6442                	ld	s0,16(sp)
    800050b6:	64a2                	ld	s1,8(sp)
    800050b8:	6902                	ld	s2,0(sp)
    800050ba:	6105                	addi	sp,sp,32
    800050bc:	8082                	ret

00000000800050be <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800050be:	00039797          	auipc	a5,0x39
    800050c2:	a367a783          	lw	a5,-1482(a5) # 8003daf4 <log+0x2c>
    800050c6:	0af05d63          	blez	a5,80005180 <install_trans+0xc2>
{
    800050ca:	7139                	addi	sp,sp,-64
    800050cc:	fc06                	sd	ra,56(sp)
    800050ce:	f822                	sd	s0,48(sp)
    800050d0:	f426                	sd	s1,40(sp)
    800050d2:	f04a                	sd	s2,32(sp)
    800050d4:	ec4e                	sd	s3,24(sp)
    800050d6:	e852                	sd	s4,16(sp)
    800050d8:	e456                	sd	s5,8(sp)
    800050da:	e05a                	sd	s6,0(sp)
    800050dc:	0080                	addi	s0,sp,64
    800050de:	8b2a                	mv	s6,a0
    800050e0:	00039a97          	auipc	s5,0x39
    800050e4:	a18a8a93          	addi	s5,s5,-1512 # 8003daf8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800050e8:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800050ea:	00039997          	auipc	s3,0x39
    800050ee:	9de98993          	addi	s3,s3,-1570 # 8003dac8 <log>
    800050f2:	a00d                	j	80005114 <install_trans+0x56>
    brelse(lbuf);
    800050f4:	854a                	mv	a0,s2
    800050f6:	fffff097          	auipc	ra,0xfffff
    800050fa:	08a080e7          	jalr	138(ra) # 80004180 <brelse>
    brelse(dbuf);
    800050fe:	8526                	mv	a0,s1
    80005100:	fffff097          	auipc	ra,0xfffff
    80005104:	080080e7          	jalr	128(ra) # 80004180 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005108:	2a05                	addiw	s4,s4,1
    8000510a:	0a91                	addi	s5,s5,4
    8000510c:	02c9a783          	lw	a5,44(s3)
    80005110:	04fa5e63          	bge	s4,a5,8000516c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80005114:	0189a583          	lw	a1,24(s3)
    80005118:	014585bb          	addw	a1,a1,s4
    8000511c:	2585                	addiw	a1,a1,1
    8000511e:	0289a503          	lw	a0,40(s3)
    80005122:	fffff097          	auipc	ra,0xfffff
    80005126:	f2e080e7          	jalr	-210(ra) # 80004050 <bread>
    8000512a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000512c:	000aa583          	lw	a1,0(s5)
    80005130:	0289a503          	lw	a0,40(s3)
    80005134:	fffff097          	auipc	ra,0xfffff
    80005138:	f1c080e7          	jalr	-228(ra) # 80004050 <bread>
    8000513c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000513e:	40000613          	li	a2,1024
    80005142:	05890593          	addi	a1,s2,88
    80005146:	05850513          	addi	a0,a0,88
    8000514a:	ffffc097          	auipc	ra,0xffffc
    8000514e:	bf6080e7          	jalr	-1034(ra) # 80000d40 <memmove>
    bwrite(dbuf);  // write dst to disk
    80005152:	8526                	mv	a0,s1
    80005154:	fffff097          	auipc	ra,0xfffff
    80005158:	fee080e7          	jalr	-18(ra) # 80004142 <bwrite>
    if(recovering == 0)
    8000515c:	f80b1ce3          	bnez	s6,800050f4 <install_trans+0x36>
      bunpin(dbuf);
    80005160:	8526                	mv	a0,s1
    80005162:	fffff097          	auipc	ra,0xfffff
    80005166:	0f8080e7          	jalr	248(ra) # 8000425a <bunpin>
    8000516a:	b769                	j	800050f4 <install_trans+0x36>
}
    8000516c:	70e2                	ld	ra,56(sp)
    8000516e:	7442                	ld	s0,48(sp)
    80005170:	74a2                	ld	s1,40(sp)
    80005172:	7902                	ld	s2,32(sp)
    80005174:	69e2                	ld	s3,24(sp)
    80005176:	6a42                	ld	s4,16(sp)
    80005178:	6aa2                	ld	s5,8(sp)
    8000517a:	6b02                	ld	s6,0(sp)
    8000517c:	6121                	addi	sp,sp,64
    8000517e:	8082                	ret
    80005180:	8082                	ret

0000000080005182 <initlog>:
{
    80005182:	7179                	addi	sp,sp,-48
    80005184:	f406                	sd	ra,40(sp)
    80005186:	f022                	sd	s0,32(sp)
    80005188:	ec26                	sd	s1,24(sp)
    8000518a:	e84a                	sd	s2,16(sp)
    8000518c:	e44e                	sd	s3,8(sp)
    8000518e:	1800                	addi	s0,sp,48
    80005190:	892a                	mv	s2,a0
    80005192:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80005194:	00039497          	auipc	s1,0x39
    80005198:	93448493          	addi	s1,s1,-1740 # 8003dac8 <log>
    8000519c:	00004597          	auipc	a1,0x4
    800051a0:	6ac58593          	addi	a1,a1,1708 # 80009848 <syscalls+0x210>
    800051a4:	8526                	mv	a0,s1
    800051a6:	ffffc097          	auipc	ra,0xffffc
    800051aa:	990080e7          	jalr	-1648(ra) # 80000b36 <initlock>
  log.start = sb->logstart;
    800051ae:	0149a583          	lw	a1,20(s3)
    800051b2:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800051b4:	0109a783          	lw	a5,16(s3)
    800051b8:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800051ba:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800051be:	854a                	mv	a0,s2
    800051c0:	fffff097          	auipc	ra,0xfffff
    800051c4:	e90080e7          	jalr	-368(ra) # 80004050 <bread>
  log.lh.n = lh->n;
    800051c8:	4d34                	lw	a3,88(a0)
    800051ca:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800051cc:	02d05663          	blez	a3,800051f8 <initlog+0x76>
    800051d0:	05c50793          	addi	a5,a0,92
    800051d4:	00039717          	auipc	a4,0x39
    800051d8:	92470713          	addi	a4,a4,-1756 # 8003daf8 <log+0x30>
    800051dc:	36fd                	addiw	a3,a3,-1
    800051de:	02069613          	slli	a2,a3,0x20
    800051e2:	01e65693          	srli	a3,a2,0x1e
    800051e6:	06050613          	addi	a2,a0,96
    800051ea:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800051ec:	4390                	lw	a2,0(a5)
    800051ee:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800051f0:	0791                	addi	a5,a5,4
    800051f2:	0711                	addi	a4,a4,4
    800051f4:	fed79ce3          	bne	a5,a3,800051ec <initlog+0x6a>
  brelse(buf);
    800051f8:	fffff097          	auipc	ra,0xfffff
    800051fc:	f88080e7          	jalr	-120(ra) # 80004180 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80005200:	4505                	li	a0,1
    80005202:	00000097          	auipc	ra,0x0
    80005206:	ebc080e7          	jalr	-324(ra) # 800050be <install_trans>
  log.lh.n = 0;
    8000520a:	00039797          	auipc	a5,0x39
    8000520e:	8e07a523          	sw	zero,-1814(a5) # 8003daf4 <log+0x2c>
  write_head(); // clear the log
    80005212:	00000097          	auipc	ra,0x0
    80005216:	e30080e7          	jalr	-464(ra) # 80005042 <write_head>
}
    8000521a:	70a2                	ld	ra,40(sp)
    8000521c:	7402                	ld	s0,32(sp)
    8000521e:	64e2                	ld	s1,24(sp)
    80005220:	6942                	ld	s2,16(sp)
    80005222:	69a2                	ld	s3,8(sp)
    80005224:	6145                	addi	sp,sp,48
    80005226:	8082                	ret

0000000080005228 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80005228:	1101                	addi	sp,sp,-32
    8000522a:	ec06                	sd	ra,24(sp)
    8000522c:	e822                	sd	s0,16(sp)
    8000522e:	e426                	sd	s1,8(sp)
    80005230:	e04a                	sd	s2,0(sp)
    80005232:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80005234:	00039517          	auipc	a0,0x39
    80005238:	89450513          	addi	a0,a0,-1900 # 8003dac8 <log>
    8000523c:	ffffc097          	auipc	ra,0xffffc
    80005240:	98a080e7          	jalr	-1654(ra) # 80000bc6 <acquire>
  while(1){
    if(log.committing){
    80005244:	00039497          	auipc	s1,0x39
    80005248:	88448493          	addi	s1,s1,-1916 # 8003dac8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000524c:	4979                	li	s2,30
    8000524e:	a039                	j	8000525c <begin_op+0x34>
      sleep(&log, &log.lock);
    80005250:	85a6                	mv	a1,s1
    80005252:	8526                	mv	a0,s1
    80005254:	ffffd097          	auipc	ra,0xffffd
    80005258:	1f4080e7          	jalr	500(ra) # 80002448 <sleep>
    if(log.committing){
    8000525c:	50dc                	lw	a5,36(s1)
    8000525e:	fbed                	bnez	a5,80005250 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80005260:	509c                	lw	a5,32(s1)
    80005262:	0017871b          	addiw	a4,a5,1
    80005266:	0007069b          	sext.w	a3,a4
    8000526a:	0027179b          	slliw	a5,a4,0x2
    8000526e:	9fb9                	addw	a5,a5,a4
    80005270:	0017979b          	slliw	a5,a5,0x1
    80005274:	54d8                	lw	a4,44(s1)
    80005276:	9fb9                	addw	a5,a5,a4
    80005278:	00f95963          	bge	s2,a5,8000528a <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000527c:	85a6                	mv	a1,s1
    8000527e:	8526                	mv	a0,s1
    80005280:	ffffd097          	auipc	ra,0xffffd
    80005284:	1c8080e7          	jalr	456(ra) # 80002448 <sleep>
    80005288:	bfd1                	j	8000525c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000528a:	00039517          	auipc	a0,0x39
    8000528e:	83e50513          	addi	a0,a0,-1986 # 8003dac8 <log>
    80005292:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80005294:	ffffc097          	auipc	ra,0xffffc
    80005298:	a08080e7          	jalr	-1528(ra) # 80000c9c <release>
      break;
    }
  }
}
    8000529c:	60e2                	ld	ra,24(sp)
    8000529e:	6442                	ld	s0,16(sp)
    800052a0:	64a2                	ld	s1,8(sp)
    800052a2:	6902                	ld	s2,0(sp)
    800052a4:	6105                	addi	sp,sp,32
    800052a6:	8082                	ret

00000000800052a8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800052a8:	7139                	addi	sp,sp,-64
    800052aa:	fc06                	sd	ra,56(sp)
    800052ac:	f822                	sd	s0,48(sp)
    800052ae:	f426                	sd	s1,40(sp)
    800052b0:	f04a                	sd	s2,32(sp)
    800052b2:	ec4e                	sd	s3,24(sp)
    800052b4:	e852                	sd	s4,16(sp)
    800052b6:	e456                	sd	s5,8(sp)
    800052b8:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800052ba:	00039497          	auipc	s1,0x39
    800052be:	80e48493          	addi	s1,s1,-2034 # 8003dac8 <log>
    800052c2:	8526                	mv	a0,s1
    800052c4:	ffffc097          	auipc	ra,0xffffc
    800052c8:	902080e7          	jalr	-1790(ra) # 80000bc6 <acquire>
  log.outstanding -= 1;
    800052cc:	509c                	lw	a5,32(s1)
    800052ce:	37fd                	addiw	a5,a5,-1
    800052d0:	0007891b          	sext.w	s2,a5
    800052d4:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800052d6:	50dc                	lw	a5,36(s1)
    800052d8:	e7b9                	bnez	a5,80005326 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800052da:	04091e63          	bnez	s2,80005336 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800052de:	00038497          	auipc	s1,0x38
    800052e2:	7ea48493          	addi	s1,s1,2026 # 8003dac8 <log>
    800052e6:	4785                	li	a5,1
    800052e8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800052ea:	8526                	mv	a0,s1
    800052ec:	ffffc097          	auipc	ra,0xffffc
    800052f0:	9b0080e7          	jalr	-1616(ra) # 80000c9c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800052f4:	54dc                	lw	a5,44(s1)
    800052f6:	06f04763          	bgtz	a5,80005364 <end_op+0xbc>
    acquire(&log.lock);
    800052fa:	00038497          	auipc	s1,0x38
    800052fe:	7ce48493          	addi	s1,s1,1998 # 8003dac8 <log>
    80005302:	8526                	mv	a0,s1
    80005304:	ffffc097          	auipc	ra,0xffffc
    80005308:	8c2080e7          	jalr	-1854(ra) # 80000bc6 <acquire>
    log.committing = 0;
    8000530c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80005310:	8526                	mv	a0,s1
    80005312:	ffffd097          	auipc	ra,0xffffd
    80005316:	2ca080e7          	jalr	714(ra) # 800025dc <wakeup>
    release(&log.lock);
    8000531a:	8526                	mv	a0,s1
    8000531c:	ffffc097          	auipc	ra,0xffffc
    80005320:	980080e7          	jalr	-1664(ra) # 80000c9c <release>
}
    80005324:	a03d                	j	80005352 <end_op+0xaa>
    panic("log.committing");
    80005326:	00004517          	auipc	a0,0x4
    8000532a:	52a50513          	addi	a0,a0,1322 # 80009850 <syscalls+0x218>
    8000532e:	ffffb097          	auipc	ra,0xffffb
    80005332:	200080e7          	jalr	512(ra) # 8000052e <panic>
    wakeup(&log);
    80005336:	00038497          	auipc	s1,0x38
    8000533a:	79248493          	addi	s1,s1,1938 # 8003dac8 <log>
    8000533e:	8526                	mv	a0,s1
    80005340:	ffffd097          	auipc	ra,0xffffd
    80005344:	29c080e7          	jalr	668(ra) # 800025dc <wakeup>
  release(&log.lock);
    80005348:	8526                	mv	a0,s1
    8000534a:	ffffc097          	auipc	ra,0xffffc
    8000534e:	952080e7          	jalr	-1710(ra) # 80000c9c <release>
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
  for (tail = 0; tail < log.lh.n; tail++) {
    80005364:	00038a97          	auipc	s5,0x38
    80005368:	794a8a93          	addi	s5,s5,1940 # 8003daf8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000536c:	00038a17          	auipc	s4,0x38
    80005370:	75ca0a13          	addi	s4,s4,1884 # 8003dac8 <log>
    80005374:	018a2583          	lw	a1,24(s4)
    80005378:	012585bb          	addw	a1,a1,s2
    8000537c:	2585                	addiw	a1,a1,1
    8000537e:	028a2503          	lw	a0,40(s4)
    80005382:	fffff097          	auipc	ra,0xfffff
    80005386:	cce080e7          	jalr	-818(ra) # 80004050 <bread>
    8000538a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000538c:	000aa583          	lw	a1,0(s5)
    80005390:	028a2503          	lw	a0,40(s4)
    80005394:	fffff097          	auipc	ra,0xfffff
    80005398:	cbc080e7          	jalr	-836(ra) # 80004050 <bread>
    8000539c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000539e:	40000613          	li	a2,1024
    800053a2:	05850593          	addi	a1,a0,88
    800053a6:	05848513          	addi	a0,s1,88
    800053aa:	ffffc097          	auipc	ra,0xffffc
    800053ae:	996080e7          	jalr	-1642(ra) # 80000d40 <memmove>
    bwrite(to);  // write the log
    800053b2:	8526                	mv	a0,s1
    800053b4:	fffff097          	auipc	ra,0xfffff
    800053b8:	d8e080e7          	jalr	-626(ra) # 80004142 <bwrite>
    brelse(from);
    800053bc:	854e                	mv	a0,s3
    800053be:	fffff097          	auipc	ra,0xfffff
    800053c2:	dc2080e7          	jalr	-574(ra) # 80004180 <brelse>
    brelse(to);
    800053c6:	8526                	mv	a0,s1
    800053c8:	fffff097          	auipc	ra,0xfffff
    800053cc:	db8080e7          	jalr	-584(ra) # 80004180 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800053d0:	2905                	addiw	s2,s2,1
    800053d2:	0a91                	addi	s5,s5,4
    800053d4:	02ca2783          	lw	a5,44(s4)
    800053d8:	f8f94ee3          	blt	s2,a5,80005374 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800053dc:	00000097          	auipc	ra,0x0
    800053e0:	c66080e7          	jalr	-922(ra) # 80005042 <write_head>
    install_trans(0); // Now install writes to home locations
    800053e4:	4501                	li	a0,0
    800053e6:	00000097          	auipc	ra,0x0
    800053ea:	cd8080e7          	jalr	-808(ra) # 800050be <install_trans>
    log.lh.n = 0;
    800053ee:	00038797          	auipc	a5,0x38
    800053f2:	7007a323          	sw	zero,1798(a5) # 8003daf4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800053f6:	00000097          	auipc	ra,0x0
    800053fa:	c4c080e7          	jalr	-948(ra) # 80005042 <write_head>
    800053fe:	bdf5                	j	800052fa <end_op+0x52>

0000000080005400 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80005400:	1101                	addi	sp,sp,-32
    80005402:	ec06                	sd	ra,24(sp)
    80005404:	e822                	sd	s0,16(sp)
    80005406:	e426                	sd	s1,8(sp)
    80005408:	e04a                	sd	s2,0(sp)
    8000540a:	1000                	addi	s0,sp,32
    8000540c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000540e:	00038917          	auipc	s2,0x38
    80005412:	6ba90913          	addi	s2,s2,1722 # 8003dac8 <log>
    80005416:	854a                	mv	a0,s2
    80005418:	ffffb097          	auipc	ra,0xffffb
    8000541c:	7ae080e7          	jalr	1966(ra) # 80000bc6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80005420:	02c92603          	lw	a2,44(s2)
    80005424:	47f5                	li	a5,29
    80005426:	06c7c563          	blt	a5,a2,80005490 <log_write+0x90>
    8000542a:	00038797          	auipc	a5,0x38
    8000542e:	6ba7a783          	lw	a5,1722(a5) # 8003dae4 <log+0x1c>
    80005432:	37fd                	addiw	a5,a5,-1
    80005434:	04f65e63          	bge	a2,a5,80005490 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80005438:	00038797          	auipc	a5,0x38
    8000543c:	6b07a783          	lw	a5,1712(a5) # 8003dae8 <log+0x20>
    80005440:	06f05063          	blez	a5,800054a0 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80005444:	4781                	li	a5,0
    80005446:	06c05563          	blez	a2,800054b0 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000544a:	44cc                	lw	a1,12(s1)
    8000544c:	00038717          	auipc	a4,0x38
    80005450:	6ac70713          	addi	a4,a4,1708 # 8003daf8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80005454:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80005456:	4314                	lw	a3,0(a4)
    80005458:	04b68c63          	beq	a3,a1,800054b0 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000545c:	2785                	addiw	a5,a5,1
    8000545e:	0711                	addi	a4,a4,4
    80005460:	fef61be3          	bne	a2,a5,80005456 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80005464:	0621                	addi	a2,a2,8
    80005466:	060a                	slli	a2,a2,0x2
    80005468:	00038797          	auipc	a5,0x38
    8000546c:	66078793          	addi	a5,a5,1632 # 8003dac8 <log>
    80005470:	963e                	add	a2,a2,a5
    80005472:	44dc                	lw	a5,12(s1)
    80005474:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80005476:	8526                	mv	a0,s1
    80005478:	fffff097          	auipc	ra,0xfffff
    8000547c:	da6080e7          	jalr	-602(ra) # 8000421e <bpin>
    log.lh.n++;
    80005480:	00038717          	auipc	a4,0x38
    80005484:	64870713          	addi	a4,a4,1608 # 8003dac8 <log>
    80005488:	575c                	lw	a5,44(a4)
    8000548a:	2785                	addiw	a5,a5,1
    8000548c:	d75c                	sw	a5,44(a4)
    8000548e:	a835                	j	800054ca <log_write+0xca>
    panic("too big a transaction");
    80005490:	00004517          	auipc	a0,0x4
    80005494:	3d050513          	addi	a0,a0,976 # 80009860 <syscalls+0x228>
    80005498:	ffffb097          	auipc	ra,0xffffb
    8000549c:	096080e7          	jalr	150(ra) # 8000052e <panic>
    panic("log_write outside of trans");
    800054a0:	00004517          	auipc	a0,0x4
    800054a4:	3d850513          	addi	a0,a0,984 # 80009878 <syscalls+0x240>
    800054a8:	ffffb097          	auipc	ra,0xffffb
    800054ac:	086080e7          	jalr	134(ra) # 8000052e <panic>
  log.lh.block[i] = b->blockno;
    800054b0:	00878713          	addi	a4,a5,8
    800054b4:	00271693          	slli	a3,a4,0x2
    800054b8:	00038717          	auipc	a4,0x38
    800054bc:	61070713          	addi	a4,a4,1552 # 8003dac8 <log>
    800054c0:	9736                	add	a4,a4,a3
    800054c2:	44d4                	lw	a3,12(s1)
    800054c4:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800054c6:	faf608e3          	beq	a2,a5,80005476 <log_write+0x76>
  }
  release(&log.lock);
    800054ca:	00038517          	auipc	a0,0x38
    800054ce:	5fe50513          	addi	a0,a0,1534 # 8003dac8 <log>
    800054d2:	ffffb097          	auipc	ra,0xffffb
    800054d6:	7ca080e7          	jalr	1994(ra) # 80000c9c <release>
}
    800054da:	60e2                	ld	ra,24(sp)
    800054dc:	6442                	ld	s0,16(sp)
    800054de:	64a2                	ld	s1,8(sp)
    800054e0:	6902                	ld	s2,0(sp)
    800054e2:	6105                	addi	sp,sp,32
    800054e4:	8082                	ret

00000000800054e6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800054e6:	1101                	addi	sp,sp,-32
    800054e8:	ec06                	sd	ra,24(sp)
    800054ea:	e822                	sd	s0,16(sp)
    800054ec:	e426                	sd	s1,8(sp)
    800054ee:	e04a                	sd	s2,0(sp)
    800054f0:	1000                	addi	s0,sp,32
    800054f2:	84aa                	mv	s1,a0
    800054f4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800054f6:	00004597          	auipc	a1,0x4
    800054fa:	3a258593          	addi	a1,a1,930 # 80009898 <syscalls+0x260>
    800054fe:	0521                	addi	a0,a0,8
    80005500:	ffffb097          	auipc	ra,0xffffb
    80005504:	636080e7          	jalr	1590(ra) # 80000b36 <initlock>
  lk->name = name;
    80005508:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000550c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005510:	0204a423          	sw	zero,40(s1)
}
    80005514:	60e2                	ld	ra,24(sp)
    80005516:	6442                	ld	s0,16(sp)
    80005518:	64a2                	ld	s1,8(sp)
    8000551a:	6902                	ld	s2,0(sp)
    8000551c:	6105                	addi	sp,sp,32
    8000551e:	8082                	ret

0000000080005520 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80005520:	1101                	addi	sp,sp,-32
    80005522:	ec06                	sd	ra,24(sp)
    80005524:	e822                	sd	s0,16(sp)
    80005526:	e426                	sd	s1,8(sp)
    80005528:	e04a                	sd	s2,0(sp)
    8000552a:	1000                	addi	s0,sp,32
    8000552c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000552e:	00850913          	addi	s2,a0,8
    80005532:	854a                	mv	a0,s2
    80005534:	ffffb097          	auipc	ra,0xffffb
    80005538:	692080e7          	jalr	1682(ra) # 80000bc6 <acquire>
  while (lk->locked) {
    8000553c:	409c                	lw	a5,0(s1)
    8000553e:	cb89                	beqz	a5,80005550 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80005540:	85ca                	mv	a1,s2
    80005542:	8526                	mv	a0,s1
    80005544:	ffffd097          	auipc	ra,0xffffd
    80005548:	f04080e7          	jalr	-252(ra) # 80002448 <sleep>
  while (lk->locked) {
    8000554c:	409c                	lw	a5,0(s1)
    8000554e:	fbed                	bnez	a5,80005540 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80005550:	4785                	li	a5,1
    80005552:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80005554:	ffffc097          	auipc	ra,0xffffc
    80005558:	528080e7          	jalr	1320(ra) # 80001a7c <myproc>
    8000555c:	515c                	lw	a5,36(a0)
    8000555e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005560:	854a                	mv	a0,s2
    80005562:	ffffb097          	auipc	ra,0xffffb
    80005566:	73a080e7          	jalr	1850(ra) # 80000c9c <release>
}
    8000556a:	60e2                	ld	ra,24(sp)
    8000556c:	6442                	ld	s0,16(sp)
    8000556e:	64a2                	ld	s1,8(sp)
    80005570:	6902                	ld	s2,0(sp)
    80005572:	6105                	addi	sp,sp,32
    80005574:	8082                	ret

0000000080005576 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005576:	1101                	addi	sp,sp,-32
    80005578:	ec06                	sd	ra,24(sp)
    8000557a:	e822                	sd	s0,16(sp)
    8000557c:	e426                	sd	s1,8(sp)
    8000557e:	e04a                	sd	s2,0(sp)
    80005580:	1000                	addi	s0,sp,32
    80005582:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005584:	00850913          	addi	s2,a0,8
    80005588:	854a                	mv	a0,s2
    8000558a:	ffffb097          	auipc	ra,0xffffb
    8000558e:	63c080e7          	jalr	1596(ra) # 80000bc6 <acquire>
  lk->locked = 0;
    80005592:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005596:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000559a:	8526                	mv	a0,s1
    8000559c:	ffffd097          	auipc	ra,0xffffd
    800055a0:	040080e7          	jalr	64(ra) # 800025dc <wakeup>
  release(&lk->lk);
    800055a4:	854a                	mv	a0,s2
    800055a6:	ffffb097          	auipc	ra,0xffffb
    800055aa:	6f6080e7          	jalr	1782(ra) # 80000c9c <release>
}
    800055ae:	60e2                	ld	ra,24(sp)
    800055b0:	6442                	ld	s0,16(sp)
    800055b2:	64a2                	ld	s1,8(sp)
    800055b4:	6902                	ld	s2,0(sp)
    800055b6:	6105                	addi	sp,sp,32
    800055b8:	8082                	ret

00000000800055ba <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800055ba:	7179                	addi	sp,sp,-48
    800055bc:	f406                	sd	ra,40(sp)
    800055be:	f022                	sd	s0,32(sp)
    800055c0:	ec26                	sd	s1,24(sp)
    800055c2:	e84a                	sd	s2,16(sp)
    800055c4:	e44e                	sd	s3,8(sp)
    800055c6:	1800                	addi	s0,sp,48
    800055c8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800055ca:	00850913          	addi	s2,a0,8
    800055ce:	854a                	mv	a0,s2
    800055d0:	ffffb097          	auipc	ra,0xffffb
    800055d4:	5f6080e7          	jalr	1526(ra) # 80000bc6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800055d8:	409c                	lw	a5,0(s1)
    800055da:	ef99                	bnez	a5,800055f8 <holdingsleep+0x3e>
    800055dc:	4481                	li	s1,0
  release(&lk->lk);
    800055de:	854a                	mv	a0,s2
    800055e0:	ffffb097          	auipc	ra,0xffffb
    800055e4:	6bc080e7          	jalr	1724(ra) # 80000c9c <release>
  return r;
}
    800055e8:	8526                	mv	a0,s1
    800055ea:	70a2                	ld	ra,40(sp)
    800055ec:	7402                	ld	s0,32(sp)
    800055ee:	64e2                	ld	s1,24(sp)
    800055f0:	6942                	ld	s2,16(sp)
    800055f2:	69a2                	ld	s3,8(sp)
    800055f4:	6145                	addi	sp,sp,48
    800055f6:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800055f8:	0284a983          	lw	s3,40(s1)
    800055fc:	ffffc097          	auipc	ra,0xffffc
    80005600:	480080e7          	jalr	1152(ra) # 80001a7c <myproc>
    80005604:	5144                	lw	s1,36(a0)
    80005606:	413484b3          	sub	s1,s1,s3
    8000560a:	0014b493          	seqz	s1,s1
    8000560e:	bfc1                	j	800055de <holdingsleep+0x24>

0000000080005610 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80005610:	1141                	addi	sp,sp,-16
    80005612:	e406                	sd	ra,8(sp)
    80005614:	e022                	sd	s0,0(sp)
    80005616:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80005618:	00004597          	auipc	a1,0x4
    8000561c:	29058593          	addi	a1,a1,656 # 800098a8 <syscalls+0x270>
    80005620:	00038517          	auipc	a0,0x38
    80005624:	5f050513          	addi	a0,a0,1520 # 8003dc10 <ftable>
    80005628:	ffffb097          	auipc	ra,0xffffb
    8000562c:	50e080e7          	jalr	1294(ra) # 80000b36 <initlock>
}
    80005630:	60a2                	ld	ra,8(sp)
    80005632:	6402                	ld	s0,0(sp)
    80005634:	0141                	addi	sp,sp,16
    80005636:	8082                	ret

0000000080005638 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80005638:	1101                	addi	sp,sp,-32
    8000563a:	ec06                	sd	ra,24(sp)
    8000563c:	e822                	sd	s0,16(sp)
    8000563e:	e426                	sd	s1,8(sp)
    80005640:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80005642:	00038517          	auipc	a0,0x38
    80005646:	5ce50513          	addi	a0,a0,1486 # 8003dc10 <ftable>
    8000564a:	ffffb097          	auipc	ra,0xffffb
    8000564e:	57c080e7          	jalr	1404(ra) # 80000bc6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005652:	00038497          	auipc	s1,0x38
    80005656:	5d648493          	addi	s1,s1,1494 # 8003dc28 <ftable+0x18>
    8000565a:	00039717          	auipc	a4,0x39
    8000565e:	56e70713          	addi	a4,a4,1390 # 8003ebc8 <ftable+0xfb8>
    if(f->ref == 0){
    80005662:	40dc                	lw	a5,4(s1)
    80005664:	cf99                	beqz	a5,80005682 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005666:	02848493          	addi	s1,s1,40
    8000566a:	fee49ce3          	bne	s1,a4,80005662 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000566e:	00038517          	auipc	a0,0x38
    80005672:	5a250513          	addi	a0,a0,1442 # 8003dc10 <ftable>
    80005676:	ffffb097          	auipc	ra,0xffffb
    8000567a:	626080e7          	jalr	1574(ra) # 80000c9c <release>
  return 0;
    8000567e:	4481                	li	s1,0
    80005680:	a819                	j	80005696 <filealloc+0x5e>
      f->ref = 1;
    80005682:	4785                	li	a5,1
    80005684:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005686:	00038517          	auipc	a0,0x38
    8000568a:	58a50513          	addi	a0,a0,1418 # 8003dc10 <ftable>
    8000568e:	ffffb097          	auipc	ra,0xffffb
    80005692:	60e080e7          	jalr	1550(ra) # 80000c9c <release>
}
    80005696:	8526                	mv	a0,s1
    80005698:	60e2                	ld	ra,24(sp)
    8000569a:	6442                	ld	s0,16(sp)
    8000569c:	64a2                	ld	s1,8(sp)
    8000569e:	6105                	addi	sp,sp,32
    800056a0:	8082                	ret

00000000800056a2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800056a2:	1101                	addi	sp,sp,-32
    800056a4:	ec06                	sd	ra,24(sp)
    800056a6:	e822                	sd	s0,16(sp)
    800056a8:	e426                	sd	s1,8(sp)
    800056aa:	1000                	addi	s0,sp,32
    800056ac:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800056ae:	00038517          	auipc	a0,0x38
    800056b2:	56250513          	addi	a0,a0,1378 # 8003dc10 <ftable>
    800056b6:	ffffb097          	auipc	ra,0xffffb
    800056ba:	510080e7          	jalr	1296(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    800056be:	40dc                	lw	a5,4(s1)
    800056c0:	02f05263          	blez	a5,800056e4 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800056c4:	2785                	addiw	a5,a5,1
    800056c6:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800056c8:	00038517          	auipc	a0,0x38
    800056cc:	54850513          	addi	a0,a0,1352 # 8003dc10 <ftable>
    800056d0:	ffffb097          	auipc	ra,0xffffb
    800056d4:	5cc080e7          	jalr	1484(ra) # 80000c9c <release>
  return f;
}
    800056d8:	8526                	mv	a0,s1
    800056da:	60e2                	ld	ra,24(sp)
    800056dc:	6442                	ld	s0,16(sp)
    800056de:	64a2                	ld	s1,8(sp)
    800056e0:	6105                	addi	sp,sp,32
    800056e2:	8082                	ret
    panic("filedup");
    800056e4:	00004517          	auipc	a0,0x4
    800056e8:	1cc50513          	addi	a0,a0,460 # 800098b0 <syscalls+0x278>
    800056ec:	ffffb097          	auipc	ra,0xffffb
    800056f0:	e42080e7          	jalr	-446(ra) # 8000052e <panic>

00000000800056f4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800056f4:	7139                	addi	sp,sp,-64
    800056f6:	fc06                	sd	ra,56(sp)
    800056f8:	f822                	sd	s0,48(sp)
    800056fa:	f426                	sd	s1,40(sp)
    800056fc:	f04a                	sd	s2,32(sp)
    800056fe:	ec4e                	sd	s3,24(sp)
    80005700:	e852                	sd	s4,16(sp)
    80005702:	e456                	sd	s5,8(sp)
    80005704:	0080                	addi	s0,sp,64
    80005706:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80005708:	00038517          	auipc	a0,0x38
    8000570c:	50850513          	addi	a0,a0,1288 # 8003dc10 <ftable>
    80005710:	ffffb097          	auipc	ra,0xffffb
    80005714:	4b6080e7          	jalr	1206(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    80005718:	40dc                	lw	a5,4(s1)
    8000571a:	06f05163          	blez	a5,8000577c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000571e:	37fd                	addiw	a5,a5,-1
    80005720:	0007871b          	sext.w	a4,a5
    80005724:	c0dc                	sw	a5,4(s1)
    80005726:	06e04363          	bgtz	a4,8000578c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000572a:	0004a903          	lw	s2,0(s1)
    8000572e:	0094ca83          	lbu	s5,9(s1)
    80005732:	0104ba03          	ld	s4,16(s1)
    80005736:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000573a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000573e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005742:	00038517          	auipc	a0,0x38
    80005746:	4ce50513          	addi	a0,a0,1230 # 8003dc10 <ftable>
    8000574a:	ffffb097          	auipc	ra,0xffffb
    8000574e:	552080e7          	jalr	1362(ra) # 80000c9c <release>

  if(ff.type == FD_PIPE){
    80005752:	4785                	li	a5,1
    80005754:	04f90d63          	beq	s2,a5,800057ae <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80005758:	3979                	addiw	s2,s2,-2
    8000575a:	4785                	li	a5,1
    8000575c:	0527e063          	bltu	a5,s2,8000579c <fileclose+0xa8>
    begin_op();
    80005760:	00000097          	auipc	ra,0x0
    80005764:	ac8080e7          	jalr	-1336(ra) # 80005228 <begin_op>
    iput(ff.ip);
    80005768:	854e                	mv	a0,s3
    8000576a:	fffff097          	auipc	ra,0xfffff
    8000576e:	2a4080e7          	jalr	676(ra) # 80004a0e <iput>
    end_op();
    80005772:	00000097          	auipc	ra,0x0
    80005776:	b36080e7          	jalr	-1226(ra) # 800052a8 <end_op>
    8000577a:	a00d                	j	8000579c <fileclose+0xa8>
    panic("fileclose");
    8000577c:	00004517          	auipc	a0,0x4
    80005780:	13c50513          	addi	a0,a0,316 # 800098b8 <syscalls+0x280>
    80005784:	ffffb097          	auipc	ra,0xffffb
    80005788:	daa080e7          	jalr	-598(ra) # 8000052e <panic>
    release(&ftable.lock);
    8000578c:	00038517          	auipc	a0,0x38
    80005790:	48450513          	addi	a0,a0,1156 # 8003dc10 <ftable>
    80005794:	ffffb097          	auipc	ra,0xffffb
    80005798:	508080e7          	jalr	1288(ra) # 80000c9c <release>
  }
}
    8000579c:	70e2                	ld	ra,56(sp)
    8000579e:	7442                	ld	s0,48(sp)
    800057a0:	74a2                	ld	s1,40(sp)
    800057a2:	7902                	ld	s2,32(sp)
    800057a4:	69e2                	ld	s3,24(sp)
    800057a6:	6a42                	ld	s4,16(sp)
    800057a8:	6aa2                	ld	s5,8(sp)
    800057aa:	6121                	addi	sp,sp,64
    800057ac:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800057ae:	85d6                	mv	a1,s5
    800057b0:	8552                	mv	a0,s4
    800057b2:	00000097          	auipc	ra,0x0
    800057b6:	34c080e7          	jalr	844(ra) # 80005afe <pipeclose>
    800057ba:	b7cd                	j	8000579c <fileclose+0xa8>

00000000800057bc <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800057bc:	715d                	addi	sp,sp,-80
    800057be:	e486                	sd	ra,72(sp)
    800057c0:	e0a2                	sd	s0,64(sp)
    800057c2:	fc26                	sd	s1,56(sp)
    800057c4:	f84a                	sd	s2,48(sp)
    800057c6:	f44e                	sd	s3,40(sp)
    800057c8:	0880                	addi	s0,sp,80
    800057ca:	84aa                	mv	s1,a0
    800057cc:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800057ce:	ffffc097          	auipc	ra,0xffffc
    800057d2:	2ae080e7          	jalr	686(ra) # 80001a7c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800057d6:	409c                	lw	a5,0(s1)
    800057d8:	37f9                	addiw	a5,a5,-2
    800057da:	4705                	li	a4,1
    800057dc:	04f76763          	bltu	a4,a5,8000582a <filestat+0x6e>
    800057e0:	892a                	mv	s2,a0
    ilock(f->ip);
    800057e2:	6c88                	ld	a0,24(s1)
    800057e4:	fffff097          	auipc	ra,0xfffff
    800057e8:	070080e7          	jalr	112(ra) # 80004854 <ilock>
    stati(f->ip, &st);
    800057ec:	fb840593          	addi	a1,s0,-72
    800057f0:	6c88                	ld	a0,24(s1)
    800057f2:	fffff097          	auipc	ra,0xfffff
    800057f6:	2ec080e7          	jalr	748(ra) # 80004ade <stati>
    iunlock(f->ip);
    800057fa:	6c88                	ld	a0,24(s1)
    800057fc:	fffff097          	auipc	ra,0xfffff
    80005800:	11a080e7          	jalr	282(ra) # 80004916 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005804:	46e1                	li	a3,24
    80005806:	fb840613          	addi	a2,s0,-72
    8000580a:	85ce                	mv	a1,s3
    8000580c:	04093503          	ld	a0,64(s2)
    80005810:	ffffc097          	auipc	ra,0xffffc
    80005814:	e54080e7          	jalr	-428(ra) # 80001664 <copyout>
    80005818:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000581c:	60a6                	ld	ra,72(sp)
    8000581e:	6406                	ld	s0,64(sp)
    80005820:	74e2                	ld	s1,56(sp)
    80005822:	7942                	ld	s2,48(sp)
    80005824:	79a2                	ld	s3,40(sp)
    80005826:	6161                	addi	sp,sp,80
    80005828:	8082                	ret
  return -1;
    8000582a:	557d                	li	a0,-1
    8000582c:	bfc5                	j	8000581c <filestat+0x60>

000000008000582e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000582e:	7179                	addi	sp,sp,-48
    80005830:	f406                	sd	ra,40(sp)
    80005832:	f022                	sd	s0,32(sp)
    80005834:	ec26                	sd	s1,24(sp)
    80005836:	e84a                	sd	s2,16(sp)
    80005838:	e44e                	sd	s3,8(sp)
    8000583a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000583c:	00854783          	lbu	a5,8(a0)
    80005840:	c3d5                	beqz	a5,800058e4 <fileread+0xb6>
    80005842:	84aa                	mv	s1,a0
    80005844:	89ae                	mv	s3,a1
    80005846:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005848:	411c                	lw	a5,0(a0)
    8000584a:	4705                	li	a4,1
    8000584c:	04e78963          	beq	a5,a4,8000589e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005850:	470d                	li	a4,3
    80005852:	04e78d63          	beq	a5,a4,800058ac <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005856:	4709                	li	a4,2
    80005858:	06e79e63          	bne	a5,a4,800058d4 <fileread+0xa6>
    ilock(f->ip);
    8000585c:	6d08                	ld	a0,24(a0)
    8000585e:	fffff097          	auipc	ra,0xfffff
    80005862:	ff6080e7          	jalr	-10(ra) # 80004854 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005866:	874a                	mv	a4,s2
    80005868:	5094                	lw	a3,32(s1)
    8000586a:	864e                	mv	a2,s3
    8000586c:	4585                	li	a1,1
    8000586e:	6c88                	ld	a0,24(s1)
    80005870:	fffff097          	auipc	ra,0xfffff
    80005874:	298080e7          	jalr	664(ra) # 80004b08 <readi>
    80005878:	892a                	mv	s2,a0
    8000587a:	00a05563          	blez	a0,80005884 <fileread+0x56>
      f->off += r;
    8000587e:	509c                	lw	a5,32(s1)
    80005880:	9fa9                	addw	a5,a5,a0
    80005882:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005884:	6c88                	ld	a0,24(s1)
    80005886:	fffff097          	auipc	ra,0xfffff
    8000588a:	090080e7          	jalr	144(ra) # 80004916 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000588e:	854a                	mv	a0,s2
    80005890:	70a2                	ld	ra,40(sp)
    80005892:	7402                	ld	s0,32(sp)
    80005894:	64e2                	ld	s1,24(sp)
    80005896:	6942                	ld	s2,16(sp)
    80005898:	69a2                	ld	s3,8(sp)
    8000589a:	6145                	addi	sp,sp,48
    8000589c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000589e:	6908                	ld	a0,16(a0)
    800058a0:	00000097          	auipc	ra,0x0
    800058a4:	3c8080e7          	jalr	968(ra) # 80005c68 <piperead>
    800058a8:	892a                	mv	s2,a0
    800058aa:	b7d5                	j	8000588e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800058ac:	02451783          	lh	a5,36(a0)
    800058b0:	03079693          	slli	a3,a5,0x30
    800058b4:	92c1                	srli	a3,a3,0x30
    800058b6:	4725                	li	a4,9
    800058b8:	02d76863          	bltu	a4,a3,800058e8 <fileread+0xba>
    800058bc:	0792                	slli	a5,a5,0x4
    800058be:	00038717          	auipc	a4,0x38
    800058c2:	2b270713          	addi	a4,a4,690 # 8003db70 <devsw>
    800058c6:	97ba                	add	a5,a5,a4
    800058c8:	639c                	ld	a5,0(a5)
    800058ca:	c38d                	beqz	a5,800058ec <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800058cc:	4505                	li	a0,1
    800058ce:	9782                	jalr	a5
    800058d0:	892a                	mv	s2,a0
    800058d2:	bf75                	j	8000588e <fileread+0x60>
    panic("fileread");
    800058d4:	00004517          	auipc	a0,0x4
    800058d8:	ff450513          	addi	a0,a0,-12 # 800098c8 <syscalls+0x290>
    800058dc:	ffffb097          	auipc	ra,0xffffb
    800058e0:	c52080e7          	jalr	-942(ra) # 8000052e <panic>
    return -1;
    800058e4:	597d                	li	s2,-1
    800058e6:	b765                	j	8000588e <fileread+0x60>
      return -1;
    800058e8:	597d                	li	s2,-1
    800058ea:	b755                	j	8000588e <fileread+0x60>
    800058ec:	597d                	li	s2,-1
    800058ee:	b745                	j	8000588e <fileread+0x60>

00000000800058f0 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800058f0:	715d                	addi	sp,sp,-80
    800058f2:	e486                	sd	ra,72(sp)
    800058f4:	e0a2                	sd	s0,64(sp)
    800058f6:	fc26                	sd	s1,56(sp)
    800058f8:	f84a                	sd	s2,48(sp)
    800058fa:	f44e                	sd	s3,40(sp)
    800058fc:	f052                	sd	s4,32(sp)
    800058fe:	ec56                	sd	s5,24(sp)
    80005900:	e85a                	sd	s6,16(sp)
    80005902:	e45e                	sd	s7,8(sp)
    80005904:	e062                	sd	s8,0(sp)
    80005906:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005908:	00954783          	lbu	a5,9(a0)
    8000590c:	10078663          	beqz	a5,80005a18 <filewrite+0x128>
    80005910:	892a                	mv	s2,a0
    80005912:	8aae                	mv	s5,a1
    80005914:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005916:	411c                	lw	a5,0(a0)
    80005918:	4705                	li	a4,1
    8000591a:	02e78263          	beq	a5,a4,8000593e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000591e:	470d                	li	a4,3
    80005920:	02e78663          	beq	a5,a4,8000594c <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005924:	4709                	li	a4,2
    80005926:	0ee79163          	bne	a5,a4,80005a08 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000592a:	0ac05d63          	blez	a2,800059e4 <filewrite+0xf4>
    int i = 0;
    8000592e:	4981                	li	s3,0
    80005930:	6b05                	lui	s6,0x1
    80005932:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005936:	6b85                	lui	s7,0x1
    80005938:	c00b8b9b          	addiw	s7,s7,-1024
    8000593c:	a861                	j	800059d4 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000593e:	6908                	ld	a0,16(a0)
    80005940:	00000097          	auipc	ra,0x0
    80005944:	22e080e7          	jalr	558(ra) # 80005b6e <pipewrite>
    80005948:	8a2a                	mv	s4,a0
    8000594a:	a045                	j	800059ea <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000594c:	02451783          	lh	a5,36(a0)
    80005950:	03079693          	slli	a3,a5,0x30
    80005954:	92c1                	srli	a3,a3,0x30
    80005956:	4725                	li	a4,9
    80005958:	0cd76263          	bltu	a4,a3,80005a1c <filewrite+0x12c>
    8000595c:	0792                	slli	a5,a5,0x4
    8000595e:	00038717          	auipc	a4,0x38
    80005962:	21270713          	addi	a4,a4,530 # 8003db70 <devsw>
    80005966:	97ba                	add	a5,a5,a4
    80005968:	679c                	ld	a5,8(a5)
    8000596a:	cbdd                	beqz	a5,80005a20 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    8000596c:	4505                	li	a0,1
    8000596e:	9782                	jalr	a5
    80005970:	8a2a                	mv	s4,a0
    80005972:	a8a5                	j	800059ea <filewrite+0xfa>
    80005974:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005978:	00000097          	auipc	ra,0x0
    8000597c:	8b0080e7          	jalr	-1872(ra) # 80005228 <begin_op>
      ilock(f->ip);
    80005980:	01893503          	ld	a0,24(s2)
    80005984:	fffff097          	auipc	ra,0xfffff
    80005988:	ed0080e7          	jalr	-304(ra) # 80004854 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000598c:	8762                	mv	a4,s8
    8000598e:	02092683          	lw	a3,32(s2)
    80005992:	01598633          	add	a2,s3,s5
    80005996:	4585                	li	a1,1
    80005998:	01893503          	ld	a0,24(s2)
    8000599c:	fffff097          	auipc	ra,0xfffff
    800059a0:	264080e7          	jalr	612(ra) # 80004c00 <writei>
    800059a4:	84aa                	mv	s1,a0
    800059a6:	00a05763          	blez	a0,800059b4 <filewrite+0xc4>
        f->off += r;
    800059aa:	02092783          	lw	a5,32(s2)
    800059ae:	9fa9                	addw	a5,a5,a0
    800059b0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800059b4:	01893503          	ld	a0,24(s2)
    800059b8:	fffff097          	auipc	ra,0xfffff
    800059bc:	f5e080e7          	jalr	-162(ra) # 80004916 <iunlock>
      end_op();
    800059c0:	00000097          	auipc	ra,0x0
    800059c4:	8e8080e7          	jalr	-1816(ra) # 800052a8 <end_op>

      if(r != n1){
    800059c8:	009c1f63          	bne	s8,s1,800059e6 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800059cc:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800059d0:	0149db63          	bge	s3,s4,800059e6 <filewrite+0xf6>
      int n1 = n - i;
    800059d4:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800059d8:	84be                	mv	s1,a5
    800059da:	2781                	sext.w	a5,a5
    800059dc:	f8fb5ce3          	bge	s6,a5,80005974 <filewrite+0x84>
    800059e0:	84de                	mv	s1,s7
    800059e2:	bf49                	j	80005974 <filewrite+0x84>
    int i = 0;
    800059e4:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800059e6:	013a1f63          	bne	s4,s3,80005a04 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800059ea:	8552                	mv	a0,s4
    800059ec:	60a6                	ld	ra,72(sp)
    800059ee:	6406                	ld	s0,64(sp)
    800059f0:	74e2                	ld	s1,56(sp)
    800059f2:	7942                	ld	s2,48(sp)
    800059f4:	79a2                	ld	s3,40(sp)
    800059f6:	7a02                	ld	s4,32(sp)
    800059f8:	6ae2                	ld	s5,24(sp)
    800059fa:	6b42                	ld	s6,16(sp)
    800059fc:	6ba2                	ld	s7,8(sp)
    800059fe:	6c02                	ld	s8,0(sp)
    80005a00:	6161                	addi	sp,sp,80
    80005a02:	8082                	ret
    ret = (i == n ? n : -1);
    80005a04:	5a7d                	li	s4,-1
    80005a06:	b7d5                	j	800059ea <filewrite+0xfa>
    panic("filewrite");
    80005a08:	00004517          	auipc	a0,0x4
    80005a0c:	ed050513          	addi	a0,a0,-304 # 800098d8 <syscalls+0x2a0>
    80005a10:	ffffb097          	auipc	ra,0xffffb
    80005a14:	b1e080e7          	jalr	-1250(ra) # 8000052e <panic>
    return -1;
    80005a18:	5a7d                	li	s4,-1
    80005a1a:	bfc1                	j	800059ea <filewrite+0xfa>
      return -1;
    80005a1c:	5a7d                	li	s4,-1
    80005a1e:	b7f1                	j	800059ea <filewrite+0xfa>
    80005a20:	5a7d                	li	s4,-1
    80005a22:	b7e1                	j	800059ea <filewrite+0xfa>

0000000080005a24 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005a24:	7179                	addi	sp,sp,-48
    80005a26:	f406                	sd	ra,40(sp)
    80005a28:	f022                	sd	s0,32(sp)
    80005a2a:	ec26                	sd	s1,24(sp)
    80005a2c:	e84a                	sd	s2,16(sp)
    80005a2e:	e44e                	sd	s3,8(sp)
    80005a30:	e052                	sd	s4,0(sp)
    80005a32:	1800                	addi	s0,sp,48
    80005a34:	84aa                	mv	s1,a0
    80005a36:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005a38:	0005b023          	sd	zero,0(a1)
    80005a3c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005a40:	00000097          	auipc	ra,0x0
    80005a44:	bf8080e7          	jalr	-1032(ra) # 80005638 <filealloc>
    80005a48:	e088                	sd	a0,0(s1)
    80005a4a:	c551                	beqz	a0,80005ad6 <pipealloc+0xb2>
    80005a4c:	00000097          	auipc	ra,0x0
    80005a50:	bec080e7          	jalr	-1044(ra) # 80005638 <filealloc>
    80005a54:	00aa3023          	sd	a0,0(s4)
    80005a58:	c92d                	beqz	a0,80005aca <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005a5a:	ffffb097          	auipc	ra,0xffffb
    80005a5e:	07c080e7          	jalr	124(ra) # 80000ad6 <kalloc>
    80005a62:	892a                	mv	s2,a0
    80005a64:	c125                	beqz	a0,80005ac4 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005a66:	4985                	li	s3,1
    80005a68:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005a6c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005a70:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005a74:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005a78:	00004597          	auipc	a1,0x4
    80005a7c:	e7058593          	addi	a1,a1,-400 # 800098e8 <syscalls+0x2b0>
    80005a80:	ffffb097          	auipc	ra,0xffffb
    80005a84:	0b6080e7          	jalr	182(ra) # 80000b36 <initlock>
  (*f0)->type = FD_PIPE;
    80005a88:	609c                	ld	a5,0(s1)
    80005a8a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005a8e:	609c                	ld	a5,0(s1)
    80005a90:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005a94:	609c                	ld	a5,0(s1)
    80005a96:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005a9a:	609c                	ld	a5,0(s1)
    80005a9c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005aa0:	000a3783          	ld	a5,0(s4)
    80005aa4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005aa8:	000a3783          	ld	a5,0(s4)
    80005aac:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005ab0:	000a3783          	ld	a5,0(s4)
    80005ab4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005ab8:	000a3783          	ld	a5,0(s4)
    80005abc:	0127b823          	sd	s2,16(a5)
  return 0;
    80005ac0:	4501                	li	a0,0
    80005ac2:	a025                	j	80005aea <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005ac4:	6088                	ld	a0,0(s1)
    80005ac6:	e501                	bnez	a0,80005ace <pipealloc+0xaa>
    80005ac8:	a039                	j	80005ad6 <pipealloc+0xb2>
    80005aca:	6088                	ld	a0,0(s1)
    80005acc:	c51d                	beqz	a0,80005afa <pipealloc+0xd6>
    fileclose(*f0);
    80005ace:	00000097          	auipc	ra,0x0
    80005ad2:	c26080e7          	jalr	-986(ra) # 800056f4 <fileclose>
  if(*f1)
    80005ad6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005ada:	557d                	li	a0,-1
  if(*f1)
    80005adc:	c799                	beqz	a5,80005aea <pipealloc+0xc6>
    fileclose(*f1);
    80005ade:	853e                	mv	a0,a5
    80005ae0:	00000097          	auipc	ra,0x0
    80005ae4:	c14080e7          	jalr	-1004(ra) # 800056f4 <fileclose>
  return -1;
    80005ae8:	557d                	li	a0,-1
}
    80005aea:	70a2                	ld	ra,40(sp)
    80005aec:	7402                	ld	s0,32(sp)
    80005aee:	64e2                	ld	s1,24(sp)
    80005af0:	6942                	ld	s2,16(sp)
    80005af2:	69a2                	ld	s3,8(sp)
    80005af4:	6a02                	ld	s4,0(sp)
    80005af6:	6145                	addi	sp,sp,48
    80005af8:	8082                	ret
  return -1;
    80005afa:	557d                	li	a0,-1
    80005afc:	b7fd                	j	80005aea <pipealloc+0xc6>

0000000080005afe <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005afe:	1101                	addi	sp,sp,-32
    80005b00:	ec06                	sd	ra,24(sp)
    80005b02:	e822                	sd	s0,16(sp)
    80005b04:	e426                	sd	s1,8(sp)
    80005b06:	e04a                	sd	s2,0(sp)
    80005b08:	1000                	addi	s0,sp,32
    80005b0a:	84aa                	mv	s1,a0
    80005b0c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005b0e:	ffffb097          	auipc	ra,0xffffb
    80005b12:	0b8080e7          	jalr	184(ra) # 80000bc6 <acquire>
  if(writable){
    80005b16:	02090d63          	beqz	s2,80005b50 <pipeclose+0x52>
    pi->writeopen = 0;
    80005b1a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005b1e:	21848513          	addi	a0,s1,536
    80005b22:	ffffd097          	auipc	ra,0xffffd
    80005b26:	aba080e7          	jalr	-1350(ra) # 800025dc <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005b2a:	2204b783          	ld	a5,544(s1)
    80005b2e:	eb95                	bnez	a5,80005b62 <pipeclose+0x64>
    release(&pi->lock);
    80005b30:	8526                	mv	a0,s1
    80005b32:	ffffb097          	auipc	ra,0xffffb
    80005b36:	16a080e7          	jalr	362(ra) # 80000c9c <release>
    kfree((char*)pi);
    80005b3a:	8526                	mv	a0,s1
    80005b3c:	ffffb097          	auipc	ra,0xffffb
    80005b40:	e9e080e7          	jalr	-354(ra) # 800009da <kfree>
  } else
    release(&pi->lock);
}
    80005b44:	60e2                	ld	ra,24(sp)
    80005b46:	6442                	ld	s0,16(sp)
    80005b48:	64a2                	ld	s1,8(sp)
    80005b4a:	6902                	ld	s2,0(sp)
    80005b4c:	6105                	addi	sp,sp,32
    80005b4e:	8082                	ret
    pi->readopen = 0;
    80005b50:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005b54:	21c48513          	addi	a0,s1,540
    80005b58:	ffffd097          	auipc	ra,0xffffd
    80005b5c:	a84080e7          	jalr	-1404(ra) # 800025dc <wakeup>
    80005b60:	b7e9                	j	80005b2a <pipeclose+0x2c>
    release(&pi->lock);
    80005b62:	8526                	mv	a0,s1
    80005b64:	ffffb097          	auipc	ra,0xffffb
    80005b68:	138080e7          	jalr	312(ra) # 80000c9c <release>
}
    80005b6c:	bfe1                	j	80005b44 <pipeclose+0x46>

0000000080005b6e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005b6e:	7159                	addi	sp,sp,-112
    80005b70:	f486                	sd	ra,104(sp)
    80005b72:	f0a2                	sd	s0,96(sp)
    80005b74:	eca6                	sd	s1,88(sp)
    80005b76:	e8ca                	sd	s2,80(sp)
    80005b78:	e4ce                	sd	s3,72(sp)
    80005b7a:	e0d2                	sd	s4,64(sp)
    80005b7c:	fc56                	sd	s5,56(sp)
    80005b7e:	f85a                	sd	s6,48(sp)
    80005b80:	f45e                	sd	s7,40(sp)
    80005b82:	f062                	sd	s8,32(sp)
    80005b84:	ec66                	sd	s9,24(sp)
    80005b86:	1880                	addi	s0,sp,112
    80005b88:	84aa                	mv	s1,a0
    80005b8a:	8b2e                	mv	s6,a1
    80005b8c:	8ab2                	mv	s5,a2
  int i = 0;
  struct proc *pr = myproc();
    80005b8e:	ffffc097          	auipc	ra,0xffffc
    80005b92:	eee080e7          	jalr	-274(ra) # 80001a7c <myproc>
    80005b96:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005b98:	8526                	mv	a0,s1
    80005b9a:	ffffb097          	auipc	ra,0xffffb
    80005b9e:	02c080e7          	jalr	44(ra) # 80000bc6 <acquire>
  while(i < n){
    80005ba2:	0b505663          	blez	s5,80005c4e <pipewrite+0xe0>
  int i = 0;
    80005ba6:	4901                	li	s2,0
    if(pi->readopen == 0 || pr->killed==1){
    80005ba8:	4a05                	li	s4,1
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005baa:	5bfd                	li	s7,-1
      wakeup(&pi->nread);
    80005bac:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005bb0:	21c48c13          	addi	s8,s1,540
    80005bb4:	a091                	j	80005bf8 <pipewrite+0x8a>
      release(&pi->lock);
    80005bb6:	8526                	mv	a0,s1
    80005bb8:	ffffb097          	auipc	ra,0xffffb
    80005bbc:	0e4080e7          	jalr	228(ra) # 80000c9c <release>
      return -1;
    80005bc0:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005bc2:	854a                	mv	a0,s2
    80005bc4:	70a6                	ld	ra,104(sp)
    80005bc6:	7406                	ld	s0,96(sp)
    80005bc8:	64e6                	ld	s1,88(sp)
    80005bca:	6946                	ld	s2,80(sp)
    80005bcc:	69a6                	ld	s3,72(sp)
    80005bce:	6a06                	ld	s4,64(sp)
    80005bd0:	7ae2                	ld	s5,56(sp)
    80005bd2:	7b42                	ld	s6,48(sp)
    80005bd4:	7ba2                	ld	s7,40(sp)
    80005bd6:	7c02                	ld	s8,32(sp)
    80005bd8:	6ce2                	ld	s9,24(sp)
    80005bda:	6165                	addi	sp,sp,112
    80005bdc:	8082                	ret
      wakeup(&pi->nread);
    80005bde:	8566                	mv	a0,s9
    80005be0:	ffffd097          	auipc	ra,0xffffd
    80005be4:	9fc080e7          	jalr	-1540(ra) # 800025dc <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005be8:	85a6                	mv	a1,s1
    80005bea:	8562                	mv	a0,s8
    80005bec:	ffffd097          	auipc	ra,0xffffd
    80005bf0:	85c080e7          	jalr	-1956(ra) # 80002448 <sleep>
  while(i < n){
    80005bf4:	05595e63          	bge	s2,s5,80005c50 <pipewrite+0xe2>
    if(pi->readopen == 0 || pr->killed==1){
    80005bf8:	2204a783          	lw	a5,544(s1)
    80005bfc:	dfcd                	beqz	a5,80005bb6 <pipewrite+0x48>
    80005bfe:	01c9a783          	lw	a5,28(s3)
    80005c02:	fb478ae3          	beq	a5,s4,80005bb6 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005c06:	2184a783          	lw	a5,536(s1)
    80005c0a:	21c4a703          	lw	a4,540(s1)
    80005c0e:	2007879b          	addiw	a5,a5,512
    80005c12:	fcf706e3          	beq	a4,a5,80005bde <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005c16:	86d2                	mv	a3,s4
    80005c18:	01690633          	add	a2,s2,s6
    80005c1c:	f9f40593          	addi	a1,s0,-97
    80005c20:	0409b503          	ld	a0,64(s3)
    80005c24:	ffffc097          	auipc	ra,0xffffc
    80005c28:	acc080e7          	jalr	-1332(ra) # 800016f0 <copyin>
    80005c2c:	03750263          	beq	a0,s7,80005c50 <pipewrite+0xe2>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005c30:	21c4a783          	lw	a5,540(s1)
    80005c34:	0017871b          	addiw	a4,a5,1
    80005c38:	20e4ae23          	sw	a4,540(s1)
    80005c3c:	1ff7f793          	andi	a5,a5,511
    80005c40:	97a6                	add	a5,a5,s1
    80005c42:	f9f44703          	lbu	a4,-97(s0)
    80005c46:	00e78c23          	sb	a4,24(a5)
      i++;
    80005c4a:	2905                	addiw	s2,s2,1
    80005c4c:	b765                	j	80005bf4 <pipewrite+0x86>
  int i = 0;
    80005c4e:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005c50:	21848513          	addi	a0,s1,536
    80005c54:	ffffd097          	auipc	ra,0xffffd
    80005c58:	988080e7          	jalr	-1656(ra) # 800025dc <wakeup>
  release(&pi->lock);
    80005c5c:	8526                	mv	a0,s1
    80005c5e:	ffffb097          	auipc	ra,0xffffb
    80005c62:	03e080e7          	jalr	62(ra) # 80000c9c <release>
  return i;
    80005c66:	bfb1                	j	80005bc2 <pipewrite+0x54>

0000000080005c68 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005c68:	715d                	addi	sp,sp,-80
    80005c6a:	e486                	sd	ra,72(sp)
    80005c6c:	e0a2                	sd	s0,64(sp)
    80005c6e:	fc26                	sd	s1,56(sp)
    80005c70:	f84a                	sd	s2,48(sp)
    80005c72:	f44e                	sd	s3,40(sp)
    80005c74:	f052                	sd	s4,32(sp)
    80005c76:	ec56                	sd	s5,24(sp)
    80005c78:	e85a                	sd	s6,16(sp)
    80005c7a:	0880                	addi	s0,sp,80
    80005c7c:	84aa                	mv	s1,a0
    80005c7e:	892e                	mv	s2,a1
    80005c80:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005c82:	ffffc097          	auipc	ra,0xffffc
    80005c86:	dfa080e7          	jalr	-518(ra) # 80001a7c <myproc>
    80005c8a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005c8c:	8526                	mv	a0,s1
    80005c8e:	ffffb097          	auipc	ra,0xffffb
    80005c92:	f38080e7          	jalr	-200(ra) # 80000bc6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005c96:	2184a703          	lw	a4,536(s1)
    80005c9a:	21c4a783          	lw	a5,540(s1)
    if(pr->killed==1){
    80005c9e:	4985                	li	s3,1
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005ca0:	21848b13          	addi	s6,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005ca4:	02f71563          	bne	a4,a5,80005cce <piperead+0x66>
    80005ca8:	2244a783          	lw	a5,548(s1)
    80005cac:	c38d                	beqz	a5,80005cce <piperead+0x66>
    if(pr->killed==1){
    80005cae:	01ca2783          	lw	a5,28(s4)
    80005cb2:	09378963          	beq	a5,s3,80005d44 <piperead+0xdc>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005cb6:	85a6                	mv	a1,s1
    80005cb8:	855a                	mv	a0,s6
    80005cba:	ffffc097          	auipc	ra,0xffffc
    80005cbe:	78e080e7          	jalr	1934(ra) # 80002448 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005cc2:	2184a703          	lw	a4,536(s1)
    80005cc6:	21c4a783          	lw	a5,540(s1)
    80005cca:	fcf70fe3          	beq	a4,a5,80005ca8 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005cce:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005cd0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005cd2:	05505363          	blez	s5,80005d18 <piperead+0xb0>
    if(pi->nread == pi->nwrite)
    80005cd6:	2184a783          	lw	a5,536(s1)
    80005cda:	21c4a703          	lw	a4,540(s1)
    80005cde:	02f70d63          	beq	a4,a5,80005d18 <piperead+0xb0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005ce2:	0017871b          	addiw	a4,a5,1
    80005ce6:	20e4ac23          	sw	a4,536(s1)
    80005cea:	1ff7f793          	andi	a5,a5,511
    80005cee:	97a6                	add	a5,a5,s1
    80005cf0:	0187c783          	lbu	a5,24(a5)
    80005cf4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005cf8:	4685                	li	a3,1
    80005cfa:	fbf40613          	addi	a2,s0,-65
    80005cfe:	85ca                	mv	a1,s2
    80005d00:	040a3503          	ld	a0,64(s4)
    80005d04:	ffffc097          	auipc	ra,0xffffc
    80005d08:	960080e7          	jalr	-1696(ra) # 80001664 <copyout>
    80005d0c:	01650663          	beq	a0,s6,80005d18 <piperead+0xb0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005d10:	2985                	addiw	s3,s3,1
    80005d12:	0905                	addi	s2,s2,1
    80005d14:	fd3a91e3          	bne	s5,s3,80005cd6 <piperead+0x6e>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005d18:	21c48513          	addi	a0,s1,540
    80005d1c:	ffffd097          	auipc	ra,0xffffd
    80005d20:	8c0080e7          	jalr	-1856(ra) # 800025dc <wakeup>
  release(&pi->lock);
    80005d24:	8526                	mv	a0,s1
    80005d26:	ffffb097          	auipc	ra,0xffffb
    80005d2a:	f76080e7          	jalr	-138(ra) # 80000c9c <release>
  return i;
}
    80005d2e:	854e                	mv	a0,s3
    80005d30:	60a6                	ld	ra,72(sp)
    80005d32:	6406                	ld	s0,64(sp)
    80005d34:	74e2                	ld	s1,56(sp)
    80005d36:	7942                	ld	s2,48(sp)
    80005d38:	79a2                	ld	s3,40(sp)
    80005d3a:	7a02                	ld	s4,32(sp)
    80005d3c:	6ae2                	ld	s5,24(sp)
    80005d3e:	6b42                	ld	s6,16(sp)
    80005d40:	6161                	addi	sp,sp,80
    80005d42:	8082                	ret
      release(&pi->lock);
    80005d44:	8526                	mv	a0,s1
    80005d46:	ffffb097          	auipc	ra,0xffffb
    80005d4a:	f56080e7          	jalr	-170(ra) # 80000c9c <release>
      return -1;
    80005d4e:	59fd                	li	s3,-1
    80005d50:	bff9                	j	80005d2e <piperead+0xc6>

0000000080005d52 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005d52:	dd010113          	addi	sp,sp,-560
    80005d56:	22113423          	sd	ra,552(sp)
    80005d5a:	22813023          	sd	s0,544(sp)
    80005d5e:	20913c23          	sd	s1,536(sp)
    80005d62:	21213823          	sd	s2,528(sp)
    80005d66:	21313423          	sd	s3,520(sp)
    80005d6a:	21413023          	sd	s4,512(sp)
    80005d6e:	ffd6                	sd	s5,504(sp)
    80005d70:	fbda                	sd	s6,496(sp)
    80005d72:	f7de                	sd	s7,488(sp)
    80005d74:	f3e2                	sd	s8,480(sp)
    80005d76:	efe6                	sd	s9,472(sp)
    80005d78:	ebea                	sd	s10,464(sp)
    80005d7a:	e7ee                	sd	s11,456(sp)
    80005d7c:	1c00                	addi	s0,sp,560
    80005d7e:	dea43823          	sd	a0,-528(s0)
    80005d82:	deb43023          	sd	a1,-544(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005d86:	ffffc097          	auipc	ra,0xffffc
    80005d8a:	cf6080e7          	jalr	-778(ra) # 80001a7c <myproc>
    80005d8e:	89aa                	mv	s3,a0

  struct kthread *t = mykthread();
    80005d90:	ffffc097          	auipc	ra,0xffffc
    80005d94:	d2c080e7          	jalr	-724(ra) # 80001abc <mykthread>
    80005d98:	8b2a                	mv	s6,a0
  struct kthread *nt;


  // Kill all process threads 
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){ 
    80005d9a:	28898493          	addi	s1,s3,648
    80005d9e:	6905                	lui	s2,0x1
    80005da0:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80005da4:	994e                	add	s2,s2,s3
    if(nt!=t && nt->state!=TUNUSED){
      acquire(&nt->lock);
      nt->killed=1;
    80005da6:	4a85                	li	s5,1
      if(nt->state == TSLEEPING){
    80005da8:	4a09                	li	s4,2
        nt->state = TRUNNABLE;
    80005daa:	4b8d                	li	s7,3
    80005dac:	a811                	j	80005dc0 <exec+0x6e>
      }
      release(&nt->lock);  
    80005dae:	8526                	mv	a0,s1
    80005db0:	ffffb097          	auipc	ra,0xffffb
    80005db4:	eec080e7          	jalr	-276(ra) # 80000c9c <release>
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){ 
    80005db8:	0b848493          	addi	s1,s1,184
    80005dbc:	03248363          	beq	s1,s2,80005de2 <exec+0x90>
    if(nt!=t && nt->state!=TUNUSED){
    80005dc0:	fe9b0ce3          	beq	s6,s1,80005db8 <exec+0x66>
    80005dc4:	4c9c                	lw	a5,24(s1)
    80005dc6:	dbed                	beqz	a5,80005db8 <exec+0x66>
      acquire(&nt->lock);
    80005dc8:	8526                	mv	a0,s1
    80005dca:	ffffb097          	auipc	ra,0xffffb
    80005dce:	dfc080e7          	jalr	-516(ra) # 80000bc6 <acquire>
      nt->killed=1;
    80005dd2:	0354a423          	sw	s5,40(s1)
      if(nt->state == TSLEEPING){
    80005dd6:	4c9c                	lw	a5,24(s1)
    80005dd8:	fd479be3          	bne	a5,s4,80005dae <exec+0x5c>
        nt->state = TRUNNABLE;
    80005ddc:	0174ac23          	sw	s7,24(s1)
    80005de0:	b7f9                	j	80005dae <exec+0x5c>
    }
  }

  // Wait for all threads to terminate
  kthread_join_all();
    80005de2:	ffffd097          	auipc	ra,0xffffd
    80005de6:	364080e7          	jalr	868(ra) # 80003146 <kthread_join_all>
    
  begin_op();
    80005dea:	fffff097          	auipc	ra,0xfffff
    80005dee:	43e080e7          	jalr	1086(ra) # 80005228 <begin_op>

  if((ip = namei(path)) == 0){
    80005df2:	df043503          	ld	a0,-528(s0)
    80005df6:	fffff097          	auipc	ra,0xfffff
    80005dfa:	212080e7          	jalr	530(ra) # 80005008 <namei>
    80005dfe:	8aaa                	mv	s5,a0
    80005e00:	cd25                	beqz	a0,80005e78 <exec+0x126>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e02:	fffff097          	auipc	ra,0xfffff
    80005e06:	a52080e7          	jalr	-1454(ra) # 80004854 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005e0a:	04000713          	li	a4,64
    80005e0e:	4681                	li	a3,0
    80005e10:	e4840613          	addi	a2,s0,-440
    80005e14:	4581                	li	a1,0
    80005e16:	8556                	mv	a0,s5
    80005e18:	fffff097          	auipc	ra,0xfffff
    80005e1c:	cf0080e7          	jalr	-784(ra) # 80004b08 <readi>
    80005e20:	04000793          	li	a5,64
    80005e24:	00f51a63          	bne	a0,a5,80005e38 <exec+0xe6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005e28:	e4842703          	lw	a4,-440(s0)
    80005e2c:	464c47b7          	lui	a5,0x464c4
    80005e30:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005e34:	04f70863          	beq	a4,a5,80005e84 <exec+0x132>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005e38:	8556                	mv	a0,s5
    80005e3a:	fffff097          	auipc	ra,0xfffff
    80005e3e:	c7c080e7          	jalr	-900(ra) # 80004ab6 <iunlockput>
    end_op();
    80005e42:	fffff097          	auipc	ra,0xfffff
    80005e46:	466080e7          	jalr	1126(ra) # 800052a8 <end_op>
  }
  return -1;
    80005e4a:	557d                	li	a0,-1
}
    80005e4c:	22813083          	ld	ra,552(sp)
    80005e50:	22013403          	ld	s0,544(sp)
    80005e54:	21813483          	ld	s1,536(sp)
    80005e58:	21013903          	ld	s2,528(sp)
    80005e5c:	20813983          	ld	s3,520(sp)
    80005e60:	20013a03          	ld	s4,512(sp)
    80005e64:	7afe                	ld	s5,504(sp)
    80005e66:	7b5e                	ld	s6,496(sp)
    80005e68:	7bbe                	ld	s7,488(sp)
    80005e6a:	7c1e                	ld	s8,480(sp)
    80005e6c:	6cfe                	ld	s9,472(sp)
    80005e6e:	6d5e                	ld	s10,464(sp)
    80005e70:	6dbe                	ld	s11,456(sp)
    80005e72:	23010113          	addi	sp,sp,560
    80005e76:	8082                	ret
    end_op();
    80005e78:	fffff097          	auipc	ra,0xfffff
    80005e7c:	430080e7          	jalr	1072(ra) # 800052a8 <end_op>
    return -1;
    80005e80:	557d                	li	a0,-1
    80005e82:	b7e9                	j	80005e4c <exec+0xfa>
  if((pagetable = proc_pagetable(p)) == 0)
    80005e84:	854e                	mv	a0,s3
    80005e86:	ffffc097          	auipc	ra,0xffffc
    80005e8a:	d92080e7          	jalr	-622(ra) # 80001c18 <proc_pagetable>
    80005e8e:	e0a43423          	sd	a0,-504(s0)
    80005e92:	d15d                	beqz	a0,80005e38 <exec+0xe6>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005e94:	e6842783          	lw	a5,-408(s0)
    80005e98:	e8045703          	lhu	a4,-384(s0)
    80005e9c:	c73d                	beqz	a4,80005f0a <exec+0x1b8>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005e9e:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005ea0:	e0043023          	sd	zero,-512(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005ea4:	6a05                	lui	s4,0x1
    80005ea6:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005eaa:	dce43c23          	sd	a4,-552(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005eae:	6d85                	lui	s11,0x1
    80005eb0:	7d7d                	lui	s10,0xfffff
    80005eb2:	a4b5                	j	8000611e <exec+0x3cc>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005eb4:	00004517          	auipc	a0,0x4
    80005eb8:	a3c50513          	addi	a0,a0,-1476 # 800098f0 <syscalls+0x2b8>
    80005ebc:	ffffa097          	auipc	ra,0xffffa
    80005ec0:	672080e7          	jalr	1650(ra) # 8000052e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005ec4:	874a                	mv	a4,s2
    80005ec6:	009c86bb          	addw	a3,s9,s1
    80005eca:	4581                	li	a1,0
    80005ecc:	8556                	mv	a0,s5
    80005ece:	fffff097          	auipc	ra,0xfffff
    80005ed2:	c3a080e7          	jalr	-966(ra) # 80004b08 <readi>
    80005ed6:	2501                	sext.w	a0,a0
    80005ed8:	1ea91263          	bne	s2,a0,800060bc <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80005edc:	009d84bb          	addw	s1,s11,s1
    80005ee0:	013d09bb          	addw	s3,s10,s3
    80005ee4:	2174fd63          	bgeu	s1,s7,800060fe <exec+0x3ac>
    pa = walkaddr(pagetable, va + i);
    80005ee8:	02049593          	slli	a1,s1,0x20
    80005eec:	9181                	srli	a1,a1,0x20
    80005eee:	95e2                	add	a1,a1,s8
    80005ef0:	e0843503          	ld	a0,-504(s0)
    80005ef4:	ffffb097          	auipc	ra,0xffffb
    80005ef8:	17e080e7          	jalr	382(ra) # 80001072 <walkaddr>
    80005efc:	862a                	mv	a2,a0
    if(pa == 0)
    80005efe:	d95d                	beqz	a0,80005eb4 <exec+0x162>
      n = PGSIZE;
    80005f00:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005f02:	fd49f1e3          	bgeu	s3,s4,80005ec4 <exec+0x172>
      n = sz - i;
    80005f06:	894e                	mv	s2,s3
    80005f08:	bf75                	j	80005ec4 <exec+0x172>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005f0a:	4481                	li	s1,0
  iunlockput(ip);
    80005f0c:	8556                	mv	a0,s5
    80005f0e:	fffff097          	auipc	ra,0xfffff
    80005f12:	ba8080e7          	jalr	-1112(ra) # 80004ab6 <iunlockput>
  end_op();
    80005f16:	fffff097          	auipc	ra,0xfffff
    80005f1a:	392080e7          	jalr	914(ra) # 800052a8 <end_op>
  p = myproc();
    80005f1e:	ffffc097          	auipc	ra,0xffffc
    80005f22:	b5e080e7          	jalr	-1186(ra) # 80001a7c <myproc>
    80005f26:	8a2a                	mv	s4,a0
  uint64 oldsz = p->sz;
    80005f28:	03853d03          	ld	s10,56(a0)
  sz = PGROUNDUP(sz);
    80005f2c:	6785                	lui	a5,0x1
    80005f2e:	17fd                	addi	a5,a5,-1
    80005f30:	94be                	add	s1,s1,a5
    80005f32:	77fd                	lui	a5,0xfffff
    80005f34:	8fe5                	and	a5,a5,s1
    80005f36:	def43423          	sd	a5,-536(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005f3a:	6609                	lui	a2,0x2
    80005f3c:	963e                	add	a2,a2,a5
    80005f3e:	85be                	mv	a1,a5
    80005f40:	e0843483          	ld	s1,-504(s0)
    80005f44:	8526                	mv	a0,s1
    80005f46:	ffffb097          	auipc	ra,0xffffb
    80005f4a:	4ce080e7          	jalr	1230(ra) # 80001414 <uvmalloc>
    80005f4e:	8caa                	mv	s9,a0
  ip = 0;
    80005f50:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005f52:	16050563          	beqz	a0,800060bc <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005f56:	75f9                	lui	a1,0xffffe
    80005f58:	95aa                	add	a1,a1,a0
    80005f5a:	8526                	mv	a0,s1
    80005f5c:	ffffb097          	auipc	ra,0xffffb
    80005f60:	6d6080e7          	jalr	1750(ra) # 80001632 <uvmclear>
  stackbase = sp - PGSIZE;
    80005f64:	7bfd                	lui	s7,0xfffff
    80005f66:	9be6                	add	s7,s7,s9
  for(argc = 0; argv[argc]; argc++) {
    80005f68:	de043783          	ld	a5,-544(s0)
    80005f6c:	6388                	ld	a0,0(a5)
    80005f6e:	c92d                	beqz	a0,80005fe0 <exec+0x28e>
    80005f70:	e8840993          	addi	s3,s0,-376
    80005f74:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80005f78:	8966                	mv	s2,s9
  for(argc = 0; argv[argc]; argc++) {
    80005f7a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005f7c:	ffffb097          	auipc	ra,0xffffb
    80005f80:	eec080e7          	jalr	-276(ra) # 80000e68 <strlen>
    80005f84:	0015079b          	addiw	a5,a0,1
    80005f88:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005f8c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005f90:	15796b63          	bltu	s2,s7,800060e6 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005f94:	de043d83          	ld	s11,-544(s0)
    80005f98:	000dba83          	ld	s5,0(s11) # 1000 <_entry-0x7ffff000>
    80005f9c:	8556                	mv	a0,s5
    80005f9e:	ffffb097          	auipc	ra,0xffffb
    80005fa2:	eca080e7          	jalr	-310(ra) # 80000e68 <strlen>
    80005fa6:	0015069b          	addiw	a3,a0,1
    80005faa:	8656                	mv	a2,s5
    80005fac:	85ca                	mv	a1,s2
    80005fae:	e0843503          	ld	a0,-504(s0)
    80005fb2:	ffffb097          	auipc	ra,0xffffb
    80005fb6:	6b2080e7          	jalr	1714(ra) # 80001664 <copyout>
    80005fba:	12054a63          	bltz	a0,800060ee <exec+0x39c>
    ustack[argc] = sp;
    80005fbe:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005fc2:	0485                	addi	s1,s1,1
    80005fc4:	008d8793          	addi	a5,s11,8
    80005fc8:	def43023          	sd	a5,-544(s0)
    80005fcc:	008db503          	ld	a0,8(s11)
    80005fd0:	c911                	beqz	a0,80005fe4 <exec+0x292>
    if(argc >= MAXARG)
    80005fd2:	09a1                	addi	s3,s3,8
    80005fd4:	fb3c14e3          	bne	s8,s3,80005f7c <exec+0x22a>
  sz = sz1;
    80005fd8:	df943423          	sd	s9,-536(s0)
  ip = 0;
    80005fdc:	4a81                	li	s5,0
    80005fde:	a8f9                	j	800060bc <exec+0x36a>
  sp = sz;
    80005fe0:	8966                	mv	s2,s9
  for(argc = 0; argv[argc]; argc++) {
    80005fe2:	4481                	li	s1,0
  ustack[argc] = 0;
    80005fe4:	00349793          	slli	a5,s1,0x3
    80005fe8:	f9040713          	addi	a4,s0,-112
    80005fec:	97ba                	add	a5,a5,a4
    80005fee:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffbcef8>
  sp -= (argc+1) * sizeof(uint64);
    80005ff2:	00148693          	addi	a3,s1,1
    80005ff6:	068e                	slli	a3,a3,0x3
    80005ff8:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005ffc:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80006000:	01797663          	bgeu	s2,s7,8000600c <exec+0x2ba>
  sz = sz1;
    80006004:	df943423          	sd	s9,-536(s0)
  ip = 0;
    80006008:	4a81                	li	s5,0
    8000600a:	a84d                	j	800060bc <exec+0x36a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000600c:	e8840613          	addi	a2,s0,-376
    80006010:	85ca                	mv	a1,s2
    80006012:	e0843503          	ld	a0,-504(s0)
    80006016:	ffffb097          	auipc	ra,0xffffb
    8000601a:	64e080e7          	jalr	1614(ra) # 80001664 <copyout>
    8000601e:	0c054c63          	bltz	a0,800060f6 <exec+0x3a4>
  t->trapframe->a1 = sp;
    80006022:	040b3783          	ld	a5,64(s6)
    80006026:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000602a:	df043783          	ld	a5,-528(s0)
    8000602e:	0007c703          	lbu	a4,0(a5)
    80006032:	cf11                	beqz	a4,8000604e <exec+0x2fc>
    80006034:	0785                	addi	a5,a5,1
    if(*s == '/')
    80006036:	02f00693          	li	a3,47
    8000603a:	a039                	j	80006048 <exec+0x2f6>
      last = s+1;
    8000603c:	def43823          	sd	a5,-528(s0)
  for(last=s=path; *s; s++)
    80006040:	0785                	addi	a5,a5,1
    80006042:	fff7c703          	lbu	a4,-1(a5)
    80006046:	c701                	beqz	a4,8000604e <exec+0x2fc>
    if(*s == '/')
    80006048:	fed71ce3          	bne	a4,a3,80006040 <exec+0x2ee>
    8000604c:	bfc5                	j	8000603c <exec+0x2ea>
  safestrcpy(p->name, last, sizeof(p->name));
    8000604e:	4641                	li	a2,16
    80006050:	df043583          	ld	a1,-528(s0)
    80006054:	0d8a0513          	addi	a0,s4,216
    80006058:	ffffb097          	auipc	ra,0xffffb
    8000605c:	dde080e7          	jalr	-546(ra) # 80000e36 <safestrcpy>
  for(int i=0; i<32; i++){
    80006060:	0f8a0793          	addi	a5,s4,248
    80006064:	1f8a0713          	addi	a4,s4,504
    80006068:	85ba                	mv	a1,a4
    if(!((p->signal_handlers[i]) == (void*)SIG_IGN)){
    8000606a:	4605                	li	a2,1
    8000606c:	a029                	j	80006076 <exec+0x324>
  for(int i=0; i<32; i++){
    8000606e:	07a1                	addi	a5,a5,8
    80006070:	0711                	addi	a4,a4,4
    80006072:	00f58a63          	beq	a1,a5,80006086 <exec+0x334>
    if(!((p->signal_handlers[i]) == (void*)SIG_IGN)){
    80006076:	6394                	ld	a3,0(a5)
    80006078:	fec68be3          	beq	a3,a2,8000606e <exec+0x31c>
        p->signal_handlers[i]=SIG_DFL;
    8000607c:	0007b023          	sd	zero,0(a5)
        p->handlers_sigmasks[i]=0;   
    80006080:	00072023          	sw	zero,0(a4)
    80006084:	b7ed                	j	8000606e <exec+0x31c>
  oldpagetable = p->pagetable;
    80006086:	040a3503          	ld	a0,64(s4)
  p->pagetable = pagetable;
    8000608a:	e0843783          	ld	a5,-504(s0)
    8000608e:	04fa3023          	sd	a5,64(s4)
  p->sz = sz;
    80006092:	039a3c23          	sd	s9,56(s4)
  t->trapframe->epc = elf.entry;  // initial program counter = main
    80006096:	040b3783          	ld	a5,64(s6)
    8000609a:	e6043703          	ld	a4,-416(s0)
    8000609e:	ef98                	sd	a4,24(a5)
  t->trapframe->sp = sp; // initial stack pointer
    800060a0:	040b3783          	ld	a5,64(s6)
    800060a4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800060a8:	85ea                	mv	a1,s10
    800060aa:	ffffc097          	auipc	ra,0xffffc
    800060ae:	c0a080e7          	jalr	-1014(ra) # 80001cb4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800060b2:	0004851b          	sext.w	a0,s1
    800060b6:	bb59                	j	80005e4c <exec+0xfa>
    800060b8:	de943423          	sd	s1,-536(s0)
    proc_freepagetable(pagetable, sz);
    800060bc:	de843583          	ld	a1,-536(s0)
    800060c0:	e0843503          	ld	a0,-504(s0)
    800060c4:	ffffc097          	auipc	ra,0xffffc
    800060c8:	bf0080e7          	jalr	-1040(ra) # 80001cb4 <proc_freepagetable>
  if(ip){
    800060cc:	d60a96e3          	bnez	s5,80005e38 <exec+0xe6>
  return -1;
    800060d0:	557d                	li	a0,-1
    800060d2:	bbad                	j	80005e4c <exec+0xfa>
    800060d4:	de943423          	sd	s1,-536(s0)
    800060d8:	b7d5                	j	800060bc <exec+0x36a>
    800060da:	de943423          	sd	s1,-536(s0)
    800060de:	bff9                	j	800060bc <exec+0x36a>
    800060e0:	de943423          	sd	s1,-536(s0)
    800060e4:	bfe1                	j	800060bc <exec+0x36a>
  sz = sz1;
    800060e6:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800060ea:	4a81                	li	s5,0
    800060ec:	bfc1                	j	800060bc <exec+0x36a>
  sz = sz1;
    800060ee:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800060f2:	4a81                	li	s5,0
    800060f4:	b7e1                	j	800060bc <exec+0x36a>
  sz = sz1;
    800060f6:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800060fa:	4a81                	li	s5,0
    800060fc:	b7c1                	j	800060bc <exec+0x36a>
    sz = sz1;
    800060fe:	de843483          	ld	s1,-536(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006102:	e0043783          	ld	a5,-512(s0)
    80006106:	0017869b          	addiw	a3,a5,1
    8000610a:	e0d43023          	sd	a3,-512(s0)
    8000610e:	df843783          	ld	a5,-520(s0)
    80006112:	0387879b          	addiw	a5,a5,56
    80006116:	e8045703          	lhu	a4,-384(s0)
    8000611a:	dee6d9e3          	bge	a3,a4,80005f0c <exec+0x1ba>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000611e:	2781                	sext.w	a5,a5
    80006120:	def43c23          	sd	a5,-520(s0)
    80006124:	03800713          	li	a4,56
    80006128:	86be                	mv	a3,a5
    8000612a:	e1040613          	addi	a2,s0,-496
    8000612e:	4581                	li	a1,0
    80006130:	8556                	mv	a0,s5
    80006132:	fffff097          	auipc	ra,0xfffff
    80006136:	9d6080e7          	jalr	-1578(ra) # 80004b08 <readi>
    8000613a:	03800793          	li	a5,56
    8000613e:	f6f51de3          	bne	a0,a5,800060b8 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80006142:	e1042783          	lw	a5,-496(s0)
    80006146:	4705                	li	a4,1
    80006148:	fae79de3          	bne	a5,a4,80006102 <exec+0x3b0>
    if(ph.memsz < ph.filesz)
    8000614c:	e3843603          	ld	a2,-456(s0)
    80006150:	e3043783          	ld	a5,-464(s0)
    80006154:	f8f660e3          	bltu	a2,a5,800060d4 <exec+0x382>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80006158:	e2043783          	ld	a5,-480(s0)
    8000615c:	963e                	add	a2,a2,a5
    8000615e:	f6f66ee3          	bltu	a2,a5,800060da <exec+0x388>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80006162:	85a6                	mv	a1,s1
    80006164:	e0843503          	ld	a0,-504(s0)
    80006168:	ffffb097          	auipc	ra,0xffffb
    8000616c:	2ac080e7          	jalr	684(ra) # 80001414 <uvmalloc>
    80006170:	dea43423          	sd	a0,-536(s0)
    80006174:	d535                	beqz	a0,800060e0 <exec+0x38e>
    if(ph.vaddr % PGSIZE != 0)
    80006176:	e2043c03          	ld	s8,-480(s0)
    8000617a:	dd843783          	ld	a5,-552(s0)
    8000617e:	00fc77b3          	and	a5,s8,a5
    80006182:	ff8d                	bnez	a5,800060bc <exec+0x36a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80006184:	e1842c83          	lw	s9,-488(s0)
    80006188:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000618c:	f60b89e3          	beqz	s7,800060fe <exec+0x3ac>
    80006190:	89de                	mv	s3,s7
    80006192:	4481                	li	s1,0
    80006194:	bb91                	j	80005ee8 <exec+0x196>

0000000080006196 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80006196:	7179                	addi	sp,sp,-48
    80006198:	f406                	sd	ra,40(sp)
    8000619a:	f022                	sd	s0,32(sp)
    8000619c:	ec26                	sd	s1,24(sp)
    8000619e:	e84a                	sd	s2,16(sp)
    800061a0:	1800                	addi	s0,sp,48
    800061a2:	892e                	mv	s2,a1
    800061a4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800061a6:	fdc40593          	addi	a1,s0,-36
    800061aa:	ffffe097          	auipc	ra,0xffffe
    800061ae:	964080e7          	jalr	-1692(ra) # 80003b0e <argint>
    800061b2:	04054063          	bltz	a0,800061f2 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800061b6:	fdc42703          	lw	a4,-36(s0)
    800061ba:	47bd                	li	a5,15
    800061bc:	02e7ed63          	bltu	a5,a4,800061f6 <argfd+0x60>
    800061c0:	ffffc097          	auipc	ra,0xffffc
    800061c4:	8bc080e7          	jalr	-1860(ra) # 80001a7c <myproc>
    800061c8:	fdc42703          	lw	a4,-36(s0)
    800061cc:	00a70793          	addi	a5,a4,10
    800061d0:	078e                	slli	a5,a5,0x3
    800061d2:	953e                	add	a0,a0,a5
    800061d4:	611c                	ld	a5,0(a0)
    800061d6:	c395                	beqz	a5,800061fa <argfd+0x64>
    return -1;
  if(pfd)
    800061d8:	00090463          	beqz	s2,800061e0 <argfd+0x4a>
    *pfd = fd;
    800061dc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800061e0:	4501                	li	a0,0
  if(pf)
    800061e2:	c091                	beqz	s1,800061e6 <argfd+0x50>
    *pf = f;
    800061e4:	e09c                	sd	a5,0(s1)
}
    800061e6:	70a2                	ld	ra,40(sp)
    800061e8:	7402                	ld	s0,32(sp)
    800061ea:	64e2                	ld	s1,24(sp)
    800061ec:	6942                	ld	s2,16(sp)
    800061ee:	6145                	addi	sp,sp,48
    800061f0:	8082                	ret
    return -1;
    800061f2:	557d                	li	a0,-1
    800061f4:	bfcd                	j	800061e6 <argfd+0x50>
    return -1;
    800061f6:	557d                	li	a0,-1
    800061f8:	b7fd                	j	800061e6 <argfd+0x50>
    800061fa:	557d                	li	a0,-1
    800061fc:	b7ed                	j	800061e6 <argfd+0x50>

00000000800061fe <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800061fe:	1101                	addi	sp,sp,-32
    80006200:	ec06                	sd	ra,24(sp)
    80006202:	e822                	sd	s0,16(sp)
    80006204:	e426                	sd	s1,8(sp)
    80006206:	1000                	addi	s0,sp,32
    80006208:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000620a:	ffffc097          	auipc	ra,0xffffc
    8000620e:	872080e7          	jalr	-1934(ra) # 80001a7c <myproc>
    80006212:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80006214:	05050793          	addi	a5,a0,80
    80006218:	4501                	li	a0,0
    8000621a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000621c:	6398                	ld	a4,0(a5)
    8000621e:	cb19                	beqz	a4,80006234 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80006220:	2505                	addiw	a0,a0,1
    80006222:	07a1                	addi	a5,a5,8
    80006224:	fed51ce3          	bne	a0,a3,8000621c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80006228:	557d                	li	a0,-1
}
    8000622a:	60e2                	ld	ra,24(sp)
    8000622c:	6442                	ld	s0,16(sp)
    8000622e:	64a2                	ld	s1,8(sp)
    80006230:	6105                	addi	sp,sp,32
    80006232:	8082                	ret
      p->ofile[fd] = f;
    80006234:	00a50793          	addi	a5,a0,10
    80006238:	078e                	slli	a5,a5,0x3
    8000623a:	963e                	add	a2,a2,a5
    8000623c:	e204                	sd	s1,0(a2)
      return fd;
    8000623e:	b7f5                	j	8000622a <fdalloc+0x2c>

0000000080006240 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80006240:	715d                	addi	sp,sp,-80
    80006242:	e486                	sd	ra,72(sp)
    80006244:	e0a2                	sd	s0,64(sp)
    80006246:	fc26                	sd	s1,56(sp)
    80006248:	f84a                	sd	s2,48(sp)
    8000624a:	f44e                	sd	s3,40(sp)
    8000624c:	f052                	sd	s4,32(sp)
    8000624e:	ec56                	sd	s5,24(sp)
    80006250:	0880                	addi	s0,sp,80
    80006252:	89ae                	mv	s3,a1
    80006254:	8ab2                	mv	s5,a2
    80006256:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80006258:	fb040593          	addi	a1,s0,-80
    8000625c:	fffff097          	auipc	ra,0xfffff
    80006260:	dca080e7          	jalr	-566(ra) # 80005026 <nameiparent>
    80006264:	892a                	mv	s2,a0
    80006266:	12050e63          	beqz	a0,800063a2 <create+0x162>
    return 0;

  ilock(dp);
    8000626a:	ffffe097          	auipc	ra,0xffffe
    8000626e:	5ea080e7          	jalr	1514(ra) # 80004854 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80006272:	4601                	li	a2,0
    80006274:	fb040593          	addi	a1,s0,-80
    80006278:	854a                	mv	a0,s2
    8000627a:	fffff097          	auipc	ra,0xfffff
    8000627e:	abe080e7          	jalr	-1346(ra) # 80004d38 <dirlookup>
    80006282:	84aa                	mv	s1,a0
    80006284:	c921                	beqz	a0,800062d4 <create+0x94>
    iunlockput(dp);
    80006286:	854a                	mv	a0,s2
    80006288:	fffff097          	auipc	ra,0xfffff
    8000628c:	82e080e7          	jalr	-2002(ra) # 80004ab6 <iunlockput>
    ilock(ip);
    80006290:	8526                	mv	a0,s1
    80006292:	ffffe097          	auipc	ra,0xffffe
    80006296:	5c2080e7          	jalr	1474(ra) # 80004854 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000629a:	2981                	sext.w	s3,s3
    8000629c:	4789                	li	a5,2
    8000629e:	02f99463          	bne	s3,a5,800062c6 <create+0x86>
    800062a2:	0444d783          	lhu	a5,68(s1)
    800062a6:	37f9                	addiw	a5,a5,-2
    800062a8:	17c2                	slli	a5,a5,0x30
    800062aa:	93c1                	srli	a5,a5,0x30
    800062ac:	4705                	li	a4,1
    800062ae:	00f76c63          	bltu	a4,a5,800062c6 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800062b2:	8526                	mv	a0,s1
    800062b4:	60a6                	ld	ra,72(sp)
    800062b6:	6406                	ld	s0,64(sp)
    800062b8:	74e2                	ld	s1,56(sp)
    800062ba:	7942                	ld	s2,48(sp)
    800062bc:	79a2                	ld	s3,40(sp)
    800062be:	7a02                	ld	s4,32(sp)
    800062c0:	6ae2                	ld	s5,24(sp)
    800062c2:	6161                	addi	sp,sp,80
    800062c4:	8082                	ret
    iunlockput(ip);
    800062c6:	8526                	mv	a0,s1
    800062c8:	ffffe097          	auipc	ra,0xffffe
    800062cc:	7ee080e7          	jalr	2030(ra) # 80004ab6 <iunlockput>
    return 0;
    800062d0:	4481                	li	s1,0
    800062d2:	b7c5                	j	800062b2 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800062d4:	85ce                	mv	a1,s3
    800062d6:	00092503          	lw	a0,0(s2)
    800062da:	ffffe097          	auipc	ra,0xffffe
    800062de:	3e2080e7          	jalr	994(ra) # 800046bc <ialloc>
    800062e2:	84aa                	mv	s1,a0
    800062e4:	c521                	beqz	a0,8000632c <create+0xec>
  ilock(ip);
    800062e6:	ffffe097          	auipc	ra,0xffffe
    800062ea:	56e080e7          	jalr	1390(ra) # 80004854 <ilock>
  ip->major = major;
    800062ee:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800062f2:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800062f6:	4a05                	li	s4,1
    800062f8:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800062fc:	8526                	mv	a0,s1
    800062fe:	ffffe097          	auipc	ra,0xffffe
    80006302:	48c080e7          	jalr	1164(ra) # 8000478a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80006306:	2981                	sext.w	s3,s3
    80006308:	03498a63          	beq	s3,s4,8000633c <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000630c:	40d0                	lw	a2,4(s1)
    8000630e:	fb040593          	addi	a1,s0,-80
    80006312:	854a                	mv	a0,s2
    80006314:	fffff097          	auipc	ra,0xfffff
    80006318:	c32080e7          	jalr	-974(ra) # 80004f46 <dirlink>
    8000631c:	06054b63          	bltz	a0,80006392 <create+0x152>
  iunlockput(dp);
    80006320:	854a                	mv	a0,s2
    80006322:	ffffe097          	auipc	ra,0xffffe
    80006326:	794080e7          	jalr	1940(ra) # 80004ab6 <iunlockput>
  return ip;
    8000632a:	b761                	j	800062b2 <create+0x72>
    panic("create: ialloc");
    8000632c:	00003517          	auipc	a0,0x3
    80006330:	5e450513          	addi	a0,a0,1508 # 80009910 <syscalls+0x2d8>
    80006334:	ffffa097          	auipc	ra,0xffffa
    80006338:	1fa080e7          	jalr	506(ra) # 8000052e <panic>
    dp->nlink++;  // for ".."
    8000633c:	04a95783          	lhu	a5,74(s2)
    80006340:	2785                	addiw	a5,a5,1
    80006342:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80006346:	854a                	mv	a0,s2
    80006348:	ffffe097          	auipc	ra,0xffffe
    8000634c:	442080e7          	jalr	1090(ra) # 8000478a <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80006350:	40d0                	lw	a2,4(s1)
    80006352:	00003597          	auipc	a1,0x3
    80006356:	5ce58593          	addi	a1,a1,1486 # 80009920 <syscalls+0x2e8>
    8000635a:	8526                	mv	a0,s1
    8000635c:	fffff097          	auipc	ra,0xfffff
    80006360:	bea080e7          	jalr	-1046(ra) # 80004f46 <dirlink>
    80006364:	00054f63          	bltz	a0,80006382 <create+0x142>
    80006368:	00492603          	lw	a2,4(s2)
    8000636c:	00003597          	auipc	a1,0x3
    80006370:	5bc58593          	addi	a1,a1,1468 # 80009928 <syscalls+0x2f0>
    80006374:	8526                	mv	a0,s1
    80006376:	fffff097          	auipc	ra,0xfffff
    8000637a:	bd0080e7          	jalr	-1072(ra) # 80004f46 <dirlink>
    8000637e:	f80557e3          	bgez	a0,8000630c <create+0xcc>
      panic("create dots");
    80006382:	00003517          	auipc	a0,0x3
    80006386:	5ae50513          	addi	a0,a0,1454 # 80009930 <syscalls+0x2f8>
    8000638a:	ffffa097          	auipc	ra,0xffffa
    8000638e:	1a4080e7          	jalr	420(ra) # 8000052e <panic>
    panic("create: dirlink");
    80006392:	00003517          	auipc	a0,0x3
    80006396:	5ae50513          	addi	a0,a0,1454 # 80009940 <syscalls+0x308>
    8000639a:	ffffa097          	auipc	ra,0xffffa
    8000639e:	194080e7          	jalr	404(ra) # 8000052e <panic>
    return 0;
    800063a2:	84aa                	mv	s1,a0
    800063a4:	b739                	j	800062b2 <create+0x72>

00000000800063a6 <sys_dup>:
{
    800063a6:	7179                	addi	sp,sp,-48
    800063a8:	f406                	sd	ra,40(sp)
    800063aa:	f022                	sd	s0,32(sp)
    800063ac:	ec26                	sd	s1,24(sp)
    800063ae:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800063b0:	fd840613          	addi	a2,s0,-40
    800063b4:	4581                	li	a1,0
    800063b6:	4501                	li	a0,0
    800063b8:	00000097          	auipc	ra,0x0
    800063bc:	dde080e7          	jalr	-546(ra) # 80006196 <argfd>
    return -1;
    800063c0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800063c2:	02054363          	bltz	a0,800063e8 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800063c6:	fd843503          	ld	a0,-40(s0)
    800063ca:	00000097          	auipc	ra,0x0
    800063ce:	e34080e7          	jalr	-460(ra) # 800061fe <fdalloc>
    800063d2:	84aa                	mv	s1,a0
    return -1;
    800063d4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800063d6:	00054963          	bltz	a0,800063e8 <sys_dup+0x42>
  filedup(f);
    800063da:	fd843503          	ld	a0,-40(s0)
    800063de:	fffff097          	auipc	ra,0xfffff
    800063e2:	2c4080e7          	jalr	708(ra) # 800056a2 <filedup>
  return fd;
    800063e6:	87a6                	mv	a5,s1
}
    800063e8:	853e                	mv	a0,a5
    800063ea:	70a2                	ld	ra,40(sp)
    800063ec:	7402                	ld	s0,32(sp)
    800063ee:	64e2                	ld	s1,24(sp)
    800063f0:	6145                	addi	sp,sp,48
    800063f2:	8082                	ret

00000000800063f4 <sys_read>:
{
    800063f4:	7179                	addi	sp,sp,-48
    800063f6:	f406                	sd	ra,40(sp)
    800063f8:	f022                	sd	s0,32(sp)
    800063fa:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800063fc:	fe840613          	addi	a2,s0,-24
    80006400:	4581                	li	a1,0
    80006402:	4501                	li	a0,0
    80006404:	00000097          	auipc	ra,0x0
    80006408:	d92080e7          	jalr	-622(ra) # 80006196 <argfd>
    return -1;
    8000640c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000640e:	04054163          	bltz	a0,80006450 <sys_read+0x5c>
    80006412:	fe440593          	addi	a1,s0,-28
    80006416:	4509                	li	a0,2
    80006418:	ffffd097          	auipc	ra,0xffffd
    8000641c:	6f6080e7          	jalr	1782(ra) # 80003b0e <argint>
    return -1;
    80006420:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006422:	02054763          	bltz	a0,80006450 <sys_read+0x5c>
    80006426:	fd840593          	addi	a1,s0,-40
    8000642a:	4505                	li	a0,1
    8000642c:	ffffd097          	auipc	ra,0xffffd
    80006430:	704080e7          	jalr	1796(ra) # 80003b30 <argaddr>
    return -1;
    80006434:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006436:	00054d63          	bltz	a0,80006450 <sys_read+0x5c>
  return fileread(f, p, n);
    8000643a:	fe442603          	lw	a2,-28(s0)
    8000643e:	fd843583          	ld	a1,-40(s0)
    80006442:	fe843503          	ld	a0,-24(s0)
    80006446:	fffff097          	auipc	ra,0xfffff
    8000644a:	3e8080e7          	jalr	1000(ra) # 8000582e <fileread>
    8000644e:	87aa                	mv	a5,a0
}
    80006450:	853e                	mv	a0,a5
    80006452:	70a2                	ld	ra,40(sp)
    80006454:	7402                	ld	s0,32(sp)
    80006456:	6145                	addi	sp,sp,48
    80006458:	8082                	ret

000000008000645a <sys_write>:
{
    8000645a:	7179                	addi	sp,sp,-48
    8000645c:	f406                	sd	ra,40(sp)
    8000645e:	f022                	sd	s0,32(sp)
    80006460:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006462:	fe840613          	addi	a2,s0,-24
    80006466:	4581                	li	a1,0
    80006468:	4501                	li	a0,0
    8000646a:	00000097          	auipc	ra,0x0
    8000646e:	d2c080e7          	jalr	-724(ra) # 80006196 <argfd>
    return -1;
    80006472:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006474:	04054163          	bltz	a0,800064b6 <sys_write+0x5c>
    80006478:	fe440593          	addi	a1,s0,-28
    8000647c:	4509                	li	a0,2
    8000647e:	ffffd097          	auipc	ra,0xffffd
    80006482:	690080e7          	jalr	1680(ra) # 80003b0e <argint>
    return -1;
    80006486:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006488:	02054763          	bltz	a0,800064b6 <sys_write+0x5c>
    8000648c:	fd840593          	addi	a1,s0,-40
    80006490:	4505                	li	a0,1
    80006492:	ffffd097          	auipc	ra,0xffffd
    80006496:	69e080e7          	jalr	1694(ra) # 80003b30 <argaddr>
    return -1;
    8000649a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000649c:	00054d63          	bltz	a0,800064b6 <sys_write+0x5c>
  return filewrite(f, p, n);
    800064a0:	fe442603          	lw	a2,-28(s0)
    800064a4:	fd843583          	ld	a1,-40(s0)
    800064a8:	fe843503          	ld	a0,-24(s0)
    800064ac:	fffff097          	auipc	ra,0xfffff
    800064b0:	444080e7          	jalr	1092(ra) # 800058f0 <filewrite>
    800064b4:	87aa                	mv	a5,a0
}
    800064b6:	853e                	mv	a0,a5
    800064b8:	70a2                	ld	ra,40(sp)
    800064ba:	7402                	ld	s0,32(sp)
    800064bc:	6145                	addi	sp,sp,48
    800064be:	8082                	ret

00000000800064c0 <sys_close>:
{
    800064c0:	1101                	addi	sp,sp,-32
    800064c2:	ec06                	sd	ra,24(sp)
    800064c4:	e822                	sd	s0,16(sp)
    800064c6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800064c8:	fe040613          	addi	a2,s0,-32
    800064cc:	fec40593          	addi	a1,s0,-20
    800064d0:	4501                	li	a0,0
    800064d2:	00000097          	auipc	ra,0x0
    800064d6:	cc4080e7          	jalr	-828(ra) # 80006196 <argfd>
    return -1;
    800064da:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800064dc:	02054463          	bltz	a0,80006504 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800064e0:	ffffb097          	auipc	ra,0xffffb
    800064e4:	59c080e7          	jalr	1436(ra) # 80001a7c <myproc>
    800064e8:	fec42783          	lw	a5,-20(s0)
    800064ec:	07a9                	addi	a5,a5,10
    800064ee:	078e                	slli	a5,a5,0x3
    800064f0:	97aa                	add	a5,a5,a0
    800064f2:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800064f6:	fe043503          	ld	a0,-32(s0)
    800064fa:	fffff097          	auipc	ra,0xfffff
    800064fe:	1fa080e7          	jalr	506(ra) # 800056f4 <fileclose>
  return 0;
    80006502:	4781                	li	a5,0
}
    80006504:	853e                	mv	a0,a5
    80006506:	60e2                	ld	ra,24(sp)
    80006508:	6442                	ld	s0,16(sp)
    8000650a:	6105                	addi	sp,sp,32
    8000650c:	8082                	ret

000000008000650e <sys_fstat>:
{
    8000650e:	1101                	addi	sp,sp,-32
    80006510:	ec06                	sd	ra,24(sp)
    80006512:	e822                	sd	s0,16(sp)
    80006514:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006516:	fe840613          	addi	a2,s0,-24
    8000651a:	4581                	li	a1,0
    8000651c:	4501                	li	a0,0
    8000651e:	00000097          	auipc	ra,0x0
    80006522:	c78080e7          	jalr	-904(ra) # 80006196 <argfd>
    return -1;
    80006526:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006528:	02054563          	bltz	a0,80006552 <sys_fstat+0x44>
    8000652c:	fe040593          	addi	a1,s0,-32
    80006530:	4505                	li	a0,1
    80006532:	ffffd097          	auipc	ra,0xffffd
    80006536:	5fe080e7          	jalr	1534(ra) # 80003b30 <argaddr>
    return -1;
    8000653a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000653c:	00054b63          	bltz	a0,80006552 <sys_fstat+0x44>
  return filestat(f, st);
    80006540:	fe043583          	ld	a1,-32(s0)
    80006544:	fe843503          	ld	a0,-24(s0)
    80006548:	fffff097          	auipc	ra,0xfffff
    8000654c:	274080e7          	jalr	628(ra) # 800057bc <filestat>
    80006550:	87aa                	mv	a5,a0
}
    80006552:	853e                	mv	a0,a5
    80006554:	60e2                	ld	ra,24(sp)
    80006556:	6442                	ld	s0,16(sp)
    80006558:	6105                	addi	sp,sp,32
    8000655a:	8082                	ret

000000008000655c <sys_link>:
{
    8000655c:	7169                	addi	sp,sp,-304
    8000655e:	f606                	sd	ra,296(sp)
    80006560:	f222                	sd	s0,288(sp)
    80006562:	ee26                	sd	s1,280(sp)
    80006564:	ea4a                	sd	s2,272(sp)
    80006566:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006568:	08000613          	li	a2,128
    8000656c:	ed040593          	addi	a1,s0,-304
    80006570:	4501                	li	a0,0
    80006572:	ffffd097          	auipc	ra,0xffffd
    80006576:	5e0080e7          	jalr	1504(ra) # 80003b52 <argstr>
    return -1;
    8000657a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000657c:	10054e63          	bltz	a0,80006698 <sys_link+0x13c>
    80006580:	08000613          	li	a2,128
    80006584:	f5040593          	addi	a1,s0,-176
    80006588:	4505                	li	a0,1
    8000658a:	ffffd097          	auipc	ra,0xffffd
    8000658e:	5c8080e7          	jalr	1480(ra) # 80003b52 <argstr>
    return -1;
    80006592:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006594:	10054263          	bltz	a0,80006698 <sys_link+0x13c>
  begin_op();
    80006598:	fffff097          	auipc	ra,0xfffff
    8000659c:	c90080e7          	jalr	-880(ra) # 80005228 <begin_op>
  if((ip = namei(old)) == 0){
    800065a0:	ed040513          	addi	a0,s0,-304
    800065a4:	fffff097          	auipc	ra,0xfffff
    800065a8:	a64080e7          	jalr	-1436(ra) # 80005008 <namei>
    800065ac:	84aa                	mv	s1,a0
    800065ae:	c551                	beqz	a0,8000663a <sys_link+0xde>
  ilock(ip);
    800065b0:	ffffe097          	auipc	ra,0xffffe
    800065b4:	2a4080e7          	jalr	676(ra) # 80004854 <ilock>
  if(ip->type == T_DIR){
    800065b8:	04449703          	lh	a4,68(s1)
    800065bc:	4785                	li	a5,1
    800065be:	08f70463          	beq	a4,a5,80006646 <sys_link+0xea>
  ip->nlink++;
    800065c2:	04a4d783          	lhu	a5,74(s1)
    800065c6:	2785                	addiw	a5,a5,1
    800065c8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800065cc:	8526                	mv	a0,s1
    800065ce:	ffffe097          	auipc	ra,0xffffe
    800065d2:	1bc080e7          	jalr	444(ra) # 8000478a <iupdate>
  iunlock(ip);
    800065d6:	8526                	mv	a0,s1
    800065d8:	ffffe097          	auipc	ra,0xffffe
    800065dc:	33e080e7          	jalr	830(ra) # 80004916 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800065e0:	fd040593          	addi	a1,s0,-48
    800065e4:	f5040513          	addi	a0,s0,-176
    800065e8:	fffff097          	auipc	ra,0xfffff
    800065ec:	a3e080e7          	jalr	-1474(ra) # 80005026 <nameiparent>
    800065f0:	892a                	mv	s2,a0
    800065f2:	c935                	beqz	a0,80006666 <sys_link+0x10a>
  ilock(dp);
    800065f4:	ffffe097          	auipc	ra,0xffffe
    800065f8:	260080e7          	jalr	608(ra) # 80004854 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800065fc:	00092703          	lw	a4,0(s2)
    80006600:	409c                	lw	a5,0(s1)
    80006602:	04f71d63          	bne	a4,a5,8000665c <sys_link+0x100>
    80006606:	40d0                	lw	a2,4(s1)
    80006608:	fd040593          	addi	a1,s0,-48
    8000660c:	854a                	mv	a0,s2
    8000660e:	fffff097          	auipc	ra,0xfffff
    80006612:	938080e7          	jalr	-1736(ra) # 80004f46 <dirlink>
    80006616:	04054363          	bltz	a0,8000665c <sys_link+0x100>
  iunlockput(dp);
    8000661a:	854a                	mv	a0,s2
    8000661c:	ffffe097          	auipc	ra,0xffffe
    80006620:	49a080e7          	jalr	1178(ra) # 80004ab6 <iunlockput>
  iput(ip);
    80006624:	8526                	mv	a0,s1
    80006626:	ffffe097          	auipc	ra,0xffffe
    8000662a:	3e8080e7          	jalr	1000(ra) # 80004a0e <iput>
  end_op();
    8000662e:	fffff097          	auipc	ra,0xfffff
    80006632:	c7a080e7          	jalr	-902(ra) # 800052a8 <end_op>
  return 0;
    80006636:	4781                	li	a5,0
    80006638:	a085                	j	80006698 <sys_link+0x13c>
    end_op();
    8000663a:	fffff097          	auipc	ra,0xfffff
    8000663e:	c6e080e7          	jalr	-914(ra) # 800052a8 <end_op>
    return -1;
    80006642:	57fd                	li	a5,-1
    80006644:	a891                	j	80006698 <sys_link+0x13c>
    iunlockput(ip);
    80006646:	8526                	mv	a0,s1
    80006648:	ffffe097          	auipc	ra,0xffffe
    8000664c:	46e080e7          	jalr	1134(ra) # 80004ab6 <iunlockput>
    end_op();
    80006650:	fffff097          	auipc	ra,0xfffff
    80006654:	c58080e7          	jalr	-936(ra) # 800052a8 <end_op>
    return -1;
    80006658:	57fd                	li	a5,-1
    8000665a:	a83d                	j	80006698 <sys_link+0x13c>
    iunlockput(dp);
    8000665c:	854a                	mv	a0,s2
    8000665e:	ffffe097          	auipc	ra,0xffffe
    80006662:	458080e7          	jalr	1112(ra) # 80004ab6 <iunlockput>
  ilock(ip);
    80006666:	8526                	mv	a0,s1
    80006668:	ffffe097          	auipc	ra,0xffffe
    8000666c:	1ec080e7          	jalr	492(ra) # 80004854 <ilock>
  ip->nlink--;
    80006670:	04a4d783          	lhu	a5,74(s1)
    80006674:	37fd                	addiw	a5,a5,-1
    80006676:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000667a:	8526                	mv	a0,s1
    8000667c:	ffffe097          	auipc	ra,0xffffe
    80006680:	10e080e7          	jalr	270(ra) # 8000478a <iupdate>
  iunlockput(ip);
    80006684:	8526                	mv	a0,s1
    80006686:	ffffe097          	auipc	ra,0xffffe
    8000668a:	430080e7          	jalr	1072(ra) # 80004ab6 <iunlockput>
  end_op();
    8000668e:	fffff097          	auipc	ra,0xfffff
    80006692:	c1a080e7          	jalr	-998(ra) # 800052a8 <end_op>
  return -1;
    80006696:	57fd                	li	a5,-1
}
    80006698:	853e                	mv	a0,a5
    8000669a:	70b2                	ld	ra,296(sp)
    8000669c:	7412                	ld	s0,288(sp)
    8000669e:	64f2                	ld	s1,280(sp)
    800066a0:	6952                	ld	s2,272(sp)
    800066a2:	6155                	addi	sp,sp,304
    800066a4:	8082                	ret

00000000800066a6 <sys_unlink>:
{
    800066a6:	7151                	addi	sp,sp,-240
    800066a8:	f586                	sd	ra,232(sp)
    800066aa:	f1a2                	sd	s0,224(sp)
    800066ac:	eda6                	sd	s1,216(sp)
    800066ae:	e9ca                	sd	s2,208(sp)
    800066b0:	e5ce                	sd	s3,200(sp)
    800066b2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800066b4:	08000613          	li	a2,128
    800066b8:	f3040593          	addi	a1,s0,-208
    800066bc:	4501                	li	a0,0
    800066be:	ffffd097          	auipc	ra,0xffffd
    800066c2:	494080e7          	jalr	1172(ra) # 80003b52 <argstr>
    800066c6:	18054163          	bltz	a0,80006848 <sys_unlink+0x1a2>
  begin_op();
    800066ca:	fffff097          	auipc	ra,0xfffff
    800066ce:	b5e080e7          	jalr	-1186(ra) # 80005228 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800066d2:	fb040593          	addi	a1,s0,-80
    800066d6:	f3040513          	addi	a0,s0,-208
    800066da:	fffff097          	auipc	ra,0xfffff
    800066de:	94c080e7          	jalr	-1716(ra) # 80005026 <nameiparent>
    800066e2:	84aa                	mv	s1,a0
    800066e4:	c979                	beqz	a0,800067ba <sys_unlink+0x114>
  ilock(dp);
    800066e6:	ffffe097          	auipc	ra,0xffffe
    800066ea:	16e080e7          	jalr	366(ra) # 80004854 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800066ee:	00003597          	auipc	a1,0x3
    800066f2:	23258593          	addi	a1,a1,562 # 80009920 <syscalls+0x2e8>
    800066f6:	fb040513          	addi	a0,s0,-80
    800066fa:	ffffe097          	auipc	ra,0xffffe
    800066fe:	624080e7          	jalr	1572(ra) # 80004d1e <namecmp>
    80006702:	14050a63          	beqz	a0,80006856 <sys_unlink+0x1b0>
    80006706:	00003597          	auipc	a1,0x3
    8000670a:	22258593          	addi	a1,a1,546 # 80009928 <syscalls+0x2f0>
    8000670e:	fb040513          	addi	a0,s0,-80
    80006712:	ffffe097          	auipc	ra,0xffffe
    80006716:	60c080e7          	jalr	1548(ra) # 80004d1e <namecmp>
    8000671a:	12050e63          	beqz	a0,80006856 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000671e:	f2c40613          	addi	a2,s0,-212
    80006722:	fb040593          	addi	a1,s0,-80
    80006726:	8526                	mv	a0,s1
    80006728:	ffffe097          	auipc	ra,0xffffe
    8000672c:	610080e7          	jalr	1552(ra) # 80004d38 <dirlookup>
    80006730:	892a                	mv	s2,a0
    80006732:	12050263          	beqz	a0,80006856 <sys_unlink+0x1b0>
  ilock(ip);
    80006736:	ffffe097          	auipc	ra,0xffffe
    8000673a:	11e080e7          	jalr	286(ra) # 80004854 <ilock>
  if(ip->nlink < 1)
    8000673e:	04a91783          	lh	a5,74(s2)
    80006742:	08f05263          	blez	a5,800067c6 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006746:	04491703          	lh	a4,68(s2)
    8000674a:	4785                	li	a5,1
    8000674c:	08f70563          	beq	a4,a5,800067d6 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80006750:	4641                	li	a2,16
    80006752:	4581                	li	a1,0
    80006754:	fc040513          	addi	a0,s0,-64
    80006758:	ffffa097          	auipc	ra,0xffffa
    8000675c:	58c080e7          	jalr	1420(ra) # 80000ce4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006760:	4741                	li	a4,16
    80006762:	f2c42683          	lw	a3,-212(s0)
    80006766:	fc040613          	addi	a2,s0,-64
    8000676a:	4581                	li	a1,0
    8000676c:	8526                	mv	a0,s1
    8000676e:	ffffe097          	auipc	ra,0xffffe
    80006772:	492080e7          	jalr	1170(ra) # 80004c00 <writei>
    80006776:	47c1                	li	a5,16
    80006778:	0af51563          	bne	a0,a5,80006822 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000677c:	04491703          	lh	a4,68(s2)
    80006780:	4785                	li	a5,1
    80006782:	0af70863          	beq	a4,a5,80006832 <sys_unlink+0x18c>
  iunlockput(dp);
    80006786:	8526                	mv	a0,s1
    80006788:	ffffe097          	auipc	ra,0xffffe
    8000678c:	32e080e7          	jalr	814(ra) # 80004ab6 <iunlockput>
  ip->nlink--;
    80006790:	04a95783          	lhu	a5,74(s2)
    80006794:	37fd                	addiw	a5,a5,-1
    80006796:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000679a:	854a                	mv	a0,s2
    8000679c:	ffffe097          	auipc	ra,0xffffe
    800067a0:	fee080e7          	jalr	-18(ra) # 8000478a <iupdate>
  iunlockput(ip);
    800067a4:	854a                	mv	a0,s2
    800067a6:	ffffe097          	auipc	ra,0xffffe
    800067aa:	310080e7          	jalr	784(ra) # 80004ab6 <iunlockput>
  end_op();
    800067ae:	fffff097          	auipc	ra,0xfffff
    800067b2:	afa080e7          	jalr	-1286(ra) # 800052a8 <end_op>
  return 0;
    800067b6:	4501                	li	a0,0
    800067b8:	a84d                	j	8000686a <sys_unlink+0x1c4>
    end_op();
    800067ba:	fffff097          	auipc	ra,0xfffff
    800067be:	aee080e7          	jalr	-1298(ra) # 800052a8 <end_op>
    return -1;
    800067c2:	557d                	li	a0,-1
    800067c4:	a05d                	j	8000686a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800067c6:	00003517          	auipc	a0,0x3
    800067ca:	18a50513          	addi	a0,a0,394 # 80009950 <syscalls+0x318>
    800067ce:	ffffa097          	auipc	ra,0xffffa
    800067d2:	d60080e7          	jalr	-672(ra) # 8000052e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800067d6:	04c92703          	lw	a4,76(s2)
    800067da:	02000793          	li	a5,32
    800067de:	f6e7f9e3          	bgeu	a5,a4,80006750 <sys_unlink+0xaa>
    800067e2:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800067e6:	4741                	li	a4,16
    800067e8:	86ce                	mv	a3,s3
    800067ea:	f1840613          	addi	a2,s0,-232
    800067ee:	4581                	li	a1,0
    800067f0:	854a                	mv	a0,s2
    800067f2:	ffffe097          	auipc	ra,0xffffe
    800067f6:	316080e7          	jalr	790(ra) # 80004b08 <readi>
    800067fa:	47c1                	li	a5,16
    800067fc:	00f51b63          	bne	a0,a5,80006812 <sys_unlink+0x16c>
    if(de.inum != 0)
    80006800:	f1845783          	lhu	a5,-232(s0)
    80006804:	e7a1                	bnez	a5,8000684c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006806:	29c1                	addiw	s3,s3,16
    80006808:	04c92783          	lw	a5,76(s2)
    8000680c:	fcf9ede3          	bltu	s3,a5,800067e6 <sys_unlink+0x140>
    80006810:	b781                	j	80006750 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80006812:	00003517          	auipc	a0,0x3
    80006816:	15650513          	addi	a0,a0,342 # 80009968 <syscalls+0x330>
    8000681a:	ffffa097          	auipc	ra,0xffffa
    8000681e:	d14080e7          	jalr	-748(ra) # 8000052e <panic>
    panic("unlink: writei");
    80006822:	00003517          	auipc	a0,0x3
    80006826:	15e50513          	addi	a0,a0,350 # 80009980 <syscalls+0x348>
    8000682a:	ffffa097          	auipc	ra,0xffffa
    8000682e:	d04080e7          	jalr	-764(ra) # 8000052e <panic>
    dp->nlink--;
    80006832:	04a4d783          	lhu	a5,74(s1)
    80006836:	37fd                	addiw	a5,a5,-1
    80006838:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000683c:	8526                	mv	a0,s1
    8000683e:	ffffe097          	auipc	ra,0xffffe
    80006842:	f4c080e7          	jalr	-180(ra) # 8000478a <iupdate>
    80006846:	b781                	j	80006786 <sys_unlink+0xe0>
    return -1;
    80006848:	557d                	li	a0,-1
    8000684a:	a005                	j	8000686a <sys_unlink+0x1c4>
    iunlockput(ip);
    8000684c:	854a                	mv	a0,s2
    8000684e:	ffffe097          	auipc	ra,0xffffe
    80006852:	268080e7          	jalr	616(ra) # 80004ab6 <iunlockput>
  iunlockput(dp);
    80006856:	8526                	mv	a0,s1
    80006858:	ffffe097          	auipc	ra,0xffffe
    8000685c:	25e080e7          	jalr	606(ra) # 80004ab6 <iunlockput>
  end_op();
    80006860:	fffff097          	auipc	ra,0xfffff
    80006864:	a48080e7          	jalr	-1464(ra) # 800052a8 <end_op>
  return -1;
    80006868:	557d                	li	a0,-1
}
    8000686a:	70ae                	ld	ra,232(sp)
    8000686c:	740e                	ld	s0,224(sp)
    8000686e:	64ee                	ld	s1,216(sp)
    80006870:	694e                	ld	s2,208(sp)
    80006872:	69ae                	ld	s3,200(sp)
    80006874:	616d                	addi	sp,sp,240
    80006876:	8082                	ret

0000000080006878 <sys_open>:

uint64
sys_open(void)
{
    80006878:	7131                	addi	sp,sp,-192
    8000687a:	fd06                	sd	ra,184(sp)
    8000687c:	f922                	sd	s0,176(sp)
    8000687e:	f526                	sd	s1,168(sp)
    80006880:	f14a                	sd	s2,160(sp)
    80006882:	ed4e                	sd	s3,152(sp)
    80006884:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006886:	08000613          	li	a2,128
    8000688a:	f5040593          	addi	a1,s0,-176
    8000688e:	4501                	li	a0,0
    80006890:	ffffd097          	auipc	ra,0xffffd
    80006894:	2c2080e7          	jalr	706(ra) # 80003b52 <argstr>
    return -1;
    80006898:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000689a:	0c054163          	bltz	a0,8000695c <sys_open+0xe4>
    8000689e:	f4c40593          	addi	a1,s0,-180
    800068a2:	4505                	li	a0,1
    800068a4:	ffffd097          	auipc	ra,0xffffd
    800068a8:	26a080e7          	jalr	618(ra) # 80003b0e <argint>
    800068ac:	0a054863          	bltz	a0,8000695c <sys_open+0xe4>

  begin_op();
    800068b0:	fffff097          	auipc	ra,0xfffff
    800068b4:	978080e7          	jalr	-1672(ra) # 80005228 <begin_op>

  if(omode & O_CREATE){
    800068b8:	f4c42783          	lw	a5,-180(s0)
    800068bc:	2007f793          	andi	a5,a5,512
    800068c0:	cbdd                	beqz	a5,80006976 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800068c2:	4681                	li	a3,0
    800068c4:	4601                	li	a2,0
    800068c6:	4589                	li	a1,2
    800068c8:	f5040513          	addi	a0,s0,-176
    800068cc:	00000097          	auipc	ra,0x0
    800068d0:	974080e7          	jalr	-1676(ra) # 80006240 <create>
    800068d4:	892a                	mv	s2,a0
    if(ip == 0){
    800068d6:	c959                	beqz	a0,8000696c <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800068d8:	04491703          	lh	a4,68(s2)
    800068dc:	478d                	li	a5,3
    800068de:	00f71763          	bne	a4,a5,800068ec <sys_open+0x74>
    800068e2:	04695703          	lhu	a4,70(s2)
    800068e6:	47a5                	li	a5,9
    800068e8:	0ce7ec63          	bltu	a5,a4,800069c0 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800068ec:	fffff097          	auipc	ra,0xfffff
    800068f0:	d4c080e7          	jalr	-692(ra) # 80005638 <filealloc>
    800068f4:	89aa                	mv	s3,a0
    800068f6:	10050263          	beqz	a0,800069fa <sys_open+0x182>
    800068fa:	00000097          	auipc	ra,0x0
    800068fe:	904080e7          	jalr	-1788(ra) # 800061fe <fdalloc>
    80006902:	84aa                	mv	s1,a0
    80006904:	0e054663          	bltz	a0,800069f0 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006908:	04491703          	lh	a4,68(s2)
    8000690c:	478d                	li	a5,3
    8000690e:	0cf70463          	beq	a4,a5,800069d6 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006912:	4789                	li	a5,2
    80006914:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80006918:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000691c:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80006920:	f4c42783          	lw	a5,-180(s0)
    80006924:	0017c713          	xori	a4,a5,1
    80006928:	8b05                	andi	a4,a4,1
    8000692a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000692e:	0037f713          	andi	a4,a5,3
    80006932:	00e03733          	snez	a4,a4
    80006936:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000693a:	4007f793          	andi	a5,a5,1024
    8000693e:	c791                	beqz	a5,8000694a <sys_open+0xd2>
    80006940:	04491703          	lh	a4,68(s2)
    80006944:	4789                	li	a5,2
    80006946:	08f70f63          	beq	a4,a5,800069e4 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000694a:	854a                	mv	a0,s2
    8000694c:	ffffe097          	auipc	ra,0xffffe
    80006950:	fca080e7          	jalr	-54(ra) # 80004916 <iunlock>
  end_op();
    80006954:	fffff097          	auipc	ra,0xfffff
    80006958:	954080e7          	jalr	-1708(ra) # 800052a8 <end_op>

  return fd;
}
    8000695c:	8526                	mv	a0,s1
    8000695e:	70ea                	ld	ra,184(sp)
    80006960:	744a                	ld	s0,176(sp)
    80006962:	74aa                	ld	s1,168(sp)
    80006964:	790a                	ld	s2,160(sp)
    80006966:	69ea                	ld	s3,152(sp)
    80006968:	6129                	addi	sp,sp,192
    8000696a:	8082                	ret
      end_op();
    8000696c:	fffff097          	auipc	ra,0xfffff
    80006970:	93c080e7          	jalr	-1732(ra) # 800052a8 <end_op>
      return -1;
    80006974:	b7e5                	j	8000695c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006976:	f5040513          	addi	a0,s0,-176
    8000697a:	ffffe097          	auipc	ra,0xffffe
    8000697e:	68e080e7          	jalr	1678(ra) # 80005008 <namei>
    80006982:	892a                	mv	s2,a0
    80006984:	c905                	beqz	a0,800069b4 <sys_open+0x13c>
    ilock(ip);
    80006986:	ffffe097          	auipc	ra,0xffffe
    8000698a:	ece080e7          	jalr	-306(ra) # 80004854 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000698e:	04491703          	lh	a4,68(s2)
    80006992:	4785                	li	a5,1
    80006994:	f4f712e3          	bne	a4,a5,800068d8 <sys_open+0x60>
    80006998:	f4c42783          	lw	a5,-180(s0)
    8000699c:	dba1                	beqz	a5,800068ec <sys_open+0x74>
      iunlockput(ip);
    8000699e:	854a                	mv	a0,s2
    800069a0:	ffffe097          	auipc	ra,0xffffe
    800069a4:	116080e7          	jalr	278(ra) # 80004ab6 <iunlockput>
      end_op();
    800069a8:	fffff097          	auipc	ra,0xfffff
    800069ac:	900080e7          	jalr	-1792(ra) # 800052a8 <end_op>
      return -1;
    800069b0:	54fd                	li	s1,-1
    800069b2:	b76d                	j	8000695c <sys_open+0xe4>
      end_op();
    800069b4:	fffff097          	auipc	ra,0xfffff
    800069b8:	8f4080e7          	jalr	-1804(ra) # 800052a8 <end_op>
      return -1;
    800069bc:	54fd                	li	s1,-1
    800069be:	bf79                	j	8000695c <sys_open+0xe4>
    iunlockput(ip);
    800069c0:	854a                	mv	a0,s2
    800069c2:	ffffe097          	auipc	ra,0xffffe
    800069c6:	0f4080e7          	jalr	244(ra) # 80004ab6 <iunlockput>
    end_op();
    800069ca:	fffff097          	auipc	ra,0xfffff
    800069ce:	8de080e7          	jalr	-1826(ra) # 800052a8 <end_op>
    return -1;
    800069d2:	54fd                	li	s1,-1
    800069d4:	b761                	j	8000695c <sys_open+0xe4>
    f->type = FD_DEVICE;
    800069d6:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800069da:	04691783          	lh	a5,70(s2)
    800069de:	02f99223          	sh	a5,36(s3)
    800069e2:	bf2d                	j	8000691c <sys_open+0xa4>
    itrunc(ip);
    800069e4:	854a                	mv	a0,s2
    800069e6:	ffffe097          	auipc	ra,0xffffe
    800069ea:	f7c080e7          	jalr	-132(ra) # 80004962 <itrunc>
    800069ee:	bfb1                	j	8000694a <sys_open+0xd2>
      fileclose(f);
    800069f0:	854e                	mv	a0,s3
    800069f2:	fffff097          	auipc	ra,0xfffff
    800069f6:	d02080e7          	jalr	-766(ra) # 800056f4 <fileclose>
    iunlockput(ip);
    800069fa:	854a                	mv	a0,s2
    800069fc:	ffffe097          	auipc	ra,0xffffe
    80006a00:	0ba080e7          	jalr	186(ra) # 80004ab6 <iunlockput>
    end_op();
    80006a04:	fffff097          	auipc	ra,0xfffff
    80006a08:	8a4080e7          	jalr	-1884(ra) # 800052a8 <end_op>
    return -1;
    80006a0c:	54fd                	li	s1,-1
    80006a0e:	b7b9                	j	8000695c <sys_open+0xe4>

0000000080006a10 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006a10:	7175                	addi	sp,sp,-144
    80006a12:	e506                	sd	ra,136(sp)
    80006a14:	e122                	sd	s0,128(sp)
    80006a16:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006a18:	fffff097          	auipc	ra,0xfffff
    80006a1c:	810080e7          	jalr	-2032(ra) # 80005228 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006a20:	08000613          	li	a2,128
    80006a24:	f7040593          	addi	a1,s0,-144
    80006a28:	4501                	li	a0,0
    80006a2a:	ffffd097          	auipc	ra,0xffffd
    80006a2e:	128080e7          	jalr	296(ra) # 80003b52 <argstr>
    80006a32:	02054963          	bltz	a0,80006a64 <sys_mkdir+0x54>
    80006a36:	4681                	li	a3,0
    80006a38:	4601                	li	a2,0
    80006a3a:	4585                	li	a1,1
    80006a3c:	f7040513          	addi	a0,s0,-144
    80006a40:	00000097          	auipc	ra,0x0
    80006a44:	800080e7          	jalr	-2048(ra) # 80006240 <create>
    80006a48:	cd11                	beqz	a0,80006a64 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006a4a:	ffffe097          	auipc	ra,0xffffe
    80006a4e:	06c080e7          	jalr	108(ra) # 80004ab6 <iunlockput>
  end_op();
    80006a52:	fffff097          	auipc	ra,0xfffff
    80006a56:	856080e7          	jalr	-1962(ra) # 800052a8 <end_op>
  return 0;
    80006a5a:	4501                	li	a0,0
}
    80006a5c:	60aa                	ld	ra,136(sp)
    80006a5e:	640a                	ld	s0,128(sp)
    80006a60:	6149                	addi	sp,sp,144
    80006a62:	8082                	ret
    end_op();
    80006a64:	fffff097          	auipc	ra,0xfffff
    80006a68:	844080e7          	jalr	-1980(ra) # 800052a8 <end_op>
    return -1;
    80006a6c:	557d                	li	a0,-1
    80006a6e:	b7fd                	j	80006a5c <sys_mkdir+0x4c>

0000000080006a70 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006a70:	7135                	addi	sp,sp,-160
    80006a72:	ed06                	sd	ra,152(sp)
    80006a74:	e922                	sd	s0,144(sp)
    80006a76:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006a78:	ffffe097          	auipc	ra,0xffffe
    80006a7c:	7b0080e7          	jalr	1968(ra) # 80005228 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006a80:	08000613          	li	a2,128
    80006a84:	f7040593          	addi	a1,s0,-144
    80006a88:	4501                	li	a0,0
    80006a8a:	ffffd097          	auipc	ra,0xffffd
    80006a8e:	0c8080e7          	jalr	200(ra) # 80003b52 <argstr>
    80006a92:	04054a63          	bltz	a0,80006ae6 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80006a96:	f6c40593          	addi	a1,s0,-148
    80006a9a:	4505                	li	a0,1
    80006a9c:	ffffd097          	auipc	ra,0xffffd
    80006aa0:	072080e7          	jalr	114(ra) # 80003b0e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006aa4:	04054163          	bltz	a0,80006ae6 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80006aa8:	f6840593          	addi	a1,s0,-152
    80006aac:	4509                	li	a0,2
    80006aae:	ffffd097          	auipc	ra,0xffffd
    80006ab2:	060080e7          	jalr	96(ra) # 80003b0e <argint>
     argint(1, &major) < 0 ||
    80006ab6:	02054863          	bltz	a0,80006ae6 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006aba:	f6841683          	lh	a3,-152(s0)
    80006abe:	f6c41603          	lh	a2,-148(s0)
    80006ac2:	458d                	li	a1,3
    80006ac4:	f7040513          	addi	a0,s0,-144
    80006ac8:	fffff097          	auipc	ra,0xfffff
    80006acc:	778080e7          	jalr	1912(ra) # 80006240 <create>
     argint(2, &minor) < 0 ||
    80006ad0:	c919                	beqz	a0,80006ae6 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006ad2:	ffffe097          	auipc	ra,0xffffe
    80006ad6:	fe4080e7          	jalr	-28(ra) # 80004ab6 <iunlockput>
  end_op();
    80006ada:	ffffe097          	auipc	ra,0xffffe
    80006ade:	7ce080e7          	jalr	1998(ra) # 800052a8 <end_op>
  return 0;
    80006ae2:	4501                	li	a0,0
    80006ae4:	a031                	j	80006af0 <sys_mknod+0x80>
    end_op();
    80006ae6:	ffffe097          	auipc	ra,0xffffe
    80006aea:	7c2080e7          	jalr	1986(ra) # 800052a8 <end_op>
    return -1;
    80006aee:	557d                	li	a0,-1
}
    80006af0:	60ea                	ld	ra,152(sp)
    80006af2:	644a                	ld	s0,144(sp)
    80006af4:	610d                	addi	sp,sp,160
    80006af6:	8082                	ret

0000000080006af8 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006af8:	7135                	addi	sp,sp,-160
    80006afa:	ed06                	sd	ra,152(sp)
    80006afc:	e922                	sd	s0,144(sp)
    80006afe:	e526                	sd	s1,136(sp)
    80006b00:	e14a                	sd	s2,128(sp)
    80006b02:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006b04:	ffffb097          	auipc	ra,0xffffb
    80006b08:	f78080e7          	jalr	-136(ra) # 80001a7c <myproc>
    80006b0c:	892a                	mv	s2,a0
  
  begin_op();
    80006b0e:	ffffe097          	auipc	ra,0xffffe
    80006b12:	71a080e7          	jalr	1818(ra) # 80005228 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006b16:	08000613          	li	a2,128
    80006b1a:	f6040593          	addi	a1,s0,-160
    80006b1e:	4501                	li	a0,0
    80006b20:	ffffd097          	auipc	ra,0xffffd
    80006b24:	032080e7          	jalr	50(ra) # 80003b52 <argstr>
    80006b28:	04054b63          	bltz	a0,80006b7e <sys_chdir+0x86>
    80006b2c:	f6040513          	addi	a0,s0,-160
    80006b30:	ffffe097          	auipc	ra,0xffffe
    80006b34:	4d8080e7          	jalr	1240(ra) # 80005008 <namei>
    80006b38:	84aa                	mv	s1,a0
    80006b3a:	c131                	beqz	a0,80006b7e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006b3c:	ffffe097          	auipc	ra,0xffffe
    80006b40:	d18080e7          	jalr	-744(ra) # 80004854 <ilock>
  if(ip->type != T_DIR){
    80006b44:	04449703          	lh	a4,68(s1)
    80006b48:	4785                	li	a5,1
    80006b4a:	04f71063          	bne	a4,a5,80006b8a <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006b4e:	8526                	mv	a0,s1
    80006b50:	ffffe097          	auipc	ra,0xffffe
    80006b54:	dc6080e7          	jalr	-570(ra) # 80004916 <iunlock>
  iput(p->cwd);
    80006b58:	0d093503          	ld	a0,208(s2)
    80006b5c:	ffffe097          	auipc	ra,0xffffe
    80006b60:	eb2080e7          	jalr	-334(ra) # 80004a0e <iput>
  end_op();
    80006b64:	ffffe097          	auipc	ra,0xffffe
    80006b68:	744080e7          	jalr	1860(ra) # 800052a8 <end_op>
  p->cwd = ip;
    80006b6c:	0c993823          	sd	s1,208(s2)
  return 0;
    80006b70:	4501                	li	a0,0
}
    80006b72:	60ea                	ld	ra,152(sp)
    80006b74:	644a                	ld	s0,144(sp)
    80006b76:	64aa                	ld	s1,136(sp)
    80006b78:	690a                	ld	s2,128(sp)
    80006b7a:	610d                	addi	sp,sp,160
    80006b7c:	8082                	ret
    end_op();
    80006b7e:	ffffe097          	auipc	ra,0xffffe
    80006b82:	72a080e7          	jalr	1834(ra) # 800052a8 <end_op>
    return -1;
    80006b86:	557d                	li	a0,-1
    80006b88:	b7ed                	j	80006b72 <sys_chdir+0x7a>
    iunlockput(ip);
    80006b8a:	8526                	mv	a0,s1
    80006b8c:	ffffe097          	auipc	ra,0xffffe
    80006b90:	f2a080e7          	jalr	-214(ra) # 80004ab6 <iunlockput>
    end_op();
    80006b94:	ffffe097          	auipc	ra,0xffffe
    80006b98:	714080e7          	jalr	1812(ra) # 800052a8 <end_op>
    return -1;
    80006b9c:	557d                	li	a0,-1
    80006b9e:	bfd1                	j	80006b72 <sys_chdir+0x7a>

0000000080006ba0 <sys_exec>:

uint64
sys_exec(void)
{
    80006ba0:	7145                	addi	sp,sp,-464
    80006ba2:	e786                	sd	ra,456(sp)
    80006ba4:	e3a2                	sd	s0,448(sp)
    80006ba6:	ff26                	sd	s1,440(sp)
    80006ba8:	fb4a                	sd	s2,432(sp)
    80006baa:	f74e                	sd	s3,424(sp)
    80006bac:	f352                	sd	s4,416(sp)
    80006bae:	ef56                	sd	s5,408(sp)
    80006bb0:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006bb2:	08000613          	li	a2,128
    80006bb6:	f4040593          	addi	a1,s0,-192
    80006bba:	4501                	li	a0,0
    80006bbc:	ffffd097          	auipc	ra,0xffffd
    80006bc0:	f96080e7          	jalr	-106(ra) # 80003b52 <argstr>
    return -1;
    80006bc4:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006bc6:	0c054a63          	bltz	a0,80006c9a <sys_exec+0xfa>
    80006bca:	e3840593          	addi	a1,s0,-456
    80006bce:	4505                	li	a0,1
    80006bd0:	ffffd097          	auipc	ra,0xffffd
    80006bd4:	f60080e7          	jalr	-160(ra) # 80003b30 <argaddr>
    80006bd8:	0c054163          	bltz	a0,80006c9a <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006bdc:	10000613          	li	a2,256
    80006be0:	4581                	li	a1,0
    80006be2:	e4040513          	addi	a0,s0,-448
    80006be6:	ffffa097          	auipc	ra,0xffffa
    80006bea:	0fe080e7          	jalr	254(ra) # 80000ce4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006bee:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006bf2:	89a6                	mv	s3,s1
    80006bf4:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006bf6:	02000a13          	li	s4,32
    80006bfa:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006bfe:	00391793          	slli	a5,s2,0x3
    80006c02:	e3040593          	addi	a1,s0,-464
    80006c06:	e3843503          	ld	a0,-456(s0)
    80006c0a:	953e                	add	a0,a0,a5
    80006c0c:	ffffd097          	auipc	ra,0xffffd
    80006c10:	e68080e7          	jalr	-408(ra) # 80003a74 <fetchaddr>
    80006c14:	02054a63          	bltz	a0,80006c48 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006c18:	e3043783          	ld	a5,-464(s0)
    80006c1c:	c3b9                	beqz	a5,80006c62 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006c1e:	ffffa097          	auipc	ra,0xffffa
    80006c22:	eb8080e7          	jalr	-328(ra) # 80000ad6 <kalloc>
    80006c26:	85aa                	mv	a1,a0
    80006c28:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006c2c:	cd11                	beqz	a0,80006c48 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006c2e:	6605                	lui	a2,0x1
    80006c30:	e3043503          	ld	a0,-464(s0)
    80006c34:	ffffd097          	auipc	ra,0xffffd
    80006c38:	e92080e7          	jalr	-366(ra) # 80003ac6 <fetchstr>
    80006c3c:	00054663          	bltz	a0,80006c48 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006c40:	0905                	addi	s2,s2,1
    80006c42:	09a1                	addi	s3,s3,8
    80006c44:	fb491be3          	bne	s2,s4,80006bfa <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006c48:	10048913          	addi	s2,s1,256
    80006c4c:	6088                	ld	a0,0(s1)
    80006c4e:	c529                	beqz	a0,80006c98 <sys_exec+0xf8>
    kfree(argv[i]);
    80006c50:	ffffa097          	auipc	ra,0xffffa
    80006c54:	d8a080e7          	jalr	-630(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006c58:	04a1                	addi	s1,s1,8
    80006c5a:	ff2499e3          	bne	s1,s2,80006c4c <sys_exec+0xac>
  return -1;
    80006c5e:	597d                	li	s2,-1
    80006c60:	a82d                	j	80006c9a <sys_exec+0xfa>
      argv[i] = 0;
    80006c62:	0a8e                	slli	s5,s5,0x3
    80006c64:	fc040793          	addi	a5,s0,-64
    80006c68:	9abe                	add	s5,s5,a5
    80006c6a:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006c6e:	e4040593          	addi	a1,s0,-448
    80006c72:	f4040513          	addi	a0,s0,-192
    80006c76:	fffff097          	auipc	ra,0xfffff
    80006c7a:	0dc080e7          	jalr	220(ra) # 80005d52 <exec>
    80006c7e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006c80:	10048993          	addi	s3,s1,256
    80006c84:	6088                	ld	a0,0(s1)
    80006c86:	c911                	beqz	a0,80006c9a <sys_exec+0xfa>
    kfree(argv[i]);
    80006c88:	ffffa097          	auipc	ra,0xffffa
    80006c8c:	d52080e7          	jalr	-686(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006c90:	04a1                	addi	s1,s1,8
    80006c92:	ff3499e3          	bne	s1,s3,80006c84 <sys_exec+0xe4>
    80006c96:	a011                	j	80006c9a <sys_exec+0xfa>
  return -1;
    80006c98:	597d                	li	s2,-1
}
    80006c9a:	854a                	mv	a0,s2
    80006c9c:	60be                	ld	ra,456(sp)
    80006c9e:	641e                	ld	s0,448(sp)
    80006ca0:	74fa                	ld	s1,440(sp)
    80006ca2:	795a                	ld	s2,432(sp)
    80006ca4:	79ba                	ld	s3,424(sp)
    80006ca6:	7a1a                	ld	s4,416(sp)
    80006ca8:	6afa                	ld	s5,408(sp)
    80006caa:	6179                	addi	sp,sp,464
    80006cac:	8082                	ret

0000000080006cae <sys_pipe>:

uint64
sys_pipe(void)
{
    80006cae:	7139                	addi	sp,sp,-64
    80006cb0:	fc06                	sd	ra,56(sp)
    80006cb2:	f822                	sd	s0,48(sp)
    80006cb4:	f426                	sd	s1,40(sp)
    80006cb6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006cb8:	ffffb097          	auipc	ra,0xffffb
    80006cbc:	dc4080e7          	jalr	-572(ra) # 80001a7c <myproc>
    80006cc0:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006cc2:	fd840593          	addi	a1,s0,-40
    80006cc6:	4501                	li	a0,0
    80006cc8:	ffffd097          	auipc	ra,0xffffd
    80006ccc:	e68080e7          	jalr	-408(ra) # 80003b30 <argaddr>
    return -1;
    80006cd0:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006cd2:	0e054063          	bltz	a0,80006db2 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006cd6:	fc840593          	addi	a1,s0,-56
    80006cda:	fd040513          	addi	a0,s0,-48
    80006cde:	fffff097          	auipc	ra,0xfffff
    80006ce2:	d46080e7          	jalr	-698(ra) # 80005a24 <pipealloc>
    return -1;
    80006ce6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006ce8:	0c054563          	bltz	a0,80006db2 <sys_pipe+0x104>
  fd0 = -1;
    80006cec:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006cf0:	fd043503          	ld	a0,-48(s0)
    80006cf4:	fffff097          	auipc	ra,0xfffff
    80006cf8:	50a080e7          	jalr	1290(ra) # 800061fe <fdalloc>
    80006cfc:	fca42223          	sw	a0,-60(s0)
    80006d00:	08054c63          	bltz	a0,80006d98 <sys_pipe+0xea>
    80006d04:	fc843503          	ld	a0,-56(s0)
    80006d08:	fffff097          	auipc	ra,0xfffff
    80006d0c:	4f6080e7          	jalr	1270(ra) # 800061fe <fdalloc>
    80006d10:	fca42023          	sw	a0,-64(s0)
    80006d14:	06054863          	bltz	a0,80006d84 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006d18:	4691                	li	a3,4
    80006d1a:	fc440613          	addi	a2,s0,-60
    80006d1e:	fd843583          	ld	a1,-40(s0)
    80006d22:	60a8                	ld	a0,64(s1)
    80006d24:	ffffb097          	auipc	ra,0xffffb
    80006d28:	940080e7          	jalr	-1728(ra) # 80001664 <copyout>
    80006d2c:	02054063          	bltz	a0,80006d4c <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006d30:	4691                	li	a3,4
    80006d32:	fc040613          	addi	a2,s0,-64
    80006d36:	fd843583          	ld	a1,-40(s0)
    80006d3a:	0591                	addi	a1,a1,4
    80006d3c:	60a8                	ld	a0,64(s1)
    80006d3e:	ffffb097          	auipc	ra,0xffffb
    80006d42:	926080e7          	jalr	-1754(ra) # 80001664 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006d46:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006d48:	06055563          	bgez	a0,80006db2 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006d4c:	fc442783          	lw	a5,-60(s0)
    80006d50:	07a9                	addi	a5,a5,10
    80006d52:	078e                	slli	a5,a5,0x3
    80006d54:	97a6                	add	a5,a5,s1
    80006d56:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006d5a:	fc042503          	lw	a0,-64(s0)
    80006d5e:	0529                	addi	a0,a0,10
    80006d60:	050e                	slli	a0,a0,0x3
    80006d62:	9526                	add	a0,a0,s1
    80006d64:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006d68:	fd043503          	ld	a0,-48(s0)
    80006d6c:	fffff097          	auipc	ra,0xfffff
    80006d70:	988080e7          	jalr	-1656(ra) # 800056f4 <fileclose>
    fileclose(wf);
    80006d74:	fc843503          	ld	a0,-56(s0)
    80006d78:	fffff097          	auipc	ra,0xfffff
    80006d7c:	97c080e7          	jalr	-1668(ra) # 800056f4 <fileclose>
    return -1;
    80006d80:	57fd                	li	a5,-1
    80006d82:	a805                	j	80006db2 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006d84:	fc442783          	lw	a5,-60(s0)
    80006d88:	0007c863          	bltz	a5,80006d98 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006d8c:	00a78513          	addi	a0,a5,10
    80006d90:	050e                	slli	a0,a0,0x3
    80006d92:	9526                	add	a0,a0,s1
    80006d94:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006d98:	fd043503          	ld	a0,-48(s0)
    80006d9c:	fffff097          	auipc	ra,0xfffff
    80006da0:	958080e7          	jalr	-1704(ra) # 800056f4 <fileclose>
    fileclose(wf);
    80006da4:	fc843503          	ld	a0,-56(s0)
    80006da8:	fffff097          	auipc	ra,0xfffff
    80006dac:	94c080e7          	jalr	-1716(ra) # 800056f4 <fileclose>
    return -1;
    80006db0:	57fd                	li	a5,-1
}
    80006db2:	853e                	mv	a0,a5
    80006db4:	70e2                	ld	ra,56(sp)
    80006db6:	7442                	ld	s0,48(sp)
    80006db8:	74a2                	ld	s1,40(sp)
    80006dba:	6121                	addi	sp,sp,64
    80006dbc:	8082                	ret
	...

0000000080006dc0 <kernelvec>:
    80006dc0:	7111                	addi	sp,sp,-256
    80006dc2:	e006                	sd	ra,0(sp)
    80006dc4:	e40a                	sd	sp,8(sp)
    80006dc6:	e80e                	sd	gp,16(sp)
    80006dc8:	ec12                	sd	tp,24(sp)
    80006dca:	f016                	sd	t0,32(sp)
    80006dcc:	f41a                	sd	t1,40(sp)
    80006dce:	f81e                	sd	t2,48(sp)
    80006dd0:	fc22                	sd	s0,56(sp)
    80006dd2:	e0a6                	sd	s1,64(sp)
    80006dd4:	e4aa                	sd	a0,72(sp)
    80006dd6:	e8ae                	sd	a1,80(sp)
    80006dd8:	ecb2                	sd	a2,88(sp)
    80006dda:	f0b6                	sd	a3,96(sp)
    80006ddc:	f4ba                	sd	a4,104(sp)
    80006dde:	f8be                	sd	a5,112(sp)
    80006de0:	fcc2                	sd	a6,120(sp)
    80006de2:	e146                	sd	a7,128(sp)
    80006de4:	e54a                	sd	s2,136(sp)
    80006de6:	e94e                	sd	s3,144(sp)
    80006de8:	ed52                	sd	s4,152(sp)
    80006dea:	f156                	sd	s5,160(sp)
    80006dec:	f55a                	sd	s6,168(sp)
    80006dee:	f95e                	sd	s7,176(sp)
    80006df0:	fd62                	sd	s8,184(sp)
    80006df2:	e1e6                	sd	s9,192(sp)
    80006df4:	e5ea                	sd	s10,200(sp)
    80006df6:	e9ee                	sd	s11,208(sp)
    80006df8:	edf2                	sd	t3,216(sp)
    80006dfa:	f1f6                	sd	t4,224(sp)
    80006dfc:	f5fa                	sd	t5,232(sp)
    80006dfe:	f9fe                	sd	t6,240(sp)
    80006e00:	b15fc0ef          	jal	ra,80003914 <kerneltrap>
    80006e04:	6082                	ld	ra,0(sp)
    80006e06:	6122                	ld	sp,8(sp)
    80006e08:	61c2                	ld	gp,16(sp)
    80006e0a:	7282                	ld	t0,32(sp)
    80006e0c:	7322                	ld	t1,40(sp)
    80006e0e:	73c2                	ld	t2,48(sp)
    80006e10:	7462                	ld	s0,56(sp)
    80006e12:	6486                	ld	s1,64(sp)
    80006e14:	6526                	ld	a0,72(sp)
    80006e16:	65c6                	ld	a1,80(sp)
    80006e18:	6666                	ld	a2,88(sp)
    80006e1a:	7686                	ld	a3,96(sp)
    80006e1c:	7726                	ld	a4,104(sp)
    80006e1e:	77c6                	ld	a5,112(sp)
    80006e20:	7866                	ld	a6,120(sp)
    80006e22:	688a                	ld	a7,128(sp)
    80006e24:	692a                	ld	s2,136(sp)
    80006e26:	69ca                	ld	s3,144(sp)
    80006e28:	6a6a                	ld	s4,152(sp)
    80006e2a:	7a8a                	ld	s5,160(sp)
    80006e2c:	7b2a                	ld	s6,168(sp)
    80006e2e:	7bca                	ld	s7,176(sp)
    80006e30:	7c6a                	ld	s8,184(sp)
    80006e32:	6c8e                	ld	s9,192(sp)
    80006e34:	6d2e                	ld	s10,200(sp)
    80006e36:	6dce                	ld	s11,208(sp)
    80006e38:	6e6e                	ld	t3,216(sp)
    80006e3a:	7e8e                	ld	t4,224(sp)
    80006e3c:	7f2e                	ld	t5,232(sp)
    80006e3e:	7fce                	ld	t6,240(sp)
    80006e40:	6111                	addi	sp,sp,256
    80006e42:	10200073          	sret
    80006e46:	00000013          	nop
    80006e4a:	00000013          	nop
    80006e4e:	0001                	nop

0000000080006e50 <timervec>:
    80006e50:	34051573          	csrrw	a0,mscratch,a0
    80006e54:	e10c                	sd	a1,0(a0)
    80006e56:	e510                	sd	a2,8(a0)
    80006e58:	e914                	sd	a3,16(a0)
    80006e5a:	6d0c                	ld	a1,24(a0)
    80006e5c:	7110                	ld	a2,32(a0)
    80006e5e:	6194                	ld	a3,0(a1)
    80006e60:	96b2                	add	a3,a3,a2
    80006e62:	e194                	sd	a3,0(a1)
    80006e64:	4589                	li	a1,2
    80006e66:	14459073          	csrw	sip,a1
    80006e6a:	6914                	ld	a3,16(a0)
    80006e6c:	6510                	ld	a2,8(a0)
    80006e6e:	610c                	ld	a1,0(a0)
    80006e70:	34051573          	csrrw	a0,mscratch,a0
    80006e74:	30200073          	mret
	...

0000000080006e7a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006e7a:	1141                	addi	sp,sp,-16
    80006e7c:	e422                	sd	s0,8(sp)
    80006e7e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006e80:	0c0007b7          	lui	a5,0xc000
    80006e84:	4705                	li	a4,1
    80006e86:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006e88:	c3d8                	sw	a4,4(a5)
}
    80006e8a:	6422                	ld	s0,8(sp)
    80006e8c:	0141                	addi	sp,sp,16
    80006e8e:	8082                	ret

0000000080006e90 <plicinithart>:

void
plicinithart(void)
{
    80006e90:	1141                	addi	sp,sp,-16
    80006e92:	e406                	sd	ra,8(sp)
    80006e94:	e022                	sd	s0,0(sp)
    80006e96:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006e98:	ffffb097          	auipc	ra,0xffffb
    80006e9c:	bb0080e7          	jalr	-1104(ra) # 80001a48 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006ea0:	0085171b          	slliw	a4,a0,0x8
    80006ea4:	0c0027b7          	lui	a5,0xc002
    80006ea8:	97ba                	add	a5,a5,a4
    80006eaa:	40200713          	li	a4,1026
    80006eae:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006eb2:	00d5151b          	slliw	a0,a0,0xd
    80006eb6:	0c2017b7          	lui	a5,0xc201
    80006eba:	953e                	add	a0,a0,a5
    80006ebc:	00052023          	sw	zero,0(a0)
}
    80006ec0:	60a2                	ld	ra,8(sp)
    80006ec2:	6402                	ld	s0,0(sp)
    80006ec4:	0141                	addi	sp,sp,16
    80006ec6:	8082                	ret

0000000080006ec8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006ec8:	1141                	addi	sp,sp,-16
    80006eca:	e406                	sd	ra,8(sp)
    80006ecc:	e022                	sd	s0,0(sp)
    80006ece:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006ed0:	ffffb097          	auipc	ra,0xffffb
    80006ed4:	b78080e7          	jalr	-1160(ra) # 80001a48 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006ed8:	00d5179b          	slliw	a5,a0,0xd
    80006edc:	0c201537          	lui	a0,0xc201
    80006ee0:	953e                	add	a0,a0,a5
  return irq;
}
    80006ee2:	4148                	lw	a0,4(a0)
    80006ee4:	60a2                	ld	ra,8(sp)
    80006ee6:	6402                	ld	s0,0(sp)
    80006ee8:	0141                	addi	sp,sp,16
    80006eea:	8082                	ret

0000000080006eec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006eec:	1101                	addi	sp,sp,-32
    80006eee:	ec06                	sd	ra,24(sp)
    80006ef0:	e822                	sd	s0,16(sp)
    80006ef2:	e426                	sd	s1,8(sp)
    80006ef4:	1000                	addi	s0,sp,32
    80006ef6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006ef8:	ffffb097          	auipc	ra,0xffffb
    80006efc:	b50080e7          	jalr	-1200(ra) # 80001a48 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006f00:	00d5151b          	slliw	a0,a0,0xd
    80006f04:	0c2017b7          	lui	a5,0xc201
    80006f08:	97aa                	add	a5,a5,a0
    80006f0a:	c3c4                	sw	s1,4(a5)
}
    80006f0c:	60e2                	ld	ra,24(sp)
    80006f0e:	6442                	ld	s0,16(sp)
    80006f10:	64a2                	ld	s1,8(sp)
    80006f12:	6105                	addi	sp,sp,32
    80006f14:	8082                	ret

0000000080006f16 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006f16:	1141                	addi	sp,sp,-16
    80006f18:	e406                	sd	ra,8(sp)
    80006f1a:	e022                	sd	s0,0(sp)
    80006f1c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006f1e:	479d                	li	a5,7
    80006f20:	06a7c963          	blt	a5,a0,80006f92 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006f24:	00038797          	auipc	a5,0x38
    80006f28:	0dc78793          	addi	a5,a5,220 # 8003f000 <disk>
    80006f2c:	00a78733          	add	a4,a5,a0
    80006f30:	6789                	lui	a5,0x2
    80006f32:	97ba                	add	a5,a5,a4
    80006f34:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006f38:	e7ad                	bnez	a5,80006fa2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006f3a:	00451793          	slli	a5,a0,0x4
    80006f3e:	0003a717          	auipc	a4,0x3a
    80006f42:	0c270713          	addi	a4,a4,194 # 80041000 <disk+0x2000>
    80006f46:	6314                	ld	a3,0(a4)
    80006f48:	96be                	add	a3,a3,a5
    80006f4a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006f4e:	6314                	ld	a3,0(a4)
    80006f50:	96be                	add	a3,a3,a5
    80006f52:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006f56:	6314                	ld	a3,0(a4)
    80006f58:	96be                	add	a3,a3,a5
    80006f5a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006f5e:	6318                	ld	a4,0(a4)
    80006f60:	97ba                	add	a5,a5,a4
    80006f62:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006f66:	00038797          	auipc	a5,0x38
    80006f6a:	09a78793          	addi	a5,a5,154 # 8003f000 <disk>
    80006f6e:	97aa                	add	a5,a5,a0
    80006f70:	6509                	lui	a0,0x2
    80006f72:	953e                	add	a0,a0,a5
    80006f74:	4785                	li	a5,1
    80006f76:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006f7a:	0003a517          	auipc	a0,0x3a
    80006f7e:	09e50513          	addi	a0,a0,158 # 80041018 <disk+0x2018>
    80006f82:	ffffb097          	auipc	ra,0xffffb
    80006f86:	65a080e7          	jalr	1626(ra) # 800025dc <wakeup>
}
    80006f8a:	60a2                	ld	ra,8(sp)
    80006f8c:	6402                	ld	s0,0(sp)
    80006f8e:	0141                	addi	sp,sp,16
    80006f90:	8082                	ret
    panic("free_desc 1");
    80006f92:	00003517          	auipc	a0,0x3
    80006f96:	9fe50513          	addi	a0,a0,-1538 # 80009990 <syscalls+0x358>
    80006f9a:	ffff9097          	auipc	ra,0xffff9
    80006f9e:	594080e7          	jalr	1428(ra) # 8000052e <panic>
    panic("free_desc 2");
    80006fa2:	00003517          	auipc	a0,0x3
    80006fa6:	9fe50513          	addi	a0,a0,-1538 # 800099a0 <syscalls+0x368>
    80006faa:	ffff9097          	auipc	ra,0xffff9
    80006fae:	584080e7          	jalr	1412(ra) # 8000052e <panic>

0000000080006fb2 <virtio_disk_init>:
{
    80006fb2:	1101                	addi	sp,sp,-32
    80006fb4:	ec06                	sd	ra,24(sp)
    80006fb6:	e822                	sd	s0,16(sp)
    80006fb8:	e426                	sd	s1,8(sp)
    80006fba:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006fbc:	00003597          	auipc	a1,0x3
    80006fc0:	9f458593          	addi	a1,a1,-1548 # 800099b0 <syscalls+0x378>
    80006fc4:	0003a517          	auipc	a0,0x3a
    80006fc8:	16450513          	addi	a0,a0,356 # 80041128 <disk+0x2128>
    80006fcc:	ffffa097          	auipc	ra,0xffffa
    80006fd0:	b6a080e7          	jalr	-1174(ra) # 80000b36 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006fd4:	100017b7          	lui	a5,0x10001
    80006fd8:	4398                	lw	a4,0(a5)
    80006fda:	2701                	sext.w	a4,a4
    80006fdc:	747277b7          	lui	a5,0x74727
    80006fe0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006fe4:	0ef71163          	bne	a4,a5,800070c6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006fe8:	100017b7          	lui	a5,0x10001
    80006fec:	43dc                	lw	a5,4(a5)
    80006fee:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006ff0:	4705                	li	a4,1
    80006ff2:	0ce79a63          	bne	a5,a4,800070c6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006ff6:	100017b7          	lui	a5,0x10001
    80006ffa:	479c                	lw	a5,8(a5)
    80006ffc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006ffe:	4709                	li	a4,2
    80007000:	0ce79363          	bne	a5,a4,800070c6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80007004:	100017b7          	lui	a5,0x10001
    80007008:	47d8                	lw	a4,12(a5)
    8000700a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000700c:	554d47b7          	lui	a5,0x554d4
    80007010:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80007014:	0af71963          	bne	a4,a5,800070c6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80007018:	100017b7          	lui	a5,0x10001
    8000701c:	4705                	li	a4,1
    8000701e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007020:	470d                	li	a4,3
    80007022:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80007024:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80007026:	c7ffe737          	lui	a4,0xc7ffe
    8000702a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fbc75f>
    8000702e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80007030:	2701                	sext.w	a4,a4
    80007032:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007034:	472d                	li	a4,11
    80007036:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007038:	473d                	li	a4,15
    8000703a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000703c:	6705                	lui	a4,0x1
    8000703e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80007040:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80007044:	5bdc                	lw	a5,52(a5)
    80007046:	2781                	sext.w	a5,a5
  if(max == 0)
    80007048:	c7d9                	beqz	a5,800070d6 <virtio_disk_init+0x124>
  if(max < NUM)
    8000704a:	471d                	li	a4,7
    8000704c:	08f77d63          	bgeu	a4,a5,800070e6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80007050:	100014b7          	lui	s1,0x10001
    80007054:	47a1                	li	a5,8
    80007056:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80007058:	6609                	lui	a2,0x2
    8000705a:	4581                	li	a1,0
    8000705c:	00038517          	auipc	a0,0x38
    80007060:	fa450513          	addi	a0,a0,-92 # 8003f000 <disk>
    80007064:	ffffa097          	auipc	ra,0xffffa
    80007068:	c80080e7          	jalr	-896(ra) # 80000ce4 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000706c:	00038717          	auipc	a4,0x38
    80007070:	f9470713          	addi	a4,a4,-108 # 8003f000 <disk>
    80007074:	00c75793          	srli	a5,a4,0xc
    80007078:	2781                	sext.w	a5,a5
    8000707a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000707c:	0003a797          	auipc	a5,0x3a
    80007080:	f8478793          	addi	a5,a5,-124 # 80041000 <disk+0x2000>
    80007084:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80007086:	00038717          	auipc	a4,0x38
    8000708a:	ffa70713          	addi	a4,a4,-6 # 8003f080 <disk+0x80>
    8000708e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80007090:	00039717          	auipc	a4,0x39
    80007094:	f7070713          	addi	a4,a4,-144 # 80040000 <disk+0x1000>
    80007098:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000709a:	4705                	li	a4,1
    8000709c:	00e78c23          	sb	a4,24(a5)
    800070a0:	00e78ca3          	sb	a4,25(a5)
    800070a4:	00e78d23          	sb	a4,26(a5)
    800070a8:	00e78da3          	sb	a4,27(a5)
    800070ac:	00e78e23          	sb	a4,28(a5)
    800070b0:	00e78ea3          	sb	a4,29(a5)
    800070b4:	00e78f23          	sb	a4,30(a5)
    800070b8:	00e78fa3          	sb	a4,31(a5)
}
    800070bc:	60e2                	ld	ra,24(sp)
    800070be:	6442                	ld	s0,16(sp)
    800070c0:	64a2                	ld	s1,8(sp)
    800070c2:	6105                	addi	sp,sp,32
    800070c4:	8082                	ret
    panic("could not find virtio disk");
    800070c6:	00003517          	auipc	a0,0x3
    800070ca:	8fa50513          	addi	a0,a0,-1798 # 800099c0 <syscalls+0x388>
    800070ce:	ffff9097          	auipc	ra,0xffff9
    800070d2:	460080e7          	jalr	1120(ra) # 8000052e <panic>
    panic("virtio disk has no queue 0");
    800070d6:	00003517          	auipc	a0,0x3
    800070da:	90a50513          	addi	a0,a0,-1782 # 800099e0 <syscalls+0x3a8>
    800070de:	ffff9097          	auipc	ra,0xffff9
    800070e2:	450080e7          	jalr	1104(ra) # 8000052e <panic>
    panic("virtio disk max queue too short");
    800070e6:	00003517          	auipc	a0,0x3
    800070ea:	91a50513          	addi	a0,a0,-1766 # 80009a00 <syscalls+0x3c8>
    800070ee:	ffff9097          	auipc	ra,0xffff9
    800070f2:	440080e7          	jalr	1088(ra) # 8000052e <panic>

00000000800070f6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800070f6:	7119                	addi	sp,sp,-128
    800070f8:	fc86                	sd	ra,120(sp)
    800070fa:	f8a2                	sd	s0,112(sp)
    800070fc:	f4a6                	sd	s1,104(sp)
    800070fe:	f0ca                	sd	s2,96(sp)
    80007100:	ecce                	sd	s3,88(sp)
    80007102:	e8d2                	sd	s4,80(sp)
    80007104:	e4d6                	sd	s5,72(sp)
    80007106:	e0da                	sd	s6,64(sp)
    80007108:	fc5e                	sd	s7,56(sp)
    8000710a:	f862                	sd	s8,48(sp)
    8000710c:	f466                	sd	s9,40(sp)
    8000710e:	f06a                	sd	s10,32(sp)
    80007110:	ec6e                	sd	s11,24(sp)
    80007112:	0100                	addi	s0,sp,128
    80007114:	8aaa                	mv	s5,a0
    80007116:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80007118:	00c52c83          	lw	s9,12(a0)
    8000711c:	001c9c9b          	slliw	s9,s9,0x1
    80007120:	1c82                	slli	s9,s9,0x20
    80007122:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80007126:	0003a517          	auipc	a0,0x3a
    8000712a:	00250513          	addi	a0,a0,2 # 80041128 <disk+0x2128>
    8000712e:	ffffa097          	auipc	ra,0xffffa
    80007132:	a98080e7          	jalr	-1384(ra) # 80000bc6 <acquire>
  for(int i = 0; i < 3; i++){
    80007136:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80007138:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000713a:	00038c17          	auipc	s8,0x38
    8000713e:	ec6c0c13          	addi	s8,s8,-314 # 8003f000 <disk>
    80007142:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80007144:	4b0d                	li	s6,3
    80007146:	a0ad                	j	800071b0 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80007148:	00fc0733          	add	a4,s8,a5
    8000714c:	975e                	add	a4,a4,s7
    8000714e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80007152:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80007154:	0207c563          	bltz	a5,8000717e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80007158:	2905                	addiw	s2,s2,1
    8000715a:	0611                	addi	a2,a2,4
    8000715c:	19690d63          	beq	s2,s6,800072f6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80007160:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80007162:	0003a717          	auipc	a4,0x3a
    80007166:	eb670713          	addi	a4,a4,-330 # 80041018 <disk+0x2018>
    8000716a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000716c:	00074683          	lbu	a3,0(a4)
    80007170:	fee1                	bnez	a3,80007148 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80007172:	2785                	addiw	a5,a5,1
    80007174:	0705                	addi	a4,a4,1
    80007176:	fe979be3          	bne	a5,s1,8000716c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000717a:	57fd                	li	a5,-1
    8000717c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000717e:	01205d63          	blez	s2,80007198 <virtio_disk_rw+0xa2>
    80007182:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80007184:	000a2503          	lw	a0,0(s4)
    80007188:	00000097          	auipc	ra,0x0
    8000718c:	d8e080e7          	jalr	-626(ra) # 80006f16 <free_desc>
      for(int j = 0; j < i; j++)
    80007190:	2d85                	addiw	s11,s11,1
    80007192:	0a11                	addi	s4,s4,4
    80007194:	ffb918e3          	bne	s2,s11,80007184 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80007198:	0003a597          	auipc	a1,0x3a
    8000719c:	f9058593          	addi	a1,a1,-112 # 80041128 <disk+0x2128>
    800071a0:	0003a517          	auipc	a0,0x3a
    800071a4:	e7850513          	addi	a0,a0,-392 # 80041018 <disk+0x2018>
    800071a8:	ffffb097          	auipc	ra,0xffffb
    800071ac:	2a0080e7          	jalr	672(ra) # 80002448 <sleep>
  for(int i = 0; i < 3; i++){
    800071b0:	f8040a13          	addi	s4,s0,-128
{
    800071b4:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800071b6:	894e                	mv	s2,s3
    800071b8:	b765                	j	80007160 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800071ba:	0003a697          	auipc	a3,0x3a
    800071be:	e466b683          	ld	a3,-442(a3) # 80041000 <disk+0x2000>
    800071c2:	96ba                	add	a3,a3,a4
    800071c4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800071c8:	00038817          	auipc	a6,0x38
    800071cc:	e3880813          	addi	a6,a6,-456 # 8003f000 <disk>
    800071d0:	0003a697          	auipc	a3,0x3a
    800071d4:	e3068693          	addi	a3,a3,-464 # 80041000 <disk+0x2000>
    800071d8:	6290                	ld	a2,0(a3)
    800071da:	963a                	add	a2,a2,a4
    800071dc:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800071e0:	0015e593          	ori	a1,a1,1
    800071e4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800071e8:	f8842603          	lw	a2,-120(s0)
    800071ec:	628c                	ld	a1,0(a3)
    800071ee:	972e                	add	a4,a4,a1
    800071f0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800071f4:	20050593          	addi	a1,a0,512
    800071f8:	0592                	slli	a1,a1,0x4
    800071fa:	95c2                	add	a1,a1,a6
    800071fc:	577d                	li	a4,-1
    800071fe:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80007202:	00461713          	slli	a4,a2,0x4
    80007206:	6290                	ld	a2,0(a3)
    80007208:	963a                	add	a2,a2,a4
    8000720a:	03078793          	addi	a5,a5,48
    8000720e:	97c2                	add	a5,a5,a6
    80007210:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80007212:	629c                	ld	a5,0(a3)
    80007214:	97ba                	add	a5,a5,a4
    80007216:	4605                	li	a2,1
    80007218:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000721a:	629c                	ld	a5,0(a3)
    8000721c:	97ba                	add	a5,a5,a4
    8000721e:	4809                	li	a6,2
    80007220:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80007224:	629c                	ld	a5,0(a3)
    80007226:	973e                	add	a4,a4,a5
    80007228:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000722c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80007230:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80007234:	6698                	ld	a4,8(a3)
    80007236:	00275783          	lhu	a5,2(a4)
    8000723a:	8b9d                	andi	a5,a5,7
    8000723c:	0786                	slli	a5,a5,0x1
    8000723e:	97ba                	add	a5,a5,a4
    80007240:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80007244:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80007248:	6698                	ld	a4,8(a3)
    8000724a:	00275783          	lhu	a5,2(a4)
    8000724e:	2785                	addiw	a5,a5,1
    80007250:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80007254:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80007258:	100017b7          	lui	a5,0x10001
    8000725c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80007260:	004aa783          	lw	a5,4(s5)
    80007264:	02c79163          	bne	a5,a2,80007286 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80007268:	0003a917          	auipc	s2,0x3a
    8000726c:	ec090913          	addi	s2,s2,-320 # 80041128 <disk+0x2128>
  while(b->disk == 1) {
    80007270:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80007272:	85ca                	mv	a1,s2
    80007274:	8556                	mv	a0,s5
    80007276:	ffffb097          	auipc	ra,0xffffb
    8000727a:	1d2080e7          	jalr	466(ra) # 80002448 <sleep>
  while(b->disk == 1) {
    8000727e:	004aa783          	lw	a5,4(s5)
    80007282:	fe9788e3          	beq	a5,s1,80007272 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80007286:	f8042903          	lw	s2,-128(s0)
    8000728a:	20090793          	addi	a5,s2,512
    8000728e:	00479713          	slli	a4,a5,0x4
    80007292:	00038797          	auipc	a5,0x38
    80007296:	d6e78793          	addi	a5,a5,-658 # 8003f000 <disk>
    8000729a:	97ba                	add	a5,a5,a4
    8000729c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800072a0:	0003a997          	auipc	s3,0x3a
    800072a4:	d6098993          	addi	s3,s3,-672 # 80041000 <disk+0x2000>
    800072a8:	00491713          	slli	a4,s2,0x4
    800072ac:	0009b783          	ld	a5,0(s3)
    800072b0:	97ba                	add	a5,a5,a4
    800072b2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800072b6:	854a                	mv	a0,s2
    800072b8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800072bc:	00000097          	auipc	ra,0x0
    800072c0:	c5a080e7          	jalr	-934(ra) # 80006f16 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800072c4:	8885                	andi	s1,s1,1
    800072c6:	f0ed                	bnez	s1,800072a8 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800072c8:	0003a517          	auipc	a0,0x3a
    800072cc:	e6050513          	addi	a0,a0,-416 # 80041128 <disk+0x2128>
    800072d0:	ffffa097          	auipc	ra,0xffffa
    800072d4:	9cc080e7          	jalr	-1588(ra) # 80000c9c <release>
}
    800072d8:	70e6                	ld	ra,120(sp)
    800072da:	7446                	ld	s0,112(sp)
    800072dc:	74a6                	ld	s1,104(sp)
    800072de:	7906                	ld	s2,96(sp)
    800072e0:	69e6                	ld	s3,88(sp)
    800072e2:	6a46                	ld	s4,80(sp)
    800072e4:	6aa6                	ld	s5,72(sp)
    800072e6:	6b06                	ld	s6,64(sp)
    800072e8:	7be2                	ld	s7,56(sp)
    800072ea:	7c42                	ld	s8,48(sp)
    800072ec:	7ca2                	ld	s9,40(sp)
    800072ee:	7d02                	ld	s10,32(sp)
    800072f0:	6de2                	ld	s11,24(sp)
    800072f2:	6109                	addi	sp,sp,128
    800072f4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800072f6:	f8042503          	lw	a0,-128(s0)
    800072fa:	20050793          	addi	a5,a0,512
    800072fe:	0792                	slli	a5,a5,0x4
  if(write)
    80007300:	00038817          	auipc	a6,0x38
    80007304:	d0080813          	addi	a6,a6,-768 # 8003f000 <disk>
    80007308:	00f80733          	add	a4,a6,a5
    8000730c:	01a036b3          	snez	a3,s10
    80007310:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80007314:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80007318:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000731c:	7679                	lui	a2,0xffffe
    8000731e:	963e                	add	a2,a2,a5
    80007320:	0003a697          	auipc	a3,0x3a
    80007324:	ce068693          	addi	a3,a3,-800 # 80041000 <disk+0x2000>
    80007328:	6298                	ld	a4,0(a3)
    8000732a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000732c:	0a878593          	addi	a1,a5,168
    80007330:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007332:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80007334:	6298                	ld	a4,0(a3)
    80007336:	9732                	add	a4,a4,a2
    80007338:	45c1                	li	a1,16
    8000733a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000733c:	6298                	ld	a4,0(a3)
    8000733e:	9732                	add	a4,a4,a2
    80007340:	4585                	li	a1,1
    80007342:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007346:	f8442703          	lw	a4,-124(s0)
    8000734a:	628c                	ld	a1,0(a3)
    8000734c:	962e                	add	a2,a2,a1
    8000734e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffbc00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80007352:	0712                	slli	a4,a4,0x4
    80007354:	6290                	ld	a2,0(a3)
    80007356:	963a                	add	a2,a2,a4
    80007358:	058a8593          	addi	a1,s5,88
    8000735c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000735e:	6294                	ld	a3,0(a3)
    80007360:	96ba                	add	a3,a3,a4
    80007362:	40000613          	li	a2,1024
    80007366:	c690                	sw	a2,8(a3)
  if(write)
    80007368:	e40d19e3          	bnez	s10,800071ba <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000736c:	0003a697          	auipc	a3,0x3a
    80007370:	c946b683          	ld	a3,-876(a3) # 80041000 <disk+0x2000>
    80007374:	96ba                	add	a3,a3,a4
    80007376:	4609                	li	a2,2
    80007378:	00c69623          	sh	a2,12(a3)
    8000737c:	b5b1                	j	800071c8 <virtio_disk_rw+0xd2>

000000008000737e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000737e:	1101                	addi	sp,sp,-32
    80007380:	ec06                	sd	ra,24(sp)
    80007382:	e822                	sd	s0,16(sp)
    80007384:	e426                	sd	s1,8(sp)
    80007386:	e04a                	sd	s2,0(sp)
    80007388:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000738a:	0003a517          	auipc	a0,0x3a
    8000738e:	d9e50513          	addi	a0,a0,-610 # 80041128 <disk+0x2128>
    80007392:	ffffa097          	auipc	ra,0xffffa
    80007396:	834080e7          	jalr	-1996(ra) # 80000bc6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000739a:	10001737          	lui	a4,0x10001
    8000739e:	533c                	lw	a5,96(a4)
    800073a0:	8b8d                	andi	a5,a5,3
    800073a2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800073a4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800073a8:	0003a797          	auipc	a5,0x3a
    800073ac:	c5878793          	addi	a5,a5,-936 # 80041000 <disk+0x2000>
    800073b0:	6b94                	ld	a3,16(a5)
    800073b2:	0207d703          	lhu	a4,32(a5)
    800073b6:	0026d783          	lhu	a5,2(a3)
    800073ba:	06f70163          	beq	a4,a5,8000741c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800073be:	00038917          	auipc	s2,0x38
    800073c2:	c4290913          	addi	s2,s2,-958 # 8003f000 <disk>
    800073c6:	0003a497          	auipc	s1,0x3a
    800073ca:	c3a48493          	addi	s1,s1,-966 # 80041000 <disk+0x2000>
    __sync_synchronize();
    800073ce:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800073d2:	6898                	ld	a4,16(s1)
    800073d4:	0204d783          	lhu	a5,32(s1)
    800073d8:	8b9d                	andi	a5,a5,7
    800073da:	078e                	slli	a5,a5,0x3
    800073dc:	97ba                	add	a5,a5,a4
    800073de:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800073e0:	20078713          	addi	a4,a5,512
    800073e4:	0712                	slli	a4,a4,0x4
    800073e6:	974a                	add	a4,a4,s2
    800073e8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800073ec:	e731                	bnez	a4,80007438 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800073ee:	20078793          	addi	a5,a5,512
    800073f2:	0792                	slli	a5,a5,0x4
    800073f4:	97ca                	add	a5,a5,s2
    800073f6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800073f8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800073fc:	ffffb097          	auipc	ra,0xffffb
    80007400:	1e0080e7          	jalr	480(ra) # 800025dc <wakeup>

    disk.used_idx += 1;
    80007404:	0204d783          	lhu	a5,32(s1)
    80007408:	2785                	addiw	a5,a5,1
    8000740a:	17c2                	slli	a5,a5,0x30
    8000740c:	93c1                	srli	a5,a5,0x30
    8000740e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007412:	6898                	ld	a4,16(s1)
    80007414:	00275703          	lhu	a4,2(a4)
    80007418:	faf71be3          	bne	a4,a5,800073ce <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000741c:	0003a517          	auipc	a0,0x3a
    80007420:	d0c50513          	addi	a0,a0,-756 # 80041128 <disk+0x2128>
    80007424:	ffffa097          	auipc	ra,0xffffa
    80007428:	878080e7          	jalr	-1928(ra) # 80000c9c <release>
}
    8000742c:	60e2                	ld	ra,24(sp)
    8000742e:	6442                	ld	s0,16(sp)
    80007430:	64a2                	ld	s1,8(sp)
    80007432:	6902                	ld	s2,0(sp)
    80007434:	6105                	addi	sp,sp,32
    80007436:	8082                	ret
      panic("virtio_disk_intr status");
    80007438:	00002517          	auipc	a0,0x2
    8000743c:	5e850513          	addi	a0,a0,1512 # 80009a20 <syscalls+0x3e8>
    80007440:	ffff9097          	auipc	ra,0xffff9
    80007444:	0ee080e7          	jalr	238(ra) # 8000052e <panic>

0000000080007448 <call_sigret>:
    80007448:	48e1                	li	a7,24
    8000744a:	00000073          	ecall
    8000744e:	8082                	ret

0000000080007450 <end_sigret>:
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
