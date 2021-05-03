
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
    80000064:	00007797          	auipc	a5,0x7
    80000068:	8ac78793          	addi	a5,a5,-1876 # 80006910 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffbd7ff>
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
    80000122:	9d2080e7          	jalr	-1582(ra) # 80002af0 <either_copyin>
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
    8000017c:	00011517          	auipc	a0,0x11
    80000180:	00450513          	addi	a0,a0,4 # 80011180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a42080e7          	jalr	-1470(ra) # 80000bc6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00011497          	auipc	s1,0x11
    80000190:	ff448493          	addi	s1,s1,-12 # 80011180 <cons>
      if(myproc()->killed==1){
    80000194:	4905                	li	s2,1
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000196:	00011997          	auipc	s3,0x11
    8000019a:	08298993          	addi	s3,s3,130 # 80011218 <cons+0x98>
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
    800001b6:	956080e7          	jalr	-1706(ra) # 80001b08 <myproc>
    800001ba:	4d5c                	lw	a5,28(a0)
    800001bc:	07278863          	beq	a5,s2,8000022c <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001c0:	85a6                	mv	a1,s1
    800001c2:	854e                	mv	a0,s3
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	3d4080e7          	jalr	980(ra) # 80002598 <sleep>
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
    80000204:	89a080e7          	jalr	-1894(ra) # 80002a9a <either_copyout>
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
    80000216:	00011517          	auipc	a0,0x11
    8000021a:	f6a50513          	addi	a0,a0,-150 # 80011180 <cons>
    8000021e:	00001097          	auipc	ra,0x1
    80000222:	a72080e7          	jalr	-1422(ra) # 80000c90 <release>

  return target - n;
    80000226:	414b853b          	subw	a0,s7,s4
    8000022a:	a811                	j	8000023e <consoleread+0xe8>
        release(&cons.lock);
    8000022c:	00011517          	auipc	a0,0x11
    80000230:	f5450513          	addi	a0,a0,-172 # 80011180 <cons>
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
    80000262:	00011717          	auipc	a4,0x11
    80000266:	faf72b23          	sw	a5,-74(a4) # 80011218 <cons+0x98>
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
    800002bc:	00011517          	auipc	a0,0x11
    800002c0:	ec450513          	addi	a0,a0,-316 # 80011180 <cons>
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
    800002e2:	00003097          	auipc	ra,0x3
    800002e6:	864080e7          	jalr	-1948(ra) # 80002b46 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ea:	00011517          	auipc	a0,0x11
    800002ee:	e9650513          	addi	a0,a0,-362 # 80011180 <cons>
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
    8000030e:	00011717          	auipc	a4,0x11
    80000312:	e7270713          	addi	a4,a4,-398 # 80011180 <cons>
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
    80000338:	00011797          	auipc	a5,0x11
    8000033c:	e4878793          	addi	a5,a5,-440 # 80011180 <cons>
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
    80000366:	00011797          	auipc	a5,0x11
    8000036a:	eb27a783          	lw	a5,-334(a5) # 80011218 <cons+0x98>
    8000036e:	0807879b          	addiw	a5,a5,128
    80000372:	f6f61ce3          	bne	a2,a5,800002ea <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000376:	863e                	mv	a2,a5
    80000378:	a07d                	j	80000426 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000037a:	00011717          	auipc	a4,0x11
    8000037e:	e0670713          	addi	a4,a4,-506 # 80011180 <cons>
    80000382:	0a072783          	lw	a5,160(a4)
    80000386:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000038a:	00011497          	auipc	s1,0x11
    8000038e:	df648493          	addi	s1,s1,-522 # 80011180 <cons>
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
    800003c6:	00011717          	auipc	a4,0x11
    800003ca:	dba70713          	addi	a4,a4,-582 # 80011180 <cons>
    800003ce:	0a072783          	lw	a5,160(a4)
    800003d2:	09c72703          	lw	a4,156(a4)
    800003d6:	f0f70ae3          	beq	a4,a5,800002ea <consoleintr+0x3c>
      cons.e--;
    800003da:	37fd                	addiw	a5,a5,-1
    800003dc:	00011717          	auipc	a4,0x11
    800003e0:	e4f72223          	sw	a5,-444(a4) # 80011220 <cons+0xa0>
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
    80000402:	00011797          	auipc	a5,0x11
    80000406:	d7e78793          	addi	a5,a5,-642 # 80011180 <cons>
    8000040a:	0a07a703          	lw	a4,160(a5)
    8000040e:	0017069b          	addiw	a3,a4,1
    80000412:	0006861b          	sext.w	a2,a3
    80000416:	0ad7a023          	sw	a3,160(a5)
    8000041a:	07f77713          	andi	a4,a4,127
    8000041e:	97ba                	add	a5,a5,a4
    80000420:	4729                	li	a4,10
    80000422:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000426:	00011797          	auipc	a5,0x11
    8000042a:	dec7ab23          	sw	a2,-522(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    8000042e:	00011517          	auipc	a0,0x11
    80000432:	dea50513          	addi	a0,a0,-534 # 80011218 <cons+0x98>
    80000436:	00002097          	auipc	ra,0x2
    8000043a:	2ec080e7          	jalr	748(ra) # 80002722 <wakeup>
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
    80000448:	00008597          	auipc	a1,0x8
    8000044c:	bc858593          	addi	a1,a1,-1080 # 80008010 <etext+0x10>
    80000450:	00011517          	auipc	a0,0x11
    80000454:	d3050513          	addi	a0,a0,-720 # 80011180 <cons>
    80000458:	00000097          	auipc	ra,0x0
    8000045c:	6de080e7          	jalr	1758(ra) # 80000b36 <initlock>

  uartinit();
    80000460:	00000097          	auipc	ra,0x0
    80000464:	32a080e7          	jalr	810(ra) # 8000078a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000468:	0003c797          	auipc	a5,0x3c
    8000046c:	70878793          	addi	a5,a5,1800 # 8003cb70 <devsw>
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
    800004aa:	00008617          	auipc	a2,0x8
    800004ae:	b9660613          	addi	a2,a2,-1130 # 80008040 <digits>
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
    8000053a:	00011797          	auipc	a5,0x11
    8000053e:	d007a323          	sw	zero,-762(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    80000542:	00008517          	auipc	a0,0x8
    80000546:	ad650513          	addi	a0,a0,-1322 # 80008018 <etext+0x18>
    8000054a:	00000097          	auipc	ra,0x0
    8000054e:	02e080e7          	jalr	46(ra) # 80000578 <printf>
  printf(s);
    80000552:	8526                	mv	a0,s1
    80000554:	00000097          	auipc	ra,0x0
    80000558:	024080e7          	jalr	36(ra) # 80000578 <printf>
  printf("\n");
    8000055c:	00008517          	auipc	a0,0x8
    80000560:	bfc50513          	addi	a0,a0,-1028 # 80008158 <digits+0x118>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	014080e7          	jalr	20(ra) # 80000578 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000056c:	4785                	li	a5,1
    8000056e:	00009717          	auipc	a4,0x9
    80000572:	a8f72923          	sw	a5,-1390(a4) # 80009000 <panicked>
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
    800005aa:	00011d97          	auipc	s11,0x11
    800005ae:	c96dad83          	lw	s11,-874(s11) # 80011240 <pr+0x18>
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
    800005d6:	00008b17          	auipc	s6,0x8
    800005da:	a6ab0b13          	addi	s6,s6,-1430 # 80008040 <digits>
    switch(c){
    800005de:	07300c93          	li	s9,115
    800005e2:	06400c13          	li	s8,100
    800005e6:	a82d                	j	80000620 <printf+0xa8>
    acquire(&pr.lock);
    800005e8:	00011517          	auipc	a0,0x11
    800005ec:	c4050513          	addi	a0,a0,-960 # 80011228 <pr>
    800005f0:	00000097          	auipc	ra,0x0
    800005f4:	5d6080e7          	jalr	1494(ra) # 80000bc6 <acquire>
    800005f8:	bf7d                	j	800005b6 <printf+0x3e>
    panic("null fmt");
    800005fa:	00008517          	auipc	a0,0x8
    800005fe:	a2e50513          	addi	a0,a0,-1490 # 80008028 <etext+0x28>
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
    800006f4:	00008497          	auipc	s1,0x8
    800006f8:	92c48493          	addi	s1,s1,-1748 # 80008020 <etext+0x20>
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
    80000746:	00011517          	auipc	a0,0x11
    8000074a:	ae250513          	addi	a0,a0,-1310 # 80011228 <pr>
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
    80000762:	00011497          	auipc	s1,0x11
    80000766:	ac648493          	addi	s1,s1,-1338 # 80011228 <pr>
    8000076a:	00008597          	auipc	a1,0x8
    8000076e:	8ce58593          	addi	a1,a1,-1842 # 80008038 <etext+0x38>
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
    800007ba:	00008597          	auipc	a1,0x8
    800007be:	89e58593          	addi	a1,a1,-1890 # 80008058 <digits+0x18>
    800007c2:	00011517          	auipc	a0,0x11
    800007c6:	a8650513          	addi	a0,a0,-1402 # 80011248 <uart_tx_lock>
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
    800007ee:	00009797          	auipc	a5,0x9
    800007f2:	8127a783          	lw	a5,-2030(a5) # 80009000 <panicked>
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
    80000826:	00008797          	auipc	a5,0x8
    8000082a:	7e27b783          	ld	a5,2018(a5) # 80009008 <uart_tx_r>
    8000082e:	00008717          	auipc	a4,0x8
    80000832:	7e273703          	ld	a4,2018(a4) # 80009010 <uart_tx_w>
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
    80000850:	00011a17          	auipc	s4,0x11
    80000854:	9f8a0a13          	addi	s4,s4,-1544 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000858:	00008497          	auipc	s1,0x8
    8000085c:	7b048493          	addi	s1,s1,1968 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000860:	00008997          	auipc	s3,0x8
    80000864:	7b098993          	addi	s3,s3,1968 # 80009010 <uart_tx_w>
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
    80000886:	ea0080e7          	jalr	-352(ra) # 80002722 <wakeup>
    
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
    800008be:	00011517          	auipc	a0,0x11
    800008c2:	98a50513          	addi	a0,a0,-1654 # 80011248 <uart_tx_lock>
    800008c6:	00000097          	auipc	ra,0x0
    800008ca:	300080e7          	jalr	768(ra) # 80000bc6 <acquire>
  if(panicked){
    800008ce:	00008797          	auipc	a5,0x8
    800008d2:	7327a783          	lw	a5,1842(a5) # 80009000 <panicked>
    800008d6:	c391                	beqz	a5,800008da <uartputc+0x2e>
    for(;;)
    800008d8:	a001                	j	800008d8 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008da:	00008717          	auipc	a4,0x8
    800008de:	73673703          	ld	a4,1846(a4) # 80009010 <uart_tx_w>
    800008e2:	00008797          	auipc	a5,0x8
    800008e6:	7267b783          	ld	a5,1830(a5) # 80009008 <uart_tx_r>
    800008ea:	02078793          	addi	a5,a5,32
    800008ee:	02e79b63          	bne	a5,a4,80000924 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008f2:	00011997          	auipc	s3,0x11
    800008f6:	95698993          	addi	s3,s3,-1706 # 80011248 <uart_tx_lock>
    800008fa:	00008497          	auipc	s1,0x8
    800008fe:	70e48493          	addi	s1,s1,1806 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000902:	00008917          	auipc	s2,0x8
    80000906:	70e90913          	addi	s2,s2,1806 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000090a:	85ce                	mv	a1,s3
    8000090c:	8526                	mv	a0,s1
    8000090e:	00002097          	auipc	ra,0x2
    80000912:	c8a080e7          	jalr	-886(ra) # 80002598 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000916:	00093703          	ld	a4,0(s2)
    8000091a:	609c                	ld	a5,0(s1)
    8000091c:	02078793          	addi	a5,a5,32
    80000920:	fee785e3          	beq	a5,a4,8000090a <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000924:	00011497          	auipc	s1,0x11
    80000928:	92448493          	addi	s1,s1,-1756 # 80011248 <uart_tx_lock>
    8000092c:	01f77793          	andi	a5,a4,31
    80000930:	97a6                	add	a5,a5,s1
    80000932:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000936:	0705                	addi	a4,a4,1
    80000938:	00008797          	auipc	a5,0x8
    8000093c:	6ce7bc23          	sd	a4,1752(a5) # 80009010 <uart_tx_w>
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
    800009ac:	00011497          	auipc	s1,0x11
    800009b0:	89c48493          	addi	s1,s1,-1892 # 80011248 <uart_tx_lock>
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
    800009ee:	00040797          	auipc	a5,0x40
    800009f2:	61278793          	addi	a5,a5,1554 # 80041000 <end>
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
    80000a0e:	00011917          	auipc	s2,0x11
    80000a12:	87290913          	addi	s2,s2,-1934 # 80011280 <kmem>
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
    80000a40:	00007517          	auipc	a0,0x7
    80000a44:	62050513          	addi	a0,a0,1568 # 80008060 <digits+0x20>
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
    80000aa2:	00007597          	auipc	a1,0x7
    80000aa6:	5c658593          	addi	a1,a1,1478 # 80008068 <digits+0x28>
    80000aaa:	00010517          	auipc	a0,0x10
    80000aae:	7d650513          	addi	a0,a0,2006 # 80011280 <kmem>
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	084080e7          	jalr	132(ra) # 80000b36 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aba:	45c5                	li	a1,17
    80000abc:	05ee                	slli	a1,a1,0x1b
    80000abe:	00040517          	auipc	a0,0x40
    80000ac2:	54250513          	addi	a0,a0,1346 # 80041000 <end>
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
    80000ae0:	00010497          	auipc	s1,0x10
    80000ae4:	7a048493          	addi	s1,s1,1952 # 80011280 <kmem>
    80000ae8:	8526                	mv	a0,s1
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	0dc080e7          	jalr	220(ra) # 80000bc6 <acquire>
  r = kmem.freelist;
    80000af2:	6c84                	ld	s1,24(s1)
  if(r)
    80000af4:	c885                	beqz	s1,80000b24 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af6:	609c                	ld	a5,0(s1)
    80000af8:	00010517          	auipc	a0,0x10
    80000afc:	78850513          	addi	a0,a0,1928 # 80011280 <kmem>
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
    80000b24:	00010517          	auipc	a0,0x10
    80000b28:	75c50513          	addi	a0,a0,1884 # 80011280 <kmem>
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
    80000b64:	f84080e7          	jalr	-124(ra) # 80001ae4 <mycpu>
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
    80000b96:	f52080e7          	jalr	-174(ra) # 80001ae4 <mycpu>
    80000b9a:	5d3c                	lw	a5,120(a0)
    80000b9c:	cf89                	beqz	a5,80000bb6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	f46080e7          	jalr	-186(ra) # 80001ae4 <mycpu>
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
    80000bba:	f2e080e7          	jalr	-210(ra) # 80001ae4 <mycpu>
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
    80000bfa:	eee080e7          	jalr	-274(ra) # 80001ae4 <mycpu>
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
    80000c10:	00007517          	auipc	a0,0x7
    80000c14:	46050513          	addi	a0,a0,1120 # 80008070 <digits+0x30>
    80000c18:	00000097          	auipc	ra,0x0
    80000c1c:	960080e7          	jalr	-1696(ra) # 80000578 <printf>
    panic("acquire");
    80000c20:	00007517          	auipc	a0,0x7
    80000c24:	48050513          	addi	a0,a0,1152 # 800080a0 <digits+0x60>
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
    80000c3c:	eac080e7          	jalr	-340(ra) # 80001ae4 <mycpu>
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
    80000c70:	00007517          	auipc	a0,0x7
    80000c74:	43850513          	addi	a0,a0,1080 # 800080a8 <digits+0x68>
    80000c78:	00000097          	auipc	ra,0x0
    80000c7c:	8b6080e7          	jalr	-1866(ra) # 8000052e <panic>
    panic("pop_off");
    80000c80:	00007517          	auipc	a0,0x7
    80000c84:	44050513          	addi	a0,a0,1088 # 800080c0 <digits+0x80>
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
    80000cc8:	00007517          	auipc	a0,0x7
    80000ccc:	40050513          	addi	a0,a0,1024 # 800080c8 <digits+0x88>
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
    80000e92:	c46080e7          	jalr	-954(ra) # 80001ad4 <cpuid>
    userinit();      // first user process
    printf("main -after user init\n");
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e96:	00008717          	auipc	a4,0x8
    80000e9a:	18270713          	addi	a4,a4,386 # 80009018 <started>
  if(cpuid() == 0){
    80000e9e:	c55d                	beqz	a0,80000f4c <main+0xc6>
    while(started == 0)
    80000ea0:	431c                	lw	a5,0(a4)
    80000ea2:	2781                	sext.w	a5,a5
    80000ea4:	dff5                	beqz	a5,80000ea0 <main+0x1a>
      ;
    __sync_synchronize();
    80000ea6:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eaa:	00001097          	auipc	ra,0x1
    80000eae:	c2a080e7          	jalr	-982(ra) # 80001ad4 <cpuid>
    80000eb2:	85aa                	mv	a1,a0
    80000eb4:	00007517          	auipc	a0,0x7
    80000eb8:	24c50513          	addi	a0,a0,588 # 80008100 <digits+0xc0>
    80000ebc:	fffff097          	auipc	ra,0xfffff
    80000ec0:	6bc080e7          	jalr	1724(ra) # 80000578 <printf>
    kvminithart();    // turn on paging
    80000ec4:	00000097          	auipc	ra,0x0
    80000ec8:	150080e7          	jalr	336(ra) # 80001014 <kvminithart>
    printf("hart %d kvm\n", cpuid());
    80000ecc:	00001097          	auipc	ra,0x1
    80000ed0:	c08080e7          	jalr	-1016(ra) # 80001ad4 <cpuid>
    80000ed4:	85aa                	mv	a1,a0
    80000ed6:	00007517          	auipc	a0,0x7
    80000eda:	24250513          	addi	a0,a0,578 # 80008118 <digits+0xd8>
    80000ede:	fffff097          	auipc	ra,0xfffff
    80000ee2:	69a080e7          	jalr	1690(ra) # 80000578 <printf>
    trapinithart();   // install kernel trap vector
    80000ee6:	00002097          	auipc	ra,0x2
    80000eea:	2d8080e7          	jalr	728(ra) # 800031be <trapinithart>
    printf("hart %d trap\n", cpuid());
    80000eee:	00001097          	auipc	ra,0x1
    80000ef2:	be6080e7          	jalr	-1050(ra) # 80001ad4 <cpuid>
    80000ef6:	85aa                	mv	a1,a0
    80000ef8:	00007517          	auipc	a0,0x7
    80000efc:	23050513          	addi	a0,a0,560 # 80008128 <digits+0xe8>
    80000f00:	fffff097          	auipc	ra,0xfffff
    80000f04:	678080e7          	jalr	1656(ra) # 80000578 <printf>

    plicinithart();   // ask PLIC for device interrupts
    80000f08:	00006097          	auipc	ra,0x6
    80000f0c:	a48080e7          	jalr	-1464(ra) # 80006950 <plicinithart>
    printf("hart %d plic\n", cpuid());
    80000f10:	00001097          	auipc	ra,0x1
    80000f14:	bc4080e7          	jalr	-1084(ra) # 80001ad4 <cpuid>
    80000f18:	85aa                	mv	a1,a0
    80000f1a:	00007517          	auipc	a0,0x7
    80000f1e:	21e50513          	addi	a0,a0,542 # 80008138 <digits+0xf8>
    80000f22:	fffff097          	auipc	ra,0xfffff
    80000f26:	656080e7          	jalr	1622(ra) # 80000578 <printf>
  }
  printf("before sched %d \n", cpuid());
    80000f2a:	00001097          	auipc	ra,0x1
    80000f2e:	baa080e7          	jalr	-1110(ra) # 80001ad4 <cpuid>
    80000f32:	85aa                	mv	a1,a0
    80000f34:	00007517          	auipc	a0,0x7
    80000f38:	21450513          	addi	a0,a0,532 # 80008148 <digits+0x108>
    80000f3c:	fffff097          	auipc	ra,0xfffff
    80000f40:	63c080e7          	jalr	1596(ra) # 80000578 <printf>
  scheduler();        
    80000f44:	00001097          	auipc	ra,0x1
    80000f48:	3ec080e7          	jalr	1004(ra) # 80002330 <scheduler>
    consoleinit();
    80000f4c:	fffff097          	auipc	ra,0xfffff
    80000f50:	4f4080e7          	jalr	1268(ra) # 80000440 <consoleinit>
    printfinit();
    80000f54:	00000097          	auipc	ra,0x0
    80000f58:	804080e7          	jalr	-2044(ra) # 80000758 <printfinit>
    printf("\n");
    80000f5c:	00007517          	auipc	a0,0x7
    80000f60:	1fc50513          	addi	a0,a0,508 # 80008158 <digits+0x118>
    80000f64:	fffff097          	auipc	ra,0xfffff
    80000f68:	614080e7          	jalr	1556(ra) # 80000578 <printf>
    printf("\n");
    80000f6c:	00007517          	auipc	a0,0x7
    80000f70:	1ec50513          	addi	a0,a0,492 # 80008158 <digits+0x118>
    80000f74:	fffff097          	auipc	ra,0xfffff
    80000f78:	604080e7          	jalr	1540(ra) # 80000578 <printf>
    kinit();         // physical page allocator
    80000f7c:	00000097          	auipc	ra,0x0
    80000f80:	b1e080e7          	jalr	-1250(ra) # 80000a9a <kinit>
    kvminit();       // create kernel page table
    80000f84:	00000097          	auipc	ra,0x0
    80000f88:	340080e7          	jalr	832(ra) # 800012c4 <kvminit>
    kvminithart();   // turn on paging
    80000f8c:	00000097          	auipc	ra,0x0
    80000f90:	088080e7          	jalr	136(ra) # 80001014 <kvminithart>
    procinit();      // process table
    80000f94:	00001097          	auipc	ra,0x1
    80000f98:	a12080e7          	jalr	-1518(ra) # 800019a6 <procinit>
    trapinit();      // trap vectors
    80000f9c:	00002097          	auipc	ra,0x2
    80000fa0:	1fa080e7          	jalr	506(ra) # 80003196 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fa4:	00002097          	auipc	ra,0x2
    80000fa8:	21a080e7          	jalr	538(ra) # 800031be <trapinithart>
    plicinit();      // set up interrupt controller
    80000fac:	00006097          	auipc	ra,0x6
    80000fb0:	98e080e7          	jalr	-1650(ra) # 8000693a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fb4:	00006097          	auipc	ra,0x6
    80000fb8:	99c080e7          	jalr	-1636(ra) # 80006950 <plicinithart>
    binit();         // buffer cache
    80000fbc:	00003097          	auipc	ra,0x3
    80000fc0:	e9a080e7          	jalr	-358(ra) # 80003e56 <binit>
    iinit();         // inode cache
    80000fc4:	00003097          	auipc	ra,0x3
    80000fc8:	52c080e7          	jalr	1324(ra) # 800044f0 <iinit>
    fileinit();      // file table
    80000fcc:	00004097          	auipc	ra,0x4
    80000fd0:	4d8080e7          	jalr	1240(ra) # 800054a4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fd4:	00006097          	auipc	ra,0x6
    80000fd8:	a9e080e7          	jalr	-1378(ra) # 80006a72 <virtio_disk_init>
    printf("main before user init \n");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	594080e7          	jalr	1428(ra) # 80000578 <printf>
    userinit();      // first user process
    80000fec:	00001097          	auipc	ra,0x1
    80000ff0:	020080e7          	jalr	32(ra) # 8000200c <userinit>
    printf("main -after user init\n");
    80000ff4:	00007517          	auipc	a0,0x7
    80000ff8:	0f450513          	addi	a0,a0,244 # 800080e8 <digits+0xa8>
    80000ffc:	fffff097          	auipc	ra,0xfffff
    80001000:	57c080e7          	jalr	1404(ra) # 80000578 <printf>
    __sync_synchronize();
    80001004:	0ff0000f          	fence
    started = 1;
    80001008:	4785                	li	a5,1
    8000100a:	00008717          	auipc	a4,0x8
    8000100e:	00f72723          	sw	a5,14(a4) # 80009018 <started>
    80001012:	bf21                	j	80000f2a <main+0xa4>

0000000080001014 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001014:	1141                	addi	sp,sp,-16
    80001016:	e422                	sd	s0,8(sp)
    80001018:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000101a:	00008797          	auipc	a5,0x8
    8000101e:	0067b783          	ld	a5,6(a5) # 80009020 <kernel_pagetable>
    80001022:	83b1                	srli	a5,a5,0xc
    80001024:	577d                	li	a4,-1
    80001026:	177e                	slli	a4,a4,0x3f
    80001028:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000102a:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000102e:	12000073          	sfence.vma
  sfence_vma();
}
    80001032:	6422                	ld	s0,8(sp)
    80001034:	0141                	addi	sp,sp,16
    80001036:	8082                	ret

0000000080001038 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001038:	7139                	addi	sp,sp,-64
    8000103a:	fc06                	sd	ra,56(sp)
    8000103c:	f822                	sd	s0,48(sp)
    8000103e:	f426                	sd	s1,40(sp)
    80001040:	f04a                	sd	s2,32(sp)
    80001042:	ec4e                	sd	s3,24(sp)
    80001044:	e852                	sd	s4,16(sp)
    80001046:	e456                	sd	s5,8(sp)
    80001048:	e05a                	sd	s6,0(sp)
    8000104a:	0080                	addi	s0,sp,64
    8000104c:	84aa                	mv	s1,a0
    8000104e:	89ae                	mv	s3,a1
    80001050:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001052:	57fd                	li	a5,-1
    80001054:	83e9                	srli	a5,a5,0x1a
    80001056:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001058:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000105a:	04b7f263          	bgeu	a5,a1,8000109e <walk+0x66>
    panic("walk");
    8000105e:	00007517          	auipc	a0,0x7
    80001062:	10250513          	addi	a0,a0,258 # 80008160 <digits+0x120>
    80001066:	fffff097          	auipc	ra,0xfffff
    8000106a:	4c8080e7          	jalr	1224(ra) # 8000052e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000106e:	060a8663          	beqz	s5,800010da <walk+0xa2>
    80001072:	00000097          	auipc	ra,0x0
    80001076:	a64080e7          	jalr	-1436(ra) # 80000ad6 <kalloc>
    8000107a:	84aa                	mv	s1,a0
    8000107c:	c529                	beqz	a0,800010c6 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000107e:	6605                	lui	a2,0x1
    80001080:	4581                	li	a1,0
    80001082:	00000097          	auipc	ra,0x0
    80001086:	c56080e7          	jalr	-938(ra) # 80000cd8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000108a:	00c4d793          	srli	a5,s1,0xc
    8000108e:	07aa                	slli	a5,a5,0xa
    80001090:	0017e793          	ori	a5,a5,1
    80001094:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001098:	3a5d                	addiw	s4,s4,-9
    8000109a:	036a0063          	beq	s4,s6,800010ba <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000109e:	0149d933          	srl	s2,s3,s4
    800010a2:	1ff97913          	andi	s2,s2,511
    800010a6:	090e                	slli	s2,s2,0x3
    800010a8:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010aa:	00093483          	ld	s1,0(s2)
    800010ae:	0014f793          	andi	a5,s1,1
    800010b2:	dfd5                	beqz	a5,8000106e <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010b4:	80a9                	srli	s1,s1,0xa
    800010b6:	04b2                	slli	s1,s1,0xc
    800010b8:	b7c5                	j	80001098 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010ba:	00c9d513          	srli	a0,s3,0xc
    800010be:	1ff57513          	andi	a0,a0,511
    800010c2:	050e                	slli	a0,a0,0x3
    800010c4:	9526                	add	a0,a0,s1
}
    800010c6:	70e2                	ld	ra,56(sp)
    800010c8:	7442                	ld	s0,48(sp)
    800010ca:	74a2                	ld	s1,40(sp)
    800010cc:	7902                	ld	s2,32(sp)
    800010ce:	69e2                	ld	s3,24(sp)
    800010d0:	6a42                	ld	s4,16(sp)
    800010d2:	6aa2                	ld	s5,8(sp)
    800010d4:	6b02                	ld	s6,0(sp)
    800010d6:	6121                	addi	sp,sp,64
    800010d8:	8082                	ret
        return 0;
    800010da:	4501                	li	a0,0
    800010dc:	b7ed                	j	800010c6 <walk+0x8e>

00000000800010de <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010de:	57fd                	li	a5,-1
    800010e0:	83e9                	srli	a5,a5,0x1a
    800010e2:	00b7f463          	bgeu	a5,a1,800010ea <walkaddr+0xc>
    return 0;
    800010e6:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010e8:	8082                	ret
{
    800010ea:	1141                	addi	sp,sp,-16
    800010ec:	e406                	sd	ra,8(sp)
    800010ee:	e022                	sd	s0,0(sp)
    800010f0:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010f2:	4601                	li	a2,0
    800010f4:	00000097          	auipc	ra,0x0
    800010f8:	f44080e7          	jalr	-188(ra) # 80001038 <walk>
  if(pte == 0)
    800010fc:	c105                	beqz	a0,8000111c <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010fe:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001100:	0117f693          	andi	a3,a5,17
    80001104:	4745                	li	a4,17
    return 0;
    80001106:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001108:	00e68663          	beq	a3,a4,80001114 <walkaddr+0x36>
}
    8000110c:	60a2                	ld	ra,8(sp)
    8000110e:	6402                	ld	s0,0(sp)
    80001110:	0141                	addi	sp,sp,16
    80001112:	8082                	ret
  pa = PTE2PA(*pte);
    80001114:	00a7d513          	srli	a0,a5,0xa
    80001118:	0532                	slli	a0,a0,0xc
  return pa;
    8000111a:	bfcd                	j	8000110c <walkaddr+0x2e>
    return 0;
    8000111c:	4501                	li	a0,0
    8000111e:	b7fd                	j	8000110c <walkaddr+0x2e>

0000000080001120 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001120:	715d                	addi	sp,sp,-80
    80001122:	e486                	sd	ra,72(sp)
    80001124:	e0a2                	sd	s0,64(sp)
    80001126:	fc26                	sd	s1,56(sp)
    80001128:	f84a                	sd	s2,48(sp)
    8000112a:	f44e                	sd	s3,40(sp)
    8000112c:	f052                	sd	s4,32(sp)
    8000112e:	ec56                	sd	s5,24(sp)
    80001130:	e85a                	sd	s6,16(sp)
    80001132:	e45e                	sd	s7,8(sp)
    80001134:	0880                	addi	s0,sp,80
    80001136:	8aaa                	mv	s5,a0
    80001138:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    8000113a:	777d                	lui	a4,0xfffff
    8000113c:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001140:	167d                	addi	a2,a2,-1
    80001142:	00b609b3          	add	s3,a2,a1
    80001146:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000114a:	893e                	mv	s2,a5
    8000114c:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001150:	6b85                	lui	s7,0x1
    80001152:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001156:	4605                	li	a2,1
    80001158:	85ca                	mv	a1,s2
    8000115a:	8556                	mv	a0,s5
    8000115c:	00000097          	auipc	ra,0x0
    80001160:	edc080e7          	jalr	-292(ra) # 80001038 <walk>
    80001164:	c51d                	beqz	a0,80001192 <mappages+0x72>
    if(*pte & PTE_V)
    80001166:	611c                	ld	a5,0(a0)
    80001168:	8b85                	andi	a5,a5,1
    8000116a:	ef81                	bnez	a5,80001182 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000116c:	80b1                	srli	s1,s1,0xc
    8000116e:	04aa                	slli	s1,s1,0xa
    80001170:	0164e4b3          	or	s1,s1,s6
    80001174:	0014e493          	ori	s1,s1,1
    80001178:	e104                	sd	s1,0(a0)
    if(a == last)
    8000117a:	03390863          	beq	s2,s3,800011aa <mappages+0x8a>
    a += PGSIZE;
    8000117e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001180:	bfc9                	j	80001152 <mappages+0x32>
      panic("remap");
    80001182:	00007517          	auipc	a0,0x7
    80001186:	fe650513          	addi	a0,a0,-26 # 80008168 <digits+0x128>
    8000118a:	fffff097          	auipc	ra,0xfffff
    8000118e:	3a4080e7          	jalr	932(ra) # 8000052e <panic>
      return -1;
    80001192:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001194:	60a6                	ld	ra,72(sp)
    80001196:	6406                	ld	s0,64(sp)
    80001198:	74e2                	ld	s1,56(sp)
    8000119a:	7942                	ld	s2,48(sp)
    8000119c:	79a2                	ld	s3,40(sp)
    8000119e:	7a02                	ld	s4,32(sp)
    800011a0:	6ae2                	ld	s5,24(sp)
    800011a2:	6b42                	ld	s6,16(sp)
    800011a4:	6ba2                	ld	s7,8(sp)
    800011a6:	6161                	addi	sp,sp,80
    800011a8:	8082                	ret
  return 0;
    800011aa:	4501                	li	a0,0
    800011ac:	b7e5                	j	80001194 <mappages+0x74>

00000000800011ae <kvmmap>:
{
    800011ae:	1141                	addi	sp,sp,-16
    800011b0:	e406                	sd	ra,8(sp)
    800011b2:	e022                	sd	s0,0(sp)
    800011b4:	0800                	addi	s0,sp,16
    800011b6:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011b8:	86b2                	mv	a3,a2
    800011ba:	863e                	mv	a2,a5
    800011bc:	00000097          	auipc	ra,0x0
    800011c0:	f64080e7          	jalr	-156(ra) # 80001120 <mappages>
    800011c4:	e509                	bnez	a0,800011ce <kvmmap+0x20>
}
    800011c6:	60a2                	ld	ra,8(sp)
    800011c8:	6402                	ld	s0,0(sp)
    800011ca:	0141                	addi	sp,sp,16
    800011cc:	8082                	ret
    panic("kvmmap");
    800011ce:	00007517          	auipc	a0,0x7
    800011d2:	fa250513          	addi	a0,a0,-94 # 80008170 <digits+0x130>
    800011d6:	fffff097          	auipc	ra,0xfffff
    800011da:	358080e7          	jalr	856(ra) # 8000052e <panic>

00000000800011de <kvmmake>:
{
    800011de:	1101                	addi	sp,sp,-32
    800011e0:	ec06                	sd	ra,24(sp)
    800011e2:	e822                	sd	s0,16(sp)
    800011e4:	e426                	sd	s1,8(sp)
    800011e6:	e04a                	sd	s2,0(sp)
    800011e8:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011ea:	00000097          	auipc	ra,0x0
    800011ee:	8ec080e7          	jalr	-1812(ra) # 80000ad6 <kalloc>
    800011f2:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011f4:	6605                	lui	a2,0x1
    800011f6:	4581                	li	a1,0
    800011f8:	00000097          	auipc	ra,0x0
    800011fc:	ae0080e7          	jalr	-1312(ra) # 80000cd8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001200:	4719                	li	a4,6
    80001202:	6685                	lui	a3,0x1
    80001204:	10000637          	lui	a2,0x10000
    80001208:	100005b7          	lui	a1,0x10000
    8000120c:	8526                	mv	a0,s1
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	fa0080e7          	jalr	-96(ra) # 800011ae <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001216:	4719                	li	a4,6
    80001218:	6685                	lui	a3,0x1
    8000121a:	10001637          	lui	a2,0x10001
    8000121e:	100015b7          	lui	a1,0x10001
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f8a080e7          	jalr	-118(ra) # 800011ae <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000122c:	4719                	li	a4,6
    8000122e:	004006b7          	lui	a3,0x400
    80001232:	0c000637          	lui	a2,0xc000
    80001236:	0c0005b7          	lui	a1,0xc000
    8000123a:	8526                	mv	a0,s1
    8000123c:	00000097          	auipc	ra,0x0
    80001240:	f72080e7          	jalr	-142(ra) # 800011ae <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001244:	00007917          	auipc	s2,0x7
    80001248:	dbc90913          	addi	s2,s2,-580 # 80008000 <etext>
    8000124c:	4729                	li	a4,10
    8000124e:	80007697          	auipc	a3,0x80007
    80001252:	db268693          	addi	a3,a3,-590 # 8000 <_entry-0x7fff8000>
    80001256:	4605                	li	a2,1
    80001258:	067e                	slli	a2,a2,0x1f
    8000125a:	85b2                	mv	a1,a2
    8000125c:	8526                	mv	a0,s1
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	f50080e7          	jalr	-176(ra) # 800011ae <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001266:	4719                	li	a4,6
    80001268:	46c5                	li	a3,17
    8000126a:	06ee                	slli	a3,a3,0x1b
    8000126c:	412686b3          	sub	a3,a3,s2
    80001270:	864a                	mv	a2,s2
    80001272:	85ca                	mv	a1,s2
    80001274:	8526                	mv	a0,s1
    80001276:	00000097          	auipc	ra,0x0
    8000127a:	f38080e7          	jalr	-200(ra) # 800011ae <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000127e:	4729                	li	a4,10
    80001280:	6685                	lui	a3,0x1
    80001282:	00006617          	auipc	a2,0x6
    80001286:	d7e60613          	addi	a2,a2,-642 # 80007000 <_trampoline>
    8000128a:	040005b7          	lui	a1,0x4000
    8000128e:	15fd                	addi	a1,a1,-1
    80001290:	05b2                	slli	a1,a1,0xc
    80001292:	8526                	mv	a0,s1
    80001294:	00000097          	auipc	ra,0x0
    80001298:	f1a080e7          	jalr	-230(ra) # 800011ae <kvmmap>
  proc_mapstacks(kpgtbl);
    8000129c:	8526                	mv	a0,s1
    8000129e:	00000097          	auipc	ra,0x0
    800012a2:	620080e7          	jalr	1568(ra) # 800018be <proc_mapstacks>
  printf("10\n");
    800012a6:	00007517          	auipc	a0,0x7
    800012aa:	ed250513          	addi	a0,a0,-302 # 80008178 <digits+0x138>
    800012ae:	fffff097          	auipc	ra,0xfffff
    800012b2:	2ca080e7          	jalr	714(ra) # 80000578 <printf>
}
    800012b6:	8526                	mv	a0,s1
    800012b8:	60e2                	ld	ra,24(sp)
    800012ba:	6442                	ld	s0,16(sp)
    800012bc:	64a2                	ld	s1,8(sp)
    800012be:	6902                	ld	s2,0(sp)
    800012c0:	6105                	addi	sp,sp,32
    800012c2:	8082                	ret

00000000800012c4 <kvminit>:
{
    800012c4:	1141                	addi	sp,sp,-16
    800012c6:	e406                	sd	ra,8(sp)
    800012c8:	e022                	sd	s0,0(sp)
    800012ca:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012cc:	00000097          	auipc	ra,0x0
    800012d0:	f12080e7          	jalr	-238(ra) # 800011de <kvmmake>
    800012d4:	00008797          	auipc	a5,0x8
    800012d8:	d4a7b623          	sd	a0,-692(a5) # 80009020 <kernel_pagetable>
}
    800012dc:	60a2                	ld	ra,8(sp)
    800012de:	6402                	ld	s0,0(sp)
    800012e0:	0141                	addi	sp,sp,16
    800012e2:	8082                	ret

00000000800012e4 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012e4:	715d                	addi	sp,sp,-80
    800012e6:	e486                	sd	ra,72(sp)
    800012e8:	e0a2                	sd	s0,64(sp)
    800012ea:	fc26                	sd	s1,56(sp)
    800012ec:	f84a                	sd	s2,48(sp)
    800012ee:	f44e                	sd	s3,40(sp)
    800012f0:	f052                	sd	s4,32(sp)
    800012f2:	ec56                	sd	s5,24(sp)
    800012f4:	e85a                	sd	s6,16(sp)
    800012f6:	e45e                	sd	s7,8(sp)
    800012f8:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012fa:	03459793          	slli	a5,a1,0x34
    800012fe:	e795                	bnez	a5,8000132a <uvmunmap+0x46>
    80001300:	8a2a                	mv	s4,a0
    80001302:	892e                	mv	s2,a1
    80001304:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001306:	0632                	slli	a2,a2,0xc
    80001308:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130e:	6b05                	lui	s6,0x1
    80001310:	0735e263          	bltu	a1,s3,80001374 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001314:	60a6                	ld	ra,72(sp)
    80001316:	6406                	ld	s0,64(sp)
    80001318:	74e2                	ld	s1,56(sp)
    8000131a:	7942                	ld	s2,48(sp)
    8000131c:	79a2                	ld	s3,40(sp)
    8000131e:	7a02                	ld	s4,32(sp)
    80001320:	6ae2                	ld	s5,24(sp)
    80001322:	6b42                	ld	s6,16(sp)
    80001324:	6ba2                	ld	s7,8(sp)
    80001326:	6161                	addi	sp,sp,80
    80001328:	8082                	ret
    panic("uvmunmap: not aligned");
    8000132a:	00007517          	auipc	a0,0x7
    8000132e:	e5650513          	addi	a0,a0,-426 # 80008180 <digits+0x140>
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	1fc080e7          	jalr	508(ra) # 8000052e <panic>
      panic("uvmunmap: walk");
    8000133a:	00007517          	auipc	a0,0x7
    8000133e:	e5e50513          	addi	a0,a0,-418 # 80008198 <digits+0x158>
    80001342:	fffff097          	auipc	ra,0xfffff
    80001346:	1ec080e7          	jalr	492(ra) # 8000052e <panic>
      panic("uvmunmap: not mapped");
    8000134a:	00007517          	auipc	a0,0x7
    8000134e:	e5e50513          	addi	a0,a0,-418 # 800081a8 <digits+0x168>
    80001352:	fffff097          	auipc	ra,0xfffff
    80001356:	1dc080e7          	jalr	476(ra) # 8000052e <panic>
      panic("uvmunmap: not a leaf");
    8000135a:	00007517          	auipc	a0,0x7
    8000135e:	e6650513          	addi	a0,a0,-410 # 800081c0 <digits+0x180>
    80001362:	fffff097          	auipc	ra,0xfffff
    80001366:	1cc080e7          	jalr	460(ra) # 8000052e <panic>
    *pte = 0;
    8000136a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000136e:	995a                	add	s2,s2,s6
    80001370:	fb3972e3          	bgeu	s2,s3,80001314 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001374:	4601                	li	a2,0
    80001376:	85ca                	mv	a1,s2
    80001378:	8552                	mv	a0,s4
    8000137a:	00000097          	auipc	ra,0x0
    8000137e:	cbe080e7          	jalr	-834(ra) # 80001038 <walk>
    80001382:	84aa                	mv	s1,a0
    80001384:	d95d                	beqz	a0,8000133a <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001386:	6108                	ld	a0,0(a0)
    80001388:	00157793          	andi	a5,a0,1
    8000138c:	dfdd                	beqz	a5,8000134a <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000138e:	3ff57793          	andi	a5,a0,1023
    80001392:	fd7784e3          	beq	a5,s7,8000135a <uvmunmap+0x76>
    if(do_free){
    80001396:	fc0a8ae3          	beqz	s5,8000136a <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000139a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000139c:	0532                	slli	a0,a0,0xc
    8000139e:	fffff097          	auipc	ra,0xfffff
    800013a2:	63c080e7          	jalr	1596(ra) # 800009da <kfree>
    800013a6:	b7d1                	j	8000136a <uvmunmap+0x86>

00000000800013a8 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013a8:	1101                	addi	sp,sp,-32
    800013aa:	ec06                	sd	ra,24(sp)
    800013ac:	e822                	sd	s0,16(sp)
    800013ae:	e426                	sd	s1,8(sp)
    800013b0:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013b2:	fffff097          	auipc	ra,0xfffff
    800013b6:	724080e7          	jalr	1828(ra) # 80000ad6 <kalloc>
    800013ba:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013bc:	c519                	beqz	a0,800013ca <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013be:	6605                	lui	a2,0x1
    800013c0:	4581                	li	a1,0
    800013c2:	00000097          	auipc	ra,0x0
    800013c6:	916080e7          	jalr	-1770(ra) # 80000cd8 <memset>
  return pagetable;
}
    800013ca:	8526                	mv	a0,s1
    800013cc:	60e2                	ld	ra,24(sp)
    800013ce:	6442                	ld	s0,16(sp)
    800013d0:	64a2                	ld	s1,8(sp)
    800013d2:	6105                	addi	sp,sp,32
    800013d4:	8082                	ret

00000000800013d6 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800013d6:	7179                	addi	sp,sp,-48
    800013d8:	f406                	sd	ra,40(sp)
    800013da:	f022                	sd	s0,32(sp)
    800013dc:	ec26                	sd	s1,24(sp)
    800013de:	e84a                	sd	s2,16(sp)
    800013e0:	e44e                	sd	s3,8(sp)
    800013e2:	e052                	sd	s4,0(sp)
    800013e4:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013e6:	6785                	lui	a5,0x1
    800013e8:	06f67063          	bgeu	a2,a5,80001448 <uvminit+0x72>
    800013ec:	8a2a                	mv	s4,a0
    800013ee:	89ae                	mv	s3,a1
    800013f0:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013f2:	fffff097          	auipc	ra,0xfffff
    800013f6:	6e4080e7          	jalr	1764(ra) # 80000ad6 <kalloc>
    800013fa:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013fc:	6605                	lui	a2,0x1
    800013fe:	4581                	li	a1,0
    80001400:	00000097          	auipc	ra,0x0
    80001404:	8d8080e7          	jalr	-1832(ra) # 80000cd8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001408:	4779                	li	a4,30
    8000140a:	86ca                	mv	a3,s2
    8000140c:	6605                	lui	a2,0x1
    8000140e:	4581                	li	a1,0
    80001410:	8552                	mv	a0,s4
    80001412:	00000097          	auipc	ra,0x0
    80001416:	d0e080e7          	jalr	-754(ra) # 80001120 <mappages>
  printf("after mappages in uvminit\n");
    8000141a:	00007517          	auipc	a0,0x7
    8000141e:	dde50513          	addi	a0,a0,-546 # 800081f8 <digits+0x1b8>
    80001422:	fffff097          	auipc	ra,0xfffff
    80001426:	156080e7          	jalr	342(ra) # 80000578 <printf>
  memmove(mem, src, sz);
    8000142a:	8626                	mv	a2,s1
    8000142c:	85ce                	mv	a1,s3
    8000142e:	854a                	mv	a0,s2
    80001430:	00000097          	auipc	ra,0x0
    80001434:	904080e7          	jalr	-1788(ra) # 80000d34 <memmove>
}
    80001438:	70a2                	ld	ra,40(sp)
    8000143a:	7402                	ld	s0,32(sp)
    8000143c:	64e2                	ld	s1,24(sp)
    8000143e:	6942                	ld	s2,16(sp)
    80001440:	69a2                	ld	s3,8(sp)
    80001442:	6a02                	ld	s4,0(sp)
    80001444:	6145                	addi	sp,sp,48
    80001446:	8082                	ret
    panic("inituvm: more than a page");
    80001448:	00007517          	auipc	a0,0x7
    8000144c:	d9050513          	addi	a0,a0,-624 # 800081d8 <digits+0x198>
    80001450:	fffff097          	auipc	ra,0xfffff
    80001454:	0de080e7          	jalr	222(ra) # 8000052e <panic>

0000000080001458 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001458:	1101                	addi	sp,sp,-32
    8000145a:	ec06                	sd	ra,24(sp)
    8000145c:	e822                	sd	s0,16(sp)
    8000145e:	e426                	sd	s1,8(sp)
    80001460:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001462:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001464:	00b67d63          	bgeu	a2,a1,8000147e <uvmdealloc+0x26>
    80001468:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000146a:	6785                	lui	a5,0x1
    8000146c:	17fd                	addi	a5,a5,-1
    8000146e:	00f60733          	add	a4,a2,a5
    80001472:	767d                	lui	a2,0xfffff
    80001474:	8f71                	and	a4,a4,a2
    80001476:	97ae                	add	a5,a5,a1
    80001478:	8ff1                	and	a5,a5,a2
    8000147a:	00f76863          	bltu	a4,a5,8000148a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000147e:	8526                	mv	a0,s1
    80001480:	60e2                	ld	ra,24(sp)
    80001482:	6442                	ld	s0,16(sp)
    80001484:	64a2                	ld	s1,8(sp)
    80001486:	6105                	addi	sp,sp,32
    80001488:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000148a:	8f99                	sub	a5,a5,a4
    8000148c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000148e:	4685                	li	a3,1
    80001490:	0007861b          	sext.w	a2,a5
    80001494:	85ba                	mv	a1,a4
    80001496:	00000097          	auipc	ra,0x0
    8000149a:	e4e080e7          	jalr	-434(ra) # 800012e4 <uvmunmap>
    8000149e:	b7c5                	j	8000147e <uvmdealloc+0x26>

00000000800014a0 <uvmalloc>:
  if(newsz < oldsz)
    800014a0:	0ab66163          	bltu	a2,a1,80001542 <uvmalloc+0xa2>
{
    800014a4:	7139                	addi	sp,sp,-64
    800014a6:	fc06                	sd	ra,56(sp)
    800014a8:	f822                	sd	s0,48(sp)
    800014aa:	f426                	sd	s1,40(sp)
    800014ac:	f04a                	sd	s2,32(sp)
    800014ae:	ec4e                	sd	s3,24(sp)
    800014b0:	e852                	sd	s4,16(sp)
    800014b2:	e456                	sd	s5,8(sp)
    800014b4:	0080                	addi	s0,sp,64
    800014b6:	8aaa                	mv	s5,a0
    800014b8:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014ba:	6985                	lui	s3,0x1
    800014bc:	19fd                	addi	s3,s3,-1
    800014be:	95ce                	add	a1,a1,s3
    800014c0:	79fd                	lui	s3,0xfffff
    800014c2:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014c6:	08c9f063          	bgeu	s3,a2,80001546 <uvmalloc+0xa6>
    800014ca:	894e                	mv	s2,s3
    mem = kalloc();
    800014cc:	fffff097          	auipc	ra,0xfffff
    800014d0:	60a080e7          	jalr	1546(ra) # 80000ad6 <kalloc>
    800014d4:	84aa                	mv	s1,a0
    if(mem == 0){
    800014d6:	c51d                	beqz	a0,80001504 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800014d8:	6605                	lui	a2,0x1
    800014da:	4581                	li	a1,0
    800014dc:	fffff097          	auipc	ra,0xfffff
    800014e0:	7fc080e7          	jalr	2044(ra) # 80000cd8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014e4:	4779                	li	a4,30
    800014e6:	86a6                	mv	a3,s1
    800014e8:	6605                	lui	a2,0x1
    800014ea:	85ca                	mv	a1,s2
    800014ec:	8556                	mv	a0,s5
    800014ee:	00000097          	auipc	ra,0x0
    800014f2:	c32080e7          	jalr	-974(ra) # 80001120 <mappages>
    800014f6:	e905                	bnez	a0,80001526 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014f8:	6785                	lui	a5,0x1
    800014fa:	993e                	add	s2,s2,a5
    800014fc:	fd4968e3          	bltu	s2,s4,800014cc <uvmalloc+0x2c>
  return newsz;
    80001500:	8552                	mv	a0,s4
    80001502:	a809                	j	80001514 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001504:	864e                	mv	a2,s3
    80001506:	85ca                	mv	a1,s2
    80001508:	8556                	mv	a0,s5
    8000150a:	00000097          	auipc	ra,0x0
    8000150e:	f4e080e7          	jalr	-178(ra) # 80001458 <uvmdealloc>
      return 0;
    80001512:	4501                	li	a0,0
}
    80001514:	70e2                	ld	ra,56(sp)
    80001516:	7442                	ld	s0,48(sp)
    80001518:	74a2                	ld	s1,40(sp)
    8000151a:	7902                	ld	s2,32(sp)
    8000151c:	69e2                	ld	s3,24(sp)
    8000151e:	6a42                	ld	s4,16(sp)
    80001520:	6aa2                	ld	s5,8(sp)
    80001522:	6121                	addi	sp,sp,64
    80001524:	8082                	ret
      kfree(mem);
    80001526:	8526                	mv	a0,s1
    80001528:	fffff097          	auipc	ra,0xfffff
    8000152c:	4b2080e7          	jalr	1202(ra) # 800009da <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001530:	864e                	mv	a2,s3
    80001532:	85ca                	mv	a1,s2
    80001534:	8556                	mv	a0,s5
    80001536:	00000097          	auipc	ra,0x0
    8000153a:	f22080e7          	jalr	-222(ra) # 80001458 <uvmdealloc>
      return 0;
    8000153e:	4501                	li	a0,0
    80001540:	bfd1                	j	80001514 <uvmalloc+0x74>
    return oldsz;
    80001542:	852e                	mv	a0,a1
}
    80001544:	8082                	ret
  return newsz;
    80001546:	8532                	mv	a0,a2
    80001548:	b7f1                	j	80001514 <uvmalloc+0x74>

000000008000154a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000154a:	7179                	addi	sp,sp,-48
    8000154c:	f406                	sd	ra,40(sp)
    8000154e:	f022                	sd	s0,32(sp)
    80001550:	ec26                	sd	s1,24(sp)
    80001552:	e84a                	sd	s2,16(sp)
    80001554:	e44e                	sd	s3,8(sp)
    80001556:	e052                	sd	s4,0(sp)
    80001558:	1800                	addi	s0,sp,48
    8000155a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000155c:	84aa                	mv	s1,a0
    8000155e:	6905                	lui	s2,0x1
    80001560:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001562:	4985                	li	s3,1
    80001564:	a821                	j	8000157c <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001566:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001568:	0532                	slli	a0,a0,0xc
    8000156a:	00000097          	auipc	ra,0x0
    8000156e:	fe0080e7          	jalr	-32(ra) # 8000154a <freewalk>
      pagetable[i] = 0;
    80001572:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001576:	04a1                	addi	s1,s1,8
    80001578:	03248163          	beq	s1,s2,8000159a <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000157c:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000157e:	00f57793          	andi	a5,a0,15
    80001582:	ff3782e3          	beq	a5,s3,80001566 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001586:	8905                	andi	a0,a0,1
    80001588:	d57d                	beqz	a0,80001576 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000158a:	00007517          	auipc	a0,0x7
    8000158e:	c8e50513          	addi	a0,a0,-882 # 80008218 <digits+0x1d8>
    80001592:	fffff097          	auipc	ra,0xfffff
    80001596:	f9c080e7          	jalr	-100(ra) # 8000052e <panic>
    }
  }
  kfree((void*)pagetable);
    8000159a:	8552                	mv	a0,s4
    8000159c:	fffff097          	auipc	ra,0xfffff
    800015a0:	43e080e7          	jalr	1086(ra) # 800009da <kfree>
}
    800015a4:	70a2                	ld	ra,40(sp)
    800015a6:	7402                	ld	s0,32(sp)
    800015a8:	64e2                	ld	s1,24(sp)
    800015aa:	6942                	ld	s2,16(sp)
    800015ac:	69a2                	ld	s3,8(sp)
    800015ae:	6a02                	ld	s4,0(sp)
    800015b0:	6145                	addi	sp,sp,48
    800015b2:	8082                	ret

00000000800015b4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015b4:	1101                	addi	sp,sp,-32
    800015b6:	ec06                	sd	ra,24(sp)
    800015b8:	e822                	sd	s0,16(sp)
    800015ba:	e426                	sd	s1,8(sp)
    800015bc:	1000                	addi	s0,sp,32
    800015be:	84aa                	mv	s1,a0
  if(sz > 0)
    800015c0:	e999                	bnez	a1,800015d6 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015c2:	8526                	mv	a0,s1
    800015c4:	00000097          	auipc	ra,0x0
    800015c8:	f86080e7          	jalr	-122(ra) # 8000154a <freewalk>
}
    800015cc:	60e2                	ld	ra,24(sp)
    800015ce:	6442                	ld	s0,16(sp)
    800015d0:	64a2                	ld	s1,8(sp)
    800015d2:	6105                	addi	sp,sp,32
    800015d4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015d6:	6605                	lui	a2,0x1
    800015d8:	167d                	addi	a2,a2,-1
    800015da:	962e                	add	a2,a2,a1
    800015dc:	4685                	li	a3,1
    800015de:	8231                	srli	a2,a2,0xc
    800015e0:	4581                	li	a1,0
    800015e2:	00000097          	auipc	ra,0x0
    800015e6:	d02080e7          	jalr	-766(ra) # 800012e4 <uvmunmap>
    800015ea:	bfe1                	j	800015c2 <uvmfree+0xe>

00000000800015ec <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015ec:	c679                	beqz	a2,800016ba <uvmcopy+0xce>
{
    800015ee:	715d                	addi	sp,sp,-80
    800015f0:	e486                	sd	ra,72(sp)
    800015f2:	e0a2                	sd	s0,64(sp)
    800015f4:	fc26                	sd	s1,56(sp)
    800015f6:	f84a                	sd	s2,48(sp)
    800015f8:	f44e                	sd	s3,40(sp)
    800015fa:	f052                	sd	s4,32(sp)
    800015fc:	ec56                	sd	s5,24(sp)
    800015fe:	e85a                	sd	s6,16(sp)
    80001600:	e45e                	sd	s7,8(sp)
    80001602:	0880                	addi	s0,sp,80
    80001604:	8b2a                	mv	s6,a0
    80001606:	8aae                	mv	s5,a1
    80001608:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000160a:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000160c:	4601                	li	a2,0
    8000160e:	85ce                	mv	a1,s3
    80001610:	855a                	mv	a0,s6
    80001612:	00000097          	auipc	ra,0x0
    80001616:	a26080e7          	jalr	-1498(ra) # 80001038 <walk>
    8000161a:	c531                	beqz	a0,80001666 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000161c:	6118                	ld	a4,0(a0)
    8000161e:	00177793          	andi	a5,a4,1
    80001622:	cbb1                	beqz	a5,80001676 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001624:	00a75593          	srli	a1,a4,0xa
    80001628:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000162c:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001630:	fffff097          	auipc	ra,0xfffff
    80001634:	4a6080e7          	jalr	1190(ra) # 80000ad6 <kalloc>
    80001638:	892a                	mv	s2,a0
    8000163a:	c939                	beqz	a0,80001690 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000163c:	6605                	lui	a2,0x1
    8000163e:	85de                	mv	a1,s7
    80001640:	fffff097          	auipc	ra,0xfffff
    80001644:	6f4080e7          	jalr	1780(ra) # 80000d34 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001648:	8726                	mv	a4,s1
    8000164a:	86ca                	mv	a3,s2
    8000164c:	6605                	lui	a2,0x1
    8000164e:	85ce                	mv	a1,s3
    80001650:	8556                	mv	a0,s5
    80001652:	00000097          	auipc	ra,0x0
    80001656:	ace080e7          	jalr	-1330(ra) # 80001120 <mappages>
    8000165a:	e515                	bnez	a0,80001686 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000165c:	6785                	lui	a5,0x1
    8000165e:	99be                	add	s3,s3,a5
    80001660:	fb49e6e3          	bltu	s3,s4,8000160c <uvmcopy+0x20>
    80001664:	a081                	j	800016a4 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001666:	00007517          	auipc	a0,0x7
    8000166a:	bc250513          	addi	a0,a0,-1086 # 80008228 <digits+0x1e8>
    8000166e:	fffff097          	auipc	ra,0xfffff
    80001672:	ec0080e7          	jalr	-320(ra) # 8000052e <panic>
      panic("uvmcopy: page not present");
    80001676:	00007517          	auipc	a0,0x7
    8000167a:	bd250513          	addi	a0,a0,-1070 # 80008248 <digits+0x208>
    8000167e:	fffff097          	auipc	ra,0xfffff
    80001682:	eb0080e7          	jalr	-336(ra) # 8000052e <panic>
      kfree(mem);
    80001686:	854a                	mv	a0,s2
    80001688:	fffff097          	auipc	ra,0xfffff
    8000168c:	352080e7          	jalr	850(ra) # 800009da <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001690:	4685                	li	a3,1
    80001692:	00c9d613          	srli	a2,s3,0xc
    80001696:	4581                	li	a1,0
    80001698:	8556                	mv	a0,s5
    8000169a:	00000097          	auipc	ra,0x0
    8000169e:	c4a080e7          	jalr	-950(ra) # 800012e4 <uvmunmap>
  return -1;
    800016a2:	557d                	li	a0,-1
}
    800016a4:	60a6                	ld	ra,72(sp)
    800016a6:	6406                	ld	s0,64(sp)
    800016a8:	74e2                	ld	s1,56(sp)
    800016aa:	7942                	ld	s2,48(sp)
    800016ac:	79a2                	ld	s3,40(sp)
    800016ae:	7a02                	ld	s4,32(sp)
    800016b0:	6ae2                	ld	s5,24(sp)
    800016b2:	6b42                	ld	s6,16(sp)
    800016b4:	6ba2                	ld	s7,8(sp)
    800016b6:	6161                	addi	sp,sp,80
    800016b8:	8082                	ret
  return 0;
    800016ba:	4501                	li	a0,0
}
    800016bc:	8082                	ret

00000000800016be <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016be:	1141                	addi	sp,sp,-16
    800016c0:	e406                	sd	ra,8(sp)
    800016c2:	e022                	sd	s0,0(sp)
    800016c4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016c6:	4601                	li	a2,0
    800016c8:	00000097          	auipc	ra,0x0
    800016cc:	970080e7          	jalr	-1680(ra) # 80001038 <walk>
  if(pte == 0)
    800016d0:	c901                	beqz	a0,800016e0 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016d2:	611c                	ld	a5,0(a0)
    800016d4:	9bbd                	andi	a5,a5,-17
    800016d6:	e11c                	sd	a5,0(a0)
}
    800016d8:	60a2                	ld	ra,8(sp)
    800016da:	6402                	ld	s0,0(sp)
    800016dc:	0141                	addi	sp,sp,16
    800016de:	8082                	ret
    panic("uvmclear");
    800016e0:	00007517          	auipc	a0,0x7
    800016e4:	b8850513          	addi	a0,a0,-1144 # 80008268 <digits+0x228>
    800016e8:	fffff097          	auipc	ra,0xfffff
    800016ec:	e46080e7          	jalr	-442(ra) # 8000052e <panic>

00000000800016f0 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f0:	c6bd                	beqz	a3,8000175e <copyout+0x6e>
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
    8000170c:	8c2e                	mv	s8,a1
    8000170e:	8a32                	mv	s4,a2
    80001710:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001712:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001714:	6a85                	lui	s5,0x1
    80001716:	a015                	j	8000173a <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001718:	9562                	add	a0,a0,s8
    8000171a:	0004861b          	sext.w	a2,s1
    8000171e:	85d2                	mv	a1,s4
    80001720:	41250533          	sub	a0,a0,s2
    80001724:	fffff097          	auipc	ra,0xfffff
    80001728:	610080e7          	jalr	1552(ra) # 80000d34 <memmove>

    len -= n;
    8000172c:	409989b3          	sub	s3,s3,s1
    src += n;
    80001730:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001732:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001736:	02098263          	beqz	s3,8000175a <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000173a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000173e:	85ca                	mv	a1,s2
    80001740:	855a                	mv	a0,s6
    80001742:	00000097          	auipc	ra,0x0
    80001746:	99c080e7          	jalr	-1636(ra) # 800010de <walkaddr>
    if(pa0 == 0)
    8000174a:	cd01                	beqz	a0,80001762 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000174c:	418904b3          	sub	s1,s2,s8
    80001750:	94d6                	add	s1,s1,s5
    if(n > len)
    80001752:	fc99f3e3          	bgeu	s3,s1,80001718 <copyout+0x28>
    80001756:	84ce                	mv	s1,s3
    80001758:	b7c1                	j	80001718 <copyout+0x28>
  }
  return 0;
    8000175a:	4501                	li	a0,0
    8000175c:	a021                	j	80001764 <copyout+0x74>
    8000175e:	4501                	li	a0,0
}
    80001760:	8082                	ret
      return -1;
    80001762:	557d                	li	a0,-1
}
    80001764:	60a6                	ld	ra,72(sp)
    80001766:	6406                	ld	s0,64(sp)
    80001768:	74e2                	ld	s1,56(sp)
    8000176a:	7942                	ld	s2,48(sp)
    8000176c:	79a2                	ld	s3,40(sp)
    8000176e:	7a02                	ld	s4,32(sp)
    80001770:	6ae2                	ld	s5,24(sp)
    80001772:	6b42                	ld	s6,16(sp)
    80001774:	6ba2                	ld	s7,8(sp)
    80001776:	6c02                	ld	s8,0(sp)
    80001778:	6161                	addi	sp,sp,80
    8000177a:	8082                	ret

000000008000177c <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000177c:	caa5                	beqz	a3,800017ec <copyin+0x70>
{
    8000177e:	715d                	addi	sp,sp,-80
    80001780:	e486                	sd	ra,72(sp)
    80001782:	e0a2                	sd	s0,64(sp)
    80001784:	fc26                	sd	s1,56(sp)
    80001786:	f84a                	sd	s2,48(sp)
    80001788:	f44e                	sd	s3,40(sp)
    8000178a:	f052                	sd	s4,32(sp)
    8000178c:	ec56                	sd	s5,24(sp)
    8000178e:	e85a                	sd	s6,16(sp)
    80001790:	e45e                	sd	s7,8(sp)
    80001792:	e062                	sd	s8,0(sp)
    80001794:	0880                	addi	s0,sp,80
    80001796:	8b2a                	mv	s6,a0
    80001798:	8a2e                	mv	s4,a1
    8000179a:	8c32                	mv	s8,a2
    8000179c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000179e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a0:	6a85                	lui	s5,0x1
    800017a2:	a01d                	j	800017c8 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017a4:	018505b3          	add	a1,a0,s8
    800017a8:	0004861b          	sext.w	a2,s1
    800017ac:	412585b3          	sub	a1,a1,s2
    800017b0:	8552                	mv	a0,s4
    800017b2:	fffff097          	auipc	ra,0xfffff
    800017b6:	582080e7          	jalr	1410(ra) # 80000d34 <memmove>

    len -= n;
    800017ba:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017be:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017c0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017c4:	02098263          	beqz	s3,800017e8 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017c8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017cc:	85ca                	mv	a1,s2
    800017ce:	855a                	mv	a0,s6
    800017d0:	00000097          	auipc	ra,0x0
    800017d4:	90e080e7          	jalr	-1778(ra) # 800010de <walkaddr>
    if(pa0 == 0)
    800017d8:	cd01                	beqz	a0,800017f0 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017da:	418904b3          	sub	s1,s2,s8
    800017de:	94d6                	add	s1,s1,s5
    if(n > len)
    800017e0:	fc99f2e3          	bgeu	s3,s1,800017a4 <copyin+0x28>
    800017e4:	84ce                	mv	s1,s3
    800017e6:	bf7d                	j	800017a4 <copyin+0x28>
  }
  return 0;
    800017e8:	4501                	li	a0,0
    800017ea:	a021                	j	800017f2 <copyin+0x76>
    800017ec:	4501                	li	a0,0
}
    800017ee:	8082                	ret
      return -1;
    800017f0:	557d                	li	a0,-1
}
    800017f2:	60a6                	ld	ra,72(sp)
    800017f4:	6406                	ld	s0,64(sp)
    800017f6:	74e2                	ld	s1,56(sp)
    800017f8:	7942                	ld	s2,48(sp)
    800017fa:	79a2                	ld	s3,40(sp)
    800017fc:	7a02                	ld	s4,32(sp)
    800017fe:	6ae2                	ld	s5,24(sp)
    80001800:	6b42                	ld	s6,16(sp)
    80001802:	6ba2                	ld	s7,8(sp)
    80001804:	6c02                	ld	s8,0(sp)
    80001806:	6161                	addi	sp,sp,80
    80001808:	8082                	ret

000000008000180a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000180a:	c6c5                	beqz	a3,800018b2 <copyinstr+0xa8>
{
    8000180c:	715d                	addi	sp,sp,-80
    8000180e:	e486                	sd	ra,72(sp)
    80001810:	e0a2                	sd	s0,64(sp)
    80001812:	fc26                	sd	s1,56(sp)
    80001814:	f84a                	sd	s2,48(sp)
    80001816:	f44e                	sd	s3,40(sp)
    80001818:	f052                	sd	s4,32(sp)
    8000181a:	ec56                	sd	s5,24(sp)
    8000181c:	e85a                	sd	s6,16(sp)
    8000181e:	e45e                	sd	s7,8(sp)
    80001820:	0880                	addi	s0,sp,80
    80001822:	8a2a                	mv	s4,a0
    80001824:	8b2e                	mv	s6,a1
    80001826:	8bb2                	mv	s7,a2
    80001828:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000182a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000182c:	6985                	lui	s3,0x1
    8000182e:	a035                	j	8000185a <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001830:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001834:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001836:	0017b793          	seqz	a5,a5
    8000183a:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000183e:	60a6                	ld	ra,72(sp)
    80001840:	6406                	ld	s0,64(sp)
    80001842:	74e2                	ld	s1,56(sp)
    80001844:	7942                	ld	s2,48(sp)
    80001846:	79a2                	ld	s3,40(sp)
    80001848:	7a02                	ld	s4,32(sp)
    8000184a:	6ae2                	ld	s5,24(sp)
    8000184c:	6b42                	ld	s6,16(sp)
    8000184e:	6ba2                	ld	s7,8(sp)
    80001850:	6161                	addi	sp,sp,80
    80001852:	8082                	ret
    srcva = va0 + PGSIZE;
    80001854:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001858:	c8a9                	beqz	s1,800018aa <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    8000185a:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000185e:	85ca                	mv	a1,s2
    80001860:	8552                	mv	a0,s4
    80001862:	00000097          	auipc	ra,0x0
    80001866:	87c080e7          	jalr	-1924(ra) # 800010de <walkaddr>
    if(pa0 == 0)
    8000186a:	c131                	beqz	a0,800018ae <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    8000186c:	41790833          	sub	a6,s2,s7
    80001870:	984e                	add	a6,a6,s3
    if(n > max)
    80001872:	0104f363          	bgeu	s1,a6,80001878 <copyinstr+0x6e>
    80001876:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001878:	955e                	add	a0,a0,s7
    8000187a:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000187e:	fc080be3          	beqz	a6,80001854 <copyinstr+0x4a>
    80001882:	985a                	add	a6,a6,s6
    80001884:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001886:	41650633          	sub	a2,a0,s6
    8000188a:	14fd                	addi	s1,s1,-1
    8000188c:	9b26                	add	s6,s6,s1
    8000188e:	00f60733          	add	a4,a2,a5
    80001892:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffbe000>
    80001896:	df49                	beqz	a4,80001830 <copyinstr+0x26>
        *dst = *p;
    80001898:	00e78023          	sb	a4,0(a5)
      --max;
    8000189c:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800018a0:	0785                	addi	a5,a5,1
    while(n > 0){
    800018a2:	ff0796e3          	bne	a5,a6,8000188e <copyinstr+0x84>
      dst++;
    800018a6:	8b42                	mv	s6,a6
    800018a8:	b775                	j	80001854 <copyinstr+0x4a>
    800018aa:	4781                	li	a5,0
    800018ac:	b769                	j	80001836 <copyinstr+0x2c>
      return -1;
    800018ae:	557d                	li	a0,-1
    800018b0:	b779                	j	8000183e <copyinstr+0x34>
  int got_null = 0;
    800018b2:	4781                	li	a5,0
  if(got_null){
    800018b4:	0017b793          	seqz	a5,a5
    800018b8:	40f00533          	neg	a0,a5
}
    800018bc:	8082                	ret

00000000800018be <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    800018be:	711d                	addi	sp,sp,-96
    800018c0:	ec86                	sd	ra,88(sp)
    800018c2:	e8a2                	sd	s0,80(sp)
    800018c4:	e4a6                	sd	s1,72(sp)
    800018c6:	e0ca                	sd	s2,64(sp)
    800018c8:	fc4e                	sd	s3,56(sp)
    800018ca:	f852                	sd	s4,48(sp)
    800018cc:	f456                	sd	s5,40(sp)
    800018ce:	f05a                	sd	s6,32(sp)
    800018d0:	ec5e                	sd	s7,24(sp)
    800018d2:	e862                	sd	s8,16(sp)
    800018d4:	e466                	sd	s9,8(sp)
    800018d6:	e06a                	sd	s10,0(sp)
    800018d8:	1080                	addi	s0,sp,96
    800018da:	8b2a                	mv	s6,a0
  struct proc *p;
  struct kthread *t;

  for(p = proc; p < &proc[NPROC]; p++) {
    800018dc:	00010997          	auipc	s3,0x10
    800018e0:	69498993          	addi	s3,s3,1684 # 80011f70 <proc+0x848>
    800018e4:	00032d17          	auipc	s10,0x32
    800018e8:	88cd0d13          	addi	s10,s10,-1908 # 80033170 <bcache+0x830>
    int proc_index= (int)(p-proc);
    800018ec:	7c7d                	lui	s8,0xfffff
    800018ee:	7b8c0c13          	addi	s8,s8,1976 # fffffffffffff7b8 <end+0xffffffff7ffbe7b8>
    800018f2:	00006c97          	auipc	s9,0x6
    800018f6:	70ecbc83          	ld	s9,1806(s9) # 80008000 <etext>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      int thread_index = (int)(t-p->kthreads);
    800018fa:	00006b97          	auipc	s7,0x6
    800018fe:	70eb8b93          	addi	s7,s7,1806 # 80008008 <etext+0x8>
      uint64 va = KSTACK( proc_index * NTHREAD + thread_index);
    80001902:	04000ab7          	lui	s5,0x4000
    80001906:	1afd                	addi	s5,s5,-1
    80001908:	0ab2                	slli	s5,s5,0xc
    8000190a:	a839                	j	80001928 <proc_mapstacks+0x6a>
        panic("kalloc");
    8000190c:	00007517          	auipc	a0,0x7
    80001910:	96c50513          	addi	a0,a0,-1684 # 80008278 <digits+0x238>
    80001914:	fffff097          	auipc	ra,0xfffff
    80001918:	c1a080e7          	jalr	-998(ra) # 8000052e <panic>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000191c:	6785                	lui	a5,0x1
    8000191e:	84878793          	addi	a5,a5,-1976 # 848 <_entry-0x7ffff7b8>
    80001922:	99be                	add	s3,s3,a5
    80001924:	07a98363          	beq	s3,s10,8000198a <proc_mapstacks+0xcc>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001928:	a4098a13          	addi	s4,s3,-1472
    int proc_index= (int)(p-proc);
    8000192c:	01898933          	add	s2,s3,s8
    80001930:	00010797          	auipc	a5,0x10
    80001934:	df878793          	addi	a5,a5,-520 # 80011728 <proc>
    80001938:	40f90933          	sub	s2,s2,a5
    8000193c:	40395913          	srai	s2,s2,0x3
    80001940:	03990933          	mul	s2,s2,s9
    80001944:	0039191b          	slliw	s2,s2,0x3
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001948:	84d2                	mv	s1,s4
      char *pa = kalloc();
    8000194a:	fffff097          	auipc	ra,0xfffff
    8000194e:	18c080e7          	jalr	396(ra) # 80000ad6 <kalloc>
    80001952:	862a                	mv	a2,a0
      if(pa == 0)
    80001954:	dd45                	beqz	a0,8000190c <proc_mapstacks+0x4e>
      int thread_index = (int)(t-p->kthreads);
    80001956:	414485b3          	sub	a1,s1,s4
    8000195a:	858d                	srai	a1,a1,0x3
    8000195c:	000bb783          	ld	a5,0(s7)
    80001960:	02f585b3          	mul	a1,a1,a5
      uint64 va = KSTACK( proc_index * NTHREAD + thread_index);
    80001964:	012585bb          	addw	a1,a1,s2
    80001968:	2585                	addiw	a1,a1,1
    8000196a:	00d5959b          	slliw	a1,a1,0xd
      kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000196e:	4719                	li	a4,6
    80001970:	6685                	lui	a3,0x1
    80001972:	40ba85b3          	sub	a1,s5,a1
    80001976:	855a                	mv	a0,s6
    80001978:	00000097          	auipc	ra,0x0
    8000197c:	836080e7          	jalr	-1994(ra) # 800011ae <kvmmap>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001980:	0b848493          	addi	s1,s1,184
    80001984:	fd3493e3          	bne	s1,s3,8000194a <proc_mapstacks+0x8c>
    80001988:	bf51                	j	8000191c <proc_mapstacks+0x5e>
    }
  }
}
    8000198a:	60e6                	ld	ra,88(sp)
    8000198c:	6446                	ld	s0,80(sp)
    8000198e:	64a6                	ld	s1,72(sp)
    80001990:	6906                	ld	s2,64(sp)
    80001992:	79e2                	ld	s3,56(sp)
    80001994:	7a42                	ld	s4,48(sp)
    80001996:	7aa2                	ld	s5,40(sp)
    80001998:	7b02                	ld	s6,32(sp)
    8000199a:	6be2                	ld	s7,24(sp)
    8000199c:	6c42                	ld	s8,16(sp)
    8000199e:	6ca2                	ld	s9,8(sp)
    800019a0:	6d02                	ld	s10,0(sp)
    800019a2:	6125                	addi	sp,sp,96
    800019a4:	8082                	ret

00000000800019a6 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800019a6:	7159                	addi	sp,sp,-112
    800019a8:	f486                	sd	ra,104(sp)
    800019aa:	f0a2                	sd	s0,96(sp)
    800019ac:	eca6                	sd	s1,88(sp)
    800019ae:	e8ca                	sd	s2,80(sp)
    800019b0:	e4ce                	sd	s3,72(sp)
    800019b2:	e0d2                	sd	s4,64(sp)
    800019b4:	fc56                	sd	s5,56(sp)
    800019b6:	f85a                	sd	s6,48(sp)
    800019b8:	f45e                	sd	s7,40(sp)
    800019ba:	f062                	sd	s8,32(sp)
    800019bc:	ec66                	sd	s9,24(sp)
    800019be:	e86a                	sd	s10,16(sp)
    800019c0:	e46e                	sd	s11,8(sp)
    800019c2:	1880                	addi	s0,sp,112
  struct proc *p;
  struct kthread *t;
  
  initlock(&pid_lock, "nextpid");
    800019c4:	00007597          	auipc	a1,0x7
    800019c8:	8bc58593          	addi	a1,a1,-1860 # 80008280 <digits+0x240>
    800019cc:	00010517          	auipc	a0,0x10
    800019d0:	8d450513          	addi	a0,a0,-1836 # 800112a0 <pid_lock>
    800019d4:	fffff097          	auipc	ra,0xfffff
    800019d8:	162080e7          	jalr	354(ra) # 80000b36 <initlock>
  initlock(&tid_lock,"nexttid");
    800019dc:	00007597          	auipc	a1,0x7
    800019e0:	8ac58593          	addi	a1,a1,-1876 # 80008288 <digits+0x248>
    800019e4:	00010517          	auipc	a0,0x10
    800019e8:	8d450513          	addi	a0,a0,-1836 # 800112b8 <tid_lock>
    800019ec:	fffff097          	auipc	ra,0xfffff
    800019f0:	14a080e7          	jalr	330(ra) # 80000b36 <initlock>
  initlock(&wait_lock, "wait_lock");
    800019f4:	00007597          	auipc	a1,0x7
    800019f8:	89c58593          	addi	a1,a1,-1892 # 80008290 <digits+0x250>
    800019fc:	00010517          	auipc	a0,0x10
    80001a00:	8d450513          	addi	a0,a0,-1836 # 800112d0 <wait_lock>
    80001a04:	fffff097          	auipc	ra,0xfffff
    80001a08:	132080e7          	jalr	306(ra) # 80000b36 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {      
    80001a0c:	00010997          	auipc	s3,0x10
    80001a10:	56498993          	addi	s3,s3,1380 # 80011f70 <proc+0x848>
    80001a14:	00010c17          	auipc	s8,0x10
    80001a18:	d14c0c13          	addi	s8,s8,-748 # 80011728 <proc>
      initlock(&p->lock, "proc");
      // p->kstack = KSTACK((int) (p - proc));
      int proc_index= (int)(p-proc);
    80001a1c:	8de2                	mv	s11,s8
    80001a1e:	00006d17          	auipc	s10,0x6
    80001a22:	5e2d0d13          	addi	s10,s10,1506 # 80008000 <etext>
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
        initlock(&t->lock, "thread");
    80001a26:	00007b97          	auipc	s7,0x7
    80001a2a:	882b8b93          	addi	s7,s7,-1918 # 800082a8 <digits+0x268>
        int thread_index = (int)(t-p->kthreads);
    80001a2e:	00006b17          	auipc	s6,0x6
    80001a32:	5dab0b13          	addi	s6,s6,1498 # 80008008 <etext+0x8>
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    80001a36:	04000ab7          	lui	s5,0x4000
    80001a3a:	1afd                	addi	s5,s5,-1
    80001a3c:	0ab2                	slli	s5,s5,0xc
  for(p = proc; p < &proc[NPROC]; p++) {      
    80001a3e:	6c85                	lui	s9,0x1
    80001a40:	848c8c93          	addi	s9,s9,-1976 # 848 <_entry-0x7ffff7b8>
    80001a44:	a809                	j	80001a56 <procinit+0xb0>
    80001a46:	9c66                	add	s8,s8,s9
    80001a48:	99e6                	add	s3,s3,s9
    80001a4a:	00031797          	auipc	a5,0x31
    80001a4e:	ede78793          	addi	a5,a5,-290 # 80032928 <tickslock>
    80001a52:	06fc0263          	beq	s8,a5,80001ab6 <procinit+0x110>
      initlock(&p->lock, "proc");
    80001a56:	00007597          	auipc	a1,0x7
    80001a5a:	84a58593          	addi	a1,a1,-1974 # 800082a0 <digits+0x260>
    80001a5e:	8562                	mv	a0,s8
    80001a60:	fffff097          	auipc	ra,0xfffff
    80001a64:	0d6080e7          	jalr	214(ra) # 80000b36 <initlock>
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001a68:	288c0a13          	addi	s4,s8,648
      int proc_index= (int)(p-proc);
    80001a6c:	41bc0933          	sub	s2,s8,s11
    80001a70:	40395913          	srai	s2,s2,0x3
    80001a74:	000d3783          	ld	a5,0(s10)
    80001a78:	02f90933          	mul	s2,s2,a5
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    80001a7c:	0039191b          	slliw	s2,s2,0x3
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001a80:	84d2                	mv	s1,s4
        initlock(&t->lock, "thread");
    80001a82:	85de                	mv	a1,s7
    80001a84:	8526                	mv	a0,s1
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	0b0080e7          	jalr	176(ra) # 80000b36 <initlock>
        int thread_index = (int)(t-p->kthreads);
    80001a8e:	414487b3          	sub	a5,s1,s4
    80001a92:	878d                	srai	a5,a5,0x3
    80001a94:	000b3703          	ld	a4,0(s6)
    80001a98:	02e787b3          	mul	a5,a5,a4
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    80001a9c:	012787bb          	addw	a5,a5,s2
    80001aa0:	2785                	addiw	a5,a5,1
    80001aa2:	00d7979b          	slliw	a5,a5,0xd
    80001aa6:	40fa87b3          	sub	a5,s5,a5
    80001aaa:	fc9c                	sd	a5,56(s1)
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001aac:	0b848493          	addi	s1,s1,184
    80001ab0:	fd3499e3          	bne	s1,s3,80001a82 <procinit+0xdc>
    80001ab4:	bf49                	j	80001a46 <procinit+0xa0>
      }
  }
}
    80001ab6:	70a6                	ld	ra,104(sp)
    80001ab8:	7406                	ld	s0,96(sp)
    80001aba:	64e6                	ld	s1,88(sp)
    80001abc:	6946                	ld	s2,80(sp)
    80001abe:	69a6                	ld	s3,72(sp)
    80001ac0:	6a06                	ld	s4,64(sp)
    80001ac2:	7ae2                	ld	s5,56(sp)
    80001ac4:	7b42                	ld	s6,48(sp)
    80001ac6:	7ba2                	ld	s7,40(sp)
    80001ac8:	7c02                	ld	s8,32(sp)
    80001aca:	6ce2                	ld	s9,24(sp)
    80001acc:	6d42                	ld	s10,16(sp)
    80001ace:	6da2                	ld	s11,8(sp)
    80001ad0:	6165                	addi	sp,sp,112
    80001ad2:	8082                	ret

0000000080001ad4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001ad4:	1141                	addi	sp,sp,-16
    80001ad6:	e422                	sd	s0,8(sp)
    80001ad8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ada:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001adc:	2501                	sext.w	a0,a0
    80001ade:	6422                	ld	s0,8(sp)
    80001ae0:	0141                	addi	sp,sp,16
    80001ae2:	8082                	ret

0000000080001ae4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001ae4:	1141                	addi	sp,sp,-16
    80001ae6:	e422                	sd	s0,8(sp)
    80001ae8:	0800                	addi	s0,sp,16
    80001aea:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001aec:	0007851b          	sext.w	a0,a5
    80001af0:	00451793          	slli	a5,a0,0x4
    80001af4:	97aa                	add	a5,a5,a0
    80001af6:	078e                	slli	a5,a5,0x3
  return c;
}
    80001af8:	0000f517          	auipc	a0,0xf
    80001afc:	7f050513          	addi	a0,a0,2032 # 800112e8 <cpus>
    80001b00:	953e                	add	a0,a0,a5
    80001b02:	6422                	ld	s0,8(sp)
    80001b04:	0141                	addi	sp,sp,16
    80001b06:	8082                	ret

0000000080001b08 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001b08:	1101                	addi	sp,sp,-32
    80001b0a:	ec06                	sd	ra,24(sp)
    80001b0c:	e822                	sd	s0,16(sp)
    80001b0e:	e426                	sd	s1,8(sp)
    80001b10:	1000                	addi	s0,sp,32
  push_off();
    80001b12:	fffff097          	auipc	ra,0xfffff
    80001b16:	068080e7          	jalr	104(ra) # 80000b7a <push_off>
    80001b1a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b1c:	0007871b          	sext.w	a4,a5
    80001b20:	00471793          	slli	a5,a4,0x4
    80001b24:	97ba                	add	a5,a5,a4
    80001b26:	078e                	slli	a5,a5,0x3
    80001b28:	0000f717          	auipc	a4,0xf
    80001b2c:	77870713          	addi	a4,a4,1912 # 800112a0 <pid_lock>
    80001b30:	97ba                	add	a5,a5,a4
    80001b32:	67a4                	ld	s1,72(a5)
  pop_off();
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	0fc080e7          	jalr	252(ra) # 80000c30 <pop_off>
  return p;
}//
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	60e2                	ld	ra,24(sp)
    80001b40:	6442                	ld	s0,16(sp)
    80001b42:	64a2                	ld	s1,8(sp)
    80001b44:	6105                	addi	sp,sp,32
    80001b46:	8082                	ret

0000000080001b48 <mykthread>:

struct kthread*
mykthread(void){
    80001b48:	1101                	addi	sp,sp,-32
    80001b4a:	ec06                	sd	ra,24(sp)
    80001b4c:	e822                	sd	s0,16(sp)
    80001b4e:	e426                	sd	s1,8(sp)
    80001b50:	1000                	addi	s0,sp,32
  push_off();
    80001b52:	fffff097          	auipc	ra,0xfffff
    80001b56:	028080e7          	jalr	40(ra) # 80000b7a <push_off>
    80001b5a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct kthread *t=c->kthread;
    80001b5c:	0007871b          	sext.w	a4,a5
    80001b60:	00471793          	slli	a5,a4,0x4
    80001b64:	97ba                	add	a5,a5,a4
    80001b66:	078e                	slli	a5,a5,0x3
    80001b68:	0000f717          	auipc	a4,0xf
    80001b6c:	73870713          	addi	a4,a4,1848 # 800112a0 <pid_lock>
    80001b70:	97ba                	add	a5,a5,a4
    80001b72:	67e4                	ld	s1,200(a5)
  pop_off();
    80001b74:	fffff097          	auipc	ra,0xfffff
    80001b78:	0bc080e7          	jalr	188(ra) # 80000c30 <pop_off>
  return t;  
}
    80001b7c:	8526                	mv	a0,s1
    80001b7e:	60e2                	ld	ra,24(sp)
    80001b80:	6442                	ld	s0,16(sp)
    80001b82:	64a2                	ld	s1,8(sp)
    80001b84:	6105                	addi	sp,sp,32
    80001b86:	8082                	ret

0000000080001b88 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001b88:	1141                	addi	sp,sp,-16
    80001b8a:	e406                	sd	ra,8(sp)
    80001b8c:	e022                	sd	s0,0(sp)
    80001b8e:	0800                	addi	s0,sp,16
  // static variables initialized only once
  static int first = 1;

  // Still holding p->lock from scheduler.
  // release(&myproc()->lock);
  release(&mykthread()->lock);    // TODO: check if this change is good
    80001b90:	00000097          	auipc	ra,0x0
    80001b94:	fb8080e7          	jalr	-72(ra) # 80001b48 <mykthread>
    80001b98:	fffff097          	auipc	ra,0xfffff
    80001b9c:	0f8080e7          	jalr	248(ra) # 80000c90 <release>

  if (first) {
    80001ba0:	00007797          	auipc	a5,0x7
    80001ba4:	ef07a783          	lw	a5,-272(a5) # 80008a90 <first.1>
    80001ba8:	eb89                	bnez	a5,80001bba <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001baa:	00002097          	auipc	ra,0x2
    80001bae:	8e6080e7          	jalr	-1818(ra) # 80003490 <usertrapret>
}
    80001bb2:	60a2                	ld	ra,8(sp)
    80001bb4:	6402                	ld	s0,0(sp)
    80001bb6:	0141                	addi	sp,sp,16
    80001bb8:	8082                	ret
    first = 0;
    80001bba:	00007797          	auipc	a5,0x7
    80001bbe:	ec07ab23          	sw	zero,-298(a5) # 80008a90 <first.1>
    fsinit(ROOTDEV);
    80001bc2:	4505                	li	a0,1
    80001bc4:	00003097          	auipc	ra,0x3
    80001bc8:	8ac080e7          	jalr	-1876(ra) # 80004470 <fsinit>
    80001bcc:	bff9                	j	80001baa <forkret+0x22>

0000000080001bce <allocpid>:
allocpid() {
    80001bce:	1101                	addi	sp,sp,-32
    80001bd0:	ec06                	sd	ra,24(sp)
    80001bd2:	e822                	sd	s0,16(sp)
    80001bd4:	e426                	sd	s1,8(sp)
    80001bd6:	e04a                	sd	s2,0(sp)
    80001bd8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001bda:	0000f917          	auipc	s2,0xf
    80001bde:	6c690913          	addi	s2,s2,1734 # 800112a0 <pid_lock>
    80001be2:	854a                	mv	a0,s2
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	fe2080e7          	jalr	-30(ra) # 80000bc6 <acquire>
  pid = nextpid;
    80001bec:	00007797          	auipc	a5,0x7
    80001bf0:	eac78793          	addi	a5,a5,-340 # 80008a98 <nextpid>
    80001bf4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bf6:	0014871b          	addiw	a4,s1,1
    80001bfa:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bfc:	854a                	mv	a0,s2
    80001bfe:	fffff097          	auipc	ra,0xfffff
    80001c02:	092080e7          	jalr	146(ra) # 80000c90 <release>
}
    80001c06:	8526                	mv	a0,s1
    80001c08:	60e2                	ld	ra,24(sp)
    80001c0a:	6442                	ld	s0,16(sp)
    80001c0c:	64a2                	ld	s1,8(sp)
    80001c0e:	6902                	ld	s2,0(sp)
    80001c10:	6105                	addi	sp,sp,32
    80001c12:	8082                	ret

0000000080001c14 <alloctid>:
alloctid() {
    80001c14:	1101                	addi	sp,sp,-32
    80001c16:	ec06                	sd	ra,24(sp)
    80001c18:	e822                	sd	s0,16(sp)
    80001c1a:	e426                	sd	s1,8(sp)
    80001c1c:	e04a                	sd	s2,0(sp)
    80001c1e:	1000                	addi	s0,sp,32
  acquire(&tid_lock);
    80001c20:	0000f917          	auipc	s2,0xf
    80001c24:	69890913          	addi	s2,s2,1688 # 800112b8 <tid_lock>
    80001c28:	854a                	mv	a0,s2
    80001c2a:	fffff097          	auipc	ra,0xfffff
    80001c2e:	f9c080e7          	jalr	-100(ra) # 80000bc6 <acquire>
  tid = nexttid;
    80001c32:	00007797          	auipc	a5,0x7
    80001c36:	e6278793          	addi	a5,a5,-414 # 80008a94 <nexttid>
    80001c3a:	4384                	lw	s1,0(a5)
  nexttid = nexttid + 1;
    80001c3c:	0014871b          	addiw	a4,s1,1
    80001c40:	c398                	sw	a4,0(a5)
  release(&tid_lock);
    80001c42:	854a                	mv	a0,s2
    80001c44:	fffff097          	auipc	ra,0xfffff
    80001c48:	04c080e7          	jalr	76(ra) # 80000c90 <release>
}
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	60e2                	ld	ra,24(sp)
    80001c50:	6442                	ld	s0,16(sp)
    80001c52:	64a2                	ld	s1,8(sp)
    80001c54:	6902                	ld	s2,0(sp)
    80001c56:	6105                	addi	sp,sp,32
    80001c58:	8082                	ret

0000000080001c5a <init_thread>:
init_thread(struct kthread *t){
    80001c5a:	1101                	addi	sp,sp,-32
    80001c5c:	ec06                	sd	ra,24(sp)
    80001c5e:	e822                	sd	s0,16(sp)
    80001c60:	e426                	sd	s1,8(sp)
    80001c62:	1000                	addi	s0,sp,32
    80001c64:	84aa                	mv	s1,a0
  t->state = TUSED;
    80001c66:	4785                	li	a5,1
    80001c68:	cd1c                	sw	a5,24(a0)
  t->tid = alloctid();  
    80001c6a:	00000097          	auipc	ra,0x0
    80001c6e:	faa080e7          	jalr	-86(ra) # 80001c14 <alloctid>
    80001c72:	d888                	sw	a0,48(s1)
  memset(&(t->context), 0, sizeof(t->context));
    80001c74:	07000613          	li	a2,112
    80001c78:	4581                	li	a1,0
    80001c7a:	04848513          	addi	a0,s1,72
    80001c7e:	fffff097          	auipc	ra,0xfffff
    80001c82:	05a080e7          	jalr	90(ra) # 80000cd8 <memset>
  t->context.ra = (uint64)forkret;
    80001c86:	00000797          	auipc	a5,0x0
    80001c8a:	f0278793          	addi	a5,a5,-254 # 80001b88 <forkret>
    80001c8e:	e4bc                	sd	a5,72(s1)
  t->context.sp = t->kstack + PGSIZE;
    80001c90:	7c9c                	ld	a5,56(s1)
    80001c92:	6705                	lui	a4,0x1
    80001c94:	97ba                	add	a5,a5,a4
    80001c96:	e8bc                	sd	a5,80(s1)
}
    80001c98:	4501                	li	a0,0
    80001c9a:	60e2                	ld	ra,24(sp)
    80001c9c:	6442                	ld	s0,16(sp)
    80001c9e:	64a2                	ld	s1,8(sp)
    80001ca0:	6105                	addi	sp,sp,32
    80001ca2:	8082                	ret

0000000080001ca4 <proc_pagetable>:
{
    80001ca4:	1101                	addi	sp,sp,-32
    80001ca6:	ec06                	sd	ra,24(sp)
    80001ca8:	e822                	sd	s0,16(sp)
    80001caa:	e426                	sd	s1,8(sp)
    80001cac:	e04a                	sd	s2,0(sp)
    80001cae:	1000                	addi	s0,sp,32
    80001cb0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001cb2:	fffff097          	auipc	ra,0xfffff
    80001cb6:	6f6080e7          	jalr	1782(ra) # 800013a8 <uvmcreate>
    80001cba:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001cbc:	c12d                	beqz	a0,80001d1e <proc_pagetable+0x7a>
  printf("before mappages\n");
    80001cbe:	00006517          	auipc	a0,0x6
    80001cc2:	5f250513          	addi	a0,a0,1522 # 800082b0 <digits+0x270>
    80001cc6:	fffff097          	auipc	ra,0xfffff
    80001cca:	8b2080e7          	jalr	-1870(ra) # 80000578 <printf>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001cce:	4729                	li	a4,10
    80001cd0:	00005697          	auipc	a3,0x5
    80001cd4:	33068693          	addi	a3,a3,816 # 80007000 <_trampoline>
    80001cd8:	6605                	lui	a2,0x1
    80001cda:	040005b7          	lui	a1,0x4000
    80001cde:	15fd                	addi	a1,a1,-1
    80001ce0:	05b2                	slli	a1,a1,0xc
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	fffff097          	auipc	ra,0xfffff
    80001ce8:	43c080e7          	jalr	1084(ra) # 80001120 <mappages>
    80001cec:	04054063          	bltz	a0,80001d2c <proc_pagetable+0x88>
  printf("after mappages\n");
    80001cf0:	00006517          	auipc	a0,0x6
    80001cf4:	5d850513          	addi	a0,a0,1496 # 800082c8 <digits+0x288>
    80001cf8:	fffff097          	auipc	ra,0xfffff
    80001cfc:	880080e7          	jalr	-1920(ra) # 80000578 <printf>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d00:	4719                	li	a4,6
    80001d02:	04893683          	ld	a3,72(s2)
    80001d06:	6605                	lui	a2,0x1
    80001d08:	020005b7          	lui	a1,0x2000
    80001d0c:	15fd                	addi	a1,a1,-1
    80001d0e:	05b6                	slli	a1,a1,0xd
    80001d10:	8526                	mv	a0,s1
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	40e080e7          	jalr	1038(ra) # 80001120 <mappages>
    80001d1a:	02054163          	bltz	a0,80001d3c <proc_pagetable+0x98>
}
    80001d1e:	8526                	mv	a0,s1
    80001d20:	60e2                	ld	ra,24(sp)
    80001d22:	6442                	ld	s0,16(sp)
    80001d24:	64a2                	ld	s1,8(sp)
    80001d26:	6902                	ld	s2,0(sp)
    80001d28:	6105                	addi	sp,sp,32
    80001d2a:	8082                	ret
    uvmfree(pagetable, 0);
    80001d2c:	4581                	li	a1,0
    80001d2e:	8526                	mv	a0,s1
    80001d30:	00000097          	auipc	ra,0x0
    80001d34:	884080e7          	jalr	-1916(ra) # 800015b4 <uvmfree>
    return 0;
    80001d38:	4481                	li	s1,0
    80001d3a:	b7d5                	j	80001d1e <proc_pagetable+0x7a>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d3c:	4681                	li	a3,0
    80001d3e:	4605                	li	a2,1
    80001d40:	040005b7          	lui	a1,0x4000
    80001d44:	15fd                	addi	a1,a1,-1
    80001d46:	05b2                	slli	a1,a1,0xc
    80001d48:	8526                	mv	a0,s1
    80001d4a:	fffff097          	auipc	ra,0xfffff
    80001d4e:	59a080e7          	jalr	1434(ra) # 800012e4 <uvmunmap>
    uvmfree(pagetable, 0);
    80001d52:	4581                	li	a1,0
    80001d54:	8526                	mv	a0,s1
    80001d56:	00000097          	auipc	ra,0x0
    80001d5a:	85e080e7          	jalr	-1954(ra) # 800015b4 <uvmfree>
    return 0;
    80001d5e:	4481                	li	s1,0
    80001d60:	bf7d                	j	80001d1e <proc_pagetable+0x7a>

0000000080001d62 <proc_freepagetable>:
{
    80001d62:	1101                	addi	sp,sp,-32
    80001d64:	ec06                	sd	ra,24(sp)
    80001d66:	e822                	sd	s0,16(sp)
    80001d68:	e426                	sd	s1,8(sp)
    80001d6a:	e04a                	sd	s2,0(sp)
    80001d6c:	1000                	addi	s0,sp,32
    80001d6e:	84aa                	mv	s1,a0
    80001d70:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d72:	4681                	li	a3,0
    80001d74:	4605                	li	a2,1
    80001d76:	040005b7          	lui	a1,0x4000
    80001d7a:	15fd                	addi	a1,a1,-1
    80001d7c:	05b2                	slli	a1,a1,0xc
    80001d7e:	fffff097          	auipc	ra,0xfffff
    80001d82:	566080e7          	jalr	1382(ra) # 800012e4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d86:	4681                	li	a3,0
    80001d88:	4605                	li	a2,1
    80001d8a:	020005b7          	lui	a1,0x2000
    80001d8e:	15fd                	addi	a1,a1,-1
    80001d90:	05b6                	slli	a1,a1,0xd
    80001d92:	8526                	mv	a0,s1
    80001d94:	fffff097          	auipc	ra,0xfffff
    80001d98:	550080e7          	jalr	1360(ra) # 800012e4 <uvmunmap>
  uvmfree(pagetable, sz);
    80001d9c:	85ca                	mv	a1,s2
    80001d9e:	8526                	mv	a0,s1
    80001da0:	00000097          	auipc	ra,0x0
    80001da4:	814080e7          	jalr	-2028(ra) # 800015b4 <uvmfree>
}
    80001da8:	60e2                	ld	ra,24(sp)
    80001daa:	6442                	ld	s0,16(sp)
    80001dac:	64a2                	ld	s1,8(sp)
    80001dae:	6902                	ld	s2,0(sp)
    80001db0:	6105                	addi	sp,sp,32
    80001db2:	8082                	ret

0000000080001db4 <freeproc>:
{
    80001db4:	7179                	addi	sp,sp,-48
    80001db6:	f406                	sd	ra,40(sp)
    80001db8:	f022                	sd	s0,32(sp)
    80001dba:	ec26                	sd	s1,24(sp)
    80001dbc:	e84a                	sd	s2,16(sp)
    80001dbe:	e44e                	sd	s3,8(sp)
    80001dc0:	1800                	addi	s0,sp,48
    80001dc2:	892a                	mv	s2,a0
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001dc4:	28850493          	addi	s1,a0,648
    80001dc8:	6985                	lui	s3,0x1
    80001dca:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80001dce:	99aa                	add	s3,s3,a0
    80001dd0:	a811                	j	80001de4 <freeproc+0x30>
    release(&t->lock);
    80001dd2:	8526                	mv	a0,s1
    80001dd4:	fffff097          	auipc	ra,0xfffff
    80001dd8:	ebc080e7          	jalr	-324(ra) # 80000c90 <release>
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001ddc:	0b848493          	addi	s1,s1,184
    80001de0:	02998463          	beq	s3,s1,80001e08 <freeproc+0x54>
    acquire(&t->lock);
    80001de4:	8526                	mv	a0,s1
    80001de6:	fffff097          	auipc	ra,0xfffff
    80001dea:	de0080e7          	jalr	-544(ra) # 80000bc6 <acquire>
    if(t->state != TUNUSED)
    80001dee:	4c9c                	lw	a5,24(s1)
    80001df0:	d3ed                	beqz	a5,80001dd2 <freeproc+0x1e>
  t->tid = 0;
    80001df2:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80001df6:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80001dfa:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80001dfe:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80001e02:	0004ac23          	sw	zero,24(s1)
}
    80001e06:	b7f1                	j	80001dd2 <freeproc+0x1e>
  p->user_trapframe_backup = 0;
    80001e08:	26093c23          	sd	zero,632(s2)
  if(p->pagetable)
    80001e0c:	04093503          	ld	a0,64(s2)
    80001e10:	c519                	beqz	a0,80001e1e <freeproc+0x6a>
    proc_freepagetable(p->pagetable, p->sz);
    80001e12:	03893583          	ld	a1,56(s2)
    80001e16:	00000097          	auipc	ra,0x0
    80001e1a:	f4c080e7          	jalr	-180(ra) # 80001d62 <proc_freepagetable>
  p->pagetable = 0;
    80001e1e:	04093023          	sd	zero,64(s2)
  p->sz = 0;
    80001e22:	02093c23          	sd	zero,56(s2)
  p->pid = 0;
    80001e26:	02092223          	sw	zero,36(s2)
  p->parent = 0;
    80001e2a:	02093823          	sd	zero,48(s2)
  p->name[0] = 0;
    80001e2e:	0c090c23          	sb	zero,216(s2)
  p->killed = 0;
    80001e32:	00092e23          	sw	zero,28(s2)
  p->xstate = 0;
    80001e36:	02092023          	sw	zero,32(s2)
  p->active_threads = 0;
    80001e3a:	02092423          	sw	zero,40(s2)
  p->state = UNUSED;
    80001e3e:	00092c23          	sw	zero,24(s2)
}
    80001e42:	70a2                	ld	ra,40(sp)
    80001e44:	7402                	ld	s0,32(sp)
    80001e46:	64e2                	ld	s1,24(sp)
    80001e48:	6942                	ld	s2,16(sp)
    80001e4a:	69a2                	ld	s3,8(sp)
    80001e4c:	6145                	addi	sp,sp,48
    80001e4e:	8082                	ret

0000000080001e50 <allocproc>:
{
    80001e50:	715d                	addi	sp,sp,-80
    80001e52:	e486                	sd	ra,72(sp)
    80001e54:	e0a2                	sd	s0,64(sp)
    80001e56:	fc26                	sd	s1,56(sp)
    80001e58:	f84a                	sd	s2,48(sp)
    80001e5a:	f44e                	sd	s3,40(sp)
    80001e5c:	f052                	sd	s4,32(sp)
    80001e5e:	ec56                	sd	s5,24(sp)
    80001e60:	e85a                	sd	s6,16(sp)
    80001e62:	e45e                	sd	s7,8(sp)
    80001e64:	e062                	sd	s8,0(sp)
    80001e66:	0880                	addi	s0,sp,80
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e68:	00010497          	auipc	s1,0x10
    80001e6c:	8c048493          	addi	s1,s1,-1856 # 80011728 <proc>
    80001e70:	6985                	lui	s3,0x1
    80001e72:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80001e76:	00031a17          	auipc	s4,0x31
    80001e7a:	ab2a0a13          	addi	s4,s4,-1358 # 80032928 <tickslock>
    acquire(&p->lock);
    80001e7e:	8526                	mv	a0,s1
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	d46080e7          	jalr	-698(ra) # 80000bc6 <acquire>
    if(p->state == UNUSED) {
    80001e88:	4c9c                	lw	a5,24(s1)
    80001e8a:	cb99                	beqz	a5,80001ea0 <allocproc+0x50>
      release(&p->lock);
    80001e8c:	8526                	mv	a0,s1
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	e02080e7          	jalr	-510(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e96:	94ce                	add	s1,s1,s3
    80001e98:	ff4493e3          	bne	s1,s4,80001e7e <allocproc+0x2e>
  return 0;
    80001e9c:	4481                	li	s1,0
    80001e9e:	a8f5                	j	80001f9a <allocproc+0x14a>
  p->pid = allocpid();
    80001ea0:	00000097          	auipc	ra,0x0
    80001ea4:	d2e080e7          	jalr	-722(ra) # 80001bce <allocpid>
    80001ea8:	d0c8                	sw	a0,36(s1)
  p->state = USED;
    80001eaa:	4785                	li	a5,1
    80001eac:	cc9c                	sw	a5,24(s1)
  if((p->threads_tf_start =kalloc()) == 0){
    80001eae:	fffff097          	auipc	ra,0xfffff
    80001eb2:	c28080e7          	jalr	-984(ra) # 80000ad6 <kalloc>
    80001eb6:	89aa                	mv	s3,a0
    80001eb8:	e4a8                	sd	a0,72(s1)
    80001eba:	cd6d                	beqz	a0,80001fb4 <allocproc+0x164>
  printf("start of tfs %p \n",p->threads_tf_start);
    80001ebc:	85aa                	mv	a1,a0
    80001ebe:	00006517          	auipc	a0,0x6
    80001ec2:	41a50513          	addi	a0,a0,1050 # 800082d8 <digits+0x298>
    80001ec6:	ffffe097          	auipc	ra,0xffffe
    80001eca:	6b2080e7          	jalr	1714(ra) # 80000578 <printf>
  for(int i=0;i<32;i++){
    80001ece:	0f848713          	addi	a4,s1,248
    80001ed2:	1f848793          	addi	a5,s1,504
    80001ed6:	27848693          	addi	a3,s1,632
    p->signal_handlers[i] = SIG_DFL;
    80001eda:	00073023          	sd	zero,0(a4) # 1000 <_entry-0x7ffff000>
    p->handlers_sigmasks[i] = 0;
    80001ede:	0007a023          	sw	zero,0(a5)
  for(int i=0;i<32;i++){
    80001ee2:	0721                	addi	a4,a4,8
    80001ee4:	0791                	addi	a5,a5,4
    80001ee6:	fed79ae3          	bne	a5,a3,80001eda <allocproc+0x8a>
  p->signal_mask= 0;
    80001eea:	0e04a623          	sw	zero,236(s1)
  p->pending_signals = 0;
    80001eee:	0e04a423          	sw	zero,232(s1)
  p->active_threads=1;
    80001ef2:	4785                	li	a5,1
    80001ef4:	d49c                	sw	a5,40(s1)
  p->signal_mask_backup = 0;
    80001ef6:	0e04a823          	sw	zero,240(s1)
  p->handling_user_sig_flag = 0;
    80001efa:	2804a023          	sw	zero,640(s1)
  p->handling_sig_flag=0;
    80001efe:	2804a223          	sw	zero,644(s1)
  p->pagetable = proc_pagetable(p);
    80001f02:	8526                	mv	a0,s1
    80001f04:	00000097          	auipc	ra,0x0
    80001f08:	da0080e7          	jalr	-608(ra) # 80001ca4 <proc_pagetable>
    80001f0c:	8c2a                	mv	s8,a0
    80001f0e:	e0a8                	sd	a0,64(s1)
  if(p->pagetable == 0){
    80001f10:	2a048913          	addi	s2,s1,672
    80001f14:	4a01                	li	s4,0
  for(int i=0;i<NTHREAD;i++){
    80001f16:	4981                	li	s3,0
    t->tid=-1;
    80001f18:	5bfd                	li	s7,-1
    printf("addr of t %d is %p\n",i ,t->trapframe);
    80001f1a:	00006b17          	auipc	s6,0x6
    80001f1e:	3d6b0b13          	addi	s6,s6,982 # 800082f0 <digits+0x2b0>
  for(int i=0;i<NTHREAD;i++){
    80001f22:	4aa1                	li	s5,8
  if(p->pagetable == 0){
    80001f24:	c545                	beqz	a0,80001fcc <allocproc+0x17c>
    t->state=TUNUSED;
    80001f26:	00092023          	sw	zero,0(s2)
    t->chan=0;
    80001f2a:	00093423          	sd	zero,8(s2)
    t->tid=-1;
    80001f2e:	01792c23          	sw	s7,24(s2)
    t->trapframe = (struct trapframe *)p->threads_tf_start + i;     //TODO: check if good or maybe + i*sizeof(struct trapframe)
    80001f32:	64b0                	ld	a2,72(s1)
    80001f34:	9652                	add	a2,a2,s4
    80001f36:	02c93423          	sd	a2,40(s2)
    printf("addr of t %d is %p\n",i ,t->trapframe);
    80001f3a:	85ce                	mv	a1,s3
    80001f3c:	855a                	mv	a0,s6
    80001f3e:	ffffe097          	auipc	ra,0xffffe
    80001f42:	63a080e7          	jalr	1594(ra) # 80000578 <printf>
    t->killed = 0;
    80001f46:	00092823          	sw	zero,16(s2)
    t->frozen = 0;
    80001f4a:	00092e23          	sw	zero,28(s2)
  for(int i=0;i<NTHREAD;i++){
    80001f4e:	2985                	addiw	s3,s3,1
    80001f50:	0b890913          	addi	s2,s2,184
    80001f54:	120a0a13          	addi	s4,s4,288
    80001f58:	fd5997e3          	bne	s3,s5,80001f26 <allocproc+0xd6>
  printf("finished thread loop\n");
    80001f5c:	00006517          	auipc	a0,0x6
    80001f60:	3ac50513          	addi	a0,a0,940 # 80008308 <digits+0x2c8>
    80001f64:	ffffe097          	auipc	ra,0xffffe
    80001f68:	614080e7          	jalr	1556(ra) # 80000578 <printf>
  struct kthread *t= &p->kthreads[0];
    80001f6c:	28848913          	addi	s2,s1,648
  acquire(&t->lock);
    80001f70:	854a                	mv	a0,s2
    80001f72:	fffff097          	auipc	ra,0xfffff
    80001f76:	c54080e7          	jalr	-940(ra) # 80000bc6 <acquire>
  if(init_thread(t) == -1){
    80001f7a:	854a                	mv	a0,s2
    80001f7c:	00000097          	auipc	ra,0x0
    80001f80:	cde080e7          	jalr	-802(ra) # 80001c5a <init_thread>
    80001f84:	57fd                	li	a5,-1
    80001f86:	04f50f63          	beq	a0,a5,80001fe4 <allocproc+0x194>
  printf("after allocproc\n");
    80001f8a:	00006517          	auipc	a0,0x6
    80001f8e:	3b650513          	addi	a0,a0,950 # 80008340 <digits+0x300>
    80001f92:	ffffe097          	auipc	ra,0xffffe
    80001f96:	5e6080e7          	jalr	1510(ra) # 80000578 <printf>
}
    80001f9a:	8526                	mv	a0,s1
    80001f9c:	60a6                	ld	ra,72(sp)
    80001f9e:	6406                	ld	s0,64(sp)
    80001fa0:	74e2                	ld	s1,56(sp)
    80001fa2:	7942                	ld	s2,48(sp)
    80001fa4:	79a2                	ld	s3,40(sp)
    80001fa6:	7a02                	ld	s4,32(sp)
    80001fa8:	6ae2                	ld	s5,24(sp)
    80001faa:	6b42                	ld	s6,16(sp)
    80001fac:	6ba2                	ld	s7,8(sp)
    80001fae:	6c02                	ld	s8,0(sp)
    80001fb0:	6161                	addi	sp,sp,80
    80001fb2:	8082                	ret
    freeproc(p);
    80001fb4:	8526                	mv	a0,s1
    80001fb6:	00000097          	auipc	ra,0x0
    80001fba:	dfe080e7          	jalr	-514(ra) # 80001db4 <freeproc>
    release(&p->lock);
    80001fbe:	8526                	mv	a0,s1
    80001fc0:	fffff097          	auipc	ra,0xfffff
    80001fc4:	cd0080e7          	jalr	-816(ra) # 80000c90 <release>
    return 0;
    80001fc8:	84ce                	mv	s1,s3
    80001fca:	bfc1                	j	80001f9a <allocproc+0x14a>
    freeproc(p);
    80001fcc:	8526                	mv	a0,s1
    80001fce:	00000097          	auipc	ra,0x0
    80001fd2:	de6080e7          	jalr	-538(ra) # 80001db4 <freeproc>
    release(&p->lock);
    80001fd6:	8526                	mv	a0,s1
    80001fd8:	fffff097          	auipc	ra,0xfffff
    80001fdc:	cb8080e7          	jalr	-840(ra) # 80000c90 <release>
    return 0;
    80001fe0:	84e2                	mv	s1,s8
    80001fe2:	bf65                	j	80001f9a <allocproc+0x14a>
    printf("after init_threat failed\n");
    80001fe4:	00006517          	auipc	a0,0x6
    80001fe8:	33c50513          	addi	a0,a0,828 # 80008320 <digits+0x2e0>
    80001fec:	ffffe097          	auipc	ra,0xffffe
    80001ff0:	58c080e7          	jalr	1420(ra) # 80000578 <printf>
    freeproc(p);
    80001ff4:	8526                	mv	a0,s1
    80001ff6:	00000097          	auipc	ra,0x0
    80001ffa:	dbe080e7          	jalr	-578(ra) # 80001db4 <freeproc>
    release(&p->lock);
    80001ffe:	8526                	mv	a0,s1
    80002000:	fffff097          	auipc	ra,0xfffff
    80002004:	c90080e7          	jalr	-880(ra) # 80000c90 <release>
    return 0;
    80002008:	4481                	li	s1,0
    8000200a:	bf41                	j	80001f9a <allocproc+0x14a>

000000008000200c <userinit>:
{
    8000200c:	1101                	addi	sp,sp,-32
    8000200e:	ec06                	sd	ra,24(sp)
    80002010:	e822                	sd	s0,16(sp)
    80002012:	e426                	sd	s1,8(sp)
    80002014:	e04a                	sd	s2,0(sp)
    80002016:	1000                	addi	s0,sp,32
  p = allocproc();
    80002018:	00000097          	auipc	ra,0x0
    8000201c:	e38080e7          	jalr	-456(ra) # 80001e50 <allocproc>
    80002020:	84aa                	mv	s1,a0
  initproc = p;
    80002022:	00007797          	auipc	a5,0x7
    80002026:	00a7b323          	sd	a0,6(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    8000202a:	03400613          	li	a2,52
    8000202e:	00007597          	auipc	a1,0x7
    80002032:	a7258593          	addi	a1,a1,-1422 # 80008aa0 <initcode>
    80002036:	6128                	ld	a0,64(a0)
    80002038:	fffff097          	auipc	ra,0xfffff
    8000203c:	39e080e7          	jalr	926(ra) # 800013d6 <uvminit>
  printf("returned from uvminit\n");
    80002040:	00006517          	auipc	a0,0x6
    80002044:	31850513          	addi	a0,a0,792 # 80008358 <digits+0x318>
    80002048:	ffffe097          	auipc	ra,0xffffe
    8000204c:	530080e7          	jalr	1328(ra) # 80000578 <printf>
  p->sz = PGSIZE;
    80002050:	6905                	lui	s2,0x1
    80002052:	0324bc23          	sd	s2,56(s1)
  printf("after p->sz\n");
    80002056:	00006517          	auipc	a0,0x6
    8000205a:	31a50513          	addi	a0,a0,794 # 80008370 <digits+0x330>
    8000205e:	ffffe097          	auipc	ra,0xffffe
    80002062:	51a080e7          	jalr	1306(ra) # 80000578 <printf>
  printf("t: %p\n",t);
    80002066:	28848593          	addi	a1,s1,648
    8000206a:	00006517          	auipc	a0,0x6
    8000206e:	31650513          	addi	a0,a0,790 # 80008380 <digits+0x340>
    80002072:	ffffe097          	auipc	ra,0xffffe
    80002076:	506080e7          	jalr	1286(ra) # 80000578 <printf>
  printf("tf : %p \n",t->trapframe);
    8000207a:	2c84b583          	ld	a1,712(s1)
    8000207e:	00006517          	auipc	a0,0x6
    80002082:	30a50513          	addi	a0,a0,778 # 80008388 <digits+0x348>
    80002086:	ffffe097          	auipc	ra,0xffffe
    8000208a:	4f2080e7          	jalr	1266(ra) # 80000578 <printf>
  t->trapframe->epc = 0;      // user program counter
    8000208e:	2c84b783          	ld	a5,712(s1)
    80002092:	0007bc23          	sd	zero,24(a5)
  t->trapframe->sp = PGSIZE;  // user stack pointer
    80002096:	2c84b783          	ld	a5,712(s1)
    8000209a:	0327b823          	sd	s2,48(a5)
  printf("before strcpy\n");
    8000209e:	00006517          	auipc	a0,0x6
    800020a2:	2fa50513          	addi	a0,a0,762 # 80008398 <digits+0x358>
    800020a6:	ffffe097          	auipc	ra,0xffffe
    800020aa:	4d2080e7          	jalr	1234(ra) # 80000578 <printf>
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800020ae:	4641                	li	a2,16
    800020b0:	00006597          	auipc	a1,0x6
    800020b4:	2f858593          	addi	a1,a1,760 # 800083a8 <digits+0x368>
    800020b8:	0d848513          	addi	a0,s1,216
    800020bc:	fffff097          	auipc	ra,0xfffff
    800020c0:	d6e080e7          	jalr	-658(ra) # 80000e2a <safestrcpy>
  printf("after strcpy\n");
    800020c4:	00006517          	auipc	a0,0x6
    800020c8:	2f450513          	addi	a0,a0,756 # 800083b8 <digits+0x378>
    800020cc:	ffffe097          	auipc	ra,0xffffe
    800020d0:	4ac080e7          	jalr	1196(ra) # 80000578 <printf>
  p->cwd = namei("/");
    800020d4:	00006517          	auipc	a0,0x6
    800020d8:	2f450513          	addi	a0,a0,756 # 800083c8 <digits+0x388>
    800020dc:	00003097          	auipc	ra,0x3
    800020e0:	dc0080e7          	jalr	-576(ra) # 80004e9c <namei>
    800020e4:	e8e8                	sd	a0,208(s1)
  p->state = RUNNABLE;
    800020e6:	4789                	li	a5,2
    800020e8:	cc9c                	sw	a5,24(s1)
  t->state = TRUNNABLE;
    800020ea:	478d                	li	a5,3
    800020ec:	2af4a023          	sw	a5,672(s1)
  release(&p->lock);
    800020f0:	8526                	mv	a0,s1
    800020f2:	fffff097          	auipc	ra,0xfffff
    800020f6:	b9e080e7          	jalr	-1122(ra) # 80000c90 <release>
  printf("after user init\n");
    800020fa:	00006517          	auipc	a0,0x6
    800020fe:	2d650513          	addi	a0,a0,726 # 800083d0 <digits+0x390>
    80002102:	ffffe097          	auipc	ra,0xffffe
    80002106:	476080e7          	jalr	1142(ra) # 80000578 <printf>
}
    8000210a:	60e2                	ld	ra,24(sp)
    8000210c:	6442                	ld	s0,16(sp)
    8000210e:	64a2                	ld	s1,8(sp)
    80002110:	6902                	ld	s2,0(sp)
    80002112:	6105                	addi	sp,sp,32
    80002114:	8082                	ret

0000000080002116 <growproc>:
{
    80002116:	1101                	addi	sp,sp,-32
    80002118:	ec06                	sd	ra,24(sp)
    8000211a:	e822                	sd	s0,16(sp)
    8000211c:	e426                	sd	s1,8(sp)
    8000211e:	e04a                	sd	s2,0(sp)
    80002120:	1000                	addi	s0,sp,32
    80002122:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002124:	00000097          	auipc	ra,0x0
    80002128:	9e4080e7          	jalr	-1564(ra) # 80001b08 <myproc>
    8000212c:	892a                	mv	s2,a0
  sz = p->sz;
    8000212e:	7d0c                	ld	a1,56(a0)
    80002130:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80002134:	00904f63          	bgtz	s1,80002152 <growproc+0x3c>
  } else if(n < 0){
    80002138:	0204cc63          	bltz	s1,80002170 <growproc+0x5a>
  p->sz = sz;
    8000213c:	1602                	slli	a2,a2,0x20
    8000213e:	9201                	srli	a2,a2,0x20
    80002140:	02c93c23          	sd	a2,56(s2) # 1038 <_entry-0x7fffefc8>
  return 0;
    80002144:	4501                	li	a0,0
}
    80002146:	60e2                	ld	ra,24(sp)
    80002148:	6442                	ld	s0,16(sp)
    8000214a:	64a2                	ld	s1,8(sp)
    8000214c:	6902                	ld	s2,0(sp)
    8000214e:	6105                	addi	sp,sp,32
    80002150:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80002152:	9e25                	addw	a2,a2,s1
    80002154:	1602                	slli	a2,a2,0x20
    80002156:	9201                	srli	a2,a2,0x20
    80002158:	1582                	slli	a1,a1,0x20
    8000215a:	9181                	srli	a1,a1,0x20
    8000215c:	6128                	ld	a0,64(a0)
    8000215e:	fffff097          	auipc	ra,0xfffff
    80002162:	342080e7          	jalr	834(ra) # 800014a0 <uvmalloc>
    80002166:	0005061b          	sext.w	a2,a0
    8000216a:	fa69                	bnez	a2,8000213c <growproc+0x26>
      return -1;
    8000216c:	557d                	li	a0,-1
    8000216e:	bfe1                	j	80002146 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002170:	9e25                	addw	a2,a2,s1
    80002172:	1602                	slli	a2,a2,0x20
    80002174:	9201                	srli	a2,a2,0x20
    80002176:	1582                	slli	a1,a1,0x20
    80002178:	9181                	srli	a1,a1,0x20
    8000217a:	6128                	ld	a0,64(a0)
    8000217c:	fffff097          	auipc	ra,0xfffff
    80002180:	2dc080e7          	jalr	732(ra) # 80001458 <uvmdealloc>
    80002184:	0005061b          	sext.w	a2,a0
    80002188:	bf55                	j	8000213c <growproc+0x26>

000000008000218a <fork>:
{
    8000218a:	7139                	addi	sp,sp,-64
    8000218c:	fc06                	sd	ra,56(sp)
    8000218e:	f822                	sd	s0,48(sp)
    80002190:	f426                	sd	s1,40(sp)
    80002192:	f04a                	sd	s2,32(sp)
    80002194:	ec4e                	sd	s3,24(sp)
    80002196:	e852                	sd	s4,16(sp)
    80002198:	e456                	sd	s5,8(sp)
    8000219a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000219c:	00000097          	auipc	ra,0x0
    800021a0:	96c080e7          	jalr	-1684(ra) # 80001b08 <myproc>
    800021a4:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    800021a6:	00000097          	auipc	ra,0x0
    800021aa:	9a2080e7          	jalr	-1630(ra) # 80001b48 <mykthread>
    800021ae:	84aa                	mv	s1,a0
  if((np = allocproc()) == 0){
    800021b0:	00000097          	auipc	ra,0x0
    800021b4:	ca0080e7          	jalr	-864(ra) # 80001e50 <allocproc>
    800021b8:	16050a63          	beqz	a0,8000232c <fork+0x1a2>
    800021bc:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800021be:	0389b603          	ld	a2,56(s3)
    800021c2:	612c                	ld	a1,64(a0)
    800021c4:	0409b503          	ld	a0,64(s3)
    800021c8:	fffff097          	auipc	ra,0xfffff
    800021cc:	424080e7          	jalr	1060(ra) # 800015ec <uvmcopy>
    800021d0:	04054763          	bltz	a0,8000221e <fork+0x94>
  np->sz = p->sz;
    800021d4:	0389b783          	ld	a5,56(s3)
    800021d8:	02f93c23          	sd	a5,56(s2)
  *(np_first_thread->trapframe) = *(t->trapframe);
    800021dc:	60b4                	ld	a3,64(s1)
    800021de:	87b6                	mv	a5,a3
    800021e0:	2c893703          	ld	a4,712(s2)
    800021e4:	12068693          	addi	a3,a3,288
    800021e8:	0007b803          	ld	a6,0(a5)
    800021ec:	6788                	ld	a0,8(a5)
    800021ee:	6b8c                	ld	a1,16(a5)
    800021f0:	6f90                	ld	a2,24(a5)
    800021f2:	01073023          	sd	a6,0(a4)
    800021f6:	e708                	sd	a0,8(a4)
    800021f8:	eb0c                	sd	a1,16(a4)
    800021fa:	ef10                	sd	a2,24(a4)
    800021fc:	02078793          	addi	a5,a5,32
    80002200:	02070713          	addi	a4,a4,32
    80002204:	fed792e3          	bne	a5,a3,800021e8 <fork+0x5e>
  np_first_thread->trapframe->a0 = 0;  // TODO: change reading the ret value from proc a0 to thread a0
    80002208:	2c893783          	ld	a5,712(s2)
    8000220c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002210:	05098493          	addi	s1,s3,80
    80002214:	05090a13          	addi	s4,s2,80
    80002218:	0d098a93          	addi	s5,s3,208
    8000221c:	a00d                	j	8000223e <fork+0xb4>
    freeproc(np);
    8000221e:	854a                	mv	a0,s2
    80002220:	00000097          	auipc	ra,0x0
    80002224:	b94080e7          	jalr	-1132(ra) # 80001db4 <freeproc>
    release(&np->lock);
    80002228:	854a                	mv	a0,s2
    8000222a:	fffff097          	auipc	ra,0xfffff
    8000222e:	a66080e7          	jalr	-1434(ra) # 80000c90 <release>
    return -1;
    80002232:	5afd                	li	s5,-1
    80002234:	a0d5                	j	80002318 <fork+0x18e>
  for(i = 0; i < NOFILE; i++)
    80002236:	04a1                	addi	s1,s1,8
    80002238:	0a21                	addi	s4,s4,8
    8000223a:	01548b63          	beq	s1,s5,80002250 <fork+0xc6>
    if(p->ofile[i])
    8000223e:	6088                	ld	a0,0(s1)
    80002240:	d97d                	beqz	a0,80002236 <fork+0xac>
      np->ofile[i] = filedup(p->ofile[i]);
    80002242:	00003097          	auipc	ra,0x3
    80002246:	2f4080e7          	jalr	756(ra) # 80005536 <filedup>
    8000224a:	00aa3023          	sd	a0,0(s4)
    8000224e:	b7e5                	j	80002236 <fork+0xac>
  np->cwd = idup(p->cwd);
    80002250:	0d09b503          	ld	a0,208(s3)
    80002254:	00002097          	auipc	ra,0x2
    80002258:	456080e7          	jalr	1110(ra) # 800046aa <idup>
    8000225c:	0ca93823          	sd	a0,208(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002260:	4641                	li	a2,16
    80002262:	0d898593          	addi	a1,s3,216
    80002266:	0d890513          	addi	a0,s2,216
    8000226a:	fffff097          	auipc	ra,0xfffff
    8000226e:	bc0080e7          	jalr	-1088(ra) # 80000e2a <safestrcpy>
  np->signal_mask = p->signal_mask;
    80002272:	0ec9a783          	lw	a5,236(s3)
    80002276:	0ef92623          	sw	a5,236(s2)
  for(int i=0;i<32;i++){
    8000227a:	0f898693          	addi	a3,s3,248
    8000227e:	0f890713          	addi	a4,s2,248
  np->signal_mask = p->signal_mask;
    80002282:	1f800793          	li	a5,504
  for(int i=0;i<32;i++){
    80002286:	27800513          	li	a0,632
    np->signal_handlers[i] = p->signal_handlers[i];
    8000228a:	6290                	ld	a2,0(a3)
    8000228c:	e310                	sd	a2,0(a4)
    np->handlers_sigmasks[i] = p->handlers_sigmasks[i];
    8000228e:	00f98633          	add	a2,s3,a5
    80002292:	420c                	lw	a1,0(a2)
    80002294:	00f90633          	add	a2,s2,a5
    80002298:	c20c                	sw	a1,0(a2)
  for(int i=0;i<32;i++){
    8000229a:	06a1                	addi	a3,a3,8
    8000229c:	0721                	addi	a4,a4,8
    8000229e:	0791                	addi	a5,a5,4
    800022a0:	fea795e3          	bne	a5,a0,8000228a <fork+0x100>
  np-> pending_signals=0;
    800022a4:	0e092423          	sw	zero,232(s2)
  pid = np->pid;
    800022a8:	02492a83          	lw	s5,36(s2)
  release(&np_first_thread->lock);
    800022ac:	28890493          	addi	s1,s2,648
    800022b0:	8526                	mv	a0,s1
    800022b2:	fffff097          	auipc	ra,0xfffff
    800022b6:	9de080e7          	jalr	-1570(ra) # 80000c90 <release>
  release(&np->lock);
    800022ba:	854a                	mv	a0,s2
    800022bc:	fffff097          	auipc	ra,0xfffff
    800022c0:	9d4080e7          	jalr	-1580(ra) # 80000c90 <release>
  acquire(&wait_lock);
    800022c4:	0000fa17          	auipc	s4,0xf
    800022c8:	00ca0a13          	addi	s4,s4,12 # 800112d0 <wait_lock>
    800022cc:	8552                	mv	a0,s4
    800022ce:	fffff097          	auipc	ra,0xfffff
    800022d2:	8f8080e7          	jalr	-1800(ra) # 80000bc6 <acquire>
  np->parent = p;
    800022d6:	03393823          	sd	s3,48(s2)
  release(&wait_lock);
    800022da:	8552                	mv	a0,s4
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	9b4080e7          	jalr	-1612(ra) # 80000c90 <release>
  acquire(&np->lock);
    800022e4:	854a                	mv	a0,s2
    800022e6:	fffff097          	auipc	ra,0xfffff
    800022ea:	8e0080e7          	jalr	-1824(ra) # 80000bc6 <acquire>
  acquire(&np_first_thread->lock);
    800022ee:	8526                	mv	a0,s1
    800022f0:	fffff097          	auipc	ra,0xfffff
    800022f4:	8d6080e7          	jalr	-1834(ra) # 80000bc6 <acquire>
  np->state = RUNNABLE;   //TOOD: check if we still need this state or should change
    800022f8:	4789                	li	a5,2
    800022fa:	00f92c23          	sw	a5,24(s2)
  np_first_thread->state = TRUNNABLE;
    800022fe:	478d                	li	a5,3
    80002300:	2af92023          	sw	a5,672(s2)
  release(&np_first_thread->lock);
    80002304:	8526                	mv	a0,s1
    80002306:	fffff097          	auipc	ra,0xfffff
    8000230a:	98a080e7          	jalr	-1654(ra) # 80000c90 <release>
  release(&np->lock);
    8000230e:	854a                	mv	a0,s2
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	980080e7          	jalr	-1664(ra) # 80000c90 <release>
}
    80002318:	8556                	mv	a0,s5
    8000231a:	70e2                	ld	ra,56(sp)
    8000231c:	7442                	ld	s0,48(sp)
    8000231e:	74a2                	ld	s1,40(sp)
    80002320:	7902                	ld	s2,32(sp)
    80002322:	69e2                	ld	s3,24(sp)
    80002324:	6a42                	ld	s4,16(sp)
    80002326:	6aa2                	ld	s5,8(sp)
    80002328:	6121                	addi	sp,sp,64
    8000232a:	8082                	ret
    return -1;
    8000232c:	5afd                	li	s5,-1
    8000232e:	b7ed                	j	80002318 <fork+0x18e>

0000000080002330 <scheduler>:
{
    80002330:	711d                	addi	sp,sp,-96
    80002332:	ec86                	sd	ra,88(sp)
    80002334:	e8a2                	sd	s0,80(sp)
    80002336:	e4a6                	sd	s1,72(sp)
    80002338:	e0ca                	sd	s2,64(sp)
    8000233a:	fc4e                	sd	s3,56(sp)
    8000233c:	f852                	sd	s4,48(sp)
    8000233e:	f456                	sd	s5,40(sp)
    80002340:	f05a                	sd	s6,32(sp)
    80002342:	ec5e                	sd	s7,24(sp)
    80002344:	e862                	sd	s8,16(sp)
    80002346:	e466                	sd	s9,8(sp)
    80002348:	1080                	addi	s0,sp,96
    8000234a:	8492                	mv	s1,tp
  int id = r_tp();
    8000234c:	2481                	sext.w	s1,s1
    8000234e:	8592                	mv	a1,tp
  printf("cpu %d\n,",cpuid());
    80002350:	2581                	sext.w	a1,a1
    80002352:	00006517          	auipc	a0,0x6
    80002356:	09650513          	addi	a0,a0,150 # 800083e8 <digits+0x3a8>
    8000235a:	ffffe097          	auipc	ra,0xffffe
    8000235e:	21e080e7          	jalr	542(ra) # 80000578 <printf>
  c->proc = 0;
    80002362:	00449793          	slli	a5,s1,0x4
    80002366:	00978733          	add	a4,a5,s1
    8000236a:	00371693          	slli	a3,a4,0x3
    8000236e:	0000f717          	auipc	a4,0xf
    80002372:	f3270713          	addi	a4,a4,-206 # 800112a0 <pid_lock>
    80002376:	9736                	add	a4,a4,a3
    80002378:	04073423          	sd	zero,72(a4)
  c->kthread=0;
    8000237c:	0c073423          	sd	zero,200(a4)
            swtch(&c->context, &t->context);
    80002380:	0000f797          	auipc	a5,0xf
    80002384:	f7078793          	addi	a5,a5,-144 # 800112f0 <cpus+0x8>
    80002388:	00f68bb3          	add	s7,a3,a5
            c->proc = p;
    8000238c:	8b3a                	mv	s6,a4
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    8000238e:	6985                	lui	s3,0x1
    80002390:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    printf("before intr_on\n");
    80002394:	00006517          	auipc	a0,0x6
    80002398:	06450513          	addi	a0,a0,100 # 800083f8 <digits+0x3b8>
    8000239c:	ffffe097          	auipc	ra,0xffffe
    800023a0:	1dc080e7          	jalr	476(ra) # 80000578 <printf>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023a4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800023a8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023ac:	10079073          	csrw	sstatus,a5
    printf("int_on\n");
    800023b0:	00006517          	auipc	a0,0x6
    800023b4:	05850513          	addi	a0,a0,88 # 80008408 <digits+0x3c8>
    800023b8:	ffffe097          	auipc	ra,0xffffe
    800023bc:	1c0080e7          	jalr	448(ra) # 80000578 <printf>
    for(p = proc; p < &proc[NPROC]; p++) {
    800023c0:	0000f917          	auipc	s2,0xf
    800023c4:	36890913          	addi	s2,s2,872 # 80011728 <proc>
    800023c8:	a095                	j	8000242c <scheduler+0xfc>
          release(&t->lock);
    800023ca:	8526                	mv	a0,s1
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	8c4080e7          	jalr	-1852(ra) # 80000c90 <release>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    800023d4:	0b848493          	addi	s1,s1,184
    800023d8:	05448363          	beq	s1,s4,8000241e <scheduler+0xee>
          acquire(&t->lock);
    800023dc:	8526                	mv	a0,s1
    800023de:	ffffe097          	auipc	ra,0xffffe
    800023e2:	7e8080e7          	jalr	2024(ra) # 80000bc6 <acquire>
          if(t->state == TRUNNABLE && !t->frozen) {
    800023e6:	4c9c                	lw	a5,24(s1)
    800023e8:	ff5791e3          	bne	a5,s5,800023ca <scheduler+0x9a>
    800023ec:	58dc                	lw	a5,52(s1)
    800023ee:	fff1                	bnez	a5,800023ca <scheduler+0x9a>
            printf("found runnable\n");
    800023f0:	8566                	mv	a0,s9
    800023f2:	ffffe097          	auipc	ra,0xffffe
    800023f6:	186080e7          	jalr	390(ra) # 80000578 <printf>
            t->state = TRUNNING;
    800023fa:	4791                	li	a5,4
    800023fc:	cc9c                	sw	a5,24(s1)
            c->proc = p;
    800023fe:	052b3423          	sd	s2,72(s6)
            c->kthread = t;
    80002402:	0c9b3423          	sd	s1,200(s6)
            swtch(&c->context, &t->context);
    80002406:	04848593          	addi	a1,s1,72
    8000240a:	855e                	mv	a0,s7
    8000240c:	00001097          	auipc	ra,0x1
    80002410:	d20080e7          	jalr	-736(ra) # 8000312c <swtch>
            c->proc = 0;
    80002414:	040b3423          	sd	zero,72(s6)
            c->kthread=0;
    80002418:	0c0b3423          	sd	zero,200(s6)
    8000241c:	b77d                	j	800023ca <scheduler+0x9a>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000241e:	994e                	add	s2,s2,s3
    80002420:	00030797          	auipc	a5,0x30
    80002424:	50878793          	addi	a5,a5,1288 # 80032928 <tickslock>
    80002428:	f6f906e3          	beq	s2,a5,80002394 <scheduler+0x64>
      if(p->state == RUNNABLE) {
    8000242c:	01892703          	lw	a4,24(s2)
    80002430:	4789                	li	a5,2
    80002432:	fef716e3          	bne	a4,a5,8000241e <scheduler+0xee>
        printf("p %d is runnable\n",p->pid);
    80002436:	02492583          	lw	a1,36(s2)
    8000243a:	00006517          	auipc	a0,0x6
    8000243e:	fd650513          	addi	a0,a0,-42 # 80008410 <digits+0x3d0>
    80002442:	ffffe097          	auipc	ra,0xffffe
    80002446:	136080e7          	jalr	310(ra) # 80000578 <printf>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    8000244a:	28890493          	addi	s1,s2,648
          if(t->state == TRUNNABLE && !t->frozen) {
    8000244e:	4a8d                	li	s5,3
            printf("found runnable\n");
    80002450:	00006c97          	auipc	s9,0x6
    80002454:	fd8c8c93          	addi	s9,s9,-40 # 80008428 <digits+0x3e8>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002458:	01390a33          	add	s4,s2,s3
    8000245c:	b741                	j	800023dc <scheduler+0xac>

000000008000245e <sched>:
{
    8000245e:	7179                	addi	sp,sp,-48
    80002460:	f406                	sd	ra,40(sp)
    80002462:	f022                	sd	s0,32(sp)
    80002464:	ec26                	sd	s1,24(sp)
    80002466:	e84a                	sd	s2,16(sp)
    80002468:	e44e                	sd	s3,8(sp)
    8000246a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	69c080e7          	jalr	1692(ra) # 80001b08 <myproc>
  struct kthread *t=mykthread();
    80002474:	fffff097          	auipc	ra,0xfffff
    80002478:	6d4080e7          	jalr	1748(ra) # 80001b48 <mykthread>
    8000247c:	84aa                	mv	s1,a0
  if(!holding(&t->lock))
    8000247e:	ffffe097          	auipc	ra,0xffffe
    80002482:	6ce080e7          	jalr	1742(ra) # 80000b4c <holding>
    80002486:	c959                	beqz	a0,8000251c <sched+0xbe>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002488:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000248a:	0007871b          	sext.w	a4,a5
    8000248e:	00471793          	slli	a5,a4,0x4
    80002492:	97ba                	add	a5,a5,a4
    80002494:	078e                	slli	a5,a5,0x3
    80002496:	0000f717          	auipc	a4,0xf
    8000249a:	e0a70713          	addi	a4,a4,-502 # 800112a0 <pid_lock>
    8000249e:	97ba                	add	a5,a5,a4
    800024a0:	0c07a703          	lw	a4,192(a5)
    800024a4:	4785                	li	a5,1
    800024a6:	08f71363          	bne	a4,a5,8000252c <sched+0xce>
  if(t->state == TRUNNING)
    800024aa:	4c98                	lw	a4,24(s1)
    800024ac:	4791                	li	a5,4
    800024ae:	08f70763          	beq	a4,a5,8000253c <sched+0xde>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024b2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800024b6:	8b89                	andi	a5,a5,2
  if(intr_get())
    800024b8:	ebd1                	bnez	a5,8000254c <sched+0xee>
  asm volatile("mv %0, tp" : "=r" (x) );
    800024ba:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800024bc:	0000f917          	auipc	s2,0xf
    800024c0:	de490913          	addi	s2,s2,-540 # 800112a0 <pid_lock>
    800024c4:	0007871b          	sext.w	a4,a5
    800024c8:	00471793          	slli	a5,a4,0x4
    800024cc:	97ba                	add	a5,a5,a4
    800024ce:	078e                	slli	a5,a5,0x3
    800024d0:	97ca                	add	a5,a5,s2
    800024d2:	0c47a983          	lw	s3,196(a5)
    800024d6:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    800024d8:	0007859b          	sext.w	a1,a5
    800024dc:	00459793          	slli	a5,a1,0x4
    800024e0:	97ae                	add	a5,a5,a1
    800024e2:	078e                	slli	a5,a5,0x3
    800024e4:	0000f597          	auipc	a1,0xf
    800024e8:	e0c58593          	addi	a1,a1,-500 # 800112f0 <cpus+0x8>
    800024ec:	95be                	add	a1,a1,a5
    800024ee:	04848513          	addi	a0,s1,72
    800024f2:	00001097          	auipc	ra,0x1
    800024f6:	c3a080e7          	jalr	-966(ra) # 8000312c <swtch>
    800024fa:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800024fc:	0007871b          	sext.w	a4,a5
    80002500:	00471793          	slli	a5,a4,0x4
    80002504:	97ba                	add	a5,a5,a4
    80002506:	078e                	slli	a5,a5,0x3
    80002508:	97ca                	add	a5,a5,s2
    8000250a:	0d37a223          	sw	s3,196(a5)
}
    8000250e:	70a2                	ld	ra,40(sp)
    80002510:	7402                	ld	s0,32(sp)
    80002512:	64e2                	ld	s1,24(sp)
    80002514:	6942                	ld	s2,16(sp)
    80002516:	69a2                	ld	s3,8(sp)
    80002518:	6145                	addi	sp,sp,48
    8000251a:	8082                	ret
    panic("sched t->lock");
    8000251c:	00006517          	auipc	a0,0x6
    80002520:	f1c50513          	addi	a0,a0,-228 # 80008438 <digits+0x3f8>
    80002524:	ffffe097          	auipc	ra,0xffffe
    80002528:	00a080e7          	jalr	10(ra) # 8000052e <panic>
    panic("sched locks");
    8000252c:	00006517          	auipc	a0,0x6
    80002530:	f1c50513          	addi	a0,a0,-228 # 80008448 <digits+0x408>
    80002534:	ffffe097          	auipc	ra,0xffffe
    80002538:	ffa080e7          	jalr	-6(ra) # 8000052e <panic>
    panic("sched running");
    8000253c:	00006517          	auipc	a0,0x6
    80002540:	f1c50513          	addi	a0,a0,-228 # 80008458 <digits+0x418>
    80002544:	ffffe097          	auipc	ra,0xffffe
    80002548:	fea080e7          	jalr	-22(ra) # 8000052e <panic>
    panic("sched interruptible");
    8000254c:	00006517          	auipc	a0,0x6
    80002550:	f1c50513          	addi	a0,a0,-228 # 80008468 <digits+0x428>
    80002554:	ffffe097          	auipc	ra,0xffffe
    80002558:	fda080e7          	jalr	-38(ra) # 8000052e <panic>

000000008000255c <yield>:
{
    8000255c:	1101                	addi	sp,sp,-32
    8000255e:	ec06                	sd	ra,24(sp)
    80002560:	e822                	sd	s0,16(sp)
    80002562:	e426                	sd	s1,8(sp)
    80002564:	1000                	addi	s0,sp,32
  struct kthread *t =mykthread();
    80002566:	fffff097          	auipc	ra,0xfffff
    8000256a:	5e2080e7          	jalr	1506(ra) # 80001b48 <mykthread>
    8000256e:	84aa                	mv	s1,a0
  acquire(&t->lock);
    80002570:	ffffe097          	auipc	ra,0xffffe
    80002574:	656080e7          	jalr	1622(ra) # 80000bc6 <acquire>
  t->state = TRUNNABLE;
    80002578:	478d                	li	a5,3
    8000257a:	cc9c                	sw	a5,24(s1)
  sched();
    8000257c:	00000097          	auipc	ra,0x0
    80002580:	ee2080e7          	jalr	-286(ra) # 8000245e <sched>
  release(&t->lock);
    80002584:	8526                	mv	a0,s1
    80002586:	ffffe097          	auipc	ra,0xffffe
    8000258a:	70a080e7          	jalr	1802(ra) # 80000c90 <release>
}
    8000258e:	60e2                	ld	ra,24(sp)
    80002590:	6442                	ld	s0,16(sp)
    80002592:	64a2                	ld	s1,8(sp)
    80002594:	6105                	addi	sp,sp,32
    80002596:	8082                	ret

0000000080002598 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002598:	7179                	addi	sp,sp,-48
    8000259a:	f406                	sd	ra,40(sp)
    8000259c:	f022                	sd	s0,32(sp)
    8000259e:	ec26                	sd	s1,24(sp)
    800025a0:	e84a                	sd	s2,16(sp)
    800025a2:	e44e                	sd	s3,8(sp)
    800025a4:	1800                	addi	s0,sp,48
    800025a6:	89aa                	mv	s3,a0
    800025a8:	892e                	mv	s2,a1
  // struct proc *p = myproc();
  struct kthread *t=mykthread();
    800025aa:	fffff097          	auipc	ra,0xfffff
    800025ae:	59e080e7          	jalr	1438(ra) # 80001b48 <mykthread>
    800025b2:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&t->lock);  //DOC: sleeplock1
    800025b4:	ffffe097          	auipc	ra,0xffffe
    800025b8:	612080e7          	jalr	1554(ra) # 80000bc6 <acquire>
  release(lk);
    800025bc:	854a                	mv	a0,s2
    800025be:	ffffe097          	auipc	ra,0xffffe
    800025c2:	6d2080e7          	jalr	1746(ra) # 80000c90 <release>

  // Go to sleep.
  t->chan = chan;
    800025c6:	0334b023          	sd	s3,32(s1)
  t->state = TSLEEPING;
    800025ca:	4789                	li	a5,2
    800025cc:	cc9c                	sw	a5,24(s1)

  sched();
    800025ce:	00000097          	auipc	ra,0x0
    800025d2:	e90080e7          	jalr	-368(ra) # 8000245e <sched>

  // Tidy up.
  t->chan = 0;
    800025d6:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&t->lock);
    800025da:	8526                	mv	a0,s1
    800025dc:	ffffe097          	auipc	ra,0xffffe
    800025e0:	6b4080e7          	jalr	1716(ra) # 80000c90 <release>
  acquire(lk);
    800025e4:	854a                	mv	a0,s2
    800025e6:	ffffe097          	auipc	ra,0xffffe
    800025ea:	5e0080e7          	jalr	1504(ra) # 80000bc6 <acquire>
}
    800025ee:	70a2                	ld	ra,40(sp)
    800025f0:	7402                	ld	s0,32(sp)
    800025f2:	64e2                	ld	s1,24(sp)
    800025f4:	6942                	ld	s2,16(sp)
    800025f6:	69a2                	ld	s3,8(sp)
    800025f8:	6145                	addi	sp,sp,48
    800025fa:	8082                	ret

00000000800025fc <wait>:
{
    800025fc:	715d                	addi	sp,sp,-80
    800025fe:	e486                	sd	ra,72(sp)
    80002600:	e0a2                	sd	s0,64(sp)
    80002602:	fc26                	sd	s1,56(sp)
    80002604:	f84a                	sd	s2,48(sp)
    80002606:	f44e                	sd	s3,40(sp)
    80002608:	f052                	sd	s4,32(sp)
    8000260a:	ec56                	sd	s5,24(sp)
    8000260c:	e85a                	sd	s6,16(sp)
    8000260e:	e45e                	sd	s7,8(sp)
    80002610:	0880                	addi	s0,sp,80
    80002612:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002614:	fffff097          	auipc	ra,0xfffff
    80002618:	4f4080e7          	jalr	1268(ra) # 80001b08 <myproc>
    8000261c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000261e:	0000f517          	auipc	a0,0xf
    80002622:	cb250513          	addi	a0,a0,-846 # 800112d0 <wait_lock>
    80002626:	ffffe097          	auipc	ra,0xffffe
    8000262a:	5a0080e7          	jalr	1440(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    8000262e:	4b0d                	li	s6,3
        havekids = 1;
    80002630:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002632:	6985                	lui	s3,0x1
    80002634:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002638:	00030a17          	auipc	s4,0x30
    8000263c:	2f0a0a13          	addi	s4,s4,752 # 80032928 <tickslock>
    havekids = 0;
    80002640:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    80002642:	0000f497          	auipc	s1,0xf
    80002646:	0e648493          	addi	s1,s1,230 # 80011728 <proc>
    8000264a:	a0b5                	j	800026b6 <wait+0xba>
          pid = np->pid;
    8000264c:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002650:	000b8e63          	beqz	s7,8000266c <wait+0x70>
    80002654:	4691                	li	a3,4
    80002656:	02048613          	addi	a2,s1,32
    8000265a:	85de                	mv	a1,s7
    8000265c:	04093503          	ld	a0,64(s2)
    80002660:	fffff097          	auipc	ra,0xfffff
    80002664:	090080e7          	jalr	144(ra) # 800016f0 <copyout>
    80002668:	02054563          	bltz	a0,80002692 <wait+0x96>
          freeproc(np);
    8000266c:	8526                	mv	a0,s1
    8000266e:	fffff097          	auipc	ra,0xfffff
    80002672:	746080e7          	jalr	1862(ra) # 80001db4 <freeproc>
          release(&np->lock);
    80002676:	8526                	mv	a0,s1
    80002678:	ffffe097          	auipc	ra,0xffffe
    8000267c:	618080e7          	jalr	1560(ra) # 80000c90 <release>
          release(&wait_lock);
    80002680:	0000f517          	auipc	a0,0xf
    80002684:	c5050513          	addi	a0,a0,-944 # 800112d0 <wait_lock>
    80002688:	ffffe097          	auipc	ra,0xffffe
    8000268c:	608080e7          	jalr	1544(ra) # 80000c90 <release>
          return pid;
    80002690:	a09d                	j	800026f6 <wait+0xfa>
            release(&np->lock);
    80002692:	8526                	mv	a0,s1
    80002694:	ffffe097          	auipc	ra,0xffffe
    80002698:	5fc080e7          	jalr	1532(ra) # 80000c90 <release>
            release(&wait_lock);
    8000269c:	0000f517          	auipc	a0,0xf
    800026a0:	c3450513          	addi	a0,a0,-972 # 800112d0 <wait_lock>
    800026a4:	ffffe097          	auipc	ra,0xffffe
    800026a8:	5ec080e7          	jalr	1516(ra) # 80000c90 <release>
            return -1;
    800026ac:	59fd                	li	s3,-1
    800026ae:	a0a1                	j	800026f6 <wait+0xfa>
    for(np = proc; np < &proc[NPROC]; np++){
    800026b0:	94ce                	add	s1,s1,s3
    800026b2:	03448463          	beq	s1,s4,800026da <wait+0xde>
      if(np->parent == p){
    800026b6:	789c                	ld	a5,48(s1)
    800026b8:	ff279ce3          	bne	a5,s2,800026b0 <wait+0xb4>
        acquire(&np->lock);
    800026bc:	8526                	mv	a0,s1
    800026be:	ffffe097          	auipc	ra,0xffffe
    800026c2:	508080e7          	jalr	1288(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    800026c6:	4c9c                	lw	a5,24(s1)
    800026c8:	f96782e3          	beq	a5,s6,8000264c <wait+0x50>
        release(&np->lock);
    800026cc:	8526                	mv	a0,s1
    800026ce:	ffffe097          	auipc	ra,0xffffe
    800026d2:	5c2080e7          	jalr	1474(ra) # 80000c90 <release>
        havekids = 1;
    800026d6:	8756                	mv	a4,s5
    800026d8:	bfe1                	j	800026b0 <wait+0xb4>
    if(!havekids || p->killed==1){
    800026da:	c709                	beqz	a4,800026e4 <wait+0xe8>
    800026dc:	01c92783          	lw	a5,28(s2)
    800026e0:	03579763          	bne	a5,s5,8000270e <wait+0x112>
      release(&wait_lock);
    800026e4:	0000f517          	auipc	a0,0xf
    800026e8:	bec50513          	addi	a0,a0,-1044 # 800112d0 <wait_lock>
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	5a4080e7          	jalr	1444(ra) # 80000c90 <release>
      return -1;
    800026f4:	59fd                	li	s3,-1
}
    800026f6:	854e                	mv	a0,s3
    800026f8:	60a6                	ld	ra,72(sp)
    800026fa:	6406                	ld	s0,64(sp)
    800026fc:	74e2                	ld	s1,56(sp)
    800026fe:	7942                	ld	s2,48(sp)
    80002700:	79a2                	ld	s3,40(sp)
    80002702:	7a02                	ld	s4,32(sp)
    80002704:	6ae2                	ld	s5,24(sp)
    80002706:	6b42                	ld	s6,16(sp)
    80002708:	6ba2                	ld	s7,8(sp)
    8000270a:	6161                	addi	sp,sp,80
    8000270c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000270e:	0000f597          	auipc	a1,0xf
    80002712:	bc258593          	addi	a1,a1,-1086 # 800112d0 <wait_lock>
    80002716:	854a                	mv	a0,s2
    80002718:	00000097          	auipc	ra,0x0
    8000271c:	e80080e7          	jalr	-384(ra) # 80002598 <sleep>
    havekids = 0;
    80002720:	b705                	j	80002640 <wait+0x44>

0000000080002722 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002722:	711d                	addi	sp,sp,-96
    80002724:	ec86                	sd	ra,88(sp)
    80002726:	e8a2                	sd	s0,80(sp)
    80002728:	e4a6                	sd	s1,72(sp)
    8000272a:	e0ca                	sd	s2,64(sp)
    8000272c:	fc4e                	sd	s3,56(sp)
    8000272e:	f852                	sd	s4,48(sp)
    80002730:	f456                	sd	s5,40(sp)
    80002732:	f05a                	sd	s6,32(sp)
    80002734:	ec5e                	sd	s7,24(sp)
    80002736:	e862                	sd	s8,16(sp)
    80002738:	e466                	sd	s9,8(sp)
    8000273a:	1080                	addi	s0,sp,96
    8000273c:	8c2a                	mv	s8,a0
  struct proc *p;
  struct kthread *t;
  struct kthread *my_t = mykthread();
    8000273e:	fffff097          	auipc	ra,0xfffff
    80002742:	40a080e7          	jalr	1034(ra) # 80001b48 <mykthread>
    80002746:	8aaa                	mv	s5,a0

  for(p = proc; p < &proc[NPROC]; p++) {
    80002748:	0000f917          	auipc	s2,0xf
    8000274c:	26890913          	addi	s2,s2,616 # 800119b0 <proc+0x288>
    80002750:	00030b97          	auipc	s7,0x30
    80002754:	460b8b93          	addi	s7,s7,1120 # 80032bb0 <bcache+0x270>
    if(p->state == RUNNABLE){
    80002758:	4989                	li	s3,2
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
        if(t != my_t){
          acquire(&t->lock);
          if(t->state == TSLEEPING && t->chan == chan) {
            t->state = TRUNNABLE;
    8000275a:	4c8d                	li	s9,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000275c:	6b05                	lui	s6,0x1
    8000275e:	848b0b13          	addi	s6,s6,-1976 # 848 <_entry-0x7ffff7b8>
    80002762:	a82d                	j	8000279c <wakeup+0x7a>
          }
          release(&t->lock);
    80002764:	8526                	mv	a0,s1
    80002766:	ffffe097          	auipc	ra,0xffffe
    8000276a:	52a080e7          	jalr	1322(ra) # 80000c90 <release>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    8000276e:	0b848493          	addi	s1,s1,184
    80002772:	03448263          	beq	s1,s4,80002796 <wakeup+0x74>
        if(t != my_t){
    80002776:	fe9a8ce3          	beq	s5,s1,8000276e <wakeup+0x4c>
          acquire(&t->lock);
    8000277a:	8526                	mv	a0,s1
    8000277c:	ffffe097          	auipc	ra,0xffffe
    80002780:	44a080e7          	jalr	1098(ra) # 80000bc6 <acquire>
          if(t->state == TSLEEPING && t->chan == chan) {
    80002784:	4c9c                	lw	a5,24(s1)
    80002786:	fd379fe3          	bne	a5,s3,80002764 <wakeup+0x42>
    8000278a:	709c                	ld	a5,32(s1)
    8000278c:	fd879ce3          	bne	a5,s8,80002764 <wakeup+0x42>
            t->state = TRUNNABLE;
    80002790:	0194ac23          	sw	s9,24(s1)
    80002794:	bfc1                	j	80002764 <wakeup+0x42>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002796:	995a                	add	s2,s2,s6
    80002798:	01790a63          	beq	s2,s7,800027ac <wakeup+0x8a>
    if(p->state == RUNNABLE){
    8000279c:	84ca                	mv	s1,s2
    8000279e:	d9092783          	lw	a5,-624(s2)
    800027a2:	ff379ae3          	bne	a5,s3,80002796 <wakeup+0x74>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800027a6:	5c090a13          	addi	s4,s2,1472
    800027aa:	b7f1                	j	80002776 <wakeup+0x54>
        }
      }
    }
  }
}
    800027ac:	60e6                	ld	ra,88(sp)
    800027ae:	6446                	ld	s0,80(sp)
    800027b0:	64a6                	ld	s1,72(sp)
    800027b2:	6906                	ld	s2,64(sp)
    800027b4:	79e2                	ld	s3,56(sp)
    800027b6:	7a42                	ld	s4,48(sp)
    800027b8:	7aa2                	ld	s5,40(sp)
    800027ba:	7b02                	ld	s6,32(sp)
    800027bc:	6be2                	ld	s7,24(sp)
    800027be:	6c42                	ld	s8,16(sp)
    800027c0:	6ca2                	ld	s9,8(sp)
    800027c2:	6125                	addi	sp,sp,96
    800027c4:	8082                	ret

00000000800027c6 <reparent>:
{
    800027c6:	7139                	addi	sp,sp,-64
    800027c8:	fc06                	sd	ra,56(sp)
    800027ca:	f822                	sd	s0,48(sp)
    800027cc:	f426                	sd	s1,40(sp)
    800027ce:	f04a                	sd	s2,32(sp)
    800027d0:	ec4e                	sd	s3,24(sp)
    800027d2:	e852                	sd	s4,16(sp)
    800027d4:	e456                	sd	s5,8(sp)
    800027d6:	0080                	addi	s0,sp,64
    800027d8:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800027da:	0000f497          	auipc	s1,0xf
    800027de:	f4e48493          	addi	s1,s1,-178 # 80011728 <proc>
      pp->parent = initproc;
    800027e2:	00007a97          	auipc	s5,0x7
    800027e6:	846a8a93          	addi	s5,s5,-1978 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800027ea:	6905                	lui	s2,0x1
    800027ec:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    800027f0:	00030a17          	auipc	s4,0x30
    800027f4:	138a0a13          	addi	s4,s4,312 # 80032928 <tickslock>
    800027f8:	a021                	j	80002800 <reparent+0x3a>
    800027fa:	94ca                	add	s1,s1,s2
    800027fc:	01448d63          	beq	s1,s4,80002816 <reparent+0x50>
    if(pp->parent == p){
    80002800:	789c                	ld	a5,48(s1)
    80002802:	ff379ce3          	bne	a5,s3,800027fa <reparent+0x34>
      pp->parent = initproc;
    80002806:	000ab503          	ld	a0,0(s5)
    8000280a:	f888                	sd	a0,48(s1)
      wakeup(initproc);
    8000280c:	00000097          	auipc	ra,0x0
    80002810:	f16080e7          	jalr	-234(ra) # 80002722 <wakeup>
    80002814:	b7dd                	j	800027fa <reparent+0x34>
}
    80002816:	70e2                	ld	ra,56(sp)
    80002818:	7442                	ld	s0,48(sp)
    8000281a:	74a2                	ld	s1,40(sp)
    8000281c:	7902                	ld	s2,32(sp)
    8000281e:	69e2                	ld	s3,24(sp)
    80002820:	6a42                	ld	s4,16(sp)
    80002822:	6aa2                	ld	s5,8(sp)
    80002824:	6121                	addi	sp,sp,64
    80002826:	8082                	ret

0000000080002828 <exit_proccess>:
{
    80002828:	7139                	addi	sp,sp,-64
    8000282a:	fc06                	sd	ra,56(sp)
    8000282c:	f822                	sd	s0,48(sp)
    8000282e:	f426                	sd	s1,40(sp)
    80002830:	f04a                	sd	s2,32(sp)
    80002832:	ec4e                	sd	s3,24(sp)
    80002834:	e852                	sd	s4,16(sp)
    80002836:	e456                	sd	s5,8(sp)
    80002838:	0080                	addi	s0,sp,64
    8000283a:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    8000283c:	fffff097          	auipc	ra,0xfffff
    80002840:	2cc080e7          	jalr	716(ra) # 80001b08 <myproc>
    80002844:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    80002846:	fffff097          	auipc	ra,0xfffff
    8000284a:	302080e7          	jalr	770(ra) # 80001b48 <mykthread>
    8000284e:	8a2a                	mv	s4,a0
  if(p == initproc)
    80002850:	00006797          	auipc	a5,0x6
    80002854:	7d87b783          	ld	a5,2008(a5) # 80009028 <initproc>
    80002858:	05098493          	addi	s1,s3,80
    8000285c:	0d098913          	addi	s2,s3,208
    80002860:	03379363          	bne	a5,s3,80002886 <exit_proccess+0x5e>
    panic("init exiting");
    80002864:	00006517          	auipc	a0,0x6
    80002868:	c1c50513          	addi	a0,a0,-996 # 80008480 <digits+0x440>
    8000286c:	ffffe097          	auipc	ra,0xffffe
    80002870:	cc2080e7          	jalr	-830(ra) # 8000052e <panic>
      fileclose(f);
    80002874:	00003097          	auipc	ra,0x3
    80002878:	d14080e7          	jalr	-748(ra) # 80005588 <fileclose>
      p->ofile[fd] = 0;
    8000287c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002880:	04a1                	addi	s1,s1,8
    80002882:	01248563          	beq	s1,s2,8000288c <exit_proccess+0x64>
    if(p->ofile[fd]){
    80002886:	6088                	ld	a0,0(s1)
    80002888:	f575                	bnez	a0,80002874 <exit_proccess+0x4c>
    8000288a:	bfdd                	j	80002880 <exit_proccess+0x58>
  begin_op();
    8000288c:	00003097          	auipc	ra,0x3
    80002890:	830080e7          	jalr	-2000(ra) # 800050bc <begin_op>
  iput(p->cwd);
    80002894:	0d09b503          	ld	a0,208(s3)
    80002898:	00002097          	auipc	ra,0x2
    8000289c:	00a080e7          	jalr	10(ra) # 800048a2 <iput>
  end_op();
    800028a0:	00003097          	auipc	ra,0x3
    800028a4:	89c080e7          	jalr	-1892(ra) # 8000513c <end_op>
  p->cwd = 0;
    800028a8:	0c09b823          	sd	zero,208(s3)
  acquire(&wait_lock);
    800028ac:	0000f497          	auipc	s1,0xf
    800028b0:	a2448493          	addi	s1,s1,-1500 # 800112d0 <wait_lock>
    800028b4:	8526                	mv	a0,s1
    800028b6:	ffffe097          	auipc	ra,0xffffe
    800028ba:	310080e7          	jalr	784(ra) # 80000bc6 <acquire>
  reparent(p);
    800028be:	854e                	mv	a0,s3
    800028c0:	00000097          	auipc	ra,0x0
    800028c4:	f06080e7          	jalr	-250(ra) # 800027c6 <reparent>
  wakeup(p->parent);
    800028c8:	0309b503          	ld	a0,48(s3)
    800028cc:	00000097          	auipc	ra,0x0
    800028d0:	e56080e7          	jalr	-426(ra) # 80002722 <wakeup>
  acquire(&p->lock);
    800028d4:	854e                	mv	a0,s3
    800028d6:	ffffe097          	auipc	ra,0xffffe
    800028da:	2f0080e7          	jalr	752(ra) # 80000bc6 <acquire>
  p->xstate = status;
    800028de:	0359a023          	sw	s5,32(s3)
  p->state = ZOMBIE;
    800028e2:	478d                	li	a5,3
    800028e4:	00f9ac23          	sw	a5,24(s3)
  release(&p->lock);// we added
    800028e8:	854e                	mv	a0,s3
    800028ea:	ffffe097          	auipc	ra,0xffffe
    800028ee:	3a6080e7          	jalr	934(ra) # 80000c90 <release>
  release(&wait_lock);
    800028f2:	8526                	mv	a0,s1
    800028f4:	ffffe097          	auipc	ra,0xffffe
    800028f8:	39c080e7          	jalr	924(ra) # 80000c90 <release>
  acquire(&t->lock);
    800028fc:	8552                	mv	a0,s4
    800028fe:	ffffe097          	auipc	ra,0xffffe
    80002902:	2c8080e7          	jalr	712(ra) # 80000bc6 <acquire>
  sched();
    80002906:	00000097          	auipc	ra,0x0
    8000290a:	b58080e7          	jalr	-1192(ra) # 8000245e <sched>
  panic("zombie exit");
    8000290e:	00006517          	auipc	a0,0x6
    80002912:	b8250513          	addi	a0,a0,-1150 # 80008490 <digits+0x450>
    80002916:	ffffe097          	auipc	ra,0xffffe
    8000291a:	c18080e7          	jalr	-1000(ra) # 8000052e <panic>

000000008000291e <kthread_exit>:
kthread_exit(int status){
    8000291e:	7179                	addi	sp,sp,-48
    80002920:	f406                	sd	ra,40(sp)
    80002922:	f022                	sd	s0,32(sp)
    80002924:	ec26                	sd	s1,24(sp)
    80002926:	e84a                	sd	s2,16(sp)
    80002928:	e44e                	sd	s3,8(sp)
    8000292a:	e052                	sd	s4,0(sp)
    8000292c:	1800                	addi	s0,sp,48
    8000292e:	89aa                	mv	s3,a0
  struct proc *p = myproc(); 
    80002930:	fffff097          	auipc	ra,0xfffff
    80002934:	1d8080e7          	jalr	472(ra) # 80001b08 <myproc>
    80002938:	892a                	mv	s2,a0
  struct kthread *t=mykthread();
    8000293a:	fffff097          	auipc	ra,0xfffff
    8000293e:	20e080e7          	jalr	526(ra) # 80001b48 <mykthread>
    80002942:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002944:	854a                	mv	a0,s2
    80002946:	ffffe097          	auipc	ra,0xffffe
    8000294a:	280080e7          	jalr	640(ra) # 80000bc6 <acquire>
  p->active_threads--;
    8000294e:	02892783          	lw	a5,40(s2)
    80002952:	37fd                	addiw	a5,a5,-1
    80002954:	00078a1b          	sext.w	s4,a5
    80002958:	02f92423          	sw	a5,40(s2)
  release(&p->lock);
    8000295c:	854a                	mv	a0,s2
    8000295e:	ffffe097          	auipc	ra,0xffffe
    80002962:	332080e7          	jalr	818(ra) # 80000c90 <release>
  acquire(&t->lock);
    80002966:	8526                	mv	a0,s1
    80002968:	ffffe097          	auipc	ra,0xffffe
    8000296c:	25e080e7          	jalr	606(ra) # 80000bc6 <acquire>
  t->xstate = status;
    80002970:	0334a623          	sw	s3,44(s1)
  t->state  = TUNUSED;
    80002974:	0004ac23          	sw	zero,24(s1)
  wakeup(t);
    80002978:	8526                	mv	a0,s1
    8000297a:	00000097          	auipc	ra,0x0
    8000297e:	da8080e7          	jalr	-600(ra) # 80002722 <wakeup>
  if(curr_active_threads==0){
    80002982:	000a1c63          	bnez	s4,8000299a <kthread_exit+0x7c>
    release(&t->lock);
    80002986:	8526                	mv	a0,s1
    80002988:	ffffe097          	auipc	ra,0xffffe
    8000298c:	308080e7          	jalr	776(ra) # 80000c90 <release>
    exit_proccess(status);
    80002990:	854e                	mv	a0,s3
    80002992:	00000097          	auipc	ra,0x0
    80002996:	e96080e7          	jalr	-362(ra) # 80002828 <exit_proccess>
    sched();
    8000299a:	00000097          	auipc	ra,0x0
    8000299e:	ac4080e7          	jalr	-1340(ra) # 8000245e <sched>
    panic("zombie thread exit");
    800029a2:	00006517          	auipc	a0,0x6
    800029a6:	afe50513          	addi	a0,a0,-1282 # 800084a0 <digits+0x460>
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	b84080e7          	jalr	-1148(ra) # 8000052e <panic>

00000000800029b2 <exit>:
exit(int status){
    800029b2:	7139                	addi	sp,sp,-64
    800029b4:	fc06                	sd	ra,56(sp)
    800029b6:	f822                	sd	s0,48(sp)
    800029b8:	f426                	sd	s1,40(sp)
    800029ba:	f04a                	sd	s2,32(sp)
    800029bc:	ec4e                	sd	s3,24(sp)
    800029be:	e852                	sd	s4,16(sp)
    800029c0:	e456                	sd	s5,8(sp)
    800029c2:	e05a                	sd	s6,0(sp)
    800029c4:	0080                	addi	s0,sp,64
    800029c6:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    800029c8:	fffff097          	auipc	ra,0xfffff
    800029cc:	140080e7          	jalr	320(ra) # 80001b08 <myproc>
    800029d0:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    800029d2:	fffff097          	auipc	ra,0xfffff
    800029d6:	176080e7          	jalr	374(ra) # 80001b48 <mykthread>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    800029da:	28890493          	addi	s1,s2,648
    800029de:	6505                	lui	a0,0x1
    800029e0:	84850513          	addi	a0,a0,-1976 # 848 <_entry-0x7ffff7b8>
    800029e4:	992a                	add	s2,s2,a0
    t->killed = 1;
    800029e6:	4a05                	li	s4,1
    if(t->state == TSLEEPING)
    800029e8:	4989                	li	s3,2
      t->state = TRUNNABLE;
    800029ea:	4b0d                	li	s6,3
    800029ec:	a811                	j	80002a00 <exit+0x4e>
    release(&t->lock);
    800029ee:	8526                	mv	a0,s1
    800029f0:	ffffe097          	auipc	ra,0xffffe
    800029f4:	2a0080e7          	jalr	672(ra) # 80000c90 <release>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    800029f8:	0b848493          	addi	s1,s1,184
    800029fc:	00990f63          	beq	s2,s1,80002a1a <exit+0x68>
    acquire(&t->lock);
    80002a00:	8526                	mv	a0,s1
    80002a02:	ffffe097          	auipc	ra,0xffffe
    80002a06:	1c4080e7          	jalr	452(ra) # 80000bc6 <acquire>
    t->killed = 1;
    80002a0a:	0344a423          	sw	s4,40(s1)
    if(t->state == TSLEEPING)
    80002a0e:	4c9c                	lw	a5,24(s1)
    80002a10:	fd379fe3          	bne	a5,s3,800029ee <exit+0x3c>
      t->state = TRUNNABLE;
    80002a14:	0164ac23          	sw	s6,24(s1)
    80002a18:	bfd9                	j	800029ee <exit+0x3c>
  kthread_exit(status);
    80002a1a:	8556                	mv	a0,s5
    80002a1c:	00000097          	auipc	ra,0x0
    80002a20:	f02080e7          	jalr	-254(ra) # 8000291e <kthread_exit>

0000000080002a24 <sig_stop>:
//   return -1;
// }

int
sig_stop(int pid)//TODO delete if not used
{
    80002a24:	7179                	addi	sp,sp,-48
    80002a26:	f406                	sd	ra,40(sp)
    80002a28:	f022                	sd	s0,32(sp)
    80002a2a:	ec26                	sd	s1,24(sp)
    80002a2c:	e84a                	sd	s2,16(sp)
    80002a2e:	e44e                	sd	s3,8(sp)
    80002a30:	e052                	sd	s4,0(sp)
    80002a32:	1800                	addi	s0,sp,48
    80002a34:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002a36:	0000f497          	auipc	s1,0xf
    80002a3a:	cf248493          	addi	s1,s1,-782 # 80011728 <proc>
    80002a3e:	6985                	lui	s3,0x1
    80002a40:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002a44:	00030a17          	auipc	s4,0x30
    80002a48:	ee4a0a13          	addi	s4,s4,-284 # 80032928 <tickslock>
    acquire(&p->lock);
    80002a4c:	8526                	mv	a0,s1
    80002a4e:	ffffe097          	auipc	ra,0xffffe
    80002a52:	178080e7          	jalr	376(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    80002a56:	50dc                	lw	a5,36(s1)
    80002a58:	01278c63          	beq	a5,s2,80002a70 <sig_stop+0x4c>
      p->pending_signals|=(1<<SIGSTOP);

      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002a5c:	8526                	mv	a0,s1
    80002a5e:	ffffe097          	auipc	ra,0xffffe
    80002a62:	232080e7          	jalr	562(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a66:	94ce                	add	s1,s1,s3
    80002a68:	ff4492e3          	bne	s1,s4,80002a4c <sig_stop+0x28>
  }
  return -1;
    80002a6c:	557d                	li	a0,-1
    80002a6e:	a831                	j	80002a8a <sig_stop+0x66>
      p->pending_signals|=(1<<SIGSTOP);
    80002a70:	0e84a783          	lw	a5,232(s1)
    80002a74:	00020737          	lui	a4,0x20
    80002a78:	8fd9                	or	a5,a5,a4
    80002a7a:	0ef4a423          	sw	a5,232(s1)
      release(&p->lock);
    80002a7e:	8526                	mv	a0,s1
    80002a80:	ffffe097          	auipc	ra,0xffffe
    80002a84:	210080e7          	jalr	528(ra) # 80000c90 <release>
      return 0;
    80002a88:	4501                	li	a0,0
}
    80002a8a:	70a2                	ld	ra,40(sp)
    80002a8c:	7402                	ld	s0,32(sp)
    80002a8e:	64e2                	ld	s1,24(sp)
    80002a90:	6942                	ld	s2,16(sp)
    80002a92:	69a2                	ld	s3,8(sp)
    80002a94:	6a02                	ld	s4,0(sp)
    80002a96:	6145                	addi	sp,sp,48
    80002a98:	8082                	ret

0000000080002a9a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002a9a:	7179                	addi	sp,sp,-48
    80002a9c:	f406                	sd	ra,40(sp)
    80002a9e:	f022                	sd	s0,32(sp)
    80002aa0:	ec26                	sd	s1,24(sp)
    80002aa2:	e84a                	sd	s2,16(sp)
    80002aa4:	e44e                	sd	s3,8(sp)
    80002aa6:	e052                	sd	s4,0(sp)
    80002aa8:	1800                	addi	s0,sp,48
    80002aaa:	84aa                	mv	s1,a0
    80002aac:	892e                	mv	s2,a1
    80002aae:	89b2                	mv	s3,a2
    80002ab0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002ab2:	fffff097          	auipc	ra,0xfffff
    80002ab6:	056080e7          	jalr	86(ra) # 80001b08 <myproc>
  if(user_dst){
    80002aba:	c08d                	beqz	s1,80002adc <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002abc:	86d2                	mv	a3,s4
    80002abe:	864e                	mv	a2,s3
    80002ac0:	85ca                	mv	a1,s2
    80002ac2:	6128                	ld	a0,64(a0)
    80002ac4:	fffff097          	auipc	ra,0xfffff
    80002ac8:	c2c080e7          	jalr	-980(ra) # 800016f0 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002acc:	70a2                	ld	ra,40(sp)
    80002ace:	7402                	ld	s0,32(sp)
    80002ad0:	64e2                	ld	s1,24(sp)
    80002ad2:	6942                	ld	s2,16(sp)
    80002ad4:	69a2                	ld	s3,8(sp)
    80002ad6:	6a02                	ld	s4,0(sp)
    80002ad8:	6145                	addi	sp,sp,48
    80002ada:	8082                	ret
    memmove((char *)dst, src, len);
    80002adc:	000a061b          	sext.w	a2,s4
    80002ae0:	85ce                	mv	a1,s3
    80002ae2:	854a                	mv	a0,s2
    80002ae4:	ffffe097          	auipc	ra,0xffffe
    80002ae8:	250080e7          	jalr	592(ra) # 80000d34 <memmove>
    return 0;
    80002aec:	8526                	mv	a0,s1
    80002aee:	bff9                	j	80002acc <either_copyout+0x32>

0000000080002af0 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002af0:	7179                	addi	sp,sp,-48
    80002af2:	f406                	sd	ra,40(sp)
    80002af4:	f022                	sd	s0,32(sp)
    80002af6:	ec26                	sd	s1,24(sp)
    80002af8:	e84a                	sd	s2,16(sp)
    80002afa:	e44e                	sd	s3,8(sp)
    80002afc:	e052                	sd	s4,0(sp)
    80002afe:	1800                	addi	s0,sp,48
    80002b00:	892a                	mv	s2,a0
    80002b02:	84ae                	mv	s1,a1
    80002b04:	89b2                	mv	s3,a2
    80002b06:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002b08:	fffff097          	auipc	ra,0xfffff
    80002b0c:	000080e7          	jalr	ra # 80001b08 <myproc>
  if(user_src){
    80002b10:	c08d                	beqz	s1,80002b32 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002b12:	86d2                	mv	a3,s4
    80002b14:	864e                	mv	a2,s3
    80002b16:	85ca                	mv	a1,s2
    80002b18:	6128                	ld	a0,64(a0)
    80002b1a:	fffff097          	auipc	ra,0xfffff
    80002b1e:	c62080e7          	jalr	-926(ra) # 8000177c <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002b22:	70a2                	ld	ra,40(sp)
    80002b24:	7402                	ld	s0,32(sp)
    80002b26:	64e2                	ld	s1,24(sp)
    80002b28:	6942                	ld	s2,16(sp)
    80002b2a:	69a2                	ld	s3,8(sp)
    80002b2c:	6a02                	ld	s4,0(sp)
    80002b2e:	6145                	addi	sp,sp,48
    80002b30:	8082                	ret
    memmove(dst, (char*)src, len);
    80002b32:	000a061b          	sext.w	a2,s4
    80002b36:	85ce                	mv	a1,s3
    80002b38:	854a                	mv	a0,s2
    80002b3a:	ffffe097          	auipc	ra,0xffffe
    80002b3e:	1fa080e7          	jalr	506(ra) # 80000d34 <memmove>
    return 0;
    80002b42:	8526                	mv	a0,s1
    80002b44:	bff9                	j	80002b22 <either_copyin+0x32>

0000000080002b46 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002b46:	715d                	addi	sp,sp,-80
    80002b48:	e486                	sd	ra,72(sp)
    80002b4a:	e0a2                	sd	s0,64(sp)
    80002b4c:	fc26                	sd	s1,56(sp)
    80002b4e:	f84a                	sd	s2,48(sp)
    80002b50:	f44e                	sd	s3,40(sp)
    80002b52:	f052                	sd	s4,32(sp)
    80002b54:	ec56                	sd	s5,24(sp)
    80002b56:	e85a                	sd	s6,16(sp)
    80002b58:	e45e                	sd	s7,8(sp)
    80002b5a:	e062                	sd	s8,0(sp)
    80002b5c:	0880                	addi	s0,sp,80


  struct proc *p;
  char *state;

  printf("\n");
    80002b5e:	00005517          	auipc	a0,0x5
    80002b62:	5fa50513          	addi	a0,a0,1530 # 80008158 <digits+0x118>
    80002b66:	ffffe097          	auipc	ra,0xffffe
    80002b6a:	a12080e7          	jalr	-1518(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b6e:	0000f497          	auipc	s1,0xf
    80002b72:	c9248493          	addi	s1,s1,-878 # 80011800 <proc+0xd8>
    80002b76:	00030997          	auipc	s3,0x30
    80002b7a:	e8a98993          	addi	s3,s3,-374 # 80032a00 <bcache+0xc0>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b7e:	4b8d                	li	s7,3
      state = states[p->state];
    else
      state = "???";
    80002b80:	00006a17          	auipc	s4,0x6
    80002b84:	938a0a13          	addi	s4,s4,-1736 # 800084b8 <digits+0x478>
    printf("%d %s %s", p->pid, state, p->name);
    80002b88:	00006b17          	auipc	s6,0x6
    80002b8c:	938b0b13          	addi	s6,s6,-1736 # 800084c0 <digits+0x480>
    printf("\n");
    80002b90:	00005a97          	auipc	s5,0x5
    80002b94:	5c8a8a93          	addi	s5,s5,1480 # 80008158 <digits+0x118>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b98:	00006c17          	auipc	s8,0x6
    80002b9c:	950c0c13          	addi	s8,s8,-1712 # 800084e8 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002ba0:	6905                	lui	s2,0x1
    80002ba2:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002ba6:	a005                	j	80002bc6 <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    80002ba8:	f4c6a583          	lw	a1,-180(a3)
    80002bac:	855a                	mv	a0,s6
    80002bae:	ffffe097          	auipc	ra,0xffffe
    80002bb2:	9ca080e7          	jalr	-1590(ra) # 80000578 <printf>
    printf("\n");
    80002bb6:	8556                	mv	a0,s5
    80002bb8:	ffffe097          	auipc	ra,0xffffe
    80002bbc:	9c0080e7          	jalr	-1600(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002bc0:	94ca                	add	s1,s1,s2
    80002bc2:	03348263          	beq	s1,s3,80002be6 <procdump+0xa0>
    if(p->state == UNUSED)
    80002bc6:	86a6                	mv	a3,s1
    80002bc8:	f404a783          	lw	a5,-192(s1)
    80002bcc:	dbf5                	beqz	a5,80002bc0 <procdump+0x7a>
      state = "???";
    80002bce:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002bd0:	fcfbece3          	bltu	s7,a5,80002ba8 <procdump+0x62>
    80002bd4:	02079713          	slli	a4,a5,0x20
    80002bd8:	01d75793          	srli	a5,a4,0x1d
    80002bdc:	97e2                	add	a5,a5,s8
    80002bde:	6390                	ld	a2,0(a5)
    80002be0:	f661                	bnez	a2,80002ba8 <procdump+0x62>
      state = "???";
    80002be2:	8652                	mv	a2,s4
    80002be4:	b7d1                	j	80002ba8 <procdump+0x62>
  }
}
    80002be6:	60a6                	ld	ra,72(sp)
    80002be8:	6406                	ld	s0,64(sp)
    80002bea:	74e2                	ld	s1,56(sp)
    80002bec:	7942                	ld	s2,48(sp)
    80002bee:	79a2                	ld	s3,40(sp)
    80002bf0:	7a02                	ld	s4,32(sp)
    80002bf2:	6ae2                	ld	s5,24(sp)
    80002bf4:	6b42                	ld	s6,16(sp)
    80002bf6:	6ba2                	ld	s7,8(sp)
    80002bf8:	6c02                	ld	s8,0(sp)
    80002bfa:	6161                	addi	sp,sp,80
    80002bfc:	8082                	ret

0000000080002bfe <is_valid_sigmask>:

int 
is_valid_sigmask(int sigmask){
    80002bfe:	1141                	addi	sp,sp,-16
    80002c00:	e422                	sd	s0,8(sp)
    80002c02:	0800                	addi	s0,sp,16
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002c04:	000207b7          	lui	a5,0x20
    80002c08:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002c0c:	8d7d                	and	a0,a0,a5
    return 0;
  return 1;
}
    80002c0e:	00153513          	seqz	a0,a0
    80002c12:	6422                	ld	s0,8(sp)
    80002c14:	0141                	addi	sp,sp,16
    80002c16:	8082                	ret

0000000080002c18 <sigprocmask>:

uint
sigprocmask(uint new_procmask){
    80002c18:	7179                	addi	sp,sp,-48
    80002c1a:	f406                	sd	ra,40(sp)
    80002c1c:	f022                	sd	s0,32(sp)
    80002c1e:	ec26                	sd	s1,24(sp)
    80002c20:	e84a                	sd	s2,16(sp)
    80002c22:	e44e                	sd	s3,8(sp)
    80002c24:	1800                	addi	s0,sp,48
    80002c26:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002c28:	fffff097          	auipc	ra,0xfffff
    80002c2c:	ee0080e7          	jalr	-288(ra) # 80001b08 <myproc>
  if(is_valid_sigmask(new_procmask) == 0)
    80002c30:	000207b7          	lui	a5,0x20
    80002c34:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002c38:	00f977b3          	and	a5,s2,a5
    return -1;
    80002c3c:	59fd                	li	s3,-1
  if(is_valid_sigmask(new_procmask) == 0)
    80002c3e:	ef99                	bnez	a5,80002c5c <sigprocmask+0x44>
    80002c40:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002c42:	ffffe097          	auipc	ra,0xffffe
    80002c46:	f84080e7          	jalr	-124(ra) # 80000bc6 <acquire>
  int old_procmask = p->signal_mask;
    80002c4a:	0ec4a983          	lw	s3,236(s1)
  p->signal_mask = new_procmask;
    80002c4e:	0f24a623          	sw	s2,236(s1)
  release(&p->lock);
    80002c52:	8526                	mv	a0,s1
    80002c54:	ffffe097          	auipc	ra,0xffffe
    80002c58:	03c080e7          	jalr	60(ra) # 80000c90 <release>
  
  return old_procmask;
}
    80002c5c:	854e                	mv	a0,s3
    80002c5e:	70a2                	ld	ra,40(sp)
    80002c60:	7402                	ld	s0,32(sp)
    80002c62:	64e2                	ld	s1,24(sp)
    80002c64:	6942                	ld	s2,16(sp)
    80002c66:	69a2                	ld	s3,8(sp)
    80002c68:	6145                	addi	sp,sp,48
    80002c6a:	8082                	ret

0000000080002c6c <sigaction>:

 
int 
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
  
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002c6c:	0005079b          	sext.w	a5,a0
    80002c70:	477d                	li	a4,31
    80002c72:	0cf76a63          	bltu	a4,a5,80002d46 <sigaction+0xda>
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
    80002c76:	7139                	addi	sp,sp,-64
    80002c78:	fc06                	sd	ra,56(sp)
    80002c7a:	f822                	sd	s0,48(sp)
    80002c7c:	f426                	sd	s1,40(sp)
    80002c7e:	f04a                	sd	s2,32(sp)
    80002c80:	ec4e                	sd	s3,24(sp)
    80002c82:	e852                	sd	s4,16(sp)
    80002c84:	0080                	addi	s0,sp,64
    80002c86:	84aa                	mv	s1,a0
    80002c88:	89ae                	mv	s3,a1
    80002c8a:	8a32                	mv	s4,a2
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002c8c:	37dd                	addiw	a5,a5,-9
    80002c8e:	9bdd                	andi	a5,a5,-9
    80002c90:	2781                	sext.w	a5,a5
    80002c92:	cfc5                	beqz	a5,80002d4a <sigaction+0xde>
    80002c94:	cdcd                	beqz	a1,80002d4e <sigaction+0xe2>
    return -1;
  struct proc *p = myproc();
    80002c96:	fffff097          	auipc	ra,0xfffff
    80002c9a:	e72080e7          	jalr	-398(ra) # 80001b08 <myproc>
    80002c9e:	892a                	mv	s2,a0

  uint new_mask;
  copyin(p->pagetable, (char *)&new_mask, (uint64)&act->sigmask, sizeof(act->sigmask));
    80002ca0:	4691                	li	a3,4
    80002ca2:	00898613          	addi	a2,s3,8
    80002ca6:	fcc40593          	addi	a1,s0,-52
    80002caa:	6128                	ld	a0,64(a0)
    80002cac:	fffff097          	auipc	ra,0xfffff
    80002cb0:	ad0080e7          	jalr	-1328(ra) # 8000177c <copyin>
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002cb4:	fcc42703          	lw	a4,-52(s0)

  if(is_valid_sigmask(new_mask) == 0)
    80002cb8:	000207b7          	lui	a5,0x20
    80002cbc:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002cc0:	8ff9                	and	a5,a5,a4
    80002cc2:	ebc1                	bnez	a5,80002d52 <sigaction+0xe6>
    return -1;
  acquire(&p->lock);
    80002cc4:	854a                	mv	a0,s2
    80002cc6:	ffffe097          	auipc	ra,0xffffe
    80002cca:	f00080e7          	jalr	-256(ra) # 80000bc6 <acquire>

  if(oldact!=0){
    80002cce:	020a0b63          	beqz	s4,80002d04 <sigaction+0x98>
    copyout(p->pagetable, (uint64)&oldact->sa_handler, (char *)&p->signal_handlers[signum], sizeof(act->sa_handler));
    80002cd2:	01f48613          	addi	a2,s1,31
    80002cd6:	060e                	slli	a2,a2,0x3
    80002cd8:	46a1                	li	a3,8
    80002cda:	964a                	add	a2,a2,s2
    80002cdc:	85d2                	mv	a1,s4
    80002cde:	04093503          	ld	a0,64(s2)
    80002ce2:	fffff097          	auipc	ra,0xfffff
    80002ce6:	a0e080e7          	jalr	-1522(ra) # 800016f0 <copyout>
    copyout(p->pagetable, (uint64)&oldact->sigmask, (char *)&p->handlers_sigmasks[signum], sizeof(uint));
    80002cea:	07e48613          	addi	a2,s1,126
    80002cee:	060a                	slli	a2,a2,0x2
    80002cf0:	4691                	li	a3,4
    80002cf2:	964a                	add	a2,a2,s2
    80002cf4:	008a0593          	addi	a1,s4,8
    80002cf8:	04093503          	ld	a0,64(s2)
    80002cfc:	fffff097          	auipc	ra,0xfffff
    80002d00:	9f4080e7          	jalr	-1548(ra) # 800016f0 <copyout>
  }

  p->handlers_sigmasks[signum]=new_mask;
    80002d04:	07c48793          	addi	a5,s1,124
    80002d08:	078a                	slli	a5,a5,0x2
    80002d0a:	97ca                	add	a5,a5,s2
    80002d0c:	fcc42703          	lw	a4,-52(s0)
    80002d10:	c798                	sw	a4,8(a5)
  copyin(p->pagetable, (char *)&p->signal_handlers[signum], (uint64)&act->sa_handler, sizeof(act->sa_handler));
    80002d12:	04fd                	addi	s1,s1,31
    80002d14:	048e                	slli	s1,s1,0x3
    80002d16:	46a1                	li	a3,8
    80002d18:	864e                	mv	a2,s3
    80002d1a:	009905b3          	add	a1,s2,s1
    80002d1e:	04093503          	ld	a0,64(s2)
    80002d22:	fffff097          	auipc	ra,0xfffff
    80002d26:	a5a080e7          	jalr	-1446(ra) # 8000177c <copyin>

  release(&p->lock);
    80002d2a:	854a                	mv	a0,s2
    80002d2c:	ffffe097          	auipc	ra,0xffffe
    80002d30:	f64080e7          	jalr	-156(ra) # 80000c90 <release>

  // printf("handler address %p = \n",p->signal_handlers[signum]);
  // printf("h_mask %d  \n",p->handlers_sigmasks[signum]);// TODO delete

  return 0;
    80002d34:	4501                	li	a0,0
}
    80002d36:	70e2                	ld	ra,56(sp)
    80002d38:	7442                	ld	s0,48(sp)
    80002d3a:	74a2                	ld	s1,40(sp)
    80002d3c:	7902                	ld	s2,32(sp)
    80002d3e:	69e2                	ld	s3,24(sp)
    80002d40:	6a42                	ld	s4,16(sp)
    80002d42:	6121                	addi	sp,sp,64
    80002d44:	8082                	ret
    return -1;
    80002d46:	557d                	li	a0,-1
}
    80002d48:	8082                	ret
    return -1;
    80002d4a:	557d                	li	a0,-1
    80002d4c:	b7ed                	j	80002d36 <sigaction+0xca>
    80002d4e:	557d                	li	a0,-1
    80002d50:	b7dd                	j	80002d36 <sigaction+0xca>
    return -1;
    80002d52:	557d                	li	a0,-1
    80002d54:	b7cd                	j	80002d36 <sigaction+0xca>

0000000080002d56 <sigret>:

void 
sigret(void){
    80002d56:	1101                	addi	sp,sp,-32
    80002d58:	ec06                	sd	ra,24(sp)
    80002d5a:	e822                	sd	s0,16(sp)
    80002d5c:	e426                	sd	s1,8(sp)
    80002d5e:	e04a                	sd	s2,0(sp)
    80002d60:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002d62:	fffff097          	auipc	ra,0xfffff
    80002d66:	da6080e7          	jalr	-602(ra) # 80001b08 <myproc>
    80002d6a:	84aa                	mv	s1,a0
  struct kthread *t=mykthread();
    80002d6c:	fffff097          	auipc	ra,0xfffff
    80002d70:	ddc080e7          	jalr	-548(ra) # 80001b48 <mykthread>
    80002d74:	892a                	mv	s2,a0

  copyin(p->pagetable, (char *)t->trapframe, (uint64)p->user_trapframe_backup, sizeof(struct trapframe));
    80002d76:	12000693          	li	a3,288
    80002d7a:	2784b603          	ld	a2,632(s1)
    80002d7e:	612c                	ld	a1,64(a0)
    80002d80:	60a8                	ld	a0,64(s1)
    80002d82:	fffff097          	auipc	ra,0xfffff
    80002d86:	9fa080e7          	jalr	-1542(ra) # 8000177c <copyin>

  // restore user stack pointer
  acquire(&p->lock);
    80002d8a:	8526                	mv	a0,s1
    80002d8c:	ffffe097          	auipc	ra,0xffffe
    80002d90:	e3a080e7          	jalr	-454(ra) # 80000bc6 <acquire>
  // TODO maybe we will need to also lock the kthread lock
  t->trapframe->sp += sizeof(struct trapframe);
    80002d94:	04093703          	ld	a4,64(s2)
    80002d98:	7b1c                	ld	a5,48(a4)
    80002d9a:	12078793          	addi	a5,a5,288
    80002d9e:	fb1c                	sd	a5,48(a4)

  p->signal_mask = p->signal_mask_backup;
    80002da0:	0f04a783          	lw	a5,240(s1)
    80002da4:	0ef4a623          	sw	a5,236(s1)
  
  // Allow user signal handler since we finished handling the current
  p->handling_user_sig_flag = 0;
    80002da8:	2804a023          	sw	zero,640(s1)
  // Allow other thread to react to signals
  p->handling_sig_flag = 0;
    80002dac:	2804a223          	sw	zero,644(s1)
  release(&p->lock);
    80002db0:	8526                	mv	a0,s1
    80002db2:	ffffe097          	auipc	ra,0xffffe
    80002db6:	ede080e7          	jalr	-290(ra) # 80000c90 <release>
}
    80002dba:	60e2                	ld	ra,24(sp)
    80002dbc:	6442                	ld	s0,16(sp)
    80002dbe:	64a2                	ld	s1,8(sp)
    80002dc0:	6902                	ld	s2,0(sp)
    80002dc2:	6105                	addi	sp,sp,32
    80002dc4:	8082                	ret

0000000080002dc6 <turn_on_bit>:

// we call turn on and turn off when holding p->lock
void
turn_on_bit(struct proc* p, int signum){
    80002dc6:	1141                	addi	sp,sp,-16
    80002dc8:	e422                	sd	s0,8(sp)
    80002dca:	0800                	addi	s0,sp,16
  if(!p->pending_signals & (1 << signum))
    80002dcc:	0e852703          	lw	a4,232(a0)
    80002dd0:	00173793          	seqz	a5,a4
    80002dd4:	40b7d7bb          	sraw	a5,a5,a1
    80002dd8:	8b85                	andi	a5,a5,1
    80002dda:	c799                	beqz	a5,80002de8 <turn_on_bit+0x22>
    p->pending_signals ^= (1 << signum);  
    80002ddc:	4785                	li	a5,1
    80002dde:	00b795bb          	sllw	a1,a5,a1
    80002de2:	8f2d                	xor	a4,a4,a1
    80002de4:	0ee52423          	sw	a4,232(a0)
}
    80002de8:	6422                	ld	s0,8(sp)
    80002dea:	0141                	addi	sp,sp,16
    80002dec:	8082                	ret

0000000080002dee <kill>:
{
    80002dee:	7139                	addi	sp,sp,-64
    80002df0:	fc06                	sd	ra,56(sp)
    80002df2:	f822                	sd	s0,48(sp)
    80002df4:	f426                	sd	s1,40(sp)
    80002df6:	f04a                	sd	s2,32(sp)
    80002df8:	ec4e                	sd	s3,24(sp)
    80002dfa:	e852                	sd	s4,16(sp)
    80002dfc:	e456                	sd	s5,8(sp)
    80002dfe:	0080                	addi	s0,sp,64
    80002e00:	892a                	mv	s2,a0
    80002e02:	8aae                	mv	s5,a1
  for(p = proc; p < &proc[NPROC]; p++){
    80002e04:	0000f497          	auipc	s1,0xf
    80002e08:	92448493          	addi	s1,s1,-1756 # 80011728 <proc>
    80002e0c:	6985                	lui	s3,0x1
    80002e0e:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002e12:	00030a17          	auipc	s4,0x30
    80002e16:	b16a0a13          	addi	s4,s4,-1258 # 80032928 <tickslock>
    acquire(&p->lock);
    80002e1a:	8526                	mv	a0,s1
    80002e1c:	ffffe097          	auipc	ra,0xffffe
    80002e20:	daa080e7          	jalr	-598(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    80002e24:	50dc                	lw	a5,36(s1)
    80002e26:	01278c63          	beq	a5,s2,80002e3e <kill+0x50>
    release(&p->lock);
    80002e2a:	8526                	mv	a0,s1
    80002e2c:	ffffe097          	auipc	ra,0xffffe
    80002e30:	e64080e7          	jalr	-412(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002e34:	94ce                	add	s1,s1,s3
    80002e36:	ff4492e3          	bne	s1,s4,80002e1a <kill+0x2c>
  return -1;
    80002e3a:	557d                	li	a0,-1
    80002e3c:	a825                	j	80002e74 <kill+0x86>
      if(p->state != RUNNABLE){
    80002e3e:	4c98                	lw	a4,24(s1)
    80002e40:	4789                	li	a5,2
    80002e42:	04f71263          	bne	a4,a5,80002e86 <kill+0x98>
      if(p->signal_handlers[signum] == (void*)SIG_IGN){
    80002e46:	01ea8793          	addi	a5,s5,30
    80002e4a:	078e                	slli	a5,a5,0x3
    80002e4c:	97a6                	add	a5,a5,s1
    80002e4e:	6798                	ld	a4,8(a5)
    80002e50:	4785                	li	a5,1
    80002e52:	04f70163          	beq	a4,a5,80002e94 <kill+0xa6>
      turn_on_bit(p,signum);
    80002e56:	85d6                	mv	a1,s5
    80002e58:	8526                	mv	a0,s1
    80002e5a:	00000097          	auipc	ra,0x0
    80002e5e:	f6c080e7          	jalr	-148(ra) # 80002dc6 <turn_on_bit>
      release(&p->lock);
    80002e62:	8526                	mv	a0,s1
    80002e64:	ffffe097          	auipc	ra,0xffffe
    80002e68:	e2c080e7          	jalr	-468(ra) # 80000c90 <release>
      if(signum == SIGKILL){
    80002e6c:	47a5                	li	a5,9
      return 0;
    80002e6e:	4501                	li	a0,0
      if(signum == SIGKILL){
    80002e70:	02fa8963          	beq	s5,a5,80002ea2 <kill+0xb4>
}
    80002e74:	70e2                	ld	ra,56(sp)
    80002e76:	7442                	ld	s0,48(sp)
    80002e78:	74a2                	ld	s1,40(sp)
    80002e7a:	7902                	ld	s2,32(sp)
    80002e7c:	69e2                	ld	s3,24(sp)
    80002e7e:	6a42                	ld	s4,16(sp)
    80002e80:	6aa2                	ld	s5,8(sp)
    80002e82:	6121                	addi	sp,sp,64
    80002e84:	8082                	ret
        release(&p->lock);
    80002e86:	8526                	mv	a0,s1
    80002e88:	ffffe097          	auipc	ra,0xffffe
    80002e8c:	e08080e7          	jalr	-504(ra) # 80000c90 <release>
        return -1;
    80002e90:	557d                	li	a0,-1
    80002e92:	b7cd                	j	80002e74 <kill+0x86>
        release(&p->lock);
    80002e94:	8526                	mv	a0,s1
    80002e96:	ffffe097          	auipc	ra,0xffffe
    80002e9a:	dfa080e7          	jalr	-518(ra) # 80000c90 <release>
        return 0;
    80002e9e:	4501                	li	a0,0
    80002ea0:	bfd1                	j	80002e74 <kill+0x86>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002ea2:	28848913          	addi	s2,s1,648
    80002ea6:	6785                	lui	a5,0x1
    80002ea8:	84878793          	addi	a5,a5,-1976 # 848 <_entry-0x7ffff7b8>
    80002eac:	94be                	add	s1,s1,a5
          if(t->state == RUNNABLE){
    80002eae:	4989                	li	s3,2
    80002eb0:	01892783          	lw	a5,24(s2)
    80002eb4:	03378d63          	beq	a5,s3,80002eee <kill+0x100>
            acquire(&t->lock);
    80002eb8:	854a                	mv	a0,s2
    80002eba:	ffffe097          	auipc	ra,0xffffe
    80002ebe:	d0c080e7          	jalr	-756(ra) # 80000bc6 <acquire>
            if(t->state==TSLEEPING){
    80002ec2:	01892783          	lw	a5,24(s2)
    80002ec6:	01378d63          	beq	a5,s3,80002ee0 <kill+0xf2>
            release(&t->lock);
    80002eca:	854a                	mv	a0,s2
    80002ecc:	ffffe097          	auipc	ra,0xffffe
    80002ed0:	dc4080e7          	jalr	-572(ra) # 80000c90 <release>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002ed4:	0b890913          	addi	s2,s2,184
    80002ed8:	fc991ce3          	bne	s2,s1,80002eb0 <kill+0xc2>
      return 0;
    80002edc:	4501                	li	a0,0
    80002ede:	bf59                	j	80002e74 <kill+0x86>
              release(&t->lock);
    80002ee0:	854a                	mv	a0,s2
    80002ee2:	ffffe097          	auipc	ra,0xffffe
    80002ee6:	dae080e7          	jalr	-594(ra) # 80000c90 <release>
      return 0;
    80002eea:	4501                	li	a0,0
              break;
    80002eec:	b761                	j	80002e74 <kill+0x86>
      return 0;
    80002eee:	4501                	li	a0,0
    80002ef0:	b751                	j	80002e74 <kill+0x86>

0000000080002ef2 <turn_off_bit>:

void
turn_off_bit(struct proc* p, int signum){
    80002ef2:	1141                	addi	sp,sp,-16
    80002ef4:	e422                	sd	s0,8(sp)
    80002ef6:	0800                	addi	s0,sp,16
  if(p->pending_signals & (1 << signum))
    80002ef8:	0e852703          	lw	a4,232(a0)
    80002efc:	4785                	li	a5,1
    80002efe:	00b795bb          	sllw	a1,a5,a1
    80002f02:	00b777b3          	and	a5,a4,a1
    80002f06:	2781                	sext.w	a5,a5
    80002f08:	c781                	beqz	a5,80002f10 <turn_off_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    80002f0a:	8db9                	xor	a1,a1,a4
    80002f0c:	0eb52423          	sw	a1,232(a0)
}
    80002f10:	6422                	ld	s0,8(sp)
    80002f12:	0141                	addi	sp,sp,16
    80002f14:	8082                	ret

0000000080002f16 <kthread_create>:

int kthread_create(void (*start_func)(), void *stack){
    80002f16:	7139                	addi	sp,sp,-64
    80002f18:	fc06                	sd	ra,56(sp)
    80002f1a:	f822                	sd	s0,48(sp)
    80002f1c:	f426                	sd	s1,40(sp)
    80002f1e:	f04a                	sd	s2,32(sp)
    80002f20:	ec4e                	sd	s3,24(sp)
    80002f22:	e852                	sd	s4,16(sp)
    80002f24:	e456                	sd	s5,8(sp)
    80002f26:	e05a                	sd	s6,0(sp)
    80002f28:	0080                	addi	s0,sp,64
    80002f2a:	8aaa                	mv	s5,a0
    80002f2c:	8b2e                	mv	s6,a1
  struct proc *p = myproc();
    80002f2e:	fffff097          	auipc	ra,0xfffff
    80002f32:	bda080e7          	jalr	-1062(ra) # 80001b08 <myproc>
    80002f36:	8a2a                	mv	s4,a0
  struct kthread *curr_t = mykthread();
    80002f38:	fffff097          	auipc	ra,0xfffff
    80002f3c:	c10080e7          	jalr	-1008(ra) # 80001b48 <mykthread>
    80002f40:	89aa                	mv	s3,a0
  struct kthread *other_t;
  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    80002f42:	288a0493          	addi	s1,s4,648
    80002f46:	6905                	lui	s2,0x1
    80002f48:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002f4c:	9952                	add	s2,s2,s4
    80002f4e:	a89d                	j	80002fc4 <kthread_create+0xae>
  t->tid = 0;
    80002f50:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80002f54:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80002f58:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80002f5c:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80002f60:	0004ac23          	sw	zero,24(s1)
    if(curr_t!=other_t){
      acquire(&other_t->lock);
      if(other_t->state==TUNUSED){
          freethread(other_t);  // free memory in case this thread entry was previously used
          init_thread(other_t);
    80002f64:	8526                	mv	a0,s1
    80002f66:	fffff097          	auipc	ra,0xfffff
    80002f6a:	cf4080e7          	jalr	-780(ra) # 80001c5a <init_thread>
          other_t->trapframe->sp = (uint64)stack;
    80002f6e:	60bc                	ld	a5,64(s1)
    80002f70:	0367b823          	sd	s6,48(a5)
          other_t->trapframe->epc = (uint64)start_func;
    80002f74:	60bc                	ld	a5,64(s1)
    80002f76:	0157bc23          	sd	s5,24(a5)
          release(&other_t->lock);
    80002f7a:	8526                	mv	a0,s1
    80002f7c:	ffffe097          	auipc	ra,0xffffe
    80002f80:	d14080e7          	jalr	-748(ra) # 80000c90 <release>
          acquire(&p->lock);
    80002f84:	8552                	mv	a0,s4
    80002f86:	ffffe097          	auipc	ra,0xffffe
    80002f8a:	c40080e7          	jalr	-960(ra) # 80000bc6 <acquire>
          p->active_threads++;
    80002f8e:	028a2783          	lw	a5,40(s4)
    80002f92:	2785                	addiw	a5,a5,1
    80002f94:	02fa2423          	sw	a5,40(s4)
          release(&p->lock);
    80002f98:	8552                	mv	a0,s4
    80002f9a:	ffffe097          	auipc	ra,0xffffe
    80002f9e:	cf6080e7          	jalr	-778(ra) # 80000c90 <release>
          other_t->state = TRUNNABLE;
    80002fa2:	478d                	li	a5,3
    80002fa4:	cc9c                	sw	a5,24(s1)
      }
      release(&other_t->lock);
    }
  }
  return 1;
}
    80002fa6:	4505                	li	a0,1
    80002fa8:	70e2                	ld	ra,56(sp)
    80002faa:	7442                	ld	s0,48(sp)
    80002fac:	74a2                	ld	s1,40(sp)
    80002fae:	7902                	ld	s2,32(sp)
    80002fb0:	69e2                	ld	s3,24(sp)
    80002fb2:	6a42                	ld	s4,16(sp)
    80002fb4:	6aa2                	ld	s5,8(sp)
    80002fb6:	6b02                	ld	s6,0(sp)
    80002fb8:	6121                	addi	sp,sp,64
    80002fba:	8082                	ret
  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    80002fbc:	0b848493          	addi	s1,s1,184
    80002fc0:	fe9903e3          	beq	s2,s1,80002fa6 <kthread_create+0x90>
    if(curr_t!=other_t){
    80002fc4:	fe998ce3          	beq	s3,s1,80002fbc <kthread_create+0xa6>
      acquire(&other_t->lock);
    80002fc8:	8526                	mv	a0,s1
    80002fca:	ffffe097          	auipc	ra,0xffffe
    80002fce:	bfc080e7          	jalr	-1028(ra) # 80000bc6 <acquire>
      if(other_t->state==TUNUSED){
    80002fd2:	4c9c                	lw	a5,24(s1)
    80002fd4:	dfb5                	beqz	a5,80002f50 <kthread_create+0x3a>
      release(&other_t->lock);
    80002fd6:	8526                	mv	a0,s1
    80002fd8:	ffffe097          	auipc	ra,0xffffe
    80002fdc:	cb8080e7          	jalr	-840(ra) # 80000c90 <release>
    80002fe0:	bff1                	j	80002fbc <kthread_create+0xa6>

0000000080002fe2 <kthread_join>:



int
kthread_join(int thread_id, int* status){
    80002fe2:	7139                	addi	sp,sp,-64
    80002fe4:	fc06                	sd	ra,56(sp)
    80002fe6:	f822                	sd	s0,48(sp)
    80002fe8:	f426                	sd	s1,40(sp)
    80002fea:	f04a                	sd	s2,32(sp)
    80002fec:	ec4e                	sd	s3,24(sp)
    80002fee:	e852                	sd	s4,16(sp)
    80002ff0:	e456                	sd	s5,8(sp)
    80002ff2:	e05a                	sd	s6,0(sp)
    80002ff4:	0080                	addi	s0,sp,64
    80002ff6:	8a2a                	mv	s4,a0
    80002ff8:	8b2e                	mv	s6,a1
  struct kthread *nt;
  struct proc *p = myproc();
    80002ffa:	fffff097          	auipc	ra,0xfffff
    80002ffe:	b0e080e7          	jalr	-1266(ra) # 80001b08 <myproc>
    80003002:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80003004:	fffff097          	auipc	ra,0xfffff
    80003008:	b44080e7          	jalr	-1212(ra) # 80001b48 <mykthread>
  if(thread_id == t->tid)
    8000300c:	591c                	lw	a5,48(a0)
    8000300e:	11478d63          	beq	a5,s4,80003128 <kthread_join+0x146>
    80003012:	89aa                	mv	s3,a0
    return -1;
  
  acquire(&wait_lock);
    80003014:	0000e517          	auipc	a0,0xe
    80003018:	2bc50513          	addi	a0,a0,700 # 800112d0 <wait_lock>
    8000301c:	ffffe097          	auipc	ra,0xffffe
    80003020:	baa080e7          	jalr	-1110(ra) # 80000bc6 <acquire>

  // Search for thread in the procces threads array
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];t++){
    80003024:	28890493          	addi	s1,s2,648
    acquire(&nt->lock);
    80003028:	8526                	mv	a0,s1
    8000302a:	ffffe097          	auipc	ra,0xffffe
    8000302e:	b9c080e7          	jalr	-1124(ra) # 80000bc6 <acquire>
    if(nt->tid == thread_id){
    80003032:	2b892783          	lw	a5,696(s2)
    80003036:	01478a63          	beq	a5,s4,8000304a <kthread_join+0x68>
      //found target thread 
      break;
    }
    release(&nt->lock);
    8000303a:	8526                	mv	a0,s1
    8000303c:	ffffe097          	auipc	ra,0xffffe
    80003040:	c54080e7          	jalr	-940(ra) # 80000c90 <release>
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];t++){
    80003044:	0b898993          	addi	s3,s3,184
    80003048:	b7c5                	j	80003028 <kthread_join+0x46>
  }
  
  // Wait for thread to terminate
  // still holding nt lock
  for(;;){
      if(nt->state==TUNUSED){
    8000304a:	2a092783          	lw	a5,672(s2)
      release(&nt->lock);
      release(&wait_lock);
      return -1;
    }
    release(&nt->lock);
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    8000304e:	0000ea97          	auipc	s5,0xe
    80003052:	282a8a93          	addi	s5,s5,642 # 800112d0 <wait_lock>
      if(nt->state==TUNUSED){
    80003056:	cb9d                	beqz	a5,8000308c <kthread_join+0xaa>
    if(t->killed || nt->tid!=thread_id){
    80003058:	0289a783          	lw	a5,40(s3)
    8000305c:	efd1                	bnez	a5,800030f8 <kthread_join+0x116>
    8000305e:	2b892783          	lw	a5,696(s2)
    80003062:	09479b63          	bne	a5,s4,800030f8 <kthread_join+0x116>
    release(&nt->lock);
    80003066:	8526                	mv	a0,s1
    80003068:	ffffe097          	auipc	ra,0xffffe
    8000306c:	c28080e7          	jalr	-984(ra) # 80000c90 <release>
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    80003070:	85d6                	mv	a1,s5
    80003072:	8526                	mv	a0,s1
    80003074:	fffff097          	auipc	ra,0xfffff
    80003078:	524080e7          	jalr	1316(ra) # 80002598 <sleep>
    acquire(&nt->lock);
    8000307c:	8526                	mv	a0,s1
    8000307e:	ffffe097          	auipc	ra,0xffffe
    80003082:	b48080e7          	jalr	-1208(ra) # 80000bc6 <acquire>
      if(nt->state==TUNUSED){
    80003086:	2a092783          	lw	a5,672(s2)
    8000308a:	f7f9                	bnez	a5,80003058 <kthread_join+0x76>
        if(status != 0 && copyout(p->pagetable, status, (char *)&nt->xstate,sizeof(nt->xstate)) < 0) {
    8000308c:	000b0e63          	beqz	s6,800030a8 <kthread_join+0xc6>
    80003090:	4691                	li	a3,4
    80003092:	2b490613          	addi	a2,s2,692
    80003096:	85da                	mv	a1,s6
    80003098:	04093503          	ld	a0,64(s2)
    8000309c:	ffffe097          	auipc	ra,0xffffe
    800030a0:	654080e7          	jalr	1620(ra) # 800016f0 <copyout>
    800030a4:	02054b63          	bltz	a0,800030da <kthread_join+0xf8>
  t->tid = 0;
    800030a8:	2a092c23          	sw	zero,696(s2)
  t->chan = 0;
    800030ac:	2a093423          	sd	zero,680(s2)
  t->killed = 0;
    800030b0:	2a092823          	sw	zero,688(s2)
  t->xstate = 0;
    800030b4:	2a092a23          	sw	zero,692(s2)
  t->state = TUNUSED;
    800030b8:	2a092023          	sw	zero,672(s2)
        release(&nt->lock);
    800030bc:	8526                	mv	a0,s1
    800030be:	ffffe097          	auipc	ra,0xffffe
    800030c2:	bd2080e7          	jalr	-1070(ra) # 80000c90 <release>
        release(&wait_lock);
    800030c6:	0000e517          	auipc	a0,0xe
    800030ca:	20a50513          	addi	a0,a0,522 # 800112d0 <wait_lock>
    800030ce:	ffffe097          	auipc	ra,0xffffe
    800030d2:	bc2080e7          	jalr	-1086(ra) # 80000c90 <release>
        return 0;
    800030d6:	4501                	li	a0,0
    800030d8:	a835                	j	80003114 <kthread_join+0x132>
           release(&nt->lock);
    800030da:	8526                	mv	a0,s1
    800030dc:	ffffe097          	auipc	ra,0xffffe
    800030e0:	bb4080e7          	jalr	-1100(ra) # 80000c90 <release>
           release(&wait_lock);
    800030e4:	0000e517          	auipc	a0,0xe
    800030e8:	1ec50513          	addi	a0,a0,492 # 800112d0 <wait_lock>
    800030ec:	ffffe097          	auipc	ra,0xffffe
    800030f0:	ba4080e7          	jalr	-1116(ra) # 80000c90 <release>
           return -1;                   
    800030f4:	557d                	li	a0,-1
    800030f6:	a839                	j	80003114 <kthread_join+0x132>
      release(&nt->lock);
    800030f8:	8526                	mv	a0,s1
    800030fa:	ffffe097          	auipc	ra,0xffffe
    800030fe:	b96080e7          	jalr	-1130(ra) # 80000c90 <release>
      release(&wait_lock);
    80003102:	0000e517          	auipc	a0,0xe
    80003106:	1ce50513          	addi	a0,a0,462 # 800112d0 <wait_lock>
    8000310a:	ffffe097          	auipc	ra,0xffffe
    8000310e:	b86080e7          	jalr	-1146(ra) # 80000c90 <release>
      return -1;
    80003112:	557d                	li	a0,-1
  }
}
    80003114:	70e2                	ld	ra,56(sp)
    80003116:	7442                	ld	s0,48(sp)
    80003118:	74a2                	ld	s1,40(sp)
    8000311a:	7902                	ld	s2,32(sp)
    8000311c:	69e2                	ld	s3,24(sp)
    8000311e:	6a42                	ld	s4,16(sp)
    80003120:	6aa2                	ld	s5,8(sp)
    80003122:	6b02                	ld	s6,0(sp)
    80003124:	6121                	addi	sp,sp,64
    80003126:	8082                	ret
    return -1;
    80003128:	557d                	li	a0,-1
    8000312a:	b7ed                	j	80003114 <kthread_join+0x132>

000000008000312c <swtch>:
    8000312c:	00153023          	sd	ra,0(a0)
    80003130:	00253423          	sd	sp,8(a0)
    80003134:	e900                	sd	s0,16(a0)
    80003136:	ed04                	sd	s1,24(a0)
    80003138:	03253023          	sd	s2,32(a0)
    8000313c:	03353423          	sd	s3,40(a0)
    80003140:	03453823          	sd	s4,48(a0)
    80003144:	03553c23          	sd	s5,56(a0)
    80003148:	05653023          	sd	s6,64(a0)
    8000314c:	05753423          	sd	s7,72(a0)
    80003150:	05853823          	sd	s8,80(a0)
    80003154:	05953c23          	sd	s9,88(a0)
    80003158:	07a53023          	sd	s10,96(a0)
    8000315c:	07b53423          	sd	s11,104(a0)
    80003160:	0005b083          	ld	ra,0(a1)
    80003164:	0085b103          	ld	sp,8(a1)
    80003168:	6980                	ld	s0,16(a1)
    8000316a:	6d84                	ld	s1,24(a1)
    8000316c:	0205b903          	ld	s2,32(a1)
    80003170:	0285b983          	ld	s3,40(a1)
    80003174:	0305ba03          	ld	s4,48(a1)
    80003178:	0385ba83          	ld	s5,56(a1)
    8000317c:	0405bb03          	ld	s6,64(a1)
    80003180:	0485bb83          	ld	s7,72(a1)
    80003184:	0505bc03          	ld	s8,80(a1)
    80003188:	0585bc83          	ld	s9,88(a1)
    8000318c:	0605bd03          	ld	s10,96(a1)
    80003190:	0685bd83          	ld	s11,104(a1)
    80003194:	8082                	ret

0000000080003196 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80003196:	1141                	addi	sp,sp,-16
    80003198:	e406                	sd	ra,8(sp)
    8000319a:	e022                	sd	s0,0(sp)
    8000319c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000319e:	00005597          	auipc	a1,0x5
    800031a2:	36a58593          	addi	a1,a1,874 # 80008508 <states.0+0x20>
    800031a6:	0002f517          	auipc	a0,0x2f
    800031aa:	78250513          	addi	a0,a0,1922 # 80032928 <tickslock>
    800031ae:	ffffe097          	auipc	ra,0xffffe
    800031b2:	988080e7          	jalr	-1656(ra) # 80000b36 <initlock>
}
    800031b6:	60a2                	ld	ra,8(sp)
    800031b8:	6402                	ld	s0,0(sp)
    800031ba:	0141                	addi	sp,sp,16
    800031bc:	8082                	ret

00000000800031be <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800031be:	1141                	addi	sp,sp,-16
    800031c0:	e422                	sd	s0,8(sp)
    800031c2:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800031c4:	00003797          	auipc	a5,0x3
    800031c8:	6bc78793          	addi	a5,a5,1724 # 80006880 <kernelvec>
    800031cc:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800031d0:	6422                	ld	s0,8(sp)
    800031d2:	0141                	addi	sp,sp,16
    800031d4:	8082                	ret

00000000800031d6 <check_should_cont>:
}

int 
check_should_cont(struct proc *p){
  for(int i=0;i<32;i++){
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    800031d6:	0e852303          	lw	t1,232(a0)
    800031da:	0f850813          	addi	a6,a0,248
    800031de:	4685                	li	a3,1
    800031e0:	4701                	li	a4,0
    800031e2:	4885                	li	a7,1
  for(int i=0;i<32;i++){
    800031e4:	4e7d                	li	t3,31
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    800031e6:	4ecd                	li	t4,19
    800031e8:	a801                	j	800031f8 <check_should_cont+0x22>
  for(int i=0;i<32;i++){
    800031ea:	0006879b          	sext.w	a5,a3
    800031ee:	04fe4663          	blt	t3,a5,8000323a <check_should_cont+0x64>
    800031f2:	2705                	addiw	a4,a4,1
    800031f4:	2685                	addiw	a3,a3,1
    800031f6:	0821                	addi	a6,a6,8
    800031f8:	0007059b          	sext.w	a1,a4
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    800031fc:	00e8963b          	sllw	a2,a7,a4
    80003200:	00c377b3          	and	a5,t1,a2
    80003204:	2781                	sext.w	a5,a5
    80003206:	d3f5                	beqz	a5,800031ea <check_should_cont+0x14>
    80003208:	0ec52783          	lw	a5,236(a0)
    8000320c:	8ff1                	and	a5,a5,a2
    8000320e:	2781                	sext.w	a5,a5
    80003210:	ffe9                	bnez	a5,800031ea <check_should_cont+0x14>
    80003212:	00083783          	ld	a5,0(a6)
    80003216:	01d78563          	beq	a5,t4,80003220 <check_should_cont+0x4a>
    8000321a:	fdd598e3          	bne	a1,t4,800031ea <check_should_cont+0x14>
          (i == SIGCONT && p->signal_handlers[i] == SIG_DFL))){
    8000321e:	fbf1                	bnez	a5,800031f2 <check_should_cont+0x1c>
check_should_cont(struct proc *p){
    80003220:	1141                	addi	sp,sp,-16
    80003222:	e406                	sd	ra,8(sp)
    80003224:	e022                	sd	s0,0(sp)
    80003226:	0800                	addi	s0,sp,16
        turn_off_bit(p, i);
    80003228:	00000097          	auipc	ra,0x0
    8000322c:	cca080e7          	jalr	-822(ra) # 80002ef2 <turn_off_bit>
        return 1;
    80003230:	4505                	li	a0,1
      }
  }
  return 0;
}
    80003232:	60a2                	ld	ra,8(sp)
    80003234:	6402                	ld	s0,0(sp)
    80003236:	0141                	addi	sp,sp,16
    80003238:	8082                	ret
  return 0;
    8000323a:	4501                	li	a0,0
}
    8000323c:	8082                	ret

000000008000323e <handle_stop>:



void
handle_stop(struct proc* p){
    8000323e:	7139                	addi	sp,sp,-64
    80003240:	fc06                	sd	ra,56(sp)
    80003242:	f822                	sd	s0,48(sp)
    80003244:	f426                	sd	s1,40(sp)
    80003246:	f04a                	sd	s2,32(sp)
    80003248:	ec4e                	sd	s3,24(sp)
    8000324a:	e852                	sd	s4,16(sp)
    8000324c:	e456                	sd	s5,8(sp)
    8000324e:	e05a                	sd	s6,0(sp)
    80003250:	0080                	addi	s0,sp,64
    80003252:	89aa                	mv	s3,a0
  // p->frozen=1;
  struct kthread *t;
  struct kthread *curr_t = mykthread();
    80003254:	fffff097          	auipc	ra,0xfffff
    80003258:	8f4080e7          	jalr	-1804(ra) # 80001b48 <mykthread>
    8000325c:	8aaa                	mv	s5,a0

  // Make all other threads belong to the same procces freeze 
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    8000325e:	28898493          	addi	s1,s3,648
    80003262:	6a05                	lui	s4,0x1
    80003264:	848a0a13          	addi	s4,s4,-1976 # 848 <_entry-0x7ffff7b8>
    80003268:	9a4e                	add	s4,s4,s3
    8000326a:	8926                	mv	s2,s1
    if(t!=curr_t){
      acquire(&t->lock);
      t->frozen=1;
    8000326c:	4b05                	li	s6,1
    8000326e:	a029                	j	80003278 <handle_stop+0x3a>
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    80003270:	0b890913          	addi	s2,s2,184
    80003274:	03490163          	beq	s2,s4,80003296 <handle_stop+0x58>
    if(t!=curr_t){
    80003278:	ff2a8ce3          	beq	s5,s2,80003270 <handle_stop+0x32>
      acquire(&t->lock);
    8000327c:	854a                	mv	a0,s2
    8000327e:	ffffe097          	auipc	ra,0xffffe
    80003282:	948080e7          	jalr	-1720(ra) # 80000bc6 <acquire>
      t->frozen=1;
    80003286:	03692a23          	sw	s6,52(s2)
      release(&t->lock);
    8000328a:	854a                	mv	a0,s2
    8000328c:	ffffe097          	auipc	ra,0xffffe
    80003290:	a04080e7          	jalr	-1532(ra) # 80000c90 <release>
    80003294:	bff1                	j	80003270 <handle_stop+0x32>
    }
  }
  int should_cont = check_should_cont(p);
    80003296:	854e                	mv	a0,s3
    80003298:	00000097          	auipc	ra,0x0
    8000329c:	f3e080e7          	jalr	-194(ra) # 800031d6 <check_should_cont>
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    800032a0:	0e89a783          	lw	a5,232(s3)
    800032a4:	2007f793          	andi	a5,a5,512
    800032a8:	e795                	bnez	a5,800032d4 <handle_stop+0x96>
    800032aa:	e50d                	bnez	a0,800032d4 <handle_stop+0x96>
    // printf("in handle stop, yielding pid=%d \n",p->pid);//TODO delete
    yield();
    800032ac:	fffff097          	auipc	ra,0xfffff
    800032b0:	2b0080e7          	jalr	688(ra) # 8000255c <yield>
    should_cont = check_should_cont(p);  
    800032b4:	854e                	mv	a0,s3
    800032b6:	00000097          	auipc	ra,0x0
    800032ba:	f20080e7          	jalr	-224(ra) # 800031d6 <check_should_cont>
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    800032be:	0e89a783          	lw	a5,232(s3)
    800032c2:	2007f793          	andi	a5,a5,512
    800032c6:	e799                	bnez	a5,800032d4 <handle_stop+0x96>
    800032c8:	d175                	beqz	a0,800032ac <handle_stop+0x6e>
    800032ca:	a029                	j	800032d4 <handle_stop+0x96>
  }

  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800032cc:	0b848493          	addi	s1,s1,184
    800032d0:	03448163          	beq	s1,s4,800032f2 <handle_stop+0xb4>
    if(t!=curr_t){
    800032d4:	fe9a8ce3          	beq	s5,s1,800032cc <handle_stop+0x8e>
      acquire(&t->lock);
    800032d8:	8526                	mv	a0,s1
    800032da:	ffffe097          	auipc	ra,0xffffe
    800032de:	8ec080e7          	jalr	-1812(ra) # 80000bc6 <acquire>
      t->frozen=0;
    800032e2:	0204aa23          	sw	zero,52(s1)
      release(&t->lock);
    800032e6:	8526                	mv	a0,s1
    800032e8:	ffffe097          	auipc	ra,0xffffe
    800032ec:	9a8080e7          	jalr	-1624(ra) # 80000c90 <release>
    800032f0:	bff1                	j	800032cc <handle_stop+0x8e>
    }
  }
  if(p->pending_signals&1<<SIGKILL)
    800032f2:	0e89a783          	lw	a5,232(s3)
    800032f6:	2007f793          	andi	a5,a5,512
    800032fa:	c781                	beqz	a5,80003302 <handle_stop+0xc4>
    p->killed=1;
    800032fc:	4785                	li	a5,1
    800032fe:	00f9ae23          	sw	a5,28(s3)
}
    80003302:	70e2                	ld	ra,56(sp)
    80003304:	7442                	ld	s0,48(sp)
    80003306:	74a2                	ld	s1,40(sp)
    80003308:	7902                	ld	s2,32(sp)
    8000330a:	69e2                	ld	s3,24(sp)
    8000330c:	6a42                	ld	s4,16(sp)
    8000330e:	6aa2                	ld	s5,8(sp)
    80003310:	6b02                	ld	s6,0(sp)
    80003312:	6121                	addi	sp,sp,64
    80003314:	8082                	ret

0000000080003316 <check_pending_signals>:

void 
check_pending_signals(struct proc* p){
    80003316:	711d                	addi	sp,sp,-96
    80003318:	ec86                	sd	ra,88(sp)
    8000331a:	e8a2                	sd	s0,80(sp)
    8000331c:	e4a6                	sd	s1,72(sp)
    8000331e:	e0ca                	sd	s2,64(sp)
    80003320:	fc4e                	sd	s3,56(sp)
    80003322:	f852                	sd	s4,48(sp)
    80003324:	f456                	sd	s5,40(sp)
    80003326:	f05a                	sd	s6,32(sp)
    80003328:	ec5e                	sd	s7,24(sp)
    8000332a:	e862                	sd	s8,16(sp)
    8000332c:	e466                	sd	s9,8(sp)
    8000332e:	e06a                	sd	s10,0(sp)
    80003330:	1080                	addi	s0,sp,96
    80003332:	89aa                	mv	s3,a0
  struct kthread *t= mykthread();
    80003334:	fffff097          	auipc	ra,0xfffff
    80003338:	814080e7          	jalr	-2028(ra) # 80001b48 <mykthread>
    8000333c:	8caa                	mv	s9,a0
  for(int sig_num=0;sig_num<32;sig_num++){
    8000333e:	0f898913          	addi	s2,s3,248
    80003342:	4481                	li	s1,0
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    80003344:	4a05                	li	s4,1
            p->killed = 1;
            release(&p->lock);
        }
      }

      else if(act.sa_handler==(void*)SIGKILL){
    80003346:	4c25                	li	s8,9
        p->killed=1;
      }else if(act.sa_handler==(void*)SIGSTOP){
    80003348:	4b45                	li	s6,17
        handle_stop(p);
      }      
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    8000334a:	4b85                	li	s7,1
        switch (sig_num)
    8000334c:	4d4d                	li	s10,19
  for(int sig_num=0;sig_num<32;sig_num++){
    8000334e:	02000a93          	li	s5,32
    80003352:	a0a1                	j	8000339a <check_pending_signals+0x84>
        switch (sig_num)
    80003354:	03648163          	beq	s1,s6,80003376 <check_pending_signals+0x60>
    80003358:	03a48763          	beq	s1,s10,80003386 <check_pending_signals+0x70>
            acquire(&p->lock);
    8000335c:	854e                	mv	a0,s3
    8000335e:	ffffe097          	auipc	ra,0xffffe
    80003362:	868080e7          	jalr	-1944(ra) # 80000bc6 <acquire>
            p->killed = 1;
    80003366:	0179ae23          	sw	s7,28(s3)
            release(&p->lock);
    8000336a:	854e                	mv	a0,s3
    8000336c:	ffffe097          	auipc	ra,0xffffe
    80003370:	924080e7          	jalr	-1756(ra) # 80000c90 <release>
    80003374:	a809                	j	80003386 <check_pending_signals+0x70>
            handle_stop(p);
    80003376:	854e                	mv	a0,s3
    80003378:	00000097          	auipc	ra,0x0
    8000337c:	ec6080e7          	jalr	-314(ra) # 8000323e <handle_stop>
            break;
    80003380:	a019                	j	80003386 <check_pending_signals+0x70>
        p->killed=1;
    80003382:	0179ae23          	sw	s7,28(s3)
        turn_off_bit(p, sig_num);

        return;
      }

      turn_off_bit(p, sig_num);            
    80003386:	85a6                	mv	a1,s1
    80003388:	854e                	mv	a0,s3
    8000338a:	00000097          	auipc	ra,0x0
    8000338e:	b68080e7          	jalr	-1176(ra) # 80002ef2 <turn_off_bit>
  for(int sig_num=0;sig_num<32;sig_num++){
    80003392:	2485                	addiw	s1,s1,1
    80003394:	0921                	addi	s2,s2,8
    80003396:	0d548963          	beq	s1,s5,80003468 <check_pending_signals+0x152>
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    8000339a:	009a173b          	sllw	a4,s4,s1
    8000339e:	0e89a783          	lw	a5,232(s3)
    800033a2:	8ff9                	and	a5,a5,a4
    800033a4:	2781                	sext.w	a5,a5
    800033a6:	d7f5                	beqz	a5,80003392 <check_pending_signals+0x7c>
    800033a8:	0ec9a783          	lw	a5,236(s3)
    800033ac:	8f7d                	and	a4,a4,a5
    800033ae:	2701                	sext.w	a4,a4
    800033b0:	f36d                	bnez	a4,80003392 <check_pending_signals+0x7c>
      act.sa_handler = p->signal_handlers[sig_num];
    800033b2:	00093703          	ld	a4,0(s2)
      if(act.sa_handler == (void*)SIG_DFL){
    800033b6:	df59                	beqz	a4,80003354 <check_pending_signals+0x3e>
      else if(act.sa_handler==(void*)SIGKILL){
    800033b8:	fd8705e3          	beq	a4,s8,80003382 <check_pending_signals+0x6c>
      }else if(act.sa_handler==(void*)SIGSTOP){
    800033bc:	0d670463          	beq	a4,s6,80003484 <check_pending_signals+0x16e>
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    800033c0:	fd7703e3          	beq	a4,s7,80003386 <check_pending_signals+0x70>
    800033c4:	2809a703          	lw	a4,640(s3)
    800033c8:	ff5d                	bnez	a4,80003386 <check_pending_signals+0x70>
      act.sigmask = p->handlers_sigmasks[sig_num];
    800033ca:	07c48713          	addi	a4,s1,124
    800033ce:	070a                	slli	a4,a4,0x2
    800033d0:	974e                	add	a4,a4,s3
    800033d2:	4718                	lw	a4,8(a4)
        p->handling_user_sig_flag = 1;
    800033d4:	4685                	li	a3,1
    800033d6:	28d9a023          	sw	a3,640(s3)
        p->signal_mask_backup = p->signal_mask;
    800033da:	0ef9a823          	sw	a5,240(s3)
        p->signal_mask= p->handlers_sigmasks[sig_num];
    800033de:	0ee9a623          	sw	a4,236(s3)
        t->trapframe->sp -= sizeof(struct trapframe);
    800033e2:	040cb703          	ld	a4,64(s9)
    800033e6:	7b1c                	ld	a5,48(a4)
    800033e8:	ee078793          	addi	a5,a5,-288
    800033ec:	fb1c                	sd	a5,48(a4)
        p->user_trapframe_backup = (struct trapframe* )(t->trapframe->sp);
    800033ee:	040cb783          	ld	a5,64(s9)
    800033f2:	7b8c                	ld	a1,48(a5)
    800033f4:	26b9bc23          	sd	a1,632(s3)
        copyout(p->pagetable, (uint64)p->user_trapframe_backup, (char *)t->trapframe, sizeof(struct trapframe));
    800033f8:	12000693          	li	a3,288
    800033fc:	040cb603          	ld	a2,64(s9)
    80003400:	0409b503          	ld	a0,64(s3)
    80003404:	ffffe097          	auipc	ra,0xffffe
    80003408:	2ec080e7          	jalr	748(ra) # 800016f0 <copyout>
        uint64 size = (uint64)&end_sigret - (uint64)&call_sigret;
    8000340c:	00004697          	auipc	a3,0x4
    80003410:	b0468693          	addi	a3,a3,-1276 # 80006f10 <end_sigret>
    80003414:	00004617          	auipc	a2,0x4
    80003418:	af460613          	addi	a2,a2,-1292 # 80006f08 <call_sigret>
        t->trapframe->sp -= size;
    8000341c:	040cb703          	ld	a4,64(s9)
    80003420:	40d605b3          	sub	a1,a2,a3
    80003424:	7b1c                	ld	a5,48(a4)
    80003426:	97ae                	add	a5,a5,a1
    80003428:	fb1c                	sd	a5,48(a4)
        copyout(p->pagetable, (uint64)t->trapframe->sp, (char *)&call_sigret, size);
    8000342a:	040cb783          	ld	a5,64(s9)
    8000342e:	8e91                	sub	a3,a3,a2
    80003430:	7b8c                	ld	a1,48(a5)
    80003432:	0409b503          	ld	a0,64(s3)
    80003436:	ffffe097          	auipc	ra,0xffffe
    8000343a:	2ba080e7          	jalr	698(ra) # 800016f0 <copyout>
        t->trapframe->a0 = sig_num;
    8000343e:	040cb783          	ld	a5,64(s9)
    80003442:	fba4                	sd	s1,112(a5)
        t->trapframe->ra = t->trapframe->sp;
    80003444:	040cb783          	ld	a5,64(s9)
    80003448:	7b98                	ld	a4,48(a5)
    8000344a:	f798                	sd	a4,40(a5)
        t->trapframe->epc = (uint64)p->signal_handlers[sig_num];
    8000344c:	040cb703          	ld	a4,64(s9)
    80003450:	01e48793          	addi	a5,s1,30
    80003454:	078e                	slli	a5,a5,0x3
    80003456:	97ce                	add	a5,a5,s3
    80003458:	679c                	ld	a5,8(a5)
    8000345a:	ef1c                	sd	a5,24(a4)
        turn_off_bit(p, sig_num);
    8000345c:	85a6                	mv	a1,s1
    8000345e:	854e                	mv	a0,s3
    80003460:	00000097          	auipc	ra,0x0
    80003464:	a92080e7          	jalr	-1390(ra) # 80002ef2 <turn_off_bit>
    }
  }
}
    80003468:	60e6                	ld	ra,88(sp)
    8000346a:	6446                	ld	s0,80(sp)
    8000346c:	64a6                	ld	s1,72(sp)
    8000346e:	6906                	ld	s2,64(sp)
    80003470:	79e2                	ld	s3,56(sp)
    80003472:	7a42                	ld	s4,48(sp)
    80003474:	7aa2                	ld	s5,40(sp)
    80003476:	7b02                	ld	s6,32(sp)
    80003478:	6be2                	ld	s7,24(sp)
    8000347a:	6c42                	ld	s8,16(sp)
    8000347c:	6ca2                	ld	s9,8(sp)
    8000347e:	6d02                	ld	s10,0(sp)
    80003480:	6125                	addi	sp,sp,96
    80003482:	8082                	ret
        handle_stop(p);
    80003484:	854e                	mv	a0,s3
    80003486:	00000097          	auipc	ra,0x0
    8000348a:	db8080e7          	jalr	-584(ra) # 8000323e <handle_stop>
    8000348e:	bde5                	j	80003386 <check_pending_signals+0x70>

0000000080003490 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80003490:	1101                	addi	sp,sp,-32
    80003492:	ec06                	sd	ra,24(sp)
    80003494:	e822                	sd	s0,16(sp)
    80003496:	e426                	sd	s1,8(sp)
    80003498:	e04a                	sd	s2,0(sp)
    8000349a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000349c:	ffffe097          	auipc	ra,0xffffe
    800034a0:	66c080e7          	jalr	1644(ra) # 80001b08 <myproc>
    800034a4:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    800034a6:	ffffe097          	auipc	ra,0xffffe
    800034aa:	6a2080e7          	jalr	1698(ra) # 80001b48 <mykthread>
    800034ae:	84aa                	mv	s1,a0
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800034b0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800034b4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800034b6:	10079073          	csrw	sstatus,a5

  // we're about to switch the destination of traps from
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();
  printf("after intr_off in usertrapret");
    800034ba:	00005517          	auipc	a0,0x5
    800034be:	05650513          	addi	a0,a0,86 # 80008510 <states.0+0x28>
    800034c2:	ffffd097          	auipc	ra,0xffffd
    800034c6:	0b6080e7          	jalr	182(ra) # 80000578 <printf>
  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800034ca:	00004617          	auipc	a2,0x4
    800034ce:	b3660613          	addi	a2,a2,-1226 # 80007000 <_trampoline>
    800034d2:	00004697          	auipc	a3,0x4
    800034d6:	b2e68693          	addi	a3,a3,-1234 # 80007000 <_trampoline>
    800034da:	8e91                	sub	a3,a3,a2
    800034dc:	040007b7          	lui	a5,0x4000
    800034e0:	17fd                	addi	a5,a5,-1
    800034e2:	07b2                	slli	a5,a5,0xc
    800034e4:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800034e6:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  t->trapframe->kernel_satp = r_satp();         // kernel page table
    800034ea:	60b8                	ld	a4,64(s1)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800034ec:	180026f3          	csrr	a3,satp
    800034f0:	e314                	sd	a3,0(a4)
  t->trapframe->kernel_sp = t->kstack + PGSIZE; // process's kernel stack
    800034f2:	60b8                	ld	a4,64(s1)
    800034f4:	7c94                	ld	a3,56(s1)
    800034f6:	6585                	lui	a1,0x1
    800034f8:	96ae                	add	a3,a3,a1
    800034fa:	e714                	sd	a3,8(a4)
  t->trapframe->kernel_trap = (uint64)usertrap;
    800034fc:	60b8                	ld	a4,64(s1)
    800034fe:	00000697          	auipc	a3,0x0
    80003502:	13e68693          	addi	a3,a3,318 # 8000363c <usertrap>
    80003506:	eb14                	sd	a3,16(a4)
  t->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80003508:	60b8                	ld	a4,64(s1)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000350a:	8692                	mv	a3,tp
    8000350c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000350e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80003512:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80003516:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000351a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(t->trapframe->epc);
    8000351e:	60b8                	ld	a4,64(s1)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003520:	6f18                	ld	a4,24(a4)
    80003522:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80003526:	04093583          	ld	a1,64(s2)
    8000352a:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000352c:	00004717          	auipc	a4,0x4
    80003530:	b6470713          	addi	a4,a4,-1180 # 80007090 <userret>
    80003534:	8f11                	sub	a4,a4,a2
    80003536:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80003538:	577d                	li	a4,-1
    8000353a:	177e                	slli	a4,a4,0x3f
    8000353c:	8dd9                	or	a1,a1,a4
    8000353e:	02000537          	lui	a0,0x2000
    80003542:	157d                	addi	a0,a0,-1
    80003544:	0536                	slli	a0,a0,0xd
    80003546:	9782                	jalr	a5
}
    80003548:	60e2                	ld	ra,24(sp)
    8000354a:	6442                	ld	s0,16(sp)
    8000354c:	64a2                	ld	s1,8(sp)
    8000354e:	6902                	ld	s2,0(sp)
    80003550:	6105                	addi	sp,sp,32
    80003552:	8082                	ret

0000000080003554 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80003554:	1101                	addi	sp,sp,-32
    80003556:	ec06                	sd	ra,24(sp)
    80003558:	e822                	sd	s0,16(sp)
    8000355a:	e426                	sd	s1,8(sp)
    8000355c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000355e:	0002f497          	auipc	s1,0x2f
    80003562:	3ca48493          	addi	s1,s1,970 # 80032928 <tickslock>
    80003566:	8526                	mv	a0,s1
    80003568:	ffffd097          	auipc	ra,0xffffd
    8000356c:	65e080e7          	jalr	1630(ra) # 80000bc6 <acquire>
  ticks++;
    80003570:	00006517          	auipc	a0,0x6
    80003574:	ac050513          	addi	a0,a0,-1344 # 80009030 <ticks>
    80003578:	411c                	lw	a5,0(a0)
    8000357a:	2785                	addiw	a5,a5,1
    8000357c:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000357e:	fffff097          	auipc	ra,0xfffff
    80003582:	1a4080e7          	jalr	420(ra) # 80002722 <wakeup>
  release(&tickslock);
    80003586:	8526                	mv	a0,s1
    80003588:	ffffd097          	auipc	ra,0xffffd
    8000358c:	708080e7          	jalr	1800(ra) # 80000c90 <release>
}
    80003590:	60e2                	ld	ra,24(sp)
    80003592:	6442                	ld	s0,16(sp)
    80003594:	64a2                	ld	s1,8(sp)
    80003596:	6105                	addi	sp,sp,32
    80003598:	8082                	ret

000000008000359a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000359a:	1101                	addi	sp,sp,-32
    8000359c:	ec06                	sd	ra,24(sp)
    8000359e:	e822                	sd	s0,16(sp)
    800035a0:	e426                	sd	s1,8(sp)
    800035a2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800035a4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800035a8:	00074d63          	bltz	a4,800035c2 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800035ac:	57fd                	li	a5,-1
    800035ae:	17fe                	slli	a5,a5,0x3f
    800035b0:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800035b2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800035b4:	06f70363          	beq	a4,a5,8000361a <devintr+0x80>
  }
}
    800035b8:	60e2                	ld	ra,24(sp)
    800035ba:	6442                	ld	s0,16(sp)
    800035bc:	64a2                	ld	s1,8(sp)
    800035be:	6105                	addi	sp,sp,32
    800035c0:	8082                	ret
     (scause & 0xff) == 9){
    800035c2:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800035c6:	46a5                	li	a3,9
    800035c8:	fed792e3          	bne	a5,a3,800035ac <devintr+0x12>
    int irq = plic_claim();
    800035cc:	00003097          	auipc	ra,0x3
    800035d0:	3bc080e7          	jalr	956(ra) # 80006988 <plic_claim>
    800035d4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800035d6:	47a9                	li	a5,10
    800035d8:	02f50763          	beq	a0,a5,80003606 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800035dc:	4785                	li	a5,1
    800035de:	02f50963          	beq	a0,a5,80003610 <devintr+0x76>
    return 1;
    800035e2:	4505                	li	a0,1
    } else if(irq){
    800035e4:	d8f1                	beqz	s1,800035b8 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800035e6:	85a6                	mv	a1,s1
    800035e8:	00005517          	auipc	a0,0x5
    800035ec:	f4850513          	addi	a0,a0,-184 # 80008530 <states.0+0x48>
    800035f0:	ffffd097          	auipc	ra,0xffffd
    800035f4:	f88080e7          	jalr	-120(ra) # 80000578 <printf>
      plic_complete(irq);
    800035f8:	8526                	mv	a0,s1
    800035fa:	00003097          	auipc	ra,0x3
    800035fe:	3b2080e7          	jalr	946(ra) # 800069ac <plic_complete>
    return 1;
    80003602:	4505                	li	a0,1
    80003604:	bf55                	j	800035b8 <devintr+0x1e>
      uartintr();
    80003606:	ffffd097          	auipc	ra,0xffffd
    8000360a:	384080e7          	jalr	900(ra) # 8000098a <uartintr>
    8000360e:	b7ed                	j	800035f8 <devintr+0x5e>
      virtio_disk_intr();
    80003610:	00004097          	auipc	ra,0x4
    80003614:	82e080e7          	jalr	-2002(ra) # 80006e3e <virtio_disk_intr>
    80003618:	b7c5                	j	800035f8 <devintr+0x5e>
    if(cpuid() == 0){
    8000361a:	ffffe097          	auipc	ra,0xffffe
    8000361e:	4ba080e7          	jalr	1210(ra) # 80001ad4 <cpuid>
    80003622:	c901                	beqz	a0,80003632 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80003624:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80003628:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000362a:	14479073          	csrw	sip,a5
    return 2;
    8000362e:	4509                	li	a0,2
    80003630:	b761                	j	800035b8 <devintr+0x1e>
      clockintr();
    80003632:	00000097          	auipc	ra,0x0
    80003636:	f22080e7          	jalr	-222(ra) # 80003554 <clockintr>
    8000363a:	b7ed                	j	80003624 <devintr+0x8a>

000000008000363c <usertrap>:
{
    8000363c:	1101                	addi	sp,sp,-32
    8000363e:	ec06                	sd	ra,24(sp)
    80003640:	e822                	sd	s0,16(sp)
    80003642:	e426                	sd	s1,8(sp)
    80003644:	e04a                	sd	s2,0(sp)
    80003646:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003648:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000364c:	1007f793          	andi	a5,a5,256
    80003650:	e3dd                	bnez	a5,800036f6 <usertrap+0xba>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003652:	00003797          	auipc	a5,0x3
    80003656:	22e78793          	addi	a5,a5,558 # 80006880 <kernelvec>
    8000365a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000365e:	ffffe097          	auipc	ra,0xffffe
    80003662:	4aa080e7          	jalr	1194(ra) # 80001b08 <myproc>
    80003666:	84aa                	mv	s1,a0
  struct kthread *t = mykthread();
    80003668:	ffffe097          	auipc	ra,0xffffe
    8000366c:	4e0080e7          	jalr	1248(ra) # 80001b48 <mykthread>
    80003670:	892a                	mv	s2,a0
  t->trapframe->epc = r_sepc();
    80003672:	613c                	ld	a5,64(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003674:	14102773          	csrr	a4,sepc
    80003678:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000367a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000367e:	47a1                	li	a5,8
    80003680:	08f71f63          	bne	a4,a5,8000371e <usertrap+0xe2>
    if(t->killed == 1)
    80003684:	5518                	lw	a4,40(a0)
    80003686:	4785                	li	a5,1
    80003688:	06f70f63          	beq	a4,a5,80003706 <usertrap+0xca>
    else if(p->killed)
    8000368c:	4cdc                	lw	a5,28(s1)
    8000368e:	e3d1                	bnez	a5,80003712 <usertrap+0xd6>
    t->trapframe->epc += 4;
    80003690:	04093703          	ld	a4,64(s2)
    80003694:	6f1c                	ld	a5,24(a4)
    80003696:	0791                	addi	a5,a5,4
    80003698:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000369a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000369e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800036a2:	10079073          	csrw	sstatus,a5
    syscall();
    800036a6:	00000097          	auipc	ra,0x0
    800036aa:	370080e7          	jalr	880(ra) # 80003a16 <syscall>
  if(holding(&p->lock))
    800036ae:	8526                	mv	a0,s1
    800036b0:	ffffd097          	auipc	ra,0xffffd
    800036b4:	49c080e7          	jalr	1180(ra) # 80000b4c <holding>
    800036b8:	e95d                	bnez	a0,8000376e <usertrap+0x132>
  acquire(&p->lock);
    800036ba:	8526                	mv	a0,s1
    800036bc:	ffffd097          	auipc	ra,0xffffd
    800036c0:	50a080e7          	jalr	1290(ra) # 80000bc6 <acquire>
  if(!p->handling_sig_flag){
    800036c4:	2844a783          	lw	a5,644(s1)
    800036c8:	cfc5                	beqz	a5,80003780 <usertrap+0x144>
  release(&p->lock);
    800036ca:	8526                	mv	a0,s1
    800036cc:	ffffd097          	auipc	ra,0xffffd
    800036d0:	5c4080e7          	jalr	1476(ra) # 80000c90 <release>
  if(t->killed == 1)
    800036d4:	02892703          	lw	a4,40(s2)
    800036d8:	4785                	li	a5,1
    800036da:	0cf70863          	beq	a4,a5,800037aa <usertrap+0x16e>
  else if(p->killed)
    800036de:	4cdc                	lw	a5,28(s1)
    800036e0:	ebf9                	bnez	a5,800037b6 <usertrap+0x17a>
  usertrapret();
    800036e2:	00000097          	auipc	ra,0x0
    800036e6:	dae080e7          	jalr	-594(ra) # 80003490 <usertrapret>
}
    800036ea:	60e2                	ld	ra,24(sp)
    800036ec:	6442                	ld	s0,16(sp)
    800036ee:	64a2                	ld	s1,8(sp)
    800036f0:	6902                	ld	s2,0(sp)
    800036f2:	6105                	addi	sp,sp,32
    800036f4:	8082                	ret
    panic("usertrap: not from user mode");
    800036f6:	00005517          	auipc	a0,0x5
    800036fa:	e5a50513          	addi	a0,a0,-422 # 80008550 <states.0+0x68>
    800036fe:	ffffd097          	auipc	ra,0xffffd
    80003702:	e30080e7          	jalr	-464(ra) # 8000052e <panic>
      kthread_exit(-1); // Kill current thread
    80003706:	557d                	li	a0,-1
    80003708:	fffff097          	auipc	ra,0xfffff
    8000370c:	216080e7          	jalr	534(ra) # 8000291e <kthread_exit>
    80003710:	b741                	j	80003690 <usertrap+0x54>
      exit(-1); // Kill the hole procces
    80003712:	557d                	li	a0,-1
    80003714:	fffff097          	auipc	ra,0xfffff
    80003718:	29e080e7          	jalr	670(ra) # 800029b2 <exit>
    8000371c:	bf95                	j	80003690 <usertrap+0x54>
  else if((which_dev = devintr()) != 0)
    8000371e:	00000097          	auipc	ra,0x0
    80003722:	e7c080e7          	jalr	-388(ra) # 8000359a <devintr>
    80003726:	c909                	beqz	a0,80003738 <usertrap+0xfc>
  if(which_dev == 2)
    80003728:	4789                	li	a5,2
    8000372a:	f8f512e3          	bne	a0,a5,800036ae <usertrap+0x72>
    yield();
    8000372e:	fffff097          	auipc	ra,0xfffff
    80003732:	e2e080e7          	jalr	-466(ra) # 8000255c <yield>
    80003736:	bfa5                	j	800036ae <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003738:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000373c:	50d0                	lw	a2,36(s1)
    8000373e:	00005517          	auipc	a0,0x5
    80003742:	e3250513          	addi	a0,a0,-462 # 80008570 <states.0+0x88>
    80003746:	ffffd097          	auipc	ra,0xffffd
    8000374a:	e32080e7          	jalr	-462(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000374e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003752:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003756:	00005517          	auipc	a0,0x5
    8000375a:	e4a50513          	addi	a0,a0,-438 # 800085a0 <states.0+0xb8>
    8000375e:	ffffd097          	auipc	ra,0xffffd
    80003762:	e1a080e7          	jalr	-486(ra) # 80000578 <printf>
    t->killed = 1;
    80003766:	4785                	li	a5,1
    80003768:	02f92423          	sw	a5,40(s2)
  if(which_dev == 2)
    8000376c:	b789                	j	800036ae <usertrap+0x72>
    printf("fuck i am holding the lock in usertrap\n");   // TODO : delete
    8000376e:	00005517          	auipc	a0,0x5
    80003772:	e5250513          	addi	a0,a0,-430 # 800085c0 <states.0+0xd8>
    80003776:	ffffd097          	auipc	ra,0xffffd
    8000377a:	e02080e7          	jalr	-510(ra) # 80000578 <printf>
    8000377e:	bf35                	j	800036ba <usertrap+0x7e>
    p->handling_sig_flag = 1;
    80003780:	4785                	li	a5,1
    80003782:	28f4a223          	sw	a5,644(s1)
    release(&p->lock);
    80003786:	8526                	mv	a0,s1
    80003788:	ffffd097          	auipc	ra,0xffffd
    8000378c:	508080e7          	jalr	1288(ra) # 80000c90 <release>
    check_pending_signals(p);
    80003790:	8526                	mv	a0,s1
    80003792:	00000097          	auipc	ra,0x0
    80003796:	b84080e7          	jalr	-1148(ra) # 80003316 <check_pending_signals>
    acquire(&p->lock);
    8000379a:	8526                	mv	a0,s1
    8000379c:	ffffd097          	auipc	ra,0xffffd
    800037a0:	42a080e7          	jalr	1066(ra) # 80000bc6 <acquire>
    p->handling_sig_flag = 0;
    800037a4:	2804a223          	sw	zero,644(s1)
    800037a8:	b70d                	j	800036ca <usertrap+0x8e>
    kthread_exit(-1); // Kill current thread
    800037aa:	557d                	li	a0,-1
    800037ac:	fffff097          	auipc	ra,0xfffff
    800037b0:	172080e7          	jalr	370(ra) # 8000291e <kthread_exit>
    800037b4:	b73d                	j	800036e2 <usertrap+0xa6>
    exit(-1); // Kill the hole procces
    800037b6:	557d                	li	a0,-1
    800037b8:	fffff097          	auipc	ra,0xfffff
    800037bc:	1fa080e7          	jalr	506(ra) # 800029b2 <exit>
    800037c0:	b70d                	j	800036e2 <usertrap+0xa6>

00000000800037c2 <kerneltrap>:
{
    800037c2:	7179                	addi	sp,sp,-48
    800037c4:	f406                	sd	ra,40(sp)
    800037c6:	f022                	sd	s0,32(sp)
    800037c8:	ec26                	sd	s1,24(sp)
    800037ca:	e84a                	sd	s2,16(sp)
    800037cc:	e44e                	sd	s3,8(sp)
    800037ce:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800037d0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800037d4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800037d8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800037dc:	1004f793          	andi	a5,s1,256
    800037e0:	cb85                	beqz	a5,80003810 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800037e2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800037e6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800037e8:	ef85                	bnez	a5,80003820 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800037ea:	00000097          	auipc	ra,0x0
    800037ee:	db0080e7          	jalr	-592(ra) # 8000359a <devintr>
    800037f2:	cd1d                	beqz	a0,80003830 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    800037f4:	4789                	li	a5,2
    800037f6:	06f50a63          	beq	a0,a5,8000386a <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800037fa:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800037fe:	10049073          	csrw	sstatus,s1
}
    80003802:	70a2                	ld	ra,40(sp)
    80003804:	7402                	ld	s0,32(sp)
    80003806:	64e2                	ld	s1,24(sp)
    80003808:	6942                	ld	s2,16(sp)
    8000380a:	69a2                	ld	s3,8(sp)
    8000380c:	6145                	addi	sp,sp,48
    8000380e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003810:	00005517          	auipc	a0,0x5
    80003814:	dd850513          	addi	a0,a0,-552 # 800085e8 <states.0+0x100>
    80003818:	ffffd097          	auipc	ra,0xffffd
    8000381c:	d16080e7          	jalr	-746(ra) # 8000052e <panic>
    panic("kerneltrap: interrupts enabled");
    80003820:	00005517          	auipc	a0,0x5
    80003824:	df050513          	addi	a0,a0,-528 # 80008610 <states.0+0x128>
    80003828:	ffffd097          	auipc	ra,0xffffd
    8000382c:	d06080e7          	jalr	-762(ra) # 8000052e <panic>
    printf("scause %p\n", scause);
    80003830:	85ce                	mv	a1,s3
    80003832:	00005517          	auipc	a0,0x5
    80003836:	dfe50513          	addi	a0,a0,-514 # 80008630 <states.0+0x148>
    8000383a:	ffffd097          	auipc	ra,0xffffd
    8000383e:	d3e080e7          	jalr	-706(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003842:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003846:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000384a:	00005517          	auipc	a0,0x5
    8000384e:	df650513          	addi	a0,a0,-522 # 80008640 <states.0+0x158>
    80003852:	ffffd097          	auipc	ra,0xffffd
    80003856:	d26080e7          	jalr	-730(ra) # 80000578 <printf>
    panic("kerneltrap");
    8000385a:	00005517          	auipc	a0,0x5
    8000385e:	dfe50513          	addi	a0,a0,-514 # 80008658 <states.0+0x170>
    80003862:	ffffd097          	auipc	ra,0xffffd
    80003866:	ccc080e7          	jalr	-820(ra) # 8000052e <panic>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    8000386a:	ffffe097          	auipc	ra,0xffffe
    8000386e:	29e080e7          	jalr	670(ra) # 80001b08 <myproc>
    80003872:	d541                	beqz	a0,800037fa <kerneltrap+0x38>
    80003874:	ffffe097          	auipc	ra,0xffffe
    80003878:	2d4080e7          	jalr	724(ra) # 80001b48 <mykthread>
    8000387c:	dd3d                	beqz	a0,800037fa <kerneltrap+0x38>
    8000387e:	ffffe097          	auipc	ra,0xffffe
    80003882:	2ca080e7          	jalr	714(ra) # 80001b48 <mykthread>
    80003886:	4d18                	lw	a4,24(a0)
    80003888:	4791                	li	a5,4
    8000388a:	f6f718e3          	bne	a4,a5,800037fa <kerneltrap+0x38>
    yield();
    8000388e:	fffff097          	auipc	ra,0xfffff
    80003892:	cce080e7          	jalr	-818(ra) # 8000255c <yield>
    80003896:	b795                	j	800037fa <kerneltrap+0x38>

0000000080003898 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003898:	1101                	addi	sp,sp,-32
    8000389a:	ec06                	sd	ra,24(sp)
    8000389c:	e822                	sd	s0,16(sp)
    8000389e:	e426                	sd	s1,8(sp)
    800038a0:	1000                	addi	s0,sp,32
    800038a2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800038a4:	ffffe097          	auipc	ra,0xffffe
    800038a8:	264080e7          	jalr	612(ra) # 80001b08 <myproc>
  struct kthread *t = mykthread();
    800038ac:	ffffe097          	auipc	ra,0xffffe
    800038b0:	29c080e7          	jalr	668(ra) # 80001b48 <mykthread>
  switch (n) {
    800038b4:	4795                	li	a5,5
    800038b6:	0497e163          	bltu	a5,s1,800038f8 <argraw+0x60>
    800038ba:	048a                	slli	s1,s1,0x2
    800038bc:	00005717          	auipc	a4,0x5
    800038c0:	dd470713          	addi	a4,a4,-556 # 80008690 <states.0+0x1a8>
    800038c4:	94ba                	add	s1,s1,a4
    800038c6:	409c                	lw	a5,0(s1)
    800038c8:	97ba                	add	a5,a5,a4
    800038ca:	8782                	jr	a5
  case 0:
    return t->trapframe->a0;
    800038cc:	613c                	ld	a5,64(a0)
    800038ce:	7ba8                	ld	a0,112(a5)
  case 5:
    return t->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800038d0:	60e2                	ld	ra,24(sp)
    800038d2:	6442                	ld	s0,16(sp)
    800038d4:	64a2                	ld	s1,8(sp)
    800038d6:	6105                	addi	sp,sp,32
    800038d8:	8082                	ret
    return t->trapframe->a1;
    800038da:	613c                	ld	a5,64(a0)
    800038dc:	7fa8                	ld	a0,120(a5)
    800038de:	bfcd                	j	800038d0 <argraw+0x38>
    return t->trapframe->a2;
    800038e0:	613c                	ld	a5,64(a0)
    800038e2:	63c8                	ld	a0,128(a5)
    800038e4:	b7f5                	j	800038d0 <argraw+0x38>
    return t->trapframe->a3;
    800038e6:	613c                	ld	a5,64(a0)
    800038e8:	67c8                	ld	a0,136(a5)
    800038ea:	b7dd                	j	800038d0 <argraw+0x38>
    return t->trapframe->a4;
    800038ec:	613c                	ld	a5,64(a0)
    800038ee:	6bc8                	ld	a0,144(a5)
    800038f0:	b7c5                	j	800038d0 <argraw+0x38>
    return t->trapframe->a5;
    800038f2:	613c                	ld	a5,64(a0)
    800038f4:	6fc8                	ld	a0,152(a5)
    800038f6:	bfe9                	j	800038d0 <argraw+0x38>
  panic("argraw");
    800038f8:	00005517          	auipc	a0,0x5
    800038fc:	d7050513          	addi	a0,a0,-656 # 80008668 <states.0+0x180>
    80003900:	ffffd097          	auipc	ra,0xffffd
    80003904:	c2e080e7          	jalr	-978(ra) # 8000052e <panic>

0000000080003908 <fetchaddr>:
{
    80003908:	1101                	addi	sp,sp,-32
    8000390a:	ec06                	sd	ra,24(sp)
    8000390c:	e822                	sd	s0,16(sp)
    8000390e:	e426                	sd	s1,8(sp)
    80003910:	e04a                	sd	s2,0(sp)
    80003912:	1000                	addi	s0,sp,32
    80003914:	84aa                	mv	s1,a0
    80003916:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003918:	ffffe097          	auipc	ra,0xffffe
    8000391c:	1f0080e7          	jalr	496(ra) # 80001b08 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003920:	7d1c                	ld	a5,56(a0)
    80003922:	02f4f863          	bgeu	s1,a5,80003952 <fetchaddr+0x4a>
    80003926:	00848713          	addi	a4,s1,8
    8000392a:	02e7e663          	bltu	a5,a4,80003956 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000392e:	46a1                	li	a3,8
    80003930:	8626                	mv	a2,s1
    80003932:	85ca                	mv	a1,s2
    80003934:	6128                	ld	a0,64(a0)
    80003936:	ffffe097          	auipc	ra,0xffffe
    8000393a:	e46080e7          	jalr	-442(ra) # 8000177c <copyin>
    8000393e:	00a03533          	snez	a0,a0
    80003942:	40a00533          	neg	a0,a0
}
    80003946:	60e2                	ld	ra,24(sp)
    80003948:	6442                	ld	s0,16(sp)
    8000394a:	64a2                	ld	s1,8(sp)
    8000394c:	6902                	ld	s2,0(sp)
    8000394e:	6105                	addi	sp,sp,32
    80003950:	8082                	ret
    return -1;
    80003952:	557d                	li	a0,-1
    80003954:	bfcd                	j	80003946 <fetchaddr+0x3e>
    80003956:	557d                	li	a0,-1
    80003958:	b7fd                	j	80003946 <fetchaddr+0x3e>

000000008000395a <fetchstr>:
{
    8000395a:	7179                	addi	sp,sp,-48
    8000395c:	f406                	sd	ra,40(sp)
    8000395e:	f022                	sd	s0,32(sp)
    80003960:	ec26                	sd	s1,24(sp)
    80003962:	e84a                	sd	s2,16(sp)
    80003964:	e44e                	sd	s3,8(sp)
    80003966:	1800                	addi	s0,sp,48
    80003968:	892a                	mv	s2,a0
    8000396a:	84ae                	mv	s1,a1
    8000396c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000396e:	ffffe097          	auipc	ra,0xffffe
    80003972:	19a080e7          	jalr	410(ra) # 80001b08 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003976:	86ce                	mv	a3,s3
    80003978:	864a                	mv	a2,s2
    8000397a:	85a6                	mv	a1,s1
    8000397c:	6128                	ld	a0,64(a0)
    8000397e:	ffffe097          	auipc	ra,0xffffe
    80003982:	e8c080e7          	jalr	-372(ra) # 8000180a <copyinstr>
  if(err < 0)
    80003986:	00054763          	bltz	a0,80003994 <fetchstr+0x3a>
  return strlen(buf);
    8000398a:	8526                	mv	a0,s1
    8000398c:	ffffd097          	auipc	ra,0xffffd
    80003990:	4d0080e7          	jalr	1232(ra) # 80000e5c <strlen>
}
    80003994:	70a2                	ld	ra,40(sp)
    80003996:	7402                	ld	s0,32(sp)
    80003998:	64e2                	ld	s1,24(sp)
    8000399a:	6942                	ld	s2,16(sp)
    8000399c:	69a2                	ld	s3,8(sp)
    8000399e:	6145                	addi	sp,sp,48
    800039a0:	8082                	ret

00000000800039a2 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800039a2:	1101                	addi	sp,sp,-32
    800039a4:	ec06                	sd	ra,24(sp)
    800039a6:	e822                	sd	s0,16(sp)
    800039a8:	e426                	sd	s1,8(sp)
    800039aa:	1000                	addi	s0,sp,32
    800039ac:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800039ae:	00000097          	auipc	ra,0x0
    800039b2:	eea080e7          	jalr	-278(ra) # 80003898 <argraw>
    800039b6:	c088                	sw	a0,0(s1)
  return 0;
}
    800039b8:	4501                	li	a0,0
    800039ba:	60e2                	ld	ra,24(sp)
    800039bc:	6442                	ld	s0,16(sp)
    800039be:	64a2                	ld	s1,8(sp)
    800039c0:	6105                	addi	sp,sp,32
    800039c2:	8082                	ret

00000000800039c4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800039c4:	1101                	addi	sp,sp,-32
    800039c6:	ec06                	sd	ra,24(sp)
    800039c8:	e822                	sd	s0,16(sp)
    800039ca:	e426                	sd	s1,8(sp)
    800039cc:	1000                	addi	s0,sp,32
    800039ce:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800039d0:	00000097          	auipc	ra,0x0
    800039d4:	ec8080e7          	jalr	-312(ra) # 80003898 <argraw>
    800039d8:	e088                	sd	a0,0(s1)
  return 0;
}
    800039da:	4501                	li	a0,0
    800039dc:	60e2                	ld	ra,24(sp)
    800039de:	6442                	ld	s0,16(sp)
    800039e0:	64a2                	ld	s1,8(sp)
    800039e2:	6105                	addi	sp,sp,32
    800039e4:	8082                	ret

00000000800039e6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800039e6:	1101                	addi	sp,sp,-32
    800039e8:	ec06                	sd	ra,24(sp)
    800039ea:	e822                	sd	s0,16(sp)
    800039ec:	e426                	sd	s1,8(sp)
    800039ee:	e04a                	sd	s2,0(sp)
    800039f0:	1000                	addi	s0,sp,32
    800039f2:	84ae                	mv	s1,a1
    800039f4:	8932                	mv	s2,a2
  *ip = argraw(n);
    800039f6:	00000097          	auipc	ra,0x0
    800039fa:	ea2080e7          	jalr	-350(ra) # 80003898 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    800039fe:	864a                	mv	a2,s2
    80003a00:	85a6                	mv	a1,s1
    80003a02:	00000097          	auipc	ra,0x0
    80003a06:	f58080e7          	jalr	-168(ra) # 8000395a <fetchstr>
}
    80003a0a:	60e2                	ld	ra,24(sp)
    80003a0c:	6442                	ld	s0,16(sp)
    80003a0e:	64a2                	ld	s1,8(sp)
    80003a10:	6902                	ld	s2,0(sp)
    80003a12:	6105                	addi	sp,sp,32
    80003a14:	8082                	ret

0000000080003a16 <syscall>:
[SYS_kthread_join] sys_kthread_join,
};

void
syscall(void)
{
    80003a16:	7179                	addi	sp,sp,-48
    80003a18:	f406                	sd	ra,40(sp)
    80003a1a:	f022                	sd	s0,32(sp)
    80003a1c:	ec26                	sd	s1,24(sp)
    80003a1e:	e84a                	sd	s2,16(sp)
    80003a20:	e44e                	sd	s3,8(sp)
    80003a22:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80003a24:	ffffe097          	auipc	ra,0xffffe
    80003a28:	0e4080e7          	jalr	228(ra) # 80001b08 <myproc>
    80003a2c:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80003a2e:	ffffe097          	auipc	ra,0xffffe
    80003a32:	11a080e7          	jalr	282(ra) # 80001b48 <mykthread>
    80003a36:	84aa                	mv	s1,a0

  num = t->trapframe->a7;
    80003a38:	04053983          	ld	s3,64(a0)
    80003a3c:	0a89b783          	ld	a5,168(s3)
    80003a40:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003a44:	37fd                	addiw	a5,a5,-1
    80003a46:	476d                	li	a4,27
    80003a48:	00f76f63          	bltu	a4,a5,80003a66 <syscall+0x50>
    80003a4c:	00369713          	slli	a4,a3,0x3
    80003a50:	00005797          	auipc	a5,0x5
    80003a54:	c5878793          	addi	a5,a5,-936 # 800086a8 <syscalls>
    80003a58:	97ba                	add	a5,a5,a4
    80003a5a:	639c                	ld	a5,0(a5)
    80003a5c:	c789                	beqz	a5,80003a66 <syscall+0x50>
    t->trapframe->a0 = syscalls[num]();
    80003a5e:	9782                	jalr	a5
    80003a60:	06a9b823          	sd	a0,112(s3)
    80003a64:	a005                	j	80003a84 <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003a66:	0d890613          	addi	a2,s2,216
    80003a6a:	02492583          	lw	a1,36(s2)
    80003a6e:	00005517          	auipc	a0,0x5
    80003a72:	c0250513          	addi	a0,a0,-1022 # 80008670 <states.0+0x188>
    80003a76:	ffffd097          	auipc	ra,0xffffd
    80003a7a:	b02080e7          	jalr	-1278(ra) # 80000578 <printf>
            p->pid, p->name, num);
    t->trapframe->a0 = -1;
    80003a7e:	60bc                	ld	a5,64(s1)
    80003a80:	577d                	li	a4,-1
    80003a82:	fbb8                	sd	a4,112(a5)
  }
}
    80003a84:	70a2                	ld	ra,40(sp)
    80003a86:	7402                	ld	s0,32(sp)
    80003a88:	64e2                	ld	s1,24(sp)
    80003a8a:	6942                	ld	s2,16(sp)
    80003a8c:	69a2                	ld	s3,8(sp)
    80003a8e:	6145                	addi	sp,sp,48
    80003a90:	8082                	ret

0000000080003a92 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003a92:	1101                	addi	sp,sp,-32
    80003a94:	ec06                	sd	ra,24(sp)
    80003a96:	e822                	sd	s0,16(sp)
    80003a98:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003a9a:	fec40593          	addi	a1,s0,-20
    80003a9e:	4501                	li	a0,0
    80003aa0:	00000097          	auipc	ra,0x0
    80003aa4:	f02080e7          	jalr	-254(ra) # 800039a2 <argint>
    return -1;
    80003aa8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003aaa:	00054963          	bltz	a0,80003abc <sys_exit+0x2a>
  exit(n);
    80003aae:	fec42503          	lw	a0,-20(s0)
    80003ab2:	fffff097          	auipc	ra,0xfffff
    80003ab6:	f00080e7          	jalr	-256(ra) # 800029b2 <exit>
  return 0;  // not reached
    80003aba:	4781                	li	a5,0
}
    80003abc:	853e                	mv	a0,a5
    80003abe:	60e2                	ld	ra,24(sp)
    80003ac0:	6442                	ld	s0,16(sp)
    80003ac2:	6105                	addi	sp,sp,32
    80003ac4:	8082                	ret

0000000080003ac6 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003ac6:	1141                	addi	sp,sp,-16
    80003ac8:	e406                	sd	ra,8(sp)
    80003aca:	e022                	sd	s0,0(sp)
    80003acc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003ace:	ffffe097          	auipc	ra,0xffffe
    80003ad2:	03a080e7          	jalr	58(ra) # 80001b08 <myproc>
}
    80003ad6:	5148                	lw	a0,36(a0)
    80003ad8:	60a2                	ld	ra,8(sp)
    80003ada:	6402                	ld	s0,0(sp)
    80003adc:	0141                	addi	sp,sp,16
    80003ade:	8082                	ret

0000000080003ae0 <sys_fork>:

uint64
sys_fork(void)
{
    80003ae0:	1141                	addi	sp,sp,-16
    80003ae2:	e406                	sd	ra,8(sp)
    80003ae4:	e022                	sd	s0,0(sp)
    80003ae6:	0800                	addi	s0,sp,16
  return fork();
    80003ae8:	ffffe097          	auipc	ra,0xffffe
    80003aec:	6a2080e7          	jalr	1698(ra) # 8000218a <fork>
}
    80003af0:	60a2                	ld	ra,8(sp)
    80003af2:	6402                	ld	s0,0(sp)
    80003af4:	0141                	addi	sp,sp,16
    80003af6:	8082                	ret

0000000080003af8 <sys_wait>:

uint64
sys_wait(void)
{
    80003af8:	1101                	addi	sp,sp,-32
    80003afa:	ec06                	sd	ra,24(sp)
    80003afc:	e822                	sd	s0,16(sp)
    80003afe:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003b00:	fe840593          	addi	a1,s0,-24
    80003b04:	4501                	li	a0,0
    80003b06:	00000097          	auipc	ra,0x0
    80003b0a:	ebe080e7          	jalr	-322(ra) # 800039c4 <argaddr>
    80003b0e:	87aa                	mv	a5,a0
    return -1;
    80003b10:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003b12:	0007c863          	bltz	a5,80003b22 <sys_wait+0x2a>
  return wait(p);
    80003b16:	fe843503          	ld	a0,-24(s0)
    80003b1a:	fffff097          	auipc	ra,0xfffff
    80003b1e:	ae2080e7          	jalr	-1310(ra) # 800025fc <wait>
}
    80003b22:	60e2                	ld	ra,24(sp)
    80003b24:	6442                	ld	s0,16(sp)
    80003b26:	6105                	addi	sp,sp,32
    80003b28:	8082                	ret

0000000080003b2a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003b2a:	7179                	addi	sp,sp,-48
    80003b2c:	f406                	sd	ra,40(sp)
    80003b2e:	f022                	sd	s0,32(sp)
    80003b30:	ec26                	sd	s1,24(sp)
    80003b32:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003b34:	fdc40593          	addi	a1,s0,-36
    80003b38:	4501                	li	a0,0
    80003b3a:	00000097          	auipc	ra,0x0
    80003b3e:	e68080e7          	jalr	-408(ra) # 800039a2 <argint>
    return -1;
    80003b42:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003b44:	00054f63          	bltz	a0,80003b62 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003b48:	ffffe097          	auipc	ra,0xffffe
    80003b4c:	fc0080e7          	jalr	-64(ra) # 80001b08 <myproc>
    80003b50:	5d04                	lw	s1,56(a0)
  if(growproc(n) < 0)
    80003b52:	fdc42503          	lw	a0,-36(s0)
    80003b56:	ffffe097          	auipc	ra,0xffffe
    80003b5a:	5c0080e7          	jalr	1472(ra) # 80002116 <growproc>
    80003b5e:	00054863          	bltz	a0,80003b6e <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003b62:	8526                	mv	a0,s1
    80003b64:	70a2                	ld	ra,40(sp)
    80003b66:	7402                	ld	s0,32(sp)
    80003b68:	64e2                	ld	s1,24(sp)
    80003b6a:	6145                	addi	sp,sp,48
    80003b6c:	8082                	ret
    return -1;
    80003b6e:	54fd                	li	s1,-1
    80003b70:	bfcd                	j	80003b62 <sys_sbrk+0x38>

0000000080003b72 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003b72:	7139                	addi	sp,sp,-64
    80003b74:	fc06                	sd	ra,56(sp)
    80003b76:	f822                	sd	s0,48(sp)
    80003b78:	f426                	sd	s1,40(sp)
    80003b7a:	f04a                	sd	s2,32(sp)
    80003b7c:	ec4e                	sd	s3,24(sp)
    80003b7e:	e852                	sd	s4,16(sp)
    80003b80:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003b82:	fcc40593          	addi	a1,s0,-52
    80003b86:	4501                	li	a0,0
    80003b88:	00000097          	auipc	ra,0x0
    80003b8c:	e1a080e7          	jalr	-486(ra) # 800039a2 <argint>
    return -1;
    80003b90:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003b92:	06054763          	bltz	a0,80003c00 <sys_sleep+0x8e>
  acquire(&tickslock);
    80003b96:	0002f517          	auipc	a0,0x2f
    80003b9a:	d9250513          	addi	a0,a0,-622 # 80032928 <tickslock>
    80003b9e:	ffffd097          	auipc	ra,0xffffd
    80003ba2:	028080e7          	jalr	40(ra) # 80000bc6 <acquire>
  ticks0 = ticks;
    80003ba6:	00005997          	auipc	s3,0x5
    80003baa:	48a9a983          	lw	s3,1162(s3) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80003bae:	fcc42783          	lw	a5,-52(s0)
    80003bb2:	cf95                	beqz	a5,80003bee <sys_sleep+0x7c>
    if(myproc()->killed==1){
    80003bb4:	4905                	li	s2,1
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003bb6:	0002fa17          	auipc	s4,0x2f
    80003bba:	d72a0a13          	addi	s4,s4,-654 # 80032928 <tickslock>
    80003bbe:	00005497          	auipc	s1,0x5
    80003bc2:	47248493          	addi	s1,s1,1138 # 80009030 <ticks>
    if(myproc()->killed==1){
    80003bc6:	ffffe097          	auipc	ra,0xffffe
    80003bca:	f42080e7          	jalr	-190(ra) # 80001b08 <myproc>
    80003bce:	4d5c                	lw	a5,28(a0)
    80003bd0:	05278163          	beq	a5,s2,80003c12 <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    80003bd4:	85d2                	mv	a1,s4
    80003bd6:	8526                	mv	a0,s1
    80003bd8:	fffff097          	auipc	ra,0xfffff
    80003bdc:	9c0080e7          	jalr	-1600(ra) # 80002598 <sleep>
  while(ticks - ticks0 < n){
    80003be0:	409c                	lw	a5,0(s1)
    80003be2:	413787bb          	subw	a5,a5,s3
    80003be6:	fcc42703          	lw	a4,-52(s0)
    80003bea:	fce7eee3          	bltu	a5,a4,80003bc6 <sys_sleep+0x54>
  }
  release(&tickslock);
    80003bee:	0002f517          	auipc	a0,0x2f
    80003bf2:	d3a50513          	addi	a0,a0,-710 # 80032928 <tickslock>
    80003bf6:	ffffd097          	auipc	ra,0xffffd
    80003bfa:	09a080e7          	jalr	154(ra) # 80000c90 <release>
  return 0;
    80003bfe:	4781                	li	a5,0
}
    80003c00:	853e                	mv	a0,a5
    80003c02:	70e2                	ld	ra,56(sp)
    80003c04:	7442                	ld	s0,48(sp)
    80003c06:	74a2                	ld	s1,40(sp)
    80003c08:	7902                	ld	s2,32(sp)
    80003c0a:	69e2                	ld	s3,24(sp)
    80003c0c:	6a42                	ld	s4,16(sp)
    80003c0e:	6121                	addi	sp,sp,64
    80003c10:	8082                	ret
      release(&tickslock);
    80003c12:	0002f517          	auipc	a0,0x2f
    80003c16:	d1650513          	addi	a0,a0,-746 # 80032928 <tickslock>
    80003c1a:	ffffd097          	auipc	ra,0xffffd
    80003c1e:	076080e7          	jalr	118(ra) # 80000c90 <release>
      return -1;
    80003c22:	57fd                	li	a5,-1
    80003c24:	bff1                	j	80003c00 <sys_sleep+0x8e>

0000000080003c26 <sys_kill>:

uint64
sys_kill(void)
{
    80003c26:	1101                	addi	sp,sp,-32
    80003c28:	ec06                	sd	ra,24(sp)
    80003c2a:	e822                	sd	s0,16(sp)
    80003c2c:	1000                	addi	s0,sp,32
  int pid;
  int signum;

  if(argint(0, &pid) < 0)
    80003c2e:	fec40593          	addi	a1,s0,-20
    80003c32:	4501                	li	a0,0
    80003c34:	00000097          	auipc	ra,0x0
    80003c38:	d6e080e7          	jalr	-658(ra) # 800039a2 <argint>
    80003c3c:	87aa                	mv	a5,a0
    return -1;
    80003c3e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003c40:	0207c963          	bltz	a5,80003c72 <sys_kill+0x4c>
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003c44:	fe840593          	addi	a1,s0,-24
    80003c48:	4505                	li	a0,1
    80003c4a:	00000097          	auipc	ra,0x0
    80003c4e:	d58080e7          	jalr	-680(ra) # 800039a2 <argint>
    80003c52:	02054463          	bltz	a0,80003c7a <sys_kill+0x54>
    80003c56:	fe842583          	lw	a1,-24(s0)
    80003c5a:	0005871b          	sext.w	a4,a1
    80003c5e:	47fd                	li	a5,31
    return -1;
    80003c60:	557d                	li	a0,-1
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003c62:	00e7e863          	bltu	a5,a4,80003c72 <sys_kill+0x4c>
  return kill(pid, signum);
    80003c66:	fec42503          	lw	a0,-20(s0)
    80003c6a:	fffff097          	auipc	ra,0xfffff
    80003c6e:	184080e7          	jalr	388(ra) # 80002dee <kill>
}
    80003c72:	60e2                	ld	ra,24(sp)
    80003c74:	6442                	ld	s0,16(sp)
    80003c76:	6105                	addi	sp,sp,32
    80003c78:	8082                	ret
    return -1;
    80003c7a:	557d                	li	a0,-1
    80003c7c:	bfdd                	j	80003c72 <sys_kill+0x4c>

0000000080003c7e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003c7e:	1101                	addi	sp,sp,-32
    80003c80:	ec06                	sd	ra,24(sp)
    80003c82:	e822                	sd	s0,16(sp)
    80003c84:	e426                	sd	s1,8(sp)
    80003c86:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003c88:	0002f517          	auipc	a0,0x2f
    80003c8c:	ca050513          	addi	a0,a0,-864 # 80032928 <tickslock>
    80003c90:	ffffd097          	auipc	ra,0xffffd
    80003c94:	f36080e7          	jalr	-202(ra) # 80000bc6 <acquire>
  xticks = ticks;
    80003c98:	00005497          	auipc	s1,0x5
    80003c9c:	3984a483          	lw	s1,920(s1) # 80009030 <ticks>
  release(&tickslock);
    80003ca0:	0002f517          	auipc	a0,0x2f
    80003ca4:	c8850513          	addi	a0,a0,-888 # 80032928 <tickslock>
    80003ca8:	ffffd097          	auipc	ra,0xffffd
    80003cac:	fe8080e7          	jalr	-24(ra) # 80000c90 <release>
  return xticks;
}
    80003cb0:	02049513          	slli	a0,s1,0x20
    80003cb4:	9101                	srli	a0,a0,0x20
    80003cb6:	60e2                	ld	ra,24(sp)
    80003cb8:	6442                	ld	s0,16(sp)
    80003cba:	64a2                	ld	s1,8(sp)
    80003cbc:	6105                	addi	sp,sp,32
    80003cbe:	8082                	ret

0000000080003cc0 <sys_sigprocmask>:

uint64
sys_sigprocmask(void)
{
    80003cc0:	1101                	addi	sp,sp,-32
    80003cc2:	ec06                	sd	ra,24(sp)
    80003cc4:	e822                	sd	s0,16(sp)
    80003cc6:	1000                	addi	s0,sp,32
  int sigmask;

  if(argint(0, &sigmask) < 0)
    80003cc8:	fec40593          	addi	a1,s0,-20
    80003ccc:	4501                	li	a0,0
    80003cce:	00000097          	auipc	ra,0x0
    80003cd2:	cd4080e7          	jalr	-812(ra) # 800039a2 <argint>
    80003cd6:	87aa                	mv	a5,a0
    return -1;
    80003cd8:	557d                	li	a0,-1
  if(argint(0, &sigmask) < 0)
    80003cda:	0007ca63          	bltz	a5,80003cee <sys_sigprocmask+0x2e>
  return sigprocmask((uint)sigmask);
    80003cde:	fec42503          	lw	a0,-20(s0)
    80003ce2:	fffff097          	auipc	ra,0xfffff
    80003ce6:	f36080e7          	jalr	-202(ra) # 80002c18 <sigprocmask>
    80003cea:	1502                	slli	a0,a0,0x20
    80003cec:	9101                	srli	a0,a0,0x20
}
    80003cee:	60e2                	ld	ra,24(sp)
    80003cf0:	6442                	ld	s0,16(sp)
    80003cf2:	6105                	addi	sp,sp,32
    80003cf4:	8082                	ret

0000000080003cf6 <sys_sigaction>:

uint64
sys_sigaction(void)
{
    80003cf6:	7179                	addi	sp,sp,-48
    80003cf8:	f406                	sd	ra,40(sp)
    80003cfa:	f022                	sd	s0,32(sp)
    80003cfc:	1800                	addi	s0,sp,48
  int signum;
  uint64 newact;
  uint64 oldact;
  
  if(argint(0, &signum) < 0)
    80003cfe:	fec40593          	addi	a1,s0,-20
    80003d02:	4501                	li	a0,0
    80003d04:	00000097          	auipc	ra,0x0
    80003d08:	c9e080e7          	jalr	-866(ra) # 800039a2 <argint>
    return -1;
    80003d0c:	57fd                	li	a5,-1
  if(argint(0, &signum) < 0)
    80003d0e:	04054163          	bltz	a0,80003d50 <sys_sigaction+0x5a>
  if(argaddr(1, &newact) < 0)
    80003d12:	fe040593          	addi	a1,s0,-32
    80003d16:	4505                	li	a0,1
    80003d18:	00000097          	auipc	ra,0x0
    80003d1c:	cac080e7          	jalr	-852(ra) # 800039c4 <argaddr>
    return -1;
    80003d20:	57fd                	li	a5,-1
  if(argaddr(1, &newact) < 0)
    80003d22:	02054763          	bltz	a0,80003d50 <sys_sigaction+0x5a>
  if(argaddr(2, &oldact) < 0)
    80003d26:	fd840593          	addi	a1,s0,-40
    80003d2a:	4509                	li	a0,2
    80003d2c:	00000097          	auipc	ra,0x0
    80003d30:	c98080e7          	jalr	-872(ra) # 800039c4 <argaddr>
    return -1;
    80003d34:	57fd                	li	a5,-1
  if(argaddr(2, &oldact) < 0)
    80003d36:	00054d63          	bltz	a0,80003d50 <sys_sigaction+0x5a>

  return sigaction(signum,newact,oldact);
    80003d3a:	fd843603          	ld	a2,-40(s0)
    80003d3e:	fe043583          	ld	a1,-32(s0)
    80003d42:	fec42503          	lw	a0,-20(s0)
    80003d46:	fffff097          	auipc	ra,0xfffff
    80003d4a:	f26080e7          	jalr	-218(ra) # 80002c6c <sigaction>
    80003d4e:	87aa                	mv	a5,a0
  
}
    80003d50:	853e                	mv	a0,a5
    80003d52:	70a2                	ld	ra,40(sp)
    80003d54:	7402                	ld	s0,32(sp)
    80003d56:	6145                	addi	sp,sp,48
    80003d58:	8082                	ret

0000000080003d5a <sys_sigret>:
uint64
sys_sigret(void)
{
    80003d5a:	1141                	addi	sp,sp,-16
    80003d5c:	e406                	sd	ra,8(sp)
    80003d5e:	e022                	sd	s0,0(sp)
    80003d60:	0800                	addi	s0,sp,16
  sigret();
    80003d62:	fffff097          	auipc	ra,0xfffff
    80003d66:	ff4080e7          	jalr	-12(ra) # 80002d56 <sigret>
  return 0;
}
    80003d6a:	4501                	li	a0,0
    80003d6c:	60a2                	ld	ra,8(sp)
    80003d6e:	6402                	ld	s0,0(sp)
    80003d70:	0141                	addi	sp,sp,16
    80003d72:	8082                	ret

0000000080003d74 <sys_kthread_create>:

uint64
sys_kthread_create(void)
{
    80003d74:	1101                	addi	sp,sp,-32
    80003d76:	ec06                	sd	ra,24(sp)
    80003d78:	e822                	sd	s0,16(sp)
    80003d7a:	1000                	addi	s0,sp,32
  uint64 start_func;
  uint64 stack;
  if(argaddr(0, &start_func) < 0)
    80003d7c:	fe840593          	addi	a1,s0,-24
    80003d80:	4501                	li	a0,0
    80003d82:	00000097          	auipc	ra,0x0
    80003d86:	c42080e7          	jalr	-958(ra) # 800039c4 <argaddr>
    80003d8a:	02054463          	bltz	a0,80003db2 <sys_kthread_create+0x3e>
    return -1;
  if(argaddr(1, &stack) < 0)
    80003d8e:	fe040593          	addi	a1,s0,-32
    80003d92:	4505                	li	a0,1
    80003d94:	00000097          	auipc	ra,0x0
    80003d98:	c30080e7          	jalr	-976(ra) # 800039c4 <argaddr>
    80003d9c:	00054b63          	bltz	a0,80003db2 <sys_kthread_create+0x3e>
    return -1;
  kthread_create(start_func,stack);
    80003da0:	fe043583          	ld	a1,-32(s0)
    80003da4:	fe843503          	ld	a0,-24(s0)
    80003da8:	fffff097          	auipc	ra,0xfffff
    80003dac:	16e080e7          	jalr	366(ra) # 80002f16 <kthread_create>
}
    80003db0:	a011                	j	80003db4 <sys_kthread_create+0x40>
    80003db2:	557d                	li	a0,-1
    80003db4:	60e2                	ld	ra,24(sp)
    80003db6:	6442                	ld	s0,16(sp)
    80003db8:	6105                	addi	sp,sp,32
    80003dba:	8082                	ret

0000000080003dbc <sys_kthread_id>:

uint64
sys_kthread_id(void){
    80003dbc:	1141                	addi	sp,sp,-16
    80003dbe:	e406                	sd	ra,8(sp)
    80003dc0:	e022                	sd	s0,0(sp)
    80003dc2:	0800                	addi	s0,sp,16
  return mykthread()->tid;
    80003dc4:	ffffe097          	auipc	ra,0xffffe
    80003dc8:	d84080e7          	jalr	-636(ra) # 80001b48 <mykthread>
}
    80003dcc:	5908                	lw	a0,48(a0)
    80003dce:	60a2                	ld	ra,8(sp)
    80003dd0:	6402                	ld	s0,0(sp)
    80003dd2:	0141                	addi	sp,sp,16
    80003dd4:	8082                	ret

0000000080003dd6 <sys_kthread_exit>:

uint64
sys_kthread_exit(void){
    80003dd6:	1101                	addi	sp,sp,-32
    80003dd8:	ec06                	sd	ra,24(sp)
    80003dda:	e822                	sd	s0,16(sp)
    80003ddc:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003dde:	fec40593          	addi	a1,s0,-20
    80003de2:	4501                	li	a0,0
    80003de4:	00000097          	auipc	ra,0x0
    80003de8:	bbe080e7          	jalr	-1090(ra) # 800039a2 <argint>
    return -1;
    80003dec:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003dee:	00054963          	bltz	a0,80003e00 <sys_kthread_exit+0x2a>
  exit(n);
    80003df2:	fec42503          	lw	a0,-20(s0)
    80003df6:	fffff097          	auipc	ra,0xfffff
    80003dfa:	bbc080e7          	jalr	-1092(ra) # 800029b2 <exit>
  
  return 0;  // not reached
    80003dfe:	4781                	li	a5,0
}
    80003e00:	853e                	mv	a0,a5
    80003e02:	60e2                	ld	ra,24(sp)
    80003e04:	6442                	ld	s0,16(sp)
    80003e06:	6105                	addi	sp,sp,32
    80003e08:	8082                	ret

0000000080003e0a <sys_kthread_join>:

uint64 
sys_kthread_join(){
    80003e0a:	1101                	addi	sp,sp,-32
    80003e0c:	ec06                	sd	ra,24(sp)
    80003e0e:	e822                	sd	s0,16(sp)
    80003e10:	1000                	addi	s0,sp,32
  int thread_id;
  uint64 status;
  if(argint(0, &thread_id) < 0)
    80003e12:	fec40593          	addi	a1,s0,-20
    80003e16:	4501                	li	a0,0
    80003e18:	00000097          	auipc	ra,0x0
    80003e1c:	b8a080e7          	jalr	-1142(ra) # 800039a2 <argint>
    return -1;
    80003e20:	57fd                	li	a5,-1
  if(argint(0, &thread_id) < 0)
    80003e22:	02054563          	bltz	a0,80003e4c <sys_kthread_join+0x42>
  if(argaddr(1, &status) < 0)
    80003e26:	fe040593          	addi	a1,s0,-32
    80003e2a:	4505                	li	a0,1
    80003e2c:	00000097          	auipc	ra,0x0
    80003e30:	b98080e7          	jalr	-1128(ra) # 800039c4 <argaddr>
    return -1;
    80003e34:	57fd                	li	a5,-1
  if(argaddr(1, &status) < 0)
    80003e36:	00054b63          	bltz	a0,80003e4c <sys_kthread_join+0x42>
  
  return kthread_join(thread_id, status);
    80003e3a:	fe043583          	ld	a1,-32(s0)
    80003e3e:	fec42503          	lw	a0,-20(s0)
    80003e42:	fffff097          	auipc	ra,0xfffff
    80003e46:	1a0080e7          	jalr	416(ra) # 80002fe2 <kthread_join>
    80003e4a:	87aa                	mv	a5,a0
    80003e4c:	853e                	mv	a0,a5
    80003e4e:	60e2                	ld	ra,24(sp)
    80003e50:	6442                	ld	s0,16(sp)
    80003e52:	6105                	addi	sp,sp,32
    80003e54:	8082                	ret

0000000080003e56 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003e56:	7179                	addi	sp,sp,-48
    80003e58:	f406                	sd	ra,40(sp)
    80003e5a:	f022                	sd	s0,32(sp)
    80003e5c:	ec26                	sd	s1,24(sp)
    80003e5e:	e84a                	sd	s2,16(sp)
    80003e60:	e44e                	sd	s3,8(sp)
    80003e62:	e052                	sd	s4,0(sp)
    80003e64:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003e66:	00005597          	auipc	a1,0x5
    80003e6a:	92a58593          	addi	a1,a1,-1750 # 80008790 <syscalls+0xe8>
    80003e6e:	0002f517          	auipc	a0,0x2f
    80003e72:	ad250513          	addi	a0,a0,-1326 # 80032940 <bcache>
    80003e76:	ffffd097          	auipc	ra,0xffffd
    80003e7a:	cc0080e7          	jalr	-832(ra) # 80000b36 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003e7e:	00037797          	auipc	a5,0x37
    80003e82:	ac278793          	addi	a5,a5,-1342 # 8003a940 <bcache+0x8000>
    80003e86:	00037717          	auipc	a4,0x37
    80003e8a:	d2270713          	addi	a4,a4,-734 # 8003aba8 <bcache+0x8268>
    80003e8e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003e92:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003e96:	0002f497          	auipc	s1,0x2f
    80003e9a:	ac248493          	addi	s1,s1,-1342 # 80032958 <bcache+0x18>
    b->next = bcache.head.next;
    80003e9e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003ea0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003ea2:	00005a17          	auipc	s4,0x5
    80003ea6:	8f6a0a13          	addi	s4,s4,-1802 # 80008798 <syscalls+0xf0>
    b->next = bcache.head.next;
    80003eaa:	2b893783          	ld	a5,696(s2)
    80003eae:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003eb0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003eb4:	85d2                	mv	a1,s4
    80003eb6:	01048513          	addi	a0,s1,16
    80003eba:	00001097          	auipc	ra,0x1
    80003ebe:	4c0080e7          	jalr	1216(ra) # 8000537a <initsleeplock>
    bcache.head.next->prev = b;
    80003ec2:	2b893783          	ld	a5,696(s2)
    80003ec6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003ec8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003ecc:	45848493          	addi	s1,s1,1112
    80003ed0:	fd349de3          	bne	s1,s3,80003eaa <binit+0x54>
  }
}
    80003ed4:	70a2                	ld	ra,40(sp)
    80003ed6:	7402                	ld	s0,32(sp)
    80003ed8:	64e2                	ld	s1,24(sp)
    80003eda:	6942                	ld	s2,16(sp)
    80003edc:	69a2                	ld	s3,8(sp)
    80003ede:	6a02                	ld	s4,0(sp)
    80003ee0:	6145                	addi	sp,sp,48
    80003ee2:	8082                	ret

0000000080003ee4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003ee4:	7179                	addi	sp,sp,-48
    80003ee6:	f406                	sd	ra,40(sp)
    80003ee8:	f022                	sd	s0,32(sp)
    80003eea:	ec26                	sd	s1,24(sp)
    80003eec:	e84a                	sd	s2,16(sp)
    80003eee:	e44e                	sd	s3,8(sp)
    80003ef0:	1800                	addi	s0,sp,48
    80003ef2:	892a                	mv	s2,a0
    80003ef4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003ef6:	0002f517          	auipc	a0,0x2f
    80003efa:	a4a50513          	addi	a0,a0,-1462 # 80032940 <bcache>
    80003efe:	ffffd097          	auipc	ra,0xffffd
    80003f02:	cc8080e7          	jalr	-824(ra) # 80000bc6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003f06:	00037497          	auipc	s1,0x37
    80003f0a:	cf24b483          	ld	s1,-782(s1) # 8003abf8 <bcache+0x82b8>
    80003f0e:	00037797          	auipc	a5,0x37
    80003f12:	c9a78793          	addi	a5,a5,-870 # 8003aba8 <bcache+0x8268>
    80003f16:	02f48f63          	beq	s1,a5,80003f54 <bread+0x70>
    80003f1a:	873e                	mv	a4,a5
    80003f1c:	a021                	j	80003f24 <bread+0x40>
    80003f1e:	68a4                	ld	s1,80(s1)
    80003f20:	02e48a63          	beq	s1,a4,80003f54 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003f24:	449c                	lw	a5,8(s1)
    80003f26:	ff279ce3          	bne	a5,s2,80003f1e <bread+0x3a>
    80003f2a:	44dc                	lw	a5,12(s1)
    80003f2c:	ff3799e3          	bne	a5,s3,80003f1e <bread+0x3a>
      b->refcnt++;
    80003f30:	40bc                	lw	a5,64(s1)
    80003f32:	2785                	addiw	a5,a5,1
    80003f34:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003f36:	0002f517          	auipc	a0,0x2f
    80003f3a:	a0a50513          	addi	a0,a0,-1526 # 80032940 <bcache>
    80003f3e:	ffffd097          	auipc	ra,0xffffd
    80003f42:	d52080e7          	jalr	-686(ra) # 80000c90 <release>
      acquiresleep(&b->lock);
    80003f46:	01048513          	addi	a0,s1,16
    80003f4a:	00001097          	auipc	ra,0x1
    80003f4e:	46a080e7          	jalr	1130(ra) # 800053b4 <acquiresleep>
      return b;
    80003f52:	a8b9                	j	80003fb0 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003f54:	00037497          	auipc	s1,0x37
    80003f58:	c9c4b483          	ld	s1,-868(s1) # 8003abf0 <bcache+0x82b0>
    80003f5c:	00037797          	auipc	a5,0x37
    80003f60:	c4c78793          	addi	a5,a5,-948 # 8003aba8 <bcache+0x8268>
    80003f64:	00f48863          	beq	s1,a5,80003f74 <bread+0x90>
    80003f68:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003f6a:	40bc                	lw	a5,64(s1)
    80003f6c:	cf81                	beqz	a5,80003f84 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003f6e:	64a4                	ld	s1,72(s1)
    80003f70:	fee49de3          	bne	s1,a4,80003f6a <bread+0x86>
  panic("bget: no buffers");
    80003f74:	00005517          	auipc	a0,0x5
    80003f78:	82c50513          	addi	a0,a0,-2004 # 800087a0 <syscalls+0xf8>
    80003f7c:	ffffc097          	auipc	ra,0xffffc
    80003f80:	5b2080e7          	jalr	1458(ra) # 8000052e <panic>
      b->dev = dev;
    80003f84:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003f88:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003f8c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003f90:	4785                	li	a5,1
    80003f92:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003f94:	0002f517          	auipc	a0,0x2f
    80003f98:	9ac50513          	addi	a0,a0,-1620 # 80032940 <bcache>
    80003f9c:	ffffd097          	auipc	ra,0xffffd
    80003fa0:	cf4080e7          	jalr	-780(ra) # 80000c90 <release>
      acquiresleep(&b->lock);
    80003fa4:	01048513          	addi	a0,s1,16
    80003fa8:	00001097          	auipc	ra,0x1
    80003fac:	40c080e7          	jalr	1036(ra) # 800053b4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003fb0:	409c                	lw	a5,0(s1)
    80003fb2:	cb89                	beqz	a5,80003fc4 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003fb4:	8526                	mv	a0,s1
    80003fb6:	70a2                	ld	ra,40(sp)
    80003fb8:	7402                	ld	s0,32(sp)
    80003fba:	64e2                	ld	s1,24(sp)
    80003fbc:	6942                	ld	s2,16(sp)
    80003fbe:	69a2                	ld	s3,8(sp)
    80003fc0:	6145                	addi	sp,sp,48
    80003fc2:	8082                	ret
    virtio_disk_rw(b, 0);
    80003fc4:	4581                	li	a1,0
    80003fc6:	8526                	mv	a0,s1
    80003fc8:	00003097          	auipc	ra,0x3
    80003fcc:	bee080e7          	jalr	-1042(ra) # 80006bb6 <virtio_disk_rw>
    b->valid = 1;
    80003fd0:	4785                	li	a5,1
    80003fd2:	c09c                	sw	a5,0(s1)
  return b;
    80003fd4:	b7c5                	j	80003fb4 <bread+0xd0>

0000000080003fd6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003fd6:	1101                	addi	sp,sp,-32
    80003fd8:	ec06                	sd	ra,24(sp)
    80003fda:	e822                	sd	s0,16(sp)
    80003fdc:	e426                	sd	s1,8(sp)
    80003fde:	1000                	addi	s0,sp,32
    80003fe0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003fe2:	0541                	addi	a0,a0,16
    80003fe4:	00001097          	auipc	ra,0x1
    80003fe8:	46a080e7          	jalr	1130(ra) # 8000544e <holdingsleep>
    80003fec:	cd01                	beqz	a0,80004004 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003fee:	4585                	li	a1,1
    80003ff0:	8526                	mv	a0,s1
    80003ff2:	00003097          	auipc	ra,0x3
    80003ff6:	bc4080e7          	jalr	-1084(ra) # 80006bb6 <virtio_disk_rw>
}
    80003ffa:	60e2                	ld	ra,24(sp)
    80003ffc:	6442                	ld	s0,16(sp)
    80003ffe:	64a2                	ld	s1,8(sp)
    80004000:	6105                	addi	sp,sp,32
    80004002:	8082                	ret
    panic("bwrite");
    80004004:	00004517          	auipc	a0,0x4
    80004008:	7b450513          	addi	a0,a0,1972 # 800087b8 <syscalls+0x110>
    8000400c:	ffffc097          	auipc	ra,0xffffc
    80004010:	522080e7          	jalr	1314(ra) # 8000052e <panic>

0000000080004014 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80004014:	1101                	addi	sp,sp,-32
    80004016:	ec06                	sd	ra,24(sp)
    80004018:	e822                	sd	s0,16(sp)
    8000401a:	e426                	sd	s1,8(sp)
    8000401c:	e04a                	sd	s2,0(sp)
    8000401e:	1000                	addi	s0,sp,32
    80004020:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004022:	01050913          	addi	s2,a0,16
    80004026:	854a                	mv	a0,s2
    80004028:	00001097          	auipc	ra,0x1
    8000402c:	426080e7          	jalr	1062(ra) # 8000544e <holdingsleep>
    80004030:	c92d                	beqz	a0,800040a2 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80004032:	854a                	mv	a0,s2
    80004034:	00001097          	auipc	ra,0x1
    80004038:	3d6080e7          	jalr	982(ra) # 8000540a <releasesleep>

  acquire(&bcache.lock);
    8000403c:	0002f517          	auipc	a0,0x2f
    80004040:	90450513          	addi	a0,a0,-1788 # 80032940 <bcache>
    80004044:	ffffd097          	auipc	ra,0xffffd
    80004048:	b82080e7          	jalr	-1150(ra) # 80000bc6 <acquire>
  b->refcnt--;
    8000404c:	40bc                	lw	a5,64(s1)
    8000404e:	37fd                	addiw	a5,a5,-1
    80004050:	0007871b          	sext.w	a4,a5
    80004054:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80004056:	eb05                	bnez	a4,80004086 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80004058:	68bc                	ld	a5,80(s1)
    8000405a:	64b8                	ld	a4,72(s1)
    8000405c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000405e:	64bc                	ld	a5,72(s1)
    80004060:	68b8                	ld	a4,80(s1)
    80004062:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80004064:	00037797          	auipc	a5,0x37
    80004068:	8dc78793          	addi	a5,a5,-1828 # 8003a940 <bcache+0x8000>
    8000406c:	2b87b703          	ld	a4,696(a5)
    80004070:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80004072:	00037717          	auipc	a4,0x37
    80004076:	b3670713          	addi	a4,a4,-1226 # 8003aba8 <bcache+0x8268>
    8000407a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000407c:	2b87b703          	ld	a4,696(a5)
    80004080:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80004082:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80004086:	0002f517          	auipc	a0,0x2f
    8000408a:	8ba50513          	addi	a0,a0,-1862 # 80032940 <bcache>
    8000408e:	ffffd097          	auipc	ra,0xffffd
    80004092:	c02080e7          	jalr	-1022(ra) # 80000c90 <release>
}
    80004096:	60e2                	ld	ra,24(sp)
    80004098:	6442                	ld	s0,16(sp)
    8000409a:	64a2                	ld	s1,8(sp)
    8000409c:	6902                	ld	s2,0(sp)
    8000409e:	6105                	addi	sp,sp,32
    800040a0:	8082                	ret
    panic("brelse");
    800040a2:	00004517          	auipc	a0,0x4
    800040a6:	71e50513          	addi	a0,a0,1822 # 800087c0 <syscalls+0x118>
    800040aa:	ffffc097          	auipc	ra,0xffffc
    800040ae:	484080e7          	jalr	1156(ra) # 8000052e <panic>

00000000800040b2 <bpin>:

void
bpin(struct buf *b) {
    800040b2:	1101                	addi	sp,sp,-32
    800040b4:	ec06                	sd	ra,24(sp)
    800040b6:	e822                	sd	s0,16(sp)
    800040b8:	e426                	sd	s1,8(sp)
    800040ba:	1000                	addi	s0,sp,32
    800040bc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800040be:	0002f517          	auipc	a0,0x2f
    800040c2:	88250513          	addi	a0,a0,-1918 # 80032940 <bcache>
    800040c6:	ffffd097          	auipc	ra,0xffffd
    800040ca:	b00080e7          	jalr	-1280(ra) # 80000bc6 <acquire>
  b->refcnt++;
    800040ce:	40bc                	lw	a5,64(s1)
    800040d0:	2785                	addiw	a5,a5,1
    800040d2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800040d4:	0002f517          	auipc	a0,0x2f
    800040d8:	86c50513          	addi	a0,a0,-1940 # 80032940 <bcache>
    800040dc:	ffffd097          	auipc	ra,0xffffd
    800040e0:	bb4080e7          	jalr	-1100(ra) # 80000c90 <release>
}
    800040e4:	60e2                	ld	ra,24(sp)
    800040e6:	6442                	ld	s0,16(sp)
    800040e8:	64a2                	ld	s1,8(sp)
    800040ea:	6105                	addi	sp,sp,32
    800040ec:	8082                	ret

00000000800040ee <bunpin>:

void
bunpin(struct buf *b) {
    800040ee:	1101                	addi	sp,sp,-32
    800040f0:	ec06                	sd	ra,24(sp)
    800040f2:	e822                	sd	s0,16(sp)
    800040f4:	e426                	sd	s1,8(sp)
    800040f6:	1000                	addi	s0,sp,32
    800040f8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800040fa:	0002f517          	auipc	a0,0x2f
    800040fe:	84650513          	addi	a0,a0,-1978 # 80032940 <bcache>
    80004102:	ffffd097          	auipc	ra,0xffffd
    80004106:	ac4080e7          	jalr	-1340(ra) # 80000bc6 <acquire>
  b->refcnt--;
    8000410a:	40bc                	lw	a5,64(s1)
    8000410c:	37fd                	addiw	a5,a5,-1
    8000410e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004110:	0002f517          	auipc	a0,0x2f
    80004114:	83050513          	addi	a0,a0,-2000 # 80032940 <bcache>
    80004118:	ffffd097          	auipc	ra,0xffffd
    8000411c:	b78080e7          	jalr	-1160(ra) # 80000c90 <release>
}
    80004120:	60e2                	ld	ra,24(sp)
    80004122:	6442                	ld	s0,16(sp)
    80004124:	64a2                	ld	s1,8(sp)
    80004126:	6105                	addi	sp,sp,32
    80004128:	8082                	ret

000000008000412a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000412a:	1101                	addi	sp,sp,-32
    8000412c:	ec06                	sd	ra,24(sp)
    8000412e:	e822                	sd	s0,16(sp)
    80004130:	e426                	sd	s1,8(sp)
    80004132:	e04a                	sd	s2,0(sp)
    80004134:	1000                	addi	s0,sp,32
    80004136:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80004138:	00d5d59b          	srliw	a1,a1,0xd
    8000413c:	00037797          	auipc	a5,0x37
    80004140:	ee07a783          	lw	a5,-288(a5) # 8003b01c <sb+0x1c>
    80004144:	9dbd                	addw	a1,a1,a5
    80004146:	00000097          	auipc	ra,0x0
    8000414a:	d9e080e7          	jalr	-610(ra) # 80003ee4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000414e:	0074f713          	andi	a4,s1,7
    80004152:	4785                	li	a5,1
    80004154:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80004158:	14ce                	slli	s1,s1,0x33
    8000415a:	90d9                	srli	s1,s1,0x36
    8000415c:	00950733          	add	a4,a0,s1
    80004160:	05874703          	lbu	a4,88(a4)
    80004164:	00e7f6b3          	and	a3,a5,a4
    80004168:	c69d                	beqz	a3,80004196 <bfree+0x6c>
    8000416a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000416c:	94aa                	add	s1,s1,a0
    8000416e:	fff7c793          	not	a5,a5
    80004172:	8ff9                	and	a5,a5,a4
    80004174:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80004178:	00001097          	auipc	ra,0x1
    8000417c:	11c080e7          	jalr	284(ra) # 80005294 <log_write>
  brelse(bp);
    80004180:	854a                	mv	a0,s2
    80004182:	00000097          	auipc	ra,0x0
    80004186:	e92080e7          	jalr	-366(ra) # 80004014 <brelse>
}
    8000418a:	60e2                	ld	ra,24(sp)
    8000418c:	6442                	ld	s0,16(sp)
    8000418e:	64a2                	ld	s1,8(sp)
    80004190:	6902                	ld	s2,0(sp)
    80004192:	6105                	addi	sp,sp,32
    80004194:	8082                	ret
    panic("freeing free block");
    80004196:	00004517          	auipc	a0,0x4
    8000419a:	63250513          	addi	a0,a0,1586 # 800087c8 <syscalls+0x120>
    8000419e:	ffffc097          	auipc	ra,0xffffc
    800041a2:	390080e7          	jalr	912(ra) # 8000052e <panic>

00000000800041a6 <balloc>:
{
    800041a6:	711d                	addi	sp,sp,-96
    800041a8:	ec86                	sd	ra,88(sp)
    800041aa:	e8a2                	sd	s0,80(sp)
    800041ac:	e4a6                	sd	s1,72(sp)
    800041ae:	e0ca                	sd	s2,64(sp)
    800041b0:	fc4e                	sd	s3,56(sp)
    800041b2:	f852                	sd	s4,48(sp)
    800041b4:	f456                	sd	s5,40(sp)
    800041b6:	f05a                	sd	s6,32(sp)
    800041b8:	ec5e                	sd	s7,24(sp)
    800041ba:	e862                	sd	s8,16(sp)
    800041bc:	e466                	sd	s9,8(sp)
    800041be:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800041c0:	00037797          	auipc	a5,0x37
    800041c4:	e447a783          	lw	a5,-444(a5) # 8003b004 <sb+0x4>
    800041c8:	cbd1                	beqz	a5,8000425c <balloc+0xb6>
    800041ca:	8baa                	mv	s7,a0
    800041cc:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800041ce:	00037b17          	auipc	s6,0x37
    800041d2:	e32b0b13          	addi	s6,s6,-462 # 8003b000 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800041d6:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800041d8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800041da:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800041dc:	6c89                	lui	s9,0x2
    800041de:	a831                	j	800041fa <balloc+0x54>
    brelse(bp);
    800041e0:	854a                	mv	a0,s2
    800041e2:	00000097          	auipc	ra,0x0
    800041e6:	e32080e7          	jalr	-462(ra) # 80004014 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800041ea:	015c87bb          	addw	a5,s9,s5
    800041ee:	00078a9b          	sext.w	s5,a5
    800041f2:	004b2703          	lw	a4,4(s6)
    800041f6:	06eaf363          	bgeu	s5,a4,8000425c <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800041fa:	41fad79b          	sraiw	a5,s5,0x1f
    800041fe:	0137d79b          	srliw	a5,a5,0x13
    80004202:	015787bb          	addw	a5,a5,s5
    80004206:	40d7d79b          	sraiw	a5,a5,0xd
    8000420a:	01cb2583          	lw	a1,28(s6)
    8000420e:	9dbd                	addw	a1,a1,a5
    80004210:	855e                	mv	a0,s7
    80004212:	00000097          	auipc	ra,0x0
    80004216:	cd2080e7          	jalr	-814(ra) # 80003ee4 <bread>
    8000421a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000421c:	004b2503          	lw	a0,4(s6)
    80004220:	000a849b          	sext.w	s1,s5
    80004224:	8662                	mv	a2,s8
    80004226:	faa4fde3          	bgeu	s1,a0,800041e0 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000422a:	41f6579b          	sraiw	a5,a2,0x1f
    8000422e:	01d7d69b          	srliw	a3,a5,0x1d
    80004232:	00c6873b          	addw	a4,a3,a2
    80004236:	00777793          	andi	a5,a4,7
    8000423a:	9f95                	subw	a5,a5,a3
    8000423c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80004240:	4037571b          	sraiw	a4,a4,0x3
    80004244:	00e906b3          	add	a3,s2,a4
    80004248:	0586c683          	lbu	a3,88(a3)
    8000424c:	00d7f5b3          	and	a1,a5,a3
    80004250:	cd91                	beqz	a1,8000426c <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004252:	2605                	addiw	a2,a2,1
    80004254:	2485                	addiw	s1,s1,1
    80004256:	fd4618e3          	bne	a2,s4,80004226 <balloc+0x80>
    8000425a:	b759                	j	800041e0 <balloc+0x3a>
  panic("balloc: out of blocks");
    8000425c:	00004517          	auipc	a0,0x4
    80004260:	58450513          	addi	a0,a0,1412 # 800087e0 <syscalls+0x138>
    80004264:	ffffc097          	auipc	ra,0xffffc
    80004268:	2ca080e7          	jalr	714(ra) # 8000052e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000426c:	974a                	add	a4,a4,s2
    8000426e:	8fd5                	or	a5,a5,a3
    80004270:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80004274:	854a                	mv	a0,s2
    80004276:	00001097          	auipc	ra,0x1
    8000427a:	01e080e7          	jalr	30(ra) # 80005294 <log_write>
        brelse(bp);
    8000427e:	854a                	mv	a0,s2
    80004280:	00000097          	auipc	ra,0x0
    80004284:	d94080e7          	jalr	-620(ra) # 80004014 <brelse>
  bp = bread(dev, bno);
    80004288:	85a6                	mv	a1,s1
    8000428a:	855e                	mv	a0,s7
    8000428c:	00000097          	auipc	ra,0x0
    80004290:	c58080e7          	jalr	-936(ra) # 80003ee4 <bread>
    80004294:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80004296:	40000613          	li	a2,1024
    8000429a:	4581                	li	a1,0
    8000429c:	05850513          	addi	a0,a0,88
    800042a0:	ffffd097          	auipc	ra,0xffffd
    800042a4:	a38080e7          	jalr	-1480(ra) # 80000cd8 <memset>
  log_write(bp);
    800042a8:	854a                	mv	a0,s2
    800042aa:	00001097          	auipc	ra,0x1
    800042ae:	fea080e7          	jalr	-22(ra) # 80005294 <log_write>
  brelse(bp);
    800042b2:	854a                	mv	a0,s2
    800042b4:	00000097          	auipc	ra,0x0
    800042b8:	d60080e7          	jalr	-672(ra) # 80004014 <brelse>
}
    800042bc:	8526                	mv	a0,s1
    800042be:	60e6                	ld	ra,88(sp)
    800042c0:	6446                	ld	s0,80(sp)
    800042c2:	64a6                	ld	s1,72(sp)
    800042c4:	6906                	ld	s2,64(sp)
    800042c6:	79e2                	ld	s3,56(sp)
    800042c8:	7a42                	ld	s4,48(sp)
    800042ca:	7aa2                	ld	s5,40(sp)
    800042cc:	7b02                	ld	s6,32(sp)
    800042ce:	6be2                	ld	s7,24(sp)
    800042d0:	6c42                	ld	s8,16(sp)
    800042d2:	6ca2                	ld	s9,8(sp)
    800042d4:	6125                	addi	sp,sp,96
    800042d6:	8082                	ret

00000000800042d8 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800042d8:	7179                	addi	sp,sp,-48
    800042da:	f406                	sd	ra,40(sp)
    800042dc:	f022                	sd	s0,32(sp)
    800042de:	ec26                	sd	s1,24(sp)
    800042e0:	e84a                	sd	s2,16(sp)
    800042e2:	e44e                	sd	s3,8(sp)
    800042e4:	e052                	sd	s4,0(sp)
    800042e6:	1800                	addi	s0,sp,48
    800042e8:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800042ea:	47ad                	li	a5,11
    800042ec:	04b7fe63          	bgeu	a5,a1,80004348 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800042f0:	ff45849b          	addiw	s1,a1,-12
    800042f4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800042f8:	0ff00793          	li	a5,255
    800042fc:	0ae7e463          	bltu	a5,a4,800043a4 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80004300:	08052583          	lw	a1,128(a0)
    80004304:	c5b5                	beqz	a1,80004370 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80004306:	00092503          	lw	a0,0(s2)
    8000430a:	00000097          	auipc	ra,0x0
    8000430e:	bda080e7          	jalr	-1062(ra) # 80003ee4 <bread>
    80004312:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80004314:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80004318:	02049713          	slli	a4,s1,0x20
    8000431c:	01e75593          	srli	a1,a4,0x1e
    80004320:	00b784b3          	add	s1,a5,a1
    80004324:	0004a983          	lw	s3,0(s1)
    80004328:	04098e63          	beqz	s3,80004384 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000432c:	8552                	mv	a0,s4
    8000432e:	00000097          	auipc	ra,0x0
    80004332:	ce6080e7          	jalr	-794(ra) # 80004014 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80004336:	854e                	mv	a0,s3
    80004338:	70a2                	ld	ra,40(sp)
    8000433a:	7402                	ld	s0,32(sp)
    8000433c:	64e2                	ld	s1,24(sp)
    8000433e:	6942                	ld	s2,16(sp)
    80004340:	69a2                	ld	s3,8(sp)
    80004342:	6a02                	ld	s4,0(sp)
    80004344:	6145                	addi	sp,sp,48
    80004346:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80004348:	02059793          	slli	a5,a1,0x20
    8000434c:	01e7d593          	srli	a1,a5,0x1e
    80004350:	00b504b3          	add	s1,a0,a1
    80004354:	0504a983          	lw	s3,80(s1)
    80004358:	fc099fe3          	bnez	s3,80004336 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000435c:	4108                	lw	a0,0(a0)
    8000435e:	00000097          	auipc	ra,0x0
    80004362:	e48080e7          	jalr	-440(ra) # 800041a6 <balloc>
    80004366:	0005099b          	sext.w	s3,a0
    8000436a:	0534a823          	sw	s3,80(s1)
    8000436e:	b7e1                	j	80004336 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80004370:	4108                	lw	a0,0(a0)
    80004372:	00000097          	auipc	ra,0x0
    80004376:	e34080e7          	jalr	-460(ra) # 800041a6 <balloc>
    8000437a:	0005059b          	sext.w	a1,a0
    8000437e:	08b92023          	sw	a1,128(s2)
    80004382:	b751                	j	80004306 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80004384:	00092503          	lw	a0,0(s2)
    80004388:	00000097          	auipc	ra,0x0
    8000438c:	e1e080e7          	jalr	-482(ra) # 800041a6 <balloc>
    80004390:	0005099b          	sext.w	s3,a0
    80004394:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80004398:	8552                	mv	a0,s4
    8000439a:	00001097          	auipc	ra,0x1
    8000439e:	efa080e7          	jalr	-262(ra) # 80005294 <log_write>
    800043a2:	b769                	j	8000432c <bmap+0x54>
  panic("bmap: out of range");
    800043a4:	00004517          	auipc	a0,0x4
    800043a8:	45450513          	addi	a0,a0,1108 # 800087f8 <syscalls+0x150>
    800043ac:	ffffc097          	auipc	ra,0xffffc
    800043b0:	182080e7          	jalr	386(ra) # 8000052e <panic>

00000000800043b4 <iget>:
{
    800043b4:	7179                	addi	sp,sp,-48
    800043b6:	f406                	sd	ra,40(sp)
    800043b8:	f022                	sd	s0,32(sp)
    800043ba:	ec26                	sd	s1,24(sp)
    800043bc:	e84a                	sd	s2,16(sp)
    800043be:	e44e                	sd	s3,8(sp)
    800043c0:	e052                	sd	s4,0(sp)
    800043c2:	1800                	addi	s0,sp,48
    800043c4:	89aa                	mv	s3,a0
    800043c6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800043c8:	00037517          	auipc	a0,0x37
    800043cc:	c5850513          	addi	a0,a0,-936 # 8003b020 <itable>
    800043d0:	ffffc097          	auipc	ra,0xffffc
    800043d4:	7f6080e7          	jalr	2038(ra) # 80000bc6 <acquire>
  empty = 0;
    800043d8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800043da:	00037497          	auipc	s1,0x37
    800043de:	c5e48493          	addi	s1,s1,-930 # 8003b038 <itable+0x18>
    800043e2:	00038697          	auipc	a3,0x38
    800043e6:	6e668693          	addi	a3,a3,1766 # 8003cac8 <log>
    800043ea:	a039                	j	800043f8 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800043ec:	02090b63          	beqz	s2,80004422 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800043f0:	08848493          	addi	s1,s1,136
    800043f4:	02d48a63          	beq	s1,a3,80004428 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800043f8:	449c                	lw	a5,8(s1)
    800043fa:	fef059e3          	blez	a5,800043ec <iget+0x38>
    800043fe:	4098                	lw	a4,0(s1)
    80004400:	ff3716e3          	bne	a4,s3,800043ec <iget+0x38>
    80004404:	40d8                	lw	a4,4(s1)
    80004406:	ff4713e3          	bne	a4,s4,800043ec <iget+0x38>
      ip->ref++;
    8000440a:	2785                	addiw	a5,a5,1
    8000440c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000440e:	00037517          	auipc	a0,0x37
    80004412:	c1250513          	addi	a0,a0,-1006 # 8003b020 <itable>
    80004416:	ffffd097          	auipc	ra,0xffffd
    8000441a:	87a080e7          	jalr	-1926(ra) # 80000c90 <release>
      return ip;
    8000441e:	8926                	mv	s2,s1
    80004420:	a03d                	j	8000444e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004422:	f7f9                	bnez	a5,800043f0 <iget+0x3c>
    80004424:	8926                	mv	s2,s1
    80004426:	b7e9                	j	800043f0 <iget+0x3c>
  if(empty == 0)
    80004428:	02090c63          	beqz	s2,80004460 <iget+0xac>
  ip->dev = dev;
    8000442c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80004430:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80004434:	4785                	li	a5,1
    80004436:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000443a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000443e:	00037517          	auipc	a0,0x37
    80004442:	be250513          	addi	a0,a0,-1054 # 8003b020 <itable>
    80004446:	ffffd097          	auipc	ra,0xffffd
    8000444a:	84a080e7          	jalr	-1974(ra) # 80000c90 <release>
}
    8000444e:	854a                	mv	a0,s2
    80004450:	70a2                	ld	ra,40(sp)
    80004452:	7402                	ld	s0,32(sp)
    80004454:	64e2                	ld	s1,24(sp)
    80004456:	6942                	ld	s2,16(sp)
    80004458:	69a2                	ld	s3,8(sp)
    8000445a:	6a02                	ld	s4,0(sp)
    8000445c:	6145                	addi	sp,sp,48
    8000445e:	8082                	ret
    panic("iget: no inodes");
    80004460:	00004517          	auipc	a0,0x4
    80004464:	3b050513          	addi	a0,a0,944 # 80008810 <syscalls+0x168>
    80004468:	ffffc097          	auipc	ra,0xffffc
    8000446c:	0c6080e7          	jalr	198(ra) # 8000052e <panic>

0000000080004470 <fsinit>:
fsinit(int dev) {
    80004470:	7179                	addi	sp,sp,-48
    80004472:	f406                	sd	ra,40(sp)
    80004474:	f022                	sd	s0,32(sp)
    80004476:	ec26                	sd	s1,24(sp)
    80004478:	e84a                	sd	s2,16(sp)
    8000447a:	e44e                	sd	s3,8(sp)
    8000447c:	1800                	addi	s0,sp,48
    8000447e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80004480:	4585                	li	a1,1
    80004482:	00000097          	auipc	ra,0x0
    80004486:	a62080e7          	jalr	-1438(ra) # 80003ee4 <bread>
    8000448a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000448c:	00037997          	auipc	s3,0x37
    80004490:	b7498993          	addi	s3,s3,-1164 # 8003b000 <sb>
    80004494:	02000613          	li	a2,32
    80004498:	05850593          	addi	a1,a0,88
    8000449c:	854e                	mv	a0,s3
    8000449e:	ffffd097          	auipc	ra,0xffffd
    800044a2:	896080e7          	jalr	-1898(ra) # 80000d34 <memmove>
  brelse(bp);
    800044a6:	8526                	mv	a0,s1
    800044a8:	00000097          	auipc	ra,0x0
    800044ac:	b6c080e7          	jalr	-1172(ra) # 80004014 <brelse>
  if(sb.magic != FSMAGIC)
    800044b0:	0009a703          	lw	a4,0(s3)
    800044b4:	102037b7          	lui	a5,0x10203
    800044b8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800044bc:	02f71263          	bne	a4,a5,800044e0 <fsinit+0x70>
  initlog(dev, &sb);
    800044c0:	00037597          	auipc	a1,0x37
    800044c4:	b4058593          	addi	a1,a1,-1216 # 8003b000 <sb>
    800044c8:	854a                	mv	a0,s2
    800044ca:	00001097          	auipc	ra,0x1
    800044ce:	b4c080e7          	jalr	-1204(ra) # 80005016 <initlog>
}
    800044d2:	70a2                	ld	ra,40(sp)
    800044d4:	7402                	ld	s0,32(sp)
    800044d6:	64e2                	ld	s1,24(sp)
    800044d8:	6942                	ld	s2,16(sp)
    800044da:	69a2                	ld	s3,8(sp)
    800044dc:	6145                	addi	sp,sp,48
    800044de:	8082                	ret
    panic("invalid file system");
    800044e0:	00004517          	auipc	a0,0x4
    800044e4:	34050513          	addi	a0,a0,832 # 80008820 <syscalls+0x178>
    800044e8:	ffffc097          	auipc	ra,0xffffc
    800044ec:	046080e7          	jalr	70(ra) # 8000052e <panic>

00000000800044f0 <iinit>:
{
    800044f0:	7179                	addi	sp,sp,-48
    800044f2:	f406                	sd	ra,40(sp)
    800044f4:	f022                	sd	s0,32(sp)
    800044f6:	ec26                	sd	s1,24(sp)
    800044f8:	e84a                	sd	s2,16(sp)
    800044fa:	e44e                	sd	s3,8(sp)
    800044fc:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800044fe:	00004597          	auipc	a1,0x4
    80004502:	33a58593          	addi	a1,a1,826 # 80008838 <syscalls+0x190>
    80004506:	00037517          	auipc	a0,0x37
    8000450a:	b1a50513          	addi	a0,a0,-1254 # 8003b020 <itable>
    8000450e:	ffffc097          	auipc	ra,0xffffc
    80004512:	628080e7          	jalr	1576(ra) # 80000b36 <initlock>
  for(i = 0; i < NINODE; i++) {
    80004516:	00037497          	auipc	s1,0x37
    8000451a:	b3248493          	addi	s1,s1,-1230 # 8003b048 <itable+0x28>
    8000451e:	00038997          	auipc	s3,0x38
    80004522:	5ba98993          	addi	s3,s3,1466 # 8003cad8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004526:	00004917          	auipc	s2,0x4
    8000452a:	31a90913          	addi	s2,s2,794 # 80008840 <syscalls+0x198>
    8000452e:	85ca                	mv	a1,s2
    80004530:	8526                	mv	a0,s1
    80004532:	00001097          	auipc	ra,0x1
    80004536:	e48080e7          	jalr	-440(ra) # 8000537a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000453a:	08848493          	addi	s1,s1,136
    8000453e:	ff3498e3          	bne	s1,s3,8000452e <iinit+0x3e>
}
    80004542:	70a2                	ld	ra,40(sp)
    80004544:	7402                	ld	s0,32(sp)
    80004546:	64e2                	ld	s1,24(sp)
    80004548:	6942                	ld	s2,16(sp)
    8000454a:	69a2                	ld	s3,8(sp)
    8000454c:	6145                	addi	sp,sp,48
    8000454e:	8082                	ret

0000000080004550 <ialloc>:
{
    80004550:	715d                	addi	sp,sp,-80
    80004552:	e486                	sd	ra,72(sp)
    80004554:	e0a2                	sd	s0,64(sp)
    80004556:	fc26                	sd	s1,56(sp)
    80004558:	f84a                	sd	s2,48(sp)
    8000455a:	f44e                	sd	s3,40(sp)
    8000455c:	f052                	sd	s4,32(sp)
    8000455e:	ec56                	sd	s5,24(sp)
    80004560:	e85a                	sd	s6,16(sp)
    80004562:	e45e                	sd	s7,8(sp)
    80004564:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80004566:	00037717          	auipc	a4,0x37
    8000456a:	aa672703          	lw	a4,-1370(a4) # 8003b00c <sb+0xc>
    8000456e:	4785                	li	a5,1
    80004570:	04e7fa63          	bgeu	a5,a4,800045c4 <ialloc+0x74>
    80004574:	8aaa                	mv	s5,a0
    80004576:	8bae                	mv	s7,a1
    80004578:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000457a:	00037a17          	auipc	s4,0x37
    8000457e:	a86a0a13          	addi	s4,s4,-1402 # 8003b000 <sb>
    80004582:	00048b1b          	sext.w	s6,s1
    80004586:	0044d793          	srli	a5,s1,0x4
    8000458a:	018a2583          	lw	a1,24(s4)
    8000458e:	9dbd                	addw	a1,a1,a5
    80004590:	8556                	mv	a0,s5
    80004592:	00000097          	auipc	ra,0x0
    80004596:	952080e7          	jalr	-1710(ra) # 80003ee4 <bread>
    8000459a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000459c:	05850993          	addi	s3,a0,88
    800045a0:	00f4f793          	andi	a5,s1,15
    800045a4:	079a                	slli	a5,a5,0x6
    800045a6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800045a8:	00099783          	lh	a5,0(s3)
    800045ac:	c785                	beqz	a5,800045d4 <ialloc+0x84>
    brelse(bp);
    800045ae:	00000097          	auipc	ra,0x0
    800045b2:	a66080e7          	jalr	-1434(ra) # 80004014 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800045b6:	0485                	addi	s1,s1,1
    800045b8:	00ca2703          	lw	a4,12(s4)
    800045bc:	0004879b          	sext.w	a5,s1
    800045c0:	fce7e1e3          	bltu	a5,a4,80004582 <ialloc+0x32>
  panic("ialloc: no inodes");
    800045c4:	00004517          	auipc	a0,0x4
    800045c8:	28450513          	addi	a0,a0,644 # 80008848 <syscalls+0x1a0>
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	f62080e7          	jalr	-158(ra) # 8000052e <panic>
      memset(dip, 0, sizeof(*dip));
    800045d4:	04000613          	li	a2,64
    800045d8:	4581                	li	a1,0
    800045da:	854e                	mv	a0,s3
    800045dc:	ffffc097          	auipc	ra,0xffffc
    800045e0:	6fc080e7          	jalr	1788(ra) # 80000cd8 <memset>
      dip->type = type;
    800045e4:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800045e8:	854a                	mv	a0,s2
    800045ea:	00001097          	auipc	ra,0x1
    800045ee:	caa080e7          	jalr	-854(ra) # 80005294 <log_write>
      brelse(bp);
    800045f2:	854a                	mv	a0,s2
    800045f4:	00000097          	auipc	ra,0x0
    800045f8:	a20080e7          	jalr	-1504(ra) # 80004014 <brelse>
      return iget(dev, inum);
    800045fc:	85da                	mv	a1,s6
    800045fe:	8556                	mv	a0,s5
    80004600:	00000097          	auipc	ra,0x0
    80004604:	db4080e7          	jalr	-588(ra) # 800043b4 <iget>
}
    80004608:	60a6                	ld	ra,72(sp)
    8000460a:	6406                	ld	s0,64(sp)
    8000460c:	74e2                	ld	s1,56(sp)
    8000460e:	7942                	ld	s2,48(sp)
    80004610:	79a2                	ld	s3,40(sp)
    80004612:	7a02                	ld	s4,32(sp)
    80004614:	6ae2                	ld	s5,24(sp)
    80004616:	6b42                	ld	s6,16(sp)
    80004618:	6ba2                	ld	s7,8(sp)
    8000461a:	6161                	addi	sp,sp,80
    8000461c:	8082                	ret

000000008000461e <iupdate>:
{
    8000461e:	1101                	addi	sp,sp,-32
    80004620:	ec06                	sd	ra,24(sp)
    80004622:	e822                	sd	s0,16(sp)
    80004624:	e426                	sd	s1,8(sp)
    80004626:	e04a                	sd	s2,0(sp)
    80004628:	1000                	addi	s0,sp,32
    8000462a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000462c:	415c                	lw	a5,4(a0)
    8000462e:	0047d79b          	srliw	a5,a5,0x4
    80004632:	00037597          	auipc	a1,0x37
    80004636:	9e65a583          	lw	a1,-1562(a1) # 8003b018 <sb+0x18>
    8000463a:	9dbd                	addw	a1,a1,a5
    8000463c:	4108                	lw	a0,0(a0)
    8000463e:	00000097          	auipc	ra,0x0
    80004642:	8a6080e7          	jalr	-1882(ra) # 80003ee4 <bread>
    80004646:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004648:	05850793          	addi	a5,a0,88
    8000464c:	40c8                	lw	a0,4(s1)
    8000464e:	893d                	andi	a0,a0,15
    80004650:	051a                	slli	a0,a0,0x6
    80004652:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80004654:	04449703          	lh	a4,68(s1)
    80004658:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000465c:	04649703          	lh	a4,70(s1)
    80004660:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80004664:	04849703          	lh	a4,72(s1)
    80004668:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000466c:	04a49703          	lh	a4,74(s1)
    80004670:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80004674:	44f8                	lw	a4,76(s1)
    80004676:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004678:	03400613          	li	a2,52
    8000467c:	05048593          	addi	a1,s1,80
    80004680:	0531                	addi	a0,a0,12
    80004682:	ffffc097          	auipc	ra,0xffffc
    80004686:	6b2080e7          	jalr	1714(ra) # 80000d34 <memmove>
  log_write(bp);
    8000468a:	854a                	mv	a0,s2
    8000468c:	00001097          	auipc	ra,0x1
    80004690:	c08080e7          	jalr	-1016(ra) # 80005294 <log_write>
  brelse(bp);
    80004694:	854a                	mv	a0,s2
    80004696:	00000097          	auipc	ra,0x0
    8000469a:	97e080e7          	jalr	-1666(ra) # 80004014 <brelse>
}
    8000469e:	60e2                	ld	ra,24(sp)
    800046a0:	6442                	ld	s0,16(sp)
    800046a2:	64a2                	ld	s1,8(sp)
    800046a4:	6902                	ld	s2,0(sp)
    800046a6:	6105                	addi	sp,sp,32
    800046a8:	8082                	ret

00000000800046aa <idup>:
{
    800046aa:	1101                	addi	sp,sp,-32
    800046ac:	ec06                	sd	ra,24(sp)
    800046ae:	e822                	sd	s0,16(sp)
    800046b0:	e426                	sd	s1,8(sp)
    800046b2:	1000                	addi	s0,sp,32
    800046b4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800046b6:	00037517          	auipc	a0,0x37
    800046ba:	96a50513          	addi	a0,a0,-1686 # 8003b020 <itable>
    800046be:	ffffc097          	auipc	ra,0xffffc
    800046c2:	508080e7          	jalr	1288(ra) # 80000bc6 <acquire>
  ip->ref++;
    800046c6:	449c                	lw	a5,8(s1)
    800046c8:	2785                	addiw	a5,a5,1
    800046ca:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800046cc:	00037517          	auipc	a0,0x37
    800046d0:	95450513          	addi	a0,a0,-1708 # 8003b020 <itable>
    800046d4:	ffffc097          	auipc	ra,0xffffc
    800046d8:	5bc080e7          	jalr	1468(ra) # 80000c90 <release>
}
    800046dc:	8526                	mv	a0,s1
    800046de:	60e2                	ld	ra,24(sp)
    800046e0:	6442                	ld	s0,16(sp)
    800046e2:	64a2                	ld	s1,8(sp)
    800046e4:	6105                	addi	sp,sp,32
    800046e6:	8082                	ret

00000000800046e8 <ilock>:
{
    800046e8:	1101                	addi	sp,sp,-32
    800046ea:	ec06                	sd	ra,24(sp)
    800046ec:	e822                	sd	s0,16(sp)
    800046ee:	e426                	sd	s1,8(sp)
    800046f0:	e04a                	sd	s2,0(sp)
    800046f2:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800046f4:	c115                	beqz	a0,80004718 <ilock+0x30>
    800046f6:	84aa                	mv	s1,a0
    800046f8:	451c                	lw	a5,8(a0)
    800046fa:	00f05f63          	blez	a5,80004718 <ilock+0x30>
  acquiresleep(&ip->lock);
    800046fe:	0541                	addi	a0,a0,16
    80004700:	00001097          	auipc	ra,0x1
    80004704:	cb4080e7          	jalr	-844(ra) # 800053b4 <acquiresleep>
  if(ip->valid == 0){
    80004708:	40bc                	lw	a5,64(s1)
    8000470a:	cf99                	beqz	a5,80004728 <ilock+0x40>
}
    8000470c:	60e2                	ld	ra,24(sp)
    8000470e:	6442                	ld	s0,16(sp)
    80004710:	64a2                	ld	s1,8(sp)
    80004712:	6902                	ld	s2,0(sp)
    80004714:	6105                	addi	sp,sp,32
    80004716:	8082                	ret
    panic("ilock");
    80004718:	00004517          	auipc	a0,0x4
    8000471c:	14850513          	addi	a0,a0,328 # 80008860 <syscalls+0x1b8>
    80004720:	ffffc097          	auipc	ra,0xffffc
    80004724:	e0e080e7          	jalr	-498(ra) # 8000052e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004728:	40dc                	lw	a5,4(s1)
    8000472a:	0047d79b          	srliw	a5,a5,0x4
    8000472e:	00037597          	auipc	a1,0x37
    80004732:	8ea5a583          	lw	a1,-1814(a1) # 8003b018 <sb+0x18>
    80004736:	9dbd                	addw	a1,a1,a5
    80004738:	4088                	lw	a0,0(s1)
    8000473a:	fffff097          	auipc	ra,0xfffff
    8000473e:	7aa080e7          	jalr	1962(ra) # 80003ee4 <bread>
    80004742:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004744:	05850593          	addi	a1,a0,88
    80004748:	40dc                	lw	a5,4(s1)
    8000474a:	8bbd                	andi	a5,a5,15
    8000474c:	079a                	slli	a5,a5,0x6
    8000474e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004750:	00059783          	lh	a5,0(a1)
    80004754:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004758:	00259783          	lh	a5,2(a1)
    8000475c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80004760:	00459783          	lh	a5,4(a1)
    80004764:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004768:	00659783          	lh	a5,6(a1)
    8000476c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80004770:	459c                	lw	a5,8(a1)
    80004772:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004774:	03400613          	li	a2,52
    80004778:	05b1                	addi	a1,a1,12
    8000477a:	05048513          	addi	a0,s1,80
    8000477e:	ffffc097          	auipc	ra,0xffffc
    80004782:	5b6080e7          	jalr	1462(ra) # 80000d34 <memmove>
    brelse(bp);
    80004786:	854a                	mv	a0,s2
    80004788:	00000097          	auipc	ra,0x0
    8000478c:	88c080e7          	jalr	-1908(ra) # 80004014 <brelse>
    ip->valid = 1;
    80004790:	4785                	li	a5,1
    80004792:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004794:	04449783          	lh	a5,68(s1)
    80004798:	fbb5                	bnez	a5,8000470c <ilock+0x24>
      panic("ilock: no type");
    8000479a:	00004517          	auipc	a0,0x4
    8000479e:	0ce50513          	addi	a0,a0,206 # 80008868 <syscalls+0x1c0>
    800047a2:	ffffc097          	auipc	ra,0xffffc
    800047a6:	d8c080e7          	jalr	-628(ra) # 8000052e <panic>

00000000800047aa <iunlock>:
{
    800047aa:	1101                	addi	sp,sp,-32
    800047ac:	ec06                	sd	ra,24(sp)
    800047ae:	e822                	sd	s0,16(sp)
    800047b0:	e426                	sd	s1,8(sp)
    800047b2:	e04a                	sd	s2,0(sp)
    800047b4:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800047b6:	c905                	beqz	a0,800047e6 <iunlock+0x3c>
    800047b8:	84aa                	mv	s1,a0
    800047ba:	01050913          	addi	s2,a0,16
    800047be:	854a                	mv	a0,s2
    800047c0:	00001097          	auipc	ra,0x1
    800047c4:	c8e080e7          	jalr	-882(ra) # 8000544e <holdingsleep>
    800047c8:	cd19                	beqz	a0,800047e6 <iunlock+0x3c>
    800047ca:	449c                	lw	a5,8(s1)
    800047cc:	00f05d63          	blez	a5,800047e6 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800047d0:	854a                	mv	a0,s2
    800047d2:	00001097          	auipc	ra,0x1
    800047d6:	c38080e7          	jalr	-968(ra) # 8000540a <releasesleep>
}
    800047da:	60e2                	ld	ra,24(sp)
    800047dc:	6442                	ld	s0,16(sp)
    800047de:	64a2                	ld	s1,8(sp)
    800047e0:	6902                	ld	s2,0(sp)
    800047e2:	6105                	addi	sp,sp,32
    800047e4:	8082                	ret
    panic("iunlock");
    800047e6:	00004517          	auipc	a0,0x4
    800047ea:	09250513          	addi	a0,a0,146 # 80008878 <syscalls+0x1d0>
    800047ee:	ffffc097          	auipc	ra,0xffffc
    800047f2:	d40080e7          	jalr	-704(ra) # 8000052e <panic>

00000000800047f6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800047f6:	7179                	addi	sp,sp,-48
    800047f8:	f406                	sd	ra,40(sp)
    800047fa:	f022                	sd	s0,32(sp)
    800047fc:	ec26                	sd	s1,24(sp)
    800047fe:	e84a                	sd	s2,16(sp)
    80004800:	e44e                	sd	s3,8(sp)
    80004802:	e052                	sd	s4,0(sp)
    80004804:	1800                	addi	s0,sp,48
    80004806:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004808:	05050493          	addi	s1,a0,80
    8000480c:	08050913          	addi	s2,a0,128
    80004810:	a021                	j	80004818 <itrunc+0x22>
    80004812:	0491                	addi	s1,s1,4
    80004814:	01248d63          	beq	s1,s2,8000482e <itrunc+0x38>
    if(ip->addrs[i]){
    80004818:	408c                	lw	a1,0(s1)
    8000481a:	dde5                	beqz	a1,80004812 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000481c:	0009a503          	lw	a0,0(s3)
    80004820:	00000097          	auipc	ra,0x0
    80004824:	90a080e7          	jalr	-1782(ra) # 8000412a <bfree>
      ip->addrs[i] = 0;
    80004828:	0004a023          	sw	zero,0(s1)
    8000482c:	b7dd                	j	80004812 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000482e:	0809a583          	lw	a1,128(s3)
    80004832:	e185                	bnez	a1,80004852 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004834:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004838:	854e                	mv	a0,s3
    8000483a:	00000097          	auipc	ra,0x0
    8000483e:	de4080e7          	jalr	-540(ra) # 8000461e <iupdate>
}
    80004842:	70a2                	ld	ra,40(sp)
    80004844:	7402                	ld	s0,32(sp)
    80004846:	64e2                	ld	s1,24(sp)
    80004848:	6942                	ld	s2,16(sp)
    8000484a:	69a2                	ld	s3,8(sp)
    8000484c:	6a02                	ld	s4,0(sp)
    8000484e:	6145                	addi	sp,sp,48
    80004850:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004852:	0009a503          	lw	a0,0(s3)
    80004856:	fffff097          	auipc	ra,0xfffff
    8000485a:	68e080e7          	jalr	1678(ra) # 80003ee4 <bread>
    8000485e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004860:	05850493          	addi	s1,a0,88
    80004864:	45850913          	addi	s2,a0,1112
    80004868:	a021                	j	80004870 <itrunc+0x7a>
    8000486a:	0491                	addi	s1,s1,4
    8000486c:	01248b63          	beq	s1,s2,80004882 <itrunc+0x8c>
      if(a[j])
    80004870:	408c                	lw	a1,0(s1)
    80004872:	dde5                	beqz	a1,8000486a <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80004874:	0009a503          	lw	a0,0(s3)
    80004878:	00000097          	auipc	ra,0x0
    8000487c:	8b2080e7          	jalr	-1870(ra) # 8000412a <bfree>
    80004880:	b7ed                	j	8000486a <itrunc+0x74>
    brelse(bp);
    80004882:	8552                	mv	a0,s4
    80004884:	fffff097          	auipc	ra,0xfffff
    80004888:	790080e7          	jalr	1936(ra) # 80004014 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000488c:	0809a583          	lw	a1,128(s3)
    80004890:	0009a503          	lw	a0,0(s3)
    80004894:	00000097          	auipc	ra,0x0
    80004898:	896080e7          	jalr	-1898(ra) # 8000412a <bfree>
    ip->addrs[NDIRECT] = 0;
    8000489c:	0809a023          	sw	zero,128(s3)
    800048a0:	bf51                	j	80004834 <itrunc+0x3e>

00000000800048a2 <iput>:
{
    800048a2:	1101                	addi	sp,sp,-32
    800048a4:	ec06                	sd	ra,24(sp)
    800048a6:	e822                	sd	s0,16(sp)
    800048a8:	e426                	sd	s1,8(sp)
    800048aa:	e04a                	sd	s2,0(sp)
    800048ac:	1000                	addi	s0,sp,32
    800048ae:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800048b0:	00036517          	auipc	a0,0x36
    800048b4:	77050513          	addi	a0,a0,1904 # 8003b020 <itable>
    800048b8:	ffffc097          	auipc	ra,0xffffc
    800048bc:	30e080e7          	jalr	782(ra) # 80000bc6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800048c0:	4498                	lw	a4,8(s1)
    800048c2:	4785                	li	a5,1
    800048c4:	02f70363          	beq	a4,a5,800048ea <iput+0x48>
  ip->ref--;
    800048c8:	449c                	lw	a5,8(s1)
    800048ca:	37fd                	addiw	a5,a5,-1
    800048cc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800048ce:	00036517          	auipc	a0,0x36
    800048d2:	75250513          	addi	a0,a0,1874 # 8003b020 <itable>
    800048d6:	ffffc097          	auipc	ra,0xffffc
    800048da:	3ba080e7          	jalr	954(ra) # 80000c90 <release>
}
    800048de:	60e2                	ld	ra,24(sp)
    800048e0:	6442                	ld	s0,16(sp)
    800048e2:	64a2                	ld	s1,8(sp)
    800048e4:	6902                	ld	s2,0(sp)
    800048e6:	6105                	addi	sp,sp,32
    800048e8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800048ea:	40bc                	lw	a5,64(s1)
    800048ec:	dff1                	beqz	a5,800048c8 <iput+0x26>
    800048ee:	04a49783          	lh	a5,74(s1)
    800048f2:	fbf9                	bnez	a5,800048c8 <iput+0x26>
    acquiresleep(&ip->lock);
    800048f4:	01048913          	addi	s2,s1,16
    800048f8:	854a                	mv	a0,s2
    800048fa:	00001097          	auipc	ra,0x1
    800048fe:	aba080e7          	jalr	-1350(ra) # 800053b4 <acquiresleep>
    release(&itable.lock);
    80004902:	00036517          	auipc	a0,0x36
    80004906:	71e50513          	addi	a0,a0,1822 # 8003b020 <itable>
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	386080e7          	jalr	902(ra) # 80000c90 <release>
    itrunc(ip);
    80004912:	8526                	mv	a0,s1
    80004914:	00000097          	auipc	ra,0x0
    80004918:	ee2080e7          	jalr	-286(ra) # 800047f6 <itrunc>
    ip->type = 0;
    8000491c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004920:	8526                	mv	a0,s1
    80004922:	00000097          	auipc	ra,0x0
    80004926:	cfc080e7          	jalr	-772(ra) # 8000461e <iupdate>
    ip->valid = 0;
    8000492a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000492e:	854a                	mv	a0,s2
    80004930:	00001097          	auipc	ra,0x1
    80004934:	ada080e7          	jalr	-1318(ra) # 8000540a <releasesleep>
    acquire(&itable.lock);
    80004938:	00036517          	auipc	a0,0x36
    8000493c:	6e850513          	addi	a0,a0,1768 # 8003b020 <itable>
    80004940:	ffffc097          	auipc	ra,0xffffc
    80004944:	286080e7          	jalr	646(ra) # 80000bc6 <acquire>
    80004948:	b741                	j	800048c8 <iput+0x26>

000000008000494a <iunlockput>:
{
    8000494a:	1101                	addi	sp,sp,-32
    8000494c:	ec06                	sd	ra,24(sp)
    8000494e:	e822                	sd	s0,16(sp)
    80004950:	e426                	sd	s1,8(sp)
    80004952:	1000                	addi	s0,sp,32
    80004954:	84aa                	mv	s1,a0
  iunlock(ip);
    80004956:	00000097          	auipc	ra,0x0
    8000495a:	e54080e7          	jalr	-428(ra) # 800047aa <iunlock>
  iput(ip);
    8000495e:	8526                	mv	a0,s1
    80004960:	00000097          	auipc	ra,0x0
    80004964:	f42080e7          	jalr	-190(ra) # 800048a2 <iput>
}
    80004968:	60e2                	ld	ra,24(sp)
    8000496a:	6442                	ld	s0,16(sp)
    8000496c:	64a2                	ld	s1,8(sp)
    8000496e:	6105                	addi	sp,sp,32
    80004970:	8082                	ret

0000000080004972 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004972:	1141                	addi	sp,sp,-16
    80004974:	e422                	sd	s0,8(sp)
    80004976:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004978:	411c                	lw	a5,0(a0)
    8000497a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000497c:	415c                	lw	a5,4(a0)
    8000497e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004980:	04451783          	lh	a5,68(a0)
    80004984:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004988:	04a51783          	lh	a5,74(a0)
    8000498c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004990:	04c56783          	lwu	a5,76(a0)
    80004994:	e99c                	sd	a5,16(a1)
}
    80004996:	6422                	ld	s0,8(sp)
    80004998:	0141                	addi	sp,sp,16
    8000499a:	8082                	ret

000000008000499c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000499c:	457c                	lw	a5,76(a0)
    8000499e:	0ed7e963          	bltu	a5,a3,80004a90 <readi+0xf4>
{
    800049a2:	7159                	addi	sp,sp,-112
    800049a4:	f486                	sd	ra,104(sp)
    800049a6:	f0a2                	sd	s0,96(sp)
    800049a8:	eca6                	sd	s1,88(sp)
    800049aa:	e8ca                	sd	s2,80(sp)
    800049ac:	e4ce                	sd	s3,72(sp)
    800049ae:	e0d2                	sd	s4,64(sp)
    800049b0:	fc56                	sd	s5,56(sp)
    800049b2:	f85a                	sd	s6,48(sp)
    800049b4:	f45e                	sd	s7,40(sp)
    800049b6:	f062                	sd	s8,32(sp)
    800049b8:	ec66                	sd	s9,24(sp)
    800049ba:	e86a                	sd	s10,16(sp)
    800049bc:	e46e                	sd	s11,8(sp)
    800049be:	1880                	addi	s0,sp,112
    800049c0:	8baa                	mv	s7,a0
    800049c2:	8c2e                	mv	s8,a1
    800049c4:	8ab2                	mv	s5,a2
    800049c6:	84b6                	mv	s1,a3
    800049c8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800049ca:	9f35                	addw	a4,a4,a3
    return 0;
    800049cc:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800049ce:	0ad76063          	bltu	a4,a3,80004a6e <readi+0xd2>
  if(off + n > ip->size)
    800049d2:	00e7f463          	bgeu	a5,a4,800049da <readi+0x3e>
    n = ip->size - off;
    800049d6:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800049da:	0a0b0963          	beqz	s6,80004a8c <readi+0xf0>
    800049de:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800049e0:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800049e4:	5cfd                	li	s9,-1
    800049e6:	a82d                	j	80004a20 <readi+0x84>
    800049e8:	020a1d93          	slli	s11,s4,0x20
    800049ec:	020ddd93          	srli	s11,s11,0x20
    800049f0:	05890793          	addi	a5,s2,88
    800049f4:	86ee                	mv	a3,s11
    800049f6:	963e                	add	a2,a2,a5
    800049f8:	85d6                	mv	a1,s5
    800049fa:	8562                	mv	a0,s8
    800049fc:	ffffe097          	auipc	ra,0xffffe
    80004a00:	09e080e7          	jalr	158(ra) # 80002a9a <either_copyout>
    80004a04:	05950d63          	beq	a0,s9,80004a5e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004a08:	854a                	mv	a0,s2
    80004a0a:	fffff097          	auipc	ra,0xfffff
    80004a0e:	60a080e7          	jalr	1546(ra) # 80004014 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004a12:	013a09bb          	addw	s3,s4,s3
    80004a16:	009a04bb          	addw	s1,s4,s1
    80004a1a:	9aee                	add	s5,s5,s11
    80004a1c:	0569f763          	bgeu	s3,s6,80004a6a <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004a20:	000ba903          	lw	s2,0(s7)
    80004a24:	00a4d59b          	srliw	a1,s1,0xa
    80004a28:	855e                	mv	a0,s7
    80004a2a:	00000097          	auipc	ra,0x0
    80004a2e:	8ae080e7          	jalr	-1874(ra) # 800042d8 <bmap>
    80004a32:	0005059b          	sext.w	a1,a0
    80004a36:	854a                	mv	a0,s2
    80004a38:	fffff097          	auipc	ra,0xfffff
    80004a3c:	4ac080e7          	jalr	1196(ra) # 80003ee4 <bread>
    80004a40:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004a42:	3ff4f613          	andi	a2,s1,1023
    80004a46:	40cd07bb          	subw	a5,s10,a2
    80004a4a:	413b073b          	subw	a4,s6,s3
    80004a4e:	8a3e                	mv	s4,a5
    80004a50:	2781                	sext.w	a5,a5
    80004a52:	0007069b          	sext.w	a3,a4
    80004a56:	f8f6f9e3          	bgeu	a3,a5,800049e8 <readi+0x4c>
    80004a5a:	8a3a                	mv	s4,a4
    80004a5c:	b771                	j	800049e8 <readi+0x4c>
      brelse(bp);
    80004a5e:	854a                	mv	a0,s2
    80004a60:	fffff097          	auipc	ra,0xfffff
    80004a64:	5b4080e7          	jalr	1460(ra) # 80004014 <brelse>
      tot = -1;
    80004a68:	59fd                	li	s3,-1
  }
  return tot;
    80004a6a:	0009851b          	sext.w	a0,s3
}
    80004a6e:	70a6                	ld	ra,104(sp)
    80004a70:	7406                	ld	s0,96(sp)
    80004a72:	64e6                	ld	s1,88(sp)
    80004a74:	6946                	ld	s2,80(sp)
    80004a76:	69a6                	ld	s3,72(sp)
    80004a78:	6a06                	ld	s4,64(sp)
    80004a7a:	7ae2                	ld	s5,56(sp)
    80004a7c:	7b42                	ld	s6,48(sp)
    80004a7e:	7ba2                	ld	s7,40(sp)
    80004a80:	7c02                	ld	s8,32(sp)
    80004a82:	6ce2                	ld	s9,24(sp)
    80004a84:	6d42                	ld	s10,16(sp)
    80004a86:	6da2                	ld	s11,8(sp)
    80004a88:	6165                	addi	sp,sp,112
    80004a8a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004a8c:	89da                	mv	s3,s6
    80004a8e:	bff1                	j	80004a6a <readi+0xce>
    return 0;
    80004a90:	4501                	li	a0,0
}
    80004a92:	8082                	ret

0000000080004a94 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004a94:	457c                	lw	a5,76(a0)
    80004a96:	10d7e863          	bltu	a5,a3,80004ba6 <writei+0x112>
{
    80004a9a:	7159                	addi	sp,sp,-112
    80004a9c:	f486                	sd	ra,104(sp)
    80004a9e:	f0a2                	sd	s0,96(sp)
    80004aa0:	eca6                	sd	s1,88(sp)
    80004aa2:	e8ca                	sd	s2,80(sp)
    80004aa4:	e4ce                	sd	s3,72(sp)
    80004aa6:	e0d2                	sd	s4,64(sp)
    80004aa8:	fc56                	sd	s5,56(sp)
    80004aaa:	f85a                	sd	s6,48(sp)
    80004aac:	f45e                	sd	s7,40(sp)
    80004aae:	f062                	sd	s8,32(sp)
    80004ab0:	ec66                	sd	s9,24(sp)
    80004ab2:	e86a                	sd	s10,16(sp)
    80004ab4:	e46e                	sd	s11,8(sp)
    80004ab6:	1880                	addi	s0,sp,112
    80004ab8:	8b2a                	mv	s6,a0
    80004aba:	8c2e                	mv	s8,a1
    80004abc:	8ab2                	mv	s5,a2
    80004abe:	8936                	mv	s2,a3
    80004ac0:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004ac2:	00e687bb          	addw	a5,a3,a4
    80004ac6:	0ed7e263          	bltu	a5,a3,80004baa <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004aca:	00043737          	lui	a4,0x43
    80004ace:	0ef76063          	bltu	a4,a5,80004bae <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004ad2:	0c0b8863          	beqz	s7,80004ba2 <writei+0x10e>
    80004ad6:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004ad8:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004adc:	5cfd                	li	s9,-1
    80004ade:	a091                	j	80004b22 <writei+0x8e>
    80004ae0:	02099d93          	slli	s11,s3,0x20
    80004ae4:	020ddd93          	srli	s11,s11,0x20
    80004ae8:	05848793          	addi	a5,s1,88
    80004aec:	86ee                	mv	a3,s11
    80004aee:	8656                	mv	a2,s5
    80004af0:	85e2                	mv	a1,s8
    80004af2:	953e                	add	a0,a0,a5
    80004af4:	ffffe097          	auipc	ra,0xffffe
    80004af8:	ffc080e7          	jalr	-4(ra) # 80002af0 <either_copyin>
    80004afc:	07950263          	beq	a0,s9,80004b60 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004b00:	8526                	mv	a0,s1
    80004b02:	00000097          	auipc	ra,0x0
    80004b06:	792080e7          	jalr	1938(ra) # 80005294 <log_write>
    brelse(bp);
    80004b0a:	8526                	mv	a0,s1
    80004b0c:	fffff097          	auipc	ra,0xfffff
    80004b10:	508080e7          	jalr	1288(ra) # 80004014 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004b14:	01498a3b          	addw	s4,s3,s4
    80004b18:	0129893b          	addw	s2,s3,s2
    80004b1c:	9aee                	add	s5,s5,s11
    80004b1e:	057a7663          	bgeu	s4,s7,80004b6a <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004b22:	000b2483          	lw	s1,0(s6)
    80004b26:	00a9559b          	srliw	a1,s2,0xa
    80004b2a:	855a                	mv	a0,s6
    80004b2c:	fffff097          	auipc	ra,0xfffff
    80004b30:	7ac080e7          	jalr	1964(ra) # 800042d8 <bmap>
    80004b34:	0005059b          	sext.w	a1,a0
    80004b38:	8526                	mv	a0,s1
    80004b3a:	fffff097          	auipc	ra,0xfffff
    80004b3e:	3aa080e7          	jalr	938(ra) # 80003ee4 <bread>
    80004b42:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004b44:	3ff97513          	andi	a0,s2,1023
    80004b48:	40ad07bb          	subw	a5,s10,a0
    80004b4c:	414b873b          	subw	a4,s7,s4
    80004b50:	89be                	mv	s3,a5
    80004b52:	2781                	sext.w	a5,a5
    80004b54:	0007069b          	sext.w	a3,a4
    80004b58:	f8f6f4e3          	bgeu	a3,a5,80004ae0 <writei+0x4c>
    80004b5c:	89ba                	mv	s3,a4
    80004b5e:	b749                	j	80004ae0 <writei+0x4c>
      brelse(bp);
    80004b60:	8526                	mv	a0,s1
    80004b62:	fffff097          	auipc	ra,0xfffff
    80004b66:	4b2080e7          	jalr	1202(ra) # 80004014 <brelse>
  }

  if(off > ip->size)
    80004b6a:	04cb2783          	lw	a5,76(s6)
    80004b6e:	0127f463          	bgeu	a5,s2,80004b76 <writei+0xe2>
    ip->size = off;
    80004b72:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004b76:	855a                	mv	a0,s6
    80004b78:	00000097          	auipc	ra,0x0
    80004b7c:	aa6080e7          	jalr	-1370(ra) # 8000461e <iupdate>

  return tot;
    80004b80:	000a051b          	sext.w	a0,s4
}
    80004b84:	70a6                	ld	ra,104(sp)
    80004b86:	7406                	ld	s0,96(sp)
    80004b88:	64e6                	ld	s1,88(sp)
    80004b8a:	6946                	ld	s2,80(sp)
    80004b8c:	69a6                	ld	s3,72(sp)
    80004b8e:	6a06                	ld	s4,64(sp)
    80004b90:	7ae2                	ld	s5,56(sp)
    80004b92:	7b42                	ld	s6,48(sp)
    80004b94:	7ba2                	ld	s7,40(sp)
    80004b96:	7c02                	ld	s8,32(sp)
    80004b98:	6ce2                	ld	s9,24(sp)
    80004b9a:	6d42                	ld	s10,16(sp)
    80004b9c:	6da2                	ld	s11,8(sp)
    80004b9e:	6165                	addi	sp,sp,112
    80004ba0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004ba2:	8a5e                	mv	s4,s7
    80004ba4:	bfc9                	j	80004b76 <writei+0xe2>
    return -1;
    80004ba6:	557d                	li	a0,-1
}
    80004ba8:	8082                	ret
    return -1;
    80004baa:	557d                	li	a0,-1
    80004bac:	bfe1                	j	80004b84 <writei+0xf0>
    return -1;
    80004bae:	557d                	li	a0,-1
    80004bb0:	bfd1                	j	80004b84 <writei+0xf0>

0000000080004bb2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004bb2:	1141                	addi	sp,sp,-16
    80004bb4:	e406                	sd	ra,8(sp)
    80004bb6:	e022                	sd	s0,0(sp)
    80004bb8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004bba:	4639                	li	a2,14
    80004bbc:	ffffc097          	auipc	ra,0xffffc
    80004bc0:	1f4080e7          	jalr	500(ra) # 80000db0 <strncmp>
}
    80004bc4:	60a2                	ld	ra,8(sp)
    80004bc6:	6402                	ld	s0,0(sp)
    80004bc8:	0141                	addi	sp,sp,16
    80004bca:	8082                	ret

0000000080004bcc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004bcc:	7139                	addi	sp,sp,-64
    80004bce:	fc06                	sd	ra,56(sp)
    80004bd0:	f822                	sd	s0,48(sp)
    80004bd2:	f426                	sd	s1,40(sp)
    80004bd4:	f04a                	sd	s2,32(sp)
    80004bd6:	ec4e                	sd	s3,24(sp)
    80004bd8:	e852                	sd	s4,16(sp)
    80004bda:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004bdc:	04451703          	lh	a4,68(a0)
    80004be0:	4785                	li	a5,1
    80004be2:	00f71a63          	bne	a4,a5,80004bf6 <dirlookup+0x2a>
    80004be6:	892a                	mv	s2,a0
    80004be8:	89ae                	mv	s3,a1
    80004bea:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004bec:	457c                	lw	a5,76(a0)
    80004bee:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004bf0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004bf2:	e79d                	bnez	a5,80004c20 <dirlookup+0x54>
    80004bf4:	a8a5                	j	80004c6c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004bf6:	00004517          	auipc	a0,0x4
    80004bfa:	c8a50513          	addi	a0,a0,-886 # 80008880 <syscalls+0x1d8>
    80004bfe:	ffffc097          	auipc	ra,0xffffc
    80004c02:	930080e7          	jalr	-1744(ra) # 8000052e <panic>
      panic("dirlookup read");
    80004c06:	00004517          	auipc	a0,0x4
    80004c0a:	c9250513          	addi	a0,a0,-878 # 80008898 <syscalls+0x1f0>
    80004c0e:	ffffc097          	auipc	ra,0xffffc
    80004c12:	920080e7          	jalr	-1760(ra) # 8000052e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004c16:	24c1                	addiw	s1,s1,16
    80004c18:	04c92783          	lw	a5,76(s2)
    80004c1c:	04f4f763          	bgeu	s1,a5,80004c6a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004c20:	4741                	li	a4,16
    80004c22:	86a6                	mv	a3,s1
    80004c24:	fc040613          	addi	a2,s0,-64
    80004c28:	4581                	li	a1,0
    80004c2a:	854a                	mv	a0,s2
    80004c2c:	00000097          	auipc	ra,0x0
    80004c30:	d70080e7          	jalr	-656(ra) # 8000499c <readi>
    80004c34:	47c1                	li	a5,16
    80004c36:	fcf518e3          	bne	a0,a5,80004c06 <dirlookup+0x3a>
    if(de.inum == 0)
    80004c3a:	fc045783          	lhu	a5,-64(s0)
    80004c3e:	dfe1                	beqz	a5,80004c16 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004c40:	fc240593          	addi	a1,s0,-62
    80004c44:	854e                	mv	a0,s3
    80004c46:	00000097          	auipc	ra,0x0
    80004c4a:	f6c080e7          	jalr	-148(ra) # 80004bb2 <namecmp>
    80004c4e:	f561                	bnez	a0,80004c16 <dirlookup+0x4a>
      if(poff)
    80004c50:	000a0463          	beqz	s4,80004c58 <dirlookup+0x8c>
        *poff = off;
    80004c54:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004c58:	fc045583          	lhu	a1,-64(s0)
    80004c5c:	00092503          	lw	a0,0(s2)
    80004c60:	fffff097          	auipc	ra,0xfffff
    80004c64:	754080e7          	jalr	1876(ra) # 800043b4 <iget>
    80004c68:	a011                	j	80004c6c <dirlookup+0xa0>
  return 0;
    80004c6a:	4501                	li	a0,0
}
    80004c6c:	70e2                	ld	ra,56(sp)
    80004c6e:	7442                	ld	s0,48(sp)
    80004c70:	74a2                	ld	s1,40(sp)
    80004c72:	7902                	ld	s2,32(sp)
    80004c74:	69e2                	ld	s3,24(sp)
    80004c76:	6a42                	ld	s4,16(sp)
    80004c78:	6121                	addi	sp,sp,64
    80004c7a:	8082                	ret

0000000080004c7c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004c7c:	711d                	addi	sp,sp,-96
    80004c7e:	ec86                	sd	ra,88(sp)
    80004c80:	e8a2                	sd	s0,80(sp)
    80004c82:	e4a6                	sd	s1,72(sp)
    80004c84:	e0ca                	sd	s2,64(sp)
    80004c86:	fc4e                	sd	s3,56(sp)
    80004c88:	f852                	sd	s4,48(sp)
    80004c8a:	f456                	sd	s5,40(sp)
    80004c8c:	f05a                	sd	s6,32(sp)
    80004c8e:	ec5e                	sd	s7,24(sp)
    80004c90:	e862                	sd	s8,16(sp)
    80004c92:	e466                	sd	s9,8(sp)
    80004c94:	1080                	addi	s0,sp,96
    80004c96:	84aa                	mv	s1,a0
    80004c98:	8aae                	mv	s5,a1
    80004c9a:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004c9c:	00054703          	lbu	a4,0(a0)
    80004ca0:	02f00793          	li	a5,47
    80004ca4:	02f70263          	beq	a4,a5,80004cc8 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004ca8:	ffffd097          	auipc	ra,0xffffd
    80004cac:	e60080e7          	jalr	-416(ra) # 80001b08 <myproc>
    80004cb0:	6968                	ld	a0,208(a0)
    80004cb2:	00000097          	auipc	ra,0x0
    80004cb6:	9f8080e7          	jalr	-1544(ra) # 800046aa <idup>
    80004cba:	89aa                	mv	s3,a0
  while(*path == '/')
    80004cbc:	02f00913          	li	s2,47
  len = path - s;
    80004cc0:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004cc2:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004cc4:	4b85                	li	s7,1
    80004cc6:	a865                	j	80004d7e <namex+0x102>
    ip = iget(ROOTDEV, ROOTINO);
    80004cc8:	4585                	li	a1,1
    80004cca:	4505                	li	a0,1
    80004ccc:	fffff097          	auipc	ra,0xfffff
    80004cd0:	6e8080e7          	jalr	1768(ra) # 800043b4 <iget>
    80004cd4:	89aa                	mv	s3,a0
    80004cd6:	b7dd                	j	80004cbc <namex+0x40>
      iunlockput(ip);
    80004cd8:	854e                	mv	a0,s3
    80004cda:	00000097          	auipc	ra,0x0
    80004cde:	c70080e7          	jalr	-912(ra) # 8000494a <iunlockput>
      return 0;
    80004ce2:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004ce4:	854e                	mv	a0,s3
    80004ce6:	60e6                	ld	ra,88(sp)
    80004ce8:	6446                	ld	s0,80(sp)
    80004cea:	64a6                	ld	s1,72(sp)
    80004cec:	6906                	ld	s2,64(sp)
    80004cee:	79e2                	ld	s3,56(sp)
    80004cf0:	7a42                	ld	s4,48(sp)
    80004cf2:	7aa2                	ld	s5,40(sp)
    80004cf4:	7b02                	ld	s6,32(sp)
    80004cf6:	6be2                	ld	s7,24(sp)
    80004cf8:	6c42                	ld	s8,16(sp)
    80004cfa:	6ca2                	ld	s9,8(sp)
    80004cfc:	6125                	addi	sp,sp,96
    80004cfe:	8082                	ret
      iunlock(ip);
    80004d00:	854e                	mv	a0,s3
    80004d02:	00000097          	auipc	ra,0x0
    80004d06:	aa8080e7          	jalr	-1368(ra) # 800047aa <iunlock>
      return ip;
    80004d0a:	bfe9                	j	80004ce4 <namex+0x68>
      iunlockput(ip);
    80004d0c:	854e                	mv	a0,s3
    80004d0e:	00000097          	auipc	ra,0x0
    80004d12:	c3c080e7          	jalr	-964(ra) # 8000494a <iunlockput>
      return 0;
    80004d16:	89e6                	mv	s3,s9
    80004d18:	b7f1                	j	80004ce4 <namex+0x68>
  len = path - s;
    80004d1a:	40b48633          	sub	a2,s1,a1
    80004d1e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004d22:	099c5463          	bge	s8,s9,80004daa <namex+0x12e>
    memmove(name, s, DIRSIZ);
    80004d26:	4639                	li	a2,14
    80004d28:	8552                	mv	a0,s4
    80004d2a:	ffffc097          	auipc	ra,0xffffc
    80004d2e:	00a080e7          	jalr	10(ra) # 80000d34 <memmove>
  while(*path == '/')
    80004d32:	0004c783          	lbu	a5,0(s1)
    80004d36:	01279763          	bne	a5,s2,80004d44 <namex+0xc8>
    path++;
    80004d3a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004d3c:	0004c783          	lbu	a5,0(s1)
    80004d40:	ff278de3          	beq	a5,s2,80004d3a <namex+0xbe>
    ilock(ip);
    80004d44:	854e                	mv	a0,s3
    80004d46:	00000097          	auipc	ra,0x0
    80004d4a:	9a2080e7          	jalr	-1630(ra) # 800046e8 <ilock>
    if(ip->type != T_DIR){
    80004d4e:	04499783          	lh	a5,68(s3)
    80004d52:	f97793e3          	bne	a5,s7,80004cd8 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004d56:	000a8563          	beqz	s5,80004d60 <namex+0xe4>
    80004d5a:	0004c783          	lbu	a5,0(s1)
    80004d5e:	d3cd                	beqz	a5,80004d00 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004d60:	865a                	mv	a2,s6
    80004d62:	85d2                	mv	a1,s4
    80004d64:	854e                	mv	a0,s3
    80004d66:	00000097          	auipc	ra,0x0
    80004d6a:	e66080e7          	jalr	-410(ra) # 80004bcc <dirlookup>
    80004d6e:	8caa                	mv	s9,a0
    80004d70:	dd51                	beqz	a0,80004d0c <namex+0x90>
    iunlockput(ip);
    80004d72:	854e                	mv	a0,s3
    80004d74:	00000097          	auipc	ra,0x0
    80004d78:	bd6080e7          	jalr	-1066(ra) # 8000494a <iunlockput>
    ip = next;
    80004d7c:	89e6                	mv	s3,s9
  while(*path == '/')
    80004d7e:	0004c783          	lbu	a5,0(s1)
    80004d82:	05279763          	bne	a5,s2,80004dd0 <namex+0x154>
    path++;
    80004d86:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004d88:	0004c783          	lbu	a5,0(s1)
    80004d8c:	ff278de3          	beq	a5,s2,80004d86 <namex+0x10a>
  if(*path == 0)
    80004d90:	c79d                	beqz	a5,80004dbe <namex+0x142>
    path++;
    80004d92:	85a6                	mv	a1,s1
  len = path - s;
    80004d94:	8cda                	mv	s9,s6
    80004d96:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004d98:	01278963          	beq	a5,s2,80004daa <namex+0x12e>
    80004d9c:	dfbd                	beqz	a5,80004d1a <namex+0x9e>
    path++;
    80004d9e:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004da0:	0004c783          	lbu	a5,0(s1)
    80004da4:	ff279ce3          	bne	a5,s2,80004d9c <namex+0x120>
    80004da8:	bf8d                	j	80004d1a <namex+0x9e>
    memmove(name, s, len);
    80004daa:	2601                	sext.w	a2,a2
    80004dac:	8552                	mv	a0,s4
    80004dae:	ffffc097          	auipc	ra,0xffffc
    80004db2:	f86080e7          	jalr	-122(ra) # 80000d34 <memmove>
    name[len] = 0;
    80004db6:	9cd2                	add	s9,s9,s4
    80004db8:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004dbc:	bf9d                	j	80004d32 <namex+0xb6>
  if(nameiparent){
    80004dbe:	f20a83e3          	beqz	s5,80004ce4 <namex+0x68>
    iput(ip);
    80004dc2:	854e                	mv	a0,s3
    80004dc4:	00000097          	auipc	ra,0x0
    80004dc8:	ade080e7          	jalr	-1314(ra) # 800048a2 <iput>
    return 0;
    80004dcc:	4981                	li	s3,0
    80004dce:	bf19                	j	80004ce4 <namex+0x68>
  if(*path == 0)
    80004dd0:	d7fd                	beqz	a5,80004dbe <namex+0x142>
  while(*path != '/' && *path != 0)
    80004dd2:	0004c783          	lbu	a5,0(s1)
    80004dd6:	85a6                	mv	a1,s1
    80004dd8:	b7d1                	j	80004d9c <namex+0x120>

0000000080004dda <dirlink>:
{
    80004dda:	7139                	addi	sp,sp,-64
    80004ddc:	fc06                	sd	ra,56(sp)
    80004dde:	f822                	sd	s0,48(sp)
    80004de0:	f426                	sd	s1,40(sp)
    80004de2:	f04a                	sd	s2,32(sp)
    80004de4:	ec4e                	sd	s3,24(sp)
    80004de6:	e852                	sd	s4,16(sp)
    80004de8:	0080                	addi	s0,sp,64
    80004dea:	892a                	mv	s2,a0
    80004dec:	8a2e                	mv	s4,a1
    80004dee:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004df0:	4601                	li	a2,0
    80004df2:	00000097          	auipc	ra,0x0
    80004df6:	dda080e7          	jalr	-550(ra) # 80004bcc <dirlookup>
    80004dfa:	e93d                	bnez	a0,80004e70 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004dfc:	04c92483          	lw	s1,76(s2)
    80004e00:	c49d                	beqz	s1,80004e2e <dirlink+0x54>
    80004e02:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e04:	4741                	li	a4,16
    80004e06:	86a6                	mv	a3,s1
    80004e08:	fc040613          	addi	a2,s0,-64
    80004e0c:	4581                	li	a1,0
    80004e0e:	854a                	mv	a0,s2
    80004e10:	00000097          	auipc	ra,0x0
    80004e14:	b8c080e7          	jalr	-1140(ra) # 8000499c <readi>
    80004e18:	47c1                	li	a5,16
    80004e1a:	06f51163          	bne	a0,a5,80004e7c <dirlink+0xa2>
    if(de.inum == 0)
    80004e1e:	fc045783          	lhu	a5,-64(s0)
    80004e22:	c791                	beqz	a5,80004e2e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004e24:	24c1                	addiw	s1,s1,16
    80004e26:	04c92783          	lw	a5,76(s2)
    80004e2a:	fcf4ede3          	bltu	s1,a5,80004e04 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004e2e:	4639                	li	a2,14
    80004e30:	85d2                	mv	a1,s4
    80004e32:	fc240513          	addi	a0,s0,-62
    80004e36:	ffffc097          	auipc	ra,0xffffc
    80004e3a:	fb6080e7          	jalr	-74(ra) # 80000dec <strncpy>
  de.inum = inum;
    80004e3e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e42:	4741                	li	a4,16
    80004e44:	86a6                	mv	a3,s1
    80004e46:	fc040613          	addi	a2,s0,-64
    80004e4a:	4581                	li	a1,0
    80004e4c:	854a                	mv	a0,s2
    80004e4e:	00000097          	auipc	ra,0x0
    80004e52:	c46080e7          	jalr	-954(ra) # 80004a94 <writei>
    80004e56:	872a                	mv	a4,a0
    80004e58:	47c1                	li	a5,16
  return 0;
    80004e5a:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e5c:	02f71863          	bne	a4,a5,80004e8c <dirlink+0xb2>
}
    80004e60:	70e2                	ld	ra,56(sp)
    80004e62:	7442                	ld	s0,48(sp)
    80004e64:	74a2                	ld	s1,40(sp)
    80004e66:	7902                	ld	s2,32(sp)
    80004e68:	69e2                	ld	s3,24(sp)
    80004e6a:	6a42                	ld	s4,16(sp)
    80004e6c:	6121                	addi	sp,sp,64
    80004e6e:	8082                	ret
    iput(ip);
    80004e70:	00000097          	auipc	ra,0x0
    80004e74:	a32080e7          	jalr	-1486(ra) # 800048a2 <iput>
    return -1;
    80004e78:	557d                	li	a0,-1
    80004e7a:	b7dd                	j	80004e60 <dirlink+0x86>
      panic("dirlink read");
    80004e7c:	00004517          	auipc	a0,0x4
    80004e80:	a2c50513          	addi	a0,a0,-1492 # 800088a8 <syscalls+0x200>
    80004e84:	ffffb097          	auipc	ra,0xffffb
    80004e88:	6aa080e7          	jalr	1706(ra) # 8000052e <panic>
    panic("dirlink");
    80004e8c:	00004517          	auipc	a0,0x4
    80004e90:	b0c50513          	addi	a0,a0,-1268 # 80008998 <syscalls+0x2f0>
    80004e94:	ffffb097          	auipc	ra,0xffffb
    80004e98:	69a080e7          	jalr	1690(ra) # 8000052e <panic>

0000000080004e9c <namei>:

struct inode*
namei(char *path)
{
    80004e9c:	1101                	addi	sp,sp,-32
    80004e9e:	ec06                	sd	ra,24(sp)
    80004ea0:	e822                	sd	s0,16(sp)
    80004ea2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004ea4:	fe040613          	addi	a2,s0,-32
    80004ea8:	4581                	li	a1,0
    80004eaa:	00000097          	auipc	ra,0x0
    80004eae:	dd2080e7          	jalr	-558(ra) # 80004c7c <namex>
}
    80004eb2:	60e2                	ld	ra,24(sp)
    80004eb4:	6442                	ld	s0,16(sp)
    80004eb6:	6105                	addi	sp,sp,32
    80004eb8:	8082                	ret

0000000080004eba <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004eba:	1141                	addi	sp,sp,-16
    80004ebc:	e406                	sd	ra,8(sp)
    80004ebe:	e022                	sd	s0,0(sp)
    80004ec0:	0800                	addi	s0,sp,16
    80004ec2:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004ec4:	4585                	li	a1,1
    80004ec6:	00000097          	auipc	ra,0x0
    80004eca:	db6080e7          	jalr	-586(ra) # 80004c7c <namex>
}
    80004ece:	60a2                	ld	ra,8(sp)
    80004ed0:	6402                	ld	s0,0(sp)
    80004ed2:	0141                	addi	sp,sp,16
    80004ed4:	8082                	ret

0000000080004ed6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004ed6:	1101                	addi	sp,sp,-32
    80004ed8:	ec06                	sd	ra,24(sp)
    80004eda:	e822                	sd	s0,16(sp)
    80004edc:	e426                	sd	s1,8(sp)
    80004ede:	e04a                	sd	s2,0(sp)
    80004ee0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004ee2:	00038917          	auipc	s2,0x38
    80004ee6:	be690913          	addi	s2,s2,-1050 # 8003cac8 <log>
    80004eea:	01892583          	lw	a1,24(s2)
    80004eee:	02892503          	lw	a0,40(s2)
    80004ef2:	fffff097          	auipc	ra,0xfffff
    80004ef6:	ff2080e7          	jalr	-14(ra) # 80003ee4 <bread>
    80004efa:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004efc:	02c92683          	lw	a3,44(s2)
    80004f00:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004f02:	02d05863          	blez	a3,80004f32 <write_head+0x5c>
    80004f06:	00038797          	auipc	a5,0x38
    80004f0a:	bf278793          	addi	a5,a5,-1038 # 8003caf8 <log+0x30>
    80004f0e:	05c50713          	addi	a4,a0,92
    80004f12:	36fd                	addiw	a3,a3,-1
    80004f14:	02069613          	slli	a2,a3,0x20
    80004f18:	01e65693          	srli	a3,a2,0x1e
    80004f1c:	00038617          	auipc	a2,0x38
    80004f20:	be060613          	addi	a2,a2,-1056 # 8003cafc <log+0x34>
    80004f24:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004f26:	4390                	lw	a2,0(a5)
    80004f28:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004f2a:	0791                	addi	a5,a5,4
    80004f2c:	0711                	addi	a4,a4,4
    80004f2e:	fed79ce3          	bne	a5,a3,80004f26 <write_head+0x50>
  }
  bwrite(buf);
    80004f32:	8526                	mv	a0,s1
    80004f34:	fffff097          	auipc	ra,0xfffff
    80004f38:	0a2080e7          	jalr	162(ra) # 80003fd6 <bwrite>
  brelse(buf);
    80004f3c:	8526                	mv	a0,s1
    80004f3e:	fffff097          	auipc	ra,0xfffff
    80004f42:	0d6080e7          	jalr	214(ra) # 80004014 <brelse>
}
    80004f46:	60e2                	ld	ra,24(sp)
    80004f48:	6442                	ld	s0,16(sp)
    80004f4a:	64a2                	ld	s1,8(sp)
    80004f4c:	6902                	ld	s2,0(sp)
    80004f4e:	6105                	addi	sp,sp,32
    80004f50:	8082                	ret

0000000080004f52 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004f52:	00038797          	auipc	a5,0x38
    80004f56:	ba27a783          	lw	a5,-1118(a5) # 8003caf4 <log+0x2c>
    80004f5a:	0af05d63          	blez	a5,80005014 <install_trans+0xc2>
{
    80004f5e:	7139                	addi	sp,sp,-64
    80004f60:	fc06                	sd	ra,56(sp)
    80004f62:	f822                	sd	s0,48(sp)
    80004f64:	f426                	sd	s1,40(sp)
    80004f66:	f04a                	sd	s2,32(sp)
    80004f68:	ec4e                	sd	s3,24(sp)
    80004f6a:	e852                	sd	s4,16(sp)
    80004f6c:	e456                	sd	s5,8(sp)
    80004f6e:	e05a                	sd	s6,0(sp)
    80004f70:	0080                	addi	s0,sp,64
    80004f72:	8b2a                	mv	s6,a0
    80004f74:	00038a97          	auipc	s5,0x38
    80004f78:	b84a8a93          	addi	s5,s5,-1148 # 8003caf8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004f7c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004f7e:	00038997          	auipc	s3,0x38
    80004f82:	b4a98993          	addi	s3,s3,-1206 # 8003cac8 <log>
    80004f86:	a00d                	j	80004fa8 <install_trans+0x56>
    brelse(lbuf);
    80004f88:	854a                	mv	a0,s2
    80004f8a:	fffff097          	auipc	ra,0xfffff
    80004f8e:	08a080e7          	jalr	138(ra) # 80004014 <brelse>
    brelse(dbuf);
    80004f92:	8526                	mv	a0,s1
    80004f94:	fffff097          	auipc	ra,0xfffff
    80004f98:	080080e7          	jalr	128(ra) # 80004014 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004f9c:	2a05                	addiw	s4,s4,1
    80004f9e:	0a91                	addi	s5,s5,4
    80004fa0:	02c9a783          	lw	a5,44(s3)
    80004fa4:	04fa5e63          	bge	s4,a5,80005000 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004fa8:	0189a583          	lw	a1,24(s3)
    80004fac:	014585bb          	addw	a1,a1,s4
    80004fb0:	2585                	addiw	a1,a1,1
    80004fb2:	0289a503          	lw	a0,40(s3)
    80004fb6:	fffff097          	auipc	ra,0xfffff
    80004fba:	f2e080e7          	jalr	-210(ra) # 80003ee4 <bread>
    80004fbe:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004fc0:	000aa583          	lw	a1,0(s5)
    80004fc4:	0289a503          	lw	a0,40(s3)
    80004fc8:	fffff097          	auipc	ra,0xfffff
    80004fcc:	f1c080e7          	jalr	-228(ra) # 80003ee4 <bread>
    80004fd0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004fd2:	40000613          	li	a2,1024
    80004fd6:	05890593          	addi	a1,s2,88
    80004fda:	05850513          	addi	a0,a0,88
    80004fde:	ffffc097          	auipc	ra,0xffffc
    80004fe2:	d56080e7          	jalr	-682(ra) # 80000d34 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004fe6:	8526                	mv	a0,s1
    80004fe8:	fffff097          	auipc	ra,0xfffff
    80004fec:	fee080e7          	jalr	-18(ra) # 80003fd6 <bwrite>
    if(recovering == 0)
    80004ff0:	f80b1ce3          	bnez	s6,80004f88 <install_trans+0x36>
      bunpin(dbuf);
    80004ff4:	8526                	mv	a0,s1
    80004ff6:	fffff097          	auipc	ra,0xfffff
    80004ffa:	0f8080e7          	jalr	248(ra) # 800040ee <bunpin>
    80004ffe:	b769                	j	80004f88 <install_trans+0x36>
}
    80005000:	70e2                	ld	ra,56(sp)
    80005002:	7442                	ld	s0,48(sp)
    80005004:	74a2                	ld	s1,40(sp)
    80005006:	7902                	ld	s2,32(sp)
    80005008:	69e2                	ld	s3,24(sp)
    8000500a:	6a42                	ld	s4,16(sp)
    8000500c:	6aa2                	ld	s5,8(sp)
    8000500e:	6b02                	ld	s6,0(sp)
    80005010:	6121                	addi	sp,sp,64
    80005012:	8082                	ret
    80005014:	8082                	ret

0000000080005016 <initlog>:
{
    80005016:	7179                	addi	sp,sp,-48
    80005018:	f406                	sd	ra,40(sp)
    8000501a:	f022                	sd	s0,32(sp)
    8000501c:	ec26                	sd	s1,24(sp)
    8000501e:	e84a                	sd	s2,16(sp)
    80005020:	e44e                	sd	s3,8(sp)
    80005022:	1800                	addi	s0,sp,48
    80005024:	892a                	mv	s2,a0
    80005026:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80005028:	00038497          	auipc	s1,0x38
    8000502c:	aa048493          	addi	s1,s1,-1376 # 8003cac8 <log>
    80005030:	00004597          	auipc	a1,0x4
    80005034:	88858593          	addi	a1,a1,-1912 # 800088b8 <syscalls+0x210>
    80005038:	8526                	mv	a0,s1
    8000503a:	ffffc097          	auipc	ra,0xffffc
    8000503e:	afc080e7          	jalr	-1284(ra) # 80000b36 <initlock>
  log.start = sb->logstart;
    80005042:	0149a583          	lw	a1,20(s3)
    80005046:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80005048:	0109a783          	lw	a5,16(s3)
    8000504c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000504e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80005052:	854a                	mv	a0,s2
    80005054:	fffff097          	auipc	ra,0xfffff
    80005058:	e90080e7          	jalr	-368(ra) # 80003ee4 <bread>
  log.lh.n = lh->n;
    8000505c:	4d34                	lw	a3,88(a0)
    8000505e:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80005060:	02d05663          	blez	a3,8000508c <initlog+0x76>
    80005064:	05c50793          	addi	a5,a0,92
    80005068:	00038717          	auipc	a4,0x38
    8000506c:	a9070713          	addi	a4,a4,-1392 # 8003caf8 <log+0x30>
    80005070:	36fd                	addiw	a3,a3,-1
    80005072:	02069613          	slli	a2,a3,0x20
    80005076:	01e65693          	srli	a3,a2,0x1e
    8000507a:	06050613          	addi	a2,a0,96
    8000507e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80005080:	4390                	lw	a2,0(a5)
    80005082:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005084:	0791                	addi	a5,a5,4
    80005086:	0711                	addi	a4,a4,4
    80005088:	fed79ce3          	bne	a5,a3,80005080 <initlog+0x6a>
  brelse(buf);
    8000508c:	fffff097          	auipc	ra,0xfffff
    80005090:	f88080e7          	jalr	-120(ra) # 80004014 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80005094:	4505                	li	a0,1
    80005096:	00000097          	auipc	ra,0x0
    8000509a:	ebc080e7          	jalr	-324(ra) # 80004f52 <install_trans>
  log.lh.n = 0;
    8000509e:	00038797          	auipc	a5,0x38
    800050a2:	a407ab23          	sw	zero,-1450(a5) # 8003caf4 <log+0x2c>
  write_head(); // clear the log
    800050a6:	00000097          	auipc	ra,0x0
    800050aa:	e30080e7          	jalr	-464(ra) # 80004ed6 <write_head>
}
    800050ae:	70a2                	ld	ra,40(sp)
    800050b0:	7402                	ld	s0,32(sp)
    800050b2:	64e2                	ld	s1,24(sp)
    800050b4:	6942                	ld	s2,16(sp)
    800050b6:	69a2                	ld	s3,8(sp)
    800050b8:	6145                	addi	sp,sp,48
    800050ba:	8082                	ret

00000000800050bc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800050bc:	1101                	addi	sp,sp,-32
    800050be:	ec06                	sd	ra,24(sp)
    800050c0:	e822                	sd	s0,16(sp)
    800050c2:	e426                	sd	s1,8(sp)
    800050c4:	e04a                	sd	s2,0(sp)
    800050c6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800050c8:	00038517          	auipc	a0,0x38
    800050cc:	a0050513          	addi	a0,a0,-1536 # 8003cac8 <log>
    800050d0:	ffffc097          	auipc	ra,0xffffc
    800050d4:	af6080e7          	jalr	-1290(ra) # 80000bc6 <acquire>
  while(1){
    if(log.committing){
    800050d8:	00038497          	auipc	s1,0x38
    800050dc:	9f048493          	addi	s1,s1,-1552 # 8003cac8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800050e0:	4979                	li	s2,30
    800050e2:	a039                	j	800050f0 <begin_op+0x34>
      sleep(&log, &log.lock);
    800050e4:	85a6                	mv	a1,s1
    800050e6:	8526                	mv	a0,s1
    800050e8:	ffffd097          	auipc	ra,0xffffd
    800050ec:	4b0080e7          	jalr	1200(ra) # 80002598 <sleep>
    if(log.committing){
    800050f0:	50dc                	lw	a5,36(s1)
    800050f2:	fbed                	bnez	a5,800050e4 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800050f4:	509c                	lw	a5,32(s1)
    800050f6:	0017871b          	addiw	a4,a5,1
    800050fa:	0007069b          	sext.w	a3,a4
    800050fe:	0027179b          	slliw	a5,a4,0x2
    80005102:	9fb9                	addw	a5,a5,a4
    80005104:	0017979b          	slliw	a5,a5,0x1
    80005108:	54d8                	lw	a4,44(s1)
    8000510a:	9fb9                	addw	a5,a5,a4
    8000510c:	00f95963          	bge	s2,a5,8000511e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80005110:	85a6                	mv	a1,s1
    80005112:	8526                	mv	a0,s1
    80005114:	ffffd097          	auipc	ra,0xffffd
    80005118:	484080e7          	jalr	1156(ra) # 80002598 <sleep>
    8000511c:	bfd1                	j	800050f0 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000511e:	00038517          	auipc	a0,0x38
    80005122:	9aa50513          	addi	a0,a0,-1622 # 8003cac8 <log>
    80005126:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80005128:	ffffc097          	auipc	ra,0xffffc
    8000512c:	b68080e7          	jalr	-1176(ra) # 80000c90 <release>
      break;
    }
  }
}
    80005130:	60e2                	ld	ra,24(sp)
    80005132:	6442                	ld	s0,16(sp)
    80005134:	64a2                	ld	s1,8(sp)
    80005136:	6902                	ld	s2,0(sp)
    80005138:	6105                	addi	sp,sp,32
    8000513a:	8082                	ret

000000008000513c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000513c:	7139                	addi	sp,sp,-64
    8000513e:	fc06                	sd	ra,56(sp)
    80005140:	f822                	sd	s0,48(sp)
    80005142:	f426                	sd	s1,40(sp)
    80005144:	f04a                	sd	s2,32(sp)
    80005146:	ec4e                	sd	s3,24(sp)
    80005148:	e852                	sd	s4,16(sp)
    8000514a:	e456                	sd	s5,8(sp)
    8000514c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000514e:	00038497          	auipc	s1,0x38
    80005152:	97a48493          	addi	s1,s1,-1670 # 8003cac8 <log>
    80005156:	8526                	mv	a0,s1
    80005158:	ffffc097          	auipc	ra,0xffffc
    8000515c:	a6e080e7          	jalr	-1426(ra) # 80000bc6 <acquire>
  log.outstanding -= 1;
    80005160:	509c                	lw	a5,32(s1)
    80005162:	37fd                	addiw	a5,a5,-1
    80005164:	0007891b          	sext.w	s2,a5
    80005168:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000516a:	50dc                	lw	a5,36(s1)
    8000516c:	e7b9                	bnez	a5,800051ba <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000516e:	04091e63          	bnez	s2,800051ca <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80005172:	00038497          	auipc	s1,0x38
    80005176:	95648493          	addi	s1,s1,-1706 # 8003cac8 <log>
    8000517a:	4785                	li	a5,1
    8000517c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000517e:	8526                	mv	a0,s1
    80005180:	ffffc097          	auipc	ra,0xffffc
    80005184:	b10080e7          	jalr	-1264(ra) # 80000c90 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80005188:	54dc                	lw	a5,44(s1)
    8000518a:	06f04763          	bgtz	a5,800051f8 <end_op+0xbc>
    acquire(&log.lock);
    8000518e:	00038497          	auipc	s1,0x38
    80005192:	93a48493          	addi	s1,s1,-1734 # 8003cac8 <log>
    80005196:	8526                	mv	a0,s1
    80005198:	ffffc097          	auipc	ra,0xffffc
    8000519c:	a2e080e7          	jalr	-1490(ra) # 80000bc6 <acquire>
    log.committing = 0;
    800051a0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800051a4:	8526                	mv	a0,s1
    800051a6:	ffffd097          	auipc	ra,0xffffd
    800051aa:	57c080e7          	jalr	1404(ra) # 80002722 <wakeup>
    release(&log.lock);
    800051ae:	8526                	mv	a0,s1
    800051b0:	ffffc097          	auipc	ra,0xffffc
    800051b4:	ae0080e7          	jalr	-1312(ra) # 80000c90 <release>
}
    800051b8:	a03d                	j	800051e6 <end_op+0xaa>
    panic("log.committing");
    800051ba:	00003517          	auipc	a0,0x3
    800051be:	70650513          	addi	a0,a0,1798 # 800088c0 <syscalls+0x218>
    800051c2:	ffffb097          	auipc	ra,0xffffb
    800051c6:	36c080e7          	jalr	876(ra) # 8000052e <panic>
    wakeup(&log);
    800051ca:	00038497          	auipc	s1,0x38
    800051ce:	8fe48493          	addi	s1,s1,-1794 # 8003cac8 <log>
    800051d2:	8526                	mv	a0,s1
    800051d4:	ffffd097          	auipc	ra,0xffffd
    800051d8:	54e080e7          	jalr	1358(ra) # 80002722 <wakeup>
  release(&log.lock);
    800051dc:	8526                	mv	a0,s1
    800051de:	ffffc097          	auipc	ra,0xffffc
    800051e2:	ab2080e7          	jalr	-1358(ra) # 80000c90 <release>
}
    800051e6:	70e2                	ld	ra,56(sp)
    800051e8:	7442                	ld	s0,48(sp)
    800051ea:	74a2                	ld	s1,40(sp)
    800051ec:	7902                	ld	s2,32(sp)
    800051ee:	69e2                	ld	s3,24(sp)
    800051f0:	6a42                	ld	s4,16(sp)
    800051f2:	6aa2                	ld	s5,8(sp)
    800051f4:	6121                	addi	sp,sp,64
    800051f6:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800051f8:	00038a97          	auipc	s5,0x38
    800051fc:	900a8a93          	addi	s5,s5,-1792 # 8003caf8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80005200:	00038a17          	auipc	s4,0x38
    80005204:	8c8a0a13          	addi	s4,s4,-1848 # 8003cac8 <log>
    80005208:	018a2583          	lw	a1,24(s4)
    8000520c:	012585bb          	addw	a1,a1,s2
    80005210:	2585                	addiw	a1,a1,1
    80005212:	028a2503          	lw	a0,40(s4)
    80005216:	fffff097          	auipc	ra,0xfffff
    8000521a:	cce080e7          	jalr	-818(ra) # 80003ee4 <bread>
    8000521e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80005220:	000aa583          	lw	a1,0(s5)
    80005224:	028a2503          	lw	a0,40(s4)
    80005228:	fffff097          	auipc	ra,0xfffff
    8000522c:	cbc080e7          	jalr	-836(ra) # 80003ee4 <bread>
    80005230:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80005232:	40000613          	li	a2,1024
    80005236:	05850593          	addi	a1,a0,88
    8000523a:	05848513          	addi	a0,s1,88
    8000523e:	ffffc097          	auipc	ra,0xffffc
    80005242:	af6080e7          	jalr	-1290(ra) # 80000d34 <memmove>
    bwrite(to);  // write the log
    80005246:	8526                	mv	a0,s1
    80005248:	fffff097          	auipc	ra,0xfffff
    8000524c:	d8e080e7          	jalr	-626(ra) # 80003fd6 <bwrite>
    brelse(from);
    80005250:	854e                	mv	a0,s3
    80005252:	fffff097          	auipc	ra,0xfffff
    80005256:	dc2080e7          	jalr	-574(ra) # 80004014 <brelse>
    brelse(to);
    8000525a:	8526                	mv	a0,s1
    8000525c:	fffff097          	auipc	ra,0xfffff
    80005260:	db8080e7          	jalr	-584(ra) # 80004014 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005264:	2905                	addiw	s2,s2,1
    80005266:	0a91                	addi	s5,s5,4
    80005268:	02ca2783          	lw	a5,44(s4)
    8000526c:	f8f94ee3          	blt	s2,a5,80005208 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80005270:	00000097          	auipc	ra,0x0
    80005274:	c66080e7          	jalr	-922(ra) # 80004ed6 <write_head>
    install_trans(0); // Now install writes to home locations
    80005278:	4501                	li	a0,0
    8000527a:	00000097          	auipc	ra,0x0
    8000527e:	cd8080e7          	jalr	-808(ra) # 80004f52 <install_trans>
    log.lh.n = 0;
    80005282:	00038797          	auipc	a5,0x38
    80005286:	8607a923          	sw	zero,-1934(a5) # 8003caf4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000528a:	00000097          	auipc	ra,0x0
    8000528e:	c4c080e7          	jalr	-948(ra) # 80004ed6 <write_head>
    80005292:	bdf5                	j	8000518e <end_op+0x52>

0000000080005294 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80005294:	1101                	addi	sp,sp,-32
    80005296:	ec06                	sd	ra,24(sp)
    80005298:	e822                	sd	s0,16(sp)
    8000529a:	e426                	sd	s1,8(sp)
    8000529c:	e04a                	sd	s2,0(sp)
    8000529e:	1000                	addi	s0,sp,32
    800052a0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800052a2:	00038917          	auipc	s2,0x38
    800052a6:	82690913          	addi	s2,s2,-2010 # 8003cac8 <log>
    800052aa:	854a                	mv	a0,s2
    800052ac:	ffffc097          	auipc	ra,0xffffc
    800052b0:	91a080e7          	jalr	-1766(ra) # 80000bc6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800052b4:	02c92603          	lw	a2,44(s2)
    800052b8:	47f5                	li	a5,29
    800052ba:	06c7c563          	blt	a5,a2,80005324 <log_write+0x90>
    800052be:	00038797          	auipc	a5,0x38
    800052c2:	8267a783          	lw	a5,-2010(a5) # 8003cae4 <log+0x1c>
    800052c6:	37fd                	addiw	a5,a5,-1
    800052c8:	04f65e63          	bge	a2,a5,80005324 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800052cc:	00038797          	auipc	a5,0x38
    800052d0:	81c7a783          	lw	a5,-2020(a5) # 8003cae8 <log+0x20>
    800052d4:	06f05063          	blez	a5,80005334 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800052d8:	4781                	li	a5,0
    800052da:	06c05563          	blez	a2,80005344 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800052de:	44cc                	lw	a1,12(s1)
    800052e0:	00038717          	auipc	a4,0x38
    800052e4:	81870713          	addi	a4,a4,-2024 # 8003caf8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800052e8:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800052ea:	4314                	lw	a3,0(a4)
    800052ec:	04b68c63          	beq	a3,a1,80005344 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800052f0:	2785                	addiw	a5,a5,1
    800052f2:	0711                	addi	a4,a4,4
    800052f4:	fef61be3          	bne	a2,a5,800052ea <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800052f8:	0621                	addi	a2,a2,8
    800052fa:	060a                	slli	a2,a2,0x2
    800052fc:	00037797          	auipc	a5,0x37
    80005300:	7cc78793          	addi	a5,a5,1996 # 8003cac8 <log>
    80005304:	963e                	add	a2,a2,a5
    80005306:	44dc                	lw	a5,12(s1)
    80005308:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000530a:	8526                	mv	a0,s1
    8000530c:	fffff097          	auipc	ra,0xfffff
    80005310:	da6080e7          	jalr	-602(ra) # 800040b2 <bpin>
    log.lh.n++;
    80005314:	00037717          	auipc	a4,0x37
    80005318:	7b470713          	addi	a4,a4,1972 # 8003cac8 <log>
    8000531c:	575c                	lw	a5,44(a4)
    8000531e:	2785                	addiw	a5,a5,1
    80005320:	d75c                	sw	a5,44(a4)
    80005322:	a835                	j	8000535e <log_write+0xca>
    panic("too big a transaction");
    80005324:	00003517          	auipc	a0,0x3
    80005328:	5ac50513          	addi	a0,a0,1452 # 800088d0 <syscalls+0x228>
    8000532c:	ffffb097          	auipc	ra,0xffffb
    80005330:	202080e7          	jalr	514(ra) # 8000052e <panic>
    panic("log_write outside of trans");
    80005334:	00003517          	auipc	a0,0x3
    80005338:	5b450513          	addi	a0,a0,1460 # 800088e8 <syscalls+0x240>
    8000533c:	ffffb097          	auipc	ra,0xffffb
    80005340:	1f2080e7          	jalr	498(ra) # 8000052e <panic>
  log.lh.block[i] = b->blockno;
    80005344:	00878713          	addi	a4,a5,8
    80005348:	00271693          	slli	a3,a4,0x2
    8000534c:	00037717          	auipc	a4,0x37
    80005350:	77c70713          	addi	a4,a4,1916 # 8003cac8 <log>
    80005354:	9736                	add	a4,a4,a3
    80005356:	44d4                	lw	a3,12(s1)
    80005358:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000535a:	faf608e3          	beq	a2,a5,8000530a <log_write+0x76>
  }
  release(&log.lock);
    8000535e:	00037517          	auipc	a0,0x37
    80005362:	76a50513          	addi	a0,a0,1898 # 8003cac8 <log>
    80005366:	ffffc097          	auipc	ra,0xffffc
    8000536a:	92a080e7          	jalr	-1750(ra) # 80000c90 <release>
}
    8000536e:	60e2                	ld	ra,24(sp)
    80005370:	6442                	ld	s0,16(sp)
    80005372:	64a2                	ld	s1,8(sp)
    80005374:	6902                	ld	s2,0(sp)
    80005376:	6105                	addi	sp,sp,32
    80005378:	8082                	ret

000000008000537a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000537a:	1101                	addi	sp,sp,-32
    8000537c:	ec06                	sd	ra,24(sp)
    8000537e:	e822                	sd	s0,16(sp)
    80005380:	e426                	sd	s1,8(sp)
    80005382:	e04a                	sd	s2,0(sp)
    80005384:	1000                	addi	s0,sp,32
    80005386:	84aa                	mv	s1,a0
    80005388:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000538a:	00003597          	auipc	a1,0x3
    8000538e:	57e58593          	addi	a1,a1,1406 # 80008908 <syscalls+0x260>
    80005392:	0521                	addi	a0,a0,8
    80005394:	ffffb097          	auipc	ra,0xffffb
    80005398:	7a2080e7          	jalr	1954(ra) # 80000b36 <initlock>
  lk->name = name;
    8000539c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800053a0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800053a4:	0204a423          	sw	zero,40(s1)
}
    800053a8:	60e2                	ld	ra,24(sp)
    800053aa:	6442                	ld	s0,16(sp)
    800053ac:	64a2                	ld	s1,8(sp)
    800053ae:	6902                	ld	s2,0(sp)
    800053b0:	6105                	addi	sp,sp,32
    800053b2:	8082                	ret

00000000800053b4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800053b4:	1101                	addi	sp,sp,-32
    800053b6:	ec06                	sd	ra,24(sp)
    800053b8:	e822                	sd	s0,16(sp)
    800053ba:	e426                	sd	s1,8(sp)
    800053bc:	e04a                	sd	s2,0(sp)
    800053be:	1000                	addi	s0,sp,32
    800053c0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800053c2:	00850913          	addi	s2,a0,8
    800053c6:	854a                	mv	a0,s2
    800053c8:	ffffb097          	auipc	ra,0xffffb
    800053cc:	7fe080e7          	jalr	2046(ra) # 80000bc6 <acquire>
  while (lk->locked) {
    800053d0:	409c                	lw	a5,0(s1)
    800053d2:	cb89                	beqz	a5,800053e4 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800053d4:	85ca                	mv	a1,s2
    800053d6:	8526                	mv	a0,s1
    800053d8:	ffffd097          	auipc	ra,0xffffd
    800053dc:	1c0080e7          	jalr	448(ra) # 80002598 <sleep>
  while (lk->locked) {
    800053e0:	409c                	lw	a5,0(s1)
    800053e2:	fbed                	bnez	a5,800053d4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800053e4:	4785                	li	a5,1
    800053e6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800053e8:	ffffc097          	auipc	ra,0xffffc
    800053ec:	720080e7          	jalr	1824(ra) # 80001b08 <myproc>
    800053f0:	515c                	lw	a5,36(a0)
    800053f2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800053f4:	854a                	mv	a0,s2
    800053f6:	ffffc097          	auipc	ra,0xffffc
    800053fa:	89a080e7          	jalr	-1894(ra) # 80000c90 <release>
}
    800053fe:	60e2                	ld	ra,24(sp)
    80005400:	6442                	ld	s0,16(sp)
    80005402:	64a2                	ld	s1,8(sp)
    80005404:	6902                	ld	s2,0(sp)
    80005406:	6105                	addi	sp,sp,32
    80005408:	8082                	ret

000000008000540a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000540a:	1101                	addi	sp,sp,-32
    8000540c:	ec06                	sd	ra,24(sp)
    8000540e:	e822                	sd	s0,16(sp)
    80005410:	e426                	sd	s1,8(sp)
    80005412:	e04a                	sd	s2,0(sp)
    80005414:	1000                	addi	s0,sp,32
    80005416:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005418:	00850913          	addi	s2,a0,8
    8000541c:	854a                	mv	a0,s2
    8000541e:	ffffb097          	auipc	ra,0xffffb
    80005422:	7a8080e7          	jalr	1960(ra) # 80000bc6 <acquire>
  lk->locked = 0;
    80005426:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000542a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000542e:	8526                	mv	a0,s1
    80005430:	ffffd097          	auipc	ra,0xffffd
    80005434:	2f2080e7          	jalr	754(ra) # 80002722 <wakeup>
  release(&lk->lk);
    80005438:	854a                	mv	a0,s2
    8000543a:	ffffc097          	auipc	ra,0xffffc
    8000543e:	856080e7          	jalr	-1962(ra) # 80000c90 <release>
}
    80005442:	60e2                	ld	ra,24(sp)
    80005444:	6442                	ld	s0,16(sp)
    80005446:	64a2                	ld	s1,8(sp)
    80005448:	6902                	ld	s2,0(sp)
    8000544a:	6105                	addi	sp,sp,32
    8000544c:	8082                	ret

000000008000544e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000544e:	7179                	addi	sp,sp,-48
    80005450:	f406                	sd	ra,40(sp)
    80005452:	f022                	sd	s0,32(sp)
    80005454:	ec26                	sd	s1,24(sp)
    80005456:	e84a                	sd	s2,16(sp)
    80005458:	e44e                	sd	s3,8(sp)
    8000545a:	1800                	addi	s0,sp,48
    8000545c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000545e:	00850913          	addi	s2,a0,8
    80005462:	854a                	mv	a0,s2
    80005464:	ffffb097          	auipc	ra,0xffffb
    80005468:	762080e7          	jalr	1890(ra) # 80000bc6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000546c:	409c                	lw	a5,0(s1)
    8000546e:	ef99                	bnez	a5,8000548c <holdingsleep+0x3e>
    80005470:	4481                	li	s1,0
  release(&lk->lk);
    80005472:	854a                	mv	a0,s2
    80005474:	ffffc097          	auipc	ra,0xffffc
    80005478:	81c080e7          	jalr	-2020(ra) # 80000c90 <release>
  return r;
}
    8000547c:	8526                	mv	a0,s1
    8000547e:	70a2                	ld	ra,40(sp)
    80005480:	7402                	ld	s0,32(sp)
    80005482:	64e2                	ld	s1,24(sp)
    80005484:	6942                	ld	s2,16(sp)
    80005486:	69a2                	ld	s3,8(sp)
    80005488:	6145                	addi	sp,sp,48
    8000548a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000548c:	0284a983          	lw	s3,40(s1)
    80005490:	ffffc097          	auipc	ra,0xffffc
    80005494:	678080e7          	jalr	1656(ra) # 80001b08 <myproc>
    80005498:	5144                	lw	s1,36(a0)
    8000549a:	413484b3          	sub	s1,s1,s3
    8000549e:	0014b493          	seqz	s1,s1
    800054a2:	bfc1                	j	80005472 <holdingsleep+0x24>

00000000800054a4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800054a4:	1141                	addi	sp,sp,-16
    800054a6:	e406                	sd	ra,8(sp)
    800054a8:	e022                	sd	s0,0(sp)
    800054aa:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800054ac:	00003597          	auipc	a1,0x3
    800054b0:	46c58593          	addi	a1,a1,1132 # 80008918 <syscalls+0x270>
    800054b4:	00037517          	auipc	a0,0x37
    800054b8:	75c50513          	addi	a0,a0,1884 # 8003cc10 <ftable>
    800054bc:	ffffb097          	auipc	ra,0xffffb
    800054c0:	67a080e7          	jalr	1658(ra) # 80000b36 <initlock>
}
    800054c4:	60a2                	ld	ra,8(sp)
    800054c6:	6402                	ld	s0,0(sp)
    800054c8:	0141                	addi	sp,sp,16
    800054ca:	8082                	ret

00000000800054cc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800054cc:	1101                	addi	sp,sp,-32
    800054ce:	ec06                	sd	ra,24(sp)
    800054d0:	e822                	sd	s0,16(sp)
    800054d2:	e426                	sd	s1,8(sp)
    800054d4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800054d6:	00037517          	auipc	a0,0x37
    800054da:	73a50513          	addi	a0,a0,1850 # 8003cc10 <ftable>
    800054de:	ffffb097          	auipc	ra,0xffffb
    800054e2:	6e8080e7          	jalr	1768(ra) # 80000bc6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800054e6:	00037497          	auipc	s1,0x37
    800054ea:	74248493          	addi	s1,s1,1858 # 8003cc28 <ftable+0x18>
    800054ee:	00038717          	auipc	a4,0x38
    800054f2:	6da70713          	addi	a4,a4,1754 # 8003dbc8 <ftable+0xfb8>
    if(f->ref == 0){
    800054f6:	40dc                	lw	a5,4(s1)
    800054f8:	cf99                	beqz	a5,80005516 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800054fa:	02848493          	addi	s1,s1,40
    800054fe:	fee49ce3          	bne	s1,a4,800054f6 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005502:	00037517          	auipc	a0,0x37
    80005506:	70e50513          	addi	a0,a0,1806 # 8003cc10 <ftable>
    8000550a:	ffffb097          	auipc	ra,0xffffb
    8000550e:	786080e7          	jalr	1926(ra) # 80000c90 <release>
  return 0;
    80005512:	4481                	li	s1,0
    80005514:	a819                	j	8000552a <filealloc+0x5e>
      f->ref = 1;
    80005516:	4785                	li	a5,1
    80005518:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000551a:	00037517          	auipc	a0,0x37
    8000551e:	6f650513          	addi	a0,a0,1782 # 8003cc10 <ftable>
    80005522:	ffffb097          	auipc	ra,0xffffb
    80005526:	76e080e7          	jalr	1902(ra) # 80000c90 <release>
}
    8000552a:	8526                	mv	a0,s1
    8000552c:	60e2                	ld	ra,24(sp)
    8000552e:	6442                	ld	s0,16(sp)
    80005530:	64a2                	ld	s1,8(sp)
    80005532:	6105                	addi	sp,sp,32
    80005534:	8082                	ret

0000000080005536 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005536:	1101                	addi	sp,sp,-32
    80005538:	ec06                	sd	ra,24(sp)
    8000553a:	e822                	sd	s0,16(sp)
    8000553c:	e426                	sd	s1,8(sp)
    8000553e:	1000                	addi	s0,sp,32
    80005540:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005542:	00037517          	auipc	a0,0x37
    80005546:	6ce50513          	addi	a0,a0,1742 # 8003cc10 <ftable>
    8000554a:	ffffb097          	auipc	ra,0xffffb
    8000554e:	67c080e7          	jalr	1660(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    80005552:	40dc                	lw	a5,4(s1)
    80005554:	02f05263          	blez	a5,80005578 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80005558:	2785                	addiw	a5,a5,1
    8000555a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000555c:	00037517          	auipc	a0,0x37
    80005560:	6b450513          	addi	a0,a0,1716 # 8003cc10 <ftable>
    80005564:	ffffb097          	auipc	ra,0xffffb
    80005568:	72c080e7          	jalr	1836(ra) # 80000c90 <release>
  return f;
}
    8000556c:	8526                	mv	a0,s1
    8000556e:	60e2                	ld	ra,24(sp)
    80005570:	6442                	ld	s0,16(sp)
    80005572:	64a2                	ld	s1,8(sp)
    80005574:	6105                	addi	sp,sp,32
    80005576:	8082                	ret
    panic("filedup");
    80005578:	00003517          	auipc	a0,0x3
    8000557c:	3a850513          	addi	a0,a0,936 # 80008920 <syscalls+0x278>
    80005580:	ffffb097          	auipc	ra,0xffffb
    80005584:	fae080e7          	jalr	-82(ra) # 8000052e <panic>

0000000080005588 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80005588:	7139                	addi	sp,sp,-64
    8000558a:	fc06                	sd	ra,56(sp)
    8000558c:	f822                	sd	s0,48(sp)
    8000558e:	f426                	sd	s1,40(sp)
    80005590:	f04a                	sd	s2,32(sp)
    80005592:	ec4e                	sd	s3,24(sp)
    80005594:	e852                	sd	s4,16(sp)
    80005596:	e456                	sd	s5,8(sp)
    80005598:	0080                	addi	s0,sp,64
    8000559a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000559c:	00037517          	auipc	a0,0x37
    800055a0:	67450513          	addi	a0,a0,1652 # 8003cc10 <ftable>
    800055a4:	ffffb097          	auipc	ra,0xffffb
    800055a8:	622080e7          	jalr	1570(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    800055ac:	40dc                	lw	a5,4(s1)
    800055ae:	06f05163          	blez	a5,80005610 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800055b2:	37fd                	addiw	a5,a5,-1
    800055b4:	0007871b          	sext.w	a4,a5
    800055b8:	c0dc                	sw	a5,4(s1)
    800055ba:	06e04363          	bgtz	a4,80005620 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800055be:	0004a903          	lw	s2,0(s1)
    800055c2:	0094ca83          	lbu	s5,9(s1)
    800055c6:	0104ba03          	ld	s4,16(s1)
    800055ca:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800055ce:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800055d2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800055d6:	00037517          	auipc	a0,0x37
    800055da:	63a50513          	addi	a0,a0,1594 # 8003cc10 <ftable>
    800055de:	ffffb097          	auipc	ra,0xffffb
    800055e2:	6b2080e7          	jalr	1714(ra) # 80000c90 <release>

  if(ff.type == FD_PIPE){
    800055e6:	4785                	li	a5,1
    800055e8:	04f90d63          	beq	s2,a5,80005642 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800055ec:	3979                	addiw	s2,s2,-2
    800055ee:	4785                	li	a5,1
    800055f0:	0527e063          	bltu	a5,s2,80005630 <fileclose+0xa8>
    begin_op();
    800055f4:	00000097          	auipc	ra,0x0
    800055f8:	ac8080e7          	jalr	-1336(ra) # 800050bc <begin_op>
    iput(ff.ip);
    800055fc:	854e                	mv	a0,s3
    800055fe:	fffff097          	auipc	ra,0xfffff
    80005602:	2a4080e7          	jalr	676(ra) # 800048a2 <iput>
    end_op();
    80005606:	00000097          	auipc	ra,0x0
    8000560a:	b36080e7          	jalr	-1226(ra) # 8000513c <end_op>
    8000560e:	a00d                	j	80005630 <fileclose+0xa8>
    panic("fileclose");
    80005610:	00003517          	auipc	a0,0x3
    80005614:	31850513          	addi	a0,a0,792 # 80008928 <syscalls+0x280>
    80005618:	ffffb097          	auipc	ra,0xffffb
    8000561c:	f16080e7          	jalr	-234(ra) # 8000052e <panic>
    release(&ftable.lock);
    80005620:	00037517          	auipc	a0,0x37
    80005624:	5f050513          	addi	a0,a0,1520 # 8003cc10 <ftable>
    80005628:	ffffb097          	auipc	ra,0xffffb
    8000562c:	668080e7          	jalr	1640(ra) # 80000c90 <release>
  }
}
    80005630:	70e2                	ld	ra,56(sp)
    80005632:	7442                	ld	s0,48(sp)
    80005634:	74a2                	ld	s1,40(sp)
    80005636:	7902                	ld	s2,32(sp)
    80005638:	69e2                	ld	s3,24(sp)
    8000563a:	6a42                	ld	s4,16(sp)
    8000563c:	6aa2                	ld	s5,8(sp)
    8000563e:	6121                	addi	sp,sp,64
    80005640:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005642:	85d6                	mv	a1,s5
    80005644:	8552                	mv	a0,s4
    80005646:	00000097          	auipc	ra,0x0
    8000564a:	34c080e7          	jalr	844(ra) # 80005992 <pipeclose>
    8000564e:	b7cd                	j	80005630 <fileclose+0xa8>

0000000080005650 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005650:	715d                	addi	sp,sp,-80
    80005652:	e486                	sd	ra,72(sp)
    80005654:	e0a2                	sd	s0,64(sp)
    80005656:	fc26                	sd	s1,56(sp)
    80005658:	f84a                	sd	s2,48(sp)
    8000565a:	f44e                	sd	s3,40(sp)
    8000565c:	0880                	addi	s0,sp,80
    8000565e:	84aa                	mv	s1,a0
    80005660:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005662:	ffffc097          	auipc	ra,0xffffc
    80005666:	4a6080e7          	jalr	1190(ra) # 80001b08 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000566a:	409c                	lw	a5,0(s1)
    8000566c:	37f9                	addiw	a5,a5,-2
    8000566e:	4705                	li	a4,1
    80005670:	04f76763          	bltu	a4,a5,800056be <filestat+0x6e>
    80005674:	892a                	mv	s2,a0
    ilock(f->ip);
    80005676:	6c88                	ld	a0,24(s1)
    80005678:	fffff097          	auipc	ra,0xfffff
    8000567c:	070080e7          	jalr	112(ra) # 800046e8 <ilock>
    stati(f->ip, &st);
    80005680:	fb840593          	addi	a1,s0,-72
    80005684:	6c88                	ld	a0,24(s1)
    80005686:	fffff097          	auipc	ra,0xfffff
    8000568a:	2ec080e7          	jalr	748(ra) # 80004972 <stati>
    iunlock(f->ip);
    8000568e:	6c88                	ld	a0,24(s1)
    80005690:	fffff097          	auipc	ra,0xfffff
    80005694:	11a080e7          	jalr	282(ra) # 800047aa <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005698:	46e1                	li	a3,24
    8000569a:	fb840613          	addi	a2,s0,-72
    8000569e:	85ce                	mv	a1,s3
    800056a0:	04093503          	ld	a0,64(s2)
    800056a4:	ffffc097          	auipc	ra,0xffffc
    800056a8:	04c080e7          	jalr	76(ra) # 800016f0 <copyout>
    800056ac:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800056b0:	60a6                	ld	ra,72(sp)
    800056b2:	6406                	ld	s0,64(sp)
    800056b4:	74e2                	ld	s1,56(sp)
    800056b6:	7942                	ld	s2,48(sp)
    800056b8:	79a2                	ld	s3,40(sp)
    800056ba:	6161                	addi	sp,sp,80
    800056bc:	8082                	ret
  return -1;
    800056be:	557d                	li	a0,-1
    800056c0:	bfc5                	j	800056b0 <filestat+0x60>

00000000800056c2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800056c2:	7179                	addi	sp,sp,-48
    800056c4:	f406                	sd	ra,40(sp)
    800056c6:	f022                	sd	s0,32(sp)
    800056c8:	ec26                	sd	s1,24(sp)
    800056ca:	e84a                	sd	s2,16(sp)
    800056cc:	e44e                	sd	s3,8(sp)
    800056ce:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800056d0:	00854783          	lbu	a5,8(a0)
    800056d4:	c3d5                	beqz	a5,80005778 <fileread+0xb6>
    800056d6:	84aa                	mv	s1,a0
    800056d8:	89ae                	mv	s3,a1
    800056da:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800056dc:	411c                	lw	a5,0(a0)
    800056de:	4705                	li	a4,1
    800056e0:	04e78963          	beq	a5,a4,80005732 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800056e4:	470d                	li	a4,3
    800056e6:	04e78d63          	beq	a5,a4,80005740 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800056ea:	4709                	li	a4,2
    800056ec:	06e79e63          	bne	a5,a4,80005768 <fileread+0xa6>
    ilock(f->ip);
    800056f0:	6d08                	ld	a0,24(a0)
    800056f2:	fffff097          	auipc	ra,0xfffff
    800056f6:	ff6080e7          	jalr	-10(ra) # 800046e8 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800056fa:	874a                	mv	a4,s2
    800056fc:	5094                	lw	a3,32(s1)
    800056fe:	864e                	mv	a2,s3
    80005700:	4585                	li	a1,1
    80005702:	6c88                	ld	a0,24(s1)
    80005704:	fffff097          	auipc	ra,0xfffff
    80005708:	298080e7          	jalr	664(ra) # 8000499c <readi>
    8000570c:	892a                	mv	s2,a0
    8000570e:	00a05563          	blez	a0,80005718 <fileread+0x56>
      f->off += r;
    80005712:	509c                	lw	a5,32(s1)
    80005714:	9fa9                	addw	a5,a5,a0
    80005716:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005718:	6c88                	ld	a0,24(s1)
    8000571a:	fffff097          	auipc	ra,0xfffff
    8000571e:	090080e7          	jalr	144(ra) # 800047aa <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005722:	854a                	mv	a0,s2
    80005724:	70a2                	ld	ra,40(sp)
    80005726:	7402                	ld	s0,32(sp)
    80005728:	64e2                	ld	s1,24(sp)
    8000572a:	6942                	ld	s2,16(sp)
    8000572c:	69a2                	ld	s3,8(sp)
    8000572e:	6145                	addi	sp,sp,48
    80005730:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005732:	6908                	ld	a0,16(a0)
    80005734:	00000097          	auipc	ra,0x0
    80005738:	3c8080e7          	jalr	968(ra) # 80005afc <piperead>
    8000573c:	892a                	mv	s2,a0
    8000573e:	b7d5                	j	80005722 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005740:	02451783          	lh	a5,36(a0)
    80005744:	03079693          	slli	a3,a5,0x30
    80005748:	92c1                	srli	a3,a3,0x30
    8000574a:	4725                	li	a4,9
    8000574c:	02d76863          	bltu	a4,a3,8000577c <fileread+0xba>
    80005750:	0792                	slli	a5,a5,0x4
    80005752:	00037717          	auipc	a4,0x37
    80005756:	41e70713          	addi	a4,a4,1054 # 8003cb70 <devsw>
    8000575a:	97ba                	add	a5,a5,a4
    8000575c:	639c                	ld	a5,0(a5)
    8000575e:	c38d                	beqz	a5,80005780 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005760:	4505                	li	a0,1
    80005762:	9782                	jalr	a5
    80005764:	892a                	mv	s2,a0
    80005766:	bf75                	j	80005722 <fileread+0x60>
    panic("fileread");
    80005768:	00003517          	auipc	a0,0x3
    8000576c:	1d050513          	addi	a0,a0,464 # 80008938 <syscalls+0x290>
    80005770:	ffffb097          	auipc	ra,0xffffb
    80005774:	dbe080e7          	jalr	-578(ra) # 8000052e <panic>
    return -1;
    80005778:	597d                	li	s2,-1
    8000577a:	b765                	j	80005722 <fileread+0x60>
      return -1;
    8000577c:	597d                	li	s2,-1
    8000577e:	b755                	j	80005722 <fileread+0x60>
    80005780:	597d                	li	s2,-1
    80005782:	b745                	j	80005722 <fileread+0x60>

0000000080005784 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80005784:	715d                	addi	sp,sp,-80
    80005786:	e486                	sd	ra,72(sp)
    80005788:	e0a2                	sd	s0,64(sp)
    8000578a:	fc26                	sd	s1,56(sp)
    8000578c:	f84a                	sd	s2,48(sp)
    8000578e:	f44e                	sd	s3,40(sp)
    80005790:	f052                	sd	s4,32(sp)
    80005792:	ec56                	sd	s5,24(sp)
    80005794:	e85a                	sd	s6,16(sp)
    80005796:	e45e                	sd	s7,8(sp)
    80005798:	e062                	sd	s8,0(sp)
    8000579a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000579c:	00954783          	lbu	a5,9(a0)
    800057a0:	10078663          	beqz	a5,800058ac <filewrite+0x128>
    800057a4:	892a                	mv	s2,a0
    800057a6:	8aae                	mv	s5,a1
    800057a8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800057aa:	411c                	lw	a5,0(a0)
    800057ac:	4705                	li	a4,1
    800057ae:	02e78263          	beq	a5,a4,800057d2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800057b2:	470d                	li	a4,3
    800057b4:	02e78663          	beq	a5,a4,800057e0 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800057b8:	4709                	li	a4,2
    800057ba:	0ee79163          	bne	a5,a4,8000589c <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800057be:	0ac05d63          	blez	a2,80005878 <filewrite+0xf4>
    int i = 0;
    800057c2:	4981                	li	s3,0
    800057c4:	6b05                	lui	s6,0x1
    800057c6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800057ca:	6b85                	lui	s7,0x1
    800057cc:	c00b8b9b          	addiw	s7,s7,-1024
    800057d0:	a861                	j	80005868 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800057d2:	6908                	ld	a0,16(a0)
    800057d4:	00000097          	auipc	ra,0x0
    800057d8:	22e080e7          	jalr	558(ra) # 80005a02 <pipewrite>
    800057dc:	8a2a                	mv	s4,a0
    800057de:	a045                	j	8000587e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800057e0:	02451783          	lh	a5,36(a0)
    800057e4:	03079693          	slli	a3,a5,0x30
    800057e8:	92c1                	srli	a3,a3,0x30
    800057ea:	4725                	li	a4,9
    800057ec:	0cd76263          	bltu	a4,a3,800058b0 <filewrite+0x12c>
    800057f0:	0792                	slli	a5,a5,0x4
    800057f2:	00037717          	auipc	a4,0x37
    800057f6:	37e70713          	addi	a4,a4,894 # 8003cb70 <devsw>
    800057fa:	97ba                	add	a5,a5,a4
    800057fc:	679c                	ld	a5,8(a5)
    800057fe:	cbdd                	beqz	a5,800058b4 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005800:	4505                	li	a0,1
    80005802:	9782                	jalr	a5
    80005804:	8a2a                	mv	s4,a0
    80005806:	a8a5                	j	8000587e <filewrite+0xfa>
    80005808:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000580c:	00000097          	auipc	ra,0x0
    80005810:	8b0080e7          	jalr	-1872(ra) # 800050bc <begin_op>
      ilock(f->ip);
    80005814:	01893503          	ld	a0,24(s2)
    80005818:	fffff097          	auipc	ra,0xfffff
    8000581c:	ed0080e7          	jalr	-304(ra) # 800046e8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005820:	8762                	mv	a4,s8
    80005822:	02092683          	lw	a3,32(s2)
    80005826:	01598633          	add	a2,s3,s5
    8000582a:	4585                	li	a1,1
    8000582c:	01893503          	ld	a0,24(s2)
    80005830:	fffff097          	auipc	ra,0xfffff
    80005834:	264080e7          	jalr	612(ra) # 80004a94 <writei>
    80005838:	84aa                	mv	s1,a0
    8000583a:	00a05763          	blez	a0,80005848 <filewrite+0xc4>
        f->off += r;
    8000583e:	02092783          	lw	a5,32(s2)
    80005842:	9fa9                	addw	a5,a5,a0
    80005844:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005848:	01893503          	ld	a0,24(s2)
    8000584c:	fffff097          	auipc	ra,0xfffff
    80005850:	f5e080e7          	jalr	-162(ra) # 800047aa <iunlock>
      end_op();
    80005854:	00000097          	auipc	ra,0x0
    80005858:	8e8080e7          	jalr	-1816(ra) # 8000513c <end_op>

      if(r != n1){
    8000585c:	009c1f63          	bne	s8,s1,8000587a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005860:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005864:	0149db63          	bge	s3,s4,8000587a <filewrite+0xf6>
      int n1 = n - i;
    80005868:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000586c:	84be                	mv	s1,a5
    8000586e:	2781                	sext.w	a5,a5
    80005870:	f8fb5ce3          	bge	s6,a5,80005808 <filewrite+0x84>
    80005874:	84de                	mv	s1,s7
    80005876:	bf49                	j	80005808 <filewrite+0x84>
    int i = 0;
    80005878:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000587a:	013a1f63          	bne	s4,s3,80005898 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000587e:	8552                	mv	a0,s4
    80005880:	60a6                	ld	ra,72(sp)
    80005882:	6406                	ld	s0,64(sp)
    80005884:	74e2                	ld	s1,56(sp)
    80005886:	7942                	ld	s2,48(sp)
    80005888:	79a2                	ld	s3,40(sp)
    8000588a:	7a02                	ld	s4,32(sp)
    8000588c:	6ae2                	ld	s5,24(sp)
    8000588e:	6b42                	ld	s6,16(sp)
    80005890:	6ba2                	ld	s7,8(sp)
    80005892:	6c02                	ld	s8,0(sp)
    80005894:	6161                	addi	sp,sp,80
    80005896:	8082                	ret
    ret = (i == n ? n : -1);
    80005898:	5a7d                	li	s4,-1
    8000589a:	b7d5                	j	8000587e <filewrite+0xfa>
    panic("filewrite");
    8000589c:	00003517          	auipc	a0,0x3
    800058a0:	0ac50513          	addi	a0,a0,172 # 80008948 <syscalls+0x2a0>
    800058a4:	ffffb097          	auipc	ra,0xffffb
    800058a8:	c8a080e7          	jalr	-886(ra) # 8000052e <panic>
    return -1;
    800058ac:	5a7d                	li	s4,-1
    800058ae:	bfc1                	j	8000587e <filewrite+0xfa>
      return -1;
    800058b0:	5a7d                	li	s4,-1
    800058b2:	b7f1                	j	8000587e <filewrite+0xfa>
    800058b4:	5a7d                	li	s4,-1
    800058b6:	b7e1                	j	8000587e <filewrite+0xfa>

00000000800058b8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800058b8:	7179                	addi	sp,sp,-48
    800058ba:	f406                	sd	ra,40(sp)
    800058bc:	f022                	sd	s0,32(sp)
    800058be:	ec26                	sd	s1,24(sp)
    800058c0:	e84a                	sd	s2,16(sp)
    800058c2:	e44e                	sd	s3,8(sp)
    800058c4:	e052                	sd	s4,0(sp)
    800058c6:	1800                	addi	s0,sp,48
    800058c8:	84aa                	mv	s1,a0
    800058ca:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800058cc:	0005b023          	sd	zero,0(a1)
    800058d0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800058d4:	00000097          	auipc	ra,0x0
    800058d8:	bf8080e7          	jalr	-1032(ra) # 800054cc <filealloc>
    800058dc:	e088                	sd	a0,0(s1)
    800058de:	c551                	beqz	a0,8000596a <pipealloc+0xb2>
    800058e0:	00000097          	auipc	ra,0x0
    800058e4:	bec080e7          	jalr	-1044(ra) # 800054cc <filealloc>
    800058e8:	00aa3023          	sd	a0,0(s4)
    800058ec:	c92d                	beqz	a0,8000595e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800058ee:	ffffb097          	auipc	ra,0xffffb
    800058f2:	1e8080e7          	jalr	488(ra) # 80000ad6 <kalloc>
    800058f6:	892a                	mv	s2,a0
    800058f8:	c125                	beqz	a0,80005958 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800058fa:	4985                	li	s3,1
    800058fc:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005900:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005904:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005908:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000590c:	00003597          	auipc	a1,0x3
    80005910:	04c58593          	addi	a1,a1,76 # 80008958 <syscalls+0x2b0>
    80005914:	ffffb097          	auipc	ra,0xffffb
    80005918:	222080e7          	jalr	546(ra) # 80000b36 <initlock>
  (*f0)->type = FD_PIPE;
    8000591c:	609c                	ld	a5,0(s1)
    8000591e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005922:	609c                	ld	a5,0(s1)
    80005924:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005928:	609c                	ld	a5,0(s1)
    8000592a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000592e:	609c                	ld	a5,0(s1)
    80005930:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005934:	000a3783          	ld	a5,0(s4)
    80005938:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000593c:	000a3783          	ld	a5,0(s4)
    80005940:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005944:	000a3783          	ld	a5,0(s4)
    80005948:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000594c:	000a3783          	ld	a5,0(s4)
    80005950:	0127b823          	sd	s2,16(a5)
  return 0;
    80005954:	4501                	li	a0,0
    80005956:	a025                	j	8000597e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005958:	6088                	ld	a0,0(s1)
    8000595a:	e501                	bnez	a0,80005962 <pipealloc+0xaa>
    8000595c:	a039                	j	8000596a <pipealloc+0xb2>
    8000595e:	6088                	ld	a0,0(s1)
    80005960:	c51d                	beqz	a0,8000598e <pipealloc+0xd6>
    fileclose(*f0);
    80005962:	00000097          	auipc	ra,0x0
    80005966:	c26080e7          	jalr	-986(ra) # 80005588 <fileclose>
  if(*f1)
    8000596a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000596e:	557d                	li	a0,-1
  if(*f1)
    80005970:	c799                	beqz	a5,8000597e <pipealloc+0xc6>
    fileclose(*f1);
    80005972:	853e                	mv	a0,a5
    80005974:	00000097          	auipc	ra,0x0
    80005978:	c14080e7          	jalr	-1004(ra) # 80005588 <fileclose>
  return -1;
    8000597c:	557d                	li	a0,-1
}
    8000597e:	70a2                	ld	ra,40(sp)
    80005980:	7402                	ld	s0,32(sp)
    80005982:	64e2                	ld	s1,24(sp)
    80005984:	6942                	ld	s2,16(sp)
    80005986:	69a2                	ld	s3,8(sp)
    80005988:	6a02                	ld	s4,0(sp)
    8000598a:	6145                	addi	sp,sp,48
    8000598c:	8082                	ret
  return -1;
    8000598e:	557d                	li	a0,-1
    80005990:	b7fd                	j	8000597e <pipealloc+0xc6>

0000000080005992 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005992:	1101                	addi	sp,sp,-32
    80005994:	ec06                	sd	ra,24(sp)
    80005996:	e822                	sd	s0,16(sp)
    80005998:	e426                	sd	s1,8(sp)
    8000599a:	e04a                	sd	s2,0(sp)
    8000599c:	1000                	addi	s0,sp,32
    8000599e:	84aa                	mv	s1,a0
    800059a0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800059a2:	ffffb097          	auipc	ra,0xffffb
    800059a6:	224080e7          	jalr	548(ra) # 80000bc6 <acquire>
  if(writable){
    800059aa:	02090d63          	beqz	s2,800059e4 <pipeclose+0x52>
    pi->writeopen = 0;
    800059ae:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800059b2:	21848513          	addi	a0,s1,536
    800059b6:	ffffd097          	auipc	ra,0xffffd
    800059ba:	d6c080e7          	jalr	-660(ra) # 80002722 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800059be:	2204b783          	ld	a5,544(s1)
    800059c2:	eb95                	bnez	a5,800059f6 <pipeclose+0x64>
    release(&pi->lock);
    800059c4:	8526                	mv	a0,s1
    800059c6:	ffffb097          	auipc	ra,0xffffb
    800059ca:	2ca080e7          	jalr	714(ra) # 80000c90 <release>
    kfree((char*)pi);
    800059ce:	8526                	mv	a0,s1
    800059d0:	ffffb097          	auipc	ra,0xffffb
    800059d4:	00a080e7          	jalr	10(ra) # 800009da <kfree>
  } else
    release(&pi->lock);
}
    800059d8:	60e2                	ld	ra,24(sp)
    800059da:	6442                	ld	s0,16(sp)
    800059dc:	64a2                	ld	s1,8(sp)
    800059de:	6902                	ld	s2,0(sp)
    800059e0:	6105                	addi	sp,sp,32
    800059e2:	8082                	ret
    pi->readopen = 0;
    800059e4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800059e8:	21c48513          	addi	a0,s1,540
    800059ec:	ffffd097          	auipc	ra,0xffffd
    800059f0:	d36080e7          	jalr	-714(ra) # 80002722 <wakeup>
    800059f4:	b7e9                	j	800059be <pipeclose+0x2c>
    release(&pi->lock);
    800059f6:	8526                	mv	a0,s1
    800059f8:	ffffb097          	auipc	ra,0xffffb
    800059fc:	298080e7          	jalr	664(ra) # 80000c90 <release>
}
    80005a00:	bfe1                	j	800059d8 <pipeclose+0x46>

0000000080005a02 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005a02:	7159                	addi	sp,sp,-112
    80005a04:	f486                	sd	ra,104(sp)
    80005a06:	f0a2                	sd	s0,96(sp)
    80005a08:	eca6                	sd	s1,88(sp)
    80005a0a:	e8ca                	sd	s2,80(sp)
    80005a0c:	e4ce                	sd	s3,72(sp)
    80005a0e:	e0d2                	sd	s4,64(sp)
    80005a10:	fc56                	sd	s5,56(sp)
    80005a12:	f85a                	sd	s6,48(sp)
    80005a14:	f45e                	sd	s7,40(sp)
    80005a16:	f062                	sd	s8,32(sp)
    80005a18:	ec66                	sd	s9,24(sp)
    80005a1a:	1880                	addi	s0,sp,112
    80005a1c:	84aa                	mv	s1,a0
    80005a1e:	8b2e                	mv	s6,a1
    80005a20:	8ab2                	mv	s5,a2
  int i = 0;
  struct proc *pr = myproc();
    80005a22:	ffffc097          	auipc	ra,0xffffc
    80005a26:	0e6080e7          	jalr	230(ra) # 80001b08 <myproc>
    80005a2a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005a2c:	8526                	mv	a0,s1
    80005a2e:	ffffb097          	auipc	ra,0xffffb
    80005a32:	198080e7          	jalr	408(ra) # 80000bc6 <acquire>
  while(i < n){
    80005a36:	0b505663          	blez	s5,80005ae2 <pipewrite+0xe0>
  int i = 0;
    80005a3a:	4901                	li	s2,0
    if(pi->readopen == 0 || pr->killed==1){
    80005a3c:	4a05                	li	s4,1
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005a3e:	5bfd                	li	s7,-1
      wakeup(&pi->nread);
    80005a40:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005a44:	21c48c13          	addi	s8,s1,540
    80005a48:	a091                	j	80005a8c <pipewrite+0x8a>
      release(&pi->lock);
    80005a4a:	8526                	mv	a0,s1
    80005a4c:	ffffb097          	auipc	ra,0xffffb
    80005a50:	244080e7          	jalr	580(ra) # 80000c90 <release>
      return -1;
    80005a54:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005a56:	854a                	mv	a0,s2
    80005a58:	70a6                	ld	ra,104(sp)
    80005a5a:	7406                	ld	s0,96(sp)
    80005a5c:	64e6                	ld	s1,88(sp)
    80005a5e:	6946                	ld	s2,80(sp)
    80005a60:	69a6                	ld	s3,72(sp)
    80005a62:	6a06                	ld	s4,64(sp)
    80005a64:	7ae2                	ld	s5,56(sp)
    80005a66:	7b42                	ld	s6,48(sp)
    80005a68:	7ba2                	ld	s7,40(sp)
    80005a6a:	7c02                	ld	s8,32(sp)
    80005a6c:	6ce2                	ld	s9,24(sp)
    80005a6e:	6165                	addi	sp,sp,112
    80005a70:	8082                	ret
      wakeup(&pi->nread);
    80005a72:	8566                	mv	a0,s9
    80005a74:	ffffd097          	auipc	ra,0xffffd
    80005a78:	cae080e7          	jalr	-850(ra) # 80002722 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005a7c:	85a6                	mv	a1,s1
    80005a7e:	8562                	mv	a0,s8
    80005a80:	ffffd097          	auipc	ra,0xffffd
    80005a84:	b18080e7          	jalr	-1256(ra) # 80002598 <sleep>
  while(i < n){
    80005a88:	05595e63          	bge	s2,s5,80005ae4 <pipewrite+0xe2>
    if(pi->readopen == 0 || pr->killed==1){
    80005a8c:	2204a783          	lw	a5,544(s1)
    80005a90:	dfcd                	beqz	a5,80005a4a <pipewrite+0x48>
    80005a92:	01c9a783          	lw	a5,28(s3)
    80005a96:	fb478ae3          	beq	a5,s4,80005a4a <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005a9a:	2184a783          	lw	a5,536(s1)
    80005a9e:	21c4a703          	lw	a4,540(s1)
    80005aa2:	2007879b          	addiw	a5,a5,512
    80005aa6:	fcf706e3          	beq	a4,a5,80005a72 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005aaa:	86d2                	mv	a3,s4
    80005aac:	01690633          	add	a2,s2,s6
    80005ab0:	f9f40593          	addi	a1,s0,-97
    80005ab4:	0409b503          	ld	a0,64(s3)
    80005ab8:	ffffc097          	auipc	ra,0xffffc
    80005abc:	cc4080e7          	jalr	-828(ra) # 8000177c <copyin>
    80005ac0:	03750263          	beq	a0,s7,80005ae4 <pipewrite+0xe2>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005ac4:	21c4a783          	lw	a5,540(s1)
    80005ac8:	0017871b          	addiw	a4,a5,1
    80005acc:	20e4ae23          	sw	a4,540(s1)
    80005ad0:	1ff7f793          	andi	a5,a5,511
    80005ad4:	97a6                	add	a5,a5,s1
    80005ad6:	f9f44703          	lbu	a4,-97(s0)
    80005ada:	00e78c23          	sb	a4,24(a5)
      i++;
    80005ade:	2905                	addiw	s2,s2,1
    80005ae0:	b765                	j	80005a88 <pipewrite+0x86>
  int i = 0;
    80005ae2:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005ae4:	21848513          	addi	a0,s1,536
    80005ae8:	ffffd097          	auipc	ra,0xffffd
    80005aec:	c3a080e7          	jalr	-966(ra) # 80002722 <wakeup>
  release(&pi->lock);
    80005af0:	8526                	mv	a0,s1
    80005af2:	ffffb097          	auipc	ra,0xffffb
    80005af6:	19e080e7          	jalr	414(ra) # 80000c90 <release>
  return i;
    80005afa:	bfb1                	j	80005a56 <pipewrite+0x54>

0000000080005afc <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005afc:	715d                	addi	sp,sp,-80
    80005afe:	e486                	sd	ra,72(sp)
    80005b00:	e0a2                	sd	s0,64(sp)
    80005b02:	fc26                	sd	s1,56(sp)
    80005b04:	f84a                	sd	s2,48(sp)
    80005b06:	f44e                	sd	s3,40(sp)
    80005b08:	f052                	sd	s4,32(sp)
    80005b0a:	ec56                	sd	s5,24(sp)
    80005b0c:	e85a                	sd	s6,16(sp)
    80005b0e:	0880                	addi	s0,sp,80
    80005b10:	84aa                	mv	s1,a0
    80005b12:	892e                	mv	s2,a1
    80005b14:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005b16:	ffffc097          	auipc	ra,0xffffc
    80005b1a:	ff2080e7          	jalr	-14(ra) # 80001b08 <myproc>
    80005b1e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005b20:	8526                	mv	a0,s1
    80005b22:	ffffb097          	auipc	ra,0xffffb
    80005b26:	0a4080e7          	jalr	164(ra) # 80000bc6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005b2a:	2184a703          	lw	a4,536(s1)
    80005b2e:	21c4a783          	lw	a5,540(s1)
    if(pr->killed==1){
    80005b32:	4985                	li	s3,1
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005b34:	21848b13          	addi	s6,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005b38:	02f71563          	bne	a4,a5,80005b62 <piperead+0x66>
    80005b3c:	2244a783          	lw	a5,548(s1)
    80005b40:	c38d                	beqz	a5,80005b62 <piperead+0x66>
    if(pr->killed==1){
    80005b42:	01ca2783          	lw	a5,28(s4)
    80005b46:	09378963          	beq	a5,s3,80005bd8 <piperead+0xdc>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005b4a:	85a6                	mv	a1,s1
    80005b4c:	855a                	mv	a0,s6
    80005b4e:	ffffd097          	auipc	ra,0xffffd
    80005b52:	a4a080e7          	jalr	-1462(ra) # 80002598 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005b56:	2184a703          	lw	a4,536(s1)
    80005b5a:	21c4a783          	lw	a5,540(s1)
    80005b5e:	fcf70fe3          	beq	a4,a5,80005b3c <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005b62:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005b64:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005b66:	05505363          	blez	s5,80005bac <piperead+0xb0>
    if(pi->nread == pi->nwrite)
    80005b6a:	2184a783          	lw	a5,536(s1)
    80005b6e:	21c4a703          	lw	a4,540(s1)
    80005b72:	02f70d63          	beq	a4,a5,80005bac <piperead+0xb0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005b76:	0017871b          	addiw	a4,a5,1
    80005b7a:	20e4ac23          	sw	a4,536(s1)
    80005b7e:	1ff7f793          	andi	a5,a5,511
    80005b82:	97a6                	add	a5,a5,s1
    80005b84:	0187c783          	lbu	a5,24(a5)
    80005b88:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005b8c:	4685                	li	a3,1
    80005b8e:	fbf40613          	addi	a2,s0,-65
    80005b92:	85ca                	mv	a1,s2
    80005b94:	040a3503          	ld	a0,64(s4)
    80005b98:	ffffc097          	auipc	ra,0xffffc
    80005b9c:	b58080e7          	jalr	-1192(ra) # 800016f0 <copyout>
    80005ba0:	01650663          	beq	a0,s6,80005bac <piperead+0xb0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005ba4:	2985                	addiw	s3,s3,1
    80005ba6:	0905                	addi	s2,s2,1
    80005ba8:	fd3a91e3          	bne	s5,s3,80005b6a <piperead+0x6e>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005bac:	21c48513          	addi	a0,s1,540
    80005bb0:	ffffd097          	auipc	ra,0xffffd
    80005bb4:	b72080e7          	jalr	-1166(ra) # 80002722 <wakeup>
  release(&pi->lock);
    80005bb8:	8526                	mv	a0,s1
    80005bba:	ffffb097          	auipc	ra,0xffffb
    80005bbe:	0d6080e7          	jalr	214(ra) # 80000c90 <release>
  return i;
}
    80005bc2:	854e                	mv	a0,s3
    80005bc4:	60a6                	ld	ra,72(sp)
    80005bc6:	6406                	ld	s0,64(sp)
    80005bc8:	74e2                	ld	s1,56(sp)
    80005bca:	7942                	ld	s2,48(sp)
    80005bcc:	79a2                	ld	s3,40(sp)
    80005bce:	7a02                	ld	s4,32(sp)
    80005bd0:	6ae2                	ld	s5,24(sp)
    80005bd2:	6b42                	ld	s6,16(sp)
    80005bd4:	6161                	addi	sp,sp,80
    80005bd6:	8082                	ret
      release(&pi->lock);
    80005bd8:	8526                	mv	a0,s1
    80005bda:	ffffb097          	auipc	ra,0xffffb
    80005bde:	0b6080e7          	jalr	182(ra) # 80000c90 <release>
      return -1;
    80005be2:	59fd                	li	s3,-1
    80005be4:	bff9                	j	80005bc2 <piperead+0xc6>

0000000080005be6 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005be6:	7139                	addi	sp,sp,-64
    80005be8:	fc06                	sd	ra,56(sp)
    80005bea:	f822                	sd	s0,48(sp)
    80005bec:	f426                	sd	s1,40(sp)
    80005bee:	f04a                	sd	s2,32(sp)
    80005bf0:	ec4e                	sd	s3,24(sp)
    80005bf2:	e852                	sd	s4,16(sp)
    80005bf4:	e456                	sd	s5,8(sp)
    80005bf6:	e05a                	sd	s6,0(sp)
    80005bf8:	0080                	addi	s0,sp,64
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005bfa:	ffffc097          	auipc	ra,0xffffc
    80005bfe:	f0e080e7          	jalr	-242(ra) # 80001b08 <myproc>
    80005c02:	89aa                	mv	s3,a0

  struct kthread *t = mykthread();
    80005c04:	ffffc097          	auipc	ra,0xffffc
    80005c08:	f44080e7          	jalr	-188(ra) # 80001b48 <mykthread>
    80005c0c:	84aa                	mv	s1,a0
  struct kthread *nt;


  // Kill all process threads 
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];t++){ 
    80005c0e:	28898913          	addi	s2,s3,648
    if(nt!=t && nt->state!=TUNUSED){
      acquire(&nt->lock);
      nt->killed=1;
    80005c12:	4a85                	li	s5,1
      if(nt->state == TSLEEPING){
    80005c14:	4a09                	li	s4,2
        nt->state = TRUNNABLE;
    80005c16:	4b0d                	li	s6,3
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];t++){ 
    80005c18:	a801                	j	80005c28 <exec+0x42>
      }

      release(&nt->lock);  
    80005c1a:	854a                	mv	a0,s2
    80005c1c:	ffffb097          	auipc	ra,0xffffb
    80005c20:	074080e7          	jalr	116(ra) # 80000c90 <release>
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];t++){ 
    80005c24:	0b848493          	addi	s1,s1,184
    if(nt!=t && nt->state!=TUNUSED){
    80005c28:	ff248ee3          	beq	s1,s2,80005c24 <exec+0x3e>
    80005c2c:	2a09a783          	lw	a5,672(s3)
    80005c30:	dbf5                	beqz	a5,80005c24 <exec+0x3e>
      acquire(&nt->lock);
    80005c32:	854a                	mv	a0,s2
    80005c34:	ffffb097          	auipc	ra,0xffffb
    80005c38:	f92080e7          	jalr	-110(ra) # 80000bc6 <acquire>
      nt->killed=1;
    80005c3c:	2b59a823          	sw	s5,688(s3)
      if(nt->state == TSLEEPING){
    80005c40:	2a09a783          	lw	a5,672(s3)
    80005c44:	fd479be3          	bne	a5,s4,80005c1a <exec+0x34>
        nt->state = TRUNNABLE;
    80005c48:	2b69a023          	sw	s6,672(s3)
    80005c4c:	b7f9                	j	80005c1a <exec+0x34>

0000000080005c4e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005c4e:	7179                	addi	sp,sp,-48
    80005c50:	f406                	sd	ra,40(sp)
    80005c52:	f022                	sd	s0,32(sp)
    80005c54:	ec26                	sd	s1,24(sp)
    80005c56:	e84a                	sd	s2,16(sp)
    80005c58:	1800                	addi	s0,sp,48
    80005c5a:	892e                	mv	s2,a1
    80005c5c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005c5e:	fdc40593          	addi	a1,s0,-36
    80005c62:	ffffe097          	auipc	ra,0xffffe
    80005c66:	d40080e7          	jalr	-704(ra) # 800039a2 <argint>
    80005c6a:	04054063          	bltz	a0,80005caa <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005c6e:	fdc42703          	lw	a4,-36(s0)
    80005c72:	47bd                	li	a5,15
    80005c74:	02e7ed63          	bltu	a5,a4,80005cae <argfd+0x60>
    80005c78:	ffffc097          	auipc	ra,0xffffc
    80005c7c:	e90080e7          	jalr	-368(ra) # 80001b08 <myproc>
    80005c80:	fdc42703          	lw	a4,-36(s0)
    80005c84:	00a70793          	addi	a5,a4,10
    80005c88:	078e                	slli	a5,a5,0x3
    80005c8a:	953e                	add	a0,a0,a5
    80005c8c:	611c                	ld	a5,0(a0)
    80005c8e:	c395                	beqz	a5,80005cb2 <argfd+0x64>
    return -1;
  if(pfd)
    80005c90:	00090463          	beqz	s2,80005c98 <argfd+0x4a>
    *pfd = fd;
    80005c94:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005c98:	4501                	li	a0,0
  if(pf)
    80005c9a:	c091                	beqz	s1,80005c9e <argfd+0x50>
    *pf = f;
    80005c9c:	e09c                	sd	a5,0(s1)
}
    80005c9e:	70a2                	ld	ra,40(sp)
    80005ca0:	7402                	ld	s0,32(sp)
    80005ca2:	64e2                	ld	s1,24(sp)
    80005ca4:	6942                	ld	s2,16(sp)
    80005ca6:	6145                	addi	sp,sp,48
    80005ca8:	8082                	ret
    return -1;
    80005caa:	557d                	li	a0,-1
    80005cac:	bfcd                	j	80005c9e <argfd+0x50>
    return -1;
    80005cae:	557d                	li	a0,-1
    80005cb0:	b7fd                	j	80005c9e <argfd+0x50>
    80005cb2:	557d                	li	a0,-1
    80005cb4:	b7ed                	j	80005c9e <argfd+0x50>

0000000080005cb6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005cb6:	1101                	addi	sp,sp,-32
    80005cb8:	ec06                	sd	ra,24(sp)
    80005cba:	e822                	sd	s0,16(sp)
    80005cbc:	e426                	sd	s1,8(sp)
    80005cbe:	1000                	addi	s0,sp,32
    80005cc0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005cc2:	ffffc097          	auipc	ra,0xffffc
    80005cc6:	e46080e7          	jalr	-442(ra) # 80001b08 <myproc>
    80005cca:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005ccc:	05050793          	addi	a5,a0,80
    80005cd0:	4501                	li	a0,0
    80005cd2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005cd4:	6398                	ld	a4,0(a5)
    80005cd6:	cb19                	beqz	a4,80005cec <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005cd8:	2505                	addiw	a0,a0,1
    80005cda:	07a1                	addi	a5,a5,8
    80005cdc:	fed51ce3          	bne	a0,a3,80005cd4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005ce0:	557d                	li	a0,-1
}
    80005ce2:	60e2                	ld	ra,24(sp)
    80005ce4:	6442                	ld	s0,16(sp)
    80005ce6:	64a2                	ld	s1,8(sp)
    80005ce8:	6105                	addi	sp,sp,32
    80005cea:	8082                	ret
      p->ofile[fd] = f;
    80005cec:	00a50793          	addi	a5,a0,10
    80005cf0:	078e                	slli	a5,a5,0x3
    80005cf2:	963e                	add	a2,a2,a5
    80005cf4:	e204                	sd	s1,0(a2)
      return fd;
    80005cf6:	b7f5                	j	80005ce2 <fdalloc+0x2c>

0000000080005cf8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005cf8:	715d                	addi	sp,sp,-80
    80005cfa:	e486                	sd	ra,72(sp)
    80005cfc:	e0a2                	sd	s0,64(sp)
    80005cfe:	fc26                	sd	s1,56(sp)
    80005d00:	f84a                	sd	s2,48(sp)
    80005d02:	f44e                	sd	s3,40(sp)
    80005d04:	f052                	sd	s4,32(sp)
    80005d06:	ec56                	sd	s5,24(sp)
    80005d08:	0880                	addi	s0,sp,80
    80005d0a:	89ae                	mv	s3,a1
    80005d0c:	8ab2                	mv	s5,a2
    80005d0e:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005d10:	fb040593          	addi	a1,s0,-80
    80005d14:	fffff097          	auipc	ra,0xfffff
    80005d18:	1a6080e7          	jalr	422(ra) # 80004eba <nameiparent>
    80005d1c:	892a                	mv	s2,a0
    80005d1e:	12050e63          	beqz	a0,80005e5a <create+0x162>
    return 0;

  ilock(dp);
    80005d22:	fffff097          	auipc	ra,0xfffff
    80005d26:	9c6080e7          	jalr	-1594(ra) # 800046e8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005d2a:	4601                	li	a2,0
    80005d2c:	fb040593          	addi	a1,s0,-80
    80005d30:	854a                	mv	a0,s2
    80005d32:	fffff097          	auipc	ra,0xfffff
    80005d36:	e9a080e7          	jalr	-358(ra) # 80004bcc <dirlookup>
    80005d3a:	84aa                	mv	s1,a0
    80005d3c:	c921                	beqz	a0,80005d8c <create+0x94>
    iunlockput(dp);
    80005d3e:	854a                	mv	a0,s2
    80005d40:	fffff097          	auipc	ra,0xfffff
    80005d44:	c0a080e7          	jalr	-1014(ra) # 8000494a <iunlockput>
    ilock(ip);
    80005d48:	8526                	mv	a0,s1
    80005d4a:	fffff097          	auipc	ra,0xfffff
    80005d4e:	99e080e7          	jalr	-1634(ra) # 800046e8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005d52:	2981                	sext.w	s3,s3
    80005d54:	4789                	li	a5,2
    80005d56:	02f99463          	bne	s3,a5,80005d7e <create+0x86>
    80005d5a:	0444d783          	lhu	a5,68(s1)
    80005d5e:	37f9                	addiw	a5,a5,-2
    80005d60:	17c2                	slli	a5,a5,0x30
    80005d62:	93c1                	srli	a5,a5,0x30
    80005d64:	4705                	li	a4,1
    80005d66:	00f76c63          	bltu	a4,a5,80005d7e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005d6a:	8526                	mv	a0,s1
    80005d6c:	60a6                	ld	ra,72(sp)
    80005d6e:	6406                	ld	s0,64(sp)
    80005d70:	74e2                	ld	s1,56(sp)
    80005d72:	7942                	ld	s2,48(sp)
    80005d74:	79a2                	ld	s3,40(sp)
    80005d76:	7a02                	ld	s4,32(sp)
    80005d78:	6ae2                	ld	s5,24(sp)
    80005d7a:	6161                	addi	sp,sp,80
    80005d7c:	8082                	ret
    iunlockput(ip);
    80005d7e:	8526                	mv	a0,s1
    80005d80:	fffff097          	auipc	ra,0xfffff
    80005d84:	bca080e7          	jalr	-1078(ra) # 8000494a <iunlockput>
    return 0;
    80005d88:	4481                	li	s1,0
    80005d8a:	b7c5                	j	80005d6a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005d8c:	85ce                	mv	a1,s3
    80005d8e:	00092503          	lw	a0,0(s2)
    80005d92:	ffffe097          	auipc	ra,0xffffe
    80005d96:	7be080e7          	jalr	1982(ra) # 80004550 <ialloc>
    80005d9a:	84aa                	mv	s1,a0
    80005d9c:	c521                	beqz	a0,80005de4 <create+0xec>
  ilock(ip);
    80005d9e:	fffff097          	auipc	ra,0xfffff
    80005da2:	94a080e7          	jalr	-1718(ra) # 800046e8 <ilock>
  ip->major = major;
    80005da6:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005daa:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005dae:	4a05                	li	s4,1
    80005db0:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005db4:	8526                	mv	a0,s1
    80005db6:	fffff097          	auipc	ra,0xfffff
    80005dba:	868080e7          	jalr	-1944(ra) # 8000461e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005dbe:	2981                	sext.w	s3,s3
    80005dc0:	03498a63          	beq	s3,s4,80005df4 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005dc4:	40d0                	lw	a2,4(s1)
    80005dc6:	fb040593          	addi	a1,s0,-80
    80005dca:	854a                	mv	a0,s2
    80005dcc:	fffff097          	auipc	ra,0xfffff
    80005dd0:	00e080e7          	jalr	14(ra) # 80004dda <dirlink>
    80005dd4:	06054b63          	bltz	a0,80005e4a <create+0x152>
  iunlockput(dp);
    80005dd8:	854a                	mv	a0,s2
    80005dda:	fffff097          	auipc	ra,0xfffff
    80005dde:	b70080e7          	jalr	-1168(ra) # 8000494a <iunlockput>
  return ip;
    80005de2:	b761                	j	80005d6a <create+0x72>
    panic("create: ialloc");
    80005de4:	00003517          	auipc	a0,0x3
    80005de8:	b7c50513          	addi	a0,a0,-1156 # 80008960 <syscalls+0x2b8>
    80005dec:	ffffa097          	auipc	ra,0xffffa
    80005df0:	742080e7          	jalr	1858(ra) # 8000052e <panic>
    dp->nlink++;  // for ".."
    80005df4:	04a95783          	lhu	a5,74(s2)
    80005df8:	2785                	addiw	a5,a5,1
    80005dfa:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005dfe:	854a                	mv	a0,s2
    80005e00:	fffff097          	auipc	ra,0xfffff
    80005e04:	81e080e7          	jalr	-2018(ra) # 8000461e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005e08:	40d0                	lw	a2,4(s1)
    80005e0a:	00003597          	auipc	a1,0x3
    80005e0e:	b6658593          	addi	a1,a1,-1178 # 80008970 <syscalls+0x2c8>
    80005e12:	8526                	mv	a0,s1
    80005e14:	fffff097          	auipc	ra,0xfffff
    80005e18:	fc6080e7          	jalr	-58(ra) # 80004dda <dirlink>
    80005e1c:	00054f63          	bltz	a0,80005e3a <create+0x142>
    80005e20:	00492603          	lw	a2,4(s2)
    80005e24:	00003597          	auipc	a1,0x3
    80005e28:	b5458593          	addi	a1,a1,-1196 # 80008978 <syscalls+0x2d0>
    80005e2c:	8526                	mv	a0,s1
    80005e2e:	fffff097          	auipc	ra,0xfffff
    80005e32:	fac080e7          	jalr	-84(ra) # 80004dda <dirlink>
    80005e36:	f80557e3          	bgez	a0,80005dc4 <create+0xcc>
      panic("create dots");
    80005e3a:	00003517          	auipc	a0,0x3
    80005e3e:	b4650513          	addi	a0,a0,-1210 # 80008980 <syscalls+0x2d8>
    80005e42:	ffffa097          	auipc	ra,0xffffa
    80005e46:	6ec080e7          	jalr	1772(ra) # 8000052e <panic>
    panic("create: dirlink");
    80005e4a:	00003517          	auipc	a0,0x3
    80005e4e:	b4650513          	addi	a0,a0,-1210 # 80008990 <syscalls+0x2e8>
    80005e52:	ffffa097          	auipc	ra,0xffffa
    80005e56:	6dc080e7          	jalr	1756(ra) # 8000052e <panic>
    return 0;
    80005e5a:	84aa                	mv	s1,a0
    80005e5c:	b739                	j	80005d6a <create+0x72>

0000000080005e5e <sys_dup>:
{
    80005e5e:	7179                	addi	sp,sp,-48
    80005e60:	f406                	sd	ra,40(sp)
    80005e62:	f022                	sd	s0,32(sp)
    80005e64:	ec26                	sd	s1,24(sp)
    80005e66:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005e68:	fd840613          	addi	a2,s0,-40
    80005e6c:	4581                	li	a1,0
    80005e6e:	4501                	li	a0,0
    80005e70:	00000097          	auipc	ra,0x0
    80005e74:	dde080e7          	jalr	-546(ra) # 80005c4e <argfd>
    return -1;
    80005e78:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005e7a:	02054363          	bltz	a0,80005ea0 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005e7e:	fd843503          	ld	a0,-40(s0)
    80005e82:	00000097          	auipc	ra,0x0
    80005e86:	e34080e7          	jalr	-460(ra) # 80005cb6 <fdalloc>
    80005e8a:	84aa                	mv	s1,a0
    return -1;
    80005e8c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005e8e:	00054963          	bltz	a0,80005ea0 <sys_dup+0x42>
  filedup(f);
    80005e92:	fd843503          	ld	a0,-40(s0)
    80005e96:	fffff097          	auipc	ra,0xfffff
    80005e9a:	6a0080e7          	jalr	1696(ra) # 80005536 <filedup>
  return fd;
    80005e9e:	87a6                	mv	a5,s1
}
    80005ea0:	853e                	mv	a0,a5
    80005ea2:	70a2                	ld	ra,40(sp)
    80005ea4:	7402                	ld	s0,32(sp)
    80005ea6:	64e2                	ld	s1,24(sp)
    80005ea8:	6145                	addi	sp,sp,48
    80005eaa:	8082                	ret

0000000080005eac <sys_read>:
{
    80005eac:	7179                	addi	sp,sp,-48
    80005eae:	f406                	sd	ra,40(sp)
    80005eb0:	f022                	sd	s0,32(sp)
    80005eb2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005eb4:	fe840613          	addi	a2,s0,-24
    80005eb8:	4581                	li	a1,0
    80005eba:	4501                	li	a0,0
    80005ebc:	00000097          	auipc	ra,0x0
    80005ec0:	d92080e7          	jalr	-622(ra) # 80005c4e <argfd>
    return -1;
    80005ec4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ec6:	04054163          	bltz	a0,80005f08 <sys_read+0x5c>
    80005eca:	fe440593          	addi	a1,s0,-28
    80005ece:	4509                	li	a0,2
    80005ed0:	ffffe097          	auipc	ra,0xffffe
    80005ed4:	ad2080e7          	jalr	-1326(ra) # 800039a2 <argint>
    return -1;
    80005ed8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005eda:	02054763          	bltz	a0,80005f08 <sys_read+0x5c>
    80005ede:	fd840593          	addi	a1,s0,-40
    80005ee2:	4505                	li	a0,1
    80005ee4:	ffffe097          	auipc	ra,0xffffe
    80005ee8:	ae0080e7          	jalr	-1312(ra) # 800039c4 <argaddr>
    return -1;
    80005eec:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005eee:	00054d63          	bltz	a0,80005f08 <sys_read+0x5c>
  return fileread(f, p, n);
    80005ef2:	fe442603          	lw	a2,-28(s0)
    80005ef6:	fd843583          	ld	a1,-40(s0)
    80005efa:	fe843503          	ld	a0,-24(s0)
    80005efe:	fffff097          	auipc	ra,0xfffff
    80005f02:	7c4080e7          	jalr	1988(ra) # 800056c2 <fileread>
    80005f06:	87aa                	mv	a5,a0
}
    80005f08:	853e                	mv	a0,a5
    80005f0a:	70a2                	ld	ra,40(sp)
    80005f0c:	7402                	ld	s0,32(sp)
    80005f0e:	6145                	addi	sp,sp,48
    80005f10:	8082                	ret

0000000080005f12 <sys_write>:
{
    80005f12:	7179                	addi	sp,sp,-48
    80005f14:	f406                	sd	ra,40(sp)
    80005f16:	f022                	sd	s0,32(sp)
    80005f18:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f1a:	fe840613          	addi	a2,s0,-24
    80005f1e:	4581                	li	a1,0
    80005f20:	4501                	li	a0,0
    80005f22:	00000097          	auipc	ra,0x0
    80005f26:	d2c080e7          	jalr	-724(ra) # 80005c4e <argfd>
    return -1;
    80005f2a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f2c:	04054163          	bltz	a0,80005f6e <sys_write+0x5c>
    80005f30:	fe440593          	addi	a1,s0,-28
    80005f34:	4509                	li	a0,2
    80005f36:	ffffe097          	auipc	ra,0xffffe
    80005f3a:	a6c080e7          	jalr	-1428(ra) # 800039a2 <argint>
    return -1;
    80005f3e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f40:	02054763          	bltz	a0,80005f6e <sys_write+0x5c>
    80005f44:	fd840593          	addi	a1,s0,-40
    80005f48:	4505                	li	a0,1
    80005f4a:	ffffe097          	auipc	ra,0xffffe
    80005f4e:	a7a080e7          	jalr	-1414(ra) # 800039c4 <argaddr>
    return -1;
    80005f52:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f54:	00054d63          	bltz	a0,80005f6e <sys_write+0x5c>
  return filewrite(f, p, n);
    80005f58:	fe442603          	lw	a2,-28(s0)
    80005f5c:	fd843583          	ld	a1,-40(s0)
    80005f60:	fe843503          	ld	a0,-24(s0)
    80005f64:	00000097          	auipc	ra,0x0
    80005f68:	820080e7          	jalr	-2016(ra) # 80005784 <filewrite>
    80005f6c:	87aa                	mv	a5,a0
}
    80005f6e:	853e                	mv	a0,a5
    80005f70:	70a2                	ld	ra,40(sp)
    80005f72:	7402                	ld	s0,32(sp)
    80005f74:	6145                	addi	sp,sp,48
    80005f76:	8082                	ret

0000000080005f78 <sys_close>:
{
    80005f78:	1101                	addi	sp,sp,-32
    80005f7a:	ec06                	sd	ra,24(sp)
    80005f7c:	e822                	sd	s0,16(sp)
    80005f7e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005f80:	fe040613          	addi	a2,s0,-32
    80005f84:	fec40593          	addi	a1,s0,-20
    80005f88:	4501                	li	a0,0
    80005f8a:	00000097          	auipc	ra,0x0
    80005f8e:	cc4080e7          	jalr	-828(ra) # 80005c4e <argfd>
    return -1;
    80005f92:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005f94:	02054463          	bltz	a0,80005fbc <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005f98:	ffffc097          	auipc	ra,0xffffc
    80005f9c:	b70080e7          	jalr	-1168(ra) # 80001b08 <myproc>
    80005fa0:	fec42783          	lw	a5,-20(s0)
    80005fa4:	07a9                	addi	a5,a5,10
    80005fa6:	078e                	slli	a5,a5,0x3
    80005fa8:	97aa                	add	a5,a5,a0
    80005faa:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005fae:	fe043503          	ld	a0,-32(s0)
    80005fb2:	fffff097          	auipc	ra,0xfffff
    80005fb6:	5d6080e7          	jalr	1494(ra) # 80005588 <fileclose>
  return 0;
    80005fba:	4781                	li	a5,0
}
    80005fbc:	853e                	mv	a0,a5
    80005fbe:	60e2                	ld	ra,24(sp)
    80005fc0:	6442                	ld	s0,16(sp)
    80005fc2:	6105                	addi	sp,sp,32
    80005fc4:	8082                	ret

0000000080005fc6 <sys_fstat>:
{
    80005fc6:	1101                	addi	sp,sp,-32
    80005fc8:	ec06                	sd	ra,24(sp)
    80005fca:	e822                	sd	s0,16(sp)
    80005fcc:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005fce:	fe840613          	addi	a2,s0,-24
    80005fd2:	4581                	li	a1,0
    80005fd4:	4501                	li	a0,0
    80005fd6:	00000097          	auipc	ra,0x0
    80005fda:	c78080e7          	jalr	-904(ra) # 80005c4e <argfd>
    return -1;
    80005fde:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005fe0:	02054563          	bltz	a0,8000600a <sys_fstat+0x44>
    80005fe4:	fe040593          	addi	a1,s0,-32
    80005fe8:	4505                	li	a0,1
    80005fea:	ffffe097          	auipc	ra,0xffffe
    80005fee:	9da080e7          	jalr	-1574(ra) # 800039c4 <argaddr>
    return -1;
    80005ff2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005ff4:	00054b63          	bltz	a0,8000600a <sys_fstat+0x44>
  return filestat(f, st);
    80005ff8:	fe043583          	ld	a1,-32(s0)
    80005ffc:	fe843503          	ld	a0,-24(s0)
    80006000:	fffff097          	auipc	ra,0xfffff
    80006004:	650080e7          	jalr	1616(ra) # 80005650 <filestat>
    80006008:	87aa                	mv	a5,a0
}
    8000600a:	853e                	mv	a0,a5
    8000600c:	60e2                	ld	ra,24(sp)
    8000600e:	6442                	ld	s0,16(sp)
    80006010:	6105                	addi	sp,sp,32
    80006012:	8082                	ret

0000000080006014 <sys_link>:
{
    80006014:	7169                	addi	sp,sp,-304
    80006016:	f606                	sd	ra,296(sp)
    80006018:	f222                	sd	s0,288(sp)
    8000601a:	ee26                	sd	s1,280(sp)
    8000601c:	ea4a                	sd	s2,272(sp)
    8000601e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006020:	08000613          	li	a2,128
    80006024:	ed040593          	addi	a1,s0,-304
    80006028:	4501                	li	a0,0
    8000602a:	ffffe097          	auipc	ra,0xffffe
    8000602e:	9bc080e7          	jalr	-1604(ra) # 800039e6 <argstr>
    return -1;
    80006032:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006034:	10054e63          	bltz	a0,80006150 <sys_link+0x13c>
    80006038:	08000613          	li	a2,128
    8000603c:	f5040593          	addi	a1,s0,-176
    80006040:	4505                	li	a0,1
    80006042:	ffffe097          	auipc	ra,0xffffe
    80006046:	9a4080e7          	jalr	-1628(ra) # 800039e6 <argstr>
    return -1;
    8000604a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000604c:	10054263          	bltz	a0,80006150 <sys_link+0x13c>
  begin_op();
    80006050:	fffff097          	auipc	ra,0xfffff
    80006054:	06c080e7          	jalr	108(ra) # 800050bc <begin_op>
  if((ip = namei(old)) == 0){
    80006058:	ed040513          	addi	a0,s0,-304
    8000605c:	fffff097          	auipc	ra,0xfffff
    80006060:	e40080e7          	jalr	-448(ra) # 80004e9c <namei>
    80006064:	84aa                	mv	s1,a0
    80006066:	c551                	beqz	a0,800060f2 <sys_link+0xde>
  ilock(ip);
    80006068:	ffffe097          	auipc	ra,0xffffe
    8000606c:	680080e7          	jalr	1664(ra) # 800046e8 <ilock>
  if(ip->type == T_DIR){
    80006070:	04449703          	lh	a4,68(s1)
    80006074:	4785                	li	a5,1
    80006076:	08f70463          	beq	a4,a5,800060fe <sys_link+0xea>
  ip->nlink++;
    8000607a:	04a4d783          	lhu	a5,74(s1)
    8000607e:	2785                	addiw	a5,a5,1
    80006080:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006084:	8526                	mv	a0,s1
    80006086:	ffffe097          	auipc	ra,0xffffe
    8000608a:	598080e7          	jalr	1432(ra) # 8000461e <iupdate>
  iunlock(ip);
    8000608e:	8526                	mv	a0,s1
    80006090:	ffffe097          	auipc	ra,0xffffe
    80006094:	71a080e7          	jalr	1818(ra) # 800047aa <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80006098:	fd040593          	addi	a1,s0,-48
    8000609c:	f5040513          	addi	a0,s0,-176
    800060a0:	fffff097          	auipc	ra,0xfffff
    800060a4:	e1a080e7          	jalr	-486(ra) # 80004eba <nameiparent>
    800060a8:	892a                	mv	s2,a0
    800060aa:	c935                	beqz	a0,8000611e <sys_link+0x10a>
  ilock(dp);
    800060ac:	ffffe097          	auipc	ra,0xffffe
    800060b0:	63c080e7          	jalr	1596(ra) # 800046e8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800060b4:	00092703          	lw	a4,0(s2)
    800060b8:	409c                	lw	a5,0(s1)
    800060ba:	04f71d63          	bne	a4,a5,80006114 <sys_link+0x100>
    800060be:	40d0                	lw	a2,4(s1)
    800060c0:	fd040593          	addi	a1,s0,-48
    800060c4:	854a                	mv	a0,s2
    800060c6:	fffff097          	auipc	ra,0xfffff
    800060ca:	d14080e7          	jalr	-748(ra) # 80004dda <dirlink>
    800060ce:	04054363          	bltz	a0,80006114 <sys_link+0x100>
  iunlockput(dp);
    800060d2:	854a                	mv	a0,s2
    800060d4:	fffff097          	auipc	ra,0xfffff
    800060d8:	876080e7          	jalr	-1930(ra) # 8000494a <iunlockput>
  iput(ip);
    800060dc:	8526                	mv	a0,s1
    800060de:	ffffe097          	auipc	ra,0xffffe
    800060e2:	7c4080e7          	jalr	1988(ra) # 800048a2 <iput>
  end_op();
    800060e6:	fffff097          	auipc	ra,0xfffff
    800060ea:	056080e7          	jalr	86(ra) # 8000513c <end_op>
  return 0;
    800060ee:	4781                	li	a5,0
    800060f0:	a085                	j	80006150 <sys_link+0x13c>
    end_op();
    800060f2:	fffff097          	auipc	ra,0xfffff
    800060f6:	04a080e7          	jalr	74(ra) # 8000513c <end_op>
    return -1;
    800060fa:	57fd                	li	a5,-1
    800060fc:	a891                	j	80006150 <sys_link+0x13c>
    iunlockput(ip);
    800060fe:	8526                	mv	a0,s1
    80006100:	fffff097          	auipc	ra,0xfffff
    80006104:	84a080e7          	jalr	-1974(ra) # 8000494a <iunlockput>
    end_op();
    80006108:	fffff097          	auipc	ra,0xfffff
    8000610c:	034080e7          	jalr	52(ra) # 8000513c <end_op>
    return -1;
    80006110:	57fd                	li	a5,-1
    80006112:	a83d                	j	80006150 <sys_link+0x13c>
    iunlockput(dp);
    80006114:	854a                	mv	a0,s2
    80006116:	fffff097          	auipc	ra,0xfffff
    8000611a:	834080e7          	jalr	-1996(ra) # 8000494a <iunlockput>
  ilock(ip);
    8000611e:	8526                	mv	a0,s1
    80006120:	ffffe097          	auipc	ra,0xffffe
    80006124:	5c8080e7          	jalr	1480(ra) # 800046e8 <ilock>
  ip->nlink--;
    80006128:	04a4d783          	lhu	a5,74(s1)
    8000612c:	37fd                	addiw	a5,a5,-1
    8000612e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006132:	8526                	mv	a0,s1
    80006134:	ffffe097          	auipc	ra,0xffffe
    80006138:	4ea080e7          	jalr	1258(ra) # 8000461e <iupdate>
  iunlockput(ip);
    8000613c:	8526                	mv	a0,s1
    8000613e:	fffff097          	auipc	ra,0xfffff
    80006142:	80c080e7          	jalr	-2036(ra) # 8000494a <iunlockput>
  end_op();
    80006146:	fffff097          	auipc	ra,0xfffff
    8000614a:	ff6080e7          	jalr	-10(ra) # 8000513c <end_op>
  return -1;
    8000614e:	57fd                	li	a5,-1
}
    80006150:	853e                	mv	a0,a5
    80006152:	70b2                	ld	ra,296(sp)
    80006154:	7412                	ld	s0,288(sp)
    80006156:	64f2                	ld	s1,280(sp)
    80006158:	6952                	ld	s2,272(sp)
    8000615a:	6155                	addi	sp,sp,304
    8000615c:	8082                	ret

000000008000615e <sys_unlink>:
{
    8000615e:	7151                	addi	sp,sp,-240
    80006160:	f586                	sd	ra,232(sp)
    80006162:	f1a2                	sd	s0,224(sp)
    80006164:	eda6                	sd	s1,216(sp)
    80006166:	e9ca                	sd	s2,208(sp)
    80006168:	e5ce                	sd	s3,200(sp)
    8000616a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000616c:	08000613          	li	a2,128
    80006170:	f3040593          	addi	a1,s0,-208
    80006174:	4501                	li	a0,0
    80006176:	ffffe097          	auipc	ra,0xffffe
    8000617a:	870080e7          	jalr	-1936(ra) # 800039e6 <argstr>
    8000617e:	18054163          	bltz	a0,80006300 <sys_unlink+0x1a2>
  begin_op();
    80006182:	fffff097          	auipc	ra,0xfffff
    80006186:	f3a080e7          	jalr	-198(ra) # 800050bc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000618a:	fb040593          	addi	a1,s0,-80
    8000618e:	f3040513          	addi	a0,s0,-208
    80006192:	fffff097          	auipc	ra,0xfffff
    80006196:	d28080e7          	jalr	-728(ra) # 80004eba <nameiparent>
    8000619a:	84aa                	mv	s1,a0
    8000619c:	c979                	beqz	a0,80006272 <sys_unlink+0x114>
  ilock(dp);
    8000619e:	ffffe097          	auipc	ra,0xffffe
    800061a2:	54a080e7          	jalr	1354(ra) # 800046e8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800061a6:	00002597          	auipc	a1,0x2
    800061aa:	7ca58593          	addi	a1,a1,1994 # 80008970 <syscalls+0x2c8>
    800061ae:	fb040513          	addi	a0,s0,-80
    800061b2:	fffff097          	auipc	ra,0xfffff
    800061b6:	a00080e7          	jalr	-1536(ra) # 80004bb2 <namecmp>
    800061ba:	14050a63          	beqz	a0,8000630e <sys_unlink+0x1b0>
    800061be:	00002597          	auipc	a1,0x2
    800061c2:	7ba58593          	addi	a1,a1,1978 # 80008978 <syscalls+0x2d0>
    800061c6:	fb040513          	addi	a0,s0,-80
    800061ca:	fffff097          	auipc	ra,0xfffff
    800061ce:	9e8080e7          	jalr	-1560(ra) # 80004bb2 <namecmp>
    800061d2:	12050e63          	beqz	a0,8000630e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800061d6:	f2c40613          	addi	a2,s0,-212
    800061da:	fb040593          	addi	a1,s0,-80
    800061de:	8526                	mv	a0,s1
    800061e0:	fffff097          	auipc	ra,0xfffff
    800061e4:	9ec080e7          	jalr	-1556(ra) # 80004bcc <dirlookup>
    800061e8:	892a                	mv	s2,a0
    800061ea:	12050263          	beqz	a0,8000630e <sys_unlink+0x1b0>
  ilock(ip);
    800061ee:	ffffe097          	auipc	ra,0xffffe
    800061f2:	4fa080e7          	jalr	1274(ra) # 800046e8 <ilock>
  if(ip->nlink < 1)
    800061f6:	04a91783          	lh	a5,74(s2)
    800061fa:	08f05263          	blez	a5,8000627e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800061fe:	04491703          	lh	a4,68(s2)
    80006202:	4785                	li	a5,1
    80006204:	08f70563          	beq	a4,a5,8000628e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80006208:	4641                	li	a2,16
    8000620a:	4581                	li	a1,0
    8000620c:	fc040513          	addi	a0,s0,-64
    80006210:	ffffb097          	auipc	ra,0xffffb
    80006214:	ac8080e7          	jalr	-1336(ra) # 80000cd8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006218:	4741                	li	a4,16
    8000621a:	f2c42683          	lw	a3,-212(s0)
    8000621e:	fc040613          	addi	a2,s0,-64
    80006222:	4581                	li	a1,0
    80006224:	8526                	mv	a0,s1
    80006226:	fffff097          	auipc	ra,0xfffff
    8000622a:	86e080e7          	jalr	-1938(ra) # 80004a94 <writei>
    8000622e:	47c1                	li	a5,16
    80006230:	0af51563          	bne	a0,a5,800062da <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80006234:	04491703          	lh	a4,68(s2)
    80006238:	4785                	li	a5,1
    8000623a:	0af70863          	beq	a4,a5,800062ea <sys_unlink+0x18c>
  iunlockput(dp);
    8000623e:	8526                	mv	a0,s1
    80006240:	ffffe097          	auipc	ra,0xffffe
    80006244:	70a080e7          	jalr	1802(ra) # 8000494a <iunlockput>
  ip->nlink--;
    80006248:	04a95783          	lhu	a5,74(s2)
    8000624c:	37fd                	addiw	a5,a5,-1
    8000624e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80006252:	854a                	mv	a0,s2
    80006254:	ffffe097          	auipc	ra,0xffffe
    80006258:	3ca080e7          	jalr	970(ra) # 8000461e <iupdate>
  iunlockput(ip);
    8000625c:	854a                	mv	a0,s2
    8000625e:	ffffe097          	auipc	ra,0xffffe
    80006262:	6ec080e7          	jalr	1772(ra) # 8000494a <iunlockput>
  end_op();
    80006266:	fffff097          	auipc	ra,0xfffff
    8000626a:	ed6080e7          	jalr	-298(ra) # 8000513c <end_op>
  return 0;
    8000626e:	4501                	li	a0,0
    80006270:	a84d                	j	80006322 <sys_unlink+0x1c4>
    end_op();
    80006272:	fffff097          	auipc	ra,0xfffff
    80006276:	eca080e7          	jalr	-310(ra) # 8000513c <end_op>
    return -1;
    8000627a:	557d                	li	a0,-1
    8000627c:	a05d                	j	80006322 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000627e:	00002517          	auipc	a0,0x2
    80006282:	72250513          	addi	a0,a0,1826 # 800089a0 <syscalls+0x2f8>
    80006286:	ffffa097          	auipc	ra,0xffffa
    8000628a:	2a8080e7          	jalr	680(ra) # 8000052e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000628e:	04c92703          	lw	a4,76(s2)
    80006292:	02000793          	li	a5,32
    80006296:	f6e7f9e3          	bgeu	a5,a4,80006208 <sys_unlink+0xaa>
    8000629a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000629e:	4741                	li	a4,16
    800062a0:	86ce                	mv	a3,s3
    800062a2:	f1840613          	addi	a2,s0,-232
    800062a6:	4581                	li	a1,0
    800062a8:	854a                	mv	a0,s2
    800062aa:	ffffe097          	auipc	ra,0xffffe
    800062ae:	6f2080e7          	jalr	1778(ra) # 8000499c <readi>
    800062b2:	47c1                	li	a5,16
    800062b4:	00f51b63          	bne	a0,a5,800062ca <sys_unlink+0x16c>
    if(de.inum != 0)
    800062b8:	f1845783          	lhu	a5,-232(s0)
    800062bc:	e7a1                	bnez	a5,80006304 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800062be:	29c1                	addiw	s3,s3,16
    800062c0:	04c92783          	lw	a5,76(s2)
    800062c4:	fcf9ede3          	bltu	s3,a5,8000629e <sys_unlink+0x140>
    800062c8:	b781                	j	80006208 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800062ca:	00002517          	auipc	a0,0x2
    800062ce:	6ee50513          	addi	a0,a0,1774 # 800089b8 <syscalls+0x310>
    800062d2:	ffffa097          	auipc	ra,0xffffa
    800062d6:	25c080e7          	jalr	604(ra) # 8000052e <panic>
    panic("unlink: writei");
    800062da:	00002517          	auipc	a0,0x2
    800062de:	6f650513          	addi	a0,a0,1782 # 800089d0 <syscalls+0x328>
    800062e2:	ffffa097          	auipc	ra,0xffffa
    800062e6:	24c080e7          	jalr	588(ra) # 8000052e <panic>
    dp->nlink--;
    800062ea:	04a4d783          	lhu	a5,74(s1)
    800062ee:	37fd                	addiw	a5,a5,-1
    800062f0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800062f4:	8526                	mv	a0,s1
    800062f6:	ffffe097          	auipc	ra,0xffffe
    800062fa:	328080e7          	jalr	808(ra) # 8000461e <iupdate>
    800062fe:	b781                	j	8000623e <sys_unlink+0xe0>
    return -1;
    80006300:	557d                	li	a0,-1
    80006302:	a005                	j	80006322 <sys_unlink+0x1c4>
    iunlockput(ip);
    80006304:	854a                	mv	a0,s2
    80006306:	ffffe097          	auipc	ra,0xffffe
    8000630a:	644080e7          	jalr	1604(ra) # 8000494a <iunlockput>
  iunlockput(dp);
    8000630e:	8526                	mv	a0,s1
    80006310:	ffffe097          	auipc	ra,0xffffe
    80006314:	63a080e7          	jalr	1594(ra) # 8000494a <iunlockput>
  end_op();
    80006318:	fffff097          	auipc	ra,0xfffff
    8000631c:	e24080e7          	jalr	-476(ra) # 8000513c <end_op>
  return -1;
    80006320:	557d                	li	a0,-1
}
    80006322:	70ae                	ld	ra,232(sp)
    80006324:	740e                	ld	s0,224(sp)
    80006326:	64ee                	ld	s1,216(sp)
    80006328:	694e                	ld	s2,208(sp)
    8000632a:	69ae                	ld	s3,200(sp)
    8000632c:	616d                	addi	sp,sp,240
    8000632e:	8082                	ret

0000000080006330 <sys_open>:

uint64
sys_open(void)
{
    80006330:	7131                	addi	sp,sp,-192
    80006332:	fd06                	sd	ra,184(sp)
    80006334:	f922                	sd	s0,176(sp)
    80006336:	f526                	sd	s1,168(sp)
    80006338:	f14a                	sd	s2,160(sp)
    8000633a:	ed4e                	sd	s3,152(sp)
    8000633c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000633e:	08000613          	li	a2,128
    80006342:	f5040593          	addi	a1,s0,-176
    80006346:	4501                	li	a0,0
    80006348:	ffffd097          	auipc	ra,0xffffd
    8000634c:	69e080e7          	jalr	1694(ra) # 800039e6 <argstr>
    return -1;
    80006350:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006352:	0c054163          	bltz	a0,80006414 <sys_open+0xe4>
    80006356:	f4c40593          	addi	a1,s0,-180
    8000635a:	4505                	li	a0,1
    8000635c:	ffffd097          	auipc	ra,0xffffd
    80006360:	646080e7          	jalr	1606(ra) # 800039a2 <argint>
    80006364:	0a054863          	bltz	a0,80006414 <sys_open+0xe4>

  begin_op();
    80006368:	fffff097          	auipc	ra,0xfffff
    8000636c:	d54080e7          	jalr	-684(ra) # 800050bc <begin_op>

  if(omode & O_CREATE){
    80006370:	f4c42783          	lw	a5,-180(s0)
    80006374:	2007f793          	andi	a5,a5,512
    80006378:	cbdd                	beqz	a5,8000642e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000637a:	4681                	li	a3,0
    8000637c:	4601                	li	a2,0
    8000637e:	4589                	li	a1,2
    80006380:	f5040513          	addi	a0,s0,-176
    80006384:	00000097          	auipc	ra,0x0
    80006388:	974080e7          	jalr	-1676(ra) # 80005cf8 <create>
    8000638c:	892a                	mv	s2,a0
    if(ip == 0){
    8000638e:	c959                	beqz	a0,80006424 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80006390:	04491703          	lh	a4,68(s2)
    80006394:	478d                	li	a5,3
    80006396:	00f71763          	bne	a4,a5,800063a4 <sys_open+0x74>
    8000639a:	04695703          	lhu	a4,70(s2)
    8000639e:	47a5                	li	a5,9
    800063a0:	0ce7ec63          	bltu	a5,a4,80006478 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800063a4:	fffff097          	auipc	ra,0xfffff
    800063a8:	128080e7          	jalr	296(ra) # 800054cc <filealloc>
    800063ac:	89aa                	mv	s3,a0
    800063ae:	10050263          	beqz	a0,800064b2 <sys_open+0x182>
    800063b2:	00000097          	auipc	ra,0x0
    800063b6:	904080e7          	jalr	-1788(ra) # 80005cb6 <fdalloc>
    800063ba:	84aa                	mv	s1,a0
    800063bc:	0e054663          	bltz	a0,800064a8 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800063c0:	04491703          	lh	a4,68(s2)
    800063c4:	478d                	li	a5,3
    800063c6:	0cf70463          	beq	a4,a5,8000648e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800063ca:	4789                	li	a5,2
    800063cc:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800063d0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800063d4:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800063d8:	f4c42783          	lw	a5,-180(s0)
    800063dc:	0017c713          	xori	a4,a5,1
    800063e0:	8b05                	andi	a4,a4,1
    800063e2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800063e6:	0037f713          	andi	a4,a5,3
    800063ea:	00e03733          	snez	a4,a4
    800063ee:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800063f2:	4007f793          	andi	a5,a5,1024
    800063f6:	c791                	beqz	a5,80006402 <sys_open+0xd2>
    800063f8:	04491703          	lh	a4,68(s2)
    800063fc:	4789                	li	a5,2
    800063fe:	08f70f63          	beq	a4,a5,8000649c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006402:	854a                	mv	a0,s2
    80006404:	ffffe097          	auipc	ra,0xffffe
    80006408:	3a6080e7          	jalr	934(ra) # 800047aa <iunlock>
  end_op();
    8000640c:	fffff097          	auipc	ra,0xfffff
    80006410:	d30080e7          	jalr	-720(ra) # 8000513c <end_op>

  return fd;
}
    80006414:	8526                	mv	a0,s1
    80006416:	70ea                	ld	ra,184(sp)
    80006418:	744a                	ld	s0,176(sp)
    8000641a:	74aa                	ld	s1,168(sp)
    8000641c:	790a                	ld	s2,160(sp)
    8000641e:	69ea                	ld	s3,152(sp)
    80006420:	6129                	addi	sp,sp,192
    80006422:	8082                	ret
      end_op();
    80006424:	fffff097          	auipc	ra,0xfffff
    80006428:	d18080e7          	jalr	-744(ra) # 8000513c <end_op>
      return -1;
    8000642c:	b7e5                	j	80006414 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000642e:	f5040513          	addi	a0,s0,-176
    80006432:	fffff097          	auipc	ra,0xfffff
    80006436:	a6a080e7          	jalr	-1430(ra) # 80004e9c <namei>
    8000643a:	892a                	mv	s2,a0
    8000643c:	c905                	beqz	a0,8000646c <sys_open+0x13c>
    ilock(ip);
    8000643e:	ffffe097          	auipc	ra,0xffffe
    80006442:	2aa080e7          	jalr	682(ra) # 800046e8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006446:	04491703          	lh	a4,68(s2)
    8000644a:	4785                	li	a5,1
    8000644c:	f4f712e3          	bne	a4,a5,80006390 <sys_open+0x60>
    80006450:	f4c42783          	lw	a5,-180(s0)
    80006454:	dba1                	beqz	a5,800063a4 <sys_open+0x74>
      iunlockput(ip);
    80006456:	854a                	mv	a0,s2
    80006458:	ffffe097          	auipc	ra,0xffffe
    8000645c:	4f2080e7          	jalr	1266(ra) # 8000494a <iunlockput>
      end_op();
    80006460:	fffff097          	auipc	ra,0xfffff
    80006464:	cdc080e7          	jalr	-804(ra) # 8000513c <end_op>
      return -1;
    80006468:	54fd                	li	s1,-1
    8000646a:	b76d                	j	80006414 <sys_open+0xe4>
      end_op();
    8000646c:	fffff097          	auipc	ra,0xfffff
    80006470:	cd0080e7          	jalr	-816(ra) # 8000513c <end_op>
      return -1;
    80006474:	54fd                	li	s1,-1
    80006476:	bf79                	j	80006414 <sys_open+0xe4>
    iunlockput(ip);
    80006478:	854a                	mv	a0,s2
    8000647a:	ffffe097          	auipc	ra,0xffffe
    8000647e:	4d0080e7          	jalr	1232(ra) # 8000494a <iunlockput>
    end_op();
    80006482:	fffff097          	auipc	ra,0xfffff
    80006486:	cba080e7          	jalr	-838(ra) # 8000513c <end_op>
    return -1;
    8000648a:	54fd                	li	s1,-1
    8000648c:	b761                	j	80006414 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000648e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006492:	04691783          	lh	a5,70(s2)
    80006496:	02f99223          	sh	a5,36(s3)
    8000649a:	bf2d                	j	800063d4 <sys_open+0xa4>
    itrunc(ip);
    8000649c:	854a                	mv	a0,s2
    8000649e:	ffffe097          	auipc	ra,0xffffe
    800064a2:	358080e7          	jalr	856(ra) # 800047f6 <itrunc>
    800064a6:	bfb1                	j	80006402 <sys_open+0xd2>
      fileclose(f);
    800064a8:	854e                	mv	a0,s3
    800064aa:	fffff097          	auipc	ra,0xfffff
    800064ae:	0de080e7          	jalr	222(ra) # 80005588 <fileclose>
    iunlockput(ip);
    800064b2:	854a                	mv	a0,s2
    800064b4:	ffffe097          	auipc	ra,0xffffe
    800064b8:	496080e7          	jalr	1174(ra) # 8000494a <iunlockput>
    end_op();
    800064bc:	fffff097          	auipc	ra,0xfffff
    800064c0:	c80080e7          	jalr	-896(ra) # 8000513c <end_op>
    return -1;
    800064c4:	54fd                	li	s1,-1
    800064c6:	b7b9                	j	80006414 <sys_open+0xe4>

00000000800064c8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800064c8:	7175                	addi	sp,sp,-144
    800064ca:	e506                	sd	ra,136(sp)
    800064cc:	e122                	sd	s0,128(sp)
    800064ce:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800064d0:	fffff097          	auipc	ra,0xfffff
    800064d4:	bec080e7          	jalr	-1044(ra) # 800050bc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800064d8:	08000613          	li	a2,128
    800064dc:	f7040593          	addi	a1,s0,-144
    800064e0:	4501                	li	a0,0
    800064e2:	ffffd097          	auipc	ra,0xffffd
    800064e6:	504080e7          	jalr	1284(ra) # 800039e6 <argstr>
    800064ea:	02054963          	bltz	a0,8000651c <sys_mkdir+0x54>
    800064ee:	4681                	li	a3,0
    800064f0:	4601                	li	a2,0
    800064f2:	4585                	li	a1,1
    800064f4:	f7040513          	addi	a0,s0,-144
    800064f8:	00000097          	auipc	ra,0x0
    800064fc:	800080e7          	jalr	-2048(ra) # 80005cf8 <create>
    80006500:	cd11                	beqz	a0,8000651c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006502:	ffffe097          	auipc	ra,0xffffe
    80006506:	448080e7          	jalr	1096(ra) # 8000494a <iunlockput>
  end_op();
    8000650a:	fffff097          	auipc	ra,0xfffff
    8000650e:	c32080e7          	jalr	-974(ra) # 8000513c <end_op>
  return 0;
    80006512:	4501                	li	a0,0
}
    80006514:	60aa                	ld	ra,136(sp)
    80006516:	640a                	ld	s0,128(sp)
    80006518:	6149                	addi	sp,sp,144
    8000651a:	8082                	ret
    end_op();
    8000651c:	fffff097          	auipc	ra,0xfffff
    80006520:	c20080e7          	jalr	-992(ra) # 8000513c <end_op>
    return -1;
    80006524:	557d                	li	a0,-1
    80006526:	b7fd                	j	80006514 <sys_mkdir+0x4c>

0000000080006528 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006528:	7135                	addi	sp,sp,-160
    8000652a:	ed06                	sd	ra,152(sp)
    8000652c:	e922                	sd	s0,144(sp)
    8000652e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006530:	fffff097          	auipc	ra,0xfffff
    80006534:	b8c080e7          	jalr	-1140(ra) # 800050bc <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006538:	08000613          	li	a2,128
    8000653c:	f7040593          	addi	a1,s0,-144
    80006540:	4501                	li	a0,0
    80006542:	ffffd097          	auipc	ra,0xffffd
    80006546:	4a4080e7          	jalr	1188(ra) # 800039e6 <argstr>
    8000654a:	04054a63          	bltz	a0,8000659e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000654e:	f6c40593          	addi	a1,s0,-148
    80006552:	4505                	li	a0,1
    80006554:	ffffd097          	auipc	ra,0xffffd
    80006558:	44e080e7          	jalr	1102(ra) # 800039a2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000655c:	04054163          	bltz	a0,8000659e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80006560:	f6840593          	addi	a1,s0,-152
    80006564:	4509                	li	a0,2
    80006566:	ffffd097          	auipc	ra,0xffffd
    8000656a:	43c080e7          	jalr	1084(ra) # 800039a2 <argint>
     argint(1, &major) < 0 ||
    8000656e:	02054863          	bltz	a0,8000659e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006572:	f6841683          	lh	a3,-152(s0)
    80006576:	f6c41603          	lh	a2,-148(s0)
    8000657a:	458d                	li	a1,3
    8000657c:	f7040513          	addi	a0,s0,-144
    80006580:	fffff097          	auipc	ra,0xfffff
    80006584:	778080e7          	jalr	1912(ra) # 80005cf8 <create>
     argint(2, &minor) < 0 ||
    80006588:	c919                	beqz	a0,8000659e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000658a:	ffffe097          	auipc	ra,0xffffe
    8000658e:	3c0080e7          	jalr	960(ra) # 8000494a <iunlockput>
  end_op();
    80006592:	fffff097          	auipc	ra,0xfffff
    80006596:	baa080e7          	jalr	-1110(ra) # 8000513c <end_op>
  return 0;
    8000659a:	4501                	li	a0,0
    8000659c:	a031                	j	800065a8 <sys_mknod+0x80>
    end_op();
    8000659e:	fffff097          	auipc	ra,0xfffff
    800065a2:	b9e080e7          	jalr	-1122(ra) # 8000513c <end_op>
    return -1;
    800065a6:	557d                	li	a0,-1
}
    800065a8:	60ea                	ld	ra,152(sp)
    800065aa:	644a                	ld	s0,144(sp)
    800065ac:	610d                	addi	sp,sp,160
    800065ae:	8082                	ret

00000000800065b0 <sys_chdir>:

uint64
sys_chdir(void)
{
    800065b0:	7135                	addi	sp,sp,-160
    800065b2:	ed06                	sd	ra,152(sp)
    800065b4:	e922                	sd	s0,144(sp)
    800065b6:	e526                	sd	s1,136(sp)
    800065b8:	e14a                	sd	s2,128(sp)
    800065ba:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800065bc:	ffffb097          	auipc	ra,0xffffb
    800065c0:	54c080e7          	jalr	1356(ra) # 80001b08 <myproc>
    800065c4:	892a                	mv	s2,a0
  
  begin_op();
    800065c6:	fffff097          	auipc	ra,0xfffff
    800065ca:	af6080e7          	jalr	-1290(ra) # 800050bc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800065ce:	08000613          	li	a2,128
    800065d2:	f6040593          	addi	a1,s0,-160
    800065d6:	4501                	li	a0,0
    800065d8:	ffffd097          	auipc	ra,0xffffd
    800065dc:	40e080e7          	jalr	1038(ra) # 800039e6 <argstr>
    800065e0:	04054b63          	bltz	a0,80006636 <sys_chdir+0x86>
    800065e4:	f6040513          	addi	a0,s0,-160
    800065e8:	fffff097          	auipc	ra,0xfffff
    800065ec:	8b4080e7          	jalr	-1868(ra) # 80004e9c <namei>
    800065f0:	84aa                	mv	s1,a0
    800065f2:	c131                	beqz	a0,80006636 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800065f4:	ffffe097          	auipc	ra,0xffffe
    800065f8:	0f4080e7          	jalr	244(ra) # 800046e8 <ilock>
  if(ip->type != T_DIR){
    800065fc:	04449703          	lh	a4,68(s1)
    80006600:	4785                	li	a5,1
    80006602:	04f71063          	bne	a4,a5,80006642 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006606:	8526                	mv	a0,s1
    80006608:	ffffe097          	auipc	ra,0xffffe
    8000660c:	1a2080e7          	jalr	418(ra) # 800047aa <iunlock>
  iput(p->cwd);
    80006610:	0d093503          	ld	a0,208(s2)
    80006614:	ffffe097          	auipc	ra,0xffffe
    80006618:	28e080e7          	jalr	654(ra) # 800048a2 <iput>
  end_op();
    8000661c:	fffff097          	auipc	ra,0xfffff
    80006620:	b20080e7          	jalr	-1248(ra) # 8000513c <end_op>
  p->cwd = ip;
    80006624:	0c993823          	sd	s1,208(s2)
  return 0;
    80006628:	4501                	li	a0,0
}
    8000662a:	60ea                	ld	ra,152(sp)
    8000662c:	644a                	ld	s0,144(sp)
    8000662e:	64aa                	ld	s1,136(sp)
    80006630:	690a                	ld	s2,128(sp)
    80006632:	610d                	addi	sp,sp,160
    80006634:	8082                	ret
    end_op();
    80006636:	fffff097          	auipc	ra,0xfffff
    8000663a:	b06080e7          	jalr	-1274(ra) # 8000513c <end_op>
    return -1;
    8000663e:	557d                	li	a0,-1
    80006640:	b7ed                	j	8000662a <sys_chdir+0x7a>
    iunlockput(ip);
    80006642:	8526                	mv	a0,s1
    80006644:	ffffe097          	auipc	ra,0xffffe
    80006648:	306080e7          	jalr	774(ra) # 8000494a <iunlockput>
    end_op();
    8000664c:	fffff097          	auipc	ra,0xfffff
    80006650:	af0080e7          	jalr	-1296(ra) # 8000513c <end_op>
    return -1;
    80006654:	557d                	li	a0,-1
    80006656:	bfd1                	j	8000662a <sys_chdir+0x7a>

0000000080006658 <sys_exec>:

uint64
sys_exec(void)
{
    80006658:	7145                	addi	sp,sp,-464
    8000665a:	e786                	sd	ra,456(sp)
    8000665c:	e3a2                	sd	s0,448(sp)
    8000665e:	ff26                	sd	s1,440(sp)
    80006660:	fb4a                	sd	s2,432(sp)
    80006662:	f74e                	sd	s3,424(sp)
    80006664:	f352                	sd	s4,416(sp)
    80006666:	ef56                	sd	s5,408(sp)
    80006668:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000666a:	08000613          	li	a2,128
    8000666e:	f4040593          	addi	a1,s0,-192
    80006672:	4501                	li	a0,0
    80006674:	ffffd097          	auipc	ra,0xffffd
    80006678:	372080e7          	jalr	882(ra) # 800039e6 <argstr>
    return -1;
    8000667c:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000667e:	0c054a63          	bltz	a0,80006752 <sys_exec+0xfa>
    80006682:	e3840593          	addi	a1,s0,-456
    80006686:	4505                	li	a0,1
    80006688:	ffffd097          	auipc	ra,0xffffd
    8000668c:	33c080e7          	jalr	828(ra) # 800039c4 <argaddr>
    80006690:	0c054163          	bltz	a0,80006752 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006694:	10000613          	li	a2,256
    80006698:	4581                	li	a1,0
    8000669a:	e4040513          	addi	a0,s0,-448
    8000669e:	ffffa097          	auipc	ra,0xffffa
    800066a2:	63a080e7          	jalr	1594(ra) # 80000cd8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800066a6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800066aa:	89a6                	mv	s3,s1
    800066ac:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800066ae:	02000a13          	li	s4,32
    800066b2:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800066b6:	00391793          	slli	a5,s2,0x3
    800066ba:	e3040593          	addi	a1,s0,-464
    800066be:	e3843503          	ld	a0,-456(s0)
    800066c2:	953e                	add	a0,a0,a5
    800066c4:	ffffd097          	auipc	ra,0xffffd
    800066c8:	244080e7          	jalr	580(ra) # 80003908 <fetchaddr>
    800066cc:	02054a63          	bltz	a0,80006700 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    800066d0:	e3043783          	ld	a5,-464(s0)
    800066d4:	c3b9                	beqz	a5,8000671a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800066d6:	ffffa097          	auipc	ra,0xffffa
    800066da:	400080e7          	jalr	1024(ra) # 80000ad6 <kalloc>
    800066de:	85aa                	mv	a1,a0
    800066e0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800066e4:	cd11                	beqz	a0,80006700 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800066e6:	6605                	lui	a2,0x1
    800066e8:	e3043503          	ld	a0,-464(s0)
    800066ec:	ffffd097          	auipc	ra,0xffffd
    800066f0:	26e080e7          	jalr	622(ra) # 8000395a <fetchstr>
    800066f4:	00054663          	bltz	a0,80006700 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    800066f8:	0905                	addi	s2,s2,1
    800066fa:	09a1                	addi	s3,s3,8
    800066fc:	fb491be3          	bne	s2,s4,800066b2 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006700:	10048913          	addi	s2,s1,256
    80006704:	6088                	ld	a0,0(s1)
    80006706:	c529                	beqz	a0,80006750 <sys_exec+0xf8>
    kfree(argv[i]);
    80006708:	ffffa097          	auipc	ra,0xffffa
    8000670c:	2d2080e7          	jalr	722(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006710:	04a1                	addi	s1,s1,8
    80006712:	ff2499e3          	bne	s1,s2,80006704 <sys_exec+0xac>
  return -1;
    80006716:	597d                	li	s2,-1
    80006718:	a82d                	j	80006752 <sys_exec+0xfa>
      argv[i] = 0;
    8000671a:	0a8e                	slli	s5,s5,0x3
    8000671c:	fc040793          	addi	a5,s0,-64
    80006720:	9abe                	add	s5,s5,a5
    80006722:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006726:	e4040593          	addi	a1,s0,-448
    8000672a:	f4040513          	addi	a0,s0,-192
    8000672e:	fffff097          	auipc	ra,0xfffff
    80006732:	4b8080e7          	jalr	1208(ra) # 80005be6 <exec>
    80006736:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006738:	10048993          	addi	s3,s1,256
    8000673c:	6088                	ld	a0,0(s1)
    8000673e:	c911                	beqz	a0,80006752 <sys_exec+0xfa>
    kfree(argv[i]);
    80006740:	ffffa097          	auipc	ra,0xffffa
    80006744:	29a080e7          	jalr	666(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006748:	04a1                	addi	s1,s1,8
    8000674a:	ff3499e3          	bne	s1,s3,8000673c <sys_exec+0xe4>
    8000674e:	a011                	j	80006752 <sys_exec+0xfa>
  return -1;
    80006750:	597d                	li	s2,-1
}
    80006752:	854a                	mv	a0,s2
    80006754:	60be                	ld	ra,456(sp)
    80006756:	641e                	ld	s0,448(sp)
    80006758:	74fa                	ld	s1,440(sp)
    8000675a:	795a                	ld	s2,432(sp)
    8000675c:	79ba                	ld	s3,424(sp)
    8000675e:	7a1a                	ld	s4,416(sp)
    80006760:	6afa                	ld	s5,408(sp)
    80006762:	6179                	addi	sp,sp,464
    80006764:	8082                	ret

0000000080006766 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006766:	7139                	addi	sp,sp,-64
    80006768:	fc06                	sd	ra,56(sp)
    8000676a:	f822                	sd	s0,48(sp)
    8000676c:	f426                	sd	s1,40(sp)
    8000676e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006770:	ffffb097          	auipc	ra,0xffffb
    80006774:	398080e7          	jalr	920(ra) # 80001b08 <myproc>
    80006778:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    8000677a:	fd840593          	addi	a1,s0,-40
    8000677e:	4501                	li	a0,0
    80006780:	ffffd097          	auipc	ra,0xffffd
    80006784:	244080e7          	jalr	580(ra) # 800039c4 <argaddr>
    return -1;
    80006788:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    8000678a:	0e054063          	bltz	a0,8000686a <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    8000678e:	fc840593          	addi	a1,s0,-56
    80006792:	fd040513          	addi	a0,s0,-48
    80006796:	fffff097          	auipc	ra,0xfffff
    8000679a:	122080e7          	jalr	290(ra) # 800058b8 <pipealloc>
    return -1;
    8000679e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800067a0:	0c054563          	bltz	a0,8000686a <sys_pipe+0x104>
  fd0 = -1;
    800067a4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800067a8:	fd043503          	ld	a0,-48(s0)
    800067ac:	fffff097          	auipc	ra,0xfffff
    800067b0:	50a080e7          	jalr	1290(ra) # 80005cb6 <fdalloc>
    800067b4:	fca42223          	sw	a0,-60(s0)
    800067b8:	08054c63          	bltz	a0,80006850 <sys_pipe+0xea>
    800067bc:	fc843503          	ld	a0,-56(s0)
    800067c0:	fffff097          	auipc	ra,0xfffff
    800067c4:	4f6080e7          	jalr	1270(ra) # 80005cb6 <fdalloc>
    800067c8:	fca42023          	sw	a0,-64(s0)
    800067cc:	06054863          	bltz	a0,8000683c <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800067d0:	4691                	li	a3,4
    800067d2:	fc440613          	addi	a2,s0,-60
    800067d6:	fd843583          	ld	a1,-40(s0)
    800067da:	60a8                	ld	a0,64(s1)
    800067dc:	ffffb097          	auipc	ra,0xffffb
    800067e0:	f14080e7          	jalr	-236(ra) # 800016f0 <copyout>
    800067e4:	02054063          	bltz	a0,80006804 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800067e8:	4691                	li	a3,4
    800067ea:	fc040613          	addi	a2,s0,-64
    800067ee:	fd843583          	ld	a1,-40(s0)
    800067f2:	0591                	addi	a1,a1,4
    800067f4:	60a8                	ld	a0,64(s1)
    800067f6:	ffffb097          	auipc	ra,0xffffb
    800067fa:	efa080e7          	jalr	-262(ra) # 800016f0 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800067fe:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006800:	06055563          	bgez	a0,8000686a <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006804:	fc442783          	lw	a5,-60(s0)
    80006808:	07a9                	addi	a5,a5,10
    8000680a:	078e                	slli	a5,a5,0x3
    8000680c:	97a6                	add	a5,a5,s1
    8000680e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006812:	fc042503          	lw	a0,-64(s0)
    80006816:	0529                	addi	a0,a0,10
    80006818:	050e                	slli	a0,a0,0x3
    8000681a:	9526                	add	a0,a0,s1
    8000681c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006820:	fd043503          	ld	a0,-48(s0)
    80006824:	fffff097          	auipc	ra,0xfffff
    80006828:	d64080e7          	jalr	-668(ra) # 80005588 <fileclose>
    fileclose(wf);
    8000682c:	fc843503          	ld	a0,-56(s0)
    80006830:	fffff097          	auipc	ra,0xfffff
    80006834:	d58080e7          	jalr	-680(ra) # 80005588 <fileclose>
    return -1;
    80006838:	57fd                	li	a5,-1
    8000683a:	a805                	j	8000686a <sys_pipe+0x104>
    if(fd0 >= 0)
    8000683c:	fc442783          	lw	a5,-60(s0)
    80006840:	0007c863          	bltz	a5,80006850 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006844:	00a78513          	addi	a0,a5,10
    80006848:	050e                	slli	a0,a0,0x3
    8000684a:	9526                	add	a0,a0,s1
    8000684c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006850:	fd043503          	ld	a0,-48(s0)
    80006854:	fffff097          	auipc	ra,0xfffff
    80006858:	d34080e7          	jalr	-716(ra) # 80005588 <fileclose>
    fileclose(wf);
    8000685c:	fc843503          	ld	a0,-56(s0)
    80006860:	fffff097          	auipc	ra,0xfffff
    80006864:	d28080e7          	jalr	-728(ra) # 80005588 <fileclose>
    return -1;
    80006868:	57fd                	li	a5,-1
}
    8000686a:	853e                	mv	a0,a5
    8000686c:	70e2                	ld	ra,56(sp)
    8000686e:	7442                	ld	s0,48(sp)
    80006870:	74a2                	ld	s1,40(sp)
    80006872:	6121                	addi	sp,sp,64
    80006874:	8082                	ret
	...

0000000080006880 <kernelvec>:
    80006880:	7111                	addi	sp,sp,-256
    80006882:	e006                	sd	ra,0(sp)
    80006884:	e40a                	sd	sp,8(sp)
    80006886:	e80e                	sd	gp,16(sp)
    80006888:	ec12                	sd	tp,24(sp)
    8000688a:	f016                	sd	t0,32(sp)
    8000688c:	f41a                	sd	t1,40(sp)
    8000688e:	f81e                	sd	t2,48(sp)
    80006890:	fc22                	sd	s0,56(sp)
    80006892:	e0a6                	sd	s1,64(sp)
    80006894:	e4aa                	sd	a0,72(sp)
    80006896:	e8ae                	sd	a1,80(sp)
    80006898:	ecb2                	sd	a2,88(sp)
    8000689a:	f0b6                	sd	a3,96(sp)
    8000689c:	f4ba                	sd	a4,104(sp)
    8000689e:	f8be                	sd	a5,112(sp)
    800068a0:	fcc2                	sd	a6,120(sp)
    800068a2:	e146                	sd	a7,128(sp)
    800068a4:	e54a                	sd	s2,136(sp)
    800068a6:	e94e                	sd	s3,144(sp)
    800068a8:	ed52                	sd	s4,152(sp)
    800068aa:	f156                	sd	s5,160(sp)
    800068ac:	f55a                	sd	s6,168(sp)
    800068ae:	f95e                	sd	s7,176(sp)
    800068b0:	fd62                	sd	s8,184(sp)
    800068b2:	e1e6                	sd	s9,192(sp)
    800068b4:	e5ea                	sd	s10,200(sp)
    800068b6:	e9ee                	sd	s11,208(sp)
    800068b8:	edf2                	sd	t3,216(sp)
    800068ba:	f1f6                	sd	t4,224(sp)
    800068bc:	f5fa                	sd	t5,232(sp)
    800068be:	f9fe                	sd	t6,240(sp)
    800068c0:	f03fc0ef          	jal	ra,800037c2 <kerneltrap>
    800068c4:	6082                	ld	ra,0(sp)
    800068c6:	6122                	ld	sp,8(sp)
    800068c8:	61c2                	ld	gp,16(sp)
    800068ca:	7282                	ld	t0,32(sp)
    800068cc:	7322                	ld	t1,40(sp)
    800068ce:	73c2                	ld	t2,48(sp)
    800068d0:	7462                	ld	s0,56(sp)
    800068d2:	6486                	ld	s1,64(sp)
    800068d4:	6526                	ld	a0,72(sp)
    800068d6:	65c6                	ld	a1,80(sp)
    800068d8:	6666                	ld	a2,88(sp)
    800068da:	7686                	ld	a3,96(sp)
    800068dc:	7726                	ld	a4,104(sp)
    800068de:	77c6                	ld	a5,112(sp)
    800068e0:	7866                	ld	a6,120(sp)
    800068e2:	688a                	ld	a7,128(sp)
    800068e4:	692a                	ld	s2,136(sp)
    800068e6:	69ca                	ld	s3,144(sp)
    800068e8:	6a6a                	ld	s4,152(sp)
    800068ea:	7a8a                	ld	s5,160(sp)
    800068ec:	7b2a                	ld	s6,168(sp)
    800068ee:	7bca                	ld	s7,176(sp)
    800068f0:	7c6a                	ld	s8,184(sp)
    800068f2:	6c8e                	ld	s9,192(sp)
    800068f4:	6d2e                	ld	s10,200(sp)
    800068f6:	6dce                	ld	s11,208(sp)
    800068f8:	6e6e                	ld	t3,216(sp)
    800068fa:	7e8e                	ld	t4,224(sp)
    800068fc:	7f2e                	ld	t5,232(sp)
    800068fe:	7fce                	ld	t6,240(sp)
    80006900:	6111                	addi	sp,sp,256
    80006902:	10200073          	sret
    80006906:	00000013          	nop
    8000690a:	00000013          	nop
    8000690e:	0001                	nop

0000000080006910 <timervec>:
    80006910:	34051573          	csrrw	a0,mscratch,a0
    80006914:	e10c                	sd	a1,0(a0)
    80006916:	e510                	sd	a2,8(a0)
    80006918:	e914                	sd	a3,16(a0)
    8000691a:	6d0c                	ld	a1,24(a0)
    8000691c:	7110                	ld	a2,32(a0)
    8000691e:	6194                	ld	a3,0(a1)
    80006920:	96b2                	add	a3,a3,a2
    80006922:	e194                	sd	a3,0(a1)
    80006924:	4589                	li	a1,2
    80006926:	14459073          	csrw	sip,a1
    8000692a:	6914                	ld	a3,16(a0)
    8000692c:	6510                	ld	a2,8(a0)
    8000692e:	610c                	ld	a1,0(a0)
    80006930:	34051573          	csrrw	a0,mscratch,a0
    80006934:	30200073          	mret
	...

000000008000693a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000693a:	1141                	addi	sp,sp,-16
    8000693c:	e422                	sd	s0,8(sp)
    8000693e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006940:	0c0007b7          	lui	a5,0xc000
    80006944:	4705                	li	a4,1
    80006946:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006948:	c3d8                	sw	a4,4(a5)
}
    8000694a:	6422                	ld	s0,8(sp)
    8000694c:	0141                	addi	sp,sp,16
    8000694e:	8082                	ret

0000000080006950 <plicinithart>:

void
plicinithart(void)
{
    80006950:	1141                	addi	sp,sp,-16
    80006952:	e406                	sd	ra,8(sp)
    80006954:	e022                	sd	s0,0(sp)
    80006956:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006958:	ffffb097          	auipc	ra,0xffffb
    8000695c:	17c080e7          	jalr	380(ra) # 80001ad4 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006960:	0085171b          	slliw	a4,a0,0x8
    80006964:	0c0027b7          	lui	a5,0xc002
    80006968:	97ba                	add	a5,a5,a4
    8000696a:	40200713          	li	a4,1026
    8000696e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006972:	00d5151b          	slliw	a0,a0,0xd
    80006976:	0c2017b7          	lui	a5,0xc201
    8000697a:	953e                	add	a0,a0,a5
    8000697c:	00052023          	sw	zero,0(a0)
}
    80006980:	60a2                	ld	ra,8(sp)
    80006982:	6402                	ld	s0,0(sp)
    80006984:	0141                	addi	sp,sp,16
    80006986:	8082                	ret

0000000080006988 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006988:	1141                	addi	sp,sp,-16
    8000698a:	e406                	sd	ra,8(sp)
    8000698c:	e022                	sd	s0,0(sp)
    8000698e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006990:	ffffb097          	auipc	ra,0xffffb
    80006994:	144080e7          	jalr	324(ra) # 80001ad4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006998:	00d5179b          	slliw	a5,a0,0xd
    8000699c:	0c201537          	lui	a0,0xc201
    800069a0:	953e                	add	a0,a0,a5
  return irq;
}
    800069a2:	4148                	lw	a0,4(a0)
    800069a4:	60a2                	ld	ra,8(sp)
    800069a6:	6402                	ld	s0,0(sp)
    800069a8:	0141                	addi	sp,sp,16
    800069aa:	8082                	ret

00000000800069ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800069ac:	1101                	addi	sp,sp,-32
    800069ae:	ec06                	sd	ra,24(sp)
    800069b0:	e822                	sd	s0,16(sp)
    800069b2:	e426                	sd	s1,8(sp)
    800069b4:	1000                	addi	s0,sp,32
    800069b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800069b8:	ffffb097          	auipc	ra,0xffffb
    800069bc:	11c080e7          	jalr	284(ra) # 80001ad4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800069c0:	00d5151b          	slliw	a0,a0,0xd
    800069c4:	0c2017b7          	lui	a5,0xc201
    800069c8:	97aa                	add	a5,a5,a0
    800069ca:	c3c4                	sw	s1,4(a5)
}
    800069cc:	60e2                	ld	ra,24(sp)
    800069ce:	6442                	ld	s0,16(sp)
    800069d0:	64a2                	ld	s1,8(sp)
    800069d2:	6105                	addi	sp,sp,32
    800069d4:	8082                	ret

00000000800069d6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800069d6:	1141                	addi	sp,sp,-16
    800069d8:	e406                	sd	ra,8(sp)
    800069da:	e022                	sd	s0,0(sp)
    800069dc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800069de:	479d                	li	a5,7
    800069e0:	06a7c963          	blt	a5,a0,80006a52 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800069e4:	00037797          	auipc	a5,0x37
    800069e8:	61c78793          	addi	a5,a5,1564 # 8003e000 <disk>
    800069ec:	00a78733          	add	a4,a5,a0
    800069f0:	6789                	lui	a5,0x2
    800069f2:	97ba                	add	a5,a5,a4
    800069f4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800069f8:	e7ad                	bnez	a5,80006a62 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800069fa:	00451793          	slli	a5,a0,0x4
    800069fe:	00039717          	auipc	a4,0x39
    80006a02:	60270713          	addi	a4,a4,1538 # 80040000 <disk+0x2000>
    80006a06:	6314                	ld	a3,0(a4)
    80006a08:	96be                	add	a3,a3,a5
    80006a0a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006a0e:	6314                	ld	a3,0(a4)
    80006a10:	96be                	add	a3,a3,a5
    80006a12:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006a16:	6314                	ld	a3,0(a4)
    80006a18:	96be                	add	a3,a3,a5
    80006a1a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006a1e:	6318                	ld	a4,0(a4)
    80006a20:	97ba                	add	a5,a5,a4
    80006a22:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006a26:	00037797          	auipc	a5,0x37
    80006a2a:	5da78793          	addi	a5,a5,1498 # 8003e000 <disk>
    80006a2e:	97aa                	add	a5,a5,a0
    80006a30:	6509                	lui	a0,0x2
    80006a32:	953e                	add	a0,a0,a5
    80006a34:	4785                	li	a5,1
    80006a36:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006a3a:	00039517          	auipc	a0,0x39
    80006a3e:	5de50513          	addi	a0,a0,1502 # 80040018 <disk+0x2018>
    80006a42:	ffffc097          	auipc	ra,0xffffc
    80006a46:	ce0080e7          	jalr	-800(ra) # 80002722 <wakeup>
}
    80006a4a:	60a2                	ld	ra,8(sp)
    80006a4c:	6402                	ld	s0,0(sp)
    80006a4e:	0141                	addi	sp,sp,16
    80006a50:	8082                	ret
    panic("free_desc 1");
    80006a52:	00002517          	auipc	a0,0x2
    80006a56:	f8e50513          	addi	a0,a0,-114 # 800089e0 <syscalls+0x338>
    80006a5a:	ffffa097          	auipc	ra,0xffffa
    80006a5e:	ad4080e7          	jalr	-1324(ra) # 8000052e <panic>
    panic("free_desc 2");
    80006a62:	00002517          	auipc	a0,0x2
    80006a66:	f8e50513          	addi	a0,a0,-114 # 800089f0 <syscalls+0x348>
    80006a6a:	ffffa097          	auipc	ra,0xffffa
    80006a6e:	ac4080e7          	jalr	-1340(ra) # 8000052e <panic>

0000000080006a72 <virtio_disk_init>:
{
    80006a72:	1101                	addi	sp,sp,-32
    80006a74:	ec06                	sd	ra,24(sp)
    80006a76:	e822                	sd	s0,16(sp)
    80006a78:	e426                	sd	s1,8(sp)
    80006a7a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006a7c:	00002597          	auipc	a1,0x2
    80006a80:	f8458593          	addi	a1,a1,-124 # 80008a00 <syscalls+0x358>
    80006a84:	00039517          	auipc	a0,0x39
    80006a88:	6a450513          	addi	a0,a0,1700 # 80040128 <disk+0x2128>
    80006a8c:	ffffa097          	auipc	ra,0xffffa
    80006a90:	0aa080e7          	jalr	170(ra) # 80000b36 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006a94:	100017b7          	lui	a5,0x10001
    80006a98:	4398                	lw	a4,0(a5)
    80006a9a:	2701                	sext.w	a4,a4
    80006a9c:	747277b7          	lui	a5,0x74727
    80006aa0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006aa4:	0ef71163          	bne	a4,a5,80006b86 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006aa8:	100017b7          	lui	a5,0x10001
    80006aac:	43dc                	lw	a5,4(a5)
    80006aae:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006ab0:	4705                	li	a4,1
    80006ab2:	0ce79a63          	bne	a5,a4,80006b86 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006ab6:	100017b7          	lui	a5,0x10001
    80006aba:	479c                	lw	a5,8(a5)
    80006abc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006abe:	4709                	li	a4,2
    80006ac0:	0ce79363          	bne	a5,a4,80006b86 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006ac4:	100017b7          	lui	a5,0x10001
    80006ac8:	47d8                	lw	a4,12(a5)
    80006aca:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006acc:	554d47b7          	lui	a5,0x554d4
    80006ad0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006ad4:	0af71963          	bne	a4,a5,80006b86 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006ad8:	100017b7          	lui	a5,0x10001
    80006adc:	4705                	li	a4,1
    80006ade:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006ae0:	470d                	li	a4,3
    80006ae2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006ae4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006ae6:	c7ffe737          	lui	a4,0xc7ffe
    80006aea:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fbd75f>
    80006aee:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006af0:	2701                	sext.w	a4,a4
    80006af2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006af4:	472d                	li	a4,11
    80006af6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006af8:	473d                	li	a4,15
    80006afa:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006afc:	6705                	lui	a4,0x1
    80006afe:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006b00:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006b04:	5bdc                	lw	a5,52(a5)
    80006b06:	2781                	sext.w	a5,a5
  if(max == 0)
    80006b08:	c7d9                	beqz	a5,80006b96 <virtio_disk_init+0x124>
  if(max < NUM)
    80006b0a:	471d                	li	a4,7
    80006b0c:	08f77d63          	bgeu	a4,a5,80006ba6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006b10:	100014b7          	lui	s1,0x10001
    80006b14:	47a1                	li	a5,8
    80006b16:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006b18:	6609                	lui	a2,0x2
    80006b1a:	4581                	li	a1,0
    80006b1c:	00037517          	auipc	a0,0x37
    80006b20:	4e450513          	addi	a0,a0,1252 # 8003e000 <disk>
    80006b24:	ffffa097          	auipc	ra,0xffffa
    80006b28:	1b4080e7          	jalr	436(ra) # 80000cd8 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006b2c:	00037717          	auipc	a4,0x37
    80006b30:	4d470713          	addi	a4,a4,1236 # 8003e000 <disk>
    80006b34:	00c75793          	srli	a5,a4,0xc
    80006b38:	2781                	sext.w	a5,a5
    80006b3a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006b3c:	00039797          	auipc	a5,0x39
    80006b40:	4c478793          	addi	a5,a5,1220 # 80040000 <disk+0x2000>
    80006b44:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006b46:	00037717          	auipc	a4,0x37
    80006b4a:	53a70713          	addi	a4,a4,1338 # 8003e080 <disk+0x80>
    80006b4e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006b50:	00038717          	auipc	a4,0x38
    80006b54:	4b070713          	addi	a4,a4,1200 # 8003f000 <disk+0x1000>
    80006b58:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006b5a:	4705                	li	a4,1
    80006b5c:	00e78c23          	sb	a4,24(a5)
    80006b60:	00e78ca3          	sb	a4,25(a5)
    80006b64:	00e78d23          	sb	a4,26(a5)
    80006b68:	00e78da3          	sb	a4,27(a5)
    80006b6c:	00e78e23          	sb	a4,28(a5)
    80006b70:	00e78ea3          	sb	a4,29(a5)
    80006b74:	00e78f23          	sb	a4,30(a5)
    80006b78:	00e78fa3          	sb	a4,31(a5)
}
    80006b7c:	60e2                	ld	ra,24(sp)
    80006b7e:	6442                	ld	s0,16(sp)
    80006b80:	64a2                	ld	s1,8(sp)
    80006b82:	6105                	addi	sp,sp,32
    80006b84:	8082                	ret
    panic("could not find virtio disk");
    80006b86:	00002517          	auipc	a0,0x2
    80006b8a:	e8a50513          	addi	a0,a0,-374 # 80008a10 <syscalls+0x368>
    80006b8e:	ffffa097          	auipc	ra,0xffffa
    80006b92:	9a0080e7          	jalr	-1632(ra) # 8000052e <panic>
    panic("virtio disk has no queue 0");
    80006b96:	00002517          	auipc	a0,0x2
    80006b9a:	e9a50513          	addi	a0,a0,-358 # 80008a30 <syscalls+0x388>
    80006b9e:	ffffa097          	auipc	ra,0xffffa
    80006ba2:	990080e7          	jalr	-1648(ra) # 8000052e <panic>
    panic("virtio disk max queue too short");
    80006ba6:	00002517          	auipc	a0,0x2
    80006baa:	eaa50513          	addi	a0,a0,-342 # 80008a50 <syscalls+0x3a8>
    80006bae:	ffffa097          	auipc	ra,0xffffa
    80006bb2:	980080e7          	jalr	-1664(ra) # 8000052e <panic>

0000000080006bb6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006bb6:	7119                	addi	sp,sp,-128
    80006bb8:	fc86                	sd	ra,120(sp)
    80006bba:	f8a2                	sd	s0,112(sp)
    80006bbc:	f4a6                	sd	s1,104(sp)
    80006bbe:	f0ca                	sd	s2,96(sp)
    80006bc0:	ecce                	sd	s3,88(sp)
    80006bc2:	e8d2                	sd	s4,80(sp)
    80006bc4:	e4d6                	sd	s5,72(sp)
    80006bc6:	e0da                	sd	s6,64(sp)
    80006bc8:	fc5e                	sd	s7,56(sp)
    80006bca:	f862                	sd	s8,48(sp)
    80006bcc:	f466                	sd	s9,40(sp)
    80006bce:	f06a                	sd	s10,32(sp)
    80006bd0:	ec6e                	sd	s11,24(sp)
    80006bd2:	0100                	addi	s0,sp,128
    80006bd4:	8aaa                	mv	s5,a0
    80006bd6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006bd8:	00c52c83          	lw	s9,12(a0)
    80006bdc:	001c9c9b          	slliw	s9,s9,0x1
    80006be0:	1c82                	slli	s9,s9,0x20
    80006be2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006be6:	00039517          	auipc	a0,0x39
    80006bea:	54250513          	addi	a0,a0,1346 # 80040128 <disk+0x2128>
    80006bee:	ffffa097          	auipc	ra,0xffffa
    80006bf2:	fd8080e7          	jalr	-40(ra) # 80000bc6 <acquire>
  for(int i = 0; i < 3; i++){
    80006bf6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006bf8:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006bfa:	00037c17          	auipc	s8,0x37
    80006bfe:	406c0c13          	addi	s8,s8,1030 # 8003e000 <disk>
    80006c02:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006c04:	4b0d                	li	s6,3
    80006c06:	a0ad                	j	80006c70 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006c08:	00fc0733          	add	a4,s8,a5
    80006c0c:	975e                	add	a4,a4,s7
    80006c0e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006c12:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006c14:	0207c563          	bltz	a5,80006c3e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006c18:	2905                	addiw	s2,s2,1
    80006c1a:	0611                	addi	a2,a2,4
    80006c1c:	19690d63          	beq	s2,s6,80006db6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006c20:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006c22:	00039717          	auipc	a4,0x39
    80006c26:	3f670713          	addi	a4,a4,1014 # 80040018 <disk+0x2018>
    80006c2a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006c2c:	00074683          	lbu	a3,0(a4)
    80006c30:	fee1                	bnez	a3,80006c08 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006c32:	2785                	addiw	a5,a5,1
    80006c34:	0705                	addi	a4,a4,1
    80006c36:	fe979be3          	bne	a5,s1,80006c2c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006c3a:	57fd                	li	a5,-1
    80006c3c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006c3e:	01205d63          	blez	s2,80006c58 <virtio_disk_rw+0xa2>
    80006c42:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006c44:	000a2503          	lw	a0,0(s4)
    80006c48:	00000097          	auipc	ra,0x0
    80006c4c:	d8e080e7          	jalr	-626(ra) # 800069d6 <free_desc>
      for(int j = 0; j < i; j++)
    80006c50:	2d85                	addiw	s11,s11,1
    80006c52:	0a11                	addi	s4,s4,4
    80006c54:	ffb918e3          	bne	s2,s11,80006c44 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006c58:	00039597          	auipc	a1,0x39
    80006c5c:	4d058593          	addi	a1,a1,1232 # 80040128 <disk+0x2128>
    80006c60:	00039517          	auipc	a0,0x39
    80006c64:	3b850513          	addi	a0,a0,952 # 80040018 <disk+0x2018>
    80006c68:	ffffc097          	auipc	ra,0xffffc
    80006c6c:	930080e7          	jalr	-1744(ra) # 80002598 <sleep>
  for(int i = 0; i < 3; i++){
    80006c70:	f8040a13          	addi	s4,s0,-128
{
    80006c74:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006c76:	894e                	mv	s2,s3
    80006c78:	b765                	j	80006c20 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006c7a:	00039697          	auipc	a3,0x39
    80006c7e:	3866b683          	ld	a3,902(a3) # 80040000 <disk+0x2000>
    80006c82:	96ba                	add	a3,a3,a4
    80006c84:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006c88:	00037817          	auipc	a6,0x37
    80006c8c:	37880813          	addi	a6,a6,888 # 8003e000 <disk>
    80006c90:	00039697          	auipc	a3,0x39
    80006c94:	37068693          	addi	a3,a3,880 # 80040000 <disk+0x2000>
    80006c98:	6290                	ld	a2,0(a3)
    80006c9a:	963a                	add	a2,a2,a4
    80006c9c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006ca0:	0015e593          	ori	a1,a1,1
    80006ca4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006ca8:	f8842603          	lw	a2,-120(s0)
    80006cac:	628c                	ld	a1,0(a3)
    80006cae:	972e                	add	a4,a4,a1
    80006cb0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006cb4:	20050593          	addi	a1,a0,512
    80006cb8:	0592                	slli	a1,a1,0x4
    80006cba:	95c2                	add	a1,a1,a6
    80006cbc:	577d                	li	a4,-1
    80006cbe:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006cc2:	00461713          	slli	a4,a2,0x4
    80006cc6:	6290                	ld	a2,0(a3)
    80006cc8:	963a                	add	a2,a2,a4
    80006cca:	03078793          	addi	a5,a5,48
    80006cce:	97c2                	add	a5,a5,a6
    80006cd0:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006cd2:	629c                	ld	a5,0(a3)
    80006cd4:	97ba                	add	a5,a5,a4
    80006cd6:	4605                	li	a2,1
    80006cd8:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006cda:	629c                	ld	a5,0(a3)
    80006cdc:	97ba                	add	a5,a5,a4
    80006cde:	4809                	li	a6,2
    80006ce0:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006ce4:	629c                	ld	a5,0(a3)
    80006ce6:	973e                	add	a4,a4,a5
    80006ce8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006cec:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006cf0:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006cf4:	6698                	ld	a4,8(a3)
    80006cf6:	00275783          	lhu	a5,2(a4)
    80006cfa:	8b9d                	andi	a5,a5,7
    80006cfc:	0786                	slli	a5,a5,0x1
    80006cfe:	97ba                	add	a5,a5,a4
    80006d00:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006d04:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006d08:	6698                	ld	a4,8(a3)
    80006d0a:	00275783          	lhu	a5,2(a4)
    80006d0e:	2785                	addiw	a5,a5,1
    80006d10:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006d14:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006d18:	100017b7          	lui	a5,0x10001
    80006d1c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006d20:	004aa783          	lw	a5,4(s5)
    80006d24:	02c79163          	bne	a5,a2,80006d46 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006d28:	00039917          	auipc	s2,0x39
    80006d2c:	40090913          	addi	s2,s2,1024 # 80040128 <disk+0x2128>
  while(b->disk == 1) {
    80006d30:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006d32:	85ca                	mv	a1,s2
    80006d34:	8556                	mv	a0,s5
    80006d36:	ffffc097          	auipc	ra,0xffffc
    80006d3a:	862080e7          	jalr	-1950(ra) # 80002598 <sleep>
  while(b->disk == 1) {
    80006d3e:	004aa783          	lw	a5,4(s5)
    80006d42:	fe9788e3          	beq	a5,s1,80006d32 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006d46:	f8042903          	lw	s2,-128(s0)
    80006d4a:	20090793          	addi	a5,s2,512
    80006d4e:	00479713          	slli	a4,a5,0x4
    80006d52:	00037797          	auipc	a5,0x37
    80006d56:	2ae78793          	addi	a5,a5,686 # 8003e000 <disk>
    80006d5a:	97ba                	add	a5,a5,a4
    80006d5c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006d60:	00039997          	auipc	s3,0x39
    80006d64:	2a098993          	addi	s3,s3,672 # 80040000 <disk+0x2000>
    80006d68:	00491713          	slli	a4,s2,0x4
    80006d6c:	0009b783          	ld	a5,0(s3)
    80006d70:	97ba                	add	a5,a5,a4
    80006d72:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006d76:	854a                	mv	a0,s2
    80006d78:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006d7c:	00000097          	auipc	ra,0x0
    80006d80:	c5a080e7          	jalr	-934(ra) # 800069d6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006d84:	8885                	andi	s1,s1,1
    80006d86:	f0ed                	bnez	s1,80006d68 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006d88:	00039517          	auipc	a0,0x39
    80006d8c:	3a050513          	addi	a0,a0,928 # 80040128 <disk+0x2128>
    80006d90:	ffffa097          	auipc	ra,0xffffa
    80006d94:	f00080e7          	jalr	-256(ra) # 80000c90 <release>
}
    80006d98:	70e6                	ld	ra,120(sp)
    80006d9a:	7446                	ld	s0,112(sp)
    80006d9c:	74a6                	ld	s1,104(sp)
    80006d9e:	7906                	ld	s2,96(sp)
    80006da0:	69e6                	ld	s3,88(sp)
    80006da2:	6a46                	ld	s4,80(sp)
    80006da4:	6aa6                	ld	s5,72(sp)
    80006da6:	6b06                	ld	s6,64(sp)
    80006da8:	7be2                	ld	s7,56(sp)
    80006daa:	7c42                	ld	s8,48(sp)
    80006dac:	7ca2                	ld	s9,40(sp)
    80006dae:	7d02                	ld	s10,32(sp)
    80006db0:	6de2                	ld	s11,24(sp)
    80006db2:	6109                	addi	sp,sp,128
    80006db4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006db6:	f8042503          	lw	a0,-128(s0)
    80006dba:	20050793          	addi	a5,a0,512
    80006dbe:	0792                	slli	a5,a5,0x4
  if(write)
    80006dc0:	00037817          	auipc	a6,0x37
    80006dc4:	24080813          	addi	a6,a6,576 # 8003e000 <disk>
    80006dc8:	00f80733          	add	a4,a6,a5
    80006dcc:	01a036b3          	snez	a3,s10
    80006dd0:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006dd4:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006dd8:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006ddc:	7679                	lui	a2,0xffffe
    80006dde:	963e                	add	a2,a2,a5
    80006de0:	00039697          	auipc	a3,0x39
    80006de4:	22068693          	addi	a3,a3,544 # 80040000 <disk+0x2000>
    80006de8:	6298                	ld	a4,0(a3)
    80006dea:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006dec:	0a878593          	addi	a1,a5,168
    80006df0:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006df2:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006df4:	6298                	ld	a4,0(a3)
    80006df6:	9732                	add	a4,a4,a2
    80006df8:	45c1                	li	a1,16
    80006dfa:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006dfc:	6298                	ld	a4,0(a3)
    80006dfe:	9732                	add	a4,a4,a2
    80006e00:	4585                	li	a1,1
    80006e02:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006e06:	f8442703          	lw	a4,-124(s0)
    80006e0a:	628c                	ld	a1,0(a3)
    80006e0c:	962e                	add	a2,a2,a1
    80006e0e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffbd00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006e12:	0712                	slli	a4,a4,0x4
    80006e14:	6290                	ld	a2,0(a3)
    80006e16:	963a                	add	a2,a2,a4
    80006e18:	058a8593          	addi	a1,s5,88
    80006e1c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006e1e:	6294                	ld	a3,0(a3)
    80006e20:	96ba                	add	a3,a3,a4
    80006e22:	40000613          	li	a2,1024
    80006e26:	c690                	sw	a2,8(a3)
  if(write)
    80006e28:	e40d19e3          	bnez	s10,80006c7a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006e2c:	00039697          	auipc	a3,0x39
    80006e30:	1d46b683          	ld	a3,468(a3) # 80040000 <disk+0x2000>
    80006e34:	96ba                	add	a3,a3,a4
    80006e36:	4609                	li	a2,2
    80006e38:	00c69623          	sh	a2,12(a3)
    80006e3c:	b5b1                	j	80006c88 <virtio_disk_rw+0xd2>

0000000080006e3e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006e3e:	1101                	addi	sp,sp,-32
    80006e40:	ec06                	sd	ra,24(sp)
    80006e42:	e822                	sd	s0,16(sp)
    80006e44:	e426                	sd	s1,8(sp)
    80006e46:	e04a                	sd	s2,0(sp)
    80006e48:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006e4a:	00039517          	auipc	a0,0x39
    80006e4e:	2de50513          	addi	a0,a0,734 # 80040128 <disk+0x2128>
    80006e52:	ffffa097          	auipc	ra,0xffffa
    80006e56:	d74080e7          	jalr	-652(ra) # 80000bc6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006e5a:	10001737          	lui	a4,0x10001
    80006e5e:	533c                	lw	a5,96(a4)
    80006e60:	8b8d                	andi	a5,a5,3
    80006e62:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006e64:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006e68:	00039797          	auipc	a5,0x39
    80006e6c:	19878793          	addi	a5,a5,408 # 80040000 <disk+0x2000>
    80006e70:	6b94                	ld	a3,16(a5)
    80006e72:	0207d703          	lhu	a4,32(a5)
    80006e76:	0026d783          	lhu	a5,2(a3)
    80006e7a:	06f70163          	beq	a4,a5,80006edc <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006e7e:	00037917          	auipc	s2,0x37
    80006e82:	18290913          	addi	s2,s2,386 # 8003e000 <disk>
    80006e86:	00039497          	auipc	s1,0x39
    80006e8a:	17a48493          	addi	s1,s1,378 # 80040000 <disk+0x2000>
    __sync_synchronize();
    80006e8e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006e92:	6898                	ld	a4,16(s1)
    80006e94:	0204d783          	lhu	a5,32(s1)
    80006e98:	8b9d                	andi	a5,a5,7
    80006e9a:	078e                	slli	a5,a5,0x3
    80006e9c:	97ba                	add	a5,a5,a4
    80006e9e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006ea0:	20078713          	addi	a4,a5,512
    80006ea4:	0712                	slli	a4,a4,0x4
    80006ea6:	974a                	add	a4,a4,s2
    80006ea8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80006eac:	e731                	bnez	a4,80006ef8 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006eae:	20078793          	addi	a5,a5,512
    80006eb2:	0792                	slli	a5,a5,0x4
    80006eb4:	97ca                	add	a5,a5,s2
    80006eb6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006eb8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006ebc:	ffffc097          	auipc	ra,0xffffc
    80006ec0:	866080e7          	jalr	-1946(ra) # 80002722 <wakeup>

    disk.used_idx += 1;
    80006ec4:	0204d783          	lhu	a5,32(s1)
    80006ec8:	2785                	addiw	a5,a5,1
    80006eca:	17c2                	slli	a5,a5,0x30
    80006ecc:	93c1                	srli	a5,a5,0x30
    80006ece:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006ed2:	6898                	ld	a4,16(s1)
    80006ed4:	00275703          	lhu	a4,2(a4)
    80006ed8:	faf71be3          	bne	a4,a5,80006e8e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80006edc:	00039517          	auipc	a0,0x39
    80006ee0:	24c50513          	addi	a0,a0,588 # 80040128 <disk+0x2128>
    80006ee4:	ffffa097          	auipc	ra,0xffffa
    80006ee8:	dac080e7          	jalr	-596(ra) # 80000c90 <release>
}
    80006eec:	60e2                	ld	ra,24(sp)
    80006eee:	6442                	ld	s0,16(sp)
    80006ef0:	64a2                	ld	s1,8(sp)
    80006ef2:	6902                	ld	s2,0(sp)
    80006ef4:	6105                	addi	sp,sp,32
    80006ef6:	8082                	ret
      panic("virtio_disk_intr status");
    80006ef8:	00002517          	auipc	a0,0x2
    80006efc:	b7850513          	addi	a0,a0,-1160 # 80008a70 <syscalls+0x3c8>
    80006f00:	ffff9097          	auipc	ra,0xffff9
    80006f04:	62e080e7          	jalr	1582(ra) # 8000052e <panic>

0000000080006f08 <call_sigret>:
    80006f08:	48e1                	li	a7,24
    80006f0a:	00000073          	ecall
    80006f0e:	8082                	ret

0000000080006f10 <end_sigret>:
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
