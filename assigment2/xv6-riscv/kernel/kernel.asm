
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
    80000068:	dbc78793          	addi	a5,a5,-580 # 80006e20 <timervec>
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
    800000b2:	dd878793          	addi	a5,a5,-552 # 80000e86 <main>
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
    80000122:	824080e7          	jalr	-2012(ra) # 80002942 <either_copyin>
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
    800001b6:	8be080e7          	jalr	-1858(ra) # 80001a70 <myproc>
    800001ba:	4d5c                	lw	a5,28(a0)
    800001bc:	07278863          	beq	a5,s2,8000022c <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001c0:	85a6                	mv	a1,s1
    800001c2:	854e                	mv	a0,s3
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	226080e7          	jalr	550(ra) # 800023ea <sleep>
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
    80000204:	6ec080e7          	jalr	1772(ra) # 800028ec <either_copyout>
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
    80000222:	a72080e7          	jalr	-1422(ra) # 80000c90 <release>

  return target - n;
    80000226:	414b853b          	subw	a0,s7,s4
    8000022a:	a811                	j	8000023e <consoleread+0xe8>
        release(&cons.lock);
    8000022c:	00012517          	auipc	a0,0x12
    80000230:	f5450513          	addi	a0,a0,-172 # 80012180 <cons>
    80000234:	00001097          	auipc	ra,0x1
    80000238:	a5c080e7          	jalr	-1444(ra) # 80000c90 <release>
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
    800002e6:	6b6080e7          	jalr	1718(ra) # 80002998 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ea:	00012517          	auipc	a0,0x12
    800002ee:	e9650513          	addi	a0,a0,-362 # 80012180 <cons>
    800002f2:	00001097          	auipc	ra,0x1
    800002f6:	99e080e7          	jalr	-1634(ra) # 80000c90 <release>
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
    8000043a:	13e080e7          	jalr	318(ra) # 80002574 <wakeup>
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
    80000560:	d0c50513          	addi	a0,a0,-756 # 80009268 <digits+0x228>
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
    80000752:	542080e7          	jalr	1346(ra) # 80000c90 <release>
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
    80000818:	41c080e7          	jalr	1052(ra) # 80000c30 <pop_off>
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
    80000886:	cf2080e7          	jalr	-782(ra) # 80002574 <wakeup>
    
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
    80000912:	adc080e7          	jalr	-1316(ra) # 800023ea <sleep>
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
    8000094e:	346080e7          	jalr	838(ra) # 80000c90 <release>
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
    800009cc:	2c8080e7          	jalr	712(ra) # 80000c90 <release>
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
    80000a0a:	2d2080e7          	jalr	722(ra) # 80000cd8 <memset>

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
    80000a30:	264080e7          	jalr	612(ra) # 80000c90 <release>
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
    80000b06:	18e080e7          	jalr	398(ra) # 80000c90 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b0a:	6605                	lui	a2,0x1
    80000b0c:	4595                	li	a1,5
    80000b0e:	8526                	mv	a0,s1
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	1c8080e7          	jalr	456(ra) # 80000cd8 <memset>
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
    80000b30:	164080e7          	jalr	356(ra) # 80000c90 <release>
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
    80000b64:	eec080e7          	jalr	-276(ra) # 80001a4c <mycpu>
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
    80000b96:	eba080e7          	jalr	-326(ra) # 80001a4c <mycpu>
    80000b9a:	5d3c                	lw	a5,120(a0)
    80000b9c:	cf89                	beqz	a5,80000bb6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	eae080e7          	jalr	-338(ra) # 80001a4c <mycpu>
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
    80000bba:	e96080e7          	jalr	-362(ra) # 80001a4c <mycpu>
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
    80000bfa:	e56080e7          	jalr	-426(ra) # 80001a4c <mycpu>
    80000bfe:	e888                	sd	a0,16(s1)
}
    80000c00:	60e2                	ld	ra,24(sp)
    80000c02:	6442                	ld	s0,16(sp)
    80000c04:	64a2                	ld	s1,8(sp)
    80000c06:	6105                	addi	sp,sp,32
    80000c08:	8082                	ret
    printf("pid=%d tried to lock when already holding\n",lk->cpu->proc->pid);//TODO delete
    80000c0a:	689c                	ld	a5,16(s1)
    80000c0c:	639c                	ld	a5,0(a5)
    80000c0e:	53cc                	lw	a1,36(a5)
    80000c10:	00008517          	auipc	a0,0x8
    80000c14:	46050513          	addi	a0,a0,1120 # 80009070 <digits+0x30>
    80000c18:	00000097          	auipc	ra,0x0
    80000c1c:	960080e7          	jalr	-1696(ra) # 80000578 <printf>
    panic("acquire");
    80000c20:	00008517          	auipc	a0,0x8
    80000c24:	48050513          	addi	a0,a0,1152 # 800090a0 <digits+0x60>
    80000c28:	00000097          	auipc	ra,0x0
    80000c2c:	906080e7          	jalr	-1786(ra) # 8000052e <panic>

0000000080000c30 <pop_off>:

void
pop_off(void)
{
    80000c30:	1141                	addi	sp,sp,-16
    80000c32:	e406                	sd	ra,8(sp)
    80000c34:	e022                	sd	s0,0(sp)
    80000c36:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c38:	00001097          	auipc	ra,0x1
    80000c3c:	e14080e7          	jalr	-492(ra) # 80001a4c <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c40:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c44:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c46:	e78d                	bnez	a5,80000c70 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c48:	5d3c                	lw	a5,120(a0)
    80000c4a:	02f05b63          	blez	a5,80000c80 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c4e:	37fd                	addiw	a5,a5,-1
    80000c50:	0007871b          	sext.w	a4,a5
    80000c54:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c56:	eb09                	bnez	a4,80000c68 <pop_off+0x38>
    80000c58:	5d7c                	lw	a5,124(a0)
    80000c5a:	c799                	beqz	a5,80000c68 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c5c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c60:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c64:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c68:	60a2                	ld	ra,8(sp)
    80000c6a:	6402                	ld	s0,0(sp)
    80000c6c:	0141                	addi	sp,sp,16
    80000c6e:	8082                	ret
    panic("pop_off - interruptible");
    80000c70:	00008517          	auipc	a0,0x8
    80000c74:	43850513          	addi	a0,a0,1080 # 800090a8 <digits+0x68>
    80000c78:	00000097          	auipc	ra,0x0
    80000c7c:	8b6080e7          	jalr	-1866(ra) # 8000052e <panic>
    panic("pop_off");
    80000c80:	00008517          	auipc	a0,0x8
    80000c84:	44050513          	addi	a0,a0,1088 # 800090c0 <digits+0x80>
    80000c88:	00000097          	auipc	ra,0x0
    80000c8c:	8a6080e7          	jalr	-1882(ra) # 8000052e <panic>

0000000080000c90 <release>:
{
    80000c90:	1101                	addi	sp,sp,-32
    80000c92:	ec06                	sd	ra,24(sp)
    80000c94:	e822                	sd	s0,16(sp)
    80000c96:	e426                	sd	s1,8(sp)
    80000c98:	1000                	addi	s0,sp,32
    80000c9a:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c9c:	00000097          	auipc	ra,0x0
    80000ca0:	eb0080e7          	jalr	-336(ra) # 80000b4c <holding>
    80000ca4:	c115                	beqz	a0,80000cc8 <release+0x38>
  lk->cpu = 0;
    80000ca6:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000caa:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cae:	0f50000f          	fence	iorw,ow
    80000cb2:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	f7a080e7          	jalr	-134(ra) # 80000c30 <pop_off>
}
    80000cbe:	60e2                	ld	ra,24(sp)
    80000cc0:	6442                	ld	s0,16(sp)
    80000cc2:	64a2                	ld	s1,8(sp)
    80000cc4:	6105                	addi	sp,sp,32
    80000cc6:	8082                	ret
    panic("release");
    80000cc8:	00008517          	auipc	a0,0x8
    80000ccc:	40050513          	addi	a0,a0,1024 # 800090c8 <digits+0x88>
    80000cd0:	00000097          	auipc	ra,0x0
    80000cd4:	85e080e7          	jalr	-1954(ra) # 8000052e <panic>

0000000080000cd8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd8:	1141                	addi	sp,sp,-16
    80000cda:	e422                	sd	s0,8(sp)
    80000cdc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cde:	ca19                	beqz	a2,80000cf4 <memset+0x1c>
    80000ce0:	87aa                	mv	a5,a0
    80000ce2:	1602                	slli	a2,a2,0x20
    80000ce4:	9201                	srli	a2,a2,0x20
    80000ce6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cea:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cee:	0785                	addi	a5,a5,1
    80000cf0:	fee79de3          	bne	a5,a4,80000cea <memset+0x12>
  }
  return dst;
}
    80000cf4:	6422                	ld	s0,8(sp)
    80000cf6:	0141                	addi	sp,sp,16
    80000cf8:	8082                	ret

0000000080000cfa <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cfa:	1141                	addi	sp,sp,-16
    80000cfc:	e422                	sd	s0,8(sp)
    80000cfe:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d00:	ca05                	beqz	a2,80000d30 <memcmp+0x36>
    80000d02:	fff6069b          	addiw	a3,a2,-1
    80000d06:	1682                	slli	a3,a3,0x20
    80000d08:	9281                	srli	a3,a3,0x20
    80000d0a:	0685                	addi	a3,a3,1
    80000d0c:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d0e:	00054783          	lbu	a5,0(a0)
    80000d12:	0005c703          	lbu	a4,0(a1)
    80000d16:	00e79863          	bne	a5,a4,80000d26 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d1a:	0505                	addi	a0,a0,1
    80000d1c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d1e:	fed518e3          	bne	a0,a3,80000d0e <memcmp+0x14>
  }

  return 0;
    80000d22:	4501                	li	a0,0
    80000d24:	a019                	j	80000d2a <memcmp+0x30>
      return *s1 - *s2;
    80000d26:	40e7853b          	subw	a0,a5,a4
}
    80000d2a:	6422                	ld	s0,8(sp)
    80000d2c:	0141                	addi	sp,sp,16
    80000d2e:	8082                	ret
  return 0;
    80000d30:	4501                	li	a0,0
    80000d32:	bfe5                	j	80000d2a <memcmp+0x30>

0000000080000d34 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d34:	1141                	addi	sp,sp,-16
    80000d36:	e422                	sd	s0,8(sp)
    80000d38:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d3a:	02a5e563          	bltu	a1,a0,80000d64 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3e:	fff6069b          	addiw	a3,a2,-1
    80000d42:	ce11                	beqz	a2,80000d5e <memmove+0x2a>
    80000d44:	1682                	slli	a3,a3,0x20
    80000d46:	9281                	srli	a3,a3,0x20
    80000d48:	0685                	addi	a3,a3,1
    80000d4a:	96ae                	add	a3,a3,a1
    80000d4c:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d4e:	0585                	addi	a1,a1,1
    80000d50:	0785                	addi	a5,a5,1
    80000d52:	fff5c703          	lbu	a4,-1(a1)
    80000d56:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d5a:	fed59ae3          	bne	a1,a3,80000d4e <memmove+0x1a>

  return dst;
}
    80000d5e:	6422                	ld	s0,8(sp)
    80000d60:	0141                	addi	sp,sp,16
    80000d62:	8082                	ret
  if(s < d && s + n > d){
    80000d64:	02061713          	slli	a4,a2,0x20
    80000d68:	9301                	srli	a4,a4,0x20
    80000d6a:	00e587b3          	add	a5,a1,a4
    80000d6e:	fcf578e3          	bgeu	a0,a5,80000d3e <memmove+0xa>
    d += n;
    80000d72:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d74:	fff6069b          	addiw	a3,a2,-1
    80000d78:	d27d                	beqz	a2,80000d5e <memmove+0x2a>
    80000d7a:	02069613          	slli	a2,a3,0x20
    80000d7e:	9201                	srli	a2,a2,0x20
    80000d80:	fff64613          	not	a2,a2
    80000d84:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d86:	17fd                	addi	a5,a5,-1
    80000d88:	177d                	addi	a4,a4,-1
    80000d8a:	0007c683          	lbu	a3,0(a5)
    80000d8e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d92:	fef61ae3          	bne	a2,a5,80000d86 <memmove+0x52>
    80000d96:	b7e1                	j	80000d5e <memmove+0x2a>

0000000080000d98 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d98:	1141                	addi	sp,sp,-16
    80000d9a:	e406                	sd	ra,8(sp)
    80000d9c:	e022                	sd	s0,0(sp)
    80000d9e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000da0:	00000097          	auipc	ra,0x0
    80000da4:	f94080e7          	jalr	-108(ra) # 80000d34 <memmove>
}
    80000da8:	60a2                	ld	ra,8(sp)
    80000daa:	6402                	ld	s0,0(sp)
    80000dac:	0141                	addi	sp,sp,16
    80000dae:	8082                	ret

0000000080000db0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000db0:	1141                	addi	sp,sp,-16
    80000db2:	e422                	sd	s0,8(sp)
    80000db4:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000db6:	ce11                	beqz	a2,80000dd2 <strncmp+0x22>
    80000db8:	00054783          	lbu	a5,0(a0)
    80000dbc:	cf89                	beqz	a5,80000dd6 <strncmp+0x26>
    80000dbe:	0005c703          	lbu	a4,0(a1)
    80000dc2:	00f71a63          	bne	a4,a5,80000dd6 <strncmp+0x26>
    n--, p++, q++;
    80000dc6:	367d                	addiw	a2,a2,-1
    80000dc8:	0505                	addi	a0,a0,1
    80000dca:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dcc:	f675                	bnez	a2,80000db8 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dce:	4501                	li	a0,0
    80000dd0:	a809                	j	80000de2 <strncmp+0x32>
    80000dd2:	4501                	li	a0,0
    80000dd4:	a039                	j	80000de2 <strncmp+0x32>
  if(n == 0)
    80000dd6:	ca09                	beqz	a2,80000de8 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dd8:	00054503          	lbu	a0,0(a0)
    80000ddc:	0005c783          	lbu	a5,0(a1)
    80000de0:	9d1d                	subw	a0,a0,a5
}
    80000de2:	6422                	ld	s0,8(sp)
    80000de4:	0141                	addi	sp,sp,16
    80000de6:	8082                	ret
    return 0;
    80000de8:	4501                	li	a0,0
    80000dea:	bfe5                	j	80000de2 <strncmp+0x32>

0000000080000dec <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dec:	1141                	addi	sp,sp,-16
    80000dee:	e422                	sd	s0,8(sp)
    80000df0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000df2:	872a                	mv	a4,a0
    80000df4:	8832                	mv	a6,a2
    80000df6:	367d                	addiw	a2,a2,-1
    80000df8:	01005963          	blez	a6,80000e0a <strncpy+0x1e>
    80000dfc:	0705                	addi	a4,a4,1
    80000dfe:	0005c783          	lbu	a5,0(a1)
    80000e02:	fef70fa3          	sb	a5,-1(a4)
    80000e06:	0585                	addi	a1,a1,1
    80000e08:	f7f5                	bnez	a5,80000df4 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e0a:	86ba                	mv	a3,a4
    80000e0c:	00c05c63          	blez	a2,80000e24 <strncpy+0x38>
    *s++ = 0;
    80000e10:	0685                	addi	a3,a3,1
    80000e12:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e16:	fff6c793          	not	a5,a3
    80000e1a:	9fb9                	addw	a5,a5,a4
    80000e1c:	010787bb          	addw	a5,a5,a6
    80000e20:	fef048e3          	bgtz	a5,80000e10 <strncpy+0x24>
  return os;
}
    80000e24:	6422                	ld	s0,8(sp)
    80000e26:	0141                	addi	sp,sp,16
    80000e28:	8082                	ret

0000000080000e2a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e2a:	1141                	addi	sp,sp,-16
    80000e2c:	e422                	sd	s0,8(sp)
    80000e2e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e30:	02c05363          	blez	a2,80000e56 <safestrcpy+0x2c>
    80000e34:	fff6069b          	addiw	a3,a2,-1
    80000e38:	1682                	slli	a3,a3,0x20
    80000e3a:	9281                	srli	a3,a3,0x20
    80000e3c:	96ae                	add	a3,a3,a1
    80000e3e:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e40:	00d58963          	beq	a1,a3,80000e52 <safestrcpy+0x28>
    80000e44:	0585                	addi	a1,a1,1
    80000e46:	0785                	addi	a5,a5,1
    80000e48:	fff5c703          	lbu	a4,-1(a1)
    80000e4c:	fee78fa3          	sb	a4,-1(a5)
    80000e50:	fb65                	bnez	a4,80000e40 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e52:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e56:	6422                	ld	s0,8(sp)
    80000e58:	0141                	addi	sp,sp,16
    80000e5a:	8082                	ret

0000000080000e5c <strlen>:

int
strlen(const char *s)
{
    80000e5c:	1141                	addi	sp,sp,-16
    80000e5e:	e422                	sd	s0,8(sp)
    80000e60:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e62:	00054783          	lbu	a5,0(a0)
    80000e66:	cf91                	beqz	a5,80000e82 <strlen+0x26>
    80000e68:	0505                	addi	a0,a0,1
    80000e6a:	87aa                	mv	a5,a0
    80000e6c:	4685                	li	a3,1
    80000e6e:	9e89                	subw	a3,a3,a0
    80000e70:	00f6853b          	addw	a0,a3,a5
    80000e74:	0785                	addi	a5,a5,1
    80000e76:	fff7c703          	lbu	a4,-1(a5)
    80000e7a:	fb7d                	bnez	a4,80000e70 <strlen+0x14>
    ;
  return n;
}
    80000e7c:	6422                	ld	s0,8(sp)
    80000e7e:	0141                	addi	sp,sp,16
    80000e80:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e82:	4501                	li	a0,0
    80000e84:	bfe5                	j	80000e7c <strlen+0x20>

0000000080000e86 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e86:	1141                	addi	sp,sp,-16
    80000e88:	e406                	sd	ra,8(sp)
    80000e8a:	e022                	sd	s0,0(sp)
    80000e8c:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e8e:	00001097          	auipc	ra,0x1
    80000e92:	bae080e7          	jalr	-1106(ra) # 80001a3c <cpuid>
    userinit();      // first user process
    __sync_synchronize();

    started = 1;
  } else {
    while(started == 0)
    80000e96:	00009717          	auipc	a4,0x9
    80000e9a:	18270713          	addi	a4,a4,386 # 8000a018 <started>
  if(cpuid() == 0){
    80000e9e:	c139                	beqz	a0,80000ee4 <main+0x5e>
    while(started == 0)
    80000ea0:	431c                	lw	a5,0(a4)
    80000ea2:	2781                	sext.w	a5,a5
    80000ea4:	dff5                	beqz	a5,80000ea0 <main+0x1a>
      ;
    __sync_synchronize();
    80000ea6:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eaa:	00001097          	auipc	ra,0x1
    80000eae:	b92080e7          	jalr	-1134(ra) # 80001a3c <cpuid>
    80000eb2:	85aa                	mv	a1,a0
    80000eb4:	00008517          	auipc	a0,0x8
    80000eb8:	23450513          	addi	a0,a0,564 # 800090e8 <digits+0xa8>
    80000ebc:	fffff097          	auipc	ra,0xfffff
    80000ec0:	6bc080e7          	jalr	1724(ra) # 80000578 <printf>
    kvminithart();    // turn on paging
    80000ec4:	00000097          	auipc	ra,0x0
    80000ec8:	0d8080e7          	jalr	216(ra) # 80000f9c <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ecc:	00002097          	auipc	ra,0x2
    80000ed0:	342080e7          	jalr	834(ra) # 8000320e <trapinithart>

    plicinithart();   // ask PLIC for device interrupts
    80000ed4:	00006097          	auipc	ra,0x6
    80000ed8:	f8c080e7          	jalr	-116(ra) # 80006e60 <plicinithart>
  }

  scheduler();        
    80000edc:	00001097          	auipc	ra,0x1
    80000ee0:	2fe080e7          	jalr	766(ra) # 800021da <scheduler>
    consoleinit();
    80000ee4:	fffff097          	auipc	ra,0xfffff
    80000ee8:	55c080e7          	jalr	1372(ra) # 80000440 <consoleinit>
    printfinit();
    80000eec:	00000097          	auipc	ra,0x0
    80000ef0:	86c080e7          	jalr	-1940(ra) # 80000758 <printfinit>
    printf("\n");
    80000ef4:	00008517          	auipc	a0,0x8
    80000ef8:	37450513          	addi	a0,a0,884 # 80009268 <digits+0x228>
    80000efc:	fffff097          	auipc	ra,0xfffff
    80000f00:	67c080e7          	jalr	1660(ra) # 80000578 <printf>
    printf("xv6 kernel is booting\n");
    80000f04:	00008517          	auipc	a0,0x8
    80000f08:	1cc50513          	addi	a0,a0,460 # 800090d0 <digits+0x90>
    80000f0c:	fffff097          	auipc	ra,0xfffff
    80000f10:	66c080e7          	jalr	1644(ra) # 80000578 <printf>
    printf("\n");
    80000f14:	00008517          	auipc	a0,0x8
    80000f18:	35450513          	addi	a0,a0,852 # 80009268 <digits+0x228>
    80000f1c:	fffff097          	auipc	ra,0xfffff
    80000f20:	65c080e7          	jalr	1628(ra) # 80000578 <printf>
    kinit();         // physical page allocator
    80000f24:	00000097          	auipc	ra,0x0
    80000f28:	b76080e7          	jalr	-1162(ra) # 80000a9a <kinit>
    kvminit();       // create kernel page table
    80000f2c:	00000097          	auipc	ra,0x0
    80000f30:	310080e7          	jalr	784(ra) # 8000123c <kvminit>
    kvminithart();   // turn on paging
    80000f34:	00000097          	auipc	ra,0x0
    80000f38:	068080e7          	jalr	104(ra) # 80000f9c <kvminithart>
    procinit();      // process table
    80000f3c:	00001097          	auipc	ra,0x1
    80000f40:	9d2080e7          	jalr	-1582(ra) # 8000190e <procinit>
    trapinit();      // trap vectors
    80000f44:	00002097          	auipc	ra,0x2
    80000f48:	2a2080e7          	jalr	674(ra) # 800031e6 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f4c:	00002097          	auipc	ra,0x2
    80000f50:	2c2080e7          	jalr	706(ra) # 8000320e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f54:	00006097          	auipc	ra,0x6
    80000f58:	ef6080e7          	jalr	-266(ra) # 80006e4a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f5c:	00006097          	auipc	ra,0x6
    80000f60:	f04080e7          	jalr	-252(ra) # 80006e60 <plicinithart>
    binit();         // buffer cache
    80000f64:	00003097          	auipc	ra,0x3
    80000f68:	02c080e7          	jalr	44(ra) # 80003f90 <binit>
    iinit();         // inode cache
    80000f6c:	00003097          	auipc	ra,0x3
    80000f70:	6be080e7          	jalr	1726(ra) # 8000462a <iinit>
    fileinit();      // file table
    80000f74:	00004097          	auipc	ra,0x4
    80000f78:	66a080e7          	jalr	1642(ra) # 800055de <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f7c:	00006097          	auipc	ra,0x6
    80000f80:	006080e7          	jalr	6(ra) # 80006f82 <virtio_disk_init>
    userinit();      // first user process
    80000f84:	00001097          	auipc	ra,0x1
    80000f88:	fa2080e7          	jalr	-94(ra) # 80001f26 <userinit>
    __sync_synchronize();
    80000f8c:	0ff0000f          	fence
    started = 1;
    80000f90:	4785                	li	a5,1
    80000f92:	00009717          	auipc	a4,0x9
    80000f96:	08f72323          	sw	a5,134(a4) # 8000a018 <started>
    80000f9a:	b789                	j	80000edc <main+0x56>

0000000080000f9c <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f9c:	1141                	addi	sp,sp,-16
    80000f9e:	e422                	sd	s0,8(sp)
    80000fa0:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fa2:	00009797          	auipc	a5,0x9
    80000fa6:	07e7b783          	ld	a5,126(a5) # 8000a020 <kernel_pagetable>
    80000faa:	83b1                	srli	a5,a5,0xc
    80000fac:	577d                	li	a4,-1
    80000fae:	177e                	slli	a4,a4,0x3f
    80000fb0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fb2:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fb6:	12000073          	sfence.vma
  sfence_vma();
}
    80000fba:	6422                	ld	s0,8(sp)
    80000fbc:	0141                	addi	sp,sp,16
    80000fbe:	8082                	ret

0000000080000fc0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fc0:	7139                	addi	sp,sp,-64
    80000fc2:	fc06                	sd	ra,56(sp)
    80000fc4:	f822                	sd	s0,48(sp)
    80000fc6:	f426                	sd	s1,40(sp)
    80000fc8:	f04a                	sd	s2,32(sp)
    80000fca:	ec4e                	sd	s3,24(sp)
    80000fcc:	e852                	sd	s4,16(sp)
    80000fce:	e456                	sd	s5,8(sp)
    80000fd0:	e05a                	sd	s6,0(sp)
    80000fd2:	0080                	addi	s0,sp,64
    80000fd4:	84aa                	mv	s1,a0
    80000fd6:	89ae                	mv	s3,a1
    80000fd8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fda:	57fd                	li	a5,-1
    80000fdc:	83e9                	srli	a5,a5,0x1a
    80000fde:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fe0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fe2:	04b7f263          	bgeu	a5,a1,80001026 <walk+0x66>
    panic("walk");
    80000fe6:	00008517          	auipc	a0,0x8
    80000fea:	11a50513          	addi	a0,a0,282 # 80009100 <digits+0xc0>
    80000fee:	fffff097          	auipc	ra,0xfffff
    80000ff2:	540080e7          	jalr	1344(ra) # 8000052e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ff6:	060a8663          	beqz	s5,80001062 <walk+0xa2>
    80000ffa:	00000097          	auipc	ra,0x0
    80000ffe:	adc080e7          	jalr	-1316(ra) # 80000ad6 <kalloc>
    80001002:	84aa                	mv	s1,a0
    80001004:	c529                	beqz	a0,8000104e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001006:	6605                	lui	a2,0x1
    80001008:	4581                	li	a1,0
    8000100a:	00000097          	auipc	ra,0x0
    8000100e:	cce080e7          	jalr	-818(ra) # 80000cd8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001012:	00c4d793          	srli	a5,s1,0xc
    80001016:	07aa                	slli	a5,a5,0xa
    80001018:	0017e793          	ori	a5,a5,1
    8000101c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001020:	3a5d                	addiw	s4,s4,-9
    80001022:	036a0063          	beq	s4,s6,80001042 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001026:	0149d933          	srl	s2,s3,s4
    8000102a:	1ff97913          	andi	s2,s2,511
    8000102e:	090e                	slli	s2,s2,0x3
    80001030:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001032:	00093483          	ld	s1,0(s2)
    80001036:	0014f793          	andi	a5,s1,1
    8000103a:	dfd5                	beqz	a5,80000ff6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000103c:	80a9                	srli	s1,s1,0xa
    8000103e:	04b2                	slli	s1,s1,0xc
    80001040:	b7c5                	j	80001020 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001042:	00c9d513          	srli	a0,s3,0xc
    80001046:	1ff57513          	andi	a0,a0,511
    8000104a:	050e                	slli	a0,a0,0x3
    8000104c:	9526                	add	a0,a0,s1
}
    8000104e:	70e2                	ld	ra,56(sp)
    80001050:	7442                	ld	s0,48(sp)
    80001052:	74a2                	ld	s1,40(sp)
    80001054:	7902                	ld	s2,32(sp)
    80001056:	69e2                	ld	s3,24(sp)
    80001058:	6a42                	ld	s4,16(sp)
    8000105a:	6aa2                	ld	s5,8(sp)
    8000105c:	6b02                	ld	s6,0(sp)
    8000105e:	6121                	addi	sp,sp,64
    80001060:	8082                	ret
        return 0;
    80001062:	4501                	li	a0,0
    80001064:	b7ed                	j	8000104e <walk+0x8e>

0000000080001066 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001066:	57fd                	li	a5,-1
    80001068:	83e9                	srli	a5,a5,0x1a
    8000106a:	00b7f463          	bgeu	a5,a1,80001072 <walkaddr+0xc>
    return 0;
    8000106e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001070:	8082                	ret
{
    80001072:	1141                	addi	sp,sp,-16
    80001074:	e406                	sd	ra,8(sp)
    80001076:	e022                	sd	s0,0(sp)
    80001078:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000107a:	4601                	li	a2,0
    8000107c:	00000097          	auipc	ra,0x0
    80001080:	f44080e7          	jalr	-188(ra) # 80000fc0 <walk>
  if(pte == 0)
    80001084:	c105                	beqz	a0,800010a4 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001086:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001088:	0117f693          	andi	a3,a5,17
    8000108c:	4745                	li	a4,17
    return 0;
    8000108e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001090:	00e68663          	beq	a3,a4,8000109c <walkaddr+0x36>
}
    80001094:	60a2                	ld	ra,8(sp)
    80001096:	6402                	ld	s0,0(sp)
    80001098:	0141                	addi	sp,sp,16
    8000109a:	8082                	ret
  pa = PTE2PA(*pte);
    8000109c:	00a7d513          	srli	a0,a5,0xa
    800010a0:	0532                	slli	a0,a0,0xc
  return pa;
    800010a2:	bfcd                	j	80001094 <walkaddr+0x2e>
    return 0;
    800010a4:	4501                	li	a0,0
    800010a6:	b7fd                	j	80001094 <walkaddr+0x2e>

00000000800010a8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a8:	715d                	addi	sp,sp,-80
    800010aa:	e486                	sd	ra,72(sp)
    800010ac:	e0a2                	sd	s0,64(sp)
    800010ae:	fc26                	sd	s1,56(sp)
    800010b0:	f84a                	sd	s2,48(sp)
    800010b2:	f44e                	sd	s3,40(sp)
    800010b4:	f052                	sd	s4,32(sp)
    800010b6:	ec56                	sd	s5,24(sp)
    800010b8:	e85a                	sd	s6,16(sp)
    800010ba:	e45e                	sd	s7,8(sp)
    800010bc:	0880                	addi	s0,sp,80
    800010be:	8aaa                	mv	s5,a0
    800010c0:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010c2:	777d                	lui	a4,0xfffff
    800010c4:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c8:	167d                	addi	a2,a2,-1
    800010ca:	00b609b3          	add	s3,a2,a1
    800010ce:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010d2:	893e                	mv	s2,a5
    800010d4:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d8:	6b85                	lui	s7,0x1
    800010da:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010de:	4605                	li	a2,1
    800010e0:	85ca                	mv	a1,s2
    800010e2:	8556                	mv	a0,s5
    800010e4:	00000097          	auipc	ra,0x0
    800010e8:	edc080e7          	jalr	-292(ra) # 80000fc0 <walk>
    800010ec:	c51d                	beqz	a0,8000111a <mappages+0x72>
    if(*pte & PTE_V)
    800010ee:	611c                	ld	a5,0(a0)
    800010f0:	8b85                	andi	a5,a5,1
    800010f2:	ef81                	bnez	a5,8000110a <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010f4:	80b1                	srli	s1,s1,0xc
    800010f6:	04aa                	slli	s1,s1,0xa
    800010f8:	0164e4b3          	or	s1,s1,s6
    800010fc:	0014e493          	ori	s1,s1,1
    80001100:	e104                	sd	s1,0(a0)
    if(a == last)
    80001102:	03390863          	beq	s2,s3,80001132 <mappages+0x8a>
    a += PGSIZE;
    80001106:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001108:	bfc9                	j	800010da <mappages+0x32>
      panic("remap");
    8000110a:	00008517          	auipc	a0,0x8
    8000110e:	ffe50513          	addi	a0,a0,-2 # 80009108 <digits+0xc8>
    80001112:	fffff097          	auipc	ra,0xfffff
    80001116:	41c080e7          	jalr	1052(ra) # 8000052e <panic>
      return -1;
    8000111a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111c:	60a6                	ld	ra,72(sp)
    8000111e:	6406                	ld	s0,64(sp)
    80001120:	74e2                	ld	s1,56(sp)
    80001122:	7942                	ld	s2,48(sp)
    80001124:	79a2                	ld	s3,40(sp)
    80001126:	7a02                	ld	s4,32(sp)
    80001128:	6ae2                	ld	s5,24(sp)
    8000112a:	6b42                	ld	s6,16(sp)
    8000112c:	6ba2                	ld	s7,8(sp)
    8000112e:	6161                	addi	sp,sp,80
    80001130:	8082                	ret
  return 0;
    80001132:	4501                	li	a0,0
    80001134:	b7e5                	j	8000111c <mappages+0x74>

0000000080001136 <kvmmap>:
{
    80001136:	1141                	addi	sp,sp,-16
    80001138:	e406                	sd	ra,8(sp)
    8000113a:	e022                	sd	s0,0(sp)
    8000113c:	0800                	addi	s0,sp,16
    8000113e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001140:	86b2                	mv	a3,a2
    80001142:	863e                	mv	a2,a5
    80001144:	00000097          	auipc	ra,0x0
    80001148:	f64080e7          	jalr	-156(ra) # 800010a8 <mappages>
    8000114c:	e509                	bnez	a0,80001156 <kvmmap+0x20>
}
    8000114e:	60a2                	ld	ra,8(sp)
    80001150:	6402                	ld	s0,0(sp)
    80001152:	0141                	addi	sp,sp,16
    80001154:	8082                	ret
    panic("kvmmap");
    80001156:	00008517          	auipc	a0,0x8
    8000115a:	fba50513          	addi	a0,a0,-70 # 80009110 <digits+0xd0>
    8000115e:	fffff097          	auipc	ra,0xfffff
    80001162:	3d0080e7          	jalr	976(ra) # 8000052e <panic>

0000000080001166 <kvmmake>:
{
    80001166:	1101                	addi	sp,sp,-32
    80001168:	ec06                	sd	ra,24(sp)
    8000116a:	e822                	sd	s0,16(sp)
    8000116c:	e426                	sd	s1,8(sp)
    8000116e:	e04a                	sd	s2,0(sp)
    80001170:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001172:	00000097          	auipc	ra,0x0
    80001176:	964080e7          	jalr	-1692(ra) # 80000ad6 <kalloc>
    8000117a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117c:	6605                	lui	a2,0x1
    8000117e:	4581                	li	a1,0
    80001180:	00000097          	auipc	ra,0x0
    80001184:	b58080e7          	jalr	-1192(ra) # 80000cd8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001188:	4719                	li	a4,6
    8000118a:	6685                	lui	a3,0x1
    8000118c:	10000637          	lui	a2,0x10000
    80001190:	100005b7          	lui	a1,0x10000
    80001194:	8526                	mv	a0,s1
    80001196:	00000097          	auipc	ra,0x0
    8000119a:	fa0080e7          	jalr	-96(ra) # 80001136 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000119e:	4719                	li	a4,6
    800011a0:	6685                	lui	a3,0x1
    800011a2:	10001637          	lui	a2,0x10001
    800011a6:	100015b7          	lui	a1,0x10001
    800011aa:	8526                	mv	a0,s1
    800011ac:	00000097          	auipc	ra,0x0
    800011b0:	f8a080e7          	jalr	-118(ra) # 80001136 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b4:	4719                	li	a4,6
    800011b6:	004006b7          	lui	a3,0x400
    800011ba:	0c000637          	lui	a2,0xc000
    800011be:	0c0005b7          	lui	a1,0xc000
    800011c2:	8526                	mv	a0,s1
    800011c4:	00000097          	auipc	ra,0x0
    800011c8:	f72080e7          	jalr	-142(ra) # 80001136 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011cc:	00008917          	auipc	s2,0x8
    800011d0:	e3490913          	addi	s2,s2,-460 # 80009000 <etext>
    800011d4:	4729                	li	a4,10
    800011d6:	80008697          	auipc	a3,0x80008
    800011da:	e2a68693          	addi	a3,a3,-470 # 9000 <_entry-0x7fff7000>
    800011de:	4605                	li	a2,1
    800011e0:	067e                	slli	a2,a2,0x1f
    800011e2:	85b2                	mv	a1,a2
    800011e4:	8526                	mv	a0,s1
    800011e6:	00000097          	auipc	ra,0x0
    800011ea:	f50080e7          	jalr	-176(ra) # 80001136 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011ee:	4719                	li	a4,6
    800011f0:	46c5                	li	a3,17
    800011f2:	06ee                	slli	a3,a3,0x1b
    800011f4:	412686b3          	sub	a3,a3,s2
    800011f8:	864a                	mv	a2,s2
    800011fa:	85ca                	mv	a1,s2
    800011fc:	8526                	mv	a0,s1
    800011fe:	00000097          	auipc	ra,0x0
    80001202:	f38080e7          	jalr	-200(ra) # 80001136 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001206:	4729                	li	a4,10
    80001208:	6685                	lui	a3,0x1
    8000120a:	00007617          	auipc	a2,0x7
    8000120e:	df660613          	addi	a2,a2,-522 # 80008000 <_trampoline>
    80001212:	040005b7          	lui	a1,0x4000
    80001216:	15fd                	addi	a1,a1,-1
    80001218:	05b2                	slli	a1,a1,0xc
    8000121a:	8526                	mv	a0,s1
    8000121c:	00000097          	auipc	ra,0x0
    80001220:	f1a080e7          	jalr	-230(ra) # 80001136 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	600080e7          	jalr	1536(ra) # 80001826 <proc_mapstacks>
}
    8000122e:	8526                	mv	a0,s1
    80001230:	60e2                	ld	ra,24(sp)
    80001232:	6442                	ld	s0,16(sp)
    80001234:	64a2                	ld	s1,8(sp)
    80001236:	6902                	ld	s2,0(sp)
    80001238:	6105                	addi	sp,sp,32
    8000123a:	8082                	ret

000000008000123c <kvminit>:
{
    8000123c:	1141                	addi	sp,sp,-16
    8000123e:	e406                	sd	ra,8(sp)
    80001240:	e022                	sd	s0,0(sp)
    80001242:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001244:	00000097          	auipc	ra,0x0
    80001248:	f22080e7          	jalr	-222(ra) # 80001166 <kvmmake>
    8000124c:	00009797          	auipc	a5,0x9
    80001250:	dca7ba23          	sd	a0,-556(a5) # 8000a020 <kernel_pagetable>
}
    80001254:	60a2                	ld	ra,8(sp)
    80001256:	6402                	ld	s0,0(sp)
    80001258:	0141                	addi	sp,sp,16
    8000125a:	8082                	ret

000000008000125c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125c:	715d                	addi	sp,sp,-80
    8000125e:	e486                	sd	ra,72(sp)
    80001260:	e0a2                	sd	s0,64(sp)
    80001262:	fc26                	sd	s1,56(sp)
    80001264:	f84a                	sd	s2,48(sp)
    80001266:	f44e                	sd	s3,40(sp)
    80001268:	f052                	sd	s4,32(sp)
    8000126a:	ec56                	sd	s5,24(sp)
    8000126c:	e85a                	sd	s6,16(sp)
    8000126e:	e45e                	sd	s7,8(sp)
    80001270:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001272:	03459793          	slli	a5,a1,0x34
    80001276:	e795                	bnez	a5,800012a2 <uvmunmap+0x46>
    80001278:	8a2a                	mv	s4,a0
    8000127a:	892e                	mv	s2,a1
    8000127c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000127e:	0632                	slli	a2,a2,0xc
    80001280:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001284:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	6b05                	lui	s6,0x1
    80001288:	0735e263          	bltu	a1,s3,800012ec <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128c:	60a6                	ld	ra,72(sp)
    8000128e:	6406                	ld	s0,64(sp)
    80001290:	74e2                	ld	s1,56(sp)
    80001292:	7942                	ld	s2,48(sp)
    80001294:	79a2                	ld	s3,40(sp)
    80001296:	7a02                	ld	s4,32(sp)
    80001298:	6ae2                	ld	s5,24(sp)
    8000129a:	6b42                	ld	s6,16(sp)
    8000129c:	6ba2                	ld	s7,8(sp)
    8000129e:	6161                	addi	sp,sp,80
    800012a0:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a2:	00008517          	auipc	a0,0x8
    800012a6:	e7650513          	addi	a0,a0,-394 # 80009118 <digits+0xd8>
    800012aa:	fffff097          	auipc	ra,0xfffff
    800012ae:	284080e7          	jalr	644(ra) # 8000052e <panic>
      panic("uvmunmap: walk");
    800012b2:	00008517          	auipc	a0,0x8
    800012b6:	e7e50513          	addi	a0,a0,-386 # 80009130 <digits+0xf0>
    800012ba:	fffff097          	auipc	ra,0xfffff
    800012be:	274080e7          	jalr	628(ra) # 8000052e <panic>
      panic("uvmunmap: not mapped");
    800012c2:	00008517          	auipc	a0,0x8
    800012c6:	e7e50513          	addi	a0,a0,-386 # 80009140 <digits+0x100>
    800012ca:	fffff097          	auipc	ra,0xfffff
    800012ce:	264080e7          	jalr	612(ra) # 8000052e <panic>
      panic("uvmunmap: not a leaf");
    800012d2:	00008517          	auipc	a0,0x8
    800012d6:	e8650513          	addi	a0,a0,-378 # 80009158 <digits+0x118>
    800012da:	fffff097          	auipc	ra,0xfffff
    800012de:	254080e7          	jalr	596(ra) # 8000052e <panic>
    *pte = 0;
    800012e2:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e6:	995a                	add	s2,s2,s6
    800012e8:	fb3972e3          	bgeu	s2,s3,8000128c <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012ec:	4601                	li	a2,0
    800012ee:	85ca                	mv	a1,s2
    800012f0:	8552                	mv	a0,s4
    800012f2:	00000097          	auipc	ra,0x0
    800012f6:	cce080e7          	jalr	-818(ra) # 80000fc0 <walk>
    800012fa:	84aa                	mv	s1,a0
    800012fc:	d95d                	beqz	a0,800012b2 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012fe:	6108                	ld	a0,0(a0)
    80001300:	00157793          	andi	a5,a0,1
    80001304:	dfdd                	beqz	a5,800012c2 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001306:	3ff57793          	andi	a5,a0,1023
    8000130a:	fd7784e3          	beq	a5,s7,800012d2 <uvmunmap+0x76>
    if(do_free){
    8000130e:	fc0a8ae3          	beqz	s5,800012e2 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001312:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001314:	0532                	slli	a0,a0,0xc
    80001316:	fffff097          	auipc	ra,0xfffff
    8000131a:	6c4080e7          	jalr	1732(ra) # 800009da <kfree>
    8000131e:	b7d1                	j	800012e2 <uvmunmap+0x86>

0000000080001320 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001320:	1101                	addi	sp,sp,-32
    80001322:	ec06                	sd	ra,24(sp)
    80001324:	e822                	sd	s0,16(sp)
    80001326:	e426                	sd	s1,8(sp)
    80001328:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000132a:	fffff097          	auipc	ra,0xfffff
    8000132e:	7ac080e7          	jalr	1964(ra) # 80000ad6 <kalloc>
    80001332:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001334:	c519                	beqz	a0,80001342 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001336:	6605                	lui	a2,0x1
    80001338:	4581                	li	a1,0
    8000133a:	00000097          	auipc	ra,0x0
    8000133e:	99e080e7          	jalr	-1634(ra) # 80000cd8 <memset>
  return pagetable;
}
    80001342:	8526                	mv	a0,s1
    80001344:	60e2                	ld	ra,24(sp)
    80001346:	6442                	ld	s0,16(sp)
    80001348:	64a2                	ld	s1,8(sp)
    8000134a:	6105                	addi	sp,sp,32
    8000134c:	8082                	ret

000000008000134e <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000134e:	7179                	addi	sp,sp,-48
    80001350:	f406                	sd	ra,40(sp)
    80001352:	f022                	sd	s0,32(sp)
    80001354:	ec26                	sd	s1,24(sp)
    80001356:	e84a                	sd	s2,16(sp)
    80001358:	e44e                	sd	s3,8(sp)
    8000135a:	e052                	sd	s4,0(sp)
    8000135c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000135e:	6785                	lui	a5,0x1
    80001360:	04f67863          	bgeu	a2,a5,800013b0 <uvminit+0x62>
    80001364:	8a2a                	mv	s4,a0
    80001366:	89ae                	mv	s3,a1
    80001368:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000136a:	fffff097          	auipc	ra,0xfffff
    8000136e:	76c080e7          	jalr	1900(ra) # 80000ad6 <kalloc>
    80001372:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001374:	6605                	lui	a2,0x1
    80001376:	4581                	li	a1,0
    80001378:	00000097          	auipc	ra,0x0
    8000137c:	960080e7          	jalr	-1696(ra) # 80000cd8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001380:	4779                	li	a4,30
    80001382:	86ca                	mv	a3,s2
    80001384:	6605                	lui	a2,0x1
    80001386:	4581                	li	a1,0
    80001388:	8552                	mv	a0,s4
    8000138a:	00000097          	auipc	ra,0x0
    8000138e:	d1e080e7          	jalr	-738(ra) # 800010a8 <mappages>
  memmove(mem, src, sz);
    80001392:	8626                	mv	a2,s1
    80001394:	85ce                	mv	a1,s3
    80001396:	854a                	mv	a0,s2
    80001398:	00000097          	auipc	ra,0x0
    8000139c:	99c080e7          	jalr	-1636(ra) # 80000d34 <memmove>
}
    800013a0:	70a2                	ld	ra,40(sp)
    800013a2:	7402                	ld	s0,32(sp)
    800013a4:	64e2                	ld	s1,24(sp)
    800013a6:	6942                	ld	s2,16(sp)
    800013a8:	69a2                	ld	s3,8(sp)
    800013aa:	6a02                	ld	s4,0(sp)
    800013ac:	6145                	addi	sp,sp,48
    800013ae:	8082                	ret
    panic("inituvm: more than a page");
    800013b0:	00008517          	auipc	a0,0x8
    800013b4:	dc050513          	addi	a0,a0,-576 # 80009170 <digits+0x130>
    800013b8:	fffff097          	auipc	ra,0xfffff
    800013bc:	176080e7          	jalr	374(ra) # 8000052e <panic>

00000000800013c0 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c0:	1101                	addi	sp,sp,-32
    800013c2:	ec06                	sd	ra,24(sp)
    800013c4:	e822                	sd	s0,16(sp)
    800013c6:	e426                	sd	s1,8(sp)
    800013c8:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013ca:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013cc:	00b67d63          	bgeu	a2,a1,800013e6 <uvmdealloc+0x26>
    800013d0:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d2:	6785                	lui	a5,0x1
    800013d4:	17fd                	addi	a5,a5,-1
    800013d6:	00f60733          	add	a4,a2,a5
    800013da:	767d                	lui	a2,0xfffff
    800013dc:	8f71                	and	a4,a4,a2
    800013de:	97ae                	add	a5,a5,a1
    800013e0:	8ff1                	and	a5,a5,a2
    800013e2:	00f76863          	bltu	a4,a5,800013f2 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e6:	8526                	mv	a0,s1
    800013e8:	60e2                	ld	ra,24(sp)
    800013ea:	6442                	ld	s0,16(sp)
    800013ec:	64a2                	ld	s1,8(sp)
    800013ee:	6105                	addi	sp,sp,32
    800013f0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f2:	8f99                	sub	a5,a5,a4
    800013f4:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f6:	4685                	li	a3,1
    800013f8:	0007861b          	sext.w	a2,a5
    800013fc:	85ba                	mv	a1,a4
    800013fe:	00000097          	auipc	ra,0x0
    80001402:	e5e080e7          	jalr	-418(ra) # 8000125c <uvmunmap>
    80001406:	b7c5                	j	800013e6 <uvmdealloc+0x26>

0000000080001408 <uvmalloc>:
  if(newsz < oldsz)
    80001408:	0ab66163          	bltu	a2,a1,800014aa <uvmalloc+0xa2>
{
    8000140c:	7139                	addi	sp,sp,-64
    8000140e:	fc06                	sd	ra,56(sp)
    80001410:	f822                	sd	s0,48(sp)
    80001412:	f426                	sd	s1,40(sp)
    80001414:	f04a                	sd	s2,32(sp)
    80001416:	ec4e                	sd	s3,24(sp)
    80001418:	e852                	sd	s4,16(sp)
    8000141a:	e456                	sd	s5,8(sp)
    8000141c:	0080                	addi	s0,sp,64
    8000141e:	8aaa                	mv	s5,a0
    80001420:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001422:	6985                	lui	s3,0x1
    80001424:	19fd                	addi	s3,s3,-1
    80001426:	95ce                	add	a1,a1,s3
    80001428:	79fd                	lui	s3,0xfffff
    8000142a:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000142e:	08c9f063          	bgeu	s3,a2,800014ae <uvmalloc+0xa6>
    80001432:	894e                	mv	s2,s3
    mem = kalloc();
    80001434:	fffff097          	auipc	ra,0xfffff
    80001438:	6a2080e7          	jalr	1698(ra) # 80000ad6 <kalloc>
    8000143c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000143e:	c51d                	beqz	a0,8000146c <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001440:	6605                	lui	a2,0x1
    80001442:	4581                	li	a1,0
    80001444:	00000097          	auipc	ra,0x0
    80001448:	894080e7          	jalr	-1900(ra) # 80000cd8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000144c:	4779                	li	a4,30
    8000144e:	86a6                	mv	a3,s1
    80001450:	6605                	lui	a2,0x1
    80001452:	85ca                	mv	a1,s2
    80001454:	8556                	mv	a0,s5
    80001456:	00000097          	auipc	ra,0x0
    8000145a:	c52080e7          	jalr	-942(ra) # 800010a8 <mappages>
    8000145e:	e905                	bnez	a0,8000148e <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001460:	6785                	lui	a5,0x1
    80001462:	993e                	add	s2,s2,a5
    80001464:	fd4968e3          	bltu	s2,s4,80001434 <uvmalloc+0x2c>
  return newsz;
    80001468:	8552                	mv	a0,s4
    8000146a:	a809                	j	8000147c <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000146c:	864e                	mv	a2,s3
    8000146e:	85ca                	mv	a1,s2
    80001470:	8556                	mv	a0,s5
    80001472:	00000097          	auipc	ra,0x0
    80001476:	f4e080e7          	jalr	-178(ra) # 800013c0 <uvmdealloc>
      return 0;
    8000147a:	4501                	li	a0,0
}
    8000147c:	70e2                	ld	ra,56(sp)
    8000147e:	7442                	ld	s0,48(sp)
    80001480:	74a2                	ld	s1,40(sp)
    80001482:	7902                	ld	s2,32(sp)
    80001484:	69e2                	ld	s3,24(sp)
    80001486:	6a42                	ld	s4,16(sp)
    80001488:	6aa2                	ld	s5,8(sp)
    8000148a:	6121                	addi	sp,sp,64
    8000148c:	8082                	ret
      kfree(mem);
    8000148e:	8526                	mv	a0,s1
    80001490:	fffff097          	auipc	ra,0xfffff
    80001494:	54a080e7          	jalr	1354(ra) # 800009da <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001498:	864e                	mv	a2,s3
    8000149a:	85ca                	mv	a1,s2
    8000149c:	8556                	mv	a0,s5
    8000149e:	00000097          	auipc	ra,0x0
    800014a2:	f22080e7          	jalr	-222(ra) # 800013c0 <uvmdealloc>
      return 0;
    800014a6:	4501                	li	a0,0
    800014a8:	bfd1                	j	8000147c <uvmalloc+0x74>
    return oldsz;
    800014aa:	852e                	mv	a0,a1
}
    800014ac:	8082                	ret
  return newsz;
    800014ae:	8532                	mv	a0,a2
    800014b0:	b7f1                	j	8000147c <uvmalloc+0x74>

00000000800014b2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014b2:	7179                	addi	sp,sp,-48
    800014b4:	f406                	sd	ra,40(sp)
    800014b6:	f022                	sd	s0,32(sp)
    800014b8:	ec26                	sd	s1,24(sp)
    800014ba:	e84a                	sd	s2,16(sp)
    800014bc:	e44e                	sd	s3,8(sp)
    800014be:	e052                	sd	s4,0(sp)
    800014c0:	1800                	addi	s0,sp,48
    800014c2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014c4:	84aa                	mv	s1,a0
    800014c6:	6905                	lui	s2,0x1
    800014c8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014ca:	4985                	li	s3,1
    800014cc:	a821                	j	800014e4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014ce:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014d0:	0532                	slli	a0,a0,0xc
    800014d2:	00000097          	auipc	ra,0x0
    800014d6:	fe0080e7          	jalr	-32(ra) # 800014b2 <freewalk>
      pagetable[i] = 0;
    800014da:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014de:	04a1                	addi	s1,s1,8
    800014e0:	03248163          	beq	s1,s2,80001502 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014e4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e6:	00f57793          	andi	a5,a0,15
    800014ea:	ff3782e3          	beq	a5,s3,800014ce <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014ee:	8905                	andi	a0,a0,1
    800014f0:	d57d                	beqz	a0,800014de <freewalk+0x2c>
      panic("freewalk: leaf");
    800014f2:	00008517          	auipc	a0,0x8
    800014f6:	c9e50513          	addi	a0,a0,-866 # 80009190 <digits+0x150>
    800014fa:	fffff097          	auipc	ra,0xfffff
    800014fe:	034080e7          	jalr	52(ra) # 8000052e <panic>
    }
  }
  kfree((void*)pagetable);
    80001502:	8552                	mv	a0,s4
    80001504:	fffff097          	auipc	ra,0xfffff
    80001508:	4d6080e7          	jalr	1238(ra) # 800009da <kfree>
}
    8000150c:	70a2                	ld	ra,40(sp)
    8000150e:	7402                	ld	s0,32(sp)
    80001510:	64e2                	ld	s1,24(sp)
    80001512:	6942                	ld	s2,16(sp)
    80001514:	69a2                	ld	s3,8(sp)
    80001516:	6a02                	ld	s4,0(sp)
    80001518:	6145                	addi	sp,sp,48
    8000151a:	8082                	ret

000000008000151c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000151c:	1101                	addi	sp,sp,-32
    8000151e:	ec06                	sd	ra,24(sp)
    80001520:	e822                	sd	s0,16(sp)
    80001522:	e426                	sd	s1,8(sp)
    80001524:	1000                	addi	s0,sp,32
    80001526:	84aa                	mv	s1,a0
  if(sz > 0)
    80001528:	e999                	bnez	a1,8000153e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000152a:	8526                	mv	a0,s1
    8000152c:	00000097          	auipc	ra,0x0
    80001530:	f86080e7          	jalr	-122(ra) # 800014b2 <freewalk>
}
    80001534:	60e2                	ld	ra,24(sp)
    80001536:	6442                	ld	s0,16(sp)
    80001538:	64a2                	ld	s1,8(sp)
    8000153a:	6105                	addi	sp,sp,32
    8000153c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000153e:	6605                	lui	a2,0x1
    80001540:	167d                	addi	a2,a2,-1
    80001542:	962e                	add	a2,a2,a1
    80001544:	4685                	li	a3,1
    80001546:	8231                	srli	a2,a2,0xc
    80001548:	4581                	li	a1,0
    8000154a:	00000097          	auipc	ra,0x0
    8000154e:	d12080e7          	jalr	-750(ra) # 8000125c <uvmunmap>
    80001552:	bfe1                	j	8000152a <uvmfree+0xe>

0000000080001554 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001554:	c679                	beqz	a2,80001622 <uvmcopy+0xce>
{
    80001556:	715d                	addi	sp,sp,-80
    80001558:	e486                	sd	ra,72(sp)
    8000155a:	e0a2                	sd	s0,64(sp)
    8000155c:	fc26                	sd	s1,56(sp)
    8000155e:	f84a                	sd	s2,48(sp)
    80001560:	f44e                	sd	s3,40(sp)
    80001562:	f052                	sd	s4,32(sp)
    80001564:	ec56                	sd	s5,24(sp)
    80001566:	e85a                	sd	s6,16(sp)
    80001568:	e45e                	sd	s7,8(sp)
    8000156a:	0880                	addi	s0,sp,80
    8000156c:	8b2a                	mv	s6,a0
    8000156e:	8aae                	mv	s5,a1
    80001570:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001572:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001574:	4601                	li	a2,0
    80001576:	85ce                	mv	a1,s3
    80001578:	855a                	mv	a0,s6
    8000157a:	00000097          	auipc	ra,0x0
    8000157e:	a46080e7          	jalr	-1466(ra) # 80000fc0 <walk>
    80001582:	c531                	beqz	a0,800015ce <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001584:	6118                	ld	a4,0(a0)
    80001586:	00177793          	andi	a5,a4,1
    8000158a:	cbb1                	beqz	a5,800015de <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000158c:	00a75593          	srli	a1,a4,0xa
    80001590:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001594:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001598:	fffff097          	auipc	ra,0xfffff
    8000159c:	53e080e7          	jalr	1342(ra) # 80000ad6 <kalloc>
    800015a0:	892a                	mv	s2,a0
    800015a2:	c939                	beqz	a0,800015f8 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015a4:	6605                	lui	a2,0x1
    800015a6:	85de                	mv	a1,s7
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	78c080e7          	jalr	1932(ra) # 80000d34 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015b0:	8726                	mv	a4,s1
    800015b2:	86ca                	mv	a3,s2
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85ce                	mv	a1,s3
    800015b8:	8556                	mv	a0,s5
    800015ba:	00000097          	auipc	ra,0x0
    800015be:	aee080e7          	jalr	-1298(ra) # 800010a8 <mappages>
    800015c2:	e515                	bnez	a0,800015ee <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015c4:	6785                	lui	a5,0x1
    800015c6:	99be                	add	s3,s3,a5
    800015c8:	fb49e6e3          	bltu	s3,s4,80001574 <uvmcopy+0x20>
    800015cc:	a081                	j	8000160c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015ce:	00008517          	auipc	a0,0x8
    800015d2:	bd250513          	addi	a0,a0,-1070 # 800091a0 <digits+0x160>
    800015d6:	fffff097          	auipc	ra,0xfffff
    800015da:	f58080e7          	jalr	-168(ra) # 8000052e <panic>
      panic("uvmcopy: page not present");
    800015de:	00008517          	auipc	a0,0x8
    800015e2:	be250513          	addi	a0,a0,-1054 # 800091c0 <digits+0x180>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f48080e7          	jalr	-184(ra) # 8000052e <panic>
      kfree(mem);
    800015ee:	854a                	mv	a0,s2
    800015f0:	fffff097          	auipc	ra,0xfffff
    800015f4:	3ea080e7          	jalr	1002(ra) # 800009da <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015f8:	4685                	li	a3,1
    800015fa:	00c9d613          	srli	a2,s3,0xc
    800015fe:	4581                	li	a1,0
    80001600:	8556                	mv	a0,s5
    80001602:	00000097          	auipc	ra,0x0
    80001606:	c5a080e7          	jalr	-934(ra) # 8000125c <uvmunmap>
  return -1;
    8000160a:	557d                	li	a0,-1
}
    8000160c:	60a6                	ld	ra,72(sp)
    8000160e:	6406                	ld	s0,64(sp)
    80001610:	74e2                	ld	s1,56(sp)
    80001612:	7942                	ld	s2,48(sp)
    80001614:	79a2                	ld	s3,40(sp)
    80001616:	7a02                	ld	s4,32(sp)
    80001618:	6ae2                	ld	s5,24(sp)
    8000161a:	6b42                	ld	s6,16(sp)
    8000161c:	6ba2                	ld	s7,8(sp)
    8000161e:	6161                	addi	sp,sp,80
    80001620:	8082                	ret
  return 0;
    80001622:	4501                	li	a0,0
}
    80001624:	8082                	ret

0000000080001626 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001626:	1141                	addi	sp,sp,-16
    80001628:	e406                	sd	ra,8(sp)
    8000162a:	e022                	sd	s0,0(sp)
    8000162c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000162e:	4601                	li	a2,0
    80001630:	00000097          	auipc	ra,0x0
    80001634:	990080e7          	jalr	-1648(ra) # 80000fc0 <walk>
  if(pte == 0)
    80001638:	c901                	beqz	a0,80001648 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000163a:	611c                	ld	a5,0(a0)
    8000163c:	9bbd                	andi	a5,a5,-17
    8000163e:	e11c                	sd	a5,0(a0)
}
    80001640:	60a2                	ld	ra,8(sp)
    80001642:	6402                	ld	s0,0(sp)
    80001644:	0141                	addi	sp,sp,16
    80001646:	8082                	ret
    panic("uvmclear");
    80001648:	00008517          	auipc	a0,0x8
    8000164c:	b9850513          	addi	a0,a0,-1128 # 800091e0 <digits+0x1a0>
    80001650:	fffff097          	auipc	ra,0xfffff
    80001654:	ede080e7          	jalr	-290(ra) # 8000052e <panic>

0000000080001658 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001658:	c6bd                	beqz	a3,800016c6 <copyout+0x6e>
{
    8000165a:	715d                	addi	sp,sp,-80
    8000165c:	e486                	sd	ra,72(sp)
    8000165e:	e0a2                	sd	s0,64(sp)
    80001660:	fc26                	sd	s1,56(sp)
    80001662:	f84a                	sd	s2,48(sp)
    80001664:	f44e                	sd	s3,40(sp)
    80001666:	f052                	sd	s4,32(sp)
    80001668:	ec56                	sd	s5,24(sp)
    8000166a:	e85a                	sd	s6,16(sp)
    8000166c:	e45e                	sd	s7,8(sp)
    8000166e:	e062                	sd	s8,0(sp)
    80001670:	0880                	addi	s0,sp,80
    80001672:	8b2a                	mv	s6,a0
    80001674:	8c2e                	mv	s8,a1
    80001676:	8a32                	mv	s4,a2
    80001678:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000167a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000167c:	6a85                	lui	s5,0x1
    8000167e:	a015                	j	800016a2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001680:	9562                	add	a0,a0,s8
    80001682:	0004861b          	sext.w	a2,s1
    80001686:	85d2                	mv	a1,s4
    80001688:	41250533          	sub	a0,a0,s2
    8000168c:	fffff097          	auipc	ra,0xfffff
    80001690:	6a8080e7          	jalr	1704(ra) # 80000d34 <memmove>

    len -= n;
    80001694:	409989b3          	sub	s3,s3,s1
    src += n;
    80001698:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000169a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000169e:	02098263          	beqz	s3,800016c2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016a2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016a6:	85ca                	mv	a1,s2
    800016a8:	855a                	mv	a0,s6
    800016aa:	00000097          	auipc	ra,0x0
    800016ae:	9bc080e7          	jalr	-1604(ra) # 80001066 <walkaddr>
    if(pa0 == 0)
    800016b2:	cd01                	beqz	a0,800016ca <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016b4:	418904b3          	sub	s1,s2,s8
    800016b8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ba:	fc99f3e3          	bgeu	s3,s1,80001680 <copyout+0x28>
    800016be:	84ce                	mv	s1,s3
    800016c0:	b7c1                	j	80001680 <copyout+0x28>
  }
  return 0;
    800016c2:	4501                	li	a0,0
    800016c4:	a021                	j	800016cc <copyout+0x74>
    800016c6:	4501                	li	a0,0
}
    800016c8:	8082                	ret
      return -1;
    800016ca:	557d                	li	a0,-1
}
    800016cc:	60a6                	ld	ra,72(sp)
    800016ce:	6406                	ld	s0,64(sp)
    800016d0:	74e2                	ld	s1,56(sp)
    800016d2:	7942                	ld	s2,48(sp)
    800016d4:	79a2                	ld	s3,40(sp)
    800016d6:	7a02                	ld	s4,32(sp)
    800016d8:	6ae2                	ld	s5,24(sp)
    800016da:	6b42                	ld	s6,16(sp)
    800016dc:	6ba2                	ld	s7,8(sp)
    800016de:	6c02                	ld	s8,0(sp)
    800016e0:	6161                	addi	sp,sp,80
    800016e2:	8082                	ret

00000000800016e4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e4:	caa5                	beqz	a3,80001754 <copyin+0x70>
{
    800016e6:	715d                	addi	sp,sp,-80
    800016e8:	e486                	sd	ra,72(sp)
    800016ea:	e0a2                	sd	s0,64(sp)
    800016ec:	fc26                	sd	s1,56(sp)
    800016ee:	f84a                	sd	s2,48(sp)
    800016f0:	f44e                	sd	s3,40(sp)
    800016f2:	f052                	sd	s4,32(sp)
    800016f4:	ec56                	sd	s5,24(sp)
    800016f6:	e85a                	sd	s6,16(sp)
    800016f8:	e45e                	sd	s7,8(sp)
    800016fa:	e062                	sd	s8,0(sp)
    800016fc:	0880                	addi	s0,sp,80
    800016fe:	8b2a                	mv	s6,a0
    80001700:	8a2e                	mv	s4,a1
    80001702:	8c32                	mv	s8,a2
    80001704:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001706:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001708:	6a85                	lui	s5,0x1
    8000170a:	a01d                	j	80001730 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000170c:	018505b3          	add	a1,a0,s8
    80001710:	0004861b          	sext.w	a2,s1
    80001714:	412585b3          	sub	a1,a1,s2
    80001718:	8552                	mv	a0,s4
    8000171a:	fffff097          	auipc	ra,0xfffff
    8000171e:	61a080e7          	jalr	1562(ra) # 80000d34 <memmove>

    len -= n;
    80001722:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001726:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001728:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000172c:	02098263          	beqz	s3,80001750 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001730:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001734:	85ca                	mv	a1,s2
    80001736:	855a                	mv	a0,s6
    80001738:	00000097          	auipc	ra,0x0
    8000173c:	92e080e7          	jalr	-1746(ra) # 80001066 <walkaddr>
    if(pa0 == 0)
    80001740:	cd01                	beqz	a0,80001758 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001742:	418904b3          	sub	s1,s2,s8
    80001746:	94d6                	add	s1,s1,s5
    if(n > len)
    80001748:	fc99f2e3          	bgeu	s3,s1,8000170c <copyin+0x28>
    8000174c:	84ce                	mv	s1,s3
    8000174e:	bf7d                	j	8000170c <copyin+0x28>
  }
  return 0;
    80001750:	4501                	li	a0,0
    80001752:	a021                	j	8000175a <copyin+0x76>
    80001754:	4501                	li	a0,0
}
    80001756:	8082                	ret
      return -1;
    80001758:	557d                	li	a0,-1
}
    8000175a:	60a6                	ld	ra,72(sp)
    8000175c:	6406                	ld	s0,64(sp)
    8000175e:	74e2                	ld	s1,56(sp)
    80001760:	7942                	ld	s2,48(sp)
    80001762:	79a2                	ld	s3,40(sp)
    80001764:	7a02                	ld	s4,32(sp)
    80001766:	6ae2                	ld	s5,24(sp)
    80001768:	6b42                	ld	s6,16(sp)
    8000176a:	6ba2                	ld	s7,8(sp)
    8000176c:	6c02                	ld	s8,0(sp)
    8000176e:	6161                	addi	sp,sp,80
    80001770:	8082                	ret

0000000080001772 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001772:	c6c5                	beqz	a3,8000181a <copyinstr+0xa8>
{
    80001774:	715d                	addi	sp,sp,-80
    80001776:	e486                	sd	ra,72(sp)
    80001778:	e0a2                	sd	s0,64(sp)
    8000177a:	fc26                	sd	s1,56(sp)
    8000177c:	f84a                	sd	s2,48(sp)
    8000177e:	f44e                	sd	s3,40(sp)
    80001780:	f052                	sd	s4,32(sp)
    80001782:	ec56                	sd	s5,24(sp)
    80001784:	e85a                	sd	s6,16(sp)
    80001786:	e45e                	sd	s7,8(sp)
    80001788:	0880                	addi	s0,sp,80
    8000178a:	8a2a                	mv	s4,a0
    8000178c:	8b2e                	mv	s6,a1
    8000178e:	8bb2                	mv	s7,a2
    80001790:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001792:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001794:	6985                	lui	s3,0x1
    80001796:	a035                	j	800017c2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001798:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000179c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000179e:	0017b793          	seqz	a5,a5
    800017a2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017a6:	60a6                	ld	ra,72(sp)
    800017a8:	6406                	ld	s0,64(sp)
    800017aa:	74e2                	ld	s1,56(sp)
    800017ac:	7942                	ld	s2,48(sp)
    800017ae:	79a2                	ld	s3,40(sp)
    800017b0:	7a02                	ld	s4,32(sp)
    800017b2:	6ae2                	ld	s5,24(sp)
    800017b4:	6b42                	ld	s6,16(sp)
    800017b6:	6ba2                	ld	s7,8(sp)
    800017b8:	6161                	addi	sp,sp,80
    800017ba:	8082                	ret
    srcva = va0 + PGSIZE;
    800017bc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017c0:	c8a9                	beqz	s1,80001812 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017c2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017c6:	85ca                	mv	a1,s2
    800017c8:	8552                	mv	a0,s4
    800017ca:	00000097          	auipc	ra,0x0
    800017ce:	89c080e7          	jalr	-1892(ra) # 80001066 <walkaddr>
    if(pa0 == 0)
    800017d2:	c131                	beqz	a0,80001816 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017d4:	41790833          	sub	a6,s2,s7
    800017d8:	984e                	add	a6,a6,s3
    if(n > max)
    800017da:	0104f363          	bgeu	s1,a6,800017e0 <copyinstr+0x6e>
    800017de:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017e0:	955e                	add	a0,a0,s7
    800017e2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017e6:	fc080be3          	beqz	a6,800017bc <copyinstr+0x4a>
    800017ea:	985a                	add	a6,a6,s6
    800017ec:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017ee:	41650633          	sub	a2,a0,s6
    800017f2:	14fd                	addi	s1,s1,-1
    800017f4:	9b26                	add	s6,s6,s1
    800017f6:	00f60733          	add	a4,a2,a5
    800017fa:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffbd000>
    800017fe:	df49                	beqz	a4,80001798 <copyinstr+0x26>
        *dst = *p;
    80001800:	00e78023          	sb	a4,0(a5)
      --max;
    80001804:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001808:	0785                	addi	a5,a5,1
    while(n > 0){
    8000180a:	ff0796e3          	bne	a5,a6,800017f6 <copyinstr+0x84>
      dst++;
    8000180e:	8b42                	mv	s6,a6
    80001810:	b775                	j	800017bc <copyinstr+0x4a>
    80001812:	4781                	li	a5,0
    80001814:	b769                	j	8000179e <copyinstr+0x2c>
      return -1;
    80001816:	557d                	li	a0,-1
    80001818:	b779                	j	800017a6 <copyinstr+0x34>
  int got_null = 0;
    8000181a:	4781                	li	a5,0
  if(got_null){
    8000181c:	0017b793          	seqz	a5,a5
    80001820:	40f00533          	neg	a0,a5
}
    80001824:	8082                	ret

0000000080001826 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001826:	711d                	addi	sp,sp,-96
    80001828:	ec86                	sd	ra,88(sp)
    8000182a:	e8a2                	sd	s0,80(sp)
    8000182c:	e4a6                	sd	s1,72(sp)
    8000182e:	e0ca                	sd	s2,64(sp)
    80001830:	fc4e                	sd	s3,56(sp)
    80001832:	f852                	sd	s4,48(sp)
    80001834:	f456                	sd	s5,40(sp)
    80001836:	f05a                	sd	s6,32(sp)
    80001838:	ec5e                	sd	s7,24(sp)
    8000183a:	e862                	sd	s8,16(sp)
    8000183c:	e466                	sd	s9,8(sp)
    8000183e:	e06a                	sd	s10,0(sp)
    80001840:	1080                	addi	s0,sp,96
    80001842:	8b2a                	mv	s6,a0
  struct proc *p;
  struct kthread *t;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001844:	00011997          	auipc	s3,0x11
    80001848:	72c98993          	addi	s3,s3,1836 # 80012f70 <proc+0x848>
    8000184c:	00033d17          	auipc	s10,0x33
    80001850:	924d0d13          	addi	s10,s10,-1756 # 80034170 <bcache+0x830>
    int proc_index= (int)(p-proc);
    80001854:	7c7d                	lui	s8,0xfffff
    80001856:	7b8c0c13          	addi	s8,s8,1976 # fffffffffffff7b8 <end+0xffffffff7ffbd7b8>
    8000185a:	00007c97          	auipc	s9,0x7
    8000185e:	7a6cbc83          	ld	s9,1958(s9) # 80009000 <etext>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      int thread_index = (int)(t-p->kthreads);
    80001862:	00007b97          	auipc	s7,0x7
    80001866:	7a6b8b93          	addi	s7,s7,1958 # 80009008 <etext+0x8>
      uint64 va = KSTACK( proc_index * NTHREAD + thread_index);
    8000186a:	04000ab7          	lui	s5,0x4000
    8000186e:	1afd                	addi	s5,s5,-1
    80001870:	0ab2                	slli	s5,s5,0xc
    80001872:	a839                	j	80001890 <proc_mapstacks+0x6a>
        panic("kalloc");
    80001874:	00008517          	auipc	a0,0x8
    80001878:	97c50513          	addi	a0,a0,-1668 # 800091f0 <digits+0x1b0>
    8000187c:	fffff097          	auipc	ra,0xfffff
    80001880:	cb2080e7          	jalr	-846(ra) # 8000052e <panic>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001884:	6785                	lui	a5,0x1
    80001886:	84878793          	addi	a5,a5,-1976 # 848 <_entry-0x7ffff7b8>
    8000188a:	99be                	add	s3,s3,a5
    8000188c:	07a98363          	beq	s3,s10,800018f2 <proc_mapstacks+0xcc>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001890:	a4098a13          	addi	s4,s3,-1472
    int proc_index= (int)(p-proc);
    80001894:	01898933          	add	s2,s3,s8
    80001898:	00011797          	auipc	a5,0x11
    8000189c:	e9078793          	addi	a5,a5,-368 # 80012728 <proc>
    800018a0:	40f90933          	sub	s2,s2,a5
    800018a4:	40395913          	srai	s2,s2,0x3
    800018a8:	03990933          	mul	s2,s2,s9
    800018ac:	0039191b          	slliw	s2,s2,0x3
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    800018b0:	84d2                	mv	s1,s4
      char *pa = kalloc();
    800018b2:	fffff097          	auipc	ra,0xfffff
    800018b6:	224080e7          	jalr	548(ra) # 80000ad6 <kalloc>
    800018ba:	862a                	mv	a2,a0
      if(pa == 0)
    800018bc:	dd45                	beqz	a0,80001874 <proc_mapstacks+0x4e>
      int thread_index = (int)(t-p->kthreads);
    800018be:	414485b3          	sub	a1,s1,s4
    800018c2:	858d                	srai	a1,a1,0x3
    800018c4:	000bb783          	ld	a5,0(s7)
    800018c8:	02f585b3          	mul	a1,a1,a5
      uint64 va = KSTACK( proc_index * NTHREAD + thread_index);
    800018cc:	012585bb          	addw	a1,a1,s2
    800018d0:	2585                	addiw	a1,a1,1
    800018d2:	00d5959b          	slliw	a1,a1,0xd
      kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018d6:	4719                	li	a4,6
    800018d8:	6685                	lui	a3,0x1
    800018da:	40ba85b3          	sub	a1,s5,a1
    800018de:	855a                	mv	a0,s6
    800018e0:	00000097          	auipc	ra,0x0
    800018e4:	856080e7          	jalr	-1962(ra) # 80001136 <kvmmap>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    800018e8:	0b848493          	addi	s1,s1,184
    800018ec:	fd3493e3          	bne	s1,s3,800018b2 <proc_mapstacks+0x8c>
    800018f0:	bf51                	j	80001884 <proc_mapstacks+0x5e>
    }
  }
}
    800018f2:	60e6                	ld	ra,88(sp)
    800018f4:	6446                	ld	s0,80(sp)
    800018f6:	64a6                	ld	s1,72(sp)
    800018f8:	6906                	ld	s2,64(sp)
    800018fa:	79e2                	ld	s3,56(sp)
    800018fc:	7a42                	ld	s4,48(sp)
    800018fe:	7aa2                	ld	s5,40(sp)
    80001900:	7b02                	ld	s6,32(sp)
    80001902:	6be2                	ld	s7,24(sp)
    80001904:	6c42                	ld	s8,16(sp)
    80001906:	6ca2                	ld	s9,8(sp)
    80001908:	6d02                	ld	s10,0(sp)
    8000190a:	6125                	addi	sp,sp,96
    8000190c:	8082                	ret

000000008000190e <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    8000190e:	7159                	addi	sp,sp,-112
    80001910:	f486                	sd	ra,104(sp)
    80001912:	f0a2                	sd	s0,96(sp)
    80001914:	eca6                	sd	s1,88(sp)
    80001916:	e8ca                	sd	s2,80(sp)
    80001918:	e4ce                	sd	s3,72(sp)
    8000191a:	e0d2                	sd	s4,64(sp)
    8000191c:	fc56                	sd	s5,56(sp)
    8000191e:	f85a                	sd	s6,48(sp)
    80001920:	f45e                	sd	s7,40(sp)
    80001922:	f062                	sd	s8,32(sp)
    80001924:	ec66                	sd	s9,24(sp)
    80001926:	e86a                	sd	s10,16(sp)
    80001928:	e46e                	sd	s11,8(sp)
    8000192a:	1880                	addi	s0,sp,112
  struct proc *p;
  struct kthread *t;
  
  initlock(&pid_lock, "nextpid");
    8000192c:	00008597          	auipc	a1,0x8
    80001930:	8cc58593          	addi	a1,a1,-1844 # 800091f8 <digits+0x1b8>
    80001934:	00011517          	auipc	a0,0x11
    80001938:	96c50513          	addi	a0,a0,-1684 # 800122a0 <pid_lock>
    8000193c:	fffff097          	auipc	ra,0xfffff
    80001940:	1fa080e7          	jalr	506(ra) # 80000b36 <initlock>
  initlock(&tid_lock,"nexttid");
    80001944:	00008597          	auipc	a1,0x8
    80001948:	8bc58593          	addi	a1,a1,-1860 # 80009200 <digits+0x1c0>
    8000194c:	00011517          	auipc	a0,0x11
    80001950:	96c50513          	addi	a0,a0,-1684 # 800122b8 <tid_lock>
    80001954:	fffff097          	auipc	ra,0xfffff
    80001958:	1e2080e7          	jalr	482(ra) # 80000b36 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000195c:	00008597          	auipc	a1,0x8
    80001960:	8ac58593          	addi	a1,a1,-1876 # 80009208 <digits+0x1c8>
    80001964:	00011517          	auipc	a0,0x11
    80001968:	96c50513          	addi	a0,a0,-1684 # 800122d0 <wait_lock>
    8000196c:	fffff097          	auipc	ra,0xfffff
    80001970:	1ca080e7          	jalr	458(ra) # 80000b36 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {      
    80001974:	00011997          	auipc	s3,0x11
    80001978:	5fc98993          	addi	s3,s3,1532 # 80012f70 <proc+0x848>
    8000197c:	00011c17          	auipc	s8,0x11
    80001980:	dacc0c13          	addi	s8,s8,-596 # 80012728 <proc>
      initlock(&p->lock, "proc");
      // p->kstack = KSTACK((int) (p - proc));
      int proc_index= (int)(p-proc);
    80001984:	8de2                	mv	s11,s8
    80001986:	00007d17          	auipc	s10,0x7
    8000198a:	67ad0d13          	addi	s10,s10,1658 # 80009000 <etext>
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
        initlock(&t->lock, "thread");
    8000198e:	00008b97          	auipc	s7,0x8
    80001992:	892b8b93          	addi	s7,s7,-1902 # 80009220 <digits+0x1e0>
        int thread_index = (int)(t-p->kthreads);
    80001996:	00007b17          	auipc	s6,0x7
    8000199a:	672b0b13          	addi	s6,s6,1650 # 80009008 <etext+0x8>
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    8000199e:	04000ab7          	lui	s5,0x4000
    800019a2:	1afd                	addi	s5,s5,-1
    800019a4:	0ab2                	slli	s5,s5,0xc
  for(p = proc; p < &proc[NPROC]; p++) {      
    800019a6:	6c85                	lui	s9,0x1
    800019a8:	848c8c93          	addi	s9,s9,-1976 # 848 <_entry-0x7ffff7b8>
    800019ac:	a809                	j	800019be <procinit+0xb0>
    800019ae:	9c66                	add	s8,s8,s9
    800019b0:	99e6                	add	s3,s3,s9
    800019b2:	00032797          	auipc	a5,0x32
    800019b6:	f7678793          	addi	a5,a5,-138 # 80033928 <tickslock>
    800019ba:	06fc0263          	beq	s8,a5,80001a1e <procinit+0x110>
      initlock(&p->lock, "proc");
    800019be:	00008597          	auipc	a1,0x8
    800019c2:	85a58593          	addi	a1,a1,-1958 # 80009218 <digits+0x1d8>
    800019c6:	8562                	mv	a0,s8
    800019c8:	fffff097          	auipc	ra,0xfffff
    800019cc:	16e080e7          	jalr	366(ra) # 80000b36 <initlock>
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    800019d0:	288c0a13          	addi	s4,s8,648
      int proc_index= (int)(p-proc);
    800019d4:	41bc0933          	sub	s2,s8,s11
    800019d8:	40395913          	srai	s2,s2,0x3
    800019dc:	000d3783          	ld	a5,0(s10)
    800019e0:	02f90933          	mul	s2,s2,a5
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    800019e4:	0039191b          	slliw	s2,s2,0x3
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    800019e8:	84d2                	mv	s1,s4
        initlock(&t->lock, "thread");
    800019ea:	85de                	mv	a1,s7
    800019ec:	8526                	mv	a0,s1
    800019ee:	fffff097          	auipc	ra,0xfffff
    800019f2:	148080e7          	jalr	328(ra) # 80000b36 <initlock>
        int thread_index = (int)(t-p->kthreads);
    800019f6:	414487b3          	sub	a5,s1,s4
    800019fa:	878d                	srai	a5,a5,0x3
    800019fc:	000b3703          	ld	a4,0(s6)
    80001a00:	02e787b3          	mul	a5,a5,a4
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    80001a04:	012787bb          	addw	a5,a5,s2
    80001a08:	2785                	addiw	a5,a5,1
    80001a0a:	00d7979b          	slliw	a5,a5,0xd
    80001a0e:	40fa87b3          	sub	a5,s5,a5
    80001a12:	fc9c                	sd	a5,56(s1)
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001a14:	0b848493          	addi	s1,s1,184
    80001a18:	fd3499e3          	bne	s1,s3,800019ea <procinit+0xdc>
    80001a1c:	bf49                	j	800019ae <procinit+0xa0>
      }
  }
}
    80001a1e:	70a6                	ld	ra,104(sp)
    80001a20:	7406                	ld	s0,96(sp)
    80001a22:	64e6                	ld	s1,88(sp)
    80001a24:	6946                	ld	s2,80(sp)
    80001a26:	69a6                	ld	s3,72(sp)
    80001a28:	6a06                	ld	s4,64(sp)
    80001a2a:	7ae2                	ld	s5,56(sp)
    80001a2c:	7b42                	ld	s6,48(sp)
    80001a2e:	7ba2                	ld	s7,40(sp)
    80001a30:	7c02                	ld	s8,32(sp)
    80001a32:	6ce2                	ld	s9,24(sp)
    80001a34:	6d42                	ld	s10,16(sp)
    80001a36:	6da2                	ld	s11,8(sp)
    80001a38:	6165                	addi	sp,sp,112
    80001a3a:	8082                	ret

0000000080001a3c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a3c:	1141                	addi	sp,sp,-16
    80001a3e:	e422                	sd	s0,8(sp)
    80001a40:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a42:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a44:	2501                	sext.w	a0,a0
    80001a46:	6422                	ld	s0,8(sp)
    80001a48:	0141                	addi	sp,sp,16
    80001a4a:	8082                	ret

0000000080001a4c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001a4c:	1141                	addi	sp,sp,-16
    80001a4e:	e422                	sd	s0,8(sp)
    80001a50:	0800                	addi	s0,sp,16
    80001a52:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a54:	0007851b          	sext.w	a0,a5
    80001a58:	00451793          	slli	a5,a0,0x4
    80001a5c:	97aa                	add	a5,a5,a0
    80001a5e:	078e                	slli	a5,a5,0x3
  return c;
}
    80001a60:	00011517          	auipc	a0,0x11
    80001a64:	88850513          	addi	a0,a0,-1912 # 800122e8 <cpus>
    80001a68:	953e                	add	a0,a0,a5
    80001a6a:	6422                	ld	s0,8(sp)
    80001a6c:	0141                	addi	sp,sp,16
    80001a6e:	8082                	ret

0000000080001a70 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001a70:	1101                	addi	sp,sp,-32
    80001a72:	ec06                	sd	ra,24(sp)
    80001a74:	e822                	sd	s0,16(sp)
    80001a76:	e426                	sd	s1,8(sp)
    80001a78:	1000                	addi	s0,sp,32
  push_off();
    80001a7a:	fffff097          	auipc	ra,0xfffff
    80001a7e:	100080e7          	jalr	256(ra) # 80000b7a <push_off>
    80001a82:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a84:	0007871b          	sext.w	a4,a5
    80001a88:	00471793          	slli	a5,a4,0x4
    80001a8c:	97ba                	add	a5,a5,a4
    80001a8e:	078e                	slli	a5,a5,0x3
    80001a90:	00011717          	auipc	a4,0x11
    80001a94:	81070713          	addi	a4,a4,-2032 # 800122a0 <pid_lock>
    80001a98:	97ba                	add	a5,a5,a4
    80001a9a:	67a4                	ld	s1,72(a5)
  pop_off();
    80001a9c:	fffff097          	auipc	ra,0xfffff
    80001aa0:	194080e7          	jalr	404(ra) # 80000c30 <pop_off>
  return p;
}//
    80001aa4:	8526                	mv	a0,s1
    80001aa6:	60e2                	ld	ra,24(sp)
    80001aa8:	6442                	ld	s0,16(sp)
    80001aaa:	64a2                	ld	s1,8(sp)
    80001aac:	6105                	addi	sp,sp,32
    80001aae:	8082                	ret

0000000080001ab0 <mykthread>:

struct kthread*
mykthread(void){
    80001ab0:	1101                	addi	sp,sp,-32
    80001ab2:	ec06                	sd	ra,24(sp)
    80001ab4:	e822                	sd	s0,16(sp)
    80001ab6:	e426                	sd	s1,8(sp)
    80001ab8:	1000                	addi	s0,sp,32
  push_off();
    80001aba:	fffff097          	auipc	ra,0xfffff
    80001abe:	0c0080e7          	jalr	192(ra) # 80000b7a <push_off>
    80001ac2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct kthread *t=c->kthread;
    80001ac4:	0007871b          	sext.w	a4,a5
    80001ac8:	00471793          	slli	a5,a4,0x4
    80001acc:	97ba                	add	a5,a5,a4
    80001ace:	078e                	slli	a5,a5,0x3
    80001ad0:	00010717          	auipc	a4,0x10
    80001ad4:	7d070713          	addi	a4,a4,2000 # 800122a0 <pid_lock>
    80001ad8:	97ba                	add	a5,a5,a4
    80001ada:	67e4                	ld	s1,200(a5)
  pop_off();
    80001adc:	fffff097          	auipc	ra,0xfffff
    80001ae0:	154080e7          	jalr	340(ra) # 80000c30 <pop_off>
  return t;  
}
    80001ae4:	8526                	mv	a0,s1
    80001ae6:	60e2                	ld	ra,24(sp)
    80001ae8:	6442                	ld	s0,16(sp)
    80001aea:	64a2                	ld	s1,8(sp)
    80001aec:	6105                	addi	sp,sp,32
    80001aee:	8082                	ret

0000000080001af0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001af0:	1141                	addi	sp,sp,-16
    80001af2:	e406                	sd	ra,8(sp)
    80001af4:	e022                	sd	s0,0(sp)
    80001af6:	0800                	addi	s0,sp,16
  printf("shity child at forkret tid= %d\n",mykthread()->tid);
    80001af8:	00000097          	auipc	ra,0x0
    80001afc:	fb8080e7          	jalr	-72(ra) # 80001ab0 <mykthread>
    80001b00:	590c                	lw	a1,48(a0)
    80001b02:	00007517          	auipc	a0,0x7
    80001b06:	72650513          	addi	a0,a0,1830 # 80009228 <digits+0x1e8>
    80001b0a:	fffff097          	auipc	ra,0xfffff
    80001b0e:	a6e080e7          	jalr	-1426(ra) # 80000578 <printf>
  static int first = 1;

  // Still holding p->lock from scheduler.
  // release(&myproc()->lock);

  release(&mykthread()->lock);    // TODO: check if this change is good
    80001b12:	00000097          	auipc	ra,0x0
    80001b16:	f9e080e7          	jalr	-98(ra) # 80001ab0 <mykthread>
    80001b1a:	fffff097          	auipc	ra,0xfffff
    80001b1e:	176080e7          	jalr	374(ra) # 80000c90 <release>
  printf("after release in forkret tid= %d\n",mykthread()->tid);
    80001b22:	00000097          	auipc	ra,0x0
    80001b26:	f8e080e7          	jalr	-114(ra) # 80001ab0 <mykthread>
    80001b2a:	590c                	lw	a1,48(a0)
    80001b2c:	00007517          	auipc	a0,0x7
    80001b30:	71c50513          	addi	a0,a0,1820 # 80009248 <digits+0x208>
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	a44080e7          	jalr	-1468(ra) # 80000578 <printf>

  if (first) {
    80001b3c:	00008797          	auipc	a5,0x8
    80001b40:	0247a783          	lw	a5,36(a5) # 80009b60 <first.1>
    80001b44:	eb89                	bnez	a5,80001b56 <forkret+0x66>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001b46:	00002097          	auipc	ra,0x2
    80001b4a:	a04080e7          	jalr	-1532(ra) # 8000354a <usertrapret>
}
    80001b4e:	60a2                	ld	ra,8(sp)
    80001b50:	6402                	ld	s0,0(sp)
    80001b52:	0141                	addi	sp,sp,16
    80001b54:	8082                	ret
    first = 0;
    80001b56:	00008797          	auipc	a5,0x8
    80001b5a:	0007a523          	sw	zero,10(a5) # 80009b60 <first.1>
    fsinit(ROOTDEV);
    80001b5e:	4505                	li	a0,1
    80001b60:	00003097          	auipc	ra,0x3
    80001b64:	a4a080e7          	jalr	-1462(ra) # 800045aa <fsinit>
    80001b68:	bff9                	j	80001b46 <forkret+0x56>

0000000080001b6a <allocpid>:
allocpid() {
    80001b6a:	1101                	addi	sp,sp,-32
    80001b6c:	ec06                	sd	ra,24(sp)
    80001b6e:	e822                	sd	s0,16(sp)
    80001b70:	e426                	sd	s1,8(sp)
    80001b72:	e04a                	sd	s2,0(sp)
    80001b74:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b76:	00010917          	auipc	s2,0x10
    80001b7a:	72a90913          	addi	s2,s2,1834 # 800122a0 <pid_lock>
    80001b7e:	854a                	mv	a0,s2
    80001b80:	fffff097          	auipc	ra,0xfffff
    80001b84:	046080e7          	jalr	70(ra) # 80000bc6 <acquire>
  pid = nextpid;
    80001b88:	00008797          	auipc	a5,0x8
    80001b8c:	fe078793          	addi	a5,a5,-32 # 80009b68 <nextpid>
    80001b90:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b92:	0014871b          	addiw	a4,s1,1
    80001b96:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b98:	854a                	mv	a0,s2
    80001b9a:	fffff097          	auipc	ra,0xfffff
    80001b9e:	0f6080e7          	jalr	246(ra) # 80000c90 <release>
}
    80001ba2:	8526                	mv	a0,s1
    80001ba4:	60e2                	ld	ra,24(sp)
    80001ba6:	6442                	ld	s0,16(sp)
    80001ba8:	64a2                	ld	s1,8(sp)
    80001baa:	6902                	ld	s2,0(sp)
    80001bac:	6105                	addi	sp,sp,32
    80001bae:	8082                	ret

0000000080001bb0 <alloctid>:
alloctid() {
    80001bb0:	1101                	addi	sp,sp,-32
    80001bb2:	ec06                	sd	ra,24(sp)
    80001bb4:	e822                	sd	s0,16(sp)
    80001bb6:	e426                	sd	s1,8(sp)
    80001bb8:	e04a                	sd	s2,0(sp)
    80001bba:	1000                	addi	s0,sp,32
  acquire(&tid_lock);
    80001bbc:	00010917          	auipc	s2,0x10
    80001bc0:	6fc90913          	addi	s2,s2,1788 # 800122b8 <tid_lock>
    80001bc4:	854a                	mv	a0,s2
    80001bc6:	fffff097          	auipc	ra,0xfffff
    80001bca:	000080e7          	jalr	ra # 80000bc6 <acquire>
  tid = nexttid;
    80001bce:	00008797          	auipc	a5,0x8
    80001bd2:	f9678793          	addi	a5,a5,-106 # 80009b64 <nexttid>
    80001bd6:	4384                	lw	s1,0(a5)
  nexttid = nexttid + 1;
    80001bd8:	0014871b          	addiw	a4,s1,1
    80001bdc:	c398                	sw	a4,0(a5)
  release(&tid_lock);
    80001bde:	854a                	mv	a0,s2
    80001be0:	fffff097          	auipc	ra,0xfffff
    80001be4:	0b0080e7          	jalr	176(ra) # 80000c90 <release>
}
    80001be8:	8526                	mv	a0,s1
    80001bea:	60e2                	ld	ra,24(sp)
    80001bec:	6442                	ld	s0,16(sp)
    80001bee:	64a2                	ld	s1,8(sp)
    80001bf0:	6902                	ld	s2,0(sp)
    80001bf2:	6105                	addi	sp,sp,32
    80001bf4:	8082                	ret

0000000080001bf6 <init_thread>:
init_thread(struct kthread *t){
    80001bf6:	1101                	addi	sp,sp,-32
    80001bf8:	ec06                	sd	ra,24(sp)
    80001bfa:	e822                	sd	s0,16(sp)
    80001bfc:	e426                	sd	s1,8(sp)
    80001bfe:	1000                	addi	s0,sp,32
    80001c00:	84aa                	mv	s1,a0
  t->state = TUSED;
    80001c02:	4785                	li	a5,1
    80001c04:	cd1c                	sw	a5,24(a0)
  t->tid = alloctid();  
    80001c06:	00000097          	auipc	ra,0x0
    80001c0a:	faa080e7          	jalr	-86(ra) # 80001bb0 <alloctid>
    80001c0e:	d888                	sw	a0,48(s1)
  memset(&(t->context), 0, sizeof(t->context));
    80001c10:	07000613          	li	a2,112
    80001c14:	4581                	li	a1,0
    80001c16:	04848513          	addi	a0,s1,72
    80001c1a:	fffff097          	auipc	ra,0xfffff
    80001c1e:	0be080e7          	jalr	190(ra) # 80000cd8 <memset>
  t->context.ra = (uint64)forkret;
    80001c22:	00000797          	auipc	a5,0x0
    80001c26:	ece78793          	addi	a5,a5,-306 # 80001af0 <forkret>
    80001c2a:	e4bc                	sd	a5,72(s1)
  t->context.sp = t->kstack + PGSIZE;
    80001c2c:	7c9c                	ld	a5,56(s1)
    80001c2e:	6705                	lui	a4,0x1
    80001c30:	97ba                	add	a5,a5,a4
    80001c32:	e8bc                	sd	a5,80(s1)
}
    80001c34:	4501                	li	a0,0
    80001c36:	60e2                	ld	ra,24(sp)
    80001c38:	6442                	ld	s0,16(sp)
    80001c3a:	64a2                	ld	s1,8(sp)
    80001c3c:	6105                	addi	sp,sp,32
    80001c3e:	8082                	ret

0000000080001c40 <proc_pagetable>:
{
    80001c40:	1101                	addi	sp,sp,-32
    80001c42:	ec06                	sd	ra,24(sp)
    80001c44:	e822                	sd	s0,16(sp)
    80001c46:	e426                	sd	s1,8(sp)
    80001c48:	e04a                	sd	s2,0(sp)
    80001c4a:	1000                	addi	s0,sp,32
    80001c4c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c4e:	fffff097          	auipc	ra,0xfffff
    80001c52:	6d2080e7          	jalr	1746(ra) # 80001320 <uvmcreate>
    80001c56:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c58:	c121                	beqz	a0,80001c98 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c5a:	4729                	li	a4,10
    80001c5c:	00006697          	auipc	a3,0x6
    80001c60:	3a468693          	addi	a3,a3,932 # 80008000 <_trampoline>
    80001c64:	6605                	lui	a2,0x1
    80001c66:	040005b7          	lui	a1,0x4000
    80001c6a:	15fd                	addi	a1,a1,-1
    80001c6c:	05b2                	slli	a1,a1,0xc
    80001c6e:	fffff097          	auipc	ra,0xfffff
    80001c72:	43a080e7          	jalr	1082(ra) # 800010a8 <mappages>
    80001c76:	02054863          	bltz	a0,80001ca6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c7a:	4719                	li	a4,6
    80001c7c:	04893683          	ld	a3,72(s2)
    80001c80:	6605                	lui	a2,0x1
    80001c82:	020005b7          	lui	a1,0x2000
    80001c86:	15fd                	addi	a1,a1,-1
    80001c88:	05b6                	slli	a1,a1,0xd
    80001c8a:	8526                	mv	a0,s1
    80001c8c:	fffff097          	auipc	ra,0xfffff
    80001c90:	41c080e7          	jalr	1052(ra) # 800010a8 <mappages>
    80001c94:	02054163          	bltz	a0,80001cb6 <proc_pagetable+0x76>
}
    80001c98:	8526                	mv	a0,s1
    80001c9a:	60e2                	ld	ra,24(sp)
    80001c9c:	6442                	ld	s0,16(sp)
    80001c9e:	64a2                	ld	s1,8(sp)
    80001ca0:	6902                	ld	s2,0(sp)
    80001ca2:	6105                	addi	sp,sp,32
    80001ca4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ca6:	4581                	li	a1,0
    80001ca8:	8526                	mv	a0,s1
    80001caa:	00000097          	auipc	ra,0x0
    80001cae:	872080e7          	jalr	-1934(ra) # 8000151c <uvmfree>
    return 0;
    80001cb2:	4481                	li	s1,0
    80001cb4:	b7d5                	j	80001c98 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cb6:	4681                	li	a3,0
    80001cb8:	4605                	li	a2,1
    80001cba:	040005b7          	lui	a1,0x4000
    80001cbe:	15fd                	addi	a1,a1,-1
    80001cc0:	05b2                	slli	a1,a1,0xc
    80001cc2:	8526                	mv	a0,s1
    80001cc4:	fffff097          	auipc	ra,0xfffff
    80001cc8:	598080e7          	jalr	1432(ra) # 8000125c <uvmunmap>
    uvmfree(pagetable, 0);
    80001ccc:	4581                	li	a1,0
    80001cce:	8526                	mv	a0,s1
    80001cd0:	00000097          	auipc	ra,0x0
    80001cd4:	84c080e7          	jalr	-1972(ra) # 8000151c <uvmfree>
    return 0;
    80001cd8:	4481                	li	s1,0
    80001cda:	bf7d                	j	80001c98 <proc_pagetable+0x58>

0000000080001cdc <proc_freepagetable>:
{
    80001cdc:	1101                	addi	sp,sp,-32
    80001cde:	ec06                	sd	ra,24(sp)
    80001ce0:	e822                	sd	s0,16(sp)
    80001ce2:	e426                	sd	s1,8(sp)
    80001ce4:	e04a                	sd	s2,0(sp)
    80001ce6:	1000                	addi	s0,sp,32
    80001ce8:	84aa                	mv	s1,a0
    80001cea:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cec:	4681                	li	a3,0
    80001cee:	4605                	li	a2,1
    80001cf0:	040005b7          	lui	a1,0x4000
    80001cf4:	15fd                	addi	a1,a1,-1
    80001cf6:	05b2                	slli	a1,a1,0xc
    80001cf8:	fffff097          	auipc	ra,0xfffff
    80001cfc:	564080e7          	jalr	1380(ra) # 8000125c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d00:	4681                	li	a3,0
    80001d02:	4605                	li	a2,1
    80001d04:	020005b7          	lui	a1,0x2000
    80001d08:	15fd                	addi	a1,a1,-1
    80001d0a:	05b6                	slli	a1,a1,0xd
    80001d0c:	8526                	mv	a0,s1
    80001d0e:	fffff097          	auipc	ra,0xfffff
    80001d12:	54e080e7          	jalr	1358(ra) # 8000125c <uvmunmap>
  uvmfree(pagetable, sz);
    80001d16:	85ca                	mv	a1,s2
    80001d18:	8526                	mv	a0,s1
    80001d1a:	00000097          	auipc	ra,0x0
    80001d1e:	802080e7          	jalr	-2046(ra) # 8000151c <uvmfree>
}
    80001d22:	60e2                	ld	ra,24(sp)
    80001d24:	6442                	ld	s0,16(sp)
    80001d26:	64a2                	ld	s1,8(sp)
    80001d28:	6902                	ld	s2,0(sp)
    80001d2a:	6105                	addi	sp,sp,32
    80001d2c:	8082                	ret

0000000080001d2e <freeproc>:
{
    80001d2e:	7179                	addi	sp,sp,-48
    80001d30:	f406                	sd	ra,40(sp)
    80001d32:	f022                	sd	s0,32(sp)
    80001d34:	ec26                	sd	s1,24(sp)
    80001d36:	e84a                	sd	s2,16(sp)
    80001d38:	e44e                	sd	s3,8(sp)
    80001d3a:	1800                	addi	s0,sp,48
    80001d3c:	892a                	mv	s2,a0
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001d3e:	28850493          	addi	s1,a0,648
    80001d42:	6985                	lui	s3,0x1
    80001d44:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80001d48:	99aa                	add	s3,s3,a0
    80001d4a:	a811                	j	80001d5e <freeproc+0x30>
    release(&t->lock);
    80001d4c:	8526                	mv	a0,s1
    80001d4e:	fffff097          	auipc	ra,0xfffff
    80001d52:	f42080e7          	jalr	-190(ra) # 80000c90 <release>
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001d56:	0b848493          	addi	s1,s1,184
    80001d5a:	02998463          	beq	s3,s1,80001d82 <freeproc+0x54>
    acquire(&t->lock);
    80001d5e:	8526                	mv	a0,s1
    80001d60:	fffff097          	auipc	ra,0xfffff
    80001d64:	e66080e7          	jalr	-410(ra) # 80000bc6 <acquire>
    if(t->state != TUNUSED)
    80001d68:	4c9c                	lw	a5,24(s1)
    80001d6a:	d3ed                	beqz	a5,80001d4c <freeproc+0x1e>
  t->tid = 0;
    80001d6c:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80001d70:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80001d74:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80001d78:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80001d7c:	0004ac23          	sw	zero,24(s1)
}
    80001d80:	b7f1                	j	80001d4c <freeproc+0x1e>
  p->user_trapframe_backup = 0;
    80001d82:	26093c23          	sd	zero,632(s2)
  if(p->pagetable)
    80001d86:	04093503          	ld	a0,64(s2)
    80001d8a:	c519                	beqz	a0,80001d98 <freeproc+0x6a>
    proc_freepagetable(p->pagetable, p->sz);
    80001d8c:	03893583          	ld	a1,56(s2)
    80001d90:	00000097          	auipc	ra,0x0
    80001d94:	f4c080e7          	jalr	-180(ra) # 80001cdc <proc_freepagetable>
  p->pagetable = 0;
    80001d98:	04093023          	sd	zero,64(s2)
  p->sz = 0;
    80001d9c:	02093c23          	sd	zero,56(s2)
  p->pid = 0;
    80001da0:	02092223          	sw	zero,36(s2)
  p->parent = 0;
    80001da4:	02093823          	sd	zero,48(s2)
  p->name[0] = 0;
    80001da8:	0c090c23          	sb	zero,216(s2)
  p->killed = 0;
    80001dac:	00092e23          	sw	zero,28(s2)
  p->xstate = 0;
    80001db0:	02092023          	sw	zero,32(s2)
  p->active_threads = 0;
    80001db4:	02092423          	sw	zero,40(s2)
  p->state = UNUSED;
    80001db8:	00092c23          	sw	zero,24(s2)
}
    80001dbc:	70a2                	ld	ra,40(sp)
    80001dbe:	7402                	ld	s0,32(sp)
    80001dc0:	64e2                	ld	s1,24(sp)
    80001dc2:	6942                	ld	s2,16(sp)
    80001dc4:	69a2                	ld	s3,8(sp)
    80001dc6:	6145                	addi	sp,sp,48
    80001dc8:	8082                	ret

0000000080001dca <allocproc>:
{
    80001dca:	7179                	addi	sp,sp,-48
    80001dcc:	f406                	sd	ra,40(sp)
    80001dce:	f022                	sd	s0,32(sp)
    80001dd0:	ec26                	sd	s1,24(sp)
    80001dd2:	e84a                	sd	s2,16(sp)
    80001dd4:	e44e                	sd	s3,8(sp)
    80001dd6:	e052                	sd	s4,0(sp)
    80001dd8:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dda:	00011497          	auipc	s1,0x11
    80001dde:	94e48493          	addi	s1,s1,-1714 # 80012728 <proc>
    80001de2:	6985                	lui	s3,0x1
    80001de4:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80001de8:	00032a17          	auipc	s4,0x32
    80001dec:	b40a0a13          	addi	s4,s4,-1216 # 80033928 <tickslock>
    acquire(&p->lock);
    80001df0:	8926                	mv	s2,s1
    80001df2:	8526                	mv	a0,s1
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	dd2080e7          	jalr	-558(ra) # 80000bc6 <acquire>
    if(p->state == UNUSED) {
    80001dfc:	4c9c                	lw	a5,24(s1)
    80001dfe:	cb99                	beqz	a5,80001e14 <allocproc+0x4a>
      release(&p->lock);
    80001e00:	8526                	mv	a0,s1
    80001e02:	fffff097          	auipc	ra,0xfffff
    80001e06:	e8e080e7          	jalr	-370(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e0a:	94ce                	add	s1,s1,s3
    80001e0c:	ff4492e3          	bne	s1,s4,80001df0 <allocproc+0x26>
  return 0;
    80001e10:	4481                	li	s1,0
    80001e12:	a86d                	j	80001ecc <allocproc+0x102>
  p->pid = allocpid();
    80001e14:	00000097          	auipc	ra,0x0
    80001e18:	d56080e7          	jalr	-682(ra) # 80001b6a <allocpid>
    80001e1c:	d0c8                	sw	a0,36(s1)
  p->state = USED;
    80001e1e:	4785                	li	a5,1
    80001e20:	cc9c                	sw	a5,24(s1)
  if((p->threads_tf_start =kalloc()) == 0){
    80001e22:	fffff097          	auipc	ra,0xfffff
    80001e26:	cb4080e7          	jalr	-844(ra) # 80000ad6 <kalloc>
    80001e2a:	89aa                	mv	s3,a0
    80001e2c:	e4a8                	sd	a0,72(s1)
    80001e2e:	0f848713          	addi	a4,s1,248
    80001e32:	1f848793          	addi	a5,s1,504
    80001e36:	27848693          	addi	a3,s1,632
    80001e3a:	c155                	beqz	a0,80001ede <allocproc+0x114>
    p->signal_handlers[i] = SIG_DFL;
    80001e3c:	00073023          	sd	zero,0(a4) # 1000 <_entry-0x7ffff000>
    p->handlers_sigmasks[i] = 0;
    80001e40:	0007a023          	sw	zero,0(a5)
  for(int i=0;i<32;i++){
    80001e44:	0721                	addi	a4,a4,8
    80001e46:	0791                	addi	a5,a5,4
    80001e48:	fed79ae3          	bne	a5,a3,80001e3c <allocproc+0x72>
  p->signal_mask= 0;
    80001e4c:	0e04a623          	sw	zero,236(s1)
  p->pending_signals = 0;
    80001e50:	0e04a423          	sw	zero,232(s1)
  p->active_threads=1;
    80001e54:	4785                	li	a5,1
    80001e56:	d49c                	sw	a5,40(s1)
  p->signal_mask_backup = 0;
    80001e58:	0e04a823          	sw	zero,240(s1)
  p->handling_user_sig_flag = 0;
    80001e5c:	2804a023          	sw	zero,640(s1)
  p->handling_sig_flag=0;
    80001e60:	2804a223          	sw	zero,644(s1)
  p->pagetable = proc_pagetable(p);
    80001e64:	8526                	mv	a0,s1
    80001e66:	00000097          	auipc	ra,0x0
    80001e6a:	dda080e7          	jalr	-550(ra) # 80001c40 <proc_pagetable>
    80001e6e:	89aa                	mv	s3,a0
    80001e70:	e0a8                	sd	a0,64(s1)
  if(p->pagetable == 0){
    80001e72:	c151                	beqz	a0,80001ef6 <allocproc+0x12c>
    80001e74:	2a048793          	addi	a5,s1,672
    80001e78:	64b8                	ld	a4,72(s1)
    80001e7a:	6685                	lui	a3,0x1
    80001e7c:	86068693          	addi	a3,a3,-1952 # 860 <_entry-0x7ffff7a0>
    80001e80:	9936                	add	s2,s2,a3
    t->tid=-1;
    80001e82:	56fd                	li	a3,-1
    t->state=TUNUSED;
    80001e84:	0007a023          	sw	zero,0(a5)
    t->chan=0;
    80001e88:	0007b423          	sd	zero,8(a5)
    t->tid=-1;
    80001e8c:	cf94                	sw	a3,24(a5)
    t->trapframe = (struct trapframe *)p->threads_tf_start + i;     //TODO: check if good or maybe + i*sizeof(struct trapframe)
    80001e8e:	f798                	sd	a4,40(a5)
    t->killed = 0;
    80001e90:	0007a823          	sw	zero,16(a5)
    t->frozen = 0;
    80001e94:	0007ae23          	sw	zero,28(a5)
  for(int i=0;i<NTHREAD;i++){
    80001e98:	0b878793          	addi	a5,a5,184
    80001e9c:	12070713          	addi	a4,a4,288
    80001ea0:	ff2792e3          	bne	a5,s2,80001e84 <allocproc+0xba>
  struct kthread *t= &p->kthreads[0];
    80001ea4:	28848913          	addi	s2,s1,648
  acquire(&t->lock);
    80001ea8:	854a                	mv	a0,s2
    80001eaa:	fffff097          	auipc	ra,0xfffff
    80001eae:	d1c080e7          	jalr	-740(ra) # 80000bc6 <acquire>
  if(init_thread(t) == -1){
    80001eb2:	854a                	mv	a0,s2
    80001eb4:	00000097          	auipc	ra,0x0
    80001eb8:	d42080e7          	jalr	-702(ra) # 80001bf6 <init_thread>
    80001ebc:	57fd                	li	a5,-1
    80001ebe:	04f50863          	beq	a0,a5,80001f0e <allocproc+0x144>
  release(&t->lock);
    80001ec2:	854a                	mv	a0,s2
    80001ec4:	fffff097          	auipc	ra,0xfffff
    80001ec8:	dcc080e7          	jalr	-564(ra) # 80000c90 <release>
}
    80001ecc:	8526                	mv	a0,s1
    80001ece:	70a2                	ld	ra,40(sp)
    80001ed0:	7402                	ld	s0,32(sp)
    80001ed2:	64e2                	ld	s1,24(sp)
    80001ed4:	6942                	ld	s2,16(sp)
    80001ed6:	69a2                	ld	s3,8(sp)
    80001ed8:	6a02                	ld	s4,0(sp)
    80001eda:	6145                	addi	sp,sp,48
    80001edc:	8082                	ret
    freeproc(p);
    80001ede:	8526                	mv	a0,s1
    80001ee0:	00000097          	auipc	ra,0x0
    80001ee4:	e4e080e7          	jalr	-434(ra) # 80001d2e <freeproc>
    release(&p->lock);
    80001ee8:	8526                	mv	a0,s1
    80001eea:	fffff097          	auipc	ra,0xfffff
    80001eee:	da6080e7          	jalr	-602(ra) # 80000c90 <release>
    return 0;
    80001ef2:	84ce                	mv	s1,s3
    80001ef4:	bfe1                	j	80001ecc <allocproc+0x102>
    freeproc(p);
    80001ef6:	8526                	mv	a0,s1
    80001ef8:	00000097          	auipc	ra,0x0
    80001efc:	e36080e7          	jalr	-458(ra) # 80001d2e <freeproc>
    release(&p->lock);
    80001f00:	8526                	mv	a0,s1
    80001f02:	fffff097          	auipc	ra,0xfffff
    80001f06:	d8e080e7          	jalr	-626(ra) # 80000c90 <release>
    return 0;
    80001f0a:	84ce                	mv	s1,s3
    80001f0c:	b7c1                	j	80001ecc <allocproc+0x102>
    freeproc(p);
    80001f0e:	8526                	mv	a0,s1
    80001f10:	00000097          	auipc	ra,0x0
    80001f14:	e1e080e7          	jalr	-482(ra) # 80001d2e <freeproc>
    release(&p->lock);  
    80001f18:	8526                	mv	a0,s1
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	d76080e7          	jalr	-650(ra) # 80000c90 <release>
    return 0;
    80001f22:	4481                	li	s1,0
    80001f24:	b765                	j	80001ecc <allocproc+0x102>

0000000080001f26 <userinit>:
{
    80001f26:	1101                	addi	sp,sp,-32
    80001f28:	ec06                	sd	ra,24(sp)
    80001f2a:	e822                	sd	s0,16(sp)
    80001f2c:	e426                	sd	s1,8(sp)
    80001f2e:	1000                	addi	s0,sp,32
    80001f30:	8792                	mv	a5,tp
  p = allocproc();
    80001f32:	00000097          	auipc	ra,0x0
    80001f36:	e98080e7          	jalr	-360(ra) # 80001dca <allocproc>
    80001f3a:	84aa                	mv	s1,a0
  initproc = p;
    80001f3c:	00008797          	auipc	a5,0x8
    80001f40:	0ea7b623          	sd	a0,236(a5) # 8000a028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001f44:	03400613          	li	a2,52
    80001f48:	00008597          	auipc	a1,0x8
    80001f4c:	c2858593          	addi	a1,a1,-984 # 80009b70 <initcode>
    80001f50:	6128                	ld	a0,64(a0)
    80001f52:	fffff097          	auipc	ra,0xfffff
    80001f56:	3fc080e7          	jalr	1020(ra) # 8000134e <uvminit>
  p->sz = PGSIZE;
    80001f5a:	6785                	lui	a5,0x1
    80001f5c:	fc9c                	sd	a5,56(s1)
  t->trapframe->epc = 0;      // user program counter
    80001f5e:	2c84b703          	ld	a4,712(s1)
    80001f62:	00073c23          	sd	zero,24(a4)
  t->trapframe->sp = PGSIZE;  // user stack pointer
    80001f66:	2c84b703          	ld	a4,712(s1)
    80001f6a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f6c:	4641                	li	a2,16
    80001f6e:	00007597          	auipc	a1,0x7
    80001f72:	30258593          	addi	a1,a1,770 # 80009270 <digits+0x230>
    80001f76:	0d848513          	addi	a0,s1,216
    80001f7a:	fffff097          	auipc	ra,0xfffff
    80001f7e:	eb0080e7          	jalr	-336(ra) # 80000e2a <safestrcpy>
  p->cwd = namei("/");
    80001f82:	00007517          	auipc	a0,0x7
    80001f86:	2fe50513          	addi	a0,a0,766 # 80009280 <digits+0x240>
    80001f8a:	00003097          	auipc	ra,0x3
    80001f8e:	04c080e7          	jalr	76(ra) # 80004fd6 <namei>
    80001f92:	e8e8                	sd	a0,208(s1)
  p->state = RUNNABLE;
    80001f94:	4789                	li	a5,2
    80001f96:	cc9c                	sw	a5,24(s1)
  t->state = TRUNNABLE;
    80001f98:	478d                	li	a5,3
    80001f9a:	2af4a023          	sw	a5,672(s1)
  release(&p->lock);
    80001f9e:	8526                	mv	a0,s1
    80001fa0:	fffff097          	auipc	ra,0xfffff
    80001fa4:	cf0080e7          	jalr	-784(ra) # 80000c90 <release>
}
    80001fa8:	60e2                	ld	ra,24(sp)
    80001faa:	6442                	ld	s0,16(sp)
    80001fac:	64a2                	ld	s1,8(sp)
    80001fae:	6105                	addi	sp,sp,32
    80001fb0:	8082                	ret

0000000080001fb2 <growproc>:
{
    80001fb2:	1101                	addi	sp,sp,-32
    80001fb4:	ec06                	sd	ra,24(sp)
    80001fb6:	e822                	sd	s0,16(sp)
    80001fb8:	e426                	sd	s1,8(sp)
    80001fba:	e04a                	sd	s2,0(sp)
    80001fbc:	1000                	addi	s0,sp,32
    80001fbe:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fc0:	00000097          	auipc	ra,0x0
    80001fc4:	ab0080e7          	jalr	-1360(ra) # 80001a70 <myproc>
    80001fc8:	892a                	mv	s2,a0
  sz = p->sz;
    80001fca:	7d0c                	ld	a1,56(a0)
    80001fcc:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001fd0:	00904f63          	bgtz	s1,80001fee <growproc+0x3c>
  } else if(n < 0){
    80001fd4:	0204cc63          	bltz	s1,8000200c <growproc+0x5a>
  p->sz = sz;
    80001fd8:	1602                	slli	a2,a2,0x20
    80001fda:	9201                	srli	a2,a2,0x20
    80001fdc:	02c93c23          	sd	a2,56(s2)
  return 0;
    80001fe0:	4501                	li	a0,0
}
    80001fe2:	60e2                	ld	ra,24(sp)
    80001fe4:	6442                	ld	s0,16(sp)
    80001fe6:	64a2                	ld	s1,8(sp)
    80001fe8:	6902                	ld	s2,0(sp)
    80001fea:	6105                	addi	sp,sp,32
    80001fec:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001fee:	9e25                	addw	a2,a2,s1
    80001ff0:	1602                	slli	a2,a2,0x20
    80001ff2:	9201                	srli	a2,a2,0x20
    80001ff4:	1582                	slli	a1,a1,0x20
    80001ff6:	9181                	srli	a1,a1,0x20
    80001ff8:	6128                	ld	a0,64(a0)
    80001ffa:	fffff097          	auipc	ra,0xfffff
    80001ffe:	40e080e7          	jalr	1038(ra) # 80001408 <uvmalloc>
    80002002:	0005061b          	sext.w	a2,a0
    80002006:	fa69                	bnez	a2,80001fd8 <growproc+0x26>
      return -1;
    80002008:	557d                	li	a0,-1
    8000200a:	bfe1                	j	80001fe2 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000200c:	9e25                	addw	a2,a2,s1
    8000200e:	1602                	slli	a2,a2,0x20
    80002010:	9201                	srli	a2,a2,0x20
    80002012:	1582                	slli	a1,a1,0x20
    80002014:	9181                	srli	a1,a1,0x20
    80002016:	6128                	ld	a0,64(a0)
    80002018:	fffff097          	auipc	ra,0xfffff
    8000201c:	3a8080e7          	jalr	936(ra) # 800013c0 <uvmdealloc>
    80002020:	0005061b          	sext.w	a2,a0
    80002024:	bf55                	j	80001fd8 <growproc+0x26>

0000000080002026 <fork>:
{
    80002026:	7139                	addi	sp,sp,-64
    80002028:	fc06                	sd	ra,56(sp)
    8000202a:	f822                	sd	s0,48(sp)
    8000202c:	f426                	sd	s1,40(sp)
    8000202e:	f04a                	sd	s2,32(sp)
    80002030:	ec4e                	sd	s3,24(sp)
    80002032:	e852                	sd	s4,16(sp)
    80002034:	e456                	sd	s5,8(sp)
    80002036:	e05a                	sd	s6,0(sp)
    80002038:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000203a:	00000097          	auipc	ra,0x0
    8000203e:	a36080e7          	jalr	-1482(ra) # 80001a70 <myproc>
    80002042:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    80002044:	00000097          	auipc	ra,0x0
    80002048:	a6c080e7          	jalr	-1428(ra) # 80001ab0 <mykthread>
    8000204c:	84aa                	mv	s1,a0
  if((np = allocproc()) == 0){
    8000204e:	00000097          	auipc	ra,0x0
    80002052:	d7c080e7          	jalr	-644(ra) # 80001dca <allocproc>
    80002056:	18050063          	beqz	a0,800021d6 <fork+0x1b0>
    8000205a:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000205c:	0389b603          	ld	a2,56(s3)
    80002060:	612c                	ld	a1,64(a0)
    80002062:	0409b503          	ld	a0,64(s3)
    80002066:	fffff097          	auipc	ra,0xfffff
    8000206a:	4ee080e7          	jalr	1262(ra) # 80001554 <uvmcopy>
    8000206e:	04054e63          	bltz	a0,800020ca <fork+0xa4>
  np->sz = p->sz;
    80002072:	0389b783          	ld	a5,56(s3)
    80002076:	02f93c23          	sd	a5,56(s2)
  acquire(&np_first_thread ->lock);
    8000207a:	28890a13          	addi	s4,s2,648
    8000207e:	8552                	mv	a0,s4
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	b46080e7          	jalr	-1210(ra) # 80000bc6 <acquire>
  *(np_first_thread->trapframe) = *(t->trapframe);
    80002088:	60b4                	ld	a3,64(s1)
    8000208a:	87b6                	mv	a5,a3
    8000208c:	2c893703          	ld	a4,712(s2)
    80002090:	12068693          	addi	a3,a3,288
    80002094:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002098:	6788                	ld	a0,8(a5)
    8000209a:	6b8c                	ld	a1,16(a5)
    8000209c:	6f90                	ld	a2,24(a5)
    8000209e:	01073023          	sd	a6,0(a4)
    800020a2:	e708                	sd	a0,8(a4)
    800020a4:	eb0c                	sd	a1,16(a4)
    800020a6:	ef10                	sd	a2,24(a4)
    800020a8:	02078793          	addi	a5,a5,32
    800020ac:	02070713          	addi	a4,a4,32
    800020b0:	fed792e3          	bne	a5,a3,80002094 <fork+0x6e>
  np_first_thread->trapframe->a0 = 0;  // TODO: change reading the ret value from proc a0 to thread a0
    800020b4:	2c893783          	ld	a5,712(s2)
    800020b8:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800020bc:	05098493          	addi	s1,s3,80
    800020c0:	05090a93          	addi	s5,s2,80
    800020c4:	0d098b13          	addi	s6,s3,208
    800020c8:	a00d                	j	800020ea <fork+0xc4>
    freeproc(np);
    800020ca:	854a                	mv	a0,s2
    800020cc:	00000097          	auipc	ra,0x0
    800020d0:	c62080e7          	jalr	-926(ra) # 80001d2e <freeproc>
    release(&np->lock);
    800020d4:	854a                	mv	a0,s2
    800020d6:	fffff097          	auipc	ra,0xfffff
    800020da:	bba080e7          	jalr	-1094(ra) # 80000c90 <release>
    return -1;
    800020de:	5afd                	li	s5,-1
    800020e0:	a0c5                	j	800021c0 <fork+0x19a>
  for(i = 0; i < NOFILE; i++)
    800020e2:	04a1                	addi	s1,s1,8
    800020e4:	0aa1                	addi	s5,s5,8
    800020e6:	01648b63          	beq	s1,s6,800020fc <fork+0xd6>
    if(p->ofile[i])
    800020ea:	6088                	ld	a0,0(s1)
    800020ec:	d97d                	beqz	a0,800020e2 <fork+0xbc>
      np->ofile[i] = filedup(p->ofile[i]);
    800020ee:	00003097          	auipc	ra,0x3
    800020f2:	582080e7          	jalr	1410(ra) # 80005670 <filedup>
    800020f6:	00aab023          	sd	a0,0(s5) # 4000000 <_entry-0x7c000000>
    800020fa:	b7e5                	j	800020e2 <fork+0xbc>
  np->cwd = idup(p->cwd);
    800020fc:	0d09b503          	ld	a0,208(s3)
    80002100:	00002097          	auipc	ra,0x2
    80002104:	6e4080e7          	jalr	1764(ra) # 800047e4 <idup>
    80002108:	0ca93823          	sd	a0,208(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000210c:	4641                	li	a2,16
    8000210e:	0d898593          	addi	a1,s3,216
    80002112:	0d890513          	addi	a0,s2,216
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	d14080e7          	jalr	-748(ra) # 80000e2a <safestrcpy>
  np->signal_mask = p->signal_mask;
    8000211e:	0ec9a783          	lw	a5,236(s3)
    80002122:	0ef92623          	sw	a5,236(s2)
  for(int i=0;i<32;i++){
    80002126:	0f898693          	addi	a3,s3,248
    8000212a:	0f890713          	addi	a4,s2,248
  np->signal_mask = p->signal_mask;
    8000212e:	1f800793          	li	a5,504
  for(int i=0;i<32;i++){
    80002132:	27800513          	li	a0,632
    np->signal_handlers[i] = p->signal_handlers[i];
    80002136:	6290                	ld	a2,0(a3)
    80002138:	e310                	sd	a2,0(a4)
    np->handlers_sigmasks[i] = p->handlers_sigmasks[i];
    8000213a:	00f98633          	add	a2,s3,a5
    8000213e:	420c                	lw	a1,0(a2)
    80002140:	00f90633          	add	a2,s2,a5
    80002144:	c20c                	sw	a1,0(a2)
  for(int i=0;i<32;i++){
    80002146:	06a1                	addi	a3,a3,8
    80002148:	0721                	addi	a4,a4,8
    8000214a:	0791                	addi	a5,a5,4
    8000214c:	fea795e3          	bne	a5,a0,80002136 <fork+0x110>
  np-> pending_signals=0;
    80002150:	0e092423          	sw	zero,232(s2)
  pid = np->pid;
    80002154:	02492a83          	lw	s5,36(s2)
  release(&np_first_thread->lock);  // TODO: check if we need to hold the lock of thread during this func
    80002158:	8552                	mv	a0,s4
    8000215a:	fffff097          	auipc	ra,0xfffff
    8000215e:	b36080e7          	jalr	-1226(ra) # 80000c90 <release>
  release(&np->lock);
    80002162:	854a                	mv	a0,s2
    80002164:	fffff097          	auipc	ra,0xfffff
    80002168:	b2c080e7          	jalr	-1236(ra) # 80000c90 <release>
  acquire(&wait_lock);
    8000216c:	00010497          	auipc	s1,0x10
    80002170:	16448493          	addi	s1,s1,356 # 800122d0 <wait_lock>
    80002174:	8526                	mv	a0,s1
    80002176:	fffff097          	auipc	ra,0xfffff
    8000217a:	a50080e7          	jalr	-1456(ra) # 80000bc6 <acquire>
  np->parent = p;
    8000217e:	03393823          	sd	s3,48(s2)
  release(&wait_lock);
    80002182:	8526                	mv	a0,s1
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	b0c080e7          	jalr	-1268(ra) # 80000c90 <release>
  acquire(&np->lock);
    8000218c:	854a                	mv	a0,s2
    8000218e:	fffff097          	auipc	ra,0xfffff
    80002192:	a38080e7          	jalr	-1480(ra) # 80000bc6 <acquire>
  acquire(&np_first_thread->lock);
    80002196:	8552                	mv	a0,s4
    80002198:	fffff097          	auipc	ra,0xfffff
    8000219c:	a2e080e7          	jalr	-1490(ra) # 80000bc6 <acquire>
  np->state = RUNNABLE;   //TOOD: check if we still need this state or should change
    800021a0:	4789                	li	a5,2
    800021a2:	00f92c23          	sw	a5,24(s2)
  np_first_thread->state = TRUNNABLE;
    800021a6:	478d                	li	a5,3
    800021a8:	2af92023          	sw	a5,672(s2)
  release(&np_first_thread->lock);
    800021ac:	8552                	mv	a0,s4
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	ae2080e7          	jalr	-1310(ra) # 80000c90 <release>
  release(&np->lock);
    800021b6:	854a                	mv	a0,s2
    800021b8:	fffff097          	auipc	ra,0xfffff
    800021bc:	ad8080e7          	jalr	-1320(ra) # 80000c90 <release>
}
    800021c0:	8556                	mv	a0,s5
    800021c2:	70e2                	ld	ra,56(sp)
    800021c4:	7442                	ld	s0,48(sp)
    800021c6:	74a2                	ld	s1,40(sp)
    800021c8:	7902                	ld	s2,32(sp)
    800021ca:	69e2                	ld	s3,24(sp)
    800021cc:	6a42                	ld	s4,16(sp)
    800021ce:	6aa2                	ld	s5,8(sp)
    800021d0:	6b02                	ld	s6,0(sp)
    800021d2:	6121                	addi	sp,sp,64
    800021d4:	8082                	ret
    return -1;
    800021d6:	5afd                	li	s5,-1
    800021d8:	b7e5                	j	800021c0 <fork+0x19a>

00000000800021da <scheduler>:
{
    800021da:	711d                	addi	sp,sp,-96
    800021dc:	ec86                	sd	ra,88(sp)
    800021de:	e8a2                	sd	s0,80(sp)
    800021e0:	e4a6                	sd	s1,72(sp)
    800021e2:	e0ca                	sd	s2,64(sp)
    800021e4:	fc4e                	sd	s3,56(sp)
    800021e6:	f852                	sd	s4,48(sp)
    800021e8:	f456                	sd	s5,40(sp)
    800021ea:	f05a                	sd	s6,32(sp)
    800021ec:	ec5e                	sd	s7,24(sp)
    800021ee:	e862                	sd	s8,16(sp)
    800021f0:	e466                	sd	s9,8(sp)
    800021f2:	1080                	addi	s0,sp,96
    800021f4:	8792                	mv	a5,tp
  int id = r_tp();
    800021f6:	2781                	sext.w	a5,a5
  c->proc = 0;
    800021f8:	00479713          	slli	a4,a5,0x4
    800021fc:	00f706b3          	add	a3,a4,a5
    80002200:	00369613          	slli	a2,a3,0x3
    80002204:	00010697          	auipc	a3,0x10
    80002208:	09c68693          	addi	a3,a3,156 # 800122a0 <pid_lock>
    8000220c:	96b2                	add	a3,a3,a2
    8000220e:	0406b423          	sd	zero,72(a3)
  c->kthread=0;
    80002212:	0c06b423          	sd	zero,200(a3)
            swtch(&c->context, &t->context);
    80002216:	00010717          	auipc	a4,0x10
    8000221a:	0da70713          	addi	a4,a4,218 # 800122f0 <cpus+0x8>
    8000221e:	00e60bb3          	add	s7,a2,a4
            c->proc = p;
    80002222:	8b36                	mv	s6,a3
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002224:	6a85                	lui	s5,0x1
    80002226:	848a8a93          	addi	s5,s5,-1976 # 848 <_entry-0x7ffff7b8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000222a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000222e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002232:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002236:	00010917          	auipc	s2,0x10
    8000223a:	4f290913          	addi	s2,s2,1266 # 80012728 <proc>
    8000223e:	a8a9                	j	80002298 <scheduler+0xbe>
          release(&t->lock);
    80002240:	8526                	mv	a0,s1
    80002242:	fffff097          	auipc	ra,0xfffff
    80002246:	a4e080e7          	jalr	-1458(ra) # 80000c90 <release>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    8000224a:	0b848493          	addi	s1,s1,184
    8000224e:	03348e63          	beq	s1,s3,8000228a <scheduler+0xb0>
          acquire(&t->lock);
    80002252:	8526                	mv	a0,s1
    80002254:	fffff097          	auipc	ra,0xfffff
    80002258:	972080e7          	jalr	-1678(ra) # 80000bc6 <acquire>
          if(t->state == TRUNNABLE && !t->frozen) {
    8000225c:	4c9c                	lw	a5,24(s1)
    8000225e:	ff4791e3          	bne	a5,s4,80002240 <scheduler+0x66>
    80002262:	58dc                	lw	a5,52(s1)
    80002264:	fff1                	bnez	a5,80002240 <scheduler+0x66>
            t->state = TRUNNING;
    80002266:	0194ac23          	sw	s9,24(s1)
            c->proc = p;
    8000226a:	052b3423          	sd	s2,72(s6)
            c->kthread = t;
    8000226e:	0c9b3423          	sd	s1,200(s6)
            swtch(&c->context, &t->context);
    80002272:	04848593          	addi	a1,s1,72
    80002276:	855e                	mv	a0,s7
    80002278:	00001097          	auipc	ra,0x1
    8000227c:	f04080e7          	jalr	-252(ra) # 8000317c <swtch>
            c->proc = 0;
    80002280:	040b3423          	sd	zero,72(s6)
            c->kthread=0;
    80002284:	0c0b3423          	sd	zero,200(s6)
    80002288:	bf65                	j	80002240 <scheduler+0x66>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000228a:	9956                	add	s2,s2,s5
    8000228c:	00031797          	auipc	a5,0x31
    80002290:	69c78793          	addi	a5,a5,1692 # 80033928 <tickslock>
    80002294:	f8f90be3          	beq	s2,a5,8000222a <scheduler+0x50>
      if(p->state == RUNNABLE) {
    80002298:	01892703          	lw	a4,24(s2)
    8000229c:	4789                	li	a5,2
    8000229e:	fef716e3          	bne	a4,a5,8000228a <scheduler+0xb0>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    800022a2:	28890493          	addi	s1,s2,648
          if(t->state == TRUNNABLE && !t->frozen) {
    800022a6:	4a0d                	li	s4,3
            t->state = TRUNNING;
    800022a8:	4c91                	li	s9,4
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    800022aa:	015909b3          	add	s3,s2,s5
    800022ae:	b755                	j	80002252 <scheduler+0x78>

00000000800022b0 <sched>:
{
    800022b0:	7179                	addi	sp,sp,-48
    800022b2:	f406                	sd	ra,40(sp)
    800022b4:	f022                	sd	s0,32(sp)
    800022b6:	ec26                	sd	s1,24(sp)
    800022b8:	e84a                	sd	s2,16(sp)
    800022ba:	e44e                	sd	s3,8(sp)
    800022bc:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800022be:	fffff097          	auipc	ra,0xfffff
    800022c2:	7b2080e7          	jalr	1970(ra) # 80001a70 <myproc>
  struct kthread *t=mykthread();
    800022c6:	fffff097          	auipc	ra,0xfffff
    800022ca:	7ea080e7          	jalr	2026(ra) # 80001ab0 <mykthread>
    800022ce:	84aa                	mv	s1,a0
  if(!holding(&t->lock))
    800022d0:	fffff097          	auipc	ra,0xfffff
    800022d4:	87c080e7          	jalr	-1924(ra) # 80000b4c <holding>
    800022d8:	c959                	beqz	a0,8000236e <sched+0xbe>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022da:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800022dc:	0007871b          	sext.w	a4,a5
    800022e0:	00471793          	slli	a5,a4,0x4
    800022e4:	97ba                	add	a5,a5,a4
    800022e6:	078e                	slli	a5,a5,0x3
    800022e8:	00010717          	auipc	a4,0x10
    800022ec:	fb870713          	addi	a4,a4,-72 # 800122a0 <pid_lock>
    800022f0:	97ba                	add	a5,a5,a4
    800022f2:	0c07a703          	lw	a4,192(a5)
    800022f6:	4785                	li	a5,1
    800022f8:	08f71363          	bne	a4,a5,8000237e <sched+0xce>
  if(t->state == TRUNNING)
    800022fc:	4c98                	lw	a4,24(s1)
    800022fe:	4791                	li	a5,4
    80002300:	08f70763          	beq	a4,a5,8000238e <sched+0xde>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002304:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002308:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000230a:	ebd1                	bnez	a5,8000239e <sched+0xee>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000230c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000230e:	00010917          	auipc	s2,0x10
    80002312:	f9290913          	addi	s2,s2,-110 # 800122a0 <pid_lock>
    80002316:	0007871b          	sext.w	a4,a5
    8000231a:	00471793          	slli	a5,a4,0x4
    8000231e:	97ba                	add	a5,a5,a4
    80002320:	078e                	slli	a5,a5,0x3
    80002322:	97ca                	add	a5,a5,s2
    80002324:	0c47a983          	lw	s3,196(a5)
    80002328:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    8000232a:	0007859b          	sext.w	a1,a5
    8000232e:	00459793          	slli	a5,a1,0x4
    80002332:	97ae                	add	a5,a5,a1
    80002334:	078e                	slli	a5,a5,0x3
    80002336:	00010597          	auipc	a1,0x10
    8000233a:	fba58593          	addi	a1,a1,-70 # 800122f0 <cpus+0x8>
    8000233e:	95be                	add	a1,a1,a5
    80002340:	04848513          	addi	a0,s1,72
    80002344:	00001097          	auipc	ra,0x1
    80002348:	e38080e7          	jalr	-456(ra) # 8000317c <swtch>
    8000234c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000234e:	0007871b          	sext.w	a4,a5
    80002352:	00471793          	slli	a5,a4,0x4
    80002356:	97ba                	add	a5,a5,a4
    80002358:	078e                	slli	a5,a5,0x3
    8000235a:	97ca                	add	a5,a5,s2
    8000235c:	0d37a223          	sw	s3,196(a5)
}
    80002360:	70a2                	ld	ra,40(sp)
    80002362:	7402                	ld	s0,32(sp)
    80002364:	64e2                	ld	s1,24(sp)
    80002366:	6942                	ld	s2,16(sp)
    80002368:	69a2                	ld	s3,8(sp)
    8000236a:	6145                	addi	sp,sp,48
    8000236c:	8082                	ret
    panic("sched t->lock");
    8000236e:	00007517          	auipc	a0,0x7
    80002372:	f1a50513          	addi	a0,a0,-230 # 80009288 <digits+0x248>
    80002376:	ffffe097          	auipc	ra,0xffffe
    8000237a:	1b8080e7          	jalr	440(ra) # 8000052e <panic>
    panic("sched locks");
    8000237e:	00007517          	auipc	a0,0x7
    80002382:	f1a50513          	addi	a0,a0,-230 # 80009298 <digits+0x258>
    80002386:	ffffe097          	auipc	ra,0xffffe
    8000238a:	1a8080e7          	jalr	424(ra) # 8000052e <panic>
    panic("sched running");
    8000238e:	00007517          	auipc	a0,0x7
    80002392:	f1a50513          	addi	a0,a0,-230 # 800092a8 <digits+0x268>
    80002396:	ffffe097          	auipc	ra,0xffffe
    8000239a:	198080e7          	jalr	408(ra) # 8000052e <panic>
    panic("sched interruptible");
    8000239e:	00007517          	auipc	a0,0x7
    800023a2:	f1a50513          	addi	a0,a0,-230 # 800092b8 <digits+0x278>
    800023a6:	ffffe097          	auipc	ra,0xffffe
    800023aa:	188080e7          	jalr	392(ra) # 8000052e <panic>

00000000800023ae <yield>:
{
    800023ae:	1101                	addi	sp,sp,-32
    800023b0:	ec06                	sd	ra,24(sp)
    800023b2:	e822                	sd	s0,16(sp)
    800023b4:	e426                	sd	s1,8(sp)
    800023b6:	1000                	addi	s0,sp,32
  struct kthread *t =mykthread();
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	6f8080e7          	jalr	1784(ra) # 80001ab0 <mykthread>
    800023c0:	84aa                	mv	s1,a0
  acquire(&t->lock);
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	804080e7          	jalr	-2044(ra) # 80000bc6 <acquire>
  t->state = TRUNNABLE;
    800023ca:	478d                	li	a5,3
    800023cc:	cc9c                	sw	a5,24(s1)
  sched();
    800023ce:	00000097          	auipc	ra,0x0
    800023d2:	ee2080e7          	jalr	-286(ra) # 800022b0 <sched>
  release(&t->lock);
    800023d6:	8526                	mv	a0,s1
    800023d8:	fffff097          	auipc	ra,0xfffff
    800023dc:	8b8080e7          	jalr	-1864(ra) # 80000c90 <release>
}
    800023e0:	60e2                	ld	ra,24(sp)
    800023e2:	6442                	ld	s0,16(sp)
    800023e4:	64a2                	ld	s1,8(sp)
    800023e6:	6105                	addi	sp,sp,32
    800023e8:	8082                	ret

00000000800023ea <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800023ea:	7179                	addi	sp,sp,-48
    800023ec:	f406                	sd	ra,40(sp)
    800023ee:	f022                	sd	s0,32(sp)
    800023f0:	ec26                	sd	s1,24(sp)
    800023f2:	e84a                	sd	s2,16(sp)
    800023f4:	e44e                	sd	s3,8(sp)
    800023f6:	1800                	addi	s0,sp,48
    800023f8:	89aa                	mv	s3,a0
    800023fa:	892e                	mv	s2,a1
  // struct proc *p = myproc();
  struct kthread *t=mykthread();
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	6b4080e7          	jalr	1716(ra) # 80001ab0 <mykthread>
    80002404:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&t->lock);  //DOC: sleeplock1
    80002406:	ffffe097          	auipc	ra,0xffffe
    8000240a:	7c0080e7          	jalr	1984(ra) # 80000bc6 <acquire>
  release(lk);
    8000240e:	854a                	mv	a0,s2
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	880080e7          	jalr	-1920(ra) # 80000c90 <release>

  // Go to sleep.
  t->chan = chan;
    80002418:	0334b023          	sd	s3,32(s1)
  t->state = TSLEEPING;
    8000241c:	4789                	li	a5,2
    8000241e:	cc9c                	sw	a5,24(s1)

  sched();
    80002420:	00000097          	auipc	ra,0x0
    80002424:	e90080e7          	jalr	-368(ra) # 800022b0 <sched>

  // Tidy up.
  t->chan = 0;
    80002428:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&t->lock);
    8000242c:	8526                	mv	a0,s1
    8000242e:	fffff097          	auipc	ra,0xfffff
    80002432:	862080e7          	jalr	-1950(ra) # 80000c90 <release>
  acquire(lk);
    80002436:	854a                	mv	a0,s2
    80002438:	ffffe097          	auipc	ra,0xffffe
    8000243c:	78e080e7          	jalr	1934(ra) # 80000bc6 <acquire>
}
    80002440:	70a2                	ld	ra,40(sp)
    80002442:	7402                	ld	s0,32(sp)
    80002444:	64e2                	ld	s1,24(sp)
    80002446:	6942                	ld	s2,16(sp)
    80002448:	69a2                	ld	s3,8(sp)
    8000244a:	6145                	addi	sp,sp,48
    8000244c:	8082                	ret

000000008000244e <wait>:
{
    8000244e:	715d                	addi	sp,sp,-80
    80002450:	e486                	sd	ra,72(sp)
    80002452:	e0a2                	sd	s0,64(sp)
    80002454:	fc26                	sd	s1,56(sp)
    80002456:	f84a                	sd	s2,48(sp)
    80002458:	f44e                	sd	s3,40(sp)
    8000245a:	f052                	sd	s4,32(sp)
    8000245c:	ec56                	sd	s5,24(sp)
    8000245e:	e85a                	sd	s6,16(sp)
    80002460:	e45e                	sd	s7,8(sp)
    80002462:	0880                	addi	s0,sp,80
    80002464:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002466:	fffff097          	auipc	ra,0xfffff
    8000246a:	60a080e7          	jalr	1546(ra) # 80001a70 <myproc>
    8000246e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002470:	00010517          	auipc	a0,0x10
    80002474:	e6050513          	addi	a0,a0,-416 # 800122d0 <wait_lock>
    80002478:	ffffe097          	auipc	ra,0xffffe
    8000247c:	74e080e7          	jalr	1870(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    80002480:	4b0d                	li	s6,3
        havekids = 1;
    80002482:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002484:	6985                	lui	s3,0x1
    80002486:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    8000248a:	00031a17          	auipc	s4,0x31
    8000248e:	49ea0a13          	addi	s4,s4,1182 # 80033928 <tickslock>
    havekids = 0;
    80002492:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    80002494:	00010497          	auipc	s1,0x10
    80002498:	29448493          	addi	s1,s1,660 # 80012728 <proc>
    8000249c:	a0b5                	j	80002508 <wait+0xba>
          pid = np->pid;
    8000249e:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800024a2:	000b8e63          	beqz	s7,800024be <wait+0x70>
    800024a6:	4691                	li	a3,4
    800024a8:	02048613          	addi	a2,s1,32
    800024ac:	85de                	mv	a1,s7
    800024ae:	04093503          	ld	a0,64(s2)
    800024b2:	fffff097          	auipc	ra,0xfffff
    800024b6:	1a6080e7          	jalr	422(ra) # 80001658 <copyout>
    800024ba:	02054563          	bltz	a0,800024e4 <wait+0x96>
          freeproc(np);
    800024be:	8526                	mv	a0,s1
    800024c0:	00000097          	auipc	ra,0x0
    800024c4:	86e080e7          	jalr	-1938(ra) # 80001d2e <freeproc>
          release(&np->lock);
    800024c8:	8526                	mv	a0,s1
    800024ca:	ffffe097          	auipc	ra,0xffffe
    800024ce:	7c6080e7          	jalr	1990(ra) # 80000c90 <release>
          release(&wait_lock);
    800024d2:	00010517          	auipc	a0,0x10
    800024d6:	dfe50513          	addi	a0,a0,-514 # 800122d0 <wait_lock>
    800024da:	ffffe097          	auipc	ra,0xffffe
    800024de:	7b6080e7          	jalr	1974(ra) # 80000c90 <release>
          return pid;
    800024e2:	a09d                	j	80002548 <wait+0xfa>
            release(&np->lock);
    800024e4:	8526                	mv	a0,s1
    800024e6:	ffffe097          	auipc	ra,0xffffe
    800024ea:	7aa080e7          	jalr	1962(ra) # 80000c90 <release>
            release(&wait_lock);
    800024ee:	00010517          	auipc	a0,0x10
    800024f2:	de250513          	addi	a0,a0,-542 # 800122d0 <wait_lock>
    800024f6:	ffffe097          	auipc	ra,0xffffe
    800024fa:	79a080e7          	jalr	1946(ra) # 80000c90 <release>
            return -1;
    800024fe:	59fd                	li	s3,-1
    80002500:	a0a1                	j	80002548 <wait+0xfa>
    for(np = proc; np < &proc[NPROC]; np++){
    80002502:	94ce                	add	s1,s1,s3
    80002504:	03448463          	beq	s1,s4,8000252c <wait+0xde>
      if(np->parent == p){
    80002508:	789c                	ld	a5,48(s1)
    8000250a:	ff279ce3          	bne	a5,s2,80002502 <wait+0xb4>
        acquire(&np->lock);
    8000250e:	8526                	mv	a0,s1
    80002510:	ffffe097          	auipc	ra,0xffffe
    80002514:	6b6080e7          	jalr	1718(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    80002518:	4c9c                	lw	a5,24(s1)
    8000251a:	f96782e3          	beq	a5,s6,8000249e <wait+0x50>
        release(&np->lock);
    8000251e:	8526                	mv	a0,s1
    80002520:	ffffe097          	auipc	ra,0xffffe
    80002524:	770080e7          	jalr	1904(ra) # 80000c90 <release>
        havekids = 1;
    80002528:	8756                	mv	a4,s5
    8000252a:	bfe1                	j	80002502 <wait+0xb4>
    if(!havekids || p->killed==1){
    8000252c:	c709                	beqz	a4,80002536 <wait+0xe8>
    8000252e:	01c92783          	lw	a5,28(s2)
    80002532:	03579763          	bne	a5,s5,80002560 <wait+0x112>
      release(&wait_lock);
    80002536:	00010517          	auipc	a0,0x10
    8000253a:	d9a50513          	addi	a0,a0,-614 # 800122d0 <wait_lock>
    8000253e:	ffffe097          	auipc	ra,0xffffe
    80002542:	752080e7          	jalr	1874(ra) # 80000c90 <release>
      return -1;
    80002546:	59fd                	li	s3,-1
}
    80002548:	854e                	mv	a0,s3
    8000254a:	60a6                	ld	ra,72(sp)
    8000254c:	6406                	ld	s0,64(sp)
    8000254e:	74e2                	ld	s1,56(sp)
    80002550:	7942                	ld	s2,48(sp)
    80002552:	79a2                	ld	s3,40(sp)
    80002554:	7a02                	ld	s4,32(sp)
    80002556:	6ae2                	ld	s5,24(sp)
    80002558:	6b42                	ld	s6,16(sp)
    8000255a:	6ba2                	ld	s7,8(sp)
    8000255c:	6161                	addi	sp,sp,80
    8000255e:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002560:	00010597          	auipc	a1,0x10
    80002564:	d7058593          	addi	a1,a1,-656 # 800122d0 <wait_lock>
    80002568:	854a                	mv	a0,s2
    8000256a:	00000097          	auipc	ra,0x0
    8000256e:	e80080e7          	jalr	-384(ra) # 800023ea <sleep>
    havekids = 0;
    80002572:	b705                	j	80002492 <wait+0x44>

0000000080002574 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002574:	711d                	addi	sp,sp,-96
    80002576:	ec86                	sd	ra,88(sp)
    80002578:	e8a2                	sd	s0,80(sp)
    8000257a:	e4a6                	sd	s1,72(sp)
    8000257c:	e0ca                	sd	s2,64(sp)
    8000257e:	fc4e                	sd	s3,56(sp)
    80002580:	f852                	sd	s4,48(sp)
    80002582:	f456                	sd	s5,40(sp)
    80002584:	f05a                	sd	s6,32(sp)
    80002586:	ec5e                	sd	s7,24(sp)
    80002588:	e862                	sd	s8,16(sp)
    8000258a:	e466                	sd	s9,8(sp)
    8000258c:	1080                	addi	s0,sp,96
    8000258e:	8c2a                	mv	s8,a0
  struct proc *p;
  struct kthread *t;
  struct kthread *my_t = mykthread();
    80002590:	fffff097          	auipc	ra,0xfffff
    80002594:	520080e7          	jalr	1312(ra) # 80001ab0 <mykthread>
    80002598:	8aaa                	mv	s5,a0

  for(p = proc; p < &proc[NPROC]; p++) {
    8000259a:	00010917          	auipc	s2,0x10
    8000259e:	41690913          	addi	s2,s2,1046 # 800129b0 <proc+0x288>
    800025a2:	00031b97          	auipc	s7,0x31
    800025a6:	60eb8b93          	addi	s7,s7,1550 # 80033bb0 <bcache+0x270>
    if(p->state == RUNNABLE){
    800025aa:	4989                	li	s3,2
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
        if(t != my_t){
          acquire(&t->lock);
          if(t->state == TSLEEPING && t->chan == chan) {
            t->state = TRUNNABLE;
    800025ac:	4c8d                	li	s9,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800025ae:	6b05                	lui	s6,0x1
    800025b0:	848b0b13          	addi	s6,s6,-1976 # 848 <_entry-0x7ffff7b8>
    800025b4:	a82d                	j	800025ee <wakeup+0x7a>
          }
          release(&t->lock);
    800025b6:	8526                	mv	a0,s1
    800025b8:	ffffe097          	auipc	ra,0xffffe
    800025bc:	6d8080e7          	jalr	1752(ra) # 80000c90 <release>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800025c0:	0b848493          	addi	s1,s1,184
    800025c4:	03448263          	beq	s1,s4,800025e8 <wakeup+0x74>
        if(t != my_t){
    800025c8:	fe9a8ce3          	beq	s5,s1,800025c0 <wakeup+0x4c>
          acquire(&t->lock);
    800025cc:	8526                	mv	a0,s1
    800025ce:	ffffe097          	auipc	ra,0xffffe
    800025d2:	5f8080e7          	jalr	1528(ra) # 80000bc6 <acquire>
          if(t->state == TSLEEPING && t->chan == chan) {
    800025d6:	4c9c                	lw	a5,24(s1)
    800025d8:	fd379fe3          	bne	a5,s3,800025b6 <wakeup+0x42>
    800025dc:	709c                	ld	a5,32(s1)
    800025de:	fd879ce3          	bne	a5,s8,800025b6 <wakeup+0x42>
            t->state = TRUNNABLE;
    800025e2:	0194ac23          	sw	s9,24(s1)
    800025e6:	bfc1                	j	800025b6 <wakeup+0x42>
  for(p = proc; p < &proc[NPROC]; p++) {
    800025e8:	995a                	add	s2,s2,s6
    800025ea:	01790a63          	beq	s2,s7,800025fe <wakeup+0x8a>
    if(p->state == RUNNABLE){
    800025ee:	84ca                	mv	s1,s2
    800025f0:	d9092783          	lw	a5,-624(s2)
    800025f4:	ff379ae3          	bne	a5,s3,800025e8 <wakeup+0x74>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800025f8:	5c090a13          	addi	s4,s2,1472
    800025fc:	b7f1                	j	800025c8 <wakeup+0x54>
        }
      }
    }
  }
}
    800025fe:	60e6                	ld	ra,88(sp)
    80002600:	6446                	ld	s0,80(sp)
    80002602:	64a6                	ld	s1,72(sp)
    80002604:	6906                	ld	s2,64(sp)
    80002606:	79e2                	ld	s3,56(sp)
    80002608:	7a42                	ld	s4,48(sp)
    8000260a:	7aa2                	ld	s5,40(sp)
    8000260c:	7b02                	ld	s6,32(sp)
    8000260e:	6be2                	ld	s7,24(sp)
    80002610:	6c42                	ld	s8,16(sp)
    80002612:	6ca2                	ld	s9,8(sp)
    80002614:	6125                	addi	sp,sp,96
    80002616:	8082                	ret

0000000080002618 <reparent>:
{
    80002618:	7139                	addi	sp,sp,-64
    8000261a:	fc06                	sd	ra,56(sp)
    8000261c:	f822                	sd	s0,48(sp)
    8000261e:	f426                	sd	s1,40(sp)
    80002620:	f04a                	sd	s2,32(sp)
    80002622:	ec4e                	sd	s3,24(sp)
    80002624:	e852                	sd	s4,16(sp)
    80002626:	e456                	sd	s5,8(sp)
    80002628:	0080                	addi	s0,sp,64
    8000262a:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000262c:	00010497          	auipc	s1,0x10
    80002630:	0fc48493          	addi	s1,s1,252 # 80012728 <proc>
      pp->parent = initproc;
    80002634:	00008a97          	auipc	s5,0x8
    80002638:	9f4a8a93          	addi	s5,s5,-1548 # 8000a028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000263c:	6905                	lui	s2,0x1
    8000263e:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002642:	00031a17          	auipc	s4,0x31
    80002646:	2e6a0a13          	addi	s4,s4,742 # 80033928 <tickslock>
    8000264a:	a021                	j	80002652 <reparent+0x3a>
    8000264c:	94ca                	add	s1,s1,s2
    8000264e:	01448d63          	beq	s1,s4,80002668 <reparent+0x50>
    if(pp->parent == p){
    80002652:	789c                	ld	a5,48(s1)
    80002654:	ff379ce3          	bne	a5,s3,8000264c <reparent+0x34>
      pp->parent = initproc;
    80002658:	000ab503          	ld	a0,0(s5)
    8000265c:	f888                	sd	a0,48(s1)
      wakeup(initproc);
    8000265e:	00000097          	auipc	ra,0x0
    80002662:	f16080e7          	jalr	-234(ra) # 80002574 <wakeup>
    80002666:	b7dd                	j	8000264c <reparent+0x34>
}
    80002668:	70e2                	ld	ra,56(sp)
    8000266a:	7442                	ld	s0,48(sp)
    8000266c:	74a2                	ld	s1,40(sp)
    8000266e:	7902                	ld	s2,32(sp)
    80002670:	69e2                	ld	s3,24(sp)
    80002672:	6a42                	ld	s4,16(sp)
    80002674:	6aa2                	ld	s5,8(sp)
    80002676:	6121                	addi	sp,sp,64
    80002678:	8082                	ret

000000008000267a <exit_proccess>:
{
    8000267a:	7139                	addi	sp,sp,-64
    8000267c:	fc06                	sd	ra,56(sp)
    8000267e:	f822                	sd	s0,48(sp)
    80002680:	f426                	sd	s1,40(sp)
    80002682:	f04a                	sd	s2,32(sp)
    80002684:	ec4e                	sd	s3,24(sp)
    80002686:	e852                	sd	s4,16(sp)
    80002688:	e456                	sd	s5,8(sp)
    8000268a:	0080                	addi	s0,sp,64
    8000268c:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    8000268e:	fffff097          	auipc	ra,0xfffff
    80002692:	3e2080e7          	jalr	994(ra) # 80001a70 <myproc>
    80002696:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    80002698:	fffff097          	auipc	ra,0xfffff
    8000269c:	418080e7          	jalr	1048(ra) # 80001ab0 <mykthread>
    800026a0:	8a2a                	mv	s4,a0
  if(p == initproc)
    800026a2:	00008797          	auipc	a5,0x8
    800026a6:	9867b783          	ld	a5,-1658(a5) # 8000a028 <initproc>
    800026aa:	05098493          	addi	s1,s3,80
    800026ae:	0d098913          	addi	s2,s3,208
    800026b2:	03379363          	bne	a5,s3,800026d8 <exit_proccess+0x5e>
    panic("init exiting");
    800026b6:	00007517          	auipc	a0,0x7
    800026ba:	c1a50513          	addi	a0,a0,-998 # 800092d0 <digits+0x290>
    800026be:	ffffe097          	auipc	ra,0xffffe
    800026c2:	e70080e7          	jalr	-400(ra) # 8000052e <panic>
      fileclose(f);
    800026c6:	00003097          	auipc	ra,0x3
    800026ca:	ffc080e7          	jalr	-4(ra) # 800056c2 <fileclose>
      p->ofile[fd] = 0;
    800026ce:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800026d2:	04a1                	addi	s1,s1,8
    800026d4:	01248563          	beq	s1,s2,800026de <exit_proccess+0x64>
    if(p->ofile[fd]){
    800026d8:	6088                	ld	a0,0(s1)
    800026da:	f575                	bnez	a0,800026c6 <exit_proccess+0x4c>
    800026dc:	bfdd                	j	800026d2 <exit_proccess+0x58>
  begin_op();
    800026de:	00003097          	auipc	ra,0x3
    800026e2:	b18080e7          	jalr	-1256(ra) # 800051f6 <begin_op>
  iput(p->cwd);
    800026e6:	0d09b503          	ld	a0,208(s3)
    800026ea:	00002097          	auipc	ra,0x2
    800026ee:	2f2080e7          	jalr	754(ra) # 800049dc <iput>
  end_op();
    800026f2:	00003097          	auipc	ra,0x3
    800026f6:	b84080e7          	jalr	-1148(ra) # 80005276 <end_op>
  p->cwd = 0;
    800026fa:	0c09b823          	sd	zero,208(s3)
  acquire(&wait_lock);
    800026fe:	00010497          	auipc	s1,0x10
    80002702:	bd248493          	addi	s1,s1,-1070 # 800122d0 <wait_lock>
    80002706:	8526                	mv	a0,s1
    80002708:	ffffe097          	auipc	ra,0xffffe
    8000270c:	4be080e7          	jalr	1214(ra) # 80000bc6 <acquire>
  reparent(p);
    80002710:	854e                	mv	a0,s3
    80002712:	00000097          	auipc	ra,0x0
    80002716:	f06080e7          	jalr	-250(ra) # 80002618 <reparent>
  wakeup(p->parent);
    8000271a:	0309b503          	ld	a0,48(s3)
    8000271e:	00000097          	auipc	ra,0x0
    80002722:	e56080e7          	jalr	-426(ra) # 80002574 <wakeup>
  acquire(&p->lock);
    80002726:	854e                	mv	a0,s3
    80002728:	ffffe097          	auipc	ra,0xffffe
    8000272c:	49e080e7          	jalr	1182(ra) # 80000bc6 <acquire>
  p->xstate = status;
    80002730:	0359a023          	sw	s5,32(s3)
  p->state = ZOMBIE;
    80002734:	478d                	li	a5,3
    80002736:	00f9ac23          	sw	a5,24(s3)
  release(&p->lock);// we added
    8000273a:	854e                	mv	a0,s3
    8000273c:	ffffe097          	auipc	ra,0xffffe
    80002740:	554080e7          	jalr	1364(ra) # 80000c90 <release>
  release(&wait_lock);
    80002744:	8526                	mv	a0,s1
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	54a080e7          	jalr	1354(ra) # 80000c90 <release>
  acquire(&t->lock);
    8000274e:	8552                	mv	a0,s4
    80002750:	ffffe097          	auipc	ra,0xffffe
    80002754:	476080e7          	jalr	1142(ra) # 80000bc6 <acquire>
  sched();
    80002758:	00000097          	auipc	ra,0x0
    8000275c:	b58080e7          	jalr	-1192(ra) # 800022b0 <sched>
  panic("zombie exit");
    80002760:	00007517          	auipc	a0,0x7
    80002764:	b8050513          	addi	a0,a0,-1152 # 800092e0 <digits+0x2a0>
    80002768:	ffffe097          	auipc	ra,0xffffe
    8000276c:	dc6080e7          	jalr	-570(ra) # 8000052e <panic>

0000000080002770 <kthread_exit>:
kthread_exit(int status){
    80002770:	7179                	addi	sp,sp,-48
    80002772:	f406                	sd	ra,40(sp)
    80002774:	f022                	sd	s0,32(sp)
    80002776:	ec26                	sd	s1,24(sp)
    80002778:	e84a                	sd	s2,16(sp)
    8000277a:	e44e                	sd	s3,8(sp)
    8000277c:	e052                	sd	s4,0(sp)
    8000277e:	1800                	addi	s0,sp,48
    80002780:	89aa                	mv	s3,a0
  struct proc *p = myproc(); 
    80002782:	fffff097          	auipc	ra,0xfffff
    80002786:	2ee080e7          	jalr	750(ra) # 80001a70 <myproc>
    8000278a:	892a                	mv	s2,a0
  struct kthread *t=mykthread();
    8000278c:	fffff097          	auipc	ra,0xfffff
    80002790:	324080e7          	jalr	804(ra) # 80001ab0 <mykthread>
    80002794:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002796:	854a                	mv	a0,s2
    80002798:	ffffe097          	auipc	ra,0xffffe
    8000279c:	42e080e7          	jalr	1070(ra) # 80000bc6 <acquire>
  p->active_threads--;
    800027a0:	02892783          	lw	a5,40(s2)
    800027a4:	37fd                	addiw	a5,a5,-1
    800027a6:	00078a1b          	sext.w	s4,a5
    800027aa:	02f92423          	sw	a5,40(s2)
  release(&p->lock);
    800027ae:	854a                	mv	a0,s2
    800027b0:	ffffe097          	auipc	ra,0xffffe
    800027b4:	4e0080e7          	jalr	1248(ra) # 80000c90 <release>
  acquire(&t->lock);
    800027b8:	8526                	mv	a0,s1
    800027ba:	ffffe097          	auipc	ra,0xffffe
    800027be:	40c080e7          	jalr	1036(ra) # 80000bc6 <acquire>
  t->xstate = status;
    800027c2:	0334a623          	sw	s3,44(s1)
  t->state  = TUNUSED;
    800027c6:	0004ac23          	sw	zero,24(s1)
  wakeup(t);
    800027ca:	8526                	mv	a0,s1
    800027cc:	00000097          	auipc	ra,0x0
    800027d0:	da8080e7          	jalr	-600(ra) # 80002574 <wakeup>
  if(curr_active_threads==0){
    800027d4:	000a1c63          	bnez	s4,800027ec <kthread_exit+0x7c>
    release(&t->lock);
    800027d8:	8526                	mv	a0,s1
    800027da:	ffffe097          	auipc	ra,0xffffe
    800027de:	4b6080e7          	jalr	1206(ra) # 80000c90 <release>
    exit_proccess(status);
    800027e2:	854e                	mv	a0,s3
    800027e4:	00000097          	auipc	ra,0x0
    800027e8:	e96080e7          	jalr	-362(ra) # 8000267a <exit_proccess>
    sched();
    800027ec:	00000097          	auipc	ra,0x0
    800027f0:	ac4080e7          	jalr	-1340(ra) # 800022b0 <sched>
    panic("zombie thread exit");
    800027f4:	00007517          	auipc	a0,0x7
    800027f8:	afc50513          	addi	a0,a0,-1284 # 800092f0 <digits+0x2b0>
    800027fc:	ffffe097          	auipc	ra,0xffffe
    80002800:	d32080e7          	jalr	-718(ra) # 8000052e <panic>

0000000080002804 <exit>:
exit(int status){
    80002804:	7139                	addi	sp,sp,-64
    80002806:	fc06                	sd	ra,56(sp)
    80002808:	f822                	sd	s0,48(sp)
    8000280a:	f426                	sd	s1,40(sp)
    8000280c:	f04a                	sd	s2,32(sp)
    8000280e:	ec4e                	sd	s3,24(sp)
    80002810:	e852                	sd	s4,16(sp)
    80002812:	e456                	sd	s5,8(sp)
    80002814:	e05a                	sd	s6,0(sp)
    80002816:	0080                	addi	s0,sp,64
    80002818:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    8000281a:	fffff097          	auipc	ra,0xfffff
    8000281e:	256080e7          	jalr	598(ra) # 80001a70 <myproc>
    80002822:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80002824:	fffff097          	auipc	ra,0xfffff
    80002828:	28c080e7          	jalr	652(ra) # 80001ab0 <mykthread>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    8000282c:	28890493          	addi	s1,s2,648
    80002830:	6505                	lui	a0,0x1
    80002832:	84850513          	addi	a0,a0,-1976 # 848 <_entry-0x7ffff7b8>
    80002836:	992a                	add	s2,s2,a0
    t->killed = 1;
    80002838:	4a05                	li	s4,1
    if(t->state == TSLEEPING)
    8000283a:	4989                	li	s3,2
      t->state = TRUNNABLE;
    8000283c:	4b0d                	li	s6,3
    8000283e:	a811                	j	80002852 <exit+0x4e>
    release(&t->lock);
    80002840:	8526                	mv	a0,s1
    80002842:	ffffe097          	auipc	ra,0xffffe
    80002846:	44e080e7          	jalr	1102(ra) # 80000c90 <release>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    8000284a:	0b848493          	addi	s1,s1,184
    8000284e:	00990f63          	beq	s2,s1,8000286c <exit+0x68>
    acquire(&t->lock);
    80002852:	8526                	mv	a0,s1
    80002854:	ffffe097          	auipc	ra,0xffffe
    80002858:	372080e7          	jalr	882(ra) # 80000bc6 <acquire>
    t->killed = 1;
    8000285c:	0344a423          	sw	s4,40(s1)
    if(t->state == TSLEEPING)
    80002860:	4c9c                	lw	a5,24(s1)
    80002862:	fd379fe3          	bne	a5,s3,80002840 <exit+0x3c>
      t->state = TRUNNABLE;
    80002866:	0164ac23          	sw	s6,24(s1)
    8000286a:	bfd9                	j	80002840 <exit+0x3c>
  kthread_exit(status);
    8000286c:	8556                	mv	a0,s5
    8000286e:	00000097          	auipc	ra,0x0
    80002872:	f02080e7          	jalr	-254(ra) # 80002770 <kthread_exit>

0000000080002876 <sig_stop>:
//   return -1;
// }

int
sig_stop(int pid)//TODO delete if not used
{
    80002876:	7179                	addi	sp,sp,-48
    80002878:	f406                	sd	ra,40(sp)
    8000287a:	f022                	sd	s0,32(sp)
    8000287c:	ec26                	sd	s1,24(sp)
    8000287e:	e84a                	sd	s2,16(sp)
    80002880:	e44e                	sd	s3,8(sp)
    80002882:	e052                	sd	s4,0(sp)
    80002884:	1800                	addi	s0,sp,48
    80002886:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002888:	00010497          	auipc	s1,0x10
    8000288c:	ea048493          	addi	s1,s1,-352 # 80012728 <proc>
    80002890:	6985                	lui	s3,0x1
    80002892:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002896:	00031a17          	auipc	s4,0x31
    8000289a:	092a0a13          	addi	s4,s4,146 # 80033928 <tickslock>
    acquire(&p->lock);
    8000289e:	8526                	mv	a0,s1
    800028a0:	ffffe097          	auipc	ra,0xffffe
    800028a4:	326080e7          	jalr	806(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    800028a8:	50dc                	lw	a5,36(s1)
    800028aa:	01278c63          	beq	a5,s2,800028c2 <sig_stop+0x4c>
      p->pending_signals|=(1<<SIGSTOP);

      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800028ae:	8526                	mv	a0,s1
    800028b0:	ffffe097          	auipc	ra,0xffffe
    800028b4:	3e0080e7          	jalr	992(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800028b8:	94ce                	add	s1,s1,s3
    800028ba:	ff4492e3          	bne	s1,s4,8000289e <sig_stop+0x28>
  }
  return -1;
    800028be:	557d                	li	a0,-1
    800028c0:	a831                	j	800028dc <sig_stop+0x66>
      p->pending_signals|=(1<<SIGSTOP);
    800028c2:	0e84a783          	lw	a5,232(s1)
    800028c6:	00020737          	lui	a4,0x20
    800028ca:	8fd9                	or	a5,a5,a4
    800028cc:	0ef4a423          	sw	a5,232(s1)
      release(&p->lock);
    800028d0:	8526                	mv	a0,s1
    800028d2:	ffffe097          	auipc	ra,0xffffe
    800028d6:	3be080e7          	jalr	958(ra) # 80000c90 <release>
      return 0;
    800028da:	4501                	li	a0,0
}
    800028dc:	70a2                	ld	ra,40(sp)
    800028de:	7402                	ld	s0,32(sp)
    800028e0:	64e2                	ld	s1,24(sp)
    800028e2:	6942                	ld	s2,16(sp)
    800028e4:	69a2                	ld	s3,8(sp)
    800028e6:	6a02                	ld	s4,0(sp)
    800028e8:	6145                	addi	sp,sp,48
    800028ea:	8082                	ret

00000000800028ec <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800028ec:	7179                	addi	sp,sp,-48
    800028ee:	f406                	sd	ra,40(sp)
    800028f0:	f022                	sd	s0,32(sp)
    800028f2:	ec26                	sd	s1,24(sp)
    800028f4:	e84a                	sd	s2,16(sp)
    800028f6:	e44e                	sd	s3,8(sp)
    800028f8:	e052                	sd	s4,0(sp)
    800028fa:	1800                	addi	s0,sp,48
    800028fc:	84aa                	mv	s1,a0
    800028fe:	892e                	mv	s2,a1
    80002900:	89b2                	mv	s3,a2
    80002902:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002904:	fffff097          	auipc	ra,0xfffff
    80002908:	16c080e7          	jalr	364(ra) # 80001a70 <myproc>
  if(user_dst){
    8000290c:	c08d                	beqz	s1,8000292e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000290e:	86d2                	mv	a3,s4
    80002910:	864e                	mv	a2,s3
    80002912:	85ca                	mv	a1,s2
    80002914:	6128                	ld	a0,64(a0)
    80002916:	fffff097          	auipc	ra,0xfffff
    8000291a:	d42080e7          	jalr	-702(ra) # 80001658 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000291e:	70a2                	ld	ra,40(sp)
    80002920:	7402                	ld	s0,32(sp)
    80002922:	64e2                	ld	s1,24(sp)
    80002924:	6942                	ld	s2,16(sp)
    80002926:	69a2                	ld	s3,8(sp)
    80002928:	6a02                	ld	s4,0(sp)
    8000292a:	6145                	addi	sp,sp,48
    8000292c:	8082                	ret
    memmove((char *)dst, src, len);
    8000292e:	000a061b          	sext.w	a2,s4
    80002932:	85ce                	mv	a1,s3
    80002934:	854a                	mv	a0,s2
    80002936:	ffffe097          	auipc	ra,0xffffe
    8000293a:	3fe080e7          	jalr	1022(ra) # 80000d34 <memmove>
    return 0;
    8000293e:	8526                	mv	a0,s1
    80002940:	bff9                	j	8000291e <either_copyout+0x32>

0000000080002942 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002942:	7179                	addi	sp,sp,-48
    80002944:	f406                	sd	ra,40(sp)
    80002946:	f022                	sd	s0,32(sp)
    80002948:	ec26                	sd	s1,24(sp)
    8000294a:	e84a                	sd	s2,16(sp)
    8000294c:	e44e                	sd	s3,8(sp)
    8000294e:	e052                	sd	s4,0(sp)
    80002950:	1800                	addi	s0,sp,48
    80002952:	892a                	mv	s2,a0
    80002954:	84ae                	mv	s1,a1
    80002956:	89b2                	mv	s3,a2
    80002958:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000295a:	fffff097          	auipc	ra,0xfffff
    8000295e:	116080e7          	jalr	278(ra) # 80001a70 <myproc>
  if(user_src){
    80002962:	c08d                	beqz	s1,80002984 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002964:	86d2                	mv	a3,s4
    80002966:	864e                	mv	a2,s3
    80002968:	85ca                	mv	a1,s2
    8000296a:	6128                	ld	a0,64(a0)
    8000296c:	fffff097          	auipc	ra,0xfffff
    80002970:	d78080e7          	jalr	-648(ra) # 800016e4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002974:	70a2                	ld	ra,40(sp)
    80002976:	7402                	ld	s0,32(sp)
    80002978:	64e2                	ld	s1,24(sp)
    8000297a:	6942                	ld	s2,16(sp)
    8000297c:	69a2                	ld	s3,8(sp)
    8000297e:	6a02                	ld	s4,0(sp)
    80002980:	6145                	addi	sp,sp,48
    80002982:	8082                	ret
    memmove(dst, (char*)src, len);
    80002984:	000a061b          	sext.w	a2,s4
    80002988:	85ce                	mv	a1,s3
    8000298a:	854a                	mv	a0,s2
    8000298c:	ffffe097          	auipc	ra,0xffffe
    80002990:	3a8080e7          	jalr	936(ra) # 80000d34 <memmove>
    return 0;
    80002994:	8526                	mv	a0,s1
    80002996:	bff9                	j	80002974 <either_copyin+0x32>

0000000080002998 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002998:	715d                	addi	sp,sp,-80
    8000299a:	e486                	sd	ra,72(sp)
    8000299c:	e0a2                	sd	s0,64(sp)
    8000299e:	fc26                	sd	s1,56(sp)
    800029a0:	f84a                	sd	s2,48(sp)
    800029a2:	f44e                	sd	s3,40(sp)
    800029a4:	f052                	sd	s4,32(sp)
    800029a6:	ec56                	sd	s5,24(sp)
    800029a8:	e85a                	sd	s6,16(sp)
    800029aa:	e45e                	sd	s7,8(sp)
    800029ac:	e062                	sd	s8,0(sp)
    800029ae:	0880                	addi	s0,sp,80


  struct proc *p;
  char *state;

  printf("\n");
    800029b0:	00007517          	auipc	a0,0x7
    800029b4:	8b850513          	addi	a0,a0,-1864 # 80009268 <digits+0x228>
    800029b8:	ffffe097          	auipc	ra,0xffffe
    800029bc:	bc0080e7          	jalr	-1088(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800029c0:	00010497          	auipc	s1,0x10
    800029c4:	e4048493          	addi	s1,s1,-448 # 80012800 <proc+0xd8>
    800029c8:	00031997          	auipc	s3,0x31
    800029cc:	03898993          	addi	s3,s3,56 # 80033a00 <bcache+0xc0>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029d0:	4b8d                	li	s7,3
      state = states[p->state];
    else
      state = "???";
    800029d2:	00007a17          	auipc	s4,0x7
    800029d6:	936a0a13          	addi	s4,s4,-1738 # 80009308 <digits+0x2c8>
    printf("%d %s %s", p->pid, state, p->name);
    800029da:	00007b17          	auipc	s6,0x7
    800029de:	936b0b13          	addi	s6,s6,-1738 # 80009310 <digits+0x2d0>
    printf("\n");
    800029e2:	00007a97          	auipc	s5,0x7
    800029e6:	886a8a93          	addi	s5,s5,-1914 # 80009268 <digits+0x228>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029ea:	00007c17          	auipc	s8,0x7
    800029ee:	b26c0c13          	addi	s8,s8,-1242 # 80009510 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    800029f2:	6905                	lui	s2,0x1
    800029f4:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    800029f8:	a005                	j	80002a18 <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    800029fa:	f4c6a583          	lw	a1,-180(a3)
    800029fe:	855a                	mv	a0,s6
    80002a00:	ffffe097          	auipc	ra,0xffffe
    80002a04:	b78080e7          	jalr	-1160(ra) # 80000578 <printf>
    printf("\n");
    80002a08:	8556                	mv	a0,s5
    80002a0a:	ffffe097          	auipc	ra,0xffffe
    80002a0e:	b6e080e7          	jalr	-1170(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a12:	94ca                	add	s1,s1,s2
    80002a14:	03348263          	beq	s1,s3,80002a38 <procdump+0xa0>
    if(p->state == UNUSED)
    80002a18:	86a6                	mv	a3,s1
    80002a1a:	f404a783          	lw	a5,-192(s1)
    80002a1e:	dbf5                	beqz	a5,80002a12 <procdump+0x7a>
      state = "???";
    80002a20:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a22:	fcfbece3          	bltu	s7,a5,800029fa <procdump+0x62>
    80002a26:	02079713          	slli	a4,a5,0x20
    80002a2a:	01d75793          	srli	a5,a4,0x1d
    80002a2e:	97e2                	add	a5,a5,s8
    80002a30:	6390                	ld	a2,0(a5)
    80002a32:	f661                	bnez	a2,800029fa <procdump+0x62>
      state = "???";
    80002a34:	8652                	mv	a2,s4
    80002a36:	b7d1                	j	800029fa <procdump+0x62>
  }
}
    80002a38:	60a6                	ld	ra,72(sp)
    80002a3a:	6406                	ld	s0,64(sp)
    80002a3c:	74e2                	ld	s1,56(sp)
    80002a3e:	7942                	ld	s2,48(sp)
    80002a40:	79a2                	ld	s3,40(sp)
    80002a42:	7a02                	ld	s4,32(sp)
    80002a44:	6ae2                	ld	s5,24(sp)
    80002a46:	6b42                	ld	s6,16(sp)
    80002a48:	6ba2                	ld	s7,8(sp)
    80002a4a:	6c02                	ld	s8,0(sp)
    80002a4c:	6161                	addi	sp,sp,80
    80002a4e:	8082                	ret

0000000080002a50 <is_valid_sigmask>:

int 
is_valid_sigmask(int sigmask){
    80002a50:	1141                	addi	sp,sp,-16
    80002a52:	e422                	sd	s0,8(sp)
    80002a54:	0800                	addi	s0,sp,16
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002a56:	000207b7          	lui	a5,0x20
    80002a5a:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002a5e:	8d7d                	and	a0,a0,a5
    return 0;
  return 1;
}
    80002a60:	00153513          	seqz	a0,a0
    80002a64:	6422                	ld	s0,8(sp)
    80002a66:	0141                	addi	sp,sp,16
    80002a68:	8082                	ret

0000000080002a6a <sigprocmask>:

uint
sigprocmask(uint new_procmask){
    80002a6a:	7179                	addi	sp,sp,-48
    80002a6c:	f406                	sd	ra,40(sp)
    80002a6e:	f022                	sd	s0,32(sp)
    80002a70:	ec26                	sd	s1,24(sp)
    80002a72:	e84a                	sd	s2,16(sp)
    80002a74:	e44e                	sd	s3,8(sp)
    80002a76:	1800                	addi	s0,sp,48
    80002a78:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002a7a:	fffff097          	auipc	ra,0xfffff
    80002a7e:	ff6080e7          	jalr	-10(ra) # 80001a70 <myproc>
  if(is_valid_sigmask(new_procmask) == 0)
    80002a82:	000207b7          	lui	a5,0x20
    80002a86:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002a8a:	00f977b3          	and	a5,s2,a5
    return -1;
    80002a8e:	59fd                	li	s3,-1
  if(is_valid_sigmask(new_procmask) == 0)
    80002a90:	ef99                	bnez	a5,80002aae <sigprocmask+0x44>
    80002a92:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002a94:	ffffe097          	auipc	ra,0xffffe
    80002a98:	132080e7          	jalr	306(ra) # 80000bc6 <acquire>
  int old_procmask = p->signal_mask;
    80002a9c:	0ec4a983          	lw	s3,236(s1)
  p->signal_mask = new_procmask;
    80002aa0:	0f24a623          	sw	s2,236(s1)
  release(&p->lock);
    80002aa4:	8526                	mv	a0,s1
    80002aa6:	ffffe097          	auipc	ra,0xffffe
    80002aaa:	1ea080e7          	jalr	490(ra) # 80000c90 <release>
  
  return old_procmask;
}
    80002aae:	854e                	mv	a0,s3
    80002ab0:	70a2                	ld	ra,40(sp)
    80002ab2:	7402                	ld	s0,32(sp)
    80002ab4:	64e2                	ld	s1,24(sp)
    80002ab6:	6942                	ld	s2,16(sp)
    80002ab8:	69a2                	ld	s3,8(sp)
    80002aba:	6145                	addi	sp,sp,48
    80002abc:	8082                	ret

0000000080002abe <sigaction>:

 
int 
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
  
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002abe:	0005079b          	sext.w	a5,a0
    80002ac2:	477d                	li	a4,31
    80002ac4:	0cf76a63          	bltu	a4,a5,80002b98 <sigaction+0xda>
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
    80002ac8:	7139                	addi	sp,sp,-64
    80002aca:	fc06                	sd	ra,56(sp)
    80002acc:	f822                	sd	s0,48(sp)
    80002ace:	f426                	sd	s1,40(sp)
    80002ad0:	f04a                	sd	s2,32(sp)
    80002ad2:	ec4e                	sd	s3,24(sp)
    80002ad4:	e852                	sd	s4,16(sp)
    80002ad6:	0080                	addi	s0,sp,64
    80002ad8:	84aa                	mv	s1,a0
    80002ada:	89ae                	mv	s3,a1
    80002adc:	8a32                	mv	s4,a2
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002ade:	37dd                	addiw	a5,a5,-9
    80002ae0:	9bdd                	andi	a5,a5,-9
    80002ae2:	2781                	sext.w	a5,a5
    80002ae4:	cfc5                	beqz	a5,80002b9c <sigaction+0xde>
    80002ae6:	cdcd                	beqz	a1,80002ba0 <sigaction+0xe2>
    return -1;
  struct proc *p = myproc();
    80002ae8:	fffff097          	auipc	ra,0xfffff
    80002aec:	f88080e7          	jalr	-120(ra) # 80001a70 <myproc>
    80002af0:	892a                	mv	s2,a0

  uint new_mask;
  copyin(p->pagetable, (char *)&new_mask, (uint64)&act->sigmask, sizeof(act->sigmask));
    80002af2:	4691                	li	a3,4
    80002af4:	00898613          	addi	a2,s3,8
    80002af8:	fcc40593          	addi	a1,s0,-52
    80002afc:	6128                	ld	a0,64(a0)
    80002afe:	fffff097          	auipc	ra,0xfffff
    80002b02:	be6080e7          	jalr	-1050(ra) # 800016e4 <copyin>
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002b06:	fcc42703          	lw	a4,-52(s0)

  if(is_valid_sigmask(new_mask) == 0)
    80002b0a:	000207b7          	lui	a5,0x20
    80002b0e:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002b12:	8ff9                	and	a5,a5,a4
    80002b14:	ebc1                	bnez	a5,80002ba4 <sigaction+0xe6>
    return -1;
  acquire(&p->lock);
    80002b16:	854a                	mv	a0,s2
    80002b18:	ffffe097          	auipc	ra,0xffffe
    80002b1c:	0ae080e7          	jalr	174(ra) # 80000bc6 <acquire>

  if(oldact!=0){
    80002b20:	020a0b63          	beqz	s4,80002b56 <sigaction+0x98>
    copyout(p->pagetable, (uint64)&oldact->sa_handler, (char *)&p->signal_handlers[signum], sizeof(act->sa_handler));
    80002b24:	01f48613          	addi	a2,s1,31
    80002b28:	060e                	slli	a2,a2,0x3
    80002b2a:	46a1                	li	a3,8
    80002b2c:	964a                	add	a2,a2,s2
    80002b2e:	85d2                	mv	a1,s4
    80002b30:	04093503          	ld	a0,64(s2)
    80002b34:	fffff097          	auipc	ra,0xfffff
    80002b38:	b24080e7          	jalr	-1244(ra) # 80001658 <copyout>
    copyout(p->pagetable, (uint64)&oldact->sigmask, (char *)&p->handlers_sigmasks[signum], sizeof(uint));
    80002b3c:	07e48613          	addi	a2,s1,126
    80002b40:	060a                	slli	a2,a2,0x2
    80002b42:	4691                	li	a3,4
    80002b44:	964a                	add	a2,a2,s2
    80002b46:	008a0593          	addi	a1,s4,8
    80002b4a:	04093503          	ld	a0,64(s2)
    80002b4e:	fffff097          	auipc	ra,0xfffff
    80002b52:	b0a080e7          	jalr	-1270(ra) # 80001658 <copyout>
  }

  p->handlers_sigmasks[signum]=new_mask;
    80002b56:	07c48793          	addi	a5,s1,124
    80002b5a:	078a                	slli	a5,a5,0x2
    80002b5c:	97ca                	add	a5,a5,s2
    80002b5e:	fcc42703          	lw	a4,-52(s0)
    80002b62:	c798                	sw	a4,8(a5)
  copyin(p->pagetable, (char *)&p->signal_handlers[signum], (uint64)&act->sa_handler, sizeof(act->sa_handler));
    80002b64:	04fd                	addi	s1,s1,31
    80002b66:	048e                	slli	s1,s1,0x3
    80002b68:	46a1                	li	a3,8
    80002b6a:	864e                	mv	a2,s3
    80002b6c:	009905b3          	add	a1,s2,s1
    80002b70:	04093503          	ld	a0,64(s2)
    80002b74:	fffff097          	auipc	ra,0xfffff
    80002b78:	b70080e7          	jalr	-1168(ra) # 800016e4 <copyin>

  release(&p->lock);
    80002b7c:	854a                	mv	a0,s2
    80002b7e:	ffffe097          	auipc	ra,0xffffe
    80002b82:	112080e7          	jalr	274(ra) # 80000c90 <release>



  return 0;
    80002b86:	4501                	li	a0,0
}
    80002b88:	70e2                	ld	ra,56(sp)
    80002b8a:	7442                	ld	s0,48(sp)
    80002b8c:	74a2                	ld	s1,40(sp)
    80002b8e:	7902                	ld	s2,32(sp)
    80002b90:	69e2                	ld	s3,24(sp)
    80002b92:	6a42                	ld	s4,16(sp)
    80002b94:	6121                	addi	sp,sp,64
    80002b96:	8082                	ret
    return -1;
    80002b98:	557d                	li	a0,-1
}
    80002b9a:	8082                	ret
    return -1;
    80002b9c:	557d                	li	a0,-1
    80002b9e:	b7ed                	j	80002b88 <sigaction+0xca>
    80002ba0:	557d                	li	a0,-1
    80002ba2:	b7dd                	j	80002b88 <sigaction+0xca>
    return -1;
    80002ba4:	557d                	li	a0,-1
    80002ba6:	b7cd                	j	80002b88 <sigaction+0xca>

0000000080002ba8 <sigret>:

void 
sigret(void){
    80002ba8:	1101                	addi	sp,sp,-32
    80002baa:	ec06                	sd	ra,24(sp)
    80002bac:	e822                	sd	s0,16(sp)
    80002bae:	e426                	sd	s1,8(sp)
    80002bb0:	e04a                	sd	s2,0(sp)
    80002bb2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002bb4:	fffff097          	auipc	ra,0xfffff
    80002bb8:	ebc080e7          	jalr	-324(ra) # 80001a70 <myproc>
    80002bbc:	84aa                	mv	s1,a0
  struct kthread *t=mykthread();
    80002bbe:	fffff097          	auipc	ra,0xfffff
    80002bc2:	ef2080e7          	jalr	-270(ra) # 80001ab0 <mykthread>
    80002bc6:	892a                	mv	s2,a0

  copyin(p->pagetable, (char *)t->trapframe, (uint64)p->user_trapframe_backup, sizeof(struct trapframe));
    80002bc8:	12000693          	li	a3,288
    80002bcc:	2784b603          	ld	a2,632(s1)
    80002bd0:	612c                	ld	a1,64(a0)
    80002bd2:	60a8                	ld	a0,64(s1)
    80002bd4:	fffff097          	auipc	ra,0xfffff
    80002bd8:	b10080e7          	jalr	-1264(ra) # 800016e4 <copyin>

  // restore user stack pointer
  acquire(&p->lock);
    80002bdc:	8526                	mv	a0,s1
    80002bde:	ffffe097          	auipc	ra,0xffffe
    80002be2:	fe8080e7          	jalr	-24(ra) # 80000bc6 <acquire>
  // TODO maybe we will need to also lock the kthread lock
  t->trapframe->sp += sizeof(struct trapframe);
    80002be6:	04093703          	ld	a4,64(s2)
    80002bea:	7b1c                	ld	a5,48(a4)
    80002bec:	12078793          	addi	a5,a5,288
    80002bf0:	fb1c                	sd	a5,48(a4)

  p->signal_mask = p->signal_mask_backup;
    80002bf2:	0f04a783          	lw	a5,240(s1)
    80002bf6:	0ef4a623          	sw	a5,236(s1)
  
  // Allow user signal handler since we finished handling the current
  p->handling_user_sig_flag = 0;
    80002bfa:	2804a023          	sw	zero,640(s1)
  // Allow other thread to react to signals
  p->handling_sig_flag = 0;
    80002bfe:	2804a223          	sw	zero,644(s1)
  release(&p->lock);
    80002c02:	8526                	mv	a0,s1
    80002c04:	ffffe097          	auipc	ra,0xffffe
    80002c08:	08c080e7          	jalr	140(ra) # 80000c90 <release>
}
    80002c0c:	60e2                	ld	ra,24(sp)
    80002c0e:	6442                	ld	s0,16(sp)
    80002c10:	64a2                	ld	s1,8(sp)
    80002c12:	6902                	ld	s2,0(sp)
    80002c14:	6105                	addi	sp,sp,32
    80002c16:	8082                	ret

0000000080002c18 <turn_on_bit>:

// we call turn on and turn off when holding p->lock
void
turn_on_bit(struct proc* p, int signum){
    80002c18:	1141                	addi	sp,sp,-16
    80002c1a:	e422                	sd	s0,8(sp)
    80002c1c:	0800                	addi	s0,sp,16
  if(!(p->pending_signals & (1 << signum)))
    80002c1e:	0e852703          	lw	a4,232(a0)
    80002c22:	4785                	li	a5,1
    80002c24:	00b795bb          	sllw	a1,a5,a1
    80002c28:	00b777b3          	and	a5,a4,a1
    80002c2c:	2781                	sext.w	a5,a5
    80002c2e:	e781                	bnez	a5,80002c36 <turn_on_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    80002c30:	8db9                	xor	a1,a1,a4
    80002c32:	0eb52423          	sw	a1,232(a0)
}
    80002c36:	6422                	ld	s0,8(sp)
    80002c38:	0141                	addi	sp,sp,16
    80002c3a:	8082                	ret

0000000080002c3c <kill>:
{
    80002c3c:	7139                	addi	sp,sp,-64
    80002c3e:	fc06                	sd	ra,56(sp)
    80002c40:	f822                	sd	s0,48(sp)
    80002c42:	f426                	sd	s1,40(sp)
    80002c44:	f04a                	sd	s2,32(sp)
    80002c46:	ec4e                	sd	s3,24(sp)
    80002c48:	e852                	sd	s4,16(sp)
    80002c4a:	e456                	sd	s5,8(sp)
    80002c4c:	0080                	addi	s0,sp,64
    80002c4e:	892a                	mv	s2,a0
    80002c50:	8aae                	mv	s5,a1
  for(p = proc; p < &proc[NPROC]; p++){
    80002c52:	00010497          	auipc	s1,0x10
    80002c56:	ad648493          	addi	s1,s1,-1322 # 80012728 <proc>
    80002c5a:	6985                	lui	s3,0x1
    80002c5c:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002c60:	00031a17          	auipc	s4,0x31
    80002c64:	cc8a0a13          	addi	s4,s4,-824 # 80033928 <tickslock>
    acquire(&p->lock);
    80002c68:	8526                	mv	a0,s1
    80002c6a:	ffffe097          	auipc	ra,0xffffe
    80002c6e:	f5c080e7          	jalr	-164(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    80002c72:	50dc                	lw	a5,36(s1)
    80002c74:	01278c63          	beq	a5,s2,80002c8c <kill+0x50>
    release(&p->lock);
    80002c78:	8526                	mv	a0,s1
    80002c7a:	ffffe097          	auipc	ra,0xffffe
    80002c7e:	016080e7          	jalr	22(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002c82:	94ce                	add	s1,s1,s3
    80002c84:	ff4492e3          	bne	s1,s4,80002c68 <kill+0x2c>
  return -1;
    80002c88:	557d                	li	a0,-1
    80002c8a:	a851                	j	80002d1e <kill+0xe2>
      if(p->state != RUNNABLE){
    80002c8c:	4c98                	lw	a4,24(s1)
    80002c8e:	4789                	li	a5,2
    80002c90:	06f71863          	bne	a4,a5,80002d00 <kill+0xc4>
      if(p->signal_handlers[signum] == (void*)SIG_IGN){
    80002c94:	01ea8793          	addi	a5,s5,30
    80002c98:	078e                	slli	a5,a5,0x3
    80002c9a:	97a6                	add	a5,a5,s1
    80002c9c:	6798                	ld	a4,8(a5)
    80002c9e:	4785                	li	a5,1
    80002ca0:	08f70863          	beq	a4,a5,80002d30 <kill+0xf4>
      turn_on_bit(p,signum);
    80002ca4:	85d6                	mv	a1,s5
    80002ca6:	8526                	mv	a0,s1
    80002ca8:	00000097          	auipc	ra,0x0
    80002cac:	f70080e7          	jalr	-144(ra) # 80002c18 <turn_on_bit>
      release(&p->lock);
    80002cb0:	8526                	mv	a0,s1
    80002cb2:	ffffe097          	auipc	ra,0xffffe
    80002cb6:	fde080e7          	jalr	-34(ra) # 80000c90 <release>
      if(signum == SIGKILL){
    80002cba:	47a5                	li	a5,9
      return 0;
    80002cbc:	4501                	li	a0,0
      if(signum == SIGKILL){
    80002cbe:	06fa9063          	bne	s5,a5,80002d1e <kill+0xe2>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002cc2:	28848913          	addi	s2,s1,648
    80002cc6:	6785                	lui	a5,0x1
    80002cc8:	84878793          	addi	a5,a5,-1976 # 848 <_entry-0x7ffff7b8>
    80002ccc:	94be                	add	s1,s1,a5
          if(t->state == RUNNABLE){
    80002cce:	4989                	li	s3,2
    80002cd0:	01892783          	lw	a5,24(s2)
    80002cd4:	07378c63          	beq	a5,s3,80002d4c <kill+0x110>
            acquire(&t->lock);
    80002cd8:	854a                	mv	a0,s2
    80002cda:	ffffe097          	auipc	ra,0xffffe
    80002cde:	eec080e7          	jalr	-276(ra) # 80000bc6 <acquire>
            if(t->state==TSLEEPING){
    80002ce2:	01892783          	lw	a5,24(s2)
    80002ce6:	05378c63          	beq	a5,s3,80002d3e <kill+0x102>
            release(&t->lock);
    80002cea:	854a                	mv	a0,s2
    80002cec:	ffffe097          	auipc	ra,0xffffe
    80002cf0:	fa4080e7          	jalr	-92(ra) # 80000c90 <release>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002cf4:	0b890913          	addi	s2,s2,184
    80002cf8:	fc991ce3          	bne	s2,s1,80002cd0 <kill+0x94>
      return 0;
    80002cfc:	4501                	li	a0,0
    80002cfe:	a005                	j	80002d1e <kill+0xe2>
        release(&p->lock);
    80002d00:	8526                	mv	a0,s1
    80002d02:	ffffe097          	auipc	ra,0xffffe
    80002d06:	f8e080e7          	jalr	-114(ra) # 80000c90 <release>
        printf("proc %d was not runnable in kill()\n",p->pid);
    80002d0a:	50cc                	lw	a1,36(s1)
    80002d0c:	00006517          	auipc	a0,0x6
    80002d10:	61450513          	addi	a0,a0,1556 # 80009320 <digits+0x2e0>
    80002d14:	ffffe097          	auipc	ra,0xffffe
    80002d18:	864080e7          	jalr	-1948(ra) # 80000578 <printf>
        return -1;
    80002d1c:	557d                	li	a0,-1
}
    80002d1e:	70e2                	ld	ra,56(sp)
    80002d20:	7442                	ld	s0,48(sp)
    80002d22:	74a2                	ld	s1,40(sp)
    80002d24:	7902                	ld	s2,32(sp)
    80002d26:	69e2                	ld	s3,24(sp)
    80002d28:	6a42                	ld	s4,16(sp)
    80002d2a:	6aa2                	ld	s5,8(sp)
    80002d2c:	6121                	addi	sp,sp,64
    80002d2e:	8082                	ret
        release(&p->lock);
    80002d30:	8526                	mv	a0,s1
    80002d32:	ffffe097          	auipc	ra,0xffffe
    80002d36:	f5e080e7          	jalr	-162(ra) # 80000c90 <release>
        return 1;
    80002d3a:	4505                	li	a0,1
    80002d3c:	b7cd                	j	80002d1e <kill+0xe2>
              release(&t->lock);
    80002d3e:	854a                	mv	a0,s2
    80002d40:	ffffe097          	auipc	ra,0xffffe
    80002d44:	f50080e7          	jalr	-176(ra) # 80000c90 <release>
      return 0;
    80002d48:	4501                	li	a0,0
              break;
    80002d4a:	bfd1                	j	80002d1e <kill+0xe2>
      return 0;
    80002d4c:	4501                	li	a0,0
    80002d4e:	bfc1                	j	80002d1e <kill+0xe2>

0000000080002d50 <turn_off_bit>:

void
turn_off_bit(struct proc* p, int signum){
    80002d50:	1141                	addi	sp,sp,-16
    80002d52:	e422                	sd	s0,8(sp)
    80002d54:	0800                	addi	s0,sp,16
  if(p->pending_signals & (1 << signum))
    80002d56:	0e852703          	lw	a4,232(a0)
    80002d5a:	4785                	li	a5,1
    80002d5c:	00b795bb          	sllw	a1,a5,a1
    80002d60:	00b777b3          	and	a5,a4,a1
    80002d64:	2781                	sext.w	a5,a5
    80002d66:	c781                	beqz	a5,80002d6e <turn_off_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    80002d68:	8db9                	xor	a1,a1,a4
    80002d6a:	0eb52423          	sw	a1,232(a0)
}
    80002d6e:	6422                	ld	s0,8(sp)
    80002d70:	0141                	addi	sp,sp,16
    80002d72:	8082                	ret

0000000080002d74 <kthread_create>:

int kthread_create(void (*start_func)(), void *stack){
    80002d74:	7139                	addi	sp,sp,-64
    80002d76:	fc06                	sd	ra,56(sp)
    80002d78:	f822                	sd	s0,48(sp)
    80002d7a:	f426                	sd	s1,40(sp)
    80002d7c:	f04a                	sd	s2,32(sp)
    80002d7e:	ec4e                	sd	s3,24(sp)
    80002d80:	e852                	sd	s4,16(sp)
    80002d82:	e456                	sd	s5,8(sp)
    80002d84:	e05a                	sd	s6,0(sp)
    80002d86:	0080                	addi	s0,sp,64
    80002d88:	8aaa                	mv	s5,a0
    80002d8a:	8b2e                	mv	s6,a1
  struct proc *p = myproc();
    80002d8c:	fffff097          	auipc	ra,0xfffff
    80002d90:	ce4080e7          	jalr	-796(ra) # 80001a70 <myproc>
    80002d94:	8a2a                	mv	s4,a0
  struct kthread *curr_t = mykthread();
    80002d96:	fffff097          	auipc	ra,0xfffff
    80002d9a:	d1a080e7          	jalr	-742(ra) # 80001ab0 <mykthread>
    80002d9e:	89aa                	mv	s3,a0
  struct kthread *other_t;

  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    80002da0:	288a0493          	addi	s1,s4,648
    80002da4:	6905                	lui	s2,0x1
    80002da6:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002daa:	9952                	add	s2,s2,s4
    80002dac:	a855                	j	80002e60 <kthread_create+0xec>
  t->tid = 0;
    80002dae:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80002db2:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80002db6:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80002dba:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80002dbe:	0004ac23          	sw	zero,24(s1)
      acquire(&other_t->lock);
      // printf("locked thread %d in kcreate\n",thread_ind);
      if(other_t->state == TUNUSED){
          freethread(other_t);  // free memory in case this thread entry was previously used
          // printf("freed thread %d in kcreate\n",thread_ind);
          init_thread(other_t);
    80002dc2:	8526                	mv	a0,s1
    80002dc4:	fffff097          	auipc	ra,0xfffff
    80002dc8:	e32080e7          	jalr	-462(ra) # 80001bf6 <init_thread>
          // printf("after init thread %d in kcreate\n",thread_ind);
          printf("in kthreadcreate startFunc add = %p\n",start_func);
    80002dcc:	85d6                	mv	a1,s5
    80002dce:	00006517          	auipc	a0,0x6
    80002dd2:	57a50513          	addi	a0,a0,1402 # 80009348 <digits+0x308>
    80002dd6:	ffffd097          	auipc	ra,0xffffd
    80002dda:	7a2080e7          	jalr	1954(ra) # 80000578 <printf>
          // uint64 sp,func;
          // copyin(p->pagetable, (char *)&func, (uint64)&start_func, sizeof(uint64));
          // copyin(p->pagetable, (char *)&sp, (uint64)&stack, sizeof(uint64));

          *(other_t->trapframe) = *(curr_t->trapframe);
    80002dde:	0409b683          	ld	a3,64(s3)
    80002de2:	87b6                	mv	a5,a3
    80002de4:	60b8                	ld	a4,64(s1)
    80002de6:	12068693          	addi	a3,a3,288
    80002dea:	0007b803          	ld	a6,0(a5)
    80002dee:	6788                	ld	a0,8(a5)
    80002df0:	6b8c                	ld	a1,16(a5)
    80002df2:	6f90                	ld	a2,24(a5)
    80002df4:	01073023          	sd	a6,0(a4) # 20000 <_entry-0x7ffe0000>
    80002df8:	e708                	sd	a0,8(a4)
    80002dfa:	eb0c                	sd	a1,16(a4)
    80002dfc:	ef10                	sd	a2,24(a4)
    80002dfe:	02078793          	addi	a5,a5,32
    80002e02:	02070713          	addi	a4,a4,32
    80002e06:	fed792e3          	bne	a5,a3,80002dea <kthread_create+0x76>
          other_t->trapframe->sp = (uint64)stack;
    80002e0a:	60bc                	ld	a5,64(s1)
    80002e0c:	0367b823          	sd	s6,48(a5)
          other_t->trapframe->epc = (uint64)start_func;
    80002e10:	60bc                	ld	a5,64(s1)
    80002e12:	0157bc23          	sd	s5,24(a5)
          release(&other_t->lock);
    80002e16:	8526                	mv	a0,s1
    80002e18:	ffffe097          	auipc	ra,0xffffe
    80002e1c:	e78080e7          	jalr	-392(ra) # 80000c90 <release>
          // printf("trying to lock p in kcreate\n");
          acquire(&p->lock);
    80002e20:	8552                	mv	a0,s4
    80002e22:	ffffe097          	auipc	ra,0xffffe
    80002e26:	da4080e7          	jalr	-604(ra) # 80000bc6 <acquire>
          p->active_threads++;
    80002e2a:	028a2783          	lw	a5,40(s4)
    80002e2e:	2785                	addiw	a5,a5,1
    80002e30:	02fa2423          	sw	a5,40(s4)
          release(&p->lock);
    80002e34:	8552                	mv	a0,s4
    80002e36:	ffffe097          	auipc	ra,0xffffe
    80002e3a:	e5a080e7          	jalr	-422(ra) # 80000c90 <release>
          other_t->state = TRUNNABLE;
    80002e3e:	478d                	li	a5,3
    80002e40:	cc9c                	sw	a5,24(s1)
          printf("making t runable and break tid=%d\n",other_t->tid);
    80002e42:	588c                	lw	a1,48(s1)
    80002e44:	00006517          	auipc	a0,0x6
    80002e48:	52c50513          	addi	a0,a0,1324 # 80009370 <digits+0x330>
    80002e4c:	ffffd097          	auipc	ra,0xffffd
    80002e50:	72c080e7          	jalr	1836(ra) # 80000578 <printf>
          return other_t->tid;
    80002e54:	5888                	lw	a0,48(s1)
    80002e56:	a02d                	j	80002e80 <kthread_create+0x10c>
  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    80002e58:	0b848493          	addi	s1,s1,184
    80002e5c:	02990163          	beq	s2,s1,80002e7e <kthread_create+0x10a>
    if(curr_t != other_t){
    80002e60:	fe998ce3          	beq	s3,s1,80002e58 <kthread_create+0xe4>
      acquire(&other_t->lock);
    80002e64:	8526                	mv	a0,s1
    80002e66:	ffffe097          	auipc	ra,0xffffe
    80002e6a:	d60080e7          	jalr	-672(ra) # 80000bc6 <acquire>
      if(other_t->state == TUNUSED){
    80002e6e:	4c9c                	lw	a5,24(s1)
    80002e70:	df9d                	beqz	a5,80002dae <kthread_create+0x3a>
      }
      release(&other_t->lock);
    80002e72:	8526                	mv	a0,s1
    80002e74:	ffffe097          	auipc	ra,0xffffe
    80002e78:	e1c080e7          	jalr	-484(ra) # 80000c90 <release>
    80002e7c:	bff1                	j	80002e58 <kthread_create+0xe4>
    }
  }
  return -1;
    80002e7e:	557d                	li	a0,-1
}
    80002e80:	70e2                	ld	ra,56(sp)
    80002e82:	7442                	ld	s0,48(sp)
    80002e84:	74a2                	ld	s1,40(sp)
    80002e86:	7902                	ld	s2,32(sp)
    80002e88:	69e2                	ld	s3,24(sp)
    80002e8a:	6a42                	ld	s4,16(sp)
    80002e8c:	6aa2                	ld	s5,8(sp)
    80002e8e:	6b02                	ld	s6,0(sp)
    80002e90:	6121                	addi	sp,sp,64
    80002e92:	8082                	ret

0000000080002e94 <kthread_join>:



int
kthread_join(int thread_id, int* status){
    80002e94:	711d                	addi	sp,sp,-96
    80002e96:	ec86                	sd	ra,88(sp)
    80002e98:	e8a2                	sd	s0,80(sp)
    80002e9a:	e4a6                	sd	s1,72(sp)
    80002e9c:	e0ca                	sd	s2,64(sp)
    80002e9e:	fc4e                	sd	s3,56(sp)
    80002ea0:	f852                	sd	s4,48(sp)
    80002ea2:	f456                	sd	s5,40(sp)
    80002ea4:	f05a                	sd	s6,32(sp)
    80002ea6:	ec5e                	sd	s7,24(sp)
    80002ea8:	e862                	sd	s8,16(sp)
    80002eaa:	e466                	sd	s9,8(sp)
    80002eac:	1080                	addi	s0,sp,96
    80002eae:	8a2a                	mv	s4,a0
    80002eb0:	8c2e                	mv	s8,a1
  struct kthread *nt;
  struct proc *p = myproc();
    80002eb2:	fffff097          	auipc	ra,0xfffff
    80002eb6:	bbe080e7          	jalr	-1090(ra) # 80001a70 <myproc>
    80002eba:	8baa                	mv	s7,a0
  struct kthread *t = mykthread();
    80002ebc:	fffff097          	auipc	ra,0xfffff
    80002ec0:	bf4080e7          	jalr	-1036(ra) # 80001ab0 <mykthread>

  if(thread_id == t->tid)
    80002ec4:	590c                	lw	a1,48(a0)
    80002ec6:	25458663          	beq	a1,s4,80003112 <kthread_join+0x27e>
    80002eca:	89aa                	mv	s3,a0
    return -1;
  printf("%d: lock wait\n",t->tid);
    80002ecc:	00006517          	auipc	a0,0x6
    80002ed0:	4cc50513          	addi	a0,a0,1228 # 80009398 <digits+0x358>
    80002ed4:	ffffd097          	auipc	ra,0xffffd
    80002ed8:	6a4080e7          	jalr	1700(ra) # 80000578 <printf>
  acquire(&wait_lock);
    80002edc:	0000f517          	auipc	a0,0xf
    80002ee0:	3f450513          	addi	a0,a0,1012 # 800122d0 <wait_lock>
    80002ee4:	ffffe097          	auipc	ra,0xffffe
    80002ee8:	ce2080e7          	jalr	-798(ra) # 80000bc6 <acquire>
  // printf("acq wait lock\n");
  // Search for thread in the procces threads array
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){
    80002eec:	288b8913          	addi	s2,s7,648
    80002ef0:	6485                	lui	s1,0x1
    80002ef2:	84848493          	addi	s1,s1,-1976 # 848 <_entry-0x7ffff7b8>
    80002ef6:	94de                	add	s1,s1,s7
    printf("%d:locking thread %d\n",t->tid,nt->tid);
    80002ef8:	00006a97          	auipc	s5,0x6
    80002efc:	4b0a8a93          	addi	s5,s5,1200 # 800093a8 <digits+0x368>
    80002f00:	aa99                	j	80003056 <kthread_join+0x1c2>
    if(nt != t){
      acquire(&nt->lock);
      // printf("nt->tid %d lock acq\n",nt->tid);

      if(nt->tid == thread_id){
        printf("%d: found target\n",t->tid);
    80002f02:	0309a583          	lw	a1,48(s3)
    80002f06:	00006517          	auipc	a0,0x6
    80002f0a:	4ba50513          	addi	a0,a0,1210 # 800093c0 <digits+0x380>
    80002f0e:	ffffd097          	auipc	ra,0xffffd
    80002f12:	66a080e7          	jalr	1642(ra) # 80000578 <printf>
        //found target thread 
        break;
    80002f16:	84ca                	mv	s1,s2
      }
      release(&nt->lock);
    }
  }

  if(nt->tid != thread_id){
    80002f18:	589c                	lw	a5,48(s1)
    80002f1a:	17479863          	bne	a5,s4,8000308a <kthread_join+0x1f6>
  }
  
  // Wait for thread to terminate
  // still holding nt lock
  for(;;){
      if(nt->state==TUNUSED){
    80002f1e:	4c9c                	lw	a5,24(s1)
    80002f20:	cbad                	beqz	a5,80002f92 <kthread_join+0xfe>
        printf("27.75 trapframe->epc=%p\n",t->trapframe->epc);
        printf("27.824 t tid=%d\n",t->tid);

        return 0;
      }
    printf("28 \n");
    80002f22:	00006917          	auipc	s2,0x6
    80002f26:	5a690913          	addi	s2,s2,1446 # 800094c8 <digits+0x488>
      release(&nt->lock);
      release(&wait_lock);
      return -1;
    }
    release(&nt->lock);
    printf("29 before sleep\n");
    80002f2a:	00006c97          	auipc	s9,0x6
    80002f2e:	5a6c8c93          	addi	s9,s9,1446 # 800094d0 <digits+0x490>

    sleep(nt, &wait_lock);  //DOC: wait-sleep
    80002f32:	0000fb17          	auipc	s6,0xf
    80002f36:	39eb0b13          	addi	s6,s6,926 # 800122d0 <wait_lock>
    acquire(&nt->lock);
    printf("30 after acq\n");
    80002f3a:	00006a97          	auipc	s5,0x6
    80002f3e:	5aea8a93          	addi	s5,s5,1454 # 800094e8 <digits+0x4a8>
    printf("28 \n");
    80002f42:	854a                	mv	a0,s2
    80002f44:	ffffd097          	auipc	ra,0xffffd
    80002f48:	634080e7          	jalr	1588(ra) # 80000578 <printf>
    if(t->killed || nt->tid!=thread_id){
    80002f4c:	0289a783          	lw	a5,40(s3)
    80002f50:	18079663          	bnez	a5,800030dc <kthread_join+0x248>
    80002f54:	589c                	lw	a5,48(s1)
    80002f56:	19479363          	bne	a5,s4,800030dc <kthread_join+0x248>
    release(&nt->lock);
    80002f5a:	8526                	mv	a0,s1
    80002f5c:	ffffe097          	auipc	ra,0xffffe
    80002f60:	d34080e7          	jalr	-716(ra) # 80000c90 <release>
    printf("29 before sleep\n");
    80002f64:	8566                	mv	a0,s9
    80002f66:	ffffd097          	auipc	ra,0xffffd
    80002f6a:	612080e7          	jalr	1554(ra) # 80000578 <printf>
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    80002f6e:	85da                	mv	a1,s6
    80002f70:	8526                	mv	a0,s1
    80002f72:	fffff097          	auipc	ra,0xfffff
    80002f76:	478080e7          	jalr	1144(ra) # 800023ea <sleep>
    acquire(&nt->lock);
    80002f7a:	8526                	mv	a0,s1
    80002f7c:	ffffe097          	auipc	ra,0xffffe
    80002f80:	c4a080e7          	jalr	-950(ra) # 80000bc6 <acquire>
    printf("30 after acq\n");
    80002f84:	8556                	mv	a0,s5
    80002f86:	ffffd097          	auipc	ra,0xffffd
    80002f8a:	5f2080e7          	jalr	1522(ra) # 80000578 <printf>
      if(nt->state==TUNUSED){
    80002f8e:	4c9c                	lw	a5,24(s1)
    80002f90:	fbcd                	bnez	a5,80002f42 <kthread_join+0xae>
        printf("%d: 27 thread unused yey\n",t->tid);
    80002f92:	0309a583          	lw	a1,48(s3)
    80002f96:	00006517          	auipc	a0,0x6
    80002f9a:	45a50513          	addi	a0,a0,1114 # 800093f0 <digits+0x3b0>
    80002f9e:	ffffd097          	auipc	ra,0xffffd
    80002fa2:	5da080e7          	jalr	1498(ra) # 80000578 <printf>
        if(status != 0 && copyout(p->pagetable, status, (char *)&nt->xstate,sizeof(nt->xstate)) < 0) {
    80002fa6:	000c0e63          	beqz	s8,80002fc2 <kthread_join+0x12e>
    80002faa:	4691                	li	a3,4
    80002fac:	02c48613          	addi	a2,s1,44
    80002fb0:	85e2                	mv	a1,s8
    80002fb2:	040bb503          	ld	a0,64(s7)
    80002fb6:	ffffe097          	auipc	ra,0xffffe
    80002fba:	6a2080e7          	jalr	1698(ra) # 80001658 <copyout>
    80002fbe:	0e054863          	bltz	a0,800030ae <kthread_join+0x21a>
        printf("27 after if all good\n");
    80002fc2:	00006517          	auipc	a0,0x6
    80002fc6:	47650513          	addi	a0,a0,1142 # 80009438 <digits+0x3f8>
    80002fca:	ffffd097          	auipc	ra,0xffffd
    80002fce:	5ae080e7          	jalr	1454(ra) # 80000578 <printf>
  t->tid = 0;
    80002fd2:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80002fd6:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80002fda:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80002fde:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80002fe2:	0004ac23          	sw	zero,24(s1)
        printf("freed nt,releasing locks\n");
    80002fe6:	00006517          	auipc	a0,0x6
    80002fea:	46a50513          	addi	a0,a0,1130 # 80009450 <digits+0x410>
    80002fee:	ffffd097          	auipc	ra,0xffffd
    80002ff2:	58a080e7          	jalr	1418(ra) # 80000578 <printf>
        release(&nt->lock);
    80002ff6:	8526                	mv	a0,s1
    80002ff8:	ffffe097          	auipc	ra,0xffffe
    80002ffc:	c98080e7          	jalr	-872(ra) # 80000c90 <release>
        release(&wait_lock);  //  successfull join
    80003000:	0000f517          	auipc	a0,0xf
    80003004:	2d050513          	addi	a0,a0,720 # 800122d0 <wait_lock>
    80003008:	ffffe097          	auipc	ra,0xffffe
    8000300c:	c88080e7          	jalr	-888(ra) # 80000c90 <release>
        printf("27.5 released wait lock\n");
    80003010:	00006517          	auipc	a0,0x6
    80003014:	46050513          	addi	a0,a0,1120 # 80009470 <digits+0x430>
    80003018:	ffffd097          	auipc	ra,0xffffd
    8000301c:	560080e7          	jalr	1376(ra) # 80000578 <printf>
        printf("27.75 trapframe->epc=%p\n",t->trapframe->epc);
    80003020:	0409b783          	ld	a5,64(s3)
    80003024:	6f8c                	ld	a1,24(a5)
    80003026:	00006517          	auipc	a0,0x6
    8000302a:	46a50513          	addi	a0,a0,1130 # 80009490 <digits+0x450>
    8000302e:	ffffd097          	auipc	ra,0xffffd
    80003032:	54a080e7          	jalr	1354(ra) # 80000578 <printf>
        printf("27.824 t tid=%d\n",t->tid);
    80003036:	0309a583          	lw	a1,48(s3)
    8000303a:	00006517          	auipc	a0,0x6
    8000303e:	47650513          	addi	a0,a0,1142 # 800094b0 <digits+0x470>
    80003042:	ffffd097          	auipc	ra,0xffffd
    80003046:	536080e7          	jalr	1334(ra) # 80000578 <printf>
        return 0;
    8000304a:	4501                	li	a0,0
    8000304c:	a075                	j	800030f8 <kthread_join+0x264>
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){
    8000304e:	0b890913          	addi	s2,s2,184
    80003052:	ed2483e3          	beq	s1,s2,80002f18 <kthread_join+0x84>
    printf("%d:locking thread %d\n",t->tid,nt->tid);
    80003056:	03092603          	lw	a2,48(s2)
    8000305a:	0309a583          	lw	a1,48(s3)
    8000305e:	8556                	mv	a0,s5
    80003060:	ffffd097          	auipc	ra,0xffffd
    80003064:	518080e7          	jalr	1304(ra) # 80000578 <printf>
    if(nt != t){
    80003068:	ff2983e3          	beq	s3,s2,8000304e <kthread_join+0x1ba>
      acquire(&nt->lock);
    8000306c:	854a                	mv	a0,s2
    8000306e:	ffffe097          	auipc	ra,0xffffe
    80003072:	b58080e7          	jalr	-1192(ra) # 80000bc6 <acquire>
      if(nt->tid == thread_id){
    80003076:	03092783          	lw	a5,48(s2)
    8000307a:	e94784e3          	beq	a5,s4,80002f02 <kthread_join+0x6e>
      release(&nt->lock);
    8000307e:	854a                	mv	a0,s2
    80003080:	ffffe097          	auipc	ra,0xffffe
    80003084:	c10080e7          	jalr	-1008(ra) # 80000c90 <release>
    80003088:	b7d9                	j	8000304e <kthread_join+0x1ba>
    printf("failed to find target\n");
    8000308a:	00006517          	auipc	a0,0x6
    8000308e:	34e50513          	addi	a0,a0,846 # 800093d8 <digits+0x398>
    80003092:	ffffd097          	auipc	ra,0xffffd
    80003096:	4e6080e7          	jalr	1254(ra) # 80000578 <printf>
    release(&wait_lock);
    8000309a:	0000f517          	auipc	a0,0xf
    8000309e:	23650513          	addi	a0,a0,566 # 800122d0 <wait_lock>
    800030a2:	ffffe097          	auipc	ra,0xffffe
    800030a6:	bee080e7          	jalr	-1042(ra) # 80000c90 <release>
    return -1;
    800030aa:	557d                	li	a0,-1
    800030ac:	a0b1                	j	800030f8 <kthread_join+0x264>
          printf("problem with copyout, releasing locks\n");
    800030ae:	00006517          	auipc	a0,0x6
    800030b2:	36250513          	addi	a0,a0,866 # 80009410 <digits+0x3d0>
    800030b6:	ffffd097          	auipc	ra,0xffffd
    800030ba:	4c2080e7          	jalr	1218(ra) # 80000578 <printf>
           release(&nt->lock);
    800030be:	8526                	mv	a0,s1
    800030c0:	ffffe097          	auipc	ra,0xffffe
    800030c4:	bd0080e7          	jalr	-1072(ra) # 80000c90 <release>
           release(&wait_lock);
    800030c8:	0000f517          	auipc	a0,0xf
    800030cc:	20850513          	addi	a0,a0,520 # 800122d0 <wait_lock>
    800030d0:	ffffe097          	auipc	ra,0xffffe
    800030d4:	bc0080e7          	jalr	-1088(ra) # 80000c90 <release>
           return -1;                   
    800030d8:	557d                	li	a0,-1
    800030da:	a839                	j	800030f8 <kthread_join+0x264>
      release(&nt->lock);
    800030dc:	8526                	mv	a0,s1
    800030de:	ffffe097          	auipc	ra,0xffffe
    800030e2:	bb2080e7          	jalr	-1102(ra) # 80000c90 <release>
      release(&wait_lock);
    800030e6:	0000f517          	auipc	a0,0xf
    800030ea:	1ea50513          	addi	a0,a0,490 # 800122d0 <wait_lock>
    800030ee:	ffffe097          	auipc	ra,0xffffe
    800030f2:	ba2080e7          	jalr	-1118(ra) # 80000c90 <release>
      return -1;
    800030f6:	557d                	li	a0,-1
  }
}
    800030f8:	60e6                	ld	ra,88(sp)
    800030fa:	6446                	ld	s0,80(sp)
    800030fc:	64a6                	ld	s1,72(sp)
    800030fe:	6906                	ld	s2,64(sp)
    80003100:	79e2                	ld	s3,56(sp)
    80003102:	7a42                	ld	s4,48(sp)
    80003104:	7aa2                	ld	s5,40(sp)
    80003106:	7b02                	ld	s6,32(sp)
    80003108:	6be2                	ld	s7,24(sp)
    8000310a:	6c42                	ld	s8,16(sp)
    8000310c:	6ca2                	ld	s9,8(sp)
    8000310e:	6125                	addi	sp,sp,96
    80003110:	8082                	ret
    return -1;
    80003112:	557d                	li	a0,-1
    80003114:	b7d5                	j	800030f8 <kthread_join+0x264>

0000000080003116 <kthread_join_all>:

int
kthread_join_all(){
    80003116:	7179                	addi	sp,sp,-48
    80003118:	f406                	sd	ra,40(sp)
    8000311a:	f022                	sd	s0,32(sp)
    8000311c:	ec26                	sd	s1,24(sp)
    8000311e:	e84a                	sd	s2,16(sp)
    80003120:	e44e                	sd	s3,8(sp)
    80003122:	e052                	sd	s4,0(sp)
    80003124:	1800                	addi	s0,sp,48
  struct proc *p=myproc();
    80003126:	fffff097          	auipc	ra,0xfffff
    8000312a:	94a080e7          	jalr	-1718(ra) # 80001a70 <myproc>
    8000312e:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    80003130:	fffff097          	auipc	ra,0xfffff
    80003134:	980080e7          	jalr	-1664(ra) # 80001ab0 <mykthread>
    80003138:	8a2a                	mv	s4,a0
  struct kthread *nt;
  int res = 1;
  for(nt = p->kthreads; nt < &p->kthreads[NTHREAD]; nt++){
    8000313a:	28898493          	addi	s1,s3,648
    8000313e:	6505                	lui	a0,0x1
    80003140:	84850513          	addi	a0,a0,-1976 # 848 <_entry-0x7ffff7b8>
    80003144:	99aa                	add	s3,s3,a0
  int res = 1;
    80003146:	4905                	li	s2,1
    80003148:	a029                	j	80003152 <kthread_join_all+0x3c>
  for(nt = p->kthreads; nt < &p->kthreads[NTHREAD]; nt++){
    8000314a:	0b848493          	addi	s1,s1,184
    8000314e:	00998e63          	beq	s3,s1,8000316a <kthread_join_all+0x54>
    if(nt != t){
    80003152:	fe9a0ce3          	beq	s4,s1,8000314a <kthread_join_all+0x34>
      int thread_index = (int)(nt - p->kthreads);
      res &= kthread_join(nt->tid,0);
    80003156:	4581                	li	a1,0
    80003158:	5888                	lw	a0,48(s1)
    8000315a:	00000097          	auipc	ra,0x0
    8000315e:	d3a080e7          	jalr	-710(ra) # 80002e94 <kthread_join>
    80003162:	01257933          	and	s2,a0,s2
    80003166:	2901                	sext.w	s2,s2
    80003168:	b7cd                	j	8000314a <kthread_join_all+0x34>
    }
  }

  return res;
    8000316a:	854a                	mv	a0,s2
    8000316c:	70a2                	ld	ra,40(sp)
    8000316e:	7402                	ld	s0,32(sp)
    80003170:	64e2                	ld	s1,24(sp)
    80003172:	6942                	ld	s2,16(sp)
    80003174:	69a2                	ld	s3,8(sp)
    80003176:	6a02                	ld	s4,0(sp)
    80003178:	6145                	addi	sp,sp,48
    8000317a:	8082                	ret

000000008000317c <swtch>:
    8000317c:	00153023          	sd	ra,0(a0)
    80003180:	00253423          	sd	sp,8(a0)
    80003184:	e900                	sd	s0,16(a0)
    80003186:	ed04                	sd	s1,24(a0)
    80003188:	03253023          	sd	s2,32(a0)
    8000318c:	03353423          	sd	s3,40(a0)
    80003190:	03453823          	sd	s4,48(a0)
    80003194:	03553c23          	sd	s5,56(a0)
    80003198:	05653023          	sd	s6,64(a0)
    8000319c:	05753423          	sd	s7,72(a0)
    800031a0:	05853823          	sd	s8,80(a0)
    800031a4:	05953c23          	sd	s9,88(a0)
    800031a8:	07a53023          	sd	s10,96(a0)
    800031ac:	07b53423          	sd	s11,104(a0)
    800031b0:	0005b083          	ld	ra,0(a1)
    800031b4:	0085b103          	ld	sp,8(a1)
    800031b8:	6980                	ld	s0,16(a1)
    800031ba:	6d84                	ld	s1,24(a1)
    800031bc:	0205b903          	ld	s2,32(a1)
    800031c0:	0285b983          	ld	s3,40(a1)
    800031c4:	0305ba03          	ld	s4,48(a1)
    800031c8:	0385ba83          	ld	s5,56(a1)
    800031cc:	0405bb03          	ld	s6,64(a1)
    800031d0:	0485bb83          	ld	s7,72(a1)
    800031d4:	0505bc03          	ld	s8,80(a1)
    800031d8:	0585bc83          	ld	s9,88(a1)
    800031dc:	0605bd03          	ld	s10,96(a1)
    800031e0:	0685bd83          	ld	s11,104(a1)
    800031e4:	8082                	ret

00000000800031e6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800031e6:	1141                	addi	sp,sp,-16
    800031e8:	e406                	sd	ra,8(sp)
    800031ea:	e022                	sd	s0,0(sp)
    800031ec:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800031ee:	00006597          	auipc	a1,0x6
    800031f2:	34258593          	addi	a1,a1,834 # 80009530 <states.0+0x20>
    800031f6:	00030517          	auipc	a0,0x30
    800031fa:	73250513          	addi	a0,a0,1842 # 80033928 <tickslock>
    800031fe:	ffffe097          	auipc	ra,0xffffe
    80003202:	938080e7          	jalr	-1736(ra) # 80000b36 <initlock>
}
    80003206:	60a2                	ld	ra,8(sp)
    80003208:	6402                	ld	s0,0(sp)
    8000320a:	0141                	addi	sp,sp,16
    8000320c:	8082                	ret

000000008000320e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000320e:	1141                	addi	sp,sp,-16
    80003210:	e422                	sd	s0,8(sp)
    80003212:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003214:	00004797          	auipc	a5,0x4
    80003218:	b7c78793          	addi	a5,a5,-1156 # 80006d90 <kernelvec>
    8000321c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80003220:	6422                	ld	s0,8(sp)
    80003222:	0141                	addi	sp,sp,16
    80003224:	8082                	ret

0000000080003226 <check_should_cont>:
}

int 
check_should_cont(struct proc *p){
  for(int i=0;i<32;i++){
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    80003226:	0e852303          	lw	t1,232(a0)
    8000322a:	0f850813          	addi	a6,a0,248
    8000322e:	4685                	li	a3,1
    80003230:	4701                	li	a4,0
    80003232:	4885                	li	a7,1
  for(int i=0;i<32;i++){
    80003234:	4e7d                	li	t3,31
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    80003236:	4ecd                	li	t4,19
    80003238:	a801                	j	80003248 <check_should_cont+0x22>
  for(int i=0;i<32;i++){
    8000323a:	0006879b          	sext.w	a5,a3
    8000323e:	04fe4663          	blt	t3,a5,8000328a <check_should_cont+0x64>
    80003242:	2705                	addiw	a4,a4,1
    80003244:	2685                	addiw	a3,a3,1
    80003246:	0821                	addi	a6,a6,8
    80003248:	0007059b          	sext.w	a1,a4
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    8000324c:	00e8963b          	sllw	a2,a7,a4
    80003250:	00c377b3          	and	a5,t1,a2
    80003254:	2781                	sext.w	a5,a5
    80003256:	d3f5                	beqz	a5,8000323a <check_should_cont+0x14>
    80003258:	0ec52783          	lw	a5,236(a0)
    8000325c:	8ff1                	and	a5,a5,a2
    8000325e:	2781                	sext.w	a5,a5
    80003260:	ffe9                	bnez	a5,8000323a <check_should_cont+0x14>
    80003262:	00083783          	ld	a5,0(a6)
    80003266:	01d78563          	beq	a5,t4,80003270 <check_should_cont+0x4a>
    8000326a:	fdd598e3          	bne	a1,t4,8000323a <check_should_cont+0x14>
          (i == SIGCONT && p->signal_handlers[i] == SIG_DFL))){
    8000326e:	fbf1                	bnez	a5,80003242 <check_should_cont+0x1c>
check_should_cont(struct proc *p){
    80003270:	1141                	addi	sp,sp,-16
    80003272:	e406                	sd	ra,8(sp)
    80003274:	e022                	sd	s0,0(sp)
    80003276:	0800                	addi	s0,sp,16
        turn_off_bit(p, i);
    80003278:	00000097          	auipc	ra,0x0
    8000327c:	ad8080e7          	jalr	-1320(ra) # 80002d50 <turn_off_bit>
        return 1;
    80003280:	4505                	li	a0,1
      }
  }
  return 0;
}
    80003282:	60a2                	ld	ra,8(sp)
    80003284:	6402                	ld	s0,0(sp)
    80003286:	0141                	addi	sp,sp,16
    80003288:	8082                	ret
  return 0;
    8000328a:	4501                	li	a0,0
}
    8000328c:	8082                	ret

000000008000328e <handle_stop>:



void
handle_stop(struct proc* p){
    8000328e:	7139                	addi	sp,sp,-64
    80003290:	fc06                	sd	ra,56(sp)
    80003292:	f822                	sd	s0,48(sp)
    80003294:	f426                	sd	s1,40(sp)
    80003296:	f04a                	sd	s2,32(sp)
    80003298:	ec4e                	sd	s3,24(sp)
    8000329a:	e852                	sd	s4,16(sp)
    8000329c:	e456                	sd	s5,8(sp)
    8000329e:	e05a                	sd	s6,0(sp)
    800032a0:	0080                	addi	s0,sp,64
    800032a2:	89aa                	mv	s3,a0
  // p->frozen=1;
  struct kthread *t;
  struct kthread *curr_t = mykthread();
    800032a4:	fffff097          	auipc	ra,0xfffff
    800032a8:	80c080e7          	jalr	-2036(ra) # 80001ab0 <mykthread>
    800032ac:	8aaa                	mv	s5,a0
  printf("entered handle stop pid %d\n",p->pid);
    800032ae:	0249a583          	lw	a1,36(s3)
    800032b2:	00006517          	auipc	a0,0x6
    800032b6:	28650513          	addi	a0,a0,646 # 80009538 <states.0+0x28>
    800032ba:	ffffd097          	auipc	ra,0xffffd
    800032be:	2be080e7          	jalr	702(ra) # 80000578 <printf>

  // Make all other threads belong to the same procces freeze 
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800032c2:	28898493          	addi	s1,s3,648
    800032c6:	6a05                	lui	s4,0x1
    800032c8:	848a0a13          	addi	s4,s4,-1976 # 848 <_entry-0x7ffff7b8>
    800032cc:	9a4e                	add	s4,s4,s3
    800032ce:	8926                	mv	s2,s1
    if(t!=curr_t){
      acquire(&t->lock);
      t->frozen=1;
    800032d0:	4b05                	li	s6,1
    800032d2:	a029                	j	800032dc <handle_stop+0x4e>
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800032d4:	0b890913          	addi	s2,s2,184
    800032d8:	03490163          	beq	s2,s4,800032fa <handle_stop+0x6c>
    if(t!=curr_t){
    800032dc:	ff2a8ce3          	beq	s5,s2,800032d4 <handle_stop+0x46>
      acquire(&t->lock);
    800032e0:	854a                	mv	a0,s2
    800032e2:	ffffe097          	auipc	ra,0xffffe
    800032e6:	8e4080e7          	jalr	-1820(ra) # 80000bc6 <acquire>
      t->frozen=1;
    800032ea:	03692a23          	sw	s6,52(s2)
      release(&t->lock);
    800032ee:	854a                	mv	a0,s2
    800032f0:	ffffe097          	auipc	ra,0xffffe
    800032f4:	9a0080e7          	jalr	-1632(ra) # 80000c90 <release>
    800032f8:	bff1                	j	800032d4 <handle_stop+0x46>
    }
  }
  int should_cont = check_should_cont(p);
    800032fa:	854e                	mv	a0,s3
    800032fc:	00000097          	auipc	ra,0x0
    80003300:	f2a080e7          	jalr	-214(ra) # 80003226 <check_should_cont>
  // printf("should cont = %d puid = %d\n",should_cont,p->pid);
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    80003304:	0e89a783          	lw	a5,232(s3)
    80003308:	2007f793          	andi	a5,a5,512
    8000330c:	e795                	bnez	a5,80003338 <handle_stop+0xaa>
    8000330e:	e50d                	bnez	a0,80003338 <handle_stop+0xaa>
    // printf("in handle stop, yielding pid=%d \n",p->pid);//TODO delete
    yield();
    80003310:	fffff097          	auipc	ra,0xfffff
    80003314:	09e080e7          	jalr	158(ra) # 800023ae <yield>
    should_cont = check_should_cont(p);  
    80003318:	854e                	mv	a0,s3
    8000331a:	00000097          	auipc	ra,0x0
    8000331e:	f0c080e7          	jalr	-244(ra) # 80003226 <check_should_cont>
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    80003322:	0e89a783          	lw	a5,232(s3)
    80003326:	2007f793          	andi	a5,a5,512
    8000332a:	e799                	bnez	a5,80003338 <handle_stop+0xaa>
    8000332c:	d175                	beqz	a0,80003310 <handle_stop+0x82>
    8000332e:	a029                	j	80003338 <handle_stop+0xaa>
    // printf("should cont = %d puid = %d\n",should_cont,p->pid);
  }

  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    80003330:	0b848493          	addi	s1,s1,184
    80003334:	03448163          	beq	s1,s4,80003356 <handle_stop+0xc8>
    if(t!=curr_t){
    80003338:	fe9a8ce3          	beq	s5,s1,80003330 <handle_stop+0xa2>
      acquire(&t->lock);
    8000333c:	8526                	mv	a0,s1
    8000333e:	ffffe097          	auipc	ra,0xffffe
    80003342:	888080e7          	jalr	-1912(ra) # 80000bc6 <acquire>
      t->frozen=0;
    80003346:	0204aa23          	sw	zero,52(s1)
      release(&t->lock);
    8000334a:	8526                	mv	a0,s1
    8000334c:	ffffe097          	auipc	ra,0xffffe
    80003350:	944080e7          	jalr	-1724(ra) # 80000c90 <release>
    80003354:	bff1                	j	80003330 <handle_stop+0xa2>
    }
  }
  if(p->pending_signals&1<<SIGKILL)
    80003356:	0e89a783          	lw	a5,232(s3)
    8000335a:	2007f793          	andi	a5,a5,512
    8000335e:	c781                	beqz	a5,80003366 <handle_stop+0xd8>
    p->killed=1;
    80003360:	4785                	li	a5,1
    80003362:	00f9ae23          	sw	a5,28(s3)
}
    80003366:	70e2                	ld	ra,56(sp)
    80003368:	7442                	ld	s0,48(sp)
    8000336a:	74a2                	ld	s1,40(sp)
    8000336c:	7902                	ld	s2,32(sp)
    8000336e:	69e2                	ld	s3,24(sp)
    80003370:	6a42                	ld	s4,16(sp)
    80003372:	6aa2                	ld	s5,8(sp)
    80003374:	6b02                	ld	s6,0(sp)
    80003376:	6121                	addi	sp,sp,64
    80003378:	8082                	ret

000000008000337a <check_pending_signals>:

void 
check_pending_signals(struct proc* p){
    8000337a:	7159                	addi	sp,sp,-112
    8000337c:	f486                	sd	ra,104(sp)
    8000337e:	f0a2                	sd	s0,96(sp)
    80003380:	eca6                	sd	s1,88(sp)
    80003382:	e8ca                	sd	s2,80(sp)
    80003384:	e4ce                	sd	s3,72(sp)
    80003386:	e0d2                	sd	s4,64(sp)
    80003388:	fc56                	sd	s5,56(sp)
    8000338a:	f85a                	sd	s6,48(sp)
    8000338c:	f45e                	sd	s7,40(sp)
    8000338e:	f062                	sd	s8,32(sp)
    80003390:	ec66                	sd	s9,24(sp)
    80003392:	e86a                	sd	s10,16(sp)
    80003394:	e46e                	sd	s11,8(sp)
    80003396:	1880                	addi	s0,sp,112
    80003398:	89aa                	mv	s3,a0
  if(p->pid==4){
    8000339a:	5158                	lw	a4,36(a0)
    8000339c:	4791                	li	a5,4
    8000339e:	02f70663          	beq	a4,a5,800033ca <check_pending_signals+0x50>
    // printf("son in pending sig\n");
    if(p->pending_signals & (1<<SIGSTOP))
      printf("recieved stop sig\n");
  }
  struct kthread *t= mykthread();
    800033a2:	ffffe097          	auipc	ra,0xffffe
    800033a6:	70e080e7          	jalr	1806(ra) # 80001ab0 <mykthread>
    800033aa:	8caa                	mv	s9,a0
  for(int sig_num=0;sig_num<32;sig_num++){
    800033ac:	0f898913          	addi	s2,s3,248
    800033b0:	4481                	li	s1,0
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    800033b2:	4a05                	li	s4,1
            p->killed = 1;
            release(&p->lock);
        }
      }

      else if(act.sa_handler==(void*)SIGKILL){
    800033b4:	4c25                	li	s8,9
        p->killed=1;
      }else if(act.sa_handler==(void*)SIGSTOP){
    800033b6:	4b45                	li	s6,17
        handle_stop(p);
      }      
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    800033b8:	4b85                	li	s7,1
            printf("handle stop pid=%d\n",p->pid); //TODO delete
    800033ba:	00006d97          	auipc	s11,0x6
    800033be:	1b6d8d93          	addi	s11,s11,438 # 80009570 <states.0+0x60>
        switch (sig_num)
    800033c2:	4d4d                	li	s10,19
  for(int sig_num=0;sig_num<32;sig_num++){
    800033c4:	02000a93          	li	s5,32
    800033c8:	a069                	j	80003452 <check_pending_signals+0xd8>
    if(p->pending_signals & (1<<SIGSTOP))
    800033ca:	0e852783          	lw	a5,232(a0)
    800033ce:	00020737          	lui	a4,0x20
    800033d2:	8ff9                	and	a5,a5,a4
    800033d4:	d7f9                	beqz	a5,800033a2 <check_pending_signals+0x28>
      printf("recieved stop sig\n");
    800033d6:	00006517          	auipc	a0,0x6
    800033da:	18250513          	addi	a0,a0,386 # 80009558 <states.0+0x48>
    800033de:	ffffd097          	auipc	ra,0xffffd
    800033e2:	19a080e7          	jalr	410(ra) # 80000578 <printf>
    800033e6:	bf75                	j	800033a2 <check_pending_signals+0x28>
        switch (sig_num)
    800033e8:	03648163          	beq	s1,s6,8000340a <check_pending_signals+0x90>
    800033ec:	03a48c63          	beq	s1,s10,80003424 <check_pending_signals+0xaa>
            acquire(&p->lock);
    800033f0:	854e                	mv	a0,s3
    800033f2:	ffffd097          	auipc	ra,0xffffd
    800033f6:	7d4080e7          	jalr	2004(ra) # 80000bc6 <acquire>
            p->killed = 1;
    800033fa:	0179ae23          	sw	s7,28(s3)
            release(&p->lock);
    800033fe:	854e                	mv	a0,s3
    80003400:	ffffe097          	auipc	ra,0xffffe
    80003404:	890080e7          	jalr	-1904(ra) # 80000c90 <release>
    80003408:	a81d                	j	8000343e <check_pending_signals+0xc4>
            printf("handle stop pid=%d\n",p->pid); //TODO delete
    8000340a:	0249a583          	lw	a1,36(s3)
    8000340e:	856e                	mv	a0,s11
    80003410:	ffffd097          	auipc	ra,0xffffd
    80003414:	168080e7          	jalr	360(ra) # 80000578 <printf>
            handle_stop(p);
    80003418:	854e                	mv	a0,s3
    8000341a:	00000097          	auipc	ra,0x0
    8000341e:	e74080e7          	jalr	-396(ra) # 8000328e <handle_stop>
            break;
    80003422:	a831                	j	8000343e <check_pending_signals+0xc4>
            printf("handle sigcont pid=%d\n",p->pid); //TODO delete
    80003424:	0249a583          	lw	a1,36(s3)
    80003428:	00006517          	auipc	a0,0x6
    8000342c:	16050513          	addi	a0,a0,352 # 80009588 <states.0+0x78>
    80003430:	ffffd097          	auipc	ra,0xffffd
    80003434:	148080e7          	jalr	328(ra) # 80000578 <printf>
            break;
    80003438:	a019                	j	8000343e <check_pending_signals+0xc4>
        p->killed=1;
    8000343a:	0179ae23          	sw	s7,28(s3)
        turn_off_bit(p, sig_num);

        return;
      }

      turn_off_bit(p, sig_num);            
    8000343e:	85a6                	mv	a1,s1
    80003440:	854e                	mv	a0,s3
    80003442:	00000097          	auipc	ra,0x0
    80003446:	90e080e7          	jalr	-1778(ra) # 80002d50 <turn_off_bit>
  for(int sig_num=0;sig_num<32;sig_num++){
    8000344a:	2485                	addiw	s1,s1,1
    8000344c:	0921                	addi	s2,s2,8
    8000344e:	0d548963          	beq	s1,s5,80003520 <check_pending_signals+0x1a6>
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    80003452:	009a173b          	sllw	a4,s4,s1
    80003456:	0e89a783          	lw	a5,232(s3)
    8000345a:	8ff9                	and	a5,a5,a4
    8000345c:	2781                	sext.w	a5,a5
    8000345e:	d7f5                	beqz	a5,8000344a <check_pending_signals+0xd0>
    80003460:	0ec9a783          	lw	a5,236(s3)
    80003464:	8f7d                	and	a4,a4,a5
    80003466:	2701                	sext.w	a4,a4
    80003468:	f36d                	bnez	a4,8000344a <check_pending_signals+0xd0>
      act.sa_handler = p->signal_handlers[sig_num];
    8000346a:	00093703          	ld	a4,0(s2)
      if(act.sa_handler == (void*)SIG_DFL){
    8000346e:	df2d                	beqz	a4,800033e8 <check_pending_signals+0x6e>
      else if(act.sa_handler==(void*)SIGKILL){
    80003470:	fd8705e3          	beq	a4,s8,8000343a <check_pending_signals+0xc0>
      }else if(act.sa_handler==(void*)SIGSTOP){
    80003474:	0d670563          	beq	a4,s6,8000353e <check_pending_signals+0x1c4>
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    80003478:	fd7703e3          	beq	a4,s7,8000343e <check_pending_signals+0xc4>
    8000347c:	2809a703          	lw	a4,640(s3)
    80003480:	ff5d                	bnez	a4,8000343e <check_pending_signals+0xc4>
      act.sigmask = p->handlers_sigmasks[sig_num];
    80003482:	07c48713          	addi	a4,s1,124
    80003486:	070a                	slli	a4,a4,0x2
    80003488:	974e                	add	a4,a4,s3
    8000348a:	4718                	lw	a4,8(a4)
        p->handling_user_sig_flag = 1;
    8000348c:	4685                	li	a3,1
    8000348e:	28d9a023          	sw	a3,640(s3)
        p->signal_mask_backup = p->signal_mask;
    80003492:	0ef9a823          	sw	a5,240(s3)
        p->signal_mask= p->handlers_sigmasks[sig_num];
    80003496:	0ee9a623          	sw	a4,236(s3)
        t->trapframe->sp -= sizeof(struct trapframe);
    8000349a:	040cb703          	ld	a4,64(s9)
    8000349e:	7b1c                	ld	a5,48(a4)
    800034a0:	ee078793          	addi	a5,a5,-288
    800034a4:	fb1c                	sd	a5,48(a4)
        p->user_trapframe_backup = (struct trapframe* )(t->trapframe->sp);
    800034a6:	040cb783          	ld	a5,64(s9)
    800034aa:	7b8c                	ld	a1,48(a5)
    800034ac:	26b9bc23          	sd	a1,632(s3)
        copyout(p->pagetable, (uint64)p->user_trapframe_backup, (char *)t->trapframe, sizeof(struct trapframe));
    800034b0:	12000693          	li	a3,288
    800034b4:	040cb603          	ld	a2,64(s9)
    800034b8:	0409b503          	ld	a0,64(s3)
    800034bc:	ffffe097          	auipc	ra,0xffffe
    800034c0:	19c080e7          	jalr	412(ra) # 80001658 <copyout>
        uint64 size = (uint64)&end_sigret - (uint64)&call_sigret;
    800034c4:	00004697          	auipc	a3,0x4
    800034c8:	f5c68693          	addi	a3,a3,-164 # 80007420 <end_sigret>
    800034cc:	00004617          	auipc	a2,0x4
    800034d0:	f4c60613          	addi	a2,a2,-180 # 80007418 <call_sigret>
        t->trapframe->sp -= size;
    800034d4:	040cb703          	ld	a4,64(s9)
    800034d8:	40d605b3          	sub	a1,a2,a3
    800034dc:	7b1c                	ld	a5,48(a4)
    800034de:	97ae                	add	a5,a5,a1
    800034e0:	fb1c                	sd	a5,48(a4)
        copyout(p->pagetable, (uint64)t->trapframe->sp, (char *)&call_sigret, size);
    800034e2:	040cb783          	ld	a5,64(s9)
    800034e6:	8e91                	sub	a3,a3,a2
    800034e8:	7b8c                	ld	a1,48(a5)
    800034ea:	0409b503          	ld	a0,64(s3)
    800034ee:	ffffe097          	auipc	ra,0xffffe
    800034f2:	16a080e7          	jalr	362(ra) # 80001658 <copyout>
        t->trapframe->a0 = sig_num;
    800034f6:	040cb783          	ld	a5,64(s9)
    800034fa:	fba4                	sd	s1,112(a5)
        t->trapframe->ra = t->trapframe->sp;
    800034fc:	040cb783          	ld	a5,64(s9)
    80003500:	7b98                	ld	a4,48(a5)
    80003502:	f798                	sd	a4,40(a5)
        t->trapframe->epc = (uint64)p->signal_handlers[sig_num];
    80003504:	040cb703          	ld	a4,64(s9)
    80003508:	01e48793          	addi	a5,s1,30
    8000350c:	078e                	slli	a5,a5,0x3
    8000350e:	97ce                	add	a5,a5,s3
    80003510:	679c                	ld	a5,8(a5)
    80003512:	ef1c                	sd	a5,24(a4)
        turn_off_bit(p, sig_num);
    80003514:	85a6                	mv	a1,s1
    80003516:	854e                	mv	a0,s3
    80003518:	00000097          	auipc	ra,0x0
    8000351c:	838080e7          	jalr	-1992(ra) # 80002d50 <turn_off_bit>
    }
  }
}
    80003520:	70a6                	ld	ra,104(sp)
    80003522:	7406                	ld	s0,96(sp)
    80003524:	64e6                	ld	s1,88(sp)
    80003526:	6946                	ld	s2,80(sp)
    80003528:	69a6                	ld	s3,72(sp)
    8000352a:	6a06                	ld	s4,64(sp)
    8000352c:	7ae2                	ld	s5,56(sp)
    8000352e:	7b42                	ld	s6,48(sp)
    80003530:	7ba2                	ld	s7,40(sp)
    80003532:	7c02                	ld	s8,32(sp)
    80003534:	6ce2                	ld	s9,24(sp)
    80003536:	6d42                	ld	s10,16(sp)
    80003538:	6da2                	ld	s11,8(sp)
    8000353a:	6165                	addi	sp,sp,112
    8000353c:	8082                	ret
        handle_stop(p);
    8000353e:	854e                	mv	a0,s3
    80003540:	00000097          	auipc	ra,0x0
    80003544:	d4e080e7          	jalr	-690(ra) # 8000328e <handle_stop>
    80003548:	bddd                	j	8000343e <check_pending_signals+0xc4>

000000008000354a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000354a:	7179                	addi	sp,sp,-48
    8000354c:	f406                	sd	ra,40(sp)
    8000354e:	f022                	sd	s0,32(sp)
    80003550:	ec26                	sd	s1,24(sp)
    80003552:	e84a                	sd	s2,16(sp)
    80003554:	e44e                	sd	s3,8(sp)
    80003556:	e052                	sd	s4,0(sp)
    80003558:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000355a:	ffffe097          	auipc	ra,0xffffe
    8000355e:	516080e7          	jalr	1302(ra) # 80001a70 <myproc>
    80003562:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80003564:	ffffe097          	auipc	ra,0xffffe
    80003568:	54c080e7          	jalr	1356(ra) # 80001ab0 <mykthread>
    8000356c:	84aa                	mv	s1,a0
  int mytid = mykthread()->tid;
    8000356e:	ffffe097          	auipc	ra,0xffffe
    80003572:	542080e7          	jalr	1346(ra) # 80001ab0 <mykthread>
    80003576:	5914                	lw	a3,48(a0)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003578:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000357c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000357e:	10079073          	csrw	sstatus,a5

  intr_off();
  

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80003582:	00005617          	auipc	a2,0x5
    80003586:	a7e60613          	addi	a2,a2,-1410 # 80008000 <_trampoline>
    8000358a:	00005717          	auipc	a4,0x5
    8000358e:	a7670713          	addi	a4,a4,-1418 # 80008000 <_trampoline>
    80003592:	8f11                	sub	a4,a4,a2
    80003594:	040007b7          	lui	a5,0x4000
    80003598:	17fd                	addi	a5,a5,-1
    8000359a:	07b2                	slli	a5,a5,0xc
    8000359c:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000359e:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  t->trapframe->kernel_satp = r_satp();         // kernel page table
    800035a2:	60b8                	ld	a4,64(s1)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800035a4:	180025f3          	csrr	a1,satp
    800035a8:	e30c                	sd	a1,0(a4)
  t->trapframe->kernel_sp = t->kstack + PGSIZE; // process's kernel stack
    800035aa:	60ac                	ld	a1,64(s1)
    800035ac:	7c98                	ld	a4,56(s1)
    800035ae:	6505                	lui	a0,0x1
    800035b0:	972a                	add	a4,a4,a0
    800035b2:	e598                	sd	a4,8(a1)
  t->trapframe->kernel_trap = (uint64)usertrap;
    800035b4:	60b8                	ld	a4,64(s1)
    800035b6:	00000597          	auipc	a1,0x0
    800035ba:	1a658593          	addi	a1,a1,422 # 8000375c <usertrap>
    800035be:	eb0c                	sd	a1,16(a4)
  t->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800035c0:	60b8                	ld	a4,64(s1)
  asm volatile("mv %0, tp" : "=r" (x) );
    800035c2:	8592                	mv	a1,tp
    800035c4:	f30c                	sd	a1,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800035c6:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800035ca:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800035ce:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800035d2:	10071073          	csrw	sstatus,a4
  w_sstatus(x);
  

  // set S Exception Program Counter to the saved user pc.
  w_sepc(t->trapframe->epc);
    800035d6:	60b8                	ld	a4,64(s1)
    800035d8:	6f0c                	ld	a1,24(a4)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800035da:	14159073          	csrw	sepc,a1

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800035de:	04093983          	ld	s3,64(s2)
    800035e2:	00c9d993          	srli	s3,s3,0xc
    800035e6:	577d                	li	a4,-1
    800035e8:	177e                	slli	a4,a4,0x3f
    800035ea:	00e9e9b3          	or	s3,s3,a4


  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800035ee:	00005a17          	auipc	s4,0x5
    800035f2:	aa2a0a13          	addi	s4,s4,-1374 # 80008090 <userret>
    800035f6:	40ca0a33          	sub	s4,s4,a2
    800035fa:	9a3e                	add	s4,s4,a5
  // if(mytid == 4)
    // printf("end of usertrap tid= %d\n",mykthread()->tid);
  int thread_ind = (int)(t - p->kthreads);
    800035fc:	28890913          	addi	s2,s2,648
    80003600:	412484b3          	sub	s1,s1,s2
    80003604:	848d                	srai	s1,s1,0x3
  struct trapframe *tf = TRAPFRAME;
  tf += thread_ind;
    80003606:	00006797          	auipc	a5,0x6
    8000360a:	a027b783          	ld	a5,-1534(a5) # 80009008 <etext+0x8>
    8000360e:	02f484bb          	mulw	s1,s1,a5
    80003612:	00349793          	slli	a5,s1,0x3
    80003616:	94be                	add	s1,s1,a5
    80003618:	0496                	slli	s1,s1,0x5
    8000361a:	020007b7          	lui	a5,0x2000
    8000361e:	17fd                	addi	a5,a5,-1
    80003620:	07b6                	slli	a5,a5,0xd
    80003622:	94be                	add	s1,s1,a5
  static int print=0;
   if(mytid == 3 && !print){
    80003624:	478d                	li	a5,3
    80003626:	00f68d63          	beq	a3,a5,80003640 <usertrapret+0xf6>
    print =0;
    printf("fuck\n");

   }

  ((void (*)(uint64,uint64))fn)(tf, satp);
    8000362a:	85ce                	mv	a1,s3
    8000362c:	8526                	mv	a0,s1
    8000362e:	9a02                	jalr	s4
}
    80003630:	70a2                	ld	ra,40(sp)
    80003632:	7402                	ld	s0,32(sp)
    80003634:	64e2                	ld	s1,24(sp)
    80003636:	6942                	ld	s2,16(sp)
    80003638:	69a2                	ld	s3,8(sp)
    8000363a:	6a02                	ld	s4,0(sp)
    8000363c:	6145                	addi	sp,sp,48
    8000363e:	8082                	ret
   if(mytid == 3 && !print){
    80003640:	00007797          	auipc	a5,0x7
    80003644:	9f07a783          	lw	a5,-1552(a5) # 8000a030 <print.0>
    80003648:	f3ed                	bnez	a5,8000362a <usertrapret+0xe0>
    printf("epc t->trapframe is %p\n",t->trapframe->epc);
    8000364a:	00006517          	auipc	a0,0x6
    8000364e:	f5650513          	addi	a0,a0,-170 # 800095a0 <states.0+0x90>
    80003652:	ffffd097          	auipc	ra,0xffffd
    80003656:	f26080e7          	jalr	-218(ra) # 80000578 <printf>
    print =0;
    8000365a:	00007797          	auipc	a5,0x7
    8000365e:	9c07ab23          	sw	zero,-1578(a5) # 8000a030 <print.0>
    printf("fuck\n");
    80003662:	00006517          	auipc	a0,0x6
    80003666:	f5650513          	addi	a0,a0,-170 # 800095b8 <states.0+0xa8>
    8000366a:	ffffd097          	auipc	ra,0xffffd
    8000366e:	f0e080e7          	jalr	-242(ra) # 80000578 <printf>
    80003672:	bf65                	j	8000362a <usertrapret+0xe0>

0000000080003674 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80003674:	1101                	addi	sp,sp,-32
    80003676:	ec06                	sd	ra,24(sp)
    80003678:	e822                	sd	s0,16(sp)
    8000367a:	e426                	sd	s1,8(sp)
    8000367c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000367e:	00030497          	auipc	s1,0x30
    80003682:	2aa48493          	addi	s1,s1,682 # 80033928 <tickslock>
    80003686:	8526                	mv	a0,s1
    80003688:	ffffd097          	auipc	ra,0xffffd
    8000368c:	53e080e7          	jalr	1342(ra) # 80000bc6 <acquire>
  ticks++;
    80003690:	00007517          	auipc	a0,0x7
    80003694:	9a450513          	addi	a0,a0,-1628 # 8000a034 <ticks>
    80003698:	411c                	lw	a5,0(a0)
    8000369a:	2785                	addiw	a5,a5,1
    8000369c:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000369e:	fffff097          	auipc	ra,0xfffff
    800036a2:	ed6080e7          	jalr	-298(ra) # 80002574 <wakeup>
  release(&tickslock);
    800036a6:	8526                	mv	a0,s1
    800036a8:	ffffd097          	auipc	ra,0xffffd
    800036ac:	5e8080e7          	jalr	1512(ra) # 80000c90 <release>
}
    800036b0:	60e2                	ld	ra,24(sp)
    800036b2:	6442                	ld	s0,16(sp)
    800036b4:	64a2                	ld	s1,8(sp)
    800036b6:	6105                	addi	sp,sp,32
    800036b8:	8082                	ret

00000000800036ba <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800036ba:	1101                	addi	sp,sp,-32
    800036bc:	ec06                	sd	ra,24(sp)
    800036be:	e822                	sd	s0,16(sp)
    800036c0:	e426                	sd	s1,8(sp)
    800036c2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800036c4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800036c8:	00074d63          	bltz	a4,800036e2 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800036cc:	57fd                	li	a5,-1
    800036ce:	17fe                	slli	a5,a5,0x3f
    800036d0:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800036d2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800036d4:	06f70363          	beq	a4,a5,8000373a <devintr+0x80>
  }
}
    800036d8:	60e2                	ld	ra,24(sp)
    800036da:	6442                	ld	s0,16(sp)
    800036dc:	64a2                	ld	s1,8(sp)
    800036de:	6105                	addi	sp,sp,32
    800036e0:	8082                	ret
     (scause & 0xff) == 9){
    800036e2:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800036e6:	46a5                	li	a3,9
    800036e8:	fed792e3          	bne	a5,a3,800036cc <devintr+0x12>
    int irq = plic_claim();
    800036ec:	00003097          	auipc	ra,0x3
    800036f0:	7ac080e7          	jalr	1964(ra) # 80006e98 <plic_claim>
    800036f4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800036f6:	47a9                	li	a5,10
    800036f8:	02f50763          	beq	a0,a5,80003726 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800036fc:	4785                	li	a5,1
    800036fe:	02f50963          	beq	a0,a5,80003730 <devintr+0x76>
    return 1;
    80003702:	4505                	li	a0,1
    } else if(irq){
    80003704:	d8f1                	beqz	s1,800036d8 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80003706:	85a6                	mv	a1,s1
    80003708:	00006517          	auipc	a0,0x6
    8000370c:	eb850513          	addi	a0,a0,-328 # 800095c0 <states.0+0xb0>
    80003710:	ffffd097          	auipc	ra,0xffffd
    80003714:	e68080e7          	jalr	-408(ra) # 80000578 <printf>
      plic_complete(irq);
    80003718:	8526                	mv	a0,s1
    8000371a:	00003097          	auipc	ra,0x3
    8000371e:	7a2080e7          	jalr	1954(ra) # 80006ebc <plic_complete>
    return 1;
    80003722:	4505                	li	a0,1
    80003724:	bf55                	j	800036d8 <devintr+0x1e>
      uartintr();
    80003726:	ffffd097          	auipc	ra,0xffffd
    8000372a:	264080e7          	jalr	612(ra) # 8000098a <uartintr>
    8000372e:	b7ed                	j	80003718 <devintr+0x5e>
      virtio_disk_intr();
    80003730:	00004097          	auipc	ra,0x4
    80003734:	c1e080e7          	jalr	-994(ra) # 8000734e <virtio_disk_intr>
    80003738:	b7c5                	j	80003718 <devintr+0x5e>
    if(cpuid() == 0){
    8000373a:	ffffe097          	auipc	ra,0xffffe
    8000373e:	302080e7          	jalr	770(ra) # 80001a3c <cpuid>
    80003742:	c901                	beqz	a0,80003752 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80003744:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80003748:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000374a:	14479073          	csrw	sip,a5
    return 2;
    8000374e:	4509                	li	a0,2
    80003750:	b761                	j	800036d8 <devintr+0x1e>
      clockintr();
    80003752:	00000097          	auipc	ra,0x0
    80003756:	f22080e7          	jalr	-222(ra) # 80003674 <clockintr>
    8000375a:	b7ed                	j	80003744 <devintr+0x8a>

000000008000375c <usertrap>:
{
    8000375c:	1101                	addi	sp,sp,-32
    8000375e:	ec06                	sd	ra,24(sp)
    80003760:	e822                	sd	s0,16(sp)
    80003762:	e426                	sd	s1,8(sp)
    80003764:	e04a                	sd	s2,0(sp)
    80003766:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003768:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000376c:	1007f793          	andi	a5,a5,256
    80003770:	e3dd                	bnez	a5,80003816 <usertrap+0xba>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003772:	00003797          	auipc	a5,0x3
    80003776:	61e78793          	addi	a5,a5,1566 # 80006d90 <kernelvec>
    8000377a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000377e:	ffffe097          	auipc	ra,0xffffe
    80003782:	2f2080e7          	jalr	754(ra) # 80001a70 <myproc>
    80003786:	84aa                	mv	s1,a0
  struct kthread *t = mykthread();
    80003788:	ffffe097          	auipc	ra,0xffffe
    8000378c:	328080e7          	jalr	808(ra) # 80001ab0 <mykthread>
    80003790:	892a                	mv	s2,a0
  t->trapframe->epc = r_sepc();
    80003792:	613c                	ld	a5,64(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003794:	14102773          	csrr	a4,sepc
    80003798:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000379a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000379e:	47a1                	li	a5,8
    800037a0:	08f71f63          	bne	a4,a5,8000383e <usertrap+0xe2>
    if(t->killed == 1)
    800037a4:	5518                	lw	a4,40(a0)
    800037a6:	4785                	li	a5,1
    800037a8:	06f70f63          	beq	a4,a5,80003826 <usertrap+0xca>
    else if(p->killed)
    800037ac:	4cdc                	lw	a5,28(s1)
    800037ae:	e3d1                	bnez	a5,80003832 <usertrap+0xd6>
    t->trapframe->epc += 4;
    800037b0:	04093703          	ld	a4,64(s2)
    800037b4:	6f1c                	ld	a5,24(a4)
    800037b6:	0791                	addi	a5,a5,4
    800037b8:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800037ba:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800037be:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800037c2:	10079073          	csrw	sstatus,a5
    syscall();
    800037c6:	00000097          	auipc	ra,0x0
    800037ca:	38a080e7          	jalr	906(ra) # 80003b50 <syscall>
  if(holding(&p->lock))
    800037ce:	8526                	mv	a0,s1
    800037d0:	ffffd097          	auipc	ra,0xffffd
    800037d4:	37c080e7          	jalr	892(ra) # 80000b4c <holding>
    800037d8:	e95d                	bnez	a0,8000388e <usertrap+0x132>
  acquire(&p->lock);
    800037da:	8526                	mv	a0,s1
    800037dc:	ffffd097          	auipc	ra,0xffffd
    800037e0:	3ea080e7          	jalr	1002(ra) # 80000bc6 <acquire>
  if(!p->handling_sig_flag){
    800037e4:	2844a783          	lw	a5,644(s1)
    800037e8:	cfc5                	beqz	a5,800038a0 <usertrap+0x144>
  release(&p->lock);
    800037ea:	8526                	mv	a0,s1
    800037ec:	ffffd097          	auipc	ra,0xffffd
    800037f0:	4a4080e7          	jalr	1188(ra) # 80000c90 <release>
  if(t->killed == 1)
    800037f4:	02892703          	lw	a4,40(s2)
    800037f8:	4785                	li	a5,1
    800037fa:	0cf70863          	beq	a4,a5,800038ca <usertrap+0x16e>
  else if(p->killed)
    800037fe:	4cdc                	lw	a5,28(s1)
    80003800:	ebf9                	bnez	a5,800038d6 <usertrap+0x17a>
  usertrapret();
    80003802:	00000097          	auipc	ra,0x0
    80003806:	d48080e7          	jalr	-696(ra) # 8000354a <usertrapret>
}
    8000380a:	60e2                	ld	ra,24(sp)
    8000380c:	6442                	ld	s0,16(sp)
    8000380e:	64a2                	ld	s1,8(sp)
    80003810:	6902                	ld	s2,0(sp)
    80003812:	6105                	addi	sp,sp,32
    80003814:	8082                	ret
    panic("usertrap: not from user mode");
    80003816:	00006517          	auipc	a0,0x6
    8000381a:	dca50513          	addi	a0,a0,-566 # 800095e0 <states.0+0xd0>
    8000381e:	ffffd097          	auipc	ra,0xffffd
    80003822:	d10080e7          	jalr	-752(ra) # 8000052e <panic>
      kthread_exit(-1); // Kill current thread
    80003826:	557d                	li	a0,-1
    80003828:	fffff097          	auipc	ra,0xfffff
    8000382c:	f48080e7          	jalr	-184(ra) # 80002770 <kthread_exit>
    80003830:	b741                	j	800037b0 <usertrap+0x54>
      exit(-1); // Kill the hole procces
    80003832:	557d                	li	a0,-1
    80003834:	fffff097          	auipc	ra,0xfffff
    80003838:	fd0080e7          	jalr	-48(ra) # 80002804 <exit>
    8000383c:	bf95                	j	800037b0 <usertrap+0x54>
  else if((which_dev = devintr()) != 0)
    8000383e:	00000097          	auipc	ra,0x0
    80003842:	e7c080e7          	jalr	-388(ra) # 800036ba <devintr>
    80003846:	c909                	beqz	a0,80003858 <usertrap+0xfc>
  if(which_dev == 2)
    80003848:	4789                	li	a5,2
    8000384a:	f8f512e3          	bne	a0,a5,800037ce <usertrap+0x72>
    yield();
    8000384e:	fffff097          	auipc	ra,0xfffff
    80003852:	b60080e7          	jalr	-1184(ra) # 800023ae <yield>
    80003856:	bfa5                	j	800037ce <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003858:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000385c:	50d0                	lw	a2,36(s1)
    8000385e:	00006517          	auipc	a0,0x6
    80003862:	da250513          	addi	a0,a0,-606 # 80009600 <states.0+0xf0>
    80003866:	ffffd097          	auipc	ra,0xffffd
    8000386a:	d12080e7          	jalr	-750(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000386e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003872:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003876:	00006517          	auipc	a0,0x6
    8000387a:	dba50513          	addi	a0,a0,-582 # 80009630 <states.0+0x120>
    8000387e:	ffffd097          	auipc	ra,0xffffd
    80003882:	cfa080e7          	jalr	-774(ra) # 80000578 <printf>
    t->killed = 1;
    80003886:	4785                	li	a5,1
    80003888:	02f92423          	sw	a5,40(s2)
  if(which_dev == 2)
    8000388c:	b789                	j	800037ce <usertrap+0x72>
    printf("fuck i am holding the lock in usertrap\n");   // TODO : delete
    8000388e:	00006517          	auipc	a0,0x6
    80003892:	dc250513          	addi	a0,a0,-574 # 80009650 <states.0+0x140>
    80003896:	ffffd097          	auipc	ra,0xffffd
    8000389a:	ce2080e7          	jalr	-798(ra) # 80000578 <printf>
    8000389e:	bf35                	j	800037da <usertrap+0x7e>
    p->handling_sig_flag = 1;
    800038a0:	4785                	li	a5,1
    800038a2:	28f4a223          	sw	a5,644(s1)
    release(&p->lock);
    800038a6:	8526                	mv	a0,s1
    800038a8:	ffffd097          	auipc	ra,0xffffd
    800038ac:	3e8080e7          	jalr	1000(ra) # 80000c90 <release>
    check_pending_signals(p);
    800038b0:	8526                	mv	a0,s1
    800038b2:	00000097          	auipc	ra,0x0
    800038b6:	ac8080e7          	jalr	-1336(ra) # 8000337a <check_pending_signals>
    acquire(&p->lock);
    800038ba:	8526                	mv	a0,s1
    800038bc:	ffffd097          	auipc	ra,0xffffd
    800038c0:	30a080e7          	jalr	778(ra) # 80000bc6 <acquire>
    p->handling_sig_flag = 0;
    800038c4:	2804a223          	sw	zero,644(s1)
    800038c8:	b70d                	j	800037ea <usertrap+0x8e>
    kthread_exit(-1); // Kill current thread
    800038ca:	557d                	li	a0,-1
    800038cc:	fffff097          	auipc	ra,0xfffff
    800038d0:	ea4080e7          	jalr	-348(ra) # 80002770 <kthread_exit>
    800038d4:	b73d                	j	80003802 <usertrap+0xa6>
    exit(-1); // Kill the hole procces
    800038d6:	557d                	li	a0,-1
    800038d8:	fffff097          	auipc	ra,0xfffff
    800038dc:	f2c080e7          	jalr	-212(ra) # 80002804 <exit>
    800038e0:	b70d                	j	80003802 <usertrap+0xa6>

00000000800038e2 <kerneltrap>:
{
    800038e2:	7179                	addi	sp,sp,-48
    800038e4:	f406                	sd	ra,40(sp)
    800038e6:	f022                	sd	s0,32(sp)
    800038e8:	ec26                	sd	s1,24(sp)
    800038ea:	e84a                	sd	s2,16(sp)
    800038ec:	e44e                	sd	s3,8(sp)
    800038ee:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800038f0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800038f4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800038f8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800038fc:	1004f793          	andi	a5,s1,256
    80003900:	cb85                	beqz	a5,80003930 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003902:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003906:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80003908:	ef85                	bnez	a5,80003940 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000390a:	00000097          	auipc	ra,0x0
    8000390e:	db0080e7          	jalr	-592(ra) # 800036ba <devintr>
    80003912:	cd1d                	beqz	a0,80003950 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    80003914:	4789                	li	a5,2
    80003916:	08f50763          	beq	a0,a5,800039a4 <kerneltrap+0xc2>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000391a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000391e:	10049073          	csrw	sstatus,s1
}
    80003922:	70a2                	ld	ra,40(sp)
    80003924:	7402                	ld	s0,32(sp)
    80003926:	64e2                	ld	s1,24(sp)
    80003928:	6942                	ld	s2,16(sp)
    8000392a:	69a2                	ld	s3,8(sp)
    8000392c:	6145                	addi	sp,sp,48
    8000392e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003930:	00006517          	auipc	a0,0x6
    80003934:	d4850513          	addi	a0,a0,-696 # 80009678 <states.0+0x168>
    80003938:	ffffd097          	auipc	ra,0xffffd
    8000393c:	bf6080e7          	jalr	-1034(ra) # 8000052e <panic>
    panic("kerneltrap: interrupts enabled");
    80003940:	00006517          	auipc	a0,0x6
    80003944:	d6050513          	addi	a0,a0,-672 # 800096a0 <states.0+0x190>
    80003948:	ffffd097          	auipc	ra,0xffffd
    8000394c:	be6080e7          	jalr	-1050(ra) # 8000052e <panic>
    printf("thread %d recieved kernel trap\n",mykthread()->tid);
    80003950:	ffffe097          	auipc	ra,0xffffe
    80003954:	160080e7          	jalr	352(ra) # 80001ab0 <mykthread>
    80003958:	590c                	lw	a1,48(a0)
    8000395a:	00006517          	auipc	a0,0x6
    8000395e:	d6650513          	addi	a0,a0,-666 # 800096c0 <states.0+0x1b0>
    80003962:	ffffd097          	auipc	ra,0xffffd
    80003966:	c16080e7          	jalr	-1002(ra) # 80000578 <printf>
    printf("scause %p\n", scause);
    8000396a:	85ce                	mv	a1,s3
    8000396c:	00006517          	auipc	a0,0x6
    80003970:	d7450513          	addi	a0,a0,-652 # 800096e0 <states.0+0x1d0>
    80003974:	ffffd097          	auipc	ra,0xffffd
    80003978:	c04080e7          	jalr	-1020(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000397c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003980:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003984:	00006517          	auipc	a0,0x6
    80003988:	d6c50513          	addi	a0,a0,-660 # 800096f0 <states.0+0x1e0>
    8000398c:	ffffd097          	auipc	ra,0xffffd
    80003990:	bec080e7          	jalr	-1044(ra) # 80000578 <printf>
    panic("kerneltrap");
    80003994:	00006517          	auipc	a0,0x6
    80003998:	d7450513          	addi	a0,a0,-652 # 80009708 <states.0+0x1f8>
    8000399c:	ffffd097          	auipc	ra,0xffffd
    800039a0:	b92080e7          	jalr	-1134(ra) # 8000052e <panic>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    800039a4:	ffffe097          	auipc	ra,0xffffe
    800039a8:	0cc080e7          	jalr	204(ra) # 80001a70 <myproc>
    800039ac:	d53d                	beqz	a0,8000391a <kerneltrap+0x38>
    800039ae:	ffffe097          	auipc	ra,0xffffe
    800039b2:	102080e7          	jalr	258(ra) # 80001ab0 <mykthread>
    800039b6:	d135                	beqz	a0,8000391a <kerneltrap+0x38>
    800039b8:	ffffe097          	auipc	ra,0xffffe
    800039bc:	0f8080e7          	jalr	248(ra) # 80001ab0 <mykthread>
    800039c0:	4d18                	lw	a4,24(a0)
    800039c2:	4791                	li	a5,4
    800039c4:	f4f71be3          	bne	a4,a5,8000391a <kerneltrap+0x38>
    yield();
    800039c8:	fffff097          	auipc	ra,0xfffff
    800039cc:	9e6080e7          	jalr	-1562(ra) # 800023ae <yield>
    800039d0:	b7a9                	j	8000391a <kerneltrap+0x38>

00000000800039d2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800039d2:	1101                	addi	sp,sp,-32
    800039d4:	ec06                	sd	ra,24(sp)
    800039d6:	e822                	sd	s0,16(sp)
    800039d8:	e426                	sd	s1,8(sp)
    800039da:	1000                	addi	s0,sp,32
    800039dc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800039de:	ffffe097          	auipc	ra,0xffffe
    800039e2:	092080e7          	jalr	146(ra) # 80001a70 <myproc>
  struct kthread *t = mykthread();
    800039e6:	ffffe097          	auipc	ra,0xffffe
    800039ea:	0ca080e7          	jalr	202(ra) # 80001ab0 <mykthread>
  switch (n) {
    800039ee:	4795                	li	a5,5
    800039f0:	0497e163          	bltu	a5,s1,80003a32 <argraw+0x60>
    800039f4:	048a                	slli	s1,s1,0x2
    800039f6:	00006717          	auipc	a4,0x6
    800039fa:	d4a70713          	addi	a4,a4,-694 # 80009740 <states.0+0x230>
    800039fe:	94ba                	add	s1,s1,a4
    80003a00:	409c                	lw	a5,0(s1)
    80003a02:	97ba                	add	a5,a5,a4
    80003a04:	8782                	jr	a5
  case 0:
    return t->trapframe->a0;
    80003a06:	613c                	ld	a5,64(a0)
    80003a08:	7ba8                	ld	a0,112(a5)
  case 5:
    return t->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003a0a:	60e2                	ld	ra,24(sp)
    80003a0c:	6442                	ld	s0,16(sp)
    80003a0e:	64a2                	ld	s1,8(sp)
    80003a10:	6105                	addi	sp,sp,32
    80003a12:	8082                	ret
    return t->trapframe->a1;
    80003a14:	613c                	ld	a5,64(a0)
    80003a16:	7fa8                	ld	a0,120(a5)
    80003a18:	bfcd                	j	80003a0a <argraw+0x38>
    return t->trapframe->a2;
    80003a1a:	613c                	ld	a5,64(a0)
    80003a1c:	63c8                	ld	a0,128(a5)
    80003a1e:	b7f5                	j	80003a0a <argraw+0x38>
    return t->trapframe->a3;
    80003a20:	613c                	ld	a5,64(a0)
    80003a22:	67c8                	ld	a0,136(a5)
    80003a24:	b7dd                	j	80003a0a <argraw+0x38>
    return t->trapframe->a4;
    80003a26:	613c                	ld	a5,64(a0)
    80003a28:	6bc8                	ld	a0,144(a5)
    80003a2a:	b7c5                	j	80003a0a <argraw+0x38>
    return t->trapframe->a5;
    80003a2c:	613c                	ld	a5,64(a0)
    80003a2e:	6fc8                	ld	a0,152(a5)
    80003a30:	bfe9                	j	80003a0a <argraw+0x38>
  panic("argraw");
    80003a32:	00006517          	auipc	a0,0x6
    80003a36:	ce650513          	addi	a0,a0,-794 # 80009718 <states.0+0x208>
    80003a3a:	ffffd097          	auipc	ra,0xffffd
    80003a3e:	af4080e7          	jalr	-1292(ra) # 8000052e <panic>

0000000080003a42 <fetchaddr>:
{
    80003a42:	1101                	addi	sp,sp,-32
    80003a44:	ec06                	sd	ra,24(sp)
    80003a46:	e822                	sd	s0,16(sp)
    80003a48:	e426                	sd	s1,8(sp)
    80003a4a:	e04a                	sd	s2,0(sp)
    80003a4c:	1000                	addi	s0,sp,32
    80003a4e:	84aa                	mv	s1,a0
    80003a50:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003a52:	ffffe097          	auipc	ra,0xffffe
    80003a56:	01e080e7          	jalr	30(ra) # 80001a70 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003a5a:	7d1c                	ld	a5,56(a0)
    80003a5c:	02f4f863          	bgeu	s1,a5,80003a8c <fetchaddr+0x4a>
    80003a60:	00848713          	addi	a4,s1,8
    80003a64:	02e7e663          	bltu	a5,a4,80003a90 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003a68:	46a1                	li	a3,8
    80003a6a:	8626                	mv	a2,s1
    80003a6c:	85ca                	mv	a1,s2
    80003a6e:	6128                	ld	a0,64(a0)
    80003a70:	ffffe097          	auipc	ra,0xffffe
    80003a74:	c74080e7          	jalr	-908(ra) # 800016e4 <copyin>
    80003a78:	00a03533          	snez	a0,a0
    80003a7c:	40a00533          	neg	a0,a0
}
    80003a80:	60e2                	ld	ra,24(sp)
    80003a82:	6442                	ld	s0,16(sp)
    80003a84:	64a2                	ld	s1,8(sp)
    80003a86:	6902                	ld	s2,0(sp)
    80003a88:	6105                	addi	sp,sp,32
    80003a8a:	8082                	ret
    return -1;
    80003a8c:	557d                	li	a0,-1
    80003a8e:	bfcd                	j	80003a80 <fetchaddr+0x3e>
    80003a90:	557d                	li	a0,-1
    80003a92:	b7fd                	j	80003a80 <fetchaddr+0x3e>

0000000080003a94 <fetchstr>:
{
    80003a94:	7179                	addi	sp,sp,-48
    80003a96:	f406                	sd	ra,40(sp)
    80003a98:	f022                	sd	s0,32(sp)
    80003a9a:	ec26                	sd	s1,24(sp)
    80003a9c:	e84a                	sd	s2,16(sp)
    80003a9e:	e44e                	sd	s3,8(sp)
    80003aa0:	1800                	addi	s0,sp,48
    80003aa2:	892a                	mv	s2,a0
    80003aa4:	84ae                	mv	s1,a1
    80003aa6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003aa8:	ffffe097          	auipc	ra,0xffffe
    80003aac:	fc8080e7          	jalr	-56(ra) # 80001a70 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003ab0:	86ce                	mv	a3,s3
    80003ab2:	864a                	mv	a2,s2
    80003ab4:	85a6                	mv	a1,s1
    80003ab6:	6128                	ld	a0,64(a0)
    80003ab8:	ffffe097          	auipc	ra,0xffffe
    80003abc:	cba080e7          	jalr	-838(ra) # 80001772 <copyinstr>
  if(err < 0)
    80003ac0:	00054763          	bltz	a0,80003ace <fetchstr+0x3a>
  return strlen(buf);
    80003ac4:	8526                	mv	a0,s1
    80003ac6:	ffffd097          	auipc	ra,0xffffd
    80003aca:	396080e7          	jalr	918(ra) # 80000e5c <strlen>
}
    80003ace:	70a2                	ld	ra,40(sp)
    80003ad0:	7402                	ld	s0,32(sp)
    80003ad2:	64e2                	ld	s1,24(sp)
    80003ad4:	6942                	ld	s2,16(sp)
    80003ad6:	69a2                	ld	s3,8(sp)
    80003ad8:	6145                	addi	sp,sp,48
    80003ada:	8082                	ret

0000000080003adc <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003adc:	1101                	addi	sp,sp,-32
    80003ade:	ec06                	sd	ra,24(sp)
    80003ae0:	e822                	sd	s0,16(sp)
    80003ae2:	e426                	sd	s1,8(sp)
    80003ae4:	1000                	addi	s0,sp,32
    80003ae6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003ae8:	00000097          	auipc	ra,0x0
    80003aec:	eea080e7          	jalr	-278(ra) # 800039d2 <argraw>
    80003af0:	c088                	sw	a0,0(s1)
  return 0;
}
    80003af2:	4501                	li	a0,0
    80003af4:	60e2                	ld	ra,24(sp)
    80003af6:	6442                	ld	s0,16(sp)
    80003af8:	64a2                	ld	s1,8(sp)
    80003afa:	6105                	addi	sp,sp,32
    80003afc:	8082                	ret

0000000080003afe <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003afe:	1101                	addi	sp,sp,-32
    80003b00:	ec06                	sd	ra,24(sp)
    80003b02:	e822                	sd	s0,16(sp)
    80003b04:	e426                	sd	s1,8(sp)
    80003b06:	1000                	addi	s0,sp,32
    80003b08:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003b0a:	00000097          	auipc	ra,0x0
    80003b0e:	ec8080e7          	jalr	-312(ra) # 800039d2 <argraw>
    80003b12:	e088                	sd	a0,0(s1)
  return 0;
}
    80003b14:	4501                	li	a0,0
    80003b16:	60e2                	ld	ra,24(sp)
    80003b18:	6442                	ld	s0,16(sp)
    80003b1a:	64a2                	ld	s1,8(sp)
    80003b1c:	6105                	addi	sp,sp,32
    80003b1e:	8082                	ret

0000000080003b20 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003b20:	1101                	addi	sp,sp,-32
    80003b22:	ec06                	sd	ra,24(sp)
    80003b24:	e822                	sd	s0,16(sp)
    80003b26:	e426                	sd	s1,8(sp)
    80003b28:	e04a                	sd	s2,0(sp)
    80003b2a:	1000                	addi	s0,sp,32
    80003b2c:	84ae                	mv	s1,a1
    80003b2e:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003b30:	00000097          	auipc	ra,0x0
    80003b34:	ea2080e7          	jalr	-350(ra) # 800039d2 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003b38:	864a                	mv	a2,s2
    80003b3a:	85a6                	mv	a1,s1
    80003b3c:	00000097          	auipc	ra,0x0
    80003b40:	f58080e7          	jalr	-168(ra) # 80003a94 <fetchstr>
}
    80003b44:	60e2                	ld	ra,24(sp)
    80003b46:	6442                	ld	s0,16(sp)
    80003b48:	64a2                	ld	s1,8(sp)
    80003b4a:	6902                	ld	s2,0(sp)
    80003b4c:	6105                	addi	sp,sp,32
    80003b4e:	8082                	ret

0000000080003b50 <syscall>:
[SYS_kthread_join] sys_kthread_join,
};

void
syscall(void)
{
    80003b50:	7179                	addi	sp,sp,-48
    80003b52:	f406                	sd	ra,40(sp)
    80003b54:	f022                	sd	s0,32(sp)
    80003b56:	ec26                	sd	s1,24(sp)
    80003b58:	e84a                	sd	s2,16(sp)
    80003b5a:	e44e                	sd	s3,8(sp)
    80003b5c:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80003b5e:	ffffe097          	auipc	ra,0xffffe
    80003b62:	f12080e7          	jalr	-238(ra) # 80001a70 <myproc>
    80003b66:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80003b68:	ffffe097          	auipc	ra,0xffffe
    80003b6c:	f48080e7          	jalr	-184(ra) # 80001ab0 <mykthread>
    80003b70:	84aa                	mv	s1,a0

  num = t->trapframe->a7;
    80003b72:	04053983          	ld	s3,64(a0)
    80003b76:	0a89b783          	ld	a5,168(s3)
    80003b7a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003b7e:	37fd                	addiw	a5,a5,-1
    80003b80:	476d                	li	a4,27
    80003b82:	00f76f63          	bltu	a4,a5,80003ba0 <syscall+0x50>
    80003b86:	00369713          	slli	a4,a3,0x3
    80003b8a:	00006797          	auipc	a5,0x6
    80003b8e:	bce78793          	addi	a5,a5,-1074 # 80009758 <syscalls>
    80003b92:	97ba                	add	a5,a5,a4
    80003b94:	639c                	ld	a5,0(a5)
    80003b96:	c789                	beqz	a5,80003ba0 <syscall+0x50>
    t->trapframe->a0 = syscalls[num]();
    80003b98:	9782                	jalr	a5
    80003b9a:	06a9b823          	sd	a0,112(s3)
    80003b9e:	a005                	j	80003bbe <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003ba0:	0d890613          	addi	a2,s2,216
    80003ba4:	02492583          	lw	a1,36(s2)
    80003ba8:	00006517          	auipc	a0,0x6
    80003bac:	b7850513          	addi	a0,a0,-1160 # 80009720 <states.0+0x210>
    80003bb0:	ffffd097          	auipc	ra,0xffffd
    80003bb4:	9c8080e7          	jalr	-1592(ra) # 80000578 <printf>
            p->pid, p->name, num);
    t->trapframe->a0 = -1;
    80003bb8:	60bc                	ld	a5,64(s1)
    80003bba:	577d                	li	a4,-1
    80003bbc:	fbb8                	sd	a4,112(a5)
  }
}
    80003bbe:	70a2                	ld	ra,40(sp)
    80003bc0:	7402                	ld	s0,32(sp)
    80003bc2:	64e2                	ld	s1,24(sp)
    80003bc4:	6942                	ld	s2,16(sp)
    80003bc6:	69a2                	ld	s3,8(sp)
    80003bc8:	6145                	addi	sp,sp,48
    80003bca:	8082                	ret

0000000080003bcc <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003bcc:	1101                	addi	sp,sp,-32
    80003bce:	ec06                	sd	ra,24(sp)
    80003bd0:	e822                	sd	s0,16(sp)
    80003bd2:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003bd4:	fec40593          	addi	a1,s0,-20
    80003bd8:	4501                	li	a0,0
    80003bda:	00000097          	auipc	ra,0x0
    80003bde:	f02080e7          	jalr	-254(ra) # 80003adc <argint>
    return -1;
    80003be2:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003be4:	00054963          	bltz	a0,80003bf6 <sys_exit+0x2a>
  exit(n);
    80003be8:	fec42503          	lw	a0,-20(s0)
    80003bec:	fffff097          	auipc	ra,0xfffff
    80003bf0:	c18080e7          	jalr	-1000(ra) # 80002804 <exit>
  return 0;  // not reached
    80003bf4:	4781                	li	a5,0
}
    80003bf6:	853e                	mv	a0,a5
    80003bf8:	60e2                	ld	ra,24(sp)
    80003bfa:	6442                	ld	s0,16(sp)
    80003bfc:	6105                	addi	sp,sp,32
    80003bfe:	8082                	ret

0000000080003c00 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003c00:	1141                	addi	sp,sp,-16
    80003c02:	e406                	sd	ra,8(sp)
    80003c04:	e022                	sd	s0,0(sp)
    80003c06:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003c08:	ffffe097          	auipc	ra,0xffffe
    80003c0c:	e68080e7          	jalr	-408(ra) # 80001a70 <myproc>
}
    80003c10:	5148                	lw	a0,36(a0)
    80003c12:	60a2                	ld	ra,8(sp)
    80003c14:	6402                	ld	s0,0(sp)
    80003c16:	0141                	addi	sp,sp,16
    80003c18:	8082                	ret

0000000080003c1a <sys_fork>:

uint64
sys_fork(void)
{
    80003c1a:	1141                	addi	sp,sp,-16
    80003c1c:	e406                	sd	ra,8(sp)
    80003c1e:	e022                	sd	s0,0(sp)
    80003c20:	0800                	addi	s0,sp,16
  return fork();
    80003c22:	ffffe097          	auipc	ra,0xffffe
    80003c26:	404080e7          	jalr	1028(ra) # 80002026 <fork>
}
    80003c2a:	60a2                	ld	ra,8(sp)
    80003c2c:	6402                	ld	s0,0(sp)
    80003c2e:	0141                	addi	sp,sp,16
    80003c30:	8082                	ret

0000000080003c32 <sys_wait>:

uint64
sys_wait(void)
{
    80003c32:	1101                	addi	sp,sp,-32
    80003c34:	ec06                	sd	ra,24(sp)
    80003c36:	e822                	sd	s0,16(sp)
    80003c38:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003c3a:	fe840593          	addi	a1,s0,-24
    80003c3e:	4501                	li	a0,0
    80003c40:	00000097          	auipc	ra,0x0
    80003c44:	ebe080e7          	jalr	-322(ra) # 80003afe <argaddr>
    80003c48:	87aa                	mv	a5,a0
    return -1;
    80003c4a:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003c4c:	0007c863          	bltz	a5,80003c5c <sys_wait+0x2a>
  return wait(p);
    80003c50:	fe843503          	ld	a0,-24(s0)
    80003c54:	ffffe097          	auipc	ra,0xffffe
    80003c58:	7fa080e7          	jalr	2042(ra) # 8000244e <wait>
}
    80003c5c:	60e2                	ld	ra,24(sp)
    80003c5e:	6442                	ld	s0,16(sp)
    80003c60:	6105                	addi	sp,sp,32
    80003c62:	8082                	ret

0000000080003c64 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003c64:	7179                	addi	sp,sp,-48
    80003c66:	f406                	sd	ra,40(sp)
    80003c68:	f022                	sd	s0,32(sp)
    80003c6a:	ec26                	sd	s1,24(sp)
    80003c6c:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003c6e:	fdc40593          	addi	a1,s0,-36
    80003c72:	4501                	li	a0,0
    80003c74:	00000097          	auipc	ra,0x0
    80003c78:	e68080e7          	jalr	-408(ra) # 80003adc <argint>
    return -1;
    80003c7c:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003c7e:	00054f63          	bltz	a0,80003c9c <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003c82:	ffffe097          	auipc	ra,0xffffe
    80003c86:	dee080e7          	jalr	-530(ra) # 80001a70 <myproc>
    80003c8a:	5d04                	lw	s1,56(a0)
  if(growproc(n) < 0)
    80003c8c:	fdc42503          	lw	a0,-36(s0)
    80003c90:	ffffe097          	auipc	ra,0xffffe
    80003c94:	322080e7          	jalr	802(ra) # 80001fb2 <growproc>
    80003c98:	00054863          	bltz	a0,80003ca8 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003c9c:	8526                	mv	a0,s1
    80003c9e:	70a2                	ld	ra,40(sp)
    80003ca0:	7402                	ld	s0,32(sp)
    80003ca2:	64e2                	ld	s1,24(sp)
    80003ca4:	6145                	addi	sp,sp,48
    80003ca6:	8082                	ret
    return -1;
    80003ca8:	54fd                	li	s1,-1
    80003caa:	bfcd                	j	80003c9c <sys_sbrk+0x38>

0000000080003cac <sys_sleep>:

uint64
sys_sleep(void)
{
    80003cac:	7139                	addi	sp,sp,-64
    80003cae:	fc06                	sd	ra,56(sp)
    80003cb0:	f822                	sd	s0,48(sp)
    80003cb2:	f426                	sd	s1,40(sp)
    80003cb4:	f04a                	sd	s2,32(sp)
    80003cb6:	ec4e                	sd	s3,24(sp)
    80003cb8:	e852                	sd	s4,16(sp)
    80003cba:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003cbc:	fcc40593          	addi	a1,s0,-52
    80003cc0:	4501                	li	a0,0
    80003cc2:	00000097          	auipc	ra,0x0
    80003cc6:	e1a080e7          	jalr	-486(ra) # 80003adc <argint>
    return -1;
    80003cca:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003ccc:	06054763          	bltz	a0,80003d3a <sys_sleep+0x8e>
  acquire(&tickslock);
    80003cd0:	00030517          	auipc	a0,0x30
    80003cd4:	c5850513          	addi	a0,a0,-936 # 80033928 <tickslock>
    80003cd8:	ffffd097          	auipc	ra,0xffffd
    80003cdc:	eee080e7          	jalr	-274(ra) # 80000bc6 <acquire>
  ticks0 = ticks;
    80003ce0:	00006997          	auipc	s3,0x6
    80003ce4:	3549a983          	lw	s3,852(s3) # 8000a034 <ticks>
  while(ticks - ticks0 < n){
    80003ce8:	fcc42783          	lw	a5,-52(s0)
    80003cec:	cf95                	beqz	a5,80003d28 <sys_sleep+0x7c>
    if(myproc()->killed==1){
    80003cee:	4905                	li	s2,1
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003cf0:	00030a17          	auipc	s4,0x30
    80003cf4:	c38a0a13          	addi	s4,s4,-968 # 80033928 <tickslock>
    80003cf8:	00006497          	auipc	s1,0x6
    80003cfc:	33c48493          	addi	s1,s1,828 # 8000a034 <ticks>
    if(myproc()->killed==1){
    80003d00:	ffffe097          	auipc	ra,0xffffe
    80003d04:	d70080e7          	jalr	-656(ra) # 80001a70 <myproc>
    80003d08:	4d5c                	lw	a5,28(a0)
    80003d0a:	05278163          	beq	a5,s2,80003d4c <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    80003d0e:	85d2                	mv	a1,s4
    80003d10:	8526                	mv	a0,s1
    80003d12:	ffffe097          	auipc	ra,0xffffe
    80003d16:	6d8080e7          	jalr	1752(ra) # 800023ea <sleep>
  while(ticks - ticks0 < n){
    80003d1a:	409c                	lw	a5,0(s1)
    80003d1c:	413787bb          	subw	a5,a5,s3
    80003d20:	fcc42703          	lw	a4,-52(s0)
    80003d24:	fce7eee3          	bltu	a5,a4,80003d00 <sys_sleep+0x54>
  }
  release(&tickslock);
    80003d28:	00030517          	auipc	a0,0x30
    80003d2c:	c0050513          	addi	a0,a0,-1024 # 80033928 <tickslock>
    80003d30:	ffffd097          	auipc	ra,0xffffd
    80003d34:	f60080e7          	jalr	-160(ra) # 80000c90 <release>
  return 0;
    80003d38:	4781                	li	a5,0
}
    80003d3a:	853e                	mv	a0,a5
    80003d3c:	70e2                	ld	ra,56(sp)
    80003d3e:	7442                	ld	s0,48(sp)
    80003d40:	74a2                	ld	s1,40(sp)
    80003d42:	7902                	ld	s2,32(sp)
    80003d44:	69e2                	ld	s3,24(sp)
    80003d46:	6a42                	ld	s4,16(sp)
    80003d48:	6121                	addi	sp,sp,64
    80003d4a:	8082                	ret
      release(&tickslock);
    80003d4c:	00030517          	auipc	a0,0x30
    80003d50:	bdc50513          	addi	a0,a0,-1060 # 80033928 <tickslock>
    80003d54:	ffffd097          	auipc	ra,0xffffd
    80003d58:	f3c080e7          	jalr	-196(ra) # 80000c90 <release>
      return -1;
    80003d5c:	57fd                	li	a5,-1
    80003d5e:	bff1                	j	80003d3a <sys_sleep+0x8e>

0000000080003d60 <sys_kill>:

uint64
sys_kill(void)
{
    80003d60:	1101                	addi	sp,sp,-32
    80003d62:	ec06                	sd	ra,24(sp)
    80003d64:	e822                	sd	s0,16(sp)
    80003d66:	1000                	addi	s0,sp,32
  int pid;
  int signum;

  if(argint(0, &pid) < 0)
    80003d68:	fec40593          	addi	a1,s0,-20
    80003d6c:	4501                	li	a0,0
    80003d6e:	00000097          	auipc	ra,0x0
    80003d72:	d6e080e7          	jalr	-658(ra) # 80003adc <argint>
    80003d76:	87aa                	mv	a5,a0
    return -1;
    80003d78:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003d7a:	0207c963          	bltz	a5,80003dac <sys_kill+0x4c>
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003d7e:	fe840593          	addi	a1,s0,-24
    80003d82:	4505                	li	a0,1
    80003d84:	00000097          	auipc	ra,0x0
    80003d88:	d58080e7          	jalr	-680(ra) # 80003adc <argint>
    80003d8c:	02054463          	bltz	a0,80003db4 <sys_kill+0x54>
    80003d90:	fe842583          	lw	a1,-24(s0)
    80003d94:	0005871b          	sext.w	a4,a1
    80003d98:	47fd                	li	a5,31
    return -1;
    80003d9a:	557d                	li	a0,-1
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003d9c:	00e7e863          	bltu	a5,a4,80003dac <sys_kill+0x4c>
  return kill(pid, signum);
    80003da0:	fec42503          	lw	a0,-20(s0)
    80003da4:	fffff097          	auipc	ra,0xfffff
    80003da8:	e98080e7          	jalr	-360(ra) # 80002c3c <kill>
}
    80003dac:	60e2                	ld	ra,24(sp)
    80003dae:	6442                	ld	s0,16(sp)
    80003db0:	6105                	addi	sp,sp,32
    80003db2:	8082                	ret
    return -1;
    80003db4:	557d                	li	a0,-1
    80003db6:	bfdd                	j	80003dac <sys_kill+0x4c>

0000000080003db8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003db8:	1101                	addi	sp,sp,-32
    80003dba:	ec06                	sd	ra,24(sp)
    80003dbc:	e822                	sd	s0,16(sp)
    80003dbe:	e426                	sd	s1,8(sp)
    80003dc0:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003dc2:	00030517          	auipc	a0,0x30
    80003dc6:	b6650513          	addi	a0,a0,-1178 # 80033928 <tickslock>
    80003dca:	ffffd097          	auipc	ra,0xffffd
    80003dce:	dfc080e7          	jalr	-516(ra) # 80000bc6 <acquire>
  xticks = ticks;
    80003dd2:	00006497          	auipc	s1,0x6
    80003dd6:	2624a483          	lw	s1,610(s1) # 8000a034 <ticks>
  release(&tickslock);
    80003dda:	00030517          	auipc	a0,0x30
    80003dde:	b4e50513          	addi	a0,a0,-1202 # 80033928 <tickslock>
    80003de2:	ffffd097          	auipc	ra,0xffffd
    80003de6:	eae080e7          	jalr	-338(ra) # 80000c90 <release>
  return xticks;
}
    80003dea:	02049513          	slli	a0,s1,0x20
    80003dee:	9101                	srli	a0,a0,0x20
    80003df0:	60e2                	ld	ra,24(sp)
    80003df2:	6442                	ld	s0,16(sp)
    80003df4:	64a2                	ld	s1,8(sp)
    80003df6:	6105                	addi	sp,sp,32
    80003df8:	8082                	ret

0000000080003dfa <sys_sigprocmask>:

uint64
sys_sigprocmask(void)
{
    80003dfa:	1101                	addi	sp,sp,-32
    80003dfc:	ec06                	sd	ra,24(sp)
    80003dfe:	e822                	sd	s0,16(sp)
    80003e00:	1000                	addi	s0,sp,32
  int sigmask;

  if(argint(0, &sigmask) < 0)
    80003e02:	fec40593          	addi	a1,s0,-20
    80003e06:	4501                	li	a0,0
    80003e08:	00000097          	auipc	ra,0x0
    80003e0c:	cd4080e7          	jalr	-812(ra) # 80003adc <argint>
    80003e10:	87aa                	mv	a5,a0
    return -1;
    80003e12:	557d                	li	a0,-1
  if(argint(0, &sigmask) < 0)
    80003e14:	0007ca63          	bltz	a5,80003e28 <sys_sigprocmask+0x2e>
  return sigprocmask((uint)sigmask);
    80003e18:	fec42503          	lw	a0,-20(s0)
    80003e1c:	fffff097          	auipc	ra,0xfffff
    80003e20:	c4e080e7          	jalr	-946(ra) # 80002a6a <sigprocmask>
    80003e24:	1502                	slli	a0,a0,0x20
    80003e26:	9101                	srli	a0,a0,0x20
}
    80003e28:	60e2                	ld	ra,24(sp)
    80003e2a:	6442                	ld	s0,16(sp)
    80003e2c:	6105                	addi	sp,sp,32
    80003e2e:	8082                	ret

0000000080003e30 <sys_sigaction>:

uint64
sys_sigaction(void)
{
    80003e30:	7179                	addi	sp,sp,-48
    80003e32:	f406                	sd	ra,40(sp)
    80003e34:	f022                	sd	s0,32(sp)
    80003e36:	1800                	addi	s0,sp,48
  int signum;
  uint64 newact;
  uint64 oldact;
  
  if(argint(0, &signum) < 0)
    80003e38:	fec40593          	addi	a1,s0,-20
    80003e3c:	4501                	li	a0,0
    80003e3e:	00000097          	auipc	ra,0x0
    80003e42:	c9e080e7          	jalr	-866(ra) # 80003adc <argint>
    return -1;
    80003e46:	57fd                	li	a5,-1
  if(argint(0, &signum) < 0)
    80003e48:	04054163          	bltz	a0,80003e8a <sys_sigaction+0x5a>
  if(argaddr(1, &newact) < 0)
    80003e4c:	fe040593          	addi	a1,s0,-32
    80003e50:	4505                	li	a0,1
    80003e52:	00000097          	auipc	ra,0x0
    80003e56:	cac080e7          	jalr	-852(ra) # 80003afe <argaddr>
    return -1;
    80003e5a:	57fd                	li	a5,-1
  if(argaddr(1, &newact) < 0)
    80003e5c:	02054763          	bltz	a0,80003e8a <sys_sigaction+0x5a>
  if(argaddr(2, &oldact) < 0)
    80003e60:	fd840593          	addi	a1,s0,-40
    80003e64:	4509                	li	a0,2
    80003e66:	00000097          	auipc	ra,0x0
    80003e6a:	c98080e7          	jalr	-872(ra) # 80003afe <argaddr>
    return -1;
    80003e6e:	57fd                	li	a5,-1
  if(argaddr(2, &oldact) < 0)
    80003e70:	00054d63          	bltz	a0,80003e8a <sys_sigaction+0x5a>

  return sigaction(signum,newact,oldact);
    80003e74:	fd843603          	ld	a2,-40(s0)
    80003e78:	fe043583          	ld	a1,-32(s0)
    80003e7c:	fec42503          	lw	a0,-20(s0)
    80003e80:	fffff097          	auipc	ra,0xfffff
    80003e84:	c3e080e7          	jalr	-962(ra) # 80002abe <sigaction>
    80003e88:	87aa                	mv	a5,a0
  
}
    80003e8a:	853e                	mv	a0,a5
    80003e8c:	70a2                	ld	ra,40(sp)
    80003e8e:	7402                	ld	s0,32(sp)
    80003e90:	6145                	addi	sp,sp,48
    80003e92:	8082                	ret

0000000080003e94 <sys_sigret>:
uint64
sys_sigret(void)
{
    80003e94:	1141                	addi	sp,sp,-16
    80003e96:	e406                	sd	ra,8(sp)
    80003e98:	e022                	sd	s0,0(sp)
    80003e9a:	0800                	addi	s0,sp,16
  sigret();
    80003e9c:	fffff097          	auipc	ra,0xfffff
    80003ea0:	d0c080e7          	jalr	-756(ra) # 80002ba8 <sigret>
  return 0;
}
    80003ea4:	4501                	li	a0,0
    80003ea6:	60a2                	ld	ra,8(sp)
    80003ea8:	6402                	ld	s0,0(sp)
    80003eaa:	0141                	addi	sp,sp,16
    80003eac:	8082                	ret

0000000080003eae <sys_kthread_create>:

uint64
sys_kthread_create(void)
{
    80003eae:	1101                	addi	sp,sp,-32
    80003eb0:	ec06                	sd	ra,24(sp)
    80003eb2:	e822                	sd	s0,16(sp)
    80003eb4:	1000                	addi	s0,sp,32
  uint64 start_func;
  uint64 stack;
  if(argaddr(0, &start_func) < 0)
    80003eb6:	fe840593          	addi	a1,s0,-24
    80003eba:	4501                	li	a0,0
    80003ebc:	00000097          	auipc	ra,0x0
    80003ec0:	c42080e7          	jalr	-958(ra) # 80003afe <argaddr>
    80003ec4:	02054463          	bltz	a0,80003eec <sys_kthread_create+0x3e>
    return -1;
  if(argaddr(1, &stack) < 0)
    80003ec8:	fe040593          	addi	a1,s0,-32
    80003ecc:	4505                	li	a0,1
    80003ece:	00000097          	auipc	ra,0x0
    80003ed2:	c30080e7          	jalr	-976(ra) # 80003afe <argaddr>
    80003ed6:	00054b63          	bltz	a0,80003eec <sys_kthread_create+0x3e>
    return -1;
  kthread_create(start_func,stack);
    80003eda:	fe043583          	ld	a1,-32(s0)
    80003ede:	fe843503          	ld	a0,-24(s0)
    80003ee2:	fffff097          	auipc	ra,0xfffff
    80003ee6:	e92080e7          	jalr	-366(ra) # 80002d74 <kthread_create>
}
    80003eea:	a011                	j	80003eee <sys_kthread_create+0x40>
    80003eec:	557d                	li	a0,-1
    80003eee:	60e2                	ld	ra,24(sp)
    80003ef0:	6442                	ld	s0,16(sp)
    80003ef2:	6105                	addi	sp,sp,32
    80003ef4:	8082                	ret

0000000080003ef6 <sys_kthread_id>:

uint64
sys_kthread_id(void){
    80003ef6:	1141                	addi	sp,sp,-16
    80003ef8:	e406                	sd	ra,8(sp)
    80003efa:	e022                	sd	s0,0(sp)
    80003efc:	0800                	addi	s0,sp,16
  return mykthread()->tid;
    80003efe:	ffffe097          	auipc	ra,0xffffe
    80003f02:	bb2080e7          	jalr	-1102(ra) # 80001ab0 <mykthread>
}
    80003f06:	5908                	lw	a0,48(a0)
    80003f08:	60a2                	ld	ra,8(sp)
    80003f0a:	6402                	ld	s0,0(sp)
    80003f0c:	0141                	addi	sp,sp,16
    80003f0e:	8082                	ret

0000000080003f10 <sys_kthread_exit>:

uint64
sys_kthread_exit(void){
    80003f10:	1101                	addi	sp,sp,-32
    80003f12:	ec06                	sd	ra,24(sp)
    80003f14:	e822                	sd	s0,16(sp)
    80003f16:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003f18:	fec40593          	addi	a1,s0,-20
    80003f1c:	4501                	li	a0,0
    80003f1e:	00000097          	auipc	ra,0x0
    80003f22:	bbe080e7          	jalr	-1090(ra) # 80003adc <argint>
    return -1;
    80003f26:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003f28:	00054963          	bltz	a0,80003f3a <sys_kthread_exit+0x2a>
  exit(n);
    80003f2c:	fec42503          	lw	a0,-20(s0)
    80003f30:	fffff097          	auipc	ra,0xfffff
    80003f34:	8d4080e7          	jalr	-1836(ra) # 80002804 <exit>
  
  return 0;  // not reached
    80003f38:	4781                	li	a5,0
}
    80003f3a:	853e                	mv	a0,a5
    80003f3c:	60e2                	ld	ra,24(sp)
    80003f3e:	6442                	ld	s0,16(sp)
    80003f40:	6105                	addi	sp,sp,32
    80003f42:	8082                	ret

0000000080003f44 <sys_kthread_join>:

uint64 
sys_kthread_join(){
    80003f44:	1101                	addi	sp,sp,-32
    80003f46:	ec06                	sd	ra,24(sp)
    80003f48:	e822                	sd	s0,16(sp)
    80003f4a:	1000                	addi	s0,sp,32
  int thread_id;
  uint64 status;
  if(argint(0, &thread_id) < 0)
    80003f4c:	fec40593          	addi	a1,s0,-20
    80003f50:	4501                	li	a0,0
    80003f52:	00000097          	auipc	ra,0x0
    80003f56:	b8a080e7          	jalr	-1142(ra) # 80003adc <argint>
    return -1;
    80003f5a:	57fd                	li	a5,-1
  if(argint(0, &thread_id) < 0)
    80003f5c:	02054563          	bltz	a0,80003f86 <sys_kthread_join+0x42>
  if(argaddr(1, &status) < 0)
    80003f60:	fe040593          	addi	a1,s0,-32
    80003f64:	4505                	li	a0,1
    80003f66:	00000097          	auipc	ra,0x0
    80003f6a:	b98080e7          	jalr	-1128(ra) # 80003afe <argaddr>
    return -1;
    80003f6e:	57fd                	li	a5,-1
  if(argaddr(1, &status) < 0)
    80003f70:	00054b63          	bltz	a0,80003f86 <sys_kthread_join+0x42>
  int ans=kthread_join(thread_id, status);
  printf("in function to lishlof args\n");
    80003f74:	fe043583          	ld	a1,-32(s0)
    80003f78:	fec42503          	lw	a0,-20(s0)
    80003f7c:	fffff097          	auipc	ra,0xfffff
    80003f80:	f18080e7          	jalr	-232(ra) # 80002e94 <kthread_join>
    80003f84:	87aa                	mv	a5,a0
  return ans;
    80003f86:	853e                	mv	a0,a5
    80003f88:	60e2                	ld	ra,24(sp)
    80003f8a:	6442                	ld	s0,16(sp)
    80003f8c:	6105                	addi	sp,sp,32
    80003f8e:	8082                	ret

0000000080003f90 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003f90:	7179                	addi	sp,sp,-48
    80003f92:	f406                	sd	ra,40(sp)
    80003f94:	f022                	sd	s0,32(sp)
    80003f96:	ec26                	sd	s1,24(sp)
    80003f98:	e84a                	sd	s2,16(sp)
    80003f9a:	e44e                	sd	s3,8(sp)
    80003f9c:	e052                	sd	s4,0(sp)
    80003f9e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003fa0:	00006597          	auipc	a1,0x6
    80003fa4:	8a058593          	addi	a1,a1,-1888 # 80009840 <syscalls+0xe8>
    80003fa8:	00030517          	auipc	a0,0x30
    80003fac:	99850513          	addi	a0,a0,-1640 # 80033940 <bcache>
    80003fb0:	ffffd097          	auipc	ra,0xffffd
    80003fb4:	b86080e7          	jalr	-1146(ra) # 80000b36 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003fb8:	00038797          	auipc	a5,0x38
    80003fbc:	98878793          	addi	a5,a5,-1656 # 8003b940 <bcache+0x8000>
    80003fc0:	00038717          	auipc	a4,0x38
    80003fc4:	be870713          	addi	a4,a4,-1048 # 8003bba8 <bcache+0x8268>
    80003fc8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003fcc:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003fd0:	00030497          	auipc	s1,0x30
    80003fd4:	98848493          	addi	s1,s1,-1656 # 80033958 <bcache+0x18>
    b->next = bcache.head.next;
    80003fd8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003fda:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003fdc:	00006a17          	auipc	s4,0x6
    80003fe0:	86ca0a13          	addi	s4,s4,-1940 # 80009848 <syscalls+0xf0>
    b->next = bcache.head.next;
    80003fe4:	2b893783          	ld	a5,696(s2)
    80003fe8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003fea:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003fee:	85d2                	mv	a1,s4
    80003ff0:	01048513          	addi	a0,s1,16
    80003ff4:	00001097          	auipc	ra,0x1
    80003ff8:	4c0080e7          	jalr	1216(ra) # 800054b4 <initsleeplock>
    bcache.head.next->prev = b;
    80003ffc:	2b893783          	ld	a5,696(s2)
    80004000:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80004002:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80004006:	45848493          	addi	s1,s1,1112
    8000400a:	fd349de3          	bne	s1,s3,80003fe4 <binit+0x54>
  }
}
    8000400e:	70a2                	ld	ra,40(sp)
    80004010:	7402                	ld	s0,32(sp)
    80004012:	64e2                	ld	s1,24(sp)
    80004014:	6942                	ld	s2,16(sp)
    80004016:	69a2                	ld	s3,8(sp)
    80004018:	6a02                	ld	s4,0(sp)
    8000401a:	6145                	addi	sp,sp,48
    8000401c:	8082                	ret

000000008000401e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000401e:	7179                	addi	sp,sp,-48
    80004020:	f406                	sd	ra,40(sp)
    80004022:	f022                	sd	s0,32(sp)
    80004024:	ec26                	sd	s1,24(sp)
    80004026:	e84a                	sd	s2,16(sp)
    80004028:	e44e                	sd	s3,8(sp)
    8000402a:	1800                	addi	s0,sp,48
    8000402c:	892a                	mv	s2,a0
    8000402e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80004030:	00030517          	auipc	a0,0x30
    80004034:	91050513          	addi	a0,a0,-1776 # 80033940 <bcache>
    80004038:	ffffd097          	auipc	ra,0xffffd
    8000403c:	b8e080e7          	jalr	-1138(ra) # 80000bc6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80004040:	00038497          	auipc	s1,0x38
    80004044:	bb84b483          	ld	s1,-1096(s1) # 8003bbf8 <bcache+0x82b8>
    80004048:	00038797          	auipc	a5,0x38
    8000404c:	b6078793          	addi	a5,a5,-1184 # 8003bba8 <bcache+0x8268>
    80004050:	02f48f63          	beq	s1,a5,8000408e <bread+0x70>
    80004054:	873e                	mv	a4,a5
    80004056:	a021                	j	8000405e <bread+0x40>
    80004058:	68a4                	ld	s1,80(s1)
    8000405a:	02e48a63          	beq	s1,a4,8000408e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000405e:	449c                	lw	a5,8(s1)
    80004060:	ff279ce3          	bne	a5,s2,80004058 <bread+0x3a>
    80004064:	44dc                	lw	a5,12(s1)
    80004066:	ff3799e3          	bne	a5,s3,80004058 <bread+0x3a>
      b->refcnt++;
    8000406a:	40bc                	lw	a5,64(s1)
    8000406c:	2785                	addiw	a5,a5,1
    8000406e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80004070:	00030517          	auipc	a0,0x30
    80004074:	8d050513          	addi	a0,a0,-1840 # 80033940 <bcache>
    80004078:	ffffd097          	auipc	ra,0xffffd
    8000407c:	c18080e7          	jalr	-1000(ra) # 80000c90 <release>
      acquiresleep(&b->lock);
    80004080:	01048513          	addi	a0,s1,16
    80004084:	00001097          	auipc	ra,0x1
    80004088:	46a080e7          	jalr	1130(ra) # 800054ee <acquiresleep>
      return b;
    8000408c:	a8b9                	j	800040ea <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000408e:	00038497          	auipc	s1,0x38
    80004092:	b624b483          	ld	s1,-1182(s1) # 8003bbf0 <bcache+0x82b0>
    80004096:	00038797          	auipc	a5,0x38
    8000409a:	b1278793          	addi	a5,a5,-1262 # 8003bba8 <bcache+0x8268>
    8000409e:	00f48863          	beq	s1,a5,800040ae <bread+0x90>
    800040a2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800040a4:	40bc                	lw	a5,64(s1)
    800040a6:	cf81                	beqz	a5,800040be <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800040a8:	64a4                	ld	s1,72(s1)
    800040aa:	fee49de3          	bne	s1,a4,800040a4 <bread+0x86>
  panic("bget: no buffers");
    800040ae:	00005517          	auipc	a0,0x5
    800040b2:	7a250513          	addi	a0,a0,1954 # 80009850 <syscalls+0xf8>
    800040b6:	ffffc097          	auipc	ra,0xffffc
    800040ba:	478080e7          	jalr	1144(ra) # 8000052e <panic>
      b->dev = dev;
    800040be:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800040c2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800040c6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800040ca:	4785                	li	a5,1
    800040cc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800040ce:	00030517          	auipc	a0,0x30
    800040d2:	87250513          	addi	a0,a0,-1934 # 80033940 <bcache>
    800040d6:	ffffd097          	auipc	ra,0xffffd
    800040da:	bba080e7          	jalr	-1094(ra) # 80000c90 <release>
      acquiresleep(&b->lock);
    800040de:	01048513          	addi	a0,s1,16
    800040e2:	00001097          	auipc	ra,0x1
    800040e6:	40c080e7          	jalr	1036(ra) # 800054ee <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800040ea:	409c                	lw	a5,0(s1)
    800040ec:	cb89                	beqz	a5,800040fe <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800040ee:	8526                	mv	a0,s1
    800040f0:	70a2                	ld	ra,40(sp)
    800040f2:	7402                	ld	s0,32(sp)
    800040f4:	64e2                	ld	s1,24(sp)
    800040f6:	6942                	ld	s2,16(sp)
    800040f8:	69a2                	ld	s3,8(sp)
    800040fa:	6145                	addi	sp,sp,48
    800040fc:	8082                	ret
    virtio_disk_rw(b, 0);
    800040fe:	4581                	li	a1,0
    80004100:	8526                	mv	a0,s1
    80004102:	00003097          	auipc	ra,0x3
    80004106:	fc4080e7          	jalr	-60(ra) # 800070c6 <virtio_disk_rw>
    b->valid = 1;
    8000410a:	4785                	li	a5,1
    8000410c:	c09c                	sw	a5,0(s1)
  return b;
    8000410e:	b7c5                	j	800040ee <bread+0xd0>

0000000080004110 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80004110:	1101                	addi	sp,sp,-32
    80004112:	ec06                	sd	ra,24(sp)
    80004114:	e822                	sd	s0,16(sp)
    80004116:	e426                	sd	s1,8(sp)
    80004118:	1000                	addi	s0,sp,32
    8000411a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000411c:	0541                	addi	a0,a0,16
    8000411e:	00001097          	auipc	ra,0x1
    80004122:	46a080e7          	jalr	1130(ra) # 80005588 <holdingsleep>
    80004126:	cd01                	beqz	a0,8000413e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80004128:	4585                	li	a1,1
    8000412a:	8526                	mv	a0,s1
    8000412c:	00003097          	auipc	ra,0x3
    80004130:	f9a080e7          	jalr	-102(ra) # 800070c6 <virtio_disk_rw>
}
    80004134:	60e2                	ld	ra,24(sp)
    80004136:	6442                	ld	s0,16(sp)
    80004138:	64a2                	ld	s1,8(sp)
    8000413a:	6105                	addi	sp,sp,32
    8000413c:	8082                	ret
    panic("bwrite");
    8000413e:	00005517          	auipc	a0,0x5
    80004142:	72a50513          	addi	a0,a0,1834 # 80009868 <syscalls+0x110>
    80004146:	ffffc097          	auipc	ra,0xffffc
    8000414a:	3e8080e7          	jalr	1000(ra) # 8000052e <panic>

000000008000414e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000414e:	1101                	addi	sp,sp,-32
    80004150:	ec06                	sd	ra,24(sp)
    80004152:	e822                	sd	s0,16(sp)
    80004154:	e426                	sd	s1,8(sp)
    80004156:	e04a                	sd	s2,0(sp)
    80004158:	1000                	addi	s0,sp,32
    8000415a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000415c:	01050913          	addi	s2,a0,16
    80004160:	854a                	mv	a0,s2
    80004162:	00001097          	auipc	ra,0x1
    80004166:	426080e7          	jalr	1062(ra) # 80005588 <holdingsleep>
    8000416a:	c92d                	beqz	a0,800041dc <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000416c:	854a                	mv	a0,s2
    8000416e:	00001097          	auipc	ra,0x1
    80004172:	3d6080e7          	jalr	982(ra) # 80005544 <releasesleep>

  acquire(&bcache.lock);
    80004176:	0002f517          	auipc	a0,0x2f
    8000417a:	7ca50513          	addi	a0,a0,1994 # 80033940 <bcache>
    8000417e:	ffffd097          	auipc	ra,0xffffd
    80004182:	a48080e7          	jalr	-1464(ra) # 80000bc6 <acquire>
  b->refcnt--;
    80004186:	40bc                	lw	a5,64(s1)
    80004188:	37fd                	addiw	a5,a5,-1
    8000418a:	0007871b          	sext.w	a4,a5
    8000418e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80004190:	eb05                	bnez	a4,800041c0 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80004192:	68bc                	ld	a5,80(s1)
    80004194:	64b8                	ld	a4,72(s1)
    80004196:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80004198:	64bc                	ld	a5,72(s1)
    8000419a:	68b8                	ld	a4,80(s1)
    8000419c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000419e:	00037797          	auipc	a5,0x37
    800041a2:	7a278793          	addi	a5,a5,1954 # 8003b940 <bcache+0x8000>
    800041a6:	2b87b703          	ld	a4,696(a5)
    800041aa:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800041ac:	00038717          	auipc	a4,0x38
    800041b0:	9fc70713          	addi	a4,a4,-1540 # 8003bba8 <bcache+0x8268>
    800041b4:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800041b6:	2b87b703          	ld	a4,696(a5)
    800041ba:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800041bc:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800041c0:	0002f517          	auipc	a0,0x2f
    800041c4:	78050513          	addi	a0,a0,1920 # 80033940 <bcache>
    800041c8:	ffffd097          	auipc	ra,0xffffd
    800041cc:	ac8080e7          	jalr	-1336(ra) # 80000c90 <release>
}
    800041d0:	60e2                	ld	ra,24(sp)
    800041d2:	6442                	ld	s0,16(sp)
    800041d4:	64a2                	ld	s1,8(sp)
    800041d6:	6902                	ld	s2,0(sp)
    800041d8:	6105                	addi	sp,sp,32
    800041da:	8082                	ret
    panic("brelse");
    800041dc:	00005517          	auipc	a0,0x5
    800041e0:	69450513          	addi	a0,a0,1684 # 80009870 <syscalls+0x118>
    800041e4:	ffffc097          	auipc	ra,0xffffc
    800041e8:	34a080e7          	jalr	842(ra) # 8000052e <panic>

00000000800041ec <bpin>:

void
bpin(struct buf *b) {
    800041ec:	1101                	addi	sp,sp,-32
    800041ee:	ec06                	sd	ra,24(sp)
    800041f0:	e822                	sd	s0,16(sp)
    800041f2:	e426                	sd	s1,8(sp)
    800041f4:	1000                	addi	s0,sp,32
    800041f6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800041f8:	0002f517          	auipc	a0,0x2f
    800041fc:	74850513          	addi	a0,a0,1864 # 80033940 <bcache>
    80004200:	ffffd097          	auipc	ra,0xffffd
    80004204:	9c6080e7          	jalr	-1594(ra) # 80000bc6 <acquire>
  b->refcnt++;
    80004208:	40bc                	lw	a5,64(s1)
    8000420a:	2785                	addiw	a5,a5,1
    8000420c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000420e:	0002f517          	auipc	a0,0x2f
    80004212:	73250513          	addi	a0,a0,1842 # 80033940 <bcache>
    80004216:	ffffd097          	auipc	ra,0xffffd
    8000421a:	a7a080e7          	jalr	-1414(ra) # 80000c90 <release>
}
    8000421e:	60e2                	ld	ra,24(sp)
    80004220:	6442                	ld	s0,16(sp)
    80004222:	64a2                	ld	s1,8(sp)
    80004224:	6105                	addi	sp,sp,32
    80004226:	8082                	ret

0000000080004228 <bunpin>:

void
bunpin(struct buf *b) {
    80004228:	1101                	addi	sp,sp,-32
    8000422a:	ec06                	sd	ra,24(sp)
    8000422c:	e822                	sd	s0,16(sp)
    8000422e:	e426                	sd	s1,8(sp)
    80004230:	1000                	addi	s0,sp,32
    80004232:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004234:	0002f517          	auipc	a0,0x2f
    80004238:	70c50513          	addi	a0,a0,1804 # 80033940 <bcache>
    8000423c:	ffffd097          	auipc	ra,0xffffd
    80004240:	98a080e7          	jalr	-1654(ra) # 80000bc6 <acquire>
  b->refcnt--;
    80004244:	40bc                	lw	a5,64(s1)
    80004246:	37fd                	addiw	a5,a5,-1
    80004248:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000424a:	0002f517          	auipc	a0,0x2f
    8000424e:	6f650513          	addi	a0,a0,1782 # 80033940 <bcache>
    80004252:	ffffd097          	auipc	ra,0xffffd
    80004256:	a3e080e7          	jalr	-1474(ra) # 80000c90 <release>
}
    8000425a:	60e2                	ld	ra,24(sp)
    8000425c:	6442                	ld	s0,16(sp)
    8000425e:	64a2                	ld	s1,8(sp)
    80004260:	6105                	addi	sp,sp,32
    80004262:	8082                	ret

0000000080004264 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80004264:	1101                	addi	sp,sp,-32
    80004266:	ec06                	sd	ra,24(sp)
    80004268:	e822                	sd	s0,16(sp)
    8000426a:	e426                	sd	s1,8(sp)
    8000426c:	e04a                	sd	s2,0(sp)
    8000426e:	1000                	addi	s0,sp,32
    80004270:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80004272:	00d5d59b          	srliw	a1,a1,0xd
    80004276:	00038797          	auipc	a5,0x38
    8000427a:	da67a783          	lw	a5,-602(a5) # 8003c01c <sb+0x1c>
    8000427e:	9dbd                	addw	a1,a1,a5
    80004280:	00000097          	auipc	ra,0x0
    80004284:	d9e080e7          	jalr	-610(ra) # 8000401e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80004288:	0074f713          	andi	a4,s1,7
    8000428c:	4785                	li	a5,1
    8000428e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80004292:	14ce                	slli	s1,s1,0x33
    80004294:	90d9                	srli	s1,s1,0x36
    80004296:	00950733          	add	a4,a0,s1
    8000429a:	05874703          	lbu	a4,88(a4)
    8000429e:	00e7f6b3          	and	a3,a5,a4
    800042a2:	c69d                	beqz	a3,800042d0 <bfree+0x6c>
    800042a4:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800042a6:	94aa                	add	s1,s1,a0
    800042a8:	fff7c793          	not	a5,a5
    800042ac:	8ff9                	and	a5,a5,a4
    800042ae:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800042b2:	00001097          	auipc	ra,0x1
    800042b6:	11c080e7          	jalr	284(ra) # 800053ce <log_write>
  brelse(bp);
    800042ba:	854a                	mv	a0,s2
    800042bc:	00000097          	auipc	ra,0x0
    800042c0:	e92080e7          	jalr	-366(ra) # 8000414e <brelse>
}
    800042c4:	60e2                	ld	ra,24(sp)
    800042c6:	6442                	ld	s0,16(sp)
    800042c8:	64a2                	ld	s1,8(sp)
    800042ca:	6902                	ld	s2,0(sp)
    800042cc:	6105                	addi	sp,sp,32
    800042ce:	8082                	ret
    panic("freeing free block");
    800042d0:	00005517          	auipc	a0,0x5
    800042d4:	5a850513          	addi	a0,a0,1448 # 80009878 <syscalls+0x120>
    800042d8:	ffffc097          	auipc	ra,0xffffc
    800042dc:	256080e7          	jalr	598(ra) # 8000052e <panic>

00000000800042e0 <balloc>:
{
    800042e0:	711d                	addi	sp,sp,-96
    800042e2:	ec86                	sd	ra,88(sp)
    800042e4:	e8a2                	sd	s0,80(sp)
    800042e6:	e4a6                	sd	s1,72(sp)
    800042e8:	e0ca                	sd	s2,64(sp)
    800042ea:	fc4e                	sd	s3,56(sp)
    800042ec:	f852                	sd	s4,48(sp)
    800042ee:	f456                	sd	s5,40(sp)
    800042f0:	f05a                	sd	s6,32(sp)
    800042f2:	ec5e                	sd	s7,24(sp)
    800042f4:	e862                	sd	s8,16(sp)
    800042f6:	e466                	sd	s9,8(sp)
    800042f8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800042fa:	00038797          	auipc	a5,0x38
    800042fe:	d0a7a783          	lw	a5,-758(a5) # 8003c004 <sb+0x4>
    80004302:	cbd1                	beqz	a5,80004396 <balloc+0xb6>
    80004304:	8baa                	mv	s7,a0
    80004306:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80004308:	00038b17          	auipc	s6,0x38
    8000430c:	cf8b0b13          	addi	s6,s6,-776 # 8003c000 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004310:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80004312:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004314:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80004316:	6c89                	lui	s9,0x2
    80004318:	a831                	j	80004334 <balloc+0x54>
    brelse(bp);
    8000431a:	854a                	mv	a0,s2
    8000431c:	00000097          	auipc	ra,0x0
    80004320:	e32080e7          	jalr	-462(ra) # 8000414e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80004324:	015c87bb          	addw	a5,s9,s5
    80004328:	00078a9b          	sext.w	s5,a5
    8000432c:	004b2703          	lw	a4,4(s6)
    80004330:	06eaf363          	bgeu	s5,a4,80004396 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80004334:	41fad79b          	sraiw	a5,s5,0x1f
    80004338:	0137d79b          	srliw	a5,a5,0x13
    8000433c:	015787bb          	addw	a5,a5,s5
    80004340:	40d7d79b          	sraiw	a5,a5,0xd
    80004344:	01cb2583          	lw	a1,28(s6)
    80004348:	9dbd                	addw	a1,a1,a5
    8000434a:	855e                	mv	a0,s7
    8000434c:	00000097          	auipc	ra,0x0
    80004350:	cd2080e7          	jalr	-814(ra) # 8000401e <bread>
    80004354:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004356:	004b2503          	lw	a0,4(s6)
    8000435a:	000a849b          	sext.w	s1,s5
    8000435e:	8662                	mv	a2,s8
    80004360:	faa4fde3          	bgeu	s1,a0,8000431a <balloc+0x3a>
      m = 1 << (bi % 8);
    80004364:	41f6579b          	sraiw	a5,a2,0x1f
    80004368:	01d7d69b          	srliw	a3,a5,0x1d
    8000436c:	00c6873b          	addw	a4,a3,a2
    80004370:	00777793          	andi	a5,a4,7
    80004374:	9f95                	subw	a5,a5,a3
    80004376:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000437a:	4037571b          	sraiw	a4,a4,0x3
    8000437e:	00e906b3          	add	a3,s2,a4
    80004382:	0586c683          	lbu	a3,88(a3)
    80004386:	00d7f5b3          	and	a1,a5,a3
    8000438a:	cd91                	beqz	a1,800043a6 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000438c:	2605                	addiw	a2,a2,1
    8000438e:	2485                	addiw	s1,s1,1
    80004390:	fd4618e3          	bne	a2,s4,80004360 <balloc+0x80>
    80004394:	b759                	j	8000431a <balloc+0x3a>
  panic("balloc: out of blocks");
    80004396:	00005517          	auipc	a0,0x5
    8000439a:	4fa50513          	addi	a0,a0,1274 # 80009890 <syscalls+0x138>
    8000439e:	ffffc097          	auipc	ra,0xffffc
    800043a2:	190080e7          	jalr	400(ra) # 8000052e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800043a6:	974a                	add	a4,a4,s2
    800043a8:	8fd5                	or	a5,a5,a3
    800043aa:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800043ae:	854a                	mv	a0,s2
    800043b0:	00001097          	auipc	ra,0x1
    800043b4:	01e080e7          	jalr	30(ra) # 800053ce <log_write>
        brelse(bp);
    800043b8:	854a                	mv	a0,s2
    800043ba:	00000097          	auipc	ra,0x0
    800043be:	d94080e7          	jalr	-620(ra) # 8000414e <brelse>
  bp = bread(dev, bno);
    800043c2:	85a6                	mv	a1,s1
    800043c4:	855e                	mv	a0,s7
    800043c6:	00000097          	auipc	ra,0x0
    800043ca:	c58080e7          	jalr	-936(ra) # 8000401e <bread>
    800043ce:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800043d0:	40000613          	li	a2,1024
    800043d4:	4581                	li	a1,0
    800043d6:	05850513          	addi	a0,a0,88
    800043da:	ffffd097          	auipc	ra,0xffffd
    800043de:	8fe080e7          	jalr	-1794(ra) # 80000cd8 <memset>
  log_write(bp);
    800043e2:	854a                	mv	a0,s2
    800043e4:	00001097          	auipc	ra,0x1
    800043e8:	fea080e7          	jalr	-22(ra) # 800053ce <log_write>
  brelse(bp);
    800043ec:	854a                	mv	a0,s2
    800043ee:	00000097          	auipc	ra,0x0
    800043f2:	d60080e7          	jalr	-672(ra) # 8000414e <brelse>
}
    800043f6:	8526                	mv	a0,s1
    800043f8:	60e6                	ld	ra,88(sp)
    800043fa:	6446                	ld	s0,80(sp)
    800043fc:	64a6                	ld	s1,72(sp)
    800043fe:	6906                	ld	s2,64(sp)
    80004400:	79e2                	ld	s3,56(sp)
    80004402:	7a42                	ld	s4,48(sp)
    80004404:	7aa2                	ld	s5,40(sp)
    80004406:	7b02                	ld	s6,32(sp)
    80004408:	6be2                	ld	s7,24(sp)
    8000440a:	6c42                	ld	s8,16(sp)
    8000440c:	6ca2                	ld	s9,8(sp)
    8000440e:	6125                	addi	sp,sp,96
    80004410:	8082                	ret

0000000080004412 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80004412:	7179                	addi	sp,sp,-48
    80004414:	f406                	sd	ra,40(sp)
    80004416:	f022                	sd	s0,32(sp)
    80004418:	ec26                	sd	s1,24(sp)
    8000441a:	e84a                	sd	s2,16(sp)
    8000441c:	e44e                	sd	s3,8(sp)
    8000441e:	e052                	sd	s4,0(sp)
    80004420:	1800                	addi	s0,sp,48
    80004422:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80004424:	47ad                	li	a5,11
    80004426:	04b7fe63          	bgeu	a5,a1,80004482 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000442a:	ff45849b          	addiw	s1,a1,-12
    8000442e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80004432:	0ff00793          	li	a5,255
    80004436:	0ae7e463          	bltu	a5,a4,800044de <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000443a:	08052583          	lw	a1,128(a0)
    8000443e:	c5b5                	beqz	a1,800044aa <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80004440:	00092503          	lw	a0,0(s2)
    80004444:	00000097          	auipc	ra,0x0
    80004448:	bda080e7          	jalr	-1062(ra) # 8000401e <bread>
    8000444c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000444e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80004452:	02049713          	slli	a4,s1,0x20
    80004456:	01e75593          	srli	a1,a4,0x1e
    8000445a:	00b784b3          	add	s1,a5,a1
    8000445e:	0004a983          	lw	s3,0(s1)
    80004462:	04098e63          	beqz	s3,800044be <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80004466:	8552                	mv	a0,s4
    80004468:	00000097          	auipc	ra,0x0
    8000446c:	ce6080e7          	jalr	-794(ra) # 8000414e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80004470:	854e                	mv	a0,s3
    80004472:	70a2                	ld	ra,40(sp)
    80004474:	7402                	ld	s0,32(sp)
    80004476:	64e2                	ld	s1,24(sp)
    80004478:	6942                	ld	s2,16(sp)
    8000447a:	69a2                	ld	s3,8(sp)
    8000447c:	6a02                	ld	s4,0(sp)
    8000447e:	6145                	addi	sp,sp,48
    80004480:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80004482:	02059793          	slli	a5,a1,0x20
    80004486:	01e7d593          	srli	a1,a5,0x1e
    8000448a:	00b504b3          	add	s1,a0,a1
    8000448e:	0504a983          	lw	s3,80(s1)
    80004492:	fc099fe3          	bnez	s3,80004470 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80004496:	4108                	lw	a0,0(a0)
    80004498:	00000097          	auipc	ra,0x0
    8000449c:	e48080e7          	jalr	-440(ra) # 800042e0 <balloc>
    800044a0:	0005099b          	sext.w	s3,a0
    800044a4:	0534a823          	sw	s3,80(s1)
    800044a8:	b7e1                	j	80004470 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800044aa:	4108                	lw	a0,0(a0)
    800044ac:	00000097          	auipc	ra,0x0
    800044b0:	e34080e7          	jalr	-460(ra) # 800042e0 <balloc>
    800044b4:	0005059b          	sext.w	a1,a0
    800044b8:	08b92023          	sw	a1,128(s2)
    800044bc:	b751                	j	80004440 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800044be:	00092503          	lw	a0,0(s2)
    800044c2:	00000097          	auipc	ra,0x0
    800044c6:	e1e080e7          	jalr	-482(ra) # 800042e0 <balloc>
    800044ca:	0005099b          	sext.w	s3,a0
    800044ce:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800044d2:	8552                	mv	a0,s4
    800044d4:	00001097          	auipc	ra,0x1
    800044d8:	efa080e7          	jalr	-262(ra) # 800053ce <log_write>
    800044dc:	b769                	j	80004466 <bmap+0x54>
  panic("bmap: out of range");
    800044de:	00005517          	auipc	a0,0x5
    800044e2:	3ca50513          	addi	a0,a0,970 # 800098a8 <syscalls+0x150>
    800044e6:	ffffc097          	auipc	ra,0xffffc
    800044ea:	048080e7          	jalr	72(ra) # 8000052e <panic>

00000000800044ee <iget>:
{
    800044ee:	7179                	addi	sp,sp,-48
    800044f0:	f406                	sd	ra,40(sp)
    800044f2:	f022                	sd	s0,32(sp)
    800044f4:	ec26                	sd	s1,24(sp)
    800044f6:	e84a                	sd	s2,16(sp)
    800044f8:	e44e                	sd	s3,8(sp)
    800044fa:	e052                	sd	s4,0(sp)
    800044fc:	1800                	addi	s0,sp,48
    800044fe:	89aa                	mv	s3,a0
    80004500:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80004502:	00038517          	auipc	a0,0x38
    80004506:	b1e50513          	addi	a0,a0,-1250 # 8003c020 <itable>
    8000450a:	ffffc097          	auipc	ra,0xffffc
    8000450e:	6bc080e7          	jalr	1724(ra) # 80000bc6 <acquire>
  empty = 0;
    80004512:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004514:	00038497          	auipc	s1,0x38
    80004518:	b2448493          	addi	s1,s1,-1244 # 8003c038 <itable+0x18>
    8000451c:	00039697          	auipc	a3,0x39
    80004520:	5ac68693          	addi	a3,a3,1452 # 8003dac8 <log>
    80004524:	a039                	j	80004532 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004526:	02090b63          	beqz	s2,8000455c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000452a:	08848493          	addi	s1,s1,136
    8000452e:	02d48a63          	beq	s1,a3,80004562 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80004532:	449c                	lw	a5,8(s1)
    80004534:	fef059e3          	blez	a5,80004526 <iget+0x38>
    80004538:	4098                	lw	a4,0(s1)
    8000453a:	ff3716e3          	bne	a4,s3,80004526 <iget+0x38>
    8000453e:	40d8                	lw	a4,4(s1)
    80004540:	ff4713e3          	bne	a4,s4,80004526 <iget+0x38>
      ip->ref++;
    80004544:	2785                	addiw	a5,a5,1
    80004546:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80004548:	00038517          	auipc	a0,0x38
    8000454c:	ad850513          	addi	a0,a0,-1320 # 8003c020 <itable>
    80004550:	ffffc097          	auipc	ra,0xffffc
    80004554:	740080e7          	jalr	1856(ra) # 80000c90 <release>
      return ip;
    80004558:	8926                	mv	s2,s1
    8000455a:	a03d                	j	80004588 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000455c:	f7f9                	bnez	a5,8000452a <iget+0x3c>
    8000455e:	8926                	mv	s2,s1
    80004560:	b7e9                	j	8000452a <iget+0x3c>
  if(empty == 0)
    80004562:	02090c63          	beqz	s2,8000459a <iget+0xac>
  ip->dev = dev;
    80004566:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000456a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000456e:	4785                	li	a5,1
    80004570:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80004574:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80004578:	00038517          	auipc	a0,0x38
    8000457c:	aa850513          	addi	a0,a0,-1368 # 8003c020 <itable>
    80004580:	ffffc097          	auipc	ra,0xffffc
    80004584:	710080e7          	jalr	1808(ra) # 80000c90 <release>
}
    80004588:	854a                	mv	a0,s2
    8000458a:	70a2                	ld	ra,40(sp)
    8000458c:	7402                	ld	s0,32(sp)
    8000458e:	64e2                	ld	s1,24(sp)
    80004590:	6942                	ld	s2,16(sp)
    80004592:	69a2                	ld	s3,8(sp)
    80004594:	6a02                	ld	s4,0(sp)
    80004596:	6145                	addi	sp,sp,48
    80004598:	8082                	ret
    panic("iget: no inodes");
    8000459a:	00005517          	auipc	a0,0x5
    8000459e:	32650513          	addi	a0,a0,806 # 800098c0 <syscalls+0x168>
    800045a2:	ffffc097          	auipc	ra,0xffffc
    800045a6:	f8c080e7          	jalr	-116(ra) # 8000052e <panic>

00000000800045aa <fsinit>:
fsinit(int dev) {
    800045aa:	7179                	addi	sp,sp,-48
    800045ac:	f406                	sd	ra,40(sp)
    800045ae:	f022                	sd	s0,32(sp)
    800045b0:	ec26                	sd	s1,24(sp)
    800045b2:	e84a                	sd	s2,16(sp)
    800045b4:	e44e                	sd	s3,8(sp)
    800045b6:	1800                	addi	s0,sp,48
    800045b8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800045ba:	4585                	li	a1,1
    800045bc:	00000097          	auipc	ra,0x0
    800045c0:	a62080e7          	jalr	-1438(ra) # 8000401e <bread>
    800045c4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800045c6:	00038997          	auipc	s3,0x38
    800045ca:	a3a98993          	addi	s3,s3,-1478 # 8003c000 <sb>
    800045ce:	02000613          	li	a2,32
    800045d2:	05850593          	addi	a1,a0,88
    800045d6:	854e                	mv	a0,s3
    800045d8:	ffffc097          	auipc	ra,0xffffc
    800045dc:	75c080e7          	jalr	1884(ra) # 80000d34 <memmove>
  brelse(bp);
    800045e0:	8526                	mv	a0,s1
    800045e2:	00000097          	auipc	ra,0x0
    800045e6:	b6c080e7          	jalr	-1172(ra) # 8000414e <brelse>
  if(sb.magic != FSMAGIC)
    800045ea:	0009a703          	lw	a4,0(s3)
    800045ee:	102037b7          	lui	a5,0x10203
    800045f2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800045f6:	02f71263          	bne	a4,a5,8000461a <fsinit+0x70>
  initlog(dev, &sb);
    800045fa:	00038597          	auipc	a1,0x38
    800045fe:	a0658593          	addi	a1,a1,-1530 # 8003c000 <sb>
    80004602:	854a                	mv	a0,s2
    80004604:	00001097          	auipc	ra,0x1
    80004608:	b4c080e7          	jalr	-1204(ra) # 80005150 <initlog>
}
    8000460c:	70a2                	ld	ra,40(sp)
    8000460e:	7402                	ld	s0,32(sp)
    80004610:	64e2                	ld	s1,24(sp)
    80004612:	6942                	ld	s2,16(sp)
    80004614:	69a2                	ld	s3,8(sp)
    80004616:	6145                	addi	sp,sp,48
    80004618:	8082                	ret
    panic("invalid file system");
    8000461a:	00005517          	auipc	a0,0x5
    8000461e:	2b650513          	addi	a0,a0,694 # 800098d0 <syscalls+0x178>
    80004622:	ffffc097          	auipc	ra,0xffffc
    80004626:	f0c080e7          	jalr	-244(ra) # 8000052e <panic>

000000008000462a <iinit>:
{
    8000462a:	7179                	addi	sp,sp,-48
    8000462c:	f406                	sd	ra,40(sp)
    8000462e:	f022                	sd	s0,32(sp)
    80004630:	ec26                	sd	s1,24(sp)
    80004632:	e84a                	sd	s2,16(sp)
    80004634:	e44e                	sd	s3,8(sp)
    80004636:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80004638:	00005597          	auipc	a1,0x5
    8000463c:	2b058593          	addi	a1,a1,688 # 800098e8 <syscalls+0x190>
    80004640:	00038517          	auipc	a0,0x38
    80004644:	9e050513          	addi	a0,a0,-1568 # 8003c020 <itable>
    80004648:	ffffc097          	auipc	ra,0xffffc
    8000464c:	4ee080e7          	jalr	1262(ra) # 80000b36 <initlock>
  for(i = 0; i < NINODE; i++) {
    80004650:	00038497          	auipc	s1,0x38
    80004654:	9f848493          	addi	s1,s1,-1544 # 8003c048 <itable+0x28>
    80004658:	00039997          	auipc	s3,0x39
    8000465c:	48098993          	addi	s3,s3,1152 # 8003dad8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004660:	00005917          	auipc	s2,0x5
    80004664:	29090913          	addi	s2,s2,656 # 800098f0 <syscalls+0x198>
    80004668:	85ca                	mv	a1,s2
    8000466a:	8526                	mv	a0,s1
    8000466c:	00001097          	auipc	ra,0x1
    80004670:	e48080e7          	jalr	-440(ra) # 800054b4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004674:	08848493          	addi	s1,s1,136
    80004678:	ff3498e3          	bne	s1,s3,80004668 <iinit+0x3e>
}
    8000467c:	70a2                	ld	ra,40(sp)
    8000467e:	7402                	ld	s0,32(sp)
    80004680:	64e2                	ld	s1,24(sp)
    80004682:	6942                	ld	s2,16(sp)
    80004684:	69a2                	ld	s3,8(sp)
    80004686:	6145                	addi	sp,sp,48
    80004688:	8082                	ret

000000008000468a <ialloc>:
{
    8000468a:	715d                	addi	sp,sp,-80
    8000468c:	e486                	sd	ra,72(sp)
    8000468e:	e0a2                	sd	s0,64(sp)
    80004690:	fc26                	sd	s1,56(sp)
    80004692:	f84a                	sd	s2,48(sp)
    80004694:	f44e                	sd	s3,40(sp)
    80004696:	f052                	sd	s4,32(sp)
    80004698:	ec56                	sd	s5,24(sp)
    8000469a:	e85a                	sd	s6,16(sp)
    8000469c:	e45e                	sd	s7,8(sp)
    8000469e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800046a0:	00038717          	auipc	a4,0x38
    800046a4:	96c72703          	lw	a4,-1684(a4) # 8003c00c <sb+0xc>
    800046a8:	4785                	li	a5,1
    800046aa:	04e7fa63          	bgeu	a5,a4,800046fe <ialloc+0x74>
    800046ae:	8aaa                	mv	s5,a0
    800046b0:	8bae                	mv	s7,a1
    800046b2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800046b4:	00038a17          	auipc	s4,0x38
    800046b8:	94ca0a13          	addi	s4,s4,-1716 # 8003c000 <sb>
    800046bc:	00048b1b          	sext.w	s6,s1
    800046c0:	0044d793          	srli	a5,s1,0x4
    800046c4:	018a2583          	lw	a1,24(s4)
    800046c8:	9dbd                	addw	a1,a1,a5
    800046ca:	8556                	mv	a0,s5
    800046cc:	00000097          	auipc	ra,0x0
    800046d0:	952080e7          	jalr	-1710(ra) # 8000401e <bread>
    800046d4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800046d6:	05850993          	addi	s3,a0,88
    800046da:	00f4f793          	andi	a5,s1,15
    800046de:	079a                	slli	a5,a5,0x6
    800046e0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800046e2:	00099783          	lh	a5,0(s3)
    800046e6:	c785                	beqz	a5,8000470e <ialloc+0x84>
    brelse(bp);
    800046e8:	00000097          	auipc	ra,0x0
    800046ec:	a66080e7          	jalr	-1434(ra) # 8000414e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800046f0:	0485                	addi	s1,s1,1
    800046f2:	00ca2703          	lw	a4,12(s4)
    800046f6:	0004879b          	sext.w	a5,s1
    800046fa:	fce7e1e3          	bltu	a5,a4,800046bc <ialloc+0x32>
  panic("ialloc: no inodes");
    800046fe:	00005517          	auipc	a0,0x5
    80004702:	1fa50513          	addi	a0,a0,506 # 800098f8 <syscalls+0x1a0>
    80004706:	ffffc097          	auipc	ra,0xffffc
    8000470a:	e28080e7          	jalr	-472(ra) # 8000052e <panic>
      memset(dip, 0, sizeof(*dip));
    8000470e:	04000613          	li	a2,64
    80004712:	4581                	li	a1,0
    80004714:	854e                	mv	a0,s3
    80004716:	ffffc097          	auipc	ra,0xffffc
    8000471a:	5c2080e7          	jalr	1474(ra) # 80000cd8 <memset>
      dip->type = type;
    8000471e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004722:	854a                	mv	a0,s2
    80004724:	00001097          	auipc	ra,0x1
    80004728:	caa080e7          	jalr	-854(ra) # 800053ce <log_write>
      brelse(bp);
    8000472c:	854a                	mv	a0,s2
    8000472e:	00000097          	auipc	ra,0x0
    80004732:	a20080e7          	jalr	-1504(ra) # 8000414e <brelse>
      return iget(dev, inum);
    80004736:	85da                	mv	a1,s6
    80004738:	8556                	mv	a0,s5
    8000473a:	00000097          	auipc	ra,0x0
    8000473e:	db4080e7          	jalr	-588(ra) # 800044ee <iget>
}
    80004742:	60a6                	ld	ra,72(sp)
    80004744:	6406                	ld	s0,64(sp)
    80004746:	74e2                	ld	s1,56(sp)
    80004748:	7942                	ld	s2,48(sp)
    8000474a:	79a2                	ld	s3,40(sp)
    8000474c:	7a02                	ld	s4,32(sp)
    8000474e:	6ae2                	ld	s5,24(sp)
    80004750:	6b42                	ld	s6,16(sp)
    80004752:	6ba2                	ld	s7,8(sp)
    80004754:	6161                	addi	sp,sp,80
    80004756:	8082                	ret

0000000080004758 <iupdate>:
{
    80004758:	1101                	addi	sp,sp,-32
    8000475a:	ec06                	sd	ra,24(sp)
    8000475c:	e822                	sd	s0,16(sp)
    8000475e:	e426                	sd	s1,8(sp)
    80004760:	e04a                	sd	s2,0(sp)
    80004762:	1000                	addi	s0,sp,32
    80004764:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004766:	415c                	lw	a5,4(a0)
    80004768:	0047d79b          	srliw	a5,a5,0x4
    8000476c:	00038597          	auipc	a1,0x38
    80004770:	8ac5a583          	lw	a1,-1876(a1) # 8003c018 <sb+0x18>
    80004774:	9dbd                	addw	a1,a1,a5
    80004776:	4108                	lw	a0,0(a0)
    80004778:	00000097          	auipc	ra,0x0
    8000477c:	8a6080e7          	jalr	-1882(ra) # 8000401e <bread>
    80004780:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004782:	05850793          	addi	a5,a0,88
    80004786:	40c8                	lw	a0,4(s1)
    80004788:	893d                	andi	a0,a0,15
    8000478a:	051a                	slli	a0,a0,0x6
    8000478c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000478e:	04449703          	lh	a4,68(s1)
    80004792:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80004796:	04649703          	lh	a4,70(s1)
    8000479a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000479e:	04849703          	lh	a4,72(s1)
    800047a2:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800047a6:	04a49703          	lh	a4,74(s1)
    800047aa:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800047ae:	44f8                	lw	a4,76(s1)
    800047b0:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800047b2:	03400613          	li	a2,52
    800047b6:	05048593          	addi	a1,s1,80
    800047ba:	0531                	addi	a0,a0,12
    800047bc:	ffffc097          	auipc	ra,0xffffc
    800047c0:	578080e7          	jalr	1400(ra) # 80000d34 <memmove>
  log_write(bp);
    800047c4:	854a                	mv	a0,s2
    800047c6:	00001097          	auipc	ra,0x1
    800047ca:	c08080e7          	jalr	-1016(ra) # 800053ce <log_write>
  brelse(bp);
    800047ce:	854a                	mv	a0,s2
    800047d0:	00000097          	auipc	ra,0x0
    800047d4:	97e080e7          	jalr	-1666(ra) # 8000414e <brelse>
}
    800047d8:	60e2                	ld	ra,24(sp)
    800047da:	6442                	ld	s0,16(sp)
    800047dc:	64a2                	ld	s1,8(sp)
    800047de:	6902                	ld	s2,0(sp)
    800047e0:	6105                	addi	sp,sp,32
    800047e2:	8082                	ret

00000000800047e4 <idup>:
{
    800047e4:	1101                	addi	sp,sp,-32
    800047e6:	ec06                	sd	ra,24(sp)
    800047e8:	e822                	sd	s0,16(sp)
    800047ea:	e426                	sd	s1,8(sp)
    800047ec:	1000                	addi	s0,sp,32
    800047ee:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800047f0:	00038517          	auipc	a0,0x38
    800047f4:	83050513          	addi	a0,a0,-2000 # 8003c020 <itable>
    800047f8:	ffffc097          	auipc	ra,0xffffc
    800047fc:	3ce080e7          	jalr	974(ra) # 80000bc6 <acquire>
  ip->ref++;
    80004800:	449c                	lw	a5,8(s1)
    80004802:	2785                	addiw	a5,a5,1
    80004804:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004806:	00038517          	auipc	a0,0x38
    8000480a:	81a50513          	addi	a0,a0,-2022 # 8003c020 <itable>
    8000480e:	ffffc097          	auipc	ra,0xffffc
    80004812:	482080e7          	jalr	1154(ra) # 80000c90 <release>
}
    80004816:	8526                	mv	a0,s1
    80004818:	60e2                	ld	ra,24(sp)
    8000481a:	6442                	ld	s0,16(sp)
    8000481c:	64a2                	ld	s1,8(sp)
    8000481e:	6105                	addi	sp,sp,32
    80004820:	8082                	ret

0000000080004822 <ilock>:
{
    80004822:	1101                	addi	sp,sp,-32
    80004824:	ec06                	sd	ra,24(sp)
    80004826:	e822                	sd	s0,16(sp)
    80004828:	e426                	sd	s1,8(sp)
    8000482a:	e04a                	sd	s2,0(sp)
    8000482c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000482e:	c115                	beqz	a0,80004852 <ilock+0x30>
    80004830:	84aa                	mv	s1,a0
    80004832:	451c                	lw	a5,8(a0)
    80004834:	00f05f63          	blez	a5,80004852 <ilock+0x30>
  acquiresleep(&ip->lock);
    80004838:	0541                	addi	a0,a0,16
    8000483a:	00001097          	auipc	ra,0x1
    8000483e:	cb4080e7          	jalr	-844(ra) # 800054ee <acquiresleep>
  if(ip->valid == 0){
    80004842:	40bc                	lw	a5,64(s1)
    80004844:	cf99                	beqz	a5,80004862 <ilock+0x40>
}
    80004846:	60e2                	ld	ra,24(sp)
    80004848:	6442                	ld	s0,16(sp)
    8000484a:	64a2                	ld	s1,8(sp)
    8000484c:	6902                	ld	s2,0(sp)
    8000484e:	6105                	addi	sp,sp,32
    80004850:	8082                	ret
    panic("ilock");
    80004852:	00005517          	auipc	a0,0x5
    80004856:	0be50513          	addi	a0,a0,190 # 80009910 <syscalls+0x1b8>
    8000485a:	ffffc097          	auipc	ra,0xffffc
    8000485e:	cd4080e7          	jalr	-812(ra) # 8000052e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004862:	40dc                	lw	a5,4(s1)
    80004864:	0047d79b          	srliw	a5,a5,0x4
    80004868:	00037597          	auipc	a1,0x37
    8000486c:	7b05a583          	lw	a1,1968(a1) # 8003c018 <sb+0x18>
    80004870:	9dbd                	addw	a1,a1,a5
    80004872:	4088                	lw	a0,0(s1)
    80004874:	fffff097          	auipc	ra,0xfffff
    80004878:	7aa080e7          	jalr	1962(ra) # 8000401e <bread>
    8000487c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000487e:	05850593          	addi	a1,a0,88
    80004882:	40dc                	lw	a5,4(s1)
    80004884:	8bbd                	andi	a5,a5,15
    80004886:	079a                	slli	a5,a5,0x6
    80004888:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000488a:	00059783          	lh	a5,0(a1)
    8000488e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004892:	00259783          	lh	a5,2(a1)
    80004896:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000489a:	00459783          	lh	a5,4(a1)
    8000489e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800048a2:	00659783          	lh	a5,6(a1)
    800048a6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800048aa:	459c                	lw	a5,8(a1)
    800048ac:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800048ae:	03400613          	li	a2,52
    800048b2:	05b1                	addi	a1,a1,12
    800048b4:	05048513          	addi	a0,s1,80
    800048b8:	ffffc097          	auipc	ra,0xffffc
    800048bc:	47c080e7          	jalr	1148(ra) # 80000d34 <memmove>
    brelse(bp);
    800048c0:	854a                	mv	a0,s2
    800048c2:	00000097          	auipc	ra,0x0
    800048c6:	88c080e7          	jalr	-1908(ra) # 8000414e <brelse>
    ip->valid = 1;
    800048ca:	4785                	li	a5,1
    800048cc:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800048ce:	04449783          	lh	a5,68(s1)
    800048d2:	fbb5                	bnez	a5,80004846 <ilock+0x24>
      panic("ilock: no type");
    800048d4:	00005517          	auipc	a0,0x5
    800048d8:	04450513          	addi	a0,a0,68 # 80009918 <syscalls+0x1c0>
    800048dc:	ffffc097          	auipc	ra,0xffffc
    800048e0:	c52080e7          	jalr	-942(ra) # 8000052e <panic>

00000000800048e4 <iunlock>:
{
    800048e4:	1101                	addi	sp,sp,-32
    800048e6:	ec06                	sd	ra,24(sp)
    800048e8:	e822                	sd	s0,16(sp)
    800048ea:	e426                	sd	s1,8(sp)
    800048ec:	e04a                	sd	s2,0(sp)
    800048ee:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800048f0:	c905                	beqz	a0,80004920 <iunlock+0x3c>
    800048f2:	84aa                	mv	s1,a0
    800048f4:	01050913          	addi	s2,a0,16
    800048f8:	854a                	mv	a0,s2
    800048fa:	00001097          	auipc	ra,0x1
    800048fe:	c8e080e7          	jalr	-882(ra) # 80005588 <holdingsleep>
    80004902:	cd19                	beqz	a0,80004920 <iunlock+0x3c>
    80004904:	449c                	lw	a5,8(s1)
    80004906:	00f05d63          	blez	a5,80004920 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000490a:	854a                	mv	a0,s2
    8000490c:	00001097          	auipc	ra,0x1
    80004910:	c38080e7          	jalr	-968(ra) # 80005544 <releasesleep>
}
    80004914:	60e2                	ld	ra,24(sp)
    80004916:	6442                	ld	s0,16(sp)
    80004918:	64a2                	ld	s1,8(sp)
    8000491a:	6902                	ld	s2,0(sp)
    8000491c:	6105                	addi	sp,sp,32
    8000491e:	8082                	ret
    panic("iunlock");
    80004920:	00005517          	auipc	a0,0x5
    80004924:	00850513          	addi	a0,a0,8 # 80009928 <syscalls+0x1d0>
    80004928:	ffffc097          	auipc	ra,0xffffc
    8000492c:	c06080e7          	jalr	-1018(ra) # 8000052e <panic>

0000000080004930 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004930:	7179                	addi	sp,sp,-48
    80004932:	f406                	sd	ra,40(sp)
    80004934:	f022                	sd	s0,32(sp)
    80004936:	ec26                	sd	s1,24(sp)
    80004938:	e84a                	sd	s2,16(sp)
    8000493a:	e44e                	sd	s3,8(sp)
    8000493c:	e052                	sd	s4,0(sp)
    8000493e:	1800                	addi	s0,sp,48
    80004940:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004942:	05050493          	addi	s1,a0,80
    80004946:	08050913          	addi	s2,a0,128
    8000494a:	a021                	j	80004952 <itrunc+0x22>
    8000494c:	0491                	addi	s1,s1,4
    8000494e:	01248d63          	beq	s1,s2,80004968 <itrunc+0x38>
    if(ip->addrs[i]){
    80004952:	408c                	lw	a1,0(s1)
    80004954:	dde5                	beqz	a1,8000494c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80004956:	0009a503          	lw	a0,0(s3)
    8000495a:	00000097          	auipc	ra,0x0
    8000495e:	90a080e7          	jalr	-1782(ra) # 80004264 <bfree>
      ip->addrs[i] = 0;
    80004962:	0004a023          	sw	zero,0(s1)
    80004966:	b7dd                	j	8000494c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004968:	0809a583          	lw	a1,128(s3)
    8000496c:	e185                	bnez	a1,8000498c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000496e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004972:	854e                	mv	a0,s3
    80004974:	00000097          	auipc	ra,0x0
    80004978:	de4080e7          	jalr	-540(ra) # 80004758 <iupdate>
}
    8000497c:	70a2                	ld	ra,40(sp)
    8000497e:	7402                	ld	s0,32(sp)
    80004980:	64e2                	ld	s1,24(sp)
    80004982:	6942                	ld	s2,16(sp)
    80004984:	69a2                	ld	s3,8(sp)
    80004986:	6a02                	ld	s4,0(sp)
    80004988:	6145                	addi	sp,sp,48
    8000498a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000498c:	0009a503          	lw	a0,0(s3)
    80004990:	fffff097          	auipc	ra,0xfffff
    80004994:	68e080e7          	jalr	1678(ra) # 8000401e <bread>
    80004998:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000499a:	05850493          	addi	s1,a0,88
    8000499e:	45850913          	addi	s2,a0,1112
    800049a2:	a021                	j	800049aa <itrunc+0x7a>
    800049a4:	0491                	addi	s1,s1,4
    800049a6:	01248b63          	beq	s1,s2,800049bc <itrunc+0x8c>
      if(a[j])
    800049aa:	408c                	lw	a1,0(s1)
    800049ac:	dde5                	beqz	a1,800049a4 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800049ae:	0009a503          	lw	a0,0(s3)
    800049b2:	00000097          	auipc	ra,0x0
    800049b6:	8b2080e7          	jalr	-1870(ra) # 80004264 <bfree>
    800049ba:	b7ed                	j	800049a4 <itrunc+0x74>
    brelse(bp);
    800049bc:	8552                	mv	a0,s4
    800049be:	fffff097          	auipc	ra,0xfffff
    800049c2:	790080e7          	jalr	1936(ra) # 8000414e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800049c6:	0809a583          	lw	a1,128(s3)
    800049ca:	0009a503          	lw	a0,0(s3)
    800049ce:	00000097          	auipc	ra,0x0
    800049d2:	896080e7          	jalr	-1898(ra) # 80004264 <bfree>
    ip->addrs[NDIRECT] = 0;
    800049d6:	0809a023          	sw	zero,128(s3)
    800049da:	bf51                	j	8000496e <itrunc+0x3e>

00000000800049dc <iput>:
{
    800049dc:	1101                	addi	sp,sp,-32
    800049de:	ec06                	sd	ra,24(sp)
    800049e0:	e822                	sd	s0,16(sp)
    800049e2:	e426                	sd	s1,8(sp)
    800049e4:	e04a                	sd	s2,0(sp)
    800049e6:	1000                	addi	s0,sp,32
    800049e8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800049ea:	00037517          	auipc	a0,0x37
    800049ee:	63650513          	addi	a0,a0,1590 # 8003c020 <itable>
    800049f2:	ffffc097          	auipc	ra,0xffffc
    800049f6:	1d4080e7          	jalr	468(ra) # 80000bc6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800049fa:	4498                	lw	a4,8(s1)
    800049fc:	4785                	li	a5,1
    800049fe:	02f70363          	beq	a4,a5,80004a24 <iput+0x48>
  ip->ref--;
    80004a02:	449c                	lw	a5,8(s1)
    80004a04:	37fd                	addiw	a5,a5,-1
    80004a06:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004a08:	00037517          	auipc	a0,0x37
    80004a0c:	61850513          	addi	a0,a0,1560 # 8003c020 <itable>
    80004a10:	ffffc097          	auipc	ra,0xffffc
    80004a14:	280080e7          	jalr	640(ra) # 80000c90 <release>
}
    80004a18:	60e2                	ld	ra,24(sp)
    80004a1a:	6442                	ld	s0,16(sp)
    80004a1c:	64a2                	ld	s1,8(sp)
    80004a1e:	6902                	ld	s2,0(sp)
    80004a20:	6105                	addi	sp,sp,32
    80004a22:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004a24:	40bc                	lw	a5,64(s1)
    80004a26:	dff1                	beqz	a5,80004a02 <iput+0x26>
    80004a28:	04a49783          	lh	a5,74(s1)
    80004a2c:	fbf9                	bnez	a5,80004a02 <iput+0x26>
    acquiresleep(&ip->lock);
    80004a2e:	01048913          	addi	s2,s1,16
    80004a32:	854a                	mv	a0,s2
    80004a34:	00001097          	auipc	ra,0x1
    80004a38:	aba080e7          	jalr	-1350(ra) # 800054ee <acquiresleep>
    release(&itable.lock);
    80004a3c:	00037517          	auipc	a0,0x37
    80004a40:	5e450513          	addi	a0,a0,1508 # 8003c020 <itable>
    80004a44:	ffffc097          	auipc	ra,0xffffc
    80004a48:	24c080e7          	jalr	588(ra) # 80000c90 <release>
    itrunc(ip);
    80004a4c:	8526                	mv	a0,s1
    80004a4e:	00000097          	auipc	ra,0x0
    80004a52:	ee2080e7          	jalr	-286(ra) # 80004930 <itrunc>
    ip->type = 0;
    80004a56:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004a5a:	8526                	mv	a0,s1
    80004a5c:	00000097          	auipc	ra,0x0
    80004a60:	cfc080e7          	jalr	-772(ra) # 80004758 <iupdate>
    ip->valid = 0;
    80004a64:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004a68:	854a                	mv	a0,s2
    80004a6a:	00001097          	auipc	ra,0x1
    80004a6e:	ada080e7          	jalr	-1318(ra) # 80005544 <releasesleep>
    acquire(&itable.lock);
    80004a72:	00037517          	auipc	a0,0x37
    80004a76:	5ae50513          	addi	a0,a0,1454 # 8003c020 <itable>
    80004a7a:	ffffc097          	auipc	ra,0xffffc
    80004a7e:	14c080e7          	jalr	332(ra) # 80000bc6 <acquire>
    80004a82:	b741                	j	80004a02 <iput+0x26>

0000000080004a84 <iunlockput>:
{
    80004a84:	1101                	addi	sp,sp,-32
    80004a86:	ec06                	sd	ra,24(sp)
    80004a88:	e822                	sd	s0,16(sp)
    80004a8a:	e426                	sd	s1,8(sp)
    80004a8c:	1000                	addi	s0,sp,32
    80004a8e:	84aa                	mv	s1,a0
  iunlock(ip);
    80004a90:	00000097          	auipc	ra,0x0
    80004a94:	e54080e7          	jalr	-428(ra) # 800048e4 <iunlock>
  iput(ip);
    80004a98:	8526                	mv	a0,s1
    80004a9a:	00000097          	auipc	ra,0x0
    80004a9e:	f42080e7          	jalr	-190(ra) # 800049dc <iput>
}
    80004aa2:	60e2                	ld	ra,24(sp)
    80004aa4:	6442                	ld	s0,16(sp)
    80004aa6:	64a2                	ld	s1,8(sp)
    80004aa8:	6105                	addi	sp,sp,32
    80004aaa:	8082                	ret

0000000080004aac <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004aac:	1141                	addi	sp,sp,-16
    80004aae:	e422                	sd	s0,8(sp)
    80004ab0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004ab2:	411c                	lw	a5,0(a0)
    80004ab4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004ab6:	415c                	lw	a5,4(a0)
    80004ab8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004aba:	04451783          	lh	a5,68(a0)
    80004abe:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004ac2:	04a51783          	lh	a5,74(a0)
    80004ac6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004aca:	04c56783          	lwu	a5,76(a0)
    80004ace:	e99c                	sd	a5,16(a1)
}
    80004ad0:	6422                	ld	s0,8(sp)
    80004ad2:	0141                	addi	sp,sp,16
    80004ad4:	8082                	ret

0000000080004ad6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004ad6:	457c                	lw	a5,76(a0)
    80004ad8:	0ed7e963          	bltu	a5,a3,80004bca <readi+0xf4>
{
    80004adc:	7159                	addi	sp,sp,-112
    80004ade:	f486                	sd	ra,104(sp)
    80004ae0:	f0a2                	sd	s0,96(sp)
    80004ae2:	eca6                	sd	s1,88(sp)
    80004ae4:	e8ca                	sd	s2,80(sp)
    80004ae6:	e4ce                	sd	s3,72(sp)
    80004ae8:	e0d2                	sd	s4,64(sp)
    80004aea:	fc56                	sd	s5,56(sp)
    80004aec:	f85a                	sd	s6,48(sp)
    80004aee:	f45e                	sd	s7,40(sp)
    80004af0:	f062                	sd	s8,32(sp)
    80004af2:	ec66                	sd	s9,24(sp)
    80004af4:	e86a                	sd	s10,16(sp)
    80004af6:	e46e                	sd	s11,8(sp)
    80004af8:	1880                	addi	s0,sp,112
    80004afa:	8baa                	mv	s7,a0
    80004afc:	8c2e                	mv	s8,a1
    80004afe:	8ab2                	mv	s5,a2
    80004b00:	84b6                	mv	s1,a3
    80004b02:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004b04:	9f35                	addw	a4,a4,a3
    return 0;
    80004b06:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004b08:	0ad76063          	bltu	a4,a3,80004ba8 <readi+0xd2>
  if(off + n > ip->size)
    80004b0c:	00e7f463          	bgeu	a5,a4,80004b14 <readi+0x3e>
    n = ip->size - off;
    80004b10:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004b14:	0a0b0963          	beqz	s6,80004bc6 <readi+0xf0>
    80004b18:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004b1a:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004b1e:	5cfd                	li	s9,-1
    80004b20:	a82d                	j	80004b5a <readi+0x84>
    80004b22:	020a1d93          	slli	s11,s4,0x20
    80004b26:	020ddd93          	srli	s11,s11,0x20
    80004b2a:	05890793          	addi	a5,s2,88
    80004b2e:	86ee                	mv	a3,s11
    80004b30:	963e                	add	a2,a2,a5
    80004b32:	85d6                	mv	a1,s5
    80004b34:	8562                	mv	a0,s8
    80004b36:	ffffe097          	auipc	ra,0xffffe
    80004b3a:	db6080e7          	jalr	-586(ra) # 800028ec <either_copyout>
    80004b3e:	05950d63          	beq	a0,s9,80004b98 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004b42:	854a                	mv	a0,s2
    80004b44:	fffff097          	auipc	ra,0xfffff
    80004b48:	60a080e7          	jalr	1546(ra) # 8000414e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004b4c:	013a09bb          	addw	s3,s4,s3
    80004b50:	009a04bb          	addw	s1,s4,s1
    80004b54:	9aee                	add	s5,s5,s11
    80004b56:	0569f763          	bgeu	s3,s6,80004ba4 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004b5a:	000ba903          	lw	s2,0(s7)
    80004b5e:	00a4d59b          	srliw	a1,s1,0xa
    80004b62:	855e                	mv	a0,s7
    80004b64:	00000097          	auipc	ra,0x0
    80004b68:	8ae080e7          	jalr	-1874(ra) # 80004412 <bmap>
    80004b6c:	0005059b          	sext.w	a1,a0
    80004b70:	854a                	mv	a0,s2
    80004b72:	fffff097          	auipc	ra,0xfffff
    80004b76:	4ac080e7          	jalr	1196(ra) # 8000401e <bread>
    80004b7a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004b7c:	3ff4f613          	andi	a2,s1,1023
    80004b80:	40cd07bb          	subw	a5,s10,a2
    80004b84:	413b073b          	subw	a4,s6,s3
    80004b88:	8a3e                	mv	s4,a5
    80004b8a:	2781                	sext.w	a5,a5
    80004b8c:	0007069b          	sext.w	a3,a4
    80004b90:	f8f6f9e3          	bgeu	a3,a5,80004b22 <readi+0x4c>
    80004b94:	8a3a                	mv	s4,a4
    80004b96:	b771                	j	80004b22 <readi+0x4c>
      brelse(bp);
    80004b98:	854a                	mv	a0,s2
    80004b9a:	fffff097          	auipc	ra,0xfffff
    80004b9e:	5b4080e7          	jalr	1460(ra) # 8000414e <brelse>
      tot = -1;
    80004ba2:	59fd                	li	s3,-1
  }
  return tot;
    80004ba4:	0009851b          	sext.w	a0,s3
}
    80004ba8:	70a6                	ld	ra,104(sp)
    80004baa:	7406                	ld	s0,96(sp)
    80004bac:	64e6                	ld	s1,88(sp)
    80004bae:	6946                	ld	s2,80(sp)
    80004bb0:	69a6                	ld	s3,72(sp)
    80004bb2:	6a06                	ld	s4,64(sp)
    80004bb4:	7ae2                	ld	s5,56(sp)
    80004bb6:	7b42                	ld	s6,48(sp)
    80004bb8:	7ba2                	ld	s7,40(sp)
    80004bba:	7c02                	ld	s8,32(sp)
    80004bbc:	6ce2                	ld	s9,24(sp)
    80004bbe:	6d42                	ld	s10,16(sp)
    80004bc0:	6da2                	ld	s11,8(sp)
    80004bc2:	6165                	addi	sp,sp,112
    80004bc4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004bc6:	89da                	mv	s3,s6
    80004bc8:	bff1                	j	80004ba4 <readi+0xce>
    return 0;
    80004bca:	4501                	li	a0,0
}
    80004bcc:	8082                	ret

0000000080004bce <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004bce:	457c                	lw	a5,76(a0)
    80004bd0:	10d7e863          	bltu	a5,a3,80004ce0 <writei+0x112>
{
    80004bd4:	7159                	addi	sp,sp,-112
    80004bd6:	f486                	sd	ra,104(sp)
    80004bd8:	f0a2                	sd	s0,96(sp)
    80004bda:	eca6                	sd	s1,88(sp)
    80004bdc:	e8ca                	sd	s2,80(sp)
    80004bde:	e4ce                	sd	s3,72(sp)
    80004be0:	e0d2                	sd	s4,64(sp)
    80004be2:	fc56                	sd	s5,56(sp)
    80004be4:	f85a                	sd	s6,48(sp)
    80004be6:	f45e                	sd	s7,40(sp)
    80004be8:	f062                	sd	s8,32(sp)
    80004bea:	ec66                	sd	s9,24(sp)
    80004bec:	e86a                	sd	s10,16(sp)
    80004bee:	e46e                	sd	s11,8(sp)
    80004bf0:	1880                	addi	s0,sp,112
    80004bf2:	8b2a                	mv	s6,a0
    80004bf4:	8c2e                	mv	s8,a1
    80004bf6:	8ab2                	mv	s5,a2
    80004bf8:	8936                	mv	s2,a3
    80004bfa:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004bfc:	00e687bb          	addw	a5,a3,a4
    80004c00:	0ed7e263          	bltu	a5,a3,80004ce4 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004c04:	00043737          	lui	a4,0x43
    80004c08:	0ef76063          	bltu	a4,a5,80004ce8 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004c0c:	0c0b8863          	beqz	s7,80004cdc <writei+0x10e>
    80004c10:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004c12:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004c16:	5cfd                	li	s9,-1
    80004c18:	a091                	j	80004c5c <writei+0x8e>
    80004c1a:	02099d93          	slli	s11,s3,0x20
    80004c1e:	020ddd93          	srli	s11,s11,0x20
    80004c22:	05848793          	addi	a5,s1,88
    80004c26:	86ee                	mv	a3,s11
    80004c28:	8656                	mv	a2,s5
    80004c2a:	85e2                	mv	a1,s8
    80004c2c:	953e                	add	a0,a0,a5
    80004c2e:	ffffe097          	auipc	ra,0xffffe
    80004c32:	d14080e7          	jalr	-748(ra) # 80002942 <either_copyin>
    80004c36:	07950263          	beq	a0,s9,80004c9a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004c3a:	8526                	mv	a0,s1
    80004c3c:	00000097          	auipc	ra,0x0
    80004c40:	792080e7          	jalr	1938(ra) # 800053ce <log_write>
    brelse(bp);
    80004c44:	8526                	mv	a0,s1
    80004c46:	fffff097          	auipc	ra,0xfffff
    80004c4a:	508080e7          	jalr	1288(ra) # 8000414e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004c4e:	01498a3b          	addw	s4,s3,s4
    80004c52:	0129893b          	addw	s2,s3,s2
    80004c56:	9aee                	add	s5,s5,s11
    80004c58:	057a7663          	bgeu	s4,s7,80004ca4 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004c5c:	000b2483          	lw	s1,0(s6)
    80004c60:	00a9559b          	srliw	a1,s2,0xa
    80004c64:	855a                	mv	a0,s6
    80004c66:	fffff097          	auipc	ra,0xfffff
    80004c6a:	7ac080e7          	jalr	1964(ra) # 80004412 <bmap>
    80004c6e:	0005059b          	sext.w	a1,a0
    80004c72:	8526                	mv	a0,s1
    80004c74:	fffff097          	auipc	ra,0xfffff
    80004c78:	3aa080e7          	jalr	938(ra) # 8000401e <bread>
    80004c7c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004c7e:	3ff97513          	andi	a0,s2,1023
    80004c82:	40ad07bb          	subw	a5,s10,a0
    80004c86:	414b873b          	subw	a4,s7,s4
    80004c8a:	89be                	mv	s3,a5
    80004c8c:	2781                	sext.w	a5,a5
    80004c8e:	0007069b          	sext.w	a3,a4
    80004c92:	f8f6f4e3          	bgeu	a3,a5,80004c1a <writei+0x4c>
    80004c96:	89ba                	mv	s3,a4
    80004c98:	b749                	j	80004c1a <writei+0x4c>
      brelse(bp);
    80004c9a:	8526                	mv	a0,s1
    80004c9c:	fffff097          	auipc	ra,0xfffff
    80004ca0:	4b2080e7          	jalr	1202(ra) # 8000414e <brelse>
  }

  if(off > ip->size)
    80004ca4:	04cb2783          	lw	a5,76(s6)
    80004ca8:	0127f463          	bgeu	a5,s2,80004cb0 <writei+0xe2>
    ip->size = off;
    80004cac:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004cb0:	855a                	mv	a0,s6
    80004cb2:	00000097          	auipc	ra,0x0
    80004cb6:	aa6080e7          	jalr	-1370(ra) # 80004758 <iupdate>

  return tot;
    80004cba:	000a051b          	sext.w	a0,s4
}
    80004cbe:	70a6                	ld	ra,104(sp)
    80004cc0:	7406                	ld	s0,96(sp)
    80004cc2:	64e6                	ld	s1,88(sp)
    80004cc4:	6946                	ld	s2,80(sp)
    80004cc6:	69a6                	ld	s3,72(sp)
    80004cc8:	6a06                	ld	s4,64(sp)
    80004cca:	7ae2                	ld	s5,56(sp)
    80004ccc:	7b42                	ld	s6,48(sp)
    80004cce:	7ba2                	ld	s7,40(sp)
    80004cd0:	7c02                	ld	s8,32(sp)
    80004cd2:	6ce2                	ld	s9,24(sp)
    80004cd4:	6d42                	ld	s10,16(sp)
    80004cd6:	6da2                	ld	s11,8(sp)
    80004cd8:	6165                	addi	sp,sp,112
    80004cda:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004cdc:	8a5e                	mv	s4,s7
    80004cde:	bfc9                	j	80004cb0 <writei+0xe2>
    return -1;
    80004ce0:	557d                	li	a0,-1
}
    80004ce2:	8082                	ret
    return -1;
    80004ce4:	557d                	li	a0,-1
    80004ce6:	bfe1                	j	80004cbe <writei+0xf0>
    return -1;
    80004ce8:	557d                	li	a0,-1
    80004cea:	bfd1                	j	80004cbe <writei+0xf0>

0000000080004cec <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004cec:	1141                	addi	sp,sp,-16
    80004cee:	e406                	sd	ra,8(sp)
    80004cf0:	e022                	sd	s0,0(sp)
    80004cf2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004cf4:	4639                	li	a2,14
    80004cf6:	ffffc097          	auipc	ra,0xffffc
    80004cfa:	0ba080e7          	jalr	186(ra) # 80000db0 <strncmp>
}
    80004cfe:	60a2                	ld	ra,8(sp)
    80004d00:	6402                	ld	s0,0(sp)
    80004d02:	0141                	addi	sp,sp,16
    80004d04:	8082                	ret

0000000080004d06 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004d06:	7139                	addi	sp,sp,-64
    80004d08:	fc06                	sd	ra,56(sp)
    80004d0a:	f822                	sd	s0,48(sp)
    80004d0c:	f426                	sd	s1,40(sp)
    80004d0e:	f04a                	sd	s2,32(sp)
    80004d10:	ec4e                	sd	s3,24(sp)
    80004d12:	e852                	sd	s4,16(sp)
    80004d14:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004d16:	04451703          	lh	a4,68(a0)
    80004d1a:	4785                	li	a5,1
    80004d1c:	00f71a63          	bne	a4,a5,80004d30 <dirlookup+0x2a>
    80004d20:	892a                	mv	s2,a0
    80004d22:	89ae                	mv	s3,a1
    80004d24:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d26:	457c                	lw	a5,76(a0)
    80004d28:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004d2a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d2c:	e79d                	bnez	a5,80004d5a <dirlookup+0x54>
    80004d2e:	a8a5                	j	80004da6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004d30:	00005517          	auipc	a0,0x5
    80004d34:	c0050513          	addi	a0,a0,-1024 # 80009930 <syscalls+0x1d8>
    80004d38:	ffffb097          	auipc	ra,0xffffb
    80004d3c:	7f6080e7          	jalr	2038(ra) # 8000052e <panic>
      panic("dirlookup read");
    80004d40:	00005517          	auipc	a0,0x5
    80004d44:	c0850513          	addi	a0,a0,-1016 # 80009948 <syscalls+0x1f0>
    80004d48:	ffffb097          	auipc	ra,0xffffb
    80004d4c:	7e6080e7          	jalr	2022(ra) # 8000052e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d50:	24c1                	addiw	s1,s1,16
    80004d52:	04c92783          	lw	a5,76(s2)
    80004d56:	04f4f763          	bgeu	s1,a5,80004da4 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d5a:	4741                	li	a4,16
    80004d5c:	86a6                	mv	a3,s1
    80004d5e:	fc040613          	addi	a2,s0,-64
    80004d62:	4581                	li	a1,0
    80004d64:	854a                	mv	a0,s2
    80004d66:	00000097          	auipc	ra,0x0
    80004d6a:	d70080e7          	jalr	-656(ra) # 80004ad6 <readi>
    80004d6e:	47c1                	li	a5,16
    80004d70:	fcf518e3          	bne	a0,a5,80004d40 <dirlookup+0x3a>
    if(de.inum == 0)
    80004d74:	fc045783          	lhu	a5,-64(s0)
    80004d78:	dfe1                	beqz	a5,80004d50 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004d7a:	fc240593          	addi	a1,s0,-62
    80004d7e:	854e                	mv	a0,s3
    80004d80:	00000097          	auipc	ra,0x0
    80004d84:	f6c080e7          	jalr	-148(ra) # 80004cec <namecmp>
    80004d88:	f561                	bnez	a0,80004d50 <dirlookup+0x4a>
      if(poff)
    80004d8a:	000a0463          	beqz	s4,80004d92 <dirlookup+0x8c>
        *poff = off;
    80004d8e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004d92:	fc045583          	lhu	a1,-64(s0)
    80004d96:	00092503          	lw	a0,0(s2)
    80004d9a:	fffff097          	auipc	ra,0xfffff
    80004d9e:	754080e7          	jalr	1876(ra) # 800044ee <iget>
    80004da2:	a011                	j	80004da6 <dirlookup+0xa0>
  return 0;
    80004da4:	4501                	li	a0,0
}
    80004da6:	70e2                	ld	ra,56(sp)
    80004da8:	7442                	ld	s0,48(sp)
    80004daa:	74a2                	ld	s1,40(sp)
    80004dac:	7902                	ld	s2,32(sp)
    80004dae:	69e2                	ld	s3,24(sp)
    80004db0:	6a42                	ld	s4,16(sp)
    80004db2:	6121                	addi	sp,sp,64
    80004db4:	8082                	ret

0000000080004db6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004db6:	711d                	addi	sp,sp,-96
    80004db8:	ec86                	sd	ra,88(sp)
    80004dba:	e8a2                	sd	s0,80(sp)
    80004dbc:	e4a6                	sd	s1,72(sp)
    80004dbe:	e0ca                	sd	s2,64(sp)
    80004dc0:	fc4e                	sd	s3,56(sp)
    80004dc2:	f852                	sd	s4,48(sp)
    80004dc4:	f456                	sd	s5,40(sp)
    80004dc6:	f05a                	sd	s6,32(sp)
    80004dc8:	ec5e                	sd	s7,24(sp)
    80004dca:	e862                	sd	s8,16(sp)
    80004dcc:	e466                	sd	s9,8(sp)
    80004dce:	1080                	addi	s0,sp,96
    80004dd0:	84aa                	mv	s1,a0
    80004dd2:	8aae                	mv	s5,a1
    80004dd4:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004dd6:	00054703          	lbu	a4,0(a0)
    80004dda:	02f00793          	li	a5,47
    80004dde:	02f70263          	beq	a4,a5,80004e02 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004de2:	ffffd097          	auipc	ra,0xffffd
    80004de6:	c8e080e7          	jalr	-882(ra) # 80001a70 <myproc>
    80004dea:	6968                	ld	a0,208(a0)
    80004dec:	00000097          	auipc	ra,0x0
    80004df0:	9f8080e7          	jalr	-1544(ra) # 800047e4 <idup>
    80004df4:	89aa                	mv	s3,a0
  while(*path == '/')
    80004df6:	02f00913          	li	s2,47
  len = path - s;
    80004dfa:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004dfc:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004dfe:	4b85                	li	s7,1
    80004e00:	a865                	j	80004eb8 <namex+0x102>
    ip = iget(ROOTDEV, ROOTINO);
    80004e02:	4585                	li	a1,1
    80004e04:	4505                	li	a0,1
    80004e06:	fffff097          	auipc	ra,0xfffff
    80004e0a:	6e8080e7          	jalr	1768(ra) # 800044ee <iget>
    80004e0e:	89aa                	mv	s3,a0
    80004e10:	b7dd                	j	80004df6 <namex+0x40>
      iunlockput(ip);
    80004e12:	854e                	mv	a0,s3
    80004e14:	00000097          	auipc	ra,0x0
    80004e18:	c70080e7          	jalr	-912(ra) # 80004a84 <iunlockput>
      return 0;
    80004e1c:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004e1e:	854e                	mv	a0,s3
    80004e20:	60e6                	ld	ra,88(sp)
    80004e22:	6446                	ld	s0,80(sp)
    80004e24:	64a6                	ld	s1,72(sp)
    80004e26:	6906                	ld	s2,64(sp)
    80004e28:	79e2                	ld	s3,56(sp)
    80004e2a:	7a42                	ld	s4,48(sp)
    80004e2c:	7aa2                	ld	s5,40(sp)
    80004e2e:	7b02                	ld	s6,32(sp)
    80004e30:	6be2                	ld	s7,24(sp)
    80004e32:	6c42                	ld	s8,16(sp)
    80004e34:	6ca2                	ld	s9,8(sp)
    80004e36:	6125                	addi	sp,sp,96
    80004e38:	8082                	ret
      iunlock(ip);
    80004e3a:	854e                	mv	a0,s3
    80004e3c:	00000097          	auipc	ra,0x0
    80004e40:	aa8080e7          	jalr	-1368(ra) # 800048e4 <iunlock>
      return ip;
    80004e44:	bfe9                	j	80004e1e <namex+0x68>
      iunlockput(ip);
    80004e46:	854e                	mv	a0,s3
    80004e48:	00000097          	auipc	ra,0x0
    80004e4c:	c3c080e7          	jalr	-964(ra) # 80004a84 <iunlockput>
      return 0;
    80004e50:	89e6                	mv	s3,s9
    80004e52:	b7f1                	j	80004e1e <namex+0x68>
  len = path - s;
    80004e54:	40b48633          	sub	a2,s1,a1
    80004e58:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004e5c:	099c5463          	bge	s8,s9,80004ee4 <namex+0x12e>
    memmove(name, s, DIRSIZ);
    80004e60:	4639                	li	a2,14
    80004e62:	8552                	mv	a0,s4
    80004e64:	ffffc097          	auipc	ra,0xffffc
    80004e68:	ed0080e7          	jalr	-304(ra) # 80000d34 <memmove>
  while(*path == '/')
    80004e6c:	0004c783          	lbu	a5,0(s1)
    80004e70:	01279763          	bne	a5,s2,80004e7e <namex+0xc8>
    path++;
    80004e74:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004e76:	0004c783          	lbu	a5,0(s1)
    80004e7a:	ff278de3          	beq	a5,s2,80004e74 <namex+0xbe>
    ilock(ip);
    80004e7e:	854e                	mv	a0,s3
    80004e80:	00000097          	auipc	ra,0x0
    80004e84:	9a2080e7          	jalr	-1630(ra) # 80004822 <ilock>
    if(ip->type != T_DIR){
    80004e88:	04499783          	lh	a5,68(s3)
    80004e8c:	f97793e3          	bne	a5,s7,80004e12 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004e90:	000a8563          	beqz	s5,80004e9a <namex+0xe4>
    80004e94:	0004c783          	lbu	a5,0(s1)
    80004e98:	d3cd                	beqz	a5,80004e3a <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004e9a:	865a                	mv	a2,s6
    80004e9c:	85d2                	mv	a1,s4
    80004e9e:	854e                	mv	a0,s3
    80004ea0:	00000097          	auipc	ra,0x0
    80004ea4:	e66080e7          	jalr	-410(ra) # 80004d06 <dirlookup>
    80004ea8:	8caa                	mv	s9,a0
    80004eaa:	dd51                	beqz	a0,80004e46 <namex+0x90>
    iunlockput(ip);
    80004eac:	854e                	mv	a0,s3
    80004eae:	00000097          	auipc	ra,0x0
    80004eb2:	bd6080e7          	jalr	-1066(ra) # 80004a84 <iunlockput>
    ip = next;
    80004eb6:	89e6                	mv	s3,s9
  while(*path == '/')
    80004eb8:	0004c783          	lbu	a5,0(s1)
    80004ebc:	05279763          	bne	a5,s2,80004f0a <namex+0x154>
    path++;
    80004ec0:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004ec2:	0004c783          	lbu	a5,0(s1)
    80004ec6:	ff278de3          	beq	a5,s2,80004ec0 <namex+0x10a>
  if(*path == 0)
    80004eca:	c79d                	beqz	a5,80004ef8 <namex+0x142>
    path++;
    80004ecc:	85a6                	mv	a1,s1
  len = path - s;
    80004ece:	8cda                	mv	s9,s6
    80004ed0:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004ed2:	01278963          	beq	a5,s2,80004ee4 <namex+0x12e>
    80004ed6:	dfbd                	beqz	a5,80004e54 <namex+0x9e>
    path++;
    80004ed8:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004eda:	0004c783          	lbu	a5,0(s1)
    80004ede:	ff279ce3          	bne	a5,s2,80004ed6 <namex+0x120>
    80004ee2:	bf8d                	j	80004e54 <namex+0x9e>
    memmove(name, s, len);
    80004ee4:	2601                	sext.w	a2,a2
    80004ee6:	8552                	mv	a0,s4
    80004ee8:	ffffc097          	auipc	ra,0xffffc
    80004eec:	e4c080e7          	jalr	-436(ra) # 80000d34 <memmove>
    name[len] = 0;
    80004ef0:	9cd2                	add	s9,s9,s4
    80004ef2:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004ef6:	bf9d                	j	80004e6c <namex+0xb6>
  if(nameiparent){
    80004ef8:	f20a83e3          	beqz	s5,80004e1e <namex+0x68>
    iput(ip);
    80004efc:	854e                	mv	a0,s3
    80004efe:	00000097          	auipc	ra,0x0
    80004f02:	ade080e7          	jalr	-1314(ra) # 800049dc <iput>
    return 0;
    80004f06:	4981                	li	s3,0
    80004f08:	bf19                	j	80004e1e <namex+0x68>
  if(*path == 0)
    80004f0a:	d7fd                	beqz	a5,80004ef8 <namex+0x142>
  while(*path != '/' && *path != 0)
    80004f0c:	0004c783          	lbu	a5,0(s1)
    80004f10:	85a6                	mv	a1,s1
    80004f12:	b7d1                	j	80004ed6 <namex+0x120>

0000000080004f14 <dirlink>:
{
    80004f14:	7139                	addi	sp,sp,-64
    80004f16:	fc06                	sd	ra,56(sp)
    80004f18:	f822                	sd	s0,48(sp)
    80004f1a:	f426                	sd	s1,40(sp)
    80004f1c:	f04a                	sd	s2,32(sp)
    80004f1e:	ec4e                	sd	s3,24(sp)
    80004f20:	e852                	sd	s4,16(sp)
    80004f22:	0080                	addi	s0,sp,64
    80004f24:	892a                	mv	s2,a0
    80004f26:	8a2e                	mv	s4,a1
    80004f28:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004f2a:	4601                	li	a2,0
    80004f2c:	00000097          	auipc	ra,0x0
    80004f30:	dda080e7          	jalr	-550(ra) # 80004d06 <dirlookup>
    80004f34:	e93d                	bnez	a0,80004faa <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004f36:	04c92483          	lw	s1,76(s2)
    80004f3a:	c49d                	beqz	s1,80004f68 <dirlink+0x54>
    80004f3c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f3e:	4741                	li	a4,16
    80004f40:	86a6                	mv	a3,s1
    80004f42:	fc040613          	addi	a2,s0,-64
    80004f46:	4581                	li	a1,0
    80004f48:	854a                	mv	a0,s2
    80004f4a:	00000097          	auipc	ra,0x0
    80004f4e:	b8c080e7          	jalr	-1140(ra) # 80004ad6 <readi>
    80004f52:	47c1                	li	a5,16
    80004f54:	06f51163          	bne	a0,a5,80004fb6 <dirlink+0xa2>
    if(de.inum == 0)
    80004f58:	fc045783          	lhu	a5,-64(s0)
    80004f5c:	c791                	beqz	a5,80004f68 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004f5e:	24c1                	addiw	s1,s1,16
    80004f60:	04c92783          	lw	a5,76(s2)
    80004f64:	fcf4ede3          	bltu	s1,a5,80004f3e <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004f68:	4639                	li	a2,14
    80004f6a:	85d2                	mv	a1,s4
    80004f6c:	fc240513          	addi	a0,s0,-62
    80004f70:	ffffc097          	auipc	ra,0xffffc
    80004f74:	e7c080e7          	jalr	-388(ra) # 80000dec <strncpy>
  de.inum = inum;
    80004f78:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f7c:	4741                	li	a4,16
    80004f7e:	86a6                	mv	a3,s1
    80004f80:	fc040613          	addi	a2,s0,-64
    80004f84:	4581                	li	a1,0
    80004f86:	854a                	mv	a0,s2
    80004f88:	00000097          	auipc	ra,0x0
    80004f8c:	c46080e7          	jalr	-954(ra) # 80004bce <writei>
    80004f90:	872a                	mv	a4,a0
    80004f92:	47c1                	li	a5,16
  return 0;
    80004f94:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f96:	02f71863          	bne	a4,a5,80004fc6 <dirlink+0xb2>
}
    80004f9a:	70e2                	ld	ra,56(sp)
    80004f9c:	7442                	ld	s0,48(sp)
    80004f9e:	74a2                	ld	s1,40(sp)
    80004fa0:	7902                	ld	s2,32(sp)
    80004fa2:	69e2                	ld	s3,24(sp)
    80004fa4:	6a42                	ld	s4,16(sp)
    80004fa6:	6121                	addi	sp,sp,64
    80004fa8:	8082                	ret
    iput(ip);
    80004faa:	00000097          	auipc	ra,0x0
    80004fae:	a32080e7          	jalr	-1486(ra) # 800049dc <iput>
    return -1;
    80004fb2:	557d                	li	a0,-1
    80004fb4:	b7dd                	j	80004f9a <dirlink+0x86>
      panic("dirlink read");
    80004fb6:	00005517          	auipc	a0,0x5
    80004fba:	9a250513          	addi	a0,a0,-1630 # 80009958 <syscalls+0x200>
    80004fbe:	ffffb097          	auipc	ra,0xffffb
    80004fc2:	570080e7          	jalr	1392(ra) # 8000052e <panic>
    panic("dirlink");
    80004fc6:	00005517          	auipc	a0,0x5
    80004fca:	aa250513          	addi	a0,a0,-1374 # 80009a68 <syscalls+0x310>
    80004fce:	ffffb097          	auipc	ra,0xffffb
    80004fd2:	560080e7          	jalr	1376(ra) # 8000052e <panic>

0000000080004fd6 <namei>:

struct inode*
namei(char *path)
{
    80004fd6:	1101                	addi	sp,sp,-32
    80004fd8:	ec06                	sd	ra,24(sp)
    80004fda:	e822                	sd	s0,16(sp)
    80004fdc:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004fde:	fe040613          	addi	a2,s0,-32
    80004fe2:	4581                	li	a1,0
    80004fe4:	00000097          	auipc	ra,0x0
    80004fe8:	dd2080e7          	jalr	-558(ra) # 80004db6 <namex>
}
    80004fec:	60e2                	ld	ra,24(sp)
    80004fee:	6442                	ld	s0,16(sp)
    80004ff0:	6105                	addi	sp,sp,32
    80004ff2:	8082                	ret

0000000080004ff4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004ff4:	1141                	addi	sp,sp,-16
    80004ff6:	e406                	sd	ra,8(sp)
    80004ff8:	e022                	sd	s0,0(sp)
    80004ffa:	0800                	addi	s0,sp,16
    80004ffc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004ffe:	4585                	li	a1,1
    80005000:	00000097          	auipc	ra,0x0
    80005004:	db6080e7          	jalr	-586(ra) # 80004db6 <namex>
}
    80005008:	60a2                	ld	ra,8(sp)
    8000500a:	6402                	ld	s0,0(sp)
    8000500c:	0141                	addi	sp,sp,16
    8000500e:	8082                	ret

0000000080005010 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80005010:	1101                	addi	sp,sp,-32
    80005012:	ec06                	sd	ra,24(sp)
    80005014:	e822                	sd	s0,16(sp)
    80005016:	e426                	sd	s1,8(sp)
    80005018:	e04a                	sd	s2,0(sp)
    8000501a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000501c:	00039917          	auipc	s2,0x39
    80005020:	aac90913          	addi	s2,s2,-1364 # 8003dac8 <log>
    80005024:	01892583          	lw	a1,24(s2)
    80005028:	02892503          	lw	a0,40(s2)
    8000502c:	fffff097          	auipc	ra,0xfffff
    80005030:	ff2080e7          	jalr	-14(ra) # 8000401e <bread>
    80005034:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80005036:	02c92683          	lw	a3,44(s2)
    8000503a:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000503c:	02d05863          	blez	a3,8000506c <write_head+0x5c>
    80005040:	00039797          	auipc	a5,0x39
    80005044:	ab878793          	addi	a5,a5,-1352 # 8003daf8 <log+0x30>
    80005048:	05c50713          	addi	a4,a0,92
    8000504c:	36fd                	addiw	a3,a3,-1
    8000504e:	02069613          	slli	a2,a3,0x20
    80005052:	01e65693          	srli	a3,a2,0x1e
    80005056:	00039617          	auipc	a2,0x39
    8000505a:	aa660613          	addi	a2,a2,-1370 # 8003dafc <log+0x34>
    8000505e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80005060:	4390                	lw	a2,0(a5)
    80005062:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005064:	0791                	addi	a5,a5,4
    80005066:	0711                	addi	a4,a4,4
    80005068:	fed79ce3          	bne	a5,a3,80005060 <write_head+0x50>
  }
  bwrite(buf);
    8000506c:	8526                	mv	a0,s1
    8000506e:	fffff097          	auipc	ra,0xfffff
    80005072:	0a2080e7          	jalr	162(ra) # 80004110 <bwrite>
  brelse(buf);
    80005076:	8526                	mv	a0,s1
    80005078:	fffff097          	auipc	ra,0xfffff
    8000507c:	0d6080e7          	jalr	214(ra) # 8000414e <brelse>
}
    80005080:	60e2                	ld	ra,24(sp)
    80005082:	6442                	ld	s0,16(sp)
    80005084:	64a2                	ld	s1,8(sp)
    80005086:	6902                	ld	s2,0(sp)
    80005088:	6105                	addi	sp,sp,32
    8000508a:	8082                	ret

000000008000508c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000508c:	00039797          	auipc	a5,0x39
    80005090:	a687a783          	lw	a5,-1432(a5) # 8003daf4 <log+0x2c>
    80005094:	0af05d63          	blez	a5,8000514e <install_trans+0xc2>
{
    80005098:	7139                	addi	sp,sp,-64
    8000509a:	fc06                	sd	ra,56(sp)
    8000509c:	f822                	sd	s0,48(sp)
    8000509e:	f426                	sd	s1,40(sp)
    800050a0:	f04a                	sd	s2,32(sp)
    800050a2:	ec4e                	sd	s3,24(sp)
    800050a4:	e852                	sd	s4,16(sp)
    800050a6:	e456                	sd	s5,8(sp)
    800050a8:	e05a                	sd	s6,0(sp)
    800050aa:	0080                	addi	s0,sp,64
    800050ac:	8b2a                	mv	s6,a0
    800050ae:	00039a97          	auipc	s5,0x39
    800050b2:	a4aa8a93          	addi	s5,s5,-1462 # 8003daf8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800050b6:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800050b8:	00039997          	auipc	s3,0x39
    800050bc:	a1098993          	addi	s3,s3,-1520 # 8003dac8 <log>
    800050c0:	a00d                	j	800050e2 <install_trans+0x56>
    brelse(lbuf);
    800050c2:	854a                	mv	a0,s2
    800050c4:	fffff097          	auipc	ra,0xfffff
    800050c8:	08a080e7          	jalr	138(ra) # 8000414e <brelse>
    brelse(dbuf);
    800050cc:	8526                	mv	a0,s1
    800050ce:	fffff097          	auipc	ra,0xfffff
    800050d2:	080080e7          	jalr	128(ra) # 8000414e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800050d6:	2a05                	addiw	s4,s4,1
    800050d8:	0a91                	addi	s5,s5,4
    800050da:	02c9a783          	lw	a5,44(s3)
    800050de:	04fa5e63          	bge	s4,a5,8000513a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800050e2:	0189a583          	lw	a1,24(s3)
    800050e6:	014585bb          	addw	a1,a1,s4
    800050ea:	2585                	addiw	a1,a1,1
    800050ec:	0289a503          	lw	a0,40(s3)
    800050f0:	fffff097          	auipc	ra,0xfffff
    800050f4:	f2e080e7          	jalr	-210(ra) # 8000401e <bread>
    800050f8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800050fa:	000aa583          	lw	a1,0(s5)
    800050fe:	0289a503          	lw	a0,40(s3)
    80005102:	fffff097          	auipc	ra,0xfffff
    80005106:	f1c080e7          	jalr	-228(ra) # 8000401e <bread>
    8000510a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000510c:	40000613          	li	a2,1024
    80005110:	05890593          	addi	a1,s2,88
    80005114:	05850513          	addi	a0,a0,88
    80005118:	ffffc097          	auipc	ra,0xffffc
    8000511c:	c1c080e7          	jalr	-996(ra) # 80000d34 <memmove>
    bwrite(dbuf);  // write dst to disk
    80005120:	8526                	mv	a0,s1
    80005122:	fffff097          	auipc	ra,0xfffff
    80005126:	fee080e7          	jalr	-18(ra) # 80004110 <bwrite>
    if(recovering == 0)
    8000512a:	f80b1ce3          	bnez	s6,800050c2 <install_trans+0x36>
      bunpin(dbuf);
    8000512e:	8526                	mv	a0,s1
    80005130:	fffff097          	auipc	ra,0xfffff
    80005134:	0f8080e7          	jalr	248(ra) # 80004228 <bunpin>
    80005138:	b769                	j	800050c2 <install_trans+0x36>
}
    8000513a:	70e2                	ld	ra,56(sp)
    8000513c:	7442                	ld	s0,48(sp)
    8000513e:	74a2                	ld	s1,40(sp)
    80005140:	7902                	ld	s2,32(sp)
    80005142:	69e2                	ld	s3,24(sp)
    80005144:	6a42                	ld	s4,16(sp)
    80005146:	6aa2                	ld	s5,8(sp)
    80005148:	6b02                	ld	s6,0(sp)
    8000514a:	6121                	addi	sp,sp,64
    8000514c:	8082                	ret
    8000514e:	8082                	ret

0000000080005150 <initlog>:
{
    80005150:	7179                	addi	sp,sp,-48
    80005152:	f406                	sd	ra,40(sp)
    80005154:	f022                	sd	s0,32(sp)
    80005156:	ec26                	sd	s1,24(sp)
    80005158:	e84a                	sd	s2,16(sp)
    8000515a:	e44e                	sd	s3,8(sp)
    8000515c:	1800                	addi	s0,sp,48
    8000515e:	892a                	mv	s2,a0
    80005160:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80005162:	00039497          	auipc	s1,0x39
    80005166:	96648493          	addi	s1,s1,-1690 # 8003dac8 <log>
    8000516a:	00004597          	auipc	a1,0x4
    8000516e:	7fe58593          	addi	a1,a1,2046 # 80009968 <syscalls+0x210>
    80005172:	8526                	mv	a0,s1
    80005174:	ffffc097          	auipc	ra,0xffffc
    80005178:	9c2080e7          	jalr	-1598(ra) # 80000b36 <initlock>
  log.start = sb->logstart;
    8000517c:	0149a583          	lw	a1,20(s3)
    80005180:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80005182:	0109a783          	lw	a5,16(s3)
    80005186:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80005188:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000518c:	854a                	mv	a0,s2
    8000518e:	fffff097          	auipc	ra,0xfffff
    80005192:	e90080e7          	jalr	-368(ra) # 8000401e <bread>
  log.lh.n = lh->n;
    80005196:	4d34                	lw	a3,88(a0)
    80005198:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000519a:	02d05663          	blez	a3,800051c6 <initlog+0x76>
    8000519e:	05c50793          	addi	a5,a0,92
    800051a2:	00039717          	auipc	a4,0x39
    800051a6:	95670713          	addi	a4,a4,-1706 # 8003daf8 <log+0x30>
    800051aa:	36fd                	addiw	a3,a3,-1
    800051ac:	02069613          	slli	a2,a3,0x20
    800051b0:	01e65693          	srli	a3,a2,0x1e
    800051b4:	06050613          	addi	a2,a0,96
    800051b8:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800051ba:	4390                	lw	a2,0(a5)
    800051bc:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800051be:	0791                	addi	a5,a5,4
    800051c0:	0711                	addi	a4,a4,4
    800051c2:	fed79ce3          	bne	a5,a3,800051ba <initlog+0x6a>
  brelse(buf);
    800051c6:	fffff097          	auipc	ra,0xfffff
    800051ca:	f88080e7          	jalr	-120(ra) # 8000414e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800051ce:	4505                	li	a0,1
    800051d0:	00000097          	auipc	ra,0x0
    800051d4:	ebc080e7          	jalr	-324(ra) # 8000508c <install_trans>
  log.lh.n = 0;
    800051d8:	00039797          	auipc	a5,0x39
    800051dc:	9007ae23          	sw	zero,-1764(a5) # 8003daf4 <log+0x2c>
  write_head(); // clear the log
    800051e0:	00000097          	auipc	ra,0x0
    800051e4:	e30080e7          	jalr	-464(ra) # 80005010 <write_head>
}
    800051e8:	70a2                	ld	ra,40(sp)
    800051ea:	7402                	ld	s0,32(sp)
    800051ec:	64e2                	ld	s1,24(sp)
    800051ee:	6942                	ld	s2,16(sp)
    800051f0:	69a2                	ld	s3,8(sp)
    800051f2:	6145                	addi	sp,sp,48
    800051f4:	8082                	ret

00000000800051f6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800051f6:	1101                	addi	sp,sp,-32
    800051f8:	ec06                	sd	ra,24(sp)
    800051fa:	e822                	sd	s0,16(sp)
    800051fc:	e426                	sd	s1,8(sp)
    800051fe:	e04a                	sd	s2,0(sp)
    80005200:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80005202:	00039517          	auipc	a0,0x39
    80005206:	8c650513          	addi	a0,a0,-1850 # 8003dac8 <log>
    8000520a:	ffffc097          	auipc	ra,0xffffc
    8000520e:	9bc080e7          	jalr	-1604(ra) # 80000bc6 <acquire>
  while(1){
    if(log.committing){
    80005212:	00039497          	auipc	s1,0x39
    80005216:	8b648493          	addi	s1,s1,-1866 # 8003dac8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000521a:	4979                	li	s2,30
    8000521c:	a039                	j	8000522a <begin_op+0x34>
      sleep(&log, &log.lock);
    8000521e:	85a6                	mv	a1,s1
    80005220:	8526                	mv	a0,s1
    80005222:	ffffd097          	auipc	ra,0xffffd
    80005226:	1c8080e7          	jalr	456(ra) # 800023ea <sleep>
    if(log.committing){
    8000522a:	50dc                	lw	a5,36(s1)
    8000522c:	fbed                	bnez	a5,8000521e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000522e:	509c                	lw	a5,32(s1)
    80005230:	0017871b          	addiw	a4,a5,1
    80005234:	0007069b          	sext.w	a3,a4
    80005238:	0027179b          	slliw	a5,a4,0x2
    8000523c:	9fb9                	addw	a5,a5,a4
    8000523e:	0017979b          	slliw	a5,a5,0x1
    80005242:	54d8                	lw	a4,44(s1)
    80005244:	9fb9                	addw	a5,a5,a4
    80005246:	00f95963          	bge	s2,a5,80005258 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000524a:	85a6                	mv	a1,s1
    8000524c:	8526                	mv	a0,s1
    8000524e:	ffffd097          	auipc	ra,0xffffd
    80005252:	19c080e7          	jalr	412(ra) # 800023ea <sleep>
    80005256:	bfd1                	j	8000522a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80005258:	00039517          	auipc	a0,0x39
    8000525c:	87050513          	addi	a0,a0,-1936 # 8003dac8 <log>
    80005260:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80005262:	ffffc097          	auipc	ra,0xffffc
    80005266:	a2e080e7          	jalr	-1490(ra) # 80000c90 <release>
      break;
    }
  }
}
    8000526a:	60e2                	ld	ra,24(sp)
    8000526c:	6442                	ld	s0,16(sp)
    8000526e:	64a2                	ld	s1,8(sp)
    80005270:	6902                	ld	s2,0(sp)
    80005272:	6105                	addi	sp,sp,32
    80005274:	8082                	ret

0000000080005276 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80005276:	7139                	addi	sp,sp,-64
    80005278:	fc06                	sd	ra,56(sp)
    8000527a:	f822                	sd	s0,48(sp)
    8000527c:	f426                	sd	s1,40(sp)
    8000527e:	f04a                	sd	s2,32(sp)
    80005280:	ec4e                	sd	s3,24(sp)
    80005282:	e852                	sd	s4,16(sp)
    80005284:	e456                	sd	s5,8(sp)
    80005286:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80005288:	00039497          	auipc	s1,0x39
    8000528c:	84048493          	addi	s1,s1,-1984 # 8003dac8 <log>
    80005290:	8526                	mv	a0,s1
    80005292:	ffffc097          	auipc	ra,0xffffc
    80005296:	934080e7          	jalr	-1740(ra) # 80000bc6 <acquire>
  log.outstanding -= 1;
    8000529a:	509c                	lw	a5,32(s1)
    8000529c:	37fd                	addiw	a5,a5,-1
    8000529e:	0007891b          	sext.w	s2,a5
    800052a2:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800052a4:	50dc                	lw	a5,36(s1)
    800052a6:	e7b9                	bnez	a5,800052f4 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800052a8:	04091e63          	bnez	s2,80005304 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800052ac:	00039497          	auipc	s1,0x39
    800052b0:	81c48493          	addi	s1,s1,-2020 # 8003dac8 <log>
    800052b4:	4785                	li	a5,1
    800052b6:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800052b8:	8526                	mv	a0,s1
    800052ba:	ffffc097          	auipc	ra,0xffffc
    800052be:	9d6080e7          	jalr	-1578(ra) # 80000c90 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800052c2:	54dc                	lw	a5,44(s1)
    800052c4:	06f04763          	bgtz	a5,80005332 <end_op+0xbc>
    acquire(&log.lock);
    800052c8:	00039497          	auipc	s1,0x39
    800052cc:	80048493          	addi	s1,s1,-2048 # 8003dac8 <log>
    800052d0:	8526                	mv	a0,s1
    800052d2:	ffffc097          	auipc	ra,0xffffc
    800052d6:	8f4080e7          	jalr	-1804(ra) # 80000bc6 <acquire>
    log.committing = 0;
    800052da:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800052de:	8526                	mv	a0,s1
    800052e0:	ffffd097          	auipc	ra,0xffffd
    800052e4:	294080e7          	jalr	660(ra) # 80002574 <wakeup>
    release(&log.lock);
    800052e8:	8526                	mv	a0,s1
    800052ea:	ffffc097          	auipc	ra,0xffffc
    800052ee:	9a6080e7          	jalr	-1626(ra) # 80000c90 <release>
}
    800052f2:	a03d                	j	80005320 <end_op+0xaa>
    panic("log.committing");
    800052f4:	00004517          	auipc	a0,0x4
    800052f8:	67c50513          	addi	a0,a0,1660 # 80009970 <syscalls+0x218>
    800052fc:	ffffb097          	auipc	ra,0xffffb
    80005300:	232080e7          	jalr	562(ra) # 8000052e <panic>
    wakeup(&log);
    80005304:	00038497          	auipc	s1,0x38
    80005308:	7c448493          	addi	s1,s1,1988 # 8003dac8 <log>
    8000530c:	8526                	mv	a0,s1
    8000530e:	ffffd097          	auipc	ra,0xffffd
    80005312:	266080e7          	jalr	614(ra) # 80002574 <wakeup>
  release(&log.lock);
    80005316:	8526                	mv	a0,s1
    80005318:	ffffc097          	auipc	ra,0xffffc
    8000531c:	978080e7          	jalr	-1672(ra) # 80000c90 <release>
}
    80005320:	70e2                	ld	ra,56(sp)
    80005322:	7442                	ld	s0,48(sp)
    80005324:	74a2                	ld	s1,40(sp)
    80005326:	7902                	ld	s2,32(sp)
    80005328:	69e2                	ld	s3,24(sp)
    8000532a:	6a42                	ld	s4,16(sp)
    8000532c:	6aa2                	ld	s5,8(sp)
    8000532e:	6121                	addi	sp,sp,64
    80005330:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80005332:	00038a97          	auipc	s5,0x38
    80005336:	7c6a8a93          	addi	s5,s5,1990 # 8003daf8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000533a:	00038a17          	auipc	s4,0x38
    8000533e:	78ea0a13          	addi	s4,s4,1934 # 8003dac8 <log>
    80005342:	018a2583          	lw	a1,24(s4)
    80005346:	012585bb          	addw	a1,a1,s2
    8000534a:	2585                	addiw	a1,a1,1
    8000534c:	028a2503          	lw	a0,40(s4)
    80005350:	fffff097          	auipc	ra,0xfffff
    80005354:	cce080e7          	jalr	-818(ra) # 8000401e <bread>
    80005358:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000535a:	000aa583          	lw	a1,0(s5)
    8000535e:	028a2503          	lw	a0,40(s4)
    80005362:	fffff097          	auipc	ra,0xfffff
    80005366:	cbc080e7          	jalr	-836(ra) # 8000401e <bread>
    8000536a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000536c:	40000613          	li	a2,1024
    80005370:	05850593          	addi	a1,a0,88
    80005374:	05848513          	addi	a0,s1,88
    80005378:	ffffc097          	auipc	ra,0xffffc
    8000537c:	9bc080e7          	jalr	-1604(ra) # 80000d34 <memmove>
    bwrite(to);  // write the log
    80005380:	8526                	mv	a0,s1
    80005382:	fffff097          	auipc	ra,0xfffff
    80005386:	d8e080e7          	jalr	-626(ra) # 80004110 <bwrite>
    brelse(from);
    8000538a:	854e                	mv	a0,s3
    8000538c:	fffff097          	auipc	ra,0xfffff
    80005390:	dc2080e7          	jalr	-574(ra) # 8000414e <brelse>
    brelse(to);
    80005394:	8526                	mv	a0,s1
    80005396:	fffff097          	auipc	ra,0xfffff
    8000539a:	db8080e7          	jalr	-584(ra) # 8000414e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000539e:	2905                	addiw	s2,s2,1
    800053a0:	0a91                	addi	s5,s5,4
    800053a2:	02ca2783          	lw	a5,44(s4)
    800053a6:	f8f94ee3          	blt	s2,a5,80005342 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800053aa:	00000097          	auipc	ra,0x0
    800053ae:	c66080e7          	jalr	-922(ra) # 80005010 <write_head>
    install_trans(0); // Now install writes to home locations
    800053b2:	4501                	li	a0,0
    800053b4:	00000097          	auipc	ra,0x0
    800053b8:	cd8080e7          	jalr	-808(ra) # 8000508c <install_trans>
    log.lh.n = 0;
    800053bc:	00038797          	auipc	a5,0x38
    800053c0:	7207ac23          	sw	zero,1848(a5) # 8003daf4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800053c4:	00000097          	auipc	ra,0x0
    800053c8:	c4c080e7          	jalr	-948(ra) # 80005010 <write_head>
    800053cc:	bdf5                	j	800052c8 <end_op+0x52>

00000000800053ce <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800053ce:	1101                	addi	sp,sp,-32
    800053d0:	ec06                	sd	ra,24(sp)
    800053d2:	e822                	sd	s0,16(sp)
    800053d4:	e426                	sd	s1,8(sp)
    800053d6:	e04a                	sd	s2,0(sp)
    800053d8:	1000                	addi	s0,sp,32
    800053da:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800053dc:	00038917          	auipc	s2,0x38
    800053e0:	6ec90913          	addi	s2,s2,1772 # 8003dac8 <log>
    800053e4:	854a                	mv	a0,s2
    800053e6:	ffffb097          	auipc	ra,0xffffb
    800053ea:	7e0080e7          	jalr	2016(ra) # 80000bc6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800053ee:	02c92603          	lw	a2,44(s2)
    800053f2:	47f5                	li	a5,29
    800053f4:	06c7c563          	blt	a5,a2,8000545e <log_write+0x90>
    800053f8:	00038797          	auipc	a5,0x38
    800053fc:	6ec7a783          	lw	a5,1772(a5) # 8003dae4 <log+0x1c>
    80005400:	37fd                	addiw	a5,a5,-1
    80005402:	04f65e63          	bge	a2,a5,8000545e <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80005406:	00038797          	auipc	a5,0x38
    8000540a:	6e27a783          	lw	a5,1762(a5) # 8003dae8 <log+0x20>
    8000540e:	06f05063          	blez	a5,8000546e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80005412:	4781                	li	a5,0
    80005414:	06c05563          	blez	a2,8000547e <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80005418:	44cc                	lw	a1,12(s1)
    8000541a:	00038717          	auipc	a4,0x38
    8000541e:	6de70713          	addi	a4,a4,1758 # 8003daf8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80005422:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80005424:	4314                	lw	a3,0(a4)
    80005426:	04b68c63          	beq	a3,a1,8000547e <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000542a:	2785                	addiw	a5,a5,1
    8000542c:	0711                	addi	a4,a4,4
    8000542e:	fef61be3          	bne	a2,a5,80005424 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80005432:	0621                	addi	a2,a2,8
    80005434:	060a                	slli	a2,a2,0x2
    80005436:	00038797          	auipc	a5,0x38
    8000543a:	69278793          	addi	a5,a5,1682 # 8003dac8 <log>
    8000543e:	963e                	add	a2,a2,a5
    80005440:	44dc                	lw	a5,12(s1)
    80005442:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80005444:	8526                	mv	a0,s1
    80005446:	fffff097          	auipc	ra,0xfffff
    8000544a:	da6080e7          	jalr	-602(ra) # 800041ec <bpin>
    log.lh.n++;
    8000544e:	00038717          	auipc	a4,0x38
    80005452:	67a70713          	addi	a4,a4,1658 # 8003dac8 <log>
    80005456:	575c                	lw	a5,44(a4)
    80005458:	2785                	addiw	a5,a5,1
    8000545a:	d75c                	sw	a5,44(a4)
    8000545c:	a835                	j	80005498 <log_write+0xca>
    panic("too big a transaction");
    8000545e:	00004517          	auipc	a0,0x4
    80005462:	52250513          	addi	a0,a0,1314 # 80009980 <syscalls+0x228>
    80005466:	ffffb097          	auipc	ra,0xffffb
    8000546a:	0c8080e7          	jalr	200(ra) # 8000052e <panic>
    panic("log_write outside of trans");
    8000546e:	00004517          	auipc	a0,0x4
    80005472:	52a50513          	addi	a0,a0,1322 # 80009998 <syscalls+0x240>
    80005476:	ffffb097          	auipc	ra,0xffffb
    8000547a:	0b8080e7          	jalr	184(ra) # 8000052e <panic>
  log.lh.block[i] = b->blockno;
    8000547e:	00878713          	addi	a4,a5,8
    80005482:	00271693          	slli	a3,a4,0x2
    80005486:	00038717          	auipc	a4,0x38
    8000548a:	64270713          	addi	a4,a4,1602 # 8003dac8 <log>
    8000548e:	9736                	add	a4,a4,a3
    80005490:	44d4                	lw	a3,12(s1)
    80005492:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80005494:	faf608e3          	beq	a2,a5,80005444 <log_write+0x76>
  }
  release(&log.lock);
    80005498:	00038517          	auipc	a0,0x38
    8000549c:	63050513          	addi	a0,a0,1584 # 8003dac8 <log>
    800054a0:	ffffb097          	auipc	ra,0xffffb
    800054a4:	7f0080e7          	jalr	2032(ra) # 80000c90 <release>
}
    800054a8:	60e2                	ld	ra,24(sp)
    800054aa:	6442                	ld	s0,16(sp)
    800054ac:	64a2                	ld	s1,8(sp)
    800054ae:	6902                	ld	s2,0(sp)
    800054b0:	6105                	addi	sp,sp,32
    800054b2:	8082                	ret

00000000800054b4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800054b4:	1101                	addi	sp,sp,-32
    800054b6:	ec06                	sd	ra,24(sp)
    800054b8:	e822                	sd	s0,16(sp)
    800054ba:	e426                	sd	s1,8(sp)
    800054bc:	e04a                	sd	s2,0(sp)
    800054be:	1000                	addi	s0,sp,32
    800054c0:	84aa                	mv	s1,a0
    800054c2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800054c4:	00004597          	auipc	a1,0x4
    800054c8:	4f458593          	addi	a1,a1,1268 # 800099b8 <syscalls+0x260>
    800054cc:	0521                	addi	a0,a0,8
    800054ce:	ffffb097          	auipc	ra,0xffffb
    800054d2:	668080e7          	jalr	1640(ra) # 80000b36 <initlock>
  lk->name = name;
    800054d6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800054da:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800054de:	0204a423          	sw	zero,40(s1)
}
    800054e2:	60e2                	ld	ra,24(sp)
    800054e4:	6442                	ld	s0,16(sp)
    800054e6:	64a2                	ld	s1,8(sp)
    800054e8:	6902                	ld	s2,0(sp)
    800054ea:	6105                	addi	sp,sp,32
    800054ec:	8082                	ret

00000000800054ee <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800054ee:	1101                	addi	sp,sp,-32
    800054f0:	ec06                	sd	ra,24(sp)
    800054f2:	e822                	sd	s0,16(sp)
    800054f4:	e426                	sd	s1,8(sp)
    800054f6:	e04a                	sd	s2,0(sp)
    800054f8:	1000                	addi	s0,sp,32
    800054fa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800054fc:	00850913          	addi	s2,a0,8
    80005500:	854a                	mv	a0,s2
    80005502:	ffffb097          	auipc	ra,0xffffb
    80005506:	6c4080e7          	jalr	1732(ra) # 80000bc6 <acquire>
  while (lk->locked) {
    8000550a:	409c                	lw	a5,0(s1)
    8000550c:	cb89                	beqz	a5,8000551e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000550e:	85ca                	mv	a1,s2
    80005510:	8526                	mv	a0,s1
    80005512:	ffffd097          	auipc	ra,0xffffd
    80005516:	ed8080e7          	jalr	-296(ra) # 800023ea <sleep>
  while (lk->locked) {
    8000551a:	409c                	lw	a5,0(s1)
    8000551c:	fbed                	bnez	a5,8000550e <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000551e:	4785                	li	a5,1
    80005520:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80005522:	ffffc097          	auipc	ra,0xffffc
    80005526:	54e080e7          	jalr	1358(ra) # 80001a70 <myproc>
    8000552a:	515c                	lw	a5,36(a0)
    8000552c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000552e:	854a                	mv	a0,s2
    80005530:	ffffb097          	auipc	ra,0xffffb
    80005534:	760080e7          	jalr	1888(ra) # 80000c90 <release>
}
    80005538:	60e2                	ld	ra,24(sp)
    8000553a:	6442                	ld	s0,16(sp)
    8000553c:	64a2                	ld	s1,8(sp)
    8000553e:	6902                	ld	s2,0(sp)
    80005540:	6105                	addi	sp,sp,32
    80005542:	8082                	ret

0000000080005544 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005544:	1101                	addi	sp,sp,-32
    80005546:	ec06                	sd	ra,24(sp)
    80005548:	e822                	sd	s0,16(sp)
    8000554a:	e426                	sd	s1,8(sp)
    8000554c:	e04a                	sd	s2,0(sp)
    8000554e:	1000                	addi	s0,sp,32
    80005550:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005552:	00850913          	addi	s2,a0,8
    80005556:	854a                	mv	a0,s2
    80005558:	ffffb097          	auipc	ra,0xffffb
    8000555c:	66e080e7          	jalr	1646(ra) # 80000bc6 <acquire>
  lk->locked = 0;
    80005560:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005564:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80005568:	8526                	mv	a0,s1
    8000556a:	ffffd097          	auipc	ra,0xffffd
    8000556e:	00a080e7          	jalr	10(ra) # 80002574 <wakeup>
  release(&lk->lk);
    80005572:	854a                	mv	a0,s2
    80005574:	ffffb097          	auipc	ra,0xffffb
    80005578:	71c080e7          	jalr	1820(ra) # 80000c90 <release>
}
    8000557c:	60e2                	ld	ra,24(sp)
    8000557e:	6442                	ld	s0,16(sp)
    80005580:	64a2                	ld	s1,8(sp)
    80005582:	6902                	ld	s2,0(sp)
    80005584:	6105                	addi	sp,sp,32
    80005586:	8082                	ret

0000000080005588 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80005588:	7179                	addi	sp,sp,-48
    8000558a:	f406                	sd	ra,40(sp)
    8000558c:	f022                	sd	s0,32(sp)
    8000558e:	ec26                	sd	s1,24(sp)
    80005590:	e84a                	sd	s2,16(sp)
    80005592:	e44e                	sd	s3,8(sp)
    80005594:	1800                	addi	s0,sp,48
    80005596:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80005598:	00850913          	addi	s2,a0,8
    8000559c:	854a                	mv	a0,s2
    8000559e:	ffffb097          	auipc	ra,0xffffb
    800055a2:	628080e7          	jalr	1576(ra) # 80000bc6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800055a6:	409c                	lw	a5,0(s1)
    800055a8:	ef99                	bnez	a5,800055c6 <holdingsleep+0x3e>
    800055aa:	4481                	li	s1,0
  release(&lk->lk);
    800055ac:	854a                	mv	a0,s2
    800055ae:	ffffb097          	auipc	ra,0xffffb
    800055b2:	6e2080e7          	jalr	1762(ra) # 80000c90 <release>
  return r;
}
    800055b6:	8526                	mv	a0,s1
    800055b8:	70a2                	ld	ra,40(sp)
    800055ba:	7402                	ld	s0,32(sp)
    800055bc:	64e2                	ld	s1,24(sp)
    800055be:	6942                	ld	s2,16(sp)
    800055c0:	69a2                	ld	s3,8(sp)
    800055c2:	6145                	addi	sp,sp,48
    800055c4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800055c6:	0284a983          	lw	s3,40(s1)
    800055ca:	ffffc097          	auipc	ra,0xffffc
    800055ce:	4a6080e7          	jalr	1190(ra) # 80001a70 <myproc>
    800055d2:	5144                	lw	s1,36(a0)
    800055d4:	413484b3          	sub	s1,s1,s3
    800055d8:	0014b493          	seqz	s1,s1
    800055dc:	bfc1                	j	800055ac <holdingsleep+0x24>

00000000800055de <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800055de:	1141                	addi	sp,sp,-16
    800055e0:	e406                	sd	ra,8(sp)
    800055e2:	e022                	sd	s0,0(sp)
    800055e4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800055e6:	00004597          	auipc	a1,0x4
    800055ea:	3e258593          	addi	a1,a1,994 # 800099c8 <syscalls+0x270>
    800055ee:	00038517          	auipc	a0,0x38
    800055f2:	62250513          	addi	a0,a0,1570 # 8003dc10 <ftable>
    800055f6:	ffffb097          	auipc	ra,0xffffb
    800055fa:	540080e7          	jalr	1344(ra) # 80000b36 <initlock>
}
    800055fe:	60a2                	ld	ra,8(sp)
    80005600:	6402                	ld	s0,0(sp)
    80005602:	0141                	addi	sp,sp,16
    80005604:	8082                	ret

0000000080005606 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80005606:	1101                	addi	sp,sp,-32
    80005608:	ec06                	sd	ra,24(sp)
    8000560a:	e822                	sd	s0,16(sp)
    8000560c:	e426                	sd	s1,8(sp)
    8000560e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80005610:	00038517          	auipc	a0,0x38
    80005614:	60050513          	addi	a0,a0,1536 # 8003dc10 <ftable>
    80005618:	ffffb097          	auipc	ra,0xffffb
    8000561c:	5ae080e7          	jalr	1454(ra) # 80000bc6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005620:	00038497          	auipc	s1,0x38
    80005624:	60848493          	addi	s1,s1,1544 # 8003dc28 <ftable+0x18>
    80005628:	00039717          	auipc	a4,0x39
    8000562c:	5a070713          	addi	a4,a4,1440 # 8003ebc8 <ftable+0xfb8>
    if(f->ref == 0){
    80005630:	40dc                	lw	a5,4(s1)
    80005632:	cf99                	beqz	a5,80005650 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005634:	02848493          	addi	s1,s1,40
    80005638:	fee49ce3          	bne	s1,a4,80005630 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000563c:	00038517          	auipc	a0,0x38
    80005640:	5d450513          	addi	a0,a0,1492 # 8003dc10 <ftable>
    80005644:	ffffb097          	auipc	ra,0xffffb
    80005648:	64c080e7          	jalr	1612(ra) # 80000c90 <release>
  return 0;
    8000564c:	4481                	li	s1,0
    8000564e:	a819                	j	80005664 <filealloc+0x5e>
      f->ref = 1;
    80005650:	4785                	li	a5,1
    80005652:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005654:	00038517          	auipc	a0,0x38
    80005658:	5bc50513          	addi	a0,a0,1468 # 8003dc10 <ftable>
    8000565c:	ffffb097          	auipc	ra,0xffffb
    80005660:	634080e7          	jalr	1588(ra) # 80000c90 <release>
}
    80005664:	8526                	mv	a0,s1
    80005666:	60e2                	ld	ra,24(sp)
    80005668:	6442                	ld	s0,16(sp)
    8000566a:	64a2                	ld	s1,8(sp)
    8000566c:	6105                	addi	sp,sp,32
    8000566e:	8082                	ret

0000000080005670 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005670:	1101                	addi	sp,sp,-32
    80005672:	ec06                	sd	ra,24(sp)
    80005674:	e822                	sd	s0,16(sp)
    80005676:	e426                	sd	s1,8(sp)
    80005678:	1000                	addi	s0,sp,32
    8000567a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000567c:	00038517          	auipc	a0,0x38
    80005680:	59450513          	addi	a0,a0,1428 # 8003dc10 <ftable>
    80005684:	ffffb097          	auipc	ra,0xffffb
    80005688:	542080e7          	jalr	1346(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    8000568c:	40dc                	lw	a5,4(s1)
    8000568e:	02f05263          	blez	a5,800056b2 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80005692:	2785                	addiw	a5,a5,1
    80005694:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80005696:	00038517          	auipc	a0,0x38
    8000569a:	57a50513          	addi	a0,a0,1402 # 8003dc10 <ftable>
    8000569e:	ffffb097          	auipc	ra,0xffffb
    800056a2:	5f2080e7          	jalr	1522(ra) # 80000c90 <release>
  return f;
}
    800056a6:	8526                	mv	a0,s1
    800056a8:	60e2                	ld	ra,24(sp)
    800056aa:	6442                	ld	s0,16(sp)
    800056ac:	64a2                	ld	s1,8(sp)
    800056ae:	6105                	addi	sp,sp,32
    800056b0:	8082                	ret
    panic("filedup");
    800056b2:	00004517          	auipc	a0,0x4
    800056b6:	31e50513          	addi	a0,a0,798 # 800099d0 <syscalls+0x278>
    800056ba:	ffffb097          	auipc	ra,0xffffb
    800056be:	e74080e7          	jalr	-396(ra) # 8000052e <panic>

00000000800056c2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800056c2:	7139                	addi	sp,sp,-64
    800056c4:	fc06                	sd	ra,56(sp)
    800056c6:	f822                	sd	s0,48(sp)
    800056c8:	f426                	sd	s1,40(sp)
    800056ca:	f04a                	sd	s2,32(sp)
    800056cc:	ec4e                	sd	s3,24(sp)
    800056ce:	e852                	sd	s4,16(sp)
    800056d0:	e456                	sd	s5,8(sp)
    800056d2:	0080                	addi	s0,sp,64
    800056d4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800056d6:	00038517          	auipc	a0,0x38
    800056da:	53a50513          	addi	a0,a0,1338 # 8003dc10 <ftable>
    800056de:	ffffb097          	auipc	ra,0xffffb
    800056e2:	4e8080e7          	jalr	1256(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    800056e6:	40dc                	lw	a5,4(s1)
    800056e8:	06f05163          	blez	a5,8000574a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800056ec:	37fd                	addiw	a5,a5,-1
    800056ee:	0007871b          	sext.w	a4,a5
    800056f2:	c0dc                	sw	a5,4(s1)
    800056f4:	06e04363          	bgtz	a4,8000575a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800056f8:	0004a903          	lw	s2,0(s1)
    800056fc:	0094ca83          	lbu	s5,9(s1)
    80005700:	0104ba03          	ld	s4,16(s1)
    80005704:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80005708:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000570c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005710:	00038517          	auipc	a0,0x38
    80005714:	50050513          	addi	a0,a0,1280 # 8003dc10 <ftable>
    80005718:	ffffb097          	auipc	ra,0xffffb
    8000571c:	578080e7          	jalr	1400(ra) # 80000c90 <release>

  if(ff.type == FD_PIPE){
    80005720:	4785                	li	a5,1
    80005722:	04f90d63          	beq	s2,a5,8000577c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80005726:	3979                	addiw	s2,s2,-2
    80005728:	4785                	li	a5,1
    8000572a:	0527e063          	bltu	a5,s2,8000576a <fileclose+0xa8>
    begin_op();
    8000572e:	00000097          	auipc	ra,0x0
    80005732:	ac8080e7          	jalr	-1336(ra) # 800051f6 <begin_op>
    iput(ff.ip);
    80005736:	854e                	mv	a0,s3
    80005738:	fffff097          	auipc	ra,0xfffff
    8000573c:	2a4080e7          	jalr	676(ra) # 800049dc <iput>
    end_op();
    80005740:	00000097          	auipc	ra,0x0
    80005744:	b36080e7          	jalr	-1226(ra) # 80005276 <end_op>
    80005748:	a00d                	j	8000576a <fileclose+0xa8>
    panic("fileclose");
    8000574a:	00004517          	auipc	a0,0x4
    8000574e:	28e50513          	addi	a0,a0,654 # 800099d8 <syscalls+0x280>
    80005752:	ffffb097          	auipc	ra,0xffffb
    80005756:	ddc080e7          	jalr	-548(ra) # 8000052e <panic>
    release(&ftable.lock);
    8000575a:	00038517          	auipc	a0,0x38
    8000575e:	4b650513          	addi	a0,a0,1206 # 8003dc10 <ftable>
    80005762:	ffffb097          	auipc	ra,0xffffb
    80005766:	52e080e7          	jalr	1326(ra) # 80000c90 <release>
  }
}
    8000576a:	70e2                	ld	ra,56(sp)
    8000576c:	7442                	ld	s0,48(sp)
    8000576e:	74a2                	ld	s1,40(sp)
    80005770:	7902                	ld	s2,32(sp)
    80005772:	69e2                	ld	s3,24(sp)
    80005774:	6a42                	ld	s4,16(sp)
    80005776:	6aa2                	ld	s5,8(sp)
    80005778:	6121                	addi	sp,sp,64
    8000577a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000577c:	85d6                	mv	a1,s5
    8000577e:	8552                	mv	a0,s4
    80005780:	00000097          	auipc	ra,0x0
    80005784:	34c080e7          	jalr	844(ra) # 80005acc <pipeclose>
    80005788:	b7cd                	j	8000576a <fileclose+0xa8>

000000008000578a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000578a:	715d                	addi	sp,sp,-80
    8000578c:	e486                	sd	ra,72(sp)
    8000578e:	e0a2                	sd	s0,64(sp)
    80005790:	fc26                	sd	s1,56(sp)
    80005792:	f84a                	sd	s2,48(sp)
    80005794:	f44e                	sd	s3,40(sp)
    80005796:	0880                	addi	s0,sp,80
    80005798:	84aa                	mv	s1,a0
    8000579a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000579c:	ffffc097          	auipc	ra,0xffffc
    800057a0:	2d4080e7          	jalr	724(ra) # 80001a70 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800057a4:	409c                	lw	a5,0(s1)
    800057a6:	37f9                	addiw	a5,a5,-2
    800057a8:	4705                	li	a4,1
    800057aa:	04f76763          	bltu	a4,a5,800057f8 <filestat+0x6e>
    800057ae:	892a                	mv	s2,a0
    ilock(f->ip);
    800057b0:	6c88                	ld	a0,24(s1)
    800057b2:	fffff097          	auipc	ra,0xfffff
    800057b6:	070080e7          	jalr	112(ra) # 80004822 <ilock>
    stati(f->ip, &st);
    800057ba:	fb840593          	addi	a1,s0,-72
    800057be:	6c88                	ld	a0,24(s1)
    800057c0:	fffff097          	auipc	ra,0xfffff
    800057c4:	2ec080e7          	jalr	748(ra) # 80004aac <stati>
    iunlock(f->ip);
    800057c8:	6c88                	ld	a0,24(s1)
    800057ca:	fffff097          	auipc	ra,0xfffff
    800057ce:	11a080e7          	jalr	282(ra) # 800048e4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800057d2:	46e1                	li	a3,24
    800057d4:	fb840613          	addi	a2,s0,-72
    800057d8:	85ce                	mv	a1,s3
    800057da:	04093503          	ld	a0,64(s2)
    800057de:	ffffc097          	auipc	ra,0xffffc
    800057e2:	e7a080e7          	jalr	-390(ra) # 80001658 <copyout>
    800057e6:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800057ea:	60a6                	ld	ra,72(sp)
    800057ec:	6406                	ld	s0,64(sp)
    800057ee:	74e2                	ld	s1,56(sp)
    800057f0:	7942                	ld	s2,48(sp)
    800057f2:	79a2                	ld	s3,40(sp)
    800057f4:	6161                	addi	sp,sp,80
    800057f6:	8082                	ret
  return -1;
    800057f8:	557d                	li	a0,-1
    800057fa:	bfc5                	j	800057ea <filestat+0x60>

00000000800057fc <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800057fc:	7179                	addi	sp,sp,-48
    800057fe:	f406                	sd	ra,40(sp)
    80005800:	f022                	sd	s0,32(sp)
    80005802:	ec26                	sd	s1,24(sp)
    80005804:	e84a                	sd	s2,16(sp)
    80005806:	e44e                	sd	s3,8(sp)
    80005808:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000580a:	00854783          	lbu	a5,8(a0)
    8000580e:	c3d5                	beqz	a5,800058b2 <fileread+0xb6>
    80005810:	84aa                	mv	s1,a0
    80005812:	89ae                	mv	s3,a1
    80005814:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005816:	411c                	lw	a5,0(a0)
    80005818:	4705                	li	a4,1
    8000581a:	04e78963          	beq	a5,a4,8000586c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000581e:	470d                	li	a4,3
    80005820:	04e78d63          	beq	a5,a4,8000587a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005824:	4709                	li	a4,2
    80005826:	06e79e63          	bne	a5,a4,800058a2 <fileread+0xa6>
    ilock(f->ip);
    8000582a:	6d08                	ld	a0,24(a0)
    8000582c:	fffff097          	auipc	ra,0xfffff
    80005830:	ff6080e7          	jalr	-10(ra) # 80004822 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005834:	874a                	mv	a4,s2
    80005836:	5094                	lw	a3,32(s1)
    80005838:	864e                	mv	a2,s3
    8000583a:	4585                	li	a1,1
    8000583c:	6c88                	ld	a0,24(s1)
    8000583e:	fffff097          	auipc	ra,0xfffff
    80005842:	298080e7          	jalr	664(ra) # 80004ad6 <readi>
    80005846:	892a                	mv	s2,a0
    80005848:	00a05563          	blez	a0,80005852 <fileread+0x56>
      f->off += r;
    8000584c:	509c                	lw	a5,32(s1)
    8000584e:	9fa9                	addw	a5,a5,a0
    80005850:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005852:	6c88                	ld	a0,24(s1)
    80005854:	fffff097          	auipc	ra,0xfffff
    80005858:	090080e7          	jalr	144(ra) # 800048e4 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000585c:	854a                	mv	a0,s2
    8000585e:	70a2                	ld	ra,40(sp)
    80005860:	7402                	ld	s0,32(sp)
    80005862:	64e2                	ld	s1,24(sp)
    80005864:	6942                	ld	s2,16(sp)
    80005866:	69a2                	ld	s3,8(sp)
    80005868:	6145                	addi	sp,sp,48
    8000586a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000586c:	6908                	ld	a0,16(a0)
    8000586e:	00000097          	auipc	ra,0x0
    80005872:	3c8080e7          	jalr	968(ra) # 80005c36 <piperead>
    80005876:	892a                	mv	s2,a0
    80005878:	b7d5                	j	8000585c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000587a:	02451783          	lh	a5,36(a0)
    8000587e:	03079693          	slli	a3,a5,0x30
    80005882:	92c1                	srli	a3,a3,0x30
    80005884:	4725                	li	a4,9
    80005886:	02d76863          	bltu	a4,a3,800058b6 <fileread+0xba>
    8000588a:	0792                	slli	a5,a5,0x4
    8000588c:	00038717          	auipc	a4,0x38
    80005890:	2e470713          	addi	a4,a4,740 # 8003db70 <devsw>
    80005894:	97ba                	add	a5,a5,a4
    80005896:	639c                	ld	a5,0(a5)
    80005898:	c38d                	beqz	a5,800058ba <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000589a:	4505                	li	a0,1
    8000589c:	9782                	jalr	a5
    8000589e:	892a                	mv	s2,a0
    800058a0:	bf75                	j	8000585c <fileread+0x60>
    panic("fileread");
    800058a2:	00004517          	auipc	a0,0x4
    800058a6:	14650513          	addi	a0,a0,326 # 800099e8 <syscalls+0x290>
    800058aa:	ffffb097          	auipc	ra,0xffffb
    800058ae:	c84080e7          	jalr	-892(ra) # 8000052e <panic>
    return -1;
    800058b2:	597d                	li	s2,-1
    800058b4:	b765                	j	8000585c <fileread+0x60>
      return -1;
    800058b6:	597d                	li	s2,-1
    800058b8:	b755                	j	8000585c <fileread+0x60>
    800058ba:	597d                	li	s2,-1
    800058bc:	b745                	j	8000585c <fileread+0x60>

00000000800058be <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800058be:	715d                	addi	sp,sp,-80
    800058c0:	e486                	sd	ra,72(sp)
    800058c2:	e0a2                	sd	s0,64(sp)
    800058c4:	fc26                	sd	s1,56(sp)
    800058c6:	f84a                	sd	s2,48(sp)
    800058c8:	f44e                	sd	s3,40(sp)
    800058ca:	f052                	sd	s4,32(sp)
    800058cc:	ec56                	sd	s5,24(sp)
    800058ce:	e85a                	sd	s6,16(sp)
    800058d0:	e45e                	sd	s7,8(sp)
    800058d2:	e062                	sd	s8,0(sp)
    800058d4:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800058d6:	00954783          	lbu	a5,9(a0)
    800058da:	10078663          	beqz	a5,800059e6 <filewrite+0x128>
    800058de:	892a                	mv	s2,a0
    800058e0:	8aae                	mv	s5,a1
    800058e2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800058e4:	411c                	lw	a5,0(a0)
    800058e6:	4705                	li	a4,1
    800058e8:	02e78263          	beq	a5,a4,8000590c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800058ec:	470d                	li	a4,3
    800058ee:	02e78663          	beq	a5,a4,8000591a <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800058f2:	4709                	li	a4,2
    800058f4:	0ee79163          	bne	a5,a4,800059d6 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800058f8:	0ac05d63          	blez	a2,800059b2 <filewrite+0xf4>
    int i = 0;
    800058fc:	4981                	li	s3,0
    800058fe:	6b05                	lui	s6,0x1
    80005900:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005904:	6b85                	lui	s7,0x1
    80005906:	c00b8b9b          	addiw	s7,s7,-1024
    8000590a:	a861                	j	800059a2 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000590c:	6908                	ld	a0,16(a0)
    8000590e:	00000097          	auipc	ra,0x0
    80005912:	22e080e7          	jalr	558(ra) # 80005b3c <pipewrite>
    80005916:	8a2a                	mv	s4,a0
    80005918:	a045                	j	800059b8 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000591a:	02451783          	lh	a5,36(a0)
    8000591e:	03079693          	slli	a3,a5,0x30
    80005922:	92c1                	srli	a3,a3,0x30
    80005924:	4725                	li	a4,9
    80005926:	0cd76263          	bltu	a4,a3,800059ea <filewrite+0x12c>
    8000592a:	0792                	slli	a5,a5,0x4
    8000592c:	00038717          	auipc	a4,0x38
    80005930:	24470713          	addi	a4,a4,580 # 8003db70 <devsw>
    80005934:	97ba                	add	a5,a5,a4
    80005936:	679c                	ld	a5,8(a5)
    80005938:	cbdd                	beqz	a5,800059ee <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    8000593a:	4505                	li	a0,1
    8000593c:	9782                	jalr	a5
    8000593e:	8a2a                	mv	s4,a0
    80005940:	a8a5                	j	800059b8 <filewrite+0xfa>
    80005942:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005946:	00000097          	auipc	ra,0x0
    8000594a:	8b0080e7          	jalr	-1872(ra) # 800051f6 <begin_op>
      ilock(f->ip);
    8000594e:	01893503          	ld	a0,24(s2)
    80005952:	fffff097          	auipc	ra,0xfffff
    80005956:	ed0080e7          	jalr	-304(ra) # 80004822 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000595a:	8762                	mv	a4,s8
    8000595c:	02092683          	lw	a3,32(s2)
    80005960:	01598633          	add	a2,s3,s5
    80005964:	4585                	li	a1,1
    80005966:	01893503          	ld	a0,24(s2)
    8000596a:	fffff097          	auipc	ra,0xfffff
    8000596e:	264080e7          	jalr	612(ra) # 80004bce <writei>
    80005972:	84aa                	mv	s1,a0
    80005974:	00a05763          	blez	a0,80005982 <filewrite+0xc4>
        f->off += r;
    80005978:	02092783          	lw	a5,32(s2)
    8000597c:	9fa9                	addw	a5,a5,a0
    8000597e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005982:	01893503          	ld	a0,24(s2)
    80005986:	fffff097          	auipc	ra,0xfffff
    8000598a:	f5e080e7          	jalr	-162(ra) # 800048e4 <iunlock>
      end_op();
    8000598e:	00000097          	auipc	ra,0x0
    80005992:	8e8080e7          	jalr	-1816(ra) # 80005276 <end_op>

      if(r != n1){
    80005996:	009c1f63          	bne	s8,s1,800059b4 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000599a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000599e:	0149db63          	bge	s3,s4,800059b4 <filewrite+0xf6>
      int n1 = n - i;
    800059a2:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800059a6:	84be                	mv	s1,a5
    800059a8:	2781                	sext.w	a5,a5
    800059aa:	f8fb5ce3          	bge	s6,a5,80005942 <filewrite+0x84>
    800059ae:	84de                	mv	s1,s7
    800059b0:	bf49                	j	80005942 <filewrite+0x84>
    int i = 0;
    800059b2:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800059b4:	013a1f63          	bne	s4,s3,800059d2 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800059b8:	8552                	mv	a0,s4
    800059ba:	60a6                	ld	ra,72(sp)
    800059bc:	6406                	ld	s0,64(sp)
    800059be:	74e2                	ld	s1,56(sp)
    800059c0:	7942                	ld	s2,48(sp)
    800059c2:	79a2                	ld	s3,40(sp)
    800059c4:	7a02                	ld	s4,32(sp)
    800059c6:	6ae2                	ld	s5,24(sp)
    800059c8:	6b42                	ld	s6,16(sp)
    800059ca:	6ba2                	ld	s7,8(sp)
    800059cc:	6c02                	ld	s8,0(sp)
    800059ce:	6161                	addi	sp,sp,80
    800059d0:	8082                	ret
    ret = (i == n ? n : -1);
    800059d2:	5a7d                	li	s4,-1
    800059d4:	b7d5                	j	800059b8 <filewrite+0xfa>
    panic("filewrite");
    800059d6:	00004517          	auipc	a0,0x4
    800059da:	02250513          	addi	a0,a0,34 # 800099f8 <syscalls+0x2a0>
    800059de:	ffffb097          	auipc	ra,0xffffb
    800059e2:	b50080e7          	jalr	-1200(ra) # 8000052e <panic>
    return -1;
    800059e6:	5a7d                	li	s4,-1
    800059e8:	bfc1                	j	800059b8 <filewrite+0xfa>
      return -1;
    800059ea:	5a7d                	li	s4,-1
    800059ec:	b7f1                	j	800059b8 <filewrite+0xfa>
    800059ee:	5a7d                	li	s4,-1
    800059f0:	b7e1                	j	800059b8 <filewrite+0xfa>

00000000800059f2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800059f2:	7179                	addi	sp,sp,-48
    800059f4:	f406                	sd	ra,40(sp)
    800059f6:	f022                	sd	s0,32(sp)
    800059f8:	ec26                	sd	s1,24(sp)
    800059fa:	e84a                	sd	s2,16(sp)
    800059fc:	e44e                	sd	s3,8(sp)
    800059fe:	e052                	sd	s4,0(sp)
    80005a00:	1800                	addi	s0,sp,48
    80005a02:	84aa                	mv	s1,a0
    80005a04:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005a06:	0005b023          	sd	zero,0(a1)
    80005a0a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005a0e:	00000097          	auipc	ra,0x0
    80005a12:	bf8080e7          	jalr	-1032(ra) # 80005606 <filealloc>
    80005a16:	e088                	sd	a0,0(s1)
    80005a18:	c551                	beqz	a0,80005aa4 <pipealloc+0xb2>
    80005a1a:	00000097          	auipc	ra,0x0
    80005a1e:	bec080e7          	jalr	-1044(ra) # 80005606 <filealloc>
    80005a22:	00aa3023          	sd	a0,0(s4)
    80005a26:	c92d                	beqz	a0,80005a98 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005a28:	ffffb097          	auipc	ra,0xffffb
    80005a2c:	0ae080e7          	jalr	174(ra) # 80000ad6 <kalloc>
    80005a30:	892a                	mv	s2,a0
    80005a32:	c125                	beqz	a0,80005a92 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005a34:	4985                	li	s3,1
    80005a36:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005a3a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005a3e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005a42:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005a46:	00004597          	auipc	a1,0x4
    80005a4a:	fc258593          	addi	a1,a1,-62 # 80009a08 <syscalls+0x2b0>
    80005a4e:	ffffb097          	auipc	ra,0xffffb
    80005a52:	0e8080e7          	jalr	232(ra) # 80000b36 <initlock>
  (*f0)->type = FD_PIPE;
    80005a56:	609c                	ld	a5,0(s1)
    80005a58:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005a5c:	609c                	ld	a5,0(s1)
    80005a5e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005a62:	609c                	ld	a5,0(s1)
    80005a64:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005a68:	609c                	ld	a5,0(s1)
    80005a6a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005a6e:	000a3783          	ld	a5,0(s4)
    80005a72:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005a76:	000a3783          	ld	a5,0(s4)
    80005a7a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005a7e:	000a3783          	ld	a5,0(s4)
    80005a82:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005a86:	000a3783          	ld	a5,0(s4)
    80005a8a:	0127b823          	sd	s2,16(a5)
  return 0;
    80005a8e:	4501                	li	a0,0
    80005a90:	a025                	j	80005ab8 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005a92:	6088                	ld	a0,0(s1)
    80005a94:	e501                	bnez	a0,80005a9c <pipealloc+0xaa>
    80005a96:	a039                	j	80005aa4 <pipealloc+0xb2>
    80005a98:	6088                	ld	a0,0(s1)
    80005a9a:	c51d                	beqz	a0,80005ac8 <pipealloc+0xd6>
    fileclose(*f0);
    80005a9c:	00000097          	auipc	ra,0x0
    80005aa0:	c26080e7          	jalr	-986(ra) # 800056c2 <fileclose>
  if(*f1)
    80005aa4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005aa8:	557d                	li	a0,-1
  if(*f1)
    80005aaa:	c799                	beqz	a5,80005ab8 <pipealloc+0xc6>
    fileclose(*f1);
    80005aac:	853e                	mv	a0,a5
    80005aae:	00000097          	auipc	ra,0x0
    80005ab2:	c14080e7          	jalr	-1004(ra) # 800056c2 <fileclose>
  return -1;
    80005ab6:	557d                	li	a0,-1
}
    80005ab8:	70a2                	ld	ra,40(sp)
    80005aba:	7402                	ld	s0,32(sp)
    80005abc:	64e2                	ld	s1,24(sp)
    80005abe:	6942                	ld	s2,16(sp)
    80005ac0:	69a2                	ld	s3,8(sp)
    80005ac2:	6a02                	ld	s4,0(sp)
    80005ac4:	6145                	addi	sp,sp,48
    80005ac6:	8082                	ret
  return -1;
    80005ac8:	557d                	li	a0,-1
    80005aca:	b7fd                	j	80005ab8 <pipealloc+0xc6>

0000000080005acc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005acc:	1101                	addi	sp,sp,-32
    80005ace:	ec06                	sd	ra,24(sp)
    80005ad0:	e822                	sd	s0,16(sp)
    80005ad2:	e426                	sd	s1,8(sp)
    80005ad4:	e04a                	sd	s2,0(sp)
    80005ad6:	1000                	addi	s0,sp,32
    80005ad8:	84aa                	mv	s1,a0
    80005ada:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005adc:	ffffb097          	auipc	ra,0xffffb
    80005ae0:	0ea080e7          	jalr	234(ra) # 80000bc6 <acquire>
  if(writable){
    80005ae4:	02090d63          	beqz	s2,80005b1e <pipeclose+0x52>
    pi->writeopen = 0;
    80005ae8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005aec:	21848513          	addi	a0,s1,536
    80005af0:	ffffd097          	auipc	ra,0xffffd
    80005af4:	a84080e7          	jalr	-1404(ra) # 80002574 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005af8:	2204b783          	ld	a5,544(s1)
    80005afc:	eb95                	bnez	a5,80005b30 <pipeclose+0x64>
    release(&pi->lock);
    80005afe:	8526                	mv	a0,s1
    80005b00:	ffffb097          	auipc	ra,0xffffb
    80005b04:	190080e7          	jalr	400(ra) # 80000c90 <release>
    kfree((char*)pi);
    80005b08:	8526                	mv	a0,s1
    80005b0a:	ffffb097          	auipc	ra,0xffffb
    80005b0e:	ed0080e7          	jalr	-304(ra) # 800009da <kfree>
  } else
    release(&pi->lock);
}
    80005b12:	60e2                	ld	ra,24(sp)
    80005b14:	6442                	ld	s0,16(sp)
    80005b16:	64a2                	ld	s1,8(sp)
    80005b18:	6902                	ld	s2,0(sp)
    80005b1a:	6105                	addi	sp,sp,32
    80005b1c:	8082                	ret
    pi->readopen = 0;
    80005b1e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005b22:	21c48513          	addi	a0,s1,540
    80005b26:	ffffd097          	auipc	ra,0xffffd
    80005b2a:	a4e080e7          	jalr	-1458(ra) # 80002574 <wakeup>
    80005b2e:	b7e9                	j	80005af8 <pipeclose+0x2c>
    release(&pi->lock);
    80005b30:	8526                	mv	a0,s1
    80005b32:	ffffb097          	auipc	ra,0xffffb
    80005b36:	15e080e7          	jalr	350(ra) # 80000c90 <release>
}
    80005b3a:	bfe1                	j	80005b12 <pipeclose+0x46>

0000000080005b3c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005b3c:	7159                	addi	sp,sp,-112
    80005b3e:	f486                	sd	ra,104(sp)
    80005b40:	f0a2                	sd	s0,96(sp)
    80005b42:	eca6                	sd	s1,88(sp)
    80005b44:	e8ca                	sd	s2,80(sp)
    80005b46:	e4ce                	sd	s3,72(sp)
    80005b48:	e0d2                	sd	s4,64(sp)
    80005b4a:	fc56                	sd	s5,56(sp)
    80005b4c:	f85a                	sd	s6,48(sp)
    80005b4e:	f45e                	sd	s7,40(sp)
    80005b50:	f062                	sd	s8,32(sp)
    80005b52:	ec66                	sd	s9,24(sp)
    80005b54:	1880                	addi	s0,sp,112
    80005b56:	84aa                	mv	s1,a0
    80005b58:	8b2e                	mv	s6,a1
    80005b5a:	8ab2                	mv	s5,a2
  int i = 0;
  struct proc *pr = myproc();
    80005b5c:	ffffc097          	auipc	ra,0xffffc
    80005b60:	f14080e7          	jalr	-236(ra) # 80001a70 <myproc>
    80005b64:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005b66:	8526                	mv	a0,s1
    80005b68:	ffffb097          	auipc	ra,0xffffb
    80005b6c:	05e080e7          	jalr	94(ra) # 80000bc6 <acquire>
  while(i < n){
    80005b70:	0b505663          	blez	s5,80005c1c <pipewrite+0xe0>
  int i = 0;
    80005b74:	4901                	li	s2,0
    if(pi->readopen == 0 || pr->killed==1){
    80005b76:	4a05                	li	s4,1
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005b78:	5bfd                	li	s7,-1
      wakeup(&pi->nread);
    80005b7a:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005b7e:	21c48c13          	addi	s8,s1,540
    80005b82:	a091                	j	80005bc6 <pipewrite+0x8a>
      release(&pi->lock);
    80005b84:	8526                	mv	a0,s1
    80005b86:	ffffb097          	auipc	ra,0xffffb
    80005b8a:	10a080e7          	jalr	266(ra) # 80000c90 <release>
      return -1;
    80005b8e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005b90:	854a                	mv	a0,s2
    80005b92:	70a6                	ld	ra,104(sp)
    80005b94:	7406                	ld	s0,96(sp)
    80005b96:	64e6                	ld	s1,88(sp)
    80005b98:	6946                	ld	s2,80(sp)
    80005b9a:	69a6                	ld	s3,72(sp)
    80005b9c:	6a06                	ld	s4,64(sp)
    80005b9e:	7ae2                	ld	s5,56(sp)
    80005ba0:	7b42                	ld	s6,48(sp)
    80005ba2:	7ba2                	ld	s7,40(sp)
    80005ba4:	7c02                	ld	s8,32(sp)
    80005ba6:	6ce2                	ld	s9,24(sp)
    80005ba8:	6165                	addi	sp,sp,112
    80005baa:	8082                	ret
      wakeup(&pi->nread);
    80005bac:	8566                	mv	a0,s9
    80005bae:	ffffd097          	auipc	ra,0xffffd
    80005bb2:	9c6080e7          	jalr	-1594(ra) # 80002574 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005bb6:	85a6                	mv	a1,s1
    80005bb8:	8562                	mv	a0,s8
    80005bba:	ffffd097          	auipc	ra,0xffffd
    80005bbe:	830080e7          	jalr	-2000(ra) # 800023ea <sleep>
  while(i < n){
    80005bc2:	05595e63          	bge	s2,s5,80005c1e <pipewrite+0xe2>
    if(pi->readopen == 0 || pr->killed==1){
    80005bc6:	2204a783          	lw	a5,544(s1)
    80005bca:	dfcd                	beqz	a5,80005b84 <pipewrite+0x48>
    80005bcc:	01c9a783          	lw	a5,28(s3)
    80005bd0:	fb478ae3          	beq	a5,s4,80005b84 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005bd4:	2184a783          	lw	a5,536(s1)
    80005bd8:	21c4a703          	lw	a4,540(s1)
    80005bdc:	2007879b          	addiw	a5,a5,512
    80005be0:	fcf706e3          	beq	a4,a5,80005bac <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005be4:	86d2                	mv	a3,s4
    80005be6:	01690633          	add	a2,s2,s6
    80005bea:	f9f40593          	addi	a1,s0,-97
    80005bee:	0409b503          	ld	a0,64(s3)
    80005bf2:	ffffc097          	auipc	ra,0xffffc
    80005bf6:	af2080e7          	jalr	-1294(ra) # 800016e4 <copyin>
    80005bfa:	03750263          	beq	a0,s7,80005c1e <pipewrite+0xe2>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005bfe:	21c4a783          	lw	a5,540(s1)
    80005c02:	0017871b          	addiw	a4,a5,1
    80005c06:	20e4ae23          	sw	a4,540(s1)
    80005c0a:	1ff7f793          	andi	a5,a5,511
    80005c0e:	97a6                	add	a5,a5,s1
    80005c10:	f9f44703          	lbu	a4,-97(s0)
    80005c14:	00e78c23          	sb	a4,24(a5)
      i++;
    80005c18:	2905                	addiw	s2,s2,1
    80005c1a:	b765                	j	80005bc2 <pipewrite+0x86>
  int i = 0;
    80005c1c:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005c1e:	21848513          	addi	a0,s1,536
    80005c22:	ffffd097          	auipc	ra,0xffffd
    80005c26:	952080e7          	jalr	-1710(ra) # 80002574 <wakeup>
  release(&pi->lock);
    80005c2a:	8526                	mv	a0,s1
    80005c2c:	ffffb097          	auipc	ra,0xffffb
    80005c30:	064080e7          	jalr	100(ra) # 80000c90 <release>
  return i;
    80005c34:	bfb1                	j	80005b90 <pipewrite+0x54>

0000000080005c36 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005c36:	715d                	addi	sp,sp,-80
    80005c38:	e486                	sd	ra,72(sp)
    80005c3a:	e0a2                	sd	s0,64(sp)
    80005c3c:	fc26                	sd	s1,56(sp)
    80005c3e:	f84a                	sd	s2,48(sp)
    80005c40:	f44e                	sd	s3,40(sp)
    80005c42:	f052                	sd	s4,32(sp)
    80005c44:	ec56                	sd	s5,24(sp)
    80005c46:	e85a                	sd	s6,16(sp)
    80005c48:	0880                	addi	s0,sp,80
    80005c4a:	84aa                	mv	s1,a0
    80005c4c:	892e                	mv	s2,a1
    80005c4e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005c50:	ffffc097          	auipc	ra,0xffffc
    80005c54:	e20080e7          	jalr	-480(ra) # 80001a70 <myproc>
    80005c58:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005c5a:	8526                	mv	a0,s1
    80005c5c:	ffffb097          	auipc	ra,0xffffb
    80005c60:	f6a080e7          	jalr	-150(ra) # 80000bc6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005c64:	2184a703          	lw	a4,536(s1)
    80005c68:	21c4a783          	lw	a5,540(s1)
    if(pr->killed==1){
    80005c6c:	4985                	li	s3,1
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005c6e:	21848b13          	addi	s6,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005c72:	02f71563          	bne	a4,a5,80005c9c <piperead+0x66>
    80005c76:	2244a783          	lw	a5,548(s1)
    80005c7a:	c38d                	beqz	a5,80005c9c <piperead+0x66>
    if(pr->killed==1){
    80005c7c:	01ca2783          	lw	a5,28(s4)
    80005c80:	09378963          	beq	a5,s3,80005d12 <piperead+0xdc>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005c84:	85a6                	mv	a1,s1
    80005c86:	855a                	mv	a0,s6
    80005c88:	ffffc097          	auipc	ra,0xffffc
    80005c8c:	762080e7          	jalr	1890(ra) # 800023ea <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005c90:	2184a703          	lw	a4,536(s1)
    80005c94:	21c4a783          	lw	a5,540(s1)
    80005c98:	fcf70fe3          	beq	a4,a5,80005c76 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005c9c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005c9e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005ca0:	05505363          	blez	s5,80005ce6 <piperead+0xb0>
    if(pi->nread == pi->nwrite)
    80005ca4:	2184a783          	lw	a5,536(s1)
    80005ca8:	21c4a703          	lw	a4,540(s1)
    80005cac:	02f70d63          	beq	a4,a5,80005ce6 <piperead+0xb0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005cb0:	0017871b          	addiw	a4,a5,1
    80005cb4:	20e4ac23          	sw	a4,536(s1)
    80005cb8:	1ff7f793          	andi	a5,a5,511
    80005cbc:	97a6                	add	a5,a5,s1
    80005cbe:	0187c783          	lbu	a5,24(a5)
    80005cc2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005cc6:	4685                	li	a3,1
    80005cc8:	fbf40613          	addi	a2,s0,-65
    80005ccc:	85ca                	mv	a1,s2
    80005cce:	040a3503          	ld	a0,64(s4)
    80005cd2:	ffffc097          	auipc	ra,0xffffc
    80005cd6:	986080e7          	jalr	-1658(ra) # 80001658 <copyout>
    80005cda:	01650663          	beq	a0,s6,80005ce6 <piperead+0xb0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005cde:	2985                	addiw	s3,s3,1
    80005ce0:	0905                	addi	s2,s2,1
    80005ce2:	fd3a91e3          	bne	s5,s3,80005ca4 <piperead+0x6e>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005ce6:	21c48513          	addi	a0,s1,540
    80005cea:	ffffd097          	auipc	ra,0xffffd
    80005cee:	88a080e7          	jalr	-1910(ra) # 80002574 <wakeup>
  release(&pi->lock);
    80005cf2:	8526                	mv	a0,s1
    80005cf4:	ffffb097          	auipc	ra,0xffffb
    80005cf8:	f9c080e7          	jalr	-100(ra) # 80000c90 <release>
  return i;
}
    80005cfc:	854e                	mv	a0,s3
    80005cfe:	60a6                	ld	ra,72(sp)
    80005d00:	6406                	ld	s0,64(sp)
    80005d02:	74e2                	ld	s1,56(sp)
    80005d04:	7942                	ld	s2,48(sp)
    80005d06:	79a2                	ld	s3,40(sp)
    80005d08:	7a02                	ld	s4,32(sp)
    80005d0a:	6ae2                	ld	s5,24(sp)
    80005d0c:	6b42                	ld	s6,16(sp)
    80005d0e:	6161                	addi	sp,sp,80
    80005d10:	8082                	ret
      release(&pi->lock);
    80005d12:	8526                	mv	a0,s1
    80005d14:	ffffb097          	auipc	ra,0xffffb
    80005d18:	f7c080e7          	jalr	-132(ra) # 80000c90 <release>
      return -1;
    80005d1c:	59fd                	li	s3,-1
    80005d1e:	bff9                	j	80005cfc <piperead+0xc6>

0000000080005d20 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005d20:	dd010113          	addi	sp,sp,-560
    80005d24:	22113423          	sd	ra,552(sp)
    80005d28:	22813023          	sd	s0,544(sp)
    80005d2c:	20913c23          	sd	s1,536(sp)
    80005d30:	21213823          	sd	s2,528(sp)
    80005d34:	21313423          	sd	s3,520(sp)
    80005d38:	21413023          	sd	s4,512(sp)
    80005d3c:	ffd6                	sd	s5,504(sp)
    80005d3e:	fbda                	sd	s6,496(sp)
    80005d40:	f7de                	sd	s7,488(sp)
    80005d42:	f3e2                	sd	s8,480(sp)
    80005d44:	efe6                	sd	s9,472(sp)
    80005d46:	ebea                	sd	s10,464(sp)
    80005d48:	e7ee                	sd	s11,456(sp)
    80005d4a:	1c00                	addi	s0,sp,560
    80005d4c:	dea43823          	sd	a0,-528(s0)
    80005d50:	deb43023          	sd	a1,-544(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005d54:	ffffc097          	auipc	ra,0xffffc
    80005d58:	d1c080e7          	jalr	-740(ra) # 80001a70 <myproc>
    80005d5c:	89aa                	mv	s3,a0

  struct kthread *t = mykthread();
    80005d5e:	ffffc097          	auipc	ra,0xffffc
    80005d62:	d52080e7          	jalr	-686(ra) # 80001ab0 <mykthread>
    80005d66:	8b2a                	mv	s6,a0
  struct kthread *nt;


  // Kill all process threads 
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){ 
    80005d68:	28898493          	addi	s1,s3,648
    80005d6c:	6905                	lui	s2,0x1
    80005d6e:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80005d72:	994e                	add	s2,s2,s3
    if(nt!=t && nt->state!=TUNUSED){
      acquire(&nt->lock);
      nt->killed=1;
    80005d74:	4a85                	li	s5,1
      if(nt->state == TSLEEPING){
    80005d76:	4a09                	li	s4,2
        nt->state = TRUNNABLE;
    80005d78:	4b8d                	li	s7,3
    80005d7a:	a811                	j	80005d8e <exec+0x6e>
      }
      release(&nt->lock);  
    80005d7c:	8526                	mv	a0,s1
    80005d7e:	ffffb097          	auipc	ra,0xffffb
    80005d82:	f12080e7          	jalr	-238(ra) # 80000c90 <release>
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){ 
    80005d86:	0b848493          	addi	s1,s1,184
    80005d8a:	03248363          	beq	s1,s2,80005db0 <exec+0x90>
    if(nt!=t && nt->state!=TUNUSED){
    80005d8e:	fe9b0ce3          	beq	s6,s1,80005d86 <exec+0x66>
    80005d92:	4c9c                	lw	a5,24(s1)
    80005d94:	dbed                	beqz	a5,80005d86 <exec+0x66>
      acquire(&nt->lock);
    80005d96:	8526                	mv	a0,s1
    80005d98:	ffffb097          	auipc	ra,0xffffb
    80005d9c:	e2e080e7          	jalr	-466(ra) # 80000bc6 <acquire>
      nt->killed=1;
    80005da0:	0354a423          	sw	s5,40(s1)
      if(nt->state == TSLEEPING){
    80005da4:	4c9c                	lw	a5,24(s1)
    80005da6:	fd479be3          	bne	a5,s4,80005d7c <exec+0x5c>
        nt->state = TRUNNABLE;
    80005daa:	0174ac23          	sw	s7,24(s1)
    80005dae:	b7f9                	j	80005d7c <exec+0x5c>
    }
  }

  // Wait for all threads to terminate
  kthread_join_all();
    80005db0:	ffffd097          	auipc	ra,0xffffd
    80005db4:	366080e7          	jalr	870(ra) # 80003116 <kthread_join_all>
    
  begin_op();
    80005db8:	fffff097          	auipc	ra,0xfffff
    80005dbc:	43e080e7          	jalr	1086(ra) # 800051f6 <begin_op>

  if((ip = namei(path)) == 0){
    80005dc0:	df043503          	ld	a0,-528(s0)
    80005dc4:	fffff097          	auipc	ra,0xfffff
    80005dc8:	212080e7          	jalr	530(ra) # 80004fd6 <namei>
    80005dcc:	8aaa                	mv	s5,a0
    80005dce:	cd25                	beqz	a0,80005e46 <exec+0x126>
    end_op();
    return -1;
  }
  ilock(ip);
    80005dd0:	fffff097          	auipc	ra,0xfffff
    80005dd4:	a52080e7          	jalr	-1454(ra) # 80004822 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005dd8:	04000713          	li	a4,64
    80005ddc:	4681                	li	a3,0
    80005dde:	e4840613          	addi	a2,s0,-440
    80005de2:	4581                	li	a1,0
    80005de4:	8556                	mv	a0,s5
    80005de6:	fffff097          	auipc	ra,0xfffff
    80005dea:	cf0080e7          	jalr	-784(ra) # 80004ad6 <readi>
    80005dee:	04000793          	li	a5,64
    80005df2:	00f51a63          	bne	a0,a5,80005e06 <exec+0xe6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005df6:	e4842703          	lw	a4,-440(s0)
    80005dfa:	464c47b7          	lui	a5,0x464c4
    80005dfe:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005e02:	04f70863          	beq	a4,a5,80005e52 <exec+0x132>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005e06:	8556                	mv	a0,s5
    80005e08:	fffff097          	auipc	ra,0xfffff
    80005e0c:	c7c080e7          	jalr	-900(ra) # 80004a84 <iunlockput>
    end_op();
    80005e10:	fffff097          	auipc	ra,0xfffff
    80005e14:	466080e7          	jalr	1126(ra) # 80005276 <end_op>
  }
  return -1;
    80005e18:	557d                	li	a0,-1
}
    80005e1a:	22813083          	ld	ra,552(sp)
    80005e1e:	22013403          	ld	s0,544(sp)
    80005e22:	21813483          	ld	s1,536(sp)
    80005e26:	21013903          	ld	s2,528(sp)
    80005e2a:	20813983          	ld	s3,520(sp)
    80005e2e:	20013a03          	ld	s4,512(sp)
    80005e32:	7afe                	ld	s5,504(sp)
    80005e34:	7b5e                	ld	s6,496(sp)
    80005e36:	7bbe                	ld	s7,488(sp)
    80005e38:	7c1e                	ld	s8,480(sp)
    80005e3a:	6cfe                	ld	s9,472(sp)
    80005e3c:	6d5e                	ld	s10,464(sp)
    80005e3e:	6dbe                	ld	s11,456(sp)
    80005e40:	23010113          	addi	sp,sp,560
    80005e44:	8082                	ret
    end_op();
    80005e46:	fffff097          	auipc	ra,0xfffff
    80005e4a:	430080e7          	jalr	1072(ra) # 80005276 <end_op>
    return -1;
    80005e4e:	557d                	li	a0,-1
    80005e50:	b7e9                	j	80005e1a <exec+0xfa>
  if((pagetable = proc_pagetable(p)) == 0)
    80005e52:	854e                	mv	a0,s3
    80005e54:	ffffc097          	auipc	ra,0xffffc
    80005e58:	dec080e7          	jalr	-532(ra) # 80001c40 <proc_pagetable>
    80005e5c:	e0a43423          	sd	a0,-504(s0)
    80005e60:	d15d                	beqz	a0,80005e06 <exec+0xe6>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005e62:	e6842783          	lw	a5,-408(s0)
    80005e66:	e8045703          	lhu	a4,-384(s0)
    80005e6a:	c73d                	beqz	a4,80005ed8 <exec+0x1b8>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005e6c:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005e6e:	e0043023          	sd	zero,-512(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005e72:	6a05                	lui	s4,0x1
    80005e74:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005e78:	dce43c23          	sd	a4,-552(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005e7c:	6d85                	lui	s11,0x1
    80005e7e:	7d7d                	lui	s10,0xfffff
    80005e80:	a4b5                	j	800060ec <exec+0x3cc>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005e82:	00004517          	auipc	a0,0x4
    80005e86:	b8e50513          	addi	a0,a0,-1138 # 80009a10 <syscalls+0x2b8>
    80005e8a:	ffffa097          	auipc	ra,0xffffa
    80005e8e:	6a4080e7          	jalr	1700(ra) # 8000052e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005e92:	874a                	mv	a4,s2
    80005e94:	009c86bb          	addw	a3,s9,s1
    80005e98:	4581                	li	a1,0
    80005e9a:	8556                	mv	a0,s5
    80005e9c:	fffff097          	auipc	ra,0xfffff
    80005ea0:	c3a080e7          	jalr	-966(ra) # 80004ad6 <readi>
    80005ea4:	2501                	sext.w	a0,a0
    80005ea6:	1ea91263          	bne	s2,a0,8000608a <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80005eaa:	009d84bb          	addw	s1,s11,s1
    80005eae:	013d09bb          	addw	s3,s10,s3
    80005eb2:	2174fd63          	bgeu	s1,s7,800060cc <exec+0x3ac>
    pa = walkaddr(pagetable, va + i);
    80005eb6:	02049593          	slli	a1,s1,0x20
    80005eba:	9181                	srli	a1,a1,0x20
    80005ebc:	95e2                	add	a1,a1,s8
    80005ebe:	e0843503          	ld	a0,-504(s0)
    80005ec2:	ffffb097          	auipc	ra,0xffffb
    80005ec6:	1a4080e7          	jalr	420(ra) # 80001066 <walkaddr>
    80005eca:	862a                	mv	a2,a0
    if(pa == 0)
    80005ecc:	d95d                	beqz	a0,80005e82 <exec+0x162>
      n = PGSIZE;
    80005ece:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005ed0:	fd49f1e3          	bgeu	s3,s4,80005e92 <exec+0x172>
      n = sz - i;
    80005ed4:	894e                	mv	s2,s3
    80005ed6:	bf75                	j	80005e92 <exec+0x172>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005ed8:	4481                	li	s1,0
  iunlockput(ip);
    80005eda:	8556                	mv	a0,s5
    80005edc:	fffff097          	auipc	ra,0xfffff
    80005ee0:	ba8080e7          	jalr	-1112(ra) # 80004a84 <iunlockput>
  end_op();
    80005ee4:	fffff097          	auipc	ra,0xfffff
    80005ee8:	392080e7          	jalr	914(ra) # 80005276 <end_op>
  p = myproc();
    80005eec:	ffffc097          	auipc	ra,0xffffc
    80005ef0:	b84080e7          	jalr	-1148(ra) # 80001a70 <myproc>
    80005ef4:	8a2a                	mv	s4,a0
  uint64 oldsz = p->sz;
    80005ef6:	03853d03          	ld	s10,56(a0)
  sz = PGROUNDUP(sz);
    80005efa:	6785                	lui	a5,0x1
    80005efc:	17fd                	addi	a5,a5,-1
    80005efe:	94be                	add	s1,s1,a5
    80005f00:	77fd                	lui	a5,0xfffff
    80005f02:	8fe5                	and	a5,a5,s1
    80005f04:	def43423          	sd	a5,-536(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005f08:	6609                	lui	a2,0x2
    80005f0a:	963e                	add	a2,a2,a5
    80005f0c:	85be                	mv	a1,a5
    80005f0e:	e0843483          	ld	s1,-504(s0)
    80005f12:	8526                	mv	a0,s1
    80005f14:	ffffb097          	auipc	ra,0xffffb
    80005f18:	4f4080e7          	jalr	1268(ra) # 80001408 <uvmalloc>
    80005f1c:	8caa                	mv	s9,a0
  ip = 0;
    80005f1e:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005f20:	16050563          	beqz	a0,8000608a <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005f24:	75f9                	lui	a1,0xffffe
    80005f26:	95aa                	add	a1,a1,a0
    80005f28:	8526                	mv	a0,s1
    80005f2a:	ffffb097          	auipc	ra,0xffffb
    80005f2e:	6fc080e7          	jalr	1788(ra) # 80001626 <uvmclear>
  stackbase = sp - PGSIZE;
    80005f32:	7bfd                	lui	s7,0xfffff
    80005f34:	9be6                	add	s7,s7,s9
  for(argc = 0; argv[argc]; argc++) {
    80005f36:	de043783          	ld	a5,-544(s0)
    80005f3a:	6388                	ld	a0,0(a5)
    80005f3c:	c92d                	beqz	a0,80005fae <exec+0x28e>
    80005f3e:	e8840993          	addi	s3,s0,-376
    80005f42:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80005f46:	8966                	mv	s2,s9
  for(argc = 0; argv[argc]; argc++) {
    80005f48:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005f4a:	ffffb097          	auipc	ra,0xffffb
    80005f4e:	f12080e7          	jalr	-238(ra) # 80000e5c <strlen>
    80005f52:	0015079b          	addiw	a5,a0,1
    80005f56:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005f5a:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005f5e:	15796b63          	bltu	s2,s7,800060b4 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005f62:	de043d83          	ld	s11,-544(s0)
    80005f66:	000dba83          	ld	s5,0(s11) # 1000 <_entry-0x7ffff000>
    80005f6a:	8556                	mv	a0,s5
    80005f6c:	ffffb097          	auipc	ra,0xffffb
    80005f70:	ef0080e7          	jalr	-272(ra) # 80000e5c <strlen>
    80005f74:	0015069b          	addiw	a3,a0,1
    80005f78:	8656                	mv	a2,s5
    80005f7a:	85ca                	mv	a1,s2
    80005f7c:	e0843503          	ld	a0,-504(s0)
    80005f80:	ffffb097          	auipc	ra,0xffffb
    80005f84:	6d8080e7          	jalr	1752(ra) # 80001658 <copyout>
    80005f88:	12054a63          	bltz	a0,800060bc <exec+0x39c>
    ustack[argc] = sp;
    80005f8c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005f90:	0485                	addi	s1,s1,1
    80005f92:	008d8793          	addi	a5,s11,8
    80005f96:	def43023          	sd	a5,-544(s0)
    80005f9a:	008db503          	ld	a0,8(s11)
    80005f9e:	c911                	beqz	a0,80005fb2 <exec+0x292>
    if(argc >= MAXARG)
    80005fa0:	09a1                	addi	s3,s3,8
    80005fa2:	fb3c14e3          	bne	s8,s3,80005f4a <exec+0x22a>
  sz = sz1;
    80005fa6:	df943423          	sd	s9,-536(s0)
  ip = 0;
    80005faa:	4a81                	li	s5,0
    80005fac:	a8f9                	j	8000608a <exec+0x36a>
  sp = sz;
    80005fae:	8966                	mv	s2,s9
  for(argc = 0; argv[argc]; argc++) {
    80005fb0:	4481                	li	s1,0
  ustack[argc] = 0;
    80005fb2:	00349793          	slli	a5,s1,0x3
    80005fb6:	f9040713          	addi	a4,s0,-112
    80005fba:	97ba                	add	a5,a5,a4
    80005fbc:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffbcef8>
  sp -= (argc+1) * sizeof(uint64);
    80005fc0:	00148693          	addi	a3,s1,1
    80005fc4:	068e                	slli	a3,a3,0x3
    80005fc6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005fca:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005fce:	01797663          	bgeu	s2,s7,80005fda <exec+0x2ba>
  sz = sz1;
    80005fd2:	df943423          	sd	s9,-536(s0)
  ip = 0;
    80005fd6:	4a81                	li	s5,0
    80005fd8:	a84d                	j	8000608a <exec+0x36a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005fda:	e8840613          	addi	a2,s0,-376
    80005fde:	85ca                	mv	a1,s2
    80005fe0:	e0843503          	ld	a0,-504(s0)
    80005fe4:	ffffb097          	auipc	ra,0xffffb
    80005fe8:	674080e7          	jalr	1652(ra) # 80001658 <copyout>
    80005fec:	0c054c63          	bltz	a0,800060c4 <exec+0x3a4>
  t->trapframe->a1 = sp;
    80005ff0:	040b3783          	ld	a5,64(s6)
    80005ff4:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005ff8:	df043783          	ld	a5,-528(s0)
    80005ffc:	0007c703          	lbu	a4,0(a5)
    80006000:	cf11                	beqz	a4,8000601c <exec+0x2fc>
    80006002:	0785                	addi	a5,a5,1
    if(*s == '/')
    80006004:	02f00693          	li	a3,47
    80006008:	a039                	j	80006016 <exec+0x2f6>
      last = s+1;
    8000600a:	def43823          	sd	a5,-528(s0)
  for(last=s=path; *s; s++)
    8000600e:	0785                	addi	a5,a5,1
    80006010:	fff7c703          	lbu	a4,-1(a5)
    80006014:	c701                	beqz	a4,8000601c <exec+0x2fc>
    if(*s == '/')
    80006016:	fed71ce3          	bne	a4,a3,8000600e <exec+0x2ee>
    8000601a:	bfc5                	j	8000600a <exec+0x2ea>
  safestrcpy(p->name, last, sizeof(p->name));
    8000601c:	4641                	li	a2,16
    8000601e:	df043583          	ld	a1,-528(s0)
    80006022:	0d8a0513          	addi	a0,s4,216
    80006026:	ffffb097          	auipc	ra,0xffffb
    8000602a:	e04080e7          	jalr	-508(ra) # 80000e2a <safestrcpy>
  for(int i=0; i<32; i++){
    8000602e:	0f8a0793          	addi	a5,s4,248
    80006032:	1f8a0713          	addi	a4,s4,504
    80006036:	85ba                	mv	a1,a4
    if(!((p->signal_handlers[i]) == (void*)SIG_IGN)){
    80006038:	4605                	li	a2,1
    8000603a:	a029                	j	80006044 <exec+0x324>
  for(int i=0; i<32; i++){
    8000603c:	07a1                	addi	a5,a5,8
    8000603e:	0711                	addi	a4,a4,4
    80006040:	00f58a63          	beq	a1,a5,80006054 <exec+0x334>
    if(!((p->signal_handlers[i]) == (void*)SIG_IGN)){
    80006044:	6394                	ld	a3,0(a5)
    80006046:	fec68be3          	beq	a3,a2,8000603c <exec+0x31c>
        p->signal_handlers[i]=SIG_DFL;
    8000604a:	0007b023          	sd	zero,0(a5)
        p->handlers_sigmasks[i]=0;   
    8000604e:	00072023          	sw	zero,0(a4)
    80006052:	b7ed                	j	8000603c <exec+0x31c>
  oldpagetable = p->pagetable;
    80006054:	040a3503          	ld	a0,64(s4)
  p->pagetable = pagetable;
    80006058:	e0843783          	ld	a5,-504(s0)
    8000605c:	04fa3023          	sd	a5,64(s4)
  p->sz = sz;
    80006060:	039a3c23          	sd	s9,56(s4)
  t->trapframe->epc = elf.entry;  // initial program counter = main
    80006064:	040b3783          	ld	a5,64(s6)
    80006068:	e6043703          	ld	a4,-416(s0)
    8000606c:	ef98                	sd	a4,24(a5)
  t->trapframe->sp = sp; // initial stack pointer
    8000606e:	040b3783          	ld	a5,64(s6)
    80006072:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80006076:	85ea                	mv	a1,s10
    80006078:	ffffc097          	auipc	ra,0xffffc
    8000607c:	c64080e7          	jalr	-924(ra) # 80001cdc <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80006080:	0004851b          	sext.w	a0,s1
    80006084:	bb59                	j	80005e1a <exec+0xfa>
    80006086:	de943423          	sd	s1,-536(s0)
    proc_freepagetable(pagetable, sz);
    8000608a:	de843583          	ld	a1,-536(s0)
    8000608e:	e0843503          	ld	a0,-504(s0)
    80006092:	ffffc097          	auipc	ra,0xffffc
    80006096:	c4a080e7          	jalr	-950(ra) # 80001cdc <proc_freepagetable>
  if(ip){
    8000609a:	d60a96e3          	bnez	s5,80005e06 <exec+0xe6>
  return -1;
    8000609e:	557d                	li	a0,-1
    800060a0:	bbad                	j	80005e1a <exec+0xfa>
    800060a2:	de943423          	sd	s1,-536(s0)
    800060a6:	b7d5                	j	8000608a <exec+0x36a>
    800060a8:	de943423          	sd	s1,-536(s0)
    800060ac:	bff9                	j	8000608a <exec+0x36a>
    800060ae:	de943423          	sd	s1,-536(s0)
    800060b2:	bfe1                	j	8000608a <exec+0x36a>
  sz = sz1;
    800060b4:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800060b8:	4a81                	li	s5,0
    800060ba:	bfc1                	j	8000608a <exec+0x36a>
  sz = sz1;
    800060bc:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800060c0:	4a81                	li	s5,0
    800060c2:	b7e1                	j	8000608a <exec+0x36a>
  sz = sz1;
    800060c4:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800060c8:	4a81                	li	s5,0
    800060ca:	b7c1                	j	8000608a <exec+0x36a>
    sz = sz1;
    800060cc:	de843483          	ld	s1,-536(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800060d0:	e0043783          	ld	a5,-512(s0)
    800060d4:	0017869b          	addiw	a3,a5,1
    800060d8:	e0d43023          	sd	a3,-512(s0)
    800060dc:	df843783          	ld	a5,-520(s0)
    800060e0:	0387879b          	addiw	a5,a5,56
    800060e4:	e8045703          	lhu	a4,-384(s0)
    800060e8:	dee6d9e3          	bge	a3,a4,80005eda <exec+0x1ba>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800060ec:	2781                	sext.w	a5,a5
    800060ee:	def43c23          	sd	a5,-520(s0)
    800060f2:	03800713          	li	a4,56
    800060f6:	86be                	mv	a3,a5
    800060f8:	e1040613          	addi	a2,s0,-496
    800060fc:	4581                	li	a1,0
    800060fe:	8556                	mv	a0,s5
    80006100:	fffff097          	auipc	ra,0xfffff
    80006104:	9d6080e7          	jalr	-1578(ra) # 80004ad6 <readi>
    80006108:	03800793          	li	a5,56
    8000610c:	f6f51de3          	bne	a0,a5,80006086 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80006110:	e1042783          	lw	a5,-496(s0)
    80006114:	4705                	li	a4,1
    80006116:	fae79de3          	bne	a5,a4,800060d0 <exec+0x3b0>
    if(ph.memsz < ph.filesz)
    8000611a:	e3843603          	ld	a2,-456(s0)
    8000611e:	e3043783          	ld	a5,-464(s0)
    80006122:	f8f660e3          	bltu	a2,a5,800060a2 <exec+0x382>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80006126:	e2043783          	ld	a5,-480(s0)
    8000612a:	963e                	add	a2,a2,a5
    8000612c:	f6f66ee3          	bltu	a2,a5,800060a8 <exec+0x388>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80006130:	85a6                	mv	a1,s1
    80006132:	e0843503          	ld	a0,-504(s0)
    80006136:	ffffb097          	auipc	ra,0xffffb
    8000613a:	2d2080e7          	jalr	722(ra) # 80001408 <uvmalloc>
    8000613e:	dea43423          	sd	a0,-536(s0)
    80006142:	d535                	beqz	a0,800060ae <exec+0x38e>
    if(ph.vaddr % PGSIZE != 0)
    80006144:	e2043c03          	ld	s8,-480(s0)
    80006148:	dd843783          	ld	a5,-552(s0)
    8000614c:	00fc77b3          	and	a5,s8,a5
    80006150:	ff8d                	bnez	a5,8000608a <exec+0x36a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80006152:	e1842c83          	lw	s9,-488(s0)
    80006156:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000615a:	f60b89e3          	beqz	s7,800060cc <exec+0x3ac>
    8000615e:	89de                	mv	s3,s7
    80006160:	4481                	li	s1,0
    80006162:	bb91                	j	80005eb6 <exec+0x196>

0000000080006164 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80006164:	7179                	addi	sp,sp,-48
    80006166:	f406                	sd	ra,40(sp)
    80006168:	f022                	sd	s0,32(sp)
    8000616a:	ec26                	sd	s1,24(sp)
    8000616c:	e84a                	sd	s2,16(sp)
    8000616e:	1800                	addi	s0,sp,48
    80006170:	892e                	mv	s2,a1
    80006172:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80006174:	fdc40593          	addi	a1,s0,-36
    80006178:	ffffe097          	auipc	ra,0xffffe
    8000617c:	964080e7          	jalr	-1692(ra) # 80003adc <argint>
    80006180:	04054063          	bltz	a0,800061c0 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80006184:	fdc42703          	lw	a4,-36(s0)
    80006188:	47bd                	li	a5,15
    8000618a:	02e7ed63          	bltu	a5,a4,800061c4 <argfd+0x60>
    8000618e:	ffffc097          	auipc	ra,0xffffc
    80006192:	8e2080e7          	jalr	-1822(ra) # 80001a70 <myproc>
    80006196:	fdc42703          	lw	a4,-36(s0)
    8000619a:	00a70793          	addi	a5,a4,10
    8000619e:	078e                	slli	a5,a5,0x3
    800061a0:	953e                	add	a0,a0,a5
    800061a2:	611c                	ld	a5,0(a0)
    800061a4:	c395                	beqz	a5,800061c8 <argfd+0x64>
    return -1;
  if(pfd)
    800061a6:	00090463          	beqz	s2,800061ae <argfd+0x4a>
    *pfd = fd;
    800061aa:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800061ae:	4501                	li	a0,0
  if(pf)
    800061b0:	c091                	beqz	s1,800061b4 <argfd+0x50>
    *pf = f;
    800061b2:	e09c                	sd	a5,0(s1)
}
    800061b4:	70a2                	ld	ra,40(sp)
    800061b6:	7402                	ld	s0,32(sp)
    800061b8:	64e2                	ld	s1,24(sp)
    800061ba:	6942                	ld	s2,16(sp)
    800061bc:	6145                	addi	sp,sp,48
    800061be:	8082                	ret
    return -1;
    800061c0:	557d                	li	a0,-1
    800061c2:	bfcd                	j	800061b4 <argfd+0x50>
    return -1;
    800061c4:	557d                	li	a0,-1
    800061c6:	b7fd                	j	800061b4 <argfd+0x50>
    800061c8:	557d                	li	a0,-1
    800061ca:	b7ed                	j	800061b4 <argfd+0x50>

00000000800061cc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800061cc:	1101                	addi	sp,sp,-32
    800061ce:	ec06                	sd	ra,24(sp)
    800061d0:	e822                	sd	s0,16(sp)
    800061d2:	e426                	sd	s1,8(sp)
    800061d4:	1000                	addi	s0,sp,32
    800061d6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800061d8:	ffffc097          	auipc	ra,0xffffc
    800061dc:	898080e7          	jalr	-1896(ra) # 80001a70 <myproc>
    800061e0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800061e2:	05050793          	addi	a5,a0,80
    800061e6:	4501                	li	a0,0
    800061e8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800061ea:	6398                	ld	a4,0(a5)
    800061ec:	cb19                	beqz	a4,80006202 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800061ee:	2505                	addiw	a0,a0,1
    800061f0:	07a1                	addi	a5,a5,8
    800061f2:	fed51ce3          	bne	a0,a3,800061ea <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800061f6:	557d                	li	a0,-1
}
    800061f8:	60e2                	ld	ra,24(sp)
    800061fa:	6442                	ld	s0,16(sp)
    800061fc:	64a2                	ld	s1,8(sp)
    800061fe:	6105                	addi	sp,sp,32
    80006200:	8082                	ret
      p->ofile[fd] = f;
    80006202:	00a50793          	addi	a5,a0,10
    80006206:	078e                	slli	a5,a5,0x3
    80006208:	963e                	add	a2,a2,a5
    8000620a:	e204                	sd	s1,0(a2)
      return fd;
    8000620c:	b7f5                	j	800061f8 <fdalloc+0x2c>

000000008000620e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000620e:	715d                	addi	sp,sp,-80
    80006210:	e486                	sd	ra,72(sp)
    80006212:	e0a2                	sd	s0,64(sp)
    80006214:	fc26                	sd	s1,56(sp)
    80006216:	f84a                	sd	s2,48(sp)
    80006218:	f44e                	sd	s3,40(sp)
    8000621a:	f052                	sd	s4,32(sp)
    8000621c:	ec56                	sd	s5,24(sp)
    8000621e:	0880                	addi	s0,sp,80
    80006220:	89ae                	mv	s3,a1
    80006222:	8ab2                	mv	s5,a2
    80006224:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80006226:	fb040593          	addi	a1,s0,-80
    8000622a:	fffff097          	auipc	ra,0xfffff
    8000622e:	dca080e7          	jalr	-566(ra) # 80004ff4 <nameiparent>
    80006232:	892a                	mv	s2,a0
    80006234:	12050e63          	beqz	a0,80006370 <create+0x162>
    return 0;

  ilock(dp);
    80006238:	ffffe097          	auipc	ra,0xffffe
    8000623c:	5ea080e7          	jalr	1514(ra) # 80004822 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80006240:	4601                	li	a2,0
    80006242:	fb040593          	addi	a1,s0,-80
    80006246:	854a                	mv	a0,s2
    80006248:	fffff097          	auipc	ra,0xfffff
    8000624c:	abe080e7          	jalr	-1346(ra) # 80004d06 <dirlookup>
    80006250:	84aa                	mv	s1,a0
    80006252:	c921                	beqz	a0,800062a2 <create+0x94>
    iunlockput(dp);
    80006254:	854a                	mv	a0,s2
    80006256:	fffff097          	auipc	ra,0xfffff
    8000625a:	82e080e7          	jalr	-2002(ra) # 80004a84 <iunlockput>
    ilock(ip);
    8000625e:	8526                	mv	a0,s1
    80006260:	ffffe097          	auipc	ra,0xffffe
    80006264:	5c2080e7          	jalr	1474(ra) # 80004822 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006268:	2981                	sext.w	s3,s3
    8000626a:	4789                	li	a5,2
    8000626c:	02f99463          	bne	s3,a5,80006294 <create+0x86>
    80006270:	0444d783          	lhu	a5,68(s1)
    80006274:	37f9                	addiw	a5,a5,-2
    80006276:	17c2                	slli	a5,a5,0x30
    80006278:	93c1                	srli	a5,a5,0x30
    8000627a:	4705                	li	a4,1
    8000627c:	00f76c63          	bltu	a4,a5,80006294 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80006280:	8526                	mv	a0,s1
    80006282:	60a6                	ld	ra,72(sp)
    80006284:	6406                	ld	s0,64(sp)
    80006286:	74e2                	ld	s1,56(sp)
    80006288:	7942                	ld	s2,48(sp)
    8000628a:	79a2                	ld	s3,40(sp)
    8000628c:	7a02                	ld	s4,32(sp)
    8000628e:	6ae2                	ld	s5,24(sp)
    80006290:	6161                	addi	sp,sp,80
    80006292:	8082                	ret
    iunlockput(ip);
    80006294:	8526                	mv	a0,s1
    80006296:	ffffe097          	auipc	ra,0xffffe
    8000629a:	7ee080e7          	jalr	2030(ra) # 80004a84 <iunlockput>
    return 0;
    8000629e:	4481                	li	s1,0
    800062a0:	b7c5                	j	80006280 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800062a2:	85ce                	mv	a1,s3
    800062a4:	00092503          	lw	a0,0(s2)
    800062a8:	ffffe097          	auipc	ra,0xffffe
    800062ac:	3e2080e7          	jalr	994(ra) # 8000468a <ialloc>
    800062b0:	84aa                	mv	s1,a0
    800062b2:	c521                	beqz	a0,800062fa <create+0xec>
  ilock(ip);
    800062b4:	ffffe097          	auipc	ra,0xffffe
    800062b8:	56e080e7          	jalr	1390(ra) # 80004822 <ilock>
  ip->major = major;
    800062bc:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800062c0:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800062c4:	4a05                	li	s4,1
    800062c6:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800062ca:	8526                	mv	a0,s1
    800062cc:	ffffe097          	auipc	ra,0xffffe
    800062d0:	48c080e7          	jalr	1164(ra) # 80004758 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800062d4:	2981                	sext.w	s3,s3
    800062d6:	03498a63          	beq	s3,s4,8000630a <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800062da:	40d0                	lw	a2,4(s1)
    800062dc:	fb040593          	addi	a1,s0,-80
    800062e0:	854a                	mv	a0,s2
    800062e2:	fffff097          	auipc	ra,0xfffff
    800062e6:	c32080e7          	jalr	-974(ra) # 80004f14 <dirlink>
    800062ea:	06054b63          	bltz	a0,80006360 <create+0x152>
  iunlockput(dp);
    800062ee:	854a                	mv	a0,s2
    800062f0:	ffffe097          	auipc	ra,0xffffe
    800062f4:	794080e7          	jalr	1940(ra) # 80004a84 <iunlockput>
  return ip;
    800062f8:	b761                	j	80006280 <create+0x72>
    panic("create: ialloc");
    800062fa:	00003517          	auipc	a0,0x3
    800062fe:	73650513          	addi	a0,a0,1846 # 80009a30 <syscalls+0x2d8>
    80006302:	ffffa097          	auipc	ra,0xffffa
    80006306:	22c080e7          	jalr	556(ra) # 8000052e <panic>
    dp->nlink++;  // for ".."
    8000630a:	04a95783          	lhu	a5,74(s2)
    8000630e:	2785                	addiw	a5,a5,1
    80006310:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80006314:	854a                	mv	a0,s2
    80006316:	ffffe097          	auipc	ra,0xffffe
    8000631a:	442080e7          	jalr	1090(ra) # 80004758 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000631e:	40d0                	lw	a2,4(s1)
    80006320:	00003597          	auipc	a1,0x3
    80006324:	72058593          	addi	a1,a1,1824 # 80009a40 <syscalls+0x2e8>
    80006328:	8526                	mv	a0,s1
    8000632a:	fffff097          	auipc	ra,0xfffff
    8000632e:	bea080e7          	jalr	-1046(ra) # 80004f14 <dirlink>
    80006332:	00054f63          	bltz	a0,80006350 <create+0x142>
    80006336:	00492603          	lw	a2,4(s2)
    8000633a:	00003597          	auipc	a1,0x3
    8000633e:	70e58593          	addi	a1,a1,1806 # 80009a48 <syscalls+0x2f0>
    80006342:	8526                	mv	a0,s1
    80006344:	fffff097          	auipc	ra,0xfffff
    80006348:	bd0080e7          	jalr	-1072(ra) # 80004f14 <dirlink>
    8000634c:	f80557e3          	bgez	a0,800062da <create+0xcc>
      panic("create dots");
    80006350:	00003517          	auipc	a0,0x3
    80006354:	70050513          	addi	a0,a0,1792 # 80009a50 <syscalls+0x2f8>
    80006358:	ffffa097          	auipc	ra,0xffffa
    8000635c:	1d6080e7          	jalr	470(ra) # 8000052e <panic>
    panic("create: dirlink");
    80006360:	00003517          	auipc	a0,0x3
    80006364:	70050513          	addi	a0,a0,1792 # 80009a60 <syscalls+0x308>
    80006368:	ffffa097          	auipc	ra,0xffffa
    8000636c:	1c6080e7          	jalr	454(ra) # 8000052e <panic>
    return 0;
    80006370:	84aa                	mv	s1,a0
    80006372:	b739                	j	80006280 <create+0x72>

0000000080006374 <sys_dup>:
{
    80006374:	7179                	addi	sp,sp,-48
    80006376:	f406                	sd	ra,40(sp)
    80006378:	f022                	sd	s0,32(sp)
    8000637a:	ec26                	sd	s1,24(sp)
    8000637c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000637e:	fd840613          	addi	a2,s0,-40
    80006382:	4581                	li	a1,0
    80006384:	4501                	li	a0,0
    80006386:	00000097          	auipc	ra,0x0
    8000638a:	dde080e7          	jalr	-546(ra) # 80006164 <argfd>
    return -1;
    8000638e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80006390:	02054363          	bltz	a0,800063b6 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80006394:	fd843503          	ld	a0,-40(s0)
    80006398:	00000097          	auipc	ra,0x0
    8000639c:	e34080e7          	jalr	-460(ra) # 800061cc <fdalloc>
    800063a0:	84aa                	mv	s1,a0
    return -1;
    800063a2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800063a4:	00054963          	bltz	a0,800063b6 <sys_dup+0x42>
  filedup(f);
    800063a8:	fd843503          	ld	a0,-40(s0)
    800063ac:	fffff097          	auipc	ra,0xfffff
    800063b0:	2c4080e7          	jalr	708(ra) # 80005670 <filedup>
  return fd;
    800063b4:	87a6                	mv	a5,s1
}
    800063b6:	853e                	mv	a0,a5
    800063b8:	70a2                	ld	ra,40(sp)
    800063ba:	7402                	ld	s0,32(sp)
    800063bc:	64e2                	ld	s1,24(sp)
    800063be:	6145                	addi	sp,sp,48
    800063c0:	8082                	ret

00000000800063c2 <sys_read>:
{
    800063c2:	7179                	addi	sp,sp,-48
    800063c4:	f406                	sd	ra,40(sp)
    800063c6:	f022                	sd	s0,32(sp)
    800063c8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800063ca:	fe840613          	addi	a2,s0,-24
    800063ce:	4581                	li	a1,0
    800063d0:	4501                	li	a0,0
    800063d2:	00000097          	auipc	ra,0x0
    800063d6:	d92080e7          	jalr	-622(ra) # 80006164 <argfd>
    return -1;
    800063da:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800063dc:	04054163          	bltz	a0,8000641e <sys_read+0x5c>
    800063e0:	fe440593          	addi	a1,s0,-28
    800063e4:	4509                	li	a0,2
    800063e6:	ffffd097          	auipc	ra,0xffffd
    800063ea:	6f6080e7          	jalr	1782(ra) # 80003adc <argint>
    return -1;
    800063ee:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800063f0:	02054763          	bltz	a0,8000641e <sys_read+0x5c>
    800063f4:	fd840593          	addi	a1,s0,-40
    800063f8:	4505                	li	a0,1
    800063fa:	ffffd097          	auipc	ra,0xffffd
    800063fe:	704080e7          	jalr	1796(ra) # 80003afe <argaddr>
    return -1;
    80006402:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006404:	00054d63          	bltz	a0,8000641e <sys_read+0x5c>
  return fileread(f, p, n);
    80006408:	fe442603          	lw	a2,-28(s0)
    8000640c:	fd843583          	ld	a1,-40(s0)
    80006410:	fe843503          	ld	a0,-24(s0)
    80006414:	fffff097          	auipc	ra,0xfffff
    80006418:	3e8080e7          	jalr	1000(ra) # 800057fc <fileread>
    8000641c:	87aa                	mv	a5,a0
}
    8000641e:	853e                	mv	a0,a5
    80006420:	70a2                	ld	ra,40(sp)
    80006422:	7402                	ld	s0,32(sp)
    80006424:	6145                	addi	sp,sp,48
    80006426:	8082                	ret

0000000080006428 <sys_write>:
{
    80006428:	7179                	addi	sp,sp,-48
    8000642a:	f406                	sd	ra,40(sp)
    8000642c:	f022                	sd	s0,32(sp)
    8000642e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006430:	fe840613          	addi	a2,s0,-24
    80006434:	4581                	li	a1,0
    80006436:	4501                	li	a0,0
    80006438:	00000097          	auipc	ra,0x0
    8000643c:	d2c080e7          	jalr	-724(ra) # 80006164 <argfd>
    return -1;
    80006440:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006442:	04054163          	bltz	a0,80006484 <sys_write+0x5c>
    80006446:	fe440593          	addi	a1,s0,-28
    8000644a:	4509                	li	a0,2
    8000644c:	ffffd097          	auipc	ra,0xffffd
    80006450:	690080e7          	jalr	1680(ra) # 80003adc <argint>
    return -1;
    80006454:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006456:	02054763          	bltz	a0,80006484 <sys_write+0x5c>
    8000645a:	fd840593          	addi	a1,s0,-40
    8000645e:	4505                	li	a0,1
    80006460:	ffffd097          	auipc	ra,0xffffd
    80006464:	69e080e7          	jalr	1694(ra) # 80003afe <argaddr>
    return -1;
    80006468:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000646a:	00054d63          	bltz	a0,80006484 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000646e:	fe442603          	lw	a2,-28(s0)
    80006472:	fd843583          	ld	a1,-40(s0)
    80006476:	fe843503          	ld	a0,-24(s0)
    8000647a:	fffff097          	auipc	ra,0xfffff
    8000647e:	444080e7          	jalr	1092(ra) # 800058be <filewrite>
    80006482:	87aa                	mv	a5,a0
}
    80006484:	853e                	mv	a0,a5
    80006486:	70a2                	ld	ra,40(sp)
    80006488:	7402                	ld	s0,32(sp)
    8000648a:	6145                	addi	sp,sp,48
    8000648c:	8082                	ret

000000008000648e <sys_close>:
{
    8000648e:	1101                	addi	sp,sp,-32
    80006490:	ec06                	sd	ra,24(sp)
    80006492:	e822                	sd	s0,16(sp)
    80006494:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80006496:	fe040613          	addi	a2,s0,-32
    8000649a:	fec40593          	addi	a1,s0,-20
    8000649e:	4501                	li	a0,0
    800064a0:	00000097          	auipc	ra,0x0
    800064a4:	cc4080e7          	jalr	-828(ra) # 80006164 <argfd>
    return -1;
    800064a8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800064aa:	02054463          	bltz	a0,800064d2 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800064ae:	ffffb097          	auipc	ra,0xffffb
    800064b2:	5c2080e7          	jalr	1474(ra) # 80001a70 <myproc>
    800064b6:	fec42783          	lw	a5,-20(s0)
    800064ba:	07a9                	addi	a5,a5,10
    800064bc:	078e                	slli	a5,a5,0x3
    800064be:	97aa                	add	a5,a5,a0
    800064c0:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800064c4:	fe043503          	ld	a0,-32(s0)
    800064c8:	fffff097          	auipc	ra,0xfffff
    800064cc:	1fa080e7          	jalr	506(ra) # 800056c2 <fileclose>
  return 0;
    800064d0:	4781                	li	a5,0
}
    800064d2:	853e                	mv	a0,a5
    800064d4:	60e2                	ld	ra,24(sp)
    800064d6:	6442                	ld	s0,16(sp)
    800064d8:	6105                	addi	sp,sp,32
    800064da:	8082                	ret

00000000800064dc <sys_fstat>:
{
    800064dc:	1101                	addi	sp,sp,-32
    800064de:	ec06                	sd	ra,24(sp)
    800064e0:	e822                	sd	s0,16(sp)
    800064e2:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800064e4:	fe840613          	addi	a2,s0,-24
    800064e8:	4581                	li	a1,0
    800064ea:	4501                	li	a0,0
    800064ec:	00000097          	auipc	ra,0x0
    800064f0:	c78080e7          	jalr	-904(ra) # 80006164 <argfd>
    return -1;
    800064f4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800064f6:	02054563          	bltz	a0,80006520 <sys_fstat+0x44>
    800064fa:	fe040593          	addi	a1,s0,-32
    800064fe:	4505                	li	a0,1
    80006500:	ffffd097          	auipc	ra,0xffffd
    80006504:	5fe080e7          	jalr	1534(ra) # 80003afe <argaddr>
    return -1;
    80006508:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000650a:	00054b63          	bltz	a0,80006520 <sys_fstat+0x44>
  return filestat(f, st);
    8000650e:	fe043583          	ld	a1,-32(s0)
    80006512:	fe843503          	ld	a0,-24(s0)
    80006516:	fffff097          	auipc	ra,0xfffff
    8000651a:	274080e7          	jalr	628(ra) # 8000578a <filestat>
    8000651e:	87aa                	mv	a5,a0
}
    80006520:	853e                	mv	a0,a5
    80006522:	60e2                	ld	ra,24(sp)
    80006524:	6442                	ld	s0,16(sp)
    80006526:	6105                	addi	sp,sp,32
    80006528:	8082                	ret

000000008000652a <sys_link>:
{
    8000652a:	7169                	addi	sp,sp,-304
    8000652c:	f606                	sd	ra,296(sp)
    8000652e:	f222                	sd	s0,288(sp)
    80006530:	ee26                	sd	s1,280(sp)
    80006532:	ea4a                	sd	s2,272(sp)
    80006534:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006536:	08000613          	li	a2,128
    8000653a:	ed040593          	addi	a1,s0,-304
    8000653e:	4501                	li	a0,0
    80006540:	ffffd097          	auipc	ra,0xffffd
    80006544:	5e0080e7          	jalr	1504(ra) # 80003b20 <argstr>
    return -1;
    80006548:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000654a:	10054e63          	bltz	a0,80006666 <sys_link+0x13c>
    8000654e:	08000613          	li	a2,128
    80006552:	f5040593          	addi	a1,s0,-176
    80006556:	4505                	li	a0,1
    80006558:	ffffd097          	auipc	ra,0xffffd
    8000655c:	5c8080e7          	jalr	1480(ra) # 80003b20 <argstr>
    return -1;
    80006560:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006562:	10054263          	bltz	a0,80006666 <sys_link+0x13c>
  begin_op();
    80006566:	fffff097          	auipc	ra,0xfffff
    8000656a:	c90080e7          	jalr	-880(ra) # 800051f6 <begin_op>
  if((ip = namei(old)) == 0){
    8000656e:	ed040513          	addi	a0,s0,-304
    80006572:	fffff097          	auipc	ra,0xfffff
    80006576:	a64080e7          	jalr	-1436(ra) # 80004fd6 <namei>
    8000657a:	84aa                	mv	s1,a0
    8000657c:	c551                	beqz	a0,80006608 <sys_link+0xde>
  ilock(ip);
    8000657e:	ffffe097          	auipc	ra,0xffffe
    80006582:	2a4080e7          	jalr	676(ra) # 80004822 <ilock>
  if(ip->type == T_DIR){
    80006586:	04449703          	lh	a4,68(s1)
    8000658a:	4785                	li	a5,1
    8000658c:	08f70463          	beq	a4,a5,80006614 <sys_link+0xea>
  ip->nlink++;
    80006590:	04a4d783          	lhu	a5,74(s1)
    80006594:	2785                	addiw	a5,a5,1
    80006596:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000659a:	8526                	mv	a0,s1
    8000659c:	ffffe097          	auipc	ra,0xffffe
    800065a0:	1bc080e7          	jalr	444(ra) # 80004758 <iupdate>
  iunlock(ip);
    800065a4:	8526                	mv	a0,s1
    800065a6:	ffffe097          	auipc	ra,0xffffe
    800065aa:	33e080e7          	jalr	830(ra) # 800048e4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800065ae:	fd040593          	addi	a1,s0,-48
    800065b2:	f5040513          	addi	a0,s0,-176
    800065b6:	fffff097          	auipc	ra,0xfffff
    800065ba:	a3e080e7          	jalr	-1474(ra) # 80004ff4 <nameiparent>
    800065be:	892a                	mv	s2,a0
    800065c0:	c935                	beqz	a0,80006634 <sys_link+0x10a>
  ilock(dp);
    800065c2:	ffffe097          	auipc	ra,0xffffe
    800065c6:	260080e7          	jalr	608(ra) # 80004822 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800065ca:	00092703          	lw	a4,0(s2)
    800065ce:	409c                	lw	a5,0(s1)
    800065d0:	04f71d63          	bne	a4,a5,8000662a <sys_link+0x100>
    800065d4:	40d0                	lw	a2,4(s1)
    800065d6:	fd040593          	addi	a1,s0,-48
    800065da:	854a                	mv	a0,s2
    800065dc:	fffff097          	auipc	ra,0xfffff
    800065e0:	938080e7          	jalr	-1736(ra) # 80004f14 <dirlink>
    800065e4:	04054363          	bltz	a0,8000662a <sys_link+0x100>
  iunlockput(dp);
    800065e8:	854a                	mv	a0,s2
    800065ea:	ffffe097          	auipc	ra,0xffffe
    800065ee:	49a080e7          	jalr	1178(ra) # 80004a84 <iunlockput>
  iput(ip);
    800065f2:	8526                	mv	a0,s1
    800065f4:	ffffe097          	auipc	ra,0xffffe
    800065f8:	3e8080e7          	jalr	1000(ra) # 800049dc <iput>
  end_op();
    800065fc:	fffff097          	auipc	ra,0xfffff
    80006600:	c7a080e7          	jalr	-902(ra) # 80005276 <end_op>
  return 0;
    80006604:	4781                	li	a5,0
    80006606:	a085                	j	80006666 <sys_link+0x13c>
    end_op();
    80006608:	fffff097          	auipc	ra,0xfffff
    8000660c:	c6e080e7          	jalr	-914(ra) # 80005276 <end_op>
    return -1;
    80006610:	57fd                	li	a5,-1
    80006612:	a891                	j	80006666 <sys_link+0x13c>
    iunlockput(ip);
    80006614:	8526                	mv	a0,s1
    80006616:	ffffe097          	auipc	ra,0xffffe
    8000661a:	46e080e7          	jalr	1134(ra) # 80004a84 <iunlockput>
    end_op();
    8000661e:	fffff097          	auipc	ra,0xfffff
    80006622:	c58080e7          	jalr	-936(ra) # 80005276 <end_op>
    return -1;
    80006626:	57fd                	li	a5,-1
    80006628:	a83d                	j	80006666 <sys_link+0x13c>
    iunlockput(dp);
    8000662a:	854a                	mv	a0,s2
    8000662c:	ffffe097          	auipc	ra,0xffffe
    80006630:	458080e7          	jalr	1112(ra) # 80004a84 <iunlockput>
  ilock(ip);
    80006634:	8526                	mv	a0,s1
    80006636:	ffffe097          	auipc	ra,0xffffe
    8000663a:	1ec080e7          	jalr	492(ra) # 80004822 <ilock>
  ip->nlink--;
    8000663e:	04a4d783          	lhu	a5,74(s1)
    80006642:	37fd                	addiw	a5,a5,-1
    80006644:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006648:	8526                	mv	a0,s1
    8000664a:	ffffe097          	auipc	ra,0xffffe
    8000664e:	10e080e7          	jalr	270(ra) # 80004758 <iupdate>
  iunlockput(ip);
    80006652:	8526                	mv	a0,s1
    80006654:	ffffe097          	auipc	ra,0xffffe
    80006658:	430080e7          	jalr	1072(ra) # 80004a84 <iunlockput>
  end_op();
    8000665c:	fffff097          	auipc	ra,0xfffff
    80006660:	c1a080e7          	jalr	-998(ra) # 80005276 <end_op>
  return -1;
    80006664:	57fd                	li	a5,-1
}
    80006666:	853e                	mv	a0,a5
    80006668:	70b2                	ld	ra,296(sp)
    8000666a:	7412                	ld	s0,288(sp)
    8000666c:	64f2                	ld	s1,280(sp)
    8000666e:	6952                	ld	s2,272(sp)
    80006670:	6155                	addi	sp,sp,304
    80006672:	8082                	ret

0000000080006674 <sys_unlink>:
{
    80006674:	7151                	addi	sp,sp,-240
    80006676:	f586                	sd	ra,232(sp)
    80006678:	f1a2                	sd	s0,224(sp)
    8000667a:	eda6                	sd	s1,216(sp)
    8000667c:	e9ca                	sd	s2,208(sp)
    8000667e:	e5ce                	sd	s3,200(sp)
    80006680:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80006682:	08000613          	li	a2,128
    80006686:	f3040593          	addi	a1,s0,-208
    8000668a:	4501                	li	a0,0
    8000668c:	ffffd097          	auipc	ra,0xffffd
    80006690:	494080e7          	jalr	1172(ra) # 80003b20 <argstr>
    80006694:	18054163          	bltz	a0,80006816 <sys_unlink+0x1a2>
  begin_op();
    80006698:	fffff097          	auipc	ra,0xfffff
    8000669c:	b5e080e7          	jalr	-1186(ra) # 800051f6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800066a0:	fb040593          	addi	a1,s0,-80
    800066a4:	f3040513          	addi	a0,s0,-208
    800066a8:	fffff097          	auipc	ra,0xfffff
    800066ac:	94c080e7          	jalr	-1716(ra) # 80004ff4 <nameiparent>
    800066b0:	84aa                	mv	s1,a0
    800066b2:	c979                	beqz	a0,80006788 <sys_unlink+0x114>
  ilock(dp);
    800066b4:	ffffe097          	auipc	ra,0xffffe
    800066b8:	16e080e7          	jalr	366(ra) # 80004822 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800066bc:	00003597          	auipc	a1,0x3
    800066c0:	38458593          	addi	a1,a1,900 # 80009a40 <syscalls+0x2e8>
    800066c4:	fb040513          	addi	a0,s0,-80
    800066c8:	ffffe097          	auipc	ra,0xffffe
    800066cc:	624080e7          	jalr	1572(ra) # 80004cec <namecmp>
    800066d0:	14050a63          	beqz	a0,80006824 <sys_unlink+0x1b0>
    800066d4:	00003597          	auipc	a1,0x3
    800066d8:	37458593          	addi	a1,a1,884 # 80009a48 <syscalls+0x2f0>
    800066dc:	fb040513          	addi	a0,s0,-80
    800066e0:	ffffe097          	auipc	ra,0xffffe
    800066e4:	60c080e7          	jalr	1548(ra) # 80004cec <namecmp>
    800066e8:	12050e63          	beqz	a0,80006824 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800066ec:	f2c40613          	addi	a2,s0,-212
    800066f0:	fb040593          	addi	a1,s0,-80
    800066f4:	8526                	mv	a0,s1
    800066f6:	ffffe097          	auipc	ra,0xffffe
    800066fa:	610080e7          	jalr	1552(ra) # 80004d06 <dirlookup>
    800066fe:	892a                	mv	s2,a0
    80006700:	12050263          	beqz	a0,80006824 <sys_unlink+0x1b0>
  ilock(ip);
    80006704:	ffffe097          	auipc	ra,0xffffe
    80006708:	11e080e7          	jalr	286(ra) # 80004822 <ilock>
  if(ip->nlink < 1)
    8000670c:	04a91783          	lh	a5,74(s2)
    80006710:	08f05263          	blez	a5,80006794 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006714:	04491703          	lh	a4,68(s2)
    80006718:	4785                	li	a5,1
    8000671a:	08f70563          	beq	a4,a5,800067a4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000671e:	4641                	li	a2,16
    80006720:	4581                	li	a1,0
    80006722:	fc040513          	addi	a0,s0,-64
    80006726:	ffffa097          	auipc	ra,0xffffa
    8000672a:	5b2080e7          	jalr	1458(ra) # 80000cd8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000672e:	4741                	li	a4,16
    80006730:	f2c42683          	lw	a3,-212(s0)
    80006734:	fc040613          	addi	a2,s0,-64
    80006738:	4581                	li	a1,0
    8000673a:	8526                	mv	a0,s1
    8000673c:	ffffe097          	auipc	ra,0xffffe
    80006740:	492080e7          	jalr	1170(ra) # 80004bce <writei>
    80006744:	47c1                	li	a5,16
    80006746:	0af51563          	bne	a0,a5,800067f0 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000674a:	04491703          	lh	a4,68(s2)
    8000674e:	4785                	li	a5,1
    80006750:	0af70863          	beq	a4,a5,80006800 <sys_unlink+0x18c>
  iunlockput(dp);
    80006754:	8526                	mv	a0,s1
    80006756:	ffffe097          	auipc	ra,0xffffe
    8000675a:	32e080e7          	jalr	814(ra) # 80004a84 <iunlockput>
  ip->nlink--;
    8000675e:	04a95783          	lhu	a5,74(s2)
    80006762:	37fd                	addiw	a5,a5,-1
    80006764:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80006768:	854a                	mv	a0,s2
    8000676a:	ffffe097          	auipc	ra,0xffffe
    8000676e:	fee080e7          	jalr	-18(ra) # 80004758 <iupdate>
  iunlockput(ip);
    80006772:	854a                	mv	a0,s2
    80006774:	ffffe097          	auipc	ra,0xffffe
    80006778:	310080e7          	jalr	784(ra) # 80004a84 <iunlockput>
  end_op();
    8000677c:	fffff097          	auipc	ra,0xfffff
    80006780:	afa080e7          	jalr	-1286(ra) # 80005276 <end_op>
  return 0;
    80006784:	4501                	li	a0,0
    80006786:	a84d                	j	80006838 <sys_unlink+0x1c4>
    end_op();
    80006788:	fffff097          	auipc	ra,0xfffff
    8000678c:	aee080e7          	jalr	-1298(ra) # 80005276 <end_op>
    return -1;
    80006790:	557d                	li	a0,-1
    80006792:	a05d                	j	80006838 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80006794:	00003517          	auipc	a0,0x3
    80006798:	2dc50513          	addi	a0,a0,732 # 80009a70 <syscalls+0x318>
    8000679c:	ffffa097          	auipc	ra,0xffffa
    800067a0:	d92080e7          	jalr	-622(ra) # 8000052e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800067a4:	04c92703          	lw	a4,76(s2)
    800067a8:	02000793          	li	a5,32
    800067ac:	f6e7f9e3          	bgeu	a5,a4,8000671e <sys_unlink+0xaa>
    800067b0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800067b4:	4741                	li	a4,16
    800067b6:	86ce                	mv	a3,s3
    800067b8:	f1840613          	addi	a2,s0,-232
    800067bc:	4581                	li	a1,0
    800067be:	854a                	mv	a0,s2
    800067c0:	ffffe097          	auipc	ra,0xffffe
    800067c4:	316080e7          	jalr	790(ra) # 80004ad6 <readi>
    800067c8:	47c1                	li	a5,16
    800067ca:	00f51b63          	bne	a0,a5,800067e0 <sys_unlink+0x16c>
    if(de.inum != 0)
    800067ce:	f1845783          	lhu	a5,-232(s0)
    800067d2:	e7a1                	bnez	a5,8000681a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800067d4:	29c1                	addiw	s3,s3,16
    800067d6:	04c92783          	lw	a5,76(s2)
    800067da:	fcf9ede3          	bltu	s3,a5,800067b4 <sys_unlink+0x140>
    800067de:	b781                	j	8000671e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800067e0:	00003517          	auipc	a0,0x3
    800067e4:	2a850513          	addi	a0,a0,680 # 80009a88 <syscalls+0x330>
    800067e8:	ffffa097          	auipc	ra,0xffffa
    800067ec:	d46080e7          	jalr	-698(ra) # 8000052e <panic>
    panic("unlink: writei");
    800067f0:	00003517          	auipc	a0,0x3
    800067f4:	2b050513          	addi	a0,a0,688 # 80009aa0 <syscalls+0x348>
    800067f8:	ffffa097          	auipc	ra,0xffffa
    800067fc:	d36080e7          	jalr	-714(ra) # 8000052e <panic>
    dp->nlink--;
    80006800:	04a4d783          	lhu	a5,74(s1)
    80006804:	37fd                	addiw	a5,a5,-1
    80006806:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000680a:	8526                	mv	a0,s1
    8000680c:	ffffe097          	auipc	ra,0xffffe
    80006810:	f4c080e7          	jalr	-180(ra) # 80004758 <iupdate>
    80006814:	b781                	j	80006754 <sys_unlink+0xe0>
    return -1;
    80006816:	557d                	li	a0,-1
    80006818:	a005                	j	80006838 <sys_unlink+0x1c4>
    iunlockput(ip);
    8000681a:	854a                	mv	a0,s2
    8000681c:	ffffe097          	auipc	ra,0xffffe
    80006820:	268080e7          	jalr	616(ra) # 80004a84 <iunlockput>
  iunlockput(dp);
    80006824:	8526                	mv	a0,s1
    80006826:	ffffe097          	auipc	ra,0xffffe
    8000682a:	25e080e7          	jalr	606(ra) # 80004a84 <iunlockput>
  end_op();
    8000682e:	fffff097          	auipc	ra,0xfffff
    80006832:	a48080e7          	jalr	-1464(ra) # 80005276 <end_op>
  return -1;
    80006836:	557d                	li	a0,-1
}
    80006838:	70ae                	ld	ra,232(sp)
    8000683a:	740e                	ld	s0,224(sp)
    8000683c:	64ee                	ld	s1,216(sp)
    8000683e:	694e                	ld	s2,208(sp)
    80006840:	69ae                	ld	s3,200(sp)
    80006842:	616d                	addi	sp,sp,240
    80006844:	8082                	ret

0000000080006846 <sys_open>:

uint64
sys_open(void)
{
    80006846:	7131                	addi	sp,sp,-192
    80006848:	fd06                	sd	ra,184(sp)
    8000684a:	f922                	sd	s0,176(sp)
    8000684c:	f526                	sd	s1,168(sp)
    8000684e:	f14a                	sd	s2,160(sp)
    80006850:	ed4e                	sd	s3,152(sp)
    80006852:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006854:	08000613          	li	a2,128
    80006858:	f5040593          	addi	a1,s0,-176
    8000685c:	4501                	li	a0,0
    8000685e:	ffffd097          	auipc	ra,0xffffd
    80006862:	2c2080e7          	jalr	706(ra) # 80003b20 <argstr>
    return -1;
    80006866:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006868:	0c054163          	bltz	a0,8000692a <sys_open+0xe4>
    8000686c:	f4c40593          	addi	a1,s0,-180
    80006870:	4505                	li	a0,1
    80006872:	ffffd097          	auipc	ra,0xffffd
    80006876:	26a080e7          	jalr	618(ra) # 80003adc <argint>
    8000687a:	0a054863          	bltz	a0,8000692a <sys_open+0xe4>

  begin_op();
    8000687e:	fffff097          	auipc	ra,0xfffff
    80006882:	978080e7          	jalr	-1672(ra) # 800051f6 <begin_op>

  if(omode & O_CREATE){
    80006886:	f4c42783          	lw	a5,-180(s0)
    8000688a:	2007f793          	andi	a5,a5,512
    8000688e:	cbdd                	beqz	a5,80006944 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80006890:	4681                	li	a3,0
    80006892:	4601                	li	a2,0
    80006894:	4589                	li	a1,2
    80006896:	f5040513          	addi	a0,s0,-176
    8000689a:	00000097          	auipc	ra,0x0
    8000689e:	974080e7          	jalr	-1676(ra) # 8000620e <create>
    800068a2:	892a                	mv	s2,a0
    if(ip == 0){
    800068a4:	c959                	beqz	a0,8000693a <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800068a6:	04491703          	lh	a4,68(s2)
    800068aa:	478d                	li	a5,3
    800068ac:	00f71763          	bne	a4,a5,800068ba <sys_open+0x74>
    800068b0:	04695703          	lhu	a4,70(s2)
    800068b4:	47a5                	li	a5,9
    800068b6:	0ce7ec63          	bltu	a5,a4,8000698e <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800068ba:	fffff097          	auipc	ra,0xfffff
    800068be:	d4c080e7          	jalr	-692(ra) # 80005606 <filealloc>
    800068c2:	89aa                	mv	s3,a0
    800068c4:	10050263          	beqz	a0,800069c8 <sys_open+0x182>
    800068c8:	00000097          	auipc	ra,0x0
    800068cc:	904080e7          	jalr	-1788(ra) # 800061cc <fdalloc>
    800068d0:	84aa                	mv	s1,a0
    800068d2:	0e054663          	bltz	a0,800069be <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800068d6:	04491703          	lh	a4,68(s2)
    800068da:	478d                	li	a5,3
    800068dc:	0cf70463          	beq	a4,a5,800069a4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800068e0:	4789                	li	a5,2
    800068e2:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800068e6:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800068ea:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800068ee:	f4c42783          	lw	a5,-180(s0)
    800068f2:	0017c713          	xori	a4,a5,1
    800068f6:	8b05                	andi	a4,a4,1
    800068f8:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800068fc:	0037f713          	andi	a4,a5,3
    80006900:	00e03733          	snez	a4,a4
    80006904:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006908:	4007f793          	andi	a5,a5,1024
    8000690c:	c791                	beqz	a5,80006918 <sys_open+0xd2>
    8000690e:	04491703          	lh	a4,68(s2)
    80006912:	4789                	li	a5,2
    80006914:	08f70f63          	beq	a4,a5,800069b2 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006918:	854a                	mv	a0,s2
    8000691a:	ffffe097          	auipc	ra,0xffffe
    8000691e:	fca080e7          	jalr	-54(ra) # 800048e4 <iunlock>
  end_op();
    80006922:	fffff097          	auipc	ra,0xfffff
    80006926:	954080e7          	jalr	-1708(ra) # 80005276 <end_op>

  return fd;
}
    8000692a:	8526                	mv	a0,s1
    8000692c:	70ea                	ld	ra,184(sp)
    8000692e:	744a                	ld	s0,176(sp)
    80006930:	74aa                	ld	s1,168(sp)
    80006932:	790a                	ld	s2,160(sp)
    80006934:	69ea                	ld	s3,152(sp)
    80006936:	6129                	addi	sp,sp,192
    80006938:	8082                	ret
      end_op();
    8000693a:	fffff097          	auipc	ra,0xfffff
    8000693e:	93c080e7          	jalr	-1732(ra) # 80005276 <end_op>
      return -1;
    80006942:	b7e5                	j	8000692a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006944:	f5040513          	addi	a0,s0,-176
    80006948:	ffffe097          	auipc	ra,0xffffe
    8000694c:	68e080e7          	jalr	1678(ra) # 80004fd6 <namei>
    80006950:	892a                	mv	s2,a0
    80006952:	c905                	beqz	a0,80006982 <sys_open+0x13c>
    ilock(ip);
    80006954:	ffffe097          	auipc	ra,0xffffe
    80006958:	ece080e7          	jalr	-306(ra) # 80004822 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000695c:	04491703          	lh	a4,68(s2)
    80006960:	4785                	li	a5,1
    80006962:	f4f712e3          	bne	a4,a5,800068a6 <sys_open+0x60>
    80006966:	f4c42783          	lw	a5,-180(s0)
    8000696a:	dba1                	beqz	a5,800068ba <sys_open+0x74>
      iunlockput(ip);
    8000696c:	854a                	mv	a0,s2
    8000696e:	ffffe097          	auipc	ra,0xffffe
    80006972:	116080e7          	jalr	278(ra) # 80004a84 <iunlockput>
      end_op();
    80006976:	fffff097          	auipc	ra,0xfffff
    8000697a:	900080e7          	jalr	-1792(ra) # 80005276 <end_op>
      return -1;
    8000697e:	54fd                	li	s1,-1
    80006980:	b76d                	j	8000692a <sys_open+0xe4>
      end_op();
    80006982:	fffff097          	auipc	ra,0xfffff
    80006986:	8f4080e7          	jalr	-1804(ra) # 80005276 <end_op>
      return -1;
    8000698a:	54fd                	li	s1,-1
    8000698c:	bf79                	j	8000692a <sys_open+0xe4>
    iunlockput(ip);
    8000698e:	854a                	mv	a0,s2
    80006990:	ffffe097          	auipc	ra,0xffffe
    80006994:	0f4080e7          	jalr	244(ra) # 80004a84 <iunlockput>
    end_op();
    80006998:	fffff097          	auipc	ra,0xfffff
    8000699c:	8de080e7          	jalr	-1826(ra) # 80005276 <end_op>
    return -1;
    800069a0:	54fd                	li	s1,-1
    800069a2:	b761                	j	8000692a <sys_open+0xe4>
    f->type = FD_DEVICE;
    800069a4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800069a8:	04691783          	lh	a5,70(s2)
    800069ac:	02f99223          	sh	a5,36(s3)
    800069b0:	bf2d                	j	800068ea <sys_open+0xa4>
    itrunc(ip);
    800069b2:	854a                	mv	a0,s2
    800069b4:	ffffe097          	auipc	ra,0xffffe
    800069b8:	f7c080e7          	jalr	-132(ra) # 80004930 <itrunc>
    800069bc:	bfb1                	j	80006918 <sys_open+0xd2>
      fileclose(f);
    800069be:	854e                	mv	a0,s3
    800069c0:	fffff097          	auipc	ra,0xfffff
    800069c4:	d02080e7          	jalr	-766(ra) # 800056c2 <fileclose>
    iunlockput(ip);
    800069c8:	854a                	mv	a0,s2
    800069ca:	ffffe097          	auipc	ra,0xffffe
    800069ce:	0ba080e7          	jalr	186(ra) # 80004a84 <iunlockput>
    end_op();
    800069d2:	fffff097          	auipc	ra,0xfffff
    800069d6:	8a4080e7          	jalr	-1884(ra) # 80005276 <end_op>
    return -1;
    800069da:	54fd                	li	s1,-1
    800069dc:	b7b9                	j	8000692a <sys_open+0xe4>

00000000800069de <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800069de:	7175                	addi	sp,sp,-144
    800069e0:	e506                	sd	ra,136(sp)
    800069e2:	e122                	sd	s0,128(sp)
    800069e4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800069e6:	fffff097          	auipc	ra,0xfffff
    800069ea:	810080e7          	jalr	-2032(ra) # 800051f6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800069ee:	08000613          	li	a2,128
    800069f2:	f7040593          	addi	a1,s0,-144
    800069f6:	4501                	li	a0,0
    800069f8:	ffffd097          	auipc	ra,0xffffd
    800069fc:	128080e7          	jalr	296(ra) # 80003b20 <argstr>
    80006a00:	02054963          	bltz	a0,80006a32 <sys_mkdir+0x54>
    80006a04:	4681                	li	a3,0
    80006a06:	4601                	li	a2,0
    80006a08:	4585                	li	a1,1
    80006a0a:	f7040513          	addi	a0,s0,-144
    80006a0e:	00000097          	auipc	ra,0x0
    80006a12:	800080e7          	jalr	-2048(ra) # 8000620e <create>
    80006a16:	cd11                	beqz	a0,80006a32 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006a18:	ffffe097          	auipc	ra,0xffffe
    80006a1c:	06c080e7          	jalr	108(ra) # 80004a84 <iunlockput>
  end_op();
    80006a20:	fffff097          	auipc	ra,0xfffff
    80006a24:	856080e7          	jalr	-1962(ra) # 80005276 <end_op>
  return 0;
    80006a28:	4501                	li	a0,0
}
    80006a2a:	60aa                	ld	ra,136(sp)
    80006a2c:	640a                	ld	s0,128(sp)
    80006a2e:	6149                	addi	sp,sp,144
    80006a30:	8082                	ret
    end_op();
    80006a32:	fffff097          	auipc	ra,0xfffff
    80006a36:	844080e7          	jalr	-1980(ra) # 80005276 <end_op>
    return -1;
    80006a3a:	557d                	li	a0,-1
    80006a3c:	b7fd                	j	80006a2a <sys_mkdir+0x4c>

0000000080006a3e <sys_mknod>:

uint64
sys_mknod(void)
{
    80006a3e:	7135                	addi	sp,sp,-160
    80006a40:	ed06                	sd	ra,152(sp)
    80006a42:	e922                	sd	s0,144(sp)
    80006a44:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006a46:	ffffe097          	auipc	ra,0xffffe
    80006a4a:	7b0080e7          	jalr	1968(ra) # 800051f6 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006a4e:	08000613          	li	a2,128
    80006a52:	f7040593          	addi	a1,s0,-144
    80006a56:	4501                	li	a0,0
    80006a58:	ffffd097          	auipc	ra,0xffffd
    80006a5c:	0c8080e7          	jalr	200(ra) # 80003b20 <argstr>
    80006a60:	04054a63          	bltz	a0,80006ab4 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80006a64:	f6c40593          	addi	a1,s0,-148
    80006a68:	4505                	li	a0,1
    80006a6a:	ffffd097          	auipc	ra,0xffffd
    80006a6e:	072080e7          	jalr	114(ra) # 80003adc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006a72:	04054163          	bltz	a0,80006ab4 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80006a76:	f6840593          	addi	a1,s0,-152
    80006a7a:	4509                	li	a0,2
    80006a7c:	ffffd097          	auipc	ra,0xffffd
    80006a80:	060080e7          	jalr	96(ra) # 80003adc <argint>
     argint(1, &major) < 0 ||
    80006a84:	02054863          	bltz	a0,80006ab4 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006a88:	f6841683          	lh	a3,-152(s0)
    80006a8c:	f6c41603          	lh	a2,-148(s0)
    80006a90:	458d                	li	a1,3
    80006a92:	f7040513          	addi	a0,s0,-144
    80006a96:	fffff097          	auipc	ra,0xfffff
    80006a9a:	778080e7          	jalr	1912(ra) # 8000620e <create>
     argint(2, &minor) < 0 ||
    80006a9e:	c919                	beqz	a0,80006ab4 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006aa0:	ffffe097          	auipc	ra,0xffffe
    80006aa4:	fe4080e7          	jalr	-28(ra) # 80004a84 <iunlockput>
  end_op();
    80006aa8:	ffffe097          	auipc	ra,0xffffe
    80006aac:	7ce080e7          	jalr	1998(ra) # 80005276 <end_op>
  return 0;
    80006ab0:	4501                	li	a0,0
    80006ab2:	a031                	j	80006abe <sys_mknod+0x80>
    end_op();
    80006ab4:	ffffe097          	auipc	ra,0xffffe
    80006ab8:	7c2080e7          	jalr	1986(ra) # 80005276 <end_op>
    return -1;
    80006abc:	557d                	li	a0,-1
}
    80006abe:	60ea                	ld	ra,152(sp)
    80006ac0:	644a                	ld	s0,144(sp)
    80006ac2:	610d                	addi	sp,sp,160
    80006ac4:	8082                	ret

0000000080006ac6 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006ac6:	7135                	addi	sp,sp,-160
    80006ac8:	ed06                	sd	ra,152(sp)
    80006aca:	e922                	sd	s0,144(sp)
    80006acc:	e526                	sd	s1,136(sp)
    80006ace:	e14a                	sd	s2,128(sp)
    80006ad0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006ad2:	ffffb097          	auipc	ra,0xffffb
    80006ad6:	f9e080e7          	jalr	-98(ra) # 80001a70 <myproc>
    80006ada:	892a                	mv	s2,a0
  
  begin_op();
    80006adc:	ffffe097          	auipc	ra,0xffffe
    80006ae0:	71a080e7          	jalr	1818(ra) # 800051f6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006ae4:	08000613          	li	a2,128
    80006ae8:	f6040593          	addi	a1,s0,-160
    80006aec:	4501                	li	a0,0
    80006aee:	ffffd097          	auipc	ra,0xffffd
    80006af2:	032080e7          	jalr	50(ra) # 80003b20 <argstr>
    80006af6:	04054b63          	bltz	a0,80006b4c <sys_chdir+0x86>
    80006afa:	f6040513          	addi	a0,s0,-160
    80006afe:	ffffe097          	auipc	ra,0xffffe
    80006b02:	4d8080e7          	jalr	1240(ra) # 80004fd6 <namei>
    80006b06:	84aa                	mv	s1,a0
    80006b08:	c131                	beqz	a0,80006b4c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006b0a:	ffffe097          	auipc	ra,0xffffe
    80006b0e:	d18080e7          	jalr	-744(ra) # 80004822 <ilock>
  if(ip->type != T_DIR){
    80006b12:	04449703          	lh	a4,68(s1)
    80006b16:	4785                	li	a5,1
    80006b18:	04f71063          	bne	a4,a5,80006b58 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006b1c:	8526                	mv	a0,s1
    80006b1e:	ffffe097          	auipc	ra,0xffffe
    80006b22:	dc6080e7          	jalr	-570(ra) # 800048e4 <iunlock>
  iput(p->cwd);
    80006b26:	0d093503          	ld	a0,208(s2)
    80006b2a:	ffffe097          	auipc	ra,0xffffe
    80006b2e:	eb2080e7          	jalr	-334(ra) # 800049dc <iput>
  end_op();
    80006b32:	ffffe097          	auipc	ra,0xffffe
    80006b36:	744080e7          	jalr	1860(ra) # 80005276 <end_op>
  p->cwd = ip;
    80006b3a:	0c993823          	sd	s1,208(s2)
  return 0;
    80006b3e:	4501                	li	a0,0
}
    80006b40:	60ea                	ld	ra,152(sp)
    80006b42:	644a                	ld	s0,144(sp)
    80006b44:	64aa                	ld	s1,136(sp)
    80006b46:	690a                	ld	s2,128(sp)
    80006b48:	610d                	addi	sp,sp,160
    80006b4a:	8082                	ret
    end_op();
    80006b4c:	ffffe097          	auipc	ra,0xffffe
    80006b50:	72a080e7          	jalr	1834(ra) # 80005276 <end_op>
    return -1;
    80006b54:	557d                	li	a0,-1
    80006b56:	b7ed                	j	80006b40 <sys_chdir+0x7a>
    iunlockput(ip);
    80006b58:	8526                	mv	a0,s1
    80006b5a:	ffffe097          	auipc	ra,0xffffe
    80006b5e:	f2a080e7          	jalr	-214(ra) # 80004a84 <iunlockput>
    end_op();
    80006b62:	ffffe097          	auipc	ra,0xffffe
    80006b66:	714080e7          	jalr	1812(ra) # 80005276 <end_op>
    return -1;
    80006b6a:	557d                	li	a0,-1
    80006b6c:	bfd1                	j	80006b40 <sys_chdir+0x7a>

0000000080006b6e <sys_exec>:

uint64
sys_exec(void)
{
    80006b6e:	7145                	addi	sp,sp,-464
    80006b70:	e786                	sd	ra,456(sp)
    80006b72:	e3a2                	sd	s0,448(sp)
    80006b74:	ff26                	sd	s1,440(sp)
    80006b76:	fb4a                	sd	s2,432(sp)
    80006b78:	f74e                	sd	s3,424(sp)
    80006b7a:	f352                	sd	s4,416(sp)
    80006b7c:	ef56                	sd	s5,408(sp)
    80006b7e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006b80:	08000613          	li	a2,128
    80006b84:	f4040593          	addi	a1,s0,-192
    80006b88:	4501                	li	a0,0
    80006b8a:	ffffd097          	auipc	ra,0xffffd
    80006b8e:	f96080e7          	jalr	-106(ra) # 80003b20 <argstr>
    return -1;
    80006b92:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006b94:	0c054a63          	bltz	a0,80006c68 <sys_exec+0xfa>
    80006b98:	e3840593          	addi	a1,s0,-456
    80006b9c:	4505                	li	a0,1
    80006b9e:	ffffd097          	auipc	ra,0xffffd
    80006ba2:	f60080e7          	jalr	-160(ra) # 80003afe <argaddr>
    80006ba6:	0c054163          	bltz	a0,80006c68 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006baa:	10000613          	li	a2,256
    80006bae:	4581                	li	a1,0
    80006bb0:	e4040513          	addi	a0,s0,-448
    80006bb4:	ffffa097          	auipc	ra,0xffffa
    80006bb8:	124080e7          	jalr	292(ra) # 80000cd8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006bbc:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006bc0:	89a6                	mv	s3,s1
    80006bc2:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006bc4:	02000a13          	li	s4,32
    80006bc8:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006bcc:	00391793          	slli	a5,s2,0x3
    80006bd0:	e3040593          	addi	a1,s0,-464
    80006bd4:	e3843503          	ld	a0,-456(s0)
    80006bd8:	953e                	add	a0,a0,a5
    80006bda:	ffffd097          	auipc	ra,0xffffd
    80006bde:	e68080e7          	jalr	-408(ra) # 80003a42 <fetchaddr>
    80006be2:	02054a63          	bltz	a0,80006c16 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006be6:	e3043783          	ld	a5,-464(s0)
    80006bea:	c3b9                	beqz	a5,80006c30 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006bec:	ffffa097          	auipc	ra,0xffffa
    80006bf0:	eea080e7          	jalr	-278(ra) # 80000ad6 <kalloc>
    80006bf4:	85aa                	mv	a1,a0
    80006bf6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006bfa:	cd11                	beqz	a0,80006c16 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006bfc:	6605                	lui	a2,0x1
    80006bfe:	e3043503          	ld	a0,-464(s0)
    80006c02:	ffffd097          	auipc	ra,0xffffd
    80006c06:	e92080e7          	jalr	-366(ra) # 80003a94 <fetchstr>
    80006c0a:	00054663          	bltz	a0,80006c16 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006c0e:	0905                	addi	s2,s2,1
    80006c10:	09a1                	addi	s3,s3,8
    80006c12:	fb491be3          	bne	s2,s4,80006bc8 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006c16:	10048913          	addi	s2,s1,256
    80006c1a:	6088                	ld	a0,0(s1)
    80006c1c:	c529                	beqz	a0,80006c66 <sys_exec+0xf8>
    kfree(argv[i]);
    80006c1e:	ffffa097          	auipc	ra,0xffffa
    80006c22:	dbc080e7          	jalr	-580(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006c26:	04a1                	addi	s1,s1,8
    80006c28:	ff2499e3          	bne	s1,s2,80006c1a <sys_exec+0xac>
  return -1;
    80006c2c:	597d                	li	s2,-1
    80006c2e:	a82d                	j	80006c68 <sys_exec+0xfa>
      argv[i] = 0;
    80006c30:	0a8e                	slli	s5,s5,0x3
    80006c32:	fc040793          	addi	a5,s0,-64
    80006c36:	9abe                	add	s5,s5,a5
    80006c38:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006c3c:	e4040593          	addi	a1,s0,-448
    80006c40:	f4040513          	addi	a0,s0,-192
    80006c44:	fffff097          	auipc	ra,0xfffff
    80006c48:	0dc080e7          	jalr	220(ra) # 80005d20 <exec>
    80006c4c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006c4e:	10048993          	addi	s3,s1,256
    80006c52:	6088                	ld	a0,0(s1)
    80006c54:	c911                	beqz	a0,80006c68 <sys_exec+0xfa>
    kfree(argv[i]);
    80006c56:	ffffa097          	auipc	ra,0xffffa
    80006c5a:	d84080e7          	jalr	-636(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006c5e:	04a1                	addi	s1,s1,8
    80006c60:	ff3499e3          	bne	s1,s3,80006c52 <sys_exec+0xe4>
    80006c64:	a011                	j	80006c68 <sys_exec+0xfa>
  return -1;
    80006c66:	597d                	li	s2,-1
}
    80006c68:	854a                	mv	a0,s2
    80006c6a:	60be                	ld	ra,456(sp)
    80006c6c:	641e                	ld	s0,448(sp)
    80006c6e:	74fa                	ld	s1,440(sp)
    80006c70:	795a                	ld	s2,432(sp)
    80006c72:	79ba                	ld	s3,424(sp)
    80006c74:	7a1a                	ld	s4,416(sp)
    80006c76:	6afa                	ld	s5,408(sp)
    80006c78:	6179                	addi	sp,sp,464
    80006c7a:	8082                	ret

0000000080006c7c <sys_pipe>:

uint64
sys_pipe(void)
{
    80006c7c:	7139                	addi	sp,sp,-64
    80006c7e:	fc06                	sd	ra,56(sp)
    80006c80:	f822                	sd	s0,48(sp)
    80006c82:	f426                	sd	s1,40(sp)
    80006c84:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006c86:	ffffb097          	auipc	ra,0xffffb
    80006c8a:	dea080e7          	jalr	-534(ra) # 80001a70 <myproc>
    80006c8e:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006c90:	fd840593          	addi	a1,s0,-40
    80006c94:	4501                	li	a0,0
    80006c96:	ffffd097          	auipc	ra,0xffffd
    80006c9a:	e68080e7          	jalr	-408(ra) # 80003afe <argaddr>
    return -1;
    80006c9e:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006ca0:	0e054063          	bltz	a0,80006d80 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006ca4:	fc840593          	addi	a1,s0,-56
    80006ca8:	fd040513          	addi	a0,s0,-48
    80006cac:	fffff097          	auipc	ra,0xfffff
    80006cb0:	d46080e7          	jalr	-698(ra) # 800059f2 <pipealloc>
    return -1;
    80006cb4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006cb6:	0c054563          	bltz	a0,80006d80 <sys_pipe+0x104>
  fd0 = -1;
    80006cba:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006cbe:	fd043503          	ld	a0,-48(s0)
    80006cc2:	fffff097          	auipc	ra,0xfffff
    80006cc6:	50a080e7          	jalr	1290(ra) # 800061cc <fdalloc>
    80006cca:	fca42223          	sw	a0,-60(s0)
    80006cce:	08054c63          	bltz	a0,80006d66 <sys_pipe+0xea>
    80006cd2:	fc843503          	ld	a0,-56(s0)
    80006cd6:	fffff097          	auipc	ra,0xfffff
    80006cda:	4f6080e7          	jalr	1270(ra) # 800061cc <fdalloc>
    80006cde:	fca42023          	sw	a0,-64(s0)
    80006ce2:	06054863          	bltz	a0,80006d52 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006ce6:	4691                	li	a3,4
    80006ce8:	fc440613          	addi	a2,s0,-60
    80006cec:	fd843583          	ld	a1,-40(s0)
    80006cf0:	60a8                	ld	a0,64(s1)
    80006cf2:	ffffb097          	auipc	ra,0xffffb
    80006cf6:	966080e7          	jalr	-1690(ra) # 80001658 <copyout>
    80006cfa:	02054063          	bltz	a0,80006d1a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006cfe:	4691                	li	a3,4
    80006d00:	fc040613          	addi	a2,s0,-64
    80006d04:	fd843583          	ld	a1,-40(s0)
    80006d08:	0591                	addi	a1,a1,4
    80006d0a:	60a8                	ld	a0,64(s1)
    80006d0c:	ffffb097          	auipc	ra,0xffffb
    80006d10:	94c080e7          	jalr	-1716(ra) # 80001658 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006d14:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006d16:	06055563          	bgez	a0,80006d80 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006d1a:	fc442783          	lw	a5,-60(s0)
    80006d1e:	07a9                	addi	a5,a5,10
    80006d20:	078e                	slli	a5,a5,0x3
    80006d22:	97a6                	add	a5,a5,s1
    80006d24:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006d28:	fc042503          	lw	a0,-64(s0)
    80006d2c:	0529                	addi	a0,a0,10
    80006d2e:	050e                	slli	a0,a0,0x3
    80006d30:	9526                	add	a0,a0,s1
    80006d32:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006d36:	fd043503          	ld	a0,-48(s0)
    80006d3a:	fffff097          	auipc	ra,0xfffff
    80006d3e:	988080e7          	jalr	-1656(ra) # 800056c2 <fileclose>
    fileclose(wf);
    80006d42:	fc843503          	ld	a0,-56(s0)
    80006d46:	fffff097          	auipc	ra,0xfffff
    80006d4a:	97c080e7          	jalr	-1668(ra) # 800056c2 <fileclose>
    return -1;
    80006d4e:	57fd                	li	a5,-1
    80006d50:	a805                	j	80006d80 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006d52:	fc442783          	lw	a5,-60(s0)
    80006d56:	0007c863          	bltz	a5,80006d66 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006d5a:	00a78513          	addi	a0,a5,10
    80006d5e:	050e                	slli	a0,a0,0x3
    80006d60:	9526                	add	a0,a0,s1
    80006d62:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006d66:	fd043503          	ld	a0,-48(s0)
    80006d6a:	fffff097          	auipc	ra,0xfffff
    80006d6e:	958080e7          	jalr	-1704(ra) # 800056c2 <fileclose>
    fileclose(wf);
    80006d72:	fc843503          	ld	a0,-56(s0)
    80006d76:	fffff097          	auipc	ra,0xfffff
    80006d7a:	94c080e7          	jalr	-1716(ra) # 800056c2 <fileclose>
    return -1;
    80006d7e:	57fd                	li	a5,-1
}
    80006d80:	853e                	mv	a0,a5
    80006d82:	70e2                	ld	ra,56(sp)
    80006d84:	7442                	ld	s0,48(sp)
    80006d86:	74a2                	ld	s1,40(sp)
    80006d88:	6121                	addi	sp,sp,64
    80006d8a:	8082                	ret
    80006d8c:	0000                	unimp
	...

0000000080006d90 <kernelvec>:
    80006d90:	7111                	addi	sp,sp,-256
    80006d92:	e006                	sd	ra,0(sp)
    80006d94:	e40a                	sd	sp,8(sp)
    80006d96:	e80e                	sd	gp,16(sp)
    80006d98:	ec12                	sd	tp,24(sp)
    80006d9a:	f016                	sd	t0,32(sp)
    80006d9c:	f41a                	sd	t1,40(sp)
    80006d9e:	f81e                	sd	t2,48(sp)
    80006da0:	fc22                	sd	s0,56(sp)
    80006da2:	e0a6                	sd	s1,64(sp)
    80006da4:	e4aa                	sd	a0,72(sp)
    80006da6:	e8ae                	sd	a1,80(sp)
    80006da8:	ecb2                	sd	a2,88(sp)
    80006daa:	f0b6                	sd	a3,96(sp)
    80006dac:	f4ba                	sd	a4,104(sp)
    80006dae:	f8be                	sd	a5,112(sp)
    80006db0:	fcc2                	sd	a6,120(sp)
    80006db2:	e146                	sd	a7,128(sp)
    80006db4:	e54a                	sd	s2,136(sp)
    80006db6:	e94e                	sd	s3,144(sp)
    80006db8:	ed52                	sd	s4,152(sp)
    80006dba:	f156                	sd	s5,160(sp)
    80006dbc:	f55a                	sd	s6,168(sp)
    80006dbe:	f95e                	sd	s7,176(sp)
    80006dc0:	fd62                	sd	s8,184(sp)
    80006dc2:	e1e6                	sd	s9,192(sp)
    80006dc4:	e5ea                	sd	s10,200(sp)
    80006dc6:	e9ee                	sd	s11,208(sp)
    80006dc8:	edf2                	sd	t3,216(sp)
    80006dca:	f1f6                	sd	t4,224(sp)
    80006dcc:	f5fa                	sd	t5,232(sp)
    80006dce:	f9fe                	sd	t6,240(sp)
    80006dd0:	b13fc0ef          	jal	ra,800038e2 <kerneltrap>
    80006dd4:	6082                	ld	ra,0(sp)
    80006dd6:	6122                	ld	sp,8(sp)
    80006dd8:	61c2                	ld	gp,16(sp)
    80006dda:	7282                	ld	t0,32(sp)
    80006ddc:	7322                	ld	t1,40(sp)
    80006dde:	73c2                	ld	t2,48(sp)
    80006de0:	7462                	ld	s0,56(sp)
    80006de2:	6486                	ld	s1,64(sp)
    80006de4:	6526                	ld	a0,72(sp)
    80006de6:	65c6                	ld	a1,80(sp)
    80006de8:	6666                	ld	a2,88(sp)
    80006dea:	7686                	ld	a3,96(sp)
    80006dec:	7726                	ld	a4,104(sp)
    80006dee:	77c6                	ld	a5,112(sp)
    80006df0:	7866                	ld	a6,120(sp)
    80006df2:	688a                	ld	a7,128(sp)
    80006df4:	692a                	ld	s2,136(sp)
    80006df6:	69ca                	ld	s3,144(sp)
    80006df8:	6a6a                	ld	s4,152(sp)
    80006dfa:	7a8a                	ld	s5,160(sp)
    80006dfc:	7b2a                	ld	s6,168(sp)
    80006dfe:	7bca                	ld	s7,176(sp)
    80006e00:	7c6a                	ld	s8,184(sp)
    80006e02:	6c8e                	ld	s9,192(sp)
    80006e04:	6d2e                	ld	s10,200(sp)
    80006e06:	6dce                	ld	s11,208(sp)
    80006e08:	6e6e                	ld	t3,216(sp)
    80006e0a:	7e8e                	ld	t4,224(sp)
    80006e0c:	7f2e                	ld	t5,232(sp)
    80006e0e:	7fce                	ld	t6,240(sp)
    80006e10:	6111                	addi	sp,sp,256
    80006e12:	10200073          	sret
    80006e16:	00000013          	nop
    80006e1a:	00000013          	nop
    80006e1e:	0001                	nop

0000000080006e20 <timervec>:
    80006e20:	34051573          	csrrw	a0,mscratch,a0
    80006e24:	e10c                	sd	a1,0(a0)
    80006e26:	e510                	sd	a2,8(a0)
    80006e28:	e914                	sd	a3,16(a0)
    80006e2a:	6d0c                	ld	a1,24(a0)
    80006e2c:	7110                	ld	a2,32(a0)
    80006e2e:	6194                	ld	a3,0(a1)
    80006e30:	96b2                	add	a3,a3,a2
    80006e32:	e194                	sd	a3,0(a1)
    80006e34:	4589                	li	a1,2
    80006e36:	14459073          	csrw	sip,a1
    80006e3a:	6914                	ld	a3,16(a0)
    80006e3c:	6510                	ld	a2,8(a0)
    80006e3e:	610c                	ld	a1,0(a0)
    80006e40:	34051573          	csrrw	a0,mscratch,a0
    80006e44:	30200073          	mret
	...

0000000080006e4a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006e4a:	1141                	addi	sp,sp,-16
    80006e4c:	e422                	sd	s0,8(sp)
    80006e4e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006e50:	0c0007b7          	lui	a5,0xc000
    80006e54:	4705                	li	a4,1
    80006e56:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006e58:	c3d8                	sw	a4,4(a5)
}
    80006e5a:	6422                	ld	s0,8(sp)
    80006e5c:	0141                	addi	sp,sp,16
    80006e5e:	8082                	ret

0000000080006e60 <plicinithart>:

void
plicinithart(void)
{
    80006e60:	1141                	addi	sp,sp,-16
    80006e62:	e406                	sd	ra,8(sp)
    80006e64:	e022                	sd	s0,0(sp)
    80006e66:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006e68:	ffffb097          	auipc	ra,0xffffb
    80006e6c:	bd4080e7          	jalr	-1068(ra) # 80001a3c <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006e70:	0085171b          	slliw	a4,a0,0x8
    80006e74:	0c0027b7          	lui	a5,0xc002
    80006e78:	97ba                	add	a5,a5,a4
    80006e7a:	40200713          	li	a4,1026
    80006e7e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006e82:	00d5151b          	slliw	a0,a0,0xd
    80006e86:	0c2017b7          	lui	a5,0xc201
    80006e8a:	953e                	add	a0,a0,a5
    80006e8c:	00052023          	sw	zero,0(a0)
}
    80006e90:	60a2                	ld	ra,8(sp)
    80006e92:	6402                	ld	s0,0(sp)
    80006e94:	0141                	addi	sp,sp,16
    80006e96:	8082                	ret

0000000080006e98 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006e98:	1141                	addi	sp,sp,-16
    80006e9a:	e406                	sd	ra,8(sp)
    80006e9c:	e022                	sd	s0,0(sp)
    80006e9e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006ea0:	ffffb097          	auipc	ra,0xffffb
    80006ea4:	b9c080e7          	jalr	-1124(ra) # 80001a3c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006ea8:	00d5179b          	slliw	a5,a0,0xd
    80006eac:	0c201537          	lui	a0,0xc201
    80006eb0:	953e                	add	a0,a0,a5
  return irq;
}
    80006eb2:	4148                	lw	a0,4(a0)
    80006eb4:	60a2                	ld	ra,8(sp)
    80006eb6:	6402                	ld	s0,0(sp)
    80006eb8:	0141                	addi	sp,sp,16
    80006eba:	8082                	ret

0000000080006ebc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006ebc:	1101                	addi	sp,sp,-32
    80006ebe:	ec06                	sd	ra,24(sp)
    80006ec0:	e822                	sd	s0,16(sp)
    80006ec2:	e426                	sd	s1,8(sp)
    80006ec4:	1000                	addi	s0,sp,32
    80006ec6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006ec8:	ffffb097          	auipc	ra,0xffffb
    80006ecc:	b74080e7          	jalr	-1164(ra) # 80001a3c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006ed0:	00d5151b          	slliw	a0,a0,0xd
    80006ed4:	0c2017b7          	lui	a5,0xc201
    80006ed8:	97aa                	add	a5,a5,a0
    80006eda:	c3c4                	sw	s1,4(a5)
}
    80006edc:	60e2                	ld	ra,24(sp)
    80006ede:	6442                	ld	s0,16(sp)
    80006ee0:	64a2                	ld	s1,8(sp)
    80006ee2:	6105                	addi	sp,sp,32
    80006ee4:	8082                	ret

0000000080006ee6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006ee6:	1141                	addi	sp,sp,-16
    80006ee8:	e406                	sd	ra,8(sp)
    80006eea:	e022                	sd	s0,0(sp)
    80006eec:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006eee:	479d                	li	a5,7
    80006ef0:	06a7c963          	blt	a5,a0,80006f62 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006ef4:	00038797          	auipc	a5,0x38
    80006ef8:	10c78793          	addi	a5,a5,268 # 8003f000 <disk>
    80006efc:	00a78733          	add	a4,a5,a0
    80006f00:	6789                	lui	a5,0x2
    80006f02:	97ba                	add	a5,a5,a4
    80006f04:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006f08:	e7ad                	bnez	a5,80006f72 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006f0a:	00451793          	slli	a5,a0,0x4
    80006f0e:	0003a717          	auipc	a4,0x3a
    80006f12:	0f270713          	addi	a4,a4,242 # 80041000 <disk+0x2000>
    80006f16:	6314                	ld	a3,0(a4)
    80006f18:	96be                	add	a3,a3,a5
    80006f1a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006f1e:	6314                	ld	a3,0(a4)
    80006f20:	96be                	add	a3,a3,a5
    80006f22:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006f26:	6314                	ld	a3,0(a4)
    80006f28:	96be                	add	a3,a3,a5
    80006f2a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006f2e:	6318                	ld	a4,0(a4)
    80006f30:	97ba                	add	a5,a5,a4
    80006f32:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006f36:	00038797          	auipc	a5,0x38
    80006f3a:	0ca78793          	addi	a5,a5,202 # 8003f000 <disk>
    80006f3e:	97aa                	add	a5,a5,a0
    80006f40:	6509                	lui	a0,0x2
    80006f42:	953e                	add	a0,a0,a5
    80006f44:	4785                	li	a5,1
    80006f46:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006f4a:	0003a517          	auipc	a0,0x3a
    80006f4e:	0ce50513          	addi	a0,a0,206 # 80041018 <disk+0x2018>
    80006f52:	ffffb097          	auipc	ra,0xffffb
    80006f56:	622080e7          	jalr	1570(ra) # 80002574 <wakeup>
}
    80006f5a:	60a2                	ld	ra,8(sp)
    80006f5c:	6402                	ld	s0,0(sp)
    80006f5e:	0141                	addi	sp,sp,16
    80006f60:	8082                	ret
    panic("free_desc 1");
    80006f62:	00003517          	auipc	a0,0x3
    80006f66:	b4e50513          	addi	a0,a0,-1202 # 80009ab0 <syscalls+0x358>
    80006f6a:	ffff9097          	auipc	ra,0xffff9
    80006f6e:	5c4080e7          	jalr	1476(ra) # 8000052e <panic>
    panic("free_desc 2");
    80006f72:	00003517          	auipc	a0,0x3
    80006f76:	b4e50513          	addi	a0,a0,-1202 # 80009ac0 <syscalls+0x368>
    80006f7a:	ffff9097          	auipc	ra,0xffff9
    80006f7e:	5b4080e7          	jalr	1460(ra) # 8000052e <panic>

0000000080006f82 <virtio_disk_init>:
{
    80006f82:	1101                	addi	sp,sp,-32
    80006f84:	ec06                	sd	ra,24(sp)
    80006f86:	e822                	sd	s0,16(sp)
    80006f88:	e426                	sd	s1,8(sp)
    80006f8a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006f8c:	00003597          	auipc	a1,0x3
    80006f90:	b4458593          	addi	a1,a1,-1212 # 80009ad0 <syscalls+0x378>
    80006f94:	0003a517          	auipc	a0,0x3a
    80006f98:	19450513          	addi	a0,a0,404 # 80041128 <disk+0x2128>
    80006f9c:	ffffa097          	auipc	ra,0xffffa
    80006fa0:	b9a080e7          	jalr	-1126(ra) # 80000b36 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006fa4:	100017b7          	lui	a5,0x10001
    80006fa8:	4398                	lw	a4,0(a5)
    80006faa:	2701                	sext.w	a4,a4
    80006fac:	747277b7          	lui	a5,0x74727
    80006fb0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006fb4:	0ef71163          	bne	a4,a5,80007096 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006fb8:	100017b7          	lui	a5,0x10001
    80006fbc:	43dc                	lw	a5,4(a5)
    80006fbe:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006fc0:	4705                	li	a4,1
    80006fc2:	0ce79a63          	bne	a5,a4,80007096 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006fc6:	100017b7          	lui	a5,0x10001
    80006fca:	479c                	lw	a5,8(a5)
    80006fcc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006fce:	4709                	li	a4,2
    80006fd0:	0ce79363          	bne	a5,a4,80007096 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006fd4:	100017b7          	lui	a5,0x10001
    80006fd8:	47d8                	lw	a4,12(a5)
    80006fda:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006fdc:	554d47b7          	lui	a5,0x554d4
    80006fe0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006fe4:	0af71963          	bne	a4,a5,80007096 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006fe8:	100017b7          	lui	a5,0x10001
    80006fec:	4705                	li	a4,1
    80006fee:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006ff0:	470d                	li	a4,3
    80006ff2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006ff4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006ff6:	c7ffe737          	lui	a4,0xc7ffe
    80006ffa:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fbc75f>
    80006ffe:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80007000:	2701                	sext.w	a4,a4
    80007002:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007004:	472d                	li	a4,11
    80007006:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007008:	473d                	li	a4,15
    8000700a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000700c:	6705                	lui	a4,0x1
    8000700e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80007010:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80007014:	5bdc                	lw	a5,52(a5)
    80007016:	2781                	sext.w	a5,a5
  if(max == 0)
    80007018:	c7d9                	beqz	a5,800070a6 <virtio_disk_init+0x124>
  if(max < NUM)
    8000701a:	471d                	li	a4,7
    8000701c:	08f77d63          	bgeu	a4,a5,800070b6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80007020:	100014b7          	lui	s1,0x10001
    80007024:	47a1                	li	a5,8
    80007026:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80007028:	6609                	lui	a2,0x2
    8000702a:	4581                	li	a1,0
    8000702c:	00038517          	auipc	a0,0x38
    80007030:	fd450513          	addi	a0,a0,-44 # 8003f000 <disk>
    80007034:	ffffa097          	auipc	ra,0xffffa
    80007038:	ca4080e7          	jalr	-860(ra) # 80000cd8 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000703c:	00038717          	auipc	a4,0x38
    80007040:	fc470713          	addi	a4,a4,-60 # 8003f000 <disk>
    80007044:	00c75793          	srli	a5,a4,0xc
    80007048:	2781                	sext.w	a5,a5
    8000704a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000704c:	0003a797          	auipc	a5,0x3a
    80007050:	fb478793          	addi	a5,a5,-76 # 80041000 <disk+0x2000>
    80007054:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80007056:	00038717          	auipc	a4,0x38
    8000705a:	02a70713          	addi	a4,a4,42 # 8003f080 <disk+0x80>
    8000705e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80007060:	00039717          	auipc	a4,0x39
    80007064:	fa070713          	addi	a4,a4,-96 # 80040000 <disk+0x1000>
    80007068:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000706a:	4705                	li	a4,1
    8000706c:	00e78c23          	sb	a4,24(a5)
    80007070:	00e78ca3          	sb	a4,25(a5)
    80007074:	00e78d23          	sb	a4,26(a5)
    80007078:	00e78da3          	sb	a4,27(a5)
    8000707c:	00e78e23          	sb	a4,28(a5)
    80007080:	00e78ea3          	sb	a4,29(a5)
    80007084:	00e78f23          	sb	a4,30(a5)
    80007088:	00e78fa3          	sb	a4,31(a5)
}
    8000708c:	60e2                	ld	ra,24(sp)
    8000708e:	6442                	ld	s0,16(sp)
    80007090:	64a2                	ld	s1,8(sp)
    80007092:	6105                	addi	sp,sp,32
    80007094:	8082                	ret
    panic("could not find virtio disk");
    80007096:	00003517          	auipc	a0,0x3
    8000709a:	a4a50513          	addi	a0,a0,-1462 # 80009ae0 <syscalls+0x388>
    8000709e:	ffff9097          	auipc	ra,0xffff9
    800070a2:	490080e7          	jalr	1168(ra) # 8000052e <panic>
    panic("virtio disk has no queue 0");
    800070a6:	00003517          	auipc	a0,0x3
    800070aa:	a5a50513          	addi	a0,a0,-1446 # 80009b00 <syscalls+0x3a8>
    800070ae:	ffff9097          	auipc	ra,0xffff9
    800070b2:	480080e7          	jalr	1152(ra) # 8000052e <panic>
    panic("virtio disk max queue too short");
    800070b6:	00003517          	auipc	a0,0x3
    800070ba:	a6a50513          	addi	a0,a0,-1430 # 80009b20 <syscalls+0x3c8>
    800070be:	ffff9097          	auipc	ra,0xffff9
    800070c2:	470080e7          	jalr	1136(ra) # 8000052e <panic>

00000000800070c6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800070c6:	7119                	addi	sp,sp,-128
    800070c8:	fc86                	sd	ra,120(sp)
    800070ca:	f8a2                	sd	s0,112(sp)
    800070cc:	f4a6                	sd	s1,104(sp)
    800070ce:	f0ca                	sd	s2,96(sp)
    800070d0:	ecce                	sd	s3,88(sp)
    800070d2:	e8d2                	sd	s4,80(sp)
    800070d4:	e4d6                	sd	s5,72(sp)
    800070d6:	e0da                	sd	s6,64(sp)
    800070d8:	fc5e                	sd	s7,56(sp)
    800070da:	f862                	sd	s8,48(sp)
    800070dc:	f466                	sd	s9,40(sp)
    800070de:	f06a                	sd	s10,32(sp)
    800070e0:	ec6e                	sd	s11,24(sp)
    800070e2:	0100                	addi	s0,sp,128
    800070e4:	8aaa                	mv	s5,a0
    800070e6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800070e8:	00c52c83          	lw	s9,12(a0)
    800070ec:	001c9c9b          	slliw	s9,s9,0x1
    800070f0:	1c82                	slli	s9,s9,0x20
    800070f2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800070f6:	0003a517          	auipc	a0,0x3a
    800070fa:	03250513          	addi	a0,a0,50 # 80041128 <disk+0x2128>
    800070fe:	ffffa097          	auipc	ra,0xffffa
    80007102:	ac8080e7          	jalr	-1336(ra) # 80000bc6 <acquire>
  for(int i = 0; i < 3; i++){
    80007106:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80007108:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000710a:	00038c17          	auipc	s8,0x38
    8000710e:	ef6c0c13          	addi	s8,s8,-266 # 8003f000 <disk>
    80007112:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80007114:	4b0d                	li	s6,3
    80007116:	a0ad                	j	80007180 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80007118:	00fc0733          	add	a4,s8,a5
    8000711c:	975e                	add	a4,a4,s7
    8000711e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80007122:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80007124:	0207c563          	bltz	a5,8000714e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80007128:	2905                	addiw	s2,s2,1
    8000712a:	0611                	addi	a2,a2,4
    8000712c:	19690d63          	beq	s2,s6,800072c6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80007130:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80007132:	0003a717          	auipc	a4,0x3a
    80007136:	ee670713          	addi	a4,a4,-282 # 80041018 <disk+0x2018>
    8000713a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000713c:	00074683          	lbu	a3,0(a4)
    80007140:	fee1                	bnez	a3,80007118 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80007142:	2785                	addiw	a5,a5,1
    80007144:	0705                	addi	a4,a4,1
    80007146:	fe979be3          	bne	a5,s1,8000713c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000714a:	57fd                	li	a5,-1
    8000714c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000714e:	01205d63          	blez	s2,80007168 <virtio_disk_rw+0xa2>
    80007152:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80007154:	000a2503          	lw	a0,0(s4)
    80007158:	00000097          	auipc	ra,0x0
    8000715c:	d8e080e7          	jalr	-626(ra) # 80006ee6 <free_desc>
      for(int j = 0; j < i; j++)
    80007160:	2d85                	addiw	s11,s11,1
    80007162:	0a11                	addi	s4,s4,4
    80007164:	ffb918e3          	bne	s2,s11,80007154 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80007168:	0003a597          	auipc	a1,0x3a
    8000716c:	fc058593          	addi	a1,a1,-64 # 80041128 <disk+0x2128>
    80007170:	0003a517          	auipc	a0,0x3a
    80007174:	ea850513          	addi	a0,a0,-344 # 80041018 <disk+0x2018>
    80007178:	ffffb097          	auipc	ra,0xffffb
    8000717c:	272080e7          	jalr	626(ra) # 800023ea <sleep>
  for(int i = 0; i < 3; i++){
    80007180:	f8040a13          	addi	s4,s0,-128
{
    80007184:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80007186:	894e                	mv	s2,s3
    80007188:	b765                	j	80007130 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000718a:	0003a697          	auipc	a3,0x3a
    8000718e:	e766b683          	ld	a3,-394(a3) # 80041000 <disk+0x2000>
    80007192:	96ba                	add	a3,a3,a4
    80007194:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80007198:	00038817          	auipc	a6,0x38
    8000719c:	e6880813          	addi	a6,a6,-408 # 8003f000 <disk>
    800071a0:	0003a697          	auipc	a3,0x3a
    800071a4:	e6068693          	addi	a3,a3,-416 # 80041000 <disk+0x2000>
    800071a8:	6290                	ld	a2,0(a3)
    800071aa:	963a                	add	a2,a2,a4
    800071ac:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800071b0:	0015e593          	ori	a1,a1,1
    800071b4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800071b8:	f8842603          	lw	a2,-120(s0)
    800071bc:	628c                	ld	a1,0(a3)
    800071be:	972e                	add	a4,a4,a1
    800071c0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800071c4:	20050593          	addi	a1,a0,512
    800071c8:	0592                	slli	a1,a1,0x4
    800071ca:	95c2                	add	a1,a1,a6
    800071cc:	577d                	li	a4,-1
    800071ce:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800071d2:	00461713          	slli	a4,a2,0x4
    800071d6:	6290                	ld	a2,0(a3)
    800071d8:	963a                	add	a2,a2,a4
    800071da:	03078793          	addi	a5,a5,48
    800071de:	97c2                	add	a5,a5,a6
    800071e0:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800071e2:	629c                	ld	a5,0(a3)
    800071e4:	97ba                	add	a5,a5,a4
    800071e6:	4605                	li	a2,1
    800071e8:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800071ea:	629c                	ld	a5,0(a3)
    800071ec:	97ba                	add	a5,a5,a4
    800071ee:	4809                	li	a6,2
    800071f0:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800071f4:	629c                	ld	a5,0(a3)
    800071f6:	973e                	add	a4,a4,a5
    800071f8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800071fc:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80007200:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80007204:	6698                	ld	a4,8(a3)
    80007206:	00275783          	lhu	a5,2(a4)
    8000720a:	8b9d                	andi	a5,a5,7
    8000720c:	0786                	slli	a5,a5,0x1
    8000720e:	97ba                	add	a5,a5,a4
    80007210:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80007214:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80007218:	6698                	ld	a4,8(a3)
    8000721a:	00275783          	lhu	a5,2(a4)
    8000721e:	2785                	addiw	a5,a5,1
    80007220:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80007224:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80007228:	100017b7          	lui	a5,0x10001
    8000722c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80007230:	004aa783          	lw	a5,4(s5)
    80007234:	02c79163          	bne	a5,a2,80007256 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80007238:	0003a917          	auipc	s2,0x3a
    8000723c:	ef090913          	addi	s2,s2,-272 # 80041128 <disk+0x2128>
  while(b->disk == 1) {
    80007240:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80007242:	85ca                	mv	a1,s2
    80007244:	8556                	mv	a0,s5
    80007246:	ffffb097          	auipc	ra,0xffffb
    8000724a:	1a4080e7          	jalr	420(ra) # 800023ea <sleep>
  while(b->disk == 1) {
    8000724e:	004aa783          	lw	a5,4(s5)
    80007252:	fe9788e3          	beq	a5,s1,80007242 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80007256:	f8042903          	lw	s2,-128(s0)
    8000725a:	20090793          	addi	a5,s2,512
    8000725e:	00479713          	slli	a4,a5,0x4
    80007262:	00038797          	auipc	a5,0x38
    80007266:	d9e78793          	addi	a5,a5,-610 # 8003f000 <disk>
    8000726a:	97ba                	add	a5,a5,a4
    8000726c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80007270:	0003a997          	auipc	s3,0x3a
    80007274:	d9098993          	addi	s3,s3,-624 # 80041000 <disk+0x2000>
    80007278:	00491713          	slli	a4,s2,0x4
    8000727c:	0009b783          	ld	a5,0(s3)
    80007280:	97ba                	add	a5,a5,a4
    80007282:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80007286:	854a                	mv	a0,s2
    80007288:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000728c:	00000097          	auipc	ra,0x0
    80007290:	c5a080e7          	jalr	-934(ra) # 80006ee6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80007294:	8885                	andi	s1,s1,1
    80007296:	f0ed                	bnez	s1,80007278 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80007298:	0003a517          	auipc	a0,0x3a
    8000729c:	e9050513          	addi	a0,a0,-368 # 80041128 <disk+0x2128>
    800072a0:	ffffa097          	auipc	ra,0xffffa
    800072a4:	9f0080e7          	jalr	-1552(ra) # 80000c90 <release>
}
    800072a8:	70e6                	ld	ra,120(sp)
    800072aa:	7446                	ld	s0,112(sp)
    800072ac:	74a6                	ld	s1,104(sp)
    800072ae:	7906                	ld	s2,96(sp)
    800072b0:	69e6                	ld	s3,88(sp)
    800072b2:	6a46                	ld	s4,80(sp)
    800072b4:	6aa6                	ld	s5,72(sp)
    800072b6:	6b06                	ld	s6,64(sp)
    800072b8:	7be2                	ld	s7,56(sp)
    800072ba:	7c42                	ld	s8,48(sp)
    800072bc:	7ca2                	ld	s9,40(sp)
    800072be:	7d02                	ld	s10,32(sp)
    800072c0:	6de2                	ld	s11,24(sp)
    800072c2:	6109                	addi	sp,sp,128
    800072c4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800072c6:	f8042503          	lw	a0,-128(s0)
    800072ca:	20050793          	addi	a5,a0,512
    800072ce:	0792                	slli	a5,a5,0x4
  if(write)
    800072d0:	00038817          	auipc	a6,0x38
    800072d4:	d3080813          	addi	a6,a6,-720 # 8003f000 <disk>
    800072d8:	00f80733          	add	a4,a6,a5
    800072dc:	01a036b3          	snez	a3,s10
    800072e0:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800072e4:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800072e8:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800072ec:	7679                	lui	a2,0xffffe
    800072ee:	963e                	add	a2,a2,a5
    800072f0:	0003a697          	auipc	a3,0x3a
    800072f4:	d1068693          	addi	a3,a3,-752 # 80041000 <disk+0x2000>
    800072f8:	6298                	ld	a4,0(a3)
    800072fa:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800072fc:	0a878593          	addi	a1,a5,168
    80007300:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007302:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80007304:	6298                	ld	a4,0(a3)
    80007306:	9732                	add	a4,a4,a2
    80007308:	45c1                	li	a1,16
    8000730a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000730c:	6298                	ld	a4,0(a3)
    8000730e:	9732                	add	a4,a4,a2
    80007310:	4585                	li	a1,1
    80007312:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007316:	f8442703          	lw	a4,-124(s0)
    8000731a:	628c                	ld	a1,0(a3)
    8000731c:	962e                	add	a2,a2,a1
    8000731e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffbc00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80007322:	0712                	slli	a4,a4,0x4
    80007324:	6290                	ld	a2,0(a3)
    80007326:	963a                	add	a2,a2,a4
    80007328:	058a8593          	addi	a1,s5,88
    8000732c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000732e:	6294                	ld	a3,0(a3)
    80007330:	96ba                	add	a3,a3,a4
    80007332:	40000613          	li	a2,1024
    80007336:	c690                	sw	a2,8(a3)
  if(write)
    80007338:	e40d19e3          	bnez	s10,8000718a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000733c:	0003a697          	auipc	a3,0x3a
    80007340:	cc46b683          	ld	a3,-828(a3) # 80041000 <disk+0x2000>
    80007344:	96ba                	add	a3,a3,a4
    80007346:	4609                	li	a2,2
    80007348:	00c69623          	sh	a2,12(a3)
    8000734c:	b5b1                	j	80007198 <virtio_disk_rw+0xd2>

000000008000734e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000734e:	1101                	addi	sp,sp,-32
    80007350:	ec06                	sd	ra,24(sp)
    80007352:	e822                	sd	s0,16(sp)
    80007354:	e426                	sd	s1,8(sp)
    80007356:	e04a                	sd	s2,0(sp)
    80007358:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000735a:	0003a517          	auipc	a0,0x3a
    8000735e:	dce50513          	addi	a0,a0,-562 # 80041128 <disk+0x2128>
    80007362:	ffffa097          	auipc	ra,0xffffa
    80007366:	864080e7          	jalr	-1948(ra) # 80000bc6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000736a:	10001737          	lui	a4,0x10001
    8000736e:	533c                	lw	a5,96(a4)
    80007370:	8b8d                	andi	a5,a5,3
    80007372:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80007374:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80007378:	0003a797          	auipc	a5,0x3a
    8000737c:	c8878793          	addi	a5,a5,-888 # 80041000 <disk+0x2000>
    80007380:	6b94                	ld	a3,16(a5)
    80007382:	0207d703          	lhu	a4,32(a5)
    80007386:	0026d783          	lhu	a5,2(a3)
    8000738a:	06f70163          	beq	a4,a5,800073ec <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000738e:	00038917          	auipc	s2,0x38
    80007392:	c7290913          	addi	s2,s2,-910 # 8003f000 <disk>
    80007396:	0003a497          	auipc	s1,0x3a
    8000739a:	c6a48493          	addi	s1,s1,-918 # 80041000 <disk+0x2000>
    __sync_synchronize();
    8000739e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800073a2:	6898                	ld	a4,16(s1)
    800073a4:	0204d783          	lhu	a5,32(s1)
    800073a8:	8b9d                	andi	a5,a5,7
    800073aa:	078e                	slli	a5,a5,0x3
    800073ac:	97ba                	add	a5,a5,a4
    800073ae:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800073b0:	20078713          	addi	a4,a5,512
    800073b4:	0712                	slli	a4,a4,0x4
    800073b6:	974a                	add	a4,a4,s2
    800073b8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800073bc:	e731                	bnez	a4,80007408 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800073be:	20078793          	addi	a5,a5,512
    800073c2:	0792                	slli	a5,a5,0x4
    800073c4:	97ca                	add	a5,a5,s2
    800073c6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800073c8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800073cc:	ffffb097          	auipc	ra,0xffffb
    800073d0:	1a8080e7          	jalr	424(ra) # 80002574 <wakeup>

    disk.used_idx += 1;
    800073d4:	0204d783          	lhu	a5,32(s1)
    800073d8:	2785                	addiw	a5,a5,1
    800073da:	17c2                	slli	a5,a5,0x30
    800073dc:	93c1                	srli	a5,a5,0x30
    800073de:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800073e2:	6898                	ld	a4,16(s1)
    800073e4:	00275703          	lhu	a4,2(a4)
    800073e8:	faf71be3          	bne	a4,a5,8000739e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800073ec:	0003a517          	auipc	a0,0x3a
    800073f0:	d3c50513          	addi	a0,a0,-708 # 80041128 <disk+0x2128>
    800073f4:	ffffa097          	auipc	ra,0xffffa
    800073f8:	89c080e7          	jalr	-1892(ra) # 80000c90 <release>
}
    800073fc:	60e2                	ld	ra,24(sp)
    800073fe:	6442                	ld	s0,16(sp)
    80007400:	64a2                	ld	s1,8(sp)
    80007402:	6902                	ld	s2,0(sp)
    80007404:	6105                	addi	sp,sp,32
    80007406:	8082                	ret
      panic("virtio_disk_intr status");
    80007408:	00002517          	auipc	a0,0x2
    8000740c:	73850513          	addi	a0,a0,1848 # 80009b40 <syscalls+0x3e8>
    80007410:	ffff9097          	auipc	ra,0xffff9
    80007414:	11e080e7          	jalr	286(ra) # 8000052e <panic>

0000000080007418 <call_sigret>:
    80007418:	48e1                	li	a7,24
    8000741a:	00000073          	ecall
    8000741e:	8082                	ret

0000000080007420 <end_sigret>:
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
