
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
    80000068:	c5c78793          	addi	a5,a5,-932 # 80006cc0 <timervec>
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
    8000011e:	00002097          	auipc	ra,0x2
    80000122:	7fc080e7          	jalr	2044(ra) # 8000291a <either_copyin>
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
    800001c8:	1fe080e7          	jalr	510(ra) # 800023c2 <sleep>
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
    80000200:	00002097          	auipc	ra,0x2
    80000204:	6c4080e7          	jalr	1732(ra) # 800028c4 <either_copyout>
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
    800002e6:	68e080e7          	jalr	1678(ra) # 80002970 <procdump>
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
    8000043a:	116080e7          	jalr	278(ra) # 8000254c <wakeup>
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
    80000560:	b4450513          	addi	a0,a0,-1212 # 800090a0 <digits+0x60>
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
    80000886:	cca080e7          	jalr	-822(ra) # 8000254c <wakeup>
    
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
    80000912:	ab4080e7          	jalr	-1356(ra) # 800023c2 <sleep>
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
    80000edc:	292080e7          	jalr	658(ra) # 8000316a <trapinithart>

    plicinithart();   // ask PLIC for device interrupts
    80000ee0:	00006097          	auipc	ra,0x6
    80000ee4:	e20080e7          	jalr	-480(ra) # 80006d00 <plicinithart>
  }

  scheduler();        
    80000ee8:	00001097          	auipc	ra,0x1
    80000eec:	2ca080e7          	jalr	714(ra) # 800021b2 <scheduler>
    consoleinit();
    80000ef0:	fffff097          	auipc	ra,0xfffff
    80000ef4:	550080e7          	jalr	1360(ra) # 80000440 <consoleinit>
    printfinit();
    80000ef8:	00000097          	auipc	ra,0x0
    80000efc:	860080e7          	jalr	-1952(ra) # 80000758 <printfinit>
    printf("\n");
    80000f00:	00008517          	auipc	a0,0x8
    80000f04:	1a050513          	addi	a0,a0,416 # 800090a0 <digits+0x60>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	670080e7          	jalr	1648(ra) # 80000578 <printf>
    printf("xv6 kernel is booting\n");
    80000f10:	00008517          	auipc	a0,0x8
    80000f14:	1c850513          	addi	a0,a0,456 # 800090d8 <digits+0x98>
    80000f18:	fffff097          	auipc	ra,0xfffff
    80000f1c:	660080e7          	jalr	1632(ra) # 80000578 <printf>
    printf("\n");
    80000f20:	00008517          	auipc	a0,0x8
    80000f24:	18050513          	addi	a0,a0,384 # 800090a0 <digits+0x60>
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
    80000f54:	1f2080e7          	jalr	498(ra) # 80003142 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	212080e7          	jalr	530(ra) # 8000316a <trapinithart>
    plicinit();      // set up interrupt controller
    80000f60:	00006097          	auipc	ra,0x6
    80000f64:	d8a080e7          	jalr	-630(ra) # 80006cea <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f68:	00006097          	auipc	ra,0x6
    80000f6c:	d98080e7          	jalr	-616(ra) # 80006d00 <plicinithart>
    binit();         // buffer cache
    80000f70:	00003097          	auipc	ra,0x3
    80000f74:	ec4080e7          	jalr	-316(ra) # 80003e34 <binit>
    iinit();         // inode cache
    80000f78:	00003097          	auipc	ra,0x3
    80000f7c:	556080e7          	jalr	1366(ra) # 800044ce <iinit>
    fileinit();      // file table
    80000f80:	00004097          	auipc	ra,0x4
    80000f84:	502080e7          	jalr	1282(ra) # 80005482 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f88:	00006097          	auipc	ra,0x6
    80000f8c:	e9a080e7          	jalr	-358(ra) # 80006e22 <virtio_disk_init>
    userinit();      // first user process
    80000f90:	00001097          	auipc	ra,0x1
    80000f94:	f6e080e7          	jalr	-146(ra) # 80001efe <userinit>
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
    80001b18:	e3c7a783          	lw	a5,-452(a5) # 80009950 <first.1>
    80001b1c:	eb89                	bnez	a5,80001b2e <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001b1e:	00002097          	auipc	ra,0x2
    80001b22:	91e080e7          	jalr	-1762(ra) # 8000343c <usertrapret>
}
    80001b26:	60a2                	ld	ra,8(sp)
    80001b28:	6402                	ld	s0,0(sp)
    80001b2a:	0141                	addi	sp,sp,16
    80001b2c:	8082                	ret
    first = 0;
    80001b2e:	00008797          	auipc	a5,0x8
    80001b32:	e207a123          	sw	zero,-478(a5) # 80009950 <first.1>
    fsinit(ROOTDEV);
    80001b36:	4505                	li	a0,1
    80001b38:	00003097          	auipc	ra,0x3
    80001b3c:	916080e7          	jalr	-1770(ra) # 8000444e <fsinit>
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
    80001b64:	df878793          	addi	a5,a5,-520 # 80009958 <nextpid>
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
    80001baa:	dae78793          	addi	a5,a5,-594 # 80009954 <nexttid>
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
    80001d22:	a811                	j	80001d36 <freeproc+0x30>
    release(&t->lock);
    80001d24:	8526                	mv	a0,s1
    80001d26:	fffff097          	auipc	ra,0xfffff
    80001d2a:	f76080e7          	jalr	-138(ra) # 80000c9c <release>
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001d2e:	0b848493          	addi	s1,s1,184
    80001d32:	02998463          	beq	s3,s1,80001d5a <freeproc+0x54>
    acquire(&t->lock);
    80001d36:	8526                	mv	a0,s1
    80001d38:	fffff097          	auipc	ra,0xfffff
    80001d3c:	e8e080e7          	jalr	-370(ra) # 80000bc6 <acquire>
    if(t->state != TUNUSED)
    80001d40:	4c9c                	lw	a5,24(s1)
    80001d42:	d3ed                	beqz	a5,80001d24 <freeproc+0x1e>
  t->tid = 0;
    80001d44:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80001d48:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80001d4c:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80001d50:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80001d54:	0004ac23          	sw	zero,24(s1)
}
    80001d58:	b7f1                	j	80001d24 <freeproc+0x1e>
  p->user_trapframe_backup = 0;
    80001d5a:	26093c23          	sd	zero,632(s2)
  if(p->pagetable)
    80001d5e:	04093503          	ld	a0,64(s2)
    80001d62:	c519                	beqz	a0,80001d70 <freeproc+0x6a>
    proc_freepagetable(p->pagetable, p->sz);
    80001d64:	03893583          	ld	a1,56(s2)
    80001d68:	00000097          	auipc	ra,0x0
    80001d6c:	f4c080e7          	jalr	-180(ra) # 80001cb4 <proc_freepagetable>
  p->pagetable = 0;
    80001d70:	04093023          	sd	zero,64(s2)
  p->sz = 0;
    80001d74:	02093c23          	sd	zero,56(s2)
  p->pid = 0;
    80001d78:	02092223          	sw	zero,36(s2)
  p->parent = 0;
    80001d7c:	02093823          	sd	zero,48(s2)
  p->name[0] = 0;
    80001d80:	0c090c23          	sb	zero,216(s2)
  p->killed = 0;
    80001d84:	00092e23          	sw	zero,28(s2)
  p->xstate = 0;
    80001d88:	02092023          	sw	zero,32(s2)
  p->active_threads = 0;
    80001d8c:	02092423          	sw	zero,40(s2)
  p->state = UNUSED;
    80001d90:	00092c23          	sw	zero,24(s2)
}
    80001d94:	70a2                	ld	ra,40(sp)
    80001d96:	7402                	ld	s0,32(sp)
    80001d98:	64e2                	ld	s1,24(sp)
    80001d9a:	6942                	ld	s2,16(sp)
    80001d9c:	69a2                	ld	s3,8(sp)
    80001d9e:	6145                	addi	sp,sp,48
    80001da0:	8082                	ret

0000000080001da2 <allocproc>:
{
    80001da2:	7179                	addi	sp,sp,-48
    80001da4:	f406                	sd	ra,40(sp)
    80001da6:	f022                	sd	s0,32(sp)
    80001da8:	ec26                	sd	s1,24(sp)
    80001daa:	e84a                	sd	s2,16(sp)
    80001dac:	e44e                	sd	s3,8(sp)
    80001dae:	e052                	sd	s4,0(sp)
    80001db0:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001db2:	00011497          	auipc	s1,0x11
    80001db6:	97648493          	addi	s1,s1,-1674 # 80012728 <proc>
    80001dba:	6985                	lui	s3,0x1
    80001dbc:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80001dc0:	00032a17          	auipc	s4,0x32
    80001dc4:	b68a0a13          	addi	s4,s4,-1176 # 80033928 <tickslock>
    acquire(&p->lock);
    80001dc8:	8926                	mv	s2,s1
    80001dca:	8526                	mv	a0,s1
    80001dcc:	fffff097          	auipc	ra,0xfffff
    80001dd0:	dfa080e7          	jalr	-518(ra) # 80000bc6 <acquire>
    if(p->state == UNUSED) {
    80001dd4:	4c9c                	lw	a5,24(s1)
    80001dd6:	cb99                	beqz	a5,80001dec <allocproc+0x4a>
      release(&p->lock);
    80001dd8:	8526                	mv	a0,s1
    80001dda:	fffff097          	auipc	ra,0xfffff
    80001dde:	ec2080e7          	jalr	-318(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001de2:	94ce                	add	s1,s1,s3
    80001de4:	ff4492e3          	bne	s1,s4,80001dc8 <allocproc+0x26>
  return 0;
    80001de8:	4481                	li	s1,0
    80001dea:	a86d                	j	80001ea4 <allocproc+0x102>
  p->pid = allocpid();
    80001dec:	00000097          	auipc	ra,0x0
    80001df0:	d56080e7          	jalr	-682(ra) # 80001b42 <allocpid>
    80001df4:	d0c8                	sw	a0,36(s1)
  p->state = USED;
    80001df6:	4785                	li	a5,1
    80001df8:	cc9c                	sw	a5,24(s1)
  if((p->threads_tf_start =kalloc()) == 0){
    80001dfa:	fffff097          	auipc	ra,0xfffff
    80001dfe:	cdc080e7          	jalr	-804(ra) # 80000ad6 <kalloc>
    80001e02:	89aa                	mv	s3,a0
    80001e04:	e4a8                	sd	a0,72(s1)
    80001e06:	0f848713          	addi	a4,s1,248
    80001e0a:	1f848793          	addi	a5,s1,504
    80001e0e:	27848693          	addi	a3,s1,632
    80001e12:	c155                	beqz	a0,80001eb6 <allocproc+0x114>
    p->signal_handlers[i] = SIG_DFL;
    80001e14:	00073023          	sd	zero,0(a4) # 1000 <_entry-0x7ffff000>
    p->handlers_sigmasks[i] = 0;
    80001e18:	0007a023          	sw	zero,0(a5)
  for(int i=0;i<32;i++){
    80001e1c:	0721                	addi	a4,a4,8
    80001e1e:	0791                	addi	a5,a5,4
    80001e20:	fed79ae3          	bne	a5,a3,80001e14 <allocproc+0x72>
  p->signal_mask= 0;
    80001e24:	0e04a623          	sw	zero,236(s1)
  p->pending_signals = 0;
    80001e28:	0e04a423          	sw	zero,232(s1)
  p->active_threads=1;
    80001e2c:	4785                	li	a5,1
    80001e2e:	d49c                	sw	a5,40(s1)
  p->signal_mask_backup = 0;
    80001e30:	0e04a823          	sw	zero,240(s1)
  p->handling_user_sig_flag = 0;
    80001e34:	2804a023          	sw	zero,640(s1)
  p->handling_sig_flag=0;
    80001e38:	2804a223          	sw	zero,644(s1)
  p->pagetable = proc_pagetable(p);
    80001e3c:	8526                	mv	a0,s1
    80001e3e:	00000097          	auipc	ra,0x0
    80001e42:	dda080e7          	jalr	-550(ra) # 80001c18 <proc_pagetable>
    80001e46:	89aa                	mv	s3,a0
    80001e48:	e0a8                	sd	a0,64(s1)
  if(p->pagetable == 0){
    80001e4a:	c151                	beqz	a0,80001ece <allocproc+0x12c>
    80001e4c:	2a048793          	addi	a5,s1,672
    80001e50:	64b8                	ld	a4,72(s1)
    80001e52:	6685                	lui	a3,0x1
    80001e54:	86068693          	addi	a3,a3,-1952 # 860 <_entry-0x7ffff7a0>
    80001e58:	9936                	add	s2,s2,a3
    t->tid=-1;
    80001e5a:	56fd                	li	a3,-1
    t->state=TUNUSED;
    80001e5c:	0007a023          	sw	zero,0(a5)
    t->chan=0;
    80001e60:	0007b423          	sd	zero,8(a5)
    t->tid=-1;
    80001e64:	cf94                	sw	a3,24(a5)
    t->trapframe = (struct trapframe *)p->threads_tf_start + i;     //TODO: check if good or maybe + i*sizeof(struct trapframe)
    80001e66:	f798                	sd	a4,40(a5)
    t->killed = 0;
    80001e68:	0007a823          	sw	zero,16(a5)
    t->frozen = 0;
    80001e6c:	0007ae23          	sw	zero,28(a5)
  for(int i=0;i<NTHREAD;i++){
    80001e70:	0b878793          	addi	a5,a5,184
    80001e74:	12070713          	addi	a4,a4,288
    80001e78:	ff2792e3          	bne	a5,s2,80001e5c <allocproc+0xba>
  struct kthread *t= &p->kthreads[0];
    80001e7c:	28848913          	addi	s2,s1,648
  acquire(&t->lock);
    80001e80:	854a                	mv	a0,s2
    80001e82:	fffff097          	auipc	ra,0xfffff
    80001e86:	d44080e7          	jalr	-700(ra) # 80000bc6 <acquire>
  if(init_thread(t) == -1){
    80001e8a:	854a                	mv	a0,s2
    80001e8c:	00000097          	auipc	ra,0x0
    80001e90:	d42080e7          	jalr	-702(ra) # 80001bce <init_thread>
    80001e94:	57fd                	li	a5,-1
    80001e96:	04f50863          	beq	a0,a5,80001ee6 <allocproc+0x144>
  release(&t->lock);
    80001e9a:	854a                	mv	a0,s2
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	e00080e7          	jalr	-512(ra) # 80000c9c <release>
}
    80001ea4:	8526                	mv	a0,s1
    80001ea6:	70a2                	ld	ra,40(sp)
    80001ea8:	7402                	ld	s0,32(sp)
    80001eaa:	64e2                	ld	s1,24(sp)
    80001eac:	6942                	ld	s2,16(sp)
    80001eae:	69a2                	ld	s3,8(sp)
    80001eb0:	6a02                	ld	s4,0(sp)
    80001eb2:	6145                	addi	sp,sp,48
    80001eb4:	8082                	ret
    freeproc(p);
    80001eb6:	8526                	mv	a0,s1
    80001eb8:	00000097          	auipc	ra,0x0
    80001ebc:	e4e080e7          	jalr	-434(ra) # 80001d06 <freeproc>
    release(&p->lock);
    80001ec0:	8526                	mv	a0,s1
    80001ec2:	fffff097          	auipc	ra,0xfffff
    80001ec6:	dda080e7          	jalr	-550(ra) # 80000c9c <release>
    return 0;
    80001eca:	84ce                	mv	s1,s3
    80001ecc:	bfe1                	j	80001ea4 <allocproc+0x102>
    freeproc(p);
    80001ece:	8526                	mv	a0,s1
    80001ed0:	00000097          	auipc	ra,0x0
    80001ed4:	e36080e7          	jalr	-458(ra) # 80001d06 <freeproc>
    release(&p->lock);
    80001ed8:	8526                	mv	a0,s1
    80001eda:	fffff097          	auipc	ra,0xfffff
    80001ede:	dc2080e7          	jalr	-574(ra) # 80000c9c <release>
    return 0;
    80001ee2:	84ce                	mv	s1,s3
    80001ee4:	b7c1                	j	80001ea4 <allocproc+0x102>
    freeproc(p);
    80001ee6:	8526                	mv	a0,s1
    80001ee8:	00000097          	auipc	ra,0x0
    80001eec:	e1e080e7          	jalr	-482(ra) # 80001d06 <freeproc>
    release(&p->lock);  
    80001ef0:	8526                	mv	a0,s1
    80001ef2:	fffff097          	auipc	ra,0xfffff
    80001ef6:	daa080e7          	jalr	-598(ra) # 80000c9c <release>
    return 0;
    80001efa:	4481                	li	s1,0
    80001efc:	b765                	j	80001ea4 <allocproc+0x102>

0000000080001efe <userinit>:
{
    80001efe:	1101                	addi	sp,sp,-32
    80001f00:	ec06                	sd	ra,24(sp)
    80001f02:	e822                	sd	s0,16(sp)
    80001f04:	e426                	sd	s1,8(sp)
    80001f06:	1000                	addi	s0,sp,32
    80001f08:	8792                	mv	a5,tp
  p = allocproc();
    80001f0a:	00000097          	auipc	ra,0x0
    80001f0e:	e98080e7          	jalr	-360(ra) # 80001da2 <allocproc>
    80001f12:	84aa                	mv	s1,a0
  initproc = p;
    80001f14:	00008797          	auipc	a5,0x8
    80001f18:	10a7ba23          	sd	a0,276(a5) # 8000a028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001f1c:	03400613          	li	a2,52
    80001f20:	00008597          	auipc	a1,0x8
    80001f24:	a4058593          	addi	a1,a1,-1472 # 80009960 <initcode>
    80001f28:	6128                	ld	a0,64(a0)
    80001f2a:	fffff097          	auipc	ra,0xfffff
    80001f2e:	430080e7          	jalr	1072(ra) # 8000135a <uvminit>
  p->sz = PGSIZE;
    80001f32:	6785                	lui	a5,0x1
    80001f34:	fc9c                	sd	a5,56(s1)
  t->trapframe->epc = 0;      // user program counter
    80001f36:	2c84b703          	ld	a4,712(s1)
    80001f3a:	00073c23          	sd	zero,24(a4)
  t->trapframe->sp = PGSIZE;  // user stack pointer
    80001f3e:	2c84b703          	ld	a4,712(s1)
    80001f42:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f44:	4641                	li	a2,16
    80001f46:	00007597          	auipc	a1,0x7
    80001f4a:	2ea58593          	addi	a1,a1,746 # 80009230 <digits+0x1f0>
    80001f4e:	0d848513          	addi	a0,s1,216
    80001f52:	fffff097          	auipc	ra,0xfffff
    80001f56:	ee4080e7          	jalr	-284(ra) # 80000e36 <safestrcpy>
  p->cwd = namei("/");
    80001f5a:	00007517          	auipc	a0,0x7
    80001f5e:	2e650513          	addi	a0,a0,742 # 80009240 <digits+0x200>
    80001f62:	00003097          	auipc	ra,0x3
    80001f66:	f18080e7          	jalr	-232(ra) # 80004e7a <namei>
    80001f6a:	e8e8                	sd	a0,208(s1)
  p->state = RUNNABLE;
    80001f6c:	4789                	li	a5,2
    80001f6e:	cc9c                	sw	a5,24(s1)
  t->state = TRUNNABLE;
    80001f70:	478d                	li	a5,3
    80001f72:	2af4a023          	sw	a5,672(s1)
  release(&p->lock);
    80001f76:	8526                	mv	a0,s1
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	d24080e7          	jalr	-732(ra) # 80000c9c <release>
}
    80001f80:	60e2                	ld	ra,24(sp)
    80001f82:	6442                	ld	s0,16(sp)
    80001f84:	64a2                	ld	s1,8(sp)
    80001f86:	6105                	addi	sp,sp,32
    80001f88:	8082                	ret

0000000080001f8a <growproc>:
{
    80001f8a:	1101                	addi	sp,sp,-32
    80001f8c:	ec06                	sd	ra,24(sp)
    80001f8e:	e822                	sd	s0,16(sp)
    80001f90:	e426                	sd	s1,8(sp)
    80001f92:	e04a                	sd	s2,0(sp)
    80001f94:	1000                	addi	s0,sp,32
    80001f96:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f98:	00000097          	auipc	ra,0x0
    80001f9c:	ae4080e7          	jalr	-1308(ra) # 80001a7c <myproc>
    80001fa0:	892a                	mv	s2,a0
  sz = p->sz;
    80001fa2:	7d0c                	ld	a1,56(a0)
    80001fa4:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001fa8:	00904f63          	bgtz	s1,80001fc6 <growproc+0x3c>
  } else if(n < 0){
    80001fac:	0204cc63          	bltz	s1,80001fe4 <growproc+0x5a>
  p->sz = sz;
    80001fb0:	1602                	slli	a2,a2,0x20
    80001fb2:	9201                	srli	a2,a2,0x20
    80001fb4:	02c93c23          	sd	a2,56(s2)
  return 0;
    80001fb8:	4501                	li	a0,0
}
    80001fba:	60e2                	ld	ra,24(sp)
    80001fbc:	6442                	ld	s0,16(sp)
    80001fbe:	64a2                	ld	s1,8(sp)
    80001fc0:	6902                	ld	s2,0(sp)
    80001fc2:	6105                	addi	sp,sp,32
    80001fc4:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001fc6:	9e25                	addw	a2,a2,s1
    80001fc8:	1602                	slli	a2,a2,0x20
    80001fca:	9201                	srli	a2,a2,0x20
    80001fcc:	1582                	slli	a1,a1,0x20
    80001fce:	9181                	srli	a1,a1,0x20
    80001fd0:	6128                	ld	a0,64(a0)
    80001fd2:	fffff097          	auipc	ra,0xfffff
    80001fd6:	442080e7          	jalr	1090(ra) # 80001414 <uvmalloc>
    80001fda:	0005061b          	sext.w	a2,a0
    80001fde:	fa69                	bnez	a2,80001fb0 <growproc+0x26>
      return -1;
    80001fe0:	557d                	li	a0,-1
    80001fe2:	bfe1                	j	80001fba <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001fe4:	9e25                	addw	a2,a2,s1
    80001fe6:	1602                	slli	a2,a2,0x20
    80001fe8:	9201                	srli	a2,a2,0x20
    80001fea:	1582                	slli	a1,a1,0x20
    80001fec:	9181                	srli	a1,a1,0x20
    80001fee:	6128                	ld	a0,64(a0)
    80001ff0:	fffff097          	auipc	ra,0xfffff
    80001ff4:	3dc080e7          	jalr	988(ra) # 800013cc <uvmdealloc>
    80001ff8:	0005061b          	sext.w	a2,a0
    80001ffc:	bf55                	j	80001fb0 <growproc+0x26>

0000000080001ffe <fork>:
{
    80001ffe:	7139                	addi	sp,sp,-64
    80002000:	fc06                	sd	ra,56(sp)
    80002002:	f822                	sd	s0,48(sp)
    80002004:	f426                	sd	s1,40(sp)
    80002006:	f04a                	sd	s2,32(sp)
    80002008:	ec4e                	sd	s3,24(sp)
    8000200a:	e852                	sd	s4,16(sp)
    8000200c:	e456                	sd	s5,8(sp)
    8000200e:	e05a                	sd	s6,0(sp)
    80002010:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002012:	00000097          	auipc	ra,0x0
    80002016:	a6a080e7          	jalr	-1430(ra) # 80001a7c <myproc>
    8000201a:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    8000201c:	00000097          	auipc	ra,0x0
    80002020:	aa0080e7          	jalr	-1376(ra) # 80001abc <mykthread>
    80002024:	84aa                	mv	s1,a0
  if((np = allocproc()) == 0){
    80002026:	00000097          	auipc	ra,0x0
    8000202a:	d7c080e7          	jalr	-644(ra) # 80001da2 <allocproc>
    8000202e:	18050063          	beqz	a0,800021ae <fork+0x1b0>
    80002032:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002034:	0389b603          	ld	a2,56(s3)
    80002038:	612c                	ld	a1,64(a0)
    8000203a:	0409b503          	ld	a0,64(s3)
    8000203e:	fffff097          	auipc	ra,0xfffff
    80002042:	522080e7          	jalr	1314(ra) # 80001560 <uvmcopy>
    80002046:	04054e63          	bltz	a0,800020a2 <fork+0xa4>
  np->sz = p->sz;
    8000204a:	0389b783          	ld	a5,56(s3)
    8000204e:	02f93c23          	sd	a5,56(s2)
  acquire(&np_first_thread ->lock);
    80002052:	28890a13          	addi	s4,s2,648
    80002056:	8552                	mv	a0,s4
    80002058:	fffff097          	auipc	ra,0xfffff
    8000205c:	b6e080e7          	jalr	-1170(ra) # 80000bc6 <acquire>
  *(np_first_thread->trapframe) = *(t->trapframe);
    80002060:	60b4                	ld	a3,64(s1)
    80002062:	87b6                	mv	a5,a3
    80002064:	2c893703          	ld	a4,712(s2)
    80002068:	12068693          	addi	a3,a3,288
    8000206c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002070:	6788                	ld	a0,8(a5)
    80002072:	6b8c                	ld	a1,16(a5)
    80002074:	6f90                	ld	a2,24(a5)
    80002076:	01073023          	sd	a6,0(a4)
    8000207a:	e708                	sd	a0,8(a4)
    8000207c:	eb0c                	sd	a1,16(a4)
    8000207e:	ef10                	sd	a2,24(a4)
    80002080:	02078793          	addi	a5,a5,32
    80002084:	02070713          	addi	a4,a4,32
    80002088:	fed792e3          	bne	a5,a3,8000206c <fork+0x6e>
  np_first_thread->trapframe->a0 = 0;  // TODO: change reading the ret value from proc a0 to thread a0
    8000208c:	2c893783          	ld	a5,712(s2)
    80002090:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002094:	05098493          	addi	s1,s3,80
    80002098:	05090a93          	addi	s5,s2,80
    8000209c:	0d098b13          	addi	s6,s3,208
    800020a0:	a00d                	j	800020c2 <fork+0xc4>
    freeproc(np);
    800020a2:	854a                	mv	a0,s2
    800020a4:	00000097          	auipc	ra,0x0
    800020a8:	c62080e7          	jalr	-926(ra) # 80001d06 <freeproc>
    release(&np->lock);
    800020ac:	854a                	mv	a0,s2
    800020ae:	fffff097          	auipc	ra,0xfffff
    800020b2:	bee080e7          	jalr	-1042(ra) # 80000c9c <release>
    return -1;
    800020b6:	5afd                	li	s5,-1
    800020b8:	a0c5                	j	80002198 <fork+0x19a>
  for(i = 0; i < NOFILE; i++)
    800020ba:	04a1                	addi	s1,s1,8
    800020bc:	0aa1                	addi	s5,s5,8
    800020be:	01648b63          	beq	s1,s6,800020d4 <fork+0xd6>
    if(p->ofile[i])
    800020c2:	6088                	ld	a0,0(s1)
    800020c4:	d97d                	beqz	a0,800020ba <fork+0xbc>
      np->ofile[i] = filedup(p->ofile[i]);
    800020c6:	00003097          	auipc	ra,0x3
    800020ca:	44e080e7          	jalr	1102(ra) # 80005514 <filedup>
    800020ce:	00aab023          	sd	a0,0(s5) # 4000000 <_entry-0x7c000000>
    800020d2:	b7e5                	j	800020ba <fork+0xbc>
  np->cwd = idup(p->cwd);
    800020d4:	0d09b503          	ld	a0,208(s3)
    800020d8:	00002097          	auipc	ra,0x2
    800020dc:	5b0080e7          	jalr	1456(ra) # 80004688 <idup>
    800020e0:	0ca93823          	sd	a0,208(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020e4:	4641                	li	a2,16
    800020e6:	0d898593          	addi	a1,s3,216
    800020ea:	0d890513          	addi	a0,s2,216
    800020ee:	fffff097          	auipc	ra,0xfffff
    800020f2:	d48080e7          	jalr	-696(ra) # 80000e36 <safestrcpy>
  np->signal_mask = p->signal_mask;
    800020f6:	0ec9a783          	lw	a5,236(s3)
    800020fa:	0ef92623          	sw	a5,236(s2)
  for(int i=0;i<32;i++){
    800020fe:	0f898693          	addi	a3,s3,248
    80002102:	0f890713          	addi	a4,s2,248
  np->signal_mask = p->signal_mask;
    80002106:	1f800793          	li	a5,504
  for(int i=0;i<32;i++){
    8000210a:	27800513          	li	a0,632
    np->signal_handlers[i] = p->signal_handlers[i];
    8000210e:	6290                	ld	a2,0(a3)
    80002110:	e310                	sd	a2,0(a4)
    np->handlers_sigmasks[i] = p->handlers_sigmasks[i];
    80002112:	00f98633          	add	a2,s3,a5
    80002116:	420c                	lw	a1,0(a2)
    80002118:	00f90633          	add	a2,s2,a5
    8000211c:	c20c                	sw	a1,0(a2)
  for(int i=0;i<32;i++){
    8000211e:	06a1                	addi	a3,a3,8
    80002120:	0721                	addi	a4,a4,8
    80002122:	0791                	addi	a5,a5,4
    80002124:	fea795e3          	bne	a5,a0,8000210e <fork+0x110>
  np-> pending_signals=0;
    80002128:	0e092423          	sw	zero,232(s2)
  pid = np->pid;
    8000212c:	02492a83          	lw	s5,36(s2)
  release(&np_first_thread->lock);  // TODO: check if we need to hold the lock of thread during this func
    80002130:	8552                	mv	a0,s4
    80002132:	fffff097          	auipc	ra,0xfffff
    80002136:	b6a080e7          	jalr	-1174(ra) # 80000c9c <release>
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
  acquire(&np_first_thread->lock);
    8000216e:	8552                	mv	a0,s4
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	a56080e7          	jalr	-1450(ra) # 80000bc6 <acquire>
  np->state = RUNNABLE;   //TOOD: check if we still need this state or should change
    80002178:	4789                	li	a5,2
    8000217a:	00f92c23          	sw	a5,24(s2)
  np_first_thread->state = TRUNNABLE;
    8000217e:	478d                	li	a5,3
    80002180:	2af92023          	sw	a5,672(s2)
  release(&np_first_thread->lock);
    80002184:	8552                	mv	a0,s4
    80002186:	fffff097          	auipc	ra,0xfffff
    8000218a:	b16080e7          	jalr	-1258(ra) # 80000c9c <release>
  release(&np->lock);
    8000218e:	854a                	mv	a0,s2
    80002190:	fffff097          	auipc	ra,0xfffff
    80002194:	b0c080e7          	jalr	-1268(ra) # 80000c9c <release>
}
    80002198:	8556                	mv	a0,s5
    8000219a:	70e2                	ld	ra,56(sp)
    8000219c:	7442                	ld	s0,48(sp)
    8000219e:	74a2                	ld	s1,40(sp)
    800021a0:	7902                	ld	s2,32(sp)
    800021a2:	69e2                	ld	s3,24(sp)
    800021a4:	6a42                	ld	s4,16(sp)
    800021a6:	6aa2                	ld	s5,8(sp)
    800021a8:	6b02                	ld	s6,0(sp)
    800021aa:	6121                	addi	sp,sp,64
    800021ac:	8082                	ret
    return -1;
    800021ae:	5afd                	li	s5,-1
    800021b0:	b7e5                	j	80002198 <fork+0x19a>

00000000800021b2 <scheduler>:
{
    800021b2:	711d                	addi	sp,sp,-96
    800021b4:	ec86                	sd	ra,88(sp)
    800021b6:	e8a2                	sd	s0,80(sp)
    800021b8:	e4a6                	sd	s1,72(sp)
    800021ba:	e0ca                	sd	s2,64(sp)
    800021bc:	fc4e                	sd	s3,56(sp)
    800021be:	f852                	sd	s4,48(sp)
    800021c0:	f456                	sd	s5,40(sp)
    800021c2:	f05a                	sd	s6,32(sp)
    800021c4:	ec5e                	sd	s7,24(sp)
    800021c6:	e862                	sd	s8,16(sp)
    800021c8:	e466                	sd	s9,8(sp)
    800021ca:	1080                	addi	s0,sp,96
    800021cc:	8792                	mv	a5,tp
  int id = r_tp();
    800021ce:	2781                	sext.w	a5,a5
  c->proc = 0;
    800021d0:	00479713          	slli	a4,a5,0x4
    800021d4:	00f706b3          	add	a3,a4,a5
    800021d8:	00369613          	slli	a2,a3,0x3
    800021dc:	00010697          	auipc	a3,0x10
    800021e0:	0c468693          	addi	a3,a3,196 # 800122a0 <pid_lock>
    800021e4:	96b2                	add	a3,a3,a2
    800021e6:	0406b423          	sd	zero,72(a3)
  c->kthread=0;
    800021ea:	0c06b423          	sd	zero,200(a3)
            swtch(&c->context, &t->context);
    800021ee:	00010717          	auipc	a4,0x10
    800021f2:	10270713          	addi	a4,a4,258 # 800122f0 <cpus+0x8>
    800021f6:	00e60bb3          	add	s7,a2,a4
            c->proc = p;
    800021fa:	8b36                	mv	s6,a3
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    800021fc:	6a85                	lui	s5,0x1
    800021fe:	848a8a93          	addi	s5,s5,-1976 # 848 <_entry-0x7ffff7b8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002202:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002206:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000220a:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000220e:	00010917          	auipc	s2,0x10
    80002212:	51a90913          	addi	s2,s2,1306 # 80012728 <proc>
    80002216:	a8a9                	j	80002270 <scheduler+0xbe>
          release(&t->lock);
    80002218:	8526                	mv	a0,s1
    8000221a:	fffff097          	auipc	ra,0xfffff
    8000221e:	a82080e7          	jalr	-1406(ra) # 80000c9c <release>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002222:	0b848493          	addi	s1,s1,184
    80002226:	03348e63          	beq	s1,s3,80002262 <scheduler+0xb0>
          acquire(&t->lock);
    8000222a:	8526                	mv	a0,s1
    8000222c:	fffff097          	auipc	ra,0xfffff
    80002230:	99a080e7          	jalr	-1638(ra) # 80000bc6 <acquire>
          if(t->state == TRUNNABLE && !t->frozen) {
    80002234:	4c9c                	lw	a5,24(s1)
    80002236:	ff4791e3          	bne	a5,s4,80002218 <scheduler+0x66>
    8000223a:	58dc                	lw	a5,52(s1)
    8000223c:	fff1                	bnez	a5,80002218 <scheduler+0x66>
            t->state = TRUNNING;
    8000223e:	0194ac23          	sw	s9,24(s1)
            c->proc = p;
    80002242:	052b3423          	sd	s2,72(s6)
            c->kthread = t;
    80002246:	0c9b3423          	sd	s1,200(s6)
            swtch(&c->context, &t->context);
    8000224a:	04848593          	addi	a1,s1,72
    8000224e:	855e                	mv	a0,s7
    80002250:	00001097          	auipc	ra,0x1
    80002254:	e88080e7          	jalr	-376(ra) # 800030d8 <swtch>
            c->proc = 0;
    80002258:	040b3423          	sd	zero,72(s6)
            c->kthread=0;
    8000225c:	0c0b3423          	sd	zero,200(s6)
    80002260:	bf65                	j	80002218 <scheduler+0x66>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002262:	9956                	add	s2,s2,s5
    80002264:	00031797          	auipc	a5,0x31
    80002268:	6c478793          	addi	a5,a5,1732 # 80033928 <tickslock>
    8000226c:	f8f90be3          	beq	s2,a5,80002202 <scheduler+0x50>
      if(p->state == RUNNABLE) {
    80002270:	01892703          	lw	a4,24(s2)
    80002274:	4789                	li	a5,2
    80002276:	fef716e3          	bne	a4,a5,80002262 <scheduler+0xb0>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    8000227a:	28890493          	addi	s1,s2,648
          if(t->state == TRUNNABLE && !t->frozen) {
    8000227e:	4a0d                	li	s4,3
            t->state = TRUNNING;
    80002280:	4c91                	li	s9,4
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002282:	015909b3          	add	s3,s2,s5
    80002286:	b755                	j	8000222a <scheduler+0x78>

0000000080002288 <sched>:
{
    80002288:	7179                	addi	sp,sp,-48
    8000228a:	f406                	sd	ra,40(sp)
    8000228c:	f022                	sd	s0,32(sp)
    8000228e:	ec26                	sd	s1,24(sp)
    80002290:	e84a                	sd	s2,16(sp)
    80002292:	e44e                	sd	s3,8(sp)
    80002294:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	7e6080e7          	jalr	2022(ra) # 80001a7c <myproc>
  struct kthread *t=mykthread();
    8000229e:	00000097          	auipc	ra,0x0
    800022a2:	81e080e7          	jalr	-2018(ra) # 80001abc <mykthread>
    800022a6:	84aa                	mv	s1,a0
  if(!holding(&t->lock))
    800022a8:	fffff097          	auipc	ra,0xfffff
    800022ac:	8a4080e7          	jalr	-1884(ra) # 80000b4c <holding>
    800022b0:	c959                	beqz	a0,80002346 <sched+0xbe>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022b2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800022b4:	0007871b          	sext.w	a4,a5
    800022b8:	00471793          	slli	a5,a4,0x4
    800022bc:	97ba                	add	a5,a5,a4
    800022be:	078e                	slli	a5,a5,0x3
    800022c0:	00010717          	auipc	a4,0x10
    800022c4:	fe070713          	addi	a4,a4,-32 # 800122a0 <pid_lock>
    800022c8:	97ba                	add	a5,a5,a4
    800022ca:	0c07a703          	lw	a4,192(a5)
    800022ce:	4785                	li	a5,1
    800022d0:	08f71363          	bne	a4,a5,80002356 <sched+0xce>
  if(t->state == TRUNNING)
    800022d4:	4c98                	lw	a4,24(s1)
    800022d6:	4791                	li	a5,4
    800022d8:	08f70763          	beq	a4,a5,80002366 <sched+0xde>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022dc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800022e0:	8b89                	andi	a5,a5,2
  if(intr_get())
    800022e2:	ebd1                	bnez	a5,80002376 <sched+0xee>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022e4:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800022e6:	00010917          	auipc	s2,0x10
    800022ea:	fba90913          	addi	s2,s2,-70 # 800122a0 <pid_lock>
    800022ee:	0007871b          	sext.w	a4,a5
    800022f2:	00471793          	slli	a5,a4,0x4
    800022f6:	97ba                	add	a5,a5,a4
    800022f8:	078e                	slli	a5,a5,0x3
    800022fa:	97ca                	add	a5,a5,s2
    800022fc:	0c47a983          	lw	s3,196(a5)
    80002300:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    80002302:	0007859b          	sext.w	a1,a5
    80002306:	00459793          	slli	a5,a1,0x4
    8000230a:	97ae                	add	a5,a5,a1
    8000230c:	078e                	slli	a5,a5,0x3
    8000230e:	00010597          	auipc	a1,0x10
    80002312:	fe258593          	addi	a1,a1,-30 # 800122f0 <cpus+0x8>
    80002316:	95be                	add	a1,a1,a5
    80002318:	04848513          	addi	a0,s1,72
    8000231c:	00001097          	auipc	ra,0x1
    80002320:	dbc080e7          	jalr	-580(ra) # 800030d8 <swtch>
    80002324:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002326:	0007871b          	sext.w	a4,a5
    8000232a:	00471793          	slli	a5,a4,0x4
    8000232e:	97ba                	add	a5,a5,a4
    80002330:	078e                	slli	a5,a5,0x3
    80002332:	97ca                	add	a5,a5,s2
    80002334:	0d37a223          	sw	s3,196(a5)
}
    80002338:	70a2                	ld	ra,40(sp)
    8000233a:	7402                	ld	s0,32(sp)
    8000233c:	64e2                	ld	s1,24(sp)
    8000233e:	6942                	ld	s2,16(sp)
    80002340:	69a2                	ld	s3,8(sp)
    80002342:	6145                	addi	sp,sp,48
    80002344:	8082                	ret
    panic("sched t->lock");
    80002346:	00007517          	auipc	a0,0x7
    8000234a:	f0250513          	addi	a0,a0,-254 # 80009248 <digits+0x208>
    8000234e:	ffffe097          	auipc	ra,0xffffe
    80002352:	1e0080e7          	jalr	480(ra) # 8000052e <panic>
    panic("sched locks");
    80002356:	00007517          	auipc	a0,0x7
    8000235a:	f0250513          	addi	a0,a0,-254 # 80009258 <digits+0x218>
    8000235e:	ffffe097          	auipc	ra,0xffffe
    80002362:	1d0080e7          	jalr	464(ra) # 8000052e <panic>
    panic("sched running");
    80002366:	00007517          	auipc	a0,0x7
    8000236a:	f0250513          	addi	a0,a0,-254 # 80009268 <digits+0x228>
    8000236e:	ffffe097          	auipc	ra,0xffffe
    80002372:	1c0080e7          	jalr	448(ra) # 8000052e <panic>
    panic("sched interruptible");
    80002376:	00007517          	auipc	a0,0x7
    8000237a:	f0250513          	addi	a0,a0,-254 # 80009278 <digits+0x238>
    8000237e:	ffffe097          	auipc	ra,0xffffe
    80002382:	1b0080e7          	jalr	432(ra) # 8000052e <panic>

0000000080002386 <yield>:
{
    80002386:	1101                	addi	sp,sp,-32
    80002388:	ec06                	sd	ra,24(sp)
    8000238a:	e822                	sd	s0,16(sp)
    8000238c:	e426                	sd	s1,8(sp)
    8000238e:	1000                	addi	s0,sp,32
  struct kthread *t =mykthread();
    80002390:	fffff097          	auipc	ra,0xfffff
    80002394:	72c080e7          	jalr	1836(ra) # 80001abc <mykthread>
    80002398:	84aa                	mv	s1,a0
  acquire(&t->lock);
    8000239a:	fffff097          	auipc	ra,0xfffff
    8000239e:	82c080e7          	jalr	-2004(ra) # 80000bc6 <acquire>
  t->state = TRUNNABLE;
    800023a2:	478d                	li	a5,3
    800023a4:	cc9c                	sw	a5,24(s1)
  sched();
    800023a6:	00000097          	auipc	ra,0x0
    800023aa:	ee2080e7          	jalr	-286(ra) # 80002288 <sched>
  release(&t->lock);
    800023ae:	8526                	mv	a0,s1
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	8ec080e7          	jalr	-1812(ra) # 80000c9c <release>
}
    800023b8:	60e2                	ld	ra,24(sp)
    800023ba:	6442                	ld	s0,16(sp)
    800023bc:	64a2                	ld	s1,8(sp)
    800023be:	6105                	addi	sp,sp,32
    800023c0:	8082                	ret

00000000800023c2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800023c2:	7179                	addi	sp,sp,-48
    800023c4:	f406                	sd	ra,40(sp)
    800023c6:	f022                	sd	s0,32(sp)
    800023c8:	ec26                	sd	s1,24(sp)
    800023ca:	e84a                	sd	s2,16(sp)
    800023cc:	e44e                	sd	s3,8(sp)
    800023ce:	1800                	addi	s0,sp,48
    800023d0:	89aa                	mv	s3,a0
    800023d2:	892e                	mv	s2,a1
  // struct proc *p = myproc();
  struct kthread *t=mykthread();
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	6e8080e7          	jalr	1768(ra) # 80001abc <mykthread>
    800023dc:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&t->lock);  //DOC: sleeplock1
    800023de:	ffffe097          	auipc	ra,0xffffe
    800023e2:	7e8080e7          	jalr	2024(ra) # 80000bc6 <acquire>
  release(lk);
    800023e6:	854a                	mv	a0,s2
    800023e8:	fffff097          	auipc	ra,0xfffff
    800023ec:	8b4080e7          	jalr	-1868(ra) # 80000c9c <release>

  // Go to sleep.
  t->chan = chan;
    800023f0:	0334b023          	sd	s3,32(s1)
  t->state = TSLEEPING;
    800023f4:	4789                	li	a5,2
    800023f6:	cc9c                	sw	a5,24(s1)

  sched();
    800023f8:	00000097          	auipc	ra,0x0
    800023fc:	e90080e7          	jalr	-368(ra) # 80002288 <sched>

  // Tidy up.
  t->chan = 0;
    80002400:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&t->lock);
    80002404:	8526                	mv	a0,s1
    80002406:	fffff097          	auipc	ra,0xfffff
    8000240a:	896080e7          	jalr	-1898(ra) # 80000c9c <release>
  acquire(lk);
    8000240e:	854a                	mv	a0,s2
    80002410:	ffffe097          	auipc	ra,0xffffe
    80002414:	7b6080e7          	jalr	1974(ra) # 80000bc6 <acquire>
}
    80002418:	70a2                	ld	ra,40(sp)
    8000241a:	7402                	ld	s0,32(sp)
    8000241c:	64e2                	ld	s1,24(sp)
    8000241e:	6942                	ld	s2,16(sp)
    80002420:	69a2                	ld	s3,8(sp)
    80002422:	6145                	addi	sp,sp,48
    80002424:	8082                	ret

0000000080002426 <wait>:
{
    80002426:	715d                	addi	sp,sp,-80
    80002428:	e486                	sd	ra,72(sp)
    8000242a:	e0a2                	sd	s0,64(sp)
    8000242c:	fc26                	sd	s1,56(sp)
    8000242e:	f84a                	sd	s2,48(sp)
    80002430:	f44e                	sd	s3,40(sp)
    80002432:	f052                	sd	s4,32(sp)
    80002434:	ec56                	sd	s5,24(sp)
    80002436:	e85a                	sd	s6,16(sp)
    80002438:	e45e                	sd	s7,8(sp)
    8000243a:	0880                	addi	s0,sp,80
    8000243c:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    8000243e:	fffff097          	auipc	ra,0xfffff
    80002442:	63e080e7          	jalr	1598(ra) # 80001a7c <myproc>
    80002446:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002448:	00010517          	auipc	a0,0x10
    8000244c:	e8850513          	addi	a0,a0,-376 # 800122d0 <wait_lock>
    80002450:	ffffe097          	auipc	ra,0xffffe
    80002454:	776080e7          	jalr	1910(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    80002458:	4b0d                	li	s6,3
        havekids = 1;
    8000245a:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000245c:	6985                	lui	s3,0x1
    8000245e:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002462:	00031a17          	auipc	s4,0x31
    80002466:	4c6a0a13          	addi	s4,s4,1222 # 80033928 <tickslock>
    havekids = 0;
    8000246a:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    8000246c:	00010497          	auipc	s1,0x10
    80002470:	2bc48493          	addi	s1,s1,700 # 80012728 <proc>
    80002474:	a0b5                	j	800024e0 <wait+0xba>
          pid = np->pid;
    80002476:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000247a:	000b8e63          	beqz	s7,80002496 <wait+0x70>
    8000247e:	4691                	li	a3,4
    80002480:	02048613          	addi	a2,s1,32
    80002484:	85de                	mv	a1,s7
    80002486:	04093503          	ld	a0,64(s2)
    8000248a:	fffff097          	auipc	ra,0xfffff
    8000248e:	1da080e7          	jalr	474(ra) # 80001664 <copyout>
    80002492:	02054563          	bltz	a0,800024bc <wait+0x96>
          freeproc(np);
    80002496:	8526                	mv	a0,s1
    80002498:	00000097          	auipc	ra,0x0
    8000249c:	86e080e7          	jalr	-1938(ra) # 80001d06 <freeproc>
          release(&np->lock);
    800024a0:	8526                	mv	a0,s1
    800024a2:	ffffe097          	auipc	ra,0xffffe
    800024a6:	7fa080e7          	jalr	2042(ra) # 80000c9c <release>
          release(&wait_lock);
    800024aa:	00010517          	auipc	a0,0x10
    800024ae:	e2650513          	addi	a0,a0,-474 # 800122d0 <wait_lock>
    800024b2:	ffffe097          	auipc	ra,0xffffe
    800024b6:	7ea080e7          	jalr	2026(ra) # 80000c9c <release>
          return pid;
    800024ba:	a09d                	j	80002520 <wait+0xfa>
            release(&np->lock);
    800024bc:	8526                	mv	a0,s1
    800024be:	ffffe097          	auipc	ra,0xffffe
    800024c2:	7de080e7          	jalr	2014(ra) # 80000c9c <release>
            release(&wait_lock);
    800024c6:	00010517          	auipc	a0,0x10
    800024ca:	e0a50513          	addi	a0,a0,-502 # 800122d0 <wait_lock>
    800024ce:	ffffe097          	auipc	ra,0xffffe
    800024d2:	7ce080e7          	jalr	1998(ra) # 80000c9c <release>
            return -1;
    800024d6:	59fd                	li	s3,-1
    800024d8:	a0a1                	j	80002520 <wait+0xfa>
    for(np = proc; np < &proc[NPROC]; np++){
    800024da:	94ce                	add	s1,s1,s3
    800024dc:	03448463          	beq	s1,s4,80002504 <wait+0xde>
      if(np->parent == p){
    800024e0:	789c                	ld	a5,48(s1)
    800024e2:	ff279ce3          	bne	a5,s2,800024da <wait+0xb4>
        acquire(&np->lock);
    800024e6:	8526                	mv	a0,s1
    800024e8:	ffffe097          	auipc	ra,0xffffe
    800024ec:	6de080e7          	jalr	1758(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    800024f0:	4c9c                	lw	a5,24(s1)
    800024f2:	f96782e3          	beq	a5,s6,80002476 <wait+0x50>
        release(&np->lock);
    800024f6:	8526                	mv	a0,s1
    800024f8:	ffffe097          	auipc	ra,0xffffe
    800024fc:	7a4080e7          	jalr	1956(ra) # 80000c9c <release>
        havekids = 1;
    80002500:	8756                	mv	a4,s5
    80002502:	bfe1                	j	800024da <wait+0xb4>
    if(!havekids || p->killed==1){
    80002504:	c709                	beqz	a4,8000250e <wait+0xe8>
    80002506:	01c92783          	lw	a5,28(s2)
    8000250a:	03579763          	bne	a5,s5,80002538 <wait+0x112>
      release(&wait_lock);
    8000250e:	00010517          	auipc	a0,0x10
    80002512:	dc250513          	addi	a0,a0,-574 # 800122d0 <wait_lock>
    80002516:	ffffe097          	auipc	ra,0xffffe
    8000251a:	786080e7          	jalr	1926(ra) # 80000c9c <release>
      return -1;
    8000251e:	59fd                	li	s3,-1
}
    80002520:	854e                	mv	a0,s3
    80002522:	60a6                	ld	ra,72(sp)
    80002524:	6406                	ld	s0,64(sp)
    80002526:	74e2                	ld	s1,56(sp)
    80002528:	7942                	ld	s2,48(sp)
    8000252a:	79a2                	ld	s3,40(sp)
    8000252c:	7a02                	ld	s4,32(sp)
    8000252e:	6ae2                	ld	s5,24(sp)
    80002530:	6b42                	ld	s6,16(sp)
    80002532:	6ba2                	ld	s7,8(sp)
    80002534:	6161                	addi	sp,sp,80
    80002536:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002538:	00010597          	auipc	a1,0x10
    8000253c:	d9858593          	addi	a1,a1,-616 # 800122d0 <wait_lock>
    80002540:	854a                	mv	a0,s2
    80002542:	00000097          	auipc	ra,0x0
    80002546:	e80080e7          	jalr	-384(ra) # 800023c2 <sleep>
    havekids = 0;
    8000254a:	b705                	j	8000246a <wait+0x44>

000000008000254c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000254c:	711d                	addi	sp,sp,-96
    8000254e:	ec86                	sd	ra,88(sp)
    80002550:	e8a2                	sd	s0,80(sp)
    80002552:	e4a6                	sd	s1,72(sp)
    80002554:	e0ca                	sd	s2,64(sp)
    80002556:	fc4e                	sd	s3,56(sp)
    80002558:	f852                	sd	s4,48(sp)
    8000255a:	f456                	sd	s5,40(sp)
    8000255c:	f05a                	sd	s6,32(sp)
    8000255e:	ec5e                	sd	s7,24(sp)
    80002560:	e862                	sd	s8,16(sp)
    80002562:	e466                	sd	s9,8(sp)
    80002564:	1080                	addi	s0,sp,96
    80002566:	8c2a                	mv	s8,a0
  struct proc *p;
  struct kthread *t;
  struct kthread *my_t = mykthread();
    80002568:	fffff097          	auipc	ra,0xfffff
    8000256c:	554080e7          	jalr	1364(ra) # 80001abc <mykthread>
    80002570:	8aaa                	mv	s5,a0

  for(p = proc; p < &proc[NPROC]; p++) {
    80002572:	00010917          	auipc	s2,0x10
    80002576:	43e90913          	addi	s2,s2,1086 # 800129b0 <proc+0x288>
    8000257a:	00031b97          	auipc	s7,0x31
    8000257e:	636b8b93          	addi	s7,s7,1590 # 80033bb0 <bcache+0x270>
    if(p->state == RUNNABLE){
    80002582:	4989                	li	s3,2
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
        if(t != my_t){
          acquire(&t->lock);
          if(t->state == TSLEEPING && t->chan == chan) {
            t->state = TRUNNABLE;
    80002584:	4c8d                	li	s9,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002586:	6b05                	lui	s6,0x1
    80002588:	848b0b13          	addi	s6,s6,-1976 # 848 <_entry-0x7ffff7b8>
    8000258c:	a82d                	j	800025c6 <wakeup+0x7a>
          }
          release(&t->lock);
    8000258e:	8526                	mv	a0,s1
    80002590:	ffffe097          	auipc	ra,0xffffe
    80002594:	70c080e7          	jalr	1804(ra) # 80000c9c <release>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    80002598:	0b848493          	addi	s1,s1,184
    8000259c:	03448263          	beq	s1,s4,800025c0 <wakeup+0x74>
        if(t != my_t){
    800025a0:	fe9a8ce3          	beq	s5,s1,80002598 <wakeup+0x4c>
          acquire(&t->lock);
    800025a4:	8526                	mv	a0,s1
    800025a6:	ffffe097          	auipc	ra,0xffffe
    800025aa:	620080e7          	jalr	1568(ra) # 80000bc6 <acquire>
          if(t->state == TSLEEPING && t->chan == chan) {
    800025ae:	4c9c                	lw	a5,24(s1)
    800025b0:	fd379fe3          	bne	a5,s3,8000258e <wakeup+0x42>
    800025b4:	709c                	ld	a5,32(s1)
    800025b6:	fd879ce3          	bne	a5,s8,8000258e <wakeup+0x42>
            t->state = TRUNNABLE;
    800025ba:	0194ac23          	sw	s9,24(s1)
    800025be:	bfc1                	j	8000258e <wakeup+0x42>
  for(p = proc; p < &proc[NPROC]; p++) {
    800025c0:	995a                	add	s2,s2,s6
    800025c2:	01790a63          	beq	s2,s7,800025d6 <wakeup+0x8a>
    if(p->state == RUNNABLE){
    800025c6:	84ca                	mv	s1,s2
    800025c8:	d9092783          	lw	a5,-624(s2)
    800025cc:	ff379ae3          	bne	a5,s3,800025c0 <wakeup+0x74>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800025d0:	5c090a13          	addi	s4,s2,1472
    800025d4:	b7f1                	j	800025a0 <wakeup+0x54>
        }
      }
    }
  }
}
    800025d6:	60e6                	ld	ra,88(sp)
    800025d8:	6446                	ld	s0,80(sp)
    800025da:	64a6                	ld	s1,72(sp)
    800025dc:	6906                	ld	s2,64(sp)
    800025de:	79e2                	ld	s3,56(sp)
    800025e0:	7a42                	ld	s4,48(sp)
    800025e2:	7aa2                	ld	s5,40(sp)
    800025e4:	7b02                	ld	s6,32(sp)
    800025e6:	6be2                	ld	s7,24(sp)
    800025e8:	6c42                	ld	s8,16(sp)
    800025ea:	6ca2                	ld	s9,8(sp)
    800025ec:	6125                	addi	sp,sp,96
    800025ee:	8082                	ret

00000000800025f0 <reparent>:
{
    800025f0:	7139                	addi	sp,sp,-64
    800025f2:	fc06                	sd	ra,56(sp)
    800025f4:	f822                	sd	s0,48(sp)
    800025f6:	f426                	sd	s1,40(sp)
    800025f8:	f04a                	sd	s2,32(sp)
    800025fa:	ec4e                	sd	s3,24(sp)
    800025fc:	e852                	sd	s4,16(sp)
    800025fe:	e456                	sd	s5,8(sp)
    80002600:	0080                	addi	s0,sp,64
    80002602:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002604:	00010497          	auipc	s1,0x10
    80002608:	12448493          	addi	s1,s1,292 # 80012728 <proc>
      pp->parent = initproc;
    8000260c:	00008a97          	auipc	s5,0x8
    80002610:	a1ca8a93          	addi	s5,s5,-1508 # 8000a028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002614:	6905                	lui	s2,0x1
    80002616:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    8000261a:	00031a17          	auipc	s4,0x31
    8000261e:	30ea0a13          	addi	s4,s4,782 # 80033928 <tickslock>
    80002622:	a021                	j	8000262a <reparent+0x3a>
    80002624:	94ca                	add	s1,s1,s2
    80002626:	01448d63          	beq	s1,s4,80002640 <reparent+0x50>
    if(pp->parent == p){
    8000262a:	789c                	ld	a5,48(s1)
    8000262c:	ff379ce3          	bne	a5,s3,80002624 <reparent+0x34>
      pp->parent = initproc;
    80002630:	000ab503          	ld	a0,0(s5)
    80002634:	f888                	sd	a0,48(s1)
      wakeup(initproc);
    80002636:	00000097          	auipc	ra,0x0
    8000263a:	f16080e7          	jalr	-234(ra) # 8000254c <wakeup>
    8000263e:	b7dd                	j	80002624 <reparent+0x34>
}
    80002640:	70e2                	ld	ra,56(sp)
    80002642:	7442                	ld	s0,48(sp)
    80002644:	74a2                	ld	s1,40(sp)
    80002646:	7902                	ld	s2,32(sp)
    80002648:	69e2                	ld	s3,24(sp)
    8000264a:	6a42                	ld	s4,16(sp)
    8000264c:	6aa2                	ld	s5,8(sp)
    8000264e:	6121                	addi	sp,sp,64
    80002650:	8082                	ret

0000000080002652 <exit_proccess>:
{
    80002652:	7139                	addi	sp,sp,-64
    80002654:	fc06                	sd	ra,56(sp)
    80002656:	f822                	sd	s0,48(sp)
    80002658:	f426                	sd	s1,40(sp)
    8000265a:	f04a                	sd	s2,32(sp)
    8000265c:	ec4e                	sd	s3,24(sp)
    8000265e:	e852                	sd	s4,16(sp)
    80002660:	e456                	sd	s5,8(sp)
    80002662:	0080                	addi	s0,sp,64
    80002664:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    80002666:	fffff097          	auipc	ra,0xfffff
    8000266a:	416080e7          	jalr	1046(ra) # 80001a7c <myproc>
    8000266e:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    80002670:	fffff097          	auipc	ra,0xfffff
    80002674:	44c080e7          	jalr	1100(ra) # 80001abc <mykthread>
    80002678:	8a2a                	mv	s4,a0
  if(p == initproc)
    8000267a:	00008797          	auipc	a5,0x8
    8000267e:	9ae7b783          	ld	a5,-1618(a5) # 8000a028 <initproc>
    80002682:	05098493          	addi	s1,s3,80
    80002686:	0d098913          	addi	s2,s3,208
    8000268a:	03379363          	bne	a5,s3,800026b0 <exit_proccess+0x5e>
    panic("init exiting");
    8000268e:	00007517          	auipc	a0,0x7
    80002692:	c0250513          	addi	a0,a0,-1022 # 80009290 <digits+0x250>
    80002696:	ffffe097          	auipc	ra,0xffffe
    8000269a:	e98080e7          	jalr	-360(ra) # 8000052e <panic>
      fileclose(f);
    8000269e:	00003097          	auipc	ra,0x3
    800026a2:	ec8080e7          	jalr	-312(ra) # 80005566 <fileclose>
      p->ofile[fd] = 0;
    800026a6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800026aa:	04a1                	addi	s1,s1,8
    800026ac:	01248563          	beq	s1,s2,800026b6 <exit_proccess+0x64>
    if(p->ofile[fd]){
    800026b0:	6088                	ld	a0,0(s1)
    800026b2:	f575                	bnez	a0,8000269e <exit_proccess+0x4c>
    800026b4:	bfdd                	j	800026aa <exit_proccess+0x58>
  begin_op();
    800026b6:	00003097          	auipc	ra,0x3
    800026ba:	9e4080e7          	jalr	-1564(ra) # 8000509a <begin_op>
  iput(p->cwd);
    800026be:	0d09b503          	ld	a0,208(s3)
    800026c2:	00002097          	auipc	ra,0x2
    800026c6:	1be080e7          	jalr	446(ra) # 80004880 <iput>
  end_op();
    800026ca:	00003097          	auipc	ra,0x3
    800026ce:	a50080e7          	jalr	-1456(ra) # 8000511a <end_op>
  p->cwd = 0;
    800026d2:	0c09b823          	sd	zero,208(s3)
  acquire(&wait_lock);
    800026d6:	00010497          	auipc	s1,0x10
    800026da:	bfa48493          	addi	s1,s1,-1030 # 800122d0 <wait_lock>
    800026de:	8526                	mv	a0,s1
    800026e0:	ffffe097          	auipc	ra,0xffffe
    800026e4:	4e6080e7          	jalr	1254(ra) # 80000bc6 <acquire>
  reparent(p);
    800026e8:	854e                	mv	a0,s3
    800026ea:	00000097          	auipc	ra,0x0
    800026ee:	f06080e7          	jalr	-250(ra) # 800025f0 <reparent>
  wakeup(p->parent);
    800026f2:	0309b503          	ld	a0,48(s3)
    800026f6:	00000097          	auipc	ra,0x0
    800026fa:	e56080e7          	jalr	-426(ra) # 8000254c <wakeup>
  acquire(&p->lock);
    800026fe:	854e                	mv	a0,s3
    80002700:	ffffe097          	auipc	ra,0xffffe
    80002704:	4c6080e7          	jalr	1222(ra) # 80000bc6 <acquire>
  p->xstate = status;
    80002708:	0359a023          	sw	s5,32(s3)
  p->state = ZOMBIE;
    8000270c:	478d                	li	a5,3
    8000270e:	00f9ac23          	sw	a5,24(s3)
  release(&p->lock);// we added
    80002712:	854e                	mv	a0,s3
    80002714:	ffffe097          	auipc	ra,0xffffe
    80002718:	588080e7          	jalr	1416(ra) # 80000c9c <release>
  release(&wait_lock);
    8000271c:	8526                	mv	a0,s1
    8000271e:	ffffe097          	auipc	ra,0xffffe
    80002722:	57e080e7          	jalr	1406(ra) # 80000c9c <release>
  acquire(&t->lock);
    80002726:	8552                	mv	a0,s4
    80002728:	ffffe097          	auipc	ra,0xffffe
    8000272c:	49e080e7          	jalr	1182(ra) # 80000bc6 <acquire>
  sched();
    80002730:	00000097          	auipc	ra,0x0
    80002734:	b58080e7          	jalr	-1192(ra) # 80002288 <sched>
  panic("zombie exit");
    80002738:	00007517          	auipc	a0,0x7
    8000273c:	b6850513          	addi	a0,a0,-1176 # 800092a0 <digits+0x260>
    80002740:	ffffe097          	auipc	ra,0xffffe
    80002744:	dee080e7          	jalr	-530(ra) # 8000052e <panic>

0000000080002748 <kthread_exit>:
kthread_exit(int status){
    80002748:	7179                	addi	sp,sp,-48
    8000274a:	f406                	sd	ra,40(sp)
    8000274c:	f022                	sd	s0,32(sp)
    8000274e:	ec26                	sd	s1,24(sp)
    80002750:	e84a                	sd	s2,16(sp)
    80002752:	e44e                	sd	s3,8(sp)
    80002754:	e052                	sd	s4,0(sp)
    80002756:	1800                	addi	s0,sp,48
    80002758:	89aa                	mv	s3,a0
  struct proc *p = myproc(); 
    8000275a:	fffff097          	auipc	ra,0xfffff
    8000275e:	322080e7          	jalr	802(ra) # 80001a7c <myproc>
    80002762:	892a                	mv	s2,a0
  struct kthread *t=mykthread();
    80002764:	fffff097          	auipc	ra,0xfffff
    80002768:	358080e7          	jalr	856(ra) # 80001abc <mykthread>
    8000276c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000276e:	854a                	mv	a0,s2
    80002770:	ffffe097          	auipc	ra,0xffffe
    80002774:	456080e7          	jalr	1110(ra) # 80000bc6 <acquire>
  p->active_threads--;
    80002778:	02892783          	lw	a5,40(s2)
    8000277c:	37fd                	addiw	a5,a5,-1
    8000277e:	00078a1b          	sext.w	s4,a5
    80002782:	02f92423          	sw	a5,40(s2)
  release(&p->lock);
    80002786:	854a                	mv	a0,s2
    80002788:	ffffe097          	auipc	ra,0xffffe
    8000278c:	514080e7          	jalr	1300(ra) # 80000c9c <release>
  acquire(&t->lock);
    80002790:	8526                	mv	a0,s1
    80002792:	ffffe097          	auipc	ra,0xffffe
    80002796:	434080e7          	jalr	1076(ra) # 80000bc6 <acquire>
  t->xstate = status;
    8000279a:	0334a623          	sw	s3,44(s1)
  t->state  = TUNUSED;
    8000279e:	0004ac23          	sw	zero,24(s1)
  wakeup(t);
    800027a2:	8526                	mv	a0,s1
    800027a4:	00000097          	auipc	ra,0x0
    800027a8:	da8080e7          	jalr	-600(ra) # 8000254c <wakeup>
  if(curr_active_threads==0){
    800027ac:	000a1c63          	bnez	s4,800027c4 <kthread_exit+0x7c>
    release(&t->lock);
    800027b0:	8526                	mv	a0,s1
    800027b2:	ffffe097          	auipc	ra,0xffffe
    800027b6:	4ea080e7          	jalr	1258(ra) # 80000c9c <release>
    exit_proccess(status);
    800027ba:	854e                	mv	a0,s3
    800027bc:	00000097          	auipc	ra,0x0
    800027c0:	e96080e7          	jalr	-362(ra) # 80002652 <exit_proccess>
    sched();
    800027c4:	00000097          	auipc	ra,0x0
    800027c8:	ac4080e7          	jalr	-1340(ra) # 80002288 <sched>
    panic("zombie thread exit");
    800027cc:	00007517          	auipc	a0,0x7
    800027d0:	ae450513          	addi	a0,a0,-1308 # 800092b0 <digits+0x270>
    800027d4:	ffffe097          	auipc	ra,0xffffe
    800027d8:	d5a080e7          	jalr	-678(ra) # 8000052e <panic>

00000000800027dc <exit>:
exit(int status){
    800027dc:	7139                	addi	sp,sp,-64
    800027de:	fc06                	sd	ra,56(sp)
    800027e0:	f822                	sd	s0,48(sp)
    800027e2:	f426                	sd	s1,40(sp)
    800027e4:	f04a                	sd	s2,32(sp)
    800027e6:	ec4e                	sd	s3,24(sp)
    800027e8:	e852                	sd	s4,16(sp)
    800027ea:	e456                	sd	s5,8(sp)
    800027ec:	e05a                	sd	s6,0(sp)
    800027ee:	0080                	addi	s0,sp,64
    800027f0:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    800027f2:	fffff097          	auipc	ra,0xfffff
    800027f6:	28a080e7          	jalr	650(ra) # 80001a7c <myproc>
    800027fa:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    800027fc:	fffff097          	auipc	ra,0xfffff
    80002800:	2c0080e7          	jalr	704(ra) # 80001abc <mykthread>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002804:	28890493          	addi	s1,s2,648
    80002808:	6505                	lui	a0,0x1
    8000280a:	84850513          	addi	a0,a0,-1976 # 848 <_entry-0x7ffff7b8>
    8000280e:	992a                	add	s2,s2,a0
    t->killed = 1;
    80002810:	4a05                	li	s4,1
    if(t->state == TSLEEPING)
    80002812:	4989                	li	s3,2
      t->state = TRUNNABLE;
    80002814:	4b0d                	li	s6,3
    80002816:	a811                	j	8000282a <exit+0x4e>
    release(&t->lock);
    80002818:	8526                	mv	a0,s1
    8000281a:	ffffe097          	auipc	ra,0xffffe
    8000281e:	482080e7          	jalr	1154(ra) # 80000c9c <release>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002822:	0b848493          	addi	s1,s1,184
    80002826:	00990f63          	beq	s2,s1,80002844 <exit+0x68>
    acquire(&t->lock);
    8000282a:	8526                	mv	a0,s1
    8000282c:	ffffe097          	auipc	ra,0xffffe
    80002830:	39a080e7          	jalr	922(ra) # 80000bc6 <acquire>
    t->killed = 1;
    80002834:	0344a423          	sw	s4,40(s1)
    if(t->state == TSLEEPING)
    80002838:	4c9c                	lw	a5,24(s1)
    8000283a:	fd379fe3          	bne	a5,s3,80002818 <exit+0x3c>
      t->state = TRUNNABLE;
    8000283e:	0164ac23          	sw	s6,24(s1)
    80002842:	bfd9                	j	80002818 <exit+0x3c>
  kthread_exit(status);
    80002844:	8556                	mv	a0,s5
    80002846:	00000097          	auipc	ra,0x0
    8000284a:	f02080e7          	jalr	-254(ra) # 80002748 <kthread_exit>

000000008000284e <sig_stop>:
//   return -1;
// }

int
sig_stop(int pid)//TODO delete if not used
{
    8000284e:	7179                	addi	sp,sp,-48
    80002850:	f406                	sd	ra,40(sp)
    80002852:	f022                	sd	s0,32(sp)
    80002854:	ec26                	sd	s1,24(sp)
    80002856:	e84a                	sd	s2,16(sp)
    80002858:	e44e                	sd	s3,8(sp)
    8000285a:	e052                	sd	s4,0(sp)
    8000285c:	1800                	addi	s0,sp,48
    8000285e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002860:	00010497          	auipc	s1,0x10
    80002864:	ec848493          	addi	s1,s1,-312 # 80012728 <proc>
    80002868:	6985                	lui	s3,0x1
    8000286a:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    8000286e:	00031a17          	auipc	s4,0x31
    80002872:	0baa0a13          	addi	s4,s4,186 # 80033928 <tickslock>
    acquire(&p->lock);
    80002876:	8526                	mv	a0,s1
    80002878:	ffffe097          	auipc	ra,0xffffe
    8000287c:	34e080e7          	jalr	846(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    80002880:	50dc                	lw	a5,36(s1)
    80002882:	01278c63          	beq	a5,s2,8000289a <sig_stop+0x4c>
      p->pending_signals|=(1<<SIGSTOP);

      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002886:	8526                	mv	a0,s1
    80002888:	ffffe097          	auipc	ra,0xffffe
    8000288c:	414080e7          	jalr	1044(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002890:	94ce                	add	s1,s1,s3
    80002892:	ff4492e3          	bne	s1,s4,80002876 <sig_stop+0x28>
  }
  return -1;
    80002896:	557d                	li	a0,-1
    80002898:	a831                	j	800028b4 <sig_stop+0x66>
      p->pending_signals|=(1<<SIGSTOP);
    8000289a:	0e84a783          	lw	a5,232(s1)
    8000289e:	00020737          	lui	a4,0x20
    800028a2:	8fd9                	or	a5,a5,a4
    800028a4:	0ef4a423          	sw	a5,232(s1)
      release(&p->lock);
    800028a8:	8526                	mv	a0,s1
    800028aa:	ffffe097          	auipc	ra,0xffffe
    800028ae:	3f2080e7          	jalr	1010(ra) # 80000c9c <release>
      return 0;
    800028b2:	4501                	li	a0,0
}
    800028b4:	70a2                	ld	ra,40(sp)
    800028b6:	7402                	ld	s0,32(sp)
    800028b8:	64e2                	ld	s1,24(sp)
    800028ba:	6942                	ld	s2,16(sp)
    800028bc:	69a2                	ld	s3,8(sp)
    800028be:	6a02                	ld	s4,0(sp)
    800028c0:	6145                	addi	sp,sp,48
    800028c2:	8082                	ret

00000000800028c4 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800028c4:	7179                	addi	sp,sp,-48
    800028c6:	f406                	sd	ra,40(sp)
    800028c8:	f022                	sd	s0,32(sp)
    800028ca:	ec26                	sd	s1,24(sp)
    800028cc:	e84a                	sd	s2,16(sp)
    800028ce:	e44e                	sd	s3,8(sp)
    800028d0:	e052                	sd	s4,0(sp)
    800028d2:	1800                	addi	s0,sp,48
    800028d4:	84aa                	mv	s1,a0
    800028d6:	892e                	mv	s2,a1
    800028d8:	89b2                	mv	s3,a2
    800028da:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028dc:	fffff097          	auipc	ra,0xfffff
    800028e0:	1a0080e7          	jalr	416(ra) # 80001a7c <myproc>
  if(user_dst){
    800028e4:	c08d                	beqz	s1,80002906 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800028e6:	86d2                	mv	a3,s4
    800028e8:	864e                	mv	a2,s3
    800028ea:	85ca                	mv	a1,s2
    800028ec:	6128                	ld	a0,64(a0)
    800028ee:	fffff097          	auipc	ra,0xfffff
    800028f2:	d76080e7          	jalr	-650(ra) # 80001664 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800028f6:	70a2                	ld	ra,40(sp)
    800028f8:	7402                	ld	s0,32(sp)
    800028fa:	64e2                	ld	s1,24(sp)
    800028fc:	6942                	ld	s2,16(sp)
    800028fe:	69a2                	ld	s3,8(sp)
    80002900:	6a02                	ld	s4,0(sp)
    80002902:	6145                	addi	sp,sp,48
    80002904:	8082                	ret
    memmove((char *)dst, src, len);
    80002906:	000a061b          	sext.w	a2,s4
    8000290a:	85ce                	mv	a1,s3
    8000290c:	854a                	mv	a0,s2
    8000290e:	ffffe097          	auipc	ra,0xffffe
    80002912:	432080e7          	jalr	1074(ra) # 80000d40 <memmove>
    return 0;
    80002916:	8526                	mv	a0,s1
    80002918:	bff9                	j	800028f6 <either_copyout+0x32>

000000008000291a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000291a:	7179                	addi	sp,sp,-48
    8000291c:	f406                	sd	ra,40(sp)
    8000291e:	f022                	sd	s0,32(sp)
    80002920:	ec26                	sd	s1,24(sp)
    80002922:	e84a                	sd	s2,16(sp)
    80002924:	e44e                	sd	s3,8(sp)
    80002926:	e052                	sd	s4,0(sp)
    80002928:	1800                	addi	s0,sp,48
    8000292a:	892a                	mv	s2,a0
    8000292c:	84ae                	mv	s1,a1
    8000292e:	89b2                	mv	s3,a2
    80002930:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002932:	fffff097          	auipc	ra,0xfffff
    80002936:	14a080e7          	jalr	330(ra) # 80001a7c <myproc>
  if(user_src){
    8000293a:	c08d                	beqz	s1,8000295c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000293c:	86d2                	mv	a3,s4
    8000293e:	864e                	mv	a2,s3
    80002940:	85ca                	mv	a1,s2
    80002942:	6128                	ld	a0,64(a0)
    80002944:	fffff097          	auipc	ra,0xfffff
    80002948:	dac080e7          	jalr	-596(ra) # 800016f0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000294c:	70a2                	ld	ra,40(sp)
    8000294e:	7402                	ld	s0,32(sp)
    80002950:	64e2                	ld	s1,24(sp)
    80002952:	6942                	ld	s2,16(sp)
    80002954:	69a2                	ld	s3,8(sp)
    80002956:	6a02                	ld	s4,0(sp)
    80002958:	6145                	addi	sp,sp,48
    8000295a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000295c:	000a061b          	sext.w	a2,s4
    80002960:	85ce                	mv	a1,s3
    80002962:	854a                	mv	a0,s2
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	3dc080e7          	jalr	988(ra) # 80000d40 <memmove>
    return 0;
    8000296c:	8526                	mv	a0,s1
    8000296e:	bff9                	j	8000294c <either_copyin+0x32>

0000000080002970 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002970:	715d                	addi	sp,sp,-80
    80002972:	e486                	sd	ra,72(sp)
    80002974:	e0a2                	sd	s0,64(sp)
    80002976:	fc26                	sd	s1,56(sp)
    80002978:	f84a                	sd	s2,48(sp)
    8000297a:	f44e                	sd	s3,40(sp)
    8000297c:	f052                	sd	s4,32(sp)
    8000297e:	ec56                	sd	s5,24(sp)
    80002980:	e85a                	sd	s6,16(sp)
    80002982:	e45e                	sd	s7,8(sp)
    80002984:	e062                	sd	s8,0(sp)
    80002986:	0880                	addi	s0,sp,80


  struct proc *p;
  char *state;

  printf("\n");
    80002988:	00006517          	auipc	a0,0x6
    8000298c:	71850513          	addi	a0,a0,1816 # 800090a0 <digits+0x60>
    80002990:	ffffe097          	auipc	ra,0xffffe
    80002994:	be8080e7          	jalr	-1048(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002998:	00010497          	auipc	s1,0x10
    8000299c:	e6848493          	addi	s1,s1,-408 # 80012800 <proc+0xd8>
    800029a0:	00031997          	auipc	s3,0x31
    800029a4:	06098993          	addi	s3,s3,96 # 80033a00 <bcache+0xc0>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029a8:	4b8d                	li	s7,3
      state = states[p->state];
    else
      state = "???";
    800029aa:	00007a17          	auipc	s4,0x7
    800029ae:	91ea0a13          	addi	s4,s4,-1762 # 800092c8 <digits+0x288>
    printf("%d %s %s", p->pid, state, p->name);
    800029b2:	00007b17          	auipc	s6,0x7
    800029b6:	91eb0b13          	addi	s6,s6,-1762 # 800092d0 <digits+0x290>
    printf("\n");
    800029ba:	00006a97          	auipc	s5,0x6
    800029be:	6e6a8a93          	addi	s5,s5,1766 # 800090a0 <digits+0x60>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029c2:	00007c17          	auipc	s8,0x7
    800029c6:	9cec0c13          	addi	s8,s8,-1586 # 80009390 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    800029ca:	6905                	lui	s2,0x1
    800029cc:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    800029d0:	a005                	j	800029f0 <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    800029d2:	f4c6a583          	lw	a1,-180(a3)
    800029d6:	855a                	mv	a0,s6
    800029d8:	ffffe097          	auipc	ra,0xffffe
    800029dc:	ba0080e7          	jalr	-1120(ra) # 80000578 <printf>
    printf("\n");
    800029e0:	8556                	mv	a0,s5
    800029e2:	ffffe097          	auipc	ra,0xffffe
    800029e6:	b96080e7          	jalr	-1130(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800029ea:	94ca                	add	s1,s1,s2
    800029ec:	03348263          	beq	s1,s3,80002a10 <procdump+0xa0>
    if(p->state == UNUSED)
    800029f0:	86a6                	mv	a3,s1
    800029f2:	f404a783          	lw	a5,-192(s1)
    800029f6:	dbf5                	beqz	a5,800029ea <procdump+0x7a>
      state = "???";
    800029f8:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029fa:	fcfbece3          	bltu	s7,a5,800029d2 <procdump+0x62>
    800029fe:	02079713          	slli	a4,a5,0x20
    80002a02:	01d75793          	srli	a5,a4,0x1d
    80002a06:	97e2                	add	a5,a5,s8
    80002a08:	6390                	ld	a2,0(a5)
    80002a0a:	f661                	bnez	a2,800029d2 <procdump+0x62>
      state = "???";
    80002a0c:	8652                	mv	a2,s4
    80002a0e:	b7d1                	j	800029d2 <procdump+0x62>
  }
}
    80002a10:	60a6                	ld	ra,72(sp)
    80002a12:	6406                	ld	s0,64(sp)
    80002a14:	74e2                	ld	s1,56(sp)
    80002a16:	7942                	ld	s2,48(sp)
    80002a18:	79a2                	ld	s3,40(sp)
    80002a1a:	7a02                	ld	s4,32(sp)
    80002a1c:	6ae2                	ld	s5,24(sp)
    80002a1e:	6b42                	ld	s6,16(sp)
    80002a20:	6ba2                	ld	s7,8(sp)
    80002a22:	6c02                	ld	s8,0(sp)
    80002a24:	6161                	addi	sp,sp,80
    80002a26:	8082                	ret

0000000080002a28 <is_valid_sigmask>:

int 
is_valid_sigmask(int sigmask){
    80002a28:	1141                	addi	sp,sp,-16
    80002a2a:	e422                	sd	s0,8(sp)
    80002a2c:	0800                	addi	s0,sp,16
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002a2e:	000207b7          	lui	a5,0x20
    80002a32:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002a36:	8d7d                	and	a0,a0,a5
    return 0;
  return 1;
}
    80002a38:	00153513          	seqz	a0,a0
    80002a3c:	6422                	ld	s0,8(sp)
    80002a3e:	0141                	addi	sp,sp,16
    80002a40:	8082                	ret

0000000080002a42 <sigprocmask>:

uint
sigprocmask(uint new_procmask){
    80002a42:	7179                	addi	sp,sp,-48
    80002a44:	f406                	sd	ra,40(sp)
    80002a46:	f022                	sd	s0,32(sp)
    80002a48:	ec26                	sd	s1,24(sp)
    80002a4a:	e84a                	sd	s2,16(sp)
    80002a4c:	e44e                	sd	s3,8(sp)
    80002a4e:	1800                	addi	s0,sp,48
    80002a50:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002a52:	fffff097          	auipc	ra,0xfffff
    80002a56:	02a080e7          	jalr	42(ra) # 80001a7c <myproc>
  if(is_valid_sigmask(new_procmask) == 0)
    80002a5a:	000207b7          	lui	a5,0x20
    80002a5e:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002a62:	00f977b3          	and	a5,s2,a5
    return -1;
    80002a66:	59fd                	li	s3,-1
  if(is_valid_sigmask(new_procmask) == 0)
    80002a68:	ef99                	bnez	a5,80002a86 <sigprocmask+0x44>
    80002a6a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002a6c:	ffffe097          	auipc	ra,0xffffe
    80002a70:	15a080e7          	jalr	346(ra) # 80000bc6 <acquire>
  int old_procmask = p->signal_mask;
    80002a74:	0ec4a983          	lw	s3,236(s1)
  p->signal_mask = new_procmask;
    80002a78:	0f24a623          	sw	s2,236(s1)
  release(&p->lock);
    80002a7c:	8526                	mv	a0,s1
    80002a7e:	ffffe097          	auipc	ra,0xffffe
    80002a82:	21e080e7          	jalr	542(ra) # 80000c9c <release>
  
  return old_procmask;
}
    80002a86:	854e                	mv	a0,s3
    80002a88:	70a2                	ld	ra,40(sp)
    80002a8a:	7402                	ld	s0,32(sp)
    80002a8c:	64e2                	ld	s1,24(sp)
    80002a8e:	6942                	ld	s2,16(sp)
    80002a90:	69a2                	ld	s3,8(sp)
    80002a92:	6145                	addi	sp,sp,48
    80002a94:	8082                	ret

0000000080002a96 <sigaction>:

 
int 
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
  
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002a96:	0005079b          	sext.w	a5,a0
    80002a9a:	477d                	li	a4,31
    80002a9c:	0cf76a63          	bltu	a4,a5,80002b70 <sigaction+0xda>
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
    80002aa0:	7139                	addi	sp,sp,-64
    80002aa2:	fc06                	sd	ra,56(sp)
    80002aa4:	f822                	sd	s0,48(sp)
    80002aa6:	f426                	sd	s1,40(sp)
    80002aa8:	f04a                	sd	s2,32(sp)
    80002aaa:	ec4e                	sd	s3,24(sp)
    80002aac:	e852                	sd	s4,16(sp)
    80002aae:	0080                	addi	s0,sp,64
    80002ab0:	84aa                	mv	s1,a0
    80002ab2:	89ae                	mv	s3,a1
    80002ab4:	8a32                	mv	s4,a2
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002ab6:	37dd                	addiw	a5,a5,-9
    80002ab8:	9bdd                	andi	a5,a5,-9
    80002aba:	2781                	sext.w	a5,a5
    80002abc:	cfc5                	beqz	a5,80002b74 <sigaction+0xde>
    80002abe:	cdcd                	beqz	a1,80002b78 <sigaction+0xe2>
    return -1;
  struct proc *p = myproc();
    80002ac0:	fffff097          	auipc	ra,0xfffff
    80002ac4:	fbc080e7          	jalr	-68(ra) # 80001a7c <myproc>
    80002ac8:	892a                	mv	s2,a0

  uint new_mask;
  copyin(p->pagetable, (char *)&new_mask, (uint64)&act->sigmask, sizeof(act->sigmask));
    80002aca:	4691                	li	a3,4
    80002acc:	00898613          	addi	a2,s3,8
    80002ad0:	fcc40593          	addi	a1,s0,-52
    80002ad4:	6128                	ld	a0,64(a0)
    80002ad6:	fffff097          	auipc	ra,0xfffff
    80002ada:	c1a080e7          	jalr	-998(ra) # 800016f0 <copyin>
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002ade:	fcc42703          	lw	a4,-52(s0)

  if(is_valid_sigmask(new_mask) == 0)
    80002ae2:	000207b7          	lui	a5,0x20
    80002ae6:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002aea:	8ff9                	and	a5,a5,a4
    80002aec:	ebc1                	bnez	a5,80002b7c <sigaction+0xe6>
    return -1;
  acquire(&p->lock);
    80002aee:	854a                	mv	a0,s2
    80002af0:	ffffe097          	auipc	ra,0xffffe
    80002af4:	0d6080e7          	jalr	214(ra) # 80000bc6 <acquire>

  if(oldact!=0){
    80002af8:	020a0b63          	beqz	s4,80002b2e <sigaction+0x98>
    copyout(p->pagetable, (uint64)&oldact->sa_handler, (char *)&p->signal_handlers[signum], sizeof(act->sa_handler));
    80002afc:	01f48613          	addi	a2,s1,31
    80002b00:	060e                	slli	a2,a2,0x3
    80002b02:	46a1                	li	a3,8
    80002b04:	964a                	add	a2,a2,s2
    80002b06:	85d2                	mv	a1,s4
    80002b08:	04093503          	ld	a0,64(s2)
    80002b0c:	fffff097          	auipc	ra,0xfffff
    80002b10:	b58080e7          	jalr	-1192(ra) # 80001664 <copyout>
    copyout(p->pagetable, (uint64)&oldact->sigmask, (char *)&p->handlers_sigmasks[signum], sizeof(uint));
    80002b14:	07e48613          	addi	a2,s1,126
    80002b18:	060a                	slli	a2,a2,0x2
    80002b1a:	4691                	li	a3,4
    80002b1c:	964a                	add	a2,a2,s2
    80002b1e:	008a0593          	addi	a1,s4,8
    80002b22:	04093503          	ld	a0,64(s2)
    80002b26:	fffff097          	auipc	ra,0xfffff
    80002b2a:	b3e080e7          	jalr	-1218(ra) # 80001664 <copyout>
  }

  p->handlers_sigmasks[signum]=new_mask;
    80002b2e:	07c48793          	addi	a5,s1,124
    80002b32:	078a                	slli	a5,a5,0x2
    80002b34:	97ca                	add	a5,a5,s2
    80002b36:	fcc42703          	lw	a4,-52(s0)
    80002b3a:	c798                	sw	a4,8(a5)
  copyin(p->pagetable, (char *)&p->signal_handlers[signum], (uint64)&act->sa_handler, sizeof(act->sa_handler));
    80002b3c:	04fd                	addi	s1,s1,31
    80002b3e:	048e                	slli	s1,s1,0x3
    80002b40:	46a1                	li	a3,8
    80002b42:	864e                	mv	a2,s3
    80002b44:	009905b3          	add	a1,s2,s1
    80002b48:	04093503          	ld	a0,64(s2)
    80002b4c:	fffff097          	auipc	ra,0xfffff
    80002b50:	ba4080e7          	jalr	-1116(ra) # 800016f0 <copyin>

  release(&p->lock);
    80002b54:	854a                	mv	a0,s2
    80002b56:	ffffe097          	auipc	ra,0xffffe
    80002b5a:	146080e7          	jalr	326(ra) # 80000c9c <release>



  return 0;
    80002b5e:	4501                	li	a0,0
}
    80002b60:	70e2                	ld	ra,56(sp)
    80002b62:	7442                	ld	s0,48(sp)
    80002b64:	74a2                	ld	s1,40(sp)
    80002b66:	7902                	ld	s2,32(sp)
    80002b68:	69e2                	ld	s3,24(sp)
    80002b6a:	6a42                	ld	s4,16(sp)
    80002b6c:	6121                	addi	sp,sp,64
    80002b6e:	8082                	ret
    return -1;
    80002b70:	557d                	li	a0,-1
}
    80002b72:	8082                	ret
    return -1;
    80002b74:	557d                	li	a0,-1
    80002b76:	b7ed                	j	80002b60 <sigaction+0xca>
    80002b78:	557d                	li	a0,-1
    80002b7a:	b7dd                	j	80002b60 <sigaction+0xca>
    return -1;
    80002b7c:	557d                	li	a0,-1
    80002b7e:	b7cd                	j	80002b60 <sigaction+0xca>

0000000080002b80 <sigret>:

void 
sigret(void){
    80002b80:	1101                	addi	sp,sp,-32
    80002b82:	ec06                	sd	ra,24(sp)
    80002b84:	e822                	sd	s0,16(sp)
    80002b86:	e426                	sd	s1,8(sp)
    80002b88:	e04a                	sd	s2,0(sp)
    80002b8a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002b8c:	fffff097          	auipc	ra,0xfffff
    80002b90:	ef0080e7          	jalr	-272(ra) # 80001a7c <myproc>
    80002b94:	84aa                	mv	s1,a0
  struct kthread *t=mykthread();
    80002b96:	fffff097          	auipc	ra,0xfffff
    80002b9a:	f26080e7          	jalr	-218(ra) # 80001abc <mykthread>
    80002b9e:	892a                	mv	s2,a0

  copyin(p->pagetable, (char *)t->trapframe, (uint64)p->user_trapframe_backup, sizeof(struct trapframe));
    80002ba0:	12000693          	li	a3,288
    80002ba4:	2784b603          	ld	a2,632(s1)
    80002ba8:	612c                	ld	a1,64(a0)
    80002baa:	60a8                	ld	a0,64(s1)
    80002bac:	fffff097          	auipc	ra,0xfffff
    80002bb0:	b44080e7          	jalr	-1212(ra) # 800016f0 <copyin>

  // restore user stack pointer
  acquire(&p->lock);
    80002bb4:	8526                	mv	a0,s1
    80002bb6:	ffffe097          	auipc	ra,0xffffe
    80002bba:	010080e7          	jalr	16(ra) # 80000bc6 <acquire>
  // TODO maybe we will need to also lock the kthread lock
  t->trapframe->sp += sizeof(struct trapframe);
    80002bbe:	04093703          	ld	a4,64(s2)
    80002bc2:	7b1c                	ld	a5,48(a4)
    80002bc4:	12078793          	addi	a5,a5,288
    80002bc8:	fb1c                	sd	a5,48(a4)

  p->signal_mask = p->signal_mask_backup;
    80002bca:	0f04a783          	lw	a5,240(s1)
    80002bce:	0ef4a623          	sw	a5,236(s1)
  
  // Allow user signal handler since we finished handling the current
  p->handling_user_sig_flag = 0;
    80002bd2:	2804a023          	sw	zero,640(s1)
  // Allow other thread to react to signals
  p->handling_sig_flag = 0;
    80002bd6:	2804a223          	sw	zero,644(s1)
  release(&p->lock);
    80002bda:	8526                	mv	a0,s1
    80002bdc:	ffffe097          	auipc	ra,0xffffe
    80002be0:	0c0080e7          	jalr	192(ra) # 80000c9c <release>
}
    80002be4:	60e2                	ld	ra,24(sp)
    80002be6:	6442                	ld	s0,16(sp)
    80002be8:	64a2                	ld	s1,8(sp)
    80002bea:	6902                	ld	s2,0(sp)
    80002bec:	6105                	addi	sp,sp,32
    80002bee:	8082                	ret

0000000080002bf0 <turn_on_bit>:

// we call turn on and turn off when holding p->lock
void
turn_on_bit(struct proc* p, int signum){
    80002bf0:	1141                	addi	sp,sp,-16
    80002bf2:	e422                	sd	s0,8(sp)
    80002bf4:	0800                	addi	s0,sp,16
  if(!(p->pending_signals & (1 << signum)))
    80002bf6:	0e852703          	lw	a4,232(a0)
    80002bfa:	4785                	li	a5,1
    80002bfc:	00b795bb          	sllw	a1,a5,a1
    80002c00:	00b777b3          	and	a5,a4,a1
    80002c04:	2781                	sext.w	a5,a5
    80002c06:	e781                	bnez	a5,80002c0e <turn_on_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    80002c08:	8db9                	xor	a1,a1,a4
    80002c0a:	0eb52423          	sw	a1,232(a0)
}
    80002c0e:	6422                	ld	s0,8(sp)
    80002c10:	0141                	addi	sp,sp,16
    80002c12:	8082                	ret

0000000080002c14 <kill>:
{
    80002c14:	7139                	addi	sp,sp,-64
    80002c16:	fc06                	sd	ra,56(sp)
    80002c18:	f822                	sd	s0,48(sp)
    80002c1a:	f426                	sd	s1,40(sp)
    80002c1c:	f04a                	sd	s2,32(sp)
    80002c1e:	ec4e                	sd	s3,24(sp)
    80002c20:	e852                	sd	s4,16(sp)
    80002c22:	e456                	sd	s5,8(sp)
    80002c24:	0080                	addi	s0,sp,64
    80002c26:	892a                	mv	s2,a0
    80002c28:	8aae                	mv	s5,a1
  for(p = proc; p < &proc[NPROC]; p++){
    80002c2a:	00010497          	auipc	s1,0x10
    80002c2e:	afe48493          	addi	s1,s1,-1282 # 80012728 <proc>
    80002c32:	6985                	lui	s3,0x1
    80002c34:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002c38:	00031a17          	auipc	s4,0x31
    80002c3c:	cf0a0a13          	addi	s4,s4,-784 # 80033928 <tickslock>
    acquire(&p->lock);
    80002c40:	8526                	mv	a0,s1
    80002c42:	ffffe097          	auipc	ra,0xffffe
    80002c46:	f84080e7          	jalr	-124(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    80002c4a:	50dc                	lw	a5,36(s1)
    80002c4c:	01278c63          	beq	a5,s2,80002c64 <kill+0x50>
    release(&p->lock);
    80002c50:	8526                	mv	a0,s1
    80002c52:	ffffe097          	auipc	ra,0xffffe
    80002c56:	04a080e7          	jalr	74(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002c5a:	94ce                	add	s1,s1,s3
    80002c5c:	ff4492e3          	bne	s1,s4,80002c40 <kill+0x2c>
  return -1;
    80002c60:	557d                	li	a0,-1
    80002c62:	a049                	j	80002ce4 <kill+0xd0>
      if(p->state != RUNNABLE){
    80002c64:	4c98                	lw	a4,24(s1)
    80002c66:	4789                	li	a5,2
    80002c68:	06f71863          	bne	a4,a5,80002cd8 <kill+0xc4>
      if(p->signal_handlers[signum] == (void*)SIG_IGN){
    80002c6c:	01ea8793          	addi	a5,s5,30
    80002c70:	078e                	slli	a5,a5,0x3
    80002c72:	97a6                	add	a5,a5,s1
    80002c74:	6798                	ld	a4,8(a5)
    80002c76:	4785                	li	a5,1
    80002c78:	06f70f63          	beq	a4,a5,80002cf6 <kill+0xe2>
      turn_on_bit(p,signum);
    80002c7c:	85d6                	mv	a1,s5
    80002c7e:	8526                	mv	a0,s1
    80002c80:	00000097          	auipc	ra,0x0
    80002c84:	f70080e7          	jalr	-144(ra) # 80002bf0 <turn_on_bit>
      release(&p->lock);
    80002c88:	8526                	mv	a0,s1
    80002c8a:	ffffe097          	auipc	ra,0xffffe
    80002c8e:	012080e7          	jalr	18(ra) # 80000c9c <release>
      if(signum == SIGKILL){
    80002c92:	47a5                	li	a5,9
      return 0;
    80002c94:	4501                	li	a0,0
      if(signum == SIGKILL){
    80002c96:	04fa9763          	bne	s5,a5,80002ce4 <kill+0xd0>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002c9a:	28848913          	addi	s2,s1,648
    80002c9e:	6785                	lui	a5,0x1
    80002ca0:	84878793          	addi	a5,a5,-1976 # 848 <_entry-0x7ffff7b8>
    80002ca4:	94be                	add	s1,s1,a5
          if(t->state == RUNNABLE){
    80002ca6:	4989                	li	s3,2
    80002ca8:	01892783          	lw	a5,24(s2)
    80002cac:	07378363          	beq	a5,s3,80002d12 <kill+0xfe>
            acquire(&t->lock);
    80002cb0:	854a                	mv	a0,s2
    80002cb2:	ffffe097          	auipc	ra,0xffffe
    80002cb6:	f14080e7          	jalr	-236(ra) # 80000bc6 <acquire>
            if(t->state==TSLEEPING){
    80002cba:	01892783          	lw	a5,24(s2)
    80002cbe:	05378363          	beq	a5,s3,80002d04 <kill+0xf0>
            release(&t->lock);
    80002cc2:	854a                	mv	a0,s2
    80002cc4:	ffffe097          	auipc	ra,0xffffe
    80002cc8:	fd8080e7          	jalr	-40(ra) # 80000c9c <release>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002ccc:	0b890913          	addi	s2,s2,184
    80002cd0:	fc991ce3          	bne	s2,s1,80002ca8 <kill+0x94>
      return 0;
    80002cd4:	4501                	li	a0,0
    80002cd6:	a039                	j	80002ce4 <kill+0xd0>
        release(&p->lock);
    80002cd8:	8526                	mv	a0,s1
    80002cda:	ffffe097          	auipc	ra,0xffffe
    80002cde:	fc2080e7          	jalr	-62(ra) # 80000c9c <release>
        return -1;
    80002ce2:	557d                	li	a0,-1
}
    80002ce4:	70e2                	ld	ra,56(sp)
    80002ce6:	7442                	ld	s0,48(sp)
    80002ce8:	74a2                	ld	s1,40(sp)
    80002cea:	7902                	ld	s2,32(sp)
    80002cec:	69e2                	ld	s3,24(sp)
    80002cee:	6a42                	ld	s4,16(sp)
    80002cf0:	6aa2                	ld	s5,8(sp)
    80002cf2:	6121                	addi	sp,sp,64
    80002cf4:	8082                	ret
        release(&p->lock);
    80002cf6:	8526                	mv	a0,s1
    80002cf8:	ffffe097          	auipc	ra,0xffffe
    80002cfc:	fa4080e7          	jalr	-92(ra) # 80000c9c <release>
        return 1;
    80002d00:	4505                	li	a0,1
    80002d02:	b7cd                	j	80002ce4 <kill+0xd0>
              release(&t->lock);
    80002d04:	854a                	mv	a0,s2
    80002d06:	ffffe097          	auipc	ra,0xffffe
    80002d0a:	f96080e7          	jalr	-106(ra) # 80000c9c <release>
      return 0;
    80002d0e:	4501                	li	a0,0
              break;
    80002d10:	bfd1                	j	80002ce4 <kill+0xd0>
      return 0;
    80002d12:	4501                	li	a0,0
    80002d14:	bfc1                	j	80002ce4 <kill+0xd0>

0000000080002d16 <turn_off_bit>:

void
turn_off_bit(struct proc* p, int signum){
    80002d16:	1141                	addi	sp,sp,-16
    80002d18:	e422                	sd	s0,8(sp)
    80002d1a:	0800                	addi	s0,sp,16
  if(p->pending_signals & (1 << signum))
    80002d1c:	0e852703          	lw	a4,232(a0)
    80002d20:	4785                	li	a5,1
    80002d22:	00b795bb          	sllw	a1,a5,a1
    80002d26:	00b777b3          	and	a5,a4,a1
    80002d2a:	2781                	sext.w	a5,a5
    80002d2c:	c781                	beqz	a5,80002d34 <turn_off_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    80002d2e:	8db9                	xor	a1,a1,a4
    80002d30:	0eb52423          	sw	a1,232(a0)
}
    80002d34:	6422                	ld	s0,8(sp)
    80002d36:	0141                	addi	sp,sp,16
    80002d38:	8082                	ret

0000000080002d3a <kthread_create>:

int kthread_create(void (*start_func)(), void *stack){
    80002d3a:	7139                	addi	sp,sp,-64
    80002d3c:	fc06                	sd	ra,56(sp)
    80002d3e:	f822                	sd	s0,48(sp)
    80002d40:	f426                	sd	s1,40(sp)
    80002d42:	f04a                	sd	s2,32(sp)
    80002d44:	ec4e                	sd	s3,24(sp)
    80002d46:	e852                	sd	s4,16(sp)
    80002d48:	e456                	sd	s5,8(sp)
    80002d4a:	e05a                	sd	s6,0(sp)
    80002d4c:	0080                	addi	s0,sp,64
    80002d4e:	8b2a                	mv	s6,a0
    80002d50:	8aae                	mv	s5,a1
  struct proc *p = myproc();
    80002d52:	fffff097          	auipc	ra,0xfffff
    80002d56:	d2a080e7          	jalr	-726(ra) # 80001a7c <myproc>
    80002d5a:	8a2a                	mv	s4,a0
  struct kthread *curr_t = mykthread();
    80002d5c:	fffff097          	auipc	ra,0xfffff
    80002d60:	d60080e7          	jalr	-672(ra) # 80001abc <mykthread>
    80002d64:	89aa                	mv	s3,a0
  struct kthread *other_t;

  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    80002d66:	288a0493          	addi	s1,s4,648
    80002d6a:	6905                	lui	s2,0x1
    80002d6c:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002d70:	9952                	add	s2,s2,s4
    80002d72:	a861                	j	80002e0a <kthread_create+0xd0>
  t->tid = 0;
    80002d74:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80002d78:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80002d7c:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80002d80:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80002d84:	0004ac23          	sw	zero,24(s1)

    if(curr_t != other_t){
      acquire(&other_t->lock);
      if(other_t->state == TUNUSED){
          freethread(other_t);  // free memory in case this thread entry was previously used
          init_thread(other_t);
    80002d88:	8526                	mv	a0,s1
    80002d8a:	fffff097          	auipc	ra,0xfffff
    80002d8e:	e44080e7          	jalr	-444(ra) # 80001bce <init_thread>
          
          
          *(other_t->trapframe) = *(curr_t->trapframe);
    80002d92:	0409b683          	ld	a3,64(s3)
    80002d96:	87b6                	mv	a5,a3
    80002d98:	60b8                	ld	a4,64(s1)
    80002d9a:	12068693          	addi	a3,a3,288
    80002d9e:	0007b803          	ld	a6,0(a5)
    80002da2:	6788                	ld	a0,8(a5)
    80002da4:	6b8c                	ld	a1,16(a5)
    80002da6:	6f90                	ld	a2,24(a5)
    80002da8:	01073023          	sd	a6,0(a4) # 20000 <_entry-0x7ffe0000>
    80002dac:	e708                	sd	a0,8(a4)
    80002dae:	eb0c                	sd	a1,16(a4)
    80002db0:	ef10                	sd	a2,24(a4)
    80002db2:	02078793          	addi	a5,a5,32
    80002db6:	02070713          	addi	a4,a4,32
    80002dba:	fed792e3          	bne	a5,a3,80002d9e <kthread_create+0x64>
          other_t->trapframe->sp = (uint64)stack + MAX_STACK_SIZE-16;
    80002dbe:	60b8                	ld	a4,64(s1)
    80002dc0:	6785                	lui	a5,0x1
    80002dc2:	f9078793          	addi	a5,a5,-112 # f90 <_entry-0x7ffff070>
    80002dc6:	9abe                	add	s5,s5,a5
    80002dc8:	03573823          	sd	s5,48(a4)

          other_t->trapframe->epc = (uint64)start_func;
    80002dcc:	60bc                	ld	a5,64(s1)
    80002dce:	0167bc23          	sd	s6,24(a5)
          release(&other_t->lock);
    80002dd2:	8526                	mv	a0,s1
    80002dd4:	ffffe097          	auipc	ra,0xffffe
    80002dd8:	ec8080e7          	jalr	-312(ra) # 80000c9c <release>
          acquire(&p->lock);
    80002ddc:	8552                	mv	a0,s4
    80002dde:	ffffe097          	auipc	ra,0xffffe
    80002de2:	de8080e7          	jalr	-536(ra) # 80000bc6 <acquire>
          p->active_threads++;
    80002de6:	028a2783          	lw	a5,40(s4)
    80002dea:	2785                	addiw	a5,a5,1
    80002dec:	02fa2423          	sw	a5,40(s4)
          release(&p->lock);
    80002df0:	8552                	mv	a0,s4
    80002df2:	ffffe097          	auipc	ra,0xffffe
    80002df6:	eaa080e7          	jalr	-342(ra) # 80000c9c <release>
          other_t->state = TRUNNABLE;
    80002dfa:	478d                	li	a5,3
    80002dfc:	cc9c                	sw	a5,24(s1)
          return other_t->tid;
    80002dfe:	5888                	lw	a0,48(s1)
    80002e00:	a02d                	j	80002e2a <kthread_create+0xf0>
  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    80002e02:	0b848493          	addi	s1,s1,184
    80002e06:	02990163          	beq	s2,s1,80002e28 <kthread_create+0xee>
    if(curr_t != other_t){
    80002e0a:	fe998ce3          	beq	s3,s1,80002e02 <kthread_create+0xc8>
      acquire(&other_t->lock);
    80002e0e:	8526                	mv	a0,s1
    80002e10:	ffffe097          	auipc	ra,0xffffe
    80002e14:	db6080e7          	jalr	-586(ra) # 80000bc6 <acquire>
      if(other_t->state == TUNUSED){
    80002e18:	4c9c                	lw	a5,24(s1)
    80002e1a:	dfa9                	beqz	a5,80002d74 <kthread_create+0x3a>
      }
      release(&other_t->lock);
    80002e1c:	8526                	mv	a0,s1
    80002e1e:	ffffe097          	auipc	ra,0xffffe
    80002e22:	e7e080e7          	jalr	-386(ra) # 80000c9c <release>
    80002e26:	bff1                	j	80002e02 <kthread_create+0xc8>
    }
  }
  return -1;
    80002e28:	557d                	li	a0,-1
}
    80002e2a:	70e2                	ld	ra,56(sp)
    80002e2c:	7442                	ld	s0,48(sp)
    80002e2e:	74a2                	ld	s1,40(sp)
    80002e30:	7902                	ld	s2,32(sp)
    80002e32:	69e2                	ld	s3,24(sp)
    80002e34:	6a42                	ld	s4,16(sp)
    80002e36:	6aa2                	ld	s5,8(sp)
    80002e38:	6b02                	ld	s6,0(sp)
    80002e3a:	6121                	addi	sp,sp,64
    80002e3c:	8082                	ret

0000000080002e3e <kthread_join>:



int
kthread_join(int thread_id, int* status){
    80002e3e:	7139                	addi	sp,sp,-64
    80002e40:	fc06                	sd	ra,56(sp)
    80002e42:	f822                	sd	s0,48(sp)
    80002e44:	f426                	sd	s1,40(sp)
    80002e46:	f04a                	sd	s2,32(sp)
    80002e48:	ec4e                	sd	s3,24(sp)
    80002e4a:	e852                	sd	s4,16(sp)
    80002e4c:	e456                	sd	s5,8(sp)
    80002e4e:	e05a                	sd	s6,0(sp)
    80002e50:	0080                	addi	s0,sp,64
    80002e52:	8a2a                	mv	s4,a0
    80002e54:	8b2e                	mv	s6,a1
  struct kthread *nt;
  struct proc *p = myproc();
    80002e56:	fffff097          	auipc	ra,0xfffff
    80002e5a:	c26080e7          	jalr	-986(ra) # 80001a7c <myproc>
    80002e5e:	8aaa                	mv	s5,a0
  struct kthread *t = mykthread();
    80002e60:	fffff097          	auipc	ra,0xfffff
    80002e64:	c5c080e7          	jalr	-932(ra) # 80001abc <mykthread>



  if(thread_id == t->tid)
    80002e68:	591c                	lw	a5,48(a0)
    80002e6a:	15478563          	beq	a5,s4,80002fb4 <kthread_join+0x176>
    80002e6e:	89aa                	mv	s3,a0
    return -1;

  acquire(&wait_lock);
    80002e70:	0000f517          	auipc	a0,0xf
    80002e74:	46050513          	addi	a0,a0,1120 # 800122d0 <wait_lock>
    80002e78:	ffffe097          	auipc	ra,0xffffe
    80002e7c:	d4e080e7          	jalr	-690(ra) # 80000bc6 <acquire>
  // Search for thread in the procces threads array
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){
    80002e80:	288a8913          	addi	s2,s5,648
    80002e84:	6485                	lui	s1,0x1
    80002e86:	84848493          	addi	s1,s1,-1976 # 848 <_entry-0x7ffff7b8>
    80002e8a:	94d6                	add	s1,s1,s5
    80002e8c:	a029                	j	80002e96 <kthread_join+0x58>
    80002e8e:	0b890913          	addi	s2,s2,184
    80002e92:	03248363          	beq	s1,s2,80002eb8 <kthread_join+0x7a>
    if(nt != t){
    80002e96:	ff298ce3          	beq	s3,s2,80002e8e <kthread_join+0x50>
      acquire(&nt->lock);
    80002e9a:	854a                	mv	a0,s2
    80002e9c:	ffffe097          	auipc	ra,0xffffe
    80002ea0:	d2a080e7          	jalr	-726(ra) # 80000bc6 <acquire>

      if(nt->tid == thread_id){
    80002ea4:	03092783          	lw	a5,48(s2)
    80002ea8:	0b478d63          	beq	a5,s4,80002f62 <kthread_join+0x124>
        //found target thread 
        break;
      }
      release(&nt->lock);
    80002eac:	854a                	mv	a0,s2
    80002eae:	ffffe097          	auipc	ra,0xffffe
    80002eb2:	dee080e7          	jalr	-530(ra) # 80000c9c <release>
    80002eb6:	bfe1                	j	80002e8e <kthread_join+0x50>
    }
  }

  if(nt->tid != thread_id){
    80002eb8:	6785                	lui	a5,0x1
    80002eba:	97d6                	add	a5,a5,s5
    80002ebc:	8787a783          	lw	a5,-1928(a5) # 878 <_entry-0x7ffff788>
    80002ec0:	09479763          	bne	a5,s4,80002f4e <kthread_join+0x110>
  }
  
  // Wait for thread to terminate
  // still holding nt lock
  for(;;){
      if(nt->state==TUNUSED){
    80002ec4:	4c9c                	lw	a5,24(s1)
      release(&nt->lock);
      release(&wait_lock);
      return -1;
    }
    release(&nt->lock);
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    80002ec6:	0000f917          	auipc	s2,0xf
    80002eca:	40a90913          	addi	s2,s2,1034 # 800122d0 <wait_lock>
      if(nt->state==TUNUSED){
    80002ece:	cb8d                	beqz	a5,80002f00 <kthread_join+0xc2>
    if(t->killed || nt->tid!=thread_id){
    80002ed0:	0289a783          	lw	a5,40(s3)
    80002ed4:	ebc5                	bnez	a5,80002f84 <kthread_join+0x146>
    80002ed6:	589c                	lw	a5,48(s1)
    80002ed8:	0b479663          	bne	a5,s4,80002f84 <kthread_join+0x146>
    release(&nt->lock);
    80002edc:	8526                	mv	a0,s1
    80002ede:	ffffe097          	auipc	ra,0xffffe
    80002ee2:	dbe080e7          	jalr	-578(ra) # 80000c9c <release>
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    80002ee6:	85ca                	mv	a1,s2
    80002ee8:	8526                	mv	a0,s1
    80002eea:	fffff097          	auipc	ra,0xfffff
    80002eee:	4d8080e7          	jalr	1240(ra) # 800023c2 <sleep>
    acquire(&nt->lock);
    80002ef2:	8526                	mv	a0,s1
    80002ef4:	ffffe097          	auipc	ra,0xffffe
    80002ef8:	cd2080e7          	jalr	-814(ra) # 80000bc6 <acquire>
      if(nt->state==TUNUSED){
    80002efc:	4c9c                	lw	a5,24(s1)
    80002efe:	fbe9                	bnez	a5,80002ed0 <kthread_join+0x92>
        if(status != 0 && copyout(p->pagetable, status, (char *)&nt->xstate,sizeof(nt->xstate)) < 0) {
    80002f00:	000b0e63          	beqz	s6,80002f1c <kthread_join+0xde>
    80002f04:	4691                	li	a3,4
    80002f06:	02c48613          	addi	a2,s1,44
    80002f0a:	85da                	mv	a1,s6
    80002f0c:	040ab503          	ld	a0,64(s5)
    80002f10:	ffffe097          	auipc	ra,0xffffe
    80002f14:	754080e7          	jalr	1876(ra) # 80001664 <copyout>
    80002f18:	04054763          	bltz	a0,80002f66 <kthread_join+0x128>
  t->tid = 0;
    80002f1c:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80002f20:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80002f24:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80002f28:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80002f2c:	0004ac23          	sw	zero,24(s1)
        release(&nt->lock);
    80002f30:	8526                	mv	a0,s1
    80002f32:	ffffe097          	auipc	ra,0xffffe
    80002f36:	d6a080e7          	jalr	-662(ra) # 80000c9c <release>
        release(&wait_lock);  //  successfull join
    80002f3a:	0000f517          	auipc	a0,0xf
    80002f3e:	39650513          	addi	a0,a0,918 # 800122d0 <wait_lock>
    80002f42:	ffffe097          	auipc	ra,0xffffe
    80002f46:	d5a080e7          	jalr	-678(ra) # 80000c9c <release>
        return 0;
    80002f4a:	4501                	li	a0,0
    80002f4c:	a891                	j	80002fa0 <kthread_join+0x162>
    release(&wait_lock);
    80002f4e:	0000f517          	auipc	a0,0xf
    80002f52:	38250513          	addi	a0,a0,898 # 800122d0 <wait_lock>
    80002f56:	ffffe097          	auipc	ra,0xffffe
    80002f5a:	d46080e7          	jalr	-698(ra) # 80000c9c <release>
    return -1;
    80002f5e:	557d                	li	a0,-1
    80002f60:	a081                	j	80002fa0 <kthread_join+0x162>
    80002f62:	84ca                	mv	s1,s2
    80002f64:	b785                	j	80002ec4 <kthread_join+0x86>
           release(&nt->lock);
    80002f66:	8526                	mv	a0,s1
    80002f68:	ffffe097          	auipc	ra,0xffffe
    80002f6c:	d34080e7          	jalr	-716(ra) # 80000c9c <release>
           release(&wait_lock);
    80002f70:	0000f517          	auipc	a0,0xf
    80002f74:	36050513          	addi	a0,a0,864 # 800122d0 <wait_lock>
    80002f78:	ffffe097          	auipc	ra,0xffffe
    80002f7c:	d24080e7          	jalr	-732(ra) # 80000c9c <release>
           return -1;                   
    80002f80:	557d                	li	a0,-1
    80002f82:	a839                	j	80002fa0 <kthread_join+0x162>
      release(&nt->lock);
    80002f84:	8526                	mv	a0,s1
    80002f86:	ffffe097          	auipc	ra,0xffffe
    80002f8a:	d16080e7          	jalr	-746(ra) # 80000c9c <release>
      release(&wait_lock);
    80002f8e:	0000f517          	auipc	a0,0xf
    80002f92:	34250513          	addi	a0,a0,834 # 800122d0 <wait_lock>
    80002f96:	ffffe097          	auipc	ra,0xffffe
    80002f9a:	d06080e7          	jalr	-762(ra) # 80000c9c <release>
      return -1;
    80002f9e:	557d                	li	a0,-1
  }
}
    80002fa0:	70e2                	ld	ra,56(sp)
    80002fa2:	7442                	ld	s0,48(sp)
    80002fa4:	74a2                	ld	s1,40(sp)
    80002fa6:	7902                	ld	s2,32(sp)
    80002fa8:	69e2                	ld	s3,24(sp)
    80002faa:	6a42                	ld	s4,16(sp)
    80002fac:	6aa2                	ld	s5,8(sp)
    80002fae:	6b02                	ld	s6,0(sp)
    80002fb0:	6121                	addi	sp,sp,64
    80002fb2:	8082                	ret
    return -1;
    80002fb4:	557d                	li	a0,-1
    80002fb6:	b7ed                	j	80002fa0 <kthread_join+0x162>

0000000080002fb8 <kthread_join_all>:

int
kthread_join_all(){
    80002fb8:	7179                	addi	sp,sp,-48
    80002fba:	f406                	sd	ra,40(sp)
    80002fbc:	f022                	sd	s0,32(sp)
    80002fbe:	ec26                	sd	s1,24(sp)
    80002fc0:	e84a                	sd	s2,16(sp)
    80002fc2:	e44e                	sd	s3,8(sp)
    80002fc4:	e052                	sd	s4,0(sp)
    80002fc6:	1800                	addi	s0,sp,48
  struct proc *p=myproc();
    80002fc8:	fffff097          	auipc	ra,0xfffff
    80002fcc:	ab4080e7          	jalr	-1356(ra) # 80001a7c <myproc>
    80002fd0:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    80002fd2:	fffff097          	auipc	ra,0xfffff
    80002fd6:	aea080e7          	jalr	-1302(ra) # 80001abc <mykthread>
    80002fda:	8a2a                	mv	s4,a0
  struct kthread *nt;
  int res = 1;
  for(nt = p->kthreads; nt < &p->kthreads[NTHREAD]; nt++){
    80002fdc:	28898493          	addi	s1,s3,648
    80002fe0:	6505                	lui	a0,0x1
    80002fe2:	84850513          	addi	a0,a0,-1976 # 848 <_entry-0x7ffff7b8>
    80002fe6:	99aa                	add	s3,s3,a0
  int res = 1;
    80002fe8:	4905                	li	s2,1
    80002fea:	a029                	j	80002ff4 <kthread_join_all+0x3c>
  for(nt = p->kthreads; nt < &p->kthreads[NTHREAD]; nt++){
    80002fec:	0b848493          	addi	s1,s1,184
    80002ff0:	00998e63          	beq	s3,s1,8000300c <kthread_join_all+0x54>
    if(nt != t){
    80002ff4:	fe9a0ce3          	beq	s4,s1,80002fec <kthread_join_all+0x34>
      int thread_index = (int)(nt - p->kthreads);
      res &= kthread_join(nt->tid,0);
    80002ff8:	4581                	li	a1,0
    80002ffa:	5888                	lw	a0,48(s1)
    80002ffc:	00000097          	auipc	ra,0x0
    80003000:	e42080e7          	jalr	-446(ra) # 80002e3e <kthread_join>
    80003004:	01257933          	and	s2,a0,s2
    80003008:	2901                	sext.w	s2,s2
    8000300a:	b7cd                	j	80002fec <kthread_join_all+0x34>
    }
  }

  return res;
}
    8000300c:	854a                	mv	a0,s2
    8000300e:	70a2                	ld	ra,40(sp)
    80003010:	7402                	ld	s0,32(sp)
    80003012:	64e2                	ld	s1,24(sp)
    80003014:	6942                	ld	s2,16(sp)
    80003016:	69a2                	ld	s3,8(sp)
    80003018:	6a02                	ld	s4,0(sp)
    8000301a:	6145                	addi	sp,sp,48
    8000301c:	8082                	ret

000000008000301e <printTF>:


void 
printTF(struct kthread *t){//function for debuging, TODO delete
    8000301e:	7175                	addi	sp,sp,-144
    80003020:	e506                	sd	ra,136(sp)
    80003022:	e122                	sd	s0,128(sp)
    80003024:	fca6                	sd	s1,120(sp)
    80003026:	0900                	addi	s0,sp,144
    80003028:	84aa                	mv	s1,a0
  printf("**************tid=%d*****************\n",t->tid);
    8000302a:	590c                	lw	a1,48(a0)
    8000302c:	00006517          	auipc	a0,0x6
    80003030:	2b450513          	addi	a0,a0,692 # 800092e0 <digits+0x2a0>
    80003034:	ffffd097          	auipc	ra,0xffffd
    80003038:	544080e7          	jalr	1348(ra) # 80000578 <printf>
  // printf("t->tf->epc = %p\n",t->trapframe->epc);
  // printf("t->tf->ra = %p\n",t->trapframe->ra);
  // printf("t->tf->kernel_sp = %p\n",t->trapframe->kernel_sp);
  printf("t->kstack = %p\n",t->kstack);
    8000303c:	7c8c                	ld	a1,56(s1)
    8000303e:	00006517          	auipc	a0,0x6
    80003042:	2ca50513          	addi	a0,a0,714 # 80009308 <digits+0x2c8>
    80003046:	ffffd097          	auipc	ra,0xffffd
    8000304a:	532080e7          	jalr	1330(ra) # 80000578 <printf>
  printf("t->context = %p\n",t->context);
    8000304e:	04848793          	addi	a5,s1,72
    80003052:	f7040713          	addi	a4,s0,-144
    80003056:	0a848693          	addi	a3,s1,168
    8000305a:	0007b803          	ld	a6,0(a5)
    8000305e:	6788                	ld	a0,8(a5)
    80003060:	6b8c                	ld	a1,16(a5)
    80003062:	6f90                	ld	a2,24(a5)
    80003064:	01073023          	sd	a6,0(a4)
    80003068:	e708                	sd	a0,8(a4)
    8000306a:	eb0c                	sd	a1,16(a4)
    8000306c:	ef10                	sd	a2,24(a4)
    8000306e:	02078793          	addi	a5,a5,32
    80003072:	02070713          	addi	a4,a4,32
    80003076:	fed792e3          	bne	a5,a3,8000305a <printTF+0x3c>
    8000307a:	6394                	ld	a3,0(a5)
    8000307c:	679c                	ld	a5,8(a5)
    8000307e:	e314                	sd	a3,0(a4)
    80003080:	e71c                	sd	a5,8(a4)
    80003082:	f7040593          	addi	a1,s0,-144
    80003086:	00006517          	auipc	a0,0x6
    8000308a:	29250513          	addi	a0,a0,658 # 80009318 <digits+0x2d8>
    8000308e:	ffffd097          	auipc	ra,0xffffd
    80003092:	4ea080e7          	jalr	1258(ra) # 80000578 <printf>
  printf("t->tf->sp = %p\n",t->trapframe->sp);
    80003096:	60bc                	ld	a5,64(s1)
    80003098:	7b8c                	ld	a1,48(a5)
    8000309a:	00006517          	auipc	a0,0x6
    8000309e:	29650513          	addi	a0,a0,662 # 80009330 <digits+0x2f0>
    800030a2:	ffffd097          	auipc	ra,0xffffd
    800030a6:	4d6080e7          	jalr	1238(ra) # 80000578 <printf>
  printf("t->state = %d\n",t->state);
    800030aa:	4c8c                	lw	a1,24(s1)
    800030ac:	00006517          	auipc	a0,0x6
    800030b0:	29450513          	addi	a0,a0,660 # 80009340 <digits+0x300>
    800030b4:	ffffd097          	auipc	ra,0xffffd
    800030b8:	4c4080e7          	jalr	1220(ra) # 80000578 <printf>
  printf("**************************************\n",t->tid);
    800030bc:	588c                	lw	a1,48(s1)
    800030be:	00006517          	auipc	a0,0x6
    800030c2:	29250513          	addi	a0,a0,658 # 80009350 <digits+0x310>
    800030c6:	ffffd097          	auipc	ra,0xffffd
    800030ca:	4b2080e7          	jalr	1202(ra) # 80000578 <printf>

    800030ce:	60aa                	ld	ra,136(sp)
    800030d0:	640a                	ld	s0,128(sp)
    800030d2:	74e6                	ld	s1,120(sp)
    800030d4:	6149                	addi	sp,sp,144
    800030d6:	8082                	ret

00000000800030d8 <swtch>:
    800030d8:	00153023          	sd	ra,0(a0)
    800030dc:	00253423          	sd	sp,8(a0)
    800030e0:	e900                	sd	s0,16(a0)
    800030e2:	ed04                	sd	s1,24(a0)
    800030e4:	03253023          	sd	s2,32(a0)
    800030e8:	03353423          	sd	s3,40(a0)
    800030ec:	03453823          	sd	s4,48(a0)
    800030f0:	03553c23          	sd	s5,56(a0)
    800030f4:	05653023          	sd	s6,64(a0)
    800030f8:	05753423          	sd	s7,72(a0)
    800030fc:	05853823          	sd	s8,80(a0)
    80003100:	05953c23          	sd	s9,88(a0)
    80003104:	07a53023          	sd	s10,96(a0)
    80003108:	07b53423          	sd	s11,104(a0)
    8000310c:	0005b083          	ld	ra,0(a1)
    80003110:	0085b103          	ld	sp,8(a1)
    80003114:	6980                	ld	s0,16(a1)
    80003116:	6d84                	ld	s1,24(a1)
    80003118:	0205b903          	ld	s2,32(a1)
    8000311c:	0285b983          	ld	s3,40(a1)
    80003120:	0305ba03          	ld	s4,48(a1)
    80003124:	0385ba83          	ld	s5,56(a1)
    80003128:	0405bb03          	ld	s6,64(a1)
    8000312c:	0485bb83          	ld	s7,72(a1)
    80003130:	0505bc03          	ld	s8,80(a1)
    80003134:	0585bc83          	ld	s9,88(a1)
    80003138:	0605bd03          	ld	s10,96(a1)
    8000313c:	0685bd83          	ld	s11,104(a1)
    80003140:	8082                	ret

0000000080003142 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80003142:	1141                	addi	sp,sp,-16
    80003144:	e406                	sd	ra,8(sp)
    80003146:	e022                	sd	s0,0(sp)
    80003148:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000314a:	00006597          	auipc	a1,0x6
    8000314e:	26658593          	addi	a1,a1,614 # 800093b0 <states.0+0x20>
    80003152:	00030517          	auipc	a0,0x30
    80003156:	7d650513          	addi	a0,a0,2006 # 80033928 <tickslock>
    8000315a:	ffffe097          	auipc	ra,0xffffe
    8000315e:	9dc080e7          	jalr	-1572(ra) # 80000b36 <initlock>
}
    80003162:	60a2                	ld	ra,8(sp)
    80003164:	6402                	ld	s0,0(sp)
    80003166:	0141                	addi	sp,sp,16
    80003168:	8082                	ret

000000008000316a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000316a:	1141                	addi	sp,sp,-16
    8000316c:	e422                	sd	s0,8(sp)
    8000316e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003170:	00004797          	auipc	a5,0x4
    80003174:	ac078793          	addi	a5,a5,-1344 # 80006c30 <kernelvec>
    80003178:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000317c:	6422                	ld	s0,8(sp)
    8000317e:	0141                	addi	sp,sp,16
    80003180:	8082                	ret

0000000080003182 <check_should_cont>:
}

int 
check_should_cont(struct proc *p){
  for(int i=0;i<32;i++){
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    80003182:	0e852303          	lw	t1,232(a0)
    80003186:	0f850813          	addi	a6,a0,248
    8000318a:	4685                	li	a3,1
    8000318c:	4701                	li	a4,0
    8000318e:	4885                	li	a7,1
  for(int i=0;i<32;i++){
    80003190:	4e7d                	li	t3,31
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    80003192:	4ecd                	li	t4,19
    80003194:	a801                	j	800031a4 <check_should_cont+0x22>
  for(int i=0;i<32;i++){
    80003196:	0006879b          	sext.w	a5,a3
    8000319a:	04fe4663          	blt	t3,a5,800031e6 <check_should_cont+0x64>
    8000319e:	2705                	addiw	a4,a4,1
    800031a0:	2685                	addiw	a3,a3,1
    800031a2:	0821                	addi	a6,a6,8
    800031a4:	0007059b          	sext.w	a1,a4
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    800031a8:	00e8963b          	sllw	a2,a7,a4
    800031ac:	00c377b3          	and	a5,t1,a2
    800031b0:	2781                	sext.w	a5,a5
    800031b2:	d3f5                	beqz	a5,80003196 <check_should_cont+0x14>
    800031b4:	0ec52783          	lw	a5,236(a0)
    800031b8:	8ff1                	and	a5,a5,a2
    800031ba:	2781                	sext.w	a5,a5
    800031bc:	ffe9                	bnez	a5,80003196 <check_should_cont+0x14>
    800031be:	00083783          	ld	a5,0(a6)
    800031c2:	01d78563          	beq	a5,t4,800031cc <check_should_cont+0x4a>
    800031c6:	fdd598e3          	bne	a1,t4,80003196 <check_should_cont+0x14>
          (i == SIGCONT && p->signal_handlers[i] == SIG_DFL))){
    800031ca:	fbf1                	bnez	a5,8000319e <check_should_cont+0x1c>
check_should_cont(struct proc *p){
    800031cc:	1141                	addi	sp,sp,-16
    800031ce:	e406                	sd	ra,8(sp)
    800031d0:	e022                	sd	s0,0(sp)
    800031d2:	0800                	addi	s0,sp,16
        turn_off_bit(p, i);
    800031d4:	00000097          	auipc	ra,0x0
    800031d8:	b42080e7          	jalr	-1214(ra) # 80002d16 <turn_off_bit>
        return 1;
    800031dc:	4505                	li	a0,1
      }
  }
  return 0;
}
    800031de:	60a2                	ld	ra,8(sp)
    800031e0:	6402                	ld	s0,0(sp)
    800031e2:	0141                	addi	sp,sp,16
    800031e4:	8082                	ret
  return 0;
    800031e6:	4501                	li	a0,0
}
    800031e8:	8082                	ret

00000000800031ea <handle_stop>:



void
handle_stop(struct proc* p){
    800031ea:	7139                	addi	sp,sp,-64
    800031ec:	fc06                	sd	ra,56(sp)
    800031ee:	f822                	sd	s0,48(sp)
    800031f0:	f426                	sd	s1,40(sp)
    800031f2:	f04a                	sd	s2,32(sp)
    800031f4:	ec4e                	sd	s3,24(sp)
    800031f6:	e852                	sd	s4,16(sp)
    800031f8:	e456                	sd	s5,8(sp)
    800031fa:	e05a                	sd	s6,0(sp)
    800031fc:	0080                	addi	s0,sp,64
    800031fe:	89aa                	mv	s3,a0

  struct kthread *t;
  struct kthread *curr_t = mykthread();
    80003200:	fffff097          	auipc	ra,0xfffff
    80003204:	8bc080e7          	jalr	-1860(ra) # 80001abc <mykthread>
    80003208:	8aaa                	mv	s5,a0


  // Make all other threads belong to the same procces freeze 
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    8000320a:	28898493          	addi	s1,s3,648
    8000320e:	6a05                	lui	s4,0x1
    80003210:	848a0a13          	addi	s4,s4,-1976 # 848 <_entry-0x7ffff7b8>
    80003214:	9a4e                	add	s4,s4,s3
    80003216:	8926                	mv	s2,s1
    if(t!=curr_t){
      acquire(&t->lock);
      t->frozen=1;
    80003218:	4b05                	li	s6,1
    8000321a:	a029                	j	80003224 <handle_stop+0x3a>
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    8000321c:	0b890913          	addi	s2,s2,184
    80003220:	03490163          	beq	s2,s4,80003242 <handle_stop+0x58>
    if(t!=curr_t){
    80003224:	ff2a8ce3          	beq	s5,s2,8000321c <handle_stop+0x32>
      acquire(&t->lock);
    80003228:	854a                	mv	a0,s2
    8000322a:	ffffe097          	auipc	ra,0xffffe
    8000322e:	99c080e7          	jalr	-1636(ra) # 80000bc6 <acquire>
      t->frozen=1;
    80003232:	03692a23          	sw	s6,52(s2)
      release(&t->lock);
    80003236:	854a                	mv	a0,s2
    80003238:	ffffe097          	auipc	ra,0xffffe
    8000323c:	a64080e7          	jalr	-1436(ra) # 80000c9c <release>
    80003240:	bff1                	j	8000321c <handle_stop+0x32>
    }
  }
  int should_cont = check_should_cont(p);
    80003242:	854e                	mv	a0,s3
    80003244:	00000097          	auipc	ra,0x0
    80003248:	f3e080e7          	jalr	-194(ra) # 80003182 <check_should_cont>
  
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    8000324c:	0e89a783          	lw	a5,232(s3)
    80003250:	2007f793          	andi	a5,a5,512
    80003254:	e795                	bnez	a5,80003280 <handle_stop+0x96>
    80003256:	e50d                	bnez	a0,80003280 <handle_stop+0x96>
    
    yield();
    80003258:	fffff097          	auipc	ra,0xfffff
    8000325c:	12e080e7          	jalr	302(ra) # 80002386 <yield>
    should_cont = check_should_cont(p);  
    80003260:	854e                	mv	a0,s3
    80003262:	00000097          	auipc	ra,0x0
    80003266:	f20080e7          	jalr	-224(ra) # 80003182 <check_should_cont>
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    8000326a:	0e89a783          	lw	a5,232(s3)
    8000326e:	2007f793          	andi	a5,a5,512
    80003272:	e799                	bnez	a5,80003280 <handle_stop+0x96>
    80003274:	d175                	beqz	a0,80003258 <handle_stop+0x6e>
    80003276:	a029                	j	80003280 <handle_stop+0x96>
    
  }

  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    80003278:	0b848493          	addi	s1,s1,184
    8000327c:	03448163          	beq	s1,s4,8000329e <handle_stop+0xb4>
    if(t!=curr_t){
    80003280:	fe9a8ce3          	beq	s5,s1,80003278 <handle_stop+0x8e>
      acquire(&t->lock);
    80003284:	8526                	mv	a0,s1
    80003286:	ffffe097          	auipc	ra,0xffffe
    8000328a:	940080e7          	jalr	-1728(ra) # 80000bc6 <acquire>
      t->frozen=0;
    8000328e:	0204aa23          	sw	zero,52(s1)
      release(&t->lock);
    80003292:	8526                	mv	a0,s1
    80003294:	ffffe097          	auipc	ra,0xffffe
    80003298:	a08080e7          	jalr	-1528(ra) # 80000c9c <release>
    8000329c:	bff1                	j	80003278 <handle_stop+0x8e>
    }
  }
  if(p->pending_signals&1<<SIGKILL)
    8000329e:	0e89a783          	lw	a5,232(s3)
    800032a2:	2007f793          	andi	a5,a5,512
    800032a6:	c781                	beqz	a5,800032ae <handle_stop+0xc4>
    p->killed=1;
    800032a8:	4785                	li	a5,1
    800032aa:	00f9ae23          	sw	a5,28(s3)
}
    800032ae:	70e2                	ld	ra,56(sp)
    800032b0:	7442                	ld	s0,48(sp)
    800032b2:	74a2                	ld	s1,40(sp)
    800032b4:	7902                	ld	s2,32(sp)
    800032b6:	69e2                	ld	s3,24(sp)
    800032b8:	6a42                	ld	s4,16(sp)
    800032ba:	6aa2                	ld	s5,8(sp)
    800032bc:	6b02                	ld	s6,0(sp)
    800032be:	6121                	addi	sp,sp,64
    800032c0:	8082                	ret

00000000800032c2 <check_pending_signals>:

void 
check_pending_signals(struct proc* p){
    800032c2:	711d                	addi	sp,sp,-96
    800032c4:	ec86                	sd	ra,88(sp)
    800032c6:	e8a2                	sd	s0,80(sp)
    800032c8:	e4a6                	sd	s1,72(sp)
    800032ca:	e0ca                	sd	s2,64(sp)
    800032cc:	fc4e                	sd	s3,56(sp)
    800032ce:	f852                	sd	s4,48(sp)
    800032d0:	f456                	sd	s5,40(sp)
    800032d2:	f05a                	sd	s6,32(sp)
    800032d4:	ec5e                	sd	s7,24(sp)
    800032d6:	e862                	sd	s8,16(sp)
    800032d8:	e466                	sd	s9,8(sp)
    800032da:	e06a                	sd	s10,0(sp)
    800032dc:	1080                	addi	s0,sp,96
    800032de:	89aa                	mv	s3,a0
  // if(p->pid==4){
    
  //   if(p->pending_signals & (1<<SIGSTOP))
  //     printf("recieved stop sig\n");
  // }
  struct kthread *t= mykthread();
    800032e0:	ffffe097          	auipc	ra,0xffffe
    800032e4:	7dc080e7          	jalr	2012(ra) # 80001abc <mykthread>
    800032e8:	8caa                	mv	s9,a0
  for(int sig_num=0;sig_num<32;sig_num++){
    800032ea:	0f898913          	addi	s2,s3,248
    800032ee:	4481                	li	s1,0
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    800032f0:	4a05                	li	s4,1
            p->killed = 1;
            release(&p->lock);
        }
      }

      else if(act.sa_handler==(void*)SIGKILL){
    800032f2:	4c25                	li	s8,9
        p->killed=1;
      }else if(act.sa_handler==(void*)SIGSTOP){
    800032f4:	4b45                	li	s6,17
        handle_stop(p);
      }      
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    800032f6:	4b85                	li	s7,1
        switch (sig_num)
    800032f8:	4d4d                	li	s10,19
  for(int sig_num=0;sig_num<32;sig_num++){
    800032fa:	02000a93          	li	s5,32
    800032fe:	a0a1                	j	80003346 <check_pending_signals+0x84>
        switch (sig_num)
    80003300:	03648163          	beq	s1,s6,80003322 <check_pending_signals+0x60>
    80003304:	03a48763          	beq	s1,s10,80003332 <check_pending_signals+0x70>
            acquire(&p->lock);
    80003308:	854e                	mv	a0,s3
    8000330a:	ffffe097          	auipc	ra,0xffffe
    8000330e:	8bc080e7          	jalr	-1860(ra) # 80000bc6 <acquire>
            p->killed = 1;
    80003312:	0179ae23          	sw	s7,28(s3)
            release(&p->lock);
    80003316:	854e                	mv	a0,s3
    80003318:	ffffe097          	auipc	ra,0xffffe
    8000331c:	984080e7          	jalr	-1660(ra) # 80000c9c <release>
    80003320:	a809                	j	80003332 <check_pending_signals+0x70>
            handle_stop(p);
    80003322:	854e                	mv	a0,s3
    80003324:	00000097          	auipc	ra,0x0
    80003328:	ec6080e7          	jalr	-314(ra) # 800031ea <handle_stop>
            break;
    8000332c:	a019                	j	80003332 <check_pending_signals+0x70>
        p->killed=1;
    8000332e:	0179ae23          	sw	s7,28(s3)
        turn_off_bit(p, sig_num);

        return;
      }

      turn_off_bit(p, sig_num);            
    80003332:	85a6                	mv	a1,s1
    80003334:	854e                	mv	a0,s3
    80003336:	00000097          	auipc	ra,0x0
    8000333a:	9e0080e7          	jalr	-1568(ra) # 80002d16 <turn_off_bit>
  for(int sig_num=0;sig_num<32;sig_num++){
    8000333e:	2485                	addiw	s1,s1,1
    80003340:	0921                	addi	s2,s2,8
    80003342:	0d548963          	beq	s1,s5,80003414 <check_pending_signals+0x152>
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    80003346:	009a173b          	sllw	a4,s4,s1
    8000334a:	0e89a783          	lw	a5,232(s3)
    8000334e:	8ff9                	and	a5,a5,a4
    80003350:	2781                	sext.w	a5,a5
    80003352:	d7f5                	beqz	a5,8000333e <check_pending_signals+0x7c>
    80003354:	0ec9a783          	lw	a5,236(s3)
    80003358:	8f7d                	and	a4,a4,a5
    8000335a:	2701                	sext.w	a4,a4
    8000335c:	f36d                	bnez	a4,8000333e <check_pending_signals+0x7c>
      act.sa_handler = p->signal_handlers[sig_num];
    8000335e:	00093703          	ld	a4,0(s2)
      if(act.sa_handler == (void*)SIG_DFL){
    80003362:	df59                	beqz	a4,80003300 <check_pending_signals+0x3e>
      else if(act.sa_handler==(void*)SIGKILL){
    80003364:	fd8705e3          	beq	a4,s8,8000332e <check_pending_signals+0x6c>
      }else if(act.sa_handler==(void*)SIGSTOP){
    80003368:	0d670463          	beq	a4,s6,80003430 <check_pending_signals+0x16e>
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    8000336c:	fd7703e3          	beq	a4,s7,80003332 <check_pending_signals+0x70>
    80003370:	2809a703          	lw	a4,640(s3)
    80003374:	ff5d                	bnez	a4,80003332 <check_pending_signals+0x70>
      act.sigmask = p->handlers_sigmasks[sig_num];
    80003376:	07c48713          	addi	a4,s1,124
    8000337a:	070a                	slli	a4,a4,0x2
    8000337c:	974e                	add	a4,a4,s3
    8000337e:	4718                	lw	a4,8(a4)
        p->handling_user_sig_flag = 1;
    80003380:	4685                	li	a3,1
    80003382:	28d9a023          	sw	a3,640(s3)
        p->signal_mask_backup = p->signal_mask;
    80003386:	0ef9a823          	sw	a5,240(s3)
        p->signal_mask= p->handlers_sigmasks[sig_num];
    8000338a:	0ee9a623          	sw	a4,236(s3)
        t->trapframe->sp -= sizeof(struct trapframe);
    8000338e:	040cb703          	ld	a4,64(s9)
    80003392:	7b1c                	ld	a5,48(a4)
    80003394:	ee078793          	addi	a5,a5,-288
    80003398:	fb1c                	sd	a5,48(a4)
        p->user_trapframe_backup = (struct trapframe* )(t->trapframe->sp);
    8000339a:	040cb783          	ld	a5,64(s9)
    8000339e:	7b8c                	ld	a1,48(a5)
    800033a0:	26b9bc23          	sd	a1,632(s3)
        copyout(p->pagetable, (uint64)p->user_trapframe_backup, (char *)t->trapframe, sizeof(struct trapframe));
    800033a4:	12000693          	li	a3,288
    800033a8:	040cb603          	ld	a2,64(s9)
    800033ac:	0409b503          	ld	a0,64(s3)
    800033b0:	ffffe097          	auipc	ra,0xffffe
    800033b4:	2b4080e7          	jalr	692(ra) # 80001664 <copyout>
        uint64 size = (uint64)&end_sigret - (uint64)&call_sigret;
    800033b8:	00004697          	auipc	a3,0x4
    800033bc:	f0868693          	addi	a3,a3,-248 # 800072c0 <end_sigret>
    800033c0:	00004617          	auipc	a2,0x4
    800033c4:	ef860613          	addi	a2,a2,-264 # 800072b8 <call_sigret>
        t->trapframe->sp -= size;
    800033c8:	040cb703          	ld	a4,64(s9)
    800033cc:	40d605b3          	sub	a1,a2,a3
    800033d0:	7b1c                	ld	a5,48(a4)
    800033d2:	97ae                	add	a5,a5,a1
    800033d4:	fb1c                	sd	a5,48(a4)
        copyout(p->pagetable, (uint64)t->trapframe->sp, (char *)&call_sigret, size);
    800033d6:	040cb783          	ld	a5,64(s9)
    800033da:	8e91                	sub	a3,a3,a2
    800033dc:	7b8c                	ld	a1,48(a5)
    800033de:	0409b503          	ld	a0,64(s3)
    800033e2:	ffffe097          	auipc	ra,0xffffe
    800033e6:	282080e7          	jalr	642(ra) # 80001664 <copyout>
        t->trapframe->a0 = sig_num;
    800033ea:	040cb783          	ld	a5,64(s9)
    800033ee:	fba4                	sd	s1,112(a5)
        t->trapframe->ra = t->trapframe->sp;
    800033f0:	040cb783          	ld	a5,64(s9)
    800033f4:	7b98                	ld	a4,48(a5)
    800033f6:	f798                	sd	a4,40(a5)
        t->trapframe->epc = (uint64)p->signal_handlers[sig_num];
    800033f8:	040cb703          	ld	a4,64(s9)
    800033fc:	01e48793          	addi	a5,s1,30
    80003400:	078e                	slli	a5,a5,0x3
    80003402:	97ce                	add	a5,a5,s3
    80003404:	679c                	ld	a5,8(a5)
    80003406:	ef1c                	sd	a5,24(a4)
        turn_off_bit(p, sig_num);
    80003408:	85a6                	mv	a1,s1
    8000340a:	854e                	mv	a0,s3
    8000340c:	00000097          	auipc	ra,0x0
    80003410:	90a080e7          	jalr	-1782(ra) # 80002d16 <turn_off_bit>
    }
  }
}
    80003414:	60e6                	ld	ra,88(sp)
    80003416:	6446                	ld	s0,80(sp)
    80003418:	64a6                	ld	s1,72(sp)
    8000341a:	6906                	ld	s2,64(sp)
    8000341c:	79e2                	ld	s3,56(sp)
    8000341e:	7a42                	ld	s4,48(sp)
    80003420:	7aa2                	ld	s5,40(sp)
    80003422:	7b02                	ld	s6,32(sp)
    80003424:	6be2                	ld	s7,24(sp)
    80003426:	6c42                	ld	s8,16(sp)
    80003428:	6ca2                	ld	s9,8(sp)
    8000342a:	6d02                	ld	s10,0(sp)
    8000342c:	6125                	addi	sp,sp,96
    8000342e:	8082                	ret
        handle_stop(p);
    80003430:	854e                	mv	a0,s3
    80003432:	00000097          	auipc	ra,0x0
    80003436:	db8080e7          	jalr	-584(ra) # 800031ea <handle_stop>
    8000343a:	bde5                	j	80003332 <check_pending_signals+0x70>

000000008000343c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000343c:	1101                	addi	sp,sp,-32
    8000343e:	ec06                	sd	ra,24(sp)
    80003440:	e822                	sd	s0,16(sp)
    80003442:	e426                	sd	s1,8(sp)
    80003444:	e04a                	sd	s2,0(sp)
    80003446:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003448:	ffffe097          	auipc	ra,0xffffe
    8000344c:	634080e7          	jalr	1588(ra) # 80001a7c <myproc>
    80003450:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80003452:	ffffe097          	auipc	ra,0xffffe
    80003456:	66a080e7          	jalr	1642(ra) # 80001abc <mykthread>
    8000345a:	84aa                	mv	s1,a0
  int mytid = mykthread()->tid;
    8000345c:	ffffe097          	auipc	ra,0xffffe
    80003460:	660080e7          	jalr	1632(ra) # 80001abc <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003464:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80003468:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000346a:	10079073          	csrw	sstatus,a5

  intr_off();
  

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000346e:	00005617          	auipc	a2,0x5
    80003472:	b9260613          	addi	a2,a2,-1134 # 80008000 <_trampoline>
    80003476:	00005697          	auipc	a3,0x5
    8000347a:	b8a68693          	addi	a3,a3,-1142 # 80008000 <_trampoline>
    8000347e:	8e91                	sub	a3,a3,a2
    80003480:	040007b7          	lui	a5,0x4000
    80003484:	17fd                	addi	a5,a5,-1
    80003486:	07b2                	slli	a5,a5,0xc
    80003488:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000348a:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  t->trapframe->kernel_satp = r_satp();         // kernel page table
    8000348e:	60b8                	ld	a4,64(s1)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80003490:	180026f3          	csrr	a3,satp
    80003494:	e314                	sd	a3,0(a4)
  t->trapframe->kernel_sp = t->kstack + PGSIZE; // process's kernel stack
    80003496:	60b8                	ld	a4,64(s1)
    80003498:	7c94                	ld	a3,56(s1)
    8000349a:	6585                	lui	a1,0x1
    8000349c:	96ae                	add	a3,a3,a1
    8000349e:	e714                	sd	a3,8(a4)
  t->trapframe->kernel_trap = (uint64)usertrap;
    800034a0:	60b8                	ld	a4,64(s1)
    800034a2:	00000697          	auipc	a3,0x0
    800034a6:	15e68693          	addi	a3,a3,350 # 80003600 <usertrap>
    800034aa:	eb14                	sd	a3,16(a4)
  t->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800034ac:	60b8                	ld	a4,64(s1)
  asm volatile("mv %0, tp" : "=r" (x) );
    800034ae:	8692                	mv	a3,tp
    800034b0:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800034b2:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800034b6:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800034ba:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800034be:	10069073          	csrw	sstatus,a3
  w_sstatus(x);
  

  // set S Exception Program Counter to the saved user pc.
  w_sepc(t->trapframe->epc);
    800034c2:	60b8                	ld	a4,64(s1)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800034c4:	6f18                	ld	a4,24(a4)
    800034c6:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800034ca:	04093583          	ld	a1,64(s2)
    800034ce:	81b1                	srli	a1,a1,0xc
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
 
 
  int thread_ind = (int)(t - p->kthreads);
    800034d0:	28890513          	addi	a0,s2,648
    800034d4:	40a48533          	sub	a0,s1,a0
    800034d8:	850d                	srai	a0,a0,0x3




  ((void (*)(uint64,uint64))fn)(TRAPFRAME + (uint64)(thread_ind * sizeof(struct trapframe)), satp);
    800034da:	00006497          	auipc	s1,0x6
    800034de:	b2e4b483          	ld	s1,-1234(s1) # 80009008 <etext+0x8>
    800034e2:	0295053b          	mulw	a0,a0,s1
    800034e6:	00351493          	slli	s1,a0,0x3
    800034ea:	9526                	add	a0,a0,s1
    800034ec:	0516                	slli	a0,a0,0x5
    800034ee:	020006b7          	lui	a3,0x2000
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800034f2:	00005717          	auipc	a4,0x5
    800034f6:	b9e70713          	addi	a4,a4,-1122 # 80008090 <userret>
    800034fa:	8f11                	sub	a4,a4,a2
    800034fc:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME + (uint64)(thread_ind * sizeof(struct trapframe)), satp);
    800034fe:	577d                	li	a4,-1
    80003500:	177e                	slli	a4,a4,0x3f
    80003502:	8dd9                	or	a1,a1,a4
    80003504:	16fd                	addi	a3,a3,-1
    80003506:	06b6                	slli	a3,a3,0xd
    80003508:	9536                	add	a0,a0,a3
    8000350a:	9782                	jalr	a5

}
    8000350c:	60e2                	ld	ra,24(sp)
    8000350e:	6442                	ld	s0,16(sp)
    80003510:	64a2                	ld	s1,8(sp)
    80003512:	6902                	ld	s2,0(sp)
    80003514:	6105                	addi	sp,sp,32
    80003516:	8082                	ret

0000000080003518 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80003518:	1101                	addi	sp,sp,-32
    8000351a:	ec06                	sd	ra,24(sp)
    8000351c:	e822                	sd	s0,16(sp)
    8000351e:	e426                	sd	s1,8(sp)
    80003520:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80003522:	00030497          	auipc	s1,0x30
    80003526:	40648493          	addi	s1,s1,1030 # 80033928 <tickslock>
    8000352a:	8526                	mv	a0,s1
    8000352c:	ffffd097          	auipc	ra,0xffffd
    80003530:	69a080e7          	jalr	1690(ra) # 80000bc6 <acquire>
  ticks++;
    80003534:	00007517          	auipc	a0,0x7
    80003538:	afc50513          	addi	a0,a0,-1284 # 8000a030 <ticks>
    8000353c:	411c                	lw	a5,0(a0)
    8000353e:	2785                	addiw	a5,a5,1
    80003540:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80003542:	fffff097          	auipc	ra,0xfffff
    80003546:	00a080e7          	jalr	10(ra) # 8000254c <wakeup>
  release(&tickslock);
    8000354a:	8526                	mv	a0,s1
    8000354c:	ffffd097          	auipc	ra,0xffffd
    80003550:	750080e7          	jalr	1872(ra) # 80000c9c <release>
}
    80003554:	60e2                	ld	ra,24(sp)
    80003556:	6442                	ld	s0,16(sp)
    80003558:	64a2                	ld	s1,8(sp)
    8000355a:	6105                	addi	sp,sp,32
    8000355c:	8082                	ret

000000008000355e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000355e:	1101                	addi	sp,sp,-32
    80003560:	ec06                	sd	ra,24(sp)
    80003562:	e822                	sd	s0,16(sp)
    80003564:	e426                	sd	s1,8(sp)
    80003566:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003568:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000356c:	00074d63          	bltz	a4,80003586 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80003570:	57fd                	li	a5,-1
    80003572:	17fe                	slli	a5,a5,0x3f
    80003574:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80003576:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80003578:	06f70363          	beq	a4,a5,800035de <devintr+0x80>
  }
}
    8000357c:	60e2                	ld	ra,24(sp)
    8000357e:	6442                	ld	s0,16(sp)
    80003580:	64a2                	ld	s1,8(sp)
    80003582:	6105                	addi	sp,sp,32
    80003584:	8082                	ret
     (scause & 0xff) == 9){
    80003586:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000358a:	46a5                	li	a3,9
    8000358c:	fed792e3          	bne	a5,a3,80003570 <devintr+0x12>
    int irq = plic_claim();
    80003590:	00003097          	auipc	ra,0x3
    80003594:	7a8080e7          	jalr	1960(ra) # 80006d38 <plic_claim>
    80003598:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000359a:	47a9                	li	a5,10
    8000359c:	02f50763          	beq	a0,a5,800035ca <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800035a0:	4785                	li	a5,1
    800035a2:	02f50963          	beq	a0,a5,800035d4 <devintr+0x76>
    return 1;
    800035a6:	4505                	li	a0,1
    } else if(irq){
    800035a8:	d8f1                	beqz	s1,8000357c <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800035aa:	85a6                	mv	a1,s1
    800035ac:	00006517          	auipc	a0,0x6
    800035b0:	e0c50513          	addi	a0,a0,-500 # 800093b8 <states.0+0x28>
    800035b4:	ffffd097          	auipc	ra,0xffffd
    800035b8:	fc4080e7          	jalr	-60(ra) # 80000578 <printf>
      plic_complete(irq);
    800035bc:	8526                	mv	a0,s1
    800035be:	00003097          	auipc	ra,0x3
    800035c2:	79e080e7          	jalr	1950(ra) # 80006d5c <plic_complete>
    return 1;
    800035c6:	4505                	li	a0,1
    800035c8:	bf55                	j	8000357c <devintr+0x1e>
      uartintr();
    800035ca:	ffffd097          	auipc	ra,0xffffd
    800035ce:	3c0080e7          	jalr	960(ra) # 8000098a <uartintr>
    800035d2:	b7ed                	j	800035bc <devintr+0x5e>
      virtio_disk_intr();
    800035d4:	00004097          	auipc	ra,0x4
    800035d8:	c1a080e7          	jalr	-998(ra) # 800071ee <virtio_disk_intr>
    800035dc:	b7c5                	j	800035bc <devintr+0x5e>
    if(cpuid() == 0){
    800035de:	ffffe097          	auipc	ra,0xffffe
    800035e2:	46a080e7          	jalr	1130(ra) # 80001a48 <cpuid>
    800035e6:	c901                	beqz	a0,800035f6 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800035e8:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800035ec:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800035ee:	14479073          	csrw	sip,a5
    return 2;
    800035f2:	4509                	li	a0,2
    800035f4:	b761                	j	8000357c <devintr+0x1e>
      clockintr();
    800035f6:	00000097          	auipc	ra,0x0
    800035fa:	f22080e7          	jalr	-222(ra) # 80003518 <clockintr>
    800035fe:	b7ed                	j	800035e8 <devintr+0x8a>

0000000080003600 <usertrap>:
{
    80003600:	1101                	addi	sp,sp,-32
    80003602:	ec06                	sd	ra,24(sp)
    80003604:	e822                	sd	s0,16(sp)
    80003606:	e426                	sd	s1,8(sp)
    80003608:	e04a                	sd	s2,0(sp)
    8000360a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000360c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003610:	1007f793          	andi	a5,a5,256
    80003614:	e3dd                	bnez	a5,800036ba <usertrap+0xba>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003616:	00003797          	auipc	a5,0x3
    8000361a:	61a78793          	addi	a5,a5,1562 # 80006c30 <kernelvec>
    8000361e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003622:	ffffe097          	auipc	ra,0xffffe
    80003626:	45a080e7          	jalr	1114(ra) # 80001a7c <myproc>
    8000362a:	84aa                	mv	s1,a0
  struct kthread *t = mykthread();
    8000362c:	ffffe097          	auipc	ra,0xffffe
    80003630:	490080e7          	jalr	1168(ra) # 80001abc <mykthread>
    80003634:	892a                	mv	s2,a0
  t->trapframe->epc = r_sepc();
    80003636:	613c                	ld	a5,64(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003638:	14102773          	csrr	a4,sepc
    8000363c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000363e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80003642:	47a1                	li	a5,8
    80003644:	08f71f63          	bne	a4,a5,800036e2 <usertrap+0xe2>
    if(t->killed == 1)
    80003648:	5518                	lw	a4,40(a0)
    8000364a:	4785                	li	a5,1
    8000364c:	06f70f63          	beq	a4,a5,800036ca <usertrap+0xca>
    else if(p->killed)
    80003650:	4cdc                	lw	a5,28(s1)
    80003652:	e3d1                	bnez	a5,800036d6 <usertrap+0xd6>
    t->trapframe->epc += 4;
    80003654:	04093703          	ld	a4,64(s2)
    80003658:	6f1c                	ld	a5,24(a4)
    8000365a:	0791                	addi	a5,a5,4
    8000365c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000365e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003662:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003666:	10079073          	csrw	sstatus,a5
    syscall();
    8000366a:	00000097          	auipc	ra,0x0
    8000366e:	38a080e7          	jalr	906(ra) # 800039f4 <syscall>
  if(holding(&p->lock))
    80003672:	8526                	mv	a0,s1
    80003674:	ffffd097          	auipc	ra,0xffffd
    80003678:	4d8080e7          	jalr	1240(ra) # 80000b4c <holding>
    8000367c:	e95d                	bnez	a0,80003732 <usertrap+0x132>
  acquire(&p->lock);
    8000367e:	8526                	mv	a0,s1
    80003680:	ffffd097          	auipc	ra,0xffffd
    80003684:	546080e7          	jalr	1350(ra) # 80000bc6 <acquire>
  if(!p->handling_sig_flag){
    80003688:	2844a783          	lw	a5,644(s1)
    8000368c:	cfc5                	beqz	a5,80003744 <usertrap+0x144>
  release(&p->lock);
    8000368e:	8526                	mv	a0,s1
    80003690:	ffffd097          	auipc	ra,0xffffd
    80003694:	60c080e7          	jalr	1548(ra) # 80000c9c <release>
  if(t->killed == 1)
    80003698:	02892703          	lw	a4,40(s2)
    8000369c:	4785                	li	a5,1
    8000369e:	0cf70863          	beq	a4,a5,8000376e <usertrap+0x16e>
  else if(p->killed)
    800036a2:	4cdc                	lw	a5,28(s1)
    800036a4:	ebf9                	bnez	a5,8000377a <usertrap+0x17a>
  usertrapret();
    800036a6:	00000097          	auipc	ra,0x0
    800036aa:	d96080e7          	jalr	-618(ra) # 8000343c <usertrapret>
}
    800036ae:	60e2                	ld	ra,24(sp)
    800036b0:	6442                	ld	s0,16(sp)
    800036b2:	64a2                	ld	s1,8(sp)
    800036b4:	6902                	ld	s2,0(sp)
    800036b6:	6105                	addi	sp,sp,32
    800036b8:	8082                	ret
    panic("usertrap: not from user mode");
    800036ba:	00006517          	auipc	a0,0x6
    800036be:	d1e50513          	addi	a0,a0,-738 # 800093d8 <states.0+0x48>
    800036c2:	ffffd097          	auipc	ra,0xffffd
    800036c6:	e6c080e7          	jalr	-404(ra) # 8000052e <panic>
      kthread_exit(-1); // Kill current thread
    800036ca:	557d                	li	a0,-1
    800036cc:	fffff097          	auipc	ra,0xfffff
    800036d0:	07c080e7          	jalr	124(ra) # 80002748 <kthread_exit>
    800036d4:	b741                	j	80003654 <usertrap+0x54>
      exit(-1); // Kill the hole procces
    800036d6:	557d                	li	a0,-1
    800036d8:	fffff097          	auipc	ra,0xfffff
    800036dc:	104080e7          	jalr	260(ra) # 800027dc <exit>
    800036e0:	bf95                	j	80003654 <usertrap+0x54>
  else if((which_dev = devintr()) != 0)
    800036e2:	00000097          	auipc	ra,0x0
    800036e6:	e7c080e7          	jalr	-388(ra) # 8000355e <devintr>
    800036ea:	c909                	beqz	a0,800036fc <usertrap+0xfc>
  if(which_dev == 2)
    800036ec:	4789                	li	a5,2
    800036ee:	f8f512e3          	bne	a0,a5,80003672 <usertrap+0x72>
    yield();
    800036f2:	fffff097          	auipc	ra,0xfffff
    800036f6:	c94080e7          	jalr	-876(ra) # 80002386 <yield>
    800036fa:	bfa5                	j	80003672 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800036fc:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003700:	50d0                	lw	a2,36(s1)
    80003702:	00006517          	auipc	a0,0x6
    80003706:	cf650513          	addi	a0,a0,-778 # 800093f8 <states.0+0x68>
    8000370a:	ffffd097          	auipc	ra,0xffffd
    8000370e:	e6e080e7          	jalr	-402(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003712:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003716:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000371a:	00006517          	auipc	a0,0x6
    8000371e:	d0e50513          	addi	a0,a0,-754 # 80009428 <states.0+0x98>
    80003722:	ffffd097          	auipc	ra,0xffffd
    80003726:	e56080e7          	jalr	-426(ra) # 80000578 <printf>
    t->killed = 1;
    8000372a:	4785                	li	a5,1
    8000372c:	02f92423          	sw	a5,40(s2)
  if(which_dev == 2)
    80003730:	b789                	j	80003672 <usertrap+0x72>
    printf("fuck i am holding the lock in usertrap\n");   // TODO : delete
    80003732:	00006517          	auipc	a0,0x6
    80003736:	d1650513          	addi	a0,a0,-746 # 80009448 <states.0+0xb8>
    8000373a:	ffffd097          	auipc	ra,0xffffd
    8000373e:	e3e080e7          	jalr	-450(ra) # 80000578 <printf>
    80003742:	bf35                	j	8000367e <usertrap+0x7e>
    p->handling_sig_flag = 1;
    80003744:	4785                	li	a5,1
    80003746:	28f4a223          	sw	a5,644(s1)
    release(&p->lock);
    8000374a:	8526                	mv	a0,s1
    8000374c:	ffffd097          	auipc	ra,0xffffd
    80003750:	550080e7          	jalr	1360(ra) # 80000c9c <release>
    check_pending_signals(p);
    80003754:	8526                	mv	a0,s1
    80003756:	00000097          	auipc	ra,0x0
    8000375a:	b6c080e7          	jalr	-1172(ra) # 800032c2 <check_pending_signals>
    acquire(&p->lock);
    8000375e:	8526                	mv	a0,s1
    80003760:	ffffd097          	auipc	ra,0xffffd
    80003764:	466080e7          	jalr	1126(ra) # 80000bc6 <acquire>
    p->handling_sig_flag = 0;
    80003768:	2804a223          	sw	zero,644(s1)
    8000376c:	b70d                	j	8000368e <usertrap+0x8e>
    kthread_exit(-1); // Kill current thread
    8000376e:	557d                	li	a0,-1
    80003770:	fffff097          	auipc	ra,0xfffff
    80003774:	fd8080e7          	jalr	-40(ra) # 80002748 <kthread_exit>
    80003778:	b73d                	j	800036a6 <usertrap+0xa6>
    exit(-1); // Kill the hole procces
    8000377a:	557d                	li	a0,-1
    8000377c:	fffff097          	auipc	ra,0xfffff
    80003780:	060080e7          	jalr	96(ra) # 800027dc <exit>
    80003784:	b70d                	j	800036a6 <usertrap+0xa6>

0000000080003786 <kerneltrap>:
{
    80003786:	7179                	addi	sp,sp,-48
    80003788:	f406                	sd	ra,40(sp)
    8000378a:	f022                	sd	s0,32(sp)
    8000378c:	ec26                	sd	s1,24(sp)
    8000378e:	e84a                	sd	s2,16(sp)
    80003790:	e44e                	sd	s3,8(sp)
    80003792:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003794:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003798:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000379c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800037a0:	1004f793          	andi	a5,s1,256
    800037a4:	cb85                	beqz	a5,800037d4 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800037a6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800037aa:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800037ac:	ef85                	bnez	a5,800037e4 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800037ae:	00000097          	auipc	ra,0x0
    800037b2:	db0080e7          	jalr	-592(ra) # 8000355e <devintr>
    800037b6:	cd1d                	beqz	a0,800037f4 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    800037b8:	4789                	li	a5,2
    800037ba:	08f50763          	beq	a0,a5,80003848 <kerneltrap+0xc2>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800037be:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800037c2:	10049073          	csrw	sstatus,s1
}
    800037c6:	70a2                	ld	ra,40(sp)
    800037c8:	7402                	ld	s0,32(sp)
    800037ca:	64e2                	ld	s1,24(sp)
    800037cc:	6942                	ld	s2,16(sp)
    800037ce:	69a2                	ld	s3,8(sp)
    800037d0:	6145                	addi	sp,sp,48
    800037d2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800037d4:	00006517          	auipc	a0,0x6
    800037d8:	c9c50513          	addi	a0,a0,-868 # 80009470 <states.0+0xe0>
    800037dc:	ffffd097          	auipc	ra,0xffffd
    800037e0:	d52080e7          	jalr	-686(ra) # 8000052e <panic>
    panic("kerneltrap: interrupts enabled");
    800037e4:	00006517          	auipc	a0,0x6
    800037e8:	cb450513          	addi	a0,a0,-844 # 80009498 <states.0+0x108>
    800037ec:	ffffd097          	auipc	ra,0xffffd
    800037f0:	d42080e7          	jalr	-702(ra) # 8000052e <panic>
    printf("thread %d recieved kernel trap\n",mykthread()->tid);
    800037f4:	ffffe097          	auipc	ra,0xffffe
    800037f8:	2c8080e7          	jalr	712(ra) # 80001abc <mykthread>
    800037fc:	590c                	lw	a1,48(a0)
    800037fe:	00006517          	auipc	a0,0x6
    80003802:	cba50513          	addi	a0,a0,-838 # 800094b8 <states.0+0x128>
    80003806:	ffffd097          	auipc	ra,0xffffd
    8000380a:	d72080e7          	jalr	-654(ra) # 80000578 <printf>
    printf("scause %p\n", scause);
    8000380e:	85ce                	mv	a1,s3
    80003810:	00006517          	auipc	a0,0x6
    80003814:	cc850513          	addi	a0,a0,-824 # 800094d8 <states.0+0x148>
    80003818:	ffffd097          	auipc	ra,0xffffd
    8000381c:	d60080e7          	jalr	-672(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003820:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003824:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003828:	00006517          	auipc	a0,0x6
    8000382c:	cc050513          	addi	a0,a0,-832 # 800094e8 <states.0+0x158>
    80003830:	ffffd097          	auipc	ra,0xffffd
    80003834:	d48080e7          	jalr	-696(ra) # 80000578 <printf>
    panic("kerneltrap");
    80003838:	00006517          	auipc	a0,0x6
    8000383c:	cc850513          	addi	a0,a0,-824 # 80009500 <states.0+0x170>
    80003840:	ffffd097          	auipc	ra,0xffffd
    80003844:	cee080e7          	jalr	-786(ra) # 8000052e <panic>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    80003848:	ffffe097          	auipc	ra,0xffffe
    8000384c:	234080e7          	jalr	564(ra) # 80001a7c <myproc>
    80003850:	d53d                	beqz	a0,800037be <kerneltrap+0x38>
    80003852:	ffffe097          	auipc	ra,0xffffe
    80003856:	26a080e7          	jalr	618(ra) # 80001abc <mykthread>
    8000385a:	d135                	beqz	a0,800037be <kerneltrap+0x38>
    8000385c:	ffffe097          	auipc	ra,0xffffe
    80003860:	260080e7          	jalr	608(ra) # 80001abc <mykthread>
    80003864:	4d18                	lw	a4,24(a0)
    80003866:	4791                	li	a5,4
    80003868:	f4f71be3          	bne	a4,a5,800037be <kerneltrap+0x38>
    yield();
    8000386c:	fffff097          	auipc	ra,0xfffff
    80003870:	b1a080e7          	jalr	-1254(ra) # 80002386 <yield>
    80003874:	b7a9                	j	800037be <kerneltrap+0x38>

0000000080003876 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003876:	1101                	addi	sp,sp,-32
    80003878:	ec06                	sd	ra,24(sp)
    8000387a:	e822                	sd	s0,16(sp)
    8000387c:	e426                	sd	s1,8(sp)
    8000387e:	1000                	addi	s0,sp,32
    80003880:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003882:	ffffe097          	auipc	ra,0xffffe
    80003886:	1fa080e7          	jalr	506(ra) # 80001a7c <myproc>
  struct kthread *t = mykthread();
    8000388a:	ffffe097          	auipc	ra,0xffffe
    8000388e:	232080e7          	jalr	562(ra) # 80001abc <mykthread>
  switch (n) {
    80003892:	4795                	li	a5,5
    80003894:	0497e163          	bltu	a5,s1,800038d6 <argraw+0x60>
    80003898:	048a                	slli	s1,s1,0x2
    8000389a:	00006717          	auipc	a4,0x6
    8000389e:	c9e70713          	addi	a4,a4,-866 # 80009538 <states.0+0x1a8>
    800038a2:	94ba                	add	s1,s1,a4
    800038a4:	409c                	lw	a5,0(s1)
    800038a6:	97ba                	add	a5,a5,a4
    800038a8:	8782                	jr	a5
  case 0:
    return t->trapframe->a0;
    800038aa:	613c                	ld	a5,64(a0)
    800038ac:	7ba8                	ld	a0,112(a5)
  case 5:
    return t->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800038ae:	60e2                	ld	ra,24(sp)
    800038b0:	6442                	ld	s0,16(sp)
    800038b2:	64a2                	ld	s1,8(sp)
    800038b4:	6105                	addi	sp,sp,32
    800038b6:	8082                	ret
    return t->trapframe->a1;
    800038b8:	613c                	ld	a5,64(a0)
    800038ba:	7fa8                	ld	a0,120(a5)
    800038bc:	bfcd                	j	800038ae <argraw+0x38>
    return t->trapframe->a2;
    800038be:	613c                	ld	a5,64(a0)
    800038c0:	63c8                	ld	a0,128(a5)
    800038c2:	b7f5                	j	800038ae <argraw+0x38>
    return t->trapframe->a3;
    800038c4:	613c                	ld	a5,64(a0)
    800038c6:	67c8                	ld	a0,136(a5)
    800038c8:	b7dd                	j	800038ae <argraw+0x38>
    return t->trapframe->a4;
    800038ca:	613c                	ld	a5,64(a0)
    800038cc:	6bc8                	ld	a0,144(a5)
    800038ce:	b7c5                	j	800038ae <argraw+0x38>
    return t->trapframe->a5;
    800038d0:	613c                	ld	a5,64(a0)
    800038d2:	6fc8                	ld	a0,152(a5)
    800038d4:	bfe9                	j	800038ae <argraw+0x38>
  panic("argraw");
    800038d6:	00006517          	auipc	a0,0x6
    800038da:	c3a50513          	addi	a0,a0,-966 # 80009510 <states.0+0x180>
    800038de:	ffffd097          	auipc	ra,0xffffd
    800038e2:	c50080e7          	jalr	-944(ra) # 8000052e <panic>

00000000800038e6 <fetchaddr>:
{
    800038e6:	1101                	addi	sp,sp,-32
    800038e8:	ec06                	sd	ra,24(sp)
    800038ea:	e822                	sd	s0,16(sp)
    800038ec:	e426                	sd	s1,8(sp)
    800038ee:	e04a                	sd	s2,0(sp)
    800038f0:	1000                	addi	s0,sp,32
    800038f2:	84aa                	mv	s1,a0
    800038f4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800038f6:	ffffe097          	auipc	ra,0xffffe
    800038fa:	186080e7          	jalr	390(ra) # 80001a7c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    800038fe:	7d1c                	ld	a5,56(a0)
    80003900:	02f4f863          	bgeu	s1,a5,80003930 <fetchaddr+0x4a>
    80003904:	00848713          	addi	a4,s1,8
    80003908:	02e7e663          	bltu	a5,a4,80003934 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000390c:	46a1                	li	a3,8
    8000390e:	8626                	mv	a2,s1
    80003910:	85ca                	mv	a1,s2
    80003912:	6128                	ld	a0,64(a0)
    80003914:	ffffe097          	auipc	ra,0xffffe
    80003918:	ddc080e7          	jalr	-548(ra) # 800016f0 <copyin>
    8000391c:	00a03533          	snez	a0,a0
    80003920:	40a00533          	neg	a0,a0
}
    80003924:	60e2                	ld	ra,24(sp)
    80003926:	6442                	ld	s0,16(sp)
    80003928:	64a2                	ld	s1,8(sp)
    8000392a:	6902                	ld	s2,0(sp)
    8000392c:	6105                	addi	sp,sp,32
    8000392e:	8082                	ret
    return -1;
    80003930:	557d                	li	a0,-1
    80003932:	bfcd                	j	80003924 <fetchaddr+0x3e>
    80003934:	557d                	li	a0,-1
    80003936:	b7fd                	j	80003924 <fetchaddr+0x3e>

0000000080003938 <fetchstr>:
{
    80003938:	7179                	addi	sp,sp,-48
    8000393a:	f406                	sd	ra,40(sp)
    8000393c:	f022                	sd	s0,32(sp)
    8000393e:	ec26                	sd	s1,24(sp)
    80003940:	e84a                	sd	s2,16(sp)
    80003942:	e44e                	sd	s3,8(sp)
    80003944:	1800                	addi	s0,sp,48
    80003946:	892a                	mv	s2,a0
    80003948:	84ae                	mv	s1,a1
    8000394a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000394c:	ffffe097          	auipc	ra,0xffffe
    80003950:	130080e7          	jalr	304(ra) # 80001a7c <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003954:	86ce                	mv	a3,s3
    80003956:	864a                	mv	a2,s2
    80003958:	85a6                	mv	a1,s1
    8000395a:	6128                	ld	a0,64(a0)
    8000395c:	ffffe097          	auipc	ra,0xffffe
    80003960:	e22080e7          	jalr	-478(ra) # 8000177e <copyinstr>
  if(err < 0)
    80003964:	00054763          	bltz	a0,80003972 <fetchstr+0x3a>
  return strlen(buf);
    80003968:	8526                	mv	a0,s1
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	4fe080e7          	jalr	1278(ra) # 80000e68 <strlen>
}
    80003972:	70a2                	ld	ra,40(sp)
    80003974:	7402                	ld	s0,32(sp)
    80003976:	64e2                	ld	s1,24(sp)
    80003978:	6942                	ld	s2,16(sp)
    8000397a:	69a2                	ld	s3,8(sp)
    8000397c:	6145                	addi	sp,sp,48
    8000397e:	8082                	ret

0000000080003980 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003980:	1101                	addi	sp,sp,-32
    80003982:	ec06                	sd	ra,24(sp)
    80003984:	e822                	sd	s0,16(sp)
    80003986:	e426                	sd	s1,8(sp)
    80003988:	1000                	addi	s0,sp,32
    8000398a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000398c:	00000097          	auipc	ra,0x0
    80003990:	eea080e7          	jalr	-278(ra) # 80003876 <argraw>
    80003994:	c088                	sw	a0,0(s1)
  return 0;
}
    80003996:	4501                	li	a0,0
    80003998:	60e2                	ld	ra,24(sp)
    8000399a:	6442                	ld	s0,16(sp)
    8000399c:	64a2                	ld	s1,8(sp)
    8000399e:	6105                	addi	sp,sp,32
    800039a0:	8082                	ret

00000000800039a2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800039a2:	1101                	addi	sp,sp,-32
    800039a4:	ec06                	sd	ra,24(sp)
    800039a6:	e822                	sd	s0,16(sp)
    800039a8:	e426                	sd	s1,8(sp)
    800039aa:	1000                	addi	s0,sp,32
    800039ac:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800039ae:	00000097          	auipc	ra,0x0
    800039b2:	ec8080e7          	jalr	-312(ra) # 80003876 <argraw>
    800039b6:	e088                	sd	a0,0(s1)
  return 0;
}
    800039b8:	4501                	li	a0,0
    800039ba:	60e2                	ld	ra,24(sp)
    800039bc:	6442                	ld	s0,16(sp)
    800039be:	64a2                	ld	s1,8(sp)
    800039c0:	6105                	addi	sp,sp,32
    800039c2:	8082                	ret

00000000800039c4 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800039c4:	1101                	addi	sp,sp,-32
    800039c6:	ec06                	sd	ra,24(sp)
    800039c8:	e822                	sd	s0,16(sp)
    800039ca:	e426                	sd	s1,8(sp)
    800039cc:	e04a                	sd	s2,0(sp)
    800039ce:	1000                	addi	s0,sp,32
    800039d0:	84ae                	mv	s1,a1
    800039d2:	8932                	mv	s2,a2
  *ip = argraw(n);
    800039d4:	00000097          	auipc	ra,0x0
    800039d8:	ea2080e7          	jalr	-350(ra) # 80003876 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    800039dc:	864a                	mv	a2,s2
    800039de:	85a6                	mv	a1,s1
    800039e0:	00000097          	auipc	ra,0x0
    800039e4:	f58080e7          	jalr	-168(ra) # 80003938 <fetchstr>
}
    800039e8:	60e2                	ld	ra,24(sp)
    800039ea:	6442                	ld	s0,16(sp)
    800039ec:	64a2                	ld	s1,8(sp)
    800039ee:	6902                	ld	s2,0(sp)
    800039f0:	6105                	addi	sp,sp,32
    800039f2:	8082                	ret

00000000800039f4 <syscall>:
[SYS_kthread_join] sys_kthread_join,
};

void
syscall(void)
{
    800039f4:	7179                	addi	sp,sp,-48
    800039f6:	f406                	sd	ra,40(sp)
    800039f8:	f022                	sd	s0,32(sp)
    800039fa:	ec26                	sd	s1,24(sp)
    800039fc:	e84a                	sd	s2,16(sp)
    800039fe:	e44e                	sd	s3,8(sp)
    80003a00:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80003a02:	ffffe097          	auipc	ra,0xffffe
    80003a06:	07a080e7          	jalr	122(ra) # 80001a7c <myproc>
    80003a0a:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80003a0c:	ffffe097          	auipc	ra,0xffffe
    80003a10:	0b0080e7          	jalr	176(ra) # 80001abc <mykthread>
    80003a14:	84aa                	mv	s1,a0

  num = t->trapframe->a7;
    80003a16:	04053983          	ld	s3,64(a0)
    80003a1a:	0a89b783          	ld	a5,168(s3)
    80003a1e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003a22:	37fd                	addiw	a5,a5,-1
    80003a24:	476d                	li	a4,27
    80003a26:	00f76f63          	bltu	a4,a5,80003a44 <syscall+0x50>
    80003a2a:	00369713          	slli	a4,a3,0x3
    80003a2e:	00006797          	auipc	a5,0x6
    80003a32:	b2278793          	addi	a5,a5,-1246 # 80009550 <syscalls>
    80003a36:	97ba                	add	a5,a5,a4
    80003a38:	639c                	ld	a5,0(a5)
    80003a3a:	c789                	beqz	a5,80003a44 <syscall+0x50>
    t->trapframe->a0 = syscalls[num]();
    80003a3c:	9782                	jalr	a5
    80003a3e:	06a9b823          	sd	a0,112(s3)
    80003a42:	a005                	j	80003a62 <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003a44:	0d890613          	addi	a2,s2,216
    80003a48:	02492583          	lw	a1,36(s2)
    80003a4c:	00006517          	auipc	a0,0x6
    80003a50:	acc50513          	addi	a0,a0,-1332 # 80009518 <states.0+0x188>
    80003a54:	ffffd097          	auipc	ra,0xffffd
    80003a58:	b24080e7          	jalr	-1244(ra) # 80000578 <printf>
            p->pid, p->name, num);
    t->trapframe->a0 = -1;
    80003a5c:	60bc                	ld	a5,64(s1)
    80003a5e:	577d                	li	a4,-1
    80003a60:	fbb8                	sd	a4,112(a5)
  }
}
    80003a62:	70a2                	ld	ra,40(sp)
    80003a64:	7402                	ld	s0,32(sp)
    80003a66:	64e2                	ld	s1,24(sp)
    80003a68:	6942                	ld	s2,16(sp)
    80003a6a:	69a2                	ld	s3,8(sp)
    80003a6c:	6145                	addi	sp,sp,48
    80003a6e:	8082                	ret

0000000080003a70 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003a70:	1101                	addi	sp,sp,-32
    80003a72:	ec06                	sd	ra,24(sp)
    80003a74:	e822                	sd	s0,16(sp)
    80003a76:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003a78:	fec40593          	addi	a1,s0,-20
    80003a7c:	4501                	li	a0,0
    80003a7e:	00000097          	auipc	ra,0x0
    80003a82:	f02080e7          	jalr	-254(ra) # 80003980 <argint>
    return -1;
    80003a86:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003a88:	00054963          	bltz	a0,80003a9a <sys_exit+0x2a>
  exit(n);
    80003a8c:	fec42503          	lw	a0,-20(s0)
    80003a90:	fffff097          	auipc	ra,0xfffff
    80003a94:	d4c080e7          	jalr	-692(ra) # 800027dc <exit>
  return 0;  // not reached
    80003a98:	4781                	li	a5,0
}
    80003a9a:	853e                	mv	a0,a5
    80003a9c:	60e2                	ld	ra,24(sp)
    80003a9e:	6442                	ld	s0,16(sp)
    80003aa0:	6105                	addi	sp,sp,32
    80003aa2:	8082                	ret

0000000080003aa4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003aa4:	1141                	addi	sp,sp,-16
    80003aa6:	e406                	sd	ra,8(sp)
    80003aa8:	e022                	sd	s0,0(sp)
    80003aaa:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003aac:	ffffe097          	auipc	ra,0xffffe
    80003ab0:	fd0080e7          	jalr	-48(ra) # 80001a7c <myproc>
}
    80003ab4:	5148                	lw	a0,36(a0)
    80003ab6:	60a2                	ld	ra,8(sp)
    80003ab8:	6402                	ld	s0,0(sp)
    80003aba:	0141                	addi	sp,sp,16
    80003abc:	8082                	ret

0000000080003abe <sys_fork>:

uint64
sys_fork(void)
{
    80003abe:	1141                	addi	sp,sp,-16
    80003ac0:	e406                	sd	ra,8(sp)
    80003ac2:	e022                	sd	s0,0(sp)
    80003ac4:	0800                	addi	s0,sp,16
  return fork();
    80003ac6:	ffffe097          	auipc	ra,0xffffe
    80003aca:	538080e7          	jalr	1336(ra) # 80001ffe <fork>
}
    80003ace:	60a2                	ld	ra,8(sp)
    80003ad0:	6402                	ld	s0,0(sp)
    80003ad2:	0141                	addi	sp,sp,16
    80003ad4:	8082                	ret

0000000080003ad6 <sys_wait>:

uint64
sys_wait(void)
{
    80003ad6:	1101                	addi	sp,sp,-32
    80003ad8:	ec06                	sd	ra,24(sp)
    80003ada:	e822                	sd	s0,16(sp)
    80003adc:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003ade:	fe840593          	addi	a1,s0,-24
    80003ae2:	4501                	li	a0,0
    80003ae4:	00000097          	auipc	ra,0x0
    80003ae8:	ebe080e7          	jalr	-322(ra) # 800039a2 <argaddr>
    80003aec:	87aa                	mv	a5,a0
    return -1;
    80003aee:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003af0:	0007c863          	bltz	a5,80003b00 <sys_wait+0x2a>
  return wait(p);
    80003af4:	fe843503          	ld	a0,-24(s0)
    80003af8:	fffff097          	auipc	ra,0xfffff
    80003afc:	92e080e7          	jalr	-1746(ra) # 80002426 <wait>
}
    80003b00:	60e2                	ld	ra,24(sp)
    80003b02:	6442                	ld	s0,16(sp)
    80003b04:	6105                	addi	sp,sp,32
    80003b06:	8082                	ret

0000000080003b08 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003b08:	7179                	addi	sp,sp,-48
    80003b0a:	f406                	sd	ra,40(sp)
    80003b0c:	f022                	sd	s0,32(sp)
    80003b0e:	ec26                	sd	s1,24(sp)
    80003b10:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003b12:	fdc40593          	addi	a1,s0,-36
    80003b16:	4501                	li	a0,0
    80003b18:	00000097          	auipc	ra,0x0
    80003b1c:	e68080e7          	jalr	-408(ra) # 80003980 <argint>
    return -1;
    80003b20:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003b22:	00054f63          	bltz	a0,80003b40 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003b26:	ffffe097          	auipc	ra,0xffffe
    80003b2a:	f56080e7          	jalr	-170(ra) # 80001a7c <myproc>
    80003b2e:	5d04                	lw	s1,56(a0)
  if(growproc(n) < 0)
    80003b30:	fdc42503          	lw	a0,-36(s0)
    80003b34:	ffffe097          	auipc	ra,0xffffe
    80003b38:	456080e7          	jalr	1110(ra) # 80001f8a <growproc>
    80003b3c:	00054863          	bltz	a0,80003b4c <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003b40:	8526                	mv	a0,s1
    80003b42:	70a2                	ld	ra,40(sp)
    80003b44:	7402                	ld	s0,32(sp)
    80003b46:	64e2                	ld	s1,24(sp)
    80003b48:	6145                	addi	sp,sp,48
    80003b4a:	8082                	ret
    return -1;
    80003b4c:	54fd                	li	s1,-1
    80003b4e:	bfcd                	j	80003b40 <sys_sbrk+0x38>

0000000080003b50 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003b50:	7139                	addi	sp,sp,-64
    80003b52:	fc06                	sd	ra,56(sp)
    80003b54:	f822                	sd	s0,48(sp)
    80003b56:	f426                	sd	s1,40(sp)
    80003b58:	f04a                	sd	s2,32(sp)
    80003b5a:	ec4e                	sd	s3,24(sp)
    80003b5c:	e852                	sd	s4,16(sp)
    80003b5e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003b60:	fcc40593          	addi	a1,s0,-52
    80003b64:	4501                	li	a0,0
    80003b66:	00000097          	auipc	ra,0x0
    80003b6a:	e1a080e7          	jalr	-486(ra) # 80003980 <argint>
    return -1;
    80003b6e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003b70:	06054763          	bltz	a0,80003bde <sys_sleep+0x8e>
  acquire(&tickslock);
    80003b74:	00030517          	auipc	a0,0x30
    80003b78:	db450513          	addi	a0,a0,-588 # 80033928 <tickslock>
    80003b7c:	ffffd097          	auipc	ra,0xffffd
    80003b80:	04a080e7          	jalr	74(ra) # 80000bc6 <acquire>
  ticks0 = ticks;
    80003b84:	00006997          	auipc	s3,0x6
    80003b88:	4ac9a983          	lw	s3,1196(s3) # 8000a030 <ticks>
  while(ticks - ticks0 < n){
    80003b8c:	fcc42783          	lw	a5,-52(s0)
    80003b90:	cf95                	beqz	a5,80003bcc <sys_sleep+0x7c>
    if(myproc()->killed==1){
    80003b92:	4905                	li	s2,1
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003b94:	00030a17          	auipc	s4,0x30
    80003b98:	d94a0a13          	addi	s4,s4,-620 # 80033928 <tickslock>
    80003b9c:	00006497          	auipc	s1,0x6
    80003ba0:	49448493          	addi	s1,s1,1172 # 8000a030 <ticks>
    if(myproc()->killed==1){
    80003ba4:	ffffe097          	auipc	ra,0xffffe
    80003ba8:	ed8080e7          	jalr	-296(ra) # 80001a7c <myproc>
    80003bac:	4d5c                	lw	a5,28(a0)
    80003bae:	05278163          	beq	a5,s2,80003bf0 <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    80003bb2:	85d2                	mv	a1,s4
    80003bb4:	8526                	mv	a0,s1
    80003bb6:	fffff097          	auipc	ra,0xfffff
    80003bba:	80c080e7          	jalr	-2036(ra) # 800023c2 <sleep>
  while(ticks - ticks0 < n){
    80003bbe:	409c                	lw	a5,0(s1)
    80003bc0:	413787bb          	subw	a5,a5,s3
    80003bc4:	fcc42703          	lw	a4,-52(s0)
    80003bc8:	fce7eee3          	bltu	a5,a4,80003ba4 <sys_sleep+0x54>
  }
  release(&tickslock);
    80003bcc:	00030517          	auipc	a0,0x30
    80003bd0:	d5c50513          	addi	a0,a0,-676 # 80033928 <tickslock>
    80003bd4:	ffffd097          	auipc	ra,0xffffd
    80003bd8:	0c8080e7          	jalr	200(ra) # 80000c9c <release>
  return 0;
    80003bdc:	4781                	li	a5,0
}
    80003bde:	853e                	mv	a0,a5
    80003be0:	70e2                	ld	ra,56(sp)
    80003be2:	7442                	ld	s0,48(sp)
    80003be4:	74a2                	ld	s1,40(sp)
    80003be6:	7902                	ld	s2,32(sp)
    80003be8:	69e2                	ld	s3,24(sp)
    80003bea:	6a42                	ld	s4,16(sp)
    80003bec:	6121                	addi	sp,sp,64
    80003bee:	8082                	ret
      release(&tickslock);
    80003bf0:	00030517          	auipc	a0,0x30
    80003bf4:	d3850513          	addi	a0,a0,-712 # 80033928 <tickslock>
    80003bf8:	ffffd097          	auipc	ra,0xffffd
    80003bfc:	0a4080e7          	jalr	164(ra) # 80000c9c <release>
      return -1;
    80003c00:	57fd                	li	a5,-1
    80003c02:	bff1                	j	80003bde <sys_sleep+0x8e>

0000000080003c04 <sys_kill>:

uint64
sys_kill(void)
{
    80003c04:	1101                	addi	sp,sp,-32
    80003c06:	ec06                	sd	ra,24(sp)
    80003c08:	e822                	sd	s0,16(sp)
    80003c0a:	1000                	addi	s0,sp,32
  int pid;
  int signum;

  if(argint(0, &pid) < 0)
    80003c0c:	fec40593          	addi	a1,s0,-20
    80003c10:	4501                	li	a0,0
    80003c12:	00000097          	auipc	ra,0x0
    80003c16:	d6e080e7          	jalr	-658(ra) # 80003980 <argint>
    80003c1a:	87aa                	mv	a5,a0
    return -1;
    80003c1c:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003c1e:	0207c963          	bltz	a5,80003c50 <sys_kill+0x4c>
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003c22:	fe840593          	addi	a1,s0,-24
    80003c26:	4505                	li	a0,1
    80003c28:	00000097          	auipc	ra,0x0
    80003c2c:	d58080e7          	jalr	-680(ra) # 80003980 <argint>
    80003c30:	02054463          	bltz	a0,80003c58 <sys_kill+0x54>
    80003c34:	fe842583          	lw	a1,-24(s0)
    80003c38:	0005871b          	sext.w	a4,a1
    80003c3c:	47fd                	li	a5,31
    return -1;
    80003c3e:	557d                	li	a0,-1
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003c40:	00e7e863          	bltu	a5,a4,80003c50 <sys_kill+0x4c>
  return kill(pid, signum);
    80003c44:	fec42503          	lw	a0,-20(s0)
    80003c48:	fffff097          	auipc	ra,0xfffff
    80003c4c:	fcc080e7          	jalr	-52(ra) # 80002c14 <kill>
}
    80003c50:	60e2                	ld	ra,24(sp)
    80003c52:	6442                	ld	s0,16(sp)
    80003c54:	6105                	addi	sp,sp,32
    80003c56:	8082                	ret
    return -1;
    80003c58:	557d                	li	a0,-1
    80003c5a:	bfdd                	j	80003c50 <sys_kill+0x4c>

0000000080003c5c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003c5c:	1101                	addi	sp,sp,-32
    80003c5e:	ec06                	sd	ra,24(sp)
    80003c60:	e822                	sd	s0,16(sp)
    80003c62:	e426                	sd	s1,8(sp)
    80003c64:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003c66:	00030517          	auipc	a0,0x30
    80003c6a:	cc250513          	addi	a0,a0,-830 # 80033928 <tickslock>
    80003c6e:	ffffd097          	auipc	ra,0xffffd
    80003c72:	f58080e7          	jalr	-168(ra) # 80000bc6 <acquire>
  xticks = ticks;
    80003c76:	00006497          	auipc	s1,0x6
    80003c7a:	3ba4a483          	lw	s1,954(s1) # 8000a030 <ticks>
  release(&tickslock);
    80003c7e:	00030517          	auipc	a0,0x30
    80003c82:	caa50513          	addi	a0,a0,-854 # 80033928 <tickslock>
    80003c86:	ffffd097          	auipc	ra,0xffffd
    80003c8a:	016080e7          	jalr	22(ra) # 80000c9c <release>
  return xticks;
}
    80003c8e:	02049513          	slli	a0,s1,0x20
    80003c92:	9101                	srli	a0,a0,0x20
    80003c94:	60e2                	ld	ra,24(sp)
    80003c96:	6442                	ld	s0,16(sp)
    80003c98:	64a2                	ld	s1,8(sp)
    80003c9a:	6105                	addi	sp,sp,32
    80003c9c:	8082                	ret

0000000080003c9e <sys_sigprocmask>:

uint64
sys_sigprocmask(void)
{
    80003c9e:	1101                	addi	sp,sp,-32
    80003ca0:	ec06                	sd	ra,24(sp)
    80003ca2:	e822                	sd	s0,16(sp)
    80003ca4:	1000                	addi	s0,sp,32
  int sigmask;

  if(argint(0, &sigmask) < 0)
    80003ca6:	fec40593          	addi	a1,s0,-20
    80003caa:	4501                	li	a0,0
    80003cac:	00000097          	auipc	ra,0x0
    80003cb0:	cd4080e7          	jalr	-812(ra) # 80003980 <argint>
    80003cb4:	87aa                	mv	a5,a0
    return -1;
    80003cb6:	557d                	li	a0,-1
  if(argint(0, &sigmask) < 0)
    80003cb8:	0007ca63          	bltz	a5,80003ccc <sys_sigprocmask+0x2e>
  return sigprocmask((uint)sigmask);
    80003cbc:	fec42503          	lw	a0,-20(s0)
    80003cc0:	fffff097          	auipc	ra,0xfffff
    80003cc4:	d82080e7          	jalr	-638(ra) # 80002a42 <sigprocmask>
    80003cc8:	1502                	slli	a0,a0,0x20
    80003cca:	9101                	srli	a0,a0,0x20
}
    80003ccc:	60e2                	ld	ra,24(sp)
    80003cce:	6442                	ld	s0,16(sp)
    80003cd0:	6105                	addi	sp,sp,32
    80003cd2:	8082                	ret

0000000080003cd4 <sys_sigaction>:

uint64
sys_sigaction(void)
{
    80003cd4:	7179                	addi	sp,sp,-48
    80003cd6:	f406                	sd	ra,40(sp)
    80003cd8:	f022                	sd	s0,32(sp)
    80003cda:	1800                	addi	s0,sp,48
  int signum;
  uint64 newact;
  uint64 oldact;
  
  if(argint(0, &signum) < 0)
    80003cdc:	fec40593          	addi	a1,s0,-20
    80003ce0:	4501                	li	a0,0
    80003ce2:	00000097          	auipc	ra,0x0
    80003ce6:	c9e080e7          	jalr	-866(ra) # 80003980 <argint>
    return -1;
    80003cea:	57fd                	li	a5,-1
  if(argint(0, &signum) < 0)
    80003cec:	04054163          	bltz	a0,80003d2e <sys_sigaction+0x5a>
  if(argaddr(1, &newact) < 0)
    80003cf0:	fe040593          	addi	a1,s0,-32
    80003cf4:	4505                	li	a0,1
    80003cf6:	00000097          	auipc	ra,0x0
    80003cfa:	cac080e7          	jalr	-852(ra) # 800039a2 <argaddr>
    return -1;
    80003cfe:	57fd                	li	a5,-1
  if(argaddr(1, &newact) < 0)
    80003d00:	02054763          	bltz	a0,80003d2e <sys_sigaction+0x5a>
  if(argaddr(2, &oldact) < 0)
    80003d04:	fd840593          	addi	a1,s0,-40
    80003d08:	4509                	li	a0,2
    80003d0a:	00000097          	auipc	ra,0x0
    80003d0e:	c98080e7          	jalr	-872(ra) # 800039a2 <argaddr>
    return -1;
    80003d12:	57fd                	li	a5,-1
  if(argaddr(2, &oldact) < 0)
    80003d14:	00054d63          	bltz	a0,80003d2e <sys_sigaction+0x5a>

  return sigaction(signum,newact,oldact);
    80003d18:	fd843603          	ld	a2,-40(s0)
    80003d1c:	fe043583          	ld	a1,-32(s0)
    80003d20:	fec42503          	lw	a0,-20(s0)
    80003d24:	fffff097          	auipc	ra,0xfffff
    80003d28:	d72080e7          	jalr	-654(ra) # 80002a96 <sigaction>
    80003d2c:	87aa                	mv	a5,a0
  
}
    80003d2e:	853e                	mv	a0,a5
    80003d30:	70a2                	ld	ra,40(sp)
    80003d32:	7402                	ld	s0,32(sp)
    80003d34:	6145                	addi	sp,sp,48
    80003d36:	8082                	ret

0000000080003d38 <sys_sigret>:
uint64
sys_sigret(void)
{
    80003d38:	1141                	addi	sp,sp,-16
    80003d3a:	e406                	sd	ra,8(sp)
    80003d3c:	e022                	sd	s0,0(sp)
    80003d3e:	0800                	addi	s0,sp,16
  sigret();
    80003d40:	fffff097          	auipc	ra,0xfffff
    80003d44:	e40080e7          	jalr	-448(ra) # 80002b80 <sigret>
  return 0;
}
    80003d48:	4501                	li	a0,0
    80003d4a:	60a2                	ld	ra,8(sp)
    80003d4c:	6402                	ld	s0,0(sp)
    80003d4e:	0141                	addi	sp,sp,16
    80003d50:	8082                	ret

0000000080003d52 <sys_kthread_create>:

uint64
sys_kthread_create(void)
{
    80003d52:	1101                	addi	sp,sp,-32
    80003d54:	ec06                	sd	ra,24(sp)
    80003d56:	e822                	sd	s0,16(sp)
    80003d58:	1000                	addi	s0,sp,32
  uint64 start_func;
  uint64 stack;
  if(argaddr(0, &start_func) < 0)
    80003d5a:	fe840593          	addi	a1,s0,-24
    80003d5e:	4501                	li	a0,0
    80003d60:	00000097          	auipc	ra,0x0
    80003d64:	c42080e7          	jalr	-958(ra) # 800039a2 <argaddr>
    80003d68:	02054463          	bltz	a0,80003d90 <sys_kthread_create+0x3e>
    return -1;
  if(argaddr(1, &stack) < 0)
    80003d6c:	fe040593          	addi	a1,s0,-32
    80003d70:	4505                	li	a0,1
    80003d72:	00000097          	auipc	ra,0x0
    80003d76:	c30080e7          	jalr	-976(ra) # 800039a2 <argaddr>
    80003d7a:	00054b63          	bltz	a0,80003d90 <sys_kthread_create+0x3e>
    return -1;
  kthread_create(start_func,stack);
    80003d7e:	fe043583          	ld	a1,-32(s0)
    80003d82:	fe843503          	ld	a0,-24(s0)
    80003d86:	fffff097          	auipc	ra,0xfffff
    80003d8a:	fb4080e7          	jalr	-76(ra) # 80002d3a <kthread_create>
}
    80003d8e:	a011                	j	80003d92 <sys_kthread_create+0x40>
    80003d90:	557d                	li	a0,-1
    80003d92:	60e2                	ld	ra,24(sp)
    80003d94:	6442                	ld	s0,16(sp)
    80003d96:	6105                	addi	sp,sp,32
    80003d98:	8082                	ret

0000000080003d9a <sys_kthread_id>:

uint64
sys_kthread_id(void){
    80003d9a:	1141                	addi	sp,sp,-16
    80003d9c:	e406                	sd	ra,8(sp)
    80003d9e:	e022                	sd	s0,0(sp)
    80003da0:	0800                	addi	s0,sp,16
  return mykthread()->tid;
    80003da2:	ffffe097          	auipc	ra,0xffffe
    80003da6:	d1a080e7          	jalr	-742(ra) # 80001abc <mykthread>
}
    80003daa:	5908                	lw	a0,48(a0)
    80003dac:	60a2                	ld	ra,8(sp)
    80003dae:	6402                	ld	s0,0(sp)
    80003db0:	0141                	addi	sp,sp,16
    80003db2:	8082                	ret

0000000080003db4 <sys_kthread_exit>:

uint64
sys_kthread_exit(void){
    80003db4:	1101                	addi	sp,sp,-32
    80003db6:	ec06                	sd	ra,24(sp)
    80003db8:	e822                	sd	s0,16(sp)
    80003dba:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003dbc:	fec40593          	addi	a1,s0,-20
    80003dc0:	4501                	li	a0,0
    80003dc2:	00000097          	auipc	ra,0x0
    80003dc6:	bbe080e7          	jalr	-1090(ra) # 80003980 <argint>
    return -1;
    80003dca:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003dcc:	00054963          	bltz	a0,80003dde <sys_kthread_exit+0x2a>
  kthread_exit(n);
    80003dd0:	fec42503          	lw	a0,-20(s0)
    80003dd4:	fffff097          	auipc	ra,0xfffff
    80003dd8:	974080e7          	jalr	-1676(ra) # 80002748 <kthread_exit>
  
  return 0;  // not reached
    80003ddc:	4781                	li	a5,0
}
    80003dde:	853e                	mv	a0,a5
    80003de0:	60e2                	ld	ra,24(sp)
    80003de2:	6442                	ld	s0,16(sp)
    80003de4:	6105                	addi	sp,sp,32
    80003de6:	8082                	ret

0000000080003de8 <sys_kthread_join>:

uint64 
sys_kthread_join(){
    80003de8:	1101                	addi	sp,sp,-32
    80003dea:	ec06                	sd	ra,24(sp)
    80003dec:	e822                	sd	s0,16(sp)
    80003dee:	1000                	addi	s0,sp,32
  int thread_id;
  uint64 status;
  if(argint(0, &thread_id) < 0)
    80003df0:	fec40593          	addi	a1,s0,-20
    80003df4:	4501                	li	a0,0
    80003df6:	00000097          	auipc	ra,0x0
    80003dfa:	b8a080e7          	jalr	-1142(ra) # 80003980 <argint>
    return -1;
    80003dfe:	57fd                	li	a5,-1
  if(argint(0, &thread_id) < 0)
    80003e00:	02054563          	bltz	a0,80003e2a <sys_kthread_join+0x42>
  if(argaddr(1, &status) < 0)
    80003e04:	fe040593          	addi	a1,s0,-32
    80003e08:	4505                	li	a0,1
    80003e0a:	00000097          	auipc	ra,0x0
    80003e0e:	b98080e7          	jalr	-1128(ra) # 800039a2 <argaddr>
    return -1;
    80003e12:	57fd                	li	a5,-1
  if(argaddr(1, &status) < 0)
    80003e14:	00054b63          	bltz	a0,80003e2a <sys_kthread_join+0x42>
  
  return kthread_join(thread_id, status);
    80003e18:	fe043583          	ld	a1,-32(s0)
    80003e1c:	fec42503          	lw	a0,-20(s0)
    80003e20:	fffff097          	auipc	ra,0xfffff
    80003e24:	01e080e7          	jalr	30(ra) # 80002e3e <kthread_join>
    80003e28:	87aa                	mv	a5,a0
    80003e2a:	853e                	mv	a0,a5
    80003e2c:	60e2                	ld	ra,24(sp)
    80003e2e:	6442                	ld	s0,16(sp)
    80003e30:	6105                	addi	sp,sp,32
    80003e32:	8082                	ret

0000000080003e34 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003e34:	7179                	addi	sp,sp,-48
    80003e36:	f406                	sd	ra,40(sp)
    80003e38:	f022                	sd	s0,32(sp)
    80003e3a:	ec26                	sd	s1,24(sp)
    80003e3c:	e84a                	sd	s2,16(sp)
    80003e3e:	e44e                	sd	s3,8(sp)
    80003e40:	e052                	sd	s4,0(sp)
    80003e42:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003e44:	00005597          	auipc	a1,0x5
    80003e48:	7f458593          	addi	a1,a1,2036 # 80009638 <syscalls+0xe8>
    80003e4c:	00030517          	auipc	a0,0x30
    80003e50:	af450513          	addi	a0,a0,-1292 # 80033940 <bcache>
    80003e54:	ffffd097          	auipc	ra,0xffffd
    80003e58:	ce2080e7          	jalr	-798(ra) # 80000b36 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003e5c:	00038797          	auipc	a5,0x38
    80003e60:	ae478793          	addi	a5,a5,-1308 # 8003b940 <bcache+0x8000>
    80003e64:	00038717          	auipc	a4,0x38
    80003e68:	d4470713          	addi	a4,a4,-700 # 8003bba8 <bcache+0x8268>
    80003e6c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003e70:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003e74:	00030497          	auipc	s1,0x30
    80003e78:	ae448493          	addi	s1,s1,-1308 # 80033958 <bcache+0x18>
    b->next = bcache.head.next;
    80003e7c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003e7e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003e80:	00005a17          	auipc	s4,0x5
    80003e84:	7c0a0a13          	addi	s4,s4,1984 # 80009640 <syscalls+0xf0>
    b->next = bcache.head.next;
    80003e88:	2b893783          	ld	a5,696(s2)
    80003e8c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003e8e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003e92:	85d2                	mv	a1,s4
    80003e94:	01048513          	addi	a0,s1,16
    80003e98:	00001097          	auipc	ra,0x1
    80003e9c:	4c0080e7          	jalr	1216(ra) # 80005358 <initsleeplock>
    bcache.head.next->prev = b;
    80003ea0:	2b893783          	ld	a5,696(s2)
    80003ea4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003ea6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003eaa:	45848493          	addi	s1,s1,1112
    80003eae:	fd349de3          	bne	s1,s3,80003e88 <binit+0x54>
  }
}
    80003eb2:	70a2                	ld	ra,40(sp)
    80003eb4:	7402                	ld	s0,32(sp)
    80003eb6:	64e2                	ld	s1,24(sp)
    80003eb8:	6942                	ld	s2,16(sp)
    80003eba:	69a2                	ld	s3,8(sp)
    80003ebc:	6a02                	ld	s4,0(sp)
    80003ebe:	6145                	addi	sp,sp,48
    80003ec0:	8082                	ret

0000000080003ec2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003ec2:	7179                	addi	sp,sp,-48
    80003ec4:	f406                	sd	ra,40(sp)
    80003ec6:	f022                	sd	s0,32(sp)
    80003ec8:	ec26                	sd	s1,24(sp)
    80003eca:	e84a                	sd	s2,16(sp)
    80003ecc:	e44e                	sd	s3,8(sp)
    80003ece:	1800                	addi	s0,sp,48
    80003ed0:	892a                	mv	s2,a0
    80003ed2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003ed4:	00030517          	auipc	a0,0x30
    80003ed8:	a6c50513          	addi	a0,a0,-1428 # 80033940 <bcache>
    80003edc:	ffffd097          	auipc	ra,0xffffd
    80003ee0:	cea080e7          	jalr	-790(ra) # 80000bc6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003ee4:	00038497          	auipc	s1,0x38
    80003ee8:	d144b483          	ld	s1,-748(s1) # 8003bbf8 <bcache+0x82b8>
    80003eec:	00038797          	auipc	a5,0x38
    80003ef0:	cbc78793          	addi	a5,a5,-836 # 8003bba8 <bcache+0x8268>
    80003ef4:	02f48f63          	beq	s1,a5,80003f32 <bread+0x70>
    80003ef8:	873e                	mv	a4,a5
    80003efa:	a021                	j	80003f02 <bread+0x40>
    80003efc:	68a4                	ld	s1,80(s1)
    80003efe:	02e48a63          	beq	s1,a4,80003f32 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003f02:	449c                	lw	a5,8(s1)
    80003f04:	ff279ce3          	bne	a5,s2,80003efc <bread+0x3a>
    80003f08:	44dc                	lw	a5,12(s1)
    80003f0a:	ff3799e3          	bne	a5,s3,80003efc <bread+0x3a>
      b->refcnt++;
    80003f0e:	40bc                	lw	a5,64(s1)
    80003f10:	2785                	addiw	a5,a5,1
    80003f12:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003f14:	00030517          	auipc	a0,0x30
    80003f18:	a2c50513          	addi	a0,a0,-1492 # 80033940 <bcache>
    80003f1c:	ffffd097          	auipc	ra,0xffffd
    80003f20:	d80080e7          	jalr	-640(ra) # 80000c9c <release>
      acquiresleep(&b->lock);
    80003f24:	01048513          	addi	a0,s1,16
    80003f28:	00001097          	auipc	ra,0x1
    80003f2c:	46a080e7          	jalr	1130(ra) # 80005392 <acquiresleep>
      return b;
    80003f30:	a8b9                	j	80003f8e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003f32:	00038497          	auipc	s1,0x38
    80003f36:	cbe4b483          	ld	s1,-834(s1) # 8003bbf0 <bcache+0x82b0>
    80003f3a:	00038797          	auipc	a5,0x38
    80003f3e:	c6e78793          	addi	a5,a5,-914 # 8003bba8 <bcache+0x8268>
    80003f42:	00f48863          	beq	s1,a5,80003f52 <bread+0x90>
    80003f46:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003f48:	40bc                	lw	a5,64(s1)
    80003f4a:	cf81                	beqz	a5,80003f62 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003f4c:	64a4                	ld	s1,72(s1)
    80003f4e:	fee49de3          	bne	s1,a4,80003f48 <bread+0x86>
  panic("bget: no buffers");
    80003f52:	00005517          	auipc	a0,0x5
    80003f56:	6f650513          	addi	a0,a0,1782 # 80009648 <syscalls+0xf8>
    80003f5a:	ffffc097          	auipc	ra,0xffffc
    80003f5e:	5d4080e7          	jalr	1492(ra) # 8000052e <panic>
      b->dev = dev;
    80003f62:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003f66:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003f6a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003f6e:	4785                	li	a5,1
    80003f70:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003f72:	00030517          	auipc	a0,0x30
    80003f76:	9ce50513          	addi	a0,a0,-1586 # 80033940 <bcache>
    80003f7a:	ffffd097          	auipc	ra,0xffffd
    80003f7e:	d22080e7          	jalr	-734(ra) # 80000c9c <release>
      acquiresleep(&b->lock);
    80003f82:	01048513          	addi	a0,s1,16
    80003f86:	00001097          	auipc	ra,0x1
    80003f8a:	40c080e7          	jalr	1036(ra) # 80005392 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003f8e:	409c                	lw	a5,0(s1)
    80003f90:	cb89                	beqz	a5,80003fa2 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003f92:	8526                	mv	a0,s1
    80003f94:	70a2                	ld	ra,40(sp)
    80003f96:	7402                	ld	s0,32(sp)
    80003f98:	64e2                	ld	s1,24(sp)
    80003f9a:	6942                	ld	s2,16(sp)
    80003f9c:	69a2                	ld	s3,8(sp)
    80003f9e:	6145                	addi	sp,sp,48
    80003fa0:	8082                	ret
    virtio_disk_rw(b, 0);
    80003fa2:	4581                	li	a1,0
    80003fa4:	8526                	mv	a0,s1
    80003fa6:	00003097          	auipc	ra,0x3
    80003faa:	fc0080e7          	jalr	-64(ra) # 80006f66 <virtio_disk_rw>
    b->valid = 1;
    80003fae:	4785                	li	a5,1
    80003fb0:	c09c                	sw	a5,0(s1)
  return b;
    80003fb2:	b7c5                	j	80003f92 <bread+0xd0>

0000000080003fb4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003fb4:	1101                	addi	sp,sp,-32
    80003fb6:	ec06                	sd	ra,24(sp)
    80003fb8:	e822                	sd	s0,16(sp)
    80003fba:	e426                	sd	s1,8(sp)
    80003fbc:	1000                	addi	s0,sp,32
    80003fbe:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003fc0:	0541                	addi	a0,a0,16
    80003fc2:	00001097          	auipc	ra,0x1
    80003fc6:	46a080e7          	jalr	1130(ra) # 8000542c <holdingsleep>
    80003fca:	cd01                	beqz	a0,80003fe2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003fcc:	4585                	li	a1,1
    80003fce:	8526                	mv	a0,s1
    80003fd0:	00003097          	auipc	ra,0x3
    80003fd4:	f96080e7          	jalr	-106(ra) # 80006f66 <virtio_disk_rw>
}
    80003fd8:	60e2                	ld	ra,24(sp)
    80003fda:	6442                	ld	s0,16(sp)
    80003fdc:	64a2                	ld	s1,8(sp)
    80003fde:	6105                	addi	sp,sp,32
    80003fe0:	8082                	ret
    panic("bwrite");
    80003fe2:	00005517          	auipc	a0,0x5
    80003fe6:	67e50513          	addi	a0,a0,1662 # 80009660 <syscalls+0x110>
    80003fea:	ffffc097          	auipc	ra,0xffffc
    80003fee:	544080e7          	jalr	1348(ra) # 8000052e <panic>

0000000080003ff2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003ff2:	1101                	addi	sp,sp,-32
    80003ff4:	ec06                	sd	ra,24(sp)
    80003ff6:	e822                	sd	s0,16(sp)
    80003ff8:	e426                	sd	s1,8(sp)
    80003ffa:	e04a                	sd	s2,0(sp)
    80003ffc:	1000                	addi	s0,sp,32
    80003ffe:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004000:	01050913          	addi	s2,a0,16
    80004004:	854a                	mv	a0,s2
    80004006:	00001097          	auipc	ra,0x1
    8000400a:	426080e7          	jalr	1062(ra) # 8000542c <holdingsleep>
    8000400e:	c92d                	beqz	a0,80004080 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80004010:	854a                	mv	a0,s2
    80004012:	00001097          	auipc	ra,0x1
    80004016:	3d6080e7          	jalr	982(ra) # 800053e8 <releasesleep>

  acquire(&bcache.lock);
    8000401a:	00030517          	auipc	a0,0x30
    8000401e:	92650513          	addi	a0,a0,-1754 # 80033940 <bcache>
    80004022:	ffffd097          	auipc	ra,0xffffd
    80004026:	ba4080e7          	jalr	-1116(ra) # 80000bc6 <acquire>
  b->refcnt--;
    8000402a:	40bc                	lw	a5,64(s1)
    8000402c:	37fd                	addiw	a5,a5,-1
    8000402e:	0007871b          	sext.w	a4,a5
    80004032:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80004034:	eb05                	bnez	a4,80004064 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80004036:	68bc                	ld	a5,80(s1)
    80004038:	64b8                	ld	a4,72(s1)
    8000403a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000403c:	64bc                	ld	a5,72(s1)
    8000403e:	68b8                	ld	a4,80(s1)
    80004040:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80004042:	00038797          	auipc	a5,0x38
    80004046:	8fe78793          	addi	a5,a5,-1794 # 8003b940 <bcache+0x8000>
    8000404a:	2b87b703          	ld	a4,696(a5)
    8000404e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80004050:	00038717          	auipc	a4,0x38
    80004054:	b5870713          	addi	a4,a4,-1192 # 8003bba8 <bcache+0x8268>
    80004058:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000405a:	2b87b703          	ld	a4,696(a5)
    8000405e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80004060:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80004064:	00030517          	auipc	a0,0x30
    80004068:	8dc50513          	addi	a0,a0,-1828 # 80033940 <bcache>
    8000406c:	ffffd097          	auipc	ra,0xffffd
    80004070:	c30080e7          	jalr	-976(ra) # 80000c9c <release>
}
    80004074:	60e2                	ld	ra,24(sp)
    80004076:	6442                	ld	s0,16(sp)
    80004078:	64a2                	ld	s1,8(sp)
    8000407a:	6902                	ld	s2,0(sp)
    8000407c:	6105                	addi	sp,sp,32
    8000407e:	8082                	ret
    panic("brelse");
    80004080:	00005517          	auipc	a0,0x5
    80004084:	5e850513          	addi	a0,a0,1512 # 80009668 <syscalls+0x118>
    80004088:	ffffc097          	auipc	ra,0xffffc
    8000408c:	4a6080e7          	jalr	1190(ra) # 8000052e <panic>

0000000080004090 <bpin>:

void
bpin(struct buf *b) {
    80004090:	1101                	addi	sp,sp,-32
    80004092:	ec06                	sd	ra,24(sp)
    80004094:	e822                	sd	s0,16(sp)
    80004096:	e426                	sd	s1,8(sp)
    80004098:	1000                	addi	s0,sp,32
    8000409a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000409c:	00030517          	auipc	a0,0x30
    800040a0:	8a450513          	addi	a0,a0,-1884 # 80033940 <bcache>
    800040a4:	ffffd097          	auipc	ra,0xffffd
    800040a8:	b22080e7          	jalr	-1246(ra) # 80000bc6 <acquire>
  b->refcnt++;
    800040ac:	40bc                	lw	a5,64(s1)
    800040ae:	2785                	addiw	a5,a5,1
    800040b0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800040b2:	00030517          	auipc	a0,0x30
    800040b6:	88e50513          	addi	a0,a0,-1906 # 80033940 <bcache>
    800040ba:	ffffd097          	auipc	ra,0xffffd
    800040be:	be2080e7          	jalr	-1054(ra) # 80000c9c <release>
}
    800040c2:	60e2                	ld	ra,24(sp)
    800040c4:	6442                	ld	s0,16(sp)
    800040c6:	64a2                	ld	s1,8(sp)
    800040c8:	6105                	addi	sp,sp,32
    800040ca:	8082                	ret

00000000800040cc <bunpin>:

void
bunpin(struct buf *b) {
    800040cc:	1101                	addi	sp,sp,-32
    800040ce:	ec06                	sd	ra,24(sp)
    800040d0:	e822                	sd	s0,16(sp)
    800040d2:	e426                	sd	s1,8(sp)
    800040d4:	1000                	addi	s0,sp,32
    800040d6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800040d8:	00030517          	auipc	a0,0x30
    800040dc:	86850513          	addi	a0,a0,-1944 # 80033940 <bcache>
    800040e0:	ffffd097          	auipc	ra,0xffffd
    800040e4:	ae6080e7          	jalr	-1306(ra) # 80000bc6 <acquire>
  b->refcnt--;
    800040e8:	40bc                	lw	a5,64(s1)
    800040ea:	37fd                	addiw	a5,a5,-1
    800040ec:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800040ee:	00030517          	auipc	a0,0x30
    800040f2:	85250513          	addi	a0,a0,-1966 # 80033940 <bcache>
    800040f6:	ffffd097          	auipc	ra,0xffffd
    800040fa:	ba6080e7          	jalr	-1114(ra) # 80000c9c <release>
}
    800040fe:	60e2                	ld	ra,24(sp)
    80004100:	6442                	ld	s0,16(sp)
    80004102:	64a2                	ld	s1,8(sp)
    80004104:	6105                	addi	sp,sp,32
    80004106:	8082                	ret

0000000080004108 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80004108:	1101                	addi	sp,sp,-32
    8000410a:	ec06                	sd	ra,24(sp)
    8000410c:	e822                	sd	s0,16(sp)
    8000410e:	e426                	sd	s1,8(sp)
    80004110:	e04a                	sd	s2,0(sp)
    80004112:	1000                	addi	s0,sp,32
    80004114:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80004116:	00d5d59b          	srliw	a1,a1,0xd
    8000411a:	00038797          	auipc	a5,0x38
    8000411e:	f027a783          	lw	a5,-254(a5) # 8003c01c <sb+0x1c>
    80004122:	9dbd                	addw	a1,a1,a5
    80004124:	00000097          	auipc	ra,0x0
    80004128:	d9e080e7          	jalr	-610(ra) # 80003ec2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000412c:	0074f713          	andi	a4,s1,7
    80004130:	4785                	li	a5,1
    80004132:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80004136:	14ce                	slli	s1,s1,0x33
    80004138:	90d9                	srli	s1,s1,0x36
    8000413a:	00950733          	add	a4,a0,s1
    8000413e:	05874703          	lbu	a4,88(a4)
    80004142:	00e7f6b3          	and	a3,a5,a4
    80004146:	c69d                	beqz	a3,80004174 <bfree+0x6c>
    80004148:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000414a:	94aa                	add	s1,s1,a0
    8000414c:	fff7c793          	not	a5,a5
    80004150:	8ff9                	and	a5,a5,a4
    80004152:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80004156:	00001097          	auipc	ra,0x1
    8000415a:	11c080e7          	jalr	284(ra) # 80005272 <log_write>
  brelse(bp);
    8000415e:	854a                	mv	a0,s2
    80004160:	00000097          	auipc	ra,0x0
    80004164:	e92080e7          	jalr	-366(ra) # 80003ff2 <brelse>
}
    80004168:	60e2                	ld	ra,24(sp)
    8000416a:	6442                	ld	s0,16(sp)
    8000416c:	64a2                	ld	s1,8(sp)
    8000416e:	6902                	ld	s2,0(sp)
    80004170:	6105                	addi	sp,sp,32
    80004172:	8082                	ret
    panic("freeing free block");
    80004174:	00005517          	auipc	a0,0x5
    80004178:	4fc50513          	addi	a0,a0,1276 # 80009670 <syscalls+0x120>
    8000417c:	ffffc097          	auipc	ra,0xffffc
    80004180:	3b2080e7          	jalr	946(ra) # 8000052e <panic>

0000000080004184 <balloc>:
{
    80004184:	711d                	addi	sp,sp,-96
    80004186:	ec86                	sd	ra,88(sp)
    80004188:	e8a2                	sd	s0,80(sp)
    8000418a:	e4a6                	sd	s1,72(sp)
    8000418c:	e0ca                	sd	s2,64(sp)
    8000418e:	fc4e                	sd	s3,56(sp)
    80004190:	f852                	sd	s4,48(sp)
    80004192:	f456                	sd	s5,40(sp)
    80004194:	f05a                	sd	s6,32(sp)
    80004196:	ec5e                	sd	s7,24(sp)
    80004198:	e862                	sd	s8,16(sp)
    8000419a:	e466                	sd	s9,8(sp)
    8000419c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000419e:	00038797          	auipc	a5,0x38
    800041a2:	e667a783          	lw	a5,-410(a5) # 8003c004 <sb+0x4>
    800041a6:	cbd1                	beqz	a5,8000423a <balloc+0xb6>
    800041a8:	8baa                	mv	s7,a0
    800041aa:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800041ac:	00038b17          	auipc	s6,0x38
    800041b0:	e54b0b13          	addi	s6,s6,-428 # 8003c000 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800041b4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800041b6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800041b8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800041ba:	6c89                	lui	s9,0x2
    800041bc:	a831                	j	800041d8 <balloc+0x54>
    brelse(bp);
    800041be:	854a                	mv	a0,s2
    800041c0:	00000097          	auipc	ra,0x0
    800041c4:	e32080e7          	jalr	-462(ra) # 80003ff2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800041c8:	015c87bb          	addw	a5,s9,s5
    800041cc:	00078a9b          	sext.w	s5,a5
    800041d0:	004b2703          	lw	a4,4(s6)
    800041d4:	06eaf363          	bgeu	s5,a4,8000423a <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800041d8:	41fad79b          	sraiw	a5,s5,0x1f
    800041dc:	0137d79b          	srliw	a5,a5,0x13
    800041e0:	015787bb          	addw	a5,a5,s5
    800041e4:	40d7d79b          	sraiw	a5,a5,0xd
    800041e8:	01cb2583          	lw	a1,28(s6)
    800041ec:	9dbd                	addw	a1,a1,a5
    800041ee:	855e                	mv	a0,s7
    800041f0:	00000097          	auipc	ra,0x0
    800041f4:	cd2080e7          	jalr	-814(ra) # 80003ec2 <bread>
    800041f8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800041fa:	004b2503          	lw	a0,4(s6)
    800041fe:	000a849b          	sext.w	s1,s5
    80004202:	8662                	mv	a2,s8
    80004204:	faa4fde3          	bgeu	s1,a0,800041be <balloc+0x3a>
      m = 1 << (bi % 8);
    80004208:	41f6579b          	sraiw	a5,a2,0x1f
    8000420c:	01d7d69b          	srliw	a3,a5,0x1d
    80004210:	00c6873b          	addw	a4,a3,a2
    80004214:	00777793          	andi	a5,a4,7
    80004218:	9f95                	subw	a5,a5,a3
    8000421a:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000421e:	4037571b          	sraiw	a4,a4,0x3
    80004222:	00e906b3          	add	a3,s2,a4
    80004226:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    8000422a:	00d7f5b3          	and	a1,a5,a3
    8000422e:	cd91                	beqz	a1,8000424a <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004230:	2605                	addiw	a2,a2,1
    80004232:	2485                	addiw	s1,s1,1
    80004234:	fd4618e3          	bne	a2,s4,80004204 <balloc+0x80>
    80004238:	b759                	j	800041be <balloc+0x3a>
  panic("balloc: out of blocks");
    8000423a:	00005517          	auipc	a0,0x5
    8000423e:	44e50513          	addi	a0,a0,1102 # 80009688 <syscalls+0x138>
    80004242:	ffffc097          	auipc	ra,0xffffc
    80004246:	2ec080e7          	jalr	748(ra) # 8000052e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000424a:	974a                	add	a4,a4,s2
    8000424c:	8fd5                	or	a5,a5,a3
    8000424e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80004252:	854a                	mv	a0,s2
    80004254:	00001097          	auipc	ra,0x1
    80004258:	01e080e7          	jalr	30(ra) # 80005272 <log_write>
        brelse(bp);
    8000425c:	854a                	mv	a0,s2
    8000425e:	00000097          	auipc	ra,0x0
    80004262:	d94080e7          	jalr	-620(ra) # 80003ff2 <brelse>
  bp = bread(dev, bno);
    80004266:	85a6                	mv	a1,s1
    80004268:	855e                	mv	a0,s7
    8000426a:	00000097          	auipc	ra,0x0
    8000426e:	c58080e7          	jalr	-936(ra) # 80003ec2 <bread>
    80004272:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80004274:	40000613          	li	a2,1024
    80004278:	4581                	li	a1,0
    8000427a:	05850513          	addi	a0,a0,88
    8000427e:	ffffd097          	auipc	ra,0xffffd
    80004282:	a66080e7          	jalr	-1434(ra) # 80000ce4 <memset>
  log_write(bp);
    80004286:	854a                	mv	a0,s2
    80004288:	00001097          	auipc	ra,0x1
    8000428c:	fea080e7          	jalr	-22(ra) # 80005272 <log_write>
  brelse(bp);
    80004290:	854a                	mv	a0,s2
    80004292:	00000097          	auipc	ra,0x0
    80004296:	d60080e7          	jalr	-672(ra) # 80003ff2 <brelse>
}
    8000429a:	8526                	mv	a0,s1
    8000429c:	60e6                	ld	ra,88(sp)
    8000429e:	6446                	ld	s0,80(sp)
    800042a0:	64a6                	ld	s1,72(sp)
    800042a2:	6906                	ld	s2,64(sp)
    800042a4:	79e2                	ld	s3,56(sp)
    800042a6:	7a42                	ld	s4,48(sp)
    800042a8:	7aa2                	ld	s5,40(sp)
    800042aa:	7b02                	ld	s6,32(sp)
    800042ac:	6be2                	ld	s7,24(sp)
    800042ae:	6c42                	ld	s8,16(sp)
    800042b0:	6ca2                	ld	s9,8(sp)
    800042b2:	6125                	addi	sp,sp,96
    800042b4:	8082                	ret

00000000800042b6 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800042b6:	7179                	addi	sp,sp,-48
    800042b8:	f406                	sd	ra,40(sp)
    800042ba:	f022                	sd	s0,32(sp)
    800042bc:	ec26                	sd	s1,24(sp)
    800042be:	e84a                	sd	s2,16(sp)
    800042c0:	e44e                	sd	s3,8(sp)
    800042c2:	e052                	sd	s4,0(sp)
    800042c4:	1800                	addi	s0,sp,48
    800042c6:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800042c8:	47ad                	li	a5,11
    800042ca:	04b7fe63          	bgeu	a5,a1,80004326 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800042ce:	ff45849b          	addiw	s1,a1,-12
    800042d2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800042d6:	0ff00793          	li	a5,255
    800042da:	0ae7e463          	bltu	a5,a4,80004382 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800042de:	08052583          	lw	a1,128(a0)
    800042e2:	c5b5                	beqz	a1,8000434e <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800042e4:	00092503          	lw	a0,0(s2)
    800042e8:	00000097          	auipc	ra,0x0
    800042ec:	bda080e7          	jalr	-1062(ra) # 80003ec2 <bread>
    800042f0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800042f2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800042f6:	02049713          	slli	a4,s1,0x20
    800042fa:	01e75593          	srli	a1,a4,0x1e
    800042fe:	00b784b3          	add	s1,a5,a1
    80004302:	0004a983          	lw	s3,0(s1)
    80004306:	04098e63          	beqz	s3,80004362 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000430a:	8552                	mv	a0,s4
    8000430c:	00000097          	auipc	ra,0x0
    80004310:	ce6080e7          	jalr	-794(ra) # 80003ff2 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80004314:	854e                	mv	a0,s3
    80004316:	70a2                	ld	ra,40(sp)
    80004318:	7402                	ld	s0,32(sp)
    8000431a:	64e2                	ld	s1,24(sp)
    8000431c:	6942                	ld	s2,16(sp)
    8000431e:	69a2                	ld	s3,8(sp)
    80004320:	6a02                	ld	s4,0(sp)
    80004322:	6145                	addi	sp,sp,48
    80004324:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80004326:	02059793          	slli	a5,a1,0x20
    8000432a:	01e7d593          	srli	a1,a5,0x1e
    8000432e:	00b504b3          	add	s1,a0,a1
    80004332:	0504a983          	lw	s3,80(s1)
    80004336:	fc099fe3          	bnez	s3,80004314 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000433a:	4108                	lw	a0,0(a0)
    8000433c:	00000097          	auipc	ra,0x0
    80004340:	e48080e7          	jalr	-440(ra) # 80004184 <balloc>
    80004344:	0005099b          	sext.w	s3,a0
    80004348:	0534a823          	sw	s3,80(s1)
    8000434c:	b7e1                	j	80004314 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000434e:	4108                	lw	a0,0(a0)
    80004350:	00000097          	auipc	ra,0x0
    80004354:	e34080e7          	jalr	-460(ra) # 80004184 <balloc>
    80004358:	0005059b          	sext.w	a1,a0
    8000435c:	08b92023          	sw	a1,128(s2)
    80004360:	b751                	j	800042e4 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80004362:	00092503          	lw	a0,0(s2)
    80004366:	00000097          	auipc	ra,0x0
    8000436a:	e1e080e7          	jalr	-482(ra) # 80004184 <balloc>
    8000436e:	0005099b          	sext.w	s3,a0
    80004372:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80004376:	8552                	mv	a0,s4
    80004378:	00001097          	auipc	ra,0x1
    8000437c:	efa080e7          	jalr	-262(ra) # 80005272 <log_write>
    80004380:	b769                	j	8000430a <bmap+0x54>
  panic("bmap: out of range");
    80004382:	00005517          	auipc	a0,0x5
    80004386:	31e50513          	addi	a0,a0,798 # 800096a0 <syscalls+0x150>
    8000438a:	ffffc097          	auipc	ra,0xffffc
    8000438e:	1a4080e7          	jalr	420(ra) # 8000052e <panic>

0000000080004392 <iget>:
{
    80004392:	7179                	addi	sp,sp,-48
    80004394:	f406                	sd	ra,40(sp)
    80004396:	f022                	sd	s0,32(sp)
    80004398:	ec26                	sd	s1,24(sp)
    8000439a:	e84a                	sd	s2,16(sp)
    8000439c:	e44e                	sd	s3,8(sp)
    8000439e:	e052                	sd	s4,0(sp)
    800043a0:	1800                	addi	s0,sp,48
    800043a2:	89aa                	mv	s3,a0
    800043a4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800043a6:	00038517          	auipc	a0,0x38
    800043aa:	c7a50513          	addi	a0,a0,-902 # 8003c020 <itable>
    800043ae:	ffffd097          	auipc	ra,0xffffd
    800043b2:	818080e7          	jalr	-2024(ra) # 80000bc6 <acquire>
  empty = 0;
    800043b6:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800043b8:	00038497          	auipc	s1,0x38
    800043bc:	c8048493          	addi	s1,s1,-896 # 8003c038 <itable+0x18>
    800043c0:	00039697          	auipc	a3,0x39
    800043c4:	70868693          	addi	a3,a3,1800 # 8003dac8 <log>
    800043c8:	a039                	j	800043d6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800043ca:	02090b63          	beqz	s2,80004400 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800043ce:	08848493          	addi	s1,s1,136
    800043d2:	02d48a63          	beq	s1,a3,80004406 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800043d6:	449c                	lw	a5,8(s1)
    800043d8:	fef059e3          	blez	a5,800043ca <iget+0x38>
    800043dc:	4098                	lw	a4,0(s1)
    800043de:	ff3716e3          	bne	a4,s3,800043ca <iget+0x38>
    800043e2:	40d8                	lw	a4,4(s1)
    800043e4:	ff4713e3          	bne	a4,s4,800043ca <iget+0x38>
      ip->ref++;
    800043e8:	2785                	addiw	a5,a5,1
    800043ea:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800043ec:	00038517          	auipc	a0,0x38
    800043f0:	c3450513          	addi	a0,a0,-972 # 8003c020 <itable>
    800043f4:	ffffd097          	auipc	ra,0xffffd
    800043f8:	8a8080e7          	jalr	-1880(ra) # 80000c9c <release>
      return ip;
    800043fc:	8926                	mv	s2,s1
    800043fe:	a03d                	j	8000442c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004400:	f7f9                	bnez	a5,800043ce <iget+0x3c>
    80004402:	8926                	mv	s2,s1
    80004404:	b7e9                	j	800043ce <iget+0x3c>
  if(empty == 0)
    80004406:	02090c63          	beqz	s2,8000443e <iget+0xac>
  ip->dev = dev;
    8000440a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000440e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80004412:	4785                	li	a5,1
    80004414:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80004418:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000441c:	00038517          	auipc	a0,0x38
    80004420:	c0450513          	addi	a0,a0,-1020 # 8003c020 <itable>
    80004424:	ffffd097          	auipc	ra,0xffffd
    80004428:	878080e7          	jalr	-1928(ra) # 80000c9c <release>
}
    8000442c:	854a                	mv	a0,s2
    8000442e:	70a2                	ld	ra,40(sp)
    80004430:	7402                	ld	s0,32(sp)
    80004432:	64e2                	ld	s1,24(sp)
    80004434:	6942                	ld	s2,16(sp)
    80004436:	69a2                	ld	s3,8(sp)
    80004438:	6a02                	ld	s4,0(sp)
    8000443a:	6145                	addi	sp,sp,48
    8000443c:	8082                	ret
    panic("iget: no inodes");
    8000443e:	00005517          	auipc	a0,0x5
    80004442:	27a50513          	addi	a0,a0,634 # 800096b8 <syscalls+0x168>
    80004446:	ffffc097          	auipc	ra,0xffffc
    8000444a:	0e8080e7          	jalr	232(ra) # 8000052e <panic>

000000008000444e <fsinit>:
fsinit(int dev) {
    8000444e:	7179                	addi	sp,sp,-48
    80004450:	f406                	sd	ra,40(sp)
    80004452:	f022                	sd	s0,32(sp)
    80004454:	ec26                	sd	s1,24(sp)
    80004456:	e84a                	sd	s2,16(sp)
    80004458:	e44e                	sd	s3,8(sp)
    8000445a:	1800                	addi	s0,sp,48
    8000445c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000445e:	4585                	li	a1,1
    80004460:	00000097          	auipc	ra,0x0
    80004464:	a62080e7          	jalr	-1438(ra) # 80003ec2 <bread>
    80004468:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000446a:	00038997          	auipc	s3,0x38
    8000446e:	b9698993          	addi	s3,s3,-1130 # 8003c000 <sb>
    80004472:	02000613          	li	a2,32
    80004476:	05850593          	addi	a1,a0,88
    8000447a:	854e                	mv	a0,s3
    8000447c:	ffffd097          	auipc	ra,0xffffd
    80004480:	8c4080e7          	jalr	-1852(ra) # 80000d40 <memmove>
  brelse(bp);
    80004484:	8526                	mv	a0,s1
    80004486:	00000097          	auipc	ra,0x0
    8000448a:	b6c080e7          	jalr	-1172(ra) # 80003ff2 <brelse>
  if(sb.magic != FSMAGIC)
    8000448e:	0009a703          	lw	a4,0(s3)
    80004492:	102037b7          	lui	a5,0x10203
    80004496:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000449a:	02f71263          	bne	a4,a5,800044be <fsinit+0x70>
  initlog(dev, &sb);
    8000449e:	00038597          	auipc	a1,0x38
    800044a2:	b6258593          	addi	a1,a1,-1182 # 8003c000 <sb>
    800044a6:	854a                	mv	a0,s2
    800044a8:	00001097          	auipc	ra,0x1
    800044ac:	b4c080e7          	jalr	-1204(ra) # 80004ff4 <initlog>
}
    800044b0:	70a2                	ld	ra,40(sp)
    800044b2:	7402                	ld	s0,32(sp)
    800044b4:	64e2                	ld	s1,24(sp)
    800044b6:	6942                	ld	s2,16(sp)
    800044b8:	69a2                	ld	s3,8(sp)
    800044ba:	6145                	addi	sp,sp,48
    800044bc:	8082                	ret
    panic("invalid file system");
    800044be:	00005517          	auipc	a0,0x5
    800044c2:	20a50513          	addi	a0,a0,522 # 800096c8 <syscalls+0x178>
    800044c6:	ffffc097          	auipc	ra,0xffffc
    800044ca:	068080e7          	jalr	104(ra) # 8000052e <panic>

00000000800044ce <iinit>:
{
    800044ce:	7179                	addi	sp,sp,-48
    800044d0:	f406                	sd	ra,40(sp)
    800044d2:	f022                	sd	s0,32(sp)
    800044d4:	ec26                	sd	s1,24(sp)
    800044d6:	e84a                	sd	s2,16(sp)
    800044d8:	e44e                	sd	s3,8(sp)
    800044da:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800044dc:	00005597          	auipc	a1,0x5
    800044e0:	20458593          	addi	a1,a1,516 # 800096e0 <syscalls+0x190>
    800044e4:	00038517          	auipc	a0,0x38
    800044e8:	b3c50513          	addi	a0,a0,-1220 # 8003c020 <itable>
    800044ec:	ffffc097          	auipc	ra,0xffffc
    800044f0:	64a080e7          	jalr	1610(ra) # 80000b36 <initlock>
  for(i = 0; i < NINODE; i++) {
    800044f4:	00038497          	auipc	s1,0x38
    800044f8:	b5448493          	addi	s1,s1,-1196 # 8003c048 <itable+0x28>
    800044fc:	00039997          	auipc	s3,0x39
    80004500:	5dc98993          	addi	s3,s3,1500 # 8003dad8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004504:	00005917          	auipc	s2,0x5
    80004508:	1e490913          	addi	s2,s2,484 # 800096e8 <syscalls+0x198>
    8000450c:	85ca                	mv	a1,s2
    8000450e:	8526                	mv	a0,s1
    80004510:	00001097          	auipc	ra,0x1
    80004514:	e48080e7          	jalr	-440(ra) # 80005358 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004518:	08848493          	addi	s1,s1,136
    8000451c:	ff3498e3          	bne	s1,s3,8000450c <iinit+0x3e>
}
    80004520:	70a2                	ld	ra,40(sp)
    80004522:	7402                	ld	s0,32(sp)
    80004524:	64e2                	ld	s1,24(sp)
    80004526:	6942                	ld	s2,16(sp)
    80004528:	69a2                	ld	s3,8(sp)
    8000452a:	6145                	addi	sp,sp,48
    8000452c:	8082                	ret

000000008000452e <ialloc>:
{
    8000452e:	715d                	addi	sp,sp,-80
    80004530:	e486                	sd	ra,72(sp)
    80004532:	e0a2                	sd	s0,64(sp)
    80004534:	fc26                	sd	s1,56(sp)
    80004536:	f84a                	sd	s2,48(sp)
    80004538:	f44e                	sd	s3,40(sp)
    8000453a:	f052                	sd	s4,32(sp)
    8000453c:	ec56                	sd	s5,24(sp)
    8000453e:	e85a                	sd	s6,16(sp)
    80004540:	e45e                	sd	s7,8(sp)
    80004542:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80004544:	00038717          	auipc	a4,0x38
    80004548:	ac872703          	lw	a4,-1336(a4) # 8003c00c <sb+0xc>
    8000454c:	4785                	li	a5,1
    8000454e:	04e7fa63          	bgeu	a5,a4,800045a2 <ialloc+0x74>
    80004552:	8aaa                	mv	s5,a0
    80004554:	8bae                	mv	s7,a1
    80004556:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80004558:	00038a17          	auipc	s4,0x38
    8000455c:	aa8a0a13          	addi	s4,s4,-1368 # 8003c000 <sb>
    80004560:	00048b1b          	sext.w	s6,s1
    80004564:	0044d793          	srli	a5,s1,0x4
    80004568:	018a2583          	lw	a1,24(s4)
    8000456c:	9dbd                	addw	a1,a1,a5
    8000456e:	8556                	mv	a0,s5
    80004570:	00000097          	auipc	ra,0x0
    80004574:	952080e7          	jalr	-1710(ra) # 80003ec2 <bread>
    80004578:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000457a:	05850993          	addi	s3,a0,88
    8000457e:	00f4f793          	andi	a5,s1,15
    80004582:	079a                	slli	a5,a5,0x6
    80004584:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80004586:	00099783          	lh	a5,0(s3)
    8000458a:	c785                	beqz	a5,800045b2 <ialloc+0x84>
    brelse(bp);
    8000458c:	00000097          	auipc	ra,0x0
    80004590:	a66080e7          	jalr	-1434(ra) # 80003ff2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80004594:	0485                	addi	s1,s1,1
    80004596:	00ca2703          	lw	a4,12(s4)
    8000459a:	0004879b          	sext.w	a5,s1
    8000459e:	fce7e1e3          	bltu	a5,a4,80004560 <ialloc+0x32>
  panic("ialloc: no inodes");
    800045a2:	00005517          	auipc	a0,0x5
    800045a6:	14e50513          	addi	a0,a0,334 # 800096f0 <syscalls+0x1a0>
    800045aa:	ffffc097          	auipc	ra,0xffffc
    800045ae:	f84080e7          	jalr	-124(ra) # 8000052e <panic>
      memset(dip, 0, sizeof(*dip));
    800045b2:	04000613          	li	a2,64
    800045b6:	4581                	li	a1,0
    800045b8:	854e                	mv	a0,s3
    800045ba:	ffffc097          	auipc	ra,0xffffc
    800045be:	72a080e7          	jalr	1834(ra) # 80000ce4 <memset>
      dip->type = type;
    800045c2:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800045c6:	854a                	mv	a0,s2
    800045c8:	00001097          	auipc	ra,0x1
    800045cc:	caa080e7          	jalr	-854(ra) # 80005272 <log_write>
      brelse(bp);
    800045d0:	854a                	mv	a0,s2
    800045d2:	00000097          	auipc	ra,0x0
    800045d6:	a20080e7          	jalr	-1504(ra) # 80003ff2 <brelse>
      return iget(dev, inum);
    800045da:	85da                	mv	a1,s6
    800045dc:	8556                	mv	a0,s5
    800045de:	00000097          	auipc	ra,0x0
    800045e2:	db4080e7          	jalr	-588(ra) # 80004392 <iget>
}
    800045e6:	60a6                	ld	ra,72(sp)
    800045e8:	6406                	ld	s0,64(sp)
    800045ea:	74e2                	ld	s1,56(sp)
    800045ec:	7942                	ld	s2,48(sp)
    800045ee:	79a2                	ld	s3,40(sp)
    800045f0:	7a02                	ld	s4,32(sp)
    800045f2:	6ae2                	ld	s5,24(sp)
    800045f4:	6b42                	ld	s6,16(sp)
    800045f6:	6ba2                	ld	s7,8(sp)
    800045f8:	6161                	addi	sp,sp,80
    800045fa:	8082                	ret

00000000800045fc <iupdate>:
{
    800045fc:	1101                	addi	sp,sp,-32
    800045fe:	ec06                	sd	ra,24(sp)
    80004600:	e822                	sd	s0,16(sp)
    80004602:	e426                	sd	s1,8(sp)
    80004604:	e04a                	sd	s2,0(sp)
    80004606:	1000                	addi	s0,sp,32
    80004608:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000460a:	415c                	lw	a5,4(a0)
    8000460c:	0047d79b          	srliw	a5,a5,0x4
    80004610:	00038597          	auipc	a1,0x38
    80004614:	a085a583          	lw	a1,-1528(a1) # 8003c018 <sb+0x18>
    80004618:	9dbd                	addw	a1,a1,a5
    8000461a:	4108                	lw	a0,0(a0)
    8000461c:	00000097          	auipc	ra,0x0
    80004620:	8a6080e7          	jalr	-1882(ra) # 80003ec2 <bread>
    80004624:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004626:	05850793          	addi	a5,a0,88
    8000462a:	40c8                	lw	a0,4(s1)
    8000462c:	893d                	andi	a0,a0,15
    8000462e:	051a                	slli	a0,a0,0x6
    80004630:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80004632:	04449703          	lh	a4,68(s1)
    80004636:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000463a:	04649703          	lh	a4,70(s1)
    8000463e:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80004642:	04849703          	lh	a4,72(s1)
    80004646:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000464a:	04a49703          	lh	a4,74(s1)
    8000464e:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80004652:	44f8                	lw	a4,76(s1)
    80004654:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004656:	03400613          	li	a2,52
    8000465a:	05048593          	addi	a1,s1,80
    8000465e:	0531                	addi	a0,a0,12
    80004660:	ffffc097          	auipc	ra,0xffffc
    80004664:	6e0080e7          	jalr	1760(ra) # 80000d40 <memmove>
  log_write(bp);
    80004668:	854a                	mv	a0,s2
    8000466a:	00001097          	auipc	ra,0x1
    8000466e:	c08080e7          	jalr	-1016(ra) # 80005272 <log_write>
  brelse(bp);
    80004672:	854a                	mv	a0,s2
    80004674:	00000097          	auipc	ra,0x0
    80004678:	97e080e7          	jalr	-1666(ra) # 80003ff2 <brelse>
}
    8000467c:	60e2                	ld	ra,24(sp)
    8000467e:	6442                	ld	s0,16(sp)
    80004680:	64a2                	ld	s1,8(sp)
    80004682:	6902                	ld	s2,0(sp)
    80004684:	6105                	addi	sp,sp,32
    80004686:	8082                	ret

0000000080004688 <idup>:
{
    80004688:	1101                	addi	sp,sp,-32
    8000468a:	ec06                	sd	ra,24(sp)
    8000468c:	e822                	sd	s0,16(sp)
    8000468e:	e426                	sd	s1,8(sp)
    80004690:	1000                	addi	s0,sp,32
    80004692:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004694:	00038517          	auipc	a0,0x38
    80004698:	98c50513          	addi	a0,a0,-1652 # 8003c020 <itable>
    8000469c:	ffffc097          	auipc	ra,0xffffc
    800046a0:	52a080e7          	jalr	1322(ra) # 80000bc6 <acquire>
  ip->ref++;
    800046a4:	449c                	lw	a5,8(s1)
    800046a6:	2785                	addiw	a5,a5,1
    800046a8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800046aa:	00038517          	auipc	a0,0x38
    800046ae:	97650513          	addi	a0,a0,-1674 # 8003c020 <itable>
    800046b2:	ffffc097          	auipc	ra,0xffffc
    800046b6:	5ea080e7          	jalr	1514(ra) # 80000c9c <release>
}
    800046ba:	8526                	mv	a0,s1
    800046bc:	60e2                	ld	ra,24(sp)
    800046be:	6442                	ld	s0,16(sp)
    800046c0:	64a2                	ld	s1,8(sp)
    800046c2:	6105                	addi	sp,sp,32
    800046c4:	8082                	ret

00000000800046c6 <ilock>:
{
    800046c6:	1101                	addi	sp,sp,-32
    800046c8:	ec06                	sd	ra,24(sp)
    800046ca:	e822                	sd	s0,16(sp)
    800046cc:	e426                	sd	s1,8(sp)
    800046ce:	e04a                	sd	s2,0(sp)
    800046d0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800046d2:	c115                	beqz	a0,800046f6 <ilock+0x30>
    800046d4:	84aa                	mv	s1,a0
    800046d6:	451c                	lw	a5,8(a0)
    800046d8:	00f05f63          	blez	a5,800046f6 <ilock+0x30>
  acquiresleep(&ip->lock);
    800046dc:	0541                	addi	a0,a0,16
    800046de:	00001097          	auipc	ra,0x1
    800046e2:	cb4080e7          	jalr	-844(ra) # 80005392 <acquiresleep>
  if(ip->valid == 0){
    800046e6:	40bc                	lw	a5,64(s1)
    800046e8:	cf99                	beqz	a5,80004706 <ilock+0x40>
}
    800046ea:	60e2                	ld	ra,24(sp)
    800046ec:	6442                	ld	s0,16(sp)
    800046ee:	64a2                	ld	s1,8(sp)
    800046f0:	6902                	ld	s2,0(sp)
    800046f2:	6105                	addi	sp,sp,32
    800046f4:	8082                	ret
    panic("ilock");
    800046f6:	00005517          	auipc	a0,0x5
    800046fa:	01250513          	addi	a0,a0,18 # 80009708 <syscalls+0x1b8>
    800046fe:	ffffc097          	auipc	ra,0xffffc
    80004702:	e30080e7          	jalr	-464(ra) # 8000052e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004706:	40dc                	lw	a5,4(s1)
    80004708:	0047d79b          	srliw	a5,a5,0x4
    8000470c:	00038597          	auipc	a1,0x38
    80004710:	90c5a583          	lw	a1,-1780(a1) # 8003c018 <sb+0x18>
    80004714:	9dbd                	addw	a1,a1,a5
    80004716:	4088                	lw	a0,0(s1)
    80004718:	fffff097          	auipc	ra,0xfffff
    8000471c:	7aa080e7          	jalr	1962(ra) # 80003ec2 <bread>
    80004720:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004722:	05850593          	addi	a1,a0,88
    80004726:	40dc                	lw	a5,4(s1)
    80004728:	8bbd                	andi	a5,a5,15
    8000472a:	079a                	slli	a5,a5,0x6
    8000472c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000472e:	00059783          	lh	a5,0(a1)
    80004732:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004736:	00259783          	lh	a5,2(a1)
    8000473a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000473e:	00459783          	lh	a5,4(a1)
    80004742:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004746:	00659783          	lh	a5,6(a1)
    8000474a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000474e:	459c                	lw	a5,8(a1)
    80004750:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004752:	03400613          	li	a2,52
    80004756:	05b1                	addi	a1,a1,12
    80004758:	05048513          	addi	a0,s1,80
    8000475c:	ffffc097          	auipc	ra,0xffffc
    80004760:	5e4080e7          	jalr	1508(ra) # 80000d40 <memmove>
    brelse(bp);
    80004764:	854a                	mv	a0,s2
    80004766:	00000097          	auipc	ra,0x0
    8000476a:	88c080e7          	jalr	-1908(ra) # 80003ff2 <brelse>
    ip->valid = 1;
    8000476e:	4785                	li	a5,1
    80004770:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004772:	04449783          	lh	a5,68(s1)
    80004776:	fbb5                	bnez	a5,800046ea <ilock+0x24>
      panic("ilock: no type");
    80004778:	00005517          	auipc	a0,0x5
    8000477c:	f9850513          	addi	a0,a0,-104 # 80009710 <syscalls+0x1c0>
    80004780:	ffffc097          	auipc	ra,0xffffc
    80004784:	dae080e7          	jalr	-594(ra) # 8000052e <panic>

0000000080004788 <iunlock>:
{
    80004788:	1101                	addi	sp,sp,-32
    8000478a:	ec06                	sd	ra,24(sp)
    8000478c:	e822                	sd	s0,16(sp)
    8000478e:	e426                	sd	s1,8(sp)
    80004790:	e04a                	sd	s2,0(sp)
    80004792:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004794:	c905                	beqz	a0,800047c4 <iunlock+0x3c>
    80004796:	84aa                	mv	s1,a0
    80004798:	01050913          	addi	s2,a0,16
    8000479c:	854a                	mv	a0,s2
    8000479e:	00001097          	auipc	ra,0x1
    800047a2:	c8e080e7          	jalr	-882(ra) # 8000542c <holdingsleep>
    800047a6:	cd19                	beqz	a0,800047c4 <iunlock+0x3c>
    800047a8:	449c                	lw	a5,8(s1)
    800047aa:	00f05d63          	blez	a5,800047c4 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800047ae:	854a                	mv	a0,s2
    800047b0:	00001097          	auipc	ra,0x1
    800047b4:	c38080e7          	jalr	-968(ra) # 800053e8 <releasesleep>
}
    800047b8:	60e2                	ld	ra,24(sp)
    800047ba:	6442                	ld	s0,16(sp)
    800047bc:	64a2                	ld	s1,8(sp)
    800047be:	6902                	ld	s2,0(sp)
    800047c0:	6105                	addi	sp,sp,32
    800047c2:	8082                	ret
    panic("iunlock");
    800047c4:	00005517          	auipc	a0,0x5
    800047c8:	f5c50513          	addi	a0,a0,-164 # 80009720 <syscalls+0x1d0>
    800047cc:	ffffc097          	auipc	ra,0xffffc
    800047d0:	d62080e7          	jalr	-670(ra) # 8000052e <panic>

00000000800047d4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800047d4:	7179                	addi	sp,sp,-48
    800047d6:	f406                	sd	ra,40(sp)
    800047d8:	f022                	sd	s0,32(sp)
    800047da:	ec26                	sd	s1,24(sp)
    800047dc:	e84a                	sd	s2,16(sp)
    800047de:	e44e                	sd	s3,8(sp)
    800047e0:	e052                	sd	s4,0(sp)
    800047e2:	1800                	addi	s0,sp,48
    800047e4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800047e6:	05050493          	addi	s1,a0,80
    800047ea:	08050913          	addi	s2,a0,128
    800047ee:	a021                	j	800047f6 <itrunc+0x22>
    800047f0:	0491                	addi	s1,s1,4
    800047f2:	01248d63          	beq	s1,s2,8000480c <itrunc+0x38>
    if(ip->addrs[i]){
    800047f6:	408c                	lw	a1,0(s1)
    800047f8:	dde5                	beqz	a1,800047f0 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800047fa:	0009a503          	lw	a0,0(s3)
    800047fe:	00000097          	auipc	ra,0x0
    80004802:	90a080e7          	jalr	-1782(ra) # 80004108 <bfree>
      ip->addrs[i] = 0;
    80004806:	0004a023          	sw	zero,0(s1)
    8000480a:	b7dd                	j	800047f0 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000480c:	0809a583          	lw	a1,128(s3)
    80004810:	e185                	bnez	a1,80004830 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004812:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004816:	854e                	mv	a0,s3
    80004818:	00000097          	auipc	ra,0x0
    8000481c:	de4080e7          	jalr	-540(ra) # 800045fc <iupdate>
}
    80004820:	70a2                	ld	ra,40(sp)
    80004822:	7402                	ld	s0,32(sp)
    80004824:	64e2                	ld	s1,24(sp)
    80004826:	6942                	ld	s2,16(sp)
    80004828:	69a2                	ld	s3,8(sp)
    8000482a:	6a02                	ld	s4,0(sp)
    8000482c:	6145                	addi	sp,sp,48
    8000482e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004830:	0009a503          	lw	a0,0(s3)
    80004834:	fffff097          	auipc	ra,0xfffff
    80004838:	68e080e7          	jalr	1678(ra) # 80003ec2 <bread>
    8000483c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000483e:	05850493          	addi	s1,a0,88
    80004842:	45850913          	addi	s2,a0,1112
    80004846:	a021                	j	8000484e <itrunc+0x7a>
    80004848:	0491                	addi	s1,s1,4
    8000484a:	01248b63          	beq	s1,s2,80004860 <itrunc+0x8c>
      if(a[j])
    8000484e:	408c                	lw	a1,0(s1)
    80004850:	dde5                	beqz	a1,80004848 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80004852:	0009a503          	lw	a0,0(s3)
    80004856:	00000097          	auipc	ra,0x0
    8000485a:	8b2080e7          	jalr	-1870(ra) # 80004108 <bfree>
    8000485e:	b7ed                	j	80004848 <itrunc+0x74>
    brelse(bp);
    80004860:	8552                	mv	a0,s4
    80004862:	fffff097          	auipc	ra,0xfffff
    80004866:	790080e7          	jalr	1936(ra) # 80003ff2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000486a:	0809a583          	lw	a1,128(s3)
    8000486e:	0009a503          	lw	a0,0(s3)
    80004872:	00000097          	auipc	ra,0x0
    80004876:	896080e7          	jalr	-1898(ra) # 80004108 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000487a:	0809a023          	sw	zero,128(s3)
    8000487e:	bf51                	j	80004812 <itrunc+0x3e>

0000000080004880 <iput>:
{
    80004880:	1101                	addi	sp,sp,-32
    80004882:	ec06                	sd	ra,24(sp)
    80004884:	e822                	sd	s0,16(sp)
    80004886:	e426                	sd	s1,8(sp)
    80004888:	e04a                	sd	s2,0(sp)
    8000488a:	1000                	addi	s0,sp,32
    8000488c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000488e:	00037517          	auipc	a0,0x37
    80004892:	79250513          	addi	a0,a0,1938 # 8003c020 <itable>
    80004896:	ffffc097          	auipc	ra,0xffffc
    8000489a:	330080e7          	jalr	816(ra) # 80000bc6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000489e:	4498                	lw	a4,8(s1)
    800048a0:	4785                	li	a5,1
    800048a2:	02f70363          	beq	a4,a5,800048c8 <iput+0x48>
  ip->ref--;
    800048a6:	449c                	lw	a5,8(s1)
    800048a8:	37fd                	addiw	a5,a5,-1
    800048aa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800048ac:	00037517          	auipc	a0,0x37
    800048b0:	77450513          	addi	a0,a0,1908 # 8003c020 <itable>
    800048b4:	ffffc097          	auipc	ra,0xffffc
    800048b8:	3e8080e7          	jalr	1000(ra) # 80000c9c <release>
}
    800048bc:	60e2                	ld	ra,24(sp)
    800048be:	6442                	ld	s0,16(sp)
    800048c0:	64a2                	ld	s1,8(sp)
    800048c2:	6902                	ld	s2,0(sp)
    800048c4:	6105                	addi	sp,sp,32
    800048c6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800048c8:	40bc                	lw	a5,64(s1)
    800048ca:	dff1                	beqz	a5,800048a6 <iput+0x26>
    800048cc:	04a49783          	lh	a5,74(s1)
    800048d0:	fbf9                	bnez	a5,800048a6 <iput+0x26>
    acquiresleep(&ip->lock);
    800048d2:	01048913          	addi	s2,s1,16
    800048d6:	854a                	mv	a0,s2
    800048d8:	00001097          	auipc	ra,0x1
    800048dc:	aba080e7          	jalr	-1350(ra) # 80005392 <acquiresleep>
    release(&itable.lock);
    800048e0:	00037517          	auipc	a0,0x37
    800048e4:	74050513          	addi	a0,a0,1856 # 8003c020 <itable>
    800048e8:	ffffc097          	auipc	ra,0xffffc
    800048ec:	3b4080e7          	jalr	948(ra) # 80000c9c <release>
    itrunc(ip);
    800048f0:	8526                	mv	a0,s1
    800048f2:	00000097          	auipc	ra,0x0
    800048f6:	ee2080e7          	jalr	-286(ra) # 800047d4 <itrunc>
    ip->type = 0;
    800048fa:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800048fe:	8526                	mv	a0,s1
    80004900:	00000097          	auipc	ra,0x0
    80004904:	cfc080e7          	jalr	-772(ra) # 800045fc <iupdate>
    ip->valid = 0;
    80004908:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000490c:	854a                	mv	a0,s2
    8000490e:	00001097          	auipc	ra,0x1
    80004912:	ada080e7          	jalr	-1318(ra) # 800053e8 <releasesleep>
    acquire(&itable.lock);
    80004916:	00037517          	auipc	a0,0x37
    8000491a:	70a50513          	addi	a0,a0,1802 # 8003c020 <itable>
    8000491e:	ffffc097          	auipc	ra,0xffffc
    80004922:	2a8080e7          	jalr	680(ra) # 80000bc6 <acquire>
    80004926:	b741                	j	800048a6 <iput+0x26>

0000000080004928 <iunlockput>:
{
    80004928:	1101                	addi	sp,sp,-32
    8000492a:	ec06                	sd	ra,24(sp)
    8000492c:	e822                	sd	s0,16(sp)
    8000492e:	e426                	sd	s1,8(sp)
    80004930:	1000                	addi	s0,sp,32
    80004932:	84aa                	mv	s1,a0
  iunlock(ip);
    80004934:	00000097          	auipc	ra,0x0
    80004938:	e54080e7          	jalr	-428(ra) # 80004788 <iunlock>
  iput(ip);
    8000493c:	8526                	mv	a0,s1
    8000493e:	00000097          	auipc	ra,0x0
    80004942:	f42080e7          	jalr	-190(ra) # 80004880 <iput>
}
    80004946:	60e2                	ld	ra,24(sp)
    80004948:	6442                	ld	s0,16(sp)
    8000494a:	64a2                	ld	s1,8(sp)
    8000494c:	6105                	addi	sp,sp,32
    8000494e:	8082                	ret

0000000080004950 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004950:	1141                	addi	sp,sp,-16
    80004952:	e422                	sd	s0,8(sp)
    80004954:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004956:	411c                	lw	a5,0(a0)
    80004958:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000495a:	415c                	lw	a5,4(a0)
    8000495c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000495e:	04451783          	lh	a5,68(a0)
    80004962:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004966:	04a51783          	lh	a5,74(a0)
    8000496a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000496e:	04c56783          	lwu	a5,76(a0)
    80004972:	e99c                	sd	a5,16(a1)
}
    80004974:	6422                	ld	s0,8(sp)
    80004976:	0141                	addi	sp,sp,16
    80004978:	8082                	ret

000000008000497a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000497a:	457c                	lw	a5,76(a0)
    8000497c:	0ed7e963          	bltu	a5,a3,80004a6e <readi+0xf4>
{
    80004980:	7159                	addi	sp,sp,-112
    80004982:	f486                	sd	ra,104(sp)
    80004984:	f0a2                	sd	s0,96(sp)
    80004986:	eca6                	sd	s1,88(sp)
    80004988:	e8ca                	sd	s2,80(sp)
    8000498a:	e4ce                	sd	s3,72(sp)
    8000498c:	e0d2                	sd	s4,64(sp)
    8000498e:	fc56                	sd	s5,56(sp)
    80004990:	f85a                	sd	s6,48(sp)
    80004992:	f45e                	sd	s7,40(sp)
    80004994:	f062                	sd	s8,32(sp)
    80004996:	ec66                	sd	s9,24(sp)
    80004998:	e86a                	sd	s10,16(sp)
    8000499a:	e46e                	sd	s11,8(sp)
    8000499c:	1880                	addi	s0,sp,112
    8000499e:	8baa                	mv	s7,a0
    800049a0:	8c2e                	mv	s8,a1
    800049a2:	8ab2                	mv	s5,a2
    800049a4:	84b6                	mv	s1,a3
    800049a6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800049a8:	9f35                	addw	a4,a4,a3
    return 0;
    800049aa:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800049ac:	0ad76063          	bltu	a4,a3,80004a4c <readi+0xd2>
  if(off + n > ip->size)
    800049b0:	00e7f463          	bgeu	a5,a4,800049b8 <readi+0x3e>
    n = ip->size - off;
    800049b4:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800049b8:	0a0b0963          	beqz	s6,80004a6a <readi+0xf0>
    800049bc:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800049be:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800049c2:	5cfd                	li	s9,-1
    800049c4:	a82d                	j	800049fe <readi+0x84>
    800049c6:	020a1d93          	slli	s11,s4,0x20
    800049ca:	020ddd93          	srli	s11,s11,0x20
    800049ce:	05890793          	addi	a5,s2,88
    800049d2:	86ee                	mv	a3,s11
    800049d4:	963e                	add	a2,a2,a5
    800049d6:	85d6                	mv	a1,s5
    800049d8:	8562                	mv	a0,s8
    800049da:	ffffe097          	auipc	ra,0xffffe
    800049de:	eea080e7          	jalr	-278(ra) # 800028c4 <either_copyout>
    800049e2:	05950d63          	beq	a0,s9,80004a3c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800049e6:	854a                	mv	a0,s2
    800049e8:	fffff097          	auipc	ra,0xfffff
    800049ec:	60a080e7          	jalr	1546(ra) # 80003ff2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800049f0:	013a09bb          	addw	s3,s4,s3
    800049f4:	009a04bb          	addw	s1,s4,s1
    800049f8:	9aee                	add	s5,s5,s11
    800049fa:	0569f763          	bgeu	s3,s6,80004a48 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800049fe:	000ba903          	lw	s2,0(s7)
    80004a02:	00a4d59b          	srliw	a1,s1,0xa
    80004a06:	855e                	mv	a0,s7
    80004a08:	00000097          	auipc	ra,0x0
    80004a0c:	8ae080e7          	jalr	-1874(ra) # 800042b6 <bmap>
    80004a10:	0005059b          	sext.w	a1,a0
    80004a14:	854a                	mv	a0,s2
    80004a16:	fffff097          	auipc	ra,0xfffff
    80004a1a:	4ac080e7          	jalr	1196(ra) # 80003ec2 <bread>
    80004a1e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004a20:	3ff4f613          	andi	a2,s1,1023
    80004a24:	40cd07bb          	subw	a5,s10,a2
    80004a28:	413b073b          	subw	a4,s6,s3
    80004a2c:	8a3e                	mv	s4,a5
    80004a2e:	2781                	sext.w	a5,a5
    80004a30:	0007069b          	sext.w	a3,a4
    80004a34:	f8f6f9e3          	bgeu	a3,a5,800049c6 <readi+0x4c>
    80004a38:	8a3a                	mv	s4,a4
    80004a3a:	b771                	j	800049c6 <readi+0x4c>
      brelse(bp);
    80004a3c:	854a                	mv	a0,s2
    80004a3e:	fffff097          	auipc	ra,0xfffff
    80004a42:	5b4080e7          	jalr	1460(ra) # 80003ff2 <brelse>
      tot = -1;
    80004a46:	59fd                	li	s3,-1
  }
  return tot;
    80004a48:	0009851b          	sext.w	a0,s3
}
    80004a4c:	70a6                	ld	ra,104(sp)
    80004a4e:	7406                	ld	s0,96(sp)
    80004a50:	64e6                	ld	s1,88(sp)
    80004a52:	6946                	ld	s2,80(sp)
    80004a54:	69a6                	ld	s3,72(sp)
    80004a56:	6a06                	ld	s4,64(sp)
    80004a58:	7ae2                	ld	s5,56(sp)
    80004a5a:	7b42                	ld	s6,48(sp)
    80004a5c:	7ba2                	ld	s7,40(sp)
    80004a5e:	7c02                	ld	s8,32(sp)
    80004a60:	6ce2                	ld	s9,24(sp)
    80004a62:	6d42                	ld	s10,16(sp)
    80004a64:	6da2                	ld	s11,8(sp)
    80004a66:	6165                	addi	sp,sp,112
    80004a68:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004a6a:	89da                	mv	s3,s6
    80004a6c:	bff1                	j	80004a48 <readi+0xce>
    return 0;
    80004a6e:	4501                	li	a0,0
}
    80004a70:	8082                	ret

0000000080004a72 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004a72:	457c                	lw	a5,76(a0)
    80004a74:	10d7e863          	bltu	a5,a3,80004b84 <writei+0x112>
{
    80004a78:	7159                	addi	sp,sp,-112
    80004a7a:	f486                	sd	ra,104(sp)
    80004a7c:	f0a2                	sd	s0,96(sp)
    80004a7e:	eca6                	sd	s1,88(sp)
    80004a80:	e8ca                	sd	s2,80(sp)
    80004a82:	e4ce                	sd	s3,72(sp)
    80004a84:	e0d2                	sd	s4,64(sp)
    80004a86:	fc56                	sd	s5,56(sp)
    80004a88:	f85a                	sd	s6,48(sp)
    80004a8a:	f45e                	sd	s7,40(sp)
    80004a8c:	f062                	sd	s8,32(sp)
    80004a8e:	ec66                	sd	s9,24(sp)
    80004a90:	e86a                	sd	s10,16(sp)
    80004a92:	e46e                	sd	s11,8(sp)
    80004a94:	1880                	addi	s0,sp,112
    80004a96:	8b2a                	mv	s6,a0
    80004a98:	8c2e                	mv	s8,a1
    80004a9a:	8ab2                	mv	s5,a2
    80004a9c:	8936                	mv	s2,a3
    80004a9e:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004aa0:	00e687bb          	addw	a5,a3,a4
    80004aa4:	0ed7e263          	bltu	a5,a3,80004b88 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004aa8:	00043737          	lui	a4,0x43
    80004aac:	0ef76063          	bltu	a4,a5,80004b8c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004ab0:	0c0b8863          	beqz	s7,80004b80 <writei+0x10e>
    80004ab4:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004ab6:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004aba:	5cfd                	li	s9,-1
    80004abc:	a091                	j	80004b00 <writei+0x8e>
    80004abe:	02099d93          	slli	s11,s3,0x20
    80004ac2:	020ddd93          	srli	s11,s11,0x20
    80004ac6:	05848793          	addi	a5,s1,88
    80004aca:	86ee                	mv	a3,s11
    80004acc:	8656                	mv	a2,s5
    80004ace:	85e2                	mv	a1,s8
    80004ad0:	953e                	add	a0,a0,a5
    80004ad2:	ffffe097          	auipc	ra,0xffffe
    80004ad6:	e48080e7          	jalr	-440(ra) # 8000291a <either_copyin>
    80004ada:	07950263          	beq	a0,s9,80004b3e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004ade:	8526                	mv	a0,s1
    80004ae0:	00000097          	auipc	ra,0x0
    80004ae4:	792080e7          	jalr	1938(ra) # 80005272 <log_write>
    brelse(bp);
    80004ae8:	8526                	mv	a0,s1
    80004aea:	fffff097          	auipc	ra,0xfffff
    80004aee:	508080e7          	jalr	1288(ra) # 80003ff2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004af2:	01498a3b          	addw	s4,s3,s4
    80004af6:	0129893b          	addw	s2,s3,s2
    80004afa:	9aee                	add	s5,s5,s11
    80004afc:	057a7663          	bgeu	s4,s7,80004b48 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004b00:	000b2483          	lw	s1,0(s6)
    80004b04:	00a9559b          	srliw	a1,s2,0xa
    80004b08:	855a                	mv	a0,s6
    80004b0a:	fffff097          	auipc	ra,0xfffff
    80004b0e:	7ac080e7          	jalr	1964(ra) # 800042b6 <bmap>
    80004b12:	0005059b          	sext.w	a1,a0
    80004b16:	8526                	mv	a0,s1
    80004b18:	fffff097          	auipc	ra,0xfffff
    80004b1c:	3aa080e7          	jalr	938(ra) # 80003ec2 <bread>
    80004b20:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004b22:	3ff97513          	andi	a0,s2,1023
    80004b26:	40ad07bb          	subw	a5,s10,a0
    80004b2a:	414b873b          	subw	a4,s7,s4
    80004b2e:	89be                	mv	s3,a5
    80004b30:	2781                	sext.w	a5,a5
    80004b32:	0007069b          	sext.w	a3,a4
    80004b36:	f8f6f4e3          	bgeu	a3,a5,80004abe <writei+0x4c>
    80004b3a:	89ba                	mv	s3,a4
    80004b3c:	b749                	j	80004abe <writei+0x4c>
      brelse(bp);
    80004b3e:	8526                	mv	a0,s1
    80004b40:	fffff097          	auipc	ra,0xfffff
    80004b44:	4b2080e7          	jalr	1202(ra) # 80003ff2 <brelse>
  }

  if(off > ip->size)
    80004b48:	04cb2783          	lw	a5,76(s6)
    80004b4c:	0127f463          	bgeu	a5,s2,80004b54 <writei+0xe2>
    ip->size = off;
    80004b50:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004b54:	855a                	mv	a0,s6
    80004b56:	00000097          	auipc	ra,0x0
    80004b5a:	aa6080e7          	jalr	-1370(ra) # 800045fc <iupdate>

  return tot;
    80004b5e:	000a051b          	sext.w	a0,s4
}
    80004b62:	70a6                	ld	ra,104(sp)
    80004b64:	7406                	ld	s0,96(sp)
    80004b66:	64e6                	ld	s1,88(sp)
    80004b68:	6946                	ld	s2,80(sp)
    80004b6a:	69a6                	ld	s3,72(sp)
    80004b6c:	6a06                	ld	s4,64(sp)
    80004b6e:	7ae2                	ld	s5,56(sp)
    80004b70:	7b42                	ld	s6,48(sp)
    80004b72:	7ba2                	ld	s7,40(sp)
    80004b74:	7c02                	ld	s8,32(sp)
    80004b76:	6ce2                	ld	s9,24(sp)
    80004b78:	6d42                	ld	s10,16(sp)
    80004b7a:	6da2                	ld	s11,8(sp)
    80004b7c:	6165                	addi	sp,sp,112
    80004b7e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004b80:	8a5e                	mv	s4,s7
    80004b82:	bfc9                	j	80004b54 <writei+0xe2>
    return -1;
    80004b84:	557d                	li	a0,-1
}
    80004b86:	8082                	ret
    return -1;
    80004b88:	557d                	li	a0,-1
    80004b8a:	bfe1                	j	80004b62 <writei+0xf0>
    return -1;
    80004b8c:	557d                	li	a0,-1
    80004b8e:	bfd1                	j	80004b62 <writei+0xf0>

0000000080004b90 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004b90:	1141                	addi	sp,sp,-16
    80004b92:	e406                	sd	ra,8(sp)
    80004b94:	e022                	sd	s0,0(sp)
    80004b96:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004b98:	4639                	li	a2,14
    80004b9a:	ffffc097          	auipc	ra,0xffffc
    80004b9e:	222080e7          	jalr	546(ra) # 80000dbc <strncmp>
}
    80004ba2:	60a2                	ld	ra,8(sp)
    80004ba4:	6402                	ld	s0,0(sp)
    80004ba6:	0141                	addi	sp,sp,16
    80004ba8:	8082                	ret

0000000080004baa <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004baa:	7139                	addi	sp,sp,-64
    80004bac:	fc06                	sd	ra,56(sp)
    80004bae:	f822                	sd	s0,48(sp)
    80004bb0:	f426                	sd	s1,40(sp)
    80004bb2:	f04a                	sd	s2,32(sp)
    80004bb4:	ec4e                	sd	s3,24(sp)
    80004bb6:	e852                	sd	s4,16(sp)
    80004bb8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004bba:	04451703          	lh	a4,68(a0)
    80004bbe:	4785                	li	a5,1
    80004bc0:	00f71a63          	bne	a4,a5,80004bd4 <dirlookup+0x2a>
    80004bc4:	892a                	mv	s2,a0
    80004bc6:	89ae                	mv	s3,a1
    80004bc8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004bca:	457c                	lw	a5,76(a0)
    80004bcc:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004bce:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004bd0:	e79d                	bnez	a5,80004bfe <dirlookup+0x54>
    80004bd2:	a8a5                	j	80004c4a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004bd4:	00005517          	auipc	a0,0x5
    80004bd8:	b5450513          	addi	a0,a0,-1196 # 80009728 <syscalls+0x1d8>
    80004bdc:	ffffc097          	auipc	ra,0xffffc
    80004be0:	952080e7          	jalr	-1710(ra) # 8000052e <panic>
      panic("dirlookup read");
    80004be4:	00005517          	auipc	a0,0x5
    80004be8:	b5c50513          	addi	a0,a0,-1188 # 80009740 <syscalls+0x1f0>
    80004bec:	ffffc097          	auipc	ra,0xffffc
    80004bf0:	942080e7          	jalr	-1726(ra) # 8000052e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004bf4:	24c1                	addiw	s1,s1,16
    80004bf6:	04c92783          	lw	a5,76(s2)
    80004bfa:	04f4f763          	bgeu	s1,a5,80004c48 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004bfe:	4741                	li	a4,16
    80004c00:	86a6                	mv	a3,s1
    80004c02:	fc040613          	addi	a2,s0,-64
    80004c06:	4581                	li	a1,0
    80004c08:	854a                	mv	a0,s2
    80004c0a:	00000097          	auipc	ra,0x0
    80004c0e:	d70080e7          	jalr	-656(ra) # 8000497a <readi>
    80004c12:	47c1                	li	a5,16
    80004c14:	fcf518e3          	bne	a0,a5,80004be4 <dirlookup+0x3a>
    if(de.inum == 0)
    80004c18:	fc045783          	lhu	a5,-64(s0)
    80004c1c:	dfe1                	beqz	a5,80004bf4 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004c1e:	fc240593          	addi	a1,s0,-62
    80004c22:	854e                	mv	a0,s3
    80004c24:	00000097          	auipc	ra,0x0
    80004c28:	f6c080e7          	jalr	-148(ra) # 80004b90 <namecmp>
    80004c2c:	f561                	bnez	a0,80004bf4 <dirlookup+0x4a>
      if(poff)
    80004c2e:	000a0463          	beqz	s4,80004c36 <dirlookup+0x8c>
        *poff = off;
    80004c32:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004c36:	fc045583          	lhu	a1,-64(s0)
    80004c3a:	00092503          	lw	a0,0(s2)
    80004c3e:	fffff097          	auipc	ra,0xfffff
    80004c42:	754080e7          	jalr	1876(ra) # 80004392 <iget>
    80004c46:	a011                	j	80004c4a <dirlookup+0xa0>
  return 0;
    80004c48:	4501                	li	a0,0
}
    80004c4a:	70e2                	ld	ra,56(sp)
    80004c4c:	7442                	ld	s0,48(sp)
    80004c4e:	74a2                	ld	s1,40(sp)
    80004c50:	7902                	ld	s2,32(sp)
    80004c52:	69e2                	ld	s3,24(sp)
    80004c54:	6a42                	ld	s4,16(sp)
    80004c56:	6121                	addi	sp,sp,64
    80004c58:	8082                	ret

0000000080004c5a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004c5a:	711d                	addi	sp,sp,-96
    80004c5c:	ec86                	sd	ra,88(sp)
    80004c5e:	e8a2                	sd	s0,80(sp)
    80004c60:	e4a6                	sd	s1,72(sp)
    80004c62:	e0ca                	sd	s2,64(sp)
    80004c64:	fc4e                	sd	s3,56(sp)
    80004c66:	f852                	sd	s4,48(sp)
    80004c68:	f456                	sd	s5,40(sp)
    80004c6a:	f05a                	sd	s6,32(sp)
    80004c6c:	ec5e                	sd	s7,24(sp)
    80004c6e:	e862                	sd	s8,16(sp)
    80004c70:	e466                	sd	s9,8(sp)
    80004c72:	1080                	addi	s0,sp,96
    80004c74:	84aa                	mv	s1,a0
    80004c76:	8aae                	mv	s5,a1
    80004c78:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004c7a:	00054703          	lbu	a4,0(a0)
    80004c7e:	02f00793          	li	a5,47
    80004c82:	02f70263          	beq	a4,a5,80004ca6 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004c86:	ffffd097          	auipc	ra,0xffffd
    80004c8a:	df6080e7          	jalr	-522(ra) # 80001a7c <myproc>
    80004c8e:	6968                	ld	a0,208(a0)
    80004c90:	00000097          	auipc	ra,0x0
    80004c94:	9f8080e7          	jalr	-1544(ra) # 80004688 <idup>
    80004c98:	89aa                	mv	s3,a0
  while(*path == '/')
    80004c9a:	02f00913          	li	s2,47
  len = path - s;
    80004c9e:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004ca0:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004ca2:	4b85                	li	s7,1
    80004ca4:	a865                	j	80004d5c <namex+0x102>
    ip = iget(ROOTDEV, ROOTINO);
    80004ca6:	4585                	li	a1,1
    80004ca8:	4505                	li	a0,1
    80004caa:	fffff097          	auipc	ra,0xfffff
    80004cae:	6e8080e7          	jalr	1768(ra) # 80004392 <iget>
    80004cb2:	89aa                	mv	s3,a0
    80004cb4:	b7dd                	j	80004c9a <namex+0x40>
      iunlockput(ip);
    80004cb6:	854e                	mv	a0,s3
    80004cb8:	00000097          	auipc	ra,0x0
    80004cbc:	c70080e7          	jalr	-912(ra) # 80004928 <iunlockput>
      return 0;
    80004cc0:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004cc2:	854e                	mv	a0,s3
    80004cc4:	60e6                	ld	ra,88(sp)
    80004cc6:	6446                	ld	s0,80(sp)
    80004cc8:	64a6                	ld	s1,72(sp)
    80004cca:	6906                	ld	s2,64(sp)
    80004ccc:	79e2                	ld	s3,56(sp)
    80004cce:	7a42                	ld	s4,48(sp)
    80004cd0:	7aa2                	ld	s5,40(sp)
    80004cd2:	7b02                	ld	s6,32(sp)
    80004cd4:	6be2                	ld	s7,24(sp)
    80004cd6:	6c42                	ld	s8,16(sp)
    80004cd8:	6ca2                	ld	s9,8(sp)
    80004cda:	6125                	addi	sp,sp,96
    80004cdc:	8082                	ret
      iunlock(ip);
    80004cde:	854e                	mv	a0,s3
    80004ce0:	00000097          	auipc	ra,0x0
    80004ce4:	aa8080e7          	jalr	-1368(ra) # 80004788 <iunlock>
      return ip;
    80004ce8:	bfe9                	j	80004cc2 <namex+0x68>
      iunlockput(ip);
    80004cea:	854e                	mv	a0,s3
    80004cec:	00000097          	auipc	ra,0x0
    80004cf0:	c3c080e7          	jalr	-964(ra) # 80004928 <iunlockput>
      return 0;
    80004cf4:	89e6                	mv	s3,s9
    80004cf6:	b7f1                	j	80004cc2 <namex+0x68>
  len = path - s;
    80004cf8:	40b48633          	sub	a2,s1,a1
    80004cfc:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004d00:	099c5463          	bge	s8,s9,80004d88 <namex+0x12e>
    memmove(name, s, DIRSIZ);
    80004d04:	4639                	li	a2,14
    80004d06:	8552                	mv	a0,s4
    80004d08:	ffffc097          	auipc	ra,0xffffc
    80004d0c:	038080e7          	jalr	56(ra) # 80000d40 <memmove>
  while(*path == '/')
    80004d10:	0004c783          	lbu	a5,0(s1)
    80004d14:	01279763          	bne	a5,s2,80004d22 <namex+0xc8>
    path++;
    80004d18:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004d1a:	0004c783          	lbu	a5,0(s1)
    80004d1e:	ff278de3          	beq	a5,s2,80004d18 <namex+0xbe>
    ilock(ip);
    80004d22:	854e                	mv	a0,s3
    80004d24:	00000097          	auipc	ra,0x0
    80004d28:	9a2080e7          	jalr	-1630(ra) # 800046c6 <ilock>
    if(ip->type != T_DIR){
    80004d2c:	04499783          	lh	a5,68(s3)
    80004d30:	f97793e3          	bne	a5,s7,80004cb6 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004d34:	000a8563          	beqz	s5,80004d3e <namex+0xe4>
    80004d38:	0004c783          	lbu	a5,0(s1)
    80004d3c:	d3cd                	beqz	a5,80004cde <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004d3e:	865a                	mv	a2,s6
    80004d40:	85d2                	mv	a1,s4
    80004d42:	854e                	mv	a0,s3
    80004d44:	00000097          	auipc	ra,0x0
    80004d48:	e66080e7          	jalr	-410(ra) # 80004baa <dirlookup>
    80004d4c:	8caa                	mv	s9,a0
    80004d4e:	dd51                	beqz	a0,80004cea <namex+0x90>
    iunlockput(ip);
    80004d50:	854e                	mv	a0,s3
    80004d52:	00000097          	auipc	ra,0x0
    80004d56:	bd6080e7          	jalr	-1066(ra) # 80004928 <iunlockput>
    ip = next;
    80004d5a:	89e6                	mv	s3,s9
  while(*path == '/')
    80004d5c:	0004c783          	lbu	a5,0(s1)
    80004d60:	05279763          	bne	a5,s2,80004dae <namex+0x154>
    path++;
    80004d64:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004d66:	0004c783          	lbu	a5,0(s1)
    80004d6a:	ff278de3          	beq	a5,s2,80004d64 <namex+0x10a>
  if(*path == 0)
    80004d6e:	c79d                	beqz	a5,80004d9c <namex+0x142>
    path++;
    80004d70:	85a6                	mv	a1,s1
  len = path - s;
    80004d72:	8cda                	mv	s9,s6
    80004d74:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004d76:	01278963          	beq	a5,s2,80004d88 <namex+0x12e>
    80004d7a:	dfbd                	beqz	a5,80004cf8 <namex+0x9e>
    path++;
    80004d7c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004d7e:	0004c783          	lbu	a5,0(s1)
    80004d82:	ff279ce3          	bne	a5,s2,80004d7a <namex+0x120>
    80004d86:	bf8d                	j	80004cf8 <namex+0x9e>
    memmove(name, s, len);
    80004d88:	2601                	sext.w	a2,a2
    80004d8a:	8552                	mv	a0,s4
    80004d8c:	ffffc097          	auipc	ra,0xffffc
    80004d90:	fb4080e7          	jalr	-76(ra) # 80000d40 <memmove>
    name[len] = 0;
    80004d94:	9cd2                	add	s9,s9,s4
    80004d96:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004d9a:	bf9d                	j	80004d10 <namex+0xb6>
  if(nameiparent){
    80004d9c:	f20a83e3          	beqz	s5,80004cc2 <namex+0x68>
    iput(ip);
    80004da0:	854e                	mv	a0,s3
    80004da2:	00000097          	auipc	ra,0x0
    80004da6:	ade080e7          	jalr	-1314(ra) # 80004880 <iput>
    return 0;
    80004daa:	4981                	li	s3,0
    80004dac:	bf19                	j	80004cc2 <namex+0x68>
  if(*path == 0)
    80004dae:	d7fd                	beqz	a5,80004d9c <namex+0x142>
  while(*path != '/' && *path != 0)
    80004db0:	0004c783          	lbu	a5,0(s1)
    80004db4:	85a6                	mv	a1,s1
    80004db6:	b7d1                	j	80004d7a <namex+0x120>

0000000080004db8 <dirlink>:
{
    80004db8:	7139                	addi	sp,sp,-64
    80004dba:	fc06                	sd	ra,56(sp)
    80004dbc:	f822                	sd	s0,48(sp)
    80004dbe:	f426                	sd	s1,40(sp)
    80004dc0:	f04a                	sd	s2,32(sp)
    80004dc2:	ec4e                	sd	s3,24(sp)
    80004dc4:	e852                	sd	s4,16(sp)
    80004dc6:	0080                	addi	s0,sp,64
    80004dc8:	892a                	mv	s2,a0
    80004dca:	8a2e                	mv	s4,a1
    80004dcc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004dce:	4601                	li	a2,0
    80004dd0:	00000097          	auipc	ra,0x0
    80004dd4:	dda080e7          	jalr	-550(ra) # 80004baa <dirlookup>
    80004dd8:	e93d                	bnez	a0,80004e4e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004dda:	04c92483          	lw	s1,76(s2)
    80004dde:	c49d                	beqz	s1,80004e0c <dirlink+0x54>
    80004de0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004de2:	4741                	li	a4,16
    80004de4:	86a6                	mv	a3,s1
    80004de6:	fc040613          	addi	a2,s0,-64
    80004dea:	4581                	li	a1,0
    80004dec:	854a                	mv	a0,s2
    80004dee:	00000097          	auipc	ra,0x0
    80004df2:	b8c080e7          	jalr	-1140(ra) # 8000497a <readi>
    80004df6:	47c1                	li	a5,16
    80004df8:	06f51163          	bne	a0,a5,80004e5a <dirlink+0xa2>
    if(de.inum == 0)
    80004dfc:	fc045783          	lhu	a5,-64(s0)
    80004e00:	c791                	beqz	a5,80004e0c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004e02:	24c1                	addiw	s1,s1,16
    80004e04:	04c92783          	lw	a5,76(s2)
    80004e08:	fcf4ede3          	bltu	s1,a5,80004de2 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004e0c:	4639                	li	a2,14
    80004e0e:	85d2                	mv	a1,s4
    80004e10:	fc240513          	addi	a0,s0,-62
    80004e14:	ffffc097          	auipc	ra,0xffffc
    80004e18:	fe4080e7          	jalr	-28(ra) # 80000df8 <strncpy>
  de.inum = inum;
    80004e1c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e20:	4741                	li	a4,16
    80004e22:	86a6                	mv	a3,s1
    80004e24:	fc040613          	addi	a2,s0,-64
    80004e28:	4581                	li	a1,0
    80004e2a:	854a                	mv	a0,s2
    80004e2c:	00000097          	auipc	ra,0x0
    80004e30:	c46080e7          	jalr	-954(ra) # 80004a72 <writei>
    80004e34:	872a                	mv	a4,a0
    80004e36:	47c1                	li	a5,16
  return 0;
    80004e38:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e3a:	02f71863          	bne	a4,a5,80004e6a <dirlink+0xb2>
}
    80004e3e:	70e2                	ld	ra,56(sp)
    80004e40:	7442                	ld	s0,48(sp)
    80004e42:	74a2                	ld	s1,40(sp)
    80004e44:	7902                	ld	s2,32(sp)
    80004e46:	69e2                	ld	s3,24(sp)
    80004e48:	6a42                	ld	s4,16(sp)
    80004e4a:	6121                	addi	sp,sp,64
    80004e4c:	8082                	ret
    iput(ip);
    80004e4e:	00000097          	auipc	ra,0x0
    80004e52:	a32080e7          	jalr	-1486(ra) # 80004880 <iput>
    return -1;
    80004e56:	557d                	li	a0,-1
    80004e58:	b7dd                	j	80004e3e <dirlink+0x86>
      panic("dirlink read");
    80004e5a:	00005517          	auipc	a0,0x5
    80004e5e:	8f650513          	addi	a0,a0,-1802 # 80009750 <syscalls+0x200>
    80004e62:	ffffb097          	auipc	ra,0xffffb
    80004e66:	6cc080e7          	jalr	1740(ra) # 8000052e <panic>
    panic("dirlink");
    80004e6a:	00005517          	auipc	a0,0x5
    80004e6e:	9f650513          	addi	a0,a0,-1546 # 80009860 <syscalls+0x310>
    80004e72:	ffffb097          	auipc	ra,0xffffb
    80004e76:	6bc080e7          	jalr	1724(ra) # 8000052e <panic>

0000000080004e7a <namei>:

struct inode*
namei(char *path)
{
    80004e7a:	1101                	addi	sp,sp,-32
    80004e7c:	ec06                	sd	ra,24(sp)
    80004e7e:	e822                	sd	s0,16(sp)
    80004e80:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004e82:	fe040613          	addi	a2,s0,-32
    80004e86:	4581                	li	a1,0
    80004e88:	00000097          	auipc	ra,0x0
    80004e8c:	dd2080e7          	jalr	-558(ra) # 80004c5a <namex>
}
    80004e90:	60e2                	ld	ra,24(sp)
    80004e92:	6442                	ld	s0,16(sp)
    80004e94:	6105                	addi	sp,sp,32
    80004e96:	8082                	ret

0000000080004e98 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004e98:	1141                	addi	sp,sp,-16
    80004e9a:	e406                	sd	ra,8(sp)
    80004e9c:	e022                	sd	s0,0(sp)
    80004e9e:	0800                	addi	s0,sp,16
    80004ea0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004ea2:	4585                	li	a1,1
    80004ea4:	00000097          	auipc	ra,0x0
    80004ea8:	db6080e7          	jalr	-586(ra) # 80004c5a <namex>
}
    80004eac:	60a2                	ld	ra,8(sp)
    80004eae:	6402                	ld	s0,0(sp)
    80004eb0:	0141                	addi	sp,sp,16
    80004eb2:	8082                	ret

0000000080004eb4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004eb4:	1101                	addi	sp,sp,-32
    80004eb6:	ec06                	sd	ra,24(sp)
    80004eb8:	e822                	sd	s0,16(sp)
    80004eba:	e426                	sd	s1,8(sp)
    80004ebc:	e04a                	sd	s2,0(sp)
    80004ebe:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004ec0:	00039917          	auipc	s2,0x39
    80004ec4:	c0890913          	addi	s2,s2,-1016 # 8003dac8 <log>
    80004ec8:	01892583          	lw	a1,24(s2)
    80004ecc:	02892503          	lw	a0,40(s2)
    80004ed0:	fffff097          	auipc	ra,0xfffff
    80004ed4:	ff2080e7          	jalr	-14(ra) # 80003ec2 <bread>
    80004ed8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004eda:	02c92683          	lw	a3,44(s2)
    80004ede:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004ee0:	02d05863          	blez	a3,80004f10 <write_head+0x5c>
    80004ee4:	00039797          	auipc	a5,0x39
    80004ee8:	c1478793          	addi	a5,a5,-1004 # 8003daf8 <log+0x30>
    80004eec:	05c50713          	addi	a4,a0,92
    80004ef0:	36fd                	addiw	a3,a3,-1
    80004ef2:	02069613          	slli	a2,a3,0x20
    80004ef6:	01e65693          	srli	a3,a2,0x1e
    80004efa:	00039617          	auipc	a2,0x39
    80004efe:	c0260613          	addi	a2,a2,-1022 # 8003dafc <log+0x34>
    80004f02:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004f04:	4390                	lw	a2,0(a5)
    80004f06:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004f08:	0791                	addi	a5,a5,4
    80004f0a:	0711                	addi	a4,a4,4
    80004f0c:	fed79ce3          	bne	a5,a3,80004f04 <write_head+0x50>
  }
  bwrite(buf);
    80004f10:	8526                	mv	a0,s1
    80004f12:	fffff097          	auipc	ra,0xfffff
    80004f16:	0a2080e7          	jalr	162(ra) # 80003fb4 <bwrite>
  brelse(buf);
    80004f1a:	8526                	mv	a0,s1
    80004f1c:	fffff097          	auipc	ra,0xfffff
    80004f20:	0d6080e7          	jalr	214(ra) # 80003ff2 <brelse>
}
    80004f24:	60e2                	ld	ra,24(sp)
    80004f26:	6442                	ld	s0,16(sp)
    80004f28:	64a2                	ld	s1,8(sp)
    80004f2a:	6902                	ld	s2,0(sp)
    80004f2c:	6105                	addi	sp,sp,32
    80004f2e:	8082                	ret

0000000080004f30 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004f30:	00039797          	auipc	a5,0x39
    80004f34:	bc47a783          	lw	a5,-1084(a5) # 8003daf4 <log+0x2c>
    80004f38:	0af05d63          	blez	a5,80004ff2 <install_trans+0xc2>
{
    80004f3c:	7139                	addi	sp,sp,-64
    80004f3e:	fc06                	sd	ra,56(sp)
    80004f40:	f822                	sd	s0,48(sp)
    80004f42:	f426                	sd	s1,40(sp)
    80004f44:	f04a                	sd	s2,32(sp)
    80004f46:	ec4e                	sd	s3,24(sp)
    80004f48:	e852                	sd	s4,16(sp)
    80004f4a:	e456                	sd	s5,8(sp)
    80004f4c:	e05a                	sd	s6,0(sp)
    80004f4e:	0080                	addi	s0,sp,64
    80004f50:	8b2a                	mv	s6,a0
    80004f52:	00039a97          	auipc	s5,0x39
    80004f56:	ba6a8a93          	addi	s5,s5,-1114 # 8003daf8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004f5a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004f5c:	00039997          	auipc	s3,0x39
    80004f60:	b6c98993          	addi	s3,s3,-1172 # 8003dac8 <log>
    80004f64:	a00d                	j	80004f86 <install_trans+0x56>
    brelse(lbuf);
    80004f66:	854a                	mv	a0,s2
    80004f68:	fffff097          	auipc	ra,0xfffff
    80004f6c:	08a080e7          	jalr	138(ra) # 80003ff2 <brelse>
    brelse(dbuf);
    80004f70:	8526                	mv	a0,s1
    80004f72:	fffff097          	auipc	ra,0xfffff
    80004f76:	080080e7          	jalr	128(ra) # 80003ff2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004f7a:	2a05                	addiw	s4,s4,1
    80004f7c:	0a91                	addi	s5,s5,4
    80004f7e:	02c9a783          	lw	a5,44(s3)
    80004f82:	04fa5e63          	bge	s4,a5,80004fde <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004f86:	0189a583          	lw	a1,24(s3)
    80004f8a:	014585bb          	addw	a1,a1,s4
    80004f8e:	2585                	addiw	a1,a1,1
    80004f90:	0289a503          	lw	a0,40(s3)
    80004f94:	fffff097          	auipc	ra,0xfffff
    80004f98:	f2e080e7          	jalr	-210(ra) # 80003ec2 <bread>
    80004f9c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004f9e:	000aa583          	lw	a1,0(s5)
    80004fa2:	0289a503          	lw	a0,40(s3)
    80004fa6:	fffff097          	auipc	ra,0xfffff
    80004faa:	f1c080e7          	jalr	-228(ra) # 80003ec2 <bread>
    80004fae:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004fb0:	40000613          	li	a2,1024
    80004fb4:	05890593          	addi	a1,s2,88
    80004fb8:	05850513          	addi	a0,a0,88
    80004fbc:	ffffc097          	auipc	ra,0xffffc
    80004fc0:	d84080e7          	jalr	-636(ra) # 80000d40 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004fc4:	8526                	mv	a0,s1
    80004fc6:	fffff097          	auipc	ra,0xfffff
    80004fca:	fee080e7          	jalr	-18(ra) # 80003fb4 <bwrite>
    if(recovering == 0)
    80004fce:	f80b1ce3          	bnez	s6,80004f66 <install_trans+0x36>
      bunpin(dbuf);
    80004fd2:	8526                	mv	a0,s1
    80004fd4:	fffff097          	auipc	ra,0xfffff
    80004fd8:	0f8080e7          	jalr	248(ra) # 800040cc <bunpin>
    80004fdc:	b769                	j	80004f66 <install_trans+0x36>
}
    80004fde:	70e2                	ld	ra,56(sp)
    80004fe0:	7442                	ld	s0,48(sp)
    80004fe2:	74a2                	ld	s1,40(sp)
    80004fe4:	7902                	ld	s2,32(sp)
    80004fe6:	69e2                	ld	s3,24(sp)
    80004fe8:	6a42                	ld	s4,16(sp)
    80004fea:	6aa2                	ld	s5,8(sp)
    80004fec:	6b02                	ld	s6,0(sp)
    80004fee:	6121                	addi	sp,sp,64
    80004ff0:	8082                	ret
    80004ff2:	8082                	ret

0000000080004ff4 <initlog>:
{
    80004ff4:	7179                	addi	sp,sp,-48
    80004ff6:	f406                	sd	ra,40(sp)
    80004ff8:	f022                	sd	s0,32(sp)
    80004ffa:	ec26                	sd	s1,24(sp)
    80004ffc:	e84a                	sd	s2,16(sp)
    80004ffe:	e44e                	sd	s3,8(sp)
    80005000:	1800                	addi	s0,sp,48
    80005002:	892a                	mv	s2,a0
    80005004:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80005006:	00039497          	auipc	s1,0x39
    8000500a:	ac248493          	addi	s1,s1,-1342 # 8003dac8 <log>
    8000500e:	00004597          	auipc	a1,0x4
    80005012:	75258593          	addi	a1,a1,1874 # 80009760 <syscalls+0x210>
    80005016:	8526                	mv	a0,s1
    80005018:	ffffc097          	auipc	ra,0xffffc
    8000501c:	b1e080e7          	jalr	-1250(ra) # 80000b36 <initlock>
  log.start = sb->logstart;
    80005020:	0149a583          	lw	a1,20(s3)
    80005024:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80005026:	0109a783          	lw	a5,16(s3)
    8000502a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000502c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80005030:	854a                	mv	a0,s2
    80005032:	fffff097          	auipc	ra,0xfffff
    80005036:	e90080e7          	jalr	-368(ra) # 80003ec2 <bread>
  log.lh.n = lh->n;
    8000503a:	4d34                	lw	a3,88(a0)
    8000503c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000503e:	02d05663          	blez	a3,8000506a <initlog+0x76>
    80005042:	05c50793          	addi	a5,a0,92
    80005046:	00039717          	auipc	a4,0x39
    8000504a:	ab270713          	addi	a4,a4,-1358 # 8003daf8 <log+0x30>
    8000504e:	36fd                	addiw	a3,a3,-1
    80005050:	02069613          	slli	a2,a3,0x20
    80005054:	01e65693          	srli	a3,a2,0x1e
    80005058:	06050613          	addi	a2,a0,96
    8000505c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000505e:	4390                	lw	a2,0(a5)
    80005060:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005062:	0791                	addi	a5,a5,4
    80005064:	0711                	addi	a4,a4,4
    80005066:	fed79ce3          	bne	a5,a3,8000505e <initlog+0x6a>
  brelse(buf);
    8000506a:	fffff097          	auipc	ra,0xfffff
    8000506e:	f88080e7          	jalr	-120(ra) # 80003ff2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80005072:	4505                	li	a0,1
    80005074:	00000097          	auipc	ra,0x0
    80005078:	ebc080e7          	jalr	-324(ra) # 80004f30 <install_trans>
  log.lh.n = 0;
    8000507c:	00039797          	auipc	a5,0x39
    80005080:	a607ac23          	sw	zero,-1416(a5) # 8003daf4 <log+0x2c>
  write_head(); // clear the log
    80005084:	00000097          	auipc	ra,0x0
    80005088:	e30080e7          	jalr	-464(ra) # 80004eb4 <write_head>
}
    8000508c:	70a2                	ld	ra,40(sp)
    8000508e:	7402                	ld	s0,32(sp)
    80005090:	64e2                	ld	s1,24(sp)
    80005092:	6942                	ld	s2,16(sp)
    80005094:	69a2                	ld	s3,8(sp)
    80005096:	6145                	addi	sp,sp,48
    80005098:	8082                	ret

000000008000509a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000509a:	1101                	addi	sp,sp,-32
    8000509c:	ec06                	sd	ra,24(sp)
    8000509e:	e822                	sd	s0,16(sp)
    800050a0:	e426                	sd	s1,8(sp)
    800050a2:	e04a                	sd	s2,0(sp)
    800050a4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800050a6:	00039517          	auipc	a0,0x39
    800050aa:	a2250513          	addi	a0,a0,-1502 # 8003dac8 <log>
    800050ae:	ffffc097          	auipc	ra,0xffffc
    800050b2:	b18080e7          	jalr	-1256(ra) # 80000bc6 <acquire>
  while(1){
    if(log.committing){
    800050b6:	00039497          	auipc	s1,0x39
    800050ba:	a1248493          	addi	s1,s1,-1518 # 8003dac8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800050be:	4979                	li	s2,30
    800050c0:	a039                	j	800050ce <begin_op+0x34>
      sleep(&log, &log.lock);
    800050c2:	85a6                	mv	a1,s1
    800050c4:	8526                	mv	a0,s1
    800050c6:	ffffd097          	auipc	ra,0xffffd
    800050ca:	2fc080e7          	jalr	764(ra) # 800023c2 <sleep>
    if(log.committing){
    800050ce:	50dc                	lw	a5,36(s1)
    800050d0:	fbed                	bnez	a5,800050c2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800050d2:	509c                	lw	a5,32(s1)
    800050d4:	0017871b          	addiw	a4,a5,1
    800050d8:	0007069b          	sext.w	a3,a4
    800050dc:	0027179b          	slliw	a5,a4,0x2
    800050e0:	9fb9                	addw	a5,a5,a4
    800050e2:	0017979b          	slliw	a5,a5,0x1
    800050e6:	54d8                	lw	a4,44(s1)
    800050e8:	9fb9                	addw	a5,a5,a4
    800050ea:	00f95963          	bge	s2,a5,800050fc <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800050ee:	85a6                	mv	a1,s1
    800050f0:	8526                	mv	a0,s1
    800050f2:	ffffd097          	auipc	ra,0xffffd
    800050f6:	2d0080e7          	jalr	720(ra) # 800023c2 <sleep>
    800050fa:	bfd1                	j	800050ce <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800050fc:	00039517          	auipc	a0,0x39
    80005100:	9cc50513          	addi	a0,a0,-1588 # 8003dac8 <log>
    80005104:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80005106:	ffffc097          	auipc	ra,0xffffc
    8000510a:	b96080e7          	jalr	-1130(ra) # 80000c9c <release>
      break;
    }
  }
}
    8000510e:	60e2                	ld	ra,24(sp)
    80005110:	6442                	ld	s0,16(sp)
    80005112:	64a2                	ld	s1,8(sp)
    80005114:	6902                	ld	s2,0(sp)
    80005116:	6105                	addi	sp,sp,32
    80005118:	8082                	ret

000000008000511a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000511a:	7139                	addi	sp,sp,-64
    8000511c:	fc06                	sd	ra,56(sp)
    8000511e:	f822                	sd	s0,48(sp)
    80005120:	f426                	sd	s1,40(sp)
    80005122:	f04a                	sd	s2,32(sp)
    80005124:	ec4e                	sd	s3,24(sp)
    80005126:	e852                	sd	s4,16(sp)
    80005128:	e456                	sd	s5,8(sp)
    8000512a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000512c:	00039497          	auipc	s1,0x39
    80005130:	99c48493          	addi	s1,s1,-1636 # 8003dac8 <log>
    80005134:	8526                	mv	a0,s1
    80005136:	ffffc097          	auipc	ra,0xffffc
    8000513a:	a90080e7          	jalr	-1392(ra) # 80000bc6 <acquire>
  log.outstanding -= 1;
    8000513e:	509c                	lw	a5,32(s1)
    80005140:	37fd                	addiw	a5,a5,-1
    80005142:	0007891b          	sext.w	s2,a5
    80005146:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80005148:	50dc                	lw	a5,36(s1)
    8000514a:	e7b9                	bnez	a5,80005198 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000514c:	04091e63          	bnez	s2,800051a8 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80005150:	00039497          	auipc	s1,0x39
    80005154:	97848493          	addi	s1,s1,-1672 # 8003dac8 <log>
    80005158:	4785                	li	a5,1
    8000515a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000515c:	8526                	mv	a0,s1
    8000515e:	ffffc097          	auipc	ra,0xffffc
    80005162:	b3e080e7          	jalr	-1218(ra) # 80000c9c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80005166:	54dc                	lw	a5,44(s1)
    80005168:	06f04763          	bgtz	a5,800051d6 <end_op+0xbc>
    acquire(&log.lock);
    8000516c:	00039497          	auipc	s1,0x39
    80005170:	95c48493          	addi	s1,s1,-1700 # 8003dac8 <log>
    80005174:	8526                	mv	a0,s1
    80005176:	ffffc097          	auipc	ra,0xffffc
    8000517a:	a50080e7          	jalr	-1456(ra) # 80000bc6 <acquire>
    log.committing = 0;
    8000517e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80005182:	8526                	mv	a0,s1
    80005184:	ffffd097          	auipc	ra,0xffffd
    80005188:	3c8080e7          	jalr	968(ra) # 8000254c <wakeup>
    release(&log.lock);
    8000518c:	8526                	mv	a0,s1
    8000518e:	ffffc097          	auipc	ra,0xffffc
    80005192:	b0e080e7          	jalr	-1266(ra) # 80000c9c <release>
}
    80005196:	a03d                	j	800051c4 <end_op+0xaa>
    panic("log.committing");
    80005198:	00004517          	auipc	a0,0x4
    8000519c:	5d050513          	addi	a0,a0,1488 # 80009768 <syscalls+0x218>
    800051a0:	ffffb097          	auipc	ra,0xffffb
    800051a4:	38e080e7          	jalr	910(ra) # 8000052e <panic>
    wakeup(&log);
    800051a8:	00039497          	auipc	s1,0x39
    800051ac:	92048493          	addi	s1,s1,-1760 # 8003dac8 <log>
    800051b0:	8526                	mv	a0,s1
    800051b2:	ffffd097          	auipc	ra,0xffffd
    800051b6:	39a080e7          	jalr	922(ra) # 8000254c <wakeup>
  release(&log.lock);
    800051ba:	8526                	mv	a0,s1
    800051bc:	ffffc097          	auipc	ra,0xffffc
    800051c0:	ae0080e7          	jalr	-1312(ra) # 80000c9c <release>
}
    800051c4:	70e2                	ld	ra,56(sp)
    800051c6:	7442                	ld	s0,48(sp)
    800051c8:	74a2                	ld	s1,40(sp)
    800051ca:	7902                	ld	s2,32(sp)
    800051cc:	69e2                	ld	s3,24(sp)
    800051ce:	6a42                	ld	s4,16(sp)
    800051d0:	6aa2                	ld	s5,8(sp)
    800051d2:	6121                	addi	sp,sp,64
    800051d4:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800051d6:	00039a97          	auipc	s5,0x39
    800051da:	922a8a93          	addi	s5,s5,-1758 # 8003daf8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800051de:	00039a17          	auipc	s4,0x39
    800051e2:	8eaa0a13          	addi	s4,s4,-1814 # 8003dac8 <log>
    800051e6:	018a2583          	lw	a1,24(s4)
    800051ea:	012585bb          	addw	a1,a1,s2
    800051ee:	2585                	addiw	a1,a1,1
    800051f0:	028a2503          	lw	a0,40(s4)
    800051f4:	fffff097          	auipc	ra,0xfffff
    800051f8:	cce080e7          	jalr	-818(ra) # 80003ec2 <bread>
    800051fc:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800051fe:	000aa583          	lw	a1,0(s5)
    80005202:	028a2503          	lw	a0,40(s4)
    80005206:	fffff097          	auipc	ra,0xfffff
    8000520a:	cbc080e7          	jalr	-836(ra) # 80003ec2 <bread>
    8000520e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80005210:	40000613          	li	a2,1024
    80005214:	05850593          	addi	a1,a0,88
    80005218:	05848513          	addi	a0,s1,88
    8000521c:	ffffc097          	auipc	ra,0xffffc
    80005220:	b24080e7          	jalr	-1244(ra) # 80000d40 <memmove>
    bwrite(to);  // write the log
    80005224:	8526                	mv	a0,s1
    80005226:	fffff097          	auipc	ra,0xfffff
    8000522a:	d8e080e7          	jalr	-626(ra) # 80003fb4 <bwrite>
    brelse(from);
    8000522e:	854e                	mv	a0,s3
    80005230:	fffff097          	auipc	ra,0xfffff
    80005234:	dc2080e7          	jalr	-574(ra) # 80003ff2 <brelse>
    brelse(to);
    80005238:	8526                	mv	a0,s1
    8000523a:	fffff097          	auipc	ra,0xfffff
    8000523e:	db8080e7          	jalr	-584(ra) # 80003ff2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005242:	2905                	addiw	s2,s2,1
    80005244:	0a91                	addi	s5,s5,4
    80005246:	02ca2783          	lw	a5,44(s4)
    8000524a:	f8f94ee3          	blt	s2,a5,800051e6 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000524e:	00000097          	auipc	ra,0x0
    80005252:	c66080e7          	jalr	-922(ra) # 80004eb4 <write_head>
    install_trans(0); // Now install writes to home locations
    80005256:	4501                	li	a0,0
    80005258:	00000097          	auipc	ra,0x0
    8000525c:	cd8080e7          	jalr	-808(ra) # 80004f30 <install_trans>
    log.lh.n = 0;
    80005260:	00039797          	auipc	a5,0x39
    80005264:	8807aa23          	sw	zero,-1900(a5) # 8003daf4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80005268:	00000097          	auipc	ra,0x0
    8000526c:	c4c080e7          	jalr	-948(ra) # 80004eb4 <write_head>
    80005270:	bdf5                	j	8000516c <end_op+0x52>

0000000080005272 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80005272:	1101                	addi	sp,sp,-32
    80005274:	ec06                	sd	ra,24(sp)
    80005276:	e822                	sd	s0,16(sp)
    80005278:	e426                	sd	s1,8(sp)
    8000527a:	e04a                	sd	s2,0(sp)
    8000527c:	1000                	addi	s0,sp,32
    8000527e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80005280:	00039917          	auipc	s2,0x39
    80005284:	84890913          	addi	s2,s2,-1976 # 8003dac8 <log>
    80005288:	854a                	mv	a0,s2
    8000528a:	ffffc097          	auipc	ra,0xffffc
    8000528e:	93c080e7          	jalr	-1732(ra) # 80000bc6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80005292:	02c92603          	lw	a2,44(s2)
    80005296:	47f5                	li	a5,29
    80005298:	06c7c563          	blt	a5,a2,80005302 <log_write+0x90>
    8000529c:	00039797          	auipc	a5,0x39
    800052a0:	8487a783          	lw	a5,-1976(a5) # 8003dae4 <log+0x1c>
    800052a4:	37fd                	addiw	a5,a5,-1
    800052a6:	04f65e63          	bge	a2,a5,80005302 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800052aa:	00039797          	auipc	a5,0x39
    800052ae:	83e7a783          	lw	a5,-1986(a5) # 8003dae8 <log+0x20>
    800052b2:	06f05063          	blez	a5,80005312 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800052b6:	4781                	li	a5,0
    800052b8:	06c05563          	blez	a2,80005322 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800052bc:	44cc                	lw	a1,12(s1)
    800052be:	00039717          	auipc	a4,0x39
    800052c2:	83a70713          	addi	a4,a4,-1990 # 8003daf8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800052c6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800052c8:	4314                	lw	a3,0(a4)
    800052ca:	04b68c63          	beq	a3,a1,80005322 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800052ce:	2785                	addiw	a5,a5,1
    800052d0:	0711                	addi	a4,a4,4
    800052d2:	fef61be3          	bne	a2,a5,800052c8 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800052d6:	0621                	addi	a2,a2,8
    800052d8:	060a                	slli	a2,a2,0x2
    800052da:	00038797          	auipc	a5,0x38
    800052de:	7ee78793          	addi	a5,a5,2030 # 8003dac8 <log>
    800052e2:	963e                	add	a2,a2,a5
    800052e4:	44dc                	lw	a5,12(s1)
    800052e6:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800052e8:	8526                	mv	a0,s1
    800052ea:	fffff097          	auipc	ra,0xfffff
    800052ee:	da6080e7          	jalr	-602(ra) # 80004090 <bpin>
    log.lh.n++;
    800052f2:	00038717          	auipc	a4,0x38
    800052f6:	7d670713          	addi	a4,a4,2006 # 8003dac8 <log>
    800052fa:	575c                	lw	a5,44(a4)
    800052fc:	2785                	addiw	a5,a5,1
    800052fe:	d75c                	sw	a5,44(a4)
    80005300:	a835                	j	8000533c <log_write+0xca>
    panic("too big a transaction");
    80005302:	00004517          	auipc	a0,0x4
    80005306:	47650513          	addi	a0,a0,1142 # 80009778 <syscalls+0x228>
    8000530a:	ffffb097          	auipc	ra,0xffffb
    8000530e:	224080e7          	jalr	548(ra) # 8000052e <panic>
    panic("log_write outside of trans");
    80005312:	00004517          	auipc	a0,0x4
    80005316:	47e50513          	addi	a0,a0,1150 # 80009790 <syscalls+0x240>
    8000531a:	ffffb097          	auipc	ra,0xffffb
    8000531e:	214080e7          	jalr	532(ra) # 8000052e <panic>
  log.lh.block[i] = b->blockno;
    80005322:	00878713          	addi	a4,a5,8
    80005326:	00271693          	slli	a3,a4,0x2
    8000532a:	00038717          	auipc	a4,0x38
    8000532e:	79e70713          	addi	a4,a4,1950 # 8003dac8 <log>
    80005332:	9736                	add	a4,a4,a3
    80005334:	44d4                	lw	a3,12(s1)
    80005336:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80005338:	faf608e3          	beq	a2,a5,800052e8 <log_write+0x76>
  }
  release(&log.lock);
    8000533c:	00038517          	auipc	a0,0x38
    80005340:	78c50513          	addi	a0,a0,1932 # 8003dac8 <log>
    80005344:	ffffc097          	auipc	ra,0xffffc
    80005348:	958080e7          	jalr	-1704(ra) # 80000c9c <release>
}
    8000534c:	60e2                	ld	ra,24(sp)
    8000534e:	6442                	ld	s0,16(sp)
    80005350:	64a2                	ld	s1,8(sp)
    80005352:	6902                	ld	s2,0(sp)
    80005354:	6105                	addi	sp,sp,32
    80005356:	8082                	ret

0000000080005358 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80005358:	1101                	addi	sp,sp,-32
    8000535a:	ec06                	sd	ra,24(sp)
    8000535c:	e822                	sd	s0,16(sp)
    8000535e:	e426                	sd	s1,8(sp)
    80005360:	e04a                	sd	s2,0(sp)
    80005362:	1000                	addi	s0,sp,32
    80005364:	84aa                	mv	s1,a0
    80005366:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80005368:	00004597          	auipc	a1,0x4
    8000536c:	44858593          	addi	a1,a1,1096 # 800097b0 <syscalls+0x260>
    80005370:	0521                	addi	a0,a0,8
    80005372:	ffffb097          	auipc	ra,0xffffb
    80005376:	7c4080e7          	jalr	1988(ra) # 80000b36 <initlock>
  lk->name = name;
    8000537a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000537e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005382:	0204a423          	sw	zero,40(s1)
}
    80005386:	60e2                	ld	ra,24(sp)
    80005388:	6442                	ld	s0,16(sp)
    8000538a:	64a2                	ld	s1,8(sp)
    8000538c:	6902                	ld	s2,0(sp)
    8000538e:	6105                	addi	sp,sp,32
    80005390:	8082                	ret

0000000080005392 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80005392:	1101                	addi	sp,sp,-32
    80005394:	ec06                	sd	ra,24(sp)
    80005396:	e822                	sd	s0,16(sp)
    80005398:	e426                	sd	s1,8(sp)
    8000539a:	e04a                	sd	s2,0(sp)
    8000539c:	1000                	addi	s0,sp,32
    8000539e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800053a0:	00850913          	addi	s2,a0,8
    800053a4:	854a                	mv	a0,s2
    800053a6:	ffffc097          	auipc	ra,0xffffc
    800053aa:	820080e7          	jalr	-2016(ra) # 80000bc6 <acquire>
  while (lk->locked) {
    800053ae:	409c                	lw	a5,0(s1)
    800053b0:	cb89                	beqz	a5,800053c2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800053b2:	85ca                	mv	a1,s2
    800053b4:	8526                	mv	a0,s1
    800053b6:	ffffd097          	auipc	ra,0xffffd
    800053ba:	00c080e7          	jalr	12(ra) # 800023c2 <sleep>
  while (lk->locked) {
    800053be:	409c                	lw	a5,0(s1)
    800053c0:	fbed                	bnez	a5,800053b2 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800053c2:	4785                	li	a5,1
    800053c4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800053c6:	ffffc097          	auipc	ra,0xffffc
    800053ca:	6b6080e7          	jalr	1718(ra) # 80001a7c <myproc>
    800053ce:	515c                	lw	a5,36(a0)
    800053d0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800053d2:	854a                	mv	a0,s2
    800053d4:	ffffc097          	auipc	ra,0xffffc
    800053d8:	8c8080e7          	jalr	-1848(ra) # 80000c9c <release>
}
    800053dc:	60e2                	ld	ra,24(sp)
    800053de:	6442                	ld	s0,16(sp)
    800053e0:	64a2                	ld	s1,8(sp)
    800053e2:	6902                	ld	s2,0(sp)
    800053e4:	6105                	addi	sp,sp,32
    800053e6:	8082                	ret

00000000800053e8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800053e8:	1101                	addi	sp,sp,-32
    800053ea:	ec06                	sd	ra,24(sp)
    800053ec:	e822                	sd	s0,16(sp)
    800053ee:	e426                	sd	s1,8(sp)
    800053f0:	e04a                	sd	s2,0(sp)
    800053f2:	1000                	addi	s0,sp,32
    800053f4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800053f6:	00850913          	addi	s2,a0,8
    800053fa:	854a                	mv	a0,s2
    800053fc:	ffffb097          	auipc	ra,0xffffb
    80005400:	7ca080e7          	jalr	1994(ra) # 80000bc6 <acquire>
  lk->locked = 0;
    80005404:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005408:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000540c:	8526                	mv	a0,s1
    8000540e:	ffffd097          	auipc	ra,0xffffd
    80005412:	13e080e7          	jalr	318(ra) # 8000254c <wakeup>
  release(&lk->lk);
    80005416:	854a                	mv	a0,s2
    80005418:	ffffc097          	auipc	ra,0xffffc
    8000541c:	884080e7          	jalr	-1916(ra) # 80000c9c <release>
}
    80005420:	60e2                	ld	ra,24(sp)
    80005422:	6442                	ld	s0,16(sp)
    80005424:	64a2                	ld	s1,8(sp)
    80005426:	6902                	ld	s2,0(sp)
    80005428:	6105                	addi	sp,sp,32
    8000542a:	8082                	ret

000000008000542c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000542c:	7179                	addi	sp,sp,-48
    8000542e:	f406                	sd	ra,40(sp)
    80005430:	f022                	sd	s0,32(sp)
    80005432:	ec26                	sd	s1,24(sp)
    80005434:	e84a                	sd	s2,16(sp)
    80005436:	e44e                	sd	s3,8(sp)
    80005438:	1800                	addi	s0,sp,48
    8000543a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000543c:	00850913          	addi	s2,a0,8
    80005440:	854a                	mv	a0,s2
    80005442:	ffffb097          	auipc	ra,0xffffb
    80005446:	784080e7          	jalr	1924(ra) # 80000bc6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000544a:	409c                	lw	a5,0(s1)
    8000544c:	ef99                	bnez	a5,8000546a <holdingsleep+0x3e>
    8000544e:	4481                	li	s1,0
  release(&lk->lk);
    80005450:	854a                	mv	a0,s2
    80005452:	ffffc097          	auipc	ra,0xffffc
    80005456:	84a080e7          	jalr	-1974(ra) # 80000c9c <release>
  return r;
}
    8000545a:	8526                	mv	a0,s1
    8000545c:	70a2                	ld	ra,40(sp)
    8000545e:	7402                	ld	s0,32(sp)
    80005460:	64e2                	ld	s1,24(sp)
    80005462:	6942                	ld	s2,16(sp)
    80005464:	69a2                	ld	s3,8(sp)
    80005466:	6145                	addi	sp,sp,48
    80005468:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000546a:	0284a983          	lw	s3,40(s1)
    8000546e:	ffffc097          	auipc	ra,0xffffc
    80005472:	60e080e7          	jalr	1550(ra) # 80001a7c <myproc>
    80005476:	5144                	lw	s1,36(a0)
    80005478:	413484b3          	sub	s1,s1,s3
    8000547c:	0014b493          	seqz	s1,s1
    80005480:	bfc1                	j	80005450 <holdingsleep+0x24>

0000000080005482 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80005482:	1141                	addi	sp,sp,-16
    80005484:	e406                	sd	ra,8(sp)
    80005486:	e022                	sd	s0,0(sp)
    80005488:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000548a:	00004597          	auipc	a1,0x4
    8000548e:	33658593          	addi	a1,a1,822 # 800097c0 <syscalls+0x270>
    80005492:	00038517          	auipc	a0,0x38
    80005496:	77e50513          	addi	a0,a0,1918 # 8003dc10 <ftable>
    8000549a:	ffffb097          	auipc	ra,0xffffb
    8000549e:	69c080e7          	jalr	1692(ra) # 80000b36 <initlock>
}
    800054a2:	60a2                	ld	ra,8(sp)
    800054a4:	6402                	ld	s0,0(sp)
    800054a6:	0141                	addi	sp,sp,16
    800054a8:	8082                	ret

00000000800054aa <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800054aa:	1101                	addi	sp,sp,-32
    800054ac:	ec06                	sd	ra,24(sp)
    800054ae:	e822                	sd	s0,16(sp)
    800054b0:	e426                	sd	s1,8(sp)
    800054b2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800054b4:	00038517          	auipc	a0,0x38
    800054b8:	75c50513          	addi	a0,a0,1884 # 8003dc10 <ftable>
    800054bc:	ffffb097          	auipc	ra,0xffffb
    800054c0:	70a080e7          	jalr	1802(ra) # 80000bc6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800054c4:	00038497          	auipc	s1,0x38
    800054c8:	76448493          	addi	s1,s1,1892 # 8003dc28 <ftable+0x18>
    800054cc:	00039717          	auipc	a4,0x39
    800054d0:	6fc70713          	addi	a4,a4,1788 # 8003ebc8 <ftable+0xfb8>
    if(f->ref == 0){
    800054d4:	40dc                	lw	a5,4(s1)
    800054d6:	cf99                	beqz	a5,800054f4 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800054d8:	02848493          	addi	s1,s1,40
    800054dc:	fee49ce3          	bne	s1,a4,800054d4 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800054e0:	00038517          	auipc	a0,0x38
    800054e4:	73050513          	addi	a0,a0,1840 # 8003dc10 <ftable>
    800054e8:	ffffb097          	auipc	ra,0xffffb
    800054ec:	7b4080e7          	jalr	1972(ra) # 80000c9c <release>
  return 0;
    800054f0:	4481                	li	s1,0
    800054f2:	a819                	j	80005508 <filealloc+0x5e>
      f->ref = 1;
    800054f4:	4785                	li	a5,1
    800054f6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800054f8:	00038517          	auipc	a0,0x38
    800054fc:	71850513          	addi	a0,a0,1816 # 8003dc10 <ftable>
    80005500:	ffffb097          	auipc	ra,0xffffb
    80005504:	79c080e7          	jalr	1948(ra) # 80000c9c <release>
}
    80005508:	8526                	mv	a0,s1
    8000550a:	60e2                	ld	ra,24(sp)
    8000550c:	6442                	ld	s0,16(sp)
    8000550e:	64a2                	ld	s1,8(sp)
    80005510:	6105                	addi	sp,sp,32
    80005512:	8082                	ret

0000000080005514 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005514:	1101                	addi	sp,sp,-32
    80005516:	ec06                	sd	ra,24(sp)
    80005518:	e822                	sd	s0,16(sp)
    8000551a:	e426                	sd	s1,8(sp)
    8000551c:	1000                	addi	s0,sp,32
    8000551e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005520:	00038517          	auipc	a0,0x38
    80005524:	6f050513          	addi	a0,a0,1776 # 8003dc10 <ftable>
    80005528:	ffffb097          	auipc	ra,0xffffb
    8000552c:	69e080e7          	jalr	1694(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    80005530:	40dc                	lw	a5,4(s1)
    80005532:	02f05263          	blez	a5,80005556 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80005536:	2785                	addiw	a5,a5,1
    80005538:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000553a:	00038517          	auipc	a0,0x38
    8000553e:	6d650513          	addi	a0,a0,1750 # 8003dc10 <ftable>
    80005542:	ffffb097          	auipc	ra,0xffffb
    80005546:	75a080e7          	jalr	1882(ra) # 80000c9c <release>
  return f;
}
    8000554a:	8526                	mv	a0,s1
    8000554c:	60e2                	ld	ra,24(sp)
    8000554e:	6442                	ld	s0,16(sp)
    80005550:	64a2                	ld	s1,8(sp)
    80005552:	6105                	addi	sp,sp,32
    80005554:	8082                	ret
    panic("filedup");
    80005556:	00004517          	auipc	a0,0x4
    8000555a:	27250513          	addi	a0,a0,626 # 800097c8 <syscalls+0x278>
    8000555e:	ffffb097          	auipc	ra,0xffffb
    80005562:	fd0080e7          	jalr	-48(ra) # 8000052e <panic>

0000000080005566 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80005566:	7139                	addi	sp,sp,-64
    80005568:	fc06                	sd	ra,56(sp)
    8000556a:	f822                	sd	s0,48(sp)
    8000556c:	f426                	sd	s1,40(sp)
    8000556e:	f04a                	sd	s2,32(sp)
    80005570:	ec4e                	sd	s3,24(sp)
    80005572:	e852                	sd	s4,16(sp)
    80005574:	e456                	sd	s5,8(sp)
    80005576:	0080                	addi	s0,sp,64
    80005578:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000557a:	00038517          	auipc	a0,0x38
    8000557e:	69650513          	addi	a0,a0,1686 # 8003dc10 <ftable>
    80005582:	ffffb097          	auipc	ra,0xffffb
    80005586:	644080e7          	jalr	1604(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    8000558a:	40dc                	lw	a5,4(s1)
    8000558c:	06f05163          	blez	a5,800055ee <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80005590:	37fd                	addiw	a5,a5,-1
    80005592:	0007871b          	sext.w	a4,a5
    80005596:	c0dc                	sw	a5,4(s1)
    80005598:	06e04363          	bgtz	a4,800055fe <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000559c:	0004a903          	lw	s2,0(s1)
    800055a0:	0094ca83          	lbu	s5,9(s1)
    800055a4:	0104ba03          	ld	s4,16(s1)
    800055a8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800055ac:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800055b0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800055b4:	00038517          	auipc	a0,0x38
    800055b8:	65c50513          	addi	a0,a0,1628 # 8003dc10 <ftable>
    800055bc:	ffffb097          	auipc	ra,0xffffb
    800055c0:	6e0080e7          	jalr	1760(ra) # 80000c9c <release>

  if(ff.type == FD_PIPE){
    800055c4:	4785                	li	a5,1
    800055c6:	04f90d63          	beq	s2,a5,80005620 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800055ca:	3979                	addiw	s2,s2,-2
    800055cc:	4785                	li	a5,1
    800055ce:	0527e063          	bltu	a5,s2,8000560e <fileclose+0xa8>
    begin_op();
    800055d2:	00000097          	auipc	ra,0x0
    800055d6:	ac8080e7          	jalr	-1336(ra) # 8000509a <begin_op>
    iput(ff.ip);
    800055da:	854e                	mv	a0,s3
    800055dc:	fffff097          	auipc	ra,0xfffff
    800055e0:	2a4080e7          	jalr	676(ra) # 80004880 <iput>
    end_op();
    800055e4:	00000097          	auipc	ra,0x0
    800055e8:	b36080e7          	jalr	-1226(ra) # 8000511a <end_op>
    800055ec:	a00d                	j	8000560e <fileclose+0xa8>
    panic("fileclose");
    800055ee:	00004517          	auipc	a0,0x4
    800055f2:	1e250513          	addi	a0,a0,482 # 800097d0 <syscalls+0x280>
    800055f6:	ffffb097          	auipc	ra,0xffffb
    800055fa:	f38080e7          	jalr	-200(ra) # 8000052e <panic>
    release(&ftable.lock);
    800055fe:	00038517          	auipc	a0,0x38
    80005602:	61250513          	addi	a0,a0,1554 # 8003dc10 <ftable>
    80005606:	ffffb097          	auipc	ra,0xffffb
    8000560a:	696080e7          	jalr	1686(ra) # 80000c9c <release>
  }
}
    8000560e:	70e2                	ld	ra,56(sp)
    80005610:	7442                	ld	s0,48(sp)
    80005612:	74a2                	ld	s1,40(sp)
    80005614:	7902                	ld	s2,32(sp)
    80005616:	69e2                	ld	s3,24(sp)
    80005618:	6a42                	ld	s4,16(sp)
    8000561a:	6aa2                	ld	s5,8(sp)
    8000561c:	6121                	addi	sp,sp,64
    8000561e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005620:	85d6                	mv	a1,s5
    80005622:	8552                	mv	a0,s4
    80005624:	00000097          	auipc	ra,0x0
    80005628:	34c080e7          	jalr	844(ra) # 80005970 <pipeclose>
    8000562c:	b7cd                	j	8000560e <fileclose+0xa8>

000000008000562e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000562e:	715d                	addi	sp,sp,-80
    80005630:	e486                	sd	ra,72(sp)
    80005632:	e0a2                	sd	s0,64(sp)
    80005634:	fc26                	sd	s1,56(sp)
    80005636:	f84a                	sd	s2,48(sp)
    80005638:	f44e                	sd	s3,40(sp)
    8000563a:	0880                	addi	s0,sp,80
    8000563c:	84aa                	mv	s1,a0
    8000563e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005640:	ffffc097          	auipc	ra,0xffffc
    80005644:	43c080e7          	jalr	1084(ra) # 80001a7c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005648:	409c                	lw	a5,0(s1)
    8000564a:	37f9                	addiw	a5,a5,-2
    8000564c:	4705                	li	a4,1
    8000564e:	04f76763          	bltu	a4,a5,8000569c <filestat+0x6e>
    80005652:	892a                	mv	s2,a0
    ilock(f->ip);
    80005654:	6c88                	ld	a0,24(s1)
    80005656:	fffff097          	auipc	ra,0xfffff
    8000565a:	070080e7          	jalr	112(ra) # 800046c6 <ilock>
    stati(f->ip, &st);
    8000565e:	fb840593          	addi	a1,s0,-72
    80005662:	6c88                	ld	a0,24(s1)
    80005664:	fffff097          	auipc	ra,0xfffff
    80005668:	2ec080e7          	jalr	748(ra) # 80004950 <stati>
    iunlock(f->ip);
    8000566c:	6c88                	ld	a0,24(s1)
    8000566e:	fffff097          	auipc	ra,0xfffff
    80005672:	11a080e7          	jalr	282(ra) # 80004788 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005676:	46e1                	li	a3,24
    80005678:	fb840613          	addi	a2,s0,-72
    8000567c:	85ce                	mv	a1,s3
    8000567e:	04093503          	ld	a0,64(s2)
    80005682:	ffffc097          	auipc	ra,0xffffc
    80005686:	fe2080e7          	jalr	-30(ra) # 80001664 <copyout>
    8000568a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000568e:	60a6                	ld	ra,72(sp)
    80005690:	6406                	ld	s0,64(sp)
    80005692:	74e2                	ld	s1,56(sp)
    80005694:	7942                	ld	s2,48(sp)
    80005696:	79a2                	ld	s3,40(sp)
    80005698:	6161                	addi	sp,sp,80
    8000569a:	8082                	ret
  return -1;
    8000569c:	557d                	li	a0,-1
    8000569e:	bfc5                	j	8000568e <filestat+0x60>

00000000800056a0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800056a0:	7179                	addi	sp,sp,-48
    800056a2:	f406                	sd	ra,40(sp)
    800056a4:	f022                	sd	s0,32(sp)
    800056a6:	ec26                	sd	s1,24(sp)
    800056a8:	e84a                	sd	s2,16(sp)
    800056aa:	e44e                	sd	s3,8(sp)
    800056ac:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800056ae:	00854783          	lbu	a5,8(a0)
    800056b2:	c3d5                	beqz	a5,80005756 <fileread+0xb6>
    800056b4:	84aa                	mv	s1,a0
    800056b6:	89ae                	mv	s3,a1
    800056b8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800056ba:	411c                	lw	a5,0(a0)
    800056bc:	4705                	li	a4,1
    800056be:	04e78963          	beq	a5,a4,80005710 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800056c2:	470d                	li	a4,3
    800056c4:	04e78d63          	beq	a5,a4,8000571e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800056c8:	4709                	li	a4,2
    800056ca:	06e79e63          	bne	a5,a4,80005746 <fileread+0xa6>
    ilock(f->ip);
    800056ce:	6d08                	ld	a0,24(a0)
    800056d0:	fffff097          	auipc	ra,0xfffff
    800056d4:	ff6080e7          	jalr	-10(ra) # 800046c6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800056d8:	874a                	mv	a4,s2
    800056da:	5094                	lw	a3,32(s1)
    800056dc:	864e                	mv	a2,s3
    800056de:	4585                	li	a1,1
    800056e0:	6c88                	ld	a0,24(s1)
    800056e2:	fffff097          	auipc	ra,0xfffff
    800056e6:	298080e7          	jalr	664(ra) # 8000497a <readi>
    800056ea:	892a                	mv	s2,a0
    800056ec:	00a05563          	blez	a0,800056f6 <fileread+0x56>
      f->off += r;
    800056f0:	509c                	lw	a5,32(s1)
    800056f2:	9fa9                	addw	a5,a5,a0
    800056f4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800056f6:	6c88                	ld	a0,24(s1)
    800056f8:	fffff097          	auipc	ra,0xfffff
    800056fc:	090080e7          	jalr	144(ra) # 80004788 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005700:	854a                	mv	a0,s2
    80005702:	70a2                	ld	ra,40(sp)
    80005704:	7402                	ld	s0,32(sp)
    80005706:	64e2                	ld	s1,24(sp)
    80005708:	6942                	ld	s2,16(sp)
    8000570a:	69a2                	ld	s3,8(sp)
    8000570c:	6145                	addi	sp,sp,48
    8000570e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005710:	6908                	ld	a0,16(a0)
    80005712:	00000097          	auipc	ra,0x0
    80005716:	3c8080e7          	jalr	968(ra) # 80005ada <piperead>
    8000571a:	892a                	mv	s2,a0
    8000571c:	b7d5                	j	80005700 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000571e:	02451783          	lh	a5,36(a0)
    80005722:	03079693          	slli	a3,a5,0x30
    80005726:	92c1                	srli	a3,a3,0x30
    80005728:	4725                	li	a4,9
    8000572a:	02d76863          	bltu	a4,a3,8000575a <fileread+0xba>
    8000572e:	0792                	slli	a5,a5,0x4
    80005730:	00038717          	auipc	a4,0x38
    80005734:	44070713          	addi	a4,a4,1088 # 8003db70 <devsw>
    80005738:	97ba                	add	a5,a5,a4
    8000573a:	639c                	ld	a5,0(a5)
    8000573c:	c38d                	beqz	a5,8000575e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000573e:	4505                	li	a0,1
    80005740:	9782                	jalr	a5
    80005742:	892a                	mv	s2,a0
    80005744:	bf75                	j	80005700 <fileread+0x60>
    panic("fileread");
    80005746:	00004517          	auipc	a0,0x4
    8000574a:	09a50513          	addi	a0,a0,154 # 800097e0 <syscalls+0x290>
    8000574e:	ffffb097          	auipc	ra,0xffffb
    80005752:	de0080e7          	jalr	-544(ra) # 8000052e <panic>
    return -1;
    80005756:	597d                	li	s2,-1
    80005758:	b765                	j	80005700 <fileread+0x60>
      return -1;
    8000575a:	597d                	li	s2,-1
    8000575c:	b755                	j	80005700 <fileread+0x60>
    8000575e:	597d                	li	s2,-1
    80005760:	b745                	j	80005700 <fileread+0x60>

0000000080005762 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80005762:	715d                	addi	sp,sp,-80
    80005764:	e486                	sd	ra,72(sp)
    80005766:	e0a2                	sd	s0,64(sp)
    80005768:	fc26                	sd	s1,56(sp)
    8000576a:	f84a                	sd	s2,48(sp)
    8000576c:	f44e                	sd	s3,40(sp)
    8000576e:	f052                	sd	s4,32(sp)
    80005770:	ec56                	sd	s5,24(sp)
    80005772:	e85a                	sd	s6,16(sp)
    80005774:	e45e                	sd	s7,8(sp)
    80005776:	e062                	sd	s8,0(sp)
    80005778:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000577a:	00954783          	lbu	a5,9(a0)
    8000577e:	10078663          	beqz	a5,8000588a <filewrite+0x128>
    80005782:	892a                	mv	s2,a0
    80005784:	8aae                	mv	s5,a1
    80005786:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005788:	411c                	lw	a5,0(a0)
    8000578a:	4705                	li	a4,1
    8000578c:	02e78263          	beq	a5,a4,800057b0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005790:	470d                	li	a4,3
    80005792:	02e78663          	beq	a5,a4,800057be <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005796:	4709                	li	a4,2
    80005798:	0ee79163          	bne	a5,a4,8000587a <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000579c:	0ac05d63          	blez	a2,80005856 <filewrite+0xf4>
    int i = 0;
    800057a0:	4981                	li	s3,0
    800057a2:	6b05                	lui	s6,0x1
    800057a4:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800057a8:	6b85                	lui	s7,0x1
    800057aa:	c00b8b9b          	addiw	s7,s7,-1024
    800057ae:	a861                	j	80005846 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800057b0:	6908                	ld	a0,16(a0)
    800057b2:	00000097          	auipc	ra,0x0
    800057b6:	22e080e7          	jalr	558(ra) # 800059e0 <pipewrite>
    800057ba:	8a2a                	mv	s4,a0
    800057bc:	a045                	j	8000585c <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800057be:	02451783          	lh	a5,36(a0)
    800057c2:	03079693          	slli	a3,a5,0x30
    800057c6:	92c1                	srli	a3,a3,0x30
    800057c8:	4725                	li	a4,9
    800057ca:	0cd76263          	bltu	a4,a3,8000588e <filewrite+0x12c>
    800057ce:	0792                	slli	a5,a5,0x4
    800057d0:	00038717          	auipc	a4,0x38
    800057d4:	3a070713          	addi	a4,a4,928 # 8003db70 <devsw>
    800057d8:	97ba                	add	a5,a5,a4
    800057da:	679c                	ld	a5,8(a5)
    800057dc:	cbdd                	beqz	a5,80005892 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800057de:	4505                	li	a0,1
    800057e0:	9782                	jalr	a5
    800057e2:	8a2a                	mv	s4,a0
    800057e4:	a8a5                	j	8000585c <filewrite+0xfa>
    800057e6:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800057ea:	00000097          	auipc	ra,0x0
    800057ee:	8b0080e7          	jalr	-1872(ra) # 8000509a <begin_op>
      ilock(f->ip);
    800057f2:	01893503          	ld	a0,24(s2)
    800057f6:	fffff097          	auipc	ra,0xfffff
    800057fa:	ed0080e7          	jalr	-304(ra) # 800046c6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800057fe:	8762                	mv	a4,s8
    80005800:	02092683          	lw	a3,32(s2)
    80005804:	01598633          	add	a2,s3,s5
    80005808:	4585                	li	a1,1
    8000580a:	01893503          	ld	a0,24(s2)
    8000580e:	fffff097          	auipc	ra,0xfffff
    80005812:	264080e7          	jalr	612(ra) # 80004a72 <writei>
    80005816:	84aa                	mv	s1,a0
    80005818:	00a05763          	blez	a0,80005826 <filewrite+0xc4>
        f->off += r;
    8000581c:	02092783          	lw	a5,32(s2)
    80005820:	9fa9                	addw	a5,a5,a0
    80005822:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005826:	01893503          	ld	a0,24(s2)
    8000582a:	fffff097          	auipc	ra,0xfffff
    8000582e:	f5e080e7          	jalr	-162(ra) # 80004788 <iunlock>
      end_op();
    80005832:	00000097          	auipc	ra,0x0
    80005836:	8e8080e7          	jalr	-1816(ra) # 8000511a <end_op>

      if(r != n1){
    8000583a:	009c1f63          	bne	s8,s1,80005858 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000583e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005842:	0149db63          	bge	s3,s4,80005858 <filewrite+0xf6>
      int n1 = n - i;
    80005846:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000584a:	84be                	mv	s1,a5
    8000584c:	2781                	sext.w	a5,a5
    8000584e:	f8fb5ce3          	bge	s6,a5,800057e6 <filewrite+0x84>
    80005852:	84de                	mv	s1,s7
    80005854:	bf49                	j	800057e6 <filewrite+0x84>
    int i = 0;
    80005856:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005858:	013a1f63          	bne	s4,s3,80005876 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000585c:	8552                	mv	a0,s4
    8000585e:	60a6                	ld	ra,72(sp)
    80005860:	6406                	ld	s0,64(sp)
    80005862:	74e2                	ld	s1,56(sp)
    80005864:	7942                	ld	s2,48(sp)
    80005866:	79a2                	ld	s3,40(sp)
    80005868:	7a02                	ld	s4,32(sp)
    8000586a:	6ae2                	ld	s5,24(sp)
    8000586c:	6b42                	ld	s6,16(sp)
    8000586e:	6ba2                	ld	s7,8(sp)
    80005870:	6c02                	ld	s8,0(sp)
    80005872:	6161                	addi	sp,sp,80
    80005874:	8082                	ret
    ret = (i == n ? n : -1);
    80005876:	5a7d                	li	s4,-1
    80005878:	b7d5                	j	8000585c <filewrite+0xfa>
    panic("filewrite");
    8000587a:	00004517          	auipc	a0,0x4
    8000587e:	f7650513          	addi	a0,a0,-138 # 800097f0 <syscalls+0x2a0>
    80005882:	ffffb097          	auipc	ra,0xffffb
    80005886:	cac080e7          	jalr	-852(ra) # 8000052e <panic>
    return -1;
    8000588a:	5a7d                	li	s4,-1
    8000588c:	bfc1                	j	8000585c <filewrite+0xfa>
      return -1;
    8000588e:	5a7d                	li	s4,-1
    80005890:	b7f1                	j	8000585c <filewrite+0xfa>
    80005892:	5a7d                	li	s4,-1
    80005894:	b7e1                	j	8000585c <filewrite+0xfa>

0000000080005896 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005896:	7179                	addi	sp,sp,-48
    80005898:	f406                	sd	ra,40(sp)
    8000589a:	f022                	sd	s0,32(sp)
    8000589c:	ec26                	sd	s1,24(sp)
    8000589e:	e84a                	sd	s2,16(sp)
    800058a0:	e44e                	sd	s3,8(sp)
    800058a2:	e052                	sd	s4,0(sp)
    800058a4:	1800                	addi	s0,sp,48
    800058a6:	84aa                	mv	s1,a0
    800058a8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800058aa:	0005b023          	sd	zero,0(a1)
    800058ae:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800058b2:	00000097          	auipc	ra,0x0
    800058b6:	bf8080e7          	jalr	-1032(ra) # 800054aa <filealloc>
    800058ba:	e088                	sd	a0,0(s1)
    800058bc:	c551                	beqz	a0,80005948 <pipealloc+0xb2>
    800058be:	00000097          	auipc	ra,0x0
    800058c2:	bec080e7          	jalr	-1044(ra) # 800054aa <filealloc>
    800058c6:	00aa3023          	sd	a0,0(s4)
    800058ca:	c92d                	beqz	a0,8000593c <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800058cc:	ffffb097          	auipc	ra,0xffffb
    800058d0:	20a080e7          	jalr	522(ra) # 80000ad6 <kalloc>
    800058d4:	892a                	mv	s2,a0
    800058d6:	c125                	beqz	a0,80005936 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800058d8:	4985                	li	s3,1
    800058da:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800058de:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800058e2:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800058e6:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800058ea:	00004597          	auipc	a1,0x4
    800058ee:	f1658593          	addi	a1,a1,-234 # 80009800 <syscalls+0x2b0>
    800058f2:	ffffb097          	auipc	ra,0xffffb
    800058f6:	244080e7          	jalr	580(ra) # 80000b36 <initlock>
  (*f0)->type = FD_PIPE;
    800058fa:	609c                	ld	a5,0(s1)
    800058fc:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005900:	609c                	ld	a5,0(s1)
    80005902:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005906:	609c                	ld	a5,0(s1)
    80005908:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000590c:	609c                	ld	a5,0(s1)
    8000590e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005912:	000a3783          	ld	a5,0(s4)
    80005916:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000591a:	000a3783          	ld	a5,0(s4)
    8000591e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005922:	000a3783          	ld	a5,0(s4)
    80005926:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000592a:	000a3783          	ld	a5,0(s4)
    8000592e:	0127b823          	sd	s2,16(a5)
  return 0;
    80005932:	4501                	li	a0,0
    80005934:	a025                	j	8000595c <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005936:	6088                	ld	a0,0(s1)
    80005938:	e501                	bnez	a0,80005940 <pipealloc+0xaa>
    8000593a:	a039                	j	80005948 <pipealloc+0xb2>
    8000593c:	6088                	ld	a0,0(s1)
    8000593e:	c51d                	beqz	a0,8000596c <pipealloc+0xd6>
    fileclose(*f0);
    80005940:	00000097          	auipc	ra,0x0
    80005944:	c26080e7          	jalr	-986(ra) # 80005566 <fileclose>
  if(*f1)
    80005948:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000594c:	557d                	li	a0,-1
  if(*f1)
    8000594e:	c799                	beqz	a5,8000595c <pipealloc+0xc6>
    fileclose(*f1);
    80005950:	853e                	mv	a0,a5
    80005952:	00000097          	auipc	ra,0x0
    80005956:	c14080e7          	jalr	-1004(ra) # 80005566 <fileclose>
  return -1;
    8000595a:	557d                	li	a0,-1
}
    8000595c:	70a2                	ld	ra,40(sp)
    8000595e:	7402                	ld	s0,32(sp)
    80005960:	64e2                	ld	s1,24(sp)
    80005962:	6942                	ld	s2,16(sp)
    80005964:	69a2                	ld	s3,8(sp)
    80005966:	6a02                	ld	s4,0(sp)
    80005968:	6145                	addi	sp,sp,48
    8000596a:	8082                	ret
  return -1;
    8000596c:	557d                	li	a0,-1
    8000596e:	b7fd                	j	8000595c <pipealloc+0xc6>

0000000080005970 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005970:	1101                	addi	sp,sp,-32
    80005972:	ec06                	sd	ra,24(sp)
    80005974:	e822                	sd	s0,16(sp)
    80005976:	e426                	sd	s1,8(sp)
    80005978:	e04a                	sd	s2,0(sp)
    8000597a:	1000                	addi	s0,sp,32
    8000597c:	84aa                	mv	s1,a0
    8000597e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005980:	ffffb097          	auipc	ra,0xffffb
    80005984:	246080e7          	jalr	582(ra) # 80000bc6 <acquire>
  if(writable){
    80005988:	02090d63          	beqz	s2,800059c2 <pipeclose+0x52>
    pi->writeopen = 0;
    8000598c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005990:	21848513          	addi	a0,s1,536
    80005994:	ffffd097          	auipc	ra,0xffffd
    80005998:	bb8080e7          	jalr	-1096(ra) # 8000254c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000599c:	2204b783          	ld	a5,544(s1)
    800059a0:	eb95                	bnez	a5,800059d4 <pipeclose+0x64>
    release(&pi->lock);
    800059a2:	8526                	mv	a0,s1
    800059a4:	ffffb097          	auipc	ra,0xffffb
    800059a8:	2f8080e7          	jalr	760(ra) # 80000c9c <release>
    kfree((char*)pi);
    800059ac:	8526                	mv	a0,s1
    800059ae:	ffffb097          	auipc	ra,0xffffb
    800059b2:	02c080e7          	jalr	44(ra) # 800009da <kfree>
  } else
    release(&pi->lock);
}
    800059b6:	60e2                	ld	ra,24(sp)
    800059b8:	6442                	ld	s0,16(sp)
    800059ba:	64a2                	ld	s1,8(sp)
    800059bc:	6902                	ld	s2,0(sp)
    800059be:	6105                	addi	sp,sp,32
    800059c0:	8082                	ret
    pi->readopen = 0;
    800059c2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800059c6:	21c48513          	addi	a0,s1,540
    800059ca:	ffffd097          	auipc	ra,0xffffd
    800059ce:	b82080e7          	jalr	-1150(ra) # 8000254c <wakeup>
    800059d2:	b7e9                	j	8000599c <pipeclose+0x2c>
    release(&pi->lock);
    800059d4:	8526                	mv	a0,s1
    800059d6:	ffffb097          	auipc	ra,0xffffb
    800059da:	2c6080e7          	jalr	710(ra) # 80000c9c <release>
}
    800059de:	bfe1                	j	800059b6 <pipeclose+0x46>

00000000800059e0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800059e0:	7159                	addi	sp,sp,-112
    800059e2:	f486                	sd	ra,104(sp)
    800059e4:	f0a2                	sd	s0,96(sp)
    800059e6:	eca6                	sd	s1,88(sp)
    800059e8:	e8ca                	sd	s2,80(sp)
    800059ea:	e4ce                	sd	s3,72(sp)
    800059ec:	e0d2                	sd	s4,64(sp)
    800059ee:	fc56                	sd	s5,56(sp)
    800059f0:	f85a                	sd	s6,48(sp)
    800059f2:	f45e                	sd	s7,40(sp)
    800059f4:	f062                	sd	s8,32(sp)
    800059f6:	ec66                	sd	s9,24(sp)
    800059f8:	1880                	addi	s0,sp,112
    800059fa:	84aa                	mv	s1,a0
    800059fc:	8b2e                	mv	s6,a1
    800059fe:	8ab2                	mv	s5,a2
  int i = 0;
  struct proc *pr = myproc();
    80005a00:	ffffc097          	auipc	ra,0xffffc
    80005a04:	07c080e7          	jalr	124(ra) # 80001a7c <myproc>
    80005a08:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005a0a:	8526                	mv	a0,s1
    80005a0c:	ffffb097          	auipc	ra,0xffffb
    80005a10:	1ba080e7          	jalr	442(ra) # 80000bc6 <acquire>
  while(i < n){
    80005a14:	0b505663          	blez	s5,80005ac0 <pipewrite+0xe0>
  int i = 0;
    80005a18:	4901                	li	s2,0
    if(pi->readopen == 0 || pr->killed==1){
    80005a1a:	4a05                	li	s4,1
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005a1c:	5bfd                	li	s7,-1
      wakeup(&pi->nread);
    80005a1e:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005a22:	21c48c13          	addi	s8,s1,540
    80005a26:	a091                	j	80005a6a <pipewrite+0x8a>
      release(&pi->lock);
    80005a28:	8526                	mv	a0,s1
    80005a2a:	ffffb097          	auipc	ra,0xffffb
    80005a2e:	272080e7          	jalr	626(ra) # 80000c9c <release>
      return -1;
    80005a32:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005a34:	854a                	mv	a0,s2
    80005a36:	70a6                	ld	ra,104(sp)
    80005a38:	7406                	ld	s0,96(sp)
    80005a3a:	64e6                	ld	s1,88(sp)
    80005a3c:	6946                	ld	s2,80(sp)
    80005a3e:	69a6                	ld	s3,72(sp)
    80005a40:	6a06                	ld	s4,64(sp)
    80005a42:	7ae2                	ld	s5,56(sp)
    80005a44:	7b42                	ld	s6,48(sp)
    80005a46:	7ba2                	ld	s7,40(sp)
    80005a48:	7c02                	ld	s8,32(sp)
    80005a4a:	6ce2                	ld	s9,24(sp)
    80005a4c:	6165                	addi	sp,sp,112
    80005a4e:	8082                	ret
      wakeup(&pi->nread);
    80005a50:	8566                	mv	a0,s9
    80005a52:	ffffd097          	auipc	ra,0xffffd
    80005a56:	afa080e7          	jalr	-1286(ra) # 8000254c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005a5a:	85a6                	mv	a1,s1
    80005a5c:	8562                	mv	a0,s8
    80005a5e:	ffffd097          	auipc	ra,0xffffd
    80005a62:	964080e7          	jalr	-1692(ra) # 800023c2 <sleep>
  while(i < n){
    80005a66:	05595e63          	bge	s2,s5,80005ac2 <pipewrite+0xe2>
    if(pi->readopen == 0 || pr->killed==1){
    80005a6a:	2204a783          	lw	a5,544(s1)
    80005a6e:	dfcd                	beqz	a5,80005a28 <pipewrite+0x48>
    80005a70:	01c9a783          	lw	a5,28(s3)
    80005a74:	fb478ae3          	beq	a5,s4,80005a28 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005a78:	2184a783          	lw	a5,536(s1)
    80005a7c:	21c4a703          	lw	a4,540(s1)
    80005a80:	2007879b          	addiw	a5,a5,512
    80005a84:	fcf706e3          	beq	a4,a5,80005a50 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005a88:	86d2                	mv	a3,s4
    80005a8a:	01690633          	add	a2,s2,s6
    80005a8e:	f9f40593          	addi	a1,s0,-97
    80005a92:	0409b503          	ld	a0,64(s3)
    80005a96:	ffffc097          	auipc	ra,0xffffc
    80005a9a:	c5a080e7          	jalr	-934(ra) # 800016f0 <copyin>
    80005a9e:	03750263          	beq	a0,s7,80005ac2 <pipewrite+0xe2>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005aa2:	21c4a783          	lw	a5,540(s1)
    80005aa6:	0017871b          	addiw	a4,a5,1
    80005aaa:	20e4ae23          	sw	a4,540(s1)
    80005aae:	1ff7f793          	andi	a5,a5,511
    80005ab2:	97a6                	add	a5,a5,s1
    80005ab4:	f9f44703          	lbu	a4,-97(s0)
    80005ab8:	00e78c23          	sb	a4,24(a5)
      i++;
    80005abc:	2905                	addiw	s2,s2,1
    80005abe:	b765                	j	80005a66 <pipewrite+0x86>
  int i = 0;
    80005ac0:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005ac2:	21848513          	addi	a0,s1,536
    80005ac6:	ffffd097          	auipc	ra,0xffffd
    80005aca:	a86080e7          	jalr	-1402(ra) # 8000254c <wakeup>
  release(&pi->lock);
    80005ace:	8526                	mv	a0,s1
    80005ad0:	ffffb097          	auipc	ra,0xffffb
    80005ad4:	1cc080e7          	jalr	460(ra) # 80000c9c <release>
  return i;
    80005ad8:	bfb1                	j	80005a34 <pipewrite+0x54>

0000000080005ada <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005ada:	715d                	addi	sp,sp,-80
    80005adc:	e486                	sd	ra,72(sp)
    80005ade:	e0a2                	sd	s0,64(sp)
    80005ae0:	fc26                	sd	s1,56(sp)
    80005ae2:	f84a                	sd	s2,48(sp)
    80005ae4:	f44e                	sd	s3,40(sp)
    80005ae6:	f052                	sd	s4,32(sp)
    80005ae8:	ec56                	sd	s5,24(sp)
    80005aea:	e85a                	sd	s6,16(sp)
    80005aec:	0880                	addi	s0,sp,80
    80005aee:	84aa                	mv	s1,a0
    80005af0:	892e                	mv	s2,a1
    80005af2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005af4:	ffffc097          	auipc	ra,0xffffc
    80005af8:	f88080e7          	jalr	-120(ra) # 80001a7c <myproc>
    80005afc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005afe:	8526                	mv	a0,s1
    80005b00:	ffffb097          	auipc	ra,0xffffb
    80005b04:	0c6080e7          	jalr	198(ra) # 80000bc6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005b08:	2184a703          	lw	a4,536(s1)
    80005b0c:	21c4a783          	lw	a5,540(s1)
    if(pr->killed==1){
    80005b10:	4985                	li	s3,1
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005b12:	21848b13          	addi	s6,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005b16:	02f71563          	bne	a4,a5,80005b40 <piperead+0x66>
    80005b1a:	2244a783          	lw	a5,548(s1)
    80005b1e:	c38d                	beqz	a5,80005b40 <piperead+0x66>
    if(pr->killed==1){
    80005b20:	01ca2783          	lw	a5,28(s4)
    80005b24:	09378963          	beq	a5,s3,80005bb6 <piperead+0xdc>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005b28:	85a6                	mv	a1,s1
    80005b2a:	855a                	mv	a0,s6
    80005b2c:	ffffd097          	auipc	ra,0xffffd
    80005b30:	896080e7          	jalr	-1898(ra) # 800023c2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005b34:	2184a703          	lw	a4,536(s1)
    80005b38:	21c4a783          	lw	a5,540(s1)
    80005b3c:	fcf70fe3          	beq	a4,a5,80005b1a <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005b40:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005b42:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005b44:	05505363          	blez	s5,80005b8a <piperead+0xb0>
    if(pi->nread == pi->nwrite)
    80005b48:	2184a783          	lw	a5,536(s1)
    80005b4c:	21c4a703          	lw	a4,540(s1)
    80005b50:	02f70d63          	beq	a4,a5,80005b8a <piperead+0xb0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005b54:	0017871b          	addiw	a4,a5,1
    80005b58:	20e4ac23          	sw	a4,536(s1)
    80005b5c:	1ff7f793          	andi	a5,a5,511
    80005b60:	97a6                	add	a5,a5,s1
    80005b62:	0187c783          	lbu	a5,24(a5)
    80005b66:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005b6a:	4685                	li	a3,1
    80005b6c:	fbf40613          	addi	a2,s0,-65
    80005b70:	85ca                	mv	a1,s2
    80005b72:	040a3503          	ld	a0,64(s4)
    80005b76:	ffffc097          	auipc	ra,0xffffc
    80005b7a:	aee080e7          	jalr	-1298(ra) # 80001664 <copyout>
    80005b7e:	01650663          	beq	a0,s6,80005b8a <piperead+0xb0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005b82:	2985                	addiw	s3,s3,1
    80005b84:	0905                	addi	s2,s2,1
    80005b86:	fd3a91e3          	bne	s5,s3,80005b48 <piperead+0x6e>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005b8a:	21c48513          	addi	a0,s1,540
    80005b8e:	ffffd097          	auipc	ra,0xffffd
    80005b92:	9be080e7          	jalr	-1602(ra) # 8000254c <wakeup>
  release(&pi->lock);
    80005b96:	8526                	mv	a0,s1
    80005b98:	ffffb097          	auipc	ra,0xffffb
    80005b9c:	104080e7          	jalr	260(ra) # 80000c9c <release>
  return i;
}
    80005ba0:	854e                	mv	a0,s3
    80005ba2:	60a6                	ld	ra,72(sp)
    80005ba4:	6406                	ld	s0,64(sp)
    80005ba6:	74e2                	ld	s1,56(sp)
    80005ba8:	7942                	ld	s2,48(sp)
    80005baa:	79a2                	ld	s3,40(sp)
    80005bac:	7a02                	ld	s4,32(sp)
    80005bae:	6ae2                	ld	s5,24(sp)
    80005bb0:	6b42                	ld	s6,16(sp)
    80005bb2:	6161                	addi	sp,sp,80
    80005bb4:	8082                	ret
      release(&pi->lock);
    80005bb6:	8526                	mv	a0,s1
    80005bb8:	ffffb097          	auipc	ra,0xffffb
    80005bbc:	0e4080e7          	jalr	228(ra) # 80000c9c <release>
      return -1;
    80005bc0:	59fd                	li	s3,-1
    80005bc2:	bff9                	j	80005ba0 <piperead+0xc6>

0000000080005bc4 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005bc4:	dd010113          	addi	sp,sp,-560
    80005bc8:	22113423          	sd	ra,552(sp)
    80005bcc:	22813023          	sd	s0,544(sp)
    80005bd0:	20913c23          	sd	s1,536(sp)
    80005bd4:	21213823          	sd	s2,528(sp)
    80005bd8:	21313423          	sd	s3,520(sp)
    80005bdc:	21413023          	sd	s4,512(sp)
    80005be0:	ffd6                	sd	s5,504(sp)
    80005be2:	fbda                	sd	s6,496(sp)
    80005be4:	f7de                	sd	s7,488(sp)
    80005be6:	f3e2                	sd	s8,480(sp)
    80005be8:	efe6                	sd	s9,472(sp)
    80005bea:	ebea                	sd	s10,464(sp)
    80005bec:	e7ee                	sd	s11,456(sp)
    80005bee:	1c00                	addi	s0,sp,560
    80005bf0:	dea43823          	sd	a0,-528(s0)
    80005bf4:	deb43023          	sd	a1,-544(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005bf8:	ffffc097          	auipc	ra,0xffffc
    80005bfc:	e84080e7          	jalr	-380(ra) # 80001a7c <myproc>
    80005c00:	89aa                	mv	s3,a0

  struct kthread *t = mykthread();
    80005c02:	ffffc097          	auipc	ra,0xffffc
    80005c06:	eba080e7          	jalr	-326(ra) # 80001abc <mykthread>
    80005c0a:	8b2a                	mv	s6,a0
  struct kthread *nt;


  // Kill all process threads 
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){ 
    80005c0c:	28898493          	addi	s1,s3,648
    80005c10:	6905                	lui	s2,0x1
    80005c12:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80005c16:	994e                	add	s2,s2,s3
    if(nt!=t && nt->state!=TUNUSED){
      acquire(&nt->lock);
      nt->killed=1;
    80005c18:	4a85                	li	s5,1
      if(nt->state == TSLEEPING){
    80005c1a:	4a09                	li	s4,2
        nt->state = TRUNNABLE;
    80005c1c:	4b8d                	li	s7,3
    80005c1e:	a811                	j	80005c32 <exec+0x6e>
      }
      release(&nt->lock);  
    80005c20:	8526                	mv	a0,s1
    80005c22:	ffffb097          	auipc	ra,0xffffb
    80005c26:	07a080e7          	jalr	122(ra) # 80000c9c <release>
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){ 
    80005c2a:	0b848493          	addi	s1,s1,184
    80005c2e:	03248363          	beq	s1,s2,80005c54 <exec+0x90>
    if(nt!=t && nt->state!=TUNUSED){
    80005c32:	fe9b0ce3          	beq	s6,s1,80005c2a <exec+0x66>
    80005c36:	4c9c                	lw	a5,24(s1)
    80005c38:	dbed                	beqz	a5,80005c2a <exec+0x66>
      acquire(&nt->lock);
    80005c3a:	8526                	mv	a0,s1
    80005c3c:	ffffb097          	auipc	ra,0xffffb
    80005c40:	f8a080e7          	jalr	-118(ra) # 80000bc6 <acquire>
      nt->killed=1;
    80005c44:	0354a423          	sw	s5,40(s1)
      if(nt->state == TSLEEPING){
    80005c48:	4c9c                	lw	a5,24(s1)
    80005c4a:	fd479be3          	bne	a5,s4,80005c20 <exec+0x5c>
        nt->state = TRUNNABLE;
    80005c4e:	0174ac23          	sw	s7,24(s1)
    80005c52:	b7f9                	j	80005c20 <exec+0x5c>
    }
  }

  // Wait for all threads to terminate
  kthread_join_all();
    80005c54:	ffffd097          	auipc	ra,0xffffd
    80005c58:	364080e7          	jalr	868(ra) # 80002fb8 <kthread_join_all>
    
  begin_op();
    80005c5c:	fffff097          	auipc	ra,0xfffff
    80005c60:	43e080e7          	jalr	1086(ra) # 8000509a <begin_op>

  if((ip = namei(path)) == 0){
    80005c64:	df043503          	ld	a0,-528(s0)
    80005c68:	fffff097          	auipc	ra,0xfffff
    80005c6c:	212080e7          	jalr	530(ra) # 80004e7a <namei>
    80005c70:	8aaa                	mv	s5,a0
    80005c72:	cd25                	beqz	a0,80005cea <exec+0x126>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c74:	fffff097          	auipc	ra,0xfffff
    80005c78:	a52080e7          	jalr	-1454(ra) # 800046c6 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005c7c:	04000713          	li	a4,64
    80005c80:	4681                	li	a3,0
    80005c82:	e4840613          	addi	a2,s0,-440
    80005c86:	4581                	li	a1,0
    80005c88:	8556                	mv	a0,s5
    80005c8a:	fffff097          	auipc	ra,0xfffff
    80005c8e:	cf0080e7          	jalr	-784(ra) # 8000497a <readi>
    80005c92:	04000793          	li	a5,64
    80005c96:	00f51a63          	bne	a0,a5,80005caa <exec+0xe6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005c9a:	e4842703          	lw	a4,-440(s0)
    80005c9e:	464c47b7          	lui	a5,0x464c4
    80005ca2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005ca6:	04f70863          	beq	a4,a5,80005cf6 <exec+0x132>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005caa:	8556                	mv	a0,s5
    80005cac:	fffff097          	auipc	ra,0xfffff
    80005cb0:	c7c080e7          	jalr	-900(ra) # 80004928 <iunlockput>
    end_op();
    80005cb4:	fffff097          	auipc	ra,0xfffff
    80005cb8:	466080e7          	jalr	1126(ra) # 8000511a <end_op>
  }
  return -1;
    80005cbc:	557d                	li	a0,-1
}
    80005cbe:	22813083          	ld	ra,552(sp)
    80005cc2:	22013403          	ld	s0,544(sp)
    80005cc6:	21813483          	ld	s1,536(sp)
    80005cca:	21013903          	ld	s2,528(sp)
    80005cce:	20813983          	ld	s3,520(sp)
    80005cd2:	20013a03          	ld	s4,512(sp)
    80005cd6:	7afe                	ld	s5,504(sp)
    80005cd8:	7b5e                	ld	s6,496(sp)
    80005cda:	7bbe                	ld	s7,488(sp)
    80005cdc:	7c1e                	ld	s8,480(sp)
    80005cde:	6cfe                	ld	s9,472(sp)
    80005ce0:	6d5e                	ld	s10,464(sp)
    80005ce2:	6dbe                	ld	s11,456(sp)
    80005ce4:	23010113          	addi	sp,sp,560
    80005ce8:	8082                	ret
    end_op();
    80005cea:	fffff097          	auipc	ra,0xfffff
    80005cee:	430080e7          	jalr	1072(ra) # 8000511a <end_op>
    return -1;
    80005cf2:	557d                	li	a0,-1
    80005cf4:	b7e9                	j	80005cbe <exec+0xfa>
  if((pagetable = proc_pagetable(p)) == 0)
    80005cf6:	854e                	mv	a0,s3
    80005cf8:	ffffc097          	auipc	ra,0xffffc
    80005cfc:	f20080e7          	jalr	-224(ra) # 80001c18 <proc_pagetable>
    80005d00:	e0a43423          	sd	a0,-504(s0)
    80005d04:	d15d                	beqz	a0,80005caa <exec+0xe6>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005d06:	e6842783          	lw	a5,-408(s0)
    80005d0a:	e8045703          	lhu	a4,-384(s0)
    80005d0e:	c73d                	beqz	a4,80005d7c <exec+0x1b8>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005d10:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005d12:	e0043023          	sd	zero,-512(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005d16:	6a05                	lui	s4,0x1
    80005d18:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005d1c:	dce43c23          	sd	a4,-552(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005d20:	6d85                	lui	s11,0x1
    80005d22:	7d7d                	lui	s10,0xfffff
    80005d24:	a4b5                	j	80005f90 <exec+0x3cc>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005d26:	00004517          	auipc	a0,0x4
    80005d2a:	ae250513          	addi	a0,a0,-1310 # 80009808 <syscalls+0x2b8>
    80005d2e:	ffffb097          	auipc	ra,0xffffb
    80005d32:	800080e7          	jalr	-2048(ra) # 8000052e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005d36:	874a                	mv	a4,s2
    80005d38:	009c86bb          	addw	a3,s9,s1
    80005d3c:	4581                	li	a1,0
    80005d3e:	8556                	mv	a0,s5
    80005d40:	fffff097          	auipc	ra,0xfffff
    80005d44:	c3a080e7          	jalr	-966(ra) # 8000497a <readi>
    80005d48:	2501                	sext.w	a0,a0
    80005d4a:	1ea91263          	bne	s2,a0,80005f2e <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80005d4e:	009d84bb          	addw	s1,s11,s1
    80005d52:	013d09bb          	addw	s3,s10,s3
    80005d56:	2174fd63          	bgeu	s1,s7,80005f70 <exec+0x3ac>
    pa = walkaddr(pagetable, va + i);
    80005d5a:	02049593          	slli	a1,s1,0x20
    80005d5e:	9181                	srli	a1,a1,0x20
    80005d60:	95e2                	add	a1,a1,s8
    80005d62:	e0843503          	ld	a0,-504(s0)
    80005d66:	ffffb097          	auipc	ra,0xffffb
    80005d6a:	30c080e7          	jalr	780(ra) # 80001072 <walkaddr>
    80005d6e:	862a                	mv	a2,a0
    if(pa == 0)
    80005d70:	d95d                	beqz	a0,80005d26 <exec+0x162>
      n = PGSIZE;
    80005d72:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005d74:	fd49f1e3          	bgeu	s3,s4,80005d36 <exec+0x172>
      n = sz - i;
    80005d78:	894e                	mv	s2,s3
    80005d7a:	bf75                	j	80005d36 <exec+0x172>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005d7c:	4481                	li	s1,0
  iunlockput(ip);
    80005d7e:	8556                	mv	a0,s5
    80005d80:	fffff097          	auipc	ra,0xfffff
    80005d84:	ba8080e7          	jalr	-1112(ra) # 80004928 <iunlockput>
  end_op();
    80005d88:	fffff097          	auipc	ra,0xfffff
    80005d8c:	392080e7          	jalr	914(ra) # 8000511a <end_op>
  p = myproc();
    80005d90:	ffffc097          	auipc	ra,0xffffc
    80005d94:	cec080e7          	jalr	-788(ra) # 80001a7c <myproc>
    80005d98:	8a2a                	mv	s4,a0
  uint64 oldsz = p->sz;
    80005d9a:	03853d03          	ld	s10,56(a0)
  sz = PGROUNDUP(sz);
    80005d9e:	6785                	lui	a5,0x1
    80005da0:	17fd                	addi	a5,a5,-1
    80005da2:	94be                	add	s1,s1,a5
    80005da4:	77fd                	lui	a5,0xfffff
    80005da6:	8fe5                	and	a5,a5,s1
    80005da8:	def43423          	sd	a5,-536(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005dac:	6609                	lui	a2,0x2
    80005dae:	963e                	add	a2,a2,a5
    80005db0:	85be                	mv	a1,a5
    80005db2:	e0843483          	ld	s1,-504(s0)
    80005db6:	8526                	mv	a0,s1
    80005db8:	ffffb097          	auipc	ra,0xffffb
    80005dbc:	65c080e7          	jalr	1628(ra) # 80001414 <uvmalloc>
    80005dc0:	8caa                	mv	s9,a0
  ip = 0;
    80005dc2:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005dc4:	16050563          	beqz	a0,80005f2e <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005dc8:	75f9                	lui	a1,0xffffe
    80005dca:	95aa                	add	a1,a1,a0
    80005dcc:	8526                	mv	a0,s1
    80005dce:	ffffc097          	auipc	ra,0xffffc
    80005dd2:	864080e7          	jalr	-1948(ra) # 80001632 <uvmclear>
  stackbase = sp - PGSIZE;
    80005dd6:	7bfd                	lui	s7,0xfffff
    80005dd8:	9be6                	add	s7,s7,s9
  for(argc = 0; argv[argc]; argc++) {
    80005dda:	de043783          	ld	a5,-544(s0)
    80005dde:	6388                	ld	a0,0(a5)
    80005de0:	c92d                	beqz	a0,80005e52 <exec+0x28e>
    80005de2:	e8840993          	addi	s3,s0,-376
    80005de6:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80005dea:	8966                	mv	s2,s9
  for(argc = 0; argv[argc]; argc++) {
    80005dec:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005dee:	ffffb097          	auipc	ra,0xffffb
    80005df2:	07a080e7          	jalr	122(ra) # 80000e68 <strlen>
    80005df6:	0015079b          	addiw	a5,a0,1
    80005dfa:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005dfe:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005e02:	15796b63          	bltu	s2,s7,80005f58 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005e06:	de043d83          	ld	s11,-544(s0)
    80005e0a:	000dba83          	ld	s5,0(s11) # 1000 <_entry-0x7ffff000>
    80005e0e:	8556                	mv	a0,s5
    80005e10:	ffffb097          	auipc	ra,0xffffb
    80005e14:	058080e7          	jalr	88(ra) # 80000e68 <strlen>
    80005e18:	0015069b          	addiw	a3,a0,1
    80005e1c:	8656                	mv	a2,s5
    80005e1e:	85ca                	mv	a1,s2
    80005e20:	e0843503          	ld	a0,-504(s0)
    80005e24:	ffffc097          	auipc	ra,0xffffc
    80005e28:	840080e7          	jalr	-1984(ra) # 80001664 <copyout>
    80005e2c:	12054a63          	bltz	a0,80005f60 <exec+0x39c>
    ustack[argc] = sp;
    80005e30:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005e34:	0485                	addi	s1,s1,1
    80005e36:	008d8793          	addi	a5,s11,8
    80005e3a:	def43023          	sd	a5,-544(s0)
    80005e3e:	008db503          	ld	a0,8(s11)
    80005e42:	c911                	beqz	a0,80005e56 <exec+0x292>
    if(argc >= MAXARG)
    80005e44:	09a1                	addi	s3,s3,8
    80005e46:	fb3c14e3          	bne	s8,s3,80005dee <exec+0x22a>
  sz = sz1;
    80005e4a:	df943423          	sd	s9,-536(s0)
  ip = 0;
    80005e4e:	4a81                	li	s5,0
    80005e50:	a8f9                	j	80005f2e <exec+0x36a>
  sp = sz;
    80005e52:	8966                	mv	s2,s9
  for(argc = 0; argv[argc]; argc++) {
    80005e54:	4481                	li	s1,0
  ustack[argc] = 0;
    80005e56:	00349793          	slli	a5,s1,0x3
    80005e5a:	f9040713          	addi	a4,s0,-112
    80005e5e:	97ba                	add	a5,a5,a4
    80005e60:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffbcef8>
  sp -= (argc+1) * sizeof(uint64);
    80005e64:	00148693          	addi	a3,s1,1
    80005e68:	068e                	slli	a3,a3,0x3
    80005e6a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005e6e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005e72:	01797663          	bgeu	s2,s7,80005e7e <exec+0x2ba>
  sz = sz1;
    80005e76:	df943423          	sd	s9,-536(s0)
  ip = 0;
    80005e7a:	4a81                	li	s5,0
    80005e7c:	a84d                	j	80005f2e <exec+0x36a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005e7e:	e8840613          	addi	a2,s0,-376
    80005e82:	85ca                	mv	a1,s2
    80005e84:	e0843503          	ld	a0,-504(s0)
    80005e88:	ffffb097          	auipc	ra,0xffffb
    80005e8c:	7dc080e7          	jalr	2012(ra) # 80001664 <copyout>
    80005e90:	0c054c63          	bltz	a0,80005f68 <exec+0x3a4>
  t->trapframe->a1 = sp;
    80005e94:	040b3783          	ld	a5,64(s6)
    80005e98:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005e9c:	df043783          	ld	a5,-528(s0)
    80005ea0:	0007c703          	lbu	a4,0(a5)
    80005ea4:	cf11                	beqz	a4,80005ec0 <exec+0x2fc>
    80005ea6:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005ea8:	02f00693          	li	a3,47
    80005eac:	a039                	j	80005eba <exec+0x2f6>
      last = s+1;
    80005eae:	def43823          	sd	a5,-528(s0)
  for(last=s=path; *s; s++)
    80005eb2:	0785                	addi	a5,a5,1
    80005eb4:	fff7c703          	lbu	a4,-1(a5)
    80005eb8:	c701                	beqz	a4,80005ec0 <exec+0x2fc>
    if(*s == '/')
    80005eba:	fed71ce3          	bne	a4,a3,80005eb2 <exec+0x2ee>
    80005ebe:	bfc5                	j	80005eae <exec+0x2ea>
  safestrcpy(p->name, last, sizeof(p->name));
    80005ec0:	4641                	li	a2,16
    80005ec2:	df043583          	ld	a1,-528(s0)
    80005ec6:	0d8a0513          	addi	a0,s4,216
    80005eca:	ffffb097          	auipc	ra,0xffffb
    80005ece:	f6c080e7          	jalr	-148(ra) # 80000e36 <safestrcpy>
  for(int i=0; i<32; i++){
    80005ed2:	0f8a0793          	addi	a5,s4,248
    80005ed6:	1f8a0713          	addi	a4,s4,504
    80005eda:	85ba                	mv	a1,a4
    if(!((p->signal_handlers[i]) == (void*)SIG_IGN)){
    80005edc:	4605                	li	a2,1
    80005ede:	a029                	j	80005ee8 <exec+0x324>
  for(int i=0; i<32; i++){
    80005ee0:	07a1                	addi	a5,a5,8
    80005ee2:	0711                	addi	a4,a4,4
    80005ee4:	00f58a63          	beq	a1,a5,80005ef8 <exec+0x334>
    if(!((p->signal_handlers[i]) == (void*)SIG_IGN)){
    80005ee8:	6394                	ld	a3,0(a5)
    80005eea:	fec68be3          	beq	a3,a2,80005ee0 <exec+0x31c>
        p->signal_handlers[i]=SIG_DFL;
    80005eee:	0007b023          	sd	zero,0(a5)
        p->handlers_sigmasks[i]=0;   
    80005ef2:	00072023          	sw	zero,0(a4)
    80005ef6:	b7ed                	j	80005ee0 <exec+0x31c>
  oldpagetable = p->pagetable;
    80005ef8:	040a3503          	ld	a0,64(s4)
  p->pagetable = pagetable;
    80005efc:	e0843783          	ld	a5,-504(s0)
    80005f00:	04fa3023          	sd	a5,64(s4)
  p->sz = sz;
    80005f04:	039a3c23          	sd	s9,56(s4)
  t->trapframe->epc = elf.entry;  // initial program counter = main
    80005f08:	040b3783          	ld	a5,64(s6)
    80005f0c:	e6043703          	ld	a4,-416(s0)
    80005f10:	ef98                	sd	a4,24(a5)
  t->trapframe->sp = sp; // initial stack pointer
    80005f12:	040b3783          	ld	a5,64(s6)
    80005f16:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005f1a:	85ea                	mv	a1,s10
    80005f1c:	ffffc097          	auipc	ra,0xffffc
    80005f20:	d98080e7          	jalr	-616(ra) # 80001cb4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005f24:	0004851b          	sext.w	a0,s1
    80005f28:	bb59                	j	80005cbe <exec+0xfa>
    80005f2a:	de943423          	sd	s1,-536(s0)
    proc_freepagetable(pagetable, sz);
    80005f2e:	de843583          	ld	a1,-536(s0)
    80005f32:	e0843503          	ld	a0,-504(s0)
    80005f36:	ffffc097          	auipc	ra,0xffffc
    80005f3a:	d7e080e7          	jalr	-642(ra) # 80001cb4 <proc_freepagetable>
  if(ip){
    80005f3e:	d60a96e3          	bnez	s5,80005caa <exec+0xe6>
  return -1;
    80005f42:	557d                	li	a0,-1
    80005f44:	bbad                	j	80005cbe <exec+0xfa>
    80005f46:	de943423          	sd	s1,-536(s0)
    80005f4a:	b7d5                	j	80005f2e <exec+0x36a>
    80005f4c:	de943423          	sd	s1,-536(s0)
    80005f50:	bff9                	j	80005f2e <exec+0x36a>
    80005f52:	de943423          	sd	s1,-536(s0)
    80005f56:	bfe1                	j	80005f2e <exec+0x36a>
  sz = sz1;
    80005f58:	df943423          	sd	s9,-536(s0)
  ip = 0;
    80005f5c:	4a81                	li	s5,0
    80005f5e:	bfc1                	j	80005f2e <exec+0x36a>
  sz = sz1;
    80005f60:	df943423          	sd	s9,-536(s0)
  ip = 0;
    80005f64:	4a81                	li	s5,0
    80005f66:	b7e1                	j	80005f2e <exec+0x36a>
  sz = sz1;
    80005f68:	df943423          	sd	s9,-536(s0)
  ip = 0;
    80005f6c:	4a81                	li	s5,0
    80005f6e:	b7c1                	j	80005f2e <exec+0x36a>
    sz = sz1;
    80005f70:	de843483          	ld	s1,-536(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005f74:	e0043783          	ld	a5,-512(s0)
    80005f78:	0017869b          	addiw	a3,a5,1
    80005f7c:	e0d43023          	sd	a3,-512(s0)
    80005f80:	df843783          	ld	a5,-520(s0)
    80005f84:	0387879b          	addiw	a5,a5,56
    80005f88:	e8045703          	lhu	a4,-384(s0)
    80005f8c:	dee6d9e3          	bge	a3,a4,80005d7e <exec+0x1ba>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005f90:	2781                	sext.w	a5,a5
    80005f92:	def43c23          	sd	a5,-520(s0)
    80005f96:	03800713          	li	a4,56
    80005f9a:	86be                	mv	a3,a5
    80005f9c:	e1040613          	addi	a2,s0,-496
    80005fa0:	4581                	li	a1,0
    80005fa2:	8556                	mv	a0,s5
    80005fa4:	fffff097          	auipc	ra,0xfffff
    80005fa8:	9d6080e7          	jalr	-1578(ra) # 8000497a <readi>
    80005fac:	03800793          	li	a5,56
    80005fb0:	f6f51de3          	bne	a0,a5,80005f2a <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80005fb4:	e1042783          	lw	a5,-496(s0)
    80005fb8:	4705                	li	a4,1
    80005fba:	fae79de3          	bne	a5,a4,80005f74 <exec+0x3b0>
    if(ph.memsz < ph.filesz)
    80005fbe:	e3843603          	ld	a2,-456(s0)
    80005fc2:	e3043783          	ld	a5,-464(s0)
    80005fc6:	f8f660e3          	bltu	a2,a5,80005f46 <exec+0x382>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005fca:	e2043783          	ld	a5,-480(s0)
    80005fce:	963e                	add	a2,a2,a5
    80005fd0:	f6f66ee3          	bltu	a2,a5,80005f4c <exec+0x388>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005fd4:	85a6                	mv	a1,s1
    80005fd6:	e0843503          	ld	a0,-504(s0)
    80005fda:	ffffb097          	auipc	ra,0xffffb
    80005fde:	43a080e7          	jalr	1082(ra) # 80001414 <uvmalloc>
    80005fe2:	dea43423          	sd	a0,-536(s0)
    80005fe6:	d535                	beqz	a0,80005f52 <exec+0x38e>
    if(ph.vaddr % PGSIZE != 0)
    80005fe8:	e2043c03          	ld	s8,-480(s0)
    80005fec:	dd843783          	ld	a5,-552(s0)
    80005ff0:	00fc77b3          	and	a5,s8,a5
    80005ff4:	ff8d                	bnez	a5,80005f2e <exec+0x36a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005ff6:	e1842c83          	lw	s9,-488(s0)
    80005ffa:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005ffe:	f60b89e3          	beqz	s7,80005f70 <exec+0x3ac>
    80006002:	89de                	mv	s3,s7
    80006004:	4481                	li	s1,0
    80006006:	bb91                	j	80005d5a <exec+0x196>

0000000080006008 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80006008:	7179                	addi	sp,sp,-48
    8000600a:	f406                	sd	ra,40(sp)
    8000600c:	f022                	sd	s0,32(sp)
    8000600e:	ec26                	sd	s1,24(sp)
    80006010:	e84a                	sd	s2,16(sp)
    80006012:	1800                	addi	s0,sp,48
    80006014:	892e                	mv	s2,a1
    80006016:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80006018:	fdc40593          	addi	a1,s0,-36
    8000601c:	ffffe097          	auipc	ra,0xffffe
    80006020:	964080e7          	jalr	-1692(ra) # 80003980 <argint>
    80006024:	04054063          	bltz	a0,80006064 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80006028:	fdc42703          	lw	a4,-36(s0)
    8000602c:	47bd                	li	a5,15
    8000602e:	02e7ed63          	bltu	a5,a4,80006068 <argfd+0x60>
    80006032:	ffffc097          	auipc	ra,0xffffc
    80006036:	a4a080e7          	jalr	-1462(ra) # 80001a7c <myproc>
    8000603a:	fdc42703          	lw	a4,-36(s0)
    8000603e:	00a70793          	addi	a5,a4,10
    80006042:	078e                	slli	a5,a5,0x3
    80006044:	953e                	add	a0,a0,a5
    80006046:	611c                	ld	a5,0(a0)
    80006048:	c395                	beqz	a5,8000606c <argfd+0x64>
    return -1;
  if(pfd)
    8000604a:	00090463          	beqz	s2,80006052 <argfd+0x4a>
    *pfd = fd;
    8000604e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80006052:	4501                	li	a0,0
  if(pf)
    80006054:	c091                	beqz	s1,80006058 <argfd+0x50>
    *pf = f;
    80006056:	e09c                	sd	a5,0(s1)
}
    80006058:	70a2                	ld	ra,40(sp)
    8000605a:	7402                	ld	s0,32(sp)
    8000605c:	64e2                	ld	s1,24(sp)
    8000605e:	6942                	ld	s2,16(sp)
    80006060:	6145                	addi	sp,sp,48
    80006062:	8082                	ret
    return -1;
    80006064:	557d                	li	a0,-1
    80006066:	bfcd                	j	80006058 <argfd+0x50>
    return -1;
    80006068:	557d                	li	a0,-1
    8000606a:	b7fd                	j	80006058 <argfd+0x50>
    8000606c:	557d                	li	a0,-1
    8000606e:	b7ed                	j	80006058 <argfd+0x50>

0000000080006070 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80006070:	1101                	addi	sp,sp,-32
    80006072:	ec06                	sd	ra,24(sp)
    80006074:	e822                	sd	s0,16(sp)
    80006076:	e426                	sd	s1,8(sp)
    80006078:	1000                	addi	s0,sp,32
    8000607a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000607c:	ffffc097          	auipc	ra,0xffffc
    80006080:	a00080e7          	jalr	-1536(ra) # 80001a7c <myproc>
    80006084:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80006086:	05050793          	addi	a5,a0,80
    8000608a:	4501                	li	a0,0
    8000608c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000608e:	6398                	ld	a4,0(a5)
    80006090:	cb19                	beqz	a4,800060a6 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80006092:	2505                	addiw	a0,a0,1
    80006094:	07a1                	addi	a5,a5,8
    80006096:	fed51ce3          	bne	a0,a3,8000608e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000609a:	557d                	li	a0,-1
}
    8000609c:	60e2                	ld	ra,24(sp)
    8000609e:	6442                	ld	s0,16(sp)
    800060a0:	64a2                	ld	s1,8(sp)
    800060a2:	6105                	addi	sp,sp,32
    800060a4:	8082                	ret
      p->ofile[fd] = f;
    800060a6:	00a50793          	addi	a5,a0,10
    800060aa:	078e                	slli	a5,a5,0x3
    800060ac:	963e                	add	a2,a2,a5
    800060ae:	e204                	sd	s1,0(a2)
      return fd;
    800060b0:	b7f5                	j	8000609c <fdalloc+0x2c>

00000000800060b2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800060b2:	715d                	addi	sp,sp,-80
    800060b4:	e486                	sd	ra,72(sp)
    800060b6:	e0a2                	sd	s0,64(sp)
    800060b8:	fc26                	sd	s1,56(sp)
    800060ba:	f84a                	sd	s2,48(sp)
    800060bc:	f44e                	sd	s3,40(sp)
    800060be:	f052                	sd	s4,32(sp)
    800060c0:	ec56                	sd	s5,24(sp)
    800060c2:	0880                	addi	s0,sp,80
    800060c4:	89ae                	mv	s3,a1
    800060c6:	8ab2                	mv	s5,a2
    800060c8:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800060ca:	fb040593          	addi	a1,s0,-80
    800060ce:	fffff097          	auipc	ra,0xfffff
    800060d2:	dca080e7          	jalr	-566(ra) # 80004e98 <nameiparent>
    800060d6:	892a                	mv	s2,a0
    800060d8:	12050e63          	beqz	a0,80006214 <create+0x162>
    return 0;

  ilock(dp);
    800060dc:	ffffe097          	auipc	ra,0xffffe
    800060e0:	5ea080e7          	jalr	1514(ra) # 800046c6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800060e4:	4601                	li	a2,0
    800060e6:	fb040593          	addi	a1,s0,-80
    800060ea:	854a                	mv	a0,s2
    800060ec:	fffff097          	auipc	ra,0xfffff
    800060f0:	abe080e7          	jalr	-1346(ra) # 80004baa <dirlookup>
    800060f4:	84aa                	mv	s1,a0
    800060f6:	c921                	beqz	a0,80006146 <create+0x94>
    iunlockput(dp);
    800060f8:	854a                	mv	a0,s2
    800060fa:	fffff097          	auipc	ra,0xfffff
    800060fe:	82e080e7          	jalr	-2002(ra) # 80004928 <iunlockput>
    ilock(ip);
    80006102:	8526                	mv	a0,s1
    80006104:	ffffe097          	auipc	ra,0xffffe
    80006108:	5c2080e7          	jalr	1474(ra) # 800046c6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000610c:	2981                	sext.w	s3,s3
    8000610e:	4789                	li	a5,2
    80006110:	02f99463          	bne	s3,a5,80006138 <create+0x86>
    80006114:	0444d783          	lhu	a5,68(s1)
    80006118:	37f9                	addiw	a5,a5,-2
    8000611a:	17c2                	slli	a5,a5,0x30
    8000611c:	93c1                	srli	a5,a5,0x30
    8000611e:	4705                	li	a4,1
    80006120:	00f76c63          	bltu	a4,a5,80006138 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80006124:	8526                	mv	a0,s1
    80006126:	60a6                	ld	ra,72(sp)
    80006128:	6406                	ld	s0,64(sp)
    8000612a:	74e2                	ld	s1,56(sp)
    8000612c:	7942                	ld	s2,48(sp)
    8000612e:	79a2                	ld	s3,40(sp)
    80006130:	7a02                	ld	s4,32(sp)
    80006132:	6ae2                	ld	s5,24(sp)
    80006134:	6161                	addi	sp,sp,80
    80006136:	8082                	ret
    iunlockput(ip);
    80006138:	8526                	mv	a0,s1
    8000613a:	ffffe097          	auipc	ra,0xffffe
    8000613e:	7ee080e7          	jalr	2030(ra) # 80004928 <iunlockput>
    return 0;
    80006142:	4481                	li	s1,0
    80006144:	b7c5                	j	80006124 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80006146:	85ce                	mv	a1,s3
    80006148:	00092503          	lw	a0,0(s2)
    8000614c:	ffffe097          	auipc	ra,0xffffe
    80006150:	3e2080e7          	jalr	994(ra) # 8000452e <ialloc>
    80006154:	84aa                	mv	s1,a0
    80006156:	c521                	beqz	a0,8000619e <create+0xec>
  ilock(ip);
    80006158:	ffffe097          	auipc	ra,0xffffe
    8000615c:	56e080e7          	jalr	1390(ra) # 800046c6 <ilock>
  ip->major = major;
    80006160:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80006164:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80006168:	4a05                	li	s4,1
    8000616a:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    8000616e:	8526                	mv	a0,s1
    80006170:	ffffe097          	auipc	ra,0xffffe
    80006174:	48c080e7          	jalr	1164(ra) # 800045fc <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80006178:	2981                	sext.w	s3,s3
    8000617a:	03498a63          	beq	s3,s4,800061ae <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000617e:	40d0                	lw	a2,4(s1)
    80006180:	fb040593          	addi	a1,s0,-80
    80006184:	854a                	mv	a0,s2
    80006186:	fffff097          	auipc	ra,0xfffff
    8000618a:	c32080e7          	jalr	-974(ra) # 80004db8 <dirlink>
    8000618e:	06054b63          	bltz	a0,80006204 <create+0x152>
  iunlockput(dp);
    80006192:	854a                	mv	a0,s2
    80006194:	ffffe097          	auipc	ra,0xffffe
    80006198:	794080e7          	jalr	1940(ra) # 80004928 <iunlockput>
  return ip;
    8000619c:	b761                	j	80006124 <create+0x72>
    panic("create: ialloc");
    8000619e:	00003517          	auipc	a0,0x3
    800061a2:	68a50513          	addi	a0,a0,1674 # 80009828 <syscalls+0x2d8>
    800061a6:	ffffa097          	auipc	ra,0xffffa
    800061aa:	388080e7          	jalr	904(ra) # 8000052e <panic>
    dp->nlink++;  // for ".."
    800061ae:	04a95783          	lhu	a5,74(s2)
    800061b2:	2785                	addiw	a5,a5,1
    800061b4:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800061b8:	854a                	mv	a0,s2
    800061ba:	ffffe097          	auipc	ra,0xffffe
    800061be:	442080e7          	jalr	1090(ra) # 800045fc <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800061c2:	40d0                	lw	a2,4(s1)
    800061c4:	00003597          	auipc	a1,0x3
    800061c8:	67458593          	addi	a1,a1,1652 # 80009838 <syscalls+0x2e8>
    800061cc:	8526                	mv	a0,s1
    800061ce:	fffff097          	auipc	ra,0xfffff
    800061d2:	bea080e7          	jalr	-1046(ra) # 80004db8 <dirlink>
    800061d6:	00054f63          	bltz	a0,800061f4 <create+0x142>
    800061da:	00492603          	lw	a2,4(s2)
    800061de:	00003597          	auipc	a1,0x3
    800061e2:	66258593          	addi	a1,a1,1634 # 80009840 <syscalls+0x2f0>
    800061e6:	8526                	mv	a0,s1
    800061e8:	fffff097          	auipc	ra,0xfffff
    800061ec:	bd0080e7          	jalr	-1072(ra) # 80004db8 <dirlink>
    800061f0:	f80557e3          	bgez	a0,8000617e <create+0xcc>
      panic("create dots");
    800061f4:	00003517          	auipc	a0,0x3
    800061f8:	65450513          	addi	a0,a0,1620 # 80009848 <syscalls+0x2f8>
    800061fc:	ffffa097          	auipc	ra,0xffffa
    80006200:	332080e7          	jalr	818(ra) # 8000052e <panic>
    panic("create: dirlink");
    80006204:	00003517          	auipc	a0,0x3
    80006208:	65450513          	addi	a0,a0,1620 # 80009858 <syscalls+0x308>
    8000620c:	ffffa097          	auipc	ra,0xffffa
    80006210:	322080e7          	jalr	802(ra) # 8000052e <panic>
    return 0;
    80006214:	84aa                	mv	s1,a0
    80006216:	b739                	j	80006124 <create+0x72>

0000000080006218 <sys_dup>:
{
    80006218:	7179                	addi	sp,sp,-48
    8000621a:	f406                	sd	ra,40(sp)
    8000621c:	f022                	sd	s0,32(sp)
    8000621e:	ec26                	sd	s1,24(sp)
    80006220:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80006222:	fd840613          	addi	a2,s0,-40
    80006226:	4581                	li	a1,0
    80006228:	4501                	li	a0,0
    8000622a:	00000097          	auipc	ra,0x0
    8000622e:	dde080e7          	jalr	-546(ra) # 80006008 <argfd>
    return -1;
    80006232:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80006234:	02054363          	bltz	a0,8000625a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80006238:	fd843503          	ld	a0,-40(s0)
    8000623c:	00000097          	auipc	ra,0x0
    80006240:	e34080e7          	jalr	-460(ra) # 80006070 <fdalloc>
    80006244:	84aa                	mv	s1,a0
    return -1;
    80006246:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80006248:	00054963          	bltz	a0,8000625a <sys_dup+0x42>
  filedup(f);
    8000624c:	fd843503          	ld	a0,-40(s0)
    80006250:	fffff097          	auipc	ra,0xfffff
    80006254:	2c4080e7          	jalr	708(ra) # 80005514 <filedup>
  return fd;
    80006258:	87a6                	mv	a5,s1
}
    8000625a:	853e                	mv	a0,a5
    8000625c:	70a2                	ld	ra,40(sp)
    8000625e:	7402                	ld	s0,32(sp)
    80006260:	64e2                	ld	s1,24(sp)
    80006262:	6145                	addi	sp,sp,48
    80006264:	8082                	ret

0000000080006266 <sys_read>:
{
    80006266:	7179                	addi	sp,sp,-48
    80006268:	f406                	sd	ra,40(sp)
    8000626a:	f022                	sd	s0,32(sp)
    8000626c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000626e:	fe840613          	addi	a2,s0,-24
    80006272:	4581                	li	a1,0
    80006274:	4501                	li	a0,0
    80006276:	00000097          	auipc	ra,0x0
    8000627a:	d92080e7          	jalr	-622(ra) # 80006008 <argfd>
    return -1;
    8000627e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006280:	04054163          	bltz	a0,800062c2 <sys_read+0x5c>
    80006284:	fe440593          	addi	a1,s0,-28
    80006288:	4509                	li	a0,2
    8000628a:	ffffd097          	auipc	ra,0xffffd
    8000628e:	6f6080e7          	jalr	1782(ra) # 80003980 <argint>
    return -1;
    80006292:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006294:	02054763          	bltz	a0,800062c2 <sys_read+0x5c>
    80006298:	fd840593          	addi	a1,s0,-40
    8000629c:	4505                	li	a0,1
    8000629e:	ffffd097          	auipc	ra,0xffffd
    800062a2:	704080e7          	jalr	1796(ra) # 800039a2 <argaddr>
    return -1;
    800062a6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800062a8:	00054d63          	bltz	a0,800062c2 <sys_read+0x5c>
  return fileread(f, p, n);
    800062ac:	fe442603          	lw	a2,-28(s0)
    800062b0:	fd843583          	ld	a1,-40(s0)
    800062b4:	fe843503          	ld	a0,-24(s0)
    800062b8:	fffff097          	auipc	ra,0xfffff
    800062bc:	3e8080e7          	jalr	1000(ra) # 800056a0 <fileread>
    800062c0:	87aa                	mv	a5,a0
}
    800062c2:	853e                	mv	a0,a5
    800062c4:	70a2                	ld	ra,40(sp)
    800062c6:	7402                	ld	s0,32(sp)
    800062c8:	6145                	addi	sp,sp,48
    800062ca:	8082                	ret

00000000800062cc <sys_write>:
{
    800062cc:	7179                	addi	sp,sp,-48
    800062ce:	f406                	sd	ra,40(sp)
    800062d0:	f022                	sd	s0,32(sp)
    800062d2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800062d4:	fe840613          	addi	a2,s0,-24
    800062d8:	4581                	li	a1,0
    800062da:	4501                	li	a0,0
    800062dc:	00000097          	auipc	ra,0x0
    800062e0:	d2c080e7          	jalr	-724(ra) # 80006008 <argfd>
    return -1;
    800062e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800062e6:	04054163          	bltz	a0,80006328 <sys_write+0x5c>
    800062ea:	fe440593          	addi	a1,s0,-28
    800062ee:	4509                	li	a0,2
    800062f0:	ffffd097          	auipc	ra,0xffffd
    800062f4:	690080e7          	jalr	1680(ra) # 80003980 <argint>
    return -1;
    800062f8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800062fa:	02054763          	bltz	a0,80006328 <sys_write+0x5c>
    800062fe:	fd840593          	addi	a1,s0,-40
    80006302:	4505                	li	a0,1
    80006304:	ffffd097          	auipc	ra,0xffffd
    80006308:	69e080e7          	jalr	1694(ra) # 800039a2 <argaddr>
    return -1;
    8000630c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000630e:	00054d63          	bltz	a0,80006328 <sys_write+0x5c>
  return filewrite(f, p, n);
    80006312:	fe442603          	lw	a2,-28(s0)
    80006316:	fd843583          	ld	a1,-40(s0)
    8000631a:	fe843503          	ld	a0,-24(s0)
    8000631e:	fffff097          	auipc	ra,0xfffff
    80006322:	444080e7          	jalr	1092(ra) # 80005762 <filewrite>
    80006326:	87aa                	mv	a5,a0
}
    80006328:	853e                	mv	a0,a5
    8000632a:	70a2                	ld	ra,40(sp)
    8000632c:	7402                	ld	s0,32(sp)
    8000632e:	6145                	addi	sp,sp,48
    80006330:	8082                	ret

0000000080006332 <sys_close>:
{
    80006332:	1101                	addi	sp,sp,-32
    80006334:	ec06                	sd	ra,24(sp)
    80006336:	e822                	sd	s0,16(sp)
    80006338:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000633a:	fe040613          	addi	a2,s0,-32
    8000633e:	fec40593          	addi	a1,s0,-20
    80006342:	4501                	li	a0,0
    80006344:	00000097          	auipc	ra,0x0
    80006348:	cc4080e7          	jalr	-828(ra) # 80006008 <argfd>
    return -1;
    8000634c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000634e:	02054463          	bltz	a0,80006376 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80006352:	ffffb097          	auipc	ra,0xffffb
    80006356:	72a080e7          	jalr	1834(ra) # 80001a7c <myproc>
    8000635a:	fec42783          	lw	a5,-20(s0)
    8000635e:	07a9                	addi	a5,a5,10
    80006360:	078e                	slli	a5,a5,0x3
    80006362:	97aa                	add	a5,a5,a0
    80006364:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80006368:	fe043503          	ld	a0,-32(s0)
    8000636c:	fffff097          	auipc	ra,0xfffff
    80006370:	1fa080e7          	jalr	506(ra) # 80005566 <fileclose>
  return 0;
    80006374:	4781                	li	a5,0
}
    80006376:	853e                	mv	a0,a5
    80006378:	60e2                	ld	ra,24(sp)
    8000637a:	6442                	ld	s0,16(sp)
    8000637c:	6105                	addi	sp,sp,32
    8000637e:	8082                	ret

0000000080006380 <sys_fstat>:
{
    80006380:	1101                	addi	sp,sp,-32
    80006382:	ec06                	sd	ra,24(sp)
    80006384:	e822                	sd	s0,16(sp)
    80006386:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006388:	fe840613          	addi	a2,s0,-24
    8000638c:	4581                	li	a1,0
    8000638e:	4501                	li	a0,0
    80006390:	00000097          	auipc	ra,0x0
    80006394:	c78080e7          	jalr	-904(ra) # 80006008 <argfd>
    return -1;
    80006398:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000639a:	02054563          	bltz	a0,800063c4 <sys_fstat+0x44>
    8000639e:	fe040593          	addi	a1,s0,-32
    800063a2:	4505                	li	a0,1
    800063a4:	ffffd097          	auipc	ra,0xffffd
    800063a8:	5fe080e7          	jalr	1534(ra) # 800039a2 <argaddr>
    return -1;
    800063ac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800063ae:	00054b63          	bltz	a0,800063c4 <sys_fstat+0x44>
  return filestat(f, st);
    800063b2:	fe043583          	ld	a1,-32(s0)
    800063b6:	fe843503          	ld	a0,-24(s0)
    800063ba:	fffff097          	auipc	ra,0xfffff
    800063be:	274080e7          	jalr	628(ra) # 8000562e <filestat>
    800063c2:	87aa                	mv	a5,a0
}
    800063c4:	853e                	mv	a0,a5
    800063c6:	60e2                	ld	ra,24(sp)
    800063c8:	6442                	ld	s0,16(sp)
    800063ca:	6105                	addi	sp,sp,32
    800063cc:	8082                	ret

00000000800063ce <sys_link>:
{
    800063ce:	7169                	addi	sp,sp,-304
    800063d0:	f606                	sd	ra,296(sp)
    800063d2:	f222                	sd	s0,288(sp)
    800063d4:	ee26                	sd	s1,280(sp)
    800063d6:	ea4a                	sd	s2,272(sp)
    800063d8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800063da:	08000613          	li	a2,128
    800063de:	ed040593          	addi	a1,s0,-304
    800063e2:	4501                	li	a0,0
    800063e4:	ffffd097          	auipc	ra,0xffffd
    800063e8:	5e0080e7          	jalr	1504(ra) # 800039c4 <argstr>
    return -1;
    800063ec:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800063ee:	10054e63          	bltz	a0,8000650a <sys_link+0x13c>
    800063f2:	08000613          	li	a2,128
    800063f6:	f5040593          	addi	a1,s0,-176
    800063fa:	4505                	li	a0,1
    800063fc:	ffffd097          	auipc	ra,0xffffd
    80006400:	5c8080e7          	jalr	1480(ra) # 800039c4 <argstr>
    return -1;
    80006404:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006406:	10054263          	bltz	a0,8000650a <sys_link+0x13c>
  begin_op();
    8000640a:	fffff097          	auipc	ra,0xfffff
    8000640e:	c90080e7          	jalr	-880(ra) # 8000509a <begin_op>
  if((ip = namei(old)) == 0){
    80006412:	ed040513          	addi	a0,s0,-304
    80006416:	fffff097          	auipc	ra,0xfffff
    8000641a:	a64080e7          	jalr	-1436(ra) # 80004e7a <namei>
    8000641e:	84aa                	mv	s1,a0
    80006420:	c551                	beqz	a0,800064ac <sys_link+0xde>
  ilock(ip);
    80006422:	ffffe097          	auipc	ra,0xffffe
    80006426:	2a4080e7          	jalr	676(ra) # 800046c6 <ilock>
  if(ip->type == T_DIR){
    8000642a:	04449703          	lh	a4,68(s1)
    8000642e:	4785                	li	a5,1
    80006430:	08f70463          	beq	a4,a5,800064b8 <sys_link+0xea>
  ip->nlink++;
    80006434:	04a4d783          	lhu	a5,74(s1)
    80006438:	2785                	addiw	a5,a5,1
    8000643a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000643e:	8526                	mv	a0,s1
    80006440:	ffffe097          	auipc	ra,0xffffe
    80006444:	1bc080e7          	jalr	444(ra) # 800045fc <iupdate>
  iunlock(ip);
    80006448:	8526                	mv	a0,s1
    8000644a:	ffffe097          	auipc	ra,0xffffe
    8000644e:	33e080e7          	jalr	830(ra) # 80004788 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80006452:	fd040593          	addi	a1,s0,-48
    80006456:	f5040513          	addi	a0,s0,-176
    8000645a:	fffff097          	auipc	ra,0xfffff
    8000645e:	a3e080e7          	jalr	-1474(ra) # 80004e98 <nameiparent>
    80006462:	892a                	mv	s2,a0
    80006464:	c935                	beqz	a0,800064d8 <sys_link+0x10a>
  ilock(dp);
    80006466:	ffffe097          	auipc	ra,0xffffe
    8000646a:	260080e7          	jalr	608(ra) # 800046c6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000646e:	00092703          	lw	a4,0(s2)
    80006472:	409c                	lw	a5,0(s1)
    80006474:	04f71d63          	bne	a4,a5,800064ce <sys_link+0x100>
    80006478:	40d0                	lw	a2,4(s1)
    8000647a:	fd040593          	addi	a1,s0,-48
    8000647e:	854a                	mv	a0,s2
    80006480:	fffff097          	auipc	ra,0xfffff
    80006484:	938080e7          	jalr	-1736(ra) # 80004db8 <dirlink>
    80006488:	04054363          	bltz	a0,800064ce <sys_link+0x100>
  iunlockput(dp);
    8000648c:	854a                	mv	a0,s2
    8000648e:	ffffe097          	auipc	ra,0xffffe
    80006492:	49a080e7          	jalr	1178(ra) # 80004928 <iunlockput>
  iput(ip);
    80006496:	8526                	mv	a0,s1
    80006498:	ffffe097          	auipc	ra,0xffffe
    8000649c:	3e8080e7          	jalr	1000(ra) # 80004880 <iput>
  end_op();
    800064a0:	fffff097          	auipc	ra,0xfffff
    800064a4:	c7a080e7          	jalr	-902(ra) # 8000511a <end_op>
  return 0;
    800064a8:	4781                	li	a5,0
    800064aa:	a085                	j	8000650a <sys_link+0x13c>
    end_op();
    800064ac:	fffff097          	auipc	ra,0xfffff
    800064b0:	c6e080e7          	jalr	-914(ra) # 8000511a <end_op>
    return -1;
    800064b4:	57fd                	li	a5,-1
    800064b6:	a891                	j	8000650a <sys_link+0x13c>
    iunlockput(ip);
    800064b8:	8526                	mv	a0,s1
    800064ba:	ffffe097          	auipc	ra,0xffffe
    800064be:	46e080e7          	jalr	1134(ra) # 80004928 <iunlockput>
    end_op();
    800064c2:	fffff097          	auipc	ra,0xfffff
    800064c6:	c58080e7          	jalr	-936(ra) # 8000511a <end_op>
    return -1;
    800064ca:	57fd                	li	a5,-1
    800064cc:	a83d                	j	8000650a <sys_link+0x13c>
    iunlockput(dp);
    800064ce:	854a                	mv	a0,s2
    800064d0:	ffffe097          	auipc	ra,0xffffe
    800064d4:	458080e7          	jalr	1112(ra) # 80004928 <iunlockput>
  ilock(ip);
    800064d8:	8526                	mv	a0,s1
    800064da:	ffffe097          	auipc	ra,0xffffe
    800064de:	1ec080e7          	jalr	492(ra) # 800046c6 <ilock>
  ip->nlink--;
    800064e2:	04a4d783          	lhu	a5,74(s1)
    800064e6:	37fd                	addiw	a5,a5,-1
    800064e8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800064ec:	8526                	mv	a0,s1
    800064ee:	ffffe097          	auipc	ra,0xffffe
    800064f2:	10e080e7          	jalr	270(ra) # 800045fc <iupdate>
  iunlockput(ip);
    800064f6:	8526                	mv	a0,s1
    800064f8:	ffffe097          	auipc	ra,0xffffe
    800064fc:	430080e7          	jalr	1072(ra) # 80004928 <iunlockput>
  end_op();
    80006500:	fffff097          	auipc	ra,0xfffff
    80006504:	c1a080e7          	jalr	-998(ra) # 8000511a <end_op>
  return -1;
    80006508:	57fd                	li	a5,-1
}
    8000650a:	853e                	mv	a0,a5
    8000650c:	70b2                	ld	ra,296(sp)
    8000650e:	7412                	ld	s0,288(sp)
    80006510:	64f2                	ld	s1,280(sp)
    80006512:	6952                	ld	s2,272(sp)
    80006514:	6155                	addi	sp,sp,304
    80006516:	8082                	ret

0000000080006518 <sys_unlink>:
{
    80006518:	7151                	addi	sp,sp,-240
    8000651a:	f586                	sd	ra,232(sp)
    8000651c:	f1a2                	sd	s0,224(sp)
    8000651e:	eda6                	sd	s1,216(sp)
    80006520:	e9ca                	sd	s2,208(sp)
    80006522:	e5ce                	sd	s3,200(sp)
    80006524:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80006526:	08000613          	li	a2,128
    8000652a:	f3040593          	addi	a1,s0,-208
    8000652e:	4501                	li	a0,0
    80006530:	ffffd097          	auipc	ra,0xffffd
    80006534:	494080e7          	jalr	1172(ra) # 800039c4 <argstr>
    80006538:	18054163          	bltz	a0,800066ba <sys_unlink+0x1a2>
  begin_op();
    8000653c:	fffff097          	auipc	ra,0xfffff
    80006540:	b5e080e7          	jalr	-1186(ra) # 8000509a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80006544:	fb040593          	addi	a1,s0,-80
    80006548:	f3040513          	addi	a0,s0,-208
    8000654c:	fffff097          	auipc	ra,0xfffff
    80006550:	94c080e7          	jalr	-1716(ra) # 80004e98 <nameiparent>
    80006554:	84aa                	mv	s1,a0
    80006556:	c979                	beqz	a0,8000662c <sys_unlink+0x114>
  ilock(dp);
    80006558:	ffffe097          	auipc	ra,0xffffe
    8000655c:	16e080e7          	jalr	366(ra) # 800046c6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006560:	00003597          	auipc	a1,0x3
    80006564:	2d858593          	addi	a1,a1,728 # 80009838 <syscalls+0x2e8>
    80006568:	fb040513          	addi	a0,s0,-80
    8000656c:	ffffe097          	auipc	ra,0xffffe
    80006570:	624080e7          	jalr	1572(ra) # 80004b90 <namecmp>
    80006574:	14050a63          	beqz	a0,800066c8 <sys_unlink+0x1b0>
    80006578:	00003597          	auipc	a1,0x3
    8000657c:	2c858593          	addi	a1,a1,712 # 80009840 <syscalls+0x2f0>
    80006580:	fb040513          	addi	a0,s0,-80
    80006584:	ffffe097          	auipc	ra,0xffffe
    80006588:	60c080e7          	jalr	1548(ra) # 80004b90 <namecmp>
    8000658c:	12050e63          	beqz	a0,800066c8 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80006590:	f2c40613          	addi	a2,s0,-212
    80006594:	fb040593          	addi	a1,s0,-80
    80006598:	8526                	mv	a0,s1
    8000659a:	ffffe097          	auipc	ra,0xffffe
    8000659e:	610080e7          	jalr	1552(ra) # 80004baa <dirlookup>
    800065a2:	892a                	mv	s2,a0
    800065a4:	12050263          	beqz	a0,800066c8 <sys_unlink+0x1b0>
  ilock(ip);
    800065a8:	ffffe097          	auipc	ra,0xffffe
    800065ac:	11e080e7          	jalr	286(ra) # 800046c6 <ilock>
  if(ip->nlink < 1)
    800065b0:	04a91783          	lh	a5,74(s2)
    800065b4:	08f05263          	blez	a5,80006638 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800065b8:	04491703          	lh	a4,68(s2)
    800065bc:	4785                	li	a5,1
    800065be:	08f70563          	beq	a4,a5,80006648 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800065c2:	4641                	li	a2,16
    800065c4:	4581                	li	a1,0
    800065c6:	fc040513          	addi	a0,s0,-64
    800065ca:	ffffa097          	auipc	ra,0xffffa
    800065ce:	71a080e7          	jalr	1818(ra) # 80000ce4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800065d2:	4741                	li	a4,16
    800065d4:	f2c42683          	lw	a3,-212(s0)
    800065d8:	fc040613          	addi	a2,s0,-64
    800065dc:	4581                	li	a1,0
    800065de:	8526                	mv	a0,s1
    800065e0:	ffffe097          	auipc	ra,0xffffe
    800065e4:	492080e7          	jalr	1170(ra) # 80004a72 <writei>
    800065e8:	47c1                	li	a5,16
    800065ea:	0af51563          	bne	a0,a5,80006694 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800065ee:	04491703          	lh	a4,68(s2)
    800065f2:	4785                	li	a5,1
    800065f4:	0af70863          	beq	a4,a5,800066a4 <sys_unlink+0x18c>
  iunlockput(dp);
    800065f8:	8526                	mv	a0,s1
    800065fa:	ffffe097          	auipc	ra,0xffffe
    800065fe:	32e080e7          	jalr	814(ra) # 80004928 <iunlockput>
  ip->nlink--;
    80006602:	04a95783          	lhu	a5,74(s2)
    80006606:	37fd                	addiw	a5,a5,-1
    80006608:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000660c:	854a                	mv	a0,s2
    8000660e:	ffffe097          	auipc	ra,0xffffe
    80006612:	fee080e7          	jalr	-18(ra) # 800045fc <iupdate>
  iunlockput(ip);
    80006616:	854a                	mv	a0,s2
    80006618:	ffffe097          	auipc	ra,0xffffe
    8000661c:	310080e7          	jalr	784(ra) # 80004928 <iunlockput>
  end_op();
    80006620:	fffff097          	auipc	ra,0xfffff
    80006624:	afa080e7          	jalr	-1286(ra) # 8000511a <end_op>
  return 0;
    80006628:	4501                	li	a0,0
    8000662a:	a84d                	j	800066dc <sys_unlink+0x1c4>
    end_op();
    8000662c:	fffff097          	auipc	ra,0xfffff
    80006630:	aee080e7          	jalr	-1298(ra) # 8000511a <end_op>
    return -1;
    80006634:	557d                	li	a0,-1
    80006636:	a05d                	j	800066dc <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80006638:	00003517          	auipc	a0,0x3
    8000663c:	23050513          	addi	a0,a0,560 # 80009868 <syscalls+0x318>
    80006640:	ffffa097          	auipc	ra,0xffffa
    80006644:	eee080e7          	jalr	-274(ra) # 8000052e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006648:	04c92703          	lw	a4,76(s2)
    8000664c:	02000793          	li	a5,32
    80006650:	f6e7f9e3          	bgeu	a5,a4,800065c2 <sys_unlink+0xaa>
    80006654:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006658:	4741                	li	a4,16
    8000665a:	86ce                	mv	a3,s3
    8000665c:	f1840613          	addi	a2,s0,-232
    80006660:	4581                	li	a1,0
    80006662:	854a                	mv	a0,s2
    80006664:	ffffe097          	auipc	ra,0xffffe
    80006668:	316080e7          	jalr	790(ra) # 8000497a <readi>
    8000666c:	47c1                	li	a5,16
    8000666e:	00f51b63          	bne	a0,a5,80006684 <sys_unlink+0x16c>
    if(de.inum != 0)
    80006672:	f1845783          	lhu	a5,-232(s0)
    80006676:	e7a1                	bnez	a5,800066be <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006678:	29c1                	addiw	s3,s3,16
    8000667a:	04c92783          	lw	a5,76(s2)
    8000667e:	fcf9ede3          	bltu	s3,a5,80006658 <sys_unlink+0x140>
    80006682:	b781                	j	800065c2 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80006684:	00003517          	auipc	a0,0x3
    80006688:	1fc50513          	addi	a0,a0,508 # 80009880 <syscalls+0x330>
    8000668c:	ffffa097          	auipc	ra,0xffffa
    80006690:	ea2080e7          	jalr	-350(ra) # 8000052e <panic>
    panic("unlink: writei");
    80006694:	00003517          	auipc	a0,0x3
    80006698:	20450513          	addi	a0,a0,516 # 80009898 <syscalls+0x348>
    8000669c:	ffffa097          	auipc	ra,0xffffa
    800066a0:	e92080e7          	jalr	-366(ra) # 8000052e <panic>
    dp->nlink--;
    800066a4:	04a4d783          	lhu	a5,74(s1)
    800066a8:	37fd                	addiw	a5,a5,-1
    800066aa:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800066ae:	8526                	mv	a0,s1
    800066b0:	ffffe097          	auipc	ra,0xffffe
    800066b4:	f4c080e7          	jalr	-180(ra) # 800045fc <iupdate>
    800066b8:	b781                	j	800065f8 <sys_unlink+0xe0>
    return -1;
    800066ba:	557d                	li	a0,-1
    800066bc:	a005                	j	800066dc <sys_unlink+0x1c4>
    iunlockput(ip);
    800066be:	854a                	mv	a0,s2
    800066c0:	ffffe097          	auipc	ra,0xffffe
    800066c4:	268080e7          	jalr	616(ra) # 80004928 <iunlockput>
  iunlockput(dp);
    800066c8:	8526                	mv	a0,s1
    800066ca:	ffffe097          	auipc	ra,0xffffe
    800066ce:	25e080e7          	jalr	606(ra) # 80004928 <iunlockput>
  end_op();
    800066d2:	fffff097          	auipc	ra,0xfffff
    800066d6:	a48080e7          	jalr	-1464(ra) # 8000511a <end_op>
  return -1;
    800066da:	557d                	li	a0,-1
}
    800066dc:	70ae                	ld	ra,232(sp)
    800066de:	740e                	ld	s0,224(sp)
    800066e0:	64ee                	ld	s1,216(sp)
    800066e2:	694e                	ld	s2,208(sp)
    800066e4:	69ae                	ld	s3,200(sp)
    800066e6:	616d                	addi	sp,sp,240
    800066e8:	8082                	ret

00000000800066ea <sys_open>:

uint64
sys_open(void)
{
    800066ea:	7131                	addi	sp,sp,-192
    800066ec:	fd06                	sd	ra,184(sp)
    800066ee:	f922                	sd	s0,176(sp)
    800066f0:	f526                	sd	s1,168(sp)
    800066f2:	f14a                	sd	s2,160(sp)
    800066f4:	ed4e                	sd	s3,152(sp)
    800066f6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800066f8:	08000613          	li	a2,128
    800066fc:	f5040593          	addi	a1,s0,-176
    80006700:	4501                	li	a0,0
    80006702:	ffffd097          	auipc	ra,0xffffd
    80006706:	2c2080e7          	jalr	706(ra) # 800039c4 <argstr>
    return -1;
    8000670a:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000670c:	0c054163          	bltz	a0,800067ce <sys_open+0xe4>
    80006710:	f4c40593          	addi	a1,s0,-180
    80006714:	4505                	li	a0,1
    80006716:	ffffd097          	auipc	ra,0xffffd
    8000671a:	26a080e7          	jalr	618(ra) # 80003980 <argint>
    8000671e:	0a054863          	bltz	a0,800067ce <sys_open+0xe4>

  begin_op();
    80006722:	fffff097          	auipc	ra,0xfffff
    80006726:	978080e7          	jalr	-1672(ra) # 8000509a <begin_op>

  if(omode & O_CREATE){
    8000672a:	f4c42783          	lw	a5,-180(s0)
    8000672e:	2007f793          	andi	a5,a5,512
    80006732:	cbdd                	beqz	a5,800067e8 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80006734:	4681                	li	a3,0
    80006736:	4601                	li	a2,0
    80006738:	4589                	li	a1,2
    8000673a:	f5040513          	addi	a0,s0,-176
    8000673e:	00000097          	auipc	ra,0x0
    80006742:	974080e7          	jalr	-1676(ra) # 800060b2 <create>
    80006746:	892a                	mv	s2,a0
    if(ip == 0){
    80006748:	c959                	beqz	a0,800067de <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000674a:	04491703          	lh	a4,68(s2)
    8000674e:	478d                	li	a5,3
    80006750:	00f71763          	bne	a4,a5,8000675e <sys_open+0x74>
    80006754:	04695703          	lhu	a4,70(s2)
    80006758:	47a5                	li	a5,9
    8000675a:	0ce7ec63          	bltu	a5,a4,80006832 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000675e:	fffff097          	auipc	ra,0xfffff
    80006762:	d4c080e7          	jalr	-692(ra) # 800054aa <filealloc>
    80006766:	89aa                	mv	s3,a0
    80006768:	10050263          	beqz	a0,8000686c <sys_open+0x182>
    8000676c:	00000097          	auipc	ra,0x0
    80006770:	904080e7          	jalr	-1788(ra) # 80006070 <fdalloc>
    80006774:	84aa                	mv	s1,a0
    80006776:	0e054663          	bltz	a0,80006862 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000677a:	04491703          	lh	a4,68(s2)
    8000677e:	478d                	li	a5,3
    80006780:	0cf70463          	beq	a4,a5,80006848 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006784:	4789                	li	a5,2
    80006786:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000678a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000678e:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80006792:	f4c42783          	lw	a5,-180(s0)
    80006796:	0017c713          	xori	a4,a5,1
    8000679a:	8b05                	andi	a4,a4,1
    8000679c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800067a0:	0037f713          	andi	a4,a5,3
    800067a4:	00e03733          	snez	a4,a4
    800067a8:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800067ac:	4007f793          	andi	a5,a5,1024
    800067b0:	c791                	beqz	a5,800067bc <sys_open+0xd2>
    800067b2:	04491703          	lh	a4,68(s2)
    800067b6:	4789                	li	a5,2
    800067b8:	08f70f63          	beq	a4,a5,80006856 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800067bc:	854a                	mv	a0,s2
    800067be:	ffffe097          	auipc	ra,0xffffe
    800067c2:	fca080e7          	jalr	-54(ra) # 80004788 <iunlock>
  end_op();
    800067c6:	fffff097          	auipc	ra,0xfffff
    800067ca:	954080e7          	jalr	-1708(ra) # 8000511a <end_op>

  return fd;
}
    800067ce:	8526                	mv	a0,s1
    800067d0:	70ea                	ld	ra,184(sp)
    800067d2:	744a                	ld	s0,176(sp)
    800067d4:	74aa                	ld	s1,168(sp)
    800067d6:	790a                	ld	s2,160(sp)
    800067d8:	69ea                	ld	s3,152(sp)
    800067da:	6129                	addi	sp,sp,192
    800067dc:	8082                	ret
      end_op();
    800067de:	fffff097          	auipc	ra,0xfffff
    800067e2:	93c080e7          	jalr	-1732(ra) # 8000511a <end_op>
      return -1;
    800067e6:	b7e5                	j	800067ce <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800067e8:	f5040513          	addi	a0,s0,-176
    800067ec:	ffffe097          	auipc	ra,0xffffe
    800067f0:	68e080e7          	jalr	1678(ra) # 80004e7a <namei>
    800067f4:	892a                	mv	s2,a0
    800067f6:	c905                	beqz	a0,80006826 <sys_open+0x13c>
    ilock(ip);
    800067f8:	ffffe097          	auipc	ra,0xffffe
    800067fc:	ece080e7          	jalr	-306(ra) # 800046c6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006800:	04491703          	lh	a4,68(s2)
    80006804:	4785                	li	a5,1
    80006806:	f4f712e3          	bne	a4,a5,8000674a <sys_open+0x60>
    8000680a:	f4c42783          	lw	a5,-180(s0)
    8000680e:	dba1                	beqz	a5,8000675e <sys_open+0x74>
      iunlockput(ip);
    80006810:	854a                	mv	a0,s2
    80006812:	ffffe097          	auipc	ra,0xffffe
    80006816:	116080e7          	jalr	278(ra) # 80004928 <iunlockput>
      end_op();
    8000681a:	fffff097          	auipc	ra,0xfffff
    8000681e:	900080e7          	jalr	-1792(ra) # 8000511a <end_op>
      return -1;
    80006822:	54fd                	li	s1,-1
    80006824:	b76d                	j	800067ce <sys_open+0xe4>
      end_op();
    80006826:	fffff097          	auipc	ra,0xfffff
    8000682a:	8f4080e7          	jalr	-1804(ra) # 8000511a <end_op>
      return -1;
    8000682e:	54fd                	li	s1,-1
    80006830:	bf79                	j	800067ce <sys_open+0xe4>
    iunlockput(ip);
    80006832:	854a                	mv	a0,s2
    80006834:	ffffe097          	auipc	ra,0xffffe
    80006838:	0f4080e7          	jalr	244(ra) # 80004928 <iunlockput>
    end_op();
    8000683c:	fffff097          	auipc	ra,0xfffff
    80006840:	8de080e7          	jalr	-1826(ra) # 8000511a <end_op>
    return -1;
    80006844:	54fd                	li	s1,-1
    80006846:	b761                	j	800067ce <sys_open+0xe4>
    f->type = FD_DEVICE;
    80006848:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000684c:	04691783          	lh	a5,70(s2)
    80006850:	02f99223          	sh	a5,36(s3)
    80006854:	bf2d                	j	8000678e <sys_open+0xa4>
    itrunc(ip);
    80006856:	854a                	mv	a0,s2
    80006858:	ffffe097          	auipc	ra,0xffffe
    8000685c:	f7c080e7          	jalr	-132(ra) # 800047d4 <itrunc>
    80006860:	bfb1                	j	800067bc <sys_open+0xd2>
      fileclose(f);
    80006862:	854e                	mv	a0,s3
    80006864:	fffff097          	auipc	ra,0xfffff
    80006868:	d02080e7          	jalr	-766(ra) # 80005566 <fileclose>
    iunlockput(ip);
    8000686c:	854a                	mv	a0,s2
    8000686e:	ffffe097          	auipc	ra,0xffffe
    80006872:	0ba080e7          	jalr	186(ra) # 80004928 <iunlockput>
    end_op();
    80006876:	fffff097          	auipc	ra,0xfffff
    8000687a:	8a4080e7          	jalr	-1884(ra) # 8000511a <end_op>
    return -1;
    8000687e:	54fd                	li	s1,-1
    80006880:	b7b9                	j	800067ce <sys_open+0xe4>

0000000080006882 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006882:	7175                	addi	sp,sp,-144
    80006884:	e506                	sd	ra,136(sp)
    80006886:	e122                	sd	s0,128(sp)
    80006888:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000688a:	fffff097          	auipc	ra,0xfffff
    8000688e:	810080e7          	jalr	-2032(ra) # 8000509a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006892:	08000613          	li	a2,128
    80006896:	f7040593          	addi	a1,s0,-144
    8000689a:	4501                	li	a0,0
    8000689c:	ffffd097          	auipc	ra,0xffffd
    800068a0:	128080e7          	jalr	296(ra) # 800039c4 <argstr>
    800068a4:	02054963          	bltz	a0,800068d6 <sys_mkdir+0x54>
    800068a8:	4681                	li	a3,0
    800068aa:	4601                	li	a2,0
    800068ac:	4585                	li	a1,1
    800068ae:	f7040513          	addi	a0,s0,-144
    800068b2:	00000097          	auipc	ra,0x0
    800068b6:	800080e7          	jalr	-2048(ra) # 800060b2 <create>
    800068ba:	cd11                	beqz	a0,800068d6 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800068bc:	ffffe097          	auipc	ra,0xffffe
    800068c0:	06c080e7          	jalr	108(ra) # 80004928 <iunlockput>
  end_op();
    800068c4:	fffff097          	auipc	ra,0xfffff
    800068c8:	856080e7          	jalr	-1962(ra) # 8000511a <end_op>
  return 0;
    800068cc:	4501                	li	a0,0
}
    800068ce:	60aa                	ld	ra,136(sp)
    800068d0:	640a                	ld	s0,128(sp)
    800068d2:	6149                	addi	sp,sp,144
    800068d4:	8082                	ret
    end_op();
    800068d6:	fffff097          	auipc	ra,0xfffff
    800068da:	844080e7          	jalr	-1980(ra) # 8000511a <end_op>
    return -1;
    800068de:	557d                	li	a0,-1
    800068e0:	b7fd                	j	800068ce <sys_mkdir+0x4c>

00000000800068e2 <sys_mknod>:

uint64
sys_mknod(void)
{
    800068e2:	7135                	addi	sp,sp,-160
    800068e4:	ed06                	sd	ra,152(sp)
    800068e6:	e922                	sd	s0,144(sp)
    800068e8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800068ea:	ffffe097          	auipc	ra,0xffffe
    800068ee:	7b0080e7          	jalr	1968(ra) # 8000509a <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800068f2:	08000613          	li	a2,128
    800068f6:	f7040593          	addi	a1,s0,-144
    800068fa:	4501                	li	a0,0
    800068fc:	ffffd097          	auipc	ra,0xffffd
    80006900:	0c8080e7          	jalr	200(ra) # 800039c4 <argstr>
    80006904:	04054a63          	bltz	a0,80006958 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80006908:	f6c40593          	addi	a1,s0,-148
    8000690c:	4505                	li	a0,1
    8000690e:	ffffd097          	auipc	ra,0xffffd
    80006912:	072080e7          	jalr	114(ra) # 80003980 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006916:	04054163          	bltz	a0,80006958 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000691a:	f6840593          	addi	a1,s0,-152
    8000691e:	4509                	li	a0,2
    80006920:	ffffd097          	auipc	ra,0xffffd
    80006924:	060080e7          	jalr	96(ra) # 80003980 <argint>
     argint(1, &major) < 0 ||
    80006928:	02054863          	bltz	a0,80006958 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000692c:	f6841683          	lh	a3,-152(s0)
    80006930:	f6c41603          	lh	a2,-148(s0)
    80006934:	458d                	li	a1,3
    80006936:	f7040513          	addi	a0,s0,-144
    8000693a:	fffff097          	auipc	ra,0xfffff
    8000693e:	778080e7          	jalr	1912(ra) # 800060b2 <create>
     argint(2, &minor) < 0 ||
    80006942:	c919                	beqz	a0,80006958 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006944:	ffffe097          	auipc	ra,0xffffe
    80006948:	fe4080e7          	jalr	-28(ra) # 80004928 <iunlockput>
  end_op();
    8000694c:	ffffe097          	auipc	ra,0xffffe
    80006950:	7ce080e7          	jalr	1998(ra) # 8000511a <end_op>
  return 0;
    80006954:	4501                	li	a0,0
    80006956:	a031                	j	80006962 <sys_mknod+0x80>
    end_op();
    80006958:	ffffe097          	auipc	ra,0xffffe
    8000695c:	7c2080e7          	jalr	1986(ra) # 8000511a <end_op>
    return -1;
    80006960:	557d                	li	a0,-1
}
    80006962:	60ea                	ld	ra,152(sp)
    80006964:	644a                	ld	s0,144(sp)
    80006966:	610d                	addi	sp,sp,160
    80006968:	8082                	ret

000000008000696a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000696a:	7135                	addi	sp,sp,-160
    8000696c:	ed06                	sd	ra,152(sp)
    8000696e:	e922                	sd	s0,144(sp)
    80006970:	e526                	sd	s1,136(sp)
    80006972:	e14a                	sd	s2,128(sp)
    80006974:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006976:	ffffb097          	auipc	ra,0xffffb
    8000697a:	106080e7          	jalr	262(ra) # 80001a7c <myproc>
    8000697e:	892a                	mv	s2,a0
  
  begin_op();
    80006980:	ffffe097          	auipc	ra,0xffffe
    80006984:	71a080e7          	jalr	1818(ra) # 8000509a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006988:	08000613          	li	a2,128
    8000698c:	f6040593          	addi	a1,s0,-160
    80006990:	4501                	li	a0,0
    80006992:	ffffd097          	auipc	ra,0xffffd
    80006996:	032080e7          	jalr	50(ra) # 800039c4 <argstr>
    8000699a:	04054b63          	bltz	a0,800069f0 <sys_chdir+0x86>
    8000699e:	f6040513          	addi	a0,s0,-160
    800069a2:	ffffe097          	auipc	ra,0xffffe
    800069a6:	4d8080e7          	jalr	1240(ra) # 80004e7a <namei>
    800069aa:	84aa                	mv	s1,a0
    800069ac:	c131                	beqz	a0,800069f0 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800069ae:	ffffe097          	auipc	ra,0xffffe
    800069b2:	d18080e7          	jalr	-744(ra) # 800046c6 <ilock>
  if(ip->type != T_DIR){
    800069b6:	04449703          	lh	a4,68(s1)
    800069ba:	4785                	li	a5,1
    800069bc:	04f71063          	bne	a4,a5,800069fc <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800069c0:	8526                	mv	a0,s1
    800069c2:	ffffe097          	auipc	ra,0xffffe
    800069c6:	dc6080e7          	jalr	-570(ra) # 80004788 <iunlock>
  iput(p->cwd);
    800069ca:	0d093503          	ld	a0,208(s2)
    800069ce:	ffffe097          	auipc	ra,0xffffe
    800069d2:	eb2080e7          	jalr	-334(ra) # 80004880 <iput>
  end_op();
    800069d6:	ffffe097          	auipc	ra,0xffffe
    800069da:	744080e7          	jalr	1860(ra) # 8000511a <end_op>
  p->cwd = ip;
    800069de:	0c993823          	sd	s1,208(s2)
  return 0;
    800069e2:	4501                	li	a0,0
}
    800069e4:	60ea                	ld	ra,152(sp)
    800069e6:	644a                	ld	s0,144(sp)
    800069e8:	64aa                	ld	s1,136(sp)
    800069ea:	690a                	ld	s2,128(sp)
    800069ec:	610d                	addi	sp,sp,160
    800069ee:	8082                	ret
    end_op();
    800069f0:	ffffe097          	auipc	ra,0xffffe
    800069f4:	72a080e7          	jalr	1834(ra) # 8000511a <end_op>
    return -1;
    800069f8:	557d                	li	a0,-1
    800069fa:	b7ed                	j	800069e4 <sys_chdir+0x7a>
    iunlockput(ip);
    800069fc:	8526                	mv	a0,s1
    800069fe:	ffffe097          	auipc	ra,0xffffe
    80006a02:	f2a080e7          	jalr	-214(ra) # 80004928 <iunlockput>
    end_op();
    80006a06:	ffffe097          	auipc	ra,0xffffe
    80006a0a:	714080e7          	jalr	1812(ra) # 8000511a <end_op>
    return -1;
    80006a0e:	557d                	li	a0,-1
    80006a10:	bfd1                	j	800069e4 <sys_chdir+0x7a>

0000000080006a12 <sys_exec>:

uint64
sys_exec(void)
{
    80006a12:	7145                	addi	sp,sp,-464
    80006a14:	e786                	sd	ra,456(sp)
    80006a16:	e3a2                	sd	s0,448(sp)
    80006a18:	ff26                	sd	s1,440(sp)
    80006a1a:	fb4a                	sd	s2,432(sp)
    80006a1c:	f74e                	sd	s3,424(sp)
    80006a1e:	f352                	sd	s4,416(sp)
    80006a20:	ef56                	sd	s5,408(sp)
    80006a22:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006a24:	08000613          	li	a2,128
    80006a28:	f4040593          	addi	a1,s0,-192
    80006a2c:	4501                	li	a0,0
    80006a2e:	ffffd097          	auipc	ra,0xffffd
    80006a32:	f96080e7          	jalr	-106(ra) # 800039c4 <argstr>
    return -1;
    80006a36:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006a38:	0c054a63          	bltz	a0,80006b0c <sys_exec+0xfa>
    80006a3c:	e3840593          	addi	a1,s0,-456
    80006a40:	4505                	li	a0,1
    80006a42:	ffffd097          	auipc	ra,0xffffd
    80006a46:	f60080e7          	jalr	-160(ra) # 800039a2 <argaddr>
    80006a4a:	0c054163          	bltz	a0,80006b0c <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006a4e:	10000613          	li	a2,256
    80006a52:	4581                	li	a1,0
    80006a54:	e4040513          	addi	a0,s0,-448
    80006a58:	ffffa097          	auipc	ra,0xffffa
    80006a5c:	28c080e7          	jalr	652(ra) # 80000ce4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006a60:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006a64:	89a6                	mv	s3,s1
    80006a66:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006a68:	02000a13          	li	s4,32
    80006a6c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006a70:	00391793          	slli	a5,s2,0x3
    80006a74:	e3040593          	addi	a1,s0,-464
    80006a78:	e3843503          	ld	a0,-456(s0)
    80006a7c:	953e                	add	a0,a0,a5
    80006a7e:	ffffd097          	auipc	ra,0xffffd
    80006a82:	e68080e7          	jalr	-408(ra) # 800038e6 <fetchaddr>
    80006a86:	02054a63          	bltz	a0,80006aba <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006a8a:	e3043783          	ld	a5,-464(s0)
    80006a8e:	c3b9                	beqz	a5,80006ad4 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006a90:	ffffa097          	auipc	ra,0xffffa
    80006a94:	046080e7          	jalr	70(ra) # 80000ad6 <kalloc>
    80006a98:	85aa                	mv	a1,a0
    80006a9a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006a9e:	cd11                	beqz	a0,80006aba <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006aa0:	6605                	lui	a2,0x1
    80006aa2:	e3043503          	ld	a0,-464(s0)
    80006aa6:	ffffd097          	auipc	ra,0xffffd
    80006aaa:	e92080e7          	jalr	-366(ra) # 80003938 <fetchstr>
    80006aae:	00054663          	bltz	a0,80006aba <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006ab2:	0905                	addi	s2,s2,1
    80006ab4:	09a1                	addi	s3,s3,8
    80006ab6:	fb491be3          	bne	s2,s4,80006a6c <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006aba:	10048913          	addi	s2,s1,256
    80006abe:	6088                	ld	a0,0(s1)
    80006ac0:	c529                	beqz	a0,80006b0a <sys_exec+0xf8>
    kfree(argv[i]);
    80006ac2:	ffffa097          	auipc	ra,0xffffa
    80006ac6:	f18080e7          	jalr	-232(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006aca:	04a1                	addi	s1,s1,8
    80006acc:	ff2499e3          	bne	s1,s2,80006abe <sys_exec+0xac>
  return -1;
    80006ad0:	597d                	li	s2,-1
    80006ad2:	a82d                	j	80006b0c <sys_exec+0xfa>
      argv[i] = 0;
    80006ad4:	0a8e                	slli	s5,s5,0x3
    80006ad6:	fc040793          	addi	a5,s0,-64
    80006ada:	9abe                	add	s5,s5,a5
    80006adc:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006ae0:	e4040593          	addi	a1,s0,-448
    80006ae4:	f4040513          	addi	a0,s0,-192
    80006ae8:	fffff097          	auipc	ra,0xfffff
    80006aec:	0dc080e7          	jalr	220(ra) # 80005bc4 <exec>
    80006af0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006af2:	10048993          	addi	s3,s1,256
    80006af6:	6088                	ld	a0,0(s1)
    80006af8:	c911                	beqz	a0,80006b0c <sys_exec+0xfa>
    kfree(argv[i]);
    80006afa:	ffffa097          	auipc	ra,0xffffa
    80006afe:	ee0080e7          	jalr	-288(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006b02:	04a1                	addi	s1,s1,8
    80006b04:	ff3499e3          	bne	s1,s3,80006af6 <sys_exec+0xe4>
    80006b08:	a011                	j	80006b0c <sys_exec+0xfa>
  return -1;
    80006b0a:	597d                	li	s2,-1
}
    80006b0c:	854a                	mv	a0,s2
    80006b0e:	60be                	ld	ra,456(sp)
    80006b10:	641e                	ld	s0,448(sp)
    80006b12:	74fa                	ld	s1,440(sp)
    80006b14:	795a                	ld	s2,432(sp)
    80006b16:	79ba                	ld	s3,424(sp)
    80006b18:	7a1a                	ld	s4,416(sp)
    80006b1a:	6afa                	ld	s5,408(sp)
    80006b1c:	6179                	addi	sp,sp,464
    80006b1e:	8082                	ret

0000000080006b20 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006b20:	7139                	addi	sp,sp,-64
    80006b22:	fc06                	sd	ra,56(sp)
    80006b24:	f822                	sd	s0,48(sp)
    80006b26:	f426                	sd	s1,40(sp)
    80006b28:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006b2a:	ffffb097          	auipc	ra,0xffffb
    80006b2e:	f52080e7          	jalr	-174(ra) # 80001a7c <myproc>
    80006b32:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006b34:	fd840593          	addi	a1,s0,-40
    80006b38:	4501                	li	a0,0
    80006b3a:	ffffd097          	auipc	ra,0xffffd
    80006b3e:	e68080e7          	jalr	-408(ra) # 800039a2 <argaddr>
    return -1;
    80006b42:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006b44:	0e054063          	bltz	a0,80006c24 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006b48:	fc840593          	addi	a1,s0,-56
    80006b4c:	fd040513          	addi	a0,s0,-48
    80006b50:	fffff097          	auipc	ra,0xfffff
    80006b54:	d46080e7          	jalr	-698(ra) # 80005896 <pipealloc>
    return -1;
    80006b58:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006b5a:	0c054563          	bltz	a0,80006c24 <sys_pipe+0x104>
  fd0 = -1;
    80006b5e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006b62:	fd043503          	ld	a0,-48(s0)
    80006b66:	fffff097          	auipc	ra,0xfffff
    80006b6a:	50a080e7          	jalr	1290(ra) # 80006070 <fdalloc>
    80006b6e:	fca42223          	sw	a0,-60(s0)
    80006b72:	08054c63          	bltz	a0,80006c0a <sys_pipe+0xea>
    80006b76:	fc843503          	ld	a0,-56(s0)
    80006b7a:	fffff097          	auipc	ra,0xfffff
    80006b7e:	4f6080e7          	jalr	1270(ra) # 80006070 <fdalloc>
    80006b82:	fca42023          	sw	a0,-64(s0)
    80006b86:	06054863          	bltz	a0,80006bf6 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006b8a:	4691                	li	a3,4
    80006b8c:	fc440613          	addi	a2,s0,-60
    80006b90:	fd843583          	ld	a1,-40(s0)
    80006b94:	60a8                	ld	a0,64(s1)
    80006b96:	ffffb097          	auipc	ra,0xffffb
    80006b9a:	ace080e7          	jalr	-1330(ra) # 80001664 <copyout>
    80006b9e:	02054063          	bltz	a0,80006bbe <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006ba2:	4691                	li	a3,4
    80006ba4:	fc040613          	addi	a2,s0,-64
    80006ba8:	fd843583          	ld	a1,-40(s0)
    80006bac:	0591                	addi	a1,a1,4
    80006bae:	60a8                	ld	a0,64(s1)
    80006bb0:	ffffb097          	auipc	ra,0xffffb
    80006bb4:	ab4080e7          	jalr	-1356(ra) # 80001664 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006bb8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006bba:	06055563          	bgez	a0,80006c24 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006bbe:	fc442783          	lw	a5,-60(s0)
    80006bc2:	07a9                	addi	a5,a5,10
    80006bc4:	078e                	slli	a5,a5,0x3
    80006bc6:	97a6                	add	a5,a5,s1
    80006bc8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006bcc:	fc042503          	lw	a0,-64(s0)
    80006bd0:	0529                	addi	a0,a0,10
    80006bd2:	050e                	slli	a0,a0,0x3
    80006bd4:	9526                	add	a0,a0,s1
    80006bd6:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006bda:	fd043503          	ld	a0,-48(s0)
    80006bde:	fffff097          	auipc	ra,0xfffff
    80006be2:	988080e7          	jalr	-1656(ra) # 80005566 <fileclose>
    fileclose(wf);
    80006be6:	fc843503          	ld	a0,-56(s0)
    80006bea:	fffff097          	auipc	ra,0xfffff
    80006bee:	97c080e7          	jalr	-1668(ra) # 80005566 <fileclose>
    return -1;
    80006bf2:	57fd                	li	a5,-1
    80006bf4:	a805                	j	80006c24 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006bf6:	fc442783          	lw	a5,-60(s0)
    80006bfa:	0007c863          	bltz	a5,80006c0a <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006bfe:	00a78513          	addi	a0,a5,10
    80006c02:	050e                	slli	a0,a0,0x3
    80006c04:	9526                	add	a0,a0,s1
    80006c06:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006c0a:	fd043503          	ld	a0,-48(s0)
    80006c0e:	fffff097          	auipc	ra,0xfffff
    80006c12:	958080e7          	jalr	-1704(ra) # 80005566 <fileclose>
    fileclose(wf);
    80006c16:	fc843503          	ld	a0,-56(s0)
    80006c1a:	fffff097          	auipc	ra,0xfffff
    80006c1e:	94c080e7          	jalr	-1716(ra) # 80005566 <fileclose>
    return -1;
    80006c22:	57fd                	li	a5,-1
}
    80006c24:	853e                	mv	a0,a5
    80006c26:	70e2                	ld	ra,56(sp)
    80006c28:	7442                	ld	s0,48(sp)
    80006c2a:	74a2                	ld	s1,40(sp)
    80006c2c:	6121                	addi	sp,sp,64
    80006c2e:	8082                	ret

0000000080006c30 <kernelvec>:
    80006c30:	7111                	addi	sp,sp,-256
    80006c32:	e006                	sd	ra,0(sp)
    80006c34:	e40a                	sd	sp,8(sp)
    80006c36:	e80e                	sd	gp,16(sp)
    80006c38:	ec12                	sd	tp,24(sp)
    80006c3a:	f016                	sd	t0,32(sp)
    80006c3c:	f41a                	sd	t1,40(sp)
    80006c3e:	f81e                	sd	t2,48(sp)
    80006c40:	fc22                	sd	s0,56(sp)
    80006c42:	e0a6                	sd	s1,64(sp)
    80006c44:	e4aa                	sd	a0,72(sp)
    80006c46:	e8ae                	sd	a1,80(sp)
    80006c48:	ecb2                	sd	a2,88(sp)
    80006c4a:	f0b6                	sd	a3,96(sp)
    80006c4c:	f4ba                	sd	a4,104(sp)
    80006c4e:	f8be                	sd	a5,112(sp)
    80006c50:	fcc2                	sd	a6,120(sp)
    80006c52:	e146                	sd	a7,128(sp)
    80006c54:	e54a                	sd	s2,136(sp)
    80006c56:	e94e                	sd	s3,144(sp)
    80006c58:	ed52                	sd	s4,152(sp)
    80006c5a:	f156                	sd	s5,160(sp)
    80006c5c:	f55a                	sd	s6,168(sp)
    80006c5e:	f95e                	sd	s7,176(sp)
    80006c60:	fd62                	sd	s8,184(sp)
    80006c62:	e1e6                	sd	s9,192(sp)
    80006c64:	e5ea                	sd	s10,200(sp)
    80006c66:	e9ee                	sd	s11,208(sp)
    80006c68:	edf2                	sd	t3,216(sp)
    80006c6a:	f1f6                	sd	t4,224(sp)
    80006c6c:	f5fa                	sd	t5,232(sp)
    80006c6e:	f9fe                	sd	t6,240(sp)
    80006c70:	b17fc0ef          	jal	ra,80003786 <kerneltrap>
    80006c74:	6082                	ld	ra,0(sp)
    80006c76:	6122                	ld	sp,8(sp)
    80006c78:	61c2                	ld	gp,16(sp)
    80006c7a:	7282                	ld	t0,32(sp)
    80006c7c:	7322                	ld	t1,40(sp)
    80006c7e:	73c2                	ld	t2,48(sp)
    80006c80:	7462                	ld	s0,56(sp)
    80006c82:	6486                	ld	s1,64(sp)
    80006c84:	6526                	ld	a0,72(sp)
    80006c86:	65c6                	ld	a1,80(sp)
    80006c88:	6666                	ld	a2,88(sp)
    80006c8a:	7686                	ld	a3,96(sp)
    80006c8c:	7726                	ld	a4,104(sp)
    80006c8e:	77c6                	ld	a5,112(sp)
    80006c90:	7866                	ld	a6,120(sp)
    80006c92:	688a                	ld	a7,128(sp)
    80006c94:	692a                	ld	s2,136(sp)
    80006c96:	69ca                	ld	s3,144(sp)
    80006c98:	6a6a                	ld	s4,152(sp)
    80006c9a:	7a8a                	ld	s5,160(sp)
    80006c9c:	7b2a                	ld	s6,168(sp)
    80006c9e:	7bca                	ld	s7,176(sp)
    80006ca0:	7c6a                	ld	s8,184(sp)
    80006ca2:	6c8e                	ld	s9,192(sp)
    80006ca4:	6d2e                	ld	s10,200(sp)
    80006ca6:	6dce                	ld	s11,208(sp)
    80006ca8:	6e6e                	ld	t3,216(sp)
    80006caa:	7e8e                	ld	t4,224(sp)
    80006cac:	7f2e                	ld	t5,232(sp)
    80006cae:	7fce                	ld	t6,240(sp)
    80006cb0:	6111                	addi	sp,sp,256
    80006cb2:	10200073          	sret
    80006cb6:	00000013          	nop
    80006cba:	00000013          	nop
    80006cbe:	0001                	nop

0000000080006cc0 <timervec>:
    80006cc0:	34051573          	csrrw	a0,mscratch,a0
    80006cc4:	e10c                	sd	a1,0(a0)
    80006cc6:	e510                	sd	a2,8(a0)
    80006cc8:	e914                	sd	a3,16(a0)
    80006cca:	6d0c                	ld	a1,24(a0)
    80006ccc:	7110                	ld	a2,32(a0)
    80006cce:	6194                	ld	a3,0(a1)
    80006cd0:	96b2                	add	a3,a3,a2
    80006cd2:	e194                	sd	a3,0(a1)
    80006cd4:	4589                	li	a1,2
    80006cd6:	14459073          	csrw	sip,a1
    80006cda:	6914                	ld	a3,16(a0)
    80006cdc:	6510                	ld	a2,8(a0)
    80006cde:	610c                	ld	a1,0(a0)
    80006ce0:	34051573          	csrrw	a0,mscratch,a0
    80006ce4:	30200073          	mret
	...

0000000080006cea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006cea:	1141                	addi	sp,sp,-16
    80006cec:	e422                	sd	s0,8(sp)
    80006cee:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006cf0:	0c0007b7          	lui	a5,0xc000
    80006cf4:	4705                	li	a4,1
    80006cf6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006cf8:	c3d8                	sw	a4,4(a5)
}
    80006cfa:	6422                	ld	s0,8(sp)
    80006cfc:	0141                	addi	sp,sp,16
    80006cfe:	8082                	ret

0000000080006d00 <plicinithart>:

void
plicinithart(void)
{
    80006d00:	1141                	addi	sp,sp,-16
    80006d02:	e406                	sd	ra,8(sp)
    80006d04:	e022                	sd	s0,0(sp)
    80006d06:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006d08:	ffffb097          	auipc	ra,0xffffb
    80006d0c:	d40080e7          	jalr	-704(ra) # 80001a48 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006d10:	0085171b          	slliw	a4,a0,0x8
    80006d14:	0c0027b7          	lui	a5,0xc002
    80006d18:	97ba                	add	a5,a5,a4
    80006d1a:	40200713          	li	a4,1026
    80006d1e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006d22:	00d5151b          	slliw	a0,a0,0xd
    80006d26:	0c2017b7          	lui	a5,0xc201
    80006d2a:	953e                	add	a0,a0,a5
    80006d2c:	00052023          	sw	zero,0(a0)
}
    80006d30:	60a2                	ld	ra,8(sp)
    80006d32:	6402                	ld	s0,0(sp)
    80006d34:	0141                	addi	sp,sp,16
    80006d36:	8082                	ret

0000000080006d38 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006d38:	1141                	addi	sp,sp,-16
    80006d3a:	e406                	sd	ra,8(sp)
    80006d3c:	e022                	sd	s0,0(sp)
    80006d3e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006d40:	ffffb097          	auipc	ra,0xffffb
    80006d44:	d08080e7          	jalr	-760(ra) # 80001a48 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006d48:	00d5179b          	slliw	a5,a0,0xd
    80006d4c:	0c201537          	lui	a0,0xc201
    80006d50:	953e                	add	a0,a0,a5
  return irq;
}
    80006d52:	4148                	lw	a0,4(a0)
    80006d54:	60a2                	ld	ra,8(sp)
    80006d56:	6402                	ld	s0,0(sp)
    80006d58:	0141                	addi	sp,sp,16
    80006d5a:	8082                	ret

0000000080006d5c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006d5c:	1101                	addi	sp,sp,-32
    80006d5e:	ec06                	sd	ra,24(sp)
    80006d60:	e822                	sd	s0,16(sp)
    80006d62:	e426                	sd	s1,8(sp)
    80006d64:	1000                	addi	s0,sp,32
    80006d66:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006d68:	ffffb097          	auipc	ra,0xffffb
    80006d6c:	ce0080e7          	jalr	-800(ra) # 80001a48 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006d70:	00d5151b          	slliw	a0,a0,0xd
    80006d74:	0c2017b7          	lui	a5,0xc201
    80006d78:	97aa                	add	a5,a5,a0
    80006d7a:	c3c4                	sw	s1,4(a5)
}
    80006d7c:	60e2                	ld	ra,24(sp)
    80006d7e:	6442                	ld	s0,16(sp)
    80006d80:	64a2                	ld	s1,8(sp)
    80006d82:	6105                	addi	sp,sp,32
    80006d84:	8082                	ret

0000000080006d86 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006d86:	1141                	addi	sp,sp,-16
    80006d88:	e406                	sd	ra,8(sp)
    80006d8a:	e022                	sd	s0,0(sp)
    80006d8c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006d8e:	479d                	li	a5,7
    80006d90:	06a7c963          	blt	a5,a0,80006e02 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006d94:	00038797          	auipc	a5,0x38
    80006d98:	26c78793          	addi	a5,a5,620 # 8003f000 <disk>
    80006d9c:	00a78733          	add	a4,a5,a0
    80006da0:	6789                	lui	a5,0x2
    80006da2:	97ba                	add	a5,a5,a4
    80006da4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006da8:	e7ad                	bnez	a5,80006e12 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006daa:	00451793          	slli	a5,a0,0x4
    80006dae:	0003a717          	auipc	a4,0x3a
    80006db2:	25270713          	addi	a4,a4,594 # 80041000 <disk+0x2000>
    80006db6:	6314                	ld	a3,0(a4)
    80006db8:	96be                	add	a3,a3,a5
    80006dba:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006dbe:	6314                	ld	a3,0(a4)
    80006dc0:	96be                	add	a3,a3,a5
    80006dc2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006dc6:	6314                	ld	a3,0(a4)
    80006dc8:	96be                	add	a3,a3,a5
    80006dca:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006dce:	6318                	ld	a4,0(a4)
    80006dd0:	97ba                	add	a5,a5,a4
    80006dd2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006dd6:	00038797          	auipc	a5,0x38
    80006dda:	22a78793          	addi	a5,a5,554 # 8003f000 <disk>
    80006dde:	97aa                	add	a5,a5,a0
    80006de0:	6509                	lui	a0,0x2
    80006de2:	953e                	add	a0,a0,a5
    80006de4:	4785                	li	a5,1
    80006de6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006dea:	0003a517          	auipc	a0,0x3a
    80006dee:	22e50513          	addi	a0,a0,558 # 80041018 <disk+0x2018>
    80006df2:	ffffb097          	auipc	ra,0xffffb
    80006df6:	75a080e7          	jalr	1882(ra) # 8000254c <wakeup>
}
    80006dfa:	60a2                	ld	ra,8(sp)
    80006dfc:	6402                	ld	s0,0(sp)
    80006dfe:	0141                	addi	sp,sp,16
    80006e00:	8082                	ret
    panic("free_desc 1");
    80006e02:	00003517          	auipc	a0,0x3
    80006e06:	aa650513          	addi	a0,a0,-1370 # 800098a8 <syscalls+0x358>
    80006e0a:	ffff9097          	auipc	ra,0xffff9
    80006e0e:	724080e7          	jalr	1828(ra) # 8000052e <panic>
    panic("free_desc 2");
    80006e12:	00003517          	auipc	a0,0x3
    80006e16:	aa650513          	addi	a0,a0,-1370 # 800098b8 <syscalls+0x368>
    80006e1a:	ffff9097          	auipc	ra,0xffff9
    80006e1e:	714080e7          	jalr	1812(ra) # 8000052e <panic>

0000000080006e22 <virtio_disk_init>:
{
    80006e22:	1101                	addi	sp,sp,-32
    80006e24:	ec06                	sd	ra,24(sp)
    80006e26:	e822                	sd	s0,16(sp)
    80006e28:	e426                	sd	s1,8(sp)
    80006e2a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006e2c:	00003597          	auipc	a1,0x3
    80006e30:	a9c58593          	addi	a1,a1,-1380 # 800098c8 <syscalls+0x378>
    80006e34:	0003a517          	auipc	a0,0x3a
    80006e38:	2f450513          	addi	a0,a0,756 # 80041128 <disk+0x2128>
    80006e3c:	ffffa097          	auipc	ra,0xffffa
    80006e40:	cfa080e7          	jalr	-774(ra) # 80000b36 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006e44:	100017b7          	lui	a5,0x10001
    80006e48:	4398                	lw	a4,0(a5)
    80006e4a:	2701                	sext.w	a4,a4
    80006e4c:	747277b7          	lui	a5,0x74727
    80006e50:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006e54:	0ef71163          	bne	a4,a5,80006f36 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006e58:	100017b7          	lui	a5,0x10001
    80006e5c:	43dc                	lw	a5,4(a5)
    80006e5e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006e60:	4705                	li	a4,1
    80006e62:	0ce79a63          	bne	a5,a4,80006f36 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006e66:	100017b7          	lui	a5,0x10001
    80006e6a:	479c                	lw	a5,8(a5)
    80006e6c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006e6e:	4709                	li	a4,2
    80006e70:	0ce79363          	bne	a5,a4,80006f36 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006e74:	100017b7          	lui	a5,0x10001
    80006e78:	47d8                	lw	a4,12(a5)
    80006e7a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006e7c:	554d47b7          	lui	a5,0x554d4
    80006e80:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006e84:	0af71963          	bne	a4,a5,80006f36 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006e88:	100017b7          	lui	a5,0x10001
    80006e8c:	4705                	li	a4,1
    80006e8e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006e90:	470d                	li	a4,3
    80006e92:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006e94:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006e96:	c7ffe737          	lui	a4,0xc7ffe
    80006e9a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fbc75f>
    80006e9e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006ea0:	2701                	sext.w	a4,a4
    80006ea2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006ea4:	472d                	li	a4,11
    80006ea6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006ea8:	473d                	li	a4,15
    80006eaa:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006eac:	6705                	lui	a4,0x1
    80006eae:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006eb0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006eb4:	5bdc                	lw	a5,52(a5)
    80006eb6:	2781                	sext.w	a5,a5
  if(max == 0)
    80006eb8:	c7d9                	beqz	a5,80006f46 <virtio_disk_init+0x124>
  if(max < NUM)
    80006eba:	471d                	li	a4,7
    80006ebc:	08f77d63          	bgeu	a4,a5,80006f56 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006ec0:	100014b7          	lui	s1,0x10001
    80006ec4:	47a1                	li	a5,8
    80006ec6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006ec8:	6609                	lui	a2,0x2
    80006eca:	4581                	li	a1,0
    80006ecc:	00038517          	auipc	a0,0x38
    80006ed0:	13450513          	addi	a0,a0,308 # 8003f000 <disk>
    80006ed4:	ffffa097          	auipc	ra,0xffffa
    80006ed8:	e10080e7          	jalr	-496(ra) # 80000ce4 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006edc:	00038717          	auipc	a4,0x38
    80006ee0:	12470713          	addi	a4,a4,292 # 8003f000 <disk>
    80006ee4:	00c75793          	srli	a5,a4,0xc
    80006ee8:	2781                	sext.w	a5,a5
    80006eea:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006eec:	0003a797          	auipc	a5,0x3a
    80006ef0:	11478793          	addi	a5,a5,276 # 80041000 <disk+0x2000>
    80006ef4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006ef6:	00038717          	auipc	a4,0x38
    80006efa:	18a70713          	addi	a4,a4,394 # 8003f080 <disk+0x80>
    80006efe:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006f00:	00039717          	auipc	a4,0x39
    80006f04:	10070713          	addi	a4,a4,256 # 80040000 <disk+0x1000>
    80006f08:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006f0a:	4705                	li	a4,1
    80006f0c:	00e78c23          	sb	a4,24(a5)
    80006f10:	00e78ca3          	sb	a4,25(a5)
    80006f14:	00e78d23          	sb	a4,26(a5)
    80006f18:	00e78da3          	sb	a4,27(a5)
    80006f1c:	00e78e23          	sb	a4,28(a5)
    80006f20:	00e78ea3          	sb	a4,29(a5)
    80006f24:	00e78f23          	sb	a4,30(a5)
    80006f28:	00e78fa3          	sb	a4,31(a5)
}
    80006f2c:	60e2                	ld	ra,24(sp)
    80006f2e:	6442                	ld	s0,16(sp)
    80006f30:	64a2                	ld	s1,8(sp)
    80006f32:	6105                	addi	sp,sp,32
    80006f34:	8082                	ret
    panic("could not find virtio disk");
    80006f36:	00003517          	auipc	a0,0x3
    80006f3a:	9a250513          	addi	a0,a0,-1630 # 800098d8 <syscalls+0x388>
    80006f3e:	ffff9097          	auipc	ra,0xffff9
    80006f42:	5f0080e7          	jalr	1520(ra) # 8000052e <panic>
    panic("virtio disk has no queue 0");
    80006f46:	00003517          	auipc	a0,0x3
    80006f4a:	9b250513          	addi	a0,a0,-1614 # 800098f8 <syscalls+0x3a8>
    80006f4e:	ffff9097          	auipc	ra,0xffff9
    80006f52:	5e0080e7          	jalr	1504(ra) # 8000052e <panic>
    panic("virtio disk max queue too short");
    80006f56:	00003517          	auipc	a0,0x3
    80006f5a:	9c250513          	addi	a0,a0,-1598 # 80009918 <syscalls+0x3c8>
    80006f5e:	ffff9097          	auipc	ra,0xffff9
    80006f62:	5d0080e7          	jalr	1488(ra) # 8000052e <panic>

0000000080006f66 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006f66:	7119                	addi	sp,sp,-128
    80006f68:	fc86                	sd	ra,120(sp)
    80006f6a:	f8a2                	sd	s0,112(sp)
    80006f6c:	f4a6                	sd	s1,104(sp)
    80006f6e:	f0ca                	sd	s2,96(sp)
    80006f70:	ecce                	sd	s3,88(sp)
    80006f72:	e8d2                	sd	s4,80(sp)
    80006f74:	e4d6                	sd	s5,72(sp)
    80006f76:	e0da                	sd	s6,64(sp)
    80006f78:	fc5e                	sd	s7,56(sp)
    80006f7a:	f862                	sd	s8,48(sp)
    80006f7c:	f466                	sd	s9,40(sp)
    80006f7e:	f06a                	sd	s10,32(sp)
    80006f80:	ec6e                	sd	s11,24(sp)
    80006f82:	0100                	addi	s0,sp,128
    80006f84:	8aaa                	mv	s5,a0
    80006f86:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006f88:	00c52c83          	lw	s9,12(a0)
    80006f8c:	001c9c9b          	slliw	s9,s9,0x1
    80006f90:	1c82                	slli	s9,s9,0x20
    80006f92:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006f96:	0003a517          	auipc	a0,0x3a
    80006f9a:	19250513          	addi	a0,a0,402 # 80041128 <disk+0x2128>
    80006f9e:	ffffa097          	auipc	ra,0xffffa
    80006fa2:	c28080e7          	jalr	-984(ra) # 80000bc6 <acquire>
  for(int i = 0; i < 3; i++){
    80006fa6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006fa8:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006faa:	00038c17          	auipc	s8,0x38
    80006fae:	056c0c13          	addi	s8,s8,86 # 8003f000 <disk>
    80006fb2:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006fb4:	4b0d                	li	s6,3
    80006fb6:	a0ad                	j	80007020 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006fb8:	00fc0733          	add	a4,s8,a5
    80006fbc:	975e                	add	a4,a4,s7
    80006fbe:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006fc2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006fc4:	0207c563          	bltz	a5,80006fee <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006fc8:	2905                	addiw	s2,s2,1
    80006fca:	0611                	addi	a2,a2,4
    80006fcc:	19690d63          	beq	s2,s6,80007166 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006fd0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006fd2:	0003a717          	auipc	a4,0x3a
    80006fd6:	04670713          	addi	a4,a4,70 # 80041018 <disk+0x2018>
    80006fda:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006fdc:	00074683          	lbu	a3,0(a4)
    80006fe0:	fee1                	bnez	a3,80006fb8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006fe2:	2785                	addiw	a5,a5,1
    80006fe4:	0705                	addi	a4,a4,1
    80006fe6:	fe979be3          	bne	a5,s1,80006fdc <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006fea:	57fd                	li	a5,-1
    80006fec:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006fee:	01205d63          	blez	s2,80007008 <virtio_disk_rw+0xa2>
    80006ff2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006ff4:	000a2503          	lw	a0,0(s4)
    80006ff8:	00000097          	auipc	ra,0x0
    80006ffc:	d8e080e7          	jalr	-626(ra) # 80006d86 <free_desc>
      for(int j = 0; j < i; j++)
    80007000:	2d85                	addiw	s11,s11,1
    80007002:	0a11                	addi	s4,s4,4
    80007004:	ffb918e3          	bne	s2,s11,80006ff4 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80007008:	0003a597          	auipc	a1,0x3a
    8000700c:	12058593          	addi	a1,a1,288 # 80041128 <disk+0x2128>
    80007010:	0003a517          	auipc	a0,0x3a
    80007014:	00850513          	addi	a0,a0,8 # 80041018 <disk+0x2018>
    80007018:	ffffb097          	auipc	ra,0xffffb
    8000701c:	3aa080e7          	jalr	938(ra) # 800023c2 <sleep>
  for(int i = 0; i < 3; i++){
    80007020:	f8040a13          	addi	s4,s0,-128
{
    80007024:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80007026:	894e                	mv	s2,s3
    80007028:	b765                	j	80006fd0 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000702a:	0003a697          	auipc	a3,0x3a
    8000702e:	fd66b683          	ld	a3,-42(a3) # 80041000 <disk+0x2000>
    80007032:	96ba                	add	a3,a3,a4
    80007034:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80007038:	00038817          	auipc	a6,0x38
    8000703c:	fc880813          	addi	a6,a6,-56 # 8003f000 <disk>
    80007040:	0003a697          	auipc	a3,0x3a
    80007044:	fc068693          	addi	a3,a3,-64 # 80041000 <disk+0x2000>
    80007048:	6290                	ld	a2,0(a3)
    8000704a:	963a                	add	a2,a2,a4
    8000704c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80007050:	0015e593          	ori	a1,a1,1
    80007054:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80007058:	f8842603          	lw	a2,-120(s0)
    8000705c:	628c                	ld	a1,0(a3)
    8000705e:	972e                	add	a4,a4,a1
    80007060:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80007064:	20050593          	addi	a1,a0,512
    80007068:	0592                	slli	a1,a1,0x4
    8000706a:	95c2                	add	a1,a1,a6
    8000706c:	577d                	li	a4,-1
    8000706e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80007072:	00461713          	slli	a4,a2,0x4
    80007076:	6290                	ld	a2,0(a3)
    80007078:	963a                	add	a2,a2,a4
    8000707a:	03078793          	addi	a5,a5,48
    8000707e:	97c2                	add	a5,a5,a6
    80007080:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80007082:	629c                	ld	a5,0(a3)
    80007084:	97ba                	add	a5,a5,a4
    80007086:	4605                	li	a2,1
    80007088:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000708a:	629c                	ld	a5,0(a3)
    8000708c:	97ba                	add	a5,a5,a4
    8000708e:	4809                	li	a6,2
    80007090:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80007094:	629c                	ld	a5,0(a3)
    80007096:	973e                	add	a4,a4,a5
    80007098:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000709c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800070a0:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800070a4:	6698                	ld	a4,8(a3)
    800070a6:	00275783          	lhu	a5,2(a4)
    800070aa:	8b9d                	andi	a5,a5,7
    800070ac:	0786                	slli	a5,a5,0x1
    800070ae:	97ba                	add	a5,a5,a4
    800070b0:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    800070b4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800070b8:	6698                	ld	a4,8(a3)
    800070ba:	00275783          	lhu	a5,2(a4)
    800070be:	2785                	addiw	a5,a5,1
    800070c0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800070c4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800070c8:	100017b7          	lui	a5,0x10001
    800070cc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800070d0:	004aa783          	lw	a5,4(s5)
    800070d4:	02c79163          	bne	a5,a2,800070f6 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800070d8:	0003a917          	auipc	s2,0x3a
    800070dc:	05090913          	addi	s2,s2,80 # 80041128 <disk+0x2128>
  while(b->disk == 1) {
    800070e0:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800070e2:	85ca                	mv	a1,s2
    800070e4:	8556                	mv	a0,s5
    800070e6:	ffffb097          	auipc	ra,0xffffb
    800070ea:	2dc080e7          	jalr	732(ra) # 800023c2 <sleep>
  while(b->disk == 1) {
    800070ee:	004aa783          	lw	a5,4(s5)
    800070f2:	fe9788e3          	beq	a5,s1,800070e2 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800070f6:	f8042903          	lw	s2,-128(s0)
    800070fa:	20090793          	addi	a5,s2,512
    800070fe:	00479713          	slli	a4,a5,0x4
    80007102:	00038797          	auipc	a5,0x38
    80007106:	efe78793          	addi	a5,a5,-258 # 8003f000 <disk>
    8000710a:	97ba                	add	a5,a5,a4
    8000710c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80007110:	0003a997          	auipc	s3,0x3a
    80007114:	ef098993          	addi	s3,s3,-272 # 80041000 <disk+0x2000>
    80007118:	00491713          	slli	a4,s2,0x4
    8000711c:	0009b783          	ld	a5,0(s3)
    80007120:	97ba                	add	a5,a5,a4
    80007122:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80007126:	854a                	mv	a0,s2
    80007128:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000712c:	00000097          	auipc	ra,0x0
    80007130:	c5a080e7          	jalr	-934(ra) # 80006d86 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80007134:	8885                	andi	s1,s1,1
    80007136:	f0ed                	bnez	s1,80007118 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80007138:	0003a517          	auipc	a0,0x3a
    8000713c:	ff050513          	addi	a0,a0,-16 # 80041128 <disk+0x2128>
    80007140:	ffffa097          	auipc	ra,0xffffa
    80007144:	b5c080e7          	jalr	-1188(ra) # 80000c9c <release>
}
    80007148:	70e6                	ld	ra,120(sp)
    8000714a:	7446                	ld	s0,112(sp)
    8000714c:	74a6                	ld	s1,104(sp)
    8000714e:	7906                	ld	s2,96(sp)
    80007150:	69e6                	ld	s3,88(sp)
    80007152:	6a46                	ld	s4,80(sp)
    80007154:	6aa6                	ld	s5,72(sp)
    80007156:	6b06                	ld	s6,64(sp)
    80007158:	7be2                	ld	s7,56(sp)
    8000715a:	7c42                	ld	s8,48(sp)
    8000715c:	7ca2                	ld	s9,40(sp)
    8000715e:	7d02                	ld	s10,32(sp)
    80007160:	6de2                	ld	s11,24(sp)
    80007162:	6109                	addi	sp,sp,128
    80007164:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007166:	f8042503          	lw	a0,-128(s0)
    8000716a:	20050793          	addi	a5,a0,512
    8000716e:	0792                	slli	a5,a5,0x4
  if(write)
    80007170:	00038817          	auipc	a6,0x38
    80007174:	e9080813          	addi	a6,a6,-368 # 8003f000 <disk>
    80007178:	00f80733          	add	a4,a6,a5
    8000717c:	01a036b3          	snez	a3,s10
    80007180:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80007184:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80007188:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000718c:	7679                	lui	a2,0xffffe
    8000718e:	963e                	add	a2,a2,a5
    80007190:	0003a697          	auipc	a3,0x3a
    80007194:	e7068693          	addi	a3,a3,-400 # 80041000 <disk+0x2000>
    80007198:	6298                	ld	a4,0(a3)
    8000719a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000719c:	0a878593          	addi	a1,a5,168
    800071a0:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    800071a2:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800071a4:	6298                	ld	a4,0(a3)
    800071a6:	9732                	add	a4,a4,a2
    800071a8:	45c1                	li	a1,16
    800071aa:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800071ac:	6298                	ld	a4,0(a3)
    800071ae:	9732                	add	a4,a4,a2
    800071b0:	4585                	li	a1,1
    800071b2:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800071b6:	f8442703          	lw	a4,-124(s0)
    800071ba:	628c                	ld	a1,0(a3)
    800071bc:	962e                	add	a2,a2,a1
    800071be:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffbc00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    800071c2:	0712                	slli	a4,a4,0x4
    800071c4:	6290                	ld	a2,0(a3)
    800071c6:	963a                	add	a2,a2,a4
    800071c8:	058a8593          	addi	a1,s5,88
    800071cc:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800071ce:	6294                	ld	a3,0(a3)
    800071d0:	96ba                	add	a3,a3,a4
    800071d2:	40000613          	li	a2,1024
    800071d6:	c690                	sw	a2,8(a3)
  if(write)
    800071d8:	e40d19e3          	bnez	s10,8000702a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800071dc:	0003a697          	auipc	a3,0x3a
    800071e0:	e246b683          	ld	a3,-476(a3) # 80041000 <disk+0x2000>
    800071e4:	96ba                	add	a3,a3,a4
    800071e6:	4609                	li	a2,2
    800071e8:	00c69623          	sh	a2,12(a3)
    800071ec:	b5b1                	j	80007038 <virtio_disk_rw+0xd2>

00000000800071ee <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800071ee:	1101                	addi	sp,sp,-32
    800071f0:	ec06                	sd	ra,24(sp)
    800071f2:	e822                	sd	s0,16(sp)
    800071f4:	e426                	sd	s1,8(sp)
    800071f6:	e04a                	sd	s2,0(sp)
    800071f8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800071fa:	0003a517          	auipc	a0,0x3a
    800071fe:	f2e50513          	addi	a0,a0,-210 # 80041128 <disk+0x2128>
    80007202:	ffffa097          	auipc	ra,0xffffa
    80007206:	9c4080e7          	jalr	-1596(ra) # 80000bc6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000720a:	10001737          	lui	a4,0x10001
    8000720e:	533c                	lw	a5,96(a4)
    80007210:	8b8d                	andi	a5,a5,3
    80007212:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80007214:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80007218:	0003a797          	auipc	a5,0x3a
    8000721c:	de878793          	addi	a5,a5,-536 # 80041000 <disk+0x2000>
    80007220:	6b94                	ld	a3,16(a5)
    80007222:	0207d703          	lhu	a4,32(a5)
    80007226:	0026d783          	lhu	a5,2(a3)
    8000722a:	06f70163          	beq	a4,a5,8000728c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000722e:	00038917          	auipc	s2,0x38
    80007232:	dd290913          	addi	s2,s2,-558 # 8003f000 <disk>
    80007236:	0003a497          	auipc	s1,0x3a
    8000723a:	dca48493          	addi	s1,s1,-566 # 80041000 <disk+0x2000>
    __sync_synchronize();
    8000723e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007242:	6898                	ld	a4,16(s1)
    80007244:	0204d783          	lhu	a5,32(s1)
    80007248:	8b9d                	andi	a5,a5,7
    8000724a:	078e                	slli	a5,a5,0x3
    8000724c:	97ba                	add	a5,a5,a4
    8000724e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80007250:	20078713          	addi	a4,a5,512
    80007254:	0712                	slli	a4,a4,0x4
    80007256:	974a                	add	a4,a4,s2
    80007258:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000725c:	e731                	bnez	a4,800072a8 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000725e:	20078793          	addi	a5,a5,512
    80007262:	0792                	slli	a5,a5,0x4
    80007264:	97ca                	add	a5,a5,s2
    80007266:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007268:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000726c:	ffffb097          	auipc	ra,0xffffb
    80007270:	2e0080e7          	jalr	736(ra) # 8000254c <wakeup>

    disk.used_idx += 1;
    80007274:	0204d783          	lhu	a5,32(s1)
    80007278:	2785                	addiw	a5,a5,1
    8000727a:	17c2                	slli	a5,a5,0x30
    8000727c:	93c1                	srli	a5,a5,0x30
    8000727e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007282:	6898                	ld	a4,16(s1)
    80007284:	00275703          	lhu	a4,2(a4)
    80007288:	faf71be3          	bne	a4,a5,8000723e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000728c:	0003a517          	auipc	a0,0x3a
    80007290:	e9c50513          	addi	a0,a0,-356 # 80041128 <disk+0x2128>
    80007294:	ffffa097          	auipc	ra,0xffffa
    80007298:	a08080e7          	jalr	-1528(ra) # 80000c9c <release>
}
    8000729c:	60e2                	ld	ra,24(sp)
    8000729e:	6442                	ld	s0,16(sp)
    800072a0:	64a2                	ld	s1,8(sp)
    800072a2:	6902                	ld	s2,0(sp)
    800072a4:	6105                	addi	sp,sp,32
    800072a6:	8082                	ret
      panic("virtio_disk_intr status");
    800072a8:	00002517          	auipc	a0,0x2
    800072ac:	69050513          	addi	a0,a0,1680 # 80009938 <syscalls+0x3e8>
    800072b0:	ffff9097          	auipc	ra,0xffff9
    800072b4:	27e080e7          	jalr	638(ra) # 8000052e <panic>

00000000800072b8 <call_sigret>:
    800072b8:	48e1                	li	a7,24
    800072ba:	00000073          	ecall
    800072be:	8082                	ret

00000000800072c0 <end_sigret>:
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
